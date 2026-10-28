# Pivot Sniper Method [trade_w_samet]

- url: https://www.tradingview.com/script/QOGmZakO-Pivot-Sniper-Method-trade-w-samet/
- type: indicator
- pine_id: PUB;bf0ea04af4e746f3adb94c6ae21a92d6
- version: 1.0

## Description

🎯 Pivot Sniper Method [trade_w_samet]

Pivot Sniper Method [trade_w_samet] is a confirmed pivot-reversal, signal-quality, session-filtering, trade-mapping, alert, and loaded-history statistics indicator designed to convert confirmed price pivots into a structured chart-review workflow.

The script is built around one central idea:

Not every confirmed pivot should be treated as an equal-quality reversal setup.

Instead of displaying every pivot as an identical signal, Pivot Sniper Method evaluates each confirmed pivot through a five-part Signal Strength model, applies the selected directional and session rules, maps a complete Entry / Stop Loss / TP1 / TP2 / TP3 structure, manages optional Break-Even behavior, and records the result through an internal R-based tracker.

When an eligible pivot is confirmed, the script can:

• Display a confirmed BUY or SELL label
• Show the calculated Signal Strength percentage directly below the direction label
• Evaluate Pivot Distance, Wick Quality, Confirmation Candle, Volume Participation, and Trend Alignment
• Apply Bullish, Bearish, or Both directional bias
• Restrict new signals to London, New York, London + New York, All Sessions, or a Custom session
• Apply an adjustable signal cooldown
• Calculate the Entry at the confirmation-candle close
• Calculate Stop Loss using ATR, Pivot Level, Pivot + ATR Buffer, or Signal Candle
• Calculate independently adjustable TP1, TP2, and TP3 targets
• Move the active Stop Loss to Break-Even after TP1 or TP2
• Add an optional favorable Break-Even tick offset
• Replace the current active tracked trade when a new eligible signal appears
• Display active Entry, Stop / Break-Even, TP1, TP2, and TP3 lines and labels
• Remove the separate Entry line and label after Break-Even becomes active
• Display compact tooltips containing signal, price, risk, target, and status information
• Track Trades, Win Rate, NET R, Average R, TP1 / TP2 / TP3 hit rates, and Break-Even results
• Display a compact premium desktop dashboard
• Display a reduced Phone Mode dashboard
• Move the dashboard to any chart corner
• Support Auto, Dark, Light, and Phone visual modes
• Support static alertcondition() events
• Support one combined “Any alert() function call” workflow
• Include symbol, timeframe, strength, Entry, Stop, targets, Stop Loss mode, Break-Even mode, and session context in dynamic alerts

The purpose of the script is to provide a transparent framework for studying confirmed pivots, setup quality, session context, predefined risk, multiple reward targets, Break-Even behavior, and bar-based historical outcomes.

It is not financial advice.
It is not an automated trading system.
It does not execute broker orders.
It does not calculate position size.
It does not guarantee that a confirmed pivot will produce a reversal.
It does not guarantee that historical Win Rate or NET R will continue in future market conditions.
It does not include spread, commission, slippage, latency, financing, taxes, partial fills, or broker-specific execution.
It does not reconstruct the exact intrabar path inside historical candles.



[image]https://www.tradingview.com/x/FkfFDJFl/[/image]


━━━━━━━━━━━━━━━━━━━━━━
📌 OVERVIEW
━━━━━━━━━━━━━━━━━━━━━━

At a high level, Pivot Sniper Method performs the following sequence:

• Searches price for confirmed pivot lows and pivot highs.
• Requires the selected number of completed candles on the right side of a pivot.
• Rejects simultaneous bullish and bearish pivot confirmation on the same calculation.
• Evaluates the selected Trend Bias.
• Evaluates the selected Trading Session.
• Evaluates the signal cooldown.
• Calculates a 0–100 Signal Strength score.
• Rejects signals below the selected minimum strength when the strength filter is enabled.
• Displays a BUY or SELL label only when all active signal rules pass.
• Opens a tracked trade at the close of the confirmation candle.
• Selects a Stop Loss using the active Stop Loss Mode.
• Uses ATR as a safety fallback when a structural Stop Loss is invalid.
• Calculates TP1, TP2, and TP3 from the actual Entry-to-Stop risk distance.
• Tracks target and stop touches from the candle after entry.
• Moves the active Stop Loss to Break-Even after the selected target condition.
• Replaces an active tracked trade at the current close when a new eligible signal appears.
• Records each completed trade in R.
• Updates a compact dashboard with state, trade, performance, and quality information.
• Generates static and dynamic TradingView alert events.

The script does not use machine learning.

It does not claim to predict every market reversal.

Its dashboard is not TradingView Strategy Tester.

Its statistics are calculated internally from the script’s own confirmed-signal, OHLC-touch, replacement-exit, and Break-Even rules.


━━━━━━━━━━━━━━━━━━━━━━
🧠 CORE IDEA
━━━━━━━━━━━━━━━━━━━━━━

A pivot low identifies a price point that is lower than the selected number of candles on both sides.

A pivot high identifies a price point that is higher than the selected number of candles on both sides.

Confirmed pivots can provide useful reversal context, but a pivot alone does not answer:

• whether the setup agrees with the selected directional bias
• whether the setup occurs during the selected trading session
• whether the pivot candle contains a meaningful rejection wick
• whether price has moved sufficiently away from the confirmed pivot
• whether the confirmation candle supports the intended direction
• whether volume participation is elevated or ordinary
• whether price and the selected EMA structure support the direction
• where Stop Loss should be placed
• how the trade should be mapped in R
• when Break-Even should become active
• how a new signal should affect an existing tracked trade
• how the setup behaved under the script’s historical bar-touch rules

Pivot Sniper Method therefore treats the pivot as the first stage of a complete process rather than the final decision.

The complete workflow is:

potential pivot
→ right-side pivot confirmation
→ same-bar conflict rejection
→ directional-bias validation
→ session validation
→ cooldown validation
→ five-part quality scoring
→ minimum-strength validation
→ BUY or SELL signal
→ confirmation-candle Entry
→ Stop Loss selection
→ TP1 / TP2 / TP3 mapping
→ active-trade management
→ optional Break-Even
→ TP3, Stop, Break-Even, or replacement exit
→ internal R result
→ dashboard update
→ alert event


━━━━━━━━━━━━━━━━━━━━━━
🧩 WHY THIS IS NOT A SIMPLE PIVOT MARKER
━━━━━━━━━━━━━━━━━━━━━━

A basic pivot script can stop after placing a shape on a confirmed swing high or swing low.

Pivot Sniper Method continues beyond pivot detection.

Each eligible setup passes through a coordinated structure:

confirmed price pivot
→ 0–100 quality evaluation
→ bias and session permission
→ structured Entry
→ selectable Stop Loss model
→ independent TP1, TP2, and TP3 targets
→ optional Break-Even transition
→ live target-status updates
→ active-trade replacement logic
→ historical R accounting
→ compact statistics dashboard
→ static and dynamic alerts

The pivot module defines the confirmed reversal location.

The Signal Strength module evaluates quality.

The Trend Bias module controls permitted directions.

The Time Filter controls when new setups may be accepted.

The trade-mapping module converts the setup into explicit price levels.

The Break-Even module changes active risk only after the selected target is confirmed.

The statistics module summarizes the exact results produced by those rules.

The alert module communicates signal and trade-management events.

These modules are not unrelated indicators placed together.

They form one process for identifying, filtering, mapping, monitoring, and reviewing confirmed pivot-reversal setups.


━━━━━━━━━━━━━━━━━━━━━━
⚙️ HOW THE SCRIPT WORKS
━━━━━━━━━━━━━━━━━━━━━━

The script runs directly on the main price chart.

It calculates confirmed price pivots using independently adjustable left-side and right-side lengths for highs and lows.

The default pivot configuration is:

• Pivot High Left Bars: 10
• Pivot High Right Bars: 10
• Pivot Low Left Bars: 10
• Pivot Low Right Bars: 10

The signal engine then combines:

• confirmed pivot status
• Bullish / Bearish / Both bias permission
• selected session permission
• Signal Strength threshold
• cooldown permission
• same-bar dual-pivot rejection
• confirmed chart-bar status

A BUY signal is based on a confirmed pivot low.

A SELL signal is based on a confirmed pivot high.

The signal label is placed on the confirmation candle, not on the original historical pivot candle.

The Entry is also stored at the close of the confirmation candle.

This separation is important:

Pivot Price

The historical swing level that became confirmed after the selected right-side bars.

Signal Candle

The later candle where the script knows the pivot exists and all active filters pass.

Entry Price

The close of that later signal-confirmation candle.


━━━━━━━━━━━━━━━━━━━━━━
🔍 PIVOT DETECTION MODEL
━━━━━━━━━━━━━━━━━━━━━━

Pivot High Left Bars determines how many candles to the left must have lower highs than a potential pivot high.

Pivot High Right Bars determines how many completed candles must form to the right before the potential pivot high is confirmed.

Pivot Low Left Bars determines how many candles to the left must have higher lows than a potential pivot low.

Pivot Low Right Bars determines how many completed candles must form to the right before the potential pivot low is confirmed.

Higher left and right values generally identify larger and less frequent swing structures.

Lower values generally identify smaller and more frequent structures.

The high and low settings are independent.

This allows users to study symmetrical configurations such as 10 / 10 for both directions, or asymmetrical configurations when market behavior requires different sensitivity for pivot highs and pivot lows.


The central pivot calculation is:

[pine]
float confirmedPivotHigh = ta.pivothigh(
     high,
     leftHighInput,
     rightHighInput
)

float confirmedPivotLow = ta.pivotlow(
     low,
     leftLowInput,
     rightLowInput
)

bool rawBuySignal =
     barstate.isconfirmed and
     not na(confirmedPivotLow)

bool rawSellSignal =
     barstate.isconfirmed and
     not na(confirmedPivotHigh)
[/pine]

These functions return a confirmed pivot value only after the required right-side bars exist.


A confirmed pivot does not automatically become a signal.

It must still pass:

• same-bar conflict rejection
• Trend Bias
• Trading Session
• Signal Strength
• cooldown


━━━━━━━━━━━━━━━━━━━━━━
⏳ PIVOT CONFIRMATION AND SIGNAL TIMING
━━━━━━━━━━━━━━━━━━━━━━

This section is essential for correct interpretation.

The script uses confirmed pivot functions.

A pivot is not known on the original pivot candle.

For example, with Pivot Low Right Bars set to 10:

• the potential pivot low occurs
• ten additional candles must complete to its right
• the pivot becomes confirmed on the later calculation candle
• the BUY candidate can then be evaluated

The signal label is displayed on the later confirmation candle.

The trade Entry is stored at the close of that confirmation candle.

The script does not backdate the BUY or SELL trade label to the original pivot candle.

This means:

• the pivot price belongs to an earlier historical candle
• the signal becomes available later
• the displayed Entry reflects the later confirmation close
• increasing right-side bars increases confirmation delay
• decreasing right-side bars confirms smaller structures earlier

The script also requires barstate.isconfirmed for raw pivot candidates.

Signals are therefore based on completed chart candles.

This reduces unfinished current-candle changes, but it does not remove the inherent delay required by pivot confirmation.



━━━━━━━━━━━━━━━━━━━━━━
🟢 CONFIRMED BUY LOGIC
━━━━━━━━━━━━━━━━━━━━━━

A BUY candidate begins when a pivot low is confirmed.

The candidate is rejected when a pivot high is also confirmed on the same calculation.

The remaining BUY candidate must satisfy:

• Trend Bias is Bullish or Both
• the selected Trading Session is active
• the BUY Signal Strength meets the minimum threshold when filtering is enabled
• the cooldown is ready
• the chart bar is confirmed

When accepted, the script displays:

▲ BUY
strength%

The strength percentage appears on the second line to keep the label compact.


The compact two-line BUY label is constructed as:

[pine]
string buyLabelText =
     showStrengthOnSignalInput
     ? "▲ BUY\n" + str.tostring(buySignalStrength) + "%"
     : "▲ BUY"
[/pine]

The SELL label uses the mirrored ▼ SELL format.


The label is placed below the signal candle.

The BUY tooltip can display:

• Confirmed BUY
• Signal Strength
• Confirmed Pivot price

The tracked Entry is the signal-confirmation candle close.

The BUY Stop Loss is placed below Entry using the selected Stop Loss Mode.

TP1, TP2, and TP3 are calculated above Entry from the actual Entry-to-Stop risk distance.



━━━━━━━━━━━━━━━━━━━━━━
🔴 CONFIRMED SELL LOGIC
━━━━━━━━━━━━━━━━━━━━━━

A SELL candidate begins when a pivot high is confirmed.

The candidate is rejected when a pivot low is also confirmed on the same calculation.

The remaining SELL candidate must satisfy:

• Trend Bias is Bearish or Both
• the selected Trading Session is active
• the SELL Signal Strength meets the minimum threshold when filtering is enabled
• the cooldown is ready
• the chart bar is confirmed

When accepted, the script displays:

▼ SELL
strength%

The strength percentage appears on the second line.

The label is placed above the signal candle.

The SELL tooltip can display:

• Confirmed SELL
• Signal Strength
• Confirmed Pivot price

The tracked Entry is the signal-confirmation candle close.

The SELL Stop Loss is placed above Entry using the selected Stop Loss Mode.

TP1, TP2, and TP3 are calculated below Entry from the actual Entry-to-Stop risk distance.



━━━━━━━━━━━━━━━━━━━━━━
💪 SIGNAL STRENGTH MODEL
━━━━━━━━━━━━━━━━━━━━━━

Signal Strength is a 0–100 quality score.

The final score contains five components worth up to 20 points each:

1. Pivot Distance
2. Wick Quality
3. Confirmation Candle
4. Volume Participation
5. Trend Alignment

The score is intended to compare the internal characteristics of confirmed pivot setups under the same script rules.

It is not a probability forecast.

A 75% label does not mean there is a guaranteed 75% probability of profit.

It means the setup received 75 points out of the script’s 100-point quality model.

The Minimum Signal Strength input controls the required score.

Default:

55

When the filter is enabled:

• scores below the minimum are rejected
• scores equal to or above the minimum are eligible
• lower thresholds generally create more signals
• higher thresholds generally create fewer signals

The strength percentage can be hidden from the BUY / SELL label without disabling the strength filter.


The five component values are combined into the final score:

[pine]
int buySignalStrength = int(math.round(
     math.min(
          buyPivotDistanceScore +
          buyWickScore +
          buyCandleScore +
          volumeScore +
          buyTrendScore,
          100.0
     )
))

int sellSignalStrength = int(math.round(
     math.min(
          sellPivotDistanceScore +
          sellWickScore +
          sellCandleScore +
          volumeScore +
          sellTrendScore,
          100.0
     )
))
[/pine]


A score is therefore the sum of five internal measurements, capped at 100.




━━━━━━━━━━━━━━━━━━━━━━
📏 PIVOT DISTANCE COMPONENT
━━━━━━━━━━━━━━━━━━━━━━

Pivot Distance evaluates how far the confirmation-candle close is from the confirmed pivot relative to ATR.

