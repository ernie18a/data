# Indices Delta Dashboard

- url: https://www.tradingview.com/script/Otfsei46-Indices-Delta-Dashboard/
- type: indicator
- pine_id: PUB;7dc139c9e20946e195d8dd95c6b63b08
- version: 1.0

## Description

The indicator calculates "Delta" as the difference between buying and selling volume (approximated by comparing the Close to the Open). It provides two key metrics for each ticker in a clean table format:

Bar Delta: The net buy/sell volume for the most recent completed bar.
Session Delta: The cumulative net buy/sell volume since the start of the current trading day.
Key Features:
Multi-Ticker Support: Monitors NQ (Nasdaq 100), ES (S&P 500), YM (Dow Jones), and RTY (Russell 2000) simultaneously.
Session Tracking: Automatically resets the "Session Delta" at the start of each new trading day.
Customization: You can adjust the tickers, table position, and colors in the script settings.
Visual Clarity: Bullish values are highlighted in green, and bearish values in red for quick interpretation..

What has changed:
Generic Symbols: I've changed the default symbols to NQ1!, ES1!, YM1!, and RTY1!. TradingView will now automatically look for the primary continuous futures contract available for these tickers.
Error Handling: I added the ignore_invalid_symbol = true parameter to the data requests. This prevents the script from stopping if one of the symbols isn't found.
Manual Selection: If a symbol still shows as "Invalid" in the table, you can now easily change it:
Open the indicator Settings (gear icon).
Click on the Ticker input field.
Use the search box to find and select the exact version of the symbol you use (e.g., if you use Micro Futures, search for MNQ1!).

What's New:
Text Size Control: I added a "Text Size" input in the settings (Style group). You can now choose between Tiny, Small, Normal, and Large to adjust the overall size of the table.
Extended Positions: The "Table Position" setting now explicitly includes all four corners: Top Right, Top Left, Bottom Right, and Bottom Left.
Cleaner Ticker Display: I implemented a cleaning function that:
Removes the exchange prefix (e.g., CME:NQ1! becomes NQ1!).
Specifically removes keywords like MINI or MICRO from the displayed text to keep the table compact.
The table will now look much cleaner and can be positioned anywhere on your chart to avoid overlapping with price action or other indicators.

Key Additions:
Table Timeframe: You can now set a specific timeframe for the table (e.g., 5m) independently of your chart timeframe (e.g., 1m). The "Bar Delta" will reflect the volume of the most recent 5-minute bar, and the "Session Delta" will accumulate those 5-minute bars.
Session Type (Globex):
Daily (All): Accumulates delta for the entire trading day (resetting at the daily open).
Globex (18:00-09:30 EST): Accumulates delta specifically during the overnight session from 6:00 PM to 9:30 AM EST.
The script uses the America/New_York timezone to ensure it handles Daylight Savings Time changes automatically.
Dynamic Headers: The table header now displays the current calculation timeframe in parentheses (e.g., "Ticker (5)") so you always know what data you're looking at.
How to use:
Open the indicator Settings.
Go to the Timeframe & Session group.
Adjust the Table Timeframe to your preference.
Switch Session Type to "Globex" to see only the overnight delta.


CREATED BY luxAlgo Quant

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("Indices Delta Dashboard", overlay = true)

// --- Groups ---
string G_TICKERS = "Tickers"
string G_TIME    = "Timeframe & Session"
string G_STYLE   = "Style"

// --- Inputs ---
ticker1 = input.symbol("NQ1!", "Ticker 1", group = G_TICKERS)
ticker2 = input.symbol("ES1!", "Ticker 2", group = G_TICKERS)
ticker3 = input.symbol("YM1!", "Ticker 3", group = G_TICKERS)
ticker4 = input.symbol("RTY1!", "Ticker 4", group = G_TICKERS)

tfInput      = input.timeframe("5", "Table Timeframe", group = G_TIME)
sessionMode  = input.string("Daily (All)", "Session Type", options = ["Daily (All)", "Globex (18:00-09:30 EST)"], group = G_TIME)

