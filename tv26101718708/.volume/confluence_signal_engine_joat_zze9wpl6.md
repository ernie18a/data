# Confluence Signal Engine [JOAT]

- url: https://www.tradingview.com/script/zZe9WPl6-Confluence-Signal-Engine-JOAT/
- type: indicator
- pine_id: PUB;5f0ad3ceb01947549f159654189d8c51
- version: 1.0

## Description

[b]Confluence Signal Engine [JOAT][/b]

[b]Introduction[/b]

Most traders encounter a common trap: stacking multiple indicators that all claim to measure something different, yet each one is ultimately derived from the same price data. The result is not confirmation — it is correlated noise presented as agreement. The Confluence Signal Engine [JOAT] was built to address this directly.

This indicator assigns a composite score to the current market condition by evaluating six deliberately chosen dimensions of market behavior. Each dimension is designed to measure a fundamentally different property of price action. When multiple dimensions agree, that agreement carries more weight than any single indicator firing alone. The result is a single, normalised score between -1 and +1, accompanied by a visual confidence meter and a score breakdown table so you can see exactly what is driving the signal.

This is an [i]overlay[/i] indicator — it plots directly on the price chart.

[image]https://www.tradingview.com/x/dcqdqjIi/[/image]
---

[b]Core Concepts[/b]

[b]The Six Scoring Dimensions[/b]

Each dimension returns one of three values: [b]+1[/b] (bullish contribution), [b]-1[/b] (bearish contribution), or [b]0[/b] (neutral / insufficient data). These are summed and divided by 6.0 to produce the composite score.

[b]D1 — EMA Alignment (Trend Direction)[/b]
Compares a fast EMA to a slow EMA. If the fast EMA is above the slow EMA, the trend dimension scores +1. If below, it scores -1. This is the structural backbone — a baseline read on which side of the trend the price currently sits.

[b]D2 — Price Z-Score (Statistical Deviation)[/b]
Calculates how many standard deviations the current close is from a baseline EMA. A Z-score below the negative threshold suggests the price has deviated far enough below the mean to be considered statistically stretched — a potential reversion candidate, scored +1. A Z-score above the positive threshold scores -1. This dimension does not measure trend; it measures relative price position against recent statistical norms.

[b]D3 — Volume Pressure (Demand Validation)[/b]
Uses a Volume RSI (RSI applied to volume over 8 bars, divided by 50) as a proxy for whether volume activity is elevated. When volume pressure exceeds the threshold, the candle's direction (close vs. open) determines the score: a bullish candle in high-volume conditions scores +1; a bearish candle scores -1. When volume is not elevated, this dimension returns 0, contributing nothing. This prevents volume noise on low-activity bars from polluting the signal.

[b]D4 — RSI Momentum (Momentum Quality)[/b]
Evaluates both the current RSI value and its slope. A rising RSI above 50 scores +1 — confirming that momentum is positive and strengthening. A falling RSI below 50 scores -1. This differs from a simple RSI threshold because the slope requirement means momentum must be actively moving in the scored direction, not merely sitting above or below a level.

[b]D5 — Structural Position (Range Placement)[/b]
Compares the current close to the midpoint of the highest high and lowest low over a configurable lookback period. Closing above the midpoint scores +1; closing below scores -1. This is a simple but useful structural context: is price holding in the upper or lower half of its recent range?

[b]D6 — Volatility Context (Environment Quality)[/b]
Divides a fast ATR by a slow ATR to produce a volatility ratio. A low ratio (calm, contracting volatility) scores +1 — historically a more favorable environment for trend continuation. A high ratio (expanding, elevated volatility) scores -1, flagging that the current environment may be erratic. A ratio between the two thresholds is neutral. This dimension does not predict price direction; it assesses whether current conditions are conducive to acting on the other signals.

---

[b]Composite Score and Confidence[/b]

[pine]
compositeScore = (D1 + D2 + D3 + D4 + D5 + D6) / 6.0
confidence = math.abs(compositeScore) * 100
[/pine]

The composite score ranges from -1.0 (all six dimensions bearish) to +1.0 (all six dimensions bullish). The confidence value is simply the absolute magnitude — a score of ±1.0 represents 100% agreement across all dimensions, while a score near 0 represents disagreement or neutrality.

[b]Signal thresholds:[/b]
[list]
[*]Score > buy threshold (default 0.3) → bullish signal
[*]Score < sell threshold (default -0.3) → bearish signal
[*]Score > high-confidence threshold (default ±0.6) → high-confidence signal
[/list]

