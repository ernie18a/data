# Overbought & Oversold Zones - MTF Signals

- url: https://www.tradingview.com/script/ejgrCxEj-Overbought-Oversold-Zones-MTF-Signals/
- type: indicator
- pine_id: PUB;8e2d99000af5437fa084ab0518000294
- version: 1.0

## Description

[b]Overbought & Oversold Zones - MTF Signals[/b]

Overbought & Oversold Zones - MTF Signals is a visual analytical indicator that highlights extreme directional conditions directly on the price chart and across multiple timeframes. Instead of plotting an oscillator line in a separate pane, it paints gradient zones around price during periods of sustained buying or selling pressure, helping traders see exhaustion states at a glance.

The indicator combines a custom Pressure Index calculation with a volatility-adjusted envelope to shape the zones, and a compact multi-timeframe panel that scans the current timeframe plus the three higher ones.

This is a visual analytical tool intended for chart reading and context. It does not execute trades and does not provide financial advice.

[b]Key Features[/b]

[list]

[*]On-chart gradient zones highlighting overbought and oversold conditions

[*]Zones follow the shape of a dynamic volatility envelope (not rectangles)

[*]Multi-timeframe panel scanning current TF plus three higher TFs

[*]Merged phase logic that groups close-proximity conditions into single zones

[*]Adjustable sensitivity through ten preset levels

[*]Fully customizable colors and optional text labels

[/list]

[b]Core Concept[/b]

The indicator uses a custom Pressure Index model to evaluate how consistently price has been pushing above or below a volatility-adjusted baseline. Unlike traditional oscillators such as RSI (which measures gain/loss ratios) or Stochastic (which measures position within a range), Pressure Index combines two complementary components:

[list]

[*]Persistence — how consistently price has stayed above or below a volatility-adjusted baseline over the measurement window, weighted by normalized distance rather than as a binary above/below count

[*]Displacement — how far current price is from that baseline in ATR-normalized units

[/list]

The baseline adapts to volatility regime: during high-volatility periods the reference band widens to reduce false exhaustion signals, and during calm periods it tightens. Final output is bounded to a 0–100 scale and smoothed with a sensitivity-scaled EMA.

[b]Zone Visualization[/b]

When the Pressure Index enters an extreme region, the indicator renders a three-layer gradient zone that follows the shape of the dynamic envelope:

[list]

[*]Overbought zones fade downward from the upper envelope into the channel

[*]Oversold zones fade upward from the lower envelope into the channel

[*]Zone thickness scales with ATR so the visual is comparable across markets and timeframes

[/list]

The gradient has three layers: a dense core band close to the envelope, a middle fade band, and an outer soft fade. This layered approach helps the zones visually surround the candles inside the extreme state rather than appearing as flat bars.

[b]Multi-Timeframe Panel[/b]

A compact panel in the top-right corner of the chart displays the Pressure Index across the current timeframe and three higher timeframes (automatically selected from the standard ladder: 1m, 5m, 15m, 30m, 1H, 4H, 1D, 1W, 1M).

Each row shows:

[list]

[*]Timeframe label

[*]Horizontal gauge bar with a position marker

[*]Numeric Pressure Index value (0–100)

[*]State pill indicating Overbought (OB), Oversold (OS), or neutral direction

[/list]

The panel adapts its higher timeframes to whichever chart timeframe is currently active. The current chart timeframe is marked with a bullet indicator.

[b]Typical Analysis Workflow[/b]

A common analytical workflow may include:

[list=1]

[*]Observing gradient zones on the main chart to identify extended conditions

[*]Checking the MTF panel to place the current reading in higher-timeframe context

[*]Evaluating price structure and candle behavior near zone edges

[*]Combining zone information with other forms of analysis and risk management

[/list]

[b]Configuration[/b]

[b]Sensitivity[/b] — Controls how quickly the Pressure Index reacts to changes in price pressure. Lower values produce faster, more frequent signals. Higher values produce slower, steadier signals.

[list]

[*]Lower settings (1-3) — Faster reactivity, suitable for intraday charts and shorter timeframes

[*]Middle settings (4-6) — Balanced sensitivity, default for most markets and timeframes

[*]Higher settings (7-10) — Slower reactivity, suitable for swing and position-style chart reading

