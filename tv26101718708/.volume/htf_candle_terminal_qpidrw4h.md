# HTF Candle Terminal

- url: https://www.tradingview.com/script/qPIdRw4h-HTF-Candle-Terminal/
- type: indicator
- pine_id: PUB;2005d9d0629642a194ab5f62e2676ecf
- version: 2.0

## Description

Title: HTF Candle Terminal: Advanced Institutional Volume & Range Engine
Description:
Welcome to the HTF Candle Terminal – a complete, institutional-grade toolkit designed to bridge the gap between Higher Timeframe (HTF) market structure and Lower Timeframe (LTF) execution.

This indicator acts as a real-time trading terminal directly on your chart, projecting higher timeframe data, volume clusters, volatility bands, and dynamic price zones so you never lose track of the macro trend while executing on the micro level.

What does it do?
Instead of switching back and forth between timeframes, the HTF Candle Terminal anchors itself to a Higher Timeframe of your choice (e.g., 4-Hour, Daily). Once a new HTF session begins, the terminal starts mapping the battlefield in real-time, calculating institutional volume, statistically probable ranges, and liquidity sweeps.

🔥 Core Features (A to Z)
1. Live HTF Candle Projection
To the right of the current price action, the indicator draws a live, constantly updating "Macro Candle." This gives you an instant visual representation of what the higher timeframe candle looks like (Open, High, Low, Close) without ever leaving your current chart. Accompanying the candle is a real-time trend status (e.g., "Very Strong Bullish" or "Bearish") based on how price is behaving relative to the HTF Open and Volume Nodes.

2. Dynamic Volume Profiling & POC (Point of Control)
The terminal tracks every drop of volume from the moment the HTF candle opens.

Bull/Bear Zones: It creates distinct bullish (above open) and bearish (below open) volume zones.
Split POC: It isolates the highest volume node for buyers (Short Line) and sellers (Long Line).
Zone Breakouts: If price decisively breaks and closes through a POC line from the opposite side, it invalidates that volume node, dynamically clearing the map to signal a strong directional shift.
Auto Row Size: The script includes an intelligent algorithm that automatically calculates the perfect row/tick size for the volume profile based on the volatility of the previous HTF candle.
3. Statistical Range Projections (Excursions)
How far did the last HTF candle travel from its open? The terminal mathematically measures the percentage expansion of the previous HTF candle and projects those exact percentages (e.g., +1.25%, -0.80%) onto the current candle's open. This gives you highly accurate, historically-backed target zones for the current session.

4. HTF ATR & ADR Projections (Volatility Boundaries)
Knowing where price should stop is just as important as knowing where it is going.

ATR (Average True Range): Projects the HTF's current True Range (+/- 0.5 ATR by default) from the open price, giving you realistic daily/session volatility boundaries.
ADR (Average Daily Range): Projects the chart's average daily movement anchored to the HTF open. When price hits these outer bands, it signals mathematical exhaustion—perfect for take-profit targeting or mean-reversion setups.
5. Liquidity Sweep Detection (PH & PL)
The script draws dashed lines representing the Previous HTF High (PH) and Previous HTF Low (PL). If the current price action pokes through these levels but fails to hold, the terminal instantly marks the chart with a precise "✖" label, alerting you to a potential liquidity sweep/hunt.

6. HTF Anchored VWAP
An optional (toggleable) Volume Weighted Average Price anchored precisely to the start of the HTF candle. This acts as the ultimate institutional "fair value" baseline. If price is above the VWAP, momentum is confirmed bullish; if below, bearish.

