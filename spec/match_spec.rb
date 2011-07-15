require 'rspec'
require 'matchers.rb'

RSpec.configure do |config|
  config.include MyMatchers
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

  def initialize(test)
    @test = test
    @errors = { }
  end

  def field
    return @field
  end

  def field=(val)
      @field = val
  end

  def valid?
    ret = @test.call @field
    @errors[:field] = Error.new(ret)
  end

  def errors
    return @errors
  end

end

describe Slug do

  context "test: field is greater than 1" do
    subject { Slug.new(lambda { |field| field > 1 }) }
    describe "field must be gt 1" do
      it { should ensure_value_of(:field).is.greater_than(1) }
    end
  end

  context "test: field is greater than or equal to 1" do
    subject { Slug.new(lambda { |field| field >= 1 }) }
    describe "field must be gt 1" do
      it { should ensure_value_of(:field).is.greater_than_or_equal_to(1) }
    end
  end

  context "test: field is an integer" do
    subject { Slug.new(lambda { |field| field == field.to_i }) }
    describe "field must be an integer" do
      it { should ensure_value_of(:field).is.an_integer }
    end
  end

  context "test: field is equal to 5" do
    subject { Slug.new(lambda { |field| field == 5 }) }
    describe "field must equal 5" do
      it { should ensure_value_of(:field).is.equal_to(5) }
    end
  end

  context "test: field is an integer greater than or equal to 1" do
    subject { Slug.new(lambda { |field| (field >= 1) && (field.to_i == field)}) }
    describe "field must be gt 1" do
      it { should ensure_value_of(:field).is.an_integer.and_is.greater_than_or_equal_to(1) }
    end
  end

end
