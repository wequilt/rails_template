# frozen_string_literal: true

module GraphQLInspectionHelpers
  extend RSpec::SharedContext

  let(:inspect_id_map) { raise 'Must be defined' }

  def args_for(field)
    field.arguments.map do |arg_name, arg|
      next unless arg.type.non_null?

      arg_value_for(field, arg, arg_name)
    end.join(' ')
  end

  def arg_value_for(field, arg, arg_name)
    if arg.type.of_type == GraphQL::Types::String
      %(#{arg_name}: "test")
    elsif arg.type.of_type == GraphQL::Types::Int
      "#{arg_name}: 1"
    elsif arg.type.of_type == GraphQL::Types::ID
      %(#{arg_name}: "#{inspect_id_map.with_indifferent_access.dig(field.name, arg_name)}")
    else
      "#{arg_name}: #{arg.type.of_type.values.keys.first}"
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
