<!-- tradingview-pine-id: PUB;9a0636e397d24a858390f331e9e16850 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# MarketMaulers Auto Trendlines

Source: https://www.tradingview.com/script/rAp1tPZr-MarketMaulers-Auto-Trendlines/

## Description

MarketMaulers Auto Trendlines draws the diagonal structure you would have drawn yourself, and then stays with the line through the part that matters. Two confirmed pivots anchor it, the market's own touches validate it, and its parallel rail is projected through the furthest price travelled while the line was forming. Then it waits for the break, and reports which of the only two things that can follow a break took place.

Forming · Validated · Broken · Retested / Failed break

THE RETEST IS THE PRODUCT
Anyone can draw a line through two pivots and print a marker when price closes through it. The break is the least informative moment in a trendline's life. Most lines break, and the break on its own says nothing about whether the level still matters.

Two things can follow, and they mean opposite things.
• RETEST. Price comes back and respects the line from the OTHER side. Old support is now resistance. The line survived its own break as a reference and is arguably more useful after it than before.
• FAILED BREAK. Price closes straight back on the original side. The break was noise, the line was never beaten, and anyone who traded the break is offside.

This tool waits for one of those and names it. That is the read you cannot get by eyeballing the chart in the moment, because in the moment the two look identical.

FROM ZERO: WHY A DIAGONAL LINE IS A DIFFERENT ANIMAL FROM A HORIZONTAL ONE
A horizontal level is a price. It sits at one number and it is still that number tomorrow. A trendline is a price AND a rate. It asks the market to keep making higher lows at a certain speed, or lower highs at a certain speed. That is a much stronger claim, which is why trendlines break more often than horizontal levels and why the break carries less information when they do.

It is also why a line has to be earned rather than drawn. Two points define any line at all. Three or more touches is the market repeatedly agreeing to the rate.

HOW A LINE EARNS ITS PLACE
Five gates, each closing a specific way auto-trendline scripts produce clutter.
• Confirmed pivots only, paired for direction. A rising support line needs a second swing low strictly HIGHER than the first, a falling resistance line a second high strictly lower. A zero slope is unreachable by construction, so this file never draws a horizontal line.
• A cleanliness scan. Every bar between the two anchors is checked for a close through the line. A line price has already spent time on the wrong side of was never a valid line, and drawing it anyway is how a chart fills with lines nobody would have drawn by hand.
• Touch counting with a spacing rule. A touch is a bar reaching within a quarter of an ATR of the line, and touches within three bars of each other count once. Without the spacing rule one slow drift along a line counts as five touches and validates anything.
• Near-duplicate rejection. Two lines are compared at two sample points, now and fifty bars back, and the newer one is dropped if they sit within 0.75 ATR at BOTH. Comparing at a single point lets two lines with different slopes look identical at the moment they cross.
• A slope cap and abandoned-line retirement. Near-vertical lines off a single spike are refused, and a line price has stayed far away from for twenty consecutive bars is retired. That is what keeps ancient support lines from hanging under current price forever.

TWO WAYS A LINE BREAKS, AND THE SECOND ONE IS THE INTERESTING ONE
The obvious break is distance: a close sitting at least 0.35 ATR beyond the line. That catches the decisive break and it misses the slow one.

Price can park a fraction through a line, too shallow to trigger the distance test and too close to trigger retirement, and grind there bar after bar. Under a distance-only rule the line stays marked VALIDATED with price on the wrong side of it for as long as the grind lasts, which is a tool stating something false. So three consecutive wrong-side closes break a line at any distance. Decisive breaks are caught by distance, grinds by persistence, and there is no state left where the display and the price disagree.

A RETESTED LINE GOES BACK TO WORK
Most implementations treat the retest as the end of a line's life, which is backwards from what the retest proves. A line that broke, was left alone, and then held from the other side has demonstrated it still matters, and the tools that go quiet there stop watching at the exact moment the line earned its keep.

The mechanism is a POLARITY FLIP rather than a new line. Old support becomes resistance, so the side the break test looks at flips while the line's geometric identity does not. It is still a rising line, it keeps its color and its channel offset, and it starts being tested for a break to the upside. The label carries R1, R2, R3 so a twice-proven line is visibly different from a fresh one, and the cycle is capped at three, after which retested is terminal. A line oscillating around price cannot churn forever.

The status card reports both facts rather than picking one. RISING · RES is a rising line currently acting as resistance. Unflipped lines read RISING · SUP and FALLING · RES, which is what they always meant, said out loud.

THE CHANNEL
Once a line is validated, its parallel rail is projected through the furthest the market travelled away from it while the line was forming. The rail comes from a real extreme rather than from a statistical fit, so the width means something specific: this is how far this structure has been willing to travel from its own floor. Fill and opacity are yours to set, and the fill carries the state, so there is no color legend to memorize.

CONVERGENCE, WITH A TIME
Two validated lines with different slopes meet at an apex, and an apex is a price AND a bar. That is a triangle or a wedge resolving, one of the oldest readable objects in chart reading. It needs both lines retained as DATA rather than as drawings, which is why most auto-trendline scripts cannot offer it at all.

It is reported on the card and alerted, not drawn. A marker painted into future bars would say the same thing and add a drawing to a chart whose whole design rule is fewer marks. And it is a fact, not a forecast: it says where and when the structure runs out of room, not what happens when it gets there.

HIGHER TIMEFRAME LINES
A second engine, off by default, sharing the concepts of the chart-timeframe engine and none of its code paths. If the higher-timeframe layer is wrong, the layer you already trust keeps working.

Why most higher-timeframe trendline overlays are unsound is worth stating. A security call hands back prices. It does not hand back the ability to walk backwards through higher-timeframe bars, and the cleanliness scan IS a walk. So an HTF line built off a plain security read cannot be validated the way a chart line is, and most implementations quietly skip the check. Here, completed higher-timeframe bars are pushed into a ring buffer as they close and the whole HTF engine walks those. A real scan, real HTF touches, and a break that is a real HTF close through the line.

Breaks are judged by the timeframe that OWNS the line. A 15m candle closing through a 4H trendline is not a 4H close, and treating it as one is the most common way an HTF overlay lies. The visible consequence is that an HTF line can die up to one HTF bar later than the chart makes it look like it should. That is correct, and it will look wrong the first time.

What the HTF layer deliberately does not do, each one a decision rather than an omission: no channel, no polarity flip, no apex participation, and no separate alerts. The rail is measured by the same pass that validates the chart line. Converging HTF and chart slopes needs a unit conversion that is wrong the moment the chart timeframe changes. And two engines firing the same alert would double every notification. One slot, defaulted off, because new surface gets proven before it gets duplicated.

THE STATUS CARD
Six live lines on a chart and no way to tell which one matters this bar. The card names the nearest line, the distance to it in points and in ATR, its geometry and its current role, how many broken lines are still awaiting a verdict, and the soonest apex. A table rather than a label, because a label draws inside the price pane and loses the z-order fight with candles.

ALERTS
Trendline validated · Trendline broken · Trendline retest confirmed · Failed trendline break · Trendline convergence approaching

The convergence alert is the one worth leaving on. The other four report something that has already finished, which is useful for a journal. Convergence is the one thing the tool knows about the future, so it is the one alert that can reach you while there is still something to do about it. It is edge-triggered: it arms while the apex is beyond your warning distance and fires once on the way in, rather than firing every bar of the approach until you mute it forever.

WHY IT DOES NOT REPAINT
Lines anchor on confirmed pivots only, and a pivot is not known until the required bars have closed after it. Every state change is judged on a closed bar. The chart-timeframe engine contains no security call at all, and the higher-timeframe engine reads only completed HTF bars, never the one in progress, using the last-closed idiom with an atomic tuple so high, low, close and time cannot straddle a boundary. The cost is a deliberate lag of a few bars on every anchor, and that lag is the guarantee.

WHAT THIS TOOL IS NOT
It draws structure. It shades no band, marks no zone, and makes no claim about resting orders anywhere. When a broken line is reclaimed, this tool calls it a FAILED BREAK, which is a statement about structure and is what the price action supports on its own. A liquidity tool looking at the same bar would call it a sweep, which is a statement about order flow. Same behavior, different claim, and only one of them is visible on the chart.

MADE TO FIT YOUR CHART
Eight card positions, three text sizes, separate colors for rising and falling lines and for their higher-timeframe counterparts, line width, channel fill and opacity, labels on or off, and a toggle per section. Detection, channel, break and retest, style, higher timeframe, card and alerts are separate groups. Pivot length, minimum touches, maximum active lines, the slope cap, the retirement distance, the retest confirmation mode and the retest window are all exposed.

HOW TRADERS ACTUALLY USE IT
Pivot Length decides everything downstream, because it decides which swings exist to be paired. If the chart looks emptier than you expect, that is the first knob, ahead of the touch count.

Minimum touches is the honesty dial. Two touches is a line you drew. Three is a line the market drew. Three is the default for that reason.

Treat a break as the question and the following bars as the answer. Wait for RETESTED or FAILED before deciding what the break meant. The whole tool is built so you do not have to guess which one you are sitting in.

Works on any market and any timeframe.

Display only. This draws structure and reports what happened to it, it does not fire buy/sell signals and it does not forecast. Educational tool, not financial advice.

Published open-source. The pivot pairing and cleanliness scan, the near-duplicate rejection, the two-mode break test, the polarity-flip lifecycle, the apex pre-filter and the higher-timeframe ring buffer are all readable in the source. Everything above explains what it draws and how it decides what to draw; the code is there so you can check that the description is accurate rather than take it on faith. Read it, fork it, argue with the constants.

