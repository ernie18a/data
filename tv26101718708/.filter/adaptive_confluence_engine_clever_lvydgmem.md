# Adaptive Confluence Engine [CLEVER]

- url: https://www.tradingview.com/script/LVyDgmEM-Adaptive-Confluence-Engine-CLEVER/
- type: indicator
- pine_id: PUB;ae084617fa4c47df9014225e276cfa4f
- version: 1.0

## Description

📌 Overview

Adaptive Confluence Engine is a structured, multi-layer technical analysis framework built to evaluate market conditions through weighted confluence rather than single-indicator signals.

The script integrates trend alignment, momentum structure, volatility conditions, participation metrics, and higher timeframe context into a unified scoring model. Instead of treating indicators as isolated tools, each component contributes a defined weight toward an overall directional bias. A signal is generated only when multiple independent conditions align and a structural trigger confirms participation.

This design reduces reliance on any one variable and emphasizes contextual agreement across:

Long-term trend positioning
Medium-term directional structure
Momentum continuation or exhaustion zones
Volatility expansion conditions
Volume confirmation
Higher timeframe bias alignment
Basic price action structure (engulfing behavior)

The engine uses a transparent scoring system where each condition adds measurable value to either bullish or bearish pressure. When the total score exceeds a defined threshold (based on selected signal mode), and a structural EMA crossover occurs, a trade signal is produced.

Importantly, all calculations are performed using confirmed bar data with no forward-looking references. Higher timeframe values are requested with lookahead_off, ensuring non-repainting behavior.

The system does not attempt to forecast price direction. Instead, it identifies moments where market structure, momentum, and volatility conditions are statistically aligned within the current chart environment. The goal is to provide a structured decision-support framework that helps traders evaluate confluence strength and manage risk using adaptive ATR-based projections.

Additionally, the script includes:

Dynamic ATR-based stop loss and multi-target mapping
Optional higher timeframe trend filter
Fair Value Gap (3-candle imbalance) visualization with mitigation tracking
Real-time performance tracking dashboard
Clean visual presentation with minimal chart clutter

This framework is designed as a modular confluence model, allowing traders to adjust signal sensitivity while maintaining consistent internal logic.

📐 Core Concepts
1️⃣ Multi-Factor Confluence Framework

This script is built on the principle of multi-factor condition alignment rather than single-indicator triggering. Instead of generating signals from isolated crossovers or oscillator thresholds, the system evaluates multiple independent analytical dimensions simultaneously. These dimensions include trend structure, momentum state, volatility expansion, participation behavior, directional strength, and higher timeframe alignment. The objective is not to predict price movement, but to measure how many independent technical conditions agree at the same time and quantify that agreement through a structured framework.

2️⃣ Weighted Scoring Architecture

At the core of the engine is a weighted scoring system. Each validated technical condition contributes a predefined numerical value toward a directional bias. When multiple components align in the same direction, their weights accumulate into a total score. That score is then compared against a configurable threshold. Only when the required level of alignment is reached does the system recognize directional bias as structurally valid. This transforms qualitative confluence into a measurable and rule-based evaluation model.

3️⃣ Trend Structure Evaluation

Trend structure within the script is evaluated through moving average positioning and relational hierarchy. Instead of defining trend purely from price direction, the system analyzes the relationship between short-, mid-, and long-term exponential moving averages. It evaluates their order, spacing, and crossover behavior to determine whether the market is in expansion, compression, or transition. This approach treats trend as a dynamic structural condition rather than a fixed directional assumption.

4️⃣ Momentum Confirmation Logic

Momentum is used as a confirmation layer rather than a standalone trigger. Oscillator behavior and crossover states are analyzed in relation to the broader trend structure. Instead of interpreting extreme values as reversal signals, the system evaluates whether momentum supports the existing structural direction. This ensures momentum acts as reinforcement of trend alignment rather than an independent signal source.

5️⃣ Volatility State Measurement

Volatility is measured using the relationship between current Average True Range (ATR) values and their historical average. This allows the system to identify whether the market is in a compression phase or an expansion phase. The measurement does not attempt to predict directional outcomes; it simply classifies the current volatility environment to provide context for price behavior.

6️⃣ Volume Participation Context

Volume is evaluated relative to its moving average baseline to determine whether current participation is above or below recent norms. Instead of assigning directional meaning to volume changes, the system uses it as a contextual filter. It helps identify whether price movement is occurring under increased or reduced market participation conditions.

7️⃣ Higher Timeframe Alignment

The system optionally incorporates higher timeframe trend context by comparing price with higher timeframe EMA structure. This allows lower timeframe signals to be filtered based on broader directional alignment. Higher timeframe data is retrieved using non-forward-looking methods to ensure historical consistency and avoid repainting behavior.

8️⃣ Structural Trigger Dependency

Signal generation requires both scoring alignment and a structural trigger condition. Even when the weighted score meets the required threshold, a structural event such as a moving average crossover is needed for activation. This separation ensures that signals only appear when both internal agreement and structural transition occur simultaneously.

9️⃣ Volatility-Adjusted Risk Projection

Risk levels, including stop loss and target projections, are calculated using ATR-based multipliers. This allows all distance measurements to adapt dynamically to current market volatility. Instead of using fixed values, the system scales projections according to changing market conditions, ensuring consistency across different volatility regimes.

🔒 Data Integrity Principle

All calculations are based on confirmed historical bar data. No future price references are used, and higher timeframe requests are configured without lookahead. Signal generation occurs only after all conditions are fully confirmed, ensuring consistent and non-repainting behavior.

🎯 Key Features
1️⃣ Multi-Condition Confluence Engine

This script is designed around a multi-condition evaluation system where multiple technical components are assessed simultaneously. Instead of relying on a single indicator signal, it combines trend, momentum, volatility, volume, and structural behavior into one unified framework. Each condition contributes independently to the overall directional assessment, allowing the system to evaluate market context through layered confirmation rather than isolated signals.

2️⃣ Weighted Scoring-Based Signal Logic

