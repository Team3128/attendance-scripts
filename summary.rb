require_relative 'attendance-api'

file = ARGV.shift
output = '/Users/tylercarter/Repositories/attendance-scripts/data/output_summary.csv'
records = AttendanceFile.getRecords( file )

date_start = ARGV.shift || nil
date_end = ARGV.shift || nil

student_time = {}
records.each do |record|

  record_id = record.student_id
  if ! record.is_complete_entry
    next
  end

  if student_time[record_id] == nil
    student_time[record_id] = 0
  end

  if date_start != nil && ! record.after_time( date_start )
    next
  end

  if date_end != nil && ! record.before_time( date_end )
    next
  end

  student_time[record_id] = student_time[record_id].to_f + record.get_seconds
end

student_time.each do |key, value|
  student_time[key] = ( value / ( 60 * 60 ) ).round(2)
end

sorted = student_time.sort_by { |id, time| time }
CSV.open( output, "w" ) do |csv|
  sorted.each do |values|
    csv << values
  end
end
