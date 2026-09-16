<!-- tradingview-pine-id: PUB;6d80acadeb354fdaa969246d47539f6e -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Squeeze Regime Map [BSL]

Source: https://www.tradingview.com/script/7X4tUoMG-Squeeze-Regime-Map-BSL/

## Description

Squeeze Regime Map classifies volatility contraction, confirmed release and
directional expansion as explicit states. It answers “what volatility regime
is the current chart in?”, not “what trade should I take?”

This is an original BarState Labs implementation built from an independent
written specification. It does not reproduce another publication's formula,
defaults, interface, chart grammar or source code.

HOW IT WORKS

Normalized volatility is Wilder ATR divided by close and expressed as a
percentage:

`nATR = RMA(True Range, ATR length) / close × 100`

The current nATR is ranked inside the latest complete rolling window using an
inclusive percentile:

`VOL PCTL = 100 × count(window values <= current nATR) / window size`

Inclusive ties are deliberate. The implementation uses this explicit bounded
definition rather than relying on an opaque rank function.

Directional impulse is displacement over the selected momentum length,
normalized by current ATR and then EMA-smoothed:

`impulse = EMA((close - close[momentum length]) / ATR, smoothing)`

Impulse labels the direction of a confirmed release only when its magnitude is
at least the configured minimum. A weak release is recorded as unresolved
instead of being forced up or down.

STATE MACHINE

- Compression begins when VOL PCTL is at or below the compression-entry level.
- Compression persists until the separate release threshold is reached. This
  hysteresis prevents repeated threshold chatter.
- The first qualified exit is a one-bar Release Up or Release Down state and a
  one-bar +1 or -1 machine-readable pulse.
- A weak exit returns to Neutral and increments the unresolved ledger.
- On the next bar, a directional release becomes Expansion only when volatility
  reaches the expansion threshold and impulse keeps the same qualified
  direction.
- Expansion persists while volatility remains above the release threshold and
  direction agrees. Otherwise the state returns to Neutral.
- A new compression always takes transition precedence.

The default thresholds are 20 / 40 / 70 percentile. They must satisfy
`compression < release <= expansion`; an invalid order renders `CONFIG ERROR`
and freezes committed output until corrected.

CONFIRMED-BAR BEHAVIOR

State, duration, release plots, diagnostics and alert pulses commit only on
confirmed bars. On an open realtime bar, the panel says `OPEN BAR — HELD` and
retains the previous confirmed values. Historical, elapsed realtime and Bar
Replay bars use the same transition order.

This does not prevent upstream exchange or broker feed corrections from
changing rebuilt history after reload. The script makes no external data
requests and uses only the current chart symbol and timeframe.

OUTPUTS

The pane contains:

- volatility percentile and declared threshold guides;
- a visually clipped impulse histogram;
- optional confirmed regime backgrounds;
- optional confirmed release markers;
- Compact and Full evidence panels with state, duration, normalized metrics,
  release counts, unresolved events and readiness.

Hidden machine-readable plots expose:

- Regime code: -3, -2, 0, 1, 2 or 3;
- Compression score: 100 minus VOL PCTL;
- Confirmed release: +1, -1 or 0.

The Confirmed release plot can be selected directly as Signal Audit Lab's
Event source with the Signed pulse decoder. In the validation run, BSL-002's
18 up and 19 down releases matched BSL-001's 18 long and 19 short accepted
events exactly.

ALERTS

Four alert conditions are provided:

- Confirmed volatility release up;
- Confirmed volatility release down;
- Confirmed directional expansion up;
- Confirmed directional expansion down.

Release alerts use the same one-bar booleans as the exported pulse. Expansion
alerts fire only on entry into expansion.

LIMITATIONS

- This is a regime classifier, not a forecast, entry/exit system or strategy.
- A release direction is a normalized momentum label, not evidence of future
  return.
- Percentile and state depend on the loaded symbol, timeframe, feed, history
  and settings.
- Warm-up requires a complete percentile window and valid momentum history.
- The maximum 500-value percentile window is bounded but intentionally more
  expensive than the default 126-value window.
- No optimization, multi-symbol scan, multi-timeframe request, order model,
  position sizing or profitability claim is included.

VALIDATION

The release candidate passed 14 deterministic reference tests, a 14/14 live
Pine harness, BTCUSDT/AAPL × 1D/1H runtime checks, exact reload parity,
realtime and replay gates, valid/invalid threshold boundaries, four alert
conditions, 390 px rendering, BSL-001 signed-source integration and a 32,137
execution Profiler run at the maximum 500-bar window.