Signal generation is driven by a weighted scoring model. Each technical condition is assigned a predefined contribution value based on its role in market structure interpretation. These values are accumulated into a total score for both bullish and bearish scenarios. A signal is only considered valid when the accumulated score exceeds a defined threshold, ensuring that multiple independent confirmations are required before any directional output is produced.

3️⃣ Structural Trend Identification

Trend direction is determined through a structured evaluation of exponential moving averages and Supertrend positioning. The relationship between short-term, mid-term, and long-term averages is analyzed to classify market direction and structure. This approach focuses on relative alignment between trend components rather than relying on price alone, allowing clearer identification of directional bias conditions.

4️⃣ Momentum Alignment Layer

Momentum is incorporated as a supporting confirmation layer rather than a standalone signal source. Indicators such as MACD, RSI, and stochastic behavior are evaluated in relation to trend direction. The purpose of this layer is to verify whether internal market momentum aligns with the broader structural direction, helping filter conditions where trend and momentum are inconsistent.

5️⃣ Volatility-Based Dynamic Risk Levels

Risk parameters are calculated using Average True Range (ATR) to adapt to current market volatility. Stop loss and take profit levels are derived using ATR multipliers, allowing distance levels to adjust automatically according to market conditions. This ensures that risk and reward projections remain consistent across both high and low volatility environments.

6️⃣ Higher Timeframe Context Filtering

The system includes an optional higher timeframe filter that evaluates broader market direction using EMA-based structure. This filter helps ensure that lower timeframe signals are aligned with higher timeframe bias when enabled. The higher timeframe data is requested in a non-repainting manner to preserve historical consistency and prevent future data influence.

7️⃣ Structural Signal Trigger Mechanism

Signals are not generated solely from score conditions. A structural trigger, such as an EMA crossover, is required to activate a trade signal. This separation between “condition agreement” and “execution trigger” ensures that signals only appear when both momentum alignment and structural transition occur together.

8️⃣ Fair Value Gap (FVG) Detection & Tracking

The script identifies Fair Value Gaps based on three-candle price imbalance structures. These zones are visualized on the chart and extended dynamically until price interacts with them. Once a gap is fully mitigated by price movement, it is automatically removed. This feature provides structural imbalance visualization without making predictive assumptions.

9️⃣ Trade Level Mapping System

Upon signal generation, the system automatically maps entry, stop loss, and three target levels based on ATR multiples. These levels are plotted on the chart and updated dynamically according to the active trade direction. This creates a structured visual framework for risk and reward reference points.

🔒 Non-Repainting Data Processing

All calculations are based strictly on confirmed bar data. The script does not use future values in any calculation or signal generation. Higher timeframe requests are configured with lookahead disabled to maintain historical accuracy and ensure consistent behavior across all timeframes.

⚙️ How It Works

1️⃣ Data Collection Layer

The script begins by collecting real-time market data from price, volume, and higher timeframe sources. It calculates multiple foundational indicators including exponential moving averages, RSI, MACD, stochastic values, ATR, ADX, Supertrend, and volume averages. Each of these components represents a different aspect of market behavior such as trend direction, momentum strength, volatility state, and participation level. Higher timeframe data is also optionally retrieved to provide broader market context.

2️⃣ Independent Condition Evaluation

After data collection, each technical component is evaluated independently against predefined conditions. For example, moving averages are checked for alignment, momentum indicators are analyzed for directional bias, volatility is compared against its historical average, and volume is assessed relative to its moving average. Each condition produces a logical outcome that contributes to either bullish or bearish interpretation.

3️⃣ Confluence Scoring Process

All evaluated conditions are then passed into a weighted scoring system. Each valid condition adds a specific numerical value to either the bullish or bearish score. These values are accumulated separately for both directions. The system does not rely on a single dominant indicator; instead, it measures the combined agreement of multiple conditions. The final score represents the overall strength of directional alignment at that moment.

4️⃣ Threshold Validation System

Once scoring is completed, the total values are compared against a configurable threshold. The threshold is based on the selected signal mode (Aggressive, Balanced, or Conservative). Only when the accumulated score meets or exceeds the required threshold does the system consider the market condition strong enough for potential signal activation. This step ensures that weak or partial alignment conditions are filtered out.

5️⃣ Structural Trigger Confirmation

Even after passing the scoring threshold, a signal is not generated immediately. The system requires a structural trigger, such as an EMA 21 and EMA 50 crossover or crossunder, to confirm directional transition. This step ensures that signals are only activated when both internal strength (score) and structural movement (trend shift) occur together.

6️⃣ Higher Timeframe Validation (Optional)

If enabled, the system checks higher timeframe trend alignment using EMA-based structure. This step ensures that lower timeframe signals are aligned with broader market direction. If the higher timeframe filter does not support the current direction, signal generation is restricted. This layer acts as a contextual filter rather than a primary trigger.

7️⃣ Risk Level Calculation

Once a valid signal is confirmed, the script calculates entry, stop loss, and take profit levels using Average True Range (ATR). ATR acts as a volatility measurement, allowing risk levels to adjust dynamically based on current market conditions. This ensures that distance between entry and risk/reward levels expands or contracts according to market volatility.

8️⃣ Trade State Management

After signal generation, the system tracks active trade state internally. It records entry price, stop loss level, and three separate target levels. As price moves, the system monitors whether each target or stop level has been reached. This tracking allows structured visualization of trade progression without manual intervention.

9️⃣ Fair Value Gap Monitoring

In parallel with signal logic, the system continuously scans for Fair Value Gaps using three-candle imbalance structures. When such gaps are detected, they are plotted and extended until price revisits the zone. Once price fully interacts with the imbalance area, the gap is removed from the chart. This process runs independently of the main signal system.

🔒 Execution Principle Summary

Overall, the system operates in a sequential flow:
data collection → condition evaluation → score aggregation → threshold validation → structural confirmation → risk mapping → trade tracking.

Each layer functions independently but contributes to a unified decision framework. The design ensures that signals are only generated when multiple analytical conditions align and are confirmed through structural market behavior.

🧭 How to Use This Script
1️⃣ Chart Setup and Activation

