# Manual Wedge Setup [WillyAlgoTrader]

- url: https://www.tradingview.com/script/ezWSw2f8-Manual-Wedge-Setup-WillyAlgoTrader/
- type: indicator
- pine_id: PUB;96a40b4f052b409aa72cf99ab7c60bdc
- version: 2.0

## Description

[b]📐 Manual Wedge Setup [WillyAlgoTrader][/b]

Manual Wedge is an interactive four-candle wedge planner for TradingView.

[b]📌 MANUAL SETUP — FOUR POINTS REQUIRED[/b]

You must manually select FOUR distinct candles on the chart using the Candle 1, Candle 2, Candle 3, and Candle 4 inputs.

The indicator does not automatically search for wedges and does not select the four candles for you.

After the four candles are selected, the script automatically determines whether each selected candle should use its High or Low as a contact point. It then fits the upper and lower boundaries, checks the geometry, classifies the formation, and prepares the trade plan.

To analyze another formation, manually move the four candle markers to four different candles.

[b]🧩 HOW THE INDICATOR WORKS[/b]

The indicator combines four manually selected candles, automatic High/Low assignment, wedge geometry, breakout confirmation, target projection, stop calculation, position planning, break-even management, and an extreme-anchored VWAP.

The selected candles define the formation. Their automatically assigned High and Low prices determine the upper and lower boundaries.

A confirmed close outside the formation creates the modeled entry. The distance between the first two chronological assigned points determines the potential target range.

The same confirmed trade timeline controls:

— Entry.
— Initial stop.
— TP1, TP2, and TP3.
— Break-even activation.
— Final exit.
— Stop-line endpoint.
— Target-line endpoint.
— VWAP endpoint.
— Event alerts.

This keeps the chart drawings and dashboard synchronized.


[b]🔍 MAIN FEATURES[/b]

[b]1️⃣ Four manually selected candles[/b]

The user selects four distinct candles directly on the chart.

The inputs are:

— Candle 1.
— Candle 2.
— Candle 3.
— Candle 4.

The selected candles are sorted chronologically. Point numbers follow chronological order, regardless of the order in which the input fields were selected.

The indicator evaluates possible High/Low assignments and requires two upper contacts and two lower contacts.

[b]2️⃣ Automatic High/Low assignment[/b]

The script determines whether each selected candle contributes its High to the upper boundary or its Low to the lower boundary.

The assignment is selected according to:

— Valid upper and lower geometry.
— Positive formation width.
— Boundary convergence.
— Anchor fitting error.
— Candle excursions outside the fitted boundaries.
— The selected Contact Order setting.

The default Contact Order is Any. This allows all valid High/Low combinations.

Alternating restricts the assignment so that upper and lower contacts alternate chronologically.

[b]3️⃣ Tolerance-based geometry validation[/b]

The selected candle range is calculated as:

Selected Range = Highest Selected High − Lowest Selected Low

The maximum fitting tolerance is:

Tolerance = max(Selected Range × Tolerance % / 100, 0.5 minimum tick)

The default tolerance is 5%.

Higher tolerance accepts looser formations. Lower tolerance requires more accurate contact points.

Tolerance is used for geometric validation. It is not a breakout buffer, stop distance, or probability estimate.

Only the four selected candles are checked against the fitted boundaries. Intermediate candles are not required to remain inside the formation.

[b]4️⃣ Falling and Rising Wedge classification[/b]

When both boundaries slope downward, the formation is classified as a Falling Wedge.

A Falling Wedge receives:

— Bullish expected bias.
— Transparent green fill.
— Stop based on the lowest assigned Low.
— VWAP anchored to the lowest assigned Low.

When both boundaries slope upward, the formation is classified as a Rising Wedge.

A Rising Wedge receives:

— Bearish expected bias.
— Transparent red fill.
— Stop based on the highest assigned High.
— VWAP anchored to the highest assigned High.

The Bullish or Bearish label describes the expected wedge direction. It does not automatically create a BUY or SELL trade.

The actual trade direction comes from the confirmed breakout:

— Close above the upper boundary creates a BUY plan.
— Close below the lower boundary creates a SELL plan.

If same-direction boundaries are disabled, converging triangles may be accepted. Triangles do not have a defined wedge stop or VWAP anchor rule and therefore may not produce a valid trade plan.

[b]5️⃣ Projected apex[/b]

The upper and lower boundaries can be extended with dashed lines until their calculated intersection.

The apex is calculated from the fitted linear boundaries in bar coordinates.

On session-based or irregular charts, the future apex timestamp is an estimate because the script must convert a fractional bar position into chart time.

[b]6️⃣ Optional mirrored upper parallel[/b]

The optional Mirrored Upper Parallel displays a thin dashed orange line.

The line is not permanently tied to point 1.

The script finds the earliest assigned lower contact, measures the distance between that candle’s Low and the upper boundary at the same candle, and reflects this distance through the upper boundary.

This creates a symmetrical channel reference based on the actual selected formation.

[b]🎯 TARGET ZONE AND POTENTIAL[/b]

The reference height is calculated from the first two chronological assigned points:

H = |Point 2 Price − Point 1 Price|

Point prices may be assigned Highs or Lows depending on the automatic contact assignment.

The target projection starts from the broken boundary at the breakout candle.

The far target boundary is:

Far Target = Breakout Boundary + Direction × H

The nearest target boundary is:

TP3 = Breakout Boundary + Direction × 0.90 × H

The transparent yellow target zone covers the range between 90% and 100% of H.

TP3 is the nearest boundary of the yellow zone. It is the final modeled take-profit level and closes the remaining position.

The target height is based specifically on points 1 and 2. It is not the maximum distance between all four points.


[b]📈 ENTRY LOGIC[/b]

All four selected candles must be closed before a trade plan becomes valid.

The script searches for the first confirmed closing-price cross after candle 4 and before the apex.

A BUY setup requires:

— Current close above the upper boundary.
— Previous close at or below the previous upper-boundary value.

A SELL setup requires:

— Current close below the lower boundary.
— Previous close at or above the previous lower-boundary value.

The entry price is the breakout candle’s closing price.

A wick outside the wedge does not create an entry by itself.

The indicator uses the first qualifying breakout. It does not search for a later breakout if the first plan has invalid stop placement or invalid target spacing.


[b]🛡 STOP LOGIC[/b]

The initial stop is based on the formation extreme.

For a Falling Wedge:

Initial Stop = Lowest Assigned Low − Stop Offset

For a Rising Wedge:

Initial Stop = Highest Assigned High − Stop Offset

The default Stop Offset is 2 ticks.

The stop line begins at the opening of the modeled trade, meaning the breakout candle where the entry is confirmed.

The stop line ends on the candle where the modeled trade reaches:

— TP3.
— The initial stop.
— The break-even stop.

The initial stop remains fixed. It does not trail with later candles.

A valid trade plan requires the stop to be on the risk side of the entry.

If the calculated stop is on the wrong side of the entry, the dashboard reports an invalid trade plan and does not activate the trade drawings.


[b]🎯 THREE TAKE-PROFIT LEVELS[/b]

TP1 and TP2 divide the price distance between the entry and TP3.

Default target positions:

— TP1: one third of the entry-to-TP3 distance.
— TP2: two thirds of the entry-to-TP3 distance.
— TP3: the 90% H target boundary.

The target-distance inputs and the position-closing inputs are independent.

Default position allocation:

— TP1 closes 33% of the initial position.
— TP2 closes 33% of the initial position.
— TP3 closes the remaining 34%.

TP1 and TP2 closing percentages must total less than 100%. TP3 always closes the remainder.

A target touch is confirmed only on a closed candle.


[b]⚖️ BREAK-EVEN MANAGEMENT[/b]

Break-Even After TP1 is enabled by default.

After the first confirmed TP1 touch:

— TP1 closes its configured position share.
— The remaining position stop moves to the entry price.
— The break-even stop becomes active from the following candle.

The activation candle itself cannot be stopped at break-even.

The initial stop segment ends when break-even activates. A new stop segment begins at the entry price on the following candle.

The trade finishes only when the remaining position reaches:

— TP3.
— The initial stop.
— The active break-even stop.

TP1 and TP2 are partial exits. They do not fully close the trade.


[b]📊 POSITION AND PROFIT CALCULATIONS[/b]

The indicator uses a linear contract model.

Notional = Margin × Leverage

Quantity = Notional / (Entry × Symbol Point Value)

Theoretical quantities are calculated from the initial position:

Q1 = Initial Quantity × TP1 Closing Share

Q2 = Initial Quantity × TP2 Closing Share

Q3 = Initial Quantity − Q1 − Q2

Profit for each target is calculated as:

Profit = Direction × (Target − Entry) × Closed Quantity × Point Value

The dashboard displays:

— Margin.
— Leverage.
— Position notional.
— Theoretical quantity.
— TP1 closing quantity and profit.
— TP2 closing quantity and profit.
— TP3 closing quantity and profit.
— Total target profit.
— Loss if the full position reaches the initial stop.
— Result after TP1 followed by stop or break-even.
— Result after TP1 and TP2 followed by stop or break-even.
— Modeled final result.
— Plan RR.

The initial price-distance R:R is calculated from the initial stop and TP3:

Risk Distance = Direction × (Entry − Initial Stop)

Reward Distance = Direction × (TP3 − Entry)

R:R = Reward Distance / Risk Distance

Plan RR uses the sum of all partial target profits divided by the initial full-position stop risk.

The calculations exclude:

— Commission.
— Spread.
— Slippage.
— Funding.
— Swaps.
— Liquidation.
— Inverse-contract settlement.
— Account-currency conversion.
— Broker lot-size rounding.

Quantities are theoretical units or contracts.


[b]📉 EXTREME-ANCHORED VWAP[/b]

For a Falling Wedge, the average starts from the lowest assigned Low and uses candle Low as its source.

For a Rising Wedge, the average starts from the highest assigned High and uses candle High as its source.

When valid positive volume exists, the calculation is:

VWAP = Sum(Source Price × Volume) / Sum(Volume)

VWAP monitoring begins after a valid entry and ends at the same modeled exit as the trade.

The final exit candle is included.

VWAP Weighting / Forex options:

— Auto.
— Volume Only.
— Unweighted.

Auto uses volume weighting when the data is usable. If volume is missing or invalid, the entire displayed span switches to an equal-weight average.

Volume Only hides the curve when usable volume is unavailable.

Unweighted always uses:

Average = Sum(Source Price) / Number of Candles

The unweighted fallback is explicitly labeled “Unweighted Average.”


[b]📖 HOW TO USE[/b]

1. Add the indicator to the chart.

2. Open the Main Settings group.

3. Manually select four distinct candles using Candle 1, Candle 2, Candle 3, and Candle 4.

4. Check the numbered H/L labels on the chart.

5. Confirm the formation status in the dashboard.

6. Start with Contact Order = Any and Tolerance = 5%.

7. Configure margin, leverage, stop offset, target percentages, and closing shares.

8. Wait for a confirmed breakout close.

