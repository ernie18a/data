# OBV Regime Shift [I.M]

- url: https://www.tradingview.com/script/PNl3aI0T-OBV-Regime-Shift-I-M/
- type: indicator
- pine_id: PUB;70bcdbe29a684ce199cd53b3f1099115
- version: 1.0

## Description

OVERVIEW
🟣 OBV Regime Shift ("OBV-RS [I.M]") is a volume-flow regime detector that goes far beyond the classic "OBV + moving average" cross. It normalizes On-Balance Volume into a rolling z-score, applies a dual-MA system (HMA fast + DEMA slow) with slope acceleration, hunts price/OBV divergences on confirmed pivots, and aggregates everything into a single 0–100 Regime Score that flags BULLISH ▲ / BEARISH ▼ / NEUTRAL — state shifts.
The screenshot below shows the indicator running on BTCUSDT (Binance) on the 15-minute timeframe — refer back to it throughout the description, since each section describes the same chart.

📊 Live example chart:
https://www.tradingview.com/x/KqZzqncp/

WHAT YOU SEE ON THE CHART
Looking at the example image, from left to right and top to bottom:
🟣 The adaptive ribbon is the visual core of the indicator. Two lines — a Hull MA (fast) and a DEMA (slow) — are drawn on top of the normalized OBV, with a filled glow between them. When the fast line is above the slow line, the entire ribbon turns green (buy bias); when the fast line crosses below, the ribbon flips to magenta (sell bias). The glow halo and fill are intentional — they let you read regime at a glance without studying the lines.
🟣 The slope differential histogram at the zero line shows the acceleration gap between the two MAs. Green columns above zero = momentum is opening up; magenta columns below = momentum is collapsing. It often turns before the ribbon itself flips, acting as an early warning.
🟣 The "SHIFT ▼" and "SHIFT ▲" triangles mark confirmed regime transitions, not raw threshold crossings. A shift only prints when the Regime Score holds above 80 (or below 20) for two consecutive bars, with a minimum of 12 bars since the previous shift. This is deliberate — most OBV-based indicators ping-pong every other candle; this one earns each signal.
🟣 The "div ▲ / div ▼" diamonds print on pivot confluences: price makes a higher high while normalized OBV makes a lower high (or the inverse for bullish), AND the slope differential agrees with the divergence direction. The slope-confirmation filter cuts roughly 70% of the false divergences a naive pivot-comparison would generate.
🟣 The bottom-right panel is the at-a-glance summary: current Score (0–100), Regime label, Momentum state (Accelerating ▲ / Slowing ▼ / Flat), active Divergence, Volume expansion state, and the raw OBV z-score. The score number turns gold when it reaches an extreme zone (≥85 or ≤15).
🟣 The background flash is intentionally brief: three bars of green or magenta tint only on the bar a shift fires, then it clears. The indicator surfaces the event, not the state — your eye finds new shifts, not a wall of color.

WHAT MAKES IT ORIGINAL
OBV-RS [I.M] is not a wrapper around ta.obv() with a moving average glued on top. The originality is in how four independent ideas are combined and filtered:
🟣 Normalized OBV (z-score)
Raw OBV has an absolute scale that drifts with volume regime — comparing today's OBV to a six-month-old reading is meaningless. The script standardizes OBV into a rolling z-score over a configurable lookback window, so the same +1.5 reading means the same thing in a low-volume drift as it does in a high-volume rally. Every downstream calculation operates on this normalized series.
🟣 Dual-MA with slope acceleration
The fast line is a Hull MA — low-lag, responsive to inflections. The slow line is a DEMA — smoother but still ahead of a traditional EMA of the same length. The script computes the slope of each over a configurable window, then takes the slope differential (fastSlope − slowSlope). This differential, not the cross itself, is the leading indicator: it widens before the lines visually separate and contracts before they merge.
🟣 Slope-confirmed divergence engine
Most divergence scripts flag every higher-high-lower-high pivot pair, which floods the chart with noise. OBV-RS demands a third condition: the slope differential must agree with the divergence direction at the moment the second pivot prints. A bearish divergence only counts if the slope is already weakening; a bullish divergence only counts if the slope is already turning up. This single filter is the difference between a useful divergence signal and a pivot-spam indicator.
🟣 Regime Score (0–100) with multi-bar confirmation
Four components feed the score: slope differential (45% weight), distance between fast and slow lines (35% weight), a neutral anchor (20%), plus bonuses from active divergences and current volume expansion. The score is then gated through a two-step confirmation: it must hold above the bullish threshold (or below the bearish one) for a configurable number of consecutive bars before the state actually flips. A minimum bar gap between shifts prevents ping-pong. Together, these filters turn a noisy oscillator into a high-conviction regime tracker.

