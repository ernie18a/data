<!-- tradingview-pine-id: PUB;d0f0af79f7e540d682385a4c372b35c7 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# MTF VWAP + POC Fan

Source: https://www.tradingview.com/script/k0xmmCQL-MTF-VWAP-POC-Fan/

## Description

### What it does

Seven fixed-lookback windows on one anchor timeframe. Each window draws a VWAP curve — where the average participant's cost sits over that span — and can optionally draw a POC, the single price bin inside that same window that traded the most volume.

Same window, two different questions:

- **VWAP** — what the average participant paid
- **POC** — where participation actually concentrated

A dashboard reads the seven VWAP endpoints and scores the structure they form.

Default ladder is a daily one: **21 / 63 / 126 / 189 / 252 / 378 / 756** bars — roughly one month through three years. The anchor timeframe is configurable, so the same ladder on Weekly becomes five months through fourteen years.

### Why fixed lookbacks instead of swing anchors

Anchoring a VWAP at a swing high or low answers a real question — "what has been paid since that event" — but those anchors collapse into each other as windows grow. If price has not exceeded its three-month high, then the six-month, twelve-month and three-year highs are all the same bar, and several rungs draw one curve.

Fixed-lookback anchors cannot collide. The bar 252 back and the bar 378 back are always different bars, so seven rungs always mean seven distinct windows. That property is what makes a seven-horizon fan worth drawing at all.

### Reading the curve correctly

This is the part most multi-window VWAP scripts leave ambiguous, so it is worth being explicit.

At its **right edge**, VW252 equals the VWAP of the last 252 anchor-TF bars. That endpoint is the number.

The **tail behind it is not a rolling 252-bar series.** Every point on the drawn curve is the accumulation from the origin that is 252 bars back *today*, so the midpoint of the line is roughly a 126-bar average. The curve does not show what VW252 read on those past dates — on any past date it was anchored 252 bars before *that* date, at a different origin entirely.

The tail is one accumulation path from today's origin. Read historical crossings with that in mind.

### How the VWAP is calculated

Standard volume-weighted mean of the source (default HLC3) from the window's origin bar to its end bar, accumulated over **chart** bars. Origins are located on the anchor timeframe, then resolved to the exact chart bar by binary search.

When volume is missing or zero the engine substitutes 1.0, and tracks the substitution rate **per window**. Two different failures hide under one symptom:

- Missing on nearly every bar (synthetic symbols, some indices) — every bar weighs the same, so the curve is an *unweighted* mean of the source. Usable if you know that is what you are reading.
- Missing on a handful of bars in a real feed — a bar weighing 1.0 against neighbours weighing millions is not averaged in, it is effectively *dropped*. Still a proper volume-weighted mean, over a slightly smaller sample.

Curves whose own window exceeds the warning rate are suffixed with `*` and counted on the dashboard.

### How the POC is calculated

The window's high-low range is divided into bins, and each bar's volume is allocated **in proportion to how much of that bar's range overlaps each bin.**

The obvious shortcut — splitting a bar's volume equally across every bin it touches — is wrong at the edges: a bar with 2% of its range in one bin and 98% in the next would contribute 50/50. Since the POC is an argmax rather than an average, that error does not wash out. It can hand the win to the wrong bin.

Fully covered interior bins are accumulated with a difference array (one increment at the low edge, one decrement at the high edge, resolved in a single prefix sum) rather than a per-bin loop, which keeps the cost at O(bars + bins).

Three deliberate constraints:

**Resolution is capped at one bin per tick.** The bin-count input is a *maximum* resolution, not permission to invent sub-tick precision. If a window's whole range spans forty ticks, a hundred bins would put several bins inside one tick and the argmax would be choosing between prices that cannot trade. The reported level is also snapped to the instrument's tick grid, because an unrounded one-tick bin from 10.00 to 10.01 reports 10.005.

**Bin width is per window.** Each window divides its *own* range, so a P756 bin can be several times wider than a P126 bin. Two POCs landing on the same price are not confirming each other to the same tolerance. Each label's tooltip prints its bin width — read the level as the centre of that band, not as a price.

**POC is suppressed, not flagged, when volume is substituted.** A VWAP with missing volume degrades into an unweighted mean, which is still a usable number. A profile with missing volume becomes a bar-*count* histogram, whose peak answers where price spent the most bars regardless of size traded. That is a different statistic wearing the POC's name, so above a threshold nothing is drawn and the dashboard names the reason.

### Why POC is drawn forward, not backward

By default a POC starts at the last calculated bar and extends right. It is not drawn back across the window it was computed from.

A VWAP tail is a continuous accumulation with a value at every bar. A POC is a single number recomputed every bar with no value anywhere but now. Drawing both back to the same origin would make one line a genuine path and the other a snapshot impersonating one — the same visual gesture carrying two different truth-values, which teaches the wrong reading and creates hindsight support that was never there.

`Window + Forward` is available when you want to see the span, with the understanding that the backward segment is decoration.

Related: a POC **jumps**. It is an argmax, so when a different bin overtakes the leader the level teleports. A POC that sat at 70k yesterday and prints 62k today is not a data error — it is a window with two shelves close in volume. The single line cannot tell you that, which is the honest limitation of showing a POC without its profile.

### The visual grammar

- **Colour = horizon identity**, fixed per rung, never reassigned when other rungs are toggled. 252 is gold whether seven rungs are on or two.
- **Solid, width 2 = VWAP**
- **Dashed, width 1 = POC**, same colour as its VWAP

There is deliberately no horizon-based transparency and no colour-by-price-position. Fading short horizons fought the pairing and restyled everything on every toggle. Colour-by-price-position was redundant with the chart itself — whether a VWAP is above or below price is visible by looking at it — and spending the colour channel on it meant colour was unavailable for identity.

The palette is a cool progression (aqua → light blue → blue → lavender → **gold at 252** → violet → deep purple) so the fan reads as one instrument rather than seven unrelated indicators. Gold breaks the ramp deliberately, because 252 is the horizon most often referenced. Green and red stay out of the palette on purpose: they belong to the candles, and to the dashboard.

The script declares `scale=scale.none` so a distant 756-bar VWAP cannot drag the price axis and compress the candles you are actually trading.

### Seven VWAPs, three POCs

All seven VWAPs ship on. Seven ordered curves read fine, and where they bunch is itself information.

POCs are opt-in per rung, defaulting to **126 / 252 / 756** only — medium-term, annual, multi-year. Seven horizontal levels crowd a chart in a way seven curves do not. P189 and P378 are one click away. Global `Show VWAPs` and `Show POCs` switches let you inspect either family alone.

### The structure dashboard

A 0–100 read on where price sits relative to the fan and whether the fan is ordered.

```
STRUCT   88
P>VW     7/7
STACK    +5/6
BIAS     STRONG BULL
P>POC    3/3
```

**Price position — 50 points.** How many VWAP endpoints price is above, as a fraction of the drawn rungs, times 50.

**Stack — 50 points.** The adjacent-pair ordering, short over long. Each of the six adjacent pairs scores +1 when the shorter window sits above the longer, −1 when inverted, 0 when they are inside an equality tolerance. Raw range −6 to +6, rescaled to 0–50.

The dashboard shows the **signed raw total** (`+5/6`, `0/6`, `−4/6`) rather than a count of bullish pairs, because that signed number is literally what enters the score. Five bullish plus one tied and five bullish plus one inverted are different fans that a bullish-pair count would render identically.

The tolerance is normalised by the **anchor timeframe's** ATR, not the chart's — otherwise the same daily fan would classify two near-identical VWAPs as tied on a 130m chart and ordered on a 39m one, purely because the chart-TF ATR is smaller.

| Score | Bias |
|---:|---|
| 85–100 | Strong Bull |
| 70–84 | Bull |
| 55–69 | Bull Lean |
| 45–54 | Neutral |
| 31–44 | Bear Lean |
| 16–30 | Bear |
| 0–15 | Strong Bear |

`P>POC` is context only and does **not** enter the score. A volume concentration is a location, not a direction.

### What the score is not

Worth stating plainly, because a 0–100 number invites more confidence than this one has earned.

**The two components are not independent.** Price above every VWAP and a perfectly stacked fan are largely the same market condition seen twice — in a sustained one-way move both max out together, in chop both sit near their middles. Treat 0–100 as one structural reading measured two ways, not as a composite of separate evidence. The extremes are easier to reach than a two-component construction suggests.

**Stack ordering is partly mechanical.** These windows are nested — VW21's bars are a subset of VW63's, which are a subset of VW126's — so in any monotonic trend the ordering *follows* from the trend rather than confirming it independently. Where it earns its keep is at turns, when the short end inverts while price position is still high. That divergence between the two rows is more informative than the combined number.

**It is a step function.** With seven rungs, price position moves in jumps of 7.14 and stack in jumps of 4.17. The reading can cross the entire neutral band between two bars without ever printing a value inside it. Small changes are not drift.

**The score is withheld when horizons are missing.** Unless every enabled rung produced a VWAP and no two rungs share a lookback, STRUCT and BIAS print `—` and a `check` row names the reason. Normalising over whatever horizons happened to exist would let a two-horizon symbol print `STRUCT 100 / STRONG BULL`, indistinguishable at a glance from a seven-horizon reading.

Practical consequence: on a symbol without 756 anchor bars of history, the score stays blank until you turn VW756 off. That is deliberate. Disabling the rungs a symbol cannot support makes the reading an explicit statement about which horizons you are using.

### Confirmed Bars Only

With this off (default), windows extend through the current chart bar and update live.

With it on, **both ends** move to completed bars: lookbacks shift back one anchor bar, and all accumulation — VWAP, POC, the dashboard's reference price, and the stack tolerance's ATR — stops at the last chart bar of the last completed anchor candle. The fan then stops moving intraday entirely, which is what the switch should mean. Labels still sit at the chart's right edge while the values belong to the last completed candle; that gap is the point of the switch.

### Settings worth knowing

- **Anchor Timeframe** — the timeframe every lookback is counted in. Must be at or above the chart timeframe. Every anchor timeframe wants its own ladder; the defaults are a daily one.
- **Profile Bins** — maximum POC resolution, capped at one bin per tick.
- **Stored Chart Bars** — an origin must fall inside stored history or its rung is dropped, not approximated. Default 10,000 because 756 daily bars on a 39m chart is roughly 7,500 chart bars.
- **Dim rungs far from price** — optional, off by default. Fades a rung whose VWAP is beyond a set ATR distance. The whole rung dims together so a pair never splits into one bright line and one faint one. Try `scale.none` alone first.
- **Update Mode** — Live redraws every tick, which is necessary rather than wasteful: Pine destroys drawing objects created on an uncommitted tick, so on the forming bar a redraw every tick is the only way curves stay on screen. On Bar Close draws only on committed executions. Use it, or turn POCs off, if the profile passes trip the calculation time limit.
- **Show Diagnostics Panel** — full accounting of rungs, drawn objects and failure reasons. Off by default; anything genuinely wrong still surfaces on the dashboard's `check` row.

