# Perfect Trading Entry Exit Finder

- url: https://www.tradingview.com/script/hdWFM8Hs-Perfect-Trading-Entry-Exit-Finder/
- type: indicator
- pine_id: PUB;6e7d708659fa4815a9bfc0b1d2355dcd
- version: 2.0

## Description

A trading entry/exit finder that searches retained structural swings for positive terminal-to-terminal opportunities, anchors each qualifying entry and exit to the actual retained terminal extremes, and preserves the corresponding causal confirmation for direct timing and opportunity comparison. Results are search and review outputs, not a guarantee of profitability or future performance.

[b]Name:[/b]
Perfect Trading Entry Exit Finder

[b]Searchable Name:[/b]
Perfect Trading Entry Exit Finder

[b]Technical Name:[/b]
Retained Terminal-to-Terminal Perfect Entry Exit and Causal Confirmation Finder

[b]Short title:[/b]
Perfect Entry Exit

[b]Summary[/b]
Perfect Trading Entry Exit Finder is an experimental finder for locating complete retained terminal-to-terminal opportunities while preserving the corresponding causal signal timing for comparison.

[b]The retrospective Perfect terminals are the completed ideal entry and exit endpoints defined by the Perfect search, but those exact terminal entries or exits are only causally executable at those same bars when the corresponding causal confirmation actually becomes available there.[/b]

A BUY can confirm after the retained trough has already occurred.

A SELL can confirm after the retained peak has already occurred.

Multiple signal attempts can develop before a completed structural swing establishes the retained signal identity.

A signal can appear very close to the terminal or only after part of the move has already occurred.

An earlier signal can be superseded before the structural swing finishes.

A retained signal can also survive structurally while the move to the next opposite retained terminal still produces a non-positive result.

A strong terminal-to-terminal move can begin before the corresponding causal confirmation becomes available.

Perfect Trading Entry Exit Finder attempts to expose this difference directly.

Within this script, [b]Perfect has a specific meaning.[/b]

A [b]Perfect Opportunity[/b] is a completed retained opposite-terminal relationship whose directional terminal-to-terminal result is positive.

The first retained terminal becomes the:

[list]
[*]PERFECT BUY
[*]or PERFECT SELL
[/list]

The next retained opposite terminal becomes the corresponding:

[list]
[*]PERFECT EXIT
[/list]

The interval between those retained terminals becomes:

[list]
[*]PERFECT HOLD
[/list]

The Perfect Entry, Hold, and Exit remain attached to the retained terminal structure.

The corresponding causal confirmation remains separately preserved.

That allows the finder to expose both:

[b]the complete retained terminal-to-terminal opportunity[/b]

and

[b]the portion represented from the actual causal confirmation[/b]

without redefining one as the other.

The finder can therefore expose:

[list]
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
[/list]

The primary search is based on completed retained structural relationships.

An additional preview mode can expose the currently implied unfinished result at the chart edge.

Because that newest structural state is incomplete, preview-only output can change as additional bars arrive.

[b]How it works[/b]

Perfect Trading Entry Exit Finder combines a causal signal foundation with a completed terminal-to-terminal search.

The causal signal foundation preserves what could actually become available through the forward signal process.

The Perfect search evaluates the completed retained structural opportunity.

[b]Those two reference systems remain separate.[/b]

[b]That separation is deliberately engineered into the finder: the completed terminal result can be reviewed alongside the causal confirmation without allowing the later result to replace what was actually available through the causal process.[/b]

The completed terminal opportunity shows the full retained swing after structural finalization.

The causal confirmation shows where the corresponding signal became available through the causal process.

The finder brings those references together for direct review without treating one as the other.

[b]Terminal opportunity and causal confirmation[/b]

A completed terminal opportunity and the signal timing actually available through causal confirmation can differ substantially.

Once a swing has reached structural finalization, its retained terminal can be identified precisely within the completed structure.

At that terminal itself, however, the signal that ultimately corresponds to the completed opportunity may not yet have confirmed.

Price can move before confirmation becomes available.

An earlier signal can fail or be superseded.

The opposite terminal can later reveal that a retained signal did not produce a positive completed opportunity.

The finder keeps these relationships visible.

[b]The Perfect terminal remains the Perfect terminal.[/b]

[b]The causal confirmation remains the causal confirmation.[/b]

This allows direct comparison between:

[b]where the complete retained opportunity began[/b]

and

[b]where the corresponding causal signal became available[/b]

without moving either reference point to make them appear equivalent.

[b]Perfect search structure[/b]

The Perfect search evaluates structurally finalized retained opposite-terminal relationships.

