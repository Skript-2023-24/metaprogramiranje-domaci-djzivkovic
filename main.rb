require "google_drive"
require "./table.rb"

session = GoogleDrive::Session.from_config("config.json")

spreadsheet = session.spreadsheet_by_key("1c_fbM_zPugumYsV4Omyu5f9QcpKn46gu-5gG9DfPNVk")

t1 = Table.new(spreadsheet.worksheets[0])

p t1.row(0)

t1.each do |cell|
    p cell
end

p t1["treca kolona"][2]
t1["treca kolona"][2] = 221
p t1["treca kolona"][2]

p t1.values

p t1["treca kolona"].values
p t1.trecaKolona.values

p t1.trecaKolona.sum
p t1.trecaKolona.avg

mapped = t1.trecaKolona.map do |cell|
    cell.to_s + "!"
end

p mapped

selected = t1.trecaKolona.select do |cell|
    cell.to_f > 10
end

p selected

sum = t1.trecaKolona.reduce(0) do |acc, cell|
    acc + cell.to_f
end

p sum

concat = t1.trecaKolona.reduce("", :+)

p concat

p t1.drugaKolona.teest
