# Pulse Entry Engine

- url: https://www.tradingview.com/script/asVngmQ1-Pulse-Entry-Engine/
- type: indicator
- pine_id: PUB;3f591b8f838c425e8c796c17a56649e2
- version: 2.0

## Description

🚀 Pulse Entry Engine [V1.0]

Pulse Entry Engine [V1.0] is a free momentum-based entry visualization and decision-support indicator designed to help traders analyze potential entry conditions with a cleaner, more structured, and more visual workflow.

This script combines a Special K-based momentum engine, signal modes, confirmation logic, EMA context, higher-timeframe bias filtering, modern oscillator visualization, signal strength scoring, star-based quality labels, TP/SL projection boxes, active-trade candle coloring, signal-candle background highlighting, compact dashboards, visual themes, and dynamic alerts into one organized TradingView tool.

The goal of Pulse Entry Engine is not to predict the future or provide guaranteed buy/sell instructions.

Its purpose is to help users visually study:

⚡ momentum expansion  
🎯 entry-quality conditions  
🧭 directional context  
📊 signal strength  
📦 projected TP/SL zones  
🕯️ active-trade candle behavior  
🚨 alert-based monitoring  

Pulse Entry Engine should be treated as a structured chart-analysis tool, not as financial advice, not as an automated trading system, and not as a guarantee of profitable results.


━━━━━━━━━━━━━━━━━━━━━━
🔓 PUBLICATION NOTE
━━━━━━━━━━━━━━━━━━━━━━

This script is published as a free educational and visual market-analysis tool.

The description is intentionally detailed because many users do not inspect every part of the Pine Script logic line by line.

The purpose of this page is to explain:

✅ what the script does  
✅ how the components work together  
✅ what appears on the chart  
✅ how signals are filtered  
✅ how TP/SL projection works  
✅ what the dashboards mean  
✅ what the limitations are  
✅ how the indicator should and should not be used  

Pulse Entry Engine [V1.0] is designed to support structured decision-making.

It does not promise profitable results.
It does not remove market risk.
It does not execute trades.
It should not be used as a blind buy/sell system.

It is best used as a visual framework for reviewing momentum, signal quality, context, and projected risk/reward.


━━━━━━━━━━━━━━━━━━━━━━
📌 OVERVIEW
━━━━━━━━━━━━━━━━━━━━━━

At a high level, Pulse Entry Engine [V1.0] does the following:

1. ⚙️ Calculates a Special K-based momentum engine.
2. 📈 Compares the engine value with its signal line.
3. 📏 Measures the distance between the engine and signal line.
4. 🔥 Classifies stretch conditions as Weak, Normal, Strong, or Extreme.
5. 🎯 Generates LONG / SHORT pulse signals when selected conditions align.
6. 🧠 Provides five different Signal Modes.
7. 🕯️ Supports Bar Close and Live Intrabar confirmation.
8. 📈 Includes an EMA-based context filter.
9. 🧭 Includes a Higher Timeframe Bias Filter.
10. ⭐ Calculates a 0–100 signal score.
11. 📊 Displays a Signal Strength Bar.
12. 🌟 Shows star-based quality labels on the main chart.
13. 🟩 Highlights the exact signal candle with a vertical background.
14. 🕯️ Colors candles only while a projected trade is active.
15. 📦 Displays ATR-based TP/SL projection boxes.
16. 🎯 Tracks TP1, TP2, TP3, and SL visually.
17. 🔒 Blocks new signals while an active projection has not reached TP1.
18. 🔁 Allows replacement logic after TP1/TP2 progress.
19. 🌊 Includes a modern oscillator visual engine.
20. 📊 Includes Neon Histogram as the default oscillator view.
21. 🎨 Includes multiple visual themes.
22. 🖥️ Includes Minimal / Pro / Full display profiles.
23. 📋 Includes a compact main dashboard.
24. 📡 Includes a compact live scanning panel.
25. 🚨 Includes standard and dynamic alert messages.

This makes the script more than a simple oscillator or a basic signal marker.

It is a complete visual entry-analysis framework built around momentum, context, signal quality, and projected trade structure.


━━━━━━━━━━━━━━━━━━━━━━
🧠 CORE IDEA
━━━━━━━━━━━━━━━━━━━━━━

The core idea behind Pulse Entry Engine is simple:

A potential entry should not be judged from one isolated condition.

A single oscillator movement, one candle reaction, one stretched reading, or one signal label is usually not enough by itself.

Market context matters.

For that reason, Pulse Entry Engine combines several layers:

⚡ momentum engine direction  
📏 distance and stretch expansion  
🧭 zero-line context  
📈 EMA context  
🕰️ higher-timeframe bias  
⭐ score requirement  
🎛️ signal mode strictness  
🕯️ confirmation timing  
📦 TP/SL projection logic  

The indicator does not attempt to mark every possible move.

Instead, it attempts to make momentum-based entry conditions easier to read, compare, and review.

The purpose is not to create more signals.

The purpose is to make signals more understandable.


━━━━━━━━━━━━━━━━━━━━━━
🧩 WHY THIS SCRIPT IS NOT A SIMPLE BUY/SELL INDICATOR
━━━━━━━━━━━━━━━━━━━━━━

Pulse Entry Engine is not intended to behave like a simple “buy here / sell here” script.

It is built as a structured workflow:

Pulse Engine  
→ Distance / Stretch Detection  
→ Signal Mode Filtering  
→ Zero / EMA Context  
→ HTF Bias Confirmation  
→ Score Classification  
→ Star-Based Signal Label  
→ TP/SL Projection  
→ Active Trade Visualization  
→ Dashboard Review  
→ Dynamic Alerts  

Each part has a specific role.

⚙️ The Pulse Engine measures momentum behavior.  
📏 The distance logic identifies meaningful separation from the signal line.  
🎛️ The signal modes adjust strictness.  
⭐ The score system summarizes confluence strength.  
🧭 The HTF filter adds broader directional context.  
📊 The dashboard summarizes current conditions.  
🌊 The oscillator visualizes momentum behavior.  
📦 The TP/SL boxes provide a projected risk/reward structure.  
🚨 The alert system helps monitor signals without constantly watching the chart.

This makes the script a full review environment, not a one-condition signal tool.


━━━━━━━━━━━━━━━━━━━━━━
⚙️ HOW THE SCRIPT WORKS
━━━━━━━━━━━━━━━━━━━━━━

1) ⚡ PULSE ENTRY CORE

Pulse Entry Engine uses a Special K-based calculation as its internal momentum engine.

The engine produces two main values:

• the main momentum engine value  
• the signal line  

The relationship between these two values forms the foundation of the signal logic.

When the engine moves away from the signal line, the script measures the distance between them.

That distance is then compared to its own recent average distance.

This creates the Distance Ratio.

The Distance Ratio helps the script understand whether the current movement is weak, normal, strong, or extreme compared to recent behavior.

This is important because a raw distance between two lines may not mean much by itself.

A distance becomes more meaningful when it is large compared to the engine’s recent average behavior.


━━━━━━━━━━━━━━━━━━━━━━
📏 DISTANCE / STRETCH LOGIC
━━━━━━━━━━━━━━━━━━━━━━

The script calculates:

📌 current distance between engine and signal line  
📌 average distance over the selected lookback  
📌 distance ratio  
📌 strong stretch threshold  
📌 extreme stretch threshold  

The stretch state can be:

🟤 Weak  
🔵 Normal  
🟠 Strong  
🟣 Extreme  

This stretch state appears in the dashboard.

The stretch logic is one of the most important parts of the signal engine.

A signal generally needs the engine distance to be strong enough according to the selected Signal Mode.

This helps reduce reactions to small, random oscillator movements.


━━━━━━━━━━━━━━━━━━━━━━
🎛️ SIGNAL MODES
━━━━━━━━━━━━━━━━━━━━━━

Pulse Entry Engine includes five Signal Modes.

These modes are not only visual names.

They change internal signal thresholds, score requirements, and filtering behavior.

Available modes:

🔥 Aggressive  
⚖️ Balanced  
⚡ Scalping  
🌊 Swing  
🛡️ Funded Account  


🔥 Aggressive

Aggressive mode is the earliest and most sensitive profile.

It uses lower stretch requirements and a lower score threshold.

This means it can produce more signals and may react faster to developing momentum conditions.

Useful for:

• testing  
• manual confirmation  
• fast scanning  
• active monitoring  
• traders who want more potential setups  

Important note:

Because it is more sensitive, it may also produce more noise.


⚖️ Balanced

Balanced mode is the default all-around profile.

It uses the user-defined Distance Multiplier and Extreme Stretch settings.

This mode is designed to provide a stable middle-ground behavior.

Useful for:

• general chart review  
• standard intraday analysis  
• balanced signal frequency  
• users who want neither too many nor too few signals  


⚡ Scalping

Scalping mode is designed for lower-timeframe active trading environments.

It is faster than Balanced mode but stricter than Aggressive mode.

Useful for:

• M1  
• M3  
• M5  
• fast intraday scanning  
• short-term chart review  

Scalping mode should still be used with context, risk control, and independent analysis.


🌊 Swing

Swing mode is more selective.

It requires stronger stretch and a higher score threshold.

EMA and Zero filters are forced on for stricter directional context.

Useful for:

• larger market moves  
• higher timeframe review  
• slower trading style  
• fewer but more filtered signals  


🛡️ Funded Account

Funded Account mode is the strictest profile.

It requires the strongest internal confirmation among the available modes.

EMA and Zero filters are forced on.

Useful for:

• fewer signals  
• stricter filtering  
• drawdown-conscious review  
• evaluation-style account discipline  
• users who prefer cleaner setups  

Important note:

This mode does not guarantee safer trades or profitable outcomes.

It only applies stricter internal filtering.


━━━━━━━━━━━━━━━━━━━━━━
🕯️ SIGNAL CONFIRMATION MODE
━━━━━━━━━━━━━━━━━━━━━━

Pulse Entry Engine includes two confirmation modes:

✅ Bar Close  
⚡ Live Intrabar  


✅ Bar Close

Bar Close mode confirms signals only after the candle closes.

This is the default mode.

It is designed to reduce repaint perception and make signal behavior easier to review historically.

This is generally the cleaner option for alerts and structured review.


⚡ Live Intrabar

Live Intrabar mode allows signals to appear before the candle closes.

This can provide earlier visual feedback.

However, because the candle is still forming, the signal may change before the candle closes.

This mode is faster but less stable than Bar Close confirmation.


━━━━━━━━━━━━━━━━━━━━━━
🧭 ZERO FILTER
━━━━━━━━━━━━━━━━━━━━━━

The Zero Filter uses the oscillator’s zero line as an additional context layer.

In the default logic:

🟢 LONG setups require the engine oscillator to be below zero.  
🔴 SHORT setups require the engine oscillator to be above zero.  

This creates a reversal-style interpretation.

The idea is that long signals may be more meaningful when the engine is stretched below the zero region, while short signals may be more meaningful when the engine is stretched above the zero region.

Swing and Funded Account modes force this filter on.


━━━━━━━━━━━━━━━━━━━━━━
📈 EMA FILTER
━━━━━━━━━━━━━━━━━━━━━━

The EMA filter adds price-location context.

In this version, the default EMA logic is reversal-oriented:

🟢 LONG setups are allowed when price is below the EMA.  
🔴 SHORT setups are allowed when price is above the EMA.  

This is not a classic trend-following EMA filter.

It is used to help identify stretched conditions relative to a directional reference.

Swing and Funded Account modes force this filter on.

The dashboard also uses the EMA relationship to display a simple bias state:

🟢 LONG ONLY  
🔴 SHORT ONLY  
⚪ NEUTRAL  

This bias should be treated as context, not as an instruction to trade.


━━━━━━━━━━━━━━━━━━━━━━
🕰️ HTF BIAS FILTER
━━━━━━━━━━━━━━━━━━━━━━

Pulse Entry Engine includes a Higher Timeframe Bias Filter.

Available HTF modes:

⚪ Off  
📈 EMA 100  
📉 EMA 200  
⚙️ Engine HTF  


⚪ Off

No higher-timeframe filter is used.


📈 EMA 100

The script checks whether higher-timeframe price is above or below the HTF EMA 100.

Above HTF EMA100 = bullish bias.  
Below HTF EMA100 = bearish bias.


📉 EMA 200

The script checks whether higher-timeframe price is above or below the HTF EMA 200.

This is a slower and broader macro filter compared to EMA 100.


⚙️ Engine HTF

The script calculates the engine relationship on the selected higher timeframe.

HTF engine above its signal line = bullish bias.  
HTF engine below its signal line = bearish bias.

The HTF filter can help reduce signals that conflict with a broader directional context.

The default HTF timeframe is 60 minutes, but users can adjust it.


━━━━━━━━━━━━━━━━━━━━━━
⭐ SIGNAL SCORE
━━━━━━━━━━━━━━━━━━━━━━

Pulse Entry Engine calculates a 0–100 signal score.

The score is based on internal confluence components such as:

⚡ engine direction  
📏 stretch strength  
🧭 zero filter alignment  
📈 EMA filter alignment  
🔥 distance strength  

The score appears in the dashboard and is also used internally by the selected Signal Mode.

Important note:

The score is not a win-rate prediction.

A score of 85 does not mean the signal has an 85% chance of winning.

It simply means the internal confluence conditions were stronger according to the script’s scoring model.


━━━━━━━━━━━━━━━━━━━━━━
🌟 STAR-BASED MAIN CHART LABELS
━━━━━━━━━━━━━━━━━━━━━━

On the main chart, Pulse Entry Engine uses star-based quality labels.

This keeps the chart cleaner than showing large score numbers directly on every signal label.

Star system:

⭐⭐⭐⭐⭐ = 96–100  
⭐⭐⭐⭐ = 92–95  
⭐⭐⭐ = 88–91  
⭐⭐ = 84–87  
⭐ = 80–83  
☆ = below 80  

Example labels:

▲ LONG PULSE  
⭐⭐⭐⭐  

▼ SHORT PULSE  
⭐⭐⭐  

The dashboard still keeps the full numerical score for users who want more detail.


━━━━━━━━━━━━━━━━━━━━━━
📊 SIGNAL STRENGTH BAR
━━━━━━━━━━━━━━━━━━━━━━

The main dashboard includes a Signal Strength Bar.

Example:

█████ 92  
████░ 84  
███░░ 73  

This gives a quick visual representation of the current score.

The strength bar is not a performance statistic.

It does not represent probability or future outcome.

It only visualizes the current internal signal-quality score.


━━━━━━━━━━━━━━━━━━━━━━
🎨 VISUAL THEME SYSTEM
━━━━━━━━━━━━━━━━━━━━━━

Pulse Entry Engine includes three full visual themes:

🟢 Dark Emerald  
🔵 Aqua Neon  
🟣 Royal Purple  


🟢 Dark Emerald

A dark professional theme using green, teal, and cyan accents.


