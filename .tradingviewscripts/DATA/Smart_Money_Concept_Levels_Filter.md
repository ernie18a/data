<!-- tradingview-pine-id: PUB;dea333a4817a43c6a48b47350f84f821 -->
<!-- tradingviewscripts-format: 1 -->
# Smart Money Concept Levels Filter

Source: https://www.tradingview.com/script/DBks2k25-Smart-Money-Concept-Levels-Filter/

## Description

SMART MONEY CONCEPT LEVELS FILTER
https://www.tradingview.com/u/Expert_Markets_Insights/

OVERVIEW

Smart Money Concept Levels Filter maps the price-action framework commonly taught as smart money concepts, and it does so on two zoom levels at the same time so that short-term structure and larger-picture structure are visible together on one chart.

Two independent structure engines run side by side. The swing engine uses a long pivot length and draws with solid lines: this is the larger picture, the structure a position trader watches. The internal engine uses a short pivot length and draws with dashed lines: this is the structure inside the swing, the detail a scalper works with. Each keeps its own trend state, so the two can disagree, and when they do that disagreement is itself information.

Around that spine sit the rest of the framework: order blocks extracted from the origin of every structural break, equal highs and equal lows marked as resting liquidity, fair value gaps filtered by an adaptive threshold, the strong and weak classification of the current swing extremes, a premium and discount partition of the trailing range, and the previous daily, weekly and monthly levels.

Every threshold that could otherwise be instrument-specific is measured in multiples of Average True Range, so the same settings behave identically on gold, on a currency pair, on an index and on crypto, from seconds charts to monthly.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

WHY THIS INDICATOR WAS CREATED

Six specific problems drove this build.

1. One structure layer is never enough.
A tool tuned to short-term pivots produces a chart covered in labels and no sense of the bigger move. A tool tuned to long pivots gives clean context and misses everything a trader actually executes on. Running both at once, each with its own trend state and its own visual weight, means the execution detail and the larger picture never have to be chosen between.

2. The difference between a break of structure and a change of character is decided by state, not by hindsight.
These two events look identical on the chart, a close through a prior pivot, and they mean opposite things. One says the trend continues, the other says it may have just turned. The only correct way to tell them apart is to read the trend state at the instant the level breaks, and that requires the engine to actually hold that state rather than infer it later.

3. A single level should fire once, not repeatedly.
Without a guard, price oscillating around a pivot prints break after break on the same level, and the chart fills with meaningless duplicates. Each pivot here is marked as consumed the moment it is broken, and only a newly confirmed pivot can produce the next event.

4. Order blocks are usually marked in the wrong place.
Many tools mark the candle that broke structure. The concept says the opposite: the block is the origin of the leg, the candle price left from before the break happened. Locating that origin candle inside the leg, rather than taking whichever bar was convenient, is the difference between a zone with a rationale and a rectangle.

5. Strong and weak extremes are the most useful idea in the framework and the least implemented.
Not all highs are equal. The high that a bearish move originated from has a reason to hold; the high formed during a countertrend bounce does not. Labelling them differently, driven by the live swing trend, turns a chart of levels into a chart of ranked levels.

6. Fixed thresholds break across instruments.
An equal-highs tolerance or a gap filter measured in fixed points is sensible on one market and nonsense on the next. Every tolerance here is ATR-relative, and the gap filter is adaptive to the instrument's own recent gap sizes, so nothing needs retuning when the chart changes.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

HOW IT WORKS, FULL METHODOLOGY

1. THE DUAL STRUCTURE ENGINE

Two engines run independently. Each holds four things: its most recent confirmed pivot high with the bar it formed on, its most recent confirmed pivot low with the same, a flag for each recording whether that level has already been broken, and its own trend direction.

When a new pivot is confirmed, it replaces the stored level and its broken flag is cleared, arming it. When price closes through an armed level, the engine fires once, marks the level consumed, and updates its trend direction. That consumed flag is what prevents a single level from producing a stream of duplicate labels.

The swing engine draws with solid lines and larger text; the internal engine draws with dashed lines and smaller text, so the two layers are never confused with each other.

2. BREAK OF STRUCTURE AND CHANGE OF CHARACTER

At the moment a level breaks, the engine compares the direction of the break to its own current trend.

If the break continues the existing trend, it is a break of structure: a continuation event, confirmation that the prevailing direction is still in force.

If the break reverses the trend, it is a change of character: the first structural evidence that the prevailing direction may be over. The trend state then flips, so the next event will be judged against the new direction.

Each layer can be filtered independently to show all events, only breaks of structure, or only changes of character.

3. SWING POINT CLASSIFICATION

Optionally, every confirmed swing pivot is labelled against its predecessor as a higher high, lower high, higher low or lower low. This is the raw grammar of trend and it is off by default because it adds a great deal of text to the chart.

4. ORDER BLOCKS

When a structural break occurs, the engine looks back across the leg that produced it and finds its origin candle: the lowest low of the leg for a bullish break, the highest high for a bearish one. The zone is built from that candle, using either its full wick range or just its body, your choice.

Internal breaks and swing breaks maintain separate pools with their own colours and their own size limits, so short-term blocks never crowd out the significant ones. Each zone extends to the right and carries a label inside it.

A block is mitigated and removed once price closes decisively through it, on either a close or a wick basis, so only unmitigated zones remain drawn.

5. EQUAL HIGHS AND EQUAL LOWS

Consecutive pivots that land within an ATR-relative tolerance of one another are joined by a dotted line and labelled as equal highs or equal lows. Under the methodology these are resting liquidity: clusters of stop orders sitting just beyond a level that price has already respected more than once.

6. FAIR VALUE GAPS

Three-candle imbalances are detected: a bullish gap where the third candle's low sits above the first candle's high, a bearish gap where the third candle's high sits below the first candle's low.

The significance filter is adaptive rather than fixed. The engine maintains a running average of the gap sizes this instrument has actually produced and requires a new gap to exceed a multiple of that average. A meaningful gap on gold and a meaningful gap on a currency pair are therefore both judged correctly by the same setting.

7. STRONG AND WEAK EXTREMES

This is driven entirely by the live swing trend.

When the swing trend is bearish, the swing high that the bearish move originated from is labelled Strong High: a level with real structural reason behind it. The swing low formed during the countertrend move is labelled Weak Low: a level with far less behind it and correspondingly easier to break.

When the swing trend is bullish, the classification mirrors: Strong Low at the origin and Weak High against it.

8. PREMIUM, EQUILIBRIUM AND DISCOUNT

The trailing swing range is partitioned into three bands: an expensive upper zone, a fair middle around the midpoint, and a cheap lower zone. All three boundaries are configurable as percentages of the range. It is off by default.

