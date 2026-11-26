# Sphinx DOL & Gamma Confluence

- url: https://www.tradingview.com/script/OkSA2eXM-Sphinx-DOL-Gamma-Confluence/
- type: indicator
- pine_id: PUB;8c2a6522edce4adea64d4431dbffb764
- version: 16.0

## Description

Sphinx DOL & Gamma Confluence

A positioning map that clusters draw-on-liquidity (DOL) levels together with options gamma levels, then grades each zone by how much confluence sits there - so the levels that matter stand out from the noise.

DOL LEVELS (computed automatically from price)
Prior day, week, and month high/low (PDH/PDL, PWH/PWL, PMH/PML); prior Asia and London session high/low; and overnight high/low (18:00-09:30, frozen at the RTH open). Each is tracked as tested or still naked (untested), and untested levels are weighted higher as live magnets. All toggleable.

GAMMA LEVELS (optional, entered by the user)
Gamma levels are price levels derived from options positioning that tend to act as support/resistance because of how dealers hedge:
- Call wall (CW): a strike with heavy call interest, usually above price - dealer hedging tends to lean against rallies there, so it often acts as a ceiling (red border).
- Put wall (PW): a strike with heavy put interest, usually below price - hedging tends to support dips there, so it often acts as a floor (green border).
- Flip (zero-gamma): the regime divider. Above it (positive gamma), hedging dampens moves - price tends to pin and walls tend to hold (fade environment). Below it (negative gamma), hedging amplifies moves - price tends to trend and walls tend to break into targets (trend environment).
Enter these per expiry (0/7/30 DTE) either as individual fields or as a pasted string; the tool auto-detects the chart symbol (ES/NQ/RTY/GC and micros).

HOW ZONES RENDER
Nearby levels merge into one translucent band. Fill color = confluence strength: extreme (a gamma wall stacked on a DOL level), major, or minor. Border color = direction: red ceiling, green floor, yellow pin (both), gray for pure liquidity. Labels list the members and tag [ceiling]/[floor]/[pin], with (naked) on untested levels. A table shows price, the 0/7/30 DTE flips with a positive/negative gamma read, the current regime, an extreme-zone count, and a snapshot-time stamp you set.

The value is combining two different mechanisms: DOL shows where liquidity rests (reactive), gamma shows where hedging flow will occur (anticipatory) - where they align is the highest-conviction zone.

IMPORTANT - DATA SOURCE
This tool does not source, provide, or connect to any options/gamma data. Gamma levels are entered manually by each user from whatever external source they choose, and their accuracy is entirely the user's responsibility. DOL levels work with no gamma input at all. Gamma tendencies are probabilistic, not guarantees - walls hold more often in positive gamma but can break.

