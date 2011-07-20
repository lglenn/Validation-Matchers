require 'rspec'
require 'validation_matchers.rb'

RSpec.configure do |config|
  config.include ValidationMatchers
end

class Error
  def initialize(blank)
    @blank = blank
  end

  def blank?
    return @blank
  end
end

class Slug

  def initialize
    @tests = []
    @errors = {}
  end

  def field
    return @field
  end

  def field=(val)
      @field = val
  end

  def +(test)
    @tests << test
  end

  def gt(val)
    @tests << lambda { |field| field > val }
    self
  end

  def lt(val)
    @tests << lambda { |field| field < val }
    self
  end

  def gte(val)
    @tests << lambda { |field| field >= val }
    self
  end

  def lte(val)
    @tests << lambda { |field| field <= val }
    self
  end

  def int
    @tests << lambda { |field| field.to_i == field }
    self
  end

  def odd
    @tests << lambda { |field| field.to_i.odd? }
    self
  end

  def even
    @tests << lambda { |field| field.to_i.even? }
    self
  end

  def valid?
    ok = true
    @tests.each do |test|
      if !test.call @field
        ok = false
        break
      end
    end
    @errors[:field] = Error.new(ok)
  end

  def errors
    return @errors
  end

  def to_s
    "slug"
  end

end