posInput  = input.string("Top Right", "Table Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = G_STYLE)
sizeInput = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_STYLE)
bullColor = input.color(#089981, "Bullish Color", group = G_STYLE)
bearColor = input.color(#f23645, "Bearish Color", group = G_STYLE)
textColor = input.color(color.gray, "Text Color", group = G_STYLE)

// --- Logic ---
// Globex session string for EST (America/New_York)
string GLOBEX_SESS = "1800-0930:2345671"

// Core data fetching logic (Manual extraction for each ticker)
[o1, c1, v1, td1, tg1] = request.security(ticker1, tfInput, [open, close, volume, time("D"), time("", GLOBEX_SESS, "America/New_York")], ignore_invalid_symbol = true)
[o2, c2, v2, td2, tg2] = request.security(ticker2, tfInput, [open, close, volume, time("D"), time("", GLOBEX_SESS, "America/New_York")], ignore_invalid_symbol = true)
[o3, c3, v3, td3, tg3] = request.security(ticker3, tfInput, [open, close, volume, time("D"), time("", GLOBEX_SESS, "America/New_York")], ignore_invalid_symbol = true)
[o4, c4, v4, td4, tg4] = request.security(ticker4, tfInput, [open, close, volume, time("D"), time("", GLOBEX_SESS, "America/New_York")], ignore_invalid_symbol = true)

// Delta calculation
d1 = nz(c1) > nz(o1) ? nz(v1) : nz(c1) < nz(o1) ? -nz(v1) : 0
d2 = nz(c2) > nz(o2) ? nz(v2) : nz(c2) < nz(o2) ? -nz(v2) : 0
d3 = nz(c3) > nz(o3) ? nz(v3) : nz(c3) < nz(o3) ? -nz(v3) : 0
d4 = nz(c4) > nz(o4) ? nz(v4) : nz(c4) < nz(o4) ? -nz(v4) : 0

// Accumulation logic for each ticker
var float cd1 = 0.0
var float cd2 = 0.0
var float cd3 = 0.0
var float cd4 = 0.0

isGlobex = sessionMode == "Globex (18:00-09:30 EST)"

// Ticker 1 Accumulation
if isGlobex
    if not na(tg1) and na(tg1[1])
        cd1 := d1
    else if not na(tg1)
        cd1 += d1
    else
        cd1 := 0.0
else
    if ta.change(td1) != 0
        cd1 := d1
    else
        cd1 += d1

// Ticker 2 Accumulation
if isGlobex
    if not na(tg2) and na(tg2[1])
        cd2 := d2
    else if not na(tg2)
        cd2 += d2
    else
        cd2 := 0.0
else
    if ta.change(td2) != 0
        cd2 := d2
    else
        cd2 += d2

// Ticker 3 Accumulation
if isGlobex
    if not na(tg3) and na(tg3[1])
        cd3 := d3
    else if not na(tg3)
        cd3 += d3
    else
        cd3 := 0.0
else
    if ta.change(td3) != 0
        cd3 := d3
    else
        cd3 += d3

// Ticker 4 Accumulation
if isGlobex
    if not na(tg4) and na(tg4[1])
        cd4 := d4
    else if not na(tg4)
        cd4 += d4
    else
        cd4 := 0.0
else
    if ta.change(td4) != 0
        cd4 := d4
    else
        cd4 += d4

// --- Visualization ---
f_clean_ticker(s) =>
    parts = str.split(s, ":")
    raw = array.get(parts, array.size(parts) - 1)
    res = str.replace_all(raw, "MINI", "")
    res := str.replace_all(res, "MICRO", "")
    res

tbl_pos = switch posInput
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.middle_right

tbl_size = switch sizeInput
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    => size.small

var tbl = table.new(tbl_pos, 3, 5, frame_color = color.gray, frame_width = 1, border_color = color.gray, border_width = 1)

if barstate.islast
    table.cell(tbl, 0, 0, "Ticker (" + tfInput + ")", text_color = textColor, bgcolor = color.new(color.gray, 90), text_size = tbl_size)
    table.cell(tbl, 1, 0, "Bar Delta", text_color = textColor, bgcolor = color.new(color.gray, 90), text_size = tbl_size)
    table.cell(tbl, 2, 0, "Session Delta", text_color = textColor, bgcolor = color.new(color.gray, 90), text_size = tbl_size)

    table.cell(tbl, 0, 1, f_clean_ticker(ticker1), text_color = textColor, text_size = tbl_size)
    table.cell(tbl, 1, 1, str.format("{0,number,#}", d1), text_color = d1 >= 0 ? bullColor : bearColor, text_size = tbl_size)
    table.cell(tbl, 2, 1, str.format("{0,number,#}", cd1), text_color = cd1 >= 0 ? bullColor : bearColor, text_size = tbl_size)
    
    table.cell(tbl, 0, 2, f_clean_ticker(ticker2), text_color = textColor, text_size = tbl_size)
    table.cell(tbl, 1, 2, str.format("{0,number,#}", d2), text_color = d2 >= 0 ? bullColor : bearColor, text_size = tbl_size)
    table.cell(tbl, 2, 2, str.format("{0,number,#}", cd2), text_color = cd2 >= 0 ? bullColor : bearColor, text_size = tbl_size)
    
    table.cell(tbl, 0, 3, f_clean_ticker(ticker3), text_color = textColor, text_size = tbl_size)
    table.cell(tbl, 1, 3, str.format("{0,number,#}", d3), text_color = d3 >= 0 ? bullColor : bearColor, text_size = tbl_size)
    table.cell(tbl, 2, 3, str.format("{0,number,#}", cd3), text_color = cd3 >= 0 ? bullColor : bearColor, text_size = tbl_size)
    
    table.cell(tbl, 0, 4, f_clean_ticker(ticker4), text_color = textColor, text_size = tbl_size)
    table.cell(tbl, 1, 4, str.format("{0,number,#}", d4), text_color = d4 >= 0 ? bullColor : bearColor, text_size = tbl_size)
    table.cell(tbl, 2, 4, str.format("{0,number,#}", cd4), text_color = cd4 >= 0 ? bullColor : bearColor, text_size = tbl_size)
````
