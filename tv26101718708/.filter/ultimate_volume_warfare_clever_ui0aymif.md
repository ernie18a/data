# Ultimate Volume Warfare [CLEVER]

- url: https://www.tradingview.com/script/uI0AyMIF-Ultimate-Volume-Warfare-CLEVER/
- type: indicator
- pine_id: PUB;dd00cbe9e8f949149072c3da3ffb2ebf
- version: 1.0

## Description

Overview
Ultimate Volume Warfare [CLEVER] is a comprehensive volume-analysis system built to study how market participation interacts with price structure, volatility, and momentum conditions across different trading environments. The indicator combines multiple layers of volume behavior into a unified analytical framework designed to help traders observe shifts in market activity with greater clarity and structure.
At its foundation, the script focuses on the relationship between price movement and trading participation rather than treating raw volume as an isolated metric. By combining pivot-based divergence analysis, adaptive volume calculations, relative volume behavior, and contextual filtering systems, the indicator attempts to highlight moments where participation characteristics begin changing beneath price action.
The system includes an advanced volume classification model inspired by participation-based market behavior. Different conditions such as climax activity, exhaustion phases, accumulation behavior, distribution pressure, absorption zones, and abnormal spike events are visually separated using dedicated color logic. This structure is designed to make changes in participation strength easier to identify during trending, ranging, and volatile market conditions.
A major component of the framework is its divergence engine, which compares confirmed swing structures in price against confirmed swing structures in volume. The script supports both regular and hidden divergence detection using pivot-based confirmation logic. Because the system relies on completed pivot structures, signals naturally appear after confirmation instead of attempting to predict unfinished market swings in real time. This confirmation-based approach is intended to reduce unstable signal behavior while preserving structural consistency.
To improve adaptability across different market conditions, the indicator uses volatility-sensitive calculations that dynamically adjust internal thresholds according to changing ATR behavior. This allows the script to react differently during low-volatility consolidation phases versus high-volatility expansion phases, helping the analytical logic remain more responsive across multiple instruments and timeframes.
The indicator also integrates relative volume analysis and spike-detection systems to identify periods where market participation exceeds normal historical behavior. Heatmap zones, spike markers, and confluence conditions are used to visually emphasize moments of unusually strong activity that may represent heightened institutional participation, aggressive momentum expansion, or temporary liquidity imbalance.
In addition to standalone volume analysis, the script supports optional confirmation filters including EMA trend alignment, ATR expansion conditions, higher timeframe participation analysis, and relative volume filtering. These layers are designed to provide broader contextual alignment before signals become visible, helping reduce weaker market conditions where participation structure may lack consistency.
The higher timeframe module introduces an additional contextual layer by comparing current higher timeframe participation against its own historical average behavior. This helps users observe whether broader participation conditions are expanding or contracting while operating on lower execution timeframes. The script uses non-lookahead calculations to reduce misleading historical behavior as much as possible within Pine Script limitations.
The interface is designed as a full analytical environment rather than a minimal signal generator. Divergence structures, classification coloring, spike visualization, confirmation ribbons, confluence markers, RVOL heatmaps, and statistical dashboards all work together to provide layered insight into changing participation behavior across the chart.
Ultimate Volume Warfare [CLEVER] is intended for educational and analytical chart-study purposes only. The script does not predict future market direction or guarantee trading performance. All signals and classifications should be interpreted within broader market context, liquidity conditions, volatility structure, and individual risk management practices.

Core Concept

The core concept behind Ultimate Volume Warfare [CLEVER] is the idea that market participation often provides additional context beyond price movement alone. Instead of treating volume as a simple confirmation tool, the script approaches volume as a dynamic behavioral component that can be analyzed alongside volatility, structure, momentum, and multi-timeframe conditions to study how market activity evolves during different phases of price action.

The framework is built around the relationship between price swings and participation strength. The script continuously evaluates whether volume behavior is supporting, weakening, accelerating, or diverging from underlying price movement. By comparing confirmed pivot structures in both price and volume, the system attempts to identify areas where participation characteristics begin changing relative to market structure. This divergence-based methodology is designed to study the interaction between directional movement and participation intensity rather than attempting to forecast exact future outcomes.

A major part of the system focuses on contextual volume interpretation. Instead of using a single static threshold, the indicator separates participation into multiple behavioral categories such as climax activity, exhaustion behavior, absorption conditions, accumulation pressure, distribution pressure, and abnormal spike events. Each classification attempts to represent a different form of participation environment occurring inside the market. The objective is not to label market direction with certainty, but to help visualize how trading activity changes during expansion, compression, continuation, or reaction phases.

The script also emphasizes adaptive behavior rather than rigid calculations. Market volatility changes constantly across assets and timeframes, so the indicator uses ATR-sensitive normalization logic to dynamically adjust several internal thresholds. This allows participation conditions to scale differently during high-volatility expansion phases compared to quieter consolidation environments. By adapting to changing volatility structures, the system attempts to maintain analytical consistency across multiple market conditions.

Another foundational concept within the framework is confluence analysis. Instead of relying on a single event to generate chart signals, the indicator can combine multiple contextual layers such as divergence confirmation, relative volume expansion, higher timeframe participation state, volatility filters, EMA alignment, and spike activity. The goal of this layered structure is to provide broader analytical context around participation behavior rather than reducing market analysis to isolated signals.

The indicator also incorporates relative volume analysis to compare current activity against historical participation averages. This helps highlight areas where current market engagement exceeds normal conditions, which may indicate periods of stronger liquidity, increased attention, or temporary participation imbalance. Heatmap zones, spike markers, and confluence visuals are designed to make these changes easier to identify visually during active market conditions.

Higher timeframe participation analysis adds another contextual dimension to the system. By comparing higher timeframe volume against its own average conditions, the framework attempts to provide additional insight into whether broader market participation is expanding or declining while traders operate on lower execution timeframes. This multi-timeframe structure is intended to improve contextual awareness without relying solely on local chart activity.

The overall design philosophy of Ultimate Volume Warfare [CLEVER] is centered around structured market observation rather than predictive certainty. The script is designed to organize complex participation behavior into a visual analytical environment where users can study the interaction between volume, volatility, and structure through multiple synchronized layers of confirmation and contextual filtering.

Because the system relies on confirmed pivot structures and historical participation calculations, certain signals may naturally appear after structural confirmation has occurred. This behavior is part of the confirmation-based methodology used throughout the framework and helps reduce unstable live-candle behavior that can occur when analyzing unfinished market structures.

Key Features — Ultimate Volume Warfare [CLEVER]