ORIGINALITY AND SOURCE

Category demand was selected from a dated metadata corpus. No protected,
invite-only or closed source was accessed, and no source from a compared open
publication was imported. The script uses standard true-range, Wilder RMA,
percentile-count and EMA calculations and is released under MPL 2.0.

CHANGELOG

v1.0.0

- Initial open-source release candidate.
- Explicit compression, release and expansion state machine with hysteresis.
- Inclusive rolling volatility percentile and normalized directional impulse.
- Confirmed +1 / -1 release export for Signal Audit Lab.
- Compact/Full evidence panels, four alerts and visible limitations.

---

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// © BarState Labs
//@version=6
indicator("Squeeze Regime Map [BSL]", shorttitle = "BSL Regime Map", overlay = false, max_bars_back = 600)

// ─────────────────────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────────────────────
string GROUP_VOL = "01 · Rank volatility"
string GROUP_STATE = "02 · Define regimes"
string GROUP_DIRECTION = "03 · Qualify direction"
string GROUP_DISPLAY = "04 · Display"

int trLength = input.int(14, "ATR length", minval = 2, maxval = 100, group = GROUP_VOL,
     tooltip = "The script divides Wilder ATR by price before ranking it. The default uses 14 bars.")
int percentileWindow = input.int(126, "Percentile lookback, bars", minval = 20, maxval = 500, group = GROUP_VOL,
     tooltip = "The 126-bar default is about six months of daily data. Shorter windows respond sooner; longer windows change more slowly.")

float compressionEntry = input.float(20.0, "Enter compression at or below", minval = 1.0, maxval = 60.0, step = 1.0, group = GROUP_STATE,
     tooltip = "20 means normalized volatility ranks in the lowest fifth of the lookback window.")
float releaseThreshold = input.float(40.0, "Confirm release at or above", minval = 2.0, maxval = 85.0, step = 1.0, group = GROUP_STATE,
     tooltip = "Release waits for the 40th percentile after compression. The gap between thresholds prevents repeated switching near one level.")
float expansionThreshold = input.float(70.0, "Confirm expansion at or above", minval = 2.0, maxval = 99.0, step = 1.0, group = GROUP_STATE,
     tooltip = "Expansion needs a volatility rank of at least 70 and a qualified impulse.")

int momentumLength = input.int(20, "Impulse lookback, bars", minval = 2, maxval = 200, group = GROUP_DIRECTION)
int momentumSmoothing = input.int(3, "Impulse smoothing", minval = 1, maxval = 50, group = GROUP_DIRECTION)
float minimumImpulse = input.float(0.25, "Minimum release impulse, ATR", minval = 0.0, maxval = 5.0, step = 0.05, group = GROUP_DIRECTION,
     tooltip = "A release needs at least 0.25 ATR of smoothed directional displacement. Weaker exits stay visible as unresolved instead of receiving a forced direction.")

string panelDensity = input.string("Compact", "Panel detail", options = ["Compact", "Full"], group = GROUP_DISPLAY,
     tooltip = "Compact shows the current state and core metrics. Full adds thresholds, durations, window settings and unresolved-release detail.")
bool showBackground = input.bool(true, "Show regime shading", group = GROUP_DISPLAY)
bool showReleaseMarkers = input.bool(true, "Show confirmed release markers", group = GROUP_DISPLAY)

// ─────────────────────────────────────────────────────────────────────────────
// Palette and helpers
// ─────────────────────────────────────────────────────────────────────────────
color COLOR_BG = color.rgb(11, 14, 13)
color COLOR_TEXT = color.rgb(242, 239, 232)
color COLOR_MUTED = color.rgb(156, 161, 154)
color COLOR_GREEN = color.rgb(82, 211, 151)
color COLOR_RED = color.rgb(239, 107, 107)
color COLOR_AMBER = color.rgb(235, 184, 87)
color COLOR_BLUE = color.rgb(104, 167, 255)

f_direction(float impulse, float threshold) =>
    impulse >= threshold ? 1 : impulse <= -threshold ? -1 : 0

f_state_name(int code, bool ready, bool valid) =>
    string name = not valid ? "CONFIG ERROR" : not ready ? "WARMUP" : "NEUTRAL"
    if valid and ready
        name := switch code
            1 => "COMPRESSION"
            2 => "RELEASE UP"
            -2 => "RELEASE DOWN"
            3 => "EXPANSION UP"
            -3 => "EXPANSION DOWN"
            => "NEUTRAL"
    name