For a BUY-side opportunity, the completed structure runs from a retained trough toward a retained opposite peak.

For a SELL-side opportunity, the completed structure runs from a retained peak toward a retained opposite trough.

The finder evaluates the complete retained swing rather than an isolated signal bar.

The first retained terminal supplies the Perfect Entry reference.

The later opposite retained terminal supplies the Perfect Exit reference.

A positive directional result qualifies the completed relationship as a Perfect Opportunity.

[b]The terminal relationship defines the Perfect search.[/b]

[b]Causal signal foundation[/b]

The Perfect results remain connected to an underlying causal signal process.

This matters because identifying the finalized Perfect terminal retrospectively does not make that exact terminal entry or exit causally executable when the terminal bar originally occurred.

The associated causal confirmation remains separately preserved.

That provides the causal comparison reference for the completed Perfect opportunity.

[b]Structural resolution[/b]

Structural resolution determines when a retained swing reaches structural finalization and becomes available to the completed Perfect search.

The script provides selectable structural approaches for reviewing this relationship.

These approaches can produce differences in finalization timing and retained structural presentation.

They do not change the central definition of a Perfect Opportunity:

[b]a structurally finalized retained entry terminal followed by its retained opposite terminal with a positive directional result.[/b]

[b]Earliest Terminal[/b]

Earliest Terminal provides an alternative structural view emphasizing earlier retained terminal context.

[b]Original Grouping[/b]

Original Grouping provides the script's primary grouped structural view.

[b]Conditional Accelerated[/b]

Conditional Accelerated provides an alternative earlier-finalization structural view when its conditions are satisfied.

These modes affect structural finalization and retained terminal identity while preserving the same Perfect Opportunity definition.

[b]Retained signal identity[/b]

More than one causal signal attempt can occur during a structural swing.

The completed finder result does not treat all of those attempts as equivalent.

A retained signal identity provides the connection between the causal signal process and the structurally finalized terminal result.

Other signal attempts can remain visible as superseded or false/non-perfect context.

[b]Retained terminal association[/b]

The finder preserves two conceptually different references:

[b]Terminal reference[/b]

the retained structural extreme belonging to the structurally finalized opportunity.

[b]Causal reference[/b]

the corresponding signal confirmation that was actually available through the causal signal process.

These references describe different parts of the same completed opportunity.

Neither replaces the other.

[b]Retained terminal chain[/b]

Structurally finalized retained terminals provide the sequence used by the Perfect search.

A newest retained terminal by itself does not yet provide a complete terminal-to-terminal opportunity.

A later opposite endpoint is needed before the completed pair can be evaluated.

This prevents the normal retrospective search from treating unfinished structure as though its later endpoint were already known.

[b]Eligible terminal pair[/b]

A structurally finalized retained opposite-terminal relationship provides the potential Perfect Entry and Perfect Exit.

The directional terminal-to-terminal result determines whether that completed relationship qualifies as a Perfect Opportunity.

The Perfect endpoints remain the retained structural terminals.

The search does not redefine them using the causal confirmation or an arbitrary interior price.

[b]Perfect Opportunity[/b]

A [b]Perfect Opportunity[/b] is a qualifying structurally finalized retained opposite-terminal relationship with a positive directional terminal-to-terminal result.

For a BUY-side opportunity, the retained trough is followed by a higher retained opposite terminal.

For a SELL-side opportunity, the retained peak is followed by a lower retained opposite terminal.

A zero or negative completed directional result does not qualify as Perfect.

[b]Perfect is therefore a search definition applied to structurally finalized retained structure.[/b]

It is separate from whether the causal confirmation captured all, some, or little of that move.

[b]Perfect Entry[/b]

The Perfect Entry is the first retained terminal of a qualifying completed opportunity.

For a BUY-side opportunity, this becomes the [b]Perfect Buy[/b].

For a SELL-side opportunity, this becomes the [b]Perfect Sell[/b].

The marker remains anchored to the retained terminal used by the completed search.

It is not moved forward to the causal confirmation.

[b]Perfect Exit[/b]

The Perfect Exit is the retained opposite terminal that completes the qualifying opportunity.

The finalized structural endpoint defines the exit.

The finder does not replace it with an arbitrary interior price simply because that price would have produced a larger temporary result.

This preserves a consistent terminal-to-terminal definition.

[b]Perfect Hold[/b]

[b]PERFECT HOLD[/b] spans the complete qualifying retained opportunity.

For a Perfect BUY, it represents the retained trough-to-opposite-peak movement.

For a Perfect SELL, it represents the retained peak-to-opposite-trough movement.

