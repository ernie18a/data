# Daily Levels + EMA + ORB + Fib + VWAP + Vol

- url: https://www.tradingview.com/script/ApvLUvcU-Daily-Levels-EMA-ORB-Fib-VWAP-Vol/
- type: indicator
- pine_id: PUB;f7828dc33d074322a7a52ade08a0f71c
- version: 1.0

## Description

🚀 Ultimate Intraday Power Toolkit – PDH/PMH/CHL + Fib7 + VWAP + ORB + Patterns
The complete all-in-one intraday trading indicator designed for serious day traders and scalpers who want every key level, momentum signal, and high-probability setup on a single clean chart.
🔥 Key Features:

Daily Market Structure Levels
Bold Previous Day High/Low (solid green/red)
Lighter Pre-Market High/Low (dashed)
Live Current Day HOD/LOD (very light dotted) — updates in real-time

7-Day Fibonacci Retracements – Automatically drawn every new trading day with unique vibrant colors for each level (0%, 23.6%, 38.2%, 50%, 61.8%, 78.6%, 100%)
EMA 9/20 Cloud – Instant visual bias (green = bullish, red = bearish)
Opening Range Breakout (ORB) – Clear ↑↓ arrows on 30-min (customizable) breakouts
Powerful Candlestick Patterns – Automatic callouts for Hammer, Shooting Star, Bullish & Bearish Engulfing with detailed descriptions. Signals get larger and brighter on high volume for strong confluence.
VWAP – Standard session Volume Weighted Average Price
Volume Histogram – Color-coded bars (easy to move to separate pane)
High-Volume Enhancement – Major signals automatically enlarge and intensify when volume confirms the move.

Perfect For:

Day traders & scalpers
Breakout & reversal strategies
Fibonacci & VWAP traders
Volume-confirmed setups

Works best on 5min, 15min, and 30min charts during US Regular Trading Hours.
One indicator. Every essential tool. Stop flipping between multiple scripts — get clean, professional-grade market structure, momentum, and confluence all in one place.
Add it now and take your intraday trading to the next level! ⚡

## Source Code

````pine
//@version=6
indicator("Daily Levels + EMA + ORB + Fib + VWAP + Vol", shorttitle="PDH Fib", overlay=true, max_lines_count=500, max_labels_count=500)

// === INPUTS ===
showPrevDay   = input.bool(true,  "Show Previous Day High/Low")
showPreMarket = input.bool(true,  "Show Pre-Market High/Low")
showCurrent   = input.bool(true,  "Show Current Day High/Low (Live)")
lineExt       = input.int(50,     "Line Extension (bars)", minval=0)

prevHighColor = color.new(color.green, 0)
prevLowColor  = color.new(color.red, 0)
pmHighColor   = color.new(color.green, 30)
pmLowColor    = color.new(color.red, 30)
currHighColor = color.new(color.green, 70)
currLowColor  = color.new(color.red, 70)

// EMA Cloud
ema9Len      = input.int(9,  "EMA 9 Length")
ema20Len     = input.int(20, "EMA 20 Length")
cloudOpacity = input.int(70, "Cloud Opacity", minval=0, maxval=100)

// ORB
orbMinutes = input.int(30, "Opening Range Minutes", minval=5, maxval=180)
showORB    = input.bool(true, "Show ORB Breakout Arrows")

// Candlestick Patterns
showPatterns = input.bool(true, "Show Candlestick Patterns")
patternSize  = input.float(1.5, "Pattern Label Size", minval=0.5, maxval=4.0)

// Fibonacci Settings
showFib      = input.bool(true, "Show 7-Day Fibonacci Retracement")
fibLevelsStr = input.string("0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0", "Fib Levels", tooltip="Comma separated: 0.0,0.236,...")

// VWAP
showVWAP     = input.bool(true, "Show VWAP")
vwapColor    = input.color(color.purple, "VWAP Color")   // Changed from violet
vwapWidth    = input.int(2, "VWAP Line Width", minval=1, maxval=5)

// Volume Settings
showVolumeHist = input.bool(true, "Show Volume Histogram (Bottom)")
volUpColor     = input.color(color.new(color.green, 0), "Volume Up Color")
volDownColor   = input.color(color.new(color.red, 0), "Volume Down Color")

// === TIME SESSIONS ===
bool newDay = timeframe.change("1D")

// Helper Functions
f_formatTime(int minutes) =>
    int h = math.floor(minutes / 60)
    int m = minutes % 60
    str.tostring(h, "00") + str.tostring(m, "00")

