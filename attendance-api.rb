require 'csv'

class AttendanceFile
  def self.getRecords( file )
    records = []
    CSV.foreach( file ) do |row|
      record = AttendanceRecord.new( row[0], row[1], row[2] );
      records.push( record )
    end
    return records
  end
end

class AttendanceRecord
  attr_reader :student_id, :time_in, :time_out

  def initialize( student_id, time_in, time_out = nil )
    @student_id, @time_in, @time_out = student_id, time_in, time_out
  end

  def is_complete_entry()
    if @time_in != nil && @time_out != nil
      return true
    else
      return false
    end
  end

  def to_array()
    return [ @student_id, @time_in, @time_out ]
  end
end
