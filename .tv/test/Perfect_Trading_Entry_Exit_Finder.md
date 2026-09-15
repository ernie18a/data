<!-- tradingview-pine-id: PUB;6e7d708659fa4815a9bfc0b1d2355dcd -->
<!-- tradingviewscripts-format: 1 -->
# Perfect Trading Entry Exit Finder

Source: https://www.tradingview.com/script/hdWFM8Hs-Perfect-Trading-Entry-Exit-Finder/

## Description

A trading entry/exit finder that searches retained structural swings for positive terminal-to-terminal opportunities, anchors each qualifying entry and exit to the actual retained terminal extremes, and preserves the corresponding causal confirmation for direct timing and opportunity comparison. Results are search and review outputs, not a guarantee of profitability or future performance.

Name:
Perfect Trading Entry Exit Finder

Searchable Name:
Perfect Trading Entry Exit Finder

Technical Name:
Retained Terminal-to-Terminal Perfect Entry Exit and Causal Confirmation Finder

Short title:
Perfect Entry Exit

Summary
Perfect Trading Entry Exit Finder is an experimental finder for locating complete retained terminal-to-terminal opportunities while preserving the corresponding causal signal timing for comparison.

The retrospective Perfect terminals are the completed ideal entry and exit endpoints defined by the Perfect search, but those exact terminal entries or exits are only causally executable at those same bars when the corresponding causal confirmation actually becomes available there.

A BUY can confirm after the retained trough has already occurred.

A SELL can confirm after the retained peak has already occurred.

Multiple signal attempts can develop before a completed structural swing establishes the retained signal identity.

A signal can appear very close to the terminal or only after part of the move has already occurred.

An earlier signal can be superseded before the structural swing finishes.

A retained signal can also survive structurally while the move to the next opposite retained terminal still produces a non-positive result.

A strong terminal-to-terminal move can begin before the corresponding causal confirmation becomes available.

Perfect Trading Entry Exit Finder attempts to expose this difference directly.

Within this script, Perfect has a specific meaning.

A Perfect Opportunity is a completed retained opposite-terminal relationship whose directional terminal-to-terminal result is positive.

The first retained terminal becomes the:

[*]PERFECT BUY
[*]or PERFECT SELL

The next retained opposite terminal becomes the corresponding:

[*]PERFECT EXIT

The interval between those retained terminals becomes:

[*]PERFECT HOLD

The Perfect Entry, Hold, and Exit remain attached to the retained terminal structure.

The corresponding causal confirmation remains separately preserved.

That allows the finder to expose both:

the complete retained terminal-to-terminal opportunity

and

the portion represented from the actual causal confirmation

without redefining one as the other.

The finder can therefore expose:

[*]Perfect Buy and Perfect Sell terminals
[*]Perfect Exit terminals
[*]Perfect Hold paths
[*]complete terminal-to-terminal opportunity
[*]corresponding causal confirmation
[*]confirmation timing difference
[*]Causal Result
[*]Opportunity Capture
[*]Confirmation Loss
[*]false/non-perfect signal context
[*]completed structural relationships
[*]and the current unfinished search state

The primary search is based on completed retained structural relationships.

An additional preview mode can expose the currently implied unfinished result at the chart edge.

Because that newest structural state is incomplete, preview-only output can change as additional bars arrive.

How it works

Perfect Trading Entry Exit Finder combines a causal signal foundation with a completed terminal-to-terminal search.

The causal signal foundation preserves what could actually become available through the forward signal process.

The Perfect search evaluates the completed retained structural opportunity.

Those two reference systems remain separate.

That separation is deliberately engineered into the finder: the completed terminal result can be reviewed alongside the causal confirmation without allowing the later result to replace what was actually available through the causal process.

The completed terminal opportunity shows the full retained swing after structural finalization.

The causal confirmation shows where the corresponding signal became available through the causal process.

The finder brings those references together for direct review without treating one as the other.

Terminal opportunity and causal confirmation

A completed terminal opportunity and the signal timing actually available through causal confirmation can differ substantially.

Once a swing has reached structural finalization, its retained terminal can be identified precisely within the completed structure.

At that terminal itself, however, the signal that ultimately corresponds to the completed opportunity may not yet have confirmed.

Price can move before confirmation becomes available.

An earlier signal can fail or be superseded.

The opposite terminal can later reveal that a retained signal did not produce a positive completed opportunity.

The finder keeps these relationships visible.

The Perfect terminal remains the Perfect terminal.

The causal confirmation remains the causal confirmation.

This allows direct comparison between:

where the complete retained opportunity began

and

where the corresponding causal signal became available

without moving either reference point to make them appear equivalent.

Perfect search structure

The Perfect search evaluates structurally finalized retained opposite-terminal relationships.

For a BUY-side opportunity, the completed structure runs from a retained trough toward a retained opposite peak.

For a SELL-side opportunity, the completed structure runs from a retained peak toward a retained opposite trough.

The finder evaluates the complete retained swing rather than an isolated signal bar.

The first retained terminal supplies the Perfect Entry reference.

The later opposite retained terminal supplies the Perfect Exit reference.

A positive directional result qualifies the completed relationship as a Perfect Opportunity.

The terminal relationship defines the Perfect search.

Causal signal foundation

The Perfect results remain connected to an underlying causal signal process.

This matters because identifying the finalized Perfect terminal retrospectively does not make that exact terminal entry or exit causally executable when the terminal bar originally occurred.

The associated causal confirmation remains separately preserved.

That provides the causal comparison reference for the completed Perfect opportunity.

Structural resolution

Structural resolution determines when a retained swing reaches structural finalization and becomes available to the completed Perfect search.

The script provides selectable structural approaches for reviewing this relationship.

These approaches can produce differences in finalization timing and retained structural presentation.

They do not change the central definition of a Perfect Opportunity:

a structurally finalized retained entry terminal followed by its retained opposite terminal with a positive directional result.

Earliest Terminal

Earliest Terminal provides an alternative structural view emphasizing earlier retained terminal context.

Original Grouping

Original Grouping provides the script's primary grouped structural view.

Conditional Accelerated

Conditional Accelerated provides an alternative earlier-finalization structural view when its conditions are satisfied.

These modes affect structural finalization and retained terminal identity while preserving the same Perfect Opportunity definition.

Retained signal identity

More than one causal signal attempt can occur during a structural swing.

The completed finder result does not treat all of those attempts as equivalent.

A retained signal identity provides the connection between the causal signal process and the structurally finalized terminal result.

Other signal attempts can remain visible as superseded or false/non-perfect context.

Retained terminal association

The finder preserves two conceptually different references:

Terminal reference

the retained structural extreme belonging to the structurally finalized opportunity.

Causal reference

the corresponding signal confirmation that was actually available through the causal signal process.

These references describe different parts of the same completed opportunity.

Neither replaces the other.

Retained terminal chain

Structurally finalized retained terminals provide the sequence used by the Perfect search.

A newest retained terminal by itself does not yet provide a complete terminal-to-terminal opportunity.

A later opposite endpoint is needed before the completed pair can be evaluated.

This prevents the normal retrospective search from treating unfinished structure as though its later endpoint were already known.

Eligible terminal pair

A structurally finalized retained opposite-terminal relationship provides the potential Perfect Entry and Perfect Exit.

The directional terminal-to-terminal result determines whether that completed relationship qualifies as a Perfect Opportunity.

The Perfect endpoints remain the retained structural terminals.

The search does not redefine them using the causal confirmation or an arbitrary interior price.

Perfect Opportunity

A Perfect Opportunity is a qualifying structurally finalized retained opposite-terminal relationship with a positive directional terminal-to-terminal result.

For a BUY-side opportunity, the retained trough is followed by a higher retained opposite terminal.

For a SELL-side opportunity, the retained peak is followed by a lower retained opposite terminal.

A zero or negative completed directional result does not qualify as Perfect.

Perfect is therefore a search definition applied to structurally finalized retained structure.

It is separate from whether the causal confirmation captured all, some, or little of that move.

Perfect Entry

The Perfect Entry is the first retained terminal of a qualifying completed opportunity.

For a BUY-side opportunity, this becomes the Perfect Buy.

For a SELL-side opportunity, this becomes the Perfect Sell.

The marker remains anchored to the retained terminal used by the completed search.

It is not moved forward to the causal confirmation.