This is a context/mapping tool, not a signal generator: no entries, no alerts, no automation. For educational purposes only; nothing here is financial advice. Verify all levels against your own sources.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// (c) MM Sphinx DOL + Gamma Confluence
// Version 2.18.4  (bar height scales with the VISIBLE range)
//
//   v2.18.4: FIX - both previous attempts scaled bar height by an ATR, and an
//   ATR is a fixed price height. Daily ATR does not change with timeframe;
//   chart ATR does, but neither changes when you zoom. A bar sized correctly
//   at one zoom level is wrong at the next.
//
//   Now sized as a fraction of the range actually on screen, read from
//   chart.left_visible_bar_time and chart.right_visible_bar_time. The bar
//   holds the same share of the window at any timeframe and any zoom, and
//   resizes as you scroll. Chart ATR and fixed ticks remain available.
//
// Version 2.18.3  (bar height scales with the chart, not the day)
//
//   v2.18.3: FIX - 2.18.1 scaled bar height by DAILY ATR, which is the same
//   number on every timeframe. It is a fixed price height, so it did not
//   adjust at all: invisible against an hourly chart showing 340 points and
//   oversized on a 1-minute chart showing 18.
//
//   Now scaled by ATR on the CHART timeframe, which moves with the visible
//   range by roughly the right order. At the default a 1-minute bar is about
//   a point tall and an hourly one about fourteen, both landing near five
//   percent of what is on screen.
//
// Version 2.18.2  (defaults: table top right, DOL lines black)
//
//   v2.18.2: table position back to top_right, and the DOL colour defaults to
//   black rather than white. White was chosen when this ran on a dark chart;
//   on a light one it is invisible, and the liquidity levels are the one part
//   of the level set that should never be hard to see.
//
// Version 2.18.1  (table clears the bars; bar height scales with ATR)
//
//   v2.18.1 changes:
//   - Table defaults to top_left. The bars now occupy the right margin and
//     the table was sitting on top of them, which made both unreadable.
//   - Bar half-height can be set as a fraction of daily ATR instead of in
//     ticks. A tick height tuned on a 1-minute chart is a hairline on an
//     hourly one, because the visible price range changes by an order of
//     magnitude while the bar does not. ATR scaling holds the proportion
//     across timeframes without retuning. Ticks remain available for a fixed
//     size.
//
// Version 2.18.0  (bar readability: axis, scaling, proportions)
//
//   v2.18.0 changes:
//   - SQRT SCALING, default on. Linear scaling against the largest wall on
//     the board means one dominant strike crushes everything else: on a live
//     board 7700 carried 6480 of put exposure while the rest ran 500-2500, so
//     every other bar rendered as a stub two or three pixels long. Square
//     root compresses the top and lifts the middle, which is the right
//     trade when the question is 'how do these compare' rather than 'what is
//     the exact ratio'. Linear remains available for reading exact
//     proportion.
//   - A centre axis is drawn in diverging mode. Without it there is no
//     reference for which way a bar leans, and two arms of similar length
//     read as one wide bar rather than as a balanced strike.
//   - A connector runs from the end of each level line to its bar, so the
//     measurement is visibly attached to the thing it measures instead of
//     floating in the margin.
//   - Bars are taller by default and the OI bar is drawn at half height
//     directly beneath its exposure bar rather than as a separate block of
//     equal weight. OI is supporting evidence, not a third equal reading.
//   - Default gap before the bars reduced, since the connector now carries
//     the eye across.
//
// Version 2.17.5  (fix: restore the label text block)
//
//   v2.17.5: FIX - CE10272, undeclared identifier _kindTxt. The 2.17.2 edit
//   replaced a slice running from the start of the bar block to the label
//   push, and the label-text block sat between the two, so it was deleted
//   along with the bars it was meant to survive.
//
//   Cause worth naming: replacing a span defined by two anchors deletes
//   everything in between, including code neither anchor refers to. Three of
//   today's faults came from edits that were larger than the change they were
//   making.
//
// Version 2.17.4  (fix: net label built above its own inputs)
//
//   v2.17.4: FIX - CE10272, undeclared identifier _rcwj. The 2.17.1 edit put
//   the net-exposure label string above the two lines that read the per-side
//   sums from the node. Moved below them.
//
//   The check that has been catching these only scanned 'var' declarations,
//   so a loop-local assigned with '=' was invisible to it. It now covers both.
//
// Version 2.17.3  (diverging exposure bar, delta-profile style)
//
//   v2.17.3 changes:
//   - Bar style is selectable. DIVERGING draws one bar per node from a centre
//     line: call exposure extends right, put exposure left, both scaled
//     against the largest single-side exposure on the board. Net is then the
//     visual imbalance - a strike leaning put has a longer left arm, and one
//     with a short arm on each side is balanced whatever its total size.
//     STACKED keeps the 2.17.2 form, two bars above one another.
//   - Diverging is the better default for a two-sided strike, which is the
//     case that matters. Stacked reads total size per side more precisely;
//     diverging reads the balance between them, and the balance is what
//     decides whether a strike pins or breaks.
//   - Open interest keeps its own bar beneath in either style. It is a count,
//     not a signed quantity, so it has no side to diverge to.
//   - The centre line sits at the middle of the bar lane, so each arm has
//     half the lane and the whole thing stays clear of the level lines.
//
// Version 2.17.2  (split bars: call exposure, put exposure, open interest)
//
//   v2.17.2 changes:
//   - A wall token may carry a third value, open interest:
//         CW7800:1400.0:27999
//     Two-value and bare tokens still parse, so nothing already working
//     breaks.
//   - The single magnitude bar becomes up to three stacked bars per node:
//     call exposure in the call colour, put exposure in the put colour, open
//     interest in its own. A dual-sided strike now shows its split instead of
//     collapsing to whichever side won a comparison.
//   - Call and put bars share one scale - the largest single-side exposure on
//     the board - so their lengths are directly comparable. OI is scaled
//     separately against the largest OI, because contracts and dollars are
//     not the same unit and a shared axis would imply they were.
//   - WHAT OI ADDS, AND WHAT IT DOES NOT. Notional already contains OI:
//     roughly OI x gamma-per-contract, and gamma-per-contract peaks at the
//     money. On a live board 7800 held 27,999 OI at $1.43B while 7750 held
//     14,313 at $1.58B - half the contracts, more exposure, because 7750 sat
//     nearer spot. So OI does not rank walls better than magnitude.
//     What it shows is DURABILITY. A wall that is large only because price is
//     standing on it loses that size when price leaves; the contracts stay
//     put but the gamma weighting collapses. A long purple bar under a short
//     red one is a position; a short purple bar under a long red one is a
//     moneyness effect that will not survive price moving away.
//   - Nothing selects, scores or filters on OI. It is drawn and exported.
//
// Version 2.17.1  (net exposure per strike decides dominance)
//
//   v2.17.1 changes:
//   - Merge nodes now carry the RAW magnitude summed per side, and dominance
//     is decided by their difference rather than by constituent count.
//   - The count test was wrong in a way that only became visible once real
//     magnitudes were being fed in. A node with one call wall and one put
//     wall is a tie by count, and ties broke to call. On a live board 7700
//     held CW 1110 against PW 2750 - two and a half times as much put
//     exposure - and was classified call-dominant. Sitting below price it was
//     then eligible for neither state box: the call box only considers walls
//     above price, and the put box requires not-call-dominant. The largest
//     strike on the board got no zone at all.
//   - RATIOS CANNOT DO THIS JOB. mMag is normalised per side per board, so
//     the top call and the top put both read 1.00 whatever their true sizes.
//     Comparing them is meaningless. Net requires the raw dollars, which is
//     why they are now stored alongside.
//   - Raw is SUMMED across constituents, not maxed. Two boards each holding
//     call exposure at one strike is more total exposure at that strike, and
//     that is the quantity a net calculation needs. mMag keeps its max-ratio
//     definition and still drives line width and bar length, which are size
//     statements about one side rather than a balance between two.
//   - Net exposure per node is exported, and shown on the label under Full.
//   - Falls back to the old count test when no magnitudes are present.
//
// Version 2.17.0  (labels group by side; lane gap and bar height are inputs)
//
//   v2.17.0 changes:
//   - Labels group their constituents by side instead of listing each one.
//     CW.0/PW.0/CW.7/PW.7/CW.30 becomes CW 0,7,30  PW 0,7 - the same content,
//     with the side stated once and the expiries collected behind it. The
//     old form repeated CW and PW up to six times per label and the expiry,
//     which is the part that varies, was buried in the repetition.
//   - The gap between the level lines and the magnitude bars is an input.
//   - Bar half-height defaults to 4 ticks rather than 2. At 2 the bar was
//     thinner than the line it measured, which read as an artefact of the
//     line rather than as its own mark.
//   - Grouping is applied in every label mode. mKind itself is unchanged and
//     still carries the full constituent list for the data window, so nothing
//     exported or measured is affected - this is the on-chart text only.
//
// Version 2.16.0  (offset region divided into lanes; compact labels)
//
//   v2.16.0 changes:
//   - The right offset region is now laid out in lanes rather than everything
//     starting at the last bar. Lines and bands end at the offset; the
//     magnitude bars occupy the lane after that; the gradient band the lane
//     after that; labels last. Previously the bars started at bar_index + 1
//     and the lines ran to bar_index + offset, so a bar was drawn INSIDE its
//     own level line and read as part of it rather than as a measurement of
//     it.
//   - Bar length is its own input instead of being derived from the label
//     offset. Those were two different quantities sharing one control, so
//     pulling the labels tighter also shortened every bar.
//   - Compact label mode. A node carrying four constituents rendered as
//     CW.0/PW.0/CW.30/PW.30, which is thirteen characters of the same two
//     facts repeated: both sides are present, two boards agree. Compact says
//     C/P 2b. The full form is still available and nothing measured changes -
//     mNCW, mNPW and mNDte are unchanged, this is the text only.
//
// Version 2.15.1  (fix: regime resolved before it is drawn with)
//
//   v2.15.1: FIX - CE10272, undeclared identifier regSig. The regime block sat
//   below the drawing block, which was harmless while nothing drawn depended
//   on the regime; the gradient band does. Pine resolves top-level statements
//   in source order, so the reference failed to compile. The regime block now
//   sits immediately above the drawing section. Nothing in it depends on
//   anything the drawing produces, so the move is order-only.
//
// Version 2.15.0  (gradient band: walls at the edges, flip zone in the middle)
//
//   v2.15.0 changes:
//   - The density column is replaced by a simpler gradient band. Density was
//     answering a question that had not been asked - how exposure distributes
//     between the walls - when the useful reading is just: where are the two
//     boundaries, and where is the regime line between them.
//   - The band runs from the boxed put wall to the boxed call wall. Call
//     colour above the flip, put colour below it, both saturating toward
//     their own wall and fading to nothing as they approach the flip. A grey
//     zone sits on the flip itself.
//   - The fade is the point. Intensity is a distance-to-boundary reading, so
//     price drifting mid-range sits in near-empty chart and price pressing an
//     edge sits in solid colour. The grey zone marks where the regime read
//     stops being reliable - within a few points of the flip strike the sign
//     of dealer gamma is a coin toss and the band should not imply otherwise.
//   - NEGATIVE REGIME collapses to one hue. In positive gamma the two edges
//     are opposite kinds of boundary and the colours mean something; in
//     negative gamma neither absorbs, both accelerate, and colouring them
//     differently would assert a role the model does not predict.
//   - Off by default, as the density column was.
//
// Version 2.14.0  (gamma density column, superseded)
//
//   v2.14.0 changes:
//   - A vertical density column in the right offset region. The price range
//     between the boxed put wall and the boxed call wall is cut into slices,
//     and each slice is shaded by the magnitude-weighted gamma sitting near
//     it. Individual lines say where the walls are; the column says how the
//     exposure is DISTRIBUTED between them - whether one strike dominates or
//     several share the load, and where the empty stretches are.
//   - Density uses an exponential kernel over node magnitude, so a slice
//     picks up nearby walls with decreasing weight rather than only the wall
//     it contains. Sigma scales with the range, so it does not need retuning
//     when the board widens.
//   - HUE FOLLOWS LOCAL CALL/PUT DOMINANCE, INTENSITY FOLLOWS DENSITY. That
//     is the reading requested and it is a directional claim the rest of this
//     script deliberately avoids - i_role_mode is Conservative precisely
//     because a put strike is taken to be short dealer gamma and therefore
//     amplifies rather than supports. Read the column as where exposure sits,
//     not as where price will hold.
//   - NEGATIVE REGIME USES A DIFFERENT PALETTE. In positive gamma a wall is a
//     boundary that absorbs; in negative gamma the same strike is a trigger
//     that accelerates once breached. The geometry is identical and the
//     meaning inverts, so the same colours across both regimes would say
//     'fade here' when the correct read is 'this is where it goes'. Amber
//     replaces the two-sided hue when net exposure is negative, and no
//     call/put distinction is drawn there - under short dealer gamma neither
//     side absorbs and the distinction stops carrying its meaning.
//   - Off by default. This is a full-height chart element and two others have
//     been removed from this script for exactly that reason.
//
// Version 2.13.0  (magnitude bars; call/put exposure gets its own row)
//
//   v2.13.0 changes:
//   - MAGNITUDE BARS. Each gamma node draws a horizontal bar in the right
//     offset region, its length proportional to the node's magnitude ratio.
//     Line width and band height already carried the same quantity, but both
//     are bounded encodings - width tops out at 4 and a band cannot grow
//     without implying a tolerance it does not have. A bar has room to be
//     read against its neighbours, which is the comparison that matters when
//     deciding which of two walls is the real one.
//     Drawn between the last bar and the label column, so it occupies space
//     already reserved and never overlays price.
//   - Call and put exposure move to their own table row. They were sharing a
//     cell with the flip-disagreement flag and were suppressed whenever that
//     flag fired - which is exactly when the composition is most worth
//     seeing, since a net figure near zero can be two large offsetting sides
//     or two small ones and the regime consequences are not the same.
//   - The net row keeps net, the flip disagreement flag and the cross-DTE
//     flag. Nothing is dropped, it is one row wider.
//
// Version 2.12.1  (fix: segment header split on first colon only)
//
//   v2.12.1: FIX - the segment split used str.split(seg, ':'), which cuts on
//   every colon, and read index 1 as the body. That was correct while the only
//   colon in a segment was the one after the DTE. From 2.11, when magnitudes
//   began travelling attached to their strikes, the body was truncated at the
//   SECOND colon: the put list vanished and the first call wall lost its
//   magnitude. The remainder still split into three fields, so the size check
//   passed, and the result was no walls drawn and no error raised. Now split
//   at the first colon by position. The wall lists are also guarded against
//   being empty before str.substring is applied to them.
//
// Version 2.12.0  (aggregate exposure travels in the string; field order free)
//
//   v2.12.0 changes:
//   - A segment may carry an optional aggregate exposure block:
//         ES.0:F7750|N3.53,7.31,-3.79|CW7800:1200.0,...|PW7700:405.3,...
//     The three numbers are net, call and put GEX in $B, in that order. They
//     land in the same place the three manual input fields did, so nothing
//     downstream of the regime resolution changes.
//   - Fields are now identified by PREFIX rather than by position. The old
//     parser read index 0 as flip, 1 as calls, 2 as puts, so inserting any new
//     field would have shifted the walls and broken every existing string.
//     CW / PW / N / F are unambiguous, so order no longer matters and an
//     unrecognised block is ignored rather than misread.
//   - Regime prefers the 0DTE net exposure from the string, then the manual
//     Net GEX field, then the flip comparison. 0DTE deliberately: the manual
//     field carried no expiry at all, so whichever board you happened to be
//     looking at when you typed it became the regime input for the whole
//     chart. Now the expiry is explicit and the intraday board governs.
//   - WHY THIS MATTERS, from a live board: spot 7779.25 against a 7782 flip is
//     spot BELOW flip, which the flip comparison reads as negative gamma. Net
//     exposure on the same board was +15.97B. The two disagree, regSplit
//     flags it, and with the field blank the flip reading would have won by
//     default and been wrong. This is the case the flag was built for and it
//     could not fire while the exposure fields sat empty.
//   - 7D and 30D net exposure are parsed, exported and used for one thing on
//     the chart: the table marks when the sign of net exposure disagrees
//     ACROSS expiries, which the single-figure display could not show.
//   - The three manual float inputs are retained as fallback and are used
//     only when the string carries no N block.
//
// Version 2.11.0  (magnitude travels inline with the strike)
//
//   v2.11.0 changes:
//   - A wall in the gamma string can now carry its magnitude attached to it:
//         ES.0:F7750|CW7800:1200.0,7775:1150.0|PW7700:405.3,7750:329.3
//     The old form is unchanged and still parses, so a plain strike list from
//     the QuantVue GEX Export drops into the same field and behaves exactly as
//     before. Mixed lists work too - a wall with no magnitude simply has none.
//   - This removes a real failure mode. The separate magnitude field is keyed
//     by POSITION: _magW looks up rank 2 of the call list and trusts that
//     rank 2 in i_mag is the same strike as rank 2 in i_gstr. Nothing checks
//     it. Paste an export from 09:31 against magnitudes captured at 09:28,
//     have one wall reorder between them, and every weight downstream is
//     attached to the wrong strike - silently, with no error and no visible
//     symptom. Binding the number to its own strike makes that impossible to
//     express rather than merely unlikely.
//   - The ratio is now computed WITHIN the segment: scan that side of that
//     board for the largest magnitude, divide. Same quantity _magW returned,
//     but without re-parsing the whole override string once per wall - which
//     was a nested scan over every segment for every wall on the chart.
//   - i_mag is retained as a fallback and is consulted only where a wall has
//     no inline magnitude. Deliberate: if the capture breaks mid-session the
//     old two-field path still works, and nothing has to be re-plumbed.
//   - BAND HEIGHT NOW CARRIES MAGNITUDE. Line mode has encoded size in width
//     since 2.10; band mode did not, so switching render modes silently
//     discarded the ranking. Band half-height is scaled by the same ratio,
//     floored by an input so a small wall stays visible rather than
//     collapsing to nothing.
//   - FIX: in Band mode a DOL that merged into a wall drew no mark at all.
//     The overlay was gated on i_lvl_render != 'Band', so the rule set in
//     2.3 - liquidity is never hidden inside a wall - held in Line mode and
//     was silently broken in Band mode. The dashed DOL line now draws in both,
//     at width 2 over a band so it reads against the fill.
//
//   v2.10.0 changes:
//   - The rank cut is now a floor rather than the whole filter. A wall below
//     the rank limit is still admitted if its magnitude ratio clears a
//     threshold. The rank cut alone drops walls by position in a list, and
//     position is a poor proxy for size: on a live ES 0DTE board the call side
//     ran 802.7 / 639.6 / 580.1 (1.00 / 0.80 / 0.72) while the put side ran
//     856.4 / 275.0 / 246.4 (1.00 / 0.32 / 0.29). The same rank step means
//     twenty percent on one side and sixty-eight on the other, so one cut
//     cannot serve both.
//   - This is what made dual-sided strikes invisible. On that board 7750 was
//     CW rank 3 and PW rank 2, carrying 580.1M call and 275.0M put - roughly
//     the largest combined concentration anywhere on the chart - and at
//     rank 1 neither leg entered the pool. It could not merge, could not be
//     counted in mNCW / mNPW, and could not be tagged. Price was resting on
//     it. Admitting on magnitude puts both legs in, they merge into one node,
//     and the pin condition can see it.
//   - FALLBACK: with the magnitude field blank, _magW returns na, the
//     threshold cannot be evaluated, and admission falls back to the rank cut
//     exactly as before. Nothing about string-only operation changes. This is
//     the same fallback pattern the Magnitude box mode already uses.
//   - Line width now carries magnitude. It was flat at 2 for every wall, so a
//     dominant wall and a marginal one drew identically and the only ranking
//     visible on the chart was the presence or absence of an alignment box.
//     Widths are 2 / 3 / 4 against two ratio thresholds, both inputs. The
//     floor is 2, so no wall draws thinner than it did before and the 2-vs-1
//     wall / DOL distinction is preserved.
//   - With magnitudes blank, width falls back to rank: r1 draws at 3, the rest
//     at 2. Coarser than the ratio mapping and honest about it - rank ordering
//     is all the string carries.
//   - NOT driven from mW. mW is a SUM over constituents, so a three-board node
//     scores high on count alone; driving width from it would encode board
//     agreement while appearing to encode magnitude. mMag is the MAX ratio
//     across a node's gamma constituents, which is a size statement. Board
//     agreement is already carried by the alignment box and its opacity.
//   - Line width applies in Line mode only. Band mode is unchanged - a band's
//     visual weight is its height and opacity, and scaling those is a separate
//     decision that would change the tolerance a band appears to represent.
//
// Version 2.9.1  (offset governs every drawn object)
//
//   v2.9.1: the right edge offset now applies to lines, bands, boxes and
//   labels together. Lines previously stopped at the last bar while boxes ran
//   twenty bars past it and labels sat wherever the offset put them, so the
//   three did not line up and moving one left the others behind.
//
// Version 2.9.0  (label content and offset)
//
//   v2.9.0 changes:
//   - Label content is selectable and defaults to the level name alone: CW.0,
//     PW.30, PDH, AsL and so on. The price is on the axis, the rank is implied
//     by the filter, and the state and confluence star were carrying detail
//     that had to be read rather than seen. Name + price and Full restore the
//     older forms.
//   - Role tags are off by default. Which side of price a wall sits on and
//     whether it is a call or a put are both visible without the words.
//   - Label offset from price is an input. It was fixed at twenty bars, which
//     on a zoomed-in chart parks the text far right of the candles.
//   - State, rank and confluence are unchanged in every other respect. They
//     are still computed, still scored, still exported - this governs the text
//     only, so nothing measured depends on what the label happens to show.
//
// Version 2.8.0  (rank filter; solid lines or bands)
//
//   v2.8.0 changes:
//   - Walls can be filtered by rank at the parse site. At the default only the
//     top-ranked call and put wall from each enabled board reach the chart.
//     With three boards on, rank 3 was up to eighteen levels; at rank 1 it is
//     six, and merging collapses the ones that agree - which is the useful
//     outcome, because a strike several boards name is the one worth drawing.
//     Filtering at the parse site rather than at draw time means a dropped
//     wall leaves the merge, the confluence scoring and the harvester with it,
//     so nothing downstream scores a level that is not on the chart.
//   - Level lines default to solid and the style is an input. They were
//     hard-coded dotted, which at a dozen levels reads as texture rather than
//     as a set of prices.
//   - Levels can render as narrow bands instead of lines. A band shows a wick
//     landing inside it, which a hairline cannot.
//
// Version 2.7.0  (stripped to levels and DOL)
//
//   v2.7.0 changes:
//   - REMOVED the HTF fair value gap subsystem entirely: its inputs, the two
//     1H / 4H security feeds, the gap capture and retention state, the gating
//     pool that decided which gaps qualified, and the drawing. It was the
//     single largest source of ink on the chart and the only part of this
//     script that drew objects not derived from a level.
//   - REMOVED the opening EQ lines - midnight, 08:30, 09:30, weekly, monthly.
//     They are reference prices rather than levels the model reads, and five
//     dashed lines across the canvas cost more than they returned.
//   - REMOVED the confluence zone bands. Every constituent already draws at
//     its own price; the band was a second mark for the same information.
//   - Rebuild now keys off the last bar alone. The gap feed used to supply two
//     further rebuild triggers, and with it gone the level set does not change
//     intrabar except for the price-relative reads.
//   - The diagnostics row reports confluent and aligned node counts; it
//     previously reported the size of the gap gating pool, which no longer
//     exists.
//
//   WHAT REMAINS: gamma walls, flips, DOL levels, their merge and confluence
//   scoring, the state boxes, the regime table, and the harvester. The
//   harvester draws nothing - it is data-window only - so it costs no ink.
//
// Version 2.6.3  (flat DTE weighting; flip band off by default)
//
//   v2.6.3 changes:
//   - DTE weights default to flat 1.00 / 1.00 / 1.00. The previous taper
//     toward 0DTE assumed the short-dated board carried the execution-relevant
//     levels. Observed otherwise: across a single session the 0DTE flip moved
//     tens of points and net exposure crossed zero twice, while the 7D and 30D
//     flips barely moved and converged on price. The level that held all day
//     was the one all three boards named, and its call dominance was visible
//     only on the longer boards - the 0DTE view of it was near-balanced. A
//     taper toward 0DTE down-weights the steadier evidence, and it works
//     against the alignment score, which already measures board agreement
//     directly. The inputs are unchanged, so the old taper is three fields
//     away for anyone who wants it.
//   - Flip band off by default. It stays available as a toggle; the flip line,
//     the label, the table rows and the data-window exports are untouched, so
//     nothing downstream of the display changes and the harvester still logs
//     distance to flip per interaction.
//
// Version 2.6.2  (correct the capture validity flag)
//
//   v2.6.2 changes:
//   - FIX: the harvester validity flag did not work. It compared the bar index
//     against the bar at which the gamma string changed, but the previous
//     string initialises empty, so the comparison fires at bar 0 on every
//     chart load and every row read as valid. A paste-time flag is not
//     constructible in Pine: history is recomputed from scratch on each load
//     and the script has no memory of when the string was entered.
//   - The flag now records whether the row was captured on a realtime bar,
//     which is knowable and is the condition that actually matters. On a live
//     bar the walls on screen were the walls in force. Rows reconstructed from
//     history carry the current string projected backwards and must be
//     excluded from gamma analysis; they remain valid for DOL analysis.
//   - Practical consequence: gamma-conditioned rows accrue only while the
//     chart is open with the current string loaded. DOL-conditioned rows
//     accrue over the full history window either way.
//
//   v2.6.1 changes:
//   - FIX: v2.6.0 did not compile. The harvester added 25 plots on top of an
//     export block that already held 48, for 74 against a hard ceiling of 64.
//   - Reduced to 56 by packing rather than dropping. The five harvester
//     booleans became one bitfield, its two wall counts one composite, the
//     eight DOL state series one base-3 composite, the three regime detail
//     series one composite, and the two reclaim flags one. Decode keys are
//     documented at each plot.
//   - Dropped outright: gate pool size, magnitude override filled, symbol
//     supported. All three are visible in the table and none is an analysis
//     input.
//   - No behaviour changed. Every quantity is still exported; several now
//     arrive packed and need splitting in the spreadsheet.
//
//   v2.6.0 changes:
//   - Adds the harvester, off by default. It logs one row per TOUCH of a level
//     node rather than per signal fire. Logging only fires produces a
//     numerator with no denominator: you learn how often a signal worked and
//     never how often the same level was reached and produced nothing, so no
//     conditional comparison is possible. The touch is the unit that makes the
//     denominator real.
//   - Each interaction is captured at the touch, watched for a configurable
//     window, then emitted with its outcome. Rows carry the level, its type,
//     board count, rank, DOL state, weight, confluence, wall composition,
//     distance to flip, regime sign, approach side, excursion either way in
//     ticks, bars to rejection, bars to break, and an outcome code.
//   - Bars to rejection and bars to break are exported raw alongside the
//     outcome code, so the respect threshold can be re-cut against the real
//     distribution later rather than being baked in at capture time.
//   - A validity flag marks rows whose gamma columns predate the gamma string
//     being entered. The string applies to all history, so on older bars the
//     walls are today's projected backwards. Those rows are still valid for
//     DOL analysis and must be excluded from gamma analysis.
//   - Merge nodes now carry a numeric DOL kind, so a row identifies which
//     level was touched rather than only that a DOL was present.
//
//   NOTE ON COLLECTION: TradingView stores nothing. These are plots, computed
//   on load. Use Export chart data to download a CSV and filter to rows where
//   hv_event is 1. At 1 minute the 10,000 bar cap is about seven sessions, so
//   exports must be taken weekly and appended - unexported data is not
//   recoverable.
//
//   v2.5.0 changes:
//   - The previous completed 4H candle high and low join the DOL pool, with
//     the same naked / swept / broken state as every other level. Every DOL
//     level here was previously a session or daily boundary, which is coarser
//     than a 4H narrative works with. Because they enter the pool rather than
//     drawing separately, a prior 4H high sharing a price with a wall merges
//     into one node and labels as 4hH/CW.30 - the alignment is computed, not
//     read off the chart by eye. They also carry into confluence scoring, the
//     FVG gating pool and the data window.
//   - Box selection gains a Magnitude mode, scoring on the node summed weight
//     so a pasted dollar magnitude drives the choice. Previously the paste
//     affected cluster weight and the nearest-wall exports but had no effect
//     at all on which wall was boxed, which was inconsistent.
//   - Magnitude mode falls back to Alignment + rank when the magnitude field
//     is blank, and the table flags the fallback. Without the guard the mode
//     would score on flat weights, which degenerates to a crude board count
//     while appearing to be a magnitude read.
//
//   v2.4.2 changes:
//   - The 0DTE flip draws as a band, coloured by which side price is closing
//     on. It was the thinnest mark on a chart carrying filled boxes on walls
//     twenty points away, which is backwards: the flip is the only level whose
//     position changes what every other level means. A wall above price is a
//     fade in positive gamma and a target in negative gamma, and nothing else
//     drawn here settles which.
//   - Optional regime background tint, off by default. It reads the resolved
//     regime signal rather than the flip side, so it follows net GEX when net
//     GEX has been entered.
//   - Box borders now inherit their state transparency. v2.4.1 forced border
//     opacity to 0, so a dim box and a lit box carried identical borders and
//     only the fill differed - at normal zoom the wick-into-level signal was
//     not visible at all.
//   - Multi-DTE alignment boxes scale opacity with the distinct board count.
//     Two boards render faint, five render solid. Previously every aligned
//     node drew at one opacity, so the count was invisible.
//
//   v2.4.1 changes:
//   - The boxed wall on each side is now chosen by score rather than by rank
//     alone. Score is an alignment bonus times a rank multiplier, so a strike
//     that two or three enabled boards agree on outscores a lone top-ranked
//     wall. At the defaults a two-board r3 scores 1.23 against 1.00 for a
//     single-board r1: agreement across expiries outweighs position within one
//     board's list. 'Rank only' restores the old selection.
//   - This also removes a defect in the old selection. Rank is emitted per
//     board, so a 30DTE r1 and a 0DTE r1 both carry rank 0 and tied; the tie
//     fell to whichever node the sorted pass reached first. A distant 30DTE
//     wall could therefore take the box from a live 0DTE one. Rank is now a
//     multiplier, and cross-board ties are broken by alignment.
//   - The 7D and 30D flip labels are off by default. The lines still draw, and
//     all three flips remain in the table and the data window.
//   - Box price and score exported for the harvester.
//
//   v2.4.0 changes:
//   - Broken DOL levels can now be mitigated off the chart. A level that has
//     had a close land beyond it has failed; it is history, not a draw. When
//     the toggle is on those levels are dropped at the pool stage, so they
//     leave the lines, the labels, the cluster weights and the FVG gate
//     together. Swept and naked levels are untouched. Turning it off restores
//     the previous behaviour exactly.
//   - The 7DTE flip label had an opaque background where the 0DTE and 30DTE
//     labels were transparent, which rendered it as a filled tag rather than
//     bare text. All three now draw identically.
//   - A merge node carrying walls from two or more enabled DTE boards is now
//     boxed. Independent boards landing on the same strike is the strongest
//     ranking signal available from the export string, and it needs no
//     magnitude data to compute. The distinct-board count is stored per node
//     and exported for the harvester.
//
//   v2.3.0 changes:
//   - Lines encode TYPE only, static: CW red, PW green, DOL white. Wall
//     line width 2, DOL width 1. A wall sharing a price with a DOL also
//     draws the DOL as its own white dashed line - liquidity is never
//     hidden inside a wall.
//   - The two largest-magnitude walls (rank 0 CW above price, rank 0 PW
//     below) get a narrow state box: dim until price wicks in, then lit;
//     closes through -> reclaimed colour, closes back -> reverts. Box
//     height and all box / line colours are inputs.
//
// Version 2.2.4  (compact table, rows appear only when they carry information)
//
//   v2.2.4 changes:
//   - The table is built to fit its contents instead of always occupying eleven
//     rows. A flip row is drawn only for an expiry that is switched on, so
//     turning one off clears it from the table rather than leaving it there as
//     context. Aggregate exposure and data age appear only once something has
//     been entered for them. Everything else moved behind a diagnostics toggle
//     that is off by default.
//   - Default is four rows: symbol and price, regime, and whichever flips are
//     enabled. Switching diagnostics on restores the outermost walls, the
//     confluent count and the gap filter pool size.
//
//   v2.2.3 changes:
//   - Role labels now distinguish call strikes from put strikes instead of
//     treating both as levels whose meaning depends only on which side of price
//     they sit. Under the standard positioning assumption these are opposites:
//     dealers are taken to be long gamma at call strikes, so hedging there
//     dampens and the level absorbs; and short gamma at put strikes, so hedging
//     there amplifies and price tends to pass through. The two lists carry
//     opposite signs in the source data for exactly this reason.
//   - Call-dominant nodes read as resistance above price and support below.
//   - Put-dominant nodes make no role claim in the default mode. Calling them a
//     floor or a ceiling asserted absorption the model does not predict. An
//     optional mode labels them as amplifying instead.
//   - Extreme naming is now positional. Outermost above and outermost below
//     describe what is computed, which is the last wall on each side. The old
//     wording implied support and resistance that a put strike does not provide.
//
//   v2.2.2 changes:
//   - Regime can now be read from net gamma exposure rather than from the side
//     of the flip strike. Where a full profile crosses zero many times, a single
//     reported flip strike is a lossy summary of it: spot can sit well above the
//     reported strike while aggregate dealer gamma is still net short. The sign
//     of net exposure is the quantity the flip comparison was standing in for,
//     so when it is supplied it is used directly. Flip side is kept and shown
//     alongside, and the two are flagged when they disagree.
//   - A level sitting exactly at the current price no longer vanishes from both
//     the ceiling and the floor. It previously had to be strictly above or
//     strictly below to be counted, so a wall the price was resting on appeared
//     in neither row. A level at price now counts as the floor.
//   - The pin label is no longer applied when call and put counts tie and no
//     magnitudes are available to break it. Where the two lists carry the same
//     strikes, every level ties, and a tie is not evidence of balance. Those
//     levels now draw with no role tag rather than a false one.
//
//   v2.2.1 changes:
//   - Labels no longer stack on top of each other at nearby prices. A collision
//     solver assigns each label the nearest free column to the right, so levels
//     a tick or two apart stagger instead of burying one another.
//   - Confluence grouping switched from single-linkage to complete-linkage. A
//     node joins a group only if it is within the radius of the group's LOWEST
//     member, which caps total group span at the radius. Single-linkage chained
//     four nodes across 8 points on a 3-point radius.
//   - Wall labels now carry their DTE (CW.0 / PW.30). With more than one DTE
//     board enabled, a bare rank was ambiguous.
//   - Merged node price snapped to mintick. The mean of two adjacent strikes
//     could land off-tick, which matters when it is a stop reference.
//   - The confluence star now marks gamma nodes only, so the count on the chart
//     matches the Confluent row in the table.
//   - Staleness timer stamps only on realtime. It was reporting the age of the
//     first historical bar, which is not when the string was pasted.
//
//   v2.2 changes:
//   - Clustering split into two independent operations. MERGE (tight, tick-based)
//     collapses only levels that are the same price for practical purposes.
//     CONFLUENCE (wide, ATR-scaled) groups nearby levels for scoring and banding
//     WITHOUT averaging them away. Constituent prices are always preserved and
//     always drawn at their true value.
//   - Transitive grouping bug fixed. The old seed/collect asymmetry silently
//     dropped chained levels (A~B, B~C, A!~C would lose C entirely). Grouping is
//     now a sorted linear pass, so chains group correctly and nothing is lost.
//   - Call/put wall RANK parsed from string position (QuantVue emits magnitude-
//     ordered, verified against the GEX Key Levels panel). Rank is stored,
//     labelled and exported but NOT scored - weights are flat by default because
//     the magnitude spread within the top three varies by DTE and is not
//     recoverable from the export string. Optional magnitude paste overrides.
//   - DOL levels carry three states instead of a touched/untouched bool:
//     naked (never reached), swept (wicked, no close beyond), broken (closed
//     through). Weighted 1.0 / 0.5 / 0.25.
//   - Wall role is decided by side relative to price, not by CW/PW label. A call
//     wall below price is reclaimed support; a put wall above price is overhead.
//   - "Extreme" renamed. [EXTREME CEILING] / [EXTREME FLOOR] mark the outermost
//     unbroken wall on each side (the boundary a draw must clear). The old
//     gamma-meets-DOL sense is now marked with a trailing * and called confluent.
//   - '++' / '+' count suffixes removed. They graded three trivial walls above
//     one dominant wall.
//   - Regime evaluated on a CLOSING basis, selectable chart / 15m / 1H.
//   - Unsupported symbols no longer silently default to ES. A 6E or DXY chart
//     previously parsed ES gamma and compared a euro price to an ES strike.
//   - Automatic staleness: minutes since the gamma string last changed, shown
//     alongside the hand-entered QuantVue snapshot time.
//   - Data-window export block added (was absent entirely). Level prices, ranks,
//     states, regime and wall touch counts are exported for offline harvesting.
//@version=6
indicator('MM Sphinx DOL + Gamma Confluence', shorttitle = 'Sphinx DOL+G', overlay = true, max_lines_count = 200, max_labels_count = 200, max_boxes_count = 200, max_bars_back = 1600)

