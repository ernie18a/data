# Relative Strength Pullback Map [AGPro Series]

- url: https://www.tradingview.com/script/0UxiiCS8-Relative-Strength-Pullback-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;33d9d20977e9459689bb36bb1a17bc38
- version: 4.0

## Description

Relative Strength Pullback Map [AGPro Series]

🧠 Core Idea

Is the pullback happening while the asset remains a relative leader against its benchmark?


📌 Overview / What it does

Relative Strength Pullback Map is a benchmark-relative price-action tool built to study whether an asset is pulling back from strength or breaking down into weakness.

The script compares the active symbol against a selected benchmark, builds a relative-strength baseline, evaluates leader status, measures pullback depth, maps a pullback pocket, marks the recovery rail, and summarizes the full context inside a compact AG Pro panel.

It does not predict future price, automate trades, or claim that every leader pullback must recover. It is a structured decision-support map for reading relative strength, benchmark leadership, pullback health, recovery readiness, and relative breakdown risk.


🎯 Purpose & Design Philosophy

Pullbacks are not all equal.

Some pullbacks happen while the asset continues to outperform its benchmark.

Other pullbacks happen because relative strength is already breaking down.

This script was built to separate those two conditions. The design goal is to help traders identify whether a pullback belongs to a still-strong relative leader or a weakening laggard.


⚡ Why This Script Is Different

Most pullback tools focus only on price.

Most relative-strength tools focus only on the ratio line.

This script does NOT treat pullback quality and relative strength as separate ideas.

Instead, it combines benchmark-relative leadership, price pullback depth, trend shelf behavior, recovery rail reclaim, and relative breakdown risk into one visual map.

The focus is not only whether price pulled back.

The focus is whether the asset remained a leader while pulling back.


⚙️ Methodology

1. Benchmark Comparison

The script compares the active symbol against a selected benchmark using a relative-strength ratio.

2. Relative Strength Baseline

The ratio is smoothed into a baseline so leadership can be evaluated against its own recent behavior.

3. Leader Status Scoring

Leader status combines relative-strength distance, relative-strength slope, and price trend structure.

4. Pullback Depth Measurement

The script measures how far price has pulled back from the recent high using ATR-normalized depth and percentage depth.

5. Pullback Pocket Mapping

The pullback pocket is mapped between the fast recovery rail and the deeper trend shelf.

6. Recovery Evaluation

The script checks whether price is reclaiming the recovery rail while relative strength remains constructive.

7. Visual Output

The chart displays the pullback pocket, recovery rail, relative-strength rail, leader/laggard labels, right-side context tags, alerts, and a compact AG Pro panel.


🗺️ How to Read the Chart

Relative Pullback Pocket = the area where a leader pullback can remain structurally constructive.

Recovery Rail = the fast trend rail used to evaluate whether price is starting to recover from the pullback.

RS LEADER tag = the active symbol is outperforming the selected benchmark with constructive relative strength.

PULLBACK tag = the current pullback depth measured in ATR.

LEADER PULLBACK = the asset remains a relative leader while pulling into a meaningful pullback area.

RS HOLD = relative strength remains constructive during the pullback.

RECOVERY READY = price reclaimed the recovery rail while relative strength remained constructive.

RS BREAK = relative strength weakened or price broke the deeper pullback shelf.

Panel = summarizes relative state, quality score, leader status, pullback depth, recovery trigger, benchmark, and next context.


🚦 Signals & States

• LEADER PULLBACK → the asset remains a relative leader while pulling back.

• RS HOLD → relative strength is still holding during the pullback.

• RECOVERY READY → price reclaimed the recovery rail with constructive relative strength.

• RS BREAK → relative strength weakened or the pullback shelf broke.

• LAGGARD RISK → price is pulling back while the asset is no longer a clear relative leader.


🔔 Alerts Logic

Alerts can trigger when a leader pullback appears, relative strength holds, recovery becomes ready, or relative breakdown appears.

These alerts are attention markers only.

They are not trade instructions, entry signals, exit signals, or guaranteed outcomes.


🧩 Confluence Logic

The context becomes stronger when the active symbol remains above its relative-strength baseline, relative-strength slope is constructive, pullback depth is meaningful but not too deep, and price starts reclaiming the recovery rail.

The context becomes weaker when relative strength drops below its baseline, the slope turns down, or price breaks below the deeper trend shelf.


📊 When to Use

• During trend pullbacks

• When comparing an asset against a benchmark

• In crypto rotation analysis

• In stock or ETF relative-strength review

• When looking for leader pullbacks rather than weak pullbacks

• When filtering pullbacks by benchmark-relative performance


⚠️ When NOT to Use

• On symbols with poor benchmark fit

• During extremely noisy sideways markets

• In low-liquidity markets with unreliable candles

• When benchmark data is missing or unsuitable

• As a standalone buy or sell system


🎛️ Key Inputs

• Benchmark Symbol → defines the market used for relative comparison.

• Relative Strength Baseline → controls the smoothing length of the RS ratio.

