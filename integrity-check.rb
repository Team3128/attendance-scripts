# Checks the integrity of the CSV file for possibly malfunctions and other
# possible problems that could cause bad data
require_relative 'attendance-api'

file = 'data/attendancerecords_hashed.csv'
records = AttendanceFile.getRecords( file )

stats = AttendanceStats.new( records )
counts = stats.count_records

puts "Removed #{counts[:empty][:by_student].length} students for no completed check-ins."
puts "Removed #{counts[:empty][:by_date].length} dates for no completed check-ins."

data_points = []
total = 0
counts[:by_date].each do |date,value|
  data_points.push( value[:completed] )
  total = total + value[:completed]
end
data_points = data_points.sort
min, max = data_points[0], data_points[-1]
average = total / data_points.length
puts "Attendance by Day (for #{counts[:by_date].length} days):"
puts "Lowest Number of Check Ins: #{min}"
puts "Highest Number of Check Ins: #{max}"
puts "Average Number of Check Ins: #{average}"

data_points = []
total = 0
counts[:by_student].each do |date,value|
  data_points.push( value[:completed] )
  total = total + value[:completed]
end
data_points = data_points.sort
min, max = data_points[0], data_points[-1]
average = total / data_points.length
puts "Attendance by Student (for #{counts[:by_student].length} students):"
puts "Lowest Number of Check Ins: #{min}"
puts "Highest Number of Check Ins: #{max}"
puts "Average Number of Check Ins: #{average}"