Signals are gated by [b]barstate.isconfirmed[/b] — they only fire on fully closed bars, preventing intra-bar repainting. State tracking also prevents the same directional signal from repeating consecutively without a change in direction first.

---

[b]Visual Components[/b]

[b]24-Cell Gradient Confidence Meter[/b]
A horizontal bar of 24 cells is displayed at the bottom of the chart. The left side is the bearish extreme, the center is neutral, and the right side is the bullish extreme. The current composite score position is highlighted within the meter, giving a continuous visual read of where the market sits in the conviction range — not just whether a signal has fired, but how strongly.

[b]Score Breakdown Table[/b]
A table showing three columns for each dimension: dimension name, dimension number, and its current score (+1, -1, or 0). This allows you to see exactly which dimensions are contributing to the composite and which are neutral or conflicting.

[b]Gradient Bar Coloring[/b]
Price bars are colored using a gradient that interpolates from a neutral color toward the signal color, weighted by the absolute value of the composite score. A high-confidence bull signal produces a strong green bar; a low-confidence or mixed signal produces a muted or neutral color. This keeps bar coloring proportional to actual conviction rather than using a binary flip.

---

[b]Features[/b]

[list]
[*]Six-dimension composite scoring system covering trend, statistics, volume, momentum, structure, and volatility
[*]Composite score normalised to [-1, +1] with confidence percentage
[*]Non-repainting: all signals confirmed on bar close via barstate.isconfirmed
[*]State-tracked signals prevent repeated same-direction firing
[*]24-cell gradient confidence meter with continuous position display
[*]Score breakdown table showing each dimension's individual contribution
[*]Gradient bar coloring proportional to conviction level
[*]Configurable thresholds for all six dimensions and signal levels
[/list]

---

[b]Input Parameters[/b]

[list]
[*][b]EMA Fast / Slow[/b] (default 21 / 55) — D1 trend alignment
[*][b]Z-Score Baseline EMA[/b] (default 50) — the mean used for Z-score calculation
[*][b]Z-Score Window[/b] (default 50) — standard deviation lookback
[*][b]Z-Score Threshold[/b] (default 1.5) — how many standard deviations trigger the score
[*][b]Volume RSI Length[/b] (default 8) — RSI period applied to volume
[*][b]Volume Threshold[/b] (default 1.2) — Volume RSI / 50 must exceed this to activate D3
[*][b]RSI Length[/b] (default 14) — standard RSI period for D4
[*][b]Structure Lookback[/b] (default 20) — bars used to define the high/low range for D5
[*][b]ATR Fast / Slow[/b] (default 14 / 50) — periods for the volatility ratio in D6
[*][b]Volatility Thresholds[/b] (default 0.8 / 1.5) — low and high boundaries for the ATR ratio
[*][b]Buy Threshold[/b] (default 0.3) — minimum composite score to generate a long signal
[*][b]Sell Threshold[/b] (default -0.3) — maximum composite score to generate a short signal
[*][b]High-Confidence Threshold[/b] (default ±0.6) — score level at which a signal is classified as high-confidence
[/list]

---

[b]How to Use[/b]

[list]
[*]Apply to any chart. The overlay paints directly on price bars.
[*]Watch the confidence meter for the current composite score position. A score pressed toward either extreme with multiple dimensions aligned is a higher-quality read than one sitting near center.
[*]Use the score breakdown table to understand [i]why[/i] the composite score is what it is. If only 2 of 6 dimensions are contributing, the signal is weaker regardless of whether it crossed the threshold.
[*]High-confidence signals (score beyond ±0.6 by default) indicate that four or more of the six dimensions are in agreement. These can be treated as stronger setups than threshold-level signals.
[*]Combine the composite score read with your own price action, support/resistance, or higher-timeframe context before entering a trade. This indicator is a confluence tool, not a standalone entry system.
[*]If several dimensions are conflicting (score near 0), the market is not in a clear state — no action is the appropriate response.
[/list]

---

[b]Limitations[/b]

