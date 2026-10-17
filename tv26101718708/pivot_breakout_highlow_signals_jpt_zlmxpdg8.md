# Pivot Breakout High&Low Signals [JPT]

- url: https://www.tradingview.com/script/ZlMxpDG8-Pivot-Breakout-High-Low-Signals-JPT/
- type: indicator
- pine_id: PUB;61b4e37dcde3401fa7fa3b2939696214
- version: 2.0

## Description

🔷 [b]OVERVIEW[/b]
https://www.tradingview.com/x/gdOedQFh/
[b]Pivot Breakout High&Low Signals [JPT][/b] is a non-repainting price action indicator that automatically identifies Pivot High and Pivot Low breakout opportunities using a [b]Breakout → Retest → Confirmation[/b] methodology.

Instead of generating signals immediately after price breaks a pivot level, the indicator waits for price to successfully retest the broken support or resistance before displaying a BUY or SELL signal. This approach helps reduce false breakouts and provides higher-quality trading opportunities.

The indicator continuously updates dynamic Pivot High resistance and Pivot Low support levels, making it easier to visualize market structure and identify potential breakout zones.

--------------------------------------------------
🔷 [b]HOW IT WORKS[/b]

The indicator continuously scans completed candles for confirmed Pivot Highs and Pivot Lows.

When breakout conditions are satisfied, it:

• Detects a confirmed Pivot High or Pivot Low

• Monitors for a breakout above resistance or below support

• Waits for price to retest the breakout level

• Confirms buyer or seller rejection

• Displays a BUY or SELL signal

• Updates Pivot Support and Resistance levels automatically

• Optionally filters signals using the EMA trend direction

Only confirmed breakout and retest setups generate trading signals.

--------------------------------------------------

🔷 [b]CHART SETUP ① – BULLISH PIVOT BREAKOUT
📈 Pivot High → Breakout → LONG → SINGAL[/b]
https://www.tradingview.com/x/oKYHlz4e/
• Price forms a confirmed Pivot High.

• Buyers break above the Pivot High resistance.

• Price retraces to retest the breakout level.

• The previous resistance becomes new support.

• Buyers defend the support.

• The indicator plots a [b]BUY signal[/b] after confirmation.
This setup helps traders avoid chasing breakouts and instead enter after confirmation.

--------------------------------------------------

🔷 [b]CHART SETUP ② – BEARISH PIVOT BREAKDOWN
📉 Pivot Low → Breakdown → SHORT → SINGAL[/b]
https://www.tradingview.com/x/hje4Vg5K/
• Price forms a confirmed Pivot Low.

• Sellers break below the Pivot Low support.

• Price pulls back to retest the broken support.

• The previous support becomes new resistance.

• Sellers reject the retest.

• The indicator plots a [b]SELL signal[/b] after confirmation.
This confirmation helps reduce false breakdown entries during sideways markets.

--------------------------------------------------

🔷 [b]CHART SETUP ③ – DYNAMIC PIVOT STRUCTURE[/b]
https://www.tradingview.com/x/ZlSMp7Xy/
Throughout every trend, the indicator continuously updates:

• Pivot Higher Resistance

• Pivot Lower Support

These dynamic levels help traders:

• Identify trend direction

• Monitor breakout zones

• Observe changing market structure

• Anticipate future breakout opportunities

The Pivot lines automatically adjust as new confirmed swing highs and lows are formed.

--------------------------------------------------

🔷 [b]VISUAL FEATURES[/b]

• Automatic BUY & SELL Signals

• Dynamic Pivot High Resistance

• Dynamic Pivot Low Support

• Breakout Confirmation

• Retest Confirmation

• Optional EMA Trend Filter

• Historical Signal Display

• Background Signal Highlight

• Clean & Lightweight Chart Layout

• Non-Repainting Pivot Logic

--------------------------------------------------

🔷[b] INPUTS[/b]

The indicator includes options to customize:

• Pivot Length

• Retest Tolerance (%)

• EMA Length

• Enable / Disable EMA Trend Filter

• Signal Colors

• Historical Signal Display

--------------------------------------------------

🔷 [b]USAGE[/b]

A common workflow is:

• Wait for a confirmed BUY or SELL signal.

• Confirm that price has completed the breakout and retest.

• Use the Pivot Support or Resistance level as your trade reference.

• Manage your trade using your own stop-loss and take-profit strategy.

• Combine signals with higher-timeframe trend analysis, support/resistance, or volume for additional confirmation.

--------------------------------------------------

🔷 [b]BEST MARKETS[/b]

The indicator can be applied to:

• Forex

• Gold (XAUUSD)

• Silver (XAGUSD)

• Crude Oil

• Cryptocurrency

• Stocks

• Indices

• Commodities

--------------------------------------------------

🔷 [b]RECOMMENDED TIMEFRAMES[/b]

The indicator works across all timeframes.

Recommended:

• 15 Minutes

• 30 Minutes

• 1 Hour

• 2 Hours

• 4 Hours

• Daily

Higher timeframes generally produce stronger breakout confirmations and more reliable retest signals.

-------------------------------------------------------

🔷 [b]DISCLAIMER[/b]

This indicator is designed as a technical analysis tool and does not predict future price movements. BUY and SELL signals are generated according to the programmed Pivot Breakout and Retest logic and should be used alongside additional market analysis, sound risk management, and appropriate trade planning. No indicator guarantees profitable trading results.