---

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════
//  MarketMaulers Auto Trendlines  ·  v1.4
//  ─────────────────────────────────
//  Classic diagonal trend structure, drawn automatically: a line anchored on two
//  confirmed pivots, validated by how many times the market actually respected
//  it, its parallel channel, and then the two things that happen to every
//  trendline in the end.
//
//     Forming → Validated → Broken → Retested  /  Failed break
//
//  ─── THE RETEST IS THE PRODUCT ───
//  Anyone can draw a line through two pivots and print a marker when price
//  closes through it. The break is the least informative moment in a trendline's
//  life: most of them break, and the break alone tells you nothing about whether
//  the level still matters.
//
//  What matters is what happens NEXT, and there are exactly two outcomes:
//    · RETEST      price comes back to the line and respects it from the OTHER
//                  side. Old support is now resistance. The line survived its
//                  own break as a reference and is arguably more useful after
//                  it than before.
//    · FAILED BREAK  price closes straight back on the original side. The break
//                  was noise, the line was never actually beaten, and anyone
//                  who traded the break is offside.
//  This tool waits for one of those and says which. It is the only thing here
//  that is not available by eyeballing the chart.
//
//  ─── THE CHANNEL ───
//  Once a line is validated, its parallel rail is projected through the furthest
//  the market travelled away from it while the line was forming. That gives the
//  actual channel the structure has been trading inside, drawn from the market's
//  own extremes rather than fitted statistically.
//
//  ─── DISJOINTNESS, and this file has more neighbours than most ───
//  Four tools in this suite already draw something line-shaped. This one is only
//  worth existing if it stays out of all four lanes, so the boundaries are
//  written here to be checked rather than assumed:
//    · MM Auto S/R             → HORIZONTAL zones, with break and retest.
//                                Same lifecycle idea, but flat. This file NEVER
//                                draws a horizontal line: the pivot pairing rule
//                                requires a strictly lower second high (or higher
//                                second low), so a zero slope is unreachable.
//    · MM LRLR                 → the ICT liquidity staircase. Horizontal.
//    · MM Trendline Liquidity  → the DIAGONAL POOL. Same pivot machinery, and
//                                that is deliberate (see PROVENANCE below), but a
//                                completely different product: it shades the band
//                                of resting orders beyond the line and resolves a
//                                break into swept-versus-broken. THIS FILE DRAWS
//                                NO BAND AND MAKES NO LIQUIDITY CLAIM. It has no
//                                pool, no sweep verdict, and no order-flow
//                                language anywhere. Trendline as STRUCTURE, not
//                                as a place stops are resting.
//    · MM LinReg Channel       → a statistical FIT channel over a fixed lookback,
//                                graded by R². This channel is anchored on two
//                                real pivots and one real extreme, and is not
//                                fitted to anything.
//  Honest note, recorded rather than buried: this file's FAILED BREAK is the same
//  price behaviour MM Trendline Liquidity calls SWEPT. The behaviour is one
//  thing; the claim made about it is not. Trendline Liquidity says a pool of
//  stops was collected, which is a statement about order flow. This file says the
//  break did not hold, which is a statement about structure and is all the price
//  action can actually support on its own. Run both and they will agree on the
//  bar and disagree on the meaning, which is the correct outcome.
//
//  ─── PROVENANCE ───
//  The pivot pairing, the cleanliness scan, the near-duplicate rejection, the
//  anchor clamp and the abandoned-line retirement are ported from
//  `mm_trendline_liquidity.pine` v1.1. That is reuse on purpose, not laziness:
//  those five pieces each fix a real defect found on Ryan's own charts (support
//  lines from 2009 still drawn under price, one pool drawn twice off different
//  pivot pairs, weekly labels with no lines attached), and rewriting them from
//  scratch would mean rediscovering all five. Any fix to this machinery should
//  be back-ported to that file, and the other way round.
//
//  Display only. No buy/sell signals. It draws structure and reports what
//  happened to it.
//
//  ─── v1.4 (2026-08-30) ───
//  HIGHER-TIMEFRAME LINES. A self-contained second engine, and the separation is the
//  design decision, not an implementation detail: it shares the CONCEPTS with the
//  chart-TF engine and none of its code paths. If the HTF layer is wrong, the tool you
//  already trust keeps working. Entangling them would have meant editing a validated
//  state machine to serve an unproven one.
//
//  THE PROBLEM WITH HTF TRENDLINES, AND WHY MOST TOOLS GET IT WRONG.
//  A request.security read hands back prices. It does not hand back the ability to walk
//  backwards through higher-timeframe bars, and this engine's whole premise is a WALK:
//  the cleanliness scan checks every bar between two anchors for a close through the
//  line. So an HTF trendline drawn from a security call cannot actually be validated
//  the way a chart-TF one is, and most implementations quietly skip the check.
//  THE FIX IS A RING BUFFER. Completed HTF bars are pushed into arrays as they close,
//  and the whole HTF engine walks THOSE. The scan is a real scan, the touches are real
//  HTF touches, and a break is a real HTF close through the line.
//
//  BREAKS ARE JUDGED BY THE TIMEFRAME THAT OWNS THE LINE. A 15m candle closing through
//  a 4H trendline is not a 4H close, and treating it as one is the single most common
//  way an HTF overlay lies. Same ruling MM Rejection Block already made for HTF blocks.
//  The visible consequence: an HTF line can die up to one HTF bar later than the chart
//  makes it look like it should. That is correct, and it will look wrong the first time.
//
//  NON-REPAINT IDIOM: `[1]` plus `lookahead_on`, which returns the last CLOSED higher-
//  timeframe bar and never the one in progress. Chosen over the zero-lookahead
//  rising-edge because this needs four values from the SAME completed bar (high, low,
//  close, time) and a tuple request keeps them atomically consistent. A rising-edge
//  read assembled from separate calls can straddle a boundary.
//
//  ONE SLOT, DELIBERATELY. The suite's HTF pattern is multi-slot, and this will follow
//  it, but slot 2 is a copy of a proven slot 1, not a guess made twice. Default OFF for
//  the same reason: it is new surface that has never been on a chart.
//
//  WHAT THE HTF LAYER DOES NOT DO, and each omission is a decision:
//    · NO CHANNEL. The rail is measured by the same walk that validates the line, and
//      that pass is entangled with the chart-TF scan. Porting it means porting the
//      excursion measurement too, and it is worth proving the lines first.
//    · NO POLARITY FLIP. A 4H line surviving a break, a departure and a held retest and
//      then doing it again is rare enough that FLIP_CAP would almost never be reached.
//      Bounded scope beats an untested state machine on an untested feed.
//    · NO APEX PARTICIPATION. HTF slopes are price-per-HTF-bar and chart slopes are
//      price-per-chart-bar. Converging them would require a unit conversion that is
//      wrong the moment the chart timeframe changes.
//    · NO NEW ALERTS. The four existing alerts stay chart-TF only rather than silently
//      firing twice from two engines.
//
//  APEX BECAME AN ALERT, WHICH MEANT IT HAD TO GET CHEAP FIRST.
//  Every alert in this file until now fired AFTER the fact: broken, retested, failed,
//  validated. Good for a journal, useless for getting you to the chart. A convergence
//  is the one thing the tool knows about the FUTURE, so it is the one alert that can
//  arrive while there is still something to do about it.
//  THE REFACTOR IS THE REAL WORK. v1.2 computed the apex inline in the card, on
//  barstate.islast only, as a nested loop over the whole line pool. An alert has to be
//  evaluated on every confirmed bar, and 60 x 60 = 3600 iterations per bar across a
//  full history is not a cost worth paying for a row on a card.
//  f_apex now PRE-FILTERS to validated rows in one O(n) pass and pairs only those,
//  which is a handful of lines rather than the whole pool. The index buffer is a
//  module-level var that gets cleared rather than a fresh array per call, so the
//  function allocates nothing. Card and alert both read the same result, so they can
//  never disagree about where the apex is.
//  THE ALERT IS EDGE-TRIGGERED, not level-triggered. It arms when the apex is further
//  out than the warning distance and fires once on the way in. A level test would fire
//  every single bar for the whole approach, which is how an alert gets muted forever.
//
//  ─── v1.3 (2026-08-30) ───
//  THE CARD WAS LYING ABOUT FLIPPED LINES, and it was my own doing: v1.2 shipped the
//  polarity flip and the status card in the same version and did not connect them.
//  NEAREST read tDir, the line's GEOMETRIC IDENTITY, so a rising support line that had
//  survived a retest and flipped to acting as resistance still displayed "RISING SUP"
//  while the engine was testing it for a break to the UPSIDE. The one row whose whole
//  job is to tell you what you are looking at was describing the opposite thing.
//  The R1 suffix on the chart label hinted at it, but only if you already knew what R
//  meant, which is not a card doing its job.
//  FIXED BY SEPARATING THE TWO FACTS INSTEAD OF PICKING ONE. The row now reads
//  "RISING · RES": geometry from tDir, current ROLE from tPol. Unflipped lines read
//  "RISING · SUP" and "FALLING · RES", which is what they always meant, just said out
//  loud. This is the same identity-versus-behaviour split the flip itself is built on,
//  finally reaching the display layer.
//
//  ─── v1.2 (2026-08-30) ───
//  Three additions, all inside the disjointness rule: this file still draws no band,
//  makes no liquidity claim, and uses no order-flow language.
//
//  1. A RETESTED LINE GOES BACK TO WORK. v1.0 and v1.1 treated RETESTED as the end of
//     the line's life, which is exactly backwards from what the retest proves. A line
//     that broke, was left, and then held from the other side has just demonstrated it
//     still matters, and the tool stopped watching it at that precise moment.
//     THE MECHANISM IS A POLARITY FLIP, not a new line. Old support is now resistance,
//     so the SIDE the break test looks at flips while the line's identity does not.
//     tPol drives every behavioural test (touch, break, persistence, away, reclaim);
//     tDir keeps driving colour and the channel offset, because a rising line is still
//     geometrically a rising line and recolouring it would just confuse the chart.
//     BOUNDED, because unbounded was the original reason it was terminal. FLIP_CAP
//     allows three cycles, after which RETESTED is terminal exactly as before. A line
//     oscillating around price cannot churn forever.
//     The label carries R1 / R2 / R3 so a twice-proven line is visibly different from a
//     fresh one.
//
//  2. CONVERGENCE, WITH A TIME. Two validated lines with different slopes meet at an
//     apex: a price AND a bar. That is a triangle or a wedge resolving, and it is one
//     of the oldest readable objects in classic chart reading. Nothing else in the
//     suite produces it, and it needs both lines retained as DATA rather than as
//     drawings, which is why most auto-trendline scripts cannot offer it.
//     REPORTED ON THE CARD, NOT DRAWN. Ryan's standing rule is that clutter gets cut by
//     showing FEWER marks. An apex is one line of arithmetic off two slopes; painting a
//     marker into future bars to say the same thing would add a drawing, a future-bar
//     offset limit, and nothing else.
//     IT IS A FACT, NOT A FORECAST. It says where and when the structure runs out of
//     room. It does not say what happens when it gets there.
//
//  3. THE STATUS CARD. Six live lines on a chart and no way to tell which one matters
//     this bar. The card names the nearest one, how far away it is in points and ATR,
//     what state it is in, how many broken lines are still awaiting a verdict, and the
//     soonest apex. Same table style as MM OTE and MM PSP.
//     A TABLE RATHER THAN A LABEL, deliberately: a label draws inside the price pane
//     and loses the z-order fight with candles.
//
//  ─── v1.1 (2026-08-30) ───
//  One fix, and it is a hole rather than a preference. The dead band between
//  TOUCH_ATR and BRK_ATR is right for a single bar and wrong for a grind: price
//  parked just through a line, too shallow to break it and too close to retire
//  it, left the line marked VALIDATED with price on the wrong side of it for as
//  long as the grind lasted. BRK_BARS now breaks a line on three consecutive
//  wrong-side closes at any distance. Back-port candidate for MM Trendline
//  Liquidity, which shares this machinery and therefore shares the hole.
//
//  Non-repaint: lines anchor on CONFIRMED pivots only (a pivot is not known until
//  pivLen bars after it prints), every state change is judged on a closed bar,
//  and there is no request.security anywhere in this file.
//
//  Built by Market Maulers  ·  Free forever
//  discord.gg/marketmaulers
// ═══════════════════════════════════════════════════════════════════════
// max_bars_back is load-bearing, not decoration: the validation scan reads
// high[]/low[]/close[] at a COMPUTED offset back to the first anchor, and Pine's
// auto-detection does not size the buffer for dynamic offsets. Without this the
// scan throws on the first widely-spaced pivot pair. Paired with SCAN_CAP below:
// raise one and you must raise the other.
indicator("MarketMaulers Auto Trendlines", shorttitle="MM Trendlines", overlay=true,
     max_lines_count=500, max_labels_count=500, max_bars_back=1000)


