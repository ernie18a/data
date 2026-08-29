<!-- tradingview-pine-id: PUB;6bf588ac64174f07bbab585081670ca0 -->
<!-- tradingviewscripts-format: 1 -->
# Entry-to-Exit Tool

Source: https://www.tradingview.com/script/5myVM1RG-Entry-to-Exit-Tool/

## Description

A realtime non-repainting entry-to-exit analysis tool that retains a Provisional or Finalized BUY/SELL entry reference and resolves it through an opposite signal, confirmed terminal invalidation, minimum-profit target, or entry-terminal risk/reward target. The displayed exits are analytical reference events and are not a guarantee of profitability or future performance.

Name:
Entry-to-Exit Tool

Searchable Name:
Realtime Non-Repainting Entry Exit Target and Risk Reward Tool

Technical Name:
Realtime Non-Repainting Provisional Finalized Entry Reference Opposite Signal Terminal Break Profit Target and Risk Reward Exit Resolution Tool

Short title:
Trade Exit Tool

Summary
Entry-to-Exit Tool is an exit-resolution indicator that converts internally generated Provisional or Finalized BUY/SELL signals into retained entry references and then identifies where those references would resolve under a selected exit method.

The script does not require signals from another indicator. It contains its own causal transform-path signals, structural resolver, Provisional signal ledger, and Finalized signal ledger. The user selects which internally generated signal stage establishes the entry reference and which stage can later provide an opposite-signal exit.

Each retained entry reference stores:

direction
confirmation bar
confirmation price
retained terminal price

The reference remains active until one enabled exit condition resolves it.

Available exit conditions include:

selected opposite BUY/SELL signal
confirmed close through the retained entry terminal
fixed minimum-profit target
entry-terminal risk/reward target

Opposite-signal exits, terminal exits, fixed-profit targets, and risk/reward targets remain separate exit identities. The script records the exit bar, exit price, resolved direction, and exit reason without rewriting the completed record after later chart history arrives.

This is not a complete strategy or automated trade-management engine. It does not submit orders, calculate position quantities, reverse broker positions, calculate complete strategy profitability, manage a portfolio, or route executable instructions. Its purpose is to show structured entry-to-exit reference behavior from the script’s own causal signal records.

How it works

The script first produces two internally retained signal stages:

Provisional
Finalized

The selected Entry Reference Stage determines which signal stage opens a retained entry reference.

The selected Opposite Exit Signal Stage determines which signal stage can later resolve that reference through an opposite BUY or SELL confirmation.

These two stages can be selected independently.

For example, a user can choose:

Provisional entry with Provisional opposite exit
Provisional entry with Finalized opposite exit
Finalized entry with Provisional opposite exit
Finalized entry with Finalized opposite exit

The script then processes entry-reference events and opposite-exit events in chronological order.

When both event streams contain an event on the same bar, the exit-stage event is processed before the entry-stage event. This prevents the new same-bar entry event from being incorrectly treated as active before the earlier reference has had a chance to resolve.

Provisional entry references

A Provisional entry reference is established from an accepted causal transform-path-agreed BUY or SELL confirmation.

Provisional confirmation requires the candidate direction to agree with the stored causal transform-reference direction.

A retained transform candidate can confirm:

on its candidate bar
or on the following closed bar

The maximum signal confirmation delay is limited to zero or one bar.

When Active Path-Filtered Candidate Memory is enabled, a valid candidate that initially fails transform-path direction agreement can remain stored. It can later confirm on the first closed bar where the retained candidate terminal agrees with the active causal transform direction.

That later passing bar becomes the actual Provisional confirmation bar and entry-reference price.

A Provisional signal is earlier than a Finalized signal, but it has not yet completed structural finalization. It can still be replaced, superseded, or fail to become the retained Finalized identity of its structural swing.

Finalized entry references

A Finalized entry reference is established from a Provisional signal that survives the selected structural resolver.

Finalized identity requires structural completion of the containing swing.

The Finalized reference uses:

the retained structural BUY or SELL identity
the Finalized confirmation bar
the Finalized confirmation price
the retained structural terminal price

Finalized references generally occur later than Provisional references, but they represent the signal identity retained after structural resolution.

Structural events classify and finalize signal identity. They do not independently create the Provisional BUY/SELL signal universe.

Entry-reference behavior

Only one entry reference can remain active at a time.

When no reference is active, the next qualifying event from the selected Entry Reference Stage establishes a new reference.

The reference retains:

long or short direction
entry confirmation bar
entry confirmation price
terminal price associated with that entry identity

The script does not continuously replace an unresolved reference with later same-side entry signals.

A new entry reference is committed only after the prior reference has resolved and the script is flat at the reference-state level.

The reference is an analytical state retained by the indicator. It is not a broker position and does not contain position size or account information.

Exit Resolution Method

The user selects one of three primary exit-resolution methods:

Opposite Signal
Entry Terminal Break
Opposite Or Terminal Break

Target exits are controlled separately and can operate alongside the selected primary exit method.

Opposite Signal

Opposite Signal resolves the active entry reference when the selected opposite signal stage confirms.

For a long reference, the selected SELL signal is the opposite event.

For a short reference, the selected BUY signal is the opposite event.

The opposite event uses the stage selected under Opposite Exit Signal Stage:

Provisional
or Finalized

The exit occurs at that opposite event’s confirmation price.

An opposite signal that does not oppose the currently active direction does not resolve the reference.

Require Profit For Opposite Exit

Require Profit For Opposite Exit applies only to opposite-signal exits.

When disabled, every qualifying opposite signal can resolve the active reference.

When enabled, the opposite signal resolves the reference only when the raw-price return from the retained entry price to the opposite confirmation price is at least the selected Minimum Profit For Opposite Exit percentage.

For a long reference, profit requires the opposite exit price to be sufficiently above the entry price.

For a short reference, profit requires the opposite exit price to be sufficiently below the entry price.

This setting does not delay or block:

Entry Terminal Break
Minimum Profit Target
Risk/Reward Target

An unprofitable opposite signal can therefore be ignored while another enabled exit condition remains active.

Minimum Profit For Opposite Exit is a gate on an opposite signal. It is not the same as the independent Minimum Profit Target exit.

Entry Terminal Break

Entry Terminal Break resolves the active reference when a confirmed close invalidates the retained entry terminal.

For a long reference:

a confirmed close below the retained terminal resolves the reference

For a short reference:

a confirmed close above the retained terminal resolves the reference

The terminal is taken from the same signal identity that established the entry reference.

The terminal is not replaced by every later support, resistance, pivot, or same-side signal.

Terminal exits use confirmed closes only.

An intrabar move through the terminal that does not remain broken at the confirmed close does not create a terminal exit under this script.

Opposite Or Terminal Break

Opposite Or Terminal Break enables both primary exit conditions.

The reference resolves on whichever valid event occurs first:

a qualifying opposite signal
or a confirmed terminal invalidation

When Require Profit For Opposite Exit is enabled, an opposite signal that does not meet the profit requirement is not treated as a valid exit. The terminal condition remains active and can still resolve the reference.

Target Exit

Target Exit is independent from the selected primary Exit Resolution Method.

Available target modes are:

Off
Minimum Profit %
Risk/Reward

When Target Exit is Off, no target price is calculated and no target exit can resolve the reference.

The status table displays:

OFF when the target mode is disabled
n/a when no entry reference is active
unavailable when a Risk/Reward target cannot be formed
the calculated target price when a valid active target exists

Minimum Profit Target

Minimum Profit % creates a fixed target from the retained entry-reference price.

For a long reference:

Target Price = Entry Price × (1 + Minimum Profit Target %)

For a short reference:

Target Price = Entry Price × (1 − Minimum Profit Target %)

The reference resolves when a confirmed close reaches or passes the calculated target.

For a long reference:

the confirmed close must be at or above the target

For a short reference:

the confirmed close must be at or below the target

The exit label is recorded as:

PROFIT TARGET

This target operates independently from Require Profit For Opposite Exit.

The two settings serve different purposes:

Minimum Profit For Opposite Exit controls whether an opposite signal is allowed to exit
Minimum Profit Target creates an independent price level that can exit without an opposite signal

Risk/Reward Target

Risk/Reward creates a target from the distance between the retained entry price and the retained entry terminal.

For a long reference:

Risk Distance = Entry Price − Retained Terminal

Target Price = Entry Price + Risk Distance × Risk/Reward Multiple

For a short reference:

Risk Distance = Retained Terminal − Entry Price

Target Price = Entry Price − Risk Distance × Risk/Reward Multiple

The target is valid only when the retained terminal is on the correct defensive side of the entry price and the resulting risk distance is positive.

For a long reference, the terminal must be below the entry price.

For a short reference, the terminal must be above the entry price.

When the terminal does not produce a positive risk distance, the Risk/Reward target is unavailable. The script does not invent a target by using an absolute distance or moving the terminal to the other side of the entry.

The reference resolves when a confirmed close reaches or passes the valid calculated target.

The exit label is recorded as:

RISK/REWARD TARGET

Confirmed-close target behavior

Both target modes use confirmed closes.

The script does not assume execution at the exact target price when price crosses the target intrabar.

The recorded exit price is the confirmed close of the bar that first satisfies the target condition.

This makes target resolution consistent with the script’s confirmed-close terminal-break behavior.

When a terminal break and target hit are both visible during the same scanned bar, terminal invalidation is given resolution priority in the code and the event is recorded as:

TERMINAL EXIT

Exit identities

The script preserves four separate exit identities:

OPPOSITE EXIT
TERMINAL EXIT
PROFIT TARGET
RISK/REWARD TARGET

These identities are not merged into one generic EXIT label.

This allows the user to distinguish whether the reference resolved because:

an opposite signal confirmed
the retained terminal failed
a fixed percentage target was reached
or the selected risk/reward target was reached

Completed exit records retain:

resolved direction
exit bar
exit price
exit reason

Later chart history does not move the completed exit to a different bar or change its recorded reason.

Signal construction

The internal signal engine uses a causal transform-reference path built from loaded raw-price records.

The transform path is used as a mandatory direction-agreement source for Provisional BUY and SELL confirmation.

The script separately maintains:

raw price arrays
transform path arrays
close, high, and low replay arrays
Provisional signal ledgers
Finalized signal ledgers
structural event ledgers

The transform path and structural resolver remain separate systems.

The transform path confirms Provisional signal direction.

The structural resolver determines which Provisional identity survives into the Finalized ledger.

A structural event does not directly create an entry reference unless Finalized is selected as the Entry Reference Stage and the corresponding Finalized signal record exists.

Transform Path Capturable Segment

Transform Path Capturable Segment percentage controls the captured movement required by the internal transform-reference path.

It is used to retain broader directional legs and reject smaller path pivots.

The setting affects transform-path construction and therefore can affect which candidates pass mandatory path agreement.

It is not an exit target and does not define minimum trade profit.

Structural resolution

The script includes three structural resolver options:

Earliest Terminal
Original Grouping
Conditional Accelerated

Original Grouping is the default.

Earliest Terminal

Earliest Terminal follows the known-prefix earliest terminal chain.

It is intended to retain the earliest causally provable structural terminal under the solver’s rules.

Original Grouping

Original Grouping retains same-side structural candidates as a group.

A later same-side candidate can replace the retained group extreme before an opposite structural candidate resolves the group.

The retained extreme becomes the finalized structural identity when the opposite side completes the structural transition.

Conditional Accelerated

Conditional Accelerated uses captured-path potential after structural proof.

The Structural Capturable Segment percentage applies only to this resolver.

It does not directly filter transform BUY/SELL events or calculate exit targets.

Structural records are prefix-stable and are committed permanently after confirmation.

Structural path and signal context

The script can display:

structural change labels
structural resolution path
Finalized transform BUY/SELL labels
Provisional Candidate signals
failed or superseded Provisional signals
path-disagreed Candidate labels
current live Candidate
live transform-reference path
confirmed support and resistance

These context displays do not change the selected entry-reference stage or exit-resolution method.

Turning a display off hides the object but does not remove its underlying retained ledger.

Entry and exit displays

Entry Reference Markers

Optional Entry Reference Markers show where the selected Provisional or Finalized entry reference was established.

These markers are display-only and do not represent submitted orders.

Resolved Exit Labels

Resolved Exit Labels show completed exit events.

Each label includes the exit identity determined by the resolution condition.

The script limits retained exit labels through the Maximum Exit Labels input.

Older labels are deleted from the chart when the display limit is exceeded. Their removal from the chart does not alter the chronological exit reconstruction used to determine the current active reference.

Active entry level

When Show Active Entry / Terminal Levels is enabled, the active entry confirmation price is displayed as a blue dotted line.

The line starts from the retained entry-reference bar and extends to the right while the reference remains active.

Active terminal level

When terminal-based resolution is enabled, the retained terminal is displayed as an orange dashed line.

For a long reference, this is the price below which a confirmed close produces a terminal exit.

For a short reference, this is the price above which a confirmed close produces a terminal exit.

Active target level

When a valid target mode is enabled, the target is displayed as a green dashed line.

The line appears only when:

an entry reference is active
the selected target mode is not Off
and the target calculation produces a valid price

Minimum Profit % generally produces a target whenever a valid entry price exists.

Risk/Reward requires a valid positive entry-to-terminal risk distance.

Support and resistance

Optional support and resistance levels are derived from confirmed signal terminals.

The user can:

show or hide the levels
extend the levels right
keep or remove broken levels
change line width
control the maximum number of managed chart objects

These levels provide contextual market structure.

They do not replace the retained entry terminal used by the exit-resolution module.

Replay and chronological reconstruction

The script reconstructs the entry-to-exit state from historical Provisional and Finalized signal ledgers.

The selected entry-stage ledger and selected opposite-stage ledger are merged chronologically.

The merge is linear rather than repeatedly sorting the complete combined event list.

This allows the script to preserve event order while avoiding the unnecessary quadratic event sorting that would become increasingly expensive as the number of signal records grows.

For each historical interval, the script checks:

whether the active retained terminal was invalidated
whether an enabled target was reached
whether a qualifying opposite event occurred
whether a new entry reference should be committed after the previous reference resolved

The reconstructed active state at chart end determines:

current active direction
entry price
retained terminal
target price
last exit reason
last exit bar
last exit price

Same-bar event priority

When an entry-stage event and exit-stage event occur on the same bar, the exit-stage event is processed first.

This preserves the prior active reference’s opportunity to resolve before a new reference from the same bar is committed.

It also prevents a newly created same-bar reference from being immediately interpreted as though it existed before the opposite event that appears at the same timestamp.

Performance controls

The script includes:

Statistics-Only Replay
Maximum Replay Objects
Auto Limit Live Replay
Live Replay Bars

Statistics-Only Replay reduces historical chart-object construction while retaining internal calculations.

Maximum Replay Objects limits the number of displayed historical objects.

Auto Limit Live Replay and Live Replay Bars can reduce the amount of live historical drawing on large charts.

These settings primarily control display and replay workload. They do not change the configured exit formulas.

Status pages

The status table includes separate pages for:

Exit State
Signals
Structural
Support/Resistance
Alerts
Guide

Exit State

The Exit State page displays:

selected Entry Stage
selected Opposite Stage
selected Resolution Method
active direction
entry price
retained terminal
last resolution reason
last exit bar
last exit price
selected Target Exit mode
current target price

Target-price display behavior is:

OFF when target exits are disabled
n/a when no reference is active
unavailable when a Risk/Reward target cannot be formed
the formatted target price when the target is valid

Signals

The Signals page summarizes the internal Provisional and Finalized signal state and selected signal context.

Structural

The Structural page displays selected structural resolver information and structural event context.

Support/Resistance

The Support/Resistance page displays level configuration and retained level state.

Alerts

The Alerts page shows whether resolved exit alerts are enabled and whether the current reconstruction produced a long-reference or short-reference exit event.

Guide

The Guide page explains the main output identities and chart-line colors:

retained entry reference
selected-stage opposite exit
confirmed terminal invalidation
target resolution
blue entry line
orange terminal line
green target line

Alerts

The script contains informational alerts for:

Provisional Transform BUY
Provisional Transform SELL
Finalized Transform BUY
Finalized Transform SELL
Long Reference Exit
Short Reference Exit

Provisional alerts are generated from accepted transform-path-agreed Provisional events.

Finalized alerts are generated when structural resolution commits a Finalized BUY or SELL identity.

Exit alerts identify whether a long or short entry reference resolved.

The exit alert title does not distinguish the exact reason in separate alertconditions. The exact chart label and status-table Last Resolution field identify whether the reconstructed exit was:

OPPOSITE EXIT
TERMINAL EXIT
PROFIT TARGET
RISK/REWARD TARGET

Alerts are informational.

They do not contain:

position size
broker account information
order type
stop order
limit order
routing destination
portfolio instruction
or guaranteed execution price

Important behavior note

The script should be understood as:

causal in its signal confirmation
historically stable after closed-bar confirmation
reconstructed chronologically from retained signal ledgers
live-updating only for current open-bar signal and path context

Closed-bar Provisional signals, Finalized signals, entry references, and completed exits are not moved or reclassified by later chart history.

The current open bar can update only the existing live Candidate and transform-reference context inherited from the internal signal engine.

Terminal and target exits use confirmed closes only.

The tool identifies analytical entry-to-exit reference events. It does not confirm that a real order was filled at the displayed price.

Features

Internally generated Provisional BUY/SELL signals
Internally generated Finalized BUY/SELL signals
Selectable Provisional or Finalized Entry Reference Stage
Selectable Provisional or Finalized Opposite Exit Signal Stage
Opposite Signal exit method
Entry Terminal Break exit method
Combined Opposite Or Terminal Break method
Optional profit requirement for opposite exits
Independent Minimum Profit Target
Independent Risk/Reward Target
Entry-to-terminal risk calculation
Confirmed-close target resolution
Confirmed-close terminal invalidation
Separate opposite, terminal, profit-target, and risk/reward exit identities
One retained active entry reference
Chronological entry and exit event reconstruction
Exit-first same-bar event ordering
Linear two-ledger event merge
Permanent closed-bar entry and exit records
Active entry price line
Active retained terminal line
Active target price line
Entry-reference markers
Resolved exit labels
Maximum retained exit-label control
Three selectable structural resolvers
Mandatory causal transform-path agreement
Candidate-bar or next-bar Provisional confirmation
Stored path-filtered Candidate memory
Provisional and Finalized signal ledgers
Failed and superseded Provisional context
Optional structural path
Optional live transform-reference path
Optional support and resistance
Replay and chart-object performance controls
Multiple status-table pages
Informational signal alerts
Informational long-reference and short-reference exit alerts