// ============================================================
// === DATA ===
// ============================================================
i_data_mode = input.string('Manual', 'Gamma source', options = ['String', 'Manual', 'Demo'], group = 'Data', tooltip = 'String: paste a full gamma string. Manual: type levels into the fields below (for THIS chart\'s symbol). Demo: built-in example. DOL levels draw in all modes.')
i_gstr = input.string('', '  Gamma string (String mode)', group = 'Data', tooltip = 'Format:  SYM.DTE:F{flip}|CW{w,w,w}|PW{w,w,w}  separated by \';\'.  Wall order is magnitude rank as emitted by QuantVue.\n\nA wall may optionally carry its magnitude attached with a colon:\n  ES.0:F7750|CW7800:1200.0,7775:1150.0|PW7700:405.3,7750:329.3\n\nAttached magnitudes are preferred over the separate override field below, because they are bound to their own strike and cannot drift out of alignment with it. Mixed lists are fine - a wall with no attached number falls back to the override field, then to flat.')
i_max_rank = input.int(1, '  Draw walls down to rank', minval = 1, maxval = 3, group = 'Data', tooltip = 'How many walls per side per board are admitted on RANK ALONE. 1 admits only the top-ranked call and put wall from each enabled board; 3 admits everything the string carries.\n\nThis is a floor, not a ceiling. With the magnitude field filled, walls below this rank are still admitted if they clear the magnitude threshold below - so a large wall sitting at rank 3 is not lost merely because of its position in the list.\n\nFiltering at the parse site rather than at draw time means a dropped wall leaves the drawing, the merge, the confluence scoring and the harvester together. It is not a display filter.')
i_mag_keep = input.float(0.30, '  Also admit walls above magnitude ratio', minval = 0.0, maxval = 1.0, step = 0.05, group = 'Data', tooltip = 'A wall below the rank cut is still admitted when its magnitude is at least this fraction of the largest wall on the same side of the same board.\n\nOnly active when the magnitude override is filled. With it blank the ratio cannot be computed and admission falls back to the rank cut alone, exactly as before.\n\nWhy this exists: rank steps are not evenly spaced and the spacing differs by side. On one live ES 0DTE board the calls ran 1.00 / 0.80 / 0.72 while the puts ran 1.00 / 0.32 / 0.29. A rank cut of 1 discards a wall worth 80% of the top on one side and 32% on the other - the same instruction meaning two different things. At 0.30 that board admits all three calls and the top two puts.\n\nSet to 1.0 to disable and use the rank cut alone. Set to 0.0 to admit every wall the string carries.')
i_rank_mode = input.string('Magnitude', '  Wall order is', options = ['Magnitude', 'Price'], group = 'Data', tooltip = 'Magnitude: string position 1/2/3 is gamma rank (verified against the QuantVue GEX Key Levels panel). Price: position carries no information, rank labels are suppressed.')
i_mag = input.string('', '  Magnitude override (optional)', group = 'Data', tooltip = 'Optional. Paste dollar magnitudes in the same wall order to weight walls exactly instead of flat. Format:  SYM.DTE:CW{m,m,m}|PW{m,m,m}  separated by \';\'.  e.g.  ES.0:CW802.7,639.6,580.1|PW856.4,275.0,246.4\n\nUse ABSOLUTE values. The source panel signs put exposure negative; the ratio is computed against the largest wall on the same side, so a negative would produce a negative weight.\n\nAs of v2.10 this field does three things rather than one: it weights walls, it admits walls the rank cut would drop, and it sets line width. Leave it blank and all three fall back to rank behaviour.')
i_snap = input.string('', '  QuantVue snapshot time (HH:MM)', group = 'Data', tooltip = 'What QuantVue reported as its own update time. The table also shows how long ago the string itself changed, which is a different number.')

gGEX = 'Aggregate GEX (optional)'
i_netgex = input.float(0.0, 'Net GEX ($B)', step = 0.01, group = gGEX, tooltip = 'From the QuantVue gamma dashboard. Blank/zero = unused. Gives regime strength, not just sign.')
i_callgex = input.float(0.0, 'Call GEX ($B)', step = 0.01, group = gGEX, inline = 'cg')
i_putgex = input.float(0.0, 'Put GEX ($B)', step = 0.01, group = gGEX, inline = 'cg')

_demo = 'ES.0:F5900|CW5950,5975,6000|PW5850,5825,5800;NQ.0:F21000|CW21200,21300|PW20800,20700'

g_m0 = 'Manual - 0DTE  (blank = unused)'
mf0 = input.float(0.0, 'Flip', group = g_m0)
mcw0a = input.float(0.0, 'Call walls', group = g_m0, inline = 'cw0')
mcw0b = input.float(0.0, '', group = g_m0, inline = 'cw0')
mcw0c = input.float(0.0, '', group = g_m0, inline = 'cw0')
mpw0a = input.float(0.0, 'Put walls', group = g_m0, inline = 'pw0')
mpw0b = input.float(0.0, '', group = g_m0, inline = 'pw0')
mpw0c = input.float(0.0, '', group = g_m0, inline = 'pw0')
g_m7 = 'Manual - 7DTE'
mf7 = input.float(0.0, 'Flip', group = g_m7)
mcw7a = input.float(0.0, 'Call walls', group = g_m7, inline = 'cw7')
mcw7b = input.float(0.0, '', group = g_m7, inline = 'cw7')
mcw7c = input.float(0.0, '', group = g_m7, inline = 'cw7')
mpw7a = input.float(0.0, 'Put walls', group = g_m7, inline = 'pw7')
mpw7b = input.float(0.0, '', group = g_m7, inline = 'pw7')
mpw7c = input.float(0.0, '', group = g_m7, inline = 'pw7')
g_m30 = 'Manual - 30DTE'
mf30 = input.float(0.0, 'Flip', group = g_m30)
mcw30a = input.float(0.0, 'Call walls', group = g_m30, inline = 'cw30')
mcw30b = input.float(0.0, '', group = g_m30, inline = 'cw30')
mcw30c = input.float(0.0, '', group = g_m30, inline = 'cw30')
mpw30a = input.float(0.0, 'Put walls', group = g_m30, inline = 'pw30')
mpw30b = input.float(0.0, '', group = g_m30, inline = 'pw30')
mpw30c = input.float(0.0, '', group = g_m30, inline = 'pw30')

i_dte0 = input.bool(true, '0DTE walls', group = 'DTE', inline = 'd')
i_dte7 = input.bool(false, '7DTE walls', group = 'DTE', inline = 'd')
i_dte30 = input.bool(true, '30DTE walls', group = 'DTE', inline = 'd')

// ============================================================
// === DOL ===
// ============================================================
i_dol = input.bool(true, 'Include DOL levels', group = 'DOL')
i_pd = input.bool(true, '  Prev day H/L', group = 'DOL')
i_asia = input.bool(true, '  Asia session H/L', group = 'DOL')
i_lon = input.bool(true, '  London session H/L', group = 'DOL')
i_pw = input.bool(false, '  Prev week H/L', group = 'DOL', tooltip = 'Off by default. On most days this duplicates a session or prior-day level and inflates cluster weight from a single real price.')
i_pm = input.bool(false, '  Prev month H/L', group = 'DOL', tooltip = 'Off by default. Same duplication problem as prev week, plus it is rarely in range intraday.')
i_h4 = input.bool(true, '  Prev 4H candle H/L', group = 'DOL', tooltip = 'The high and low of the previous completed 4-hour candle, carrying the same naked / swept / broken state as the session levels.\n\nThese are the nearest structural draws on a 4H narrative and they were absent from the pool: every other DOL level here is a session or daily boundary, which is a coarser object than a 4H read works with. With this on, a prior 4H high sharing a price with a wall merges into one node and labels as 4hH/CW.30 rather than the two being read off the chart by eye.')
i_on = input.bool(false, '  Overnight H/L (18:00-09:30)', group = 'DOL', tooltip = 'Off by default. The overnight window spans Asia AND London, so ONH/ONL is almost always identical to AsH/LoH or AsL/LoL. Enabling it double-counts one level.')
i_hide_broken = input.bool(true, 'Mitigate broken levels', group = 'DOL', tooltip = 'A broken level is one a close has landed beyond - it failed, and it is no longer a draw. On: broken DOL levels are dropped entirely, so they leave the lines, the labels, the cluster weight and the FVG gating pool at the same time. Off: they keep drawing at the broken weight below, which is the pre-2.4 behaviour.\n\nSwept levels (wicked, no close beyond) are never hidden. The sweep is the raid; the level held.')
i_w_naked = input.float(1.00, 'Weight: naked', minval = 0.0, maxval = 2.0, step = 0.05, group = 'DOL', inline = 'dw')
i_w_swept = input.float(0.50, 'swept', minval = 0.0, maxval = 2.0, step = 0.05, group = 'DOL', inline = 'dw')
i_w_broken = input.float(0.25, 'broken', minval = 0.0, maxval = 2.0, step = 0.05, group = 'DOL', inline = 'dw')

// ============================================================
// === CLUSTER ===
// ============================================================
i_merge_ticks = input.int(4, 'Merge tolerance (ticks)', minval = 1, maxval = 40, group = 'Cluster', tooltip = 'Only levels this close collapse to a single drawn line. Kept tight so the drawn price stays within a tick or two of the real level - the stop reference depends on it.')
i_confl_atr = input.float(0.04, 'Confluence radius (x daily ATR)', minval = 0.005, maxval = 0.50, step = 0.005, group = 'Cluster', tooltip = 'Levels within this distance are treated as confluent: weight is summed, a shared band is drawn, and the FVG gate sees the group. They are NOT merged - each still draws at its own price.')
i_w_wall = input.float(1.00, 'Wall base weight', minval = 0.0, maxval = 3.0, step = 0.05, group = 'Cluster', tooltip = 'Flat by default. Rank is parsed and exported but not scored: the magnitude spread across the top three walls varies by DTE (steep at 0DTE, nearly flat at 7DTE) and is not recoverable from the export string. Use the magnitude override, or let the harvester measure whether rank matters.')
// Flat by default as of v2.6.3. The old 1.00 / 0.60 / 0.40 taper assumed the
// short-dated board was the execution-relevant one. Observed intraday: the
// 0DTE flip travelled tens of points and net exposure changed sign twice
// inside two hours, while the 7D and 30D flips barely moved and converged on
// price. The level set that held was the one the longer boards agreed on. A
// taper toward 0DTE therefore down-weights the more stable evidence. Flat
// lets board agreement alone drive the score, which is what mNDte measures.
i_dte_w0 = input.float(1.00, 'DTE weight  0D', minval = 0.0, maxval = 2.0, step = 0.05, group = 'Cluster', inline = 'dtew')
i_dte_w7 = input.float(1.00, '7D', minval = 0.0, maxval = 2.0, step = 0.05, group = 'Cluster', inline = 'dtew')
i_dte_w30 = input.float(1.00, '30D', minval = 0.0, maxval = 2.0, step = 0.05, group = 'Cluster', inline = 'dtew')

// ============================================================
// === REGIME ===
// ============================================================
i_reg_basis = input.string('Chart', 'Regime basis', options = ['Chart', '15m', '1H'], group = 'Regime', tooltip = 'Flip is evaluated on a CLOSING basis, never on an intrabar cross. Chart = last confirmed bar on this timeframe.')
i_role_mode = input.string('Conservative', 'Wall role labels', options = ['Conservative', 'Training wheels', 'Off'], group = 'Regime', tooltip = 'Conservative: call-dominant nodes are labelled resistance above price and support below. Put-dominant nodes carry no role label, because the positioning model does not predict that they absorb.\n\nTraining wheels: as above, and put-dominant nodes are additionally marked as amplifying.\n\nOff: no role labels at all, prices and kinds only.\n\nAll of this rests on the assumption built into the source data that dealers are long gamma at call strikes and short gamma at put strikes. That is a convention, not observed inventory, and it may not hold for very short dated boards where speculative call buying is heavy.')
i_reg_src = input.string('Auto', 'Regime source', options = ['Auto', 'Net GEX', 'Flip'], group = 'Regime', tooltip = 'Auto: use net gamma exposure when it has been entered, otherwise fall back to the side of the flip strike. Net GEX: always use the sign of net exposure, and report nothing if it is blank. Flip: always use the flip comparison.\n\nThese can disagree. A gamma profile can cross zero at many strikes, so a single reported flip is a summary of it, and spot can sit above that strike while aggregate exposure is still net short. The table marks a disagreement when one occurs.')

gHV = 'Harvester (level interaction log)'
i_hv = input.bool(false, 'Enable harvester', group = gHV, tooltip = 'Logs one row per level interaction for export. The unit of observation is the TOUCH, not the signal fire: logging only fires gives a numerator with no denominator, so nothing can be said about whether a condition changes the reaction rate.\n\nRows are emitted as data-window plots. TradingView stores nothing - use Export chart data to download a CSV, then filter to rows where hv_event is 1. At 1 minute the 10,000 bar cap is about seven sessions, so this needs exporting weekly or the data is gone.')
i_hv_win = input.int(20, '  Outcome window (bars)', minval = 3, maxval = 200, group = gHV, tooltip = 'How long each interaction is watched before its row is emitted. The row appears this many bars AFTER the touch, with the interaction bar index carried in hv_bar.')
i_hv_rej = input.int(2, '  Respect within (bars)', minval = 1, maxval = 20, group = gHV, tooltip = 'Bars within which a rejection counts as the level being respected. Two is a common discretionary threshold and is a reasonable starting cut, but it is a hypothesis, not a constant - hv_bars_to_reject records the raw figure so the threshold can be re-cut against the real distribution later.')
i_hv_ticks = input.int(4, '  Minimum move (ticks)', minval = 1, maxval = 40, group = gHV, tooltip = 'How far price must travel from the level before a move counts as a rejection or a break. Filters out prints that sit on the level without resolving.')
i_hv_gamma_only = input.bool(false, '  Gamma nodes only', group = gHV, tooltip = 'Off by default. Every node is logged with its type as a column, so subsets can be taken later in the spreadsheet - a narrower capture cannot be widened after the fact.')