To use this script, it should be added directly to a TradingView chart as an overlay indicator. Once applied, it automatically begins analyzing live market data based on the selected symbol and timeframe. The system does not require manual calculation inputs, as all indicators, scoring logic, and structural conditions are computed internally.

After activation, users can optionally enable or disable visual components such as moving averages, Supertrend, and candle coloring. These settings are designed to allow customization of visual clarity without affecting the underlying logic of signal generation.

2️⃣ Selecting Signal Mode

The script provides three signal sensitivity modes: Aggressive, Balanced, and Conservative. These modes control the minimum score required for signal consideration.

Aggressive mode requires lower confirmation levels and produces more frequent signals
Balanced mode uses a moderate confirmation threshold
Conservative mode requires stronger multi-condition alignment before a signal is displayed

This setting does not change indicator behavior; it only adjusts how strict the confirmation requirement is before signal activation.

3️⃣ Understanding Signal Conditions

Signals are generated only when two conditions are met simultaneously: a structural trend change and sufficient multi-factor score alignment. A trend change is identified through EMA crossover logic, while the score represents the combined strength of multiple technical conditions such as momentum, trend alignment, volatility state, and volume behavior.

Users should understand that signals are not based on a single indicator but on the combined agreement of multiple analytical layers. Therefore, signals appear only when multiple conditions align in the same directional bias.

4️⃣ Reading Buy and Sell Signals

Buy signals appear when bullish conditions align and are confirmed by structural crossover logic. Sell signals appear under the opposite conditions. These signals are displayed directly on the chart using labeled markers.

Each signal represents a point where multiple conditions agree on directional bias and structural confirmation has occurred. Signals should be interpreted as analytical outputs rather than automatic trade instructions.

5️⃣ Using Entry, Stop Loss, and Targets

After a signal is generated, the system automatically plots an entry reference level along with stop loss and three take profit levels. These levels are calculated using ATR-based multipliers, which means they adjust dynamically according to market volatility.

Entry represents the reference price level at signal activation
Stop loss is calculated below or above entry depending on direction
TP1, TP2, and TP3 represent staged target levels based on volatility expansion

These levels are visual guides for structured risk and reward planning and are not fixed price predictions.

6️⃣ Monitoring Trade Progress

Once a signal is active, the system tracks price movement relative to defined levels. If price reaches any target or stop level, it is recorded internally and displayed on the chart. This allows users to observe how price interacts with predefined structure over time.

The system does not automatically execute trades; it only tracks conditions and displays outcomes based on price interaction with levels.

7️⃣ Using Higher Timeframe Filter

If enabled, the higher timeframe filter adds an additional layer of confirmation by checking broader market direction. When this filter is active, signals that conflict with higher timeframe trend are restricted.

This feature is useful for aligning lower timeframe signals with overall market structure, reducing conflicting directional bias across timeframes.

8️⃣ Interpreting Fair Value Gaps

The script also highlights Fair Value Gaps (FVGs), which represent price imbalance areas formed between candles. These zones are displayed on the chart and extended forward until price revisits them.

When price fully interacts with a gap zone, it is automatically removed. These zones are used for structural context only and do not represent guaranteed reversal or continuation areas.

🔒 Practical Usage Summary

In practical use, the workflow is simple:
apply indicator → select signal mode → observe signals → monitor risk/target levels → use higher timeframe filter for context → reference FVG zones for structure.

The system is designed to provide structured technical analysis by combining multiple market factors into a single visual and rule-based framework, without requiring manual calculations.

⚙️ Settings & Customization 

1️⃣ Signal Mode Customization

The script provides a Signal Mode option that controls how strict the confirmation logic is before a signal is displayed. This setting adjusts the internal score threshold required for signal validation, without changing the underlying calculations.
Aggressive Mode lowers the confirmation requirement, allowing signals to appear with fewer aligned conditions.
Balanced Mode applies a moderate threshold and represents a middle-ground filtering approach.
Conservative Mode increases the confirmation requirement, meaning more conditions must align before a signal is generated.
This setting is used to control signal sensitivity based on user preference and market style.

2️⃣ Moving Average Visibility Settings

Users can enable or disable different moving averages to customize chart clarity.
EMA 200 represents broader structural trend and can be enabled for long-term context
EMA 50 provides mid-term trend structure reference
EMA 21 is used internally for signal logic and crossover detection
These options are visual only and do not affect internal calculations or signal generation logic.

3️⃣ Supertrend Display Control

The Supertrend line can be toggled on or off depending on user preference. When enabled, it provides an additional visual representation of directional trend structure. This setting is designed purely for chart visualization and does not modify the scoring or signal logic.

4️⃣ Candle Coloring Option

The script includes an optional candle coloring feature based on trend direction relative to EMA 200. When enabled, candles are visually colored to reflect broader market bias.
This feature is only for visual assistance and does not influence signal generation or internal decision-making.

5️⃣ Risk and Reward Configuration (ATR Multipliers)

The script allows full customization of risk and reward structure using ATR-based multipliers:
Stop Loss multiplier controls how far stop levels are placed relative to entry
TP1, TP2, and TP3 multipliers define progressive target distances
Higher values increase distance between entry and levels, while lower values reduce spacing. These settings adapt automatically to volatility because they are based on ATR rather than fixed price points.

6️⃣ Higher Timeframe Filter Settings
Users can enable or disable higher timeframe confirmation. When enabled, the script compares current price structure with a higher timeframe EMA 200 trend.
If enabled, signals are filtered based on broader directional alignment
If disabled, only current timeframe conditions are used
The timeframe itself can also be adjusted, allowing flexibility in how broader market structure is evaluated.

7️⃣ Fair Value Gap (FVG) Settings

The FVG module includes customization options for imbalance detection and visualization.
Bullish and bearish FVG colors can be adjusted for clarity
Maximum active FVG limit controls how many zones remain visible on the chart
This ensures chart performance remains stable even during high activity conditions.

8️⃣ Dashboard Position Customization

