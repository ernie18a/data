# IFVG Sniper Entry Engine [trade_w_samet]

- url: https://www.tradingview.com/script/kz0NSVR5-IFVG-Sniper-Entry-Engine-trade-w-samet/
- type: indicator
- pine_id: PUB;7e6d6ea95879446b99c877a940762418
- version: 2.0

## Description

🎯 IFVG Sniper Entry Engine [trade_w_samet]

IFVG Sniper Entry Engine [trade_w_samet] is a clean, focused, and structured Inversion Fair Value Gap analysis indicator designed to help traders study filtered IFVG conditions directly on the price chart.

This script focuses on one main concept:

IFVG-based entry visualization.

It is not designed to be a complex all-in-one trading system.

It is not designed to show every possible Fair Value Gap.

It is not designed to generate constant chart noise.

Instead, the goal of IFVG Sniper Entry Engine is to detect filtered Inversion Fair Value Gap events, display clean IFVG+ / IFVG- labels, and visualize a simple active trade projection using one entry level, one stop-loss level, and one take-profit level.

The indicator includes:

• Inversion Fair Value Gap detection
• Filtered IFVG selection
• Bullish IFVG+ and bearish IFVG- chart labels
• Thin blue bullish IFVG lines
• Thin red bearish IFVG lines
• Adjustable IFVG label size
• ATR-based stop-loss projection
• Selectable take-profit RR from 1R to 6R
• Active TP / SL visual box
• One-active-trade-at-a-time logic
• Confirmed-candle IFVG processing
• IFVG invalidation handling
• Simple dashboard
• Professional alert conditions

The purpose of this script is to help users visually study where an FVG has inverted and whether that inversion may create a structured review point on the chart.

It should be treated as a chart-analysis and educational decision-support tool.

It is not financial advice.
It is not an automated trading system.
It does not guarantee profitable trades.
It does not execute broker orders.
It does not replace personal analysis, risk management, or trade validation.

━━━━━━━━━━━━━━━━━━━━━━
📌 OVERVIEW
━━━━━━━━━━━━━━━━━━━━━━

At a high level, IFVG Sniper Entry Engine does the following:

• Detects bullish and bearish Fair Value Gaps.
• Stores valid hidden FVG zones in memory.
• Watches for price to invert those zones.
• Confirms bullish IFVG when a bearish FVG is broken upward.
• Confirms bearish IFVG when a bullish FVG is broken downward.
• Applies an optional IFVG quality filter.
• Draws only filtered IFVGs on the chart.
• Displays IFVG+ for bullish IFVG events.
• Displays IFVG- for bearish IFVG events.
• Projects one active entry, stop-loss, and take-profit box.
• Allows only one active trade projection at a time.
• Removes the active TP/SL box after TP or SL is reached.
• Tracks basic visual trade outcome statistics in the dashboard.
• Provides alert conditions for IFVG entries and IFVG formations.

The script is intentionally built to be simple and focused.

It does not include multiple take-profit levels.

It does not include machine-learning optimization.

It does not include hidden performance promises.

It does not attempt to predict the future.

It provides a structured way to visualize filtered IFVG events and their projected trade model.

━━━━━━━━━━━━━━━━━━━━━━
🧠 CORE IDEA
━━━━━━━━━━━━━━━━━━━━━━

The core idea behind IFVG Sniper Entry Engine is based on Inversion Fair Value Gaps.

A Fair Value Gap represents an imbalance area created when price moves aggressively enough to leave a gap-like inefficiency between candles.

An Inversion Fair Value Gap occurs when price later breaks through a previously formed FVG in the opposite direction.

This can be useful for traders who study:

• market imbalance
• failed displacement zones
• price repricing behavior
• continuation after inversion
• possible shift in directional pressure
• clean chart-based trade planning

The script does not treat every FVG as important.

Instead, it stores FVGs and waits for inversion behavior.

Then it filters the IFVG event using quality conditions such as gap size, candle body strength, candle range, and clean break logic.

The goal is not to show more signals.

The goal is to reduce noise and highlight cleaner IFVG conditions.

━━━━━━━━━━━━━━━━━━━━━━
🧩 WHY THIS SCRIPT IS NOT A SIMPLE BUY/SELL INDICATOR
━━━━━━━━━━━━━━━━━━━━━━

IFVG Sniper Entry Engine is not intended to be used as a blind buy/sell system.

The script is structured as a visual review workflow:

Fair Value Gap forms
→ FVG is stored in memory
→ price later breaks through the opposite side
→ inversion is detected
→ IFVG quality filter is checked
→ IFVG+ or IFVG- is displayed
→ active entry / SL / TP projection is drawn
→ trade box extends while active
→ result is tracked visually
→ box is removed after TP or SL

Each part has a specific purpose.

The FVG memory system stores imbalance zones.
The inversion logic checks whether price has broken the opposite side of the stored zone.
The filter system attempts to reduce weaker IFVG events.
The entry model gives a simple visual planning level.
The ATR stop-loss model creates a consistent risk reference.
The RR setting controls the projected target distance.
The dashboard summarizes the current state.
The alert system helps monitor confirmed events.

This makes the script a structured IFVG review tool, not a guaranteed trade signal generator.

━━━━━━━━━━━━━━━━━━━━━━
⚙️ HOW THE SCRIPT WORKS
━━━━━━━━━━━━━━━━━━━━━━

The script first detects normal bullish and bearish Fair Value Gaps.

A bullish FVG is detected when the current candle structure leaves an imbalance above the candle from two bars earlier.

A bearish FVG is detected when the current candle structure leaves an imbalance below the candle from two bars earlier.

Once a raw FVG is detected, the script stores:

• top of the FVG
• bottom of the FVG
• original FVG direction
• age of the FVG
• gap size relative to ATR
• candle body ratio
• candle range relative to ATR

These values are stored internally and are later used when an inversion happens.

The script then waits for price to break through the stored FVG in the opposite direction.

For a bullish IFVG:

A previously bearish FVG must be broken upward.

For a bearish IFVG:

A previously bullish FVG must be broken downward.

When inversion is detected, the script checks whether the IFVG passes the selected filter mode.

Only filtered IFVGs are displayed on the chart.

━━━━━━━━━━━━━━━━━━━━━━
🔵 BULLISH IFVG+ LOGIC
━━━━━━━━━━━━━━━━━━━━━━

A bullish IFVG+ appears when a previously bearish Fair Value Gap is inverted to the upside.

In practical terms, the script looks for a stored bearish FVG and then checks whether price closes above the top boundary of that FVG.

If the selected filter conditions are satisfied, the script draws:

• a thin blue IFVG line
• an IFVG+ label
• a bullish active trade projection if no trade is already active

The bullish trade projection uses:

• entry level
• ATR-based stop-loss below entry
• selected RR-based take-profit above entry

This does not mean price must continue upward.

It only means the script detected a bullish IFVG condition based on its internal rules.

━━━━━━━━━━━━━━━━━━━━━━
🔴 BEARISH IFVG- LOGIC
━━━━━━━━━━━━━━━━━━━━━━

A bearish IFVG- appears when a previously bullish Fair Value Gap is inverted to the downside.

In practical terms, the script looks for a stored bullish FVG and then checks whether price closes below the bottom boundary of that FVG.

If the selected filter conditions are satisfied, the script draws:

• a thin red IFVG line
• an IFVG- label
• a bearish active trade projection if no trade is already active

The bearish trade projection uses:

