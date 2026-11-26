# Custom EMA Structure break + Dual ORB + VWAP

- url: https://www.tradingview.com/script/SpW0zJK3-Custom-EMA-Structure-break-Dual-ORB-VWAP/
- type: indicator
- pine_id: PUB;51c8c9d966c145b18c544b5855eeac21
- version: 1.0

## Description

If you want everything in 1 indicator instead of swapping Indicatiors this it for you.

*Built In EMA's (4 total) with custom selection to fit your style
*VWAP
*ORB x 2 (Set times and toggle on/off)
     - Note: Make sure time selection matches with your chart time, This is set to Eastern time, but will not respect daylight savings.

I use this in a different style. I pair this with the NY Opening Orb for any instrument but I don't enter on cross... It's too late. 

 I specifically use the 9, 21 or 35, 50 and 200 along with Vwap. I look back and find out where price is respecting a specific EMA. Once I know where the respect is, I also not that above the 35 is small frame uptrend and below is small frame downtrend (Look @ CM EMA Trend Bars by Chris Moody as reference.)

Ill use the 5 min chart and enter on candle cross and close above/below an EMA. I'll stay in the trade as long as the price is respecting EMA9. Example would be to stay in on a "long" when the price action is staying above the 9. Once Price action crosses the 9, that's your exit. 

A+ trades occur when VWAP and EMA200 are sloped in the same direction.

Use the Dots as reference for entries/Exits.

## Source Code

````pine
//@version=6
indicator('Custom EMA Structure break + Dual ORB + VWAP', overlay = true)

// ───── EMA INPUTS ─────
emaFastLen = input.int(9, 'Fast EMA', minval = 1)
emaMidLen = input.int(21, 'Mid EMA', minval = 1)
emaTrendLen = input.int(50, 'Trend EMA', minval = 1)
emaSlowLen = input.int(200, 'Slow EMA', minval = 1)

// ───── VWAP TOGGLE ─────
showVWAP = input.bool(true, 'Show VWAP')

// ───── EMAs ─────
emaFast = ta.ema(close, emaFastLen)
emaMid = ta.ema(close, emaMidLen)
emaTrend = ta.ema(close, emaTrendLen)
emaSlow = ta.ema(close, emaSlowLen)

// ───── VWAP ─────
vwap = ta.vwap(hlc3)

// ───── PLOTS ─────
plot(emaFast, color = color.new(color.blue, 60), linewidth = 2)
plot(emaMid, color = color.purple, linewidth = 2)
plot(emaTrend, color = color.yellow, linewidth = 2)
plot(emaSlow, color = color.white, linewidth = 2)

plot(showVWAP ? vwap : na, color = color.orange, linewidth = 2)

// ───── STRUCTURE STATE ─────
var bool longArmed = true
var bool shortArmed = true

if close > emaFast
    longArmed := true
    longArmed

if close < emaFast
    shortArmed := true
    shortArmed

// ───── CANDLE FILTER ─────
atr = ta.atr(14)
body = math.abs(close - open)
strongCandle = body > atr * 0.5

// ───── TREND FILTER ─────
allowLong = close > emaTrend
allowShort = close < emaTrend

// ───── LONGS ─────
longMid = longArmed and allowLong and close > emaMid and close[1] <= emaMid

longTrend = longArmed and allowLong and close > emaTrend and close[1] <= emaTrend

longSlow = longArmed and allowLong and close > emaSlow and close[1] <= emaSlow

longSignal = longMid or longTrend or longSlow

// ───── SHORTS ─────
shortMid = shortArmed and allowShort and close < emaMid and close[1] >= emaMid

shortTrend = shortArmed and allowShort and close < emaTrend and close[1] >= emaTrend

shortSlow = shortArmed and allowShort and close < emaSlow and close[1] >= emaSlow

shortSignal = shortMid or shortTrend or shortSlow

// ───── STRONG BODY REQUIRED ─────
longSignal := longSignal and strongCandle
shortSignal := shortSignal and strongCandle

// ───── DISARM AFTER SIGNAL ─────
if longSignal
    longArmed := false
    longArmed

if shortSignal
    shortArmed := false
    shortArmed

// ───── SIGNALS ─────
plotshape(longSignal, style = shape.circle, location = location.belowbar, color = color.green, size = size.tiny)
plotshape(shortSignal, style = shape.circle, location = location.abovebar, color = color.red, size = size.tiny)


//─────────────────────────────────────────────
// 🔷 DUAL ORB
//─────────────────────────────────────────────

// ───── TOGGLES ─────
showORB1 = input.bool(true, 'Enable ORB 1')
showORB2 = input.bool(true, 'Enable ORB 2')

// ───── SESSIONS ─────
orb1Session = input.session('1800-1815', 'ORB 1 Session')
orb2Session = input.session('0930-0945', 'ORB 2 Session')

inORB1 = not na(time(timeframe.period, orb1Session))
inORB2 = not na(time(timeframe.period, orb2Session))

// ───── ORB 1 ─────
var float orb1High = na
var float orb1Low = na

if inORB1 and not inORB1[1]
    orb1High := high
    orb1Low := low
    orb1Low

if inORB1
    orb1High := math.max(orb1High, high)
    orb1Low := math.min(orb1Low, low)
    orb1Low

// ───── ORB 2 ─────
var float orb2High = na
var float orb2Low = na

if inORB2 and not inORB2[1]
    orb2High := high
    orb2Low := low
    orb2Low

if inORB2
    orb2High := math.max(orb2High, high)
    orb2Low := math.min(orb2Low, low)
    orb2Low


// ───── ORB PLOTS (WITH SHADING) ─────
orb1HighPlot = plot(showORB1 ? orb1High : na, color = color.new(color.green, 0), linewidth = 1)
orb1LowPlot = plot(showORB1 ? orb1Low : na, color = color.new(color.green, 60), linewidth = 1)

orb2HighPlot = plot(showORB2 ? orb2High : na, color = color.new(color.red, 0), linewidth = 1)
orb2LowPlot = plot(showORB2 ? orb2Low : na, color = color.new(color.red, 60), linewidth = 1)

// ───── ORB SHADING ─────
fill(orb1HighPlot, orb1LowPlot, color = color.new(color.green, 90))
fill(orb2HighPlot, orb2LowPlot, color = color.new(color.red, 90))


// ───── ALERTS ─────
alertcondition(longSignal, title = 'Long Signal', message = 'EMA Structure LONG signal')
alertcondition(shortSignal, title = 'Short Signal', message = 'EMA Structure SHORT signal')
````