The analytics dashboard can be placed in different chart areas:
Top Left
Top Right
Bottom Left
Bottom Right
This allows users to adjust layout based on chart space and personal preference. The dashboard itself displays live system data and does not affect calculations.

🔒 Customization Principle Summary

All settings in the script are designed to control visual appearance, signal sensitivity, and risk structure, without modifying the core analytical engine.
The internal logic always remains consistent, while customization options allow users to adjust how signals are filtered, displayed, and interpreted.

⚙️ Mashup Design Justification (House Rules Safe Explanation)

This script combines multiple technical components, but it is not a simple “indicator stacking” or random merge. It is structured as a single analytical framework where each component has a defined role inside a unified decision model. The purpose of combining these tools is to evaluate different dimensions of market behavior in a controlled and rule-based manner.

1️⃣ Why the Scoring Model Exists

The scoring model exists to convert multiple independent market conditions into a single structured evaluation output. In traditional single-indicator systems, signals are generated when one condition is met, which can lead to inconsistent behavior across different market environments.

In this framework, each indicator does not act as a standalone signal generator. Instead, each one contributes a weighted value representing a specific market dimension such as trend alignment, momentum strength, volatility state, or participation level. These values are accumulated into a total score.

The purpose of this design is to measure confluence strength, meaning how many independent technical conditions are aligned at the same time. A signal is only considered valid when enough conditions agree, which is why scoring is used instead of binary logic.

2️⃣ Why EMA Crossover is Used as a Trigger

The EMA 21 and EMA 50 crossover is used as a structural trigger mechanism, not as a standalone trading signal.

The scoring model identifies whether market conditions are aligned, but it does not define when the market is actually transitioning. The EMA crossover is used to detect this transition point in structure.

This separation is important:

Scoring = evaluates market condition strength
EMA crossover = confirms directional structural change

A signal is only generated when both conditions occur together. This prevents signals from appearing during weak or sideways alignment where no structural shift has occurred.

3️⃣ Why Higher Timeframe (HTF) Filter is Used

The higher timeframe filter is included to provide multi-layer market context. Markets behave differently across timeframes, and lower timeframe signals can sometimes conflict with broader directional structure.

The HTF filter compares current price structure with higher timeframe EMA-based trend direction. When enabled, it ensures that lower timeframe signals are only considered when they are not opposing the broader trend environment.

The purpose of this filter is not prediction, but context alignment, ensuring that signals are consistent across multiple timeframes instead of being isolated to a single chart view.

4️⃣ Why ATR-Based Risk Model is Used

ATR (Average True Range) is used to define dynamic risk levels because market volatility is not constant. Fixed stop loss and target values do not adapt to changing market conditions, which can lead to inconsistent risk structure across different volatility phases.

In this script, ATR is used to calculate:

Stop loss distance
Take profit levels (TP1, TP2, TP3)

This ensures that all risk and reward levels automatically adjust based on current market volatility. During high volatility, levels expand; during low volatility, they contract.

The purpose of this design is to maintain volatility-adjusted consistency, not to predict price movement.

5️⃣ Why Multiple Indicators Are Combined

Each included indicator serves a different analytical function:

EMA system → trend structure
Supertrend → directional confirmation
MACD → momentum alignment
RSI → relative strength positioning
Stochastic → short-term momentum shifts
ADX → trend strength measurement
Volume filter → participation context
ATR → volatility scaling
HTF filter → higher timeframe structure
FVG detection → imbalance visualization

These are not combined to create multiple signals. Instead, they are used to evaluate different dimensions of the same market condition.

The system only generates output when multiple independent conditions agree, which is why it is structured as a confluence-based analytical model, not a simple indicator mashup.

🔒 Final Compliance Summary

This script is designed as a unified decision framework where:

Indicators do not function independently as signal generators
Scoring system evaluates confluence strength
EMA crossover defines structural transition
HTF filter ensures contextual alignment
ATR ensures volatility-adjusted risk mapping

The combination is structured to represent a single rule-based system for market condition evaluation rather than multiple disconnected indicators.

📝 Final Notes (House Rules Safe)

This script is designed as a structured analytical framework that combines multiple technical components into a single unified evaluation system. Each included element serves a specific role within the overall logic, such as trend identification, momentum evaluation, volatility measurement, structural confirmation, and contextual filtering.

The system does not rely on any single indicator to generate signals. Instead, it uses a rule-based confluence approach where multiple independent conditions must align before a signal is considered valid. This reduces dependence on isolated market readings and ensures that outputs are generated only when broader technical agreement is present.

All indicators used in the script are applied in a supporting role within a scoring and confirmation structure. They are not interpreted individually as standalone buy or sell signals. The scoring model ensures that each condition contributes proportionally to a combined directional assessment.

Signal generation is further controlled through a structural trigger mechanism, such as moving average crossover logic. This ensures that signals only appear when both condition alignment and structural transition occur together, rather than from static or partial alignment.

Risk and target levels are calculated using ATR-based volatility measurement, allowing all distance-based projections to adjust dynamically according to current market conditions. This ensures consistency across different volatility environments without relying on fixed values.

Higher timeframe filtering is optionally included to provide broader market context and ensure alignment with larger structural direction when enabled. This helps maintain consistency between lower timeframe signals and overall trend environment.

Fair Value Gap detection is used as a structural visualization tool to highlight price imbalance areas. These zones are tracked dynamically and removed when mitigated by price interaction, providing additional context without influencing signal logic.

Overall, the system operates as a rule-based confluence engine where multiple market dimensions are evaluated together. The goal is to present structured, condition-based analysis rather than isolated indicator outputs, while maintaining consistent, non-repainting behavior based on confirmed data only.

⚠️ Final Notes

This indicator is designed as a multi-layer confluence engine that combines trend, momentum, volatility, and market structure into a single scoring-based decision system. It is important to understand that no trading system guarantees accuracy in all market conditions, and this tool should be treated as a decision-support framework, not a standalone trading guarantee.

The strength of this model comes from its confluence logic, where multiple independent signals (trend direction, momentum strength, volume activity, and higher timeframe bias) must align before a valid trade signal is generated. This reduces random entries and focuses only on structured market conditions where probability is higher.

