require "google_drive"

class Column
    attr_accessor :values
    def initialize(column_index, values, table_ref)
        @column_index = column_index
        @values = values
        @table_ref = table_ref
    end
  
    def [](index)
        @values[index]
    end
  
    def []=(index, value)
        @table_ref[index, @column_index] = value
    end

    def each
        @values.each { |row| row.each { |col| yield col } }
    end

    def sum()
        @values.map(&:to_f).reduce(:+)
    end

    def avg()
        sum / @values.size
    end

    def map()
        @values.map { |el| yield el }
    end

    def select()
        @values.select { |el| yield el }
    end

    def reduce(initial = 0, op = nil)
        block_given? ? @values.reduce(initial) { |acc, el| yield acc, el } : @values.reduce(initial, op)
    end

    def method_missing(name)
        row_index = @values.index(name.to_s)
        return nil if row_index.nil?
        @table_ref.row(row_index)
    end

end

class Table
    attr_accessor :headers
    def initialize(ws)
        @ws = ws
        clean_rows
        @headers = row(-1)
        @table_offset = get_table_offset
        @headers = row(-1) # remove empty columns from headers
        define_header_methods
    end

    def values()
        matrix = (2..@ws.num_rows).map { |row| (@table_offset || 1..@ws.num_cols).map { |col| @ws[row, col] } }
    end

    def clean_rows()
        rows = @ws.rows
        rows_to_delete_indices = rows.each_index.select do |i| 
            rows[i].all?(&:empty?) || rows[i].any? { |cell| cell.downcase =~ /total|subtotal/i }
        end
        offset = 0 # offset because rows get shifted when deleting
        rows_to_delete_indices.each do |original_index|
            @ws.delete_rows(original_index + 1 - offset, 1)
            offset += 1
        end
    end

    def get_table_offset
        @ws.rows[0].index { |cell| !cell.empty? } + 1 || @ws.num_cols
    end
    
    def row(index)
        (@table_offset || 1..@ws.num_cols).map { |col| @ws[index + 2, col] }
    end

    def each
        values.each { |row| row.each { |col| yield col } }
    end

    def [](column_name)
        column_index = @table_offset + @headers.index(column_name)
        array = (2..@ws.num_rows).map { |row| @ws[row, column_index] }
        Column.new(column_index, array, self)
    end
    
    def []=(row, column_index, value)
        @ws[row + 2, column_index] = value
    end

    def define_header_methods() 
        @headers.each_with_index do |header, col|
            method_name = header.split(' ').map.with_index { |word, i| i.zero? ? word : word.capitalize }.join
            self.class.send(:define_method, method_name) do
                self[header]
            end
        end
    end
end