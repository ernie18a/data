# Regime Transition Intelligence [AGPro Series]

- url: https://www.tradingview.com/script/TxkeLxQ1-Regime-Transition-Intelligence-AGPro-Series/
- type: indicator
- pine_id: PUB;d5731cba074b47fbbfcf43ef7271127c
- version: 4.0

## Description

[b]Regime Transition Intelligence [AGPro Series][/b]

Most regime scripts answer a single question: "what regime are we in right now?". Regime Transition Intelligence is designed to answer a different, more actionable set of questions: how long does this regime usually last, how close to its typical end is it, how likely is it to flip within the next N bars, and where does it historically go when it does flip. Instead of treating the current regime as a standalone snapshot, it builds a living, self-calibrating statistical profile of the symbol's own regime behavior and presents it in a compact on-chart dashboard.

The engine runs on three independent axes — Trend Strength (Kaufman Efficiency Ratio + ADX), Chop Risk (Choppiness Index + inverse trend), and Volatility (ATR% normalized over a user-defined lookback). Each axis is classified as LOW / MID / HIGH, either with fixed 33/67 thresholds or with an adaptive percentile rank engine that learns the symbol's own statistical envelope over a rolling window. The three axes are then combined into a discrete regime state: TREND, MIXED, or RANGE / CHOP.


🟦 Overview / What it does

Regime Transition Intelligence is a single-pane overlay indicator that continuously classifies the market into one of three regimes and then layers a full transition intelligence stack on top of that classification:
- A per-regime dwell-time distribution learned from the chart's own completed regime blocks
- A Bayesian-style flip probability that answers "how likely is a regime change within the next N bars, given the current age"
- A 3x3 transition matrix that ranks the most likely next regime with a secondary fallback
- A fatigue score comparing the current regime's age to its historical mean (FRESH / MATURE / EXTENDED)
- A confidence decay tracker that shows whether conviction is BUILDING, STABLE, or FADING within the current regime block
- A compact history ribbon showing the last completed regime blocks with their durations
- Higher-timeframe alignment with a SYNC / DIV indicator and a live beacon at the right edge of the chart

All of this is delivered inside a single configurable dashboard, a directional transition marker layer on the chart, optional regime tint and candle coloring, and a right-edge beacon summarizing the current state.


🟣 Unique Edge / Why it is not a basic mashup

Standard regime indicators report the current state and stop there. Regime Transition Intelligence adds six distinct statistical layers that together form a transition-aware view:

1. Dwell Time Statistics — the script stores every completed regime block in a rolling array (configurable depth) and continuously updates running mean, running variance, running max, and running count per regime code. Statistics are only shown after a minimum number of blocks per regime have been collected, so the user always knows when the sample size is still too small.

2. Exponential Hazard Flip Probability — the baseline flip probability uses P(flip within H bars) = 1 - exp(-H / mean), a standard survival-analysis construction assuming constant hazard. The result is then fatigue-adjusted: if the current age is far above the historical mean, the probability is boosted; if the regime has just started, the probability is damped. The final value is capped at 95% to avoid certainty claims.

3. Transition Matrix — a 3x3 counter records every observed regime transition and is read as a conditional distribution: "given the current regime ends, which regime is it most likely to move to, and what is the runner-up". Both the top candidate and the secondary candidate are displayed with their percentages.

4. Fatigue Score — the ratio of the current age to the historical mean is bucketed into three zones (FRESH, MATURE, EXTENDED) using user-configurable thresholds. It tells the user whether the current regime is still in its early lifecycle or already past its typical end.

5. Confidence Decay Tracker — conviction in the current regime is sampled at the start of each new block and compared to the current conviction. The delta is classified as BUILDING, STABLE, or FADING, which gives an early read on whether the regime is strengthening or losing its grip.

6. History Ribbon — the last N completed regime blocks are compressed into a single compact line such as "C2·M4·C8·M1·M7*", where letters are regime codes and numbers are bar counts, with the current block marked by an asterisk. It gives immediate context on recent regime rhythm at a single glance.

None of these layers is a repackaged classic indicator. They are built on top of a trend / chop / volatility engine but deliver information that is categorically different from a simple "regime yes / no" readout.


🟢 Methodology / Conceptual data flow

1. Feature extraction. Kaufman Efficiency Ratio (net move over lookback divided by summed absolute moves) and normalized ADX are combined into a trend score. The Choppiness Index is normalized against its operating range and blended with inverse trend to produce a chop score. ATR as a percentage of price is normalized against its own lookback min/max to produce a volatility score.

2. Classification. Each score is mapped to LOW / MID / HIGH using either fixed thresholds (Static mode) or percentile rank over an adaptive lookback (Adaptive mode). The three bands are combined into a discrete regime state: TREND when trend is HIGH and chop is LOW, RANGE / CHOP when chop is HIGH, and MIXED otherwise.

