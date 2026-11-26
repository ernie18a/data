# Liquidity Intelligence Entry System

- url: https://www.tradingview.com/script/6hrPRiif-Liquidity-Intelligence-Entry-System/
- type: indicator
- pine_id: PUB;3b80657506ba4c659dcf20518afac612
- version: 2.0

## Description

Liquidity Intelligence System

Liquidity Intelligence System is a liquidity-based market analysis framework designed around one central idea:

market movement is often shaped by liquidity pools, stop sweeps, directional bias, displacement, volatility conditions, and the quality of confluence around a signal.

This script is not designed to mark every candle, every swing, or every possible reversal. It is not intended to behave like a simple buy/sell indicator that reacts to one isolated condition. Its purpose is to detect structured liquidity events, compare multiple confluence models in the background, classify the current market regime, display signal quality, and project a visual risk/reward framework directly on the chart.

The script combines liquidity sweep detection, trend confirmation, FVG presence, volume expansion, RSI extremes, displacement behavior, market regime logic, adaptive preset modes, TP1/TP2/TP3 projection, visual liquidity mapping, and a model-performance dashboard into one organized workflow.

The goal is to help users review liquidity-based signals in a more structured way, not to promise future performance or replace independent analysis.


🔓 PUBLICATION NOTE

This script is published to provide a structured liquidity-analysis workflow.

The description is intentionally detailed because many users do not inspect every part of the Pine Script logic line by line. The purpose of this page is to explain what the script does, how its components connect, why the system is organized this way, and what limitations should be understood before using it.

The script should be treated as a decision-support and research tool. It is not financial advice, it is not an automated trading system, and it does not guarantee profitable results.


📌 OVERVIEW

At a high level, Liquidity Intelligence System does several things:

1. It detects liquidity sweep conditions around recent swing highs and swing lows.
2. It identifies buy-side liquidity and sell-side liquidity areas.
3. It can mark Equal High and Equal Low liquidity pools.
4. It changes swept liquidity levels visually once price takes them.
5. It evaluates 16 different liquidity/confluence signal models in the background.
6. It allows the user to manually choose which model should be active on the chart.
7. It prevents repeated same-direction signals from stacking unnecessarily.
8. It calculates virtual trade outcomes for each model.
9. It displays model statistics such as Trades, Win Rate, Profit Factor, Average R, and Net R.
10. It identifies the current best-performing model according to a selected metric.
11. It detects the current market regime using trend, ADX-style directional movement, ATR behavior, and candle body conditions.
12. It gives the most recent signal a Signal Quality score.
13. It displays a Signal Quality panel with a visual score bar.
14. It projects Entry, TP1, TP2, TP3, and SL levels on the chart.
15. It draws soft reward and risk zones around the active signal.
16. It provides theme modes for different chart styles.
17. It includes dynamic alert messages with signal, model, quality, regime, entry, TP, SL, and performance details.

The script is therefore not a single-purpose liquidity sweep marker. It is a multi-model liquidity intelligence and signal-review framework.


🧠 CORE IDEA

The core idea of the script is that a liquidity sweep by itself is only one part of the story.

A market may sweep a previous high or low, but that does not automatically mean the move is actionable. A sweep can lead to reversal, continuation, expansion, or false movement depending on the broader context.

For that reason, Liquidity Intelligence System does not rely on one condition alone.

Instead, it builds a layered model around the following question:

When liquidity is taken, what other evidence exists around that event?

The system can evaluate liquidity events together with:

- trend direction,
- recent FVG behavior,
- volume expansion,
- RSI extreme positioning,
- displacement strength,
- current market regime,
- and model-specific confluence.

This allows the script to compare different interpretations of the same market environment.

For example, one user may prefer simple liquidity sweeps, while another may prefer liquidity sweeps only when FVG and trend alignment are also present. The script does not force one fixed interpretation. It allows multiple models to run in the background while the user selects the model they want to display.


🧩 WHY THIS SCRIPT IS NOT A SIMPLE MASHUP

This script combines several concepts that are familiar in technical analysis and liquidity-based trading:

- swing highs and swing lows,
- liquidity sweeps,
- equal highs and equal lows,
- FVG-style imbalance logic,
- trend filters,
- volume filters,
- RSI conditions,
- displacement candles,
- ATR-based risk projection,
- dashboard statistics,
- alert messages.

These individual concepts are not unique by themselves.

The main purpose of this script is the way these elements are organized into one structured liquidity workflow:

Liquidity map
→ sweep detection
→ confluence model selection
→ market regime classification
→ signal quality scoring
→ TP1/TP2/TP3 projection
→ model-performance dashboard
→ dynamic alert system

Each part has a specific role.

- The liquidity map shows where price may be interacting with stop pools.
- The sweep engine defines the base signal event.
- The confluence models decide which extra filters should be required.
- The regime engine gives context about the current environment.
- The quality panel summarizes the last signal.
- The dashboard compares the performance of different models.
- The TP/SL projection gives a visual review structure.
- The alert system allows monitoring without constantly watching the chart.

For that reason, the script is intended as one complete liquidity-intelligence framework, not as a random collection of unrelated tools.


💧 WHAT THE SCRIPT DOES

The script begins by detecting swing-based liquidity references.

It uses recent pivot highs and pivot lows to define potential buy-side and sell-side liquidity levels.

Then it can classify and draw:

- BSL: Buy-Side Liquidity
- SSL: Sell-Side Liquidity
- EQH: Equal High liquidity
- EQL: Equal Low liquidity

When price later trades through one of these mapped levels, the script can visually mark that level as swept. This makes the liquidity map more informative because old untouched levels and swept levels are no longer displayed the same way.

After the liquidity engine identifies sweep conditions, the script evaluates whether the sweep qualifies under one of the available model combinations.

Those models are tested in the background, while the user chooses which one should be active on the chart.

The active model controls the visible LONG / SHORT labels and the projected Entry / TP / SL structure.


⚙️ HOW THE SCRIPT WORKS

1) LIQUIDITY SWEEP ENGINE

The script uses swing pivots to identify important recent highs and lows.

A buy-side sweep occurs when price moves above a previous swing high and then closes back below that swing high.

A sell-side sweep occurs when price moves below a previous swing low and then closes back above that swing low.

The script also checks sweep depth and wick rejection. This helps avoid treating every small break of a level as an equally meaningful sweep.

The sweep engine uses:

- swing pivot length,
- maximum sweep depth measured with ATR,
- rejection wick ratio,
- current candle structure,
- and the most recent mapped swing levels.

This base liquidity engine creates the foundation for all model combinations.


2) BSL / SSL LIQUIDITY MAP

The script can draw liquidity levels directly on the price chart.

The map may include:

- BSL above swing highs,
- SSL below swing lows,
- EQH when similar highs form near each other,
- EQL when similar lows form near each other.

The liquidity map is designed to be selective rather than excessive.

A quality mode controls how many levels are displayed:

- Balanced: more levels,
- Conservative: cleaner default view,
- Strict: fewer but more selective levels.

The script also limits the maximum number of active liquidity lines so the chart does not become overloaded.


3) SWEPT LIQUIDITY VISUAL STATE

When price reaches a mapped liquidity level, the script can mark that line as swept.

A swept liquidity line changes visually:

- the line becomes grey,
- the style changes,
- the label changes to SWEPT.

This makes it easier to distinguish active liquidity pools from liquidity that has already been taken.

This visual behavior is important because liquidity levels are not static forever. Once price has interacted with a level, its meaning may change.


4) EQUAL HIGH / EQUAL LOW LOGIC

The script can detect similar high or low points using an ATR-based tolerance.

Equal highs can represent a potential buy-side liquidity pool.
Equal lows can represent a potential sell-side liquidity pool.

Because instruments have different volatility, the tolerance is not fixed in raw price terms. It is scaled with ATR.

This makes the EQH / EQL logic more adaptive across different markets and timeframes.


🧠 16 MODEL SYSTEM

The script includes 16 model combinations.

These models are evaluated in the background:

1. LQ
2. LQ + Trend
3. LQ + FVG
4. LQ + Volume
5. LQ + RSI
6. LQ + Displacement
7. LQ + Trend + FVG
8. LQ + Trend + Volume
9. LQ + Trend + RSI
10. LQ + Trend + Displacement
11. LQ + FVG + Volume
12. LQ + FVG + RSI
13. LQ + FVG + Displacement
14. LQ + Volume + RSI
15. LQ + Trend + FVG + Volume
16. LQ + Trend + FVG + Volume + RSI + Displacement

The user can choose one active model from the settings.

The active model is the one that controls the visible chart signals.
The other models still run in the background for dashboard comparison.

This is one of the main ideas of the script: the user does not have to guess which confluence combination is currently performing better. The dashboard can compare the models over the visible historical calculation period.


📈 TREND COMPONENT

The trend component compares a fast EMA and a slow EMA.

If the fast EMA is above the slow EMA, the script treats the trend condition as bullish.
If the fast EMA is below the slow EMA, the script treats the trend condition as bearish.

This does not mean the EMA lines have to be plotted on the chart. They can work silently as internal filters.

When a model uses Trend, the liquidity signal must align with the EMA-based directional condition.


🟩 FVG COMPONENT

The FVG component checks for recent imbalance-style behavior.

The script identifies bullish and bearish FVG-style conditions and then checks whether such a condition has occurred within a recent lookback window.

This allows models such as:

- LQ + FVG,
- LQ + Trend + FVG,
- LQ + FVG + Volume,
- LQ + FVG + Displacement,

to require liquidity behavior together with recent imbalance context.

The FVG logic in this version is used as a filter and confluence component. It is not presented as a full FVG box-management system.


🔊 VOLUME COMPONENT

The volume component compares current volume against a volume moving average.

When current volume exceeds the selected volume average by the chosen multiplier, the script treats it as a volume expansion condition.

This can help models focus on sweeps that occur with stronger activity.

Volume is not used as proof of future direction. It is used as one additional context layer.


📉 RSI COMPONENT

The RSI component allows the script to include oscillator conditions in selected models.

For long models, RSI can be required to be near or below a selected lower threshold.
For short models, RSI can be required to be near or above a selected upper threshold.

This allows RSI to function as a contextual filter around liquidity events rather than as a standalone signal generator.


⚡ DISPLACEMENT COMPONENT

The displacement component checks whether the signal candle has enough body strength relative to ATR and total candle range.

A bullish displacement condition requires:

- bullish candle body,
- minimum body size relative to ATR,
- minimum body ratio inside the candle range.

A bearish displacement condition uses the opposite candle direction.

This helps identify signals where the sweep is followed by stronger directional candle behavior.


🧠 MARKET REGIME DETECTION

The script includes a market regime engine.

It classifies the current environment into states such as:

- Trend Up
- Trend Down
- Range
- Choppy
- High Vol
- Low Vol
- Neutral

The regime engine uses:

- directional movement logic,
- ADX-style trend strength,
- EMA trend direction,
- ATR compared to its average,
- candle body ratio behavior.

The purpose of this engine is to provide context.

A liquidity sweep in a trending market is not the same as a liquidity sweep in a range.
A signal during choppy conditions may require more caution than a signal during clean directional expansion.

The regime output is also used in the Signal Quality framework.


⭐ SIGNAL QUALITY SCORE

The Signal Quality score is a 0–100 style scoring framework.

The score is designed to summarize the most recent signal’s contextual quality.

It can consider:

- whether the signal is a valid liquidity event,
- whether the selected model’s trend condition is satisfied,
- whether the selected model’s FVG condition is satisfied,
- whether the selected model’s volume condition is satisfied,
- whether the selected model’s RSI condition is satisfied,
- whether the selected model’s displacement condition is satisfied,
- whether the market regime supports or conflicts with the signal direction.

The important detail is that the score is connected to the active model.

For example:

If the active model is LQ + FVG, FVG matters more directly.
If the active model is LQ + Volume, volume matters more directly.
If the active model is LQ + Trend + FVG + Volume, all of those conditions become part of the model-specific score.

This helps avoid a generic score that ignores the selected model’s logic.


📊 SIGNAL QUALITY PANEL

The Signal Quality panel displays a compact summary of the last signal.

It can show:

- current regime,
- market bias,
- last signal side,
- active model,
- signal score,
- mini score bar,
- alignment state.

The score bar is included to make the quality reading easier to review visually.

Example format:

Score: 78/100
Bar: ████████░░

This panel is not intended to guarantee that a signal will work. It simply summarizes how much contextual evidence was present when the signal appeared.


