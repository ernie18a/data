# B&R ORB (Clean Signals)

- url: https://www.tradingview.com/script/kDBGrrAO-B-R-ORB-Clean-Signals/
- type: indicator
- pine_id: PUB;441ee47c99034f29ad9f66597b08ea8e
- version: 1.0

## Description

Opening Range (ORB)
Uses:
First 3 candles on 5-minute chart OR
First 15-minute candle
These define the key intraday high and low levels
2. Breakout Detection
A valid breakout occurs when:
Price closes above ORB high (long)
Price closes below ORB low (short)
Avoids false breakouts by requiring candle close, not just wick
3. Retest Entry
After breakout:
Price must pull back to the breakout level
Must stay within a small ATR-based buffer zone
Entry is only taken when:
A rejection candle confirms continuation
4. Trend Filter
Uses EMA 20 & EMA 50
Only trades:
Longs in uptrend
Shorts in downtrend
5. Time Filter
Trades only during:
🕘 9:30 AM – 12:05 PM (market hours)
Avoids:
Midday chop
Low-volume conditions
📈 Signals
🔺 Break Signals → Mark initial breakout
🟢 LONG Label → Break + retest + bullish confirmation
🔴 SHORT Label → Break + retest + bearish confirmation
⚡ Key Features
Filters out weak breakouts
Focuses on liquidity-based retests
Reduces overtrading
Works best in trending market conditions
Clean and minimal signals (no clutter)
⚠️ Notes
This is a signal indicator, not a full strategy
Entries are shown, but:
Stop loss and targets should be managed manually
Best used with:
Market structure
Liquidity zones
Volume confirmation
🔥 Best Use Case
Stocks like NVDA, TSLA, SPY
Timeframes:
1 min (entry)
5 min (structure)
Strategy type:
Break & Retest
Momentum continuation

## Source Code

````pine
//@version=5
indicator("B&R ORB (Clean Signals)", overlay=true)

// ===== Inputs =====
use5mORB   = input.bool(true,  "Use first 3 candles on 5m")
use15mORB  = input.bool(true,  "Use first candle on 15m")
emaFastLen = input.int(20, "EMA Fast")
emaSlowLen = input.int(50, "EMA Slow")
atrLen     = input.int(14, "ATR")
bufMult    = input.float(0.15, "Retest buffer ATR", step=0.01)
maxBarsRet = input.int(8, "Max bars for retest")

// ===== Session =====
inSession = not na(time(timeframe.period, "0930-1205"))
newDay    = ta.change(time("D")) != 0

// ===== EMAs =====
emaF = ta.ema(close, emaFastLen)
emaS = ta.ema(close, emaSlowLen)
plot(emaF, "EMA Fast", color=color.aqua)
plot(emaS, "EMA Slow", color=color.purple)

// ===== Day state =====
var int barsToday = 0
if newDay
    barsToday := 0
barsToday += 1

// ===== ORB =====
var float orbH = na
var float orbL = na
var bool  orbReady = false

is5m  = timeframe.period == "5"
is15m = timeframe.period == "15"

if newDay
    orbH := na
    orbL := na
    orbReady := false

if is5m and use5mORB and not orbReady
    orbH := na(orbH) ? high : math.max(orbH, high)
    orbL := na(orbL) ? low  : math.min(orbL, low)
    if barsToday >= 3
        orbReady := true

if is15m and use15mORB and not orbReady
    orbH := na(orbH) ? high : orbH
    orbL := na(orbL) ? low  : orbL
    if barsToday >= 1
        orbReady := true

plot(orbReady ? orbH : na, "ORB High", color=color.new(color.green, 20), style=plot.style_linebr)
plot(orbReady ? orbL : na, "ORB Low",  color=color.new(color.red, 20),   style=plot.style_linebr)

// ===== Break state =====
var bool  waitL = false
var bool  waitS = false
var float lvlL  = na
var float lvlS  = na
var int   barL  = na
var int   barS  = na

bull = close > emaF and close > emaS
bear = close < emaF and close < emaS

longBreak  = inSession and orbReady and bull and close > orbH and close[1] <= orbH
shortBreak = inSession and orbReady and bear and close < orbL and close[1] >= orbL

if longBreak
    waitL := true
    waitS := false
    lvlL  := orbH
    barL  := bar_index

if shortBreak
    waitS := true
    waitL := false
    lvlS  := orbL
    barS  := bar_index

if waitL and (bar_index - barL > maxBarsRet)
    waitL := false
if waitS and (bar_index - barS > maxBarsRet)
    waitS := false

// ===== Retest + rejection =====
buf = ta.atr(atrLen) * bufMult

touchL = waitL and low <= lvlL + buf and low >= lvlL - buf
touchS = waitS and high >= lvlS - buf and high <= lvlS + buf

bullRej = close > open and close > lvlL
bearRej = close < open and close < lvlS

longSig  = inSession and touchL and bullRej and bull
shortSig = inSession and touchS and bearRej and bear

plotshape(longBreak,  "Break L",  shape.triangleup,   location.belowbar, color=color.lime, size=size.tiny, text="BRK")
plotshape(shortBreak, "Break S",  shape.triangledown, location.abovebar, color=color.red,  size=size.tiny, text="BRK")

plotshape(longSig,  "LONG",  shape.labelup,   location.belowbar, color=color.green,  text="LONG")
plotshape(shortSig, "SHORT", shape.labeldown, location.abovebar, color=color.maroon, text="SHORT")
````