🔵 Aqua Neon

A brighter cyber-style theme using blue, cyan, and pink tones.


🟣 Royal Purple

A premium-looking theme using purple and gold-style accents.

The theme affects:

🎨 dashboard colors  
📡 live panel colors  
🌊 oscillator colors  
📊 histogram colors  
🏷️ signal labels  
📦 TP/SL boxes  
🟢 LONG visuals  
🔴 SHORT visuals  
🕯️ active-trade candle coloring  
🟩 signal-candle background  
🚨 visual alert feel  

Color inputs are intentionally not exposed in the Inputs tab.

The indicator uses internal theme profiles to keep the settings cleaner and more organized.


━━━━━━━━━━━━━━━━━━━━━━
🖥️ DISPLAY MODE
━━━━━━━━━━━━━━━━━━━━━━

Pulse Entry Engine includes three display profiles:

▫️ Minimal  
▪️ Pro  
🔳 Full  


▫️ Minimal

Minimal mode reduces chart clutter.

It hides many optional visual layers such as dashboards, oscillator dots, gradient zones, pulse backgrounds, and TP level lines.

Useful for clean chart viewing.


▪️ Pro

Pro mode is the balanced default layout.

It uses the user’s individual visibility settings and is designed as the standard V1.0 experience.


🔳 Full

Full mode forces major visual layers on.

Useful for:

🎥 YouTube live streams  
📸 screenshots  
📚 educational examples  
🧪 demonstrations  
📊 full feature previews  


━━━━━━━━━━━━━━━━━━━━━━
🌊 OSCILLATOR VISUAL ENGINE
━━━━━━━━━━━━━━━━━━━━━━

Pulse Entry Engine includes multiple oscillator display styles.

Available oscillator styles:

📊 Neon Histogram  
🌊 Modern Pulse Wave  
➖ Clean Line Pro  
🕯️ Classic HA  
🕯️ Classic Candles  

Neon Histogram is the default mode in this version.


📊 Neon Histogram

This mode displays the difference between the engine core and signal line as a histogram.

The histogram helps users quickly read momentum expansion and contraction.

Positive and negative histogram areas are colored according to the selected theme.


🌊 Modern Pulse Wave

This mode displays a smooth pulse wave with soft glow layers and a momentum cloud.

It is designed to look clean, modern, and premium.


➖ Clean Line Pro

This mode provides a simpler line-based oscillator view with less visual noise.


🕯️ Classic HA

This mode keeps the previous Heikin Ashi-style synthetic oscillator candle view.


🕯️ Classic Candles

This mode keeps the previous raw synthetic oscillator candle view.

These modes allow users to choose between a modern histogram, a glowing wave, a minimal line, and legacy oscillator candle styles.


━━━━━━━━━━━━━━━━━━━━━━
🌈 OSCILLATOR SIGNAL DOTS
━━━━━━━━━━━━━━━━━━━━━━

The oscillator panel can show LONG and SHORT signal dots.

In modern modes, the dots can include a glow effect:

✨ larger soft outer dot  
● smaller sharp inner dot  

This makes signal locations easier to identify in the oscillator panel without large text labels.

These oscillator dots are visual markers only.

They are based on the same signal logic as the main chart labels.


━━━━━━━━━━━━━━━━━━━━━━
⚡ EXTREME STRETCH MARKERS
━━━━━━━━━━━━━━━━━━━━━━

The script can display extreme stretch markers when the engine reaches an extreme distance condition.

These markers highlight stretched momentum conditions.

They are not direct trade signals by themselves.

Their purpose is to show that the engine has moved far away from its recent average relationship with the signal line.


━━━━━━━━━━━━━━━━━━━━━━
📦 TP / SL PROJECTION SYSTEM
━━━━━━━━━━━━━━━━━━━━━━

Pulse Entry Engine includes a TP/SL projection system on the main price chart.

When a new signal appears, the script can draw:

📦 TP box  
📦 SL box  
🎯 TP1 line  
🎯 TP2 line  
🎯 TP3 line  
🏷️ result label  

The system uses ATR-based risk.

Default risk settings:

📌 SL ATR Multiplier = 2.5  
📌 Final TP Risk Reward = 1.5R  

TP structure:

TP1 = 25% of final TP distance  
TP2 = 50% of final TP distance  
TP3 = final TP  

The boxes are projected forward by an initial number of bars.

Default:

📌 Initial TP/SL Box Length = 10 bars  

If the projected trade remains active longer than the initial length, the box continues extending until TP3, SL, or a valid replacement condition occurs.


━━━━━━━━━━━━━━━━━━━━━━
🎯 TP1 / TP2 / TP3 / SL RESULT LOGIC
━━━━━━━━━━━━━━━━━━━━━━

The TP/SL projection system tracks the projected result visually.

Possible result labels:

🟢 TP1  
🟢 TP2  
🟢 TP3  
🔴 SL  

If price reaches TP3, the result is marked as TP3.

If price hits SL before reaching any TP level, the result is marked as SL.

If price reaches TP1 and later returns to SL, the result is marked as TP1.

If price reaches TP2 and later returns to SL, the result is marked as TP2.

This means the system remembers the highest target reached before a stop event.

This makes the visual projection more informative than a simple static TP/SL marker.


━━━━━━━━━━━━━━━━━━━━━━
⚠️ SAME-BAR TP/SL HANDLING
━━━━━━━━━━━━━━━━━━━━━━

If TP and SL are both touched on the same candle, there is ambiguity.

The script cannot know the true intrabar sequence unless lower-timeframe reconstruction is used.

For this reason, the script includes a same-bar setting:

If TP and SL Hit Same Bar:

🔴 SL  
🟢 TP1  

SL is the conservative default.

This allows users to decide how they want same-candle ambiguity to be handled in the visual projection.


━━━━━━━━━━━━━━━━━━━━━━
🔁 ACTIVE TRADE SIGNAL GATE
━━━━━━━━━━━━━━━━━━━━━━

Pulse Entry Engine includes an active projection gate.

If a projected trade is active and has not yet reached TP1, the script blocks new signals.

This prevents the chart from stacking multiple new signals before the previous projection has made minimum progress.

If an active projection has already reached TP1 or TP2 and a new signal appears, the old projection can be closed at its highest reached TP level and the new signal can begin.

This keeps the visual trade structure cleaner and more organized.


━━━━━━━━━━━━━━━━━━━━━━
🕯️ ACTIVE TRADE CANDLE COLORING
━━━━━━━━━━━━━━━━━━━━━━

Pulse Entry Engine can color candles while a projected trade is active.

This candle coloring appears only during an active projection.

🟢 During an active LONG projection, candles use the theme long color.  
🔴 During an active SHORT projection, candles use the theme short color.  

Once the projection closes, candle coloring stops.

This helps users visually identify when the system considers a projected trade to be active.

It is not a separate trading signal.


━━━━━━━━━━━━━━━━━━━━━━
🟩 SIGNAL CANDLE BACKGROUND
━━━━━━━━━━━━━━━━━━━━━━

The script can highlight the exact candle that produced a confirmed signal.

🟢 LONG signal = vertical long-colored background stripe  
🔴 SHORT signal = vertical short-colored background stripe  

This feature is useful for:

📌 historical review  
📌 live chart monitoring  
📌 YouTube live streams  
📌 educational explanations  
📌 quickly locating the original signal candle  


━━━━━━━━━━━━━━━━━━━━━━
📋 MAIN DASHBOARD
━━━━━━━━━━━━━━━━━━━━━━

Pulse Entry Engine includes a compact main dashboard.

The dashboard can display:

🎛️ Signal Mode  
🎨 Theme  
🧭 Bias  
🔥 Stretch state  
⭐ Score  
📊 Strength  
🎯 Signal state  
🕯️ Confirmation mode  
🕰️ HTF Bias  

The dashboard is intentionally compact.

It is not designed to be a large performance table.

Its purpose is to summarize the current engine state and help users understand what the script is currently reading.

Dashboard position and size can be adjusted from the settings.


━━━━━━━━━━━━━━━━━━━━━━
📡 LIVE SCANNING PANEL
━━━━━━━━━━━━━━━━━━━━━━

The script includes a compact Live Scanning panel.

The live panel displays the Pulse Entry Engine live scanning state in a clean visual format.

The lower information row was intentionally removed to keep the chart cleaner.

Users can adjust:

📍 Live Panel Position  
🔠 Live Panel Size  
● Live blinking status symbol  

The live panel is visual only.

It does not affect signal logic.


━━━━━━━━━━━━━━━━━━━━━━
🚨 ALERT SYSTEM
━━━━━━━━━━━━━━━━━━━━━━

Pulse Entry Engine includes both standard alert conditions and dynamic alert messages.

Standard alertcondition alerts include:

🟢 LONG signal  
🔴 SHORT signal  
⚡ LONG/SHORT signal  
🔥 Extreme stretch detected  

The script also includes dynamic alert messages using alert().

The dynamic alert message can include:

📌 indicator name and version  
📌 signal direction  
📌 ticker  
📌 timeframe  
📌 Signal Mode  
📌 Confirmation Mode  
📌 HTF Bias  
📌 Score  
📌 Stretch  
📌 ATR risk setting  
📌 TP RR setting  

Important usage note:

To use the full dynamic alert message, create a TradingView alert with:

Condition: Pulse Entry Engine  
Option: Any alert() function call  

The standard alertcondition options can still be used as simpler fallback alerts.


━━━━━━━━━━━━━━━━━━━━━━
🧪 HOW TO USE THE INDICATOR
━━━━━━━━━━━━━━━━━━━━━━

A practical workflow:

1. Add Pulse Entry Engine [V1.0] to your chart.
2. Start with the default Pro display mode.
3. Choose a visual theme that fits your chart.
4. Select your Signal Mode.
5. Use Bar Close confirmation for cleaner signal review.
6. Choose whether to enable the HTF Bias Filter.
7. Watch the oscillator histogram for momentum expansion.
8. Review the dashboard for score, stretch, signal state, and HTF bias.
9. When a LONG or SHORT pulse appears, check the star rating.
10. Look at the signal candle background highlight.
11. Review the TP/SL projection box.
12. Observe whether the projection reaches TP1, TP2, TP3, or SL.
13. Use alerts if you want automated signal notifications.
14. Validate the indicator on the specific markets and timeframes you personally study.

The indicator is best used as a structured decision-support tool.

It should not be used as a blind execution system.


━━━━━━━━━━━━━━━━━━━━━━
⚙️ SETTINGS REFERENCE
━━━━━━━━━━━━━━━━━━━━━━

🎯 Signal Logic

Source

Selects the price source used by the Pulse Entry Engine core.

Signal Length 1

Primary engine calculation length.

Signal Length 2

Secondary engine calculation length.

Signal Mode

Selects the main signal preset:

🔥 Aggressive  
⚖️ Balanced  
⚡ Scalping  
🌊 Swing  
🛡️ Funded Account  

Signal Confirmation Mode

Controls when a signal is allowed to confirm:

✅ Bar Close  
⚡ Live Intrabar  

Average Distance Length

Lookback length used to calculate average distance between engine and signal line.

Distance Multiplier

Balanced mode stretch threshold.

Extreme Stretch Multiplier

Balanced mode extreme stretch threshold.

Reset When Distance Gets Weak

Allows the internal signal state to reset when distance becomes weak.

Reset Multiplier

Defines how weak the distance must become before reset.

Use Zero Filter

Enables zero-line filtering.


📈 EMA Filter

Use EMA Filter

Enables the EMA context filter.

EMA Length

EMA length used for the filter and dashboard bias.


🧭 HTF Bias Filter

HTF Bias Mode

Available modes:

⚪ Off  
📈 EMA 100  
📉 EMA 200  
⚙️ Engine HTF  

HTF Timeframe

Higher timeframe used by the HTF filter.


🎨 Style

Visual Theme

Available themes:

🟢 Dark Emerald  
🔵 Aqua Neon  
🟣 Royal Purple  

Display Mode

Available profiles:

▫️ Minimal  
▪️ Pro  
🔳 Full  

Oscillator Visual Mode

Available styles:

📊 Neon Histogram  
🌊 Modern Pulse Wave  
➖ Clean Line Pro  
🕯️ Classic HA  
🕯️ Classic Candles  

Show Signal Line

Shows or hides the engine signal line.

Show Momentum Cloud

Shows the oscillator momentum cloud.

Show Zero Zone

Shows the oscillator zero zone.

Zero Zone Width

Controls the width of the zero zone.

Show Gradient Background Zones

Shows subtle oscillator background zones.

Show Extreme Stretch Markers

Shows extreme stretch pulse markers.

Show Oscillator Pulse Glow

Adds glow layers to modern oscillator visuals.

Show Neon Histogram

Controls histogram visibility when Neon Histogram mode is selected.

Show Oscillator Signal Dots

Shows LONG/SHORT dots in the oscillator panel.

Show Main Chart LONG / SHORT Labels

Shows signal labels on the main chart.

Main Chart Label Offset ATR

Controls how far signal labels are placed from price.

Show Main Chart Dashboard

Shows or hides the main dashboard.

Dashboard Position

Controls dashboard location.

Dashboard Size

Controls dashboard text size.

Show Main Chart Live Dashboard

Shows or hides the live scanning panel.

Live Panel Position

Controls live panel location.

Live Panel Size

Controls live panel text size.

Show Signal Pulse Background

Shows a soft background pulse when a signal appears.

Show Signal Candle Background

Highlights the exact signal candle with a vertical background.

Signal Candle Background Transparency

Controls the transparency of the signal candle highlight.

Color Candles During Active Trade

Colors price candles only while a projected trade is active.

Active Trade Candle Transparency

Controls active-trade candle coloring transparency.

Use Live Blinking Status Symbol

Enables the blinking live scanning dot.

Live Symbol Blink Seconds

Controls blink speed.


📦 TP / SL Box System

Show TP / SL Boxes on Main Chart

Enables TP/SL projection boxes.

SL ATR Length

ATR length used for stop-loss calculation.

SL ATR Multiplier

ATR multiplier used for SL distance.

Final TP Risk Reward

Final TP target multiple:

1R  
1.5R  
2R  
3R  
4R  
5R  

Max Stored TP / SL Trades

Maximum historical projection objects kept on chart.

If TP and SL Hit Same Bar

Controls same-bar ambiguity handling.

Show TP1 / TP2 / TP3 Lines

Shows TP level lines inside the projection box.

Initial TP / SL Box Length

Initial forward length of projection boxes.

Show TP / SL Result Label

Shows result labels after projected trade closes.


🛡️ Professional Controls

Max Main Signal Labels

Limits the number of main-chart signal labels to protect TradingView object limits.

Enable Dynamic Alert Messages

Enables alert() based dynamic alert messages.

Show Version Badge

Shows the V1.0 badge in the visual panels.


━━━━━━━━━━━━━━━━━━━━━━
🧠 WHAT MAKES THIS SCRIPT ORIGINAL
━━━━━━━━━━━━━━━━━━━━━━