[list]
[*]No indicator can predict future price. The composite score reflects current market conditions based on recent historical data — not what will happen next.
[*]Z-score and structural position dimensions are mean-reverting in nature, while EMA alignment and RSI momentum are trend-following. In strongly trending markets, D2 and D5 may produce persistent bearish readings even during a healthy uptrend, suppressing the composite score. This is by design — the indicator is more suited to environments where confluence across all dimensions is achievable.
[*]Volume RSI (D3) is only reliable on instruments and timeframes with consistent, meaningful volume data. On synthetic instruments, indices, or very low-timeframe charts, volume data may be unreliable and D3's contribution should be weighted accordingly.
[*]The volatility context dimension (D6) measures the [i]environment[/i], not direction. A low-volatility score of +1 does not mean the market is about to move up — only that conditions are historically more favorable for clean signals.
[*]Signal state tracking prevents consecutive same-direction signals, which reduces noise but also means the indicator will not re-fire during a prolonged trending move. This is a deliberate design choice but should be understood before use.
[*]Default thresholds were chosen for general applicability. Different asset classes, timeframes, and volatility regimes may benefit from threshold adjustment.
[*]Past signal quality on any given instrument does not guarantee future performance.
[/list]

---

[b]Originality Statement[/b]

The core innovation of this indicator is the deliberate selection of six dimensions that measure [i]fundamentally different[/i] market properties rather than multiple views of the same property. Standard multi-indicator approaches tend to combine RSI, MACD, and Stochastic — all of which are momentum oscillators derived from price, generating correlated signals that appear independent but are not.

This indicator separates the problem into distinct domains: trend direction (EMA alignment), statistical deviation from the mean (Z-score), demand-side pressure (Volume RSI), momentum quality and direction (RSI slope + level), structural placement within recent range (midpoint comparison), and environmental favorability (ATR ratio). Because these dimensions are largely uncorrelated with each other, genuine multi-dimension agreement represents a qualitatively different kind of confluence than stacking three oscillators. The 24-cell gradient meter goes further — it provides a continuous conviction read rather than a binary signal, treating market condition as a spectrum.

---

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It does not constitute financial advice, investment advice, or a recommendation to buy or sell any security. All trading involves risk, including the possible loss of principal. Past indicator performance does not guarantee future results. Always conduct your own research and consult a qualified financial professional before making any trading decisions.

-Made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Confluence Signal Engine [JOAT]", shorttitle="CSE [JOAT]", overlay=true, max_labels_count=100)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grpEMA  = "Dimension 1 — EMA Alignment"
emaFastLen = input.int(21, "Fast EMA", minval=5, maxval=100, group=grpEMA)
emaSlowLen = input.int(55, "Slow EMA", minval=10, maxval=300, group=grpEMA)

grpZ    = "Dimension 2 — Price Z-Score"
zEmaLen = input.int(50, "Z-Score EMA Baseline", minval=10, maxval=200, group=grpZ)
zWin    = input.int(50, "Z-Score Window", minval=10, maxval=200, group=grpZ)
zThresh = input.float(1.5, "Z-Score Threshold", minval=0.5, maxval=4.0, step=0.1, group=grpZ)

grpVol  = "Dimension 3 — Volume Pressure"
volRsiLen  = input.int(8, "Volume RSI Length", minval=2, maxval=30, group=grpVol)
volThresh  = input.float(1.2, "Volume RSI Threshold", minval=0.8, maxval=2.5, step=0.05, group=grpVol)

grpRSI  = "Dimension 4 — RSI Momentum"
rsiLen  = input.int(14, "RSI Length", minval=2, maxval=50, group=grpRSI)
rsiEmaL = input.int(3, "RSI EMA Smoothing", minval=1, maxval=20, group=grpRSI)

grpStr  = "Dimension 5 — Structural Position"
strLen  = input.int(20, "Structure Lookback", minval=5, maxval=100, group=grpStr)

grpAtr  = "Dimension 6 — Volatility Context"
atrFast = input.int(14, "ATR Fast", minval=1, maxval=50, group=grpAtr)
atrSlow = input.int(50, "ATR Slow", minval=10, maxval=200, group=grpAtr)
atrLoTh = input.float(0.8, "Low Vol Threshold", minval=0.2, maxval=1.0, step=0.05, group=grpAtr)
atrHiTh = input.float(1.5, "High Vol Threshold", minval=1.0, maxval=5.0, step=0.1, group=grpAtr)

grpSig  = "Signal Logic"
buyThresh  = input.float(0.3,  "Buy Score Threshold",  minval=0.1, maxval=1.0, step=0.05, group=grpSig)
sellThresh = input.float(-0.3, "Sell Score Threshold", minval=-1.0, maxval=-0.1, step=0.05, group=grpSig)
highConfB  = input.float(0.6,  "High Confidence Buy",  minval=0.3, maxval=1.0, step=0.05, group=grpSig)
highConfS  = input.float(-0.6, "High Confidence Sell", minval=-1.0, maxval=-0.3, step=0.05, group=grpSig)