Advanced Volume Classification Engine

The indicator uses a layered volume analysis system designed to separate normal market participation from abnormal activity. Instead of displaying raw volume alone, the script classifies volume behavior into multiple conditions such as Climax Volume, Exhaustion, Accumulation, Distribution, Absorption, and Spike Events. This allows traders to visually identify changing market participation and potential momentum transitions with greater clarity. The classification system dynamically adapts to volatility conditions, helping the indicator remain responsive across different assets and market environments.

Adaptive Volume Moving Average System

A customizable volume moving average is integrated to help smooth market activity and identify shifts in participation strength. Users can choose between a traditional SMA-based approach or an adaptive ALMA smoothing method for more responsive volume tracking. This adaptive behavior helps reduce unnecessary noise while still reacting efficiently during periods of increased market activity.

Volume Divergence Detection

The script includes a pivot-based divergence engine that compares price structure against volume structure. By monitoring the relationship between swing highs/lows and underlying participation strength, the indicator highlights both regular and hidden divergence conditions. These divergence signals are confirmation-oriented and rely on completed pivot structures, which helps reduce impulsive or premature signaling behavior.

Multi-Layer Signal Filtering

To improve signal quality, the indicator supports several optional filters including EMA trend filtering, ATR-based volatility filtering, volume threshold filtering, and higher timeframe confirmation logic. These filters allow users to align signals with broader market conditions rather than relying solely on isolated volume behavior. The layered filtering approach is designed to support structured analysis workflows across multiple trading styles.

Higher Timeframe Volume Analysis

The integrated MTF (Multi-Timeframe) system evaluates higher timeframe volume conditions alongside the active chart timeframe. This helps traders observe whether participation is expanding or declining on broader market structures. By combining local chart activity with higher timeframe volume context, the indicator attempts to provide a more balanced interpretation of market participation.

Relative Volume Heatmap Zones

The indicator contains an optional RVOL heatmap system that visually highlights periods where relative volume exceeds predefined thresholds. These zones help identify areas of increased participation, heightened volatility, or potential institutional activity. The heatmap acts as an additional contextual layer rather than a standalone trading trigger.

High Confluence Signal Detection

A specialized confluence system combines divergence conditions with advanced volume classifications such as spikes, absorption, and climax activity. When multiple internal conditions align simultaneously, the script highlights stronger confluence zones for additional visual awareness. This feature is intended to assist with market structure observation rather than guarantee directional outcomes.

Dynamic Visual Structure

The script includes extensive visual customization including adaptive colors, divergence lines, spike markers, chart overlays, confirmation ribbons, signal labels, and statistical tables. The design focuses on improving readability while allowing users to personalize the visual experience according to their workflow and charting preferences.
Real-Time Statistical Monitoring
Built-in statistical tables provide ongoing tracking of daily and weekly signal activity, volume distribution, relative volume values, and higher timeframe participation states. These panels are designed to help users monitor evolving market behavior directly from the chart without requiring separate tools or calculations.

Confirmation-Based Logic Design

The overall architecture prioritizes confirmation-oriented behavior rather than predictive forecasting. Many components rely on completed pivot structures, confirmed candle states, and finalized volume conditions before generating visual outputs. Because of this structure, some delay may naturally occur in signal plotting, particularly during divergence analysis. This behavior is expected and reflects the script’s emphasis on structural confirmation instead of instant projection.

How It Works — Ultimate Volume Warfare [CLEVER]
The indicator works as a multi-layer volume intelligence system that combines raw volume, price structure, volatility, and higher-timeframe context into a single analytical framework. Instead of treating volume as a simple histogram, it reconstructs market behavior by classifying participation, detecting structural shifts, and validating signals through confirmations.

1. Volume Foundation Layer
At the core, the script continuously reads raw market volume and compares it against a 50-period average volume baseline. From this it calculates relative volume (RVOL), which becomes the foundation for most logic decisions. This step helps the system understand whether current activity is normal, elevated, or extreme compared to recent history.

2. Adaptive Volatility Normalization
Market conditions are not fixed, so the indicator adjusts sensitivity using ATR-based volatility scaling. When volatility expands, thresholds become more relaxed; when volatility contracts, thresholds become tighter. This prevents false signals during erratic or quiet market phases and keeps behavior consistent across different market regimes.

3. Volume Behavior Classification Engine
Each candle’s volume is categorized into behavioral states rather than just numbers:


Climax → Extremely high participation (possible exhaustion zones)


Absorption → High volume but limited price movement (smart money activity)


Exhaustion → Weak follow-through after heavy participation


Accumulation / Distribution → Directional pressure with controlled flow


Spike Events → Sudden abnormal participation bursts


This layer transforms raw volume into market intent interpretation.

4. Structure-Based Divergence System
The indicator uses pivot-based swing detection (confirmed highs and lows) to compare:


Price swings (structure)


Volume swings (participation)


If price makes a new extreme but volume fails to confirm (or reverses behavior), it generates:


Regular Divergence (trend weakening signals)


Hidden Divergence (continuation signals)


Because pivots require confirmation, signals appear only after structure completes, reducing noise but introducing slight delay.

5. Multi-Factor Filtering System
Before any signal becomes valid, it passes through multiple optional filters:


EMA Trend Filter → ensures signals align with overall trend


ATR Filter → ensures sufficient volatility for valid movement


Volume Filter → avoids low participation environments


Wick Logic (Accurate Mode) → confirms rejection behavior


HTF Filter → validates higher timeframe volume direction


This creates a confluence-based confirmation model, not a single-trigger system.

6. Signal Confirmation Engine
After divergence detection, signals are not immediately printed. They are validated through:


Volume classification (spike / absorption / climax alignment)


Filter alignment (trend + volatility + structure agreement)


Multi-timeframe confirmation (optional)


Only when multiple conditions agree, the system produces Buy/Sell labels and confluence stars.

7. Higher Timeframe Context Layer
The script optionally pulls volume data from a higher timeframe (like Daily). It compares:


Current volume trend (expanding or declining)


Higher timeframe volume state


This ensures signals are not isolated to a single timeframe and helps detect broader institutional participation shifts.

8. Visual Intelligence Layer
All internal logic is translated into:


Colored volume bars (based on classification)


Spike markers on chart and pane


Divergence lines between pivots


Confluence stars for strong setups


Heatmap zones for RVOL spikes


Stats table for session tracking


This layer turns complex logic into readable visual structure.

9. Confirmation-Based Philosophy
The entire system is built on one principle:

Nothing is predicted — everything is confirmed after structure completes.

