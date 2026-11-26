# ATC SuperTrend Pro 

- url: https://www.tradingview.com/script/xIUgf05c-ATC-SuperTrend-Pro/
- type: indicator
- pine_id: PUB;354555a81a0046efb7556f0180079cea
- version: 1.0

## Description

What It Is

ATC SuperTrend Pro is a trend-following indicator built on the classic SuperTrend framework and rebuilt from the ground up with three layers of intelligence the retail version simply does not have: a volatility regime engine that adapts the ATR multiplier to current market conditions, a volume participation classifier that tells you who is behind each trend flip, and a session-aware signal filter that focuses your attention on the time windows where trend flips have the highest historical follow-through. The result is a SuperTrend that doesn't just tell you which direction price is moving — it tells you whether the flip is worth acting on.
________________________________________

Who It's Built For

ATC SuperTrend Pro is designed for active intraday traders who already understand trend-following but are tired of getting whipsawed by low-conviction flips in choppy, low-volume conditions. It works best on liquid instruments with clearly defined session structure. The indicator ships with optimized pre-built profiles for QQQ on the 5-minute and 1-minute timeframes, and a fully configurable Custom mode for traders who want to tune it to other instruments or session styles.

________________________________________

Core Concept

At its foundation, this is still a SuperTrend indicator. Price closes below the dynamic ATR band, the trend flips bearish. Price closes above the band, the trend flips bullish. The band plots directly on the chart as your support and resistance anchor for the current trend.

What makes ATC SuperTrend Pro different is what happens around that flip before it is presented to you. Every flip is evaluated against three filters simultaneously:

1. Is the volatility environment appropriate? The indicator continuously measures where current ATR sits within its recent historical range. If volatility is in a low regime, the ATR multiplier compresses slightly, pulling the band closer to price and making the indicator more sensitive. If volatility is in a high regime, the multiplier expands, giving the band more room and reducing noise-driven flips. If the market is in a normal regime, the base multiplier is used as-is.

2. Is there meaningful participation behind the flip? Every flip is classified by the volume ratio at the moment of the flip — current bar volume divided by the rolling average volume. Flips that occur on low relative volume are classified as Low Participation. Flips that occur on high relative volume are classified as High Participation. This distinction matters: a trend flip on thin volume is structurally weaker than a flip that occurs with genuine market engagement behind it.

3. Is this flip occurring at a time of day when trend signals are worth acting on? Not all hours of the trading session are equal. Choppy midday drift produces a high percentage of false flips that reverse within a few bars. ATC SuperTrend Pro lets you restrict signal qualification to specific time windows — the opening hour, the second hour, and the final hour — so that the flips that make it through to a Qualified status are the ones occurring when market structure is most directional.

Only flips that pass all three gates simultaneously are elevated to Qualified status and trigger the primary markers and alerts.

________________________________________

ATC SuperTrend Pro Upgrades

The standard retail SuperTrend uses a fixed ATR multiplier applied uniformly regardless of whether the market is trending quietly or exploding through key levels. ATC SuperTrend Pro replaces that single fixed value with three layered upgrades:

Volatility Regime Engine — A rolling ATR percentile rank determines whether the market is currently in a Low, Normal, or High volatility regime. Each regime applies a different effective ATR multiplier using hysteresis-locked state transitions, meaning the indicator doesn't flicker back and forth between regimes on every bar when ATR sits near a threshold. The regime boundaries are defined by empirical percentile ranks (33rd and 67th percentile by default) rather than arbitrary round-number breakpoints.

Participation Classification — Volume at the time of each flip is compared against a rolling volume moving average. Every flip is tagged with one of three participation states — Low Participation, High Participation, or Exhaustion Risk — before any signal is qualified.

Exhaustion Risk Detection — A specific combination of conditions — high volume participation during a high volatility regime — is flagged as Exhaustion Risk rather than a clean directional signal. This is the market condition most commonly associated with climactic moves followed by reversal, and it is the one condition most retail SuperTrend tools would happily hand you as a clean entry signal. ATC SuperTrend Pro surfaces it explicitly and excludes it from qualified signals by default.

Session Time Window Filtering — Seven configurable signal windows let you define when the indicator can issue a Qualified signal. The pre-built QQQ profiles apply empirically validated time windows out of the box.

Timeframe Profiles — The Profile Engine loads pre-optimized parameter sets for QQQ 5-minute and QQQ 1-minute trading so new users don't have to guess at calibration.

________________________________________

Chart Visuals

The SuperTrend Line — The core line plots directly on price. In a bullish trend it sits below price, acting as dynamic support. In a bearish trend it sits above price, acting as dynamic resistance. The line color shifts cleanly between electric green (bullish) and electric red (bearish) on each confirmed flip. The line uses a break style so it does not draw through gaps.

Glow Layer — A wide, semi-transparent glow surrounds the SuperTrend line at 78% transparency, creating a visual halo effect. This is a cosmetic enhancement that makes the trend direction immediately readable on any chart background. It can be toggled off in settings.

Trend Fill — A gradient fill extends from the SuperTrend line to the price close, color-matched to the current trend direction. Fill opacity adjusts automatically by volatility regime: tighter and more opaque in low-volatility conditions, slightly more transparent in high-volatility conditions where the fill region widens. This gives you a passive visual read on the current regime without requiring you to check the HUD.