describe Slug do

  before(:each) do
    @floor = 1
    @cieling = 100
    @slug = Slug.new
  end

  context "greater than" do
    subject { @slug.gt(@floor) }
    describe "just greater than" do
      it { should ensure_value_of(:field).is.greater_than(@floor) }
    end
    describe "an integer" do
      subject { @slug.gt(@floor).int }
      it { should ensure_value_of(:field).is.greater_than(@floor).and_is.an_integer }
    end
    describe "even" do
      subject { @slug.gt(@floor).even }
      it { should ensure_value_of(:field).is.greater_than(@floor).and_is.even }
    end
    describe "odd" do
      subject { @slug.gt(@floor).odd }
      it { should ensure_value_of(:field).is.greater_than(@floor).and_is.odd }
    end
    describe "lt" do
      subject { @slug.gt(@floor).lt(@cieling) }
      it { should ensure_value_of(:field).is.greater_than(@floor).and_is.less_than(@cieling) }
    end
    describe "lte" do
      subject { @slug.gt(@floor).lte(@cieling) }
      it { should ensure_value_of(:field).is.greater_than(@floor).and_is.less_than_or_equal_to(@cieling) }
    end
    describe "lt and odd" do
      subject { @slug.gt(@floor).lt(@cieling).odd }
      it { should ensure_value_of(:field).is.greater_than(@floor).and_is.less_than(@cieling).and_is.odd }
    end
    describe "lt and even" do
      subject { @slug.gt(@floor).lt(@cieling).even }
      it { should ensure_value_of(:field).is.greater_than(@floor).and_is.less_than(@cieling).and_is.even }
    end
    describe "lte and odd" do
      subject { @slug.gt(@floor).lte(@cieling).odd }
      it { should ensure_value_of(:field).is.greater_than(@floor).and_is.less_than_or_equal_to(@cieling-1).and_is.odd }
    end
    describe "lte and even" do
      subject { @slug.gt(@floor).lte(@cieling).even }
      it { should ensure_value_of(:field).is.greater_than(@floor).and_is.less_than_or_equal_to(@cieling).and_is.even }
    end
  end

  context "less than" do
    subject { @slug.lt(@cieling) }
    describe "just less than" do
      it { should ensure_value_of(:field).is.less_than(@cieling) }
    end
    describe "an integer" do
      subject { @slug.lt(@cieling).int }
      it { should ensure_value_of(:field).is.less_than(@cieling).and_is.an_integer }
    end
    describe "even" do
      subject { @slug.lt(@cieling).even }
      it { should ensure_value_of(:field).is.less_than(@cieling).and_is.even }
    end
    describe "odd" do
      subject { @slug.lt(@cieling).odd }
      it { should ensure_value_of(:field).is.less_than(@cieling).and_is.odd }
    end
    describe "gte and odd" do
      subject { @slug.gte(@floor).lt(@cieling).odd }
      it { should ensure_value_of(:field).is.greater_than_or_equal_to(@floor).and_is.less_than(@cieling).and_is.odd }
    end
    describe "gte and even" do
      subject { @slug.gte(@floor + 1).lt(@cieling).even }
      it { should ensure_value_of(:field).is.greater_than_or_equal_to(@floor + 1).and_is.less_than(@cieling).and_is.even }
    end
  end

  context "greater than or equal to" do
    subject { @slug.gte(@floor) }
    describe "just greater than or equal to" do
      it { should ensure_value_of(:field).is.greater_than_or_equal_to(@floor) }
    end
    describe "an integer" do
      subject { @slug.gte(@floor).int }
      it { should ensure_value_of(:field).is.greater_than_or_equal_to(@floor).and_is.an_integer }
    end
    describe "even" do
      subject { @slug.gte(@floor).even }
      it { should ensure_value_of(:field).is.greater_than_or_equal_to(@floor + 1).and_is.even }
    end
    describe "odd" do
      subject { @slug.gte(@floor).odd }
      it { should ensure_value_of(:field).is.greater_than_or_equal_to(@floor).and_is.odd }
    end
    describe "lte" do
      subject { @slug.gte(@floor).lte(@cieling) }
      it { should ensure_value_of(:field).is.greater_than_or_equal_to(@floor).and_is.less_than_or_equal_to(@cieling) }
    end
    describe "lte and odd" do
      subject { @slug.gte(@floor).lte(@cieling).odd }
      it { should ensure_value_of(:field).is.greater_than_or_equal_to(@floor).and_is.less_than_or_equal_to(@cieling-1).and_is.odd }
    end
    describe "lte and even" do
      subject { @slug.gte(@floor).lte(@cieling).even }
      it { should ensure_value_of(:field).is.greater_than_or_equal_to(@floor + 1).and_is.less_than_or_equal_to(@cieling).and_is.even }
    end
  end

  context "less than or equal to" do
    subject { @slug.lte(@cieling) }
    describe "just less than or equal to" do
      it { should ensure_value_of(:field).is.less_than_or_equal_to(@cieling) }
    end
    describe "an integer" do
      subject { @slug.lte(@cieling).int }
      it { should ensure_value_of(:field).is.less_than_or_equal_to(@cieling).and_is.an_integer }
    end
    describe "even" do
      subject { @slug.lte(@cieling).even }
      it { should ensure_value_of(:field).is.less_than_or_equal_to(@cieling).and_is.even }
    end
    describe "odd" do
      subject { @slug.lte(@cieling - 1).odd }
      it { should ensure_value_of(:field).is.less_than_or_equal_to(@cieling - 1).and_is.odd }
    end
    describe "gt" do
      subject { @slug.lte(@cieling).gt(@floor) }
      it { should ensure_value_of(:field).is.less_than_or_equal_to(@cieling).and_is.greater_than(@floor) }
    end
  end

  context "an integer" do
    subject { @slug.int }
    describe "just an integer" do
      it { should ensure_value_of(:field).is.an_integer }
    end
    describe "even" do
      subject { @slug.int.even }
      it { should ensure_value_of(:field).is.an_integer.and_is.even }
    end
    describe "odd" do
      subject { @slug.int.odd }
      it { should ensure_value_of(:field).is.an_integer.and_is.odd }
    end
  end

  context "even" do
    subject { @slug.even }
    describe "just even" do
      it {  should ensure_value_of(:field).is.even }
    end
  end

  context "odd" do
    subject { @slug.odd }
    describe "just odd" do
      it {  should ensure_value_of(:field).is.odd }
    end
  end

end
