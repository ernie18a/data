<!-- tradingview-pine-id: PUB;df463196d3f646a09d54cb99d7e9f023 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# RSI Pro+ Suite

Source: https://www.tradingview.com/script/jADTvj81-RSI-Pro-Suite/

## Description

What It Is

RSI Pro+ Suite is a separate-pane oscillator built on the classic Wilder RSI. It adds a signal line and a regime layer, and puts everything through a structured state engine. Each bar is read four ways:

where RSI sits relative to 50,
where it sits relative to its own signal line,
which RSI range regime the market is in,
whether RSI and price are diverging.

The result is one coherent momentum state instead of a raw number.

It is the momentum companion to EMA Pro+ Suite and follows the same design: a layered state engine, a 0–5 conviction score, aligned vs counter-trend signals, and a real-time dashboard.

How It Works

The indicator evaluates four layers on every bar.

Layer 1 — Bias (RSI vs 50)
RSI at or above 50 means bullish bias; below 50 means bearish bias. The 50 line is the momentum equivalent of a trend midline and decides which side of the market has control.

Layer 2 — Momentum (RSI vs Signal Line)
RSI above its signal line means momentum is building; below means it is fading. The signal line can be an SMA, EMA, SMMA (RMA), WMA or VWMA, or an SMA with Bollinger Bands.

Layer 3 — Regime (Range Shift)
RSI behaves differently in trending markets:

Bull regime: RSI tends to hold above ~40 and push into the 60s–80s.
Bear regime: RSI tends to cap below ~60 and sink toward 20–30.

The regime engine checks the lowest and highest RSI over a configurable lookback (default 50 bars) to classify the market:

BULL RANGE: RSI held above the floor (40) and has pushed above the ceiling (60).
BEAR RANGE: RSI stayed below the ceiling (60) and has dropped below the floor (40).
MIXED: everything else, meaning a transitional or ranging state.

This is the "macro" layer of the suite. It is the RSI equivalent of the 100/200 EMA structure in EMA Pro+.

Layer 4 — Pullback Detection
The indicator flags a pullback in two cases:

Bull regime with momentum fading: RSI is below its signal line. This may be a dip-buy opportunity inside a healthy trend, or an early sign of exhaustion. Context decides which.
Bear regime with momentum rising: RSI is above its signal line. This is flagged as a bounce into resistance.

The Bull Score (0–5)
The score counts how many bullish conditions are currently true:

RSI is above 50.
RSI is above its signal line.
The signal line is above 50.
The RSI slope is rising beyond the flat threshold.
The regime is BULL.

A score of 5 is full bullish momentum confluence. A score of 0 means no bullish conditions are present. Scores of 2–3 are transitional.

Slope Engine
RSI slope is measured in RSI points over a configurable lookback and labelled RISING, FLAT or FALLING. A move smaller than the flat threshold (default 2 points) reads as FLAT. Momentum flips that fire on a flat RSI carry much less weight than flips with a clear slope behind them.

Divergence Engine
The engine uses pivots on both RSI and price, with configurable left/right lookback and a minimum and maximum number of bars between pivots. It detects four types:

Regular Bullish: price makes a lower low while RSI makes a higher low. This suggests potential reversal up.
Regular Bearish: price makes a higher high while RSI makes a lower high. This suggests potential reversal down.
Hidden Bullish (optional): price makes a higher low while RSI makes a lower low. This suggests trend continuation up.
Hidden Bearish (optional): price makes a lower high while RSI makes a higher high. This suggests trend continuation down.

Divergence lines connect the two pivots involved and are labelled "Bull", "Bear", "H Bull" or "H Bear".

Divergences are confirmed only after the right-side pivot lookback completes, which is 5 bars by default. They do not repaint, but they are inherently lagged by that amount. Labels are drawn back at the pivot bar.

Pane Visuals

Background: a deeper green or red tint means the RSI bias agrees with the regime. A faint tint means the bias is fighting the regime, which is a lower-conviction environment.
Gradient fills: green fills mark overbought territory and red fills mark oversold territory.
Exit markers: small circles on the OB/OS lines mark RSI leaving an extreme.

Price Bar Coloring (optional, off by default)
This works as a conviction heatmap based on the Bull Score:

Bright green / bright red: Score 5 / Score 0, meaning full alignment.
Subdued green / subdued red: Score 4 / Score 1.
Yellow: Score 2–3, a neutral or transitional state.
Aqua: a bull-regime pullback.
Fuchsia: a bear-regime bounce.