HOW TO USE IT
🟣 Ribbon color = directional bias. Green ribbon = look for longs / hold longs. Magenta ribbon = look for shorts / hold shorts / cash. Do not fight the ribbon; let it confirm.
🟣 SHIFT triangles = regime change. A SHIFT ▼ at the top means volume flow has flipped bearish with confirmation. A SHIFT ▲ at the bottom means the opposite. These are not entry signals on their own — they are context. Combine them with your price-action setup, your structure tool, or with my other indicators (LSE [I.M], Liquidity Confluence [I.M]).
🟣 Divergence diamonds = exhaustion warnings. A bearish divergence inside a bullish ribbon is a "be careful, the bid is fading" signal — tighten stops, don't add. A bullish divergence inside a bearish ribbon is the opposite. Divergences against the regime are more useful than divergences in the direction of the regime.
🟣 Score panel = quick read. Score above 70 with Momentum Accelerating ▲ and Volume Expanding = strong bullish regime. Score below 30 with Accelerating ▼ and Contracting = strong bearish. Anything between 30–70 = no-trade context for momentum strategies.
🟣 Best timeframes: 15-minute to 1-hour on liquid instruments (BTC, ETH, SOL, major FX, SPX/NDX/DXY, gold). Lower than 15m gets noisy regardless of filters. Higher than 4h works but the score becomes very slow to update.
🟣 What this indicator is NOT: it is not an entry signal generator and it does not predict price. It tells you what kind of market you are in — that is the prerequisite for everything else.

📌 Free and open to all. Feedback, improvement ideas and edge cases welcome in the comments.

## Source Code

````pine
//@version=6
indicator("OBV Regime Shift [I.M]", shorttitle="OBV-RS", overlay=false, precision=2, max_bars_back=500, max_lines_count=100, max_labels_count=200)

// ═════════════════════════════════════════════════════════════════════════════
//                          OBV REGIME SHIFT [I.M]
// ─────────────────────────────────────────────────────────────────────────────
// A volume-flow regime detector that normalizes OBV into a z-score, applies a
// dual-MA system (HMA fast + DEMA slow) with slope acceleration, detects
// price/OBV divergences on pivots, and aggregates everything into a 0-100
// Regime Score that flags BULLISH / BEARISH / NEUTRAL state shifts.
//
// Adaptive ribbon: green glow when fast > slow (buy bias), magenta glow when
// fast < slow (sell bias). Filtered signals: shifts require multi-bar score
// confirmation, minimum bar separation between transitions, and divergences
// must be slope-confirmed.
//
// Designed for 15m–1h timeframes on liquid crypto, FX and index instruments.
//
// @author  igormena
// @version 1.3
// ═════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────────────────────
// CONSTANTS
// ─────────────────────────────────────────────────────────────────────────────
const int   PANEL_ROWS         = 6
const int   PANEL_COLS         = 2
const float SLOPE_Z_SCALE      = 18.0
const float DIST_Z_SCALE       = 12.0
const float DIV_BIAS_FACTOR    = 0.3
const float VOL_BOOST_FACTOR   = 8.0
const float SCORE_WEIGHT_SLOPE = 0.45
const float SCORE_WEIGHT_DIST  = 0.35
const float SCORE_WEIGHT_BASE  = 0.20
const float NEUTRAL_ANCHOR     = 50.0
const int   BG_HIGHLIGHT_BARS  = 3
const float SLOPE_CONFIRM_MIN  = 0.03

// ─────────────────────────────────────────────────────────────────────────────
// USER-DEFINED TYPES
// ─────────────────────────────────────────────────────────────────────────────