9. MULTI-TIMEFRAME LEVELS

The previous completed daily, weekly and monthly high and low can each be extended across the chart as higher-timeframe reference, whatever timeframe you are working on. All are requested with lookahead disabled.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

HOW TO READ IT ON THE CHART

- Solid line with a label. A swing structure break, the larger picture.
- Dashed line with a smaller label. An internal structure break, the detail inside the swing.
- BOS. Break of structure, a continuation of that layer's trend.
- CHoCH. Change of character, that layer's trend just flipped.
- Green labels and lines. Bullish events. Red labels and lines. Bearish events.
- Blue shaded zone. A bullish order block, the origin of an upward leg.
- Red or pink shaded zone. A bearish order block, the origin of a downward leg.
- Order Block text inside a zone. Identifies the zone at a glance without a separate legend.
- EQH or EQL joined by a dotted line. Equal highs or equal lows, resting liquidity.
- Strong High or Strong Low on the right. The extreme the current swing trend originated from.
- Weak High or Weak Low on the right. The countertrend extreme, structurally the softer level.
- HH, HL, LH, LL. Swing point classification, off by default.

Read the swing layer first for context, then the internal layer for timing. When both layers agree, structure is aligned. When the internal layer flips against a swing trend that is still intact, you are usually looking at a pullback rather than a reversal.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PRACTICAL USE

Treat a change of character as a warning and a break of structure as confirmation.
A change of character is the first structural evidence that a trend may be ending. It is a reason to tighten risk and stop adding, not a reason to reverse immediately. A break of structure in the new direction afterwards is the confirmation that the turn has actually happened.

Rank levels by strong and weak before anything else.
A Strong High in a bearish market is where the move came from and where sellers have a reason to defend. A Weak Low is where a bounce ran out of steam and has far less behind it. Given a choice of levels to work with, the strong one deserves more respect and the weak one is the more likely to break.

Use order blocks as zones to react in, not signals to act on.
A block marks the origin of a move. Price returning into it is the setup, not the entry. Wait for the reaction inside the zone before committing, and use the far boundary as invalidation, because that is where the zone's premise fails.

Read the layers together for timing.
The classic combination is a swing structure that is intact in one direction and an internal change of character that turns back in line with it. That is a pullback ending, which is a very different thing from a swing change of character, which is a trend possibly ending.

Expect equal levels to be swept.
Equal highs and equal lows mark where stops are resting. The methodology expects price to run them before the real move. Placing your own stop immediately beyond an obvious EQH or EQL is placing it exactly where the framework says price is most likely to reach.

Use the higher-timeframe levels as context, not as signals.
The previous daily, weekly and monthly extremes are reference points that traders on those timeframes are watching. They matter most when structure on your own chart is already turning near one of them.

Tune the two pivot lengths to your own horizon.
Raising the internal length quietens the chart and produces fewer, more meaningful internal events. Raising the swing length gives broader, rarer, more significant swing events. These two settings do more to change the character of the tool than anything else in it.

Timeframes.
Everything is ATR-relative, so the tool behaves consistently everywhere. Higher timeframes produce fewer, larger and more significant events; lower timeframes produce many more. A swing change of character on a four-hour chart carries far more weight than one on a one-minute chart.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SETTINGS

INTERNAL STRUCTURE
- Show Internal Structure, Internal Pivot Length, and a label filter for all events, breaks of structure only, or changes of character only.

SWING STRUCTURE
- Show Swing Structure, Swing Pivot Length, the same label filter, and Show Swing Points for the higher high and lower low classification.

ORDER BLOCKS
- Internal Order Blocks with their own count limit.
- Swing Order Blocks with their own count limit.
- Zone Built From, wick range or candle body.
- Mitigation Basis, close or wick.
- Write Order Block Inside Zone, with its own text colour and text size.

EQUAL HIGHS AND LOWS
- Show Equal Highs and Lows, the pivot length used to find them, and the tolerance in ATR.

FAIR VALUE GAPS
- Show Fair Value Gaps, Adaptive Significance Threshold, Threshold Strength, Gap Extend.

STRONG AND WEAK EXTREMES
- Show Strong and Weak High and Low.

PREMIUM AND DISCOUNT
- Show the partition, where premium starts, where discount ends, and the equilibrium half width.

MULTI-TIMEFRAME LEVELS
- Previous daily, weekly and monthly high and low, each independently.

STYLE
- Bullish and bearish structure colours, bullish and bearish order block colours, order block transparency, equal level colour, gap colours, higher-timeframe level colour and the ATR length.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

UNIVERSAL MARKET AND TIMEFRAME COMPATIBILITY

No pip value, point distance or price constant appears anywhere in the logic. The equal-level tolerance is an ATR multiple, the gap filter is adaptive to the instrument's own recent gaps, and the range partition is expressed in percentages, so the same configuration behaves consistently on Forex majors and crosses, on gold and other metals, on indices, on crypto, on futures and on individual equities, from seconds charts to monthly.

No volume data is required anywhere, so feeds that publish none lose no functionality at all.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ALERTS

Eleven alert conditions are included:

- Internal BOS and Internal CHoCH
- Swing BOS and Swing CHoCH
- Bullish Swing Break and Bearish Swing Break
- Equal Highs and Equal Lows
- Bullish Fair Value Gap and Bearish Fair Value Gap
- Order Block Mitigated

Alert messages carry the ticker and timeframe automatically, so the same alert can be run across a watchlist without keeping charts open.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

LIVE BEHAVIOUR AND REPAINTING STATEMENT

A pivot is confirmed only after the required bars have formed to its right. This is inherent to every pivot-based tool and cannot be removed by any setting: a swing is not a swing until price has moved away from it. Once confirmed, a pivot never moves.

Structure breaks, order block creation, order block mitigation, equal-level marking and gap detection are all evaluated on confirmed bars. A printed break of structure, change of character, equal level or order block never disappears from history and never changes side.

The strong and weak labels, the premium and discount partition and the previous higher-timeframe levels describe the present state and therefore update live, which is their purpose and is stated here so it is not mistaken for repainting.

The multi-timeframe levels are requested with lookahead disabled, so no future higher-timeframe data can reach a past bar.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

HONEST NOTE ON THE FRAMEWORK

I state this plainly so nothing here is oversold. The same note appears in the script header.

Smart money concepts are an interpretive framework, not a description of verified fact. This tool marks structure exactly as the methodology defines it, and that is all it does. It cannot see institutional orders. It cannot know anyone's intent. The words order block and liquidity name concepts from within the framework; they are not observations of order-book data. No retail charting tool can observe institutional flow, and this one makes no such claim anywhere.