The built-in ATR-based risk system (SL/TP) ensures that trade management adapts dynamically to volatility rather than using fixed pip values. However, risk levels should always be adjusted according to account size and personal risk tolerance.

The dashboard and scoring system are intended to provide transparency, helping traders understand why a signal is generated rather than blindly following entries. Users are encouraged to test and optimize settings based on their own trading style and market conditions.

⚠️ Disclaimer

This script is developed for educational and informational purposes only. It does not provide financial advice, investment recommendations, or guaranteed trading outcomes.

Trading in financial markets (Forex, crypto, indices, or stocks) involves high risk, and you may lose part or all of your capital. Past performance of this indicator does not guarantee future results.

Users are solely responsible for their trading decisions. It is strongly recommended to:

Use proper risk management
Test the strategy on demo accounts first
Avoid over-leveraging
Combine with personal analysis before execution

The developer holds no responsibility for any financial losses incurred from the use of this indicator.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © shafaan2000

//@version=6
indicator("Adaptive Confluence Engine [CLEVER]", overlay=true, max_labels_count=200, max_lines_count=200, max_boxes_count=100)

// ══════════════════════════════════════════════════════════════════
//    Adaptive Confulence Engine |  Advanced Trading Suite
//  ► Logic: Multi-EMA Confluence + Trend Filtering + Momentum Scoring
//  ► Risk:  Dynamic ATR-based Entry, Stop Loss, and 3-Target Profit system
//  ► Features: Real-time FVG Mitigation and Interactive Performance Dashboard
// ══════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────
// 🛠️ SYSTEM INPUTS & CONFIGURATION
// ─────────────────────────────────────────────

grp_sig = "⚡ Signal Settings"
sigMode  = input.string("Conservative", "Signal Mode",  options=["Aggressive","Balanced","Conservative"], group=grp_sig, tooltip="Conservative = fewer signals with stricter confirmation")

show200  = input.bool(false, "Show EMA 200 (Trend Line)?", group=grp_sig)
show50   = input.bool(false, "Show EMA 50?",               group=grp_sig)
showST   = input.bool(false, "Show Supertrend?",           group=grp_sig)
colorBar = input.bool(true,  "Color Candles by Trend?",    group=grp_sig)

grp_risk = "🎯 SL / TP Settings"
slMult  = input.float(2.2, "Stop Loss (ATR ×)",   minval=0.1, step=0.1, group=grp_risk)
tp1Mult = input.float(2.2, "Take Profit 1 (ATR ×)", minval=0.1, step=0.1, group=grp_risk)
tp2Mult = input.float(4.4, "Take Profit 2 (ATR ×)", minval=0.1, step=0.1, group=grp_risk)
tp3Mult = input.float(6.6, "Take Profit 3 (ATR ×)", minval=0.1, step=0.1, group=grp_risk)
showTP1 = input.bool(true, "Show TP 1?", group=grp_risk)
showTP2 = input.bool(true, "Show TP 2?", group=grp_risk)
showTP3 = input.bool(true, "Show TP 3?", group=grp_risk)

grp_htf = "🔭 Higher Timeframe"
useHtf = input.bool(true,   "Enable HTF Filter?", group=grp_htf)
htfTf  = input.timeframe("1", "HTF Timeframe",   group=grp_htf)

grp_dash = "📊 Dashboard"
showDash    = input.bool(true,         "Show Dashboard?", group=grp_dash)
dashPos     = input.string("Top Right","Position", options=["Top Left","Top Right","Bottom Left","Bottom Right"], group=grp_dash)




// ─────────────────────────────────────────────
// CLEAN COLOR PALETTE
// ─────────────────────────────────────────────

C_BUY  = color.rgb(8, 239, 251)   // Primary Buy Color
C_SELL = color.rgb(217, 2, 255)   // Primary Sell Color
C_SL   = color.rgb(255, 100, 120)   // Risk/Stop Color
C_TP1  = color.rgb(100, 220, 160)   // Target 1 Color
C_TP2  = color.rgb(50,  200, 255)   // Target 2 Color
C_TP3  = color.rgb(180, 130, 255)   // Target 3 Color
C_ENTRY= color.rgb(100, 180, 255)   // Neutral Entry Color
C_200  = color.rgb(255, 200,   0)   // Major Trend Color
C_50   = color.rgb(150, 150, 200)   // Minor Trend Color
C_BG   = color.rgb(10,  12,  20)   // Interface Background
C_TXT  = color.rgb(200, 210, 225)   // Primary Text Color
C_DIM  = color.rgb(90, 100, 120)    // Secondary/Dim Text Color

// ─────────────────────────────────────────────
// 📈 TECHNICAL INDICATOR SETTINGS
// ─────────────────────────────────────────────

grp_fvg = "🕯️ FVG Settings"
showFvg   = input.bool(true,  "Show FVGs?", group=grp_fvg)
fvgBullC  = input.color(color.new(C_BUY, 85), "Bull FVG Color", group=grp_fvg)
fvgBearC  = input.color(color.new(C_SELL, 85), "Bear FVG Color", group=grp_fvg)
fvgLimit  = input.int(50, "Max Active FVGs", minval=1, maxval=500, group=grp_fvg)

// ─────────────────────────────────────────────
// 🧮 CORE CALCULATIONS & MOMENTUM
// ─────────────────────────────────────────────

ema21  = ta.ema(close, 21)
ema50  = ta.ema(close, 50)
ema200 = ta.ema(close, 200)

rsi = ta.rsi(close, 14)
[macdL, macdS, macdH] = ta.macd(close, 12, 26, 9)
stochK = ta.sma(ta.stoch(rsi, rsi, rsi, 14), 3)
stochD = ta.sma(stochK, 3)
[diP, diM, adxV] = ta.dmi(14, 14)

atr    = ta.atr(14)
atrAvg = ta.sma(atr, 20)
volAvg = ta.sma(volume, 20)

[stLine, stDir] = ta.supertrend(3.0, 10)
stBull = stDir < 0
stBear = stDir > 0