• entry level
• ATR-based stop-loss above entry
• selected RR-based take-profit below entry

This does not mean price must continue downward.

It only means the script detected a bearish IFVG condition based on its internal rules.

━━━━━━━━━━━━━━━━━━━━━━
💎 IFVG FILTER SYSTEM
━━━━━━━━━━━━━━━━━━━━━━

The script includes an IFVG filter system to reduce chart noise.

This is important because not every inversion is meaningful.

The filter system can be set to:

Off
Loose
Balanced
Strict
Custom

Off mode shows all detected IFVG events.

Loose mode allows more IFVGs and uses lower quality requirements.

Balanced mode is the default middle-ground setting.

Strict mode requires stronger IFVG conditions and will show fewer signals.

Custom mode allows the user to manually control the filter thresholds.

The filter evaluates:

• minimum gap size relative to ATR
• minimum candle body ratio
• minimum candle range relative to ATR
• clean break buffer relative to ATR

This creates a more selective IFVG workflow.

The filter does not guarantee better future outcomes.

It only controls how strict the script is before displaying an IFVG.

━━━━━━━━━━━━━━━━━━━━━━
📏 GAP / ATR FILTER
━━━━━━━━━━━━━━━━━━━━━━

The gap filter measures the original Fair Value Gap size relative to ATR.

This helps avoid very small imbalance zones that may not be meaningful on the selected chart.

A larger minimum gap requirement makes the indicator more selective.

A smaller minimum gap requirement allows more IFVGs.

The default Balanced setting uses a moderate gap requirement.

Users can adjust this in Custom mode.

━━━━━━━━━━━━━━━━━━━━━━
🕯️ BODY RATIO FILTER
━━━━━━━━━━━━━━━━━━━━━━

The body ratio filter measures the candle body compared to the full candle range.

This helps evaluate whether the candle that created the FVG had meaningful directional pressure.

A stronger body ratio requirement can reduce weaker candles.

A lower body ratio requirement allows more setups.

This is not a prediction tool.

It is only a candle-quality filter.

━━━━━━━━━━━━━━━━━━━━━━
📊 RANGE / ATR FILTER
━━━━━━━━━━━━━━━━━━━━━━

The range filter measures the candle’s full range relative to ATR.

This helps the script avoid very small candles that may not represent meaningful displacement.

A higher range/ATR requirement makes the script more selective.

A lower range/ATR requirement increases the number of visible IFVGs.

The value should be adjusted based on symbol volatility and timeframe.

━━━━━━━━━━━━━━━━━━━━━━
🧼 CLEAN BREAK FILTER
━━━━━━━━━━━━━━━━━━━━━━

The clean break filter requires price to break beyond the IFVG boundary by an ATR-based buffer.

This helps avoid very small boundary touches.

For bullish IFVGs, price must close above the stored FVG top plus the clean break buffer.

For bearish IFVGs, price must close below the stored FVG bottom minus the clean break buffer.

The clean break buffer can be controlled in Custom mode.

A higher buffer makes the inversion requirement stricter.

A lower buffer allows more IFVG events.

━━━━━━━━━━━━━━━━━━━━━━
🎯 ENTRY MODEL
━━━━━━━━━━━━━━━━━━━━━━

When a filtered IFVG appears and no active trade is already open, the script creates a visual trade projection.

The entry can be based on:

IFVG Line
Confirmation Close

IFVG Line mode uses the selected IFVG line price as the projected entry reference.

Confirmation Close mode uses the candle close that confirmed the IFVG.

The entry is only a visual reference.

It is not a broker order.

It does not mean the user must enter a trade.

It is designed to help users review how the IFVG setup would look with a structured risk/reward model.

━━━━━━━━━━━━━━━━━━━━━━
🛑 ATR STOP-LOSS MODEL
━━━━━━━━━━━━━━━━━━━━━━

The stop-loss projection is based on ATR.

The main settings are:

ATR Length
SL ATR Multiplier

For bullish IFVG entries, the stop-loss is projected below the entry.

For bearish IFVG entries, the stop-loss is projected above the entry.

ATR is used because market volatility changes across symbols and timeframes.

A higher SL ATR multiplier creates a wider visual risk area.

A lower SL ATR multiplier creates a tighter visual risk area.

This stop-loss level is a visual projection only.

It does not place an order.

It does not guarantee that the level is appropriate for every trader or every market.

━━━━━━━━━━━━━━━━━━━━━━
🎯 TAKE-PROFIT RR MODEL
━━━━━━━━━━━━━━━━━━━━━━

The script uses one take-profit level.

There are no TP1, TP2, or TP3 levels.

The take-profit is calculated from the projected risk distance.

Available RR options:

1R
2R
3R
4R
5R
6R

Default:

3R

For bullish IFVG entries, TP is projected above entry.

For bearish IFVG entries, TP is projected below entry.

The RR setting only controls the visual projected target distance.

It should not be interpreted as a recommendation or guarantee.

Users should decide whether the projected target makes sense based on their own analysis, market structure, liquidity, session, volatility, and risk plan.

━━━━━━━━━━━━━━━━━━━━━━
📦 ACTIVE TP / SL BOX SYSTEM
━━━━━━━━━━━━━━━━━━━━━━

When a new valid IFVG entry appears, the script draws a clean active TP / SL visual model.

The visual model includes:

• TP box
• SL box
• entry line
• stop-loss line
• take-profit line
• ENTRY label
• SL label
• TP label

The TP/SL box remains visible only while the trade projection is active.

While the trade is active, the box extends to the right as new candles form.

When TP or SL is reached, the active trade box is removed from the chart.

This means historical TP/SL boxes are not kept.

The chart remains cleaner and only the active trade projection is visible.

━━━━━━━━━━━━━━━━━━━━━━
🚦 ONE ACTIVE TRADE AT A TIME
━━━━━━━━━━━━━━━━━━━━━━

The script includes one-active-trade-at-a-time logic.

If a trade projection is active, the script will not open another trade projection until the active one reaches TP or SL.

However, new filtered IFVG lines can still appear on the chart.

This design separates:

• IFVG detection
• trade projection permission

An IFVG can appear while a trade is active, but it will not create a new active TP/SL box.

The dashboard tracks blocked IFVG events internally.

This helps keep the chart structured and avoids multiple overlapping trade boxes.

━━━━━━━━━━━━━━━━━━━━━━
⚠️ SAME-CANDLE TP / SL HANDLING
━━━━━━━━━━━━━━━━━━━━━━

If TP and SL are both touched on the same candle, the true intrabar sequence cannot be known from standard OHLC chart data.

This script uses a conservative assumption:

SL is counted first.

This avoids overly optimistic historical visual results when the actual intrabar order is unknown.

Users should understand that this is still a bar-based assumption.

It does not represent broker execution.

It does not include spread, slippage, commissions, order delay, or partial fills.

━━━━━━━━━━━━━━━━━━━━━━
🏷️ IFVG LABELS
━━━━━━━━━━━━━━━━━━━━━━

The script uses simple IFVG labels:

IFVG+
IFVG-

IFVG+ represents a bullish Inversion Fair Value Gap.

IFVG- represents a bearish Inversion Fair Value Gap.

The label size can be adjusted from the settings.

Available label sizes:

Tiny
Small
Normal
Large
Huge

The default label size is Large.

This allows users to adjust visibility depending on chart zoom, monitor size, and visual preference.