Candle Tinting — An optional setting tints every candle with a light wash of the current trend color at 72% transparency. Off by default.

Qualified Flip Markers (Q triangles) — The primary actionable markers. A green upward triangle with a white "Q" label appears below the bar on a Qualified Bull Flip. A red downward triangle with a white "Q" label appears above the bar on a Qualified Bear Flip. These are the only markers that trigger the primary alert conditions.

Low Participation Markers (small circles) — Cyan circles mark flips that occurred on below-average volume. These flips did not pass the participation filter for a Qualified signal. They are visible context — not action items.

High Participation Markers (small diamonds) — Gold diamonds mark flips that occurred on above-average volume but did not qualify due to time window filtering or another gate. These are structurally stronger flips than the circles, and they are worth noting even when they fall outside the active signal window.

Exhaustion Risk Markers (X crosses) — Orange X marks appear on flips classified as Exhaustion Risk — high participation volume during a high volatility regime. These are the most important non-qualified flips to understand. They are not entry signals. They are structural warnings.

Volatility Regime Change Markers (tiny accent X) — A small gold-tinted X appears at the bottom of the chart whenever the volatility regime transitions between Low, Normal, and High. This is a background awareness marker, not a trading signal.

________________________________________

HUD Breakdown

The HUD is a two-column table that anchors to your chosen chart corner and stays current on every bar close. Each row reflects a live or persistent state:

Profile — Displays the active profile: QQQ 5m, QQQ 1m, or Custom. Gold text.

Trend — Current SuperTrend direction: Bullish (green) or Bearish (red). This updates on every confirmed bar close.

Signal Window — Active or Filtered. Shows whether the current bar falls within the configured actionable time window. Green when active, grey when filtered. Useful for understanding in real time whether a flip occurring right now would qualify.

Window Mode — The abbreviated label of the current time window configuration (e.g., "Open + Final", "2nd + Final").

Action Mode — The current participation mode filter displayed in abbreviated form (e.g., "Low Part.", "Non-Exh.", "All Flips").

Vol Regime — The current volatility regime: Low (gold), Normal (grey), or High (red). Updates whenever the regime transitions.

Eff. Mult — The effective ATR multiplier currently in use after regime adjustment. In a Low volatility regime this will be less than the base multiplier. In a High volatility regime it will be greater.

Current Part. — The current bar's volume participation ratio expressed as a multiple of the rolling average (e.g., "0.84×" means below-average volume, "2.31×" means more than double average volume). Color-coded: cyan for low participation, gold for high.

Last Flip — The direction of the most recent trend flip (Bull Flip or Bear Flip).

Flip Type — The participation classification assigned to the last flip: Low Participation, High Participation, or Exhaustion Risk. Color matches the corresponding marker color.

Qualified — Whether the last flip achieved Qualified status (green "Qualified") or was filtered out (grey "Filtered").

________________________________________

Logic Layers

Reading the layers together is what separates ATC SuperTrend Pro from a standard flip-and-go indicator.

Layer 1: Trend Direction — The SuperTrend line tells you what direction the tool currently calls. This is the structural backbone. Every other layer is commentary on that backbone.

Layer 2: Volatility Regime — The regime tells you how tight or loose the market is relative to its own recent history. A Low regime means the market is coiling. A High regime means the market is already expanded. Flips in High regime conditions are more suspect — they may be climactic rather than initiating.

Layer 3: Participation — Participation tells you whether the flip had genuine volume engagement or whether it was a thin-air move. Low-participation flips in a trending environment sometimes resolve as continuation after a shallow pullback touches the SuperTrend band. High-participation flips with the trend have the most structural conviction behind them.

Layer 4: Exhaustion Risk — The highest-priority warning in the system. When all three of the following are simultaneously true — a flip occurred, volume is elevated above the participation threshold, and the market is in a High volatility regime — the tool flags Exhaustion Risk. This combination historically corresponds to moves that spike through the SuperTrend band on a burst of volume only to reverse back. Do not treat this as a confirmed directional flip.

Layer 5: Time Window — The time window filter is the final gate. Even a structurally clean flip — Low participation, Normal regime, correct direction — will not receive Qualified status if it occurs during a filtered time window. This is by design. Qualified signals are reserved for periods of the session where trend initiation is most reliable.

________________________________________

Alerts

ATC SuperTrend Pro includes eight distinct alert conditions covering every layer of the system.

Qualified Bull Flip — Fires on a confirmed bullish flip that passes all three gates: time window, participation mode, and exhaustion exclusion. This is the primary long signal alert.

Qualified Bear Flip — Fires on a confirmed bearish flip that passes all three gates. This is the primary short signal alert.

Low Participation Bull Flip — Fires on a bullish flip classified as Low Participation, regardless of time window qualification.

Low Participation Bear Flip — Fires on a bearish flip classified as Low Participation, regardless of time window qualification.

High Participation Bull Flip — Fires on a bullish flip classified as High Participation but not Exhaustion Risk.

High Participation Bear Flip — Fires on a bearish flip classified as High Participation but not Exhaustion Risk.

Exhaustion-Risk Bull Flip — Fires when a bullish flip occurs simultaneously with High Participation and a High Volatility regime. Use as a caution alert, not an entry trigger.

Exhaustion-Risk Bear Flip — Same logic for bearish direction.

Volatility Regime Change — Fires whenever the volatility regime transitions between Low, Normal, and High.

