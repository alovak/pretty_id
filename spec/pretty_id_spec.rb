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

  context 'when id separator is specified' do
    context 'when separator is not nil' do
      it 'creates id with specified separator' do
        Account.id_separator = '#'
        account = Account.create!

        expect(account.id).to match /^acnt#/
      end
    end

    context 'when separator is nil' do
      it 'creates id with specified separator' do
        Account.id_separator = nil
        account = Account.create!

        expect(account.id).to match /^acnt(\w+)/
      end
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

  it 'sets primary_key to id' do
    expect(Account.primary_key).to eq('id')
  end
end
