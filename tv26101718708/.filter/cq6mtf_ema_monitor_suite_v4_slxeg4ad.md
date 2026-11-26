# CQ_(6)_MTF EMA Monitor Suite V4

- url: https://www.tradingview.com/script/SLxeg4Ad-CQ-6-MTF-EMA-Monitor-Suite-V4/
- type: indicator
- pine_id: PUB;7c3376bbae0b4274af5c3833281f9a26
- version: 1.0

## Description

================================================================================
CQ_(6)_MTF EMA MONITOR SUITE V3 [▤]
Description and User Manual
Some modules based on Zeierman and Ukutalabs public code.
================================================================================

--------------------------------------------------------------------------------
1. OVERVIEW
--------------------------------------------------------------------------------

MTF EMA Monitor Suite V3 is a multi-module price-chart overlay that bundles
six largely independent trading tools into a single indicator:

  A) EMA Monitor        - 3-EMA trend engine with bar coloring, channel fill,
                           breakout/breakdown shapes, and a per-timeframe
                           EMA relationship dashboard.
  B) Breakout Probability Meter - a statistical "likely next move" ladder
                           projected to the right of price, based on how
                           often price has historically reached each
                           percentage step from the prior bar's high/low.
  C) ZigZag              - a swing-pivot ZigZag with HH/LH/HL/LL labeling
                           and optional support/resistance dotted lines.
  D) MTF RSI             - a compact 6-timeframe RSI heat-strip appended to
                           the EMA Monitor dashboard.
  E) RSI Divergence      - classic + hidden RSI divergence detection, plus a
                           "predictive" real-time projection of the price
                           level needed to confirm a divergence on the
                           current live bar, complete with a strength score.
  F) Swing Pivots        - current-timeframe and higher-timeframe swing
                           High/Low detection with classification boxes,
                           extension lines, and colored supply/demand zones.

Each module has its own input group in the settings panel (prefixed with the
🟧 icon for the primary toggle of that section) and can be enabled/disabled
independently.

--------------------------------------------------------------------------------
2. MODULE A - EMA MONITOR
--------------------------------------------------------------------------------

WHAT IT DOES
  - Plots three EMAs (Fast/EMA1, Trigger/EMA2, Slow/EMA3) directly on price,
    each colored based on whether it is currently rising or falling.
  - Fills the channel between EMA1 and EMA2, colored green when EMA1 is
    above EMA2 (bullish) and red when below (bearish).
  - Optionally colors the chart's candles/bars:
      * "Color Bars?" recolors every bar green/red based on EMA1 vs EMA2.
      * "Color Bar when price closes Under/Above EMA 1 & 2?" recolors bars
        blue/orange specifically when price crosses above/below BOTH EMA1
        and EMA2 simultaneously.
  - Plots small triangle markers above price when a "Breakout" (fast EMA
    turning up) or "Breakdown" condition is met.
  - Optional background tint reflecting the EMA1/EMA2 relationship.
  - Optional "EMA Deviations" labels showing how far (in %) price currently
    sits from each EMA.
  - Fires alerts when price crosses above/below both EMA1 and EMA2.

KEY INPUTS (group: "EMA Monitor")
  Turn on EMA cross Alerts?      - master alert toggle for the cross-above/
                                    cross-below-both-EMAs condition.
  Color Bars?                    - green/red bar coloring by EMA1 vs EMA2.
  Color Bar when price closes... - blue/orange bar coloring on dual-EMA cross.
  Turn on EMA Lines?             - shows/hides the three EMA plots.
  Enable Background Color?       - shows/hides the channel-fill background tint.
  Fast/Trigger/Slow EMA lengths  - the three EMA periods (defaults 20/55/200).
  Opacity for all EMAs           - shared transparency for all three EMA lines.
  EMA Deviations                 - toggles the %-distance-from-EMA labels.

--------------------------------------------------------------------------------
3. MODULE A(continued) - MULTI-TIMEFRAME EMA DASHBOARD
--------------------------------------------------------------------------------

WHAT IT DOES
  - Requests EMA1/EMA2/EMA3 values from six user-selected timeframes and
    displays, per timeframe: the EMA1-vs-EMA2 bias (with % separation),
    plus price's distance from each of the three EMAs (with directional
    arrows and color-coded backgrounds).
  - Supports both a horizontal layout (timeframes as columns, the classic
    layout) and a vertical layout (timeframes as rows) via a single toggle -
    all cell-placement logic is handled by a shared "tc()" helper so the
    same data populates either orientation.

KEY INPUTS (group: "EMA Monitoring Dashboard")
  Display (EMA) Dashboard   - master on/off switch for the whole table.
  Dashboard Position?       - anchor corner/edge of the chart.
  Dashboard Size?           - text size (Tiny recommended for mobile).
  Vertical Layout (Timeframes as Rows) - flips the table orientation.
  Time Frame 1-6            - the six timeframes monitored (defaults:
                               5m, 15m, 1H, 4H, 1D, 1W).

--------------------------------------------------------------------------------
4. MODULE B - BREAKOUT PROBABILITY METER
--------------------------------------------------------------------------------

WHAT IT DOES
  - Builds a small ladder of horizontal price levels above and below the
    prior candle's high/low, spaced by a user-defined percentage step.
  - For each level, it tracks (since the indicator was added to the chart)
    how often price has historically reached that many steps away on a
    green vs. red candle, and displays the resulting hit-rate as a
    percentage label at each level.
  - Optionally shades the region between consecutive levels for a
    heat-map-style visual, and can display a running win/loss "Statistic
    Panel" for whichever side (high or low) was projected as most likely.
  - Can fire a consolidated alert() call containing the ticker, the most
    recent high/low, the bullish/bearish bias, and the percentage
    likelihoods, gated by four independent content toggles.

KEY INPUTS (group: "Break Out Probability Meter")
  Show Break Out Probability Meter - master toggle.
  Percentage Step             - vertical spacing between levels (default 0.5%).
  Number of Lines              - how many levels to project (max 5).
  Label Size?                  - text size for the level labels.
  Labels / Background colors   - separate up/down colors for label text and
                                  the optional shaded background.
  Meter Background Shade        - toggles the shaded fill between levels.
  Meter Offset (Horizontal)     - how far right of price the ladder is drawn.
  Disable 0.00%                 - hides levels with a 0% historical hit rate.
  Show Statistic Panel          - shows the win/loss/win-rate mini table.
  Any alert() function call     - four toggles controlling which pieces of
                                  information (Ticker, High/Low, Bias,
                                  Percentage) are included in the alert text.

--------------------------------------------------------------------------------
5. MODULE C - ZIGZAG
--------------------------------------------------------------------------------

WHAT IT DOES
  - Detects swing highs/lows over a configurable lookback ("Length") and
    connects them with a ZigZag line.
  - Classifies each new pivot as Higher High (HH), Lower High (LH), Higher
    Low (HL), or Lower Low (LL), each with its own color, and optionally
    labels each pivot on the chart.
  - Optionally draws dotted support/resistance lines projecting from each
    pivot level, including one live "developing" dotted line that extends
    to the current bar until price moves past it.

KEY INPUTS (group: "ZigZag")
  Length     - pivot lookback length (default 20; higher = fewer, larger
               swings).
  SR Lines   - toggles the dotted support/resistance projections.
  Labels     - toggles the HH/LH/HL/LL text labels at each pivot.
  ZigZag     - toggles the connecting ZigZag line itself.

--------------------------------------------------------------------------------
6. MODULE D - MTF RSI (HEAT STRIP)
--------------------------------------------------------------------------------

WHAT IT DOES
  - Computes RSI on six independently selectable timeframes and appends a
    one-row heat-strip to the bottom of the EMA dashboard table, colored on
    a 7-band scale from "Max Bearish" (RSI <= 25) to "Max Bullish"
    (RSI >= 75), with a neutral band in between.
  - Respects the same horizontal/vertical orientation toggle as the EMA
    dashboard, so it always lines up with the correct timeframe column/row.

KEY INPUTS (group: "MTF RSI")
  Resolution 1-6            - the six timeframes analyzed (defaults: 5m,
                               15m, 1H, 4H, 1D, 1W).
  Max/Med/Min Bullish Cell Color, Neutral Cell Color,
  Min/Med/Max Bearish Cell Color - the 7-step color scale.
  Cell Transparency          - shared transparency for all heat-strip cells.
  Length                     - RSI calculation length (default 14).

--------------------------------------------------------------------------------
7. MODULE E - RSI DIVERGENCE (WITH PREDICTIVE PROJECTION)
--------------------------------------------------------------------------------