📊 MODEL DASHBOARD

The main dashboard compares the 16 models.

It includes:

- Trades
- WR
- PF
- Avg R
- Net R
- Active model row
- Best system row

The dashboard is meant for internal review.

It does not represent broker-executed trades. It is a virtual model-testing layer based on the script’s signal and TP/SL rules.

The dashboard helps the user compare whether one model is currently producing cleaner historical behavior than another, but it should not be interpreted as a guarantee that the same behavior will continue.


🏆 BEST SYSTEM ROW

The script can identify a Best System based on the selected metric.

The user can choose the best-system metric from:

- Net R
- Profit Factor
- Average R
- Win Rate

The system also uses a minimum trade count before a model can qualify for the Best row.

This is important because a model with only one or two trades can look misleading. The minimum trade threshold helps reduce the chance of highlighting a model with too little sample size.


🎛️ PRESET MODES

The script includes preset modes.

Available presets:

- Manual
- Scalping
- Intraday
- Swing
- Conservative
- Aggressive
- Funded Account Safe

The default preset is Intraday.

Preset modes do not simply change the name of the setting. They adjust internal effective values such as:

- TP / SL behavior,
- maximum bars in trade,
- sweep depth sensitivity,
- rejection requirement,
- FVG recency,
- volume multiplier,
- displacement requirements.

Manual mode allows the user to control the underlying settings directly.

Presets are included to make the script easier to adapt to different trading styles without requiring every setting to be adjusted one by one.


🎨 THEME SYSTEM

The script includes three visual themes:

Emerald Dark

A dark premium style using green and teal accents.

Crimson Pro

A more aggressive dark theme using red and high-contrast signal colors.

Ice Minimal

A cleaner light-style theme with black text and softer blue/grey visual structure.

The theme affects visual elements such as:

- dashboard colors,
- selected model row,
- best-system row,
- TP/SL/Entry line colors,
- TP/SL/Entry labels,
- reward and risk boxes.

The purpose is to make the same system usable across different chart backgrounds and visual preferences.


🎯 ACTIVE TRADE PROJECTION

When the active model produces a new signal, the script can project a visual trade framework.

The chart may display:

- Entry line
- TP1 line
- TP2 line
- TP3 line
- SL line
- reward zone
- risk zone
- price labels next to each level

The projected levels are based on risk multiples.

Default structure:

- TP1 = 1R
- TP2 = 2R
- TP3 = 3R
- SL = 1R risk

The user can adjust TP1, TP2, and TP3 R multiples from settings.

The projected structure is designed for review and visualization. It should not be treated as an instruction to enter a live trade without additional analysis and risk management.


🟢 TP / SL BACKTEST LOGIC

The script’s virtual testing engine is aligned with the TP1 / TP2 / TP3 structure.

If TP3 is reached, the virtual result is recorded using the selected TP3 R multiple.
If SL is reached, the result is recorded as -1R.
If the trade expires before TP3 or SL, the script can use the highest reached TP level or the open R result depending on what happened.

This creates a more consistent link between what appears visually on the chart and what the dashboard is evaluating.

Same-bar TP/SL behavior is handled by a conservative option. If both TP and SL appear to be hit during the same candle, the user can choose to count that situation conservatively.


🔁 NO CONSECUTIVE SAME-DIRECTION SIGNALS

The script includes a same-direction signal filter.

If a model produces a long signal, it will not keep printing long signals repeatedly until an opposite short signal occurs.

Likewise, if a model produces a short signal, it will not keep printing short signals repeatedly until an opposite long signal occurs.

This helps reduce repeated label clutter and makes the signal stream easier to review.


🚨 PRO ALERT SYSTEM

The script includes dynamic alert messages.

The alert message can include:

- signal side,
- active model,
- preset mode,
- quality score,
- market regime,
- alignment,
- entry price,
- TP1,
- TP2,
- TP3,
- SL,
- active model WR,
- active model PF,
- active model Avg R,
- active model Net R.

The script supports Text and JSON-style alert formats.

Important usage note:

To use the full dynamic Pro Alert message, create the TradingView alert with:

Condition: Liquidity Intelligence System
Option: Any alert() function call

The regular alertcondition messages are fallback static alerts.


🧭 WHAT APPEARS ON THE CHART

Depending on settings, the script may display:

- LONG / SHORT labels,
- BSL liquidity lines,
- SSL liquidity lines,
- EQH liquidity lines,
- EQL liquidity lines,
- SWEPT liquidity labels,
- Entry line,
- TP1 line,
- TP2 line,
- TP3 line,
- SL line,
- reward area box,
- risk area box,
- price labels beside Entry / TP / SL,
- main model dashboard,
- Signal Quality dashboard.

This design is intentional.

The chart shows liquidity structure, active model signals, projected risk/reward, and review statistics in one organized view.


🧪 HOW TO USE THE SCRIPT

A practical workflow:

1. Add the script to your chart.
2. Start with the default Intraday preset.
3. Choose a theme that fits your chart background.
4. Select the active model you want to display.
5. Review the liquidity map: BSL, SSL, EQH, and EQL.
6. Wait for a liquidity sweep signal from the active model.
7. Check the Signal Quality panel.
8. Check the market regime and alignment state.
9. Review the Entry / TP1 / TP2 / TP3 / SL projection.
10. Compare the active model to the other models in the dashboard.
11. Use alerts if you want to monitor signals automatically.
12. Validate settings across the specific instruments and timeframes you actually trade.

The script is best used as a structured review framework, not as a blind execution system.


⚙️ SETTINGS REFERENCE

Manual Model Selection

- Active Signal Model: selects which of the 16 models appears on the chart.
- Preset Mode: selects the effective behavior profile.
- Show Active Model Labels: enables/disables signal labels.
- Signal Label Style: controls how much information appears in signal labels.
- LONG / SHORT Label Size: controls signal label size.

Virtual Trade Test

- ATR Length: ATR basis for risk calculations.
- Virtual TP ATR Multiplier: used in manual/preset logic where applicable.
- Virtual SL ATR Multiplier: used to define risk distance.
- TP1 R Multiple: first target multiple.
- TP2 R Multiple: second target multiple.
- TP3 R Multiple: third target multiple.
- Max Bars In Virtual Trade: maximum duration of virtual trade.
- If TP and SL Hit Same Candle, Count As Loss: conservative same-bar handling.

Liquidity Sweep

- Swing Pivot Length: pivot sensitivity.
- Max Sweep Depth ATR: maximum allowed sweep depth.
- Minimum Rejection Wick Ratio: wick rejection requirement.
- Show BSL / SSL Liquidity Lines: enables liquidity map.
- Show Equal High / Equal Low Lines: enables EQH/EQL.
- Liquidity Line Limit: maximum active liquidity lines.
- Liquidity Map Quality: controls how selective the liquidity map is.
- Equal High / Low Tolerance ATR: ATR-scaled equality tolerance.

Confirmation Filters

- Fast EMA Length: trend filter fast EMA.
- Slow EMA Length: trend filter slow EMA.
- EMA Source: source used for EMA calculations.
- Minimum FVG Size ATR: minimum FVG size filter.
- FVG Recent Bars: how recently FVG must have appeared.
- Volume SMA Length: volume baseline.
- Volume Spike Multiplier: volume expansion threshold.
- RSI Length: RSI calculation length.
- RSI Long Threshold: RSI condition for long models.
- RSI Short Threshold: RSI condition for short models.
- Minimum Displacement Body ATR: minimum displacement body size.
- Minimum Displacement Body Ratio: minimum body-to-range ratio.

Market Regime & Quality

- Show Signal Quality Table: enables/disables quality panel.
- Regime ADX Length: directional movement calculation length.
- Trend ADX Threshold: trend-strength threshold.
- Range ADX Threshold: range-condition threshold.
- Regime ATR Average Length: ATR baseline for volatility regime.
- High Volatility ATR Multiplier: high-volatility threshold.
- Low Volatility ATR Multiplier: low-volatility threshold.
- Choppy Body Ratio Threshold: body-ratio condition for choppy regimes.

Dashboard & Visuals

- Show Model Dashboard: enables/disables model comparison dashboard.
- Theme: selects Emerald Dark, Crimson Pro, or Ice Minimal.
- Dashboard Size: controls dashboard text size.
- BEST System Metric: selects best-system ranking logic.
- Minimum Trades For BEST Row: minimum sample size for best-system qualification.

Pro Alerts

- Enable Pro Alert Message: enables dynamic alert messages.
- Alert Message Format: selects Text or JSON-style format.


🧠 WHAT MAKES THIS SCRIPT ORIGINAL

This script uses familiar components such as swing highs/lows, EMA trend filters, volume comparison, RSI thresholds, ATR, and dashboard statistics.

Those components are not original by themselves.

The originality of this script lies in how those components are organized into a single liquidity-intelligence workflow:

Liquidity map
→ sweep detection
→ 16 model comparison
→ market regime classification
→ model-specific quality scoring
→ TP1/TP2/TP3 projection
→ dashboard review
→ dynamic alert output

This structure allows the script to function as a complete liquidity review environment rather than a simple signal marker.


⚠️ IMPORTANT PRACTICAL NOTES

The script’s behavior depends heavily on settings.

Signal frequency and signal quality may change based on:

- selected active model,
- preset mode,
- pivot length,
- sweep depth,
- rejection requirement,
- FVG recency,
- volume threshold,
- RSI thresholds,
- displacement settings,
- volatility conditions,
- symbol,
- timeframe.

A model that looks cleaner on one instrument may not behave the same way on another.

The dashboard is a virtual review layer. It is useful for comparing model behavior, but it should not be treated as proof of future results.


⚠️ LIMITATIONS AND SHORTCOMINGS

This script has important limitations:

- It does not guarantee profitable signals.
- It does not know future price movement.
- It does not replace risk management.
- It does not execute trades.
- It does not include broker slippage, commissions, spreads, or order-fill uncertainty.
- It uses chart data and bar-based logic.
- Same-bar TP/SL ambiguity is handled by a rule, not by true intrabar reconstruction.
- Liquidity sweeps can fail.
- FVG, trend, volume, RSI, and displacement filters can still produce false signals.
- The dashboard is historical and virtual, not a live brokerage performance report.
- Market regime classification is an analytical approximation, not an absolute truth.
- No confluence model removes all risk or uncertainty.

For these reasons, the script should be used as a structured analysis and review tool, not as a standalone trading system.


👤 WHO THIS SCRIPT MAY BE USEFUL FOR

This script may be useful for traders who:

- study liquidity sweeps,
- use smart-money-style market structure concepts,
- want BSL / SSL / EQH / EQL mapping,
- want multiple confluence models in one tool,
- want a visual TP1 / TP2 / TP3 framework,
- want a signal quality panel,
- want market regime context,
- want model comparison statistics,
- prefer organized chart-based review.

It may be less suitable for users who:

- want a fully automated trading system,
- want guaranteed buy/sell signals,
- do not use liquidity concepts,
- do not want dashboard-based review,
- prefer very minimal charts with no overlays,
- expect one model to work the same way on every market and timeframe.


🛡️ DISCLAIMER

This script is provided for educational and informational purposes only.

It does not constitute financial, investment, or trading advice.

No indicator can guarantee future results. Market conditions change, historical behavior does not ensure future behavior, and every user is responsible for their own analysis, validation, position sizing, and risk management.

Use this script as a structured decision-support and review framework, not as a promise of profitability.

## Source Code

````pine
//@version=6
indicator("Liquidity Intelligence System [trade_w_samet]", shorttitle="Liquidity Intelligence System [trade_w_samet]", overlay=true, max_labels_count=500, max_lines_count=300, max_boxes_count=100)

//============================================================
// LIQUIDITY INTELLIGENCE SYSTEM - V1.0
// Multi-model liquidity intelligence optimizer
// No consecutive same-direction signals per model
// Market Regime Detection
// Bottom-left Signal Quality Score table
// Pro dynamic alert messages
// Preset modes
// Equal High / Equal Low + BSL / SSL Liquidity Map
// Session filter removed
// Active manual model TP/SL/Entry lines
// Background virtual testing for all systems
// Dashboard: Trades, WR, PF, Avg R, Net R
//============================================================

//============================================================
// INPUTS
//============================================================

