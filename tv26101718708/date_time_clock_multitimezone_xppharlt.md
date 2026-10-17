# Date & Time Clock: Multi-Timezone

- url: https://www.tradingview.com/script/xppharLT-Date-Time-Clock-Multi-Timezone/
- type: indicator
- pine_id: PUB;7c58ccc10bca4ec0b12171b9f1687999
- version: 1.0

## Description

🕐 A clean, always-on clock for your chart. Shows the current date and time in any timezone you choose, pinned to the corner you pick.

Built to be simple, readable, and out of your way.

──────────────────────────

✅ WHAT IT DOES
Displays today's date and the live time in a small box on your chart — so you always know "what time is it, right now, in the market I care about" without doing timezone math in your head.

──────────────────────────

⚙️ WHAT YOU CAN CONTROL
• Corner — put the clock in any of the 4 chart corners
• Font size — Small, Medium, or Large
• Timezone — New York, Chicago, London, Frankfurt, Tokyo, Sydney, UTC, or match the chart's exchange
• Date format — Jun 6, 2026  /  2026-06-06  /  06/06/2026
• Time format — 12-hour or 24-hour, with or without seconds
• Colors — text color + background color (and transparency)

──────────────────────────

🌍 DAYLIGHT SAVING IS AUTOMATIC
The timezone label shows the live GMT offset, e.g. "New York (GMT-4)". It adjusts itself for daylight saving — you never have to switch anything by hand.

──────────────────────────

ℹ️ ONE THING TO KNOW
TradingView updates indicators when price moves. So the clock ticks forward on active symbols during market hours, and may pause when the market is quiet or closed. That's normal — it's not frozen.

──────────────────────────

🚀 HOW TO USE
1. Add to your chart
2. Open settings (the gear icon)
3. Pick your corner, timezone, format, and colors

Free and open-source. Feedback welcome 🙏

## Source Code

````pine
//@version=6
indicator("Date & Time Clock", overlay = true)

// ============================================================
//  Date & Time Clock — v1
//  Shows the current date + time pinned to a chart corner.
//  - Live wall-clock via `timenow`.
//  - Timezone offset (incl. daylight saving) is rendered by the
//    native "Z" token in str.format_time — one mechanism for all
//    zones, no abbreviation lookup table to maintain.
// ============================================================

// ---------- Inputs ----------
gStyle = "Display"
gFmt   = "Format"

posInput  = input.string("Top Right", "Corner", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group = gStyle)
sizeInput = input.string("Medium", "Font size", options = ["Small", "Medium", "Large"], group = gStyle)
txtColor  = input.color(color.white, "Text color", group = gStyle)
bgColor   = input.color(color.new(#1e222d, 20), "Background color", group = gStyle)

tzInput      = input.string("New York", "Timezone", options = ["Exchange", "New York", "Chicago", "London", "Frankfurt", "Tokyo", "Sydney", "UTC"], group = gFmt)
dateFmtInput = input.string("Jun 6, 2026", "Date format", options = ["Jun 6, 2026", "2026-06-06", "06/06/2026"], group = gFmt)
timeFmtInput = input.string("2:30 PM", "Time format", options = ["2:30 PM", "2:30:25 PM", "14:30", "14:30:25"], group = gFmt)

// ---------- Mappings ----------
tablePos = switch posInput
    "Top Left"     => position.top_left
    "Top Right"    => position.top_right
    "Bottom Left"  => position.bottom_left
    "Bottom Right" => position.bottom_right
    => position.top_right

txtSize = switch sizeInput
    "Small"  => size.small
    "Medium" => size.normal
    "Large"  => size.large
    => size.normal

tz = switch tzInput
    "Exchange"  => syminfo.timezone
    "New York"  => "America/New_York"
    "Chicago"   => "America/Chicago"
    "London"    => "Europe/London"
    "Frankfurt" => "Europe/Berlin"
    "Tokyo"     => "Asia/Tokyo"
    "Sydney"    => "Australia/Sydney"
    "UTC"       => "UTC"
    => "America/New_York"

zoneName = tzInput  // the dropdown label doubles as the friendly display name

// ---------- Offset label helper ----------
// The "Z" token returns a raw offset like "-0400"; turn it into "GMT-4" / "GMT+5:30".
f_offsetLabel(string raw) =>
    sign = str.substring(raw, 0, 1)
    hh   = int(str.tonumber(str.substring(raw, 1, 3)))
    mm   = str.substring(raw, 3, 5)
    base = "GMT" + sign + str.tostring(hh)
    mm == "00" ? base : base + ":" + mm

offsetLabel = f_offsetLabel(str.format_time(timenow, "Z", tz))

// ---------- Format strings ----------
dateFmt = switch dateFmtInput
    "Jun 6, 2026" => "MMM d, yyyy"
    "2026-06-06"  => "yyyy-MM-dd"
    "06/06/2026"  => "MM/dd/yyyy"
    => "MMM d, yyyy"

timeFmt = switch timeFmtInput
    "2:30 PM"    => "h:mm a"
    "2:30:25 PM" => "h:mm:ss a"
    "14:30"      => "HH:mm"
    "14:30:25"   => "HH:mm:ss"
    => "h:mm a"

dateStr = str.format_time(timenow, dateFmt, tz)
timeStr = str.format_time(timenow, timeFmt, tz)
line2   = timeStr + " · " + zoneName + " (" + offsetLabel + ")"

// ---------- Render ----------
var table clock = table.new(tablePos, 1, 2, bgcolor = bgColor)
if barstate.islast
    table.cell(clock, 0, 0, dateStr, text_color = txtColor, text_size = txtSize, bgcolor = bgColor)
    table.cell(clock, 0, 1, line2,   text_color = txtColor, text_size = txtSize, bgcolor = bgColor)
````
