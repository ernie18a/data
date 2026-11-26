# Asia & NY Session Range Table (heistrader)

- url: https://www.tradingview.com/script/UmI8auWW-Asia-NY-Session-Range-Table-heistrader/
- type: indicator
- pine_id: PUB;811ff5476e2d4c4891edbdf0ea1aeebc
- version: 1.0

## Description

Asia & NY Session Range Table
(heistrader)

Overview
This powerful indicator automatically tracks and displays key price levels from Asia and New York trading sessions, along with daily data and RSI, in a clean, customizable table format. Perfect for traders who want to quickly reference multi-session ranges without manual calculations.

🎯 Key Features
📈 Session Tracking
Asia Session (HKT 06:00-10:00) – Track Asian session High, Low, and Range

NY Session (EST 09:30-16:00) – Track New York session High, Low, and Range

Full Daily Data – Complete day's High, Low, Range, and average RSI

📅 Historical Reference
Shows Today + 4 previous days (Prev, Prev 2, Prev 3, Prev 4)

Automatically shifts data each new trading day

No manual data entry required

🎨 Visual Customization
Color-coded section labels:

🔴 Asia Session – Red background

🔵 NY Session – Blue background

🟢 Daily Data – Green background

RSI color alerts:

🔴 Red text for overbought (≥70)

🟢 Green text for oversold (≤30)

Fully customizable table position, size, and colors

⚙️ Flexible Settings
Toggle individual rows on/off (Asia, NY, Daily, RSI)

Adjustable session times

Customizable RSI length and thresholds

Multiple table positions: Top/Bottom, Left/Right

Table sizes: Tiny, Small, Normal, Large

💡 Why Use This Indicator?
Traditional Method	This Indicator
Manual session tracking	Automatic session detection
Scrolling through charts	Instant table display
Mental calculations	Automatic range calculation
Multiple timeframes	One consolidated view
🔧 How It Works
Automatically detects when Asia and NY sessions begin/end based on your timezone

Records session High/Low values in real-time

Calculates session ranges and daily RSI averages

Shifts data at each new trading day

Displays all information in a clean table on your chart

📋 Example Use Cases
🏢 Institutional Traders
Quickly identify overnight ranges and potential breakout levels

📉 Day Traders
Reference key support/resistance levels from major sessions

📊 Swing Traders
Track session volatility patterns across multiple days

🔬 Technical Analysts
Compare RSI conditions with price action across sessions

🚀 Quick Start
Add indicator to your chart

Verify timezone setting (default: Asia/Hong_Kong)

Adjust session times if needed

Position table where convenient (default: Top Right)

Toggle rows you want to display

Start trading with instant session data!

⚡ Pro Tips
Volume Confirmation: Use Asia/NY ranges alongside volume indicators

Breakout Strategy: Watch for price breaking beyond previous session ranges

RSI Divergence: Look for price/RSI divergences across daily and session data

Multiple Timeframe: Combine with higher timeframe analysis for confluence

📝 Input Parameters
Parameter	Default	Description
Timezone	Asia/Hong_Kong	Your chart's timezone
Asia Session	2200-0200 UTC	(HKT 06:00-10:00)
NY Session	1330-2000 UTC	(EST 09:30-16:00)
Table Position	Top Right	Where table appears
Table Size	Small	Font size
RSI Length	14	Period for RSI calculation
RSI Overbought	70	Threshold for red text
RSI Oversold	30	Threshold for green text
❓ Common Questions
Q: Does this work on any timeframe?
A: Yes! Works on all timeframes from 1min to monthly.

Q: Can I adjust session times?
A: Absolutely – both Asia and NY session times are fully customizable in UTC.

Q: Does it repaint?
A: No. Session values are only finalized after each session closes.

Q: Can I hide certain rows?
A: Yes – each row group has its own visibility toggle.

#heistrader

## Source Code

````pine
//@version=6
indicator("Asia & NY Session Range Table", overlay=true)

// ===== Inputs
tz           = input.string("Asia/Hong_Kong", "Timezone")
// Convert HK session to UTC: 06:00-10:00 HKT = 22:00-02:00 UTC
asiaSess     = input.session("2200-0200", "Asia Session (HKT 06:00-10:00)")
// NY session: 09:30-16:00 NY time = 13:30-20:00 UTC
nySess       = input.session("1330-2000", "NY Session (EST 09:30-16:00)")