For BUY candidates, the model measures the distance from the confirmed pivot low to the current close.

For SELL candidates, it measures the distance from the current close to the confirmed pivot high.

The normalized value is capped internally.

The maximum contribution is 20 points.

This component does not claim that a larger distance is always better.

It only measures the amount of price separation used by this quality model.


━━━━━━━━━━━━━━━━━━━━━━
🕯️ WICK QUALITY COMPONENT
━━━━━━━━━━━━━━━━━━━━━━

Wick Quality evaluates the rejection wick on the original pivot candle.

For BUY candidates:

• lower wick size is compared with the full pivot-candle range

For SELL candidates:

• upper wick size is compared with the full pivot-candle range

A larger relevant wick can contribute more points, up to 20.

This component attempts to represent rejection behavior at the confirmed swing.

A large wick does not guarantee reversal continuation.


━━━━━━━━━━━━━━━━━━━━━━
📊 CONFIRMATION CANDLE COMPONENT
━━━━━━━━━━━━━━━━━━━━━━

The Confirmation Candle component evaluates the candle where the pivot becomes confirmed and the signal is processed.

The model considers:

• body size relative to the full candle range
• bullish close direction for BUY candidates
• bearish close direction for SELL candidates

The body ratio contributes most of the component score.

A directional close can add an additional internal bonus.

The maximum contribution is 20 points.

The confirmation candle is not the original pivot candle.


━━━━━━━━━━━━━━━━━━━━━━
🔊 VOLUME PARTICIPATION COMPONENT
━━━━━━━━━━━━━━━━━━━━━━

Volume Participation compares current volume with an adjustable volume average.

Default volume length:

20

Higher relative volume can contribute more points, up to 20.

The component is internally capped.

When usable volume data is unavailable, the script applies a neutral fallback contribution instead of automatically assigning zero.

Volume behavior differs across asset classes and data feeds.

For some symbols, displayed volume can represent exchange volume.

For others, it can represent tick activity or a provider-specific value.


━━━━━━━━━━━━━━━━━━━━━━
📈 TREND ALIGNMENT COMPONENT
━━━━━━━━━━━━━━━━━━━━━━

Trend Alignment uses an adjustable EMA.

Default EMA length:

50

For BUY candidates, the component evaluates:

• whether price is above the EMA
• whether the EMA is rising

For SELL candidates, it evaluates:

• whether price is below the EMA
• whether the EMA is falling

Each condition contributes part of the 20-point component.

This EMA is used as one component of Signal Strength.

It is not a separate hard directional filter.

A setup can still receive points from the other four components when Trend Alignment is weak.


━━━━━━━━━━━━━━━━━━━━━━
🧭 TREND BIAS
━━━━━━━━━━━━━━━━━━━━━━

Trend Bias controls which signal directions are permitted.

Available modes:

• Bullish
• Bearish
• Both

Bullish

Allows only confirmed BUY signals.

Bearish

Allows only confirmed SELL signals.

Both

Allows confirmed signals in both directions.

Trend Bias does not change pivot detection.

It changes which confirmed candidates are allowed to become signals and tracked trades.


The final signal gate combines pivot confirmation, directional permission, session permission, Signal Strength, and cooldown:

[pine]
bool buySignal =
     buyCandidate and
     bullishBiasAllowed and
     timeFilterPassed and
     buyStrengthPassed and
     cooldownReady

bool sellSignal =
     sellCandidate and
     bearishBiasAllowed and
     timeFilterPassed and
     sellStrengthPassed and
     cooldownReady
[/pine]


Only candidates that pass every active condition become BUY or SELL signals.



━━━━━━━━━━━━━━━━━━━━━━
🕒 SESSION FILTER
━━━━━━━━━━━━━━━━━━━━━━

The Trading Session input controls when new signals can be accepted.

Available modes:

• All Sessions
• London
• New York
• London + New York
• Custom

London uses:

08:00–17:00
Europe/London time

New York uses:

09:30–16:00
America/New_York time

London + New York accepts signals during either defined session.

Custom allows the user to define a session and select:

• Exchange
• UTC
• Europe/London
• America/New_York
• Europe/Istanbul
• Asia/Tokyo

The session filter affects new entries only.

An already active tracked trade continues to be managed outside the selected session.

The dashboard displays whether the current session rule is OPEN or CLOSED.


━━━━━━━━━━━━━━━━━━━━━━
⏳ COOLDOWN AND CONFLICT HANDLING
━━━━━━━━━━━━━━━━━━━━━━

Signal Cooldown Bars defines the minimum number of completed candles required between accepted signals.

Default:

0

A value of 0 disables additional cooldown filtering.

Higher values reduce how frequently new signals can be accepted.

When a pivot high and pivot low are both confirmed on the same calculation, the script rejects both candidates.

This prevents contradictory BUY and SELL signals from being accepted on the same candle.


━━━━━━━━━━━━━━━━━━━━━━
🎯 ENTRY AND ACTIVE-TRADE REPLACEMENT MODEL
━━━━━━━━━━━━━━━━━━━━━━

The Entry is stored at the close of the accepted signal candle.

The script maintains one active tracked trade.

However, new eligible signals are not ignored while a trade is active.

When a new eligible BUY or SELL signal appears:

• the current active trade is valued at the new signal candle’s close
• its current R result is added to statistics
• its active lines and labels are removed
• the new signal opens a new tracked trade

This behavior applies to eligible same-direction and opposite-direction signals.

The replacement exit is not a broker fill.

It is an internal close-based accounting rule used to keep only one active tracked trade.

Because replacement exits can occur before TP3, Stop Loss, or Break-Even, NET R can include partial positive or negative R outcomes.


━━━━━━━━━━━━━━━━━━━━━━
🛑 STOP LOSS SYSTEM
━━━━━━━━━━━━━━━━━━━━━━

The script includes four Stop Loss modes:

• ATR
• Pivot Level
• Pivot + ATR Buffer
• Signal Candle

ATR

BUY:
Entry − ATR × multiplier

SELL:
Entry + ATR × multiplier

Default ATR length:

14

Default ATR multiplier:

2.0

Pivot Level

BUY:
confirmed pivot low

SELL:
confirmed pivot high

Pivot + ATR Buffer

BUY:
confirmed pivot low − ATR × pivot buffer

SELL:
confirmed pivot high + ATR × pivot buffer

Default pivot buffer:

0.25 ATR

Signal Candle

BUY:
signal candle low

SELL:
signal candle high

The script validates the selected Stop Loss.

For BUY, Stop Loss must be meaningfully below Entry.

For SELL, Stop Loss must be meaningfully above Entry.

When the selected structural stop is invalid, the script uses the ATR Stop Loss as a safety fallback.

The actual risk distance is:

absolute difference between Entry and the validated Stop Loss

That distance becomes 1R for all target calculations.


The requested Stop Loss is selected from the active mode:

[pine]
requestedStopPrice :=
     stopLossModeInput == "ATR"
     ? activeEntryPrice - atrFallbackDistance
     : stopLossModeInput == "Pivot Level"
     ? confirmedPivotLow
     : stopLossModeInput == "Pivot + ATR Buffer"
     ? confirmedPivotLow - atrValue * pivotBufferATRInput
     : low
[/pine]

For SELL trades, the same logic is mirrored above Entry.

The script then validates the requested structural stop.

When the selected price is not on the correct side of Entry, ATR is used as the fallback.





━━━━━━━━━━━━━━━━━━━━━━
🏆 TP1 / TP2 / TP3 SYSTEM
━━━━━━━━━━━━━━━━━━━━━━

TP1, TP2, and TP3 are independently adjustable.

Default values:

• TP1: 1R
• TP2: 2R
• TP3: 3R

For BUY:

target = Entry + risk distance × selected R multiple

For SELL:

target = Entry − risk distance × selected R multiple

TP1 and TP2 are intermediate target events.

TP3 is the final target and closes the active tracked trade.

When TP3 is touched:

• TP1 is also recorded if it was not already recorded
• TP2 is also recorded if it was not already recorded
• TP3 is recorded
• the trade closes at the selected TP3 R value

Users should normally keep:

TP1 < TP2 < TP3

The script allows independent values, so users are responsible for maintaining a logical target sequence.


After the validated Stop Loss is stored, the script defines 1R and calculates each target:

[pine]
activeRiskDistance :=
     math.max(
          math.abs(activeEntryPrice - activeStopPrice),
          syminfo.mintick
     )

activeTP1Price :=
     activeTradeDirection == 1
     ? activeEntryPrice + activeRiskDistance * tp1RRInput
     : activeEntryPrice - activeRiskDistance * tp1RRInput

activeTP2Price :=
     activeTradeDirection == 1
     ? activeEntryPrice + activeRiskDistance * tp2RRInput
     : activeEntryPrice - activeRiskDistance * tp2RRInput

activeTP3Price :=
     activeTradeDirection == 1
     ? activeEntryPrice + activeRiskDistance * tp3RRInput
     : activeEntryPrice - activeRiskDistance * tp3RRInput
[/pine]


The target calculations therefore remain proportional to the actual Entry-to-Stop distance.



━━━━━━━━━━━━━━━━━━━━━━
🟡 BREAK-EVEN SYSTEM
━━━━━━━━━━━━━━━━━━━━━━

Break-Even Mode includes:

• Off
• After TP1
• After TP2

After TP1

The Stop Loss moves to Entry after the TP1-touch candle closes.

After TP2

The Stop Loss moves to Entry after the TP2-touch candle closes.

The updated Break-Even stop applies from the following candle.

An optional favorable tick offset can be added.

For BUY:

Break-Even = Entry + offset

For SELL:

Break-Even = Entry − offset

When Break-Even becomes active:

• the Stop Loss line changes to the Break-Even color
• the Stop label changes from SL to BE
• the separate Entry line is deleted
• the separate Entry label is deleted
• only the BE level remains at or near Entry

This prevents Entry and Break-Even labels from overlapping at the same price.

A Break-Even stop with zero offset produces approximately 0R.

A positive favorable offset can produce a small positive R result.



━━━━━━━━━━━━━━━━━━━━━━
⚠️ SAME-CANDLE STOP AND TARGET HANDLING
━━━━━━━━━━━━━━━━━━━━━━

Historical OHLC candles do not reveal the exact sequence of all intrabar price movement.

A candle can include both the active Stop price and one or more target prices.

When the active Stop and a target are both touched inside the same historical candle, the script uses a conservative rule:

The active Stop receives priority.

This applies to the original Stop Loss and the active Break-Even stop.

Trade-management checks begin on the candle after Entry.

The Entry candle cannot immediately close the new tracked trade.

The conservative priority rule can produce different results from lower-timeframe reconstruction or tick-level execution data.


━━━━━━━━━━━━━━━━━━━━━━
📐 ACTIVE TRADE VISUAL SYSTEM
━━━━━━━━━━━━━━━━━━━━━━

While a tracked trade is active, the script can display:

• Stop Loss or Break-Even line
• Entry line
• TP1 line
• TP2 line
• TP3 line
• Stop Loss or Break-Even label
• Entry label
• TP1 label
• TP2 label
• TP3 label

The lines project to the right by the selected number of bars.

Default:

20 bars

Stop and Entry use solid lines.

Targets use dashed lines.

After TP1 or TP2 is reached:

• the corresponding target label changes to a completed state
• the corresponding line becomes more transparent

After Break-Even activates:

• the Entry line and Entry label disappear
• the active Stop line and label become BE

When the trade closes or is replaced:

• active trade lines are deleted
• active trade labels are deleted

The script does not preserve completed trade lines as permanent historical drawings.


━━━━━━━━━━━━━━━━━━━━━━
🏷️ LABELS, TOOLTIPS, AND TEXT
━━━━━━━━━━━━━━━━━━━━━━

BUY and SELL labels use two lines when strength display is enabled:

direction
strength%

Available Label Size values:

• Tiny
• Small
• Normal
• Large
• Huge

The setting controls:

• BUY
• SELL
• Entry
• Stop Loss
• Break-Even
• TP1
• TP2
• TP3

Phone Mode overrides the selected label size with Tiny.

Visible chart labels use bold and italic formatting.

Signal tooltips can show:

• direction
• strength
• pivot price

Trade-level tooltips can show:

• Entry strength
• risk distance
• Stop Loss mode
• Stop or BE price
• target R value
• target price
• target status
• Break-Even tick offset

Tooltips are informational chart elements.

They do not represent broker orders.


━━━━━━━━━━━━━━━━━━━━━━
📟 COMPACT PREMIUM DASHBOARD
━━━━━━━━━━━━━━━━━━━━━━

The desktop dashboard is divided into four sections:

STATE

• symbol and timeframe
• active signal and strength
• current trade status
• session status

TRADE

• active Stop Loss mode
• Entry and Stop / Break-Even
• TP1 / TP2 / TP3 scale
• live R

PERFORMANCE

• total trades started
• closed trades
• Win Rate
• NET R
• Average R
• TP1 / TP2 / TP3 hit rates

QUALITY

• latest strength
• Trend component
• Volume component
• Wick component
• Confirmation Candle component
• Pivot Distance component
• Trend Bias
• Break-Even mode
• Minimum Strength

Quality components are displayed in a compact format:

T = Trend
V = Volume
W = Wick
C = Candle
P = Pivot Distance

The dashboard can be positioned at:

• Top Right
• Bottom Right
• Top Left
• Bottom Left


The selected input is translated into a TradingView table position:

[pine]
string dashboardTablePosition =
     dashboardPositionInput == "Top Right" ? position.top_right :
     dashboardPositionInput == "Top Left" ? position.top_left :
     dashboardPositionInput == "Bottom Left" ? position.bottom_left :
     position.bottom_right

if barstate.islast
    table.set_position(
         statisticsTable,
         dashboardTablePosition
    )
[/pine]



━━━━━━━━━━━━━━━━━━━━━━
📊 STATISTICS METHODOLOGY
━━━━━━━━━━━━━━━━━━━━━━

The statistics are produced by the script’s internal bar-based tracker.

They are not imported from a broker.

They are not verified account results.

They are not TradingView Strategy Tester results.

Total Trades Started

Number of accepted signals that opened a tracked trade.

Total Trades Closed

Number of tracked trades closed by:

• Stop Loss
• Break-Even
• TP3
• active-trade replacement

TP1 Hit Rate

TP1 touches divided by Total Trades Started.

TP2 Hit Rate

TP2 touches divided by Total Trades Started.

TP3 Hit Rate

TP3 touches divided by Total Trades Started.

NET R

Sum of all recorded closed-trade R outcomes.

Average R

NET R divided by Total Trades Closed.

Win Rate

Positive-R trades divided by positive-R plus negative-R trades.

Exact 0R Break-Even results are excluded from the Win Rate denominator.

A favorable Break-Even offset can produce a small positive R result and can therefore be classified as a positive-R trade.

Replacement exits use the close of the new signal candle and can contribute partial R.

Statistics depend on:

• loaded chart history
• symbol
• timeframe
• exchange or broker feed
• left and right pivot settings
• Trend Bias
• session setting
• cooldown
• strength threshold
• EMA and volume lengths
• ATR settings
• Stop Loss mode
• target settings
• Break-Even settings
• replacement-signal sequence

