# ATR Swing Stop Loss (Long)

- url: https://www.tradingview.com/script/5wOH0LDp-ATR-Swing-Stop-Loss-Long/
- type: indicator
- pine_id: PUB;f14d4fabd6af4713ae0f652a8182d493
- version: 1.0

## Description

ATR Swing Stop Loss (Long) — Documentation

Purpose: Plots a trailing stop-loss line for long swing positions in Indian equities, based on Average True Range (ATR) volatility rather than a fixed percentage or arbitrary support level.

Core Logic
ATR Calculation — Measures 14-period average true range (Wilder's smoothing), capturing the stock's typical daily volatility.
Stop Level — Highest High (14 bars) − (ATR × 3.0). Anchoring to the recent high (not just current price) keeps the stop from tightening prematurely during a pullback within an uptrend.
Ratcheting — The stop only moves up, never down, as price makes new highs. This locks in gains as the trade progresses.
Reset on Breach — If a candle closes below the trailing stop, it's treated as a stop-out. The calculation resets fresh from that point (as if starting a new trade), and the line briefly turns red.
Inputs
Input	Default	Description
ATR Length	14	Lookback period for ATR and highest-high calculation
ATR Multiplier	3.0	Controls stop distance — lower = tighter stop, higher = more room
Show Info Table	On	Displays ATR value, stop price, and risk % in top-right corner
Show Stop-Hit Markers	On	Plots an "SL" cross marker when price closes below the stop
Visual Output
Orange line — active trailing stop
Red line/marker — stop was just breached (exit signal)
Info table — current ATR, stop level, and % distance from close to stop (useful for position sizing/risk calc)
Alerts

One built-in alert condition: "Long ATR Stop Hit" — fires when price closes below the trailing stop. Set this up via TradingView's Alert panel to get notified without watching the chart.

Usage Notes
Designed for daily timeframe swing trades; can be used intraday but multiplier/length may need adjustment for lower timeframes.
Works best on trending stocks — in sideways/choppy names it may whipsaw more often near the 3× ATR threshold.
Long-only. Does not track entry price or position size — it's a volatility-based exit reference, not a full position manager.
Not signal generation — this indicator does not tell you when to enter, only where to consider exiting once you're long.
Suggested Workflow
Add to your stock's daily chart alongside your entry signal/strategy.
Enter long per your own setup.
Use the plotted stop as your live stop-loss reference — adjust broker SL order as the line ratchets up.
Exit (or tighten manually) when the "SL" marker appears or your alert fires.

## Source Code

````pine
//@version=6
indicator("ATR Swing Stop Loss (Long)", overlay=true, max_labels_count=50)

// ============================================================
// INPUTS
// ============================================================
atrLength   = input.int(14, "ATR Length", minval=1, tooltip="14 is standard for daily swing trades on Indian equities")
atrMult     = input.float(3.0, "ATR Multiplier", step=0.1, minval=0.5, tooltip="3.0 gives room for normal volatility; lower it for tighter stops")
showTable   = input.bool(true, "Show Info Table")
showMarkers = input.bool(true, "Show Stop-Hit Markers")

// ============================================================
// CALCULATIONS
// ============================================================
atr         = ta.atr(atrLength)
highestHigh = ta.highest(high, atrLength)
rawStop     = highestHigh - atr * atrMult

var float trailStop = na
var bool  stopHit   = false

if bar_index == 0 or na(trailStop[1])
    trailStop := rawStop
    stopHit   := false
else
    if close[1] < trailStop[1]
        // previous stop was breached -> start a fresh trailing calc
        trailStop := rawStop
        stopHit   := true
    else
        // ratchet: stop can only move up, never down
        trailStop := math.max(rawStop, trailStop[1])
        stopHit   := false

stopDistPct = (close - trailStop) / close * 100

// ============================================================
// PLOTS
// ============================================================
plot(trailStop, title="ATR Trailing Stop", color=stopHit ? color.new(color.red, 0) : color.new(color.orange, 0), style=plot.style_linebr, linewidth=2)

exitSignal = ta.crossunder(close, trailStop)

plotshape(showMarkers and exitSignal, title="Stop Hit", style=shape.xcross, location=location.abovebar, color=color.red, size=size.small, text="SL")

// ============================================================
// INFO TABLE (last bar)
// ============================================================
var table infoTable = table.new(position.top_right, 2, 3, border_width=1)
if showTable and barstate.islast
    table.cell(infoTable, 0, 0, "ATR (" + str.tostring(atrLength) + ")", text_color=color.white, bgcolor=color.new(color.gray, 20))
    table.cell(infoTable, 1, 0, str.tostring(atr, format.mintick), text_color=color.white, bgcolor=color.new(color.gray, 20))
    table.cell(infoTable, 0, 1, "Stop Level", text_color=color.white, bgcolor=color.new(color.gray, 20))
    table.cell(infoTable, 1, 1, str.tostring(trailStop, format.mintick), text_color=color.white, bgcolor=color.new(color.gray, 20))
    table.cell(infoTable, 0, 2, "Risk %", text_color=color.white, bgcolor=color.new(color.gray, 20))
    table.cell(infoTable, 1, 2, str.tostring(stopDistPct, format.percent), text_color=(stopDistPct > 0 ? color.lime : color.red), bgcolor=color.new(color.gray, 20))

// ============================================================
// ALERTS
// ============================================================
alertcondition(exitSignal, title="Long ATR Stop Hit", message="Price closed below the ATR trailing stop. Consider exiting the long position.")
````