tablePos     = input.string("Top Right", "Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])
tableSize    = input.string("Small", "Table Size", options=["Tiny", "Small", "Normal", "Large"])

titleTextCol = input.color(color.white, "Header Text Color")
bodyTextCol  = input.color(color.new(color.white, 25), "Body Text Color")
bgHeaderCol  = input.color(color.new(color.blue, 0), "Header Background")
bgBodyCol    = input.color(color.new(color.black, 85), "Body Background")

// ===== Row Visibility Toggles
showAsiaRow   = input.bool(true, "Show Asia High/Low/Range Row")
showNYRow     = input.bool(true, "Show NY High/Low/Range Row")
showDailyRow  = input.bool(true, "Show Daily High/Low/Range Row")
showRSIRow    = input.bool(true, "Show Daily RSI Row")

// ===== RSI Input
rsiLength     = input.int(14, "RSI Length")
rsiOverbought = input.int(70, "RSI Overbought")
rsiOversold   = input.int(30, "RSI Oversold")

// ===== Position
pos = tablePos == "Top Right" ? position.top_right :
      tablePos == "Top Left" ? position.top_left :
      tablePos == "Bottom Right" ? position.bottom_right :
      position.bottom_left

txtSize = tableSize == "Tiny" ? size.tiny :
          tableSize == "Small" ? size.small :
          tableSize == "Normal" ? size.normal : size.large

// ===== Session helper
inSession(sess) =>
    not na(time(timeframe.period, sess, tz))

newDay = ta.change(time("D", tz)) != 0

// ===== Stored Asia ranges for 5 days (Today + 4 previous)
var float aHi0 = na
var float aLo0 = na
var float aHi1 = na
var float aLo1 = na
var float aHi2 = na
var float aLo2 = na
var float aHi3 = na
var float aLo3 = na
var float aHi4 = na
var float aLo4 = na

// ===== Stored NY ranges for 5 days
var float nyHi0 = na
var float nyLo0 = na
var float nyHi1 = na
var float nyLo1 = na
var float nyHi2 = na
var float nyLo2 = na
var float nyHi3 = na
var float nyLo3 = na
var float nyHi4 = na
var float nyLo4 = na

// ===== Stored Daily data for 5 days
var float dHi0 = na
var float dLo0 = na
var float dRsi0 = na
var float dHi1 = na
var float dLo1 = na
var float dRsi1 = na
var float dHi2 = na
var float dLo2 = na
var float dRsi2 = na
var float dHi3 = na
var float dLo3 = na
var float dRsi3 = na
var float dHi4 = na
var float dLo4 = na
var float dRsi4 = na

// ===== Current session tracking
var float curAHi = na
var float curALo = na
var bool doneA = false

var float curNYHi = na
var float curNYLo = na
var bool doneNY = false

// ===== Current daily tracking
var float curDHi = na
var float curDLo = na
var float sumRsi = 0.0
var int rsiCount = 0

// Calculate RSI
rsiValue = ta.rsi(close, rsiLength)

// Shift data at new day (save previous day's data before resetting)
if newDay
    // Shift Asia data (Previous becomes Prev 1, etc.)
    aHi4 := aHi3
    aLo4 := aLo3
    aHi3 := aHi2
    aLo3 := aLo2
    aHi2 := aHi1
    aLo2 := aLo1
    aHi1 := aHi0
    aLo1 := aLo0
    
    // Shift NY data
    nyHi4 := nyHi3
    nyLo4 := nyLo3
    nyHi3 := nyHi2
    nyLo3 := nyLo2
    nyHi2 := nyHi1
    nyLo2 := nyLo1
    nyHi1 := nyHi0
    nyLo1 := nyLo0
    
    // Shift Daily data
    dHi4 := dHi3
    dLo4 := dLo3
    dRsi4 := dRsi3
    dHi3 := dHi2
    dLo3 := dLo2
    dRsi3 := dRsi2
    dHi2 := dHi1
    dLo2 := dLo1
    dRsi2 := dRsi1
    dHi1 := dHi0
    dLo1 := dLo0
    dRsi1 := dRsi0
    
    // Reset today's values
    aHi0 := na
    aLo0 := na
    nyHi0 := na
    nyLo0 := na
    dHi0 := na
    dLo0 := na
    dRsi0 := na
    
    curAHi := na
    curALo := na
    doneA := false
    curNYHi := na
    curNYLo := na
    doneNY := false
    curDHi := na
    curDLo := na
    sumRsi := 0.0
    rsiCount := 0

// ===== Track daily high/low (full day from 00:00 to 00:00 in TZ)
curDHi := na(curDHi) ? high : math.max(curDHi, high)
curDLo := na(curDLo) ? low : math.min(curDLo, low)

// ===== Track daily RSI (average of all RSI values in the day)
if not na(rsiValue)
    sumRsi += rsiValue
    rsiCount += 1

// ===== Asia session range
if inSession(asiaSess)
    curAHi := na(curAHi) ? high : math.max(curAHi, high)
    curALo := na(curALo) ? low : math.min(curALo, low)
else if not doneA and not na(curAHi)
    aHi0 := curAHi
    aLo0 := curALo
    doneA := true

// ===== NY session range
if inSession(nySess)
    curNYHi := na(curNYHi) ? high : math.max(curNYHi, high)
    curNYLo := na(curNYLo) ? low : math.min(curNYLo, low)
else if not doneNY and not na(curNYHi)
    nyHi0 := curNYHi
    nyLo0 := curNYLo
    doneNY := true

// ===== At end of day, store daily values
if not newDay[1] and newDay
    dHi0 := curDHi[1]
    dLo0 := curDLo[1]
    dRsi0 := rsiCount[1] > 0 ? sumRsi[1] / rsiCount[1] : na

// ===== Formatting
f_val(_v) =>
    na(_v) ? "na" : str.tostring(_v, format.mintick)

f_rng(_hi, _lo) =>
    na(_hi) or na(_lo) ? "na" : str.tostring(_hi - _lo, format.mintick)

f_rsi(_rsi) =>
    na(_rsi) ? "na" : str.tostring(math.round(_rsi, 1))

// ===== Color based on RSI value
f_rsi_color(_rsi) =>
    if na(_rsi)
        bodyTextCol
    else if _rsi >= rsiOverbought
        color.new(color.red, 0)
    else if _rsi <= rsiOversold
        color.new(color.green, 0)
    else
        bodyTextCol


// ===== Calculate rows count based on visibility
getRowCount() =>
    rowCount = 1
    if showAsiaRow
        rowCount += 3
    if showNYRow
        rowCount += 3
    if showDailyRow
        rowCount += 3
    if showRSIRow
        rowCount += 1
    rowCount

// ===== Color for section labels
getLabelColor(section) =>
    if section == "Asia"
        color.new(color.red, 0)
    else if section == "NY"
        color.new(color.blue, 0)
    else if section == "Daily"
        color.new(color.green, 0)
    else
        bgHeaderCol

// ===== Tables
var table titleTable = table.new(position.top_center, 1, 1, border_width=0)
var table t = table.new(pos, 6, getRowCount(), border_width=1)

if barstate.islast
    // Set title
    table.cell(titleTable, 0, 0, "Powered by Stephen Ko", text_size=txtSize, 
               text_color=titleTextCol, bgcolor=bgHeaderCol, text_halign=text.align_center)
    
    currentRow = 0
    
    // ===== Header Row
    table.cell(t, 0, currentRow, "Session", text_size=txtSize, text_color=titleTextCol, bgcolor=bgHeaderCol)
    table.cell(t, 1, currentRow, "Today", text_size=txtSize, text_color=titleTextCol, bgcolor=bgHeaderCol)
    table.cell(t, 2, currentRow, "Prev", text_size=txtSize, text_color=titleTextCol, bgcolor=bgHeaderCol)
    table.cell(t, 3, currentRow, "Prev 2", text_size=txtSize, text_color=titleTextCol, bgcolor=bgHeaderCol)
    table.cell(t, 4, currentRow, "Prev 3", text_size=txtSize, text_color=titleTextCol, bgcolor=bgHeaderCol)
    table.cell(t, 5, currentRow, "Prev 4", text_size=txtSize, text_color=titleTextCol, bgcolor=bgHeaderCol)
    currentRow += 1
    
    // ===== Asia Session Rows
    if showAsiaRow
        // Asia High
        table.cell(t, 0, currentRow, "Asia High", text_size=txtSize, text_color=titleTextCol, bgcolor=getLabelColor("Asia"))
        table.cell(t, 1, currentRow, f_val(aHi0), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 2, currentRow, f_val(aHi1), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 3, currentRow, f_val(aHi2), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 4, currentRow, f_val(aHi3), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 5, currentRow, f_val(aHi4), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        currentRow += 1
        
        // Asia Low
        table.cell(t, 0, currentRow, "Asia Low", text_size=txtSize, text_color=titleTextCol, bgcolor=getLabelColor("Asia"))
        table.cell(t, 1, currentRow, f_val(aLo0), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 2, currentRow, f_val(aLo1), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 3, currentRow, f_val(aLo2), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 4, currentRow, f_val(aLo3), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 5, currentRow, f_val(aLo4), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        currentRow += 1
        
        // Asia Range
        table.cell(t, 0, currentRow, "Asia Range", text_size=txtSize, text_color=titleTextCol, bgcolor=getLabelColor("Asia"))
        table.cell(t, 1, currentRow, f_rng(aHi0, aLo0), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 2, currentRow, f_rng(aHi1, aLo1), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 3, currentRow, f_rng(aHi2, aLo2), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 4, currentRow, f_rng(aHi3, aLo3), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 5, currentRow, f_rng(aHi4, aLo4), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        currentRow += 1
    
    // ===== NY Session Rows
    if showNYRow
        // NY High
        table.cell(t, 0, currentRow, "NY High", text_size=txtSize, text_color=titleTextCol, bgcolor=getLabelColor("NY"))
        table.cell(t, 1, currentRow, f_val(nyHi0), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 2, currentRow, f_val(nyHi1), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 3, currentRow, f_val(nyHi2), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 4, currentRow, f_val(nyHi3), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 5, currentRow, f_val(nyHi4), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        currentRow += 1
        
        // NY Low
        table.cell(t, 0, currentRow, "NY Low", text_size=txtSize, text_color=titleTextCol, bgcolor=getLabelColor("NY"))
        table.cell(t, 1, currentRow, f_val(nyLo0), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 2, currentRow, f_val(nyLo1), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 3, currentRow, f_val(nyLo2), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 4, currentRow, f_val(nyLo3), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 5, currentRow, f_val(nyLo4), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        currentRow += 1
        
        // NY Range
        table.cell(t, 0, currentRow, "NY Range", text_size=txtSize, text_color=titleTextCol, bgcolor=getLabelColor("NY"))
        table.cell(t, 1, currentRow, f_rng(nyHi0, nyLo0), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 2, currentRow, f_rng(nyHi1, nyLo1), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 3, currentRow, f_rng(nyHi2, nyLo2), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 4, currentRow, f_rng(nyHi3, nyLo3), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 5, currentRow, f_rng(nyHi4, nyLo4), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        currentRow += 1
    
    // ===== Daily Rows
    if showDailyRow
        // Daily High
        table.cell(t, 0, currentRow, "Daily High", text_size=txtSize, text_color=titleTextCol, bgcolor=getLabelColor("Daily"))
        table.cell(t, 1, currentRow, f_val(dHi0), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 2, currentRow, f_val(dHi1), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 3, currentRow, f_val(dHi2), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 4, currentRow, f_val(dHi3), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 5, currentRow, f_val(dHi4), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        currentRow += 1
        
        // Daily Low
        table.cell(t, 0, currentRow, "Daily Low", text_size=txtSize, text_color=titleTextCol, bgcolor=getLabelColor("Daily"))
        table.cell(t, 1, currentRow, f_val(dLo0), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 2, currentRow, f_val(dLo1), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 3, currentRow, f_val(dLo2), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 4, currentRow, f_val(dLo3), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 5, currentRow, f_val(dLo4), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        currentRow += 1
        
        // Daily Range
        table.cell(t, 0, currentRow, "Daily Range", text_size=txtSize, text_color=titleTextCol, bgcolor=getLabelColor("Daily"))
        table.cell(t, 1, currentRow, f_rng(dHi0, dLo0), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 2, currentRow, f_rng(dHi1, dLo1), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 3, currentRow, f_rng(dHi2, dLo2), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 4, currentRow, f_rng(dHi3, dLo3), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        table.cell(t, 5, currentRow, f_rng(dHi4, dLo4), text_size=txtSize, text_color=bodyTextCol, bgcolor=bgBodyCol)
        currentRow += 1
    
    // ===== Daily RSI Row
    if showRSIRow
        table.cell(t, 0, currentRow, "Daily RSI", text_size=txtSize, text_color=titleTextCol, bgcolor=getLabelColor("Daily"))
        table.cell(t, 1, currentRow, f_rsi(dRsi0), text_size=txtSize, text_color=f_rsi_color(dRsi0), bgcolor=bgBodyCol)
        table.cell(t, 2, currentRow, f_rsi(dRsi1), text_size=txtSize, text_color=f_rsi_color(dRsi1), bgcolor=bgBodyCol)
        table.cell(t, 3, currentRow, f_rsi(dRsi2), text_size=txtSize, text_color=f_rsi_color(dRsi2), bgcolor=bgBodyCol)
        table.cell(t, 4, currentRow, f_rsi(dRsi3), text_size=txtSize, text_color=f_rsi_color(dRsi3), bgcolor=bgBodyCol)
        table.cell(t, 5, currentRow, f_rsi(dRsi4), text_size=txtSize, text_color=f_rsi_color(dRsi4), bgcolor=bgBodyCol)
        currentRow += 1
````