Any Flip — Fires on every confirmed trend flip regardless of classification. Useful for monitoring purposes when you want to observe all flip activity.

All flip-based alerts respect the Confirm Markers / Alerts On Bar Close setting, meaning they will not fire mid-bar — only on a confirmed bar close.

________________________________________

How to Trade (Step-by-Step)

Step 1: Select your profile. If you are trading QQQ on the 5-minute chart, select QQQ 5-Minute. If you are on the 1-minute chart, select QQQ 1-Minute. For other instruments or timeframes, select Custom and configure the parameters manually.

Step 2: Confirm the signal window is Active. Check the HUD's Signal Window row before taking any action on a flip. If it reads "Filtered," you are outside the active time window. The indicator is still tracking trend direction, but Qualified signals are not being issued. You can watch the flip and mark the level, but wait for a time-window-active retest or a new flip within the active window before acting.

Step 3: Wait for a Q marker. Only flips that print the triangle with the white Q label are Qualified signals. Do not act on circles, diamonds, or X marks as primary entries. Those markers are classification information.

Step 4: Confirm the Flip Type in the HUD. After a Q marker prints, check the Flip Type row in the HUD. "Low Participation" means the flip occurred on thin volume — the move may be cleaner but should be confirmed with continuation. "High Participation" means strong volume engagement — this flip has more conviction, though the participation alone does not guarantee follow-through.

Step 5: Note the volatility regime. If the Vol Regime row shows "High" and a flip just printed, proceed with tighter sizing than normal. High-regime flips on elevated volume are the conditions where Exhaustion Risk is most likely. A High regime with a Qualified signal that is classified as High Participation is structurally the strongest setup the tool will generate — but it is also the setup most worth confirming with at least one or two bars of follow-through before adding size.

Step 6: Use the SuperTrend line as your stop anchor. Once in a trade, the SuperTrend line is your structural stop reference. In a long trade, price should remain above the line. A confirmed close back below the line flips the trend and is your exit signal. Do not move your stop to breakeven prematurely if price is simply oscillating near the line within a Low volatility regime — the tighter multiplier is doing its job.

Step 7: Respect Exhaustion Risk X markers. If an X appears on a flip that was otherwise pointing in your favor, treat it as a warning to reduce size or stay flat rather than chasing the move. These prints are the system telling you that the flip is accompanied by the exact conditions most associated with reversal, not continuation.

Step 8: Set your preferred alerts. For a clean setup, set alerts on Qualified Bull Flip and Qualified Bear Flip only. If you want supplementary context, also set the Volatility Regime Change and Exhaustion-Risk alerts so you are notified of structural shifts even when no Qualified flip is pending.

________________________________________

Settings Reference

Profile Engine

•	Timeframe Profile — Selects QQQ 5-Minute, QQQ 1-Minute, or Custom. When a pre-built profile is selected, the Custom input groups below are overridden by the profile values. Custom exposes all parameters for manual tuning.
	
Custom SuperTrend Core (active in Custom mode only)

•	Custom ATR Length — The lookback period for ATR calculation. Shorter values respond faster to volatility shifts; longer values are smoother. Default: 10.

•	Custom Base ATR Multiplier — The base envelope width as a multiple of ATR. This value is further modified by the regime engine. Default: 2.5.

•	Source — Price anchor for the ATR envelope. hl2 (the average of high and low) is the classic SuperTrend source and the recommended starting point.

Custom Volatility Regimes (active in Custom mode only)

•	Custom Regime Lookback — The number of bars used to establish the ATR percentile baseline. Default: 100.

•	Custom Low-Vol Percentile — ATR readings below this percentile rank are classified as Low volatility. Default: 33.

•	Custom High-Vol Percentile — ATR readings above this percentile rank are classified as High volatility. Default: 67.

•	Custom Regime Hysteresis Buffer (%) — A buffer around each regime threshold that prevents the indicator from rapidly switching regimes on marginal ATR readings. Default: 3.0%.

•	Custom Low-Vol Mult Adjust — Multiplier scaling factor applied in Low volatility regimes. Values below 1.0 tighten the band. Default: 0.85.

•	Custom High-Vol Mult Adjust — Multiplier scaling factor applied in High volatility regimes. Values above 1.0 widen the band. Default: 1.15.

Custom Participation Classification (active in Custom mode only)

•	Enable Participation Classification — Toggles the volume participation layer on or off.

•	Custom Participation MA Length — The rolling average lookback for the volume baseline. Default: 20.

•	Custom High Participation Threshold (× MA) — The volume multiple at which a flip is classified as High Participation. Default: 1.5×, meaning volume must be 50% above its rolling average.

•	Tag High-Vol / High-Participation Flips As Exhaustion Risk — When enabled, flips meeting both the High Participation and High Volatility regime criteria are tagged as Exhaustion Risk rather than High Participation.

Signal Qualification

•	Confirm Markers / Alerts On Bar Close — When enabled, no markers, HUD flip updates, or alerts fire until the bar is fully confirmed. Recommended for live trading to avoid acting on signals that repaint within the bar.

•	Custom Actionable Signal Mode — Defines which participation class of flips can achieve Qualified status. Options: Low Participation Only, High Participation Only, All Non-Exhaustion, All Flips.

•	Exclude Exhaustion-Risk Flips From Qualified Signals — When enabled, Exhaustion Risk flips are never elevated to Qualified status regardless of other criteria. On by default.