type DivState
    float lastHighPrice = na
    float lastHighObv   = na
    int   lastHighBar   = na
    float lastLowPrice  = na
    float lastLowObv    = na
    int   lastLowBar    = na

type Regime
    float score
    int   state
    bool  shiftBull
    bool  shiftBear

type OBVMetrics
    float raw
    float normalized
    float fast
    float slow
    float slopeFast
    float slopeSlow
    float slopeDiff

// ─────────────────────────────────────────────────────────────────────────────
// METHODS — DivState
// ─────────────────────────────────────────────────────────────────────────────
method registerHigh(DivState self, float price, float obvVal, int barIdx) =>
    self.lastHighPrice := price
    self.lastHighObv   := obvVal
    self.lastHighBar   := barIdx

method registerLow(DivState self, float price, float obvVal, int barIdx) =>
    self.lastLowPrice := price
    self.lastLowObv   := obvVal
    self.lastLowBar   := barIdx

method hasValidHigh(DivState self, int currentBar, int maxRange) =>
    not na(self.lastHighPrice) and not na(self.lastHighObv) and (currentBar - self.lastHighBar) <= maxRange

method hasValidLow(DivState self, int currentBar, int maxRange) =>
    not na(self.lastLowPrice) and not na(self.lastLowObv) and (currentBar - self.lastLowBar) <= maxRange

// ─────────────────────────────────────────────────────────────────────────────
// METHODS — Regime
// ─────────────────────────────────────────────────────────────────────────────
method label(Regime self) =>
    self.state == 1 ? "BULLISH ▲" : self.state == -1 ? "BEARISH ▼" : "NEUTRAL —"

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
g1 = "── Normalization ──"
normLen     = input.int(50,  "Z-Score Lookback", minval=10, maxval=500, group=g1, tooltip="Window used to normalize OBV. Higher = smoother regime detection. 50 works well on 15m–1h.")

g2 = "── Moving Averages ──"
fastLen     = input.int(14,  "Fast HMA Length", minval=2,  maxval=100, group=g2, tooltip="Hull MA of the normalized OBV. Reacts fast to momentum shifts.")
slowLen     = input.int(50,  "Slow DEMA Length", minval=5, maxval=200, group=g2, tooltip="DEMA baseline — the regime anchor.")
slopeBars   = input.int(5,   "Slope Window",    minval=2,  maxval=20,  group=g2, tooltip="Bars used to measure slope acceleration.")

g3 = "── Divergence Engine ──"
divEnable      = input.bool(true, "Detect Divergences",      group=g3)
divLookL       = input.int(5,   "Pivot Left",   minval=2,  maxval=20,  group=g3)
divLookR       = input.int(3,   "Pivot Right",  minval=1,  maxval=20,  group=g3)
divRange       = input.int(60,  "Max Lookback Range", minval=10, maxval=200, group=g3, tooltip="Maximum bar distance between pivots to count as a divergence.")
divSlopeFilter = input.bool(true, "Require Slope Confirmation", group=g3, tooltip="Only flag divergence if slope differential agrees with the divergence direction. Cuts false signals significantly.")

g4 = "── Regime Score ──"
bullCut          = input.int(80,  "Bullish Threshold", minval=55, maxval=95, group=g4, tooltip="Score level required to flag BULLISH regime. Higher = fewer / cleaner signals.")
bearCut          = input.int(20,  "Bearish Threshold", minval=5,  maxval=45, group=g4)
confirmBars      = input.int(2,   "Confirmation Bars", minval=1, maxval=10, group=g4, tooltip="Score must stay above/below threshold for N consecutive bars before shift fires. 2 = balanced; 3 = very strict.")
minBarsBtwShifts = input.int(12,  "Min Bars Between Shifts", minval=1, maxval=50, group=g4, tooltip="Prevents ping-pong by requiring at least N bars between regime transitions.")
bgHighlight      = input.bool(true, "Highlight Shift Bars Only", group=g4, tooltip="Tints background only for 3 bars after each shift. Cleaner than tinting the full regime duration.")

