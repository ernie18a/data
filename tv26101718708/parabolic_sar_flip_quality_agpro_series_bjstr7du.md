# Parabolic SAR Flip Quality [AGPro Series]

- url: https://www.tradingview.com/script/BjsTR7Du-Parabolic-SAR-Flip-Quality-AGPro-Series/
- type: indicator
- pine_id: PUB;89c7dc1f78f34d779b52774541713157
- version: 4.0

## Description

Parabolic SAR Flip Quality [AGPro Series]

🧠 Core Idea

Is this Parabolic SAR flip strong enough to plan around, or is it just another noisy stop-and-reverse signal?


📌 Overview / What it does

Parabolic SAR Flip Quality [AGPro Series] is a planner-style Parabolic SAR overlay built to evaluate PSAR flip conditions as trade-decision context, not as simple directional signals.

The script keeps the classic Parabolic SAR dot trail visible, then adds a professional quality model that measures flip strength, trend alignment, SAR distance, candle efficiency, volatility expansion, and prior-leg maturity. The result is a clear 0-100 readiness score that helps traders judge whether the current PSAR flip environment is valid, weak, developing, or blocked.

It produces qualified flip labels, SAR dots, a SAR-native protection band, and a compact AGPro panel showing Flip Side, SAR Distance, Trend Filter, and Quality Score. It does not automate trades, predict future price, or tell users what to buy or sell. It organizes PSAR flip context into a cleaner decision framework.


🎯 Purpose & Design Philosophy

Most Parabolic SAR tools show where the SAR dots are and where the stop-and-reverse event happened. That is useful, but it often leaves the trader with the harder question: is this flip actually good enough to act on, monitor, or ignore?

This script was built to fill that gap. It turns a classic indicator into a structured decision engine by asking whether the flip has enough distance, trend support, expansion, and maturity behind it.

The design supports traders who want cleaner execution readiness, not more noise. It is built for chart readers who want to evaluate setup quality, risk area, invalidation context, and next-action state before making their own decision.


⚡ Why This Script Is Different

Most tools focus on printing every Parabolic SAR flip as if all flips have similar meaning.

This script does NOT treat a dot-side change as a complete setup. It also does not turn PSAR into a generic signal board or a generic support/resistance zone map.

Instead, it evaluates the flip as a planning event. The script scores the quality of the transition, checks whether trend conditions support the new side, measures how far price is from the SAR reference, and projects a SAR Protection Band that represents the stop-defense area created by the qualified flip.

The difference is the decision layer:

• Is the flip valid?
• How strong is it?
• Where is the SAR-based invalidation area?
• Is the trend filter helping or blocking the setup?
• What is the current read now?


⚙️ Methodology

1. Context Detection

The script detects whether price is currently operating on the bullish or bearish side of the Parabolic SAR. It also tracks raw SAR flips and measures how mature the prior SAR leg was before the transition.

2. Reference Mapping

The active SAR value becomes the primary reference point. Distance from SAR is normalized by ATR so the read adapts across symbols and timeframes.

3. Reaction Evaluation

Each flip is evaluated through a multi-factor quality model:

• SAR distance versus ATR
• EMA trend alignment
• EMA slope direction
• DMI directional agreement
• ADX trend strength
• Candle body efficiency
• Range expansion
• Prior-leg maturity

These conditions are combined into a 0-100 Quality Score.

4. Visual Output

When a flip passes the quality threshold, trend filter, SAR distance requirement, confirmation setting, and cooldown control, the script promotes it into a qualified chart label. It can also draw a SAR Protection Band around the flip's SAR reference for forward context.


🗺️ How to Read the Chart

SAR dots show the classic Parabolic SAR trail. Bullish dots appear below price, and bearish dots appear above price.

Qualified flip labels mark PSAR flips that passed the quality and trend conditions. The label includes the flip side and the quality score, allowing quick comparison between stronger and weaker transitions.

The SAR Protection Band represents the PSAR-based stop-defense area created after a qualified flip. It is not a generic support/resistance zone. It is a SAR-native invalidation and planning reference.

Colors follow the AGPro visual language:

• Teal = bullish side or bullish qualified flip
• Pink = bearish side or bearish qualified flip
• Gold = neutral, blocked, or caution state
• Indigo = trend backbone reference

The panel summarizes the active read:

• Flip Side
• SAR Distance
• Trend Filter
• Quality Score


🚦 Signals & States

• Bullish Flip → A qualified PSAR transition to the bullish side.

• Bearish Flip → A qualified PSAR transition to the bearish side.

• Trend Filter PASS → The broader trend filter agrees with the current SAR side.

• Trend Filter BLOCKED → The SAR side is active, but the broader trend filter does not fully support it.

• High Quality Score → The flip has stronger alignment across distance, trend, expansion, efficiency, and maturity.

• WAIT Grade → The current condition does not meet the preferred readiness profile.