Changing any of these inputs can change historical results.


━━━━━━━━━━━━━━━━━━━━━━
🎨 THEME SYSTEM
━━━━━━━━━━━━━━━━━━━━━━

The script includes:

• Auto
• Dark Mode
• Light Mode
• Phone Mode

Auto

Detects the chart background and selects the corresponding light or dark visual palette.

Dark Mode

Uses:

• darker green and red signal colors
• dark dashboard surfaces
• white chart-label text
• dark Entry color
• muted dashboard text
• red brand header

Light Mode

Uses:

• brighter green and red signal colors
• light dashboard surfaces
• dark BUY text where required
• adjusted Entry and dashboard colors
• red brand header

Theme selection changes presentation.

It does not change pivot detection, Signal Strength, trade levels, statistics, or alerts.



━━━━━━━━━━━━━━━━━━━━━━
📱 PHONE MODE
━━━━━━━━━━━━━━━━━━━━━━

Phone Mode is designed for smaller chart areas.

It uses:

• Tiny signal labels
• Tiny active-trade labels
• one-pixel trade-level lines
• dark visual palette
• compact dashboard text
• reduced dashboard rows

The Phone Mode dashboard displays:

• Signal and Strength
• Status
• Win Rate and NET R
• Session

The compact layout intentionally removes most desktop details.

Phone Mode changes presentation only.

It does not change calculations.



━━━━━━━━━━━━━━━━━━━━━━
🚨 ALERT SYSTEM
━━━━━━━━━━━━━━━━━━━━━━

The script includes static TradingView alert conditions for:

• Confirmed BUY
• Confirmed SELL
• Stop Loss Hit
• Break-Even Activated
• Break-Even Hit
• TP1 Hit
• TP2 Hit
• TP3 Hit

Static BUY and SELL messages can include:

• exchange
• ticker
• timeframe
• Signal Strength
• Entry
• Stop
• TP1
• TP2
• TP3

The script also includes dynamic alert() events for:

• BUY signal
• SELL signal
• Stop Loss hit
• Break-Even activation
• Break-Even hit
• TP1 hit
• TP2 hit
• TP3 hit

Dynamic signal messages can include:

• trade_w_samet identifier
• event type
• direction
• symbol
• timeframe
• Signal Strength
• Entry
• Stop
• TP1
• TP2
• TP3
• Stop Loss Mode
• Break-Even Mode
• Trading Session
• session OPEN / CLOSED state

Dynamic trade-management messages preserve the active trade’s stored values before the trade state is reset.

Alert events use once-per-bar-close frequency.


A dynamic signal message is assembled from the stored trade values:

[pine]
string buyEntryAlertMessage =
     "trade_w_samet | Pivot Sniper Method" +
     "\nEvent: BUY SIGNAL" +
     "\nDirection: BUY" +
     "\nSymbol: " + syminfo.tickerid +
     "\nTimeframe: " + timeframe.period +
     "\nStrength: " + str.tostring(buySignalStrength) + "%" +
     "\nEntry: " + str.tostring(activeEntryPrice, format.mintick) +
     "\nSL: " + str.tostring(activeStopPrice, format.mintick) +
     "\nTP1: " + str.tostring(activeTP1Price, format.mintick) +
     "\nTP2: " + str.tostring(activeTP2Price, format.mintick) +
     "\nTP3: " + str.tostring(activeTP3Price, format.mintick)

alert(
     message=buyEntryAlertMessage,
     freq=alert.freq_once_per_bar_close
)
[/pine]


The complete live message also includes Stop Loss Mode, Break-Even Mode, and session context.


Alerts are monitoring tools.

They do not execute or modify broker orders.


━━━━━━━━━━━━━━━━━━━━━━
🔔 HOW TO USE ALERTS
━━━━━━━━━━━━━━━━━━━━━━

For a specific static event:

1. Add Pivot Sniper Method [trade_w_samet] to the chart.
2. Open TradingView’s Create Alert window.
3. Select the indicator as the condition.
4. Select the required BUY, SELL, Stop, Break-Even, TP1, TP2, or TP3 event.
5. Select the notification method.
6. Test the alert before relying on it.

For one combined dynamic workflow:

1. Add the indicator to the chart.
2. Open Create Alert.
3. Select Pivot Sniper Method [trade_w_samet].
4. Select Any alert() function call.
5. Configure the delivery method.
6. Test signal and trade-management messages.

TradingView saves a snapshot of the script, its inputs, and chart context when an alert is created.

After materially changing the script, symbol, timeframe, or inputs, delete and recreate the alert so it uses the intended configuration.


━━━━━━━━━━━━━━━━━━━━━━
🧪 PRACTICAL WORKFLOW
━━━━━━━━━━━━━━━━━━━━━━

A practical review process:

1. Add Pivot Sniper Method [trade_w_samet] to a standard candlestick chart.
2. Select Auto, Dark, Light, or Phone Mode.
3. Start with symmetrical pivot settings.
4. Observe how right-side bars affect confirmation delay.
5. Select Both Trend Bias when studying raw signal behavior.
6. Select Bullish or Bearish when reviewing one direction only.
7. Begin with All Sessions when studying general behavior.
8. Test London, New York, or Custom session filtering.
9. Begin with the default Minimum Signal Strength.
10. Compare signal frequency at higher and lower thresholds.
11. Review the strength percentage below each BUY or SELL label.
12. Use the tooltip to inspect the confirmed pivot price.
13. Compare the five quality components in the dashboard.
14. Select the preferred Stop Loss Mode.
15. Verify that the structural stop is logically positioned.
16. Review the ATR fallback behavior.
17. Set TP1, TP2, and TP3 in increasing order.
18. Select the Break-Even rule.
19. Review when the Entry label disappears and BE replaces it.
20. Observe how new eligible signals replace an active tracked trade.
21. Review Live R and historical NET R.
22. Review failed setups as well as successful setups.
23. Create and test alerts.
24. Define personal position size independently.
25. Account for spread, commission, liquidity, news, and execution conditions.

The indicator is designed for structured study and monitoring.

It should not be treated as an automatic decision-maker.


━━━━━━━━━━━━━━━━━━━━━━
⚙️ SETTINGS REFERENCE
━━━━━━━━━━━━━━━━━━━━━━

📈 Trend Bias

Trend Bias

• Bullish
• Bearish
• Both

━━━━━━━━━━━━━━━━━━━━━━

⚙️ Pivot Settings

Pivot High Left Bars

Default:
10

Pivot High Right Bars

Default:
10

Pivot Low Left Bars

Default:
10

Pivot Low Right Bars

Default:
10

━━━━━━━━━━━━━━━━━━━━━━

🚨 Signal Settings

Show BUY / SELL Signals

Shows or hides signal labels.

Signal Cooldown Bars

Default:
0

━━━━━━━━━━━━━━━━━━━━━━

🕒 Time Filter

Trading Session

• All Sessions
• London
• New York
• London + New York
• Custom

Custom Session

Default:
08:00–17:00

Custom Session Time Zone

• Exchange
• UTC
• Europe/London
• America/New_York
• Europe/Istanbul
• Asia/Tokyo

━━━━━━━━━━━━━━━━━━━━━━

💪 Signal Strength

Enable Signal Strength Filter

Default:
On

Minimum Signal Strength

Default:
55

Show Strength on Signal

Default:
On

Strength Trend Length

Default:
50

Strength Volume Length

Default:
20

━━━━━━━━━━━━━━━━━━━━━━

📦 Trade Levels

Show Active Trade Levels

Default:
On

Stop Loss Mode

• ATR
• Pivot Level
• Pivot + ATR Buffer
• Signal Candle

ATR Length

Default:
14

Stop Loss ATR Multiplier

Default:
2.0

Pivot ATR Buffer

Default:
0.25

TP1 Risk / Reward

Default:
1.0R

TP2 Risk / Reward

Default:
2.0R

TP3 Risk / Reward

Default:
3.0R

Level Projection Bars

Default:
20

━━━━━━━━━━━━━━━━━━━━━━

🟡 Break-Even

Break-Even Mode

• Off
• After TP1
• After TP2

Default:
After TP1

Break-Even Offset Ticks

Default:
0

━━━━━━━━━━━━━━━━━━━━━━

📊 Statistics Dashboard

Show Statistics Dashboard

Default:
On

Dashboard Position

• Top Right
• Bottom Right
• Top Left
• Bottom Left

━━━━━━━━━━━━━━━━━━━━━━

🎨 Visual Settings

Theme Mode

• Auto
• Dark Mode
• Light Mode
• Phone Mode

Label Size

• Tiny
• Small
• Normal
• Large
• Huge

Phone Mode always uses Tiny.

━━━━━━━━━━━━━━━━━━━━━━

🔔 Alert Settings

Enable BUY Alerts

Default:
On

Enable SELL Alerts

Default:
On

Enable Dynamic Alerts

Default:
On

All public input values are hidden from TradingView’s status line to reduce chart-header clutter.


━━━━━━━━━━━━━━━━━━━━━━
🧠 WHAT MAKES THIS SCRIPT ORIGINAL
━━━━━━━━━━━━━━━━━━━━━━

Pivots, ATR, EMA, volume comparison, session filters, risk/reward levels, Break-Even, alerts, and performance statistics are established technical-analysis concepts.

These concepts are not unique by themselves.

The originality of Pivot Sniper Method lies in the coordinated implementation applied to them:

confirmed high and low pivots
→ same-bar directional-conflict rejection
→ Bullish / Bearish / Both permission
→ session filtering
→ cooldown
→ five-part 0–100 quality model
→ minimum-quality acceptance
→ compact two-line BUY / SELL labels
→ confirmation-close Entry
→ four selectable Stop Loss models
→ ATR structural-stop validation fallback
→ independently adjustable TP1 / TP2 / TP3
→ target-state visual updates
→ TP1- or TP2-based Break-Even
→ Entry-to-BE visual replacement
→ active-trade replacement at current close
→ internal partial-R accounting
→ desktop and Phone dashboards
→ theme-aware colors
→ dashboard-corner selection
→ detailed static and dynamic alerts

Distinctive implementation features include:

• using five quality dimensions inside one pivot-reversal workflow
• separating pivot confirmation from Entry timing
• using the original pivot candle for wick quality
• using the later confirmation candle for candle quality and Entry
• applying session control only to new entries
• supporting four Stop Loss construction methods
• validating structural stops and falling back to ATR when required
• removing the Entry visual after Break-Even replaces it
• tracking replacement exits in R
• showing latest quality components in a compact dashboard
• supporting both individual events and one combined dynamic-alert workflow

The script is not a collection of unrelated indicators.

Every component supports the same objective: evaluating and managing a confirmed pivot-reversal setup under explicit, reviewable rules.


━━━━━━━━━━━━━━━━━━━━━━
⚠️ IMPORTANT PRACTICAL NOTES
━━━━━━━━━━━━━━━━━━━━━━

Signal frequency depends on:

• symbol
• timeframe
• data provider
• pivot left and right settings
• Trend Bias
• selected session
• cooldown
• minimum strength
• EMA length
• volume length
• ATR availability
• historical data availability

Higher right-side pivot values increase confirmation delay.

Higher strength thresholds reduce accepted signals.

Session filtering can remove otherwise valid setups.

The strength score is not a probability forecast.

The Trend component is part of the score, not a separate hard trend filter.

The script replaces an active tracked trade when a new eligible signal appears.

The script does not retain completed trade lines historically.

Dashboard statistics use loaded chart history only.

Different exchanges, brokers, and data feeds can produce different:

• highs
• lows
• closes
• pivots
• wick measurements
• volume values
• ATR values
• EMA values
• signals
• stop levels
• target levels
• replacement exits
• historical statistics

Changing available history can change the first eligible setup and later active-trade sequencing.


━━━━━━━━━━━━━━━━━━━━━━
⚠️ LIMITATIONS AND SHORTCOMINGS
━━━━━━━━━━━━━━━━━━━━━━

This script has important limitations.

It does not guarantee profitable trades.
It does not predict future price movement with certainty.
It does not execute orders.
It does not place broker Stop Loss orders.
It does not place broker Take Profit orders.
It does not calculate position size.
It does not calculate account risk.
It does not include spread.
It does not include commission.
It does not include slippage.
It does not include latency.
It does not include swap or financing.
It does not include taxes.
It does not model partial fills.
It does not model order rejection.
It does not model contract specifications.
It does not model tick-by-tick execution.
It uses historical OHLC bars.
It cannot always determine whether Stop or target occurred first inside one candle.
It resolves same-candle ambiguity in favor of the active Stop.
It begins trade-management checks on the candle after Entry.
It requires right-side pivot confirmation.
It cannot identify a confirmed pivot on the original pivot candle.
It can react with delay when larger right-side values are used.
It rejects simultaneous high and low pivot confirmation.
It can reject setups through bias, session, strength, or cooldown rules.
It replaces an active tracked trade when a new eligible signal appears.
A replacement exit can close a trade before its mapped Stop or TP3.
Its Signal Strength is an internal score, not a probability.
Its volume component depends on available volume data.
Its dashboard is not Strategy Tester.
Its statistics are not audited.
Its Win Rate excludes exact 0R Break-Even results.
A positive Break-Even offset can classify a BE hit as positive R.
Its target hit rates use total trades started.
Its statistics depend on loaded chart history.
Changing settings recalculates historical behavior.
Alerts depend on TradingView and user configuration.
Alerts do not guarantee broker execution.



━━━━━━━━━━━━━━━━━━━━━━
👤 WHO THIS SCRIPT MAY BE USEFUL FOR
━━━━━━━━━━━━━━━━━━━━━━

This script may be useful for traders who:

• understand pivot confirmation
• want BUY and SELL signals based on confirmed price pivots
• prefer a quality score instead of equal treatment for every pivot
• want separate Bullish and Bearish direction controls
• want London, New York, or Custom session filtering
• want selectable ATR or structural stops
• want independently adjustable R targets
• want TP1- or TP2-based Break-Even
• want active trade levels on the chart
• want compact tooltips
• want loaded-history R statistics
• want a compact desktop dashboard
• want a reduced Phone Mode
• want detailed TradingView alerts
• understand that historical chart results are not verified execution

It may be less suitable for users who:

• want signals on the original unconfirmed pivot candle
• want no pivot delay
• want tick-level backtesting
• want multiple simultaneous tracked trades
• want new signals ignored while a trade is active
• want historical completed-trade lines preserved
• want automatic broker execution
• want position sizing
• want commission and slippage modeling
• want guaranteed reversal signals
• interpret Signal Strength as win probability
• expect historical Win Rate to continue unchanged


━━━━━━━━━━━━━━━━━━━━━━
🧭 BEST-PRACTICE SUGGESTIONS
━━━━━━━━━━━━━━━━━━━━━━

For studying pivot sensitivity:

• begin with equal high and low pivot settings
• compare smaller and larger left / right values
• remember that right-side values directly affect delay

For studying raw signal behavior:

• use Both Trend Bias
• use All Sessions
• use a moderate minimum strength
• review every accepted BUY and SELL