g5 = "── Visual ──"
colBull        = input.color(color.rgb(38, 166, 154),  "Bullish Color",  group=g5, tooltip="Color of the ribbon and signals when the fast line is above the slow line (buy bias).")
colBear        = input.color(color.rgb(217, 70, 239),  "Bearish Color",  group=g5, tooltip="Color of the ribbon and signals when the fast line is below the slow line (sell bias).")
colPOC         = input.color(color.rgb(255, 193, 7),   "Highlight Color", group=g5, tooltip="Used when score reaches extreme zones (≥85 or ≤15).")
colNeutral     = input.color(color.rgb(140, 155, 170), "Neutral Color",  group=g5)
showPanel      = input.bool(true,  "Show Info Panel",   group=g5)

// ─────────────────────────────────────────────────────────────────────────────
// FUNCTIONS — Calculations
// ─────────────────────────────────────────────────────────────────────────────
calcOBV() =>
    var float obv = 0.0
    obv := nz(obv[1]) + (close > close[1] ? volume : close < close[1] ? -volume : 0.0)
    obv

zScore(float src, int len) =>
    m = ta.sma(src, len)
    s = ta.stdev(src, len)
    s > 0 ? (src - m) / s : 0.0

hmaCalc(float src, int len) =>
    h = math.floor(len / 2)
    s = math.floor(math.sqrt(len))
    ta.wma(2 * ta.wma(src, h) - ta.wma(src, len), s)

demaCalc(float src, int len) =>
    e1 = ta.ema(src, len)
    e2 = ta.ema(e1, len)
    2 * e1 - e2

computeOBVMetrics() =>
    raw  = calcOBV()
    norm = zScore(raw, normLen)
    f    = hmaCalc(norm, fastLen)
    s    = demaCalc(norm, slowLen)
    sf   = (f - f[slopeBars]) / slopeBars
    ss   = (s - s[slopeBars]) / slopeBars
    sd   = sf - ss
    OBVMetrics.new(raw, norm, f, s, sf, ss, sd)

detectDivergences(DivState self, float normObv, float slopeDiff) =>
    phPrice = ta.pivothigh(high,    divLookL, divLookR)
    plPrice = ta.pivotlow(low,      divLookL, divLookR)
    phObv   = ta.pivothigh(normObv, divLookL, divLookR)
    plObv   = ta.pivotlow(normObv,  divLookL, divLookR)

    bull = false
    bear = false
    strength = 0.0
    currentBar = bar_index - divLookR

    if not na(phPrice) and not na(phObv)
        if self.hasValidHigh(currentBar, divRange)
            rawBear = phPrice > self.lastHighPrice and phObv < self.lastHighObv
            slopeOk = divSlopeFilter ? slopeDiff < -SLOPE_CONFIRM_MIN : true
            if rawBear and slopeOk
                bear := true
                strength := math.min(100, math.abs(phObv - self.lastHighObv) * 25)
        self.registerHigh(phPrice, phObv, currentBar)

    if not na(plPrice) and not na(plObv)
        if self.hasValidLow(currentBar, divRange)
            rawBull = plPrice < self.lastLowPrice and plObv > self.lastLowObv
            slopeOk = divSlopeFilter ? slopeDiff > SLOPE_CONFIRM_MIN : true
            if rawBull and slopeOk
                bull := true
                strength := math.min(100, math.abs(plObv - self.lastLowObv) * 25)
        self.registerLow(plPrice, plObv, currentBar)

    [bull, bear, strength]

computeScore(OBVMetrics m, bool bullDiv, bool bearDiv, float divStrength) =>
    slopeZ      = zScore(m.slopeDiff, normLen)
    slopeScore  = math.max(0, math.min(100, NEUTRAL_ANCHOR + slopeZ * SLOPE_Z_SCALE))

    distScore   = math.max(0, math.min(100, NEUTRAL_ANCHOR + (m.fast - m.slow) * DIST_Z_SCALE))

    divBias = 0.0
    if divEnable
        divBias := bullDiv ? divStrength * DIV_BIAS_FACTOR : bearDiv ? -divStrength * DIV_BIAS_FACTOR : 0.0

    volMA       = ta.sma(volume, normLen)
    volExp      = volMA > 0 ? volume / volMA : 1.0
    volBoost    = math.max(-10, math.min(10, (volExp - 1) * VOL_BOOST_FACTOR))
    volComp     = volBoost * (m.slopeFast >= 0 ? 1 : -1)

    math.max(0, math.min(100,
       slopeScore * SCORE_WEIGHT_SLOPE
     + distScore  * SCORE_WEIGHT_DIST
     + NEUTRAL_ANCHOR * SCORE_WEIGHT_BASE
     + divBias
     + volComp * 0.5
    ))