These are analytical states, not trade instructions.


🔔 Alerts Logic

Alerts trigger only when a qualified bullish or bearish PSAR flip is confirmed by the script's quality rules.

• Qualified Bullish PSAR Flip → A bullish SAR flip passed the trend filter, quality threshold, SAR distance threshold, cooldown rule, and confirmation setting.

• Qualified Bearish PSAR Flip → A bearish SAR flip passed the trend filter, quality threshold, SAR distance threshold, cooldown rule, and confirmation setting.

Alerts are attention markers. They are not automated trading instructions and do not guarantee future movement.


🧩 Confluence Logic

The strongest context appears when several conditions align at the same time:

• PSAR flips to a new side
• Price has enough ATR-normalized distance from SAR
• EMA trend direction supports the flip
• DMI confirms directional pressure
• ADX shows enough trend strength
• Candle structure shows real expansion
• The previous SAR leg was mature enough

When these elements align, the flip becomes more useful as a planning reference.


📊 When to Use

This script is best suited for:

• Trending markets where SAR transitions can develop into continuation phases
• Swing-trading review on higher timeframes
• Crypto, forex, stocks, indices, and commodities with enough liquidity
• PSAR users who want a readiness score instead of raw dot flips
• Traders who want a cleaner invalidation reference around qualified SAR flips
• Multi-timeframe analysis where the user wants to compare flip quality across chart periods


⚠️ When NOT to Use

This script is less useful in:

• Very low-liquidity markets
• Extremely noisy sideways chop
• News-driven spikes where ATR and structure can distort quickly
• Ultra-low timeframes with unstable spread or poor execution quality
• Markets where price repeatedly flips around the SAR without trend expansion

In these conditions, raw PSAR flips and quality labels can become less reliable as planning references.


🎛️ Key Inputs

• SAR Start → Controls the initial Parabolic SAR acceleration factor.

• SAR Increment → Controls how quickly the SAR acceleration increases as the trend develops.

• SAR Maximum → Controls the maximum SAR acceleration level.

• Trend EMA Length → Defines the trend backbone used by the filter.

• DMI Length and ADX Smoothing → Control directional pressure and trend-strength measurement.

• Minimum ADX → Sets the required trend-strength floor.

• Minimum Quality Score → Defines how selective qualified flip labels should be.

• Minimum SAR Distance ATR → Blocks cramped flips that occur too close to the SAR reference.

• Prior Leg Maturity Bars → Requires the prior SAR leg to have enough development before a flip receives full maturity credit.

• Flip Cooldown Bars → Controls label density and keeps the chart readable.

• SAR Protection Band settings → Control the width, forward projection, and maximum active bands.

• Panel and Label Font Size → Adjust visual readability, with Normal as the default.

• Panel Location and Theme → Control the AGPro panel placement and appearance.


🖥️ Interface & Visual Design

The interface is designed to be premium, compact, and decision-focused.

The chart keeps the classic PSAR dots as the main visual anchor. Qualified labels appear only when the flip passes the selected filters. The SAR Protection Band is transparent and restrained so it adds planning context without overwhelming candles.

The AGPro panel uses a single merged blue header row with the script name, followed by a clean four-row readout. Its purpose is to summarize the current decision state without turning the chart into a dashboard-heavy layout.


🧪 Practical Usage Workflow

1. Read the panel.

Check the active Flip Side, SAR Distance, Trend Filter, and Quality Score.

2. Check the latest qualified label.

Compare the quality score with the minimum threshold and with prior labels on the chart.

3. Review the SAR Protection Band.

Use the band as a SAR-native planning reference for where the qualified flip should remain structurally defended.

4. Confirm broader context.

Compare the flip with trend direction, volatility, market structure, and timeframe behavior.

5. Decide independently.

Use the output as structured context, not as an automatic trade command.


🔍 Interpretation Guidelines

A strong read usually has a qualified flip label, a passing trend filter, enough SAR distance, and a higher quality grade.

A weaker read may show an active SAR side but a blocked trend filter or a low score. This means the SAR state exists, but the planning context is not strong enough under the script's model.

The SAR Protection Band should be interpreted as a stop-defense and invalidation reference. If price respects it, the flip context remains cleaner. If price violates it, the qualified flip has lost part of its structural value.

The best use of the script is comparison: compare current flip quality against previous flips, across timeframes, and across market conditions.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an auto-trading system.

It does not guarantee profitable signals.

It does not replace independent analysis, position sizing, risk management, or broader market context.


⚠️ Limitations & Transparency

Parabolic SAR is a trend-following concept, so it can struggle in choppy or directionless markets.

Quality scoring improves structure, but it cannot remove all false transitions. Timeframe selection, volatility regime, liquidity, and market session can affect how signals appear and how useful the SAR Protection Band becomes.

The script is rule-based and transparent. It reads current and historical chart data according to the selected inputs. It does not know future price behavior.


