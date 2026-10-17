# RSI-T (RSI + Time)

- url: https://www.tradingview.com/script/MqjZfBFe-RSI-T-RSI-Time/
- type: indicator
- pine_id: PUB;c9aaea14eb3f4a2bb5525829c9cb03e8
- version: 1.0

## Description

RSI-T
RSI with Time Parameter


Technical White Paper & User Guide
Dimitrios Kataliakos
May 2026

Based on the theory: "Market as Expanding Dough"
(Agora os Diogkoumeno Zymari)
 
Table of Contents
Table of Contents	1
1. Executive Summary	1
2. Theoretical Foundation	1
2.1 The Market as Expanding Dough	1
2.2 Time as a Curvature Factor	1
2.3 Regime Classification	1
3. Mathematical Definition	1
3.1 Core Formula	1
3.2 Parameters	1
3.3 Derived Metrics	1
4. Timeframe Analysis	1
4.1 Timeframe Weight	1
4.2 Recommended Settings by Timeframe	1
4.3 Multi-Timeframe Confluence	1
5. User Guide	1
5.1 Installation (TradingView)	1
5.2 Reading the Indicator	1
5.3 Trading Rules	1
Rule 1: Regime Identification First	1
Rule 2: Do Not Short Persistent Bull	1
Rule 3: Do Not Buy Persistent Bear	1
Rule 4: Momentum Zone is Decision Zone	1
Rule 5: Watch the Divergence	1
5.4 Practical Examples	1
6. Backtest Strategy	1
6.1 Strategy Logic	1
6.2 Risk Management	1
6.3 Pine Script Strategy	1
6.4 Metrics to Evaluate	1
7. Limitations & Future Work	1
7.1 Known Limitations	1
7.2 Future Development	1
8. Appendix	1
8.1 Files Included	1
8.2 Version History	1

 
1. Executive Summary
The RSI-T (RSI with Time) is a technical indicator that extends the classic Wilder RSI by adding a third parameter: the duration of time price action remains in an extreme zone. While the standard RSI measures the magnitude of recent price changes, it fails to capture the persistence of momentum regimes. The RSI-T solves this by quantifying how long the RSI stays above or below threshold levels, providing traders with a tool that distinguishes between transient spikes and sustained directional moves.
The indicator is derived from the economic theory of markets as expanding systems, where price does not tend toward equilibrium but rather expands unevenly, creating zones of compression and expansion. The RSI-T operationalizes this concept by treating the time spent in extreme RSI territory as a measure of regime strength.

2. Theoretical Foundation
2.1 The Market as Expanding Dough
Traditional economic theory assumes markets tend toward equilibrium. The theory underlying RSI-T proposes an alternative model: the market behaves like expanding dough, where nominal prices continuously inflate, but the expansion is uneven across time and sectors. This creates regions of rapid expansion (bubbles, momentum regimes) and compression (consolidations, mean-reversion zones).
The three analytical layers of this model are:
•	Geometry (Curvature): How price curves in space, measured through momentum and convexity. This corresponds to the RSI dimension of the indicator.
•	Temperature (Volatility): The thermal energy of the market, measured through implied and realized volatility. This informs the threshold sensitivity.
•	Cohesion (Liquidity): The structural integrity of price action, related to order flow and market microstructure. This provides context for regime classification.
2.2 Time as a Curvature Factor
The critical insight of RSI-T is that time spent at extremes is itself information. When the RSI remains above 70 for one bar, it may be a transient spike. When it remains above 70 for eight consecutive bars, the market has entered a different regime entirely. Standard RSI treats both situations identically. RSI-T does not.
In the dough metaphor, this corresponds to a region that is not just expanded, but has been expanding for a sustained period. The longer the expansion persists, the more the local structure of the market has reorganized around the new price level, and the less likely a simple mean-reversion is to occur.
This is consistent with empirical findings in momentum literature: assets that have been trending tend to continue trending, and the duration of the trend is a stronger predictor of continuation than the magnitude alone.
2.3 Regime Classification
The RSI-T framework classifies market states into distinct regimes based on the combination of RSI level and time at extreme:
Regime	RSI Condition	Time Condition
NEUTRAL	Between oversold and overbought	Counter = 0
MOMENTUM_BULL	RSI > Overbought threshold	2 to N-1 bars
MOMENTUM_BEAR	RSI < Oversold threshold	2 to N-1 bars
PERSISTENT_BULL	RSI > Overbought threshold	N or more bars
PERSISTENT_BEAR	RSI < Oversold threshold	N or more bars

