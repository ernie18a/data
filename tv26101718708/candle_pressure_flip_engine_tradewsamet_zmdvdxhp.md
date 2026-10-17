# Candle Pressure Flip Engine [trade_w_samet]

- url: https://www.tradingview.com/script/ZMDvdXhP-Candle-Pressure-Flip-Engine-trade-w-samet/
- type: indicator
- pine_id: PUB;2bdf571e0653410599e418fa1ef08b89
- version: 2.0

## Description

🎯 Candle Pressure Flip Engine

Candle Pressure Flip Engine is a professional candle-pressure reversal and trade-visualization indicator designed to help traders study potential pressure-shift conditions directly on the price chart.

This script combines:

🔥 candle pressure analysis
⚡ exhaustion move detection
🕯️ rejection wick logic
📍 close-location pressure
📊 volume burst confirmation
🧭 RSI momentum flip confirmation
🧠 Auto Best optimizer logic
🎯 target / risk projection boxes
🏷️ BULLISH / BEARISH flip labels
🏁 WIN / LOSS result stamps
🩸 Crimson Spine + Echo + Fill visual system
🚨 professional alert messages
🎨 multiple visual themes
📦 historical target/risk visual tracking

The goal of Candle Pressure Flip Engine is not to predict the future or provide guaranteed buy/sell instructions.

Its purpose is to help users visually study:

⚡ exhaustion after aggressive moves
🕯️ candle rejection behavior
📍 where price closes inside the candle range
📊 whether volume expanded during the reaction
🧭 whether RSI momentum started turning
🎯 projected target and risk areas
🏁 visual target/risk outcomes
🩸 price-following pressure visuals
🚨 alert-based chart monitoring

Candle Pressure Flip Engine should be treated as a structured chart-analysis and educational decision-support tool.

It is not financial advice.
It is not an automated trading system.
It does not guarantee profitable results.
It does not place broker orders.
It does not remove the need for personal analysis, risk management, or trade validation.

━━━━━━━━━━━━━━━━━━━━━━
📌 OVERVIEW
━━━━━━━━━━━━━━━━━━━━━━

At a high level, Candle Pressure Flip Engine does the following:

🔥 Measures the size of the prior price move using ATR-based exhaustion logic.
🕯️ Checks whether the signal candle shows meaningful rejection wick pressure.
📍 Evaluates where the candle closes inside its own range.
📊 Optionally confirms the move with volume expansion.
🧭 Optionally confirms momentum change using RSI behavior.
🧠 Runs a background optimizer to compare internal setup combinations.
🎯 Draws a single target zone and risk zone after confirmed signals.
📦 Keeps historical target/risk boxes on the chart.
🏁 Tracks whether target or risk was reached first.
🏷️ Prints clean BULLISH FLIP ▲ and BEARISH FLIP ▼ labels.
🩸 Displays a premium Crimson Spine + Echo + Fill visual trail around price.
🚨 Provides professional human-readable and JSON-style dynamic alerts.

This makes the script more than a simple signal-label indicator.

It is designed as a complete candle-pressure review environment that combines candle behavior, exhaustion context, rejection, momentum, volume, visual planning, and alerts.

━━━━━━━━━━━━━━━━━━━━━━
🧠 CORE IDEA
━━━━━━━━━━━━━━━━━━━━━━

The core idea behind Candle Pressure Flip Engine is that a potential reversal should not be judged from a single isolated condition.

A candle can look strong, but without context it may not mean much.

For that reason, this script combines several layers:

🔥 exhaustion move context
🕯️ rejection wick behavior
📍 close-position pressure
📊 volume burst confirmation
🧭 RSI momentum turn
🧠 optimizer-based internal comparison
🎯 target/risk visualization
🩸 visual price-following pressure trail

The script does not attempt to catch every reversal.

It attempts to highlight moments where the internal candle-pressure model detects a possible shift after price has already moved aggressively in one direction.

The purpose is not to create more signals.

The purpose is to make potential pressure-flip conditions easier to identify, review, and compare on the chart.

━━━━━━━━━━━━━━━━━━━━━━
🧩 WHY THIS SCRIPT IS NOT A SIMPLE BUY/SELL INDICATOR
━━━━━━━━━━━━━━━━━━━━━━

Candle Pressure Flip Engine is not intended to behave like a basic “buy here / sell here” script.

It is built as a structured workflow:

Exhaustion Move
→ Candle Rejection
→ Close Pressure
→ Volume Burst
→ Momentum Flip
→ Score Requirement
→ Optional Auto Best Selection
→ BULLISH / BEARISH Flip Label
→ Target / Risk Projection
→ Result Tracking
→ Crimson Spine Visual Context
→ Alerts

Each part has a specific role.

🔥 The exhaustion engine checks whether price has moved enough before a flip is considered.
🕯️ The wick engine checks whether the candle rejected a level strongly enough.
📍 The close-pressure engine checks where the candle closed inside its range.
📊 The volume module checks whether the signal candle has volume expansion.
🧭 The momentum module checks whether RSI is turning in the expected direction.
🧠 The optimizer compares internal parameter combinations in the background.
🎯 The target/risk module draws visual planning zones.
🩸 The Crimson Spine module adds a premium price-following visual layer.
🚨 The alert module helps monitor signals and results without constantly watching the chart.

This makes the script a complete visual review framework, not a one-condition signal tool.

━━━━━━━━━━━━━━━━━━━━━━
⚙️ HOW THE SCRIPT WORKS
━━━━━━━━━━━━━━━━━━━━━━

🔥 EXHAUSTION MOVE ENGINE

The script first checks whether price has made a meaningful move over a selected lookback period.

This is done using:

• Exhaustion Lookback
• Minimum Exhaustion Move ATR
• Minimum Directional Bars
• ATR-based move measurement

A bullish flip can only appear after bearish exhaustion conditions are detected.

A bearish flip can only appear after bullish exhaustion conditions are detected.

This means the script is designed to look for possible pressure flips after directional movement, not random candles in the middle of neutral price action.

For bullish setups, the script looks for prior downside pressure.

For bearish setups, the script looks for prior upside pressure.

This creates the first layer of context.

━━━━━━━━━━━━━━━━━━━━━━
🕯️ REJECTION WICK ENGINE
━━━━━━━━━━━━━━━━━━━━━━

After exhaustion is detected, the script checks the signal candle itself.

For a bullish flip, the script evaluates the lower wick.

For a bearish flip, the script evaluates the upper wick.

The purpose is to identify whether price rejected one side of the candle range.

The main setting is:

Minimum Rejection Wick %

A larger rejection wick requirement makes the script more selective.

A smaller rejection wick requirement allows more potential signals.

The wick condition does not guarantee that price will reverse.

It only means that the candle showed rejection behavior according to the script’s internal model.

━━━━━━━━━━━━━━━━━━━━━━
📍 CLOSE-PRESSURE ENGINE
━━━━━━━━━━━━━━━━━━━━━━

The script also evaluates where the candle closes inside its own range.

This is important because a rejection wick alone is not always enough.

For bullish flips, the script prefers candles that close closer to the upper part of the candle range.

For bearish flips, the script prefers candles that close closer to the lower part of the candle range.

This is controlled by:

Close Pressure Threshold %

Example:

If the threshold is 65%, a bullish candle must close relatively high in its candle range.

For bearish flips, the inverse logic is used.

This helps the script avoid weak candles that reject but fail to close with enough pressure.

━━━━━━━━━━━━━━━━━━━━━━
📏 BODY PRESSURE ENGINE
━━━━━━━━━━━━━━━━━━━━━━

The script also checks the body size of the signal candle.

This is controlled by:

Minimum Reversal Body %

The candle body is measured as a percentage of the full candle range.

This helps avoid extremely weak candles where the wick may be large but the body does not show enough directional pressure.

A higher value makes the script more selective.

A lower value allows more signals.

This does not mean a larger candle body is always better.

It simply gives the model a minimum candle-strength requirement.

━━━━━━━━━━━━━━━━━━━━━━
📊 VOLUME BURST CONFIRMATION
━━━━━━━━━━━━━━━━━━━━━━

Candle Pressure Flip Engine includes an optional Volume Burst filter.

When enabled, the script compares current volume to its moving average.

The main settings are:

📊 Use Volume Burst
📊 Volume MA Length
📊 Minimum Volume Multiplier

Example:

A Minimum Volume Multiplier of 1.10 means the current volume must be at least 10% above its average.

The purpose is to check whether the pressure-flip candle appeared with above-average participation.

This can be useful on markets where volume data is meaningful.

Important note:

Some symbols, brokers, CFDs, forex feeds, or synthetic markets may have limited or less reliable volume data.

Users can disable this filter if volume is not useful for their selected market.

━━━━━━━━━━━━━━━━━━━━━━
🧭 RSI MOMENTUM FLIP CONFIRMATION
━━━━━━━━━━━━━━━━━━━━━━

The script includes an optional RSI Momentum Flip module.

This does not use RSI as a classic overbought/oversold signal.

Instead, the script checks whether RSI is turning in the expected direction.

Main settings:

🧭 Use Momentum Flip
🧭 RSI Length
🧭 RSI Turn Lookback
🧭 Bullish RSI Max After Flip
🧭 Bearish RSI Min After Flip

For bullish flips, RSI should start turning upward without already being too extended.

For bearish flips, RSI should start turning downward without already being too extended.

This is designed to help filter signals where candle pressure appears but momentum has not started shifting yet.

RSI confirmation is only one part of the model.

It does not guarantee future price movement.

━━━━━━━━━━━━━━━━━━━━━━
🧠 AUTO BEST OPTIMIZER
━━━━━━━━━━━━━━━━━━━━━━

Candle Pressure Flip Engine includes a background optimizer.

The optimizer compares controlled internal combinations of:

• Exhaustion move requirement
• Rejection wick requirement
• Signal score requirement
• Risk/reward target

The optimizer can be set to:

Light 27
Full 81

Light mode tests fewer combinations.

Full mode tests a deeper combination set.

The script can automatically use the best internal combination after enough closed virtual outcomes are collected.

This is controlled by:

🧠 Use Background Optimizer
🧠 Auto Use Best Optimizer Combo
🧠 Optimizer Grid Depth
🧠 Best Combination Ranking
🧠 Minimum Trades For Best Combo

Important note:

The optimizer is an internal visual-analysis feature.

It is not the same as TradingView Strategy Tester.

It does not include broker execution, spread, slippage, commissions, order delay, partial fills, or real trade management.

It should be treated as a chart-based adaptive review tool, not as a guarantee of improved future performance.

━━━━━━━━━━━━━━━━━━━━━━
🎯 TARGET / RISK VISUAL SYSTEM
━━━━━━━━━━━━━━━━━━━━━━

When a valid candle pressure flip appears, the script can draw a projected trade plan.

The chart can show:

🎯 Target Zone
⚠️ Risk Zone
📍 Entry Zone
📈 Target line
🛑 Risk line
🏁 WIN / LOSS result stamp

The system uses a single target model.

There are no TP1 / TP2 / TP3 levels in this script.

The default target is based on the selected Risk Reward value.

Default:

Target Risk Reward = 2.0R

The risk distance can be calculated using:

Signal Wick
ATR
Hybrid