9. Use the entry marker, target levels, stop line, yellow potential zone, VWAP, and dashboard together.

If no wedge is found, check:

— The four candles are distinct.
— The candles are within the loaded history.
— The boundaries can converge.
— Tolerance is not too strict.
— The selected candles are closed.
— Contact Order is not unnecessarily restrictive.

Changing the four selected candles changes the entire formation and trade plan.


[b]📋 READING THE CHART[/b]

— Orange solid line: upper wedge boundary.
— Teal solid line: lower wedge boundary.
— Dashed boundary extensions: projected apex.
— Thin dashed orange line: optional mirrored upper parallel.
— Transparent green fill: Falling Wedge.
— Transparent red fill: Rising Wedge.
— Yellow fill: 90–100% H target zone.
— Green BUY marker: confirmed upward breakout.
— Red SELL marker: confirmed downward breakout.
— Dotted entry line: modeled breakout closing price.
— Solid stop line: initial or active stop.
— Dashed target lines: TP1, TP2, and TP3.
— Checkmark and solid teal target line: confirmed target touch.
— Purple curve: anchored VWAP or unweighted fallback.

The dashboard uses the following expected formation bias:

— Falling Wedge → Bullish.
— Rising Wedge → Bearish.

This expected bias is independent of the actual breakout direction.


[b]📊 DASHBOARD SECTIONS[/b]

[b]Market[/b]

Shows:

— Expected formation bias.
— Confirmed breakout signal.
— Chart timeframe.
— High/Low assignment status.

[b]Formation[/b]

Shows:

— Formation type.
— Fit error.
— Number of valid assignments.
— Selected-candle range.
— Target height.
— Target zone.
— VWAP status.

[b]Trade Levels[/b]

Shows:

— Entry.
— Initial or break-even stop.
— TP1.
— TP2.
— TP3.
— R:R to TP3.
— Current stop distance.

[b]Position Plan[/b]

Shows:

— Margin and leverage.
— Position notional.
— Theoretical quantity.
— Closing quantity and profit for each target.
— Total target profit.
— Stop-loss scenarios.
— Plan RR.
— Modeled active or final result.

All dashboard sections can be hidden independently.


[b]⚙️ KEY SETTINGS[/b]

[b]Main Settings[/b]

— Candle 1: manual chart selection.
— Candle 2: manual chart selection.
— Candle 3: manual chart selection.
— Candle 4: manual chart selection.

[b]Visual Settings[/b]

— Theme: Auto.
— Show Wedge Boundaries: enabled.
— Show Wedge Fill: enabled.
— Extend Boundaries to Apex: enabled.
— Show Mirrored Upper Parallel: disabled.
— Show Anchor Labels: enabled.
— Show Entry Signal Marker: enabled.
— Show Price-Level Labels: enabled.
— Show Target Zone: enabled.
— Show Extreme-Anchored VWAP: enabled.
— Show Watermark: enabled.
— Signal Label Size: Small.
— Price Label Size: Small.

[b]Filters[/b]

— Contact Order: Any.
— Tolerance: 5%.
— Require Same-Direction Boundaries: enabled.

[b]Risk Management[/b]

— Show Stop Line: enabled.
— Stop Offset: 2 ticks.
— Show Entry and Three Targets: enabled.
— TP1 Distance: 33.33% of the entry-to-TP3 path.
— TP2 Distance: 66.67% of the entry-to-TP3 path.
— Margin: 100 quote-currency units.
— Leverage: 5×.
— TP1 Close: 33%.
— TP2 Close: 33%.
— TP3 Close: remaining position.
— Entry Line Style: Dotted.
— SL Line Style: Solid.
— TP Line Style: Dashed.
— Show % Distance on Labels: enabled.
— Break-Even After TP1: enabled.

[b]Dashboard[/b]

— Show Dashboard: enabled.
— Dashboard Position: Top Right.
— Dashboard Font Size: Small.
— Market: enabled.
— Formation: enabled.
— Trade Levels: enabled.
— Position Plan: enabled.

[b]Alerts[/b]

— Enable Event Alerts: enabled.
— Webhook JSON Format: disabled.
— Alert on Entry: enabled.
— Alert on SL / TP / BE Events: enabled.

[b]Colors[/b]

— Upper Boundary: orange.
— Lower Boundary: teal.
— Target Boundary: yellow.
— VWAP: purple.
— BUY Marker: green.
— SELL Marker: red.

[b]Advanced[/b]

— VWAP Weighting / Forex: Auto.
— Volume Only: requires usable volume.
— Unweighted: always uses equal candle weights.


[b]🔔 ALERTS[/b]

Create a TradingView alert using:

Any alert() function call

Supported events:

— BUY.
— SELL.
— TP1_TOUCH.
— TP2_TOUCH.
— BREAK_EVEN.
— TP3_TOUCH.
— SL_TOUCH.
— BE_STOP_OUT.

Multiple events on one confirmed candle are bundled into one alert message.

Readable alerts include:

— Event names.
— Symbol.
— Timeframe.
— Closing price.
— Bar time.
— Entry.
— Effective stop.
— TP1.
— TP2.
— TP3.
— Initial R:R.

Optional JSON alerts include:

— events.
— ticker.
— timeframe.
— time.
— price.
— side.
— entry.
— sl.
— initial_sl.
— tp1.
— tp2.
— tp3.
— rr.

Historical reconstruction does not generate retrospective alerts.

The indicator does not create alerts automatically and does not execute trades.


[b]⚠️ IMPORTANT NOTES[/b]

This is a manual formation and trade-planning indicator. It is not an automatic scanner, broker execution system, or strategy backtest.

The four candles must be selected manually. The indicator only automates High/Low assignment and subsequent calculations.

Selecting historical candles introduces hindsight. Historical formations should not be interpreted as proof that the same setup would have been selected in real time.

Geometry based on an unfinished anchor candle is provisional.

Confirmed trade events require closed candles. Changing the selected candles, settings, symbol, timeframe, or chart data can change the reconstructed result.

The indicator uses linear price geometry and bar coordinates. Future apex timestamps are estimated on session-based or irregular charts.

The supported anchor lookback is 9,999 bars and requires the selected history to be loaded.

Only the selected candles are validated against the fitted boundaries. Intermediate candles are not used for full formation containment.

The first qualifying breakout determines the trade plan.

The OHLC management model cannot know the exact intrabar sequence when several levels are touched inside one candle. New target touches receive optimistic priority over a stop on the same candle.

The break-even stop cannot close the trade on the candle where break-even is activated.

Profit and loss values are theoretical gross estimates. They do not guarantee execution results.

Use Manual Wedge as a structured analysis and planning tool. Always evaluate market conditions, liquidity, execution costs, and personal risk before making a trading decision.

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════
// 1. VERSION, DECLARATION
// ══════════════════════════════════════════════════════════
// Author:  Willy | WillyAlgoTrader
// Version: 1.3.3

indicator("Manual Wedge Setup [WillyAlgoTrader]", shorttitle = "MWedge Setup ", overlay = true, max_lines_count = 20, max_labels_count = 20, max_polylines_count = 1)
max_bars_back(time, 2)

// ══════════════════════════════════════════════════════════
// 2. CONSTANTS
// ══════════════════════════════════════════════════════════
const string INDICATOR_VERSION = "1.3.3"
const int LABEL_OFFSET_BARS = 1
const int N = 4
const int HISTORY = 10000
const int MAX_LOOKBACK = HISTORY - 1
const int MAX_FUTURE_BARS = 500
const float TARGET_NEAR_RATIO = 0.9
const float AMBIGUITY_THRESHOLD = 0.01
const float RR_GOOD = 1.5
const float RR_FAIR = 1.0
const float RISK_HIGH_PCT = 3.0
const float RISK_MID_PCT = 1.0
const string GRP_MAIN = "⚙ Main Settings"
const string GRP_VISUAL = "🎨 Visual Settings"
const string GRP_FILTER = "🔍 Filters"
const string GRP_RISK = "🛡 Risk Management"
const string GRP_DASH = "📊 Dashboard"
const string GRP_ALERT = "🔔 Alerts"
const string GRP_COLORS = "🖌 Colors"
const string GRP_ADV = "🔧 Advanced"