🧠 Market Context Notes

PSAR flips tend to become more meaningful when they occur with volatility expansion, directional pressure, and enough distance from the SAR reference.

In compressed markets, the dots may switch sides more frequently and the score may change quickly. In stronger trends, the SAR dots often create cleaner trailing structure, and qualified flips can become more useful as planning events.

The best interpretation comes from combining the panel state, SAR distance, label quality, protection band behavior, and the broader market environment.


🧾 Use Case Examples

When price flips bullish, the trend filter passes, SAR distance expands above the minimum threshold, and the quality score is high, the user can treat that area as a cleaner bullish planning context.

When price flips bearish but the trend filter is blocked, the script communicates caution. The SAR side changed, but the broader read is not aligned.

When price returns to the SAR Protection Band after a qualified flip, the user can monitor whether the band is respected or violated as part of the invalidation read.


🧱 System Philosophy

The purpose of this script is not to add another signal to the chart.

The purpose is to turn a classic indicator into a decision-support framework:

• Setup validity
• Quality strength
• Trend agreement
• Risk reference
• Invalidation context
• Current action state

This is the AGPro direction: tools that help traders make better decisions, not tools that simply decorate the chart with more signals.


🔐 Non-Promise Statement

No indicator can provide certainty.

This script does not promise future outcomes, guaranteed performance, or risk-free execution.

Its role is to organize Parabolic SAR flip context into a clearer analytical structure.


📉 Risk Disclosure

Trading involves risk, and market conditions can change quickly.

This script is provided for educational and analytical purposes only. It does not provide financial advice, investment advice, or guaranteed trading outcomes.

Users are responsible for their own analysis, decisions, risk management, and trading results.


📚 Educational Note

Parabolic SAR is one of the most recognized stop-and-reverse indicators because it makes trend state visually simple. This script keeps that visual simplicity while adding a quality and planning layer so users can study which flips deserve more attention and which ones should remain secondary context.

## Source Code

````pine
// -----------------------------------------------------------------------------
// Parabolic SAR Flip Quality [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Parabolic SAR Flip Quality filters raw PSAR stop-and-reverse flips through
// trend alignment, SAR distance, candle efficiency, expansion, and prior-leg
// maturity. The script keeps the classic Parabolic SAR dot trail visible,
// grades each flip 0-100, measures confirmation-anchored follow-through,
// surfaces the live SAR and locked protection edge, and maintains one active
// SAR-native defense band with collision-safe event and zone labels.
// -----------------------------------------------------------------------------

//@version=6
indicator("Parabolic SAR Flip Quality [AGPro Series]",
     shorttitle       = "AG Pro SAR",
     overlay          = true,
     max_labels_count = 40,
     max_boxes_count  = 2,
     max_lines_count  = 4)

// -----------------------------------------------------------------------------
// AGPro Color Palette
// -----------------------------------------------------------------------------
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
panelBg       = color.rgb(15, 23, 42)
panelBorder   = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)

// -----------------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

f_size(string value) =>
    switch value
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_position(string value) =>
    switch value
        "Top Left" => position.top_left
        "Middle Right" => position.middle_right
        "Middle Left" => position.middle_left
        "Bottom Left" => position.bottom_left
        "Bottom Right" => position.bottom_right
        => position.top_right

f_score_color(int score) =>
    score >= 78 ? bullColor : score >= 62 ? neutralColor : bearColor

f_grade(int score) =>
    score >= 84 ? "A+" : score >= 76 ? "A" : score >= 68 ? "B" : score >= 58 ? "C" : "WAIT"

f_panel_bg(bool lightPanel, bool alt) =>
    lightPanel ? (alt ? color.rgb(241, 245, 249) : color.rgb(248, 250, 252)) : (alt ? color.rgb(19, 29, 48) : panelBg)

f_next_action(bool sarIsBull, bool trendPass, bool freshFlip, bool bandLive) =>
    not trendPass ? "Wait trend alignment" :
     freshFlip ? (sarIsBull ? "Review fresh bull flip" : "Review fresh bear flip") :
     bandLive ? (sarIsBull ? "Trail bullish SAR" : "Trail bearish SAR") :
     (sarIsBull ? "Monitor bullish SAR" : "Monitor bearish SAR")

f_delete_label(label item) =>
    if not na(item)
        label.delete(item)

// -----------------------------------------------------------------------------
// Inputs
// -----------------------------------------------------------------------------
string groupSar = "SAR Engine"
enginePreset = input.string("Balanced Trend", "Engine Preset", options = ["Balanced Trend", "Cleaner Swing", "Active Flip", "Custom"], group = groupSar,
     tooltip = "Selects the default behavior profile. Balanced Trend is the publication default. Cleaner Swing is more selective. Active Flip prints more frequent PSAR quality events. Custom uses the raw inputs below.")
