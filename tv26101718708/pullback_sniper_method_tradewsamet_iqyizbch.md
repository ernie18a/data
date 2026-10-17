# Pullback Sniper Method [trade_w_samet]

- url: https://www.tradingview.com/script/IqyiZbCh-Pullback-Sniper-Method-trade-w-samet/
- type: indicator
- pine_id: PUB;86718046848d4570ab30779991dd7026
- version: 2.0

## Description

🎯 Pullback Sniper Method [trade_w_samet]

Pullback Sniper Method [trade_w_samet] is a free open-source pullback, breakout, and trade-visualization indicator designed to help traders analyze structured trend-continuation setups directly on the price chart.

This script combines:

📈 EMA-based trend context
🚀 breakout detection
🎯 pullback confirmation logic
✅ Fast / Balanced / Strict confirmation modes
🧠 optional McGinley and RSI filters
📦 ATR-based TP/SL projection boxes
🎯 TP1 / TP2 / TP3 tracking
🛑 SL tracking
🏷️ result labels
⭐ signal quality tooltip information
📊 statistics table
💎 premium-style dashboard
🎨 multiple visual themes
🚨 alert conditions

The goal of Pullback Sniper Method is not to predict the future or provide guaranteed buy/sell instructions.

Its purpose is to help users visually study:

⚡ trend continuation behavior
🎯 pullback quality
📈 breakout-following structure
🧠 confirmation strength
📦 projected risk/reward zones
📊 historical visual outcomes
💎 dashboard-based system feedback
🚨 alert-based monitoring

Pullback Sniper Method should be treated as a structured chart-analysis and educational decision-support tool, not as financial advice, not as an automated trading system, and not as a guarantee of profitable results.

━━━━━━━━━━━━━━━━━━━━━━
🔓 OPEN-SOURCE PUBLICATION NOTE
━━━━━━━━━━━━━━━━━━━━━━

This script is published as an open-source educational and visual market-analysis tool.

The source code is visible so users can inspect, review, understand, and learn from the logic.

The description is intentionally detailed because many users do not inspect every part of the Pine Script code line by line.

The purpose of this page is to explain:

✅ what the script does
✅ how the main logic works
✅ how signals are created
✅ what the trend engine checks
✅ how pullbacks are validated
✅ how confirmation modes differ
✅ how TP/SL projections are drawn
✅ how historical trade visuals are managed
✅ what the statistics table means
✅ what the premium dashboard means
✅ what the quality score tooltip represents
✅ what the limitations are
✅ how the indicator should and should not be used

Pullback Sniper Method is designed to support structured analysis.

It does not promise profitable results.
It does not remove market risk.
It does not execute trades.
It does not place broker orders.
It should not be used as a blind buy/sell system.

It is best used as a visual framework for reviewing trend, breakout, pullback, confirmation, and projected risk/reward behavior.

━━━━━━━━━━━━━━━━━━━━━━
📌 OVERVIEW
━━━━━━━━━━━━━━━━━━━━━━

At a high level, Pullback Sniper Method does the following:

📈 Calculates a trend engine using Fast EMA, Slow EMA, and EMA slope.
🚀 Detects breakout conditions after trend alignment.
🎯 Waits for price to pull back toward the Pullback EMA.
✅ Confirms entries using Fast, Balanced, or Strict confirmation logic.
🧠 Applies optional McGinley Dynamic distance filtering.
📊 Applies optional RSI directional filtering.
🧊 Uses a cooldown system to reduce signal clustering.
📦 Draws ATR-based TP/SL projection boxes.
🎯 Tracks TP1, TP2, TP3, and SL visually.
🏷️ Displays active TP labels and final result labels.
🗂️ Keeps historical TP/SL visuals on the chart.
⭐ Displays a Quality Score only inside the STRONG label tooltip.
📊 Builds a statistics table for TP1, TP2, TP3, SL, Total, and Win Rate.
💎 Builds a premium dashboard with deeper internal performance metrics.
🎨 Includes three visual themes.
🚨 Includes alert conditions for strong signals and trade outcomes.

This makes the script more than a simple signal label tool.

It is a complete pullback-analysis framework built around trend context, breakout confirmation, pullback behavior, ATR-based visual planning, and historical result review.

━━━━━━━━━━━━━━━━━━━━━━
🧠 CORE IDEA
━━━━━━━━━━━━━━━━━━━━━━

The core idea behind Pullback Sniper Method is simple:

A trend continuation setup should not be judged from one isolated candle.

A single breakout, one EMA touch, one candle close, or one label is usually not enough by itself.

Market context matters.

For that reason, Pullback Sniper Method combines several layers:

📈 trend alignment
🚀 breakout structure
🎯 pullback location
✅ confirmation candle behavior
📏 ATR-based distance filtering
🧠 optional McGinley distance filtering
📊 optional RSI direction filtering
📦 projected TP/SL structure
📊 visual statistics
💎 dashboard feedback

The indicator does not attempt to mark every possible move.

Instead, it attempts to make pullback-based trend continuation conditions easier to read, compare, and review.

The purpose is not to create more signals.

The purpose is to make signal conditions more structured and understandable.

━━━━━━━━━━━━━━━━━━━━━━
🧩 WHY THIS SCRIPT IS NOT A SIMPLE BUY/SELL INDICATOR
━━━━━━━━━━━━━━━━━━━━━━

Pullback Sniper Method is not intended to behave like a simple “buy here / sell here” script.

It is built as a structured workflow:

Trend Engine
→ Breakout Detection
→ Pullback Wait
→ Confirmation Mode
→ Optional Filters
→ STRONG Signal Label
→ Quality Tooltip
→ TP/SL Projection
→ Active Trade Visualization
→ Result Tracking
→ Statistics Review
→ Dashboard Review
→ Alerts

Each part has a specific role.

📈 The Trend Engine defines directional context.
🚀 The Breakout Engine identifies fresh movement beyond recent highs or lows.
🎯 The Pullback Engine waits for price to return toward the pullback EMA.
✅ The Confirmation Engine decides whether the reaction is strong enough.
🧠 The optional filters reduce signals that do not meet additional conditions.
⭐ The Quality Score tooltip gives extra signal context without changing the signal.
📦 The TP/SL boxes provide projected visual structure.
📊 The statistics table summarizes historical visual outcomes.
💎 The dashboard gives a broader state and performance-style overview.
🚨 The alert system helps monitor the script without constantly watching the chart.

This makes the script a full review environment, not a one-condition signal tool.

━━━━━━━━━━━━━━━━━━━━━━
⚙️ HOW THE SCRIPT WORKS
━━━━━━━━━━━━━━━━━━━━━━

📈 TREND ENGINE

The Trend Engine is based on three key components:

⚡ Fast EMA
🐢 Slow EMA
📐 Fast EMA slope

The default structure uses:

Fast EMA = 50
Slow EMA = 200
Pullback EMA = 21
Slope Lookback = 5

For bullish context, the script checks whether:

🟢 Fast EMA is above Slow EMA
🟢 Price is above Slow EMA
🟢 Fast EMA is rising compared to previous bars

For bearish context, the script checks whether:

🔴 Fast EMA is below Slow EMA
🔴 Price is below Slow EMA
🔴 Fast EMA is falling compared to previous bars

This helps the script avoid treating every price move as a valid pullback opportunity.

The trend engine creates the directional foundation for the rest of the logic.

━━━━━━━━━━━━━━━━━━━━━━
🚀 BREAKOUT ENGINE
━━━━━━━━━━━━━━━━━━━━━━

After trend alignment is detected, the script looks for a breakout.

For bullish setups, price must close above the recent breakout high.

For bearish setups, price must close below the recent breakout low.

The breakout engine uses:

🚀 Breakout Lookback
🛑 Invalidation Lookback
🔥 Minimum Breakout Body / ATR

The breakout candle must also have enough body size relative to ATR.

This is important because very small breakouts can create low-quality setup conditions.

The breakout does not immediately create a STRONG label.

Instead, it activates a setup state.

After that, the script waits for a pullback.

━━━━━━━━━━━━━━━━━━━━━━
🎯 PULLBACK SETUP ENGINE
━━━━━━━━━━━━━━━━━━━━━━

Once a breakout setup is active, the script waits for price to return toward the Pullback EMA.

For a bullish setup:

🟢 Price must pull back toward the Pullback EMA.
🟢 The setup must not be invalidated.
🟢 Enough bars must have passed after breakout.

For a bearish setup:

🔴 Price must pull back toward the Pullback EMA from the opposite direction.
🔴 The setup must not be invalidated.
🔴 Enough bars must have passed after breakout.

The script also includes a maximum number of bars to find the pullback.

If no valid pullback appears within that window, the setup expires.

This prevents old breakout conditions from staying active forever.

━━━━━━━━━━━━━━━━━━━━━━
✅ CONFIRMATION ENGINE
━━━━━━━━━━━━━━━━━━━━━━

After a valid pullback touch, the script waits for confirmation.

There are three confirmation modes:

⚡ Fast
⚖️ Balanced
🛡️ Strict

⚡ Fast Mode

Fast mode is the earliest and simplest confirmation style.

It checks whether price closes back in the expected direction relative to the Pullback EMA.

This mode can react faster but may produce more noise.

Useful for:

• faster review
• active chart monitoring
• lower-timeframe analysis
• users who prefer earlier signals

⚖️ Balanced Mode

Balanced mode is the default middle-ground profile.

It requires directional candle behavior and also considers either a break of the previous candle level or wick/rejection behavior.

This helps the signal feel more structured than a basic close-based trigger.

Useful for:

• general chart review
• balanced signal frequency
• intraday analysis
• users who want neither too many nor too few signals

🛡️ Strict Mode

Strict mode is the most selective confirmation profile.

It requires stronger candle body behavior and a more decisive close.

This can reduce signal frequency.

Useful for:

• cleaner setups
• fewer signals
• higher selectivity
• users who prefer stricter confirmation

Important note:

A stricter mode does not guarantee better future outcomes.

It only applies stricter internal confirmation logic.

━━━━━━━━━━━━━━━━━━━━━━
📏 ATR-BASED DISTANCE FILTERING
━━━━━━━━━━━━━━━━━━━━━━

ATR is used in several areas of the script.

The script uses ATR to evaluate:

📌 breakout body strength
📌 confirmation candle body strength
📌 entry distance from Pullback EMA
📌 stop-loss projection distance
📌 TP/SL visual structure

The Max Entry Distance / ATR setting helps block entries that are too far away from the Pullback EMA.

This is important because a pullback system generally works best when the signal appears close enough to the pullback reference area.

If price runs too far away before confirmation, the setup may become less efficient from a risk/reward perspective.

━━━━━━━━━━━━━━━━━━━━━━
🧠 MCGINLEY DYNAMIC FILTER
━━━━━━━━━━━━━━━━━━━━━━

Pullback Sniper Method includes an optional McGinley Dynamic filter.

The purpose of this filter is to avoid signals that appear too close to the McGinley Dynamic line.

This distance is measured using ATR.

When enabled, the script checks whether price has enough distance from the McGinley line.

This can help reduce low-quality signals in crowded or compressed areas.

The McGinley filter is optional.

Users can turn it off if they prefer to use only the main trend/pullback logic.

━━━━━━━━━━━━━━━━━━━━━━
📊 RSI DIRECTION FILTER
━━━━━━━━━━━━━━━━━━━━━━

The script also includes an optional RSI direction filter.

When enabled:

🟢 Long signals require RSI to be above the selected long threshold.
🔴 Short signals require RSI to be below the selected short threshold.

By default, the RSI filter is turned off.

This keeps the base system cleaner and allows users to decide whether they want additional oscillator-style directional filtering.

The RSI filter should be treated as context, not as a guarantee.

━━━━━━━━━━━━━━━━━━━━━━
🧊 SIGNAL COOLDOWN SYSTEM
━━━━━━━━━━━━━━━━━━━━━━

The script includes a cooldown system to prevent signals from appearing too close to each other.

After a signal appears, the script waits for the selected number of bars before allowing another signal.

This helps reduce visual clutter and prevents the chart from printing too many labels in a short period.

The cooldown system is especially useful on lower timeframes or volatile assets.

━━━━━━━━━━━━━━━━━━━━━━
💪 STRONG SIGNAL LABELS
━━━━━━━━━━━━━━━━━━━━━━

When all required conditions align, the script can display a STRONG label on the chart.

A STRONG label appears only after the script detects:

📈 valid trend context
🚀 valid breakout setup
🎯 valid pullback touch
✅ valid confirmation
🧠 optional filter approval
🧊 cooldown approval
📦 no active trade conflict

The STRONG label does not mean the future outcome is guaranteed.

It simply means the script’s internal conditions aligned at that point.

━━━━━━━━━━━━━━━━━━━━━━
⭐ QUALITY SCORE TOOLTIP
━━━━━━━━━━━━━━━━━━━━━━

Pullback Sniper Method includes a Quality Score tooltip on the STRONG label.

This score does not filter signals.

It does not change entries.

It does not block or approve trades.

It is only informational.

To view it, hover your mouse over the STRONG label.

The tooltip can show:

⭐ Quality Score
🌟 Star rating
📌 Direction
📈 Trend alignment
🔥 Body / ATR ratio
📍 EMA Distance / ATR

Example tooltip:

Quality Score: 82/100 ⭐⭐⭐⭐ | Quality: HIGH | Direction: LONG | Trend: Bullish | Body/ATR: 0.48 | EMA Distance/ATR: 0.32

Star guide:

⭐⭐⭐⭐⭐ = very strong internal quality
⭐⭐⭐⭐ = high internal quality
⭐⭐⭐ = good internal quality
⭐⭐ = medium internal quality
⭐ = lower internal quality

Important note:

A score of 82 does not mean there is an 82% chance of winning.

The score only summarizes internal signal quality according to the script’s own visual model.

━━━━━━━━━━━━━━━━━━━━━━
📦 TP / SL PROJECTION SYSTEM
━━━━━━━━━━━━━━━━━━━━━━

Pullback Sniper Method includes an ATR-based TP/SL projection system.

When a STRONG signal appears, the script can draw:

📦 TP box
📦 SL box
🎯 TP1 line
🎯 TP2 line
🎯 TP3 line
🏷️ TP price labels
🏁 final result label

The system uses ATR-based risk.

Default structure:

🛡️ SL ATR Multiplier = 2.0
🎯 TP3 Reward R = 2.0R
🥉 TP1 = 25% of TP3 distance
🥈 TP2 = 50% of TP3 distance
🏆 TP3 = final target distance

This creates a clean visual projection of the potential trade structure.

The boxes are not broker orders.

They are visual projections based on the script’s internal logic.

━━━━━━━━━━━━━━━━━━━━━━
🎯 TP1 / TP2 / TP3 / SL TRACKING
━━━━━━━━━━━━━━━━━━━━━━

The script tracks projected trade progress visually.

Possible outcome states include:

🥉 TP1 reached
🥈 TP2 reached
🏆 TP3 reached
🛑 SL reached

If price reaches TP3, the result is marked as TP3.

If price hits SL before reaching any TP level, the result is marked as SL.

If price reaches TP1 and later returns to SL, the result can be treated as a TP1-style protected outcome.

If price reaches TP2 and later returns to SL, the result can be treated as a TP2-style protected outcome.

This allows the visual projection to remember the best target reached before the trade closes.

━━━━━━━━━━━━━━━━━━━━━━
⚠️ SAME-CANDLE TP/SL HANDLING
━━━━━━━━━━━━━━━━━━━━━━

If TP and SL are both touched on the same candle, there is ambiguity.

The script cannot know the true intrabar sequence from standard OHLC data.

For that reason, Pullback Sniper Method uses a conservative rule:

🔴 If TP and SL are both touched on the same candle, the script treats it as SL.

This avoids overly optimistic visual outcomes when the true intrabar order is unknown.

This conservative approach is useful when reviewing historical visual performance.

━━━━━━━━━━━━━━━━━━━━━━
🙈 EARLY SL HIDING LOGIC
━━━━━━━━━━━━━━━━━━━━━━

The script includes an early SL hiding feature.

If a projected trade hits SL within the first selected number of bars, the visual trade can be hidden and excluded from statistics.

Default:

🙈 Hide Early SL Bars = 3

This feature is designed to reduce extremely fast failed projections from cluttering the visual history.

Users should understand that this affects the visual/statistical display of the script.

It is not a broker-side execution rule.

━━━━━━━━━━━━━━━━━━━━━━
🗂️ HISTORICAL TRADE VISUALS
━━━━━━━━━━━━━━━━━━━━━━

Pullback Sniper Method can keep historical TP/SL visuals on the chart.

This includes:

📦 previous TP boxes
📦 previous SL boxes
🎯 TP1 / TP2 / TP3 lines
🛑 SL lines
🏷️ result labels
🏷️ TP price labels

The script also includes a maximum historical trade limit.

Default:

🧮 Max Historical Trades = 40

This helps prevent TradingView object-limit issues while still allowing users to review past signals visually.

━━━━━━━━━━━━━━━━━━━━━━
📊 STATISTICS TABLE
━━━━━━━━━━━━━━━━━━━━━━

The statistics table summarizes visual trade outcomes.

It can display:

🥉 TP1 count
🥈 TP2 count
🏆 TP3 count
🛑 SL count
📊 Total closed trades
✅ Win Rate

The statistics are calculated internally using the script’s visual TP/SL logic.

They are not broker execution results.

They do not include real slippage, spread, commission, liquidity, partial fills, or order execution issues.

They should be used for visual review and educational analysis only.

━━━━━━━━━━━━━━━━━━━━━━
💎 PREMIUM DASHBOARD
━━━━━━━━━━━━━━━━━━━━━━

Pullback Sniper Method includes a premium-style dashboard.

The dashboard can display:

📈 Trend
📡 Current status
📊 Total trades
✅ Win rate
📈 Total R
📉 Average R
🧮 Profit Factor
🎯 Expectancy
🔥 Max win streak
❄️ Max loss streak
🔁 Current streak
⏱️ Average bars in trade
🏆 TP3 rate
🛑 SL rate
🧭 Best direction
🟢 Long win rate
🔴 Short win rate
📌 Active trade state
🧾 Last signal
🎯 Best TP reached

The dashboard is designed to give users a structured overview of the script’s internal visual results.

Important note:

These dashboard values are not official TradingView Strategy Tester results.

They are internally calculated visual-analysis metrics.

They should not be interpreted as guaranteed performance.

━━━━━━━━━━━━━━━━━━━━━━
🎨 VISUAL THEME SYSTEM
━━━━━━━━━━━━━━━━━━━━━━

The script includes three visual themes:

🔵 Neon Pro
🧊 Ice Blue
🟡 Gold Black

The theme system affects:

🎨 STRONG label colors
📦 TP/SL box colors
🎯 TP/SL line colors
🏷️ TP price labels
📊 statistics table colors
💎 premium dashboard colors
🟢 long-side visuals
🟠 short-side visuals

Color settings are handled internally to keep the Inputs tab cleaner and more organized.

━━━━━━━━━━━━━━━━━━━━━━
🏷️ TP PRICE LABELS
━━━━━━━━━━━━━━━━━━━━━━

TP labels are displayed next to the TP levels rather than inside the boxes.

This helps keep the projection boxes cleaner.

The labels can show:

TP1 price
TP2 price
TP3 price

Example:

TP1 102450.5
TP2 103120.0
TP3 104300.0

This makes it easier to visually read the projected target levels without opening the settings or manually checking each line.

━━━━━━━━━━━━━━━━━━━━━━
🏁 RESULT LABELS
━━━━━━━━━━━━━━━━━━━━━━

When a projected trade closes, the script can display a result label.

Examples:

🏆 TP3 HIT WIN +2R
🥈 TP2 EXIT WIN +1R
🥉 TP1 EXIT WIN +0.5R
🛑 SL HIT LOSS -1R

The exact value depends on the selected TP/SL structure and the highest TP reached before closure.

These labels are visual summaries only.

They do not represent broker execution.

━━━━━━━━━━━━━━━━━━━━━━
🚨 ALERT SYSTEM
━━━━━━━━━━━━━━━━━━━━━━

Pullback Sniper Method includes alert conditions for:

🟢 Strong Long
🟠 Strong Short
🏆 TP3 Hit
🛑 SL Hit
🎯 Protected TP Exit

Users can create TradingView alerts from these alert conditions.

Alerts can help monitor the chart without constantly watching every candle.

Important note:

Alerts are based on the script’s conditions.

They are not trade execution instructions.

Users are responsible for validating alerts and applying their own risk management.

━━━━━━━━━━━━━━━━━━━━━━
🧪 HOW TO USE THE INDICATOR
━━━━━━━━━━━━━━━━━━━━━━

A practical workflow:

Add Pullback Sniper Method [trade_w_samet] to your chart.
Start with the default settings.
Review the overall trend direction.
Wait for a valid breakout setup.
Let the script wait for a pullback toward the Pullback EMA.
Watch for a STRONG label after confirmation.
Hover over the STRONG label to review the Quality Score tooltip.
Review the TP/SL projection box.
Check TP1, TP2, TP3, and SL levels.
Observe whether the projected trade reaches TP levels or SL.
Use the statistics table for visual outcome review.
Use the premium dashboard for deeper internal metrics.
Use alerts if you want automated signal notifications.
Validate the behavior on the exact symbols and timeframes you personally study.

This indicator is best used as a structured review tool.

It should not be used as a blind execution system.

━━━━━━━━━━━━━━━━━━━━━━
⚙️ SETTINGS REFERENCE
━━━━━━━━━━━━━━━━━━━━━━

📈 Trend Engine

⚡ Fast EMA Length
Controls the fast trend EMA. Lower values react faster, while higher values are smoother.

🐢 Slow EMA Length
Controls the broader trend EMA used for directional context.

🎯 Pullback EMA Length
Defines the EMA area where price is expected to pull back before confirmation.

📐 Trend Slope Lookback
Checks whether the fast EMA is sloping in the expected trend direction.

━━━━━━━━━━━━━━━━━━━━━━

🎯 Pullback Setup Engine

🚀 Breakout Lookback
Defines how many bars are used to detect a fresh breakout level.

🛑 Invalidation Lookback
Defines the invalidation level for the active pullback setup.

⏳ Min Bars After Breakout
Controls how many bars must pass after breakout before pullback detection begins.

⌛ Max Bars To Find Pullback
If no valid pullback appears within this range, the setup expires.

━━━━━━━━━━━━━━━━━━━━━━

✅ Confirmation Engine

✅ Confirmation Mode
Available modes:

⚡ Fast
⚖️ Balanced
🛡️ Strict

📏 ATR Length
ATR used for body-size and distance filters.

🔥 Min Breakout Body / ATR
Minimum breakout candle body size compared to ATR.

💪 Min Confirm Body / ATR
Minimum confirmation candle body size compared to ATR. Mainly used in Strict mode.

📍 Max Entry Distance / ATR
Blocks entries that are too far away from the Pullback EMA.

🧊 Use Signal Cooldown
Prevents too many signals from appearing too close to each other.

⏱️ Cooldown Bars
Number of bars to wait after a signal before allowing another one.

━━━━━━━━━━━━━━━━━━━━━━

🧠 Optional Filters

🧲 Block Signals Near McGinley
Avoids entries too close to the McGinley Dynamic line.

〽️ McGinley Length
Length used for the McGinley Dynamic filter.

📐 Min McGinley Distance / ATR
Minimum distance required between price and McGinley Dynamic.

📊 Use RSI Direction Filter
Filters long/short signals based on RSI direction.

📈 RSI Length
RSI length used for the optional direction filter.

🟢 RSI Long Minimum
Long signals are allowed only when RSI is above this value.

🔴 RSI Short Maximum
Short signals are allowed only when RSI is below this value.

━━━━━━━━━━━━━━━━━━━━━━

📦 Trade Visual Engine

📏 Show TP / SL Lines
Shows TP1, TP2, TP3, and SL lines.

📦 Show TP / SL Boxes
Shows TP and SL projection zones.

🏷️ Show Active TP Label
Shows the latest touched TP label while the projected trade is active.

🗂️ Show Historical TP / SL Trades
Keeps previous TP/SL boxes, lines, and labels on the chart.

🧮 Max Historical Trades
Limits historical visual trades to help avoid object-limit issues.

🛡️ SL ATR Length
ATR length used for stop-loss calculation.

🛑 SL ATR Multiplier
ATR multiplier used for stop-loss distance.

🎯 TP3 Reward R
Final TP target multiple based on the initial risk distance.

🥉 TP1 % Of TP3
TP1 distance as a percentage of final TP3 distance.

🥈 TP2 % Of TP3
TP2 distance as a percentage of final TP3 distance.

↔️ Initial TP / SL Length
Initial visual length of TP/SL lines and boxes.

