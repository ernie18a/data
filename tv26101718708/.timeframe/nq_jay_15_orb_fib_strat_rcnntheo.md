# NQ JAY 15 ORB + Fib Strat

- url: https://www.tradingview.com/script/RcnNtheO-NQ-JAY-15-ORB-Fib-Strat/
- type: indicator
- pine_id: PUB;acdb0743f39b4add9cd2566b7c6b863c
- version: 1.0

## Description

**NQ JAY 15 ORB + Fib Strategy**

The **NQ JAY 15 ORB + Fib Strategy** is an intraday trading indicator designed primarily for **Nasdaq Futures (NQ/MNQ)** during the New York session.

The indicator combines the **9:30–9:45 AM New York Opening Range** with Fibonacci retracement levels, rejection confirmation, and higher-timeframe liquidity targets to help identify structured long and short setups.

### Key Features

• **15-Minute Opening Range (ORB)**  
Automatically marks the high and low created between **9:30 AM and 9:45 AM EST**.

• **Automatic Fibonacci Levels**  
Plots the key **50%, 60%, and 70% retracement levels** from the opening range to highlight potential entry and reaction zones.

• **Long & Short Trade Signals**  
Looks for price to retrace into the designated Fibonacci area before producing potential bullish or bearish setups.

• **Candle Confirmation**  
Optional confirmation requires a bullish or bearish rejection candle before a signal is generated.

• **60% Level Confirmation**  
An optional filter can require price to close through the 60% Fibonacci level, helping reduce lower-quality setups.

• **1-Hour High & Low Targets**  
Displays higher-timeframe highs and lows as potential liquidity targets and areas where price may be drawn toward.

• **Customizable Display**  
Traders can individually enable or disable the ORB box, Fibonacci levels, targets, and trade signals.

### Strategy Concept

After

## Source Code

````pine
//@version=6
indicator("NQ JAY 15 ORB + Fib Strat", overlay=true, max_boxes_count=50, max_lines_count=100, max_labels_count=100)

// ─────────────────────────────────────
// INPUTS
// ─────────────────────────────────────
orbSession      = input.session("0930-0945", "NY ORB Session")
timeZone        = input.string("America/New_York", "Timezone")

showOrbBox      = input.bool(true, "Show ORB Box")
showFibLevels   = input.bool(true, "Show 50 / 60 / 70 Fib")
showTargets     = input.bool(true, "Show 1H High / Low Targets")
showSignals     = input.bool(true, "Show Long / Short Signals")

requireCandle   = input.bool(true, "Require Bull/Bear Rejection Candle")
requireMidClose = input.bool(true, "Require Close Through 60%")

fib50 = 0.50
fib60 = 0.60
fib70 = 0.70

// ─────────────────────────────────────
// SESSION LOGIC
// ─────────────────────────────────────
inOrb = not na(time(timeframe.period, orbSession, timeZone))

newOrbSession = inOrb and not inOrb[1]
orbEnded      = not inOrb and inOrb[1]

// ─────────────────────────────────────
// ORB VARIABLES
// ─────────────────────────────────────
var float orbHigh = na
var float orbLow  = na
var bool orbReady = false

var box orbBox = na

if newOrbSession
    orbHigh := high
    orbLow  := low
    orbReady := false

    if not na(orbBox)
        box.delete(orbBox)

    if showOrbBox
        orbBox := box.new(
             left=bar_index,
             top=high,
             right=bar_index,
             bottom=low,
             bgcolor=color.new(color.gray, 88),
             border_color=color.new(color.white, 45)
         )

if inOrb
    orbHigh := math.max(nz(orbHigh, high), high)
    orbLow  := math.min(nz(orbLow, low), low)

    if showOrbBox and not na(orbBox)
        box.set_top(orbBox, orbHigh)
        box.set_bottom(orbBox, orbLow)
        box.set_right(orbBox, bar_index)

if orbEnded
    orbReady := true

// extend box after formation
if orbReady and showOrbBox and not na(orbBox)
    box.set_right(orbBox, bar_index)

// ─────────────────────────────────────
// BREAKOUT DIRECTION
// ─────────────────────────────────────
var int breakoutDir = 0
//  1 = bullish
// -1 = bearish

var bool breakoutTriggered = false

if newOrbSession
    breakoutDir := 0
    breakoutTriggered := false

bullBreak = orbReady and breakoutDir == 0 and close > orbHigh
bearBreak = orbReady and breakoutDir == 0 and close < orbLow

if bullBreak
    breakoutDir := 1
    breakoutTriggered := true

if bearBreak
    breakoutDir := -1
    breakoutTriggered := true

// ─────────────────────────────────────
// FIB CALCULATIONS
// ─────────────────────────────────────
orbRange = orbHigh - orbLow