sarStart = input.float(0.02, "SAR Start", minval = 0.001, maxval = 0.20, step = 0.001, group = groupSar,
     tooltip = "Initial Parabolic SAR acceleration factor. Lower values make the SAR slower and smoother.")
sarIncrement = input.float(0.02, "SAR Increment", minval = 0.001, maxval = 0.20, step = 0.001, group = groupSar,
     tooltip = "Acceleration increment applied as the Parabolic SAR trend develops.")
sarMaximum = input.float(0.20, "SAR Maximum", minval = 0.01, maxval = 1.00, step = 0.01, group = groupSar,
     tooltip = "Maximum Parabolic SAR acceleration factor. Higher values make the SAR react faster.")
confirmedOnly = input.bool(true, "Confirmed-Bar Flips", group = groupSar,
     tooltip = "When enabled, qualified flips are accepted only after the current bar is confirmed.")

string groupTrend = "Trend Filter"
trendEmaLength = input.int(55, "Trend EMA Length", minval = 5, maxval = 300, group = groupTrend,
     tooltip = "EMA backbone used to verify whether the PSAR flip is aligned with the broader trend.")
emaSlopeBars = input.int(3, "EMA Slope Bars", minval = 1, maxval = 20, group = groupTrend,
     tooltip = "Number of bars used to confirm whether the trend EMA is rising or falling.")
dmiLength = input.int(14, "DMI Length", minval = 2, maxval = 100, group = groupTrend,
     tooltip = "DMI length used to measure directional pressure behind the PSAR flip.")
adxSmoothing = input.int(14, "ADX Smoothing", minval = 2, maxval = 100, group = groupTrend,
     tooltip = "ADX smoothing length used by the trend-quality filter.")
minAdx = input.float(16.0, "Minimum ADX", minval = 1.0, maxval = 60.0, step = 0.5, group = groupTrend,
     tooltip = "Minimum ADX required for a flip to pass the directional trend filter.")

string groupQuality = "Quality Model"
atrLength = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupQuality,
     tooltip = "ATR length used to normalize SAR distance, candle expansion, labels, and protection bands.")
minQualityScore = input.int(75, "Minimum Quality Score", minval = 1, maxval = 100, group = groupQuality,
     tooltip = "Minimum composite score required before a PSAR flip can be promoted into a qualified chart event.")
minSarDistanceAtr = input.float(0.18, "Minimum SAR Distance ATR", minval = 0.01, maxval = 5.0, step = 0.01, group = groupQuality,
     tooltip = "Minimum close-to-SAR distance, normalized by ATR, required to avoid promoting cramped flips.")
distanceTargetAtr = input.float(0.85, "Distance Target ATR", minval = 0.05, maxval = 5.0, step = 0.05, group = groupQuality,
     tooltip = "Distance level where the SAR separation component reaches full score.")
maturityBars = input.int(7, "Prior Leg Maturity Bars", minval = 1, maxval = 50, group = groupQuality,
     tooltip = "Prior SAR leg length needed before a new flip receives full maturity credit.")
cooldownBars = input.int(44, "Flip Cooldown Bars", minval = 0, maxval = 100, group = groupQuality,
     tooltip = "Minimum number of bars between qualified flip labels. This keeps the overlay selective and readable.")
followTargetAtr = input.float(1.0, "Follow-Through Target ATR", minval = 0.20, maxval = 5.0, step = 0.05, group = groupQuality,
     tooltip = "Favorable move (in ATR) a qualified flip must reach to count as a follow-through in the Follow Rate proof.")
followWindowBars = input.int(24, "Follow-Through Window", minval = 4, maxval = 200, group = groupQuality,
     tooltip = "Maximum number of bars a qualified flip is tracked for follow-through before the sample resolves.")

string groupVisual = "Visuals"
showSarDots = input.bool(true, "Show SAR Dots", group = groupVisual,
     tooltip = "Displays the classic Parabolic SAR dot trail.")
showTrendBackbone = input.bool(true, "Show Trend Backbone", group = groupVisual,
     tooltip = "Displays the EMA backbone used by the trend filter.")
showFlipLabels = input.bool(true, "Show Qualified Flip Labels", group = groupVisual,
     tooltip = "Displays labels only for PSAR flips that pass the trend filter and quality threshold.")
showWatchLabels = input.bool(false, "Show Near-Quality Watch Labels", group = groupVisual,
     tooltip = "Shows muted watch labels for flips that are close to qualification. Disabled by default to keep the publication chart clean.")
watchScoreGap = input.int(8, "Watch Score Gap", minval = 1, maxval = 25, group = groupVisual,
     tooltip = "How close a raw flip must be to the minimum quality threshold before an optional watch label can print.")
labelOffsetAtr = input.float(1.25, "Label Offset ATR", minval = 0.10, maxval = 5.00, step = 0.05, group = groupVisual,
     tooltip = "Vertical label offset measured in ATR so labels stay clear of candle bodies.")
