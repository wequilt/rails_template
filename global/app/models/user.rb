# frozen_string_literal: true

class User
  attr_reader :data

  def initialize(hash)
    @data = hash.with_indifferent_access
  end

  def id
    data[:id]
  end

  def ==(other)
    id == other.id
  end

  def self.find(id)
    new(id:)
  end
end