The displayed hold therefore represents the complete Perfect opportunity between the two retained endpoints.

[b]Shared Perfect Exit and next Perfect Entry[/b]

One retained terminal can conceptually complete one opportunity and begin another.

For example, a retained peak can complete a BUY-side Perfect opportunity and also become the starting terminal of a later SELL-side opportunity.

Likewise, a retained trough can complete a SELL-side opportunity and begin a later BUY-side opportunity.

The chart can present these shared terminal relationships without changing the underlying Perfect definitions.

[b]Causal confirmation comparison[/b]

The finder can display the causal confirmation associated with a Perfect terminal opportunity.

The causal reference shows where the corresponding surviving signal became available.

The Perfect reference remains at the structurally finalized retained terminal.

This produces a direct comparison between:

[b]Perfect terminal opportunity[/b]

and

[b]causal signal availability[/b]

without treating the Perfect terminal as though it were known causally at that point.

[b]Terminal-to-confirmation delay[/b]

The finder measures the timing difference between the retained Perfect Entry terminal and its corresponding causal confirmation.

A same-bar relationship has no bar delay.

A later confirmation represents a later causal availability point.

The purpose of this measurement is to expose the timing gap between the completed Perfect benchmark and the signal timing actually represented by the causal process.

[b]Perfect result[/b]

Perfect Result is the directional percentage result between the retained Perfect Entry and retained Perfect Exit of a qualifying opportunity.

It represents the full completed terminal-to-terminal opportunity identified by the finder.

[b]Causal result[/b]

Causal Result uses the corresponding causal confirmation as the entry reference while preserving the same completed exit context.

This allows the causal result and Perfect result to be compared within the same completed opportunity.

[b]The two measurements answer different questions and are not interchangeable.[/b]

[b]Opportunity Capture[/b]

[b]Opportunity Capture[/b] describes how much of the completed Perfect opportunity is represented by the corresponding causal result.

It provides a normalized comparison between:

[b]the complete retained opportunity[/b]

and

[b]the result represented from causal confirmation.[/b]

Its purpose is interpretation, not to redefine either reference.

[b]Confirmation Loss[/b]

[b]Confirmation Loss[/b] describes the difference between the Perfect Result and corresponding Causal Result.

It shows how much of the completed terminal-to-terminal movement was not represented from the causal confirmation reference.

Perfect Result, Causal Result, Opportunity Capture, and Confirmation Loss therefore provide different views of the same completed opportunity.

[b]False / non-perfect context[/b]

The finder can expose causal signal activity that did not become part of a qualifying Perfect Opportunity.

This can include:

1. signal attempts that were later superseded
2. structurally finalized retained relationships whose directional result was not positive

These categories help distinguish the wider causal signal stream from the subset of completed relationships classified as Perfect.

[b]Superseded attempts[/b]

Several causal signal attempts can occur while the underlying structure is still developing.

Not every attempt becomes the retained identity associated with the structurally finalized opportunity.

Non-retained attempts can remain visible as superseded context.

This allows users to see that the eventual Perfect terminal association does not imply every earlier causal signal was correct.

[b]Retained non-positive pairs[/b]

Structural retention alone does not automatically create a Perfect Opportunity.

A structurally finalized retained relationship must still satisfy the Perfect Opportunity definition.

If the completed directional terminal-to-terminal result is zero or negative, it does not qualify as a Perfect Opportunity and remains non-perfect context.

[b]Unmatched newest retained terminal[/b]

The newest retained terminal remains incomplete until a later opposite terminal provides the second endpoint needed for structural finalization of the terminal-to-terminal relationship.

The normal retrospective search therefore does not prematurely classify that newest terminal as Perfect or non-perfect.

The optional preview can temporarily expose what the unfinished structure currently implies.

That preview remains separate from structurally finalized retained history.

[b]Finder modes[/b]

The script contains two search modes:

[list]
[*]Retrospective
[*]Repainting Preview
[/list]

They use the same conceptual Perfect Entry/Exit definition.

Their difference is whether the newest unfinished chart-edge structure is temporarily included.

[b]Retrospective[/b]

Retrospective uses structurally finalized retained relationships.

Its Perfect results are based on swings whose terminal relationship has already reached structural finalization.

This is the primary review mode.

[b]Repainting Preview[/b]

Repainting Preview temporarily extends the same search concept to the unfinished chart-right structure.

It shows what the newest result currently looks like before structural finalization has occurred.

Because the latest structural state is unfinished, preview-only output can change as future bars arrive.

[b]The preview therefore repaints by design.[/b]