Because of pivot confirmation and multi-condition validation, signals may appear slightly delayed, but they are structurally more reliable than real-time guessing systems.

Final Idea
In simple terms, this indicator works like a market behavior decoder:
It doesn’t just show volume — it interprets who is active, how strong they are, whether they are absorbing or pushing price, and whether the trend is supported or weakening, then confirms it using structure + filters + multi-timeframe agreement.

How It Works — Deep Core Logic (House Rules Safe)

This script is basically a volume-based market behavior engine that converts raw volume + price movement into structured trading intelligence. Instead of using simple indicators, it builds a full system that reads participation, pressure, and structural confirmation together.

1. Raw Data Foundation Layer

The system starts by continuously reading:

Volume (market participation)
Price (open, high, low, close)
Range behavior (high–low movement)
ATR (volatility baseline)

From this, it builds a foundation of how active the market is and how far price is moving for that activity.

2. Relative Volume Intelligence (RVOL Core)

It calculates:

Average volume (baseline)
Relative volume (current vs average)

This allows the system to classify whether the market is:

Normal activity
High participation
Unusual/institutional level activity

RVOL becomes the main pressure meter of the script.

3. Adaptive Volatility Control System

Instead of using fixed thresholds, the script adjusts sensitivity using volatility:

High volatility → loosens strictness
Low volatility → tightens strictness

This ensures the indicator does not overreact in choppy markets or underreact in fast trends.

This is what makes the system adaptive instead of static.

4. Volume Behavior Classification Engine

Each candle is analyzed and categorized into behavioral types:

Climax → Extreme activity, possible reversal pressure
Absorption → High volume but controlled price movement (hidden buying/selling)
Exhaustion → Weak follow-through after heavy activity
Accumulation → Quiet buying under pressure
Distribution → Quiet selling under strength
Spike Events → Sudden aggressive participation bursts

This converts raw volume into market intention mapping.

5. Pivot-Based Structure Detection

The system uses pivot logic (confirmed swing highs/lows):

Detects structural market points
Builds swing relationships
Waits for confirmation (not live guessing)

This is important because it ensures signals only appear when structure is completed, not during formation.

6. Volume vs Price Divergence System

This is one of the core engines:

It compares:

Price direction (higher highs / lower lows)
Volume behavior at those points

It detects:

Regular Divergence → trend weakening
Hidden Divergence → continuation strength

If price and volume disagree → it signals imbalance.

7. Multi-Factor Signal Filtering

Before any signal is allowed, it must pass filters:

EMA trend direction (trend alignment)
ATR movement strength (volatility validation)
Volume confirmation filter (participation check)
Wick rejection logic (price rejection strength)
Optional higher timeframe filter (market context)

This creates a confluence gate system.

If conditions don’t align → no signal.

8. Confluence Engine (Final Signal Decision Layer)

After divergence + classification + filters:

The system checks for alignment like:

Spike + divergence
Absorption + reversal structure
Climax + weak follow-through

When multiple conditions agree → it produces:

Buy / Sell labels
Confluence star signals

This is the final decision layer of the system.

9. Higher Timeframe Confirmation Layer (MTF Logic)

It optionally pulls higher timeframe volume:

Checks if volume is expanding or declining on higher TF
Aligns lower TF signals with broader trend context

This helps reduce false signals against the bigger trend.

10. Visual Interpretation Layer

Everything is converted into visual structure:

Colored volume bars (behavior-based)
Spike markers (sudden activity)
Divergence lines (structure mismatch)
Signal labels (buy/sell)
Confluence stars (strong setups)
Stats table (market session tracking)

This makes complex logic readable on chart.

Final Working Principle

At its core, the system works like this:

It does not predict price. It studies how volume behaves relative to structure, confirms conditions across multiple filters, and only then highlights high-probability market pressure zones.

Settings & Customization — Ultimate Volume Warfare [CLEVER]

This script is built like a modular trading system, meaning every major component can be tuned depending on your trading style (scalping, intraday, swing). The settings are designed to control signal speed, accuracy, sensitivity, and visual clarity.

1. Signal Sensitivity Control (Core Behavior)
Signal Intensity (sigMode)


Accurate


Strict confirmation rules


Strong filters (wick + structure quality)


Fewer signals, higher reliability




Balanced (Default)


Middle ground between speed and accuracy


Best for most traders




Aggressive


Fast signals, early entries


More noise but earlier detection




👉 This is the main brain setting of the system.

divPivot (Structure Depth)
Controlled automatically by sigMode:


Accurate → deeper pivots (5)


Balanced → medium (3)


Aggressive → shallow (2)


👉 Higher pivot = more stable but slower signals
👉 Lower pivot = faster but noisier signals

2. Volume Behavior Customization
Volume Moving Average (maLength)


Controls smoothing of volume trend


Lower value → fast reaction (scalping)


Higher value → stable trend view (swing)


ALMA Toggle (useALMA)


ON → smoother, adaptive volume curve


OFF → standard SMA (simpler structure)



Volume Spike Multiplier (spikeMult)


Defines what is considered “abnormal volume”


Low value → more spike signals


High value → only extreme spikes


👉 Recommended:


Crypto → 2.0–2.5


Forex → 2.5–3.5


Stocks → 2.0–3.0



3. Volume Classification Control
These settings control how market behavior is labeled:


Climax Volume sensitivity


Absorption detection strength


Exhaustion filtering


Accumulation / Distribution recognition


👉 You don’t manually change thresholds here; instead, they react automatically using:


Average Volume (50 SMA)


Dynamic Volatility Multiplier (dynMult)


✔ This makes the system self-adjusting across market conditions

4. Trend & Filter System (Signal Protection Layer)
EMA Filter (useEmaFilter)


ON → trades only in trend direction


OFF → allows counter-trend signals


EMA Length (emaLen)


200 = strong trend filter (safe mode)


50–100 = faster trend detection



ATR Filter (useAtrFilter)


Ensures real market movement exists


Prevents signals in low volatility zones


ATR Multiplier (atrMult)


Low → more signals (sensitive)


High → stricter entry conditions



Volume Filter (useVolFilter)


Blocks weak participation signals


Helps avoid fake breakouts



5. Higher Timeframe Control (MTF Layer)
HTF Filter (useHTFFilter)


ON → only trade with higher timeframe volume direction


OFF → independent signals


HTF Resolution (htfRes)


D (Daily) → swing confirmation


4H → intraday trend filter


1H → scalping context


👉 This is your big picture alignment tool

6. Visual Customization (Chart Control Layer)
Volume Colors