Where N is the persistence threshold (default: 5 bars). In the persistent regimes, traditional mean-reversion signals (e.g., sell when RSI > 70) are weakened or inverted.
 
3. Mathematical Definition
3.1 Core Formula
The RSI-T value is calculated as:
RSI_T = clamp( RSI + (bars_at_extreme × time_weight × direction), 0, 100 )
Where:
•	RSI = Standard Wilder RSI(close, period)
•	bars_at_extreme = consecutive bars where RSI > threshold_OB or RSI < threshold_OS
•	time_weight (α) = scaling factor per bar of persistence (default: 1.2)
•	direction = +1 if RSI > threshold_OB, -1 if RSI < threshold_OS, 0 otherwise
•	clamp() = constrains result to [0, 100]
3.2 Parameters
Parameter	Default	Range	Description
period	14	5 – 50	RSI lookback period (Wilder smoothing)
threshold	70 / 30	55–90 / 10–45	Overbought / Oversold boundary
time_weight (α)	1.2	0.0 – 5.0	Signal boost per bar at extreme
max_boost	20	5 – 40	Maximum cumulative boost (cap)
persist_bars (N)	5	2 – 20	Bars required for persistent regime
3.3 Derived Metrics
•	Divergence = RSI_T − RSI: Measures the total impact of the time parameter. When divergence is zero, RSI-T equals classic RSI. When divergence is large, the time dimension is providing significant additional information.
•	Time Counter (bars_extreme): The raw number of consecutive bars spent above/below the threshold. This is the primary regime classifier.
•	Regime Label: Categorical classification (NEUTRAL, MOMENTUM_BULL, MOMENTUM_BEAR, PERSISTENT_BULL, PERSISTENT_BEAR) derived from the combination of RSI level and time counter.
 
4. Timeframe Analysis
The RSI-T works across all timeframes, but its interpretation changes because the time counter has different weight depending on bar duration.
4.1 Timeframe Weight
Timeframe	1 Bar =	5 Bars (Persistent) =	Interpretation
1 minute	1 minute	5 minutes	Micro-momentum, scalping noise common
5 minutes	5 minutes	25 minutes	Intraday momentum phases
15 minutes	15 minutes	1.25 hours	Session-level regime shifts
1 hour	1 hour	5 hours	Intraday trend confirmation
4 hours	4 hours	20 hours	Multi-session directional bias
Daily	1 day	1 week	Swing-level regime classification
Weekly	1 week	5 weeks (~1 month)	Position-level trend strength
Monthly	1 month	5 months	Macro regime identification
4.2 Recommended Settings by Timeframe
Timeframe	Period	Time Weight	Persist Bars
1–5 min	14	0.5 – 0.8	8 – 12
15–60 min	14	0.8 – 1.2	5 – 8
4H / Daily	14	1.0 – 1.5	4 – 6
Weekly	14	1.5 – 2.0	3 – 5
Monthly	14	2.0 – 3.0	3 – 4

The general principle: shorter timeframes need more bars to confirm persistence (more noise to filter), while longer timeframes establish regimes faster because each bar carries more weight.
4.3 Multi-Timeframe Confluence
The highest-conviction signals occur when multiple timeframes agree. For example, if the daily RSI-T shows PERSISTENT_BULL and the weekly RSI-T enters MOMENTUM_BULL, this represents a multi-timeframe momentum alignment that significantly increases the probability of trend continuation.
Conversely, if the daily is in PERSISTENT_BULL but the weekly RSI-T is declining from a recent extreme, this divergence between timeframes suggests the persistent regime may be nearing exhaustion.
 