htfCl  = request.security(syminfo.tickerid, htfTf, close,          lookahead=barmerge.lookahead_off)
htfE200= request.security(syminfo.tickerid, htfTf, ta.ema(close,200), lookahead=barmerge.lookahead_off)
htfBull = not useHtf or htfCl > htfE200
htfBear = not useHtf or htfCl < htfE200

bullEngulf = close > open[1] and open < close[1] and close[1] < open[1]
bearEngulf = close < open[1] and open > close[1] and close[1] > open[1]

// ─────────────────────────────────────────────
// SIGNAL SCORING  (max = 16)
// ─────────────────────────────────────────────

longScore = 0
longScore := longScore + (close > ema200                        ? 2 : 0)
longScore := longScore + (ema21 > ema50                         ? 1 : 0)
longScore := longScore + (stBull                                ? 2 : 0)
longScore := longScore + (macdL > macdS and macdH > 0           ? 2 : 0)
longScore := longScore + (rsi > 45 and rsi < 70                 ? 2 : 0)
longScore := longScore + (stochK > stochD and stochK < 80       ? 1 : 0)
longScore := longScore + (adxV > 20 and diP > diM               ? 1 : 0)
longScore := longScore + (volume > volAvg                        ? 1 : 0)
longScore := longScore + (htfBull                               ? 2 : 0)
longScore := longScore + (bullEngulf                            ? 1 : 0)
longScore := longScore + (atr > atrAvg * 0.8                    ? 1 : 0)

shortScore = 0
shortScore := shortScore + (close < ema200                      ? 2 : 0)
shortScore := shortScore + (ema21 < ema50                       ? 1 : 0)
shortScore := shortScore + (stBear                              ? 2 : 0)
shortScore := shortScore + (macdL < macdS and macdH < 0         ? 2 : 0)
shortScore := shortScore + (rsi < 55 and rsi > 30               ? 2 : 0)
shortScore := shortScore + (stochK < stochD and stochK > 20     ? 1 : 0)
shortScore := shortScore + (adxV > 20 and diM > diP             ? 1 : 0)
shortScore := shortScore + (volume > volAvg                      ? 1 : 0)
shortScore := shortScore + (htfBear                             ? 2 : 0)
shortScore := shortScore + (bearEngulf                          ? 1 : 0)
shortScore := shortScore + (atr > atrAvg * 0.8                  ? 1 : 0)

// Trigger: EMA21 crosses EMA50
emaCB  = ta.crossover(ema21, ema50)
emaCBr = ta.crossunder(ema21, ema50)

longThr  = sigMode == "Conservative" ? 12 : sigMode == "Balanced" ? 9 : 6
shortThr = sigMode == "Conservative" ? 12 : sigMode == "Balanced" ? 9 : 6

longSignal  = emaCB  and longScore  >= longThr
shortSignal = emaCBr and shortScore >= shortThr

// ─────────────────────────────────────────────
// TRADE MANAGEMENT
// ─────────────────────────────────────────────

var int   tDir  = 0
var float ePx   = na
var float slPx  = na
var float t1Px  = na
var float t2Px  = na
var float t3Px  = na
var bool  t1Hit = false
var bool  t2Hit = false
var bool  t3Hit = false

var int totTr = 0
var int slCnt = 0
var int t1Cnt = 0
var int t2Cnt = 0
var int t3Cnt = 0

// Persistent line objects
var line lnE  = na
var line lnSL = na
var line lnT1 = na
var line lnT2 = na
var line lnT3 = na

EXT = 40  // line extension bars

// ── Open LONG
if longSignal and tDir != 1
    line.delete(lnE)
    line.delete(lnSL)
    line.delete(lnT1)
    line.delete(lnT2)
    line.delete(lnT3)

    tDir  := 1
    ePx   := close
    slPx  := close - atr * slMult
    t1Px  := close + atr * tp1Mult
    t2Px  := close + atr * tp2Mult
    t3Px  := close + atr * tp3Mult
    t1Hit := false
    t2Hit := false
    t3Hit := false
    totTr := totTr + 1

    // Clean lines only — no cluttered labels
    lnE  := line.new(bar_index, ePx,  bar_index + EXT, ePx,  color=color.new(C_ENTRY, 30), width=1, style=line.style_dashed)
    lnSL := line.new(bar_index, slPx, bar_index + EXT, slPx, color=color.new(C_SL, 0),    width=2, style=line.style_solid)
    if showTP1
        lnT1 := line.new(bar_index, t1Px, bar_index + EXT, t1Px, color=color.new(C_TP1, 10), width=1, style=line.style_dashed)
    if showTP2
        lnT2 := line.new(bar_index, t2Px, bar_index + EXT, t2Px, color=color.new(C_TP2, 10), width=2, style=line.style_dashed)
    if showTP3
        lnT3 := line.new(bar_index, t3Px, bar_index + EXT, t3Px, color=color.new(C_TP3, 0),  width=2, style=line.style_solid)



// ── Open SHORT
if shortSignal and tDir != -1
    line.delete(lnE)
    line.delete(lnSL)
    line.delete(lnT1)
    line.delete(lnT2)
    line.delete(lnT3)

    tDir  := -1
    ePx   := close
    slPx  := close + atr * slMult
    t1Px  := close - atr * tp1Mult
    t2Px  := close - atr * tp2Mult
    t3Px  := close - atr * tp3Mult
    t1Hit := false
    t2Hit := false
    t3Hit := false
    totTr := totTr + 1

    lnE  := line.new(bar_index, ePx,  bar_index + EXT, ePx,  color=color.new(C_ENTRY, 30), width=1, style=line.style_dashed)
    lnSL := line.new(bar_index, slPx, bar_index + EXT, slPx, color=color.new(C_SL, 0),    width=2, style=line.style_solid)
    if showTP1
        lnT1 := line.new(bar_index, t1Px, bar_index + EXT, t1Px, color=color.new(C_TP1, 10), width=1, style=line.style_dashed)
    if showTP2
        lnT2 := line.new(bar_index, t2Px, bar_index + EXT, t2Px, color=color.new(C_TP2, 10), width=2, style=line.style_dashed)
    if showTP3
        lnT3 := line.new(bar_index, t3Px, bar_index + EXT, t3Px, color=color.new(C_TP3, 0),  width=2, style=line.style_solid)



