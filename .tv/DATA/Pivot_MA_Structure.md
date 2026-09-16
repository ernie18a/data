<!-- tradingview-pine-id: PUB;610ded6ad56243e19167326f255af29e -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Pivot MA Structure

Source: https://www.tradingview.com/script/oybOc30F-Pivot-MA-Structure/

## Description

Pivot MA Structure— Complete User Guide

1. General Purpose
This indicator combines several independent market-reading components into one framework:

Pivot-controlled directional moving averages
Bullish and Bearish market-structure shifts
Pre-break structure candidates
Trend-continuation markers
Shift-direction MA retests
Anchored VWAP equilibrium
RSI 50 equilibrium
Fair Value Gaps and breakers
Long/Short health scores
A real-time information dashboard
Selectable alerts
It is an indicator, not an automated strategy. It does not place orders, calculate position size, or automatically manage stop-loss and take-profit orders.

Its primary objective is to answer five questions:

What is the latest structural direction?
Which directional Pivot MA is currently active?
Do structure and the active MA agree?
Do VWAP and RSI support the same direction?
Is there a suitable continuation or retest location for entry?
2. The Core Reading Model
The indicator separates market information into three layers.

Structural layer
This layer detects:

Bullish Shift
Bearish Shift
Bullish continuation
Bearish continuation
Unbroken bullish and bearish candidates
A Shift represents a change in the direction of confirmed structure breaks.

Directional MA layer
This layer determines whether the active moving-average condition is:

Bullish
Bearish
Ghost/inactive
Still waiting for a valid pivot
Only one directional MA can be active at a time.

Confirmation layer
The following secondary filters measure the quality of the directional condition:

Anchored VWAP
RSI relative to 50
Fair Value Gaps
Directional MA retests
Health score
A structural signal does not automatically imply that all confirmation filters agree.

3. Pivot Moving Average System
Default settings
MA type: EMA
MA length: 50
Pivot strength: 5
Pivot qualification: All Confirmed Pivots
Source: Pivot Side
The MA type can be changed to:

EMA
SMA
WMA
RMA
HMA
Pivot Side source
When MA Source = Pivot Side:

The bullish MA is calculated from low.
The bearish MA is calculated from high.
This creates two distinct directional averages:

Green MA for bullish conditions
Red MA for bearish conditions
If Close or HL2 is selected, both averages use the selected common source.

How a Pivot MA is created
A bullish Pivot MA becomes available after a qualifying confirmed low pivot.

A bearish Pivot MA becomes available after a qualifying confirmed high pivot.

The pivot does not become known immediately. With Pivot Strength set to 5, the system requires five bars on the right side of the pivot before confirming it.

Therefore, pivot activation is intentionally delayed.

Pivot Qualification
All Confirmed Pivots
This is the default mode.

Every confirmed low pivot can refresh the bullish MA state.
Every confirmed high pivot can refresh the bearish MA state.
This allows higher lows in an uptrend to reactivate the bullish side and lower highs in a downtrend to refresh the bearish side.

HH / LL Only
This is a more selective mode.

A bearish MA trigger requires a pivot high above the previous pivot high.
A bullish MA trigger requires a pivot low below the previous pivot low.
This mode generates fewer MA refresh events and may leave an MA in ghost mode for longer.

4. Active and Ghost MA Logic
Active bullish MA
The bullish MA is eligible to become active when:

The bullish MA exists.
It has not remained locked by an unresolved break.
Price is at or above the bullish MA.
The bullish MA is rising.
Active bearish MA
The bearish MA is eligible when:

The bearish MA exists.
It has not remained locked by an unresolved break.
Price is at or below the bearish MA.
The bearish MA is falling.
One active MA at a time
The indicator does not allow both MAs to be active simultaneously.

If only the bullish side is eligible:

Bullish MA becomes active.
Bearish MA becomes ghost.
If only the bearish side is eligible:

Bearish MA becomes active.
Bullish MA becomes ghost.
If neither side is eligible:

Both lines can appear as ghost lines.
If both sides are technically eligible during compression:

A new bearish pivot or downward bar movement gives priority to the bearish MA.
Otherwise, the bullish MA receives priority.
Active line thickness
The active directional MA is always displayed one step thicker than a ghost MA.

This allows the currently accepted directional condition to be identified visually without relying only on color.

Ghost lines
A ghost line is a faded directional MA.

Ghost status means that the MA still exists and is still calculated, but it is not currently accepted as the active directional condition.

A ghost line is not frozen. Its value continues to move because the underlying MA calculation continues.

MA break behavior
The bullish MA is broken when price crosses below it according to the selected break confirmation.

The bearish MA is broken when price crosses above it.

The break method can be:

Close: requires the closing price to cross the MA.
Wick: reacts to the bar’s low or high crossing the MA.
After a genuine break, the line becomes ghosted. A new qualifying same-side pivot can reset its broken state.

5. Market Structure Engine
Default structure length
Structure Length: 12
The engine uses an odd-length fractal model. An even input is internally advanced to the next odd number.

Therefore:

Input 12 becomes an internal 13-bar fractal.
Pivot strength becomes 6 bars on each side.
This is different from using 12 left bars and 12 right bars. It is a full fractal-window interpretation.

Confirmed structure pivots
The engine continuously tracks:

Latest confirmed fractal high
Latest confirmed fractal low
These become potential break candidates.

A structure pivot appears only after its required right-side bars have completed.

6. Candidate Lines
Bullish Break Candidate
A confirmed fractal high creates a bullish break candidate.

It is displayed as:

Green dotted line
Bullish Break Candidate text above the line
This level represents the price that must be exceeded for an upward structure break.

Bearish Break Candidate
A confirmed fractal low creates a bearish break candidate.

It is displayed as:

Red dotted line
Bearish Break Candidate text below the line
This level represents the price that must be broken for a downward structure break.

Candidate projection
The default projection is five bars to the right.

The candidate does not extend infinitely. On every new bar:

Its right endpoint moves forward.
It remains five bars ahead of the current bar.
It stops when broken or replaced by a newer same-side pivot.
Candidate replacement
When a newer confirmed pivot of the same side appears:

The previous unbroken candidate is deleted.
A new candidate begins from the newer pivot.
This ensures that the chart emphasizes the latest actionable structure level.

7. Bullish and Bearish Shift Logic
The internal logic follows a CHoCH-style direction-change model, but the chart does not display the word “CHoCH.”

It uses:

Bullish Shift
Bearish Shift
Bullish Shift
A Bullish Shift occurs when:

The last confirmed structure break was downward.
Price subsequently breaks the latest unbroken fractal high.
The break can be confirmed by:

Close above the level, or
Wick above the level
depending on the selected Break Confirmation.

When confirmed:

The candidate line ends at the breakout bar.
The line becomes a stronger green dotted shift segment.
Bullish Shift appears above the middle of the segment.
The dashboard’s Latest Shift changes to Bullish Shift.
The bullish retest detector becomes armed.
Bearish Shift
A Bearish Shift occurs when:

The last confirmed structure break was upward.
Price subsequently breaks the latest unbroken fractal low.
When confirmed:

The candidate line ends at the breakdown bar.
It becomes a stronger red dotted shift segment.
Bearish Shift appears below the middle of the line.
The dashboard changes to Bearish Shift.
The bearish retest detector becomes armed.
First structure break
The first break establishes the initial direction.

Because no previous opposite break exists, it is not classified as a Shift.

It is treated as a continuation break and receives a directional triangle.

8. Trend-Continuation Triangles
The indicator does not draw BOS lines.

Instead, a same-direction continuation break is marked directly on the breaking candle.

Bullish continuation
A bullish continuation is shown as:

Green upward triangle
Located below the breakout candle
It means that an upward break occurred without reversing the previous break direction.

Bearish continuation
A bearish continuation is shown as:

Red downward triangle
Located above the breakdown candle
It means that a downward break occurred without reversing the previous break direction.

How to interpret continuation marks
Continuation triangles are not fresh reversal signals.

They are better interpreted as confirmation that the existing structural direction is continuing.

A continuation marker is generally more useful when:

The matching directional MA is active.
Price is on the correct side of VWAP.
RSI supports the same direction.
The breakout is not entering directly into an opposing FVG or major swing level.
Avoid treating every continuation triangle as an automatic market entry. Entering immediately after an extended breakout can create poor risk-to-reward.

9. Directional MA Retest — “R” Marker
Important definition
In the current version, the R marker detects a retest of the same-direction Pivot MA, not the horizontal dotted shift line.

After a Bullish Shift:

The indicator monitors the green bullish Pivot MA.
After a Bearish Shift:

It monitors the red bearish Pivot MA.
Bullish retest
After a Bullish Shift, the retest detector waits for a later candle whose range intersects the green bullish MA:

Candle low is at or below the MA.
Candle high is at or above the MA.
When the first valid touch occurs:

A green R appears below the candle.
The bullish retest alert can trigger.
The retest detector stops waiting until a new Shift occurs.
The green line can be active or ghost. The retest detector only requires the corresponding bullish MA to exist.

Bearish retest
After a Bearish Shift, the first later candle that intersects the red bearish MA produces:

A red R
Located above the candle
A bearish retest alert opportunity
Why an R may not appear
An R will not appear when:

No valid Bullish or Bearish Shift has occurred.
The contact happens on the Shift candle itself.
The candle does not actually intersect the MA value.
The first retest after that Shift has already been marked.
A new opposite Shift replaced the previous retest direction.
The corresponding directional MA does not yet exist.
Show Directional MA Retests is disabled.
The visual toggle does not disable the underlying alert calculation.

10. Anchored VWAP Equilibrium
Default status
The VWAP line is enabled by default.

Available anchors
Session
Week
Month
Session
The VWAP resets with the daily/session boundary.

Week
The VWAP resets at the beginning of each week.

Month
The VWAP resets at the beginning of each month.

Horizontal VWAP presentation
The indicator does not plot the entire conventional curved VWAP history.

