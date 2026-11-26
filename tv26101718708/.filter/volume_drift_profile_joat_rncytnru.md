# Volume Drift Profile [JOAT]

- url: https://www.tradingview.com/script/rNCYtNru-Volume-Drift-Profile-JOAT/
- type: indicator
- pine_id: PUB;70852930c1114447aab38ef51173d87e
- version: 1.0

## Description

[b]Volume Drift Profile [JOAT][/b]

[b]Introduction[/b]

Volume Drift Profile is an open-source trend detection indicator that derives directional bias from rolling pivot averages rather than fixed moving averages, and visualizes volume directly on the drift lines themselves as a histogram. The volume histogram coloring adapts to three modes — delta (buy-sell pressure gradient), trend (directional mono-color), and spike-highlighted — making the volume context immediately readable without a separate volume panel.

Most trend indicators separate the price trend line from the volume analysis. The trend line tells you the direction; you look at a separate volume bar panel to interpret whether that direction is supported. Volume Drift Profile overlaps both by rendering volume bars along the drift lines themselves, so the relationship between trend level and volume support is visually immediate.

[image]https://www.tradingview.com/x/9oYmMklj/[/image]

[b]Core Concepts[/b]

[b]1. Pivot Drift Line Calculation[/b]

The upper drift line is the rolling average of the most recent N confirmed pivot highs. The lower drift line is the rolling average of the most recent N confirmed pivot lows. This produces smoothed, structurally-anchored reference levels that adapt as new pivots confirm, rather than a fixed-period moving average that treats all bars equally.

[pine]
if not na(ph)
    phArr.push(ph)
    if phArr.size() > avgCount : phArr.shift()
    upperDrift := phArr.avg()
[/pine]

Trend flips when price crosses above the upper drift (bull) or below the lower drift (bear).

[b]2. Volume Normalization[/b]

Volume is normalized by its 200-bar standard deviation, capped at 4. This z-score-like measure produces a 0-4 scale where 4 represents an extreme volume spike. The step height of each volume bar on the drift line is proportional to this normalized value, so spike bars visually dominate the histogram.

[b]3. Three Volume Coloring Modes[/b]

Delta mode computes a buy ratio from (close - low) / (high - low) and maps it through color.from_gradient() between the bear and bull theme colors. Bars with higher closes relative to their range appear in bull color; lower closes in bear color. Volume intensity is further modulated by the normalized volume level.

Trend mode uses a single directional color with intensity modulated by normalized volume.

Spike mode uses trend color normally but switches to a dedicated spike color for bars where normalized volume reaches the extreme level.

[b]4. Absorption Detection[/b]

An absorption bar is identified when volume exceeds twice the 20-bar average (high institutional participation) while the body-to-range ratio is below 30% (price closes near where it opened). This pattern suggests large volume without directional price movement — potential institutional accumulation or distribution.

[b]5. Volume-Weighted Momentum[/b]

A running Volume-Weighted Momentum reading tracks cumulative signed volume weighted by price change, normalized to a readable scale. This reading reflects directional institutional bias — rising VWM during an uptrend suggests genuine buying pressure supports the move.

[image]https://www.tradingview.com/x/ZIO1HYWz/[/image]

[b]Features[/b]

[list]
[*][b]Pivot drift lines:[/b] Upper and lower drift from rolling average of last N confirmed pivot highs and lows
[*][b]Volume histogram on drift lines:[/b] Volume bars rendered along the active drift line, sized by normalized volume
[*][b]Three volume coloring modes:[/b] Delta (buy-sell gradient), Trend (directional mono), Spikes (trend + spike highlights)
[*][b]Gradient fill between drift and price:[/b] Translucent fill between the active drift line and current price
[*][b]Candle volume coloring:[/b] Optional bar coloring by volume intensity and trend direction simultaneously
[*][b]Spike detection and highlighting:[/b] Bars with extreme normalized volume shown in dedicated spike color
[*][b]Absorption detection:[/b] High-volume, small-body bars marked as potential institutional absorption events
[*][b]Volume-Weighted Momentum display:[/b] VWM reading normalized and displayed in dashboard
[*][b]Trend flip labels:[/b] Clean text labels at trend reversal points with direction indicator
[*][b]Non-repainting:[/b] Pivot detection uses standard confirmed pivot functions with symmetric lookback
[*][b]Dashboard:[/b] 8-row table with trend direction, volume mode, volume intensity, absorption state, spike state, bars in trend, and VWM
[/list]

