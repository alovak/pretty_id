require "pretty_id/version"
require "pretty_id/sec_random"
require "pretty_id/generator"
require 'active_support/concern'

module PrettyId
  extend ActiveSupport::Concern

  included do
    self.primary_key = 'id'
  end

  class_methods do
    def id_prefix=(prefix)
      @id_prefix = prefix
    end

    def id_prefix
      @id_prefix || name.downcase[0, 3]
    end
  end

  def _create_record(*)
    attempt ||= 1
    set_pretty_id
    super
  rescue ActiveRecord::RecordNotUnique => e
    attempt += 1
    retry if attempt < 4

    raise
  end

  private

  def set_pretty_id
    self.id = PrettyId::Generator.new(self).id
  end
end