What the tool actually does is entirely mechanical and entirely honest: it finds pivots, it detects closes through them, it classifies those closes against a tracked trend state, and it marks the origin candles of the resulting legs. Whether that framework describes how markets work is a question for you, not for the indicator.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

HONEST LIMITATIONS

- A change of character is a warning, not a reversal, and a break of structure is a continuation signal, not a guarantee. Both fail regularly, which is why every level here needs a stop behind it.
- Pivot confirmation means every event is marked some bars after the price action that caused it. The tool describes structure that has completed, never structure that is forming.
- Order blocks are areas, not barriers. Price can trade deep into a block and recover, and it can slice straight through one without pausing.
- The internal layer on a fast chart will produce a great deal of activity. That is the layer working as intended, and it is why the pivot length and the label filters exist.
- Equal highs and equal lows are marked by proximity within a tolerance. A wider tolerance finds more pairs and some of them will be coincidence; a narrower one finds fewer and misses some genuine ones. There is no setting that removes this trade-off.
- The strong and weak classification follows the swing trend. When that trend flips, the classification flips with it, which is correct behaviour and does mean the labels move when structure changes.
- The premium and discount partition uses the trailing swing range. In a strongly trending market that range is constantly being redefined, and the partition is correspondingly less meaningful than it is in a range.
- This indicator maps structure. It produces no entry or exit signals, does not size positions and does not manage risk. Every trading decision remains entirely your own.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

AUTHOR VERIFICATION DECLARATION

I am Expert_Markets_Insights, the publisher and sole original author of this exact implementation of Smart Money Concept Levels Filter. I designed the architecture of this tool, wrote every line of the Pine Script v6 code it contains, tested it across multiple asset classes and timeframes, and I take full and sole ownership and responsibility for it.

Specifically, I independently designed and coded: the dual structure engine that tracks an internal and a swing layer with independent pivot lengths, independent trend state and independent break bookkeeping; the crossed-level guard that prevents a single pivot from firing repeatedly; the break classifier that decides between a break of structure and a change of character from the trend state at the moment of the break; the swing labelling that classifies each pivot against its predecessor; the order block extraction that locates the origin candle of each structural leg and builds a zone from it, with separate internal and swing pools, mitigation tracking and capped storage; the equal high and equal low detector with its ATR-relative tolerance; the fair value gap engine with its adaptive significance threshold; the strong and weak extreme classifier driven by the swing trend; the premium, equilibrium and discount partition of the trailing swing range; the multi-timeframe previous period level layer; and the alert framework.

This declaration is made for this specific version of the script, version 6.0, July 2026. Any future modified version I publish will carry its own updated declaration in the script header.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ORIGINAL INDICATOR SCRIPT IMPLEMENTATION VERIFICATION AND DECLARATION

I verify and declare that this script is an original implementation authored from scratch by Expert_Markets_Insights. No portion of this code was copied, ported, decompiled, translated, reverse-engineered or adapted from any other author's closed-source, invite-only, protected or open-source script. No third-party library and no republished open-source script forms any part of this work, and no other author's structure engine, order block logic or visual system was reproduced.

I acknowledge openly and without reservation that every trading concept implemented here is public and very widely taught. Market structure, the break of structure and the change of character, higher highs and lower lows, order blocks, fair value gaps, equal highs and equal lows as liquidity, strong and weak extremes, premium and discount pricing against a range, and previous higher-timeframe levels, are all common knowledge across the trading community. They are taught freely in countless articles, videos and courses, they belong to no single author, and I claim ownership of none of them.

My original contribution, and what this declaration covers, is the specific code implementation: my own dual-layer structure state machine, my own crossed-level guard, my own break classifier, my own order block extraction and mitigation model, my own ATR-relative equal-level tolerance, my own adaptive fair value gap threshold, my own strong and weak classifier, my own range partition, and my own presentation layer.

Because these concepts are so widely implemented, conceptual and visual overlap with other smart money tools is unavoidable and fully expected. Two honest authors implementing the break of structure will produce charts that look similar, because they are both drawing the same publicly taught idea, and neither of them invented it. What I declare is that there is no source-code overlap of any kind with any other author's work, and that every line in this script is mine.

The full commented source, including both of these declarations and the note on the framework, is contained in the script header.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DISCLAIMER

This tool is for educational and informational purposes only. It does not constitute financial advice. Trading involves risk and past patterns do not guarantee future results. Smart money concepts are an interpretive framework rather than verified fact, and no structure label, zone or level produced by this indicator is a recommendation to enter or exit any position. Use proper risk management, test thoroughly on your own instruments and timeframes, and consult a licensed financial advisor before trading real capital. All trading decisions and all risk taken remain entirely your own responsibility.

---

## Source Code