[b]Developed by Jos-ProTrader (JPT)[/b]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
indicator("Pivot Breakout High&Low Signals [JPT]", shorttitle="PBHL [JPT]", overlay=true, max_labels_count=500)

// ===== Inputs =====
pivotLen = input.int(5, "Pivot Length", minval=2)
retestTolerance = input.float(0.3, "Retest Tolerance (%)", step=0.1) / 100
emaFilter = input.bool(true, "Use EMA Trend Filter")
emaLength = input.int(200, "EMA Length")

// ===== EMA =====
ema = ta.ema(close, emaLength)
plot(emaFilter ? ema : na, color=color.orange, linewidth=2)

// ===== Pivot Detection =====
pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivotLow = ta.pivotlow(low, pivotLen, pivotLen)

var float lastPivotHigh = na
var float lastPivotLow = na

if not na(pivotHigh)
    lastPivotHigh := pivotHigh

if not na(pivotLow)
    lastPivotLow := pivotLow

plot(lastPivotHigh, color=color.red, linewidth=2, style=plot.style_linebr)
plot(lastPivotLow, color=color.lime, linewidth=2, style=plot.style_linebr)

// ===== Breakout Detection =====
bullBreakout = ta.crossover(close, lastPivotHigh)
bearBreakout = ta.crossunder(close, lastPivotLow)

// ===== Store Breakout Levels =====
var float bullLevel = na
var float bearLevel = na

var bool waitingBullRetest = false
var bool waitingBearRetest = false

if bullBreakout
    bullLevel := lastPivotHigh
    waitingBullRetest := true

if bearBreakout
    bearLevel := lastPivotLow
    waitingBearRetest := true

// ===== Retest Logic =====
bullRetest =
     waitingBullRetest and
     low <= bullLevel * (1 + retestTolerance) and
     low >= bullLevel * (1 - retestTolerance) and
     close > bullLevel

bearRetest =
     waitingBearRetest and
     high >= bearLevel * (1 - retestTolerance) and
     high <= bearLevel * (1 + retestTolerance) and
     close < bearLevel

// ===== EMA Filter =====
buySignal = bullRetest and (not emaFilter or close > ema)
sellSignal = bearRetest and (not emaFilter or close < ema)

// ===== Reset =====
if buySignal
    waitingBullRetest := false

if sellSignal
    waitingBearRetest := false

// ===== Plot Signals =====
plotshape(buySignal,
     title="BUY",
     location=location.belowbar,
     style=shape.triangleup,
     color=color.lime,
     size=size.large,
     text="BUY")

plotshape(sellSignal,
     title="SELL",
     location=location.abovebar,
     style=shape.triangledown,
     color=color.red,
     size=size.large,
     text="SELL")

// ===== Alerts =====
alertcondition(buySignal, title="Buy Alert", message="Pivot Breakout Retest BUY")
alertcondition(sellSignal, title="Sell Alert", message="Pivot Breakout Retest SELL")

// ===== Background =====
bgcolor(buySignal ? color.new(color.green, 85) : na)
bgcolor(sellSignal ? color.new(color.red, 85) : na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MODULE — ADVANCED ALERTS [JPT]
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Enable Alerts
enableAlerts = input.bool(true, "Enable Alerts", group="Advanced Alerts")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Breakout Alerts
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(
     enableAlerts and bullBreakout,
     title="Bullish Pivot Breakout",
     message="🟢 [JPT] Bullish Pivot Breakout detected.\nPrice has broken above the previous Pivot High.")

alertcondition(
     enableAlerts and bearBreakout,
     title="Bearish Pivot Breakout",
     message="🔴 [JPT] Bearish Pivot Breakout detected.\nPrice has broken below the previous Pivot Low.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Retest Alerts
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(
     enableAlerts and bullRetest,
     title="Bullish Retest Confirmed",
     message="🟢 [JPT] Bullish Retest confirmed.\nPrice successfully retested the breakout level.")

alertcondition(
     enableAlerts and bearRetest,
     title="Bearish Retest Confirmed",
     message="🔴 [JPT] Bearish Retest confirmed.\nPrice successfully retested the breakout level.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Trade Signal Alerts
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(
     enableAlerts and buySignal,
     title="BUY Signal",
     message="🚀 [JPT] BUY Signal\nPivot Breakout + Retest + EMA confirmation.")

alertcondition(
     enableAlerts and sellSignal,
     title="SELL Signal",
     message="📉 [JPT] SELL Signal\nPivot Breakdown + Retest + EMA confirmation.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Trend Change Alerts
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullTrendChange = ta.crossover(close, ema)
bearTrendChange = ta.crossunder(close, ema)

alertcondition(
     enableAlerts and emaFilter and bullTrendChange,
     title="Bullish Trend Change",
     message="📈 [JPT] Price crossed ABOVE the EMA.\nBullish trend bias detected.")

alertcondition(
     enableAlerts and emaFilter and bearTrendChange,
     title="Bearish Trend Change",
     message="📉 [JPT] Price crossed BELOW the EMA.\nBearish trend bias detected.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// New Pivot Alerts
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(
     enableAlerts and not na(pivotHigh),
     title="New Pivot High",
     message="🔺 [JPT] New Pivot High confirmed.")

alertcondition(
     enableAlerts and not na(pivotLow),
     title="New Pivot Low",
     message="🔻 [JPT] New Pivot Low confirmed.")
````