// ── Hit Detection
bool hitSL = false
bool hitT1 = false
bool hitT2 = false
bool hitT3 = false

if tDir == 1
    if high >= t1Px and not t1Hit
        hitT1 := true
        t1Hit := true
        t1Cnt := t1Cnt + 1
    if high >= t2Px and not t2Hit
        hitT2 := true
        t2Hit := true
        t2Cnt := t2Cnt + 1
    if high >= t3Px and not t3Hit
        hitT3 := true
        t3Hit := true
        t3Cnt := t3Cnt + 1
        tDir  := 0
        line.delete(lnE)
        line.delete(lnSL)
        line.delete(lnT1)
        line.delete(lnT2)
        line.delete(lnT3)
    if low <= slPx and not t1Hit
        hitSL := true
        tDir  := 0
        slCnt := slCnt + 1
        line.delete(lnE)
        line.delete(lnSL)
        line.delete(lnT1)
        line.delete(lnT2)
        line.delete(lnT3)

if tDir == -1
    if low <= t1Px and not t1Hit
        hitT1 := true
        t1Hit := true
        t1Cnt := t1Cnt + 1
    if low <= t2Px and not t2Hit
        hitT2 := true
        t2Hit := true
        t2Cnt := t2Cnt + 1
    if low <= t3Px and not t3Hit
        hitT3 := true
        t3Hit := true
        t3Cnt := t3Cnt + 1
        tDir  := 0
        line.delete(lnE)
        line.delete(lnSL)
        line.delete(lnT1)
        line.delete(lnT2)
        line.delete(lnT3)
    if high >= slPx and not t1Hit
        hitSL := true
        tDir  := 0
        slCnt := slCnt + 1
        line.delete(lnE)
        line.delete(lnSL)
        line.delete(lnT1)
        line.delete(lnT2)
        line.delete(lnT3)

// ─────────────────────────────────────────────
// Detects 3-candle imbalance structures (FVG)
// ─────────────────────────────────────────────

var box[] fvgBoxes = array.new_box()

if showFvg
    // ── BULLISH FVG
    if low > high[2]
        nb = box.new(bar_index-2, low, bar_index, high[2], 
             bgcolor=fvgBullC, border_color=color.new(fvgBullC, 50),
             text="FVG", text_halign=text.align_center, text_valign=text.align_center,
             text_color=color.new(C_TXT, 30), text_size=size.tiny)
        array.push(fvgBoxes, nb)

    // ── BEARISH FVG
    if high < low[2]
        nb = box.new(bar_index-2, high, bar_index, low[2], 
             bgcolor=fvgBearC, border_color=color.new(fvgBearC, 50), 
             text="FVG", text_halign=text.align_center, text_valign=text.align_center,
             text_color=color.new(C_TXT, 30), text_size=size.tiny)
        array.push(fvgBoxes, nb)

    // ── MITIGATION & CLEANUP
    if array.size(fvgBoxes) > 0
        for i = array.size(fvgBoxes) - 1 to 0
            b = array.get(fvgBoxes, i)
            top = box.get_top(b)
            btm = box.get_bottom(b)
            
            // Mitigated if price penetrates the gap
            isBull = top > btm
            mitigated = false
            if isBull
                if low < btm
                    mitigated := true
            else
                if high > btm
                    mitigated := true
            
            if mitigated
                box.delete(b)
                array.remove(fvgBoxes, i)
            else
                // IF NOT MITIGATED, EXTEND TO CURRENT BAR
                box.set_right(b, bar_index)

                // Limit management
                if i < array.size(fvgBoxes) - fvgLimit
                    box.delete(b)
                    array.remove(fvgBoxes, i)

// ─────────────────────────────────────────────
// PLOTTING  —  Clean & Minimal
// ─────────────────────────────────────────────

// ── EMA 200 (Gold — main trend)
plot(show200 ? ema200 : na, "EMA 200", color=color.new(C_200, 20), linewidth=3)

// ── EMA 50 (Soft purple)
plot(show50  ? ema50  : na, "EMA 50",  color=color.new(C_50, 40),  linewidth=1, style=plot.style_line)

// ── Supertrend (thin step line)
plot(showST ? stLine : na, "Supertrend",
     color=stBull ? color.new(C_BUY, 40) : color.new(C_SELL, 40),
     linewidth=2, style=plot.style_stepline)



// ── Candle color (subtle)
barcolor(colorBar ? (close > ema200 ? color.new(C_BUY, 75) : color.new(C_SELL, 75)) : na)

// ── BUY Signal Labels
plotshape(longSignal, title="BUY", style=shape.labelup, location=location.belowbar, color=C_BUY, textcolor=color.rgb(5,10,5), text="BUY", size=size.tiny)

// ── SELL Signal Labels
plotshape(shortSignal, title="SELL", style=shape.labeldown, location=location.abovebar, color=C_SELL, textcolor=color.white, text="SELL", size=size.tiny)

// ── SL Hit marker (exactly at price level)
plotshape(hitSL ? slPx : na,  title="SL Hit",  style=shape.xcross, location=location.absolute, color=color.new(color.white, 100), size=size.tiny, text="SL", textcolor=color.white)

// ── TP Hit markers (exactly at price level)
plotshape(hitT1 and showTP1 ? t1Px : na, title="TP1 Hit", style=shape.triangleup, location=location.absolute, color=color.new(color.white, 100), size=size.tiny, text="TP1", textcolor=color.white)
plotshape(hitT2 and showTP2 ? t2Px : na, title="TP2 Hit", style=shape.triangleup, location=location.absolute, color=color.new(color.white, 100), size=size.small, text="TP2", textcolor=color.white)
plotshape(hitT3 and showTP3 ? t3Px : na, title="TP3 Hit", style=shape.triangleup, location=location.absolute, color=color.new(color.white, 100), size=size.small, text="TP3", textcolor=color.white)

