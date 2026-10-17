# CDT Clock + Trade Timer

- url: https://www.tradingview.com/script/tDa7NdgG-CDT-Clock-Trade-Timer/
- type: indicator
- pine_id: PUB;52ec7682743a41afae6ee1ae3ba448ef
- version: 1.0

## Description

To keep it organized in your TradingView library, you’ll want a description that reminds you exactly how the logic works (especially the CDT offset and the manual timer).

Here is a concise description you can paste into the "Description" field when you save the script:

NQ Execution Clock & Patience Timer (CDT)
Overview:
A specialized execution tool designed for NQ/ES futures trading. This indicator provides a high-visibility digital clock synced to Central Daylight Time (CDT) and a manual "Trade Timer" to help manage trade duration and psychology during liquidity sweeps.

Key Features:

Live CDT Clock: Hardcoded to UTC-5 to stay synced with Chicago/San Antonio market hours.

Manual Trade Stopwatch: A "Start Trade Timer" toggle in the settings allows you to track exactly how many minutes/seconds you have been in a position.

Psychology Support: Specifically built to prevent early exits by providing a visual counter for the "10-minute rule" during NQ runs.

Customizable UI: Options to reposition the clock (Top Right, Bottom Left, etc.) and adjust font size/color to fit any chart layout.

Instructions:

Check "START TRADE TIMER" in the inputs as soon as your limit order is filled.

Uncheck to reset once the trade is closed.

## Source Code

````pine
//@version=6
indicator("CDT Clock + Trade Timer", shorttitle="Trade Timer", overlay=true)

// --- INPUTS ---
i_position = input.string("Top Right", "Location", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Top Center", "Bottom Center"])
i_tradeActive = input.bool(false, "START TRADE TIMER")
i_textColor  = input.color(color.white, "Text Color")
i_bgColor    = input.color(color.new(color.black, 30), "Background Color")
i_fontSize   = input.string("Large", "Size", options=["Tiny", "Small", "Normal", "Large", "Huge"])

// --- TIME LOGIC ---
// CDT Clock (UTC-5)
currentClockTime = str.format_time(timenow, "hh:mm:ss a", "UTC-5")

// Trade Timer Logic
var int startTime = 0

if i_tradeActive and not i_tradeActive[1]
    startTime := timenow

if not i_tradeActive
    startTime := 0

// Calculate elapsed time
elapsedMs = startTime > 0 ? timenow - startTime : 0
elapsedMin = math.floor(elapsedMs / 60000)
elapsedSec = math.floor((elapsedMs % 60000) / 1000)

// Format the Timer string
timerDisplay = i_tradeActive ? " | Timer: " + str.format("{0,number,00}:{1,number,00}", elapsedMin, elapsedSec) : ""

// --- HELPER FUNCTIONS ---
get_location(pos) =>
    switch pos
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Top Center"    => position.top_center
        "Bottom Center" => position.bottom_center
        => position.top_right

get_size(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.large

// --- DISPLAY ---
var table clockTable = table.new(get_location(i_position), 1, 1)

if barstate.islast
    fullDisplay = currentClockTime + timerDisplay
    
    // Update table location if changed
    table.delete(clockTable)
    clockTable := table.new(get_location(i_position), 1, 1)
    
    table.cell(clockTable, 0, 0, fullDisplay, 
         text_color=i_textColor, 
         bgcolor=i_bgColor, 
         text_size=get_size(i_fontSize))
````