maxFlipLabels = input.int(12, "Maximum Flip Labels", minval = 5, maxval = 40, group = groupVisual,
     tooltip = "Maximum number of qualified flip and optional watch labels kept on the chart.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisual,
     tooltip = "Controls all chart label text sizes.")

string groupProtection = "SAR Protection Band"
showProtectionBands = input.bool(true, "Show Protection Bands", group = groupProtection,
     tooltip = "Draws a SAR-native stop-defense band after qualified flips. It is based on the PSAR reference and ATR, not on generic trend-band zones.")
showBandLabels = input.bool(true, "Show Centered Band Labels", group = groupProtection,
     tooltip = "Places a centered label inside each SAR protection band so the band explains the active flip context.")
protectionWidthAtr = input.float(0.30, "Band Width ATR", minval = 0.05, maxval = 2.00, step = 0.01, group = groupProtection,
     tooltip = "Half-width of the protection band around the qualified flip's SAR reference, measured in ATR.")
protectionForwardBars = input.int(48, "Band Forward Bars", minval = 10, maxval = 180, group = groupProtection,
     tooltip = "Forward projection length of each SAR protection band.")
showBandFailureLabels = input.bool(true, "Show Band Failure Labels", group = groupProtection,
     tooltip = "Prints one compact confirmed-close failure label when the active SAR protection edge is lost. The expired band is removed immediately to prevent historical zone overlap.")

string groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel,
     tooltip = "Shows the compact AG Pro status panel.")
panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Right"], group = groupPanel,
     tooltip = "Controls where the AG Pro panel is displayed.")
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel,
     tooltip = "Controls the panel color theme.")
panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel,
     tooltip = "Controls all panel text sizes.")

string groupAlerts = "Alerts"
alertQualifiedFlips = input.bool(true, "Alert on Qualified Flips", group = groupAlerts,
     tooltip = "Enables alerts when a bullish or bearish PSAR flip passes the quality model.")
alertBandFailure = input.bool(false, "Alert on Protection Band Failure", group = groupAlerts,
     tooltip = "Enables alerts when price closes through a live SAR protection band.")

// -----------------------------------------------------------------------------
// Presets
// -----------------------------------------------------------------------------
cleanerPreset = enginePreset == "Cleaner Swing"
activePreset = enginePreset == "Active Flip"
usedMinQuality = cleanerPreset ? math.max(minQualityScore, 72) : activePreset ? math.max(minQualityScore - 5, 1) : minQualityScore
usedCooldownBars = cleanerPreset ? math.max(cooldownBars, 14) : activePreset ? math.max(cooldownBars, 6) : cooldownBars
usedForwardBars = cleanerPreset ? math.max(protectionForwardBars, 64) : activePreset ? math.max(protectionForwardBars, 42) : protectionForwardBars

// -----------------------------------------------------------------------------
// Core calculations
// -----------------------------------------------------------------------------
atrValue = ta.atr(atrLength)
safeAtr = math.max(atrValue, syminfo.mintick)
sarValue = ta.sar(sarStart, sarIncrement, sarMaximum)
sarBull = sarValue < close
hasPrevBar = bar_index > 0 and not na(sarValue[1])
rawBullFlip = hasPrevBar and sarBull and not sarBull[1]
rawBearFlip = hasPrevBar and not sarBull and sarBull[1]

trendEma = ta.ema(close, trendEmaLength)
emaSlope = trendEma - trendEma[emaSlopeBars]
[diPlus, diMinus, adxValue] = ta.dmi(dmiLength, adxSmoothing)
bullTrendPass = close > trendEma and emaSlope > 0 and diPlus > diMinus and adxValue >= minAdx
bearTrendPass = close < trendEma and emaSlope < 0 and diMinus > diPlus and adxValue >= minAdx
activeTrendPass = sarBull ? bullTrendPass : bearTrendPass

var int sarLegBars = 0
sarLegBars := hasPrevBar and sarBull == sarBull[1] ? sarLegBars + 1 : 1
priorLegBars = nz(sarLegBars[1], 0)
scoreLegBars = (rawBullFlip or rawBearFlip) ? priorLegBars : sarLegBars

barRange = math.max(high - low, syminfo.mintick)
bodyEfficiency = math.abs(close - open) / barRange
rangeAtr = barRange / safeAtr
sarDistanceAtr = math.abs(close - sarValue) / safeAtr

bodyScore = f_clamp(bodyEfficiency / 0.62, 0.0, 1.0) * 18.0
rangeScore = f_clamp(rangeAtr / 1.35, 0.0, 1.0) * 16.0
distanceScore = f_clamp(sarDistanceAtr / distanceTargetAtr, 0.0, 1.0) * 22.0
float trendScore = 0.0
if activeTrendPass
    trendScore := 26.0
else if (sarBull and close > trendEma) or (not sarBull and close < trendEma)
    trendScore := 12.0
