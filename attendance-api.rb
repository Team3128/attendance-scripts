require 'csv'
require 'digest'
require 'date'

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

  def get_seconds()
    if ! is_complete_entry
      return 0
    else
      return ( ( DateTime.parse( @time_out ) - DateTime.parse( @time_in ) ) * 24 * 60 * 60 ).to_i
    end
  end

  def is_complete_entry()
    if @time_in != nil && @time_out != nil
      return true
    else
      return false
    end
  end

  def before_time ( time )
    if time > @time_in
      return true
    else
      return false
    end
  end

  def after_time ( time )
    if time < @time_in
      return true
    else
      return false
    end
  end

  def to_array()
    return [ @student_id, @time_in, @time_out ]
  end

  def to_hashed( shorten_length = 4, hash = false )

    identifier = @student_id
    if shorten_length != false
      identifier = identifier.split(//).last( shorten_length ).join
    end

    if hash == true
      identifier = Digest::SHA256.hexdigest( identifier )[0...10]
    end

    return AttendanceRecord.new( identifier, @time_in, @time_out )
  end

  def get_time_id
    return time_id = "#{@time_in}/#{@time_out}"
  end

end

class AttendanceStats

  def initialize( records )
    @records = records
  end

  def get_overview_stats ()

    counts = {
      :total => {
        :completed => 0,
        :incomplete => 0,
      },
      :by_date => {},
      :by_student => {},
      :empty => {
        :by_date => [],
        :by_student => [],
      }
    }

    @records.each do |record|

      # Normalize data
      record_date = Date.parse( record.time_in ).to_s
      record_id = record.student_id

      # Record completed entry
      if record.is_complete_entry()
        type = :completed
      else
        type = :incomplete
      end

      if counts[:by_date][record_date] == nil
        counts[:by_date][record_date] = {
          :completed => 0,
          :incomplete => 0,
        }
      end
      if counts[:by_student][record_id] == nil
        counts[:by_student][record_id] = {
          :completed => 0,
          :incomplete => 0,
        }
      end

      counts[:total][type] = 1 + counts[:total][type]
      counts[:by_date][record_date][type] = counts[:by_date][record_date][type] + 1
      counts[:by_student][record_id][type] = counts[:by_student][record_id][type] + 1
    end

    counts[:by_date].each do | record_date, values |
      if values[:completed] == 0
        counts[:by_date].delete record_date
        counts[:empty][:by_date].push( record_date )
      end
    end
    counts[:by_student].each do | record_id, values |
      if values[:completed] == 0
        counts[:by_student].delete record_id
        counts[:empty][:by_student].push( record_id )
      end
    end

    return counts
  end

end