// === PREVIOUS DAY H/L ===
var float pdHigh = na
var float pdLow  = na
var line  pdhLine = na
var line  pdlLine = na

if newDay
    pdHigh := high[1]
    pdLow  := low[1]
    if not na(pdhLine)
        line.delete(pdhLine)
    if not na(pdlLine)
        line.delete(pdlLine)

if showPrevDay and not na(pdHigh)
    pdhLine := line.new(bar_index - 1, pdHigh, bar_index + lineExt, pdHigh, color=prevHighColor, width=2, extend=extend.right)
    pdlLine := line.new(bar_index - 1, pdLow,  bar_index + lineExt, pdLow,  color=prevLowColor,  width=2, extend=extend.right)

// === PRE-MARKET H/L ===
var float pmHigh = na
var float pmLow  = na
var line  pmhLine = na
var line  pmlLine = na

bool isPreMarket = not na(time("1", "0400-0930", "America/New_York"))

if newDay
    pmHigh := na
    pmLow  := na

if isPreMarket
    pmHigh := na(pmHigh) ? high : math.max(pmHigh, high)
    pmLow  := na(pmLow)  ? low  : math.min(pmLow,  low)

if showPreMarket and not na(pmHigh)
    pmhLine := line.new(bar_index - 1, pmHigh, bar_index + lineExt, pmHigh, color=pmHighColor, width=1, style=line.style_dashed, extend=extend.right)
    pmlLine := line.new(bar_index - 1, pmLow,  bar_index + lineExt, pmLow,  color=pmLowColor,  width=1, style=line.style_dashed, extend=extend.right)

// === CURRENT DAY LIVE H/L ===
var float currHigh = na
var float currLow  = na
var line  chLine = na
var line  clLine = na

if newDay
    currHigh := high
    currLow  := low
else
    currHigh := math.max(nz(currHigh), high)
    currLow  := math.min(nz(currLow), low)

if showCurrent and not na(currHigh)
    chLine := line.new(bar_index - 1, currHigh, bar_index + lineExt, currHigh, color=currHighColor, width=1, style=line.style_dotted, extend=extend.right)
    clLine := line.new(bar_index - 1, currLow,  bar_index + lineExt, currLow,  color=currLowColor,  width=1, style=line.style_dotted, extend=extend.right)

// === EMA 9 / 20 CLOUD ===
ema9  = ta.ema(close, ema9Len)
ema20 = ta.ema(close, ema20Len)

plot(ema9,  "EMA 9",  color=color.blue,   linewidth=2)
plot(ema20, "EMA 20", color=color.orange, linewidth=2)

fillColor = ema9 > ema20 ? color.new(color.green, cloudOpacity) : color.new(color.red, cloudOpacity)
fill(plot(ema9), plot(ema20), color=fillColor, title="EMA Cloud")

// === VWAP ===
vwapValue = ta.vwap(hlc3)
plot(showVWAP ? vwapValue : na, "VWAP", color=vwapColor, linewidth=vwapWidth)

// === VOLUME HISTOGRAM ===
avgVol = ta.sma(volume, 20)
highVol = volume > avgVol * 1.5

volColor = close > open ? volUpColor : volDownColor
plot(showVolumeHist ? volume : na, "Volume", color=volColor, style=plot.style_columns, linewidth=3)

// === OPENING RANGE BREAKOUT ===
var float orHigh = na
var float orLow  = na
var bool  inORB  = false

int startMin = 930
int endMin   = startMin + orbMinutes
string orbSession = "0930-" + f_formatTime(endMin)

bool inOpeningRange = not na(time("1", orbSession, "America/New_York"))

if inOpeningRange and not inORB
    orHigh := high
    orLow  := low
    inORB  := true
else if inOpeningRange
    orHigh := math.max(orHigh, high)
    orLow  := math.min(orLow, low)
else if inORB
    inORB := false

// Safe Breakout Detection
bullBreak = ta.crossover(high, orHigh)
bearBreak = ta.crossunder(low, orLow)

if showORB and not inORB and not na(orHigh)
    if bullBreak
        arrowSize = highVol ? size.large : size.normal
        label.new(bar_index, low - ta.tr * 0.7, "↑ ORB", color=color.new(color.lime,0), style=label.style_label_up, textcolor=color.black, size=arrowSize)
    if bearBreak
        arrowSize = highVol ? size.large : size.normal
        label.new(bar_index, high + ta.tr * 0.7, "↓ ORB", color=color.new(color.red,0), style=label.style_label_down, textcolor=color.white, size=arrowSize)