Strengths

Self-Contained Signal Source — generates its own Provisional and Finalized entry references without requiring another script’s external signal input.

Entry-to-Exit Structure — converts internal BUY/SELL identities into a retained reference with a clearly defined entry price, terminal, target, and exit reason.

Stage Flexibility — allows the entry stage and opposite exit stage to be selected independently.

Exit Method Flexibility — supports opposite confirmation, terminal invalidation, or whichever valid event occurs first.

Independent Target Logic — fixed-profit and risk/reward targets can resolve the reference without waiting for an opposite signal.

Opposite Profit Gate — can prevent an unprofitable opposite signal from resolving the reference while leaving terminal and target exits active.

Identity Separation — opposite, terminal, fixed-profit, and risk/reward exits remain distinguishable.

Terminal Consistency — uses the terminal retained by the same signal identity that established the entry reference.

Confirmed-Close Stability — terminal and target exits do not depend on unfinished intrabar movement.

Chronological Reconstruction — historical state is rebuilt in event order rather than inferred only from the latest signal.

Same-Bar Ordering — exit-stage processing precedes entry-stage processing when both events occur on the same bar.

Performance-Aware Merge — merges already chronological signal ledgers directly instead of repeatedly sorting a combined event array.

Long and Short Symmetry — applies entry, opposite, terminal, and target calculations to both long and short references.

Visual Clarity — separates entry price, terminal price, and target price with distinct chart lines.

Context Availability — retains optional Provisional, Finalized, structural, path, and support/resistance displays.

Weaknesses

Signal Dependence — exit quality depends on the quality and timing of the internally generated Provisional or Finalized entry reference.

No Universal Best Stage — Provisional entries are earlier but less structurally resolved; Finalized entries are more confirmed but later.

Confirmed-Close Delay — terminal and target exits can occur later than an intrabar crossing.

Close-Price Exit Recording — the recorded exit price is the confirmation-bar close, not necessarily the exact target or terminal price touched intrabar.

No Partial Exits — each retained reference resolves as one complete analytical state rather than splitting into multiple exit quantities.

No Trailing Target — the fixed-profit and risk/reward targets do not trail favorable movement.

Static Entry Terminal — the retained terminal belongs to the entry identity and is not dynamically replaced with every later structural level.

Risk/Reward Availability — a risk/reward target cannot be formed when the retained terminal is not on the correct defensive side of the entry price.

Opposite Profit-Gate Persistence — an opposite signal that fails the profit gate is ignored rather than stored as a pending opposite exit.

No Complete Strategy Return — the tool does not calculate commissions, slippage, quantity, capital allocation, or portfolio equity.

No Broker Execution — displayed exits and alerts do not prove that a real order would fill at the same price.

One Active Reference — the script does not maintain simultaneous independent long and short references or multiple scaled entries.

Historical Reconstruction Cost — although the event merge is linear, the script still performs substantial transform, structural, replay, and chart-object work on large charts.

Parameter Sensitivity — transform capture, structural solver, entry stage, opposite stage, target percentage, and reward multiple can materially change results.

No Universal Profitability — structured exits do not guarantee that the underlying entries have sufficient predictive edge.

Who it’s for

This tool is best suited for:

TradingView users who want an exit-focused companion to transform-based entry signals
traders comparing Provisional and Finalized entry timing
users studying opposite-signal exit timing
users testing retained-terminal invalidation
users testing fixed minimum-profit targets
users testing entry-terminal risk/reward targets
reversal and market-structure traders
users who want long and short exit references
users who want historically stable closed-bar exit labels
users who want one retained entry reference at a time
users interested in causal transform-path agreement
users developing an exit framework before integrating position sizing or routing
research-oriented users comparing multiple exit identities
users who want chart-based exit analysis without a complete strategy engine

Who it’s not for

This tool is not best suited for:

users looking for guaranteed profitable exits
users expecting the script to know the best future exit in advance
users looking for automatic broker execution
users requiring position sizing or account-risk calculations
users requiring partial profit taking
users requiring multiple simultaneous entries
users requiring dynamic trailing stops
users requiring intrabar target or stop execution
users expecting target price to guarantee actual fill price
users wanting complete strategy-equity reconstruction
users wanting commissions, slippage, leverage, or margin modeling
users expecting Provisional or Finalized signals to universally identify profitable trades
users seeking a complete operational transform engine with split quantities, portfolio state, or order routing

Known limitations

The tool is better at:

retaining a consistent entry reference
showing multiple structured exit conditions
distinguishing why an exit occurred
comparing Provisional and Finalized signal stages
visualizing entry, terminal, and target prices
and reconstructing closed-bar entry-to-exit state

than it is at:

predicting which entry will succeed
guaranteeing that a selected target will be reached
guaranteeing that a terminal exit will contain loss
finding the best possible future exit
or reproducing real broker fills

A fixed-profit target can improve consistency but can also exit before a larger move develops.

A risk/reward target can align the target with entry-terminal distance, but the retained terminal may not represent the user’s actual financial risk or intended stop placement.

An opposite signal can respond to changing structure, but it can arrive late or be ignored when Require Profit For Opposite Exit is enabled and the profit requirement is not met.

A terminal exit can preserve the entry identity’s invalidation point, but confirmed-close evaluation can exit beyond the terminal after a fast move.

These are structural exit references, not guarantees of favorable trade outcomes.

Final note

Entry-to-Exit Tool is a focused indicator for converting internally generated Provisional or Finalized BUY/SELL signals into retained entry references and resolving those references through explicitly defined exit conditions.

Its main value is not that it predicts the perfect exit. Its value is that it makes the exit framework visible and consistent:

which stage opened the reference
which stage can provide the opposite exit
which terminal belongs to the entry
whether an opposite exit requires profit
whether a fixed or risk/reward target is active
which condition actually resolved the reference
and where that resolution occurred on a confirmed close

The tool should be viewed as an entry-to-exit analysis layer, not as a complete strategy, broker-execution system, or guarantee of profitability.

It provides more structured exit information than an entry-only signal script while stopping before quantities, partial positions, portfolio state, order routing, and full operational trade management.

---

## Source Code

````pine
// © AceInfinity
// Entry-to-Exit Tool
// This indicator resolves one exit output from an internally retained Provisional or Finalized entry reference.
// The user selects the signal stage that establishes the entry reference, the signal stage used for opposite exits, and the exit-resolution method.
// Opposite Signal resolves the active reference when the selected opposite BUY/SELL signal confirms. Entry Terminal Break resolves it when a confirmed close invalidates the retained entry terminal. Opposite Or Terminal Break commits whichever valid signal or terminal event occurs first.
// Target Exit can independently resolve the active reference at a user-selected minimum-profit percentage or at a reward multiple of the entry-to-terminal risk distance.
// Require Profit For Opposite Exit can delay only an opposite-signal exit until the configured raw-price profit is available. It never delays an entry-terminal break or target exit.
// Provisional entry references use accepted transform-path-agreed BUY/SELL confirmations. Finalized entry references use structurally retained BUY/SELL confirmations.
// Each active entry reference retains its direction, confirmation bar, confirmation price, and terminal price until one enabled exit condition resolves it.
// An exit record retains the resolved side, exit bar, exit price, and exit reason. Completed records are not rewritten after later chart history arrives.
// Entry-reference events and exit-stage events are replayed in chronological order. Exit-stage events are processed before entry-stage events when both occur on the same bar.
// Entry Terminal Break and Target Exit use confirmed closes only. A long reference resolves below its retained terminal or at/above its target; a short reference resolves above its retained terminal or at/below its target.
// Opposite-signal, terminal-break, minimum-profit-target, and risk/reward-target exits remain separate exit identities.
// Entry-reference markers, exit labels, the active entry-price line, and the active terminal-exit line remain separate display outputs.
// Provisional, finalized, structural, path, and support/resistance outputs remain available as optional signal context and do not alter exit resolution.
// Exit alerts are informational and do not contain quantities, order-routing instructions, or broker commands.
// The script does not create positions, size trades, calculate strategy profitability, reverse positions, submit orders, or manage a portfolio.
// Closed-bar signal, entry-reference, and exit records are permanent and are not moved or reclassified by later chart history.
// The current open bar can update only existing live signal and reference-path context inherited from the signal engine.
// This script is designed for inspection, testing, and personal use. It is not financial advice.
//@version=6
indicator("Entry-to-Exit Tool", shorttitle="Trade Exit Tool", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=2000, max_bars_back=5000)

//==================================================================================================
// SECTION 1 — STRUCTURAL RESOLUTION, TRANSFORM SIGNALS, PATH, AND DISPLAY INPUTS
//==================================================================================================
src = input.source(close, "Source")
atrLen = input.int(14, "ATR Length", minval=1)

structuralMode = input.string("Original Grouping", "Structural Change Resolver", options=["Earliest Terminal", "Original Grouping", "Conditional Accelerated"], tooltip="Selects the independent structural PEAK/TROUGH resolver. Structural changes classify transform signals but never create entries or exits.")
structuralLength = input.int(10, "Structural Length", minval=1, tooltip="Structural context used by all three structural-change modes.")
structuralCapturablePct = input.float(20.0, "Structural Capturable Segment %", minval=0.01, step=0.05, tooltip="Used only by Conditional Accelerated structural resolution. It selects captured path potential after structural proof; it does not filter transform BUY/SELL events.")
showStructuralChangeLabels = input.bool(true, "Show Structural Change Labels")
plotStructuralAtConfirmBar = input.bool(false, "Plot Structural Change At Confirmation Bar")
showStructuralPath = input.bool(true, "Show Structural Resolution Path")

refPathMinCapturedPathPct = input.float(20.0, "Transform Path Capturable Segment %", minval=0.01, step=0.05, tooltip="Controls the solved transform path used for mandatory entry/exit agreement.")
showLiveEntryReferencePath = input.bool(false, "Show Live Transform Reference Path")
entryReferenceUpdateLiveBar = input.bool(true, "Update Transform Reference While Live Bar Is Open")
maxCandidateEntryDelayBars = input.int(1, "Maximum Signal Confirmation Delay Bars", minval=0, maxval=1, tooltip="Retained transform candidates can confirm on the candidate bar or following bar. This does not alter structural-change resolution.")

showSignals = input.bool(false, "Show Finalized Transform BUY/SELL Labels")
showProvisionalCandidateSignals = input.bool(false, "Show Provisional Candidate Signals", tooltip="Shows accepted causal path-agreed candidates before structural finalization. These records remain provisional until the selected structural resolver completes the containing swing.")
showFailedCandidateSignals = input.bool(false, "Show Failed / Superseded Provisional Signals", tooltip="Shows provisional candidates that were not selected when their structural swing finalized.")
showFilteredCandidateLabels = input.bool(false, "Show Path-Disagreed Candidate Labels")
keepOnlyLastPair = input.bool(false, "Keep Only Last BUY/SELL Pair")
showDetailedLabelText = input.bool(false, "Show Detailed Signal Text")
showLiveCandidateLabel = input.bool(false, "Show Current Transform Candidate")
keepActiveFilteredCandidate = input.bool(true, "Keep Active Path-Filtered Candidate Memory", tooltip="OFF: a valid candidate blocked by mandatory transform-path direction agreement is discarded after that blocked attempt. ON: the valid blocked candidate terminal is stored separately and can be accepted later on the first closed bar where the causal transform reference direction agrees with its side. The later passing bar close is stored as the actual confirmation bar and price. Structural-change state never controls this memory.")
plotAtConfirmBar = input.bool(false, "Plot Finalized Signal At Finalization Bar", tooltip="ON plots a finalized BUY at the structural finalization bar low and a finalized SELL at the structural finalization bar high. OFF plots the same finalized identity at its retained structural terminal.")
immediateSignalTransparency = input.int(20, "Transform Signal Label Transparency", minval=0, maxval=90)


showReplayHistoricalLabels = input.bool(true, "Show Replay Historical Labels")
optReplayStatsOnly = input.bool(false, "Performance: Statistics-Only Replay")
optMaxReplayObjects = input.int(260, "Performance: Maximum Replay Objects", minval=50, maxval=500)
autoLimitLiveProvisionalReplay = input.bool(false, "Auto Limit Live Replay")
liveProvisionalReplayBars = input.int(1400, "Live Replay Bars", minval=250, maxval=2500, step=50)

showConfirmedSupportResistance = input.bool(false, "Show Confirmed Support / Resistance")
extendConfirmedSupportResistance = input.bool(true, "Extend Support / Resistance Right")
keepBrokenSupportResistanceLevels = input.bool(false, "Keep Broken Support / Resistance")
supportResistanceWidth = input.int(2, "Support / Resistance Width", minval=1, maxval=5)
maxManagedEventObjects = input.int(450, "Maximum Managed Objects", minval=50, maxval=500)

enableProvisionalSignalAlerts = input.bool(false, "Enable Provisional Signal Alerts", tooltip="Enables informational BUY/SELL alerts when a causal path-agreed candidate is accepted into the provisional ledger. This does not create or modify any position state.")
enableFinalizedSignalAlerts = input.bool(false, "Enable Finalized Signal Alerts", tooltip="Enables informational BUY/SELL alerts when structural resolution commits a provisional candidate into the official finalized signal ledger. This does not create or modify any position state.")

showStatus = input.bool(true, "Show Status Table")
statusPage = input.string("Exit State", "Status Table Page", options=["Exit State", "Signals", "Structural", "Support/Resistance", "Alerts", "Guide"])

// Entry-reference and exit-resolution settings.
entryReferenceStage = input.string("Provisional", "Entry Reference Stage", options=["Provisional", "Finalized"], tooltip="Selects the internally generated signal stage that opens each retained entry reference. Provisional uses the accepted transform-path-agreed confirmation. Finalized uses the later structurally retained confirmation. This is a fixed stage selection and does not reproduce objective-based confirmation-stage selection.")
exitSignalStage = input.string("Provisional", "Opposite Exit Signal Stage", options=["Provisional", "Finalized"], tooltip="Selects the internally generated opposite signal stage that can resolve an active entry reference. Provisional uses the accepted transform-path-agreed opposite confirmation. Finalized uses the structurally retained opposite confirmation.")
exitMethod = input.string("Opposite Or Terminal Break", "Exit Resolution Method", options=["Opposite Signal", "Entry Terminal Break", "Opposite Or Terminal Break"], tooltip="Opposite Signal resolves the active entry reference when the selected opposite signal stage confirms. Entry Terminal Break resolves it when a confirmed close crosses the retained entry terminal against the active direction. Opposite Or Terminal Break commits the first valid enabled exit event.")
requireProfitForOppositeExit = input.bool(true, "Require Profit For Opposite Exit", tooltip="OFF resolves every accepted opposite signal. ON resolves an opposite signal only when the active entry reference has reached the configured minimum raw-price profit. This setting never blocks an Entry Terminal Break.")
minimumProfitForOppositeExitPct = input.float(0.0, "Minimum Profit For Opposite Exit %", minval=0.0, step=0.05)

targetExitMode = input.string("Off", "Target Exit", options=["Off", "Minimum Profit %", "Risk/Reward"], tooltip="Off disables target exits. Minimum Profit % resolves the active entry reference when a confirmed close reaches the selected raw-price profit. Risk/Reward sets the target from the retained entry-to-terminal risk distance multiplied by the selected reward multiple.")
minimumProfitTargetPct = input.float(2.0, "Minimum Profit Target %", minval=0.01, step=0.05)
riskRewardMultiple = input.float(2.0, "Risk/Reward Multiple", minval=0.1, step=0.1, tooltip="For a long reference, risk is Entry Price minus Retained Terminal. For a short reference, risk is Retained Terminal minus Entry Price. The target is Entry Price plus or minus that risk distance multiplied by this value.")

showEntryReferenceMarkers = input.bool(false, "Show Entry Reference Markers")
showExitLocations = input.bool(true, "Show Resolved Exit Labels")
showActiveExitReference = input.bool(true, "Show Active Entry / Terminal Levels")
keepOnlyRecentExitLabels = input.int(160, "Maximum Exit Labels", minval=20, maxval=450)

enableExitAlerts = input.bool(false, "Enable Resolved Exit Alerts", tooltip="Enables informational alerts when an Opposite Signal or Entry Terminal Break resolves the active entry reference. Alerts contain no quantity, routing, order, or broker instructions.")

// Mandatory transform-path agreement constants. They are not user-disableable.
bool useReferencePathAgreementEntryFilter = true
bool useReferencePathAgreementForShortEntry = true

//==================================================================================================
// SECTION 2 — TRANSFORM AND DISPLAY HELPERS
//==================================================================================================
atrV = ta.atr(atrLen)
eps = math.max(syminfo.mintick, 1e-6)
f_sign(x)=>x > 0.0 ? 1 : x < 0.0 ? -1 : 0
safeDiv(_n,_d)=>_d == 0.0 ? 0.0 : _n / _d
f_tanh(_x)=>
    float e2x = math.exp(2.0 * _x)
    (e2x - 1.0) / (e2x + 1.0)
f_erfApprox(_x)=>
    float s = _x < 0.0 ? -1.0 : 1.0
    float ax = math.abs(_x)
    float t = 1.0 / (1.0 + 0.3275911 * ax)
    float poly = (((((1.061405429 * t - 1.453152027) * t + 1.421413741) * t - 0.284496736) * t + 0.254829592) * t)
    s * (1.0 - poly * math.exp(-ax * ax))
f_normcdf(_x)=>0.5 * (1.0 + f_erfApprox(_x / math.sqrt(2.0)))
f_updateCumMove(float _cum,int _dirStore,int _stepSign,float _step)=>
    _stepSign == 0 ? _cum : (_dirStore == 0 or _stepSign == _dirStore ? _cum + _step : _step)
f_labelProbTxt(float _p)=>na(_p) ? "n/a" : str.tostring(_p * 100.0, "#.0") + "%"
f_clearLabelArr(label[] a)=>
    if array.size(a) > 0
        for i = 0 to array.size(a) - 1
            label.delete(array.get(a, i))
    array.clear(a)
f_clearLineArr(line[] a)=>
    if array.size(a) > 0
        for i = 0 to array.size(a) - 1
            line.delete(array.get(a, i))
    array.clear(a)
f_clearBoxArr(box[] a)=>
    if array.size(a) > 0
        for i = 0 to array.size(a) - 1
            box.delete(array.get(a, i))
    array.clear(a)