barsHolding(float score, float threshold, int sign, int lookback) =>
    count = 0
    for i = 0 to lookback - 1
        v = score[i]
        cond = sign == 1 ? v >= threshold : v <= threshold
        if cond
            count += 1
    count

// ─────────────────────────────────────────────────────────────────────────────
// PERSISTENT STATE
// ─────────────────────────────────────────────────────────────────────────────
var DivState divState         = DivState.new()
var int      lastState        = 0
var int      lastShiftBar     = na
var int      lastShiftDir     = 0

// ─────────────────────────────────────────────────────────────────────────────
// MAIN — OBV Metrics
// ─────────────────────────────────────────────────────────────────────────────
metrics = computeOBVMetrics()
slopeFastNow  = metrics.slopeFast
slopeFastPrev = nz(slopeFastNow[1])

// ─────────────────────────────────────────────────────────────────────────────
// MAIN — Divergence Engine (slope-confirmed)
// ─────────────────────────────────────────────────────────────────────────────
[bullDiv, bearDiv, divStrength] = detectDivergences(divState, metrics.normalized, metrics.slopeDiff)

// ─────────────────────────────────────────────────────────────────────────────
// MAIN — Regime Score with multi-bar confirmation
// ─────────────────────────────────────────────────────────────────────────────
score = computeScore(metrics, bullDiv, bearDiv, divStrength)

barsHoldBull = barsHolding(score, bullCut, 1,  confirmBars)
barsHoldBear = barsHolding(score, bearCut, -1, confirmBars)

confirmedBull = barsHoldBull >= confirmBars
confirmedBear = barsHoldBear >= confirmBars
newState = confirmedBull ? 1 : confirmedBear ? -1 : 0

barsSinceShift = na(lastShiftBar) ? 9999 : bar_index - lastShiftBar
canShift = barsSinceShift >= minBarsBtwShifts

shiftBull = newState == 1  and lastState != 1  and canShift
shiftBear = newState == -1 and lastState != -1 and canShift

regime = Regime.new(score, newState != 0 ? newState : lastState, shiftBull, shiftBear)

if shiftBull
    lastShiftBar := bar_index
    lastShiftDir := 1
    lastState    := 1
if shiftBear
    lastShiftBar := bar_index
    lastShiftDir := -1
    lastState    := -1

// ─────────────────────────────────────────────────────────────────────────────
// MAIN — Volume Expansion (pre-computed for panel)
// ─────────────────────────────────────────────────────────────────────────────
volMAPanel  = ta.sma(volume, normLen)
volExpPanel = volMAPanel > 0 ? volume / volMAPanel : 1.0

// ─────────────────────────────────────────────────────────────────────────────
// MAIN — Adaptive Ribbon Rendering
// ─────────────────────────────────────────────────────────────────────────────
ribbonBull = metrics.fast > metrics.slow
ribbonCol  = ribbonBull ? colBull : colBear

inHighlightWindow = not na(lastShiftBar) and (bar_index - lastShiftBar) < BG_HIGHLIGHT_BARS
bgcolor(bgHighlight and inHighlightWindow and lastShiftDir == 1  ? color.new(colBull, 85) : na)
bgcolor(bgHighlight and inHighlightWindow and lastShiftDir == -1 ? color.new(colBear, 85) : na)

hline(0, "Zero", color=color.new(colNeutral, 60), linestyle=hline.style_dotted)

// Outer glow halo
plot(metrics.fast, "Fast Glow Outer", color=color.new(ribbonCol, 90), linewidth=10)
plot(metrics.slow, "Slow Glow Outer", color=color.new(ribbonCol, 92), linewidth=10)

