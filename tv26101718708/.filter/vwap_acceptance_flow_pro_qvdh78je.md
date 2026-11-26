# VWAP Acceptance Flow PRO

- url: https://www.tradingview.com/script/qVdH78JE/
- type: indicator
- pine_id: PUB;265e81d34e684b39a9823c98066f4149
- version: 3.0

## Description

VWAP Acceptance Flow PRO

VWAP Acceptance Flow PRO is a multi-timeframe flow oscillator designed to measure market acceptance around a rolling VWAP. Instead of tracking price alone, the indicator evaluates whether the market is accepting or rejecting value and combines this information into a clean flow model optimized for fast-moving markets such as NASDAQ.

The indicator provides a real-time view of short-term flow, higher-timeframe alignment, momentum shifts, pullbacks, and re-acceptance signals.

CORE CONCEPT

Markets constantly move between two states:

• Acceptance → price is accepted above or below fair value.
• Rejection → price fails to hold value and rotates back.

VWAP Acceptance Flow PRO quantifies this process by combining:

1. Distance from VWAP
2. Velocity of VWAP displacement
3. Acceptance duration
4. VWAP slope

The result is a normalized flow engine that visualizes whether buyers or sellers are gaining control.

COMPONENTS

Chart Flow

The fastest flow line.

Measures current market pressure and reacts quickly to shifts in acceptance.

• Above zero = bullish acceptance
• Below zero = bearish acceptance
• Rising = increasing momentum
• Falling = weakening momentum

X5 Flow

Intermediate flow filter.

Represents the dominant short-term trend and helps remove noise from the Chart Flow.

• Above zero = bullish environment
• Below zero = bearish environment

X15 Flow

Institutional flow filter.

Represents the broader market bias.

This is the slowest and most stable component of the system.

• Positive = higher-timeframe buyers in control
• Negative = higher-timeframe sellers in control

ACCEPTANCE HISTOGRAM

The histogram displays:

Chart Flow − X5 Flow

This measures short-term acceleration relative to the dominant trend.

Green Histogram

• Bullish acceleration
• Momentum expanding
• Buyers gaining control

Red Histogram

• Bearish acceleration
• Momentum weakening
• Sellers gaining control

DYNAMIC ACCEPTANCE BANDS

The upper and lower bands are calculated from the average absolute flow value.

They adapt automatically to market volatility.

Inside Bands

• Normal market activity

Outside Bands

• Extreme acceptance conditions
• Trend extension
• Potential exhaustion
• Possible mean reversion

PULLBACK RADAR

The background highlights pullback opportunities inside strong trends.

Yellow Background

Bullish pullback.

Conditions:

• X15 Flow > 0
• X5 Flow > 0
• Chart Flow < 0

The larger trend remains bullish while short-term flow temporarily weakens.

Purple Background

Bearish pullback.

Conditions:

• X15 Flow < 0
• X5 Flow < 0
• Chart Flow > 0

The larger trend remains bearish while short-term flow temporarily rebounds.

RE-ACCEPTANCE SIGNALS

Signals occur when Chart Flow crosses X5 Flow.

Long Signal

Condition:

• Chart Flow crosses above X5 Flow

Interpretation:

Short-term acceptance is returning in favor of buyers.

Short Signal

Condition:

• Chart Flow crosses below X5 Flow

Interpretation:

Short-term acceptance is returning in favor of sellers.

These signals are designed to identify re-entry opportunities after pullbacks and consolidations.

FLOW SCORE

The Flow Score measures directional alignment across all three flow layers.

Range: -3 to +3

+3

• Strong bullish alignment
• All flow lines above zero

+2

• Bullish bias

+1

• Weak bullish bias

0

• Neutral market

-1

• Weak bearish bias

-2

• Bearish bias

-3

• Strong bearish alignment
• All flow lines below zero

ACCEPTANCE SCORE

The Acceptance Score measures the overall strength of market participation.

Range: 0–100

Low Values

• Weak conviction
• Choppy conditions
• Poor acceptance

