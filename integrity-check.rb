# Checks the integrity of the CSV file for possibly malfunctions and other
# possible problems that could cause bad data
require_relative 'attendance-api'

tests = {
  true => [],
  false => [],
}

file = 'data/attendancerecords_merged.csv'
control_records = AttendanceFile.getRecords( file )

control = AttendanceStats.new( control_records )
control_counts = control.get_overview_stats

variable_records = [];
control_records.each do |record|
  variable_records.push( record.to_hashed )
end
variable = AttendanceStats.new ( variable_records )
variable_counts = variable.get_overview_stats

# Check totals
tests[( variable_counts[:total] == control_counts[:total] )].push( 'Total counts match.')
tests[( variable_counts[:by_date].length == control_counts[:by_date].length )].push( 'Total dates match.')
tests[( variable_counts[:by_student].length == control_counts[:by_student].length )].push( 'Total students match.')

tests.each do |key, value|
  puts "-----#{key}-----"
  value.each do |message|
    puts message
  end
end
