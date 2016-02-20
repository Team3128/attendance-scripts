require_relative 'attendance-api'

HOURS_THRESHOLD = 1

file = ARGV.shift
output = '/Users/tylercarter/Repositories/attendance-scripts/data/output_days.csv'
records = AttendanceFile.getRecords( file )

date_start = ARGV.shift || nil
date_end = ARGV.shift || nil

dates = {}
records.each do |record|

  if ! record.is_complete_entry
    next
  end

  if date_start != nil && date_start != "0" && ! record.after_time( date_start )
    next
  end

  if date_end != nil && date_end != "0" && ! record.before_time( date_end )
    next
  end

  time_in = DateTime.strptime( record.time_in, '%Y-%m-%d %H:%M:%S' ).strftime("%Y-%m-%d")
  if dates.has_key?( time_in )
    dates[ time_in ].push( record.get_seconds )
  else
    dates[ time_in ] = [ record.get_seconds ]
  end

end

count_dates = {}
sum_dates = {}
dates.each do |date, checkins|
  count_dates[ date ] = checkins.length
  sum = 0
  checkins.each do |value|
    sum = sum + value
  end
  sum_dates[ date] = ( sum / ( 60 * 60 ) ).round(2)
end

headers = ["Date", "Count", "Total Hours", "Day of Week"]
CSV.open( output, "w" ) do |csv|
  csv << headers
  count_dates.each do |values|
    values.push( sum_dates[ values[0] ] )
    values.push( DateTime.strptime( values[0], '%Y-%m-%d' ).strftime("%A") )
    csv << values
  end
end