Pulse Entry Engine uses familiar concepts such as:

⚡ oscillator momentum  
📈 signal lines  
🧭 EMA context  
🕰️ higher-timeframe filtering  
📦 ATR-based risk projection  
📊 dashboards  
🚨 alerts  

These components are not unique by themselves.

The originality of the script lies in how these components are organized into one workflow:

Pulse Engine  
→ Stretch Detection  
→ Signal Mode Filtering  
→ Score Classification  
→ HTF Bias Confirmation  
→ Modern Oscillator Visualization  
→ Star-Based Quality Label  
→ TP/SL Projection  
→ Active-Trade Candle Coloring  
→ Compact Dashboard  
→ Dynamic Alerts  

This structure is intended to give users a more organized way to review momentum-based entries.


━━━━━━━━━━━━━━━━━━━━━━
⚠️ IMPORTANT PRACTICAL NOTES
━━━━━━━━━━━━━━━━━━━━━━

The script’s behavior depends heavily on settings.

Signal frequency and visual output may change based on:

🎛️ selected Signal Mode  
🕯️ confirmation mode  
📈 EMA filter setting  
🧭 HTF bias mode  
🌊 oscillator visual mode  
🖥️ display profile  
📏 ATR multiplier  
🎯 TP RR setting  
📊 market  
⏱️ timeframe  
📉 symbol volatility  
📚 available historical bars  

A mode that appears cleaner on one symbol may not behave the same way on another.

The TP/SL boxes are visual projections based on the script’s rules.

They are not broker orders.

They do not account for real execution conditions.


━━━━━━━━━━━━━━━━━━━━━━
⚠️ LIMITATIONS AND SHORTCOMINGS
━━━━━━━━━━━━━━━━━━━━━━

This script has important limitations:

❌ It does not guarantee profitable trades.  
❌ It does not predict future price movement.  
❌ It does not replace risk management.  
❌ It does not execute trades.  
❌ It does not place orders.  
❌ It does not include broker slippage.  
❌ It does not include commissions.  
❌ It does not include spreads.  
❌ It uses bar-based chart data.  
❌ Same-bar TP/SL order is approximated by a user-selected rule.  
❌ Live Intrabar mode may change before candle close.  
❌ Higher-timeframe filters can lag.  
❌ EMA filters can conflict with certain market structures.  
❌ Momentum signals can fail in choppy markets.  
❌ Strong scores do not guarantee successful outcomes.  
❌ TP/SL projections are visual analysis tools, not trade instructions.  
❌ Historical visual behavior does not ensure future behavior.  

For these reasons, Pulse Entry Engine should be used as an educational decision-support tool, not as a standalone trading strategy.


━━━━━━━━━━━━━━━━━━━━━━
👤 WHO THIS SCRIPT MAY BE USEFUL FOR
━━━━━━━━━━━━━━━━━━━━━━

This script may be useful for traders who:

✅ study momentum-based entries  
✅ want a structured entry review tool  
✅ want a clean visual dashboard  
✅ want higher-timeframe context  
✅ want ATR-based TP/SL projection  
✅ want signal strength scoring  
✅ want modern oscillator visuals  
✅ want star-based quality labels  
✅ want active-trade candle coloring  
✅ want dynamic alerts  
✅ prefer organized chart-based analysis  
✅ want a free visual trading assistant for review and education  

It may be less suitable for users who:

❌ want guaranteed buy/sell signals  
❌ want a fully automated trading bot  
❌ do not want chart visuals  
❌ do not use technical analysis  
❌ expect one setting to work on every market  
❌ want an indicator that replaces their own decision-making  


━━━━━━━━━━━━━━━━━━━━━━
🧭 BEST PRACTICE SUGGESTIONS
━━━━━━━━━━━━━━━━━━━━━━

For cleaner review:

✅ Start with Bar Close confirmation.  
✅ Start with Balanced or Funded Account mode.  
✅ Use HTF Bias only when you want broader directional filtering.  
✅ Use Minimal display mode if the chart feels crowded.  
✅ Use Full display mode for screenshots, education, and live demonstrations.  
✅ Review signals together with market structure.  
✅ Avoid treating every label as an automatic trade.  
✅ Test the indicator on the specific symbols and timeframes you actually watch.  
✅ Combine the tool with your own analysis and risk rules.  


━━━━━━━━━━━━━━━━━━━━━━
🛡️ DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━

Pulse Entry Engine [V1.0] is provided for educational and informational purposes only.

It does not constitute financial, investment, or trading advice.

No indicator can guarantee future results.

Markets are uncertain, conditions change, and historical behavior does not ensure future performance.

Every user is responsible for their own analysis, validation, risk management, position sizing, and trading decisions.

Use this script as a structured decision-support and visual review framework, not as a promise of profitability.

## Source Code

````pine
//@version=6
indicator("Pulse Entry Engine [trade_w_samet]", "Pulse Entry Engine [trade_w_samet]", max_labels_count = 500, max_boxes_count = 500, max_lines_count = 500)

import TradingView/ta/11 as TVta

const string ENGINE_VERSION = "V1.0"
const string ENGINE_RELEASE = "Professional Release"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupSignal = "🎯 01 - Signal Logic"

const string ttSource = "Selects the price source used by the Pulse Entry Engine core. Default: Close. Use HL2/HLC3/OHLC4 only if you want a smoother or broader price input."
const string ttLength1 = "Primary Pulse Entry calculation length. Higher values create smoother but slower signals. Lower values react faster but may produce more noise."
const string ttLength2 = "Secondary Pulse Entry calculation length. Usually kept equal to Signal Length 1 for a balanced engine. Increase for smoother behavior, decrease for faster reaction."
const string ttSignalMode = "Selects the main signal preset. Each mode changes the engine thresholds, score requirement and filtering behavior.\n\nAggressive: earliest entry profile. Uses the lowest stretch and score requirements. Produces the most signals, but also the highest noise/risk. Best for testing, manual confirmation and fast opportunity scanning.\n\nBalanced: default profile. Uses your manual Distance Multiplier and Extreme Stretch settings. Designed for stable all-around use with normal signal frequency.\n\nScalping: lower-timeframe profile for M1-M5 style trading. Faster than Balanced, but stricter than Aggressive. Good for active intraday scanning.\n\nSwing: higher-quality profile for larger moves. Requires stronger stretch and higher score. EMA and Zero filters are forced on for cleaner directional context.\n\nFunded Account: strictest risk-control profile. Requires the strongest confirmation, highest score and forced EMA/Zero filters. Produces fewer signals and is designed to reduce low-quality trades and drawdown pressure.\n\nMode impact: Aggressive = more signals, Funded Account = fewer but stricter signals."
const string ttConfirmation = "Controls when a signal is allowed to confirm.\n\nBar Close: signals confirm only after the candle closes. This is the safest default and reduces repaint perception.\nLive Intrabar: signals can appear before candle close. Faster, but they may change while the candle is still open."
const string ttDistanceLength = "Lookback length used to calculate the average distance between the engine core and its signal line. This average becomes the baseline for stretch detection."
const string ttDistanceMultiplier = "Balanced mode stretch threshold. A signal needs the current engine distance to be this many times greater than its average distance. Higher = fewer but stronger signals."
const string ttExtremeMultiplier = "Balanced mode extreme stretch threshold. Used for extreme markers, score calculation and visual state classification. Higher = only the strongest stretches are marked as extreme."
const string ttResetWeak = "When enabled, the internal signal state resets after the engine distance becomes weak. This allows the next valid pulse in the same direction to appear later."
const string ttResetMultiplier = "Defines when distance is considered weak enough to reset the signal state. Lower values reset less often. Higher values reset more easily."
const string ttZeroFilter = "Filters signals using the engine zero line. Long setups require the engine oscillator below zero; short setups require the engine oscillator above zero. Swing and Funded Account modes force this filter on for stricter signals."

sourceInput  = input.source(close, "Source", group = groupSignal, display = display.none, tooltip = ttSource)
length1Input = input.int(100, "Signal Length 1", minval = 1, group = groupSignal, display = display.none, tooltip = ttLength1)
length2Input = input.int(100, "Signal Length 2", minval = 1, group = groupSignal, display = display.none, tooltip = ttLength2)
signalMode = input.string("Balanced", "Signal Mode", options = ["Aggressive", "Balanced", "Scalping", "Swing", "Funded Account"], group = groupSignal, display = display.none, tooltip = ttSignalMode)
signalConfirmationMode = input.string("Bar Close", "Signal Confirmation Mode", options = ["Bar Close", "Live Intrabar"], group = groupSignal, display = display.none, tooltip = ttConfirmation)
distanceLength = input.int(50, "Average Distance Length", minval = 1, group = groupSignal, display = display.none, tooltip = ttDistanceLength)
distanceMultiplier = input.float(1.50, "Distance Multiplier", minval = 0.1, step = 0.1, group = groupSignal, display = display.none, tooltip = ttDistanceMultiplier)
extremeMultiplier = input.float(2.00, "Extreme Stretch Multiplier", minval = 0.5, step = 0.1, group = groupSignal, display = display.none, tooltip = ttExtremeMultiplier)
resetWhenDistanceWeak = input.bool(true, "Reset When Distance Gets Weak", group = groupSignal, display = display.none, tooltip = ttResetWeak)
resetMultiplier = input.float(0.80, "Reset Multiplier", minval = 0.1, step = 0.1, group = groupSignal, display = display.none, tooltip = ttResetMultiplier)
useZeroFilter = input.bool(true, "Use Zero Filter", group = groupSignal, display = display.none, tooltip = ttZeroFilter)

modeDistanceMultiplier =
     signalMode == "Aggressive" ? 1.10 :
     signalMode == "Balanced" ? distanceMultiplier :
     signalMode == "Scalping" ? 1.25 :
     signalMode == "Swing" ? 1.70 :
     1.90

modeExtremeMultiplier =
     signalMode == "Aggressive" ? 1.70 :
     signalMode == "Balanced" ? extremeMultiplier :
     signalMode == "Scalping" ? 1.85 :
     signalMode == "Swing" ? 2.20 :
     2.35

modeMinScore =
     signalMode == "Aggressive" ? 45.0 :
     signalMode == "Balanced" ? 55.0 :
     signalMode == "Scalping" ? 60.0 :
     signalMode == "Swing" ? 70.0 :
     78.0

strictSignalMode = signalMode == "Swing" or signalMode == "Funded Account"
effectiveUseZeroFilter = useZeroFilter or strictSignalMode
signalConfirmationOk = signalConfirmationMode == "Live Intrabar" or barstate.isconfirmed

groupEMA = "📈 02 - EMA Filter"

const string ttEMAFilter = "Enables the EMA direction filter. In this engine the default logic is reversal-based: longs are allowed below EMA and shorts are allowed above EMA. Swing and Funded Account modes force this filter on."
const string ttEMALength = "EMA length used by the direction filter and dashboard bias. Higher values create a slower macro bias; lower values react faster."

useEMAFilter = input.bool(true, "Use EMA Filter", group = groupEMA, display = display.none, tooltip = ttEMAFilter)
emaLength = input.int(100, "EMA Length", minval = 1, group = groupEMA, display = display.none, tooltip = ttEMALength)
effectiveUseEMAFilter = useEMAFilter or strictSignalMode

groupHTF = "🧭 03 - HTF Bias Filter"

const string ttHTFBiasMode = "Adds a higher-timeframe directional filter.\n\nOff: no HTF filter.\nEMA 100: bullish above HTF EMA100, bearish below it.\nEMA 200: stronger macro trend filter using HTF EMA200.\nEngine HTF: bias is based on higher-timeframe engine core vs its signal line."
const string ttHTFTimeframe = "Higher timeframe used by the HTF Bias Filter. Example: 60 = 1H, 240 = 4H, D = Daily. Use a higher timeframe than your chart for cleaner directional context."

htfBiasMode = input.string("Off", "HTF Bias Mode", options = ["Off", "EMA 100", "EMA 200", "Engine HTF"], group = groupHTF, display = display.none, tooltip = ttHTFBiasMode)
htfTimeframeInput = input.timeframe("60", "HTF Timeframe", group = groupHTF, display = display.none, tooltip = ttHTFTimeframe)

groupVisual = "🎨 04 - Style"

const string ttVisualTheme = "Selects the full visual profile of the indicator.\n\nDark Emerald: dark professional green/cyan style.\nAqua Neon: bright cyber blue/pink style.\nRoyal Purple: luxury purple/gold style.\n\nTheme colors are managed internally, so color inputs are not shown in the Inputs tab."
const string ttDisplayProfile = "Controls the chart visual density.\n\nMinimal: keeps the chart cleaner by hiding optional visual layers such as dashboards, oscillator dots, pulse backgrounds, gradient zones and TP level lines. Main trade projections and signal labels remain usable.\n\nPro: balanced V1.0 layout. Uses your individual visibility settings and is the recommended default.\n\nFull: presentation mode. Forces major visual layers on for screenshots, demos and full feature previews."
const string ttDisplayMode = "Controls the oscillator visual style.\n\nModern Pulse Wave: default premium wave view with soft glow, cloud and clean signal dots.\nNeon Histogram: momentum-difference histogram between the engine and signal line. Useful for fast momentum reading.\nClean Line Pro: minimal professional line view with less visual noise.\nClassic HA: previous Heikin Ashi synthetic oscillator candle style.\nClassic Candles: previous raw synthetic oscillator candle style."
const string ttSignalLine = "Shows or hides the engine signal line. In Modern Pulse Wave mode it appears as a premium guide line; in Classic modes it behaves like the previous signal line."
const string ttCloud = "Shows the momentum cloud between the engine oscillator and the signal line. In Modern Pulse Wave and Clean Line Pro modes it creates a softer premium fill. In Neon Histogram mode you can turn it off for a cleaner histogram."
const string ttZeroZone = "Shows the zero zone around the oscillator midline. This helps identify whether the engine oscillator is in long-favored or short-favored territory."
const string ttZeroZoneWidth = "Controls the width of the zero zone around the zero line. Higher values create a wider neutral area."
const string ttGradientZones = "Adds subtle background zones based on the engine oscillator position relative to zero. Useful for quick directional context."
const string ttExtremeMarkers = "Shows modern pulse markers when the engine distance reaches the extreme stretch threshold. These are not direct trade signals; they highlight stretched conditions."
const string ttOscDots = "Shows oscillator-panel LONG/SHORT signal dots. Modern modes use a glow-dot structure: a larger soft outer dot plus a smaller sharp inner dot."
const string ttPulseGlow = "Adds soft glow layers to the Modern Pulse Wave oscillator line and signal dots. Turn off if you prefer a very clean minimal panel."
const string ttOscHistogram = "Shows the Neon Histogram when Oscillator Visual Mode is set to Neon Histogram. The histogram measures the distance between the engine core and signal line."
const string ttMainLabels = "Shows LONG/SHORT signal labels on the main price chart with the current score. Turn off if you want a cleaner chart."
const string ttLabelOffset = "Controls how far main chart LONG/SHORT labels are placed from price using ATR. Higher values move labels farther away from candles."
const string ttMainLabelSize = "Controls the size of the main chart BUY/SELL signal labels. Use Tiny/Small for compact charts and Large/Huge for screenshots, mobile viewing or stronger visual emphasis."
const string ttDashboard = "Shows the main dashboard with signal mode, theme, bias, stretch, score, signal state, confirmation and HTF status. Kept compact for a cleaner chart."
const string ttDashboardPosition = "Sets the main dashboard location on the price chart. Choose the position that does not block your candles or other tools."
const string ttDashboardSize = "Controls the main dashboard text size. Default is Small. Use Tiny/Small for compact charts and Large for presentations."
const string ttLivePanel = "Shows the compact live scanning panel. The lower info row is intentionally removed for a cleaner chart; position and size can be adjusted from the settings."
const string ttLivePanelPosition = "Sets the live scanning panel location on the price chart. Default: Bottom Center. Choose a location that does not block candles, TP/SL boxes or the main dashboard."
const string ttLivePanelSize = "Controls the live scanning panel text size. Default: Small. Tiny/Small are more compact; Large is better for presentations and screenshots."
const string ttPulseBg = "Flashes a subtle background pulse when a new LONG or SHORT signal appears. Helps visually catch fresh signals."
const string ttSignalCandleBg = "Highlights the exact price candle that produced a new confirmed LONG or SHORT signal with a vertical background stripe on the main chart. LONG uses the theme long color; SHORT uses the theme short color."
const string ttSignalCandleBgTransparency = "Controls how transparent the signal-candle vertical background stripe is. Higher values are lighter and less intrusive. Default: 88."
const string ttActiveTradeCandleColor = "Colors price candles only while a TP/SL projection trade is active. LONG trades use the theme long color; SHORT trades use the theme short color. Once the trade closes as TP1/TP2/TP3/SL, candle coloring stops."
const string ttActiveTradeCandleTransparency = "Controls the transparency of active-trade candle coloring. Lower values are stronger; higher values are softer. Default: 35."
const string ttLiveBlink = "Enables the blinking dot before LIVE SCANNING. The dot is visual only and does not affect signals."
const string ttBlinkSpeed = "Controls how fast the live scanning dot blinks. 1 second is the default. Higher values blink slower."