WHAT IT DOES
  - Detects Regular Bullish, Hidden Bullish, Regular Bearish, and Hidden
    Bearish divergence between price and RSI, using pivot detection with
    configurable left/right lookback and a valid pivot-distance range.
  - Source for price pivots can use either candle Wicks (high/low) or
    Bodies (max/min of open/close).
  - PREDICTIVE DIVERGENCE (unique feature): on the live/current bar, before
    a divergence has technically confirmed, the script projects the exact
    closing price that WOULD confirm a divergence against the last
    confirmed pivot, and draws a dashed projection line plus an info label
    showing that "Confirmation Price."
  - DIVERGENCE STRENGTH SCORE: an optional 0-10 score combining a
    "location" component (how overbought/oversold the RSI pivots are,
    using two configurable levels each for overbought/oversold) and a
    "magnitude" component (how much RSI's percentage change disagrees with
    price's percentage change between the two pivots).
  - Alerts can fire the moment a potential (not-yet-confirmed) divergence
    is detected, separately for each of the four divergence types.

KEY INPUTS (group: "RSI Divergence")
  RSI Period                 - RSI calculation length (default 14).
  Use Price Wicks or Bodies? - pivot source selection.
  Pivot Lookback Left/Right  - standard pivot detection window.
  Lookback Range Max/Min     - valid bar-distance range between two pivots.
  Plot Bullish / Hidden, Plot Bearish / Hidden - independent toggles for
                               each of the four divergence types.

  Predictive Divergences group:
  Show Predictive Divergences        - master toggle for the live-bar
                                        projection feature.
  Min Bars Since Last Pivot for Predictive - cooldown before a new
                                        potential divergence is considered.
  Show Divergence Confirmation Price - toggles the projection line/label.

  Alerts group:
  Alert on Potential Bullish/Bearish (+ Hidden variants) - four independent
                                        alert toggles for potential (not yet
                                        confirmed) divergences.

  Divergence Strength Score group:
  Show Strength Score        - toggles the 0-10 score display in labels/alerts.
  RSI Overbought Level 1/2   - thresholds used for the bearish location score.
  RSI Oversold Level 1/2     - thresholds used for the bullish location score.

--------------------------------------------------------------------------------
8. MODULE F - SWING PIVOTS
--------------------------------------------------------------------------------

WHAT IT DOES
  - Identifies swing Highs/Lows on the CURRENT chart timeframe and,
    optionally, on up to six independently selectable higher timeframes
    (5m, 15m, 30m, 1H, 4H, Daily), each mirrored onto the current chart.
  - Classifies each new swing as Higher High, Lower High, Lower Low, or
    Higher Low, drawing a small classification box + label, a colored
    supply/demand "shadow" zone, a dashed midline, a dotted extension line
    at the pivot price, and a price box showing the exact level.
  - Each higher-timeframe stream keeps its own rolling history (bars +
    swing-point collections), so multiple timeframes can be displayed
    simultaneously without interfering with each other.
  - "Pivot Strength" controls how many bars on each side must confirm a
    high/low before it is accepted as a valid swing (higher = fewer, more
    significant pivots).

KEY INPUTS (group: "Swing Pivots Configuration")
  Pivot Strength   - sensitivity of the pivot calculation.
  Font Size        - text size for classification/price labels.

  Per-classification color + zone toggle (Higher High, Lower High, Lower
  Low, Higher Low groups):
  [Type] Color     - color used for that classification's box/label/zone.
  Show Zones       - toggles the shaded supply/demand zone for that type.

  Higher Time Frame group:
  Display Current Timeframe        - toggles current-TF swing pivots.
  5/15/30 Minute, 1 Hour, 4 Hour, Daily Higher Timeframe - independent
                                      toggles for each mirrored HTF stream.

--------------------------------------------------------------------------------
9. GENERAL NOTES
--------------------------------------------------------------------------------

  - This script is written in Pine Script v6 and declared as an overlay
    indicator (draws directly on the price chart).
  - Several modules (EMA Dashboard, MTF RSI, Breakout Probability Meter,
    Predictive Divergence) only redraw on the last/live bar
    (barstate.islast), which keeps the chart responsive while still
    updating in real time as new bars form.
  - The EMA Dashboard and MTF RSI heat-strip share a single table object
    and orientation toggle; toggling "Vertical Layout" affects both at once.
  - Multiple modules use array/matrix-based object pooling (lines, labels,
    boxes) with fixed maximum sizes, so older drawings are automatically
    cleaned up as new ones are created - no manual cleanup is required.

--------------------------------------------------------------------------------
10. ALERTS SUMMARY
--------------------------------------------------------------------------------

  - EMA Monitor: price rises above / drops below both EMA1 and EMA2.
  - Breakout Probability Meter: consolidated alert with ticker, high/low,
    bias, and percentage likelihoods (each field independently toggleable).
  - RSI Divergence: potential Regular Bullish / Hidden Bullish / Regular
    Bearish / Hidden Bearish divergence detected on the live bar, including
    the projected confirmation price and (optionally) the strength score.

================================================================================
End of manual.
================================================================================

## Source Code

````pine
//@version=6
indicator(title='CQ_(6)_MTF EMA Monitor Suite V4', overlay=true, max_bars_back = 5000, max_lines_count = 200)

// --- Inputs
source =          close
turnon2 =         input(true,   title = "Turn on EMA cross Alerts?", tooltip='Show an indicator above chart if Bullish or Bearish market condition exist.', group="🟧 EMA Monitor Settings")
colorbars  =      input(false,  title = "Color Bars?", group="EMA Monitor")
colorbars2 =      input(true,   title = "Color Bar when price closes Under/Above EMA 1 & 2?" , inline = "1", group="EMA Monitor")
turnon =          input(true,   title = "Turn on EMA Lines?", group="EMA Monitor")
backgroundcolor = input(false,  title = "Enable Background Color?", group="EMA Monitor")

// EMAs
len1 = input.int( 20, minval=1, title='   Fast EMA (↝EMA1)', tooltip='Selected EMA to monitor Bullish Market [If drawn above (↝EMA2)]', group="EMA Monitor")
len2 = input.int( 55, minval=1, title='Trigger EMA (↝EMA2)', tooltip='Selected EMA to monitor price Bouncing for Best Long Position Entry [Bearish Market if drawn above (↝EMA1)]', group="EMA Monitor")
len3 = input.int(200, minval=1, title='   Slow EMA (↝EMA3)', tooltip='Selected EMA to monitor Market Tendency', group="EMA Monitor")

EMAopacity = input.int(70, minval=0, maxval = 100, title='Opacity for all EMAS', tooltip='Select the opacity for plotting EMA lines', group="EMA Monitor")

showLengthSelected = input.bool(title='EMA Deviations', defval=false, tooltip='Show contraction/expansion from close price in %', group="EMA Monitor")

ema1 = ta.ema(source, len1)
ema2 = ta.ema(source, len2)
ema3 = ta.ema(source, len3)

//Distances from mean
d1 = (close - ema1) / ema1 * 100
d2 = (close - ema2) / ema2 * 100
d3 = (close - ema3) / ema3 * 100

//Description
devdesc1 = '↝' + str.tostring(len1) + ': ' + str.tostring(d1, '#0.00') + '%'
devdesc2 = '↝' + str.tostring(len2) + ': ' + str.tostring(d2, '#0.00') + '%'
devdesc3 = '↝' + str.tostring(len3) + ': ' + str.tostring(d3, '#0.00') + '%'

//---
cond1 = ta.crossover(close,ema1)  and ta.crossover(close,ema2)
cond2 = ta.crossunder(close,ema1) and ta.crossunder(close,ema2)

barcolor(cond1 ? color.rgb(0, 89, 255) : cond2 ? color.orange: na)
alertcondition(cond1, title = "Alert when price rises above EMA1 and EMA 2?", message = "Price rose above EMA 1 & EMA 2")
alertcondition(cond2, title = "Alert when price drops below EMA1 and EMA 2?", message = "Price closed below EMA 1 & EMA 2")


////////////////////////////////////////////////////////////////
///////               MAIN EMA MONITOR CODE                 ////
////////////////////////////////////////////////////////////////

//-- Candle Color
colbar = ema1 > ema2 ? color.rgb(15, 250, 23) :  color.rgb(255, 0, 0) 
barcolor(colorbars ? colbar :na)

// Ema Cross 
mylong  = ta.crossover(ema1, ema2)
myshort = ta.crossunder(ema1, ema2)

FirstEMA  = ta.ema(close, len1)
SecondEMA = ta.ema(close, len2)
ThirdEMA  = ta.ema(close, len3)

// Calculations
last_long  = float(na)
last_short = float(na)
last_long  := mylong ? time : nz(last_long[1])
last_short := myshort ? time : nz(last_short[1])

in_long = last_long > last_short ? 2 : 0
in_short = last_short > last_long ? 2 : 0

condlongx = in_long
condlong = ta.crossover(condlongx, 1.9)
condlongclose = ta.crossunder(condlongx, 1.9)

condshortx = in_short
condshort = ta.crossover(condshortx, 1.9)
condshortclose = ta.crossover(condshortx, 1.9)

// Color Fill
fcolor = FirstEMA > SecondEMA? color.rgb(10, 255, 96, 90) : FirstEMA < SecondEMA? color.rgb(255, 0, 0, 90) : color.rgb(204, 204, 204)

// Ema Output
upFirstEMA    = FirstEMA > FirstEMA[1]
downFirstEMA  = FirstEMA < FirstEMA[1]
lightblue  = color.rgb(40, 169, 255, EMAopacity)
darkblue   = color.rgb(0, 94, 170, EMAopacity)
FirstEMAcolor = upFirstEMA ? lightblue : downFirstEMA ? darkblue : lightblue
F1 = plot(turnon ? FirstEMA : na, color=FirstEMAcolor, linewidth=1)

upSecondEMA   = SecondEMA > SecondEMA[1]
downSecondEMA = SecondEMA < SecondEMA[1]
lightorange   = color.rgb(255, 187, 0, EMAopacity)
darkorange    = color.rgb(120, 64, 0, EMAopacity)
SecondEMAcolor = upSecondEMA ? lightorange : downSecondEMA ? darkorange : lightorange
S2 = plot(turnon ? SecondEMA  : na, color=SecondEMAcolor, linewidth=1)

upThirdEMA   = ThirdEMA > ThirdEMA[1]
downThirdEMA = ThirdEMA < ThirdEMA[1]
lightwhite   = color.rgb(255, 255, 255, EMAopacity)
darkwhite    = color.rgb(117, 117, 117, EMAopacity)
ThirdEMAcolor = upThirdEMA ? lightwhite : downSecondEMA ? darkwhite : lightwhite
T3 = plot(turnon ? ThirdEMA : na, color=ThirdEMAcolor, linewidth=1)

showLabelNow = showLengthSelected and barstate.islast
label1 = showLabelNow ? label.new(bar_index, ema1, text=devdesc1, textcolor=color.rgb(0, 140, 255), color=color.rgb(33, 149, 243, 70), style=label.style_label_left, textalign=text.align_left, yloc=yloc.price, size=size.tiny) : na
label.set_tooltip(label1, devdesc1)
label2 = showLabelNow ? label.new(bar_index, ema2, text=devdesc2, textcolor=color.rgb(255, 153, 0), color=color.rgb(255, 153, 0, 70), style=label.style_label_left, textalign=text.align_left, yloc=yloc.price, size=size.tiny) : na
label.set_tooltip(label2, devdesc2)
label3 = showLabelNow ? label.new(bar_index, ema3, text=devdesc3, textcolor=color.rgb(223, 223, 223), color=color.rgb(255, 255, 255, 70), style=label.style_label_left, textalign=text.align_left, yloc=yloc.price, size=size.tiny) : na
label.set_tooltip(label3, devdesc3)

label.delete(label1[1])
label.delete(label2[1])
label.delete(label3[1])

fill(F1, S2, title='Channel Fill', color=color.new(fcolor, 98))

// Plots
plotshape(turnon2 ? condlong  : bool(na), title='Breakout  (Fast EMA Up)', color=color.new(color.blue, 0), location=location.top, style=shape.triangleup, text='↝\n\📈', textcolor=color.new(color.blue, 0), size=size.tiny)
plotshape(turnon2 ? condshort : bool(na), title='Breakdown (Slow EMA Up)', color=color.new(color.orange, 0), location=location.top, style=shape.triangleup, text='↝\n📉', textcolor=color.new(color.orange, 0), size=size.tiny)

// Background Color
bgcolor(backgroundcolor ? fcolor : color.new(fcolor, 100))

// ─── DASHBOARD INPUTS ────────────────────────────────────────────────────────
showTable     = input.bool(defval=true,  title='Display (↝EMA) Dashboard',   group='🟧 EMA Monitoring Dashboard')
tablePosition = input.string(title='Dashboard Position?', defval=position.top_right,
     options=[position.bottom_left, position.top_left, position.middle_left,
              position.middle_right, position.bottom_right, position.top_right],
     group='EMA Dashboard',
     tooltip='Allows you to change the position of the dashboard on the chart.')
tableTextSize = input.string(title='Dashboard Size?', defval=size.tiny,
     options=[size.auto, size.tiny, size.small, size.normal, size.large, size.huge],
     group='EMA Dashboard',
     tooltip='Use Tiny if on Mobile, Use Small if on Web browser.')

// ── NEW: orientation toggle ───────────────────────────────────────────────────
tableVertical = input.bool(defval=false, title='Vertical Layout (Timeframes as Rows)',
     group='EMA Dashboard',
     tooltip='OFF = original layout: timeframes across columns, metrics down rows.\nON  = transposed layout: timeframes down rows, metrics across columns.')
// ─────────────────────────────────────────────────────────────────────────────

// Time Frames
TF1 = input.timeframe('5',   'Time Frame 1', tooltip='Select time frame to Monitor on Dashboard (Column 1)')
TF2 = input.timeframe('15',  'Time Frame 2', tooltip='Select time frame to Monitor on Dashboard (Column 2)')
TF3 = input.timeframe('60',  'Time Frame 3', tooltip='Select time frame to Monitor on Dashboard (Column 3)')
TF4 = input.timeframe('240', 'Time Frame 4', tooltip='Select time frame to Monitor on Dashboard (Column 4)')
TF5 = input.timeframe('1D',  'Time Frame 5', tooltip='Select time frame to Monitor on Dashboard (Column 5)')
TF6 = input.timeframe('1W',  'Time Frame 6', tooltip='Select time frame to Monitor on Dashboard (Column 6)')

//Time Frame 1
ema1ofTF1 = request.security(syminfo.tickerid, TF1, ta.ema(source, len1))
ema2ofTF1 = request.security(syminfo.tickerid, TF1, ta.ema(source, len2))
ema3ofTF1 = request.security(syminfo.tickerid, TF1, ta.ema(source, len3))

//Time Frame 2
ema1ofTF2 = request.security(syminfo.tickerid, TF2, ta.ema(source, len1))
ema2ofTF2 = request.security(syminfo.tickerid, TF2, ta.ema(source, len2))
ema3ofTF2 = request.security(syminfo.tickerid, TF2, ta.ema(source, len3))

//Time Frame 3
ema1ofTF3 = request.security(syminfo.tickerid, TF3, ta.ema(source, len1))
ema2ofTF3 = request.security(syminfo.tickerid, TF3, ta.ema(source, len2))
ema3ofTF3 = request.security(syminfo.tickerid, TF3, ta.ema(source, len3))

//Time Frame 4
ema1ofTF4 = request.security(syminfo.tickerid, TF4, ta.ema(source, len1))
ema2ofTF4 = request.security(syminfo.tickerid, TF4, ta.ema(source, len2))
ema3ofTF4 = request.security(syminfo.tickerid, TF4, ta.ema(source, len3))

//Time Frame 5
ema1ofTF5 = request.security(syminfo.tickerid, TF5, ta.ema(source, len1))
ema2ofTF5 = request.security(syminfo.tickerid, TF5, ta.ema(source, len2))
ema3ofTF5 = request.security(syminfo.tickerid, TF5, ta.ema(source, len3))

//Time Frame 6
ema1ofTF6 = request.security(syminfo.tickerid, TF6, ta.ema(source, len1))
ema2ofTF6 = request.security(syminfo.tickerid, TF6, ta.ema(source, len2))
ema3ofTF6 = request.security(syminfo.tickerid, TF6, ta.ema(source, len3))

colorTF1 = color.rgb(10, 10, 10, 50)
colorTF2 = color.rgb(10, 10, 10, 50)
colorTF3 = color.rgb(10, 10, 10, 50)
colorTF4 = color.rgb(10, 10, 10, 50)
colorTF5 = color.rgb(10, 10, 10, 50)
colorTF6 = color.rgb(10, 10, 10, 50)

f_timeframeConverter(_tf) =>
    seconds = timeframe.in_seconds(_tf)
    if seconds < 60
        _tf
    else if seconds < 3600
        str.tostring(seconds / 60) + 'min'
    else if seconds < 86400
        str.tostring(seconds / 60 / 60) + 'hrs'
    else
        switch _tf
            "1D" => "DAY"
            "1W" => "WEEK"
            "1M" => "MONTH"
            => str.tostring(_tf)

// EMA OF TIME FRAME 1  
Diff_ema1ofTF1     = ema1ofTF1 - ema2ofTF1 
PDif_ema1ema2ofTF1 = math.round((ema1ofTF1-ema2ofTF1)/((ema1ofTF1+ema2ofTF1)/2)*100,2)
BulBer_ema1ofTF1   = ema1ofTF1 > ema2ofTF1 ? "\n▲ " + str.tostring(PDif_ema1ema2ofTF1) + "%" : "\n▼ " + str.tostring(PDif_ema1ema2ofTF1) + "%"
BgColor1ofTF1      = ema1ofTF1 > ema2ofTF1 ? color.rgb(34, 95, 174, 80) : color.rgb(181, 60, 0, 80)
TxtColor1ofTF1     = ema1ofTF1 > ema2ofTF1 ? color.rgb(1, 170, 248)  : color.rgb(255, 85, 0)
Diff_ema2ofTF1  = close - ema1ofTF1
Drctn_ema2ofTF1 = close > ema1ofTF1 ? "↗" : "↘"
BgColor2ofTF1   = close > ema1ofTF1 ? color.rgb(1, 248, 26, 80) : color.rgb(255, 0, 0, 80)
TxtColor2ofTF1  = close > ema2ofTF1 ? color.rgb(1, 248, 26)     : color.rgb(255, 0, 0)
Diff_ema3ofTF1  = close - ema2ofTF1
Drctn_ema3ofTF1 = close > ema2ofTF1 ? "↗" : "↘"
BgColor3ofTF1   = close > ema2ofTF1 ? color.rgb(1, 248, 26, 80) : color.rgb(255, 0, 0, 80)
TxtColor3ofTF1  = close > ema3ofTF1 ? color.rgb(1, 248, 26)     : color.rgb(255, 0, 0)
Diff_ema4ofTF1  = close - ema3ofTF1
Drctn_ema4ofTF1 = close > ema3ofTF1 ? "↗" : "↘"
BgColor4ofTF1   = close > ema3ofTF1 ? color.rgb(1, 248, 26, 80) : color.rgb(255, 0, 0, 80)
TxtColor4ofTF1  = close > ema3ofTF1 ? color.rgb(1, 248, 26)     : color.rgb(255, 0, 0)

// EMA OF TIME FRAME 2
Diff_ema1ofTF2     = ema1ofTF2 - ema2ofTF2 
PDif_ema1ema2ofTF2 = math.round((ema1ofTF2-ema2ofTF2)/((ema1ofTF2+ema2ofTF2)/2)*100,2)
BulBer_ema1ofTF2   = ema1ofTF2 > ema2ofTF2 ? "\n▲ " + str.tostring(PDif_ema1ema2ofTF2) + "%" : "\n▼ " + str.tostring(PDif_ema1ema2ofTF2) + "%"
BgColor1ofTF2      = ema1ofTF2 > ema2ofTF2 ? color.rgb(34, 95, 174, 80) : color.rgb(181, 60, 0, 80)
TxtColor1ofTF2     = ema1ofTF2 > ema2ofTF2 ? color.rgb(1, 170, 248)  : color.rgb(255, 85, 0)
Diff_ema2ofTF2  = close - ema1ofTF2
Drctn_ema2ofTF2 = close > ema1ofTF2 ? "↗" : "↘"
BgColor2ofTF2   = close > ema1ofTF2 ? color.rgb(1, 248, 26, 80) : color.rgb(255, 0, 0, 80)
TxtColor2ofTF2  = close > ema2ofTF2 ? color.rgb(1, 248, 26)     : color.rgb(255, 0, 0)
Diff_ema3ofTF2  = close - ema2ofTF2
Drctn_ema3ofTF2 = close > ema2ofTF2 ? "↗" : "↘"
BgColor3ofTF2   = close > ema2ofTF2 ? color.rgb(1, 248, 26, 80) : color.rgb(255, 0, 0, 80)
TxtColor3ofTF2  = close > ema3ofTF2 ? color.rgb(1, 248, 26)     : color.rgb(255, 0, 0)
Diff_ema4ofTF2  = close - ema3ofTF2
Drctn_ema4ofTF2 = close > ema3ofTF2 ? "↗" : "↘"
BgColor4ofTF2   = close > ema3ofTF2 ? color.rgb(1, 248, 26, 80) : color.rgb(255, 0, 0, 80)
TxtColor4ofTF2  = close > ema3ofTF2 ? color.rgb(1, 248, 26)     : color.rgb(255, 0, 0)

// EMA OF TIME FRAME 3
Diff_ema1ofTF3     = ema1ofTF3 - ema2ofTF3 
PDif_ema1ema2ofTF3 = math.round((ema1ofTF3-ema2ofTF3)/((ema1ofTF3+ema2ofTF3)/2)*100,2)
BulBer_ema1ofTF3   = ema1ofTF3 > ema2ofTF3 ? "\n▲ " + str.tostring(PDif_ema1ema2ofTF3) + "%" : "\n▼ " + str.tostring(PDif_ema1ema2ofTF3) + "%"
BgColor1ofTF3      = ema1ofTF3 > ema2ofTF3 ? color.rgb(34, 95, 174, 80) : color.rgb(181, 60, 0, 80)
TxtColor1ofTF3     = ema1ofTF3 > ema2ofTF3 ? color.rgb(1, 170, 248)     : color.rgb(255, 85, 0)
Diff_ema2ofTF3  = close - ema1ofTF3
Drctn_ema2ofTF3 = close > ema1ofTF3 ? "↗" : "↘"
BgColor2ofTF3   = close > ema1ofTF3 ? color.rgb(1, 248, 26, 80) : color.rgb(255, 0, 0, 80)
TxtColor2ofTF3  = close > ema2ofTF3 ? color.rgb(1, 248, 26)     : color.rgb(255, 0, 0)
Diff_ema3ofTF3  = close - ema2ofTF3
Drctn_ema3ofTF3 = close > ema2ofTF3 ? "↗" : "↘"
BgColor3ofTF3   = close > ema2ofTF3 ? color.rgb(1, 248, 26, 80) : color.rgb(255, 0, 0, 80)
TxtColor3ofTF3  = close > ema3ofTF3 ? color.rgb(1, 248, 26)     : color.rgb(255, 0, 0)
Diff_ema4ofTF3  = close - ema3ofTF3
Drctn_ema4ofTF3 = close > ema3ofTF3 ? "↗" : "↘"
BgColor4ofTF3   = close > ema3ofTF3 ? color.rgb(1, 248, 26, 80) : color.rgb(255, 0, 0, 80)
TxtColor4ofTF3  = close > ema3ofTF3 ? color.rgb(1, 248, 26)     : color.rgb(255, 0, 0)

// EMA OF TIME FRAME 4
Diff_ema1ofTF4     = ema1ofTF4 - ema2ofTF4 
PDif_ema1ema2ofTF4 = math.round((ema1ofTF4-ema2ofTF4)/((ema1ofTF4+ema2ofTF4)/2)*100,2)
BulBer_ema1ofTF4   = ema1ofTF4 > ema2ofTF4 ? "\n▲ " + str.tostring(PDif_ema1ema2ofTF4) + "%" : "\n▼ " + str.tostring(PDif_ema1ema2ofTF4) + "%"
BgColor1ofTF4      = ema1ofTF4 > ema2ofTF4 ? color.rgb(34, 95, 174, 80) : color.rgb(181, 60, 0, 80)
TxtColor1ofTF4     = ema1ofTF4 > ema2ofTF4 ? color.rgb(1, 170, 248)  : color.rgb(255, 85, 0)
Diff_ema2ofTF4  = close - ema1ofTF4
Drctn_ema2ofTF4 = close > ema1ofTF4 ? "↗" : "↘"
BgColor2ofTF4   = close > ema1ofTF4 ? color.rgb(1, 248, 26, 80) : color.rgb(255, 0, 0, 80)
TxtColor2ofTF4  = close > ema2ofTF4 ? color.rgb(1, 248, 26)     : color.rgb(255, 0, 0)
Diff_ema3ofTF4  = close - ema2ofTF4
Drctn_ema3ofTF4 = close > ema2ofTF4 ? "↗" : "↘"
BgColor3ofTF4   = close > ema2ofTF4 ? color.rgb(1, 248, 26, 80) : color.rgb(255, 0, 0, 80)
TxtColor3ofTF4  = close > ema3ofTF4 ? color.rgb(1, 248, 26)     : color.rgb(255, 0, 0)
Diff_ema4ofTF4  = close - ema3ofTF4
Drctn_ema4ofTF4 = close > ema3ofTF4 ? "↗" : "↘"
BgColor4ofTF4   = close > ema3ofTF4 ? color.rgb(1, 248, 26, 80) : color.rgb(255, 0, 0, 80)
TxtColor4ofTF4  = close > ema3ofTF4 ? color.rgb(1, 248, 26)     : color.rgb(255, 0, 0)

// EMA OF TIMEFRAME 5
Diff_ema1ofTF5     = ema1ofTF5 - ema2ofTF5 
PDif_ema1ema2ofTF5 = math.round((ema1ofTF5-ema2ofTF5)/((ema1ofTF5+ema2ofTF5)/2)*100,2)
BulBer_ema1ofTF5   = ema1ofTF5 > ema2ofTF5 ? "\n▲ " + str.tostring(PDif_ema1ema2ofTF5) + "%" : "\n▼ " + str.tostring(PDif_ema1ema2ofTF5) + "%"
BgColor1ofTF5      = ema1ofTF5 > ema2ofTF5 ? color.rgb(34, 95, 174, 80) : color.rgb(181, 60, 0, 80)
TxtColor1ofTF5     = ema1ofTF5 > ema2ofTF5 ? color.rgb(1, 170, 248)  : color.rgb(255, 85, 0)
Diff_ema2ofTF5  = close - ema1ofTF5
Drctn_ema2ofTF5 = close > ema1ofTF5 ? "↗" : "↘"
BgColor2ofTF5   = close > ema1ofTF5 ? color.rgb(1, 248, 26, 80) : color.rgb(255, 0, 0, 80)
TxtColor2ofTF5  = close > ema2ofTF5 ? color.rgb(1, 248, 26)     : color.rgb(255, 0, 0)
Diff_ema3ofTF5  = close - ema2ofTF5
Drctn_ema3ofTF5 = close > ema2ofTF5 ? "↗" : "↘"
BgColor3ofTF5   = close > ema2ofTF5 ? color.rgb(1, 248, 26, 80) : color.rgb(255, 0, 0, 80)
TxtColor3ofTF5  = close > ema3ofTF5 ? color.rgb(1, 248, 26)     : color.rgb(255, 0, 0)
Diff_ema4ofTF5  = close - ema3ofTF5
Drctn_ema4ofTF5 = close > ema3ofTF5 ? "↗" : "↘"
BgColor4ofTF5   = close > ema3ofTF5 ? color.rgb(1, 248, 26, 80) : color.rgb(255, 0, 0, 80)
TxtColor4ofTF5  = close > ema3ofTF5 ? color.rgb(1, 248, 26)     : color.rgb(255, 0, 0)

// EMA OF TIMEFRAME 6
Diff_ema1ofTF6     = ema1ofTF6 - ema2ofTF6 
PDif_ema1ema2ofTF6 = math.round((ema1ofTF6-ema2ofTF6)/((ema1ofTF6+ema2ofTF6)/2)*100,2)
BulBer_ema1ofTF6   = ema1ofTF6 > ema2ofTF6 ? "\n▲ " + str.tostring(PDif_ema1ema2ofTF6) + "%" : "\n▼ " + str.tostring(PDif_ema1ema2ofTF6) + "%"
BgColor1ofTF6      = ema1ofTF6 > ema2ofTF6 ? color.rgb(34, 95, 174, 80) : color.rgb(181, 60, 0, 80)
TxtColor1ofTF6     = ema1ofTF6 > ema2ofTF6 ? color.rgb(1, 170, 248)  : color.rgb(255, 85, 0)
Diff_ema2ofTF6  = close - ema1ofTF6
Drctn_ema2ofTF6 = close > ema1ofTF6 ? "↗" : "↘"
BgColor2ofTF6   = close > ema1ofTF6 ? color.rgb(1, 248, 26, 80) : color.rgb(255, 0, 0, 80)
TxtColor2ofTF6  = close > ema2ofTF6 ? color.rgb(1, 248, 26)     : color.rgb(255, 0, 0)
Diff_ema3ofTF6  = close - ema2ofTF6
Drctn_ema3ofTF6 = close > ema2ofTF6 ? "↗" : "↘"
BgColor3ofTF6   = close > ema2ofTF6 ? color.rgb(1, 248, 26, 80) : color.rgb(255, 0, 0, 80)
TxtColor3ofTF6  = close > ema3ofTF6 ? color.rgb(1, 248, 26)     : color.rgb(255, 0, 0)
Diff_ema4ofTF6  = close - ema3ofTF6
Drctn_ema4ofTF6 = close > ema3ofTF6 ? "↗" : "↘"
BgColor4ofTF6   = close > ema3ofTF6 ? color.rgb(1, 248, 26, 80) : color.rgb(255, 0, 0, 80)
TxtColor4ofTF6  = close > ema3ofTF6 ? color.rgb(1, 248, 26)     : color.rgb(255, 0, 0)

TextColor = color.rgb(181, 212, 255)

// ─────────────────────────────────────────────────────────────────────────────
//  DASHBOARD — HELPER: cell placement wrapper
//  In horizontal mode (original): tc(col, row) → table.cell(col, row)
//  In vertical mode (transposed):  tc(col, row) → table.cell(row, col)
//  This keeps all the cell definitions identical regardless of orientation.
// ─────────────────────────────────────────────────────────────────────────────
// Horizontal layout dimensions: 11 columns × 11 rows
// Vertical   layout dimensions: 11 rows    × 11 columns  (same numbers, transposed)
var table ssltable = table.new(tablePosition, columns = 11, rows = 11,
     border_width = 1,
     bgcolor      = color.rgb(10, 10, 10, 50),
     border_color = color.rgb(0, 0, 0, 50))

tc(col, row, txt, txtCol, sz, bg, halign) =>
    // Swap col↔row when vertical layout is active
    _c = tableVertical ? row : col
    _r = tableVertical ? col : row
    table.cell(ssltable, _c, _r, text = txt, text_color = txtCol,
         text_size = sz, bgcolor = bg, text_halign = halign)

if barstate.islast
    if showTable
        // ── Row 0: Title row ─────────────────────────────────────────────────
        tc(0, 0, '↝=EMA\n' + 'P=' + str.tostring(math.round(close, 0)), TextColor, tableTextSize, colorTF6, text.align_center)
        tc(1, 0, f_timeframeConverter(TF1) + '\n' + '↨  Diff', TextColor, tableTextSize, colorTF1, text.align_center)
        tc(2, 0, f_timeframeConverter(TF2) + '\n' + '↨  Diff', TextColor, tableTextSize, colorTF2, text.align_center)
        tc(3, 0, f_timeframeConverter(TF3) + '\n' + '↨  Diff', TextColor, tableTextSize, colorTF3, text.align_center)
        tc(4, 0, f_timeframeConverter(TF4) + '\n' + '↨  Diff', TextColor, tableTextSize, colorTF4, text.align_center)
        tc(5, 0, f_timeframeConverter(TF5) + '\n' + '↨  Diff', TextColor, tableTextSize, colorTF5, text.align_center)
        tc(6, 0, f_timeframeConverter(TF6) + '\n' + '↨  Diff', TextColor, tableTextSize, colorTF6, text.align_center)

        // ── Column 0: Metric labels ───────────────────────────────────────────
        tc(0, 2, '↝' + str.tostring(math.round(len1, 0)) + ' ↨ ↝' + str.tostring(math.round(len2, 0)) + '\nPosition', TxtColor1ofTF6, tableTextSize, colorTF6, text.align_right)
        tc(0, 4, 'P ↨ ↝' + str.tostring(math.round(len1, 0)), color.new(color.blue,   0), tableTextSize, colorTF2, text.align_right)
        tc(0, 5, 'P ↨ ↝' + str.tostring(math.round(len2, 0)), color.new(color.orange, 0), tableTextSize, colorTF3, text.align_right)
        tc(0, 6, 'P ↨ ↝' + str.tostring(math.round(len3, 0)), color.new(color.white,  0), tableTextSize, colorTF4, text.align_right)

        // ── TF1 data ──────────────────────────────────────────────────────────
        tc(1, 2, '⇝ $' + str.tostring(math.round(Diff_ema1ofTF1, 0)) + BulBer_ema1ofTF1, TxtColor1ofTF1, tableTextSize, BgColor1ofTF1, text.align_left)
        tc(1, 4, Drctn_ema2ofTF1 + '$' + str.tostring(math.round(Diff_ema2ofTF1, 0)),     TxtColor2ofTF1, tableTextSize, BgColor2ofTF1, text.align_left)
        tc(1, 5, Drctn_ema3ofTF1 + '$' + str.tostring(math.round(Diff_ema3ofTF1, 0)),     TxtColor3ofTF1, tableTextSize, BgColor3ofTF1, text.align_left)
        tc(1, 6, Drctn_ema4ofTF1 + '$' + str.tostring(math.round(Diff_ema4ofTF1, 0)),     TxtColor4ofTF1, tableTextSize, BgColor4ofTF1, text.align_left)

        // ── TF2 data ──────────────────────────────────────────────────────────
        tc(2, 2, '⇝ $' + str.tostring(math.round(Diff_ema1ofTF2, 0)) + BulBer_ema1ofTF2, TxtColor1ofTF2, tableTextSize, BgColor1ofTF2, text.align_left)
        tc(2, 4, Drctn_ema2ofTF2 + '$' + str.tostring(math.round(Diff_ema2ofTF2, 0)),     TxtColor2ofTF2, tableTextSize, BgColor2ofTF2, text.align_left)
        tc(2, 5, Drctn_ema3ofTF2 + '$' + str.tostring(math.round(Diff_ema3ofTF2, 0)),     TxtColor3ofTF2, tableTextSize, BgColor3ofTF2, text.align_left)
        tc(2, 6, Drctn_ema4ofTF2 + '$' + str.tostring(math.round(Diff_ema4ofTF2, 0)),     TxtColor4ofTF2, tableTextSize, BgColor4ofTF2, text.align_left)

        // ── TF3 data ──────────────────────────────────────────────────────────
        tc(3, 2, '⇝ $' + str.tostring(math.round(Diff_ema1ofTF3, 0)) + BulBer_ema1ofTF3, TxtColor1ofTF3, tableTextSize, BgColor1ofTF3, text.align_left)
        tc(3, 4, Drctn_ema2ofTF3 + '$' + str.tostring(math.round(Diff_ema2ofTF3, 0)),     TxtColor2ofTF3, tableTextSize, BgColor2ofTF3, text.align_left)
        tc(3, 5, Drctn_ema3ofTF3 + '$' + str.tostring(math.round(Diff_ema3ofTF3, 0)),     TxtColor3ofTF3, tableTextSize, BgColor3ofTF3, text.align_left)
        tc(3, 6, Drctn_ema4ofTF3 + '$' + str.tostring(math.round(Diff_ema4ofTF3, 0)),     TxtColor4ofTF3, tableTextSize, BgColor4ofTF3, text.align_left)

        // ── TF4 data ──────────────────────────────────────────────────────────
        tc(4, 2, '⇝ $' + str.tostring(math.round(Diff_ema1ofTF4, 0)) + BulBer_ema1ofTF4, TxtColor1ofTF4, tableTextSize, BgColor1ofTF4, text.align_left)
        tc(4, 4, Drctn_ema2ofTF4 + '$' + str.tostring(math.round(Diff_ema2ofTF4, 0)),     TxtColor2ofTF4, tableTextSize, BgColor2ofTF4, text.align_left)
        tc(4, 5, Drctn_ema3ofTF4 + '$' + str.tostring(math.round(Diff_ema4ofTF4, 0)),     TxtColor3ofTF4, tableTextSize, BgColor3ofTF4, text.align_left)
        tc(4, 6, Drctn_ema4ofTF4 + '$' + str.tostring(math.round(Diff_ema4ofTF4, 0)),     TxtColor4ofTF4, tableTextSize, BgColor4ofTF4, text.align_left)

        // ── TF5 data ──────────────────────────────────────────────────────────
        tc(5, 2, '⇝ $' + str.tostring(math.round(Diff_ema1ofTF5, 0)) + BulBer_ema1ofTF5, TxtColor1ofTF5, tableTextSize, BgColor1ofTF5, text.align_left)
        tc(5, 4, Drctn_ema2ofTF5 + '$' + str.tostring(math.round(Diff_ema2ofTF5, 0)),     TxtColor2ofTF5, tableTextSize, BgColor2ofTF5, text.align_left)
        tc(5, 5, Drctn_ema3ofTF5 + '$' + str.tostring(math.round(Diff_ema3ofTF5, 0)),     TxtColor3ofTF5, tableTextSize, BgColor3ofTF5, text.align_left)
        tc(5, 6, Drctn_ema4ofTF5 + '$' + str.tostring(math.round(Diff_ema4ofTF5, 0)),     TxtColor4ofTF5, tableTextSize, BgColor4ofTF5, text.align_left)

        // ── TF6 data ──────────────────────────────────────────────────────────
        tc(6, 2, '⇝ $' + str.tostring(math.round(Diff_ema1ofTF6, 0)) + BulBer_ema1ofTF6, TxtColor1ofTF6, tableTextSize, BgColor1ofTF6, text.align_left)
        tc(6, 4, Drctn_ema2ofTF6 + '$' + str.tostring(math.round(Diff_ema2ofTF6, 0)),     TxtColor2ofTF6, tableTextSize, BgColor2ofTF6, text.align_left)
        tc(6, 5, Drctn_ema3ofTF6 + '$' + str.tostring(math.round(Diff_ema3ofTF6, 0)),     TxtColor3ofTF6, tableTextSize, BgColor3ofTF6, text.align_left)
        tc(6, 6, Drctn_ema4ofTF6 + '$' + str.tostring(math.round(Diff_ema4ofTF6, 0)),     TxtColor4ofTF6, tableTextSize, BgColor4ofTF6, text.align_left)

////////////////////////////////////////
////   End main EMA monitor Script   ///
////////////////////////////////////////



////////////////////////////////////////////////////////////////
///////               BREAKOUT PROBABILITY                  ////
////////////////////////////////////////////////////////////////
t1 = 'The space between the levels can be adjusted with a percentage step. 1% means that each level is located 1% above/under the previous one.'
t2 = 'Set the number of levels you want to display.'
t3 = 'If a level got 0% likelihood of being hit, the level is not displayed as default. Enable the option if you want to see all levels regardless of their values.'
t4 = 'Enable this option if you want to display the backtest statistics for that a new high or low is made.'
array<string> tbl_tips = array.from('Number of times price has reached the first highest percentage level', 'Number of times price failed to reach the first highest percentage level', 'Reached/Failed ratio')

showBOP = input(title='Show Break Out Probability Meter', defval=false, group='🟧 Break Out Probability Meter')
perc = input.float(0.5, title = 'Percentage Step', step = .1, minval = 0, group = 'Settings', tooltip = t1)
nbr = input.int(5, title = 'Number of Lines', maxval = 5, minval = 1, group = 'Settings', tooltip = t2)
LabelTextSize = input.string(title = 'Label Size?', defval = size.tiny, options = [size.auto, size.tiny, size.small, size.normal, size.large, size.huge], tooltip = 'Use Tiny if on Mobile, Use Small if on Web browser.')
TupCol = input.color(color.rgb(181, 212, 249), title = 'Labels', inline = 'col')
TdnCol = input.color(color.rgb(137, 159, 186), title = '', inline = 'col')
fill   = input.bool(true, title = 'Meter Background Shade')
upCol  = input.color(color.rgb(101, 119, 140), title = 'Background', inline = 'Scol')
dnCol  = input.color(color.rgb(62, 72, 86), title = '', inline = 'Scol')
offset = input.int(20,'Meter Offset (Horizontal)', maxval = 50, minval = -5)
var array<bool> bools = array.from(input.bool(false, title = 'Disable 0.00%', group = 'Settings', tooltip = t3), input.bool(false, title = 'Show Statistic Panel', group = 'Settings', tooltip = t4))
var array<bool> alert_bool = array.from(input.bool(true, title = 'Ticker ID', group = 'Any alert() function call'), input.bool(true, title = 'High/Low Price', group = 'Any alert() function call'), input.bool(true, title = 'Bullish/Bearish Bias', group = 'Any alert() function call'), input.bool(true, title = 'Bullish/Bearish Percentage', group = 'Any alert() function call'))

b = bar_index
o = open
h = high
l = low
c = close
step = c * (perc / 100)

var total = matrix.new<int>(7, 4, 0)
var vals = matrix.new<float>(5, 4, 0.0)
var markers = matrix.new<line>(1, 10, line(na))
var labels = matrix.new<label>(1, 10, label(na))
var tbl = matrix.new<table>(1, 1, table.new(position.bottom_center, 2, 3, frame_color = color.rgb(19, 19, 19, 70), frame_width = 3, border_color = chart.bg_color, border_width = -2))

green = c[1] > o[1]
red = c[1] < o[1]
if green
    prev = matrix.get(total, 5, 0)
    matrix.set(total, 5, 0, prev + 1)
if red
    prev = matrix.get(total, 5, 1)
    matrix.set(total, 5, 1, prev + 1)

CreateLine(p, i, c) =>
    prevLine = matrix.get(markers, 0, i)
    line.delete(prevLine)
    li = line.new(b + offset, p, b + offset + 1, p, color = c, width = 1)
    matrix.set(markers, 0, i, li)
CreateLabel(p, i, c, r, v) =>
    prevLabel = matrix.get(labels, 0, i)
    label.delete(prevLabel)
    la = label.new(b + offset + 1, p, text = str.tostring(matrix.get(vals, r, v), '0') + '%', style = label.style_label_right, color = color.new(color.black, 100), textcolor = c, size = LabelTextSize)
    matrix.set(labels, 0, i, la)
Score(x, i) =>
    ghh = matrix.get(total, i, 0)
    gll = matrix.get(total, i, 1)
    rhh = matrix.get(total, i, 2)
    rll = matrix.get(total, i, 3)
    gtotal = matrix.get(total, 5, 0)
    rtotal = matrix.get(total, 5, 1)
    hh = h >= h[1] + x
    ll = l <= l[1] - x
    if green and hh
        matrix.set(total, i, 0, ghh + 1)
        matrix.set(vals, i, 0, math.round((ghh + 1) / gtotal * 100, 2))
    if green and ll
        matrix.set(total, i, 1, gll + 1)
        matrix.set(vals, i, 1, math.round((gll + 1) / gtotal * 100, 2))
    if red and hh
        matrix.set(total, i, 2, rhh + 1)
        matrix.set(vals, i, 2, math.round((rhh + 1) / rtotal * 100, 2))
    if red and ll
        matrix.set(total, i, 3, rll + 1)
        matrix.set(vals, i, 3, math.round((rll + 1) / rtotal * 100, 2))
Backtest(v) =>
    p1 = matrix.get(total, 6, 0)
    p2 = matrix.get(total, 6, 1)
    if v == h[1]
        if h >= v
            matrix.set(total, 6, 0, p1 + 1)
        else
            matrix.set(total, 6, 1, p2 + 1)
    else
        if l <= v
            matrix.set(total, 6, 0, p1 + 1)
        else
            matrix.set(total, 6, 1, p2 + 1)

Score(0, 0)
Score(step, 1)
Score(step * 2, 2)
Score(step * 3, 3)
Score(step * 4, 4)

a1 = matrix.get(vals, 0, 0)
b1 = matrix.get(vals, 0, 1)
a2 = matrix.get(vals, 0, 2)
b2 = matrix.get(vals, 0, 3)

if showBOP
    for i = 0 to nbr - 1 by 1
        hide = array.get(bools, 0)
        if not hide or hide and (green ? math.min(matrix.get(vals, i, 0), matrix.get(vals, i, 1)) > 0 : math.min(matrix.get(vals, i, 2), matrix.get(vals, i, 3)) > 0)
            hi = h[1] + step * i
            lo = l[1] - step * i
            CreateLine(hi, i,     upCol)
            CreateLine(lo, 5 + i, dnCol)
            if green
                CreateLabel(hi, i,     TupCol, i, 0)
                CreateLabel(lo, 5 + i, TdnCol, i, 1)
            else
                CreateLabel(hi, i,     TupCol, i, 2)
                CreateLabel(lo, 5 + i, TdnCol, i, 3)
            if array.includes(alert_bool, true)
                s1 = str.tostring(syminfo.ticker)
                s2 = 'High Price: ' + str.tostring(math.round_to_mintick(h[1])) + ' | Low Price: ' + str.tostring(math.round_to_mintick(l[1]))
                s3 = green ? math.max(a1, b1) == a1 ? 'BULL' : 'BEAR' : math.max(a2, b2) == a2 ? 'BULL' : 'BEAR'
                s4 = green ? math.max(a1, b1) == a1 ? a1 : b1 : math.min(a2, b2) == a2 ? a2 : b2
                s5 = red   ? math.max(a2, b2) == a2 ? a2 : b2 : math.min(a1, b1) == a1 ? a1 : b1
                array<string> str_vals = array.from(s1, s2, 'BIAS: ' + s3, 'Percentage: High: ' + str.tostring(s4, format.percent) + ' | Low: ' + str.tostring(s5, format.percent))
                output = array.new_string()
                for x = 0 to array.size(alert_bool) - 1 by 1
                    if array.get(alert_bool, x)
                        array.push(output, array.get(str_vals, x))
                alert(array.join(output, '\n'), alert.freq_once_per_bar)
        else
            line.delete(matrix.get(markers, 0, i))
            line.delete(matrix.get(markers, 0, 5 + i))
            label.delete(matrix.get(labels, 0, i))
            label.delete(matrix.get(labels, 0, 5 + i))

Backtest(green ? math.max(a1, b1) == a1 ? h[1] : l[1] : math.max(a2, b2) == a2 ? h[1] : l[1])

if fill
    var filler = linefill(na)
    for i = 0 to 8 by 1
        get = matrix.get(markers, 0, i)
        get1 = matrix.get(markers, 0, i + 1)
        col = i > 4 ? color.new(dnCol, 60) : i == 4 ? color.new(color.gray, 100) : color.new(upCol, 60)
        filler := linefill.new(get, get1, color = col)
        linefill.delete(filler[1])

if barstate.islast and array.get(bools, 1)
    W = matrix.get(total, 6, 0)
    L = matrix.get(total, 6, 1)
    WR = math.round(W / (W + L) * 100, 2)
    array<string> tbl_vals = array.from('✔️ ' + str.tostring(W) + 'x', '✖️ ' + str.tostring(L) + 'x', '☑️ ' + str.tostring(WR, format.percent))
    array<color> tbl_col = array.from(color.rgb(255, 255, 255), color.rgb(255, 255, 255), chart.fg_color)
    for i = 0 to 2 by 1
        table.cell(matrix.get(tbl, 0, 0), 0, i, array.get(tbl_vals, i), text_halign = text.align_left, bgcolor = chart.bg_color, text_color = array.get(tbl_col, i), text_size = size.tiny, tooltip = array.get(tbl_tips, i))

////////////////////////////////////////
////     End Breakout Probability    ///
////////////////////////////////////////



//////////////////////////////
////////////////////////////// ZigZag
//////////////////////////////

period              = input.int(20, step=1, minval=5, title='Length', group='🟧 ZigZag', display=display.none)
showSR              = input(true, title='SR Lines', display=display.none)
showLabels          = input(true, title='Labels', group='Show', inline='length1', display=display.none)
showZZ              = input(true, title='ZigZag', group='Show', inline='length1', display=display.none)

HHColor             = color.rgb(76, 175, 80)
LHColor             = color.rgb(102, 255, 0)
LLColor             = color.rgb(255, 82, 82)
HLColor             = color.rgb(0, 230, 118)

var ZZvalues        = array.new_float(0)
var ZZindexes       = array.new_int(0)
var ZZdir           = array.new_int(0)

int max_array_size  = 100
var lineArray       = array.new_line(0)
var labelArray      = array.new_label(0)
var line dottedLine = na

pivot(period)=>
    float p_h       = ta.highestbars(high, period) == 0 ? high : na
    float p_l       = ta.lowestbars(low, period) == 0 ? low : na
    dir = 0
    iff_1 = not na(p_l) and na(p_h) ? -1 : dir[1]
    dir := not na(p_h) and na(p_l) ? 1 : iff_1
    [dir, p_h, p_l]

add_to_array(value, index, dir) =>
    mult = array.size(ZZvalues) < 2 ? 1 : dir * value > dir * array.get(ZZvalues, 1) ? 2 : 1
    array.unshift(ZZindexes, index)
    array.unshift(ZZvalues, value)
    array.unshift(ZZdir, dir * mult)
    if array.size(ZZindexes) > max_array_size
        array.pop(ZZindexes)
        array.pop(ZZvalues)
        array.pop(ZZdir)

add_to_zz(dir, dirchanged, p_h, p_l, index) =>
    value = dir == 1 ? p_h : p_l
    if array.size(ZZvalues) == 0 or dirchanged != 0
        add_to_array(value, index, dir)
    else if dir == 1 and value > array.get(ZZvalues, 0) or dir == -1 and value < array.get(ZZvalues, 0)
        array.shift(ZZvalues)
        array.shift(ZZindexes)
        array.shift(ZZdir)
        add_to_array(value, index, dir)
        
zz(length) =>
    [dir, p_h, p_l] = pivot(length)
    dirchanged = ta.change(dir)
    if not na(p_h) or not na(p_l)
        add_to_zz(dir, dirchanged, p_h, p_l, bar_index)
zz(period)

if barstate.isconfirmed and array.size(ZZindexes) > 1
    lastHigh = 0.0
    lastLow = 0.0
    for x = 0 to array.size(ZZindexes) - 1 by 1
        i = array.size(ZZindexes) - 1 - x
        index = array.get(ZZindexes, i)
        value = array.get(ZZvalues, i)
        highLow = array.get(ZZdir, i)
        index_offset = bar_index - index
        labelText     = highLow == 2 ? 'HH'    : highLow == 1 ? 'LH'    : highLow == -1 ? 'HL'    : 'LL'
        labelColor    = highLow == 2 ? HHColor : highLow == 1 ? LHColor : highLow == -1 ? HLColor : LLColor
        lineColor     = highLow == 2 ? HHColor : highLow == 1 ? LHColor : highLow == -1 ? HLColor : LLColor
        SRColor       = highLow == 2 ? LLColor : highLow == 1 ? LLColor : highLow == -1 ? HHColor : HHColor
        SRColor0      = highLow == 2 ? HHColor : highLow == 1 ? HHColor : highLow == -1 ? LLColor : LLColor
        labelStyle    = highLow > 0  ? label.style_label_down : label.style_label_up
        labelLocation = yloc.price
        if showLabels
            l = label.new(x=index, y=value, xloc=xloc.bar_index, yloc=labelLocation, style=labelStyle, size=size.tiny, color=labelColor,text=labelText)
            array.unshift(labelArray, l)
            if array.size(labelArray) > max_array_size
                label.delete(array.pop(labelArray))
        if i < array.size(ZZindexes) - 1 and showZZ
            indexLast = array.get(ZZindexes, i + 1)
            valueLast = array.get(ZZvalues, i + 1)
            l = line.new(x1=index, y1=value, x2=indexLast, y2=valueLast, color=labelColor, width=2, style=line.style_solid)
            array.unshift(lineArray, l)
            if array.size(lineArray) > max_array_size
                line.delete(array.pop(lineArray))
        if i < array.size(ZZindexes) - 1 and showSR
            indexLast = array.get(ZZindexes, i + 1)
            valueLast = array.get(ZZvalues, i + 1)
            line.new(x1=index, y1=valueLast, x2=indexLast, y2=valueLast, color=SRColor, width=2, style=line.style_dotted)
            if i==0    
                if na(dottedLine)
                    dottedLine := line.new(x1=index, y1=value, x2=bar_index, y2=value, color=SRColor0, width=2, style=line.style_dotted)
            if bar_index >= indexLast and i==0
                dottedLine := na

//////////////////////////////
////////////////////////////// ZigZag | End
//////////////////////////////



//////////////////////////////
////////////////////////////// RSI
//////////////////////////////

rstime1 = input.timeframe(title='Resolution 1', defval='5',  group = '🟧 MTF RSI')
rstime2 = input.timeframe(title='Resolution 2', defval='15')
rstime3 = input.timeframe(title='Resolution 3', defval='60')
rstime4 = input.timeframe(title='Resolution 4', defval='240')
rstime5 = input.timeframe(title='Resolution 5', defval='D')
rstime6 = input.timeframe(title='Resolution 6', defval='W')

cell_up_max  = input.color(color.rgb(72, 255, 0),   'Max Bullish Cell Color')
cell_up_med  = input.color(color.rgb(87, 173, 0),   'Med Bullish Cell Color')
cell_up_min  = input.color(color.rgb(45, 85, 0),    'Min Bullish Cell Color')
cell_neutral = input.color(color.rgb(111, 111, 111),'Neutral Cell Color')
cell_dn_min  = input.color(color.rgb(110, 0, 0),    'Min Bearish Cell Color')
cell_dn_med  = input.color(color.rgb(183, 0, 0),    'Med Bearish Cell Color')
cell_dn_max  = input.color(color.rgb(255, 0, 0),    'Max Bearish Cell Color')
cell_transp  = input.int(20, 'Cell Transparency', minval=0, maxval=100, group='Style Settings')

len = input.int(14, minval=1, title='Length')
up   = ta.rma(math.max(ta.change(close), 0), len)
down = ta.rma(-math.min(ta.change(close), 0), len)

vsi1 = request.security(syminfo.tickerid, rstime1, down == 0 ? 100 : up == 0 ? 0 : 100 - 100 / (1 + up / down))
vsi2 = request.security(syminfo.tickerid, rstime2, down == 0 ? 100 : up == 0 ? 0 : 100 - 100 / (1 + up / down))
vsi3 = request.security(syminfo.tickerid, rstime3, down == 0 ? 100 : up == 0 ? 0 : 100 - 100 / (1 + up / down))
vsi4 = request.security(syminfo.tickerid, rstime4, down == 0 ? 100 : up == 0 ? 0 : 100 - 100 / (1 + up / down))
vsi5 = request.security(syminfo.tickerid, rstime5, down == 0 ? 100 : up == 0 ? 0 : 100 - 100 / (1 + up / down))
vsi6 = request.security(syminfo.tickerid, rstime6, down == 0 ? 100 : up == 0 ? 0 : 100 - 100 / (1 + up / down))

f_fillCell(_table, _column, _row, _value) =>
    _c_color = _value >= 75 ? cell_up_max : _value < 75 and _value >= 65 ? cell_up_med : _value < 65 and _value >= 55 ? cell_up_min : _value <= 45 and _value > 35 ? cell_dn_min : _value <= 35 and _value > 25 ? cell_dn_med : _value <= 25 ? cell_dn_max : cell_neutral
    _cellText = str.tostring(_value, '0')
    // RSI row/col also respects the orientation toggle
    _c = tableVertical ? _row : _column
    _r = tableVertical ? _column : _row
    table.cell(_table, _c, _r, _cellText, bgcolor=color.new(_c_color, cell_transp), text_color=color.white, width=2, text_size=size.tiny)

// RSI label cell — col=0, row=8 in logical space
_rsiLabelC = tableVertical ? 8 : 0
_rsiLabelR = tableVertical ? 0 : 8
table.cell(ssltable, _rsiLabelC, _rsiLabelR, 'RSI', bgcolor=color.rgb(10, 10, 10, 50), text_color=color.rgb(255, 77, 1), width=2, text_size=size.tiny, text_halign=text.align_right)

if barstate.islast
    f_fillCell(ssltable, 1, 8, vsi1)
    f_fillCell(ssltable, 2, 8, vsi2)
    f_fillCell(ssltable, 3, 8, vsi3)
    f_fillCell(ssltable, 4, 8, vsi4)
    f_fillCell(ssltable, 5, 8, vsi5)
    f_fillCell(ssltable, 6, 8, vsi6)

//////////////////////////////
////////////////////////////// RSI | End
//////////////////////////////


// RSI DIVERGENCE — all remaining code unchanged from original
rsiGroup = '🟧 RSI Divergence'
lenght = input.int(title='RSI Period', minval=1, defval=14, group=rsiGroup, tooltip='The number of bars used to calculate the RSI. The standard value is 14.')
src = close
divsrc = input.string(title='Use Price Wicks or Bodies?', defval='Bodies', options=['Wicks', 'Bodies'], group=rsiGroup, tooltip="Determines whether to use candle wicks (high/low) or candle bodies (max/min of open/close) for detecting price pivots. 'Wicks' is more sensitive to volatility.")
lbL = input.int(title='Pivot Lookback Left', defval=5, inline='Direction', group=rsiGroup, tooltip='The number of bars to the left and right of a pivot. A higher Left value finds more significant, longer-term pivots. A pivot is only confirmed after Right bars have passed.')
lbR = input.int(title='Right', defval=3, inline='Direction', group=rsiGroup)
rangeUpper = input.int(title='Lookback Range Max', defval=60, inline='Range', group=rsiGroup, tooltip='The maximum and minimum number of bars allowed between two pivots for a divergence to be considered valid.')
rangeLower = input.int(title='Min', defval=5, inline='Range', group=rsiGroup)
plotBull = input.bool(title='Plot Bullish', defval=true, inline='Bullish', group=rsiGroup, tooltip='Toggles the display of Confirmed Regular (first box) and Hidden (second box) Bullish divergences.')
plotHiddenBull = input.bool(title='Hidden', defval=false, inline='Bullish', group=rsiGroup)
plotBear = input.bool(title='Plot Bearish', defval=true, inline='Bearish', group=rsiGroup, tooltip='Toggles the display of Confirmed Regular (first box) and Hidden (second box) Bearish divergences.')
plotHiddenBear = input.bool(title='Hidden', defval=false, inline='Bearish', group=rsiGroup)
predictiveGroup = 'Predictive Divergences'
showPredictive = input.bool(true, 'Show Predictive Divergences', group=predictiveGroup, tooltip='Master switch to enable or disable all real-time predictive divergence analysis on the current (live) bar.')
potentialMinBars = input.int(5, 'Min Bars Since Last Pivot for Predictive', group=predictiveGroup, tooltip='The minimum number of bars that must pass since the last pivot before the script starts looking for a new potential divergence.')
showThreshold = input.bool(true, 'Show Divergence Confirmation Price', group=predictiveGroup, tooltip='Toggles the display of the projection line and label for the Confirmation Price on the live bar.')
alertGroup = 'Alerts'
alertOnPotentialBull = input.bool(true, "Alert on Potential Bullish", group=alertGroup, inline="PotBull", tooltip="Triggers an alert when a potential divergence is first detected. Use the first box for Regular Bullish and the second for Hidden Bullish. To use, create one alert on the chart and set its condition to 'Any alert() function call'.")
alertOnPotentialHiddenBull = input.bool(false, "Hidden", group=alertGroup, inline="PotBull")
alertOnPotentialBear = input.bool(true, "Alert on Potential Bearish", group=alertGroup, inline="PotBear", tooltip="Triggers an alert when a potential divergence is first detected. Use the first box for Regular Bearish and the second for Hidden Bearish.")
alertOnPotentialHiddenBear = input.bool(false, "Hidden", group=alertGroup, inline="PotBear")
strengthGroup = 'Divergence Strength Score'
showStrength = input.bool(true, 'Show Strength Score', group=strengthGroup, tooltip='If checked, the score (out of 10) will be displayed on the real-time projection label and included in alerts.')
rsiOB_L1 = input.int(70, 'RSI Overbought Level 1', group=strengthGroup, inline="OB", tooltip='Defines the RSI levels for overbought conditions, used to calculate the Location Score. Level 2 is for more extreme conditions and results in a higher score.')
rsiOB_L2 = input.int(80, 'Level 2', group=strengthGroup, inline="OB")
rsiOS_L1 = input.int(30, 'RSI Oversold Level 1', group=strengthGroup, inline="OS", tooltip='Defines the RSI levels for oversold conditions, used to calculate the Location Score. Level 2 is for more extreme conditions and results in a higher score.')
rsiOS_L2 = input.int(20, 'Level 2', group=strengthGroup, inline="OS")

bearColor = #DE071C
bullColor = #0CAB07
hiddenBullColor = #8BDE7A
hiddenBearColor = #DEA7A6
textColor = color.white
noneColor = color.new(color.white, 100)

osc = ta.rsi(src, lenght)
plFound = na(ta.pivotlow(osc, lbL, lbR)) ? false : true
phFound = na(ta.pivothigh(osc, lbL, lbR)) ? false : true

_inRange(cond) =>
    bars = ta.barssince(cond == true)
    rangeLower <= bars and bars <= rangeUpper

srch = divsrc == 'Wicks' ? high : math.max(close, open)
srcl = divsrc == 'Wicks' ? low : math.min(close, open)

oscHL = osc[lbR] > ta.valuewhen(plFound, osc[lbR], 1) and _inRange(plFound[1])
priceLL = srcl[lbR] < ta.valuewhen(plFound, srcl[lbR], 1)
bullCond = plotBull and priceLL and oscHL and plFound
plot(plFound ? srcl[lbR] : na, offset=-lbR, title='Regular Bullish', linewidth=2, color=bullCond ? bullColor : noneColor)
plotshape(bullCond ? srcl[lbR] : na, offset=-lbR, title='Regular Bullish Label', text=' B ', style=shape.labelup, location=location.absolute, color=color.new(bullColor, 50), textcolor=color.new(textColor, 50))

oscLL = osc[lbR] < ta.valuewhen(plFound, osc[lbR], 1) and _inRange(plFound[1])
priceHL = srcl[lbR] > ta.valuewhen(plFound, srcl[lbR], 1)
hiddenBullCond = plotHiddenBull and priceHL and oscLL and plFound
plot(plFound ? srcl[lbR] : na, offset=-lbR, title='Hidden Bullish', linewidth=2, color=hiddenBullCond ? hiddenBullColor : noneColor)
plotshape(hiddenBullCond ? srcl[lbR] : na, offset=-lbR, title='Hidden Bullish Label', text=' HB ', style=shape.labelup, location=location.absolute, color=color.new(bullColor, 50), textcolor=color.new(textColor, 50))

oscLH = osc[lbR] < ta.valuewhen(phFound, osc[lbR], 1) and _inRange(phFound[1])
priceHH = srch[lbR] > ta.valuewhen(phFound, srch[lbR], 1)
bearCond = plotBear and priceHH and oscLH and phFound
plot(phFound ? srch[lbR] : na, offset=-lbR, title='Regular Bearish', linewidth=2, color=bearCond ? bearColor : noneColor)
plotshape(bearCond ? srch[lbR] : na, offset=-lbR, title='Regular Bearish Label', text=' B ', style=shape.labeldown, location=location.absolute, color=color.new(bearColor, 50), textcolor=color.new(textColor, 50))

oscHH = osc[lbR] > ta.valuewhen(phFound, osc[lbR], 1) and _inRange(phFound[1])
priceLH = srch[lbR] < ta.valuewhen(phFound, srch[lbR], 1)
hiddenBearCond = plotHiddenBear and priceLH and oscHH and phFound
plot(phFound ? srch[lbR] : na, offset=-lbR, title='Hidden Bearish', linewidth=2, color=hiddenBearCond ? hiddenBearColor : noneColor)
plotshape(hiddenBearCond ? srch[lbR] : na, offset=-lbR, title='Hidden Bearish Label', text=' HB ', style=shape.labeldown, location=location.absolute, color=color.new(bearColor, 50), textcolor=color.new(textColor, 50))

change = ta.change(close)
gain = change > 0 ? change : 0
loss = change < 0 ? -change : 0
avg_gain = ta.rma(gain, lenght)
avg_loss = ta.rma(loss, lenght)

var float lastPriceLow = na, var float lastRsiLow = na, var int lastLowBar = na
var float lastPriceHigh = na, var float lastRsiHigh = na, var int lastHighBar = na

if plFound
    lastPriceLow := srcl[lbR], lastRsiLow := osc[lbR], lastLowBar := bar_index - lbR
if phFound
    lastPriceHigh := srch[lbR], lastRsiHigh := osc[lbR], lastHighBar := bar_index - lbR

f_threshold_close(rsi_target, prev_avg_gain, prev_avg_loss, _lenght, prev_close) =>
    if rsi_target >= 100 or rsi_target <= 0
        na
    else
        rs_target = rsi_target / (100.0 - rsi_target)
        required_avg_gain_g = rs_target * (prev_avg_loss * (_lenght - 1.0)) / _lenght
        required_gain = (required_avg_gain_g * _lenght) - (prev_avg_gain * (_lenght - 1.0))
        close_if_gain = required_gain > 0 ? prev_close + required_gain : na
        required_avg_loss_l = ((prev_avg_gain * (_lenght - 1.0)) / _lenght) / rs_target
        required_loss = (required_avg_loss_l * _lenght) - (prev_avg_loss * (_lenght - 1.0))
        close_if_loss = required_loss > 0 ? prev_close - required_loss : na
        float rsi_if_gain = na
        if not na(close_if_gain)
            change_g = close_if_gain - prev_close, gain_g = change_g > 0 ? change_g : 0, loss_g = change_g < 0 ? -change_g : 0
            avg_gain_g = (prev_avg_gain * (_lenght - 1) + gain_g) / _lenght, avg_loss_g = (prev_avg_loss * (_lenght - 1) + loss_g) / _lenght
            rsi_if_gain := 100 - (100 / (1 + (avg_gain_g / avg_loss_g)))
        float rsi_if_loss = na
        if not na(close_if_loss)
            change_l = close_if_loss - prev_close, gain_l = change_l > 0 ? change_l : 0, loss_l = change_l < 0 ? -change_l : 0
            avg_gain_l = (prev_avg_gain * (_lenght - 1) + gain_l) / _lenght, avg_loss_l = (prev_avg_loss * (_lenght - 1) + loss_l) / _lenght
            rsi_if_loss := 100 - (100 / (1 + (avg_gain_l / avg_loss_l)))
        diff_g = math.abs(rsi_if_gain - rsi_target), diff_l = math.abs(rsi_if_loss - rsi_target)
        na(diff_g) and na(diff_l) ? na : na(diff_g) ? close_if_loss : na(diff_l) ? close_if_gain : diff_g < diff_l ? close_if_gain : close_if_loss

f_getStrengthScore(type, rsi_p1, rsi_p2, price_p1, price_p2) =>
    int location_score = 1
    if type == 'bull'
        if rsi_p1 < rsiOS_L2 and rsi_p2 < rsiOS_L2
            location_score := 5
        else if rsi_p1 < rsiOS_L1 and rsi_p2 < rsiOS_L1
            location_score := 4
        else if rsi_p1 < rsiOS_L1 or rsi_p2 < rsiOS_L1
            location_score := 3
        else if rsi_p1 < 40 or rsi_p2 < 40
            location_score := 2
    else if type == 'bear'
        if rsi_p1 > rsiOB_L2 and rsi_p2 > rsiOB_L2
            location_score := 5
        else if rsi_p1 > rsiOB_L1 and rsi_p2 > rsiOB_L1
            location_score := 4
        else if rsi_p1 > rsiOB_L1 or rsi_p2 > rsiOB_L1
            location_score := 3
        else if rsi_p1 > 60 or rsi_p2 > 60
            location_score := 2
    else
        location_score := 3
    float price_change_pct = price_p1 != 0 ? ((price_p2 / price_p1) - 1) * 100 : 0.0
    float rsi_change_pct = rsi_p1 != 0 ? ((rsi_p2 / rsi_p1) - 1) * 100 : 0.0
    disagreement_score = math.abs(rsi_change_pct - price_change_pct)
    int magnitude_score = 1
    if disagreement_score > 100
        magnitude_score := 5
    else if disagreement_score > 75
        magnitude_score := 4
    else if disagreement_score > 50
        magnitude_score := 3
    else if disagreement_score > 25
        magnitude_score := 2
    location_score + magnitude_score

var line bullLine = na, var line hiddenBullLine = na, var line bearLine = na, var line hiddenBearLine = na
var line bullThreshLine = na, var label bullInfoLabel = na
var line hiddenBullThreshLine = na, var label hiddenBullInfoLabel = na
var line bearThreshLine = na, var label bearInfoLabel = na
var line hiddenBearThreshLine = na, var label hiddenBearInfoLabel = na
var bool isBullAlertSent = false
var bool isHiddenBullAlertSent = false
var bool isBearAlertSent = false
var bool isHiddenBearAlertSent = false

if showPredictive and barstate.islast
    line.delete(bullThreshLine), label.delete(bullInfoLabel)
    line.delete(hiddenBullThreshLine), label.delete(hiddenBullInfoLabel)
    line.delete(bearThreshLine), label.delete(bearInfoLabel)
    line.delete(hiddenBearThreshLine), label.delete(hiddenBearInfoLabel)
    bool potentialBull = not na(lastPriceLow) and bar_index - lastLowBar >= potentialMinBars and srcl < lastPriceLow and osc > lastRsiLow
    bool potentialHiddenBull = not na(lastPriceLow) and bar_index - lastLowBar >= potentialMinBars and srcl > lastPriceLow and osc < lastRsiLow
    bool potentialBear = not na(lastPriceHigh) and bar_index - lastHighBar >= potentialMinBars and srch > lastPriceHigh and osc < lastRsiHigh
    bool potentialHiddenBear = not na(lastPriceHigh) and bar_index - lastHighBar >= potentialMinBars and srch < lastPriceHigh and osc > lastRsiHigh
    if potentialBull and plotBull
        if na(bullLine)
            bullLine := line.new(lastLowBar, lastPriceLow, bar_index, srcl, color=color.green, style=line.style_dashed)
        else
            line.set_xy1(bullLine, lastLowBar, lastPriceLow), line.set_xy2(bullLine, bar_index, srcl)
    else if not na(bullLine)
        line.delete(bullLine), bullLine := na
    if potentialHiddenBull and plotHiddenBull
        if na(hiddenBullLine)
            hiddenBullLine := line.new(lastLowBar, lastPriceLow, bar_index, srcl, color=color.lime, style=line.style_dashed)
        else
            line.set_xy1(hiddenBullLine, lastLowBar, lastPriceLow), line.set_xy2(hiddenBullLine, bar_index, srcl)
    else if not na(hiddenBullLine)
        line.delete(hiddenBullLine), hiddenBullLine := na
    if potentialBear and plotBear
        if na(bearLine)
            bearLine := line.new(lastHighBar, lastPriceHigh, bar_index, srch, color=color.red, style=line.style_dashed)
        else
            line.set_xy1(bearLine, lastHighBar, lastPriceHigh), line.set_xy2(bearLine, bar_index, srch)
    else if not na(bearLine)
        line.delete(bearLine), bearLine := na
    if potentialHiddenBear and plotHiddenBear
        if na(hiddenBearLine)
            hiddenBearLine := line.new(lastHighBar, lastPriceHigh, bar_index, srch, color=color.maroon, style=line.style_dashed)
        else
            line.set_xy1(hiddenBearLine, lastHighBar, lastPriceHigh), line.set_xy2(hiddenBearLine, bar_index, srch)
    else if not na(hiddenBearLine)
        line.delete(hiddenBearLine), hiddenBearLine := na
    if showThreshold
        int lineOffset = 2
        if potentialBull and plotBull
            score = f_getStrengthScore('bull', lastRsiLow, osc, lastPriceLow, srcl)
            string strengthText = showStrength ? 'Score: ' + str.tostring(score) + '/10\n' : ''
            float confirmation_price = f_threshold_close(lastRsiLow, avg_gain[1], avg_loss[1], lenght, close[1])
            if not na(confirmation_price)
                bullThreshLine := line.new(bar_index, confirmation_price, bar_index + lineOffset, confirmation_price, color=color.new(bullColor, 20), style=line.style_solid)
                bullInfoLabel := label.new(bar_index + lineOffset, confirmation_price, 'POTENTIAL\nBULL RSI DIV.\n' + strengthText + 'Confirm @\n' + str.tostring(confirmation_price, '#,###'), color=color.new(bullColor, 80), style=label.style_label_upper_left, textcolor=textColor, textalign=text.align_left, size = size.tiny)
                if alertOnPotentialBull and not isBullAlertSent
                    string alertMsg = 'Potential Bullish RSI Divergence on ' + syminfo.ticker + ' (' + timeframe.period + ')\n' + (showStrength ? 'Score: ' + str.tostring(score) + '/10\n' : '') + 'Confirmation Price: ' + str.tostring(confirmation_price, '#,###')
                    alert(alertMsg, freq = alert.freq_once_per_bar)
                    isBullAlertSent := true
        if potentialHiddenBull and plotHiddenBull
            score = f_getStrengthScore('hiddenbull', lastRsiLow, osc, lastPriceLow, srcl)
            string strengthText = showStrength ? 'Score: ' + str.tostring(score) + '/10\n' : ''
            float confirmation_price = f_threshold_close(lastRsiLow, avg_gain[1], avg_loss[1], lenght, close[1])
            if not na(confirmation_price)
                hiddenBullThreshLine := line.new(bar_index, confirmation_price, bar_index + lineOffset, confirmation_price, color=color.new(hiddenBullColor, 20), style=line.style_solid)
                hiddenBullInfoLabel := label.new(bar_index + lineOffset, confirmation_price, 'POTENTIAL\nHBULL RSI DIV.\n' + strengthText + 'Confirm @\n' + str.tostring(confirmation_price, '#,###'), color=color.new(hiddenBullColor, 80), style=label.style_label_upper_left, textcolor=textColor, textalign=text.align_left, size = size.tiny)
                if alertOnPotentialHiddenBull and not isHiddenBullAlertSent
                    string alertMsg = 'Potential Hidden Bullish RSI Divergence on ' + syminfo.ticker + ' (' + timeframe.period + ')\n' + (showStrength ? 'Score: ' + str.tostring(score) + '/10\n' : '') + 'Confirmation Price: ' + str.tostring(confirmation_price, '#,###')
                    alert(alertMsg, freq = alert.freq_once_per_bar)
                    isHiddenBullAlertSent := true
        if potentialBear and plotBear
            score = f_getStrengthScore('bear', lastRsiHigh, osc, lastPriceHigh, srch)
            string strengthText = showStrength ? 'Score: ' + str.tostring(score) + '/10\n' : ''
            float confirmation_price = f_threshold_close(lastRsiHigh, avg_gain[1], avg_loss[1], lenght, close[1])
            if not na(confirmation_price)
                bearThreshLine := line.new(bar_index, confirmation_price, bar_index + lineOffset, confirmation_price, color=color.new(bearColor, 20), style=line.style_solid)
                bearInfoLabel := label.new(bar_index + lineOffset, confirmation_price, 'POTENTIAL\nBEAR RSI DIV.\n' + strengthText + 'Confirm @\n' + str.tostring(confirmation_price, '$#,###'), color=color.new(bearColor, 80), style=label.style_label_lower_left, textcolor=textColor, textalign=text.align_left, size = size.tiny)
                if alertOnPotentialBear and not isBearAlertSent
                    string alertMsg = 'Potential Bearish RSI Divergence on ' + syminfo.ticker + ' (' + timeframe.period + ')\n' + (showStrength ? 'Score: ' + str.tostring(score) + '/10\n' : '') + 'Confirmation Price: ' + str.tostring(confirmation_price, '$#,###')
                    alert(alertMsg, freq = alert.freq_once_per_bar)
                    isBearAlertSent := true
        if potentialHiddenBear and plotHiddenBear
            score = f_getStrengthScore('hiddenbear', lastRsiHigh, osc, lastPriceHigh, srch)
            string strengthText = showStrength ? 'Score: ' + str.tostring(score) + '/10\n' : ''
            float confirmation_price = f_threshold_close(lastRsiHigh, avg_gain[1], avg_loss[1], lenght, close[1])
            if not na(confirmation_price)
                hiddenBearThreshLine := line.new(bar_index, confirmation_price, bar_index + lineOffset, confirmation_price, color=color.new(hiddenBearColor, 20), style=line.style_solid)
                hiddenBearInfoLabel := label.new(bar_index + lineOffset, confirmation_price, 'POTENTIAL\nHBEAR RSI DIV.\n' + strengthText + 'Confirm @\n' + str.tostring(confirmation_price, '#.##'), color=color.new(hiddenBearColor, 80), style=label.style_label_lower_left, textcolor=textColor, textalign=text.align_left, size = size.tiny)
                if alertOnPotentialHiddenBear and not isHiddenBearAlertSent
                    string alertMsg = 'Potential Hidden Bearish RSI Divergence on ' + syminfo.ticker + ' (' + timeframe.period + ')\n' + (showStrength ? 'Score: ' + str.tostring(score) + '/10\n' : '') + 'Confirmation Price: ' + str.tostring(confirmation_price, '$#,###')
                    alert(alertMsg, freq = alert.freq_once_per_bar)
                    isHiddenBearAlertSent := true
    if not potentialBull
        isBullAlertSent := false
    if not potentialHiddenBull
        isHiddenBullAlertSent := false
    if not potentialBear
        isBearAlertSent := false
    if not potentialHiddenBear
        isHiddenBearAlertSent := false



////////////////////////////////////////////////////////////////
///////                   SWING PIVOTS                      ////
////////////////////////////////////////////////////////////////

//█ OVERVIEW

//The Swing Pivots indicator uses relevant price-action information to identify key levels of Support and Resistance. Traders will be able to use current day Swing Pivots as well as mirror higher time frame Swing Pivots to gain a stronger understanding of overall market strength and key levels.

//The aim of this script is to improve the users trading experience by offering a versatile toolkit that can be used in a wide variety of trading strategies to help simplify the complexities of the market.

//█ USAGE

//Throughout the trading day, the script will automatically identify key High and Low levels in the market based on currently relevant price action information, giving users potentially strong support and resistance levels which serve to guide the trader throughout the complexities in the market.

//The script will also Identify powerful Order Blocks which are clusters of orders executed at a specific price level which represent an imbalance between supply and demand. By identifying Order Blocks, the script can indicate valuable supply and demand zones which help signal potential market turning points for the trader.

//Furthermore, the script allows the user to mirror higher time frame Swing Pivots onto lower time frame charts to gain a stronger understanding of overall market strength and key levels on multiple time frames from a single chart.

//█ SETTINGS

//Configuration

//Pivot Strength: Determines the sensitivity of the pivot calculation. A higher strength will result in less pivots being drawn, and a lower strength will result in more pivots being drawn.

//Current Time frame

//• Display: Determines whether or not Swing Pivots from the current time frame will be drawn on the chart.

//5 Minute (Higher Time Frame)

//• Display: Determines whether or not Swing Pivots from the 5 minute time frame will be drawn on the chart.

//15 Minute (Higher Time Frame)

//• Display: Determines whether or not Swing Pivots from the 15 minute time frame will be drawn on the chart.
//30 Minute (Higher Time Frame)

//• Display: Determines whether or not Swing Pivots from the 30 minute time frame will be drawn on the chart.

//1 Hour (Higher Time Frame)

//• Display: Determines whether or not Swing Pivots from the 1 hour time frame will be drawn on the chart.

//4 Hour (Higher Time Frame)

//• Display: Determines whether or not Swing Pivots from the 4 hour time frame will be drawn on the chart.

//Daily (Higher Time Frame)

//• Display: Determines whether or not Swing Pivots from the daily time frame will be drawn on the chart.


//-----------
//CLASSES
//-----------
type BarStructure
    int left
    float top
    int right
    float bottom

type SwingPoint
    box classification
    box shadow
    line midLine
    line extensionLine
    box price

method SPExtend(SwingPoint this) =>
    if not na(this)
        this.extensionLine.set_x2(bar_index)
        this.price.set_right(bar_index)

//-----------
//USER VARIABLES
//-----------
int strength    = input.int(defval=5, title="Pivot Strength", group='🟧 Swing Pivots Configuration')
string fontSize = input.string(defval="Tiny", title="Font Size", options=["Tiny", "Small", "Medium", "Large"], group="🟧 Swing Pivots Configuration")

color hhColor = input.color(defval = color.rgb(0, 184, 166), title = 'Higher High Color', group = 'Higher High')
bool hhToggle = input.bool(defval = true, title = 'Show Zones', group = 'Higher High')
color lhColor = input.color(defval = color.rgb(0, 184, 166), title = 'Lower High Color', group = 'Lower High')
bool lhToggle = input.bool(defval = false, title = 'Show Zones', group = 'Lower High')
color llColor = input.color(defval = color.rgb(230, 150, 30), title = 'Lower Low Color', group = 'Lower Low')
bool llToggle = input.bool(defval = true, title = 'Show Zones', group = 'Lower Low')
color hlColor = input.color(defval = color.rgb(230, 150, 30), title = 'Higher Low Color', group = 'Higher Low')
bool hlToggle   = input.bool(defval=false, title="Show Zones", group="Higher Low")

bool ctf        = input.bool(defval=true, title="Display Current Timeframe", group="Higher Time Frame")
bool htf5       = input.bool(defval=false, title="5 Minute Higher Timeframe", group="Higher Time Frame")
bool htf15      = input.bool(defval=false, title="15 Minute Higher Timeframe", group="Higher Time Frame")
bool htf30      = input.bool(defval=false, title="30 Minute Higher Timeframe", group="Higher Time Frame")
bool htf60      = input.bool(defval=false, title="1 Hour Higher Timeframe", group="Higher Time Frame")
bool htf240     = input.bool(defval=false, title="4 Hour Higher Timeframe", group="Higher Time Frame")
bool htfd       = input.bool(defval=false, title="Daily Higher Timeframe", group="Higher Time Frame")

//-----------
//VARIABLES
//-----------
var int tfp     = timeframe.isintraday and not timeframe.isseconds ? int(str.tonumber(timeframe.period)) : 0
var int b3      = na
var barsC = array.new<BarStructure> (0)
var collectionC = array.new<SwingPoint> (0)
var bars5 = array.new<BarStructure> (0)
var collection5 = array.new<SwingPoint> (0)
var bars15 = array.new<BarStructure> (0)
var collection15 = array.new<SwingPoint> (0)
var bars30 = array.new<BarStructure> (0)
var collection30 = array.new<SwingPoint> (0)
var bars60 = array.new<BarStructure> (0)
var collection60 = array.new<SwingPoint> (0)
var bars240 = array.new<BarStructure> (0)
var collection240 = array.new<SwingPoint> (0)
var barsDaily = array.new<BarStructure> (0)
var collectionDaily = array.new<SwingPoint> (0)

//-----------
//METHODS
//-----------
highest(array<BarStructure> bars) =>
    bool validHigh = true

    for i = 1 to strength
        if bars.get(bars.size()-((strength+1)+i)).top>bars.get(bars.size()-(strength+1)).top
            validHigh := false
        if bars.get(bars.size()-((strength+1)-i)).top>bars.get(bars.size()-(strength+1)).top
            validHigh := false

    validHigh

lowest(array<BarStructure> bars) =>
    bool validLow = true

    for i = 1 to strength
        if bars.get(bars.size()-((strength+1)+i)).bottom<bars.get(bars.size()-(strength+1)).bottom
            validLow := false
        if bars.get(bars.size()-((strength+1)-i)).bottom<bars.get(bars.size()-(strength+1)).bottom
            validLow := false

    validLow

drawRange(int BarsPerHigher, array<BarStructure> bars, array<SwingPoint> collection) =>
    var newBarStructure = BarStructure.new()
    var SwingPoint newSwingPoint = na
    var float recentHigh = na
    var float recentLow = na
    var SwingPoint recentSwingHigh = na
    var SwingPoint recentSwingLow = na

    newBarStructure := BarsPerHigher==1 ? BarStructure.new(bar_index,high,bar_index,low)
     : b%BarsPerHigher==0 ? BarStructure.new(
     left = bars.size() < 1 ? bar_index[BarsPerHigher] : bars.get(bars.size()-1).right+1
     , top = ta.highest(BarsPerHigher)[1]
     , right = bar_index[1]
     , bottom = ta.lowest(BarsPerHigher)[1]
     ) : newBarStructure

    if b%BarsPerHigher == 0 and not na(newBarStructure)
        bars.push(newBarStructure)
        if bars.size()>50
            bars.shift()

        if bars.size()>(strength*2+1)
            if highest(bars) or lowest(bars)
                bool direction = highest(bars) ? true : false
                newSwingPoint := SwingPoint.new(
                 classification = box.new(
                 left           = bars.get(bars.size()-(strength+1)).left
                 , top          = direction ? bars.get(bars.size()-(strength+1)).top+1 : bars.get(bars.size()-(strength+1)).bottom
                 , right        = bars.get(bars.size()-(strength+1)).left+1
                 , bottom       = direction ? bars.get(bars.size()-(strength+1)).top : bars.get(bars.size()-(strength+1)).bottom-1
                 , bgcolor      = color.new(color.black,100)
                 , border_color = na
                 , text         = direction ? (bars.get(bars.size()-(strength+1)).top > recentHigh ? "▼HH" : "▼LH") : (bars.get(bars.size()-(strength+1)).bottom < recentLow ? "▲LL" : "▲HL") // ⌜△⌝ ⌞▽⌟ ▭▲▭ ▭▼▭
                 , text_color   = direction ? (bars.get(bars.size()-(strength+1)).top > recentHigh ? hhColor : lhColor) : (bars.get(bars.size()-(strength+1)).bottom < recentLow ? llColor : hlColor)
                 , text_size    = fontSize == "Tiny" ? size.tiny : fontSize == "Small" ? size.small : fontSize == "Medium" ? size.normal : size.large
                 , text_valign  = direction ? text.align_bottom : text.align_top
                 , text_halign  = text.align_left
                 ),
                 shadow         = box.new(
                 left           = bars.get(bars.size()-(strength+1)).left
                 , top          = bars.get(bars.size()-(strength+1)).top
                 , right        = bars.get(bars.size()-(strength+1)).left+(5*BarsPerHigher)+5
                 , bottom       = bars.get(bars.size()-(strength+1)).bottom
                 , bgcolor      = direction and bars.get(bars.size()-(strength+1)).top > recentHigh and hhToggle ? color.new(hhColor,93) 
                 : direction and bars.get(bars.size()-(strength+1)).top < recentHigh and lhToggle ? color.new(lhColor,93)
                 : not direction and bars.get(bars.size()-(strength+1)).bottom < recentLow and llToggle ? color.new(llColor,93) 
                 : not direction and bars.get(bars.size()-(strength+1)).bottom > recentLow and hlToggle ? color.new(hlColor,93) : na
                 , border_color = direction and bars.get(bars.size()-(strength+1)).top > recentHigh and hhToggle ? color.new(hhColor,0) 
                 : direction and bars.get(bars.size()-(strength+1)).top < recentHigh and lhToggle ? color.new(lhColor,0)
                 : not direction and bars.get(bars.size()-(strength+1)).bottom < recentLow and llToggle ? color.new(llColor,0) 
                 : not direction and bars.get(bars.size()-(strength+1)).bottom > recentLow and hlToggle ? color.new(hlColor,0) : na
                 , border_style = line.style_dotted // Box Outline
                 ),
                 midLine        = line.new(
                 x1             = bars.get(bars.size()-(strength+1)).left
                 , y1           = (bars.get(bars.size()-(strength+1)).top+bars.get(bars.size()-(strength+1)).bottom)/2
                 , x2           = bars.get(bars.size()-(strength+1)).left+(5*BarsPerHigher)+5
                 , y2           = (bars.get(bars.size()-(strength+1)).top+bars.get(bars.size()-(strength+1)).bottom)/2
                 , color        = direction and bars.get(bars.size()-(strength+1)).top > recentHigh and hhToggle ? color.new(hhColor,0) 
                 : direction and bars.get(bars.size()-(strength+1)).top < recentHigh and lhToggle ? color.new(lhColor,0)
                 : not direction and bars.get(bars.size()-(strength+1)).bottom < recentLow and llToggle ? color.new(llColor,0) 
                 : not direction and bars.get(bars.size()-(strength+1)).bottom > recentLow and hlToggle ? color.new(hlColor,0) : na
                 , style        = line.style_dashed //Box Middle Line
                 ),
                 extensionLine  = line.new(
                 x1             = bars.get(bars.size()-(strength+1)).left
                 , y1           = direction ? bars.get(bars.size()-(strength+1)).top : bars.get(bars.size()-(strength+1)).bottom
                 , x2           = bars.get(bars.size()-(strength+1)).left+(5*BarsPerHigher)+5
                 , y2           = direction ? bars.get(bars.size()-(strength+1)).top : bars.get(bars.size()-(strength+1)).bottom
                 , color        = direction ? (bars.get(bars.size()-(strength+1)).top > recentHigh ? hhColor : lhColor) : (bars.get(bars.size()-(strength+1)).bottom < recentLow ? llColor : hlColor)
                 , style        = line.style_dotted // Extension Line
                 ),
                 price          = box.new(
                 left           = bars.get(bars.size()-(strength+1)).left
                 , top          = direction ? bars.get(bars.size()-(strength+1)).top+1 : bars.get(bars.size()-(strength+1)).bottom
                 , right        = bars.get(bars.size()-(strength+1)).left+(5*BarsPerHigher)+5
                 , bottom       = direction ? bars.get(bars.size()-(strength+1)).top : bars.get(bars.size()-(strength+1)).bottom-1
                 , bgcolor      = color.new(color.black,100)
                 , border_color = na
                 , text         = "$" + str.tostring(direction ? bars.get(bars.size()-(strength+1)).top : bars.get(bars.size()-(strength+1)).bottom, '###,###')
                 , text_color   = direction ? (bars.get(bars.size()-(strength+1)).top > recentHigh ? color.new(hhColor, 0) : color.new(lhColor, 0)) : (bars.get(bars.size()-(strength+1)).bottom < recentLow ? color.new(llColor,0) : color.new(hlColor,0))
                 , text_size    = fontSize == "Tiny" ? size.tiny : fontSize == "Small" ? size.small : fontSize == "Medium" ? size.normal : size.large
                 , text_valign  = direction ? text.align_bottom : text.align_top
                 , text_halign  = text.align_right
                 )
                 )

                recentHigh := direction ? bars.get(bars.size()-(strength+1)).top : recentHigh
                recentLow := direction ? recentLow : bars.get(bars.size()-(strength+1)).bottom

                recentSwingHigh := direction ? newSwingPoint : recentSwingHigh
                recentSwingLow := direction ? recentSwingLow : newSwingPoint
            
                collection.push(newSwingPoint)
                if collection.size()>5
                    collection.shift()

        if not na(recentSwingHigh)
            if bar_index>recentSwingHigh.extensionLine.get_x2()
                recentSwingHigh.SPExtend()
        if not na(recentSwingLow)
            if bar_index>recentSwingLow.extensionLine.get_x2()
                recentSwingLow.SPExtend()

//-----------
//FUNCTION
//-----------
if session.isfirstbar
    b3:=0

if ctf
    drawRange(1, barsC, collectionC)
if htf5 and 5%tfp == 0
    drawRange(5/tfp, bars5, collection5)
if htf15 and 15%tfp == 0
    drawRange(15/tfp, bars15, collection15)
if htf30 and 30%tfp == 0
    drawRange(30/tfp, bars30, collection30)
if htf60 and 60%tfp == 0
    drawRange(60/tfp, bars60, collection60)
if htf240 and 240%tfp == 0
    drawRange(240/tfp, bars240, collection240)
if htfd and 1380%tfp == 0
    drawRange(1380/tfp, barsDaily, collectionDaily)
////////////////////////////////////////////////
////            End Swing Pivots             ///
////////////////////////////////////////////////
````