legScore = f_clamp(float(scoreLegBars) / float(maturityBars), 0.0, 1.0) * 18.0
qualityScore = int(math.round(f_clamp(bodyScore + rangeScore + distanceScore + trendScore + legScore, 0.0, 100.0)))

var int lastQualifiedBar = na
var int lastQualifiedScore = na
var int lastQualifiedDir = 0
var int lastWatchBar = na
cooldownPass = na(lastQualifiedBar) or bar_index - lastQualifiedBar >= usedCooldownBars
watchCooldownPass = na(lastWatchBar) or bar_index - lastWatchBar >= usedCooldownBars
confirmedGate = not confirmedOnly or barstate.isconfirmed
qualifiedBull = rawBullFlip and bullTrendPass and qualityScore >= usedMinQuality and sarDistanceAtr >= minSarDistanceAtr and cooldownPass and confirmedGate
qualifiedBear = rawBearFlip and bearTrendPass and qualityScore >= usedMinQuality and sarDistanceAtr >= minSarDistanceAtr and cooldownPass and confirmedGate
nearQualityFlip = (rawBullFlip or rawBearFlip) and not (qualifiedBull or qualifiedBear) and qualityScore >= math.max(usedMinQuality - watchScoreGap, 1) and sarDistanceAtr >= minSarDistanceAtr and watchCooldownPass and confirmedGate

if qualifiedBull or qualifiedBear
    lastQualifiedBar := bar_index
    lastQualifiedScore := qualityScore
    lastQualifiedDir := qualifiedBull ? 1 : -1
if nearQualityFlip
    lastWatchBar := bar_index

// -----------------------------------------------------------------------------
// Follow-through proof (Follow Rate)
// -----------------------------------------------------------------------------
var int   ftTotal   = 0
var int   ftWin     = 0
var int   pendDir   = 0
var float pendEntry = na
var float pendAtr   = na
var float pendInvalid = na
var int   pendLeft  = 0

if barstate.isconfirmed
    if pendLeft > 0
        favMove = pendDir == 1 ? high - pendEntry : pendEntry - low
        hitTarget = favMove >= pendAtr * followTargetAtr
        invalidated = pendDir == 1 ? close < pendInvalid : close > pendInvalid
        flippedBack = pendDir == 1 ? not sarBull : sarBull
        if invalidated or flippedBack
            ftTotal += 1
            pendDir := 0
            pendLeft := 0
        else if hitTarget
            ftTotal += 1
            ftWin   += 1
            pendDir := 0
            pendLeft := 0
        else if pendLeft == 1
            ftTotal += 1
            pendDir := 0
            pendLeft := 0
        else
            pendLeft -= 1
    if (qualifiedBull or qualifiedBear) and pendLeft == 0
        pendDir := qualifiedBull ? 1 : -1
        pendEntry := close
        pendAtr := safeAtr
        pendInvalid := pendDir == 1 ? sarValue - safeAtr * protectionWidthAtr : sarValue + safeAtr * protectionWidthAtr
        pendLeft := followWindowBars

followRate = ftTotal > 0 ? ftWin / ftTotal * 100.0 : na

// -----------------------------------------------------------------------------
// Visual overlay
// -----------------------------------------------------------------------------
labelTextSize = f_size(labelSizeInput)
panelTextSize = f_size(panelSizeInput)

plot(showSarDots ? sarValue : na, "SAR Dots", style = plot.style_circles, linewidth = 2, color = sarBull ? color.new(bullColor, 0) : color.new(bearColor, 0))
plot(showTrendBackbone ? trendEma : na, "Trend Backbone", linewidth = 2, color = color.new(accentColor, 28))

var array<label> flipLabels = array.new_label()
if showFlipLabels and qualifiedBull
    bullLabel = label.new(bar_index, high + safeAtr * labelOffsetAtr, "BULL FLIP | Q" + str.tostring(qualityScore) + " " + f_grade(qualityScore),
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_label_down,
         color = color.new(bullColor, 0),
         textcolor = headerText,
         size = labelTextSize,
         textalign = text.align_center)
    array.push(flipLabels, bullLabel)
if showFlipLabels and qualifiedBear
    bearLabel = label.new(bar_index, low - safeAtr * labelOffsetAtr, "BEAR FLIP | Q" + str.tostring(qualityScore) + " " + f_grade(qualityScore),
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_label_up,
         color = color.new(bearColor, 0),
         textcolor = headerText,
         size = labelTextSize,
         textalign = text.align_center)
    array.push(flipLabels, bearLabel)
if showWatchLabels and nearQualityFlip
    watchIsBull = rawBullFlip
    watchLabel = label.new(bar_index, watchIsBull ? high + safeAtr * labelOffsetAtr : low - safeAtr * labelOffsetAtr, (watchIsBull ? "BULL WATCH | Q" : "BEAR WATCH | Q") + str.tostring(qualityScore),
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = watchIsBull ? label.style_label_down : label.style_label_up,
         color = color.new(watchIsBull ? bullColor : bearColor, 36),
         textcolor = headerText,
         size = labelTextSize,
         textalign = text.align_center)
    array.push(flipLabels, watchLabel)