━━━━━━━━━━━━━━━━━━━━━━
📍 IFVG LINE PRICE MODES
━━━━━━━━━━━━━━━━━━━━━━

The IFVG line can be drawn using different price references.

Available modes:

Broken Boundary
Confirmation Close
Midpoint

Broken Boundary mode draws the line at the boundary that was broken during inversion.

Confirmation Close mode draws the line at the candle close that confirmed the IFVG.

Midpoint mode draws the line at the midpoint of the original FVG zone.

Each mode gives a different way to visualize the IFVG reference level.

There is no universally best option.

Users should choose the line mode that best matches their own review method.

━━━━━━━━━━━━━━━━━━━━━━
🧹 IFVG INVALIDATION
━━━━━━━━━━━━━━━━━━━━━━

The script can automatically remove invalidated IFVG lines.

For bullish IFVGs, invalidation occurs when price closes back below the lower boundary of the IFVG zone.

For bearish IFVGs, invalidation occurs when price closes back above the upper boundary of the IFVG zone.

This helps keep the chart cleaner by removing IFVG levels that are no longer valid according to the script’s internal logic.

Users can disable this setting if they prefer to keep IFVG lines visible.

━━━━━━━━━━━━━━━━━━━━━━
📟 DASHBOARD
━━━━━━━━━━━━━━━━━━━━━━

The script includes a compact dashboard.

The dashboard displays:

• selected filter mode
• selected label size
• last signal direction
• active trade status
• selected RR
• latest entry level
• latest SL level
• latest TP level
• active box state
• filtered IFVG count
• trades / wins / losses

The dashboard is designed to provide a quick summary of the current script state.

It is not a full performance report.

It is not a replacement for TradingView Strategy Tester.

It is a visual summary based on the script’s internal bar-based projection logic.

━━━━━━━━━━━━━━━━━━━━━━
🚨 ALERT SYSTEM
━━━━━━━━━━━━━━━━━━━━━━

IFVG Sniper Entry Engine includes alert conditions for:

Bullish IFVG Entry
Bearish IFVG Entry
Bullish IFVG+ formed
Bearish IFVG- formed

The entry alerts are triggered when a filtered IFVG creates a new active trade projection.

The IFVG formation alerts are triggered when filtered IFVG+ or IFVG- conditions appear.

Alerts are monitoring tools only.

They do not execute trades.

They do not place broker orders.

Users must confirm all alerts with their own analysis and risk management.

━━━━━━━━━━━━━━━━━━━━━━
🔔 HOW TO USE ALERTS
━━━━━━━━━━━━━━━━━━━━━━

A practical alert workflow:

1. Add IFVG Sniper Entry Engine [trade_w_samet] to your chart.
2. Open TradingView’s alert window.
3. Select the indicator as the alert condition.
4. Choose the desired alert type.
5. Select alert frequency according to your preference.
6. Use alerts for monitoring only.
7. Confirm each alert manually before making any trading decision.

Alerts may behave differently depending on timeframe, symbol, session, and real-time candle updates.

━━━━━━━━━━━━━━━━━━━━━━
🧪 HOW TO USE THE INDICATOR
━━━━━━━━━━━━━━━━━━━━━━

A practical workflow:

1. Add IFVG Sniper Entry Engine [trade_w_samet] to your chart.
2. Start with the default Balanced filter mode.
3. Review the visible IFVG+ and IFVG- labels.
4. Check whether the IFVG appears in a meaningful market context.
5. Review the active TP/SL projection if a trade model appears.
6. Use the selected RR level as a visual planning reference only.
7. Avoid treating every IFVG as a trade.
8. Combine the tool with your own market structure, liquidity, trend, session, and risk-management rules.
9. Use alerts for monitoring, not automatic execution.
10. Test the indicator on the exact markets and timeframes you personally study.

The indicator is best used as a structured IFVG review tool.

It should not be used as a blind execution system.

━━━━━━━━━━━━━━━━━━━━━━
⚙️ SETTINGS REFERENCE
━━━━━━━━━━━━━━━━━━━━━━

⚙️ IFVG Engine

Hidden FVG Memory
Controls how many raw FVGs can be stored internally.

Max Hidden FVG Age
Controls how long a hidden FVG remains eligible for inversion.

Minimum FVG Size / Ticks
Sets the minimum raw FVG size using ticks.

Max Visible IFVG
Controls how many IFVG lines and labels can remain visible.

IFVG Line Length Bars
Controls how far the IFVG line extends to the right.

IFVG Line Price
Controls whether the IFVG line is drawn from Broken Boundary, Confirmation Close, or Midpoint.

Delete Invalidated IFVG
Removes IFVG lines when the script detects invalidation.

━━━━━━━━━━━━━━━━━━━━━━

💎 IFVG Filter

IFVG Filter Mode
Controls how selective the IFVG display logic is.

Available modes:

Off
Loose
Balanced
Strict
Custom

Custom Minimum Gap / ATR
Defines the minimum FVG gap size relative to ATR when Custom mode is selected.

Custom Minimum Body Ratio
Defines the minimum body-to-range ratio when Custom mode is selected.

Custom Minimum Range / ATR
Defines the minimum candle range relative to ATR when Custom mode is selected.

Custom Clean Break Buffer / ATR
Defines the ATR-based clean break buffer when Custom mode is selected.

━━━━━━━━━━━━━━━━━━━━━━

🎯 IFVG Entry Model

Entry Price
Controls whether entry is based on IFVG Line or Confirmation Close.

ATR Length
Defines the ATR length used for risk calculation.

SL ATR Multiplier
Controls the distance of the projected stop-loss.

Take Profit RR
Controls the projected take-profit distance.

Available RR values:

1R
2R
3R
4R
5R
6R

Initial TP / SL Box Length
Controls the initial box length when a new active trade projection appears.

━━━━━━━━━━━━━━━━━━━━━━

🎨 Visual Style

Bullish IFVG Blue
Controls the color of bullish IFVG+ lines and labels.

Bearish IFVG Red
Controls the color of bearish IFVG- lines and labels.

IFVG Label Size
Controls the size of IFVG+ and IFVG- labels.

Entry Line Color
Controls the entry line color.

SL Color
Controls the stop-loss box and line color.

TP Color
Controls the take-profit box and line color.

Dashboard Background
Controls the dashboard background color.

Dashboard Text
Controls the dashboard text color.

━━━━━━━━━━━━━━━━━━━━━━

📟 Dashboard

Show Dashboard
Shows or hides the compact dashboard.

━━━━━━━━━━━━━━━━━━━━━━
🧠 WHAT MAKES THIS SCRIPT ORIGINAL
━━━━━━━━━━━━━━━━━━━━━━

IFVG Sniper Entry Engine uses familiar market concepts such as:

• Fair Value Gaps
• Inversion Fair Value Gaps
• ATR-based risk projection
• risk/reward planning
• label-based visual mapping
• active trade visualization
• alert monitoring

These concepts are not unique by themselves.

The originality of this script lies in how they are organized into a clean IFVG workflow:

Raw FVG detection
→ hidden FVG memory
→ inversion confirmation
→ IFVG quality filter
→ IFVG+ / IFVG- display
→ one-active-trade rule
→ ATR stop-loss projection
→ selectable RR target
→ active-only TP/SL box
→ compact dashboard
→ alerts

This structure is designed to give users a focused way to review filtered IFVG conditions without unnecessary chart clutter.

