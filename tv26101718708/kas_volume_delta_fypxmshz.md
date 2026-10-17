# KAS Volume Delta

- url: https://www.tradingview.com/script/FYpxMsHz-KAS-Volume-Delta/
- type: indicator
- pine_id: PUB;a54ab521c8a04fe78e9b752cf1be55e1
- version: 1.0

## Description

KAS Volume Delta is a per-candle volume delta histogram that shows the directional buy and sell pressure behind every bar. It reads each candle's direction together with its volume to estimate net order pressure, then adds a signal line and highlights bars with exceptional delta. It is a clean, lightweight way to add order-flow context to any chart that provides volume data.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WHAT IT DOES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Plots a per-candle volume delta histogram (green for net buying, red for net selling).

Splits indecision (Doji) candles by their close position so flat bars still carry a directional bias.

Draws a Delta SMA signal line to track whether pressure is accelerating or fading.

Highlights dominant bars where the absolute delta exceeds twice its recent average.

Optionally normalizes delta by average volume for cross-instrument comparison.

Optionally tints the main-chart candles by delta direction (off by default).

Shows a compact status readout: current bias, SMA signal state, dominant state.

Includes four alerts on delta zero-cross and SMA-cross events.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW IT WORKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Bar-Level Delta: Each candle's delta is set to +volume when close is above open (net buying) and -volume when close is below open (net selling). This is a transparent estimate computed directly from OHLC and volume, with no lower-timeframe dependency.

Doji Handling (hl2 midpoint): On indecision candles where close equals open, delta is split by the close-versus-midpoint position. A close at or above hl2 yields +0.5x volume (soft buying); below hl2 yields -0.5x volume (soft selling). Flat bars therefore still contribute a directional bias instead of a zero.

Delta SMA Signal Line: A simple moving average of delta over a configurable length (default 21) acts as a signal line. Delta crossing above the SMA indicates buying pressure accelerating; crossing below indicates selling pressure building.

Dominant Bar Detection: The absolute delta is compared against its own 20-bar average. When a bar's magnitude exceeds twice that average, it renders at full opacity and greater width, surfacing exceptional single-bar pressure with no manual reading.

Optional Normalization: When enabled, delta is divided by the 20-bar volume average, producing a relative ratio that makes delta intensity comparable across different instruments and timeframes.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WHY IT'S UNIQUE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Unlike TradingView's native Volume Delta, which relies on lower-timeframe intrabar data and can behave inconsistently on higher timeframes or illiquid symbols, this indicator computes a transparent bar-level delta directly from each candle, with no lower-timeframe dependency.

Unlike scripts that assign zero delta to indecision candles, this indicator splits Doji volume by the close-versus-midpoint (hl2) position at plus or minus 0.5x volume, preserving directional bias on flat bars.

Unlike cumulative delta tools that focus on a single running aggregate line, this indicator stays per-candle and flags dominant bars whenever delta magnitude exceeds twice its own recent average.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW TO USE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Add to any timeframe; works well from 5m to 4h for intraday and swing context.

Default settings are calibrated for liquid symbols (major crypto, large-cap stocks, major FX).

Read the histogram against the SMA signal line: sustained bars beyond the line confirm momentum; dominant bars mark exceptional initiation or exhaustion.

Enable Normalization when comparing delta intensity across different instruments.

Pair with your existing price structure or trend tools for confluence.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
LIMITATIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Requires a symbol that provides volume data; on feeds without volume the histogram will be empty.

The bar-level method is an approximation of order flow based on candle direction. It does not measure true intrabar buy/sell execution.

The SMA signal line lags by design and reacts after a move has begun.

This tool is for analytical purposes only and does not constitute financial advice.

Past signal behavior is not indicative of future results.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
KNECHT ALPHA SIGNALS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Institutional-grade Volume Delta, Momentum, and MTF Analysis for TradingView.
Built for traders who demand precision over noise.

## Source Code

````pine
//@version=6
// =============================================================================
// KAS Volume Delta
// Per-candle volume delta histogram with directional buy/sell pressure.
//
// Method:
//   - Bar-level delta from candle direction (close vs open)
//   - Doji handling: split by close vs hl2 midpoint at +/- 0.5 * volume (BR-07)
//   - Delta SMA signal line
//   - Dominant bar highlight when abs(delta) exceeds 2x its recent average
//   - Optional main-chart candle coloring by delta direction
//   - Compact functional status readout
//
// Bar-level method has no lower-timeframe dependency and does not repaint.
// =============================================================================
indicator("KAS Volume Delta", shorttitle="KAS Vol Delta", overlay=false)

