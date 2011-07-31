module ValidationMatchers

  def ensure_value_of(attr)
    EnsureValueIsMatcher.new(attr)
  end

  class EnsureValueIsMatcher

    def initialize(attr)
      @attribute = attr
      @float = true
      @floor = 0
      @cieling = 100
      @even = @odd = false
      @upper_limit = @lower_limit = false
      @locked_floor = @locked_cieling = false
      @tests = {}
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

    def odd?
      @odd
    end

    def odd=(odd)
      @odd = odd
      if @odd
        @float = false
        align_boundary_parity
      end
    end

    def align_boundary_parity
      if !@locked_floor && !parity_match?(self.floor)
        self.floor += 1
      end
      if !@locked_cieling && !parity_match?(self.cieling)
        self.cieling -= 1
      end
    end

    def even?
      @even
    end

    def even=(even)
      @even = even
      if @even
        @float = false
        align_boundary_parity
      end
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
      test "is equal to #{@floor}" do
        allows_value_of(self.floor) && disallows_value_of(gt_floor) && disallows_value_of(lt_floor)
      end
      self
    end

    def odd
      self.odd = true
      test "is odd" do
        allows_value_of(odd_val) && disallows_value_of(even_val)
      end
      self
    end

    def even
      self.even = true
      test "is even" do
        allows_value_of(even_val) && disallows_value_of(odd_val)
      end
      self
    end

    def greater_than(value)
      self.floor = value
      @lower_limit = true
      test "greater than #{@floor}" do
        disallows_value_of(self.floor) && allows_value_of(gt_floor)
      end
      self
    end

    def less_than(value)
      self.cieling = value
      @upper_limit = true
      test "less than #{cieling}" do
        disallows_value_of(cieling) && allows_value_of(lt_cieling)
      end
      self
    end

    def greater_than_or_equal_to(value)
      self.floor = value
      test "greater than or equal to #{@floor}" do
        disallows_value_of(lt_floor) && allows_value_of(self.floor) && allows_value_of(gt_floor)
      end
      self
    end

    def less_than_or_equal_to(value)
      self.cieling = value
      test "less than or equal to #{self.cieling}" do
        disallows_value_of(gt_cieling) && allows_value_of(self.cieling) && allows_value_of(lt_cieling)
      end
      self
    end

    def an_integer
      @float = false
      test "an integer" do
        disallows_value_of(int_val + 0.001) && allows_value_of(int_val)
      end
      self
    end

    def description
      "ensure that value of #{@attribute} is #{@tests.keys.join(" and is ")}"
    end

    def failure_message
      "Failed test '#{@attribute} #{@test}' because #{@subject} #{@failed_because} for it."
    end

    def matches?(subject)
      @subject = subject
      @tests.each do |description, test|
        if !test.call
          @test = description
          return false
        end
      end
      return true
    end

    private

    def test(description,&test)
      @tests[description] = test
    end

    def odd_val
      an_int.odd? ? an_int : an_int - 1
    end

    def even_val
      an_int.even? ? an_int : an_int - 1
    end

    def an_int
      @upper_limit ? self.cieling.to_i - 1 : self.cieling.to_i
    end

    def int_val
      if @even
        even_val
      elsif @odd
        odd_val
      else
        an_int
      end
    end

    def an_atom
      @float ? 0.00001 : 1
    end

    def parity_match?(i)
      @float || ((even? && i.even?) || (odd? && i.odd?))
    end

    def gt(val)
      ret = val + an_atom
      ret += 1 unless parity_match?(ret)
      return ret
    end

    def lt(val)
      ret = val - an_atom
      ret -= 1 unless parity_match?(ret)
      return ret
    end

    def gt_floor
      gt self.floor
    end

    def lt_floor
      lt self.floor
    end

    def gt_cieling
      gt self.cieling
    end

    def lt_cieling
      lt self.cieling
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