// Plot OR levels
plot(showORB and not inORB ? orHigh : na, "ORB High", color=color.new(color.green, 60), style=plot.style_linebr)
plot(showORB and not inORB ? orLow  : na, "ORB Low",  color=color.new(color.red, 60),   style=plot.style_linebr)

// === CANDLESTICK PATTERNS ===
body      = math.abs(close - open)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
isBull    = close > open
isBear    = close < open

bullHammer   = lowerWick >= 2 * body and upperWick <= body * 0.5 and body > 0 and isBull
shootingStar = upperWick >= 2 * body and lowerWick <= body * 0.5 and body > 0 and isBear
bullEngulf   = isBear[1] and isBull and close > open[1] and open < close[1]
bearEngulf   = isBull[1] and isBear and close < open[1] and open > close[1]

if showPatterns
    int patternCount = (bullHammer ? 1 : 0) + (shootingStar ? 1 : 0) + (bullEngulf ? 1 : 0) + (bearEngulf ? 1 : 0)
    bool strongSignal = patternCount >= 1 and highVol
    
    if bullHammer
        txt = "HAMMER\nBullish Reversal\nBuyers rejected lower prices"
        lblSize = strongSignal ? size.large : size.normal
        label.new(bar_index, low - ta.tr * 1.0, txt, style=label.style_label_up, color=color.new(color.green, 10), textcolor=color.white, size=lblSize, yloc=yloc.belowbar)
    
    if shootingStar
        txt = "SHOOTING STAR\nBearish Reversal\nSellers rejected higher prices"
        lblSize = strongSignal ? size.large : size.normal
        label.new(bar_index, high + ta.tr * 1.0, txt, style=label.style_label_down, color=color.new(color.red, 10), textcolor=color.white, size=lblSize, yloc=yloc.abovebar)
    
    if bullEngulf
        txt = "BULL ENGULFING\nStrong Bullish Reversal\nBuyers overwhelmed sellers"
        lblSize = strongSignal ? size.large : size.normal
        label.new(bar_index, low - ta.tr * 1.2, txt, style=label.style_label_up, color=color.new(color.lime, 0), textcolor=color.black, size=lblSize, yloc=yloc.belowbar)
    
    if bearEngulf
        txt = "BEAR ENGULFING\nStrong Bearish Reversal\nSellers overwhelmed buyers"
        lblSize = strongSignal ? size.large : size.normal
        label.new(bar_index, high + ta.tr * 1.2, txt, style=label.style_label_down, color=color.new(color.maroon, 0), textcolor=color.white, size=lblSize, yloc=yloc.abovebar)

// === 7-DAY FIBONACCI RETRACEMENT ===
var line[] fibLines = array.new<line>()

if newDay
    for i = 0 to array.size(fibLines) - 1
        line.delete(array.get(fibLines, i))
    array.clear(fibLines)

    // Extract calls for consistency
    float dailyHigh = ta.highest(high, 7)
    float dailyLow  = ta.lowest(low, 7)
    float sevenDayHigh = request.security(syminfo.tickerid, "1D", dailyHigh)
    float sevenDayLow  = request.security(syminfo.tickerid, "1D", dailyLow)

    if showFib and not na(sevenDayHigh) and not na(sevenDayLow)
        float fibRange = sevenDayHigh - sevenDayLow
        array<string> levels = str.split(fibLevelsStr, ",")
        
        for i = 0 to array.size(levels) - 1
            float lvl = str.tonumber(str.trim(array.get(levels, i)))
            if not na(lvl)
                float price = sevenDayLow + fibRange * lvl
                
                color fibColor = lvl == 0.0 or lvl == 1.0 ? color.new(color.yellow, 0) :
                               lvl == 0.236 ? color.new(color.fuchsia, 20) :
                               lvl == 0.382 ? color.new(color.aqua, 20) :
                               lvl == 0.5 ? color.new(color.white, 20) :
                               lvl == 0.618 ? color.new(color.orange, 20) :
                               lvl == 0.786 ? color.new(color.purple, 20) : color.new(color.gray, 40)
                
                line fibLine = line.new(bar_index - 1, price, bar_index + lineExt * 3, price, 
                                       color = fibColor, width = 1, style = line.style_dotted, extend = extend.right)
                array.push(fibLines, fibLine)

plot(showFib ? request.security(syminfo.tickerid, "1D", ta.highest(high, 7)) : na, "7D High", color=color.new(color.yellow, 40), style=plot.style_linebr)
plot(showFib ? request.security(syminfo.tickerid, "1D", ta.lowest(low, 7))  : na, "7D Low",  color=color.new(color.yellow, 40), style=plot.style_linebr)
````