5. User Guide
5.1 Installation (TradingView)
1.	Open TradingView and navigate to the chart of your chosen instrument.
2.	Click Pine Editor at the bottom of the screen.
3.	Click New and select New indicator.
4.	Delete all existing code and paste the RSI-T Pine Script (v6) code.
5.	Click Add to chart. The RSI-T panel appears below the price chart.
6.	Adjust parameters via the Settings gear icon on the indicator.
5.2 Reading the Indicator
Blue line: Classic RSI. This is the baseline reference.
Orange/Red line: RSI-T. When this diverges from the blue line, the time parameter is active and providing additional information.
Histogram (bottom): Scaled time counter showing the number of bars spent at the extreme zone.
Green background: Persistent bull regime. The RSI has been above the overbought threshold for N or more bars.
Red/orange background: Persistent bear regime (red) or momentum bear/bull (orange/blue).
Blue background: Momentum bull. RSI above overbought for 2 to N-1 bars. Early-stage momentum zone.
5.3 Trading Rules
Rule 1: Regime Identification First
Before making any trading decision, identify the current regime from the background color. In NEUTRAL regime, traditional RSI-based mean-reversion strategies apply normally. In MOMENTUM or PERSISTENT regimes, mean-reversion signals are weakened or inverted.
Rule 2: Do Not Short Persistent Bull
When the RSI-T shows persistent bull (green background), do not initiate short positions based on overbought readings. The persistence signal indicates that the market has reorganized around the uptrend and further upside is more likely than immediate reversal. Wait for the regime to reset (counter returns to zero) before considering mean-reversion trades.
Rule 3: Do Not Buy Persistent Bear
The inverse of Rule 2. When persistent bear is active (red background), do not buy dips based on oversold readings. The selling pressure has established itself as a regime, not a transient condition.
Rule 4: Momentum Zone is Decision Zone
The blue/orange background (momentum zone, 2 to N-1 bars) is where decisions are made. This is the transitional phase where the market is testing whether it will establish a persistent regime or revert. Tighter stops and smaller positions are appropriate here.
Rule 5: Watch the Divergence
When RSI-T diverges significantly from classic RSI (large divergence value), the time dimension is dominating. A sudden collapse of this divergence (counter drops to zero) often precedes sharp reversals, as the accumulated time pressure releases.
5.4 Practical Examples
Scenario	RSI-T Reading	Action
RSI at 75, counter = 1	Momentum bull (blue bg)	Standard caution, normal position sizing
RSI at 75, counter = 7	Persistent bull (green bg)	Do NOT short. Trailing stop on existing longs
RSI at 42, counter = 0	Neutral	Normal analysis applies. No regime signal
RSI at 25, counter = 6	Persistent bear (red bg)	Do NOT buy dips. Wait for regime exit
RSI at 72, counter drops from 5 to 0	Regime exit	Alert: potential reversal. Tighten stops
 
6. Backtest Strategy
6.1 Strategy Logic
The RSI-T Strategy for backtesting converts the indicator into actionable entries and exits. The core logic uses regime transitions as signals:
Long Entry:
•	RSI-T crosses above the overbought threshold AND the time counter reaches the momentum threshold (2 bars), confirming directional commitment.
•	Alternative: Enter when the regime transitions from NEUTRAL to MOMENTUM_BULL (catching the early phase of a potential persistent move).
Long Exit:
•	The time counter resets to zero after being in persistent bull (regime exit signal).
•	Alternative: RSI-T crosses below the midline (50) from above.
Short Entry:
•	RSI-T crosses below the oversold threshold AND the time counter reaches the momentum threshold.
Short Exit:
•	Time counter resets to zero after persistent bear, or RSI-T crosses above midline.
6.2 Risk Management
•	Position size: 10% of equity per trade (adjustable in strategy settings).
•	Stop loss: Based on ATR multiplier (default 2x ATR-14) to account for regime volatility.
•	Trailing stop: Activates once position reaches 1.5x risk in profit.
•	No pyramiding by default (can be enabled for persistent regime continuation).
6.3 Pine Script Strategy
A complete Pine Script v6 strategy file (rsi_t_strategy_v6.pine) is provided alongside this document. The strategy includes configurable parameters for entry/exit rules, position sizing, stop-loss, and trailing stop. It can be applied to any instrument and timeframe in TradingView for historical backtesting.
6.4 Metrics to Evaluate
When backtesting the RSI-T strategy, focus on the following metrics to validate the theoretical framework:
•	Win Rate in Persistent vs. Momentum vs. Neutral regimes (the theory predicts higher win rates in persistent regimes for trend-following entries).
•	Average trade duration across regimes (persistent regime trades should be longer and more profitable).
•	False signal rate: How often does momentum (blue background) fail to convert to persistent (green background)?
•	Regime exit accuracy: What percentage of regime exits (counter reset) are followed by actual reversals within N bars?
•	Comparison vs. classic RSI strategy (same entry rules without the time parameter) to isolate the value added by the time dimension.
 