3. Block tracking. Every time the regime state changes on a confirmed bar, the previous block is closed: its duration is pushed to a rolling history array and added to the running sum / sum-of-squares / count / max for its regime code. When the history array exceeds its configured depth, the oldest block is popped and its contribution is subtracted from the running totals, which keeps the statistics adaptive and non-expanding.

4. Transition matrix update. When a block closes into a new regime, the 3x3 counter is incremented at the corresponding cell, and the row total is incremented. The conditional distribution for the current regime is read from its row at display time.

5. Statistical outputs. Mean dwell, fatigue ratio, exponential-hazard flip probability, fatigue-adjusted flip probability, top and secondary next regimes, and confidence delta are all derived from the running state and rendered into the dashboard.

6. Higher-timeframe alignment. The same three-axis engine is run on a user-selected higher timeframe via request.security and compared against the current-timeframe regime; the result appears as SYNC or DIV in the header and as an optional HTF row in the dashboard.


🔔 Signals & Alerts / Interpretation

Regime Transition Intelligence is a state-mapping and statistical context tool rather than a directional buy / sell engine. The main on-chart events are:
- Regime Shift — fires when the regime state changes on a confirmed bar
- High Flip Probability — fires when the fatigue-adjusted flip probability crosses a high threshold
- Regime Fatigue Extended — fires on the transition into the EXTENDED fatigue zone
- Confidence Fading — fires on the transition into the FADING confidence zone

How to read the panel:
- Summary + Age tells the user which regime is active and how long it has been active.
- Dwell Context compares the current age to the historical mean in the form "age / mean · % of typical lifespan".
- Fatigue summarizes that comparison as FRESH, MATURE, or EXTENDED.
- Flip Probability reports the statistical odds of a regime change within the user-defined horizon.
- Next Likely names the most probable next regime with its percentage and a secondary fallback.
- Confidence and Conf Decay together tell the user whether the current read is reliable and whether conviction is rising or fading.
- History gives quick situational awareness of recent regime rhythm.

None of these rows should be interpreted as a trade instruction. They are a context layer meant to be combined with the user's own structure and entry framework.


🎛️ Key Inputs

Regime Engine Core — Trend Persistence Length, DMI/ADX Length, Chop Length, ATR Length, Volatility Normalize Lookback.
Adaptive Boundaries — Band Classification Mode (Adaptive / Static), Adaptive Lookback, Adaptive Low / High Percentile.
Transition Intelligence — Regime History Depth, Flip Probability Horizon, Min Blocks Before Stats Activate, Fatigue Fresh / Extended thresholds.
HUD — Display Mode (PRO / MINIMAL), HUD Position, Text Size, transparency controls, individual row toggles, history ribbon length.
Add-ons — Chart Regime Tint, Regime Candle Coloring (Soft / Strong), HTF Peek Timeframe, Transition Markers (location, cooldown, stagger, size, ATR offset), Live Regime Beacon (position, size, stats toggle).


🧭 How to use

1. Add the script to any chart and timeframe. The engine is tuned to work from 15m up to Daily; very low timeframes on illiquid instruments can produce unstable regime blocks and are not the intended use case.

2. Give the script time to collect blocks. Statistics stay in N/A until the configured minimum number of completed blocks per regime has accumulated. On a fresh chart or an illiquid instrument this is expected behavior, not a bug.

3. Read the dashboard top-down. Start with the three axis rows to understand the current market shape, then move to Summary and Age to see what is active and for how long, then use Dwell / Fatigue / Flip / Next Likely to place the current regime inside its historical distribution, and finally use Conf Decay and HTF to sanity-check reliability and alignment.

4. Treat EXTENDED fatigue and high flip probability as context, not as a reversal signal. Regimes can remain in the EXTENDED zone for a while before actually flipping; the statistical profile is descriptive, not deterministic.

5. Combine with structural context. The script does not know about support / resistance, order blocks, or news. It only knows about the symbol's own regime rhythm. Use it as a regime-aware filter on top of the user's existing framework.


⚠️ Limitations & Transparency

This is not a strategy and not a complete trading system. It does not predict price direction and does not generate buy or sell signals. All statistics are estimated from a rolling history of the chart's own regime blocks, so they are sensitive to the chosen engine parameters, the timeframe, and the symbol; different timeframes and different instruments will produce different statistical profiles, and that is by design.

The exponential-hazard flip probability assumes a constant hazard within the current regime, which is a simplification. Real-world regime durations are not perfectly memoryless and the fatigue multiplier is a heuristic correction, not a formal model. The probability is capped at 95% on purpose, because even a heavily aged regime cannot be considered a certainty and the script deliberately avoids certainty language.

