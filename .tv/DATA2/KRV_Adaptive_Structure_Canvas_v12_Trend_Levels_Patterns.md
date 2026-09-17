<!-- tradingview-pine-id: PUB;b865276b3c3c447bb8fe43a7c44ac060 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# KRV Adaptive Structure Canvas v1.2 — Trend / Levels / Patterns

Source: https://www.tradingview.com/script/OYcfgrPs-KRV-Adaptive-Structure-Canvas-v1-2-Trend-Levels-Patterns/

## Description

Know the trend. Know where it breaks. Know what comes next.

KRV Adaptive Structure Canvas v1.2 is a visual market-structure framework designed to organize trend, structural invalidation, higher-timeframe support and resistance, pattern confirmation, and post-break price objectives on a single chart.

Rather than covering the chart with multiple moving averages, pivots, trendlines, and repeated pattern labels, KRV Structure compresses those functions into one adaptive structural map.

It is not designed as a standalone buy/sell signal system.

Instead, it is built to answer five practical questions:

1. What is the dominant structure?
2. Where does that structure fail?
3. Where is the nearest meaningful support or resistance?
4. Is a recognizable pattern merely forming, or has it actually confirmed?
5. If a key level breaks, what is the next structural objective?

1. ADAPTIVE TREND CHANNEL

The shaded channel represents the current directional structure.

Its basis uses an adaptive KAMA framework, while channel width adjusts using ATR and trend efficiency. In lower-efficiency conditions, the channel expands so ordinary market noise is less likely to trigger unnecessary structural changes.

Green = bullish structure
Red = bearish structure
Neutral = insufficient directional structure

The goal is not to predict every candle.

The goal is to answer a more useful question:

“Is the current trend structure still intact?”

2. BREAK RAIL

The Break Rail is the script’s primary structural invalidation reference.

During bullish structure, the dashboard may display:

UPTREND BREAK BELOW [price]

During bearish structure:

DOWNTREND BREAK ABOVE [price]

This creates an explicit failure boundary for the active trend instead of relying entirely on subjective visual interpretation.

By default, structural breaks require confirmation rather than reacting to a single touch of the rail.

Think of the Break Rail as the level the current structure should not lose if the trend is going to remain intact.

3. MULTI-HORIZON SUPPORT AND RESISTANCE

KRV Structure automatically maps the nearest relevant support and resistance zones using completed higher-timeframe price data.

Potential sources include:

D1 — Previous daily level
2D — Two-day level
3D — Three-day level
W — Weekly level
M — Monthly level
Y — Yearly level

Only the nearest zones are emphasized by default, which keeps the chart focused rather than filling it with distant horizontal levels.

For example:

3D RES 79,461 | D1 SUP 75,568

means the nearest resistance is derived from the three-day structure, while the nearest support comes from the prior daily structure.

These levels are displayed as zones, not as false-precision single-price predictions.

4. STRUCTURAL PATTERN ENGINE

The script also monitors several common structural formations:

• Bull Flag
• Cup + Handle
• Ascending Wedge
• Descending Wedge
• Head & Shoulders
• Inverse Head & Shoulders

The important distinction is that KRV Structure separates pattern candidates from confirmed pattern breaks.

A recognizable shape alone is not enough.

Patterns must persist long enough to satisfy a maturity requirement, and confirmed events require price to break the relevant flag range, handle, wedge boundary, or neckline.

The engine also uses cooldown periods and pattern-instance tracking to reduce repeated signals from effectively the same formation.

The objective is selective structural recognition, not constant pattern labeling.

5. BREAKOUT PRICE-TARGET LADDER

When price confirms a break through the nearest support or resistance zone, the script can activate a projected:

PT1
PT2

ladder.

PT1 prioritizes the next available structural level when one exists. When an appropriate structural level is unavailable, ATR-based extensions provide fallback reference objectives.

This creates a simple progression:

Structure → Decision Zone → Confirmed Break → Next Objective

PT1 and PT2 are reference levels, not guaranteed price forecasts.

READING THE STRUCTURE BADGE

The upper-left badge is designed to summarize the active market structure in a few seconds.

TREND

Displays the current directional structure:

BULLISH STRUCTURE
BEARISH STRUCTURE
BULLISH / BEARISH FORMING
NEUTRAL / RANGE

BREAK RAIL

Displays the current structural failure boundary.

NEAREST

Shows the closest relevant resistance and support zones.

PATTERN

Shows the highest-priority active pattern candidate or confirmed pattern event.

LAST EVENT

Records the most recent significant structural event and its exchange time.

The chart intentionally limits excessive event stamps, so the badge helps preserve important structural information without adding unnecessary visual clutter.

HOW TO USE KRV STRUCTURE

A simple workflow is:

1. Start with TREND.

Determine whether the dominant structure is bullish, bearish, or neutral.

2. Read the BREAK RAIL.

Identify where the current structural thesis would begin to fail.

3. Locate the NEAREST support and resistance zones.

These define the next important decision areas.

4. Observe price behavior at those zones.

A rejection, acceptance, or confirmed break is more informative than price merely touching a level.

5. Use PATTERN information as supporting structural context.

A pattern label identifies a qualifying formation. A confirmed BREAK means that the script’s objective boundary condition has also been satisfied.

6. After a confirmed zone break, inspect PT1 and PT2.

These provide the next structural reference points after the breakout or breakdown.

PRACTICAL EXAMPLE

Suppose the dashboard reads:

TREND: BULLISH STRUCTURE
BREAK RAIL: UPTREND BREAK BELOW 76,894
NEAREST: 3D RES 79,461 | D1 SUP 75,568

That does not mean:

“Buy.”

It means:

• The dominant structure remains bullish.
• 76,894 is the current structural failure rail.
• Price is approaching resistance derived from the three-day structure.
• The nearest daily support is 75,568.
• A confirmed resistance break may activate the next PT ladder.

The indicator is therefore providing a map:

Trend → Failure Boundary → Decision Zone → Confirmation → Next Objective

CLEAN MODE VS. RESEARCH MODE

Clean Mode is designed for normal chart use.

It emphasizes the adaptive channel, Break Rail, nearest support and resistance zones, active target ladder, and selective structural events.

Research Mode can additionally display active pattern guide lines for users who want to inspect how structural formations are developing.

ALERTS

KRV Structure includes alert conditions for key structural events, including:

• Uptrend breaks
• Downtrend breaks
• Resistance breaks
• Support breaks
• Bull Flag breaks
• Cup + Handle breaks
• Head & Shoulders breaks
• Ascending Wedge breaks

This allows the chart to remain visually clean while important structural changes can still be monitored.

RECOMMENDED USE

The script is designed primarily for higher-order structure analysis and is best suited to:

Daily / 4H / 1H

Lower timeframes can also be used for tactical timing when appropriate.

The default visual philosophy is intentionally simple:

One primary trend structure.
One failure boundary.
The nearest important levels.
Selective pattern events.
A continuation map when structure breaks.

WHAT KRV STRUCTURE IS NOT

KRV Adaptive Structure Canvas is not intended to predict every reversal, identify guaranteed chart patterns, or generate standalone entry signals.

Its purpose is to make the structural questions surrounding a trade easier to answer:

What is the trend?
Where does it fail?
Where is the next decision zone?
Has the setup actually confirmed?
If price breaks that zone, what comes next?

Less chart clutter. More structural information.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Cheeseboard1991
// KRV Adaptive Structure Canvas v1.2
// by Cheeseboard1991