### Known properties

**Chart-timeframe sensitivity.** Origins come from the anchor timeframe, but accumulation uses chart bars, so the same daily setup gives slightly different values on a 39m chart than a 130m one. For the VWAPs this is second order — averaging washes out coarse bucketing. For the POC it is not: an argmax does not average, and a coarse bar spreads its volume uniformly across a range it never traded uniformly through. Expect the POC to shift by a bin or two between chart timeframes, more on symbols with frequent wide-range bars.

**Duplicate lookbacks are counted, never merged.** Two rungs set to the same number draw two identical curves in two colours, which looks like two horizons agreeing and is really one horizon entered twice. The dashboard flags it and withholds the score.

### Why VWAP and POC live in one script

They are computed from the same window definition. Splitting them would mean two indicators independently re-deriving identical origins, and would make it impossible to guarantee that P252 and VW252 cover exactly the same bars — which is the entire point of reading them as a pair. The dashboard reads only the VWAPs; the POC family is excluded from it precisely because it answers a non-directional question.

---

*This is a structural reference tool, not a signal generator. Nothing here produces entries, exits or alerts, and no part of it is a claim about future prices. Published open source so the calculations can be checked rather than taken on trust.*

---

## Source Code

````pine
//@version=6
indicator(
     "MTF VWAP + POC Fan",
     shorttitle="VW+POC Fan",
     overlay=true,
     max_polylines_count=100,
     max_labels_count=100,
     max_lines_count=20,
     max_bars_back=2500,
     scale=scale.none
)

// ============================================================================
// WHAT THIS IS
//
// Seven fixed-lookback windows on one anchor timeframe. Each window produces
// one object, and selected windows a second:
//
//   VWAP (solid)  — the volume-weighted average price over that window. Where
//                   the average participant's cost sits.
//   POC  (dashed) — the price bin inside that window that traded the most
//                   volume. Where participation concentrated. OPT-IN per rung,
//                   because seven horizontal levels crowd a chart in a way
//                   seven curves do not.
//
// Same window, two different questions, and the pair reads as a unit:
//
//   VW252 48.20 / P252 44.70 — the year's average cost is above the year's
//   busiest price, so the heaviest trade happened below where the average
//   participant is now.
//   VW63  52.10 / P63  53.00 — the recent window sits higher than both, and
//   in the recent window the busiest price is above the average cost.
//
// Reading that across seven horizons is the point of the indicator. Nothing
// here is a signal; it is a map of where cost and volume sit at each horizon.
//
// WHY THERE ARE NO EXTREME (HH/LL) ANCHORS HERE
//
// Anchoring at the highest high or lowest low of a window answers a genuinely
// different question — "what has been paid since that event" — and it is a good
// question. It belongs in its own indicator, and it has one: the Rolling
// Extreme AVWAP Fan is unchanged and still runs alongside this.
//
// The reason to separate them rather than combine: extreme anchors DEGENERATE
// as windows grow. If price has not exceeded its 3-month high, the 6-month,
// 12-month and 3-year highs are all the same bar, so several rungs collapse to
// one curve. Fixed-lookback anchors cannot collide — 252, 378 and 756 bars back
// are always three different bars — so every rung here is guaranteed to be a
// distinct window. Mixing the two families meant one indicator where half the
// rungs sometimes vanished into each other and half never could.
//
// WHAT A FIXED-LOOKBACK VWAP ACTUALLY IS
//
// At its RIGHT EDGE, VW252 equals the VWAP of the last 252 anchor-TF bars. The
// curve BEHIND that point is not a 252-period rolling series — every point on
// it is an anchored VWAP from the origin that is 252 bars back TODAY, so the
// midpoint of the drawn line is roughly a 126-bar average. The endpoint is the
// number; the tail is the path that endpoint took from a fixed origin. Read
// historical crossings accordingly.
//
// THE VISUAL GRAMMAR
//
//   COLOUR  = horizon identity. Fixed per rung, never reassigned. 252 is gold
//             whether seven rungs are on or two. You should end up recognising
//             the pairs without reading labels.
//   SOLID   = VWAP,   width 2
//   DASHED  = POC,    width 1, same colour as its VWAP
//
// The palette is a cool progression — aqua, light blue, blue, lavender, then
// gold at 252, violet, deep purple — rather than seven unrelated hues, so the
// fan reads as one instrument instead of seven indicators. Gold at the centre
// breaks the ramp deliberately: 252 is the horizon most often referenced, and a
// pure gradient would make it no more findable than its neighbours. The cost of
// a coordinated progression is that ADJACENT rungs are similar by construction —
// 63 and 126 are both blues. Labels resolve it; if you find yourself squinting,
// widen the two you actually use rather than fighting the whole ramp.
//
// Green and red stay out of the palette on purpose. They belong to the candles.
//
// SCALE. The indicator declares scale=scale.none. A 756-bar VWAP can sit far
// from current price, and letting it into the price scale compresses the actual
// candles into a band while the chart autoscales to accommodate a line you are
// only using as a reference.
//
// That is the whole encoding. There is deliberately NO transparency grading by
// horizon and NO colour-by-price-position:
//
//   Transparency grading fought the pairing. If VW63 and P63 are both meant to
//   read as "the 63 window", fading the short horizons makes the pair harder to
//   see as a pair, and a rank-based fade also restyled everything whenever a
//   rung was toggled.
//
//   Colour-by-price-position was the one encoding in the old design that was
//   redundant with the chart itself. Whether a VWAP sits above or below price
//   is visible by looking at whether the line is above or below the candles.
//   Spending the colour channel on it, and thereby not having colour available
//   for identity, was the worse trade.
//
// NO MERGE, NO NEAR-DUPLICATE DECLUTTER
//
// Both existed in the extreme fan for reasons that do not survive here.
//
//   MERGE combined curves sharing an origin. Fixed-lookback rungs can only
//   share an origin if two of them are set to the same number, which is a
//   configuration mistake, not a structure worth collapsing. The status panel
//   now COUNTS duplicates instead of hiding them.
//
//   DECLUTTER hid a curve whose value happened to coincide with another's.
//   Under an identity encoding that is actively destructive: hiding VW378
//   because it converged with VW252 deletes a horizon from the map. Two
//   horizons converging is a finding — the same price is the average cost over
//   two different spans — and it is exactly what you would want to see.
//
// ============================================================================
// POC — WHAT IT IS AND WHAT IT IS NOT
//
//   IT IS A POINT VALUE, NOT A CONTINUOUS SERIES. A VWAP curve has a defined
//   value at every bar along it: each point is the accumulation from that
//   rung's origin up to that bar. That is NOT the same as saying the curve
//   shows what VW252 read on those dates — it did not, because on any past date
//   VW252 was anchored 252 bars before THAT date, at a different origin. The
//   tail is one accumulation path from today's origin. A POC is one number
//   the window as it stands today. So POC defaults to CURRENT FORWARD — it
//   starts at the last calculated bar and extends right, and nothing is drawn
//   over history that was never true. "Window + Forward" is available when you
//   want to see the span, with the understanding that the backward segment is
//   decoration. Without that default, a solid line running back to the anchor
//   would be a real path and a dashed line running back to the same anchor
//   would be a snapshot impersonating one — the same gesture, two different
//   truth-values.
//
//   IT JUMPS. A VWAP moves smoothly because it is an average. A POC moves in
//   steps because it is an argmax: when a different bin overtakes the leader,
//   the level teleports. A POC that sat at 70k yesterday and prints 62k today
//   is not a data error — it is a bimodal window whose two shelves are close in
//   volume. Worth knowing, and the single line cannot tell you, which is the
//   real cost of showing POC without the profile.
//
//   BIN WIDTH IS PER WINDOW, so two POCs agreeing agree at different
//   precisions. Each window divides its OWN range into pocBins, so a P756 bin
//   can be several times wider than a P126 bin. The label tooltip prints each
//   window's bin width; check it before treating a cluster as precise
//   agreement.
//
//   NOT DRAWING THE PROFILE SAVES RENDERING, NOT COMPUTE. The histogram is
//   built either way; the argmax requires it. POC is the expensive half of this
//   indicator, and "Show POCs" is the lever if it gets slow.
//
//   VOLUME SUBSTITUTION KILLS IT OUTRIGHT. A VWAP on a symbol with no volume
//   degrades into an unweighted mean of the source — a usable number, just a
//   different one. A POC does not degrade: with every bar weighing 1.0 the
//   profile becomes a bar-COUNT histogram, whose peak is where price spent the
//   most BARS regardless of size traded. That is a different statistic wearing
//   the POC's name, so it is SUPPRESSED above a threshold rather than drawn
//   with an asterisk. The status panel names the reason.
//
// HOW VOLUME IS DISTRIBUTED INTO BINS
//
// Each bar's volume is allocated in PROPORTION to how much of the bar's range
// overlaps each bin. Splitting equally across touched bins — the obvious first
// implementation — is wrong at the edges: a bar with 2% of its range in bin A
// and 98% in bin B would contribute 50/50. Since POC is an argmax and not an
// average, that error does not wash out; it can hand the win to the wrong bin.
//
// Uniform-within-the-bar is still an approximation (real intrabar volume is not
// uniform) but it is the standard one, and unlike close-dumping it does not
// manufacture peaks at round closing prices.
//
// Bar interiors use a difference array rather than a per-bin loop: fully
// covered bins all take the same density, so one increment at the low edge and
// one decrement at the high edge, resolved by a single prefix sum, replaces the
// inner loop. O(bars + bins) instead of O(bars x bins touched). The window's
// range still needs its own pass first — bin edges cannot be known until the
// range is — so the profile is two passes over the window, not one.
//
// CONFIRMED-ONLY IS SYMMETRIC
//
// With the switch ON, BOTH ENDS of every window move to completed bars: the
// lookback shifts back one anchor bar AND all accumulation, VWAP and POC alike,
// stops at the last chart bar of the last COMPLETED anchor-TF candle. The fan
// then stops moving intraday, which is what the switch was always supposed to
// mean. The labels still sit at the chart's right edge while the values belong
// to the last completed candle; that gap is the point of the switch.
//
// A KNOWN PROPERTY, NOT FIXED HERE
//
// Anchors come from anchorTF, but accumulation uses CHART bars. The same
// D-anchor setup yields slightly different values on a 39m vs a 130m chart. For
// the VWAPs this is second order — averaging washes out coarse bucketing. For
// the POC it is not: an argmax does not average, and a coarse bar spreads its
// volume uniformly across a range it never traded uniformly through. Expect the
// POC to shift by a bin or two between chart timeframes, more on symbols with
// frequent wide-range bars.
// ============================================================================