🙈 Hide Early SL Bars
If SL is reached within this number of bars, the projection can be hidden and excluded from statistics.

📊 Show Statistics Table
Shows TP1, TP2, TP3, SL, total trades, and win rate.

💎 Show Premium Dashboard
Shows the extended dashboard with deeper internal metrics.

━━━━━━━━━━━━━━━━━━━━━━

🎨 Visual Settings

🎭 Color Theme
Available themes:

🔵 Neon Pro
🧊 Ice Blue
🟡 Gold Black

💪 Show STRONG Labels
Shows the main STRONG labels on the chart.

🔠 Signal Label Size
Controls the size of STRONG signal labels.

━━━━━━━━━━━━━━━━━━━━━━
🧠 WHAT MAKES THIS SCRIPT ORIGINAL
━━━━━━━━━━━━━━━━━━━━━━

Pullback Sniper Method uses familiar concepts such as:

📈 EMA trend context
🚀 breakout detection
🎯 pullback confirmation
🧠 optional technical filters
📦 ATR-based TP/SL projection
📊 dashboard metrics
🚨 alerts

These components are not unique by themselves.

The originality of the script lies in how these components are organized into one workflow:

Trend Engine
→ Breakout Detection
→ Pullback Validation
→ Confirmation Mode
→ Optional Filters
→ STRONG Label
→ Quality Tooltip
→ TP/SL Projection
→ Historical Trade Visualization
→ Statistics Table
→ Premium Dashboard
→ Alerts

This structure is intended to give users a cleaner way to review pullback-based trend continuation setups.

━━━━━━━━━━━━━━━━━━━━━━
⚠️ IMPORTANT PRACTICAL NOTES
━━━━━━━━━━━━━━━━━━━━━━

The script’s behavior depends heavily on settings.

Signal frequency and visual output may change based on:

🎛️ selected confirmation mode
📈 EMA lengths
🎯 pullback EMA length
🚀 breakout lookback
🛑 invalidation lookback
📏 ATR settings
🧠 McGinley filter
📊 RSI filter
🧊 cooldown setting
📦 TP/SL settings
📊 market
⏱️ timeframe
📉 symbol volatility
📚 available historical bars

A configuration that looks cleaner on one market may not behave the same way on another.

The TP/SL boxes are visual projections based on script rules.

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
❌ Same-candle TP/SL order cannot be known from standard OHLC data.
❌ Same-candle TP/SL is handled conservatively as SL.
❌ Quality Score is not a win-rate prediction.
❌ Dashboard statistics are internal visual metrics, not broker results.
❌ ATR-based TP/SL projections are visual analysis tools, not trade instructions.
❌ Strong labels can still fail in choppy or low-quality market conditions.
❌ Historical visual behavior does not ensure future behavior.

For these reasons, Pullback Sniper Method should be used as an educational decision-support tool, not as a standalone trading strategy.

━━━━━━━━━━━━━━━━━━━━━━
👤 WHO THIS SCRIPT MAY BE USEFUL FOR
━━━━━━━━━━━━━━━━━━━━━━

This script may be useful for traders who:

✅ study pullback-based trend continuation
✅ want structured breakout/pullback confirmation
✅ want ATR-based TP/SL visualization
✅ want historical visual trade review
✅ want a clean statistics table
✅ want a premium-style dashboard
✅ want signal quality information without changing signal logic
✅ want configurable confirmation strictness
✅ want visual themes
✅ want alert-based monitoring
✅ prefer organized chart-based analysis
✅ want an open-source educational TradingView tool

It may be less suitable for users who:

❌ want guaranteed buy/sell signals
❌ want a fully automated trading bot
❌ do not use technical analysis
❌ do not want chart visuals
❌ expect one setting to work on every market
❌ want an indicator that replaces their own decision-making
❌ expect internal visual statistics to match broker execution results

━━━━━━━━━━━━━━━━━━━━━━
🧭 BEST PRACTICE SUGGESTIONS
━━━━━━━━━━━━━━━━━━━━━━

For cleaner review:

✅ Start with the default settings.
✅ Use Balanced confirmation first.
✅ Test Fast and Strict modes only after understanding the default behavior.
✅ Review STRONG labels together with market structure.
✅ Hover over labels to inspect Quality Score context.
✅ Use TP/SL boxes as visual planning tools, not automatic orders.
✅ Review dashboard metrics as internal script feedback only.
✅ Avoid treating every signal as a trade.
✅ Test the indicator on the symbols and timeframes you actually use.
✅ Combine the tool with independent analysis and risk management.
✅ Keep expectations realistic.

━━━━━━━━━━━━━━━━━━━━━━
🚨 ALERT USAGE
━━━━━━━━━━━━━━━━━━━━━━

The script includes alert conditions for important events.

Available alert types include:

🟢 Strong Long
🟠 Strong Short
🏆 TP3 Hit
🛑 SL Hit
🎯 Protected TP Exit

A practical alert workflow:

Add the indicator to your chart.
Open TradingView’s alert window.
Select Pullback Sniper Method as the condition.
Choose the alert condition you want.
Configure frequency according to your preference.
Use alerts as monitoring tools only.
Confirm all alerts manually with your own analysis.

Alerts do not execute trades.

Alerts are not financial advice.

━━━━━━━━━━━━━━━━━━━━━━
🔓 OPEN-SOURCE NOTE
━━━━━━━━━━━━━━━━━━━━━━

This script is published open-source for educational review, transparency, and community learning.

Users can inspect how the indicator works, study the logic, modify it for personal learning, and understand the internal conditions behind the visual output.

Please respect TradingView’s House Rules when reusing or republishing open-source code.

The purpose of open-source publication is to support learning and transparent script review.

━━━━━━━━━━━━━━━━━━━━━━
🛡️ DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━

Pullback Sniper Method [trade_w_samet] is provided for educational and informational purposes only.

It does not constitute financial, investment, or trading advice.

No indicator can guarantee future results.

Markets are uncertain, conditions change, and historical behavior does not ensure future performance.

Every user is responsible for their own analysis, validation, risk management, position sizing, and trading decisions.

The TP/SL boxes, labels, dashboard statistics, Quality Score, and alerts are visual analysis tools only.

Use this script as a structured decision-support and visual review framework, not as a promise of profitability.

## Source Code