//@version=6
indicator("KRV Adaptive Structure Canvas v1.2 — Trend / Levels / Patterns", shorttitle="KRV STRUCTURE", overlay=true, max_labels_count=150, max_lines_count=120, max_boxes_count=20, max_bars_back=5000, calc_bars_count=5000)
// =================================================================================================
// KRV ADAPTIVE STRUCTURE CANVAS v1.2
// -------------------------------------------------------------------------------------------------
// v1.2 EVENT ENGINE
//   - v1.1's per-bar edge latch was insufficient: the pivot-based detectors re-arm every time a
//     new pivot redraws the same shape, so every re-arm produced a fresh "edge" and labels still
//     clustered. v1.2 latches per INSTANCE instead:
//       MATURITY  - a candidate must hold N consecutive bars before its break can register.
//       COOLDOWN  - after a break, that pattern type is silent for M bars.
//       IDENTITY  - wedge breaks require a wedge that STARTED after the prior break; H&S breaks
//                   require a new head pivot.
//   - Pattern-break stamps also respect the shared label spacing gap, so different pattern types
//     can no longer cluster back-to-back. Alerts and badge always record the event even when the
//     chart stamp is spaced out.
//   - Optional max-distance filter hides S/R zones far from price.
//
// v1.1 CLARITY PASS
//   - One prioritized structural label per bar (trend break > shift > pattern break > candidate).
//   - "LAST EVENT" badge row (event + exchange time) preserves history off-chart.
//
// PURPOSE
// A clean visual companion for swing / structure reading on equities. It is NOT an execution-arrow
// tool. It owns the higher-order visual job:
//   1) Adaptive trend channel + explicit break rail.
//   2) Nearest multi-horizon S/R zones: D1, 2D, 3D, W, M, Y.
//   3) Breakout Price Target (PT) ladder when a resistance/support zone is confirmed broken.
//   4) Selective structural pattern candidates and confirmed breaks (heuristic, objective boundary).
//
// DESIGN PRINCIPLES
// - One primary channel, not a rainbow of MAs.
// - Only the two nearest resistance and support zones are rendered by default.
// - Pattern labels are objective heuristics: candidate first, confirmed only after boundary break.
// - One structural label per bar, ever. Reversals loud, candidates quiet.
// =================================================================================================

// =================================================================================================
// 1. CANVAS MODE / GOVERNANCE
// =================================================================================================
string G_SYSTEM = "1. Canvas Mode / Governance"
i_canvasMode = input.string("Clean", "Visual Mode", options=["Clean", "Research"], group=G_SYSTEM, tooltip="Clean keeps only the core channel, break rail, nearest zones, active PT ladder, and selective pattern stamps. Research adds pattern guide lines.")
i_confirmedOnly = input.bool(true, "Confirm Trend / Break Labels on Bar Close", group=G_SYSTEM)
i_structureTfHint = input.string("Daily / 4H / 1H", "Recommended Chart Use", options=["Daily / 4H / 1H", "1H / 30m", "15m / 5m"], group=G_SYSTEM, tooltip="Informational only. For equity swing structure this canvas reads best on Daily/4H/1H; drop to intraday only for tactical timing.")
i_showPanel = input.bool(true, "Show Structure Badge", group=G_SYSTEM)
i_showBreakLabels = input.bool(true, "Show Trend-Break Labels", group=G_SYSTEM)
i_colorCandles = input.bool(false, "Subtly Color Candles by Structure", group=G_SYSTEM)

// =================================================================================================
// 2. ADAPTIVE TREND CHANNEL
// =================================================================================================
string G_CHANNEL = "2. Adaptive Trend Channel"
i_kamaLen = input.int(34, "Adaptive Basis KAMA Length", minval=5, group=G_CHANNEL)
i_erLen = input.int(20, "Trend Efficiency Length", minval=5, group=G_CHANNEL)
i_atrLen = input.int(21, "Channel ATR Length", minval=5, group=G_CHANNEL)
i_slopeBars = input.int(5, "KAMA Slope Lookback", minval=1, maxval=50, group=G_CHANNEL)
i_minER = input.float(0.24, "Minimum Trend Efficiency", minval=0.05, maxval=0.95, step=0.01, group=G_CHANNEL)
i_minSlopeATR = input.float(0.07, "Minimum KAMA Slope (ATR)", minval=0.01, maxval=1.00, step=0.01, group=G_CHANNEL)
i_baseWidthATR = input.float(1.05, "Base Channel Width (ATR)", minval=0.25, maxval=5.00, step=0.05, group=G_CHANNEL)
i_noiseExpansion = input.float(0.65, "Noise Expansion Add-On", minval=0.00, maxval=3.00, step=0.05, group=G_CHANNEL, tooltip="Expands the channel in lower-efficiency conditions so the break rail does not flip from ordinary noise.")
i_breakBars = input.int(2, "Trend Break Confirmation Bars", minval=1, maxval=5, group=G_CHANNEL)
i_showChannel = input.bool(true, "Show Shaded Trend Channel", group=G_CHANNEL)
i_showBreakRail = input.bool(true, "Show Trend Break Rail", group=G_CHANNEL)
i_showShiftLabels = input.bool(true, "Show Structure Shift Labels", group=G_CHANNEL)

// =================================================================================================
// 3. MULTI-HORIZON SUPPORT / RESISTANCE ZONES
// =================================================================================================
string G_SR = "3. Multi-Horizon Support / Resistance"
i_showSR = input.bool(true, "Show Nearest S/R Zones", group=G_SR)
i_srDepth = input.int(2, "Zones Per Side", minval=1, maxval=2, group=G_SR)
i_dailyAtrLen = input.int(14, "Daily ATR Length for Zone Width", minval=5, group=G_SR)
i_zoneHalfWidthATR = input.float(0.085, "Zone Half-Width (Daily ATR)", minval=0.01, maxval=0.50, step=0.005, group=G_SR)
i_zoneLookbackBars = input.int(90, "Zone Left Span Bars", minval=20, maxval=1000, group=G_SR)
i_zoneProjectionBars = input.int(90, "Zone Right Projection Bars", minval=20, maxval=1000, group=G_SR)
i_zoneMaxDistanceATR = input.float(2.5, "Max Zone Distance (Daily ATR)", minval=0.5, maxval=20.0, step=0.5, group=G_SR, tooltip="Zones farther than this many daily ATRs from current price are not drawn. Keeps distant monthly/yearly levels from dominating the canvas until price actually approaches them.")
i_showZoneLabels = input.bool(true, "Show Zone Labels", group=G_SR)
i_showBreakTargets = input.bool(true, "Show PT Ladder After Break", group=G_SR)
i_ptFallbackATR1 = input.float(0.75, "PT1 Fallback (Daily ATR)", minval=0.10, maxval=5.00, step=0.05, group=G_SR)
i_ptFallbackATR2 = input.float(1.50, "PT2 Fallback (Daily ATR)", minval=0.20, maxval=10.00, step=0.05, group=G_SR)
i_ptProjectionBars = input.int(120, "PT Projection Bars", minval=20, maxval=1000, group=G_SR)