gCore = "🎛️ 01 - Manual Model Selection"
selectedModelName = input.string("LQ", "🧠 Active Signal Model", options=["LQ", "LQ + Trend", "LQ + FVG", "LQ + Volume", "LQ + RSI", "LQ + Displacement", "LQ + Trend + FVG", "LQ + Trend + Volume", "LQ + Trend + RSI", "LQ + Trend + Displacement", "LQ + FVG + Volume", "LQ + FVG + RSI", "LQ + FVG + Displacement", "LQ + Volume + RSI", "LQ + Trend + FVG + Volume", "LQ + Trend + FVG + Volume + RSI + Displacement"], tooltip="Selects the active confluence model used for chart signals, alerts, and active TP/SL visuals.", group=gCore, display=display.none)
presetMode = input.string("Intraday", "⚙️ Preset Mode", options=["Manual", "Scalping", "Intraday", "Swing", "Conservative", "Aggressive", "Funded Account Safe"], tooltip="Applies ready-made parameter behavior for different trading styles. Manual keeps your custom values.", group=gCore, display=display.none)
showActiveLabels = input.bool(true, "🏷️ Show Active Model Labels", tooltip="Shows LONG / SHORT labels on the chart when the selected active model produces a new signal.", group=gCore, display=display.none)
labelStyle = input.string("Compact", "✍️ Signal Label Style", options=["Ultra Minimal", "Compact", "Detailed"], tooltip="Controls how much information is displayed inside signal labels. Detailed mode includes model statistics.", group=gCore, display=display.none)
activeLabelSize = input.string("Small", "🔠 LONG / SHORT Label Size", options=["Tiny", "Small", "Normal", "Large"], tooltip="Controls the chart label size for active model LONG and SHORT signals.", group=gCore, display=display.none)

gTrade = "📊 02 - Virtual Trade Test"
atrLen = input.int(14, "📏 ATR Length", minval=1, tooltip="ATR length used to calculate virtual SL distance and TP projections.", group=gTrade, display=display.none)
tpAtr = input.float(4.00, "🎯 Virtual TP ATR Multiplier", minval=0.10, step=0.05, tooltip="Manual preset TP distance multiplier based on ATR. Used only when Preset Mode is Manual.", group=gTrade, display=display.none)
slAtr = input.float(2.00, "🛡️ Virtual SL ATR Multiplier", minval=0.10, step=0.05, tooltip="Manual preset SL distance multiplier based on ATR. Used only when Preset Mode is Manual.", group=gTrade, display=display.none)
tp1R = input.float(1.00, "🥉 TP1 R Multiple", minval=0.10, maxval=20.00, step=0.10, tooltip="First take-profit level measured as an R multiple from the entry and SL distance.", group=gTrade, display=display.none)
tp2R = input.float(2.00, "🥈 TP2 R Multiple", minval=0.10, maxval=20.00, step=0.10, tooltip="Second take-profit level measured as an R multiple from the entry and SL distance.", group=gTrade, display=display.none)
tp3R = input.float(3.00, "🥇 TP3 R Multiple", minval=0.10, maxval=20.00, step=0.10, tooltip="Final take-profit level measured as an R multiple from the entry and SL distance.", group=gTrade, display=display.none)
maxBarsInTrade = input.int(20, "⏱️ Max Bars In Virtual Trade", minval=1, maxval=300, tooltip="Maximum number of bars a virtual trade can remain active before it is closed by time expiration.", group=gTrade, display=display.none)
conservativeBothHit = input.bool(true, "⚠️ Same Candle TP/SL = Loss", tooltip="When TP and SL are touched on the same candle, the test counts it as a loss for conservative backtesting behavior.", group=gTrade, display=display.none)

gLiquidity = "💧 03 - Liquidity Sweep"
pivotLen = input.int(5, "🌀 Swing Pivot Length", minval=2, maxval=30, tooltip="Pivot length used to detect swing highs and swing lows for liquidity sweep logic.", group=gLiquidity, display=display.none)
maxSweepDepthAtr = input.float(0.80, "🌊 Max Sweep Depth ATR", minval=0.05, step=0.05, tooltip="Maximum allowed sweep depth measured in ATR. Lower values make sweep detection more selective.", group=gLiquidity, display=display.none)
minRejectionRatio = input.float(0.20, "🕯️ Minimum Rejection Wick Ratio", minval=0.05, maxval=0.90, step=0.05, tooltip="Minimum wick rejection ratio required after sweeping liquidity.", group=gLiquidity, display=display.none)
showLiquidityMap = input.bool(true, "🗺️ Show BSL / SSL Liquidity Lines", tooltip="Shows mapped buy-side and sell-side liquidity levels from confirmed swing pivots.", group=gLiquidity, display=display.none)
showEqualHighLow = input.bool(true, "⚖️ Show Equal High / Equal Low Lines", tooltip="Shows equal high and equal low liquidity levels when two swing levels are close enough.", group=gLiquidity, display=display.none)
liquidityLineLimit = input.int(15, "📌 Liquidity Line Limit", minval=5, maxval=100, tooltip="Maximum number of liquidity map lines kept on the chart.", group=gLiquidity, display=display.none)
liquidityMapQuality = input.string("Conservative", "💎 Liquidity Map Quality", options=["Balanced", "Conservative", "Strict"], tooltip="Controls how selective the liquidity map is. Strict keeps fewer, higher-quality levels.", group=gLiquidity, display=display.none)
equalToleranceAtr = input.float(0.08, "🎚️ Equal High / Low Tolerance ATR", minval=0.01, maxval=1.00, step=0.01, tooltip="ATR-based tolerance used to decide whether two swing levels are equal highs or equal lows.", group=gLiquidity, display=display.none)

gFilters = "🧩 04 - Confirmation Filters"
emaFastLen = input.int(50, "⚡ Fast EMA Length", minval=1, tooltip="Fast EMA length used for trend confirmation filters.", group=gFilters, display=display.none)
emaSlowLen = input.int(200, "🐢 Slow EMA Length", minval=2, tooltip="Slow EMA length used for trend confirmation filters.", group=gFilters, display=display.none)
emaSource = input.source(close, "📍 EMA Source", tooltip="Price source used for EMA calculations.", group=gFilters, display=display.none)
fvgAtrMin = input.float(0.05, "📐 Minimum FVG Size ATR", minval=0.00, step=0.01, tooltip="Minimum FVG size measured in ATR. Higher values require larger imbalance zones.", group=gFilters, display=display.none)
fvgRecentBars = input.int(6, "🕒 FVG Recent Bars", minval=1, maxval=50, tooltip="Maximum number of bars after an FVG for it to count as recent confirmation.", group=gFilters, display=display.none)
volLen = input.int(20, "🔊 Volume SMA Length", minval=1, tooltip="SMA length used to calculate the average volume baseline.", group=gFilters, display=display.none)
volMult = input.float(1.30, "📢 Volume Spike Multiplier", minval=0.10, step=0.05, tooltip="Required volume spike multiplier above the volume SMA.", group=gFilters, display=display.none)
rsiLen = input.int(14, "💪 RSI Length", minval=2, tooltip="RSI length used by RSI-based confluence models.", group=gFilters, display=display.none)
rsiOS = input.float(35, "🟢 RSI Long Threshold", minval=1, maxval=50, step=1, tooltip="RSI threshold used as long-side confirmation.", group=gFilters, display=display.none)
rsiOB = input.float(65, "🔴 RSI Short Threshold", minval=50, maxval=99, step=1, tooltip="RSI threshold used as short-side confirmation.", group=gFilters, display=display.none)
dispAtrMin = input.float(0.20, "🚀 Minimum Displacement Body ATR", minval=0.00, step=0.05, tooltip="Minimum candle body size measured in ATR for displacement confirmation.", group=gFilters, display=display.none)
dispBodyRatioMin = input.float(0.50, "📊 Minimum Displacement Body Ratio", minval=0.10, maxval=1.00, step=0.05, tooltip="Minimum body-to-range ratio required for displacement confirmation.", group=gFilters, display=display.none)

gRegime = "🧠 05 - Market Regime & Quality"
showQualityTable = input.bool(true, "📋 Show Signal Quality Table", tooltip="Shows the compact signal quality table with regime, bias, last signal, score, and alignment.", group=gRegime, display=display.none)
adxLen = input.int(14, "📈 Regime ADX Length", minval=2, maxval=100, tooltip="ADX length used for trend/range/chop regime detection.", group=gRegime, display=display.none)
adxTrendMin = input.float(20.0, "📈 Trend ADX Threshold", minval=1.0, maxval=60.0, step=0.5, tooltip="ADX value required to classify the market as trending.", group=gRegime, display=display.none)
adxRangeMax = input.float(16.0, "↔️ Range ADX Threshold", minval=1.0, maxval=40.0, step=0.5, tooltip="ADX value below this level may classify the market as ranging.", group=gRegime, display=display.none)
atrRegimeLen = input.int(50, "🌡️ Regime ATR Average Length", minval=5, maxval=300, tooltip="ATR average length used to detect high and low volatility regimes.", group=gRegime, display=display.none)
highVolMult = input.float(1.25, "🔥 High Volatility ATR Multiplier", minval=0.50, maxval=5.00, step=0.05, tooltip="ATR multiplier used to classify high volatility environments.", group=gRegime, display=display.none)
lowVolMult = input.float(0.75, "🧊 Low Volatility ATR Multiplier", minval=0.10, maxval=2.00, step=0.05, tooltip="ATR multiplier used to classify low volatility environments.", group=gRegime, display=display.none)
chopBodyMax = input.float(0.35, "🪓 Choppy Body Ratio Threshold", minval=0.05, maxval=0.90, step=0.05, tooltip="Average body ratio threshold used to detect choppy market conditions.", group=gRegime, display=display.none)

gVisual = "📈 06 - Dashboard And Visuals"
showDashboard = input.bool(true, "📊 Show Model Dashboard", tooltip="Shows the multi-model performance dashboard in the top-right corner.", group=gVisual, display=display.none)
themeMode = input.string("Emerald Dark", "🎨 Theme", options=["Emerald Dark", "Crimson Pro", "Ice Minimal"], tooltip="Changes dashboard, label, and visual color theme.", group=gVisual, display=display.none)
dashboardSize = input.string("Medium", "🔎 Dashboard Size", options=["Small", "Medium", "Large"], tooltip="Controls the text size of the dashboard and quality table.", group=gVisual, display=display.none)
bestMetric = input.string("Net R", "🏆 BEST System Metric", options=["Net R", "Profit Factor", "Average R", "Win Rate"], tooltip="Metric used to select the BEST row in the model dashboard.", group=gVisual, display=display.none)
minBestTrades = input.int(25, "✅ Minimum Trades For BEST Row", minval=1, maxval=1000, tooltip="Minimum number of virtual trades required before a model can be selected as BEST.", group=gVisual, display=display.none)
showHistoricalTradeBoxes = input.bool(true, "📦 Show Historical TP/SL Boxes", tooltip="Keeps completed Entry / TP / SL lines and TP/SL boxes visible after TP3 or SL is reached. Enabled by default.", group=gVisual, display=display.none)
historicalTradeLimit = input.int(20, "🧱 Historical Trade Visual Limit", minval=1, maxval=35, tooltip="Maximum number of completed/previous trade visual sets kept on the chart to protect TradingView object limits.", group=gVisual, display=display.none)

gAlert = "🚨 07 - Pro Alerts"
enableProAlerts = input.bool(true, "🔔 Enable Pro Alert Message", tooltip="Enables dynamic alert() messages for selected active model signals.", group=gAlert, display=display.none)
alertMessageFormat = input.string("Text", "🧾 Alert Message Format", options=["Text", "JSON"], tooltip="Selects whether dynamic pro alerts are sent as readable text or compact JSON-like format.", group=gAlert, display=display.none)

//============================================================
// PRESET EFFECTIVE VALUES
//============================================================

