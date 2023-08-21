# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'rake graphql:federation' do
  let(:rover) { Rover.new }

  before do
    allow(Rover).to receive(:new).and_return(rover)
    allow(rover).to receive(:run).and_return(true)
    Rake::Task["graphql:federation:#{task}"].invoke
  end

  describe ':publish' do
    let(:task) { :publish }

    it 'calls rover with expected parameters' do
      expect(Rover).to have_received(:new).with(command: :publish)
    end
  end

  describe ':check' do
    let(:task) { :check }

    it 'calls rover with expected parameters' do
      expect(Rover).to have_received(:new).with(command: :check)
    end
  end

  describe ':admin:publish' do
    let(:task) { :'admin:publish' }

    it 'calls rover with expected parameters' do
      expect(Rover).to have_received(:new).with(command: :publish, admin: true)
    end
  end

  describe ':admin:check' do
    let(:task) { :'admin:check' }

    it 'calls rover with expected parameters' do
      expect(Rover).to have_received(:new).with(command: :check, admin: true)
    end
  end
end