It should not be interpreted as a permanent causal Perfect signal.

[b]Permanent completed history and preview state[/b]

The finder keeps structurally finalized retained history separate from temporary preview completion.

Finalized retrospective results belong to the completed search.

Preview-only results belong to the unfinished chart-edge state.

This allows the finder to expose both:

[b]structurally finalized Perfect Entry/Exit structure[/b]

and

[b]the currently implied unfinished structure[/b]

without treating them as equivalent.

[b]Perfect Entry / Exit display[/b]

The primary display can show:

[list]
[*]Perfect Buy
[*]Perfect Sell
[*]Perfect Exit
[*]Perfect Hold
[*]terminal-to-terminal result
[*]causal confirmation comparison
[*]and supporting opportunity context
[/list]

These visuals represent the underlying search result.

Display settings do not redefine what qualifies as a finalized Perfect Opportunity.

[b]False-context display[/b]

False/non-perfect context can be displayed separately from Perfect results.

This allows the chart to show the broader causal signal activity around finalized opportunities without changing which retained terminal relationships qualify as Perfect.

[b]Structural context[/b]

The finder retains structural context around the signals and finalized opportunities being reviewed.

This context can help distinguish finalized, unresolved, retained, or superseded relationships.

The Perfect Opportunity itself remains defined by the structurally finalized retained terminal relationship and its directional result.

[b]Search reconstruction[/b]

The finder reconstructs the historical search context needed to display causal signal relationships, structurally finalized opportunities, and the current unfinished state.

The purpose is to preserve the distinction between causal signal timing and finalized terminal identity across loaded chart history.

[b]Perfect Opportunity Rate[/b]

The finder calculates a [b]Perfect Opportunity Rate[/b] describing how often eligible finalized retained terminal relationships satisfy the Perfect Opportunity definition.

[b]Perfect Opportunity Rate is not a trading win rate.[/b]

It describes the completed search classification.

It does not establish the result of an executed strategy using causal entries, transaction costs, slippage, sizing, or external risk rules.

[b]Search statistics[/b]

The finder provides summary statistics describing the finalized Perfect search, causal comparison, false/non-perfect context, and current search state.

These statistics are designed to help interpret the search result.

[b]Status pages[/b]

The script includes a compact status interface for reviewing the current Perfect search, causal comparison, timing, and interpretation context.

The status display supports chart review without requiring every measurement to be placed directly on the chart.

[image]https://www.tradingview.com/x/E27CI49K/[/image]

[b]Alerts and execution[/b]

Perfect Trading Entry Exit Finder is not an execution engine.

Retrospective Perfect terminal results identify the completed ideal entry and exit endpoints. [b]Those exact terminal entries or exits are only causally executable at those same bars when the corresponding causal confirmation actually becomes available there.[/b]

The Perfect structure and causal confirmation are retained for search, review, and comparison.

[b]When causal confirmation occurs later, the executable causal entry or exit occurs later; the retrospective Perfect terminal remains the completed ideal endpoint rather than an entry or exit that was available at that earlier terminal bar.[/b]

The optional preview also remains a search preview rather than an execution-ready Perfect signal source.

[b]Finder behavior[/b]

Perfect Trading Entry Exit Finder combines causal signal identity with finalized terminal-to-terminal opportunity searching.

Its broad workflow is:

[list]
[*]causal signal activity develops
[*]retained structural relationships reach finalization
[*]a completed terminal-to-terminal relationship becomes available for review
[*]positive finalized relationships can qualify as Perfect Opportunities
[*]Perfect Entry, Hold, and Exit remain attached to the retained terminal structure
[*]and the corresponding causal confirmation remains separately available for comparison
[/list]

The optional preview can temporarily extend the same search concept to the unfinished newest structure.

[b]Features[/b]

[list]
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
[/list]

[b]Strengths[/b]

[b]Perfect Entry/Exit Search[/b] — directly finds qualifying finalized terminal-to-terminal opportunities rather than stopping at the original causal signal.

[b]Terminal-to-Terminal Structure[/b] — Perfect Entry and Perfect Exit remain tied to retained structural endpoints.

[b]Complete Swing Representation[/b] — Perfect Hold represents the full retained opportunity between those endpoints.

[b]Causal Identity Preservation[/b] — keeps the corresponding causal confirmation connected to the finalized opportunity for comparison.

[b]Direct Perfect-versus-Causal Comparison[/b] — shows both the complete retained opportunity and the result represented from causal confirmation.

[b]Opportunity Capture Measurement[/b] — quantifies how much of the completed Perfect opportunity is represented by the causal result.