// =================================================================================================
// 4. STRUCTURAL PATTERN ENGINE
// =================================================================================================
string G_PATTERN = "4. Structural Pattern Engine"
i_patternMode = input.string("Confirmed Only", "Pattern Labels", options=["Off", "Confirmed Only", "Candidates + Confirmed"], group=G_PATTERN, tooltip="Patterns are heuristic structure classifications, not guaranteed outcomes. Confirmed labels require the stated neckline, flag, handle, or wedge boundary to break.")
i_minLabelGap = input.int(6, "Minimum Bars Between Pattern Stamps", minval=0, maxval=60, group=G_PATTERN, tooltip="Shared spacing governor for pattern labels (candidates AND confirmed breaks) so stamps never cluster. Trend rail breaks and structure shifts always print. A break suppressed by spacing still fires its alert and updates the LAST EVENT badge row.")
i_patternMaturityBars = input.int(4, "Pattern Maturity Bars", minval=1, maxval=30, group=G_PATTERN, tooltip="A candidate must hold this many consecutive bars before its break can register. Filters out shapes that form off a fresh pivot and break instantly - the main source of junk break labels.")
i_breakCooldownBars = input.int(20, "Bars Between Same-Pattern Breaks", minval=0, maxval=200, group=G_PATTERN, tooltip="After a confirmed break of a given pattern type, that type stays silent this many bars. Wedge breaks additionally require a wedge formed AFTER the prior break; H&S breaks require a new head pivot.")
i_showPatternGuides = input.bool(false, "Show Active Pattern Guide Lines", group=G_PATTERN)
i_pivotLeft = input.int(3, "Pivot Left Bars", minval=2, maxval=20, group=G_PATTERN)
i_pivotRight = input.int(3, "Pivot Right Bars", minval=2, maxval=20, group=G_PATTERN)
i_wedgeMaxBars = input.int(55, "Maximum Wedge Age", minval=10, maxval=250, group=G_PATTERN)
i_wedgeTightness = input.float(0.80, "Wedge Compression Requirement", minval=0.25, maxval=0.98, step=0.01, group=G_PATTERN)
i_shoulderToleranceATR = input.float(0.55, "H&S Shoulder Similarity (ATR)", minval=0.10, maxval=3.00, step=0.05, group=G_PATTERN)
i_headDominanceATR = input.float(0.65, "H&S Head Dominance (ATR)", minval=0.10, maxval=5.00, step=0.05, group=G_PATTERN)
i_flagPoleBars = input.int(12, "Bull Flag Pole Lookback", minval=5, maxval=100, group=G_PATTERN)
i_flagBars = input.int(6, "Bull Flag Pullback Bars", minval=3, maxval=30, group=G_PATTERN)
i_flagPoleATR = input.float(2.00, "Bull Flag Minimum Pole (ATR)", minval=0.50, maxval=10.00, step=0.10, group=G_PATTERN)
i_flagMaxRetrace = input.float(0.45, "Bull Flag Maximum Retrace", minval=0.10, maxval=0.90, step=0.05, group=G_PATTERN)
i_cupLookback = input.int(30, "Cup Lookback Bars", minval=12, maxval=200, group=G_PATTERN)
i_handleBars = input.int(6, "Handle Bars", minval=3, maxval=30, group=G_PATTERN)
i_cupMinDepthATR = input.float(2.00, "Cup Minimum Depth (ATR)", minval=0.50, maxval=15.00, step=0.10, group=G_PATTERN)
i_cupRimTolerance = input.float(0.22, "Cup Rim Recovery Tolerance", minval=0.05, maxval=0.60, step=0.01, group=G_PATTERN)
i_handleMaxDepth = input.float(0.42, "Maximum Handle Depth of Cup", minval=0.10, maxval=0.80, step=0.02, group=G_PATTERN)

// =================================================================================================
// 5. VISUAL PALETTE
// =================================================================================================
const color C_BULL = color.rgb(64, 224, 151)
const color C_BEAR = color.rgb(255, 96, 104)
const color C_INFO = color.rgb(74, 184, 255)
const color C_WARN = color.rgb(250, 191, 52)
const color C_NEUTRAL = color.rgb(148, 163, 184)
const color C_PANEL = color.rgb(15, 23, 42)
const color C_PURPLE = color.rgb(194, 120, 255)
const color C_DARK = color.rgb(31, 41, 55)

// =================================================================================================
// 6. UTILITY FUNCTIONS
// =================================================================================================
f_clamp(float _x, float _lo, float _hi) =>
    math.max(_lo, math.min(_x, _hi))

f_roundTick(float _price) =>
    math.round(_price / syminfo.mintick) * syminfo.mintick

f_efficiency(float _src, int _len) =>
    float _net = math.abs(_src - _src[_len])
    float _noise = ta.sma(math.abs(ta.change(_src)), _len) * _len
    _noise > 0 ? _net / _noise : 0.0

// Custom Kaufman Adaptive Moving Average. Pine has no native ta.kama().
f_kama(float _src, int _erLen, int _fastLen, int _slowLen) =>
    float _change = math.abs(_src - _src[_erLen])
    float _volatility = ta.sma(math.abs(ta.change(_src)), _erLen) * _erLen
    float _er = _volatility > 0 ? _change / _volatility : 0.0
    float _fastSC = 2.0 / (_fastLen + 1.0)
    float _slowSC = 2.0 / (_slowLen + 1.0)
    float _smooth = math.pow(_er * (_fastSC - _slowSC) + _slowSC, 2.0)
    float _kama = na
    _kama := na(_kama[1]) ? _src : _kama[1] + _smooth * (_src - _kama[1])
    _kama

f_project(int _x1, float _y1, int _x2, float _y2, int _xNow) =>
    not na(_x1) and not na(_x2) and _x2 != _x1 ? _y2 + ((_y2 - _y1) / float(_x2 - _x1)) * float(_xNow - _x2) : na

f_levelName(int _idx) =>
    _idx == 1 ? "D1" : _idx == 2 ? "2D" : _idx == 3 ? "3D" : _idx == 4 ? "W" : _idx == 5 ? "M" : _idx == 6 ? "Y" : "—"

f_pickAbove(float _price, float _a, float _b, float _c, float _d, float _e, float _f, float _exclude, float _tol) =>
    float _best = na
    int _idx = 0
    if not na(_a) and _a > _price + _tol and (na(_exclude) or math.abs(_a - _exclude) > _tol)
        _best := _a
        _idx := 1
    if not na(_b) and _b > _price + _tol and (na(_exclude) or math.abs(_b - _exclude) > _tol) and (na(_best) or _b < _best)
        _best := _b
        _idx := 2
    if not na(_c) and _c > _price + _tol and (na(_exclude) or math.abs(_c - _exclude) > _tol) and (na(_best) or _c < _best)
        _best := _c
        _idx := 3
    if not na(_d) and _d > _price + _tol and (na(_exclude) or math.abs(_d - _exclude) > _tol) and (na(_best) or _d < _best)
        _best := _d
        _idx := 4
    if not na(_e) and _e > _price + _tol and (na(_exclude) or math.abs(_e - _exclude) > _tol) and (na(_best) or _e < _best)
        _best := _e
        _idx := 5
    if not na(_f) and _f > _price + _tol and (na(_exclude) or math.abs(_f - _exclude) > _tol) and (na(_best) or _f < _best)
        _best := _f
        _idx := 6
    [_best, _idx]

f_pickBelow(float _price, float _a, float _b, float _c, float _d, float _e, float _f, float _exclude, float _tol) =>
    float _best = na
    int _idx = 0
    if not na(_a) and _a < _price - _tol and (na(_exclude) or math.abs(_a - _exclude) > _tol)
        _best := _a
        _idx := 1
    if not na(_b) and _b < _price - _tol and (na(_exclude) or math.abs(_b - _exclude) > _tol) and (na(_best) or _b > _best)
        _best := _b
        _idx := 2
    if not na(_c) and _c < _price - _tol and (na(_exclude) or math.abs(_c - _exclude) > _tol) and (na(_best) or _c > _best)
        _best := _c
        _idx := 3
    if not na(_d) and _d < _price - _tol and (na(_exclude) or math.abs(_d - _exclude) > _tol) and (na(_best) or _d > _best)
        _best := _d
        _idx := 4
    if not na(_e) and _e < _price - _tol and (na(_exclude) or math.abs(_e - _exclude) > _tol) and (na(_best) or _e > _best)
        _best := _e
        _idx := 5
    if not na(_f) and _f < _price - _tol and (na(_exclude) or math.abs(_f - _exclude) > _tol) and (na(_best) or _f > _best)
        _best := _f
        _idx := 6
    [_best, _idx]