Instead, it takes the latest anchored VWAP value and displays it as a horizontal equilibrium reference.

Default presentation:

100 bars to the left
10 bars to the right
VWAP label on the right
Dashed neutral-colored line
The right-side length and label offset are adjustable.

Bullish interpretation
Price above VWAP suggests that current price is trading above the volume-weighted equilibrium.

This supports a bullish setup.

Bearish interpretation
Price below VWAP suggests that price is trading below the volume-weighted equilibrium.

This supports a bearish setup.

VWAP as a trade-management filter
For an existing long:

Remaining above VWAP supports the health of the position.
Losing VWAP removes one bullish health point.
Reclaiming VWAP can restore that point.
For an existing short:

Remaining below VWAP supports the bearish condition.
Moving above VWAP weakens the short health score.
VWAP alone is not an entry or exit signal. It is an equilibrium filter.

11. RSI 50 Price Equilibrium
Default settings
RSI Length: 14
RSI line: enabled
Midpoint: 50
HUD interpretation
RSI at or above 50 is bullish.
RSI below 50 is bearish.
Horizontal RSI 50 price line
A literal RSI value of 50 cannot be plotted meaningfully on the same price scale as BTC, forex, or commodities.

Therefore, the indicator stores the closing price where RSI most recently crossed 50.

That price becomes the RSI 50 horizontal equilibrium level.

It represents the latest price associated with a momentum-regime transition.

The line:

Is green when the current RSI is above 50.
Is red when the current RSI is below 50.
Extends a configurable number of bars left and right.
Has an offset label on the right.
Practical use
For a long position:

RSI above 50 supports positive momentum.
RSI falling below 50 reduces long health.
For a short position:

RSI below 50 supports negative momentum.
RSI reclaiming 50 reduces short health.
RSI 50 should be used as confirmation, not as a standalone trigger.

12. Fair Value Gap Engine
The FVG engine is enabled by default.

It supports:

Standard FVG mode
Breaker mode
Bullish and bearish zones
ATR threshold filtering
Multiple mitigation methods
Overlap filtering
Midlines
Optional right extension
Optional raid tracking
Bullish FVG
A bullish FVG is created when the current low is above the high from two bars earlier, producing a three-candle imbalance.

The engine also applies the selected ATR threshold to filter insignificant gaps.

A bullish FVG is normally interpreted as:

An imbalance below price
A possible pullback support area
A potential location for bullish continuation or mitigation
Bearish FVG
A bearish FVG is created when the current high is below the low from two bars earlier.

It is generally interpreted as:

An imbalance above price
A possible resistance area
A potential bearish pullback or mitigation location
Show Last
Show Last determines how many recent bullish and bearish FVGs are displayed.

With a value of 5, the engine can show:

Five recent bullish zones
Five recent bearish zones
subject to mitigation and overlap removal.

Threshold
The threshold applies an ATR-based significance filter.

A value of 0 accepts all qualifying gaps.
Higher values require a stronger displacement relative to ATR.
Increasing the threshold generally produces fewer but more significant FVGs.

Mitigation modes
Close
Uses the candle body boundary as the mitigation trigger.

For a bullish FVG, the body must penetrate below the relevant lower boundary.

For a bearish FVG, the body must penetrate above the relevant upper boundary.

Wick
Uses the candle’s full high/low range.

This is the most sensitive mitigation method.

Avg
Uses the midpoint of the gap.

This treats a move through the FVG’s average price as mitigation.

FVG mode
In standard FVG mode:

The zone remains visible while active.
It is removed when the selected mitigation condition is satisfied.
Breakers mode
In Breakers mode:

The original FVG is tracked.
When mitigated, it becomes a breaker.
Its directional display changes to the opposite-side color.
It remains until the breaker’s opposite invalidation condition occurs.
Hide Overlap
When enabled, overlapping FVGs are filtered.

The newest FVG is compared against:

Older FVGs in the same direction
FVGs in the opposite direction
Overlapping stored zones can be removed to reduce visual clutter.

Midline
When enabled, the midpoint of each FVG is displayed.

The midpoint can be useful as:

A partial mitigation level
A mean-reversion reference
A refined entry or invalidation location
Extend FVG
When disabled, FVG drawings end at the current bar.

When enabled, active FVG zones extend to the right.

Display Raids
Raid tracking looks for liquidity interactions around an active FVG.

For a bullish FVG, it can track a move below the upper FVG boundary followed by a close back above it.

For a bearish FVG, it can track a move above the lower boundary followed by a close back below it.

Raid locations are displayed with a line and an x marker.

13. Information HUD
The information table summarizes the indicator’s current state.

Latest Shift
Possible values:

Bullish Shift
Bearish Shift
Waiting
This row stores the most recent genuine opposite-direction structure break.

It does not reset to neutral after a few bars. It remains bullish or bearish until an opposite Shift occurs.

Bullish Pivot MA
Possible values:

Waiting
Active
Ghost
Waiting
No qualifying bullish pivot has created the bullish MA state yet.

Active
The bullish MA currently satisfies the directional activation logic.

Ghost
The bullish MA exists but is not currently accepted as active.

Bearish Pivot MA
Uses the same status definitions for the red bearish MA.

Shift + MA
Possible values:

Bullish Match
Bearish Match
No Match
Bullish Match
Requires:

Latest Shift is bullish.
Bullish Pivot MA is active.
Bearish Match
Requires:

Latest Shift is bearish.
Bearish Pivot MA is active.
No Match
Structure and the active directional MA do not currently agree.

This is a warning that the setup lacks core confluence.

VWAP
Possible values:

Price Above
Price Below
Unavailable
This reports the current price’s relationship with the selected anchored VWAP.

RSI
Displays:

Current RSI value
Above 50 or Below 50
Example:

56.4 / Above 50

Long Health
The long score counts currently satisfied bullish conditions.

Short Health
The short score counts currently satisfied bearish conditions.

Composite Bias
Possible values:

Bullish
Bearish
Balanced
The result is determined by comparing Long Health with Short Health.

Long Health greater than Short Health → Bullish
Short Health greater than Long Health → Bearish
Equal values → Balanced
Composite Bias is a comparison of rule counts, not a forecast.

14. Health Score Calculation
With all default score filters enabled, each side has four factors.

Long Health factors
One point is awarded for each condition:

Latest Shift is Bullish.
Bullish Pivot MA is active.
Price is above VWAP.
RSI is at or above 50.
Short Health factors
One point is awarded for each condition:

Latest Shift is Bearish.
Bearish Pivot MA is active.
Price is below VWAP.
RSI is below 50.
Score examples
100% — 4/4
All directional conditions agree.

This is the strongest confluence state produced by the dashboard.

It does not mean the trade has a 100% probability of success.

75% — 3/4
The setup is directionally favorable, but one filter disagrees.

Examples:

Bullish Shift and bullish MA are aligned, but RSI is below 50.
Bearish structure is aligned, but price is still above VWAP.
50% — 2/4
The condition is mixed.

This often occurs during:

Transition
Consolidation
Pullback
Delayed confirmation
Conflict between structure and momentum
25% — 1/4
Only one filter supports the direction.

This is generally a weak environment for initiating a new position.

0% — 0/4
None of the directional filters support that side.

Disabling score filters
If VWAP is removed from the score, the denominator decreases.

If RSI is also removed, only two core factors remain:

Shift direction
Active directional MA
The displayed percentage automatically adjusts to the number of enabled factors.

Important limitation
Health is a confluence percentage, not a statistically measured win probability.

A 100% Long Health reading means four out of four programmed bullish conditions are true. It does not mean the market has a 100% chance of rising.

15. Suggested Long Entry Framework
Core long condition
The preferred long environment is:

Latest Shift = Bullish Shift
Bullish Pivot MA = Active
Shift + MA = Bullish Match
This is the minimum structural and directional agreement.

Additional confirmation
A higher-quality long condition may also include:

Price above VWAP
RSI above 50
Long Health at 75% or 100%
Bullish FVG below or around the entry
No large bearish FVG immediately above
A green R retest marker
Aggressive long entry
An aggressive trader may enter near the Bullish Shift breakout.

Risks:

The breakout may be extended.
Stop distance may be large.
Price may return to the broken structure or MA before continuing.
Conservative long entry
A more conservative sequence is:

Bullish Shift appears.
Bullish MA becomes active or remains directionally valid.
Price stays above or reclaims VWAP.
RSI remains above or reclaims 50.
Price pulls back into the green MA.
A green R appears.
The retest candle shows rejection or closes constructively.
This avoids chasing the initial breakout.

Continuation entry
A green triangle can support a continuation entry when:

The dashboard already has bullish alignment.
Price is not excessively extended above the MA.
The continuation break has room before the next bearish FVG or swing resistance.
A triangle by itself is not enough.

16. Suggested Short Entry Framework
Core short condition
The preferred short environment is:

Latest Shift = Bearish Shift
Bearish Pivot MA = Active
Shift + MA = Bearish Match
Additional confirmation
A higher-quality short may include:

Price below VWAP
RSI below 50
Short Health at 75% or 100%
Bearish FVG above or near the entry
No major bullish FVG immediately below
A red R retest marker
Conservative short entry
A conservative bearish sequence is:

Bearish Shift appears.
Bearish Pivot MA becomes active.
Price remains below or rejects VWAP.
RSI remains below 50.
Price rallies back into the red MA.
A red R appears.
The retest candle rejects the MA or closes bearishly.
17. How to Stay in a Position
Staying in a long
A long remains structurally healthier while:

Latest Shift remains bullish.
Bullish Pivot MA remains active.
Price remains above VWAP.
RSI remains above 50.
Long Health remains at 75% or 100%.
Bullish FVGs below price continue to act as support.
No Bearish Shift is created.
Early long weakness
Potential deterioration begins when:

RSI falls below 50.
Price falls below VWAP.
Bullish MA becomes ghost.
Long Health falls from 100% to 75% or 50%.
One lost factor is not necessarily an exit. It is a warning that confluence is decreasing.