[b]Confirmation Loss Measurement[/b] — measures the difference between Perfect and causal results.

[b]No Arbitrary Exit Substitution[/b] — does not replace the retained opposite terminal with an arbitrary interior best price.

[b]False-Context Separation[/b] — keeps superseded and non-positive finalized relationships distinct from qualifying Perfect Opportunities.

[b]Unfinished-Terminal Discipline[/b] — normal retrospective results are not finalized until the necessary opposite structural endpoint exists.

[b]Structural Choice[/b] — selectable structural views can be compared while preserving the same central Perfect concept.

[b]Finalized-History Separation[/b] — finalized search results remain distinct from temporary chart-edge preview output.

[b]Preview Capability[/b] — the currently implied unfinished Perfect structure can be inspected while remaining explicitly identified as repainting.

[b]Search Diagnostics[/b] — timing, capture, confirmation loss, false context, and opportunity context remain measurable.

[b]Weaknesses[/b]

[b]Opposite-Terminal Requirement[/b] — the complete Perfect Entry/Exit opportunity is not known until the later retained opposite endpoint structurally finalizes the relationship.

[b]Terminal Hindsight[/b] — the finalized retained terminal and causal confirmation are different reference systems and can occur at different times and prices.

[b]Confirmation Delay[/b] — part of the complete terminal-to-terminal movement can occur before causal confirmation becomes available.

[b]Superseded Signals[/b] — multiple causal attempts can occur before structural finalization establishes the retained relationship.

[b]Non-Positive Retained Relationships[/b] — structural retention alone does not guarantee a positive Perfect Opportunity.

[b]Perfect Definition Scope[/b] — Perfect refers specifically to the positive finalized terminal-to-terminal search definition.

[b]No Interior Exit Optimization[/b] — the retained opposite terminal remains the Perfect Exit even if another temporary price would have produced a larger result.

[b]Structural Dependence[/b] — different structural views can affect finalization timing and retained terminal presentation.

[b]Causal-Signal Dependence[/b] — the comparison remains connected to an underlying causal signal process.

[b]Preview Repainting[/b] — unfinished preview output can move, disappear, or change before structural finalization.

[b]Perfect-Terminal Executability Is Conditional[/b] — a finalized Perfect terminal is the completed ideal entry or exit endpoint, but it is executable at that exact terminal bar only when the corresponding causal confirmation actually becomes available there.

[b]Perfect Opportunity Rate Is Not Win Rate[/b] — it measures search classification rather than executed strategy performance.

[b]No Execution Engine[/b] — the standalone finder does not turn Perfect search output into automated trading decisions.

[b]No Full Strategy Return Calculation[/b] — it does not establish complete returns after sizing, transaction costs, slippage, and external trading rules.

[b]Who it’s for[/b]

This tool is best suited for:

[list]
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
[/list]

[b]Who it’s not for[/b]

This tool is not best suited for:

[list]
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
[/list]

[b]Known limitations[/b]

The finder is better at:

[list]
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
[/list]

than it is at:

[list]
[*]identifying the final retained terminal causally before structural finalization
[*]eliminating delayed confirmation
[*]eliminating false or superseded signals
[*]guaranteeing that every retained relationship produces a positive result
[*]turning Perfect terminal markers into operational entries
[*]determining whether the newest unfinished preview terminal will remain final
[*]or determining a complete future trading result
[/list]

A Perfect Opportunity is defined by the structurally finalized retained terminal relationship.

The causal confirmation can represent all, some, or very little of the complete terminal-to-terminal movement.

That difference is part of what the finder exposes.

A large Perfect Result can therefore coexist with a much smaller Causal Result.

Opportunity Capture and Confirmation Loss describe that difference.

Likewise, a retained signal can remain structurally relevant while its finalized opposite-terminal result still fails the Perfect qualification.

[b]The term Perfect therefore belongs to the finalized search definition.[/b]

It does not imply that the finalized terminal was causally available as a Perfect signal when it originally occurred.

The optional Repainting Preview introduces an additional limitation.

It evaluates unfinished chart-right structure before structural finalization.

Future bars can therefore change preview-only output.

Finalized retrospective results remain separate from that temporary preview.

[b]Perfect result scope[/b]

The Perfect result represents the complete retained terminal-to-terminal directional opportunity of a qualifying structurally finalized relationship.

It can include:

[list]
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
[/list]

These measurements preserve the complete opportunity and causal signal result as separate but directly comparable references.

[b]Final note[/b]