[b]Input Parameters[/b]

[b]Drift Structure:[/b]
[list]
[*]Pivot Lookback: Bars required on each side for pivot confirmation (default: 8)
[*]Pivot Avg Count: Number of pivots to average for drift line (default: 3)
[/list]

[b]Volume:[/b]
[list]
[*]Volume Color Mode: Delta / Trend / Spikes
[*]Histogram Height: Scale of volume bars on drift line (default: 0.3)
[*]Show Volume Histogram toggle
[*]Color Price Bars toggle
[*]Show Drift Fill toggle
[*]Spike Color
[/list]

[b]Absorption:[/b]
[list]
[*]Show Absorption Dots toggle
[*]Absorption Volume Multiple (default: 2.0)
[*]Max Body Ratio for absorption detection (default: 0.3)
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the Drift Line Direction[/b]
The active drift line (lower drift in uptrend, upper drift in downtrend) is the primary trend reference. When price is above the lower drift, the trend is bullish. When price crosses the upper drift downward, the trend flips bearish.

[b]Step 2: Interpret Volume Histogram Color[/b]
In Delta mode, teal/bull-colored bars represent buying pressure dominating that bar; bear-colored bars represent selling pressure. When large volume bars appear in the trend direction, it confirms the drift.

[b]Step 3: Monitor Absorption Events[/b]
Absorption dots mark bars where institutional participants may be accumulating. Large absorption bars at drift line levels are particularly significant — they suggest the drift level is actively defended.

[b]Step 4: Use VWM as Direction Confirmer[/b]
Rising VWM during an uptrend means volume-weighted momentum supports price movement. Flat or declining VWM during an uptrend flags weak participation — a potential warning of trend exhaustion.

[b]Indicator Limitations[/b]

[list]
[*]Drift lines require at least N confirmed pivots to begin rendering. In early bars of a new chart, the lines will be absent
[*]The volume histogram renders along the drift line. In periods of very high drift line slope, the histogram may visually overlap the price range
[*]Absorption detection uses volume relative to a 20-bar average. In low-liquidity environments, the threshold may trigger on routine trading activity
[*]The pivot lookback introduces a lag between when a pivot forms and when the drift line updates
[/list]

[b]Originality Statement[/b]

[list]
[*]Rendering a volume histogram directly along pivot drift lines — rather than in a separate panel — as a real-time visualization that integrates trend level and volume support in a single overlay is an original approach
[*]Three independently selectable volume coloring modes driven by a normalized volume z-score, combined with buy-ratio gradient coloring in delta mode, is not replicated in existing open-source pivot drift indicator publications
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Trading involves substantial risk of loss. The author accepts no responsibility for trading losses resulting from use of this indicator.

Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Volume Drift Profile [JOAT]", overlay=true, max_labels_count=50, max_lines_count=10)

// =============================================================================
// SECTION 1 : COLOR THEME
// =============================================================================

string themeInput = input.string("Phantom", "Color Theme",
     options=["Phantom", "Neon", "Classic", "Solar"],
     group="◈ Visual")

var color colorBULL  = na
var color colorBEAR  = na
var color colorELITE = na
var color colorNEUTR = na

if themeInput == "Phantom"
    colorBULL  := color.rgb(6, 182, 212)
    colorBEAR  := color.rgb(236, 72, 153)
    colorELITE := color.rgb(187, 134, 252)
    colorNEUTR := color.rgb(139, 148, 158)
else if themeInput == "Neon"
    colorBULL  := #00F5D4
    colorBEAR  := #FF4466
    colorELITE := #6C63FF
    colorNEUTR := #FFD700
else if themeInput == "Classic"
    colorBULL  := color.rgb(0, 255, 0)
    colorBEAR  := color.rgb(255, 0, 0)
    colorELITE := color.rgb(187, 134, 252)
    colorNEUTR := color.rgb(139, 148, 158)
else
    colorBULL  := #FF9800
    colorBEAR  := #42A5F5
    colorELITE := #FFEB3B
    colorNEUTR := #9E9E9E

// =============================================================================
// SECTION 2 : INPUTS
// =============================================================================

