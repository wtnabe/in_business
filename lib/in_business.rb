require 'ostruct'
require 'active_support'
require 'active_support/core_ext'
require 'active_support/concern'

module InBusiness
  extend ActiveSupport::Concern

  included do
    include InstanceMethods
  end

  module InstanceMethods
    def holidays
      @holidays ||= []
    end

    def holidays=(array)
      @holidays = array
    end

    def hours
      @hours ||= OpenStruct.new
    end

    def hours=(hash)
      @hours = OpenStruct.new(hash)
    end

    def reset
      # Used for clearing the state of InBusiness between specs
      self.holidays = []
      self.hours = {}
      true
    end

    def open?(datetime=DateTime.now)
      
      # If this is included in the list of holidays, return false
      return false if is_holiday? datetime

      # If we don't know the opening hours for datetime's day, assume we're closed
      hours_ranges = hours.send(days[datetime.wday.to_s].to_sym)
      return false unless hours_ranges

      # We have opening hours, so check if the current time is within them
      hours_ranges = [hours_ranges] unless hours_ranges.is_a? Array
      hours_ranges.any? {|hours| hours.cover? datetime.strftime("%H:%M")}
    end

    def closed?(datetime=DateTime.now)
      !open?(datetime)
    end

    def is_holiday?(date=DateTime.now)
      holidays.include? date.to_date
    end

    # Maps values of [DateTime/Date/Time]#wday to English days
    def days
      {
        "0" => "sunday",
        "1" => "monday",
        "2" => "tuesday",
        "3" => "wednesday",
        "4" => "thursday",
        "5" => "friday",
        "6" => "saturday"
      }
    end
  end

  # Extend so one can use InBusiness as a singleton module
  extend InstanceMethods
end