// Bullish:
// 0 = ORB high
// 1 = ORB low
bullFib50 = orbHigh - orbRange * fib50
bullFib60 = orbHigh - orbRange * fib60
bullFib70 = orbHigh - orbRange * fib70

// Bearish:
// 0 = ORB low
// 1 = ORB high
bearFib50 = orbLow + orbRange * fib50
bearFib60 = orbLow + orbRange * fib60
bearFib70 = orbLow + orbRange * fib70

// Active Fib levels depending on breakout
active50 = breakoutDir == 1 ? bullFib50 : breakoutDir == -1 ? bearFib50 : na
active60 = breakoutDir == 1 ? bullFib60 : breakoutDir == -1 ? bearFib60 : na
active70 = breakoutDir == 1 ? bullFib70 : breakoutDir == -1 ? bearFib70 : na

// ─────────────────────────────────────
// PLOT ORB
// ─────────────────────────────────────
plot(orbReady ? orbHigh : na, "ORB High", color=color.new(color.green, 0), linewidth=2, style=plot.style_linebr)
plot(orbReady ? orbLow : na, "ORB Low", color=color.new(color.red, 0), linewidth=2, style=plot.style_linebr)

// ─────────────────────────────────────
// PLOT FIB
// ─────────────────────────────────────
p50 = plot(showFibLevels ? active50 : na, "Fib 50", color=color.new(color.yellow, 0), linewidth=1, style=plot.style_linebr)
p60 = plot(showFibLevels ? active60 : na, "Fib 60", color=color.new(color.orange, 0), linewidth=2, style=plot.style_linebr)
p70 = plot(showFibLevels ? active70 : na, "Fib 70", color=color.new(color.red, 0), linewidth=1, style=plot.style_linebr)

fill(p50, p70, color=color.new(color.orange, 88), title="50-70 Retracement Zone")

// ─────────────────────────────────────
// RETRACEMENT DETECTION
// ─────────────────────────────────────
bullInZone =
     breakoutDir == 1 and
     low <= bullFib50 and
     high >= bullFib70

bearInZone =
     breakoutDir == -1 and
     high >= bearFib50 and
     low <= bearFib70

bullCandle = close > open
bearCandle = close < open

bullMidConfirm = close > bullFib60
bearMidConfirm = close < bearFib60

bullReject =
     bullInZone and
     (not requireCandle or bullCandle) and
     (not requireMidClose or bullMidConfirm)

bearReject =
     bearInZone and
     (not requireCandle or bearCandle) and
     (not requireMidClose or bearMidConfirm)

// prevent repeated signals
var bool longTaken  = false
var bool shortTaken = false

if newOrbSession
    longTaken := false
    shortTaken := false

longSignal = bullReject and not longTaken
shortSignal = bearReject and not shortTaken

if longSignal
    longTaken := true

if shortSignal
    shortTaken := true

// ─────────────────────────────────────
// 1H TARGETS
// ─────────────────────────────────────
oneHourHigh = request.security(syminfo.tickerid, "60", high[1], lookahead=barmerge.lookahead_off)
oneHourLow  = request.security(syminfo.tickerid, "60", low[1], lookahead=barmerge.lookahead_off)

plot(showTargets ? oneHourHigh : na, "Previous 1H High", color=color.new(color.aqua, 25), linewidth=1, style=plot.style_linebr)
plot(showTargets ? oneHourLow : na, "Previous 1H Low", color=color.new(color.fuchsia, 25), linewidth=1, style=plot.style_linebr)

// ─────────────────────────────────────
// SIGNALS
// ─────────────────────────────────────
plotshape(
     showSignals and longSignal,
     title="Long Signal",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     text="LONG",
     textcolor=color.white,
     size=size.small
)

plotshape(
     showSignals and shortSignal,
     title="Short Signal",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="SHORT",
     textcolor=color.white,
     size=size.small
)

// Breakout markers
plotshape(
     bullBreak,
     title="Bullish ORB Break",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.new(color.green, 0),
     size=size.tiny,
     text="ORB"
)

plotshape(
     bearBreak,
     title="Bearish ORB Break",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.new(color.red, 0),
     size=size.tiny,
     text="ORB"
)

// ─────────────────────────────────────
// ALERTS
// ─────────────────────────────────────
alertcondition(
     bullBreak,
     title="Bullish ORB Breakout",
     message="NQ JAY: Bullish ORB breakout detected."
)

alertcondition(
     bearBreak,
     title="Bearish ORB Breakout",
     message="NQ JAY: Bearish ORB breakout detected."
)

alertcondition(
     longSignal,
     title="NQ JAY Long Setup",
     message="NQ JAY LONG: Bullish ORB breakout + 50/60/70 retracement rejection."
)

alertcondition(
     shortSignal,
     title="NQ JAY Short Setup",
     message="NQ JAY SHORT: Bearish ORB breakout + 50/60/70 retracement rejection."
)
````