visualTheme = input.string("Royal Purple", "Visual Theme", options = ["Dark Emerald", "Aqua Neon", "Royal Purple"], group = groupVisual, display = display.none, tooltip = ttVisualTheme)
displayProfile = input.string("Pro", "Display Mode", options = ["Minimal", "Pro", "Full"], group = groupVisual, display = display.none, tooltip = ttDisplayProfile)
oscillatorVisualMode = input.string("Neon Histogram", "Oscillator Visual Mode", options = ["Modern Pulse Wave", "Neon Histogram", "Clean Line Pro", "Classic HA", "Classic Candles"], group = groupVisual, display = display.none, tooltip = ttDisplayMode)
showSignalLine = input.bool(true, "Show Signal Line", group = groupVisual, display = display.none, tooltip = ttSignalLine)
showCloud = input.bool(true, "Show Momentum Cloud", group = groupVisual, display = display.none, tooltip = ttCloud)
showZeroZone = input.bool(true, "Show Zero Zone", group = groupVisual, display = display.none, tooltip = ttZeroZone)
zeroZoneWidth = input.float(1.0, "Zero Zone Width", minval = 0.1, step = 0.1, group = groupVisual, display = display.none, tooltip = ttZeroZoneWidth)
showGradientZones = input.bool(true, "Show Gradient Background Zones", group = groupVisual, display = display.none, tooltip = ttGradientZones)
showExtremeMarkers = input.bool(true, "Show Extreme Stretch Markers", group = groupVisual, display = display.none, tooltip = ttExtremeMarkers)
showPulseGlow = input.bool(true, "Show Oscillator Pulse Glow", group = groupVisual, display = display.none, tooltip = ttPulseGlow)
showNeonHistogram = input.bool(true, "Show Neon Histogram", group = groupVisual, display = display.none, tooltip = ttOscHistogram)