tpAtrEff = presetMode == "Manual" ? tpAtr : presetMode == "Scalping" ? 2.00 : presetMode == "Intraday" ? 3.00 : presetMode == "Swing" ? 5.00 : presetMode == "Conservative" ? 3.00 : presetMode == "Aggressive" ? 2.50 : 3.00
slAtrEff = presetMode == "Manual" ? slAtr : presetMode == "Scalping" ? 1.00 : presetMode == "Intraday" ? 1.50 : presetMode == "Swing" ? 2.50 : presetMode == "Conservative" ? 1.75 : presetMode == "Aggressive" ? 1.00 : 1.50
maxBarsInTradeEff = presetMode == "Manual" ? maxBarsInTrade : presetMode == "Scalping" ? 12 : presetMode == "Intraday" ? 30 : presetMode == "Swing" ? 80 : presetMode == "Conservative" ? 25 : presetMode == "Aggressive" ? 15 : 25
maxSweepDepthAtrEff = presetMode == "Manual" ? maxSweepDepthAtr : presetMode == "Scalping" ? 0.55 : presetMode == "Intraday" ? 0.75 : presetMode == "Swing" ? 1.20 : presetMode == "Conservative" ? 0.55 : presetMode == "Aggressive" ? 1.00 : 0.65
minRejectionRatioEff = presetMode == "Manual" ? minRejectionRatio : presetMode == "Scalping" ? 0.25 : presetMode == "Intraday" ? 0.20 : presetMode == "Swing" ? 0.15 : presetMode == "Conservative" ? 0.30 : presetMode == "Aggressive" ? 0.12 : 0.25
fvgRecentBarsEff = presetMode == "Manual" ? fvgRecentBars : presetMode == "Scalping" ? 4 : presetMode == "Intraday" ? 8 : presetMode == "Swing" ? 15 : presetMode == "Conservative" ? 5 : presetMode == "Aggressive" ? 10 : 6
volMultEff = presetMode == "Manual" ? volMult : presetMode == "Scalping" ? 1.25 : presetMode == "Intraday" ? 1.30 : presetMode == "Swing" ? 1.15 : presetMode == "Conservative" ? 1.45 : presetMode == "Aggressive" ? 1.10 : 1.35
dispAtrMinEff = presetMode == "Manual" ? dispAtrMin : presetMode == "Scalping" ? 0.18 : presetMode == "Intraday" ? 0.22 : presetMode == "Swing" ? 0.30 : presetMode == "Conservative" ? 0.28 : presetMode == "Aggressive" ? 0.12 : 0.24
dispBodyRatioMinEff = presetMode == "Manual" ? dispBodyRatioMin : presetMode == "Scalping" ? 0.50 : presetMode == "Intraday" ? 0.50 : presetMode == "Swing" ? 0.45 : presetMode == "Conservative" ? 0.60 : presetMode == "Aggressive" ? 0.40 : 0.55

//============================================================
// THEME ENGINE
//============================================================

themeBg = themeMode == "Emerald Dark" ? color.new(color.rgb(6, 12, 14), 10) : themeMode == "Crimson Pro" ? color.new(color.rgb(15, 8, 10), 10) : color.new(color.rgb(235, 242, 245), 8)
themeRowBg = themeMode == "Emerald Dark" ? color.new(color.black, 65) : themeMode == "Crimson Pro" ? color.new(color.rgb(18, 10, 12), 58) : color.new(color.white, 8)
themeHeaderBg = themeMode == "Emerald Dark" ? color.new(color.black, 0) : themeMode == "Crimson Pro" ? color.new(color.rgb(70, 0, 10), 0) : color.new(color.rgb(210, 225, 235), 0)
themeSelectedBg = themeMode == "Emerald Dark" ? color.new(color.teal, 25) : themeMode == "Crimson Pro" ? color.new(color.red, 25) : color.new(color.rgb(70, 130, 180), 20)
themeBestBg = themeMode == "Emerald Dark" ? color.new(color.orange, 20) : themeMode == "Crimson Pro" ? color.new(color.rgb(255, 85, 60), 15) : color.new(color.rgb(255, 200, 80), 10)
themeBestHeaderBg = themeMode == "Emerald Dark" ? color.new(color.orange, 0) : themeMode == "Crimson Pro" ? color.new(color.rgb(255, 60, 45), 0) : color.new(color.rgb(255, 190, 60), 0)
themeText = themeMode == "Ice Minimal" ? color.black : color.white
themeMutedText = themeMode == "Ice Minimal" ? color.rgb(25, 25, 25) : color.white
themeLong = themeMode == "Crimson Pro" ? color.rgb(0, 255, 140) : themeMode == "Ice Minimal" ? color.rgb(0, 150, 95) : color.rgb(0, 255, 80)
themeShort = themeMode == "Crimson Pro" ? color.rgb(255, 25, 60) : themeMode == "Ice Minimal" ? color.rgb(220, 35, 35) : color.rgb(255, 35, 35)
themeEntry = color.white
themeLabelText = color.black

f_boldItalicText(string _txt) =>
    string s = _txt
    s := str.replace_all(s, "A", "𝑨")
    s := str.replace_all(s, "B", "𝑩")
    s := str.replace_all(s, "C", "𝑪")
    s := str.replace_all(s, "D", "𝑫")
    s := str.replace_all(s, "E", "𝑬")
    s := str.replace_all(s, "F", "𝑭")
    s := str.replace_all(s, "G", "𝑮")
    s := str.replace_all(s, "H", "𝑯")
    s := str.replace_all(s, "I", "𝑰")
    s := str.replace_all(s, "J", "𝑱")
    s := str.replace_all(s, "K", "𝑲")
    s := str.replace_all(s, "L", "𝑳")
    s := str.replace_all(s, "M", "𝑴")
    s := str.replace_all(s, "N", "𝑵")
    s := str.replace_all(s, "O", "𝑶")
    s := str.replace_all(s, "P", "𝑷")
    s := str.replace_all(s, "Q", "𝑸")
    s := str.replace_all(s, "R", "𝑹")
    s := str.replace_all(s, "S", "𝑺")
    s := str.replace_all(s, "T", "𝑻")
    s := str.replace_all(s, "U", "𝑼")
    s := str.replace_all(s, "V", "𝑽")
    s := str.replace_all(s, "W", "𝑾")
    s := str.replace_all(s, "X", "𝑿")
    s := str.replace_all(s, "Y", "𝒀")
    s := str.replace_all(s, "Z", "𝒁")
    s := str.replace_all(s, "a", "𝒂")
    s := str.replace_all(s, "b", "𝒃")
    s := str.replace_all(s, "c", "𝒄")
    s := str.replace_all(s, "d", "𝒅")
    s := str.replace_all(s, "e", "𝒆")
    s := str.replace_all(s, "f", "𝒇")
    s := str.replace_all(s, "g", "𝒈")
    s := str.replace_all(s, "h", "𝒉")
    s := str.replace_all(s, "i", "𝒊")
    s := str.replace_all(s, "j", "𝒋")
    s := str.replace_all(s, "k", "𝒌")
    s := str.replace_all(s, "l", "𝒍")
    s := str.replace_all(s, "m", "𝒎")
    s := str.replace_all(s, "n", "𝒏")
    s := str.replace_all(s, "o", "𝒐")
    s := str.replace_all(s, "p", "𝒑")
    s := str.replace_all(s, "q", "𝒒")
    s := str.replace_all(s, "r", "𝒓")
    s := str.replace_all(s, "s", "𝒔")
    s := str.replace_all(s, "t", "𝒕")
    s := str.replace_all(s, "u", "𝒖")
    s := str.replace_all(s, "v", "𝒗")
    s := str.replace_all(s, "w", "𝒘")
    s := str.replace_all(s, "x", "𝒙")
    s := str.replace_all(s, "y", "𝒚")
    s := str.replace_all(s, "z", "𝒛")
    s := str.replace_all(s, "0", "𝟎")
    s := str.replace_all(s, "1", "𝟏")
    s := str.replace_all(s, "2", "𝟐")
    s := str.replace_all(s, "3", "𝟑")
    s := str.replace_all(s, "4", "𝟒")
    s := str.replace_all(s, "5", "𝟓")
    s := str.replace_all(s, "6", "𝟔")
    s := str.replace_all(s, "7", "𝟕")
    s := str.replace_all(s, "8", "𝟖")
    s := str.replace_all(s, "9", "𝟗")
    s

//============================================================
// CORE SERIES
//============================================================

atr = ta.atr(atrLen)
emaFast = ta.ema(emaSource, emaFastLen)
emaSlow = ta.ema(emaSource, emaSlowLen)
rsi = ta.rsi(close, rsiLen)
volSma = ta.sma(volume, volLen)

trendLong = emaFast > emaSlow
trendShort = emaFast < emaSlow

volOk = not na(volume) and not na(volSma)
volSpike = volOk and volume > volSma * volMultEff

bullFvg = low > high[2] and (low - high[2]) >= atr * fvgAtrMin
bearFvg = high < low[2] and (low[2] - high) >= atr * fvgAtrMin
bullFvgRecent = nz(ta.barssince(bullFvg), 100000) <= fvgRecentBarsEff
bearFvgRecent = nz(ta.barssince(bearFvg), 100000) <= fvgRecentBarsEff

rsiLong = rsi <= rsiOS
rsiShort = rsi >= rsiOB

//============================================================
// LIQUIDITY SWEEP ENGINE
//============================================================

ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float lastSwingHigh = na
var float lastSwingLow = na
var array<line> liquidityMapLines = array.new_line()
var array<label> liquidityMapLabels = array.new_label()
var array<float> liquidityMapPrices = array.new_float()
var array<bool> liquidityMapIsHigh = array.new_bool()
var array<bool> liquidityMapSwept = array.new_bool()

f_addLiquidityMapLine(float _price, int _bar, string _txt, color _color, bool _isHigh, _style) =>
    if showLiquidityMap
        if array.size(liquidityMapLines) >= liquidityLineLimit
            line oldLine = array.shift(liquidityMapLines)
            if not na(oldLine)
                line.delete(oldLine)
            label oldLabel = array.shift(liquidityMapLabels)
            if not na(oldLabel)
                label.delete(oldLabel)
            array.shift(liquidityMapPrices)
            array.shift(liquidityMapIsHigh)
            array.shift(liquidityMapSwept)
        line newLine = line.new(x1=_bar, y1=_price, x2=bar_index + 1, y2=_price, xloc=xloc.bar_index, extend=extend.right, color=_color, width=_txt == "EQH" or _txt == "EQL" ? 2 : 1, style=_style)
        label newLabel = label.new(x=_bar, y=_price, text=f_boldItalicText(_txt), xloc=xloc.bar_index, yloc=yloc.price, style=_isHigh ? label.style_label_down : label.style_label_up, color=color.new(_color, 75), textcolor=color.white, size=size.tiny, tooltip=_txt + " liquidity level | Price: " + str.tostring(_price, format.mintick))
        array.push(liquidityMapLines, newLine)
        array.push(liquidityMapLabels, newLabel)
        array.push(liquidityMapPrices, _price)
        array.push(liquidityMapIsHigh, _isHigh)
        array.push(liquidityMapSwept, false)
    true

var float lastMappedHigh = na
var float lastMappedLow = na
var int lastMappedHighBar = na
var int lastMappedLowBar = na

equalTolerance = atr * equalToleranceAtr
mapMinDistanceAtr = liquidityMapQuality == "Balanced" ? 0.40 : liquidityMapQuality == "Conservative" ? 0.70 : 1.10
mapMinBars = liquidityMapQuality == "Balanced" ? 8 : liquidityMapQuality == "Conservative" ? 18 : 30
mapMinDistance = atr * mapMinDistanceAtr

if not na(ph)
    int pivotBarHigh = bar_index - pivotLen
    bool isEqualHigh = showEqualHighLow and not na(lastSwingHigh) and math.abs(ph - lastSwingHigh) <= equalTolerance
    bool enoughDistanceHigh = na(lastMappedHigh) or math.abs(ph - lastMappedHigh) >= mapMinDistance
    bool enoughBarsHigh = na(lastMappedHighBar) or pivotBarHigh - lastMappedHighBar >= mapMinBars
    bool qualityHigh = isEqualHigh ? enoughBarsHigh : enoughDistanceHigh and enoughBarsHigh
    if qualityHigh
        f_addLiquidityMapLine(ph, pivotBarHigh, isEqualHigh ? "EQH" : "BSL", isEqualHigh ? color.new(color.orange, 0) : color.new(color.red, 0), true, isEqualHigh ? line.style_solid : line.style_dotted)
        lastMappedHigh := ph
        lastMappedHighBar := pivotBarHigh
    lastSwingHigh := ph