// =============================================================================
// COLORS
// =============================================================================
grpColors  = "Colors"

posBase    = input.color(color.rgb(38, 166, 154), "Bullish Bar Color",
  group=grpColors,
  tooltip="Color for positive delta bars (close above open: net buying pressure).")

negBase    = input.color(color.rgb(239, 83, 80),  "Bearish Bar Color",
  group=grpColors,
  tooltip="Color for negative delta bars (close below open: net selling pressure).")

zeroLineCol = input.color(color.new(color.gray, 50), "Zero Line Color", group=grpColors)

// =============================================================================
// VISUALIZATION
// =============================================================================
grpVis     = "Visualization"

posTransp  = input.int(20, "Bullish Transparency (0=solid)",
  minval=0, maxval=100, group=grpVis,
  tooltip="0 = solid bars, 100 = invisible.")

negTransp  = input.int(20, "Bearish Transparency (0=solid)",
  minval=0, maxval=100, group=grpVis)

showSpike  = input.bool(true, "Highlight Dominant Bars (2x Avg)",
  group=grpVis,
  tooltip="Renders a bar at full opacity and larger width when its absolute delta exceeds 2x the 20-bar average.")

showCandleColor = input.bool(false, "Color Main Chart Candles by Delta",
  group=grpVis,
  tooltip="Tints price candles by delta direction. Off by default for a clean chart.")

// =============================================================================
// DELTA SMA
// =============================================================================
grpMA      = "Delta SMA"

showMA     = input.bool(true, "Show Delta SMA Line",
  group=grpMA,
  tooltip="Simple moving average of delta values, used as a signal line.")

maLen      = input.int(21, "SMA Length",
  minval=2, group=grpMA,
  tooltip="Period for the delta SMA. Lower is more reactive, higher is smoother.")

maCol      = input.color(color.rgb(255, 193, 7), "SMA Line Color", group=grpMA,
  tooltip="Signal line color.")

// =============================================================================
// NORMALIZATION
// =============================================================================
grpNorm    = "Normalization"

useNorm    = input.bool(false, "Normalize Delta by Average Volume",
  group=grpNorm,
  tooltip="Divides delta by the 20-bar volume average to produce a relative ratio. Off uses absolute volume values.")

// =============================================================================
// STATUS READOUT
// =============================================================================
grpStatus  = "Status Readout"

showStatus = input.bool(true, "Show Status Readout",
  group=grpStatus,
  tooltip="Compact panel showing current delta bias, SMA signal state, and dominant-bar state.")

statusPos  = input.string("Top Right", "Status Position",
  options=["Top Left","Top Center","Top Right","Middle Left","Middle Right","Bottom Left","Bottom Center","Bottom Right"],
  group=grpStatus)

// =============================================================================
// POSITION RESOLVER - switch ONLY (BR-01)
// =============================================================================
getDashPos(string s) =>
    switch s
        "Top Right"     => position.top_right
        "Top Center"    => position.top_center
        "Middle Left"   => position.middle_left
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        =>                 position.top_left

// Global scope table guard (BR-06)
var table statusTbl = na

// =============================================================================
// DELTA CALCULATION (BR-07: Doji = +/- 0.5 * volume, NEVER 0.0)
// =============================================================================
// Doji split: close position relative to candle midpoint sets the bias.
//   close >= hl2 -> upper half -> soft buying pressure  (+0.5 * volume)
//   close <  hl2 -> lower half -> soft selling pressure (-0.5 * volume)
float deltaRaw   = close > open ? volume : close < open ? -volume : (close >= hl2 ? volume * 0.5 : -(volume * 0.5))
float normVol    = ta.sma(volume, 20)
float seriesBase = useNorm ? (deltaRaw / nz(normVol, 1.0)) : deltaRaw
bool  isPos      = seriesBase >= 0

// =============================================================================
// DELTA SMA (BR-02: input.int returns simple int, allowed in ta.*)
// =============================================================================
float deltaMA = ta.sma(seriesBase, maLen)