Perfect Trading Entry Exit Finder is an experimental finder for the entry-and-exit problem that remains when the complete terminal opportunity and the causal signal available during that opportunity are not the same thing.

Its central capability is the retained terminal-to-terminal search.

Positive structurally finalized terminal relationships can become Perfect Opportunities.

The corresponding:

[list]
[*]Perfect Entry
[*]Perfect Hold
[*]and Perfect Exit
[/list]

remain attached to the retained terminal structure.

The causal confirmation remains separately preserved.

This allows the finder to expose both:

[b]the complete retained entry-to-exit opportunity[/b]

and

[b]the result represented from the corresponding causal confirmation[/b]

inside the same finalized swing.

False, superseded, or non-perfect signal context remains separately visible.

The optional preview can extend the same search concept to unfinished chart-edge structure, with its repainting behavior kept separate from structurally finalized results.

Perfect Trading Entry Exit Finder therefore remains centered on the problem it attempts to address:

[b]locating the complete retained terminal entry, hold, and opposite-terminal exit opportunity while preserving the causal signal that was actually available for comparison.[/b]

[b]Profitability is not guaranteed.[/b]

[b]Future performance is not guaranteed.[/b]

The finder reports the Perfect opportunity, its terminal structure, corresponding causal result, timing difference, capture, confirmation loss, and false/non-perfect context. [b]The retrospective Perfect terminals are the completed ideal entry and exit endpoints, but those exact terminal entries or exits were only causally executable at the time when the corresponding causal confirmation actually occurred at those same terminal bars; otherwise the executable causal timing occurred elsewhere.[/b]

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
// Grouped Extremes structural resolution and causal Provisional confirmation establish surviving signal identity, terminal-to-terminal perfect opportunities, causal timing comparison, and false-signal context.
// This standalone does not select live confirmation stages, simulate positions, route orders, or produce execution-ready trade-management decisions.
// Results measure historical/preview opportunity and terminal identity. They are not a profitability result, actual win rate, future result, or financial advice.
//@version=6
indicator("Perfect Trading Entry Exit Finder", shorttitle="Perfect Entry Exit", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=50, max_bars_back=5000)

//==================================================================================================
// SECTION 1 — PERFECT ENTRY/EXIT SEARCH, STRUCTURAL RESOLUTION, AND DISPLAY INPUTS
//==================================================================================================
src = input.source(close, "Source")
atrLen = input.int(14, "ATR Length", minval=1)
transformAtrScale = input.float(5.0, "Transform ATR Scale", minval=0.1, step=0.1, tooltip="Controls how strongly the causal comparison transform follows raw price. Lower values follow price more closely; higher values transform more smoothly.")
transformDirectionThresholdAtr = input.float(0.001, "Transform Direction Threshold (ATR)", minval=0.0, step=0.001, tooltip="Minimum transformed bar-to-bar movement, measured in ATR units, required to count as a directional step. The transform itself continues to move even when the step is treated as flat.")
string structuralMode = "Grouped Extremes"
structuralLength = input.int(10, "Structural Length", minval=1, tooltip="Structural context used by Grouped Extremes.")
maxCandidateEntryDelayBars = input.int(1, "Maximum Provisional Confirmation Delay Bars", minval=0, maxval=1, tooltip="A retained transform candidate can confirm on its candidate bar or the following bar. The actual confirmation close becomes the causal search entry.")
keepActiveFilteredCandidate = input.bool(true, "Keep Delayed Transform Candidate Memory", tooltip="When enabled, a valid candidate blocked only by causal transform timing can remain pending and become a Provisional search start on the first later closed bar where its retained terminal agrees with the active causal reference pivot.")

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

// The causal adaptive transform path is the Provisional search-start reference.
bool useReferencePathAgreementEntryFilter = true
bool useReferencePathAgreementForShortEntry = true

//==================================================================================================
// SECTION 2 — SEARCH AND CAUSAL ENTRY HELPERS
//==================================================================================================
eps = math.max(syminfo.mintick, 1e-6)
atrV = ta.atr(atrLen)

f_sign(x)=>x > 0.0 ? 1 : x < 0.0 ? -1 : 0

f_updateCumMove(float _cum,int _dirStore,int _stepSign,float _step)=>
    _stepSign == 0 ? _cum : (_dirStore == 0 or _stepSign == _dirStore ? _cum + _step : _step)

f_candBar(int _bar,bool _filtered)=>_filtered ? -(_bar + 1) : (_bar + 1)
f_candIdx(int _bar)=>na(_bar) ? na : math.abs(_bar) - 1