[/list]

[b]On-Chart Display[/b] — Toggles the gradient zones on or off.

[b]Show Text Labels[/b] — Toggles "Overbought" and "Oversold" text labels that appear once per merged phase. Can be disabled for a cleaner chart.

[b]Show MTF Panel[/b] — Toggles the multi-timeframe panel.

[b]Appearance[/b] — Customizable colors for Overbought and Oversold zones, panel text size, and history rendering depth.

[b]Markets and Timeframes[/b]

The indicator can be applied across multiple markets and timeframes:

[list]

[*]Forex

[*]Stocks and Indices

[*]Commodities

[*]Cryptocurrencies

[/list]

Because the zone thickness and Pressure Index smoothing are both normalized by ATR and sensitivity presets, the visual behavior remains consistent across different instruments and timeframes without manual re-tuning.

[b]Alerts[/b]

Two alert conditions are available:

[list]

[*]Overbought Entry — triggers on the first bar a new Overbought state begins

[*]Oversold Entry — triggers on the first bar a new Oversold state begins

[/list]

[b]Important Notes[/b]

This indicator is an analytical visualization tool. It does not execute trades and does not provide financial advice. All outputs are informational and should be interpreted within the context of independent market analysis and proper risk management.

Past behavior of any technical indicator does not guarantee future results.

If you find this indicator useful, feel free to add it to your favorites and share your feedback in the comments. Community feedback helps improve future updates.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
//
// Multi-Timeframe Overbought & Oversold Indicator
// Open-source visual tool for tracking exhaustion conditions across
// multiple timeframes using a custom Pressure Index model.
//
// The Pressure Index combines two independent components:
//   1. Persistence - how consistently price has stayed above/below a
//      volatility-adjusted baseline over the measurement window, weighted
//      by distance (not binary).
//   2. Displacement - how far current price is from that baseline in
//      ATR-normalized units.
// The baseline adapts to volatility regime: in high-volatility periods
// the reference band widens to reduce false exhaustion signals. Final
// output is smoothed with a sensitivity-scaled EMA.
//
// Components on chart:
//   - Overbought / Oversold ribbon segments plotted on price, anchored
//     to dynamic volatility envelopes.
//   - Entry labels on the first bar an extreme state begins.
//   - MTF panel to the right of price showing Pressure Index across
//     current timeframe and the three higher timeframes as horizontal
//     gauges with state indicators.

