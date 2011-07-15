module MyMatchers

  def ensure_value_of(attr)
    EnsureValueIsMatcher.new(attr)
  end

  def ensures_value_is(attr)
    ensure_value_is(attr)
  end

  class EnsureValueIsMatcher

    def initialize(attr)
      @attribute = attr
      @float = true
      @description = []
      @floor = 0
      @cieling = 100
      @lower_limit = @upper_limt = false
      @tests = []
    end

    def with_message(message)
      if message
        @message = message
      end
      self
    end

    def is
      self
    end

    def and_is
      self
    end

    def equal_to(value)
      @floor = value
      @description << "equal to #{@floor}"
      @tests << lambda {  allows_value_of(@floor) && disallows_value_of(@floor + 1) && disallows_value_of(@floor - 1) }
      self
    end

    def greater_than(value)
      @floor = value
      @lower_limit = true
      @description << "greater than #{@floor}"
      @tests << lambda { disallows_value_of(@floor) && allows_value_of(@floor + 1) }
      self
    end

    def greater_than_or_equal_to(value)
      @floor = value
      @description << "greater than or equal to #{@floor}"
      @tests << lambda { disallows_value_of(@floor - 1) && allows_value_of(@floor) && allows_value_of(@floor + 1) }
      self
    end

    def an_integer
      @float = false
      @description << "an integer"
      @tests << lambda { disallows_value_of(@floor + 0.1) && allows_value_of(((@floor + @cieling)/2).to_i) }
      self
    end

    def description
      "ensure that value of #{@attribute} is #{@description.join(" and is ")}"
    end

    def failure_message
      "Failed because #{@subject} #{@failed_because} for #{@attribute}"
    end

    def matches?(subject)
      @subject = subject
      @tests.each do |test|
        return false if !test.call
      end
      return true
    end

    private

    def allows_value_of(value)
      @failed_because = "did not allow a value of #{value}"
      @subject.send("#{@attribute}=",value)
      @subject.valid?
      @subject.errors[@attribute].blank?
    end

    def disallows_value_of(value)
      @failed_because = "allowed a value of #{value}"
      @subject.send("#{@attribute}=",value)
      @subject.valid?
      not @subject.errors[@attribute].blank?
    end

  end

end
