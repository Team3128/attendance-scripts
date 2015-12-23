# Checks the integrity of the CSV file for possibly malfunctions and other
# possible problems that could cause bad data
require_relative 'attendance-api'

file = 'data/attendancerecords_merged.csv'
records = AttendanceFile.getRecords( file )

# Check the number of students not checked out
puts "Complete Records Statistics"
raw_counts = {
  :total => 0,
  :by_date => {},
  :by_student => {},
}

records.each do |record|
  record_date = Date.parse( record.time_in ).to_s
  record_id = record.student_id.to_i
  if raw_counts[:by_date][record_date] == nil
    raw_counts[:by_date][record_date] = 0
  end
  if raw_counts[:by_student][record_id] == nil
    raw_counts[:by_student][record_id] = 0
  end

  if record.is_complete_entry()
    raw_counts[:total] += 1
    raw_counts[:by_date][record_date] = raw_counts[:by_date][record_date] + 1
    raw_counts[:by_student][record_id] = raw_counts[:by_student][record_id] + 1
  end
end
percentage = raw_counts[:total].to_f / records.length.to_f * 100.00
puts "Analyzing #{records.length} check-ins"

counts = {
  :total => raw_counts[:total],
  :by_date => {},
  :by_student => {},
}

cleaned_dates = 0
raw_counts[:by_date].each do |date,value|
  if value == 0
    cleaned_dates = cleaned_dates + 1
    next
  end
  counts[:by_date][date] = value
end
puts "Removed #{cleaned_dates} meeting dates for no completed check-ins."

cleaned_students = 0
raw_counts[:by_student].each do |id,value|
  if value == 0
    cleaned_students = cleaned_students + 1
    next
  end
  counts[:by_student][id] = value
end
puts "Removed #{cleaned_students} students for no completed check-ins."

data_points = []
total = 0
counts[:by_date].each do |date,value|
  data_points.push( value )
  total = total + value
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
  data_points.push( value )
  total = total + value
end
data_points = data_points.sort
min, max = data_points[0], data_points[-1]
average = total / data_points.length
puts "Attendance by Student (for #{counts[:by_student].length} students):"
puts "Lowest Number of Check Ins: #{min}"
puts "Highest Number of Check Ins: #{max}"
puts "Average Number of Check Ins: #{average}"