f_statusCell(table t, int row, string left, string right) =>
    table.cell(t, 0, row, left, text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(t, 1, row, right, text_color=color.white, bgcolor=color.new(color.black, 20))
f_pushRefBody(box[] _a,int _x,float _o,float _c,color _fallbackCol)=>
    color _col = _c > _o ? color.lime : _c < _o ? color.red : _fallbackCol
    float _top = math.max(_o, _c)
    float _bot = math.min(_o, _c)
    if math.abs(_top - _bot) <= eps
        _top += eps * 10.0
        _bot -= eps * 10.0
    array.push(_a, box.new(_x - 1, _top, _x, _bot, xloc=xloc.bar_index, border_color=_col, bgcolor=color.new(_col, 0)))
f_pushRefReplaySegment(box[] _a,int _base,int _s,int _e,float[] _vals,int _drawStart)=>
    if not na(_s) and not na(_e) and _e > _s and array.size(_vals) > _e
        int _st = math.max(_s + 1, _drawStart)
        if _st <= _e
            for _j = _st to _e
                float _o = array.get(_vals, _j - 1)
                float _c = array.get(_vals, _j)
                if not na(_o) and not na(_c)
                    f_pushRefBody(_a, _base + _j, _o, _c, color.gray)
f_pushRefLeg(box[] _a,int _base,int _s,float _sPx,int _e,float _ePx,int _drawStart)=>
    if not na(_s) and not na(_e) and _e > _s and not na(_sPx) and not na(_ePx)
        int _st = math.max(_s + 1, _drawStart)
        int _span = math.max(_e - _s, 1)
        if _st <= _e
            for _j = _st to _e
                float _t0 = float(_j - 1 - _s) / float(_span)
                float _t1 = float(_j - _s) / float(_span)
                f_pushRefBody(_a, _base + _j, _sPx + (_ePx - _sPx) * _t0, _sPx + (_ePx - _sPx) * _t1, color.gray)
f_pushRefPerfectSegment(box[] _a,int _base,int _s,float _sPx,int _e,float _ePx,float[] _hi,float[] _lo,int _drawStart)=>
    if not na(_s) and not na(_e) and _e > _s and not na(_sPx) and not na(_ePx) and array.size(_hi) > _e and array.size(_lo) > _e
        int _dir = _ePx > _sPx ? 1 : _ePx < _sPx ? -1 : 0
        int _lastIdx = _s
        float _lastPx = _sPx
        float _acceptedPx = _sPx
        if _dir != 0 and _e - _s > 1
            for _j = _s + 1 to _e - 1
                float _midPx = _dir > 0 ? array.get(_hi, _j) : array.get(_lo, _j)
                bool _newDirectionalExtreme = _dir > 0 ? _midPx > _acceptedPx : _midPx < _acceptedPx
                bool _insideFinalLeg = _dir > 0 ? _midPx < _ePx : _midPx > _ePx
                if _newDirectionalExtreme and _insideFinalLeg
                    f_pushRefLeg(_a, _base, _lastIdx, _lastPx, _j, _midPx, _drawStart)
                    _acceptedPx := _midPx
                    _lastIdx := _j
                    _lastPx := _midPx
        f_pushRefLeg(_a, _base, _lastIdx, _lastPx, _e, _ePx, _drawStart)
f_setRefLegDir(int[] _a,int _s,float _sPx,int _e,float _ePx,int _drawStart)=>
    if not na(_s) and not na(_e) and _e > _s and not na(_sPx) and not na(_ePx)
        int _st = math.max(_s + 1, _drawStart)
        int _d = f_sign(_ePx - _sPx)
        if _st <= _e and _d != 0
            for _j = _st to _e
                if _j >= 0 and _j < array.size(_a)
                    array.set(_a, _j, _d)
f_markRefPerfectSegmentDir(int[] _a,int _s,float _sPx,int _e,float _ePx,float[] _hi,float[] _lo,int _drawStart)=>
    if not na(_s) and not na(_e) and _e > _s and not na(_sPx) and not na(_ePx) and array.size(_hi) > _e and array.size(_lo) > _e
        int _dir = _ePx > _sPx ? 1 : _ePx < _sPx ? -1 : 0
        int _lastIdx = _s
        float _lastPx = _sPx
        float _acceptedPx = _sPx
        if _dir != 0 and _e - _s > 1
            for _j = _s + 1 to _e - 1
                float _midPx = _dir > 0 ? array.get(_hi, _j) : array.get(_lo, _j)
                bool _newDirectionalExtreme = _dir > 0 ? _midPx > _acceptedPx : _midPx < _acceptedPx
                bool _insideFinalLeg = _dir > 0 ? _midPx < _ePx : _midPx > _ePx
                if _newDirectionalExtreme and _insideFinalLeg
                    f_setRefLegDir(_a, _lastIdx, _lastPx, _j, _midPx, _drawStart)
                    _acceptedPx := _midPx
                    _lastIdx := _j
                    _lastPx := _midPx
        f_setRefLegDir(_a, _lastIdx, _lastPx, _e, _ePx, _drawStart)
f_candBar(int _bar,bool _filtered)=>_filtered ? -(_bar + 1) : (_bar + 1)
f_candIdx(int _bar)=>na(_bar) ? na : math.abs(_bar) - 1

f_replayLblsOn()=>not optReplayStatsOnly and showReplayHistoricalLabels and showSignals
f_filteredLblsOn()=>f_replayLblsOn() and showFilteredCandidateLabels
f_pushReplayLbl(label[] _a,int _bar,float _y,string _txt,string _style,color _col)=>
    array.push(_a, label.new(_bar, _y, _txt, xloc=xloc.bar_index, style=_style, textcolor=color.white, color=_col, size=size.tiny))
f_refEntryGate(bool _buy,bool _cand,int _dir,bool _flat)=>
    bool _refOn = useReferencePathAgreementEntryFilter and (_buy or useReferencePathAgreementForShortEntry)
    bool _side = _dir == (_buy ? 1 : -1) and not _flat
    not _refOn or (_cand and _side)

f_rangeMin(float[] _tree,int _size,int _left,int _right)=>
    float _result = 1e100
    int _l = _left + _size
    int _r = _right + _size
    while _l <= _r
        if _l % 2 == 1
            _result := math.min(_result, array.get(_tree, _l))
            _l += 1
        if _r % 2 == 0
            _result := math.min(_result, array.get(_tree, _r))
            _r -= 1
        _l := int(math.floor(_l / 2))
        _r := int(math.floor(_r / 2))
    _result

f_rangeMax(float[] _tree,int _size,int _left,int _right)=>
    float _result = -1e100
    int _l = _left + _size
    int _r = _right + _size
    while _l <= _r
        if _l % 2 == 1
            _result := math.max(_result, array.get(_tree, _l))
            _l += 1
        if _r % 2 == 0
            _result := math.max(_result, array.get(_tree, _r))
            _r -= 1
        _l := int(math.floor(_l / 2))
        _r := int(math.floor(_r / 2))
    _result

f_firstBelow(float[] _tree,int _size,int _left,int _right,float _threshold)=>
    int _found = na
    if _left <= _right and f_rangeMin(_tree, _size, _left, _right) < _threshold
        int _lo = _left
        int _hi = _right
        while _lo < _hi
            int _mid = int(math.floor((_lo + _hi) / 2))
            if f_rangeMin(_tree, _size, _lo, _mid) < _threshold
                _hi := _mid
            else
                _lo := _mid + 1
        _found := _lo
    _found

f_firstAbove(float[] _tree,int _size,int _left,int _right,float _threshold)=>
    int _found = na
    if _left <= _right and f_rangeMax(_tree, _size, _left, _right) > _threshold
        int _lo = _left
        int _hi = _right
        while _lo < _hi
            int _mid = int(math.floor((_lo + _hi) / 2))
            if f_rangeMax(_tree, _size, _lo, _mid) > _threshold
                _hi := _mid
            else
                _lo := _mid + 1
        _found := _lo
    _found

//==================================================================================================
// SECTION 3 — TRANSFORM AND REFERENCE-PATH CONSTRUCTION
//==================================================================================================
f_easeSeg(float _aPx,float _bPx,int _aBar,int _bBar,int _currBar)=>
    int _span = math.max(_bBar - _aBar, 1)
    float _t = math.max(0.0, math.min(1.0, float(_currBar - _aBar) / float(_span)))
    float _te = _t * _t * (3.0 - 2.0 * _t)
    _aPx + (_bPx - _aPx) * _te
f_softSeg(float _aPx,float _bPx,float _thr)=>
    float _dist = math.abs(_bPx - _aPx)
    float _alpha = _dist / math.max(_thr, eps)
    float _a = math.max(0.0, math.min(1.0, _alpha))
    float _ae = _a * _a * (3.0 - 2.0 * _a)
    _aPx + (_bPx - _aPx) * _ae
f_clamp(float _x,float _lo,float _hi)=>
    math.max(_lo, math.min(_hi, _x))
f_smooth01(float _x)=>
    float _c = math.max(0.0, math.min(1.0, _x))
    _c * _c * (3.0 - 2.0 * _c)
f_pickRefPathMid(float _aPx,float _bPx,float _hiPx,int _hiIdx,float _loPx,int _loIdx)=>
    float _hiPath = math.abs(_hiPx - _aPx) + math.abs(_bPx - _hiPx)
    float _loPath = math.abs(_loPx - _aPx) + math.abs(_bPx - _loPx)
    int _midIdx = _hiPath >= _loPath ? _hiIdx : _loIdx
    float _midPx = _hiPath >= _loPath ? _hiPx : _loPx
    [_midIdx, _midPx]
f_prevRefPathVal(int _sIdx,float _sPx,int _mIdx,float _mPx,int _eIdx,float _ePx,int _pIdx)=>
    float _v = _sPx
    if _pIdx > _sIdx
        if _mIdx > _sIdx and _mIdx < _eIdx
            if _pIdx <= _mIdx
                int _spanA = math.max(_mIdx - _sIdx, 1)
                float _tA = math.max(0.0, math.min(1.0, float(_pIdx - _sIdx) / float(_spanA)))
                float _teA = _tA * _tA * (3.0 - 2.0 * _tA)
                _v := _sPx + (_mPx - _sPx) * _teA
            else
                int _spanB = math.max(_eIdx - _mIdx, 1)
                float _tB = math.max(0.0, math.min(1.0, float(_pIdx - _mIdx) / float(_spanB)))
                float _ptB = _tB * _tB * (3.0 - 2.0 * _tB)
                _v := _mPx + (_ePx - _mPx) * _ptB
        else
            int _span = math.max(_eIdx - _sIdx, 1)
            float _t = math.max(0.0, math.min(1.0, float(_pIdx - _sIdx) / float(_span)))
            float _te = _t * _t * (3.0 - 2.0 * _t)
            _v := _sPx + (_ePx - _sPx) * _te
    _v
f_prevRefPathLast(int _sIdx,float _sPx,int _mIdx,float _mPx,int _eIdx,float _ePx)=>
    // Reads the most recent retained directional path value before the requested endpoint.
    // Used by the replay builder hot loop to avoid the general midpoint/path function overhead.
    int _pIdx = _eIdx - 1
    float _v = _sPx
    if _pIdx > _sIdx
        if _mIdx > _sIdx and _mIdx < _eIdx
            if _pIdx <= _mIdx
                _v := _mPx
            else
                int _spanB = math.max(_eIdx - _mIdx, 1)
                float _tB = float(_pIdx - _mIdx) / float(_spanB)
                float _ptB = _tB * _tB * (3.0 - 2.0 * _tB)
                _v := _mPx + (_ePx - _mPx) * _ptB
        else
            int _span = math.max(_eIdx - _sIdx, 1)
            float _t = float(_pIdx - _sIdx) / float(_span)
            float _te = _t * _t * (3.0 - 2.0 * _t)
            _v := _sPx + (_ePx - _sPx) * _te
    _v
f_livePivotState(float _src,float _prevSrc,float _aPx,int _aBar,float _cPx,int _cBar,int _dir,int _bar)=>
    // Live retained transform-path state built from executable candidate extrema.
    // The active candidate peak/trough is available on its own bar close. When the first
    // opposite close appears, the segment anchor moves to that already-seen candidate
    // extreme, not to the later opposite close. This prevents the reference path from
    // starting at 24 after a 20 -> 25 -> 24 sequence; the executable candidate extreme was 25.
    float a = nz(_aPx, _src)
    int ab = nz(_aBar, _bar)
    float c = nz(_cPx, a)
    int cb = nz(_cBar, ab)
    int d = _dir
    float prev = nz(_prevSrc, _src)
    int sd = f_sign(_src - prev)
    if d == 0
        if sd != 0
            c := _src
            cb := _bar
            d := sd
    else if d > 0
        if _src >= c
            c := _src
            cb := _bar
        else if sd < 0
            a := c
            ab := cb
            c := _src
            cb := _bar
            d := -1
    else
        if _src <= c
            c := _src
            cb := _bar
        else if sd > 0
            a := c
            ab := cb
            c := _src
            cb := _bar
            d := 1
    [a, ab, c, cb, d]


f_buildReferencePathArrays(float[] _rawPx,int _nBars)=>
    // Builds the chart-end reference path from loaded close data.
    // Step 1: collect actual local close extrema from loaded close data.
    // Step 2: merge out alternating segments smaller than refPathMinCapturedPathPct.
    // This does not wait for movement away from an old extreme. A higher value can remove
    // earlier small pivots so the kept start becomes the earliest executable bar capable of
    // actually capturing the required close-close move.
    int[] _pivIdx = array.new_int()
    float[] _pivPx = array.new_float()
    float _cumTmp = 0.0
    int _prevStepDir = 0
    float _lastClose = na
    float _lastOpen = na
    int _lastDir = 0
    if _nBars <= 0 or array.size(_rawPx) == 0
        float[] _emptyPath = array.new_float()
        [_pivIdx, _pivPx, _emptyPath, _cumTmp, _lastClose, _lastOpen, _lastDir]
    else
        float _firstPx = array.get(_rawPx, 0)
        array.push(_pivIdx, 0)
        array.push(_pivPx, _firstPx)
        if _nBars > 2
            for _i = 1 to _nBars - 2
                float _pp = array.get(_rawPx, _i - 1)
                float _p = array.get(_rawPx, _i)
                float _pn = array.get(_rawPx, _i + 1)
                bool _hi = (_p >= _pp and _p > _pn) or (_p > _pp and _p >= _pn)
                bool _lo = (_p <= _pp and _p < _pn) or (_p < _pp and _p <= _pn)
                if _hi or _lo
                    int _sz = array.size(_pivIdx)
                    float _lastPx = array.get(_pivPx, _sz - 1)
                    if _sz == 1
                        if math.abs(_p - _lastPx) > eps
                            array.push(_pivIdx, _i)
                            array.push(_pivPx, _p)
                    else
                        float _prevPivPx = array.get(_pivPx, _sz - 2)
                        int _lastLegDir = _lastPx > _prevPivPx ? 1 : _lastPx < _prevPivPx ? -1 : 0
                        int _newLegDir = _p > _lastPx ? 1 : _p < _lastPx ? -1 : 0
                        if _newLegDir != 0
                            if _newLegDir == _lastLegDir
                                if (_lastLegDir > 0 and _p > _lastPx) or (_lastLegDir < 0 and _p < _lastPx)
                                    array.set(_pivIdx, _sz - 1, _i)
                                    array.set(_pivPx, _sz - 1, _p)
                            else
                                array.push(_pivIdx, _i)
                                array.push(_pivPx, _p)
        float _endPx = array.get(_rawPx, _nBars - 1)
        int _szEnd = array.size(_pivIdx)
        float _lastEndPx = array.get(_pivPx, _szEnd - 1)
        if _nBars - 1 != array.get(_pivIdx, _szEnd - 1) and math.abs(_endPx - _lastEndPx) > eps
            if _szEnd == 1
                array.push(_pivIdx, _nBars - 1)
                array.push(_pivPx, _endPx)
            else
                float _prevEndPx = array.get(_pivPx, _szEnd - 2)
                int _lastEndDir = _lastEndPx > _prevEndPx ? 1 : _lastEndPx < _prevEndPx ? -1 : 0
                int _newEndDir = _endPx > _lastEndPx ? 1 : _endPx < _lastEndPx ? -1 : 0
                if _newEndDir == _lastEndDir
                    if (_lastEndDir > 0 and _endPx > _lastEndPx) or (_lastEndDir < 0 and _endPx < _lastEndPx)
                        array.set(_pivIdx, _szEnd - 1, _nBars - 1)
                        array.set(_pivPx, _szEnd - 1, _endPx)
                    else
                        array.push(_pivIdx, _nBars - 1)
                        array.push(_pivPx, _endPx)
                else if _newEndDir != 0
                    array.push(_pivIdx, _nBars - 1)
                    array.push(_pivPx, _endPx)
        bool _changed = true
        int _guard = 0
        while _changed and array.size(_pivIdx) > 2 and _guard < 5000
            _changed := false
            _guard += 1
            int _k = 0
            while _k < array.size(_pivIdx) - 1 and not _changed
                float _a = array.get(_pivPx, _k)
                float _b = array.get(_pivPx, _k + 1)
                float _segPct = math.abs(_b - _a) * 100.0 / math.max(math.abs(_a), eps)
                if _segPct < refPathMinCapturedPathPct
                    int _last = array.size(_pivIdx) - 1
                    if _k == 0
                        array.remove(_pivIdx, 1)
                        array.remove(_pivPx, 1)
                    else if _k + 1 == _last
                        array.remove(_pivIdx, _k)
                        array.remove(_pivPx, _k)
                    else
                        array.remove(_pivIdx, _k + 1)
                        array.remove(_pivPx, _k + 1)
                        array.remove(_pivIdx, _k)
                        array.remove(_pivPx, _k)
                    _changed := true
                _k += 1
        bool _domChanged = true
        int _domGuard = 0
        while _domChanged and array.size(_pivIdx) > 3 and _domGuard < 5000
            _domChanged := false
            _domGuard += 1
            int _kd = 0
            while _kd <= array.size(_pivIdx) - 4 and not _domChanged
                float _aD = array.get(_pivPx, _kd)
                float _bD = array.get(_pivPx, _kd + 1)
                float _cD = array.get(_pivPx, _kd + 2)
                float _dD = array.get(_pivPx, _kd + 3)
                bool _upDnUp = _bD > _aD and _cD < _bD and _dD > _cD
                bool _dnUpDn = _bD < _aD and _cD > _bD and _dD < _cD
                bool _mergeDominated = (_upDnUp and _bD <= _cD) or (_dnUpDn and _bD >= _cD)
                if _mergeDominated
                    array.remove(_pivIdx, _kd + 2)
                    array.remove(_pivPx, _kd + 2)
                    array.remove(_pivIdx, _kd + 1)
                    array.remove(_pivPx, _kd + 1)
                    _domChanged := true
                _kd += 1
        if array.size(_pivIdx) == 0
            array.push(_pivIdx, 0)
            array.push(_pivPx, _firstPx)
        if array.get(_pivIdx, array.size(_pivIdx) - 1) != _nBars - 1
            array.push(_pivIdx, _nBars - 1)
            array.push(_pivPx, array.get(_rawPx, _nBars - 1))
        float[] _pathClose = array.new_float(_nBars, na)
        if array.size(_pivIdx) == 1
            for _i = 0 to _nBars - 1
                array.set(_pathClose, _i, array.get(_pivPx, 0))
        else
            for _s = 0 to array.size(_pivIdx) - 2
                int _sIdx = array.get(_pivIdx, _s)
                int _eIdx = array.get(_pivIdx, _s + 1)
                float _sPx = array.get(_pivPx, _s)
                float _ePx = array.get(_pivPx, _s + 1)
                int _macroDir = _ePx > _sPx ? 1 : _ePx < _sPx ? -1 : 0
                int _lastSegIdx = _sIdx
                float _lastSegPx = _sPx
                float _lastAcceptedPx = _sPx
                if _macroDir != 0 and _eIdx - _sIdx > 1
                    for _j = _sIdx + 1 to _eIdx - 1
                        float _pMid = array.get(_rawPx, _j)
                        bool _newDirectionalExtreme = _macroDir == 1 ? _pMid > _lastAcceptedPx : _pMid < _lastAcceptedPx
                        bool _insideFinalLeg = _macroDir == 1 ? _pMid < _ePx : _pMid > _ePx
                        if _newDirectionalExtreme and _insideFinalLeg
                            int _spanA = math.max(_j - _lastSegIdx, 1)
                            for _fill = _lastSegIdx to _j
                                float _tA = float(_fill - _lastSegIdx) / float(_spanA)
                                array.set(_pathClose, _fill, _lastSegPx + (_pMid - _lastSegPx) * _tA)
                            _lastAcceptedPx := _pMid
                            _lastSegIdx := _j
                            _lastSegPx := _pMid
                int _spanB = math.max(_eIdx - _lastSegIdx, 1)
                for _fill = _lastSegIdx to _eIdx
                    float _tB = float(_fill - _lastSegIdx) / float(_spanB)
                    array.set(_pathClose, _fill, _lastSegPx + (_ePx - _lastSegPx) * _tB)
        float _lastFilled = array.get(_rawPx, 0)
        for _i = 0 to _nBars - 1
            float _v = array.get(_pathClose, _i)
            float _finalV = na(_v) ? _lastFilled : _v
            if na(_v)
                array.set(_pathClose, _i, _finalV)
            else
                _lastFilled := _finalV
            if _i > 0
                float _prevV = array.get(_pathClose, _i - 1)
                float _d = _finalV - _prevV
                int _stepDir = f_sign(_d)
                _cumTmp := f_updateCumMove(_cumTmp, _prevStepDir, _stepDir, _d)
                if _stepDir != 0
                    _prevStepDir := _stepDir
        _lastClose := array.get(_pathClose, _nBars - 1)
        _lastOpen := _nBars > 1 ? array.get(_pathClose, _nBars - 2) : _lastClose
        _lastDir := f_sign(_lastClose - _lastOpen)
        [_pivIdx, _pivPx, _pathClose, _cumTmp, _lastClose, _lastOpen, _lastDir]
f_buildInboundCapturePathArrays(float[] _rawPx,int _nBars)=>
    // Live entry-reference transform path built from the confirmed chart prefix.
    // Capture size is used on the incoming leg into the candidate extreme, not as an
    // outgoing move-away confirmation. That keeps the reference immediately available
    // at/after the executable peak/trough while still rejecting small raw flip pivots.
    int[] _pivIdx = array.new_int()
    float[] _pivPx = array.new_float()
    float[] _pathClose = array.new_float()
    float _cumTmp = 0.0
    int _prevStepDir = 0
    float _lastClose = na
    float _lastOpen = na
    int _lastDir = 0
    if _nBars <= 0 or array.size(_rawPx) == 0
        [_pivIdx, _pivPx, _pathClose, _cumTmp, _lastClose, _lastOpen, _lastDir]
    else
        float _firstPx = array.get(_rawPx, 0)
        array.push(_pivIdx, 0)
        array.push(_pivPx, _firstPx)
        int _lastPivIdx = 0
        float _lastPivPx = _firstPx
        int _dir = 0
        int _candIdx = 0
        float _candPx = _firstPx
        if _nBars > 1
            for _i = 1 to _nBars - 1
                float _p = array.get(_rawPx, _i)
                int _netDir = f_sign(_p - _lastPivPx)
                if _dir == 0
                    if _netDir != 0
                        _dir := _netDir
                        _candIdx := _i
                        _candPx := _p
                else if _dir > 0
                    if _p >= _candPx
                        _candIdx := _i
                        _candPx := _p
                    else
                        float _inPctUp = math.abs(_candPx - _lastPivPx) * 100.0 / math.max(math.abs(_lastPivPx), eps)
                        if _inPctUp >= refPathMinCapturedPathPct
                            if _candIdx != _lastPivIdx and array.get(_pivIdx, array.size(_pivIdx) - 1) != _candIdx
                                array.push(_pivIdx, _candIdx)
                                array.push(_pivPx, _candPx)
                            _lastPivIdx := _candIdx
                            _lastPivPx := _candPx
                            _dir := -1
                            _candIdx := _i
                            _candPx := _p
                        else if _p < _lastPivPx
                            _dir := -1
                            _candIdx := _i
                            _candPx := _p
                else
                    if _p <= _candPx
                        _candIdx := _i
                        _candPx := _p
                    else
                        float _inPctDn = math.abs(_candPx - _lastPivPx) * 100.0 / math.max(math.abs(_lastPivPx), eps)
                        if _inPctDn >= refPathMinCapturedPathPct
                            if _candIdx != _lastPivIdx and array.get(_pivIdx, array.size(_pivIdx) - 1) != _candIdx
                                array.push(_pivIdx, _candIdx)
                                array.push(_pivPx, _candPx)
                            _lastPivIdx := _candIdx
                            _lastPivPx := _candPx
                            _dir := 1
                            _candIdx := _i
                            _candPx := _p
                        else if _p > _lastPivPx
                            _dir := 1
                            _candIdx := _i
                            _candPx := _p
        int _endIdx = _nBars - 1
        float _endPx = array.get(_rawPx, _endIdx)
        if array.get(_pivIdx, array.size(_pivIdx) - 1) != _endIdx and math.abs(_endPx - array.get(_pivPx, array.size(_pivPx) - 1)) > eps
            array.push(_pivIdx, _endIdx)
            array.push(_pivPx, _endPx)
        bool _domChanged = true
        int _domGuard = 0
        while _domChanged and array.size(_pivIdx) > 3 and _domGuard < 5000
            _domChanged := false
            _domGuard += 1
            int _kd = 0
            while _kd <= array.size(_pivIdx) - 4 and not _domChanged
                float _aD = array.get(_pivPx, _kd)
                float _bD = array.get(_pivPx, _kd + 1)
                float _cD = array.get(_pivPx, _kd + 2)
                float _dD = array.get(_pivPx, _kd + 3)
                bool _upDnUp = _bD > _aD and _cD < _bD and _dD > _cD
                bool _dnUpDn = _bD < _aD and _cD > _bD and _dD < _cD
                bool _mergeDominated = (_upDnUp and _bD <= _cD) or (_dnUpDn and _bD >= _cD)
                if _mergeDominated
                    array.remove(_pivIdx, _kd + 2)
                    array.remove(_pivPx, _kd + 2)
                    array.remove(_pivIdx, _kd + 1)
                    array.remove(_pivPx, _kd + 1)
                    _domChanged := true
                _kd += 1
        _pathClose := array.new_float(_nBars, na)
        if array.size(_pivIdx) == 1
            for _i = 0 to _nBars - 1
                array.set(_pathClose, _i, array.get(_pivPx, 0))
        else
            for _s = 0 to array.size(_pivIdx) - 2
                int _sIdx = array.get(_pivIdx, _s)
                int _eIdx = array.get(_pivIdx, _s + 1)
                float _sPx = array.get(_pivPx, _s)
                float _ePx = array.get(_pivPx, _s + 1)
                int _macroDir = _ePx > _sPx ? 1 : _ePx < _sPx ? -1 : 0
                int _lastSegIdx = _sIdx
                float _lastSegPx = _sPx
                float _lastAcceptedPx = _sPx
                if _macroDir != 0 and _eIdx - _sIdx > 1
                    for _j = _sIdx + 1 to _eIdx - 1
                        float _pMid = array.get(_rawPx, _j)
                        bool _newDirectionalExtreme = _macroDir == 1 ? _pMid > _lastAcceptedPx : _pMid < _lastAcceptedPx
                        bool _insideFinalLeg = _macroDir == 1 ? _pMid < _ePx : _pMid > _ePx
                        if _newDirectionalExtreme and _insideFinalLeg
                            int _spanA = math.max(_j - _lastSegIdx, 1)
                            for _fill = _lastSegIdx to _j
                                float _tA = float(_fill - _lastSegIdx) / float(_spanA)
                                array.set(_pathClose, _fill, _lastSegPx + (_pMid - _lastSegPx) * _tA)
                            _lastAcceptedPx := _pMid
                            _lastSegIdx := _j
                            _lastSegPx := _pMid
                int _spanB = math.max(_eIdx - _lastSegIdx, 1)
                for _fill = _lastSegIdx to _eIdx
                    float _tB = float(_fill - _lastSegIdx) / float(_spanB)
                    array.set(_pathClose, _fill, _lastSegPx + (_ePx - _lastSegPx) * _tB)
        float _lastFilled = array.get(_rawPx, 0)
        for _i = 0 to _nBars - 1
            float _v = array.get(_pathClose, _i)
            float _finalV = na(_v) ? _lastFilled : _v
            if na(_v)
                array.set(_pathClose, _i, _finalV)
            else
                _lastFilled := _finalV
            if _i > 0
                float _prevV = array.get(_pathClose, _i - 1)
                float _d = _finalV - _prevV
                int _stepDir = f_sign(_d)
                _cumTmp := f_updateCumMove(_cumTmp, _prevStepDir, _stepDir, _d)
                if _stepDir != 0
                    _prevStepDir := _stepDir
        _lastClose := array.get(_pathClose, _nBars - 1)
        _lastOpen := _nBars > 1 ? array.get(_pathClose, _nBars - 2) : _lastClose
        _lastDir := f_sign(_lastClose - _lastOpen)
        [_pivIdx, _pivPx, _pathClose, _cumTmp, _lastClose, _lastOpen, _lastDir]

//==================================================================================================
// SECTION 4 — CHART-PREFIX ARRAYS AND TRANSFORM SIGNAL REPLAY
//==================================================================================================
var float[] bestFitStatsTfPath = array.new_float()
var float[] bestFitStatsRawPath = array.new_float()
var float[] bestFitStatsClosePath = array.new_float()
var float[] bestFitStatsHighPath = array.new_float()
var float[] bestFitStatsLowPath = array.new_float()
var int[] ptOracleKindByBar = array.new_int()

var label[] histStructuralChangeLabs = array.new_label()
var line[] histStructuralPathLines = array.new_line()

var label[] histBuyReplayLabs = array.new_label()
var label[] histSellReplayLabs = array.new_label()
var label[] histBuyFiltReplayLabs = array.new_label()
var box[] histLiveEntryRefReplayBodies = array.new_box()

var int[] confirmedSignalDirLedger = array.new_int()
var int[] confirmedSignalTerminalBarLedger = array.new_int()
var float[] confirmedSignalTerminalPriceLedger = array.new_float()
var int[] confirmedSignalConfirmBarLedger = array.new_int()
var float[] confirmedSignalConfirmPriceLedger = array.new_float()
var int[] confirmedSignalClassLedger = array.new_int()
var int[] provisionalSignalDirLedger = array.new_int()
var int[] provisionalSignalTerminalBarLedger = array.new_int()
var float[] provisionalSignalTerminalPriceLedger = array.new_float()
var int[] provisionalSignalConfirmBarLedger = array.new_int()

var int replaySignalCount = 0
var int replayBuyCount = 0
var int replaySellCount = 0
var int replayReversalCount = 0
var int replayContinuationCount = 0
var int replayUnresolvedClassCount = 0
var int replayPathFilteredCount = 0
var int replayStructuralCount = 0
var float replayCandidateDelaySum = 0.0
var float replayFilterWaitSum = 0.0
var float replayExecutableDelaySum = 0.0
var float replayDistanceSum = 0.0
var float replayMaxDistance = 0.0
var int replayLastSignalDir = 0
var int replayLastCandidateDelay = na
var int replayLastFilterWait = na
var int replayLastExecutableDelay = na
var float replayLastDistance = na
var int replayLastStructuralDir = 0

var label liveCandidateLabel = na
var label lastBuyLab = na
var label lastSellLab = na

//==================================================================================================
// CAUSAL PREFIX-STABLE STRUCTURAL EVENT ENGINE
//==================================================================================================
// Structural resolver implementations:
//   Original Grouping uses a persistent retained-extreme lifecycle.
//   Conditional Accelerated uses a known-prefix captured-path chain.
//   Earliest Terminal uses a known-prefix earliest-capture chain.
// Confirmed structural identities are committed once and are never rebuilt from chart-end state.
var float[] csHi = array.new_float()
var float[] csLo = array.new_float()
var float[] csCl = array.new_float()
var int[] csEventDir = array.new_int()
var int[] csEventTerminalBar = array.new_int()
var float[] csEventTerminalPrice = array.new_float()
var int[] csEventConfirmBar = array.new_int()

var int csLastCommittedDir = 0
var float csLastTerminalPrice = na
var int csScanStart = 0

// Original grouped-state lifecycle.
var int csGroupDir = 0
var float csGroupExtremePrice = na
var int csGroupExtremeBar = na

// Exact known-prefix chain working memory used by Conditional Accelerated and Earliest Terminal.
var float[] csSufHi = array.new_float()
var float[] csSufLo = array.new_float()
var int[] csNextHigher = array.new_int()
var int[] csNextLower = array.new_int()
var float[] csCloseMinTree = array.new_float()
var float[] csCloseMaxTree = array.new_float()
var float[] csOppTroughMinTree = array.new_float()
var float[] csOppPeakMaxTree = array.new_float()
var int[] csNodeK = array.new_int()
var int[] csNodeX = array.new_int()
var float[] csNodeY = array.new_float()
var int[] csNodeConfirm = array.new_int()

f_csEventExists(int _dir, int _terminalBar) =>
    bool _found = false
    if array.size(csEventDir) > 0
        for _e = 0 to array.size(csEventDir) - 1
            if array.get(csEventDir, _e) == _dir and array.get(csEventTerminalBar, _e) == _terminalBar
                _found := true
                break
    _found

f_csRangeMin(float[] _tree, int _left, int _right, int _treeBase) =>
    float _result = 1e100
    if _left <= _right
        int _l = _left + _treeBase
        int _r = _right + _treeBase
        while _l <= _r
            if _l % 2 == 1
                _result := math.min(_result, array.get(_tree, _l))
                _l += 1
            if _r % 2 == 0
                _result := math.min(_result, array.get(_tree, _r))
                _r -= 1
            _l := int(math.floor(_l / 2))
            _r := int(math.floor(_r / 2))
    _result

f_csRangeMax(float[] _tree, int _left, int _right, int _treeBase) =>
    float _result = -1e100
    if _left <= _right
        int _l = _left + _treeBase
        int _r = _right + _treeBase
        while _l <= _r
            if _l % 2 == 1
                _result := math.max(_result, array.get(_tree, _l))
                _l += 1
            if _r % 2 == 0
                _result := math.max(_result, array.get(_tree, _r))
                _r -= 1
            _l := int(math.floor(_l / 2))
            _r := int(math.floor(_r / 2))
    _result

f_csPrepare(int _n, int _startIndex) =>
    int _activeStart = math.max(math.min(_startIndex, _n - 1), 0)
    int _activeLength = _n - _activeStart
    int _treeBase = 1

    while array.size(csSufHi) < _n
        array.push(csSufHi, na)
        array.push(csSufLo, na)
        array.push(csNextHigher, na)
        array.push(csNextLower, na)

    if _activeLength > 0
        float _hiM = array.get(csHi, _n - 1)
        float _loM = array.get(csLo, _n - 1)
        int[] _hs = array.new_int()
        int[] _ls = array.new_int()

        for _r = 0 to _activeLength - 1
            int _i = _n - 1 - _r
            float _hi = array.get(csHi, _i)
            float _lo = array.get(csLo, _i)
            _hiM := math.max(_hiM, _hi)
            _loM := math.min(_loM, _lo)
            array.set(csSufHi, _i, _hiM)
            array.set(csSufLo, _i, _loM)

            while array.size(_hs) > 0 and array.get(csHi, array.get(_hs, array.size(_hs) - 1)) <= _hi + eps
                array.pop(_hs)
            array.set(csNextHigher, _i, array.size(_hs) > 0 ? array.get(_hs, array.size(_hs) - 1) : na)
            array.push(_hs, _i)

            while array.size(_ls) > 0 and array.get(csLo, array.get(_ls, array.size(_ls) - 1)) >= _lo - eps
                array.pop(_ls)
            array.set(csNextLower, _i, array.size(_ls) > 0 ? array.get(_ls, array.size(_ls) - 1) : na)
            array.push(_ls, _i)

        while _treeBase < _activeLength
            _treeBase *= 2

        array.clear(csCloseMinTree)
        array.clear(csCloseMaxTree)
        array.clear(csOppTroughMinTree)
        array.clear(csOppPeakMaxTree)

        int _treeSize = _treeBase * 2
        for _i = 0 to _treeSize - 1
            array.push(csCloseMinTree, 1e100)
            array.push(csCloseMaxTree, -1e100)
            array.push(csOppTroughMinTree, 1e100)
            array.push(csOppPeakMaxTree, -1e100)

        for _i = _activeStart to _n - 1
            float _hi = array.get(csHi, _i)
            float _lo = array.get(csLo, _i)
            float _cl = array.get(csCl, _i)
            bool _localPeak = _i > 0 and _i < _n - 1 and _hi >= array.get(csHi, _i - 1) and _hi >= array.get(csHi, _i + 1)
            bool _localTrough = _i > 0 and _i < _n - 1 and _lo <= array.get(csLo, _i - 1) and _lo <= array.get(csLo, _i + 1)
            bool _suffixPeak = _hi >= array.get(csSufHi, _i) - eps
            bool _suffixTrough = _lo <= array.get(csSufLo, _i) + eps
            int _leaf = _treeBase + _i - _activeStart
            array.set(csCloseMinTree, _leaf, _cl)
            array.set(csCloseMaxTree, _leaf, _cl)
            array.set(csOppTroughMinTree, _leaf, _localTrough or _suffixTrough ? _lo : 1e100)
            array.set(csOppPeakMaxTree, _leaf, _localPeak or _suffixPeak ? _hi : -1e100)

        if _treeBase > 1
            for _r = 1 to _treeBase - 1
                int _i = _treeBase - _r
                int _left = _i * 2
                int _right = _left + 1
                array.set(csCloseMinTree, _i, math.min(array.get(csCloseMinTree, _left), array.get(csCloseMinTree, _right)))
                array.set(csCloseMaxTree, _i, math.max(array.get(csCloseMaxTree, _left), array.get(csCloseMaxTree, _right)))
                array.set(csOppTroughMinTree, _i, math.min(array.get(csOppTroughMinTree, _left), array.get(csOppTroughMinTree, _right)))
                array.set(csOppPeakMaxTree, _i, math.max(array.get(csOppPeakMaxTree, _left), array.get(csOppPeakMaxTree, _right)))

    _treeBase

f_csFirstProof(int _k, int _x, float _y, int _stopBar, int _n, int _treeBase, int _activeStart) =>
    int _proof = na
    int _start = _x + 1
    int _stop = math.min(_stopBar, _n - 1)
    if _start <= _stop
        int _queryLeft = _start - _activeStart
        int _queryRight = _stop - _activeStart
        bool _exists = _k > 0 ? f_csRangeMin(csCloseMinTree, _queryLeft, _queryRight, _treeBase) < _y - eps : f_csRangeMax(csCloseMaxTree, _queryLeft, _queryRight, _treeBase) > _y + eps
        if _exists
            int _lo = _start
            int _hi = _stop
            while _lo < _hi
                int _mid = int(math.floor((_lo + _hi) / 2))
                int _leftQuery = _start - _activeStart
                int _rightQuery = _mid - _activeStart
                bool _existsLeft = _k > 0 ? f_csRangeMin(csCloseMinTree, _leftQuery, _rightQuery, _treeBase) < _y - eps : f_csRangeMax(csCloseMaxTree, _leftQuery, _rightQuery, _treeBase) > _y + eps
                if _existsLeft
                    _hi := _mid
                else
                    _lo := _mid + 1
            _proof := _lo
    _proof

f_csFirstCaptureBar(int _k, int _proof, float _proofPx, int _stopBar, int _n, int _treeBase, int _activeStart) =>
    int _captureBar = na
    int _start = _proof + 1
    int _stop = math.min(_stopBar, _n - 1)
    if not na(_proof) and _start <= _stop
        int _fullLeft = _start - _activeStart
        int _fullRight = _stop - _activeStart
        float _fullOpposite = _k > 0 ? f_csRangeMin(csOppTroughMinTree, _fullLeft, _fullRight, _treeBase) : f_csRangeMax(csOppPeakMaxTree, _fullLeft, _fullRight, _treeBase)
        bool _fullHasOpposite = _k > 0 ? _fullOpposite < 1e99 : _fullOpposite > -1e99
        float _fullPathPct = _fullHasOpposite ? (_k > 0 ? (_proofPx - _fullOpposite) * 100.0 / math.max(math.abs(_proofPx), eps) : (_fullOpposite - _proofPx) * 100.0 / math.max(math.abs(_proofPx), eps)) : 0.0
        if _fullHasOpposite and _fullPathPct >= structuralCapturablePct
            int _lo = _start
            int _hi = _stop
            while _lo < _hi
                int _mid = int(math.floor((_lo + _hi) / 2))
                int _queryLeft = _start - _activeStart
                int _queryRight = _mid - _activeStart
                float _oppositePx = _k > 0 ? f_csRangeMin(csOppTroughMinTree, _queryLeft, _queryRight, _treeBase) : f_csRangeMax(csOppPeakMaxTree, _queryLeft, _queryRight, _treeBase)
                bool _hasOpposite = _k > 0 ? _oppositePx < 1e99 : _oppositePx > -1e99
                float _pathPct = _hasOpposite ? (_k > 0 ? (_proofPx - _oppositePx) * 100.0 / math.max(math.abs(_proofPx), eps) : (_oppositePx - _proofPx) * 100.0 / math.max(math.abs(_proofPx), eps)) : 0.0
                if _hasOpposite and _pathPct >= structuralCapturablePct
                    _hi := _mid
                else
                    _lo := _mid + 1
            _captureBar := _lo
    _captureBar

f_csBuild(int _n, bool _requirePriceOrder) =>
    array.clear(csNodeK)
    array.clear(csNodeX)
    array.clear(csNodeY)
    array.clear(csNodeConfirm)

    if _n >= 2
        int _activeStart = math.max(math.min(csScanStart, _n - 1), 0)
        int _treeBase = f_csPrepare(_n, _activeStart)
        int _lastK = csLastCommittedDir > 0 ? -1 : csLastCommittedDir < 0 ? 1 : 0
        float _chainLastTerminalPrice = csLastTerminalPrice

        for _i = _activeStart to _n - 1
            float _hi = array.get(csHi, _i)
            float _lo = array.get(csLo, _i)
            bool _suffixPeak = _hi >= array.get(csSufHi, _i) - eps
            bool _suffixTrough = _lo <= array.get(csSufLo, _i) + eps
            bool _localPeak = _i > 0 and _i < _n - 1 and _hi >= array.get(csHi, _i - 1) and _hi >= array.get(csHi, _i + 1)
            bool _localTrough = _i > 0 and _i < _n - 1 and _lo <= array.get(csLo, _i - 1) and _lo <= array.get(csLo, _i + 1)
            int _k = (_suffixPeak or _localPeak) and not (_suffixTrough or _localTrough) ? 1 : (_suffixTrough or _localTrough) and not (_suffixPeak or _localPeak) ? -1 : 0

            if _k != 0
                float _y = _k > 0 ? _hi : _lo
                int _sameBreak = _k > 0 ? array.get(csNextHigher, _i) : array.get(csNextLower, _i)
                int _stop = na(_sameBreak) ? _n - 1 : _sameBreak - 1
                int _proof = f_csFirstProof(_k, _i, _y, _stop, _n, _treeBase, _activeStart)
                bool _hasProof = not na(_proof)
                float _proofPx = _hasProof ? array.get(csCl, _proof) : na
                int _captureBar = _hasProof ? f_csFirstCaptureBar(_k, _proof, _proofPx, _stop, _n, _treeBase, _activeStart) : na
                bool _captured = not na(_captureBar)
                bool _alternatesNaturally = _lastK == 0 or _k != _lastK
                bool _correctPriceOrder = na(_chainLastTerminalPrice) or (_k > 0 ? _y > _chainLastTerminalPrice + eps : _y < _chainLastTerminalPrice - eps)
                bool _keep = _captured and _alternatesNaturally and (not _requirePriceOrder or _correctPriceOrder)

                if _keep
                    array.push(csNodeK, _k)
                    array.push(csNodeX, _i)
                    array.push(csNodeY, _y)
                    array.push(csNodeConfirm, _captureBar)
                    _lastK := _k
                    _chainLastTerminalPrice := _y

bool csBarReady = barstate.isconfirmed
if csBarReady
    array.push(csHi, high)
    array.push(csLo, low)
    array.push(csCl, src)

    if structuralMode == "Original Grouping"
        bool _structuralHigh = bar_index >= structuralLength and ta.highestbars(high, structuralLength) == 0
        bool _structuralLow = bar_index >= structuralLength and ta.lowestbars(low, structuralLength) == 0
        int _candidateDir = 0
        float _candidatePrice = na
        if _structuralHigh and _structuralLow
            float _upDistance = math.abs(high - nz(close[1], close))
            float _downDistance = math.abs(nz(close[1], close) - low)
            _candidateDir := _upDistance >= _downDistance ? -1 : 1
            _candidatePrice := _candidateDir < 0 ? high : low
        else if _structuralHigh
            _candidateDir := -1
            _candidatePrice := high
        else if _structuralLow
            _candidateDir := 1
            _candidatePrice := low

        if _candidateDir != 0
            if csGroupDir == 0
                csGroupDir := _candidateDir
                csGroupExtremePrice := _candidatePrice
                csGroupExtremeBar := bar_index
            else if _candidateDir == csGroupDir
                bool _moreExtreme = csGroupDir > 0 ? _candidatePrice < csGroupExtremePrice : _candidatePrice > csGroupExtremePrice
                if _moreExtreme
                    csGroupExtremePrice := _candidatePrice
                    csGroupExtremeBar := bar_index
            else
                bool _alternationPass = csLastCommittedDir == 0 or csGroupDir != csLastCommittedDir
                if _alternationPass and not f_csEventExists(csGroupDir, csGroupExtremeBar)
                    array.push(csEventDir, csGroupDir)
                    array.push(csEventTerminalBar, csGroupExtremeBar)
                    array.push(csEventTerminalPrice, csGroupExtremePrice)
                    array.push(csEventConfirmBar, bar_index)
                    csLastCommittedDir := csGroupDir
                    csLastTerminalPrice := csGroupExtremePrice
                csGroupDir := _candidateDir
                csGroupExtremePrice := _candidatePrice
                csGroupExtremeBar := bar_index
    else
        int _n = array.size(csHi)
        bool _requirePriceOrder = structuralMode == "Earliest Terminal"
        f_csBuild(_n, _requirePriceOrder)

        int _chosen = na
        if array.size(csNodeK) > 0
            for _i = 0 to array.size(csNodeK) - 1
                int _k = array.get(csNodeK, _i)
                int _dir = _k > 0 ? -1 : 1
                int _terminalBar = array.get(csNodeX, _i)
                if not f_csEventExists(_dir, _terminalBar) and na(_chosen)
                    _chosen := _i

        if not na(_chosen)
            int _k = array.get(csNodeK, _chosen)
            int _dir = _k > 0 ? -1 : 1
            int _terminalBar = array.get(csNodeX, _chosen)
            float _terminalPrice = array.get(csNodeY, _chosen)
            int _captureBar = array.get(csNodeConfirm, _chosen)
            // Earliest Terminal uses the retained earliest-capture bar.
            // Conditional Accelerated uses the current causal commit bar.
            int _confirmBar = structuralMode == "Earliest Terminal" ? _captureBar : _n - 1

            array.push(csEventDir, _dir)
            array.push(csEventTerminalBar, _terminalBar)
            array.push(csEventTerminalPrice, _terminalPrice)
            array.push(csEventConfirmBar, _confirmBar)
            csLastCommittedDir := _dir
            csLastTerminalPrice := _terminalPrice

            // The resolved primary identity is
            // consumed once so they cannot repeatedly block the next naturally alternating node.
            csScanStart := math.max(_terminalBar + 1, csScanStart)

provisionalTriggerBuy = false
provisionalTriggerSell = false
finalizedTriggerBuy = false
finalizedTriggerSell = false

if barstate.islast
    provisionalTriggerBuy := false
    provisionalTriggerSell := false
    finalizedTriggerBuy := false
    finalizedTriggerSell := false
    f_clearLabelArr(histStructuralChangeLabs)
    f_clearLineArr(histStructuralPathLines)
    f_clearLabelArr(histBuyReplayLabs)
    f_clearLabelArr(histSellReplayLabs)
    f_clearLabelArr(histBuyFiltReplayLabs)
    f_clearBoxArr(histLiveEntryRefReplayBodies)
    array.clear(confirmedSignalDirLedger)
    array.clear(confirmedSignalTerminalBarLedger)
    array.clear(confirmedSignalTerminalPriceLedger)
    array.clear(confirmedSignalConfirmBarLedger)
    array.clear(confirmedSignalConfirmPriceLedger)
    array.clear(confirmedSignalClassLedger)
    array.clear(provisionalSignalDirLedger)
    array.clear(provisionalSignalTerminalBarLedger)
    array.clear(provisionalSignalTerminalPriceLedger)
    array.clear(provisionalSignalConfirmBarLedger)
    replaySignalCount := 0
    replayBuyCount := 0
    replaySellCount := 0
    replayReversalCount := 0
    replayContinuationCount := 0
    replayUnresolvedClassCount := 0
    replayPathFilteredCount := 0
    replayStructuralCount := 0
    replayCandidateDelaySum := 0.0
    replayFilterWaitSum := 0.0
    replayExecutableDelaySum := 0.0
    replayDistanceSum := 0.0
    replayMaxDistance := 0.0
    replayLastSignalDir := 0
    replayLastCandidateDelay := na
    replayLastFilterWait := na
    replayLastExecutableDelay := na
    replayLastDistance := na
    replayLastStructuralDir := 0

    int historyCap = autoLimitLiveProvisionalReplay ? liveProvisionalReplayBars : 5000
    int nBarsFull = bar_index + 1
    int simN = math.min(nBarsFull, historyCap + 1)
    int simBaseBar = nBarsFull - simN
    float[] rawPx = array.new_float(simN, na)
    float[] rawHi = array.new_float(simN, na)
    float[] rawLo = array.new_float(simN, na)
    for i = 0 to simN - 1
        int off = simN - 1 - i
        array.set(rawPx, i, src[off])
        array.set(rawHi, i, high[off])
        array.set(rawLo, i, low[off])

    [pivIdxFinal, pivPxFinal, finalPath, finalCum, finalLast, finalOpen, finalDir] = f_buildReferencePathArrays(rawPx, simN)
    [simFastPivIdx, simFastPivPx, simFastPath, simFastCum, simFastLast, simFastOpen, simFastDir] = f_buildInboundCapturePathArrays(rawPx, simN)

    array.clear(bestFitStatsTfPath)
    array.clear(bestFitStatsRawPath)
    array.clear(bestFitStatsClosePath)
    array.clear(bestFitStatsHighPath)
    array.clear(bestFitStatsLowPath)
    array.clear(ptOracleKindByBar)
    for i = 0 to simN - 1
        array.push(bestFitStatsTfPath, array.get(finalPath, i))
        array.push(bestFitStatsRawPath, array.get(rawPx, i))
        array.push(bestFitStatsClosePath, close[simN - 1 - i])
        array.push(bestFitStatsHighPath, array.get(rawHi, i))
        array.push(bestFitStatsLowPath, array.get(rawLo, i))
        array.push(ptOracleKindByBar, 0)

    if array.size(pivIdxFinal) >= 3
        for k = 1 to array.size(pivIdxFinal) - 2
            int pb = array.get(pivIdxFinal, k)
            float pp = array.get(pivPxFinal, k - 1)
            float pc = array.get(pivPxFinal, k)
            float pn = array.get(pivPxFinal, k + 1)
            if pb >= 0 and pb < simN
                array.set(ptOracleKindByBar, pb, pc <= pp and pc <= pn ? 1 : pc >= pp and pc >= pn ? -1 : 0)

    // Forward-only entry-reference state. Each stored replay bar uses only source bars
    // available through that bar. Later bars cannot rewrite an earlier agreement direction
    // or active reference pivot.
    int[] refDirByBar = array.new_int(simN, 0)
    int[] refSignalPivotByBar = array.new_int(simN, na)
    if simN > 0
        int refLastPivotBar = 0
        float refLastPivotPrice = array.get(rawPx, 0)
        int refBuildDir = 0
        int refCandidateBar = 0
        float refCandidatePrice = refLastPivotPrice
        array.set(refSignalPivotByBar, 0, refLastPivotBar)

        if simN > 1
            int refReplayIndex = 1
            float refPriceNow = na
            int refNetDir = 0
            while refReplayIndex < simN
                refPriceNow := array.get(rawPx, refReplayIndex)
                refNetDir := f_sign(refPriceNow - refLastPivotPrice)

                if refBuildDir == 0
                    if refNetDir != 0
                        refBuildDir := refNetDir
                        refCandidateBar := refReplayIndex
                        refCandidatePrice := refPriceNow
                else if refBuildDir > 0
                    if refPriceNow >= refCandidatePrice
                        refCandidateBar := refReplayIndex
                        refCandidatePrice := refPriceNow
                    else
                        float refInboundUpPct = math.abs(refCandidatePrice - refLastPivotPrice) * 100.0 / math.max(math.abs(refLastPivotPrice), eps)
                        if refInboundUpPct >= refPathMinCapturedPathPct
                            refLastPivotBar := refCandidateBar
                            refLastPivotPrice := refCandidatePrice
                            refBuildDir := -1
                            refCandidateBar := refReplayIndex
                            refCandidatePrice := refPriceNow
                        else if refPriceNow < refLastPivotPrice
                            refBuildDir := -1
                            refCandidateBar := refReplayIndex
                            refCandidatePrice := refPriceNow
                else
                    if refPriceNow <= refCandidatePrice
                        refCandidateBar := refReplayIndex
                        refCandidatePrice := refPriceNow
                    else
                        float refInboundDownPct = math.abs(refCandidatePrice - refLastPivotPrice) * 100.0 / math.max(math.abs(refLastPivotPrice), eps)
                        if refInboundDownPct >= refPathMinCapturedPathPct
                            refLastPivotBar := refCandidateBar
                            refLastPivotPrice := refCandidatePrice
                            refBuildDir := 1
                            refCandidateBar := refReplayIndex
                            refCandidatePrice := refPriceNow
                        else if refPriceNow > refLastPivotPrice
                            refBuildDir := 1
                            refCandidateBar := refReplayIndex
                            refCandidatePrice := refPriceNow

                int refResolvedDirNow = f_sign(refPriceNow - refLastPivotPrice)
                if refResolvedDirNow == 0
                    refResolvedDirNow := refBuildDir
                array.set(refDirByBar, refReplayIndex, refResolvedDirNow)
                array.set(refSignalPivotByBar, refReplayIndex, refLastPivotBar)
                refReplayIndex += 1

    // Causal path-agreed attempts remain provisional until a structural event completes their swing.
    int[] provisionalDir = array.new_int()
    int[] provisionalTerminal = array.new_int()
    float[] provisionalTerminalPrice = array.new_float()
    int[] provisionalConfirm = array.new_int()
    float[] provisionalConfirmPrice = array.new_float()
    int[] provisionalClass = array.new_int()
    bool[] provisionalResolved = array.new_bool()
    int structuralCommitCursor = 0
    int previousStructuralConfirm = -1

    //==================================================================================================
    // INDEPENDENT STRUCTURAL-CHANGE RESOLUTION — IMMUTABLE CAUSAL LEDGER
    //==================================================================================================
    int[] structuralDirByBar = array.new_int(simN, 0)
    int[] structuralEventDir = array.new_int()
    int[] structuralEventTerminal = array.new_int()
    float[] structuralEventPrice = array.new_float()
    int[] structuralEventConfirm = array.new_int()

    // Copy only immutable causal events that fall inside the active replay window.
    int csLedgerCount = array.size(csEventDir)
    if csLedgerCount > 0
        for ce = 0 to csLedgerCount - 1
            int ceTerminalAbs = array.get(csEventTerminalBar, ce)
            int ceConfirmAbs = array.get(csEventConfirmBar, ce)
            if ceTerminalAbs >= simBaseBar and ceConfirmAbs >= simBaseBar and ceConfirmAbs <= bar_index
                array.push(structuralEventDir, array.get(csEventDir, ce))
                array.push(structuralEventTerminal, ceTerminalAbs - simBaseBar)
                array.push(structuralEventPrice, array.get(csEventTerminalPrice, ce))
                array.push(structuralEventConfirm, ceConfirmAbs - simBaseBar)
    // Resolve the most recent accepted structural direction in one forward pass.
    int structuralResolveCursor = 0
    int structuralResolvedDir = 0
    int structuralEventCountForResolve = array.size(structuralEventDir)
    for si = 0 to simN - 1
        while structuralResolveCursor < structuralEventCountForResolve and array.get(structuralEventConfirm, structuralResolveCursor) <= si
            structuralResolvedDir := array.get(structuralEventDir, structuralResolveCursor)
            structuralResolveCursor += 1
        array.set(structuralDirByBar, si, structuralResolvedDir)

    // Structural-change labels and structural resolution path are separate from transform BUY/SELL labels.
    replayStructuralCount := array.size(structuralEventDir)
    replayLastStructuralDir := replayStructuralCount > 0 ? array.get(structuralEventDir, replayStructuralCount - 1) : 0

    if not optReplayStatsOnly and array.size(structuralEventDir) > 0
        int structuralDrawStart = math.max(0, array.size(structuralEventDir) - optMaxReplayObjects)
        for se = structuralDrawStart to array.size(structuralEventDir) - 1
            int sd = array.get(structuralEventDir, se)
            int stb = array.get(structuralEventTerminal, se)
            float stp = array.get(structuralEventPrice, se)
            int scb = array.get(structuralEventConfirm, se)
            int drawIndex = plotStructuralAtConfirmBar ? scb : stb
            int drawBar = simBaseBar + drawIndex
            float structuralAnchorPrice = plotStructuralAtConfirmBar ? array.get(rawPx, scb) : stp
            float structuralBarRange = math.max(array.get(rawHi, drawIndex) - array.get(rawLo, drawIndex), eps)
            float structuralPadding = math.max(structuralBarRange * 1.25, math.abs(structuralAnchorPrice) * 0.001)
            float drawPrice = sd > 0 ? structuralAnchorPrice - structuralPadding : structuralAnchorPrice + structuralPadding
            if showStructuralChangeLabels
                string stText = sd > 0 ? "STRUCTURE\n▲ TROUGH → UP" : "STRUCTURE\n▼ PEAK → DOWN"
                color structuralLabelColor = sd > 0 ? color.rgb(0, 115, 230) : color.rgb(230, 120, 0)
                label stLabel = label.new(drawBar, drawPrice, stText, xloc=xloc.bar_index, style=sd > 0 ? label.style_label_up : label.style_label_down, color=color.new(structuralLabelColor, 0), textcolor=color.white, size=size.small)
                array.push(histStructuralChangeLabs, stLabel)
            if showStructuralPath and se > structuralDrawStart
                int prevTb = array.get(structuralEventTerminal, se - 1)
                float prevTp = array.get(structuralEventPrice, se - 1)
                line stLine = line.new(simBaseBar + prevTb, prevTp, simBaseBar + stb, stp, xloc=xloc.bar_index, extend=extend.none, color=color.new(sd > 0 ? color.green : color.red, 35), width=2)
                array.push(histStructuralPathLines, stLine)

    

    // Historical cycle statistics are updated only by accepted transform signals.

    if showLiveEntryReferencePath and not optReplayStatsOnly
        int drawStart = math.max(1, simN - optMaxReplayObjects)
        f_pushRefReplaySegment(histLiveEntryRefReplayBodies, simBaseBar, 0, simN - 1, simFastPath, drawStart)

    int simSwingDir = 0
    int simSwingHighBar = 0
    int simSwingLowBar = 0
    float simSwingHighTf = array.get(simFastPath, 0)
    float simSwingLowTf = array.get(simFastPath, 0)

    float simLastBuyCandidateLow = na
    float simLastBuyCandidateHigh = na
    int simLastBuyCandidateBar = na
    float simLastSellCandidateHigh = na
    float simLastSellCandidateLow = na
    int simLastSellCandidateBar = na

    bool simPendingCandidateActive = false
    int simPendingCandidateDir = 0
    int simPendingCandidateBar = na
    float simPendingCandidatePx = na
    float simPendingCandidateLow = na
    float simPendingCandidateHigh = na
    float simPendingPriorSamePx = na
    float simPendingOppositePx = na
    bool simPendingNeedsElapsedBar = false

    bool simFilteredBuyBlockActive = false
    bool simFilteredSellBlockActive = false
    int simFilteredBuyBlockBar = na
    int simFilteredSellBlockBar = na
    float simFilteredBuyBlockPrice = na
    float simFilteredSellBlockPrice = na
    int simFilteredBuyBlockConfirmBar = na
    int simFilteredSellBlockConfirmBar = na

    for i = 1 to simN - 1
        int simBar = simBaseBar + i
        float simTfPrev = array.get(simFastPath, i - 1)
        float simTfNow = array.get(simFastPath, i)
        float simPxHigh = array.get(rawHi, i)
        float simPxLow = array.get(rawLo, i)
        float simPxNow = array.get(rawPx, i)
        int simFastStepDir = f_sign(simTfNow - simTfPrev)
        bool simTfIsFlat = simFastStepDir == 0
        int simEntryRefDirNow = array.get(refDirByBar, i)
        bool simEntryRefFlatNow = simEntryRefDirNow == 0
        int simEntryRefSignalPivIdxNow = array.get(refSignalPivotByBar, i)
        bool refGateOn = useReferencePathAgreementEntryFilter

        bool simCandBuyThisBar = false
        bool simCandSellThisBar = false
        int simCandBuyBarThis = na
        int simCandSellBarThis = na
        float simCandBuyPxThis = na
        float simCandBuyLowThis = na
        float simCandBuyHighThis = na
        float simCandSellPxThis = na
        float simCandSellLowThis = na
        float simCandSellHighThis = na
        bool simCandidateBuyConfirmedNow = false
        bool simCandidateSellConfirmedNow = false
        float simConfirmedCandidatePxNow = na
        int simConfirmedCandidateBarNow = na

        // Evaluate the retained pending candidate before creating a new candidate on this bar.
        if simPendingCandidateActive
            int simCandAge = i - simPendingCandidateBar
            bool simCandIsBuy = simPendingCandidateDir == 1
            if simCandIsBuy and simPxLow < simPendingCandidatePx
                simPendingCandidatePx := simPxLow
                simPendingCandidateLow := simPxLow
                simPendingCandidateHigh := simPxHigh
            else if (not simCandIsBuy) and simPxHigh > simPendingCandidatePx
                simPendingCandidatePx := simPxHigh
                simPendingCandidateHigh := simPxHigh
                simPendingCandidateLow := simPxLow
            float simEvalCandidatePx = simPendingCandidatePx
            bool simWithinCandidateWindow = simCandAge >= 0 and (simCandAge <= maxCandidateEntryDelayBars or (keepActiveFilteredCandidate and refGateOn))
            bool simCandidateReady = (not simPendingNeedsElapsedBar) or simCandAge > 0
            if simWithinCandidateWindow and simCandidateReady
                simCandidateBuyConfirmedNow := simCandIsBuy
                simCandidateSellConfirmedNow := not simCandIsBuy
                simConfirmedCandidatePxNow := simEvalCandidatePx
                simConfirmedCandidateBarNow := simPendingCandidateBar
                if simCandIsBuy
                    simLastBuyCandidateLow := simEvalCandidatePx
                    simLastBuyCandidateHigh := simPendingCandidateHigh
                    simLastBuyCandidateBar := f_candBar(simPendingCandidateBar, false)
                else
                    simLastSellCandidateHigh := simEvalCandidatePx
                    simLastSellCandidateLow := simPendingCandidateLow
                    simLastSellCandidateBar := f_candBar(simPendingCandidateBar, false)
                simPendingCandidateActive := false
            else if simCandAge >= maxCandidateEntryDelayBars and not (keepActiveFilteredCandidate and refGateOn)
                if simCandIsBuy
                    simLastBuyCandidateLow := simEvalCandidatePx
                    simLastBuyCandidateHigh := simPendingCandidateHigh
                    simLastBuyCandidateBar := f_candBar(simPendingCandidateBar, true)
                else
                    simLastSellCandidateHigh := simEvalCandidatePx
                    simLastSellCandidateLow := simPendingCandidateLow
                    simLastSellCandidateBar := f_candBar(simPendingCandidateBar, true)
                if f_filteredLblsOn()
                    f_pushReplayLbl(histBuyFiltReplayLabs, simBaseBar + simPendingCandidateBar, simEvalCandidatePx, (simCandIsBuy ? "BUY" : "SELL") + " FILTERED • WAIT", simCandIsBuy ? label.style_label_up : label.style_label_down, color.new(color.gray, 0))
                simPendingCandidateActive := false

        // Create candidates from the direction transition that was actually resolved on this replay bar.
        // This uses the permanently stored forward-only reference state, so a later continuation
        // cannot erase an intervening opposite transition that existed in realtime.
        int simEntryRefDirPrev = i > 1 ? array.get(refDirByBar, i - 1) : 0
        bool simResolvedUpTransition = simEntryRefDirPrev < 0 and simEntryRefDirNow > 0
        bool simResolvedDownTransition = simEntryRefDirPrev > 0 and simEntryRefDirNow < 0
        int simResolvedPivotBar = simEntryRefSignalPivIdxNow
        bool simResolvedPivotOk = not na(simResolvedPivotBar) and simResolvedPivotBar >= 0 and simResolvedPivotBar < simN

        if simResolvedUpTransition and simResolvedPivotOk
            simCandBuyThisBar := true
            simCandBuyBarThis := simResolvedPivotBar
            simCandBuyPxThis := array.get(rawLo, simResolvedPivotBar)
            simCandBuyLowThis := array.get(rawLo, simResolvedPivotBar)
            simCandBuyHighThis := array.get(rawHi, simResolvedPivotBar)
        else if simResolvedDownTransition and simResolvedPivotOk
            simCandSellThisBar := true
            simCandSellBarThis := simResolvedPivotBar
            simCandSellPxThis := array.get(rawHi, simResolvedPivotBar)
            simCandSellHighThis := array.get(rawHi, simResolvedPivotBar)
            simCandSellLowThis := array.get(rawLo, simResolvedPivotBar)

        if simCandBuyThisBar
            bool simBuySameAfterOpp = not na(simLastBuyCandidateLow) and (na(simLastSellCandidateBar) or f_candIdx(simLastBuyCandidateBar) > f_candIdx(simLastSellCandidateBar))
            float simBuyProgressRef = simBuySameAfterOpp ? simLastBuyCandidateLow : simLastSellCandidateLow
            simPendingCandidateActive := true
            simPendingCandidateDir := 1
            simPendingCandidateBar := simCandBuyBarThis
            simPendingCandidatePx := simCandBuyPxThis
            simPendingCandidateLow := simCandBuyLowThis
            simPendingCandidateHigh := simCandBuyHighThis
            simPendingPriorSamePx := simBuyProgressRef
            simPendingOppositePx := simLastSellCandidateHigh
            simPendingNeedsElapsedBar := na(simBuyProgressRef)
        if simCandSellThisBar
            bool simSellSameAfterOpp = not na(simLastSellCandidateHigh) and (na(simLastBuyCandidateBar) or f_candIdx(simLastSellCandidateBar) > f_candIdx(simLastBuyCandidateBar))
            float simSellProgressRef = simSellSameAfterOpp ? simLastSellCandidateHigh : simLastBuyCandidateHigh
            simPendingCandidateActive := true
            simPendingCandidateDir := -1
            simPendingCandidateBar := simCandSellBarThis
            simPendingCandidatePx := simCandSellPxThis
            simPendingCandidateLow := simCandSellLowThis
            simPendingCandidateHigh := simCandSellHighThis
            simPendingPriorSamePx := simSellProgressRef
            simPendingOppositePx := simLastBuyCandidateLow
            simPendingNeedsElapsedBar := na(simSellProgressRef)

        // Reevaluate a newly created candidate on the same confirmed replay bar when its progression reference is already established.
        if simPendingCandidateActive and (simCandBuyThisBar or simCandSellThisBar)
            int simCandAge0 = i - simPendingCandidateBar
            bool simCandIsBuy0 = simPendingCandidateDir == 1
            float simEvalCandidatePx0 = simPendingCandidatePx
            bool simCandidateReady0 = (not simPendingNeedsElapsedBar) or simCandAge0 > 0
            if (simCandAge0 <= maxCandidateEntryDelayBars or (keepActiveFilteredCandidate and refGateOn)) and simCandidateReady0
                simCandidateBuyConfirmedNow := simCandIsBuy0
                simCandidateSellConfirmedNow := not simCandIsBuy0
                simConfirmedCandidatePxNow := simEvalCandidatePx0
                simConfirmedCandidateBarNow := simPendingCandidateBar
                if simCandIsBuy0
                    simLastBuyCandidateLow := simEvalCandidatePx0
                    simLastBuyCandidateHigh := simPendingCandidateHigh
                    simLastBuyCandidateBar := f_candBar(simPendingCandidateBar, false)
                else
                    simLastSellCandidateHigh := simEvalCandidatePx0
                    simLastSellCandidateLow := simPendingCandidateLow
                    simLastSellCandidateBar := f_candBar(simPendingCandidateBar, false)
                simPendingCandidateActive := false
            else if simCandAge0 >= maxCandidateEntryDelayBars and not (keepActiveFilteredCandidate and refGateOn)
                if simCandIsBuy0
                    simLastBuyCandidateLow := simEvalCandidatePx0
                    simLastBuyCandidateHigh := simPendingCandidateHigh
                    simLastBuyCandidateBar := f_candBar(simPendingCandidateBar, true)
                else
                    simLastSellCandidateHigh := simEvalCandidatePx0
                    simLastSellCandidateLow := simPendingCandidateLow
                    simLastSellCandidateBar := f_candBar(simPendingCandidateBar, true)
                if f_filteredLblsOn()
                    f_pushReplayLbl(histBuyFiltReplayLabs, simBaseBar + simPendingCandidateBar, simEvalCandidatePx0, (simCandIsBuy0 ? "BUY" : "SELL") + " FILTERED • WAIT", simCandIsBuy0 ? label.style_label_up : label.style_label_down, color.new(color.gray, 0))
                simPendingCandidateActive := false

        int rawConfirmDir = simCandidateBuyConfirmedNow ? 1 : simCandidateSellConfirmedNow ? -1 : 0
        bool rawConfirmActive = rawConfirmDir != 0 and not na(simConfirmedCandidateBarNow)
        bool filteredBuyMemoryActive = keepActiveFilteredCandidate and simFilteredBuyBlockActive and not na(simFilteredBuyBlockBar)
        bool filteredSellMemoryActive = keepActiveFilteredCandidate and simFilteredSellBlockActive and not na(simFilteredSellBlockBar)

        int gateCandidateBar = filteredBuyMemoryActive ? simFilteredBuyBlockBar : filteredSellMemoryActive ? simFilteredSellBlockBar : rawConfirmActive ? simConfirmedCandidateBarNow : na
        int gateCandidateDir = filteredBuyMemoryActive ? 1 : filteredSellMemoryActive ? -1 : rawConfirmDir
        bool gateCandidateIndexOk = not na(gateCandidateBar) and gateCandidateBar >= 0 and gateCandidateBar < simN
        bool gateCandidateAtPathPivot = gateCandidateIndexOk and not na(simEntryRefSignalPivIdxNow) and gateCandidateBar == simEntryRefSignalPivIdxNow
        bool gateCandidatePass = gateCandidateDir != 0 and f_refEntryGate(gateCandidateDir > 0, gateCandidateAtPathPivot, simEntryRefDirNow, simEntryRefFlatNow)

        bool rawCandidateBlocked = rawConfirmActive and not gateCandidatePass
        bool filteredMemoryTrigger = (filteredBuyMemoryActive or filteredSellMemoryActive) and gateCandidatePass

        int acceptedCandidateConfirmBar = filteredBuyMemoryActive ? simFilteredBuyBlockConfirmBar : filteredSellMemoryActive ? simFilteredSellBlockConfirmBar : simBar
        if filteredMemoryTrigger
            simCandidateBuyConfirmedNow := gateCandidateDir > 0
            simCandidateSellConfirmedNow := gateCandidateDir < 0
            simConfirmedCandidateBarNow := gateCandidateBar
            simConfirmedCandidatePxNow := gateCandidateDir > 0 ? simFilteredBuyBlockPrice : simFilteredSellBlockPrice
            if gateCandidateDir > 0
                simFilteredBuyBlockActive := false
                simFilteredBuyBlockBar := na
                simFilteredBuyBlockPrice := na
                simFilteredBuyBlockConfirmBar := na
                simFilteredSellBlockActive := false
                simFilteredSellBlockBar := na
                simFilteredSellBlockPrice := na
                simFilteredSellBlockConfirmBar := na
            else
                simFilteredSellBlockActive := false
                simFilteredSellBlockBar := na
                simFilteredSellBlockPrice := na
                simFilteredSellBlockConfirmBar := na
                simFilteredBuyBlockActive := false
                simFilteredBuyBlockBar := na
                simFilteredBuyBlockPrice := na
                simFilteredBuyBlockConfirmBar := na

        int confirmDir = simCandidateBuyConfirmedNow ? 1 : simCandidateSellConfirmedNow ? -1 : 0
        if rawCandidateBlocked
            replayPathFilteredCount += 1
            if showFilteredCandidateLabels and not optReplayStatsOnly
                f_pushReplayLbl(histBuyFiltReplayLabs, simBaseBar + simConfirmedCandidateBarNow, simConfirmedCandidatePxNow, (rawConfirmDir > 0 ? "BUY" : "SELL") + " FILTERED • PATH DISAGREEMENT", rawConfirmDir > 0 ? label.style_label_up : label.style_label_down, color.new(color.gray, 0))
            if keepActiveFilteredCandidate
                if rawConfirmDir > 0
                    simFilteredBuyBlockActive := true
                    simFilteredBuyBlockBar := simConfirmedCandidateBarNow
                    simFilteredBuyBlockPrice := simConfirmedCandidatePxNow
                    simFilteredBuyBlockConfirmBar := simBar
                    simFilteredSellBlockActive := false
                    simFilteredSellBlockBar := na
                    simFilteredSellBlockPrice := na
                else
                    simFilteredSellBlockActive := true
                    simFilteredSellBlockBar := simConfirmedCandidateBarNow
                    simFilteredSellBlockPrice := simConfirmedCandidatePxNow
                    simFilteredSellBlockConfirmBar := simBar
                    simFilteredBuyBlockActive := false
                    simFilteredBuyBlockBar := na
                    simFilteredBuyBlockPrice := na
            simCandidateBuyConfirmedNow := false
            simCandidateSellConfirmedNow := false
            confirmDir := 0

        if confirmDir != 0 and not na(simConfirmedCandidateBarNow) and (filteredMemoryTrigger or gateCandidatePass)
            int terminalBarAbs = simBaseBar + simConfirmedCandidateBarNow
            float provisionalConfirmPriceNow = simPxNow
            int structuralDirAtSignal = array.get(structuralDirByBar, i)
            int provisionalClassCode = structuralDirAtSignal != 0 and structuralDirAtSignal == confirmDir ? 1 : structuralDirAtSignal != 0 ? -1 : 0

            array.push(provisionalDir, confirmDir)
            array.push(provisionalTerminal, simConfirmedCandidateBarNow)
            array.push(provisionalTerminalPrice, simConfirmedCandidatePxNow)
            array.push(provisionalConfirm, i)
            array.push(provisionalConfirmPrice, provisionalConfirmPriceNow)
            array.push(provisionalClass, provisionalClassCode)
            array.push(provisionalResolved, false)
            array.push(provisionalSignalDirLedger, confirmDir)
            array.push(provisionalSignalTerminalBarLedger, terminalBarAbs)
            array.push(provisionalSignalTerminalPriceLedger, simConfirmedCandidatePxNow)
            array.push(provisionalSignalConfirmBarLedger, simBar)

            if simBar == bar_index
                provisionalTriggerBuy := confirmDir > 0
                provisionalTriggerSell := confirmDir < 0

            if showProvisionalCandidateSignals and not optReplayStatsOnly
                string provisionalClassText = provisionalClassCode == 1 ? "CONTINUATION" : provisionalClassCode == -1 ? "REVERSAL" : "UNRESOLVED"
                string provisionalText = "PROVISIONAL " + (confirmDir > 0 ? "BUY " : "SELL ") + provisionalClassText
                if showDetailedLabelText
                    provisionalText += "\nterminal " + str.tostring(terminalBarAbs) + " @ " + str.tostring(simConfirmedCandidatePxNow, format.mintick)
                    provisionalText += "\nprovisional confirmation " + str.tostring(simBar) + " @ " + str.tostring(provisionalConfirmPriceNow, format.mintick)
                label provisionalLabel = label.new(simBar, confirmDir > 0 ? simPxLow : simPxHigh, provisionalText, xloc=xloc.bar_index, style=confirmDir > 0 ? label.style_label_up : label.style_label_down, textcolor=color.white, color=confirmDir > 0 ? color.new(color.rgb(46, 74, 112), immediateSignalTransparency) : color.new(color.rgb(176, 82, 64), immediateSignalTransparency), size=size.tiny)
                if confirmDir > 0
                    array.push(histBuyReplayLabs, provisionalLabel)
                else
                    array.push(histSellReplayLabs, provisionalLabel)

        // Structural finalization is the only writer of the official signal ledger.
        while structuralCommitCursor < array.size(structuralEventDir) and array.get(structuralEventConfirm, structuralCommitCursor) <= i
            int committedDir = array.get(structuralEventDir, structuralCommitCursor)
            int committedTerminal = array.get(structuralEventTerminal, structuralCommitCursor)
            float committedTerminalPrice = array.get(structuralEventPrice, structuralCommitCursor)
            int committedConfirm = array.get(structuralEventConfirm, structuralCommitCursor)

            int selectedAttempt = na
            int selectedConfirm = -1
            int attemptCount = array.size(provisionalDir)
            if attemptCount > 0
                for pa = 0 to attemptCount - 1
                    int paConfirm = array.get(provisionalConfirm, pa)
                    bool availableAttempt = not array.get(provisionalResolved, pa)
                    bool insideCompletedSwing = paConfirm > previousStructuralConfirm and paConfirm <= committedConfirm
                    bool terminalNotAfterTruth = array.get(provisionalTerminal, pa) <= committedTerminal
                    if availableAttempt and array.get(provisionalDir, pa) == committedDir and insideCompletedSwing and terminalNotAfterTruth and paConfirm >= selectedConfirm
                        selectedAttempt := pa
                        selectedConfirm := paConfirm

            bool matchedProvisional = not na(selectedAttempt)
            int finalizedClass = matchedProvisional ? array.get(provisionalClass, selectedAttempt) : 0
            if attemptCount > 0
                for pa = 0 to attemptCount - 1
                    int paConfirm = array.get(provisionalConfirm, pa)
                    bool inResolvedWindow = not array.get(provisionalResolved, pa) and paConfirm > previousStructuralConfirm and paConfirm <= committedConfirm
                    if inResolvedWindow
                        array.set(provisionalResolved, pa, true)
                        if showFailedCandidateSignals and pa != selectedAttempt and not optReplayStatsOnly
                            int failedDir = array.get(provisionalDir, pa)
                            int failedAbsBar = simBaseBar + array.get(provisionalConfirm, pa)
                            float failedPrice = array.get(provisionalConfirmPrice, pa)
                            label failedLabel = label.new(failedAbsBar, failedPrice, "FAILED PROVISIONAL " + (failedDir > 0 ? "BUY" : "SELL"), xloc=xloc.bar_index, style=failedDir > 0 ? label.style_label_up : label.style_label_down, textcolor=color.white, color=color.new(color.gray, 20), size=size.tiny)
                            if failedDir > 0
                                array.push(histBuyReplayLabs, failedLabel)
                            else
                                array.push(histSellReplayLabs, failedLabel)

            int committedTerminalAbs = simBaseBar + committedTerminal
            int committedConfirmAbs = simBaseBar + committedConfirm
            float finalizedPrice = array.get(rawPx, committedConfirm)
            float adverseDistancePct = committedDir > 0 ? math.max(finalizedPrice - committedTerminalPrice, 0.0) * 100.0 / math.max(math.abs(committedTerminalPrice), eps) : math.max(committedTerminalPrice - finalizedPrice, 0.0) * 100.0 / math.max(math.abs(committedTerminalPrice), eps)
            int finalizedDelayBars = math.max(committedConfirm - committedTerminal, 0)

            array.push(confirmedSignalDirLedger, committedDir)
            array.push(confirmedSignalTerminalBarLedger, committedTerminalAbs)
            array.push(confirmedSignalTerminalPriceLedger, committedTerminalPrice)
            array.push(confirmedSignalConfirmBarLedger, committedConfirmAbs)
            array.push(confirmedSignalConfirmPriceLedger, finalizedPrice)
            array.push(confirmedSignalClassLedger, finalizedClass)

            replaySignalCount += 1
            replayBuyCount += committedDir > 0 ? 1 : 0
            replaySellCount += committedDir < 0 ? 1 : 0
            replayContinuationCount += finalizedClass == 1 ? 1 : 0
            replayReversalCount += finalizedClass == -1 ? 1 : 0
            replayUnresolvedClassCount += finalizedClass == 0 ? 1 : 0
            replayCandidateDelaySum += finalizedDelayBars
            replayExecutableDelaySum += finalizedDelayBars
            replayDistanceSum += adverseDistancePct
            replayMaxDistance := math.max(replayMaxDistance, adverseDistancePct)
            replayLastSignalDir := committedDir
            replayLastCandidateDelay := finalizedDelayBars
            replayLastExecutableDelay := finalizedDelayBars
            replayLastDistance := adverseDistancePct

            if showSignals and not optReplayStatsOnly
                string finalizedClassText = finalizedClass == 1 ? "CONTINUATION" : finalizedClass == -1 ? "REVERSAL" : "UNRESOLVED"
                string txt = "FINALIZED " + (committedDir > 0 ? "BUY " : "SELL ") + finalizedClassText
                if showDetailedLabelText
                    txt += "\nterminal " + str.tostring(committedTerminalAbs) + " @ " + str.tostring(committedTerminalPrice, format.mintick)
                    txt += "\nfinalization " + str.tostring(committedConfirmAbs) + " @ " + str.tostring(finalizedPrice, format.mintick)
                    txt += "\ndelay " + str.tostring(finalizedDelayBars) + " bars • distance " + str.tostring(adverseDistancePct, "#.##") + "%"
                int plotBar = plotAtConfirmBar ? committedConfirmAbs : committedTerminalAbs
                int plotReplayIndex = committedConfirmAbs - simBaseBar
                float finalizationBarAnchor = plotReplayIndex >= 0 and plotReplayIndex < simN ? (committedDir > 0 ? array.get(rawLo, plotReplayIndex) : array.get(rawHi, plotReplayIndex)) : finalizedPrice
                float plotPrice = plotAtConfirmBar ? finalizationBarAnchor : committedTerminalPrice
                if keepOnlyLastPair
                    if committedDir > 0 and not na(lastBuyLab)
                        label.delete(lastBuyLab)
                    if committedDir < 0 and not na(lastSellLab)
                        label.delete(lastSellLab)
                label lb = label.new(plotBar, plotPrice, txt, xloc=xloc.bar_index, style=committedDir > 0 ? label.style_label_up : label.style_label_down, textcolor=color.white, color=committedDir > 0 ? color.new(color.green, immediateSignalTransparency) : color.new(color.red, immediateSignalTransparency), size=size.small)
                if committedDir > 0
                    array.push(histBuyReplayLabs, lb)
                    lastBuyLab := lb
                else
                    array.push(histSellReplayLabs, lb)
                    lastSellLab := lb

            if committedConfirmAbs == bar_index
                finalizedTriggerBuy := committedDir > 0
                finalizedTriggerSell := committedDir < 0
            previousStructuralConfirm := committedConfirm
            structuralCommitCursor += 1

    if not na(liveCandidateLabel)
        label.delete(liveCandidateLabel)
        liveCandidateLabel := na
    if showLiveCandidateLabel and simPendingCandidateActive
        int liveBar = simBaseBar + simPendingCandidateBar
        liveCandidateLabel := label.new(liveBar, simPendingCandidatePx, simPendingCandidateDir > 0 ? "CAND BUY" : "CAND SELL", xloc=xloc.bar_index, style=simPendingCandidateDir > 0 ? label.style_label_up : label.style_label_down, textcolor=color.white, color=color.new(color.gray, 20), size=size.tiny)

//==================================================================================================
// SECTION 5 — PROVISIONAL AND FINALIZED TRANSFORM SUPPORT / RESISTANCE
//==================================================================================================
var line[] supportLines = array.new_line()
var line[] resistanceLines = array.new_line()

if barstate.islast
    f_clearLineArr(supportLines)
    f_clearLineArr(resistanceLines)
    int provisionalEc = array.size(provisionalSignalDirLedger)
    int finalizedEc = array.size(confirmedSignalDirLedger)
    int replayCloseCount = array.size(bestFitStatsClosePath)
    int replayCloseBaseBar = bar_index + 1 - replayCloseCount
    if showConfirmedSupportResistance and replayCloseCount > 0 and (provisionalEc > 0 or finalizedEc > 0)
        int breakTreeSize = 1
        while breakTreeSize < replayCloseCount
            breakTreeSize *= 2
        float[] breakMinTree = array.new_float(breakTreeSize * 2, 1e100)
        float[] breakMaxTree = array.new_float(breakTreeSize * 2, -1e100)
        for ci = 0 to replayCloseCount - 1
            float cv = array.get(bestFitStatsClosePath, ci)
            if not na(cv)
                array.set(breakMinTree, breakTreeSize + ci, cv)
                array.set(breakMaxTree, breakTreeSize + ci, cv)
        int treeNode = breakTreeSize - 1
        while treeNode >= 1
            array.set(breakMinTree, treeNode, math.min(array.get(breakMinTree, treeNode * 2), array.get(breakMinTree, treeNode * 2 + 1)))
            array.set(breakMaxTree, treeNode, math.max(array.get(breakMaxTree, treeNode * 2), array.get(breakMaxTree, treeNode * 2 + 1)))
            treeNode -= 1

        int totalSources = provisionalEc + finalizedEc
        for sourceIndex = 0 to totalSources - 1
            bool provisionalSource = sourceIndex < provisionalEc
            int e = provisionalSource ? sourceIndex : sourceIndex - provisionalEc
            int d = provisionalSource ? array.get(provisionalSignalDirLedger, e) : array.get(confirmedSignalDirLedger, e)
            int tb = provisionalSource ? array.get(provisionalSignalTerminalBarLedger, e) : array.get(confirmedSignalTerminalBarLedger, e)
            float tp = provisionalSource ? array.get(provisionalSignalTerminalPriceLedger, e) : array.get(confirmedSignalTerminalPriceLedger, e)
            int cb = provisionalSource ? array.get(provisionalSignalConfirmBarLedger, e) : array.get(confirmedSignalConfirmBarLedger, e)
            bool duplicateFinalized = false
            if not provisionalSource and provisionalEc > 0
                for p = 0 to provisionalEc - 1
                    if array.get(provisionalSignalDirLedger, p) == d and array.get(provisionalSignalTerminalBarLedger, p) == tb and math.abs(array.get(provisionalSignalTerminalPriceLedger, p) - tp) <= eps
                        duplicateFinalized := true
                        break
            if not duplicateFinalized
                int breakScanStartBar = math.max(cb + 1, replayCloseBaseBar)
                int breakStartIdx = breakScanStartBar - replayCloseBaseBar
                int breakIdx = breakScanStartBar <= bar_index ? (d > 0 ? f_firstBelow(breakMinTree, breakTreeSize, breakStartIdx, replayCloseCount - 1, tp) : f_firstAbove(breakMaxTree, breakTreeSize, breakStartIdx, replayCloseCount - 1, tp)) : na
                int breakBar = na(breakIdx) ? na : replayCloseBaseBar + breakIdx
                if na(breakBar) or keepBrokenSupportResistanceLevels
                    int x2 = na(breakBar) ? bar_index : breakBar
                    color levelColor = d > 0 ? color.new(color.green, na(breakBar) ? 20 : 70) : color.new(color.red, na(breakBar) ? 20 : 70)
                    line ln = line.new(tb, tp, x2, tp, xloc=xloc.bar_index, extend=na(breakBar) and extendConfirmedSupportResistance ? extend.right : extend.none, color=levelColor, width=supportResistanceWidth, style=na(breakBar) ? line.style_solid : line.style_dashed)
                    if d > 0
                        array.push(supportLines, ln)
                    else
                        array.push(resistanceLines, ln)


//==================================================================================================
// SECTION 6 — ENTRY-REFERENCE AND EXIT RESOLUTION
//==================================================================================================

var label[] exitResolutionLabels = array.new_label()
var line activeEntryReferenceLine = na
var line activeTerminalExitLine = na
var line activeTargetExitLine = na

var int exitActiveDir = 0
var int exitEntryBar = na
var float exitEntryPrice = na
var float exitEntryTerminal = na
var string exitLastReason = "NONE"
var int exitLastBar = na
var float exitLastPrice = na
var bool exitTriggerLong = false
var bool exitTriggerShort = false

f_exitReturnPct(int _dir, float _entry, float _price) =>
    _dir > 0 ? (_price - _entry) * 100.0 / math.max(math.abs(_entry), eps) : (_entry - _price) * 100.0 / math.max(math.abs(_entry), eps)

f_targetPrice(int _dir, float _entry, float _terminal) =>
    float _target = na
    if targetExitMode == "Minimum Profit %"
        _target := _dir > 0 ? _entry * (1.0 + minimumProfitTargetPct / 100.0) : _entry * (1.0 - minimumProfitTargetPct / 100.0)
    else if targetExitMode == "Risk/Reward"
        float _riskDistance = _dir > 0 ? _entry - _terminal : _terminal - _entry
        if _riskDistance > eps
            _target := _dir > 0 ? _entry + _riskDistance * riskRewardMultiple : _entry - _riskDistance * riskRewardMultiple
    _target

f_closeAtAbsBar(int _absBar, int _baseBar, float[] _closeArr) =>
    int _idx = _absBar - _baseBar
    _idx >= 0 and _idx < array.size(_closeArr) ? array.get(_closeArr, _idx) : na

f_addExitLabel(int _bar, float _price, int _dir, string _reason) =>
    if showExitLocations
        label _lb = label.new(_bar, _price, _reason, xloc=xloc.bar_index, style=_dir > 0 ? label.style_label_down : label.style_label_up, color=color.new(color.orange, 0), textcolor=color.white, size=size.small)
        array.push(exitResolutionLabels, _lb)

f_addEntryReferenceLabel(int _bar, float _price, int _dir) =>
    if showEntryReferenceMarkers
        label _lb = label.new(_bar, _price, _dir > 0 ? "LONG REFERENCE" : "SHORT REFERENCE", xloc=xloc.bar_index, style=_dir > 0 ? label.style_label_up : label.style_label_down, color=color.new(color.gray, 20), textcolor=color.white, size=size.tiny)
        array.push(exitResolutionLabels, _lb)

if barstate.islast
    f_clearLabelArr(exitResolutionLabels)

    if not na(activeEntryReferenceLine)
        line.delete(activeEntryReferenceLine)
        activeEntryReferenceLine := na
    if not na(activeTerminalExitLine)
        line.delete(activeTerminalExitLine)
        activeTerminalExitLine := na
    if not na(activeTargetExitLine)
        line.delete(activeTargetExitLine)
        activeTargetExitLine := na

    exitActiveDir := 0
    exitEntryBar := na
    exitEntryPrice := na
    exitEntryTerminal := na
    exitLastReason := "NONE"
    exitLastBar := na
    exitLastPrice := na
    exitTriggerLong := false
    exitTriggerShort := false

    int replayCloseCountForExit = array.size(bestFitStatsClosePath)
    int replayCloseBaseForExit = bar_index + 1 - replayCloseCountForExit

    int entryCount = entryReferenceStage == "Provisional" ? array.size(provisionalSignalDirLedger) : array.size(confirmedSignalDirLedger)
    int oppositeCount = exitSignalStage == "Provisional" ? array.size(provisionalSignalDirLedger) : array.size(confirmedSignalDirLedger)

    int[] eventBars = array.new_int()
    int[] eventDirs = array.new_int()
    int[] eventKinds = array.new_int() // 1 entry-stage event, 2 exit-stage event
    float[] eventPrices = array.new_float()
    float[] eventTerminals = array.new_float()

    // Both persistent ledgers are already chronological. Merge them directly in O(E) time.
    // Exit-stage events precede entry-stage events when both ledgers contain an event on the same bar.
    int entryIndex = 0
    int oppositeIndex = 0
    while entryIndex < entryCount or oppositeIndex < oppositeCount
        int entryBarCandidate = entryIndex < entryCount ? (entryReferenceStage == "Provisional" ? array.get(provisionalSignalConfirmBarLedger, entryIndex) : array.get(confirmedSignalConfirmBarLedger, entryIndex)) : 2147483647
        int exitBarCandidate = oppositeIndex < oppositeCount ? (exitSignalStage == "Provisional" ? array.get(provisionalSignalConfirmBarLedger, oppositeIndex) : array.get(confirmedSignalConfirmBarLedger, oppositeIndex)) : 2147483647
        bool takeExitEvent = exitBarCandidate <= entryBarCandidate

        if takeExitEvent
            int _dir = exitSignalStage == "Provisional" ? array.get(provisionalSignalDirLedger, oppositeIndex) : array.get(confirmedSignalDirLedger, oppositeIndex)
            int _bar = exitBarCandidate
            float _price = exitSignalStage == "Provisional" ? f_closeAtAbsBar(_bar, replayCloseBaseForExit, bestFitStatsClosePath) : array.get(confirmedSignalConfirmPriceLedger, oppositeIndex)
            float _terminal = exitSignalStage == "Provisional" ? array.get(provisionalSignalTerminalPriceLedger, oppositeIndex) : array.get(confirmedSignalTerminalPriceLedger, oppositeIndex)
            array.push(eventBars, _bar)
            array.push(eventDirs, _dir)
            array.push(eventKinds, 2)
            array.push(eventPrices, _price)
            array.push(eventTerminals, _terminal)
            oppositeIndex += 1
        else
            int _dir = entryReferenceStage == "Provisional" ? array.get(provisionalSignalDirLedger, entryIndex) : array.get(confirmedSignalDirLedger, entryIndex)
            int _bar = entryBarCandidate
            float _price = entryReferenceStage == "Provisional" ? f_closeAtAbsBar(_bar, replayCloseBaseForExit, bestFitStatsClosePath) : array.get(confirmedSignalConfirmPriceLedger, entryIndex)
            float _terminal = entryReferenceStage == "Provisional" ? array.get(provisionalSignalTerminalPriceLedger, entryIndex) : array.get(confirmedSignalTerminalPriceLedger, entryIndex)
            array.push(eventBars, _bar)
            array.push(eventDirs, _dir)
            array.push(eventKinds, 1)
            array.push(eventPrices, _price)
            array.push(eventTerminals, _terminal)
            entryIndex += 1

    int eventCount = array.size(eventBars)

    int lastProcessedBar = replayCloseBaseForExit - 1

    if eventCount > 0 and replayCloseCountForExit > 0
        for e = 0 to eventCount - 1
            int eventBar = array.get(eventBars, e)
            int eventDir = array.get(eventDirs, e)
            int eventKind = array.get(eventKinds, e)
            float eventPrice = array.get(eventPrices, e)
            float eventTerminal = array.get(eventTerminals, e)

            // Resolve any confirmed terminal invalidation between the previously processed event and the current event.
            if exitActiveDir != 0 and ((exitMethod == "Entry Terminal Break" or exitMethod == "Opposite Or Terminal Break") or targetExitMode != "Off")
                int scanStart = math.max(lastProcessedBar + 1, exitEntryBar + 1)
                int scanEnd = eventBar - 1
                bool terminalExited = false
                if scanStart <= scanEnd
                    for scanBar = scanStart to scanEnd
                        if not terminalExited
                            float scanClose = f_closeAtAbsBar(scanBar, replayCloseBaseForExit, bestFitStatsClosePath)
                            bool terminalBreak = not na(scanClose) and (exitMethod == "Entry Terminal Break" or exitMethod == "Opposite Or Terminal Break") and (exitActiveDir > 0 ? scanClose < exitEntryTerminal : scanClose > exitEntryTerminal)
                            float targetPrice = f_targetPrice(exitActiveDir, exitEntryPrice, exitEntryTerminal)
                            bool targetHit = not na(scanClose) and not na(targetPrice) and (exitActiveDir > 0 ? scanClose >= targetPrice : scanClose <= targetPrice)
                            if terminalBreak or targetHit
                                int closingDir = exitActiveDir
                                string resolutionReason = terminalBreak ? "TERMINAL EXIT" : targetExitMode == "Risk/Reward" ? "RISK/REWARD TARGET" : "PROFIT TARGET"
                                f_addExitLabel(scanBar, scanClose, closingDir, resolutionReason)
                                exitLastReason := resolutionReason
                                exitLastBar := scanBar
                                exitLastPrice := scanClose
                                if scanBar == bar_index
                                    exitTriggerLong := closingDir > 0
                                    exitTriggerShort := closingDir < 0
                                exitActiveDir := 0
                                exitEntryBar := na
                                exitEntryPrice := na
                                exitEntryTerminal := na
                                terminalExited := true

            if eventKind == 2 and exitActiveDir != 0 and eventDir == -exitActiveDir and (exitMethod == "Opposite Signal" or exitMethod == "Opposite Or Terminal Break")
                float eventReturnPct = f_exitReturnPct(exitActiveDir, exitEntryPrice, eventPrice)
                bool profitReady = not requireProfitForOppositeExit or eventReturnPct >= minimumProfitForOppositeExitPct
                if profitReady
                    int closingDir = exitActiveDir
                    f_addExitLabel(eventBar, eventPrice, closingDir, "OPPOSITE EXIT")
                    exitLastReason := "OPPOSITE EXIT"
                    exitLastBar := eventBar
                    exitLastPrice := eventPrice
                    if eventBar == bar_index
                        exitTriggerLong := closingDir > 0
                        exitTriggerShort := closingDir < 0
                    exitActiveDir := 0
                    exitEntryBar := na
                    exitEntryPrice := na
                    exitEntryTerminal := na

            if eventKind == 1
                // Commit a new entry reference only when no earlier reference remains unresolved.
                if exitActiveDir == 0 and not na(eventPrice)
                    exitActiveDir := eventDir
                    exitEntryBar := eventBar
                    exitEntryPrice := eventPrice
                    exitEntryTerminal := eventTerminal
                    f_addEntryReferenceLabel(eventBar, eventPrice, eventDir)

            lastProcessedBar := math.max(lastProcessedBar, eventBar)

        // Resolve any confirmed terminal invalidation after the final merged event through the current closed bar.
        if exitActiveDir != 0 and ((exitMethod == "Entry Terminal Break" or exitMethod == "Opposite Or Terminal Break") or targetExitMode != "Off")
            int finalScanStart = math.max(lastProcessedBar + 1, exitEntryBar + 1)
            if finalScanStart <= bar_index
                bool finalTerminalExited = false
                for scanBar = finalScanStart to bar_index
                    if not finalTerminalExited
                        float scanClose = f_closeAtAbsBar(scanBar, replayCloseBaseForExit, bestFitStatsClosePath)
                        bool terminalBreak = not na(scanClose) and (exitMethod == "Entry Terminal Break" or exitMethod == "Opposite Or Terminal Break") and (exitActiveDir > 0 ? scanClose < exitEntryTerminal : scanClose > exitEntryTerminal)
                        float targetPrice = f_targetPrice(exitActiveDir, exitEntryPrice, exitEntryTerminal)
                        bool targetHit = not na(scanClose) and not na(targetPrice) and (exitActiveDir > 0 ? scanClose >= targetPrice : scanClose <= targetPrice)
                        if terminalBreak or targetHit
                            int closingDir = exitActiveDir
                            string resolutionReason = terminalBreak ? "TERMINAL EXIT" : targetExitMode == "Risk/Reward" ? "RISK/REWARD TARGET" : "PROFIT TARGET"
                            f_addExitLabel(scanBar, scanClose, closingDir, resolutionReason)
                            exitLastReason := resolutionReason
                            exitLastBar := scanBar
                            exitLastPrice := scanClose
                            if scanBar == bar_index
                                exitTriggerLong := closingDir > 0
                                exitTriggerShort := closingDir < 0
                            exitActiveDir := 0
                            exitEntryBar := na
                            exitEntryPrice := na
                            exitEntryTerminal := na
                            finalTerminalExited := true

    while array.size(exitResolutionLabels) > keepOnlyRecentExitLabels
        label.delete(array.shift(exitResolutionLabels))

    if showActiveExitReference and exitActiveDir != 0 and not na(exitEntryBar)
        activeEntryReferenceLine := line.new(exitEntryBar, exitEntryPrice, bar_index, exitEntryPrice, xloc=xloc.bar_index, extend=extend.right, color=color.new(color.blue, 20), width=1, style=line.style_dotted)
        if exitMethod == "Entry Terminal Break" or exitMethod == "Opposite Or Terminal Break"
            activeTerminalExitLine := line.new(exitEntryBar, exitEntryTerminal, bar_index, exitEntryTerminal, xloc=xloc.bar_index, extend=extend.right, color=color.new(color.orange, 0), width=2, style=line.style_dashed)
        float activeTargetPrice = f_targetPrice(exitActiveDir, exitEntryPrice, exitEntryTerminal)
        if not na(activeTargetPrice)
            activeTargetExitLine := line.new(exitEntryBar, activeTargetPrice, bar_index, activeTargetPrice, xloc=xloc.bar_index, extend=extend.right, color=color.new(color.green, 0), width=2, style=line.style_dashed)

//==================================================================================================
// SECTION 6 — COMPACT STATUS AND STATISTICS
//==================================================================================================
var table statusTable = table.new(position.top_right, 2, 15, border_width=1)

if barstate.islast
    for r = 0 to 14
        table.cell(statusTable, 0, r, "", bgcolor=color.new(color.black, 100))
        table.cell(statusTable, 1, r, "", bgcolor=color.new(color.black, 100))
    if showStatus
        table.cell(statusTable, 0, 0, "Entry-to-Exit Tool", text_color=color.white, bgcolor=color.new(color.blue, 10))
        table.cell(statusTable, 1, 0, statusPage, text_color=color.white, bgcolor=color.new(color.green, 15))
        if statusPage == "Exit State"
            f_statusCell(statusTable, 1, "Entry stage", entryReferenceStage)
            f_statusCell(statusTable, 2, "Opposite stage", exitSignalStage)
            f_statusCell(statusTable, 3, "Resolution method", exitMethod)
            f_statusCell(statusTable, 4, "Active direction", exitActiveDir > 0 ? "LONG" : exitActiveDir < 0 ? "SHORT" : "NONE")
            f_statusCell(statusTable, 5, "Entry price", na(exitEntryPrice) ? "n/a" : str.tostring(exitEntryPrice, format.mintick))
            f_statusCell(statusTable, 6, "Retained terminal", na(exitEntryTerminal) ? "n/a" : str.tostring(exitEntryTerminal, format.mintick))
            f_statusCell(statusTable, 7, "Last resolution", exitLastReason)
            f_statusCell(statusTable, 8, "Last exit bar", na(exitLastBar) ? "n/a" : str.tostring(exitLastBar))
            f_statusCell(statusTable, 9, "Last exit price", na(exitLastPrice) ? "n/a" : str.tostring(exitLastPrice, format.mintick))
            f_statusCell(statusTable, 10, "Target exit", targetExitMode)
            float statusTargetPrice = exitActiveDir != 0 ? f_targetPrice(exitActiveDir, exitEntryPrice, exitEntryTerminal) : na
            string statusTargetText = targetExitMode == "Off" ? "OFF" : exitActiveDir == 0 ? "n/a" : na(statusTargetPrice) ? "unavailable" : str.tostring(statusTargetPrice, format.mintick)
            f_statusCell(statusTable, 11, "Target price", statusTargetText)
        else if statusPage == "Signals"
            f_statusCell(statusTable, 1, "Total", str.tostring(replaySignalCount))
            f_statusCell(statusTable, 2, "BUY", str.tostring(replayBuyCount))
            f_statusCell(statusTable, 3, "SELL", str.tostring(replaySellCount))
            f_statusCell(statusTable, 4, "Reversal", str.tostring(replayReversalCount))
            f_statusCell(statusTable, 5, "Continuation", str.tostring(replayContinuationCount))
            f_statusCell(statusTable, 6, "Structurally unresolved", str.tostring(replayUnresolvedClassCount))
            f_statusCell(statusTable, 7, "Path-disagreed", str.tostring(replayPathFilteredCount))
            f_statusCell(statusTable, 8, "Avg confirm delay", replaySignalCount > 0 ? str.tostring(replayCandidateDelaySum / replaySignalCount, "#.##") + " bars" : "n/a")
            f_statusCell(statusTable, 9, "Last confirm delay", na(replayLastCandidateDelay) ? "n/a" : str.tostring(replayLastCandidateDelay) + " bars")
            f_statusCell(statusTable, 10, "Avg path-filter wait", replaySignalCount > 0 ? str.tostring(replayFilterWaitSum / replaySignalCount, "#.##") + " bars" : "n/a")
            f_statusCell(statusTable, 11, "Avg distance", replaySignalCount > 0 ? str.tostring(replayDistanceSum / replaySignalCount, "#.##") + "%" : "n/a")
            f_statusCell(statusTable, 12, "Last distance", na(replayLastDistance) ? "n/a" : str.tostring(replayLastDistance, "#.##") + "%")
        else if statusPage == "Structural"
            f_statusCell(statusTable, 1, "Resolver", structuralMode)
            f_statusCell(statusTable, 2, "Length", str.tostring(structuralLength))
            f_statusCell(statusTable, 3, "Resolved changes", str.tostring(replayStructuralCount))
            f_statusCell(statusTable, 4, "Last direction", replayLastStructuralDir > 0 ? "UP / BUY" : replayLastStructuralDir < 0 ? "DOWN / SELL" : "UNRESOLVED")
            f_statusCell(statusTable, 5, "Capturable segment", structuralMode == "Conditional Accelerated" ? str.tostring(structuralCapturablePct, "#.##") + "%" : "not used")
            f_statusCell(statusTable, 6, "Creates signals", "NO")
            f_statusCell(statusTable, 7, "Classification only", "YES")
        else if statusPage == "Support/Resistance"
            f_statusCell(statusTable, 1, "Supports drawn", str.tostring(array.size(supportLines)))
            f_statusCell(statusTable, 2, "Resistances drawn", str.tostring(array.size(resistanceLines)))
            f_statusCell(statusTable, 3, "Broken retained", keepBrokenSupportResistanceLevels ? "YES" : "NO")
            f_statusCell(statusTable, 4, "Extend active", extendConfirmedSupportResistance ? "YES" : "NO")
            f_statusCell(statusTable, 5, "Width", str.tostring(supportResistanceWidth))
            f_statusCell(statusTable, 6, "Source", "accepted transform terminals")
        else if statusPage == "Alerts"
            f_statusCell(statusTable, 1, "Resolved exit alerts", enableExitAlerts ? "enabled" : "disabled")
            f_statusCell(statusTable, 2, "Long exit event", exitTriggerLong ? "TRUE" : "false")
            f_statusCell(statusTable, 3, "Short exit event", exitTriggerShort ? "TRUE" : "false")
            f_statusCell(statusTable, 4, "Signal alerts", "optional context only")
            f_statusCell(statusTable, 5, "Order sizing", "not included")
            f_statusCell(statusTable, 6, "Execution routing", "not included")
        else if statusPage == "Guide"
            f_statusCell(statusTable, 1, "Output", "resolved exit locations")
            f_statusCell(statusTable, 2, "Entry reference", "retained signal identity")
            f_statusCell(statusTable, 3, "Opposite exit", "selected stage confirmation")
            f_statusCell(statusTable, 4, "Terminal exit", "confirmed terminal invalidation")
            f_statusCell(statusTable, 5, "Blue line", "entry confirmation price")
            f_statusCell(statusTable, 6, "Orange / green", "terminal / target level")
            f_statusCell(statusTable, 7, "Orders / sizing", "not included")
            f_statusCell(statusTable, 8, "Closed chart bar", "required for final state")

alertcondition(enableProvisionalSignalAlerts and provisionalTriggerBuy, "Provisional Transform BUY", "Informational accepted provisional Transform BUY signal with mandatory causal path agreement")
alertcondition(enableProvisionalSignalAlerts and provisionalTriggerSell, "Provisional Transform SELL", "Informational accepted provisional Transform SELL signal with mandatory causal path agreement")
alertcondition(enableFinalizedSignalAlerts and finalizedTriggerBuy, "Finalized Transform BUY Reversal / Continuation", "Informational structurally finalized Transform BUY reversal or continuation signal")
alertcondition(enableFinalizedSignalAlerts and finalizedTriggerSell, "Finalized Transform SELL Reversal / Continuation", "Informational structurally finalized Transform SELL reversal or continuation signal")

alertcondition(enableExitAlerts and exitTriggerLong, "Long Reference Exit", "Entry-to-Exit Tool resolved the active long entry reference")
alertcondition(enableExitAlerts and exitTriggerShort, "Short Reference Exit", "Entry-to-Exit Tool resolved the active short entry reference")
````
