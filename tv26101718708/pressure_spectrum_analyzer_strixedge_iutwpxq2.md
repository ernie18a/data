# Pressure Spectrum Analyzer [StrixEDGE]

- url: https://www.tradingview.com/script/iuTWpXQ2-Pressure-Spectrum-Analyzer-StrixEDGE/
- type: indicator
- pine_id: PUB;45b6119181cc4727b4cba2b05ab58619
- version: 1.0

## Description

StrixEDGE is a pressure spectrum analyzer that decomposes each candle into its buying vs selling pressure components, then visualizes pressure alignment across eight Fibonacci-based lookback periods as a real-time colored heatmap ribbon. Instead of relying on derived calculations from close prices alone, it reads the internal anatomy of every candle to reveal what buyers and sellers are actually doing.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔮 CORE CONCEPT — CANDLE PRESSURE DECOMPOSITION

Most indicators process the closing price through mathematical formulas. StrixEDGE starts differently: it decomposes each candle's anatomy into a net pressure score.

→ Buying pressure = (close − low) / (high − low)
https://www.tradingview.com/x/z0PAtKPU/
→ Selling pressure = (high − close) / (high − low)
https://www.tradingview.com/x/MBbl4JWm/
→ Net pressure = buying − selling → ranges from −1 to +1

A candle closing at its absolute high scores +1 (pure buying dominance). A candle closing at its low scores −1 (pure selling dominance). A doji closing at the midpoint scores 0 (equilibrium). This raw pressure reading captures information that close-price-only indicators miss entirely: wick rejections, body dominance, and where within the range the session actually settled.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔮 THE FIBONACCI SPECTRUM — 8 BANDS

The raw net pressure is then smoothed with an EMA at eight Fibonacci lookback periods:

Band 1 → 3 bars (ultra-fast, reacts to individual candles)
Band 2 → 5 bars
Band 3 → 8 bars
Band 4 → 13 bars
Band 5 → 21 bars
Band 6 → 34 bars
Band 7 → 55 bars
Band 8 → 89 bars (trend anchor, moves slowly)

Each band is displayed as a horizontal color stripe. The result is an 8-layer heatmap ribbon that updates every bar:

→ Bright green = strong buying pressure at that period
→ Pale green = moderate buying
→ Gray = neutral / equilibrium
→ Pale red = moderate selling
→ Bright red = strong selling pressure

The visual effect is immediate: when all 8 bands turn the same color, the market is in full alignment. When they diverge (top bands green, bottom bands red, or vice versa), the market is in transition — and that transition is where the edge lives.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔮 HOW TO READ THE RIBBON

ALL BANDS GREEN — Full bullish convergence. Buying pressure dominates across all timeframes from 3-bar to 89-bar. Strong trend in progress.

ALL BANDS RED — Full bearish convergence. Selling pressure dominates across all timeframes. Strong downtrend in progress.

MIXED COLORS — Disagreement between timeframes. The market is choppy, consolidating, or transitioning. No clear edge.

BOTTOM BANDS FLIP FIRST — The fast periods (3, 5, 8) change color before the slow periods (34, 55, 89). This is a momentum wave forming — an early reversal signal before the full spectrum converges. StrixEDGE marks these moments with yellow diamond markers (◆).

TOP BANDS HOLD WHILE BOTTOM FLIP — The trend anchor (slow periods) remains in one direction while fast periods temporarily flip. Often a pullback within a larger trend, not a reversal.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔮 WAVE DETECTION — EARLY REVERSAL WARNING

StrixEDGE includes a proprietary wave detection system. It identifies when the three fastest bands (3, 5, 8) have already flipped direction while the three slowest bands (34, 55, 89) have not. This divergence between fast and slow pressure readings often precedes a full spectrum convergence by several bars, giving an early warning of potential trend shifts.

Wave markers appear as yellow diamonds (◆) on the ribbon. They are not entry signals — they are attention signals. When a wave marker appears, watch for the remaining bands to follow. If they do, a full convergence signal follows.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔮 SIGNAL GENERATION