7. Limitations & Future Work
7.1 Known Limitations
•	The RSI-T is a lagging indicator by nature. The time counter requires bars to accumulate before signaling persistence, meaning the earliest phase of a move is not captured.
•	In choppy or range-bound markets, the counter may produce false starts, briefly entering momentum zone before resetting. The persist_bars threshold helps filter these but cannot eliminate them entirely.
•	The linear time_weight model (each bar adds the same boost) may not be optimal. Markets may exhibit non-linear acceleration, where the 10th bar at extreme is more significant than the 3rd.
•	The indicator does not incorporate volume, volatility, or cross-asset information. It is purely price-derived.
7.2 Future Development
•	Non-linear time weighting: Exponential or logarithmic boost curves that better reflect the accelerating nature of regime establishment.
•	Volatility-adjusted thresholds: Dynamic overbought/oversold levels that adjust based on current implied volatility (high-vol environments may require wider thresholds).
•	Fast/Slow RSI divergence: Comparing RSI-T across different periods (e.g., RSI-T(7) vs RSI-T(21)) to measure regime acceleration, as described in the original theory.
•	Cross-asset regime correlation: Using the RSI-T regime of correlated assets (e.g., SPX for individual stocks) as a confirmation layer.
•	Machine learning optimization: Using historical data to optimize time_weight and persist_bars parameters per asset class and market regime.

8. Appendix
8.1 Files Included
File	Description
rsi_t_v6.pine	RSI-T indicator for TradingView (Pine Script v6)
rsi_t_strategy_v6.pine	RSI-T backtest strategy for TradingView (Pine Script v6)
rsi_t_indicator.py	RSI-T Python implementation for custom backtesting
8.2 Version History
Version	Date	Changes
1.0	May 2026	Initial release: RSI-T indicator, strategy, white paper

Copyright © 2026 Dimitrios Kataliakos. All rights reserved.
This document and the associated indicator code are proprietary work based on the original theory of markets as expanding systems.

## Source Code

````pine
// This source code is subject to the Mozilla Public License 2.0
// RSI-T: RSI με τρίτη παράμετρο τον Χρόνο
// Βασισμένο στη θεωρία "Αγορά ως Διογκούμενο Ζυμάρι" — D. Kataliakos, 2026
// ─────────────────────────────────────────────────────────────────────────────
//@version=6
indicator(title = "RSI-T (RSI + Time)", shorttitle = "RSI-T", overlay = false, max_bars_back = 500)

// ── Inputs ────────────────────────────────────────────────────────────────────
grp1 = "RSI Settings"
rsi_period   = input.int(14,   "RSI Period",       minval = 2,  maxval = 50, group = grp1)
threshold_ob = input.float(70, "Overbought Level", minval = 55, maxval = 90, group = grp1, step = 1)
threshold_os = 100.0 - threshold_ob

grp2 = "Time Parameter"
time_weight = input.float(1.2,  "Time Weight (α)", minval = 0.0, maxval = 5.0,  group = grp2, step = 0.1,
              tooltip = "Πόσο ενισχύεται το σήμα ανά bar παραμονής στο extreme zone.\n0 = κλασικό RSI  |  1–2 = μέτριο  |  3+ = aggressive.")
max_boost   = input.float(20.0, "Max Boost (cap)", minval = 5.0, maxval = 40.0, group = grp2, step = 1,
              tooltip = "Ανώτατη επίδραση του time_weight.")

grp3 = "Regime Thresholds"
persist_bars = input.int(5, "Persistent Regime (bars)", minval = 2, maxval = 20, group = grp3,
               tooltip = "Πόσα bars στο extreme ορίζουν persistent momentum regime.")