var box activeBand = na
var label activeBandLabel = na
var int activeBandDir = 0
var int activeBandScore = na
var float activeBandInvalid = na
var bool activeBandLive = false
bandFailureEvent = false

if activeBandLive and not na(activeBand)
    confirmedBandFailure = barstate.isconfirmed and (activeBandDir == 1 ? close < box.get_bottom(activeBand) : close > box.get_top(activeBand))
    if confirmedBandFailure
        bandFailureEvent := true
        if showBandFailureLabels
            failPrice = activeBandDir == 1 ? high + safeAtr * labelOffsetAtr : low - safeAtr * labelOffsetAtr
            failText = (activeBandDir == 1 ? "BULL BAND FAIL | " : "BEAR BAND FAIL | ") + str.tostring(activeBandInvalid, format.mintick)
            failLabel = label.new(bar_index, failPrice, failText,
                 xloc = xloc.bar_index,
                 yloc = yloc.price,
                 style = activeBandDir == 1 ? label.style_label_down : label.style_label_up,
                 color = color.new(neutralColor, 0),
                 textcolor = color.rgb(17, 24, 39),
                 size = labelTextSize,
                 textalign = text.align_center)
            array.push(flipLabels, failLabel)
        box.delete(activeBand)
        f_delete_label(activeBandLabel)
        activeBand := na
        activeBandLabel := na
        activeBandLive := false
        activeBandDir := 0
        activeBandScore := na
        activeBandInvalid := na
    else
        box.set_right(activeBand, bar_index + usedForwardBars)
        if not na(activeBandLabel)
            label.set_x(activeBandLabel, int(math.round((box.get_left(activeBand) + box.get_right(activeBand)) / 2.0)))
            label.set_y(activeBandLabel, (box.get_top(activeBand) + box.get_bottom(activeBand)) * 0.5)

if showProtectionBands and (qualifiedBull or qualifiedBear)
    if not na(activeBand)
        box.delete(activeBand)
    f_delete_label(activeBandLabel)
    activeBandDir := qualifiedBull ? 1 : -1
    activeBandScore := qualityScore
    bandColor = activeBandDir == 1 ? bullColor : bearColor
    bandTop = sarValue + safeAtr * protectionWidthAtr
    bandBottom = sarValue - safeAtr * protectionWidthAtr
    activeBandInvalid := activeBandDir == 1 ? bandBottom : bandTop
    activeBand := box.new(bar_index, bandTop, bar_index + usedForwardBars, bandBottom,
         xloc = xloc.bar_index,
         bgcolor = color.new(bandColor, 87),
         border_color = color.new(bandColor, 30),
         border_width = 1)
    activeBandLive := true
    if showBandLabels
        centerX = bar_index + int(math.round(usedForwardBars * 0.5))
        centerY = (bandTop + bandBottom) * 0.5
        bandText = (activeBandDir == 1 ? "BULL SAR" : "BEAR SAR") + " | Q" + str.tostring(activeBandScore) + " | STOP " + str.tostring(activeBandInvalid, format.mintick)
        activeBandLabel := label.new(centerX, centerY, bandText,
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_center,
             color = color.new(bandColor, 0),
             textcolor = headerText,
             size = labelTextSize,
             textalign = text.align_center)
    else
        activeBandLabel := na

while array.size(flipLabels) > maxFlipLabels
    oldFlip = array.shift(flipLabels)
    label.delete(oldFlip)

// One current-direction band drives the panel workflow.
liveBandNow = activeBandLive and activeBandDir == (sarBull ? 1 : -1)

// -----------------------------------------------------------------------------
// AG Pro panel
// -----------------------------------------------------------------------------
darkPanel = panelTheme == "Dark"
rowBg = f_panel_bg(not darkPanel, false)
rowAltBg = f_panel_bg(not darkPanel, true)
panelBorderActive = darkPanel ? panelBorder : color.rgb(203, 213, 225)
labelCol = darkPanel ? panelLabelCol : color.rgb(71, 85, 105)
valueCol = darkPanel ? panelValueCol : color.rgb(15, 23, 42)

