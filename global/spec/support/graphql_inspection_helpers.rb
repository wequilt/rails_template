# frozen_string_literal: true

module GraphQLInspectionHelpers
  extend RSpec::SharedContext

  let(:inspect_id_map) { raise 'Must be defined' }

  def args_for(field)
    field.arguments.map do |arg_name, arg|
      next unless arg.type.non_null?

      "#{arg_name}: #{arg_value_for(field, arg.type.of_type, arg_name)}"
    end.join(' ')
  end

  def arg_value_for(field, type, arg_name)
    # case uses === which roughly translates to "is_a?" so a class object isn't === itself
    case type.name
    when 'GraphQL::Types::String' then '"test"'
    when 'GraphQL::Types::Int' then 1
    when 'GraphQL::Types::ID' then %("#{inspect_id_map.with_indifferent_access.dig(field.name, arg_name)}")
    else type.values.keys.first
    end
  end

  def sub_field_for_connection(field)
    sub_field_for_path(field.type.of_type.fields['nodes'].type.of_type)
  rescue StandardError
    nil
  end

  def sub_field_for_null(field)
    sub_field_for_path(field.type)
  rescue StandardError
    nil
  end

  def sub_field_for_non_null(field)
    sub_field_for_path(field.type.of_type)
  rescue StandardError
    nil
  end

  def sub_field_for_list(field)
    sub_field_for_path(field.type.of_type.of_type.of_type)
  rescue StandardError
    nil
  end

  def sub_field_for_path(path)
    path.fields.pluck(1).detect do |sub|
      sub.type.try(:of_type).try(:kind).try(:scalar?) && args_for(sub).empty?
    end.name
  end

  def sub_field_for(field)
    [
      sub_field_for_connection(field),
      sub_field_for_null(field),
      sub_field_for_non_null(field),
      sub_field_for_list(field)
    ].compact.first.then do |sub_field|
      "{ #{sub_field} }" if sub_field.present?
    end
  end
end