Perfect Exit

The Perfect Exit is the retained opposite terminal that completes the qualifying opportunity.

The finalized structural endpoint defines the exit.

The finder does not replace it with an arbitrary interior price simply because that price would have produced a larger temporary result.

This preserves a consistent terminal-to-terminal definition.

Perfect Hold

PERFECT HOLD spans the complete qualifying retained opportunity.

For a Perfect BUY, it represents the retained trough-to-opposite-peak movement.

For a Perfect SELL, it represents the retained peak-to-opposite-trough movement.

The displayed hold therefore represents the complete Perfect opportunity between the two retained endpoints.

Shared Perfect Exit and next Perfect Entry

One retained terminal can conceptually complete one opportunity and begin another.

For example, a retained peak can complete a BUY-side Perfect opportunity and also become the starting terminal of a later SELL-side opportunity.

Likewise, a retained trough can complete a SELL-side opportunity and begin a later BUY-side opportunity.

The chart can present these shared terminal relationships without changing the underlying Perfect definitions.

Causal confirmation comparison

The finder can display the causal confirmation associated with a Perfect terminal opportunity.

The causal reference shows where the corresponding surviving signal became available.

The Perfect reference remains at the structurally finalized retained terminal.

This produces a direct comparison between:

Perfect terminal opportunity

and

causal signal availability

without treating the Perfect terminal as though it were known causally at that point.

Terminal-to-confirmation delay

The finder measures the timing difference between the retained Perfect Entry terminal and its corresponding causal confirmation.

A same-bar relationship has no bar delay.

A later confirmation represents a later causal availability point.

The purpose of this measurement is to expose the timing gap between the completed Perfect benchmark and the signal timing actually represented by the causal process.

Perfect result

Perfect Result is the directional percentage result between the retained Perfect Entry and retained Perfect Exit of a qualifying opportunity.

It represents the full completed terminal-to-terminal opportunity identified by the finder.

Causal result

Causal Result uses the corresponding causal confirmation as the entry reference while preserving the same completed exit context.

This allows the causal result and Perfect result to be compared within the same completed opportunity.

The two measurements answer different questions and are not interchangeable.

Opportunity Capture

Opportunity Capture describes how much of the completed Perfect opportunity is represented by the corresponding causal result.

It provides a normalized comparison between:

the complete retained opportunity

and

the result represented from causal confirmation.

Its purpose is interpretation, not to redefine either reference.

Confirmation Loss

Confirmation Loss describes the difference between the Perfect Result and corresponding Causal Result.

It shows how much of the completed terminal-to-terminal movement was not represented from the causal confirmation reference.

Perfect Result, Causal Result, Opportunity Capture, and Confirmation Loss therefore provide different views of the same completed opportunity.

False / non-perfect context

The finder can expose causal signal activity that did not become part of a qualifying Perfect Opportunity.

This can include:

1. signal attempts that were later superseded
2. structurally finalized retained relationships whose directional result was not positive

These categories help distinguish the wider causal signal stream from the subset of completed relationships classified as Perfect.

Superseded attempts

Several causal signal attempts can occur while the underlying structure is still developing.

Not every attempt becomes the retained identity associated with the structurally finalized opportunity.

Non-retained attempts can remain visible as superseded context.

This allows users to see that the eventual Perfect terminal association does not imply every earlier causal signal was correct.

Retained non-positive pairs

Structural retention alone does not automatically create a Perfect Opportunity.

A structurally finalized retained relationship must still satisfy the Perfect Opportunity definition.

If the completed directional terminal-to-terminal result is zero or negative, it does not qualify as a Perfect Opportunity and remains non-perfect context.

Unmatched newest retained terminal

The newest retained terminal remains incomplete until a later opposite terminal provides the second endpoint needed for structural finalization of the terminal-to-terminal relationship.

The normal retrospective search therefore does not prematurely classify that newest terminal as Perfect or non-perfect.

The optional preview can temporarily expose what the unfinished structure currently implies.

That preview remains separate from structurally finalized retained history.

Finder modes

The script contains two search modes:

[*]Retrospective
[*]Repainting Preview

They use the same conceptual Perfect Entry/Exit definition.

Their difference is whether the newest unfinished chart-edge structure is temporarily included.

Retrospective

Retrospective uses structurally finalized retained relationships.

Its Perfect results are based on swings whose terminal relationship has already reached structural finalization.

This is the primary review mode.

Repainting Preview

Repainting Preview temporarily extends the same search concept to the unfinished chart-right structure.

It shows what the newest result currently looks like before structural finalization has occurred.

Because the latest structural state is unfinished, preview-only output can change as future bars arrive.

The preview therefore repaints by design.

It should not be interpreted as a permanent causal Perfect signal.

Permanent completed history and preview state

The finder keeps structurally finalized retained history separate from temporary preview completion.

Finalized retrospective results belong to the completed search.

Preview-only results belong to the unfinished chart-edge state.

This allows the finder to expose both:

structurally finalized Perfect Entry/Exit structure

and

the currently implied unfinished structure

without treating them as equivalent.

Perfect Entry / Exit display

The primary display can show:

[*]Perfect Buy
[*]Perfect Sell
[*]Perfect Exit
[*]Perfect Hold
[*]terminal-to-terminal result
[*]causal confirmation comparison
[*]and supporting opportunity context

These visuals represent the underlying search result.

Display settings do not redefine what qualifies as a finalized Perfect Opportunity.

False-context display

False/non-perfect context can be displayed separately from Perfect results.

This allows the chart to show the broader causal signal activity around finalized opportunities without changing which retained terminal relationships qualify as Perfect.

Structural context

The finder retains structural context around the signals and finalized opportunities being reviewed.

This context can help distinguish finalized, unresolved, retained, or superseded relationships.

The Perfect Opportunity itself remains defined by the structurally finalized retained terminal relationship and its directional result.

Search reconstruction

The finder reconstructs the historical search context needed to display causal signal relationships, structurally finalized opportunities, and the current unfinished state.

The purpose is to preserve the distinction between causal signal timing and finalized terminal identity across loaded chart history.

Perfect Opportunity Rate

The finder calculates a Perfect Opportunity Rate describing how often eligible finalized retained terminal relationships satisfy the Perfect Opportunity definition.

Perfect Opportunity Rate is not a trading win rate.

It describes the completed search classification.

It does not establish the result of an executed strategy using causal entries, transaction costs, slippage, sizing, or external risk rules.

Search statistics

The finder provides summary statistics describing the finalized Perfect search, causal comparison, false/non-perfect context, and current search state.

These statistics are designed to help interpret the search result.

Status pages

The script includes a compact status interface for reviewing the current Perfect search, causal comparison, timing, and interpretation context.

The status display supports chart review without requiring every measurement to be placed directly on the chart.

[image]https://www.tradingview.com/x/E27CI49K/[/image]

Alerts and execution

Perfect Trading Entry Exit Finder is not an execution engine.

Retrospective Perfect terminal results identify the completed ideal entry and exit endpoints. Those exact terminal entries or exits are only causally executable at those same bars when the corresponding causal confirmation actually becomes available there.

The Perfect structure and causal confirmation are retained for search, review, and comparison.

When causal confirmation occurs later, the executable causal entry or exit occurs later; the retrospective Perfect terminal remains the completed ideal endpoint rather than an entry or exit that was available at that earlier terminal bar.

The optional preview also remains a search preview rather than an execution-ready Perfect signal source.

Finder behavior

Perfect Trading Entry Exit Finder combines causal signal identity with finalized terminal-to-terminal opportunity searching.

Its broad workflow is:

[*]causal signal activity develops
[*]retained structural relationships reach finalization
[*]a completed terminal-to-terminal relationship becomes available for review
[*]positive finalized relationships can qualify as Perfect Opportunities
[*]Perfect Entry, Hold, and Exit remain attached to the retained terminal structure
[*]and the corresponding causal confirmation remains separately available for comparison

The optional preview can temporarily extend the same search concept to the unfinished newest structure.

Features