For directional study:

• use Bullish or Bearish
• compare results separately
• do not assume one direction will remain superior

For session-based review:

• compare All Sessions with London or New York
• use the exchange’s actual liquidity characteristics
• remember that active trades remain managed outside the session

For Signal Strength:

• begin with 55
• compare frequency at 45, 55, and 65
• review the five components
• do not interpret the percentage as guaranteed probability

For risk mapping:

• begin with ATR 14 and 2.0 multiplier
• compare ATR with Pivot Level
• compare Pivot Level with Pivot + ATR Buffer
• maintain logical TP1 < TP2 < TP3 values

For Break-Even:

• compare Off with After TP1
• test After TP2 for wider trade development
• keep the tick offset realistic for the instrument

For chart clarity:

• use Auto for general use
• use Dark or Light when manual control is preferred
• use Phone Mode on smaller screens
• move the dashboard away from important price action
• adjust label size according to chart density

Always:

• wait for confirmed signals
• review broader market structure
• review liquidity and volatility
• review news risk
• define personal account risk
• calculate position size independently
• test the exact symbol, timeframe, and data feed
• inspect failed trades as well as successful trades
• recreate alerts after important configuration changes


━━━━━━━━━━━━━━━━━━━━━━
🔓 PUBLICATION NOTE
━━━━━━━━━━━━━━━━━━━━━━

Pivot Sniper Method [trade_w_samet] is published as an educational pivot-confirmation, signal-quality, session-filtering, risk-mapping, Break-Even, statistics, and alert tool.

The purpose of this description is to explain:

• how pivots are confirmed
• why signals appear after the original pivot
• how BUY and SELL candidates are formed
• how simultaneous pivot conflicts are rejected
• how Trend Bias affects eligibility
• how session filtering affects new entries
• how cooldown affects frequency
• how the five Signal Strength components work
• why Signal Strength is not a probability
• how Entry is defined
• how each Stop Loss Mode works
• how invalid structural stops fall back to ATR
• how TP1, TP2, and TP3 are calculated
• how Break-Even activates
• why Entry disappears after BE becomes active
• how same-candle Stop / target ambiguity is handled
• how active trades are replaced by new eligible signals
• how internal R statistics are calculated
• what the dashboard displays
• how Phone Mode differs
• what alerts include
• what the script does not simulate
• why historical results can change

The script is designed to support structured review.

It does not promise profitable results.

It does not remove market risk.

It does not replace independent analysis.

It does not replace personal risk management.


━━━━━━━━━━━━━━━━━━━━━━
🕒 REPAINTING, BACKPLOTTING, AND TIMING DISCLOSURE
━━━━━━━━━━━━━━━━━━━━━━

Pivot Sniper Method uses confirmed price pivots.

Pivot confirmation requires future candles relative to the original pivot location.

The number of required right-side candles is controlled independently for pivot highs and pivot lows.

The script does not know that a pivot exists on the original pivot candle.

After the required right-side candles complete:

• the pivot becomes confirmed
• the candidate is evaluated
• Signal Strength is calculated
• filters are applied
• the BUY or SELL label can appear on the confirmation candle
• the tracked Entry can open at the confirmation-candle close

The BUY or SELL trade label is not plotted back on the original pivot candle.

The Entry is not backdated.

Signals require confirmed chart bars.

This reduces unfinished current-bar variation.

It does not remove:

• pivot confirmation delay
• differences between historical OHLC and tick sequence
• data-feed differences
• changes caused by settings
• changes caused by loaded history
• market risk

Historical results can change when:

• pivot settings change
• Trend Bias changes
• session settings change
• cooldown changes
• strength settings change
• ATR settings change
• Stop Loss Mode changes
• target settings change
• Break-Even settings change
• symbol changes
• timeframe changes
• exchange or broker feed changes
• available chart history changes

Users should interpret the original pivot price as historical structure and the later BUY / SELL candle as the actual confirmed signal timing.


━━━━━━━━━━━━━━━━━━━━━━
🛡️ DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━

Pivot Sniper Method [trade_w_samet] is provided for educational and informational purposes only.

It does not constitute financial, investment, trading, legal, accounting, or tax advice.

No indicator can guarantee future results.

Markets are uncertain.

Price structure changes.

Volatility changes.

Liquidity changes.

Volume behavior changes.

Session behavior changes.

Historical chart behavior does not ensure future performance.

Every user is responsible for their own:

• analysis
• validation
• symbol selection
• timeframe selection
• pivot settings
• directional bias
• session selection
• quality threshold
• Stop Loss selection
• target planning
• Break-Even selection
• position sizing
• risk management
• alert configuration
• trading decisions
• broker execution
• legal obligations
• tax obligations

The pivots, BUY labels, SELL labels, Signal Strength values, Entry levels, Stop Loss levels, Break-Even levels, TP1 levels, TP2 levels, TP3 levels, active lines, labels, tooltips, dashboard values, Win Rate, NET R, Average R, target hit rates, and alerts are visual analysis tools only.

A confirmed pivot is not a guaranteed reversal.

A high Signal Strength value is not a guaranteed winning trade.

A TP label is not proof of an actual broker fill.

A Stop Loss event is not proof of an actual broker fill.

The dashboard is not verified account performance.

The statistics are not audited.

The script does not include spread, commission, slippage, latency, financing, taxes, partial fills, order rejection, position sizing, account equity, or broker-specific execution.

Use the script as a structured pivot-reversal review, trade-mapping, and monitoring framework—not as a promise of profitability or a substitute for independent judgment.

## Source Code

````pine
// © trade_w_samet

//@version=6
indicator(
     title="Pivot Sniper Method [trade_w_samet]",
     shorttitle="Pivot Sniper Method [trade_w_samet]",
     overlay=true,
     max_labels_count=500,
     max_lines_count=500,
     max_bars_back=5000
)

//==================================================================================================
// INPUT GROUPS
//==================================================================================================

const string GROUP_TREND    = "📈 Trend Bias"
const string GROUP_PIVOTS   = "⚙️ Pivot Settings"
const string GROUP_SIGNALS  = "🚨 Signal Settings"
const string GROUP_TIME     = "🕒 Time Filter"
const string GROUP_STRENGTH = "💪 Signal Strength"
const string GROUP_TRADE    = "📦 Trade Levels"
const string GROUP_BE       = "🟡 Break-Even"
const string GROUP_STATS    = "📊 Statistics Dashboard"
const string GROUP_VISUALS  = "🎨 Visual Settings"
const string GROUP_ALERTS   = "🔔 Alert Settings"

//==================================================================================================
// TREND BIAS
//==================================================================================================

string trendBiasInput = input.string(
     defval="Both",
     title="📈 Trend Bias",
     options=["Bullish", "Bearish", "Both"],
     tooltip="Bullish allows only BUY signals. Bearish allows only SELL signals. Both allows signals in both directions.",
     group=GROUP_TREND,
     display=display.none
)

bool bullishBiasAllowed = trendBiasInput == "Bullish" or trendBiasInput == "Both"
bool bearishBiasAllowed = trendBiasInput == "Bearish" or trendBiasInput == "Both"

//==================================================================================================
// PIVOT SETTINGS
//==================================================================================================

int leftHighInput = input.int(
     defval=10,
     title="🔺 Pivot High Left Bars",
     minval=1,
     maxval=500,
     tooltip="Defines how many candles to the left must have lower highs for a potential pivot high.",
     group=GROUP_PIVOTS,
     display=display.none
)

int rightHighInput = input.int(
     defval=10,
     title="🔺 Pivot High Right Bars",
     minval=1,
     maxval=500,
     tooltip="Defines how many completed candles must form to the right before a pivot high is confirmed.",
     group=GROUP_PIVOTS,
     display=display.none
)

int leftLowInput = input.int(
     defval=10,
     title="🔻 Pivot Low Left Bars",
     minval=1,
     maxval=500,
     tooltip="Defines how many candles to the left must have higher lows for a potential pivot low.",
     group=GROUP_PIVOTS,
     display=display.none
)

int rightLowInput = input.int(
     defval=10,
     title="🔻 Pivot Low Right Bars",
     minval=1,
     maxval=500,
     tooltip="Defines how many completed candles must form to the right before a pivot low is confirmed.",
     group=GROUP_PIVOTS,
     display=display.none
)

//==================================================================================================
// SIGNAL SETTINGS
//==================================================================================================

bool showSignalsInput = input.bool(
     defval=true,
     title="🏷️ Show BUY / SELL Signals",
     tooltip="Displays confirmed BUY and SELL labels. When Signal Strength is enabled, the calculated quality score is shown inside the label.",
     group=GROUP_SIGNALS,
     display=display.none
)

int cooldownInput = input.int(
     defval=0,
     title="⏳ Signal Cooldown Bars",
     minval=0,
     maxval=500,
     tooltip="Defines the minimum number of completed candles required between confirmed signals. Set to 0 to disable the cooldown filter.",
     group=GROUP_SIGNALS,
     display=display.none
)

//==================================================================================================
// TIME FILTER
//==================================================================================================

string timeFilterModeInput = input.string(
     defval="All Sessions",
     title="🕒 Trading Session",
     options=["All Sessions", "London", "New York", "London + New York", "Custom"],
     tooltip="Filters new entries by trading session. Active trades continue to be managed outside the selected session.",
     group=GROUP_TIME,
     display=display.none
)

string customSessionInput = input.session(
     defval="0800-1700",
     title="🗓️ Custom Session",
     tooltip="Custom session used when Trading Session is set to Custom.",
     group=GROUP_TIME,
     display=display.none
)

string customTimezoneInput = input.string(
     defval="Exchange",
     title="🌍 Custom Session Time Zone",
     options=["Exchange", "UTC", "Europe/London", "America/New_York", "Europe/Istanbul", "Asia/Tokyo"],
     tooltip="Time zone used by the Custom session. Exchange uses the symbol's exchange time zone.",
     group=GROUP_TIME,
     display=display.none
)

string customSessionTimezone = customTimezoneInput == "Exchange" ? syminfo.timezone : customTimezoneInput

bool inLondonSession = not na(time(timeframe.period, "0800-1700:1234567", "Europe/London"))
bool inNewYorkSession = not na(time(timeframe.period, "0930-1600:1234567", "America/New_York"))
bool inCustomSession = not na(time(timeframe.period, customSessionInput, customSessionTimezone))

bool timeFilterPassed =
     timeFilterModeInput == "All Sessions" or
     (timeFilterModeInput == "London" and inLondonSession) or
     (timeFilterModeInput == "New York" and inNewYorkSession) or
     (timeFilterModeInput == "London + New York" and (inLondonSession or inNewYorkSession)) or
     (timeFilterModeInput == "Custom" and inCustomSession)

//==================================================================================================
// SIGNAL STRENGTH SETTINGS
//==================================================================================================

bool enableStrengthFilterInput = input.bool(
     defval=true,
     title="💪 Enable Signal Strength Filter",
     tooltip="Requires the calculated signal quality score to meet the Minimum Signal Strength value.",
     group=GROUP_STRENGTH,
     display=display.none
)

int minimumStrengthInput = input.int(
     defval=55,
     title="🎚️ Minimum Signal Strength",
     minval=0,
     maxval=100,
     tooltip="Minimum 0–100 quality score required for a BUY or SELL signal. Lower values produce more signals.",
     group=GROUP_STRENGTH,
     display=display.none
)

bool showStrengthOnSignalInput = input.bool(
     defval=true,
     title="🏷️ Show Strength on Signal",
     tooltip="Displays the calculated quality percentage inside BUY and SELL labels.",
     group=GROUP_STRENGTH,
     display=display.none
)

int strengthTrendLengthInput = input.int(
     defval=50,
     title="📈 Strength Trend Length",
     minval=2,
     maxval=500,
     tooltip="EMA length used by the trend-alignment component of the Signal Strength score.",
     group=GROUP_STRENGTH,
     display=display.none
)

int strengthVolumeLengthInput = input.int(
     defval=20,
     title="📊 Strength Volume Length",
     minval=2,
     maxval=500,
     tooltip="Volume average length used by the participation component of the Signal Strength score.",
     group=GROUP_STRENGTH,
     display=display.none
)

//==================================================================================================
// TRADE LEVEL SETTINGS
//==================================================================================================

bool showTradeLevelsInput = input.bool(
     defval=true,
     title="📦 Show Active Trade Levels",
     tooltip="Shows Entry, Stop Loss, TP1, TP2 and TP3 only while a trade is active.",
     group=GROUP_TRADE,
     display=display.none
)

string stopLossModeInput = input.string(
     defval="ATR",
     title="🛑 Stop Loss Mode",
     options=["ATR", "Pivot Level", "Pivot + ATR Buffer", "Signal Candle"],
     tooltip="ATR uses Entry ± ATR distance. Pivot Level uses the confirmed pivot price. Pivot + ATR Buffer places the stop beyond the pivot. Signal Candle uses the signal candle low for BUY and high for SELL.",
     group=GROUP_TRADE,
     display=display.none
)

int atrLengthInput = input.int(
     defval=14,
     title="📏 ATR Length",
     minval=1,
     maxval=500,
     tooltip="ATR period used by ATR Stop Loss, Pivot Buffer and Signal Strength calculations.",
     group=GROUP_TRADE,
     display=display.none
)

float atrMultiplierInput = input.float(
     defval=1.5,
     title="🛑 Stop Loss ATR Multiplier",
     minval=0.1,
     maxval=20.0,
     step=0.1,
     tooltip="ATR distance used when Stop Loss Mode is ATR. It is also used as a safety fallback when another mode produces an invalid stop.",
     group=GROUP_TRADE,
     display=display.none
)

float pivotBufferATRInput = input.float(
     defval=0.25,
     title="🧱 Pivot ATR Buffer",
     minval=0.0,
     maxval=10.0,
     step=0.05,
     tooltip="ATR buffer placed beyond the confirmed pivot when Stop Loss Mode is Pivot + ATR Buffer.",
     group=GROUP_TRADE,
     display=display.none
)

float tp1RRInput = input.float(
     defval=1.0,
     title="🎯 TP1 Risk / Reward",
     minval=0.1,
     maxval=20.0,
     step=0.1,
     tooltip="Risk / reward multiple used to calculate TP1.",
     group=GROUP_TRADE,
     display=display.none
)

float tp2RRInput = input.float(
     defval=2.0,
     title="🎯 TP2 Risk / Reward",
     minval=0.1,
     maxval=20.0,
     step=0.1,
     tooltip="Risk / reward multiple used to calculate TP2.",
     group=GROUP_TRADE,
     display=display.none
)

float tp3RRInput = input.float(
     defval=3.0,
     title="🎯 TP3 Risk / Reward",
     minval=0.1,
     maxval=20.0,
     step=0.1,
     tooltip="Risk / reward multiple used to calculate TP3. TP3 closes the active trade.",
     group=GROUP_TRADE,
     display=display.none
)

int levelProjectionBarsInput = input.int(
     defval=20,
     title="↔️ Level Projection Bars",
     minval=1,
     maxval=200,
     tooltip="Defines how many candles the active lines and labels project to the right of the current bar.",
     group=GROUP_TRADE,
     display=display.none
)

