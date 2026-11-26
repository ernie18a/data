# ICT Concept & Fib Liquidity Box

- url: https://www.tradingview.com/script/SV6j2isY-ICT-Concept-Fib-Liquidity-Box/
- type: indicator
- pine_id: PUB;ad67037dd1cb4275a75037eea9a95fbf
- version: 1.0

## Description

EMA cross over and ICT concept for 2022 model(Features Included:
EMAs (13, 53, 103, 173): Plotted with different colors as requested. You can toggle their visibility from the indicator settings.
Killzones: Highlights the background with distinct transparent colors during the specified times (Asia, London, New York). Default times are based on EST/EDT; you can adjust the session parameters in the input settings.
Fair Value Gaps (FVG): Identifies bullish and bearish 3-bar Fair Value Gaps and projects a colored box on them. It dynamically deletes older ones, keeping exactly the latest 7 on your chart (can be changed in settings).
BOS & Fibonacci Liquidity Zone:
Tracks pivot highs and lows (structural swings).
When the structure breaks (BOS occurs), it draws a Fibonacci Optimal Trade Entry (OTE) zone (between the 0.618 and 0.786 retracement levels).
The zone automatically extends forward and dynamically expands if the trend pushes to a new extreme before reversing.
When the price dips into this box for the first time, it waits for an exit and plots a "Liq Grab" signal indicating liquidity was potentially swept inside the zone.
ICT Unicorn Model:
Uses the unicorn emoji 🦄 to mark a classic ICT unicorn setup. It identifies occurrences where a new Fair Value Gap overlaps perfectly with a previously broken structural swing point (a Breaker block).
You can configure almost everything (pivot length, Fib levels, FVG limit, session times) directly from the indicator settings icon! Let me know if you would like me to adjust the visual style or tighten any of the specific entry conditions!

## Source Code

````pine
 //@version=6
indicator("ICT Concept & Fib Liquidity Box", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ==============================================================================
// INPUTS
// ==============================================================================
grp_ema = "EMAs"
showEma = input.bool(true, "Show EMAs", group=grp_ema)

grp_kz = "Kill Zones (EST/EDT)"
showKz = input.bool(true, "Show Killzones", group=grp_kz)
asiaSession = input.session("2000-0000", "Asia Killzone", group=grp_kz)
londonSession = input.session("0200-0500", "London Killzone", group=grp_kz)
nySession = input.session("0700-1000", "New York Killzone", group=grp_kz)

grp_fvg = "Fair Value Gaps"
showFvg = input.bool(true, "Show FVGs", group=grp_fvg)
fvgCount = input.int(7, "Max FVGs to show", minval=1, maxval=20, group=grp_fvg)

grp_bos = "BOS & Fib Zone"
showBos = input.bool(true, "Show BOS & Fib", group=grp_bos)
pivotLen = input.int(15, "Pivot Length (15 recommended for XAUUSD)", group=grp_bos)
fibLevel1 = input.float(0.618, "Fib Level 1", group=grp_bos)
fibLevel2 = input.float(0.786, "Fib Level 2", group=grp_bos)
fibLevel3 = input.float(0.53, "Fib Level 0.53", group=grp_bos)
fibLevel4 = input.float(0.63, "Fib Level 0.63", group=grp_bos)
fibLevel5 = input.float(0.73, "Fib Level 0.73", group=grp_bos)



// ==============================================================================
// EMAS
// ==============================================================================
ema13 = ta.ema(close, 13)
ema53 = ta.ema(close, 53)
ema103 = ta.ema(close, 103)
ema173 = ta.ema(close, 173)

plot(showEma ? ema13 : na, color=#2962FF, title="EMA 13")
plot(showEma ? ema53 : na, color=#FF6D00, title="EMA 53")
plot(showEma ? ema103 : na, color=#00C853, title="EMA 103")
plot(showEma ? ema173 : na, color=#D50000, title="EMA 173")

// ==============================================================================
// KILL ZONES
// ==============================================================================
inAsia = not na(time(timeframe.period, asiaSession, "America/New_York"))
inLondon = not na(time(timeframe.period, londonSession, "America/New_York"))
inNy = not na(time(timeframe.period, nySession, "America/New_York"))

bgcolor(showKz and inAsia ? color.new(#9C27B0, 90) : na, title="Asia KZ")
bgcolor(showKz and inLondon ? color.new(#2962FF, 90) : na, title="London KZ")
bgcolor(showKz and inNy ? color.new(#FF6D00, 90) : na, title="NY KZ")

// ==============================================================================
// FAIR VALUE GAPS (FVG)
// ==============================================================================
type FVG
    int startBar
    int endBar
    float top
    float bottom
    bool isBullish
    box bx

var fvgArray = array.new<FVG>()

bullFvg = low > high[2] and close[1] > open[1]
bearFvg = high < low[2] and close[1] < open[1]

if bullFvg and showFvg
    newFvg = FVG.new(bar_index[2], bar_index, low, high[2], true, box.new(bar_index[2], low, bar_index, high[2], border_color=na, bgcolor=color.new(#089981, 85)))
    array.push(fvgArray, newFvg)
    if array.size(fvgArray) > fvgCount
        removed = array.shift(fvgArray)
        box.delete(removed.bx)

if bearFvg and showFvg
    newFvg = FVG.new(bar_index[2], bar_index, low[2], high, false, box.new(bar_index[2], low[2], bar_index, high, border_color=na, bgcolor=color.new(#F23645, 85)))
    array.push(fvgArray, newFvg)
    if array.size(fvgArray) > fvgCount
        removed = array.shift(fvgArray)
        box.delete(removed.bx)

if array.size(fvgArray) > 0
    for i = 0 to array.size(fvgArray) - 1
        f = array.get(fvgArray, i)
        box.set_right(f.bx, bar_index)

// ==============================================================================
// BOS & FIBONACCI OTE ZONE
// ==============================================================================
var int trend = 0
var float lastPh = na
var float lastPl = na
var int lastPhIndex = na
var int lastPlIndex = na

ph = ta.pivothigh(pivotLen, pivotLen)
pl = ta.pivotlow(pivotLen, pivotLen)

var line liqHighLine = na
var line liqLowLine = na

if not na(ph)
    lastPh := ph
    lastPhIndex := bar_index[pivotLen]
    if not na(liqHighLine)
        line.delete(liqHighLine)
    liqHighLine := line.new(lastPhIndex, lastPh, bar_index, lastPh, color=color.new(#F23645, 50), style=line.style_dashed, width=2)
else
    if not na(liqHighLine)
        line.set_x2(liqHighLine, bar_index)

if not na(pl)
    lastPl := pl
    lastPlIndex := bar_index[pivotLen]
    if not na(liqLowLine)
        line.delete(liqLowLine)
    liqLowLine := line.new(lastPlIndex, lastPl, bar_index, lastPl, color=color.new(#089981, 50), style=line.style_dashed, width=2)
else
    if not na(liqLowLine)
        line.set_x2(liqLowLine, bar_index)

var float fibHigh = na
var float fibLow = na
var box fibBox = na
var line fibL3 = na
var line fibL4 = na
var line fibL5 = na
var bool inFibZone = false
var bool signalFired = false

bullBos = ta.crossover(close, lastPh) and trend <= 0
bearBos = ta.crossunder(close, lastPl) and trend >= 0

emaCrossBull = ta.crossover(ema13, ema53)
emaCrossBear = ta.crossunder(ema13, ema53)

if bullBos
    trend := 1
    fibHigh := high
    fibLow := lastPl
    if showBos
        if not na(fibBox)
            box.delete(fibBox)
            line.delete(fibL3)
            line.delete(fibL4)
            line.delete(fibL5)
            
        fibTop = fibHigh - (fibHigh - fibLow) * fibLevel1
        fibBot = fibHigh - (fibHigh - fibLow) * fibLevel2
        fibBox := box.new(lastPlIndex, fibTop, bar_index, fibBot, bgcolor=color.new(#FF9800, 85), border_color=#FF9800)
        
        f3 = fibHigh - (fibHigh - fibLow) * fibLevel3
        f4 = fibHigh - (fibHigh - fibLow) * fibLevel4
        f5 = fibHigh - (fibHigh - fibLow) * fibLevel5
        fibL3 := line.new(lastPlIndex, f3, bar_index, f3, color=color.new(#FF9800, 0), style=line.style_solid, width=2)
        fibL4 := line.new(lastPlIndex, f4, bar_index, f4, color=color.new(#FF9800, 0), style=line.style_solid, width=2)
        fibL5 := line.new(lastPlIndex, f5, bar_index, f5, color=color.new(#FF9800, 0), style=line.style_solid, width=2)
        
        inFibZone := false
        signalFired := false

if bearBos
    trend := -1
    fibLow := low
    fibHigh := lastPh
    if showBos
        if not na(fibBox)
            box.delete(fibBox)
            line.delete(fibL3)
            line.delete(fibL4)
            line.delete(fibL5)
            
        fibBot = fibLow + (fibHigh - fibLow) * fibLevel1
        fibTop = fibLow + (fibHigh - fibLow) * fibLevel2
        fibBox := box.new(lastPhIndex, fibTop, bar_index, fibBot, bgcolor=color.new(#FF9800, 85), border_color=#FF9800)
        
        f3 = fibLow + (fibHigh - fibLow) * fibLevel3
        f4 = fibLow + (fibHigh - fibLow) * fibLevel4
        f5 = fibLow + (fibHigh - fibLow) * fibLevel5
        fibL3 := line.new(lastPhIndex, f3, bar_index, f3, color=color.new(#FF9800, 0), style=line.style_solid, width=2)
        fibL4 := line.new(lastPhIndex, f4, bar_index, f4, color=color.new(#FF9800, 0), style=line.style_solid, width=2)
        fibL5 := line.new(lastPhIndex, f5, bar_index, f5, color=color.new(#FF9800, 0), style=line.style_solid, width=2)
        
        inFibZone := false
        signalFired := false

if trend == 1
    if high > fibHigh
        fibHigh := high
        if not na(fibBox)
            fibTop = fibHigh - (fibHigh - fibLow) * fibLevel1
            fibBot = fibHigh - (fibHigh - fibLow) * fibLevel2
            box.set_top(fibBox, fibTop)
            box.set_bottom(fibBox, fibBot)
            
            f3 = fibHigh - (fibHigh - fibLow) * fibLevel3
            f4 = fibHigh - (fibHigh - fibLow) * fibLevel4
            f5 = fibHigh - (fibHigh - fibLow) * fibLevel5
            line.set_y1(fibL3, f3)
            line.set_y2(fibL3, f3)
            line.set_y1(fibL4, f4)
            line.set_y2(fibL4, f4)
            line.set_y1(fibL5, f5)
            line.set_y2(fibL5, f5)

if trend == -1
    if low < fibLow
        fibLow := low
        if not na(fibBox)
            fibBot = fibLow + (fibHigh - fibLow) * fibLevel1
            fibTop = fibLow + (fibHigh - fibLow) * fibLevel2
            box.set_top(fibBox, fibTop)
            box.set_bottom(fibBox, fibBot)
            
            f3 = fibLow + (fibHigh - fibLow) * fibLevel3
            f4 = fibLow + (fibHigh - fibLow) * fibLevel4
            f5 = fibLow + (fibHigh - fibLow) * fibLevel5
            line.set_y1(fibL3, f3)
            line.set_y2(fibL3, f3)
            line.set_y1(fibL4, f4)
            line.set_y2(fibL4, f4)
            line.set_y1(fibL5, f5)
            line.set_y2(fibL5, f5)

if not na(fibBox)
    box.set_right(fibBox, bar_index)
    if not na(fibL3)
        line.set_x2(fibL3, bar_index)
        line.set_x2(fibL4, bar_index)
        line.set_x2(fibL5, bar_index)
        
    top = box.get_top(fibBox)
    bot = box.get_bottom(fibBox)
    
    enteredZone = low <= top and high >= bot
    if enteredZone and not inFibZone
        inFibZone := true
    
    if inFibZone and not signalFired and (trend == 1 ? close > top : close < bot)
        if (trend == 1 and emaCrossBull)
            label.new(bar_index, low - ta.tr, "BUY", style=label.style_label_up, color=color.new(#089981, 0), textcolor=color.white, size=size.normal)
            
        if (trend == -1 and emaCrossBear)
            label.new(bar_index, high + ta.tr, "SELL", style=label.style_label_down, color=color.new(#F23645, 0), textcolor=color.white, size=size.normal)

        signalFired := true

// ==============================================================================
// UNICORN MODEL (FVG Overlapping Broken Swing / Breaker)
// ==============================================================================
if bullFvg and not na(lastPh)
    if lastPh >= high[2] and lastPh <= low
        label.new(bar_index, low, "🦄", style=label.style_label_up, color=color.new(color.white, 100), textcolor=#9C27B0, size=size.normal)

if bearFvg and not na(lastPl)
    if lastPl <= low[2] and lastPl >= high
        label.new(bar_index, high, "🦄", style=label.style_label_down, color=color.new(color.white, 100), textcolor=#9C27B0, size=size.normal)

// ==============================================================================
// PREVIOUS DAY & WEEK TREND VIEWER
// ==============================================================================
[pdClose, pdOpen, pdHigh, pdLow] = request.security(syminfo.tickerid, "D", [close[1], open[1], high[1], low[1]], lookahead=barmerge.lookahead_on)
[pwClose, pwOpen] = request.security(syminfo.tickerid, "W", [close[1], open[1]], lookahead=barmerge.lookahead_on)

var table trendTable = table.new(position.top_right, 2, 3, bgcolor=color.new(#000000, 80), border_color=color.new(color.white, 80), border_width=1)

if barstate.islast
    dTrend = pdClose > pdOpen ? "Bullish" : pdClose < pdOpen ? "Bearish" : "Neutral"
    dColor = pdClose > pdOpen ? #089981 : pdClose < pdOpen ? #F23645 : color.gray
    
    wTrend = pwClose > pwOpen ? "Bullish" : pwClose < pwOpen ? "Bearish" : "Neutral"
    wColor = pwClose > pwOpen ? #089981 : pwClose < pwOpen ? #F23645 : color.gray
    
    table.cell(trendTable, 0, 0, "Previous TF", text_color=color.white, text_size=size.small)
    table.cell(trendTable, 1, 0, "Trend", text_color=color.white, text_size=size.small)
    
    table.cell(trendTable, 0, 1, "Day", text_color=color.white, text_size=size.small)
    table.cell(trendTable, 1, 1, dTrend, text_color=dColor, text_size=size.small)
    
    table.cell(trendTable, 0, 2, "Week", text_color=color.white, text_size=size.small)
    table.cell(trendTable, 1, 2, wTrend, text_color=wColor, text_size=size.small)

// ==============================================================================
// HTF POI (Previous Day OHLC)
// ==============================================================================
var line pdHighLine = na
var line pdLowLine = na
var line pdOpenLine = na
var line pdCloseLine = na

var label pdHighLbl = na
var label pdLowLbl = na
var label pdOpenLbl = na
var label pdCloseLbl = na
var label pdDeltaLbl = na

if barstate.islast
    if not na(pdHighLine)
        line.delete(pdHighLine)
        line.delete(pdLowLine)
        line.delete(pdOpenLine)
        line.delete(pdCloseLine)
        
        label.delete(pdHighLbl)
        label.delete(pdLowLbl)
        label.delete(pdOpenLbl)
        label.delete(pdCloseLbl)
        label.delete(pdDeltaLbl)
        
    start_bar = bar_index - 50
    
    pdHighLine := line.new(start_bar, pdHigh, bar_index + 10, pdHigh, color=color.new(#089981, 0), style=line.style_dashed)
    pdLowLine := line.new(start_bar, pdLow, bar_index + 10, pdLow, color=color.new(#F23645, 0), style=line.style_dashed)
    pdOpenLine := line.new(start_bar, pdOpen, bar_index + 10, pdOpen, color=color.new(color.gray, 0), style=line.style_dotted)
    pdCloseLine := line.new(start_bar, pdClose, bar_index + 10, pdClose, color=color.new(color.gray, 0), style=line.style_dotted)
    
    // Calculate Delta (Close - Open)
    pdDelta = pdClose - pdOpen
    deltaSign = pdDelta > 0 ? "+" : ""
    deltaColor = pdDelta > 0 ? #089981 : #F23645
    
    pdHighLbl := label.new(bar_index + 10, pdHigh, "High: " + str.tostring(pdHigh, format.mintick), color=color.new(color.white, 100), textcolor=#089981, style=label.style_label_left, size=size.small)
    pdCloseLbl := label.new(bar_index + 10, pdClose, "Close: " + str.tostring(pdClose, format.mintick), color=color.new(color.white, 100), textcolor=color.gray, style=label.style_label_left, size=size.small)
    pdOpenLbl := label.new(bar_index + 10, pdOpen, "Open: " + str.tostring(pdOpen, format.mintick), color=color.new(color.white, 100), textcolor=color.black, style=label.style_label_left, size=size.small)
    pdLowLbl := label.new(bar_index + 10, pdLow, "Low: " + str.tostring(pdLow, format.mintick), color=color.new(color.white, 100), textcolor=color.black, style=label.style_label_left, size=size.small)
    
    // Place Delta label slightly below the low
    pdDeltaLbl := label.new(bar_index + 10, pdLow - ta.tr, "Delta: " + deltaSign + str.tostring(pdDelta, format.mintick), color=color.new(color.white, 100), textcolor=deltaColor, style=label.style_label_left, size=size.small)
````
