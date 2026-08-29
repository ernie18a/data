<!-- tradingview-pine-id: PUB;d23508c807e445639ad2f813e8f648d3 -->
<!-- tradingviewscripts-format: 1 -->
# CRT Indicator [Dynamic Period Grid]

Source: https://www.tradingview.com/script/JVMlgA3j-CRT-Range-Indicator-Dynamic-Period-Grid/

## Description

[image]https://www.tradingview.com/x/0cpsYjMb/[/image]

The CRT Indicator [Dynamic Period Grid] is a multi-timeframe tool designed for traders who utilize Candle Range Theory and liquidity concepts.

Instead of cluttering your chart with endless historical lines, this indicator automatically identifies the active "Master CRT Range" on a higher timeframe (HTF) and projects it cleanly onto your lower execution timeframe. It frames the market’s accumulation and manipulation phases into a dynamic, expanding visual grid, allowing you to instantly spot true structural breakouts versus liquidity sweeps.

🧠 How It Works
The Master Candle: The script looks at your chosen Higher Timeframe (e.g., the 1-Hour chart) and establishes the High and Low of the most recently closed candle.

The Grid: It draws a clean bounding box around this range on your current lower timeframe (e.g., the 15m chart). As long as subsequent HTF candles form inside this range, the box dynamically expands to the right, dropping a new vertical grid line to mark the passage of each new HTF period.

The Breakout Reset: The Master Range is only considered "broken" if a HTF candle closes outside the boundaries. When a true close happens, the old grid is wiped away, and a brand new Master Range is established instantly.

🔥 Key Features
Liquidity Grab Detection (The Latch System): If price wicks past the range boundary but fails to close outside of it, the indicator permanently "latches" a warning onto the chart. The breached horizontal line will change to your designated Breach Color (e.g., Green for a high sweep, Red for a low sweep), and the text label will automatically update to explicitly call out a "(Liquidity Grab)".

Dynamic Grid Expansion: Stop guessing where you are in the session. The internal vertical lines keep your lower timeframe perfectly synced with the higher timeframe's pacing.

Unified & Clean Visuals: The base grid remains a single, solid color (defaulted to Yellow) to keep your charts clean. Only the specific levels that have been tested/swept will change color, drawing your eye exactly where it needs to be.

Repaint-Free Multi-Timeframe: Built with secure historical data referencing, ensuring the indicator plots accurately in real-time without looking into the future or repainting historical data.

⚙️ Settings
Master Timeframe: Select the HTF you want to define your range (e.g., 60 for 1H, 240 for 4H). The text labels will automatically update to reflect your choice.

Base Line/Text Color: Customize the default color of the unbroken range grid.

Breach Colors: Fully customize the visual alerts for when Buy-Side or Sell-Side liquidity is swept.

Line Styles & Widths: Toggle between solid, dashed, or dotted lines to fit your chart aesthetic.

📈 How to Use It
Trading the Sweep: Wait for the boundary line to change color and display "(Liquidity Grab)". Once the sweep is confirmed and price rejects back inside the grid, target the opposite side of the Master Range.

---

## Source Code

````pine
//@version=6
indicator("CRT Indicator [Dynamic Period Grid]", overlay=true)

// =========================================================================
// 1. SETTINGS & INPUTS
// =========================================================================
rangeTF   = input.timeframe("60", title="Master Timeframe")

// Visual Settings - Basic
colorBase = input.color(color.new(color.yellow, 0), title="Standard Line/Text Color")
lineWidth = input.int(2, title="Line Width", minval=1)
rayStyle  = input.string("Solid", title="Line Style", options=["Solid", "Dashed", "Dotted"])
textSize  = input.string(size.small, title="Text Size", options=[size.tiny, size.small, size.normal, size.large])

// Visual Settings - Dynamic Breach Colors
grp_breach = "Breach Colors & Liquidity Grabs"
colorHighBreach = input.color(color.new(color.lime, 0), title="Breached High Color", group=grp_breach)
colorLowBreach  = input.color(color.new(color.red, 0), title="Breached Low Color", group=grp_breach)

getLineStyle(style) =>
    style == "Dashed" ? line.style_dashed : 
     style == "Dotted" ? line.style_dotted : 
     line.style_solid

// =========================================================================
// 2. TIMEFRAME CONVERSIONS & DURATIONS
// =========================================================================
get_tf_string(tf) =>
    string res = tf
    float num = str.tonumber(tf)
    if not na(num)
        if num >= 60 and num % 60 == 0
            res := str.tostring(num / 60) + "H"
        else
            res := tf + "m"
    else
        res := tf 
    res

string tfText = get_tf_string(rangeTF)

int tf_ms = timeframe.in_seconds(rangeTF) * 1000

// =========================================================================
// 3. MASTER CANDLE LOGIC (Close Breakouts)
// =========================================================================
f_get_master() =>
    var float mHigh = high
    var float mLow  = low
    var int   mTime = time
    
    if close > mHigh or close < mLow
        mHigh := high
        mLow  := low
        mTime := time
        
    [mHigh, mLow, mTime]

