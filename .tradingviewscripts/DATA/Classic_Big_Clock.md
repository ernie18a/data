<!-- tradingview-pine-id: PUB;9a37886160754085ad2a967612d57333 -->
<!-- tradingviewscripts-format: 1 -->
# Classic Big Clock

Source: https://www.tradingview.com/script/D2t9Bey1-Classic-Big-Clock/

## Description

Classic Big Clock [Multi-Timezone]

Overview
Classic Big Clock is a clean, highly visual, and fully customizable dynamic clock overlay designed for traders who need precise time tracking across different global sessions directly on their chart.

Whether you trade forex sessions, market opens/closes, or specific economic news events, having the exact local or target timezone time immediately visible helps you stay synchronized with the markets without leaving your TradingView interface.

Key Features
Complete UTC Timezone Coverage: Easily switch between Exchange time, UTC, or any global offset from UTC-12 to UTC+14 (including non-standard offsets like UTC+5:30 IST).

High-Visibility & Dynamic Sizing: Choose between multiple display sizes (Huge, Large, Normal, Small).

Enhanced Visual Frame: Includes an option to expand the cell frame padding to make the Huge display stand out even more on high-resolution screens.

Fully Customizable Appearance: Adjust table position (any corner), background color/opacity, text color, border color, and border thickness to match your personal chart layout or theme.

Lightweight & Efficient: Built on Pine Script v6 using real-time execution (barstate.islast), ensuring fast chart rendering without performance lag.

How to Use
Position: Select where the clock appears on your screen (Top Right, Top Left, Bottom Right, Bottom Left).

Clock Size: Pick the text size that best fits your screen layout.

Enlarge Cell Frame: Toggle this setting on when using Huge mode to give the clock extra visual weight and padding.

Timezone: Select Exchange to stick with the symbol's native time, or choose your desired UTC offset from the list (e.g., UTC-5 for New York, UTC+1 for Europe/CET, UTC+9 for Tokyo/JST) to track global trading hubs.

---

## Source Code

````pine
//@version=6
indicator("Classic Big Clock", overlay=true)

// --- USER INPUTS ---
string posInput        = input.string("Top Right", title="Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group="Appearance")
string sizeInput       = input.string("Huge", title="Clock Size", options=["Huge", "Large", "Normal", "Small"], group="Appearance")
bool   extraPadding    = input.bool(true, title="Enlarge Cell Frame (Make Huge Bigger)", group="Appearance")

color  textColorInput  = input.color(color.rgb(248, 252, 4), title="Text Color", group="Appearance")
color  bgColorInput    = input.color(color.new(color.black, 40), title="Background Color", group="Appearance")
color  frameColorInput = input.color(color.gray, title="Border Color", group="Appearance")
int    frameWidthInput = input.int(2, title="Border Width (px)", minval=0, maxval=10, group="Appearance")

// Complete UTC Timezone Selection
string tzInput         = input.string("Exchange", title="Timezone", options=[
     "Exchange", 
     "UTC-12", "UTC-11", "UTC-10 (HST)", "UTC-9 (AKST)", "UTC-8 (PST)", "UTC-7 (MST)", 
     "UTC-6 (CST)", "UTC-5 (EST)", "UTC-4 (AST)", "UTC-3 (BRT)", "UTC-2", "UTC-1", 
     "UTC", "UTC+1 (CET)", "UTC+2 (EET)", "UTC+3 (MSK)", "UTC+4 (GST)", "UTC+5 (PKT)", 
     "UTC+5:30 (IST)", "UTC+6 (BST)", "UTC+7 (ICT)", "UTC+8 (SGT/HKT)", "UTC+9 (JST)", 
     "UTC+10 (AEST)", "UTC+11", "UTC+12 (NZST)", "UTC+13", "UTC+14"
     ], group="Time Settings")

// --- MAP TIMEZONE STRING ---
string tz = switch tzInput
    "Exchange"        => syminfo.timezone
    "UTC-12"          => "Etc/GMT+12"
    "UTC-11"          => "Etc/GMT+11"
    "UTC-10 (HST)"    => "Pacific/Honolulu"
    "UTC-9 (AKST)"    => "America/Anchorage"
    "UTC-8 (PST)"     => "America/Los_Angeles"
    "UTC-7 (MST)"     => "America/Denver"
    "UTC-6 (CST)"     => "America/Chicago"
    "UTC-5 (EST)"     => "America/New_York"
    "UTC-4 (AST)"     => "America/Halifax"
    "UTC-3 (BRT)"     => "America/Sao_Paulo"
    "UTC-2"           => "Etc/GMT+2"
    "UTC-1"           => "Etc/GMT+1"
    "UTC"             => "UTC"
    "UTC+1 (CET)"     => "Europe/Belgrade"
    "UTC+2 (EET)"     => "Europe/Athens"
    "UTC+3 (MSK)"     => "Europe/Moscow"
    "UTC+4 (GST)"     => "Asia/Dubai"
    "UTC+5 (PKT)"     => "Asia/Karachi"
    "UTC+5:30 (IST)"  => "Asia/Kolkata"
    "UTC+6 (BST)"     => "Asia/Dhaka"
    "UTC+7 (ICT)"     => "Asia/Bangkok"
    "UTC+8 (SGT/HKT)" => "Asia/Singapore"
    "UTC+9 (JST)"     => "Asia/Tokyo"
    "UTC+10 (AEST)"   => "Australia/Sydney"
    "UTC+11"          => "Pacific/Noumea"
    "UTC+12 (NZST)"   => "Pacific/Auckland"
    "UTC+13"          => "Pacific/Tongatapu"
    "UTC+14"          => "Pacific/Kiritimati"
    => syminfo.timezone

// --- MAP POSITION AND SIZE ---
var string tablePos = switch posInput
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right

var string textSize = switch sizeInput
    "Huge"   => size.huge
    "Large"  => size.large
    "Normal" => size.normal
    "Small"  => size.small
    => size.huge

// --- CREATE TABLE ---
var table clockTable = table.new(position = tablePos, columns = 1, rows = 1, bgcolor = bgColorInput, border_width = frameWidthInput, border_color = frameColorInput)

// --- UPDATE CLOCK ---
if barstate.islast
    // Get time components based on the selected timezone
    int h = hour(timenow, tz)
    int m = minute(timenow, tz)
    int s = second(timenow, tz)

    // Format time as HH:MM:SS
    string timeString = str.tostring(h, "00") + ":" + str.tostring(m, "00") + ":" + str.tostring(s, "00")
    
    // Set cell size dynamically if Extra Padding option is active
    int cellWidth  = (extraPadding and sizeInput == "Huge") ? 12 : 0
    int cellHeight = (extraPadding and sizeInput == "Huge") ? 8  : 0

    // Update cell
    table.cell(clockTable, column = 0, row = 0, text = timeString, text_color = textColorInput, text_size = textSize, width = cellWidth, height = cellHeight)
````