• RS Slope Lookback → controls how relative-strength direction is evaluated.

• Minimum Leader Score → controls how strict leader classification should be.

• Fast Trend Length → controls the recovery rail.

• Slow Trend Length → controls the deeper pullback shelf.

• Pullback Lookback → controls the recent high used to measure pullback depth.

• Maximum Healthy Pullback ATR → controls when a pullback becomes too deep.

• Label and Panel Font Size → controls chart readability.


🖥️ Interface & Visual Design

The visual design is built around one question:

Is this still a leader pullback?

The pullback pocket shows the structural area, the recovery rail marks the reclaim reference, the relative-strength rail keeps benchmark context visible, the labels mark state changes, and the AG Pro panel summarizes the current decision context.


🧪 Practical Usage Workflow

1. Select an appropriate benchmark.

2. Read the panel first.

3. Check whether the asset is a relative leader.

4. Review pullback depth.

5. Look at the pullback pocket.

6. Watch whether price reclaims the recovery rail.

7. Confirm the broader market structure independently.


🔍 Interpretation Guidelines

A leader pullback means the asset is pulling back while still holding relative strength.

An RS hold means relative leadership has not broken yet.

Recovery ready means price has started reclaiming the recovery rail while relative strength remains constructive.

An RS break means the pullback may no longer be a clean leader pullback.

None of these states guarantee what happens next.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not a financial advice tool.

It is not an automated trading system.

It does not guarantee recovery after a leader pullback.

It does not guarantee that relative leaders will continue outperforming.

It does not replace risk management or independent analysis.


⚠️ Limitations & Transparency

Relative strength depends heavily on benchmark selection.

Different benchmarks may produce different interpretations.

Different timeframes may show different relative-strength states.

Fast markets can move through the pullback pocket quickly.

Sideways markets may create unclear relative-strength readings.


🧠 Market Context Notes

Relative strength is most useful when combined with structure, trend, volatility, and market regime.

A pullback in a relative leader can be constructive if leadership remains intact.

A pullback with relative breakdown is a weaker context and should be interpreted with caution.

Benchmark choice matters: crypto pairs may use BTCUSDT, stock charts may use SPY, sector ETFs, or another relevant benchmark.


🧾 Use Case Examples

When ETH pulls back while still outperforming BTC, the script can identify whether the pullback remains constructive or starts losing relative strength.

When a stock pulls back against SPY but relative strength holds above baseline, the script can highlight a leader pullback context.

When price breaks the pullback shelf while RS weakens, the script can flag relative breakdown risk.


🧱 System Philosophy

Relative Strength Pullback Map is part of the AGPro Series approach:

Build visual tools that explain market context clearly, avoid hype, avoid prediction claims, and support structured decision-making.

The goal is not to tell users what to do.

The goal is to help users see whether a pullback belongs to a strong leader or a weakening asset.


🔐 Non-Promise Statement

No script can remove uncertainty from trading.

This tool does not promise accuracy, certainty, profitability, or future performance.


📉 Risk Disclosure

Trading involves risk.

Market conditions can change quickly.

Users are responsible for their own decisions, position sizing, risk management, benchmark selection, and interpretation.

This script is for educational and analytical purposes only and does not provide financial advice.


📚 Educational Note

Use this script as a structured way to study relative strength, benchmark leadership, pullback depth, and recovery context.

The most valuable output is not a single label.

The value is the full map: relative state, leader status, pullback pocket, recovery rail, and next context.

## Source Code

````pine
// --------------------------------------------------
// Relative Strength Pullback Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.5
//
// Relative Strength Pullback Map compares the active symbol against a selected
// benchmark, detects whether the asset remains a relative leader during a price
// pullback, maps the pullback pocket and recovery rail, scores setup quality,
// flags the recovery target and the pullback-failure invalidation, and tracks a
// stop-aware recovery follow-through proof rate in a compact AG Pro panel.
// Version 1.5 adds font- and volatility-aware right-tag lanes with owned
// connectors while preserving the complete analytical engine.
// --------------------------------------------------

//@version=6
indicator("Relative Strength Pullback Map [AGPro Series]",
     shorttitle = "AG Pro RS",
     overlay = true,
     max_boxes_count = 45,
     max_lines_count = 100,
     max_labels_count = 220)

// --------------------------------------------------
// Inputs
// --------------------------------------------------
G_RS = "Relative Strength Engine"
G_PULLBACK = "Pullback Logic"
G_VISUAL = "Visuals"
G_PANEL = "Panel"
G_ALERTS = "Alerts"

benchmarkSymbol = input.symbol("BINANCE:BTCUSDT", "Benchmark Symbol", group = G_RS,
     tooltip = "Benchmark used to calculate relative strength. For crypto pairs, BTCUSDT often works well as a broad leadership benchmark.")
rsLength = input.int(34, "Relative Strength Baseline", minval = 2, maxval = 300, group = G_RS,
     tooltip = "EMA length applied to the relative-strength ratio between the active symbol and benchmark.")