````pine
//@version=6
indicator("Pullback Sniper Method [trade_w_samet]", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 01. TREND ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

trendGroup = "01. 📈 Trend Engine"

fastEmaLength     = input.int(50, "⚡ Fast EMA Length", minval = 1, group = trendGroup, tooltip = "Controls the fast trend EMA. Lower values react faster, higher values are smoother.", display = display.none)
slowEmaLength     = input.int(200, "🐢 Slow EMA Length", minval = 1, group = trendGroup, tooltip = "Controls the main trend EMA. This is used as the broader trend direction filter.", display = display.none)
pullbackEmaLength = input.int(21, "🎯 Pullback EMA Length", minval = 1, group = trendGroup, tooltip = "Price must pull back toward this EMA before a confirmation signal can appear.", display = display.none)
slopeLookback     = input.int(5, "📐 Trend Slope Lookback", minval = 1, group = trendGroup, tooltip = "Checks whether the fast EMA is sloping in the trend direction.", display = display.none)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 02. BREAKOUT / PULLBACK ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

setupGroup = "02. 🎯 Pullback Setup Engine"

breakoutLookback       = input.int(20, "🚀 Breakout Lookback", minval = 5, maxval = 300, group = setupGroup, tooltip = "Defines how many bars are used to detect a fresh breakout level.", display = display.none)
invalidationLookback   = input.int(12, "🛑 Invalidation Lookback", minval = 3, maxval = 100, group = setupGroup, tooltip = "Defines the invalidation level for the active pullback setup.", display = display.none)
minBarsAfterBreakout   = input.int(2, "⏳ Min Bars After Breakout", minval = 1, maxval = 50, group = setupGroup, tooltip = "Minimum waiting bars after breakout before pullback detection starts.", display = display.none)
maxBarsToFindPullback  = input.int(60, "⌛ Max Bars To Find Pullback", minval = 5, maxval = 500, group = setupGroup, tooltip = "If no valid pullback appears within this range, the setup expires.", display = display.none)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 03. CONFIRMATION ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

confirmGroup = "03. ✅ Confirmation Engine"

confirmationMode      = input.string("Balanced", "✅ Confirmation Mode", options = ["Fast", "Balanced", "Strict"], group = confirmGroup, tooltip = "Fast gives earlier entries, Strict gives fewer but stronger confirmations, Balanced stays between them.", display = display.none)
atrLength             = input.int(14, "📏 ATR Length", minval = 1, group = confirmGroup, tooltip = "ATR used for body-size and distance filters in the confirmation engine.", display = display.none)
minBreakoutBodyAtr    = input.float(0.20, "🔥 Min Breakout Body / ATR", minval = 0.01, maxval = 5.0, step = 0.05, group = confirmGroup, tooltip = "Minimum breakout candle body size compared to ATR. Higher values filter weak breakouts.", display = display.none)
minConfirmBodyAtr     = input.float(0.25, "💪 Min Confirm Body / ATR", minval = 0.01, maxval = 5.0, step = 0.05, group = confirmGroup, tooltip = "Minimum confirmation candle body size compared to ATR. Mainly used in Strict mode.", display = display.none)
maxEntryDistanceAtr   = input.float(1.00, "📍 Max Entry Distance / ATR", minval = 0.10, maxval = 5.0, step = 0.10, group = confirmGroup, tooltip = "Blocks entries that are too far away from the pullback EMA.", display = display.none)
useCooldown           = input.bool(true, "🧊 Use Signal Cooldown", group = confirmGroup, tooltip = "Prevents too many signals from appearing too close to each other.", display = display.none)
cooldownBars          = input.int(20, "⏱️ Cooldown Bars", minval = 1, maxval = 500, group = confirmGroup, tooltip = "Number of bars to wait after a signal before allowing another one.", display = display.none)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 04. OPTIONAL FILTERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

filterGroup = "04. 🧠 Optional Filters"

useMcginleyFilter     = input.bool(true, "🧲 Block Signals Near McGinley", group = filterGroup, tooltip = "Avoids entries too close to the McGinley Dynamic line, reducing low-quality signals.", display = display.none)
mcginleyLength        = input.int(100, "〽️ McGinley Length", minval = 1, group = filterGroup, tooltip = "Length used for the McGinley Dynamic filter.", display = display.none)
mcginleyDistanceAtr   = input.float(0.25, "📐 Min McGinley Distance / ATR", minval = 0.01, maxval = 5.0, step = 0.05, group = filterGroup, tooltip = "Minimum distance required between price and McGinley Dynamic line.", display = display.none)

useRsiFilter          = input.bool(false, "📊 Use RSI Direction Filter", group = filterGroup, tooltip = "Filters long/short signals based on RSI direction bias.", display = display.none)
rsiLength             = input.int(14, "📈 RSI Length", minval = 1, group = filterGroup, tooltip = "RSI length used for the optional direction filter.", display = display.none)
rsiLongMin            = input.float(50.0, "🟢 RSI Long Minimum", minval = 1, maxval = 99, step = 1, group = filterGroup, tooltip = "Long signals are allowed only when RSI is above this value.", display = display.none)
rsiShortMax           = input.float(50.0, "🔴 RSI Short Maximum", minval = 1, maxval = 99, step = 1, group = filterGroup, tooltip = "Short signals are allowed only when RSI is below this value.", display = display.none)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 05. TRADE VISUAL ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

tradeGroup = "05. 📦 Trade Visual Engine"

showTradeLines        = input.bool(true, "📏 Show TP / SL Lines", group = tradeGroup, tooltip = "Shows TP1, TP2, TP3 and SL lines for active and historical trades.", display = display.none)
showTradeBoxes        = input.bool(true, "📦 Show TP / SL Boxes", group = tradeGroup, tooltip = "Shows TP and SL zones as clean modern background boxes.", display = display.none)
showActiveTpLabel     = input.bool(true, "🏷️ Show Active TP Label", group = tradeGroup, tooltip = "Shows the latest touched TP label while the trade is active.", display = display.none)
showHistoricalTrades  = input.bool(true, "🗂️ Show Historical TP / SL Trades", group = tradeGroup, tooltip = "Keeps previous TP/SL boxes, lines and result labels on the chart.", display = display.none)
maxHistoricalTrades   = input.int(40, "🧮 Max Historical Trades", minval = 1, maxval = 100, group = tradeGroup, tooltip = "Limits the number of historical visual trades to prevent TradingView object-limit issues.", display = display.none)
tradeAtrLength        = input.int(14, "🛡️ SL ATR Length", minval = 1, group = tradeGroup, tooltip = "ATR length used to calculate the stop-loss distance.", display = display.none)
tradeAtrMultiplier    = input.float(2.0, "🛑 SL ATR Multiplier", minval = 0.1, step = 0.1, group = tradeGroup, tooltip = "Multiplier applied to ATR for stop-loss placement.", display = display.none)
tp3RewardR            = input.float(2.0, "🎯 TP3 Reward R", minval = 0.1, step = 0.1, group = tradeGroup, tooltip = "Final TP reward multiple based on the initial risk distance.", display = display.none)
tp1PercentOfTp3       = input.float(25.0, "🥉 TP1 % Of TP3", minval = 1.0, maxval = 100.0, step = 1.0, group = tradeGroup, tooltip = "TP1 distance as a percentage of the TP3 target distance.", display = display.none)
tp2PercentOfTp3       = input.float(50.0, "🥈 TP2 % Of TP3", minval = 1.0, maxval = 100.0, step = 1.0, group = tradeGroup, tooltip = "TP2 distance as a percentage of the TP3 target distance.", display = display.none)
initialLineBars       = input.int(20, "↔️ Initial TP / SL Length", minval = 1, maxval = 500, group = tradeGroup, tooltip = "Initial visual length of TP/SL lines and boxes when a trade opens.", display = display.none)
hideEarlySlBars       = input.int(3, "🙈 Hide Early SL Bars", minval = 0, maxval = 50, group = tradeGroup, tooltip = "If a trade hits SL within this number of bars, its visuals are hidden and it is excluded from stats.", display = display.none)

showStatsTable        = input.bool(true, "📊 Show Statistics Table", group = tradeGroup, tooltip = "Shows TP1, TP2, TP3, SL and total trade distribution statistics.", display = display.none)
statsTablePositionIn  = input.string("Top Right", "🧭 Statistics Table Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = tradeGroup, tooltip = "Choose where the statistics table appears on the chart.", display = display.none)

statsTablePosition =
     statsTablePositionIn == "Top Left" ? position.top_left :
     statsTablePositionIn == "Bottom Right" ? position.bottom_right :
     statsTablePositionIn == "Bottom Left" ? position.bottom_left :
     position.top_right

showPremiumDashboard  = input.bool(true, "💎 Show Premium Dashboard", group = tradeGroup, tooltip = "Shows the premium status panel with trend, status, active trade and latest signal context.", display = display.none)
premiumDashPositionIn = input.string("Bottom Right", "🧭 Premium Dashboard Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = tradeGroup, tooltip = "Choose where the premium dashboard appears on the chart.", display = display.none)

premiumDashPosition =
     premiumDashPositionIn == "Top Left" ? position.top_left :
     premiumDashPositionIn == "Top Right" ? position.top_right :
     premiumDashPositionIn == "Bottom Left" ? position.bottom_left :
     position.bottom_right


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 06. VISUAL SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

visualGroup = "06. 🎨 Visual Settings"

visualTheme = input.string("Neon Pro", "🎭 Color Theme", options = ["Neon Pro", "Ice Blue", "Gold Black", "Aqua Violet", "Frost Glass", "Polar Night"], group = visualGroup, tooltip = "Original themes are preserved. Aqua Violet, Frost Glass and Polar Night are new Ice-Blue-style themes with different TP/SL box colors and more modern dashboard surfaces.", display = display.none)
showStrongLabels = input.bool(true, "💪 Show STRONG Labels", group = visualGroup, tooltip = "Shows the main STRONG signal label when a valid setup confirms.", display = display.none)
labelSizeInput   = input.string("Normal", "🔠 Signal Label Size", options = ["Small", "Normal", "Large"], group = visualGroup, tooltip = "Controls the size of STRONG signal labels.", display = display.none)

labelSize =
     labelSizeInput == "Small" ? size.small :
     labelSizeInput == "Large" ? size.large :
     size.normal

longLabelColor =
     visualTheme == "Ice Blue" ? color.rgb(0, 190, 255) :
     visualTheme == "Gold Black" ? color.rgb(255, 190, 40) :
     visualTheme == "Aqua Violet" ? color.rgb(0, 230, 255) :
     visualTheme == "Frost Glass" ? color.rgb(0, 145, 210) :
     visualTheme == "Polar Night" ? color.rgb(70, 220, 255) :
     color.rgb(0, 120, 255)

shortLabelColor =
     visualTheme == "Ice Blue" ? color.rgb(255, 145, 60) :
     visualTheme == "Gold Black" ? color.rgb(255, 165, 45) :
     visualTheme == "Aqua Violet" ? color.rgb(178, 110, 255) :
     visualTheme == "Frost Glass" ? color.rgb(196, 76, 150) :
     visualTheme == "Polar Night" ? color.rgb(255, 118, 210) :
     color.rgb(255, 135, 45)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 07. COLORS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

tpLineColor =
     visualTheme == "Ice Blue" ? color.rgb(0, 200, 255) :
     visualTheme == "Gold Black" ? color.rgb(255, 205, 55) :
     visualTheme == "Aqua Violet" ? color.rgb(0, 225, 255) :
     visualTheme == "Frost Glass" ? color.rgb(0, 165, 220) :
     visualTheme == "Polar Night" ? color.rgb(86, 235, 255) :
     color.rgb(0, 210, 130)

slLineColor =
     visualTheme == "Ice Blue" ? color.rgb(125, 80, 255) :
     visualTheme == "Gold Black" ? color.rgb(255, 75, 45) :
     visualTheme == "Aqua Violet" ? color.rgb(170, 105, 255) :
     visualTheme == "Frost Glass" ? color.rgb(210, 86, 165) :
     visualTheme == "Polar Night" ? color.rgb(255, 92, 195) :
     color.rgb(255, 80, 80)

tpBoxColor =
     visualTheme == "Ice Blue" ? color.rgb(0, 230, 255) :
     visualTheme == "Gold Black" ? color.rgb(255, 215, 55) :
     visualTheme == "Aqua Violet" ? color.rgb(0, 235, 255) :
     visualTheme == "Frost Glass" ? color.rgb(0, 175, 210) :
     visualTheme == "Polar Night" ? color.rgb(80, 240, 255) :
     color.rgb(0, 235, 165)

slBoxColor =
     visualTheme == "Ice Blue" ? color.rgb(255, 70, 120) :
     visualTheme == "Gold Black" ? color.rgb(255, 80, 45) :
     visualTheme == "Aqua Violet" ? color.rgb(255, 88, 190) :
     visualTheme == "Frost Glass" ? color.rgb(235, 70, 115) :
     visualTheme == "Polar Night" ? color.rgb(255, 62, 165) :
     color.rgb(255, 70, 115)

// High-contrast TP / SL zone backgrounds
// Theme names and general theme identity are preserved. Only TP/SL boxes are separated more clearly.
tpBoxBgColor =
     visualTheme == "Ice Blue" ? color.rgb(0, 80, 118) :
     visualTheme == "Gold Black" ? color.rgb(98, 76, 0) :
     visualTheme == "Aqua Violet" ? color.rgb(0, 70, 105) :
     visualTheme == "Frost Glass" ? color.rgb(188, 248, 232) :
     visualTheme == "Polar Night" ? color.rgb(0, 72, 104) :
     color.rgb(0, 92, 58)

slBoxBgColor =
     visualTheme == "Ice Blue" ? color.rgb(145, 24, 72) :
     visualTheme == "Gold Black" ? color.rgb(150, 42, 18) :
     visualTheme == "Aqua Violet" ? color.rgb(116, 28, 116) :
     visualTheme == "Frost Glass" ? color.rgb(255, 202, 212) :
     visualTheme == "Polar Night" ? color.rgb(120, 18, 82) :
     color.rgb(145, 16, 30)

tpBoxBorderColor =
     visualTheme == "Ice Blue" ? color.rgb(0, 225, 255) :
     visualTheme == "Gold Black" ? color.rgb(255, 220, 70) :
     visualTheme == "Aqua Violet" ? color.rgb(0, 235, 255) :
     visualTheme == "Frost Glass" ? color.rgb(0, 170, 150) :
     visualTheme == "Polar Night" ? color.rgb(70, 235, 255) :
     color.rgb(0, 220, 145)

slBoxBorderColor =
     visualTheme == "Ice Blue" ? color.rgb(255, 85, 130) :
     visualTheme == "Gold Black" ? color.rgb(255, 92, 45) :
     visualTheme == "Aqua Violet" ? color.rgb(255, 95, 205) :
     visualTheme == "Frost Glass" ? color.rgb(230, 58, 105) :
     visualTheme == "Polar Night" ? color.rgb(255, 70, 175) :
     color.rgb(255, 70, 95)

tpLabelColor =
     visualTheme == "Ice Blue" ? color.rgb(0, 200, 255) :
     visualTheme == "Gold Black" ? color.rgb(255, 200, 40) :
     visualTheme == "Aqua Violet" ? color.rgb(0, 215, 255) :
     visualTheme == "Frost Glass" ? color.rgb(0, 140, 200) :
     visualTheme == "Polar Night" ? color.rgb(88, 230, 255) :
     color.rgb(0, 170, 110)

whiteText =
     visualTheme == "Ice Blue" ? color.rgb(235, 250, 255) :
     visualTheme == "Gold Black" ? color.rgb(255, 245, 210) :
     visualTheme == "Aqua Violet" ? color.rgb(235, 248, 255) :
     visualTheme == "Frost Glass" ? color.rgb(25, 40, 56) :
     visualTheme == "Polar Night" ? color.rgb(238, 250, 255) :
     color.white

statsBgColor =
     visualTheme == "Ice Blue" ? color.rgb(4, 18, 36) :
     visualTheme == "Gold Black" ? color.rgb(14, 10, 4) :
     visualTheme == "Aqua Violet" ? color.rgb(5, 13, 28) :
     visualTheme == "Frost Glass" ? color.rgb(244, 250, 255) :
     visualTheme == "Polar Night" ? color.rgb(3, 10, 24) :
     color.rgb(10, 10, 10)

statsHeaderColor =
     visualTheme == "Ice Blue" ? color.rgb(8, 42, 78) :
     visualTheme == "Gold Black" ? color.rgb(55, 38, 8) :
     visualTheme == "Aqua Violet" ? color.rgb(10, 34, 64) :
     visualTheme == "Frost Glass" ? color.rgb(218, 236, 248) :
     visualTheme == "Polar Night" ? color.rgb(8, 28, 58) :
     color.rgb(25, 25, 25)

statsBorderColor =
     visualTheme == "Ice Blue" ? color.rgb(0, 160, 255) :
     visualTheme == "Gold Black" ? color.rgb(255, 190, 45) :
     visualTheme == "Aqua Violet" ? color.rgb(0, 180, 255) :
     visualTheme == "Frost Glass" ? color.rgb(115, 165, 205) :
     visualTheme == "Polar Night" ? color.rgb(70, 190, 255) :
     color.rgb(70, 70, 70)

statsWinColor =
     visualTheme == "Ice Blue" ? color.rgb(0, 220, 255) :
     visualTheme == "Gold Black" ? color.rgb(255, 210, 70) :
     visualTheme == "Aqua Violet" ? color.rgb(0, 225, 255) :
     visualTheme == "Frost Glass" ? color.rgb(0, 140, 205) :
     visualTheme == "Polar Night" ? color.rgb(95, 230, 255) :
     color.rgb(0, 170, 110)

statsLossColor =
     visualTheme == "Ice Blue" ? color.rgb(160, 110, 255) :
     visualTheme == "Gold Black" ? color.rgb(255, 90, 55) :
     visualTheme == "Aqua Violet" ? color.rgb(180, 115, 255) :
     visualTheme == "Frost Glass" ? color.rgb(198, 70, 150) :
     visualTheme == "Polar Night" ? color.rgb(255, 98, 205) :
     color.rgb(220, 50, 50)

statsNeutralColor =
     visualTheme == "Ice Blue" ? color.rgb(165, 215, 245) :
     visualTheme == "Gold Black" ? color.rgb(220, 190, 120) :
     visualTheme == "Aqua Violet" ? color.rgb(155, 205, 235) :
     visualTheme == "Frost Glass" ? color.rgb(88, 106, 125) :
     visualTheme == "Polar Night" ? color.rgb(145, 198, 228) :
     color.rgb(180, 180, 180)

tpPriceLabelBg =
     visualTheme == "Ice Blue" ? color.rgb(220, 245, 255) :
     visualTheme == "Gold Black" ? color.rgb(255, 215, 80) :
     visualTheme == "Aqua Violet" ? color.rgb(220, 248, 255) :
     visualTheme == "Frost Glass" ? color.rgb(15, 42, 60) :
     visualTheme == "Polar Night" ? color.rgb(218, 248, 255) :
     color.white

tpPriceLabelText =
     visualTheme == "Ice Blue" ? color.rgb(0, 30, 60) :
     visualTheme == "Gold Black" ? color.rgb(20, 12, 0) :
     visualTheme == "Aqua Violet" ? color.rgb(4, 20, 38) :
     visualTheme == "Frost Glass" ? color.rgb(236, 248, 255) :
     visualTheme == "Polar Night" ? color.rgb(5, 18, 34) :
     color.black

f_boldItalicText(txt) =>
    out = txt
    out := str.replace_all(out, "A", "𝑨")
    out := str.replace_all(out, "B", "𝑩")
    out := str.replace_all(out, "C", "𝑪")
    out := str.replace_all(out, "D", "𝑫")
    out := str.replace_all(out, "E", "𝑬")
    out := str.replace_all(out, "F", "𝑭")
    out := str.replace_all(out, "G", "𝑮")
    out := str.replace_all(out, "H", "𝑯")
    out := str.replace_all(out, "I", "𝑰")
    out := str.replace_all(out, "J", "𝑱")
    out := str.replace_all(out, "K", "𝑲")
    out := str.replace_all(out, "L", "𝑳")
    out := str.replace_all(out, "M", "𝑴")
    out := str.replace_all(out, "N", "𝑵")
    out := str.replace_all(out, "O", "𝑶")
    out := str.replace_all(out, "P", "𝑷")
    out := str.replace_all(out, "Q", "𝑸")
    out := str.replace_all(out, "R", "𝑹")
    out := str.replace_all(out, "S", "𝑺")
    out := str.replace_all(out, "T", "𝑻")
    out := str.replace_all(out, "U", "𝑼")
    out := str.replace_all(out, "V", "𝑽")
    out := str.replace_all(out, "W", "𝑾")
    out := str.replace_all(out, "X", "𝑿")
    out := str.replace_all(out, "Y", "𝒀")
    out := str.replace_all(out, "Z", "𝒁")
    out := str.replace_all(out, "a", "𝒂")
    out := str.replace_all(out, "b", "𝒃")
    out := str.replace_all(out, "c", "𝒄")
    out := str.replace_all(out, "d", "𝒅")
    out := str.replace_all(out, "e", "𝒆")
    out := str.replace_all(out, "f", "𝒇")
    out := str.replace_all(out, "g", "𝒈")
    out := str.replace_all(out, "h", "𝒉")
    out := str.replace_all(out, "i", "𝒊")
    out := str.replace_all(out, "j", "𝒋")
    out := str.replace_all(out, "k", "𝒌")
    out := str.replace_all(out, "l", "𝒍")
    out := str.replace_all(out, "m", "𝒎")
    out := str.replace_all(out, "n", "𝒏")
    out := str.replace_all(out, "o", "𝒐")
    out := str.replace_all(out, "p", "𝒑")
    out := str.replace_all(out, "q", "𝒒")
    out := str.replace_all(out, "r", "𝒓")
    out := str.replace_all(out, "s", "𝒔")
    out := str.replace_all(out, "t", "𝒕")
    out := str.replace_all(out, "u", "𝒖")
    out := str.replace_all(out, "v", "𝒗")
    out := str.replace_all(out, "w", "𝒘")
    out := str.replace_all(out, "x", "𝒙")
    out := str.replace_all(out, "y", "𝒚")
    out := str.replace_all(out, "z", "𝒛")
    out := str.replace_all(out, "0", "𝟎")
    out := str.replace_all(out, "1", "𝟏")
    out := str.replace_all(out, "2", "𝟐")
    out := str.replace_all(out, "3", "𝟑")
    out := str.replace_all(out, "4", "𝟒")
    out := str.replace_all(out, "5", "𝟓")
    out := str.replace_all(out, "6", "𝟔")
    out := str.replace_all(out, "7", "𝟕")
    out := str.replace_all(out, "8", "𝟖")
    out := str.replace_all(out, "9", "𝟗")
    out

f_tpPriceText(tpName, tpPrice) =>
    f_boldItalicText(tpName + "  " + str.tostring(tpPrice, format.mintick))

f_signedRText(value) =>
    value >= 0 ? "+" + str.tostring(value, "#.##") + "R" : str.tostring(value, "#.##") + "R"


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 09. CORE CALCULATIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

fastEma = ta.ema(close, fastEmaLength)
slowEma = ta.ema(close, slowEmaLength)
pullbackEma = ta.ema(close, pullbackEmaLength)

atrValue = ta.atr(atrLength)
tradeAtr = ta.atr(tradeAtrLength)
rsiValue = ta.rsi(close, rsiLength)

bodySize = math.abs(close - open)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

bullTrend =
     fastEma > slowEma and
     close > slowEma and
     fastEma > fastEma[slopeLookback]

bearTrend =
     fastEma < slowEma and
     close < slowEma and
     fastEma < fastEma[slopeLookback]

highestBefore = ta.highest(high[1], breakoutLookback)
lowestBefore  = ta.lowest(low[1], breakoutLookback)

breakoutBodyOk = bodySize >= atrValue * minBreakoutBodyAtr

bullBreakout =
     bullTrend and
     close > highestBefore and
     close > open and
     breakoutBodyOk

bearBreakout =
     bearTrend and
     close < lowestBefore and
     close < open and
     breakoutBodyOk


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 10. MCGINLEY DYNAMIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var float mcginleyLine = na

mcginleySeed = ta.ema(close, mcginleyLength)
mcginleyBase = nz(mcginleyLine[1], mcginleySeed)
mcginleyRatio = mcginleyBase != 0.0 ? close / mcginleyBase : 1.0
mcginleyDivider = mcginleyLength * math.pow(mcginleyRatio, 4)

mcginleyLine := na(mcginleyLine[1]) ? mcginleySeed : mcginleyLine[1] + (close - mcginleyLine[1]) / mcginleyDivider

mcginleyDistance = math.abs(close - mcginleyLine)

mcginleyAllowed =
     not useMcginleyFilter or
     mcginleyDistance >= atrValue * mcginleyDistanceAtr

rsiLongAllowed =
     not useRsiFilter or
     rsiValue >= rsiLongMin

rsiShortAllowed =
     not useRsiFilter or
     rsiValue <= rsiShortMax


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 10B. QUALITY SCORE HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_qualityStars(score) =>
    stars = "⭐"
    if score >= 90
        stars := "⭐⭐⭐⭐⭐"
    else if score >= 75
        stars := "⭐⭐⭐⭐"
    else if score >= 60
        stars := "⭐⭐⭐"
    else if score >= 45
        stars := "⭐⭐"
    stars

f_qualityScore(isLong) =>
    trendScore = 0
    if isLong and bullTrend
        trendScore := 25
    else if not isLong and bearTrend
        trendScore := 25

    bodyAtrRatio = atrValue > 0 ? bodySize / atrValue : 0.0
    bodyScore = 4
    if bodyAtrRatio >= 0.75
        bodyScore := 20
    else if bodyAtrRatio >= 0.50
        bodyScore := 16
    else if bodyAtrRatio >= 0.35
        bodyScore := 12
    else if bodyAtrRatio >= 0.20
        bodyScore := 8

    distanceAtrRatio = atrValue > 0 ? math.abs(close - pullbackEma) / atrValue : 10.0
    distanceScore = 4
    if distanceAtrRatio <= 0.25
        distanceScore := 20
    else if distanceAtrRatio <= 0.50
        distanceScore := 16
    else if distanceAtrRatio <= 0.75
        distanceScore := 12
    else if distanceAtrRatio <= 1.00
        distanceScore := 8

    wickScore = 3
    if isLong
        if lowerWick >= bodySize * 0.50
            wickScore := 10
        else if lowerWick >= bodySize * 0.25
            wickScore := 6
    else
        if upperWick >= bodySize * 0.50
            wickScore := 10
        else if upperWick >= bodySize * 0.25
            wickScore := 6

    mcginleyScore = 10
    if useMcginleyFilter
        mcginleyScore := 3
        if mcginleyDistance >= atrValue * mcginleyDistanceAtr * 1.50
            mcginleyScore := 10
        else if mcginleyDistance >= atrValue * mcginleyDistanceAtr
            mcginleyScore := 7

    rsiScore = 10
    if useRsiFilter
        rsiScore := 3
        if isLong and rsiValue >= rsiLongMin + 5
            rsiScore := 10
        else if isLong and rsiValue >= rsiLongMin
            rsiScore := 7
        else if not isLong and rsiValue <= rsiShortMax - 5
            rsiScore := 10
        else if not isLong and rsiValue <= rsiShortMax
            rsiScore := 7

    totalScore = trendScore + bodyScore + distanceScore + wickScore + mcginleyScore + rsiScore + 5
    math.min(100, totalScore)

f_qualityTooltip(isLong, score) =>
    directionText = isLong ? "LONG" : "SHORT"
    starsText = f_qualityStars(score)

    qualityText = "LOW"
    if score >= 90
        qualityText := "ELITE"
    else if score >= 75
        qualityText := "HIGH"
    else if score >= 60
        qualityText := "GOOD"
    else if score >= 45
        qualityText := "MEDIUM"

    trendText = "Weak"
    if isLong and bullTrend
        trendText := "Bullish"
    else if not isLong and bearTrend
        trendText := "Bearish"

    bodyAtrText = str.tostring(atrValue > 0 ? bodySize / atrValue : 0.0, "#.##")
    emaDistText = str.tostring(atrValue > 0 ? math.abs(close - pullbackEma) / atrValue : 0.0, "#.##")

    tooltipText = "Quality Score: " + str.tostring(score) + "/100 " + starsText
    tooltipText := tooltipText + " | Quality: " + qualityText
    tooltipText := tooltipText + " | Direction: " + directionText
    tooltipText := tooltipText + " | Trend: " + trendText
    tooltipText := tooltipText + " | Body/ATR: " + bodyAtrText
    tooltipText := tooltipText + " | EMA Distance/ATR: " + emaDistText
    tooltipText


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 11. SETUP STATE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var bool  setupActive       = false
var int   setupDirection    = 0
var int   setupStartBar     = na
var float setupInvalidation = na
var bool  setupPullbackHit  = false
var bool  setupCompleted    = false

var int lastSignalBar = na
var int lastSignalSide = 0

barsSinceSetup =
     setupActive and not na(setupStartBar) ? bar_index - setupStartBar : na

cooldownAllowed =
     not useCooldown or
     na(lastSignalBar) or
     bar_index - lastSignalBar >= cooldownBars


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 12. TRADE STATE / HISTORICAL OBJECTS / STATS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var bool  tradeActive       = false
var int   tradeSide         = 0
var int   tradeEntryBar     = na
var float tradeEntry        = na
var float tradeStop         = na
var float tradeTp1          = na
var float tradeTp2          = na
var float tradeTp3          = na
var int   tradeBestTpStage  = 0
var int   tp3DirectionLock  = 0

var line  activeTp1Line     = na
var line  activeTp2Line     = na
var line  activeTp3Line     = na
var line  activeSlLine      = na

var box   activeTpBox       = na
var box   activeSlBox       = na

var label activeTpLabel        = na
var label activeSignalLabel    = na
var label activeExitLabel      = na
var label activeTp1PriceLabel  = na
var label activeTp2PriceLabel  = na
var label activeTp3PriceLabel  = na

var int historicalTradeCount = 0

var line[]  historicalTp1Lines       = array.new_line()
var line[]  historicalTp2Lines       = array.new_line()
var line[]  historicalTp3Lines       = array.new_line()
var line[]  historicalSlLines        = array.new_line()
var box[]   historicalTpBoxes        = array.new_box()
var box[]   historicalSlBoxes        = array.new_box()
var label[] historicalTpLabels       = array.new_label()
var label[] historicalSignalLabels   = array.new_label()
var label[] historicalExitLabels     = array.new_label()
var label[] historicalTp1PriceLabels = array.new_label()
var label[] historicalTp2PriceLabels = array.new_label()
var label[] historicalTp3PriceLabels = array.new_label()

var int statTotalClosed      = 0
var int statTp1              = 0
var int statTp2              = 0
var int statTp3              = 0
var int statSl               = 0
var int statWinTrades        = 0
var float statTotalR         = 0.0
var float statGrossWinR      = 0.0
var float statGrossLossR     = 0.0
var int statTotalBars        = 0
var int statMaxWinStreak     = 0
var int statMaxLossStreak    = 0
var int statCurrentWinStreak = 0
var int statCurrentLossStreak = 0
var int statCurrentStreak    = 0
var int statLongTotal        = 0
var int statLongWins         = 0
var int statShortTotal       = 0
var int statShortWins        = 0

var table statsTable = table.new(
     statsTablePosition,
     3,
     6,
     bgcolor = color.new(statsBgColor, 5),
     frame_color = color.new(statsBorderColor, 0),
     frame_width = 1,
     border_color = color.new(statsBorderColor, 20),
     border_width = 1)

var table premiumDashTable = table.new(
     premiumDashPosition,
     2,
     7,
     bgcolor = color.new(statsBgColor, 5),
     frame_color = color.new(statsBorderColor, 0),
     frame_width = 1,
     border_color = color.new(statsBorderColor, 20),
     border_width = 1)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 13. SETUP CREATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

canCreateSetup =
     not tradeActive and
     (not setupActive or setupCompleted)

if bullBreakout and canCreateSetup
    setupActive       := true
    setupDirection    := 1
    setupStartBar     := bar_index
    setupInvalidation := ta.lowest(low[1], invalidationLookback)
    setupPullbackHit  := false
    setupCompleted    := false

if bearBreakout and canCreateSetup
    setupActive       := true
    setupDirection    := -1
    setupStartBar     := bar_index
    setupInvalidation := ta.highest(high[1], invalidationLookback)
    setupPullbackHit  := false
    setupCompleted    := false


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 14. SETUP MANAGEMENT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

setupExpired =
     setupActive and
     not setupCompleted and
     not na(barsSinceSetup) and
     barsSinceSetup > maxBarsToFindPullback

setupInvalidated =
     setupActive and
     not setupCompleted and
     not na(setupInvalidation) and
     (
         setupDirection == 1 and close < setupInvalidation or
         setupDirection == -1 and close > setupInvalidation
     )

if setupExpired or setupInvalidated
    setupCompleted := true
    setupActive := false
    setupDirection := 0
    setupStartBar := na
    setupInvalidation := na
    setupPullbackHit := false

longPullbackTouch =
     setupActive and
     setupDirection == 1 and
     not setupPullbackHit and
     not na(barsSinceSetup) and
     barsSinceSetup >= minBarsAfterBreakout and
     low <= pullbackEma and
     close > setupInvalidation

shortPullbackTouch =
     setupActive and
     setupDirection == -1 and
     not setupPullbackHit and
     not na(barsSinceSetup) and
     barsSinceSetup >= minBarsAfterBreakout and
     high >= pullbackEma and
     close < setupInvalidation

if longPullbackTouch or shortPullbackTouch
    setupPullbackHit := true


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 15. CONFIRMATION LOGIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

entryDistanceOk =
     math.abs(close - pullbackEma) <= atrValue * maxEntryDistanceAtr

confirmBodyOk =
     bodySize >= atrValue * minConfirmBodyAtr

longFastConfirm =
     close > pullbackEma and
     close > open

shortFastConfirm =
     close < pullbackEma and
     close < open

longBalancedConfirm =
     close > pullbackEma and
     close > open and
     (
         close > high[1] or
         lowerWick >= bodySize * 0.50
     )

shortBalancedConfirm =
     close < pullbackEma and
     close < open and
     (
         close < low[1] or
         upperWick >= bodySize * 0.50
     )

longStrictConfirm =
     close > pullbackEma and
     close > high[1] and
     close > open and
     confirmBodyOk

shortStrictConfirm =
     close < pullbackEma and
     close < low[1] and
     close < open and
     confirmBodyOk

longConfirm =
     confirmationMode == "Fast" ? longFastConfirm :
     confirmationMode == "Balanced" ? longBalancedConfirm :
     longStrictConfirm

shortConfirm =
     confirmationMode == "Fast" ? shortFastConfirm :
     confirmationMode == "Balanced" ? shortBalancedConfirm :
     shortStrictConfirm


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 16. ACTIVE TRADE VISUAL EXTENSION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

activeVisualRight =
     tradeActive and not na(tradeEntryBar) ? math.max(bar_index, tradeEntryBar + initialLineBars) : na

if tradeActive
    if showTradeLines
        if not na(activeTp1Line)
            line.set_x2(activeTp1Line, activeVisualRight)
        if not na(activeTp2Line)
            line.set_x2(activeTp2Line, activeVisualRight)
        if not na(activeTp3Line)
            line.set_x2(activeTp3Line, activeVisualRight)
        if not na(activeSlLine)
            line.set_x2(activeSlLine, activeVisualRight)

        if not na(activeTp1PriceLabel)
            label.set_x(activeTp1PriceLabel, activeVisualRight)
            label.set_y(activeTp1PriceLabel, tradeTp1)
        if not na(activeTp2PriceLabel)
            label.set_x(activeTp2PriceLabel, activeVisualRight)
            label.set_y(activeTp2PriceLabel, tradeTp2)
        if not na(activeTp3PriceLabel)
            label.set_x(activeTp3PriceLabel, activeVisualRight)
            label.set_y(activeTp3PriceLabel, tradeTp3)

    if showTradeBoxes
        if not na(activeTpBox)
            box.set_right(activeTpBox, activeVisualRight)
        if not na(activeSlBox)
            box.set_right(activeSlBox, activeVisualRight)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 17. TRADE EXIT MANAGEMENT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

tradeClosedThisBar = false
tradeClosedByTp3 = false
tradeClosedBySl = false
tradeClosedByProtectedTp = false
tradeHiddenByEarlySl = false

if tradeActive
    tp1Touched = tradeSide == 1 ? high >= tradeTp1 : low <= tradeTp1
    tp2Touched = tradeSide == 1 ? high >= tradeTp2 : low <= tradeTp2
    tp3Touched = tradeSide == 1 ? high >= tradeTp3 : low <= tradeTp3
    slTouched  = tradeSide == 1 ? low <= tradeStop : high >= tradeStop

    touchedTpStage =
         tp3Touched ? 3 :
         tp2Touched ? 2 :
         tp1Touched ? 1 : 0

    sameCandleTpAndSl = slTouched and touchedTpStage > 0

    touchedTpPrice =
         touchedTpStage == 3 ? tradeTp3 :
         touchedTpStage == 2 ? tradeTp2 :
         touchedTpStage == 1 ? tradeTp1 : na

    touchedTpText =
         touchedTpStage == 3 ? "TP3" :
         touchedTpStage == 2 ? "TP2" :
         touchedTpStage == 1 ? "TP1" : ""

    if touchedTpStage > tradeBestTpStage and not sameCandleTpAndSl
        tradeBestTpStage := touchedTpStage

        if showActiveTpLabel
            tpStyle = tradeSide == 1 ? label.style_label_down : label.style_label_up
            tpSize  = touchedTpStage == 3 ? size.normal : size.small

            if na(activeTpLabel)
                activeTpLabel := label.new(
                     bar_index,
                     touchedTpPrice,
                     f_boldItalicText(touchedTpText),
                     style = tpStyle,
                     color = color.new(tpLabelColor, 0),
                     textcolor = whiteText,
                     size = tpSize)
            else
                label.set_xy(activeTpLabel, bar_index, touchedTpPrice)
                label.set_text(activeTpLabel, f_boldItalicText(touchedTpText))
                label.set_style(activeTpLabel, tpStyle)
                label.set_color(activeTpLabel, color.new(tpLabelColor, 0))
                label.set_textcolor(activeTpLabel, whiteText)
                label.set_size(activeTpLabel, tpSize)

    barsFromEntry =
         not na(tradeEntryBar) ? bar_index - tradeEntryBar : na

    finalTp3 = not sameCandleTpAndSl and tradeBestTpStage == 3
    finalSl  = slTouched and (tradeBestTpStage == 0 or sameCandleTpAndSl)
    finalProtectedTp = slTouched and not sameCandleTpAndSl and tradeBestTpStage > 0 and tradeBestTpStage < 3
    earlySlHide = finalSl and not na(barsFromEntry) and barsFromEntry <= hideEarlySlBars

    if finalTp3 or finalSl or finalProtectedTp
        tradeClosedThisBar := true
        tradeClosedByTp3 := finalTp3
        tradeClosedBySl := finalSl and not earlySlHide
        tradeClosedByProtectedTp := finalProtectedTp
        tradeHiddenByEarlySl := earlySlHide

        if not earlySlHide
            statResultR =
                 finalTp3 ? tp3RewardR :
                 finalProtectedTp and tradeBestTpStage == 2 ? tp3RewardR * (tp2PercentOfTp3 / 100.0) :
                 finalProtectedTp and tradeBestTpStage == 1 ? tp3RewardR * (tp1PercentOfTp3 / 100.0) :
                 -1.0

            statIsWin = statResultR > 0
            statBarsInTrade = not na(barsFromEntry) ? barsFromEntry : 0

            statTotalClosed += 1
            statTotalR += statResultR
            statTotalBars += statBarsInTrade

            if statIsWin
                statWinTrades += 1
                statGrossWinR += statResultR
                statCurrentWinStreak += 1
                statCurrentLossStreak := 0
                statMaxWinStreak := statCurrentWinStreak > statMaxWinStreak ? statCurrentWinStreak : statMaxWinStreak
                statCurrentStreak := statCurrentWinStreak
            else
                statGrossLossR += math.abs(statResultR)
                statCurrentLossStreak += 1
                statCurrentWinStreak := 0
                statMaxLossStreak := statCurrentLossStreak > statMaxLossStreak ? statCurrentLossStreak : statMaxLossStreak
                statCurrentStreak := -statCurrentLossStreak

            if tradeSide == 1
                statLongTotal += 1
                if statIsWin
                    statLongWins += 1
            else if tradeSide == -1
                statShortTotal += 1
                if statIsWin
                    statShortWins += 1

            if finalTp3
                statTp3 += 1
            else if finalProtectedTp
                if tradeBestTpStage == 2
                    statTp2 += 1
                else
                    statTp1 += 1
            else if finalSl
                statSl += 1

        if earlySlHide
            if not na(activeTp1Line)
                line.delete(activeTp1Line)
            if not na(activeTp2Line)
                line.delete(activeTp2Line)
            if not na(activeTp3Line)
                line.delete(activeTp3Line)
            if not na(activeSlLine)
                line.delete(activeSlLine)

            if not na(activeTpBox)
                box.delete(activeTpBox)
            if not na(activeSlBox)
                box.delete(activeSlBox)

            if not na(activeTpLabel)
                label.delete(activeTpLabel)
            if not na(activeSignalLabel)
                label.delete(activeSignalLabel)

            if not na(activeTp1PriceLabel)
                label.delete(activeTp1PriceLabel)
            if not na(activeTp2PriceLabel)
                label.delete(activeTp2PriceLabel)
            if not na(activeTp3PriceLabel)
                label.delete(activeTp3PriceLabel)

            activeTp1Line := na
            activeTp2Line := na
            activeTp3Line := na
            activeSlLine := na
            activeTpBox := na
            activeSlBox := na
            activeTpLabel := na
            activeSignalLabel := na
            activeTp1PriceLabel := na
            activeTp2PriceLabel := na
            activeTp3PriceLabel := na
        else
            if showTradeLines
                if not na(activeTp1Line)
                    line.set_x2(activeTp1Line, bar_index)
                if not na(activeTp2Line)
                    line.set_x2(activeTp2Line, bar_index)
                if not na(activeTp3Line)
                    line.set_x2(activeTp3Line, bar_index)
                if not na(activeSlLine)
                    line.set_x2(activeSlLine, bar_index)

                if not na(activeTp1PriceLabel)
                    label.set_x(activeTp1PriceLabel, bar_index)
                    label.set_y(activeTp1PriceLabel, tradeTp1)
                if not na(activeTp2PriceLabel)
                    label.set_x(activeTp2PriceLabel, bar_index)
                    label.set_y(activeTp2PriceLabel, tradeTp2)
                if not na(activeTp3PriceLabel)
                    label.set_x(activeTp3PriceLabel, bar_index)
                    label.set_y(activeTp3PriceLabel, tradeTp3)

            if showTradeBoxes
                if not na(activeTpBox)
                    box.set_right(activeTpBox, bar_index)
                if not na(activeSlBox)
                    box.set_right(activeSlBox, bar_index)

            resultStage = finalTp3 ? 3 : finalProtectedTp ? tradeBestTpStage : 0
            resultR =
                 finalTp3 ? tp3RewardR :
                 finalProtectedTp and tradeBestTpStage == 2 ? tp3RewardR * (tp2PercentOfTp3 / 100.0) :
                 finalProtectedTp and tradeBestTpStage == 1 ? tp3RewardR * (tp1PercentOfTp3 / 100.0) :
                 -1.0

            resultPrice =
                 finalTp3 ? tradeTp3 :
                 finalProtectedTp and resultStage == 2 ? tradeTp2 :
                 finalProtectedTp and resultStage == 1 ? tradeTp1 :
                 tradeStop

            resultText =
                 finalTp3 ? "TP3 HIT  WIN " + f_signedRText(resultR) :
                 finalProtectedTp ? "TP" + str.tostring(resultStage) + " EXIT  WIN " + f_signedRText(resultR) :
                 "SL HIT  LOSS -1R"

            resultStyle = tradeSide == 1 ? resultR >= 0 ? label.style_label_down : label.style_label_up : resultR >= 0 ? label.style_label_up : label.style_label_down
            resultColor = resultR >= 0 ? tpLabelColor : slLineColor

            activeExitLabel := label.new(
                 bar_index,
                 resultPrice,
                 f_boldItalicText(resultText),
                 style = resultStyle,
                 color = color.new(resultColor, 0),
                 textcolor = whiteText,
                 size = size.normal)

            if showHistoricalTrades
                array.push(historicalTp1Lines, activeTp1Line)
                array.push(historicalTp2Lines, activeTp2Line)
                array.push(historicalTp3Lines, activeTp3Line)
                array.push(historicalSlLines, activeSlLine)
                array.push(historicalTpBoxes, activeTpBox)
                array.push(historicalSlBoxes, activeSlBox)
                array.push(historicalTpLabels, activeTpLabel)
                array.push(historicalSignalLabels, activeSignalLabel)
                array.push(historicalExitLabels, activeExitLabel)
                array.push(historicalTp1PriceLabels, activeTp1PriceLabel)
                array.push(historicalTp2PriceLabels, activeTp2PriceLabel)
                array.push(historicalTp3PriceLabels, activeTp3PriceLabel)

                historicalTradeCount += 1

                while historicalTradeCount > maxHistoricalTrades
                    if array.size(historicalTp1Lines) > 0
                        oldTp1Line = array.shift(historicalTp1Lines)
                        if not na(oldTp1Line)
                            line.delete(oldTp1Line)

                    if array.size(historicalTp2Lines) > 0
                        oldTp2Line = array.shift(historicalTp2Lines)
                        if not na(oldTp2Line)
                            line.delete(oldTp2Line)

                    if array.size(historicalTp3Lines) > 0
                        oldTp3Line = array.shift(historicalTp3Lines)
                        if not na(oldTp3Line)
                            line.delete(oldTp3Line)

                    if array.size(historicalSlLines) > 0
                        oldSlLine = array.shift(historicalSlLines)
                        if not na(oldSlLine)
                            line.delete(oldSlLine)

                    if array.size(historicalTpBoxes) > 0
                        oldTpBox = array.shift(historicalTpBoxes)
                        if not na(oldTpBox)
                            box.delete(oldTpBox)

                    if array.size(historicalSlBoxes) > 0
                        oldSlBox = array.shift(historicalSlBoxes)
                        if not na(oldSlBox)
                            box.delete(oldSlBox)

                    if array.size(historicalTpLabels) > 0
                        oldTpLabel = array.shift(historicalTpLabels)
                        if not na(oldTpLabel)
                            label.delete(oldTpLabel)

                    if array.size(historicalSignalLabels) > 0
                        oldSignalLabel = array.shift(historicalSignalLabels)
                        if not na(oldSignalLabel)
                            label.delete(oldSignalLabel)

                    if array.size(historicalExitLabels) > 0
                        oldExitLabel = array.shift(historicalExitLabels)
                        if not na(oldExitLabel)
                            label.delete(oldExitLabel)

                    if array.size(historicalTp1PriceLabels) > 0
                        oldTp1PriceLabel = array.shift(historicalTp1PriceLabels)
                        if not na(oldTp1PriceLabel)
                            label.delete(oldTp1PriceLabel)

                    if array.size(historicalTp2PriceLabels) > 0
                        oldTp2PriceLabel = array.shift(historicalTp2PriceLabels)
                        if not na(oldTp2PriceLabel)
                            label.delete(oldTp2PriceLabel)

                    if array.size(historicalTp3PriceLabels) > 0
                        oldTp3PriceLabel = array.shift(historicalTp3PriceLabels)
                        if not na(oldTp3PriceLabel)
                            label.delete(oldTp3PriceLabel)

                    historicalTradeCount -= 1

        if finalTp3 and not earlySlHide
            tp3DirectionLock := tradeSide

        tradeActive := false
        tradeSide := 0
        tradeEntryBar := na
        tradeEntry := na
        tradeStop := na
        tradeTp1 := na
        tradeTp2 := na
        tradeTp3 := na
        tradeBestTpStage := 0


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 18. FINAL SIGNALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

longDirectionUnlocked =
     tp3DirectionLock == 0 or
     tp3DirectionLock == -1

shortDirectionUnlocked =
     tp3DirectionLock == 0 or
     tp3DirectionLock == 1

tradeCanOpen =
     not tradeActive and
     not tradeClosedThisBar and
     not na(tradeAtr)

strongLong =
     setupActive and
     setupDirection == 1 and
     setupPullbackHit and
     bullTrend and
     longConfirm and
     entryDistanceOk and
     mcginleyAllowed and
     rsiLongAllowed and
     cooldownAllowed and
     tradeCanOpen and
     longDirectionUnlocked

strongShort =
     setupActive and
     setupDirection == -1 and
     setupPullbackHit and
     bearTrend and
     shortConfirm and
     entryDistanceOk and
     mcginleyAllowed and
     rsiShortAllowed and
     cooldownAllowed and
     tradeCanOpen and
     shortDirectionUnlocked

if strongLong or strongShort
    lastSignalBar := bar_index
    lastSignalSide := strongLong ? 1 : -1
    setupCompleted := true
    setupActive := false
    setupPullbackHit := false


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 19. NEW TRADE VISUAL HANDOFF
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if strongLong or strongShort
    if not showHistoricalTrades
        if not na(activeTp1Line)
            line.delete(activeTp1Line)
        if not na(activeTp2Line)
            line.delete(activeTp2Line)
        if not na(activeTp3Line)
            line.delete(activeTp3Line)
        if not na(activeSlLine)
            line.delete(activeSlLine)

        if not na(activeTpBox)
            box.delete(activeTpBox)
        if not na(activeSlBox)
            box.delete(activeSlBox)

        if not na(activeTpLabel)
            label.delete(activeTpLabel)
        if not na(activeSignalLabel)
            label.delete(activeSignalLabel)
        if not na(activeExitLabel)
            label.delete(activeExitLabel)

        if not na(activeTp1PriceLabel)
            label.delete(activeTp1PriceLabel)
        if not na(activeTp2PriceLabel)
            label.delete(activeTp2PriceLabel)
        if not na(activeTp3PriceLabel)
            label.delete(activeTp3PriceLabel)

    activeTp1Line := na
    activeTp2Line := na
    activeTp3Line := na
    activeSlLine := na
    activeTpBox := na
    activeSlBox := na
    activeTpLabel := na
    activeSignalLabel := na
    activeExitLabel := na
    activeTp1PriceLabel := na
    activeTp2PriceLabel := na
    activeTp3PriceLabel := na


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 20. TRADE ENTRY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if strongLong
    tradeActive := true
    tradeSide := 1
    tradeEntryBar := bar_index
    tradeEntry := close
    tradeStop := close - tradeAtr * tradeAtrMultiplier
    tradeBestTpStage := 0

    riskDistance = tradeEntry - tradeStop
    tradeTp1 := tradeEntry + riskDistance * tp3RewardR * (tp1PercentOfTp3 / 100.0)
    tradeTp2 := tradeEntry + riskDistance * tp3RewardR * (tp2PercentOfTp3 / 100.0)
    tradeTp3 := tradeEntry + riskDistance * tp3RewardR

    if tp3DirectionLock == -1
        tp3DirectionLock := 0

    if showStrongLabels
        longQualityScore = f_qualityScore(true)
        activeSignalLabel := label.new(
             bar_index,
             low,
             f_boldItalicText("STRONG"),
             style = label.style_label_up,
             color = color.new(longLabelColor, 0),
             textcolor = whiteText,
             size = labelSize,
             tooltip = f_qualityTooltip(true, longQualityScore))

    rightSide = bar_index + initialLineBars

    if showTradeBoxes
        activeTpBox := box.new(
             left = bar_index,
             top = tradeTp3,
             right = rightSide,
             bottom = tradeEntry,
             xloc = xloc.bar_index,
             bgcolor = color.new(tpBoxBgColor, 76),
             border_color = color.new(tpBoxBorderColor, 0),
             border_width = 2,
             text = "",
             text_color = color.new(whiteText, 10),
             text_size = size.tiny)

        activeSlBox := box.new(
             left = bar_index,
             top = tradeEntry,
             right = rightSide,
             bottom = tradeStop,
             xloc = xloc.bar_index,
             bgcolor = color.new(slBoxBgColor, 76),
             border_color = color.new(slBoxBorderColor, 0),
             border_width = 2,
             text = "",
             text_color = color.new(whiteText, 10),
             text_size = size.tiny)

    if showTradeLines
        activeTp1Line := line.new(bar_index, tradeTp1, rightSide, tradeTp1, xloc = xloc.bar_index, color = color.new(tpLineColor, 35), width = 1, style = line.style_dotted)
        activeTp2Line := line.new(bar_index, tradeTp2, rightSide, tradeTp2, xloc = xloc.bar_index, color = color.new(tpLineColor, 15), width = 1, style = line.style_dotted)
        activeTp3Line := line.new(bar_index, tradeTp3, rightSide, tradeTp3, xloc = xloc.bar_index, color = color.new(tpLineColor, 0), width = 2, style = line.style_solid)
        activeSlLine  := line.new(bar_index, tradeStop, rightSide, tradeStop, xloc = xloc.bar_index, color = color.new(slLineColor, 0), width = 2, style = line.style_solid)

        activeTp1PriceLabel := label.new(rightSide, tradeTp1, f_tpPriceText("TP1", tradeTp1), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(tpPriceLabelBg, 0), textcolor = tpPriceLabelText, size = size.small)
        activeTp2PriceLabel := label.new(rightSide, tradeTp2, f_tpPriceText("TP2", tradeTp2), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(tpPriceLabelBg, 0), textcolor = tpPriceLabelText, size = size.small)
        activeTp3PriceLabel := label.new(rightSide, tradeTp3, f_tpPriceText("TP3", tradeTp3), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(tpPriceLabelBg, 0), textcolor = tpPriceLabelText, size = size.small)

if strongShort
    tradeActive := true
    tradeSide := -1
    tradeEntryBar := bar_index
    tradeEntry := close
    tradeStop := close + tradeAtr * tradeAtrMultiplier
    tradeBestTpStage := 0

    riskDistance = tradeStop - tradeEntry
    tradeTp1 := tradeEntry - riskDistance * tp3RewardR * (tp1PercentOfTp3 / 100.0)
    tradeTp2 := tradeEntry - riskDistance * tp3RewardR * (tp2PercentOfTp3 / 100.0)
    tradeTp3 := tradeEntry - riskDistance * tp3RewardR

    if tp3DirectionLock == 1
        tp3DirectionLock := 0

    if showStrongLabels
        shortQualityScore = f_qualityScore(false)
        activeSignalLabel := label.new(
             bar_index,
             high,
             f_boldItalicText("STRONG"),
             style = label.style_label_down,
             color = color.new(shortLabelColor, 0),
             textcolor = whiteText,
             size = labelSize,
             tooltip = f_qualityTooltip(false, shortQualityScore))

    rightSide = bar_index + initialLineBars

    if showTradeBoxes
        activeTpBox := box.new(
             left = bar_index,
             top = tradeEntry,
             right = rightSide,
             bottom = tradeTp3,
             xloc = xloc.bar_index,
             bgcolor = color.new(tpBoxBgColor, 76),
             border_color = color.new(tpBoxBorderColor, 0),
             border_width = 2,
             text = "",
             text_color = color.new(whiteText, 10),
             text_size = size.tiny)

        activeSlBox := box.new(
             left = bar_index,
             top = tradeStop,
             right = rightSide,
             bottom = tradeEntry,
             xloc = xloc.bar_index,
             bgcolor = color.new(slBoxBgColor, 76),
             border_color = color.new(slBoxBorderColor, 0),
             border_width = 2,
             text = "",
             text_color = color.new(whiteText, 10),
             text_size = size.tiny)

    if showTradeLines
        activeTp1Line := line.new(bar_index, tradeTp1, rightSide, tradeTp1, xloc = xloc.bar_index, color = color.new(tpLineColor, 35), width = 1, style = line.style_dotted)
        activeTp2Line := line.new(bar_index, tradeTp2, rightSide, tradeTp2, xloc = xloc.bar_index, color = color.new(tpLineColor, 15), width = 1, style = line.style_dotted)
        activeTp3Line := line.new(bar_index, tradeTp3, rightSide, tradeTp3, xloc = xloc.bar_index, color = color.new(tpLineColor, 0), width = 2, style = line.style_solid)
        activeSlLine  := line.new(bar_index, tradeStop, rightSide, tradeStop, xloc = xloc.bar_index, color = color.new(slLineColor, 0), width = 2, style = line.style_solid)

        activeTp1PriceLabel := label.new(rightSide, tradeTp1, f_tpPriceText("TP1", tradeTp1), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(tpPriceLabelBg, 0), textcolor = tpPriceLabelText, size = size.small)
        activeTp2PriceLabel := label.new(rightSide, tradeTp2, f_tpPriceText("TP2", tradeTp2), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(tpPriceLabelBg, 0), textcolor = tpPriceLabelText, size = size.small)
        activeTp3PriceLabel := label.new(rightSide, tradeTp3, f_tpPriceText("TP3", tradeTp3), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(tpPriceLabelBg, 0), textcolor = tpPriceLabelText, size = size.small)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 21. STATISTICS TABLE / PREMIUM DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

statTp1Rate = statTotalClosed > 0 ? statTp1 / statTotalClosed * 100.0 : 0.0
statTp2Rate = statTotalClosed > 0 ? statTp2 / statTotalClosed * 100.0 : 0.0
statTp3Rate = statTotalClosed > 0 ? statTp3 / statTotalClosed * 100.0 : 0.0
statSlRate  = statTotalClosed > 0 ? statSl / statTotalClosed * 100.0 : 0.0
statWinRate = statTotalClosed > 0 ? statWinTrades / statTotalClosed * 100.0 : 0.0
statAverageR = statTotalClosed > 0 ? statTotalR / statTotalClosed : 0.0
statProfitFactor = statGrossLossR > 0 ? statGrossWinR / statGrossLossR : statGrossWinR > 0 ? 999.0 : 0.0
statExpectancy = statAverageR
statAvgBars = statTotalClosed > 0 ? statTotalBars / statTotalClosed : 0.0
statLongWinRate = statLongTotal > 0 ? statLongWins / statLongTotal * 100.0 : 0.0
statShortWinRate = statShortTotal > 0 ? statShortWins / statShortTotal * 100.0 : 0.0

statBestDirection =
     statLongTotal == 0 and statShortTotal == 0 ? "NONE" :
     statLongTotal > 0 and statShortTotal == 0 ? "LONG" :
     statShortTotal > 0 and statLongTotal == 0 ? "SHORT" :
     statLongWinRate > statShortWinRate ? "LONG" :
     statShortWinRate > statLongWinRate ? "SHORT" :
     "EVEN"

statCurrentStreakText =
     statCurrentStreak > 0 ? "W" + str.tostring(statCurrentStreak) :
     statCurrentStreak < 0 ? "L" + str.tostring(math.abs(statCurrentStreak)) :
     "NONE"

statProfitFactorText = statProfitFactor >= 999.0 ? "INF" : str.tostring(statProfitFactor, "#.##")

premiumTrendText = bullTrend ? "BULLISH" : bearTrend ? "BEARISH" : "NEUTRAL"
premiumStatusText = tradeActive ? "TRADE ACTIVE" : setupActive and setupPullbackHit ? "PULLBACK HIT" : setupActive ? "SETUP ACTIVE" : "WAITING"
premiumTradeText = tradeActive ? tradeSide == 1 ? "LONG" : "SHORT" : "NONE"
premiumLastSignalText = lastSignalSide == 1 ? "LONG" : lastSignalSide == -1 ? "SHORT" : "NONE"
premiumBestTpText = tradeActive and tradeBestTpStage > 0 ? "TP" + str.tostring(tradeBestTpStage) : "NONE"
premiumBiasColor = bullTrend ? longLabelColor : bearTrend ? shortLabelColor : statsNeutralColor
premiumStatusColor = tradeActive ? tpLabelColor : setupActive ? color.rgb(255, 190, 70) : statsNeutralColor

if barstate.islast
    if showPremiumDashboard
        table.cell(premiumDashTable, 0, 0, f_boldItalicText("PULLBACK SNIPER"), text_color = whiteText, bgcolor = color.new(statsHeaderColor, 0), text_size = size.small)
        table.cell(premiumDashTable, 1, 0, f_boldItalicText("PRO"), text_color = tpLabelColor, bgcolor = color.new(statsHeaderColor, 0), text_size = size.small)

        table.cell(premiumDashTable, 0, 1, f_boldItalicText("TREND"), text_color = statsNeutralColor, bgcolor = color.new(statsBgColor, 5), text_size = size.small)
        table.cell(premiumDashTable, 1, 1, f_boldItalicText(premiumTrendText), text_color = premiumBiasColor, bgcolor = color.new(statsBgColor, 5), text_size = size.small)

        table.cell(premiumDashTable, 0, 2, f_boldItalicText("STATUS"), text_color = statsNeutralColor, bgcolor = color.new(statsBgColor, 5), text_size = size.small)
        table.cell(premiumDashTable, 1, 2, f_boldItalicText(premiumStatusText), text_color = premiumStatusColor, bgcolor = color.new(statsBgColor, 5), text_size = size.small)

        table.cell(premiumDashTable, 0, 3, f_boldItalicText("TOTAL TRADES"), text_color = statsNeutralColor, bgcolor = color.new(statsBgColor, 5), text_size = size.small)
        table.cell(premiumDashTable, 1, 3, f_boldItalicText(str.tostring(statTotalClosed)), text_color = whiteText, bgcolor = color.new(statsBgColor, 5), text_size = size.small)

        table.cell(premiumDashTable, 0, 4, f_boldItalicText("BEST DIRECTION"), text_color = statsNeutralColor, bgcolor = color.new(statsBgColor, 5), text_size = size.small)
        table.cell(premiumDashTable, 1, 4, f_boldItalicText(statBestDirection), text_color = statBestDirection == "LONG" ? longLabelColor : statBestDirection == "SHORT" ? shortLabelColor : statsNeutralColor, bgcolor = color.new(statsBgColor, 5), text_size = size.small)

        table.cell(premiumDashTable, 0, 5, f_boldItalicText("ACTIVE"), text_color = statsNeutralColor, bgcolor = color.new(statsBgColor, 5), text_size = size.small)
        table.cell(premiumDashTable, 1, 5, f_boldItalicText(premiumTradeText), text_color = tradeSide == 1 ? longLabelColor : tradeSide == -1 ? shortLabelColor : statsNeutralColor, bgcolor = color.new(statsBgColor, 5), text_size = size.small)

        table.cell(premiumDashTable, 0, 6, f_boldItalicText("LAST SIGNAL"), text_color = whiteText, bgcolor = color.new(statsHeaderColor, 0), text_size = size.small)
        table.cell(premiumDashTable, 1, 6, f_boldItalicText(premiumLastSignalText), text_color = lastSignalSide == 1 ? longLabelColor : lastSignalSide == -1 ? shortLabelColor : statsNeutralColor, bgcolor = color.new(statsHeaderColor, 0), text_size = size.small)
    else
        table.clear(premiumDashTable, 0, 0, 1, 6)

if barstate.islast
    if showStatsTable
        table.cell(statsTable, 0, 0, f_boldItalicText("PULLBACK STATS"), text_color = whiteText, bgcolor = color.new(statsHeaderColor, 0), text_size = size.small)
        table.cell(statsTable, 1, 0, f_boldItalicText("COUNT"), text_color = whiteText, bgcolor = color.new(statsHeaderColor, 0), text_size = size.small)
        table.cell(statsTable, 2, 0, f_boldItalicText("RATE"), text_color = whiteText, bgcolor = color.new(statsHeaderColor, 0), text_size = size.small)

        table.cell(statsTable, 0, 1, f_boldItalicText("TP1"), text_color = statsWinColor, bgcolor = color.new(statsBgColor, 5), text_size = size.small)
        table.cell(statsTable, 1, 1, f_boldItalicText(str.tostring(statTp1)), text_color = whiteText, bgcolor = color.new(statsBgColor, 5), text_size = size.small)
        table.cell(statsTable, 2, 1, f_boldItalicText(str.tostring(statTp1Rate, "#.##") + "%"), text_color = statsWinColor, bgcolor = color.new(statsBgColor, 5), text_size = size.small)

        table.cell(statsTable, 0, 2, f_boldItalicText("TP2"), text_color = statsWinColor, bgcolor = color.new(statsBgColor, 5), text_size = size.small)
        table.cell(statsTable, 1, 2, f_boldItalicText(str.tostring(statTp2)), text_color = whiteText, bgcolor = color.new(statsBgColor, 5), text_size = size.small)
        table.cell(statsTable, 2, 2, f_boldItalicText(str.tostring(statTp2Rate, "#.##") + "%"), text_color = statsWinColor, bgcolor = color.new(statsBgColor, 5), text_size = size.small)

        table.cell(statsTable, 0, 3, f_boldItalicText("TP3"), text_color = statsWinColor, bgcolor = color.new(statsBgColor, 5), text_size = size.small)
        table.cell(statsTable, 1, 3, f_boldItalicText(str.tostring(statTp3)), text_color = whiteText, bgcolor = color.new(statsBgColor, 5), text_size = size.small)
        table.cell(statsTable, 2, 3, f_boldItalicText(str.tostring(statTp3Rate, "#.##") + "%"), text_color = statsWinColor, bgcolor = color.new(statsBgColor, 5), text_size = size.small)

        table.cell(statsTable, 0, 4, f_boldItalicText("SL"), text_color = statsLossColor, bgcolor = color.new(statsBgColor, 5), text_size = size.small)
        table.cell(statsTable, 1, 4, f_boldItalicText(str.tostring(statSl)), text_color = whiteText, bgcolor = color.new(statsBgColor, 5), text_size = size.small)
        table.cell(statsTable, 2, 4, f_boldItalicText(str.tostring(statSlRate, "#.##") + "%"), text_color = statsLossColor, bgcolor = color.new(statsBgColor, 5), text_size = size.small)

        table.cell(statsTable, 0, 5, f_boldItalicText("TOTAL"), text_color = statsNeutralColor, bgcolor = color.new(statsBgColor, 5), text_size = size.small)
        table.cell(statsTable, 1, 5, f_boldItalicText(str.tostring(statTotalClosed)), text_color = whiteText, bgcolor = color.new(statsBgColor, 5), text_size = size.small)
        table.cell(statsTable, 2, 5, f_boldItalicText("100%"), text_color = statsNeutralColor, bgcolor = color.new(statsBgColor, 5), text_size = size.small)

    else
        table.clear(statsTable, 0, 0, 2, 5)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 22. ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(strongLong, title = "Strong Long", message = "Pullback Sniper Method [trade_w_samet]: STRONG LONG on {{ticker}} {{interval}}.")
alertcondition(strongShort, title = "Strong Short", message = "Pullback Sniper Method [trade_w_samet]: STRONG SHORT on {{ticker}} {{interval}}.")
alertcondition(tradeClosedByTp3, title = "TP3 Hit", message = "Pullback Sniper Method [trade_w_samet]: TP3 hit on {{ticker}} {{interval}}.")
alertcondition(tradeClosedBySl, title = "SL Hit", message = "Pullback Sniper Method [trade_w_samet]: SL hit on {{ticker}} {{interval}}.")
alertcondition(tradeClosedByProtectedTp, title = "Protected TP Exit", message = "Pullback Sniper Method [trade_w_samet]: Trade protected by last touched TP on {{ticker}} {{interval}}.")
````