━━━━━━━━━━━━━━━━━━━━━━
⚠️ IMPORTANT PRACTICAL NOTES
━━━━━━━━━━━━━━━━━━━━━━

The script’s behavior depends heavily on settings.

Signal frequency and visual output may change based on:

• filter mode
• ATR length
• SL multiplier
• RR selection
• IFVG line mode
• minimum gap settings
• candle body settings
• range/ATR settings
• clean break buffer
• timeframe
• symbol volatility
• market session
• available historical bars

A setting that looks clean on one symbol may behave differently on another.

A setting that appears useful on one timeframe may not be useful on another.

Users should test the script on the exact markets and timeframes they personally study.

━━━━━━━━━━━━━━━━━━━━━━
⚠️ LIMITATIONS AND SHORTCOMINGS
━━━━━━━━━━━━━━━━━━━━━━

This script has important limitations:

It does not guarantee profitable trades.
It does not predict future price movement.
It does not replace risk management.
It does not execute trades.
It does not place broker orders.
It does not include broker slippage.
It does not include commissions.
It does not include spreads.
It does not include order delay.
It does not include partial fills.
It uses bar-based chart data.
Same-candle TP/SL order cannot be known from standard OHLC data.
The dashboard is not TradingView Strategy Tester.
The TP/SL boxes are visual projections only.
Alerts are monitoring tools only.
Historical visual behavior does not ensure future behavior.
Filter settings do not guarantee better results.
One-active-trade logic is a visual management rule, not broker execution logic.

For these reasons, IFVG Sniper Entry Engine should be used as an educational decision-support and chart-analysis tool, not as a standalone trading strategy.

━━━━━━━━━━━━━━━━━━━━━━
👤 WHO THIS SCRIPT MAY BE USEFUL FOR
━━━━━━━━━━━━━━━━━━━━━━

This script may be useful for traders who:

• study IFVG concepts
• study Fair Value Gap inversions
• want cleaner IFVG chart visuals
• prefer filtered signals instead of every raw IFVG
• want a simple one-TP projection model
• want ATR-based risk visualization
• want one active trade projection at a time
• want active-only TP/SL boxes
• want IFVG+ and IFVG- labels
• want alert-based monitoring
• want a focused educational analysis tool

It may be less suitable for users who:

• want guaranteed buy/sell signals
• want a fully automated trading bot
• want many take-profit levels
• want every raw FVG displayed
• expect one setting to work on every market
• expect alerts to execute trades
• expect visual projections to match broker execution
• want an indicator that replaces personal decision-making

━━━━━━━━━━━━━━━━━━━━━━
🧭 BEST PRACTICE SUGGESTIONS
━━━━━━━━━━━━━━━━━━━━━━

For cleaner review:

• Start with the default Balanced filter mode.
• Use Strict mode if the chart is too noisy.
• Use Loose mode if the chart shows too few IFVGs.
• Use Custom mode only after understanding how each filter affects signal frequency.
• Review IFVGs together with market structure.
• Check whether the IFVG appears near meaningful liquidity or displacement context.
• Do not treat every IFVG+ or IFVG- as a trade.
• Use the TP/SL box as a visual planning tool only.
• Keep expectations realistic.
• Use alerts for monitoring, not automatic execution.
• Always apply independent analysis and risk management.

━━━━━━━━━━━━━━━━━━━━━━
🔓 PUBLICATION NOTE
━━━━━━━━━━━━━━━━━━━━━━

IFVG Sniper Entry Engine [trade_w_samet] is published as an educational and visual market-analysis tool.

The purpose of this description is to explain:

• what the script does
• how IFVG conditions are detected
• how IFVG filters work
• how IFVG+ and IFVG- labels are created
• how the entry model is projected
• how the ATR stop-loss model works
• how the RR-based take-profit is calculated
• how the active TP/SL box behaves
• how the one-active-trade rule works
• what the dashboard shows
• what the alerts do
• what the limitations are
• how the indicator should and should not be used

The script is designed to support structured analysis.

It does not promise profitable results.

It does not remove market risk.

It does not execute trades.

It should not be used as a blind buy/sell system.

It is best used as a visual framework for reviewing filtered Inversion Fair Value Gap conditions and projected risk/reward behavior.

━━━━━━━━━━━━━━━━━━━━━━
🛡️ DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━

IFVG Sniper Entry Engine [trade_w_samet] is provided for educational and informational purposes only.

It does not constitute financial, investment, or trading advice.

No indicator can guarantee future results.

Markets are uncertain, conditions change, and historical behavior does not ensure future performance.

Every user is responsible for their own analysis, validation, risk management, position sizing, and trading decisions.

The IFVG+ labels, IFVG- labels, active TP/SL boxes, dashboard values, RR projections, stop-loss projections, and alerts are visual analysis tools only.

Use this script as a structured decision-support and visual review framework, not as a promise of profitability.

## Source Code

````pine
//@version=6
indicator("IFVG Sniper Entry Engine [trade_w_samet]", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=100)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ⚙️ 01. IFVG ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupIFVG = "⚙️ 01. IFVG Engine"

maxHiddenFVG = input.int(
     120,
     "🧠 Hidden FVG Memory",
     minval=10,
     maxval=500,
     group=groupIFVG,
     tooltip="Controls how many hidden FVG structures are stored internally before IFVG inversion is checked.",
     display=display.none
)

maxFvgAge = input.int(
     60,
     "⏳ Max Hidden FVG Age",
     minval=5,
     maxval=500,
     group=groupIFVG,
     tooltip="Maximum bar age for hidden FVG structures before they expire.",
     display=display.none
)

minGapTicks = input.int(
     0,
     "📏 Minimum FVG Size / Ticks",
     minval=0,
     group=groupIFVG,
     tooltip="Minimum raw tick size required before a hidden FVG can be stored.",
     display=display.none
)

maxVisibleIFVG = input.int(
     20,
     "📌 Max Visible IFVG",
     minval=1,
     maxval=100,
     group=groupIFVG,
     tooltip="Maximum number of visible IFVG lines kept on the chart.",
     display=display.none
)

ifvgLengthBars = input.int(
     50,
     "↔️ IFVG Line Length Bars",
     minval=5,
     maxval=500,
     group=groupIFVG,
     tooltip="Controls how far IFVG lines extend to the right.",
     display=display.none
)

linePriceMode = input.string(
     "Broken Boundary",
     "📍 IFVG Line Price",
     options=["Broken Boundary", "Confirmation Close", "Midpoint"],
     group=groupIFVG,
     tooltip="Controls whether IFVG lines are drawn from the broken boundary, confirmation close, or midpoint.",
     display=display.none
)

deleteInvalidIFVG = input.bool(
     true,
     "🧹 Delete Invalidated IFVG",
     group=groupIFVG,
     tooltip="Automatically deletes IFVG lines when price invalidates the structure.",
     display=display.none
)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 💎 02. IFVG FILTER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupFilter = "💎 02. IFVG Filter"

filterMode = input.string(
     "Balanced",
     "💎 IFVG Filter Mode",
     options=["Off", "Loose", "Balanced", "Strict", "Custom"],
     group=groupFilter,
     tooltip="Controls how strict the IFVG quality filter should be.",
     display=display.none
)

customMinGapAtr = input.float(
     0.25,
     "💎 Custom Minimum Gap / ATR",
     minval=0.0,
     step=0.05,
     group=groupFilter,
     tooltip="Custom minimum gap size measured against ATR. Used only in Custom mode.",
     display=display.none
)