if not na(pl)
    int pivotBarLow = bar_index - pivotLen
    bool isEqualLow = showEqualHighLow and not na(lastSwingLow) and math.abs(pl - lastSwingLow) <= equalTolerance
    bool enoughDistanceLow = na(lastMappedLow) or math.abs(pl - lastMappedLow) >= mapMinDistance
    bool enoughBarsLow = na(lastMappedLowBar) or pivotBarLow - lastMappedLowBar >= mapMinBars
    bool qualityLow = isEqualLow ? enoughBarsLow : enoughDistanceLow and enoughBarsLow
    if qualityLow
        f_addLiquidityMapLine(pl, pivotBarLow, isEqualLow ? "EQL" : "SSL", isEqualLow ? color.new(color.aqua, 0) : color.new(color.lime, 0), false, isEqualLow ? line.style_solid : line.style_dotted)
        lastMappedLow := pl
        lastMappedLowBar := pivotBarLow
    lastSwingLow := pl

if showLiquidityMap and array.size(liquidityMapLines) > 0
    for lm = 0 to array.size(liquidityMapLines) - 1
        bool sweptLine = array.get(liquidityMapSwept, lm)
        float lqPrice = array.get(liquidityMapPrices, lm)
        bool lqIsHigh = array.get(liquidityMapIsHigh, lm)
        bool nowSwept = not sweptLine and (lqIsHigh ? high >= lqPrice : low <= lqPrice)
        if nowSwept
            line lqLine = array.get(liquidityMapLines, lm)
            label lqLabel = array.get(liquidityMapLabels, lm)
            if not na(lqLine)
                line.set_color(lqLine, color.new(color.gray, 20))
                line.set_style(lqLine, line.style_dashed)
                line.set_width(lqLine, 1)
            if not na(lqLabel)
                label.set_text(lqLabel, f_boldItalicText("SWEPT"))
                label.set_color(lqLabel, color.new(color.gray, 55))
                label.set_textcolor(lqLabel, color.white)
            array.set(liquidityMapSwept, lm, true)

candleRange = math.max(high - low, syminfo.mintick)
bodySize = math.abs(close - open)
bodyRatio = bodySize / candleRange
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
upperRejection = math.max(upperWick, 0.0) / candleRange
lowerRejection = math.max(lowerWick, 0.0) / candleRange

bullDisplacement = close > open and bodySize >= atr * dispAtrMinEff and bodyRatio >= dispBodyRatioMinEff
bearDisplacement = close < open and bodySize >= atr * dispAtrMinEff and bodyRatio >= dispBodyRatioMinEff

//============================================================
// MARKET REGIME DETECTION
//============================================================

upMove = high - high[1]
downMove = low[1] - low
plusDM = upMove > downMove and upMove > 0 ? upMove : 0.0
minusDM = downMove > upMove and downMove > 0 ? downMove : 0.0
trValue = ta.tr(true)
trRma = ta.rma(trValue, adxLen)
plusDI = trRma > 0 ? 100.0 * ta.rma(plusDM, adxLen) / trRma : 0.0
minusDI = trRma > 0 ? 100.0 * ta.rma(minusDM, adxLen) / trRma : 0.0
dxValue = plusDI + minusDI > 0 ? 100.0 * math.abs(plusDI - minusDI) / (plusDI + minusDI) : 0.0
adxValue = ta.rma(dxValue, adxLen)
atrRegimeAvg = ta.sma(atr, atrRegimeLen)
avgBodyRatio = ta.sma(bodyRatio, 20)
highVolRegime = not na(atrRegimeAvg) and atr > atrRegimeAvg * highVolMult
lowVolRegime = not na(atrRegimeAvg) and atr < atrRegimeAvg * lowVolMult
regimeTrendUp = adxValue >= adxTrendMin and trendLong and plusDI > minusDI
regimeTrendDown = adxValue >= adxTrendMin and trendShort and minusDI > plusDI
regimeRange = adxValue <= adxRangeMax and not highVolRegime
regimeChoppy = not regimeTrendUp and not regimeTrendDown and avgBodyRatio <= chopBodyMax and not highVolRegime
regimeName = regimeTrendUp ? "Trend Up" : regimeTrendDown ? "Trend Down" : regimeChoppy ? "Choppy" : highVolRegime ? "High Vol" : lowVolRegime ? "Low Vol" : regimeRange ? "Range" : "Neutral"
regimeBias = regimeTrendUp ? "LONG Bias" : regimeTrendDown ? "SHORT Bias" : regimeRange ? "Mean Reversion" : regimeChoppy ? "Avoid / Wait" : highVolRegime ? "Aggressive" : lowVolRegime ? "Patience" : "Neutral"

buySideDepth = not na(lastSwingHigh) ? high - lastSwingHigh : na
sellSideDepth = not na(lastSwingLow) ? lastSwingLow - low : na

buySideDepthAtr = not na(buySideDepth) and atr > 0 ? buySideDepth / atr : na
sellSideDepthAtr = not na(sellSideDepth) and atr > 0 ? sellSideDepth / atr : na

buySideSweep = not na(lastSwingHigh) and not na(buySideDepthAtr) and high > lastSwingHigh and close < lastSwingHigh and buySideDepthAtr <= maxSweepDepthAtrEff and upperRejection >= minRejectionRatioEff
sellSideSweep = not na(lastSwingLow) and not na(sellSideDepthAtr) and low < lastSwingLow and close > lastSwingLow and sellSideDepthAtr <= maxSweepDepthAtrEff and lowerRejection >= minRejectionRatioEff

baseLong = sellSideSweep
baseShort = buySideSweep

regimeLongBonus = regimeTrendUp ? 15.0 : regimeTrendDown ? -15.0 : regimeRange ? 5.0 : regimeChoppy ? -10.0 : highVolRegime ? 5.0 : 0.0
regimeShortBonus = regimeTrendDown ? 15.0 : regimeTrendUp ? -15.0 : regimeRange ? 5.0 : regimeChoppy ? -10.0 : highVolRegime ? 5.0 : 0.0
qualityLongRaw = (baseLong ? 20.0 : 0.0) + (trendLong ? 15.0 : 0.0) + (bullFvgRecent ? 15.0 : 0.0) + (volSpike ? 10.0 : 0.0) + (rsiLong ? 10.0 : 0.0) + (bullDisplacement ? 15.0 : 0.0) + regimeLongBonus
qualityShortRaw = (baseShort ? 20.0 : 0.0) + (trendShort ? 15.0 : 0.0) + (bearFvgRecent ? 15.0 : 0.0) + (volSpike ? 10.0 : 0.0) + (rsiShort ? 10.0 : 0.0) + (bearDisplacement ? 15.0 : 0.0) + regimeShortBonus
qualityScoreLong = math.max(0.0, math.min(100.0, qualityLongRaw))
qualityScoreShort = math.max(0.0, math.min(100.0, qualityShortRaw))
qualityAlignLong = regimeTrendUp ? "Aligned" : regimeTrendDown ? "Against" : regimeChoppy ? "Avoid" : "Neutral"
qualityAlignShort = regimeTrendDown ? "Aligned" : regimeTrendUp ? "Against" : regimeChoppy ? "Avoid" : "Neutral"

//============================================================
// MODEL FUNCTIONS
//============================================================

modelName(int _m) =>
    _m == 0 ? "LQ" :
     _m == 1 ? "LQ + Trend" :
     _m == 2 ? "LQ + FVG" :
     _m == 3 ? "LQ + Volume" :
     _m == 4 ? "LQ + RSI" :
     _m == 5 ? "LQ + Displacement" :
     _m == 6 ? "LQ + Trend + FVG" :
     _m == 7 ? "LQ + Trend + Volume" :
     _m == 8 ? "LQ + Trend + RSI" :
     _m == 9 ? "LQ + Trend + Displacement" :
     _m == 10 ? "LQ + FVG + Volume" :
     _m == 11 ? "LQ + FVG + RSI" :
     _m == 12 ? "LQ + FVG + Displacement" :
     _m == 13 ? "LQ + Volume + RSI" :
     _m == 14 ? "LQ + Trend + FVG + Volume" :
     "LQ + Trend + FVG + Volume + RSI + Displacement"

modelIndex(string _name) =>
    _name == "LQ" ? 0 :
     _name == "LQ + Trend" ? 1 :
     _name == "LQ + FVG" ? 2 :
     _name == "LQ + Volume" ? 3 :
     _name == "LQ + RSI" ? 4 :
     _name == "LQ + Displacement" ? 5 :
     _name == "LQ + Trend + FVG" ? 6 :
     _name == "LQ + Trend + Volume" ? 7 :
     _name == "LQ + Trend + RSI" ? 8 :
     _name == "LQ + Trend + Displacement" ? 9 :
     _name == "LQ + FVG + Volume" ? 10 :
     _name == "LQ + FVG + RSI" ? 11 :
     _name == "LQ + FVG + Displacement" ? 12 :
     _name == "LQ + Volume + RSI" ? 13 :
     _name == "LQ + Trend + FVG + Volume" ? 14 :
     15

modelLong(int _m) =>
    _m == 0 ? baseLong :
     _m == 1 ? baseLong and trendLong :
     _m == 2 ? baseLong and bullFvgRecent :
     _m == 3 ? baseLong and volSpike :
     _m == 4 ? baseLong and rsiLong :
     _m == 5 ? baseLong and bullDisplacement :
     _m == 6 ? baseLong and trendLong and bullFvgRecent :
     _m == 7 ? baseLong and trendLong and volSpike :
     _m == 8 ? baseLong and trendLong and rsiLong :
     _m == 9 ? baseLong and trendLong and bullDisplacement :
     _m == 10 ? baseLong and bullFvgRecent and volSpike :
     _m == 11 ? baseLong and bullFvgRecent and rsiLong :
     _m == 12 ? baseLong and bullFvgRecent and bullDisplacement :
     _m == 13 ? baseLong and volSpike and rsiLong :
     _m == 14 ? baseLong and trendLong and bullFvgRecent and volSpike :
     baseLong and trendLong and bullFvgRecent and volSpike and rsiLong and bullDisplacement

modelShort(int _m) =>
    _m == 0 ? baseShort :
     _m == 1 ? baseShort and trendShort :
     _m == 2 ? baseShort and bearFvgRecent :
     _m == 3 ? baseShort and volSpike :
     _m == 4 ? baseShort and rsiShort :
     _m == 5 ? baseShort and bearDisplacement :
     _m == 6 ? baseShort and trendShort and bearFvgRecent :
     _m == 7 ? baseShort and trendShort and volSpike :
     _m == 8 ? baseShort and trendShort and rsiShort :
     _m == 9 ? baseShort and trendShort and bearDisplacement :
     _m == 10 ? baseShort and bearFvgRecent and volSpike :
     _m == 11 ? baseShort and bearFvgRecent and rsiShort :
     _m == 12 ? baseShort and bearFvgRecent and bearDisplacement :
     _m == 13 ? baseShort and volSpike and rsiShort :
     _m == 14 ? baseShort and trendShort and bearFvgRecent and volSpike :
     baseShort and trendShort and bearFvgRecent and volSpike and rsiShort and bearDisplacement

selectedModel = modelIndex(selectedModelName)

modelUsesTrend(int _m) =>
    _m == 1 or _m == 6 or _m == 7 or _m == 8 or _m == 9 or _m == 14 or _m == 15

modelUsesFVG(int _m) =>
    _m == 2 or _m == 6 or _m == 10 or _m == 11 or _m == 12 or _m == 14 or _m == 15

modelUsesVolume(int _m) =>
    _m == 3 or _m == 7 or _m == 10 or _m == 13 or _m == 14 or _m == 15

modelUsesRSI(int _m) =>
    _m == 4 or _m == 8 or _m == 11 or _m == 13 or _m == 15

modelUsesDisplacement(int _m) =>
    _m == 5 or _m == 9 or _m == 12 or _m == 15

modelQualityScore(int _m, bool _isLong) =>
    float score = 25.0
    bool trendOk = _isLong ? trendLong : trendShort
    bool fvgOk = _isLong ? bullFvgRecent : bearFvgRecent
    bool rsiOk = _isLong ? rsiLong : rsiShort
    bool dispOk = _isLong ? bullDisplacement : bearDisplacement
    float regimeBonus = _isLong ? regimeLongBonus : regimeShortBonus
    score += modelUsesTrend(_m) ? (trendOk ? 15.0 : -10.0) : 0.0
    score += modelUsesFVG(_m) ? (fvgOk ? 15.0 : -10.0) : 0.0
    score += modelUsesVolume(_m) ? (volSpike ? 10.0 : -6.0) : 0.0
    score += modelUsesRSI(_m) ? (rsiOk ? 10.0 : -5.0) : 0.0
    score += modelUsesDisplacement(_m) ? (dispOk ? 15.0 : -10.0) : 0.0
    score += regimeBonus
    math.max(0.0, math.min(100.0, score))