The transition matrix is read as a conditional frequency over completed blocks; it is informative about the symbol's own past behavior and should not be interpreted as a forward-looking forecast. Very small samples produce unstable conditional probabilities, which is why stats stay in N/A until a minimum number of blocks is collected.

Regime classification itself reacts to confirmed bars and can change as new data arrives, which is expected for any regime filter. Users who prefer fully non-repainting alerts should rely on the barstate.isconfirmed-gated alert conditions provided.


📜 Risk Disclosure

Trading involves substantial risk of loss and is not suitable for every investor. Past performance is not indicative of future results. This indicator is provided for educational and analytical purposes only and should not be interpreted as financial advice, an investment recommendation or a solicitation to trade. Always combine multiple forms of analysis, manage position size responsibly, and never risk capital you cannot afford to lose.

## Source Code

````pine
// -------------------------------------------------
// Regime Transition Intelligence [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.4
//
// Regime Transition Intelligence evaluates trend persistence, chop pressure,
// volatility state, dwell-time behavior, regime fatigue, flip probability,
// transition history and higher-timeframe alignment, then turns it into a clear
// regime stance and a persistent transition-accuracy proof layer. Version 1.4
// adds duration-aware transition markers and a compact live-regime beacon. It is a
// chart-first market regime dashboard that shows whether the environment is
// trending, mixed or range-heavy - and what stance fits - without making
// directional promises. Built for market regime, trend vs range, chop and
// volatility-state analysis.
// -------------------------------------------------

//@version=6
indicator("Regime Transition Intelligence [AGPro Series]",
     shorttitle = "AG Pro RTI",
     overlay = true,
     max_labels_count = 220,
     max_lines_count = 40,
     max_boxes_count = 40)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
color headerBg      = color.rgb(37, 99, 235)
color headerText    = color.rgb(245, 247, 250)
color panelBg       = color.rgb(15, 23, 42)
color panelBorder   = color.rgb(51, 65, 85)
color panelLabelCol = color.rgb(148, 163, 184)
color panelValueCol = color.rgb(226, 232, 240)
color bullColor     = color.rgb(34, 197, 166)
color bearColor     = color.rgb(244, 114, 182)
color neutralColor  = color.rgb(245, 189, 92)
color accentColor   = color.rgb(129, 140, 248)
color coolColor     = color.rgb(56, 189, 248)
color darkText      = color.rgb(17, 24, 39)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupEngine = "Regime Engine"
int trendLength = input.int(20, "Trend Persistence Length", minval = 5, maxval = 120, group = groupEngine, tooltip = "Efficiency-ratio lookback used to estimate directional persistence.")
int adxLength = input.int(14, "DMI / ADX Length", minval = 5, maxval = 80, group = groupEngine, tooltip = "ADX length used as a secondary trend-strength component.")
int chopLength = input.int(14, "Chop Length", minval = 5, maxval = 80, group = groupEngine, tooltip = "Choppiness Index length used to estimate range pressure.")
int atrLength = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupEngine, tooltip = "ATR length used for volatility scoring, marker spacing, and beacon placement.")
int volatilityLookback = input.int(100, "Volatility Normalize Lookback", minval = 20, maxval = 400, group = groupEngine, tooltip = "Lookback used to normalize ATR percent into a 0-100 volatility state.")
string bandMode = input.string("Adaptive", "Band Classification Mode", options = ["Adaptive", "Static"], group = groupEngine, tooltip = "Adaptive uses percentile rank boundaries. Static uses fixed low, mid, and high score zones.")
int adaptiveLookback = input.int(200, "Adaptive Lookback", minval = 50, maxval = 800, group = groupEngine, tooltip = "Lookback used for adaptive percentile ranks.")
float adaptiveLowPct = input.float(33.0, "Adaptive Low Percentile", minval = 5.0, maxval = 45.0, step = 1.0, group = groupEngine, tooltip = "Lower adaptive boundary for low regime axis states.")
float adaptiveHighPct = input.float(67.0, "Adaptive High Percentile", minval = 55.0, maxval = 95.0, step = 1.0, group = groupEngine, tooltip = "Upper adaptive boundary for high regime axis states.")

string groupTransition = "Transition Intelligence"
int historyDepth = input.int(64, "Regime History Depth", minval = 8, maxval = 200, group = groupTransition, tooltip = "Maximum number of closed regime blocks retained for dwell and transition statistics.")
int flipHorizonBars = input.int(20, "Flip Probability Horizon", minval = 1, maxval = 200, group = groupTransition, tooltip = "Forward-looking bar window used by the statistical flip-risk model.")
int minBlocksForStats = input.int(3, "Min Blocks Before Stats Activate", minval = 1, maxval = 20, group = groupTransition, tooltip = "Statistics show limited context until this many closed blocks exist for the current regime.")
float fatigueFreshCap = input.float(0.40, "Fatigue Fresh Threshold", minval = 0.10, maxval = 0.80, step = 0.05, group = groupTransition, tooltip = "Age-to-mean ratio below this value is treated as a fresh regime.")
float fatigueExtendedCap = input.float(1.20, "Fatigue Extended Threshold", minval = 0.80, maxval = 2.50, step = 0.05, group = groupTransition, tooltip = "Age-to-mean ratio above this value is treated as an extended regime.")