Up Volume / Down Volume / Neutral


Custom spike colors


Classification colors (climax, absorption, etc.)


👉 Used for quick visual reading of market behavior

Spike Display Settings


Show spikes on volume pane


Show spikes on main chart


Show icon markers (diamond)


👉 Helps detect sudden institutional activity

Heatmap (RVOL Zones)


ON → highlights high activity zones


Sensitivity (rvolSens):


Lower = more zones


Higher = only extreme activity zones





7. Divergence System Control
showDiv


Enables/disables full divergence engine


Strength of Divergence Logic:


Based on pivot structure


Compares price swings vs volume swings


You can tune behavior indirectly via:


sigMode (accuracy vs speed)


divPivot (structure depth)



8. Signal Display Control
showSignals
Controls:


Buy/Sell labels


Entry markers


Visual Options:


Chart overlay signals


Pane signals


Confirmation stars (confluence)


👉 Helps switch between:


Clean chart mode


Full analysis mode



9. Statistics & Table System
showTable
Displays:


Daily buy/sell activity


Weekly trend bias


RVOL strength


MTF volume state


👉 Useful for:


Session monitoring


Market behavior tracking


Strategy validation



10. Recommended Presets (Practical Use)
🔹 Scalping Setup


Aggressive mode


Low divPivot


EMA filter OFF


HTF OFF


Spike sensitivity low


🔹 Intraday Setup (Best Balanced)


Balanced mode


EMA filter ON (100–200)


ATR filter ON


HTF (4H or D)


🔹 Swing Trading Setup


Accurate mode


EMA 200 ON


HTF Daily ON


Higher spike threshold


Strict ATR filter



Final Idea
This system is not a fixed indicator — it is a customizable volume intelligence framework.
You control:


Speed (Aggressive → Accurate)


Safety (filters)


Trend alignment (EMA + HTF)


Sensitivity (spikes + pivots)


Visual depth (signals + heatmap)


👉 In simple terms:

You are not just using an indicator — you are tuning a market behavior engine according to your strategy.


Mashup Rules & Combined System Logic — Deep Explanation (House Rules Safe)

This script is not a single indicator — it is a mashup system, meaning multiple independent trading models are merged into one unified decision engine. Each module works separately, but final signals only appear when multiple layers agree.

Think of it like a multi-department trading desk where every department must approve before a signal is released.

1. Core Mashup Structure (System Architecture)

The system is built from 5 main modules:

1. Volume Intelligence Module
Classifies raw volume into behavior types:
Climax
Absorption
Exhaustion
Accumulation / Distribution
Spikes

👉 This tells what kind of pressure is in the market

2. Price Structure Module (Pivot Engine)
Detects swing highs and swing lows
Builds market structure using confirmed pivots
Identifies:
Regular divergence
Hidden divergence

👉 This tells where the market structure is changing

3. Trend Filter Module (EMA System)
Checks overall market direction using EMA
Controls whether trades align with trend or against it

👉 This tells which side is dominant

4. Volatility Filter Module (ATR System)
Measures market movement strength
Blocks low-quality or weak movement conditions

👉 This tells whether market is active enough for signals

5. Multi-Timeframe Module (HTF Logic)
Reads higher timeframe volume trend
Confirms whether lower timeframe signals match bigger structure

👉 This tells whether the move is supported by broader market flow

2. Mashup Rule System (How Everything Combines)

The system follows a strict rule chain:

STEP 1 — Detection Phase

Each module generates raw conditions:

Volume detects pressure
Price detects structure shift
Trend detects direction
Volatility detects strength
HTF detects macro alignment
STEP 2 — Filtering Phase

All signals must pass filters:

EMA alignment check
ATR movement validation
Volume participation check
Wick rejection logic (optional strict mode)
HTF confirmation (if enabled)

👉 If even one major filter fails → signal is blocked

STEP 3 — Confluence Phase (Mashup Core)

This is where systems merge.

A valid signal requires at least 2–3 conditions aligning, such as:

Divergence + Spike
Absorption + Trend alignment
Climax + Weak continuation
Structure break + Volume surge

👉 This is the decision-making engine

STEP 4 — Confirmation Phase

Even after confluence:

Signal waits for candle confirmation
Pivot must be fully formed
No mid-candle prediction allowed

👉 This ensures no premature signals

3. Combined Logic (How Mashup Actually Works)

Final decision is based on:

BUY Logic Example:
Bullish divergence detected
AND
Volume shows absorption or spike
AND
Price is above EMA trend
AND
ATR confirms movement strength
AND
HTF is not bearish

✔ THEN → Buy signal appears

SELL Logic Example:
Bearish divergence detected
AND
Volume shows distribution or spike
AND
Price is below EMA trend
AND
Volatility is sufficient
AND
HTF is not bullish

✔ THEN → Sell signal appears

4. Conflict Handling System

If modules disagree:

Volume says bullish but structure says bearish → no trade
Trend bullish but divergence bearish → wait mode
HTF opposite direction → signal weakened or blocked

👉 This prevents random or emotional signals

5. Strength Levels (Confluence Ranking)

Signals are not equal:

Weak Signal
Only divergence OR only volume spike
Medium Signal
Divergence + trend alignment
Strong Signal
Divergence + spike + absorption/climax
High Confluence Signal ⭐
Multiple modules agree simultaneously
Marked with special star confirmation
6. Why This Mashup System is Powerful

Because it does NOT rely on one idea.

It combines:

Volume behavior (who is active)
Price structure (what is happening)
Trend direction (who is in control)
Volatility state (is market ready)
Higher timeframe context (big picture bias)

👉 So the system behaves like a multi-layer institutional analysis model

Final Summary

The mashup rule system works like this:

It first detects signals independently from volume, price, trend, volatility, and higher timeframe data — then it filters them, then merges them, and finally only allows signals when multiple independent confirmations align.

This is why it is called a confluence-based volume warfare system, not a simple indicator.

Final Note — Ultimate Volume Warfare [CLEVER] 

This script is designed as a multi-layer market behavior system, not a simple indicator. Its core strength comes from combining volume, price structure, volatility, trend direction, and higher timeframe context into one unified decision framework.

At its foundation, it does not attempt to predict the market. Instead, it waits for confirmation of behavior — meaning it only reacts when multiple independent conditions align. This makes the system more focused on structure and participation rather than noise or emotional price movement.

The divergence engine ensures that price and volume relationships are continuously compared, helping identify situations where the market is losing strength or building hidden continuation pressure. However, because it relies on pivot confirmation, signals are naturally delayed until structure is fully formed. This delay is intentional and represents a shift from prediction-based systems to confirmation-based logic.