💡 How to Use the Terminal in Your Trading
Trade the Open: The most critical level is the dashed HTF Open line. Treat it as the equator. Longs above, shorts below.
Target the Extremes: Use the Excursion lines, ATR, and ADR bands as your primary Take-Profit (TP) zones. When price reaches these levels, the market is mathematically overextended.
Watch the POCs: The Bull and Bear POC lines act as heavy magnets. If price is returning to the open, watch for bounces off the POC. If a POC is broken, ride the momentum in the direction of the break.
Trade the Sweeps: Look for an "✖" marker at the PH or PL lines. A sweep combined with a rejection back into the HTF Open zone is one of the highest probability reversal setups available.
⚙️ Full Customization
Every element is built to be customized. Change the colors of the HTF candle, adjust global label sizes, toggle VWAP/ATR/ADR on or off, and tweak the transparency of historical boxes to keep your chart perfectly clean.

Developed with precision for structural and quantitative traders.
© erdensedat

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © erdensedat

//@version=6
indicator("HTF Candle Terminal", shorttitle="HTF Terminal", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// --- Inputs ---
string htfInput = input.timeframe("240", "Higher Timeframe")
int showLastN = input.int(1, "Show Last N Boxes", minval=1, maxval=50)

bool autoRowSize = input.bool(true, "Auto Row Size", tooltip="When auto mode is enabled, it automatically calculates the ideal number of rows based on the previous HTF box size.")
int ticksPerRow = input.int(10, "Row Size (Ticks) [Manual]", minval=1, step=10, tooltip="Used when Auto Row Size is disabled.")

int extendBoxes = input.int(1, "Extend Boxes (Bars to Right)", minval=0)

string pocStyleStr = input.string("Solid", "POC Line Style", options=["Solid", "Dotted", "Dashed"], group="Style")
int projectionOffset = input.int(5, "Projection Offset (Bars)", minval=1, group="Style")
string labelSizeStr = input.string("Small", "Global Label Size", options=["Tiny", "Small", "Normal", "Large"], group="Style")

color bullColor = input.color(color.new(#089981, 80), "Bull Zone Color", group="Style")
color bearColor = input.color(color.new(#f23645, 80), "Bear Zone Color", group="Style")

color htfBullColor = input.color(#089981, "HTF Candle Bull Color", group="Style")
color htfBearColor = input.color(#f23645, "HTF Candle Bear Color", group="Style")

color bullPocColor = input.color(color.new(#f23645, 0), "Bull POC Color (Short Line)", group="Style")
color bearPocColor = input.color(color.new(#089981, 0), "Bear POC Color (Long Line)", group="Style")
int pocWidth = input.int(2, "POC Line Width", minval=1, group="Style")
color prevLevelsColor = input.color(color.new(color.gray, 0), "Prev HH/LL Line Color", group="Style")
int prevLevelsWidth = input.int(2, "Prev HH/LL Line Width", minval=1, group="Style")

// --- Additional Features Inputs ---
bool showVWAP = input.bool(false, "Show HTF Anchored VWAP", group="VWAP Settings")
color vwapColor = input.color(color.new(#ff9800, 0), "VWAP Color", group="VWAP Settings")

bool showATR = input.bool(true, "Show HTF ATR Projections", group="ATR Settings")
int atrLength = input.int(14, "ATR Length", minval=1, group="ATR Settings")
float atrMult = input.float(0.5, "ATR Multiplier", minval=0.1, step=0.1, group="ATR Settings")
color atrColor = input.color(color.new(#5272be, 60), "ATR Target Box Color", group="ATR Settings")

bool showADR = input.bool(true, "Show HTF Anchored ADR", group="ADR Settings")
int adrLen = input.int(14, "ADR Length (Chart Bars)", minval=1, group="ADR Settings")
color adrColor = input.color(color.new(#9c27b0, 40), "ADR Projections Color", group="ADR Settings")

bool showWatermark = input.bool(true, "Show Watermark", group="Style")

// --- Types ---
type DrawnObjects
    line openLine
    box bullBox
    line bullPocLine
    box bearBox
    line bearPocLine
    array<label> sweeps

// --- Variables ---
var map<float, float> bullMap = map.new<float, float>()
var map<float, float> bearMap = map.new<float, float>()

var float htfOpen = na
var float currentBullPoc = na
var float currentBearPoc = na
var float currentBullMaxVol = 0.0
var float currentBearMaxVol = 0.0
var float htfHigh = na
var float htfLow = na

var int htfStartTime = na
var int htfStartBarIndex = na
var bool wentBelowOpen = false
var bool wentAboveOpen = false

var float prevOpen = na
var float prevHigh = na
var float prevLow = na

var line prevHighLine = na
var line prevLowLine = na
var label prevHighLabel = na
var label prevLowLabel = na

// Excursion lines
var line prevUpExLine = na
var line prevDownExLine = na
var label prevUpExLabel = na
var label prevDownExLabel = na

// ATR Projection lines
var box atrUpBox = na
var box atrDownBox = na
var label atrUpLabel = na
var label atrDownLabel = na
var float currentAtrUp = na
var float currentAtrDown = na

// ADR Projection lines
var line adrUpLine = na
var line adrDownLine = na
var label adrUpLabel = na
var label adrDownLabel = na
var float currentAdrUp = na
var float currentAdrDown = na

var float activeTickSize = ticksPerRow

var DrawnObjects currentDrawings = DrawnObjects.new(na, na, na, na, na, array.new<label>())
var array<DrawnObjects> history = array.new<DrawnObjects>()

var label activeBullLabel = na
var label activeBearLabel = na

// Projection Elements
var box projBody = box.new(na, na, na, na, border_color=na, xloc=xloc.bar_index)
var line projWick = line.new(na, na, na, na, xloc=xloc.bar_index, width=2)
var label projLabel = label.new(na, na, "", style=label.style_none, xloc=xloc.bar_index, textalign=text.align_center)

// Watermark Element
var table watermark = table.new(position.bottom_right, 1, 1)

// VWAP Variables
var float sumVol = 0.0
var float sumSrcVol = 0.0

// Request HTF ATR & Calculate ADR
float htfAtrRaw = request.security(syminfo.tickerid, htfInput, ta.atr(atrLength))
float htfAtr = htfAtrRaw * atrMult

float adrValue = ta.sma(high - low, adrLen)

// --- Functions ---
get_bin(float p, float tickSize) =>
    math.round(p / (syminfo.mintick * tickSize)) * (syminfo.mintick * tickSize)

get_line_style(string styleStr) =>
    switch styleStr
        "Solid" => line.style_solid
        "Dotted" => line.style_dotted
        "Dashed" => line.style_dashed
        => line.style_solid

format_tf(string tf) =>
    float tf_num = str.tonumber(tf)
    string res = tf
    if not na(tf_num)
        if tf_num < 60
            res := str.tostring(tf_num) + "m"
        else
            res := str.tostring(tf_num / 60) + "H"
    res

get_size(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

// --- Core Logic ---
bool isNewHTF = ta.change(time(htfInput)) != 0
string pocStyle = get_line_style(pocStyleStr)
string activeLabelSize = get_size(labelSizeStr)

if isNewHTF
    // Reset VWAP
    sumVol := 0.0
    sumSrcVol := 0.0
    
    // Save history
    if not na(htfOpen)
        // Make historical boxes more transparent (90 transparency = 10% opacity)
        currentDrawings.bullBox.set_bgcolor(color.new(bullColor, 90))
        currentDrawings.bearBox.set_bgcolor(color.new(bearColor, 90))
        
        array.push(history, currentDrawings)
        while array.size(history) > math.max(0, showLastN - 1)
            DrawnObjects old = array.shift(history)
            old.openLine.delete()
            old.bullBox.delete()
            old.bullPocLine.delete()
            old.bearBox.delete()
            old.bearPocLine.delete()
            for lbl in old.sweeps
                lbl.delete()
            
        // Setup Previous HTF levels
        prevOpen := htfOpen
        prevHigh := htfHigh
        prevLow := htfLow
        
        // Calculate percentages
        float pctUp = (prevHigh - prevOpen) / prevOpen
        float pctDown = (prevOpen - prevLow) / prevOpen
        
        // Project onto current Open
        float projectedUp = open * (1 + pctUp)
        float projectedDown = open * (1 - pctDown)
        
        if not na(prevHighLine)
            prevHighLine.delete()
        if not na(prevLowLine)
            prevLowLine.delete()
        if not na(prevHighLabel)
            prevHighLabel.delete()
        if not na(prevLowLabel)
            prevLowLabel.delete()
            
        if not na(prevUpExLine)
            prevUpExLine.delete()
        if not na(prevDownExLine)
            prevDownExLine.delete()
        if not na(prevUpExLabel)
            prevUpExLabel.delete()
        if not na(prevDownExLabel)
            prevDownExLabel.delete()
            
        // PH / PL Lines
        prevHighLine := line.new(x1=htfStartTime, y1=prevHigh, x2=time, y2=prevHigh, xloc=xloc.bar_time, color=prevLevelsColor, style=line.style_dashed, width=prevLevelsWidth)
        prevLowLine := line.new(x1=htfStartTime, y1=prevLow, x2=time, y2=prevLow, xloc=xloc.bar_time, color=prevLevelsColor, style=line.style_dashed, width=prevLevelsWidth)
        
        prevHighLabel := label.new(x=time, y=prevHigh, text="PH", xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=prevLevelsColor, style=label.style_label_down, size=activeLabelSize)
        prevLowLabel := label.new(x=time, y=prevLow, text="PL", xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=prevLevelsColor, style=label.style_label_up, size=activeLabelSize)
        
        // Excursion Projection Lines
        prevUpExLine := line.new(x1=time, y1=projectedUp, x2=time, y2=projectedUp, xloc=xloc.bar_time, color=color.new(htfBullColor, 30), style=line.style_dotted, width=1)
        prevDownExLine := line.new(x1=time, y1=projectedDown, x2=time, y2=projectedDown, xloc=xloc.bar_time, color=color.new(htfBearColor, 30), style=line.style_dotted, width=1)
        
        string upText = "+" + str.tostring(pctUp * 100, "#.##") + "%"
        string downText = "-" + str.tostring(pctDown * 100, "#.##") + "%"
        
        prevUpExLabel := label.new(x=time, y=projectedUp, text=upText, xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=color.new(htfBullColor, 0), style=label.style_label_down, size=activeLabelSize)
        prevDownExLabel := label.new(x=time, y=projectedDown, text=downText, xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=color.new(htfBearColor, 0), style=label.style_label_up, size=activeLabelSize)
        
        // ATR Target Boxes
        if showATR and not na(htfAtr)
            currentAtrUp := open + htfAtr
            currentAtrDown := open - htfAtr
            
            if not na(atrUpBox)
                atrUpBox.delete()
            if not na(atrDownBox)
                atrDownBox.delete()
            if not na(atrUpLabel)
                atrUpLabel.delete()
            if not na(atrDownLabel)
                atrDownLabel.delete()
                
            // Small thickness for the target box so it's visible but acts as a precise level
            float boxThick = math.max(syminfo.mintick * 2, htfAtr * 0.03)
                
            atrUpBox := box.new(left=time, top=currentAtrUp + boxThick, right=time, bottom=currentAtrUp - boxThick, xloc=xloc.bar_time, border_color=na, bgcolor=atrColor)
            atrDownBox := box.new(left=time, top=currentAtrDown + boxThick, right=time, bottom=currentAtrDown - boxThick, xloc=xloc.bar_time, border_color=na, bgcolor=atrColor)
            
            string atrStr = str.tostring(atrMult) + " ATR Target"
            atrUpLabel := label.new(x=time, y=currentAtrUp, text="+" + atrStr, xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=color.new(atrColor, 0), style=label.style_label_left, size=activeLabelSize)
            atrDownLabel := label.new(x=time, y=currentAtrDown, text="-" + atrStr, xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=color.new(atrColor, 0), style=label.style_label_left, size=activeLabelSize)

        // ADR Projections
        if showADR and not na(adrValue)
            currentAdrUp := open + adrValue
            currentAdrDown := open - adrValue
            
            if not na(adrUpLine)
                adrUpLine.delete()
            if not na(adrDownLine)
                adrDownLine.delete()
            if not na(adrUpLabel)
                adrUpLabel.delete()
            if not na(adrDownLabel)
                adrDownLabel.delete()
                
            adrUpLine := line.new(x1=time, y1=currentAdrUp, x2=time, y2=currentAdrUp, xloc=xloc.bar_time, color=adrColor, style=line.style_dashed, width=1)
            adrDownLine := line.new(x1=time, y1=currentAdrDown, x2=time, y2=currentAdrDown, xloc=xloc.bar_time, color=adrColor, style=line.style_dashed, width=1)
            
            // ADR Labels set to the left style so they appear on the right side of the anchor point
            adrUpLabel := label.new(x=time, y=currentAdrUp, text="ADR High", xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=color.new(adrColor, 0), style=label.style_label_left, size=activeLabelSize)
            adrDownLabel := label.new(x=time, y=currentAdrDown, text="ADR Low", xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=color.new(adrColor, 0), style=label.style_label_left, size=activeLabelSize)

        // Calculate Auto Tick Size based on previous HTF range (~50 rows per box)
        if autoRowSize
            activeTickSize := math.max(1, math.round((prevHigh - prevLow) / syminfo.mintick / 50))
        else
            activeTickSize := ticksPerRow
            
    // Reset for new HTF
    bullMap.clear()
    bearMap.clear()
    htfOpen := open
    htfStartTime := time
    htfStartBarIndex := bar_index
    htfHigh := high
    htfLow := low
    currentBullPoc := na
    currentBearPoc := na
    currentBullMaxVol := 0.0
    currentBearMaxVol := 0.0
    
    wentBelowOpen := low < open
    wentAboveOpen := high > open
    
    if not na(activeBullLabel)
        activeBullLabel.delete()
    if not na(activeBearLabel)
        activeBearLabel.delete()
        
    int rightTime = time + math.round(time - time[1]) * extendBoxes
    
    activeBullLabel := label.new(x=rightTime, y=htfOpen, text="short line", xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=color.new(bullPocColor, 100), style=label.style_label_left, size=activeLabelSize)
    activeBearLabel := label.new(x=rightTime, y=htfOpen, text="long line", xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=color.new(bearPocColor, 100), style=label.style_label_left, size=activeLabelSize)

    // Create new drawing objects for the current HTF
    currentDrawings := DrawnObjects.new(
      line.new(x1=htfStartTime, y1=htfOpen, x2=rightTime, y2=htfOpen, xloc=xloc.bar_time, color=chart.fg_color, style=line.style_dashed),
      box.new(left=htfStartTime, top=htfHigh, right=rightTime, bottom=htfOpen, xloc=xloc.bar_time, border_color=na, bgcolor=bullColor),
      line.new(x1=htfStartTime, y1=htfOpen, x2=rightTime, y2=htfOpen, xloc=xloc.bar_time, color=color.new(bullPocColor, 100), style=pocStyle, width=pocWidth),
      box.new(left=htfStartTime, top=htfOpen, right=rightTime, bottom=htfLow, xloc=xloc.bar_time, border_color=na, bgcolor=bearColor),
      line.new(x1=htfStartTime, y1=htfOpen, x2=rightTime, y2=htfOpen, xloc=xloc.bar_time, color=color.new(bearPocColor, 100), style=pocStyle, width=pocWidth),
      array.new<label>()
      )
else
    htfHigh := math.max(htfHigh, high)
    htfLow := math.min(htfLow, low)
    if low < htfOpen
        wentBelowOpen := true
    if high > htfOpen
        wentAboveOpen := true

// Update VWAP
sumVol += volume
sumSrcVol += hlc3 * volume
float vwapValue = sumVol > 0 ? sumSrcVol / sumVol : na

// Plot VWAP
plot(showVWAP ? vwapValue : na, "HTF VWAP", color=vwapColor, style=plot.style_line, linewidth=2)

// Sweep detection (using labels instead of plotshape to keep only the last N boxes)
bool sweepHigh = not na(prevHigh) and high > prevHigh and high[1] <= prevHigh
bool sweepLow = not na(prevLow) and low < prevLow and low[1] >= prevLow

if sweepHigh and not na(currentDrawings.openLine)
    label l = label.new(x=bar_index, y=high, text="✖", xloc=xloc.bar_index, color=color.new(color.white, 100), textcolor=color.red, style=label.style_label_down, size=activeLabelSize)
    array.push(currentDrawings.sweeps, l)

if sweepLow and not na(currentDrawings.openLine)
    label l = label.new(x=bar_index, y=low, text="✖", xloc=xloc.bar_index, color=color.new(color.white, 100), textcolor=color.green, style=label.style_label_up, size=activeLabelSize)
    array.push(currentDrawings.sweeps, l)

// Update Profile
float bin = get_bin(hlc3, activeTickSize)
float vol = volume

if not na(htfOpen)
    if hlc3 >= htfOpen
        float currentVol = nz(bullMap.get(bin), 0.0)
        float newVol = currentVol + vol
        bullMap.put(bin, newVol)
        if newVol > currentBullMaxVol
            currentBullMaxVol := newVol
            currentBullPoc := bin
    else
        float currentVol = nz(bearMap.get(bin), 0.0)
        float newVol = currentVol + vol
        bearMap.put(bin, newVol)
        if newVol > currentBearMaxVol
            currentBearMaxVol := newVol
            currentBearPoc := bin

// Check for Breakouts
if not na(currentBullPoc) and not na(currentBearPoc)
    // Strong Bullish Breakout: From <= Long Line (Bear POC) breaking > Short Line (Bull POC) with body
    if low <= currentBearPoc and close > currentBullPoc
        bullMap.clear()
        currentBullPoc := na
        currentBullMaxVol := 0.0
        
    // Strong Bearish Breakout: From >= Short Line (Bull POC) breaking < Long Line (Bear POC) with body
    else if high >= currentBullPoc and close < currentBearPoc
        bearMap.clear()
        currentBearPoc := na
        currentBearMaxVol := 0.0

// Update visual elements dynamically
if not na(htfOpen) and not na(currentDrawings.openLine)
    int rightTime = time + math.round(time - time[1]) * extendBoxes

    // Update Open Line
    currentDrawings.openLine.set_x2(rightTime)
    
    // Update Bull Box
    currentDrawings.bullBox.set_top(htfHigh)
    currentDrawings.bullBox.set_right(rightTime)
    
    // Update Bull POC Line & Label
    if not na(currentBullPoc)
        currentDrawings.bullPocLine.set_xy1(htfStartTime, currentBullPoc)
        currentDrawings.bullPocLine.set_xy2(rightTime, currentBullPoc)
        currentDrawings.bullPocLine.set_color(bullPocColor)
        
        activeBullLabel.set_xy(rightTime, currentBullPoc)
        activeBullLabel.set_textcolor(bullPocColor)
    else
        currentDrawings.bullPocLine.set_color(color.new(bullPocColor, 100)) // Hide
        activeBullLabel.set_textcolor(color.new(bullPocColor, 100))
        
    // Update Bear Box
    currentDrawings.bearBox.set_bottom(htfLow)
    currentDrawings.bearBox.set_right(rightTime)
    
    // Update Bear POC Line & Label
    if not na(currentBearPoc)
        currentDrawings.bearPocLine.set_xy1(htfStartTime, currentBearPoc)
        currentDrawings.bearPocLine.set_xy2(rightTime, currentBearPoc)
        currentDrawings.bearPocLine.set_color(bearPocColor)
        
        activeBearLabel.set_xy(rightTime, currentBearPoc)
        activeBearLabel.set_textcolor(bearPocColor)
    else
        currentDrawings.bearPocLine.set_color(color.new(bearPocColor, 100)) // Hide
        activeBearLabel.set_textcolor(color.new(bearPocColor, 100))
        
    // Update Prev HH/LL Lines
    if not na(prevHighLine)
        prevHighLine.set_x2(rightTime)
        prevHighLabel.set_x(rightTime)
    if not na(prevLowLine)
        prevLowLine.set_x2(rightTime)
        prevLowLabel.set_x(rightTime)
        
    // Update Percentage Projection Lines
    if not na(prevUpExLine)
        prevUpExLine.set_x2(rightTime)
        prevUpExLabel.set_x(rightTime)
    if not na(prevDownExLine)
        prevDownExLine.set_x2(rightTime)
        prevDownExLabel.set_x(rightTime)
        
    // Update ATR Target Boxes
    if showATR and not na(atrUpBox)
        atrUpBox.set_right(rightTime)
        atrUpLabel.set_x(rightTime)
    if showATR and not na(atrDownBox)
        atrDownBox.set_right(rightTime)
        atrDownLabel.set_x(rightTime)

    // Update ADR Projection Lines
    if showADR and not na(adrUpLine)
        adrUpLine.set_x2(rightTime)
        adrUpLabel.set_x(rightTime)
    if showADR and not na(adrDownLine)
        adrDownLine.set_x2(rightTime)
        adrDownLabel.set_x(rightTime)

// --- Chart Projection Status & Candle ---
string tfStr = format_tf(htfInput)
string panelTxt = "Waiting for trend..."
color pColor = color.gray

bool canShowInfo = (time - htfStartTime) >= 15 * 60 * 1000 or (bar_index > htfStartBarIndex)

if canShowInfo and not na(htfOpen)
    if not wentBelowOpen
        panelTxt := "Very Strong Bullish\n" + tfStr
        pColor := htfBullColor
    else if not wentAboveOpen
        panelTxt := "Very Strong Bearish\n" + tfStr
        pColor := htfBearColor
    else if close > htfOpen
        if not na(currentBullPoc) and close > currentBullPoc
            panelTxt := "Strong Bullish\n" + tfStr
            pColor := htfBullColor
        else
            panelTxt := "Bullish\n" + tfStr
            pColor := htfBullColor
    else if close < htfOpen
        if not na(currentBearPoc) and close < currentBearPoc
            panelTxt := "Strong Bearish\n" + tfStr
            pColor := htfBearColor
        else
            panelTxt := "Bearish\n" + tfStr
            pColor := htfBearColor

if barstate.islast and not na(htfOpen)
    color candleColor = close >= htfOpen ? htfBullColor : htfBearColor
    float bodyTop = math.max(htfOpen, close)
    float bodyBot = math.min(htfOpen, close)
    
    int x1 = bar_index + projectionOffset
    int x2 = bar_index + projectionOffset + 2
    int midX = x1 + 1
    
    // Update Body
    projBody.set_lefttop(x1, bodyTop)
    projBody.set_rightbottom(x2, bodyBot)
    projBody.set_bgcolor(candleColor)
    
    // Update Wick
    projWick.set_xy1(midX, htfHigh)
    projWick.set_xy2(midX, htfLow)
    projWick.set_color(candleColor)
    
    // Update Status Label
    projLabel.set_xy(midX, htfHigh)
    projLabel.set_text(panelTxt)
    projLabel.set_textcolor(pColor)
    
    // If body is extremely small (doji), force 1 tick height so it's visible
    if bodyTop - bodyBot < syminfo.mintick
        projBody.set_lefttop(x1, bodyBot + syminfo.mintick)
        projBody.set_rightbottom(x2, bodyBot - syminfo.mintick)

    // Update Watermark
    if showWatermark
        table.cell(watermark, 0, 0, "HTF Candle Terminal\n© erdensedat", text_color=color.new(chart.fg_color, 70), text_size=size.small, text_halign=text.align_right)
    else
        table.clear(watermark, 0, 0)
````
