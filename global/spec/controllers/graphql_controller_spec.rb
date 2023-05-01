# frozen_string_literal: true

require 'rails_helper'

class TestGraphqlControllerSubscriber < ActiveSupport::LogSubscriber
  attr_reader :backtrace, :message

  def process_action(event)
    @backtrace = event.payload[:exception_object].backtrace
    @message = event.payload[:exception_object].message
  end
end

RSpec.describe(GraphqlController) do
  let(:body) { JSON.parse(response.body) }
  let(:headers) { {} }
  let(:user) { User.new(id: SecureRandom.uuid) }
  let(:params) { {} }
  let(:schema) { Schema.tap { post :execute, params: } }

  before do
    allow(Schema).to(receive(:execute))
    headers.each { |k, v| request.headers[k.to_s] = v }
  end

  shared_examples 'expected args' do
    it 'calls Schema.execute with expected args' do
      expect(schema).to have_received(:execute).with(nil, hash_including(args))
    end
  end

  context 'when passed variables as a JSON string' do
    let(:args) { { variables: { 'foo' => 'bar' } } }
    let(:params) { { variables: { foo: :bar }.to_json } }

    it_behaves_like 'expected args'

    context 'when that string is blank' do
      let(:args) { { variables: {} } }
      let(:params) { { variables: '' } }

      it_behaves_like 'expected args'
    end
  end

  context 'when a hash of variables is passed' do
    let(:args) { { variables: { 'foo' => 'bar' } } }
    let(:params) { { variables: { foo: :bar } } }

    it_behaves_like 'expected args'
  end

  context 'when variables is an unexpected type' do
    let(:params) { { variables: %i[foo bar] } }

    it 'raises an error' do
      expect { schema }.to(raise_error(ArgumentError))
    end
  end

  context 'when a query is provided' do
    let(:params) { { query: 'query Foo { foo { bar } }' } }

    it 'passes the arguent to execute' do
      expect(schema).to have_received(:execute).with(params[:query], any_args)
    end
  end

  context 'when an X-Authenticated-User header is present' do
    let(:args) { { context: hash_including(current_user: user) } }
    let(:headers) { { 'X-Authenticated-User': Base64.encode64("{\"id\":\"#{user.id}\",\"fooBar\":\"bazinga\"}") } }
    let(:user) { User.new(id: SecureRandom.uuid) }

    before { schema }

    it_behaves_like 'expected args'

    it 'converts auth context keys to snake case' do
      expect(controller.instance_variable_get(:@current_user).data[:foo_bar]).to eq('bazinga')
    end

    context 'when authorization is invalid' do
      let(:args) { { context: hash_including(current_user: nil) } }
      let(:headers) { { 'X-Authenticated-User': 'not a valid auth context' } }

      it_behaves_like 'expected args'
    end
  end

  context 'when query execution produces an error in development' do
    before do
      allow(Schema).to(receive(:execute).and_raise(StandardError))
      allow(Rails.env).to(receive(:development?).and_return(true))
      schema
    end

    it 'renders the error in a GraphQL response' do
      expect(body.dig('errors', 0, 'message')).to(eq('StandardError'))
    end
  end

  context 'when there is a log subscriber handling exceptions' do
    let!(:subscriber) do
      TestGraphqlControllerSubscriber.attach_to(:action_controller)
      TestGraphqlControllerSubscriber.subscribers[-1]
    end

    before do
      allow(Schema).to receive(:execute).and_raise(StandardError)
      begin
        schema
      rescue StandardError
        nil
      end
    end

    after do
      TestGraphqlControllerSubscriber.detach_from(:action_controller)
    end

    it 'includes the exception backtrace in the event payload' do
      expect(subscriber.backtrace).to include(a_string_matching(":in `execute'"))
    end

    it 'includes the exception message in the event payload' do
      expect(subscriber.message).to eq('StandardError')
    end
  end
end