// ══════════════════════════════════════════════════════════
// 3. INPUTS
// ══════════════════════════════════════════════════════════
int t1Input = input.time(0, "Candle 1", confirm = true, group = GRP_MAIN, tooltip = "Manually select all FOUR anchor candles on the chart. The script does not find these candles automatically. Select the first anchor candle. Use four distinct candles within 9999 bars. Anchors are sorted by time.")
int t2Input = input.time(0, "Candle 2", confirm = true, group = GRP_MAIN, tooltip = "Select a second distinct candle. H is the absolute price difference between the earliest upper contact and the earliest lower contact.")
int t3Input = input.time(0, "Candle 3", confirm = true, group = GRP_MAIN, tooltip = "Select a third distinct candle. The indicator assigns its High or Low to a boundary automatically.")
int t4Input = input.time(0, "Candle 4", confirm = true, group = GRP_MAIN, tooltip = "Select a fourth distinct candle. A breakout must close after the last anchor and before the apex.")
string themeInput = input.string("Auto", "Theme", options = ["Auto", "Dark", "Light"], group = GRP_VISUAL, tooltip = "Auto detects the chart background. Select Dark or Light manually for custom chart backgrounds.")
bool showWedgeInput = input.bool(true, "Show Wedge Boundaries", group = GRP_VISUAL, tooltip = "Show the fitted upper and lower boundaries. Disable to focus on trade levels; calculations continue.")
bool showFillInput = input.bool(true, "Show Wedge Fill", group = GRP_VISUAL, tooltip = "Show a translucent green fill for falling wedges and red for rising wedges. Requires Show Wedge Boundaries; transparency adapts to the theme.")
bool showApexInput = input.bool(true, "Extend Boundaries to Apex", group = GRP_VISUAL, tooltip = "Continue both boundaries with the same slope toward their intersection. Requires Show Wedge Boundaries. Projection is capped at 500 future bars by TradingView.")
bool showParallelInput = input.bool(false, "Show Mirrored Upper Parallel", group = GRP_VISUAL, tooltip = "Reflect a parallel through the earliest lower contact across the upper boundary. Optional; disabled by default.")
bool showLabelsInput = input.bool(true, "Show Anchor Labels", group = GRP_VISUAL, tooltip = "Show point numbers and assigned High/Low contacts. Anchor numbers follow chronological order.")
bool showSignalLabelsInput = input.bool(true, "Show Entry Signal Marker", group = GRP_VISUAL, tooltip = "Show BUY below or SELL above the confirmed breakout candle. Independent of level-label visibility.")
bool showTradeLabelsInput = input.bool(true, "Show Price-Level Labels", group = GRP_VISUAL, tooltip = "Show solid-background Entry/SL/TP price labels one bar after the common line endpoint. Confirmed target touches are marked with a checkmark.")
bool showTargetInput = input.bool(true, "Show Target Zone", group = GRP_VISUAL, tooltip = "Show the transparent yellow 90–100% H zone after breakout. TP3 is the near 90% boundary.")
bool showVwapInput = input.bool(true, "Show Extreme-Anchored VWAP", group = GRP_VISUAL, tooltip = "Anchor at the lowest assigned Low of a falling wedge or the highest assigned High of a rising wedge. The average ends at the same confirmed TP3, SL, or BE-stop exit as the trade; monitoring begins after entry.")
bool showWatermarkInput = input.bool(true, "Show Watermark", group = GRP_VISUAL, tooltip = "Show a subtle WillyAlgoTrader watermark at the bottom center. Disable for a cleaner chart.")
string signalSizeInput = input.string("Small", "Signal Label Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = GRP_VISUAL, tooltip = "Size of BUY/SELL markers. Small is recommended; larger sizes improve visibility on high-resolution displays.")
string levelSizeInput = input.string("Small", "Price Label Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = GRP_VISUAL, tooltip = "Size of anchor, apex, entry, SL, TP, and VWAP labels. Small keeps the chart compact.")
string modeInput = input.string("Any", "Contact Order", options = ["Alternating", "Any"], group = GRP_FILTER, tooltip = "Any allows all valid High/Low assignments. Alternating requires upper/lower contacts to alternate. Recommended: Any.")
float tolerancePctInput = input.float(5.0, "Tolerance (% of Selected Candle Range)", minval = 0.0, maxval = 25.0, step = 0.5, group = GRP_FILTER, tooltip = "Boundaries pass exactly through their two contacts; this limits how far any other anchor wick may poke through the opposite boundary, relative to the selected High–Low range. Higher values accept looser formations. Default: 5%.")
bool strictWedgeInput = input.bool(true, "Require Same-Direction Boundaries", group = GRP_FILTER, tooltip = "Enable for rising/falling wedges. Disable to allow converging triangles. Parallel and diverging boundaries remain invalid.")
bool showStopInput = input.bool(true, "Show Stop Line", group = GRP_RISK, tooltip = "Show the fixed selected-anchor stop from entry until the first SL or near-target touch. Falling: below the lowest Low. Rising: above the highest High.")
int stopOffsetTicksInput = input.int(2, "Stop Offset (Ticks)", minval = 1, maxval = 10000, step = 1, group = GRP_RISK, tooltip = "Offset beyond the selected stop anchor in minimum price ticks: below the lowest Low for falling wedges, above the highest High for rising wedges. Larger values move the stop farther from the formation. Default: 2 ticks.")
bool showTradeLevelsInput = input.bool(true, "Show Entry and Three Targets", group = GRP_RISK, tooltip = "Show entry and TP1/TP2/TP3 levels with a common SL/TP3 endpoint. TP3 coincides with the near target-zone boundary.")
float tp1PctInput = input.float(100.0 / 3.0, "TP1 (% of Entry-to-TP3 Distance)", minval = 0.1, maxval = 99.9, step = 0.1, group = GRP_RISK, tooltip = "Position TP1 along the entry-to-TP3 path. Higher percentages move it farther from entry. Must be below TP2. Default: one third.")
float tp2PctInput = input.float(200.0 / 3.0, "TP2 (% of Entry-to-TP3 Distance)", minval = 0.1, maxval = 99.9, step = 0.1, group = GRP_RISK, tooltip = "Position TP2 along the entry-to-TP3 path. Must be above TP1 and below 100%. Default: two thirds.")
float marginAmountInput = input.float(100.0, "Margin (Quote Currency)", minval = 0.01, maxval = 1000000000.0, step = 10.0, group = GRP_RISK, tooltip = "Initial margin in the chart's quote currency. Notional = margin × leverage. Higher margin scales all cash P&L estimates. Default: 100.")
float leverageInput = input.float(5.0, "Leverage", minval = 1.0, maxval = 1000.0, step = 0.5, group = GRP_RISK, tooltip = "Multiplier applied once to position notional. Higher leverage scales estimated profit and loss. No liquidation model. Default: 5×.")
float tp1ClosePctInput = input.float(33.0, "TP1 Close (% of Initial Position)", minval = 0.0, maxval = 100.0, step = 1.0, group = GRP_RISK, tooltip = "Share of the initial position closed at TP1. Higher values realize more profit earlier. TP1 + TP2 must remain below 100%. Default: 33%.")
float tp2ClosePctInput = input.float(33.0, "TP2 Close (% of Initial Position)", minval = 0.0, maxval = 100.0, step = 1.0, group = GRP_RISK, tooltip = "Share of the initial position closed at TP2. TP3 closes the remainder: 100% minus TP1 and TP2 shares. Default: 33%, leaving 34% for TP3.")
string entryLineStyleInput = input.string("Dotted", "Entry Line Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_RISK, tooltip = "Entry is a reference level. Dotted is recommended to keep it visually subtle.")
string slLineStyleInput = input.string("Solid", "SL Line Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_RISK, tooltip = "Style of the stop line. Solid with width 2 emphasizes the risk boundary.")
string tpLineStyleInput = input.string("Dashed", "TP Line Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_RISK, tooltip = "Style for TP1/TP2/TP3. Confirmed touches turn the trade line solid teal and add a checkmark; the yellow target zone remains visible.")
bool showPctOnLabelsInput = input.bool(true, "Show % Distance on Labels", group = GRP_RISK, tooltip = "Append signed price change from entry to SL/TP labels, matching the Reactive Trail System layout. Disable for price-only labels.")
bool moveToBEInput = input.bool(true, "Break-Even After TP1", group = GRP_RISK, tooltip = "After the first confirmed TP1 touch, move the remaining position's stop to entry. The BE stop is active from the next candle. TP1/TP2 only close their configured fractions; only TP3, SL, or BE-stop finish the trade. New TP touches have optimistic priority over SL on the same candle.")
bool showDashInput = input.bool(true, "Show Dashboard", group = GRP_DASH, tooltip = "Show the sectioned information panel. Disable to use chart drawings only.")
string dashPositionInput = input.string("Top Right", "Dashboard Position", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group = GRP_DASH, tooltip = "Choose the corner for the dashboard. Top Right is recommended; use another corner if it covers candles.")
string dashSizeInput = input.string("Small", "Dashboard Font Size", options = ["Small", "Normal", "Large", "Huge"], group = GRP_DASH, tooltip = "Size of all data rows. Small is the minimum readable size; choose Normal, Large, or Huge for larger displays.")
bool dashMarketInput = input.bool(true, "    Market", group = GRP_DASH, tooltip = "Show expected wedge bias (falling: Bullish; rising: Bearish), confirmed breakout state, chart timeframe, and assignment confidence.")
bool dashGeometryInput = input.bool(true, "    Formation", group = GRP_DASH, tooltip = "Show geometry diagnostics, target zone, and VWAP status. Assignment confidence is not a win probability.")
bool dashTradeInput = input.bool(true, "    Trade Levels", group = GRP_DASH, tooltip = "Show entry, fixed SL, three TP levels, SL distance %, and RR to TP3. Before entry the section collapses to a waiting row.")
bool dashMathInput = input.bool(true, "    Position Plan", group = GRP_DASH, tooltip = "Show margin, leverage, theoretical size, partial-exit P&L, and SL scenarios. These are estimates, not execution statistics.")
bool showAlertsInput = input.bool(true, "Enable Event Alerts", group = GRP_ALERT, tooltip = "Allow confirmed BUY/SELL and level-event alerts. Create a TradingView alert using Any alert() function call. No alerts are created automatically.")
bool webhookInput = input.bool(false, "Webhook JSON Format", group = GRP_ALERT, tooltip = "Format event messages as JSON for integrations. Default: readable text. All events on a candle are bundled into one message.")
bool alertEntryInput = input.bool(true, "Alert on Entry", group = GRP_ALERT, tooltip = "Notify at the confirmed breakout close with entry, SL, TP1–3, and RR. Historical drawings never produce alerts.")
bool alertExitInput = input.bool(true, "Alert on SL / TP / BE Events", group = GRP_ALERT, tooltip = "Notify on confirmed TP touches, BE activation, and TP3/SL/BE-stop exits. The OHLC management model gives new TP touches priority over SL on the same candle.")
color upperColorInput = input.color(#F59E0B, "Upper Boundary", group = GRP_COLORS, tooltip = "Color of the upper boundary and mirrored parallel. Orange is recommended to distinguish it from the lower boundary.")
color lowerColorInput = input.color(#00ACC1, "Lower Boundary", group = GRP_COLORS, tooltip = "Color of the lower boundary. Teal is recommended for contrast with the upper boundary.")
color targetColorInput = input.color(#FBC02D, "Target Boundary", group = GRP_COLORS, tooltip = "Color of the 90–100% H zone boundaries. The translucent zone fill remains yellow.")
color vwapColorInput = input.color(#AB47BC, "VWAP", group = GRP_COLORS, tooltip = "Color of the anchored volume-weighted or unweighted average. Purple distinguishes it from trade levels.")
color bullColorInput = input.color(#00E676, "BUY Marker", inline = "signal", group = GRP_COLORS, tooltip = "Background color of BUY markers. Text stays dark for contrast on the default bright-green background.")
color bearColorInput = input.color(#FF5252, "SELL Marker", inline = "signal", group = GRP_COLORS, tooltip = "Background color of SELL markers. Text stays white on the default red background.")
string vwapVolumeModeInput = input.string("Auto", "VWAP Weighting / Forex", options = ["Auto", "Volume Only", "Unweighted"], group = GRP_ADV, tooltip = "Auto falls back to an unweighted average if volumes are missing. Volume Only hides unavailable VWAP; Unweighted always uses equal candle weights.")

if barstate.isfirst
    if tp1PctInput >= tp2PctInput
        runtime.error("TP1 distance percentage must be less than TP2. Adjust Risk Management settings.")
    if tp1ClosePctInput + tp2ClosePctInput >= 100.0
        runtime.error("TP1 + TP2 closing shares must total less than 100%; TP3 closes the remainder.")

// ══════════════════════════════════════════════════════════
// 4. THEME DETECTION & COLORS
// ══════════════════════════════════════════════════════════
// Perceived luminance, so dark blue or dark green backgrounds are detected as dark.
float bgLuma = 0.299 * color.r(chart.bg_color) + 0.587 * color.g(chart.bg_color) + 0.114 * color.b(chart.bg_color)
bool isDark = themeInput == "Dark" or (themeInput == "Auto" and bgLuma < 128)
color TEXT_COLOR = isDark ? #E0E0E0 : #1A1A1A
color TEXT_MUTED = isDark ? #9E9E9E : #757575
color BULL_TEXT = isDark ? #00E676 : #00A152
color BEAR_TEXT = isDark ? #FF5252 : #D32F2F
color NEUTRAL_TEXT = isDark ? #FFEB3B : #F57F17
color TABLE_BG = color.new(isDark ? #131722 : #FFFFFF, 5)
color TABLE_BORDER = isDark ? #2A2E39 : #D0D0D0
color TABLE_ROW_ALT = isDark ? #1C2030 : #F0F4F8
color HEADER_BG = isDark ? #0D47A1 : #1565C0
color HEADER_BG_BULL = #0F6E56
color HEADER_BG_BEAR = #A32D2D
color HEADER_TEXT = #FFFFFF
color LINE_SUBTLE = isDark ? #9E9E9E : #616161
color SL_COLOR = isDark ? #E57373 : #B71C1C
color TP1_COLOR = isDark ? color.new(#66BB6A, 30) : color.new(#388E3C, 30)
color TP2_COLOR = isDark ? color.new(#66BB6A, 40) : color.new(#388E3C, 40)
color TP3_COLOR = isDark ? #66BB6A : #388E3C
color ENTRY_COLOR = isDark ? #5C8AAE : #34495E
color TP_LABEL_COLOR = isDark ? #66BB6A : #388E3C
color TP_HIT_COLOR = isDark ? #4DB6AC : #00695C
color BE_COLOR = isDark ? #FFA726 : #E65100
color LABEL_TEXT = isDark ? #1A1A1A : #FFFFFF
color BULL_LABEL_TEXT = #004D25
color BEAR_LABEL_TEXT = #FFFFFF
color WM_COLOR = color.new(isDark ? #FFFFFF : #000000, 80)
int FILL_TRANSP = isDark ? 88 : 82
string dashPosition = dashPositionInput == "Top Left" ? position.top_left : dashPositionInput == "Bottom Left" ? position.bottom_left : dashPositionInput == "Bottom Right" ? position.bottom_right : position.top_right
string signalSize = signalSizeInput == "Huge" ? size.huge : signalSizeInput == "Tiny" ? size.tiny : signalSizeInput == "Large" ? size.large : signalSizeInput == "Normal" ? size.normal : size.small
string levelSize = levelSizeInput == "Huge" ? size.huge : levelSizeInput == "Tiny" ? size.tiny : levelSizeInput == "Large" ? size.large : levelSizeInput == "Normal" ? size.normal : size.small
string dashSize = dashSizeInput == "Huge" ? size.huge : dashSizeInput == "Large" ? size.large : dashSizeInput == "Normal" ? size.normal : size.small
string dashSizeSub = dashSizeInput == "Huge" ? size.large : dashSizeInput == "Large" ? size.normal : dashSizeInput == "Normal" ? size.small : size.tiny

// ══════════════════════════════════════════════════════════
// 5. STATE & BOUNDED HISTORY
// ══════════════════════════════════════════════════════════
var array<int> targets = array.from(t1Input, t2Input, t3Input, t4Input)
var array<int> bars = array.new_int(N, na)
var array<float> highs = array.new_float(N, na)
var array<float> lows = array.new_float(N, na)
var array<bool> closed = array.new_bool(N, false)
var array<line> drawnLines = array.new<line>()
var array<label> drawnLabels = array.new<label>()
var linefill shading = na
var linefill targetShading = na
var polyline vwapCurve = na
var table panel = na
var table watermark = table.new(position.bottom_center, 1, 1, border_width = 0)
// Bounded history supports a selected formation up to 9999 bars back.
var array<int> historyTime = array.new_int(HISTORY, na)
var array<float> historyClose = array.new_float(HISTORY, na)
var array<float> historyHigh = array.new_float(HISTORY, na)
var array<float> historyLow = array.new_float(HISTORY, na)
var array<float> historyVolume = array.new_float(HISTORY, na)
array.set(historyTime, bar_index % HISTORY, time)
array.set(historyClose, bar_index % HISTORY, close)
array.set(historyHigh, bar_index % HISTORY, high)
array.set(historyLow, bar_index % HISTORY, low)
array.set(historyVolume, bar_index % HISTORY, volume)
// Evaluate the one-bar reference on every bar, not just inside last-bar drawing.
int barDuration = math.max(1, nz(time_close - time, nz(time - time[1], 60000)))

// ══════════════════════════════════════════════════════════
// 6. FUNCTIONS
// ══════════════════════════════════════════════════════════
// Open time of a bar. Historical bars use actual times; future bars are an
// estimate on session-based/irregular charts.
barTime(int bar) =>
    bar >= bar_index ? time + (bar - bar_index) * barDuration : array.get(historyTime, bar % HISTORY)

// Exact bar open, or a timestamp inside a time-based candle. Never snap gaps.
for i = 0 to N - 1
    int target = array.get(targets, i)
    bool selected = target > 0 and (time == target or (not na(time_close) and time <= target and target < time_close))
    if selected
        array.set(bars, i, bar_index)
        array.set(highs, i, high)
        array.set(lows, i, low)
        array.set(closed, i, barstate.isconfirmed)

isUpper(int mask, int i) =>
    int(math.floor(mask / math.pow(2, i))) % 2 == 1

// Linear-contract estimates. Fractions always refer to the INITIAL position.
tradeMath(float margin, float lev, float entry, float pv, int dir, float stop, float tOne, float tTwo, float tThree, float shareOne, float shareTwo) =>
    float qty = margin * lev / (entry * pv)
    float qOne = qty * shareOne / 100.0
    float qTwo = qty * shareTwo / 100.0
    float qThree = qty - qOne - qTwo
    float pOne = dir * (tOne - entry) * qOne * pv
    float pTwo = dir * (tTwo - entry) * qTwo * pv
    float pThree = dir * (tThree - entry) * qThree * pv
    float stopUnit = dir * (stop - entry) * pv
    float stopBefore = stopUnit * qty
    float stopAfterOne = pOne + stopUnit * (qty - qOne)
    float stopAfterTwo = pOne + pTwo + stopUnit * qThree
    float riskDistance = dir * (entry - stop)
    float rewardDistance = dir * (tThree - entry)
    [qty, qOne, qTwo, qThree, pOne, pTwo, pThree, stopBefore, stopAfterOne, stopAfterTwo, riskDistance, rewardDistance]

money(float value) =>
    na(value) ? "—" : (value > 0 ? "+" : "") + str.tostring(value, "0.00") + " " + syminfo.currency

levelLabel(string title, float price, float entry) =>
    float changePct = not na(entry) and entry > 0 ? (price - entry) / entry * 100.0 : na
    title + " " + str.tostring(price, format.mintick) + (not showPctOnLabelsInput or na(changePct) ? "" : " (" + (changePct >= 0 ? "+" : "") + str.tostring(changePct, "#.##") + "%)")

// Called only for confirmed bars strictly AFTER entry, with valid ordered targets.
// Capture the effective stop at bar start; a new BE stop cannot fire on this bar.
tradeStep(int dir, float entry, float stop, float tp1, float tp2, float tp3, bool useBE, bool wasBE, bool wasTP1, bool wasTP2, bool wasTP3, float h, float l) =>
    float effectiveStop = wasBE ? entry : stop
    bool rawTP1 = dir == 1 ? h >= tp1 : l <= tp1
    bool rawTP2 = dir == 1 ? h >= tp2 : l <= tp2
    bool rawTP3 = dir == 1 ? h >= tp3 : l <= tp3
    bool rawSL = dir == 1 ? l <= effectiveStop : h >= effectiveStop
    bool firstTP1 = rawTP1 and not wasTP1
    bool firstTP2 = rawTP2 and not wasTP2
    bool nextTP1 = wasTP1 or rawTP1
    bool nextTP2 = wasTP2 or rawTP2
    bool nextTP3 = wasTP3 or rawTP3
    bool moveBE = useBE and firstTP1 and not wasBE and not rawTP3
    bool nextBE = wasBE or moveBE
    bool closeSL = rawSL and not firstTP1 and not firstTP2
    int stopExitKind = wasBE ? 3 : 2
    int exitKind = rawTP3 ? 1 : closeSL ? stopExitKind : 0
    [nextBE, nextTP1, nextTP2, nextTP3, firstTP1, firstTP2, moveBE, exitKind, effectiveStop]

lineStyle(string value) =>
    value == "Dashed" ? line.style_dashed : value == "Dotted" ? line.style_dotted : line.style_solid

jsonNumber(float value) =>
    na(value) ? "null" : str.tostring(value, "0.########")

jsonEscape(string value) =>
    str.replace_all(str.replace_all(value, "\\", "\\\\"), "\"", "\\\"")

panelRow(array<string> keys, array<string> values, array<color> colors, array<string> hints, string key, string value, color textColor, string hint) =>
    array.push(keys, key)
    array.push(values, value)
    array.push(colors, textColor)
    array.push(hints, hint)

// Fit in bar coordinates (not elapsed wall-clock time), relative to the first bar.
fit(array<int> xs, array<float> hs, array<float> ls, int mask, bool upper) =>
    float sx = 0.0
    float sy = 0.0
    float sxx = 0.0
    float sxy = 0.0
    int count = 0
    int origin = array.get(xs, 0)
    for i = 0 to N - 1
        if isUpper(mask, i) == upper
            float x = array.get(xs, i) - origin
            float y = upper ? array.get(hs, i) : array.get(ls, i)
            sx += x
            sy += y
            sxx += x * x
            sxy += x * y
            count += 1
    float denominator = count * sxx - sx * sx
    float slope = count >= 2 and denominator > 0 ? (count * sxy - sx * sy) / denominator : na
    float intercept = not na(slope) ? (sy - slope * sx) / count : na
    [slope, intercept]

// ══════════════════════════════════════════════════════════
// 7. FORMATION, SIGNALS, RISK PLAN & DRAWINGS
// ══════════════════════════════════════════════════════════
// Rebuild only on the last bar; delete every previous object first.
if barstate.islast
    if not na(vwapCurve)
        polyline.delete(vwapCurve)
        vwapCurve := na
    if not na(targetShading)
        linefill.delete(targetShading)
        targetShading := na
    if not na(shading)
        linefill.delete(shading)
        shading := na
    while array.size(drawnLines) > 0
        line.delete(array.pop(drawnLines))
    while array.size(drawnLabels) > 0
        label.delete(array.pop(drawnLabels))

    string status = "Select " + str.tostring(N) + " distinct candles"
    string detail = "Drag each time marker to a different candle"
    string note = "Linear scale · selected candles only"
    string targetText = "Waiting for formation"
    string vwapText = showVwapInput ? "Waiting for formation" : "Disabled"
    string marginText = "Margin: " + str.tostring(marginAmountInput, "#.##") + " " + syminfo.currency
    string leverageText = "Leverage: " + str.tostring(leverageInput, "#.##") + "×"
    string notionalText = "Notional: —"
    string quantityText = "Quantity: —"
    string tp1CloseText = "TP1 Close: —"
    string tp1ProfitText = "TP1 Profit: —"
    string tp2CloseText = "TP2 Close: —"
    string tp2ProfitText = "TP2 Profit: —"
    string stopLossText = "—"
    string netStopText = "—"
    string stopAfterOneText = "—"
    string tp3CloseText = "TP3 Close: —"
    string tp3ProfitText = "TP3 Profit (90% H): —"
    string totalProfitText = "—"
    string mathNote = "Linear-contract plan · excludes fees/funding\nTheoretical quantity; not rounded to broker lots"
    string signalText = "Wait"
    string confidenceText = "Not evaluated"
    string riskPercentText = "—"
    bool hasEntry = false
    int formationBias = 0
    int displayDirection = 0
    bool displayTp1Reached = false
    bool displayTp2Reached = false
    bool displayTp3Reached = false
    string dashEntryText = "—"
    string dashSLText = "—"
    string dashTP1Text = "—"
    string dashTP2Text = "—"
    string dashTP3Text = "—"
    string modeledResultText = "—"
    bool displayBE = false
    string dashRRText = "—"
    color dashRRColor = TEXT_MUTED
    color dashRiskColor = TEXT_MUTED
    array<string> pendingEvents = array.new_string()
    string pendingAlertDetails = ""
    string pendingAlertFields = ""
    color statusColor = NEUTRAL_TEXT
    bool ready = true
    bool allClosed = true
    for i = 0 to N - 1
        ready := ready and not na(array.get(bars, i))
        allClosed := allClosed and array.get(closed, i)

    if ready
        array<int> order = array.sort_indices(bars, order.ascending)
        array<int> xs = array.new_int()
        array<float> hs = array.new_float()
        array<float> ls = array.new_float()
        bool unique = true
        for i = 0 to N - 1
            int j = array.get(order, i)
            array.push(xs, array.get(bars, j))
            array.push(hs, array.get(highs, j))
            array.push(ls, array.get(lows, j))
            if i > 0
                unique := unique and array.get(xs, i) != array.get(xs, i - 1)
        int first = array.get(xs, 0)
        int last = array.get(xs, N - 1)
        if not unique
            status := "Duplicate candle selection"
            detail := "Each anchor must belong to a different candle"
        else if first < bar_index - MAX_LOOKBACK
            status := "Selection is too far back"
            detail := "The first candle must be within the last " + str.tostring(MAX_LOOKBACK) + " bars"
        else
            float span = last - first
            float scale = math.max(array.max(hs) - array.min(ls), syminfo.mintick)
            float tolerance = math.max(scale * tolerancePctInput / 100.0, syminfo.mintick * 0.5)
            float best = na
            float runnerUp = na
            int bestMask = na
            float bestU = na
            float bestL = na
            float bestUI = na
            float bestLI = na
            float bestOutside = na
            int candidates = 0

            // 16 masks; only the 6 with two contacts per side survive fit().
            // Each boundary then passes exactly through its two contacts, so the
            // only free quantity is how far the other wicks protrude through the
            // opposite boundary.
            for mask = 0 to int(math.pow(2, N)) - 1
                bool alternating = true
                for i = 1 to N - 1
                    alternating := alternating and isUpper(mask, i) != isUpper(mask, i - 1)
                if modeInput == "Any" or alternating
                    [u, ui] = fit(xs, hs, ls, mask, true)
                    [l, li] = fit(xs, hs, ls, mask, false)
                    float startWidth = ui - li
                    float endWidth = startWidth + (u - l) * span
                    bool geometry = not na(u) and not na(l) and startWidth > 0 and endWidth > 0 and (l - u) * span > syminfo.mintick * 0.5
                    geometry := geometry and (not strictWedgeInput or (u > 0 and l > 0) or (u < 0 and l < 0))
                    if geometry
                        float outside = 0.0
                        for i = 0 to N - 1
                            float x = array.get(xs, i) - first
                            float top = ui + u * x
                            float bottom = li + l * x
                            outside := math.max(outside, math.max(array.get(hs, i) - top, bottom - array.get(ls, i)))
                        if outside <= tolerance
                            float score = outside / scale
                            candidates += 1
                            if na(best) or score < best
                                runnerUp := best
                                best := score
                                bestMask := mask
                                bestU := u
                                bestL := l
                                bestUI := ui
                                bestLI := li
                                bestOutside := outside
                            else if na(runnerUp) or score < runnerUp
                                runnerUp := score

            if na(bestMask)
                status := "No valid wedge found"
                detail := "Check candles, contact order, and tolerance"
            else
                float apexX = (bestUI - bestLI) / (bestL - bestU)
                float apexPrice = bestUI + bestU * apexX
                float lastUpper = bestUI + bestU * span
                float lastLower = bestLI + bestL * span
                // Use chart bar coordinates for BOTH solid and dashed segments.
                // A time-coordinate projection can bend across session gaps.
                int apexEndBar = math.min(int(math.ceil(first + apexX)), bar_index + MAX_FUTURE_BARS)
                float apexEndX = apexEndBar - first
                float projectedUpper = bestUI + bestU * apexEndX
                float projectedLower = bestLI + bestL * apexEndX
                bool drawApex = showWedgeInput and showApexInput
                if showWedgeInput
                    line topLine = line.new(first, bestUI, last, lastUpper, xloc = xloc.bar_index, color = upperColorInput, width = 2)
                    line bottomLine = line.new(first, bestLI, last, lastLower, xloc = xloc.bar_index, color = lowerColorInput, width = 2)
                    array.push(drawnLines, topLine)
                    array.push(drawnLines, bottomLine)
                    if showFillInput
                        shading := linefill.new(topLine, bottomLine, color.new(bestU < 0 and bestL < 0 ? bullColorInput : bestU > 0 and bestL > 0 ? bearColorInput : ENTRY_COLOR, FILL_TRANSP))
                if drawApex
                    array.push(drawnLines, line.new(last, lastUpper, apexEndBar, projectedUpper, xloc = xloc.bar_index, color = upperColorInput, style = line.style_dashed))
                    array.push(drawnLines, line.new(last, lastLower, apexEndBar, projectedLower, xloc = xloc.bar_index, color = lowerColorInput, style = line.style_dashed))
                    if first + apexX <= bar_index + MAX_FUTURE_BARS
                        array.push(drawnLabels, label.new(apexEndBar, apexPrice, "Apex", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(LINE_SUBTLE, 85), textcolor = TEXT_COLOR, size = levelSize))

                // Target distance H: earliest upper contact vs earliest lower
                // contact, using the same assigned High/Low prices as the labels.
                // In "Any" mode anchors 1 and 2 may share a side, so the pair is
                // chosen by side, not by point number. Every valid candidate has
                // exactly two contacts per side, so both prices are always found.
                float firstUpperPrice = na
                float firstLowerPrice = na
                float parallelOffset = na
                for i = 0 to N - 1
                    if isUpper(bestMask, i)
                        if na(firstUpperPrice)
                            firstUpperPrice := array.get(hs, i)
                    else if na(firstLowerPrice)
                        firstLowerPrice := array.get(ls, i)
                        // Mirrored parallel: measure the upper boundary at this
                        // contact's bar and reflect its Low across that boundary.
                        float channelX = array.get(xs, i) - first
                        parallelOffset := bestUI + bestU * channelX - firstLowerPrice
                float height = math.abs(firstUpperPrice - firstLowerPrice)
                if showParallelInput
                    array.push(drawnLines, line.new(first, bestUI + parallelOffset, last, lastUpper + parallelOffset, xloc = xloc.bar_index, color = upperColorInput, style = line.style_dashed, width = 1))
                    if drawApex
                        array.push(drawnLines, line.new(last, lastUpper + parallelOffset, apexEndBar, projectedUpper + parallelOffset, xloc = xloc.bar_index, color = upperColorInput, style = line.style_dashed, width = 1))
                int breakoutBar = na
                int direction = 0
                float breakoutLevel = na
                float entryPrice = na
                float targetPrice = na
                float targetNear = na
                int confirmedLast = barstate.isconfirmed ? bar_index : bar_index - 1
                // The first close outside a boundary AFTER point 4 and BEFORE
                // the apex fixes direction and target. No intrabar confirmation.
                if allClosed and confirmedLast > last
                    for b = last + 1 to confirmedLast
                        float x = b - first
                        if x >= apexX
                            break
                        float c = array.get(historyClose, b % HISTORY)
                        float uNow = bestUI + bestU * x
                        float lNow = bestLI + bestL * x
                        bool breakUp = c > uNow
                        bool breakDown = c < lNow
                        if breakUp or breakDown
                            breakoutBar := b
                            direction := breakUp ? 1 : -1
                            breakoutLevel := breakUp ? uNow : lNow
                            entryPrice := c
                            targetPrice := math.round_to_mintick(breakoutLevel + direction * height)
                            targetNear := math.round_to_mintick(breakoutLevel + direction * height * TARGET_NEAR_RATIO)
                            break
                // Classify the formation by BOTH boundary slopes, independently
                // of the breakout direction used for targets.
                bool risingWedge = bestU > 0 and bestL > 0
                bool fallingWedge = bestU < 0 and bestL < 0
                string shape = risingWedge ? "Rising Wedge" : fallingWedge ? "Falling Wedge" : "Converging Triangle"
                formationBias := fallingWedge ? 1 : risingWedge ? -1 : 0
                // Stop follows formation direction, using only assigned anchors:
                // falling -> below the lowest Low; rising -> above the highest High.
                // The VWAP is anchored at the same extreme bar, without the offset.
                float stopAnchor = na
                int stopAnchorBar = na
                for i = 0 to N - 1
                    bool upper = isUpper(bestMask, i)
                    if (fallingWedge and not upper) or (risingWedge and upper)
                        float candidate = upper ? array.get(hs, i) : array.get(ls, i)
                        bool replaceAnchor = na(stopAnchor) or (fallingWedge ? candidate < stopAnchor : candidate > stopAnchor)
                        if replaceAnchor
                            stopAnchor := candidate
                            stopAnchorBar := array.get(xs, i)
                float stopPrice = na
                if not na(stopAnchor)
                    float stopOffset = stopOffsetTicksInput * syminfo.mintick
                    stopPrice := math.round_to_mintick(fallingWedge ? stopAnchor - stopOffset : stopAnchor + stopOffset)
                float remainingDistance = targetNear - entryPrice
                float tp1Price = math.round_to_mintick(entryPrice + remainingDistance * tp1PctInput / 100.0)
                float tp2Price = math.round_to_mintick(entryPrice + remainingDistance * tp2PctInput / 100.0)
                bool orderedTargets = direction * (tp1Price - entryPrice) > 0 and direction * (tp2Price - tp1Price) > 0 and direction * (targetNear - tp2Price) > 0
                bool validTradePlan = not na(breakoutBar) and orderedTargets and not na(stopPrice) and direction * (entryPrice - stopPrice) > 0
                // Only confirmed TP3, initial SL, or an already-active BE stop can finish a trade.
                int tradeEndBar = bar_index
                int tradeExitKind = 0
                float tradeExitPrice = na
                string tradeFinishReason = ""
                bool beActive = false
                int beActivationBar = na
                bool tp1Reached = false
                bool tp2Reached = false
                bool tp3Reached = false
                int firstTP1Bar = na
                int firstTP2Bar = na
                if validTradePlan and confirmedLast > breakoutBar
                    for b = breakoutBar + 1 to confirmedLast
                        float h = array.get(historyHigh, b % HISTORY)
                        float l = array.get(historyLow, b % HISTORY)
                        [nextBE, nextTP1, nextTP2, nextTP3, firstTP1, firstTP2, moveBE, exitKind, effectiveStop] = tradeStep(direction, entryPrice, stopPrice, tp1Price, tp2Price, targetNear, moveToBEInput, beActive, tp1Reached, tp2Reached, tp3Reached, h, l)
                        beActive := nextBE
                        tp1Reached := nextTP1
                        tp2Reached := nextTP2
                        tp3Reached := nextTP3
                        if firstTP1
                            firstTP1Bar := b
                        if firstTP2
                            firstTP2Bar := b
                        if moveBE
                            beActivationBar := b
                        if exitKind != 0
                            tradeEndBar := b
                            tradeExitKind := exitKind
                            tradeExitPrice := exitKind == 1 ? targetNear : effectiveStop
                            tradeFinishReason := exitKind == 1 ? "Target reached" : exitKind == 3 ? "BE stop reached" : "SL reached"
                            break
                displayTp1Reached := tp1Reached
                displayTp2Reached := tp2Reached
                displayTp3Reached := tp3Reached
                displayBE := beActive
                int tradeEndTime = not na(breakoutBar) ? array.get(historyTime, tradeEndBar % HISTORY) : na
                int tradeLabelTime = not na(breakoutBar) ? barTime(tradeEndBar + LABEL_OFFSET_BARS) : na
                targetText := "Height H = " + str.tostring(height, format.mintick) + " · waiting for breakout close"
                if not allClosed
                    targetText := "Wait for all four anchors to close"
                else if na(breakoutBar) and confirmedLast - first >= apexX
                    targetText := "Apex passed without confirmed breakout · H = " + str.tostring(height, format.mintick)
                else if not na(breakoutBar)
                    hasEntry := validTradePlan
                    displayDirection := direction
                    signalText := validTradePlan ? (direction == 1 ? "Buy" : "Sell") + (tradeFinishReason == "" ? " · active" : " · " + tradeFinishReason) : "Breakout · invalid SL or target plan"
                    string targetRange = str.tostring(math.min(targetNear, targetPrice), format.mintick) + " — " + str.tostring(math.max(targetNear, targetPrice), format.mintick)
                    targetText := (direction == 1 ? "↑ " : "↓ ") + targetRange + " · 90–100% H" + (tradeFinishReason == "" ? " · active" : " · " + tradeFinishReason)
                    // Entry is the confirming close, never a retroactive fill at
                    // the boundary. Intermediate targets divide the remaining
                    // price distance to TP3, the near 90% H boundary.
                    int levelsStartTime = array.get(historyTime, breakoutBar % HISTORY)
                    if showTradeLevelsInput and validTradePlan
                        array.push(drawnLines, line.new(levelsStartTime, entryPrice, tradeEndTime, entryPrice, xloc = xloc.bar_time, color = ENTRY_COLOR, style = lineStyle(entryLineStyleInput), width = 1))
                    if showSignalLabelsInput and validTradePlan
                        array.push(drawnLabels, label.new(levelsStartTime, entryPrice, (direction == 1 ? "▲ BUY " : "▼ SELL ") + str.tostring(entryPrice, format.mintick), xloc = xloc.bar_time, yloc = direction == 1 ? yloc.belowbar : yloc.abovebar, style = direction == 1 ? label.style_label_up : label.style_label_down, color = direction == 1 ? bullColorInput : bearColorInput, textcolor = direction == 1 ? BULL_LABEL_TEXT : BEAR_LABEL_TEXT, size = signalSize, tooltip = "Confirmed breakout close\nSL: " + (na(stopPrice) ? "—" : str.tostring(stopPrice, format.mintick)) + " | TP3: " + str.tostring(targetNear, format.mintick)))
                    if showTradeLevelsInput and showTradeLabelsInput and validTradePlan
                        array.push(drawnLabels, label.new(tradeLabelTime, entryPrice, "ENTRY " + str.tostring(entryPrice, format.mintick) + (beActive ? " → SL (BE)" : ""), xloc = xloc.bar_time, style = label.style_label_left, color = beActive ? BE_COLOR : ENTRY_COLOR, textcolor = LABEL_TEXT, size = levelSize))
                    dashEntryText := (direction == 1 ? "Long @ " : "Short @ ") + str.tostring(entryPrice, format.mintick)
                    dashSLText := beActive ? "BE @ " + str.tostring(entryPrice, format.mintick) : na(stopPrice) ? "—" : str.tostring(stopPrice, format.mintick)
                    dashTP1Text := orderedTargets ? (displayTp1Reached ? "✓ " : "") + str.tostring(tp1Price, format.mintick) : "Invalid target spacing"
                    dashTP2Text := orderedTargets ? (displayTp2Reached ? "✓ " : "") + str.tostring(tp2Price, format.mintick) : "—"
                    dashTP3Text := (displayTp3Reached ? "✓ " : "") + str.tostring(targetNear, format.mintick)
                    // Financial plan is independent of whether drawing toggles are enabled.
                    // Share validity (TP1 + TP2 < 100%) is enforced by runtime.error on the first bar.
                    bool validSize = entryPrice > 0 and syminfo.pointvalue > 0
                    float tp3ClosePct = 100.0 - tp1ClosePctInput - tp2ClosePctInput
                    notionalText := "Notional: " + str.tostring(marginAmountInput * leverageInput, "0.00") + " " + syminfo.currency
                    if validSize
                        [qty, qOne, qTwo, qThree, pOne, pTwo, pThree, stopBefore, stopAfterOne, stopAfterTwo, riskDistance, rewardDistance] = tradeMath(marginAmountInput, leverageInput, entryPrice, syminfo.pointvalue, direction, stopPrice, tp1Price, tp2Price, targetNear, tp1ClosePctInput, tp2ClosePctInput)
                        quantityText := "Quantity: " + str.tostring(qty, "0.########") + " units/contracts (theoretical)"
                        bool validStop = not na(riskDistance) and riskDistance > 0
                        float riskPct = validStop ? riskDistance / entryPrice * 100.0 : na
                        riskPercentText := beActive ? "0.00% (BE)" : validStop ? str.tostring(riskPct, "0.00") + "%" : "Invalid SL side"
                        stopLossText := validStop ? money(stopBefore) : "No level on the risk side of entry"
                        if validStop and rewardDistance > 0
                            float rr = rewardDistance / riskDistance
                            dashRRText := str.tostring(rr, "#.##") + "R"
                            dashRRColor := rr >= RR_GOOD ? BULL_TEXT : rr >= RR_FAIR ? NEUTRAL_TEXT : BEAR_TEXT
                            dashRiskColor := beActive ? BE_COLOR : riskPct > RISK_HIGH_PCT ? BEAR_TEXT : riskPct > RISK_MID_PCT ? NEUTRAL_TEXT : BULL_TEXT
                        tp1CloseText := "TP1 Close: " + str.tostring(tp1ClosePctInput, "0.##") + "% · " + str.tostring(qOne, "0.########") + " units/contracts"
                        tp2CloseText := "TP2 Close: " + str.tostring(tp2ClosePctInput, "0.##") + "% · " + str.tostring(qTwo, "0.########") + " units/contracts"
                        tp3CloseText := "TP3 Close: " + str.tostring(tp3ClosePct, "0.##") + "% · " + str.tostring(qThree, "0.########") + " units/contracts"
                        if orderedTargets
                            tp1ProfitText := "TP1 Profit: " + money(pOne)
                            tp2ProfitText := "TP2 Profit: " + money(pTwo)
                            tp3ProfitText := "TP3 " + str.tostring(targetNear, format.mintick) + " (90% H) · profit " + money(pThree)
                            totalProfitText := money(pOne + pTwo + pThree)
                            if validStop
                                stopAfterOneText := money(moveToBEInput ? pOne : stopAfterOne)
                                netStopText := money(moveToBEInput ? pOne + pTwo : stopAfterTwo)
                                totalProfitText += " · Plan RR " + str.tostring((pOne + pTwo + pThree) / -stopBefore, "0.00")
                            float realizedTP = (tp1Reached ? pOne : 0.0) + (tp2Reached ? pTwo : 0.0)
                            if tradeExitKind != 0
                                float remainingQty = qty - (tp1Reached ? qOne : 0.0) - (tp2Reached ? qTwo : 0.0)
                                modeledResultText := money(realizedTP + direction * (tradeExitPrice - entryPrice) * remainingQty * syminfo.pointvalue) + " · " + tradeFinishReason
                            else if validTradePlan
                                modeledResultText := "Active · realized " + money(realizedTP)
                    else
                        quantityText := "Quantity: positive price and point value required"
                    // validTradePlan already implies ordered targets, so TP1/TP2 are drawable here.
                    if showTradeLevelsInput and validTradePlan
                        array.push(drawnLines, line.new(levelsStartTime, tp1Price, tradeEndTime, tp1Price, xloc = xloc.bar_time, color = displayTp1Reached ? TP_HIT_COLOR : TP1_COLOR, style = displayTp1Reached ? line.style_solid : lineStyle(tpLineStyleInput), width = 1))
                        array.push(drawnLines, line.new(levelsStartTime, tp2Price, tradeEndTime, tp2Price, xloc = xloc.bar_time, color = displayTp2Reached ? TP_HIT_COLOR : TP2_COLOR, style = displayTp2Reached ? line.style_solid : lineStyle(tpLineStyleInput), width = 1))
                        if showTradeLabelsInput
                            array.push(drawnLabels, label.new(tradeLabelTime, tp1Price, levelLabel(displayTp1Reached ? "TP1 ✓" : "TP1", tp1Price, entryPrice), xloc = xloc.bar_time, style = label.style_label_left, color = displayTp1Reached ? TP_HIT_COLOR : TP_LABEL_COLOR, textcolor = LABEL_TEXT, size = levelSize))
                            array.push(drawnLabels, label.new(tradeLabelTime, tp2Price, levelLabel(displayTp2Reached ? "TP2 ✓" : "TP2", tp2Price, entryPrice), xloc = xloc.bar_time, style = label.style_label_left, color = displayTp2Reached ? TP_HIT_COLOR : TP_LABEL_COLOR, textcolor = LABEL_TEXT, size = levelSize))
                        array.push(drawnLines, line.new(levelsStartTime, targetNear, tradeEndTime, targetNear, xloc = xloc.bar_time, color = displayTp3Reached ? TP_HIT_COLOR : TP3_COLOR, style = displayTp3Reached ? line.style_solid : lineStyle(tpLineStyleInput), width = 1))
                        if showTradeLabelsInput
                            array.push(drawnLabels, label.new(tradeLabelTime, targetNear, levelLabel(displayTp3Reached ? "TP3 ✓" : "TP3", targetNear, entryPrice), xloc = xloc.bar_time, style = label.style_label_left, color = displayTp3Reached ? TP_HIT_COLOR : TP_LABEL_COLOR, textcolor = LABEL_TEXT, size = levelSize))
                    // Confirmed event snapshots; historical reconstruction never sends alerts.
                    if showAlertsInput and validTradePlan and barstate.isrealtime and barstate.isconfirmed
                        if alertEntryInput and breakoutBar == bar_index
                            array.push(pendingEvents, direction == 1 ? "BUY" : "SELL")
                        if alertExitInput and bar_index > breakoutBar
                            if beActivationBar == bar_index
                                array.push(pendingEvents, "BREAK_EVEN")
                            if firstTP1Bar == bar_index
                                array.push(pendingEvents, "TP1_TOUCH")
                            if firstTP2Bar == bar_index
                                array.push(pendingEvents, "TP2_TOUCH")
                        if alertExitInput and tradeEndBar == bar_index and tradeFinishReason != ""
                            string exitEvent = tradeExitKind == 3 ? "BE_STOP_OUT" : tradeExitKind == 2 ? "SL_TOUCH" : "TP3_TOUCH"
                            array.push(pendingEvents, exitEvent)
                        float alertRisk = direction * (entryPrice - stopPrice)
                        float alertReward = direction * (targetNear - entryPrice)
                        float alertRR = alertRisk > 0 and alertReward > 0 ? alertReward / alertRisk : na
                        pendingAlertDetails := " | Entry: " + str.tostring(entryPrice, format.mintick) + " | SL: " + str.tostring(beActive ? entryPrice : stopPrice, format.mintick) + " | TP1: " + str.tostring(tp1Price, format.mintick) + " | TP2: " + str.tostring(tp2Price, format.mintick) + " | TP3: " + str.tostring(targetNear, format.mintick) + " | Initial RR: " + (na(alertRR) ? "—" : str.tostring(alertRR, "0.00"))
                        pendingAlertFields := ',"side":"' + (direction == 1 ? "buy" : "sell") + '","entry":' + jsonNumber(entryPrice) + ',"sl":' + jsonNumber(beActive ? entryPrice : stopPrice) + ',"initial_sl":' + jsonNumber(stopPrice) + ',"tp1":' + jsonNumber(tp1Price) + ',"tp2":' + jsonNumber(tp2Price) + ',"tp3":' + jsonNumber(targetNear) + ',"rr":' + jsonNumber(alertRR)
                    if showTargetInput and validTradePlan
                        int breakoutTime = array.get(historyTime, breakoutBar % HISTORY)
                        array.push(drawnLines, line.new(breakoutTime, breakoutLevel, breakoutTime, targetPrice, xloc = xloc.bar_time, color = targetColorInput, style = line.style_dotted))
                        line targetFarLine = line.new(breakoutTime, targetPrice, tradeEndTime, targetPrice, xloc = xloc.bar_time, color = targetColorInput, width = 1)
                        line targetNearLine = line.new(breakoutTime, targetNear, tradeEndTime, targetNear, xloc = xloc.bar_time, color = targetColorInput, width = 1)
                        array.push(drawnLines, targetFarLine)
                        array.push(drawnLines, targetNearLine)
                        // The TP3 line already marks this level; keep the near line only as the fill edge.
                        if showTradeLevelsInput
                            line.set_color(targetNearLine, color.new(targetColorInput, 100))
                        targetShading := linefill.new(targetFarLine, targetNearLine, color.new(color.yellow, FILL_TRANSP))
                        if showTradeLabelsInput
                            array.push(drawnLabels, label.new(tradeEndTime, (targetNear + targetPrice) / 2.0, "Target 90–100% H\n" + targetRange, xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.yellow, 80), textcolor = TEXT_COLOR, size = levelSize))
                if showLabelsInput
                    for i = 0 to N - 1
                        bool upper = isUpper(bestMask, i)
                        float price = upper ? array.get(hs, i) : array.get(ls, i)
                        label point = label.new(array.get(historyTime, array.get(xs, i) % HISTORY), price, str.tostring(i + 1) + (upper ? " H" : " L"), xloc = xloc.bar_time, style = upper ? label.style_label_down : label.style_label_up, color = color.new(upper ? upperColorInput : lowerColorInput, 85), textcolor = TEXT_COLOR, size = levelSize)
                        array.push(drawnLabels, point)
                bool ambiguous = not na(runnerUp) and runnerUp - best <= AMBIGUITY_THRESHOLD
                confidenceText := ambiguous ? "Ambiguous assignment" : allClosed ? "Valid assignment" : "Provisional anchors"
                // validTradePlan implies a breakout and a non-na stop.
                if showStopInput and validTradePlan
                    int stopStartTime = array.get(historyTime, breakoutBar % HISTORY)
                    // The initial stop stays live through the BE activation candle;
                    // the BE line takes over at the open of the following bar.
                    int originalStopEndTime = beActive ? barTime(beActivationBar + 1) : tradeEndTime
                    color originalStopColor = beActive ? color.new(SL_COLOR, 70) : SL_COLOR
                    array.push(drawnLines, line.new(stopStartTime, stopPrice, originalStopEndTime, stopPrice, xloc = xloc.bar_time, color = originalStopColor, style = lineStyle(slLineStyleInput), width = 2))
                    if showTradeLabelsInput
                        int originalLabelTime = beActive ? barTime(beActivationBar + LABEL_OFFSET_BARS) : tradeLabelTime
                        array.push(drawnLabels, label.new(originalLabelTime, stopPrice, levelLabel(beActive ? "INITIAL SL" : "SL", stopPrice, entryPrice), xloc = xloc.bar_time, style = label.style_label_left, color = originalStopColor, textcolor = beActive ? TEXT_MUTED : LABEL_TEXT, size = levelSize))
                    if beActive and beActivationBar < tradeEndBar
                        array.push(drawnLines, line.new(originalStopEndTime, entryPrice, tradeEndTime, entryPrice, xloc = xloc.bar_time, color = BE_COLOR, style = lineStyle(slLineStyleInput), width = 2))
                    if beActive and showTradeLabelsInput and not showTradeLevelsInput
                        array.push(drawnLabels, label.new(tradeLabelTime, entryPrice, "SL (BE) " + str.tostring(entryPrice, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = BE_COLOR, textcolor = LABEL_TEXT, size = levelSize))
                if showVwapInput and na(stopAnchorBar)
                    vwapText := "No anchor rule for triangles"
                if showVwapInput and not na(stopAnchorBar)
                    array<chart.point> vwapPoints = array.new<chart.point>()
                    array<chart.point> averagePoints = array.new<chart.point>()
                    float cumulativePV = 0.0
                    float cumulativeVolume = 0.0
                    float cumulativePrice = 0.0
                    int averageCount = 0
                    float lastAverage = na
                    int averageEndTime = na
                    float lastVwap = na
                    int lastVwapTime = na
                    bool missingVolume = false
                    string finishReason = ""
                    // Low-source VWAP for falling wedges; High-source for rising.
                    // With positive anchor volume, its first value is exactly the
                    // chosen extreme. Include the final touch candle as before.
                    for b = stopAnchorBar to bar_index
                        int slot = b % HISTORY
                        float v = array.get(historyVolume, slot)
                        float sourcePrice = fallingWedge ? array.get(historyLow, slot) : array.get(historyHigh, slot)
                        cumulativePrice += sourcePrice
                        averageCount += 1
                        lastAverage := cumulativePrice / averageCount
                        averageEndTime := array.get(historyTime, slot)
                        array.push(averagePoints, chart.point.from_time(averageEndTime, lastAverage))
                        missingVolume := missingVolume or na(v) or v < 0
                        if not na(v) and v > 0
                            cumulativePV += sourcePrice * v
                            cumulativeVolume += v
                        if cumulativeVolume > 0
                            lastVwap := cumulativePV / cumulativeVolume
                            lastVwapTime := array.get(historyTime, slot)
                            array.push(vwapPoints, chart.point.from_time(lastVwapTime, lastVwap))

                        // The average consumes the same confirmed exit snapshot as all trade lines.
                        if validTradePlan and tradeExitKind != 0 and b >= tradeEndBar
                            finishReason := tradeFinishReason
                            break
                    // Choose ONE weighting scheme for the whole displayed span;
                    // never mix actual volumes with fabricated per-bar volumes.
                    bool noUsableVolume = missingVolume or cumulativeVolume <= 0
                    bool useAverage = vwapVolumeModeInput == "Unweighted" or (vwapVolumeModeInput == "Auto" and noUsableVolume)
                    if not useAverage and missingVolume
                        vwapText := "Missing volumes; VWAP unavailable"
                    else if not useAverage and cumulativeVolume <= 0
                        vwapText := "No positive volume"
                    else
                        array<chart.point> displayedPoints = useAverage ? averagePoints : vwapPoints
                        float displayedPrice = useAverage ? lastAverage : lastVwap
                        int displayedTime = useAverage ? averageEndTime : lastVwapTime
                        string averageName = useAverage ? "Unweighted Average" : "VWAP"
                        if array.size(displayedPoints) >= 2
                            vwapCurve := polyline.new(displayedPoints, curved = false, closed = false, xloc = xloc.bar_time, line_color = vwapColorInput, line_width = 2)
                        string vwapState = finishReason != "" ? "finished: " + finishReason : not validTradePlan ? "waiting for valid entry" : "active"
                        vwapText := (useAverage ? "Unweighted " : "") + (fallingWedge ? "Low " : "High ") + str.tostring(displayedPrice, format.mintick) + " · " + vwapState
                        array.push(drawnLabels, label.new(displayedTime, displayedPrice, averageName, xloc = xloc.bar_time, style = label.style_label_left, color = color.new(vwapColorInput, 80), textcolor = TEXT_COLOR, size = levelSize))
                status := shape + (ambiguous ? " · ambiguous" : "")
                detail := "Max outside " + str.tostring(bestOutside, format.mintick) + " · candidates: " + str.tostring(candidates)
                note := (allClosed ? "" : "Unclosed anchor: geometry is provisional!\n") + "Linear scale · only selected candles checked"
                statusColor := ambiguous or not allClosed ? NEUTRAL_TEXT : ENTRY_COLOR
    else
        detail := "Anchor outside loaded history or not available yet"
    // ══════════════════════════════════════════════════════
    // 8. SECTIONED DASHBOARD
    // ══════════════════════════════════════════════════════
    array<string> rowKeys = array.new_string()
    array<string> rowValues = array.new_string()
    array<color> rowColors = array.new<color>()
    array<string> rowHints = array.new_string()
    if showDashInput
        string trendWord = formationBias == 1 ? "Bullish" : formationBias == -1 ? "Bearish" : "Neutral"
        panelRow(rowKeys, rowValues, rowColors, rowHints, "#Header", "◆ MWedge · " + trendWord, HEADER_TEXT, "Four manually selected candles; automatic High/Low assignments.")
        if dashMarketInput
            panelRow(rowKeys, rowValues, rowColors, rowHints, "#Market", "", HEADER_TEXT, "Expected wedge bias is independent of the confirmed breakout direction.")
            panelRow(rowKeys, rowValues, rowColors, rowHints, "Trend", trendWord, formationBias == 1 ? BULL_TEXT : formationBias == -1 ? BEAR_TEXT : TEXT_MUTED, "Falling wedge: Bullish bias. Rising wedge: Bearish bias. This is the expected pattern direction; BUY/SELL requires a confirmed breakout.")
            panelRow(rowKeys, rowValues, rowColors, rowHints, "Signal", signalText, displayDirection == 1 ? BULL_TEXT : displayDirection == -1 ? BEAR_TEXT : TEXT_MUTED, "Entry is the first confirmed close outside a boundary after candle 4 and before the apex. The previous close need not be inside.")
            panelRow(rowKeys, rowValues, rowColors, rowHints, "Timeframe", timeframe.period, TEXT_COLOR, "All calculations use the chart timeframe; no higher-timeframe data.")
            panelRow(rowKeys, rowValues, rowColors, rowHints, "Assignment", confidenceText, statusColor, "Valid/ambiguous describes the High/Low assignment, not trade strength or win probability.")
        if dashGeometryInput
            panelRow(rowKeys, rowValues, rowColors, rowHints, "#Formation", "", HEADER_TEXT, "Fit diagnostics for the selected candles.")
            panelRow(rowKeys, rowValues, rowColors, rowHints, "Status", status, statusColor, "Choose four distinct candles within 9999 bars. Unclosed anchors produce provisional geometry.")
            panelRow(rowKeys, rowValues, rowColors, rowHints, "Fit", detail, TEXT_MUTED, "Largest anchor-wick protrusion beyond the opposite boundary, and the number of valid assignments. Only selected candles are checked.")
            panelRow(rowKeys, rowValues, rowColors, rowHints, "Scale", note, TEXT_MUTED, "The wedge uses linear price geometry. Live anchor data can change before the anchor candle closes.")
            panelRow(rowKeys, rowValues, rowColors, rowHints, "Target", targetText, NEUTRAL_TEXT, "90–100% H measured from the broken boundary. H is the price difference between the earliest upper and earliest lower contacts.")
            panelRow(rowKeys, rowValues, rowColors, rowHints, "VWAP", vwapText, TEXT_COLOR, "Extreme-anchored average. Without usable volume, Auto uses equal candle weights for the entire span.")
        if dashTradeInput
            panelRow(rowKeys, rowValues, rowColors, rowHints, "#Trade", "", HEADER_TEXT, "Fixed levels for one manually selected formation.")
            if not hasEntry
                panelRow(rowKeys, rowValues, rowColors, rowHints, "#Waiting", "Flat · waiting for confirmed breakout", TEXT_MUTED, "No trade plan is active until a breakout candle closes.")
            else
                panelRow(rowKeys, rowValues, rowColors, rowHints, "Entry", dashEntryText, displayDirection == 1 ? BULL_TEXT : BEAR_TEXT, "Assumed entry is the breakout candle close; actual fill prices may differ.")
                panelRow(rowKeys, rowValues, rowColors, rowHints, "SL", dashSLText, displayBE ? BE_COLOR : SL_COLOR, "Initial stop uses selected anchors. BE @ marks the entry-level stop after TP1, effective from the following candle. Only TP3/SL/BE-stop finish the trade.")
                panelRow(rowKeys, rowValues, rowColors, rowHints, "TP1", dashTP1Text, displayTp1Reached ? TP_HIT_COLOR : TP_LABEL_COLOR, "First configurable fraction of the entry-to-TP3 price path.")
                panelRow(rowKeys, rowValues, rowColors, rowHints, "TP2", dashTP2Text, displayTp2Reached ? TP_HIT_COLOR : TP_LABEL_COLOR, "Second configurable fraction of the entry-to-TP3 price path.")
                panelRow(rowKeys, rowValues, rowColors, rowHints, "TP3", dashTP3Text, displayTp3Reached ? TP_HIT_COLOR : TP_LABEL_COLOR, "Nearest target-zone boundary at 90% H. The final position remainder closes here in the plan.")
                panelRow(rowKeys, rowValues, rowColors, rowHints, "R:R", dashRRText, dashRRColor, "Initial SL : TP3 = 1 : reward/risk. This planned ratio stays fixed after BE; SL Dist shows the current stop distance.")
                panelRow(rowKeys, rowValues, rowColors, rowHints, "SL Dist", riskPercentText, dashRiskColor, "Risk-side price distance from entry to SL divided by entry price.")
        if dashMathInput
            panelRow(rowKeys, rowValues, rowColors, rowHints, "#Position Plan", "", HEADER_TEXT, "Linear-contract estimates, not execution statistics.")
            panelRow(rowKeys, rowValues, rowColors, rowHints, "Margin / Leverage", marginText + " · " + leverageText, TEXT_COLOR, "Margin is in quote currency. Notional equals margin multiplied once by leverage.")
            if not hasEntry
                panelRow(rowKeys, rowValues, rowColors, rowHints, "Plan", "Waiting for confirmed entry", TEXT_MUTED, "Sizing and P&L require a known entry price.")
            else
                panelRow(rowKeys, rowValues, rowColors, rowHints, "Position", notionalText + " · " + quantityText, TEXT_COLOR, "Quantity = notional / (entry × point value). Theoretical units/contracts; not rounded to broker lot sizes.")
                panelRow(rowKeys, rowValues, rowColors, rowHints, "TP1 Plan", tp1CloseText + " · " + tp1ProfitText, BULL_TEXT, "Close share of the initial position × directional TP1 price move × point value.")
                panelRow(rowKeys, rowValues, rowColors, rowHints, "TP2 Plan", tp2CloseText + " · " + tp2ProfitText, BULL_TEXT, "TP2's share is measured against initial size, not the remainder after TP1.")
                panelRow(rowKeys, rowValues, rowColors, rowHints, "TP3 Plan", tp3CloseText + " · " + tp3ProfitText, BULL_TEXT, "TP3 closes 100% minus TP1 and TP2 shares. Default remaining share: 34%.")
                panelRow(rowKeys, rowValues, rowColors, rowHints, "All Targets", totalProfitText, BULL_TEXT, "Sum of all three partial profits. Plan RR uses this sum divided by the initial full-position SL risk.")
                panelRow(rowKeys, rowValues, rowColors, rowHints, "SL Before TP1", stopLossText, BEAR_TEXT, "Full initial position stops out before any take-profit exit.")
                panelRow(rowKeys, rowValues, rowColors, rowHints, moveToBEInput ? "TP1 then BE" : "TP1 then SL", stopAfterOneText, NEUTRAL_TEXT, "With BE enabled, the remainder exits at entry and this scenario retains only TP1 profit. Excludes fees.")
                panelRow(rowKeys, rowValues, rowColors, rowHints, moveToBEInput ? "TP1 + TP2 then BE" : "TP1 + TP2 then SL", netStopText, NEUTRAL_TEXT, "With BE enabled, the remainder exits at entry and this scenario retains TP1 + TP2 profits. Excludes fees.")
            if hasEntry
                panelRow(rowKeys, rowValues, rowColors, rowHints, "Modeled Result", modeledResultText, TEXT_COLOR, "Gross result from the confirmed OHLC timeline and configured partial closes. Optimistic TP priority; not broker execution data.")
            panelRow(rowKeys, rowValues, rowColors, rowHints, "Model", mathNote, TEXT_MUTED, "Excludes fees, funding, swaps, slippage, liquidation, and inverse-contract settlement. OHLC sequence is unknown; new TP touches take optimistic priority over SL. BE cannot stop out on its activation candle.")
        panelRow(rowKeys, rowValues, rowColors, rowHints, "#Version", "MWedge · v" + INDICATOR_VERSION, TEXT_MUTED, "Reactive Trail System 2.2.1 presentation adapted for the manual formation planner.")
        int requiredRows = array.size(rowKeys)
        // RTS dynamic-height pattern: rebuild explicitly to clear old merged cells.
        if not na(panel)
            table.delete(panel)
        panel := table.new(dashPosition, 2, requiredRows, bgcolor = TABLE_BG, border_color = TABLE_BORDER, border_width = 1, frame_color = TABLE_BORDER, frame_width = 1)
        int r = 0
        bool zeb = false
        color headerBg = formationBias == 1 ? HEADER_BG_BULL : formationBias == -1 ? HEADER_BG_BEAR : HEADER_BG
        for i = 0 to requiredRows - 1
            string key = array.get(rowKeys, i)
            string value = array.get(rowValues, i)
            bool merged = str.startswith(key, "#")
            bool header = key == "#Header"
            bool footer = key == "#Version"
            bool waiting = key == "#Waiting"
            color rowBg = header ? headerBg : footer ? TABLE_BG : merged and not waiting ? TABLE_ROW_ALT : zeb ? TABLE_ROW_ALT : TABLE_BG
            if merged
                string heading = header or footer or waiting ? value : "— " + str.substring(key, 1) + " —"
                table.cell(panel, 0, r, heading, text_color = header ? HEADER_TEXT : TEXT_MUTED, bgcolor = rowBg, text_size = header or waiting ? dashSize : dashSizeSub, text_halign = text.align_center, tooltip = array.get(rowHints, i))
                table.merge_cells(panel, 0, r, 1, r)
            else
                table.cell(panel, 0, r, key, text_color = TEXT_MUTED, bgcolor = rowBg, text_size = dashSize, tooltip = array.get(rowHints, i))
                table.cell(panel, 1, r, value, text_color = array.get(rowColors, i), bgcolor = rowBg, text_size = dashSize, tooltip = array.get(rowHints, i))
                zeb := not zeb
            r += 1
    else if not na(panel)
        table.delete(panel)
        panel := na

    // ══════════════════════════════════════════════════════
    // 9. WATERMARK
    // ══════════════════════════════════════════════════════
    table.cell(watermark, 0, 0, showWatermarkInput ? "WillyAlgoTrader" : "", text_color = WM_COLOR, text_size = size.normal, bgcolor = color.new(TABLE_BG, 100))

    // ══════════════════════════════════════════════════════
    // 10. ALERTS — one bundled message per confirmed candle
    // ══════════════════════════════════════════════════════
    if showAlertsInput and barstate.isrealtime and barstate.isconfirmed and array.size(pendingEvents) > 0
        string events = array.join(pendingEvents, ", ")
        string eventJson = '["' + array.join(pendingEvents, '","') + '"]'
        string textMessage = events + " | " + syminfo.tickerid + " | TF: " + timeframe.period + " | Price: " + str.tostring(close, format.mintick) + " | Time: " + str.format_time(time, "yyyy-MM-dd HH:mm", syminfo.timezone) + pendingAlertDetails
        string jsonMessage = '{"events":' + eventJson + ',"ticker":"' + jsonEscape(syminfo.tickerid) + '","timeframe":"' + jsonEscape(timeframe.period) + '","time":' + str.tostring(time) + ',"price":' + jsonNumber(close) + pendingAlertFields + '}'
        alert(webhookInput ? jsonMessage : textMessage, alert.freq_once_per_bar_close)
````
