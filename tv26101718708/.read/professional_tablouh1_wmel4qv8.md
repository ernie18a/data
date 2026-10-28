# PROFESSIONAL (TABLOUH1)

- url: https://www.tradingview.com/script/wmeL4qv8-PROFESSIONAL-TABLOUH1/
- type: indicator
- pine_id: PUB;0d1f25f3f0e6456d96e0296d87755faa
- version: 1.0

## Description

Think of this indicator as a Smart Roadmap for your chart that manages your EMAs and your calendar automatically.

Here is the simple breakdown:

* Smart EMAs:
* It shows 5-minute lines only when you are on small charts (for scalping).
   * It shows 1-hour lines (with a colored cloud between them) to show the big trend.
   * It has a Yellow line that follows you on every timeframe.

* Past Markers (The History):
* It draws gray vertical lines to show where every previous Day (small charts), Week (hourly charts), or Month (daily charts) started.

* Future Marker (The Deadline):
* It draws one Bright Magenta line ahead of the current price.
   * This line shows you exactly when the next session or month will begin. It acts like a "finish 
line" for the current period.

* Auto-Cleaning:
* As you change timeframes, the lines and EMAs vanish or appear so your chart never looks messy.

In short: It shows you where you’ve been, where you are going, and what the big-picture trend is doing—all in one tool.

## Source Code

````pine
//@version=5
indicator("Adaptive Multi-TF EMA + Precision Future Separators", overlay=true, max_lines_count=500)

// --- INPUTS: EMAs ---
show5m   = input.bool(true, "Show 5m EMAs?", group="EMA Visibility")
limit5m  = input.int(15, "Hide 5m EMA if Chart > (min)", group="EMA Visibility")
show1h   = input.bool(true, "Show 1h EMAs?", group="EMA Visibility")
limit1h  = input.int(60, "Hide 1h EMA if Chart > (min)", group="EMA Visibility")
showDyn  = input.bool(true, "Show Dynamic 20 EMA?", group="EMA Visibility")

// --- INPUTS: 1H CLOUD ---
showCloud = input.bool(true, "Show 1h EMA Cloud?", group="1h Cloud Options")
cloudCol  = input.color(color.new(color.orange, 80), "Cloud Color", group="1h Cloud Options")

// --- INPUTS: SMART SEPARATORS ---
showSess      = input.bool(true, "Enable Separators", group="Separator Settings")
sessColor     = input.color(color.new(color.gray, 50), "Past Line Color", group="Separator Settings")
futureSessCol = input.color(color.new(#ff00ff, 0), "Future Line Color (Magenta)", group="Separator Settings") // Bright Magenta
sessStyle     = input.string("Dashed", "Line Style", options=["Solid", "Dashed", "Dotted"], group="Separator Settings")
sessWidth     = input.int(1, "Line Width", group="Separator Settings")

// --- CALCULATIONS: EMAs ---
currentTF = timeframe.isintraday ? timeframe.multiplier : (timeframe.isdaily ? 1440 : timeframe.isweekly ? 10080 : 43200)

e9_5m  = request.security(syminfo.tickerid, "5", ta.ema(close, 9))
e20_5m = request.security(syminfo.tickerid, "5", ta.ema(close, 20))
e10_1h = request.security(syminfo.tickerid, "60", ta.ema(close, 10))
e20_1h = request.security(syminfo.tickerid, "60", ta.ema(close, 20))
dynEma = ta.ema(close, 20)

// --- LOGIC: SEPARATORS ---
lineStyle = sessStyle == "Solid" ? line.style_solid : sessStyle == "Dashed" ? line.style_dashed : line.style_dotted

// 1. Past Lines (Historical)
isNewCycle = false
if timeframe.isweekly
    isNewCycle := ta.change(time("Y")) != 0 
else if timeframe.isdaily
    isNewCycle := ta.change(time("M")) != 0 
else if timeframe.isintraday and timeframe.multiplier >= 60
    isNewCycle := ta.change(time("W")) != 0 
else if timeframe.isintraday
    isNewCycle := ta.change(time("D")) != 0 

if showSess and isNewCycle
    line.new(bar_index, low, bar_index, high, xloc=xloc.bar_index, extend=extend.both, color=sessColor, style=lineStyle, width=sessWidth)

// 2. Future Line (Locked to 1st of period)
var line nextCycleLine = na
if showSess and barstate.islast
    line.delete(nextCycleLine)
    
    int nextTime = na
    if timeframe.isweekly
        nextTime := timestamp(year(time) + 1, 1, 1, 0, 0)
    else if timeframe.isdaily
        int nextMonth = month(time) == 12 ? 1 : month(time) + 1
        int nextYear  = month(time) == 12 ? year(time) + 1 : year(time)
        nextTime := timestamp(nextYear, nextMonth, 1, 0, 0)
    else if timeframe.isintraday and timeframe.multiplier >= 60
        nextTime := time("W") + 604800000 
    else if timeframe.isintraday
        nextTime := time("D") + 86400000

    if not na(nextTime)
        nextCycleLine := line.new(nextTime, close, nextTime, close, xloc=xloc.bar_time, extend=extend.both, color=futureSessCol, style=lineStyle, width=sessWidth)

// --- PLOTS ---
p1h_1 = plot(show1h and currentTF <= limit1h ? e10_1h : na, "1h EMA 10", color=color.orange, linewidth=2)
p1h_2 = plot(show1h and currentTF <= limit1h ? e20_1h : na, "1h EMA 20", color=color.red,    linewidth=2)
fill(p1h_1, p1h_2, color = showCloud and show1h and currentTF <= limit1h ? cloudCol : na)

plot(show5m and currentTF <= limit5m ? e9_5m : na,  "5m EMA 9",  color=color.blue)
plot(show5m and currentTF <= limit5m ? e20_5m : na, "5m EMA 20", color=color.aqua)
plot(showDyn ? dynEma : na, "Dynamic EMA 20", color=color.yellow, linewidth=2)
````