The current default risk mode is ATR.

The ATR multiplier used in the model is fixed internally at 4.0.

This creates a consistent risk projection structure.

Important note:

The target and risk boxes are visual projections only.

They are not broker orders.

They do not execute trades.

They do not guarantee that the displayed target or risk will be reached in a profitable way.

━━━━━━━━━━━━━━━━━━━━━━
🛡️ RISK MODE EXPLANATION
━━━━━━━━━━━━━━━━━━━━━━

The script includes three risk modes:

Signal Wick
ATR
Hybrid

Signal Wick mode uses the candle wick area as the risk reference.

ATR mode uses ATR-based distance.

Hybrid mode uses a wider protective logic between wick-based and ATR-based risk.

The purpose of these modes is to give users flexibility in how projected risk zones are visually drawn.

Risk settings affect the chart projection.

They should not be treated as trade recommendations.

Users should always apply their own risk management and validation.

━━━━━━━━━━━━━━━━━━━━━━
⚠️ SAME-CANDLE TARGET/RISK HANDLING
━━━━━━━━━━━━━━━━━━━━━━

If both target and risk are touched on the same candle, the true intrabar sequence cannot be known from standard OHLC chart data.

The script includes a setting for this situation:

If Target and Risk Hit Same Bar

Available options:

SL First
TP First

The default is SL First.

This is a conservative assumption.

It helps avoid overly optimistic historical visual results when the true intrabar order is unknown.

Users should understand that this is still an assumption based on available bar data.

━━━━━━━━━━━━━━━━━━━━━━
🏁 RESULT TRACKING
━━━━━━━━━━━━━━━━━━━━━━

The script can track whether a projected setup reaches target or risk first.

Possible result labels:

WIN | TARGET HIT
LOSS | RISK HIT

A WIN label means the projected target zone was reached first according to the script’s bar-based logic.

A LOSS label means the projected risk zone was reached first according to the script’s bar-based logic.

These labels are visual summaries only.

They do not represent broker execution.

They do not include slippage, spread, commissions, order delay, partial fills, liquidity issues, or real entry conditions.

━━━━━━━━━━━━━━━━━━━━━━
🗂️ HISTORICAL TARGET / RISK BOXES
━━━━━━━━━━━━━━━━━━━━━━

Candle Pressure Flip Engine can keep previous target and risk boxes on the chart.

This helps users visually review past projected setups.

The script includes a maximum historical trade-plan limit.

This is important because TradingView has object limits.

Historical visuals may include:

🎯 previous target boxes
⚠️ previous risk boxes
📍 previous entry lines
🏁 previous result labels
🏷️ previous target/risk price tags

Users can reduce the historical object limit if the chart becomes crowded or performance slows down.

━━━━━━━━━━━━━━━━━━━━━━
🏷️ SIGNAL LABELS
━━━━━━━━━━━━━━━━━━━━━━

The script displays professional signal labels:

BULLISH FLIP ▲
BEARISH FLIP ▼

A BULLISH FLIP label appears when the script detects a possible bullish candle-pressure shift.

A BEARISH FLIP label appears when the script detects a possible bearish candle-pressure shift.

The arrow icon is included to make direction easier to identify visually.

These labels do not mean the future outcome is guaranteed.

They only mean the script’s internal conditions aligned at that candle.

━━━━━━━━━━━━━━━━━━━━━━
🩸 CRIMSON SPINE + ECHO + FILL
━━━━━━━━━━━━━━━━━━━━━━

Candle Pressure Flip Engine includes a premium visual system called:

Crimson Spine + Echo + Fill

This is not a signal by itself.

It is a visual price-following layer designed to create a clean pressure-aura effect around price.

The system includes:

🩸 one central Crimson Spine
🩸 multiple upper echo layers
🩸 multiple lower echo layers
🩸 soft crimson fill clouds
🩸 optional pulse effect
🩸 adaptive spread based on internal pressure intensity

The purpose of the Crimson Spine system is to enhance chart readability and create a premium visual structure around price.

It can help users visually track price flow, pressure compression, and expansion.

Important note:

The Crimson Spine visual is not a standalone entry signal.

It should not be used by itself as a buy/sell system.

It is a supporting visual layer.

━━━━━━━━━━━━━━━━━━━━━━
🎨 VISUAL THEME SYSTEM
━━━━━━━━━━━━━━━━━━━━━━

The script includes multiple visual themes:

Midnight Pro
Ice Minimal
Black Gold
Red Carbon

The theme system affects:

🎨 BULLISH / BEARISH label colors
🎨 Target zone colors
🎨 Risk zone colors
🎨 Result stamp colors
🎨 Entry / target / risk tags
🎨 Candle highlight color
🎨 Glow effects

The script uses a modern chart-first visual style.

It does not include a classic dashboard.

It does not include a large statistics panel.

The goal is to keep the chart clean while still providing strong visual feedback.

━━━━━━━━━━━━━━━━━━━━━━
🚨 PROFESSIONAL ALERT SYSTEM
━━━━━━━━━━━━━━━━━━━━━━

Candle Pressure Flip Engine includes two alert layers:

1. Standard alertcondition() events
2. Dynamic alert() messages

Standard alert conditions are included for compatibility with TradingView’s normal alert interface.

Dynamic alerts can include more detailed information such as:

🚨 symbol
🚨 timeframe
🚨 direction
🚨 score
🚨 entry
🚨 risk
🚨 target
🚨 RR
🚨 Auto Best state
🚨 result
🚨 Net R

The alert system can be configured using:

🚨 Enable Dynamic Alerts
🚨 Alert Bullish Flips
🚨 Alert Bearish Flips
🚨 Alert Trade Results
🚨 Alert Payload Format
🚨 Include Entry / Risk / Target
🚨 Include Auto Best State
🚨 Alert Tag

Available payload formats:

Human
JSON

Human format is easier to read.

JSON format is more suitable for webhook workflows.

Important note:

Alerts are monitoring tools only.

They are not trade execution instructions.

They do not place orders.

Users must confirm all alerts with their own analysis and risk management.

━━━━━━━━━━━━━━━━━━━━━━
🔔 HOW TO USE ALERTS
━━━━━━━━━━━━━━━━━━━━━━

A practical alert workflow:

1. Add Candle Pressure Flip Engine [trade_w_samet] to your chart.
2. Open TradingView’s alert window.
3. Select the indicator as the alert condition.
4. Choose the desired alert type.
5. For dynamic alert() messages, use “Any alert() function call” if needed.
6. Select alert frequency according to your preference.
7. Use alerts for monitoring only.
8. Confirm each alert manually before making any trading decision.

Alerts may behave differently depending on chart timeframe, symbol, session, and real-time bar updates.

━━━━━━━━━━━━━━━━━━━━━━
🧪 HOW TO USE THE INDICATOR
━━━━━━━━━━━━━━━━━━━━━━

A practical workflow:

1. Add Candle Pressure Flip Engine [trade_w_samet] to your chart.
2. Start with the default settings.
3. Review whether the chart is trending, ranging, or highly volatile.
4. Wait for a BULLISH FLIP ▲ or BEARISH FLIP ▼ label.
5. Review the candle that created the signal.
6. Check whether the move before the signal was extended.
7. Check whether the rejection wick is meaningful.
8. Check whether the candle closed with pressure.
9. Review the target and risk boxes.
10. Review the Crimson Spine visual context.
11. Use alerts if you want automatic monitoring.
12. Validate the signal with your own market structure, liquidity, trend, session, and risk-management rules.

This indicator is best used as a structured visual review tool.

It should not be used as a blind execution system.

━━━━━━━━━━━━━━━━━━━━━━
⚙️ SETTINGS REFERENCE
━━━━━━━━━━━━━━━━━━━━━━

⚙️ General

Signal Mode
Controls how selective the signal engine is.

Available modes:

Aggressive
Balanced
Conservative

Aggressive allows more signals.
Balanced is the default middle-ground profile.
Conservative requires stricter conditions.

Only One Active Trade
When enabled, the script waits until the active projection reaches target or risk before allowing a new signal.

Signal Cooldown Bars
Controls how many bars must pass between confirmed signals.

Show BULLISH / BEARISH Labels
Shows or hides the main signal labels.

Max Signal Labels
Limits how many signal labels remain visible on the chart.

━━━━━━━━━━━━━━━━━━━━━━

🔥 Candle Pressure Flip Engine

Exhaustion Lookback
Defines how many bars are used to evaluate the prior aggressive move.

Minimum Exhaustion Move ATR
Defines how large the prior move must be, measured in ATR.

Minimum Directional Bars
Requires a minimum number of bars inside the lookback to support the exhaustion direction.

Minimum Reversal Body %
Controls the minimum candle body size of the signal candle.

Minimum Rejection Wick %
Controls the minimum rejection wick percentage.

Close Pressure Threshold %
Controls where the candle must close inside its range.

Minimum Signal Score
Defines the minimum internal score required for a signal.

━━━━━━━━━━━━━━━━━━━━━━

📊 Volume Burst

Use Volume Burst
Enables or disables volume confirmation.

Volume MA Length
Defines the moving average length used for volume comparison.

Minimum Volume Multiplier
Defines how much larger current volume must be compared to average volume.

━━━━━━━━━━━━━━━━━━━━━━

🧭 Momentum Flip

Use Momentum Flip
Enables or disables RSI momentum confirmation.

RSI Length
Defines the RSI calculation length.

RSI Turn Lookback
Defines how many bars back RSI is compared.

Bullish RSI Max After Flip
Prevents bullish signals from appearing when RSI is already too extended upward.

Bearish RSI Min After Flip
Prevents bearish signals from appearing when RSI is already too extended downward.

━━━━━━━━━━━━━━━━━━━━━━

🎯 Target / Risk Result Engine

Show Target / Risk Boxes
Shows projected target and risk zones.

Show Entry / Risk / Target Lines
Shows entry, risk, and target lines.

Show Only Last Trade Plan
Removes older visual trade plans and keeps only the newest one.

Keep Historical Target / Risk Boxes
Keeps previous target/risk projections on the chart.

Max Historical Trade Plans
Controls the maximum number of historical visual plans.

Track Win / Loss Result
Enables visual result tracking.

Default Target Risk Reward
Defines the default projected RR value.

Risk Mode
Controls whether risk is based on signal wick, ATR, or hybrid logic.

ATR Length
Defines the ATR length used for risk calculations.

Risk Buffer Ticks
Adds a small tick buffer to wick-based risk calculations.

Trade Box Extend Bars
Controls how far target/risk boxes extend to the right.

If Target and Risk Hit Same Bar
Controls the same-candle assumption.

Max Result Stamps
Limits the number of WIN / LOSS result labels.

━━━━━━━━━━━━━━━━━━━━━━

🧠 Background Optimizer

Use Background Optimizer
Enables the internal optimizer engine.

Auto Use Best Optimizer Combo
Allows the script to automatically apply the best internal combination after enough closed virtual outcomes are collected.

Optimizer Grid Depth
Controls whether the optimizer uses Light 27 or Full 81 testing depth.

Best Combination Ranking
Controls whether combinations are ranked by wins first or win rate first.

Minimum Trades For Best Combo
Defines how many closed virtual trades are required before a combination can become eligible.

