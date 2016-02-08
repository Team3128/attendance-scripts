require_relative 'attendance-api'

HOURS_THRESHOLD = 1

file = ARGV.shift
output = '/Users/tylercarter/Repositories/attendance-scripts/data/output_summary.csv'
records = AttendanceFile.getRecords( file )

date_start = ARGV.shift || nil
date_end = ARGV.shift || nil

name_map = ARGV.shift || nil

total_seconds = 0
unlisted = 0
student_time = {}
records.each do |record|

  record_id = record.student_id
  if ! record.is_complete_entry
    next
  end

  if student_time[record_id] == nil
    student_time[record_id] = 0
  end

  if date_start != nil && date_start != "0" && ! record.after_time( date_start )
    next
  end

  if date_end != nil && date_end != "0" && ! record.before_time( date_end )
    next
  end

  student_time[record_id] = student_time[record_id].to_f + record.get_seconds
  total_seconds = total_seconds + record.get_seconds
end

names = {}
if name_map != nil
  CSV.foreach( name_map ) do |row|
    names[row[0]] = row[1]
  end
end

results = {}
student_time.each do |key, value|
  result = ( value / ( 60 * 60 ) ).round(2)
  if result < HOURS_THRESHOLD
    unlisted = unlisted + result
    next
  end
  results[key] = result
end

if unlisted != 0
  results["<Unlisted>"] = unlisted
end

headers = ["Student ID", "Hours"]
if name_map != nil
  headers.push("Name")
end
sorted = results.sort_by { |id, time| time }
CSV.open( output, "w" ) do |csv|
  csv << headers
  sorted.each do |values|
    if name_map != nil
      values.push( names["#{values[0]}"] )
    end
    csv << values
  end

  total_hours = ( total_seconds / ( 60 * 60 ) ).round(2)
  csv << ["<Total Hours>", total_hours]
end