//============================================================
// PERFORMANCE STORAGE
//============================================================

var int[] totalTrades = array.new_int(16, 0)
var int[] totalWins = array.new_int(16, 0)
var float[] grossProfitR = array.new_float(16, 0.0)
var float[] grossLossR = array.new_float(16, 0.0)
var float[] netR = array.new_float(16, 0.0)

recordOutcome(int _model, float _r) =>
    int oldTrades = array.get(totalTrades, _model)
    int oldWins = array.get(totalWins, _model)
    float oldGP = array.get(grossProfitR, _model)
    float oldGL = array.get(grossLossR, _model)
    float oldNet = array.get(netR, _model)
    array.set(totalTrades, _model, oldTrades + 1)
    array.set(totalWins, _model, oldWins + (_r > 0 ? 1 : 0))
    array.set(grossProfitR, _model, oldGP + (_r > 0 ? _r : 0.0))
    array.set(grossLossR, _model, oldGL + (_r < 0 ? math.abs(_r) : 0.0))
    array.set(netR, _model, oldNet + _r)
    true

getTrades(int _m) =>
    array.get(totalTrades, _m)

getWins(int _m) =>
    array.get(totalWins, _m)

getNetR(int _m) =>
    array.get(netR, _m)

getWinRate(int _m) =>
    getTrades(_m) > 0 ? float(getWins(_m)) / float(getTrades(_m)) * 100.0 : na

getAvgR(int _m) =>
    getTrades(_m) > 0 ? getNetR(_m) / float(getTrades(_m)) : na

getProfitFactor(int _m) =>
    array.get(grossLossR, _m) > 0 ? array.get(grossProfitR, _m) / array.get(grossLossR, _m) : array.get(grossProfitR, _m) > 0 ? 999.0 : na

getMetricValue(int _m) =>
    bestMetric == "Net R" ? getNetR(_m) :
     bestMetric == "Profit Factor" ? getProfitFactor(_m) :
     bestMetric == "Average R" ? getAvgR(_m) :
     getWinRate(_m)

//============================================================
// VIRTUAL TRADE STATE
//============================================================

var bool[] inTrade = array.new_bool(16, false)
var int[] tradeDir = array.new_int(16, 0)
var float[] tradeEntry = array.new_float(16, na)
var float[] tradeTP1 = array.new_float(16, na)
var float[] tradeTP2 = array.new_float(16, na)
var float[] tradeTP3 = array.new_float(16, na)
var float[] tradeSL = array.new_float(16, na)
var float[] tradeRisk = array.new_float(16, na)
var float[] tradeMaxRReached = array.new_float(16, 0.0)
var int[] tradeBar = array.new_int(16, 0)
var int[] lastSignalDir = array.new_int(16, 0)

openTrade(int _model, int _dir) =>
    float e = close
    float risk = math.max(atr * slAtrEff, syminfo.mintick)
    float tp1 = _dir == 1 ? e + risk * tp1R : e - risk * tp1R
    float tp2 = _dir == 1 ? e + risk * tp2R : e - risk * tp2R
    float tp3 = _dir == 1 ? e + risk * tp3R : e - risk * tp3R
    float sl = _dir == 1 ? e - risk : e + risk
    array.set(inTrade, _model, true)
    array.set(tradeDir, _model, _dir)
    array.set(tradeEntry, _model, e)
    array.set(tradeTP1, _model, tp1)
    array.set(tradeTP2, _model, tp2)
    array.set(tradeTP3, _model, tp3)
    array.set(tradeSL, _model, sl)
    array.set(tradeRisk, _model, risk)
    array.set(tradeMaxRReached, _model, 0.0)
    array.set(tradeBar, _model, bar_index)
    true

closeTrade(int _model, float _r) =>
    recordOutcome(_model, _r)
    array.set(inTrade, _model, false)
    array.set(tradeDir, _model, 0)
    array.set(tradeEntry, _model, na)
    array.set(tradeTP1, _model, na)
    array.set(tradeTP2, _model, na)
    array.set(tradeTP3, _model, na)
    array.set(tradeSL, _model, na)
    array.set(tradeRisk, _model, na)
    array.set(tradeMaxRReached, _model, 0.0)
    array.set(tradeBar, _model, 0)
    true

//============================================================
// VIRTUAL TRADE EVALUATION
//============================================================

var bool activeVisualTrade = false

for m = 0 to 15
    if array.get(inTrade, m)
        int d = array.get(tradeDir, m)
        float e = array.get(tradeEntry, m)
        float tp1 = array.get(tradeTP1, m)
        float tp2 = array.get(tradeTP2, m)
        float tp3 = array.get(tradeTP3, m)
        float sl = array.get(tradeSL, m)
        float risk = array.get(tradeRisk, m)
        int eb = array.get(tradeBar, m)
        bool hitTP1 = d == 1 ? high >= tp1 : low <= tp1
        bool hitTP2 = d == 1 ? high >= tp2 : low <= tp2
        bool hitTP3 = d == 1 ? high >= tp3 : low <= tp3
        bool hitSL = d == 1 ? low <= sl : high >= sl
        bool selectedVisualStillActive = m == selectedModel and activeVisualTrade
        bool expired = not selectedVisualStillActive and bar_index - eb >= maxBarsInTradeEff
        float reachedR = hitTP3 ? tp3R : hitTP2 ? tp2R : hitTP1 ? tp1R : array.get(tradeMaxRReached, m)
        reachedR := math.max(reachedR, array.get(tradeMaxRReached, m))
        array.set(tradeMaxRReached, m, reachedR)
        if hitTP3 or hitSL or expired
            float rResult = 0.0
            if hitTP3 and hitSL
                rResult := conservativeBothHit ? -1.0 : tp3R
            else if hitTP3
                rResult := tp3R
            else if hitSL
                rResult := -1.0
            else
                float pnl = d == 1 ? close - e : e - close
                float openR = pnl / risk
                rResult := reachedR > 0 ? reachedR : openR
            closeTrade(m, rResult)


bool selectedNewLongSignal = false
bool selectedNewShortSignal = false

for m = 0 to 15
    bool rawLongSig = modelLong(m)
    bool rawShortSig = modelShort(m)
    int lastDir = array.get(lastSignalDir, m)
    bool longSig = rawLongSig and lastDir != 1
    bool shortSig = rawShortSig and lastDir != -1
    bool chartTradeLocked = m == selectedModel and activeVisualTrade
    bool free = not array.get(inTrade, m) and not chartTradeLocked
    if free and longSig
        array.set(lastSignalDir, m, 1)
        selectedNewLongSignal := m == selectedModel ? true : selectedNewLongSignal
        openTrade(m, 1)
    else if free and shortSig
        array.set(lastSignalDir, m, -1)
        selectedNewShortSignal := m == selectedModel ? true : selectedNewShortSignal
        openTrade(m, -1)

//============================================================
// ACTIVE MANUAL MODEL SIGNAL
//============================================================

activeLong = modelLong(selectedModel)
activeShort = modelShort(selectedModel)

newActiveLong = selectedNewLongSignal
newActiveShort = selectedNewShortSignal

activeName = modelName(selectedModel)
activeTrades = getTrades(selectedModel)
activeWr = getWinRate(selectedModel)
activePf = getProfitFactor(selectedModel)
activeNetR = getNetR(selectedModel)
activeAvgR = getAvgR(selectedModel)

//============================================================
// SIGNAL QUALITY MEMORY
//============================================================

var float lastSignalQuality = na
var string lastSignalSide = "WAIT"
var string lastSignalModel = "-"
var string lastSignalRegime = "-"
var string lastSignalAlignment = "-"

if newActiveLong
    lastSignalQuality := modelQualityScore(selectedModel, true)
    lastSignalSide := "LONG"
    lastSignalModel := activeName
    lastSignalRegime := regimeName
    lastSignalAlignment := qualityAlignLong

if newActiveShort
    lastSignalQuality := modelQualityScore(selectedModel, false)
    lastSignalSide := "SHORT"
    lastSignalModel := activeName
    lastSignalRegime := regimeName
    lastSignalAlignment := qualityAlignShort

//============================================================
// ACTIVE MANUAL MODEL ENTRY / TP1 / TP2 / TP3 / SL LINES
//============================================================

var int activeVisualDir = 0
var float activeVisualEntry = na
var float activeVisualTP1 = na
var float activeVisualTP2 = na
var float activeVisualTP3 = na
var float activeVisualSL = na
var int activeVisualStartBar = na
var line activeEntryLine = na
var line activeTP1Line = na
var line activeTP2Line = na
var line activeTP3Line = na
var line activeSLLine = na
var label activeEntryLabel = na
var label activeTP1Label = na
var label activeTP2Label = na
var label activeTP3Label = na
var label activeSLLabel = na
var box activeRewardBox = na
var box activeRiskBox = na

var array<line> historicalTradeLines = array.new_line()
var array<label> historicalTradeLabels = array.new_label()
var array<box> historicalTradeBoxes = array.new_box()

tradeLevelText(string _name, float _price) =>
    _name + " " + str.tostring(_price, format.mintick)

tradeLevelTooltip(string _name, float _price) =>
    _name + " level | Price: " + str.tostring(_price, format.mintick) + " | TP/SL boxes extend live until TP3 or SL, then stay visible when historical boxes are enabled."

f_deleteLine(line _line) =>
    if not na(_line)
        line.delete(_line)
    true

f_deleteLabel(label _label) =>
    if not na(_label)
        label.delete(_label)
    true

f_deleteBox(box _box) =>
    if not na(_box)
        box.delete(_box)
    true

f_pushHistoricalLine(line _line) =>
    if not na(_line)
        array.push(historicalTradeLines, _line)
    true

f_pushHistoricalLabel(label _label) =>
    if not na(_label)
        array.push(historicalTradeLabels, _label)
    true

f_pushHistoricalBox(box _box) =>
    if not na(_box)
        array.push(historicalTradeBoxes, _box)
    true

f_trimHistoricalTradeVisuals() =>
    while array.size(historicalTradeLines) > historicalTradeLimit * 5
        line oldLine = array.shift(historicalTradeLines)
        if not na(oldLine)
            line.delete(oldLine)
    while array.size(historicalTradeLabels) > historicalTradeLimit * 5
        label oldLabel = array.shift(historicalTradeLabels)
        if not na(oldLabel)
            label.delete(oldLabel)
    while array.size(historicalTradeBoxes) > historicalTradeLimit * 2
        box oldBox = array.shift(historicalTradeBoxes)
        if not na(oldBox)
            box.delete(oldBox)
    true

f_archiveActiveVisuals() =>
    if showHistoricalTradeBoxes
        if not na(activeEntryLine)
            line.set_extend(activeEntryLine, extend.none)
            line.set_color(activeEntryLine, color.white)
            line.set_width(activeEntryLine, 4)
            line.set_style(activeEntryLine, line.style_solid)
        if not na(activeTP1Line)
            line.set_extend(activeTP1Line, extend.none)
        if not na(activeTP2Line)
            line.set_extend(activeTP2Line, extend.none)
        if not na(activeTP3Line)
            line.set_extend(activeTP3Line, extend.none)
        if not na(activeSLLine)
            line.set_extend(activeSLLine, extend.none)
        f_pushHistoricalLine(activeEntryLine)
        f_pushHistoricalLine(activeTP1Line)
        f_pushHistoricalLine(activeTP2Line)
        f_pushHistoricalLine(activeTP3Line)
        f_pushHistoricalLine(activeSLLine)
        f_pushHistoricalLabel(activeEntryLabel)
        f_pushHistoricalLabel(activeTP1Label)
        f_pushHistoricalLabel(activeTP2Label)
        f_pushHistoricalLabel(activeTP3Label)
        f_pushHistoricalLabel(activeSLLabel)
        f_pushHistoricalBox(activeRewardBox)
        f_pushHistoricalBox(activeRiskBox)
        f_trimHistoricalTradeVisuals()
    else
        f_deleteLine(activeEntryLine)
        f_deleteLine(activeTP1Line)
        f_deleteLine(activeTP2Line)
        f_deleteLine(activeTP3Line)
        f_deleteLine(activeSLLine)
        f_deleteLabel(activeEntryLabel)
        f_deleteLabel(activeTP1Label)
        f_deleteLabel(activeTP2Label)
        f_deleteLabel(activeTP3Label)
        f_deleteLabel(activeSLLabel)
        f_deleteBox(activeRewardBox)
        f_deleteBox(activeRiskBox)
    true

