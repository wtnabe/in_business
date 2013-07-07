require 'ostruct'
require 'active_support/core_ext'

module InBusiness

  @holidays = []
  @hours = OpenStruct.new
  
  def self.holidays
    @holidays
  end

  def self.hours
    @hours
  end

  def self.open?(datetime)
    
    # If this is included in the list of holidays, return false
    return false if is_holiday? datetime

    # If we don't know the opening hours for datetime's day, assume we're closed
    return false unless hours.send(days[datetime.wday.to_s].to_sym)

    # We have opening hours, so check if the current time is within them
    if !hours.send(days[datetime.wday.to_s].to_sym).include? datetime.strftime("%H:%M")
      return false
    end

    true # It's not not open, so it must be open ;)
  end

  def self.closed?(datetime)
    !open?(datetime)
  end

  def self.is_holiday?(date)
    @holidays.include? date.to_date
  end

  # Maps values of [DateTime/Date/Time]#wday to English days
  def self.days
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