[*]Perfect terminal-to-terminal Entry/Exit finder
[*]Perfect Buy identification
[*]Perfect Sell identification
[*]Perfect Exit identification
[*]Perfect Hold paths
[*]retained trough-to-peak opportunity review
[*]retained peak-to-trough opportunity review
[*]positive finalized opportunity classification
[*]actual retained terminal anchoring
[*]causal confirmation preservation
[*]direct Perfect-versus-causal comparison
[*]confirmation timing comparison
[*]Perfect Result
[*]Causal Result
[*]Opportunity Capture
[*]Confirmation Loss
[*]false/non-perfect context
[*]superseded signal context
[*]unresolved newest-terminal handling
[*]selectable structural views
[*]finalized historical search mode
[*]Repainting Preview
[*]false-context visualization
[*]Perfect Hold visualization
[*]causal comparison markers
[*]supporting search statistics
[*]Perfect Opportunity Rate
[*]compact review/status interface
[*]review-focused standalone finder
[*]completed ideal Perfect entry/exit endpoints compared directly with whether those exact endpoints were causally executable at the time

Strengths

Perfect Entry/Exit Search — directly finds qualifying finalized terminal-to-terminal opportunities rather than stopping at the original causal signal.

Terminal-to-Terminal Structure — Perfect Entry and Perfect Exit remain tied to retained structural endpoints.

Complete Swing Representation — Perfect Hold represents the full retained opportunity between those endpoints.

Causal Identity Preservation — keeps the corresponding causal confirmation connected to the finalized opportunity for comparison.

Direct Perfect-versus-Causal Comparison — shows both the complete retained opportunity and the result represented from causal confirmation.

Opportunity Capture Measurement — quantifies how much of the completed Perfect opportunity is represented by the causal result.

Confirmation Loss Measurement — measures the difference between Perfect and causal results.

No Arbitrary Exit Substitution — does not replace the retained opposite terminal with an arbitrary interior best price.

False-Context Separation — keeps superseded and non-positive finalized relationships distinct from qualifying Perfect Opportunities.

Unfinished-Terminal Discipline — normal retrospective results are not finalized until the necessary opposite structural endpoint exists.

Structural Choice — selectable structural views can be compared while preserving the same central Perfect concept.

Finalized-History Separation — finalized search results remain distinct from temporary chart-edge preview output.

Preview Capability — the currently implied unfinished Perfect structure can be inspected while remaining explicitly identified as repainting.

Search Diagnostics — timing, capture, confirmation loss, false context, and opportunity context remain measurable.

Weaknesses

Opposite-Terminal Requirement — the complete Perfect Entry/Exit opportunity is not known until the later retained opposite endpoint structurally finalizes the relationship.

Terminal Hindsight — the finalized retained terminal and causal confirmation are different reference systems and can occur at different times and prices.

Confirmation Delay — part of the complete terminal-to-terminal movement can occur before causal confirmation becomes available.

Superseded Signals — multiple causal attempts can occur before structural finalization establishes the retained relationship.

Non-Positive Retained Relationships — structural retention alone does not guarantee a positive Perfect Opportunity.

Perfect Definition Scope — Perfect refers specifically to the positive finalized terminal-to-terminal search definition.

No Interior Exit Optimization — the retained opposite terminal remains the Perfect Exit even if another temporary price would have produced a larger result.

Structural Dependence — different structural views can affect finalization timing and retained terminal presentation.

Causal-Signal Dependence — the comparison remains connected to an underlying causal signal process.

Preview Repainting — unfinished preview output can move, disappear, or change before structural finalization.

Perfect-Terminal Executability Is Conditional — a finalized Perfect terminal is the completed ideal entry or exit endpoint, but it is executable at that exact terminal bar only when the corresponding causal confirmation actually becomes available there.

Perfect Opportunity Rate Is Not Win Rate — it measures search classification rather than executed strategy performance.

No Execution Engine — the standalone finder does not turn Perfect search output into automated trading decisions.

No Full Strategy Return Calculation — it does not establish complete returns after sizing, transaction costs, slippage, and external trading rules.

Who it’s for

This tool is best suited for:

[*]advanced TradingView users
[*]users investigating the Perfect Entry/Exit problem
[*]users searching for complete retained terminal-to-terminal opportunities
[*]users comparing causal signal timing with structurally finalized terminal structure
[*]users studying how much of a move occurs before confirmation
[*]users examining trough-to-peak and peak-to-trough opportunities
[*]users comparing Perfect Result and Causal Result
[*]users studying Opportunity Capture
[*]users studying Confirmation Loss
[*]users examining false and superseded signal activity
[*]users studying structural finalization and retained terminal relationships
[*]users who want entry and exit markers anchored to actual retained endpoints
[*]users who do not want arbitrary interior prices substituted for Perfect Exit
[*]users who want the complete hold path between retained terminals
[*]users comparing finalized structural results with an unfinished preview
[*]users developing or evaluating separate causal methods against an explicit Perfect benchmark

Who it’s not for

This tool is not best suited for:

[*]users expecting Perfect terminal markers to be live causal signals
[*]users expecting final retained extremes to be known at the exact moment they occur
[*]users expecting every causal signal to survive structural finalization
[*]users expecting every finalized retained terminal relationship to qualify as Perfect
[*]users expecting Perfect Opportunity Rate to represent an executed trading win rate
[*]users expecting unfinished preview results to remain fixed
[*]users expecting preview-only terminal markers never to repaint
[*]users looking for broker execution from retrospective Perfect markers
[*]users looking for automated position management from Perfect results
[*]users looking for a complete trading strategy
[*]users expecting causal confirmation and Perfect terminal timing to always coincide
[*]users expecting the finder to remove confirmation delay
[*]users expecting a guarantee of profitability or future performance

Known limitations

The finder is better at:

[*]finding finalized retained terminal-to-terminal opportunity structure
[*]identifying positive finalized terminal relationships
[*]preserving complete Perfect Entry/Hold/Exit geometry
[*]anchoring results to retained structural extremes
[*]linking Perfect opportunity identity with causal signal confirmation
[*]comparing complete opportunity with causal availability
[*]measuring confirmation delay
[*]measuring Opportunity Capture
[*]measuring Confirmation Loss
[*]exposing superseded and non-perfect context
[*]comparing finalized and unfinished search structure
[*]and reviewing how causal signals relate to complete terminal swings

than it is at:

[*]identifying the final retained terminal causally before structural finalization
[*]eliminating delayed confirmation
[*]eliminating false or superseded signals
[*]guaranteeing that every retained relationship produces a positive result
[*]turning Perfect terminal markers into operational entries
[*]determining whether the newest unfinished preview terminal will remain final
[*]or determining a complete future trading result

A Perfect Opportunity is defined by the structurally finalized retained terminal relationship.

The causal confirmation can represent all, some, or very little of the complete terminal-to-terminal movement.

That difference is part of what the finder exposes.

A large Perfect Result can therefore coexist with a much smaller Causal Result.

Opportunity Capture and Confirmation Loss describe that difference.

Likewise, a retained signal can remain structurally relevant while its finalized opposite-terminal result still fails the Perfect qualification.

The term Perfect therefore belongs to the finalized search definition.

It does not imply that the finalized terminal was causally available as a Perfect signal when it originally occurred.

The optional Repainting Preview introduces an additional limitation.

It evaluates unfinished chart-right structure before structural finalization.

Future bars can therefore change preview-only output.

Finalized retrospective results remain separate from that temporary preview.

Perfect result scope

The Perfect result represents the complete retained terminal-to-terminal directional opportunity of a qualifying structurally finalized relationship.

It can include:

[*]Perfect Buy or Perfect Sell
[*]Perfect Exit
[*]Perfect Hold
[*]retained entry and exit terminals
[*]terminal-to-terminal result
[*]corresponding causal confirmation
[*]Causal Result
[*]Opportunity Capture
[*]Confirmation Loss
[*]and false/non-perfect context

These measurements preserve the complete opportunity and causal signal result as separate but directly comparable references.

Final note

Perfect Trading Entry Exit Finder is an experimental finder for the entry-and-exit problem that remains when the complete terminal opportunity and the causal signal available during that opportunity are not the same thing.

Its central capability is the retained terminal-to-terminal search.

Positive structurally finalized terminal relationships can become Perfect Opportunities.

The corresponding:

[*]Perfect Entry
[*]Perfect Hold
[*]and Perfect Exit

remain attached to the retained terminal structure.

The causal confirmation remains separately preserved.

This allows the finder to expose both:

the complete retained entry-to-exit opportunity

and

the result represented from the corresponding causal confirmation

inside the same finalized swing.