grp4 = "Display"
show_rsi     = input.bool(true, "Show classic RSI",  group = grp4)
show_rsit    = input.bool(true, "Show RSI-T",        group = grp4)
show_bars    = input.bool(true, "Show time counter", group = grp4)
show_bgcolor = input.bool(true, "Regime background", group = grp4)

// ── RSI Classic (Wilder) ──────────────────────────────────────────────────────
rsi_val = ta.rsi(close, rsi_period)

// ── Time Counter ──────────────────────────────────────────────────────────────
var int bars_extreme = 0
var int direction    = 0

if na(rsi_val)
    bars_extreme := 0
    direction    := 0
else if rsi_val > threshold_ob
    bars_extreme := bars_extreme + 1
    direction    := 1
else if rsi_val < threshold_os
    bars_extreme := bars_extreme + 1
    direction    := -1
else
    bars_extreme := 0
    direction    := 0

// ── RSI-T Calculation ─────────────────────────────────────────────────────────
boost      = math.min(bars_extreme * time_weight, max_boost) * direction
rsi_t      = math.max(0.0, math.min(100.0, rsi_val + boost))
divergence = rsi_t - rsi_val

// ── Regime Classification ─────────────────────────────────────────────────────
persistent_bull = rsi_val > threshold_ob and bars_extreme >= persist_bars
persistent_bear = rsi_val < threshold_os and bars_extreme >= persist_bars
momentum_bull   = rsi_val > threshold_ob and bars_extreme >= 2 and bars_extreme < persist_bars
momentum_bear   = rsi_val < threshold_os and bars_extreme >= 2 and bars_extreme < persist_bars

// ── Background (global scope — bgcolor δεν επιτρέπεται σε local scope) ────────
bgcolor_col = switch
    not show_bgcolor    => na
    persistent_bull     => color.new(#1D9E75, 60)
    persistent_bear     => color.new(#D85A30, 60)
    momentum_bull       => color.new(#378ADD, 72)
    momentum_bear       => color.new(#BA7517, 72)
    =>                     na

bgcolor(bgcolor_col, title = "Regime background")

// ── Levels ────────────────────────────────────────────────────────────────────
hline(threshold_ob, "Overbought", color = color.new(#1D9E75, 50), linestyle = hline.style_dashed, linewidth = 1)
hline(threshold_os, "Oversold",   color = color.new(#1D9E75, 50), linestyle = hline.style_dashed, linewidth = 1)
hline(50,           "Midline",    color = color.new(#888780, 70), linestyle = hline.style_dotted,  linewidth = 1)

// ── Plots ─────────────────────────────────────────────────────────────────────
plot(show_rsi  ? rsi_val : na, title = "RSI",   color = color.new(#378ADD, 0), linewidth = 2)
plot(show_rsit ? rsi_t   : na, title = "RSI-T", color = color.new(#D85A30, 0), linewidth = 2)

bars_norm = math.min(bars_extreme / math.max(max_boost / time_weight, 1.0), 1.0) * 30
plot(show_bars ? bars_norm : na, title = "Time Counter (scaled)",
     color = color.new(#888780, 40), linewidth = 1, style = plot.style_histogram)

// ── Data Window ───────────────────────────────────────────────────────────────
plot(rsi_val,      title = "[data] RSI",         display = display.data_window, color = color.new(#378ADD, 0))
plot(rsi_t,        title = "[data] RSI-T",        display = display.data_window, color = color.new(#D85A30, 0))
plot(divergence,   title = "[data] Divergence",   display = display.data_window, color = color.gray)
plot(bars_extreme, title = "[data] Bars extreme", display = display.data_window, color = color.gray)

// ── Alerts ────────────────────────────────────────────────────────────────────
alertcondition(persistent_bull and not persistent_bull[1],
               title   = "Persistent Bull Regime",
               message = "RSI-T: Persistent BULL regime ▲")

alertcondition(persistent_bear and not persistent_bear[1],
               title   = "Persistent Bear Regime",
               message = "RSI-T: Persistent BEAR regime ▼")

alertcondition(bars_extreme == 0 and bars_extreme[1] > 0,
               title   = "Regime Exit",
               message = "RSI-T: Έξοδος από extreme zone — regime reset")
````