````pine
//@version=6
// ==============================================================================================
//              S M A R T   M O N E Y   C O N C E P T   L E V E L S   F I L T E R
// ==============================================================================================
//
//  Indicator Name : Smart Money Concept Levels Filter
//  Author         : Expert_Markets_Insights
//  Version        : v6.0 - July 2026
//  Pine Version   : Pine Script v6
//  Script Type    : Overlay indicator (plots on the price chart)
//
// ----------------------------------------------------------------------------------------------
//  A U T H O R   V E R I F I C A T I O N   D E C L A R A T I O N
// ----------------------------------------------------------------------------------------------
//  I am Expert_Markets_Insights, the publisher and sole original author of this exact
//  implementation of "Smart Money Concept Levels Filter." I designed the architecture of this
//  tool, wrote every line of the Pine Script v6 code contained in this file, tested it across
//  multiple asset classes and timeframes, and I take full and sole ownership and responsibility
//  for it.
//
//  Specifically, I independently designed and coded: the dual structure engine that tracks an
//  internal and a swing layer with independent pivot lengths, independent trend state and
//  independent break bookkeeping; the crossed-level guard that prevents a single pivot from firing
//  repeatedly; the break classifier that decides between a break of structure and a change of
//  character from the trend state at the moment of the break; the swing labelling that classifies
//  each pivot as a higher high, higher low, lower high or lower low against its predecessor; the
//  order block extraction that locates the origin candle of each structural leg and builds a zone
//  from it, with separate internal and swing pools, mitigation tracking and capped storage; the
//  equal high and equal low detector with its ATR-relative tolerance; the fair value gap engine
//  with its adaptive significance threshold; the strong and weak extreme classifier driven by the
//  swing trend; the premium, equilibrium and discount partition of the trailing swing range; the
//  multi-timeframe previous period level layer; and the alert framework.
//
//  This declaration is made for this specific version of the script (v6.0, July 2026). Any future
//  modified version I publish will carry its own updated declaration in this same header.
//
// ----------------------------------------------------------------------------------------------
//  O R I G I N A L   I N D I C A T O R   S C R I P T   I M P L E M E N T A T I O N
//  V E R I F I C A T I O N   A N D   D E C L A R A T I O N
// ----------------------------------------------------------------------------------------------
//  I verify and declare that this script is an original implementation authored from scratch by
//  Expert_Markets_Insights. No portion of this code was copied, ported, decompiled, translated,
//  reverse-engineered or adapted from any other author's closed-source, invite-only, protected or
//  open-source script. No third-party library and no republished open-source script forms any
//  part of this work, and no other author's structure engine, order block logic or visual system
//  was reproduced.
//
//  I acknowledge openly and without reservation that every trading concept implemented here is
//  public and very widely taught. Market structure, the break of structure and the change of
//  character, higher highs and lower lows, order blocks, fair value gaps, equal highs and equal
//  lows as liquidity, strong and weak extremes, premium and discount pricing against a range, and
//  previous higher-timeframe levels, are all common knowledge across the trading community. They
//  belong to no single author, they are taught freely in countless free courses and articles, and
//  I claim ownership of none of them.
//
//  My original contribution, and what this declaration covers, is the specific code
//  implementation: my own dual-layer structure state machine, my own crossed-level guard, my own
//  break classifier, my own order block extraction and mitigation model, my own ATR-relative
//  equal-level tolerance, my own adaptive fair value gap threshold, my own strong and weak
//  classifier, my own range partition, and my own presentation layer.
//
//  Because these concepts are so widely implemented, conceptual and visual overlap with other
//  smart money tools is unavoidable and fully expected. Two honest authors implementing the break
//  of structure will produce charts that look similar, because they are both drawing the same
//  publicly taught idea. What I declare is that there is no source-code overlap of any kind with
//  any other author's work, and that every line here is mine.
//
// ----------------------------------------------------------------------------------------------
//  W H A T   T H I S   I N D I C A T O R   D O E S
// ----------------------------------------------------------------------------------------------
//  This tool maps the price-action framework commonly taught as smart money concepts, and it does
//  so on two zoom levels at once so short-term and larger-picture structure are visible together.
//
//  1) DUAL MARKET STRUCTURE
//     Two independent structure layers run side by side. The swing layer uses a long pivot length
//     and draws with solid lines: this is the larger picture. The internal layer uses a short
//     pivot length and draws with dashed lines: this is the structure inside the swing. Each has
//     its own trend state, so the two can and often do disagree, which is itself informative.
//
//  2) BREAK OF STRUCTURE AND CHANGE OF CHARACTER
//     When price closes through the most recent pivot, the engine labels the event. If the break
//     continues the layer's existing trend it is a break of structure, a continuation. If it
//     reverses the trend it is a change of character, the first warning of a possible turn. The
//     distinction is made from the trend state at the instant of the break, not in hindsight.
//
//  3) SWING POINT CLASSIFICATION
//     Every confirmed pivot is optionally labelled as a higher high, higher low, lower high or
//     lower low against its predecessor, which is the raw grammar of trend.
//
//  4) ORDER BLOCKS
//     Each structural break leaves an order block: the origin candle of the leg that produced it.
//     Internal and swing breaks maintain separate pools with their own colours. A block is
//     mitigated and removed once price closes decisively through it.
//
//  5) EQUAL HIGHS AND EQUAL LOWS
//     Consecutive pivots landing within an ATR-relative tolerance of each other are marked as
//     equal highs or equal lows and joined by a dotted line. These are the resting-liquidity
//     levels the methodology expects to be swept.
//
//  6) FAIR VALUE GAPS
//     Three-candle imbalances are detected and filtered by an adaptive threshold derived from the
//     instrument's own recent gap sizes, so only genuinely significant gaps are drawn.
//
//  7) STRONG AND WEAK EXTREMES
//     The extreme that originated the current swing trend is labelled strong; the extreme formed
//     against it is labelled weak. A strong high in a bearish market is a level with a reason to
//     hold; a weak low is one with far less behind it.
//
//  8) PREMIUM, EQUILIBRIUM AND DISCOUNT
//     The trailing swing range is partitioned so that the expensive upper zone, the fair middle
//     and the cheap lower zone are visible at a glance.
//
//  9) MULTI-TIMEFRAME LEVELS
//     The previous daily, weekly and monthly highs and lows are extended across the chart as
//     higher-timeframe reference, whatever timeframe you are working on.
//
// ----------------------------------------------------------------------------------------------
//  H O N E S T   N O T E
// ----------------------------------------------------------------------------------------------
//  Smart money concepts are an interpretive framework, not a description of verified fact. This
//  tool marks structure exactly as the methodology defines it. It cannot see institutional orders,
//  it cannot know intent, and the words order block and liquidity name concepts from the framework
//  rather than observed order-book data. No retail charting tool can observe institutional flow,
//  and this one makes no such claim.
//
//  A change of character is a warning, not a reversal. A break of structure is a continuation
//  signal, not a guarantee. Every level here can and sometimes will fail.
//
// ----------------------------------------------------------------------------------------------
//  L I V E   B E H A V I O U R   A N D   R E P A I N T I N G   S T A T E M E N T
// ----------------------------------------------------------------------------------------------
//  A pivot is confirmed only after the required bars have formed to its right, which is inherent
//  to every pivot-based tool. Once confirmed, a pivot never moves. Structure breaks, order block
//  creation, mitigation, equal-level marking and gap detection are all evaluated on confirmed
//  bars, so a printed break of structure, change of character or order block never disappears from
//  history and never changes side.
//
//  The strong and weak labels, the premium and discount partition and the previous higher-
//  timeframe levels describe the present state and update live, which is their purpose. The
//  multi-timeframe levels are requested with lookahead disabled, so no future higher-timeframe
//  data can reach a past bar.
//
// ----------------------------------------------------------------------------------------------
//  D I S C L A I M E R
// ----------------------------------------------------------------------------------------------
//  This tool is for educational and informational purposes only. It does not constitute financial
//  advice. Trading involves risk; past patterns do not guarantee future results. Use proper risk
//  management and consult a licensed financial advisor before trading real capital.
// ==============================================================================================

indicator("Smart Money Concept Levels Filter", "SMC Levels", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_bars_back = 1000)

// ----------------------------------------------------------------------------------------------
//  I N P U T S
// ----------------------------------------------------------------------------------------------
gInt = "=====  INTERNAL STRUCTURE  ====="
intOn    = input.bool(true, "Show Internal Structure", group = gInt)
intLen   = input.int(5, "Internal Pivot Length", minval = 2, maxval = 50, group = gInt)
intFilter= input.string("All", "Internal Labels", options = ["All", "BOS Only", "CHoCH Only"], group = gInt)