customMinBodyRatio = input.float(
     0.50,
     "💎 Custom Minimum Body Ratio",
     minval=0.0,
     maxval=1.0,
     step=0.05,
     group=groupFilter,
     tooltip="Custom minimum candle body ratio. Used only in Custom mode.",
     display=display.none
)

customMinRangeAtr = input.float(
     0.60,
     "💎 Custom Minimum Range / ATR",
     minval=0.0,
     step=0.05,
     group=groupFilter,
     tooltip="Custom minimum candle range measured against ATR. Used only in Custom mode.",
     display=display.none
)

customBreakAtr = input.float(
     0.05,
     "💎 Custom Clean Break Buffer / ATR",
     minval=0.0,
     step=0.01,
     group=groupFilter,
     tooltip="Extra ATR buffer required for IFVG confirmation. Used only in Custom mode.",
     display=display.none
)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🎯 03. IFVG ENTRY MODEL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupTrade = "🎯 03. IFVG Entry Model"

entryMode = input.string(
     "IFVG Line",
     "🎯 Entry Price",
     options=["IFVG Line", "Confirmation Close"],
     group=groupTrade,
     tooltip="IFVG Line uses the IFVG level as entry reference. Confirmation Close uses the close that confirmed the IFVG.",
     display=display.none
)

atrLen = input.int(
     14,
     "📐 ATR Length",
     minval=1,
     group=groupTrade,
     tooltip="ATR length used for the visual SL calculation.",
     display=display.none
)

slAtrMult = input.float(
     1.5,
     "🛡️ SL ATR Multiplier",
     minval=0.1,
     step=0.1,
     group=groupTrade,
     tooltip="Controls how far the visual SL is placed from entry using ATR.",
     display=display.none
)

tpRRInput = input.string(
     "3R",
     "🎯 Take Profit RR",
     options=["1R", "2R", "3R", "4R", "5R", "6R"],
     group=groupTrade,
     tooltip="Selects the visual take-profit RR target.",
     display=display.none
)

initialBoxLength = input.int(
     5,
     "📦 Initial TP / SL Box Length",
     minval=1,
     maxval=50,
     group=groupTrade,
     tooltip="Initial box extension length when a new IFVG trade model appears.",
     display=display.none
)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🎨 04. VISUAL STYLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupStyle = "🎨 04. Visual Style"

themePackage = input.string(
     "Obsidian Sniper",
     "🎨 Theme Package",
     options=["Obsidian Sniper", "Ice Blue", "Royal Gold"],
     group=groupStyle,
     tooltip="Applies one of three premium color packages to IFVG lines, trade boxes, trade levels, and dashboard colors.",
     display=display.none
)

useThemePackage = input.bool(
     true,
     "🎨 Use Theme Package Colors",
     group=groupStyle,
     tooltip="When enabled, colors are controlled by the selected theme package. Disable it to use custom colors.",
     display=display.none
)

customBullIFVGColor = input.color(
     color.rgb(0, 120, 255),
     "🟦 Custom Bullish IFVG Color",
     group=groupStyle,
     tooltip="Custom bullish IFVG color. Used only when Theme Package Colors is disabled.",
     display=display.none
)

customBearIFVGColor = input.color(
     color.rgb(255, 60, 70),
     "🟥 Custom Bearish IFVG Color",
     group=groupStyle,
     tooltip="Custom bearish IFVG color. Used only when Theme Package Colors is disabled.",
     display=display.none
)

ifvgLabelSizeInput = input.string(
     "Large",
     "🏷️ IFVG Label Size",
     options=["Tiny", "Small", "Normal", "Large", "Huge"],
     group=groupStyle,
     tooltip="Controls IFVG+ and IFVG- label size.",
     display=display.none
)

customEntryColor = input.color(
     color.white,
     "⚪ Custom Entry Line Color",
     group=groupStyle,
     tooltip="Custom ENTRY line color. Used only when Theme Package Colors is disabled.",
     display=display.none
)

customSLColor = input.color(
     color.rgb(220, 50, 50),
     "🛑 Custom SL Color",
     group=groupStyle,
     tooltip="Custom SL line and box color. Used only when Theme Package Colors is disabled.",
     display=display.none
)

customTPColor = input.color(
     color.rgb(0, 190, 110),
     "🎯 Custom TP Color",
     group=groupStyle,
     tooltip="Custom TP line and box color. Used only when Theme Package Colors is disabled.",
     display=display.none
)

customDashboardBg = input.color(
     color.rgb(12, 12, 16),
     "📟 Custom Dashboard Background",
     group=groupStyle,
     tooltip="Custom dashboard background color. Used only when Theme Package Colors is disabled.",
     display=display.none
)

customDashboardText = input.color(
     color.white,
     "📟 Custom Dashboard Text",
     group=groupStyle,
     tooltip="Custom dashboard text color. Used only when Theme Package Colors is disabled.",
     display=display.none
)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 📟 05. DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupDashboard = "📟 05. Dashboard"

showDashboard = input.bool(
     true,
     "📟 Show Dashboard",
     group=groupDashboard,
     tooltip="Shows or hides the IFVG Sniper dashboard.",
     display=display.none
)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// THEME ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_themeBullIFVG() =>
    themePackage == "Ice Blue" ? color.rgb(0, 180, 255) :
     themePackage == "Royal Gold" ? color.rgb(212, 175, 55) :
     color.rgb(0, 120, 255)

f_themeBearIFVG() =>
    themePackage == "Ice Blue" ? color.rgb(255, 80, 120) :
     themePackage == "Royal Gold" ? color.rgb(210, 45, 65) :
     color.rgb(255, 60, 70)

f_themeEntry() =>
    themePackage == "Ice Blue" ? color.rgb(235, 250, 255) :
     themePackage == "Royal Gold" ? color.rgb(255, 245, 210) :
     color.white

f_themeSL() =>
    themePackage == "Ice Blue" ? color.rgb(255, 70, 115) :
     themePackage == "Royal Gold" ? color.rgb(210, 45, 65) :
     color.rgb(220, 50, 50)

f_themeTP() =>
    themePackage == "Ice Blue" ? color.rgb(0, 220, 255) :
     themePackage == "Royal Gold" ? color.rgb(212, 175, 55) :
     color.rgb(0, 190, 110)

f_themeDashboardBg() =>
    themePackage == "Ice Blue" ? color.rgb(8, 20, 32) :
     themePackage == "Royal Gold" ? color.rgb(20, 15, 8) :
     color.rgb(12, 12, 16)

f_themeDashboardText() =>
    themePackage == "Ice Blue" ? color.rgb(230, 248, 255) :
     themePackage == "Royal Gold" ? color.rgb(255, 245, 215) :
     color.white

bullIFVGColor = useThemePackage ? f_themeBullIFVG() : customBullIFVGColor
bearIFVGColor = useThemePackage ? f_themeBearIFVG() : customBearIFVGColor

entryColor = useThemePackage ? f_themeEntry() : customEntryColor
slColor = useThemePackage ? f_themeSL() : customSLColor
tpColor = useThemePackage ? f_themeTP() : customTPColor

dashboardBg = useThemePackage ? f_themeDashboardBg() : customDashboardBg
dashboardText = useThemePackage ? f_themeDashboardText() : customDashboardText


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CORE VALUES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

atrValue = ta.atr(atrLen)
safeAtr = na(atrValue) or atrValue <= 0.0 ? syminfo.mintick : atrValue

