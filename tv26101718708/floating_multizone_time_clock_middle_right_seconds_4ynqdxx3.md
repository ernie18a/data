# Floating Multi-Zone Time Clock (Middle Right + Seconds)

- url: https://www.tradingview.com/script/4yNqDxx3-Floating-Multi-Zone-Time-Clock-Middle-Right-Seconds/
- type: indicator
- pine_id: PUB;3dbb30d1deb046978ab76db5e4b046d8
- version: 1.0

## Description

clock middle right of chart easy to see adjustable time zones , hour, minute , second helps keep focus in one area

## Source Code

````pine
//@version=5
indicator("Floating Multi-Zone Time Clock (Middle Right + Seconds)", overlay=true)

// Inputs
txtSize     = input.string("Normal", title="Text Size", options=["Small", "Normal", "Large"])
timeZoneOpt = input.string("America/Chicago", title="Clock Time Zone", 
               options=["America/Chicago", "America/New_York", "Europe/London", "Exchange", "UTC"])

// Visual Styling Inputs
bgChoice    = input.color(color.new(color.black, 30), title="Widget Background")
txtChoice   = input.color(color.green, title="Text Color")

// Map size inputs to internal text size constants
textSize = switch txtSize
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    => size.normal

// Create a 3-row vertical stack pinned to the right side of the screen
var table clockDashboard = table.new(position=position.middle_right, columns=1, rows=3, 
                                     border_color=color.new(color.white, 80), border_width=1)

// Force clock calculations to run natively inside the selected Time zone
var string tzString = timeZoneOpt == "Exchange" ? syminfo.timezone : timeZoneOpt

targetYear   = year(timenow, tzString)
targetMonth  = month(timenow, tzString)
targetDay    = dayofmonth(timenow, tzString)
targetHour   = hour(timenow, tzString)
targetMinute = minute(timenow, tzString)
targetSecond = second(timenow, tzString) // Added seconds extraction

// Pad numbers with leading zeros for standard digital clock formatting
strMonth  = targetMonth  < 10 ? "0" + str.tostring(targetMonth)  : str.tostring(targetMonth)
strDay    = targetDay    < 10 ? "0" + str.tostring(targetDay)    : str.tostring(targetDay)
strHour   = targetHour   < 10 ? "0" + str.tostring(targetHour)   : str.tostring(targetHour)
strMinute = targetMinute < 10 ? "0" + str.tostring(targetMinute) : str.tostring(targetMinute)
strSecond = targetSecond < 10 ? "0" + str.tostring(targetSecond) : str.tostring(targetSecond) // Added seconds padding

// Determine label prefix based on choice
zoneLabel = switch timeZoneOpt
    "America/Chicago"  => "CHI: "
    "America/New_York" => "EST: "
    "Europe/London"    => "LON: "
    "Exchange"         => "EXCH: "
    "UTC"              => "UTC: "
    => ""

// Assemble the final display strings with the new seconds variable
dateString = "Date: " + str.tostring(targetYear) + "-" + strMonth + "-" + strDay
timeString = zoneLabel + strHour + ":" + strMinute + ":" + strSecond
combinedDisplay = dateString + "\n" + timeString

// Only update the floating table on the very last live bar to optimize performance
if barstate.islast
    // Clear top and bottom rows to keep them blank and invisible
    table.cell(table_id=clockDashboard, column=0, row=0, text="", bgcolor=color.new(color.black, 100))
    table.cell(table_id=clockDashboard, column=0, row=2, text="", bgcolor=color.new(color.black, 100))
    
    // Render the clock cleanly in the center row with seconds included
    table.cell(table_id=clockDashboard, column=0, row=1, text=combinedDisplay, 
               text_color=txtChoice, text_size=textSize, bgcolor=bgChoice)
````
