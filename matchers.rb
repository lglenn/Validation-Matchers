module MyMatchers

  def ensure_value_of(attr)
    EnsureValueIsMatcher.new(attr)
  end

  def ensures_value_is(attr)
    ensure_value_is(attr)
  end

  class ImpossibleSpecificationError < Exception
  end

  class EnsureValueIsMatcher

    def initialize(attr)
      @attribute = attr
      @float = true
      @description = []
      @floor = 0
      @cieling = 100
      @even = @odd = false
      @lower_limit = @upper_limt = false
      @locked_floor = @locked_cieling = false
      @tests = []
    end

    def cieling
      @cieling
    end

    def cieling=(cieling)
      @cieling = cieling
      @locked_cieling = true
      @locked_floor || @floor = cieling - 100
    end

    def floor
      @floor
    end

    def floor=(floor)
      @floor = floor
      @locked_floor = true
      @locked_cieling || @cieling = @floor + 100
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
      self.floor = value
      @description << "equal to #{@floor}"
      @tests << lambda { @test = "equal_to"; allows_value_of(self.floor) && disallows_value_of(gt_floor) && disallows_value_of(self.floor - 1) }
      self
    end

    def odd
      @odd = true
      @description << "odd"
      @tests << lambda { @test = "is odd"; allows_value_of(odd_val) && disallows_value_of(even_val) }
      self
    end

    def even
      @even = true
      @description << "even"
      @tests << lambda { @test = "is even"; allows_value_of(even_val) && disallows_value_of(odd_val) }
      self
    end

    def greater_than(value)
      self.floor = value
      @lower_limit = true
      @description << "greater than #{@floor}"
      @tests << lambda { @test = "greater than"; disallows_value_of(self.floor) && allows_value_of(gt_floor) }
      self
    end

    def less_than(value)
      self.cieling = value
      @lower_limit = true
      @description << "less than #{cieling}"
      @tests << lambda { @test = "less than"; disallows_value_of(cieling) && allows_value_of(lt_cieling) }
      self
    end

    def greater_than_or_equal_to(value)
      self.floor = value
      @description << "greater than or equal to #{@floor}"
      @tests << lambda { @test = "greater than or equal to"; disallows_value_of(self.floor - 1) && allows_value_of(self.floor) && allows_value_of(gt_floor) }
      self
    end

    def less_than_or_equal_to(value)
      self.cieling = value
      @description << "less than or equal to #{self.cieling}"
      @tests << lambda { @test = "less than or equal to"; disallows_value_of(self.cieling + 1) && allows_value_of(self.cieling) && allows_value_of(lt_cieling) }
      self
    end

    def an_integer
      @float = false
      @description << "an integer"
      @tests << lambda { @test = "an integer"; disallows_value_of(int_val + 0.001) && allows_value_of(int_val) }
      self
    end

    def description
      "ensure that value of #{@attribute} is #{@description.join(" and is ")}"
    end

    def failure_message
      "Failed test '#{@attribute} #{@test}' because #{@subject} #{@failed_because} for it."
    end

    def matches?(subject)
      @subject = subject
      @tests.each do |test|
        return false if !test.call
      end
      return true
    end

    private

    def odd_val
      odd = an_int
      if odd % 2 == 0
        odd -= 1
      end
      odd
    end

    def even_val
      even = an_int
      if even % 2 == 1
        even -= 1
      end
      even
    end

    def an_int
      self.cieling.to_i
    end

    def int_val
      ret = nil
      if @even
        ret = even
      elsif @odd
        ret = odd
      else
        ret = an_int
      end
      return ret
    end

    def gt_floor
      @integer ? self.floor + 1 : (self.cieling + self.floor) / 2.0
    end

    def lt_cieling
      @integer ? self.cieling - 1 : (self.cieling + self.floor) / 2.0
    end

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