Signal Time Windows

•	Signal Time Zone — The timezone used for all session window definitions. Default: America/Chicago (CT).

•	Custom Actionable Signal Window — Selects which periods of the session can produce Qualified signals. Options: All Day, Opening Hour + Final Hour, Second Hour + Final Hour, Avoid Afternoon Drift, Opening Hour Only, Second Hour Only, Final Hour Only.

•	Opening Hour Window — Defines the opening window session string. Default: 0830–0929 CT.

•	Second Hour Window — Defines the second-hour window. Default: 0930–1029 CT.
•	Final Hour Window — Defines the final-hour window. Default: 1400–1459 CT.

•	Afternoon Drift Window To Avoid — Defines the midday drift window excluded when using the Avoid Afternoon Drift mode. Default: 1230–1359 CT.

Premium Visuals

•	Shade Trend Fill — Enables the gradient fill between the SuperTrend line and price close. On by default.

•	Show Line Glow — Enables the wide semi-transparent glow layer behind the SuperTrend line. On by default.

•	Tint Candles By Trend — Applies a light color wash to candles matching the current trend direction. Off by default.

•	Show Non-Qualified Flip Class Markers — When enabled, Low Participation circles, High Participation diamonds, and Exhaustion Risk X marks are drawn for flips that did not achieve Qualified status. These are informational context markers. Recommended on.

•	Core Line Width — The width of the primary SuperTrend line in pixels. Range 1–5. Default: 3.

Colors All default colors are fully customizable: Electric Bullish Trend, Electric Bearish Trend, Low Participation Accent, High Participation Accent, Exhaustion-Risk Accent, Neutral, and Premium Accent.

HUD

•	Show HUD — Toggles the HUD on or off.

•	HUD Position — Anchors the HUD to Top Right, Top Left, Bottom Right, or Bottom Left.

•	HUD Theme — Dark (dark background, white text) or Light (light background, dark text).

________________________________________
Instruments & Timeframes

ATC SuperTrend Pro was developed and validated primarily on QQQ on the 5-minute and 1-minute timeframes, for which pre-built profiles are included. The Custom mode is suitable for tuning to other liquid equities, equity index ETFs, and futures instruments on intraday timeframes where RTH session structure is well-defined. The indicator is a single-timeframe tool — it does not request external timeframe data and operates entirely on the chart's current timeframe and symbol.

Allow a minimum of 100 bars of warmup before treating signals as fully calibrated. On short lookback timeframes with limited history, the ATR percentile baseline and volume moving average will stabilize as more data accumulates.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ATConcepts

// ==========================================================================
// ATC SuperTrend Pro — v4.0
// Part of the ATC Free-Tier Library
//
// Author:   Ascend Trading Concepts
// Website:  ascendtradingconcepts.com
// License:  Free for personal use. Redistribution requires attribution.
//
// v4.0 Revision Notes:
//   1. Added Timeframe Profile engine:
//        - QQQ 5-Minute Profile
//        - QQQ 1-Minute Profile
//        - Custom
//   2. Added optimized QQQ 5-minute settings profile:
//        - ATR Length: 10
//        - Base ATR Multiplier: 2.5
//        - Participation Threshold: 1.5
//        - Actionable Mode: Low Participation Only
//        - Signal Window: Opening Hour + Final Hour
//   3. Added optimized QQQ 1-minute settings profile:
//        - ATR Length: 7
//        - Base ATR Multiplier: 2.2
//        - Participation Threshold: 1.5
//        - Actionable Mode: Low Participation Only
//        - Signal Window: Second Hour + Final Hour
//   4. Added Second Hour signal window support.
// ==========================================================================

//@version=6
indicator("ATC SuperTrend Pro v4.0", shorttitle="ST Pro v4.0",
     overlay=true, precision=4, max_labels_count=100)

// ==========================================================================
// Section B — Inputs
// ==========================================================================

grpProfile = "Profile Engine"
profileMode = input.string("QQQ 5-Minute", "Timeframe Profile",
     options=["QQQ 5-Minute", "QQQ 1-Minute", "Custom"], group=grpProfile,
     tooltip="Select an optimized profile or choose Custom to manually control all settings.")

grpST = "Custom SuperTrend Core"
customAtrLen = input.int(10, "Custom ATR Length", minval=1, group=grpST)
customAtrMult = input.float(2.5, "Custom Base ATR Multiplier", minval=0.5, step=0.1, group=grpST)
srcMode = input.string("hl2", "Source",
     options=["hl2", "close", "hlc3", "ohlc4"], group=grpST,
     tooltip="Price anchor for the ATR envelope. hl2 is the classic SuperTrend source.")

grpRegime = "Custom Volatility Regimes"
customRegimeLen = input.int(100, "Custom Regime Lookback", minval=30, group=grpRegime)
customLowPct = input.int(33, "Custom Low-Vol Percentile", minval=10, maxval=45, group=grpRegime)
customHighPct = input.int(67, "Custom High-Vol Percentile", minval=55, maxval=90, group=grpRegime)
customRegimeHystPct = input.float(3.0, "Custom Regime Hysteresis Buffer (%)", minval=0.0, maxval=20.0, step=0.5, group=grpRegime)
customLowMultAdj = input.float(0.85, "Custom Low-Vol Mult Adjust", minval=0.5, maxval=1.0, step=0.05, group=grpRegime)
customHighMultAdj = input.float(1.15, "Custom High-Vol Mult Adjust", minval=1.0, maxval=2.0, step=0.05, group=grpRegime)