gSw = "=====  SWING STRUCTURE  ====="
swOn     = input.bool(true, "Show Swing Structure", group = gSw)
swLen    = input.int(25, "Swing Pivot Length", minval = 3, maxval = 200, group = gSw)
swFilter = input.string("All", "Swing Labels", options = ["All", "BOS Only", "CHoCH Only"], group = gSw)
showPts  = input.bool(false, "Show Swing Points (HH / HL / LH / LL)", group = gSw)

gOb = "=====  ORDER BLOCKS  ====="
obIntOn  = input.bool(true, "Internal Order Blocks", group = gOb, inline = "a")
obIntN   = input.int(5, "", minval = 1, maxval = 20, group = gOb, inline = "a")
obSwOn   = input.bool(true, "Swing Order Blocks", group = gOb, inline = "b")
obSwN    = input.int(5, "", minval = 1, maxval = 20, group = gOb, inline = "b")
obSource = input.string("Wick", "Zone Built From", options = ["Wick", "Body"], group = gOb)
obMitig  = input.string("Close", "Mitigation Basis", options = ["Close", "Wick"], group = gOb)
obText   = input.bool(true, "Write 'Order Block' Inside Zone", group = gOb)
obTxtCol = input.color(color.black, "Zone Text Colour", group = gOb)
obTxtSz  = input.string("Tiny", "Zone Text Size", options = ["Tiny", "Small", "Normal"], group = gOb)

string szOb = obTxtSz == "Small" ? size.small : obTxtSz == "Normal" ? size.normal : size.tiny

gEq = "=====  EQUAL HIGHS AND LOWS  ====="
eqOn     = input.bool(true, "Show Equal Highs / Lows", group = gEq)
eqLen    = input.int(3, "Equal Level Pivot Length", minval = 2, maxval = 50, group = gEq)
eqTol    = input.float(0.10, "Tolerance (x ATR)", minval = 0.01, maxval = 2, step = 0.01, group = gEq)

gFvg = "=====  FAIR VALUE GAPS  ====="
fvgOn    = input.bool(false, "Show Fair Value Gaps", group = gFvg)
fvgAuto  = input.bool(true, "Adaptive Significance Threshold", group = gFvg, tooltip = "Filters out gaps that are small relative to this instrument's own recent gaps.")
fvgMult  = input.float(1.0, "Threshold Strength", minval = 0.1, maxval = 5, step = 0.1, group = gFvg)
fvgExt   = input.int(20, "Gap Extend (bars)", minval = 1, maxval = 200, group = gFvg)

gExt = "=====  STRONG / WEAK EXTREMES  ====="
swkOn    = input.bool(true, "Show Strong / Weak High and Low", group = gExt)

gPd = "=====  PREMIUM / DISCOUNT  ====="
pdOn     = input.bool(false, "Show Premium / Equilibrium / Discount", group = gPd)
pdPrem   = input.float(95, "Premium Starts At (percent of range)", minval = 55, maxval = 99, step = 1, group = gPd)
pdDisc   = input.float(5,  "Discount Ends At (percent of range)",  minval = 1,  maxval = 45, step = 1, group = gPd)
pdEq     = input.float(5,  "Equilibrium Half Width (percent)",     minval = 1,  maxval = 25, step = 1, group = gPd)

gMtf = "=====  MULTI-TIMEFRAME LEVELS  ====="
mtfD     = input.bool(false, "Previous Daily High / Low",   group = gMtf)
mtfW     = input.bool(false, "Previous Weekly High / Low",  group = gMtf)
mtfM     = input.bool(false, "Previous Monthly High / Low", group = gMtf)