string groupVisual = "Chart Visuals"
bool showTint = input.bool(true, "Show Regime Tint", group = groupVisual, tooltip = "Applies a subtle chart background tint based on the active regime.")
int tintTransparency = input.int(96, "Tint Transparency", minval = 82, maxval = 99, group = groupVisual, tooltip = "Transparency for the chart regime tint. Higher values are lighter.")
bool colorBars = input.bool(false, "Color Bars By Regime", group = groupVisual, tooltip = "Optionally colors candles by the active regime state.")
bool showTransitionMarkers = input.bool(true, "Show Transition Markers", group = groupVisual, tooltip = "Shows compact transition labels when the regime changes.")
int markerCooldownBars = input.int(24, "Marker Cooldown Bars", minval = 0, maxval = 200, group = groupVisual, tooltip = "Minimum bar spacing between transition labels.")
int minimumMarkerDwell = input.int(3, "Minimum Closed-Regime Bars", minval = 1, maxval = 50, group = groupVisual, tooltip = "Minimum completed-regime duration required before its transition receives a historical chart marker. Classification and statistics are not filtered.")
int maxMarkers = input.int(8, "Max Transition Markers", minval = 0, maxval = 40, group = groupVisual, tooltip = "Maximum visible transition labels retained on the chart.")
float markerOffsetAtr = input.float(0.50, "Marker Offset ATR", minval = 0.00, maxval = 4.00, step = 0.05, group = groupVisual, tooltip = "ATR-based vertical spacing used for transition labels.")
bool showBeacon = input.bool(true, "Show Live Regime Beacon", group = groupVisual, tooltip = "Shows a compact right-side beacon with current regime, confidence, dwell, and flip context.")
bool showBeaconStats = input.bool(true, "Beacon: Show Stats", group = groupVisual, tooltip = "Adds dwell and flip probability context to the live regime beacon.")
int beaconOffsetBars = input.int(4, "Beacon X Offset", minval = 0, maxval = 30, group = groupVisual, tooltip = "Bars projected to the right for the live regime beacon.")
float beaconOffsetAtr = input.float(0.65, "Beacon Y Offset ATR", minval = 0.00, maxval = 4.00, step = 0.05, group = groupVisual, tooltip = "ATR offset used to keep the beacon away from the current price label.")
string labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupVisual, tooltip = "Controls transition marker and beacon text size.")

string groupPanel = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = "Shows or hides the AG Pro regime panel.")
string panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = "Moves the AG Pro regime panel to the preferred chart location.")
string panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = groupPanel, tooltip = "Switches the panel theme while preserving the blue merged header row.")
string panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupPanel, tooltip = "Controls panel text size.")
bool showAxisRows = input.bool(true, "Show Axis Rows", group = groupPanel, tooltip = "Shows trend, chop, and volatility axis rows.")
bool showDwellRows = input.bool(true, "Show Dwell / Flip Rows", group = groupPanel, tooltip = "Shows dwell, fatigue, flip probability, and next-likely regime rows.")
bool showHistoryRow = input.bool(true, "Show History Row", group = groupPanel, tooltip = "Shows compact historical regime block sequence.")
bool showHTF = input.bool(true, "Show HTF Row", group = groupPanel, tooltip = "Shows higher-timeframe regime alignment inside the panel.")
string htfTimeframe = input.timeframe("D", "HTF Timeframe", group = groupPanel, tooltip = "Higher timeframe used for panel alignment context.")