// ── Drift Structure ──────────────────────────────────────────────────────────
var string G_STR = "◈ Drift Structure"
int  pivLen   = input.int(8,  "Pivot Lookback",  minval=2,    maxval=30,  group=G_STR)
int  avgCount = input.int(3,  "Pivot Avg Count", minval=1,    maxval=10,  group=G_STR)

// ── Volume ────────────────────────────────────────────────────────────────────
var string G_VOL = "◈ Volume"
string volMode   = input.string("Delta", "Volume Color Mode",
     options=["Delta", "Trend", "Spikes"], group=G_VOL)
float  i_volSize = input.float(0.3,   "Histogram Height",     minval=0.05, maxval=2.0,  step=0.05, group=G_VOL)
bool   showVol   = input.bool(true,   "Show Volume Histogram",  group=G_VOL)
bool   paintBars = input.bool(true,   "Color Price Bars",       group=G_VOL)
bool   showFill  = input.bool(true,   "Show Drift Fill",        group=G_VOL)
color  spikeCol  = input.color(#ff0000, "Spike Color",          group=G_VOL)

// ── Absorption ────────────────────────────────────────────────────────────────
var string G_ABS = "◈ Absorption"
bool  showAbsorption = input.bool(true,  "Show Absorption Dots",    group=G_ABS)
float absVolMult     = input.float(2.0,  "Absorption Vol Multiple", minval=1.0, step=0.1, group=G_ABS)
float absBodyMax     = input.float(0.3,  "Max Body Ratio",          minval=0.05, maxval=0.9, step=0.05, group=G_ABS)

// ── Volume-Weighted Momentum ──────────────────────────────────────────────────
var string G_VWM = "◈ Volume-Weighted Momentum"
bool showVWM = input.bool(true, "Show VWM in Dashboard", group=G_VWM)

// ── Dashboard ─────────────────────────────────────────────────────────────────
var string G_DASH = "◈ Dashboard"
bool   showDash = input.bool(true,         "Show Dashboard", group=G_DASH)
string dashPos  = input.string("Top Right", "Position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=G_DASH)
string dashSize = input.string("Small",     "Size",
     options=["Tiny", "Small", "Normal"], group=G_DASH)

// =============================================================================
// SECTION 3 : PIVOT DETECTION & DRIFT LINE CALCULATION
// =============================================================================

float ph = ta.pivothigh(high, pivLen, pivLen)
float pl = ta.pivotlow( low,  pivLen, pivLen)

var array<float> phArr = array.new<float>()
var array<float> plArr = array.new<float>()
var float upperDrift   = na
var float lowerDrift   = na

if not na(ph)
    phArr.push(ph)
    if phArr.size() > avgCount
        phArr.shift()
    if phArr.size() >= 1
        upperDrift := phArr.avg()

if not na(pl)
    plArr.push(pl)
    if plArr.size() > avgCount
        plArr.shift()
    if plArr.size() >= 1
        lowerDrift := plArr.avg()

// =============================================================================
// SECTION 4 : TREND STATE MACHINE
// =============================================================================

var bool  trend    = true
var color trendCol = na

if not na(upperDrift) and not na(lowerDrift)
    if ta.crossover(close, upperDrift)
        trend    := true
        trendCol := colorBULL
    else if ta.crossunder(close, lowerDrift)
        trend    := false
        trendCol := colorBEAR

// Seed trendCol before any crossover fires
if na(trendCol)
    trendCol := colorBULL

// Trend flip: avoid ta.change() on bool — compare directly
bool trendFlip = trend != trend[1]

// Active drift band: bull → show lower drift as support; bear → show upper drift as resistance
// trend is a bool series (always initialised), never na — select the appropriate drift line directly
float mainBand = trend ? lowerDrift : upperDrift

// =============================================================================
// SECTION 5 : VOLUME NORMALIZATION
// =============================================================================

float distance = ta.sma(high - low, 200)
float volStdev = ta.stdev(volume, 200)
float n_vol    = volStdev > 0.0 ? math.min(4.0, volume / volStdev) : 0.0
bool  isSpike  = n_vol >= 4.0

// Step unit for histogram height scaling
float step_ = (distance * i_volSize) / 4.0

// =============================================================================
// SECTION 6 : VOLUME COLORING — THREE MODES
// =============================================================================

// baseCol is updated every bar based on the selected volume mode
var color baseCol = colorBULL

if volMode == "Delta"
    float buyRatio = (high - low) > 0.0 ? (close - low) / (high - low) : 0.5
    baseCol := color.from_gradient(buyRatio, 0.35, 0.65, colorBEAR, colorBULL)
else if volMode == "Spikes"
    baseCol := isSpike ? spikeCol : trendCol
else
    // "Trend" mode — just follow the current trend colour
    baseCol := trendCol

// Intensity-blended colours
color volCol    = color.from_gradient(n_vol, 0.0, 4.0, color.new(baseCol, 65), baseCol)
color candleCol = color.from_gradient(n_vol, 0.0, 4.0, color.new(trendCol, 70), trendCol)

// =============================================================================
// SECTION 7 : VOLUME HISTOGRAM — RENDERED ON DRIFT LINE
// =============================================================================
// The histogram is drawn as a plotcandle where:
//   high = volEdge (volume-displaced from the drift band)
//   low  = volBase (the drift band itself)
// Both open and close are set to the same values to produce a flat body.

float volBase = not trendFlip and not na(mainBand) ? mainBand : na
float volEdge = not trendFlip and not na(mainBand) ?
     (trend ? mainBand + step_ * n_vol : mainBand - step_ * n_vol) : na

plotcandle(volEdge, volEdge, volBase, volBase, "Vol Hist",
     color       = showVol ? volCol : na,
     wickcolor   = showVol ? volCol : na,
     bordercolor = showVol ? volCol : na,
     display     = display.all)

// =============================================================================
// SECTION 8 : PRICE CANDLE COLORING
// =============================================================================

plotcandle(open, high, low, close, "Candles",
     color       = paintBars ? candleCol : na,
     wickcolor   = paintBars ? candleCol : na,
     bordercolor = paintBars ? candleCol : na,
     display     = paintBars ? display.all : display.none)

// =============================================================================
// SECTION 9 : DRIFT LINE PLOT & GRADIENT FILL
// =============================================================================

pMain = plot(
     not trendFlip and not na(mainBand) ? mainBand : na,
     "Drift Line",
     color = color.new(trendCol, 30),
     linewidth = 2,
     style = plot.style_linebr)

pHL2 = plot(hl2, "HL2 Ref", color = na, display = display.none)

fill(pMain, pHL2, color = showFill ? color.new(trendCol, 80) : color(na))

// =============================================================================
// SECTION 10 : TREND FLIP LABELS
// =============================================================================
// Clean triangle labels — no plotshape arrows

if trendFlip and trend
    label.new(bar_index, low,  "▲",
         style     = label.style_label_up,
         color     = color(na),
         textcolor = colorBULL,
         size      = size.normal)

if trendFlip and not trend
    label.new(bar_index, high, "▼",
         style     = label.style_label_down,
         color     = color(na),
         textcolor = colorBEAR,
         size      = size.normal)

// =============================================================================
// SECTION 11 : ABSORPTION BAR DETECTION
// =============================================================================
// High-volume, small-body bars signal potential absorption of order flow.

float avgVol20   = ta.ema(volume, 20)
float bodyRatioA = (high - low) > 0.0 ? math.abs(close - open) / (high - low) : 0.0
bool  absorption = volume > avgVol20 * absVolMult and bodyRatioA < absBodyMax and barstate.isconfirmed

plotchar(showAbsorption and absorption, "Absorption", "●",
     location.belowbar, color.new(colorELITE, 20), size = size.tiny)

// =============================================================================
// SECTION 12 : VOLUME-WEIGHTED MOMENTUM (VWM)
// =============================================================================
// Cumulative sum of (price change × volume), normalised to a ±50 scale.

var float cumVWM = 0.0
cumVWM += ta.change(close) * volume

float vwmNorm = na
float vwmLow  = ta.lowest(cumVWM,  100)
float vwmHigh = ta.highest(cumVWM, 100)

if vwmHigh != vwmLow
    vwmNorm := (cumVWM - vwmLow) / (vwmHigh - vwmLow) * 100.0 - 50.0

// =============================================================================
// SECTION 13 : BARS IN TREND COUNTER
// =============================================================================

var int barsInTrend = 0
if trendFlip
    barsInTrend := 0
else
    barsInTrend += 1

// =============================================================================
// SECTION 14 : ALERT CONDITIONS
// =============================================================================

alertcondition(trendFlip and trend,
     "VDP Trend Flip Bull",
     "Volume Drift Profile: Bullish trend flip confirmed.")

alertcondition(trendFlip and not trend,
     "VDP Trend Flip Bear",
     "Volume Drift Profile: Bearish trend flip confirmed.")

alertcondition(absorption,
     "VDP Absorption Detected",
     "Volume Drift Profile: High-volume absorption bar detected.")

alertcondition(isSpike and barstate.isconfirmed,
     "VDP Volume Spike",
     "Volume Drift Profile: Volume spike detected (4+ std devs).")

// =============================================================================
// SECTION 15 : DASHBOARD
// =============================================================================

// ── Cell helper ───────────────────────────────────────────────────────────────
// Position & size resolution
string dashPosVal = switch dashPos
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    =>                position.top_right

string dSz = switch dashSize
    "Tiny"   => size.tiny
    "Normal" => size.normal
    =>          size.small

// ── Table declaration ─────────────────────────────────────────────────────────
// 2 columns, 9 rows (indices 0–8)
var table dash = table.new(
     dashPosVal, 2, 9,
     bgcolor      = color.new(#0d1117, 10),
     border_color = color.new(#30363d, 20),
     border_width = 1,
     frame_color  = color.new(#30363d, 40),
     frame_width  = 1)

// ── Cell helper ───────────────────────────────────────────────────────────────
f_dc(int col, int row, string txt, color tc, color bg) =>
    table.cell(dash, col, row, txt,
         text_color  = tc,
         text_size   = dSz,
         bgcolor     = bg,
         text_halign = col == 0 ? text.align_left : text.align_right)

// ── Render on last confirmed bar only ────────────────────────────────────────
if showDash and barstate.islast
    // Palette shortcuts
    color hBg  = color.new(#1A237E, 0)
    color pBg  = color.new(#161b22, 0)
    color dBg  = color.new(#0d1117, 10)
    color cMut = color.new(#8b949e, 0)

    // Row 0 — header
    f_dc(0, 0, "Volume Drift Profile [JOAT]", colorELITE, hBg)
    f_dc(1, 0, timeframe.period + " | v1.0",  cMut,       hBg)

    // Row 1 — trend direction
    f_dc(0, 1, "Trend",   cMut, pBg)
    f_dc(1, 1, trend ? "Bullish" : "Bearish",
         trend ? colorBULL : colorBEAR, dBg)

    // Row 2 — volume mode
    f_dc(0, 2, "Vol Mode", cMut, pBg)
    f_dc(1, 2, volMode,    cMut, dBg)

    // Row 3 — volume intensity
    color volIntCol = isSpike ? spikeCol : n_vol > 2.0 ? colorBULL : cMut
    f_dc(0, 3, "Vol Intensity", cMut, pBg)
    f_dc(1, 3,
         isSpike ? "SPIKE" : str.tostring(n_vol, "#.##") + "σ",
         volIntCol, dBg)

    // Row 4 — absorption
    f_dc(0, 4, "Absorption", cMut, pBg)
    f_dc(1, 4,
         absorption ? "DETECTED" : "─",
         absorption ? colorELITE : cMut, dBg)

    // Row 5 — bars in trend
    f_dc(0, 5, "Bars in Trend", cMut, pBg)
    f_dc(1, 5, str.tostring(barsInTrend), cMut, dBg)

    // Row 6 — current drift level
    f_dc(0, 6, "Drift Level", cMut, pBg)
    f_dc(1, 6,
         not na(mainBand) ? str.tostring(mainBand, format.mintick) : "─",
         trend ? colorBULL : colorBEAR, dBg)

    // Row 7 — VWM reading
    color vwmCol = not na(vwmNorm) ?
         (vwmNorm > 10.0 ? colorBULL : vwmNorm < -10.0 ? colorBEAR : cMut) : cMut
    f_dc(0, 7, "VWM", cMut, pBg)
    f_dc(1, 7,
         showVWM and not na(vwmNorm) ? str.tostring(vwmNorm, "#.#") : "─",
         vwmCol, dBg)

    // Row 8 — branding footer
    f_dc(0, 8, "[JOAT]",          color.new(#6C63FF, 0), color.new(#0d1117, 20))
    f_dc(1, 8, "jackofalltrades", cMut,                  color.new(#0d1117, 20))

// =============================================================================
// END OF SCRIPT
// =============================================================================
````
