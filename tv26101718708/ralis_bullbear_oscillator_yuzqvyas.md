# Ralis Bull/Bear Oscillator

- url: https://www.tradingview.com/script/YUZQVyaS-Ralis-Bull-Bear-Oscillator/
- type: indicator
- pine_id: PUB;0e6f26385c774aa7ac1551569f4dec99
- version: 3.0

## Description

Ralis Bull/Bear Oscillator measures buying and selling pressure using True Range decomposition. Unlike single-bar OHLC analysis, True Range captures gap pressure from the prior close, giving a more complete picture of who controlled the bar. Buying pressure is the distance from the close to the true low (how far buyers pushed up), selling pressure is the distance from the true high to the close (how far sellers pushed down). Both are normalized by the true range to produce values on a 0–100 scale, then SMA-smoothed into two continuous lines: the green bull line and the red bear line.

The pressure engine offers three calculation modes. Intrabar mode normalizes each bar independently — pure micro reads of who won that specific bar. Structural mode sums buying pressure, selling pressure, and true range over a lookback window before normalizing — this reveals the cumulative balance of power over the period. Average mode blends both, giving you micro responsiveness anchored by macro context. The default Period of 10 and Smoothing Length of 10 work well across most assets and timeframes.

The 4-SMMA ribbon regime (8/16/24/32 on HL2) runs in the background, classifying the macro trend as Bullish, Bearish, or Neutral. Two independent tests must pass for a confirmed regime. Tangle detection checks that the inner ribbon lines (16/24) agree with the outer line relationship — if any inner line disagrees, the ribbon is tangled and the regime is Neutral. The neutral zone filter requires the percentage gradient between the fast outer (8) and slow outer (32) to exceed ±0.34% before confirming a trend. If the spread is too narrow, the regime stays Neutral regardless of alignment. The regime is displayed in the info table and can optionally tint the pressure lines. The SMMA calculations use inline var-state seeding for consistent cross-asset behavior.

Pressure divergence detects exhaustion by comparing pivots on the pressure ratio (bull / (bull + bear) as a percentage) against price. Bearish divergence fires when price makes a higher high but the pressure ratio makes a lower high — buying pressure is fading despite higher prices. Bullish divergence fires when price makes a lower low but the pressure ratio makes a higher low — selling pressure is weakening despite lower prices. Pivots use 5 bars left and 3 bars right by default, with a maximum 24-bar lookback between two pivots to qualify. Divergence markers are orange triangles (bearish, top of pane) and cyan triangles (bullish, bottom of pane), plotted at the pivot bar where the divergence was confirmed.

The spread histogram plots the difference between the bull and bear lines as columns behind the pressure lines. Green columns above zero indicate bull dominance, red columns below zero indicate bear dominance. Acceleration dimming modulates brightness based on whether the spread is growing or shrinking in magnitude. Bright bars mean the dominant side is gaining steam — the absolute spread is larger than the prior bar. Dim bars mean the dominant side is fading — the spread is contracting even though it may still be positive or negative. This gives an instant visual read on momentum acceleration without adding another indicator.

Regime-tinted lines optionally fade the pressure line that is fighting the current ribbon regime. In a bullish regime, the bear line dims to 60% transparency while the bull line stays full brightness. In a bearish regime, the bull line dims. In a neutral regime, both lines fade to 40% transparency. This helps the eye focus on the pressure line that matters given the macro context.

Percentile extreme bands draw the 90th and 10th percentile of both the bull and bear lines over a configurable lookback (default 200 bars). When either pressure line exceeds its 90th percentile, a subtle background highlight appears behind the oscillator pane — green for extreme buying pressure, red for extreme selling pressure. These zones flag historically unusual pressure readings that often precede reversals or signal trend acceleration.

The info table displays Pressure (BULLS or BEARS with color-coded background), the current bull and bear line values, the spread between them, the pressure ratio as a percentage (green above 55%, red below 45%, white in between), and the ribbon regime (BULLISH in gold, BEARISH in blue, NEUTRAL in gray). The table supports 9-position placement.

Four alert conditions are available. Bull Cross fires when buying pressure crosses above selling pressure. Bear Cross fires when selling pressure crosses above. Bull Divergence fires on bullish pressure divergence (price lower low, ratio higher low). Bear Divergence fires on bearish pressure divergence (price higher high, ratio lower high). All alerts include ticker and timeframe context.

Settings are organized into five groups. Pressure Engine controls the calculation period, mode (Average/Intrabar/Structural), and smoothing length. Ribbon Regime controls the 4-SMMA source, lengths, and neutral zone percentage. Divergence controls visibility, pivot left/right bars, and maximum lookback between pivots. Visual controls line colors, spread histogram toggle, regime-tinted lines toggle, and percentile extreme bands with their lookback length. Table controls visibility and 9-position placement.