f_state_color(int code, bool ready, bool valid) =>
    color result = not valid ? COLOR_RED : not ready ? COLOR_AMBER : COLOR_MUTED
    if valid and ready
        result := switch code
            1 => COLOR_AMBER
            2 => COLOR_GREEN
            -2 => COLOR_RED
            3 => COLOR_GREEN
            -3 => COLOR_RED
            => COLOR_MUTED
    result

f_number(float value, string formatString) =>
    na(value) ? "N/A" : str.tostring(value, formatString)

f_metric(float value, string formatString, string suffix) =>
    na(value) ? "N/A" : str.tostring(value, formatString) + suffix

f_inclusive_percentile_rank(array<float> values, int index) =>
    int length = array.size(values)
    float current = array.get(values, index)
    int atOrBelow = 0
    if length > 0
        for sampleIndex = 0 to length - 1
            atOrBelow += array.get(values, sampleIndex) <= current ? 1 : 0
    length > 0 ? 100.0 * atOrBelow / length : na

// ─────────────────────────────────────────────────────────────────────────────
// Volatility and impulse
// ─────────────────────────────────────────────────────────────────────────────
bool configValid = compressionEntry < releaseThreshold and releaseThreshold <= expansionThreshold
float atr = ta.atr(trLength)
float normalizedAtr = close != 0.0 ? atr / close * 100.0 : na
float rawImpulse = not na(atr) and atr != 0.0 ? (close - close[momentumLength]) / atr : na
float impulse = ta.ema(rawImpulse, momentumSmoothing)

var array<float> volatilityWindow = array.new<float>()
if not na(normalizedAtr)
    array.push(volatilityWindow, normalizedAtr)
    if array.size(volatilityWindow) > percentileWindow
        array.shift(volatilityWindow)

bool windowReady = array.size(volatilityWindow) == percentileWindow
float volatilityPercentile = windowReady ?
     f_inclusive_percentile_rank(volatilityWindow, array.size(volatilityWindow) - 1) : na
bool calculationReady = windowReady and not na(impulse)

// ─────────────────────────────────────────────────────────────────────────────
// Confirmed state machine
// ─────────────────────────────────────────────────────────────────────────────
var int regime = 0
var int stateDuration = 0
var int compressionDuration = 0
var int lastCompressionDuration = 0
var int expansionDuration = 0
var int releaseUpCount = 0
var int releaseDownCount = 0
var int unresolvedReleaseCount = 0
var float confirmedVolatilityPercentile = na
var float confirmedNormalizedAtr = na
var float confirmedImpulse = na

int releasePulse = 0
int expansionEntry = 0

if barstate.isconfirmed
    if configValid and calculationReady
        int previousRegime = regime
        int direction = f_direction(impulse, minimumImpulse)
        int nextRegime = 0

        if volatilityPercentile <= compressionEntry
            nextRegime := 1
        else if regime == 1 and volatilityPercentile < releaseThreshold
            nextRegime := 1
        else if regime == 1
            if direction > 0
                nextRegime := 2
                releasePulse := 1
                releaseUpCount += 1
            else if direction < 0
                nextRegime := -2
                releasePulse := -1
                releaseDownCount += 1
            else
                nextRegime := 0
                unresolvedReleaseCount += 1
        else if math.abs(regime) == 2
            int previousDirection = regime > 0 ? 1 : -1
            if volatilityPercentile >= expansionThreshold and direction == previousDirection
                nextRegime := 3 * previousDirection
                expansionEntry := previousDirection
            else
                nextRegime := 0
        else if math.abs(regime) == 3
            int previousDirection = regime > 0 ? 1 : -1
            nextRegime := volatilityPercentile >= releaseThreshold and direction == previousDirection ? 3 * previousDirection : 0
        else
            nextRegime := 0

        regime := nextRegime
        stateDuration := regime == previousRegime ? stateDuration + 1 : 1

        if regime == 1
            compressionDuration := previousRegime == 1 ? compressionDuration + 1 : 1
        else
            if previousRegime == 1
                lastCompressionDuration := compressionDuration
            compressionDuration := 0

        if math.abs(regime) == 3
            bool sameExpansion = math.abs(previousRegime) == 3 and (previousRegime > 0) == (regime > 0)
            expansionDuration := sameExpansion ? expansionDuration + 1 : 1
        else
            expansionDuration := 0

        confirmedVolatilityPercentile := volatilityPercentile
        confirmedNormalizedAtr := normalizedAtr
        confirmedImpulse := impulse
    else if configValid and not calculationReady
        regime := 0
        stateDuration := 0
        compressionDuration := 0
        expansionDuration := 0