grpVis  = "Visual"
showScore   = input.bool(true, "Show Score Table", group=grpVis)
showMeter   = input.bool(true, "Show Confidence Meter", group=grpVis)
showLabels  = input.bool(true, "Show Signal Labels", group=grpVis)
showBars    = input.bool(true, "Gradient Bar Color", group=grpVis)
scoreTblPos = input.string("top_right", "Score Table Position",
  options=["top_right","top_left","bottom_right","bottom_left"], group=grpVis)

// ─────────────────────────────────────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────────────────────────────────────
bullColor  = color.rgb(92, 240, 215)
bearColor  = color.rgb(179, 42, 195)
neutralCol = color.rgb(130, 140, 160)
bgDark     = color.rgb(10, 14, 22)
textLight  = color.rgb(220, 225, 235)
textDim    = color.rgb(100, 110, 130)
highConfC  = color.rgb(255, 200, 50)

// ─────────────────────────────────────────────────────────────────────────────
// DIMENSION 1 — EMA ALIGNMENT
// ─────────────────────────────────────────────────────────────────────────────
ema_fast = ta.ema(close, emaFastLen)
ema_slow = ta.ema(close, emaSlowLen)
s1 = ema_fast > ema_slow ? 1.0 : ema_fast < ema_slow ? -1.0 : 0.0

// ─────────────────────────────────────────────────────────────────────────────
// DIMENSION 2 — PRICE Z-SCORE
// ─────────────────────────────────────────────────────────────────────────────
emaBase    = ta.ema(close, zEmaLen)
deviation  = close - emaBase
devStdev   = math.max(ta.stdev(close, zWin), syminfo.mintick)
zScore     = deviation / devStdev
s2 = zScore < -zThresh ? 1.0 : zScore > zThresh ? -1.0 : 0.0

// ─────────────────────────────────────────────────────────────────────────────
// DIMENSION 3 — VOLUME PRESSURE
// ─────────────────────────────────────────────────────────────────────────────
volRSI    = ta.rsi(volume, volRsiLen) / 50.0
s3 = volRSI > volThresh ? (close > open ? 1.0 : close < open ? -1.0 : 0.0) : 0.0

// ─────────────────────────────────────────────────────────────────────────────
// DIMENSION 4 — RSI MOMENTUM
// ─────────────────────────────────────────────────────────────────────────────
rsiVal    = ta.rsi(close, rsiLen)
rsiEmaVal = ta.ema(rsiVal, rsiEmaL)
rsiSlope  = rsiEmaVal - rsiEmaVal[1]
s4 = rsiSlope > 0 and rsiVal > 50 ? 1.0 : rsiSlope < 0 and rsiVal < 50 ? -1.0 : 0.0

// ─────────────────────────────────────────────────────────────────────────────
// DIMENSION 5 — STRUCTURAL POSITION
// ─────────────────────────────────────────────────────────────────────────────
strHigh = ta.highest(high, strLen)
strLow  = ta.lowest(low,  strLen)
strMid  = (strHigh + strLow) / 2.0
s5 = close > strMid ? 1.0 : close < strMid ? -1.0 : 0.0

// ─────────────────────────────────────────────────────────────────────────────
// DIMENSION 6 — VOLATILITY CONTEXT
// ─────────────────────────────────────────────────────────────────────────────
atrF     = ta.atr(atrFast)
atrSl    = math.max(ta.atr(atrSlow), syminfo.mintick)
atrRatio = atrF / atrSl
s6 = atrRatio < atrLoTh ? 1.0 : atrRatio > atrHiTh ? -1.0 : 0.0

// ─────────────────────────────────────────────────────────────────────────────
// COMPOSITE SCORE
// ─────────────────────────────────────────────────────────────────────────────
totalScore = (s1 + s2 + s3 + s4 + s5 + s6) / 6.0
confidence = math.abs(totalScore) * 100.0

signalStr  = totalScore > buyThresh ? (totalScore > highConfB ? "STRONG BUY" : "BUY") :
  totalScore < sellThresh ? (totalScore < highConfS ? "STRONG SELL" : "SELL") : "NEUTRAL"
signalColor = totalScore > buyThresh ? bullColor : totalScore < sellThresh ? bearColor : neutralCol

// ─────────────────────────────────────────────────────────────────────────────
// NON-REPAINTING SIGNAL DETECTION
// ─────────────────────────────────────────────────────────────────────────────
var float prevScore = 0.0
var string prevSig  = "NEUTRAL"