// ═══════════════════════════════════════════════════════════════════════
//  LOCKED CALIBRATION (v1.2) - constants, deliberately NOT inputs
// ═══════════════════════════════════════════════════════════════════════
//  Trendline drawing is a decades-old technique with no published thresholds,
//  because it has always been done by hand and by eye. Every number here is a
//  Maulers calibration choice made so a machine can do it consistently. None is
//  duplicated as an inline literal downstream, so editing this block actually
//  changes behaviour (MM Volume Imbalance v1.7 found its whole block decorative
//  for exactly that reason).
float TOUCH_ATR   = 0.25  // how close a bar must come to the line to count as a
                          //   touch, in ATR. ATR-scaled rather than a tick count
                          //   so the engine adapts to any symbol and timeframe.
int   TOUCH_GAP   = 3     // bars between counted touches. Without this, one slow
                          //   approach riding the line for six bars scores six
                          //   touches and every line validates instantly.
float BRK_ATR     = 0.35  // how far beyond the line a close must sit to be a
                          //   break rather than a nick.
                          //   🔴 ADVERSARIAL-REVIEW FIX: this was 0.15, which is
                          //   NARROWER than TOUCH_ATR, so a bar closing between
                          //   0.15 and 0.25 ATR through the line scored as a touch
                          //   AND a break on the same bar. The comment claimed a
                          //   separation that the numbers did not provide.
                          //   It must sit ABOVE TOUCH_ATR. The gap between the two
                          //   (0.25 to 0.35) is a deliberate dead band: a close in
                          //   there is neither, which is the honest answer for a
                          //   bar sitting exactly on the line.
int   BRK_BARS    = 3     // v1.1: consecutive closes on the WRONG side of the line
                          //   that count as a break regardless of distance.
                          //   🔴 THIS CLOSES THE DEAD BAND. The gap between
                          //   TOUCH_ATR and BRK_ATR is deliberate and correct for
                          //   a single bar, but nothing was watching what happens
                          //   when price PARKS in it: a rising support line with
                          //   price closing 0.30 ATR underneath it, bar after bar,
                          //   scored no touch (close is through the line), no
                          //   break (not far enough), and could not be retired
                          //   either (staleATR wants 3 ATR of distance, and price
                          //   is sitting right on the thing). The line stayed
                          //   VALIDATED with price on the wrong side of it for as
                          //   long as the grind lasted. Three closes beyond the
                          //   line is a break however small the distance, which is
                          //   also how a human reads it. Ours, not sourced.
int   SCAN_CAP    = 500   // hard cap on the between-anchors scan
int   TR_BROKE    = 45    // transparency ladder. The fill IS the state signal:
int   TR_RESOLVED = 70    //   one base colour per direction, and there is no
int   TR_CHAN     = 72    //   colour legend to memorise.
int   STALE_BARS  = 20    // consecutive bars price must stay abandoned-far from a
                          //   line before it is retired
float DEDUP_ATR   = 0.75  // two lines closer than this at BOTH sample points are
                          //   the same line drawn off a different pivot pair
int   DEDUP_LOOK  = 50    // the second sample point, bars back. Comparing now AND
                          //   then separates "duplicate" from "converging".
int   ANCHOR_CAP  = 9500  // TradingView silently refuses bar_index coordinates
                          //   beyond about 10,000 bars back and the drawing never
                          //   appears (found on a weekly chart: labels drawn,
                          //   lines missing)
int   FLIP_CAP    = 3     // v1.2: retest-and-flip cycles a line may go through before
                          //   RETESTED becomes terminal again. Bounding it is the whole
                          //   reason the state was terminal before: a line oscillating
                          //   around price would otherwise re-enter the watch forever.
                          //   Three is ours. Each cycle needs a full break, a departure
                          //   and a held retest, so it is already slow to reach.
int   APEX_MAX    = 200   // v1.2: furthest ahead, in bars, that a convergence is worth
                          //   naming. Past this the two lines will have been broken or
                          //   retired long before they ever meet, so the apex is
                          //   arithmetic rather than information.
int   HTF_CAP     = 400   // v1.4: completed HTF bars retained in the ring buffer. The
                          //   scan can only verify a line whose anchors are both still
                          //   in here, so this is also the real reach of an HTF line.
                          //   400 4H bars is roughly nine months.
int   HTF_LINES   = 8     // v1.4: max HTF lines held. Separate budget from maxLines so
                          //   turning the layer on cannot evict chart-TF structure.
int   HTF_RT      = 10    // v1.4: retest window in HTF BARS. Deliberately not rtBars:
                          //   that number is in chart bars and means something entirely
                          //   different at 4H. Ours, and uncalibrated like its sibling.
int   HARD_CAP    = 60    // total rows before the oldest is evicted regardless of
                          //   state
color COL_NONE    = #ffffff00


// ═══════════════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════════════
string GRP_D = "Detection"
string GRP_C = "Channel"
string GRP_B = "Break & Retest"
string GRP_S = "Style"
string GRP_H = "Higher Timeframe"
string GRP_K = "Card"
string GRP_A = "Alerts"

// ── Detection ──
int  pivLen   = input.int(8, "Pivot length", minval=2, maxval=50, group=GRP_D,
     tooltip="How many bars either side a high or low must dominate to count as a pivot, and therefore how significant a swing has to be before a line can anchor on it.\n\nHigher = fewer, larger, more widely-watched lines. Lower = a busy chart of lines nobody else is drawing.\n\n8 is a reasonable intraday default. Drop it to 4-5 on higher timeframes where swings are scarcer.")
int  minTouch = input.int(3, "Minimum touches to validate", minval=2, maxval=10, group=GRP_D,
     tooltip="Touches required before a line is treated as real. The two anchor pivots count, so 3 means the anchors plus one honest retest of the line.\n\n2 draws every pivot pair and is only useful for seeing what the engine found. 3 is the classic standard. 4-5 leaves you with the two or three lines on the chart that actually matter.")
bool showUp   = input.bool(true, "Rising support lines", group=GRP_D, inline="d1")
bool showDn   = input.bool(true, "Falling resistance lines", group=GRP_D, inline="d1",
     tooltip="Rising support anchors on two ascending pivot lows. Falling resistance anchors on two descending pivot highs. Turn one off to read a single side of the structure.")
int  maxLines = input.int(6, "Max active lines", minval=1, maxval=20, group=GRP_D,
     tooltip="Live lines kept on the chart at once, oldest culled first. Resolved lines (retested, failed, expired) are faded rather than deleted and do not count against this.")
bool strictOK = input.bool(true, "Require a clean line", group=GRP_D,
     tooltip="ON (default) - a line is only drawn if no bar between its two anchors CLOSED through it. That is what makes it a trendline rather than two points joined by geometry: a line price already closed through was never respected.\n\nThis scan is also what measures the channel width, so turning it OFF disables the channel too.\n\nOFF - anchors any two qualifying pivots regardless of what happened in between. Many more lines, most of them meaningless.")
float maxSlope = input.float(0.5, "Max slope (ATR per bar)", minval=0.05, maxval=5.0, step=0.05, group=GRP_D,
     tooltip="Rejects near-vertical lines. Two pivots close together in time and far apart in price produce a technically valid line that no human would ever draw and that price leaves behind within a few bars.\n\n0.5 ATR per bar is a Maulers starting point. Lower it if you still see steep lines that vanish immediately; raise it on fast intraday charts where real structure genuinely is steep.")
float staleATR = input.float(3.0, "Retire abandoned lines (ATR)", minval=0, maxval=20, step=0.5, group=GRP_D,
     tooltip="Retires a line once price has sat further than this from it, in ATR, for 20 straight bars. Set to 0 to never retire.\n\n⚠ THIS EXISTS BECAUSE OF A REAL HOLE, found on Ryan's own charts in the sibling tool. A rising support line only dies when price closes BELOW it. When price runs AWAY upward instead, nothing ever kills it: the line stays live forever and extends into empty space. A monthly NQ chart ended up with support lines from 2009 still drawn 15,000 points under price.\n\n3 ATR is a Maulers starting point, not a sourced number.")

// ── Channel ──
bool showChan = input.bool(true, "Show the parallel channel", group=GRP_C,
     tooltip="Projects a rail parallel to the trendline, through the furthest price travelled away from it while the line was forming.\n\nThis is the channel the structure has actually been trading in, taken from the market's own extreme rather than fitted. It is drawn from the same two anchors, so it cannot disagree with the line.\n\nRequires 'Require a clean line' to be ON, because the same scan measures both.")