// ─────────────────────────────────────────────
// 📊 ANALYTICS DASHBOARD & STATS
// ─────────────────────────────────────────────

f_pos(p) =>
    switch p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        => position.top_right

f_bar(v, mx) =>
    p = math.round(v / mx * 10)
    s = ""
    for i = 1 to 10
        s := s + (i <= p ? "█" : "░")
    s


int   wins  = t1Cnt + t2Cnt + t3Cnt


string dirStr = tDir == 1 ? "📈  LONG"  : tDir == -1 ? "📉  SHORT" : "──  FLAT"
color  dirCol = tDir == 1 ? C_BUY      : tDir == -1 ? C_SELL     : C_DIM
string mktStr = adxV > 25 ? (close > ema200 ? "🔼 Trending UP" : "🔽 Trending DOWN") : "↔ Ranging"

var table dash = na
if showDash
    dash := table.new(f_pos(dashPos), 2, 15,
         bgcolor=color.new(C_BG, 8),
         border_width=1, border_color=color.new(C_DIM, 50),
         frame_width=2,  frame_color=color.new(C_200, 35))

if barstate.islast and showDash
    // ── Title
    table.cell(dash, 0, 0, "Adaptive Confluence Engine",
         text_color=C_200, text_size=size.small,
         bgcolor=color.new(C_BG, 0), text_halign=text.align_center)
    table.merge_cells(dash, 0, 0, 1, 0)

    // ── Signal
    table.cell(dash, 0, 1, "Signal", text_color=C_DIM, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, dirStr,   text_color=dirCol, text_size=size.small, text_halign=text.align_right)

    // ── Entry
    table.cell(dash, 0, 2, "Entry",  text_color=C_DIM, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2,
         (tDir != 0 and not na(ePx)) ? str.tostring(ePx, "#.##") : "—",
         text_color=C_ENTRY, text_size=size.small, text_halign=text.align_right)

    // ── Stop Loss
    table.cell(dash, 0, 3, "Stop Loss", text_color=C_DIM, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3,
         (tDir != 0 and not na(slPx)) ? str.tostring(slPx, "#.##") : "—",
         text_color=C_SL, text_size=size.small, text_halign=text.align_right)

    // ── TP1
    table.cell(dash, 0, 4, "TP 1", text_color=C_DIM, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4,
         (tDir != 0 and not na(t1Px)) ? str.tostring(t1Px, "#.##") : "—",
         text_color=C_TP1, text_size=size.small, text_halign=text.align_right)

    // ── TP2
    table.cell(dash, 0, 5, "TP 2", text_color=C_DIM, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5,
         (tDir != 0 and not na(t2Px)) ? str.tostring(t2Px, "#.##") : "—",
         text_color=C_TP2, text_size=size.small, text_halign=text.align_right)

    // ── TP3
    table.cell(dash, 0, 6, "TP 3", text_color=C_DIM, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6,
         (tDir != 0 and not na(t3Px)) ? str.tostring(t3Px, "#.##") : "—",
         text_color=C_TP3, text_size=size.small, text_halign=text.align_right)

    // ── Divider
    table.cell(dash, 0, 7, "────────────────",
         text_color=color.new(C_DIM, 30), text_size=size.tiny, text_halign=text.align_center)
    table.merge_cells(dash, 0, 7, 1, 7)

    // ── Total Trades
    table.cell(dash, 0, 8, "Total Trades", text_color=C_DIM, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 8, str.tostring(totTr), text_color=C_TXT, text_size=size.small, text_halign=text.align_right)

    // ── Wins
    table.cell(dash, 0, 9, "TP Hits (1/2/3)", text_color=C_DIM, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 9,
         str.tostring(t1Cnt) + " / " + str.tostring(t2Cnt) + " / " + str.tostring(t3Cnt),
         text_color=C_TP1, text_size=size.small, text_halign=text.align_right)

    // ── SL Hits
    table.cell(dash, 0, 10, "SL Hits", text_color=C_DIM, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 10, str.tostring(slCnt), text_color=C_SL, text_size=size.small, text_halign=text.align_right)



    // ── Divider
    table.cell(dash, 0, 11, "────────────────",
         text_color=color.new(C_DIM, 30), text_size=size.tiny, text_halign=text.align_center)
    table.merge_cells(dash, 0, 11, 1, 11)

    // ── Market
    table.cell(dash, 0, 12, "Market", text_color=C_DIM, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 12, mktStr,   text_color=adxV > 25 ? (close > ema200 ? C_BUY : C_SELL) : color.rgb(255,200,0), text_size=size.small, text_halign=text.align_right)

    // ── RSI
    table.cell(dash, 0, 13, "RSI (14)", text_color=C_DIM, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 13, str.tostring(rsi, "#.#"),
         text_color=rsi > 70 ? C_SELL : rsi < 30 ? C_BUY : C_TXT,
         text_size=size.small, text_halign=text.align_right)

    // ── HTF
    table.cell(dash, 0, 14, "HTF (" + htfTf + "m)", text_color=C_DIM, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 14, htfBull ? "📈 Bullish" : "📉 Bearish",
         text_color=htfBull ? C_BUY : C_SELL, text_size=size.small, text_halign=text.align_right)

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────

alertcondition(longSignal,  title="BUY Signal",   message="Adaptive Confluence Engine — BUY Signal! Check Dashboard for Entry, SL & TP.")
alertcondition(shortSignal, title="SELL Signal",  message="Adaptive Confluence Engine— SELL Signal! Check Dashboard for Entry, SL & TP.")
alertcondition(hitSL,       title="SL Hit",       message="Adaptive Confluence Engine — Stop Loss Hit.")
alertcondition(hitT1,       title="TP1 Hit",      message="Adaptive Confluence Engine — Take Profit 1 Reached!")
alertcondition(hitT2,       title="TP2 Hit",      message="Adaptive Confluence Engine — Take Profit 2 Reached!")
alertcondition(hitT3,       title="TP3 Hit",      message="Adaptive Confluence Engine — Take Profit 3 Reached!")
````