━━━━━━━━━━━━━━━━━━━━━━

🎨 Visual Pro Design

Visual Theme
Controls the main chart color theme.

Visual Intensity
Controls glow and line emphasis.

Label Size
Controls signal/result label size.

Target / Risk Box Transparency
Controls how transparent projected boxes appear.

Show Signal Glow
Shows or hides the signal candle glow.

Show WIN / LOSS Stamps
Shows or hides result labels.

Show Compact Price Tags
Shows or hides ENTRY ZONE, TARGET ZONE, and RISK ZONE tags.

Candle Highlight Mode
Controls candle coloring on signal/result bars.

Max Signal Glow Objects
Limits signal glow objects for chart performance.

━━━━━━━━━━━━━━━━━━━━━━

🚨 Professional Alerts

Enable Dynamic Alerts
Turns dynamic alert() messages on or off.

Alert Bullish Flips
Enables alerts for bullish flip signals.

Alert Bearish Flips
Enables alerts for bearish flip signals.

Alert Trade Results
Enables alerts for target/risk results.

Alert Payload Format
Choose Human or JSON.

Include Entry / Risk / Target
Adds projected price levels into alerts.

Include Auto Best State
Adds Auto Best status into signal alerts.

Alert Tag
Custom text tag included in alert messages.

━━━━━━━━━━━━━━━━━━━━━━

🩸 Crimson Spine + Echo

Show Crimson Spine System
Shows or hides the Crimson Spine visual layer.

Spine Source
Defines the source price used by the spine.

Spine EMA Length
Controls the central spine smoothing.

Echo Spacing ATR
Controls how far echo layers are spaced from the central spine.

Adaptive Echo Spread
Expands or compresses the echo cloud based on internal pressure intensity.

Spine Line Width
Controls line thickness.

Core Line Transparency
Controls the transparency of the central spine.

Echo Transparency Step
Controls how quickly outer echo layers become transparent.

Crimson Fill Transparency
Controls the fill cloud transparency.

Spine Pulse Effect
Adds a subtle pulsing visual effect.

━━━━━━━━━━━━━━━━━━━━━━
🧠 WHAT MAKES THIS SCRIPT ORIGINAL
━━━━━━━━━━━━━━━━━━━━━━

Candle Pressure Flip Engine uses familiar concepts such as:

🔥 candle body analysis
🕯️ wick rejection
📍 close-location pressure
📊 volume comparison
🧭 RSI momentum
📏 ATR-based risk projection
🎯 target/risk boxes
🚨 alerts

These concepts are not unique by themselves.

The originality of the script lies in how they are organized into one workflow:

Exhaustion Move
→ Rejection Wick
→ Close Pressure
→ Volume Burst
→ Momentum Flip
→ Internal Score
→ Auto Best Optimizer
→ BULLISH / BEARISH Flip Label
→ Target / Risk Projection
→ Result Tracking
→ Crimson Spine Visual Layer
→ Professional Alerts

This structure is designed to give users a clearer way to review potential candle-pressure reversal conditions.

━━━━━━━━━━━━━━━━━━━━━━
⚠️ IMPORTANT PRACTICAL NOTES
━━━━━━━━━━━━━━━━━━━━━━

The script’s behavior depends heavily on settings.

Signal frequency and visual output may change based on:

🎛️ signal mode
🔥 exhaustion lookback
📏 ATR settings
🕯️ wick requirement
📍 close-pressure threshold
📊 volume settings
🧭 RSI settings
🧠 optimizer settings
🎯 target/risk settings
⏱️ timeframe
📊 symbol volatility
🌐 market session
📚 available historical bars

A configuration that looks clean on one symbol may behave differently on another.

A setting that appears useful on one timeframe may not be useful on another.

Users should test the script on the exact markets and timeframes they personally study.

━━━━━━━━━━━━━━━━━━━━━━
⚠️ LIMITATIONS AND SHORTCOMINGS
━━━━━━━━━━━━━━━━━━━━━━

This script has important limitations:

❌ It does not guarantee profitable trades.
❌ It does not predict future price movement.
❌ It does not replace risk management.
❌ It does not execute trades.
❌ It does not place broker orders.
❌ It does not include broker slippage.
❌ It does not include commissions.
❌ It does not include spreads.
❌ It does not include order delay.
❌ It does not include partial fills.
❌ It uses bar-based chart data.
❌ Same-candle target/risk order cannot be known from standard OHLC data.
❌ Internal optimizer results are not official Strategy Tester results.
❌ Target/risk boxes are visual projections only.
❌ Result labels are visual outcomes only.
❌ Crimson Spine visuals are not standalone signals.
❌ Alerts are monitoring tools only.
❌ Historical behavior does not ensure future behavior.

For these reasons, Candle Pressure Flip Engine should be used as an educational decision-support and chart-analysis tool, not as a standalone trading strategy.

━━━━━━━━━━━━━━━━━━━━━━
👤 WHO THIS SCRIPT MAY BE USEFUL FOR
━━━━━━━━━━━━━━━━━━━━━━

This script may be useful for traders who:

✅ study candle-pressure behavior
✅ study reversal conditions after extended moves
✅ want structured candle rejection confirmation
✅ want volume and momentum context
✅ want clean target/risk visual planning
✅ want historical visual projection review
✅ want premium chart visuals without a large dashboard
✅ want alert-based monitoring
✅ want a structured educational analysis tool
✅ prefer chart-first visual design

It may be less suitable for users who:

❌ want guaranteed buy/sell signals
❌ want a fully automated trading bot
❌ do not use technical analysis
❌ do not want chart visuals
❌ expect one setting to work on every market
❌ expect alerts to execute trades
❌ expect visual projections to match broker execution
❌ want an indicator that replaces personal decision-making

━━━━━━━━━━━━━━━━━━━━━━
🧭 BEST PRACTICE SUGGESTIONS
━━━━━━━━━━━━━━━━━━━━━━

For cleaner review:

✅ Start with the default settings.
✅ Use Balanced mode first.
✅ Review signals together with market structure.
✅ Check whether the signal appears after a meaningful move.
✅ Review rejection wick quality.
✅ Review candle close position.
✅ Use target/risk boxes as visual planning tools only.
✅ Do not treat every signal as a trade.
✅ Review the Crimson Spine as a supporting visual layer, not as a standalone signal.
✅ Use alerts for monitoring, not automatic execution.
✅ Test the indicator on the symbols and timeframes you actually study.
✅ Combine the tool with independent analysis and risk management.
✅ Keep expectations realistic.

━━━━━━━━━━━━━━━━━━━━━━
🔓 PUBLICATION NOTE
━━━━━━━━━━━━━━━━━━━━━━

Candle Pressure Flip Engine [trade_w_samet] is published as an educational and visual market-analysis tool.

The purpose of this description is to explain:

✅ what the script does
✅ how the main logic works
✅ how signals are created
✅ how candle pressure is evaluated
✅ how target/risk boxes are drawn
✅ how result labels work
✅ what the Crimson Spine visual means
✅ what the alert system does
✅ what the limitations are
✅ how the indicator should and should not be used

The script is designed to support structured analysis.

It does not promise profitable results.

It does not remove market risk.

It does not execute trades.

It should not be used as a blind buy/sell system.

It is best used as a visual framework for reviewing candle-pressure reversal conditions, target/risk projection behavior, and alert-based monitoring.

━━━━━━━━━━━━━━━━━━━━━━
🛡️ DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━

Candle Pressure Flip Engine [trade_w_samet] is provided for educational and informational purposes only.

It does not constitute financial, investment, or trading advice.

No indicator can guarantee future results.

Markets are uncertain, conditions change, and historical behavior does not ensure future performance.

Every user is responsible for their own analysis, validation, risk management, position sizing, and trading decisions.

The target/risk boxes, BULLISH / BEARISH labels, WIN / LOSS result stamps, Crimson Spine visuals, optimizer behavior, and alerts are visual analysis tools only.

Use this script as a structured decision-support and visual review framework, not as a promise of profitability.

## Source Code