freshFlip = not na(lastQualifiedBar) and bar_index - lastQualifiedBar <= 2
panelDir = liveBandNow ? activeBandDir : freshFlip ? lastQualifiedDir : sarBull ? 1 : -1
panelScore = liveBandNow or freshFlip ? lastQualifiedScore : qualityScore
panelSarBull = panelDir == 1
sideText = freshFlip ? (panelSarBull ? "Bullish Flip" : "Bearish Flip") : panelSarBull ? "Bullish Side" : "Bearish Side"
trendText = activeTrendPass ? "PASS" : "BLOCKED"
scoreText = str.tostring(panelScore) + " / 100  " + f_grade(panelScore)
distanceText = str.tostring(sarDistanceAtr, "#.##") + " ATR"
nextActionText = f_next_action(panelSarBull, activeTrendPass, freshFlip, liveBandNow)
stopText = str.tostring(sarValue, format.mintick) + (liveBandNow ? " / " + str.tostring(activeBandInvalid, format.mintick) : "")
followRateText = ftTotal > 0 ? str.tostring(int(math.round(followRate))) + "% (" + str.tostring(ftTotal) + ")" : "Building"

sideColor = panelSarBull ? bullColor : bearColor
trendColor = activeTrendPass ? bullColor : neutralColor
scoreColor = f_score_color(panelScore)
distanceColor = sarDistanceAtr >= minSarDistanceAtr ? valueCol : neutralColor
nextColor = not activeTrendPass ? neutralColor : panelSarBull ? bullColor : bearColor
followColor = na(followRate) ? valueCol : followRate >= 55 ? bullColor : followRate >= 40 ? neutralColor : bearColor

var table panel = table.new(position.top_right, 2, 7, bgcolor = panelBg, border_width = 1, frame_width = 1, border_color = panelBorder, frame_color = panelBorder)
var bool headerMerged = false

if not headerMerged
    table.cell(panel, 0, 0, "", bgcolor = headerBg)
    table.cell(panel, 1, 0, "", bgcolor = headerBg)
    table.merge_cells(panel, 0, 0, 1, 0)
    headerMerged := true

if barstate.islast
    table.set_position(panel, f_position(panelLocation))
    table.set_frame_color(panel, panelBorderActive)
    table.set_border_color(panel, panelBorderActive)
    if showPanel
        table.cell(panel, 0, 0, "AG Pro Parabolic SAR Flip Quality", text_color = headerText, bgcolor = headerBg, text_size = panelTextSize, text_halign = text.align_center)
        table.cell(panel, 0, 1, "Next Action", text_color = labelCol, bgcolor = rowBg, text_size = panelTextSize)
        table.cell(panel, 1, 1, nextActionText, text_color = nextColor, bgcolor = rowBg, text_size = panelTextSize, text_halign = text.align_right)
        table.cell(panel, 0, 2, "Flip Side", text_color = labelCol, bgcolor = rowAltBg, text_size = panelTextSize)
        table.cell(panel, 1, 2, sideText, text_color = sideColor, bgcolor = rowAltBg, text_size = panelTextSize, text_halign = text.align_right)
        table.cell(panel, 0, 3, "Trend / Score", text_color = labelCol, bgcolor = rowBg, text_size = panelTextSize)
        table.cell(panel, 1, 3, trendText + " / " + scoreText, text_color = scoreColor, bgcolor = rowBg, text_size = panelTextSize, text_halign = text.align_right)
        table.cell(panel, 0, 4, "SAR Distance", text_color = labelCol, bgcolor = rowAltBg, text_size = panelTextSize)
        table.cell(panel, 1, 4, distanceText, text_color = distanceColor, bgcolor = rowAltBg, text_size = panelTextSize, text_halign = text.align_right)
        table.cell(panel, 0, 5, "SAR / Invalid", text_color = labelCol, bgcolor = rowBg, text_size = panelTextSize)
        table.cell(panel, 1, 5, stopText, text_color = valueCol, bgcolor = rowBg, text_size = panelTextSize, text_halign = text.align_right)
        table.cell(panel, 0, 6, "Follow Rate", text_color = labelCol, bgcolor = rowAltBg, text_size = panelTextSize)
        table.cell(panel, 1, 6, followRateText, text_color = followColor, bgcolor = rowAltBg, text_size = panelTextSize, text_halign = text.align_right)
    else
        table.clear(panel, 0, 0, 1, 6)

// -----------------------------------------------------------------------------
// Alerts And Hidden Exports
// -----------------------------------------------------------------------------
alertcondition(alertQualifiedFlips and qualifiedBull, "Qualified Bullish PSAR Flip", "Parabolic SAR Flip Quality: qualified bullish PSAR flip on {{ticker}} {{interval}}.")
alertcondition(alertQualifiedFlips and qualifiedBear, "Qualified Bearish PSAR Flip", "Parabolic SAR Flip Quality: qualified bearish PSAR flip on {{ticker}} {{interval}}.")
alertcondition(alertBandFailure and bandFailureEvent, "PSAR Protection Band Failed", "Parabolic SAR Flip Quality: price closed through a live SAR protection band on {{ticker}} {{interval}}.")

plot(qualityScore, "PSAR Flip Quality Score", display = display.none)
plot(followRate, "PSAR Follow Rate", display = display.none)
plot(sarDistanceAtr, "PSAR Distance ATR", display = display.none)
````