isBuy  = totalScore > buyThresh  and barstate.isconfirmed
isSell = totalScore < sellThresh and barstate.isconfirmed

newBuySignal  = isBuy  and (prevSig != "BUY" and prevSig != "STRONG BUY")   and barstate.isconfirmed
newSellSignal = isSell and (prevSig != "SELL" and prevSig != "STRONG SELL")  and barstate.isconfirmed

if barstate.isconfirmed
    prevSig  := signalStr
    prevScore := totalScore

// ─────────────────────────────────────────────────────────────────────────────
// SIGNAL LABELS
// ─────────────────────────────────────────────────────────────────────────────
atr14 = ta.atr(14)

if showLabels and newBuySignal
    confLabel = totalScore > highConfB ? "HC " : ""
    label.new(bar_index, low - atr14 * 1.2,
      text="▲ " + confLabel + "BUY\n" + str.tostring(confidence, "#.#") + "%",
      style=label.style_label_up,
      color=color.new(bullColor, 15),
      textcolor=bgDark,
      size=totalScore > highConfB ? size.small : size.tiny)

if showLabels and newSellSignal
    confLabel = totalScore < highConfS ? "HC " : ""
    label.new(bar_index, high + atr14 * 1.2,
      text="▼ " + confLabel + "SELL\n" + str.tostring(confidence, "#.#") + "%",
      style=label.style_label_down,
      color=color.new(bearColor, 15),
      textcolor=color.white,
      size=totalScore < highConfS ? size.small : size.tiny)

// ─────────────────────────────────────────────────────────────────────────────
// BAR COLORING
// ─────────────────────────────────────────────────────────────────────────────
barGradR = int(float(color.r(neutralCol)) + (float(color.r(signalColor)) - float(color.r(neutralCol))) * math.abs(totalScore))
barGradG = int(float(color.g(neutralCol)) + (float(color.g(signalColor)) - float(color.g(neutralCol))) * math.abs(totalScore))
barGradB = int(float(color.b(neutralCol)) + (float(color.b(signalColor)) - float(color.b(neutralCol))) * math.abs(totalScore))
barGradColor = color.rgb(barGradR, barGradG, barGradB)
barcolor(showBars ? color.new(barGradColor, 40) : na)

// ─────────────────────────────────────────────────────────────────────────────
// EMA PLOTS
// ─────────────────────────────────────────────────────────────────────────────
emaPlotColor = ema_fast > ema_slow ? color.new(bullColor, 50) : color.new(bearColor, 50)
plot(ema_fast, "EMA Fast", color=emaPlotColor, linewidth=1)
plot(ema_slow, "EMA Slow", color=color.new(neutralCol, 50), linewidth=1)

// ─────────────────────────────────────────────────────────────────────────────
// SCORE TABLE (8 rows: 6 dimensions + total + signal)
// ─────────────────────────────────────────────────────────────────────────────
score_color(s) =>
    s > 0.5 ? bullColor : s < -0.5 ? bearColor : neutralCol