// ============================================================================
// ANCHOR TIMEFRAME
// ============================================================================

groupAnchor = "Anchor Timeframe"

anchorTF = input.timeframe(
     "D",
     "Anchor Timeframe",
     group=groupAnchor,
     tooltip="The timeframe every lookback below is counted in. Must be at or above the chart timeframe. 252 on D is a year; 252 on W is nearly five. Every anchor timeframe wants its own ladder — the defaults here are a daily ladder."
)

confirmedOnly = input.bool(
     false,
     "Anchor On Confirmed Bars Only",
     group=groupAnchor,
     tooltip="OFF (default): windows extend through the current chart bar and update live. ON: BOTH ENDS move to completed bars — lookbacks shift back one anchor bar, and all accumulation stops at the last chart bar of the last completed anchor-TF candle. The fan then stops moving intraday entirely. Note the labels still sit at the right edge while the values belong to the last completed candle."
)

// ============================================================================
// RUNGS — one toggle, one lookback, one colour per horizon
//
// Colours are FIXED PER RUNG and never reassigned by active-set rank. 252 is
// gold whether it is one of seven rungs or one of two. That stability is the
// whole point: the pairs become recognisable without reading labels, which
// cannot happen if the palette shifts every time something is toggled.
//
// ALL SEVEN VWAPs SHIP ON. The fan is the point, and a cost-basis curve is
// cheap to read even at seven horizons — they are ordered, they rarely cross,
// and where they bunch is itself the information.
//
// POCs ARE OPT-IN PER RUNG, defaulting to 126 / 252 / 756 only. Seven
// horizontal levels crowd a chart in a way seven curves do not, and those three
// are the structurally distinct spans: medium-term, annual, multi-year. P189
// and P378 are one click away when a particular chart calls for them.
//
// So the two families are not symmetric, deliberately:
//   seven VWAPs = the continuous multi-horizon cost-basis fan
//   three POCs  = supplemental volume landmarks at chosen depths
// ============================================================================

groupRungs = "Rungs (VWAP + POC pairs)"