High Values

• Strong conviction
• Trend continuation environment
• High-quality directional movement

The Acceptance Score can be used as a confidence filter for trade selection.

TRADING IDEAS

Trend Following

Look for:

• X15 Flow above zero
• X5 Flow above zero
• Flow Score = +2 or +3

Use bullish pullbacks and long re-acceptance signals as entry opportunities.

Short Selling

Look for:

• X15 Flow below zero
• X5 Flow below zero
• Flow Score = -2 or -3

Use bearish pullbacks and short re-acceptance signals as entry opportunities.

Momentum Expansion

Strong momentum often occurs when:

• Histogram expands rapidly
• Acceptance Score rises
• Flow Score reaches extreme alignment

This combination frequently appears during trend continuation phases.

BEST MARKETS

• NASDAQ
• Index Futures
• High-Volume Stocks
• ETFs
• Cryptocurrency Markets

Recommended Timeframes:

• 1 Minute
• 2 Minute
• 5 Minute
• 15 Minute

SUMMARY

VWAP Acceptance Flow PRO transforms VWAP behavior into a complete market-flow model. By combining acceptance, momentum, trend alignment, pullback detection, and re-acceptance signals, it helps traders identify when markets are building conviction and when higher-probability trend opportunities are emerging.

## Source Code

````pine
//@version=6
indicator("VWAP Acceptance Flow PRO", shorttitle="VAF PRO", overlay=false)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━

vwapLen  = input.int(55, "VWAP Length", minval=5)

chartLen = input.int(8, "Chart Flow")
x5Len    = input.int(40, "X5 Flow")
x15Len   = input.int(120, "X15 Flow")

bandLen  = input.int(50, "Band Length")
bandMult = input.float(1.5, "Band Multiplier", step=0.1)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TREND TRIGGER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━

enableTrendTrigger = input.bool(true, "Trend Continuation Signale")
triggerLen         = input.int(4, "Trigger EMA", minval=2, maxval=20)
showTriggerLine    = input.bool(true, "Trigger Linie anzeigen")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ROLLING VWAP
//━━━━━━━━━━━━━━━━━━━━━━━━━━━

pv = ta.sma(close * volume, vwapLen) * vwapLen
vv = ta.sma(volume, vwapLen) * vwapLen

rvwap = vv > 0 ? pv / vv : close

//━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ACCEPTANCE ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━

atr = ta.atr(14)

dist = atr > 0 ? (close - rvwap) / atr : 0.0

velocity = ta.ema(dist - dist[1], 5)

var float acceptCount = 0.0

if close > rvwap
    acceptCount := math.min(50, nz(acceptCount[1]) + 1)
else
    acceptCount := math.max(-50, nz(acceptCount[1]) - 1)

acceptNorm = acceptCount / 10.0

slope = atr > 0 ? (rvwap - rvwap[5]) / atr : 0.0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ACCEPTANCE FLOW
//━━━━━━━━━━━━━━━━━━━━━━━━━━━

rawFlow = dist * 0.40 + velocity * 0.30 + acceptNorm * 0.20 + slope * 0.10

//━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FLOW LINES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━

flowChart = ta.ema(rawFlow, chartLen)
flowX5    = ta.ema(rawFlow, x5Len)
flowX15   = ta.ema(rawFlow, x15Len)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CHART FLOW TRIGGER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━

flowTrigger = ta.ema(flowChart, triggerLen)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HISTOGRAM
//━━━━━━━━━━━━━━━━━━━━━━━━━━━

hist = flowChart - flowX5

//━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DYNAMIC BANDS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━

avgFlow = ta.ema(math.abs(flowChart), bandLen)

upper = avgFlow * bandMult
lower = -avgFlow * bandMult
//━━━━━━━━━━━━━━━━━━━
// PULLBACK RADAR
//━━━━━━━━━━━━━━━━━━━

longPB = flowX15 > 0 and flowX5 > 0 and flowChart < 0
shortPB = flowX15 < 0 and flowX5 < 0 and flowChart > 0