f_stateColor(int _state) =>
    _state == 1 ? C_BULL : _state == -1 ? C_BEAR : C_NEUTRAL

f_stateText(int _state, bool _confirmed) =>
    _state == 1 ? (_confirmed ? "BULLISH STRUCTURE" : "BULLISH FORMING") : _state == -1 ? (_confirmed ? "BEARISH STRUCTURE" : "BEARISH FORMING") : "NEUTRAL / RANGE"

// =================================================================================================
// 7. ADAPTIVE TREND CHANNEL ENGINE
// =================================================================================================
float trendATR = ta.atr(i_atrLen)
float trendKama = f_kama(close, i_kamaLen, 2, 30)
float trendER = f_efficiency(close, i_erLen)
float kamaSlope = trendKama - trendKama[i_slopeBars]
float kamaSlopeATR = trendATR > 0 ? kamaSlope / trendATR : 0.0
float dynamicWidthMult = i_baseWidthATR + (1.0 - f_clamp(trendER, 0.0, 1.0)) * i_noiseExpansion
float channelHalfWidth = trendATR * dynamicWidthMult
float channelUpper = trendKama + channelHalfWidth
float channelLower = trendKama - channelHalfWidth

bool bullRaw = close > trendKama and kamaSlopeATR >= i_minSlopeATR and trendER >= i_minER
bool bearRaw = close < trendKama and kamaSlopeATR <= -i_minSlopeATR and trendER >= i_minER

var int trendState = 0
var int trendStartBar = na
var int upBreachBars = 0
var int downBreachBars = 0
int priorTrendState = nz(trendState[1], 0)

upBreachBars := priorTrendState == 1 and close < channelLower ? nz(upBreachBars[1]) + 1 : 0
downBreachBars := priorTrendState == -1 and close > channelUpper ? nz(downBreachBars[1]) + 1 : 0

bool breakBullTrend = priorTrendState == 1 and upBreachBars >= i_breakBars
bool breakBearTrend = priorTrendState == -1 and downBreachBars >= i_breakBars

if priorTrendState == 1
    trendState := breakBullTrend ? (bearRaw ? -1 : 0) : 1
else if priorTrendState == -1
    trendState := breakBearTrend ? (bullRaw ? 1 : 0) : -1
else
    trendState := bullRaw ? 1 : bearRaw ? -1 : 0

if trendState != priorTrendState
    trendStartBar := bar_index

int trendAge = trendState != 0 and not na(trendStartBar) ? bar_index - trendStartBar + 1 : 0
bool trendConfirmed = trendState != 0 and trendAge >= i_breakBars
bool bullShift = trendState == 1 and priorTrendState != 1
bool bearShift = trendState == -1 and priorTrendState != -1
float breakRail = trendState == 1 ? channelLower : trendState == -1 ? channelUpper : na
string breakRailText = trendState == 1 ? "UPTREND BREAK BELOW" : trendState == -1 ? "DOWNTREND BREAK ABOVE" : "NO ACTIVE BREAK RAIL"
color trendColor = f_stateColor(trendState)

bool labelGate = i_confirmedOnly ? barstate.isconfirmed : true
bool bullTrendBreakPrint = labelGate and breakBullTrend
bool bearTrendBreakPrint = labelGate and breakBearTrend
bool bullShiftPrint = labelGate and bullShift
bool bearShiftPrint = labelGate and bearShift