string groupAlerts = "Alerts"
bool alertRegimeShift = input.bool(true, "Alert: Regime Shift", group = groupAlerts, tooltip = "Enables alerts when the active regime changes.")
bool alertHighFlip = input.bool(true, "Alert: High Flip Probability", group = groupAlerts, tooltip = "Enables alerts when the statistical flip probability becomes elevated.")
bool alertExtended = input.bool(true, "Alert: Extended Fatigue", group = groupAlerts, tooltip = "Enables alerts when the current regime moves into extended fatigue.")
bool alertFading = input.bool(true, "Alert: Confidence Fading", group = groupAlerts, tooltip = "Enables alerts when confidence fades during the current regime block.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_clamp01(float value) =>
    f_clamp(value, 0.0, 1.0)

f_text_on(color bg) =>
    float bright = (color.r(bg) * 299 + color.g(bg) * 587 + color.b(bg) * 114) / 1000
    bright >= 145 ? darkText : headerText

f_size(string sizeInput) =>
    switch sizeInput
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_panel_pos(string locationInput) =>
    switch locationInput
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_panel_bg() =>
    panelTheme == "Clean Light" ? color.rgb(245, 247, 250) : panelTheme == "Slate" ? color.rgb(30, 41, 59) : panelBg

f_panel_border() =>
    panelTheme == "Clean Light" ? color.rgb(148, 163, 184) : panelTheme == "Slate" ? color.rgb(71, 85, 105) : panelBorder

f_panel_label() =>
    panelTheme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value() =>
    panelTheme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(int row) =>
    bool evenRow = row % 2 == 0
    panelTheme == "Clean Light" ? (evenRow ? color.rgb(226, 232, 240) : color.rgb(245, 247, 250)) : panelTheme == "Slate" ? (evenRow ? color.rgb(37, 49, 70) : color.rgb(30, 41, 59)) : (evenRow ? color.rgb(20, 31, 52) : panelBg)

f_panel_row(table panelRef, int row, string leftText, string rightText, color rightColor, string fontSize) =>
    color rowBg = f_row_bg(row)
    table.cell(panelRef, 0, row, leftText, text_color = f_panel_label(), bgcolor = rowBg, text_size = f_size(fontSize), text_halign = text.align_left)
    table.cell(panelRef, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_size(fontSize), text_halign = text.align_right)

f_pct(float value) =>
    str.tostring(int(math.round(f_clamp01(value) * 100.0))) + "%"

f_score(float value) =>
    int(math.round(f_clamp01(value) * 100.0))

f_band_static(float value) =>
    value < 0.33 ? "LOW" : value < 0.66 ? "MID" : "HIGH"

f_band(float value, float rank) =>
    string staticBand = f_band_static(value)
    bandMode == "Static" or na(rank) ? staticBand : rank < adaptiveLowPct ? "LOW" : rank > adaptiveHighPct ? "HIGH" : "MID"

f_code(string regimeText) =>
    regimeText == "TREND" ? 0 : regimeText == "MIXED" ? 1 : 2

f_regime_name(int code) =>
    code == 0 ? "TREND" : code == 1 ? "MIXED" : "RANGE / CHOP"

f_regime_short(int code) =>
    code == 0 ? "T" : code == 1 ? "M" : "C"

f_regime_color(int code) =>
    code == 0 ? bullColor : code == 1 ? neutralColor : bearColor

f_summary_color(string regimeText) =>
    f_regime_color(f_code(regimeText))

f_axis_color(string axisName, string band) =>
    axisName == "Trend" ? (band == "HIGH" ? bullColor : band == "MID" ? neutralColor : bearColor) : axisName == "Chop" ? (band == "HIGH" ? bearColor : band == "MID" ? neutralColor : bullColor) : (band == "HIGH" ? accentColor : band == "MID" ? coolColor : panelLabelCol)

f_marker_y(bool topSide, float atrValue, int stagger) =>
    topSide ? high + atrValue * markerOffsetAtr * (1.0 + stagger * 0.55) : low - atrValue * markerOffsetAtr * (1.0 + stagger * 0.55)

// -------------------------------------------------
// Regime Engine
// -------------------------------------------------
float netMove = math.abs(close - close[trendLength])
float denMove = ta.sma(math.abs(close - close[1]), trendLength) * trendLength
float efficiency = denMove == 0.0 ? 0.0 : netMove / denMove
[_, _, adxValue] = ta.dmi(adxLength, adxLength)
float adxScore = f_clamp01(adxValue / 40.0)
float trendScore = f_clamp01(efficiency * 0.65 + adxScore * 0.35)
float trendRank = ta.percentrank(trendScore, adaptiveLookback)
string trendBand = f_band(trendScore, trendRank)

float trueRange = ta.tr(true)
float sumRange = ta.sma(trueRange, chopLength) * chopLength
float rangeHigh = ta.highest(high, chopLength)
float rangeLow = ta.lowest(low, chopLength)
float rangeSpan = math.max(rangeHigh - rangeLow, syminfo.mintick)
float chopRaw = 100.0 * math.log10(sumRange / rangeSpan) / math.log10(chopLength)
float chopNorm = f_clamp01((chopRaw - 38.0) / 24.0)
float chopScore = f_clamp01(chopNorm * 0.70 + (1.0 - trendScore) * 0.30)
float chopRank = ta.percentrank(chopScore, adaptiveLookback)
string chopBand = f_band(chopScore, chopRank)

float atrValue = ta.atr(atrLength)
float atrPct = close == 0.0 ? 0.0 : atrValue / close * 100.0
float atrMin = ta.lowest(atrPct, volatilityLookback)
float atrMax = ta.highest(atrPct, volatilityLookback)
float volScore = f_clamp01((atrPct - atrMin) / math.max(atrMax - atrMin, 0.000001))
float volRank = ta.percentrank(volScore, adaptiveLookback)
string volBand = f_band(volScore, volRank)

string summary = chopBand == "HIGH" ? "RANGE / CHOP" : trendBand == "HIGH" and chopBand == "LOW" ? "TREND" : "MIXED"
int summaryCode = f_code(summary)
float confidence = f_clamp01((math.abs(trendScore - 0.5) + math.abs(chopScore - 0.5) + math.abs(volScore - 0.5)) / 1.5)

// -------------------------------------------------
// HTF Regime
// -------------------------------------------------
[htfTrendScore, htfChopScore, htfVolScore] = request.security(syminfo.tickerid, htfTimeframe, [trendScore, chopScore, volScore])
[htfTrendRank, htfChopRank, htfVolRank] = request.security(syminfo.tickerid, htfTimeframe, [ta.percentrank(trendScore, adaptiveLookback), ta.percentrank(chopScore, adaptiveLookback), ta.percentrank(volScore, adaptiveLookback)])
string htfTrendBand = f_band(htfTrendScore, htfTrendRank)
string htfChopBand = f_band(htfChopScore, htfChopRank)
string htfVolBand = f_band(htfVolScore, htfVolRank)
string htfSummary = htfChopBand == "HIGH" ? "RANGE / CHOP" : htfTrendBand == "HIGH" and htfChopBand == "LOW" ? "TREND" : "MIXED"
bool htfSync = htfSummary == summary

// -------------------------------------------------
// Transition Statistics
// -------------------------------------------------
var array<int> histCode = array.new_int()
var array<int> histDur = array.new_int()
var array<float> sumDur = array.new_float(3, 0.0)
var array<float> sumSq = array.new_float(3, 0.0)
var array<int> cntDur = array.new_int(3, 0)
var array<int> transM = array.new_int(9, 0)
var array<int> fromCnt = array.new_int(3, 0)

// Transition-accuracy proof layer
var int proofTotal = 0
var int proofHit = 0

var int currentCode = summaryCode
var int currentAge = 0
var int lastClosedAge = 0
var float firstConfidence = na

bool regimeShift = barstate.isconfirmed and summaryCode != currentCode

if barstate.isconfirmed
    if na(firstConfidence)
        firstConfidence := confidence
    if regimeShift
        int closedCode = currentCode
        int closedAge = currentAge
        lastClosedAge := math.max(closedAge, 1)
        if closedAge > 0
            array.set(sumDur, closedCode, array.get(sumDur, closedCode) + closedAge)
            array.set(sumSq, closedCode, array.get(sumSq, closedCode) + closedAge * closedAge)
            array.set(cntDur, closedCode, array.get(cntDur, closedCode) + 1)
            array.push(histCode, closedCode)
            array.push(histDur, closedAge)
            while array.size(histCode) > historyDepth
                int oldCode = array.shift(histCode)
                int oldDur = array.shift(histDur)
                array.set(sumDur, oldCode, math.max(0.0, array.get(sumDur, oldCode) - oldDur))
                array.set(sumSq, oldCode, math.max(0.0, array.get(sumSq, oldCode) - oldDur * oldDur))
                array.set(cntDur, oldCode, math.max(0, array.get(cntDur, oldCode) - 1))
            int matrixIndex = closedCode * 3 + summaryCode
            array.set(transM, matrixIndex, array.get(transM, matrixIndex) + 1)
            array.set(fromCnt, closedCode, array.get(fromCnt, closedCode) + 1)
        currentCode := summaryCode
        currentAge := 1
        firstConfidence := confidence
    else
        currentAge += 1

int statCount = array.get(cntDur, currentCode)
float meanDur = statCount == 0 ? na : array.get(sumDur, currentCode) / statCount
bool hasStats = not na(meanDur) and statCount >= minBlocksForStats
float ageRatio = hasStats and meanDur > 0.0 ? currentAge / meanDur : na
string fatigueTag = not hasStats ? "N/A" : ageRatio < fatigueFreshCap ? "FRESH" : ageRatio < fatigueExtendedCap ? "MATURE" : "EXTENDED"
color fatigueCol = fatigueTag == "FRESH" ? bullColor : fatigueTag == "MATURE" ? neutralColor : fatigueTag == "EXTENDED" ? bearColor : panelLabelCol

float flipBase = hasStats and meanDur > 0.0 ? 1.0 - math.exp(-flipHorizonBars / math.max(meanDur, 1.0)) : na
float flipProb = na(flipBase) or na(ageRatio) ? na : math.min(0.95, flipBase * math.max(0.30, math.min(2.50, ageRatio)))
color flipCol = na(flipProb) ? panelLabelCol : flipProb >= 0.66 ? bearColor : flipProb >= 0.40 ? neutralColor : bullColor

int nextBestCode = currentCode == 0 ? 1 : 0
float nextBestProb = 0.0
int fromTotal = array.get(fromCnt, currentCode)
if fromTotal > 0
    for idx = 0 to 2
        if idx != currentCode
            float p = array.get(transM, currentCode * 3 + idx) / fromTotal
            if p > nextBestProb
                nextBestProb := p
                nextBestCode := idx
bool hasTransitionData = fromTotal >= minBlocksForStats

// Score the previous bar's "next likely" forecast against the actual new regime
if barstate.isconfirmed and regimeShift and hasTransitionData[1]
    proofTotal += 1
    if summaryCode == nextBestCode[1]
        proofHit += 1
float transitionHitRate = proofTotal > 0 ? 100.0 * proofHit / proofTotal : na

float confidenceDelta = na(firstConfidence) ? na : confidence - firstConfidence
string decayTag = na(confidenceDelta) ? "N/A" : confidenceDelta > 0.08 ? "BUILDING" : confidenceDelta < -0.08 ? "FADING" : "STABLE"
color decayCol = decayTag == "BUILDING" ? bullColor : decayTag == "FADING" ? bearColor : accentColor

// Regime stance (next-action)
bool highFlip = not na(flipProb) and flipProb >= 0.66
bool agingRegime = fatigueTag == "EXTENDED"
string regimeAction = summaryCode == 0 ? (agingRegime or highFlip ? "Trend Aging" : "Follow Trend") :
     summaryCode == 2 ? (agingRegime or highFlip ? "Breakout Watch" : "Fade Range Edges") :
     "Reduce / Wait"
color regimeActionColor = regimeAction == "Follow Trend" ? bullColor :
     regimeAction == "Fade Range Edges" ? accentColor :
     regimeAction == "Trend Aging" or regimeAction == "Breakout Watch" ? neutralColor :
     panelLabelCol

f_history_text() =>
    string out = ""
    int count = array.size(histCode)
    int start = math.max(0, count - 4)
    if count > 0
        for idx = start to count - 1
            out := out + f_regime_short(array.get(histCode, idx)) + str.tostring(array.get(histDur, idx)) + "-"
    out + f_regime_short(currentCode) + str.tostring(currentAge) + "*"

string historyText = f_history_text()
string dwellText = hasStats ? str.tostring(currentAge) + "/" + str.tostring(int(math.round(meanDur))) + " bars" : "N/A " + str.tostring(statCount) + "/" + str.tostring(minBlocksForStats)
string fatigueText = hasStats ? fatigueTag + " " + str.tostring(ageRatio, "#.##") + "x" : "N/A"
string flipText = hasStats and not na(flipProb) ? str.tostring(flipHorizonBars) + "b " + f_pct(flipProb) : "N/A"
string nextText = hasTransitionData ? f_regime_name(nextBestCode) + " " + f_pct(nextBestProb) : "N/A"
string decayText = na(confidenceDelta) ? "N/A" : decayTag + " " + (confidenceDelta >= 0 ? "+" : "") + str.tostring(int(math.round(confidenceDelta * 100))) + "%"
string transitionHitText = na(transitionHitRate) ? "Building" : str.tostring(int(math.round(transitionHitRate))) + "% (" + str.tostring(proofTotal) + ")"
color transitionHitColor = na(transitionHitRate) ? f_panel_value() : transitionHitRate >= 55.0 ? bullColor : transitionHitRate >= 40.0 ? neutralColor : bearColor

// -------------------------------------------------
// Chart Visuals
// -------------------------------------------------
color summaryCol = f_summary_color(summary)
bgcolor(showTint ? color.new(summaryCol, tintTransparency) : na)
barcolor(colorBars ? color.new(summaryCol, 58) : na)

var array<label> transitionLabels = array.new_label()
var int lastMarkerBar = na
var int markerStagger = 0
bool markerAllowed = showTransitionMarkers and regimeShift and lastClosedAge >= minimumMarkerDwell and (na(lastMarkerBar) or bar_index - lastMarkerBar >= markerCooldownBars)
if markerAllowed and maxMarkers > 0
    bool topMarker = summaryCode != 0
    string previousSummary = na(summary[1]) ? summary : summary[1]
    string markerText = f_regime_short(f_code(previousSummary)) + " -> " + f_regime_short(summaryCode) + " | " + str.tostring(lastClosedAge) + "b"
    label marker = label.new(bar_index, f_marker_y(topMarker, atrValue, markerStagger), markerText, xloc = xloc.bar_index, yloc = yloc.price, style = topMarker ? label.style_label_down : label.style_label_up, color = color.new(summaryCol, 0), textcolor = f_text_on(summaryCol), size = f_size(labelFontSize))
    array.push(transitionLabels, marker)
    markerStagger := (markerStagger + 1) % 3
    lastMarkerBar := bar_index
    while array.size(transitionLabels) > maxMarkers
        label oldLabel = array.shift(transitionLabels)
        label.delete(oldLabel)

if maxMarkers == 0 and barstate.islast and array.size(transitionLabels) > 0
    while array.size(transitionLabels) > 0
        label oldLabel = array.pop(transitionLabels)
        label.delete(oldLabel)

var label beacon = na
if barstate.islast
    if not na(beacon)
        label.delete(beacon)
        beacon := na
    if showBeacon
        string beaconText = summary + " | CONF " + f_pct(confidence)
        if showBeaconStats
            beaconText += "\nAGE " + str.tostring(currentAge) + "b | FLIP " + (hasStats and not na(flipProb) ? f_pct(flipProb) : "N/A")
        float beaconY = close + (summaryCode == 0 ? atrValue * beaconOffsetAtr : summaryCode == 2 ? -atrValue * beaconOffsetAtr : 0.0)
        beacon := label.new(bar_index + beaconOffsetBars, beaconY, beaconText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(summaryCol, 5), textcolor = f_text_on(summaryCol), size = f_size(labelFontSize), textalign = text.align_center)

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table panel = table.new(f_panel_pos(panelLocation), 2, 14, bgcolor = f_panel_bg(), frame_color = f_panel_border(), frame_width = 1, border_color = f_panel_border(), border_width = 1)

if barstate.islast
    table.set_position(panel, f_panel_pos(panelLocation))
    table.clear(panel, 0, 0, 1, 13)
    if showPanel
        table.cell(panel, 0, 0, "", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelFontSize))
        table.cell(panel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelFontSize))
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Regime Transition Intelligence", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelFontSize), text_halign = text.align_center)
        string contextText = syminfo.ticker + " | " + timeframe.period + (showHTF ? " | " + (htfSync ? "HTF Sync" : "HTF Divergence") : "")
        f_panel_row(panel, 1, "Context", contextText, showHTF ? (htfSync ? bullColor : neutralColor) : f_panel_value(), panelFontSize)
        f_panel_row(panel, 2, "Regime", summary + " | Age " + str.tostring(currentAge) + "b", summaryCol, panelFontSize)
        f_panel_row(panel, 3, "Action", regimeAction, regimeActionColor, panelFontSize)
        if showAxisRows
            f_panel_row(panel, 4, "Trend Axis", trendBand + " | " + str.tostring(f_score(trendScore)) + "%", f_axis_color("Trend", trendBand), panelFontSize)
            f_panel_row(panel, 5, "Chop Axis", chopBand + " | " + str.tostring(f_score(chopScore)) + "%", f_axis_color("Chop", chopBand), panelFontSize)
            f_panel_row(panel, 6, "Volatility", volBand + " | " + str.tostring(f_score(volScore)) + "%", f_axis_color("Vol", volBand), panelFontSize)
        if showDwellRows
            f_panel_row(panel, 7, "Dwell", dwellText, accentColor, panelFontSize)
            f_panel_row(panel, 8, "Fatigue", fatigueText, fatigueCol, panelFontSize)
            f_panel_row(panel, 9, "Flip Risk", flipText, flipCol, panelFontSize)
            f_panel_row(panel, 10, "Next Likely", nextText, hasTransitionData ? f_regime_color(nextBestCode) : f_panel_value(), panelFontSize)
        f_panel_row(panel, 11, "Transition Hit", transitionHitText, transitionHitColor, panelFontSize)
        f_panel_row(panel, 12, "Confidence", f_pct(confidence) + " | " + decayText, decayCol, panelFontSize)
        string lastRow = showHistoryRow ? historyText : "Mode | " + bandMode
        f_panel_row(panel, 13, showHistoryRow ? "History" : "Mode", lastRow, f_panel_value(), panelFontSize)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(barstate.isconfirmed and alertRegimeShift and regimeShift, "RTI Regime Shift", "Regime Transition Intelligence: active regime shifted.")
alertcondition(barstate.isconfirmed and alertHighFlip and hasStats and not na(flipProb) and flipProb >= 0.60, "RTI High Flip Probability", "Regime Transition Intelligence: flip probability is elevated.")
alertcondition(barstate.isconfirmed and alertExtended and fatigueTag == "EXTENDED" and fatigueTag[1] != "EXTENDED", "RTI Extended Fatigue", "Regime Transition Intelligence: current regime entered extended fatigue.")
alertcondition(barstate.isconfirmed and alertFading and decayTag == "FADING" and decayTag[1] != "FADING", "RTI Confidence Fading", "Regime Transition Intelligence: current regime confidence is fading.")
````