k1on = input.bool(true,  "VW", inline="k1", group=groupRungs)
k1   = input.int(21, "", minval=2, maxval=2000, inline="k1", group=groupRungs)
k1p  = input.bool(false, "POC", inline="k1", group=groupRungs)
k1c  = input.color(#26C6DA, "", inline="k1", group=groupRungs, tooltip="Per rung: VW draws the cost-basis curve, POC draws the volume level, and the colour is that rung's permanent identity. The two families also have global switches below. POCs default to 126 / 252 / 756 only — three structurally different spans — because seven horizontal levels crowd the chart in a way seven curves do not.")

k2on = input.bool(true,  "VW", inline="k2", group=groupRungs)
k2   = input.int(63, "", minval=2, maxval=2000, inline="k2", group=groupRungs)
k2p  = input.bool(false, "POC", inline="k2", group=groupRungs)
k2c  = input.color(#4FC3F7, "", inline="k2", group=groupRungs)

k3on = input.bool(true,  "VW", inline="k3", group=groupRungs)
k3   = input.int(126, "", minval=2, maxval=2000, inline="k3", group=groupRungs)
k3p  = input.bool(true,  "POC", inline="k3", group=groupRungs)
k3c  = input.color(#42A5F5, "", inline="k3", group=groupRungs)

k4on = input.bool(true,  "VW", inline="k4", group=groupRungs)
k4   = input.int(189, "", minval=2, maxval=2000, inline="k4", group=groupRungs)
k4p  = input.bool(false, "POC", inline="k4", group=groupRungs)
k4c  = input.color(#9FA8DA, "", inline="k4", group=groupRungs)

k5on = input.bool(true,  "VW", inline="k5", group=groupRungs)
k5   = input.int(252, "", minval=2, maxval=2000, inline="k5", group=groupRungs)
k5p  = input.bool(true,  "POC", inline="k5", group=groupRungs)
k5c  = input.color(#F5C542, "", inline="k5", group=groupRungs)

k6on = input.bool(true,  "VW", inline="k6", group=groupRungs)
k6   = input.int(378, "", minval=2, maxval=2000, inline="k6", group=groupRungs)
k6p  = input.bool(false, "POC", inline="k6", group=groupRungs)
k6c  = input.color(#B084F5, "", inline="k6", group=groupRungs)

k7on = input.bool(true,  "VW", inline="k7", group=groupRungs)
k7   = input.int(756, "", minval=2, maxval=2000, inline="k7", group=groupRungs)
k7p  = input.bool(true,  "POC", inline="k7", group=groupRungs)
k7c  = input.color(#7E57C2, "", inline="k7", group=groupRungs)

showVWAPs = input.bool(true, "Show VWAPs", inline="fam", group=groupRungs)
showPOCs  = input.bool(true, "Show POCs",  inline="fam", group=groupRungs, tooltip="Family switches on top of the per-rung toggles, so you can look at just the cost-basis fan or just the volume levels without touching fourteen controls. Turning POCs off is also the main performance lever: the profile passes are by far the most expensive part of this script.")

// ============================================================================
// DRAWING
// ============================================================================

groupDraw = "Drawing"

src = input.source(hlc3, "VWAP Source", group=groupDraw)

vwapWidth = input.int(2, "VWAP width", minval=1, maxval=6, inline="w", group=groupDraw, tooltip="VWAPs draw heavier than POCs so the solid/dashed distinction survives at small chart scales, where line style alone can become hard to read. Dashed rather than dotted because a width-1 dotted horizontal line reads as a row of coloured pixels once the chart is zoomed out.")
pocWidth  = input.int(1, "POC width",  minval=1, maxval=4, inline="w", group=groupDraw)

baseTransparency = input.int(
     0,
     "Transparency",
     minval=0,
     maxval=90,
     group=groupDraw,
     tooltip="Applied uniformly to every rung. There is deliberately no per-horizon fade: colour carries identity here, and fading the short horizons would make a pair harder to read as a pair. If the chart is busy, turn rungs off rather than fading them out."
)

dimFar = input.bool(
     false,
     "Dim rungs far from price",
     inline="dim",
     group=groupDraw,
     tooltip="OFF by default. Fades a rung whose VWAP sits further than the threshold from current price. This is NOT the old horizon fade — it says nothing about which horizon a line belongs to, only that the line is currently far away. The RUNG dims as a unit, driven by its VWAP's distance, so a VWAP and its POC never split into one bright line and one faint one and stop reading as a pair. Try scale.none first; it may solve enough of the crowding on its own."
)

dimFarATR = input.float(5.0, "beyond ATR", minval=1.0, maxval=30.0, step=0.5, inline="dim", group=groupDraw)

dimAmount = input.int(55, "by", minval=10, maxval=90, inline="dim", group=groupDraw)

pocDisplay = input.string(
     "Current Forward",
     "POC Display",
     options=["Current Forward", "Window + Forward"],
     group=groupDraw,
     tooltip="Current Forward (default): the level starts at the last calculated bar and extends right. Nothing is drawn back over history, because the POC was NOT at this price back then — it is recomputed every bar. Window + Forward also draws back to the window's start, which shows the span at the cost of implying a history the level does not have. The VWAP curves genuinely ARE historical paths, so without this default the two line types would make different claims with the same gesture."
)

maxPointsPerCurve = input.int(1000, "Max Points Per VWAP", minval=100, maxval=3000, group=groupDraw, tooltip="Long curves are drawn with a stride so a 756-day window does not need one polyline point per chart bar. The window's final bar is always plotted regardless of stride, since that endpoint is the number you actually read.")

showAnchorMarkers = input.bool(
     false,
     "Show Anchor Markers",
     group=groupDraw,
     tooltip="Drops a tiny label on the chart bar each VWAP originates from. Fixed-lookback anchors are chosen by POSITION, not by price, so the marker sits at the bar midpoint — putting it on the high or low would imply the extreme had something to do with the selection."
)

// ============================================================================
// POC CALCULATION
// ============================================================================

groupPOC = "POC Calculation"

pocBins = input.int(
     100,
     "Profile Bins",
     minval=10,
     maxval=400,
     group=groupPOC,
     tooltip="How finely each window's price range is divided. Bin WIDTH is that window's own range divided by this, so different rungs get different bin widths and their levels are not comparable to the same tolerance — the label tooltip prints each one's width. More bins is a more precise peak but a noisier one, because a single large bar can win a narrow bin outright. Below about 50 the POC is really just naming a third of the range."
)

pocMaxSubPct = input.float(
     20.0,
     "Suppress POC above volume substitution — %",
     minval=0.0,
     maxval=100.0,
     step=1.0,
     group=groupPOC,
     tooltip="A window whose substituted-volume rate exceeds this draws NO POC, rather than drawing one with a warning suffix like the VWAPs get. A VWAP with missing volume is still a mean, just unweighted. A profile with missing volume stops being a volume profile and becomes a bar-COUNT histogram — a different statistic wearing the POC's name. Better to show nothing. The status panel names the reason."
)

// ============================================================================
// LABELS
// ============================================================================

// ============================================================================
// STRUCTURE DASHBOARD
//
// A 0-100 read on where price sits relative to the fan, and whether the fan is
// ordered. Two 50-point components:
//
//   PRICE POSITION — how many VWAP endpoints price is above, as a fraction of
//     the drawn rungs, times 50.
//
//   STACK — the adjacent-pair ordering, short over long. Each of the N-1
//     adjacent pairs scores +1 bullish, -1 inverted, 0 inside the tolerance
//     band. Raw range -(N-1)..+(N-1), rescaled to 0-50. The dashboard shows the
//     SIGNED raw total (+5/6, 0/6, -4/6) rather than a count of bullish pairs,
//     because that signed number is literally what enters the score — five
//     bullish plus one tied and five bullish plus one inverted are different
//     fans that a bullish-pair count would render identically.
//
//     The tolerance is normalised by the ANCHOR timeframe's ATR, not the
//     chart's. Otherwise the same daily fan would classify two near-identical
//     VWAPs as tied on a 130m chart and ordered on a 39m one, purely because
//     the chart-TF ATR is smaller. Label stagger and distance dimming keep the
//     chart ATR, since those are properties of the chart you are looking at.
//
// WHEN THE SCORE IS WITHHELD: unless every enabled rung produced a VWAP and no
// two rungs share a lookback, STRUCT and BIAS print "—" and the check row
// names the reason. Normalising to whatever horizons happened to exist would
// let a two-horizon symbol print STRUCT 100 / STRONG BULL, indistinguishable at
// a glance from a seven-horizon reading. The P>VW and STACK rows still show
// their counts, greyed, because those remain factual over what was drawn.
//
// WHAT THE SCORE IS NOT: two independent dimensions. Price above every VWAP and
// a perfectly stacked fan are strongly co-occurring — in a sustained one-way
// move both components max out together, and in chop both sit near their
// middles. Treat 0-100 as ONE structural reading measured two ways, not as a
// composite of separate evidence. The practical consequence is that the extremes
// are easier to reach than a two-component construction suggests, and readings
// genuinely near 50 are less common than the band widths imply.
//
// Stack ordering is also partly mechanical rather than empirical. These windows
// are nested — VW21's bars are a subset of VW63's, which are a subset of
// VW126's — so in any monotonic trend the ordering FOLLOWS from the trend
// rather than confirming it independently. It earns its keep at turns, where
// the short end inverts before the long end and the raw stack falls while price
// position is still high.
//
// There is no arrow on STRUCT. An earlier version put ▲ next to a bullish score
// and ▼ next to a bearish one, which reads as "the score is rising" when it
// meant "the score is high" — 82 down from 95 would have shown ▲. Orientation
// is already carried by the bias word and the colour. If a genuine change
// indicator is ever wanted it should compare against the previous bar's score,
// and only then does an arrow belong there.
//
// The score is a STEP function, not continuous. With seven rungs, price position
// moves in jumps of 7.14 and stack in jumps of 4.17, so the reading can cross
// the whole neutral band between two bars without ever printing a value inside
// it. Do not read small changes as drift.
//
// POC is deliberately excluded from the score. A volume concentration is not
// bullish or bearish — it is a location. It gets an informational row instead.
// ============================================================================

groupDash = "Structure Dashboard"

showDash = input.bool(true, "Show Structure Dashboard", group=groupDash)

dashPos = input.string(
     "Top Right",
     "Position",
     options=["Top Right","Top Left","Top Center","Middle Right","Middle Left","Bottom Right","Bottom Left","Bottom Center"],
     group=groupDash,
     tooltip="TradingView stacks tables sharing an anchor ACROSS indicators. If you run the MTF Regime dashboards, their anchors are already taken — give this one its own."
)

dashSize = input.string("Small", "Text size", options=["Tiny","Small","Normal"], group=groupDash)

stackTolATR = input.float(
     0.04,
     "Stack equality tolerance — ATR",
     minval=0.0,
     maxval=1.0,
     step=0.01,
     group=groupDash,
     tooltip="Two adjacent VWAPs closer together than this count as tied rather than ordered, contributing 0 to the stack instead of ±1. Literal equality would almost never fire, so without a tolerance a fan whose curves are effectively on top of each other would still report a confident ordering decided by rounding noise. Raise it if the stack reading flickers in compressed markets."
)

showPocRow = input.bool(
     true,
     "Show POC context row",
     group=groupDash,
     tooltip="Reports how many drawn POCs price is above, phrased as P>POC to match P>VW. Informational only — it does NOT enter the score. A volume concentration is a location, not a direction."
)

groupLabels = "Labels"

showLabels = input.bool(true, "Show Labels", group=groupLabels)

labelDetail = input.string(
     "Compact",
     "Label Detail",
     options=["Compact", "Full"],
     group=groupLabels,
     tooltip="Compact: VW252 / P252. Full: prefixes the anchor timeframe, D-VW252 — useful when you run two instances on different anchor timeframes and need to tell their labels apart."
)

labelGapATR = input.float(
     0.60,
     "Label Stagger Distance — ATR",
     minval=0.0,
     maxval=5.0,
     step=0.05,
     group=groupLabels,
     tooltip="Labels closer together than this vertically get pushed further right. VWAP and POC labels go through ONE combined price ordering, not two separate passes — two passes would each be internally tidy and still collide with each other. With seven rungs this is what keeps fourteen labels readable."
)

atrLength = input.int(14, "ATR Length", minval=2, maxval=100, group=groupLabels, tooltip="One length, applied on two timeframes for two different jobs. On the CHART timeframe it normalises label stagger and distance dimming, which are visual and belong to the chart you are looking at. On the ANCHOR timeframe it normalises the dashboard's stack equality tolerance, which belongs to the horizon being measured — otherwise the same daily fan would classify two near-identical VWAPs differently on a 39m chart than on a 130m one, purely because the chart-TF ATR is smaller.")

// ============================================================================
// STORAGE / STATUS
// ============================================================================

groupStorage = "Storage / Display"

historyBars = input.int(
     10000,
     "Stored Chart Bars",
     minval=500,
     maxval=20000,
     group=groupStorage,
     tooltip="An anchor must fall inside stored history or its rung is DROPPED, not approximated. Clamping to the oldest stored bar would draw something that looks like a VWAP, labels itself as one, and starts from the wrong origin. Budget: longest rung x anchor-TF bars converted to chart bars. 756 daily bars on a 39m RTH chart is roughly 7500, which is why the default is 10000 rather than 5000 — the old default could silently drop VW756, a rung that ships enabled."
)

updateMode = input.string(
     "Live (every tick)",
     "Update Mode",
     options=["Live (every tick)", "On Bar Close"],
     group=groupStorage,
     tooltip="Live: rebuilt on every realtime tick. This is not wasteful — Pine rolls back an uncommitted tick's execution and DESTROYS any drawing objects it created, so on the forming bar a redraw every tick is the only way curves stay on screen. On Bar Close: draw only on committed executions, which survive. Use it if the profile passes trip the calculation time limit. Note Confirmed Bars Only already freezes the VALUES intraday; this setting only governs redraw frequency."
)

showStatus = input.bool(false, "Show Diagnostics Panel", group=groupStorage, tooltip="The full accounting: rungs enabled, VWAPs drawn, POCs drawn, and the reasons for any gap. OFF by default — when everything is healthy this panel says nothing but 'nothing is wrong', and the structure dashboard is the one worth chart space. Anything that IS wrong still surfaces as a line on the dashboard without this on.")

statusPos = input.string(
     "Bottom Left",
     "Status Position",
     options=["Bottom Left","Top Left","Top Center","Bottom Center","Top Right","Bottom Right","Middle Right","Middle Left"],
     group=groupStorage,
     tooltip="TradingView stacks tables that share an anchor ACROSS indicators, not just within one. If you run the MTF Regime dashboards or the Rolling Extreme AVWAP Fan, their anchors are already taken."
)

statusSize = input.string("Tiny", "Status Text size", options=["Tiny","Small","Normal"], group=groupStorage)

volWarnPct = input.float(
     5.0,
     "VWAP Volume Substitution Warning — %",
     minval=0.0,
     maxval=100.0,
     step=0.5,
     group=groupStorage,
     tooltip="Measured PER RUNG over that rung's own window — a data gap from three years ago no longer flags a 126-bar curve. VWAPs above this rate are suffixed with * and counted in a warning label. POC uses its own, higher threshold and suppresses instead of flagging."
)

// ============================================================================
// TIMEFRAME TAG
// ============================================================================

f_tfTag(simple string tf) =>
    string t = tf == "" ? timeframe.period : tf
    string res = t

    if str.contains(t, "S")
        res := t
    else if str.contains(t, "D") or str.contains(t, "W") or str.contains(t, "M")
        res := (str.startswith(t, "1") and str.length(t) == 2) ? str.substring(t, 1) : t
    else
        res := t + "m"

    res

string anchorTag = f_tfTag(anchorTF)

float chartSeconds = timeframe.in_seconds()
float anchorSeconds = timeframe.in_seconds(anchorTF)

bool tfValid = anchorSeconds >= chartSeconds

// ============================================================================
// VWAP ENGINE
//
// MISSING VOLUME:
//   Missing EVERYWHERE (synthetic symbol, index with no volume feed): every bar
//     weighs 1.0, so the curve is a genuine UNWEIGHTED mean of the source.
//     Usable, as long as you know that is what you are looking at.
//   Missing OCCASIONALLY (a few bad bars in a real feed): a bar weighing 1.0
//     against neighbours weighing millions is not being averaged in — it is
//     being DROPPED. Still a proper volume-weighted mean, over a slightly
//     smaller sample.
// The rate is tracked cumulatively so each rung reports the rate inside its own
// window, the only scope where the number means anything.
// ============================================================================

bool volMissingBar = na(volume) or volume <= 0

float barVolume = volMissingBar ? 1.0 : volume

float pv = src * barVolume

float cumPV = ta.cum(pv)
float cumVol = ta.cum(barVolume)
float cumVolSub = ta.cum(volMissingBar ? 1.0 : 0.0)

float basePVThisBar = nz(cumPV[1], 0.0)
float baseVolThisBar = nz(cumVol[1], 0.0)
float baseSubThisBar = nz(cumVolSub[1], 0.0)

float chartATR = ta.atr(atrLength)

// ============================================================================
// BAR STORAGE
//
// barVols   — each bar's own volume. A histogram cannot be recovered from
//             cumulative differences the way a mean can.
// barCumSub — cumulative substitution count AT each bar, not just before it,
//             because a window can END before the last stored bar when
//             confirmed-only is on.
// ============================================================================

var array<int> barTimes = array.new_int()
var array<float> barHighs = array.new_float()
var array<float> barLows = array.new_float()
var array<float> barCloses = array.new_float()
var array<float> barVols = array.new_float()
var array<float> barCumPV = array.new_float()
var array<float> barCumVol = array.new_float()
var array<float> barCumSub = array.new_float()
var array<float> barBasePV = array.new_float()
var array<float> barBaseVol = array.new_float()
var array<float> barBaseSub = array.new_float()

array.push(barTimes, time)
array.push(barHighs, high)
array.push(barLows, low)
array.push(barCloses, close)
array.push(barVols, barVolume)
array.push(barCumPV, cumPV)
array.push(barCumVol, cumVol)
array.push(barCumSub, cumVolSub)
array.push(barBasePV, basePVThisBar)
array.push(barBaseVol, baseVolThisBar)
array.push(barBaseSub, baseSubThisBar)

if array.size(barTimes) > historyBars
    array.shift(barTimes)
    array.shift(barHighs)
    array.shift(barLows)
    array.shift(barCloses)
    array.shift(barVols)
    array.shift(barCumPV)
    array.shift(barCumVol)
    array.shift(barCumSub)
    array.shift(barBasePV)
    array.shift(barBaseVol)
    array.shift(barBaseSub)

// ============================================================================
// ANCHORS
//
// NOTE ON lookahead — OFF IS CORRECT. The timestamp of the bar 252 back is
// knowable the instant the current bar prints; there is no confirmation lag to
// undo. lookahead_on would deliver a completed anchor-TF bar's data before that
// bar finished forming, which is a real future leak.
//
// nowOpen is the OPEN timestamp of the anchor-TF candle currently forming. It
// is what makes the confirmed-only end cut possible chart-side: every stored
// chart bar at or after it belongs to the incomplete candle and is excluded.
// ============================================================================

f_rollAnchor(simple int len, simple int shift) =>
    simple int off = shift + len - 1
    bar_index >= off ? time[off] : na

type AnchorBundle
    int a1
    int a2
    int a3
    int a4
    int a5
    int a6
    int a7
    int nowOpen
    float atr

simple int sk1 = math.max(2, k1)
simple int sk2 = math.max(2, k2)
simple int sk3 = math.max(2, k3)
simple int sk4 = math.max(2, k4)
simple int sk5 = math.max(2, k5)
simple int sk6 = math.max(2, k6)
simple int sk7 = math.max(2, k7)

simple int shiftBars = confirmedOnly ? 1 : 0

// Disabled rungs still occupy a slot — the length argument must be a simple
// int, so it cannot be conditionally skipped inside the security context.
// Discarded chart-side by the on/off flags.
f_allAnchors() =>
    // Shifted by the SAME shiftBars the anchors use, not by a separate
    // confirmedOnly test. The stack tolerance is derived from this ATR, so
    // leaving it live meant confirmed-only froze the VWAP values while today's
    // evolving anchor candle could still widen or narrow the tie band and flip
    // a pair in rawStack intraday. Tying it to shiftBars also means the two
    // cannot drift apart if that mechanism ever changes.
    float aAtr = ta.atr(atrLength)

    AnchorBundle.new(
         a1=f_rollAnchor(sk1, shiftBars),
         a2=f_rollAnchor(sk2, shiftBars),
         a3=f_rollAnchor(sk3, shiftBars),
         a4=f_rollAnchor(sk4, shiftBars),
         a5=f_rollAnchor(sk5, shiftBars),
         a6=f_rollAnchor(sk6, shiftBars),
         a7=f_rollAnchor(sk7, shiftBars),
         nowOpen=time,
         atr=aAtr[shiftBars])

AnchorBundle ab = request.security(syminfo.tickerid, anchorTF, f_allAnchors(), lookahead=barmerge.lookahead_off)

if na(ab)
    ab := AnchorBundle.new()

// ============================================================================
// CHART-BAR RESOLUTION
//
// barTimes is sorted ascending, so any timestamp's position is found by binary
// search rather than by walking back from the right edge.
//
// The profile pass is different: it genuinely needs every bar in the window, so
// its O(bars) cost is a floor rather than an inefficiency. What the difference
// array removes is the second dimension, the per-bin inner loop.
// ============================================================================

f_lowerBound(array<int> times, int t) =>
    int lo = 0
    int hi = array.size(times)

    while lo < hi
        int mid = int(math.floor((lo + hi) / 2))

        if array.get(times, mid) < t
            lo := mid + 1
        else
            hi := mid

    lo

// The FIRST chart bar at or after the window's opening timestamp. If that lands
// at index 0 while stored history begins AFTER the requested open, the window
// predates storage and the rung is dropped rather than clamped.
f_findOpenIndex(array<int> times, int periodStart) =>
    int n = array.size(times)
    int idx = f_lowerBound(times, periodStart)

    int result = idx >= n ? -1 : idx

    if result == 0 and n > 0 and array.get(times, 0) > periodStart
        result := -1

    result

// ============================================================================
// PROFILE / POC
//
// Proportional overlap allocation with a difference array for bar interiors.
//
// Status codes, so a missing level can say why rather than just being absent:
//   0  drawn
//   1  unusable window (bad indices)
//   2  volume substitution above threshold
//   3  zero price range across the window
//
// Returns na for the price on anything but status 0. There is no fallback
// level — every fallback available would be a made-up number wearing the POC's
// label.
// ============================================================================

f_windowPOC(int anchorIdx, int endIdx, int bins, float maxSubPct) =>
    float result = na
    int status = 1
    float binWidthOut = na
    int binsUsed = na

    int n = array.size(barTimes)

    if anchorIdx >= 0 and endIdx >= anchorIdx and endIdx < n and bins >= 2
        int barsInWindow = endIdx - anchorIdx + 1
        float subs = array.get(barCumSub, endIdx) - array.get(barBaseSub, anchorIdx)
        float subPct = barsInWindow > 0 ? subs * 100.0 / barsInWindow : 100.0

        if subPct > maxSubPct
            status := 2
        else
            float lo = na
            float hi = na

            // Pass 1 — the window's range. Bin edges cannot be known before
            // this, so it cannot be folded into the binning pass.
            for i = anchorIdx to endIdx
                float bl = array.get(barLows, i)
                float bh = array.get(barHighs, i)

                if na(lo) or bl < lo
                    lo := bl
                if na(hi) or bh > hi
                    hi := bh

            if na(lo) or na(hi) or hi <= lo
                status := 3
            else
                // The requested bin count is a MAXIMUM resolution, not
                // permission to invent sub-tick precision. If a window's whole
                // range spans 40 ticks, 100 bins would put several bins inside
                // one tick and the argmax would be choosing between prices that
                // cannot trade. Resolution is capped at one bin per tick.
                // Floor of one bin, not two. Forcing a minimum of two bins on a
                // window that spans a single tick re-creates the sub-tick bins
                // this cap exists to prevent — the argmax would be choosing
                // between two halves of one tick.
                int tickBins = math.max(1, int(math.floor((hi - lo) / syminfo.mintick)))
                int effBins = math.max(1, math.min(bins, tickBins))

                float binWidth = (hi - lo) / effBins
                binWidthOut := binWidth
                binsUsed := effBins

                // direct — edge-bin and single-bin contributions, exact.
                // diff   — difference array for fully covered interiors: one
                //          increment and one decrement per bar instead of a
                //          loop over every covered bin.
                array<float> direct = array.new_float(effBins, 0.0)
                array<float> diff = array.new_float(effBins + 1, 0.0)

                // Pass 2 — allocate each bar's volume across the bins its range
                // overlaps, in proportion to the overlapped fraction.
                for i = anchorIdx to endIdx
                    float bl = array.get(barLows, i)
                    float bh = array.get(barHighs, i)
                    float bv = array.get(barVols, i)
                    float rng = bh - bl

                    if rng <= 0
                        // Zero-range bar: all volume traded at one price.
                        int b = math.max(0, math.min(effBins - 1, int(math.floor((bl - lo) / binWidth))))
                        array.set(direct, b, array.get(direct, b) + bv)
                    else
                        int b0 = math.max(0, math.min(effBins - 1, int(math.floor((bl - lo) / binWidth))))
                        int b1 = math.max(0, math.min(effBins - 1, int(math.floor((bh - lo) / binWidth))))

                        if b0 == b1
                            array.set(direct, b0, array.get(direct, b0) + bv)
                        else
                            float b0Top = lo + (b0 + 1) * binWidth
                            array.set(direct, b0, array.get(direct, b0) + bv * (b0Top - bl) / rng)

                            float b1Bot = lo + b1 * binWidth
                            array.set(direct, b1, array.get(direct, b1) + bv * (bh - b1Bot) / rng)

                            if b1 - b0 > 1
                                float d = bv * binWidth / rng
                                array.set(diff, b0 + 1, array.get(diff, b0 + 1) + d)
                                array.set(diff, b1, array.get(diff, b1) - d)

                // Pass 3 — resolve the difference array and take the argmax in
                // the same sweep. O(bins), independent of window length.
                int bestBin = -1
                float bestVol = na
                float running = 0.0

                for b = 0 to effBins - 1
                    running += array.get(diff, b)
                    float total = array.get(direct, b) + running

                    if bestBin == -1 or total > bestVol
                        bestBin := b
                        bestVol := total

                if bestBin >= 0
                    // Centre of the winning bin, snapped to the instrument's
                    // tick grid. Unrounded, a one-tick bin from 10.00 to 10.01
                    // reports 10.005 — a price that cannot trade.
                    //
                    // The rounding fixes tradability, NOT precision, and the two
                    // are easy to confuse. On a wide window the bin can be
                    // hundreds of dollars across, so a level printed to the cent
                    // is still only accurate to half a bin. The label tooltip
                    // states the bin width for exactly this reason — read the
                    // level as the centre of that band, not as a price.
                    result := math.round_to_mintick(lo + (bestBin + 0.5) * binWidth)
                    status := 0
                else
                    status := 3

    [result, status, binWidthOut, binsUsed]

// ============================================================================
// PER-RUNG STORAGE
// ============================================================================

var array<float> vwValues = array.new_float()
var array<int> vwLookbacks = array.new_int()
var array<int> vwAnchorIdx = array.new_int()
var array<color> vwColors = array.new<color>()
var array<float> vwBasePV = array.new_float()
var array<float> vwBaseVol = array.new_float()
var array<float> vwVolPct = array.new_float()
var array<int> vwLabelOffsets = array.new_int()

var array<float> pcValues = array.new_float()
var array<int> pcLookbacks = array.new_int()
var array<int> pcAnchorIdx = array.new_int()
var array<color> pcColors = array.new<color>()
var array<float> pcBinWidths = array.new_float()
var array<int> pcBinsUsed = array.new_int()
var array<int> pcLabelOffsets = array.new_int()

f_vwName(int lookback, bool degraded) =>
    string body = labelDetail == "Compact" ? "VW" + str.tostring(lookback) : anchorTag + "-VW" + str.tostring(lookback)
    body + (degraded ? "*" : "")

f_pocName(int lookback) =>
    labelDetail == "Compact" ? "P" + str.tostring(lookback) : anchorTag + "-P" + str.tostring(lookback)

// Substitution rate inside ONE window, bounded at both ends so it stays correct
// when confirmed-only cuts the window short of the last stored bar.
f_windowVolPct(int idx, int endIdx) =>
    int barsInWindow = endIdx - idx + 1
    float subs = array.get(barCumSub, endIdx) - array.get(barBaseSub, idx)
    barsInWindow > 0 ? subs * 100.0 / barsInWindow : 0.0

// ============================================================================
// DRAW STORAGE
// ============================================================================

var array<polyline> drawnPolylines = array.new<polyline>()
var array<label> drawnLabels = array.new<label>()
var array<line> drawnLines = array.new<line>()

// ============================================================================
// STATUS TABLE
// ============================================================================

f_statPos(string s) => switch s
    "Top Right"=>position.top_right
    "Top Left"=>position.top_left
    "Top Center"=>position.top_center
    "Bottom Right"=>position.bottom_right
    "Bottom Left"=>position.bottom_left
    "Bottom Center"=>position.bottom_center
    "Middle Right"=>position.middle_right
    "Middle Left"=>position.middle_left
    =>position.bottom_left

f_statSize(string s) => switch s
    "Tiny"=>size.tiny
    "Small"=>size.small
    "Normal"=>size.normal
    =>size.tiny

// Bias bands, not regime bands. This measures VWAP structural bias and nothing
// else — no volatility, no participation, no trend strength. Calling it a
// regime would overclaim, and it would also collide with the MTF Regime
// dashboards, which use a different vocabulary (ALIGN / BUILD / FADE / COIL)
// for a genuinely broader question. Two indicators on one chart should not both
// print a word called REGIME meaning different things.
//
// Deliberately asymmetric around the middle: the neutral band is
// 45-54 while the outer bands are wider, because the score's step size means it
// rarely lands in a narrow window and a wide "neutral" would swallow readings
// that are genuinely leaning.
f_biasWord(float sc) =>
    na(sc) ? "—" : sc >= 85 ? "STRONG BULL" : sc >= 70 ? "BULL" : sc >= 55 ? "BULL LEAN" : sc >= 45 ? "NEUTRAL" : sc >= 31 ? "BEAR LEAN" : sc >= 16 ? "BEAR" : "STRONG BEAR"

// Green/red/gold here mean DIRECTIONAL BIAS. That is a different meaning
// from the plotted curves, where colour means horizon identity and green/red
// were kept out of the palette precisely so they could carry this instead.
f_biasCol(float sc) =>
    na(sc) ? color.new(color.gray, 45) : sc >= 85 ? #2DD4A7 : sc >= 70 ? #7FD1AE : sc >= 55 ? #66BB6A : sc >= 45 ? #9AA0A6 : sc >= 31 ? #E5989B : sc >= 16 ? #E06C75 : #FF6B6B

f_dashPos(string s) => switch s
    "Top Right"=>position.top_right
    "Top Left"=>position.top_left
    "Top Center"=>position.top_center
    "Middle Right"=>position.middle_right
    "Middle Left"=>position.middle_left
    "Bottom Right"=>position.bottom_right
    "Bottom Left"=>position.bottom_left
    "Bottom Center"=>position.bottom_center
    =>position.top_right

var table dashTbl = na
var int dashLastRows = -1

if not showDash and not na(dashTbl)
    table.delete(dashTbl)
    dashTbl := na
    dashLastRows := -1

var table statTbl = na

// Without this the panel stays stranded on the chart after the toggle is
// switched off, because a table object persists until deleted.
if not showStatus and not na(statTbl)
    table.delete(statTbl)
    statTbl := na

// ============================================================================
// REDRAW GATE
//
// There is no "have I already drawn this bar" counter, and there cannot
// usefully be one. A `var` counter is rolled back every realtime tick, so the
// guard never holds inside the forming bar. A `varip` counter survives the
// rollback but the drawings it guards do NOT — Pine destroys the polylines and
// labels an uncommitted tick created — so from the second tick onward the gate
// reports "already drawn" and skips the redraw that was just undone, and the
// chart goes blank. Drawing objects and bar-state counters have different
// lifetimes; any gate mixing them desynchronises.
// ============================================================================

bool shouldRedraw = updateMode == "On Bar Close" ? (barstate.islastconfirmedhistory or (barstate.islast and barstate.isconfirmed)) : barstate.islast

// ============================================================================
// MAIN
// ============================================================================

if shouldRedraw

    if array.size(drawnPolylines) > 0
        for i = 0 to array.size(drawnPolylines) - 1
            polyline.delete(array.get(drawnPolylines, i))
        array.clear(drawnPolylines)

    if array.size(drawnLabels) > 0
        for i = 0 to array.size(drawnLabels) - 1
            label.delete(array.get(drawnLabels, i))
        array.clear(drawnLabels)

    if array.size(drawnLines) > 0
        for i = 0 to array.size(drawnLines) - 1
            line.delete(array.get(drawnLines, i))
        array.clear(drawnLines)

    array.clear(vwValues)
    array.clear(vwLookbacks)
    array.clear(vwAnchorIdx)
    array.clear(vwColors)
    array.clear(vwBasePV)
    array.clear(vwBaseVol)
    array.clear(vwVolPct)
    array.clear(vwLabelOffsets)
    array.clear(pcValues)
    array.clear(pcLookbacks)
    array.clear(pcAnchorIdx)
    array.clear(pcColors)
    array.clear(pcBinWidths)
    array.clear(pcBinsUsed)
    array.clear(pcLabelOffsets)

    array<bool> rOn = array.from(k1on, k2on, k3on, k4on, k5on, k6on, k7on)
    array<int> rLB = array.from(k1, k2, k3, k4, k5, k6, k7)
    array<color> rCol = array.from(k1c, k2c, k3c, k4c, k5c, k6c, k7c)
    array<bool> rPoc = array.from(k1p, k2p, k3p, k4p, k5p, k6p, k7p)
    array<int> rAnchor = array.from(ab.a1, ab.a2, ab.a3, ab.a4, ab.a5, ab.a6, ab.a7)

    // ------------------------------------------------------------------------
    // WINDOW END — the confirmed-only cut, applied once for everything
    //
    // Off: the last stored bar. On: the last stored bar strictly before the
    // forming anchor-TF candle opened. If that lands below zero (no completed
    // candle in stored history) nothing is drawable, and the pass produces empty
    // buckets and a warning rather than half-valid curves.
    // ------------------------------------------------------------------------

    int lastStored = array.size(barTimes) - 1
    int windowEnd = lastStored

    if confirmedOnly and not na(ab.nowOpen)
        windowEnd := f_lowerBound(barTimes, ab.nowOpen) - 1

    bool windowUsable = windowEnd >= 0 and windowEnd <= lastStored

    // ------------------------------------------------------------------------
    // COLLECT — one pass, both objects per rung
    //
    // The VWAP value is read at windowEnd rather than from the live cumulative
    // totals. That is what makes confirmed-only actually freeze the fan.
    // ------------------------------------------------------------------------

    int rungsOn = 0
    int noHistoryCount = 0
    int droppedCount = 0
    int dupCount = 0

    int pocRequested = 0
    int pocSuppressVol = 0
    int pocSuppressRange = 0
    int pocSuppressWindow = 0

    // Enabled rungs and duplicates are counted BEFORE the validity gate.
    // Counting them inside it meant an invalid anchor timeframe printed
    // "rungs 0" with seven rungs enabled — which reads as a configuration
    // mistake rather than the timeframe problem it actually is.
    //
    // Duplicate lookbacks are counted, never merged. Two rungs set to the same
    // number draw two identical curves in two different colours, which looks
    // like two horizons agreeing and is really one horizon entered twice.
    for k = 0 to 6
        if array.get(rOn, k)
            rungsOn += 1

            for j = 0 to 6
                if j < k and array.get(rOn, j) and array.get(rLB, j) == array.get(rLB, k)
                    dupCount += 1

    if tfValid and windowUsable
        for k = 0 to 6
            if array.get(rOn, k)
                int lookback = array.get(rLB, k)
                int aStart = array.get(rAnchor, k)

                if na(aStart)
                    noHistoryCount += 1
                else
                    int aIdx = f_findOpenIndex(barTimes, aStart)

                    if aIdx < 0 or aIdx > windowEnd
                        droppedCount += 1
                    else
                        float pBasePV = array.get(barBasePV, aIdx)
                        float pBaseVol = array.get(barBaseVol, aIdx)
                        float endPV = array.get(barCumPV, windowEnd)
                        float endVol = array.get(barCumVol, windowEnd)
                        float denominator = endVol - pBaseVol
                        float vwapNow = denominator > 0 ? (endPV - pBasePV) / denominator : na

                        if na(vwapNow)
                            droppedCount += 1
                        else
                            // Distance dimming (off by default). Driven by the
                            // VWAP's distance so the whole rung dims together.
                            //
                            // The reference price is the WINDOW-END close when
                            // confirmed-only is on, not the live close. Otherwise
                            // the levels would sit frozen while their brightness
                            // changed intraday — the switch would half-apply.
                            //
                            // ATR is still the live chart-TF value. Fixing that
                            // too would mean storing a second per-bar array for a
                            // cosmetic feature that ships off, and the threshold
                            // is coarse enough (5 ATR) that intrabar ATR drift
                            // cannot move a rung across it.
                            float dimRefPrice = confirmedOnly ? array.get(barCloses, windowEnd) : close
                            float distATR = na(chartATR) or chartATR <= 0 ? 0.0 : math.abs(vwapNow - dimRefPrice) / chartATR
                            int dimExtra = dimFar and distATR > dimFarATR ? dimAmount : 0
                            color rungColor = color.new(array.get(rCol, k), math.min(95, baseTransparency + dimExtra))

                            array.push(vwValues, vwapNow)
                            array.push(vwLookbacks, lookback)
                            array.push(vwAnchorIdx, aIdx)
                            array.push(vwColors, rungColor)
                            array.push(vwBasePV, pBasePV)
                            array.push(vwBaseVol, pBaseVol)
                            array.push(vwVolPct, f_windowVolPct(aIdx, windowEnd))
                            array.push(vwLabelOffsets, 2)

                            // A POC is now opt-in per rung rather than a
                            // mandatory partner. Seven curves read fine; seven
                            // horizontal levels do not, and the POCs worth
                            // having are the structurally distinct spans.
                            if showPOCs and array.get(rPoc, k)
                                pocRequested += 1

                                [pocPrice, pocStatus, pocBW, pocBinsUsed] = f_windowPOC(aIdx, windowEnd, pocBins, pocMaxSubPct)

                                if pocStatus == 0 and not na(pocPrice)
                                    array.push(pcValues, pocPrice)
                                    array.push(pcLookbacks, lookback)
                                    array.push(pcAnchorIdx, aIdx)
                                    array.push(pcColors, rungColor)
                                    array.push(pcBinWidths, pocBW)
                                    array.push(pcBinsUsed, pocBinsUsed)
                                    array.push(pcLabelOffsets, 2)
                                else
                                    pocSuppressVol += pocStatus == 2 ? 1 : 0
                                    pocSuppressRange += pocStatus == 3 ? 1 : 0
                                    pocSuppressWindow += pocStatus == 1 ? 1 : 0

    int vwCount = array.size(vwValues)
    int pcCount = array.size(pcValues)

    // ========================================================================
    // COMBINED LABEL STAGGER — VWAPs and POCs in ONE price ordering
    //
    // Two separate passes would each be internally tidy and still collide with
    // each other, which is the whole failure mode. kind 0 = VWAP, 1 = POC.
    // Only families that are actually being drawn take part.
    // ========================================================================

    array<float> lblPrices = array.new_float()
    array<int> lblKind = array.new_int()
    array<int> lblRef = array.new_int()

    if showVWAPs and vwCount > 0
        for i = 0 to vwCount - 1
            array.push(lblPrices, array.get(vwValues, i))
            array.push(lblKind, 0)
            array.push(lblRef, i)

    if showPOCs and pcCount > 0
        for i = 0 to pcCount - 1
            array.push(lblPrices, array.get(pcValues, i))
            array.push(lblKind, 1)
            array.push(lblRef, i)

    int lblCount = array.size(lblPrices)

    if lblCount > 1
        for a = 0 to lblCount - 2
            for b = 0 to lblCount - 2 - a
                if array.get(lblPrices, b) > array.get(lblPrices, b + 1)
                    float tmpP = array.get(lblPrices, b)
                    int tmpK = array.get(lblKind, b)
                    int tmpR = array.get(lblRef, b)

                    array.set(lblPrices, b, array.get(lblPrices, b + 1))
                    array.set(lblKind, b, array.get(lblKind, b + 1))
                    array.set(lblRef, b, array.get(lblRef, b + 1))

                    array.set(lblPrices, b + 1, tmpP)
                    array.set(lblKind, b + 1, tmpK)
                    array.set(lblRef, b + 1, tmpR)

    // No maximum. An earlier version wrapped back to the first column past 44
    // bars, which put a far-right label on top of the one it had been pushed
    // away from — the exact collision the stagger exists to prevent, just
    // deferred. With seven VWAPs and three POCs the worst realistic cluster is
    // ten labels, i.e. column 65, which is well inside normal right-margin
    // space.
    int lblBase = 2
    int lblStep = 7

    float lblGap = chartATR * labelGapATR

    int curOffset = lblBase
    float lastLabelPrice = na

    if lblCount > 0
        for q = 0 to lblCount - 1
            float v = array.get(lblPrices, q)

            if not na(lastLabelPrice) and labelGapATR > 0 and not na(lblGap) and (v - lastLabelPrice) < lblGap
                curOffset += lblStep
            else
                curOffset := lblBase

            if array.get(lblKind, q) == 0
                array.set(vwLabelOffsets, array.get(lblRef, q), curOffset)
            else
                array.set(pcLabelOffsets, array.get(lblRef, q), curOffset)

            lastLabelPrice := v

    // ========================================================================
    // DRAW VWAPS
    // ========================================================================

    int vwDrawn = 0
    int volFlagged = 0
    float worstVolPct = 0.0

    if showVWAPs and vwCount > 0 and windowUsable
        for i = 0 to vwCount - 1
            int anchorIndex = array.get(vwAnchorIdx, i)
            int lookback = array.get(vwLookbacks, i)
            color rungColor = array.get(vwColors, i)
            float pBasePV = array.get(vwBasePV, i)
            float pBaseVol = array.get(vwBaseVol, i)
            float vwapNow = array.get(vwValues, i)
            float wVolPct = array.get(vwVolPct, i)
            int labelOffset = array.get(vwLabelOffsets, i)

            bool degraded = wVolPct > volWarnPct

            if anchorIndex >= 0 and windowEnd > anchorIndex
                int barsInCurve = windowEnd - anchorIndex + 1
                int stride = math.max(1, int(math.ceil(barsInCurve * 1.0 / maxPointsPerCurve)))
                array<chart.point> points = array.new<chart.point>()

                int j = anchorIndex
                int lastAdded = -1

                while j <= windowEnd
                    float pointPV = array.get(barCumPV, j)
                    float pointVol = array.get(barCumVol, j)
                    float denominator = pointVol - pBaseVol
                    float avwap = denominator > 0 ? (pointPV - pBasePV) / denominator : na

                    if not na(avwap)
                        array.push(points, chart.point.from_time(array.get(barTimes, j), avwap))
                        lastAdded := j

                    j += stride

                // The stride can step past the window's final bar; the endpoint
                // is the number you actually read, so it is always added.
                if lastAdded != windowEnd
                    float finalPV = array.get(barCumPV, windowEnd)
                    float finalVol = array.get(barCumVol, windowEnd)
                    float finalDenominator = finalVol - pBaseVol
                    float finalVWAP = finalDenominator > 0 ? (finalPV - pBasePV) / finalDenominator : na

                    if not na(finalVWAP)
                        array.push(points, chart.point.from_time(array.get(barTimes, windowEnd), finalVWAP))

                if array.size(points) >= 2
                    polyline newPoly = polyline.new(
                         points,
                         curved=false,
                         xloc=xloc.bar_time,
                         line_color=rungColor,
                         line_style=line.style_solid,
                         line_width=vwapWidth
                    )
                    array.push(drawnPolylines, newPoly)
                    vwDrawn += 1

                if showLabels
                    string volNote = degraded ? "\nvolume substituted on " + str.tostring(wVolPct, "#.0") + "% of this window" : ""

                    label newLabel = label.new(
                         bar_index + labelOffset,
                         vwapNow,
                         f_vwName(lookback, degraded),
                         xloc=xloc.bar_index,
                         style=label.style_label_left,
                         color=color.new(rungColor, 80),
                         textcolor=rungColor,
                         size=size.tiny,
                         tooltip="VWAP over the last " + str.tostring(lookback) + " " + anchorTag + " bars\nendpoint is the window's VWAP; the tail is the path from that fixed origin" + volNote
                    )
                    array.push(drawnLabels, newLabel)

                if degraded
                    volFlagged += 1

                worstVolPct := math.max(worstVolPct, wVolPct)

    // ========================================================================
    // DRAW POC LEVELS
    //
    // Current Forward (default) starts at the window's END bar and extends
    // right. Window + Forward reinstates the backward segment for span, which
    // is decoration rather than a record. A VWAP tail is a continuous
    // accumulation from a fixed origin and has a value at every bar; a POC is a
    // single number with no value anywhere but now. The two look identical if
    // you are not thinking about it.
    // ========================================================================

    int pcDrawn = 0

    if showPOCs and pcCount > 0 and windowUsable
        int endTimeP = array.get(barTimes, windowEnd)
        int oneBarMs = int(chartSeconds * 1000)

        for i = 0 to pcCount - 1
            float pocPrice = array.get(pcValues, i)
            int lookback = array.get(pcLookbacks, i)
            int aIdx = array.get(pcAnchorIdx, i)
            color rungColor = array.get(pcColors, i)
            float bw = array.get(pcBinWidths, i)
            int bu = array.get(pcBinsUsed, i)
            int offP = array.get(pcLabelOffsets, i)

            int x1 = pocDisplay == "Window + Forward" ? array.get(barTimes, aIdx) : endTimeP
            int x2 = endTimeP + oneBarMs

            line pocLine = line.new(
                 x1,
                 pocPrice,
                 x2,
                 pocPrice,
                 xloc=xloc.bar_time,
                 extend=extend.right,
                 color=rungColor,
                 style=line.style_dashed,
                 width=pocWidth
            )
            array.push(drawnLines, pocLine)

            if showLabels
                label pocLabel = label.new(
                     bar_index + offP,
                     pocPrice,
                     f_pocName(lookback),
                     xloc=xloc.bar_index,
                     style=label.style_label_left,
                     color=color.new(rungColor, 85),
                     textcolor=rungColor,
                     size=size.tiny,
                     tooltip="POC of the " + str.tostring(lookback) + "-bar window\n" + str.tostring(bu) + " bins used" + (bu < pocBins ? " (capped at one bin per tick, " + str.tostring(pocBins) + " requested)" : "") + " over " + str.tostring(windowEnd - aIdx + 1) + " chart bars\nbin width " + str.tostring(bw, format.mintick) + " — the level is a bin centre, precision is half that either way\nrecomputed every bar; it was not at this price historically"
                )
                array.push(drawnLabels, pocLabel)

            pcDrawn += 1

    // ========================================================================
    // ANCHOR MARKERS
    //
    // A fixed-lookback anchor is chosen by POSITION, not by price, so the
    // marker sits at the bar midpoint. Putting it on the high or low would
    // imply the extreme had something to do with the selection.
    // ========================================================================

    if showAnchorMarkers and vwCount > 0
        for i = 0 to vwCount - 1
            int aIdx = array.get(vwAnchorIdx, i)
            int markerBar = bar_index - (lastStored - aIdx)

            float aHigh = array.get(barHighs, aIdx)
            float aLow = array.get(barLows, aIdx)

            label markerLabel = label.new(
                 markerBar,
                 (aHigh + aLow) / 2.0,
                 str.tostring(array.get(vwLookbacks, i)),
                 xloc=xloc.bar_index,
                 style=label.style_label_center,
                 color=color.new(array.get(vwColors, i), 70),
                 textcolor=array.get(vwColors, i),
                 size=size.tiny
            )
            array.push(drawnLabels, markerLabel)

    // ========================================================================
    // STRUCTURE SCORE
    //
    // Computed from the DRAWN rungs — but only published when the drawn set
    // matches the enabled set exactly (see scoreValid below). A missing rung
    // does not silently shrink the denominator: normalising over whatever
    // horizons survived would let two available horizons print a confident
    // 0-100 that looks identical to a seven-horizon reading. If you are here to
    // "fix" the score so it works on short-history symbols, that is the
    // behaviour being prevented on purpose — disable the rungs the symbol
    // cannot support instead, which makes the reading an explicit choice.
    //
    // The reference price is the window-end close when confirmed-only is on, so
    // the score freezes with the levels rather than drifting intraday against
    // frozen VWAPs.
    // ========================================================================

    float dashRefPrice = confirmedOnly and windowUsable ? array.get(barCloses, windowEnd) : close

    array<int> orderIdx = array.new_int()

    if vwCount > 0
        for i = 0 to vwCount - 1
            array.push(orderIdx, i)

    // Sorted by lookback ascending, not by input order: the stack comparison is
    // short-vs-long, and nothing stops a rung being typed out of sequence.
    if vwCount > 1
        for a = 0 to vwCount - 2
            for b = 0 to vwCount - 2 - a
                if array.get(vwLookbacks, array.get(orderIdx, b)) > array.get(vwLookbacks, array.get(orderIdx, b + 1))
                    int tmpO = array.get(orderIdx, b)
                    array.set(orderIdx, b, array.get(orderIdx, b + 1))
                    array.set(orderIdx, b + 1, tmpO)

    int aboveCount = 0

    if vwCount > 0
        for i = 0 to vwCount - 1
            if array.get(vwValues, i) < dashRefPrice
                aboveCount += 1

    // Anchor-TF ATR, not chart ATR. The stack tolerance is a statement about
    // the horizon being measured, so it must not change when you switch the
    // chart timeframe under a fixed anchor. Falls back to chart ATR only if the
    // anchor value has not warmed up.
    float stackAtrRef = na(ab.atr) ? chartATR : ab.atr
    float stackTol = na(stackAtrRef) ? 0.0 : stackAtrRef * stackTolATR

    int pairCount = math.max(0, vwCount - 1)
    int rawStack = 0

    // Guarded: Pine counts DOWNWARD when the end value is below the start, so an
    // unguarded "for p = 0 to pairCount - 1" would execute twice at pairCount 0.
    if pairCount > 0
        for pI = 0 to pairCount - 1
            float vShort = array.get(vwValues, array.get(orderIdx, pI))
            float vLong = array.get(vwValues, array.get(orderIdx, pI + 1))
            float d = vShort - vLong

            if math.abs(d) <= stackTol
                rawStack += 0
            else if d > 0
                rawStack += 1
            else
                rawStack -= 1

    // The score is only published when every ENABLED rung actually produced a
    // VWAP and no two rungs share a lookback. Normalising to whatever happened
    // to exist would let a symbol with two available horizons print STRUCT 100
    // / STRONG BULL, which looks exactly as authoritative as a seven-horizon
    // reading and is not — the whole premise is multi-horizon agreement.
    //
    // Consequence worth knowing: on a symbol without 756 anchor bars of
    // history, the score stays "—" until you turn VW756 off. That is deliberate
    // rather than a limitation. Disabling the rungs a symbol cannot support is
    // an explicit decision about which horizons you are reading, and the score
    // comes back computed over that coherent set.
    bool scoreValid = rungsOn > 0 and vwCount == rungsOn and dupCount == 0

    float priceScore = scoreValid and vwCount > 0 ? aboveCount * 50.0 / vwCount : na
    float stackScore = scoreValid and pairCount > 0 ? ((rawStack + pairCount) / (2.0 * pairCount)) * 50.0 : na
    float structScore = na(priceScore) or na(stackScore) ? na : priceScore + stackScore

    int pocBelow = 0

    if pcDrawn > 0
        for i = 0 to array.size(pcValues) - 1
            if array.get(pcValues, i) < dashRefPrice
                pocBelow += 1

    // Anything genuinely wrong surfaces here even with the diagnostics panel
    // off, so a silent failure cannot hide behind a healthy-looking score.
    string issueTxt = ""

    // The two failures that stop collection entirely. Without these the
    // dashboard could show four em-dashes and no explanation, with the reason
    // only on a chart label — which defeats the point of centralising the
    // reading here.
    if not tfValid
        issueTxt := issueTxt + " TF invalid"
    if tfValid and not windowUsable
        issueTxt := issueTxt + " no completed TF"

    if noHistoryCount > 0
        issueTxt := issueTxt + " " + str.tostring(noHistoryCount) + " no-hist"
    if droppedCount > 0
        issueTxt := issueTxt + " " + str.tostring(droppedCount) + " dropped"
    if dupCount > 0
        issueTxt := issueTxt + " " + str.tostring(dupCount) + " dup"
    if pcDrawn < pocRequested
        issueTxt := issueTxt + " " + str.tostring(pocRequested - pcDrawn) + " poc"
    if volFlagged > 0
        issueTxt := issueTxt + " " + str.tostring(volFlagged) + " vol"

    bool hasIssues = str.length(issueTxt) > 0
    bool pocRowOn = showPocRow and pcDrawn > 0

    // ========================================================================
    // STRUCTURE DASHBOARD
    // ========================================================================

    if showDash
        int dashRows = 4 + (pocRowOn ? 1 : 0) + (hasIssues ? 1 : 0)

        if na(dashTbl) or dashRows != dashLastRows
            if not na(dashTbl)
                table.delete(dashTbl)
            dashTbl := table.new(f_dashPos(dashPos), 2, dashRows, border_width=1, frame_width=1, frame_color=color.new(color.gray, 60), bgcolor=color.new(color.black, 100))
            dashLastRows := dashRows

        string dss = f_statSize(dashSize)
        color dtp = color.new(color.black, 100)
        color dhc = color.new(color.gray, 0)
        color ddim = color.new(color.gray, 40)
        color biasCol = f_biasCol(structScore)

        table.cell(dashTbl, 0, 0, "STRUCT", text_color=dhc, text_size=dss, bgcolor=dtp)
        table.cell(dashTbl, 1, 0, na(structScore) ? "—" : str.tostring(structScore, "#"), text_color=biasCol, text_size=dss, bgcolor=dtp)

        table.cell(dashTbl, 0, 1, "P>VW", text_color=dhc, text_size=dss, bgcolor=dtp)
        table.cell(dashTbl, 1, 1, vwCount > 0 ? str.tostring(aboveCount) + "/" + str.tostring(vwCount) : "—", text_color=f_biasCol(priceScore * 2), text_size=dss, bgcolor=dtp)

        // The SIGNED total, which is the number that actually enters the score.
        // Counting bullish pairs only was ambiguous: five bullish plus one tied
        // and five bullish plus one inverted both read 5/6 while scoring
        // differently. +5/6 and +4/6 tell those apart.
        string stackTxt = pairCount == 0 ? "—" : (rawStack > 0 ? "+" : "") + str.tostring(rawStack) + "/" + str.tostring(pairCount)

        table.cell(dashTbl, 0, 2, "STACK", text_color=dhc, text_size=dss, bgcolor=dtp)
        table.cell(dashTbl, 1, 2, stackTxt, text_color=f_biasCol(stackScore * 2), text_size=dss, bgcolor=dtp)

        table.cell(dashTbl, 0, 3, "BIAS", text_color=dhc, text_size=dss, bgcolor=dtp)
        table.cell(dashTbl, 1, 3, f_biasWord(structScore), text_color=color.white, text_size=dss, bgcolor=color.new(biasCol, 25))

        int rowN = 4

        if pocRowOn
            // Phrased as P>POC to parallel P>VW, so the three count rows read
            // as one hierarchy: price against the curves, the curves against
            // each other, price against the volume levels. Still context only —
            // it does not touch the score.
            table.cell(dashTbl, 0, rowN, "P>POC", text_color=dhc, text_size=dss, bgcolor=dtp)
            table.cell(dashTbl, 1, rowN, str.tostring(pocBelow) + "/" + str.tostring(pcDrawn), text_color=#B084F5, text_size=dss, bgcolor=dtp)
            rowN += 1

        if hasIssues
            table.cell(dashTbl, 0, rowN, "check", text_color=#F5C542, text_size=dss, bgcolor=dtp)
            table.cell(dashTbl, 1, rowN, str.trim(issueTxt), text_color=#F5C542, text_size=dss, bgcolor=dtp)

    // ========================================================================
    // DIAGNOSTICS PANEL — optional, off by default
    //
    //   rungs = vwap + no TF hist + dropped     (exactly)
    //
    // POC sits below that identity, not inside it: a rung can produce a good
    // VWAP and no POC. Reasons are vol (substitution), rng (no price range),
    // win (window unavailable). dup counts rungs sharing a lookback number.
    // ========================================================================

    if showStatus
        if na(statTbl)
            statTbl := table.new(f_statPos(statusPos), 2, 6, border_width=1, frame_width=1, frame_color=color.new(color.gray, 60), bgcolor=color.new(color.black, 100))

        string ss = f_statSize(statusSize)
        color tp = color.new(color.black, 100)
        color hc = color.new(color.gray, 0)
        color dim = color.new(color.gray, 40)

        table.cell(statTbl, 0, 0, "rungs", text_color=hc, text_size=ss, bgcolor=tp)
        table.cell(statTbl, 1, 0, str.tostring(rungsOn), text_color=color.white, text_size=ss, bgcolor=tp)

        table.cell(statTbl, 0, 1, "vwap", text_color=showVWAPs ? hc : dim, text_size=ss, bgcolor=tp)
        table.cell(statTbl, 1, 1, showVWAPs ? str.tostring(vwDrawn) + "/" + str.tostring(rungsOn) : "off", text_color=not showVWAPs ? dim : (vwDrawn < rungsOn ? #F5C542 : color.white), text_size=ss, bgcolor=tp)

        string pocReason = ""
        if pocSuppressVol > 0
            pocReason := pocReason + " " + str.tostring(pocSuppressVol) + "vol"
        if pocSuppressRange > 0
            pocReason := pocReason + " " + str.tostring(pocSuppressRange) + "rng"
        if pocSuppressWindow > 0
            pocReason := pocReason + " " + str.tostring(pocSuppressWindow) + "win"

        // Expected = rungs whose OWN POC toggle is on and which produced a
        // VWAP, not every rung. "3/3" with seven rungs enabled is correct and
        // is what the default configuration should read.
        string pocTxt = not showPOCs ? "off" : str.tostring(pcDrawn) + "/" + str.tostring(pocRequested) + pocReason

        table.cell(statTbl, 0, 2, "poc", text_color=showPOCs ? hc : dim, text_size=ss, bgcolor=tp)
        table.cell(statTbl, 1, 2, pocTxt, text_color=not showPOCs ? dim : (pcDrawn < pocRequested ? #F5C542 : color.white), text_size=ss, bgcolor=tp)

        table.cell(statTbl, 0, 3, "no TF hist", text_color=noHistoryCount > 0 ? hc : dim, text_size=ss, bgcolor=tp)
        table.cell(statTbl, 1, 3, str.tostring(noHistoryCount), text_color=noHistoryCount > 0 ? #FF6B6B : dim, text_size=ss, bgcolor=tp)

        table.cell(statTbl, 0, 4, "dropped", text_color=droppedCount > 0 ? hc : dim, text_size=ss, bgcolor=tp)
        table.cell(statTbl, 1, 4, str.tostring(droppedCount), text_color=droppedCount > 0 ? #FF6B6B : dim, text_size=ss, bgcolor=tp)

        table.cell(statTbl, 0, 5, "dup", text_color=dupCount > 0 ? hc : dim, text_size=ss, bgcolor=tp)
        table.cell(statTbl, 1, 5, str.tostring(dupCount), text_color=dupCount > 0 ? #F5C542 : dim, text_size=ss, bgcolor=tp)

    // ========================================================================
    // WARNINGS
    // ========================================================================

    if not tfValid
        label tfLabel = label.new(
             bar_index,
             high,
             "Anchor TF (" + anchorTag + ") is below the chart TF\nnothing drawn — raise the anchor timeframe",
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_label_down,
             color=color.new(color.red, 20),
             textcolor=color.white,
             size=size.small
        )
        array.push(drawnLabels, tfLabel)

    // Confirmed-only with no completed anchor candle in stored history. Silent
    // failure here would look like a broken indicator rather than a setting.
    if tfValid and not windowUsable
        label winLabel = label.new(
             bar_index,
             high,
             "Confirmed Bars Only is on, but no completed " + anchorTag + " candle\nsits inside stored history — nothing drawn",
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_label_down,
             color=color.new(color.red, 20),
             textcolor=color.white,
             size=size.small
        )
        array.push(drawnLabels, winLabel)

    if volFlagged > 0
        string volMsg = worstVolPct >= 95.0 ? "volume missing on essentially every bar\nVWAPs are UNWEIGHTED means of the source, not volume-weighted\nPOCs are suppressed for the same reason" : str.tostring(volFlagged) + " VWAP(s) span windows with substituted volume\nworst window " + str.tostring(worstVolPct, "#.0") + "% — those bars are effectively DROPPED from the average, not down-weighted"

        label warnLabel = label.new(
             bar_index,
             high,
             volMsg,
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_label_down,
             color=color.new(color.orange, 20),
             textcolor=color.black,
             size=size.small
        )
        array.push(drawnLabels, warnLabel)
````
