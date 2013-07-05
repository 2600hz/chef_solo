#!/usr/bin/env ruby

### grabs the list of currently connected FreeSWITCH nodes
fs_connected=`sudo /opt/kazoo/utils/sup/sup -n ecallmgr ecallmgr_maintenance list_fs_nodes | cut -d"[" -f2 | cut -d"]" -f1 | sed -e "s/'//g"`.split(',')

### grabs the list of FreeSWITCH nodes from the DataBase
fs_db=`sudo /opt/kazoo/utils/sup/sup -n ecallmgr ecallmgr_config get fs_nodes | cut -d"[" -f2 | cut -d"]" -f1 | sed -e 's/<<"//g' | sed -e 's/">>//g'`.split(',')

### recreating the arrays and removing the newline characters
fs_connected.map!{|c| c.chomp }
fs_db.map!{|c| c.chomp }

### compare the 2 arrays for missing whapps
diff = ( fs_connected - fs_db ) | ( fs_db - fs_connected )

if diff.empty?
  puts "OK - all FreeSWITCH nodes are currently connected to ecallmgr"
  exit 0
elsif fs_connected.count == 0
  puts "None of the FreeSWITCH nodes are connected to ecallmgr!"
  exit 2
elsif diff
  diff.each do |x|
  puts "#{x} is not connected..."
  end
  exit 1
end