rsSlopeLookback = input.int(8, "RS Slope Lookback", minval = 1, maxval = 100, group = G_RS,
     tooltip = "Number of bars used to evaluate whether relative strength is improving or deteriorating.")
rsStdevLength = input.int(80, "RS Deviation Length", minval = 10, maxval = 500, group = G_RS,
     tooltip = "Length used to normalize relative-strength distance from its baseline.")
minLeaderScore = input.int(62, "Minimum Leader Score", minval = 1, maxval = 100, group = G_RS,
     tooltip = "Minimum score required before the active symbol is treated as a relative leader.")

atrLength = input.int(14, "ATR Length", minval = 1, maxval = 300, group = G_PULLBACK,
     tooltip = "ATR length used to measure pullback depth, label spacing, pocket width, and failure buffers.")
trendFastLength = input.int(21, "Fast Trend Length", minval = 2, maxval = 300, group = G_PULLBACK,
     tooltip = "Fast EMA used as the first recovery rail and pullback reference.")
trendSlowLength = input.int(55, "Slow Trend Length", minval = 3, maxval = 500, group = G_PULLBACK,
     tooltip = "Slow EMA used as the deeper pullback shelf and trend-health reference.")
pullbackLookback = input.int(64, "Pullback Lookback", minval = 10, maxval = 500, group = G_PULLBACK,
     tooltip = "Lookback used to measure pullback depth from the recent price extreme.")
minPullbackAtr = input.float(0.45, "Minimum Pullback ATR", minval = 0.05, maxval = 10.0, step = 0.05, group = G_PULLBACK,
     tooltip = "Minimum pullback depth in ATR before a leader pullback can be considered meaningful.")
maxHealthyPullbackAtr = input.float(3.20, "Maximum Healthy Pullback ATR", minval = 0.20, maxval = 20.0, step = 0.10, group = G_PULLBACK,
     tooltip = "Maximum pullback depth in ATR considered structurally healthy while relative strength remains strong.")
recoveryBufferAtr = input.float(0.12, "Recovery Rail Buffer ATR", minval = 0.00, maxval = 3.0, step = 0.01, group = G_PULLBACK,
     tooltip = "ATR buffer around the fast trend rail used to detect recovery trigger conditions.")
breakBufferAtr = input.float(0.30, "Breakdown Buffer ATR", minval = 0.00, maxval = 3.0, step = 0.01, group = G_PULLBACK,
     tooltip = "ATR buffer below the slow trend rail used to detect weak or broken pullbacks.")

showPullbackPocket = input.bool(true, "Show Pullback Pocket", group = G_VISUAL,
     tooltip = "Shows the active pullback pocket between the fast and slow trend rails.")
showRecoveryRail = input.bool(true, "Show Recovery Rail", group = G_VISUAL,
     tooltip = "Shows the fast trend rail used as the recovery reference.")
showRelativeRail = input.bool(true, "Show Relative Strength Rail", group = G_VISUAL,
     tooltip = "Shows a compact price-level rail representing current relative leadership context.")
showCenteredText = input.bool(true, "Show Centered Pocket Badge", group = G_VISUAL,
     tooltip = "Shows a centered premium badge inside the pullback pocket.")
rightTagDetail = input.string("Compact", "Right Tag Detail", options = ["Compact", "Full"], group = G_VISUAL,
     tooltip = "Compact keeps right-side tags short for publication screenshots. Full adds extra score and benchmark detail where space allows.")
showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL,
     tooltip = "Shows leader-pullback, laggard-risk, RS hold, RS break, and recovery-ready labels.")
showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL,
     tooltip = "Shows compact right-side tags for the recovery rail, pullback pocket, and relative state.")
showBarColors = input.bool(false, "Color Bars By Relative State", group = G_VISUAL,
     tooltip = "Colors bars lightly according to leader pullback, recovery, or laggard risk.")
projectionBars = input.int(72, "Projection Bars", minval = 10, maxval = 400, group = G_VISUAL,
     tooltip = "Number of bars used for projected zones, rails, and right-side tags.")
labelCooldownBars = input.int(50, "Label Cooldown Bars", minval = 1, maxval = 140, group = G_VISUAL,
     tooltip = "Minimum spacing between repeated event labels.")
maxEventLabels = input.int(5, "Maximum Event Labels", minval = 3, maxval = 20, group = G_VISUAL,
     tooltip = "Maximum historical event badge-and-connector pairs retained on the chart.")
labelOffsetAtr = input.float(1.10, "Label Offset ATR", minval = 0.05, maxval = 5.0, step = 0.05, group = G_VISUAL,
     tooltip = "ATR-based event badge offset. Each displaced badge keeps an owned connector to its source candle.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_VISUAL,
     tooltip = "Controls chart label and right-side tag font size.")

showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Shows or hides the AG Pro dashboard panel.")
panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = G_PANEL,
     tooltip = "Controls dashboard location.")
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Slate", "Light"], group = G_PANEL,
     tooltip = "Controls dashboard theme.")
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_PANEL,
     tooltip = "Controls dashboard font size.")

