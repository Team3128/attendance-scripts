# Hashes student IDs
require_relative 'attendance-api'

file = 'data/attendancerecords_merged.csv'
output = 'data/attendancerecords_hashed.csv'
original_records = AttendanceFile.getRecords( file )
new_records = []

# Write new file with hashed student IDs
CSV.open( output, "w" ) do |csv|
  original_records.each do |record|
    new_record = record.to_hashed
    new_records.push( new_record )
    csv << new_record.to_array
  end
end

tests = {
  true => [],
  false => [],
}

# Control Stats
control = AttendanceStats.new( original_records )
control_counts = control.get_overview_stats

# Variable Stats
variable = AttendanceStats.new( new_records )
variable_counts = variable.get_overview_stats

# Check totals
tests[( variable_counts[:total] == control_counts[:total] )].push( 'Total number of check-ins match.')
tests[( variable_counts[:by_date].length == control_counts[:by_date].length )].push( 'Total number of dates match.')
tests[( variable_counts[:by_student].length == control_counts[:by_student].length )].push( 'Total number of students match.')

# Check if students have the same number of completed entries.
control_student_completed = []
control_counts[:by_student].each do |key,value|
  control_student_completed.push value[:completed]
end
variable_student_completed = []
variable_counts[:by_student].each do |key,value|
  variable_student_completed.push value[:completed]
end

control_student_completed.sort
variable_student_completed.sort
tests[( control_student_completed == variable_student_completed )].push( 'Students have the same number of completed entries.')

if tests[false].length > 0
  puts "Hashing unsuccessful. Some tests failed."
  tests.each do |key, value|
    puts "-----#{key}-----"
    value.each do |message|
      puts message
    end
  end
else
  puts "Hashing successful. All tests passed."
end
