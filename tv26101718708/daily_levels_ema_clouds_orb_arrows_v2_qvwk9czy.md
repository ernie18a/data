# Daily Levels + EMA Clouds + ORB Arrows V2

- url: https://www.tradingview.com/script/QVWk9czy-Daily-Levels-EMA-Clouds-ORB-Arrows-V2/
- type: indicator
- pine_id: PUB;3df9a1ab93774e33895af4b90c260c94
- version: 1.0

## Description

Daily Levels + EMA Clouds + ORB Arrows
This powerful intraday indicator combines key market structure levels with dynamic momentum visualization and Opening Range Breakout signals.
Key Features:

Previous Day High & Low — Solid, bold green (high) and red (low) lines for clear reference to the prior session's extremes.
Pre-Market High & Low — Lighter green/red dashed lines showing today's pre-market (4:00–9:30 ET) range.
Current Day Live High & Low (HOD/LOD) — Very light green/red dotted lines that update in real-time with the developing high and low of the current session.
EMA 9 & 20 Cloud — Plots the 9-period and 20-period Exponential Moving Averages with a filled cloud between them. The cloud turns green when EMA 9 is above EMA 20 (bullish bias) and red when below (bearish bias).
Opening Range Breakout (ORB) Arrows — Automatically detects your chosen opening range (default 30 minutes after 9:30 ET) and plots clear green ↑ arrows below candles on bullish breakouts and red ↓ arrows above candles on bearish breakouts.

Customization Options:

Toggle each level group on/off (Previous Day, Pre-Market, Current Day)
Adjust line extension length
Change EMA lengths and cloud opacity
Set custom Opening Range duration (5–120+ minutes)
Enable/disable ORB arrows and OR level plots

Best Used On:

1min, 3min, 5min, 15min charts (intraday)
US equities, futures, and forex during RTH (Regular Trading Hours)

Perfect for day traders, scalpers, and momentum traders who rely on daily levels, pre-market structure, and opening range breakouts for high-probability setups.
Time Zone: Built for America/New_York (standard US market hours). Lines and sessions automatically reset on new trading days.

## Source Code

````pine
//@version=6
indicator("Daily Levels + EMA Clouds + ORB Arrows", shorttitle="PDH/PMH/CHL + EMA9/20 + ORB", overlay=true, max_lines_count=500, max_labels_count=500)

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

// === TIME SESSIONS ===
bool newDay = timeframe.change("1D")

// Helper to format time string (e.g., 960 → "1000")
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

// Breakout arrows
if showORB and not inORB and not na(orHigh)
    if ta.crossover(high, orHigh)
        label.new(bar_index, low - ta.tr * 0.5, "↑", color=color.new(color.green,0), style=label.style_label_up, textcolor=color.white, size=size.normal)
    if ta.crossunder(low, orLow)
        label.new(bar_index, high + ta.tr * 0.5, "↓", color=color.new(color.red,0), style=label.style_label_down, textcolor=color.white, size=size.normal)

// Plot OR levels
plot(showORB and not inORB ? orHigh : na, "ORB High", color=color.new(color.green, 60), style=plot.style_linebr)
plot(showORB and not inORB ? orLow  : na, "ORB Low",  color=color.new(color.red, 60),   style=plot.style_linebr)
````