bool releaseUp = releasePulse == 1
bool releaseDown = releasePulse == -1
bool expansionUp = expansionEntry == 1
bool expansionDown = expansionEntry == -1
float compressionScore = na(confirmedVolatilityPercentile) ? na : 100.0 - confirmedVolatilityPercentile
float visualImpulse = na(confirmedImpulse) ? na : math.max(-5.0, math.min(5.0, confirmedImpulse)) * 20.0

// ─────────────────────────────────────────────────────────────────────────────
// Visual and machine-readable outputs
// ─────────────────────────────────────────────────────────────────────────────
color stateColor = f_state_color(regime, calculationReady, configValid)
color regimeBackground = regime == 1 ? color.new(COLOR_AMBER, 85) : regime > 1 ? color.new(COLOR_GREEN, 88) : regime < -1 ? color.new(COLOR_RED, 88) : na

plot(confirmedVolatilityPercentile, "Volatility percentile", color = COLOR_BLUE, linewidth = 2)
plot(visualImpulse, "Impulse ×20 (visual only)", style = plot.style_histogram, histbase = 0.0, color = confirmedImpulse >= minimumImpulse ? color.new(COLOR_GREEN, 15) : confirmedImpulse <= -minimumImpulse ? color.new(COLOR_RED, 15) : color.new(COLOR_MUTED, 35))
plot(compressionEntry, "Compression entry", color = color.new(COLOR_AMBER, 25), linewidth = 1)
plot(releaseThreshold, "Release threshold", color = color.new(COLOR_TEXT, 55), linewidth = 1)
plot(expansionThreshold, "Expansion threshold", color = color.new(COLOR_GREEN, 45), linewidth = 1)
hline(0.0, "Impulse zero", color = color.new(COLOR_MUTED, 70))
hline(100.0, "Percentile ceiling", color = color.new(COLOR_MUTED, 80))
bgcolor(showBackground ? regimeBackground : na, title = "Confirmed regime background")

plotshape(showReleaseMarkers and releaseUp, title = "Release up marker", style = shape.triangleup, location = location.bottom, color = COLOR_GREEN, size = size.tiny, text = "R")
plotshape(showReleaseMarkers and releaseDown, title = "Release down marker", style = shape.triangledown, location = location.top, color = COLOR_RED, size = size.tiny, text = "R")

plot(float(regime), "Regime code", display = display.none)
plot(compressionScore, "Compression score", display = display.none)
plot(float(releasePulse), "Confirmed release", display = display.none)

alertcondition(releaseUp, "Confirmed volatility release up", "Squeeze Regime Map confirmed an upward volatility release.")
alertcondition(releaseDown, "Confirmed volatility release down", "Squeeze Regime Map confirmed a downward volatility release.")
alertcondition(expansionUp, "Confirmed directional expansion up", "Squeeze Regime Map entered confirmed upward expansion.")
alertcondition(expansionDown, "Confirmed directional expansion down", "Squeeze Regime Map entered confirmed downward expansion.")

// ─────────────────────────────────────────────────────────────────────────────
// Evidence panel
// ─────────────────────────────────────────────────────────────────────────────
int panelRows = panelDensity == "Full" ? 14 : 7
var table panel = table.new(position.top_right, 2, panelRows, bgcolor = color.new(COLOR_BG, 3), border_color = color.new(COLOR_MUTED, 65), border_width = 1)

