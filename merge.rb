# Checks the integrity of the CSV file for possibly malfunctions and other
# possible problems that could cause bad data
require_relative 'attendance-api'

file1 = ARGV[0]
file2 = ARGV[1]

if file1 == nil || file2 == nil
  abort( "Must provide an original file and merge file.")
end

output = '/Users/tylercarter/Repositories/attendance-scripts/data/output_merged.csv'
originalRecords = AttendanceFile.getRecords( file1 )
mergingRecords = AttendanceFile.getRecords( file2 )

# Create hash of students by date
attendance = {}
count = {
  :completed => 0,
  :incomplete => 0,
  :merged => 0,
  :duplicate => 0,
}

originalRecords.each do |record|
  if attendance[record.student_id] == nil
    attendance[record.student_id] = []
  end

  if record.is_complete_entry
    count[:completed] = count[:completed] + 1
  else
    count[:incomplete] = count[:incomplete] + 1
  end

  attendance[record.student_id].push( record.time_in )
end
original_students = attendance.length
puts "Completed/Incomplete/Total Entries: #{count[:completed]} / #{count[:incomplete]} / #{originalRecords.length}; Students: #{attendance.length}"

workingRecords = originalRecords.clone
mergingRecords.each do |record|

  # Check if student exists.
  if attendance[record.student_id] == nil

    # Student not found. Create student. Merge record.
    attendance[record.student_id] = []
    workingRecords.push( record )
    count[:merged] = count[:merged] + 1;
    if record.is_complete_entry
      count[:completed] = count[:completed] + 1
    else
      count[:incomplete] = count[:incomplete] + 1
    end

  # Student found. Check if time entry exists.
  elsif ! attendance[record.student_id].include? record.time_in

    # No time entry exists. Merge record.
    workingRecords.push( record )
    count[:merged] = count[:merged] + 1;
    if record.is_complete_entry
      count[:completed] = count[:completed] + 1
    else
      count[:incomplete] = count[:incomplete] + 1
    end

  else
    # Time entry found. Throw out as duplicate
    count[:duplicate] = count[:duplicate] + 1;
  end

end

puts "Merged/Duplicate/Total Entries: #{count[:merged]} / #{count[:duplicate]} / #{mergingRecords.length}; New Students: #{attendance.length - original_students}"

puts "Final Result: #{count[:completed]} Complete check-ins. #{count[:incomplete]} Incomplete checkins. #{workingRecords.length} Total checkins. Total Students: #{attendance.length}"

CSV.open( output, "w" ) do |csv|
  workingRecords.each do |record|
    csv << record.to_array
  end
end