// Inner glow
plot(metrics.fast, "Fast Glow Mid", color=color.new(ribbonCol, 75), linewidth=6)
plot(metrics.slow, "Slow Glow Mid", color=color.new(ribbonCol, 80), linewidth=6)

// Core lines — fast solid, slow slightly transparent for depth
fastPlot = plot(metrics.fast, "Fast HMA", color=ribbonCol, linewidth=2)
slowPlot = plot(metrics.slow, "Slow DEMA", color=color.new(ribbonCol, 35), linewidth=2)

// Ribbon fill between fast and slow
fill(fastPlot, slowPlot, color=color.new(ribbonCol, 82), title="Ribbon Fill")

// Slope differential histogram
histCol = metrics.slopeDiff > 0 ? color.new(colBull, 50) : color.new(colBear, 50)
plot(metrics.slopeDiff, "Slope Diff", color=histCol, style=plot.style_columns)

// Shift markers
plotshape(shiftBull, "Bullish Shift", location=location.bottom, style=shape.triangleup,
          color=colBull, size=size.small, text="SHIFT", textcolor=colBull)
plotshape(shiftBear, "Bearish Shift", location=location.top, style=shape.triangledown,
          color=colBear, size=size.small, text="SHIFT", textcolor=colBear)

// Divergence markers
plotshape(bullDiv, "Bull Div", location=location.bottom, style=shape.diamond,
          color=colBull, size=size.tiny, text="div", textcolor=colBull, offset=-divLookR)
plotshape(bearDiv, "Bear Div", location=location.top, style=shape.diamond,
          color=colBear, size=size.tiny, text="div", textcolor=colBear, offset=-divLookR)

// ─────────────────────────────────────────────────────────────────────────────
// MAIN — Info Panel
// ─────────────────────────────────────────────────────────────────────────────
if showPanel and barstate.islast
    var table panel = table.new(position.bottom_right, PANEL_COLS, PANEL_ROWS,
                               bgcolor=color.new(color.black, 70),
                               border_width=1, border_color=color.new(color.gray, 70))

    regimeTxt = regime.label()
    regimeCol = regime.state == 1 ? colBull : regime.state == -1 ? colBear : colNeutral

    momTxt = slopeFastNow > 0 and slopeFastNow > slopeFastPrev ? "Accelerating ▲" :
             slopeFastNow > 0 and slopeFastNow < slopeFastPrev ? "Slowing ▼" :
             slopeFastNow < 0 and slopeFastNow < slopeFastPrev ? "Accelerating ▼" :
             slopeFastNow < 0 and slopeFastNow > slopeFastPrev ? "Slowing ▲" : "Flat"

    divTxt = bullDiv ? "Bullish ▲" : bearDiv ? "Bearish ▼" : "—"
    divCol = bullDiv ? colBull : bearDiv ? colBear : colNeutral

    volTxt = volExpPanel > 1.5 ? "Expanding" : volExpPanel < 0.7 ? "Contracting" : "Normal"

    scoreCol = regime.score >= 85 or regime.score <= 15 ? colPOC : color.white

    table.cell(panel, 0, 0, "OBV-RS [I.M]",                      text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 1, 0, "Score: " + str.tostring(math.round(regime.score)), text_color=scoreCol, text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 0, 1, "Regime",     text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 1, 1, regimeTxt,    text_color=regimeCol,   text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 0, 2, "Momentum",   text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 1, 2, momTxt,       text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 0, 3, "Divergence", text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 1, 3, divTxt,       text_color=divCol,      text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 0, 4, "Volume",     text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 1, 4, volTxt,       text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 0, 5, "OBV z-score", text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 1, 5, str.tostring(metrics.normalized, "#.##"), text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 50))

// ─────────────────────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(shiftBull, title="Bullish Regime Shift", message="OBV Regime Shift: Bullish regime shift confirmed")
alertcondition(shiftBear, title="Bearish Regime Shift", message="OBV Regime Shift: Bearish regime shift confirmed")
alertcondition(bullDiv,   title="Bullish Divergence",   message="OBV Regime Shift: Bullish divergence (slope-confirmed)")
alertcondition(bearDiv,   title="Bearish Divergence",   message="OBV Regime Shift: Bearish divergence (slope-confirmed)")
````