f_setTradeLabel(label _label, float _price, string _txt) =>
    if not na(_label)
        label.set_x(_label, bar_index + 1)
        label.set_y(_label, _price)
        label.set_text(_label, f_boldItalicText(tradeLevelText(_txt, _price)))
        label.set_textcolor(_label, (_txt == "TP1" or _txt == "TP2" or _txt == "TP3") ? color.black : color.white)
    true

newVisualTradeSignal = newActiveLong or newActiveShort

if newVisualTradeSignal
    f_archiveActiveVisuals()
    int visualDir = newActiveLong ? 1 : -1
    float visualEntry = close
    float visualRisk = math.max(atr * slAtrEff, syminfo.mintick)
    float visualTP1Distance = visualRisk * tp1R
    float visualTP2Distance = visualRisk * tp2R
    float visualTP3Distance = visualRisk * tp3R
    float visualSL = visualDir == 1 ? visualEntry - visualRisk : visualEntry + visualRisk
    float visualTP1 = visualDir == 1 ? visualEntry + visualTP1Distance : visualEntry - visualTP1Distance
    float visualTP2 = visualDir == 1 ? visualEntry + visualTP2Distance : visualEntry - visualTP2Distance
    float visualTP3 = visualDir == 1 ? visualEntry + visualTP3Distance : visualEntry - visualTP3Distance
    activeVisualTrade := true
    activeVisualDir := visualDir
    activeVisualEntry := visualEntry
    activeVisualTP1 := visualTP1
    activeVisualTP2 := visualTP2
    activeVisualTP3 := visualTP3
    activeVisualSL := visualSL
    activeVisualStartBar := bar_index
    activeEntryLine := line.new(x1=bar_index, y1=activeVisualEntry, x2=bar_index + 1, y2=activeVisualEntry, xloc=xloc.bar_index, extend=extend.none, color=color.white, width=4, style=line.style_solid)
    activeTP1Line := line.new(x1=bar_index, y1=activeVisualTP1, x2=bar_index + 1, y2=activeVisualTP1, xloc=xloc.bar_index, extend=extend.none, color=themeLong, width=2, style=line.style_solid)
    activeTP2Line := line.new(x1=bar_index, y1=activeVisualTP2, x2=bar_index + 1, y2=activeVisualTP2, xloc=xloc.bar_index, extend=extend.none, color=themeLong, width=2, style=line.style_solid)
    activeTP3Line := line.new(x1=bar_index, y1=activeVisualTP3, x2=bar_index + 1, y2=activeVisualTP3, xloc=xloc.bar_index, extend=extend.none, color=themeLong, width=3, style=line.style_solid)
    activeSLLine := line.new(x1=bar_index, y1=activeVisualSL, x2=bar_index + 1, y2=activeVisualSL, xloc=xloc.bar_index, extend=extend.none, color=themeShort, width=3, style=line.style_solid)
    float rewardTop = math.max(activeVisualEntry, activeVisualTP3)
    float rewardBottom = math.min(activeVisualEntry, activeVisualTP3)
    float riskTop = math.max(activeVisualEntry, activeVisualSL)
    float riskBottom = math.min(activeVisualEntry, activeVisualSL)
    activeRewardBox := box.new(left=bar_index, top=rewardTop, right=bar_index + 1, bottom=rewardBottom, xloc=xloc.bar_index, bgcolor=color.new(themeLong, 88), border_color=color.new(themeLong, 55))
    activeRiskBox := box.new(left=bar_index, top=riskTop, right=bar_index + 1, bottom=riskBottom, xloc=xloc.bar_index, bgcolor=color.new(themeShort, 88), border_color=color.new(themeShort, 55))
    activeEntryLabel := label.new(bar_index + 1, activeVisualEntry, f_boldItalicText(tradeLevelText("ENTRY", activeVisualEntry)), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(color.black, 0), textcolor=color.white, size=size.small, tooltip=tradeLevelTooltip("ENTRY", activeVisualEntry))
    activeTP1Label := label.new(bar_index + 1, activeVisualTP1, f_boldItalicText(tradeLevelText("TP1", activeVisualTP1)), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=themeLong, textcolor=color.black, size=size.small, tooltip=tradeLevelTooltip("TP1", activeVisualTP1))
    activeTP2Label := label.new(bar_index + 1, activeVisualTP2, f_boldItalicText(tradeLevelText("TP2", activeVisualTP2)), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=themeLong, textcolor=color.black, size=size.small, tooltip=tradeLevelTooltip("TP2", activeVisualTP2))
    activeTP3Label := label.new(bar_index + 1, activeVisualTP3, f_boldItalicText(tradeLevelText("TP3", activeVisualTP3)), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=themeLong, textcolor=color.black, size=size.small, tooltip=tradeLevelTooltip("TP3", activeVisualTP3))
    activeSLLabel := label.new(bar_index + 1, activeVisualSL, f_boldItalicText(tradeLevelText("SL", activeVisualSL)), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=themeShort, textcolor=color.white, size=size.small, tooltip=tradeLevelTooltip("SL", activeVisualSL))

if activeVisualTrade
    int liveTradeRightBar = bar_index + 1
    if not na(activeEntryLine)
        line.set_x2(activeEntryLine, liveTradeRightBar)
    if not na(activeTP1Line)
        line.set_x2(activeTP1Line, liveTradeRightBar)
    if not na(activeTP2Line)
        line.set_x2(activeTP2Line, liveTradeRightBar)
    if not na(activeTP3Line)
        line.set_x2(activeTP3Line, liveTradeRightBar)
    if not na(activeSLLine)
        line.set_x2(activeSLLine, liveTradeRightBar)
    if not na(activeRewardBox)
        box.set_right(activeRewardBox, liveTradeRightBar)
    if not na(activeRiskBox)
        box.set_right(activeRiskBox, liveTradeRightBar)
    f_setTradeLabel(activeEntryLabel, activeVisualEntry, "ENTRY")
    f_setTradeLabel(activeTP1Label, activeVisualTP1, "TP1")
    f_setTradeLabel(activeTP2Label, activeVisualTP2, "TP2")
    f_setTradeLabel(activeTP3Label, activeVisualTP3, "TP3")
    f_setTradeLabel(activeSLLabel, activeVisualSL, "SL")

activeVisualTP1Hit = activeVisualTrade and activeVisualDir == 1 ? high >= activeVisualTP1 : activeVisualTrade and activeVisualDir == -1 ? low <= activeVisualTP1 : false
activeVisualTP2Hit = activeVisualTrade and activeVisualDir == 1 ? high >= activeVisualTP2 : activeVisualTrade and activeVisualDir == -1 ? low <= activeVisualTP2 : false
activeVisualTP3Hit = activeVisualTrade and activeVisualDir == 1 ? high >= activeVisualTP3 : activeVisualTrade and activeVisualDir == -1 ? low <= activeVisualTP3 : false
activeVisualSLHit = activeVisualTrade and activeVisualDir == 1 ? low <= activeVisualSL : activeVisualTrade and activeVisualDir == -1 ? high >= activeVisualSL : false
activeVisualClosed = activeVisualTrade and bar_index > activeVisualStartBar and (activeVisualTP3Hit or activeVisualSLHit)

if activeVisualClosed
    if not na(activeEntryLine)
        line.set_extend(activeEntryLine, extend.none)
        line.set_x2(activeEntryLine, bar_index)
        line.set_color(activeEntryLine, color.white)
        line.set_width(activeEntryLine, 4)
        line.set_style(activeEntryLine, line.style_solid)
    if not na(activeTP1Line)
        line.set_extend(activeTP1Line, extend.none)
        line.set_x2(activeTP1Line, bar_index)
        line.set_color(activeTP1Line, activeVisualTP1Hit ? themeLong : color.new(color.gray, 35))
    if not na(activeTP2Line)
        line.set_extend(activeTP2Line, extend.none)
        line.set_x2(activeTP2Line, bar_index)
        line.set_color(activeTP2Line, activeVisualTP2Hit ? themeLong : color.new(color.gray, 35))
    if not na(activeTP3Line)
        line.set_extend(activeTP3Line, extend.none)
        line.set_x2(activeTP3Line, bar_index)
        line.set_color(activeTP3Line, activeVisualTP3Hit ? themeLong : color.new(color.gray, 35))
    if not na(activeSLLine)
        line.set_extend(activeSLLine, extend.none)
        line.set_x2(activeSLLine, bar_index)
        line.set_color(activeSLLine, activeVisualSLHit ? themeShort : color.new(color.gray, 35))
    if not na(activeRewardBox)
        box.set_right(activeRewardBox, bar_index)
    if not na(activeRiskBox)
        box.set_right(activeRiskBox, bar_index)
    int closedLabelX = bar_index + 1
    if not na(activeEntryLabel)
        label.set_x(activeEntryLabel, closedLabelX)
    if not na(activeTP1Label)
        label.set_x(activeTP1Label, closedLabelX)
    if not na(activeTP2Label)
        label.set_x(activeTP2Label, closedLabelX)
    if not na(activeTP3Label)
        label.set_x(activeTP3Label, closedLabelX)
    if not na(activeSLLabel)
        label.set_x(activeSLLabel, closedLabelX)
    activeVisualTrade := false

//============================================================
// BEST SYSTEM CALCULATION
//============================================================

int bestSystem = -1
float bestScore = na

for m = 0 to 15
    int t = getTrades(m)
    float score = getMetricValue(m)
    bool eligible = t >= minBestTrades and not na(score)
    if eligible
        if na(bestScore) or score > bestScore
            bestScore := score
            bestSystem := m
        else if score == bestScore and bestSystem >= 0 and getNetR(m) > getNetR(bestSystem)
            bestScore := score
            bestSystem := m

bestSystemName = bestSystem < 0 ? "Not enough data" : modelName(bestSystem)
bestSystemTrades = bestSystem < 0 ? 0 : getTrades(bestSystem)
bestSystemPf = bestSystem < 0 ? na : getProfitFactor(bestSystem)
bestSystemNetR = bestSystem < 0 ? na : getNetR(bestSystem)

//============================================================
// FORMAT HELPERS
//============================================================

pfText(float _pf) =>
    na(_pf) ? "-" : _pf >= 999 ? "INF" : str.tostring(_pf, "#.00")

wrText(float _wr) =>
    na(_wr) ? "-" : str.tostring(_wr, "#.0") + "%"

rText(float _r) =>
    na(_r) ? "-" : str.tostring(_r, "#.00") + "R"

metricText(float _v) =>
    bestMetric == "Profit Factor" ? pfText(_v) :
     bestMetric == "Win Rate" ? wrText(_v) :
     rText(_v)

signalText(string _side) =>
    labelStyle == "Ultra Minimal" ? _side :
     labelStyle == "Detailed" ? _side + " | " + activeName + " | WR " + wrText(activeWr) + " | PF " + pfText(activePf) + " | Avg " + rText(activeAvgR) + " | Net " + rText(activeNetR) :
     _side + " | " + activeName

activeLabelTextSize = activeLabelSize == "Tiny" ? size.tiny : activeLabelSize == "Small" ? size.small : activeLabelSize == "Normal" ? size.normal : size.large

signalQualityColor(float _q, bool _isLong) =>
    na(_q) ? color.new(color.gray, 20) : _q >= 75 ? (_isLong ? themeLong : themeShort) : _q >= 50 ? color.orange : color.new(color.gray, 25)

//============================================================
// VISUALS - CHART LOCKED
//============================================================

plotshape(newActiveLong, title="Manual Model LONG", style=shape.triangleup, location=location.belowbar, color=color.new(color.teal, 0), size=size.tiny)
plotshape(newActiveShort, title="Manual Model SHORT", style=shape.triangledown, location=location.abovebar, color=color.new(color.red, 0), size=size.tiny)

longLabelPrice = low
shortLabelPrice = high

if showActiveLabels and newActiveLong
    label.new(bar_index, longLabelPrice, f_boldItalicText(signalText("LONG")), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=color.new(color.teal, 10), textcolor=color.white, size=activeLabelTextSize, tooltip="LONG signal from the selected active model | Model: " + activeName + " | Quality: " + str.tostring(modelQualityScore(selectedModel, true), "#.0") + "/100")

