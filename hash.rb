# Hashes student IDs
require_relative 'attendance-api'

file = 'data/attendancerecords_merged.csv'
output = 'data/attendancerecords_hashed.csv'
originalRecords = AttendanceFile.getRecords( file )

CSV.open( output, "w" ) do |csv|
  originalRecords.each do |record|
    csv << record.to_array_hashed
  end
end