tpRR =
     tpRRInput == "1R" ? 1.0 :
     tpRRInput == "2R" ? 2.0 :
     tpRRInput == "3R" ? 3.0 :
     tpRRInput == "4R" ? 4.0 :
     tpRRInput == "5R" ? 5.0 :
     6.0


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FILTER HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_minGapAtr() =>
    filterMode == "Off" ? 0.0 :
     filterMode == "Loose" ? 0.15 :
     filterMode == "Balanced" ? 0.25 :
     filterMode == "Strict" ? 0.40 :
     customMinGapAtr

f_minBodyRatio() =>
    filterMode == "Off" ? 0.0 :
     filterMode == "Loose" ? 0.40 :
     filterMode == "Balanced" ? 0.50 :
     filterMode == "Strict" ? 0.60 :
     customMinBodyRatio

f_minRangeAtr() =>
    filterMode == "Off" ? 0.0 :
     filterMode == "Loose" ? 0.40 :
     filterMode == "Balanced" ? 0.60 :
     filterMode == "Strict" ? 0.85 :
     customMinRangeAtr

f_breakBufferAtr() =>
    filterMode == "Off" ? 0.0 :
     filterMode == "Loose" ? 0.00 :
     filterMode == "Balanced" ? 0.05 :
     filterMode == "Strict" ? 0.10 :
     customBreakAtr

f_qualityPass(float _gapAtr, float _bodyRatio, float _rangeAtr) =>
    filterMode == "Off" or (
         _gapAtr >= f_minGapAtr() and
         _bodyRatio >= f_minBodyRatio() and
         _rangeAtr >= f_minRangeAtr()
    )


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GENERAL HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_priceText(float _price) =>
    na(_price) ? "-" : str.tostring(_price, format.mintick)

f_linePrice(float _top, float _bot, float _confirmClose, int _dir) =>
    float price = na

    if linePriceMode == "Confirmation Close"
        price := _confirmClose
    else if linePriceMode == "Midpoint"
        price := (_top + _bot) / 2.0
    else
        price := _dir == 1 ? _top : _bot

    price

f_ifvgLabelSize() =>
    ifvgLabelSizeInput == "Tiny" ? size.tiny :
     ifvgLabelSizeInput == "Small" ? size.small :
     ifvgLabelSizeInput == "Normal" ? size.normal :
     ifvgLabelSizeInput == "Large" ? size.large :
     size.huge

f_statusText(int _status) =>
    _status == 1 ? "ACTIVE" :
     _status == 2 ? "TP HIT" :
     _status == -1 ? "SL HIT" :
     "WAITING"

f_statusColor(int _status) =>
    _status == -1 ? color.new(slColor, 0) :
     _status == 2 ? color.new(tpColor, 0) :
     _status == 1 ? color.new(color.orange, 15) :
     color.new(color.gray, 35)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HIDDEN FVG MEMORY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var array<float> rawTops = array.new_float()
var array<float> rawBots = array.new_float()
var array<int> rawDirs = array.new_int()
var array<int> rawAges = array.new_int()

var array<float> rawGapAtr = array.new_float()
var array<float> rawBodyRatio = array.new_float()
var array<float> rawRangeAtr = array.new_float()


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VISIBLE IFVG OBJECTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var array<line> ifvgLines = array.new_line()
var array<label> ifvgLabels = array.new_label()

var array<float> ifvgTops = array.new_float()
var array<float> ifvgBots = array.new_float()
var array<int> ifvgDirs = array.new_int()

f_deleteVisibleIFVG(int _idx) =>
    line ln = array.get(ifvgLines, _idx)
    label lb = array.get(ifvgLabels, _idx)

    line.delete(ln)

    if not na(lb)
        label.delete(lb)

    array.remove(ifvgLines, _idx)
    array.remove(ifvgLabels, _idx)
    array.remove(ifvgTops, _idx)
    array.remove(ifvgBots, _idx)
    array.remove(ifvgDirs, _idx)

f_addVisibleIFVG(int _bar, float _top, float _bot, float _confirmClose, int _dir) =>
    color c = _dir == 1 ? bullIFVGColor : bearIFVGColor
    float linePrice = f_linePrice(_top, _bot, _confirmClose, _dir)

    string labelText = _dir == 1 ? "IFVG+" : "IFVG-"

    string tooltip =
         "IFVG Sniper Entry Engine\n" +
         "Direction: " + (_dir == 1 ? "Bullish IFVG+" : "Bearish IFVG-") + "\n" +
         "Filter Mode: " + filterMode + "\n" +
         "Top: " + str.tostring(_top, format.mintick) + "\n" +
         "Bottom: " + str.tostring(_bot, format.mintick) + "\n" +
         "Line Price: " + str.tostring(linePrice, format.mintick)

    line ln = line.new(
         x1=_bar,
         y1=linePrice,
         x2=_bar + ifvgLengthBars,
         y2=linePrice,
         xloc=xloc.bar_index,
         extend=extend.none,
         color=c,
         width=1
    )

    label lb = label.new(
         x=_bar + ifvgLengthBars,
         y=linePrice,
         text=labelText,
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_label_left,
         color=color.new(c, 0),
         textcolor=color.white,
         size=f_ifvgLabelSize(),
         tooltip=tooltip
    )

    array.push(ifvgLines, ln)
    array.push(ifvgLabels, lb)

    array.push(ifvgTops, _top)
    array.push(ifvgBots, _bot)
    array.push(ifvgDirs, _dir)

    while array.size(ifvgLines) > maxVisibleIFVG
        f_deleteVisibleIFVG(0)

    linePrice

f_updateIFVGInvalidation() =>
    if deleteInvalidIFVG and barstate.isconfirmed and array.size(ifvgLines) > 0
        int count = array.size(ifvgLines)

        for j = 0 to count - 1
            int i = count - 1 - j

            if i >= 0 and i < array.size(ifvgLines)
                float top = array.get(ifvgTops, i)
                float bot = array.get(ifvgBots, i)
                int dir = array.get(ifvgDirs, i)

                bool invalidBull = dir == 1 and close < bot
                bool invalidBear = dir == -1 and close > top

                if invalidBull or invalidBear
                    f_deleteVisibleIFVG(i)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ACTIVE TRADE OBJECTS ONLY
// Past TP/SL boxes are not shown.
// Trade objects are deleted after TP or SL.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var array<box> tradeBoxes = array.new_box()
var array<line> tradeLines = array.new_line()
var array<label> tradeLabels = array.new_label()

f_clearActiveTradeObjects() =>
    while array.size(tradeBoxes) > 0
        box bx = array.shift(tradeBoxes)
        box.delete(bx)

    while array.size(tradeLines) > 0
        line ln = array.shift(tradeLines)
        line.delete(ln)

    while array.size(tradeLabels) > 0
        label lb = array.shift(tradeLabels)
        label.delete(lb)