False, superseded, or non-perfect signal context remains separately visible.

The optional preview can extend the same search concept to unfinished chart-edge structure, with its repainting behavior kept separate from structurally finalized results.

Perfect Trading Entry Exit Finder therefore remains centered on the problem it attempts to address:

locating the complete retained terminal entry, hold, and opposite-terminal exit opportunity while preserving the causal signal that was actually available for comparison.

Profitability is not guaranteed.

Future performance is not guaranteed.

The finder reports the Perfect opportunity, its terminal structure, corresponding causal result, timing difference, capture, confirmation loss, and false/non-perfect context. The retrospective Perfect terminals are the completed ideal entry and exit endpoints, but those exact terminal entries or exits were only causally executable at the time when the corresponding causal confirmation actually occurred at those same terminal bars; otherwise the executable causal timing occurred elsewhere.

---

## Source Code

````pine
// © AceInfinity
// Perfect Trading Entry Exit Finder
// Retrospective mode performs the completed-history search for perfect terminal-to-terminal entries, holds, and exits using the existing causal Provisional lifecycle in which the latest eligible same-side Provisional survives when its containing structural swing resolves.
// Provisional BUY/SELL attempts are generated causally. Structural resolution keeps only the latest eligible same-side Provisional in each completed swing; the retained identity is anchored to that resolved structural terminal extreme.
// Consecutive retained opposite-side terminal extremes define the only eligible Perfect Entry/Exit swing. The first retained terminal is the hindsight PERFECT BUY/SELL and the next retained opposite terminal is its hindsight PERFECT EXIT.
// A retained terminal pair qualifies as a Perfect Opportunity only when its terminal-to-terminal directional result is positive. Superseded attempts and non-positive retained pairs are false/non-perfect context and never receive PERFECT HOLD paths.
// PERFECT HOLD spans the actual retained terminal extreme to the next retained opposite terminal extreme. The Perfect Entry/Exit visual never selects an arbitrary interior best close as the exit.
// Repainting Preview mode is a repainting hindsight preview and is not suitable for live or automated trade execution. It runs the SAME retrospective search rules against all history currently available and temporarily treats the still-unfinished chart-right structural/search state as completed at the current endpoint.
// That temporary preview exposes the newest currently implied PERFECT BUY/SELL, PERFECT HOLD, PERFECT EXIT, false/non-perfect context, and statistics immediately. Any preview-only terminal, label, line, classification, count, or percentage may move, disappear, or change when future bars arrive.
// Repainting Preview does not produce execution-ready signals, alerts, positions, orders, or causal confirmations. It shows what the retrospective search would currently display if the available history ended at the chart endpoint.
// Each retained identity separately preserves its actual causal Provisional confirmation bar and confirmation-close price. Optional causal-comparison markers expose how far the knowable confirmation was from the hindsight terminal without moving the Perfect Entry/Exit markers.
// Structural resolution and causal Provisional confirmation are retained only to establish surviving signal identity, terminal-to-terminal perfect opportunities, causal timing comparison, and false-signal context.
// This standalone does not select live confirmation stages, simulate positions, route orders, or produce execution-ready trade-management decisions.
// Results measure historical/preview opportunity and terminal identity. They are not a profitability result, actual win rate, future result, or financial advice.
//@version=6
indicator("Perfect Trading Entry Exit Finder", shorttitle="Perfect Entry Exit", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=50, max_bars_back=5000)

//==================================================================================================
// SECTION 1 — PERFECT ENTRY/EXIT SEARCH, STRUCTURAL RESOLUTION, AND DISPLAY INPUTS
//==================================================================================================
src = input.source(close, "Source")
structuralMode = input.string("Original Grouping", "Structural Resolution", options=["Earliest Terminal", "Original Grouping", "Conditional Accelerated"], tooltip="Selects the causal structural resolver that closes completed search intervals. Structural events define search resolution boundaries and do not generate Perfect Hindsight Decisions before resolution.")
structuralLength = input.int(10, "Structural Length", minval=1, tooltip="Structural context used by the selected structural resolver.")
structuralCapturablePct = input.float(20.0, "Structural Capturable Segment %", minval=0.01, step=0.05, tooltip="Used only by Conditional Accelerated structural resolution. It selects captured path potential after structural proof and does not score a search result.")
refPathMinCapturedPathPct = input.float(15.0, "Causal Entry Path Capturable Segment %", minval=0.01, step=0.05, tooltip="Controls the causal transform path used for mandatory Provisional entry agreement.")
maxCandidateEntryDelayBars = input.int(1, "Maximum Provisional Confirmation Delay Bars", minval=0, maxval=1, tooltip="A retained transform candidate can confirm on its candidate bar or the following bar. The actual confirmation close becomes the causal search entry.")
keepActiveFilteredCandidate = input.bool(true, "Keep Path-Blocked Candidate Memory", tooltip="When enabled, a valid candidate blocked only by causal path disagreement can remain pending and become a Provisional search start on the first later closed bar where its retained terminal agrees with the active causal reference pivot.")

finderMode = input.string("Repainting Preview", "Finder Mode", options=["Retrospective", "Repainting Preview"], tooltip="Retrospective shows only completed historical results. Repainting Preview uses the same retrospective rules but temporarily resolves the still-unfinished chart-right structural/search state at the current endpoint. It is a repainting hindsight preview, not a live or automated execution signal source, and its results may move, disappear, or change when future bars arrive.")

showPerfectDecisions = input.bool(true, "Show Perfect Entry / Exit", tooltip="Shows positive retained terminal-to-terminal opportunities. Retrospective requires completed terminal identities. Repainting Preview temporarily resolves the unfinished chart-right search so the currently implied PERFECT BUY/SELL, PERFECT HOLD, and PERFECT EXIT appear immediately and can update as future bars arrive.")
showRetrospectiveSearchCanvas = input.bool(true, "Show Entry / Exit Search Canvas", tooltip="Applies a subtle neutral background across the chart while Perfect Entry/Exit results are displayed.")
retrospectiveSearchCanvasTransparency = input.int(92, "Search Canvas Transparency", minval=86, maxval=97, tooltip="Controls only the neutral full-chart retrospective presentation layer. Higher values are more transparent.")
showPerfectDecisionBackground = input.bool(true, "Show Perfect Hold Background", tooltip="Adds a subtle translucent zone behind each displayed PERFECT HOLD interval. In Repainting Preview the newest zone may update with the temporary chart-end result.")
showCausalComparison = input.bool(true, "Show Causal Confirmation Comparison", tooltip="Shows a readable directional CAUSAL BUY/SELL label at the actual Provisional confirmation close for each perfect retained identity, with a thin dashed connector back to the hindsight terminal. It never changes the Perfect Entry/Exit terminal identity.")
showFalseSignals = input.bool(false, "Show False / Non-Perfect Context", tooltip="Shows the same false/non-perfect definitions in both modes: superseded Provisional attempts and retained terminal signals whose next opposite retained terminal produces a non-positive directional result. Repainting Preview also applies those definitions to its temporary chart-end completion, so preview false marks can update when future bars arrive.")
falseSignalDisplay = input.string("X Markers", "False Signal Display", options=["X Markers", "Labels"], tooltip="X Markers shows a dense, clearly distinguishable X at each false signal location. Labels shows FALSE BUY / FALSE SELL directional labels instead.")
maxFalseSignalsToDraw = input.int(160, "Maximum False Signals To Draw", minval=10, maxval=300, tooltip="Maximum number of completed false/non-perfect signals shown when the false-signal display is enabled.")
maxPerfectDecisionsToDraw = input.int(24, "Maximum Perfect Entry / Exits To Draw", minval=1, maxval=80)
searchLabelTransparency = input.int(12, "Perfect Entry / Exit Transparency", minval=0, maxval=75)

showStatus = input.bool(true, "Show Status Table")
statusPage = input.string("Summary", "Status Table Page", options=["Summary", "Perfect Entry Exit Search", "Timing", "Guide"])

// Mandatory causal transform-path agreement is part of the Provisional search-start definition.
bool useReferencePathAgreementEntryFilter = true
bool useReferencePathAgreementForShortEntry = true

//==================================================================================================
// SECTION 2 — SEARCH AND CAUSAL ENTRY HELPERS
//==================================================================================================
eps = math.max(syminfo.mintick, 1e-6)