//==================================================================================================
// BREAK-EVEN SETTINGS
//==================================================================================================

string breakEvenModeInput = input.string(
     defval="After TP1",
     title="🟡 Break-Even Mode",
     options=["Off", "After TP1", "After TP2"],
     tooltip="Moves the active Stop Loss to Entry after the selected target is confirmed. The move occurs after the target candle closes and applies from the next candle.",
     group=GROUP_BE,
     display=display.none
)

int breakEvenOffsetTicksInput = input.int(
     defval=0,
     title="➕ Break-Even Offset Ticks",
     minval=0,
     maxval=10000,
     tooltip="Optional favorable offset from Entry when Stop Loss moves to Break-Even.",
     group=GROUP_BE,
     display=display.none
)

//==================================================================================================
// STATISTICS DASHBOARD SETTINGS
//==================================================================================================

bool showDashboardInput = input.bool(
     defval=true,
     title="📊 Show Statistics Dashboard",
     tooltip="Shows historical trades, win rate, Net R, target hit rates, break-even count and current trade status.",
     group=GROUP_STATS,
     display=display.none
)


string dashboardPositionInput = input.string(
     defval="Bottom Right",
     title="📍 Dashboard Position",
     options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"],
     tooltip="Selects the chart corner where the statistics dashboard is displayed.",
     group=GROUP_STATS,
     display=display.none
)

//==================================================================================================
// VISUAL SETTINGS
//==================================================================================================

string themeModeInput = input.string(
     defval="Auto",
     title="🌓 Theme Mode",
     options=["Auto", "Dark Mode", "Light Mode", "Phone Mode"],
     tooltip="Auto detects the chart background. Phone Mode uses the Dark Mode palette with tiny labels and thinner lines.",
     group=GROUP_VISUALS,
     display=display.none
)


string labelSizeInput = input.string(
     defval="Normal",
     title="🏷️ Label Size",
     options=["Tiny", "Small", "Normal", "Large", "Huge"],
     tooltip="Controls BUY, SELL, Entry, Stop Loss, Break-Even and Take Profit label sizes. Phone Mode always uses Tiny.",
     group=GROUP_VISUALS,
     display=display.none
)

//==================================================================================================
// THEME ENGINE
//==================================================================================================

isLightChartTheme(color backgroundColor = chart.bg_color) =>
    float redValue = color.r(backgroundColor)
    float greenValue = color.g(backgroundColor)
    float blueValue = color.b(backgroundColor)
    float brightness = (redValue + greenValue + blueValue) / (3.0 * 255.0)
    brightness > 0.5

bool detectedLightTheme = isLightChartTheme()
bool usePhoneTheme = themeModeInput == "Phone Mode"

bool useLightTheme =
     themeModeInput == "Light Mode" or
     (themeModeInput == "Auto" and detectedLightTheme)

color bullishColor = useLightTheme ? #00E676 : #007A4D
color bearishColor = useLightTheme ? #FF1744 : #C62828

color buyTextColor = useLightTheme ? color.black : color.white
color sellTextColor = color.white

color stopLineColor = useLightTheme ? #FF1744 : #C62828
color entryLineColor = useLightTheme ? #4B5563 : #374151
color takeProfitLineColor = useLightTheme ? #00C853 : #008A52
color breakEvenColor = useLightTheme ? #FFB300 : #D97706