if barstate.islast
    string stateName = f_state_name(regime, calculationReady, configValid)
    string readyName = not configValid ? "CONFIG ERROR" : not calculationReady ? "WARMUP" : barstate.isconfirmed ? "CONFIRMED" : "OPEN BAR · HELD"
    string directionName = na(confirmedImpulse) ? "N/A" : math.abs(confirmedImpulse) < minimumImpulse ? "UNRESOLVED" : confirmedImpulse > 0 ? "UP" : "DOWN"
    color readyColor = not configValid ? COLOR_RED : not calculationReady ? COLOR_AMBER : barstate.isconfirmed ? COLOR_GREEN : COLOR_AMBER

    table.cell(panel, 0, 0, "BSL / SQUEEZE REGIME", text_color = COLOR_TEXT, bgcolor = color.new(COLOR_BLUE, 70), text_size = size.small)
    table.cell(panel, 1, 0, syminfo.ticker + " · " + timeframe.period, text_color = COLOR_MUTED, bgcolor = color.new(COLOR_BLUE, 70), text_size = size.small)
    bool fullPanel = panelDensity == "Full"
    if fullPanel
        table.cell(panel, 0, 1, "STATE", text_color = COLOR_MUTED)
        table.cell(panel, 1, 1, stateName, text_color = stateColor)
        table.cell(panel, 0, 2, "DURATION", text_color = COLOR_MUTED)
        table.cell(panel, 1, 2, str.tostring(stateDuration), text_color = COLOR_TEXT)
        table.cell(panel, 0, 3, "VOL PCTL", text_color = COLOR_MUTED)
        table.cell(panel, 1, 3, f_metric(confirmedVolatilityPercentile, "#.0", "%"), text_color = COLOR_BLUE)
        table.cell(panel, 0, 4, "nATR", text_color = COLOR_MUTED)
        table.cell(panel, 1, 4, f_metric(confirmedNormalizedAtr, "#.000", "%"), text_color = COLOR_TEXT)
        table.cell(panel, 0, 5, "IMPULSE", text_color = COLOR_MUTED)
        table.cell(panel, 1, 5, f_number(confirmedImpulse, "#.00") + " / " + directionName, text_color = stateColor)
        table.cell(panel, 0, 6, "RELEASES", text_color = COLOR_MUTED)
        table.cell(panel, 1, 6, str.tostring(releaseUpCount) + " UP / " + str.tostring(releaseDownCount) + " DN", text_color = COLOR_TEXT)
        table.cell(panel, 0, 7, "UNRESOLVED", text_color = COLOR_MUTED)
        table.cell(panel, 1, 7, str.tostring(unresolvedReleaseCount), text_color = unresolvedReleaseCount > 0 ? COLOR_AMBER : COLOR_TEXT)
        table.cell(panel, 0, 8, "STATUS", text_color = COLOR_MUTED)
        table.cell(panel, 1, 8, readyName, text_color = readyColor)
        table.cell(panel, 0, 9, "THRESHOLDS", text_color = COLOR_MUTED)
        table.cell(panel, 1, 9, str.tostring(compressionEntry, "#") + " / " + str.tostring(releaseThreshold, "#") + " / " + str.tostring(expansionThreshold, "#"), text_color = COLOR_TEXT)
        table.cell(panel, 0, 10, "WINDOW", text_color = COLOR_MUTED)
        table.cell(panel, 1, 10, str.tostring(percentileWindow) + " / ATR " + str.tostring(trLength), text_color = COLOR_TEXT)
        table.cell(panel, 0, 11, "COMPRESSION", text_color = COLOR_MUTED)
        table.cell(panel, 1, 11, str.tostring(compressionDuration) + " NOW / " + str.tostring(lastCompressionDuration) + " LAST", text_color = COLOR_TEXT)
        table.cell(panel, 0, 12, "EXPANSION", text_color = COLOR_MUTED)
        table.cell(panel, 1, 12, str.tostring(expansionDuration) + " BARS", text_color = COLOR_TEXT)
    else
        table.cell(panel, 0, 1, "STATE · DURATION", text_color = COLOR_MUTED)
        table.cell(panel, 1, 1, stateName + " · " + str.tostring(stateDuration) + "B", text_color = stateColor)
        table.cell(panel, 0, 2, "VOL PCTL · nATR", text_color = COLOR_MUTED)
        table.cell(panel, 1, 2, f_metric(confirmedVolatilityPercentile, "#.0", "%") + " · " + f_metric(confirmedNormalizedAtr, "#.000", "%"), text_color = COLOR_BLUE)
        table.cell(panel, 0, 3, "IMPULSE", text_color = COLOR_MUTED)
        table.cell(panel, 1, 3, f_number(confirmedImpulse, "#.00") + " / " + directionName, text_color = stateColor)
        table.cell(panel, 0, 4, "RELEASES", text_color = COLOR_MUTED)
        table.cell(panel, 1, 4, str.tostring(releaseUpCount) + " UP / " + str.tostring(releaseDownCount) + " DN", text_color = COLOR_TEXT)
        table.cell(panel, 0, 5, "UNRES. · STATUS", text_color = COLOR_MUTED)
        table.cell(panel, 1, 5, str.tostring(unresolvedReleaseCount) + " · " + readyName, text_color = readyColor)

    int footerRow = fullPanel ? 13 : 6
    table.cell(panel, 0, footerRow, "REGIME CLASSIFIER", text_color = COLOR_MUTED, bgcolor = color.new(COLOR_BG, 0), text_size = size.tiny)
    table.cell(panel, 1, footerRow, "NOT A TRADE SIGNAL", text_color = COLOR_AMBER, bgcolor = color.new(COLOR_BG, 0), text_size = size.tiny)
````