grpPart = "Custom Participation Classification"
useParticipation = input.bool(true, "Enable Participation Classification", group=grpPart)
customVolLen = input.int(20, "Custom Participation MA Length", minval=5, group=grpPart)
customParticipationThresh = input.float(1.5, "Custom High Participation Threshold (× MA)", minval=1.0, step=0.05, group=grpPart)
exhaustionInHighVol = input.bool(true, "Tag High-Vol / High-Participation Flips As Exhaustion Risk", group=grpPart)

grpSignal = "Signal Qualification"
confirmOnClose = input.bool(true, "Confirm Markers / Alerts On Bar Close", group=grpSignal,
     tooltip="When enabled, flip markers, HUD flip updates, and alerts only trigger after the bar closes.")
customActionableMode = input.string("Low Participation Only", "Custom Actionable Signal Mode",
     options=["Low Participation Only", "High Participation Only", "All Non-Exhaustion", "All Flips"], group=grpSignal)
excludeExhaustion = input.bool(true, "Exclude Exhaustion-Risk Flips From Qualified Signals", group=grpSignal)

grpSession = "Signal Time Windows"
signalTimezone = input.string("America/Chicago", "Signal Time Zone",
     options=["America/Chicago", "America/New_York", "Etc/UTC"], group=grpSession)
customTimeFilterMode = input.string("Opening Hour + Final Hour", "Custom Actionable Signal Window",
     options=["All Day", "Opening Hour + Final Hour", "Second Hour + Final Hour", "Avoid Afternoon Drift", "Opening Hour Only", "Second Hour Only", "Final Hour Only"], group=grpSession)
openWindow = input.session("0830-0929", "Opening Hour Window", group=grpSession)
secondWindow = input.session("0930-1029", "Second Hour Window", group=grpSession)
finalWindow = input.session("1400-1459", "Final Hour Window", group=grpSession)
avoidWindow = input.session("1230-1359", "Afternoon Drift Window To Avoid", group=grpSession)

grpVisual = "Premium Visuals"
useFill = input.bool(true, "Shade Trend Fill", group=grpVisual)
useGlow = input.bool(true, "Show Line Glow", group=grpVisual)
colorBars = input.bool(false, "Tint Candles By Trend", group=grpVisual)
showRawClassMarkers = input.bool(true, "Show Non-Qualified Flip Class Markers", group=grpVisual)
lineWidth = input.int(3, "Core Line Width", minval=1, maxval=5, group=grpVisual)