// ============================================================
// === STYLE ===
// ============================================================
col_cw = input.color(color.new(#ef5350, 0), 'Call wall (CW)', group = 'Style', inline = 'wall')
col_pw = input.color(color.new(#26a69a, 0), 'Put wall (PW)', group = 'Style', inline = 'wall')
col_dol = input.color(color.new(#000000, 0), 'DOL level', group = 'Style')
i_lvl_render = input.string('Line', 'Draw levels as', options = ['Line', 'Band'], group = 'Style', tooltip = 'Line: one horizontal line per level. Band: a narrow filled rectangle instead, which reads as a zone rather than a price and is easier to see a wick land inside.\n\nMagnitude-scaled line width applies in Line mode only. A band already carries visual weight through its height and opacity, and scaling those would change the tolerance the band appears to represent.')
i_lvl_sty = input.string('Solid', '  Line style', options = ['Solid', 'Dashed', 'Dotted'], group = 'Style')
i_mag_width = input.bool(true, '  Scale wall line width by magnitude', group = 'Style', tooltip = 'On: a wall line is drawn at width 2, 3 or 4 according to how large it is relative to the biggest wall on its side of its board. The node takes the MAX ratio among its gamma constituents.\n\nWith the magnitude field blank the ratio does not exist and width falls back to rank: the top-ranked wall draws at 3, everything else at 2. Coarser, and honest about it - rank ordering is all the string carries.\n\nDeliberately NOT driven from the node summed weight. That is a sum over constituents, so a three-board node scores high on count alone; driving width from it would encode board agreement while appearing to encode size. Board agreement already has its own mark - the alignment box, whose opacity carries the count.\n\nOff: every wall draws at width 2, which is the pre-2.10 behaviour.')
i_dens = input.bool(false, 'Gradient band', group = 'Style', tooltip = 'A vertical band in the right offset region running from the boxed put wall to the boxed call wall.\n\nCall colour above the flip, put colour below, each saturating toward its own wall and fading out as it nears the flip. A grey zone sits on the flip strike itself.\n\nThe fade carries the reading: mid-range is near-empty, pressing an edge is solid. The grey marks where the regime call is not reliable - within a few points of the flip the sign of dealer gamma is a coin toss.\n\nIn NEGATIVE regime the band collapses to one hue. Neither side absorbs under short dealer gamma, so a two-colour split would assert a role the model does not predict.')
i_dens_n = input.int(28, '  Slices', minval = 6, maxval = 60, group = 'Style')
i_dens_w = input.int(6, '  Band width (bars)', minval = 2, maxval = 40, group = 'Style')
i_flipz = input.float(4.0, '  Flip zone half-height (points)', minval = 0.0, maxval = 50.0, step = 0.5, group = 'Style', tooltip = 'Half the height of the grey neutral zone centred on the 0DTE flip strike. Set to 0 to remove it and let the two colours meet directly.')
i_dens_op_hi = input.int(45, '  Opacity at the wall', minval = 0, maxval = 95, group = 'Style', inline = 'do')
i_dens_op_lo = input.int(95, 'at the flip', minval = 0, maxval = 99, group = 'Style', inline = 'do')
col_dens_neg = input.color(color.new(#ffa726, 0), '  Negative-regime hue', group = 'Style')
col_flipz = input.color(color.new(#9e9e9e, 70), '  Flip zone', group = 'Style')
i_mag_bars = input.bool(true, '  Magnitude bars at right edge', group = 'Style', tooltip = 'Draws a horizontal bar per gamma node in the offset region to the right of price, length proportional to the node magnitude ratio.\n\nWidth and band height carry the same number but both are bounded - width stops at 4, and a band cannot grow without implying a tolerance it does not represent. A bar has room to be compared against its neighbours, which is the read that decides which of two nearby walls is the one to trade.\n\nOccupies the space already reserved by the right edge offset, so it never overlays price. Needs magnitudes; with none it draws nothing.')
i_bar_h_mode = input.string('Visible range', '    Bar height from', options = ['Visible range', 'Chart ATR', 'Ticks'], group = 'Style', tooltip = 'ATR: bar half-height is a fraction of daily ATR, so it holds its proportion when you change timeframe. A tick height tuned on a 1-minute chart renders as a hairline on an hourly one, because the visible price range changes by an order of magnitude and a fixed tick count does not.\n\nTicks: fixed size regardless of range.')
i_bar_ticks = input.int(7, '    Bar half-height (ticks)', minval = 1, maxval = 30, group = 'Style')
i_bar_vis = input.float(0.020, '    Bar half-height (x visible range)', minval = 0.002, maxval = 0.20, step = 0.002, group = 'Style', tooltip = 'Fraction of the price range currently on screen. Unlike an ATR this responds to zoom, so the bar keeps the same visual weight whether you are looking at fifteen points or four hundred.')
i_bar_atr = input.float(0.60, '    Bar half-height (x chart ATR)', minval = 0.05, maxval = 5.0, step = 0.05, group = 'Style', tooltip = 'Multiplier on ATR(14) of the CHART timeframe, not the daily. Daily ATR is one number regardless of timeframe, so scaling by it produced a fixed price height that did not adjust between a 1-minute and an hourly chart.')
i_lane_gap = input.int(3, '    Gap before bars (bars)', minval = 0, maxval = 60, group = 'Style', tooltip = 'Horizontal space between where the level lines stop and where the magnitude bars begin. Raise it to separate the measurement from the thing being measured.')
i_bar_scale = input.string('Sqrt', '    Bar scaling', options = ['Sqrt', 'Linear'], group = 'Style', tooltip = 'How bar length maps to exposure.\n\nSqrt: compresses the largest wall and lifts the smaller ones. Use when the board has one dominant strike - linear scaling against it renders everything else as a stub.\n\nLinear: length is exactly proportional. Truer, and unreadable when one strike is several times the rest.')
i_bar_axis = input.bool(true, '    Centre axis and connectors', group = 'Style', tooltip = 'Draws the zero line for diverging bars, and a faint connector from each level line to its bar. Without the axis there is no reference for which way a bar leans; without the connector the bars float unattached in the margin.')
i_bar_style = input.string('Diverging', '    Exposure bar style', options = ['Diverging', 'Stacked'], group = 'Style', tooltip = 'Diverging: one bar per node from a centre line, calls right and puts left, both on the same scale. The imbalance IS the net, read at a glance, and a two-sided strike shows an arm each way.\n\nStacked: calls and puts as separate bars one above the other. Reads absolute size per side more precisely, and the balance between them less directly.\n\nOpen interest keeps its own bar beneath in either style - it is a count with no side to diverge to.')
col_oi = input.color(color.new(#ab47bc, 0), '    Open interest bar', group = 'Style')
i_bar_len = input.int(20, '    Bar length at max magnitude (bars)', minval = 4, maxval = 120, group = 'Style', tooltip = 'Horizontal length of the longest bar. Every other bar is this times its magnitude ratio.\n\nSeparate from the right edge offset deliberately - that governs where the lines stop, this governs how long the bars are, and sharing one control meant pulling the labels tighter also shortened every bar.')
i_bar_op = input.int(35, '    Bar opacity', minval = 0, maxval = 90, group = 'Style')
i_mag_w_hi = input.float(0.70, '    Width 4 above ratio', minval = 0.0, maxval = 1.0, step = 0.05, group = 'Style', inline = 'mw')
i_mag_w_mid = input.float(0.40, 'width 3 above', minval = 0.0, maxval = 1.0, step = 0.05, group = 'Style', inline = 'mw')
i_band_ticks = input.int(3, '  Band half-height (ticks)', minval = 1, maxval = 40, group = 'Style', tooltip = 'Used in Band mode. The band is centred on the level price, so this is half its total height.\n\nWhen magnitude scaling is on this is the height of the LARGEST wall; everything else scales down from it by ratio.')
i_band_min = input.float(0.35, '  Band minimum scale', minval = 0.05, maxval = 1.0, step = 0.05, group = 'Style', tooltip = 'Floor on the magnitude scaling of band height, so a small wall renders as a thin band rather than disappearing. At 0.35 the smallest wall drawn is a third the height of the largest.\n\nSet to 1.0 to switch band scaling off and draw every band at full height, which is the pre-2.11 behaviour.')
i_band_op = input.int(70, '  Band opacity', minval = 0, maxval = 100, group = 'Style')
col_flip = input.color(#ffd54f, 'Flip', group = 'Style')
i_bignb = input.bool(true, 'Box the largest CW / PW', group = 'Style', tooltip = 'Draws a narrow box on the largest-magnitude call wall above price and put wall below. The box is dim until price wicks into it (lights up), turns green when price closes through and back to red/green when it closes back. Other walls stay as plain lines.')
i_box_ticks = input.int(3, '  Box height (ticks)', minval = 1, maxval = 40, group = 'Style')
i_box_mode = input.string('Alignment + rank', '  Box selection', options = ['Alignment + rank', 'Magnitude', 'Rank only'], group = 'Style', tooltip = 'Alignment + rank: score = alignment bonus x rank multiplier. A strike two or three enabled boards agree on outscores a lone top-ranked wall. Costs nothing and works every session, because board agreement is recoverable from the export string alone.\n\nMagnitude: score = the node summed weight, which carries the pasted dollar magnitudes. Sharper where absorption is expected, since dampening force scales with gamma concentration at the strike - but it needs the magnitude field filled every session. If that field is blank the mode falls back to Alignment + rank and the table flags it, rather than silently scoring on flat weights.\n\nRank only: lowest rank number wins, board agreement ignored. Rank is emitted per board and is not comparable across boards, so this is kept for comparison rather than use.')
i_align_bonus = input.float(0.75, '  Alignment bonus per extra board', minval = 0.0, maxval = 3.0, step = 0.05, group = 'Style', tooltip = 'Score multiplier added for each board beyond the first that puts a wall at this strike. At 0.75 a two-board node scores 1.75 and a three-board node 2.50 against 1.00 for a single board. Set to 0 to make alignment worthless and fall back to rank alone.')
i_rank_decay = input.float(0.15, '  Rank decay per step', minval = 0.0, maxval = 0.50, step = 0.05, group = 'Style', tooltip = 'Score multiplier lost per rank step. At 0.15 an r1 keeps 1.00, r2 0.85, r3 0.70. Kept small deliberately: the magnitude spread across the top three walls is not recoverable from the export string, so rank is a tiebreak here rather than the primary sort. Raise it only if you are pasting magnitudes.')
col_cw_dim = input.color(color.new(#ef5350, 70), '  CW box dim', group = 'Style', inline = 'cwb')
col_cw_lit = input.color(color.new(#ef5350, 0), 'lit', group = 'Style', inline = 'cwb')
col_pw_dim = input.color(color.new(#26a69a, 70), '  PW box dim', group = 'Style', inline = 'pwb')
col_pw_lit = input.color(color.new(#26a69a, 0), 'lit', group = 'Style', inline = 'pwb')
col_reclaim = input.color(color.new(#26a69a, 0), '  Reclaimed (closed through)', group = 'Style')
i_tier2 = input.bool(true, 'Box multi-DTE aligned walls', group = 'Style', tooltip = 'Boxes any node where two or more ENABLED DTE boards put a wall at the same price (within merge tolerance). Independent expiries agreeing on a strike is the only ranking signal recoverable from the export string without magnitudes.\n\nOnly boards switched on in the DTE group are counted, so turning a board off removes its votes.')
i_t2_ticks = input.int(3, '  Aligned box height (ticks)', minval = 1, maxval = 40, group = 'Style')
col_tier2 = input.color(color.new(#ffd54f, 60), '  Aligned box', group = 'Style')
i_show_flips = input.bool(true, 'Show flip lines', group = 'Style')
i_flip_band = input.bool(false, '  Band the regime flip', group = 'Style', tooltip = 'Draws the 0DTE flip as a band rather than a hairline. The flip is the only level on the chart that changes what every other level means - a wall above price is a fade in positive gamma and a target in negative gamma - so it should not be the thinnest thing drawn.\n\nColoured by which side of it price is closing: dampening above, amplifying below.')
i_flip_band_pts = input.float(1.50, '  Band half-height (points)', minval = 0.25, maxval = 20.0, step = 0.25, group = 'Style', tooltip = 'Half the band height in price points, not ticks. This is a visual weight setting, not a tolerance - the regime comparison is still made against the exact flip price.')
col_flip_pos = input.color(color.new(#26a69a, 78), '  Band above / below', group = 'Style', inline = 'fb')
col_flip_neg = input.color(color.new(#ef5350, 78), '', group = 'Style', inline = 'fb')
i_reg_tint = input.bool(false, '  Tint background by regime', group = 'Style', tooltip = 'Colours the whole chart background by regime sign. Unmissable, and heavy - off by default. Use it if the band is still not carrying enough weight against the rest of the level set.')
i_reg_tint_op = input.int(94, '  Tint opacity', minval = 80, maxval = 99, group = 'Style')
i_flip_lbl_all = input.bool(false, '  Label 7D / 30D flips', group = 'Style', tooltip = 'Off: only the 0DTE flip carries a text label. The 7D and 30D flip lines still draw, and all three flips stay in the table and the data window - the label is the only thing suppressed.\n\nOn: every enabled flip line is labelled, which is the pre-2.4.1 behaviour.')
i_show_tbl = input.bool(true, 'Show regime table', group = 'Style')
i_tbl_diag = input.bool(false, '  Include diagnostic rows', group = 'Style', tooltip = 'Adds the outermost wall on each side, the confluent node count and the gap filter pool size. Off by default: the first two are already drawn on the chart as labelled lines, and the last two are only useful when something looks wrong.')
i_tbl_pos = input.string('top_right', 'Table position', options = ['top_right', 'bottom_right', 'top_left', 'bottom_left'], group = 'Style')
i_lbl_size = input.string('small', 'Label size', options = ['tiny', 'small', 'normal', 'large'], group = 'Style')
i_lbl_pad = input.int(20, 'Right edge offset (bars)', minval = 0, maxval = 200, group = 'Style', tooltip = 'How far past the last bar every drawn object ends - lines, bands, boxes and labels together. Lower values pull the whole set tight to price; raise it to park it clear of the candles.\n\nPreviously lines stopped at the last bar while boxes ran twenty bars past it, so the two did not line up.')
i_lbl_detail = input.string('Name only', 'Label content', options = ['Compact', 'Name only', 'Name + price', 'Full'], group = 'Style', tooltip = 'Name only: the level kind alone - CW.0, PDH, AsL and so on. Everything else is already on the chart or in the settings.\n\nName + price: adds the level price.\n\nFull: adds the DOL state, the rank and the confluence star. This is the pre-2.9 label and it is the densest thing the script draws.')
i_lbl_role = input.bool(false, '  Include role tag', group = 'Style', tooltip = 'Adds [resistance] / [support] / [OUTERMOST ABOVE] to the label. Off by default: the role follows from the wall type and which side of price it sits on, both of which are visible without the text.')
i_stagger = input.int(22, 'Label stagger (bars)', minval = 0, maxval = 120, group = 'Style', tooltip = 'Horizontal offset applied when two labels would sit at nearly the same price. 0 disables staggering and lets them overlap.')
i_lbl_gap = input.float(0.020, 'Label collision gap (x daily ATR)', minval = 0.001, maxval = 0.20, step = 0.001, group = 'Style', tooltip = 'Two labels closer than this in price are considered colliding and get pushed to separate columns. Raise it if labels still overlap at your zoom level.')

// ============================================================
// === SYMBOL RESOLUTION  (no silent fallback to ES) ===
// ============================================================
_t = syminfo.ticker
// Whether the magnitude override has actually been filled. Used to keep the
// Magnitude box mode from scoring on flat weights when the field is blank,
// and as of v2.10 to decide whether the magnitude admission threshold and the
// magnitude line width can be evaluated at all.
_magOn = i_mag != ''
chartSym = str.contains(_t, 'RTY') or str.contains(_t, '2K') ? 'RTY' : str.contains(_t, 'NQ') ? 'NQ' : str.contains(_t, 'GC') ? 'GC' : str.contains(_t, 'ES') ? 'ES' : ''
symOk = chartSym != ''

_dteOn(d) =>
    d == '0' and i_dte0 or d == '7' and i_dte7 or d == '30' and i_dte30
_dteW(d) =>
    d == '0' ? i_dte_w0 : d == '7' ? i_dte_w7 : d == '30' ? i_dte_w30 : 1.0
_lsty(x) =>
    x == 'Dashed' ? line.style_dashed : x == 'Dotted' ? line.style_dotted : line.style_solid
// Groups a merge node's constituent list by side: CW.0/PW.0/CW.7/PW.7/CW.30
// becomes CW 0,7,30  PW 0,7. Any constituent that is not a wall - a DOL kind
// like PDH or AsL - passes through and is appended after the walls.
_fmtKind(k) =>
    _parts = str.split(k, '/')
    string _cw = ''
    string _pw = ''
    string _dl = ''
    if array.size(_parts) > 0
        for _i = 0 to array.size(_parts) - 1 by 1
            _p = array.get(_parts, _i)
            if str.startswith(_p, 'CW.')
                _d = str.substring(_p, 3)
                _cw := _cw == '' ? _d : _cw + ',' + _d
                _cw
            else if str.startswith(_p, 'PW.')
                _d = str.substring(_p, 3)
                _pw := _pw == '' ? _d : _pw + ',' + _d
                _pw
            else
                _dl := _dl == '' ? _p : _dl + '/' + _p
                _dl
    string _o = ''
    if _cw != ''
        _o := 'CW ' + _cw
        _o
    if _pw != ''
        _o := _o == '' ? 'PW ' + _pw : _o + '  PW ' + _pw
        _o
    if _dl != ''
        _o := _o == '' ? _dl : _o + '  ' + _dl
        _o
    _o == '' ? k : _o

_lblsz(z) =>
    z == 'tiny' ? size.tiny : z == 'normal' ? size.normal : z == 'large' ? size.large : size.small

// Manual fields build the same string the parser consumes (0 = unused, skipped).
_join3(a, b, c) =>
    _s = ''
    if a > 0
        _s := str.tostring(a)
        _s
    if b > 0
        _s := _s == '' ? str.tostring(b) : _s + ',' + str.tostring(b)
        _s
    if c > 0
        _s := _s == '' ? str.tostring(c) : _s + ',' + str.tostring(c)
        _s
    _s
_mseg(sym, dte, f, cwa, cwb, cwc, pwa, pwb, pwc) =>
    _cw = _join3(cwa, cwb, cwc)
    _pw = _join3(pwa, pwb, pwc)
    _fs = f > 0 ? str.tostring(f) : ''
    _fs == '' and _cw == '' and _pw == '' ? '' : sym + '.' + dte + ':F' + _fs + '|CW' + _cw + '|PW' + _pw
_msym = symOk ? chartSym : 'XX'
_seg0 = _mseg(_msym, '0', mf0, mcw0a, mcw0b, mcw0c, mpw0a, mpw0b, mpw0c)
_seg7 = _mseg(_msym, '7', mf7, mcw7a, mcw7b, mcw7c, mpw7a, mpw7b, mpw7c)
_seg30 = _mseg(_msym, '30', mf30, mcw30a, mcw30b, mcw30c, mpw30a, mpw30b, mpw30c)
manual_str = _seg0
if _seg7 != ''
    manual_str := manual_str == '' ? _seg7 : manual_str + ';' + _seg7
    manual_str
if _seg30 != ''
    manual_str := manual_str == '' ? _seg30 : manual_str + ';' + _seg30
    manual_str
gstr = not symOk ? '' : i_data_mode == 'Demo' ? _demo : i_data_mode == 'Manual' ? manual_str : i_gstr

// ============================================================
// === CLOSING-BASIS REFERENCE ===
// ============================================================
_ccl = barstate.isconfirmed ? close : close[1]
_rc15 = request.security(syminfo.tickerid, '15', close[1], lookahead = barmerge.lookahead_off)
_rc60 = request.security(syminfo.tickerid, '60', close[1], lookahead = barmerge.lookahead_off)
regClose = i_reg_basis == '15m' ? _rc15 : i_reg_basis == '1H' ? _rc60 : _ccl

katr_d = request.security(syminfo.tickerid, 'D', ta.atr(14), lookahead = barmerge.lookahead_off)
atr_tol = na(katr_d) ? ta.atr(14) * 3 : katr_d
// ATR on the chart timeframe. Used for bar height so the bars keep their
// proportion to what is actually on screen; daily ATR cannot do that job
// because it does not change when the timeframe does.
_catr = ta.atr(14)
// Price range currently on screen. chart.left_visible_bar_time and its right
// counterpart move with zoom and scroll, so this is the only one of the three
// height sources that responds to how the chart is actually being viewed.
_tfms = timeframe.in_seconds() * 1000
_visN = _tfms > 0 ? math.max(10, math.min(2000, int((chart.right_visible_bar_time - chart.left_visible_bar_time) / _tfms))) : 300
_visRange = ta.highest(high, _visN) - ta.lowest(low, _visN)
[pdh, pdl] = request.security(syminfo.tickerid, 'D', [high[1], low[1]], lookahead = barmerge.lookahead_on)
// Prior completed 4H candle. lookahead_on is safe for a [1]-offset request:
// it returns the previous bar's finished values, which are known.
[h4h, h4l] = request.security(syminfo.tickerid, '240', [high[1], low[1]], lookahead = barmerge.lookahead_on)
[pwh, pwl] = request.security(syminfo.tickerid, 'W', [high[1], low[1]], lookahead = barmerge.lookahead_on)
[pmh, pml] = request.security(syminfo.tickerid, 'M', [high[1], low[1]], lookahead = barmerge.lookahead_on)

kh = hour(time, 'America/New_York')
km = minute(time, 'America/New_York')
kmins = kh * 60 + km

// ============================================================
// === DOL STATE  (2 = naked, 1 = swept, 0 = broken) ===
//   naked  : price has never reached the level
//   swept  : price wicked through, no close beyond - liquidity taken, level held
//   broken : a close landed beyond the level - the level failed
//   The distinction matters: a wick sweep is the raid, a close through is
//   structural failure. v2.1 collapsed both into "touched".
// ============================================================
_stH(lvl, st) =>
    na(lvl) ? st : _ccl > lvl ? 0 : high >= lvl ? math.min(st, 1) : st
_stL(lvl, st) =>
    na(lvl) ? st : _ccl < lvl ? 0 : low <= lvl ? math.min(st, 1) : st
_stTxt(s) =>
    s == 2 ? 'naked' : s == 1 ? 'swept' : s == 0 ? 'broken' : ''
_stW(s) =>
    s == 2 ? i_w_naked : s == 1 ? i_w_swept : s == 0 ? i_w_broken : 1.0
// Gate for the raw pool. A broken level (state 0) is excluded at source when
// mitigation is on, so it disappears from drawing, weighting and gating in one
// place rather than three.
_dolKeep(s) =>
    not i_hide_broken or s != 0

kx_in_asia = kmins >= 1200 or kmins < 180
kx_in_lon = kmins >= 180 and kmins < 510
kx_in_on = kmins >= 1080 or kmins < 570

var float asiaH_cur = na
var float asiaL_cur = na
var float asiaH_prev = na
var float asiaL_prev = na
var float lonH_cur = na
var float lonL_cur = na
var float lonH_prev = na
var float lonL_prev = na
var float onH_cur = na
var float onL_cur = na
var float onH_prev = na
var float onL_prev = na
var int st_asiaH = 2
var int st_asiaL = 2
var int st_lonH = 2
var int st_lonL = 2
var int st_onH = 2
var int st_h4h = 2
var int st_h4l = 2
var int st_onL = 2
var int st_pdh = 2
var int st_pdl = 2
var int st_pwh = 2
var int st_pwl = 2
var int st_pmh = 2
var int st_pml = 2

if kx_in_asia and not kx_in_asia[1]
    asiaH_cur := high
    asiaL_cur := low
    asiaL_cur
else if kx_in_asia
    asiaH_cur := math.max(asiaH_cur, high)
    asiaL_cur := math.min(asiaL_cur, low)
    asiaL_cur
if not kx_in_asia and kx_in_asia[1]
    asiaH_prev := asiaH_cur
    asiaL_prev := asiaL_cur
    st_asiaH := 2
    st_asiaL := 2
    st_asiaL

if kx_in_lon and not kx_in_lon[1]
    lonH_cur := high
    lonL_cur := low
    lonL_cur
else if kx_in_lon
    lonH_cur := math.max(lonH_cur, high)
    lonL_cur := math.min(lonL_cur, low)
    lonL_cur
if not kx_in_lon and kx_in_lon[1]
    lonH_prev := lonH_cur
    lonL_prev := lonL_cur
    st_lonH := 2
    st_lonL := 2
    st_lonL

if kx_in_on and not kx_in_on[1]
    onH_cur := high
    onL_cur := low
    onL_cur
else if kx_in_on
    onH_cur := math.max(onH_cur, high)
    onL_cur := math.min(onL_cur, low)
    onL_cur
if not kx_in_on and kx_in_on[1]
    onH_prev := onH_cur
    onL_prev := onL_cur
    st_onH := 2
    st_onL := 2
    st_onL

newDay = ta.change(time('D')) != 0
newWk = ta.change(time('W')) != 0
newMonth = ta.change(time('M')) != 0
if newDay
    st_pdh := 2
    st_pdl := 2
    st_pdl
if newWk
    st_pwh := 2
    st_pwl := 2
    st_pwl
if newMonth
    st_pmh := 2
    st_pml := 2
    st_pml

st_pdh := _stH(pdh, st_pdh)
st_pdl := _stL(pdl, st_pdl)
st_pwh := _stH(pwh, st_pwh)
st_pwl := _stL(pwl, st_pwl)
st_pmh := _stH(pmh, st_pmh)
st_pml := _stL(pml, st_pml)
st_asiaH := _stH(asiaH_prev, st_asiaH)
st_asiaL := _stL(asiaL_prev, st_asiaL)
st_lonH := _stH(lonH_prev, st_lonH)
st_lonL := _stL(lonL_prev, st_lonL)
// New 4H candle retires the old prior-candle levels and arms the new pair.
new4h = ta.change(time('240')) != 0
if new4h
    st_h4h := 2
    st_h4l := 2
    st_h4l
st_h4h := _stH(h4h, st_h4h)
st_h4l := _stL(h4l, st_h4l)

st_onH := _stH(onH_prev, st_onH)
st_onL := _stL(onL_prev, st_onL)

// ============================================================
// === RAW LEVEL POOL ===
//   cP price | cK kind | cG isGamma | cS state | cR rank | cD dte | cW weight
//   cMag: normalised magnitude ratio for a wall, or -1 when unavailable.
//   Kept SEPARATE from cW deliberately. cW folds the ratio together with the
//   base wall weight and the DTE weight, so the ratio cannot be recovered from
//   it - and the ratio is what the width mapping needs.
//   Nothing in this array is ever overwritten or averaged. Clustering reads it
//   and produces a separate node list; constituents survive intact.
// ============================================================
var array<float> cP = array.new_float()
var array<string> cK = array.new_string()
var array<bool> cG = array.new_bool()
var array<int> cS = array.new_int()
var array<int> cR = array.new_int()
var array<string> cD = array.new_string()
var array<float> cW = array.new_float()
var array<float> cMag = array.new_float()
// Raw magnitude as pasted, before per-side normalisation. Needed because the
// ratio is computed within one side of one board, so a call ratio and a put
// ratio are not on the same scale and their difference means nothing.
var array<float> cRaw = array.new_float()
// Open interest, third value on a wall token. 0 when absent.
var array<float> cOI = array.new_float()

// merge-node arrays (one drawn line each)
var array<float> mP = array.new_float()
var array<float> mLo = array.new_float()
var array<float> mHi = array.new_float()
var array<float> mW = array.new_float()
var array<int> mCnt = array.new_int()
var array<bool> mHasG = array.new_bool()
var array<bool> mHasD = array.new_bool()
var array<int> mNCW = array.new_int()
var array<int> mNPW = array.new_int()
var array<string> mKind = array.new_string()
var array<int> mState = array.new_int()
var array<int> mRank = array.new_int()
var array<int> mConf = array.new_int()
// MAX magnitude ratio among the node's gamma constituents, or -1 if none
// carried one. Max rather than sum: this is a size statement about the
// strike, and summing across constituents would make it a count.
var array<float> mMag = array.new_float()
// Raw exposure summed per side on this node. Two boards holding call exposure
// at one strike is more total exposure at that strike, so these are sums where
// mMag is a max - different questions, different reductions.
var array<float> mRawCW = array.new_float()
var array<float> mRawPW = array.new_float()
var array<float> mOI = array.new_float()
// Numeric DOL kind, so an exported row says which level was touched rather
// than only that a DOL was present. 0 = gamma only.
var array<int> mKC = array.new_int()
// Call-dominant when net exposure at the strike is positive. Falls back to the
// constituent count only when no raw magnitudes were supplied, which is the
// one case where the count is the best available evidence.
_cwDominant(rcw, rpw, ncw, npw) =>
    rcw > 0 or rpw > 0 ? rcw >= rpw : ncw >= npw

// Bar length. Sqrt compresses a dominant wall so the rest stay legible; the
// ordering is preserved either way, only the spacing changes.
_barLen(v, mx, maxLen) =>
    _r = mx > 0 ? math.min(1.0, v / mx) : 0.0
    _r := i_bar_scale == 'Sqrt' ? math.sqrt(_r) : _r
    math.max(1, math.round(_r * maxLen))

_kcode(k) =>
    k == 'PDH' ? 1 : k == 'PDL' ? 2 : k == 'AsH' ? 3 : k == 'AsL' ? 4 : k == 'LoH' ? 5 : k == 'LoL' ? 6 : k == '4hH' ? 7 : k == '4hL' ? 8 : k == 'PWH' ? 9 : k == 'PWL' ? 10 : k == 'PMH' ? 11 : k == 'PML' ? 12 : k == 'ONH' ? 13 : k == 'ONL' ? 14 : 0
// count of DISTINCT enabled DTE boards contributing a wall to this node.
// 0 = no gamma, 1 = one board, >=2 = independent boards agree on the strike.
var array<int> mNDte = array.new_int()

// confluence-group aggregates
var array<float> gW = array.new_float()
var array<int> gN = array.new_int()
var array<bool> gBoth = array.new_bool()
var array<float> gLo = array.new_float()
var array<float> gHi = array.new_float()

var float _flip0 = na
var float _flip7 = na
var float _flip30 = na
// Aggregate exposure per board, from the optional N block. na = not supplied.
var float _net0 = na
var float _net7 = na
var float _net30 = na
var float _call0 = na
var float _put0 = na

// wall touch counters, keyed to the parsed wall list, reset when the string changes
var array<float> wP = array.new_float()
var array<int> wT = array.new_int()
var string _lastG = ''
var int _gTime = na

if gstr != _lastG
    _lastG := gstr
    _gTime := barstate.isrealtime ? timenow : int(na)
    array.clear(wP)
    array.clear(wT)

if array.size(wP) > 0
    for _ti = 0 to array.size(wP) - 1 by 1
        _tp = array.get(wP, _ti)
        _spanNow = high >= _tp and low <= _tp
        _spanPrev = high[1] >= _tp and low[1] <= _tp
        if _spanNow and not _spanPrev
            array.set(wT, _ti, array.get(wT, _ti) + 1)

// magnitude override lookup: returns normalised weight for sym/dte/side/rank.
// The ratio is me/top within the SAME side of the SAME board, so it is a
// statement about relative size on that list and nothing else. Cross-board
// and cross-side comparison is not implied and is not made anywhere.
_magW(sym, dte, side, rank) =>
    _w = float(na)
    if i_mag != ''
        _segs = str.split(i_mag, ';')
        if array.size(_segs) > 0
            for _si = 0 to array.size(_segs) - 1 by 1
                _pr = str.split(array.get(_segs, _si), ':')
                if array.size(_pr) >= 2
                    _hd = str.split(array.get(_pr, 0), '.')
                    if array.size(_hd) >= 2
                        if array.get(_hd, 0) == sym and array.get(_hd, 1) == dte
                            _bd = str.split(array.get(_pr, 1), '|')
                            if array.size(_bd) >= 2
                                _txt = side == 'CW' ? array.get(_bd, 0) : array.get(_bd, 1)
                                _vals = str.split(str.substring(_txt, 2), ',')
                                if array.size(_vals) > rank
                                    _top = str.tonumber(array.get(_vals, 0))
                                    _me = str.tonumber(array.get(_vals, rank))
                                    if not na(_top) and not na(_me) and _top > 0
                                        _w := _me / _top
                                        _w
    _w

// Largest inline magnitude on one side of one board. Returns 0 when no wall
// on that side carries an attached number, which is the signal to fall back
// to the separate override field. Absolute: the source panel signs put
// exposure negative and a negative ratio would invert every weight.
_inlineMax(arr) =>
    _mx = 0.0
    if array.size(arr) > 0
        for _i = 0 to array.size(arr) - 1 by 1
            _t = str.split(array.get(arr, _i), ':')
            if array.size(_t) >= 2
                _m = str.tonumber(array.get(_t, 1))
                if not na(_m)
                    _mx := math.max(_mx, math.abs(_m))
                    _mx
    _mx

// Rebuilt on the last bar only. The HTF gap feed used to supply two more
// rebuild triggers; with it gone, the level set is static between bars
// anyway - nothing in the pool changes intrabar except price-relative reads.
bool rebuildPool = barstate.islast

if rebuildPool
    array.clear(cP)
    array.clear(cK)
    array.clear(cG)
    array.clear(cS)
    array.clear(cR)
    array.clear(cD)
    array.clear(cW)
    array.clear(cMag)
    array.clear(cRaw)
    array.clear(cOI)
    _flip0 := na
    _flip7 := na
    _flip30 := na
    _net0 := na
    _net7 := na
    _net30 := na
    _call0 := na
    _put0 := na

    if i_dol
        if i_pd and not na(pdh) and _dolKeep(st_pdh)
            array.push(cP, pdh), array.push(cK, 'PDH'), array.push(cG, false), array.push(cS, st_pdh), array.push(cR, -1), array.push(cD, ''), array.push(cW, _stW(st_pdh)), array.push(cMag, -1.0), array.push(cRaw, 0.0), array.push(cOI, 0.0)
        if i_pd and not na(pdl) and _dolKeep(st_pdl)
            array.push(cP, pdl), array.push(cK, 'PDL'), array.push(cG, false), array.push(cS, st_pdl), array.push(cR, -1), array.push(cD, ''), array.push(cW, _stW(st_pdl)), array.push(cMag, -1.0), array.push(cRaw, 0.0), array.push(cOI, 0.0)
        if i_asia and not na(asiaH_prev) and _dolKeep(st_asiaH)
            array.push(cP, asiaH_prev), array.push(cK, 'AsH'), array.push(cG, false), array.push(cS, st_asiaH), array.push(cR, -1), array.push(cD, ''), array.push(cW, _stW(st_asiaH)), array.push(cMag, -1.0), array.push(cRaw, 0.0), array.push(cOI, 0.0)
        if i_asia and not na(asiaL_prev) and _dolKeep(st_asiaL)
            array.push(cP, asiaL_prev), array.push(cK, 'AsL'), array.push(cG, false), array.push(cS, st_asiaL), array.push(cR, -1), array.push(cD, ''), array.push(cW, _stW(st_asiaL)), array.push(cMag, -1.0), array.push(cRaw, 0.0), array.push(cOI, 0.0)
        if i_lon and not na(lonH_prev) and _dolKeep(st_lonH)
            array.push(cP, lonH_prev), array.push(cK, 'LoH'), array.push(cG, false), array.push(cS, st_lonH), array.push(cR, -1), array.push(cD, ''), array.push(cW, _stW(st_lonH)), array.push(cMag, -1.0), array.push(cRaw, 0.0), array.push(cOI, 0.0)
        if i_lon and not na(lonL_prev) and _dolKeep(st_lonL)
            array.push(cP, lonL_prev), array.push(cK, 'LoL'), array.push(cG, false), array.push(cS, st_lonL), array.push(cR, -1), array.push(cD, ''), array.push(cW, _stW(st_lonL)), array.push(cMag, -1.0), array.push(cRaw, 0.0), array.push(cOI, 0.0)
        if i_pw and not na(pwh) and _dolKeep(st_pwh)
            array.push(cP, pwh), array.push(cK, 'PWH'), array.push(cG, false), array.push(cS, st_pwh), array.push(cR, -1), array.push(cD, ''), array.push(cW, _stW(st_pwh)), array.push(cMag, -1.0), array.push(cRaw, 0.0), array.push(cOI, 0.0)
        if i_pw and not na(pwl) and _dolKeep(st_pwl)
            array.push(cP, pwl), array.push(cK, 'PWL'), array.push(cG, false), array.push(cS, st_pwl), array.push(cR, -1), array.push(cD, ''), array.push(cW, _stW(st_pwl)), array.push(cMag, -1.0), array.push(cRaw, 0.0), array.push(cOI, 0.0)
        if i_pm and not na(pmh) and _dolKeep(st_pmh)
            array.push(cP, pmh), array.push(cK, 'PMH'), array.push(cG, false), array.push(cS, st_pmh), array.push(cR, -1), array.push(cD, ''), array.push(cW, _stW(st_pmh)), array.push(cMag, -1.0), array.push(cRaw, 0.0), array.push(cOI, 0.0)
        if i_pm and not na(pml) and _dolKeep(st_pml)
            array.push(cP, pml), array.push(cK, 'PML'), array.push(cG, false), array.push(cS, st_pml), array.push(cR, -1), array.push(cD, ''), array.push(cW, _stW(st_pml)), array.push(cMag, -1.0), array.push(cRaw, 0.0), array.push(cOI, 0.0)
        if i_on and not na(onH_prev) and _dolKeep(st_onH)
            array.push(cP, onH_prev), array.push(cK, 'ONH'), array.push(cG, false), array.push(cS, st_onH), array.push(cR, -1), array.push(cD, ''), array.push(cW, _stW(st_onH)), array.push(cMag, -1.0), array.push(cRaw, 0.0), array.push(cOI, 0.0)
        if i_h4 and not na(h4h) and _dolKeep(st_h4h)
            array.push(cP, h4h), array.push(cK, '4hH'), array.push(cG, false), array.push(cS, st_h4h), array.push(cR, -1), array.push(cD, ''), array.push(cW, _stW(st_h4h)), array.push(cMag, -1.0), array.push(cRaw, 0.0), array.push(cOI, 0.0)
        if i_h4 and not na(h4l) and _dolKeep(st_h4l)
            array.push(cP, h4l), array.push(cK, '4hL'), array.push(cG, false), array.push(cS, st_h4l), array.push(cR, -1), array.push(cD, ''), array.push(cW, _stW(st_h4l)), array.push(cMag, -1.0), array.push(cRaw, 0.0), array.push(cOI, 0.0)
        if i_on and not na(onL_prev) and _dolKeep(st_onL)
            array.push(cP, onL_prev), array.push(cK, 'ONL'), array.push(cG, false), array.push(cS, st_onL), array.push(cR, -1), array.push(cD, ''), array.push(cW, _stW(st_onL)), array.push(cMag, -1.0), array.push(cRaw, 0.0), array.push(cOI, 0.0)

    _wallFresh = array.size(wP) == 0
    segs = str.split(gstr, ';')
    if array.size(segs) > 0
        for si = 0 to array.size(segs) - 1 by 1
            seg = array.get(segs, si)
            // v2.12.1 FIX: split on the FIRST colon only. str.split cuts on
            // EVERY colon, so index 1 was the text between the first and
            // second - fine while the only colon was the one after the DTE,
            // and silently destructive from 2.11 onward when magnitudes began
            // carrying their own. A segment then arrived as
            //   ES.0:F7749|N5.73,8.75,-3.01|CW7800
            // with the put list gone and the first call wall stripped of its
            // magnitude, which still passed the >= 3 field count and produced
            // no walls and no error.
            _cix = str.pos(seg, ':')
            if not na(_cix) and _cix > 0
                head = str.substring(seg, 0, _cix)
                body = str.substring(seg, _cix + 1)
                dpr = str.split(head, '.')
                if array.size(dpr) >= 2
                    sym = array.get(dpr, 0)
                    dte = array.get(dpr, 1)
                    if sym == chartSym
                        ppr = str.split(body, '|')
                        if array.size(ppr) >= 3
                            // v2.12: identify by prefix, not by index. The old
                            // positional read meant any new field would shift
                            // the wall lists and silently corrupt every string.
                            string cwp = ''
                            string pwp = ''
                            string npr = ''
                            float flip = na
                            for _fi = 0 to array.size(ppr) - 1 by 1
                                _fp = array.get(ppr, _fi)
                                if str.startswith(_fp, 'CW')
                                    cwp := _fp
                                    cwp
                                else if str.startswith(_fp, 'PW')
                                    pwp := _fp
                                    pwp
                                else if str.startswith(_fp, 'N')
                                    npr := _fp
                                    npr
                                else if str.startswith(_fp, 'F')
                                    flip := str.tonumber(str.substring(_fp, 1))
                                    flip
                            // N{net},{call},{put} in $B. Call and put are kept
                            // for the 0DTE board only - they are display detail
                            // and nothing downstream reads them per expiry.
                            if npr != ''
                                _nv = str.split(str.substring(npr, 1), ',')
                                if array.size(_nv) >= 1
                                    _nn = str.tonumber(array.get(_nv, 0))
                                    if dte == '0'
                                        _net0 := _nn
                                        _net0
                                    else if dte == '7'
                                        _net7 := _nn
                                        _net7
                                    else if dte == '30'
                                        _net30 := _nn
                                        _net30
                                if array.size(_nv) >= 3 and dte == '0'
                                    _call0 := str.tonumber(array.get(_nv, 1))
                                    _put0 := str.tonumber(array.get(_nv, 2))
                                    _put0
                            if dte == '0'
                                _flip0 := flip
                                _flip0
                            else if dte == '7'
                                _flip7 := flip
                                _flip7
                            else if dte == '30'
                                _flip30 := flip
                                _flip30
                            if _dteOn(dte) and cwp != '' and pwp != ''
                                cwArr = str.split(str.substring(cwp, 2), ',')
                                _cwMax = _inlineMax(cwArr)
                                if array.size(cwArr) > 0
                                    for wi = 0 to array.size(cwArr) - 1 by 1
                                        _tokC = str.split(array.get(cwArr, wi), ':')
                                        v = str.tonumber(array.get(_tokC, 0))
                                        _inlC = array.size(_tokC) >= 2 ? str.tonumber(array.get(_tokC, 1)) : float(na)
                                        _oiC = array.size(_tokC) >= 3 ? str.tonumber(array.get(_tokC, 2)) : float(na)
                                        // rank is zero-based here: wi 0 is r1.
                                        // v2.10: the magnitude ratio is now
                                        // resolved BEFORE the admission test,
                                        // because it is one of the two things
                                        // that can admit a wall. The rank cut
                                        // is a floor; the ratio is a second,
                                        // independent door. With the field
                                        // blank _mw is na, the second test
                                        // cannot pass, and admission is the
                                        // rank cut alone - pre-2.10 behaviour.
                                        _mw = not na(_inlC) and _cwMax > 0 ? math.abs(_inlC) / _cwMax : _magW(sym, dte, 'CW', wi)
                                        _keep = not na(v) and (wi < i_max_rank or not na(_mw) and _mw >= i_mag_keep)
                                        if _keep
                                            _ww = (na(_mw) ? i_w_wall : i_w_wall * _mw) * _dteW(dte)
                                            array.push(cP, v), array.push(cK, 'CW'), array.push(cG, true), array.push(cS, -1), array.push(cR, wi), array.push(cD, dte), array.push(cW, _ww), array.push(cMag, na(_mw) ? -1.0 : _mw), array.push(cRaw, na(_inlC) ? 0.0 : math.abs(_inlC)), array.push(cOI, na(_oiC) ? 0.0 : _oiC)
                                            if _wallFresh
                                                array.push(wP, v), array.push(wT, 0)
                                pwArr = str.split(str.substring(pwp, 2), ',')
                                _pwMax = _inlineMax(pwArr)
                                if array.size(pwArr) > 0
                                    for wi = 0 to array.size(pwArr) - 1 by 1
                                        _tokP = str.split(array.get(pwArr, wi), ':')
                                        v = str.tonumber(array.get(_tokP, 0))
                                        _inlP = array.size(_tokP) >= 2 ? str.tonumber(array.get(_tokP, 1)) : float(na)
                                        _oiP = array.size(_tokP) >= 3 ? str.tonumber(array.get(_tokP, 2)) : float(na)
                                        _mw = not na(_inlP) and _pwMax > 0 ? math.abs(_inlP) / _pwMax : _magW(sym, dte, 'PW', wi)
                                        _keep = not na(v) and (wi < i_max_rank or not na(_mw) and _mw >= i_mag_keep)
                                        if _keep
                                            _ww = (na(_mw) ? i_w_wall : i_w_wall * _mw) * _dteW(dte)
                                            array.push(cP, v), array.push(cK, 'PW'), array.push(cG, true), array.push(cS, -1), array.push(cR, wi), array.push(cD, dte), array.push(cW, _ww), array.push(cMag, na(_mw) ? -1.0 : _mw), array.push(cRaw, na(_inlP) ? 0.0 : math.abs(_inlP)), array.push(cOI, na(_oiP) ? 0.0 : _oiP)
                                            if _wallFresh
                                                array.push(wP, v), array.push(wT, 0)

    _np = array.size(cP)
    // ---------- MERGE PASS ----------
    // Sorted linear grouping. Fixes the v2.1 seed/collect asymmetry that dropped
    // chained levels: A~B and B~C now group together even when A and C are apart.
    array.clear(mP), array.clear(mLo), array.clear(mHi), array.clear(mW)
    array.clear(mCnt), array.clear(mHasG), array.clear(mHasD)
    array.clear(mNCW), array.clear(mNPW), array.clear(mKind)
    array.clear(mState), array.clear(mRank), array.clear(mConf), array.clear(mKC)
    array.clear(mNDte), array.clear(mMag), array.clear(mRawCW), array.clear(mRawPW), array.clear(mOI)

    if _np > 0
        _mtol = i_merge_ticks * syminfo.mintick
        _idx = array.sort_indices(cP, order.ascending)
        _sum = 0.0
        _cnt = 0
        _wsum = 0.0
        _lo = 0.0
        _hi = 0.0
        _hg = false
        _hd = false
        _ncw = 0
        _npw = 0
        _kd = ''
        _stB = 3
        _rkB = 9
        _kcB = 99
        _mgB = -1.0
        _rcw = 0.0
        _rpw = 0.0
        _oiN = 0.0
        _prev = 0.0
        // Pine has no bitwise ops, so distinct-board presence is three flags
        // rather than a mask. Counted at each push site.
        _d0 = false
        _d7 = false
        _d30 = false
        for _k = 0 to _np - 1 by 1
            _i = array.get(_idx, _k)
            _p = array.get(cP, _i)
            _break = _k > 0 and _p - _prev > _mtol
            if _break
                array.push(mP, math.round(_sum / _cnt / syminfo.mintick) * syminfo.mintick), array.push(mLo, _lo), array.push(mHi, _hi)
                array.push(mW, _wsum), array.push(mCnt, _cnt)
                array.push(mHasG, _hg), array.push(mHasD, _hd)
                array.push(mNCW, _ncw), array.push(mNPW, _npw), array.push(mKind, _kd)
                array.push(mState, _stB == 3 ? -1 : _stB), array.push(mRank, _rkB == 9 ? -1 : _rkB)
                array.push(mConf, -1)
                array.push(mKC, _kcB == 99 ? 0 : _kcB)
                array.push(mNDte, (_d0 ? 1 : 0) + (_d7 ? 1 : 0) + (_d30 ? 1 : 0))
                array.push(mMag, _mgB), array.push(mRawCW, _rcw), array.push(mRawPW, _rpw), array.push(mOI, _oiN)
                _sum := 0.0, _cnt := 0, _wsum := 0.0, _hg := false, _hd := false
                _ncw := 0, _npw := 0, _kd := '', _stB := 3, _rkB := 9, _kcB := 99
                _mgB := -1.0
                _rcw := 0.0
                _rpw := 0.0
                _oiN := 0.0
                _d0 := false, _d7 := false, _d30 := false
                _lo := _p, _hi := _p
                _hi
            if _k == 0
                _lo := _p
                _hi := _p
                _hi
            _sum := _sum + _p
            _cnt := _cnt + 1
            _wsum := _wsum + array.get(cW, _i)
            _lo := math.min(_lo, _p)
            _hi := math.max(_hi, _p)
            _gb = array.get(cG, _i)
            _oiN := _oiN + array.get(cOI, _i)
            _hg := _hg or _gb
            _hd := _hd or not _gb
            if _gb
                _dd = array.get(cD, _i)
                _d0 := _d0 or _dd == '0'
                _d7 := _d7 or _dd == '7'
                _d30 := _d30 or _dd == '30'
                // MAX, not sum. A strike carrying a 0.72 call leg and a 0.32
                // put leg is a 0.72-sized strike that happens to be two-sided,
                // not a 1.04-sized one. Two-sidedness is carried by mNCW /
                // mNPW, which is where the pin condition reads it.
                _mgB := math.max(_mgB, array.get(cMag, _i))
                _mgB
            _kb0 = array.get(cK, _i)
            // walls carry their DTE so a bare rank is not ambiguous when more
            // than one board is enabled
            _kb = _gb ? _kb0 + '.' + array.get(cD, _i) : _kb0
            if _kb0 == 'CW'
                _ncw := _ncw + 1
                _rcw := _rcw + array.get(cRaw, _i)
                _rcw
            if _kb0 == 'PW'
                _npw := _npw + 1
                _rpw := _rpw + array.get(cRaw, _i)
                _rpw
            _kd := _kd == '' ? _kb : str.contains(_kd, _kb) ? _kd : _kd + '/' + _kb
            _sb = array.get(cS, _i)
            if _sb >= 0
                _stB := math.min(_stB, _sb)
                _stB
            _rb = array.get(cR, _i)
            if _rb >= 0
                _rkB := math.min(_rkB, _rb)
                _rkB
            _kcv = _kcode(_kb0)
            if _kcv > 0
                _kcB := math.min(_kcB, _kcv)
                _kcB
            _prev := _p
            _prev
        array.push(mP, math.round(_sum / _cnt / syminfo.mintick) * syminfo.mintick), array.push(mLo, _lo), array.push(mHi, _hi)
        array.push(mW, _wsum), array.push(mCnt, _cnt)
        array.push(mHasG, _hg), array.push(mHasD, _hd)
        array.push(mNCW, _ncw), array.push(mNPW, _npw), array.push(mKind, _kd)
        array.push(mState, _stB == 3 ? -1 : _stB), array.push(mRank, _rkB == 9 ? -1 : _rkB)
        array.push(mConf, -1)
        array.push(mKC, _kcB == 99 ? 0 : _kcB)
        array.push(mNDte, (_d0 ? 1 : 0) + (_d7 ? 1 : 0) + (_d30 ? 1 : 0))
        array.push(mMag, _mgB), array.push(mRawCW, _rcw), array.push(mRawPW, _rpw), array.push(mOI, _oiN)

    // ---------- CONFLUENCE PASS ----------
    // Assigns a group id. Does NOT merge - every node keeps its own price.
    array.clear(gW), array.clear(gN), array.clear(gBoth), array.clear(gLo), array.clear(gHi)
    _nm = array.size(mP)
    if _nm > 0
        _ctol = i_confl_atr * atr_tol
        _gid = 0
        _grpMin = array.get(mP, 0)
        array.set(mConf, 0, 0)
        array.push(gW, array.get(mW, 0)), array.push(gN, 1)
        array.push(gBoth, array.get(mHasG, 0) and array.get(mHasD, 0))
        array.push(gLo, array.get(mLo, 0)), array.push(gHi, array.get(mHi, 0))
        if _nm > 1
            for _j = 1 to _nm - 1 by 1
                _pj = array.get(mP, _j)
                // complete linkage: measured against the group's LOWEST member,
                // not the previous node. Caps total group span at _ctol. Single
                // linkage let a chain of near-neighbours span several radii.
                if _pj - _grpMin > _ctol
                    _gid := _gid + 1
                    _grpMin := _pj
                    array.push(gW, 0.0), array.push(gN, 0), array.push(gBoth, false)
                    array.push(gLo, _pj), array.push(gHi, _pj)
                array.set(mConf, _j, _gid)
                array.set(gW, _gid, array.get(gW, _gid) + array.get(mW, _j))
                array.set(gN, _gid, array.get(gN, _gid) + 1)
                array.set(gLo, _gid, math.min(array.get(gLo, _gid), array.get(mLo, _j)))
                array.set(gHi, _gid, math.max(array.get(gHi, _gid), array.get(mHi, _j)))
                _hasG = false
                _hasD = false
                for _z = 0 to _nm - 1 by 1
                    if array.get(mConf, _z) == _gid
                        _hasG := _hasG or array.get(mHasG, _z)
                        _hasD := _hasD or array.get(mHasD, _z)
                        _hasD
                array.set(gBoth, _gid, _hasG and _hasD)

// ============================================================
// === EXTREME / NEAREST WALLS ===
//   Extreme = outermost unbroken wall on each side. This is the boundary a
//   draw has to clear, which is what the fade target and stop reference need.
//   Deliberately NOT the highest-magnitude wall: at 0DTE gamma-per-contract
//   peaks at spot, so the top-ranked wall is mostly the nearest one.
// ============================================================
var float x_extCeil = na
var float x_extFloor = na
var float x_nearCeil = na
var float x_nearFloor = na
var float x_nearCeilW = na
var float x_nearFloorW = na
var int x_confl = 0
var int x_align = 0
// board-wide maxima for bar scaling; declared here because the extremes
// pass below assigns them
var float x_maxRaw = na
var float x_maxOI = na
var int x_nearCeilT = 0
var int x_nearFloorT = 0
// v2.10 diagnostic: how many nodes were admitted on magnitude that the rank
// cut alone would have dropped. Zero means the threshold is doing nothing,
// which is either a quiet board or a threshold set too high.
var int x_magAdmit = 0

if rebuildPool
    x_extCeil := na
    x_extFloor := na
    x_nearCeil := na
    x_nearFloor := na
    x_nearCeilW := na
    x_nearFloorW := na
    x_confl := 0
    x_align := 0
    x_maxRaw := na
    x_maxOI := na
    x_magAdmit := 0
    _nm2 = array.size(mP)
    if _nm2 > 0
        for _j = 0 to _nm2 - 1 by 1
            _pj = array.get(mP, _j)
            if array.get(mHasG, _j)
                if _pj > close
                    x_extCeil := na(x_extCeil) ? _pj : math.max(x_extCeil, _pj)
                    if na(x_nearCeil) or _pj < x_nearCeil
                        x_nearCeil := _pj
                        x_nearCeilW := array.get(mW, _j)
                        x_nearCeilW
                // <= so a level the price is resting on is still reported as the
                // floor. Strict comparison dropped it from both sides.
                if _pj <= close
                    x_extFloor := na(x_extFloor) ? _pj : math.min(x_extFloor, _pj)
                    if na(x_nearFloor) or _pj > x_nearFloor
                        x_nearFloor := _pj
                        x_nearFloorW := array.get(mW, _j)
                        x_nearFloorW
                // a node whose best rank is beyond the rank cut only got here
                // through the magnitude door
                if array.get(mRank, _j) >= i_max_rank
                    x_magAdmit := x_magAdmit + 1
                    x_magAdmit
            if array.get(mHasG, _j)
                // one scale for both exposure bars so their lengths compare;
                // OI on its own, because contracts and dollars are not the
                // same unit and a shared axis would imply they were
                float _rc = array.get(mRawCW, _j)
                float _rp = array.get(mRawPW, _j)
                float _oi = array.get(mOI, _j)
                x_maxRaw := na(x_maxRaw) ? math.max(_rc, _rp) : math.max(x_maxRaw, math.max(_rc, _rp))
                x_maxOI := na(x_maxOI) ? _oi : math.max(x_maxOI, _oi)
            if array.get(mHasG, _j) and array.get(mNDte, _j) >= 2
                x_align := x_align + 1
                x_align
            _cgj = array.get(mConf, _j)
            if _cgj >= 0 and _cgj < array.size(gBoth)
                if array.get(gBoth, _cgj) and array.get(mHasG, _j)
                    x_confl := x_confl + 1
                    x_confl
    x_nearCeilT := 0
    x_nearFloorT := 0
    if array.size(wP) > 0
        for _ti = 0 to array.size(wP) - 1 by 1
            _tp = array.get(wP, _ti)
            if not na(x_nearCeil) and math.abs(_tp - x_nearCeil) <= i_merge_ticks * syminfo.mintick
                x_nearCeilT := math.max(x_nearCeilT, array.get(wT, _ti))
                x_nearCeilT
            if not na(x_nearFloor) and math.abs(_tp - x_nearFloor) <= i_merge_ticks * syminfo.mintick
                x_nearFloorT := math.max(x_nearFloorT, array.get(wT, _ti))
                x_nearFloorT

// ============================================================
// === REGIME RESOLUTION ===
//   flip side and net exposure sign are two readings of the same thing and can
//   disagree. Net exposure is the underlying quantity; flip side is a summary.
// ============================================================
// String-supplied 0DTE exposure wins over the manual field, which wins over
// nothing. The manual field carried no expiry, so whichever board was on
// screen when it was typed became the regime input for the entire chart.
_netEff = not na(_net0) ? _net0 : i_netgex
_callEff = not na(_call0) ? _call0 : i_callgex
_putEff = not na(_put0) ? _put0 : i_putgex
_netOn = not na(_netEff) and _netEff != 0.0
_regFlip = na(_flip0) ? 0 : regClose > _flip0 ? 1 : -1
_regNet = _netOn ? (_netEff > 0 ? 1 : -1) : 0
_useNet = i_reg_src == 'Net GEX' or i_reg_src == 'Auto' and _netOn
regSig = _useNet ? _regNet : _regFlip
regSrc = _useNet ? 'net' : 'flip'
regSplit = _netOn and _regNet != 0 and _regFlip != 0 and _regNet != _regFlip
// Sign disagreement ACROSS expiries. A single net figure cannot show this,
// and a 0DTE board that has flipped against the longer boards is a different
// day from one where all three agree.
_sgn(x) => na(x) ? 0 : x > 0 ? 1 : -1
_dteSplit = (_sgn(_net0) != 0 and _sgn(_net7) != 0 and _sgn(_net0) != _sgn(_net7)) or (_sgn(_net0) != 0 and _sgn(_net30) != 0 and _sgn(_net0) != _sgn(_net30))

// ============================================================
// === DRAWING ===
// ============================================================
var array<float> lblP = array.new_float()
var array<int> lblC = array.new_int()
// label collision solver: lowest free column such that no placed label within
// gap uses it. Cleared once per draw pass.
_place(p, gap) =>
    _col = 0
    for _try = 0 to 12 by 1
        _free = true
        if array.size(lblP) > 0
            for _q = 0 to array.size(lblP) - 1 by 1
                if array.get(lblC, _q) == _try and math.abs(array.get(lblP, _q) - p) < gap
                    _free := false
                    break
        if _free
            _col := _try
            break
    array.push(lblP, p)
    array.push(lblC, _col)
    _col

var array<line> glines = array.new_line()
var array<label> glabels = array.new_label()
var array<box> gboxes = array.new_box()
// largest-wall box state, carried across bars. *_px is the level the box
// sits on; *_recl is whether price has closed through it (reclaimed).
var float cwbox_px = na
var bool cwbox_recl = false
var float pwbox_px = na
var bool pwbox_recl = false
// selection scores, kept for export - the harvester needs to know how strong
// the boxed level was, not only where it sat.
var float cwbox_sc = na
var float x_domNet = na
var float pwbox_sc = na

// ---- boxed CW/PW state machine (every bar) ----
// Selects one call wall above price and one put wall below to carry a state box.
//
// Score = alignment bonus x rank multiplier.
//
//   alignment : mNDte is the count of DISTINCT enabled boards holding a wall at
//               this merge node. Independent expiries landing on the same strike
//               is the strongest ranking evidence the export string carries, and
//               unlike magnitude it needs no extra paste to compute.
//   rank      : mRank is the best (lowest) rank among the node's constituents.
//               It is emitted per board, so it is NOT comparable across boards -
//               a 30DTE r1 and a 0DTE r1 are both 0. That is why it is applied
//               as a small multiplier and not as the sort key. The v2.4.0
//               selection used it as the sort key, which let a distant 30DTE
//               wall displace a live 0DTE one.
if i_bignb
    float _bestCW = na
    float _bestCWs = -1.0
    float _bestPW = na
    float _bestPWs = -1.0
    int _nb = array.size(mP)
    if _nb > 0
        for _bi = 0 to _nb - 1 by 1
            if array.get(mHasG, _bi)
                float _bp = array.get(mP, _bi)
                int _br = array.get(mRank, _bi)
                // no rank parsed (Price mode) is treated as worst rank, not as
                // an exclusion - the wall is still a level.
                int _rr = _br < 0 ? 2 : _br
                int _nd = array.get(mNDte, _bi)
                int _ndc = _nd < 1 ? 1 : _nd
                float _rmul = math.max(0.05, 1.0 - i_rank_decay * _rr)
                float _amul = 1.0 + i_align_bonus * (_ndc - 1)
                // Magnitude mode scores on the node summed weight, which is
                // where the pasted dollar magnitudes land. With i_mag blank
                // that weight is flat and mW degenerates to a crude board
                // count, so the mode falls back rather than pretending.
                float _sc = _magOn and i_box_mode == 'Magnitude' ? array.get(mW, _bi) : i_box_mode == 'Rank only' ? _rmul : _amul * _rmul
                bool _cwDom = _cwDominant(array.get(mRawCW, _bi), array.get(mRawPW, _bi), array.get(mNCW, _bi), array.get(mNPW, _bi))
                if _bp > close and _cwDom and _sc > _bestCWs
                    _bestCWs := _sc
                    _bestCW := _bp
                    _bestCW
                if _bp <= close and not _cwDom and _sc > _bestPWs
                    _bestPWs := _sc
                    _bestPW := _bp
                    _bestPW
    cwbox_sc := _bestCWs < 0 ? float(na) : _bestCWs
    x_domNet := na
    if not na(_bestCW) and _nb > 0
        for _xi = 0 to _nb - 1 by 1
            if math.abs(array.get(mP, _xi) - _bestCW) < syminfo.mintick / 2
                x_domNet := array.get(mRawCW, _xi) - array.get(mRawPW, _xi)
                x_domNet
    pwbox_sc := _bestPWs < 0 ? float(na) : _bestPWs
    // CW box: if the target level changed, reset its reclaim state.
    if not na(_bestCW) and (na(cwbox_px) or math.abs(_bestCW - cwbox_px) > syminfo.mintick / 2)
        cwbox_px := _bestCW
        cwbox_recl := false
        cwbox_recl
    // reclaim / un-reclaim on CLOSE relative to the box level
    if not na(cwbox_px) and barstate.isconfirmed
        if close > cwbox_px
            cwbox_recl := true
            cwbox_recl
        else if close < cwbox_px
            cwbox_recl := false
            cwbox_recl
    // PW box likewise
    if not na(_bestPW) and (na(pwbox_px) or math.abs(_bestPW - pwbox_px) > syminfo.mintick / 2)
        pwbox_px := _bestPW
        pwbox_recl := false
        pwbox_recl
    if not na(pwbox_px) and barstate.isconfirmed
        if close < pwbox_px
            pwbox_recl := true
            pwbox_recl
        else if close > pwbox_px
            pwbox_recl := false
            pwbox_recl

if barstate.islast
    if array.size(glines) > 0
        for gi = 0 to array.size(glines) - 1 by 1
            line.delete(array.get(glines, gi))
    if array.size(glabels) > 0
        for gi = 0 to array.size(glabels) - 1 by 1
            label.delete(array.get(glabels, gi))
    if array.size(gboxes) > 0
        for gi = 0 to array.size(gboxes) - 1 by 1
            box.delete(array.get(gboxes, gi))
    array.clear(glines)
    array.clear(glabels)
    array.clear(gboxes)
    array.clear(lblP)
    array.clear(lblC)
    _lblgap = i_lbl_gap * atr_tol
    // Lanes across the offset region, left to right:
    //   lines/bands end at i_lbl_pad | bars | gradient band | labels
    // Each starts where the previous ends, so nothing is drawn inside
    // anything else and a bar reads as a measurement of its line rather
    // than as part of it.
    int _laneBar = bar_index + i_lbl_pad + i_lane_gap
    int _laneDens = _laneBar + (i_mag_bars ? i_bar_len + 3 : 0)
    int _laneLbl = _laneDens + (i_dens ? i_dens_w + 3 : 0)

    // one line per merge node, at its true price
    _nd = array.size(mP)
    if _nd > 0
        for _j = 0 to _nd - 1 by 1
            _pj = array.get(mP, _j)
            _hg = array.get(mHasG, _j)
            _cgj = array.get(mConf, _j)
            _both = _cgj >= 0 and _cgj < array.size(gBoth) ? array.get(gBoth, _cgj) : false
            _ncw = array.get(mNCW, _j)
            _npw = array.get(mNPW, _j)
            _above = _pj > close
            _isExtC = not na(x_extCeil) and math.abs(_pj - x_extCeil) < syminfo.mintick / 2
            _isExtF = not na(x_extFloor) and math.abs(_pj - x_extFloor) < syminfo.mintick / 2

            // Role follows the sign convention in the source data, not position
            // alone. Call strikes are taken to be long dealer gamma, so they
            // absorb: resistance above price, support below. Put strikes are
            // taken to be short dealer gamma, so hedging there amplifies and
            // price passes through - no support or resistance claim is made.
            _tag = ''
            if _hg and i_role_mode != 'Off' and i_lbl_role
                _cwDom = _ncw > _npw
                _pwDom = _npw > _ncw
                if _cwDom
                    _tag := _above ? ' [resistance]' : ' [support]'
                    _tag
                else if _pwDom
                    _tag := i_role_mode == 'Training wheels' ? ' [amplifies]' : ''
                    _tag
                else if _ncw > 0 and _npw > 0 and i_mag != ''
                    // a count tie only means balance when magnitudes broke it
                    _tag := ' [pin]'
                    _tag
            // Extreme naming is positional. These are the last walls on each
            // side, which is a boundary statement, not a role statement.
            if _isExtC and i_lbl_role
                _tag := ' [OUTERMOST ABOVE]'
                _tag
            if _isExtF and i_lbl_role
                _tag := ' [OUTERMOST BELOW]'
                _tag

            _stj = array.get(mState, _j)
            _rkj = array.get(mRank, _j)
            _ndj = array.get(mNDte, _j)
            _mgj = array.get(mMag, _j)
            // Label content is built from the detail setting rather than
            // always carrying everything. State, rank and the confluence star
            // are all still computed, scored and exported - this governs the
            // text only.
            _stx = i_lbl_detail == 'Full' and _stj >= 0 ? ' ' + _stTxt(_stj) : ''
            _rkx = i_lbl_detail == 'Full' and i_rank_mode == 'Magnitude' and _rkj >= 0 ? ' r' + str.tostring(_rkj + 1) : ''
            _cfx = i_lbl_detail == 'Full' and _both and _hg ? ' *' : ''
            _pxx = i_lbl_detail == 'Name only' or i_lbl_detail == 'Compact' ? '' : ' ' + str.tostring(_pj, format.mintick)

            // three-way colour: a node with no gamma is a pure DOL / liquidity
            // level (PDH, PDL, AsH, AsL, ...) and takes the DOL colour. A node
            // that carries gamma is a wall, coloured by type - call walls red,
            // put walls green, a mixed node by its dominant count (tie -> CW).
            _hasD = array.get(mHasD, _j)
            _rcwj = array.get(mRawCW, _j)
            _rpwj = array.get(mRawPW, _j)
            _netx = i_lbl_detail == 'Full' and _hg and (_rcwj > 0 or _rpwj > 0) ? '  net ' + (_rcwj - _rpwj >= 0 ? '+' : '') + str.tostring(_rcwj - _rpwj, '#') : ''
            _col = not _hg ? col_dol : _cwDominant(_rcwj, _rpwj, _ncw, _npw) ? col_cw : col_pw
            // v2.10: wall width carries size. Floor is 2, so no wall draws
            // thinner than pre-2.10 and the 2-vs-1 wall / DOL distinction is
            // untouched. Ratio mapping when magnitudes exist; rank mapping
            // when they do not; flat 2 when the toggle is off.
            _wid = 1
            if _hg
                _wid := 2
                if i_mag_width
                    if _mgj >= 0
                        _wid := _mgj >= i_mag_w_hi ? 4 : _mgj >= i_mag_w_mid ? 3 : 2
                    else if _rkj == 0
                        _wid := 3
            _lx = _laneLbl + _place(_pj, _lblgap) * i_stagger
            // multi-DTE alignment box: drawn before the line so the line sits on top
            if i_tier2 and _hg and _ndj >= 2
                float _t2h = syminfo.mintick * i_t2_ticks
                // opacity carries the board count: two boards render faint,
                // five render solid. v2.4.1 drew every aligned node at one
                // opacity, so a two-board node and a five-board node were
                // visually identical.
                int _t2op = math.max(0, 70 - (_ndj - 2) * 18)
                color _t2c = color.new(col_tier2, _t2op)
                array.push(gboxes, box.new(math.max(0, bar_index - 1500), _pj + _t2h, bar_index + i_lbl_pad, _pj - _t2h, xloc = xloc.bar_index, bgcolor = _t2c, border_color = _t2c, border_width = 1))
            if i_lvl_render == 'Band'
                // Band half-height carries magnitude, same ratio the line
                // width uses. Floored by i_band_min so a marginal wall stays
                // legible instead of collapsing to a hairline.
                float _bscale = 1.0
                if i_mag_width and _hg
                    _bscale := _mgj >= 0 ? math.max(i_band_min, _mgj) : _rkj == 0 ? 1.0 : math.max(i_band_min, 0.6)
                float _bh2 = syminfo.mintick * i_band_ticks * _bscale
                color _bc2 = color.new(_col, i_band_op)
                array.push(gboxes, box.new(math.max(0, bar_index - 1500), _pj + _bh2, bar_index + i_lbl_pad, _pj - _bh2, xloc = xloc.bar_index, bgcolor = _bc2, border_color = color.new(_col, math.max(0, i_band_op - 30)), border_width = 1))
            else
                array.push(glines, line.new(bar_index - 1, _pj, bar_index + i_lbl_pad, _pj, xloc = xloc.bar_index, extend = extend.left, color = color.new(_col, 0), width = _wid, style = _lsty(i_lvl_sty)))
            // a node carrying both a wall and a DOL draws the DOL as its own
            // mark, so liquidity is never hidden inside a wall
            // v2.11 FIX: this used to be gated on i_lvl_render != 'Band', so a
            // DOL folded into a wall drew nothing at all in Band mode and the
            // 2.3 rule - liquidity is never hidden inside a wall - held in one
            // render mode and was silently broken in the other. Drawn after the
            // band so it sits on top of the fill, at width 2 there to read
            // against it.
            if _hg and _hasD
                array.push(glines, line.new(bar_index - 1, _pj, bar_index + i_lbl_pad, _pj, xloc = xloc.bar_index, extend = extend.left, color = color.new(col_dol, 0), width = i_lvl_render == 'Band' ? 2 : 1, style = line.style_dashed))
            // Magnitude bar. Lives strictly between the last bar and the
            // label column, both of which are already reserved, so it cannot
            // collide with price or with the text. Gamma nodes only - a DOL
            // has no magnitude and a zero-length bar would read as one.
            // Up to three stacked bars: call exposure, put exposure, open
            // interest. Drawn only for what the node actually has, so a
            // one-sided strike shows one bar rather than a zero-length stub.
            if i_mag_bars and _hg
                float _bh = i_bar_h_mode == 'Visible range' and not na(_visRange) and _visRange > 0 ? _visRange * i_bar_vis : i_bar_h_mode == 'Chart ATR' ? _catr * i_bar_atr : syminfo.mintick * i_bar_ticks
                bool _anyRaw = (_rcwj > 0 or _rpwj > 0) and not na(x_maxRaw) and x_maxRaw > 0
                float _oij = array.get(mOI, _j)
                bool _anyOI = _oij > 0 and not na(x_maxOI) and x_maxOI > 0
                int _mid = _laneBar + math.round(i_bar_len / 2.0)
                int _half = math.max(2, math.round(i_bar_len / 2.0))
                // connector: ties the bar back to the line it measures
                if i_bar_axis and (_anyRaw or _anyOI)
                    array.push(glines, line.new(bar_index + i_lbl_pad, _pj, i_bar_style == 'Diverging' and _rpwj > 0 ? _mid - _barLen(_rpwj, x_maxRaw, _half) : _laneBar, _pj, xloc = xloc.bar_index, color = color.new(_col, 72), width = 1, style = line.style_dotted))
                if _anyRaw and i_bar_style == 'Diverging'
                    if _rcwj > 0
                        color _c = color.new(col_cw, i_bar_op)
                        array.push(gboxes, box.new(_mid, _pj + _bh, _mid + _barLen(_rcwj, x_maxRaw, _half), _pj - _bh, xloc = xloc.bar_index, bgcolor = _c, border_color = _c, border_width = 1))
                    if _rpwj > 0
                        color _c = color.new(col_pw, i_bar_op)
                        array.push(gboxes, box.new(_mid - _barLen(_rpwj, x_maxRaw, _half), _pj + _bh, _mid, _pj - _bh, xloc = xloc.bar_index, bgcolor = _c, border_color = _c, border_width = 1))
                    if _anyOI
                        // half height, directly beneath: supporting evidence,
                        // not a third reading of equal weight
                        color _c = color.new(col_oi, i_bar_op + 15 > 95 ? 95 : i_bar_op + 15)
                        array.push(gboxes, box.new(_mid, _pj - _bh, _mid + _barLen(_oij, x_maxOI, _half), _pj - _bh * 1.55, xloc = xloc.bar_index, bgcolor = _c, border_color = _c, border_width = 1))
                else if _anyRaw
                    float _y = _pj + _bh
                    if _rcwj > 0
                        color _c = color.new(col_cw, i_bar_op)
                        array.push(gboxes, box.new(_laneBar, _y, _laneBar + _barLen(_rcwj, x_maxRaw, i_bar_len), _y - _bh, xloc = xloc.bar_index, bgcolor = _c, border_color = _c, border_width = 1))
                        _y := _y - _bh
                        _y
                    if _rpwj > 0
                        color _c = color.new(col_pw, i_bar_op)
                        array.push(gboxes, box.new(_laneBar, _y, _laneBar + _barLen(_rpwj, x_maxRaw, i_bar_len), _y - _bh, xloc = xloc.bar_index, bgcolor = _c, border_color = _c, border_width = 1))
                        _y := _y - _bh
                        _y
                    if _anyOI
                        color _c = color.new(col_oi, i_bar_op + 15 > 95 ? 95 : i_bar_op + 15)
                        array.push(gboxes, box.new(_laneBar, _y, _laneBar + _barLen(_oij, x_maxOI, i_bar_len), _y - _bh * 0.55, xloc = xloc.bar_index, bgcolor = _c, border_color = _c, border_width = 1))
                else if _mgj >= 0
                    color _c = color.new(_col, i_bar_op)
                    array.push(gboxes, box.new(_laneBar, _pj + _bh, _laneBar + _barLen(_mgj, 1.0, i_bar_len), _pj - _bh, xloc = xloc.bar_index, bgcolor = _c, border_color = _c, border_width = 1))
            // Grouped by side in every mode. Compact goes further and drops the
            // expiries entirely, which is worth having when several boards
            // agree and the only thing you need off the chart is that they do.
            string _kindTxt = _fmtKind(array.get(mKind, _j))
            if i_lbl_detail == 'Compact' and _hg
                string _sides = (_ncw > 0 ? 'C' : '') + (_ncw > 0 and _npw > 0 ? '/' : '') + (_npw > 0 ? 'P' : '')
                _kindTxt := _sides + (_ndj > 1 ? ' ' + str.tostring(_ndj) + 'b' : '') + (_hasD ? '+DOL' : '')
                _kindTxt
            array.push(glabels, label.new(_lx, _pj, _kindTxt + _tag + _pxx + _stx + _rkx + _cfx + _netx, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.black, 100), textcolor = _col, size = _lblsz(i_lbl_size)))

    // centre axis for the diverging bars, spanning the drawn level set
    if i_mag_bars and i_bar_axis and i_bar_style == 'Diverging' and array.size(mP) > 1
        int _ax = bar_index + i_lbl_pad + i_lane_gap + math.round(i_bar_len / 2.0)
        float _axLo = array.get(mP, 0)
        float _axHi = array.get(mP, array.size(mP) - 1)
        array.push(glines, line.new(_ax, _axLo, _ax, _axHi, xloc = xloc.bar_index, color = color.new(color.gray, 55), width = 1, style = line.style_solid))

    if i_show_flips
        if not na(_flip0) and i_dte0
            // The regime band. Drawn before the line so the hairline sits on
            // top of it, and coloured by which side price is closing on: this
            // is the one level whose position rewrites the meaning of every
            // other level on the chart.
            if i_flip_band
                color _fbc = regClose > _flip0 ? col_flip_pos : col_flip_neg
                array.push(gboxes, box.new(math.max(0, bar_index - 1500), _flip0 + i_flip_band_pts, bar_index + i_lbl_pad, _flip0 - i_flip_band_pts, xloc = xloc.bar_index, bgcolor = _fbc, border_color = _fbc, border_width = 1))
            array.push(glines, line.new(bar_index - 1, _flip0, bar_index + i_lbl_pad, _flip0, xloc = xloc.bar_index, extend = extend.left, color = color.new(col_flip, 20), style = _lsty(i_lvl_sty), width = 1))
            array.push(glabels, label.new(_laneLbl + _place(_flip0, _lblgap) * i_stagger, _flip0, 'flip 0D' + (i_lbl_detail == 'Name only' or i_lbl_detail == 'Compact' ? '' : ' ' + str.tostring(_flip0, format.mintick)), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.black, 100), textcolor = col_flip, size = size.tiny))
        if not na(_flip7) and i_dte7
            array.push(glines, line.new(bar_index - 1, _flip7, bar_index + i_lbl_pad, _flip7, xloc = xloc.bar_index, extend = extend.left, color = color.new(col_flip, 20), style = _lsty(i_lvl_sty), width = 1))
            if i_flip_lbl_all
                array.push(glabels, label.new(_laneLbl + _place(_flip7, _lblgap) * i_stagger, _flip7, 'flip 7D' + (i_lbl_detail == 'Name only' or i_lbl_detail == 'Compact' ? '' : ' ' + str.tostring(_flip7, format.mintick)), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.black, 100), textcolor = col_flip, size = size.tiny))
        if not na(_flip30) and i_dte30
            array.push(glines, line.new(bar_index - 1, _flip30, bar_index + i_lbl_pad, _flip30, xloc = xloc.bar_index, extend = extend.left, color = color.new(col_flip, 20), style = _lsty(i_lvl_sty), width = 1))
            if i_flip_lbl_all
                array.push(glabels, label.new(_laneLbl + _place(_flip30, _lblgap) * i_stagger, _flip30, 'flip 30D' + (i_lbl_detail == 'Name only' or i_lbl_detail == 'Compact' ? '' : ' ' + str.tostring(_flip30, format.mintick)), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.black, 100), textcolor = col_flip, size = size.tiny))

    // ---- gradient band -----------------------------------------------
    // Bounds are the two boxed walls, so this inherits the alignment-and-rank
    // selection already made rather than inventing a second rule for which
    // walls matter. Anchored on the 0DTE flip, which is the level whose
    // position rewrites what every other level means.
    if i_dens and not na(cwbox_px) and not na(pwbox_px) and cwbox_px > pwbox_px
        float _dlo = pwbox_px
        float _dhi = cwbox_px
        // Flip anchors the middle. If it sits outside the two walls - which
        // happens when price has run past one of them - fall back to the
        // midpoint rather than producing a band with no neutral zone.
        float _fz = not na(_flip0) and _flip0 > _dlo and _flip0 < _dhi ? _flip0 : (_dlo + _dhi) / 2
        float _fzTop = _fz + i_flipz
        float _fzBot = _fz - i_flipz
        float _slice = (_dhi - _dlo) / i_dens_n
        int _x0 = _laneDens
        for _si = 0 to i_dens_n - 1 by 1
            float _b = _dlo + _slice * _si
            float _pm = _b + _slice / 2
            color _cc = na
            if _pm <= _fzTop and _pm >= _fzBot
                _cc := col_flipz
                _cc
            else
                // strength is distance from the neutral zone toward this
                // side's wall, so it is 0 at the flip and 1 at the boundary
                float _st = _pm > _fzTop ? (_dhi - _fzTop) <= 0 ? 1.0 : (_pm - _fzTop) / (_dhi - _fzTop) : (_fzBot - _dlo) <= 0 ? 1.0 : (_fzBot - _pm) / (_fzBot - _dlo)
                _st := math.min(1.0, math.max(0.0, _st))
                int _op = math.round(i_dens_op_lo - (i_dens_op_lo - i_dens_op_hi) * _st)
                _cc := regSig == -1 ? color.new(col_dens_neg, _op) : color.new(_pm > _fzTop ? col_cw : col_pw, _op)
                _cc
            array.push(gboxes, box.new(_x0, _b + _slice, _x0 + i_dens_w, _b, xloc = xloc.bar_index, bgcolor = _cc, border_color = color.new(color.black, 100), border_width = 0))

    // largest CW / PW state boxes (narrow, fixed tick height)
    if i_bignb
        float _bh = syminfo.mintick * i_box_ticks
        if not na(cwbox_px)
            // lit when the current bar wicks into the box range
            bool _cwLit = high >= cwbox_px - _bh and low <= cwbox_px + _bh
            color _cwc = cwbox_recl ? col_reclaim : _cwLit ? col_cw_lit : col_cw_dim
            // border inherits the state transparency. v2.4.1 forced it to 0,
            // which made a dim box and a lit box carry identical borders and
            // defeated the state machine at any realistic zoom.
            array.push(gboxes, box.new(math.max(0, bar_index - 1500), cwbox_px + _bh, bar_index + i_lbl_pad, cwbox_px - _bh, xloc = xloc.bar_index, bgcolor = _cwc, border_color = _cwc, border_width = 1))
        if not na(pwbox_px)
            bool _pwLit = high >= pwbox_px - _bh and low <= pwbox_px + _bh
            // PW: reclaimed (closed below) shows red; else lit/dim green
            color _pwc = pwbox_recl ? col_cw_lit : _pwLit ? col_pw_lit : col_pw_dim
            array.push(gboxes, box.new(math.max(0, bar_index - 1500), pwbox_px + _bh, bar_index + i_lbl_pad, pwbox_px - _bh, xloc = xloc.bar_index, bgcolor = _pwc, border_color = _pwc, border_width = 1))

// ============================================================
// === TABLE ===
// ============================================================
_pos(p) =>
    p == 'bottom_right' ? position.bottom_right : p == 'top_left' ? position.top_left : p == 'bottom_left' ? position.bottom_left : position.top_right


_reg(f) =>
    na(f) ? '-' : regClose > f ? 'POS' : 'NEG'

// Regime tint. Uses the resolved regime signal, so it follows net GEX when net
// GEX has been entered rather than always tracking the 0DTE flip side.
bgcolor(i_reg_tint and regSig != 0 ? (regSig == 1 ? color.new(#26a69a, i_reg_tint_op) : color.new(#ef5350, i_reg_tint_op)) : na, title = 'Regime tint')

_regc(f) =>
    na(f) ? color.new(color.gray, 30) : regClose > f ? color.new(#26a69a, 0) : color.new(#ef5350, 0)
_sigc(v) =>
    v == 1 ? color.new(#26a69a, 0) : v == -1 ? color.new(#ef5350, 0) : color.new(color.gray, 30)
_ageTxt() =>
    na(_gTime) ? '-' : str.tostring(math.round((timenow - _gTime) / 60000)) + 'm'

// Rows are counted first so the table is created at the size it needs. An
// expiry that is switched off contributes no row at all, rather than showing
// as unused context.
_f0on = i_dte0
_f7on = i_dte7
_f30on = i_dte30
_ageOn = i_snap != '' or not na(_gTime)
_netOn2 = _netOn
// Composition gets its own row. A net figure near zero can be two large
// offsetting sides or two small ones, and those are different days.
_cpOn = (not na(_callEff) and _callEff != 0.0) or (not na(_putEff) and _putEff != 0.0)

var table gt = na
if i_show_tbl and barstate.islast
    if not na(gt)
        table.delete(gt)
    _na = not symOk
    _n = 2
    _n += _f0on ? 1 : 0
    _n += _f7on ? 1 : 0
    _n += _f30on ? 1 : 0
    _n += _netOn2 ? 1 : 0
    _n += _cpOn ? 1 : 0
    _n += _ageOn ? 1 : 0
    _n += i_tbl_diag ? 3 : 0
    gt := table.new(_pos(i_tbl_pos), 2, _n, border_width = 1, border_color = color.new(color.gray, 55))

    _r = 0
    // Version is on the chart deliberately. Two instances of this script can
    // sit on one chart looking identical in the legend, and a settings panel
    // does not say which build it belongs to - so a string that fails to parse
    // is indistinguishable from a string pasted into the wrong instance.
    table.cell(gt, 0, _r, 'DOL+G ' + (symOk ? chartSym : 'n/a') + '  v2.18.4', text_color = color.white, bgcolor = color.new(color.black, 0), text_size = size.small)
    table.cell(gt, 1, _r, str.tostring(close, format.mintick), text_color = color.white, bgcolor = color.new(color.black, 0), text_size = size.small)

    _r += 1
    _regTxt = regSig == 1 ? 'POS - fade walls' : regSig == -1 ? 'NEG - walls break' : '-'
    _boxTxt = i_box_mode == 'Magnitude' and not _magOn ? '  ! mag blank' : ''
    table.cell(gt, 0, _r, 'Regime', text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.small)
    table.cell(gt, 1, _r, _na ? 'n/a - no gamma here' : _regTxt + ' (' + regSrc + ')' + (regSplit ? ' !' : '') + _boxTxt, text_color = color.white, bgcolor = _na ? color.new(color.gray, 40) : _sigc(regSig), text_size = size.small)

    if _f0on
        _r += 1
        table.cell(gt, 0, _r, '0DTE flip', text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.small)
        table.cell(gt, 1, _r, _na ? 'n/a' : na(_flip0) ? '-' : str.tostring(_flip0, format.mintick) + '  ' + _reg(_flip0), text_color = color.white, bgcolor = _na ? color.new(color.gray, 40) : _regc(_flip0), text_size = size.small)
    if _f7on
        _r += 1
        table.cell(gt, 0, _r, '7DTE flip', text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.small)
        table.cell(gt, 1, _r, _na ? 'n/a' : na(_flip7) ? '-' : str.tostring(_flip7, format.mintick) + '  ' + _reg(_flip7), text_color = color.white, bgcolor = _na ? color.new(color.gray, 40) : _regc(_flip7), text_size = size.small)
    if _f30on
        _r += 1
        table.cell(gt, 0, _r, '30DTE flip', text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.small)
        table.cell(gt, 1, _r, _na ? 'n/a' : na(_flip30) ? '-' : str.tostring(_flip30, format.mintick) + '  ' + _reg(_flip30), text_color = color.white, bgcolor = _na ? color.new(color.gray, 40) : _regc(_flip30), text_size = size.small)

    if _netOn2
        _r += 1
        table.cell(gt, 0, _r, 'Net GEX', text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.small)
        table.cell(gt, 1, _r, str.tostring(_netEff, '#.##') + 'B' + (regSplit ? '  ! flip ' + (_regFlip == 1 ? 'POS' : 'NEG') : '') + (_dteSplit ? '  !DTE' : ''), text_color = color.white, bgcolor = _netEff > 0 ? color.new(#26a69a, 55) : color.new(#ef5350, 55), text_size = size.small)

    if _cpOn
        _r += 1
        table.cell(gt, 0, _r, 'Call / Put GEX', text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.small)
        table.cell(gt, 1, _r, '+' + str.tostring(math.abs(_callEff), '#.##') + '  /  -' + str.tostring(math.abs(_putEff), '#.##') + 'B', text_color = color.white, bgcolor = math.abs(_callEff) > math.abs(_putEff) ? color.new(#26a69a, 55) : color.new(#ef5350, 55), text_size = size.small)

    if i_tbl_diag
        _r += 1
        table.cell(gt, 0, _r, 'Outer above', text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.small)
        table.cell(gt, 1, _r, _na or na(x_extCeil) ? '-' : str.tostring(x_extCeil, format.mintick), text_color = color.white, bgcolor = color.new(col_cw, 20), text_size = size.small)
        _r += 1
        table.cell(gt, 0, _r, 'Outer below', text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.small)
        table.cell(gt, 1, _r, _na or na(x_extFloor) ? '-' : str.tostring(x_extFloor, format.mintick), text_color = color.white, bgcolor = color.new(col_pw, 20), text_size = size.small)
        _r += 1
        // v2.10 adds the magnitude-admitted count. Zero with the field filled
        // means the threshold admitted nothing beyond the rank cut, so the
        // level set is identical to string-only operation.
        table.cell(gt, 0, _r, 'Confl / align / mag', text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.small)
        table.cell(gt, 1, _r, (_na ? '-' : str.tostring(x_confl)) + ' / ' + str.tostring(x_align) + ' / ' + (_magOn ? str.tostring(x_magAdmit) : '-'), text_color = color.white, bgcolor = color.new(#26a69a, 40), text_size = size.small)

    if _ageOn
        _r += 1
        table.cell(gt, 0, _r, 'As of', text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.small)
        table.cell(gt, 1, _r, (i_snap == '' ? 'QV -' : 'QV ' + i_snap) + '  / set ' + _ageTxt(), text_color = color.white, bgcolor = color.new(color.gray, 25), text_size = size.small)

// ============================================================
// === HARVESTER  (level interaction log) ===
//   One row per TOUCH of a level node, not per signal fire. Logging only
//   fires produces a numerator with no denominator: you learn how often a
//   signal worked, never how often the same level was reached and produced
//   nothing, so no conditional comparison is possible. The touch is the unit
//   that makes the denominator real.
//
//   An interaction is captured at the touch bar, watched for i_hv_win bars,
//   then emitted with its outcome attached. Rows therefore appear LATER than
//   the event they describe; hv_bar carries the interaction bar index.
//
//   One row per bar. Touches are sparse enough that this rarely binds, but
//   hv_queue exports the pending depth so a backlog is visible rather than
//   silent.
// ============================================================
var array<int> hvB = array.new_int()
var array<float> hvPx = array.new_float()
var array<int> hvKC = array.new_int()
var array<int> hvG = array.new_int()
var array<int> hvD = array.new_int()
var array<int> hvND = array.new_int()
var array<int> hvRk = array.new_int()
var array<int> hvSt = array.new_int()
var array<float> hvW = array.new_float()
var array<float> hvMg = array.new_float()
var array<int> hvCf = array.new_int()
var array<int> hvNcw = array.new_int()
var array<int> hvNpw = array.new_int()
var array<float> hvDf = array.new_float()
var array<int> hvReg = array.new_int()
var array<int> hvBox = array.new_int()
var array<int> hvSide = array.new_int()
var array<float> hvOrig = array.new_float()
var array<float> hvFar = array.new_float()
var array<int> hvRej = array.new_int()
var array<int> hvDis = array.new_int()
var array<int> hvGV = array.new_int()
var int hvDropped = 0

// emitted row (one bar wide)
var float e_evt = 0.0
var float e_bar = na
var float e_px = na
var float e_kc = na
var float e_g = na
var float e_d = na
var float e_nd = na
var float e_rk = na
var float e_st = na
var float e_w = na
var float e_mg = na
var float e_cf = na
var float e_ncw = na
var float e_npw = na
var float e_df = na
var float e_reg = na
var float e_box = na
var float e_side = na
var float e_orig = na
var float e_far = na
var float e_rej = na
var float e_dis = na
var float e_out = na
var float e_gv = na

if i_hv
    e_evt := 0.0
    float _tk = syminfo.mintick * i_hv_ticks

    // ---- capture new touches ----
    int _hn = array.size(mP)
    if _hn > 0 and array.size(hvB) < 12
        for _hi = 0 to _hn - 1 by 1
            if array.size(hvB) >= 12
                break
            float _hp = array.get(mP, _hi)
            bool _isg = array.get(mHasG, _hi)
            if not na(_hp) and (not i_hv_gamma_only or _isg)
                bool _spanNow = high >= _hp and low <= _hp
                bool _spanPrev = high[1] >= _hp and low[1] <= _hp
                if _spanNow and not _spanPrev
                    // already pending for this level? do not double-count a
                    // level that is being chopped across consecutive bars
                    bool _dup = false
                    if array.size(hvB) > 0
                        for _dq = 0 to array.size(hvB) - 1 by 1
                            if math.abs(array.get(hvPx, _dq) - _hp) < syminfo.mintick / 2
                                _dup := true
                                break
                    if not _dup
                        int _cg = array.get(mConf, _hi)
                        bool _both = _cg >= 0 and _cg < array.size(gBoth) ? array.get(gBoth, _cg) : false
                        bool _isbox = (not na(cwbox_px) and math.abs(_hp - cwbox_px) < syminfo.mintick / 2) or (not na(pwbox_px) and math.abs(_hp - pwbox_px) < syminfo.mintick / 2)
                        array.push(hvB, bar_index)
                        array.push(hvPx, _hp)
                        array.push(hvKC, array.get(mKC, _hi))
                        array.push(hvG, _isg ? 1 : 0)
                        array.push(hvD, array.get(mHasD, _hi) ? 1 : 0)
                        array.push(hvND, array.get(mNDte, _hi))
                        array.push(hvRk, array.get(mRank, _hi))
                        array.push(hvSt, array.get(mState, _hi))
                        array.push(hvW, array.get(mW, _hi))
                        // raw magnitude ratio, -1 when unavailable. Kept apart
                        // from hv_weight so the harvester can separate size
                        // from the weight blend that also carries DTE.
                        array.push(hvMg, array.get(mMag, _hi))
                        array.push(hvCf, _both ? 1 : 0)
                        array.push(hvNcw, array.get(mNCW, _hi))
                        array.push(hvNpw, array.get(mNPW, _hi))
                        array.push(hvDf, na(_flip0) ? float(na) : close - _flip0)
                        array.push(hvReg, regSig)
                        array.push(hvBox, _isbox ? 1 : 0)
                        // side: which way price came from. 1 = from below, so
                        // the level is overhead; -1 = from above.
                        array.push(hvSide, close[1] < _hp ? 1 : -1)
                        array.push(hvOrig, 0.0)
                        array.push(hvFar, 0.0)
                        array.push(hvRej, -1)
                        array.push(hvDis, -1)
                        // Captured live, not "gamma valid". Pine recomputes
                        // history on every load and cannot know when the
                        // string was actually pasted, so a paste-time flag is
                        // not constructible. Realtime capture IS knowable, and
                        // it is the condition that matters: on a live bar the
                        // walls on screen are the walls that were in force.
                        array.push(hvGV, barstate.isrealtime ? 1 : 0)
    else if _hn > 0 and array.size(hvB) >= 12
        hvDropped := hvDropped + 1
        hvDropped

    // ---- advance pending ----
    if array.size(hvB) > 0
        for _pi = 0 to array.size(hvB) - 1 by 1
            int _age = bar_index - array.get(hvB, _pi)
            if _age >= 1
                float _pp = array.get(hvPx, _pi)
                int _sd = array.get(hvSide, _pi)
                // excursion on the side price came from, and beyond the level
                float _eo = _sd == 1 ? _pp - low : high - _pp
                float _ef = _sd == 1 ? high - _pp : _pp - low
                array.set(hvOrig, _pi, math.max(array.get(hvOrig, _pi), math.max(0.0, _eo)))
                array.set(hvFar, _pi, math.max(array.get(hvFar, _pi), math.max(0.0, _ef)))
                // first close back on the origin side, far enough away
                if array.get(hvRej, _pi) < 0
                    bool _r = _sd == 1 ? close < _pp - _tk : close > _pp + _tk
                    if _r
                        array.set(hvRej, _pi, _age)
                // first close beyond the level, far enough through
                if array.get(hvDis, _pi) < 0
                    bool _b = _sd == 1 ? close > _pp + _tk : close < _pp - _tk
                    if _b
                        array.set(hvDis, _pi, _age)

    // ---- emit the oldest matured row ----
    if array.size(hvB) > 0
        int _age0 = bar_index - array.get(hvB, 0)
        if _age0 >= i_hv_win
            int _rj = array.get(hvRej, 0)
            int _ds = array.get(hvDis, 0)
            // respected only if the rejection came first AND inside the
            // threshold. Anything slower is the tug-of-war case and codes 0,
            // with the raw bar count kept so the cut can be revisited.
            int _oc = _rj >= 0 and (_ds < 0 or _rj < _ds) and _rj <= i_hv_rej ? 1 : _ds >= 0 and (_rj < 0 or _ds < _rj) ? -1 : 0
            e_evt := 1.0
            e_bar := array.get(hvB, 0)
            e_px := array.get(hvPx, 0)
            e_kc := array.get(hvKC, 0)
            e_g := array.get(hvG, 0)
            e_d := array.get(hvD, 0)
            e_nd := array.get(hvND, 0)
            e_rk := array.get(hvRk, 0)
            e_st := array.get(hvSt, 0)
            e_w := array.get(hvW, 0)
            e_mg := array.get(hvMg, 0)
            e_cf := array.get(hvCf, 0)
            e_ncw := array.get(hvNcw, 0)
            e_npw := array.get(hvNpw, 0)
            e_df := array.get(hvDf, 0)
            e_reg := array.get(hvReg, 0)
            e_box := array.get(hvBox, 0)
            e_side := array.get(hvSide, 0)
            e_orig := array.get(hvOrig, 0) / syminfo.mintick
            e_far := array.get(hvFar, 0) / syminfo.mintick
            e_rej := _rj
            e_dis := _ds
            e_out := _oc
            e_gv := array.get(hvGV, 0)
            array.shift(hvB), array.shift(hvPx), array.shift(hvKC), array.shift(hvG)
            array.shift(hvD), array.shift(hvND), array.shift(hvRk), array.shift(hvSt)
            array.shift(hvW), array.shift(hvMg), array.shift(hvCf), array.shift(hvNcw)
            array.shift(hvNpw), array.shift(hvDf), array.shift(hvReg), array.shift(hvBox)
            array.shift(hvSide), array.shift(hvOrig), array.shift(hvFar), array.shift(hvRej)
            array.shift(hvDis), array.shift(hvGV)

// ---- harvester export block ----
//   Filter the exported CSV to rows where hv_event = 1. One such row is one
//   level interaction.
//   hv_kind      1 PDH 2 PDL 3 AsH 4 AsL 5 LoH 6 LoL 7 4hH 8 4hL
//                9 PWH 10 PWL 11 PMH 12 PML 13 ONH 14 ONL 0 gamma only
//   hv_side      1 approached from below (level overhead), -1 from above
//   hv_outcome   1 respected, -1 broken, 0 undecided
//   hv_walls     call constituents * 100 + put constituents
//   hv_mag       magnitude ratio of the node's largest gamma leg, -1 if the
//                magnitude field was blank. This is the column that answers
//                whether wall SIZE changes the reaction rate, which no
//                previous column could: hv_weight blends size with the DTE
//                weight and the base wall weight, and hv_rank is ordinal.
//   hv_flags     bitfield, add to decode:
//                  1 is gamma      2 has DOL       4 confluent
//                  8 was the boxed level          16 captured live
//                Bit 16 clear means the row was reconstructed from history on
//                a chart load, so its gamma fields are the CURRENT string
//                projected onto an older bar. Those rows stay valid for DOL
//                analysis and must be excluded from gamma analysis. Only
//                rows with bit 16 set carry gamma that was really in force.
plot(e_evt, 'hv_event', color = na, display = display.data_window)
plot(e_bar, 'hv_bar', color = na, display = display.data_window)
plot(e_px, 'hv_level', color = na, display = display.data_window)
plot(e_kc, 'hv_kind', color = na, display = display.data_window)
plot(e_nd, 'hv_boards', color = na, display = display.data_window)
plot(e_rk, 'hv_rank', color = na, display = display.data_window)
plot(e_st, 'hv_dol_state', color = na, display = display.data_window)
plot(e_w, 'hv_weight', color = na, display = display.data_window)
plot(e_mg, 'hv_mag', color = na, display = display.data_window)
plot(na(e_ncw) ? na : e_ncw * 100 + e_npw, 'hv_walls (call*100+put)', color = na, display = display.data_window)
plot(e_df, 'hv_dist_to_flip', color = na, display = display.data_window)
plot(e_reg, 'hv_regime', color = na, display = display.data_window)
plot(e_side, 'hv_side', color = na, display = display.data_window)
plot(e_orig, 'hv_excursion_origin_ticks', color = na, display = display.data_window)
plot(e_far, 'hv_excursion_through_ticks', color = na, display = display.data_window)
plot(e_rej, 'hv_bars_to_reject', color = na, display = display.data_window)
plot(e_dis, 'hv_bars_to_break', color = na, display = display.data_window)
plot(e_out, 'hv_outcome', color = na, display = display.data_window)
plot(na(e_g) ? na : e_g + e_d * 2 + e_cf * 4 + e_box * 8 + e_gv * 16, 'hv_flags', color = na, display = display.data_window)
plot(array.size(hvB), 'hv_queue', color = na, display = display.data_window)
plot(hvDropped, 'hv_dropped', color = na, display = display.data_window)

// ============================================================
// === DATA WINDOW EXPORTS ===
//   Prerequisite for the level-interaction harvester. Unit of observation is the
//   level touch, not the signal fire - these plots are the denominator.
// ============================================================
plot(_flip0, 'flip 0DTE', color = na, display = display.data_window)
plot(_flip7, 'flip 7DTE', color = na, display = display.data_window)
plot(_flip30, 'flip 30DTE', color = na, display = display.data_window)
plot(regSig, 'regime 0D (1 pos / -1 neg)', color = na, display = display.data_window)
plot(_regFlip + _regNet * 10 + (regSplit ? 100 : 0), 'regime detail (flip + net*10 + split*100)', color = na, display = display.data_window)
plot(_netEff, 'net GEX 0D ($B)', color = na, display = display.data_window)
plot(_net7, 'net GEX 7D ($B)', color = na, display = display.data_window)
plot(_net30, 'net GEX 30D ($B)', color = na, display = display.data_window)
plot(_dteSplit ? 1 : 0, 'net GEX sign split across DTE', color = na, display = display.data_window)
plot(na(_flip0) ? na : close - _flip0, 'dist to flip 0D', color = na, display = display.data_window)
plot(x_extCeil, 'outermost wall above', color = na, display = display.data_window)
plot(x_extFloor, 'outermost wall below', color = na, display = display.data_window)
plot(x_nearCeil, 'nearest ceiling', color = na, display = display.data_window)
plot(x_nearFloor, 'nearest floor', color = na, display = display.data_window)
plot(x_nearCeilW, 'nearest ceiling weight', color = na, display = display.data_window)
plot(x_nearFloorW, 'nearest floor weight', color = na, display = display.data_window)
plot(x_nearCeilT, 'nearest ceiling touches', color = na, display = display.data_window)
plot(x_nearFloorT, 'nearest floor touches', color = na, display = display.data_window)
plot(x_confl, 'confluent nodes', color = na, display = display.data_window)
plot(x_align, 'multi-DTE aligned nodes', color = na, display = display.data_window)
// Nodes admitted by the magnitude threshold that the rank cut alone would
// have dropped. Compare against 'level nodes' to see how much of the level
// set exists only because the magnitude field is filled.
plot(x_magAdmit, 'magnitude-admitted nodes', color = na, display = display.data_window)
plot(x_maxOI, 'max OI on board', color = na, display = display.data_window)
plot(x_domNet, 'net exposure at boxed CW', color = na, display = display.data_window)
plot(cwbox_px, 'boxed CW price', color = na, display = display.data_window)
plot(cwbox_sc, 'boxed CW score', color = na, display = display.data_window)

plot(pwbox_px, 'boxed PW price', color = na, display = display.data_window)
plot(pwbox_sc, 'boxed PW score', color = na, display = display.data_window)
plot((cwbox_recl ? 1 : 0) + (pwbox_recl ? 2 : 0), 'boxed reclaimed (CW1 + PW2)', color = na, display = display.data_window)

plot(array.size(mP), 'level nodes', color = na, display = display.data_window)
plot(pdh, 'PDH', color = na, display = display.data_window)

plot(pdl, 'PDL', color = na, display = display.data_window)

plot(asiaH_prev, 'AsH', color = na, display = display.data_window)

plot(asiaL_prev, 'AsL', color = na, display = display.data_window)

plot(lonH_prev, 'LoH', color = na, display = display.data_window)

plot(lonL_prev, 'LoL', color = na, display = display.data_window)

plot(h4h, '4hH', color = na, display = display.data_window)

plot(h4l, '4hL', color = na, display = display.data_window)
// DOL states packed base-3 (2 naked / 1 swept / 0 broken). Decode by
// repeated division by 3: PDH, PDL, AsH, AsL, LoH, LoL, 4hH, 4hL.
// Packed because the 64-plot ceiling is a hard limit and eight separate
// state series is the cheapest thing to give up - the harvester carries
// per-interaction state on the row that actually needs it.
plot(st_pdh + st_pdl * 3 + st_asiaH * 9 + st_asiaL * 27 + st_lonH * 81 + st_lonL * 243 + st_h4h * 729 + st_h4l * 2187, 'DOL states packed base3', color = na, display = display.data_window)

plot(na(_gTime) ? na : (timenow - _gTime) / 60000, 'gamma age (min)', color = na, display = display.data_window)
````
