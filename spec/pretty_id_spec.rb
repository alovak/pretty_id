ActiveRecord::Schema.define do
  create_table :users, id: false do |t|
    t.string :id, null: false
  end
  add_index(:users, :id, unique: true)

  create_table :accounts, id: false do |t|
    t.string :id, null: false
  end
  add_index(:accounts, :id, unique: true)
end

module PrettyId
  extend ActiveSupport::Concern

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

  class Generator
    attr_reader :record

    def initialize(record)
      @record = record
    end

    def id
      "#{prefix}_#{SecRandom.alphanumeric(length)}"
    end

    def length
      12
    end

    def prefix
      if record.class.id_prefix.is_a? Proc
        record.class.id_prefix.call(record)
      else
        record.class.id_prefix
      end
    end
  end

  # taken from Ruby 2.5 implementation
  class SecRandom
    ALPHANUMERIC = [*'A'..'Z', *'a'..'z', *'0'..'9']

    def self.alphanumeric(n=nil)
      n = 16 if n.nil?
      choose(ALPHANUMERIC, n)
    end

    def self.choose(source, n)
      size = source.size
      m = 1
      limit = size
      while limit * size <= 0x100000000
        limit *= size
        m += 1
      end
      result = ''.dup
      while m <= n
        rs = SecureRandom.random_number(limit)
        is = rs.digits(size)
        (m-is.length).times { is << 0 }
        result << source.values_at(*is).join('')
        n -= m
      end
      if 0 < n
        rs = SecureRandom.random_number(limit)
        is = rs.digits(size)
        if is.length < n
          (n-is.length).times { is << 0 }
        else
          is.pop while n < is.length
        end
        result.concat source.values_at(*is).join('')
      end
      result
    end
  end
end

class User < ActiveRecord::Base
  include PrettyId
end

class Account < ActiveRecord::Base
  include PrettyId

  self.id_prefix = 'acnt'

  attr_accessor :type
end

RSpec.describe PrettyId do
  it "has a version number" do
    expect(PrettyId::VERSION).not_to be nil
  end

  it "creates id with first 3 letters of class name as prefix" do
    user = User.create!

    expect(user.id).to match /^use_/
  end

  context 'when id prefix is specified as string' do
    it "creates id with specified prefix" do
      account = Account.create!

      expect(account.id).to match /^acnt_/
    end
  end

  context 'when id prefix is specified as Proc' do
    it "creates id with specified prefix" do
      Account.id_prefix = -> (o) { o.type == 'test' ? 'acc_test' : 'acc_live' }

      account = Account.new
      account.type = 'test'
      account.save

      expect(account.id).to match /^acc_test/

      account = Account.new
      account.type = 'live'
      account.save

      expect(account.id).to match /^acc_live/
    end
  end
end