grpColors = "Colors"
bullCol = input.color(#00E676, "Electric Bullish Trend", group=grpColors)
bearCol = input.color(#FF1744, "Electric Bearish Trend", group=grpColors)
lowPartCol = input.color(#00E5FF, "Low Participation Accent", group=grpColors)
highPartCol = input.color(#FFD166, "High Participation Accent", group=grpColors)
exhaustCol = input.color(#FF9100, "Exhaustion-Risk Accent", group=grpColors)
neutCol = input.color(#9CA3AF, "Neutral", group=grpColors)
accCol = input.color(#D4AF37, "Premium Accent", group=grpColors)

grpHUD = "HUD"
showHUD = input.bool(true, "Show HUD", group=grpHUD)
hudPos = input.string("Top Right", "HUD Position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpHUD)
hudTheme = input.string("Dark", "HUD Theme",
     options=["Dark", "Light"], group=grpHUD)

// ==========================================================================
// Section C — Profile Engine
// ==========================================================================

isQQQ5 = profileMode == "QQQ 5-Minute"
isQQQ1 = profileMode == "QQQ 1-Minute"
isCustom = profileMode == "Custom"

effAtrLen = isQQQ1 ? 7 : isQQQ5 ? 10 : customAtrLen
effAtrMult = isQQQ1 ? 2.2 : isQQQ5 ? 2.5 : customAtrMult
effRegimeLen = isCustom ? customRegimeLen : 100
effLowPct = isCustom ? customLowPct : 33
effHighPct = isCustom ? customHighPct : 67
effRegimeHystPct = isCustom ? customRegimeHystPct : 3.0
effLowMultAdj = isCustom ? customLowMultAdj : 0.85
effHighMultAdj = isCustom ? customHighMultAdj : 1.15
effVolLen = isCustom ? customVolLen : 20
effParticipationThresh = isCustom ? customParticipationThresh : 1.5

effActionableMode = isCustom ? customActionableMode : "Low Participation Only"
effTimeFilterMode = isQQQ1 ? "Second Hour + Final Hour" : isQQQ5 ? "Opening Hour + Final Hour" : customTimeFilterMode

profileShort = isQQQ1 ? "QQQ 1m" : isQQQ5 ? "QQQ 5m" : "Custom"

// ==========================================================================
// Section D — Helper Logic
// ==========================================================================

srcPrice = switch srcMode
    "close" => close
    "hlc3"  => hlc3
    "ohlc4" => ohlc4
    => hl2

hudPosition = switch hudPos
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    => position.bottom_left

f_inSession(sess) =>
    not na(time(timeframe.period, sess, signalTimezone))

inOpenWindow = f_inSession(openWindow)
inSecondWindow = f_inSession(secondWindow)
inFinalWindow = f_inSession(finalWindow)
inAvoidWindow = f_inSession(avoidWindow)

timeAllowed = switch effTimeFilterMode
    "All Day" => true
    "Opening Hour + Final Hour" => inOpenWindow or inFinalWindow
    "Second Hour + Final Hour" => inSecondWindow or inFinalWindow
    "Avoid Afternoon Drift" => not inAvoidWindow
    "Opening Hour Only" => inOpenWindow
    "Second Hour Only" => inSecondWindow
    "Final Hour Only" => inFinalWindow
    => true

// ==========================================================================
// Section E — Core Calculations
// ==========================================================================

atrVal = ta.atr(effAtrLen)

// ==========================================================================
// Section F — Volatility Regime Engine
// ==========================================================================

lowThresh = ta.percentile_linear_interpolation(atrVal, effRegimeLen, effLowPct)
highThresh = ta.percentile_linear_interpolation(atrVal, effRegimeLen, effHighPct)

regimeBufferLow = not na(lowThresh) ? lowThresh * effRegimeHystPct * 0.01 : na
regimeBufferHigh = not na(highThresh) ? highThresh * effRegimeHystPct * 0.01 : na

lowEnter = not na(lowThresh) and not na(regimeBufferLow) ? lowThresh - regimeBufferLow : na
lowExit = not na(lowThresh) and not na(regimeBufferLow) ? lowThresh + regimeBufferLow : na
highEnter = not na(highThresh) and not na(regimeBufferHigh) ? highThresh + regimeBufferHigh : na
highExit = not na(highThresh) and not na(regimeBufferHigh) ? highThresh - regimeBufferHigh : na

var string regimeState = "Normal"
priorRegime = na(regimeState[1]) ? "Normal" : regimeState[1]
nextRegime = priorRegime

if na(atrVal) or na(lowThresh) or na(highThresh)
    nextRegime := "Normal"
else if priorRegime == "Low"
    nextRegime := atrVal > lowExit ? "Normal" : "Low"
    if atrVal > highEnter
        nextRegime := "High"
else if priorRegime == "High"
    nextRegime := atrVal < highExit ? "Normal" : "High"
    if atrVal < lowEnter
        nextRegime := "Low"
else
    if atrVal < lowEnter
        nextRegime := "Low"
    else if atrVal > highEnter
        nextRegime := "High"
    else
        nextRegime := "Normal"

regimeState := nextRegime
regime = regimeState

regimeChangedRaw = regime != priorRegime and not na(atrVal[1])
regimeChanged = regimeChangedRaw and (not confirmOnClose or barstate.isconfirmed)

regimeMult = regime == "Low" ? effAtrMult * effLowMultAdj : regime == "High" ? effAtrMult * effHighMultAdj : effAtrMult

// ==========================================================================
// Section G — SuperTrend Engine
// ==========================================================================

upBasic = srcPrice + regimeMult * atrVal
dnBasic = srcPrice - regimeMult * atrVal

var float upBand = na
var float dnBand = na
var int dir = 1

upBand := na(upBand[1]) ? upBasic : upBasic < upBand[1] or close[1] > upBand[1] ? upBasic : upBand[1]
dnBand := na(dnBand[1]) ? dnBasic : dnBasic > dnBand[1] or close[1] < dnBand[1] ? dnBasic : dnBand[1]

prevDir = nz(dir[1], 1)
newDir = prevDir

if na(atrVal[1])
    newDir := 1
else if prevDir == -1 and close > upBand
    newDir := 1
else if prevDir == 1 and close < dnBand
    newDir := -1

dir := newDir

rawFlip = dir != prevDir and not na(atrVal[1])
signalFlip = rawFlip and (not confirmOnClose or barstate.isconfirmed)
stLine = dir == 1 ? dnBand : upBand

// ==========================================================================
// Section H — Participation Classification
// ==========================================================================

volMa = ta.sma(volume, effVolLen)
participationRatio = not na(volume) and not na(volMa) and volMa > 0 ? volume / volMa : 1.0

highParticipation = useParticipation and participationRatio >= effParticipationThresh
lowParticipation = not useParticipation or participationRatio < effParticipationThresh
exhaustionRisk = signalFlip and exhaustionInHighVol and highParticipation and regime == "High"

participationText = "Low Participation"
if highParticipation
    participationText := "High Participation"
if exhaustionRisk
    participationText := "Exhaustion Risk"

participationAllowed = switch effActionableMode
    "Low Participation Only" => lowParticipation
    "High Participation Only" => highParticipation
    "All Non-Exhaustion" => not exhaustionRisk
    "All Flips" => true
    => lowParticipation

qualifiedFlip = signalFlip and timeAllowed and participationAllowed and (not excludeExhaustion or not exhaustionRisk)

qualifiedBull = qualifiedFlip and dir == 1
qualifiedBear = qualifiedFlip and dir == -1

classOnlyFlip = signalFlip and showRawClassMarkers and not qualifiedFlip

lowPartBull = classOnlyFlip and lowParticipation and not exhaustionRisk and dir == 1
lowPartBear = classOnlyFlip and lowParticipation and not exhaustionRisk and dir == -1

highPartBull = classOnlyFlip and highParticipation and not exhaustionRisk and dir == 1
highPartBear = classOnlyFlip and highParticipation and not exhaustionRisk and dir == -1

exhaustBull = classOnlyFlip and exhaustionRisk and dir == 1
exhaustBear = classOnlyFlip and exhaustionRisk and dir == -1

// Track last flip status.
var string lastFlipStatus = "None"
var string lastFlipParticipation = "—"
var string lastFlipQualification = "—"
var int lastFlipBar = na
var float lastFlipVolRatio = na
var string lastFlipRegime = "—"

if signalFlip
    dirText = dir == 1 ? "Bull" : "Bear"
    lastFlipStatus := dirText + " Flip"
    lastFlipParticipation := participationText
    lastFlipQualification := qualifiedFlip ? "Qualified" : "Filtered"
    lastFlipBar := bar_index
    lastFlipVolRatio := participationRatio
    lastFlipRegime := regime

barsSinceFlip = na(lastFlipBar) ? na : bar_index - lastFlipBar

// ==========================================================================
// Section I — Premium Plotting
// ==========================================================================

stColor = dir == 1 ? bullCol : bearCol
glowColor = useGlow ? color.new(stColor, 78) : na

fillOpacity = regime == "High" ? 84 : regime == "Low" ? 91 : 88
fillColor = useFill ? color.new(stColor, fillOpacity) : na

stGlowPlot = plot(stLine, "SuperTrend Glow", color=glowColor, linewidth=7, style=plot.style_linebr)
stPlot = plot(stLine, "SuperTrend Core", color=stColor, linewidth=lineWidth, style=plot.style_linebr)
pricePlot = plot(close, title="Price Reference", display=display.none)

fill(stPlot, pricePlot, color=fillColor, title="Trend Fill")

barcolor(colorBars ? color.new(stColor, 72) : na, title="Trend Candle Tint")

plotshape(qualifiedBull, title="Qualified Bull Flip",
     style=shape.triangleup, location=location.belowbar, color=bullCol, size=size.normal, text="Q", textcolor=color.white)

plotshape(qualifiedBear, title="Qualified Bear Flip",
     style=shape.triangledown, location=location.abovebar, color=bearCol, size=size.normal, text="Q", textcolor=color.white)

plotshape(lowPartBull, title="Low Participation Bull Flip",
     style=shape.circle, location=location.belowbar, color=color.new(lowPartCol, 10), size=size.tiny)

plotshape(lowPartBear, title="Low Participation Bear Flip",
     style=shape.circle, location=location.abovebar, color=color.new(lowPartCol, 10), size=size.tiny)

plotshape(highPartBull, title="High Participation Bull Flip",
     style=shape.diamond, location=location.belowbar, color=color.new(highPartCol, 0), size=size.tiny)

plotshape(highPartBear, title="High Participation Bear Flip",
     style=shape.diamond, location=location.abovebar, color=color.new(highPartCol, 0), size=size.tiny)

plotshape(exhaustBull, title="Exhaustion-Risk Bull Flip",
     style=shape.xcross, location=location.belowbar, color=exhaustCol, size=size.small)

plotshape(exhaustBear, title="Exhaustion-Risk Bear Flip",
     style=shape.xcross, location=location.abovebar, color=exhaustCol, size=size.small)

plotshape(regimeChanged, title="Volatility Regime Change",
     style=shape.xcross, location=location.bottom, color=color.new(accCol, 25), size=size.tiny)

// ==========================================================================
// Section J — Premium HUD
// ==========================================================================

var table hud = na

hudBgColor = hudTheme == "Dark" ? #111318 : #F8F9FA
hudValueBg = hudTheme == "Dark" ? #171A21 : #FFFFFF
hudTextColor = hudTheme == "Dark" ? color.white : #1F2937
hudDimColor = hudTheme == "Dark" ? color.new(color.white, 35) : color.new(#1F2937, 35)
hudGridColor = hudTheme == "Dark" ? color.new(accCol, 68) : color.new(accCol, 55)

if showHUD and na(hud)
    hud := table.new(hudPosition, 2, 11,
         bgcolor=hudBgColor,
         frame_color=accCol,
         frame_width=2,
         border_color=hudGridColor,
         border_width=1)

if not showHUD and not na(hud)
    table.delete(hud)
    hud := na

if showHUD and barstate.islast and not na(hud)
    trendText = dir == 1 ? "Bullish" : "Bearish"
    trendColor = dir == 1 ? bullCol : bearCol

    regimeColor = regime == "Low" ? accCol : regime == "High" ? bearCol : neutCol

    timeStatusText = timeAllowed ? "Active" : "Filtered"
    timeStatusColor = timeAllowed ? bullCol : neutCol

    modeShort = effActionableMode == "Low Participation Only" ? "Low Part." : effActionableMode == "High Participation Only" ? "High Part." : effActionableMode == "All Non-Exhaustion" ? "Non-Exh." : "All Flips"

    windowShort = effTimeFilterMode == "Opening Hour + Final Hour" ? "Open + Final" : effTimeFilterMode == "Second Hour + Final Hour" ? "2nd + Final" : effTimeFilterMode == "Avoid Afternoon Drift" ? "Avoid Drift" : effTimeFilterMode

    participationColor = lastFlipParticipation == "Low Participation" ? lowPartCol : lastFlipParticipation == "High Participation" ? highPartCol : lastFlipParticipation == "Exhaustion Risk" ? exhaustCol : hudDimColor

    qualificationColor = lastFlipQualification == "Qualified" ? bullCol : lastFlipQualification == "Filtered" ? neutCol : hudDimColor

    volColor = participationRatio >= effParticipationThresh ? highPartCol : lowPartCol
    lastVolColor = na(lastFlipVolRatio) ? hudDimColor : lastFlipVolRatio >= effParticipationThresh ? highPartCol : lowPartCol

    barsStr = na(barsSinceFlip) ? "—" : str.tostring(barsSinceFlip) + " bars"
    currentVolStr = str.tostring(participationRatio, "#.##") + "×"
    lastVolStr = na(lastFlipVolRatio) ? "—" : str.tostring(lastFlipVolRatio, "#.##") + "×"

    table.cell(hud, 0, 0, "Profile", text_color=hudDimColor, bgcolor=hudBgColor, text_size=size.small)
    table.cell(hud, 1, 0, profileShort, text_color=accCol, bgcolor=hudValueBg, text_size=size.small)

    table.cell(hud, 0, 1, "Trend", text_color=hudDimColor, bgcolor=hudBgColor, text_size=size.small)
    table.cell(hud, 1, 1, trendText, text_color=trendColor, bgcolor=hudValueBg, text_size=size.small)

    table.cell(hud, 0, 2, "Signal Window", text_color=hudDimColor, bgcolor=hudBgColor, text_size=size.small)
    table.cell(hud, 1, 2, timeStatusText, text_color=timeStatusColor, bgcolor=hudValueBg, text_size=size.small)

    table.cell(hud, 0, 3, "Window Mode", text_color=hudDimColor, bgcolor=hudBgColor, text_size=size.small)
    table.cell(hud, 1, 3, windowShort, text_color=hudTextColor, bgcolor=hudValueBg, text_size=size.small)

    table.cell(hud, 0, 4, "Action Mode", text_color=hudDimColor, bgcolor=hudBgColor, text_size=size.small)
    table.cell(hud, 1, 4, modeShort, text_color=hudTextColor, bgcolor=hudValueBg, text_size=size.small)

    table.cell(hud, 0, 5, "Vol Regime", text_color=hudDimColor, bgcolor=hudBgColor, text_size=size.small)
    table.cell(hud, 1, 5, regime, text_color=regimeColor, bgcolor=hudValueBg, text_size=size.small)

    table.cell(hud, 0, 6, "Eff. Mult", text_color=hudDimColor, bgcolor=hudBgColor, text_size=size.small)
    table.cell(hud, 1, 6, str.tostring(regimeMult, "#.##") + "×", text_color=hudTextColor, bgcolor=hudValueBg, text_size=size.small)

    table.cell(hud, 0, 7, "Current Part.", text_color=hudDimColor, bgcolor=hudBgColor, text_size=size.small)
    table.cell(hud, 1, 7, currentVolStr, text_color=volColor, bgcolor=hudValueBg, text_size=size.small)

    table.cell(hud, 0, 8, "Last Flip", text_color=hudDimColor, bgcolor=hudBgColor, text_size=size.small)
    table.cell(hud, 1, 8, lastFlipStatus, text_color=hudTextColor, bgcolor=hudValueBg, text_size=size.small)

    table.cell(hud, 0, 9, "Flip Type", text_color=hudDimColor, bgcolor=hudBgColor, text_size=size.small)
    table.cell(hud, 1, 9, lastFlipParticipation, text_color=participationColor, bgcolor=hudValueBg, text_size=size.small)

    table.cell(hud, 0, 10, "Qualified", text_color=hudDimColor, bgcolor=hudBgColor, text_size=size.small)
    table.cell(hud, 1, 10, lastFlipQualification, text_color=qualificationColor, bgcolor=hudValueBg, text_size=size.small)

// ==========================================================================
// Section K — Alerts
// ==========================================================================

alertcondition(qualifiedBull, "Qualified Bull Flip",
     "SuperTrend Pro: Qualified bullish flip based on participation mode, active profile, and signal time window.")

alertcondition(qualifiedBear, "Qualified Bear Flip",
     "SuperTrend Pro: Qualified bearish flip based on participation mode, active profile, and signal time window.")

alertcondition(signalFlip and lowParticipation and dir == 1, "Low Participation Bull Flip",
     "SuperTrend Pro: Bullish flip classified as Low Participation.")

alertcondition(signalFlip and lowParticipation and dir == -1, "Low Participation Bear Flip",
     "SuperTrend Pro: Bearish flip classified as Low Participation.")

alertcondition(signalFlip and highParticipation and not exhaustionRisk and dir == 1, "High Participation Bull Flip",
     "SuperTrend Pro: Bullish flip classified as High Participation.")

alertcondition(signalFlip and highParticipation and not exhaustionRisk and dir == -1, "High Participation Bear Flip",
     "SuperTrend Pro: Bearish flip classified as High Participation.")

alertcondition(exhaustionRisk and dir == 1, "Exhaustion-Risk Bull Flip",
     "SuperTrend Pro: Bullish flip occurred with High Participation during a High Volatility regime.")

alertcondition(exhaustionRisk and dir == -1, "Exhaustion-Risk Bear Flip",
     "SuperTrend Pro: Bearish flip occurred with High Participation during a High Volatility regime.")

alertcondition(regimeChanged, "Volatility Regime Change",
     "SuperTrend Pro: Volatility regime changed.")

alertcondition(signalFlip, "Any Flip",
     "SuperTrend Pro: Trend flipped based on the current signal confirmation setting.")
````