It is off by default.

Momentum Flip Signals

Green triangle (bottom): RSI crossed above its signal line while above 50. This is aligned and higher conviction.
Red triangle (top): RSI crossed below its signal line while below 50. This is aligned and higher conviction.
Orange triangle: the flip fired on the wrong side of 50. This is counter-trend and lower conviction.

Multi-Timeframe Support with Non-Repainting Mode
RSI, the signal line and the Bollinger Bands can all be calculated on a higher timeframe and displayed on the current chart.

With Non-Repainting MTF enabled (the default), the indicator uses the last closed higher-timeframe bar. What you see on historical bars is then exactly what you would have seen in real time. The dashboard marks this mode with "(NR)".

Dashboard
Row	What It Shows
RSI	Current RSI value, colored by zone
Zone	OVERBOUGHT / NEUTRAL / OVERSOLD
Bias	RSI vs 50
Momentum	RSI vs signal line
Regime	BULL RANGE / BEAR RANGE / MIXED
Alignment	Bull Score (X/5) with color-coded conviction
Slope	RISING / FLAT / FALLING
Signal	Current event: OB/OS exit, pullback, bounce, or momentum flip
Last Div	Most recent divergence type and how many bars ago it occurred
TF	Calculation timeframe (NR = non-repainting mode active)

Possible Ways to Use It

Regime-Filtered Trading
Only take longs while the Regime reads BULL RANGE and only take shorts in a BEAR RANGE. In a bull regime, a trip down to 40 is often a buying zone rather than weakness. In a bear regime, a rally up to 60 is often a selling zone rather than strength.

Pullback Entries
In a BULL RANGE, look for aqua pullback states that line up with RSI holding near the 40–50 area. Then use a green momentum flip back above the signal line as the trigger. Reverse the logic for shorts.

Divergence at Extremes
Regular divergences are most meaningful when they form in or near OB/OS territory and against a MIXED or opposing regime. Hidden divergences are most useful as continuation signals inside an established regime.

OB/OS Exits Instead of Entries
Overbought is not automatically a sell and oversold is not automatically a buy. In strong trends RSI can stay pinned at an extreme. The exit markers flag the moment RSI leaves an extreme, which is often a cleaner trigger than the entry into it.

HTF Confluence
Set the RSI Timeframe to 4H or Daily while trading a 15m or 1H chart. The dashboard then gives you the higher-timeframe momentum regime as a structural anchor. Divergence detection is most reliable when the RSI timeframe matches the chart timeframe.

Pairing with EMA Pro+ Suite
EMA Pro+ tells you the trend structure; RSI Pro+ tells you the momentum behind it. The highest-confluence reads are:

EMA Pro+ showing a high Bull Score alongside an RSI Pro+ BULL RANGE and rising slope.
A trend that looks strong on EMA Pro+ while RSI Pro+ prints a regular bearish divergence. This is an early warning.

Avoiding Chop
When the regime reads MIXED, the slope reads FLAT and the score sits at 2–3, momentum has no direction. Consider standing aside or reducing size.

Settings
Setting	Description
RSI Timeframe	Blank = chart timeframe. Enter any higher TF (e.g. 60, 240, D) for MTF mode.
Non-Repainting MTF	Uses the last closed HTF bar so history matches realtime. Only applies when RSI TF is higher than the chart.
RSI Length / Source	Default 14 / close.
Overbought / Oversold Levels	Default 70 / 30.
Slope Lookback / Flat Threshold	Default 5 bars / 2.0 RSI points.
Signal Line Type / Length	SMA, SMA + Bollinger Bands, EMA, SMMA (RMA), WMA, VWMA. Default SMA 14.
BB StdDev	Band width when using SMA + Bollinger Bands. Default 2.0.
Regime Lookback	Bars used to classify the RSI range regime. Default 50.
Bull Regime Floor / Bear Regime Ceiling	Default 40 / 60.
Enable Divergence / Include Hidden Divergence	Toggle regular and hidden divergence detection.
Pivot Lookback Left / Right	Default 5 / 5. The right value sets confirmation delay.
Min / Max Bars Between Pivots	Default 5 / 60.
Show Signal Line / Levels / Gradient Fill	Visual toggles.
Show Bias Background	Toggle the regime-aware background tint.
Color Price Bars by State	Toggle the conviction heatmap on price bars (off by default).
Show Momentum Flip Signals / OB-OS Exit Markers	Toggle signal markers.
Show Dashboard Table / Table Position	Toggle and position the HUD.
Bar-Close Check-In alert()	Sends a bar-close summary with RSI, zone, regime, score and slope.