Buy and Sell signals fire when the spectrum achieves convergence:

1. Convergence Threshold — A configurable minimum number of bands (default 6 out of 8) must agree on the same direction.

2. Transition Detection — The signal fires only on the bar where the convergence count first crosses the threshold, not on every bar it remains above it.

3. Flip-Only Logic — After a Buy signal, the next signal must be a Sell (and vice versa). No consecutive same-direction signals.

4. Cooldown — A configurable minimum number of bars between signals (default 10).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔮 THE PULSE LINE

A composite line overlaid on the ribbon shows the average pressure across all 8 bands, scaled to the ribbon's visual range. It provides a single-glance summary of the aggregate market pressure:

→ Pulse above midline and green = net buying pressure
→ Pulse below midline and red = net selling pressure
→ Pulse at midline and gray = equilibrium

The pulse line often leads the ribbon visually — it can curl toward the midline before the individual bands start flipping, providing another layer of early warning.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔮 DASHBOARD

The on-chart dashboard displays:
→ Real-time pressure reading for each of the 8 bands with directional arrows
→ Convergence count and direction (e.g., "6 / 8 BULL")
→ Composite pulse value
→ Current wave status (Bull Forming / Bear Forming / None)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔮 SETTINGS GUIDE

Spectrum
• Bullish Threshold (default 0.15) — Pressure above this value counts as bullish for convergence scoring. Lower = more sensitive.
• Bearish Threshold (default −0.15) — Pressure below this counts as bearish. Closer to zero = more sensitive.

https://www.tradingview.com/x/6yTPYwSx/

Signals
• Convergence Minimum (default 6) — How many of the 8 bands must agree. Range 3-8. Higher = fewer but stronger signals.
• Signal Cooldown (default 10 bars) — Minimum spacing between consecutive signals.

Display
• Show Pulse Line — Toggle the composite pressure overlay.
• Show Wave Markers — Toggle early reversal diamonds.
• Show Dashboard — Toggle the status table.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔮 WHAT MAKES THIS ORIGINAL

StrixEDGE is not a wrapper around existing indicators. Its originality lies in three layers:

1. The data source is candle anatomy (body position within range), not close price or volume alone. This extracts buying/selling pressure information that close-price-derived indicators structurally cannot access.

2. The multi-period spectrum approach displays pressure alignment across eight simultaneous timeframes in a single visual. Standard oscillators show one reading at one lookback period. StrixPULSE shows eight readings simultaneously as a heatmap, making convergence and divergence visible at a glance.

3. Wave detection identifies the propagation pattern — when fast periods lead slow periods in a directional flip — as a standalone analytical feature. This captures the internal momentum dynamics of a trend change, not just the result.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔮 RECOMMENDED USE

Designed for day trading timeframes (15-minute to 1-hour). Works across all markets with standard OHLC data: crypto, forex, stocks, indices, commodities. Best used as a companion below the main chart alongside an overlay indicator (such as StrixEDGE or any trend-following system). The ribbon provides the conviction layer — it answers "should I trust this signal?" by showing whether the pressure spectrum supports the trade direction.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️ DISCLAIMER
This indicator is a technical analysis tool, not financial advice. No indicator guarantees profitable outcomes. Past performance of any signal does not indicate future results. Always apply proper risk management and use this tool as one component of a complete trading plan.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

5 alert conditions: Buy Signal, Sell Signal, Any Signal, Bull Wave, Bear Wave.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © StrixEDGE

//@version=6
indicator("Pressure Spectrum Analyzer [StrixEDGE]", shorttitle="Pressure Spectrum Analyzer [StrixEDGE]", overlay=false, max_bars_back=500, precision=2)

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  StrixPULSE — Pressure Spectrum Analyzer v1.0                               ║
// ║                                                                              ║
// ║  Decomposes each candle into buying vs selling pressure, then displays       ║
// ║  pressure alignment across 8 Fibonacci lookback periods as a colored         ║
// ║  spectrum ribbon. Signals fire when the spectrum fully converges.            ║
// ║                                                                              ║
// ║  Unique elements:                                                            ║
// ║  • Candle anatomy pressure (not just close price)                            ║
// ║  • 8-period Fibonacci spectrum (3,5,8,13,21,34,55,89)                       ║
// ║  • Visual heatmap ribbon showing momentum propagation                       ║
// ║  • Convergence-based signal generation with flip-only logic                 ║
// ╚══════════════════════════════════════════════════════════════════════════════╝