## Source Code

````pine
//@version=6
indicator("Ralis Bull/Bear Oscillator", shorttitle="RalisBB", overlay=false, max_lines_count=500)

// ═══════════════════════════════════════════════════════════════════════════════
// RALIS BULL/BEAR OSCILLATOR v1.11 — TheurgyLabs
//
// v1.11 (Aug 8 2026) — crossover circles REMOVED. With the two lines summing
//   to 100, a crossover is just the bull line touching 50, and the fill already
//   shows dominance. They were clutter on the midline.
//   Divergence markers recoloured CYAN bullish / YELLOW bearish and sized up.
//   Added a Div B/S count to the table: how many bullish and bearish
//   divergences have fired on the whole chart. It prints RED at zero. If it
//   reads zero the logic never fires; if it reads non-zero and nothing is
//   visible, it is a rendering problem and the new "Draw Marker At The Pivot"
//   toggle is the first thing to rule out.
//
// v1.10 (Aug 8 2026) — DIVERGENCE RESTORED, on the bull line by default.
//   The source is the BULL LINE, not RSI and not MACD. Two reasons, both
//   measured rather than preferred:
//     1. RalisBB already IS an oscillator. Price making a higher high while
//        BUYING PRESSURE makes a lower high is a statement about this engine.
//        RSI divergence drawn on this pane describes RSI, not pressure.
//     2. MACD is UNBOUNDED and scales with price. On a weekly bitcoin chart
//        running $5k to $120k, a 2020 MACD pivot and a 2025 one differ by an
//        order of magnitude and are not comparable. That is the CCIBands law:
//        unbounded oscillators cannot carry fixed thresholds. The bull line is
//        bounded 0-100 by construction because the two lines sum to 100.
//   RSI is offered as an alternate source so the two can be compared. Expect
//   them to fire on nearly the same bars - RSI is avg-gain/(avg-gain+avg-loss)
//   and the bull line is sum(close-trueLow)/sum(TR). Both measure how much of
//   the recent range was captured upward.
//
//   MARKERS ONLY. Nothing here gates, filters or shades a signal. The fleet
//   ships divergence as a scored bonus with the gate default OFF everywhere it
//   exists, and nothing has yet measured what a RalisBB divergence is worth.
//   Run it through the forward lab before believing it.
//
//   THE LAG IS REAL. A pivot needs Right bars to confirm, so a marker appears
//   Right bars AFTER the pivot it describes. On weekly bars that is three
//   weeks. The connector line is drawn back to the pivot for legibility; the
//   knowledge arrived later.
// ═══════════════════════════════════════════════════════════════════════════════
//
// Dual-line oscillator measuring buying vs selling pressure using True Range
// decomposition. Captures gap pressure that single-bar OHLC analysis misses.
//
// Buying Pressure  = close − TrueLow     (how far price pushed up from true low)
// Selling Pressure = TrueHigh − close    (how far price fell from true high)
// Both normalized by True Range → 0-100 scale, SMA-smoothed.
//
// Two scales:
//   Intrabar: single-bar BP/SP normalized by that bar's TR
//   Structural: cumulative BP/SP over lookback, normalized by cumulative TR
// Blended by default for both micro and macro pressure reads.
//
// When bull line crosses above bear line → buying pressure dominating
// When bear line crosses above bull line → selling pressure dominating
//
// ═══════════════════════════════════════════════════════════════════════════════

// ── SETTINGS ──────────────────────────────────────────────────────
groupASO    = "Pressure Engine"
groupRegime = "Ribbon Regime"
groupVisual = "Visual"
groupTable  = "Table"

i_length    = input.int(10, "Period", minval=1, maxval=100, group=groupASO,
     tooltip="Lookback for structural pressure calculation and SMA smoothing.")
i_mode      = input.string("Average", "Calculation Mode", options=["Average", "Intrabar", "Structural"], group=groupASO,
     tooltip="Average = blend of intrabar + structural. Intrabar = single bar TR pressure. Structural = cumulative pressure over lookback window.")
i_smooth    = input.int(10, "Smoothing Length", minval=1, maxval=50, group=groupASO,
     tooltip="SMA smoothing applied to raw bull/bear pressure values.")