The volume classification system adds another layer of intelligence by interpreting raw volume into meaningful market states such as absorption, climax, exhaustion, accumulation, and distribution. This allows traders to understand not just how much volume exists, but what that volume represents in terms of market intent.

On top of this, filters such as EMA trend alignment, ATR volatility validation, and optional higher timeframe confirmation act as protection layers. These filters ensure that signals are only displayed when market conditions are suitable, reducing low-quality setups and improving contextual accuracy.

The mashup architecture is what makes this system unique. Instead of relying on a single signal source, it combines multiple analytical engines that must agree before any trade signal is produced. This creates a confluence-based decision model, where signals represent agreement between different aspects of market behavior rather than isolated indicators.

In practical terms, this means the system prioritizes quality over quantity. Fewer signals may appear, but each one is backed by multiple confirmations across structure, volume, and trend alignment.

Overall, the indicator behaves like a structured market intelligence framework — designed to filter noise, highlight real participation shifts, and provide visually clear confirmation zones for decision-making.

In short: it is not a prediction tool, but a confirmation system that waits for multiple layers of market agreement before showing any trading signal.

Disclaimer — Ultimate Volume Warfare [CLEVER] 
This indicator is designed strictly for educational and informational purposes only. It is a technical analysis tool that interprets market data such as volume, price structure, volatility, and higher timeframe trends. It does not guarantee results, profits, or accuracy in any market condition.
All signals generated by this script — including buy/sell labels, divergence markers, spike detection, and confluence confirmations — are based on historical and real-time data calculations. These signals are not financial advice, not investment recommendations, and should not be considered as a directive to enter or exit any trade.
Because the system relies on pivot-based structure and confirmation logic, signals may appear with a natural delay. This delay is a known and expected behavior of confirmation-based systems and does not represent prediction capability. Market conditions can change rapidly, and past performance of any signal does not guarantee future outcomes.
The script also uses multiple analytical filters such as trend alignment, volatility checks, and higher timeframe volume comparison. These filters improve contextual accuracy but cannot eliminate market risk. No system is immune to false signals, unexpected volatility, slippage, liquidity gaps, or sudden news-driven movements.
Trading in financial markets involves a high level of risk, and users are fully responsible for their own decisions. You should only use this tool as part of a broader strategy that includes proper risk management, independent analysis, and personal judgment.
The creator of this script does not take responsibility for any financial losses, missed opportunities, or incorrect interpretations resulting from the use of this indicator.

In simple terms: this is a decision-support tool, not a prediction system, and all trading decisions remain entirely the responsibility of the user.

## Source Code

````pine
//@version=6
// @description This script detects Volume Divergences using Pivot structures.
// Note: Divergence signals are confirmation-based, not predictive. 
// Due to the use of technical pivots, a "pivot confirmation delay" is expected as 
// divergence requires completed swing structures to be identified.
indicator('Ultimate Volume Warfare [CLEVER]', overlay = false, max_bars_back = 500)