f_drawActiveTradeObjects(int _bar, float _entry, float _sl, float _tp) =>
    f_clearActiveTradeObjects()

    int rightBar = _bar + initialBoxLength

    float tpTop = math.max(_entry, _tp)
    float tpBot = math.min(_entry, _tp)

    float slTop = math.max(_entry, _sl)
    float slBot = math.min(_entry, _sl)

    box tpBox = box.new(
         left=_bar,
         top=tpTop,
         right=rightBar,
         bottom=tpBot,
         xloc=xloc.bar_index,
         bgcolor=color.new(tpColor, 82),
         border_color=color.new(tpColor, 0),
         border_width=1
    )

    box slBox = box.new(
         left=_bar,
         top=slTop,
         right=rightBar,
         bottom=slBot,
         xloc=xloc.bar_index,
         bgcolor=color.new(slColor, 82),
         border_color=color.new(slColor, 0),
         border_width=1
    )

    line entryLine = line.new(
         x1=_bar,
         y1=_entry,
         x2=rightBar,
         y2=_entry,
         xloc=xloc.bar_index,
         color=entryColor,
         width=2
    )

    line slLine = line.new(
         x1=_bar,
         y1=_sl,
         x2=rightBar,
         y2=_sl,
         xloc=xloc.bar_index,
         color=slColor,
         width=2
    )

    line tpLine = line.new(
         x1=_bar,
         y1=_tp,
         x2=rightBar,
         y2=_tp,
         xloc=xloc.bar_index,
         color=tpColor,
         width=2
    )

    label entryLabel = label.new(
         x=rightBar,
         y=_entry,
         text="ENTRY",
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_label_left,
         color=entryColor,
         textcolor=color.black,
         size=size.small
    )

    label slLabel = label.new(
         x=rightBar,
         y=_sl,
         text="SL",
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_label_left,
         color=slColor,
         textcolor=color.white,
         size=size.small
    )

    label tpLabel = label.new(
         x=rightBar,
         y=_tp,
         text="TP " + tpRRInput,
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_label_left,
         color=tpColor,
         textcolor=color.white,
         size=size.small
    )

    array.push(tradeBoxes, tpBox)
    array.push(tradeBoxes, slBox)

    array.push(tradeLines, entryLine)
    array.push(tradeLines, slLine)
    array.push(tradeLines, tpLine)

    array.push(tradeLabels, entryLabel)
    array.push(tradeLabels, slLabel)
    array.push(tradeLabels, tpLabel)

f_updateActiveTradeRight(int _right) =>
    if array.size(tradeBoxes) >= 2 and array.size(tradeLines) >= 3 and array.size(tradeLabels) >= 3
        box tpBox = array.get(tradeBoxes, 0)
        box slBox = array.get(tradeBoxes, 1)

        line entryLine = array.get(tradeLines, 0)
        line slLine = array.get(tradeLines, 1)
        line tpLine = array.get(tradeLines, 2)

        label entryLabel = array.get(tradeLabels, 0)
        label slLabel = array.get(tradeLabels, 1)
        label tpLabel = array.get(tradeLabels, 2)

        box.set_right(tpBox, _right)
        box.set_right(slBox, _right)

        line.set_x2(entryLine, _right)
        line.set_x2(slLine, _right)
        line.set_x2(tpLine, _right)

        label.set_x(entryLabel, _right)
        label.set_x(slLabel, _right)
        label.set_x(tpLabel, _right)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRADE STATE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var int lastSignalDir = 0
var int lastSignalBar = na

var float lastEntry = na
var float lastSL = na
var float lastTP = na

var string lastSignalSide = "-"
var int currentTradeStatus = 0
var bool tradeActive = false

var int totalSignals = 0
var int totalWins = 0
var int totalLosses = 0
var int blockedSignals = 0
var int filteredIFVG = 0

bool newBullEntry = false
bool newBearEntry = false


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CORE IFVG ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bool newBullIFVG = false
bool newBearIFVG = false

float newTop = na
float newBot = na
float newConfirmClose = na
int newDir = 0

if barstate.isconfirmed
    newBullEntry := false
    newBearEntry := false

    // Hidden FVG age update.
    if array.size(rawAges) > 0
        int ageCount = array.size(rawAges)

        for i = 0 to ageCount - 1
            array.set(rawAges, i, array.get(rawAges, i) + 1)

    // Remove expired hidden FVGs.
    if array.size(rawAges) > 0
        int removeCount = array.size(rawAges)

        for j = 0 to removeCount - 1
            int i = removeCount - 1 - j

            if i >= 0 and i < array.size(rawAges)
                if array.get(rawAges, i) > maxFvgAge
                    array.remove(rawTops, i)
                    array.remove(rawBots, i)
                    array.remove(rawDirs, i)
                    array.remove(rawAges, i)
                    array.remove(rawGapAtr, i)
                    array.remove(rawBodyRatio, i)
                    array.remove(rawRangeAtr, i)

    float minGap = minGapTicks * syminfo.mintick

    float candleRange = math.max(high - low, syminfo.mintick)
    float candleBody = math.abs(close - open)
    float bodyRatio = candleBody / candleRange
    float rangeAtrRatio = candleRange / safeAtr

    bool rawBullFVG = not na(high[2]) and low > high[2] and (low - high[2]) >= minGap
    bool rawBearFVG = not na(low[2]) and high < low[2] and (low[2] - high) >= minGap

    if rawBullFVG
        float gapAtr = (low - high[2]) / safeAtr

        array.push(rawTops, low)
        array.push(rawBots, high[2])
        array.push(rawDirs, 1)
        array.push(rawAges, 0)

        array.push(rawGapAtr, gapAtr)
        array.push(rawBodyRatio, bodyRatio)
        array.push(rawRangeAtr, rangeAtrRatio)

    if rawBearFVG
        float gapAtr = (low[2] - high) / safeAtr

        array.push(rawTops, low[2])
        array.push(rawBots, high)
        array.push(rawDirs, -1)
        array.push(rawAges, 0)

        array.push(rawGapAtr, gapAtr)
        array.push(rawBodyRatio, bodyRatio)
        array.push(rawRangeAtr, rangeAtrRatio)

    while array.size(rawTops) > maxHiddenFVG
        array.shift(rawTops)
        array.shift(rawBots)
        array.shift(rawDirs)
        array.shift(rawAges)
        array.shift(rawGapAtr)
        array.shift(rawBodyRatio)
        array.shift(rawRangeAtr)

    // Detect IFVG inversion with filter.
    if array.size(rawTops) > 0
        int invCount = array.size(rawTops)

        for j = 0 to invCount - 1
            int i = invCount - 1 - j

            if i >= 0 and i < array.size(rawTops)
                float top = array.get(rawTops, i)
                float bot = array.get(rawBots, i)
                int dir = array.get(rawDirs, i)

                float gapAtrStored = array.get(rawGapAtr, i)
                float bodyRatioStored = array.get(rawBodyRatio, i)
                float rangeAtrStored = array.get(rawRangeAtr, i)

                float cleanBreakBuffer = safeAtr * f_breakBufferAtr()

                bool bullishInversion = dir == -1 and close > top + cleanBreakBuffer
                bool bearishInversion = dir == 1 and close < bot - cleanBreakBuffer

                if bullishInversion or bearishInversion
                    bool passFilter = f_qualityPass(gapAtrStored, bodyRatioStored, rangeAtrStored)

                    if passFilter
                        newBullIFVG := bullishInversion
                        newBearIFVG := bearishInversion

                        newTop := top
                        newBot := bot
                        newConfirmClose := close
                        newDir := bullishInversion ? 1 : -1
                    else
                        filteredIFVG += 1

                    array.remove(rawTops, i)
                    array.remove(rawBots, i)
                    array.remove(rawDirs, i)
                    array.remove(rawAges, i)
                    array.remove(rawGapAtr, i)
                    array.remove(rawBodyRatio, i)
                    array.remove(rawRangeAtr, i)

                    break

    // Only filtered IFVGs appear.
    if newBullIFVG or newBearIFVG
        float ifvgLinePrice = f_addVisibleIFVG(bar_index, newTop, newBot, newConfirmClose, newDir)

        if not tradeActive
            float entryPrice = entryMode == "Confirmation Close" ? newConfirmClose : ifvgLinePrice
            float risk = atrValue * slAtrMult

            float sl = newDir == 1 ? entryPrice - risk : entryPrice + risk
            float tp = newDir == 1 ? entryPrice + risk * tpRR : entryPrice - risk * tpRR

            f_drawActiveTradeObjects(bar_index, entryPrice, sl, tp)

            lastSignalDir := newDir
            lastSignalBar := bar_index

            lastEntry := entryPrice
            lastSL := sl
            lastTP := tp

            lastSignalSide := newDir == 1 ? "Bullish" : "Bearish"
            currentTradeStatus := 1
            tradeActive := true

            newBullEntry := newDir == 1
            newBearEntry := newDir == -1

            totalSignals += 1
        else
            blockedSignals += 1


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ACTIVE TRADE BOX EXTENSION
// Only active trade box is visible.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if tradeActive and not na(lastSignalBar)
    int liveRight = math.max(bar_index, lastSignalBar + initialBoxLength)

    f_updateActiveTradeRight(liveRight)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// IFVG INVALIDATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_updateIFVGInvalidation()


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRADE STATUS UPDATE
// TP/SL hit deletes active box.
// Past TP/SL boxes are not kept.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if tradeActive and not na(lastEntry) and not na(lastSignalBar) and bar_index > lastSignalBar
    bool hitSL = lastSignalDir == 1 ? low <= lastSL : high >= lastSL
    bool hitTP = lastSignalDir == 1 ? high >= lastTP : low <= lastTP

    // Conservative priority:
    // If TP and SL are touched in the same candle, SL is counted first.
    if hitSL
        currentTradeStatus := -1
        tradeActive := false
        totalLosses += 1

        f_clearActiveTradeObjects()

    else if hitTP
        currentTradeStatus := 2
        tradeActive := false
        totalWins += 1

        f_clearActiveTradeObjects()


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(
     newBullEntry,
     title="IFVG Sniper Bullish Entry",
     message="IFVG Sniper Entry Engine | Bullish IFVG Entry confirmed on {{ticker}} / {{interval}}"
)