alertLeaderPullback = input.bool(true, "Alert: Leader Pullback", group = G_ALERTS,
     tooltip = "Enables alerts when a relative leader enters a meaningful pullback pocket.")
alertRsBreak = input.bool(true, "Alert: Relative Breakdown", group = G_ALERTS,
     tooltip = "Enables alerts when the asset loses relative strength and price breaks the pullback shelf.")
alertRecoveryReady = input.bool(true, "Alert: Recovery Ready", group = G_ALERTS,
     tooltip = "Enables alerts when price reclaims the recovery rail while relative strength remains constructive.")
alertRsHold = input.bool(true, "Alert: Relative Strength Hold", group = G_ALERTS,
     tooltip = "Enables alerts when relative strength holds during a pullback.")

// --------------------------------------------------
// AGPro Color Palette
// --------------------------------------------------
headerBg = color.rgb(37, 99, 235)
headerText = color.rgb(245, 247, 250)
panelBgDark = color.rgb(15, 23, 42)
panelBgSlate = color.rgb(30, 41, 59)
panelBgLight = color.rgb(248, 250, 252)
panelBorder = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
panelLabelLight = color.rgb(71, 85, 105)
panelValueLight = color.rgb(15, 23, 42)
bullColor = color.rgb(34, 197, 166)
bearColor = color.rgb(244, 114, 182)
neutralColor = color.rgb(245, 189, 92)
accentColor = color.rgb(129, 140, 248)
zoneBorder = color.rgb(99, 102, 241)

// --------------------------------------------------
// Helpers
// --------------------------------------------------
// Luminance-aware text color so every on-chart tag stays legible on its fill
f_text_on(color bg) =>
    float lum = 0.299 * color.r(bg) + 0.587 * color.g(bg) + 0.114 * color.b(bg)
    lum > 145 ? color.rgb(17, 24, 39) : headerText

f_clamp(float value, float minValue, float maxValue) =>
    float safeValue = na(value) ? minValue : value
    math.max(minValue, math.min(maxValue, safeValue))

f_score(float value) =>
    int(math.round(f_clamp(na(value) ? 0.0 : value, 0.0, 100.0)))

f_size(string sizeInput) =>
    sizeInput == "Tiny" ? size.tiny :
     sizeInput == "Small" ? size.small :
     sizeInput == "Large" ? size.large :
     sizeInput == "Huge" ? size.huge : size.normal

f_pos(string posInput) =>
    posInput == "Top Left" ? position.top_left :
     posInput == "Top Center" ? position.top_center :
     posInput == "Top Right" ? position.top_right :
     posInput == "Middle Left" ? position.middle_left :
     posInput == "Middle Center" ? position.middle_center :
     posInput == "Middle Right" ? position.middle_right :
     posInput == "Bottom Left" ? position.bottom_left :
     posInput == "Bottom Center" ? position.bottom_center : position.bottom_right