f_sign(x)=>x > 0.0 ? 1 : x < 0.0 ? -1 : 0

f_updateCumMove(float _cum,int _dirStore,int _stepSign,float _step)=>
    _stepSign == 0 ? _cum : (_dirStore == 0 or _stepSign == _dirStore ? _cum + _step : _step)

f_candBar(int _bar,bool _filtered)=>_filtered ? -(_bar + 1) : (_bar + 1)
f_candIdx(int _bar)=>na(_bar) ? na : math.abs(_bar) - 1

f_refEntryGate(bool _buy,bool _cand,int _dir,bool _flat)=>
    bool _refOn = useReferencePathAgreementEntryFilter and (_buy or useReferencePathAgreementForShortEntry)
    bool _side = _dir == (_buy ? 1 : -1) and not _flat
    not _refOn or (_cand and _side)

f_searchReturn(int _dir,float _entry,float _exit)=>
    na(_entry) or na(_exit) or math.abs(_entry) <= eps ? na : _dir * (_exit - _entry) * 100.0 / math.abs(_entry)

f_statusCell(table _t,int _row,string _left,string _right)=>
    table.cell(_t, 0, _row, _left, text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(_t, 1, _row, _right, text_color=color.white, bgcolor=color.new(color.black, 20))

f_clearLabels(label[] _a)=>
    if array.size(_a) > 0
        for _i = 0 to array.size(_a) - 1
            label.delete(array.get(_a, _i))
    array.clear(_a)

f_clearLines(line[] _a)=>
    if array.size(_a) > 0
        for _i = 0 to array.size(_a) - 1
            line.delete(array.get(_a, _i))
    array.clear(_a)

f_clearBoxes(box[] _a)=>
    if array.size(_a) > 0
        for _i = 0 to array.size(_a) - 1
            box.delete(array.get(_a, _i))
    array.clear(_a)

f_fmtPct(float _v)=>
    na(_v) ? "n/a" : str.tostring(_v, "#.00") + "%"

f_searchResultText(bool _retained,int _class)=>
    _retained ? (_class == 1 ? "RETAINED CONTINUATION" : _class == -1 ? "RETAINED REVERSAL" : "RETAINED / UNRESOLVED CLASS") : "SUPERSEDED"


//==================================================================================================
// SECTION 3 — CAUSAL ENTRY REFERENCE PATH
//==================================================================================================
f_buildInboundCapturePathArrays(float[] _rawPx,int _nBars)=>
    // Causal entry-reference transform path built from the confirmed chart prefix.
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
// CAUSAL PREFIX-STABLE STRUCTURAL RESOLUTION
//==================================================================================================
// Structural resolver implementations retained for completed search boundaries:
//   Original Grouping uses the persistent retained-extreme lifecycle.
//   Conditional Accelerated uses the known-prefix captured-path chain.
//   Earliest Terminal uses the known-prefix earliest-capture chain.
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
            // Earliest Terminal uses the retained earliest causal capture bar.
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



//==================================================================================================
// SECTION 4 — COMPLETED SEARCH RESULT STORAGE AND VISUAL OBJECTS
//==================================================================================================
var int[] searchDir = array.new_int()
var int[] searchTerminalBar = array.new_int()
var float[] searchTerminalPrice = array.new_float()
var int[] searchEntryBar = array.new_int()
var float[] searchEntryPrice = array.new_float()
var bool[] searchRetained = array.new_bool()

var label[] searchLabels = array.new_label()
var line[] searchLines = array.new_line()
var box[] searchBoxes = array.new_box()

var int searchProfitableOpportunityCount = 0
var int searchFalseSignalCount = 0
var int searchStructuralCount = 0
var int searchLastStructuralDir = 0
var int searchOpenCount = 0
var int searchLatestOpenDir = 0
var int searchLatestOpenBar = na
var float searchLatestOpenPrice = na
var int searchPreviewTemporaryStructuralCount = 0


//==================================================================================================
// SECTION 5 — CAUSAL REPLAY AND COMPLETED SEARCH RESOLUTION
//==================================================================================================
if barstate.islast
    array.clear(searchDir)
    array.clear(searchTerminalBar)
    array.clear(searchTerminalPrice)
    array.clear(searchEntryBar)
    array.clear(searchEntryPrice)
    array.clear(searchRetained)
    searchProfitableOpportunityCount := 0
    searchFalseSignalCount := 0
    searchStructuralCount := 0
    searchLastStructuralDir := 0
    searchOpenCount := 0
    searchLatestOpenDir := 0
    searchLatestOpenBar := na
    searchLatestOpenPrice := na
    searchPreviewTemporaryStructuralCount := 0

    int historyCap = 5000
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

    [simFastPivIdx, simFastPivPx, simFastPath, simFastCum, simFastLast, simFastOpen, simFastDir] = f_buildInboundCapturePathArrays(rawPx, simN)


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

    // Repainting Preview: temporarily completes the still-unfinished chart-right structural state
    // without writing anything into the permanent csEvent* ledger.
    //
    // Original Grouping:
    //   The currently retained same-side structural group is evaluated as if the available history ended at the current chart endpoint.
    // Node-based modes:
    //   Any currently solved node that has not yet entered the immutable ledger is included locally
    //   at the chart endpoint. These temporary events exist only within the current preview rebuild.
    if finderMode == "Repainting Preview" and simN > 0
        int previewConfirmLocal = simN - 1

        if structuralMode == "Original Grouping"
            bool previewGroupAvailable = csGroupDir != 0 and not na(csGroupExtremeBar) and not na(csGroupExtremePrice) and csGroupExtremeBar >= simBaseBar and csGroupExtremeBar <= bar_index
            if previewGroupAvailable
                bool previewDuplicate = false
                int previewLocalCount = array.size(structuralEventDir)
                if previewLocalCount > 0
                    for pe = 0 to previewLocalCount - 1
                        int peTerminalAbs = simBaseBar + array.get(structuralEventTerminal, pe)
                        if array.get(structuralEventDir, pe) == csGroupDir and peTerminalAbs == csGroupExtremeBar
                            previewDuplicate := true
                            break

                int previewLastDir = previewLocalCount > 0 ? array.get(structuralEventDir, previewLocalCount - 1) : 0
                bool previewAlternationPass = previewLastDir == 0 or previewLastDir != csGroupDir
                if not previewDuplicate and previewAlternationPass
                    array.push(structuralEventDir, csGroupDir)
                    array.push(structuralEventTerminal, csGroupExtremeBar - simBaseBar)
                    array.push(structuralEventPrice, csGroupExtremePrice)
                    array.push(structuralEventConfirm, previewConfirmLocal)
                    searchPreviewTemporaryStructuralCount += 1
        else
            // csNode* is already the currently solved known-history node chain for the selected mode.
            // Expose only nodes not present in the permanent structural ledger.
            int previewNodeCount = array.size(csNodeK)
            if previewNodeCount > 0
                for pn = 0 to previewNodeCount - 1
                    int pnK = array.get(csNodeK, pn)
                    int pnDir = pnK > 0 ? -1 : 1
                    int pnTerminalAbs = array.get(csNodeX, pn)
                    float pnTerminalPx = array.get(csNodeY, pn)

                    bool pnInsideReplay = pnTerminalAbs >= simBaseBar and pnTerminalAbs <= bar_index
                    bool pnPermanent = f_csEventExists(pnDir, pnTerminalAbs)
                    bool pnLocalDuplicate = false
                    int pnLocalCount = array.size(structuralEventDir)
                    if pnLocalCount > 0
                        for ple = 0 to pnLocalCount - 1
                            int pleTerminalAbs = simBaseBar + array.get(structuralEventTerminal, ple)
                            if array.get(structuralEventDir, ple) == pnDir and pleTerminalAbs == pnTerminalAbs
                                pnLocalDuplicate := true
                                break

                    int pnLastDir = pnLocalCount > 0 ? array.get(structuralEventDir, pnLocalCount - 1) : 0
                    bool pnAlternationPass = pnLastDir == 0 or pnLastDir != pnDir

                    if pnInsideReplay and not pnPermanent and not pnLocalDuplicate and pnAlternationPass
                        array.push(structuralEventDir, pnDir)
                        array.push(structuralEventTerminal, pnTerminalAbs - simBaseBar)
                        array.push(structuralEventPrice, pnTerminalPx)
                        array.push(structuralEventConfirm, previewConfirmLocal)
                        searchPreviewTemporaryStructuralCount += 1

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
    searchStructuralCount := array.size(structuralEventDir)
    searchLastStructuralDir := searchStructuralCount > 0 ? array.get(structuralEventDir, searchStructuralCount - 1) : 0


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
                        int searchDirNow = array.get(provisionalDir, pa)
                        int searchTerminalNow = array.get(provisionalTerminal, pa)
                        float searchTerminalPxNow = array.get(provisionalTerminalPrice, pa)
                        int searchEntryNow = paConfirm
                        float searchEntryPxNow = array.get(provisionalConfirmPrice, pa)
                        bool searchRetainedNow = pa == selectedAttempt

                        int storedTerminalNow = searchRetainedNow ? committedTerminal : searchTerminalNow
                        float storedTerminalPxNow = searchRetainedNow ? committedTerminalPrice : searchTerminalPxNow
                        array.push(searchDir, searchDirNow)
                        array.push(searchTerminalBar, simBaseBar + storedTerminalNow)
                        array.push(searchTerminalPrice, storedTerminalPxNow)
                        array.push(searchEntryBar, simBaseBar + searchEntryNow)
                        array.push(searchEntryPrice, searchEntryPxNow)
                        array.push(searchRetained, searchRetainedNow)
                        // Perfect Opportunity qualification is resolved later from consecutive retained opposite terminal extremes.
                        // At this stage only superseded attempts are known false; a retained terminal remains unresolved until the next retained opposite terminal exists.
                        if not searchRetainedNow
                            searchFalseSignalCount += 1
                        array.set(provisionalResolved, pa, true)



            previousStructuralConfirm := committedConfirm
            structuralCommitCursor += 1

    int unresolvedSearchCount = array.size(provisionalDir)
    if unresolvedSearchCount > 0
        for us = 0 to unresolvedSearchCount - 1
            if not array.get(provisionalResolved, us)
                searchOpenCount += 1
                searchLatestOpenDir := array.get(provisionalDir, us)
                searchLatestOpenBar := simBaseBar + array.get(provisionalConfirm, us)
                searchLatestOpenPrice := array.get(provisionalConfirmPrice, us)

// Full-chart Entry/Exit Finder presentation canvas.
// Retrospective uses completed history. Repainting Preview may include the temporary chart-end completion.
// All trading/search meaning remains in the Perfect, Causal, Hold, and False visuals.
color retrospectiveSearchCanvasColor = color.rgb(70, 66, 74)
bgcolor(showRetrospectiveSearchCanvas and showPerfectDecisions ? color.new(retrospectiveSearchCanvasColor, retrospectiveSearchCanvasTransparency) : na)

//==================================================================================================
// SECTION 6 — PERFECT TERMINAL ENTRY / HOLD / EXIT VISUALS
//==================================================================================================
if barstate.islast
    f_clearLabels(searchLabels)
    f_clearLines(searchLines)
    f_clearBoxes(searchBoxes)

    int completedSearches = array.size(searchDir)
    int[] retainedIdx = array.new_int()
    if completedSearches > 0
        for sr = 0 to completedSearches - 1
            if array.get(searchRetained, sr)
                array.push(retainedIdx, sr)

    int retainedCount = array.size(retainedIdx)
    int eligiblePairCount = 0
    int perfectPairCount = 0
    int retainedNonPerfectCount = 0

    // Count resolved retained terminal pairs. The newest unmatched retained terminal is not classified.
    if retainedCount > 1
        for ri = 0 to retainedCount - 2
            int a = array.get(retainedIdx, ri)
            int b = array.get(retainedIdx, ri + 1)
            int aDir = array.get(searchDir, a)
            int bDir = array.get(searchDir, b)
            float aPx = array.get(searchTerminalPrice, a)
            float bPx = array.get(searchTerminalPrice, b)
            bool oppositePair = aDir != bDir
            float pairRet = oppositePair ? f_searchReturn(aDir, aPx, bPx) : na
            if oppositePair
                eligiblePairCount += 1
                if not na(pairRet) and pairRet > 0.0
                    perfectPairCount += 1
                else
                    retainedNonPerfectCount += 1

    // Primary perfect Entry/Hold/Exit result. Points stay anchored to retained terminal extremes.
    if showPerfectDecisions and retainedCount > 1
        int firstRetainedVisual = math.max(0, retainedCount - (maxPerfectDecisionsToDraw + 1))

        // One clean hold path per qualifying terminal-to-terminal opportunity.
        for ri = firstRetainedVisual to retainedCount - 2
            int a = array.get(retainedIdx, ri)
            int b = array.get(retainedIdx, ri + 1)
            int aDir = array.get(searchDir, a)
            int bDir = array.get(searchDir, b)
            int aTerminalBar = array.get(searchTerminalBar, a)
            float aTerminalPx = array.get(searchTerminalPrice, a)
            int bTerminalBar = array.get(searchTerminalBar, b)
            float bTerminalPx = array.get(searchTerminalPrice, b)
            int aCausalBar = array.get(searchEntryBar, a)
            float aCausalPx = array.get(searchEntryPrice, a)

            bool oppositePair = aDir != bDir and bTerminalBar > aTerminalBar
            float perfectSwingRet = oppositePair ? f_searchReturn(aDir, aTerminalPx, bTerminalPx) : na
            bool perfectOpportunity = oppositePair and not na(perfectSwingRet) and perfectSwingRet > 0.0

            if perfectOpportunity
                color decisionColor = aDir > 0 ? color.green : color.red

                // Primary Perfect Hold path. The geometry remains unchanged.
                line holdLine = line.new(aTerminalBar, aTerminalPx, bTerminalBar, bTerminalPx, xloc=xloc.bar_index, extend=extend.none, color=color.new(decisionColor, 12), width=3)
                array.push(searchLines, holdLine)

                // Optional low-opacity Perfect Hold zone.
                if showPerfectDecisionBackground
                    float zonePad = math.max(math.abs(bTerminalPx - aTerminalPx) * 0.10, syminfo.mintick * 10.0)
                    float zoneTop = math.max(aTerminalPx, bTerminalPx) + zonePad
                    float zoneBottom = math.min(aTerminalPx, bTerminalPx) - zonePad
                    box decisionZone = box.new(aTerminalBar, zoneTop, bTerminalBar, zoneBottom, xloc=xloc.bar_index, border_color=color.new(decisionColor, 76), border_width=1, bgcolor=color.new(decisionColor, 92))
                    array.push(searchBoxes, decisionZone)

                int holdLabelBar = aTerminalBar + int(math.floor(float(bTerminalBar - aTerminalBar) * 0.5))
                float holdLabelPx = aTerminalPx + (bTerminalPx - aTerminalPx) * 0.5
                string holdText = "PERFECT HOLD\n" + f_fmtPct(perfectSwingRet)
                label holdLabel = label.new(holdLabelBar, holdLabelPx, holdText, xloc=xloc.bar_index, style=label.style_label_center, textcolor=color.white, color=color.new(color.rgb(32, 36, 43), 0), size=size.small)
                array.push(searchLabels, holdLabel)

                // Causal confirmation is secondary but must remain immediately readable.
                if showCausalComparison and aCausalBar >= aTerminalBar and (aCausalBar != aTerminalBar or math.abs(aCausalPx - aTerminalPx) > eps)
                    int causalDelay = aCausalBar - aTerminalBar
                    bool causalBuy = aDir > 0
                    string causalText = causalBuy ? "Causal Buy" : "Causal Sell"
                    causalText += causalDelay > 0 ? "\n+" + str.tostring(causalDelay) + " bar" + (causalDelay == 1 ? "" : "s") : "\nsame bar"
                    color causalColor = causalBuy ? color.rgb(46, 74, 112) : color.rgb(176, 82, 64)
                    label causalLabel = label.new(aCausalBar, aCausalPx, causalText, xloc=xloc.bar_index, style=causalBuy ? label.style_label_up : label.style_label_down, textcolor=color.white, color=color.new(causalColor, 12), size=size.small)
                    array.push(searchLabels, causalLabel)
                    line causalLine = line.new(aTerminalBar, aTerminalPx, aCausalBar, aCausalPx, xloc=xloc.bar_index, extend=extend.none, color=color.new(causalColor, 48), width=2, style=line.style_dashed)
                    array.push(searchLines, causalLine)

        // One terminal label per retained terminal. Shared exit/next-entry points are merged.
        for ri = firstRetainedVisual to retainedCount - 1
            int cur = array.get(retainedIdx, ri)
            int curDir = array.get(searchDir, cur)
            int curBar = array.get(searchTerminalBar, cur)
            float curPx = array.get(searchTerminalPrice, cur)

            bool prevPerfect = false
            bool nextPerfect = false

            if ri > 0
                int prev = array.get(retainedIdx, ri - 1)
                int prevDir = array.get(searchDir, prev)
                int prevBar = array.get(searchTerminalBar, prev)
                float prevPx = array.get(searchTerminalPrice, prev)
                float prevRet = prevDir != curDir and curBar > prevBar ? f_searchReturn(prevDir, prevPx, curPx) : na
                prevPerfect := not na(prevRet) and prevRet > 0.0

            if ri < retainedCount - 1
                int nxt = array.get(retainedIdx, ri + 1)
                int nextDir = array.get(searchDir, nxt)
                int nextBar = array.get(searchTerminalBar, nxt)
                float nextPx = array.get(searchTerminalPrice, nxt)
                float nextRet = curDir != nextDir and nextBar > curBar ? f_searchReturn(curDir, curPx, nextPx) : na
                nextPerfect := not na(nextRet) and nextRet > 0.0

            if prevPerfect or nextPerfect
                string curSignalText = curDir > 0 ? "Perfect Buy" : "Perfect Sell"
                string terminalText = prevPerfect and nextPerfect ? "Perfect Exit\n" + curSignalText : nextPerfect ? curSignalText : "Perfect Exit"
                color terminalColor = nextPerfect ? (curDir > 0 ? color.green : color.red) : color.rgb(64, 72, 82)
                label terminalLabel = label.new(curBar, curPx, terminalText, xloc=xloc.bar_index, style=curDir > 0 ? label.style_label_up : label.style_label_down, textcolor=color.white, color=color.new(terminalColor, math.min(searchLabelTransparency, 12)), size=size.small)
                array.push(searchLabels, terminalLabel)

    // Optional false/non-perfect context.
    // False is limited to the established completed-result definition:
    // 1) superseded Provisional attempts,
    // 2) retained terminal identities whose next opposite retained terminal is non-positive.
    if showFalseSignals
        int falseShown = 0
        int falseLimit = maxFalseSignalsToDraw

        // Superseded Provisional attempts.
        if completedSearches > 0
            int sr = completedSearches - 1
            while sr >= 0 and falseShown < falseLimit
                if not array.get(searchRetained, sr)
                    int fsDir = array.get(searchDir, sr)
                    int fsBar = array.get(searchTerminalBar, sr)
                    float fsPx = array.get(searchTerminalPrice, sr)
                    bool fsBuy = fsDir > 0
                    if falseSignalDisplay == "X Markers"
                        label fsMark = label.new(fsBar, fsPx, "", xloc=xloc.bar_index, style=label.style_xcross, textcolor=color.red, color=color.new(color.red, 0), size=size.large)
                        array.push(searchLabels, fsMark)
                    else
                        string fsText = "FALSE " + (fsBuy ? "BUY" : "SELL")
                        color fsColor = color.red
                        label fsLabel = label.new(fsBar, fsPx, fsText, xloc=xloc.bar_index, style=fsBuy ? label.style_label_up : label.style_label_down, textcolor=color.white, color=color.new(fsColor, 22), size=size.small)
                        array.push(searchLabels, fsLabel)
                    falseShown += 1
                sr -= 1

        // Retained terminal signals whose completed next-opposite-terminal result is non-positive.
        if retainedCount > 1 and falseShown < falseLimit
            int ri = retainedCount - 2
            while ri >= 0 and falseShown < falseLimit
                int a = array.get(retainedIdx, ri)
                int b = array.get(retainedIdx, ri + 1)
                int aDir = array.get(searchDir, a)
                int bDir = array.get(searchDir, b)
                int aBar = array.get(searchTerminalBar, a)
                float aPx = array.get(searchTerminalPrice, a)
                float bPx = array.get(searchTerminalPrice, b)
                float pairRet = aDir != bDir ? f_searchReturn(aDir, aPx, bPx) : na
                if aDir == bDir or na(pairRet) or pairRet <= 0.0
                    bool nfBuy = aDir > 0
                    if falseSignalDisplay == "X Markers"
                        label nfMark = label.new(aBar, aPx, "", xloc=xloc.bar_index, style=label.style_xcross, textcolor=color.red, color=color.new(color.red, 0), size=size.large)
                        array.push(searchLabels, nfMark)
                    else
                        string nfText = "FALSE " + (nfBuy ? "BUY" : "SELL") + "\nNON-POSITIVE"
                        color nfColor = color.red
                        label nfLabel = label.new(aBar, aPx, nfText, xloc=xloc.bar_index, style=nfBuy ? label.style_label_up : label.style_label_down, textcolor=color.white, color=color.new(nfColor, 18), size=size.small)
                        array.push(searchLabels, nfLabel)
                    falseShown += 1
                ri -= 1

//==================================================================================================
// SECTION 7 — ENTRY / EXIT SEARCH STATUS AND DEFINITIONS
//==================================================================================================
var table statusTable = table.new(position.top_right, 2, 15, border_width=1)

if barstate.islast
    for r = 0 to 14
        table.cell(statusTable, 0, r, "", bgcolor=color.new(color.black, 100))
        table.cell(statusTable, 1, r, "", bgcolor=color.new(color.black, 100))

    if showStatus
        // Header is muted gold while Perfect Entry/Exit review is visible. Preview execution limitations remain identified on the Timing and Guide pages.
        color defaultHeaderColor = color.rgb(42, 52, 64)
        color perfectReviewHeaderColor = color.rgb(168, 126, 46)
        color activeHeaderColor = showPerfectDecisions ? perfectReviewHeaderColor : defaultHeaderColor
        table.cell(statusTable, 0, 0, "Perfect Entry Exit Finder", text_color=color.white, bgcolor=color.new(activeHeaderColor, 0))
        table.cell(statusTable, 1, 0, statusPage, text_color=color.white, bgcolor=color.new(activeHeaderColor, 0))

        int scAll = array.size(searchDir)
        int retainedCountStatus = 0
        int[] retainedStatusIdx = array.new_int()
        if scAll > 0
            for si = 0 to scAll - 1
                if array.get(searchRetained, si)
                    array.push(retainedStatusIdx, si)
                    retainedCountStatus += 1

        int pairCountStatus = 0
        int perfectCountStatus = 0
        int retainedNonPerfectStatus = 0
        int latestPairA = na
        int latestPairB = na
        float latestPerfectReturn = na
        float latestCausalReturn = na
        float latestCapture = na
        int latestDelay = na

        if retainedCountStatus > 1
            for ri = 0 to retainedCountStatus - 2
                int a = array.get(retainedStatusIdx, ri)
                int b = array.get(retainedStatusIdx, ri + 1)
                int aDir = array.get(searchDir, a)
                int bDir = array.get(searchDir, b)
                float aTerminalPx = array.get(searchTerminalPrice, a)
                float bTerminalPx = array.get(searchTerminalPrice, b)
                bool oppositePair = aDir != bDir
                float pairRet = oppositePair ? f_searchReturn(aDir, aTerminalPx, bTerminalPx) : na
                if oppositePair
                    pairCountStatus += 1
                    if not na(pairRet) and pairRet > 0.0
                        perfectCountStatus += 1
                        latestPairA := a
                        latestPairB := b
                        latestPerfectReturn := pairRet
                        float aCausalPx = array.get(searchEntryPrice, a)
                        latestCausalReturn := f_searchReturn(aDir, aCausalPx, bTerminalPx)
                        latestCapture := pairRet > 0.0 ? math.max(0.0, math.min(100.0, nz(latestCausalReturn, 0.0) * 100.0 / pairRet)) : na
                        latestDelay := array.get(searchEntryBar, a) - array.get(searchTerminalBar, a)
                    else
                        retainedNonPerfectStatus += 1

        int falseContextStatus = searchFalseSignalCount + retainedNonPerfectStatus
        float perfectOpportunityRate = pairCountStatus > 0 ? perfectCountStatus * 100.0 / pairCountStatus : na

        int latestDir = not na(latestPairA) ? array.get(searchDir, latestPairA) : 0
        int latestTerminalBar = not na(latestPairA) ? array.get(searchTerminalBar, latestPairA) : na
        float latestTerminalPrice = not na(latestPairA) ? array.get(searchTerminalPrice, latestPairA) : na
        int latestCausalBar = not na(latestPairA) ? array.get(searchEntryBar, latestPairA) : na
        float latestCausalPrice = not na(latestPairA) ? array.get(searchEntryPrice, latestPairA) : na
        int latestExitBar = not na(latestPairB) ? array.get(searchTerminalBar, latestPairB) : na
        float latestExitPrice = not na(latestPairB) ? array.get(searchTerminalPrice, latestPairB) : na
        float confirmationLoss = not na(latestPerfectReturn) and not na(latestCausalReturn) ? latestPerfectReturn - latestCausalReturn : na

        if statusPage == "Summary"
            f_statusCell(statusTable, 1, "Retained terminals", str.tostring(retainedCountStatus))
            f_statusCell(statusTable, 2, "Terminal pairs", str.tostring(pairCountStatus))
            f_statusCell(statusTable, 3, "Perfect opportunities", str.tostring(perfectCountStatus))
            f_statusCell(statusTable, 4, "False / non-perfect", str.tostring(falseContextStatus))
            f_statusCell(statusTable, 5, "Latest entry/exit", latestDir > 0 ? "BUY → EXIT" : latestDir < 0 ? "SELL → EXIT" : "NONE")
            f_statusCell(statusTable, 6, "Perfect result", f_fmtPct(latestPerfectReturn))
            f_statusCell(statusTable, 7, "Causal result", f_fmtPct(latestCausalReturn))
            f_statusCell(statusTable, 8, "Opportunity capture", f_fmtPct(latestCapture))
            f_statusCell(statusTable, 9, "Confirmation loss", f_fmtPct(confirmationLoss))
            f_statusCell(statusTable, 10, "Perfect opportunity rate", f_fmtPct(perfectOpportunityRate))
            f_statusCell(statusTable, 11, "Entry / exit display", showPerfectDecisions ? "VISIBLE • GOLD" : "HIDDEN • NEUTRAL")
            f_statusCell(statusTable, 12, "False context", showFalseSignals ? "VISIBLE" : "HIDDEN")
            f_statusCell(statusTable, 13, "Finder mode", finderMode == "Repainting Preview" ? "PREVIEW • CURRENT RESULTS" : "RETROSPECTIVE • FINALIZED")
            f_statusCell(statusTable, 14, "Preview resolutions", finderMode == "Repainting Preview" ? str.tostring(searchPreviewTemporaryStructuralCount) : "n/a")
        else if statusPage == "Perfect Entry Exit Search"
            f_statusCell(statusTable, 1, "Perfect entry", latestDir > 0 ? "BUY TERMINAL" : latestDir < 0 ? "SELL TERMINAL" : "NONE")
            f_statusCell(statusTable, 2, "Entry terminal bar", na(latestTerminalBar) ? "n/a" : str.tostring(latestTerminalBar))
            f_statusCell(statusTable, 3, "Entry price", na(latestTerminalPrice) ? "n/a" : str.tostring(latestTerminalPrice, format.mintick))
            f_statusCell(statusTable, 4, "Perfect exit bar", na(latestExitBar) ? "n/a" : str.tostring(latestExitBar))
            f_statusCell(statusTable, 5, "Exit price", na(latestExitPrice) ? "n/a" : str.tostring(latestExitPrice, format.mintick))
            f_statusCell(statusTable, 6, "Perfect swing result", f_fmtPct(latestPerfectReturn))
            f_statusCell(statusTable, 7, "Causal confirm bar", na(latestCausalBar) ? "n/a" : str.tostring(latestCausalBar))
            f_statusCell(statusTable, 8, "Causal confirm price", na(latestCausalPrice) ? "n/a" : str.tostring(latestCausalPrice, format.mintick))
            f_statusCell(statusTable, 9, "Causal result", f_fmtPct(latestCausalReturn))
            f_statusCell(statusTable, 10, "Opportunity capture", f_fmtPct(latestCapture))
            f_statusCell(statusTable, 11, "Confirmation loss", f_fmtPct(confirmationLoss))
            f_statusCell(statusTable, 12, "Perfect path", "TERMINAL → OPPOSITE")
            f_statusCell(statusTable, 13, "Result basis", finderMode == "Repainting Preview" ? "ENDPOINT HINDSIGHT PREVIEW" : "RETROSPECTIVE")
            f_statusCell(statusTable, 14, "Operational use", finderMode == "Repainting Preview" ? "NO • PREVIEW ONLY" : "NO • REVIEW ONLY")
        else if statusPage == "Timing"
            f_statusCell(statusTable, 1, "Entry terminal bar", na(latestTerminalBar) ? "n/a" : str.tostring(latestTerminalBar))
            f_statusCell(statusTable, 2, "Causal confirm bar", na(latestCausalBar) ? "n/a" : str.tostring(latestCausalBar))
            f_statusCell(statusTable, 3, "Entry → confirm delay", na(latestDelay) ? "n/a" : str.tostring(latestDelay) + " bars")
            f_statusCell(statusTable, 4, "Exit terminal bar", na(latestExitBar) ? "n/a" : str.tostring(latestExitBar))
            f_statusCell(statusTable, 5, "Swing duration", na(latestTerminalBar) or na(latestExitBar) ? "n/a" : str.tostring(latestExitBar - latestTerminalBar) + " bars")
            f_statusCell(statusTable, 6, "Perfect swing result", f_fmtPct(latestPerfectReturn))
            f_statusCell(statusTable, 7, "Causal available result", f_fmtPct(latestCausalReturn))
            f_statusCell(statusTable, 8, "Opportunity capture", f_fmtPct(latestCapture))
            f_statusCell(statusTable, 9, "Confirmation loss", f_fmtPct(confirmationLoss))
            f_statusCell(statusTable, 10, "Structural resolver", structuralMode)
            f_statusCell(statusTable, 11, "Terminal identity", "RETAINED")
            f_statusCell(statusTable, 12, "Exit identity", "NEXT RETAINED OPPOSITE")
            f_statusCell(statusTable, 13, "Newest terminal", finderMode == "Repainting Preview" ? (searchPreviewTemporaryStructuralCount > 0 ? "PREVIEW-RESOLVED" : "NO PREVIEW RESULT") : (retainedCountStatus > 0 ? "WAITING FOR OPPOSITE" : "NONE"))
            f_statusCell(statusTable, 14, "Preview repainting", finderMode == "Repainting Preview" ? "ALLOWED • FUTURE UPDATES" : "OFF")
        else
            f_statusCell(statusTable, 1, "Perfect entry", "RETAINED TERMINAL EXTREME")
            f_statusCell(statusTable, 2, "Perfect exit", "NEXT OPPOSITE TERMINAL")
            f_statusCell(statusTable, 3, "Perfect hold", "TERMINAL → TERMINAL")
            f_statusCell(statusTable, 4, "Perfect opportunity", "POSITIVE TERMINAL PAIR")
            f_statusCell(statusTable, 5, "False context", "SUPERSEDED OR NON-POSITIVE PAIR")
            f_statusCell(statusTable, 6, "Causal comparison", "PROVISIONAL CONFIRM CLOSE")
            f_statusCell(statusTable, 7, "Retrospective timing", "BOTH TERMINALS RESOLVED")
            f_statusCell(statusTable, 8, "Opportunity capture", "CAUSAL / PERFECT")
            f_statusCell(statusTable, 9, "Perfect opportunity rate", "NOT A WIN RATE")
            f_statusCell(statusTable, 10, "Repainting Preview", "TEMPORARY ENDPOINT RESULT")
            f_statusCell(statusTable, 11, "Preview operation", "NONE • REVIEW ONLY")
            f_statusCell(statusTable, 12, "Preview repainting", "EXPECTED / ALLOWED")
            f_statusCell(statusTable, 13, "Result scope", "HINDSIGHT / PREVIEW • NOT PROFIT")
            f_statusCell(statusTable, 14, "Use", "REVIEW / TESTING ONLY")
````