Alerts
Momentum Flip Bull (Above 50): aligned
Momentum Flip Bull (Below 50): counter-trend
Momentum Flip Bear (Below 50): aligned
Momentum Flip Bear (Above 50): counter-trend
RSI Reclaimed 50 / RSI Lost 50
Entered Overbought / Exited Overbought
Entered Oversold / Exited Oversold
Bull Regime Pullback / Bear Regime Bounce
Regime Shift Bull / Regime Shift Bear
Regular Bullish / Regular Bearish Divergence
Hidden Bullish / Hidden Bearish Divergence
Bar-Close Check-In: create it with "Any alert() function call" to receive the live state summary on every bar close.

Disclaimer

This indicator is provided for educational and informational purposes only. It does not constitute financial advice, investment advice, or a recommendation to buy or sell any asset. All trading involves substantial risk of loss. Past performance of any signal, strategy, or system is not indicative of future results.

RSI Pro+ Suite is a tool to assist with technical analysis. It does not predict price, guarantee accuracy, or remove the inherent uncertainty of financial markets. No indicator eliminates risk. You are solely responsible for your own trading decisions.

Always conduct your own research, apply proper risk management, and consider consulting a licensed financial professional before making any trading decisions. Only trade with capital you can afford to lose.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RWCS_LTD

//@version=6
indicator("RSI Pro+ Suite", shorttitle = "RSI Pro+", overlay = false, format = format.price, precision = 2)

// ═══════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════
group1 = "RSI Settings"
group2 = "Signal Line"
group3 = "Regime (Range Shift)"
group4 = "Divergence"
group5 = "Display"
group6 = "Dashboard"
group7 = "Alerts"

RSI_TF      = input.timeframe("", "RSI Timeframe (blank = chart)", group = group1)
noRepaint   = input.bool(true, "Non-Repainting MTF", group = group1,
              tooltip = "When the RSI timeframe is higher than the chart, use the last CLOSED higher-timeframe bar so history and realtime match. Ignored when RSI timeframe = chart.")
rsiLen      = input.int(14, "RSI Length", minval = 1, group = group1)
rsiSrc      = input.source(close, "Source", group = group1)
OB          = input.int(70, "Overbought Level", minval = 50, maxval = 100, group = group1)
OS          = input.int(30, "Oversold Level",   minval = 0,  maxval = 50,  group = group1)
slopeLen    = input.int(5, "Slope Lookback (bars)", minval = 1, group = group1)
slopeThresh = input.float(2.0, "Flat Slope Threshold (RSI pts)", minval = 0, step = 0.5, group = group1)