//---------- Inputs ----------
showMA = input.bool(true, 'Show Volume MA')
maLength = input.int(20, 'Volume MA Length', minval = 1)
useALMA = input.bool(true, 'Use Adaptive MA (ALMA)', group = 'Volume MA Settings')
upColor = input.color(color.new(#03e8fc, 0), 'Up Volume Color')
downColor = input.color(color.new(#ff4bf6, 0), 'Down Volume Color')
neutralColor = input.color(color.new(color.gray, 0), 'Neutral Volume Color')

//---------- Volume Classification Colors ----------
climaxCol = input.color(color.new(#ff00ff, 0), 'Climax Volume', group = 'Volume Classification')
exhaustCol = input.color(color.new(#ffff00, 0), 'Exhaustion Volume', group = 'Volume Classification')
accumCol = input.color(color.new(#00ccff, 0), 'Accumulation', group = 'Volume Classification')
distCol = input.color(color.new(#ff9800, 0), 'Distribution', group = 'Volume Classification')
absorpCol = input.color(color.new(#ffffff, 0), 'Absorption', group = 'Volume Classification')
showVSA = input.bool(true, 'Show Classification Colors', group = 'Volume Classification')

//---------- Volume Spike Detection ----------
showSpikes = input.bool(true, 'Show Volume Spikes', group = 'Volume Spike Detection')
spikeMult = input.float(2.5, 'Spike Multiplier (vs Avg)', group = 'Volume Spike Detection', minval = 1.1, step = 0.1)
spikeUpCol = input.color(color.new(#00ddff, 0), 'Bull Spike Color', group = 'Volume Spike Detection')
spikeDnCol = input.color(color.new(#fb00ff, 0), 'Bear Spike Color', group = 'Volume Spike Detection')
showSpikeIcon = input.bool(true, 'Show Spike Icon', group = 'Volume Spike Detection')
showSpikeChart = input.bool(true, 'Show Spike on Main Chart', group = 'Volume Spike Detection')
showDiv = input.bool(true, 'Show Volume Divergence')
sigMode = input.string('Balanced', 'Signal Intensity', options = ['Accurate', 'Balanced', 'Aggressive'])
divPivot = sigMode == 'Accurate' ? 5 : sigMode == 'Balanced' ? 3 : 2
showSignals = input.bool(true, 'Show Buy/Sell Labels')
showTable = input.bool(true, 'Show Stats Table')
maxLines = input.int(50, 'Max Divergence Lines', minval = 10, maxval = 200, group = 'Visuals')

//---------- Filter Inputs ----------
useEmaFilter = input.bool(false, 'Use EMA Filter', group = 'Filters')
emaLen = input.int(200, 'EMA Length', minval = 1, group = 'Filters')
useVolFilter = input.bool(false, 'Use Volume Filter', group = 'Filters')
useAtrFilter = input.bool(false, 'Use ATR Filter', group = 'Filters')
atrLen = input.int(14, 'ATR Length', minval = 1, group = 'Filters')
atrMult = input.float(1.0, 'ATR Multiplier', minval = 0.1, step = 0.1, group = 'Filters')

//---------- MTF Analysis Inputs ----------
useHTFFilter = input.bool(false, 'HTF Volume Filter', group = 'MTF Analysis')
htfRes = input.timeframe('D', 'Higher Timeframe', group = 'MTF Analysis')
showHTFTable = input.bool(true, 'Show HTF in Table', group = 'MTF Analysis')

//---------- Visual & Heatmap Inputs ----------
showHeatmap = input.bool(false, 'Show RVOL Heatmap', group = 'Visuals')
rvolSens = input.float(1.5, 'Heatmap Sensitivity', minval = 1.0, step = 0.1, group = 'Visuals')
heatmapCol = input.color(color.new(#ffeb3b, 85), 'Heatmap Color', group = 'Visuals')

//---------- Volume Classification Logic ----------
avgVol = ta.sma(volume, 50)
volMA = useALMA ? ta.alma(volume, maLength, 0.85, 6) : ta.sma(volume, maLength)
rvol = volume / avgVol

avgATR = ta.atr(20)
barRange = high - low
bodyRange = math.abs(close - open)

// --- Adaptive Sensitivity Logic ---
volatilityRatio = avgATR / ta.sma(avgATR, 100)
dynMult = math.max(0.5, math.min(1.5, 1.0 / volatilityRatio)) // Adjust multiplier based on volatility

isClimax = volume > avgVol * 2.0 * dynMult
isAbsorp = not isClimax and volume > avgVol * 1.5 * dynMult and barRange < avgATR * 0.5
isExhaustion = not isClimax and not isAbsorp and volume > avgVol * 1.2 * dynMult and barRange < avgATR * 0.7
isAccum = not isClimax and not isAbsorp and close < open and volume > volMA and close > low + barRange * 0.6
isDist = not isClimax and not isAbsorp and close > open and volume > volMA and close < low + barRange * 0.4
isSpikeBull = volume > avgVol * spikeMult * dynMult and close >= open
isSpikeBear = volume > avgVol * spikeMult * dynMult and close < open
isSpike = isSpikeBull or isSpikeBear

//---------- Volume Coloring ----------
volColor = not showVSA ? close > open ? upColor : close < open ? downColor : neutralColor : showSpikes and isSpikeBull ? spikeUpCol : showSpikes and isSpikeBear ? spikeDnCol : isClimax ? climaxCol : isAbsorp ? absorpCol : isExhaustion ? exhaustCol : isAccum ? accumCol : isDist ? distCol : close > open ? upColor : close < open ? downColor : neutralColor

//---------- Plot Volume ----------
plot(volume, style = plot.style_columns, color = volColor, title = 'Volume', linewidth = 2)

//---------- Volume Moving Average ----------
plot(showMA ? volMA : na, title = 'Volume MA', color = color.new(color.yellow, 0), linewidth = 2)

//---------- Plot Spike Icons ----------
plotshape(showSpikes and showSpikeIcon and isSpikeBull ? volume : na, title = 'Bull Spike Icon', style = shape.diamond, location = location.absolute, color = spikeUpCol, size = size.tiny)
plotshape(showSpikes and showSpikeIcon and isSpikeBear ? volume : na, title = 'Bear Spike Icon', style = shape.diamond, location = location.absolute, color = spikeDnCol, size = size.tiny)
plotshape(showSpikes and showSpikeChart and isSpikeBull ? true : false, title = 'Bull Spike (Chart)', style = shape.diamond, location = location.belowbar, color = spikeUpCol, size = size.tiny, force_overlay = true)
plotshape(showSpikes and showSpikeChart and isSpikeBear ? true : false, title = 'Bear Spike (Chart)', style = shape.diamond, location = location.abovebar, color = spikeDnCol, size = size.tiny, force_overlay = true)

//---------- MTF Volume Logic ----------
[htfVol, htfVolMA] = request.security(syminfo.tickerid, htfRes, [volume, ta.sma(volume, 20)], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
htfVolUp = htfVol > htfVolMA
htfTrendLabel = htfVolUp ? 'Expanding' : 'Declining'
htfTrendCol = htfVolUp ? color.rgb(0, 226, 230) : color.rgb(255, 82, 246)

//---------- Heatmap Zones ----------
bgcolor(showHeatmap and rvol > rvolSens ? heatmapCol : na, title = 'RVOL Heatmap Zone')

// Volume divergence (price vs volume)
var float lastPriceLow = na
var float lastVolLow = na
var float lastPriceHigh = na
var float lastVolHigh = na
var int lastLowBar = na
var int lastHighBar = na

priceLowPivot = ta.pivotlow(low, divPivot, divPivot)
volLowPivot = ta.pivotlow(volume, divPivot, divPivot)
priceHighPivot = ta.pivothigh(high, divPivot, divPivot)
volHighPivot = ta.pivothigh(volume, divPivot, divPivot)

bool bullReg = false
bool bearReg = false
bool bullHidden = false
bool bearHidden = false

// --- Line Management Arrays ---
var array<line> bullLines = array.new_line()
var array<line> bearLines = array.new_line()

manage_lines(array<line> arr, line new_line, int limit) =>
    array.push(arr, new_line)
    if array.size(arr) > limit
        line.delete(array.shift(arr))

if showDiv and not na(priceLowPivot) and not na(volLowPivot)
    lowPriceVal = priceLowPivot
    lowVolVal = volLowPivot
    lowBar = bar_index - divPivot

    bullRegNew = not na(lastPriceLow) and lowPriceVal < lastPriceLow and lowVolVal > lastVolLow
    bullHiddenNew = not na(lastPriceLow) and lowPriceVal > lastPriceLow and lowVolVal < lastVolLow

    bullReg := bullRegNew
    bullHidden := bullHiddenNew

    if bullRegNew and not na(lastLowBar)
        l = line.new(lastLowBar, lastVolLow, lowBar, lowVolVal, xloc = xloc.bar_index, extend = extend.none, color = color.new(#00d3e6, 0), width = 1)
        manage_lines(bullLines, l, maxLines)
    if bullHiddenNew and not na(lastLowBar)
        l = line.new(lastLowBar, lastVolLow, lowBar, lowVolVal, xloc = xloc.bar_index, extend = extend.none, color = color.new(color.aqua, 0), width = 1)
        manage_lines(bullLines, l, maxLines)

    lastPriceLow := lowPriceVal
    lastVolLow := lowVolVal
    lastLowBar := lowBar
    lastLowBar

if showDiv and not na(priceHighPivot) and not na(volHighPivot)
    highPriceVal = priceHighPivot
    highVolVal = volHighPivot
    highBar = bar_index - divPivot

    bearRegNew = not na(lastPriceHigh) and highPriceVal > lastPriceHigh and highVolVal < lastVolHigh
    bearHiddenNew = not na(lastPriceHigh) and highPriceVal < lastPriceHigh and highVolVal > lastVolHigh

    bearReg := bearRegNew
    bearHidden := bearHiddenNew

    if bearRegNew and not na(lastHighBar)
        l = line.new(lastHighBar, lastVolHigh, highBar, highVolVal, xloc = xloc.bar_index, extend = extend.none, color = color.new(#ff52eb, 0), width = 1)
        manage_lines(bearLines, l, maxLines)
    if bearHiddenNew and not na(lastHighBar)
        l = line.new(lastHighBar, lastVolHigh, highBar, highVolVal, xloc = xloc.bar_index, extend = extend.none, color = color.new(color.orange, 0), width = 1)
        manage_lines(bearLines, l, maxLines)

    lastPriceHigh := highPriceVal
    lastVolHigh := highVolVal
    lastHighBar := highBar
    lastHighBar

bullRegPlot = showDiv and bullReg ? volume[divPivot] : na
bearRegPlot = showDiv and bearReg ? volume[divPivot] : na
bullHiddenPlot = showDiv and bullHidden ? volume[divPivot] : na
bearHiddenPlot = showDiv and bearHidden ? volume[divPivot] : na

//---------- Filters ----------
emaValue = ta.ema(close, emaLen)
atrValue = ta.atr(atrLen)
volMA_Filter = ta.sma(volume, 20)

emaFilterBull = not useEmaFilter or close > emaValue
emaFilterBear = not useEmaFilter or close < emaValue
volFilter = not useVolFilter or volume > volMA_Filter
atrFilter = not useAtrFilter or high - low > atrValue * atrMult

totalBullFilter = emaFilterBull and volFilter and atrFilter
totalBearFilter = emaFilterBear and volFilter and atrFilter

// Accuracy Booster: Wick Rejection (Only for 'Accurate' mode)
isBullWick = sigMode == 'Accurate' ? close > open and close - low > (high - low) * 0.6 : true
isBearWick = sigMode == 'Accurate' ? close < open and high - close > (high - low) * 0.6 : true

totalBullFilter := totalBullFilter and isBullWick
totalBearFilter := totalBearFilter and isBearWick

// Update Total Filters with HTF
mtfFilter = not useHTFFilter or htfVolUp
totalBullFilter := totalBullFilter and mtfFilter
totalBearFilter := totalBearFilter and mtfFilter

// --- Confirmation Ribbon Logic (Alignment of all filters) ---
isReadyBull = totalBullFilter
isReadyBear = totalBearFilter

buyPlot = showSignals and (bullReg or bullHidden) and totalBullFilter ? volume[divPivot] : na
sellPlot = showSignals and (bearReg or bearHidden) and totalBearFilter ? volume[divPivot] : na

// --- High Confluence Signal Detection ---
isConfBull = not na(buyPlot) and (isClimax or isAbsorp or isSpikeBull)
isConfBear = not na(sellPlot) and (isClimax or isAbsorp or isSpikeBear)

plotshape(bullRegPlot, offset = -divPivot, style = shape.triangleup, location = location.absolute, color = color.new(#00e2e6, 0), size = size.small, title = 'Bullish Vol Divergence')
plotshape(bearRegPlot, offset = -divPivot, style = shape.triangledown, location = location.absolute, color = color.new(#e852ff, 0), size = size.small, title = 'Bearish Vol Divergence')
plotshape(bullHiddenPlot, offset = -divPivot, style = shape.triangleup, location = location.absolute, color = color.new(color.aqua, 0), size = size.small, title = 'Hidden Bullish Vol Divergence')
plotshape(bearHiddenPlot, offset = -divPivot, style = shape.triangledown, location = location.absolute, color = color.new(color.orange, 0), size = size.small, title = 'Hidden Bearish Vol Divergence')

plotshape(buyPlot, offset = -divPivot, style = shape.labelup, location = location.absolute, text = 'Buy', color = color.new(#00e6cf, 0), textcolor = color.white, size = size.tiny, title = 'Buy Signal')
plotshape(sellPlot, offset = -divPivot, style = shape.labeldown, location = location.absolute, text = 'Sell', color = color.new(#f352ff, 0), textcolor = color.white, size = size.tiny, title = 'Sell Signal')

plotshape(buyPlot, offset = -divPivot, style = shape.labelup, location = location.belowbar, text = 'Buy', color = color.new(#00e2e6, 0), textcolor = color.white, size = size.tiny, title = 'Buy Signal (Chart)', force_overlay = true)
plotshape(sellPlot, offset = -divPivot, style = shape.labeldown, location = location.abovebar, text = 'Sell', color = color.new(#f352ff, 0), textcolor = color.white, size = size.tiny, title = 'Sell Signal (Chart)', force_overlay = true)

// --- Confluence Signal Visuals ---
plotchar(isConfBull, 'Bull Confluence', '★', location.belowbar, color.new(color.yellow, 0), offset = -divPivot, size = size.small, force_overlay = true)
plotchar(isConfBear, 'Bear Confluence', '★', location.abovebar, color.new(color.yellow, 0), offset = -divPivot, size = size.small, force_overlay = true)

// --- Confirmation Ribbon Visuals ---
plotshape(isReadyBull ? true : false, 'Bull Alignment', shape.square, location.bottom, color.new(color.lime, 50), size = size.tiny)
plotshape(isReadyBear ? true : false, 'Bear Alignment', shape.square, location.bottom, color.new(color.red, 50), size = size.tiny)

//---------- Daily / Weekly stats table ----------
// Count trades (based on visible Buy/Sell labels)
buyEvent = not na(buyPlot)
sellEvent = not na(sellPlot)

//---------- Alerts ----------
alertcondition(isSpike, title = 'Volume Spike!', message = 'Sudden Volume Spike detected!')
alertcondition(isConfBull or isConfBear, title = 'High Confluence Signal!', message = 'Advanced VSA + Divergence Signal detected!')

if bool(buyPlot) and barstate.isconfirmed
    msg = isConfBull ? 'Bullish Volume Confluence Detected (Divergence + VSA)' : 'Buy Signal'
    alert(msg + ' on ' + syminfo.ticker + ' (' + timeframe.period + ') - RVOL: ' + str.tostring(math.round(rvol, 2)), alert.freq_once_per_bar)
if bool(sellPlot) and barstate.isconfirmed
    msg = isConfBear ? 'Bearish Volume Confluence Detected (Divergence + VSA)' : 'Sell Signal'
    alert(msg + ' on ' + syminfo.ticker + ' (' + timeframe.period + ') - RVOL: ' + str.tostring(math.round(rvol, 2)), alert.freq_once_per_bar)

var int dayBuy = 0
var int daySell = 0
var int weekBuy = 0
var int weekSell = 0
var float dayBuyQty = 0.0
var float daySellQty = 0.0
var float weekBuyQty = 0.0
var float weekSellQty = 0.0
var int lastDay = na
var int lastWeek = na
var float dayVolMax = 0.0

currDay = dayofmonth(time)
currWeek = weekofyear(time)

if na(lastDay) or currDay != lastDay
    dayBuy := 0
    daySell := 0
    dayBuyQty := 0.0
    daySellQty := 0.0
    dayVolMax := 0.0
    lastDay := currDay
    lastDay

if na(lastWeek) or currWeek != lastWeek
    weekBuy := 0
    weekSell := 0
    weekBuyQty := 0.0
    weekSellQty := 0.0
    lastWeek := currWeek
    lastWeek

if buyEvent
    dayBuy := dayBuy + 1
    weekBuy := weekBuy + 1
    dayBuyQty := dayBuyQty + volume
    weekBuyQty := weekBuyQty + volume
    weekBuyQty
if sellEvent
    daySell := daySell + 1
    weekSell := weekSell + 1
    daySellQty := daySellQty + volume
    weekSellQty := weekSellQty + volume
    weekSellQty

// Track Session Volume High
if volume > dayVolMax
    dayVolMax := volume
    dayVolMax

plot(dayVolMax > 0 ? dayVolMax : na, title = 'Session Volume High', color = color.new(color.gray, 50), style = plot.style_stepline, linewidth = 1)

dayTrend = dayBuy > daySell ? 'Bullish' : dayBuy < daySell ? 'Bearish' : 'Neutral'
weekTrend = weekBuy > weekSell ? 'Bullish' : weekBuy < weekSell ? 'Bearish' : 'Neutral'

dayTrendColor = dayTrend == 'Bullish' ? color.new(#00e6c7, 0) : dayTrend == 'Bearish' ? color.new(#ff52f6, 0) : color.new(color.gray, 0)
weekTrendColor = weekTrend == 'Bullish' ? color.new(#00e6cf, 0) : weekTrend == 'Bearish' ? color.new(#ff52f6, 0) : color.new(color.gray, 0)

var table statsTbl = table.new(position.top_right, 7, 4, border_width = 1)

if showTable and barstate.islast
    // header row
    table.cell(statsTbl, 0, 0, '', bgcolor = color.new(color.black, 0), text_color = color.white, text_size = size.small)
    table.cell(statsTbl, 1, 0, 'Buys', bgcolor = color.new(color.black, 0), text_color = color.white, text_size = size.small)
    table.cell(statsTbl, 2, 0, 'Sells', bgcolor = color.new(color.black, 0), text_color = color.white, text_size = size.small)
    table.cell(statsTbl, 3, 0, 'BuyQty', bgcolor = color.new(color.black, 0), text_color = color.white, text_size = size.small)
    table.cell(statsTbl, 4, 0, 'SellQty', bgcolor = color.new(color.black, 0), text_color = color.white, text_size = size.small)
    table.cell(statsTbl, 5, 0, 'RVOL', bgcolor = color.new(color.black, 0), text_color = color.white, text_size = size.small)
    table.cell(statsTbl, 6, 0, 'Trend', bgcolor = color.new(color.black, 0), text_color = color.white, text_size = size.small)

    // Day row
    table.cell(statsTbl, 0, 1, 'Day', text_color = color.white)
    table.cell(statsTbl, 1, 1, str.tostring(dayBuy), text_color = color.white)
    table.cell(statsTbl, 2, 1, str.tostring(daySell), text_color = color.white)
    table.cell(statsTbl, 3, 1, str.tostring(math.round(dayBuyQty)), text_color = color.white)
    table.cell(statsTbl, 4, 1, str.tostring(math.round(daySellQty)), text_color = color.white)
    table.cell(statsTbl, 5, 1, str.tostring(math.round(rvol, 2)), text_color = rvol > 1.0 ? color.yellow : color.white)
    table.cell(statsTbl, 6, 1, dayTrend, text_color = dayTrendColor)

    // Week row
    table.cell(statsTbl, 0, 2, 'Week', text_color = color.white)
    table.cell(statsTbl, 1, 2, str.tostring(weekBuy), text_color = color.white)
    table.cell(statsTbl, 2, 2, str.tostring(weekSell), text_color = color.white)
    table.cell(statsTbl, 3, 2, str.tostring(math.round(weekBuyQty)), text_color = color.white)
    table.cell(statsTbl, 4, 2, str.tostring(math.round(weekSellQty)), text_color = color.white)
    table.cell(statsTbl, 5, 2, '-', text_color = color.gray)
    table.cell(statsTbl, 6, 2, weekTrend, text_color = weekTrendColor)

    // HTF row
    if showHTFTable
        table.cell(statsTbl, 0, 3, 'MTF [' + htfRes + ']', text_color = color.white)
        table.cell(statsTbl, 1, 3, 'Vol State:', text_color = color.white)
        table.cell(statsTbl, 2, 3, htfTrendLabel, text_color = htfTrendCol)
        table.cell(statsTbl, 3, 3, 'Avg:', text_color = color.white)
        table.cell(statsTbl, 4, 3, str.tostring(math.round(htfVolMA)), text_color = color.white)
        table.cell(statsTbl, 5, 3, 'Current:', text_color = color.white)
        table.cell(statsTbl, 6, 3, str.tostring(math.round(htfVol)), text_color = htfTrendCol)

//---------- Volume Legend ----------
var table legendTbl = table.new(position.bottom_right, 7, 1, border_width = 1)
if showVSA and barstate.islast
    table.cell(legendTbl, 0, 0, 'Bull Spike', bgcolor = spikeUpCol, text_color = color.black, text_size = size.tiny)
    table.cell(legendTbl, 1, 0, 'Bear Spike', bgcolor = spikeDnCol, text_color = color.white, text_size = size.tiny)
    table.cell(legendTbl, 2, 0, 'Climax', bgcolor = climaxCol, text_color = color.white, text_size = size.tiny)
    table.cell(legendTbl, 3, 0, 'Exhaustion', bgcolor = exhaustCol, text_color = color.black, text_size = size.tiny)
    table.cell(legendTbl, 4, 0, 'Accum', bgcolor = accumCol, text_color = color.black, text_size = size.tiny)
    table.cell(legendTbl, 5, 0, 'Dist', bgcolor = distCol, text_color = color.white, text_size = size.tiny)
    table.cell(legendTbl, 6, 0, 'Absorp', bgcolor = absorpCol, text_color = color.black, text_size = size.tiny)
````
