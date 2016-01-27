# LumPatternsWeb

A Phoenix web application to convert CSV files to LSE map files.

## CSV File Format


CSV files must have a first row that contains column headers.
 
There should be seven columns: *Node Name*, *Panel X*, *Panel Y*, *Install X*, *Install Y*, *Supply Number*, and *Port Number*.

The *Node Name* should be formatted to contain the per-string node number between a `:` and a `(`
  
>000822263822881/A-P71-100-150107 LP-ROUND-ASSY > Teamcenter Status:1(000822263822881.par)

### Sample CSV file:

	Name of Node,X-Coordinate within a panel,Y-Coordinate within a panel,X-Coordinate within the total installation,Y-Coordinate within the total installation,Supply Number,Port Number
	000822263822881/A-P71-100-150107 LP-ROUND-ASSY > Teamcenter Status:1(000822263822881.par),1287.5,27.5,10,10,1,1
	000822263822881/A-P71-100-150107 LP-ROUND-ASSY > Teamcenter Status:2(000822263822881.par),1227.5,27.5,10,20,1,1
	000822263822881/A-P71-100-150107 LP-ROUND-ASSY > Teamcenter Status:1(000822263822881.par),1167.5,27.5,20,10,1,2
	000822263822881/A-P71-100-150107 LP-ROUND-ASSY > Teamcenter Status:2(000822263822881.par),1107.5,27.5,20,20,1,2
	000822263822881/A-P71-100-150107 LP-ROUND-ASSY > Teamcenter Status:1(000822263822881.par),1047.5,27.5,30,10,2,1
	000822263822881/A-P71-100-150107 LP-ROUND-ASSY > Teamcenter Status:2(000822263822881.par),987.5,27.5,30,20,2,1
	000822263822881/A-P71-100-150107 LP-ROUND-ASSY > Teamcenter Status:1(000822263822881.par),867.5,27.5,40,10,2,2
	000822263822881/A-P71-100-150107 LP-ROUND-ASSY > Teamcenter Status:2(000822263822881.par),747.5,27.5,40,20,2,2

## Running

Clone the repository and run `mix deps.get`. The run `mix phoenix.server`.

## License

See the [LICENSE](LICENSE.md) file for license rights and limitations (MIT).