// ============================================================================
// INPUTS
// ============================================================================

// ── Spectrum ──────────────────────────────────────────────────────────────────
string GRP_SPEC  = "🔮 Spectrum"
float  i_bullThr = input.float(0.15,  "Bullish Threshold",   minval=0.01, maxval=0.5, step=0.05, group=GRP_SPEC, tooltip="Pressure above this = bullish band. Lower = more sensitive.")
float  i_bearThr = input.float(-0.15, "Bearish Threshold",   minval=-0.5, maxval=-0.01, step=0.05, group=GRP_SPEC, tooltip="Pressure below this = bearish band. Higher (closer to 0) = more sensitive.")

// ── Signals ───────────────────────────────────────────────────────────────────
string GRP_SIG   = "⚡ Signals"
int    i_convMin = input.int(6,   "Convergence Minimum",  minval=3, maxval=8, group=GRP_SIG, tooltip="How many of the 8 bands must agree for a signal (3-8). Default 6 = conservative.")
int    i_cooldown= input.int(10,  "Signal Cooldown (bars)", minval=1, maxval=100, group=GRP_SIG, tooltip="Minimum bars between signals.")

// ── Display ───────────────────────────────────────────────────────────────────
string GRP_DISP  = "🎨 Display"
bool   i_showPulse = input.bool(true,  "Show Pulse Line",   group=GRP_DISP, tooltip="Composite average of all 8 spectrum bands.")
bool   i_showWave  = input.bool(true,  "Show Wave Markers",  group=GRP_DISP, tooltip="Marks when fast bands flip before slow bands — early reversal warning.")
bool   i_showDash  = input.bool(true,  "Show Dashboard",     group=GRP_DISP)


// ============================================================================
// CANDLE PRESSURE DECOMPOSITION
// ============================================================================
// Instead of using close price directly, we decompose each candle's anatomy
// to extract the TRUE buying vs selling pressure.
//
//   buying_pressure  = (close − low) / (high − low)    → 0 to 1
//   selling_pressure = (high − close) / (high − low)   → 0 to 1
//   net_pressure     = buying − selling                 → −1 to +1
//
// A candle closing at its high = +1 (pure buying)
// A candle closing at its low  = −1 (pure selling)
// A doji (close ≈ midpoint)    =  0 (neutral)

float candleRange  = high - low
float netPressure  = candleRange > 0 ? (close - low) / candleRange * 2.0 - 1.0 : 0.0


// ============================================================================
// FIBONACCI SPECTRUM — 8 smoothed pressure readings
// ============================================================================
// Each band smooths the raw pressure at a different Fibonacci period.
// Fast bands (3,5) react immediately. Slow bands (55,89) show the trend.
// When ALL bands agree → strong conviction. When they diverge → uncertainty.

float s1 = ta.ema(netPressure, 3)     // ── Band 1: ultra-fast
float s2 = ta.ema(netPressure, 5)     // ── Band 2: fast
float s3 = ta.ema(netPressure, 8)     // ── Band 3: quick
float s4 = ta.ema(netPressure, 13)    // ── Band 4: medium-fast
float s5 = ta.ema(netPressure, 21)    // ── Band 5: medium
float s6 = ta.ema(netPressure, 34)    // ── Band 6: medium-slow
float s7 = ta.ema(netPressure, 55)    // ── Band 7: slow
float s8 = ta.ema(netPressure, 89)    // ── Band 8: trend anchor