bgcolor(longPB ? color.new(color.yellow, 92) : na)
bgcolor(shortPB ? color.new(color.purple, 92) : na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FLOW SCORE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━

score = (flowChart > 0 ? 1 : -1) + (flowX5 > 0 ? 1 : -1) + (flowX15 > 0 ? 1 : -1)
//━━━━━━━━━━━━━━━━━━━
// ACCEPTANCE SCORE
//━━━━━━━━━━━━━━━━━━━

scoreRaw = math.abs(flowChart) * 0.40 + math.abs(flowX5) * 0.30 + math.abs(flowX15) * 0.30

acceptScore = math.min(100.0, scoreRaw * 25.0)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COLORS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━

histColor = hist >= 0 ? color.lime : color.red

chartColor = flowChart >= flowChart[1] ? color.aqua : color.orange

x5Color = flowX5 >= flowX5[1] ? color.yellow : color.rgb(255,140,0)

x15Color = flowX15 >= flowX15[1] ? color.white : color.silver
//━━━━━━━━━━━━━━━━━━━
// RE-ACCEPTANCE
//━━━━━━━━━━━━━━━━━━━

longSignal = ta.crossover(flowChart, flowX5)
shortSignal = ta.crossunder(flowChart, flowX5)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CONTINUATION SIGNALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━

triggerLongCross  = ta.crossover(flowChart, flowTrigger)
triggerShortCross = ta.crossunder(flowChart, flowTrigger)

trendLong =
     enableTrendTrigger and
     flowX15 > 0 and
     flowX5 > 0 and
     triggerLongCross and
     flowChart > flowChart[1]

trendShort =
     enableTrendTrigger and
     flowX15 < 0 and
     flowX5 < 0 and
     triggerShortCross and
     flowChart < flowChart[1]
//━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━

hline(0, "Zero", color=color.gray)

u = plot(upper, "Upper", color=color.new(color.green, 70))
l = plot(lower, "Lower", color=color.new(color.red, 70))

fill(u, l, color=color.new(color.gray, 92))

plot(
     hist,
     title="Acceptance Histogram",
     style=plot.style_histogram,
     color=histColor,
     linewidth=2)

plot(
     flowChart,
     title="Chart Flow",
     color=chartColor,
     linewidth=2)

plot(
     showTriggerLine ? flowTrigger : na,
     title="Flow Trigger",
     color=color.fuchsia,
     linewidth=1)

plot(
     flowX5,
     title="X5 Flow",
     color=x5Color,
     linewidth=2)

plot(
     flowX15,
     title="X15 Flow",
     color=x15Color,
     linewidth=3)

plotshape(
     longSignal ? lower * 1.15 : na,
     title="LONG",
     style=shape.triangleup,
     location=location.absolute,
     color=color.lime,
     size=size.small)

plotshape(
     shortSignal ? upper * 1.15 : na,
     title="SHORT",
     style=shape.triangledown,
     location=location.absolute,
     color=color.red,
     size=size.small)

plotshape(
     trendLong ? lower * 0.75 : na,
     title="Trend LONG",
     style=shape.circle,
     location=location.absolute,
     color=color.aqua,
     size=size.tiny)

plotshape(
     trendShort ? upper * 0.75 : na,
     title="Trend SHORT",
     style=shape.circle,
     location=location.absolute,
     color=color.orange,
     size=size.tiny)
     


//━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SCORE PANEL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━

var table t = table.new(position.top_right, 1, 1)

bg = score == 3 ? color.green :
     score == 2 ? color.new(color.green, 40) :
     score == 1 ? color.new(color.green, 70) :
     score == 0 ? color.gray :
     score == -1 ? color.new(color.red, 70) :
     score == -2 ? color.new(color.red, 40) :
     color.red

if barstate.islast
    table.cell(
         t,
         0,
         0,
         "FLOW " + str.tostring(score) + "\nACC " + str.tostring(math.round(acceptScore)),
         bgcolor=bg,
         text_color=color.white)
````