f_refEntryGate(bool _buy,bool _cand,int _dir,bool _flat)=>
    bool _side = _dir == (_buy ? 1 : -1) and not _flat
    _cand and _side

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



//==================================================================================================
// SECTION 3 — CAUSAL ADAPTIVE TRANSFORM PATH
//==================================================================================================
f_buildCausalTransformPathArrays(float[] _rawPx,float[] _rawAtr,int _nBars)=>
    int[] _pivIdx = array.new_int()
    float[] _pivPx = array.new_float()
    float[] _pathClose = array.new_float(_nBars, na)
    float _cumTmp = 0.0
    int _prevStepDir = 0
    float _lastClose = na
    float _lastOpen = na
    int _lastDir = 0

    if _nBars <= 0 or array.size(_rawPx) == 0
        [_pivIdx, _pivPx, _pathClose, _cumTmp, _lastClose, _lastOpen, _lastDir]
    else
        float _transform = array.get(_rawPx, 0)
        array.set(_pathClose, 0, _transform)
        array.push(_pivIdx, 0)
        array.push(_pivPx, _transform)

        int _swingDir = 0
        int _swingExtremeIdx = 0
        float _swingExtremePx = _transform

        if _nBars > 1
            for _i = 1 to _nBars - 1
                float _raw = array.get(_rawPx, _i)
                float _atr = _i < array.size(_rawAtr) ? math.abs(nz(array.get(_rawAtr, _i), 0.0)) : 0.0
                float _prevTransform = _transform
                float _pull = _raw - _prevTransform
                float _absPull = math.abs(_pull)
                float _moveScale = math.max(_atr * transformAtrScale, eps)
                float _alpha = _absPull / math.max(_absPull + _moveScale, eps)
                float _step = _pull * _alpha
                _transform := _prevTransform + _step
                array.set(_pathClose, _i, _transform)

                float _dirThreshold = math.max(_atr * transformDirectionThresholdAtr, eps)
                int _stepDir = math.abs(_step) >= _dirThreshold ? f_sign(_step) : 0

                if _stepDir != 0
                    if _swingDir == 0
                        _swingDir := _stepDir
                        _swingExtremeIdx := _i
                        _swingExtremePx := _transform
                    else if _stepDir == _swingDir
                        bool _moreExtreme = _swingDir > 0 ? _transform >= _swingExtremePx : _transform <= _swingExtremePx
                        if _moreExtreme
                            _swingExtremeIdx := _i
                            _swingExtremePx := _transform
                    else
                        if array.get(_pivIdx, array.size(_pivIdx) - 1) != _swingExtremeIdx
                            array.push(_pivIdx, _swingExtremeIdx)
                            array.push(_pivPx, _swingExtremePx)
                        _swingDir := _stepDir
                        _swingExtremeIdx := _i
                        _swingExtremePx := _transform

                    _cumTmp := f_updateCumMove(_cumTmp, _prevStepDir, _stepDir, _step)
                    _prevStepDir := _stepDir

        int _endIdx = _nBars - 1
        if array.get(_pivIdx, array.size(_pivIdx) - 1) != _endIdx
            array.push(_pivIdx, _endIdx)
            array.push(_pivPx, array.get(_pathClose, _endIdx))

        _lastClose := array.get(_pathClose, _endIdx)
        _lastOpen := _nBars > 1 ? array.get(_pathClose, _endIdx - 1) : _lastClose
        if _nBars > 1
            float _lastAtr = math.abs(nz(array.get(_rawAtr, _endIdx), 0.0))
            float _lastThreshold = math.max(_lastAtr * transformDirectionThresholdAtr, eps)
            float _lastStep = _lastClose - _lastOpen
            _lastDir := math.abs(_lastStep) >= _lastThreshold ? f_sign(_lastStep) : 0
        [_pivIdx, _pivPx, _pathClose, _cumTmp, _lastClose, _lastOpen, _lastDir]

// CAUSAL PREFIX-STABLE STRUCTURAL RESOLUTION
//==================================================================================================
// Grouped Extremes retains the most extreme same-side structural candidate and commits it when an opposite structural candidate arrives.
// Confirmed structural identities are committed once and are never rebuilt from chart-end state.
var int[] csEventDir = array.new_int()
var int[] csEventTerminalBar = array.new_int()
var float[] csEventTerminalPrice = array.new_float()
var int[] csEventConfirmBar = array.new_int()

var int csLastCommittedDir = 0
var int csGroupDir = 0
var float csGroupExtremePrice = na
var int csGroupExtremeBar = na