// ============================================================================
// BAND COLOR FUNCTION
// ============================================================================
// Maps pressure value (−1 to +1) to a color gradient:
//   Strong bull → Bright green
//   Moderate bull → Medium green
//   Weak bull → Pale green
//   Neutral → Gray
//   Weak bear → Pale red
//   Moderate bear → Medium red
//   Strong bear → Bright red

bandColor(float val) =>
    if val > 0.30
        color.new(#00C853, 8)
    else if val > 0.15
        color.new(#69F0AE, 20)
    else if val > 0.05
        color.new(#B9F6CA, 35)
    else if val > -0.05
        color.new(#90A4AE, 45)
    else if val > -0.15
        color.new(#FFAB91, 35)
    else if val > -0.30
        color.new(#FF5252, 20)
    else
        color.new(#D50000, 8)


// ============================================================================
// RIBBON DISPLAY — 8 colored bands
// ============================================================================
// Hidden horizontal plots create fixed levels 0–8.
// fill() between adjacent levels creates bands whose color depends on
// the smoothed pressure at that Fibonacci period.
// Bottom = fastest (3-bar), Top = slowest (89-bar).

p_0 = plot(0, editable=false, display=display.none)
p_1 = plot(1, editable=false, display=display.none)
p_2 = plot(2, editable=false, display=display.none)
p_3 = plot(3, editable=false, display=display.none)
p_4 = plot(4, editable=false, display=display.none)
p_5 = plot(5, editable=false, display=display.none)
p_6 = plot(6, editable=false, display=display.none)
p_7 = plot(7, editable=false, display=display.none)
p_8 = plot(8, editable=false, display=display.none)

fill(p_0, p_1, color=bandColor(s1), title="Band 1 — 3 bars")
fill(p_1, p_2, color=bandColor(s2), title="Band 2 — 5 bars")
fill(p_2, p_3, color=bandColor(s3), title="Band 3 — 8 bars")
fill(p_3, p_4, color=bandColor(s4), title="Band 4 — 13 bars")
fill(p_4, p_5, color=bandColor(s5), title="Band 5 — 21 bars")
fill(p_5, p_6, color=bandColor(s6), title="Band 6 — 34 bars")
fill(p_6, p_7, color=bandColor(s7), title="Band 7 — 55 bars")
fill(p_7, p_8, color=bandColor(s8), title="Band 8 — 89 bars")

// ── Thin separator lines between bands ────────────────────────────────────────
hline(1, color=color.new(#546E7A, 85), linestyle=hline.style_dotted, title="Sep 1")
hline(2, color=color.new(#546E7A, 85), linestyle=hline.style_dotted, title="Sep 2")
hline(3, color=color.new(#546E7A, 85), linestyle=hline.style_dotted, title="Sep 3")
hline(4, color=color.new(#546E7A, 70), linestyle=hline.style_dashed, title="Midline")
hline(5, color=color.new(#546E7A, 85), linestyle=hline.style_dotted, title="Sep 5")
hline(6, color=color.new(#546E7A, 85), linestyle=hline.style_dotted, title="Sep 6")
hline(7, color=color.new(#546E7A, 85), linestyle=hline.style_dotted, title="Sep 7")


// ============================================================================
// COMPOSITE PULSE LINE
// ============================================================================
// Average of all 8 spectrum bands, scaled from (−1,+1) to (0,8) to overlay
// on the ribbon. Shows the aggregate pressure direction.

float pulse       = (s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8) / 8.0
float pulseScaled = (pulse + 1.0) / 2.0 * 8.0

color pulseColor  = pulse > 0.1 ? color.new(#00E676, 0) : pulse < -0.1 ? color.new(#FF5252, 0) : color.new(#B0BEC5, 0)
plot(i_showPulse ? pulseScaled : na, "Pulse Line", color=pulseColor, linewidth=2, style=plot.style_line)


// ============================================================================
// CONVERGENCE SCORING
// ============================================================================
// Count how many bands are bullish or bearish

int bullCount = (s1 > i_bullThr ? 1 : 0) + (s2 > i_bullThr ? 1 : 0) + (s3 > i_bullThr ? 1 : 0) + (s4 > i_bullThr ? 1 : 0) + (s5 > i_bullThr ? 1 : 0) + (s6 > i_bullThr ? 1 : 0) + (s7 > i_bullThr ? 1 : 0) + (s8 > i_bullThr ? 1 : 0)
int bearCount = (s1 < i_bearThr ? 1 : 0) + (s2 < i_bearThr ? 1 : 0) + (s3 < i_bearThr ? 1 : 0) + (s4 < i_bearThr ? 1 : 0) + (s5 < i_bearThr ? 1 : 0) + (s6 < i_bearThr ? 1 : 0) + (s7 < i_bearThr ? 1 : 0) + (s8 < i_bearThr ? 1 : 0)


// ============================================================================
// WAVE DETECTION — early reversal warning
// ============================================================================
// When the 3 fastest bands (3,5,8) have already flipped direction but the
// 3 slowest bands (34,55,89) haven't yet, it signals a momentum wave forming.
// This often precedes a full spectrum convergence by several bars.

bool fastBull = s1 > i_bullThr and s2 > i_bullThr and s3 > i_bullThr
bool slowBear = s6 < i_bearThr and s7 < i_bearThr and s8 < i_bearThr
bool fastBear = s1 < i_bearThr and s2 < i_bearThr and s3 < i_bearThr
bool slowBull = s6 > i_bullThr and s7 > i_bullThr and s8 > i_bullThr

bool waveBull = fastBull and slowBear     // fast bands turned bull, slow still bear
bool waveBear = fastBear and slowBull     // fast bands turned bear, slow still bull

// Only show on the first bar of wave detection
bool waveUpNew   = waveBull and not waveBull[1]
bool waveDownNew = waveBear and not waveBear[1]

plotshape(i_showWave and waveUpNew,   "Wave ▲", shape.diamond, location.bottom, color.new(#FFD740, 0), size=size.tiny)
plotshape(i_showWave and waveDownNew, "Wave ▼", shape.diamond, location.top,    color.new(#FFD740, 0), size=size.tiny)


// ============================================================================
// SIGNAL GENERATION — convergence + flip-only
// ============================================================================
bool rawBull = bullCount >= i_convMin and bullCount[1] < i_convMin
bool rawBear = bearCount >= i_convMin and bearCount[1] < i_convMin

var int lastSigDir = 0
var int lastSigBar = -9999

bool buySignal  = rawBull and lastSigDir != 1  and (bar_index - lastSigBar) >= i_cooldown
bool sellSignal = rawBear and lastSigDir != -1 and (bar_index - lastSigBar) >= i_cooldown

if buySignal
    lastSigDir := 1
    lastSigBar := bar_index
if sellSignal
    lastSigDir := -1
    lastSigBar := bar_index

// ── Signal markers on the ribbon ──────────────────────────────────────────────
plotshape(buySignal,  "Buy",  shape.labelup,   location.bottom, color.new(#00E676, 0), text="Buy",  textcolor=color.white, size=size.small)
plotshape(sellSignal, "Sell", shape.labeldown,  location.top,    color.new(#FF5252, 0), text="Sell", textcolor=color.white, size=size.small)


// ============================================================================
// DASHBOARD TABLE
// ============================================================================
if i_showDash and barstate.islast

    var table dash = table.new(position.top_right, 3, 12, bgcolor=color.new(#131722, 5), border_color=color.new(#2A2E39, 0), border_width=1, frame_color=color.new(#363A45, 0), frame_width=2)

    // ── Header ────────────────────────────────────────────────────────────────
    table.cell(dash, 0, 0, "StrixEDGE",   text_color=color.white, text_size=size.small, bgcolor=color.new(#6A1B9A, 0), text_halign=text.align_left)
    table.cell(dash, 1, 0, "PERIOD",        text_color=#CE93D8,     text_size=size.tiny,  bgcolor=color.new(#6A1B9A, 0), text_halign=text.align_center)
    table.cell(dash, 2, 0, "PRESSURE",      text_color=color.white, text_size=size.tiny,  bgcolor=color.new(#6A1B9A, 0), text_halign=text.align_right)

    // ── Band readout rows ────────────────────────────────────────────────────
    color c1 = s1 > i_bullThr ? #00E676 : s1 < i_bearThr ? #FF5252 : #78909C
    color c2 = s2 > i_bullThr ? #00E676 : s2 < i_bearThr ? #FF5252 : #78909C
    color c3 = s3 > i_bullThr ? #00E676 : s3 < i_bearThr ? #FF5252 : #78909C
    color c4 = s4 > i_bullThr ? #00E676 : s4 < i_bearThr ? #FF5252 : #78909C
    color c5 = s5 > i_bullThr ? #00E676 : s5 < i_bearThr ? #FF5252 : #78909C
    color c6 = s6 > i_bullThr ? #00E676 : s6 < i_bearThr ? #FF5252 : #78909C
    color c7 = s7 > i_bullThr ? #00E676 : s7 < i_bearThr ? #FF5252 : #78909C
    color c8 = s8 > i_bullThr ? #00E676 : s8 < i_bearThr ? #FF5252 : #78909C

    string i1 = s1 > i_bullThr ? " ▲" : s1 < i_bearThr ? " ▼" : " ◆"
    string i2 = s2 > i_bullThr ? " ▲" : s2 < i_bearThr ? " ▼" : " ◆"
    string i3 = s3 > i_bullThr ? " ▲" : s3 < i_bearThr ? " ▼" : " ◆"
    string i4 = s4 > i_bullThr ? " ▲" : s4 < i_bearThr ? " ▼" : " ◆"
    string i5 = s5 > i_bullThr ? " ▲" : s5 < i_bearThr ? " ▼" : " ◆"
    string i6 = s6 > i_bullThr ? " ▲" : s6 < i_bearThr ? " ▼" : " ◆"
    string i7 = s7 > i_bullThr ? " ▲" : s7 < i_bearThr ? " ▼" : " ◆"
    string i8 = s8 > i_bullThr ? " ▲" : s8 < i_bearThr ? " ▼" : " ◆"

    table.cell(dash, 0, 1, "B1", text_color=#B0BEC5, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_left)
    table.cell(dash, 1, 1, "3",  text_color=#90A4AE, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_center)
    table.cell(dash, 2, 1, str.tostring(s1, "#.###") + i1, text_color=c1, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_right)

    table.cell(dash, 0, 2, "B2", text_color=#B0BEC5, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_left)
    table.cell(dash, 1, 2, "5",  text_color=#90A4AE, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_center)
    table.cell(dash, 2, 2, str.tostring(s2, "#.###") + i2, text_color=c2, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_right)

    table.cell(dash, 0, 3, "B3", text_color=#B0BEC5, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_left)
    table.cell(dash, 1, 3, "8",  text_color=#90A4AE, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_center)
    table.cell(dash, 2, 3, str.tostring(s3, "#.###") + i3, text_color=c3, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_right)

    table.cell(dash, 0, 4, "B4", text_color=#B0BEC5, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_left)
    table.cell(dash, 1, 4, "13", text_color=#90A4AE, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_center)
    table.cell(dash, 2, 4, str.tostring(s4, "#.###") + i4, text_color=c4, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_right)

    table.cell(dash, 0, 5, "B5", text_color=#B0BEC5, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_left)
    table.cell(dash, 1, 5, "21", text_color=#90A4AE, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_center)
    table.cell(dash, 2, 5, str.tostring(s5, "#.###") + i5, text_color=c5, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_right)

    table.cell(dash, 0, 6, "B6", text_color=#B0BEC5, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_left)
    table.cell(dash, 1, 6, "34", text_color=#90A4AE, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_center)
    table.cell(dash, 2, 6, str.tostring(s6, "#.###") + i6, text_color=c6, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_right)

    table.cell(dash, 0, 7, "B7", text_color=#B0BEC5, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_left)
    table.cell(dash, 1, 7, "55", text_color=#90A4AE, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_center)
    table.cell(dash, 2, 7, str.tostring(s7, "#.###") + i7, text_color=c7, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_right)

    table.cell(dash, 0, 8, "B8", text_color=#B0BEC5, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_left)
    table.cell(dash, 1, 8, "89", text_color=#90A4AE, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_center)
    table.cell(dash, 2, 8, str.tostring(s8, "#.###") + i8, text_color=c8, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_right)

    // ── Convergence row ───────────────────────────────────────────────────────
    int    activeConv = math.max(bullCount, bearCount)
    string convDir   = bullCount >= bearCount ? "BULL" : "BEAR"
    string convTxt   = str.tostring(activeConv) + " / 8  " + convDir
    color  convBG    = activeConv >= i_convMin ? (bullCount >= bearCount ? color.new(#1B5E20, 0) : color.new(#B71C1C, 0)) : color.new(#37474F, 0)
    color  convClr   = activeConv >= i_convMin ? color.white : #90A4AE

    table.cell(dash, 0, 9, "CONV.",  text_color=color.white, text_size=size.small, bgcolor=convBG, text_halign=text.align_left)
    table.cell(dash, 1, 9, convTxt,  text_color=convClr,     text_size=size.small, bgcolor=convBG, text_halign=text.align_center)
    table.cell(dash, 2, 9, activeConv >= i_convMin ? "🟢" : "⚪", text_color=color.white, text_size=size.small, bgcolor=convBG, text_halign=text.align_right)

    // ── Pulse row ─────────────────────────────────────────────────────────────
    string pulseTxt  = str.tostring(pulse, "#.###")
    color  pulseClr2 = pulse > 0.1 ? #00E676 : pulse < -0.1 ? #FF5252 : #78909C
    table.cell(dash, 0, 10, "PULSE",   text_color=#B0BEC5, text_size=size.tiny, bgcolor=color.new(#131722, 0), text_halign=text.align_left)
    table.cell(dash, 1, 10, pulseTxt,  text_color=pulseClr2, text_size=size.tiny, bgcolor=color.new(#131722, 0), text_halign=text.align_center)
    table.cell(dash, 2, 10, "",        text_color=#78909C,   text_size=size.tiny, bgcolor=color.new(#131722, 0))

    // ── Wave row ──────────────────────────────────────────────────────────────
    string waveTxt = waveBull ? "BULL FORMING" : waveBear ? "BEAR FORMING" : "NONE"
    color  waveClr = waveBull ? #FFD740 : waveBear ? #FFD740 : #546E7A
    table.cell(dash, 0, 11, "WAVE",    text_color=#B0BEC5, text_size=size.tiny, bgcolor=color.new(#131722, 0), text_halign=text.align_left)
    table.cell(dash, 1, 11, waveTxt,   text_color=waveClr, text_size=size.tiny, bgcolor=color.new(#131722, 0), text_halign=text.align_center)
    table.cell(dash, 2, 11, "",        text_color=#78909C, text_size=size.tiny, bgcolor=color.new(#131722, 0))


// ============================================================================
// ALERTS
// ============================================================================
alertcondition(buySignal,                "StrixPULSE — Buy Signal",   "StrixPULSE BUY: Spectrum convergence on {{ticker}} {{interval}}")
alertcondition(sellSignal,               "StrixPULSE — Sell Signal",  "StrixPULSE SELL: Spectrum convergence on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,  "StrixPULSE — Any Signal",   "StrixPULSE SIGNAL on {{ticker}} {{interval}}")
alertcondition(waveUpNew,                "StrixPULSE — Bull Wave",    "StrixPULSE: Bullish wave forming on {{ticker}} {{interval}}")
alertcondition(waveDownNew,              "StrixPULSE — Bear Wave",    "StrixPULSE: Bearish wave forming on {{ticker}} {{interval}}")
````