//@version=6
indicator("Overbought & Oversold Zones - MTF Signals", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

// =============== Inputs ===============

// General ----------------------------------------------------------------

sensitivityInput = input.string(
     defval="6",
     title="Sensitivity",
     options=["1","2","3","4","5","6","7","8","9","10"],
     tooltip="Overbought / Oversold reactivity. Lower values react faster (more signals); higher values react slower (fewer signals).",
     group="General"
)

displayModeInput = input.string(
     defval="On",
     title="Show Zones",
     options=["On","Off"],
     tooltip="Shows gradient zones around candles during Overbought/Oversold states. Turn off to hide all on-chart zones.",
     group="General"
)

labelsOnInput = input.bool(
     true,
     title="Show Text Labels",
     tooltip="Shows 'Overbought' / 'Oversold' text labels on the first bar of each extreme phase. Turn off for a cleaner chart.",
     group="General"
)

showMtfPanelInput = input.bool(
     true,
     title="Show MTF Panel",
     tooltip="Shows the multi-timeframe OB/OS panel in the top-right corner of the chart.",
     group="General"
)

// Appearance -------------------------------------------------------------

overboughtColor = input.color(
     color.rgb(235, 85, 100),
     title="Overbought Color",
     tooltip="Color for Overbought ribbon, labels, and gauge markers.",
     group="Appearance"
)

oversoldColor = input.color(
     color.rgb(0, 220, 185),
     title="Oversold Color",
     tooltip="Color for Oversold ribbon, labels, and gauge markers.",
     group="Appearance"
)

panelSizeInput = input.string(
     defval="Normal",
     title="Panel Size",
     options=["Compact","Normal","Large"],
     tooltip="Text size used inside the MTF panel.",
     group="Appearance"
)

historyBarsInput = input.int(
     1000,
     minval=1,
     title="History Bars (rendering)",
     tooltip="Limits on-chart ribbon drawings to the most recent N bars for performance.",
     group="Appearance"
)

// =============== Constants ===============
const int   BASELINE_MA_PERIOD     = 100
const float PRESSURE_OVERBOUGHT    = 95.0
const float PRESSURE_OVERSOLD      = 5.0
const int   ENVELOPE_PERIOD        = 14
const float ENVELOPE_DEVIATION     = 0.50
const float PERSIST_WEIGHT         = 0.70    // weight of Persistence component
const float DISPLACE_WEIGHT        = 0.30    // weight of Displacement component
const float DISPLACE_CLAMP         = 3.0     // max ATR-units for Displacement

// Panel palette
color PANEL_BG         = color.new(color.rgb(18, 22, 28), 8)
color PANEL_BORDER     = color.new(color.rgb(70, 80, 95), 40)
color TRACK_BG         = color.new(color.rgb(48, 56, 68), 55)
color TEXT_PRIMARY     = color.rgb(230, 235, 242)
color TEXT_SECONDARY   = color.new(color.rgb(150, 160, 175), 0)

// =============== Functions ===============

// Sensitivity preset -> measurement window length
f_sensToWindow(_sens) =>
    _sens == "1" ? 10 : _sens == "2" ? 20 : _sens == "3" ? 30 : _sens == "4" ? 40 : _sens == "5" ? 50 : _sens == "6" ? 60 : _sens == "7" ? 80 : _sens == "8" ? 120 : _sens == "9" ? 160 : _sens == "10" ? 220 : 60

// Sensitivity preset -> final EMA smoothing length
f_sensToSmoothing(_sens) =>
    _sens == "1" ? 2 : _sens == "2" ? 2 : _sens == "3" ? 3 : _sens == "4" ? 3 : _sens == "5" ? 3 : _sens == "6" ? 4 : _sens == "7" ? 4 : _sens == "8" ? 5 : _sens == "9" ? 5 : _sens == "10" ? 5 : 3

f_clamp(_v, _lo, _hi) => math.max(_lo, math.min(_hi, _v))

// Timeframe gain for envelope deviation
f_tfGainEnv() => timeframe.period == "1" ? 0.85 : timeframe.period == "5" ? 0.92 : timeframe.period == "15" ? 0.98 : timeframe.period == "30" ? 1.00 : timeframe.period == "60" ? 1.03 : timeframe.period == "240" ? 1.06 : timeframe.period == "1D" ? 1.10 : 1.00

f_envDeviationPctDynamic() =>
    float atrRaw = ta.atr(200)
    float px     = (bar_index > 0 and close[1] > 0.0) ? close[1] : (close > 0.0 ? close : 1.0)
    float atr    = bar_index > 0 ? atrRaw[1] : atrRaw
    float atrPct = (atr / px) * 100.0
    float dev    = atrPct * 1.6 * f_tfGainEnv()
    float bias   = f_clamp(ENVELOPE_DEVIATION / 0.50, 0.75, 1.25)
    f_clamp(dev * bias, 0.03, 1.20)

f_buildEnvelopes(float _src) =>
    float _ma = na
    float _u  = na
    float _l  = na
    float maEnv   = ta.ema(_src, ENVELOPE_PERIOD)
    float devPct  = f_envDeviationPctDynamic()
    float devFrac = devPct * 0.01
    if bar_index >= ENVELOPE_PERIOD - 1
        _ma := maEnv
        _u  := maEnv * (1 + devFrac)
        _l  := maEnv * (1 - devFrac)
    [_ma, _u, _l]

// Higher TF ladder
// NOTE: Pine v6 always includes multiplier in timeframe.period, so daily="1D",
// weekly="1W", monthly="1M" (not "D", "W", "M" as in v5).
f_fillHigherTfStrings(_currTf) =>
    string[] _ladder = array.from("1", "5", "15", "30", "60", "240", "1D", "1W", "1M")
    string[] _out    = array.new_string()
    int _pos         = -1
    for i = 0 to array.size(_ladder) - 1
        if array.get(_ladder, i) == _currTf
            _pos := i
            break
    if _pos != -1
        for k = _pos + 1 to array.size(_ladder) - 1
            if array.size(_out) >= 3
                break
            array.push(_out, array.get(_ladder, k))
    _out

f_prettyTf(string _tf) =>
    _tf == "1" ? "1m" : _tf == "5" ? "5m" : _tf == "15" ? "15m" : _tf == "30" ? "30m" : _tf == "60" ? "1H" : _tf == "240" ? "4H" : _tf == "1D" ? "1D" : _tf == "1W" ? "1W" : _tf == "1M" ? "1M" : _tf

// =============== History limiter ===============
bool withinHistory = bar_index >= (last_bar_index - historyBarsInput)

// =============== Pressure Index (custom OB/OS model) ===============
//
// Two-component exhaustion detector:
//
//   Persistence (P): weighted count of how consistently close has stayed
//   above the volatility-adjusted baseline over the measurement window.
//   Each bar contributes a value in [0..1] proportional to its normalized
//   distance above the baseline (capped at 2 ATRs), not a binary above/below.
//
//   Displacement (D): current close distance from baseline in ATR-units,
//   clamped and normalized to [0..1].
//
//   Pressure = 100 * (0.7 * P + 0.3 * D), then smoothed by a sensitivity-
//   scaled EMA. Range: 0 (full oversold) .. 100 (full overbought).
//
// Baseline uses an adaptive sigma coefficient that scales between 0.15
// and 0.35 depending on the ratio of short-term to long-term ATR, so the
// reference band widens in volatile regimes and tightens in calm ones.

int   windowLen    = f_sensToWindow(sensitivityInput)
int   smoothLen    = f_sensToSmoothing(sensitivityInput)

// Adaptive sigma coefficient based on volatility regime
float atrShort = ta.atr(14)
float atrLong  = ta.atr(50)
float volRatio = (not na(atrShort) and not na(atrLong) and atrLong > 0.0) ? (atrShort / atrLong) : 1.0
float kSigma   = f_clamp(0.15 + (volRatio - 1.0) * 0.20, 0.15, 0.35)

// Volatility-adjusted baseline
float baseSma  = ta.sma(close, BASELINE_MA_PERIOD)
float baseStd  = ta.stdev(close, BASELINE_MA_PERIOD)
float baseline = na
if bar_index >= BASELINE_MA_PERIOD - 1
    baseline := baseSma - kSigma * baseStd

// ATR used for Persistence bar weighting and Displacement normalization
float atrRef = ta.atr(14)

// Persistence: weighted count over window
float persistence = na
if bar_index >= BASELINE_MA_PERIOD - 1 and bar_index >= windowLen - 1 and not na(atrRef) and atrRef > 0.0
    float sumWeight = 0.0
    for j = 0 to windowLen - 1
        float b = baseline[j]
        float a = atrRef[j]
        if not na(b) and not na(a) and a > 0.0
            float delta = (close[j] - b) / a        // ATR-normalized distance
            float w     = f_clamp(delta, 0.0, 2.0) / 2.0  // 0..1 (only above-baseline contribution)
            sumWeight := sumWeight + w
    persistence := sumWeight / windowLen  // 0..1

// Displacement: current distance in ATR-units, symmetric, normalized to 0..1
float displacement = na
if not na(baseline) and not na(atrRef) and atrRef > 0.0
    float delta = (close - baseline) / atrRef
    float clamped = f_clamp(delta, -DISPLACE_CLAMP, DISPLACE_CLAMP)
    displacement := (clamped + DISPLACE_CLAMP) / (2.0 * DISPLACE_CLAMP)  // 0..1

// Composite Pressure Index 0..100
float pressureRaw = na
if not na(persistence) and not na(displacement)
    pressureRaw := 100.0 * (PERSIST_WEIGHT * persistence + DISPLACE_WEIGHT * displacement)

// Sensitivity-scaled smoothing (EMA length from preset)
float pressureSmooth = ta.ema(pressureRaw, smoothLen)

float pressureVal = na
if not na(pressureRaw)
    pressureVal := pressureSmooth

bool isOverbought  = not na(pressureVal) and pressureVal >= PRESSURE_OVERBOUGHT
bool isOversold    = not na(pressureVal) and pressureVal <= PRESSURE_OVERSOLD
bool wasOverbought = pressureVal[1] >= PRESSURE_OVERBOUGHT
bool wasOversold   = pressureVal[1] <= PRESSURE_OVERSOLD
bool obOnset       = not wasOverbought and isOverbought
bool osOnset       = not wasOversold and isOversold

// Dynamic envelopes for ribbon anchoring
[envMa, envU, envL] = f_buildEnvelopes(close)

// =============== OB/OS Envelope Zones: gradient fills following envU / envL ===============
//
// Instead of drawing rectangles around candles, we render gradient fills
// that follow the dynamic envelope curves:
//   - In Overbought:  fill from envU DOWNWARD into the channel, 3 layers
//   - In Oversold:    fill from envL UPWARD into the channel, 3 layers
// The fill is toggled per-bar via series color: when the state is not
// active, fill color becomes fully transparent (invisible). This gives
// curve-shaped zones that hug the envelope, never rectangular.
//
// Implementation: plot() draws hidden border lines, fill() between two
// plots uses a series color that turns on/off with isOverbought/isOversold.

bool showZones  = displayModeInput == "On"
bool showLabels = labelsOnInput

// ATR for layer extent (how far inward from the envelope the zone reaches)
float atrZone = ta.atr(14)

// Zone layer extents as ATR multipliers (inward from envelope, into channel)
const float CORE_EXTENT  = 0.6
const float MID_EXTENT   = 1.6
const float OUTER_EXTENT = 3.0

// Layer colors: dense core near envelope, fading outward
color obCoreColOn  = color.new(overboughtColor, 45)
color obMidColOn   = color.new(overboughtColor, 68)
color obOuterColOn = color.new(overboughtColor, 85)
color osCoreColOn  = color.new(oversoldColor, 45)
color osMidColOn   = color.new(oversoldColor, 68)
color osOuterColOn = color.new(oversoldColor, 85)
color offCol       = color.new(color.black, 100)  // fully transparent

// Boundaries for each OB layer (3 bands going DOWN from envU into channel)
float obBand1 = (not na(envU) and not na(atrZone)) ? envU - atrZone * CORE_EXTENT  : na
float obBand2 = (not na(envU) and not na(atrZone)) ? envU - atrZone * MID_EXTENT   : na
float obBand3 = (not na(envU) and not na(atrZone)) ? envU - atrZone * OUTER_EXTENT : na

// Boundaries for each OS layer (3 bands going UP from envL into channel)
float osBand1 = (not na(envL) and not na(atrZone)) ? envL + atrZone * CORE_EXTENT  : na
float osBand2 = (not na(envL) and not na(atrZone)) ? envL + atrZone * MID_EXTENT   : na
float osBand3 = (not na(envL) and not na(atrZone)) ? envL + atrZone * OUTER_EXTENT : na

// Plot the envelope and band boundaries as hidden lines (needed for fill())
p_envU  = plot(showZones ? envU    : na, title="OB envU top",    color=color.new(color.black, 100), display=display.none)
p_obB1  = plot(showZones ? obBand1 : na, title="OB band 1",      color=color.new(color.black, 100), display=display.none)
p_obB2  = plot(showZones ? obBand2 : na, title="OB band 2",      color=color.new(color.black, 100), display=display.none)
p_obB3  = plot(showZones ? obBand3 : na, title="OB band 3",      color=color.new(color.black, 100), display=display.none)

p_envL  = plot(showZones ? envL    : na, title="OS envL bottom", color=color.new(color.black, 100), display=display.none)
p_osB1  = plot(showZones ? osBand1 : na, title="OS band 1",      color=color.new(color.black, 100), display=display.none)
p_osB2  = plot(showZones ? osBand2 : na, title="OS band 2",      color=color.new(color.black, 100), display=display.none)
p_osB3  = plot(showZones ? osBand3 : na, title="OS band 3",      color=color.new(color.black, 100), display=display.none)

// Series colors: gated by state, only render during OB/OS
color obCoreColSer  = (showZones and isOverbought and withinHistory) ? obCoreColOn  : offCol
color obMidColSer   = (showZones and isOverbought and withinHistory) ? obMidColOn   : offCol
color obOuterColSer = (showZones and isOverbought and withinHistory) ? obOuterColOn : offCol
color osCoreColSer  = (showZones and isOversold   and withinHistory) ? osCoreColOn  : offCol
color osMidColSer   = (showZones and isOversold   and withinHistory) ? osMidColOn   : offCol
color osOuterColSer = (showZones and isOversold   and withinHistory) ? osOuterColOn : offCol

// Fills: each between two adjacent boundary plots.
// Layers drawn in order outer -> mid -> core so denser layer paints on top.
fill(p_envU, p_obB1, color=obCoreColSer,  title="OB core layer")
fill(p_obB1, p_obB2, color=obMidColSer,   title="OB mid layer")
fill(p_obB2, p_obB3, color=obOuterColSer, title="OB outer layer")

fill(p_envL, p_osB1, color=osCoreColSer,  title="OS core layer")
fill(p_osB1, p_osB2, color=osMidColSer,   title="OS mid layer")
fill(p_osB2, p_osB3, color=osOuterColSer, title="OS outer layer")

// =============== OB/OS Mega-Phase Labels: one per merged phase ===============
//
// Text labels "Overbought" / "Oversold" are drawn once per merged phase
// using the same merge-with-gap-tolerance logic. Labels appear only when
// a phase finalizes (after GAP_TOLERANCE bars of inactivity).

const int GAP_TOLERANCE = 5

var bool  obActive  = false
var int   obStart   = na
var int   obLastAct = na
var int   obGap     = 0
var float obMaxEnvU = na    // running max of envU across the phase (zone top)

var bool  osActive  = false
var int   osStart   = na
var int   osLastAct = na
var int   osGap     = 0
var float osMinEnvL = na    // running min of envL across the phase (zone bottom)

if withinHistory and showLabels and not na(atrZone) and barstate.isconfirmed

    // --- Overbought phase tracker ---
    if isOverbought
        if not obActive
            obActive  := true
            obStart   := bar_index
            obMaxEnvU := envU
        else
            obMaxEnvU := na(obMaxEnvU) ? envU : (na(envU) ? obMaxEnvU : math.max(obMaxEnvU, envU))
        obLastAct := bar_index
        obGap     := 0
    else if obActive
        obGap := obGap + 1
        if obGap > GAP_TOLERANCE
            // Finalize: emit one centered label anchored just above zone top
            int labelX = math.round((obStart + obLastAct) / 2)
            float labelY = na(obMaxEnvU) ? high : (obMaxEnvU + atrZone * 0.25)
            label.new(labelX, labelY,
                 text="Overbought",
                 style=label.style_label_down,
                 textcolor=color.white,
                 color=color.new(overboughtColor, 0),
                 size=size.tiny,
                 xloc=xloc.bar_index)
            obActive  := false
            obStart   := na
            obLastAct := na
            obMaxEnvU := na
            obGap     := 0

    // --- Oversold phase tracker ---
    if isOversold
        if not osActive
            osActive  := true
            osStart   := bar_index
            osMinEnvL := envL
        else
            osMinEnvL := na(osMinEnvL) ? envL : (na(envL) ? osMinEnvL : math.min(osMinEnvL, envL))
        osLastAct := bar_index
        osGap     := 0
    else if osActive
        osGap := osGap + 1
        if osGap > GAP_TOLERANCE
            int labelX = math.round((osStart + osLastAct) / 2)
            float labelY = na(osMinEnvL) ? low : (osMinEnvL - atrZone * 0.25)
            label.new(labelX, labelY,
                 text="Oversold",
                 style=label.style_label_up,
                 textcolor=color.white,
                 color=color.new(oversoldColor, 0),
                 size=size.tiny,
                 xloc=xloc.bar_index)
            osActive  := false
            osStart   := na
            osLastAct := na
            osMinEnvL := na
            osGap     := 0

// =============== MTF Pressure Panel ===============

string[] _higherAll = f_fillHigherTfStrings(timeframe.period)
string _tf1 = array.size(_higherAll) > 0 ? array.get(_higherAll, 0) : ""
string _tf2 = array.size(_higherAll) > 1 ? array.get(_higherAll, 1) : ""
string _tf3 = array.size(_higherAll) > 2 ? array.get(_higherAll, 2) : ""

float _v1 = _tf1 == "" ? na : request.security(syminfo.tickerid, _tf1, pressureVal, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
float _v2 = _tf2 == "" ? na : request.security(syminfo.tickerid, _tf2, pressureVal, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
float _v3 = _tf3 == "" ? na : request.security(syminfo.tickerid, _tf3, pressureVal, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

var table mtfPanel = na

// 20-segment horizontal gauge using Unicode block characters
f_gaugeLine(float _val) =>
    string _out = ""
    if na(_val)
        _out := "──────────────"
    else
        float S = f_clamp(_val, 0.0, 100.0)
        int filled = int(math.round(S / (100.0 / 14.0)))
        filled := f_clamp(filled, 0, 14)
        for i = 0 to 13
            if i == filled or (filled == 14 and i == 13)
                _out := _out + "◉"
            else if i < filled
                _out := _out + "━"
            else
                _out := _out + "─"
    _out

f_panelTextSize() =>
    panelSizeInput == "Compact" ? size.small : panelSizeInput == "Large" ? size.large : size.normal

f_gaugeColor(float _val) =>
    if na(_val)
        color.new(TEXT_SECONDARY, 30)
    else
        float S = f_clamp(_val, 0.0, 100.0)
        if S >= PRESSURE_OVERBOUGHT
            overboughtColor
        else if S <= PRESSURE_OVERSOLD
            oversoldColor
        else if S >= 75.0
            color.new(overboughtColor, 35)
        else if S <= 25.0
            color.new(oversoldColor, 35)
        else
            color.new(TEXT_PRIMARY, 30)

f_statePill(float _val) =>
    if na(_val)
        "  ·  "
    else
        float S = f_clamp(_val, 0.0, 100.0)
        if S >= PRESSURE_OVERBOUGHT
            " OB "
        else if S <= PRESSURE_OVERSOLD
            " OS "
        else if S >= 75.0
            " ▲  "
        else if S <= 25.0
            " ▼  "
        else
            "  ·  "

f_statePillBg(float _val) =>
    if na(_val)
        TRACK_BG
    else
        float S = f_clamp(_val, 0.0, 100.0)
        if S >= PRESSURE_OVERBOUGHT
            color.new(overboughtColor, 0)
        else if S <= PRESSURE_OVERSOLD
            color.new(oversoldColor, 0)
        else if S >= 75.0
            color.new(overboughtColor, 55)
        else if S <= 25.0
            color.new(oversoldColor, 55)
        else
            TRACK_BG

// Row data arrays
var string[] rowTf  = array.new_string(4, "")
var float[]  rowVal = array.new_float(4, na)

bool panelActive = showMtfPanelInput and not timeframe.ismonthly

if panelActive
    array.set(rowTf,  0, f_prettyTf(timeframe.period))
    array.set(rowVal, 0, na(pressureVal) ? na : f_clamp(pressureVal, 0.0, 100.0))

    array.set(rowTf,  1, _tf1 == "" ? "" : f_prettyTf(_tf1))
    array.set(rowVal, 1, na(_v1) ? na : f_clamp(_v1, 0.0, 100.0))

    array.set(rowTf,  2, _tf2 == "" ? "" : f_prettyTf(_tf2))
    array.set(rowVal, 2, na(_v2) ? na : f_clamp(_v2, 0.0, 100.0))

    array.set(rowTf,  3, _tf3 == "" ? "" : f_prettyTf(_tf3))
    array.set(rowVal, 3, na(_v3) ? na : f_clamp(_v3, 0.0, 100.0))

    // Count how many TF rows are actually populated (non-empty label)
    int activeRows = 0
    for idx = 0 to 3
        if array.get(rowTf, idx) != ""
            activeRows := activeRows + 1

    // Total table rows: 1 header + 1 separator + N data rows + 1 footer
    int totalRows = 3 + activeRows

    var int prevTotalRows = 0
    if na(mtfPanel) or totalRows != prevTotalRows
        if not na(mtfPanel)
            table.delete(mtfPanel)
        mtfPanel := table.new(position.top_right, 4, totalRows, border_width=0)
        prevTotalRows := totalRows

    if barstate.islast
        // Header row
        table.cell(mtfPanel, 0, 0, " OB/OS ",   text_color=TEXT_PRIMARY,   bgcolor=color.new(PANEL_BG, 0),  text_halign=text.align_left,   text_size=f_panelTextSize())
        table.cell(mtfPanel, 1, 0, " MULTI-TF ", text_color=color.new(TEXT_SECONDARY, 0), bgcolor=color.new(PANEL_BG, 0), text_halign=text.align_center, text_size=f_panelTextSize())
        table.cell(mtfPanel, 2, 0, " ",           text_color=TEXT_PRIMARY,   bgcolor=color.new(PANEL_BG, 0),  text_size=f_panelTextSize())
        table.cell(mtfPanel, 3, 0, " ",           text_color=TEXT_PRIMARY,   bgcolor=color.new(PANEL_BG, 0),  text_size=f_panelTextSize())

        // Separator row
        table.cell(mtfPanel, 0, 1, "",  bgcolor=PANEL_BORDER, text_size=size.tiny)
        table.cell(mtfPanel, 1, 1, "",  bgcolor=PANEL_BORDER, text_size=size.tiny)
        table.cell(mtfPanel, 2, 1, "",  bgcolor=PANEL_BORDER, text_size=size.tiny)
        table.cell(mtfPanel, 3, 1, "",  bgcolor=PANEL_BORDER, text_size=size.tiny)

        // Data rows — only render populated ones
        int rowCursor = 2
        for idx = 0 to 3
            string _tf  = array.get(rowTf,  idx)
            float  _val = array.get(rowVal, idx)

            if _tf != ""
                color  tfBg    = idx == 0 ? color.new(PANEL_BG, 0) : color.new(PANEL_BG, 15)
                string tfMark  = idx == 0 ? "● " : "  "
                table.cell(mtfPanel, 0, rowCursor, tfMark + _tf + " ",
                     text_color=TEXT_PRIMARY,
                     bgcolor=tfBg,
                     text_halign=text.align_left,
                     text_size=f_panelTextSize())

                string _gauge = f_gaugeLine(_val)
                color  _gCol  = f_gaugeColor(_val)
                table.cell(mtfPanel, 1, rowCursor, _gauge,
                     text_color=_gCol,
                     bgcolor=tfBg,
                     text_halign=text.align_left,
                     text_size=f_panelTextSize())

                string _txt = na(_val) ? " - " : (" " + str.tostring(math.round(_val)) + " ")
                color  _numCol = na(_val) ? color.new(TEXT_SECONDARY, 30) : TEXT_PRIMARY
                table.cell(mtfPanel, 2, rowCursor, _txt,
                     text_color=_numCol,
                     bgcolor=tfBg,
                     text_halign=text.align_right,
                     text_size=f_panelTextSize())

                table.cell(mtfPanel, 3, rowCursor, f_statePill(_val),
                     text_color=color.white,
                     bgcolor=f_statePillBg(_val),
                     text_halign=text.align_center,
                     text_size=f_panelTextSize())
                rowCursor := rowCursor + 1

        // Footer scale hint — uses the last row after data rows
        int footerRow = rowCursor
        table.cell(mtfPanel, 0, footerRow, " 0", text_color=color.new(TEXT_SECONDARY, 10), bgcolor=color.new(PANEL_BG, 0), text_halign=text.align_left,   text_size=size.tiny)
        table.cell(mtfPanel, 1, footerRow, "50", text_color=color.new(TEXT_SECONDARY, 10), bgcolor=color.new(PANEL_BG, 0), text_halign=text.align_center, text_size=size.tiny)
        table.cell(mtfPanel, 2, footerRow, "100", text_color=color.new(TEXT_SECONDARY, 10), bgcolor=color.new(PANEL_BG, 0), text_halign=text.align_right,  text_size=size.tiny)
        table.cell(mtfPanel, 3, footerRow, " ",  text_color=color.new(TEXT_SECONDARY, 10), bgcolor=color.new(PANEL_BG, 0), text_size=size.tiny)
else
    if not na(mtfPanel)
        table.clear(mtfPanel, 0, 0)

// =============== Alerts ===============
alertcondition(obOnset, title="Overbought Entry", message="Overbought entry on {{ticker}}")
alertcondition(osOnset, title="Oversold Entry",   message="Oversold entry on {{ticker}}")
````