color dashboardBackgroundColor = useLightTheme ? color.new(#F8FAFC, 2) : color.new(#0B0F16, 2)
color dashboardHeaderColor = useLightTheme ? #E53935 : #B91C1C
color dashboardSectionColor = useLightTheme ? #E5E7EB : #1F2937
color dashboardBorderColor = useLightTheme ? #9CA3AF : #374151
color dashboardTextColor = useLightTheme ? #111827 : color.white
color dashboardMutedTextColor = useLightTheme ? #4B5563 : #9CA3AF
color dashboardWarningColor = useLightTheme ? #D97706 : #F59E0B

string selectedLabelSize =
     labelSizeInput == "Tiny" ? size.tiny :
     labelSizeInput == "Small" ? size.small :
     labelSizeInput == "Large" ? size.large :
     labelSizeInput == "Huge" ? size.huge :
     size.normal

string signalLabelSize = usePhoneTheme ? size.tiny : selectedLabelSize
string tradeLevelLabelSize = usePhoneTheme ? size.tiny : selectedLabelSize
string dashboardTextSize = usePhoneTheme ? size.tiny : size.small
int tradeLevelLineWidth = usePhoneTheme ? 1 : 2


string dashboardTablePosition =
     dashboardPositionInput == "Top Right" ? position.top_right :
     dashboardPositionInput == "Top Left" ? position.top_left :
     dashboardPositionInput == "Bottom Left" ? position.bottom_left :
     position.bottom_right

//==================================================================================================
// ALERT SETTINGS
//==================================================================================================

bool enableBuyAlertsInput = input.bool(
     defval=true,
     title="🟢 Enable BUY Alerts",
     tooltip="Allows confirmed BUY signals to trigger alerts.",
     group=GROUP_ALERTS,
     display=display.none
)

bool enableSellAlertsInput = input.bool(
     defval=true,
     title="🔴 Enable SELL Alerts",
     tooltip="Allows confirmed SELL signals to trigger alerts.",
     group=GROUP_ALERTS,
     display=display.none
)

bool dynamicAlertsInput = input.bool(
     defval=true,
     title="🔔 Enable Dynamic Alerts",
     tooltip="Enables TradingView's Any alert() function call option. Alerts trigger after candle close.",
     group=GROUP_ALERTS,
     display=display.none
)

//==================================================================================================
// CORE CALCULATIONS
//==================================================================================================

float confirmedPivotHigh = ta.pivothigh(high, leftHighInput, rightHighInput)
float confirmedPivotLow = ta.pivotlow(low, leftLowInput, rightLowInput)

float atrValue = ta.atr(atrLengthInput)
float strengthEMA = ta.ema(close, strengthTrendLengthInput)
float strengthVolumeAverage = ta.sma(volume, strengthVolumeLengthInput)

bool rawBuySignal = barstate.isconfirmed and not na(confirmedPivotLow)
bool rawSellSignal = barstate.isconfirmed and not na(confirmedPivotHigh)

bool dualPivotConfirmation = rawBuySignal and rawSellSignal
bool buyCandidate = rawBuySignal and not dualPivotConfirmation
bool sellCandidate = rawSellSignal and not dualPivotConfirmation

//==================================================================================================
// SIGNAL STRENGTH ENGINE — 0 TO 100
//==================================================================================================

float buyPivotRange = buyCandidate ? high[rightLowInput] - low[rightLowInput] : na
float sellPivotRange = sellCandidate ? high[rightHighInput] - low[rightHighInput] : na

float buyLowerWick = buyCandidate ? math.min(open[rightLowInput], close[rightLowInput]) - low[rightLowInput] : na
float sellUpperWick = sellCandidate ? high[rightHighInput] - math.max(open[rightHighInput], close[rightHighInput]) : na

float buyPivotDistanceScore =
     buyCandidate and not na(atrValue) and atrValue > 0.0
     ? math.min(math.max((close - confirmedPivotLow) / atrValue, 0.0), 2.0) / 2.0 * 20.0
     : 0.0

float sellPivotDistanceScore =
     sellCandidate and not na(atrValue) and atrValue > 0.0
     ? math.min(math.max((confirmedPivotHigh - close) / atrValue, 0.0), 2.0) / 2.0 * 20.0
     : 0.0

float buyWickScore =
     buyCandidate and not na(buyPivotRange) and buyPivotRange > 0.0
     ? math.min(math.max(buyLowerWick / buyPivotRange, 0.0), 1.0) * 20.0
     : 0.0

float sellWickScore =
     sellCandidate and not na(sellPivotRange) and sellPivotRange > 0.0
     ? math.min(math.max(sellUpperWick / sellPivotRange, 0.0), 1.0) * 20.0
     : 0.0

float signalCandleRange = high - low
float signalBodyRatio = signalCandleRange > 0.0 ? math.abs(close - open) / signalCandleRange : 0.0

float buyCandleScore =
     buyCandidate
     ? math.min(signalBodyRatio * 15.0 + (close > open ? 5.0 : 0.0), 20.0)
     : 0.0

float sellCandleScore =
     sellCandidate
     ? math.min(signalBodyRatio * 15.0 + (close < open ? 5.0 : 0.0), 20.0)
     : 0.0

bool usableVolume = not na(volume) and not na(strengthVolumeAverage) and strengthVolumeAverage > 0.0

float volumeScore =
     usableVolume
     ? math.min(math.max(volume / strengthVolumeAverage, 0.0) / 1.5, 1.0) * 20.0
     : 10.0

float buyTrendScore =
     buyCandidate
     ? (close > strengthEMA ? 10.0 : 0.0) + (strengthEMA > strengthEMA[1] ? 10.0 : 0.0)
     : 0.0

float sellTrendScore =
     sellCandidate
     ? (close < strengthEMA ? 10.0 : 0.0) + (strengthEMA < strengthEMA[1] ? 10.0 : 0.0)
     : 0.0

int buySignalStrength = int(math.round(
     math.min(
          buyPivotDistanceScore +
          buyWickScore +
          buyCandleScore +
          volumeScore +
          buyTrendScore,
          100.0
     )
))

int sellSignalStrength = int(math.round(
     math.min(
          sellPivotDistanceScore +
          sellWickScore +
          sellCandleScore +
          volumeScore +
          sellTrendScore,
          100.0
     )
))

bool buyStrengthPassed = not enableStrengthFilterInput or buySignalStrength >= minimumStrengthInput
bool sellStrengthPassed = not enableStrengthFilterInput or sellSignalStrength >= minimumStrengthInput

//==================================================================================================
// CONFIRMED SIGNAL ENGINE
//==================================================================================================

var int lastSignalBar = na

bool cooldownReady = na(lastSignalBar) or bar_index - lastSignalBar > cooldownInput

bool buySignal =
     buyCandidate and
     bullishBiasAllowed and
     timeFilterPassed and
     buyStrengthPassed and
     cooldownReady

bool sellSignal =
     sellCandidate and
     bearishBiasAllowed and
     timeFilterPassed and
     sellStrengthPassed and
     cooldownReady

if buySignal or sellSignal
    lastSignalBar := bar_index

//==================================================================================================
// SIGNAL LABELS
//==================================================================================================

if showSignalsInput and buySignal
    string buyLabelText =
         showStrengthOnSignalInput
         ? "▲ BUY\n" + str.tostring(buySignalStrength) + "%"
         : "▲ BUY"

    string buySignalTooltip =
         "Confirmed BUY" +
         "\nStrength: " + str.tostring(buySignalStrength) + "%" +
         "\nPivot: " + str.tostring(confirmedPivotLow, format.mintick)

    label.new(
         x=bar_index,
         y=low,
         text=buyLabelText,
         xloc=xloc.bar_index,
         yloc=yloc.belowbar,
         style=label.style_label_up,
         color=bullishColor,
         textcolor=buyTextColor,
         size=signalLabelSize,
         tooltip=buySignalTooltip
    ,
         text_formatting=text.format_bold + text.format_italic)

if showSignalsInput and sellSignal
    string sellLabelText =
         showStrengthOnSignalInput
         ? "▼ SELL\n" + str.tostring(sellSignalStrength) + "%"
         : "▼ SELL"

    string sellSignalTooltip =
         "Confirmed SELL" +
         "\nStrength: " + str.tostring(sellSignalStrength) + "%" +
         "\nPivot: " + str.tostring(confirmedPivotHigh, format.mintick)

    label.new(
         x=bar_index,
         y=high,
         text=sellLabelText,
         xloc=xloc.bar_index,
         yloc=yloc.abovebar,
         style=label.style_label_down,
         color=bearishColor,
         textcolor=sellTextColor,
         size=signalLabelSize,
         tooltip=sellSignalTooltip
    ,
         text_formatting=text.format_bold + text.format_italic)

//==================================================================================================
// ACTIVE TRADE STATE
//==================================================================================================

var bool activeTrade = false
var int activeTradeDirection = 0
var int activeTradeStartBar = na
var int activeSignalStrength = na

var int latestSignalStrength = na
var float latestTrendComponent = na
var float latestVolumeComponent = na
var float latestWickComponent = na
var float latestCandleComponent = na
var float latestPivotComponent = na

var float activeEntryPrice = na
var float activeOriginalStopPrice = na
var float activeStopPrice = na
var float activeTP1Price = na
var float activeTP2Price = na
var float activeTP3Price = na
var float activeRiskDistance = na

var bool activeTP1Reached = false
var bool activeTP2Reached = false
var bool activeBreakEven = false

var line activeStopLine = na
var line activeEntryLine = na
var line activeTP1Line = na
var line activeTP2Line = na
var line activeTP3Line = na

var label activeStopLabel = na
var label activeEntryLabel = na
var label activeTP1Label = na
var label activeTP2Label = na
var label activeTP3Label = na

//==================================================================================================
// STATISTICS STATE
//==================================================================================================

var int totalTradesStarted = 0
var int totalTradesClosed = 0
var int winningTrades = 0
var int losingTrades = 0
var int breakEvenTrades = 0

var int tp1HitCount = 0
var int tp2HitCount = 0
var int tp3HitCount = 0

var float netR = 0.0

//==================================================================================================
// TRADE EVENTS
//==================================================================================================

bool newTradeRequest = (buySignal or sellSignal) and not na(atrValue)

bool stopLossHitEvent = false
bool breakEvenHitEvent = false
bool breakEvenActivatedEvent = false
bool tp1HitEvent = false
bool tp2HitEvent = false
bool tp3HitEvent = false
bool replacementExitEvent = false

bool closeActiveTradeNow = false
float closedTradeR = na


float alertEventEntryPrice = na
float alertEventStopPrice = na
float alertEventTP1Price = na
float alertEventTP2Price = na
float alertEventTP3Price = na
float alertEventStrength = na
int alertEventDirection = 0

string stopLossDynamicMessage = ""
string breakEvenActivatedDynamicMessage = ""
string breakEvenHitDynamicMessage = ""
string tp1DynamicMessage = ""
string tp2DynamicMessage = ""
string tp3DynamicMessage = ""

//==================================================================================================
// MANAGE CURRENT ACTIVE TRADE
//==================================================================================================

if activeTrade and bar_index > activeTradeStartBar
    bool stopTouched =
         activeTradeDirection == 1
         ? low <= activeStopPrice
         : high >= activeStopPrice

    bool tp1Touched =
         activeTradeDirection == 1
         ? high >= activeTP1Price
         : low <= activeTP1Price

    bool tp2Touched =
         activeTradeDirection == 1
         ? high >= activeTP2Price
         : low <= activeTP2Price

    bool tp3Touched =
         activeTradeDirection == 1
         ? high >= activeTP3Price
         : low <= activeTP3Price

    // Conservative OHLC handling: the active stop has priority when stop and target are touched on the same candle.
    if stopTouched
        if activeBreakEven
            breakEvenHitEvent := true
        else
            stopLossHitEvent := true

        closedTradeR :=
             activeTradeDirection == 1
             ? (activeStopPrice - activeEntryPrice) / activeRiskDistance
             : (activeEntryPrice - activeStopPrice) / activeRiskDistance

        closeActiveTradeNow := true

    else if tp3Touched
        if not activeTP1Reached
            activeTP1Reached := true
            tp1HitEvent := true
            tp1HitCount += 1

        if not activeTP2Reached
            activeTP2Reached := true
            tp2HitEvent := true
            tp2HitCount += 1

        tp3HitEvent := true
        tp3HitCount += 1
        closedTradeR := tp3RRInput
        closeActiveTradeNow := true

    else
        if tp1Touched and not activeTP1Reached
            activeTP1Reached := true
            tp1HitEvent := true
            tp1HitCount += 1

        if tp2Touched and not activeTP2Reached
            activeTP2Reached := true
            tp2HitEvent := true
            tp2HitCount += 1

        bool shouldActivateBreakEven =
             not activeBreakEven and
             (
                  (breakEvenModeInput == "After TP1" and activeTP1Reached) or
                  (breakEvenModeInput == "After TP2" and activeTP2Reached)
             )

        if shouldActivateBreakEven
            float breakEvenOffset = breakEvenOffsetTicksInput * syminfo.mintick

            activeStopPrice :=
                 activeTradeDirection == 1
                 ? activeEntryPrice + breakEvenOffset
                 : activeEntryPrice - breakEvenOffset

            activeBreakEven := true
            breakEvenActivatedEvent := true

//==================================================================================================
// ALERT EVENT SNAPSHOT
//==================================================================================================

bool anyManagedTradeEvent =
     stopLossHitEvent or
     breakEvenHitEvent or
     breakEvenActivatedEvent or
     tp1HitEvent or
     tp2HitEvent or
     tp3HitEvent

if anyManagedTradeEvent
    alertEventEntryPrice := activeEntryPrice
    alertEventStopPrice := activeStopPrice
    alertEventTP1Price := activeTP1Price
    alertEventTP2Price := activeTP2Price
    alertEventTP3Price := activeTP3Price
    alertEventStrength := activeSignalStrength
    alertEventDirection := activeTradeDirection

    string eventDirectionText = alertEventDirection == 1 ? "BUY" : "SELL"
    string eventSessionText = timeFilterModeInput + " / " + (timeFilterPassed ? "OPEN" : "CLOSED")

    string eventTradeDetails =
         "\nDirection: " + eventDirectionText +
         "\nSymbol: " + syminfo.tickerid +
         "\nTimeframe: " + timeframe.period +
         "\nStrength: " + str.tostring(alertEventStrength, "#") + "%" +
         "\nEntry: " + str.tostring(alertEventEntryPrice, format.mintick) +
         "\nSL / BE: " + str.tostring(alertEventStopPrice, format.mintick) +
         "\nTP1: " + str.tostring(alertEventTP1Price, format.mintick) +
         "\nTP2: " + str.tostring(alertEventTP2Price, format.mintick) +
         "\nTP3: " + str.tostring(alertEventTP3Price, format.mintick) +
         "\nSL Mode: " + stopLossModeInput +
         "\nBE Mode: " + breakEvenModeInput +
         "\nSession: " + eventSessionText

    if stopLossHitEvent
        stopLossDynamicMessage :=
             "trade_w_samet | Pivot Sniper Method" +
             "\nEvent: STOP LOSS HIT" +
             eventTradeDetails

    if breakEvenActivatedEvent
        breakEvenActivatedDynamicMessage :=
             "trade_w_samet | Pivot Sniper Method" +
             "\nEvent: BREAK-EVEN ACTIVATED" +
             eventTradeDetails

    if breakEvenHitEvent
        breakEvenHitDynamicMessage :=
             "trade_w_samet | Pivot Sniper Method" +
             "\nEvent: BREAK-EVEN HIT" +
             eventTradeDetails

    if tp1HitEvent
        tp1DynamicMessage :=
             "trade_w_samet | Pivot Sniper Method" +
             "\nEvent: TP1 HIT" +
             eventTradeDetails

    if tp2HitEvent
        tp2DynamicMessage :=
             "trade_w_samet | Pivot Sniper Method" +
             "\nEvent: TP2 HIT" +
             eventTradeDetails

    if tp3HitEvent
        tp3DynamicMessage :=
             "trade_w_samet | Pivot Sniper Method" +
             "\nEvent: TP3 HIT" +
             eventTradeDetails

//==================================================================================================
// REPLACE ACTIVE TRADE WHEN A NEW SIGNAL ARRIVES
//==================================================================================================

if newTradeRequest and activeTrade and not closeActiveTradeNow
    closedTradeR :=
         activeTradeDirection == 1
         ? (close - activeEntryPrice) / activeRiskDistance
         : (activeEntryPrice - close) / activeRiskDistance

    replacementExitEvent := true
    closeActiveTradeNow := true

//==================================================================================================
// FINALIZE CLOSED TRADE
//==================================================================================================

if closeActiveTradeNow
    totalTradesClosed += 1
    netR += closedTradeR

    if closedTradeR > 0.0001
        winningTrades += 1
    else if closedTradeR < -0.0001
        losingTrades += 1
    else
        breakEvenTrades += 1

    if not na(activeStopLine)
        line.delete(activeStopLine)
        activeStopLine := na

    if not na(activeEntryLine)
        line.delete(activeEntryLine)
        activeEntryLine := na

    if not na(activeTP1Line)
        line.delete(activeTP1Line)
        activeTP1Line := na

    if not na(activeTP2Line)
        line.delete(activeTP2Line)
        activeTP2Line := na

    if not na(activeTP3Line)
        line.delete(activeTP3Line)
        activeTP3Line := na

    if not na(activeStopLabel)
        label.delete(activeStopLabel)
        activeStopLabel := na

    if not na(activeEntryLabel)
        label.delete(activeEntryLabel)
        activeEntryLabel := na

    if not na(activeTP1Label)
        label.delete(activeTP1Label)
        activeTP1Label := na

    if not na(activeTP2Label)
        label.delete(activeTP2Label)
        activeTP2Label := na

    if not na(activeTP3Label)
        label.delete(activeTP3Label)
        activeTP3Label := na

    activeTrade := false
    activeTradeDirection := 0
    activeTradeStartBar := na
    activeSignalStrength := na

    activeEntryPrice := na
    activeOriginalStopPrice := na
    activeStopPrice := na
    activeTP1Price := na
    activeTP2Price := na
    activeTP3Price := na
    activeRiskDistance := na

    activeTP1Reached := false
    activeTP2Reached := false
    activeBreakEven := false

//==================================================================================================
// OPEN NEW TRADE
//==================================================================================================

if newTradeRequest
    activeTrade := true
    activeTradeDirection := buySignal ? 1 : -1
    activeTradeStartBar := bar_index
    activeSignalStrength := buySignal ? buySignalStrength : sellSignalStrength

    latestSignalStrength := activeSignalStrength
    latestTrendComponent := buySignal ? buyTrendScore : sellTrendScore
    latestVolumeComponent := volumeScore
    latestWickComponent := buySignal ? buyWickScore : sellWickScore
    latestCandleComponent := buySignal ? buyCandleScore : sellCandleScore
    latestPivotComponent := buySignal ? buyPivotDistanceScore : sellPivotDistanceScore

    activeEntryPrice := close

    float atrFallbackDistance = math.max(atrValue * atrMultiplierInput, syminfo.mintick)
    float requestedStopPrice = na

    if activeTradeDirection == 1
        requestedStopPrice :=
             stopLossModeInput == "ATR"
             ? activeEntryPrice - atrFallbackDistance
             : stopLossModeInput == "Pivot Level"
             ? confirmedPivotLow
             : stopLossModeInput == "Pivot + ATR Buffer"
             ? confirmedPivotLow - atrValue * pivotBufferATRInput
             : low

        bool validBuyStop = not na(requestedStopPrice) and requestedStopPrice < activeEntryPrice - syminfo.mintick
        activeStopPrice := validBuyStop ? requestedStopPrice : activeEntryPrice - atrFallbackDistance

    else
        requestedStopPrice :=
             stopLossModeInput == "ATR"
             ? activeEntryPrice + atrFallbackDistance
             : stopLossModeInput == "Pivot Level"
             ? confirmedPivotHigh
             : stopLossModeInput == "Pivot + ATR Buffer"
             ? confirmedPivotHigh + atrValue * pivotBufferATRInput
             : high

        bool validSellStop = not na(requestedStopPrice) and requestedStopPrice > activeEntryPrice + syminfo.mintick
        activeStopPrice := validSellStop ? requestedStopPrice : activeEntryPrice + atrFallbackDistance

    activeOriginalStopPrice := activeStopPrice
    activeRiskDistance := math.max(math.abs(activeEntryPrice - activeStopPrice), syminfo.mintick)

    activeTP1Price :=
         activeTradeDirection == 1
         ? activeEntryPrice + activeRiskDistance * tp1RRInput
         : activeEntryPrice - activeRiskDistance * tp1RRInput

    activeTP2Price :=
         activeTradeDirection == 1
         ? activeEntryPrice + activeRiskDistance * tp2RRInput
         : activeEntryPrice - activeRiskDistance * tp2RRInput

    activeTP3Price :=
         activeTradeDirection == 1
         ? activeEntryPrice + activeRiskDistance * tp3RRInput
         : activeEntryPrice - activeRiskDistance * tp3RRInput

    activeTP1Reached := false
    activeTP2Reached := false
    activeBreakEven := false

    totalTradesStarted += 1

//==================================================================================================
// ACTIVE TRADE VISUALS
//==================================================================================================

if activeTrade
    if showTradeLevelsInput
        int liveProjectionBar = bar_index + levelProjectionBarsInput

        if na(activeStopLine)
            activeStopLine := line.new(
                 x1=activeTradeStartBar,
                 y1=activeStopPrice,
                 x2=liveProjectionBar,
                 y2=activeStopPrice,
                 xloc=xloc.bar_index,
                 extend=extend.none,
                 color=activeBreakEven ? breakEvenColor : stopLineColor,
                 style=line.style_solid,
                 width=tradeLevelLineWidth
            )

        if not activeBreakEven and na(activeEntryLine)
            activeEntryLine := line.new(
                 x1=activeTradeStartBar,
                 y1=activeEntryPrice,
                 x2=liveProjectionBar,
                 y2=activeEntryPrice,
                 xloc=xloc.bar_index,
                 extend=extend.none,
                 color=entryLineColor,
                 style=line.style_solid,
                 width=tradeLevelLineWidth
            )

        if na(activeTP1Line)
            activeTP1Line := line.new(
                 x1=activeTradeStartBar,
                 y1=activeTP1Price,
                 x2=liveProjectionBar,
                 y2=activeTP1Price,
                 xloc=xloc.bar_index,
                 extend=extend.none,
                 color=takeProfitLineColor,
                 style=line.style_dashed,
                 width=tradeLevelLineWidth
            )

        if na(activeTP2Line)
            activeTP2Line := line.new(
                 x1=activeTradeStartBar,
                 y1=activeTP2Price,
                 x2=liveProjectionBar,
                 y2=activeTP2Price,
                 xloc=xloc.bar_index,
                 extend=extend.none,
                 color=takeProfitLineColor,
                 style=line.style_dashed,
                 width=tradeLevelLineWidth
            )

        if na(activeTP3Line)
            activeTP3Line := line.new(
                 x1=activeTradeStartBar,
                 y1=activeTP3Price,
                 x2=liveProjectionBar,
                 y2=activeTP3Price,
                 xloc=xloc.bar_index,
                 extend=extend.none,
                 color=takeProfitLineColor,
                 style=line.style_dashed,
                 width=tradeLevelLineWidth
            )

        string stopLabelText =
             activeBreakEven
             ? "🟡 BE  |  " + str.tostring(activeStopPrice, format.mintick)
             : "🛑 SL  |  " + str.tostring(activeStopPrice, format.mintick)

        string tp1LabelText =
             activeTP1Reached
             ? "✅ TP1  |  " + str.tostring(activeTP1Price, format.mintick)
             : "🎯 TP1  |  " + str.tostring(activeTP1Price, format.mintick)

        string tp2LabelText =
             activeTP2Reached
             ? "✅ TP2  |  " + str.tostring(activeTP2Price, format.mintick)
             : "🎯 TP2  |  " + str.tostring(activeTP2Price, format.mintick)

        string stopTooltipText =
             activeBreakEven
             ? "Break-Even Stop" +
               "\nPrice: " + str.tostring(activeStopPrice, format.mintick) +
               "\nOffset: " + str.tostring(breakEvenOffsetTicksInput) + " ticks"
             : "Stop Loss" +
               "\nMode: " + stopLossModeInput +
               "\nPrice: " + str.tostring(activeStopPrice, format.mintick)

        string entryTooltipText =
             "Entry Price" +
             "\nStrength: " + str.tostring(activeSignalStrength) + "%" +
             "\nRisk: " + str.tostring(activeRiskDistance, format.mintick)

        string tp1TooltipText =
             "TP1 • " + str.tostring(tp1RRInput, "#.##") + "R" +
             "\nPrice: " + str.tostring(activeTP1Price, format.mintick) +
             "\nStatus: " + (activeTP1Reached ? "HIT" : "PENDING")

        string tp2TooltipText =
             "TP2 • " + str.tostring(tp2RRInput, "#.##") + "R" +
             "\nPrice: " + str.tostring(activeTP2Price, format.mintick) +
             "\nStatus: " + (activeTP2Reached ? "HIT" : "PENDING")

        string tp3TooltipText =
             "TP3 • " + str.tostring(tp3RRInput, "#.##") + "R" +
             "\nPrice: " + str.tostring(activeTP3Price, format.mintick) +
             "\nFinal target"

        if na(activeStopLabel)
            activeStopLabel := label.new(
                 x=liveProjectionBar,
                 y=activeStopPrice,
                 text=stopLabelText,
                 xloc=xloc.bar_index,
                 yloc=yloc.price,
                 style=label.style_label_left,
                 color=activeBreakEven ? breakEvenColor : stopLineColor,
                 textcolor=color.white,
                 size=tradeLevelLabelSize,
                 tooltip=stopTooltipText
            ,
                 text_formatting=text.format_bold + text.format_italic)

        if not activeBreakEven and na(activeEntryLabel)
            activeEntryLabel := label.new(
                 x=liveProjectionBar,
                 y=activeEntryPrice,
                 text="⚪ ENTRY  |  " + str.tostring(activeEntryPrice, format.mintick),
                 xloc=xloc.bar_index,
                 yloc=yloc.price,
                 style=label.style_label_left,
                 color=entryLineColor,
                 textcolor=color.white,
                 size=tradeLevelLabelSize,
                 tooltip=entryTooltipText
            ,
                 text_formatting=text.format_bold + text.format_italic)

        if na(activeTP1Label)
            activeTP1Label := label.new(
                 x=liveProjectionBar,
                 y=activeTP1Price,
                 text=tp1LabelText,
                 xloc=xloc.bar_index,
                 yloc=yloc.price,
                 style=label.style_label_left,
                 color=takeProfitLineColor,
                 textcolor=color.white,
                 size=tradeLevelLabelSize,
                 tooltip=tp1TooltipText
            ,
                 text_formatting=text.format_bold + text.format_italic)

        if na(activeTP2Label)
            activeTP2Label := label.new(
                 x=liveProjectionBar,
                 y=activeTP2Price,
                 text=tp2LabelText,
                 xloc=xloc.bar_index,
                 yloc=yloc.price,
                 style=label.style_label_left,
                 color=takeProfitLineColor,
                 textcolor=color.white,
                 size=tradeLevelLabelSize,
                 tooltip=tp2TooltipText
            ,
                 text_formatting=text.format_bold + text.format_italic)

        if na(activeTP3Label)
            activeTP3Label := label.new(
                 x=liveProjectionBar,
                 y=activeTP3Price,
                 text="🎯 TP3  |  " + str.tostring(activeTP3Price, format.mintick),
                 xloc=xloc.bar_index,
                 yloc=yloc.price,
                 style=label.style_label_left,
                 color=takeProfitLineColor,
                 textcolor=color.white,
                 size=tradeLevelLabelSize,
                 tooltip=tp3TooltipText
            ,
                 text_formatting=text.format_bold + text.format_italic)

        line.set_xy1(activeStopLine, activeTradeStartBar, activeStopPrice)
        line.set_xy2(activeStopLine, liveProjectionBar, activeStopPrice)
        line.set_color(activeStopLine, activeBreakEven ? breakEvenColor : stopLineColor)

        if activeBreakEven
            if not na(activeEntryLine)
                line.delete(activeEntryLine)
                activeEntryLine := na

            if not na(activeEntryLabel)
                label.delete(activeEntryLabel)
                activeEntryLabel := na
        else
            if not na(activeEntryLine)
                line.set_xy1(activeEntryLine, activeTradeStartBar, activeEntryPrice)
                line.set_xy2(activeEntryLine, liveProjectionBar, activeEntryPrice)

        line.set_xy1(activeTP1Line, activeTradeStartBar, activeTP1Price)
        line.set_xy2(activeTP1Line, liveProjectionBar, activeTP1Price)
        line.set_color(activeTP1Line, activeTP1Reached ? color.new(takeProfitLineColor, 60) : takeProfitLineColor)

        line.set_xy1(activeTP2Line, activeTradeStartBar, activeTP2Price)
        line.set_xy2(activeTP2Line, liveProjectionBar, activeTP2Price)
        line.set_color(activeTP2Line, activeTP2Reached ? color.new(takeProfitLineColor, 60) : takeProfitLineColor)

        line.set_xy1(activeTP3Line, activeTradeStartBar, activeTP3Price)
        line.set_xy2(activeTP3Line, liveProjectionBar, activeTP3Price)

        label.set_xy(activeStopLabel, liveProjectionBar, activeStopPrice)
        label.set_text(activeStopLabel, stopLabelText)
        label.set_text_formatting(activeStopLabel, text.format_bold + text.format_italic)
        label.set_color(activeStopLabel, activeBreakEven ? breakEvenColor : stopLineColor)
        label.set_tooltip(activeStopLabel, stopTooltipText)

        if not activeBreakEven and not na(activeEntryLabel)
            label.set_xy(activeEntryLabel, liveProjectionBar, activeEntryPrice)
            label.set_text(activeEntryLabel, "⚪ ENTRY  |  " + str.tostring(activeEntryPrice, format.mintick))
            label.set_text_formatting(activeEntryLabel, text.format_bold + text.format_italic)
            label.set_tooltip(activeEntryLabel, entryTooltipText)

        label.set_xy(activeTP1Label, liveProjectionBar, activeTP1Price)
        label.set_text(activeTP1Label, tp1LabelText)
        label.set_text_formatting(activeTP1Label, text.format_bold + text.format_italic)
        label.set_color(activeTP1Label, activeTP1Reached ? color.new(takeProfitLineColor, 35) : takeProfitLineColor)
        label.set_tooltip(activeTP1Label, tp1TooltipText)

        label.set_xy(activeTP2Label, liveProjectionBar, activeTP2Price)
        label.set_text(activeTP2Label, tp2LabelText)
        label.set_text_formatting(activeTP2Label, text.format_bold + text.format_italic)
        label.set_color(activeTP2Label, activeTP2Reached ? color.new(takeProfitLineColor, 35) : takeProfitLineColor)
        label.set_tooltip(activeTP2Label, tp2TooltipText)

        label.set_xy(activeTP3Label, liveProjectionBar, activeTP3Price)
        label.set_text(activeTP3Label, "🎯 TP3  |  " + str.tostring(activeTP3Price, format.mintick))
        label.set_text_formatting(activeTP3Label, text.format_bold + text.format_italic)
        label.set_tooltip(activeTP3Label, tp3TooltipText)

    else
        if not na(activeStopLine)
            line.delete(activeStopLine)
            activeStopLine := na

        if not na(activeEntryLine)
            line.delete(activeEntryLine)
            activeEntryLine := na

        if not na(activeTP1Line)
            line.delete(activeTP1Line)
            activeTP1Line := na

        if not na(activeTP2Line)
            line.delete(activeTP2Line)
            activeTP2Line := na

        if not na(activeTP3Line)
            line.delete(activeTP3Line)
            activeTP3Line := na

        if not na(activeStopLabel)
            label.delete(activeStopLabel)
            activeStopLabel := na

        if not na(activeEntryLabel)
            label.delete(activeEntryLabel)
            activeEntryLabel := na

        if not na(activeTP1Label)
            label.delete(activeTP1Label)
            activeTP1Label := na

        if not na(activeTP2Label)
            label.delete(activeTP2Label)
            activeTP2Label := na

        if not na(activeTP3Label)
            label.delete(activeTP3Label)
            activeTP3Label := na

//==================================================================================================
// COMPACT PREMIUM STATISTICS DASHBOARD
//==================================================================================================

var table statisticsTable = table.new(
     position.bottom_right,
     2,
     15,
     frame_color=dashboardBorderColor,
     frame_width=1,
     border_color=dashboardBorderColor,
     border_width=1
)

if barstate.islast
    table.set_position(statisticsTable, dashboardTablePosition)
    table.clear(statisticsTable, 0, 0, 1, 14)

    if showDashboardInput
        int decisiveTrades = winningTrades + losingTrades

        float winRate =
             decisiveTrades > 0
             ? winningTrades * 100.0 / decisiveTrades
             : 0.0

        float averageR =
             totalTradesClosed > 0
             ? netR / totalTradesClosed
             : 0.0

        float tp1HitRate =
             totalTradesStarted > 0
             ? tp1HitCount * 100.0 / totalTradesStarted
             : 0.0

        float tp2HitRate =
             totalTradesStarted > 0
             ? tp2HitCount * 100.0 / totalTradesStarted
             : 0.0

        float tp3HitRate =
             totalTradesStarted > 0
             ? tp3HitCount * 100.0 / totalTradesStarted
             : 0.0

        float liveR =
             activeTrade and activeRiskDistance > 0.0
             ? (
                  activeTradeDirection == 1
                  ? (close - activeEntryPrice) / activeRiskDistance
                  : (activeEntryPrice - close) / activeRiskDistance
             )
             : 0.0

        string netRText = (netR > 0.0 ? "+" : "") + str.tostring(netR, "#.##") + "R"
        string averageRText = (averageR > 0.0 ? "+" : "") + str.tostring(averageR, "#.##") + "R"
        string liveRText = activeTrade ? (liveR > 0.0 ? "+" : "") + str.tostring(liveR, "#.##") + "R" : "—"

        string dashboardSignal =
             activeTrade
             ? activeTradeDirection == 1 ? "▲ BUY" : "▼ SELL"
             : "—"

        int dashboardStrengthValue =
             activeTrade
             ? activeSignalStrength
             : latestSignalStrength

        string dashboardStrengthText =
             not na(dashboardStrengthValue)
             ? str.tostring(dashboardStrengthValue) + "%"
             : "—"

        string dashboardStatus =
             activeTrade
             ? (
                  activeBreakEven
                  ? "BE ACTIVE"
                  : activeTP2Reached
                  ? "TP2 HIT"
                  : activeTP1Reached
                  ? "TP1 HIT"
                  : "ACTIVE"
             )
             : timeFilterPassed
             ? "READY"
             : "SESSION CLOSED"

        string dashboardSessionStatus = timeFilterPassed ? "OPEN" : "CLOSED"

        string dashboardStopText =
             activeTrade
             ? (
                  activeBreakEven
                  ? "BE " + str.tostring(activeStopPrice, format.mintick)
                  : str.tostring(activeStopPrice, format.mintick)
             )
             : "—"

        string dashboardTPScale =
             str.tostring(tp1RRInput, "#.##") +
             "/" +
             str.tostring(tp2RRInput, "#.##") +
             "/" +
             str.tostring(tp3RRInput, "#.##")

        string dashboardTPHits =
             str.tostring(tp1HitRate, "#") +
             "/" +
             str.tostring(tp2HitRate, "#") +
             "/" +
             str.tostring(tp3HitRate, "#") +
             "%"

        string dashboardQualityText =
             "T" + str.tostring(nz(latestTrendComponent, 0.0), "#") +
             " V" + str.tostring(nz(latestVolumeComponent, 0.0), "#") +
             " W" + str.tostring(nz(latestWickComponent, 0.0), "#") +
             " C" + str.tostring(nz(latestCandleComponent, 0.0), "#") +
             " P" + str.tostring(nz(latestPivotComponent, 0.0), "#")

        color dashboardSignalColor =
             activeTrade
             ? activeTradeDirection == 1 ? bullishColor : bearishColor
             : dashboardMutedTextColor

        color dashboardStatusColor =
             activeTrade
             ? activeBreakEven
             ? breakEvenColor
             : activeTradeDirection == 1
             ? bullishColor
             : bearishColor
             : timeFilterPassed
             ? bullishColor
             : bearishColor

        color dashboardStrengthColor =
             not na(dashboardStrengthValue) and dashboardStrengthValue >= minimumStrengthInput
             ? bullishColor
             : dashboardWarningColor

        if usePhoneTheme
            table.cell(
                 statisticsTable,
                 0,
                 0,
                 "PIVOT SNIPER",
                 bgcolor=dashboardHeaderColor,
                 text_color=color.white,
                 text_size=dashboardTextSize,
                 text_halign=text.align_left,
                 text_formatting=text.format_bold + text.format_italic
            )

            table.cell(
                 statisticsTable,
                 1,
                 0,
                 "trade_w_samet",
                 bgcolor=dashboardHeaderColor,
                 text_color=color.white,
                 text_size=dashboardTextSize,
                 text_halign=text.align_right,
                 text_formatting=text.format_bold + text.format_italic
            )

            table.cell(statisticsTable, 0, 1, "SIGNAL", bgcolor=dashboardBackgroundColor, text_color=dashboardTextColor, text_size=dashboardTextSize, text_halign=text.align_left, text_formatting=text.format_bold + text.format_italic)
            table.cell(statisticsTable, 1, 1, dashboardSignal + " " + dashboardStrengthText, bgcolor=dashboardBackgroundColor, text_color=dashboardSignalColor, text_size=dashboardTextSize, text_halign=text.align_right, text_formatting=text.format_bold + text.format_italic)

            table.cell(statisticsTable, 0, 2, "STATUS", bgcolor=dashboardBackgroundColor, text_color=dashboardTextColor, text_size=dashboardTextSize, text_halign=text.align_left, text_formatting=text.format_bold + text.format_italic)
            table.cell(statisticsTable, 1, 2, dashboardStatus, bgcolor=dashboardBackgroundColor, text_color=dashboardStatusColor, text_size=dashboardTextSize, text_halign=text.align_right, text_formatting=text.format_bold + text.format_italic)

            table.cell(statisticsTable, 0, 3, "WR / NET R", bgcolor=dashboardBackgroundColor, text_color=dashboardTextColor, text_size=dashboardTextSize, text_halign=text.align_left, text_formatting=text.format_bold + text.format_italic)
            table.cell(statisticsTable, 1, 3, str.tostring(winRate, "#.0") + "% / " + netRText, bgcolor=dashboardBackgroundColor, text_color=netR >= 0.0 ? bullishColor : bearishColor, text_size=dashboardTextSize, text_halign=text.align_right, text_formatting=text.format_bold + text.format_italic)

            table.cell(statisticsTable, 0, 4, "SESSION", bgcolor=dashboardBackgroundColor, text_color=dashboardTextColor, text_size=dashboardTextSize, text_halign=text.align_left, text_formatting=text.format_bold + text.format_italic)
            table.cell(statisticsTable, 1, 4, dashboardSessionStatus, bgcolor=dashboardBackgroundColor, text_color=timeFilterPassed ? bullishColor : bearishColor, text_size=dashboardTextSize, text_halign=text.align_right, text_formatting=text.format_bold + text.format_italic)

        else
            table.cell(statisticsTable, 0, 0, "PIVOT SNIPER", bgcolor=dashboardHeaderColor, text_color=color.white, text_size=dashboardTextSize, text_halign=text.align_left, text_formatting=text.format_bold + text.format_italic)
            table.cell(statisticsTable, 1, 0, "trade_w_samet", bgcolor=dashboardHeaderColor, text_color=color.white, text_size=dashboardTextSize, text_halign=text.align_right, text_formatting=text.format_bold + text.format_italic)

            table.cell(statisticsTable, 0, 1, "STATE", bgcolor=dashboardSectionColor, text_color=dashboardTextColor, text_size=dashboardTextSize, text_halign=text.align_left, text_formatting=text.format_bold + text.format_italic)
            table.cell(statisticsTable, 1, 1, syminfo.ticker + " • " + timeframe.period, bgcolor=dashboardSectionColor, text_color=dashboardMutedTextColor, text_size=dashboardTextSize, text_halign=text.align_right, text_formatting=text.format_bold + text.format_italic)

            table.cell(statisticsTable, 0, 2, "Signal / Strength", bgcolor=dashboardBackgroundColor, text_color=dashboardMutedTextColor, text_size=dashboardTextSize, text_halign=text.align_left, text_formatting=text.format_bold + text.format_italic)
            table.cell(statisticsTable, 1, 2, dashboardSignal + " • " + dashboardStrengthText, bgcolor=dashboardBackgroundColor, text_color=dashboardSignalColor, text_size=dashboardTextSize, text_halign=text.align_right, text_formatting=text.format_bold + text.format_italic)

            table.cell(statisticsTable, 0, 3, "Status / Session", bgcolor=dashboardBackgroundColor, text_color=dashboardMutedTextColor, text_size=dashboardTextSize, text_halign=text.align_left, text_formatting=text.format_bold + text.format_italic)
            table.cell(statisticsTable, 1, 3, dashboardStatus + " • " + dashboardSessionStatus, bgcolor=dashboardBackgroundColor, text_color=dashboardStatusColor, text_size=dashboardTextSize, text_halign=text.align_right, text_formatting=text.format_bold + text.format_italic)

            table.cell(statisticsTable, 0, 4, "TRADE", bgcolor=dashboardSectionColor, text_color=dashboardTextColor, text_size=dashboardTextSize, text_halign=text.align_left, text_formatting=text.format_bold + text.format_italic)
            table.cell(statisticsTable, 1, 4, stopLossModeInput, bgcolor=dashboardSectionColor, text_color=dashboardMutedTextColor, text_size=dashboardTextSize, text_halign=text.align_right, text_formatting=text.format_bold + text.format_italic)

            table.cell(statisticsTable, 0, 5, "Entry / Stop", bgcolor=dashboardBackgroundColor, text_color=dashboardMutedTextColor, text_size=dashboardTextSize, text_halign=text.align_left, text_formatting=text.format_bold + text.format_italic)
            table.cell(statisticsTable, 1, 5, activeTrade ? str.tostring(activeEntryPrice, format.mintick) + " / " + dashboardStopText : "—", bgcolor=dashboardBackgroundColor, text_color=activeBreakEven ? breakEvenColor : dashboardTextColor, text_size=dashboardTextSize, text_halign=text.align_right, text_formatting=text.format_bold + text.format_italic)

            table.cell(statisticsTable, 0, 6, "TP Scale / Live R", bgcolor=dashboardBackgroundColor, text_color=dashboardMutedTextColor, text_size=dashboardTextSize, text_halign=text.align_left, text_formatting=text.format_bold + text.format_italic)
            table.cell(statisticsTable, 1, 6, dashboardTPScale + " • " + liveRText, bgcolor=dashboardBackgroundColor, text_color=liveR >= 0.0 ? bullishColor : bearishColor, text_size=dashboardTextSize, text_halign=text.align_right, text_formatting=text.format_bold + text.format_italic)

            table.cell(statisticsTable, 0, 7, "PERFORMANCE", bgcolor=dashboardSectionColor, text_color=dashboardTextColor, text_size=dashboardTextSize, text_halign=text.align_left, text_formatting=text.format_bold + text.format_italic)
            table.cell(statisticsTable, 1, 7, str.tostring(totalTradesClosed) + " closed", bgcolor=dashboardSectionColor, text_color=dashboardMutedTextColor, text_size=dashboardTextSize, text_halign=text.align_right, text_formatting=text.format_bold + text.format_italic)

            table.cell(statisticsTable, 0, 8, "Trades / Win Rate", bgcolor=dashboardBackgroundColor, text_color=dashboardMutedTextColor, text_size=dashboardTextSize, text_halign=text.align_left, text_formatting=text.format_bold + text.format_italic)
            table.cell(statisticsTable, 1, 8, str.tostring(totalTradesStarted) + " / " + str.tostring(winRate, "#.0") + "%", bgcolor=dashboardBackgroundColor, text_color=winRate >= 50.0 ? bullishColor : bearishColor, text_size=dashboardTextSize, text_halign=text.align_right, text_formatting=text.format_bold + text.format_italic)

            table.cell(statisticsTable, 0, 9, "Net R / Avg R", bgcolor=dashboardBackgroundColor, text_color=dashboardMutedTextColor, text_size=dashboardTextSize, text_halign=text.align_left, text_formatting=text.format_bold + text.format_italic)
            table.cell(statisticsTable, 1, 9, netRText + " / " + averageRText, bgcolor=dashboardBackgroundColor, text_color=netR >= 0.0 ? bullishColor : bearishColor, text_size=dashboardTextSize, text_halign=text.align_right, text_formatting=text.format_bold + text.format_italic)

            table.cell(statisticsTable, 0, 10, "TP1 / TP2 / TP3", bgcolor=dashboardBackgroundColor, text_color=dashboardMutedTextColor, text_size=dashboardTextSize, text_halign=text.align_left, text_formatting=text.format_bold + text.format_italic)
            table.cell(statisticsTable, 1, 10, dashboardTPHits, bgcolor=dashboardBackgroundColor, text_color=takeProfitLineColor, text_size=dashboardTextSize, text_halign=text.align_right, text_formatting=text.format_bold + text.format_italic)

            table.cell(statisticsTable, 0, 11, "QUALITY", bgcolor=dashboardSectionColor, text_color=dashboardTextColor, text_size=dashboardTextSize, text_halign=text.align_left, text_formatting=text.format_bold + text.format_italic)
            table.cell(statisticsTable, 1, 11, dashboardStrengthText, bgcolor=dashboardSectionColor, text_color=dashboardStrengthColor, text_size=dashboardTextSize, text_halign=text.align_right, text_formatting=text.format_bold + text.format_italic)

            table.cell(statisticsTable, 0, 12, "T / V / W / C / P", bgcolor=dashboardBackgroundColor, text_color=dashboardMutedTextColor, text_size=dashboardTextSize, text_halign=text.align_left, text_formatting=text.format_bold + text.format_italic)
            table.cell(statisticsTable, 1, 12, dashboardQualityText, bgcolor=dashboardBackgroundColor, text_color=dashboardTextColor, text_size=dashboardTextSize, text_halign=text.align_right, text_formatting=text.format_bold + text.format_italic)

            table.cell(statisticsTable, 0, 13, "Bias / BE", bgcolor=dashboardBackgroundColor, text_color=dashboardMutedTextColor, text_size=dashboardTextSize, text_halign=text.align_left, text_formatting=text.format_bold + text.format_italic)
            table.cell(statisticsTable, 1, 13, trendBiasInput + " / " + breakEvenModeInput, bgcolor=dashboardBackgroundColor, text_color=breakEvenModeInput == "Off" ? dashboardTextColor : breakEvenColor, text_size=dashboardTextSize, text_halign=text.align_right, text_formatting=text.format_bold + text.format_italic)

            table.cell(statisticsTable, 0, 14, "Min Strength", bgcolor=dashboardBackgroundColor, text_color=dashboardMutedTextColor, text_size=dashboardTextSize, text_halign=text.align_left, text_formatting=text.format_bold + text.format_italic)
            table.cell(statisticsTable, 1, 14, enableStrengthFilterInput ? str.tostring(minimumStrengthInput) + "%" : "OFF", bgcolor=dashboardBackgroundColor, text_color=dashboardStrengthColor, text_size=dashboardTextSize, text_halign=text.align_right, text_formatting=text.format_bold + text.format_italic)

//==================================================================================================
// HIDDEN OUTPUTS
//==================================================================================================

float signalOutput =
     buySignal ? 1.0 :
     sellSignal ? -1.0 :
     0.0

plot(
     series=signalOutput,
     title="Signal Output",
     display=display.none
)

plot(
     series=buySignal ? buySignalStrength : sellSignal ? sellSignalStrength : na,
     title="Signal Strength Output",
     display=display.none
)


bool anyAlertEvent =
     stopLossHitEvent or
     breakEvenActivatedEvent or
     breakEvenHitEvent or
     tp1HitEvent or
     tp2HitEvent or
     tp3HitEvent

float alertEntryOutput =
     anyAlertEvent
     ? alertEventEntryPrice
     : (buySignal or sellSignal)
     ? activeEntryPrice
     : na

float alertStopOutput =
     anyAlertEvent
     ? alertEventStopPrice
     : (buySignal or sellSignal)
     ? activeStopPrice
     : na

float alertTP1Output =
     anyAlertEvent
     ? alertEventTP1Price
     : (buySignal or sellSignal)
     ? activeTP1Price
     : na

float alertTP2Output =
     anyAlertEvent
     ? alertEventTP2Price
     : (buySignal or sellSignal)
     ? activeTP2Price
     : na

float alertTP3Output =
     anyAlertEvent
     ? alertEventTP3Price
     : (buySignal or sellSignal)
     ? activeTP3Price
     : na

float alertStrengthOutput =
     anyAlertEvent
     ? alertEventStrength
     : buySignal
     ? buySignalStrength
     : sellSignal
     ? sellSignalStrength
     : na

plot(series=alertEntryOutput, title="Alert Entry", display=display.none)
plot(series=alertStopOutput, title="Alert Stop", display=display.none)
plot(series=alertTP1Output, title="Alert TP1", display=display.none)
plot(series=alertTP2Output, title="Alert TP2", display=display.none)
plot(series=alertTP3Output, title="Alert TP3", display=display.none)
plot(series=alertStrengthOutput, title="Alert Strength", display=display.none)

//==================================================================================================
// STATIC ALERT CONDITIONS
//==================================================================================================

alertcondition(
     condition=enableBuyAlertsInput and buySignal,
     title="trade_w_samet — Confirmed BUY Alert",
     message="trade_w_samet | Pivot Sniper Method | BUY | {{exchange}}:{{ticker}} | {{interval}} | Strength: {{plot(\"Alert Strength\")}}% | Entry: {{plot(\"Alert Entry\")}} | SL: {{plot(\"Alert Stop\")}} | TP1: {{plot(\"Alert TP1\")}} | TP2: {{plot(\"Alert TP2\")}} | TP3: {{plot(\"Alert TP3\")}}"
)

alertcondition(
     condition=enableSellAlertsInput and sellSignal,
     title="trade_w_samet — Confirmed SELL Alert",
     message="trade_w_samet | Pivot Sniper Method | SELL | {{exchange}}:{{ticker}} | {{interval}} | Strength: {{plot(\"Alert Strength\")}}% | Entry: {{plot(\"Alert Entry\")}} | SL: {{plot(\"Alert Stop\")}} | TP1: {{plot(\"Alert TP1\")}} | TP2: {{plot(\"Alert TP2\")}} | TP3: {{plot(\"Alert TP3\")}}"
)

alertcondition(
     condition=stopLossHitEvent,
     title="trade_w_samet — Stop Loss Hit",
     message="trade_w_samet | Pivot Sniper Method | STOP LOSS HIT | {{exchange}}:{{ticker}} | {{interval}} | Entry: {{plot(\"Alert Entry\")}} | Stop: {{plot(\"Alert Stop\")}}"
)

alertcondition(
     condition=breakEvenActivatedEvent,
     title="trade_w_samet — Break-Even Activated",
     message="trade_w_samet | Pivot Sniper Method | BREAK-EVEN ACTIVATED | {{exchange}}:{{ticker}} | {{interval}} | Entry: {{plot(\"Alert Entry\")}} | BE: {{plot(\"Alert Stop\")}}"
)

alertcondition(
     condition=breakEvenHitEvent,
     title="trade_w_samet — Break-Even Hit",
     message="trade_w_samet | Pivot Sniper Method | BREAK-EVEN HIT | {{exchange}}:{{ticker}} | {{interval}} | Entry: {{plot(\"Alert Entry\")}} | BE: {{plot(\"Alert Stop\")}}"
)

alertcondition(
     condition=tp1HitEvent,
     title="trade_w_samet — TP1 Hit",
     message="trade_w_samet | Pivot Sniper Method | TP1 HIT | {{exchange}}:{{ticker}} | {{interval}} | Entry: {{plot(\"Alert Entry\")}} | TP1: {{plot(\"Alert TP1\")}} | Current Stop: {{plot(\"Alert Stop\")}}"
)

alertcondition(
     condition=tp2HitEvent,
     title="trade_w_samet — TP2 Hit",
     message="trade_w_samet | Pivot Sniper Method | TP2 HIT | {{exchange}}:{{ticker}} | {{interval}} | Entry: {{plot(\"Alert Entry\")}} | TP2: {{plot(\"Alert TP2\")}} | Current Stop: {{plot(\"Alert Stop\")}}"
)

alertcondition(
     condition=tp3HitEvent,
     title="trade_w_samet — TP3 Hit",
     message="trade_w_samet | Pivot Sniper Method | TP3 HIT | {{exchange}}:{{ticker}} | {{interval}} | Entry: {{plot(\"Alert Entry\")}} | TP3: {{plot(\"Alert TP3\")}}"
)

//==================================================================================================
// DYNAMIC ALERTS — ANY ALERT() FUNCTION CALL
//==================================================================================================

if dynamicAlertsInput and enableBuyAlertsInput and buySignal
    string buyEntryAlertMessage =
         "trade_w_samet | Pivot Sniper Method" +
         "\nEvent: BUY SIGNAL" +
         "\nDirection: BUY" +
         "\nSymbol: " + syminfo.tickerid +
         "\nTimeframe: " + timeframe.period +
         "\nStrength: " + str.tostring(buySignalStrength) + "%" +
         "\nEntry: " + str.tostring(activeEntryPrice, format.mintick) +
         "\nSL: " + str.tostring(activeStopPrice, format.mintick) +
         "\nTP1: " + str.tostring(activeTP1Price, format.mintick) +
         "\nTP2: " + str.tostring(activeTP2Price, format.mintick) +
         "\nTP3: " + str.tostring(activeTP3Price, format.mintick) +
         "\nSL Mode: " + stopLossModeInput +
         "\nBE Mode: " + breakEvenModeInput +
         "\nSession: " + timeFilterModeInput + " / " + (timeFilterPassed ? "OPEN" : "CLOSED")

    alert(
         message=buyEntryAlertMessage,
         freq=alert.freq_once_per_bar_close
    )

if dynamicAlertsInput and enableSellAlertsInput and sellSignal
    string sellEntryAlertMessage =
         "trade_w_samet | Pivot Sniper Method" +
         "\nEvent: SELL SIGNAL" +
         "\nDirection: SELL" +
         "\nSymbol: " + syminfo.tickerid +
         "\nTimeframe: " + timeframe.period +
         "\nStrength: " + str.tostring(sellSignalStrength) + "%" +
         "\nEntry: " + str.tostring(activeEntryPrice, format.mintick) +
         "\nSL: " + str.tostring(activeStopPrice, format.mintick) +
         "\nTP1: " + str.tostring(activeTP1Price, format.mintick) +
         "\nTP2: " + str.tostring(activeTP2Price, format.mintick) +
         "\nTP3: " + str.tostring(activeTP3Price, format.mintick) +
         "\nSL Mode: " + stopLossModeInput +
         "\nBE Mode: " + breakEvenModeInput +
         "\nSession: " + timeFilterModeInput + " / " + (timeFilterPassed ? "OPEN" : "CLOSED")

    alert(
         message=sellEntryAlertMessage,
         freq=alert.freq_once_per_bar_close
    )

if dynamicAlertsInput and stopLossHitEvent
    alert(
         message=stopLossDynamicMessage,
         freq=alert.freq_once_per_bar_close
    )

if dynamicAlertsInput and breakEvenActivatedEvent
    alert(
         message=breakEvenActivatedDynamicMessage,
         freq=alert.freq_once_per_bar_close
    )

if dynamicAlertsInput and breakEvenHitEvent
    alert(
         message=breakEvenHitDynamicMessage,
         freq=alert.freq_once_per_bar_close
    )

if dynamicAlertsInput and tp1HitEvent
    alert(
         message=tp1DynamicMessage,
         freq=alert.freq_once_per_bar_close
    )

if dynamicAlertsInput and tp2HitEvent
    alert(
         message=tp2DynamicMessage,
         freq=alert.freq_once_per_bar_close
    )

if dynamicAlertsInput and tp3HitEvent
    alert(
         message=tp3DynamicMessage,
         freq=alert.freq_once_per_bar_close
    )
````
