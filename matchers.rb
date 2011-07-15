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
      @locked_floor = @locked_cieling = false
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
      @tests << lambda {
        i = @floor
        if @floor % 2 == 1
          i = @floor + 1
        end
        allows_value_of(@floor) && disallows_value_of(@floor + 1) && disallows_value_of(@floor - 1) }
      self
    end

    def odd
      @description << "odd"
      @tests << lambda {
        odd = @floor.to_i
        if odd % 2 == 0
          odd += 1
        end
        if !fits_under(odd)
          return false
        end
        even = fits_under(odd + 1) ? odd + 1 : nil
        allows_value_of(odd) && (!even || disallows_value_of(even))
      }
      self
    end

    def even
      @description << "even"
      @tests << lambda {
        even = @floor.to_i
        if even % 2 == 1
          even += 1
        end
        if !fits_under(even)
          return false
        end
        odd = fits_under(even + 1) ? even + 1 : nil
        allows_value_of(even) && (!odd || disallows_value_of(odd))
      }
      self
    end

    def greater_than(value)
      @floor = value
      @locked_floor = true
      @lower_limit = true
      @description << "greater than #{@floor}"
      @tests << lambda { disallows_value_of(@floor) && allows_value_of(@floor + 1) }
      self
    end

    def greater_than_or_equal_to(value)
      @floor = value
      @locked_floor = true
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

    def fits_under(val)
      if (val > @cieling) && @locked_cieling
        return false
      elsif (val == @cieling) && @upper_limit
        return false
      end
      return true
    end

  end

end