alertcondition(
     newBearEntry,
     title="IFVG Sniper Bearish Entry",
     message="IFVG Sniper Entry Engine | Bearish IFVG Entry confirmed on {{ticker}} / {{interval}}"
)

alertcondition(
     newBullIFVG,
     title="IFVG Sniper Bullish IFVG+",
     message="IFVG Sniper Entry Engine | Bullish IFVG+ formed on {{ticker}} / {{interval}}"
)

alertcondition(
     newBearIFVG,
     title="IFVG Sniper Bearish IFVG-",
     message="IFVG Sniper Entry Engine | Bearish IFVG- formed on {{ticker}} / {{interval}}"
)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var table dash = table.new(position.top_right, 2, 12, border_width=1)

if showDashboard and barstate.islast
    float wr = totalWins + totalLosses > 0 ? totalWins * 100.0 / (totalWins + totalLosses) : na

    table.cell(dash, 0, 0, "IFVG SNIPER", bgcolor=dashboardBg, text_color=dashboardText, text_size=size.small)
    table.cell(dash, 1, 0, "ENGINE", bgcolor=dashboardBg, text_color=dashboardText, text_size=size.small)

    table.cell(dash, 0, 1, "Filter", bgcolor=color.new(dashboardBg, 0), text_color=dashboardText, text_size=size.tiny)
    table.cell(dash, 1, 1, filterMode, bgcolor=color.new(dashboardBg, 25), text_color=dashboardText, text_size=size.tiny)

    table.cell(dash, 0, 2, "Label Size", bgcolor=color.new(dashboardBg, 0), text_color=dashboardText, text_size=size.tiny)
    table.cell(dash, 1, 2, ifvgLabelSizeInput, bgcolor=color.new(dashboardBg, 25), text_color=dashboardText, text_size=size.tiny)

    table.cell(dash, 0, 3, "Last Signal", bgcolor=color.new(dashboardBg, 0), text_color=dashboardText, text_size=size.tiny)
    table.cell(
         dash,
         1,
         3,
         lastSignalSide,
         bgcolor=lastSignalDir == 1 ? color.new(bullIFVGColor, 20) : lastSignalDir == -1 ? color.new(bearIFVGColor, 20) : color.new(color.gray, 35),
         text_color=color.white,
         text_size=size.tiny
    )

    table.cell(dash, 0, 4, "Trade Status", bgcolor=color.new(dashboardBg, 0), text_color=dashboardText, text_size=size.tiny)
    table.cell(dash, 1, 4, f_statusText(currentTradeStatus), bgcolor=f_statusColor(currentTradeStatus), text_color=color.white, text_size=size.tiny)

    table.cell(dash, 0, 5, "Selected RR", bgcolor=color.new(dashboardBg, 0), text_color=dashboardText, text_size=size.tiny)
    table.cell(dash, 1, 5, tpRRInput, bgcolor=color.new(dashboardBg, 25), text_color=dashboardText, text_size=size.tiny)

    table.cell(dash, 0, 6, "Entry", bgcolor=color.new(dashboardBg, 0), text_color=dashboardText, text_size=size.tiny)
    table.cell(dash, 1, 6, f_priceText(lastEntry), bgcolor=color.new(dashboardBg, 25), text_color=dashboardText, text_size=size.tiny)

    table.cell(dash, 0, 7, "SL", bgcolor=color.new(dashboardBg, 0), text_color=dashboardText, text_size=size.tiny)
    table.cell(dash, 1, 7, f_priceText(lastSL), bgcolor=color.new(slColor, 70), text_color=color.white, text_size=size.tiny)

    table.cell(dash, 0, 8, "TP", bgcolor=color.new(dashboardBg, 0), text_color=dashboardText, text_size=size.tiny)
    table.cell(dash, 1, 8, f_priceText(lastTP), bgcolor=color.new(tpColor, 65), text_color=color.white, text_size=size.tiny)

    table.cell(dash, 0, 9, "Active Box", bgcolor=color.new(dashboardBg, 0), text_color=dashboardText, text_size=size.tiny)
    table.cell(
         dash,
         1,
         9,
         tradeActive ? "VISIBLE" : "HIDDEN",
         bgcolor=tradeActive ? color.new(tpColor, 65) : color.new(color.gray, 35),
         text_color=color.white,
         text_size=size.tiny
    )

    table.cell(dash, 0, 10, "Filtered IFVG", bgcolor=color.new(dashboardBg, 0), text_color=dashboardText, text_size=size.tiny)
    table.cell(dash, 1, 10, str.tostring(filteredIFVG), bgcolor=color.new(color.gray, 35), text_color=color.white, text_size=size.tiny)

    table.cell(dash, 0, 11, "Trades / W / L", bgcolor=color.new(dashboardBg, 0), text_color=dashboardText, text_size=size.tiny)
    table.cell(
         dash,
         1,
         11,
         str.tostring(totalSignals) + " / " + str.tostring(totalWins) + " / " + str.tostring(totalLosses),
         bgcolor=color.new(dashboardBg, 25),
         text_color=dashboardText,
         text_size=size.tiny
    )
````