bool chanFill = input.bool(false, "Fill the channel", group=GRP_C,
     tooltip="OFF by default, and deliberately. A filled diagonal band reads as a liquidity pool, which is MM Trendline Liquidity's job and a claim this tool does not make. Leave it off unless you are running this alone.")
int  chanOpac = input.int(90, "Fill opacity", minval=50, maxval=100, group=GRP_C,
     active=chanFill,
     tooltip="Transparency of the channel fill. 100 is invisible. Keep it high; this is context and should sit behind the candles.")

// ── Break & Retest ──
string rtMode = input.string("Close", "Retest confirmation", options=["Close", "Touch"], group=GRP_B,
     tooltip="What counts as a retest after a line breaks.\n\nClose (default, stricter) - price has to come back to the line AND close on the new side. That is an actual rejection: old support held as resistance.\n\nTouch - any bar that reaches back to the line counts, regardless of where it closes. More retests, and some of them are just price passing through on its way back.")
int  rtBars = input.int(20, "Retest window (bars)", minval=2, maxval=200, group=GRP_B,
     tooltip="How long after a break the tool keeps watching for the retest. Nothing happens within this window and the break is marked unresolved and left alone.\n\n⚠ OURS, not sourced. 20 bars is a Maulers starting point. It is also the setting that most changes what the tool appears to say: too short and genuine retests get marked expired, too long and an unrelated return weeks later gets called a retest.")
bool showMark = input.bool(true, "Mark retests", group=GRP_B,
     tooltip="Prints a marker on the bar a broken line was retested and respected from the other side.")

