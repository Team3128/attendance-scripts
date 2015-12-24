# Hashes student IDs
require_relative 'attendance-api'

file = 'data/attendancerecords_merged.csv'
output = 'data/attendancerecords_hashed.csv'
originalRecords = AttendanceFile.getRecords( file )

# Write new file with hashed student IDs
CSV.open( output, "w" ) do |csv|
  originalRecords.each do |record|
    csv << record.to_array_hashed
  end
end

originalStats = AttendanceStats.new( originalRecords )
originalStats.count_records
newStats = AttendanceStats.new( AttendanceFile.getRecords( output ) )
newStats.count_records

if originalStats.stats[:total] != newStats.stats[:total]
  puts "Collision detected: Analyzing new file results in different stats."
end