````pine
//@version=6
indicator("Candle Pressure Flip Engine [trade_w_samet]", shorttitle = "Candle Pressure Flip Engine [trade_w_samet]", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Candle Pressure Flip Engine [trade_w_samet]
// v1.0 Official Release
// Clean reversal signal engine:
// Exhaustion Move + Rejection Wick + Close Pressure + Volume Burst + Momentum Flip
// Features:
// - Auto Best Optimizer Combo
// - Fixed ATR Risk Multiplier = 4.0
// - Single Target / Risk result model
// - Historical Target / Risk boxes
// - Modern target/risk color separation
// - Professional BULLISH / BEARISH labels
// - Inputs hidden from status line
// - Mini modern dashboard added
// - Extended label size control
// - Synthetic ribbon removed
// - Crimson Spine + Echo + Fill: central EMA spine, layered red echo bands and premium fill cloud
// - Official release naming prepared for TradingView publishing
// - Clean chart-first visuals with hidden status-line inputs and hidden price-scale plot labels
// - Professional dynamic alert system with human-readable and JSON-style payloads
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupGeneral = "⚙️ 01. General"
signalMode = input.string("Balanced", "Signal Mode", options = ["Aggressive", "Balanced", "Conservative"], group = groupGeneral, tooltip = "Controls how selective the signal engine is. Aggressive gives more signals, Conservative gives fewer but stricter signals.", display = display.none)
oneTradeAtATime = input.bool(true, "Only One Active Trade", group = groupGeneral, tooltip = "When enabled, the script waits for the active trade to hit target or risk before allowing a new signal.", display = display.none)
signalCooldownBars = input.int(8, "Signal Cooldown Bars", minval = 0, maxval = 500, group = groupGeneral, tooltip = "Minimum number of bars required between two confirmed signals. Higher values reduce signal clustering.", display = display.none)
showBullBearLabels = input.bool(true, "Show BULLISH / BEARISH Labels", group = groupGeneral, tooltip = "Shows the main BULLISH FLIP or BEARISH FLIP signal label on the chart.", display = display.none)
maxSignalLabels = input.int(80, "Max Signal Labels", minval = 10, maxval = 250, group = groupGeneral, tooltip = "Limits how many historical signal labels remain visible to protect chart performance.", display = display.none)

groupPressure = "🔥 02. Candle Pressure Flip Engine"
exhaustionLookback = input.int(8, "Exhaustion Lookback", minval = 3, maxval = 50, group = groupPressure, tooltip = "Number of bars used to measure the aggressive move before a possible pressure flip.", display = display.none)
minMoveAtr = input.float(1.20, "Minimum Exhaustion Move ATR", minval = 0.10, maxval = 10.0, step = 0.10, group = groupPressure, tooltip = "Minimum move size measured in ATR. Higher values require stronger exhaustion before a reversal signal can form.", display = display.none)
minDirectionalBars = input.int(4, "Minimum Directional Bars", minval = 1, maxval = 30, group = groupPressure, tooltip = "Minimum number of bars inside the lookback that must support the exhaustion direction.", display = display.none)
minBodyPct = input.float(30.0, "Minimum Reversal Body %", minval = 0.0, maxval = 100.0, step = 1.0, group = groupPressure, tooltip = "Minimum candle body percentage required on the reversal trigger candle.", display = display.none)
minRejectionWickPct = input.float(35.0, "Minimum Rejection Wick %", minval = 0.0, maxval = 100.0, step = 1.0, group = groupPressure, tooltip = "Minimum rejection wick percentage. Bullish flips use lower wick, bearish flips use upper wick.", display = display.none)
closePressurePct = input.float(65.0, "Close Pressure Threshold %", minval = 50.0, maxval = 95.0, step = 1.0, group = groupPressure, tooltip = "Defines where the candle must close inside its range. Bullish flips need an upper-range close, bearish flips need a lower-range close.", display = display.none)
minSignalScore = input.float(62.0, "Minimum Signal Score", minval = 0.0, maxval = 100.0, step = 1.0, group = groupPressure, tooltip = "Minimum final score required for a pressure flip signal. Higher values produce fewer but cleaner signals.", display = display.none)

groupVolume = "📊 03. Volume Burst"
useVolumeBurst = input.bool(true, "Use Volume Burst", group = groupVolume, tooltip = "Requires the signal candle to have above-average volume. Disable for markets with unreliable volume data.", display = display.none)
volumeLength = input.int(20, "Volume MA Length", minval = 1, maxval = 300, group = groupVolume, tooltip = "Moving average length used to compare current volume against normal volume.", display = display.none)
minVolumeMultiplier = input.float(1.10, "Minimum Volume Multiplier", minval = 0.10, maxval = 10.0, step = 0.05, group = groupVolume, tooltip = "Minimum volume expansion required. Example: 1.10 means current volume must be at least 10% above the volume average.", display = display.none)

groupMomentum = "🧭 04. Momentum Flip"
useMomentumFlip = input.bool(true, "Use Momentum Flip", group = groupMomentum, tooltip = "Requires RSI momentum to turn in the reversal direction before confirming the signal.", display = display.none)
rsiLength = input.int(14, "RSI Length", minval = 2, maxval = 100, group = groupMomentum, tooltip = "RSI length used for the momentum flip confirmation.", display = display.none)
rsiTurnLookback = input.int(2, "RSI Turn Lookback", minval = 1, maxval = 10, group = groupMomentum, tooltip = "How many bars back RSI is compared to detect momentum turning.", display = display.none)
buyRsiMax = input.float(58.0, "Bullish RSI Max After Flip", minval = 1.0, maxval = 100.0, step = 1.0, group = groupMomentum, tooltip = "Maximum RSI allowed after a bullish flip. Helps avoid entering after momentum is already too extended upward.", display = display.none)
sellRsiMin = input.float(42.0, "Bearish RSI Min After Flip", minval = 1.0, maxval = 100.0, step = 1.0, group = groupMomentum, tooltip = "Minimum RSI allowed after a bearish flip. Helps avoid entering after momentum is already too extended downward.", display = display.none)

groupTrade = "🎯 05. Target / Risk Result Engine"
showTradeBoxes = input.bool(true, "Show Target / Risk Boxes", group = groupTrade, tooltip = "Displays modern target and risk boxes after each confirmed signal.", display = display.none)
showTradeLines = input.bool(true, "Show Entry / Risk / Target Lines", group = groupTrade, tooltip = "Displays compact entry, risk and target lines inside the trade box structure.", display = display.none)
showOnlyLastTradePlan = input.bool(false, "Show Only Last Trade Plan", group = groupTrade, tooltip = "When enabled, older trade boxes are removed and only the most recent trade plan remains visible.", display = display.none)
keepHistoricalTradeBoxes = input.bool(true, "Keep Historical Target / Risk Boxes", group = groupTrade, tooltip = "Keeps previous trade boxes on the chart after target or risk is reached.", display = display.none)
maxHistoricalTradePlans = input.int(25, "Max Historical Trade Plans", minval = 1, maxval = 100, group = groupTrade, tooltip = "Maximum number of historical trade plans kept on the chart. Lower this if the chart becomes too crowded.", display = display.none)
trackTradeResults = input.bool(true, "Track Win / Loss Result", group = groupTrade, tooltip = "Tracks whether each signal reaches target or risk first and prints WIN / LOSS result stamps.", display = display.none)
rrTarget = input.float(2.0, "Default Target Risk Reward", minval = 0.10, maxval = 20.0, step = 0.10, group = groupTrade, tooltip = "Default target RR used before the optimizer has enough data to select the best RR automatically.", display = display.none)
slMode = input.string("ATR", "Risk Mode", options = ["Signal Wick", "ATR", "Hybrid"], group = groupTrade, tooltip = "Signal Wick uses the trigger wick for risk. ATR uses ATR x4. Hybrid uses the wider of wick and ATR risk.", display = display.none)
atrLength = input.int(14, "ATR Length", minval = 1, maxval = 200, group = groupTrade, tooltip = "ATR length used for the fixed ATR x4 risk calculation.", display = display.none)
slBufferTicks = input.int(2, "Risk Buffer Ticks", minval = 0, maxval = 100, group = groupTrade, tooltip = "Small tick buffer added beyond the signal wick when wick or hybrid risk mode is used.", display = display.none)
tradeBoxExtendBars = input.int(40, "Trade Box Extend Bars", minval = 1, maxval = 300, group = groupTrade, tooltip = "How far the active trade box extends to the right while the trade is open.", display = display.none)
sameBarResult = input.string("SL First", "If Target and Risk Hit Same Bar", options = ["SL First", "TP First"], group = groupTrade, tooltip = "Determines the result assumption if target and risk are touched on the same candle.", display = display.none)
maxResultLabels = input.int(80, "Max Result Stamps", minval = 10, maxval = 250, group = groupTrade, tooltip = "Limits how many WIN / LOSS result stamps remain visible on the chart.", display = display.none)

groupOptimizer = "🧠 06. Background Optimizer"
useOptimizer = input.bool(true, "Use Background Optimizer", group = groupOptimizer, tooltip = "Runs a controlled internal grid test in the background to find the strongest parameter combination.", display = display.none)
useAutoBestCombo = input.bool(true, "Auto Use Best Optimizer Combo", group = groupOptimizer, tooltip = "When enough optimizer trades are collected, the live signal engine automatically uses the best combination.", display = display.none)
optimizerDepth = input.string("Full 81", "Optimizer Grid Depth", options = ["Light 27", "Full 81"], group = groupOptimizer, tooltip = "Light 27 tests fewer combinations. Full 81 also tests multiple RR values for a deeper optimization.", display = display.none)
optimizerRankMode = input.string("Wins First", "Best Combination Ranking", options = ["Wins First", "Win Rate First"], group = groupOptimizer, tooltip = "Wins First prioritizes the highest number of winning trades. Win Rate First prioritizes percentage accuracy.", display = display.none)
optimizerMinTrades = input.int(10, "Minimum Trades For Best Combo", minval = 1, maxval = 500, group = groupOptimizer, tooltip = "Minimum closed virtual trades required before a combination can become the Auto Best setup.", display = display.none)

groupVisual = "🎨 07. Visual Pro Design"
visualTheme = input.string("Midnight Pro", "Visual Theme", options = ["Midnight Pro", "Ice Minimal", "Black Gold", "Red Carbon"], group = groupVisual, tooltip = "Changes the full visual palette of signal labels, risk boxes, target boxes and result stamps.", display = display.none)
visualIntensity = input.string("Balanced", "Visual Intensity", options = ["Minimal", "Balanced", "Showcase"], group = groupVisual, tooltip = "Controls the strength of borders, glow and visual emphasis.", display = display.none)
labelSizeInput = input.string("Small", "Signal / Result Label Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupVisual, tooltip = "Controls the size of the main BULLISH / BEARISH labels, result stamps and compact price tags.", display = display.none)
boxTransparency = input.int(84, "Target / Risk Box Transparency", minval = 0, maxval = 100, group = groupVisual, tooltip = "Controls how transparent the target and risk boxes are. Higher values are more subtle.", display = display.none)
showSignalGlow = input.bool(true, "Show Signal Glow", group = groupVisual, tooltip = "Adds a subtle one-bar glow around the confirmed signal candle.", display = display.none)
showResultStamps = input.bool(true, "Show WIN / LOSS Stamps", group = groupVisual, tooltip = "Shows premium result stamps when a trade reaches target or risk.", display = display.none)
showPriceTags = input.bool(true, "Show Compact Price Tags", group = groupVisual, tooltip = "Shows compact ENTRY, TARGET and RISK tags at the right side of the trade plan.", display = display.none)
candleHighlightMode = input.string("Signal Only", "Candle Highlight Mode", options = ["Off", "Signal Only", "Signal + Result"], group = groupVisual, tooltip = "Controls whether signal candles and result candles are softly highlighted.", display = display.none)
maxGlowObjects = input.int(80, "Max Signal Glow Objects", minval = 10, maxval = 250, group = groupVisual, tooltip = "Maximum number of historical signal glow objects kept on the chart.", display = display.none)

groupDashboard = "📟 08. Mini Dashboard"
showDashboard = input.bool(true, "Show Mini Dashboard", group = groupDashboard, tooltip = "Shows a small, clean dashboard with live state, Auto Best status, active direction and result summary.", display = display.none)
dashboardPosition = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = groupDashboard, tooltip = "Controls where the mini dashboard is displayed on the chart.", display = display.none)
dashboardTextSize = input.string("Tiny", "Dashboard Text Size", options = ["Tiny", "Small", "Normal"], group = groupDashboard, tooltip = "Controls the text size of the mini dashboard. Tiny keeps the dashboard compact and clean.", display = display.none)
dashboardTransparency = input.int(12, "Dashboard Background Transparency", minval = 0, maxval = 90, group = groupDashboard, tooltip = "Controls dashboard background transparency. Higher values make the panel more transparent.", display = display.none)

groupAlerts = "🚨 09. Professional Alerts"
enableProfessionalAlerts = input.bool(true, "Enable Dynamic Alerts", group = groupAlerts, tooltip = "Enables dynamic alert() messages with symbol, timeframe, direction, entry, risk, target and result information.", display = display.none)
alertBullishFlips = input.bool(true, "Alert Bullish Flips", group = groupAlerts, tooltip = "Sends an alert when a BULLISH FLIP signal is confirmed.", display = display.none)
alertBearishFlips = input.bool(true, "Alert Bearish Flips", group = groupAlerts, tooltip = "Sends an alert when a BEARISH FLIP signal is confirmed.", display = display.none)
alertTradeResults = input.bool(true, "Alert Trade Results", group = groupAlerts, tooltip = "Sends an alert when an active trade reaches target or risk.", display = display.none)
alertPayloadFormat = input.string("Human", "Alert Payload Format", options = ["Human", "JSON"], group = groupAlerts, tooltip = "Human creates readable alerts. JSON creates automation-friendly payloads for webhooks.", display = display.none)
alertIncludePrices = input.bool(true, "Include Entry / Risk / Target", group = groupAlerts, tooltip = "Includes entry, risk and target prices inside dynamic alert messages.", display = display.none)
alertIncludeAutoBest = input.bool(true, "Include Auto Best State", group = groupAlerts, tooltip = "Includes whether Auto Best optimizer mode is active or still waiting.", display = display.none)
alertTag = input.string("Candle Pressure Flip Engine", "Alert Tag", group = groupAlerts, tooltip = "Custom tag used at the start of alert messages and inside JSON payloads.", display = display.none)

groupSpine = "🩸 10. Crimson Spine + Echo"
showCrimsonSpine = input.bool(true, "Show Crimson Spine System", group = groupSpine, tooltip = "Shows the premium Spine + Echo + Fill system: one central red spine, symmetrical echo lines and soft crimson fill clouds around price.", display = display.none)
spineSource = input.source(close, "Spine Source", group = groupSpine, tooltip = "Price source used by the central Crimson Spine.", display = display.none)
spineLength = input.int(8, "Spine EMA Length", minval = 1, maxval = 200, group = groupSpine, tooltip = "Central EMA length. Lower values track price more tightly; higher values create a smoother spine.", display = display.none)
spineEchoSpacingAtr = input.float(0.045, "Echo Spacing ATR", minval = 0.005, maxval = 1.0, step = 0.005, group = groupSpine, tooltip = "Distance between echo layers, measured as ATR fraction. Smaller values keep the ribbon very tight around price.", display = display.none)
spineAdaptiveSpread = input.bool(true, "Adaptive Echo Spread", group = groupSpine, tooltip = "Expands the echo cloud slightly when pressure intensity increases and compresses it when pressure is neutral.", display = display.none)
spineLineWidth = input.int(2, "Spine Line Width", minval = 1, maxval = 5, group = groupSpine, tooltip = "Thickness of the main spine and echo lines.", display = display.none)
spineTransparencyStart = input.int(0, "Core Line Transparency", minval = 0, maxval = 95, group = groupSpine, tooltip = "Transparency of the center spine line. Lower values are more visible.", display = display.none)
spineTransparencyStep = input.int(10, "Echo Transparency Step", minval = 0, maxval = 20, group = groupSpine, tooltip = "Each outer echo layer becomes more transparent by this amount.", display = display.none)
spineFillTransparency = input.int(86, "Crimson Fill Transparency", minval = 0, maxval = 100, group = groupSpine, tooltip = "Transparency of the red cloud fill between echo layers. Higher values are more subtle.", display = display.none)
spinePulseEffect = input.bool(true, "Spine Pulse Effect", group = groupSpine, tooltip = "Adds a subtle pulsing glow to the spine and echo layers for a more premium live feel.", display = display.none)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CONSTANTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

float atrMultiplier = 4.0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HELPER FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_clamp(_value, _min, _max) =>
    math.max(_min, math.min(_value, _max))

f_labelSize(_size) =>
    _size == "Tiny" ? size.tiny : _size == "Small" ? size.small : _size == "Normal" ? size.normal : _size == "Large" ? size.large : size.huge

f_dashboardTextSize(_size) =>
    _size == "Tiny" ? size.tiny : _size == "Small" ? size.small : size.normal

f_dashboardPosition(_pos) =>
    _pos == "Top Left" ? position.top_left : _pos == "Bottom Right" ? position.bottom_right : _pos == "Bottom Left" ? position.bottom_left : position.top_right

f_dashboardBaseBg() =>
    visualTheme == "Ice Minimal" ? color.rgb(10, 24, 32) : visualTheme == "Black Gold" ? color.rgb(20, 17, 10) : visualTheme == "Red Carbon" ? color.rgb(18, 10, 12) : color.rgb(8, 11, 18)

f_dashboardHeaderBg() =>
    visualTheme == "Ice Minimal" ? color.rgb(30, 120, 150) : visualTheme == "Black Gold" ? color.rgb(165, 125, 45) : visualTheme == "Red Carbon" ? color.rgb(155, 20, 35) : color.rgb(125, 15, 35)

f_dashboardFrameColor() =>
    visualTheme == "Ice Minimal" ? color.rgb(105, 205, 235) : visualTheme == "Black Gold" ? color.rgb(230, 190, 90) : visualTheme == "Red Carbon" ? color.rgb(235, 55, 55) : color.rgb(225, 45, 65)

f_modeMoveMultiplier() =>
    signalMode == "Aggressive" ? 0.85 : signalMode == "Conservative" ? 1.25 : 1.00

f_modeWickAdjustment() =>
    signalMode == "Aggressive" ? -8.0 : signalMode == "Conservative" ? 8.0 : 0.0

f_modeScoreAdjustment() =>
    signalMode == "Aggressive" ? -8.0 : signalMode == "Conservative" ? 8.0 : 0.0

f_sideText(_dir) =>
    _dir == 1 ? "BULLISH" : _dir == -1 ? "BEARISH" : "NONE"

f_resultText(_isTp) =>
    _isTp ? "TP" : "SL"

f_buyColor() =>
    visualTheme == "Ice Minimal" ? color.rgb(70, 190, 220) : visualTheme == "Black Gold" ? color.rgb(230, 190, 90) : visualTheme == "Red Carbon" ? color.rgb(70, 210, 230) : color.rgb(0, 205, 230)

f_sellColor() =>
    visualTheme == "Ice Minimal" ? color.rgb(165, 140, 245) : visualTheme == "Black Gold" ? color.rgb(145, 115, 210) : visualTheme == "Red Carbon" ? color.rgb(195, 90, 240) : color.rgb(155, 115, 255)

f_neutralColor() =>
    visualTheme == "Ice Minimal" ? color.rgb(185, 205, 220) : visualTheme == "Black Gold" ? color.rgb(210, 185, 120) : visualTheme == "Red Carbon" ? color.rgb(150, 155, 170) : color.rgb(150, 165, 185)

f_targetColor() =>
    visualTheme == "Ice Minimal" ? color.rgb(35, 170, 230) : visualTheme == "Black Gold" ? color.rgb(60, 180, 240) : visualTheme == "Red Carbon" ? color.rgb(0, 190, 240) : color.rgb(0, 210, 255)

f_riskColor() =>
    visualTheme == "Ice Minimal" ? color.rgb(245, 145, 60) : visualTheme == "Black Gold" ? color.rgb(255, 170, 45) : visualTheme == "Red Carbon" ? color.rgb(255, 95, 45) : color.rgb(255, 155, 45)

f_glowTransparency() =>
    visualIntensity == "Minimal" ? 88 : visualIntensity == "Showcase" ? 72 : 80

f_lineWidth() =>
    visualIntensity == "Showcase" ? 2 : 1

f_resultLabelSize() =>
    f_labelSize(labelSizeInput)

f_spineColor(_layer) =>
    int pulseShift = spinePulseEffect and bar_index % 2 == 0 ? -7 : 0
    int alpha = f_clamp(spineTransparencyStart + _layer * spineTransparencyStep + pulseShift, 0, 95)
    _layer == 0 ? color.new(color.rgb(255, 0, 35), alpha) : _layer == 1 ? color.new(color.rgb(220, 0, 32), alpha) : _layer == 2 ? color.new(color.rgb(185, 0, 28), alpha) : _layer == 3 ? color.new(color.rgb(145, 0, 24), alpha) : color.new(color.rgb(105, 0, 20), alpha)

f_spineFillColor(_layer) =>
    int pulseShift = spinePulseEffect and bar_index % 2 == 0 ? -4 : 0
    int alpha = f_clamp(spineFillTransparency + _layer * 3 + pulseShift, 0, 100)
    _layer == 1 ? color.new(color.rgb(255, 0, 35), alpha) : _layer == 2 ? color.new(color.rgb(190, 0, 28), alpha) : color.new(color.rgb(120, 0, 22), alpha)

f_priceText(_price) =>
    str.tostring(_price, format.mintick)

f_timeframeText() =>
    timeframe.period

f_autoBestText(_ready) =>
    _ready ? "ON" : "WAIT"

f_signalAlertMessage(_dir, _score, _entry, _risk, _target, _rr, _autoReady) =>
    string direction = f_sideText(_dir)
    string eventName = direction + "_FLIP"
    string pricePart = alertIncludePrices ? " | Entry " + f_priceText(_entry) + " | Risk " + f_priceText(_risk) + " | Target " + f_priceText(_target) : ""
    string autoPart = alertIncludeAutoBest ? " | Auto Best " + f_autoBestText(_autoReady) : ""
    string humanMsg = alertTag + " | " + direction + " FLIP confirmed | " + syminfo.ticker + " | TF " + f_timeframeText() + " | Score " + str.tostring(_score, "#.##") + " | RR " + str.tostring(_rr, "#.##") + pricePart + autoPart
    string jsonMsg = '{"tag":"' + alertTag + '","event":"' + eventName + '","symbol":"' + syminfo.ticker + '","timeframe":"' + f_timeframeText() + '","direction":"' + direction + '","score":' + str.tostring(_score, "#.##") + ',"entry":' + f_priceText(_entry) + ',"risk":' + f_priceText(_risk) + ',"target":' + f_priceText(_target) + ',"rr":' + str.tostring(_rr, "#.##") + ',"auto_best":"' + f_autoBestText(_autoReady) + '"}'
    alertPayloadFormat == "JSON" ? jsonMsg : humanMsg

f_resultAlertMessage(_isTp, _entry, _risk, _target, _rr, _netR) =>
    string eventName = _isTp ? "WIN_TARGET_HIT" : "LOSS_RISK_HIT"
    string resultText = _isTp ? "WIN | TARGET HIT" : "LOSS | RISK HIT"
    string pricePart = alertIncludePrices ? " | Entry " + f_priceText(_entry) + " | Risk " + f_priceText(_risk) + " | Target " + f_priceText(_target) : ""
    string humanMsg = alertTag + " | " + resultText + " | " + syminfo.ticker + " | TF " + f_timeframeText() + " | RR " + str.tostring(_rr, "#.##") + " | Net R " + str.tostring(_netR, "#.##") + pricePart
    string jsonMsg = '{"tag":"' + alertTag + '","event":"' + eventName + '","symbol":"' + syminfo.ticker + '","timeframe":"' + f_timeframeText() + '","result":"' + resultText + '","entry":' + f_priceText(_entry) + ',"risk":' + f_priceText(_risk) + ',"target":' + f_priceText(_target) + ',"rr":' + str.tostring(_rr, "#.##") + ',"net_r":' + str.tostring(_netR, "#.##") + '}'
    alertPayloadFormat == "JSON" ? jsonMsg : humanMsg

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CORE DATA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

float atr = ta.atr(atrLength)
float avgVolume = ta.sma(volume, volumeLength)
float volumeMultiplier = not na(avgVolume) and avgVolume > 0.0 ? volume / avgVolume : 1.0
float rsi = ta.rsi(close, rsiLength)

float candleRange = high - low
float bodySize = math.abs(close - open)
float bodyPct = candleRange > 0.0 ? bodySize / candleRange * 100.0 : 0.0
float lowerWick = math.min(open, close) - low
float upperWick = high - math.max(open, close)
float lowerWickPct = candleRange > 0.0 ? lowerWick / candleRange * 100.0 : 0.0
float upperWickPct = candleRange > 0.0 ? upperWick / candleRange * 100.0 : 0.0
float closePosition = candleRange > 0.0 ? (close - low) / candleRange * 100.0 : 50.0

bool enoughBars = bar_index > exhaustionLookback + rsiTurnLookback + 2 and not na(atr)

int bullishDirectionalBars = 0
int bearishDirectionalBars = 0

if enoughBars
    for j = 0 to exhaustionLookback - 1
        bullishDirectionalBars += close[j] > close[j + 1] ? 1 : 0
        bearishDirectionalBars += close[j] < close[j + 1] ? 1 : 0

float moveDistance = enoughBars ? math.abs(close - close[exhaustionLookback]) : 0.0
float moveAtr = atr > 0.0 ? moveDistance / atr : 0.0
float requiredMoveAtr = minMoveAtr * f_modeMoveMultiplier()
float requiredWickPct = f_clamp(minRejectionWickPct + f_modeWickAdjustment(), 5.0, 95.0)
float requiredSignalScore = f_clamp(minSignalScore + f_modeScoreAdjustment(), 5.0, 100.0)
bool volumeOk = not useVolumeBurst or volumeMultiplier >= minVolumeMultiplier
bool buyMomentumOk = not useMomentumFlip or (rsi > rsi[rsiTurnLookback] and rsi <= buyRsiMax)
bool sellMomentumOk = not useMomentumFlip or (rsi < rsi[rsiTurnLookback] and rsi >= sellRsiMin)

f_buyScore(_reqMoveAtr, _reqWickPct) =>
    float exhaustionScore = f_clamp((moveAtr / math.max(_reqMoveAtr, 0.10)) * 25.0, 0.0, 25.0)
    float directionScore = f_clamp((bearishDirectionalBars / math.max(exhaustionLookback, 1)) * 10.0, 0.0, 10.0)
    float wickScore = f_clamp((lowerWickPct / math.max(_reqWickPct, 1.0)) * 20.0, 0.0, 20.0)
    float closeScore = f_clamp((closePosition / math.max(closePressurePct, 1.0)) * 15.0, 0.0, 15.0)
    float bScore = f_clamp((bodyPct / math.max(minBodyPct, 1.0)) * 10.0, 0.0, 10.0)
    float vScore = volumeOk ? 10.0 : 0.0
    float mScore = buyMomentumOk ? 10.0 : 0.0
    exhaustionScore + directionScore + wickScore + closeScore + bScore + vScore + mScore

f_sellScore(_reqMoveAtr, _reqWickPct) =>
    float exhaustionScore = f_clamp((moveAtr / math.max(_reqMoveAtr, 0.10)) * 25.0, 0.0, 25.0)
    float directionScore = f_clamp((bullishDirectionalBars / math.max(exhaustionLookback, 1)) * 10.0, 0.0, 10.0)
    float wickScore = f_clamp((upperWickPct / math.max(_reqWickPct, 1.0)) * 20.0, 0.0, 20.0)
    float closeScore = f_clamp(((100.0 - closePosition) / math.max(closePressurePct, 1.0)) * 15.0, 0.0, 15.0)
    float bScore = f_clamp((bodyPct / math.max(minBodyPct, 1.0)) * 10.0, 0.0, 10.0)
    float vScore = volumeOk ? 10.0 : 0.0
    float mScore = sellMomentumOk ? 10.0 : 0.0
    exhaustionScore + directionScore + wickScore + closeScore + bScore + vScore + mScore

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STATE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var bool tradeActive = false
var int tradeDir = 0
var float tradeEntry = na
var float tradeSl = na
var float tradeTp = na
var float tradeRr = na
var int tradeStartBar = na
var int lastSignalBar = na
var string lastResult = "N/A"
var int lastSignalDir = 0
var float lastSignalScore = na
var int completedTrades = 0
var int winTrades = 0
var int lossTrades = 0
var float netR = 0.0
var float grossWinR = 0.0
var float grossLossR = 0.0
var box tpBox = na
var box slBox = na
var line entryLine = na
var line slLine = na
var line tpLine = na
var label entryTag = na
var label slTag = na
var label tpTag = na
var array<label> signalLabels = array.new_label()
var array<label> resultLabels = array.new_label()
var array<box> historicalTradeBoxes = array.new_box()
var array<line> historicalTradeLines = array.new_line()
var array<label> historicalPriceTags = array.new_label()
var array<box> glowBoxes = array.new_box()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OPTIMIZER ARRAYS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var array<float> optMoveAtrs = array.new_float()
var array<float> optWickPcts = array.new_float()
var array<float> optScores = array.new_float()
var array<float> optRrs = array.new_float()
var array<bool> optActive = array.new_bool()
var array<int> optDirs = array.new_int()
var array<float> optEntries = array.new_float()
var array<float> optSls = array.new_float()
var array<float> optTps = array.new_float()
var array<int> optStartBars = array.new_int()
var array<int> optLastSignalBars = array.new_int()
var array<int> optWins = array.new_int()
var array<int> optLosses = array.new_int()
var float bestOptMoveAtr = na
var float bestOptWickPct = na
var float bestOptScoreReq = na
var float bestOptRr = na

if barstate.isfirst
    int rrLoopCount = optimizerDepth == "Full 81" ? 3 : 1
    for mi = 0 to 2
        float moveValue = mi == 0 ? 0.90 : mi == 1 ? 1.20 : 1.50
        for wi = 0 to 2
            float wickValue = wi == 0 ? 28.0 : wi == 1 ? 35.0 : 42.0
            for si = 0 to 2
                float scoreValue = si == 0 ? 55.0 : si == 1 ? 62.0 : 70.0
                for ri = 0 to rrLoopCount - 1
                    float rrValue = optimizerDepth == "Full 81" ? (ri == 0 ? 1.50 : ri == 1 ? 2.00 : 2.50) : rrTarget
                    array.push(optMoveAtrs, moveValue)
                    array.push(optWickPcts, wickValue)
                    array.push(optScores, scoreValue)
                    array.push(optRrs, rrValue)
                    array.push(optActive, false)
                    array.push(optDirs, 0)
                    array.push(optEntries, na)
                    array.push(optSls, na)
                    array.push(optTps, na)
                    array.push(optStartBars, na)
                    array.push(optLastSignalBars, na)
                    array.push(optWins, 0)
                    array.push(optLosses, 0)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BACKGROUND OPTIMIZER ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if barstate.isconfirmed and useOptimizer and enoughBars
    int comboCount = array.size(optMoveAtrs)
    if comboCount > 0
        for i = 0 to comboCount - 1
            bool isActive = array.get(optActive, i)
            int oDir = array.get(optDirs, i)
            float oSl = array.get(optSls, i)
            float oTp = array.get(optTps, i)
            int oStart = array.get(optStartBars, i)
            if isActive and bar_index > oStart
                bool oHitTp = oDir == 1 ? high >= oTp : low <= oTp
                bool oHitSl = oDir == 1 ? low <= oSl : high >= oSl
                bool oHit = oHitTp or oHitSl
                bool oTpFirst = oHitTp and oHitSl ? sameBarResult == "TP First" : oHitTp
                if oHit
                    array.set(optActive, i, false)
                    array.set(optDirs, i, 0)
                    if oTpFirst
                        array.set(optWins, i, array.get(optWins, i) + 1)
                    else
                        array.set(optLosses, i, array.get(optLosses, i) + 1)
            bool stillActive = array.get(optActive, i)
            if not stillActive
                float reqMove = array.get(optMoveAtrs, i)
                float reqWick = array.get(optWickPcts, i)
                float reqScore = array.get(optScores, i)
                float reqRr = array.get(optRrs, i)
                int oLastSig = array.get(optLastSignalBars, i)
                bool oCooldownOk = na(oLastSig) or bar_index - oLastSig >= signalCooldownBars
                bool oBearishExhaustion = close < close[exhaustionLookback] and moveAtr >= reqMove and bearishDirectionalBars >= minDirectionalBars
                bool oBullishExhaustion = close > close[exhaustionLookback] and moveAtr >= reqMove and bullishDirectionalBars >= minDirectionalBars
                bool oBuyRejection = lowerWickPct >= reqWick and closePosition >= closePressurePct and close > open and bodyPct >= minBodyPct
                bool oSellRejection = upperWickPct >= reqWick and closePosition <= 100.0 - closePressurePct and close < open and bodyPct >= minBodyPct
                float oBuyScore = f_buyScore(reqMove, reqWick)
                float oSellScore = f_sellScore(reqMove, reqWick)
                bool oBuySignal = oBearishExhaustion and oBuyRejection and volumeOk and buyMomentumOk and oBuyScore >= reqScore and oCooldownOk and oBuyScore >= oSellScore
                bool oSellSignal = oBullishExhaustion and oSellRejection and volumeOk and sellMomentumOk and oSellScore >= reqScore and oCooldownOk and oSellScore > oBuyScore
                if oBuySignal or oSellSignal
                    int newOptDir = oBuySignal ? 1 : -1
                    float buffer = slBufferTicks * syminfo.mintick
                    float entry = close
                    float wickSl = newOptDir == 1 ? low - buffer : high + buffer
                    float atrSl = newOptDir == 1 ? entry - atr * atrMultiplier : entry + atr * atrMultiplier
                    float sl = slMode == "Signal Wick" ? wickSl : slMode == "ATR" ? atrSl : newOptDir == 1 ? math.min(wickSl, atrSl) : math.max(wickSl, atrSl)
                    float risk = math.abs(entry - sl)
                    if risk > syminfo.mintick
                        float tp = entry + newOptDir * risk * reqRr
                        array.set(optActive, i, true)
                        array.set(optDirs, i, newOptDir)
                        array.set(optEntries, i, entry)
                        array.set(optSls, i, sl)
                        array.set(optTps, i, tp)
                        array.set(optStartBars, i, bar_index)
                        array.set(optLastSignalBars, i, bar_index)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BEST OPTIMIZER COMBINATION SELECTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bestOptMoveAtr := na
bestOptWickPct := na
bestOptScoreReq := na
bestOptRr := na
if useOptimizer
    int bestIdxRuntime = -1
    float bestPrimaryRuntime = -1.0
    float bestSecondaryRuntime = -1.0
    int comboCountRuntime = array.size(optMoveAtrs)
    if comboCountRuntime > 0
        for i = 0 to comboCountRuntime - 1
            int w = array.get(optWins, i)
            int l = array.get(optLosses, i)
            int t = w + l
            float wr = t > 0 ? w / t * 100.0 : 0.0
            bool eligible = t >= optimizerMinTrades
            float primary = optimizerRankMode == "Wins First" ? w : wr
            float secondary = optimizerRankMode == "Wins First" ? wr : w
            if eligible and (primary > bestPrimaryRuntime or (primary == bestPrimaryRuntime and secondary > bestSecondaryRuntime))
                bestIdxRuntime := i
                bestPrimaryRuntime := primary
                bestSecondaryRuntime := secondary
    if bestIdxRuntime >= 0
        bestOptMoveAtr := array.get(optMoveAtrs, bestIdxRuntime)
        bestOptWickPct := array.get(optWickPcts, bestIdxRuntime)
        bestOptScoreReq := array.get(optScores, bestIdxRuntime)
        bestOptRr := array.get(optRrs, bestIdxRuntime)

bool autoComboReady = useOptimizer and useAutoBestCombo and not na(bestOptMoveAtr) and not na(bestOptWickPct) and not na(bestOptScoreReq) and not na(bestOptRr)
float selectedMoveAtr = autoComboReady ? bestOptMoveAtr : requiredMoveAtr
float selectedWickPct = autoComboReady ? bestOptWickPct : requiredWickPct
float selectedScoreReq = autoComboReady ? bestOptScoreReq : requiredSignalScore
float selectedRrTarget = autoComboReady ? bestOptRr : rrTarget

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// REAL SIGNAL CONDITIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bool cooldownOk = na(lastSignalBar) or bar_index - lastSignalBar >= signalCooldownBars
bool tradeGateOk = not oneTradeAtATime or not tradeActive
bool selectedBullishExhaustion = enoughBars and close > close[exhaustionLookback] and moveAtr >= selectedMoveAtr and bullishDirectionalBars >= minDirectionalBars
bool selectedBearishExhaustion = enoughBars and close < close[exhaustionLookback] and moveAtr >= selectedMoveAtr and bearishDirectionalBars >= minDirectionalBars
bool selectedBuyRejection = lowerWickPct >= selectedWickPct and closePosition >= closePressurePct and close > open and bodyPct >= minBodyPct
bool selectedSellRejection = upperWickPct >= selectedWickPct and closePosition <= 100.0 - closePressurePct and close < open and bodyPct >= minBodyPct
float selectedBuySignalScore = f_buyScore(selectedMoveAtr, selectedWickPct)
float selectedSellSignalScore = f_sellScore(selectedMoveAtr, selectedWickPct)
bool rawBuySignal = selectedBearishExhaustion and selectedBuyRejection and volumeOk and buyMomentumOk and selectedBuySignalScore >= selectedScoreReq
bool rawSellSignal = selectedBullishExhaustion and selectedSellRejection and volumeOk and sellMomentumOk and selectedSellSignalScore >= selectedScoreReq
bool buySignal = barstate.isconfirmed and rawBuySignal and cooldownOk and tradeGateOk and selectedBuySignalScore >= selectedSellSignalScore
bool sellSignal = barstate.isconfirmed and rawSellSignal and cooldownOk and tradeGateOk and selectedSellSignalScore > selectedBuySignalScore
bool buySignalEvent = false
bool sellSignalEvent = false
bool tpResultEvent = false
bool slResultEvent = false
bool resultBarEvent = false
int resultBarDir = 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// REAL SIGNAL EXECUTION + TRADE PLAN
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if buySignal or sellSignal
    int newDir = buySignal ? 1 : -1
    float newScore = buySignal ? selectedBuySignalScore : selectedSellSignalScore
    float buffer = slBufferTicks * syminfo.mintick
    float entry = close
    float wickSl = newDir == 1 ? low - buffer : high + buffer
    float atrSl = newDir == 1 ? entry - atr * atrMultiplier : entry + atr * atrMultiplier
    float sl = na
    if slMode == "Signal Wick"
        sl := wickSl
    else if slMode == "ATR"
        sl := atrSl
    else
        sl := newDir == 1 ? math.min(wickSl, atrSl) : math.max(wickSl, atrSl)
    float risk = math.abs(entry - sl)
    if risk > syminfo.mintick
        float tp = entry + newDir * risk * selectedRrTarget
        if showOnlyLastTradePlan or not keepHistoricalTradeBoxes
            if not na(tpBox)
                box.delete(tpBox)
            if not na(slBox)
                box.delete(slBox)
            if not na(entryLine)
                line.delete(entryLine)
            if not na(slLine)
                line.delete(slLine)
            if not na(tpLine)
                line.delete(tpLine)
            if not na(entryTag)
                label.delete(entryTag)
            if not na(slTag)
                label.delete(slTag)
            if not na(tpTag)
                label.delete(tpTag)
        tradeActive := true
        tradeDir := newDir
        tradeEntry := entry
        tradeSl := sl
        tradeTp := tp
        tradeRr := selectedRrTarget
        tradeStartBar := bar_index
        lastSignalBar := bar_index
        lastSignalDir := newDir
        lastSignalScore := newScore
        buySignalEvent := newDir == 1
        sellSignalEvent := newDir == -1
        color sideColor = newDir == 1 ? f_buyColor() : f_sellColor()
        if showSignalGlow
            box glow = box.new(left = bar_index, top = high + atr * 0.20, right = bar_index + 1, bottom = low - atr * 0.20, xloc = xloc.bar_index, bgcolor = color.new(sideColor, f_glowTransparency()), border_color = color.new(sideColor, 35), border_width = visualIntensity == "Showcase" ? 2 : 1)
            array.push(glowBoxes, glow)
            while array.size(glowBoxes) > maxGlowObjects
                box oldGlow = array.shift(glowBoxes)
                if not na(oldGlow)
                    box.delete(oldGlow)
        if showTradeBoxes
            float tpTop = newDir == 1 ? tp : entry
            float tpBottom = newDir == 1 ? entry : tp
            float slTop = newDir == 1 ? entry : sl
            float slBottom = newDir == 1 ? sl : entry
            tpBox := box.new(left = bar_index, top = tpTop, right = bar_index + tradeBoxExtendBars, bottom = tpBottom, xloc = xloc.bar_index, bgcolor = color.new(f_targetColor(), boxTransparency), border_color = color.new(f_targetColor(), 10), border_width = f_lineWidth())
            slBox := box.new(left = bar_index, top = slTop, right = bar_index + tradeBoxExtendBars, bottom = slBottom, xloc = xloc.bar_index, bgcolor = color.new(f_riskColor(), boxTransparency), border_color = color.new(f_riskColor(), 10), border_width = f_lineWidth())
            if keepHistoricalTradeBoxes
                array.push(historicalTradeBoxes, tpBox)
                array.push(historicalTradeBoxes, slBox)
                while array.size(historicalTradeBoxes) > maxHistoricalTradePlans * 2
                    box oldBox = array.shift(historicalTradeBoxes)
                    if not na(oldBox)
                        box.delete(oldBox)
        if showTradeLines
            entryLine := line.new(x1 = bar_index, y1 = entry, x2 = bar_index + tradeBoxExtendBars, y2 = entry, xloc = xloc.bar_index, extend = extend.none, color = color.new(f_neutralColor(), 0), style = line.style_solid, width = f_lineWidth())
            slLine := line.new(x1 = bar_index, y1 = sl, x2 = bar_index + tradeBoxExtendBars, y2 = sl, xloc = xloc.bar_index, extend = extend.none, color = color.new(f_riskColor(), 0), style = line.style_solid, width = f_lineWidth())
            tpLine := line.new(x1 = bar_index, y1 = tp, x2 = bar_index + tradeBoxExtendBars, y2 = tp, xloc = xloc.bar_index, extend = extend.none, color = color.new(f_targetColor(), 0), style = line.style_solid, width = f_lineWidth())
            if keepHistoricalTradeBoxes
                array.push(historicalTradeLines, entryLine)
                array.push(historicalTradeLines, slLine)
                array.push(historicalTradeLines, tpLine)
                while array.size(historicalTradeLines) > maxHistoricalTradePlans * 3
                    line oldLine = array.shift(historicalTradeLines)
                    if not na(oldLine)
                        line.delete(oldLine)
        if showPriceTags
            int tagX = bar_index + tradeBoxExtendBars
            entryTag := label.new(x = tagX, y = entry, text = "ENTRY ZONE", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(color.black, 0), textcolor = f_neutralColor(), size = f_labelSize(labelSizeInput), text_formatting = text.format_bold + text.format_italic)
            tpTag := label.new(x = tagX, y = tp, text = "TARGET ZONE", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(f_targetColor(), 10), textcolor = color.white, size = f_labelSize(labelSizeInput), text_formatting = text.format_bold + text.format_italic)
            slTag := label.new(x = tagX, y = sl, text = "RISK ZONE", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(f_riskColor(), 10), textcolor = color.white, size = f_labelSize(labelSizeInput), text_formatting = text.format_bold + text.format_italic)
            if keepHistoricalTradeBoxes
                array.push(historicalPriceTags, entryTag)
                array.push(historicalPriceTags, tpTag)
                array.push(historicalPriceTags, slTag)
                while array.size(historicalPriceTags) > maxHistoricalTradePlans * 3
                    label oldTag = array.shift(historicalPriceTags)
                    if not na(oldTag)
                        label.delete(oldTag)
        if showBullBearLabels
            float labelY = newDir == 1 ? low - atr * 0.45 : high + atr * 0.45
            string labelText = newDir == 1 ? "BULLISH FLIP ▲" : "BEARISH FLIP ▼"
            labelStyle = newDir == 1 ? label.style_label_up : label.style_label_down
            string sigTip = "Direction " + f_sideText(newDir) + " | Score " + str.tostring(newScore, "#.##") + " | Auto Best " + (autoComboReady ? "ON" : "WAIT") + " | Risk ATR x4 | Target RR " + str.tostring(selectedRrTarget, "#.##")
            label sigLb = label.new(x = bar_index, y = labelY, text = labelText, xloc = xloc.bar_index, yloc = yloc.price, style = labelStyle, color = color.new(sideColor, 0), textcolor = color.white, size = f_labelSize(labelSizeInput), text_formatting = text.format_bold + text.format_italic, tooltip = sigTip)
            array.push(signalLabels, sigLb)
            while array.size(signalLabels) > maxSignalLabels
                label oldSig = array.shift(signalLabels)
                if not na(oldSig)
                    label.delete(oldSig)

        if enableProfessionalAlerts and ((newDir == 1 and alertBullishFlips) or (newDir == -1 and alertBearishFlips))
            alert(f_signalAlertMessage(newDir, newScore, entry, sl, tp, selectedRrTarget, autoComboReady), alert.freq_once_per_bar_close)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ACTIVE TRADE UPDATE + RESULT TRACKING
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if tradeActive
    int dynamicRight = bar_index + tradeBoxExtendBars
    if not na(tpBox)
        box.set_right(tpBox, dynamicRight)
    if not na(slBox)
        box.set_right(slBox, dynamicRight)
    if not na(entryLine)
        line.set_x2(entryLine, dynamicRight)
    if not na(slLine)
        line.set_x2(slLine, dynamicRight)
    if not na(tpLine)
        line.set_x2(tpLine, dynamicRight)
    if not na(entryTag)
        label.set_x(entryTag, dynamicRight)
    if not na(tpTag)
        label.set_x(tpTag, dynamicRight)
    if not na(slTag)
        label.set_x(slTag, dynamicRight)
    if trackTradeResults and bar_index > tradeStartBar
        bool hitTp = tradeDir == 1 ? high >= tradeTp : low <= tradeTp
        bool hitSl = tradeDir == 1 ? low <= tradeSl : high >= tradeSl
        bool resultHit = hitTp or hitSl
        bool resultIsTp = hitTp and hitSl ? sameBarResult == "TP First" : hitTp
        if resultHit
            tradeActive := false
            completedTrades += 1
            resultBarEvent := true
            resultBarDir := resultIsTp ? tradeDir : tradeDir * -1
            if resultIsTp
                winTrades += 1
                grossWinR += tradeRr
                netR += tradeRr
                lastResult := "WIN"
                tpResultEvent := true
            else
                lossTrades += 1
                grossLossR += 1.0
                netR -= 1.0
                lastResult := "LOSS"
                slResultEvent := true
            if not na(tpBox)
                box.set_right(tpBox, bar_index)
            if not na(slBox)
                box.set_right(slBox, bar_index)
            if not na(entryLine)
                line.set_x2(entryLine, bar_index)
            if not na(slLine)
                line.set_x2(slLine, bar_index)
            if not na(tpLine)
                line.set_x2(tpLine, bar_index)
            if not na(entryTag)
                label.set_x(entryTag, bar_index)
            if not na(tpTag)
                label.set_x(tpTag, bar_index)
            if not na(slTag)
                label.set_x(slTag, bar_index)
            if showResultStamps
                float resultY = resultIsTp ? tradeTp : tradeSl
                string resultTxt = resultIsTp ? "WIN | TARGET HIT" : "LOSS | RISK HIT"
                color resultBg = resultIsTp ? f_targetColor() : f_riskColor()
                label resLb = label.new(x = bar_index, y = resultY, text = resultTxt, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(resultBg, 0), textcolor = color.white, size = f_resultLabelSize(), text_formatting = text.format_bold + text.format_italic, tooltip = "Trade Result | " + (resultIsTp ? "WIN - Target reached" : "LOSS - Risk reached") + " | Net R " + str.tostring(netR, "#.##"))
                array.push(resultLabels, resLb)
                while array.size(resultLabels) > maxResultLabels
                    label oldRes = array.shift(resultLabels)
                    if not na(oldRes)
                        label.delete(oldRes)

            if enableProfessionalAlerts and alertTradeResults
                alert(f_resultAlertMessage(resultIsTp, tradeEntry, tradeSl, tradeTp, tradeRr, netR), alert.freq_once_per_bar_close)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CRIMSON SPINE + ECHO + FILL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

float spineCore = ta.ema(spineSource, spineLength)
float spinePressureRaw = selectedBuySignalScore - selectedSellSignalScore
float spinePressureIntensity = f_clamp(math.abs(spinePressureRaw) / 100.0, 0.20, 1.00)
float spineSpreadMultiplier = spineAdaptiveSpread ? 0.70 + spinePressureIntensity * 0.70 : 1.00
float spineUnit = atr * spineEchoSpacingAtr * spineSpreadMultiplier

float spineU1 = spineCore + spineUnit * 1.0
float spineU2 = spineCore + spineUnit * 2.0
float spineU3 = spineCore + spineUnit * 3.0
float spineU4 = spineCore + spineUnit * 4.0
float spineU5 = spineCore + spineUnit * 5.0
float spineL1 = spineCore - spineUnit * 1.0
float spineL2 = spineCore - spineUnit * 2.0
float spineL3 = spineCore - spineUnit * 3.0
float spineL4 = spineCore - spineUnit * 4.0
float spineL5 = spineCore - spineUnit * 5.0

pSpineCore = plot(showCrimsonSpine ? spineCore : na, title = "Crimson Spine Core", color = f_spineColor(0), linewidth = spineLineWidth + 1, display = display.all - display.status_line - display.price_scale)
pSpineU1 = plot(showCrimsonSpine ? spineU1 : na, title = "Crimson Echo Upper 1", color = f_spineColor(1), linewidth = spineLineWidth, display = display.all - display.status_line - display.price_scale)
pSpineU2 = plot(showCrimsonSpine ? spineU2 : na, title = "Crimson Echo Upper 2", color = f_spineColor(2), linewidth = spineLineWidth, display = display.all - display.status_line - display.price_scale)
pSpineU3 = plot(showCrimsonSpine ? spineU3 : na, title = "Crimson Echo Upper 3", color = f_spineColor(3), linewidth = spineLineWidth, display = display.all - display.status_line - display.price_scale)
pSpineU4 = plot(showCrimsonSpine ? spineU4 : na, title = "Crimson Echo Upper 4", color = f_spineColor(4), linewidth = spineLineWidth, display = display.all - display.status_line - display.price_scale)
pSpineU5 = plot(showCrimsonSpine ? spineU5 : na, title = "Crimson Echo Upper 5", color = f_spineColor(4), linewidth = 1, display = display.all - display.status_line - display.price_scale)
pSpineL1 = plot(showCrimsonSpine ? spineL1 : na, title = "Crimson Echo Lower 1", color = f_spineColor(1), linewidth = spineLineWidth, display = display.all - display.status_line - display.price_scale)
pSpineL2 = plot(showCrimsonSpine ? spineL2 : na, title = "Crimson Echo Lower 2", color = f_spineColor(2), linewidth = spineLineWidth, display = display.all - display.status_line - display.price_scale)
pSpineL3 = plot(showCrimsonSpine ? spineL3 : na, title = "Crimson Echo Lower 3", color = f_spineColor(3), linewidth = spineLineWidth, display = display.all - display.status_line - display.price_scale)
pSpineL4 = plot(showCrimsonSpine ? spineL4 : na, title = "Crimson Echo Lower 4", color = f_spineColor(4), linewidth = spineLineWidth, display = display.all - display.status_line - display.price_scale)
pSpineL5 = plot(showCrimsonSpine ? spineL5 : na, title = "Crimson Echo Lower 5", color = f_spineColor(4), linewidth = 1, display = display.all - display.status_line - display.price_scale)

fill(pSpineU1, pSpineL1, title = "Crimson Inner Fill", color = showCrimsonSpine ? f_spineFillColor(1) : na)
fill(pSpineU3, pSpineU5, title = "Crimson Upper Outer Fill", color = showCrimsonSpine ? f_spineFillColor(3) : na)
fill(pSpineL3, pSpineL5, title = "Crimson Lower Outer Fill", color = showCrimsonSpine ? f_spineFillColor(3) : na)
fill(pSpineU1, pSpineU3, title = "Crimson Upper Mid Fill", color = showCrimsonSpine ? f_spineFillColor(2) : na)
fill(pSpineL1, pSpineL3, title = "Crimson Lower Mid Fill", color = showCrimsonSpine ? f_spineFillColor(2) : na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VISUAL LAYERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

color signalBarColor = na
if candleHighlightMode != "Off"
    if buySignal
        signalBarColor := color.new(f_buyColor(), 45)
    else if sellSignal
        signalBarColor := color.new(f_sellColor(), 45)
    else if candleHighlightMode == "Signal + Result" and resultBarEvent
        signalBarColor := resultBarDir == 1 ? color.new(f_targetColor(), 55) : color.new(f_riskColor(), 55)
barcolor(signalBarColor)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MINI MODERN DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var table miniDashboard = table.new(f_dashboardPosition(dashboardPosition), 2, 6, bgcolor = color.new(f_dashboardBaseBg(), dashboardTransparency), frame_color = color.new(f_dashboardFrameColor(), 55), frame_width = 1, border_color = color.new(f_dashboardFrameColor(), 82), border_width = 1)

if barstate.islast
    if showDashboard
        int dashKeyTransparency = math.min(dashboardTransparency + 8, 95)
        int dashValueTransparency = math.min(dashboardTransparency + 2, 95)
        color dashHeader = color.new(f_dashboardHeaderBg(), 0)
        color dashKeyBg = color.new(f_dashboardBaseBg(), dashKeyTransparency)
        color dashValueBg = color.new(f_dashboardBaseBg(), dashValueTransparency)
        color dashText = color.white
        color dashMuted = color.new(color.white, 32)
        color stateColor = tradeActive ? color.new(f_riskColor(), 0) : color.new(f_targetColor(), 0)
        string stateText = tradeActive ? "ACTIVE" : "CLEAR"
        string activeSide = tradeActive ? f_sideText(tradeDir) : lastSignalDir == 0 ? "WAIT" : f_sideText(lastSignalDir)
        string autoText = autoComboReady ? "AUTO BEST" : useOptimizer ? "WAITING" : "OFF"
        string scoreText = na(lastSignalScore) ? "N/A" : str.tostring(lastSignalScore, "#.##")
        table.cell(miniDashboard, 0, 0, "CPFE", text_color = dashText, bgcolor = dashHeader, text_size = f_dashboardTextSize(dashboardTextSize), text_halign = text.align_left)
        table.cell(miniDashboard, 1, 0, stateText, text_color = stateColor, bgcolor = dashHeader, text_size = f_dashboardTextSize(dashboardTextSize), text_halign = text.align_right)
        table.cell(miniDashboard, 0, 1, "Mode", text_color = dashMuted, bgcolor = dashKeyBg, text_size = f_dashboardTextSize(dashboardTextSize), text_halign = text.align_left)
        table.cell(miniDashboard, 1, 1, signalMode, text_color = dashText, bgcolor = dashValueBg, text_size = f_dashboardTextSize(dashboardTextSize), text_halign = text.align_right)
        table.cell(miniDashboard, 0, 2, "Auto", text_color = dashMuted, bgcolor = dashKeyBg, text_size = f_dashboardTextSize(dashboardTextSize), text_halign = text.align_left)
        table.cell(miniDashboard, 1, 2, autoText, text_color = autoComboReady ? f_targetColor() : dashText, bgcolor = dashValueBg, text_size = f_dashboardTextSize(dashboardTextSize), text_halign = text.align_right)
        table.cell(miniDashboard, 0, 3, "Side", text_color = dashMuted, bgcolor = dashKeyBg, text_size = f_dashboardTextSize(dashboardTextSize), text_halign = text.align_left)
        table.cell(miniDashboard, 1, 3, activeSide, text_color = activeSide == "BULLISH" ? f_buyColor() : activeSide == "BEARISH" ? f_sellColor() : dashText, bgcolor = dashValueBg, text_size = f_dashboardTextSize(dashboardTextSize), text_halign = text.align_right)
        table.cell(miniDashboard, 0, 4, "Score", text_color = dashMuted, bgcolor = dashKeyBg, text_size = f_dashboardTextSize(dashboardTextSize), text_halign = text.align_left)
        table.cell(miniDashboard, 1, 4, scoreText, text_color = dashText, bgcolor = dashValueBg, text_size = f_dashboardTextSize(dashboardTextSize), text_halign = text.align_right)
        table.cell(miniDashboard, 0, 5, "Last", text_color = dashMuted, bgcolor = dashKeyBg, text_size = f_dashboardTextSize(dashboardTextSize), text_halign = text.align_left)
        table.cell(miniDashboard, 1, 5, lastResult, text_color = lastResult == "WIN" ? f_targetColor() : lastResult == "LOSS" ? f_riskColor() : dashText, bgcolor = dashValueBg, text_size = f_dashboardTextSize(dashboardTextSize), text_halign = text.align_right)
    else
        for c = 0 to 1
            for r = 0 to 5
                table.cell(miniDashboard, c, r, "", bgcolor = color.new(color.black, 100), text_color = color.new(color.white, 100), text_size = size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(buySignalEvent, title = "Bullish Pressure Flip", message = "Bullish Pressure Flip signal detected by Candle Pressure Flip Engine [trade_w_samet].")
alertcondition(sellSignalEvent, title = "Bearish Pressure Flip", message = "Bearish Pressure Flip signal detected by Candle Pressure Flip Engine [trade_w_samet].")
alertcondition(tpResultEvent, title = "Trade Result WIN", message = "Candle Pressure Flip Engine trade reached target.")
alertcondition(slResultEvent, title = "Trade Result LOSS", message = "Candle Pressure Flip Engine trade reached risk.")
````