// ── Style ──
color upCol   = input.color(#26c6da, "Rising support", group=GRP_S, inline="s1")
color dnCol   = input.color(#ec407a, "Falling resistance", group=GRP_S, inline="s1",
     tooltip="One base colour per direction. Every state is a transparency or a line style of these two.\n\nDeliberately NOT the teal and coral used by MM Trendline Liquidity, so the two can run on the same chart without you having to work out which line belongs to which tool.")
int  lnWidth  = input.int(2, "Line width", options=[1,2,3,4], group=GRP_S)
bool showLbl  = input.bool(true, "Show labels", group=GRP_S,
     tooltip="Prints the touch count and the state at the right end of each line.")

// ── Higher Timeframe ──
bool   htfOn  = input.bool(false, "Draw higher-timeframe lines", group=GRP_H,
     tooltip="Draws trendlines built from a higher timeframe's own pivots on top of your chart.\n\nOFF by default because it is the newest surface in this tool and it has the most ways to be subtly wrong.\n\nThis is a SEPARATE engine that shares the concepts and none of the code. It walks a buffer of completed higher-timeframe bars, so the cleanliness scan, the touches and the breaks are all genuine HTF events rather than chart-timeframe events wearing an HTF label.\n\nIt does not draw a channel and it does not flip polarity after a retest. Both are deliberate: prove the lines first.")
string htfTf  = input.timeframe("240", "Timeframe", group=GRP_H, active=htfOn,
     tooltip="Which timeframe the lines are built from. Pick something meaningfully higher than your chart: 4H lines on a 5m chart is the intended shape. Setting this at or below your chart timeframe will just redraw what the main engine already found, more slowly.")
int    htfPiv = input.int(5, "HTF pivot length", minval=2, maxval=20, group=GRP_H, active=htfOn,
     tooltip="Bars either side that define a swing on the HIGHER timeframe. Lower than the chart-TF default on purpose: higher-timeframe swings are already significant, so demanding eight bars either side of a 4H pivot finds almost nothing.")
int    htfTch = input.int(3, "HTF minimum touches", minval=2, maxval=10, group=GRP_H, active=htfOn,
     tooltip="Touches before an HTF line is treated as real, counted in HTF bars. The two anchors count, so 3 means the anchors plus one honest retest.")
color  htfUp  = input.color(#4dd0e1, "HTF rising", inline="h1", group=GRP_H)
color  htfDn  = input.color(#f06292, "HTF falling", inline="h1", group=GRP_H,
     tooltip="Deliberately close to the chart-TF pair but not identical, so you can tell at a glance which engine drew a line without checking the label. Every HTF state is a transparency of these two, same as the chart-TF lines.")
int    htfW   = input.int(2, "HTF line width", options=[1,2,3,4], group=GRP_H, active=htfOn)

// ── Card ──
bool showCard = input.bool(true, "Show the status card", group=GRP_K,
     tooltip="A corner card naming the line that matters right now.\n\nWith six lines on the chart there is otherwise no way to tell which one price is actually working, and you end up eyeballing it. The card reports the NEAREST live line, its distance in both points and ATR, its state and touch count, how many broken lines are still waiting on a verdict, and the soonest convergence.\n\nA table rather than a label on purpose: a label is drawn inside the price pane and candles can sit on top of it.")
string cardPos = input.string("Top Right", "Card position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=GRP_K, active=showCard,
     tooltip="Which corner the card sits in. Move it off whichever corner your other indicators have already claimed.")
string cardSize = input.string("Small", "Card text size", options=["Tiny","Small","Normal"], group=GRP_K, active=showCard,
     tooltip="Tiny keeps it out of the way on a busy chart. Normal is the one to use for a screen recording, where Small tends to be unreadable once the video is compressed.")
int  apexWarn = input.int(10, "Alert when apex is within (bars)", minval=1, maxval=100, group=GRP_K,
     tooltip="How close the convergence has to get before the apex alert fires. Only read when the apex alert is switched on in the Alerts group.\n\nEdge-triggered: it fires ONCE on the way in and re-arms only after the apex moves back outside this distance. A level test would fire on every bar of the approach, which is how an alert ends up muted.\n\nThe apex can also move further away again, because it is recomputed from live slopes as the lines extend. That is not a fault, it is two structures that stopped converging.")
bool showApex = input.bool(true, "Report convergence (apex)", group=GRP_K, active=showCard,
     tooltip="Two validated lines with different slopes meet at an apex: a price AND a bar. That is a triangle or a wedge resolving, and the card reports the soonest one as bars-ahead and price.\n\nDeliberately NOT drawn on the chart. Clutter gets cut by showing fewer marks, and a marker painted into future bars would say nothing the row does not.\n\nIt is a fact, not a forecast: it tells you where and when the structure runs out of room, not what happens when it gets there. Convergences further out than 200 bars are ignored, because both lines will almost certainly have resolved long before then.")

// ── Alerts ──
bool alNew  = input.bool(false, "Alert on new validated line", group=GRP_A)
bool alBrk  = input.bool(false, "Alert on trendline break", group=GRP_A)
bool alRt   = input.bool(false, "Alert on retest confirmed", group=GRP_A)
bool alFail = input.bool(false, "Alert on failed break", group=GRP_A)
bool alApex = input.bool(false, "Alert on approaching convergence", group=GRP_A,
     tooltip="Fires once when two validated lines are converging and the apex comes within the bar distance set in the Card group.\n\nThis is the only alert here that is not about something that already happened. It tells you a triangle or a wedge is running out of room, which is information you can still act on.\n\nIt says nothing about which way it resolves.")


// ═══════════════════════════════════════════════════════════════════════
//  GLOBALS
// ═══════════════════════════════════════════════════════════════════════
float atr   = nz(ta.atr(200), syminfo.mintick * 40)
float tolPx = atr * TOUCH_ATR
float brkPx = atr * BRK_ATR


// ═══════════════════════════════════════════════════════════════════════
//  DATA - parallel columns, one row per trendline.
//  House archetype: a flat pool of homogeneous objects → parallel arrays, not
//  UDTs. Every delete MUST remove index i from EVERY column or the rows desync,
//  which is the single classic failure mode of this model.
// ═══════════════════════════════════════════════════════════════════════
var array<int>      tDir   = array.new<int>()      //  1 = rising support, -1 = falling resistance
var array<int>      tX1    = array.new<int>()      // anchor bar (first pivot)
var array<float>    tY1    = array.new<float>()    // anchor price
var array<float>    tSlope = array.new<float>()    // price per bar
var array<float>    tDev   = array.new<float>()    // channel offset (na = no channel)
var array<int>      tTouch = array.new<int>()
var array<int>      tLast  = array.new<int>()      // bar of the last counted touch
var array<int>      tState = array.new<int>()      // 0 forming · 1 validated · 2 broken
                                                   //   3 retested · 4 failed · 5 expired.
                                                   //   The comment said three for two
                                                   //   versions; there were always six.
                                                   // 3 retested · 4 failed break · 5 break expired
var array<int>      tBrk   = array.new<int>()      // bar the break happened
var array<bool>     tAway  = array.new<bool>()     // price has genuinely left the line
                                                   //   since the break (see the retest gate)
var array<int>      tBorn  = array.new<int>()
var array<int>      tFar   = array.new<int>()      // consecutive abandoned-far bars
var array<int>      tWrong = array.new<int>()      // v1.1: consecutive wrong-side closes
var array<int>      tPol   = array.new<int>()      // v1.2: SIDE the behavioural tests use.
                                                   //   Starts as tDir and flips on every
                                                   //   retest. tDir never changes: it is
                                                   //   the line's geometric identity and
                                                   //   still drives colour and the rail.
var array<int>      tFlip  = array.new<int>()      // v1.2: completed retest-flip cycles
// v1.4: scratch buffer for f_apex. Module-level and cleared per call rather than a
// fresh array each time, because f_apex now runs on every confirmed bar.
var array<int>      apxIdx = array.new<int>()
var array<line>     tLn    = array.new<line>()
var array<line>     tCh    = array.new<line>()     // the parallel rail
var array<linefill> tFl    = array.new<linefill>()
var array<label>    tLb    = array.new<label>()


// ═══════════════════════════════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════════════════════════════
// Price of a line at any bar. The ONLY way any coordinate is produced in this
// file: no drawing is ever read back to position another drawing (house rule).
f_valAt(float y1, float slope, int x1, int at) =>
    y1 + slope * (at - x1)

f_base(int dir) =>
    dir == 1 ? upCol : dnCol

// v1.2 card helpers. f_tblPos and f_tblSize are lifted verbatim from mm_psp.pine and
// mm_ote.pine so the three cards in the suite can never drift apart on placement.
f_tblPos(string x) =>
    switch x
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

f_tblSize(string x) => x == "Tiny" ? size.tiny : x == "Normal" ? size.normal : size.small

f_stName(int st) => st == 0 ? "FORMING" : st == 1 ? "VALIDATED" : st == 2 ? "BROKE" : st == 3 ? "RETESTED" : st == 4 ? "FAILED" : "EXPIRED"

// ═══════════════════════════════════════════════════════════════════════
//  CONVERGENCE (v1.2, made cheap in v1.4)
//  Two validated lines with different slopes meet at an apex: a price AND a bar.
//  Only VALIDATED lines are eligible - an apex between two lines that have not proven
//  themselves is arithmetic about noise.
//  PRE-FILTERED, because this runs on every confirmed bar now that it drives an alert.
//  One O(n) pass collects the validated rows, then the pair loop runs over those few
//  instead of over the whole pool. Pairing the raw pool would be 3600 iterations a bar.
//  Returns bars-ahead and price, or [-1, na] when nothing converges in range.
// ═══════════════════════════════════════════════════════════════════════
f_apex() =>
    int   ab = -1
    float ap = na
    array.clear(apxIdx)
    if array.size(tDir) > 1
        for i = 0 to array.size(tDir) - 1
            if array.get(tState, i) == 1
                array.push(apxIdx, i)
        int m = array.size(apxIdx)
        if m > 1
            for a = 0 to m - 2
                int   i  = array.get(apxIdx, a)
                float si = array.get(tSlope, i)
                float yi = array.get(tY1, i)
                int   xi = array.get(tX1, i)
                for b = a + 1 to m - 1
                    int   j  = array.get(apxIdx, b)
                    float sj = array.get(tSlope, j)
                    float den = si - sj
                    // Parallel lines never meet. Exact float equality is not a safe
                    // guard, so anything flatter than a hundredth of a tick per bar of
                    // slope difference is treated as parallel.
                    if math.abs(den) > syminfo.mintick / 100
                        float xs = (array.get(tY1, j) - sj * array.get(tX1, j) - yi + si * xi) / den
                        int   ah = int(xs) - bar_index
                        if ah > 0 and ah <= APEX_MAX and (ab < 0 or ah < ab)
                            ab := ah
                            ap := yi + si * (xs - xi)
    [ab, ap]

[apexBars, apexPx] = f_apex()

// Edge-triggered arming. A level test would fire on every bar of the approach.
var bool apxArmed = true
bool apxHit = false
if apexBars > 0 and apexBars <= apexWarn
    if apxArmed
        apxHit   := true
        apxArmed := false
else
    apxArmed := true

// State → colour. Broken lines stay bright because a broken trendline is still
// the thing you are watching; only RESOLVED lines fade.
f_col(int dir, int st) =>
    color b = f_base(dir)
    st <= 1 ? b : st == 2 ? color.new(b, TR_BROKE) : color.new(b, TR_RESOLVED)

f_del(int i) =>
    // linefill must go before its lines: deleting a line first orphans the fill.
    // 🔴 ADVERSARIAL-REVIEW FIX: na guards are required here, unlike in the
    // sibling tool this was ported from. There every row always had a band line
    // and a fill, so the handles were never na. Here BOTH are optional (no
    // channel when the scan could not measure one, no fill unless the user asks
    // for it), so a bare delete would be handed an na id.
    linefill fl = array.get(tFl, i)
    if not na(fl)
        linefill.delete(fl)
    line ch = array.get(tCh, i)
    if not na(ch)
        line.delete(ch)
    line.delete(array.get(tLn, i))
    label.delete(array.get(tLb, i))
    array.remove(tDir,   i)
    array.remove(tX1,    i)
    array.remove(tY1,    i)
    array.remove(tSlope, i)
    array.remove(tDev,   i)
    array.remove(tTouch, i)
    array.remove(tLast,  i)
    array.remove(tState, i)
    array.remove(tBrk,   i)
    array.remove(tAway,  i)
    array.remove(tBorn,  i)
    array.remove(tFar,   i)
    array.remove(tWrong, i)
    array.remove(tPol,   i)
    array.remove(tFlip,  i)
    array.remove(tLn,    i)
    array.remove(tCh,    i)
    array.remove(tFl,    i)
    array.remove(tLb,    i)
    0


// ═══════════════════════════════════════════════════════════════════════
//  PIVOTS - confirmed only. ta.pivothigh(n, n) does not return a value until n
//  bars AFTER the pivot bar, which is exactly why this tool cannot repaint: a
//  line can never anchor on a swing that has not finished being a swing.
// ═══════════════════════════════════════════════════════════════════════
float ph   = ta.pivothigh(pivLen, pivLen)
float pl   = ta.pivotlow(pivLen, pivLen)
int   pBar = bar_index - pivLen

var int   lastPHx = na
var float lastPHy = na
var int   lastPLx = na
var float lastPLy = na


// ═══════════════════════════════════════════════════════════════════════
//  VALIDATION SCAN - cleanliness AND channel width, in one pass.
//
//  A line the market closed straight through on its way to the second anchor was
//  never respected. Wicks are allowed through deliberately: a wick beyond a
//  trendline is an overshoot, and overshoots are normal structure.
//
//  The same walk measures the furthest the market travelled AWAY from the line,
//  which is the channel rail. Doing both in one loop is not just cheaper: it
//  guarantees the channel is measured over exactly the span the line was
//  validated on, so the two can never describe different stretches of chart.
//
//  Ported from mm_trendline_liquidity.pine v1.1, including its adversarial fix:
//  the first draft there skipped spans it could not reach and returned TRUE, so
//  an unscannable anchor pair was silently accepted as clean - the tool asserting
//  a property it had never checked. An unverifiable pair is rejected instead.
// ═══════════════════════════════════════════════════════════════════════
f_scan(int dir, int x1, float y1, float slope, int x2) =>
    bool  ok  = true
    float dev = na
    int   span = x2 - x1
    if strictOK
        if bar_index - x1 > SCAN_CAP or span <= 1
            ok := span > 1 ? false : true
        else
            for k = 1 to span - 1
                int   b   = x1 + k
                int   off = bar_index - b            // history offset for that bar
                float v   = f_valAt(y1, slope, x1, b)
                // dir 1 = support, broken by a close BELOW; -1 = resistance, above.
                if dir == 1 and close[off] < v - tolPx
                    ok := false
                    break
                if dir == -1 and close[off] > v + tolPx
                    ok := false
                    break
                // Channel rail: the furthest excursion to the FAR side of the
                // line. Above a support line, below a resistance line.
                float d = dir == 1 ? high[off] - v : v - low[off]
                if d > nz(dev, 0)
                    dev := d
    [ok, dev]


// ═══════════════════════════════════════════════════════════════════════
//  NEAR-DUPLICATE REJECTION
//  Two lines a few points apart with the same slope are not two structures, they
//  are one structure found off two different pivot pairs. The test that separates
//  a duplicate from a genuinely converging line is to compare them at TWO points
//  in time: lines that agree NOW and also agreed 50 bars ago are the same line.
//  Lines that only agree now are converging, which is real and worth seeing.
//  Ported from mm_trendline_liquidity.pine v1.1.
// ═══════════════════════════════════════════════════════════════════════
f_dupe(int dir, int x1, float y1, float slope) =>
    bool dup = false
    int  n   = array.size(tDir)
    if n > 0
        for i = 0 to n - 1
            if array.get(tState, i) <= 2 and array.get(tDir, i) == dir
                float oy = array.get(tY1, i)
                float os = array.get(tSlope, i)
                int   ox = array.get(tX1, i)
                float dNow  = math.abs(f_valAt(y1, slope, x1, bar_index) -
                     f_valAt(oy, os, ox, bar_index))
                float dThen = math.abs(f_valAt(y1, slope, x1, bar_index - DEDUP_LOOK) -
                     f_valAt(oy, os, ox, bar_index - DEDUP_LOOK))
                if dNow < atr * DEDUP_ATR and dThen < atr * DEDUP_ATR
                    dup := true
                    break
    dup


// ═══════════════════════════════════════════════════════════════════════
//  LINE CREATION
// ═══════════════════════════════════════════════════════════════════════
f_add(int dir, int x1, float y1, int x2, float y2) =>
    // int in the denominator, float in the numerator, so this is float division.
    // Guarded anyway: two pivots on the same bar is impossible, but a zero divide
    // is not the kind of thing to leave to impossibility.
    float slope = x2 == x1 ? 0.0 : (y2 - y1) / (x2 - x1)
    // Slope sanity before the expensive scan. A near-vertical line is valid
    // geometry and worthless structure.
    bool steepOK = math.abs(slope) <= atr * maxSlope
    if x2 != x1 and steepOK
        [clean, dev] = f_scan(dir, x1, y1, slope, x2)
        if clean and not f_dupe(dir, x1, y1, slope)
            float yNow = f_valAt(y1, slope, x1, bar_index)
            // ANCHOR CLAMP (house rule). TradingView silently refuses bar_index
            // coordinates beyond roughly 10,000 bars back: the line simply never
            // renders, and the symptom is labels with no line attached. Clamping
            // the LEFT anchor forward and recomputing its price off the same
            // slope keeps the line geometrically identical while bringing the
            // coordinate back into range.
            int   x1c = math.max(x1, bar_index - ANCHOR_CAP)
            float y1c = f_valAt(y1, slope, x1, x1c)
            color c   = f_base(dir)
            line ln = line.new(x1c, y1c, bar_index, yNow, xloc=xloc.bar_index,
                 color=c, width=lnWidth)
            // The rail exists only when the scan actually measured one. With
            // "Require a clean line" off there is no scan, so there is no
            // channel, and the tool says so by not drawing one.
            bool hasCh = showChan and not na(dev) and dev > 0
            line ch = hasCh ? line.new(x1c, y1c + dir * dev, bar_index, yNow + dir * dev,
                 xloc=xloc.bar_index, color=color.new(c, TR_CHAN), width=1,
                 style=line.style_dashed) : na
            linefill fl = hasCh and chanFill ? linefill.new(ln, ch, color.new(c, chanOpac)) : na
            label lb = label.new(bar_index, yNow, "", xloc=xloc.bar_index,
                 style=label.style_label_left, color=COL_NONE, textcolor=c, size=size.tiny)
            array.push(tDir,   dir)
            array.push(tX1,    x1)
            array.push(tY1,    y1)
            array.push(tSlope, slope)
            array.push(tDev,   hasCh ? dev : na)
            array.push(tTouch, 2)                   // the two anchors are touches
            array.push(tLast,  x2)
            array.push(tState, 2 >= minTouch ? 1 : 0)
            array.push(tBrk,   0)
            array.push(tAway,  false)
            array.push(tBorn,  bar_index)
            array.push(tFar,   0)
            array.push(tWrong, 0)
            array.push(tPol,   dir)
            array.push(tFlip,  0)
            array.push(tLn,    ln)
            array.push(tCh,    ch)
            array.push(tFl,    fl)
            array.push(tLb,    lb)
    0

// A falling resistance line needs a LOWER second high; rising support needs a
// HIGHER second low. Pairing the other way round produces a line price has
// already left behind. This rule is also what guarantees a non-zero slope, which
// is what keeps this file out of MM Auto S/R's horizontal lane.
if not na(ph)
    if showDn and not na(lastPHy) and ph < lastPHy
        f_add(-1, lastPHx, lastPHy, pBar, ph)
    lastPHx := pBar
    lastPHy := ph

if not na(pl)
    if showUp and not na(lastPLy) and pl > lastPLy
        f_add(1, lastPLx, lastPLy, pBar, pl)
    lastPLx := pBar
    lastPLy := pl


// ═══════════════════════════════════════════════════════════════════════
//  LIFECYCLE - Forming → Validated → Broken → Retested / Failed break
// ═══════════════════════════════════════════════════════════════════════
bool didNew  = false
bool didBrk  = false
bool didRt   = false
bool didFail = false

if barstate.isconfirmed and array.size(tDir) > 0
    for i = array.size(tDir) - 1 to 0          // newest → oldest so in-loop delete is safe
        int   d  = array.get(tDir, i)
        // v1.2: d is IDENTITY (colour, channel offset). p is BEHAVIOUR (which side a
        // break is on). They are equal until the line survives a retest and flips.
        int   p  = array.get(tPol, i)
        int   x1 = array.get(tX1, i)
        float y1 = array.get(tY1, i)
        float sl = array.get(tSlope, i)
        int   st = array.get(tState, i)
        float v  = f_valAt(y1, sl, x1, bar_index)

        // Birth-bar guard. A line cannot be touched, broken or resolved by the
        // bar that created it. Same defect class caught in MM Suspension Block,
        // MM Volume Imbalance v1.6, MM Trendline Liquidity and MM ICT 2022, where
        // zones were stamped into their next state the instant they appeared.
        // It also gives the born-already-validated case (minTouch = 2) somewhere
        // to raise its alert, since f_add cannot write a global from inside a
        // function.
        bool bornNow = bar_index == array.get(tBorn, i)
        if bornNow and st == 1
            didNew := true

        // ── abandoned-line retirement ──
        // A rising support line only dies when price closes BELOW it. When price
        // runs AWAY upward instead, nothing ever kills it and it extends into
        // empty space forever. Retired by DELETION, not fading: an abandoned line
        // was never resolved and is simply noise, unlike a retested or failed one
        // which is a finished story worth leaving on the chart.
        if st <= 2 and staleATR > 0 and not bornNow
            if math.abs(close - v) > atr * staleATR
                array.set(tFar, i, array.get(tFar, i) + 1)
            else
                array.set(tFar, i, 0)
        if st <= 2 and staleATR > 0 and array.get(tFar, i) >= STALE_BARS
            f_del(i)
            continue        // MANDATORY: the row is gone, so every array.get
                            // below this point would read a DIFFERENT line.

        if not bornNow
            if st <= 1
                // ── touch counting ──
                // The bar has to REACH the line without the body closing through
                // it. A close through is not a touch, it is a break.
                bool near = p == 1 ? (low <= v + tolPx and close >= v - tolPx)
                     : (high >= v - tolPx and close <= v + tolPx)
                if near and bar_index - array.get(tLast, i) >= TOUCH_GAP
                    array.set(tTouch, i, array.get(tTouch, i) + 1)
                    array.set(tLast,  i, bar_index)
                    if array.get(tTouch, i) >= minTouch and st == 0
                        array.set(tState, i, 1)
                        st := 1
                        didNew := true

                // ── the break ──
                // Judged on a CLOSE beyond the line by more than brkPx, which is
                // deliberately wider than the touch tolerance so no single bar
                // can score as both a touch and a break.
                bool through = p == 1 ? close < v - brkPx : close > v + brkPx
                // v1.1: PERSISTENCE BREAK. A close on the wrong side counts even
                // when it is too shallow to clear brkPx, provided it keeps
                // happening. Resets the moment price closes back on its own side,
                // so a single deep wick-and-recover cannot accumulate.
                bool wrongSide = p == 1 ? close < v : close > v
                array.set(tWrong, i, wrongSide ? array.get(tWrong, i) + 1 : 0)
                if through or array.get(tWrong, i) >= BRK_BARS
                    array.set(tState, i, 2)
                    array.set(tBrk,   i, bar_index)
                    st := 2
                    didBrk := true

            else if st == 2
                // ── resolve the break: retest, failed break, or neither ──
                // 🔴 ADVERSARIAL-REVIEW FIX: A RETEST REQUIRES PRICE TO HAVE LEFT
                // FIRST. Without this gate the tool marks a retest on the bar
                // immediately after almost every break, because a marginal break
                // closes just below the line and the very next bar's wick is
                // still touching it. That is not a return to the level, it is the
                // same candle cluster that broke it, and it would have made
                // "retest" the most common and least meaningful state in the file.
                // Price has left once a whole bar sits clear of the line on the
                // break side.
                bool gone = p == 1 ? high < v : low > v
                if gone
                    array.set(tAway, i, true)
                // Failed break is tested FIRST because it is the stronger
                // statement. Price closing back on the original side means the
                // line was never actually beaten, and that settles the question
                // regardless of whether the bar also touched.
                bool backInside = p == 1 ? close > v + brkPx : close < v - brkPx
                // A retest needs price to REACH the line again from the new side.
                bool reached = p == 1 ? (high >= v - tolPx) : (low <= v + tolPx)
                bool held    = rtMode == "Touch" ? true : (p == 1 ? close < v : close > v)
                bool ready   = array.get(tAway, i)
                if backInside
                    array.set(tState, i, 4)      // FAILED BREAK
                    st := 4
                    didFail := true
                else if ready and reached and held
                    didRt := true
                    // v1.2: RETESTED IS NO LONGER THE END OF THE LINE'S LIFE.
                    // The retest is the line PROVING it still matters, so stopping
                    // work on it there was backwards. Old support is now resistance:
                    // the polarity flips, the line returns to VALIDATED, and the
                    // break watch resumes on the other side. tDir is untouched, so
                    // colour and the channel rail keep describing the same geometry.
                    // Bounded by FLIP_CAP, which is the reason the state was terminal
                    // in the first place.
                    int fl = array.get(tFlip, i)
                    if fl < FLIP_CAP
                        array.set(tFlip,  i, fl + 1)
                        array.set(tPol,   i, -p)
                        array.set(tState, i, 1)
                        array.set(tAway,  i, false)   // the departure gate must be re-earned
                        array.set(tWrong, i, 0)       // persistence counter starts clean
                        array.set(tLast,  i, bar_index)  // touch-gap clock restarts here
                        st := 1
                    else
                        array.set(tState, i, 3)      // cap reached: terminal, as before
                        st := 3
                    if showMark
                        label.new(bar_index, p == 1 ? high : low, "✓", xloc=xloc.bar_index,
                             style=label.style_label_center, color=COL_NONE,
                             textcolor=f_base(d), size=size.small,
                             tooltip="Retest confirmed. Price came back to the broken trendline and respected it from the other side: old support acting as resistance, or old resistance reclaimed as support.\n\nThis is the moment the line proved it still matters after being broken.")
                else if bar_index - array.get(tBrk, i) >= rtBars
                    array.set(tState, i, 5)      // break expired unresolved
                    st := 5

        // ── render ──
        // Live and broken lines track price; resolved ones freeze where they
        // resolved. Resolved lines FADE rather than being deleted: a chart that
        // only ever shows the lines that worked is a chart that cannot be
        // learned from.
        color c = f_col(d, st)
        line lnI = array.get(tLn, i)
        line chI = array.get(tCh, i)
        line.set_color(lnI, c)
        if st <= 2
            line.set_x2(lnI, bar_index)
            line.set_y2(lnI, v)
            if not na(chI)
                float dv = array.get(tDev, i)
                line.set_color(chI, color.new(f_base(d), TR_CHAN))
                line.set_x2(chI, bar_index)
                line.set_y2(chI, v + d * dv)
        else
            // Dotted once resolved: still a reference, no longer live structure.
            line.set_style(lnI, line.style_dotted)
            if not na(chI)
                line.set_color(chI, COL_NONE)
            // 🔴 ADVERSARIAL-REVIEW FIX: the fill has to be retired with its rail.
            // The first draft hid the channel line and left the linefill fully
            // painted, so a resolved line kept a solid diagonal band on the chart
            // with no visible rail bounding it - which is exactly the liquidity-pool
            // look this tool is supposed to stay out of.
            linefill flI = array.get(tFl, i)
            if not na(flI)
                linefill.set_color(flI, COL_NONE)
        if showLbl
            string txt = st == 0 ? "trend " + str.tostring(array.get(tTouch, i))
                 : st == 1 ? "trend " + str.tostring(array.get(tTouch, i)) + " ✓" + (array.get(tFlip, i) > 0 ? " R" + str.tostring(array.get(tFlip, i)) : "")
                 : st == 2 ? "BROKE"
                 : st == 3 ? "RETEST ✓"
                 : st == 4 ? "FAILED" : "BROKE ·"
            // Resolved labels are simply not moved, rather than being repositioned
            // from their own stored coordinates. Reading a drawing's coordinates
            // back to place another drawing breaks the house rule outright, and
            // leans on getters that do not exist for every drawing type.
            if st <= 2
                label.set_xy(array.get(tLb, i), bar_index, v)
            label.set_text(array.get(tLb, i), txt)
            label.set_textcolor(array.get(tLb, i), c)
        else
            label.set_text(array.get(tLb, i), "")


// ═══════════════════════════════════════════════════════════════════════
//  CULL - cap LIVE lines only (forming, validated, and awaiting a retest).
//  Resolved lines are history and do not compete for the budget.
//  Size guards required: Pine runs `for 0 to -1` ONCE on an empty array.
// ═══════════════════════════════════════════════════════════════════════
bool trim = true
while trim
    int cnt   = 0
    int first = -1
    int sz    = array.size(tDir)
    if sz > 0
        for j = 0 to sz - 1
            if array.get(tState, j) <= 2
                cnt += 1
                if first == -1
                    first := j
    if cnt > maxLines and first >= 0
        f_del(first)
    else
        trim := false

// Hard total ceiling. Unlike the live cap this one MUST be able to evict whatever
// is actually filling the array, so it drops the oldest row of any state. The
// failure mode of a cap that can only delete one category was caught in MM Volume
// Imbalance v1.7 and is not repeated here.
while array.size(tDir) > HARD_CAP
    f_del(0)


// ═══════════════════════════════════════════════════════════════════════
//  HIGHER-TIMEFRAME ENGINE (v1.4) - self-contained, shares no code path above.
//
//  Everything here operates on a ring buffer of COMPLETED higher-timeframe bars, not
//  on chart bars. That is what makes an HTF line honest: the cleanliness scan is a real
//  walk over HTF closes, a touch is a real HTF touch, and a break is a real HTF close
//  through the line. A tool that anchors on HTF pivots and then judges everything on
//  chart closes is describing your chart timeframe while wearing an HTF label.
// ═══════════════════════════════════════════════════════════════════════
// NON-REPAINT: `[1]` + lookahead_on returns the last CLOSED HTF bar, never the one in
// progress. A tuple request keeps the four values atomically from the SAME bar; four
// separate calls could straddle a boundary and hand back a mixed bar.
// Called unconditionally because request.security must not sit inside `if` scope
// without dynamic_requests, so the feed costs the same whether the layer is on or off.
[sH, sL, sC, sT] = request.security(syminfo.tickerid, htfTf,
     [high[1], low[1], close[1], time[1]], lookahead = barmerge.lookahead_on)
float sAtr = request.security(syminfo.tickerid, htfTf, ta.atr(200)[1], lookahead = barmerge.lookahead_on)

var array<float> hbH = array.new<float>()
var array<float> hbL = array.new<float>()
var array<float> hbC = array.new<float>()
var array<int>   hbT = array.new<int>()
// Absolute count of completed HTF bars ever seen. Buffer slots shift as old bars are
// evicted, so anchors are stored as ABSOLUTE indices and converted on demand. Storing
// slot numbers would silently re-point every line the first time the buffer overflowed.
var int hbN = 0

// HTF-scaled tolerances. Falls back to chart ATR only so a fresh chart with no HTF
// history yet cannot produce na comparisons that read as false and silently pass gates.
float hAtr  = nz(sAtr, atr)
float hTol  = hAtr * TOUCH_ATR
float hBrk  = hAtr * BRK_ATR

// Absolute index -> buffer slot. Negative or past the end means the bar has been
// evicted and anything depending on it is unverifiable.
f_hSlot(int a) => a - hbN + array.size(hbH)

// ── HTF cleanliness scan ──
// Same rule as the chart-TF scan: a line the market CLOSED through on its way to the
// second anchor was never respected, and wicks through are allowed because an overshoot
// of a trendline is normal structure.
// Carries the same adversarial fix as its sibling: a span it cannot verify is REJECTED,
// never accepted. Returning true for an unscannable pair is the tool asserting a
// property it never checked.
f_hScan(int dir, int a1, float y1, float slope, int a2) =>
    int  s1 = f_hSlot(a1)
    int  s2 = f_hSlot(a2)
    bool ok = true
    if s1 < 0 or s2 >= array.size(hbH) or s2 <= s1
        ok := false
    else if s2 == s1 + 1
        ok := true
    else
        for k = s1 + 1 to s2 - 1
            int   ab = hbN - array.size(hbH) + k
            float v  = y1 + slope * (ab - a1)
            if dir == 1 and array.get(hbC, k) < v - hTol
                ok := false
                break
            if dir == -1 and array.get(hbC, k) > v + hTol
                ok := false
                break
    ok

// ── HTF line rows ──
var array<int>   hlDir = array.new<int>()
var array<int>   hlA1  = array.new<int>()      // absolute HTF index of the first anchor
var array<float> hlY1  = array.new<float>()
var array<float> hlSl  = array.new<float>()    // price per HTF BAR, not per chart bar
var array<int>   hlT1  = array.new<int>()      // anchor time, for xloc.bar_time drawing
var array<int>   hlTch = array.new<int>()
var array<int>   hlLst = array.new<int>()      // absolute index of the last counted touch
var array<int>   hlSt  = array.new<int>()      // 0 form 1 valid 2 broke 3 retest 4 fail 5 expire
var array<int>   hlBrk = array.new<int>()
var array<bool>  hlAwy = array.new<bool>()
var array<line>  hlLn  = array.new<line>()
var array<label> hlLb  = array.new<label>()

f_hBase(int dir) => dir == 1 ? htfUp : htfDn

f_hDel(int i) =>
    line.delete(array.get(hlLn, i))
    label.delete(array.get(hlLb, i))
    array.remove(hlDir, i)
    array.remove(hlA1,  i)
    array.remove(hlY1,  i)
    array.remove(hlSl,  i)
    array.remove(hlT1,  i)
    array.remove(hlTch, i)
    array.remove(hlLst, i)
    array.remove(hlSt,  i)
    array.remove(hlBrk, i)
    array.remove(hlAwy, i)
    array.remove(hlLn,  i)
    array.remove(hlLb,  i)
    0

f_hAdd(int dir, int a1, float y1, int t1, int a2, float y2, int t2) =>
    float sl = (y2 - y1) / (a2 - a1)
    bool ok = f_hScan(dir, a1, y1, sl, a2)
    // Same slope ceiling as the chart-TF engine, in HTF ATR per HTF bar. A near-vertical
    // line is valid geometry and worthless structure on any timeframe.
    if ok and math.abs(sl) > hAtr * maxSlope
        ok := false
    // Near-duplicate guard. Cheaper than the chart-TF two-point test because the HTF
    // pool is small: two same-direction lines within a touch tolerance of each other at
    // the current bar are one structure found twice.
    if ok and array.size(hlDir) > 0
        for q = 0 to array.size(hlDir) - 1
            if array.get(hlDir, q) == dir and array.get(hlSt, q) <= 1
                float vq = array.get(hlY1, q) + array.get(hlSl, q) * (a2 - array.get(hlA1, q))
                if math.abs(vq - y2) < hTol
                    ok := false
    if ok
        line ln = line.new(t1, y1, t2, y2, xloc = xloc.bar_time,
             color = f_hBase(dir), width = htfW)
        label lb = label.new(t2, y2, "", xloc = xloc.bar_time,
             style = label.style_label_left, color = COL_NONE,
             textcolor = f_hBase(dir), size = size.small)
        array.push(hlDir, dir)
        array.push(hlA1,  a1)
        array.push(hlY1,  y1)
        array.push(hlSl,  sl)
        array.push(hlT1,  t1)
        array.push(hlTch, 2)                 // both anchors are touches
        array.push(hlLst, a2)
        array.push(hlSt,  2 >= htfTch ? 1 : 0)
        array.push(hlBrk, 0)
        array.push(hlAwy, false)
        array.push(hlLn,  ln)
        array.push(hlLb,  lb)
    0

// ── the last confirmed pivot on each side ──
var float hPHy = na
var int   hPHa = na
var int   hPHt = na
var float hPLy = na
var int   hPLa = na
var int   hPLt = na

// A new completed HTF bar has arrived when its timestamp changes.
bool htfNew = htfOn and not na(sT) and (na(sT[1]) or sT != sT[1])

if htfNew
    array.push(hbH, sH)
    array.push(hbL, sL)
    array.push(hbC, sC)
    array.push(hbT, sT)
    hbN += 1
    while array.size(hbH) > HTF_CAP
        array.remove(hbH, 0)
        array.remove(hbL, 0)
        array.remove(hbC, 0)
        array.remove(hbT, 0)

    // ── pivot detection, run locally over the buffer ──
    // Only ONE candidate can newly confirm per bar: the one exactly htfPiv bars back.
    // Checking it alone mirrors how ta.pivothigh confirms and keeps this O(htfPiv).
    // Ties reject on both sides, matching ta.pivothigh's strict comparison.
    int nb = array.size(hbH)
    if nb >= htfPiv * 2 + 1
        int   ci = nb - 1 - htfPiv
        float cH = array.get(hbH, ci)
        float cL = array.get(hbL, ci)
        int   cA = hbN - nb + ci
        int   cT = array.get(hbT, ci)
        bool  okH = true
        bool  okL = true
        for k = 1 to htfPiv
            if array.get(hbH, ci - k) >= cH or array.get(hbH, ci + k) >= cH
                okH := false
            if array.get(hbL, ci - k) <= cL or array.get(hbL, ci + k) <= cL
                okL := false
        // Falling resistance needs a strictly LOWER second high, rising support a
        // strictly HIGHER second low. That pairing rule is also what makes a horizontal
        // HTF line unreachable by construction, exactly as on the chart-TF side.
        if okH
            if showDn and not na(hPHy) and cH < hPHy
                f_hAdd(-1, hPHa, hPHy, hPHt, cA, cH, cT)
            hPHy := cH
            hPHa := cA
            hPHt := cT
        if okL
            if showUp and not na(hPLy) and cL > hPLy
                f_hAdd(1, hPLa, hPLy, hPLt, cA, cL, cT)
            hPLy := cL
            hPLa := cA
            hPLt := cT

    // ── lifecycle, judged on THIS completed HTF bar ──
    // The whole point of the ring buffer: a break here is an HTF close through the line,
    // not a chart close. An HTF line therefore dies up to one HTF bar later than a lower
    // timeframe chart makes it look like it should, which is correct.
    int   aNow = hbN - 1
    float bH   = array.get(hbH, array.size(hbH) - 1)
    float bL   = array.get(hbL, array.size(hbH) - 1)
    float bC   = array.get(hbC, array.size(hbH) - 1)
    if array.size(hlDir) > 0
        for i = array.size(hlDir) - 1 to 0
            int   d  = array.get(hlDir, i)
            int   st = array.get(hlSt, i)
            float v  = array.get(hlY1, i) + array.get(hlSl, i) * (aNow - array.get(hlA1, i))
            // NO birth-bar guard here, and that is correct rather than an omission.
            // The chart-TF engine needs one because a line is created on the same bar
            // its second anchor confirms. Here the anchor is a PIVOT, which confirms
            // htfPiv bars after it printed, so this bar is already well past both
            // anchors and is genuinely eligible to touch or break the line.
            if st <= 1
                bool nearH = d == 1 ? (bL <= v + hTol and bC >= v - hTol)
                     : (bH >= v - hTol and bC <= v + hTol)
                if nearH and aNow - array.get(hlLst, i) >= 1
                    array.set(hlTch, i, array.get(hlTch, i) + 1)
                    array.set(hlLst, i, aNow)
                    if array.get(hlTch, i) >= htfTch and st == 0
                        array.set(hlSt, i, 1)
                        st := 1
                bool thru = d == 1 ? bC < v - hBrk : bC > v + hBrk
                if thru
                    array.set(hlSt,  i, 2)
                    array.set(hlBrk, i, aNow)
                    st := 2
            else if st == 2
                // A retest requires price to have genuinely LEFT first, or the bar
                // after almost every marginal break scores as one.
                if d == 1 ? bH < v : bL > v
                    array.set(hlAwy, i, true)
                bool backIn  = d == 1 ? bC > v + hBrk : bC < v - hBrk
                bool reached = d == 1 ? bH >= v - hTol : bL <= v + hTol
                bool heldIt  = d == 1 ? bC < v : bC > v
                if backIn
                    array.set(hlSt, i, 4)
                else if array.get(hlAwy, i) and reached and heldIt
                    array.set(hlSt, i, 3)
                else if aNow - array.get(hlBrk, i) >= HTF_RT
                    array.set(hlSt, i, 5)

    // Budget is separate from maxLines so switching this layer on can never evict
    // chart-TF structure. Oldest live line goes first.
    while array.size(hlDir) > HTF_LINES
        f_hDel(0)

// Switching the layer off clears its drawings rather than freezing them on the chart.
if not htfOn and array.size(hlDir) > 0
    while array.size(hlDir) > 0
        f_hDel(0)

// ── HTF render ──
// Live lines extend one full HTF bar past the last completed one, which is where the
// bar in progress ends. The step is measured from the buffer rather than from
// timeframe.in_seconds(), which is unreliable on monthly and would be wrong exactly
// where an HTF tool is most useful.
if htfOn and barstate.islast and array.size(hlDir) > 0 and array.size(hbT) >= 2
    int nbb   = array.size(hbT)
    int hStep = array.get(hbT, nbb - 1) - array.get(hbT, nbb - 2)
    int xEnd  = array.get(hbT, nbb - 1) + hStep
    int aEnd  = hbN
    for i = 0 to array.size(hlDir) - 1
        int   d  = array.get(hlDir, i)
        int   st = array.get(hlSt, i)
        float ve = array.get(hlY1, i) + array.get(hlSl, i) * (aEnd - array.get(hlA1, i))
        color cc = st <= 1 ? f_hBase(d) : st == 2 ? color.new(f_hBase(d), TR_BROKE)
             : color.new(f_hBase(d), TR_RESOLVED)
        line ln = array.get(hlLn, i)
        line.set_color(ln, cc)
        if st <= 2
            line.set_x2(ln, xEnd)
            line.set_y2(ln, ve)
            label.set_xy(array.get(hlLb, i), xEnd, ve)
        else
            line.set_style(ln, line.style_dotted)
        string tx = st == 0 ? "HTF " + str.tostring(array.get(hlTch, i))
             : st == 1 ? "HTF " + str.tostring(array.get(hlTch, i)) + " ✓"
             : st == 2 ? "HTF BROKE"
             : st == 3 ? "HTF RETEST ✓"
             : st == 4 ? "HTF FAILED" : "HTF BROKE ·"
        label.set_text(array.get(hlLb, i), showLbl ? tx : "")
        label.set_textcolor(array.get(hlLb, i), cc)


// ═══════════════════════════════════════════════════════════════════════
//  STATUS CARD (v1.2) - one var table, wiped and rebuilt on islast.
//  Answers the question the chart cannot: with six lines drawn, WHICH ONE matters on
//  this bar. A separate read-only pass over the same arrays, deliberately kept out of
//  the lifecycle loop above - that loop runs on confirmed bars and mutates state, and
//  entangling a display scan with it is how a display change starts breaking behaviour.
//  Runs on the last bar only, so the cost is one pass over at most HARD_CAP rows.
// ═══════════════════════════════════════════════════════════════════════
var table tlTbl = table.new(position.top_right, 2, 7, border_width = 1)

if showCard and barstate.islast
    int   nLive  = 0
    int   nPend  = 0
    int   nearI  = -1
    float nearD  = -1.0
    // Nearest LIVE line to price. Resolved lines are history and are not competing for
    // your attention, so they are not eligible to be "the one that matters".
    if array.size(tDir) > 0
        for i = 0 to array.size(tDir) - 1
            int st2 = array.get(tState, i)
            if st2 <= 2
                nLive += 1
                if st2 == 2
                    nPend += 1
                float v2 = f_valAt(array.get(tY1, i), array.get(tSlope, i), array.get(tX1, i), bar_index)
                float dd = math.abs(close - v2)
                if nearD < 0 or dd < nearD
                    nearD := dd
                    nearI := i

    // v1.4: the apex is computed once, globally, by f_apex. The card and the alert
    // read the same result so they can never disagree about where it is.
    table.clear(tlTbl, 0, 0, 1, 6)
    table.set_position(tlTbl, f_tblPos(cardPos))
    table.set_bgcolor(tlTbl, color.new(#0e1621, 12))
    table.set_frame_color(tlTbl, color.new(#f5a800, 55))
    table.set_frame_width(tlTbl, 1)
    table.set_border_color(tlTbl, color.new(#f5a800, 80))
    string csz = cardSize

    table.cell(tlTbl, 0, 0, "MM TRENDLINES", text_color = #f5a800, text_size = f_tblSize(csz))
    table.cell(tlTbl, 1, 0, str.tostring(nLive) + " LIVE", text_color = #f5a800, text_size = f_tblSize(csz))

    bool  hasN  = nearI >= 0
    int   nd    = hasN ? array.get(tDir, nearI) : 0
    // v1.3: the ROLE, which is not the same thing as the identity once a line has
    // flipped. Reading tDir alone here made the card contradict the engine.
    int   np    = hasN ? array.get(tPol, nearI) : 0
    int   nst   = hasN ? array.get(tState, nearI) : 0
    int   nfl   = hasN ? array.get(tFlip, nearI) : 0
    color nc    = hasN ? f_base(nd) : color.gray

    table.cell(tlTbl, 0, 1, "NEAREST", text_color = color.silver, text_size = f_tblSize(csz))
    table.cell(tlTbl, 1, 1, hasN ? (nd == 1 ? "RISING" : "FALLING") + " · " + (np == 1 ? "SUP" : "RES") : "--",
         text_color = nc, text_size = f_tblSize(csz))

    // Both units on purpose: points tell you the risk, ATR tells you whether that is
    // actually close on this instrument. Neither one answers it alone.
    table.cell(tlTbl, 0, 2, "DISTANCE", text_color = color.silver, text_size = f_tblSize(csz))
    table.cell(tlTbl, 1, 2, hasN and atr > 0 ? str.tostring(nearD, format.mintick) + " · " + str.tostring(nearD / atr, "#.00") + " ATR" : "--",
         text_color = hasN ? color.silver : color.gray, text_size = f_tblSize(csz))

    table.cell(tlTbl, 0, 3, "STATE", text_color = color.silver, text_size = f_tblSize(csz))
    table.cell(tlTbl, 1, 3, hasN ? f_stName(nst) + " · " + str.tostring(array.get(tTouch, nearI)) + "T" + (nfl > 0 ? " R" + str.tostring(nfl) : "") : "--",
         text_color = hasN ? nc : color.gray, text_size = f_tblSize(csz))

    // The most time-sensitive thing the tool knows: a line that broke and has not yet
    // told you whether it was a retest or a failed break.
    table.cell(tlTbl, 0, 4, "WATCHING", text_color = color.silver, text_size = f_tblSize(csz))
    table.cell(tlTbl, 1, 4, nPend > 0 ? str.tostring(nPend) + " PENDING" : "--",
         text_color = nPend > 0 ? #f5a800 : color.gray, text_size = f_tblSize(csz))

    table.cell(tlTbl, 0, 5, "APEX", text_color = color.silver, text_size = f_tblSize(csz))
    bool apxOk = showApex and apexBars > 0
    table.cell(tlTbl, 1, 5, apxOk ? str.tostring(apexBars) + "b @ " + str.tostring(apexPx, format.mintick) : "--",
         text_color = apxOk ? color.silver : color.gray, text_size = f_tblSize(csz))

    // v1.4: HTF lines are counted separately because they are a separate engine with a
    // separate budget. Rolling them into LIVE would make the top row lie about which
    // pool the cull is about to act on.
    int nHtf = 0
    if htfOn and array.size(hlSt) > 0
        for i = 0 to array.size(hlSt) - 1
            if array.get(hlSt, i) <= 2
                nHtf += 1
    table.cell(tlTbl, 0, 6, "HTF", text_color = color.silver, text_size = f_tblSize(csz))
    table.cell(tlTbl, 1, 6, htfOn ? str.tostring(nHtf) + " · " + htfTf : "OFF",
         text_color = htfOn and nHtf > 0 ? htfUp : color.gray, text_size = f_tblSize(csz))


// ═══════════════════════════════════════════════════════════════════════
//  ALERTS - double-gated: the event AND the user's per-event toggle.
// ═══════════════════════════════════════════════════════════════════════
alertcondition(alNew and didNew, "Trendline validated",
     "A trendline reached its touch threshold on {{ticker}} {{interval}}")
alertcondition(alBrk and didBrk, "Trendline broken",
     "Price closed through a validated trendline on {{ticker}} {{interval}} - watching for the retest")
alertcondition(alRt and didRt, "Trendline retest confirmed",
     "A broken trendline was retested and held from the other side on {{ticker}} {{interval}} - role reversal confirmed")
alertcondition(alApex and apxHit, "Trendline convergence approaching",
     "Two validated trendlines are converging on {{ticker}} {{interval}} - the structure is running out of room")
alertcondition(alFail and didFail, "Failed trendline break",
     "A trendline break failed on {{ticker}} {{interval}} - price closed straight back on the original side")
````