// =================================================================================================
// 8. MULTI-HORIZON LEVEL MAP — COMPLETED HIGHER-TIMEFRAME VALUES ONLY
// =================================================================================================
float dailyATR = request.security(syminfo.tickerid, "D", ta.atr(i_dailyAtrLen)[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float d1High = request.security(syminfo.tickerid, "D", high[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float d1Low = request.security(syminfo.tickerid, "D", low[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float d2High = request.security(syminfo.tickerid, "D", ta.highest(high, 2)[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float d2Low = request.security(syminfo.tickerid, "D", ta.lowest(low, 2)[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float d3High = request.security(syminfo.tickerid, "D", ta.highest(high, 3)[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float d3Low = request.security(syminfo.tickerid, "D", ta.lowest(low, 3)[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float wHigh = request.security(syminfo.tickerid, "W", high[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float wLow = request.security(syminfo.tickerid, "W", low[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float mHigh = request.security(syminfo.tickerid, "M", high[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float mLow = request.security(syminfo.tickerid, "M", low[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float yHigh = request.security(syminfo.tickerid, "12M", high[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float yLow = request.security(syminfo.tickerid, "12M", low[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

float zoneHalfWidth = math.max(nz(dailyATR, trendATR) * i_zoneHalfWidthATR, syminfo.mintick * 4.0)
float dedupeTolerance = zoneHalfWidth * 1.25

[resistance1, resistance1Idx] = f_pickAbove(close, d1High, d2High, d3High, wHigh, mHigh, yHigh, na, dedupeTolerance)
[resistance2, resistance2Idx] = f_pickAbove(close, d1High, d2High, d3High, wHigh, mHigh, yHigh, resistance1, dedupeTolerance)
[support1, support1Idx] = f_pickBelow(close, d1Low, d2Low, d3Low, wLow, mLow, yLow, na, dedupeTolerance)
[support2, support2Idx] = f_pickBelow(close, d1Low, d2Low, d3Low, wLow, mLow, yLow, support1, dedupeTolerance)

string resistance1Name = f_levelName(resistance1Idx) + " RES"
string resistance2Name = f_levelName(resistance2Idx) + " RES"
string support1Name = f_levelName(support1Idx) + " SUP"
string support2Name = f_levelName(support2Idx) + " SUP"

bool resistanceBreak = labelGate and not na(resistance1) and close > resistance1 + zoneHalfWidth and close[1] <= resistance1 + zoneHalfWidth
bool supportBreak = labelGate and not na(support1) and close < support1 - zoneHalfWidth and close[1] >= support1 - zoneHalfWidth
float pt1Up = not na(resistance2) ? resistance2 : resistance1 + nz(dailyATR, trendATR) * i_ptFallbackATR1
float pt2Up = resistance1 + nz(dailyATR, trendATR) * i_ptFallbackATR2
float pt1Down = not na(support2) ? support2 : support1 - nz(dailyATR, trendATR) * i_ptFallbackATR1
float pt2Down = support1 - nz(dailyATR, trendATR) * i_ptFallbackATR2

// =================================================================================================
// 9. PIVOT ARCHIVE FOR STRUCTURE PATTERNS
// =================================================================================================
float pivotHigh = ta.pivothigh(high, i_pivotLeft, i_pivotRight)
float pivotLow = ta.pivotlow(low, i_pivotLeft, i_pivotRight)

var float ph1 = na
var float ph2 = na
var float ph3 = na
var int ph1Bar = na
var int ph2Bar = na
var int ph3Bar = na
var float pl1 = na
var float pl2 = na
var float pl3 = na
var int pl1Bar = na
var int pl2Bar = na
var int pl3Bar = na

if not na(pivotHigh)
    ph3 := ph2
    ph3Bar := ph2Bar
    ph2 := ph1
    ph2Bar := ph1Bar
    ph1 := pivotHigh
    ph1Bar := bar_index - i_pivotRight

if not na(pivotLow)
    pl3 := pl2
    pl3Bar := pl2Bar
    pl2 := pl1
    pl2Bar := pl1Bar
    pl1 := pivotLow
    pl1Bar := bar_index - i_pivotRight

// =================================================================================================
// 10. ASCENDING / DESCENDING WEDGE — CANDIDATE AND OBJECTIVE BREAK
// =================================================================================================
bool wedgeDataReady = not na(ph1) and not na(ph2) and not na(pl1) and not na(pl2) and not na(ph1Bar) and not na(ph2Bar) and not na(pl1Bar) and not na(pl2Bar)
float wedgeUpperNow = wedgeDataReady ? f_project(ph2Bar, ph2, ph1Bar, ph1, bar_index) : na
float wedgeLowerNow = wedgeDataReady ? f_project(pl2Bar, pl2, pl1Bar, pl1, bar_index) : na
int wedgeStartBar = wedgeDataReady ? (ph2Bar > pl2Bar ? ph2Bar : pl2Bar) : na
float wedgeUpperStart = wedgeDataReady ? f_project(ph2Bar, ph2, ph1Bar, ph1, wedgeStartBar) : na
float wedgeLowerStart = wedgeDataReady ? f_project(pl2Bar, pl2, pl1Bar, pl1, wedgeStartBar) : na
float wedgeWidthNow = wedgeDataReady ? wedgeUpperNow - wedgeLowerNow : na
float wedgeWidthStart = wedgeDataReady ? wedgeUpperStart - wedgeLowerStart : na
float highSlope = wedgeDataReady ? (ph1 - ph2) / math.max(float(ph1Bar - ph2Bar), 1.0) : na
float lowSlope = wedgeDataReady ? (pl1 - pl2) / math.max(float(pl1Bar - pl2Bar), 1.0) : na
int wedgeAge = wedgeDataReady ? bar_index - wedgeStartBar : 9999

bool ascendingWedge = wedgeDataReady and wedgeAge <= i_wedgeMaxBars and ph1 > ph2 and pl1 > pl2 and highSlope > 0 and lowSlope > highSlope and wedgeWidthNow > syminfo.mintick and wedgeWidthStart > 0 and wedgeWidthNow <= wedgeWidthStart * i_wedgeTightness
bool descendingWedge = wedgeDataReady and wedgeAge <= i_wedgeMaxBars and ph1 < ph2 and pl1 < pl2 and lowSlope < 0 and highSlope < lowSlope and wedgeWidthNow > syminfo.mintick and wedgeWidthStart > 0 and wedgeWidthNow <= wedgeWidthStart * i_wedgeTightness

// =================================================================================================
// 11. HEAD & SHOULDERS / INVERSE H&S — HEURISTIC CANDIDATE + NECKLINE BREAK
// =================================================================================================
float normalNeckline = not na(pl1) and not na(pl2) ? (pl1 + pl2) / 2.0 : na
float inverseNeckline = not na(ph1) and not na(ph2) ? (ph1 + ph2) / 2.0 : na
float shoulderDifference = not na(ph3) and not na(ph1) and trendATR > 0 ? math.abs(ph3 - ph1) / trendATR : 999.0
float inverseShoulderDifference = not na(pl3) and not na(pl1) and trendATR > 0 ? math.abs(pl3 - pl1) / trendATR : 999.0
bool headShouldersCandidate = not na(ph3) and not na(ph2) and not na(ph1) and ph3Bar < ph2Bar and ph2Bar < ph1Bar and shoulderDifference <= i_shoulderToleranceATR and ph2 > ph3 + trendATR * i_headDominanceATR and ph2 > ph1 + trendATR * i_headDominanceATR and trendState == 1
bool inverseHeadShouldersCandidate = not na(pl3) and not na(pl2) and not na(pl1) and pl3Bar < pl2Bar and pl2Bar < pl1Bar and inverseShoulderDifference <= i_shoulderToleranceATR and pl2 < pl3 - trendATR * i_headDominanceATR and pl2 < pl1 - trendATR * i_headDominanceATR and trendState == -1
bool hsNecklineCrossDown = not na(normalNeckline) and ta.crossunder(close, normalNeckline)
bool invHsNecklineCrossUp = not na(inverseNeckline) and ta.crossover(close, inverseNeckline)

// =================================================================================================
// 12. BULL FLAG — IMPULSE / ORDERLY RESET / BREAK
// =================================================================================================
float flagRangeHigh = ta.highest(high, i_flagBars)[1]
float flagRangeLow = ta.lowest(low, i_flagBars)[1]
float poleBaseLow = ta.lowest(low, i_flagPoleBars)[i_flagBars]
float flagPole = not na(flagRangeHigh) and not na(poleBaseLow) ? flagRangeHigh - poleBaseLow : 0.0
float flagWidth = flagRangeHigh - flagRangeLow
float flagSlope = ta.linreg(close, i_flagBars, 0) - ta.linreg(close, i_flagBars, 1)
bool bullFlagCandidate = trendState == 1 and trendConfirmed and flagPole >= trendATR * i_flagPoleATR and flagWidth <= flagPole * i_flagMaxRetrace and flagSlope <= 0 and close >= flagRangeLow and close <= flagRangeHigh

// =================================================================================================
// 13. CUP + HANDLE — HEURISTIC RIM / DEPTH / HANDLE / BREAK
// =================================================================================================
float cupRim = ta.highest(high, i_cupLookback)[1]
float cupBase = ta.lowest(low, i_cupLookback)
float cupDepth = not na(cupRim) and not na(cupBase) ? cupRim - cupBase : 0.0
float handleHigh = ta.highest(high, i_handleBars)[1]
float handleLow = ta.lowest(low, i_handleBars)
float handleDepthFraction = cupDepth > syminfo.mintick ? (cupRim - handleLow) / cupDepth : 999.0
bool nearCupRim = cupDepth > 0 and close >= cupRim - cupDepth * i_cupRimTolerance
bool cupHandleCandidate = trendState >= 0 and cupDepth >= trendATR * i_cupMinDepthATR and nearCupRim and handleDepthFraction >= 0 and handleDepthFraction <= i_handleMaxDepth and handleHigh >= cupRim - cupDepth * i_cupRimTolerance

// =================================================================================================
// 13b. PATTERN EVENT ENGINE — MATURITY, PER-TYPE COOLDOWN, ONE EVENT PER INSTANCE
// -------------------------------------------------------------------------------------------------
// The raw detectors re-arm every time a new pivot redraws the shape, so a per-bar edge latch
// (v1.1) still produced clusters: each re-arm was a fresh "edge". Events are latched per INSTANCE:
//   MATURITY  - candidate must have held i_patternMaturityBars consecutive bars as of the prior
//               bar. A shape that forms off a fresh pivot and breaks immediately never registers.
//   COOLDOWN  - after a break, that pattern type is silent for i_breakCooldownBars.
//   IDENTITY  - wedge breaks require wedgeStartBar AFTER the prior break bar (genuinely new
//               structure, not the old shape re-projected); H&S breaks require a new head pivot.
// Alerts, the badge, and the chart stamp all consume these events, so they always agree.
// =================================================================================================
var int ascRun = 0
var int descRun = 0
var int hsRun = 0
var int invHsRun = 0
var int flagRun = 0
var int cupRun = 0
ascRun := ascendingWedge ? ascRun + 1 : 0
descRun := descendingWedge ? descRun + 1 : 0
hsRun := headShouldersCandidate ? hsRun + 1 : 0
invHsRun := inverseHeadShouldersCandidate ? invHsRun + 1 : 0
flagRun := bullFlagCandidate ? flagRun + 1 : 0
cupRun := cupHandleCandidate ? cupRun + 1 : 0

var int lastAscBreakBar = na
var int lastDescBreakBar = na
var int lastHsBreakBar = na
var int lastInvHsBreakBar = na
var int lastFlagBreakBar = na
var int lastCupBreakBar = na
var int lastHsHeadBar = na
var int lastInvHsHeadBar = na

bool ascWedgeBreakEvent = false
if labelGate and nz(ascRun[1]) >= i_patternMaturityBars and not na(wedgeLowerNow) and close < wedgeLowerNow and (na(lastAscBreakBar) or bar_index - lastAscBreakBar >= i_breakCooldownBars) and (na(lastAscBreakBar) or nz(wedgeStartBar, bar_index) > lastAscBreakBar)
    ascWedgeBreakEvent := true
    lastAscBreakBar := bar_index

bool descWedgeBreakEvent = false
if labelGate and nz(descRun[1]) >= i_patternMaturityBars and not na(wedgeUpperNow) and close > wedgeUpperNow and (na(lastDescBreakBar) or bar_index - lastDescBreakBar >= i_breakCooldownBars) and (na(lastDescBreakBar) or nz(wedgeStartBar, bar_index) > lastDescBreakBar)
    descWedgeBreakEvent := true
    lastDescBreakBar := bar_index

bool hsBreakEvent = false
if labelGate and nz(hsRun[1]) >= i_patternMaturityBars and hsNecklineCrossDown and (na(lastHsBreakBar) or bar_index - lastHsBreakBar >= i_breakCooldownBars) and (na(lastHsHeadBar) or nz(ph2Bar, bar_index) != lastHsHeadBar)
    hsBreakEvent := true
    lastHsBreakBar := bar_index
    lastHsHeadBar := ph2Bar

bool invHsBreakEvent = false
if labelGate and nz(invHsRun[1]) >= i_patternMaturityBars and invHsNecklineCrossUp and (na(lastInvHsBreakBar) or bar_index - lastInvHsBreakBar >= i_breakCooldownBars) and (na(lastInvHsHeadBar) or nz(pl2Bar, bar_index) != lastInvHsHeadBar)
    invHsBreakEvent := true
    lastInvHsBreakBar := bar_index
    lastInvHsHeadBar := pl2Bar

bool flagBreakEvent = false
if labelGate and nz(flagRun[1]) >= i_patternMaturityBars and not na(flagRangeHigh) and close > flagRangeHigh and (na(lastFlagBreakBar) or bar_index - lastFlagBreakBar >= i_breakCooldownBars)
    flagBreakEvent := true
    lastFlagBreakBar := bar_index

bool cupBreakEvent = false
if labelGate and nz(cupRun[1]) >= i_patternMaturityBars and not na(handleHigh) and close > handleHigh and (na(lastCupBreakBar) or bar_index - lastCupBreakBar >= i_breakCooldownBars)
    cupBreakEvent := true
    lastCupBreakBar := bar_index

// Candidate stamps fire once, when the shape first reaches maturity — not on every pivot flicker.
bool newAscendingWedge = ascRun == i_patternMaturityBars
bool newDescendingWedge = descRun == i_patternMaturityBars
bool newHeadShoulders = hsRun == i_patternMaturityBars
bool newInverseHeadShoulders = invHsRun == i_patternMaturityBars
bool newBullFlag = flagRun == i_patternMaturityBars
bool newCupHandle = cupRun == i_patternMaturityBars

// =================================================================================================
// 14. PATTERN PRIORITY / BADGE STATUS
// =================================================================================================
bool patternsOff = i_patternMode == "Off"
bool showCandidates = i_patternMode == "Candidates + Confirmed"
bool showConfirmed = not patternsOff

bool confirmedBullPattern = flagBreakEvent or cupBreakEvent or descWedgeBreakEvent or invHsBreakEvent
bool confirmedBearPattern = ascWedgeBreakEvent or hsBreakEvent
string patternStatus = confirmedBullPattern ? (flagBreakEvent ? "BULL FLAG BREAK" : cupBreakEvent ? "CUP+HANDLE BREAK" : descWedgeBreakEvent ? "DESC WEDGE BREAK" : "INV H&S BREAK") : confirmedBearPattern ? (ascWedgeBreakEvent ? "ASC WEDGE BREAK" : "H&S NECKLINE BREAK") : headShouldersCandidate ? "H&S CANDIDATE" : inverseHeadShouldersCandidate ? "INV H&S CANDIDATE" : ascendingWedge ? "ASC WEDGE" : descendingWedge ? "DESC WEDGE" : bullFlagCandidate ? "BULL FLAG" : cupHandleCandidate ? "CUP+HANDLE" : "—"
color patternColor = confirmedBullPattern ? C_BULL : confirmedBearPattern ? C_BEAR : str.contains(patternStatus, "BULL") or str.contains(patternStatus, "CUP") ? C_INFO : str.contains(patternStatus, "WEDGE") ? C_WARN : str.contains(patternStatus, "H&S") ? C_PURPLE : C_NEUTRAL

// =================================================================================================
// 15. ALERTS — POINTED AT INSTANCE-LATCHED EVENTS SO EACH BREAK ALERTS ONCE
// =================================================================================================
alertcondition(bullTrendBreakPrint, title="KRV Structure — UPTREND BREAK", message="KRV Structure Canvas: confirmed break below adaptive uptrend rail on {{ticker}} {{interval}}.")
alertcondition(bearTrendBreakPrint, title="KRV Structure — DOWNTREND BREAK", message="KRV Structure Canvas: confirmed break above adaptive downtrend rail on {{ticker}} {{interval}}.")
alertcondition(resistanceBreak, title="KRV Structure — RESISTANCE BREAK / PT UP", message="KRV Structure Canvas: resistance zone broken on {{ticker}} {{interval}}. Inspect PT1 / PT2 ladder.")
alertcondition(supportBreak, title="KRV Structure — SUPPORT BREAK / PT DOWN", message="KRV Structure Canvas: support zone broken on {{ticker}} {{interval}}. Inspect PT1 / PT2 ladder.")
alertcondition(flagBreakEvent, title="KRV Structure — BULL FLAG BREAK", message="KRV Structure Canvas: bull flag breakout confirmed on {{ticker}} {{interval}}.")
alertcondition(cupBreakEvent, title="KRV Structure — CUP HANDLE BREAK", message="KRV Structure Canvas: cup-and-handle breakout confirmed on {{ticker}} {{interval}}.")
alertcondition(hsBreakEvent, title="KRV Structure — H&S BREAK", message="KRV Structure Canvas: head-and-shoulders neckline break confirmed on {{ticker}} {{interval}}.")
alertcondition(ascWedgeBreakEvent, title="KRV Structure — ASC WEDGE BREAK", message="KRV Structure Canvas: ascending wedge breakdown confirmed on {{ticker}} {{interval}}.")

// =================================================================================================
// 16. CORE VISUALS — ONE CHANNEL, ONE BREAK RAIL
// =================================================================================================
pTrendBasis = plot(i_showChannel ? trendKama : na, "Adaptive Trend Basis", color=trendState == 1 ? color.new(C_BULL, 0) : trendState == -1 ? color.new(C_BEAR, 0) : color.new(C_NEUTRAL, 15), linewidth=2)
pChannelUpper = plot(i_showChannel ? channelUpper : na, "Adaptive Channel Upper", color=color.new(trendColor, 72), linewidth=1)
pChannelLower = plot(i_showChannel ? channelLower : na, "Adaptive Channel Lower", color=color.new(trendColor, 72), linewidth=1)
fill(pChannelUpper, pChannelLower, color=i_showChannel ? color.new(trendColor, 88) : na, title="Adaptive Trend Channel Fill")
plot(i_showBreakRail ? breakRail : na, "Active Trend Break Rail", color=trendState == 1 ? color.new(C_BEAR, 0) : trendState == -1 ? color.new(C_BULL, 0) : na, linewidth=2, style=plot.style_linebr)

color canvasBarColor = trendState == 1 ? color.new(C_BULL, 72) : trendState == -1 ? color.new(C_BEAR, 72) : na
barcolor(i_colorCandles ? canvasBarColor : na)

// =================================================================================================
// 17. MULTI-HORIZON ZONE BOXES — ONLY THE NEAREST TWO ABOVE / BELOW
// =================================================================================================
var box resBox1 = na
var box resBox2 = na
var box supBox1 = na
var box supBox2 = na
var label resLabel1 = na
var label resLabel2 = na
var label supLabel1 = na
var label supLabel2 = na

if barstate.islast
    if not na(resBox1)
        box.delete(resBox1)
    if not na(resBox2)
        box.delete(resBox2)
    if not na(supBox1)
        box.delete(supBox1)
    if not na(supBox2)
        box.delete(supBox2)
    if not na(resLabel1)
        label.delete(resLabel1)
    if not na(resLabel2)
        label.delete(resLabel2)
    if not na(supLabel1)
        label.delete(supLabel1)
    if not na(supLabel2)
        label.delete(supLabel2)

    int zoneLeft = math.max(0, bar_index - i_zoneLookbackBars)
    int zoneRight = bar_index + i_zoneProjectionBars
    float zoneMaxDistance = nz(dailyATR, trendATR) * i_zoneMaxDistanceATR
    if i_showSR and not na(resistance1) and resistance1 - close <= zoneMaxDistance
        resBox1 := box.new(left=zoneLeft, top=resistance1 + zoneHalfWidth, right=zoneRight, bottom=resistance1 - zoneHalfWidth, xloc=xloc.bar_index, border_color=color.new(C_BEAR, 35), border_width=1, bgcolor=color.new(C_BEAR, 90))
        if i_showZoneLabels
            resLabel1 := label.new(x=zoneRight, y=resistance1, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(C_BEAR, 8), textcolor=color.white, size=size.tiny, text=resistance1Name)
    if i_showSR and i_srDepth == 2 and not na(resistance2) and resistance2 - close <= zoneMaxDistance
        resBox2 := box.new(left=zoneLeft, top=resistance2 + zoneHalfWidth, right=zoneRight, bottom=resistance2 - zoneHalfWidth, xloc=xloc.bar_index, border_color=color.new(C_BEAR, 65), border_width=1, bgcolor=color.new(C_BEAR, 94))
        if i_showZoneLabels
            resLabel2 := label.new(x=zoneRight, y=resistance2, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(C_BEAR, 35), textcolor=color.white, size=size.tiny, text=resistance2Name)
    if i_showSR and not na(support1) and close - support1 <= zoneMaxDistance
        supBox1 := box.new(left=zoneLeft, top=support1 + zoneHalfWidth, right=zoneRight, bottom=support1 - zoneHalfWidth, xloc=xloc.bar_index, border_color=color.new(C_BULL, 35), border_width=1, bgcolor=color.new(C_BULL, 90))
        if i_showZoneLabels
            supLabel1 := label.new(x=zoneRight, y=support1, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(C_BULL, 8), textcolor=color.black, size=size.tiny, text=support1Name)
    if i_showSR and i_srDepth == 2 and not na(support2) and close - support2 <= zoneMaxDistance
        supBox2 := box.new(left=zoneLeft, top=support2 + zoneHalfWidth, right=zoneRight, bottom=support2 - zoneHalfWidth, xloc=xloc.bar_index, border_color=color.new(C_BULL, 65), border_width=1, bgcolor=color.new(C_BULL, 94))
        if i_showZoneLabels
            supLabel2 := label.new(x=zoneRight, y=support2, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(C_BULL, 35), textcolor=color.black, size=size.tiny, text=support2Name)

// =================================================================================================
// 18. PT LADDER — ONLY ON A CONFIRMED BREAKOUT / BREAKDOWN
// =================================================================================================
var line pt1Line = na
var line pt2Line = na
var label pt1Label = na
var label pt2Label = na
var label breakLabel = na

if i_showBreakTargets and (resistanceBreak or supportBreak)
    if not na(pt1Line)
        line.delete(pt1Line)
    if not na(pt2Line)
        line.delete(pt2Line)
    if not na(pt1Label)
        label.delete(pt1Label)
    if not na(pt2Label)
        label.delete(pt2Label)
    if not na(breakLabel)
        label.delete(breakLabel)

    bool upBreak = resistanceBreak
    float triggerLevel = upBreak ? resistance1 : support1
    float target1 = f_roundTick(upBreak ? pt1Up : pt1Down)
    float target2 = f_roundTick(upBreak ? pt2Up : pt2Down)
    color ptColor = upBreak ? C_BULL : C_BEAR
    string directionText = upBreak ? "RES BREAK" : "SUP BREAK"
    int ptRight = bar_index + i_ptProjectionBars

    pt1Line := line.new(x1=bar_index, y1=target1, x2=ptRight, y2=target1, xloc=xloc.bar_index, extend=extend.none, color=color.new(ptColor, 10), style=line.style_dotted, width=2)
    pt2Line := line.new(x1=bar_index, y1=target2, x2=ptRight, y2=target2, xloc=xloc.bar_index, extend=extend.none, color=color.new(ptColor, 0), style=line.style_dashed, width=2)
    pt1Label := label.new(x=ptRight, y=target1, xloc=xloc.bar_index, style=label.style_label_left, color=ptColor, textcolor=upBreak ? color.black : color.white, size=size.tiny, text="PT1")
    pt2Label := label.new(x=ptRight, y=target2, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(ptColor, 18), textcolor=upBreak ? color.black : color.white, size=size.tiny, text="PT2")
    breakLabel := label.new(x=bar_index, y=triggerLevel, xloc=xloc.bar_index, style=upBreak ? label.style_label_up : label.style_label_down, color=ptColor, textcolor=upBreak ? color.black : color.white, size=size.small, text=directionText + "\n" + (upBreak ? resistance1Name : support1Name))

// =================================================================================================
// 19. PATTERN GUIDE LINES — CURRENT ACTIVE SHAPE ONLY
// =================================================================================================
var line wedgeUpperGuide = na
var line wedgeLowerGuide = na
var line hsNeckGuide = na

if barstate.islast
    if not na(wedgeUpperGuide)
        line.delete(wedgeUpperGuide)
    if not na(wedgeLowerGuide)
        line.delete(wedgeLowerGuide)
    if not na(hsNeckGuide)
        line.delete(hsNeckGuide)

    bool showGuides = i_showPatternGuides and i_canvasMode == "Research"
    if showGuides and (ascendingWedge or descendingWedge)
        color wedgeColor = ascendingWedge ? C_WARN : C_INFO
        wedgeUpperGuide := line.new(x1=ph2Bar, y1=ph2, x2=bar_index + 20, y2=f_project(ph2Bar, ph2, ph1Bar, ph1, bar_index + 20), xloc=xloc.bar_index, extend=extend.none, color=color.new(wedgeColor, 10), style=line.style_dashed, width=1)
        wedgeLowerGuide := line.new(x1=pl2Bar, y1=pl2, x2=bar_index + 20, y2=f_project(pl2Bar, pl2, pl1Bar, pl1, bar_index + 20), xloc=xloc.bar_index, extend=extend.none, color=color.new(wedgeColor, 10), style=line.style_dashed, width=1)
    if showGuides and headShouldersCandidate and not na(normalNeckline)
        hsNeckGuide := line.new(x1=bar_index - 30, y1=normalNeckline, x2=bar_index + 20, y2=normalNeckline, xloc=xloc.bar_index, extend=extend.none, color=color.new(C_PURPLE, 10), style=line.style_dotted, width=2)
    if showGuides and inverseHeadShouldersCandidate and not na(inverseNeckline)
        hsNeckGuide := line.new(x1=bar_index - 30, y1=inverseNeckline, x2=bar_index + 20, y2=inverseNeckline, xloc=xloc.bar_index, extend=extend.none, color=color.new(C_PURPLE, 10), style=line.style_dotted, width=2)

// =================================================================================================
// 20. UNIFIED STRUCTURE STAMP — ONE PRIORITIZED LABEL PER BAR, SHARED SPACING
// -------------------------------------------------------------------------------------------------
// One ranked selector, one label max per bar. Rank 3 = trend rail break / structure shift (always
// prints). Rank 2 = confirmed pattern break (instance-latched upstream, and additionally respects
// i_minLabelGap so different pattern types cannot cluster back-to-back). Rank 1 = candidate
// (respects i_minLabelGap). A rank-2 event suppressed by spacing still fires its alert and updates
// the LAST EVENT badge row — the chart stays clean, the record stays complete.
// =================================================================================================
var int lastStampBar = na
var string lastEventText = "—"
var int lastEventTime = na
var color lastEventColor = C_NEUTRAL

int stampGap = bar_index - nz(lastStampBar, -100000)

string evtText = ""
color evtColor = C_NEUTRAL
color evtTextColor = color.white
bool evtBelow = false
string evtSize = size.tiny
int evtRank = 0

if i_showBreakLabels and bullTrendBreakPrint
    evtText := "UPTREND BREAK"
    evtColor := C_BEAR
    evtTextColor := color.white
    evtBelow := false
    evtSize := size.small
    evtRank := 3
else if i_showBreakLabels and bearTrendBreakPrint
    evtText := "DOWNTREND BREAK"
    evtColor := C_BULL
    evtTextColor := color.black
    evtBelow := true
    evtSize := size.small
    evtRank := 3
else if i_showShiftLabels and bullShiftPrint
    evtText := "BULL STRUCTURE"
    evtColor := C_BULL
    evtTextColor := color.black
    evtBelow := true
    evtSize := size.tiny
    evtRank := 3
else if i_showShiftLabels and bearShiftPrint
    evtText := "BEAR STRUCTURE"
    evtColor := C_BEAR
    evtTextColor := color.white
    evtBelow := false
    evtSize := size.tiny
    evtRank := 3
else if showConfirmed and hsBreakEvent
    evtText := "H&S BREAK"
    evtColor := C_BEAR
    evtTextColor := color.white
    evtBelow := false
    evtSize := size.small
    evtRank := 2
else if showConfirmed and invHsBreakEvent
    evtText := "INV H&S BREAK"
    evtColor := C_BULL
    evtTextColor := color.black
    evtBelow := true
    evtSize := size.small
    evtRank := 2
else if showConfirmed and ascWedgeBreakEvent
    evtText := "WEDGE BREAK"
    evtColor := C_BEAR
    evtTextColor := color.white
    evtBelow := false
    evtSize := size.small
    evtRank := 2
else if showConfirmed and descWedgeBreakEvent
    evtText := "WEDGE BREAK"
    evtColor := C_BULL
    evtTextColor := color.black
    evtBelow := true
    evtSize := size.small
    evtRank := 2
else if showConfirmed and flagBreakEvent
    evtText := "FLAG BREAK"
    evtColor := C_BULL
    evtTextColor := color.black
    evtBelow := true
    evtSize := size.small
    evtRank := 2
else if showConfirmed and cupBreakEvent
    evtText := "CUP BREAK"
    evtColor := C_BULL
    evtTextColor := color.black
    evtBelow := true
    evtSize := size.small
    evtRank := 2
else if showCandidates and newHeadShoulders
    evtText := "H&S"
    evtColor := C_PURPLE
    evtTextColor := color.white
    evtBelow := false
    evtSize := size.tiny
    evtRank := 1
else if showCandidates and newInverseHeadShoulders
    evtText := "INV H&S"
    evtColor := C_PURPLE
    evtTextColor := color.white
    evtBelow := true
    evtSize := size.tiny
    evtRank := 1
else if showCandidates and newAscendingWedge
    evtText := "ASC WEDGE"
    evtColor := C_WARN
    evtTextColor := color.black
    evtBelow := false
    evtSize := size.tiny
    evtRank := 1
else if showCandidates and newDescendingWedge
    evtText := "DESC WEDGE"
    evtColor := C_INFO
    evtTextColor := color.black
    evtBelow := true
    evtSize := size.tiny
    evtRank := 1
else if showCandidates and newBullFlag
    evtText := "BULL FLAG"
    evtColor := C_INFO
    evtTextColor := color.black
    evtBelow := true
    evtSize := size.tiny
    evtRank := 1
else if showCandidates and newCupHandle
    evtText := "CUP+HANDLE"
    evtColor := C_INFO
    evtTextColor := color.black
    evtBelow := true
    evtSize := size.tiny
    evtRank := 1

bool canStamp = evtText != "" and (evtRank == 3 or stampGap >= i_minLabelGap)
if canStamp
    float evtY = evtBelow ? low : high
    label.new(x=bar_index, y=evtY, xloc=xloc.bar_index, style=evtBelow ? label.style_label_up : label.style_label_down, color=evtColor, textcolor=evtTextColor, size=evtSize, text=evtText)
    lastStampBar := bar_index
if evtRank >= 2
    lastEventText := evtText
    lastEventColor := evtColor
    lastEventTime := time

// =================================================================================================
// 21. STRUCTURE BADGE — VISUAL COMMAND WITHOUT A SECOND EXECUTION DASHBOARD
// =================================================================================================
var table structureBadge = table.new(position.top_left, 2, 6, border_width=1)
if barstate.islast
    table.clear(structureBadge, 0, 0, 1, 5)
    if i_showPanel
        color headerColor = trendState == 1 ? C_BULL : trendState == -1 ? C_BEAR : C_PANEL
        table.cell(structureBadge, 0, 0, "KRV STRUCTURE", text_color=color.white, bgcolor=headerColor, text_size=size.small)
        table.cell(structureBadge, 1, 0, i_canvasMode, text_color=trendState == 0 ? C_NEUTRAL : color.black, bgcolor=headerColor, text_size=size.small)

        table.cell(structureBadge, 0, 1, "TREND", text_color=color.white, bgcolor=C_PANEL, text_size=size.small)
        table.cell(structureBadge, 1, 1, f_stateText(trendState, trendConfirmed), text_color=trendColor, bgcolor=C_PANEL, text_size=size.small)

        table.cell(structureBadge, 0, 2, "BREAK RAIL", text_color=color.white, bgcolor=C_PANEL, text_size=size.small)
        string breakText = na(breakRail) ? "NO ACTIVE RAIL" : breakRailText + " " + str.tostring(breakRail, format.mintick)
        table.cell(structureBadge, 1, 2, breakText, text_color=trendState == 1 ? C_BEAR : trendState == -1 ? C_BULL : C_NEUTRAL, bgcolor=C_PANEL, text_size=size.small)

        table.cell(structureBadge, 0, 3, "NEAREST", text_color=color.white, bgcolor=C_PANEL, text_size=size.small)
        string nearestText = not na(resistance1) ? resistance1Name + " " + str.tostring(resistance1, format.mintick) + " | " + support1Name + " " + str.tostring(support1, format.mintick) : "LEVELS BUILDING"
        table.cell(structureBadge, 1, 3, nearestText, text_color=C_INFO, bgcolor=C_PANEL, text_size=size.small)

        table.cell(structureBadge, 0, 4, "PATTERN", text_color=color.white, bgcolor=C_PANEL, text_size=size.small)
        table.cell(structureBadge, 1, 4, patternStatus, text_color=patternColor, bgcolor=C_PANEL, text_size=size.small)

        table.cell(structureBadge, 0, 5, "LAST EVENT", text_color=color.white, bgcolor=C_PANEL, text_size=size.small)
        string leTime = na(lastEventTime) ? "" : "  " + str.format_time(lastEventTime, "MMM d HH:mm", syminfo.timezone)
        table.cell(structureBadge, 1, 5, lastEventText + leTime, text_color=lastEventColor, bgcolor=C_PANEL, text_size=size.small)
````