if showActiveLabels and newActiveShort
    label.new(bar_index, shortLabelPrice, f_boldItalicText(signalText("SHORT")), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=color.new(color.red, 10), textcolor=color.white, size=activeLabelTextSize, tooltip="SHORT signal from the selected active model | Model: " + activeName + " | Quality: " + str.tostring(modelQualityScore(selectedModel, false), "#.0") + "/100")

//============================================================
// SIGNAL QUALITY SCORE TABLE
//============================================================

var table qualityDash = table.new(position.bottom_right, 2, 8, bgcolor=themeBg, frame_color=color.new(themeText, 75), frame_width=1)
qualityTextSize = dashboardSize == "Small" ? size.tiny : dashboardSize == "Medium" ? size.small : size.normal
qualityColor(float _q) =>
    na(_q) ? color.new(color.white, 45) : _q >= 75 ? color.new(color.lime, 0) : _q >= 50 ? color.new(color.orange, 0) : color.new(color.red, 0)

qualityBar(float _q) =>
    int filled = na(_q) ? 0 : int(math.round(math.min(100.0, math.max(0.0, _q)) / 10.0))
    string bar = ""
    for qb = 1 to 10
        bar += qb <= filled ? "█" : "░"
    bar

regimeColor() =>
    regimeTrendUp ? color.new(color.teal, 0) : regimeTrendDown ? color.new(color.red, 0) : regimeChoppy ? color.new(color.orange, 0) : highVolRegime ? color.new(color.yellow, 0) : color.new(color.white, 0)

if showQualityTable and barstate.islast
    table.cell(qualityDash, 0, 0, "SIGNAL", text_color=color.white, bgcolor=color.new(color.black, 0), text_size=qualityTextSize)
    table.cell(qualityDash, 1, 0, "QUALITY", text_color=color.white, bgcolor=color.new(color.black, 0), text_size=qualityTextSize)
    table.cell(qualityDash, 0, 1, "Regime", text_color=color.white, bgcolor=color.new(color.black, 65), text_size=qualityTextSize)
    table.cell(qualityDash, 1, 1, regimeName, text_color=regimeColor(), bgcolor=color.new(color.black, 65), text_size=qualityTextSize)
    table.cell(qualityDash, 0, 2, "Bias", text_color=color.white, bgcolor=color.new(color.black, 65), text_size=qualityTextSize)
    table.cell(qualityDash, 1, 2, regimeBias, text_color=color.white, bgcolor=color.new(color.black, 65), text_size=qualityTextSize)
    table.cell(qualityDash, 0, 3, "Last", text_color=color.white, bgcolor=color.new(color.black, 65), text_size=qualityTextSize)
    table.cell(qualityDash, 1, 3, lastSignalSide, text_color=lastSignalSide == "LONG" ? color.lime : lastSignalSide == "SHORT" ? color.red : color.white, bgcolor=color.new(color.black, 65), text_size=qualityTextSize)
    table.cell(qualityDash, 0, 4, "Model", text_color=color.white, bgcolor=color.new(color.black, 65), text_size=qualityTextSize)
    table.cell(qualityDash, 1, 4, lastSignalModel, text_color=color.white, bgcolor=color.new(color.black, 65), text_size=qualityTextSize)
    table.cell(qualityDash, 0, 5, "Score", text_color=color.white, bgcolor=color.new(color.black, 65), text_size=qualityTextSize)
    table.cell(qualityDash, 1, 5, na(lastSignalQuality) ? "-" : str.tostring(lastSignalQuality, "#.0") + "/100", text_color=qualityColor(lastSignalQuality), bgcolor=color.new(color.black, 65), text_size=qualityTextSize)
    table.cell(qualityDash, 0, 6, "Bar", text_color=color.white, bgcolor=color.new(color.black, 65), text_size=qualityTextSize)
    table.cell(qualityDash, 1, 6, qualityBar(lastSignalQuality), text_color=qualityColor(lastSignalQuality), bgcolor=color.new(color.black, 65), text_size=qualityTextSize)
    table.cell(qualityDash, 0, 7, "Alignment", text_color=color.white, bgcolor=color.new(color.black, 65), text_size=qualityTextSize)
    table.cell(qualityDash, 1, 7, lastSignalAlignment, text_color=lastSignalAlignment == "Aligned" ? color.lime : lastSignalAlignment == "Against" or lastSignalAlignment == "Avoid" ? color.red : color.white, bgcolor=color.new(color.black, 65), text_size=qualityTextSize)

if not showQualityTable and barstate.islast
    table.clear(qualityDash, 0, 0, 1, 7)

//============================================================
// DASHBOARD
//============================================================

var table dash = table.new(position.top_right, 6, 19, bgcolor=themeBg, frame_color=color.new(themeText, 75), frame_width=1)

dashTextSize = dashboardSize == "Small" ? size.tiny : dashboardSize == "Medium" ? size.small : size.normal

rowColor(int _m) =>
    _m == selectedModel ? themeSelectedBg : themeRowBg

netRColor(float _r) =>
    na(_r) ? color.white : _r > 0 ? color.lime : _r < 0 ? color.red : color.white

f_row(int _row, int _m) =>
    table.cell(dash, 0, _row, modelName(_m), text_color=themeText, bgcolor=rowColor(_m), text_size=dashTextSize)
    table.cell(dash, 1, _row, str.tostring(getTrades(_m)), text_color=themeText, bgcolor=rowColor(_m), text_size=dashTextSize)
    table.cell(dash, 2, _row, wrText(getWinRate(_m)), text_color=themeText, bgcolor=rowColor(_m), text_size=dashTextSize)
    table.cell(dash, 3, _row, pfText(getProfitFactor(_m)), text_color=themeText, bgcolor=rowColor(_m), text_size=dashTextSize)
    table.cell(dash, 4, _row, rText(getAvgR(_m)), text_color=themeText, bgcolor=rowColor(_m), text_size=dashTextSize)
    table.cell(dash, 5, _row, rText(getNetR(_m)), text_color=netRColor(getNetR(_m)), bgcolor=rowColor(_m), text_size=dashTextSize)
    true

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "Model", text_color=themeText, bgcolor=themeHeaderBg, text_size=dashTextSize)
    table.cell(dash, 1, 0, "Trades", text_color=themeText, bgcolor=themeHeaderBg, text_size=dashTextSize)
    table.cell(dash, 2, 0, "WR", text_color=themeText, bgcolor=themeHeaderBg, text_size=dashTextSize)
    table.cell(dash, 3, 0, "PF", text_color=themeText, bgcolor=themeHeaderBg, text_size=dashTextSize)
    table.cell(dash, 4, 0, "Avg R", text_color=themeText, bgcolor=themeHeaderBg, text_size=dashTextSize)
    table.cell(dash, 5, 0, "Net R", text_color=themeText, bgcolor=themeHeaderBg, text_size=dashTextSize)
    f_row(1, 0)
    f_row(2, 1)
    f_row(3, 2)
    f_row(4, 3)
    f_row(5, 4)
    f_row(6, 5)
    f_row(7, 6)
    f_row(8, 7)
    f_row(9, 8)
    f_row(10, 9)
    f_row(11, 10)
    f_row(12, 11)
    f_row(13, 12)
    f_row(14, 13)
    f_row(15, 14)
    f_row(16, 15)
    table.cell(dash, 0, 17, "ACTIVE", text_color=themeText, bgcolor=themeSelectedBg, text_size=dashTextSize)
    table.cell(dash, 1, 17, activeName, text_color=themeText, bgcolor=themeSelectedBg, text_size=dashTextSize)
    table.cell(dash, 2, 17, wrText(activeWr), text_color=themeText, bgcolor=themeSelectedBg, text_size=dashTextSize)
    table.cell(dash, 3, 17, pfText(activePf), text_color=themeText, bgcolor=themeSelectedBg, text_size=dashTextSize)
    table.cell(dash, 4, 17, rText(activeAvgR), text_color=themeText, bgcolor=themeSelectedBg, text_size=dashTextSize)
    table.cell(dash, 5, 17, rText(activeNetR), text_color=netRColor(activeNetR), bgcolor=themeSelectedBg, text_size=dashTextSize)
    table.cell(dash, 0, 18, "BEST " + bestMetric, text_color=color.black, bgcolor=themeBestHeaderBg, text_size=dashTextSize)
    table.cell(dash, 1, 18, bestSystemName, text_color=color.black, bgcolor=themeBestBg, text_size=dashTextSize)
    table.cell(dash, 2, 18, str.tostring(bestSystemTrades) + " trades", text_color=color.black, bgcolor=themeBestBg, text_size=dashTextSize)
    table.cell(dash, 3, 18, "Score " + metricText(bestScore), text_color=color.black, bgcolor=themeBestBg, text_size=dashTextSize)
    table.cell(dash, 4, 18, "PF " + pfText(bestSystemPf), text_color=color.black, bgcolor=themeBestBg, text_size=dashTextSize)
    table.cell(dash, 5, 18, "Net " + rText(bestSystemNetR), text_color=color.black, bgcolor=themeBestBg, text_size=dashTextSize)

if not showDashboard and barstate.islast
    table.clear(dash, 0, 0, 5, 18)

//============================================================
// PRO ALERTS
//============================================================

// USAGE NOTE:
// To use the full dynamic Pro Alert message with Side, Model, Preset, Quality, Regime,
// Entry, TP1, TP2, TP3 and SL, create the TradingView alert with:
// Condition: Liquidity Intelligence System
// Option: Any alert() function call
// The regular alertcondition() messages below are fallback static alerts only.

priceText(float _p) =>
    na(_p) ? "-" : str.tostring(_p, format.mintick)

proAlertText(string _side, float _quality, string _alignment) =>
    string qTxt = na(_quality) ? "-" : str.tostring(_quality, "#.0")
    string msg = "LIS PRO SIGNAL"
    msg += " | Side: " + _side
    msg += " | Model: " + activeName
    msg += " | Preset: " + presetMode
    msg += " | Quality: " + qTxt + "/100"
    msg += " | Regime: " + regimeName
    msg += " | Alignment: " + _alignment
    msg += " | Entry: " + priceText(activeVisualEntry)
    msg += " | TP1: " + priceText(activeVisualTP1)
    msg += " | TP2: " + priceText(activeVisualTP2)
    msg += " | TP3: " + priceText(activeVisualTP3)
    msg += " | SL: " + priceText(activeVisualSL)
    msg += " | WR: " + wrText(activeWr)
    msg += " | PF: " + pfText(activePf)
    msg += " | AvgR: " + rText(activeAvgR)
    msg += " | NetR: " + rText(activeNetR)
    msg

proAlertJson(string _side, float _quality, string _alignment) =>
    string qTxt = na(_quality) ? "-" : str.tostring(_quality, "#.0")
    string msg = "{event:LIS_PRO_SIGNAL"
    msg += ",side:" + _side
    msg += ",model:" + activeName
    msg += ",preset:" + presetMode
    msg += ",quality:" + qTxt
    msg += ",regime:" + regimeName
    msg += ",alignment:" + _alignment
    msg += ",entry:" + priceText(activeVisualEntry)
    msg += ",tp1:" + priceText(activeVisualTP1)
    msg += ",tp2:" + priceText(activeVisualTP2)
    msg += ",tp3:" + priceText(activeVisualTP3)
    msg += ",sl:" + priceText(activeVisualSL)
    msg += ",wr:" + wrText(activeWr)
    msg += ",pf:" + pfText(activePf)
    msg += ",avgR:" + rText(activeAvgR)
    msg += ",netR:" + rText(activeNetR)
    msg += "}"
    msg

proAlertMessage(string _side, float _quality, string _alignment) =>
    alertMessageFormat == "JSON" ? proAlertJson(_side, _quality, _alignment) : proAlertText(_side, _quality, _alignment)

if enableProAlerts and newActiveLong
    alert(proAlertMessage("LONG", modelQualityScore(selectedModel, true), qualityAlignLong), alert.freq_once_per_bar_close)

if enableProAlerts and newActiveShort
    alert(proAlertMessage("SHORT", modelQualityScore(selectedModel, false), qualityAlignShort), alert.freq_once_per_bar_close)

//============================================================
// ALERT CONDITIONS
//============================================================

alertcondition(newActiveLong, "Manual Model LONG", "Selected manual confluence model produced a new LONG signal. For full dynamic message, create alert using: Any alert() function call.")
alertcondition(newActiveShort, "Manual Model SHORT", "Selected manual confluence model produced a new SHORT signal. For full dynamic message, create alert using: Any alert() function call.")
````