maType      = input.string("SMA", "Signal Line Type",
              options = ["SMA", "SMA + Bollinger Bands", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group = group2)
maLen       = input.int(14, "Signal Line Length", minval = 1, group = group2)
bbMult      = input.float(2.0, "BB StdDev", minval = 0.001, maxval = 50, step = 0.5, group = group2,
              active = maType == "SMA + Bollinger Bands")

regimeLen   = input.int(50, "Regime Lookback (bars)", minval = 5, group = group3,
              tooltip = "Range-shift regime: in bull regimes RSI tends to hold above ~40; in bear regimes it tends to cap below ~60. Bull = RSI never below the floor over the lookback (and has pushed above the ceiling). Bear = never above the ceiling (and has dropped below the floor).")
bullFloor   = input.int(40, "Bull Regime Floor",   minval = 0,  maxval = 50,  group = group3)
bearCeil    = input.int(60, "Bear Regime Ceiling", minval = 50, maxval = 100, group = group3)

enableDiv   = input.bool(true,  "Enable Divergence",         group = group4)
showHidden  = input.bool(false, "Include Hidden Divergence", group = group4)
lbL         = input.int(5,  "Pivot Lookback Left",     minval = 1, group = group4)
lbR         = input.int(5,  "Pivot Lookback Right",    minval = 1, group = group4)
rangeLower  = input.int(5,  "Min Bars Between Pivots", minval = 1, group = group4)
rangeUpper  = input.int(60, "Max Bars Between Pivots", minval = 1, group = group4)

showMA       = input.bool(true,  "Show Signal Line",              group = group5)
showLevels   = input.bool(true,  "Show OB / Mid / OS Levels",     group = group5)
showGradient = input.bool(true,  "Show OB / OS Gradient Fill",    group = group5)
showBG       = input.bool(true,  "Show Bias Background",          group = group5)
showBars     = input.bool(false, "Color Price Bars by State",     group = group5,
               tooltip = "Off by default so it doesn't fight EMA Pro+ bar colouring if both are loaded.")
showSignals  = input.bool(true,  "Show Momentum Flip Signals",    group = group5)
showExits    = input.bool(true,  "Show OB / OS Exit Markers",     group = group5)

showDash    = input.bool(true, "Show Dashboard Table", group = group6)
dashLoc     = input.string("Bottom Right", "Table Position",
              options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = group6)

showBarAlert = input.bool(true, "Bar-Close Check-In alert()", group = group7)

// ═══════════════════════════════════════════════════
// MTF RSI FUNCTIONS
// ═══════════════════════════════════════════════════
f_ma(src, len, type) =>
    switch type
        "SMA"                   => ta.sma(src, len)
        "SMA + Bollinger Bands" => ta.sma(src, len)
        "EMA"                   => ta.ema(src, len)
        "SMMA (RMA)"            => ta.rma(src, len)
        "WMA"                   => ta.wma(src, len)
        => ta.vwma(src, len)

f_rsiPack(src, len, mLen, mType, mult) =>
    r   = ta.rsi(src, len)
    m   = f_ma(r, mLen, mType)
    dev = ta.stdev(r, mLen) * mult
    [r, m, dev]

// Previous-bar version, used with lookahead_on for non-repainting HTF values
f_rsiPackPrev(src, len, mLen, mType, mult) =>
    [r, m, dev] = f_rsiPack(src, len, mLen, mType, mult)
    [r[1], m[1], dev[1]]

tfEff = RSI_TF == "" ? timeframe.period : RSI_TF
isHTF = timeframe.in_seconds(tfEff) > timeframe.in_seconds(timeframe.period)

if barstate.isfirst and timeframe.in_seconds(tfEff) < timeframe.in_seconds(timeframe.period)
    runtime.error("RSI Pro+: RSI timeframe must be equal to or higher than the chart timeframe.")

[rsiLive, maLive, devLive] = request.security(syminfo.tickerid, tfEff,
  f_rsiPack(rsiSrc, rsiLen, maLen, maType, bbMult), lookahead = barmerge.lookahead_off)
[rsiNR, maNR, devNR] = request.security(syminfo.tickerid, tfEff,
  f_rsiPackPrev(rsiSrc, rsiLen, maLen, maType, bbMult), lookahead = barmerge.lookahead_on)

useNR = noRepaint and isHTF
rsi   = useNR ? rsiNR : rsiLive
rsiMA = useNR ? maNR  : maLive
bbDev = useNR ? devNR : devLive
isBB  = maType == "SMA + Bollinger Bands"

MID = 50.0

// ═══════════════════════════════════════════════════
// SLOPE ENGINE
// ═══════════════════════════════════════════════════
// Slope in RSI points over slopeLen bars (RSI is already bounded, so no % needed)
rsiSlope = rsi - rsi[slopeLen]

f_slopeLabel(s) =>
    math.abs(s) < slopeThresh ? "FLAT" : s > 0 ? "RISING" : "FALLING"

f_slopeColor(s) =>
    math.abs(s) < slopeThresh ? color.yellow : s > 0 ? color.green : color.red

// ═══════════════════════════════════════════════════
// STATE ENGINE
// ═══════════════════════════════════════════════════
bull_bias = rsi >= MID
bear_bias = not bull_bias
bull_mom  = rsi > rsiMA
bear_mom  = rsi < rsiMA

in_OB = rsi >= OB
in_OS = rsi <= OS

// Regime (range shift)
rsiLo = ta.lowest(rsi, regimeLen)
rsiHi = ta.highest(rsi, regimeLen)
regime_bull  = rsiLo >= bullFloor and rsiHi > bearCeil
regime_bear  = rsiHi <= bearCeil  and rsiLo < bullFloor
regime_mixed = not regime_bull and not regime_bear
regState     = regime_bull ? 1 : regime_bear ? -1 : 0

// Pullback inside a regime (the RSI analogue of EMA Pro+ "divergence" state)
bull_pb = regime_bull and bear_mom      // bull regime, RSI dipping under its signal line
bear_pb = regime_bear and bull_mom      // bear regime, RSI bouncing over its signal line

// ── Bull Score (0–5) ──
bull_score = (rsi > MID          ? 1 : 0) +
             (rsi > rsiMA        ? 1 : 0) +
             (rsiMA > MID        ? 1 : 0) +
             (rsiSlope > slopeThresh ? 1 : 0) +
             (regime_bull        ? 1 : 0)

// ── Events ──
mom_up   = ta.crossover(rsi,  rsiMA)
mom_dn   = ta.crossunder(rsi, rsiMA)
mid_up   = ta.crossover(rsi,  MID)
mid_dn   = ta.crossunder(rsi, MID)
ob_enter = ta.crossover(rsi,  OB)
ob_exit  = ta.crossunder(rsi, OB)
os_enter = ta.crossunder(rsi, OS)
os_exit  = ta.crossover(rsi,  OS)
reg_flip_bull = regState == 1  and regState[1] != 1
reg_flip_bear = regState == -1 and regState[1] != -1

// ═══════════════════════════════════════════════════
// DIVERGENCE ENGINE
// ═══════════════════════════════════════════════════
// Note: most reliable when RSI timeframe = chart timeframe. With an HTF RSI the
// line is stepped on the chart, which makes pivots sparse.
_inRange(bool cond) =>
    bars = ta.barssince(cond)
    rangeLower <= bars and bars <= rangeUpper

plPiv   = ta.pivotlow(rsi,  lbL, lbR)
phPiv   = ta.pivothigh(rsi, lbL, lbR)
plFound = enableDiv and not na(plPiv)
phFound = enableDiv and not na(phPiv)

rsiLBR  = rsi[lbR]
lowLBR  = low[lbR]
highLBR = high[lbR]

prevPL_rsi  = ta.valuewhen(plFound, rsiLBR,  1)
prevPL_low  = ta.valuewhen(plFound, lowLBR,  1)
prevPH_rsi  = ta.valuewhen(phFound, rsiLBR,  1)
prevPH_high = ta.valuewhen(phFound, highLBR, 1)
plInRange   = _inRange(plFound[1])
phInRange   = _inRange(phFound[1])

// Regular: price LL + RSI HL (bull) / price HH + RSI LH (bear)
regBull = plFound and plInRange and lowLBR  < prevPL_low  and rsiLBR > prevPL_rsi
regBear = phFound and phInRange and highLBR > prevPH_high and rsiLBR < prevPH_rsi
// Hidden: price HL + RSI LL (bull continuation) / price LH + RSI HH (bear continuation)
hidBull = showHidden and plFound and plInRange and lowLBR  > prevPL_low  and rsiLBR < prevPL_rsi
hidBear = showHidden and phFound and phInRange and highLBR < prevPH_high and rsiLBR > prevPH_rsi

// Track last divergence for the dashboard
var string lastDivTxt = "—"
var color  lastDivCol = color.gray
var int    lastDivBar = na
if regBull
    lastDivTxt := "BULL"
    lastDivCol := color.green
    lastDivBar := bar_index - lbR
if regBear
    lastDivTxt := "BEAR"
    lastDivCol := color.red
    lastDivBar := bar_index - lbR
if hidBull
    lastDivTxt := "H-BULL"
    lastDivCol := color.teal
    lastDivBar := bar_index - lbR
if hidBear
    lastDivTxt := "H-BEAR"
    lastDivCol := color.maroon
    lastDivBar := bar_index - lbR

// ═══════════════════════════════════════════════════
// RSI PANE PLOTS
// ═══════════════════════════════════════════════════
bullC   = color.green
bearC   = color.red
hBullC  = color.teal
hBearC  = color.maroon
noneC   = color.new(color.white, 100)

rsiPlot     = plot(rsi, "RSI", color = #7E57C2, linewidth = 2)
midLinePlot = plot(MID, color = na, editable = false, display = display.none)

hOB  = hline(OB,  "Overbought", color = #787B86, display = showLevels ? display.all : display.none)
hMid = hline(MID, "Midline",    color = color.new(#787B86, 50), linestyle = hline.style_dashed,
             display = showLevels ? display.all : display.none)
hOS  = hline(OS,  "Oversold",   color = #787B86, display = showLevels ? display.all : display.none)
fill(hOB, hOS, color = color.rgb(126, 87, 194, 92), title = "RSI Band Fill",
     display = showLevels ? display.all : display.none)

fill(rsiPlot, midLinePlot, 100, OB, top_color = color.new(color.green, 0), bottom_color = color.new(color.green, 100),
     title = "Overbought Gradient Fill", display = showGradient ? display.all : display.none)
fill(rsiPlot, midLinePlot, OS, 0,   top_color = color.new(color.red, 100), bottom_color = color.new(color.red, 0),
     title = "Oversold Gradient Fill",   display = showGradient ? display.all : display.none)

// Signal line + optional Bollinger Bands
plot(showMA ? rsiMA : na, "Signal Line", color = color.yellow)
bbUp = plot(rsiMA + bbDev, "Upper BB", color = color.green, display = showMA and isBB ? display.all : display.none)
bbLo = plot(rsiMA - bbDev, "Lower BB", color = color.green, display = showMA and isBB ? display.all : display.none)
fill(bbUp, bbLo, color = color.new(color.green, 90), title = "BB Fill",
     display = showMA and isBB ? display.all : display.none)

// ═══════════════════════════════════════════════════
// BACKGROUND TINT — regime-aware opacity
// ═══════════════════════════════════════════════════
bgcolor(showBG and bull_bias and regime_bull     ? color.new(color.green, 88) : na, title = "Strong Bull BG")
bgcolor(showBG and bull_bias and not regime_bull ? color.new(color.green, 96) : na, title = "Weak Bull BG")
bgcolor(showBG and bear_bias and regime_bear     ? color.new(color.red,   88) : na, title = "Strong Bear BG")
bgcolor(showBG and bear_bias and not regime_bear ? color.new(color.red,   96) : na, title = "Weak Bear BG")

// ═══════════════════════════════════════════════════
// PRICE BAR COLOR — score-tiered (pullback states override)
// ═══════════════════════════════════════════════════
barcolor(
  showBars ?
    (bull_pb         ? color.new(color.aqua,    0)  :
     bear_pb         ? color.new(color.fuchsia, 0)  :
     bull_score == 5 ? color.new(color.green,   0)  :
     bull_score == 4 ? color.new(color.green,   40) :
     bull_score == 3 ? color.new(color.yellow,  20) :
     bull_score == 2 ? color.new(color.yellow,  20) :
     bull_score == 1 ? color.new(color.red,     40) :
                       color.new(color.red,     0))
  : na,
  title = "State Bar Color")

// ═══════════════════════════════════════════════════
// MOMENTUM FLIP SIGNALS — zone-aware (aligned vs counter-trend)
// ═══════════════════════════════════════════════════
plotshape(showSignals and mom_up and bull_bias, title = "Momentum Flip Bull (Above 50)",
  location = location.bottom, style = shape.triangleup,   color = color.new(color.green,  20), size = size.tiny)
plotshape(showSignals and mom_up and bear_bias, title = "Momentum Flip Bull (Below 50)",
  location = location.bottom, style = shape.triangleup,   color = color.new(color.orange, 20), size = size.tiny)
plotshape(showSignals and mom_dn and bear_bias, title = "Momentum Flip Bear (Below 50)",
  location = location.top,    style = shape.triangledown, color = color.new(color.red,    20), size = size.tiny)
plotshape(showSignals and mom_dn and bull_bias, title = "Momentum Flip Bear (Above 50)",
  location = location.top,    style = shape.triangledown, color = color.new(color.orange, 20), size = size.tiny)

// OB / OS exits (RSI leaving an extreme)
plotshape(showExits and ob_exit ? OB : na, title = "OB Exit", location = location.absolute,
  style = shape.circle, color = color.new(color.red,   0), size = size.tiny)
plotshape(showExits and os_exit ? OS : na, title = "OS Exit", location = location.absolute,
  style = shape.circle, color = color.new(color.green, 0), size = size.tiny)

// ═══════════════════════════════════════════════════
// DIVERGENCE PLOTS
// ═══════════════════════════════════════════════════
// Line plots connect successive pivots; a segment is only visible when its
// ending pivot completes a divergence.
plot(plFound ? rsiLBR : na, "Bull Divergence Line", offset = -lbR, linewidth = 2,
     color = regBull ? bullC : hidBull ? hBullC : noneC, display = display.pane, editable = enableDiv)
plot(phFound ? rsiLBR : na, "Bear Divergence Line", offset = -lbR, linewidth = 2,
     color = regBear ? bearC : hidBear ? hBearC : noneC, display = display.pane, editable = enableDiv)

plotshape(regBull ? rsiLBR : na, offset = -lbR, title = "Regular Bullish Label", text = " Bull ",
  style = shape.labelup,   location = location.absolute, color = bullC,  textcolor = color.white, display = display.pane)
plotshape(regBear ? rsiLBR : na, offset = -lbR, title = "Regular Bearish Label", text = " Bear ",
  style = shape.labeldown, location = location.absolute, color = bearC,  textcolor = color.white, display = display.pane)
plotshape(hidBull ? rsiLBR : na, offset = -lbR, title = "Hidden Bullish Label",  text = " H Bull ",
  style = shape.labelup,   location = location.absolute, color = hBullC, textcolor = color.white, display = display.pane)
plotshape(hidBear ? rsiLBR : na, offset = -lbR, title = "Hidden Bearish Label",  text = " H Bear ",
  style = shape.labeldown, location = location.absolute, color = hBearC, textcolor = color.white, display = display.pane)

// ═══════════════════════════════════════════════════
// DASHBOARD TABLE
// ═══════════════════════════════════════════════════
f_row(table t, int row, string lbl, string val, color col) =>
    table.cell(t, 0, row, lbl, text_color = color.gray, text_size = size.small)
    table.cell(t, 1, row, val, text_color = col,        text_size = size.small)

var table dash = na

if showDash and barstate.islast
    if na(dash)
        tPos = dashLoc == "Top Right"    ? position.top_right    :
               dashLoc == "Top Left"     ? position.top_left     :
               dashLoc == "Bottom Right" ? position.bottom_right :
                                           position.bottom_left
        dash := table.new(tPos, columns = 2, rows = 11,
             bgcolor      = color.new(color.black, 80),
             border_color = color.new(color.gray,  50),
             border_width = 1,
             frame_color  = color.gray,
             frame_width  = 1, 
             force_overlay = true)

    // ── Header ──
    table.cell(dash, 0, 0, "RSI PRO+", text_color = color.white, text_size = size.small,
               bgcolor = color.new(color.navy, 40))
    table.cell(dash, 1, 0, "", bgcolor = color.new(color.navy, 40))

    // ── RSI value ──
    rsiCol = in_OB ? color.red : in_OS ? color.green : color.white
    f_row(dash, 1, "RSI", str.tostring(rsi, "#.0"), rsiCol)

    // ── Zone ──
    zoneLbl = in_OB ? "OVERBOUGHT" : in_OS ? "OVERSOLD" : "NEUTRAL"
    zoneCol = in_OB ? color.red    : in_OS ? color.green : color.gray
    f_row(dash, 2, "Zone", zoneLbl, zoneCol)

    // ── Bias (vs 50) ──
    f_row(dash, 3, "Bias", bull_bias ? "▲ BULL" : "▼ BEAR", bull_bias ? color.green : color.red)

    // ── Momentum (vs signal line) ──
    f_row(dash, 4, "Momentum", bull_mom ? "▲ BULL" : "▼ BEAR", bull_mom ? color.green : color.red)

    // ── Regime ──
    regLbl = regime_bull ? "▲ BULL RANGE" : regime_bear ? "▼ BEAR RANGE" : "⚡ MIXED"
    regCol = regime_bull ? color.green    : regime_bear ? color.red      : color.yellow
    f_row(dash, 5, "Regime", regLbl, regCol)

    // ── Alignment (score-based) ──
    alignLabel = bull_score == 5 ? "★ FULL BULL"   :
                 bull_score == 4 ? "✦ BULL (4/5)"  :
                 bull_score == 3 ? "⚡ MIXED (3/5)" :
                 bull_score == 2 ? "⚡ MIXED (2/5)" :
                 bull_score == 1 ? "✦ BEAR (1/5)"  :
                                   "★ FULL BEAR"
    alignColor = bull_score == 5 ? color.green  :
                 bull_score == 4 ? color.lime   :
                 bull_score >= 2 ? color.yellow :
                 bull_score == 1 ? color.orange :
                                   color.red
    f_row(dash, 6, "Alignment", alignLabel, alignColor)

    // ── Slope ──
    f_row(dash, 7, "Slope", f_slopeLabel(rsiSlope), f_slopeColor(rsiSlope))

    // ── Signal ──
    sigLabel = ob_exit ? "OB EXIT ↓"   : os_exit ? "OS EXIT ↑"  :
               bull_pb ? "↑ PULLBACK?" : bear_pb ? "↓ BOUNCE?"  :
               mom_up  ? "M FLIP ↑"    : mom_dn  ? "M FLIP ↓"   : "—"
    sigColor = ob_exit ? color.red     : os_exit ? color.green  :
               bull_pb ? color.aqua    : bear_pb ? color.fuchsia :
               mom_up  ? color.green   : mom_dn  ? color.red    : color.gray
    f_row(dash, 8, "Signal", sigLabel, sigColor)

    // ── Last divergence ──
    divStr = na(lastDivBar) ? "—" : lastDivTxt + " (" + str.tostring(bar_index - lastDivBar) + " bars)"
    f_row(dash, 9, "Last Div", divStr, lastDivCol)

    // ── Timeframe ──
    f_row(dash, 10, "TF", tfEff + (useNR ? " (NR)" : ""), color.white)

// ═══════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════
alertcondition(mom_up and bull_bias, title = "Momentum Flip Bull (Above 50)",
  message = "RSI Pro+ ({{ticker}}): RSI crossed ABOVE signal line while above 50 — aligned bull momentum.")
alertcondition(mom_up and bear_bias, title = "Momentum Flip Bull (Below 50)",
  message = "RSI Pro+ ({{ticker}}): RSI crossed ABOVE signal line but still below 50 — counter-trend, low conviction.")
alertcondition(mom_dn and bear_bias, title = "Momentum Flip Bear (Below 50)",
  message = "RSI Pro+ ({{ticker}}): RSI crossed BELOW signal line while below 50 — aligned bear momentum.")
alertcondition(mom_dn and bull_bias, title = "Momentum Flip Bear (Above 50)",
  message = "RSI Pro+ ({{ticker}}): RSI crossed BELOW signal line but still above 50 — counter-trend, low conviction.")
alertcondition(mid_up,   title = "RSI Reclaimed 50",  message = "RSI Pro+ ({{ticker}}): RSI crossed ABOVE 50 — bias flipped bullish.")
alertcondition(mid_dn,   title = "RSI Lost 50",       message = "RSI Pro+ ({{ticker}}): RSI crossed BELOW 50 — bias flipped bearish.")
alertcondition(ob_enter, title = "Entered Overbought", message = "RSI Pro+ ({{ticker}}): RSI entered overbought.")
alertcondition(ob_exit,  title = "Exited Overbought",  message = "RSI Pro+ ({{ticker}}): RSI dropped back out of overbought.")
alertcondition(os_enter, title = "Entered Oversold",   message = "RSI Pro+ ({{ticker}}): RSI entered oversold.")
alertcondition(os_exit,  title = "Exited Oversold",    message = "RSI Pro+ ({{ticker}}): RSI climbed back out of oversold.")
alertcondition(bull_pb,  title = "Bull Regime Pullback", message = "RSI Pro+ ({{ticker}}): Bull regime but RSI below signal line — pullback or exhaustion.")
alertcondition(bear_pb,  title = "Bear Regime Bounce",   message = "RSI Pro+ ({{ticker}}): Bear regime but RSI above signal line — bounce or exhaustion.")
alertcondition(reg_flip_bull, title = "Regime Shift Bull", message = "RSI Pro+ ({{ticker}}): RSI range shifted to BULL regime.")
alertcondition(reg_flip_bear, title = "Regime Shift Bear", message = "RSI Pro+ ({{ticker}}): RSI range shifted to BEAR regime.")
alertcondition(regBull, title = "Regular Bullish Divergence", message = "RSI Pro+ ({{ticker}}): Regular bullish divergence confirmed (price LL, RSI HL).")
alertcondition(regBear, title = "Regular Bearish Divergence", message = "RSI Pro+ ({{ticker}}): Regular bearish divergence confirmed (price HH, RSI LH).")
alertcondition(hidBull, title = "Hidden Bullish Divergence",  message = "RSI Pro+ ({{ticker}}): Hidden bullish divergence confirmed (price HL, RSI LL).")
alertcondition(hidBear, title = "Hidden Bearish Divergence",  message = "RSI Pro+ ({{ticker}}): Hidden bearish divergence confirmed (price LH, RSI HH).")

if showBarAlert and barstate.isconfirmed
    zoneTxt = in_OB ? "OB" : in_OS ? "OS" : "Neutral"
    regTxt  = regime_bull ? "Bull" : regime_bear ? "Bear" : "Mixed"
    alert("🔍 RSI Pro+ " + syminfo.ticker + " bar closed | RSI " + str.tostring(rsi, "#.0") +
          " | Zone " + zoneTxt + " | Regime " + regTxt + " | Score " + str.tostring(bull_score) +
          "/5 | Slope " + f_slopeLabel(rsiSlope) + ". Is there a setup?", alert.freq_once_per_bar_close)
````