i_src        = input.source(hl2, "Ribbon Source", group=groupRegime)
i_fastOut    = input.int(8,  "Fast Outer", minval=5, maxval=50, group=groupRegime)
i_fastIn     = input.int(16, "Fast Inner", minval=5, maxval=50, group=groupRegime)
i_slowIn     = input.int(24, "Slow Inner", minval=10, maxval=80, group=groupRegime)
i_slowOut    = input.int(32, "Slow Outer", minval=10, maxval=80, group=groupRegime)

i_bullColor  = input.color(#00FF88, "Bull Line (Green)", group=groupVisual)
i_bearColor  = input.color(#FF4444, "Bear Line (Red)", group=groupVisual)

groupDiv = "Divergence"
i_divOn     = input.bool(true, "Show Divergence", group=groupDiv)
i_divSrc    = input.string("Bull Line", "Source", options=["Bull Line","RSI"], group=groupDiv,
     tooltip="Bull Line keeps the divergence inside this engine's own measurement. RSI is offered for comparison - it is bounded like the bull line, unlike MACD, which scales with price and cannot be compared across a chart spanning $5k to $120k.")
i_rsiLen    = input.int(14, "RSI Length (if RSI source)", minval=2, maxval=100, group=groupDiv)
i_pivL      = input.int(5,  "Pivot Left",  minval=1, maxval=50, group=groupDiv, inline="pv")
i_pivR      = input.int(3,  "Pivot Right", minval=1, maxval=50, group=groupDiv, inline="pv")
i_divMin    = input.int(5,  "Min Bars Between Pivots", minval=1, maxval=100, group=groupDiv, inline="rg")
i_divMax    = input.int(24, "Max Bars",                minval=2, maxval=300, group=groupDiv, inline="rg")
i_regBull   = input.bool(true,  "Regular Bullish  (price LL, pressure HL)", group=groupDiv)
i_regBear   = input.bool(true,  "Regular Bearish  (price HH, pressure LH)", group=groupDiv)
i_hidBull   = input.bool(false, "Hidden Bullish   (price HL, pressure LL)", group=groupDiv)
i_hidBear   = input.bool(false, "Hidden Bearish   (price LH, pressure HH)", group=groupDiv)
i_divLines  = input.bool(true,  "Draw Connector Lines", group=groupDiv)
i_divShift  = input.bool(true,  "Draw Marker At The Pivot", group=groupDiv,
     tooltip="ON draws the triangle back at the pivot bar it describes. OFF draws it at the bar it was CONFIRMED, which is Pivot Right bars later and is when you would actually have known. Turn OFF if markers are not appearing - a back-shifted shape is the first thing to rule out.")
i_cRegBull  = input.color(#00FFFF, "Bullish Div", group=groupDiv, inline="dc1")
i_cRegBear  = input.color(#FFD700, "Bearish Div", group=groupDiv, inline="dc1")
i_cHidBull  = input.color(#00E5FF, "Hidden Bull", group=groupDiv, inline="dc2")
i_cHidBear  = input.color(#FF8C42, "Hidden Bear", group=groupDiv, inline="dc2")

i_showTable  = input.bool(true, "Show Info Table", group=groupTable)
tPos = switch input.string("Top Right", "Table Position", options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group=groupTable)
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    => position.bottom_right

// ── CUSTOM SMMA ───────────────────────────────────────────────────
smma(float src, int length) =>
    float s = 0.0
    float sma1 = ta.sma(src, length)
    s := na(s[1]) ? sma1 : (s[1] * (length - 1) + src) / length
    s

// ── SMMA RIBBON + 3-STATE REGIME ─────────────────────────────────
float v1 = smma(i_src, i_fastOut)
float m1 = smma(i_src, i_fastIn)
float m2 = smma(i_src, i_slowIn)
float v2 = smma(i_src, i_slowOut)

bool inconclusive = (v1 < m1) != (v1 < v2) or (m2 < v2) != (v1 < v2)
bool bearish      = not inconclusive and v1 < v2
bool bullish      = not inconclusive and not bearish

// ── REGIME (for table display only) ───────────────────────────────
float ribbonMid     = (v1 + v2) / 2

// ── TRUE RANGE PRESSURE ENGINE ───────────────────────────────────
// True Range decomposition: captures gap pressure from prior close
float trueLow  = math.min(low, nz(close[1], low))
float trueHigh = math.max(high, nz(close[1], high))
float trueRange = trueHigh - trueLow
float trSafe    = trueRange == 0 ? 1 : trueRange

// Intrabar pressure (single bar, normalized by TR)
float intraBP = ((close - trueLow) / trSafe) * 100
float intraSP = ((trueHigh - close) / trSafe) * 100

// Structural pressure (cumulative over lookback, normalized by cumulative TR)
float cumBP = math.sum(close - trueLow, i_length)
float cumSP = math.sum(trueHigh - close, i_length)
float cumTR = math.sum(trueRange, i_length)
float cumTRsafe = cumTR == 0 ? 1 : cumTR

float structBP = (cumBP / cumTRsafe) * 100
float structSP = (cumSP / cumTRsafe) * 100

// Mode selection
float rawBulls = i_mode == "Average" ? (intraBP + structBP) / 2 : i_mode == "Intrabar" ? intraBP : structBP
float rawBears = i_mode == "Average" ? (intraSP + structSP) / 2 : i_mode == "Intrabar" ? intraSP : structSP

// SMA smoothing
float bullLine = ta.sma(rawBulls, i_smooth)
float bearLine = ta.sma(rawBears, i_smooth)

// Derived
float pressureSpread = bullLine - bearLine
float pressureRatio  = (bullLine + bearLine) > 0 ? bullLine / (bullLine + bearLine) * 100 : 50
bool  bullCross      = ta.crossover(bullLine, bearLine)
bool  bearCross      = ta.crossunder(bullLine, bearLine)
bool  bullDominant   = bullLine > bearLine

// ── DIVERGENCE ───────────────────────────────────────────────────
// Pivots are found on the OSCILLATOR and confirmed i_pivR bars later, so
// nothing here reads a bar that had not happened. bullLine[i_pivR] is the
// value AT the pivot; ta.valuewhen(...,1) is the pivot before it.
float divSrc = i_divSrc == "RSI" ? ta.rsi(close, i_rsiLen) : bullLine

bool plFound = i_divOn and not na(ta.pivotlow(divSrc,  i_pivL, i_pivR))
bool phFound = i_divOn and not na(ta.pivothigh(divSrc, i_pivL, i_pivR))

inRange(bool cond) =>
    int bars = ta.barssince(cond == true)
    i_divMax >= bars and bars >= i_divMin

// regular bullish: price lower low, pressure higher low
bool oscHL   = divSrc[i_pivR] > ta.valuewhen(plFound, divSrc[i_pivR], 1) and inRange(plFound[1])
bool priceLL = low[i_pivR]    < ta.valuewhen(plFound, low[i_pivR],    1)
bool regBull = i_regBull and plFound and oscHL and priceLL

// hidden bullish: price higher low, pressure lower low
bool oscLL   = divSrc[i_pivR] < ta.valuewhen(plFound, divSrc[i_pivR], 1) and inRange(plFound[1])
bool priceHL = low[i_pivR]    > ta.valuewhen(plFound, low[i_pivR],    1)
bool hidBull = i_hidBull and plFound and oscLL and priceHL

// regular bearish: price higher high, pressure lower high
bool oscLH   = divSrc[i_pivR] < ta.valuewhen(phFound, divSrc[i_pivR], 1) and inRange(phFound[1])
bool priceHH = high[i_pivR]   > ta.valuewhen(phFound, high[i_pivR],   1)
bool regBear = i_regBear and phFound and oscLH and priceHH

// hidden bearish: price lower high, pressure higher high
bool oscHH   = divSrc[i_pivR] > ta.valuewhen(phFound, divSrc[i_pivR], 1) and inRange(phFound[1])
bool priceLH = high[i_pivR]   < ta.valuewhen(phFound, high[i_pivR],   1)
bool hidBear = i_hidBear and phFound and oscHH and priceLH

plotshape(regBull ? divSrc[i_pivR] : na, "Regular Bullish", shape.triangleup,   location.absolute, i_cRegBull, offset=i_divShift ? -i_pivR : 0, size=size.small)
plotshape(hidBull ? divSrc[i_pivR] : na, "Hidden Bullish",  shape.triangleup,   location.absolute, i_cHidBull, offset=i_divShift ? -i_pivR : 0, size=size.small)
plotshape(regBear ? divSrc[i_pivR] : na, "Regular Bearish", shape.triangledown, location.absolute, i_cRegBear, offset=i_divShift ? -i_pivR : 0, size=size.small)
plotshape(hidBear ? divSrc[i_pivR] : na, "Hidden Bearish",  shape.triangledown, location.absolute, i_cHidBear, offset=i_divShift ? -i_pivR : 0, size=size.small)

if i_divLines and (regBull or hidBull)
    int back = int(ta.barssince(plFound[1])) + i_pivR
    line.new(bar_index - back, ta.valuewhen(plFound, divSrc[i_pivR], 1), bar_index - i_pivR, divSrc[i_pivR],
         color=regBull ? i_cRegBull : i_cHidBull, width=1)
if i_divLines and (regBear or hidBear)
    int back = int(ta.barssince(phFound[1])) + i_pivR
    line.new(bar_index - back, ta.valuewhen(phFound, divSrc[i_pivR], 1), bar_index - i_pivR, divSrc[i_pivR],
         color=regBear ? i_cRegBear : i_cHidBear, width=1)

// ── PLOTS ────────────────────────────────────────────────────────
pBull = plot(bullLine, "Bulls", color=i_bullColor, linewidth=2)
pBear = plot(bearLine, "Bears", color=i_bearColor, linewidth=2)
fill(pBull, pBear, color=bullDominant ? color.new(i_bullColor, 85) : color.new(i_bearColor, 85), title="Pressure Fill")

hline(50, "Midline", color=color.new(color.white, 80), linestyle=hline.style_dotted)

// crossover circles removed at v1.11 - the fill already shows dominance, and
// with the lines summing to 100 a cross is just the bull line touching 50.

var int cRB = 0
var int cRb = 0
var int cHB = 0
var int cHb = 0
if regBull
    cRB += 1
if regBear
    cRb += 1
if hidBull
    cHB += 1
if hidBear
    cHb += 1

// ── INFO TABLE ───────────────────────────────────────────────────
string regime    = bullish ? "BULLISH" : bearish ? "BEARISH" : "NEUTRAL"
string sentiment = bullDominant ? "BULLS" : "BEARS"
color regCol     = bullish ? #FFD700 : bearish ? #1E90FF : color.gray
color sentCol    = bullDominant ? i_bullColor : i_bearColor

var table infoTable = table.new(tPos, 2, 7, border_width=1, bgcolor=color.new(color.black, 80))

if i_showTable and barstate.islast
    table.cell(infoTable, 0, 0, "Pressure",  text_color=color.white, bgcolor=color.new(color.gray, 50), text_size=size.small)
    table.cell(infoTable, 1, 0, sentiment,   text_color=color.white, bgcolor=sentCol, text_size=size.small)
    table.cell(infoTable, 0, 1, "Bulls",     text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.small)
    table.cell(infoTable, 1, 1, str.tostring(bullLine, "#.#"),  text_color=i_bullColor, text_size=size.small)
    table.cell(infoTable, 0, 2, "Bears",     text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.small)
    table.cell(infoTable, 1, 2, str.tostring(bearLine, "#.#"),  text_color=i_bearColor, text_size=size.small)
    table.cell(infoTable, 0, 3, "Spread",    text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.small)
    table.cell(infoTable, 1, 3, str.tostring(pressureSpread, "#.#"), text_color=sentCol, text_size=size.small)
    table.cell(infoTable, 0, 4, "Ratio",     text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.small)
    table.cell(infoTable, 1, 4, str.tostring(pressureRatio, "#.#") + "%", text_color=pressureRatio > 55 ? i_bullColor : pressureRatio < 45 ? i_bearColor : color.white, text_size=size.small)
    table.cell(infoTable, 0, 5, "Regime",    text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.small)
    table.cell(infoTable, 1, 5, regime,      text_color=color.white, bgcolor=regCol, text_size=size.small)
    table.cell(infoTable, 0, 6, "Div B/S",   text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.small)
    table.cell(infoTable, 1, 6, str.tostring(cRB + cHB) + " / " + str.tostring(cRb + cHb),
         text_color=(cRB + cHB + cRb + cHb) == 0 ? #FF4444 : #d0d0d0, text_size=size.small)

// Data window exports
plot(pressureRatio, "Pressure Ratio", color.new(color.gray, 100), display=display.data_window)
plot(regBull ? 1 : 0, "Div Reg Bull", color.new(color.gray, 100), display=display.data_window)
plot(regBear ? 1 : 0, "Div Reg Bear", color.new(color.gray, 100), display=display.data_window)
plot(hidBull ? 1 : 0, "Div Hid Bull", color.new(color.gray, 100), display=display.data_window)
plot(hidBear ? 1 : 0, "Div Hid Bear", color.new(color.gray, 100), display=display.data_window)

// ── ALERTS ───────────────────────────────────────────────────────
alertcondition(bullCross, title="Bull Cross", message="{{ticker}} RalisBB: Buying pressure crossed above selling pressure")
alertcondition(bearCross, title="Bear Cross", message="{{ticker}} RalisBB: Selling pressure crossed above buying pressure")
alertcondition(regBull, title="Regular Bullish Divergence", message="{{ticker}} RalisBB: price lower low, buying pressure higher low")
alertcondition(regBear, title="Regular Bearish Divergence", message="{{ticker}} RalisBB: price higher high, buying pressure lower high")
````