showOscSignalDots = input.bool(true, "Show Oscillator Signal Dots", group = groupVisual, display = display.none, tooltip = ttOscDots)
showMainChartLabels = input.bool(true, "Show Main Chart LONG / SHORT Labels", group = groupVisual, display = display.none, tooltip = ttMainLabels)
mainLabelOffsetAtr = input.float(0.40, "Main Chart Label Offset ATR", minval = 0.0, step = 0.05, group = groupVisual, display = display.none, tooltip = ttLabelOffset)
mainSignalLabelSizeInput = input.string("Normal", "Buy / Sell Label Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupVisual, display = display.none, tooltip = ttMainLabelSize)

showDashboard = input.bool(true, "Show Main Chart Dashboard", group = groupVisual, display = display.none, tooltip = ttDashboard)
dashboardPositionInput = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Left", "Middle Center", "Bottom Right", "Bottom Left", "Bottom Center"], group = groupVisual, display = display.none, tooltip = ttDashboardPosition)
dashboardSizeInput = input.string("Small", "Dashboard Size", options = ["Tiny", "Small", "Medium", "Large"], group = groupVisual, display = display.none, tooltip = ttDashboardSize)
showMainLivePanel = input.bool(true, "Show Main Chart Live Dashboard", group = groupVisual, display = display.none, tooltip = ttLivePanel)
livePanelPositionInput = input.string("Bottom Center", "Live Panel Position", options = ["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Left", "Middle Center", "Bottom Right", "Bottom Left", "Bottom Center"], group = groupVisual, display = display.none, tooltip = ttLivePanelPosition)
livePanelSizeInput = input.string("Small", "Live Panel Size", options = ["Tiny", "Small", "Medium", "Large"], group = groupVisual, display = display.none, tooltip = ttLivePanelSize)
showPulseBg = input.bool(true, "Show Signal Pulse Background", group = groupVisual, display = display.none, tooltip = ttPulseBg)
showSignalCandleBg = input.bool(true, "Show Signal Candle Background", group = groupVisual, display = display.none, tooltip = ttSignalCandleBg)
signalCandleBgTransparency = input.int(88, "Signal Candle Background Transparency", minval = 0, maxval = 100, group = groupVisual, display = display.none, tooltip = ttSignalCandleBgTransparency)
showActiveTradeCandleColor = input.bool(true, "Color Candles During Active Trade", group = groupVisual, display = display.none, tooltip = ttActiveTradeCandleColor)
activeTradeCandleTransparency = input.int(35, "Active Trade Candle Transparency", minval = 0, maxval = 100, group = groupVisual, display = display.none, tooltip = ttActiveTradeCandleTransparency)

useLiveBlink = input.bool(true, "Use Live Blinking Status Symbol", group = groupVisual, display = display.none, tooltip = ttLiveBlink)
blinkSpeedSeconds = input.int(1, "Live Symbol Blink Seconds", minval = 1, maxval = 10, group = groupVisual, display = display.none, tooltip = ttBlinkSpeed)

groupRisk = "📦 05 - TP / SL Box System"

const string ttTPSLBoxes = "Shows TP/SL projection boxes on the main chart when a new signal appears. This is a visual trade projection, not an order execution system."
const string ttRiskAtrLength = "ATR length used to calculate the stop-loss distance. Higher values create smoother SL distance; lower values react faster to recent volatility."
const string ttSlAtrMultiplier = "Stop-loss distance multiplier based on ATR. Default: 2.5. Higher values create wider stops; lower values create tighter stops."
const string ttTPRR = "Final take-profit risk/reward target.\n\n1R: final TP equals the risk distance.\n1.5R: default balanced target.\n2R-5R: larger targets with lower hit frequency.\n\nTP1 is 25% of final TP distance, TP2 is 50%, TP3 is final TP."
const string ttMaxTrades = "Maximum number of historical TP/SL trade projections stored on the chart. Lower values improve chart cleanliness and performance."
const string ttSameBar = "Defines what happens if TP and SL are both touched on the same candle.\n\nSL: conservative assumption.\nTP1: allows TP1 if both sides are touched on the same bar."
const string ttTPLevelLines = "Shows TP1, TP2 and TP3 horizontal lines inside the TP projection box. Turn off for a cleaner chart."
const string ttInitialBars = "Initial horizontal length of TP/SL boxes when a trade appears. Default: 10 bars. If the trade stays active longer, boxes continue extending until the result is reached."
const string ttResultLabels = "Shows result labels when a projected trade closes as SL, TP1, TP2 or TP3."

showTPSLBoxes = input.bool(true, "Show TP / SL Boxes on Main Chart", group = groupRisk, display = display.none, tooltip = ttTPSLBoxes)
riskAtrLength = input.int(14, "SL ATR Length", minval = 1, group = groupRisk, display = display.none, tooltip = ttRiskAtrLength)
slAtrMultiplier = input.float(2.5, "SL ATR Multiplier", minval = 0.1, step = 0.1, group = groupRisk, display = display.none, tooltip = ttSlAtrMultiplier)
tpRRInput = input.string("1.5R", "Final TP Risk Reward", options = ["1R", "1.5R", "2R", "3R", "4R", "5R"], group = groupRisk, display = display.none, tooltip = ttTPRR)
maxStoredTrades = input.int(100, "Max Stored TP / SL Trades", minval = 20, maxval = 120, group = groupRisk, display = display.none, tooltip = ttMaxTrades)
sameBarResultInput = input.string("SL", "If TP and SL Hit Same Bar", options = ["SL", "TP1"], group = groupRisk, display = display.none, tooltip = ttSameBar)
showTPLevelLines = input.bool(true, "Show TP1 / TP2 / TP3 Lines", group = groupRisk, display = display.none, tooltip = ttTPLevelLines)
tpSlInitialBars = input.int(10, "Initial TP / SL Box Length (Bars)", minval = 1, maxval = 100, group = groupRisk, display = display.none, tooltip = ttInitialBars)
showResultLabels = input.bool(true, "Show TP / SL Result Label", group = groupRisk, display = display.none, tooltip = ttResultLabels)

groupSystem = "🛡️ 06 - Professional Controls"

const string ttMaxSignalLabels = "Maximum number of main-chart LONG/SHORT signal labels kept on the chart. Older labels are deleted automatically to protect TradingView object limits and keep the indicator stable."
const string ttDynamicAlerts = "Enables professional dynamic alert messages using alert(). These alerts include direction, score, mode, confirmation, HTF state, RR and ATR risk settings. You can still use the standard alertcondition options as well."
const string ttVersionBadge = "Shows the V1.0 release badge inside the main dashboard and live panel. This is visual only and does not affect signal logic."

maxSignalLabels = input.int(120, "Max Main Signal Labels", minval = 20, maxval = 500, group = groupSystem, display = display.none, tooltip = ttMaxSignalLabels)
enableDynamicAlerts = input.bool(true, "Enable Dynamic Alert Messages", group = groupSystem, display = display.none, tooltip = ttDynamicAlerts)
showVersionBadge = input.bool(true, "Show Version Badge", group = groupSystem, display = display.none, tooltip = ttVersionBadge)

// Display profile engine
isMinimalDisplay = displayProfile == "Minimal"
isFullDisplay = displayProfile == "Full"

showDashboardFinal = isFullDisplay ? true : isMinimalDisplay ? false : showDashboard
showMainLivePanelFinal = isFullDisplay ? true : isMinimalDisplay ? false : showMainLivePanel
showCloudFinal = isFullDisplay ? true : isMinimalDisplay ? false : showCloud
showZeroZoneFinal = isFullDisplay ? true : isMinimalDisplay ? false : showZeroZone
showGradientZonesFinal = isFullDisplay ? true : isMinimalDisplay ? false : showGradientZones
showExtremeMarkersFinal = isFullDisplay ? true : isMinimalDisplay ? false : showExtremeMarkers
showPulseGlowFinal = isFullDisplay ? true : isMinimalDisplay ? false : showPulseGlow
showNeonHistogramFinal = isFullDisplay ? true : showNeonHistogram
showOscSignalDotsFinal = isFullDisplay ? true : isMinimalDisplay ? false : showOscSignalDots
showMainChartLabelsFinal = isFullDisplay ? true : showMainChartLabels
showPulseBgFinal = isFullDisplay ? true : isMinimalDisplay ? false : showPulseBg
showSignalCandleBgFinal = isFullDisplay ? true : isMinimalDisplay ? false : showSignalCandleBg
showActiveTradeCandleColorFinal = showActiveTradeCandleColor
showTPSLBoxesFinal = isFullDisplay ? true : showTPSLBoxes
showTPLevelLinesFinal = isFullDisplay ? true : isMinimalDisplay ? false : showTPLevelLines
showResultLabelsFinal = isFullDisplay ? true : showResultLabels

// Color controls are intentionally not exposed as input.color() fields.
// Theme colors are handled by the selected Visual Theme, while TradingView
// exposes supported plot visuals in the indicator Style tab when possible.

// Dashboard layout controls
dashboardPosition =
     dashboardPositionInput == "Top Left" ? position.top_left :
     dashboardPositionInput == "Top Center" ? position.top_center :
     dashboardPositionInput == "Middle Right" ? position.middle_right :
     dashboardPositionInput == "Middle Left" ? position.middle_left :
     dashboardPositionInput == "Middle Center" ? position.middle_center :
     dashboardPositionInput == "Bottom Right" ? position.bottom_right :
     dashboardPositionInput == "Bottom Left" ? position.bottom_left :
     dashboardPositionInput == "Bottom Center" ? position.bottom_center :
     position.top_right

dashboardTextSize =
     dashboardSizeInput == "Tiny" ? size.tiny :
     dashboardSizeInput == "Small" ? size.small :
     dashboardSizeInput == "Large" ? size.large :
     size.normal

// Live panel layout controls
livePanelPosition =
     livePanelPositionInput == "Top Left" ? position.top_left :
     livePanelPositionInput == "Top Center" ? position.top_center :
     livePanelPositionInput == "Middle Right" ? position.middle_right :
     livePanelPositionInput == "Middle Left" ? position.middle_left :
     livePanelPositionInput == "Middle Center" ? position.middle_center :
     livePanelPositionInput == "Bottom Right" ? position.bottom_right :
     livePanelPositionInput == "Bottom Left" ? position.bottom_left :
     livePanelPositionInput == "Bottom Center" ? position.bottom_center :
     position.bottom_center

liveHeaderTextSize =
     livePanelSizeInput == "Tiny" ? size.tiny :
     livePanelSizeInput == "Small" ? size.tiny :
     livePanelSizeInput == "Large" ? size.normal :
     size.small

liveTitleTextSize =
     livePanelSizeInput == "Tiny" ? size.small :
     livePanelSizeInput == "Small" ? size.normal :
     livePanelSizeInput == "Large" ? size.huge :
     size.large

liveSubTextSize =
     livePanelSizeInput == "Tiny" ? size.tiny :
     livePanelSizeInput == "Small" ? size.tiny :
     livePanelSizeInput == "Large" ? size.normal :
     size.small

mainSignalLabelSize =
     mainSignalLabelSizeInput == "Tiny" ? size.tiny :
     mainSignalLabelSizeInput == "Small" ? size.small :
     mainSignalLabelSizeInput == "Large" ? size.large :
     mainSignalLabelSizeInput == "Huge" ? size.huge :
     size.normal

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// THEME ENGINE - FULL VISUAL PROFILES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

isDarkEmerald = visualTheme == "Dark Emerald"
isAquaNeon = visualTheme == "Aqua Neon"
isRoyalPurple = visualTheme == "Royal Purple"

themeSignalColor =
     isDarkEmerald ? color.rgb(255, 170, 45) :
     isAquaNeon ? color.rgb(0, 245, 255) :
     color.rgb(255, 204, 92)

themeLineColor =
     isDarkEmerald ? color.rgb(0, 174, 255) :
     isAquaNeon ? color.rgb(0, 245, 255) :
     color.rgb(190, 120, 255)

themeBullWeakColor =
     isDarkEmerald ? color.rgb(0, 100, 170) :
     isAquaNeon ? color.rgb(0, 125, 165) :
     color.rgb(88, 56, 155)

themeBullStrongColor =
     isDarkEmerald ? color.rgb(0, 190, 255) :
     isAquaNeon ? color.rgb(0, 235, 255) :
     color.rgb(255, 190, 80)

themeBullExtremeColor =
     isDarkEmerald ? color.rgb(0, 255, 220) :
     isAquaNeon ? color.rgb(95, 255, 235) :
     color.rgb(255, 225, 110)

themeBearWeakColor =
     isDarkEmerald ? color.rgb(70, 90, 210) :
     isAquaNeon ? color.rgb(75, 70, 170) :
     color.rgb(75, 38, 125)

themeBearStrongColor =
     isDarkEmerald ? color.rgb(70, 130, 255) :
     isAquaNeon ? color.rgb(255, 70, 170) :
     color.rgb(178, 92, 255)

themeBearExtremeColor =
     isDarkEmerald ? color.rgb(180, 90, 255) :
     isAquaNeon ? color.rgb(255, 55, 145) :
     color.rgb(255, 90, 210)

themeLongBadgeColor =
     isDarkEmerald ? color.rgb(0, 200, 110) :
     isAquaNeon ? color.rgb(0, 235, 200) :
     color.rgb(255, 187, 70)

themeShortBadgeColor =
     isDarkEmerald ? color.rgb(220, 45, 55) :
     isAquaNeon ? color.rgb(255, 65, 135) :
     color.rgb(186, 95, 255)

themeCenterPanelColor =
     isDarkEmerald ? color.rgb(18, 22, 24) :
     isAquaNeon ? color.rgb(3, 18, 30) :
     color.rgb(28, 16, 46)

themeTpBoxColor =
     isDarkEmerald ? color.rgb(0, 145, 80) :
     isAquaNeon ? color.rgb(0, 175, 145) :
     color.rgb(30, 160, 95)

themeSlBoxColor =
     isDarkEmerald ? color.rgb(185, 28, 42) :
     isAquaNeon ? color.rgb(210, 30, 70) :
     color.rgb(190, 45, 70)

themeTp1LineColor =
     isDarkEmerald ? color.black :
     isAquaNeon ? color.rgb(0, 255, 255) :
     color.rgb(255, 210, 90)

themeTp2LineColor =
     isDarkEmerald ? color.black :
     isAquaNeon ? color.rgb(0, 190, 255) :
     color.rgb(230, 170, 255)

themeTp3LineColor = themeTpBoxColor
themeTpResultColor = themeTpBoxColor
themeSlResultColor = themeSlBoxColor

// Dashboard / table profile colors.
themeDashboardHeaderBgColor =
     isDarkEmerald ? color.rgb(3, 12, 11) :
     isAquaNeon ? color.rgb(0, 20, 38) :
     color.rgb(43, 20, 76)

themeDashboardHeaderTextColor =
     isDarkEmerald ? color.rgb(235, 255, 246) :
     isAquaNeon ? color.rgb(0, 245, 255) :
     color.rgb(255, 213, 105)

themeDashboardLabelBgColor =
     isDarkEmerald ? color.rgb(12, 26, 24) :
     isAquaNeon ? color.rgb(2, 28, 52) :
     color.rgb(31, 18, 55)

themeDashboardLabelTextColor =
     isDarkEmerald ? color.rgb(175, 230, 205) :
     isAquaNeon ? color.rgb(160, 245, 255) :
     color.rgb(235, 205, 255)

themeDashboardValueBgColor =
     isDarkEmerald ? color.rgb(18, 34, 31) :
     isAquaNeon ? color.rgb(4, 36, 64) :
     color.rgb(42, 24, 72)

themeDashboardValueTextColor =
     isDarkEmerald ? color.rgb(245, 255, 250) :
     isAquaNeon ? color.rgb(230, 255, 255) :
     color.rgb(255, 236, 180)

themeDashboardBorderColor =
     isDarkEmerald ? color.rgb(0, 140, 95) :
     isAquaNeon ? color.rgb(0, 210, 255) :
     color.rgb(255, 188, 80)

// Live panel profile colors.
themeLiveHeaderBgColor =
     isDarkEmerald ? color.rgb(0, 8, 7) :
     isAquaNeon ? color.rgb(0, 10, 24) :
     color.rgb(20, 9, 35)

themeLiveHeaderTextColor =
     isDarkEmerald ? color.rgb(230, 255, 240) :
     isAquaNeon ? color.rgb(0, 245, 255) :
     color.rgb(255, 215, 110)

themeLiveTitleTextColor =
     isDarkEmerald ? color.rgb(0, 255, 120) :
     isAquaNeon ? color.rgb(0, 245, 255) :
     color.rgb(255, 210, 90)

themeLiveSubBgColor =
     isDarkEmerald ? color.rgb(10, 24, 22) :
     isAquaNeon ? color.rgb(3, 28, 52) :
     color.rgb(35, 17, 62)

themeLiveSubTextColor =
     isDarkEmerald ? color.rgb(230, 255, 242) :
     isAquaNeon ? color.rgb(220, 255, 255) :
     color.rgb(245, 220, 255)

themeMainLongLabelTextColor =
     isDarkEmerald ? color.white :
     isAquaNeon ? color.rgb(5, 15, 20) :
     color.rgb(20, 10, 25)

themeMainShortLabelTextColor =
     isDarkEmerald ? color.white :
     isAquaNeon ? color.white :
     color.white

themeTpResultLabelTextColor =
     isDarkEmerald ? color.white :
     isAquaNeon ? color.rgb(5, 15, 20) :
     color.rgb(20, 10, 25)

themeSlResultLabelTextColor =
     isDarkEmerald ? color.white :
     isAquaNeon ? color.white :
     color.white

// Dynamic state colors for dashboard cells.
themeScoreEliteColor =
     isDarkEmerald ? color.rgb(115, 40, 170) :
     isAquaNeon ? color.rgb(0, 160, 190) :
     color.rgb(255, 190, 80)

themeScoreHighColor =
     isDarkEmerald ? color.rgb(195, 115, 35) :
     isAquaNeon ? color.rgb(0, 115, 175) :
     color.rgb(125, 72, 205)

themeScoreMediumColor =
     isDarkEmerald ? color.rgb(35, 95, 160) :
     isAquaNeon ? color.rgb(42, 75, 170) :
     color.rgb(80, 42, 145)

themeScoreLowColor =
     isDarkEmerald ? color.rgb(55, 65, 70) :
     isAquaNeon ? color.rgb(34, 50, 70) :
     color.rgb(58, 45, 78)

themeScoreWeakColor =
     isDarkEmerald ? color.rgb(35, 40, 42) :
     isAquaNeon ? color.rgb(24, 36, 48) :
     color.rgb(38, 28, 52)

themeStretchExtremeColor =
     isDarkEmerald ? color.rgb(115, 40, 170) :
     isAquaNeon ? color.rgb(0, 190, 220) :
     color.rgb(255, 185, 80)

themeStretchStrongColor =
     isDarkEmerald ? color.rgb(195, 115, 35) :
     isAquaNeon ? color.rgb(0, 110, 180) :
     color.rgb(125, 72, 205)

themeStretchNormalColor =
     isDarkEmerald ? color.rgb(35, 95, 160) :
     isAquaNeon ? color.rgb(40, 70, 150) :
     color.rgb(80, 42, 145)

themeStretchWeakColor =
     isDarkEmerald ? color.rgb(50, 56, 58) :
     isAquaNeon ? color.rgb(28, 43, 58) :
     color.rgb(52, 40, 68)

themeNeutralCellColor =
     isDarkEmerald ? color.rgb(36, 42, 44) :
     isAquaNeon ? color.rgb(18, 38, 58) :
     color.rgb(50, 32, 70)

// Theme-specific opacity values.
themeTpBoxTransparency =
     isDarkEmerald ? 78 :
     isAquaNeon ? 80 :
     76

themeSlBoxTransparency =
     isDarkEmerald ? 78 :
     isAquaNeon ? 80 :
     76

themeBoxBorderTransparency =
     isDarkEmerald ? 0 :
     isAquaNeon ? 0 :
     5

themeTpMinorLineTransparency =
     isDarkEmerald ? 50 :
     isAquaNeon ? 25 :
     35

themeZeroLineColor =
     isDarkEmerald ? color.new(color.white, 70) :
     isAquaNeon ? color.new(color.rgb(0, 245, 255), 65) :
     color.new(color.rgb(255, 210, 90), 65)

themeZeroZoneFillColor =
     isDarkEmerald ? color.new(color.gray, 91) :
     isAquaNeon ? color.new(color.rgb(0, 140, 180), 91) :
     color.new(color.rgb(130, 70, 190), 90)

signalColor = themeSignalColor
lineColor = themeLineColor

bullWeakColor = themeBullWeakColor
bullStrongColor = themeBullStrongColor
bullExtremeColor = themeBullExtremeColor

bearWeakColor = themeBearWeakColor
bearStrongColor = themeBearStrongColor
bearExtremeColor = themeBearExtremeColor

longBadgeColor = themeLongBadgeColor
shortBadgeColor = themeShortBadgeColor
centerPanelColor = themeCenterPanelColor

tpBoxColor = themeTpBoxColor
slBoxColor = themeSlBoxColor
tp1LineColor = themeTp1LineColor
tp2LineColor = themeTp2LineColor
tp3LineColor = themeTp3LineColor
tpResultColor = themeTpResultColor
slResultColor = themeSlResultColor

dashboardHeaderBgColor = themeDashboardHeaderBgColor
dashboardHeaderTextColor = themeDashboardHeaderTextColor
dashboardLabelBgColor = themeDashboardLabelBgColor
dashboardLabelTextColor = themeDashboardLabelTextColor
dashboardValueBgColor = themeDashboardValueBgColor
dashboardValueTextColor = themeDashboardValueTextColor
dashboardBorderColor = themeDashboardBorderColor

liveHeaderBgColor = themeLiveHeaderBgColor
liveHeaderTextColor = themeLiveHeaderTextColor
liveTitleTextColor = themeLiveTitleTextColor
liveSubBgColor = themeLiveSubBgColor
liveSubTextColor = themeLiveSubTextColor

mainLongLabelTextColor = themeMainLongLabelTextColor
mainShortLabelTextColor = themeMainShortLabelTextColor
tpResultLabelTextColor = themeTpResultLabelTextColor
slResultLabelTextColor = themeSlResultLabelTextColor

scoreEliteColor = themeScoreEliteColor
scoreHighColor = themeScoreHighColor
scoreMediumColor = themeScoreMediumColor
scoreLowColor = themeScoreLowColor
scoreWeakColor = themeScoreWeakColor

stretchExtremeColor = themeStretchExtremeColor
stretchStrongColor = themeStretchStrongColor
stretchNormalColor = themeStretchNormalColor
stretchWeakColor = themeStretchWeakColor
neutralCellColor = themeNeutralCellColor

tpBoxTransparency = themeTpBoxTransparency
slBoxTransparency = themeSlBoxTransparency
boxBorderTransparency = themeBoxBorderTransparency
tpMinorLineTransparency = themeTpMinorLineTransparency
zeroLineColor = themeZeroLineColor
zeroZoneFillColor = themeZeroZoneFillColor


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PULSE ENTRY CORE CALCULATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[specialK, signal] = TVta.specialK(sourceInput, length1Input, length2Input)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMA FILTER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

emaValue = ta.ema(close, emaLength)

longEMAOk = not effectiveUseEMAFilter or close < emaValue
shortEMAOk = not effectiveUseEMAFilter or close > emaValue


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HTF BIAS FILTER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

htfClose = request.security(syminfo.tickerid, htfTimeframeInput, close, barmerge.gaps_off, barmerge.lookahead_off)
htfEma100 = request.security(syminfo.tickerid, htfTimeframeInput, ta.ema(close, 100), barmerge.gaps_off, barmerge.lookahead_off)
htfEma200 = request.security(syminfo.tickerid, htfTimeframeInput, ta.ema(close, 200), barmerge.gaps_off, barmerge.lookahead_off)
[htfSpecialK, htfSignal] = request.security(syminfo.tickerid, htfTimeframeInput, TVta.specialK(close, length1Input, length2Input), barmerge.gaps_off, barmerge.lookahead_off)

htfBiasDir =
     htfBiasMode == "EMA 100" ? (htfClose > htfEma100 ? 1 : htfClose < htfEma100 ? -1 : 0) :
     htfBiasMode == "EMA 200" ? (htfClose > htfEma200 ? 1 : htfClose < htfEma200 ? -1 : 0) :
     htfBiasMode == "Engine HTF" ? (htfSpecialK > htfSignal ? 1 : htfSpecialK < htfSignal ? -1 : 0) :
     0

htfFilterActive = htfBiasMode != "Off"
htfLongOk = not htfFilterActive or htfBiasDir >= 0
htfShortOk = not htfFilterActive or htfBiasDir <= 0

htfBiasText =
     not htfFilterActive ? "OFF" :
     htfBiasDir == 1 ? "BULLISH" :
     htfBiasDir == -1 ? "BEARISH" :
     "NEUTRAL"

htfBiasColorCell =
     not htfFilterActive ? neutralCellColor :
     htfBiasDir == 1 ? color.new(longBadgeColor, 12) :
     htfBiasDir == -1 ? color.new(shortBadgeColor, 12) :
     neutralCellColor


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DISTANCE / STRETCH LOGIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

distance = math.abs(specialK - signal)
avgDistance = ta.sma(distance, distanceLength)
distanceRatio = avgDistance > 0 ? distance / avgDistance : 0.0

distanceStrong = distanceRatio >= modeDistanceMultiplier
distanceExtreme = distanceRatio >= modeExtremeMultiplier
distanceWeak = distanceRatio <= resetMultiplier

stretchState =
     distanceRatio >= modeExtremeMultiplier ? "EXTREME" :
     distanceRatio >= modeDistanceMultiplier ? "STRONG" :
     distanceRatio >= 1.0 ? "NORMAL" :
     "WEAK"


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ZERO FILTER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

longZeroOk = not effectiveUseZeroFilter or specialK < 0
shortZeroOk = not effectiveUseZeroFilter or specialK > 0


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BASE SIGNAL CONDITIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

longBaseCondition = specialK < signal and distanceStrong and longZeroOk and longEMAOk
shortBaseCondition = specialK > signal and distanceStrong and shortZeroOk and shortEMAOk


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RAW SYNTHETIC OHLC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

skOpen = nz(specialK[1], specialK)
skClose = specialK
skHigh = math.max(skOpen, skClose)
skLow = math.min(skOpen, skClose)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HA SYNTHETIC OHLC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

haClose = (skOpen + skHigh + skLow + skClose) / 4.0

var float haOpen = na
haOpen := na(haOpen[1]) ? (skOpen + skClose) / 2.0 : (haOpen[1] + haClose[1]) / 2.0

haHigh = math.max(skHigh, math.max(haOpen, haClose))
haLow = math.min(skLow, math.min(haOpen, haClose))


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DISPLAY CORE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

oscModernMode = oscillatorVisualMode == "Modern Pulse Wave"
oscHistogramMode = oscillatorVisualMode == "Neon Histogram"
oscCleanLineMode = oscillatorVisualMode == "Clean Line Pro"
oscClassicHAMode = oscillatorVisualMode == "Classic HA"
oscClassicCandleMode = oscillatorVisualMode == "Classic Candles"

pulseWave = ta.ema(specialK, 3)
pulseSignal = ta.ema(signal, 3)
pulseHistogram = specialK - signal
pulseHistogramBase = 0.0

// Display references used by cloud, markers and oscillator dots.
displayCore = oscClassicHAMode ? haClose : oscClassicCandleMode ? skClose : pulseWave
displayLow = oscClassicHAMode ? haLow : oscClassicCandleMode ? skLow : math.min(pulseWave, pulseSignal)
displayHigh = oscClassicHAMode ? haHigh : oscClassicCandleMode ? skHigh : math.max(pulseWave, pulseSignal)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MAIN CHART LEVELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

atrValue = ta.atr(14)
riskAtrValue = ta.atr(riskAtrLength)

mainLongLabelY = low - atrValue * mainLabelOffsetAtr
mainShortLabelY = high + atrValue * mainLabelOffsetAtr

tpRR =
     tpRRInput == "1R" ? 1.0 :
     tpRRInput == "1.5R" ? 1.5 :
     tpRRInput == "2R" ? 2.0 :
     tpRRInput == "3R" ? 3.0 :
     tpRRInput == "4R" ? 4.0 :
     5.0


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// REVERSAL SCORE 0-100
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

setupDirection =
     specialK < signal ? 1 :
     specialK > signal ? -1 :
     0

directionScore = setupDirection != 0 ? 15.0 : 0.0
stretchScore = math.min(distanceRatio / modeExtremeMultiplier, 1.0) * 40.0

zeroScore =
     setupDirection == 1 and longZeroOk ? 15.0 :
     setupDirection == -1 and shortZeroOk ? 15.0 :
     not effectiveUseZeroFilter ? 15.0 :
     0.0

emaScore =
     setupDirection == 1 and longEMAOk ? 20.0 :
     setupDirection == -1 and shortEMAOk ? 20.0 :
     not effectiveUseEMAFilter ? 20.0 :
     0.0

strengthBonus = distanceStrong ? 10.0 : 0.0

reversalScoreRaw = directionScore + stretchScore + zeroScore + emaScore + strengthBonus
reversalScore = math.min(100.0, math.max(0.0, reversalScoreRaw))
reversalScoreRounded = math.round(reversalScore)

scoreState =
     reversalScore >= 85 ? "ELITE" :
     reversalScore >= 70 ? "HIGH" :
     reversalScore >= 55 ? "MEDIUM" :
     reversalScore >= 40 ? "LOW" :
     "WEAK"


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FINAL SIGNAL CONDITIONS / MODE SCORE FILTER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

modeScoreOk = reversalScore >= modeMinScore

longCondition = longBaseCondition and modeScoreOk and htfLongOk
shortCondition = shortBaseCondition and modeScoreOk and htfShortOk


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STATE SYSTEM
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var int signalState = 0

if resetWhenDistanceWeak and distanceWeak and not longCondition and not shortCondition
    signalState := 0

candidateLongSignal = longCondition and signalState != 1
candidateShortSignal = shortCondition and signalState != -1


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DYNAMIC COLORS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

rawBull = skClose >= skOpen
haBull = haClose >= haOpen

rawColor =
     distanceRatio >= modeExtremeMultiplier ? (rawBull ? bullExtremeColor : bearExtremeColor) :
     distanceRatio >= modeDistanceMultiplier ? (rawBull ? bullStrongColor : bearStrongColor) :
     distanceRatio >= 1.0 ? (rawBull ? bullWeakColor : bearWeakColor) :
     color.new(color.gray, 20)

haColor =
     distanceRatio >= modeExtremeMultiplier ? (haBull ? bullExtremeColor : bearExtremeColor) :
     distanceRatio >= modeDistanceMultiplier ? (haBull ? bullStrongColor : bearStrongColor) :
     distanceRatio >= 1.0 ? (haBull ? bullWeakColor : bearWeakColor) :
     color.new(color.gray, 20)

cloudColor =
     specialK > signal ?
     (distanceRatio >= modeExtremeMultiplier ? color.new(shortBadgeColor, 68) : color.new(bearStrongColor, 84)) :
     (distanceRatio >= modeExtremeMultiplier ? color.new(bullExtremeColor, 68) : color.new(bullStrongColor, 84))

scoreColor =
     reversalScore >= 85 ? scoreEliteColor :
     reversalScore >= 70 ? scoreHighColor :
     reversalScore >= 55 ? scoreMediumColor :
     reversalScore >= 40 ? scoreLowColor :
     scoreWeakColor


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BLINK ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

liveTimeSeconds = int(math.floor(timenow / 1000))
blinkPhase = int(math.floor(liveTimeSeconds / blinkSpeedSeconds)) % 2
blinkOn = blinkPhase == 0
symbolVisible = not useLiveBlink or blinkOn


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRADE MANAGEMENT ARRAYS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var box[] tradeTpBoxes = array.new_box()
var box[] tradeSlBoxes = array.new_box()
var line[] tradeTp1Lines = array.new_line()
var line[] tradeTp2Lines = array.new_line()
var line[] tradeTp3Lines = array.new_line()
var int[] tradeDirs = array.new_int()
var int[] tradeStartBars = array.new_int()
var float[] tradeEntries = array.new_float()
var float[] tradeTP1s = array.new_float()
var float[] tradeTP2s = array.new_float()
var float[] tradeTP3s = array.new_float()
var float[] tradeSLs = array.new_float()
var int[] tradeMaxTpHit = array.new_int()
var bool[] tradeActive = array.new_bool()
var label[] tradeResultLabels = array.new_label()


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// UPDATE ACTIVE TRADES BEFORE NEW SIGNAL FILTER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if showTPSLBoxesFinal and array.size(tradeDirs) > 0
    for i = array.size(tradeDirs) - 1 to 0
        isActive = array.get(tradeActive, i)

        if isActive
            dir = array.get(tradeDirs, i)
            startBar = array.get(tradeStartBars, i)

            tp1Price = array.get(tradeTP1s, i)
            tp2Price = array.get(tradeTP2s, i)
            tp3Price = array.get(tradeTP3s, i)
            slPrice = array.get(tradeSLs, i)

            tpBox = array.get(tradeTpBoxes, i)
            slBox = array.get(tradeSlBoxes, i)
            tp1Line = array.get(tradeTp1Lines, i)
            tp2Line = array.get(tradeTp2Lines, i)
            tp3Line = array.get(tradeTp3Lines, i)

            projectedRightBar = startBar + tpSlInitialBars
            activeRightBar = math.max(bar_index, projectedRightBar)

            box.set_right(tpBox, activeRightBar)
            box.set_right(slBox, activeRightBar)

            line.set_x2(tp1Line, activeRightBar)
            line.set_x2(tp2Line, activeRightBar)
            line.set_x2(tp3Line, activeRightBar)

            canCheckHit = bar_index > startBar

            longTp1Hit = dir == 1 and high >= tp1Price
            longTp2Hit = dir == 1 and high >= tp2Price
            longTp3Hit = dir == 1 and high >= tp3Price
            longSlHit = dir == 1 and low <= slPrice

            shortTp1Hit = dir == -1 and low <= tp1Price
            shortTp2Hit = dir == -1 and low <= tp2Price
            shortTp3Hit = dir == -1 and low <= tp3Price
            shortSlHit = dir == -1 and high >= slPrice

            tp1HitRaw = longTp1Hit or shortTp1Hit
            tp2HitRaw = longTp2Hit or shortTp2Hit
            tp3HitRaw = longTp3Hit or shortTp3Hit
            slHitRaw = longSlHit or shortSlHit

            priorMaxTpHit = array.get(tradeMaxTpHit, i)
            int currentMaxTpHit = priorMaxTpHit

            sameBarTpAndSl = canCheckHit and slHitRaw and (tp1HitRaw or tp2HitRaw or tp3HitRaw)

            if canCheckHit and not sameBarTpAndSl
                if tp1HitRaw
                    currentMaxTpHit := math.max(currentMaxTpHit, 1)
                if tp2HitRaw
                    currentMaxTpHit := math.max(currentMaxTpHit, 2)
                if tp3HitRaw
                    currentMaxTpHit := math.max(currentMaxTpHit, 3)

                array.set(tradeMaxTpHit, i, currentMaxTpHit)

            int resultLevel = 0

            if sameBarTpAndSl
                if sameBarResultInput == "TP1"
                    currentMaxTpHit := math.max(priorMaxTpHit, 1)
                    array.set(tradeMaxTpHit, i, currentMaxTpHit)
                    resultLevel := currentMaxTpHit
                else
                    resultLevel := priorMaxTpHit > 0 ? priorMaxTpHit : -1
            else
                if canCheckHit and tp3HitRaw
                    resultLevel := 3
                else if canCheckHit and slHitRaw
                    resultLevel := currentMaxTpHit > 0 ? currentMaxTpHit : -1

            if resultLevel != 0
                array.set(tradeActive, i, false)

                resultText =
                     resultLevel == 3 ? "TP3" :
                     resultLevel == 2 ? "TP2" :
                     resultLevel == 1 ? "TP1" :
                     "SL"

                resultPrice =
                     resultLevel == 3 ? tp3Price :
                     resultLevel == 2 ? tp2Price :
                     resultLevel == 1 ? tp1Price :
                     slPrice

                resultColor = resultLevel == -1 ? slResultColor : tpResultColor
                resultTextColor = resultLevel == -1 ? slResultLabelTextColor : tpResultLabelTextColor
                resultTooltip =
                     "Pulse Entry Engine [trade_w_samet]" + "\n\n" +
                     "Projected trade result: " + resultText + "\n" +
                     "Direction: " + (dir == 1 ? "LONG" : "SHORT") + "\n" +
                     "Entry: " + str.tostring(array.get(tradeEntries, i), format.mintick) + "\n" +
                     "TP1: " + str.tostring(tp1Price, format.mintick) + "\n" +
                     "TP2: " + str.tostring(tp2Price, format.mintick) + "\n" +
                     "TP3: " + str.tostring(tp3Price, format.mintick) + "\n" +
                     "SL: " + str.tostring(slPrice, format.mintick) + "\n" +
                     "RR: " + tpRRInput

                if showResultLabelsFinal
                    resultLabel = label.new(
                         x = bar_index,
                         y = resultPrice,
                         text = resultText,
                         xloc = xloc.bar_index,
                         yloc = yloc.price,
                         style = label.style_label_left,
                         textcolor = resultTextColor,
                         color = resultColor,
                         size = size.normal,
                         tooltip = resultTooltip,
                         force_overlay = true
                    )

                    array.set(tradeResultLabels, i, resultLabel)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NEW SIGNAL GATE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bool activeBlockingTrade = false
bool activeReplaceableTrade = false

if showTPSLBoxesFinal and array.size(tradeDirs) > 0
    for i = 0 to array.size(tradeDirs) - 1
        isActive = array.get(tradeActive, i)
        maxTp = array.get(tradeMaxTpHit, i)

        if isActive and maxTp == 0
            activeBlockingTrade := true

        if isActive and maxTp > 0
            activeReplaceableTrade := true

newLongSignal = candidateLongSignal and signalConfirmationOk and not activeBlockingTrade
newShortSignal = candidateShortSignal and signalConfirmationOk and not activeBlockingTrade
newTradeSignal = newLongSignal or newShortSignal

if newLongSignal
    signalState := 1

if newShortSignal
    signalState := -1


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CLOSE REPLACEABLE ACTIVE TRADES IF NEW SIGNAL APPEARS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if showTPSLBoxesFinal and newTradeSignal and activeReplaceableTrade and array.size(tradeDirs) > 0
    for i = array.size(tradeDirs) - 1 to 0
        isActive = array.get(tradeActive, i)
        maxTp = array.get(tradeMaxTpHit, i)

        if isActive and maxTp > 0
            array.set(tradeActive, i, false)

            tp1Price = array.get(tradeTP1s, i)
            tp2Price = array.get(tradeTP2s, i)
            tp3Price = array.get(tradeTP3s, i)

            tpBox = array.get(tradeTpBoxes, i)
            slBox = array.get(tradeSlBoxes, i)
            tp1Line = array.get(tradeTp1Lines, i)
            tp2Line = array.get(tradeTp2Lines, i)
            tp3Line = array.get(tradeTp3Lines, i)
            closeStartBar = array.get(tradeStartBars, i)
            projectedRightBar = closeStartBar + tpSlInitialBars
            closeRightBar = math.max(bar_index, projectedRightBar)

            box.set_right(tpBox, closeRightBar)
            box.set_right(slBox, closeRightBar)

            line.set_x2(tp1Line, closeRightBar)
            line.set_x2(tp2Line, closeRightBar)
            line.set_x2(tp3Line, closeRightBar)

            dir = array.get(tradeDirs, i)
            slPrice = array.get(tradeSLs, i)
            entryPrice = array.get(tradeEntries, i)

            resultText =
                 maxTp == 3 ? "TP3" :
                 maxTp == 2 ? "TP2" :
                 "TP1"

            resultPrice =
                 maxTp == 3 ? tp3Price :
                 maxTp == 2 ? tp2Price :
                 tp1Price

            resultTooltip =
                 "Pulse Entry Engine [trade_w_samet]" + "\n\n" +
                 "Projected trade result: " + resultText + "\n" +
                 "Direction: " + (dir == 1 ? "LONG" : "SHORT") + "\n" +
                 "Entry: " + str.tostring(entryPrice, format.mintick) + "\n" +
                 "TP1: " + str.tostring(tp1Price, format.mintick) + "\n" +
                 "TP2: " + str.tostring(tp2Price, format.mintick) + "\n" +
                 "TP3: " + str.tostring(tp3Price, format.mintick) + "\n" +
                 "SL: " + str.tostring(slPrice, format.mintick) + "\n" +
                 "RR: " + tpRRInput

            if showResultLabelsFinal
                resultLabel = label.new(
                     x = bar_index,
                     y = resultPrice,
                     text = resultText,
                     xloc = xloc.bar_index,
                     yloc = yloc.price,
                     style = label.style_label_left,
                     textcolor = tpResultLabelTextColor,
                     color = tpResultColor,
                     size = size.normal,
                     tooltip = resultTooltip,
                     force_overlay = true
                )

                array.set(tradeResultLabels, i, resultLabel)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CREATE NEW TP / SL TRADE BOXES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if showTPSLBoxesFinal and newLongSignal
    entryPrice = close
    slPrice = entryPrice - riskAtrValue * slAtrMultiplier
    riskValue = entryPrice - slPrice
    tp3Price = entryPrice + riskValue * tpRR
    tp1Price = entryPrice + (tp3Price - entryPrice) * 0.25
    tp2Price = entryPrice + (tp3Price - entryPrice) * 0.50

    tpBox = box.new(
         left = bar_index,
         top = tp3Price,
         right = bar_index + tpSlInitialBars,
         bottom = entryPrice,
         xloc = xloc.bar_index,
         border_color = color.new(tpBoxColor, boxBorderTransparency),
         bgcolor = color.new(tpBoxColor, tpBoxTransparency),
         force_overlay = true
    )

    slBox = box.new(
         left = bar_index,
         top = entryPrice,
         right = bar_index + tpSlInitialBars,
         bottom = slPrice,
         xloc = xloc.bar_index,
         border_color = color.new(slBoxColor, boxBorderTransparency),
         bgcolor = color.new(slBoxColor, slBoxTransparency),
         force_overlay = true
    )

    tp1Line = line.new(bar_index, tp1Price, bar_index + tpSlInitialBars, tp1Price, xloc = xloc.bar_index, color = showTPLevelLinesFinal ? color.new(tp1LineColor, tpMinorLineTransparency) : color.new(tp1LineColor, 100), width = 1, style = line.style_solid, force_overlay = true)
    tp2Line = line.new(bar_index, tp2Price, bar_index + tpSlInitialBars, tp2Price, xloc = xloc.bar_index, color = showTPLevelLinesFinal ? color.new(tp2LineColor, tpMinorLineTransparency) : color.new(tp2LineColor, 100), width = 1, style = line.style_solid, force_overlay = true)
    tp3Line = line.new(bar_index, tp3Price, bar_index + tpSlInitialBars, tp3Price, xloc = xloc.bar_index, color = showTPLevelLinesFinal ? tp3LineColor : color.new(tp3LineColor, 100), width = 2, style = line.style_solid, force_overlay = true)

    array.push(tradeTpBoxes, tpBox)
    array.push(tradeSlBoxes, slBox)
    array.push(tradeTp1Lines, tp1Line)
    array.push(tradeTp2Lines, tp2Line)
    array.push(tradeTp3Lines, tp3Line)
    array.push(tradeDirs, 1)
    array.push(tradeStartBars, bar_index)
    array.push(tradeEntries, entryPrice)
    array.push(tradeTP1s, tp1Price)
    array.push(tradeTP2s, tp2Price)
    array.push(tradeTP3s, tp3Price)
    array.push(tradeSLs, slPrice)
    array.push(tradeMaxTpHit, 0)
    array.push(tradeActive, true)
    array.push(tradeResultLabels, na)

if showTPSLBoxesFinal and newShortSignal
    entryPrice = close
    slPrice = entryPrice + riskAtrValue * slAtrMultiplier
    riskValue = slPrice - entryPrice
    tp3Price = entryPrice - riskValue * tpRR
    tp1Price = entryPrice - (entryPrice - tp3Price) * 0.25
    tp2Price = entryPrice - (entryPrice - tp3Price) * 0.50

    tpBox = box.new(
         left = bar_index,
         top = entryPrice,
         right = bar_index + tpSlInitialBars,
         bottom = tp3Price,
         xloc = xloc.bar_index,
         border_color = color.new(tpBoxColor, boxBorderTransparency),
         bgcolor = color.new(tpBoxColor, tpBoxTransparency),
         force_overlay = true
    )

    slBox = box.new(
         left = bar_index,
         top = slPrice,
         right = bar_index + tpSlInitialBars,
         bottom = entryPrice,
         xloc = xloc.bar_index,
         border_color = color.new(slBoxColor, boxBorderTransparency),
         bgcolor = color.new(slBoxColor, slBoxTransparency),
         force_overlay = true
    )

    tp1Line = line.new(bar_index, tp1Price, bar_index + tpSlInitialBars, tp1Price, xloc = xloc.bar_index, color = showTPLevelLinesFinal ? color.new(tp1LineColor, tpMinorLineTransparency) : color.new(tp1LineColor, 100), width = 1, style = line.style_solid, force_overlay = true)
    tp2Line = line.new(bar_index, tp2Price, bar_index + tpSlInitialBars, tp2Price, xloc = xloc.bar_index, color = showTPLevelLinesFinal ? color.new(tp2LineColor, tpMinorLineTransparency) : color.new(tp2LineColor, 100), width = 1, style = line.style_solid, force_overlay = true)
    tp3Line = line.new(bar_index, tp3Price, bar_index + tpSlInitialBars, tp3Price, xloc = xloc.bar_index, color = showTPLevelLinesFinal ? tp3LineColor : color.new(tp3LineColor, 100), width = 2, style = line.style_solid, force_overlay = true)

    array.push(tradeTpBoxes, tpBox)
    array.push(tradeSlBoxes, slBox)
    array.push(tradeTp1Lines, tp1Line)
    array.push(tradeTp2Lines, tp2Line)
    array.push(tradeTp3Lines, tp3Line)
    array.push(tradeDirs, -1)
    array.push(tradeStartBars, bar_index)
    array.push(tradeEntries, entryPrice)
    array.push(tradeTP1s, tp1Price)
    array.push(tradeTP2s, tp2Price)
    array.push(tradeTP3s, tp3Price)
    array.push(tradeSLs, slPrice)
    array.push(tradeMaxTpHit, 0)
    array.push(tradeActive, true)
    array.push(tradeResultLabels, na)

while array.size(tradeDirs) > maxStoredTrades
    oldTpBox = array.shift(tradeTpBoxes)
    oldSlBox = array.shift(tradeSlBoxes)
    oldTp1Line = array.shift(tradeTp1Lines)
    oldTp2Line = array.shift(tradeTp2Lines)
    oldTp3Line = array.shift(tradeTp3Lines)
    oldResultLabel = array.shift(tradeResultLabels)

    box.delete(oldTpBox)
    box.delete(oldSlBox)

    line.delete(oldTp1Line)
    line.delete(oldTp2Line)
    line.delete(oldTp3Line)

    if not na(oldResultLabel)
        label.delete(oldResultLabel)

    array.shift(tradeDirs)
    array.shift(tradeStartBars)
    array.shift(tradeEntries)
    array.shift(tradeTP1s)
    array.shift(tradeTP2s)
    array.shift(tradeTP3s)
    array.shift(tradeSLs)
    array.shift(tradeMaxTpHit)
    array.shift(tradeActive)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ACTIVE TRADE CANDLE COLORING
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

int activeTradeDir = 0

if showTPSLBoxesFinal and array.size(tradeDirs) > 0
    for i = 0 to array.size(tradeDirs) - 1
        if array.get(tradeActive, i)
            activeTradeDir := array.get(tradeDirs, i)

activeTradeCandleColor =
     showActiveTradeCandleColorFinal and activeTradeDir == 1 ? color.new(longBadgeColor, activeTradeCandleTransparency) :
     showActiveTradeCandleColorFinal and activeTradeDir == -1 ? color.new(shortBadgeColor, activeTradeCandleTransparency) :
     na

barcolor(activeTradeCandleColor, title = "Active Trade Candle Color")


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OPTIMIZED BACKGROUND ZONES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

gradientBg =
     showGradientZonesFinal and specialK < -zeroZoneWidth * 2.0 ? color.new(longBadgeColor, 92) :
     showGradientZonesFinal and specialK < -zeroZoneWidth ? color.new(longBadgeColor, 94) :
     showGradientZonesFinal and specialK < 0 ? color.new(longBadgeColor, 96) :
     showGradientZonesFinal and specialK > zeroZoneWidth * 2.0 ? color.new(shortBadgeColor, 92) :
     showGradientZonesFinal and specialK > zeroZoneWidth ? color.new(shortBadgeColor, 94) :
     showGradientZonesFinal and specialK > 0 ? color.new(shortBadgeColor, 96) :
     na

bgcolor(gradientBg, title = "Gradient Background Zones")

pulseBg =
     showPulseBgFinal and newLongSignal ? color.new(longBadgeColor, 86) :
     showPulseBgFinal and newShortSignal ? color.new(shortBadgeColor, 86) :
     na

bgcolor(pulseBg, title = "Signal Pulse Background")

// Main-chart vertical highlight on the exact signal candle.
signalCandleVerticalBg =
     showSignalCandleBgFinal and newLongSignal ? color.new(longBadgeColor, signalCandleBgTransparency) :
     showSignalCandleBgFinal and newShortSignal ? color.new(shortBadgeColor, signalCandleBgTransparency) :
     na

bgcolor(signalCandleVerticalBg, title = "Signal Candle Vertical Background", force_overlay = true)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ZERO ZONE - OUTPUT VALUES OFF SAFE VERSION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

zeroUpperPlot = plot(
     showZeroZoneFinal ? zeroZoneWidth : na,
     "Zero Zone Upper",
     color = color.new(color.gray, 100),
     display = display.pane
)

zeroLowerPlot = plot(
     showZeroZoneFinal ? -zeroZoneWidth : na,
     "Zero Zone Lower",
     color = color.new(color.gray, 100),
     display = display.pane
)

zeroMidPlot = plot(
     showZeroZoneFinal ? 0.0 : na,
     "Zero Line",
     color = zeroLineColor,
     linewidth = 1,
     display = display.pane
)

fill(zeroUpperPlot, zeroLowerPlot, color = showZeroZoneFinal ? zeroZoneFillColor : na, title = "Zero Zone Fill")


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MODERN OSCILLATOR VISUAL ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

modernWaveColor = pulseWave >= pulseSignal ? longBadgeColor : shortBadgeColor
cleanWaveColor = pulseWave >= pulseSignal ? lineColor : signalColor
histogramColor = pulseHistogram >= 0 ? color.new(longBadgeColor, distanceExtreme ? 8 : distanceStrong ? 18 : 35) : color.new(shortBadgeColor, distanceExtreme ? 8 : distanceStrong ? 18 : 35)
modernCloudColor = pulseWave >= pulseSignal ? color.new(longBadgeColor, distanceExtreme ? 72 : distanceStrong ? 82 : 90) : color.new(shortBadgeColor, distanceExtreme ? 72 : distanceStrong ? 82 : 90)
cleanCloudColor = pulseWave >= pulseSignal ? color.new(longBadgeColor, 88) : color.new(shortBadgeColor, 88)
classicCloudColor = cloudColor
activeCloudColor = oscModernMode ? modernCloudColor : oscCleanLineMode ? cleanCloudColor : classicCloudColor

// Hidden anchor plots for the premium momentum fill.
cloudCorePlot = plot(
     showCloudFinal and not oscHistogramMode ? displayCore : na,
     "Momentum Cloud Core",
     color = color.new(color.white, 100),
     display = display.pane
)

cloudSignalPlot = plot(
     showCloudFinal and not oscHistogramMode ? pulseSignal : na,
     "Momentum Cloud Signal",
     color = color.new(color.white, 100),
     display = display.pane
)

fill(cloudCorePlot, cloudSignalPlot, color = showCloudFinal and not oscHistogramMode ? activeCloudColor : na, title = "Momentum Cloud")

// Optional histogram mode for momentum-difference reading.
plot(
     oscHistogramMode and showNeonHistogramFinal ? pulseHistogram : na,
     "Neon Momentum Histogram",
     color = histogramColor,
     style = plot.style_columns,
     linewidth = 2,
     histbase = pulseHistogramBase,
     display = display.pane
)

plot(
     oscHistogramMode ? pulseHistogramBase : na,
     "Histogram Base Line",
     color = color.new(signalColor, 65),
     linewidth = 1,
     display = display.pane
)

// Modern Pulse Wave: layered glow + sharp core line.
plot(
     oscModernMode and showPulseGlowFinal ? pulseWave : na,
     "Modern Pulse Wave Glow Wide",
     color = color.new(modernWaveColor, 86),
     linewidth = 9,
     display = display.pane
)

plot(
     oscModernMode and showPulseGlowFinal ? pulseWave : na,
     "Modern Pulse Wave Glow",
     color = color.new(modernWaveColor, 72),
     linewidth = 5,
     display = display.pane
)

plot(
     oscModernMode ? pulseWave : na,
     "Modern Pulse Wave",
     color = modernWaveColor,
     linewidth = 3,
     display = display.pane
)

// Clean Line Pro: minimal line mode.
plot(
     oscCleanLineMode ? pulseWave : na,
     "Clean Line Pro Core",
     color = cleanWaveColor,
     linewidth = 2,
     display = display.pane
)

// Classic Candles / Classic HA retained as legacy options.
plotcandle(
     oscClassicCandleMode ? skOpen : na,
     oscClassicCandleMode ? skHigh : na,
     oscClassicCandleMode ? skLow : na,
     oscClassicCandleMode ? skClose : na,
     title = "Pulse Entry Classic Candles",
     color = rawColor,
     wickcolor = rawColor,
     bordercolor = rawColor,
     display = display.pane
)

plotcandle(
     oscClassicHAMode ? haOpen : na,
     oscClassicHAMode ? haHigh : na,
     oscClassicHAMode ? haLow : na,
     oscClassicHAMode ? haClose : na,
     title = "Pulse Entry Classic HA",
     color = haColor,
     wickcolor = haColor,
     bordercolor = haColor,
     display = display.pane
)

// Signal line adapts to the selected oscillator visual mode.
plot(
     showSignalLine and not oscHistogramMode ? pulseSignal : na,
     "Signal Glow",
     color = showPulseGlowFinal and oscModernMode ? color.new(signalColor, 78) : color.new(signalColor, 100),
     linewidth = 6,
     display = display.pane
)

plot(
     showSignalLine and not oscHistogramMode ? pulseSignal : na,
     "Signal Line",
     color = signalColor,
     linewidth = oscModernMode ? 2 : 1,
     display = display.pane
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MODERN EXTREME STRETCH MARKERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plotshape(
     showExtremeMarkersFinal and distanceExtreme and specialK > signal ? displayHigh : na,
     title = "Extreme Upper Pulse Glow",
     style = shape.circle,
     location = location.absolute,
     color = color.new(shortBadgeColor, 78),
     size = size.small,
     display = display.pane
)

plotshape(
     showExtremeMarkersFinal and distanceExtreme and specialK > signal ? displayHigh : na,
     title = "Extreme Upper Pulse",
     style = shape.circle,
     location = location.absolute,
     color = shortBadgeColor,
     size = size.tiny,
     display = display.pane
)

plotshape(
     showExtremeMarkersFinal and distanceExtreme and specialK < signal ? displayLow : na,
     title = "Extreme Lower Pulse Glow",
     style = shape.circle,
     location = location.absolute,
     color = color.new(longBadgeColor, 78),
     size = size.small,
     display = display.pane
)

plotshape(
     showExtremeMarkersFinal and distanceExtreme and specialK < signal ? displayLow : na,
     title = "Extreme Lower Pulse",
     style = shape.circle,
     location = location.absolute,
     color = longBadgeColor,
     size = size.tiny,
     display = display.pane
)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MODERN OSCILLATOR SIGNAL DOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

oscLongDotY = oscHistogramMode ? pulseHistogramBase : displayLow
oscShortDotY = oscHistogramMode ? pulseHistogramBase : displayHigh

plotshape(
     showOscSignalDotsFinal and showPulseGlowFinal and newLongSignal ? oscLongDotY : na,
     title = "Oscillator LONG Glow Dot",
     style = shape.circle,
     location = location.absolute,
     color = color.new(longBadgeColor, 74),
     size = size.large,
     display = display.pane
)

plotshape(
     showOscSignalDotsFinal and newLongSignal ? oscLongDotY : na,
     title = "Oscillator LONG Dot",
     style = shape.circle,
     location = location.absolute,
     color = longBadgeColor,
     size = size.small,
     display = display.pane
)

plotshape(
     showOscSignalDotsFinal and showPulseGlowFinal and newShortSignal ? oscShortDotY : na,
     title = "Oscillator SHORT Glow Dot",
     style = shape.circle,
     location = location.absolute,
     color = color.new(shortBadgeColor, 74),
     size = size.large,
     display = display.pane
)

plotshape(
     showOscSignalDotsFinal and newShortSignal ? oscShortDotY : na,
     title = "Oscillator SHORT Dot",
     style = shape.circle,
     location = location.absolute,
     color = shortBadgeColor,
     size = size.small,
     display = display.pane
)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL STRENGTH BAR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

signalStrengthBar =
     reversalScore >= 90 ? "█████" :
     reversalScore >= 80 ? "████░" :
     reversalScore >= 70 ? "███░░" :
     reversalScore >= 60 ? "██░░░" :
     reversalScore >= 50 ? "█░░░░" :
     "░░░░░"

signalStrengthText = signalStrengthBar + " " + str.tostring(reversalScoreRounded)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MAIN CHART DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

biasText = close > emaValue ? "SHORT ONLY" : close < emaValue ? "LONG ONLY" : "NEUTRAL"

signalText =
     newLongSignal ? "LONG PULSE" :
     newShortSignal ? "SHORT PULSE" :
     longCondition ? "LONG READY" :
     shortCondition ? "SHORT READY" :
     "WAIT"

signalColorCell =
     newLongSignal ? longBadgeColor :
     newShortSignal ? shortBadgeColor :
     longCondition ? color.new(longBadgeColor, 18) :
     shortCondition ? color.new(shortBadgeColor, 18) :
     neutralCellColor

biasColorCell =
     close > emaValue ? color.new(shortBadgeColor, 12) :
     close < emaValue ? color.new(longBadgeColor, 12) :
     neutralCellColor

stretchColorCell =
     stretchState == "EXTREME" ? stretchExtremeColor :
     stretchState == "STRONG" ? stretchStrongColor :
     stretchState == "NORMAL" ? stretchNormalColor :
     stretchWeakColor

var table dash = table.new(dashboardPosition, 2, 10, border_width = 1, frame_width = 1, force_overlay = true)

if barstate.islast
    if showDashboardFinal
        table.set_position(dash, dashboardPosition)
        table.set_border_color(dash, dashboardBorderColor)
        table.set_frame_color(dash, dashboardBorderColor)

        table.cell(dash, 0, 0, "PULSE ENTRY", text_color = dashboardHeaderTextColor, bgcolor = dashboardHeaderBgColor, text_size = dashboardTextSize)
        table.cell(dash, 1, 0, showVersionBadge ? ENGINE_VERSION : "VISUAL PRO", text_color = dashboardHeaderTextColor, bgcolor = dashboardHeaderBgColor, text_size = dashboardTextSize)

        table.cell(dash, 0, 1, "Signal Mode", text_color = dashboardLabelTextColor, bgcolor = dashboardLabelBgColor, text_size = dashboardTextSize)
        table.cell(dash, 1, 1, signalMode, text_color = dashboardValueTextColor, bgcolor = dashboardValueBgColor, text_size = dashboardTextSize)

        table.cell(dash, 0, 2, "Theme", text_color = dashboardLabelTextColor, bgcolor = dashboardLabelBgColor, text_size = dashboardTextSize)
        table.cell(dash, 1, 2, visualTheme, text_color = dashboardHeaderTextColor, bgcolor = centerPanelColor, text_size = dashboardTextSize)

        table.cell(dash, 0, 3, "Bias", text_color = dashboardLabelTextColor, bgcolor = dashboardLabelBgColor, text_size = dashboardTextSize)
        table.cell(dash, 1, 3, biasText, text_color = dashboardValueTextColor, bgcolor = biasColorCell, text_size = dashboardTextSize)

        table.cell(dash, 0, 4, "Stretch", text_color = dashboardLabelTextColor, bgcolor = dashboardLabelBgColor, text_size = dashboardTextSize)
        table.cell(dash, 1, 4, stretchState + " | " + str.tostring(distanceRatio, "#.##") + "x", text_color = dashboardValueTextColor, bgcolor = stretchColorCell, text_size = dashboardTextSize)

        table.cell(dash, 0, 5, "Score", text_color = dashboardLabelTextColor, bgcolor = dashboardLabelBgColor, text_size = dashboardTextSize)
        table.cell(dash, 1, 5, str.tostring(reversalScoreRounded) + " / 100 | " + scoreState, text_color = dashboardValueTextColor, bgcolor = scoreColor, text_size = dashboardTextSize)

        table.cell(dash, 0, 6, "Strength", text_color = dashboardLabelTextColor, bgcolor = dashboardLabelBgColor, text_size = dashboardTextSize)
        table.cell(dash, 1, 6, signalStrengthText, text_color = dashboardValueTextColor, bgcolor = scoreColor, text_size = dashboardTextSize)

        table.cell(dash, 0, 7, "Signal", text_color = dashboardLabelTextColor, bgcolor = dashboardLabelBgColor, text_size = dashboardTextSize)
        table.cell(dash, 1, 7, signalText, text_color = dashboardValueTextColor, bgcolor = signalColorCell, text_size = dashboardTextSize)

        table.cell(dash, 0, 8, "Confirm", text_color = dashboardLabelTextColor, bgcolor = dashboardLabelBgColor, text_size = dashboardTextSize)
        table.cell(dash, 1, 8, signalConfirmationMode, text_color = dashboardValueTextColor, bgcolor = dashboardValueBgColor, text_size = dashboardTextSize)

        table.cell(dash, 0, 9, "HTF Bias", text_color = dashboardLabelTextColor, bgcolor = dashboardLabelBgColor, text_size = dashboardTextSize)
        table.cell(dash, 1, 9, htfBiasMode == "Off" ? "OFF" : htfBiasText + " | " + htfTimeframeInput + " | " + htfBiasMode, text_color = dashboardValueTextColor, bgcolor = htfBiasColorCell, text_size = dashboardTextSize)
    else
        table.clear(dash, 0, 0, 1, 9)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MAIN CHART LIVE STATUS DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

centerBaseTitle = "LIVE SCANNING"
centerSymbol = "● "

blankSymbol = "⠀ "
centerTitle = (symbolVisible ? centerSymbol : blankSymbol) + centerBaseTitle

centerBg = color.new(centerPanelColor, 8)
centerTextColor = liveTitleTextColor

var table mainLivePanel = table.new(
     livePanelPosition,
     1,
     2,
     border_width = 1,
     force_overlay = true
)

if barstate.islast
    if showMainLivePanelFinal
        table.set_position(mainLivePanel, livePanelPosition)

        table.cell(
             mainLivePanel,
             0,
             0,
             useLiveBlink ? "PULSE ENTRY ENGINE " + ENGINE_VERSION + "  |  LIVE" : "PULSE ENTRY ENGINE " + ENGINE_VERSION,
             text_color = liveHeaderTextColor,
             bgcolor = liveHeaderBgColor,
             text_size = liveHeaderTextSize
        )

        table.cell(
             mainLivePanel,
             0,
             1,
             centerTitle,
             text_color = centerTextColor,
             bgcolor = centerBg,
             text_size = liveTitleTextSize
        )

    else
        table.clear(mainLivePanel, 0, 0, 0, 1)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MAIN CHART LABEL SYSTEM
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var label[] mainSignalLabels = array.new_label()

scoreStars =
     reversalScore >= 96 ? "★★★★★" :
     reversalScore >= 92 ? "★★★★" :
     reversalScore >= 88 ? "★★★" :
     reversalScore >= 84 ? "★★" :
     reversalScore >= 80 ? "★" :
     "☆"

mainLongLabelText = "▲ LONG PULSE\n" + scoreStars
mainShortLabelText = "▼ SHORT PULSE\n" + scoreStars

mainLongLabelTooltip =
     "Pulse Entry Engine [trade_w_samet]" + "\n\n" +
     "Signal: LONG PULSE" + "\n" +
     "Ticker: " + syminfo.ticker + "\n" +
     "Timeframe: " + timeframe.period + "\n" +
     "Mode: " + signalMode + "\n" +
     "Confirmation: " + signalConfirmationMode + "\n" +
     "HTF Bias: " + htfBiasText + (htfFilterActive ? " | " + htfTimeframeInput + " | " + htfBiasMode : "") + "\n" +
     "Score: " + str.tostring(reversalScoreRounded) + " / 100 | " + scoreState + "\n" +
     "Stretch: " + str.tostring(distanceRatio, "#.##") + "x | " + stretchState + "\n" +
     "Risk: ATR " + str.tostring(slAtrMultiplier, "#.##") + " | TP " + tpRRInput

mainShortLabelTooltip =
     "Pulse Entry Engine [trade_w_samet]" + "\n\n" +
     "Signal: SHORT PULSE" + "\n" +
     "Ticker: " + syminfo.ticker + "\n" +
     "Timeframe: " + timeframe.period + "\n" +
     "Mode: " + signalMode + "\n" +
     "Confirmation: " + signalConfirmationMode + "\n" +
     "HTF Bias: " + htfBiasText + (htfFilterActive ? " | " + htfTimeframeInput + " | " + htfBiasMode : "") + "\n" +
     "Score: " + str.tostring(reversalScoreRounded) + " / 100 | " + scoreState + "\n" +
     "Stretch: " + str.tostring(distanceRatio, "#.##") + "x | " + stretchState + "\n" +
     "Risk: ATR " + str.tostring(slAtrMultiplier, "#.##") + " | TP " + tpRRInput

if newLongSignal and showMainChartLabelsFinal
    mainSignalLabel = label.new(
         x = bar_index,
         y = mainLongLabelY,
         text = mainLongLabelText,
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_label_up,
         textcolor = mainLongLabelTextColor,
         color = longBadgeColor,
         size = mainSignalLabelSize,
         tooltip = mainLongLabelTooltip,
         force_overlay = true
    )

    array.push(mainSignalLabels, mainSignalLabel)

if newShortSignal and showMainChartLabelsFinal
    mainSignalLabel = label.new(
         x = bar_index,
         y = mainShortLabelY,
         text = mainShortLabelText,
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_label_down,
         textcolor = mainShortLabelTextColor,
         color = shortBadgeColor,
         size = mainSignalLabelSize,
         tooltip = mainShortLabelTooltip,
         force_overlay = true
    )

    array.push(mainSignalLabels, mainSignalLabel)

while array.size(mainSignalLabels) > maxSignalLabels
    oldMainSignalLabel = array.shift(mainSignalLabels)
    if not na(oldMainSignalLabel)
        label.delete(oldMainSignalLabel)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(newLongSignal, title = "Pulse Entry V1.0 LONG", message = "Pulse Entry Engine V1.0 LONG signal on {{ticker}} / {{interval}}")
alertcondition(newShortSignal, title = "Pulse Entry V1.0 SHORT", message = "Pulse Entry Engine V1.0 SHORT signal on {{ticker}} / {{interval}}")
alertcondition(newLongSignal or newShortSignal, title = "Pulse Entry V1.0 Signal", message = "Pulse Entry Engine V1.0 LONG/SHORT signal on {{ticker}} / {{interval}}")
alertcondition(distanceExtreme, title = "Pulse Entry V1.0 Extreme Stretch", message = "Pulse Entry Engine V1.0 extreme stretch detected on {{ticker}} / {{interval}}")

signalDirectionText = newLongSignal ? "LONG" : newShortSignal ? "SHORT" : "NONE"
dynamicAlertMessage =
     "Pulse Entry Engine " + ENGINE_VERSION + "\n" +
     "Direction: " + signalDirectionText + "\n" +
     "Ticker: " + syminfo.ticker + "\n" +
     "Timeframe: " + timeframe.period + "\n" +
     "Mode: " + signalMode + "\n" +
     "Confirmation: " + signalConfirmationMode + "\n" +
     "HTF Bias: " + htfBiasText + (htfFilterActive ? " | " + htfTimeframeInput + " | " + htfBiasMode : "") + "\n" +
     "Score: " + str.tostring(reversalScoreRounded) + " / 100 | " + scoreState + "\n" +
     "Stretch: " + str.tostring(distanceRatio, "#.##") + "x | " + stretchState + "\n" +
     "Risk: ATR " + str.tostring(slAtrMultiplier, "#.##") + " | TP " + tpRRInput

if enableDynamicAlerts and newTradeSignal
    alert(dynamicAlertMessage, alert.freq_once_per_bar)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HISTORY CHECK
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if last_bar_index < 724
    runtime.error("Not enough history on the chart. Choose a symbol or timeframe with a larger number of bars.")
````