Strong long invalidation
More serious invalidation can include:

Bearish Shift
Bearish Match
Bullish MA break
Price remaining below VWAP
RSI remaining below 50
Bullish FVG support being fully mitigated
Staying in a short
A short remains healthier while:

Latest Shift remains bearish.
Bearish MA remains active.
Price remains below VWAP.
RSI remains below 50.
Short Health remains high.
Bearish FVGs above price act as resistance.
No Bullish Shift appears.
Strong short invalidation
Potential invalidation includes:

Bullish Shift
Bullish Match
Bearish MA break
Sustained price above VWAP
RSI above 50
Bearish FVG resistance being invalidated
18. Stop-Loss and Profit Management
The indicator does not place stops or targets.

Possible stop references include:

For long trades
Below the retest candle low
Below the latest confirmed swing low
Below the bullish FVG
Below the bullish MA with an ATR buffer
Below the structure level that would invalidate the setup
For short trades
Above the retest candle high
Above the latest swing high
Above the bearish FVG
Above the bearish MA with an ATR buffer
Possible profit references
Previous swing high/low
Opposing FVG
Major VWAP deviation area
Fixed risk-to-reward target
Partial exit at 1R and trailing remainder
Opposite Shift
Health score deterioration
Stops should not be moved farther away simply to avoid accepting a loss.

19. Alerts
The script provides selectable conditions for:

Bullish Shift Created
Bearish Shift Created
Bullish Directional MA Retest
Bearish Directional MA Retest
Bullish Pivot MA Broken
Bearish Pivot MA Broken
Bullish Shift + Bullish MA alignment
Bearish Shift + Bearish MA alignment
Alert toggles
The shift and retest alerts have individual enable/disable inputs.

These settings control whether the corresponding alert condition can trigger.

Important TradingView behavior
Enabling an alert condition in the indicator settings does not automatically create a TradingView alert.

You must still:

Open TradingView’s alert dialog.
Select the indicator.
Select the desired alert condition.
Choose the frequency.
Create the alert.
For confirmed signals, using Once Per Bar Close is generally the most consistent choice.

20. Repainting and Confirmation Considerations
Pivot delay
Confirmed pivots require future right-side bars.

This means:

Pivot signals are delayed.
Once confirmed, the historical pivot itself is stable.
The indicator does not know a pivot at the exact moment the pivot bar first forms.
Bar-close confirmation
Confirm Signals On Bar Close is enabled by default.

This reduces intrabar signal changes for:

MA breaks
Structure breaks
Shift creation
Retests
Intrabar movement
The current MA, VWAP, RSI, and live candidate values may still visually move while the current candle is forming.

Using bar-close confirmation does not freeze the current bar’s underlying price calculations.

FVG evolution
FVGs can disappear when:

Mitigated
Invalidated
Removed by overlap filtering
Excluded by the Show Last setting
This is normal lifecycle behavior, not necessarily historical repainting.

21. Practical Decision Hierarchy
A disciplined way to use the indicator is:

Step 1 — Identify structure
Check Latest Shift.

Bullish Shift → prioritize long ideas.
Bearish Shift → prioritize short ideas.
Waiting → insufficient shift history.
Step 2 — Confirm the directional MA
Check Shift + MA.

Bullish Match → bullish structure and MA agree.
Bearish Match → bearish structure and MA agree.
No Match → wait or reduce conviction.
Step 3 — Check equilibrium
For longs:

Prefer price above VWAP.
Prefer RSI above 50.
For shorts:

Prefer price below VWAP.
Prefer RSI below 50.
Step 4 — Check location
Use:

Directional MA retest
FVG support/resistance
Recent swing levels
VWAP
A good directional idea entered at a poor location can still have poor risk-to-reward.

Step 5 — Check health
75–100%: favorable confluence
50%: mixed
0–25%: weak for that direction
Step 6 — Define invalidation before entry
Determine:

Stop level
Position size
Maximum acceptable loss
First target
Conditions for partial or full exit
Disclaimer
This indicator is provided for informational, educational, and analytical purposes only. It does not constitute financial advice, investment advice, trading advice, a solicitation, or a recommendation to buy or sell any financial instrument.

Market-structure shifts, moving averages, VWAP, RSI, Fair Value Gaps, retest markers, continuation symbols, health scores, and alerts are mathematical interpretations of historical and real-time market data. They do not guarantee future price movement or profitable outcomes.

The Health Score is a count of aligned indicator conditions. It is not a probability of success, an expected return, or a measure of actual trade risk.

Trading cryptocurrencies, forex, commodities, futures, CFDs, and other leveraged products involves substantial risk and may result in the loss of some or all invested capital. Historical performance does not guarantee future results. Signals may be delayed because of pivot confirmation, and real-time values may change before a candle closes.

Always perform independent analysis, use appropriate position sizing, define a stop-loss before entering a trade, account for fees and slippage, and never risk capital you cannot afford to lose. The user remains solely responsible for all trading and investment decisions.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ MPL-2.0
//@version=6
indicator("Pivot MA Structure", "Pivot MA Structure", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500, calc_bars_count = 10000)

// --- Constants ---
const color BULL_COLOR = #089981
const color BEAR_COLOR = #f23645
const color NEUTRAL_COLOR = #5b9cf6
const float RSI_MIDLINE = 50.0
const string GROUP_PIVOT_MA = "Pivot Moving Averages"
const string GROUP_STRUCTURE = "Market Structure"
const string GROUP_VWAP = "VWAP Equilibrium"
const string GROUP_RSI = "RSI Equilibrium"
const string GROUP_HUD = "Dashboard"
const string GROUP_STYLE = "Style"
const string GROUP_ALERTS = "Alerts"
const string GROUP_FVG = "Fair Value Gap"
const string TOOLTIP_MA_LENGTH = "Number of bars used by the selected moving-average calculation."
const string TOOLTIP_PIVOT_STRENGTH = "Bars required on both sides of a pivot. A pivot is confirmed only after this many right-side bars, so signals are intentionally delayed."
const string TOOLTIP_QUALIFICATION = "HH / LL Only starts bearish MAs from higher highs and bullish MAs from lower lows. All Confirmed Pivots uses every confirmed swing high and swing low."
const string TOOLTIP_GHOST = "After price breaks a pivot MA, its line remains visible with increased transparency until another qualifying pivot of the same direction is confirmed."
const string TOOLTIP_STRUCTURE = "Full fractal length used by the candidate-to-broken structure model. Even values are internally advanced to the next odd value. Only opposite-direction breaks are reported as Bullish Shift or Bearish Shift."
const string TOOLTIP_VWAP_LINE = "Displays the latest anchored VWAP value as a horizontal equilibrium line. VWAP information remains available in the dashboard when this line is hidden."
const string TOOLTIP_RSI_LINE = "Creates a horizontal price-equilibrium line at the closing price where RSI most recently crossed 50. This avoids plotting an oscillator-scale value directly on the price scale."

// --- Inputs ---
maTypeInput = input.string("EMA", "MA Type", options = ["EMA", "SMA", "WMA", "RMA", "HMA"], group = GROUP_PIVOT_MA, tooltip = "Calculation method for both bullish and bearish pivot moving averages.")
maLengthInput = input.int(50, "MA Length", minval = 1, group = GROUP_PIVOT_MA, tooltip = TOOLTIP_MA_LENGTH)
pivotStrengthInput = input.int(5, "Pivot Strength", minval = 1, maxval = 100, group = GROUP_PIVOT_MA, tooltip = TOOLTIP_PIVOT_STRENGTH)
pivotQualificationInput = input.string("All Confirmed Pivots", "Pivot Qualification", options = ["All Confirmed Pivots", "HH / LL Only"], group = GROUP_PIVOT_MA, tooltip = TOOLTIP_QUALIFICATION)
maSourceInput = input.string("Pivot Side", "MA Source", options = ["Pivot Side", "Close", "HL2"], group = GROUP_PIVOT_MA, tooltip = "Pivot Side uses lows for the bullish MA and highs for the bearish MA. Close or HL2 applies the same source to both calculations.")
breakSourceInput = input.string("Close", "Break Confirmation", options = ["Close", "Wick"], group = GROUP_PIVOT_MA, tooltip = "Close requires a closing-price cross. Wick reacts when the bar's high or low crosses the relevant level.")
confirmOnCloseInput = input.bool(true, "Confirm Signals On Bar Close", group = GROUP_PIVOT_MA, tooltip = "Prevents intrabar pivot-break and market-shift signals from changing before the bar closes.")

