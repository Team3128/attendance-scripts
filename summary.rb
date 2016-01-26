require_relative 'attendance-api'

file = ARGV.shift
output = '/Users/tylercarter/Repositories/attendance-scripts/data/output_summary.csv'
records = AttendanceFile.getRecords( file )

student_time = {}
records.each do |record|

  record_id = record.student_id
  if ! record.is_complete_entry
    next
  end

  if student_time[record_id] == nil
    student_time[record_id] = 0
  end

  student_time[record_id] = student_time[record_id].to_f + record.get_seconds
end

student_time.each do |key, value|
  student_time[key] = ( value / ( 60 * 60 ) ).round(2)
end

sorted = student_time.sort_by { |id, time| time }
sorted.each do |x|
  puts "ID: #{x[0]}; Time: #{x[1]}"
end

CSV.open( output, "w" ) do |csv|
  sorted.each do |values|
    csv << values
  end
end