gSty = "=====  STYLE  ====="
colBull  = input.color(#089981, "Bullish Structure", group = gSty, inline = "a")
colBear  = input.color(#f23645, "Bearish Structure", group = gSty, inline = "a")
colObB   = input.color(#3179f5, "Bullish Order Block", group = gSty, inline = "b")
colObS   = input.color(#f23645, "Bearish Order Block", group = gSty, inline = "b")
obTrans  = input.int(85, "Order Block Transparency", minval = 50, maxval = 99, group = gSty)
colEq    = input.color(#787b86, "Equal Levels", group = gSty)
colFvgB  = input.color(#089981, "Bullish Gap", group = gSty, inline = "c")
colFvgS  = input.color(#f23645, "Bearish Gap", group = gSty, inline = "c")
colMtf   = input.color(#b2b5be, "MTF Levels", group = gSty)
atrLen   = input.int(14, "ATR Length", minval = 2, maxval = 200, group = gSty)

float atr = ta.atr(atrLen)

// ----------------------------------------------------------------------------------------------
//  S T R U C T U R E   S T A T E
//  Two independent layers. Each holds its most recent confirmed pivot high and low, whether that
//  pivot has already been broken, and its own trend direction.
// ----------------------------------------------------------------------------------------------
// internal layer
var float iTopP = na
var int   iTopB = na
var bool  iTopX = true
var float iBtmP = na
var int   iBtmB = na
var bool  iBtmX = true
var int   iTrend = 0

// swing layer
var float sTopP = na
var int   sTopB = na
var bool  sTopX = true
var float sBtmP = na
var int   sBtmB = na
var bool  sBtmX = true
var int   sTrend = 0

// previous pivots, used for the higher-high / lower-low classification and for equal levels
var float prevSwTop = na
var float prevSwBtm = na

// swing extremes that define the strong and weak labels
var float strongHi = na
var int   strongHiB = na
var float weakLo   = na
var int   weakLoB  = na
var float strongLo = na
var int   strongLoB = na
var float weakHi   = na
var int   weakHiB  = na

// ----------------------------------------------------------------------------------------------
//  P I V O T S
// ----------------------------------------------------------------------------------------------
float iPh = ta.pivothigh(high, intLen, intLen)
float iPl = ta.pivotlow(low,  intLen, intLen)
float sPh = ta.pivothigh(high, swLen,  swLen)
float sPl = ta.pivotlow(low,   swLen,  swLen)
float ePh = ta.pivothigh(high, eqLen,  eqLen)
float ePl = ta.pivotlow(low,   eqLen,  eqLen)

// ----------------------------------------------------------------------------------------------
//  O R D E R   B L O C K   T Y P E   A N D   P O O L S
// ----------------------------------------------------------------------------------------------
type OB
    float top
    float bot
    int   left
    bool  isBull
    bool  isSwing
    box   bx

var array<OB> obList = array.new<OB>()

method wipe(OB z) =>
    box.delete(z.bx)

// find the origin candle of a structural leg and build a zone from it
// bullish break -> the lowest bar of the leg is the origin; bearish break -> the highest bar
buildOB(int fromBar, bool isBull, bool isSwing) =>
    int span = math.max(1, math.min(bar_index - fromBar, 200))
    int bestOff = 1
    float bestVal = isBull ? 1e20 : -1e20
    for k = 1 to span
        float v = isBull ? low[k] : high[k]
        if (isBull and v < bestVal) or (not isBull and v > bestVal)
            bestVal := v
            bestOff := k
    OB z = OB.new()
    float bTop = obSource == "Body" ? math.max(open[bestOff], close[bestOff]) : high[bestOff]
    float bBot = obSource == "Body" ? math.min(open[bestOff], close[bestOff]) : low[bestOff]
    if bTop <= bBot
        bTop := high[bestOff]
        bBot := low[bestOff]
    z.top := bTop
    z.bot := bBot
    z.left := bar_index - bestOff
    z.isBull := isBull
    z.isSwing := isSwing
    z.bx := na
    z

// keep each pool inside its configured size
trimPool(bool isSwing, int keep) =>
    int count = 0
    if obList.size() > 0
        for m = obList.size() - 1 to 0
            OB z = obList.get(m)
            if z.isSwing == isSwing
                count += 1
                if count > keep
                    z.wipe()
                    obList.remove(m)

// ----------------------------------------------------------------------------------------------
//  S T R U C T U R E   D R A W I N G   H E L P E R
// ----------------------------------------------------------------------------------------------
drawBreak(float lvl, int fromBar, bool isBull, bool isSwing, bool isBOS) =>
    color c = isBull ? colBull : colBear
    line ln = line.new(fromBar, lvl, bar_index, lvl, xloc = xloc.bar_index, color = c, width = 1, style = isSwing ? line.style_solid : line.style_dashed)
    string txt = isBOS ? "BOS" : "CHoCH"
    int midB = math.round((fromBar + bar_index) / 2.0)
    label.new(midB, lvl, txt, xloc = xloc.bar_index, style = label.style_none, textcolor = c, size = isSwing ? size.small : size.tiny)

allowLabel(string filter, bool isBOS) =>
    filter == "All" or (filter == "BOS Only" and isBOS) or (filter == "CHoCH Only" and not isBOS)

// ----------------------------------------------------------------------------------------------
//  I N T E R N A L   S T R U C T U R E   E N G I N E
// ----------------------------------------------------------------------------------------------
bool iBosBull = false
bool iBosBear = false
bool iChoBull = false
bool iChoBear = false

if barstate.isconfirmed
    if not na(iPh)
        iTopP := iPh
        iTopB := bar_index - intLen
        iTopX := false
    if not na(iPl)
        iBtmP := iPl
        iBtmB := bar_index - intLen
        iBtmX := false

    // bullish break of the internal top
    if intOn and not iTopX and not na(iTopP) and close > iTopP
        bool isBOS = iTrend == 1
        if allowLabel(intFilter, isBOS)
            drawBreak(iTopP, iTopB, true, false, isBOS)
        if isBOS
            iBosBull := true
        else
            iChoBull := true
        if obIntOn
            obList.push(buildOB(iTopB, true, false))
            trimPool(false, obIntN)
        iTrend := 1
        iTopX := true

    // bearish break of the internal bottom
    if intOn and not iBtmX and not na(iBtmP) and close < iBtmP
        bool isBOS = iTrend == -1
        if allowLabel(intFilter, isBOS)
            drawBreak(iBtmP, iBtmB, false, false, isBOS)
        if isBOS
            iBosBear := true
        else
            iChoBear := true
        if obIntOn
            obList.push(buildOB(iBtmB, false, false))
            trimPool(false, obIntN)
        iTrend := -1
        iBtmX := true

// ----------------------------------------------------------------------------------------------
//  S W I N G   S T R U C T U R E   E N G I N E   +   S W I N G   P O I N T   L A B E L S
// ----------------------------------------------------------------------------------------------
bool sBosBull = false
bool sBosBear = false
bool sChoBull = false
bool sChoBear = false

if barstate.isconfirmed
    if not na(sPh)
        // classify this pivot against its predecessor
        if showPts and swOn
            string t = na(prevSwTop) ? "H" : (sPh > prevSwTop ? "HH" : "LH")
            label.new(bar_index - swLen, sPh, t, xloc = xloc.bar_index, style = label.style_label_down, color = color.new(colBear, 100), textcolor = colBear, size = size.tiny)
        prevSwTop := sPh
        sTopP := sPh
        sTopB := bar_index - swLen
        sTopX := false

    if not na(sPl)
        if showPts and swOn
            string t = na(prevSwBtm) ? "L" : (sPl > prevSwBtm ? "HL" : "LL")
            label.new(bar_index - swLen, sPl, t, xloc = xloc.bar_index, style = label.style_label_up, color = color.new(colBull, 100), textcolor = colBull, size = size.tiny)
        prevSwBtm := sPl
        sBtmP := sPl
        sBtmB := bar_index - swLen
        sBtmX := false

    // bullish break of the swing top
    if swOn and not sTopX and not na(sTopP) and close > sTopP
        bool isBOS = sTrend == 1
        if allowLabel(swFilter, isBOS)
            drawBreak(sTopP, sTopB, true, true, isBOS)
        if isBOS
            sBosBull := true
        else
            sChoBull := true
        if obSwOn
            obList.push(buildOB(sTopB, true, true))
            trimPool(true, obSwN)
        sTrend := 1
        sTopX := true
        // a bullish swing trend makes the origin low strong and the countertrend high weak
        strongLo := sBtmP
        strongLoB := sBtmB
        weakHi := sTopP
        weakHiB := sTopB

    // bearish break of the swing bottom
    if swOn and not sBtmX and not na(sBtmP) and close < sBtmP
        bool isBOS = sTrend == -1
        if allowLabel(swFilter, isBOS)
            drawBreak(sBtmP, sBtmB, false, true, isBOS)
        if isBOS
            sBosBear := true
        else
            sChoBear := true
        if obSwOn
            obList.push(buildOB(sBtmB, false, true))
            trimPool(true, obSwN)
        sTrend := -1
        sBtmX := true
        // a bearish swing trend makes the origin high strong and the countertrend low weak
        strongHi := sTopP
        strongHiB := sTopB
        weakLo := sBtmP
        weakLoB := sBtmB

// ----------------------------------------------------------------------------------------------
//  O R D E R   B L O C K   M I T I G A T I O N   A N D   R E N D E R I N G
// ----------------------------------------------------------------------------------------------
bool obMitigated = false

if barstate.isconfirmed and obList.size() > 0
    float refUp = obMitig == "Close" ? close : high
    float refDn = obMitig == "Close" ? close : low
    for m = obList.size() - 1 to 0
        OB z = obList.get(m)
        bool gone = z.isBull ? refDn < z.bot : refUp > z.top
        if gone
            z.wipe()
            obList.remove(m)
            obMitigated := true

if barstate.islast and obList.size() > 0
    for m = 0 to obList.size() - 1
        OB z = obList.get(m)
        box.delete(z.bx)
        color c = z.isBull ? colObB : colObS
        z.bx := box.new(z.left, z.top, bar_index + 12, z.bot, xloc = xloc.bar_index, border_color = color.new(c, z.isSwing ? 55 : 80), border_width = 1, bgcolor = color.new(c, z.isSwing ? obTrans - 6 : obTrans), text = obText ? "Order Block" : "", text_color = obTxtCol, text_size = szOb, text_halign = text.align_center, text_valign = text.align_center)

// ----------------------------------------------------------------------------------------------
//  E Q U A L   H I G H S   A N D   E Q U A L   L O W S
//  Consecutive pivots landing within an ATR-relative tolerance are resting liquidity.
// ----------------------------------------------------------------------------------------------
var float lastEqTop = na
var int   lastEqTopB = na
var float lastEqBtm = na
var int   lastEqBtmB = na

bool eqhFound = false
bool eqlFound = false

if barstate.isconfirmed and eqOn and not na(atr)
    float tol = atr * eqTol
    if not na(ePh)
        int b = bar_index - eqLen
        if not na(lastEqTop) and math.abs(ePh - lastEqTop) <= tol
            line.new(lastEqTopB, lastEqTop, b, ePh, xloc = xloc.bar_index, color = color.new(colEq, 20), style = line.style_dotted, width = 1)
            label.new(math.round((lastEqTopB + b) / 2.0), math.max(ePh, lastEqTop), "EQH", xloc = xloc.bar_index, style = label.style_none, textcolor = colEq, size = size.tiny)
            eqhFound := true
        lastEqTop := ePh
        lastEqTopB := b
    if not na(ePl)
        int b = bar_index - eqLen
        if not na(lastEqBtm) and math.abs(ePl - lastEqBtm) <= tol
            line.new(lastEqBtmB, lastEqBtm, b, ePl, xloc = xloc.bar_index, color = color.new(colEq, 20), style = line.style_dotted, width = 1)
            label.new(math.round((lastEqBtmB + b) / 2.0), math.min(ePl, lastEqBtm), "EQL", xloc = xloc.bar_index, style = label.style_none, textcolor = colEq, size = size.tiny)
            eqlFound := true
        lastEqBtm := ePl
        lastEqBtmB := b

// ----------------------------------------------------------------------------------------------
//  F A I R   V A L U E   G A P S
//  Three-candle imbalance, filtered by an adaptive threshold built from this instrument's own
//  recent gap sizes rather than from a fixed number.
// ----------------------------------------------------------------------------------------------
var float gapSum = 0.0
var int   gapCnt = 0

bool newFvgUp = false
bool newFvgDn = false

if barstate.isconfirmed and fvgOn
    bool up = low > high[2]
    bool dn = high < low[2]
    float gapSz = up ? low - high[2] : dn ? low[2] - high : 0.0
    if gapSz > 0
        gapSum += gapSz
        gapCnt += 1
    float avgGap = gapCnt > 0 ? gapSum / gapCnt : 0.0
    float thr = fvgAuto ? avgGap * fvgMult : 0.0
    if up and gapSz > thr
        box.new(bar_index - 2, low, bar_index + fvgExt, high[2], xloc = xloc.bar_index, border_color = color.new(colFvgB, 100), bgcolor = color.new(colFvgB, 86))
        newFvgUp := true
    if dn and gapSz > thr
        box.new(bar_index - 2, low[2], bar_index + fvgExt, high, xloc = xloc.bar_index, border_color = color.new(colFvgS, 100), bgcolor = color.new(colFvgS, 86))
        newFvgDn := true

// ----------------------------------------------------------------------------------------------
//  S T R O N G   A N D   W E A K   E X T R E M E S
// ----------------------------------------------------------------------------------------------
var line  shLn = na
var label shLb = na
var line  wlLn = na
var label wlLb = na

if barstate.islast
    line.delete(shLn)
    label.delete(shLb)
    line.delete(wlLn)
    label.delete(wlLb)

    if swkOn
        int rx = bar_index + 30
        if sTrend == -1
            // bearish swing trend: the origin high is strong, the countertrend low is weak
            if not na(strongHi)
                shLn := line.new(strongHiB, strongHi, rx, strongHi, xloc = xloc.bar_index, color = color.new(colBear, 25), width = 1)
                shLb := label.new(rx, strongHi, "Strong High", xloc = xloc.bar_index, style = label.style_none, textcolor = colBear, size = size.small)
            if not na(weakLo)
                wlLn := line.new(weakLoB, weakLo, rx, weakLo, xloc = xloc.bar_index, color = color.new(colBull, 25), width = 1)
                wlLb := label.new(rx, weakLo, "Weak Low", xloc = xloc.bar_index, style = label.style_none, textcolor = colBull, size = size.small)
        else if sTrend == 1
            if not na(strongLo)
                wlLn := line.new(strongLoB, strongLo, rx, strongLo, xloc = xloc.bar_index, color = color.new(colBull, 25), width = 1)
                wlLb := label.new(rx, strongLo, "Strong Low", xloc = xloc.bar_index, style = label.style_none, textcolor = colBull, size = size.small)
            if not na(weakHi)
                shLn := line.new(weakHiB, weakHi, rx, weakHi, xloc = xloc.bar_index, color = color.new(colBear, 25), width = 1)
                shLb := label.new(rx, weakHi, "Weak High", xloc = xloc.bar_index, style = label.style_none, textcolor = colBear, size = size.small)

// ----------------------------------------------------------------------------------------------
//  P R E M I U M   /   E Q U I L I B R I U M   /   D I S C O U N T
//  The trailing swing range partitioned into an expensive upper zone, a fair middle and a cheap
//  lower zone.
// ----------------------------------------------------------------------------------------------
var box  pBox = na
var box  eBox = na
var box  dBox = na
var label pLb = na
var label eLb = na
var label dLb = na

if barstate.islast
    box.delete(pBox)
    box.delete(eBox)
    box.delete(dBox)
    label.delete(pLb)
    label.delete(eLb)
    label.delete(dLb)

    if pdOn and not na(sTopP) and not na(sBtmP) and sTopP > sBtmP
        float rng = sTopP - sBtmP
        int lx = math.min(nz(sTopB, bar_index), nz(sBtmB, bar_index))
        int rx = bar_index + 12

        float pLo = sBtmP + rng * pdPrem / 100.0
        float dHi = sBtmP + rng * pdDisc / 100.0
        float eMid = sBtmP + rng * 0.5
        float eHi = eMid + rng * pdEq / 200.0
        float eLo = eMid - rng * pdEq / 200.0

        pBox := box.new(lx, sTopP, rx, pLo, xloc = xloc.bar_index, border_color = color.new(colBear, 80), bgcolor = color.new(colBear, 88))
        eBox := box.new(lx, eHi, rx, eLo, xloc = xloc.bar_index, border_color = color.new(colEq, 80), bgcolor = color.new(colEq, 88))
        dBox := box.new(lx, dHi, rx, sBtmP, xloc = xloc.bar_index, border_color = color.new(colBull, 80), bgcolor = color.new(colBull, 88))

        pLb := label.new(rx, sTopP, "Premium", xloc = xloc.bar_index, style = label.style_none, textcolor = colBear, size = size.tiny)
        eLb := label.new(rx, eMid, "Equilibrium", xloc = xloc.bar_index, style = label.style_none, textcolor = colEq, size = size.tiny)
        dLb := label.new(rx, sBtmP, "Discount", xloc = xloc.bar_index, style = label.style_none, textcolor = colBull, size = size.tiny)

// ----------------------------------------------------------------------------------------------
//  M U L T I - T I M E F R A M E   L E V E L S
//  Previous completed period high and low, requested with lookahead disabled.
// ----------------------------------------------------------------------------------------------
// Requested directly rather than through a helper: request.security needs a simple timeframe
// string, and a function parameter would be series-qualified.
float dH = request.security(syminfo.tickerid, "D", high[1], lookahead = barmerge.lookahead_off)
float dL = request.security(syminfo.tickerid, "D", low[1],  lookahead = barmerge.lookahead_off)
float wH = request.security(syminfo.tickerid, "W", high[1], lookahead = barmerge.lookahead_off)
float wL = request.security(syminfo.tickerid, "W", low[1],  lookahead = barmerge.lookahead_off)
float mH = request.security(syminfo.tickerid, "M", high[1], lookahead = barmerge.lookahead_off)
float mL = request.security(syminfo.tickerid, "M", low[1],  lookahead = barmerge.lookahead_off)

var array<line>  mtfLn = array.new<line>()
var array<label> mtfLb = array.new<label>()

drawMtf(bool on, float hi, float lo, string tag) =>
    if on and not na(hi) and not na(lo)
        int lx = math.max(0, bar_index - 120)
        int rx = bar_index + 20
        line l1 = line.new(lx, hi, rx, hi, xloc = xloc.bar_index, color = color.new(colMtf, 35), style = line.style_dotted, width = 1)
        line l2 = line.new(lx, lo, rx, lo, xloc = xloc.bar_index, color = color.new(colMtf, 35), style = line.style_dotted, width = 1)
        mtfLn.push(l1)
        mtfLn.push(l2)
        mtfLb.push(label.new(rx, hi, tag + "H", xloc = xloc.bar_index, style = label.style_none, textcolor = colMtf, size = size.tiny))
        mtfLb.push(label.new(rx, lo, tag + "L", xloc = xloc.bar_index, style = label.style_none, textcolor = colMtf, size = size.tiny))

if barstate.islast
    if mtfLn.size() > 0
        for l in mtfLn
            line.delete(l)
        mtfLn.clear()
    if mtfLb.size() > 0
        for l in mtfLb
            label.delete(l)
        mtfLb.clear()
    drawMtf(mtfD, dH, dL, "PD")
    drawMtf(mtfW, wH, wL, "PW")
    drawMtf(mtfM, mH, mL, "PM")

// ----------------------------------------------------------------------------------------------
//  A L E R T S
// ----------------------------------------------------------------------------------------------
alertcondition(iBosBull or iBosBear, "SMC - Internal BOS",   "Smart Money Concept Levels Filter: an internal break of structure occurred on {{ticker}} {{interval}}.")
alertcondition(iChoBull or iChoBear, "SMC - Internal CHoCH", "Smart Money Concept Levels Filter: an internal change of character occurred on {{ticker}} {{interval}}.")
alertcondition(sBosBull or sBosBear, "SMC - Swing BOS",      "Smart Money Concept Levels Filter: a swing break of structure occurred on {{ticker}} {{interval}}.")
alertcondition(sChoBull or sChoBear, "SMC - Swing CHoCH",    "Smart Money Concept Levels Filter: a swing change of character occurred on {{ticker}} {{interval}}.")
alertcondition(sBosBull or sChoBull, "SMC - Bullish Swing Break", "Smart Money Concept Levels Filter: a bullish swing structure break occurred on {{ticker}} {{interval}}.")
alertcondition(sBosBear or sChoBear, "SMC - Bearish Swing Break", "Smart Money Concept Levels Filter: a bearish swing structure break occurred on {{ticker}} {{interval}}.")
alertcondition(eqhFound, "SMC - Equal Highs", "Smart Money Concept Levels Filter: equal highs formed on {{ticker}} {{interval}}.")
alertcondition(eqlFound, "SMC - Equal Lows",  "Smart Money Concept Levels Filter: equal lows formed on {{ticker}} {{interval}}.")
alertcondition(newFvgUp, "SMC - Bullish Fair Value Gap", "Smart Money Concept Levels Filter: a bullish fair value gap formed on {{ticker}} {{interval}}.")
alertcondition(newFvgDn, "SMC - Bearish Fair Value Gap", "Smart Money Concept Levels Filter: a bearish fair value gap formed on {{ticker}} {{interval}}.")
alertcondition(obMitigated, "SMC - Order Block Mitigated", "Smart Money Concept Levels Filter: an order block was mitigated on {{ticker}} {{interval}}.")

if sChoBull or sChoBear
    alert("SMC Swing CHoCH - " + syminfo.ticker + " " + timeframe.period, alert.freq_once_per_bar_close)
if sBosBull or sBosBear
    alert("SMC Swing BOS - " + syminfo.ticker + " " + timeframe.period, alert.freq_once_per_bar_close)

// ----------------------------------------------------------------------------------------------
//  D A T A   W I N D O W   O U T P U T S
// ----------------------------------------------------------------------------------------------
plot(iTrend,       "Internal Trend",   color = color.new(color.orange, 100), display = display.data_window)
plot(sTrend,       "Swing Trend",      color = color.new(color.orange, 100), display = display.data_window)
plot(obList.size(),"Order Blocks Live",color = color.new(color.orange, 100), display = display.data_window)
plot(strongHi,     "Strong High",      color = color.new(color.orange, 100), display = display.data_window)
plot(weakLo,       "Weak Low",         color = color.new(color.orange, 100), display = display.data_window)
````