showStructureInput = input.bool(true, "Show Structure Breaks", group = GROUP_STRUCTURE, tooltip = "Draws dotted confirmed market-structure break segments and keeps shift calculations active for the dashboard.")
showShiftCandidatesInput = input.bool(true, "Show Shift Candidates", group = GROUP_STRUCTURE, tooltip = "Draws the latest unbroken swing-high and swing-low levels as finite faded dotted candidate lines.")
showCandidateLabelsInput = input.bool(true, "Show Candidate Labels", group = GROUP_STRUCTURE, tooltip = "Shows background-free Bullish Break Candidate and Bearish Break Candidate text beside active candidate levels.")
candidateBarsRightInput = input.int(5, "Candidate Bars To Right", minval = 1, maxval = 200, group = GROUP_STRUCTURE, tooltip = "Bars projected to the right of the current bar. Candidate lines advance by one bar on every new bar until broken or replaced.")
structureLengthInput = input.int(12, "Structure Length", minval = 1, maxval = 100, group = GROUP_STRUCTURE, tooltip = TOOLTIP_STRUCTURE)
showShiftLabelsInput = input.bool(true, "Show Shift Labels", group = GROUP_STRUCTURE, tooltip = "Displays background-free Bullish Shift and Bearish Shift text at the midpoint of each confirmed break line.")
shiftLabelSizeInput = input.string("Small", "Structure Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = GROUP_STRUCTURE, tooltip = "Text size used by shift and candidate labels. Labels have no background.")
showContinuationMarksInput = input.bool(true, "Show Trend Continuation Marks", group = GROUP_STRUCTURE, tooltip = "Marks same-direction structure breaks with a directional triangle instead of drawing a BOS line.")
showRetestMarksInput = input.bool(true, "Show Shift MA Retests", group = GROUP_STRUCTURE, tooltip = "After a shift, marks the first touch of the matching bullish or bearish pivot MA with a directional R.")
retestToleranceInput = input.float(0.10, "Retest Tolerance (ATR)", minval = 0.0, maxval = 1.0, step = 0.01, group = GROUP_STRUCTURE, tooltip = "Creates a small ATR-based contact zone around the shift-direction MA so visually valid wick touches are not missed.")
maxStructureMarksInput = input.int(50, "Maximum Structure Marks", minval = 5, maxval = 150, group = GROUP_STRUCTURE, tooltip = "Limits retained shift lines and labels to control chart object usage.")

showVwapLineInput = input.bool(true, "Show Horizontal VWAP", group = GROUP_VWAP, tooltip = TOOLTIP_VWAP_LINE)
vwapAnchorInput = input.string("Session", "VWAP Anchor", options = ["Session", "Week", "Month"], group = GROUP_VWAP, tooltip = "Period that resets the anchored VWAP calculation.")
vwapSourceInput = input.source(hlc3, "VWAP Source", group = GROUP_VWAP, tooltip = "Price source used in the anchored VWAP calculation.")
vwapBarsRightInput = input.int(10, "Bars To Right", minval = 1, maxval = 200, group = GROUP_VWAP, tooltip = "Finite number of bars projected to the right of the current VWAP level.")
vwapLabelOffsetInput = input.int(1, "Label Offset", minval = 0, maxval = 50, group = GROUP_VWAP, tooltip = "Horizontal bars between the right endpoint of the VWAP line and its label.")
useVwapScoreInput = input.bool(true, "Include VWAP In Health Score", group = GROUP_VWAP, tooltip = "Adds price-above-VWAP to the long score and price-below-VWAP to the short score.")

showRsiLineInput = input.bool(true, "Show RSI 50 Price Equilibrium", group = GROUP_RSI, tooltip = TOOLTIP_RSI_LINE)
rsiLengthInput = input.int(14, "RSI Length", minval = 2, group = GROUP_RSI, tooltip = "Lookback length used to calculate RSI. The dashboard reports whether RSI is above or below 50.")
rsiBarsRightInput = input.int(10, "Bars To Right", minval = 1, maxval = 200, group = GROUP_RSI, tooltip = "Finite number of bars projected to the right of the RSI 50 price-equilibrium level.")
rsiLabelOffsetInput = input.int(1, "Label Offset", minval = 0, maxval = 50, group = GROUP_RSI, tooltip = "Horizontal bars between the right endpoint of the RSI equilibrium line and its label.")
useRsiScoreInput = input.bool(true, "Include RSI In Health Score", group = GROUP_RSI, tooltip = "Adds RSI-above-50 to the long score and RSI-below-50 to the short score.")

showHudInput = input.bool(true, "Show Table", group = GROUP_HUD, tooltip = "Turns the information table on or off without disabling its underlying calculations.")
hudPositionInput = input.string("Top Right", "Table Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GROUP_HUD, tooltip = "Location of the information table on the chart.")
equilibriumSpanInput = input.int(100, "Equilibrium Bars To Left", minval = 10, maxval = 500, group = GROUP_HUD, tooltip = "Historical bar span used for the horizontal VWAP and RSI price-equilibrium lines.")
showWatermarkInput = input.bool(true, "Show Watermark", group = GROUP_HUD, tooltip = "Displays the erdensedat watermark at the bottom center of the chart.")
watermarkTextInput = input.string("erdensedat", "Watermark Text", group = GROUP_HUD, tooltip = "Text displayed by the optional chart watermark.")

bullColorInput = input.color(BULL_COLOR, "Bullish", inline = "colors", group = GROUP_STYLE, tooltip = "Color for bullish pivot MAs, shifts, and dashboard states.")
bearColorInput = input.color(BEAR_COLOR, "Bearish", inline = "colors", group = GROUP_STYLE, tooltip = "Color for bearish pivot MAs, shifts, and dashboard states.")
neutralColorInput = input.color(NEUTRAL_COLOR, "Neutral", inline = "colors", group = GROUP_STYLE, tooltip = "Color for neutral information and equilibrium lines.")
ghostTransparencyInput = input.int(78, "Ghost Transparency", minval = 0, maxval = 95, group = GROUP_STYLE, tooltip = TOOLTIP_GHOST)
maWidthInput = input.int(2, "Ghost MA Width", minval = 1, maxval = 3, group = GROUP_STYLE, tooltip = "Base width of ghost pivot MAs. The single active MA is always drawn one step thicker.")
equilibriumLabelSizeInput = input.string("Small", "Equilibrium Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = GROUP_STYLE, tooltip = "Text size of the VWAP and RSI 50 labels displayed to the right of their lines.")

enableBullishShiftAlertInput = input.bool(true, "Bullish Shift Created", group = GROUP_ALERTS, tooltip = "Enables the selectable Bullish Shift Created alert condition.")
enableBearishShiftAlertInput = input.bool(true, "Bearish Shift Created", group = GROUP_ALERTS, tooltip = "Enables the selectable Bearish Shift Created alert condition.")
enableBullishRetestAlertInput = input.bool(true, "Bullish Retest", group = GROUP_ALERTS, tooltip = "Enables the selectable Bullish Shift Retest alert condition.")
enableBearishRetestAlertInput = input.bool(true, "Bearish Retest", group = GROUP_ALERTS, tooltip = "Enables the selectable Bearish Shift Retest alert condition.")

fvgEnableInput = input.bool(true, "Show FVG", inline = "fvg1", group = GROUP_FVG, tooltip = "Displays the integrated fair value gap engine.")
whatFvgInput = input.string("FVG", "Mode", inline = "fvg1", group = GROUP_FVG, options = ["FVG", "Breakers"], tooltip = "Selects standard fair value gaps or breaker behavior.")
fvgNumInput = input.int(5, "Show Last", minval = 0, group = GROUP_FVG, tooltip = "Maximum number of recent bullish and bearish FVGs to display.")
fvgUpColorInput = input.color(color.new(BULL_COLOR, 80), "Bullish FVG", inline = "fvgColors", group = GROUP_FVG, tooltip = "Fill color used for bullish fair value gaps.")
fvgDownColorInput = input.color(color.new(BEAR_COLOR, 80), "Bearish FVG", inline = "fvgColors", group = GROUP_FVG, tooltip = "Fill color used for bearish fair value gaps.")
fvgSourceInput = input.string("Close", "Mitigation", options = ["Close", "Wick", "Avg"], group = GROUP_FVG, tooltip = "Close uses the candle body, Wick uses the extreme, and Avg uses the gap midpoint as the mitigation trigger.")
fvgThresholdInput = input.float(0.0, "Threshold", minval = 0.0, maxval = 2.0, step = 0.1, group = GROUP_FVG, tooltip = "Filters out non-significant fair value gaps using an ATR-based threshold.")
fvgOverlapInput = input.bool(true, "Hide Overlap", group = GROUP_FVG, tooltip = "Removes overlapping fair value gaps.")
fvgMidlineInput = input.bool(true, "Show Mid-Line", group = GROUP_FVG, tooltip = "Displays the midpoint of each visible fair value gap.")
fvgExtendInput = input.bool(false, "Extend FVG", group = GROUP_FVG, tooltip = "Extends active fair value gap drawings to the right.")
displayFvgRaidsInput = input.bool(false, "Display Raids", group = GROUP_FVG, tooltip = "Displays liquidity raid markers tracked by the FVG engine.")

// --- Types ---
type FvgData
    float top = na
    float bottom = na
    int location = bar_index
    bool isBreaker = false
    int breakerLocation = na
    bool isRaid = false
    float raidPrice = na
    int raidLocation = na
    int raidRight = na
    bool active = false
    color raidColor = na

type FvgStore
    array<line> lines
    array<label> labels
    array<box> boxes
    array<linefill> linefills

var FvgStore fvgBin = FvgStore.new(array.new<line>(), array.new<label>(), array.new<box>(), array.new<linefill>())

// --- Functions ---
f_tablePosition(string location) =>
    switch location
        "Top Left" => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

f_healthColor(int score, color bullishColor, color bearishColor, color neutralColor) =>
    score >= 75 ? bullishColor : score <= 25 ? bearishColor : neutralColor

f_labelSize(string sizeName) =>
    switch sizeName
        "Tiny" => size.tiny
        "Normal" => size.normal
        "Large" => size.large
        => size.small

f_fvgValues() =>
    [high[2], low[2], close[1], open[1], close, open, high, low, high[1], low[1], ta.atr(200)]

f_overlapFvg(array<FvgData> bullishFvgArray, array<FvgData> bearishFvgArray) =>
    if bullishFvgArray.size() > 1
        for index = bullishFvgArray.size() - 1 to 1
            FvgData storedFvg = bullishFvgArray.get(index)
            FvgData currentFvg = bullishFvgArray.get(0)
            switch
                storedFvg.bottom > currentFvg.bottom and storedFvg.bottom < currentFvg.top => bullishFvgArray.remove(index)
                storedFvg.top < currentFvg.top and storedFvg.bottom > currentFvg.bottom => bullishFvgArray.remove(index)
                storedFvg.top > currentFvg.top and storedFvg.bottom < currentFvg.bottom => bullishFvgArray.remove(index)
                storedFvg.top < currentFvg.top and storedFvg.top > currentFvg.bottom => bullishFvgArray.remove(index)

    if bearishFvgArray.size() > 1
        for index = bearishFvgArray.size() - 1 to 1
            FvgData storedFvg = bearishFvgArray.get(index)
            FvgData currentFvg = bearishFvgArray.get(0)
            switch
                storedFvg.bottom > currentFvg.bottom and storedFvg.bottom < currentFvg.top => bearishFvgArray.remove(index)
                storedFvg.top < currentFvg.top and storedFvg.bottom > currentFvg.bottom => bearishFvgArray.remove(index)
                storedFvg.top > currentFvg.top and storedFvg.bottom < currentFvg.bottom => bearishFvgArray.remove(index)
                storedFvg.top < currentFvg.top and storedFvg.top > currentFvg.bottom => bearishFvgArray.remove(index)

    if bullishFvgArray.size() > 0 and bearishFvgArray.size() > 0
        for index = bullishFvgArray.size() - 1 to 0
            FvgData storedFvg = bullishFvgArray.get(index)
            FvgData currentFvg = bearishFvgArray.get(0)
            switch
                storedFvg.bottom > currentFvg.bottom and storedFvg.bottom < currentFvg.top => bullishFvgArray.remove(index)
                storedFvg.top < currentFvg.top and storedFvg.bottom > currentFvg.bottom => bullishFvgArray.remove(index)
                storedFvg.top > currentFvg.top and storedFvg.bottom < currentFvg.bottom => bullishFvgArray.remove(index)
                storedFvg.top < currentFvg.top and storedFvg.top > currentFvg.bottom => bullishFvgArray.remove(index)

    if bullishFvgArray.size() > 0 and bearishFvgArray.size() > 0
        for index = bearishFvgArray.size() - 1 to 0
            FvgData storedFvg = bearishFvgArray.get(index)
            FvgData currentFvg = bullishFvgArray.get(0)
            switch
                storedFvg.bottom > currentFvg.bottom and storedFvg.bottom < currentFvg.top => bearishFvgArray.remove(index)
                storedFvg.top < currentFvg.top and storedFvg.bottom > currentFvg.bottom => bearishFvgArray.remove(index)
                storedFvg.top > currentFvg.top and storedFvg.bottom < currentFvg.bottom => bearishFvgArray.remove(index)
                storedFvg.top < currentFvg.top and storedFvg.top > currentFvg.bottom => bearishFvgArray.remove(index)

method displayFvg(FvgData fvg, bool bullish) =>
    string extension = fvgExtendInput ? extend.right : extend.none
    if not fvg.isBreaker
        fvgBin.boxes.unshift(box.new(top = fvg.top, bottom = fvg.bottom, left = fvg.location, right = time, border_color = na, bgcolor = bullish ? fvgUpColorInput : fvgDownColorInput, xloc = xloc.bar_time, extend = extension))
        if fvgMidlineInput
            fvgBin.lines.unshift(line.new(x1 = fvg.location, x2 = time, y1 = math.avg(fvg.top, fvg.bottom), y2 = math.avg(fvg.top, fvg.bottom), xloc = xloc.bar_time, color = color.new(bullish ? fvgUpColorInput : fvgDownColorInput, 0), extend = extension))
        if displayFvgRaidsInput
            fvgBin.lines.unshift(line.new(x1 = fvg.raidLocation, x2 = fvg.raidRight, y1 = fvg.raidPrice, y2 = fvg.raidPrice, xloc = xloc.bar_time, color = fvg.raidColor))
            fvgBin.labels.unshift(label.new(x = int(math.avg(fvg.raidLocation, fvg.raidRight)), y = fvg.raidPrice, text = "x", xloc = xloc.bar_time, textcolor = fvg.raidColor, style = bullish ? label.style_label_up : label.style_label_down, size = size.small, color = #00000000))
    else
        fvgBin.boxes.unshift(box.new(top = fvg.top, bottom = fvg.bottom, left = fvg.location, right = fvg.breakerLocation, border_color = na, bgcolor = bullish ? fvgUpColorInput : fvgDownColorInput, xloc = xloc.bar_time))
        fvgBin.boxes.unshift(box.new(top = fvg.top, bottom = fvg.bottom, left = fvg.breakerLocation, right = time, border_color = bullish ? fvgDownColorInput : fvgUpColorInput, bgcolor = bullish ? fvgDownColorInput : fvgUpColorInput, xloc = xloc.bar_time, extend = extension))
        if fvgMidlineInput
            fvgBin.lines.unshift(line.new(x1 = fvg.location, x2 = fvg.breakerLocation, y1 = math.avg(fvg.top, fvg.bottom), y2 = math.avg(fvg.top, fvg.bottom), color = color.new(bullish ? fvgUpColorInput : fvgDownColorInput, 0), xloc = xloc.bar_time))
            fvgBin.lines.unshift(line.new(x1 = fvg.breakerLocation, x2 = time, y1 = math.avg(fvg.top, fvg.bottom), y2 = math.avg(fvg.top, fvg.bottom), color = color.new(bullish ? fvgDownColorInput : fvgUpColorInput, 0), xloc = xloc.bar_time, extend = extension, style = line.style_dashed))

f_runFvgEngine() =>
    [highTwo, lowTwo, closeOne, openOne, currentClose, currentOpen, currentHigh, currentLow, highOne, lowOne, fvgAtr] = f_fvgValues()
    var array<FvgData> bullishFvgArray = array.new<FvgData>()
    var array<FvgData> bearishFvgArray = array.new<FvgData>()
    bool bullishFvgCreated = false
    bool bearishFvgCreated = false
    float bullishThreshold = lowOne + fvgAtr[1] * fvgThresholdInput
    float bearishThreshold = highOne - fvgAtr[1] * fvgThresholdInput
    bool timeframeChanged = timeframe.change()

    switch
        whatFvgInput == "FVG" or whatFvgInput == "Breakers" =>
            if currentLow > highTwo and timeframeChanged and closeOne > bullishThreshold
                bullishFvgCreated := true
            if lowTwo > currentHigh and timeframeChanged and closeOne < bearishThreshold
                bearishFvgCreated := true

    if bullishFvgCreated[1]
        if bullishFvgArray.size() > 0
            FvgData recentFvg = bullishFvgArray.get(0)
            if recentFvg.isRaid and not recentFvg.active
                recentFvg.active := true
                recentFvg.raidLocation := na
                recentFvg.raidRight := na
                recentFvg.raidPrice := na
                recentFvg.raidColor := #00000000
        bullishFvgArray.unshift(FvgData.new(top = currentLow[1], bottom = highTwo[1], location = time[3]))

    if bearishFvgCreated[1]
        if bearishFvgArray.size() > 0
            FvgData recentFvg = bearishFvgArray.get(0)
            if recentFvg.isRaid and not recentFvg.active
                recentFvg.active := true
                recentFvg.raidLocation := na
                recentFvg.raidRight := na
                recentFvg.raidPrice := na
                recentFvg.raidColor := #00000000
        bearishFvgArray.unshift(FvgData.new(top = lowTwo[1], bottom = currentHigh[1], location = time[3]))

    if bullishFvgArray.size() > 0
        for [index, fvg] in bullishFvgArray
            if not fvg.isBreaker
                bool mitigated = fvgSourceInput == "Close" ? math.min(currentClose, currentOpen) < fvg.bottom : fvgSourceInput == "Wick" ? currentLow < fvg.bottom : fvgSourceInput == "Avg" ? currentLow < math.avg(fvg.top, fvg.bottom) : false
                if mitigated
                    fvg.isBreaker := true
                    fvg.breakerLocation := time
                    if whatFvgInput == "FVG"
                        bullishFvgArray.remove(index)
            else
                bool breakerMitigated = fvgSourceInput == "Close" ? math.max(currentClose, currentOpen) > fvg.top : fvgSourceInput == "Wick" ? currentHigh > fvg.top : fvgSourceInput == "Avg" ? currentHigh > math.avg(fvg.top, fvg.bottom) : false
                if breakerMitigated and whatFvgInput == "Breakers"
                    bullishFvgArray.remove(index)

    if bearishFvgArray.size() > 0
        for [index, fvg] in bearishFvgArray
            if not fvg.isBreaker
                bool mitigated = fvgSourceInput == "Close" ? math.max(currentClose, currentOpen) > fvg.top : fvgSourceInput == "Wick" ? currentHigh > fvg.top : fvgSourceInput == "Avg" ? currentHigh > math.avg(fvg.top, fvg.bottom) : false
                if mitigated
                    fvg.isBreaker := true
                    fvg.breakerLocation := time
                    if whatFvgInput == "FVG"
                        bearishFvgArray.remove(index)
            else
                bool breakerMitigated = fvgSourceInput == "Close" ? math.min(currentClose, currentOpen) < fvg.bottom : fvgSourceInput == "Wick" ? currentLow < fvg.bottom : fvgSourceInput == "Avg" ? currentLow < math.avg(fvg.top, fvg.bottom) : false
                if breakerMitigated and whatFvgInput == "Breakers"
                    bearishFvgArray.remove(index)

    if fvgOverlapInput
        f_overlapFvg(bullishFvgArray, bearishFvgArray)

    if displayFvgRaidsInput
        for fvg in bullishFvgArray
            if not fvg.isRaid and not fvg.isBreaker
                if low < fvg.top and close > fvg.top
                    fvg.isRaid := true
                    fvg.raidLocation := time
                    fvg.raidRight := time
                    fvg.raidPrice := low
                    fvg.raidColor := chart.fg_color
            else
                if low <= fvg.raidPrice and not fvg.active and not fvg.isBreaker
                    fvg.active := true
                    fvg.raidRight := time
                else if not fvg.active and not fvg.isBreaker
                    fvg.raidRight := time

        for fvg in bearishFvgArray
            if not fvg.isRaid and not fvg.isBreaker
                if high > fvg.bottom and close < fvg.bottom
                    fvg.isRaid := true
                    fvg.raidLocation := time
                    fvg.raidPrice := high
                    fvg.raidRight := time
                    fvg.raidColor := chart.fg_color
            else
                if high >= fvg.raidPrice and not fvg.active and not fvg.isBreaker
                    fvg.active := true
                    fvg.raidRight := time
                else if not fvg.active and not fvg.isBreaker
                    fvg.raidRight := time

    if barstate.islast
        if bullishFvgArray.size() > 0 and fvgNumInput > 0
            for index = 0 to math.min(fvgNumInput - 1, bullishFvgArray.size() - 1)
                FvgData fvg = bullishFvgArray.get(index)
                fvg.displayFvg(true)
        if bearishFvgArray.size() > 0 and fvgNumInput > 0
            for index = 0 to math.min(fvgNumInput - 1, bearishFvgArray.size() - 1)
                FvgData fvg = bearishFvgArray.get(index)
                fvg.displayFvg(false)

// --- FVG Execution ---
if barstate.islast
    for lineId in fvgBin.lines
        lineId.delete()
    for labelId in fvgBin.labels
        labelId.delete()
    for boxId in fvgBin.boxes
        boxId.delete()
    fvgBin.lines.clear()
    fvgBin.labels.clear()
    fvgBin.boxes.clear()

if fvgEnableInput
    f_runFvgEngine()

// --- Moving Average Calculations ---
float bullishSource = switch maSourceInput
    "Close" => close
    "HL2" => hl2
    => low

float bearishSource = switch maSourceInput
    "Close" => close
    "HL2" => hl2
    => high

float bullishEma = ta.ema(bullishSource, maLengthInput)
float bullishSma = ta.sma(bullishSource, maLengthInput)
float bullishWma = ta.wma(bullishSource, maLengthInput)
float bullishRma = ta.rma(bullishSource, maLengthInput)
float bullishHma = ta.hma(bullishSource, maLengthInput)
float bearishEma = ta.ema(bearishSource, maLengthInput)
float bearishSma = ta.sma(bearishSource, maLengthInput)
float bearishWma = ta.wma(bearishSource, maLengthInput)
float bearishRma = ta.rma(bearishSource, maLengthInput)
float bearishHma = ta.hma(bearishSource, maLengthInput)

float bullishMa = switch maTypeInput
    "SMA" => bullishSma
    "WMA" => bullishWma
    "RMA" => bullishRma
    "HMA" => bullishHma
    => bullishEma

float bearishMa = switch maTypeInput
    "SMA" => bearishSma
    "WMA" => bearishWma
    "RMA" => bearishRma
    "HMA" => bearishHma
    => bearishEma

// --- Pivot MA State ---
float pricePivotHigh = ta.pivothigh(high, pivotStrengthInput, pivotStrengthInput)
float pricePivotLow = ta.pivotlow(low, pivotStrengthInput, pivotStrengthInput)
bool signalReady = not confirmOnCloseInput or barstate.isconfirmed
var float previousHighPivot = na
var float previousLowPivot = na
bool bearishPivotTrigger = false
bool bullishPivotTrigger = false

if signalReady and not na(pricePivotHigh)
    bearishPivotTrigger := pivotQualificationInput == "All Confirmed Pivots" or na(previousHighPivot) or pricePivotHigh > previousHighPivot
    previousHighPivot := pricePivotHigh

if signalReady and not na(pricePivotLow)
    bullishPivotTrigger := pivotQualificationInput == "All Confirmed Pivots" or na(previousLowPivot) or pricePivotLow < previousLowPivot
    previousLowPivot := pricePivotLow

bool closeBullBreak = ta.crossunder(close, bullishMa)
bool wickBullBreak = ta.crossunder(low, bullishMa)
bool closeBearBreak = ta.crossover(close, bearishMa)
bool wickBearBreak = ta.crossover(high, bearishMa)
bool bullishBreakCondition = breakSourceInput == "Wick" ? wickBullBreak : closeBullBreak
bool bearishBreakCondition = breakSourceInput == "Wick" ? wickBearBreak : closeBearBreak

var bool bullishMaExists = false
var bool bearishMaExists = false
var bool bullishMaGhost = false
var bool bearishMaGhost = false
var bool bullishMaBroken = false
var bool bearishMaBroken = false
bool bullishMaBreak = false
bool bearishMaBreak = false
bool bullishActivationValid = not na(bullishMa[1]) and close >= bullishMa and bullishMa > bullishMa[1]
bool bearishActivationValid = not na(bearishMa[1]) and close <= bearishMa and bearishMa < bearishMa[1]

if bullishPivotTrigger
    bullishMaExists := true
    bullishMaBroken := false
    bullishMaGhost := not bullishActivationValid
else if signalReady and bullishMaExists and not bullishMaGhost and (bullishBreakCondition or not bullishActivationValid)
    bullishMaGhost := true
    bullishMaBreak := bullishBreakCondition
    if bullishBreakCondition
        bullishMaBroken := true

if bearishPivotTrigger
    bearishMaExists := true
    bearishMaBroken := false
    bearishMaGhost := not bearishActivationValid
else if signalReady and bearishMaExists and not bearishMaGhost and (bearishBreakCondition or not bearishActivationValid)
    bearishMaGhost := true
    bearishMaBreak := bearishBreakCondition
    if bearishBreakCondition
        bearishMaBroken := true

if signalReady
    bool bullishEligible = bullishMaExists and not bullishMaBroken and bullishActivationValid
    bool bearishEligible = bearishMaExists and not bearishMaBroken and bearishActivationValid
    if bullishEligible and not bearishEligible
        bullishMaGhost := false
        if bearishMaExists
            bearishMaGhost := true
    else if bearishEligible and not bullishEligible
        bearishMaGhost := false
        if bullishMaExists
            bullishMaGhost := true
    else if not bullishEligible and not bearishEligible
        if bullishMaExists
            bullishMaGhost := true
        if bearishMaExists
            bearishMaGhost := true
    else
        if bearishPivotTrigger or close < close[1]
            bearishMaGhost := false
            bullishMaGhost := true
        else
            bullishMaGhost := false
            bearishMaGhost := true

bool bullishMaActive = bullishMaExists and not bullishMaGhost
bool bearishMaActive = bearishMaExists and not bearishMaGhost
color bullishGhostColor = color.new(bullColorInput, ghostTransparencyInput)
color bearishGhostColor = color.new(bearColorInput, ghostTransparencyInput)

plot(bullishMaActive ? bullishMa : na, "Active Bullish Pivot MA", color = bullColorInput, linewidth = maWidthInput + 1, style = plot.style_linebr, force_overlay = true)
plot(bearishMaActive ? bearishMa : na, "Active Bearish Pivot MA", color = bearColorInput, linewidth = maWidthInput + 1, style = plot.style_linebr, force_overlay = true)
plot(bullishMaExists and bullishMaGhost ? bullishMa : na, "Ghost Bullish Pivot MA", color = bullishGhostColor, linewidth = maWidthInput, style = plot.style_linebr, force_overlay = true)
plot(bearishMaExists and bearishMaGhost ? bearishMa : na, "Ghost Bearish Pivot MA", color = bearishGhostColor, linewidth = maWidthInput, style = plot.style_linebr, force_overlay = true)

// --- Market Structure: Candidate to Broken CHoCH Logic ---
int adjustedStructureLength = structureLengthInput % 2 == 0 ? structureLengthInput + 1 : structureLengthInput
int structurePivotStrength = int(adjustedStructureLength / 2)
float structurePivotHigh = ta.pivothigh(high, structurePivotStrength, structurePivotStrength)
float structurePivotLow = ta.pivotlow(low, structurePivotStrength, structurePivotStrength)
float structureAtr = ta.atr(14)
float shiftLabelOffset = math.max(structureAtr * 0.16, syminfo.mintick * 20.0)
float candidateLabelOffset = math.max(structureAtr * 0.10, syminfo.mintick * 12.0)
bool structureHighHit = signalReady and not na(structurePivotHigh)
bool structureLowHit = signalReady and not na(structurePivotLow)

var float activeStructureHigh = na
var float activeStructureLow = na
var int activeStructureHighBar = na
var int activeStructureLowBar = na
var bool structureHighBroken = false
var bool structureLowBroken = false
var line bullishCandidateLineId = na
var line bearishCandidateLineId = na
var label bullishCandidateLabelId = na
var label bearishCandidateLabelId = na
var int lastStructureBreakDirection = 0
var int shiftState = 0
var array<line> structureLinesArray = array.new_line()
var array<label> structureLabelsArray = array.new_label()

if structureHighHit
    if not na(bullishCandidateLineId) and not structureHighBroken
        line.delete(bullishCandidateLineId)
    if not na(bullishCandidateLabelId)
        label.delete(bullishCandidateLabelId)
    activeStructureHigh := structurePivotHigh
    activeStructureHighBar := bar_index - structurePivotStrength
    structureHighBroken := false
    bullishCandidateLineId := na
    bullishCandidateLabelId := na
    if showShiftCandidatesInput
        int bullishCandidateRightBar = bar_index + candidateBarsRightInput
        bullishCandidateLineId := line.new(activeStructureHighBar, activeStructureHigh, bullishCandidateRightBar, activeStructureHigh, xloc = xloc.bar_index, extend = extend.none, color = color.new(bullColorInput, 45), style = line.style_dotted, width = 1, force_overlay = true)
        if showCandidateLabelsInput
            bullishCandidateLabelId := label.new(bullishCandidateRightBar, activeStructureHigh + candidateLabelOffset, "Bullish Break Candidate", xloc = xloc.bar_index, yloc = yloc.price, color = #00000000, style = label.style_none, textcolor = bullColorInput, size = f_labelSize(shiftLabelSizeInput), force_overlay = true)

if structureLowHit
    if not na(bearishCandidateLineId) and not structureLowBroken
        line.delete(bearishCandidateLineId)
    if not na(bearishCandidateLabelId)
        label.delete(bearishCandidateLabelId)
    activeStructureLow := structurePivotLow
    activeStructureLowBar := bar_index - structurePivotStrength
    structureLowBroken := false
    bearishCandidateLineId := na
    bearishCandidateLabelId := na
    if showShiftCandidatesInput
        int bearishCandidateRightBar = bar_index + candidateBarsRightInput
        bearishCandidateLineId := line.new(activeStructureLowBar, activeStructureLow, bearishCandidateRightBar, activeStructureLow, xloc = xloc.bar_index, extend = extend.none, color = color.new(bearColorInput, 45), style = line.style_dotted, width = 1, force_overlay = true)
        if showCandidateLabelsInput
            bearishCandidateLabelId := label.new(bearishCandidateRightBar, activeStructureLow - candidateLabelOffset, "Bearish Break Candidate", xloc = xloc.bar_index, yloc = yloc.price, color = #00000000, style = label.style_none, textcolor = bearColorInput, size = f_labelSize(shiftLabelSizeInput), force_overlay = true)

if not na(bullishCandidateLineId) and not structureHighBroken
    int bullishCandidateRightBar = bar_index + candidateBarsRightInput
    line.set_x2(bullishCandidateLineId, bullishCandidateRightBar)
    if not na(bullishCandidateLabelId)
        label.set_xy(bullishCandidateLabelId, bullishCandidateRightBar, activeStructureHigh + candidateLabelOffset)

if not na(bearishCandidateLineId) and not structureLowBroken
    int bearishCandidateRightBar = bar_index + candidateBarsRightInput
    line.set_x2(bearishCandidateLineId, bearishCandidateRightBar)
    if not na(bearishCandidateLabelId)
        label.set_xy(bearishCandidateLabelId, bearishCandidateRightBar, activeStructureLow - candidateLabelOffset)

bool rawBullishStructureBreak = signalReady and not na(activeStructureHigh) and not structureHighBroken and (breakSourceInput == "Close" ? close > activeStructureHigh : high > activeStructureHigh)
bool rawBearishStructureBreak = signalReady and not na(activeStructureLow) and not structureLowBroken and (breakSourceInput == "Close" ? close < activeStructureLow : low < activeStructureLow)
bool bullishStructureBreak = rawBullishStructureBreak and (not rawBearishStructureBreak or close >= open)
bool bearishStructureBreak = rawBearishStructureBreak and (not rawBullishStructureBreak or close < open)
bool bullishShift = bullishStructureBreak and lastStructureBreakDirection == -1
bool bearishShift = bearishStructureBreak and lastStructureBreakDirection == 1
bool bullishContinuation = bullishStructureBreak and not bullishShift
bool bearishContinuation = bearishStructureBreak and not bearishShift
var int activeRetestDirection = 0
var int activeRetestStartBar = na
var bool retestPending = false

if bullishStructureBreak
    structureHighBroken := true
    if not na(bullishCandidateLabelId)
        label.delete(bullishCandidateLabelId)
        bullishCandidateLabelId := na
    line bullishBrokenLineId = bullishCandidateLineId
    if bullishShift and showStructureInput
        if na(bullishBrokenLineId)
            bullishBrokenLineId := line.new(activeStructureHighBar, activeStructureHigh, bar_index, activeStructureHigh, xloc = xloc.bar_index, extend = extend.none, color = bullColorInput, style = line.style_dotted, width = 2, force_overlay = true)
        else
            line.set_x2(bullishBrokenLineId, bar_index)
            line.set_color(bullishBrokenLineId, bullColorInput)
            line.set_style(bullishBrokenLineId, line.style_dotted)
            line.set_width(bullishBrokenLineId, 2)
        array.push(structureLinesArray, bullishBrokenLineId)
        if array.size(structureLinesArray) > maxStructureMarksInput
            line.delete(array.shift(structureLinesArray))
    else if not na(bullishBrokenLineId)
        line.delete(bullishBrokenLineId)
    bullishCandidateLineId := na
    if bullishShift
        shiftState := 1
        activeRetestDirection := 1
        activeRetestStartBar := bar_index
        retestPending := true
        if showStructureInput and showShiftLabelsInput
            int bullishLabelBar = int(math.avg(activeStructureHighBar, bar_index))
            label bullishShiftLabel = label.new(bullishLabelBar, activeStructureHigh + shiftLabelOffset, "Bullish Shift", xloc = xloc.bar_index, yloc = yloc.price, color = #00000000, style = label.style_none, textcolor = bullColorInput, size = f_labelSize(shiftLabelSizeInput), force_overlay = true)
            array.push(structureLabelsArray, bullishShiftLabel)
            if array.size(structureLabelsArray) > maxStructureMarksInput
                label.delete(array.shift(structureLabelsArray))
    lastStructureBreakDirection := 1

if bearishStructureBreak
    structureLowBroken := true
    if not na(bearishCandidateLabelId)
        label.delete(bearishCandidateLabelId)
        bearishCandidateLabelId := na
    line bearishBrokenLineId = bearishCandidateLineId
    if bearishShift and showStructureInput
        if na(bearishBrokenLineId)
            bearishBrokenLineId := line.new(activeStructureLowBar, activeStructureLow, bar_index, activeStructureLow, xloc = xloc.bar_index, extend = extend.none, color = bearColorInput, style = line.style_dotted, width = 2, force_overlay = true)
        else
            line.set_x2(bearishBrokenLineId, bar_index)
            line.set_color(bearishBrokenLineId, bearColorInput)
            line.set_style(bearishBrokenLineId, line.style_dotted)
            line.set_width(bearishBrokenLineId, 2)
        array.push(structureLinesArray, bearishBrokenLineId)
        if array.size(structureLinesArray) > maxStructureMarksInput
            line.delete(array.shift(structureLinesArray))
    else if not na(bearishBrokenLineId)
        line.delete(bearishBrokenLineId)
    bearishCandidateLineId := na
    if bearishShift
        shiftState := -1
        activeRetestDirection := -1
        activeRetestStartBar := bar_index
        retestPending := true
        if showStructureInput and showShiftLabelsInput
            int bearishLabelBar = int(math.avg(activeStructureLowBar, bar_index))
            label bearishShiftLabel = label.new(bearishLabelBar, activeStructureLow - shiftLabelOffset, "Bearish Shift", xloc = xloc.bar_index, yloc = yloc.price, color = #00000000, style = label.style_none, textcolor = bearColorInput, size = f_labelSize(shiftLabelSizeInput), force_overlay = true)
            array.push(structureLabelsArray, bearishShiftLabel)
            if array.size(structureLabelsArray) > maxStructureMarksInput
                label.delete(array.shift(structureLabelsArray))
    lastStructureBreakDirection := -1

float retestTolerance = structureAtr * retestToleranceInput
bool bullishMaContact = bullishMaExists and not na(bullishMa) and low <= bullishMa + retestTolerance and high >= bullishMa - retestTolerance
bool bearishMaContact = bearishMaExists and not na(bearishMa) and high >= bearishMa - retestTolerance and low <= bearishMa + retestTolerance
bool bullishRetest = signalReady and retestPending and activeRetestDirection == 1 and bar_index > activeRetestStartBar and bullishMaContact
bool bearishRetest = signalReady and retestPending and activeRetestDirection == -1 and bar_index > activeRetestStartBar and bearishMaContact
if bullishRetest or bearishRetest
    retestPending := false

plotshape(showContinuationMarksInput and bullishContinuation, title = "Bullish Trend Continuation", style = shape.triangleup, location = location.belowbar, color = bullColorInput, size = size.tiny, force_overlay = true)
plotshape(showContinuationMarksInput and bearishContinuation, title = "Bearish Trend Continuation", style = shape.triangledown, location = location.abovebar, color = bearColorInput, size = size.tiny, force_overlay = true)
plotshape(showRetestMarksInput and bullishRetest, title = "Bullish Shift MA Retest", style = shape.labelup, location = location.belowbar, color = #00000000, text = "R", textcolor = bullColorInput, size = size.small, force_overlay = true)
plotshape(showRetestMarksInput and bearishRetest, title = "Bearish Shift MA Retest", style = shape.labeldown, location = location.abovebar, color = #00000000, text = "R", textcolor = bearColorInput, size = size.small, force_overlay = true)

// --- VWAP and RSI Equilibrium ---
bool vwapReset = switch vwapAnchorInput
    "Week" => timeframe.change("1W")
    "Month" => timeframe.change("1M")
    => timeframe.change("1D")

float anchoredVwap = ta.vwap(vwapSourceInput, vwapReset)
float rsiValue = ta.rsi(close, rsiLengthInput)
bool rsiCross50 = ta.cross(rsiValue, RSI_MIDLINE)
var float rsiPriceEquilibrium = na
if signalReady and rsiCross50
    rsiPriceEquilibrium := close

var line vwapLineId = na
var line rsiLineId = na
var label vwapLabelId = na
var label rsiLabelId = na

if barstate.islast
    int equilibriumLeftBar = math.max(0, bar_index - equilibriumSpanInput)
    int vwapRightBar = bar_index + vwapBarsRightInput
    int rsiRightBar = bar_index + rsiBarsRightInput
    if showVwapLineInput and not na(anchoredVwap)
        if na(vwapLineId)
            vwapLineId := line.new(equilibriumLeftBar, anchoredVwap, vwapRightBar, anchoredVwap, xloc = xloc.bar_index, extend = extend.none, color = neutralColorInput, style = line.style_dashed, width = 2, force_overlay = true)
        else
            line.set_xy1(vwapLineId, equilibriumLeftBar, anchoredVwap)
            line.set_xy2(vwapLineId, vwapRightBar, anchoredVwap)
            line.set_color(vwapLineId, neutralColorInput)
        if na(vwapLabelId)
            vwapLabelId := label.new(vwapRightBar + vwapLabelOffsetInput, anchoredVwap, "VWAP", xloc = xloc.bar_index, yloc = yloc.price, color = #00000000, style = label.style_none, textcolor = neutralColorInput, size = f_labelSize(equilibriumLabelSizeInput), force_overlay = true)
        else
            label.set_xy(vwapLabelId, vwapRightBar + vwapLabelOffsetInput, anchoredVwap)
            label.set_textcolor(vwapLabelId, neutralColorInput)
    else
        if not na(vwapLineId)
            line.delete(vwapLineId)
            vwapLineId := na
        if not na(vwapLabelId)
            label.delete(vwapLabelId)
            vwapLabelId := na

    if showRsiLineInput and not na(rsiPriceEquilibrium)
        color rsiLineColor = rsiValue >= RSI_MIDLINE ? bullColorInput : bearColorInput
        if na(rsiLineId)
            rsiLineId := line.new(equilibriumLeftBar, rsiPriceEquilibrium, rsiRightBar, rsiPriceEquilibrium, xloc = xloc.bar_index, extend = extend.none, color = rsiLineColor, style = line.style_dashed, width = 2, force_overlay = true)
        else
            line.set_xy1(rsiLineId, equilibriumLeftBar, rsiPriceEquilibrium)
            line.set_xy2(rsiLineId, rsiRightBar, rsiPriceEquilibrium)
            line.set_color(rsiLineId, rsiLineColor)
        if na(rsiLabelId)
            rsiLabelId := label.new(rsiRightBar + rsiLabelOffsetInput, rsiPriceEquilibrium, "RSI 50", xloc = xloc.bar_index, yloc = yloc.price, color = #00000000, style = label.style_none, textcolor = rsiLineColor, size = f_labelSize(equilibriumLabelSizeInput), force_overlay = true)
        else
            label.set_xy(rsiLabelId, rsiRightBar + rsiLabelOffsetInput, rsiPriceEquilibrium)
            label.set_textcolor(rsiLabelId, rsiLineColor)
    else
        if not na(rsiLineId)
            line.delete(rsiLineId)
            rsiLineId := na
        if not na(rsiLabelId)
            label.delete(rsiLabelId)
            rsiLabelId := na

// --- Alignment and Health Scores ---
bool priceAboveVwap = not na(anchoredVwap) and close >= anchoredVwap
bool priceBelowVwap = not na(anchoredVwap) and close < anchoredVwap
bool rsiBullish = not na(rsiValue) and rsiValue >= RSI_MIDLINE
bool rsiBearish = not na(rsiValue) and rsiValue < RSI_MIDLINE
bool idealLong = shiftState == 1 and bullishMaActive
bool idealShort = shiftState == -1 and bearishMaActive
int scoreFactors = 2 + (useVwapScoreInput ? 1 : 0) + (useRsiScoreInput ? 1 : 0)
int longPoints = (shiftState == 1 ? 1 : 0) + (bullishMaActive ? 1 : 0) + (useVwapScoreInput and priceAboveVwap ? 1 : 0) + (useRsiScoreInput and rsiBullish ? 1 : 0)
int shortPoints = (shiftState == -1 ? 1 : 0) + (bearishMaActive ? 1 : 0) + (useVwapScoreInput and priceBelowVwap ? 1 : 0) + (useRsiScoreInput and rsiBearish ? 1 : 0)
int longHealth = int(math.round(100.0 * longPoints / scoreFactors))
int shortHealth = int(math.round(100.0 * shortPoints / scoreFactors))

string shiftText = shiftState == 1 ? "Bullish Shift" : shiftState == -1 ? "Bearish Shift" : "Waiting"
string bullishMaText = not bullishMaExists ? "Waiting" : bullishMaGhost ? "Ghost" : "Active"
string bearishMaText = not bearishMaExists ? "Waiting" : bearishMaGhost ? "Ghost" : "Active"
string alignmentText = idealLong ? "Bullish Match" : idealShort ? "Bearish Match" : "No Match"
string vwapText = na(anchoredVwap) ? "Unavailable" : priceAboveVwap ? "Price Above" : "Price Below"
string rsiText = na(rsiValue) ? "Unavailable" : str.tostring(rsiValue, "#.0") + (rsiBullish ? " / Above 50" : " / Below 50")
string biasText = longHealth > shortHealth ? "Bullish" : shortHealth > longHealth ? "Bearish" : "Balanced"
color shiftColor = shiftState == 1 ? bullColorInput : shiftState == -1 ? bearColorInput : neutralColorInput
color bullishStatusColor = bullishMaActive ? bullColorInput : neutralColorInput
color bearishStatusColor = bearishMaActive ? bearColorInput : neutralColorInput
color alignmentColor = idealLong ? bullColorInput : idealShort ? bearColorInput : neutralColorInput
color vwapStatusColor = na(anchoredVwap) ? neutralColorInput : priceAboveVwap ? bullColorInput : bearColorInput
color rsiStatusColor = na(rsiValue) ? neutralColorInput : rsiBullish ? bullColorInput : bearColorInput
color biasColor = biasText == "Bullish" ? bullColorInput : biasText == "Bearish" ? bearColorInput : neutralColorInput

// --- Dashboard ---
var table hudTable = table.new(f_tablePosition(hudPositionInput), 2, 10, border_width = 1, frame_color = color.new(chart.fg_color, 65), border_color = color.new(chart.fg_color, 80))
if barstate.isfirst
    table.merge_cells(hudTable, 0, 0, 1, 0)

if barstate.islast
    if showHudInput
        color panelColor = color.new(chart.bg_color, 8)
        table.cell(hudTable, 0, 0, "PIVOT STRUCTURE DASHBOARD", text_color = chart.fg_color, bgcolor = color.new(neutralColorInput, 65), text_size = size.small)
        table.cell(hudTable, 0, 1, "Latest Shift", text_color = chart.fg_color, bgcolor = panelColor, text_halign = text.align_left)
        table.cell(hudTable, 1, 1, shiftText, text_color = shiftColor, bgcolor = panelColor, text_halign = text.align_right)
        table.cell(hudTable, 0, 2, "Bullish Pivot MA", text_color = chart.fg_color, bgcolor = panelColor, text_halign = text.align_left)
        table.cell(hudTable, 1, 2, bullishMaText, text_color = bullishStatusColor, bgcolor = panelColor, text_halign = text.align_right)
        table.cell(hudTable, 0, 3, "Bearish Pivot MA", text_color = chart.fg_color, bgcolor = panelColor, text_halign = text.align_left)
        table.cell(hudTable, 1, 3, bearishMaText, text_color = bearishStatusColor, bgcolor = panelColor, text_halign = text.align_right)
        table.cell(hudTable, 0, 4, "Shift + MA", text_color = chart.fg_color, bgcolor = panelColor, text_halign = text.align_left)
        table.cell(hudTable, 1, 4, alignmentText, text_color = alignmentColor, bgcolor = panelColor, text_halign = text.align_right)
        table.cell(hudTable, 0, 5, "VWAP", text_color = chart.fg_color, bgcolor = panelColor, text_halign = text.align_left)
        table.cell(hudTable, 1, 5, vwapText, text_color = vwapStatusColor, bgcolor = panelColor, text_halign = text.align_right)
        table.cell(hudTable, 0, 6, "RSI", text_color = chart.fg_color, bgcolor = panelColor, text_halign = text.align_left)
        table.cell(hudTable, 1, 6, rsiText, text_color = rsiStatusColor, bgcolor = panelColor, text_halign = text.align_right)
        table.cell(hudTable, 0, 7, "Long Health", text_color = chart.fg_color, bgcolor = panelColor, text_halign = text.align_left)
        table.cell(hudTable, 1, 7, str.tostring(longHealth) + "% (" + str.tostring(longPoints) + "/" + str.tostring(scoreFactors) + ")", text_color = f_healthColor(longHealth, bullColorInput, bearColorInput, neutralColorInput), bgcolor = panelColor, text_halign = text.align_right)
        table.cell(hudTable, 0, 8, "Short Health", text_color = chart.fg_color, bgcolor = panelColor, text_halign = text.align_left)
        table.cell(hudTable, 1, 8, str.tostring(shortHealth) + "% (" + str.tostring(shortPoints) + "/" + str.tostring(scoreFactors) + ")", text_color = f_healthColor(shortHealth, bullColorInput, bearColorInput, neutralColorInput), bgcolor = panelColor, text_halign = text.align_right)
        table.cell(hudTable, 0, 9, "Composite Bias", text_color = chart.fg_color, bgcolor = panelColor, text_halign = text.align_left)
        table.cell(hudTable, 1, 9, biasText, text_color = biasColor, bgcolor = panelColor, text_halign = text.align_right)
    else
        table.clear(hudTable, 0, 0, 1, 9)

// --- Watermark ---
var table watermarkTable = table.new(position.bottom_center, 1, 1)
if barstate.islast
    if showWatermarkInput
        table.cell(watermarkTable, 0, 0, watermarkTextInput, text_color = color.new(chart.fg_color, 75), bgcolor = #00000000, text_size = size.large)
    else
        table.clear(watermarkTable, 0, 0, 0, 0)

// --- Alerts ---
bool newIdealLong = idealLong and not idealLong[1]
bool newIdealShort = idealShort and not idealShort[1]
alertcondition(enableBullishShiftAlertInput and bullishShift, "Bullish Shift Created", "A bullish market-structure shift has been created.")
alertcondition(enableBearishShiftAlertInput and bearishShift, "Bearish Shift Created", "A bearish market-structure shift has been created.")
alertcondition(enableBullishRetestAlertInput and bullishRetest, "Bullish Shift MA Retest", "After a Bullish Shift, price has contacted the bullish pivot MA retest zone.")
alertcondition(enableBearishRetestAlertInput and bearishRetest, "Bearish Shift MA Retest", "After a Bearish Shift, price has contacted the bearish pivot MA retest zone.")
alertcondition(bullishMaBreak, "Bullish Pivot MA Broken", "The bullish pivot MA has been broken and is now a ghost line.")
alertcondition(bearishMaBreak, "Bearish Pivot MA Broken", "The bearish pivot MA has been broken and is now a ghost line.")
alertcondition(newIdealLong, "Bullish Shift + Bullish MA", "Bullish Shift and an active bullish pivot MA are aligned.")
alertcondition(newIdealShort, "Bearish Shift + Bearish MA", "Bearish Shift and an active bearish pivot MA are aligned.")
````