f_price(float value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

f_ratio(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.##")

f_pct(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#") + "%"

f_state_color(string state) =>
    state == "LEADER PULLBACK" ? bullColor :
     state == "RECOVERY READY" ? bullColor :
     state == "RS HOLD" ? accentColor :
     state == "LAGGARD RISK" ? bearColor :
     state == "RS BREAK" ? bearColor :
     state == "NO CLEAR EDGE" ? panelValueCol : neutralColor

f_add_event(array<label> labels, array<line> guides, int x, float y, float anchorY, string txt, color bg, bool up, string sizeInput, int maxLabels) =>
    label lbl = label.new(x, y, txt,
         style = up ? label.style_label_up : label.style_label_down,
         textcolor = f_text_on(bg),
         color = bg,
         size = f_size(sizeInput))
    line guide = line.new(x, anchorY, x, y, xloc = xloc.bar_index, color = color.new(bg, 38), width = 1)
    array.push(labels, lbl)
    array.push(guides, guide)
    if array.size(labels) > maxLabels
        label.delete(array.shift(labels))
        line.delete(array.shift(guides))
    lbl

f_delete_label(label lbl) =>
    if not na(lbl)
        label.delete(lbl)

f_delete_box(box bx) =>
    if not na(bx)
        box.delete(bx)

f_delete_line(line ln) =>
    if not na(ln)
        line.delete(ln)

f_panel_cell(table panel, int col, int row, string txt, color txtColor, color bgColor, string sizeInput) =>
    table.cell(panel, col, row, txt, text_color = txtColor, bgcolor = bgColor, text_size = f_size(sizeInput))

// --------------------------------------------------
// Core Calculations
// --------------------------------------------------
benchmarkClose = request.security(benchmarkSymbol, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
safeBenchmark = math.max(nz(benchmarkClose, close), syminfo.mintick)
rsRaw = close / safeBenchmark * 100.0
rsBaseRaw = ta.ema(rsRaw, rsLength)
rsBase = nz(rsBaseRaw, rsRaw)
rsDevRaw = ta.stdev(rsRaw, rsStdevLength)
rsDev = nz(rsDevRaw, 0.0)
rsDistance = rsRaw - rsBase
rsDevSafe = math.max(rsDev, syminfo.mintick)
rsZ = rsDev > 0.0 ? nz(rsDistance, 0.0) / rsDevSafe : 0.0
rsSlope = rsBase - nz(rsBase[rsSlopeLookback], rsBase)

atr = ta.atr(atrLength)
safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
fast = ta.ema(close, trendFastLength)
slow = ta.ema(close, trendSlowLength)
safeFast = nz(fast, close)
safeSlow = nz(slow, close)
trendUp = safeFast > safeSlow and close > safeSlow
trendWeak = close < safeSlow - breakBufferAtr * safeAtr

recentHigh = ta.highest(high, pullbackLookback)
safeRecentHigh = nz(recentHigh, high)
pullbackAtr = (safeRecentHigh - close) / safeAtr
pullbackPct = safeRecentHigh > 0.0 ? (safeRecentHigh - close) / safeRecentHigh * 100.0 : na
pullbackScore = f_clamp((pullbackAtr - minPullbackAtr) / math.max(maxHealthyPullbackAtr - minPullbackAtr, 0.01) * 100.0, 0.0, 100.0)
healthyDepth = pullbackAtr >= minPullbackAtr and pullbackAtr <= maxHealthyPullbackAtr
tooDeep = pullbackAtr > maxHealthyPullbackAtr or trendWeak

rsDistanceScore = f_clamp(50.0 + rsZ * 22.0, 0.0, 100.0)
rsSlopeScore = f_clamp(50.0 + rsSlope / rsDevSafe * 45.0, 0.0, 100.0)
trendScore = trendUp ? 86.0 : close > safeSlow ? 58.0 : 24.0
leaderScore = f_score(rsDistanceScore * 0.36 + rsSlopeScore * 0.34 + trendScore * 0.30)

isLeader = leaderScore >= minLeaderScore and rsRaw >= rsBase
rsHold = isLeader and healthyDepth and not tooDeep
leaderPullback = isLeader and healthyDepth and close <= fast + recoveryBufferAtr * safeAtr and close >= slow - breakBufferAtr * safeAtr
recoveryReady = isLeader and healthyDepth and close > fast + recoveryBufferAtr * safeAtr and close > open
rsBreak = (rsRaw < rsBase and rsSlope < 0) or tooDeep
laggardRisk = not isLeader and healthyDepth and close < fast

qualityScore = f_score(leaderScore * 0.46 + (100.0 - math.abs(pullbackScore - 45.0)) * 0.30 + (recoveryReady ? 100.0 : rsHold ? 78.0 : rsBreak ? 18.0 : 45.0) * 0.24)

relativeState = recoveryReady ? "RECOVERY READY" :
     leaderPullback ? "LEADER PULLBACK" :
     rsHold ? "RS HOLD" :
     rsBreak ? "RS BREAK" :
     laggardRisk ? "LAGGARD RISK" : "NO CLEAR EDGE"

leaderStatus = isLeader ? "Leader" : rsRaw >= rsBase ? "Neutral lead" : "Not leader"
recoveryTriggerText = recoveryReady ? "Triggered" : leaderPullback or rsHold ? "Watch rail" : rsBreak ? "Broken" : "Not ready"
nextContext = recoveryReady ? "Track recovery" :
     leaderPullback ? "Watch rail reclaim" :
     rsHold ? "RS still holding" :
     rsBreak ? "Avoid weak pullback" :
     laggardRisk ? "Wait RS reclaim" : "Wait alignment"

pocketTop = math.max(safeFast + recoveryBufferAtr * safeAtr, safeSlow + safeAtr * 0.20)
pocketBottom = safeSlow - breakBufferAtr * safeAtr
pocketOk = pocketTop > pocketBottom and (isLeader or rsBreak or laggardRisk)
relativeRail = safeFast + rsZ * safeAtr * 0.08

leaderPullbackEvent = barstate.isconfirmed and leaderPullback and not leaderPullback[1]
rsHoldEvent = barstate.isconfirmed and rsHold and not rsHold[1]
recoveryReadyEvent = barstate.isconfirmed and recoveryReady and not recoveryReady[1]
rsBreakEvent = barstate.isconfirmed and rsBreak and not rsBreak[1]
laggardRiskEvent = barstate.isconfirmed and laggardRisk and not laggardRisk[1]

// --------------------------------------------------
// Recovery target & pullback-failure invalidation
// --------------------------------------------------
// Recovery objective = the high price pulled back from (full reclaim).
// Invalidation = the buffered pullback-failure shelf (pocket bottom).
recoveryTarget = safeRecentHigh
invalidationLevel = pocketBottom
hasContext = isLeader and healthyDepth
targetDisp = hasContext ? f_price(recoveryTarget) : "-"
invalDisp = pocketOk ? f_price(invalidationLevel) : "-"

// --------------------------------------------------
// Stop-aware Proof - recovery follow-through
// On a leader-pullback entry, did price retrace half of the pullback (a genuine
// recovery leg) before the pullback-failure level was hit? Confirmed-bar gated,
// resolve-then-open, timeout uncounted, "Building (n)" until >=6 samples.
// --------------------------------------------------
var float rsProofTarget = na
var float rsProofStop   = na
var bool  rsProofOpen   = false
var int   rsProofAge    = na
var int   rsProofWins   = 0
var int   rsProofLosses = 0
rsProofMaxBars = pullbackLookback

if leaderPullbackEvent and not rsProofOpen
    // Half-recovery checkpoint toward the recent high (genuine follow-through)
    rsProofTarget := close + (safeRecentHigh - close) * 0.5
    rsProofStop   := pocketBottom
    rsProofAge    := 0
    rsProofOpen   := true

if rsProofOpen and barstate.isconfirmed and not na(rsProofTarget) and not na(rsProofStop)
    if low <= rsProofStop
        rsProofLosses += 1
        rsProofOpen := false
    else if high >= rsProofTarget
        rsProofWins += 1
        rsProofOpen := false
    else
        rsProofAge := nz(rsProofAge) + 1
        if rsProofAge > rsProofMaxBars
            rsProofOpen := false   // timeout - uncounted

rsProofTotal = rsProofWins + rsProofLosses
rsProofRate  = rsProofTotal == 0 ? 0.0 : 100.0 * rsProofWins / rsProofTotal
proofText    = rsProofTotal < 6 ? "Building (" + str.tostring(rsProofTotal) + ")" : str.tostring(math.round(rsProofRate)) + "% (" + str.tostring(rsProofTotal) + ")"
proofColor   = rsProofTotal < 6 ? panelLabelCol : rsProofRate >= 55 ? bullColor : rsProofRate >= 45 ? neutralColor : bearColor

// --------------------------------------------------
// Visuals
// --------------------------------------------------
var box pocketBox = na
var line recoveryRail = na
var line rsRail = na
var label recoveryTag = na
var label rsTag = na
var line recoveryTagGuide = na
var line rsTagGuide = na
var label centeredPocketLabel = na
var array<label> eventLabels = array.new<label>()
var array<line> eventGuides = array.new<line>()
var int lastLeaderPullbackBar = na
var int lastRsHoldBar = na
var int lastRecoveryBar = na
var int lastBreakBar = na
var int lastLaggardBar = na
var int lastAnyEventBar = na

labelSize = f_size(labelSizeInput)
stateColor = f_state_color(relativeState)
upperEventY = high + labelOffsetAtr * safeAtr
upperEventY2 = high + (labelOffsetAtr + 0.55) * safeAtr
lowerEventY = low - labelOffsetAtr * safeAtr
lowerEventY2 = low - (labelOffsetAtr + 0.55) * safeAtr
lowerEventY3 = low - (labelOffsetAtr + 1.10) * safeAtr
eventClusterCooldownBars = math.max(int(math.round(labelCooldownBars * 0.60)), 12)
canPlaceEventCluster = na(lastAnyEventBar) or bar_index - lastAnyEventBar >= eventClusterCooldownBars

if showEventLabels and canPlaceEventCluster
    if rsBreakEvent and (na(lastBreakBar) or bar_index - lastBreakBar >= labelCooldownBars)
        f_add_event(eventLabels, eventGuides, bar_index, upperEventY, high, "RS BREAK | Q " + str.tostring(qualityScore), bearColor, false, labelSizeInput, maxEventLabels)
        lastBreakBar := bar_index
        lastAnyEventBar := bar_index
    else if laggardRiskEvent and (na(lastLaggardBar) or bar_index - lastLaggardBar >= labelCooldownBars)
        f_add_event(eventLabels, eventGuides, bar_index, upperEventY2, high, "LAGGARD | Q " + str.tostring(qualityScore), bearColor, false, labelSizeInput, maxEventLabels)
        lastLaggardBar := bar_index
        lastAnyEventBar := bar_index
    else if recoveryReadyEvent and (na(lastRecoveryBar) or bar_index - lastRecoveryBar >= labelCooldownBars)
        f_add_event(eventLabels, eventGuides, bar_index, lowerEventY, low, "RECOVERY | Q " + str.tostring(qualityScore), bullColor, true, labelSizeInput, maxEventLabels)
        lastRecoveryBar := bar_index
        lastAnyEventBar := bar_index
    else if leaderPullbackEvent and (na(lastLeaderPullbackBar) or bar_index - lastLeaderPullbackBar >= labelCooldownBars)
        f_add_event(eventLabels, eventGuides, bar_index, lowerEventY2, low, "LEADER PB | Q " + str.tostring(qualityScore), bullColor, true, labelSizeInput, maxEventLabels)
        lastLeaderPullbackBar := bar_index
        lastAnyEventBar := bar_index
    else if rsHoldEvent and (na(lastRsHoldBar) or bar_index - lastRsHoldBar >= labelCooldownBars)
        f_add_event(eventLabels, eventGuides, bar_index, lowerEventY3, low, "RS HOLD | Q " + str.tostring(leaderScore), accentColor, true, labelSizeInput, maxEventLabels)
        lastRsHoldBar := bar_index
        lastAnyEventBar := bar_index

if not showEventLabels and array.size(eventLabels) > 0
    for i = 0 to array.size(eventLabels) - 1
        label.delete(array.get(eventLabels, i))
        line.delete(array.get(eventGuides, i))
    array.clear(eventLabels)
    array.clear(eventGuides)

if barstate.islast
    f_delete_box(pocketBox)
    f_delete_line(recoveryRail)
    f_delete_line(rsRail)
    f_delete_label(recoveryTag)
    f_delete_label(rsTag)
    f_delete_line(recoveryTagGuide)
    f_delete_line(rsTagGuide)
    f_delete_label(centeredPocketLabel)
    pocketBox := na
    recoveryRail := na
    rsRail := na
    recoveryTag := na
    rsTag := na
    recoveryTagGuide := na
    rsTagGuide := na
    centeredPocketLabel := na
    int halfLookback = int(math.round(pullbackLookback * 0.5))
    int leftX = math.max(bar_index - math.max(halfLookback, 10), 0)
    int rightX = bar_index + projectionBars
    int rightTagStep = math.max(int(math.round(projectionBars * 0.06)), 3)
    int recoveryTagX = rightX + rightTagStep
    int rsTagX = rightX + rightTagStep
    int pocketBadgeX = leftX + int(math.round((rightX - leftX) * 0.50))
    float pocketMid = math.avg(pocketTop, pocketBottom)
    float pocketHeight = math.abs(pocketTop - pocketBottom)
    float recoveryTagY = fast
    float rsTagY = relativeRail
    float fontGapMult = labelSizeInput == "Tiny" ? 0.72 : labelSizeInput == "Small" ? 0.86 : labelSizeInput == "Large" ? 1.25 : labelSizeInput == "Huge" ? 1.55 : 1.0
    float rightTagLaneGap = math.max(safeAtr * 0.58, pocketHeight * 0.22) * fontGapMult
    bool rightTagsCrowded = math.abs(relativeRail - fast) < rightTagLaneGap * 2.20
    if rightTagsCrowded
        recoveryTagY := math.min(fast, relativeRail) - rightTagLaneGap
        rsTagY := math.max(fast, relativeRail) + rightTagLaneGap
    if showPullbackPocket and pocketOk
        pocketBox := box.new(leftX, pocketTop, rightX, pocketBottom,
             bgcolor = color.new(stateColor, 84),
             border_color = color.new(stateColor, 14),
             border_width = 1)
        if showCenteredText
            string pocketIdentity = relativeState + " | Q " + str.tostring(qualityScore) + "\nPB " + f_ratio(pullbackAtr) + " ATR | RS " + str.tostring(leaderScore)
            centeredPocketLabel := label.new(pocketBadgeX, pocketMid, pocketIdentity,
                 style = label.style_label_center,
                 textcolor = f_text_on(stateColor),
                 color = color.new(stateColor, 8),
                 size = labelSize)
    if showRecoveryRail
        recoveryRail := line.new(leftX, fast, rightX, fast, color = color.new(bullColor, 0), width = 1)
    if showRelativeRail
        rsRail := line.new(leftX, relativeRail, rightX, relativeRail, color = color.new(accentColor, 8), style = line.style_dotted, width = 2)
    if showRightTags
        string recTagText = recoveryReady ? "RECOVERY RAIL" : "RECOVERY WATCH"
        string rsTagText = rightTagDetail == "Full" ? (isLeader ? "RS LEADER " : "RS ") + str.tostring(leaderScore) + " | " + benchmarkSymbol : isLeader ? "RS LEADER " + str.tostring(leaderScore) : "RS " + str.tostring(leaderScore)
        color recTagBg = recoveryReady ? bullColor : accentColor
        color rsTagBg = isLeader ? bullColor : rsBreak ? bearColor : neutralColor
        recoveryTagGuide := line.new(rightX, fast, recoveryTagX, recoveryTagY, xloc = xloc.bar_index, color = color.new(recTagBg, 20), width = 1)
        recoveryTag := label.new(recoveryTagX, recoveryTagY, recTagText,
             style = label.style_label_left,
             textcolor = f_text_on(recTagBg),
             color = recTagBg,
             size = labelSize)
        rsTagGuide := line.new(rightX, relativeRail, rsTagX, rsTagY, xloc = xloc.bar_index, color = color.new(rsTagBg, 20), width = 1)
        rsTag := label.new(rsTagX, rsTagY, rsTagText,
             style = label.style_label_left,
             textcolor = f_text_on(rsTagBg),
             color = rsTagBg,
             size = labelSize)

barCol = not showBarColors ? na :
     relativeState == "RECOVERY READY" ? color.new(bullColor, 70) :
     relativeState == "LEADER PULLBACK" ? color.new(bullColor, 78) :
     relativeState == "RS HOLD" ? color.new(accentColor, 76) :
     relativeState == "RS BREAK" ? color.new(bearColor, 70) :
     relativeState == "LAGGARD RISK" ? color.new(bearColor, 78) : na
barcolor(barCol)

// --------------------------------------------------
// Panel
// --------------------------------------------------
panelBg = panelTheme == "Light" ? panelBgLight : panelTheme == "Slate" ? panelBgSlate : panelBgDark
panelLabel = panelTheme == "Light" ? panelLabelLight : panelLabelCol
panelValue = panelTheme == "Light" ? panelValueLight : panelValueCol
panelBorderActive = panelTheme == "Light" ? color.rgb(203, 213, 225) : panelBorder
var table panel = na
var string panelPosMemory = ""
var string panelThemeMemory = ""

if showPanel and (na(panel) or panelPosMemory != panelPositionInput or panelThemeMemory != panelTheme)
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_pos(panelPositionInput), 2, 11, bgcolor = panelBg, border_color = panelBorderActive, border_width = 1)
    panelPosMemory := panelPositionInput
    panelThemeMemory := panelTheme

if showPanel and not na(panel)
    table.clear(panel, 0, 0, 1, 10)
    table.cell(panel, 0, 0, "AG Pro Relative Strength Pullback Map", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelFontSizeInput))
    table.cell(panel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelFontSizeInput))
    table.merge_cells(panel, 0, 0, 1, 0)
    f_panel_cell(panel, 0, 1, "Relative State", panelLabel, panelBg, panelFontSizeInput)
    f_panel_cell(panel, 1, 1, relativeState, stateColor, panelBg, panelFontSizeInput)
    f_panel_cell(panel, 0, 2, "Quality Score", panelLabel, panelBg, panelFontSizeInput)
    f_panel_cell(panel, 1, 2, str.tostring(qualityScore) + " / 100", qualityScore >= 70 ? bullColor : qualityScore >= 45 ? neutralColor : panelValue, panelBg, panelFontSizeInput)
    f_panel_cell(panel, 0, 3, "Leader Status", panelLabel, panelBg, panelFontSizeInput)
    f_panel_cell(panel, 1, 3, leaderStatus + " / " + str.tostring(leaderScore), isLeader ? bullColor : rsBreak ? bearColor : neutralColor, panelBg, panelFontSizeInput)
    f_panel_cell(panel, 0, 4, "Pullback Depth", panelLabel, panelBg, panelFontSizeInput)
    f_panel_cell(panel, 1, 4, f_ratio(pullbackAtr) + " ATR / " + f_pct(pullbackPct), healthyDepth ? neutralColor : tooDeep ? bearColor : panelValue, panelBg, panelFontSizeInput)
    f_panel_cell(panel, 0, 5, "Target", panelLabel, panelBg, panelFontSizeInput)
    f_panel_cell(panel, 1, 5, targetDisp, hasContext ? bullColor : panelValue, panelBg, panelFontSizeInput)
    f_panel_cell(panel, 0, 6, "Invalidation", panelLabel, panelBg, panelFontSizeInput)
    f_panel_cell(panel, 1, 6, invalDisp, pocketOk ? bearColor : panelValue, panelBg, panelFontSizeInput)
    f_panel_cell(panel, 0, 7, "Recovery Trigger", panelLabel, panelBg, panelFontSizeInput)
    f_panel_cell(panel, 1, 7, recoveryTriggerText, recoveryReady ? bullColor : rsBreak ? bearColor : panelValue, panelBg, panelFontSizeInput)
    f_panel_cell(panel, 0, 8, "Action", panelLabel, panelBg, panelFontSizeInput)
    f_panel_cell(panel, 1, 8, nextContext, stateColor, panelBg, panelFontSizeInput)
    f_panel_cell(panel, 0, 9, "Benchmark", panelLabel, panelBg, panelFontSizeInput)
    f_panel_cell(panel, 1, 9, benchmarkSymbol, panelValue, panelBg, panelFontSizeInput)
    f_panel_cell(panel, 0, 10, "Proof", panelLabel, panelBg, panelFontSizeInput)
    f_panel_cell(panel, 1, 10, proofText, proofColor, panelBg, panelFontSizeInput)

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na
    panelPosMemory := ""
    panelThemeMemory := ""

// --------------------------------------------------
// Alerts
// --------------------------------------------------
alertcondition(alertLeaderPullback and leaderPullbackEvent, "Leader Pullback", "Relative Strength Pullback Map: the active symbol remains a relative leader during a meaningful pullback.")
alertcondition(alertRsBreak and rsBreakEvent, "Relative Strength Breakdown", "Relative Strength Pullback Map: relative strength weakened and the pullback shelf broke.")
alertcondition(alertRecoveryReady and recoveryReadyEvent, "Recovery Ready", "Relative Strength Pullback Map: price reclaimed the recovery rail while relative strength remained constructive.")
alertcondition(alertRsHold and rsHoldEvent, "Relative Strength Hold", "Relative Strength Pullback Map: relative strength held during the pullback.")
````