// =============================================================================
// DOMINANT BAR DETECTION
// =============================================================================
// A bar is dominant when its absolute delta exceeds 2x the 20-bar average.
float avgDeltaAbs = ta.sma(math.abs(seriesBase), 20)
bool  isDominant  = showSpike and not na(avgDeltaAbs) and avgDeltaAbs > 0 and (math.abs(seriesBase) > avgDeltaAbs * 2.0)

// Color resolution (dominant bars render at full opacity)
color posColNorm  = color.new(posBase, posTransp)
color negColNorm  = color.new(negBase, negTransp)
color posColDom   = color.new(posBase, 0)
color negColDom   = color.new(negBase, 0)
color colMain     = isPos ? (isDominant ? posColDom : posColNorm) : (isDominant ? negColDom : negColNorm)

// =============================================================================
// PLOTS - global scope, after all variable declarations (BR-18)
// =============================================================================
// Main delta histogram - two separate plots for normal vs dominant bars.
// BR-11: plot() linewidth MUST be a compile-time constant. Never a ternary with
// series values. Fix: two plot() calls with conditional na and fixed linewidths.
plot(isDominant ? seriesBase : na,
  "Delta Dominant",
  color=colMain,
  style=plot.style_columns, linewidth=3)

plot(not isDominant ? seriesBase : na,
  "Delta",
  color=colMain,
  style=plot.style_columns, linewidth=2)

// Delta SMA signal line
plot(showMA ? deltaMA : na,
  "Delta SMA",
  color=maCol, linewidth=2)

// Zero baseline
plot(0, "Zero Line", color=zeroLineCol, linewidth=1)

// Candle coloring on main price chart (global scope, BR-09)
barcolor(showCandleColor ? (isPos ? color.new(posBase, 75) : color.new(negBase, 75)) : na,
  title="Candle Color by Delta")

// =============================================================================
// STATUS READOUT (BR-05: delete -> new, BR-06: white text, global scope)
// =============================================================================
if showStatus and barstate.islast
    if not na(statusTbl)
        table.delete(statusTbl)
    statusTbl := table.new(getDashPos(statusPos), 2, 3, border_width=1)

    color cLbl = color.new(color.black, 0)
    color cNeu = color.new(color.gray, 70)
    color cPos = color.new(posBase, 55)
    color cNeg = color.new(negBase, 55)

    string sBias  = isPos ? "Buy Pressure" : "Sell Pressure"
    bool   aboveMA = seriesBase > deltaMA
    string sSig   = aboveMA ? "Above SMA" : "Below SMA"
    string sDom   = isDominant ? "Yes" : "-"

    table.cell(statusTbl, 0, 0, "Delta",    text_color=color.white, bgcolor=cLbl)
    table.cell(statusTbl, 1, 0, sBias,      text_color=color.white, bgcolor=isPos ? cPos : cNeg)
    table.cell(statusTbl, 0, 1, "Signal",   text_color=color.white, bgcolor=cLbl)
    table.cell(statusTbl, 1, 1, sSig,       text_color=color.white, bgcolor=aboveMA ? cPos : cNeg)
    table.cell(statusTbl, 0, 2, "Dominant", text_color=color.white, bgcolor=cLbl)
    table.cell(statusTbl, 1, 2, sDom,       text_color=color.white, bgcolor=cNeu)

// =============================================================================
// ALERTS (BR-09: English ASCII + {{ticker}} {{interval}} {{close}})
// =============================================================================
alertcondition(ta.crossover(seriesBase, 0),
  "Volume Delta: Turns Positive",
  "Delta Positive | {{ticker}} | TF {{interval}} | Close={{close}} | Buy pressure crossing into positive territory.")

alertcondition(ta.crossunder(seriesBase, 0),
  "Volume Delta: Turns Negative",
  "Delta Negative | {{ticker}} | TF {{interval}} | Close={{close}} | Sell pressure crossing into negative territory.")

alertcondition(ta.crossover(seriesBase, deltaMA),
  "Volume Delta: Crosses Above SMA",
  "Delta Above SMA | {{ticker}} | TF {{interval}} | Close={{close}} | Buy pressure accelerating above average.")

alertcondition(ta.crossunder(seriesBase, deltaMA),
  "Volume Delta: Crosses Below SMA",
  "Delta Below SMA | {{ticker}} | TF {{interval}} | Close={{close}} | Sell pressure accelerating below average.")
````