[mHigh, mLow, mTime] = request.security(syminfo.tickerid, rangeTF, f_get_master(), barmerge.gaps_off, barmerge.lookahead_on)
htf_time = request.security(syminfo.tickerid, rangeTF, time, barmerge.gaps_off, barmerge.lookahead_on)

// =========================================================================
// 4. DRAWING THE BOUNDED MARKERS & DYNAMIC GRID
// =========================================================================
var line rayHigh = na
var line rayLow  = na
var line vLineLeft = na
var line vLineRight = na
var label lblHigh = na
var label lblLow  = na

var line[] innerVLines = array.new_line()

var bool highBreached = false
var bool lowBreached  = false

int htf_endTime = htf_time + tf_ms

// A. NEW MASTER CANDLE FORMED
if ta.change(mTime) != 0 or (na(rayHigh) and not na(mTime))
    line.delete(rayHigh)
    line.delete(rayLow)
    line.delete(vLineLeft)
    line.delete(vLineRight)
    label.delete(lblHigh)
    label.delete(lblLow)
    
    if array.size(innerVLines) > 0
        for i = 0 to array.size(innerVLines) - 1
            line.delete(array.get(innerVLines, i))
    array.clear(innerVLines)
    
    highBreached := false
    lowBreached  := false
    
    string highString = tfText + " Range High: " + str.tostring(mHigh, format.mintick)
    string lowString  = tfText + " Range Low: "  + str.tostring(mLow, format.mintick)

    rayHigh := line.new(
         x1=mTime, y1=mHigh, 
         x2=htf_endTime, y2=mHigh, 
         xloc=xloc.bar_time, color=colorBase, width=lineWidth, extend=extend.none, style=getLineStyle(rayStyle))
     
    rayLow := line.new(
         x1=mTime, y1=mLow,  
         x2=htf_endTime, y2=mLow,  
         xloc=xloc.bar_time, color=colorBase, width=lineWidth, extend=extend.none, style=getLineStyle(rayStyle))
     
    vLineLeft := line.new(
         x1=mTime, y1=mHigh, 
         x2=mTime, y2=mLow, 
         xloc=xloc.bar_time, color=colorBase, width=lineWidth, style=getLineStyle(rayStyle))
     
    vLineRight := line.new(
         x1=htf_endTime, y1=mHigh, 
         x2=htf_endTime, y2=mLow, 
         xloc=xloc.bar_time, color=colorBase, width=lineWidth, style=getLineStyle(rayStyle))
    
    lblHigh := label.new(
         x=mTime, y=mHigh, text=highString, 
         xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=colorBase, style=label.style_label_lower_left, size=textSize)
     
    lblLow := label.new(
         x=mTime, y=mLow, text=lowString,  
         xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=colorBase, style=label.style_label_upper_left, size=textSize)

// B. RANGE IS HELD -> ADD INNER VERTICAL LINE FOR NEW PERIOD
if ta.change(htf_time) != 0 and htf_time > mTime
    line newVLine = line.new(
         x1=htf_time, y1=mHigh, 
         x2=htf_time, y2=mLow, 
         xloc=xloc.bar_time, color=colorBase, width=lineWidth, style=getLineStyle(rayStyle))
    array.push(innerVLines, newVLine)

// =========================================================================
// 5. DYNAMIC COLOR LATCHING & EXPANSION UPDATES
// =========================================================================
if not na(rayHigh)
    if high > mHigh
        highBreached := true
    if low < mLow
        lowBreached  := true

    color finalHighColor = highBreached ? colorHighBreach : colorBase
    color finalLowColor  = lowBreached  ? colorLowBreach  : colorBase
    
    string finalHighText = tfText + " Range High: " + str.tostring(mHigh, format.mintick) + (highBreached ? " (Liquidity Grab)" : "")
    string finalLowText  = tfText + " Range Low: "  + str.tostring(mLow, format.mintick) + (lowBreached ? " (Liquidity Grab)" : "")

    // Horizontal bounds push forward and apply dynamic colors
    line.set_x2(rayHigh, htf_endTime)
    line.set_y1(rayHigh, mHigh)
    line.set_y2(rayHigh, mHigh)
    line.set_color(rayHigh, finalHighColor)

    line.set_x2(rayLow, htf_endTime)
    line.set_y1(rayLow, mLow)
    line.set_y2(rayLow, mLow)
    line.set_color(rayLow, finalLowColor)
    
    // Vertical lines update coordinates but STAY locked to the base color
    line.set_y1(vLineLeft, mHigh)
    line.set_y2(vLineLeft, mLow)
    
    line.set_x1(vLineRight, htf_endTime)
    line.set_x2(vLineRight, htf_endTime)
    line.set_y1(vLineRight, mHigh)
    line.set_y2(vLineRight, mLow)
    
    if array.size(innerVLines) > 0
        for i = 0 to array.size(innerVLines) - 1
            line.set_y1(array.get(innerVLines, i), mHigh)
            line.set_y2(array.get(innerVLines, i), mLow)
    
    // Update labels
    label.set_y(lblHigh, mHigh)
    label.set_text(lblHigh, finalHighText)
    label.set_textcolor(lblHigh, finalHighColor)
    
    label.set_y(lblLow, mLow)
    label.set_text(lblLow, finalLowText)
    label.set_textcolor(lblLow, finalLowColor)
````