f_csEventExists(int _dir, int _terminalBar) =>
    bool _found = false
    if array.size(csEventDir) > 0
        for _e = 0 to array.size(csEventDir) - 1
            if array.get(csEventDir, _e) == _dir and array.get(csEventTerminalBar, _e) == _terminalBar
                _found := true
                break
    _found

bool csBarReady = barstate.isconfirmed
if csBarReady
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
            csGroupDir := _candidateDir
            csGroupExtremePrice := _candidatePrice
            csGroupExtremeBar := bar_index

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
    float[] rawAtr = array.new_float(simN, na)
    for i = 0 to simN - 1
        int off = simN - 1 - i
        array.set(rawPx, i, src[off])
        array.set(rawHi, i, high[off])
        array.set(rawLo, i, low[off])
        array.set(rawAtr, i, atrV[off])

    [simFastPivIdx, simFastPivPx, simFastPath, simFastCum, simFastLast, simFastOpen, simFastDir] = f_buildCausalTransformPathArrays(rawPx, rawAtr, simN)


    // Forward-only transform direction state. Each replay bar uses only transform values
    // available through that bar. Flat transform bars preserve the most recent nonzero direction.
    int[] refDirByBar = array.new_int(simN, 0)
    int[] refSignalPivotByBar = array.new_int(simN, na)
    if simN > 0
        int refLastNonZeroDir = 0
        int refActivePivotBar = 0
        int refSwingExtremeBar = 0
        float refSwingExtremePrice = array.get(rawPx, 0)
        array.set(refSignalPivotByBar, 0, refActivePivotBar)

        if simN > 1
            for refReplayIndex = 1 to simN - 1
                float refPrevTransform = array.get(simFastPath, refReplayIndex - 1)
                float refTransformNow = array.get(simFastPath, refReplayIndex)
                int refStepDir = f_sign(refTransformNow - refPrevTransform)

                if refStepDir != 0
                    if refLastNonZeroDir == 0
                        refLastNonZeroDir := refStepDir
                        refSwingExtremeBar := refReplayIndex
                        refSwingExtremePrice := refStepDir > 0 ? array.get(rawHi, refReplayIndex) : array.get(rawLo, refReplayIndex)
                    else if refStepDir == refLastNonZeroDir
                        float refExtremeNow = refLastNonZeroDir > 0 ? array.get(rawHi, refReplayIndex) : array.get(rawLo, refReplayIndex)
                        bool refMoreExtreme = refLastNonZeroDir > 0 ? refExtremeNow >= refSwingExtremePrice : refExtremeNow <= refSwingExtremePrice
                        if refMoreExtreme
                            refSwingExtremeBar := refReplayIndex
                            refSwingExtremePrice := refExtremeNow
                    else
                        refActivePivotBar := refSwingExtremeBar
                        refLastNonZeroDir := refStepDir
                        refSwingExtremeBar := refReplayIndex
                        refSwingExtremePrice := refStepDir > 0 ? array.get(rawHi, refReplayIndex) : array.get(rawLo, refReplayIndex)

                array.set(refDirByBar, refReplayIndex, refLastNonZeroDir)
                array.set(refSignalPivotByBar, refReplayIndex, refActivePivotBar)

    // Causal transform-reversal attempts remain provisional until a structural event completes their swing.
    int[] provisionalDir = array.new_int()
    int[] provisionalTerminal = array.new_int()
    float[] provisionalTerminalPrice = array.new_float()
    int[] provisionalConfirm = array.new_int()
    float[] provisionalConfirmPrice = array.new_float()
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
    // The currently retained same-side grouped extreme is evaluated as if the available history ended at the current chart endpoint.
    // This temporary event exists only within the current preview rebuild.
    if finderMode == "Repainting Preview" and simN > 0
        int previewConfirmLocal = simN - 1

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
        float simStepThreshold = math.max(math.abs(array.get(rawAtr, i)) * transformDirectionThresholdAtr, eps)
        int simFastStepDir = math.abs(simTfNow - simTfPrev) >= simStepThreshold ? f_sign(simTfNow - simTfPrev) : 0
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

        // Create candidates directly from confirmed nonzero direction reversals of the causal adaptive transform path.
        // The stored forward-only transform state prevents later bars from rewriting an earlier reversal.
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
            array.push(provisionalDir, confirmDir)
            array.push(provisionalTerminal, simConfirmedCandidateBarNow)
            array.push(provisionalTerminalPrice, simConfirmedCandidatePxNow)
            array.push(provisionalConfirm, i)
            array.push(provisionalConfirmPrice, provisionalConfirmPriceNow)
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
            f_statusCell(statusTable, 10, "Structural resolver", "Grouped Extremes")
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