var table scoreTable = na
if showScore
    scorePos = scoreTblPos == "top_right"    ? position.top_right    :
      scoreTblPos == "top_left"    ? position.top_left    :
      scoreTblPos == "bottom_right" ? position.bottom_right : position.bottom_left

    if na(scoreTable)
        scoreTable := table.new(scorePos, 3, 10,
          bgcolor=color.new(bgDark, 15),
          border_color=color.new(neutralCol, 70),
          border_width=1,
          frame_color=color.new(neutralCol, 50),
          frame_width=1)

    table.cell(scoreTable, 0, 0, "CSE [JOAT]", text_color=textLight,
      bgcolor=color.new(bgDark, 5), text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(scoreTable, 1, 0, "DIM", text_color=textDim,
      bgcolor=color.new(bgDark, 5), text_size=size.tiny, text_font_family=font.family_monospace)
    table.cell(scoreTable, 2, 0, "SCORE", text_color=textDim,
      bgcolor=color.new(bgDark, 5), text_size=size.tiny, text_font_family=font.family_monospace)

    string[] dimNames  = array.from("EMA Align","Price Z","Vol Press","RSI Mom","Structural","Vol Ctx")
    float[]  dimScores = array.from(s1, s2, s3, s4, s5, s6)
    for di = 0 to 5
        dName  = array.get(dimNames,  di)
        dScore = array.get(dimScores, di)
        table.cell(scoreTable, 0, di + 1, dName, text_color=textDim, text_size=size.tiny,
          text_font_family=font.family_monospace, text_halign=text.align_left)
        table.cell(scoreTable, 1, di + 1, str.tostring(di + 1), text_color=neutralCol,
          text_size=size.tiny, text_font_family=font.family_monospace, text_halign=text.align_center)
        scoreVal = dScore > 0 ? "+1" : dScore < 0 ? "-1" : "0"
        table.cell(scoreTable, 2, di + 1, scoreVal, text_color=score_color(dScore),
          text_size=size.tiny, text_font_family=font.family_monospace, text_halign=text.align_right)

    table.cell(scoreTable, 0, 7, "Total Score", text_color=textLight, text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(scoreTable, 1, 7, "---", text_color=textDim, text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_center)
    table.cell(scoreTable, 2, 7, str.tostring(totalScore, "#.##"), text_color=signalColor,
      text_size=size.tiny, text_font_family=font.family_monospace, text_halign=text.align_right)

    table.cell(scoreTable, 0, 8, "Confidence", text_color=textDim, text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(scoreTable, 1, 8, "---", text_color=textDim, text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_center)
    confCol = confidence > 60 ? highConfC : confidence > 30 ? textLight : textDim
    table.cell(scoreTable, 2, 8, str.tostring(confidence, "#.#") + "%", text_color=confCol,
      text_size=size.tiny, text_font_family=font.family_monospace, text_halign=text.align_right)

    table.cell(scoreTable, 0, 9, "Signal", text_color=textDim, text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(scoreTable, 1, 9, "---", text_color=textDim, text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_center)
    table.cell(scoreTable, 2, 9, signalStr, text_color=signalColor,
      text_size=size.tiny, text_font_family=font.family_monospace, text_halign=text.align_right)

// ─────────────────────────────────────────────────────────────────────────────
// CONFIDENCE METER TABLE (24-cell gradient bar at bottom center)
// ─────────────────────────────────────────────────────────────────────────────
meterCells = 24
var table meter = na
if showMeter
    if na(meter)
        meter := table.new(position.bottom_center, meterCells, 2,
          bgcolor=color.new(bgDark, 25),
          border_color=color.new(neutralCol, 80),
          border_width=1)

    // Determine arrow position: map totalScore (-1..+1) to cell index (0..meterCells-1)
    arrowPos = int((totalScore + 1.0) / 2.0 * float(meterCells - 1))
    arrowPos := math.max(0, math.min(meterCells - 1, arrowPos))

    for ci = 0 to meterCells - 1
        frac = float(ci) / float(meterCells - 1)
        // Gradient: bear (left) → neutral (center) → bull (right)
        cellR = 0
        cellG = 0
        cellB = 0
        if frac < 0.5
            f2   = frac * 2.0
            cellR := int(float(color.r(bearColor)) * (1.0 - f2) + float(color.r(neutralCol)) * f2)
            cellG := int(float(color.g(bearColor)) * (1.0 - f2) + float(color.g(neutralCol)) * f2)
            cellB := int(float(color.b(bearColor)) * (1.0 - f2) + float(color.b(neutralCol)) * f2)
        else
            f2   = (frac - 0.5) * 2.0
            cellR := int(float(color.r(neutralCol)) * (1.0 - f2) + float(color.r(bullColor)) * f2)
            cellG := int(float(color.g(neutralCol)) * (1.0 - f2) + float(color.g(bullColor)) * f2)
            cellB := int(float(color.b(neutralCol)) * (1.0 - f2) + float(color.b(bullColor)) * f2)

        gradCell = color.rgb(cellR, cellG, cellB)
        // Arrow row (row 0): show indicator at matching position
        arrowTxt = ci == arrowPos ? "|" : " "
        arrowCol = ci == arrowPos ? textLight : color.new(textDim, 100)
        table.cell(meter, ci, 0, arrowTxt, text_color=arrowCol,
          bgcolor=color.new(bgDark, 30), text_size=size.tiny)
        // Color row (row 1)
        table.cell(meter, ci, 1, " ", bgcolor=color.new(gradCell, 50), text_size=size.tiny)

// ─────────────────────────────────────────────────────────────────────────────
// ALERT CONDITIONS
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(newBuySignal,  title="CSE [JOAT] Buy Signal",  message="CSE [JOAT]: BUY on {{ticker}} — multi-dimensional bullish confluence confirmed.")
alertcondition(newSellSignal, title="CSE [JOAT] Sell Signal", message="CSE [JOAT]: SELL on {{ticker}} — multi-dimensional bearish confluence confirmed.")
````
