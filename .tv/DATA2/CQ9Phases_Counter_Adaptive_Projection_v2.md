<!-- tradingview-pine-id: PUB;7ff93afdc3804f43be7d01862c1dd7f6 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# CQ_(9)_Phases Counter + Adaptive Projection v2

Source: https://www.tradingview.com/script/oTkEaRuR-CQ-9-Phases-Counter-Adaptive-Projection-v2/

## Description

================================================================================
 CQ_(9)_Phases Counter + Adaptive Projection v2
 FUNCTIONALITY DESCRIPTION AND USER MANUAL
 Pine Script v6 | TradingView | Overlay indicator
================================================================================

TABLE OF CONTENTS
  PART 1 - FUNCTIONALITY DESCRIPTION
    1.  Purpose and overview
    2.  Feature summary
    3.  How the script works (engine walkthrough)
        3.1  ZigZag engine
        3.2  ZigZag drawing (confirmed / unconfirmed / active legs)
        3.3  Adaptive Projection engine
        3.4  Leg (phase) numbering engine
        3.5  Phase Statistics table engine
        3.6  Table padding frame
    4.  Data model (internal arrays and state)
    5.  Repainting, timing and performance notes
  PART 2 - USER MANUAL
    6.  Quick start
    7.  Setting up the phase counter (anchors) step by step
    8.  Settings reference (every input, by group)
    9.  Reading the chart
    10. Reading the Phase Statistics table (every metric explained)
    11. Recommended workflows
    12. Troubleshooting and FAQ
    13. Known limitations and behaviors worth knowing
    14. Glossary

################################################################################
# PART 1 - FUNCTIONALITY DESCRIPTION
################################################################################

--------------------------------------------------------------------------------
1. PURPOSE AND OVERVIEW
--------------------------------------------------------------------------------

This indicator turns raw price action into a structured "phase" map. It:

  a) Builds a ZigZag of alternating swing highs and swing lows using a single
     lookback period.
  b) Draws the ZigZag legs on the chart, with the two most recent legs styled
     differently from the settled history.
  c) Numbers each leg 1-2-3-4-5 in a repeating cycle, anchored to a pivot whose
     phase number YOU verify manually (one saved anchor per timeframe).
  d) Projects a two-segment "adaptive" path forward from the current price,
     based on the average size, slope and direction of all past legs on the
     chart.
  e) Displays a Phase Statistics table with per-leg metrics: direction,
     high/low, growth, bars, retracement, velocity, comparison to averages,
     ATR-normalized size, ratio to the prior leg, plus Fibonacci-style
     retracement and extension price targets.

Everything is driven by ONE structural setting, the ZigZag Period. Changing it
changes the pivots, the numbering, the averages behind the projection, and every
number in the table.

The indicator is an analysis/visualization tool. It does not place orders, does
not generate alerts, and does not plot any series (the script ends with
plot(na), which only satisfies TradingView's requirement of having a plot).

--------------------------------------------------------------------------------
2. FEATURE SUMMARY
--------------------------------------------------------------------------------

  - ZigZag with adjustable period (10-100, default 45)
  - Three leg states, each with its own line style:
        Confirmed   (older, settled legs)
        Unconfirmed (most recent completed pivot-to-pivot leg)
        Active      (live leg from the latest pivot to the current price)
  - Optional circle markers at both ends of the Active and Unconfirmed legs
  - Adaptive Projection: 2 dotted segments (continue current leg, then reverse)
  - Phase numbering 1-5, repeating, forward and backward from a user anchor
  - Separate saved anchors for 1H, 4H, 1D, 1W and 1M charts
  - Manual or Automatic anchor-timeframe selection
  - Six numbering glyph styles
  - Label placement on the pivot or at the leg midpoint
  - Anchor marker (anchor symbol) showing which pivot was snapped to
  - Phase Statistics table, vertical or horizontal, 1-10 legs
  - 40/50/60% retracement targets and 127.2/161.8/200% extension targets, with
    "reached" markers
  - Three cell coloring styles for the table
  - Invisible padding frame to fine-tune table position on screen

--------------------------------------------------------------------------------
3. HOW THE SCRIPT WORKS (ENGINE WALKTHROUGH)
--------------------------------------------------------------------------------

3.1  ZIGZAG ENGINE
----------------------------------------------------------------------
Pivot detection uses the ZigZag Period (N):

    A bar is a pivot HIGH candidate if its high is the highest high of the
    last N bars.
    A bar is a pivot LOW candidate if its low is the lowest low of the last
    N bars.

The current direction (dir) is +1 (up) or -1 (down). Direction flips when a bar
is a pivot high but not a pivot low (dir becomes +1) or a pivot low but not a
pivot high (dir becomes -1). If a bar is both or neither, direction is kept.

Pivot storage:
  - On a direction change, a NEW pivot is added at the front of the pivot list.
  - If direction has not changed and a more extreme candidate appears (a higher
    high in an up move, or a lower low in a down move), the CURRENT (front)
    pivot is UPDATED in place (its price, time and bar index are replaced).
  - The ATR(20) value at the moment a pivot is created or updated is stored
    alongside it (used later for the xATR metric).

The pivot list is stored newest-first. Index 0 is the most recent pivot (the
start of the currently forming leg), index 1 the one before it, and so on.
Because the newest pivot can keep moving while price makes new extremes, the
most recent leg is not final until a new opposite pivot forms.

3.2  ZIGZAG DRAWING
----------------------------------------------------------------------
Whenever at least two legs' worth of data exists (4+ stored values), all
ZigZag lines are deleted and redrawn from the stored pivots:

  - The most recent completed leg (pivot 1 -> pivot 0 pair) uses the
    "Unconfirmed Leg Style".
  - All older legs use the "Confirmed Style".
  - Leg color: bullish color if the leg ended higher than it started,
    bearish color otherwise.
  - If "Mark Unconfirmed Leg Start/End" is on, two circle markers are placed at
    that leg's endpoints, in the leg's color.

The ACTIVE leg is drawn on the last bar only: a line from the latest pivot to
the current close, using the "Active Leg Style". Its color is bullish when
close is above the latest pivot's price, otherwise bearish. If "Mark Active
Leg Start/End" is on, circle markers are drawn at both ends.

All lines are positioned by bar TIME (xloc.bar_time), so they align to the
chart regardless of scrolling.

3.3  ADAPTIVE PROJECTION ENGINE
----------------------------------------------------------------------
Step 1 - Collect statistics from EVERY leg in the stored pivot history:
    For each leg the script records: length ($), slope ($ per unit time), and
    duration (bars). Legs are separated into bullish and bearish groups.
    It then computes: average bullish/bearish length, slope and bars.

Step 2 - Describe the live leg:
    current_direction : +1 if close > latest pivot price, otherwise -1
    current_length    : |close - latest pivot price|
    current_slope     : (close - latest pivot price) / time elapsed

Step 3 - Build the projection from the current price:
    Segment 1 ("finish the leg"):
        If the current leg is shorter than the average leg length in the same
        direction, draw a line continuing at the CURRENT leg's slope until the
        leg would reach the average length. Color follows the current
        direction.
    Segment 2 ("reversal"):
        Draw a line in the OPPOSITE direction using the average length and
        average slope of past legs in that opposite direction. It starts where
        Segment 1 ends.
    If the current leg is ALREADY as long as or longer than the average,
    Segment 1 is skipped and only Segment 2 is drawn, starting at the current
    price.

Safety cap: the projection never extends more than 500 bars (of the chart's
timeframe) into the future, in total.

Only the projection lines from the latest bar are kept; earlier copies are
deleted each time the script recalculates.

3.4  LEG (PHASE) NUMBERING ENGINE
----------------------------------------------------------------------
Goal: label every pivot with a phase number 1-5 in a repeating cycle that
matches a numbering YOU have verified.

Inputs: for each supported timeframe (1h, 4h, 1d, 1w, 1m) there is an anchor
date/time and a phase number (1-5).

Selecting the active anchor:
  - Manual mode: the "Anchor Timeframe (Manual)" dropdown decides which saved
    anchor is used.
  - Automatic mode: the script detects the chart's timeframe (must be exactly
    60m, 240m, 1D, 1W or 1M) and uses that timeframe's saved anchor. On any
    other timeframe there is no saved anchor and the counter stays silent.

The counter DISPLAYS only when the chart timeframe actually matches the active
anchor timeframe (tf_matches). Otherwise labels and anchor marker are hidden,
keeping other timeframes uncluttered.

Seeding (runs once, on the last bar, when at least 4 pivot values exist):
  1. The script finds the stored pivot whose timestamp is closest to the anchor
     date/time you entered ("snap to nearest pivot"). The newest pivot (the one
     still forming) is excluded from this search.
  2. That pivot receives the phase number you entered.
  3. Pivots NEWER than the anchor count up (…, n, n+1, …, wrapping 5 -> 1).
     Pivots OLDER than the anchor count down (…, n-1, n-2, …, wrapping 1 -> 5).
  4. The result is stored in three parallel lists: bar time, price, number.

Auto-extension: after seeding, each time a new pivot becomes frozen (a newer
opposite pivot forms), the next number in the cycle is appended automatically.
You do not need to renumber by hand as the chart advances.

Label placement: each label is drawn on the last bar.
  - "Pivot": label sits on the pivot itself.
  - "Leg Midpoint": label sits halfway (in time and price) between that pivot
    and the next numbered pivot. The newest label uses the live current price
    as its far endpoint, so it drifts until the leg is confirmed.

Label colors: with Auto-Color on, the label text uses bullish or bearish color
according to whether the next pivot's price is higher or lower than this
pivot's price; the background is the same color faded by the Fade %. With
Auto-Color off, custom background and text colors are used.

Anchor marker: an anchor-symbol label is placed above (if the anchor pivot was
a high) or below (if a low) the anchor pivot, offset by 2x ATR(20). It shows
the anchor's phase number and timeframe, for example "anchor 5 1d".

3.5  PHASE STATISTICS TABLE ENGINE
----------------------------------------------------------------------
The table is rebuilt on the last bar. Legs shown = Active + Previous
(Unconfirmed) + (Legs Shown - 2) older confirmed legs, up to 10 total.

Each leg is a column (Vertical orientation) or a row (Horizontal). Column order
left to right (Vertical): oldest historical leg ... newest historical leg,
Previous (Unconfirmed), Active (Projected).

Per-leg metric sources:
  - Historical legs: computed from fixed pivot-to-pivot data.
  - Previous leg: computed from the leg's pivot window through the current
    bar, plus live retracement information.
  - Active leg: computed from the latest pivot through the current bar.

Full definitions of every metric are in Section 10.

Cell coloring is controlled by "Value Cell Style":
  - White: flat background, flat text.
  - Tendency Color: text colored by the leg's direction.
  - Tendency Background: the cell background colored by direction with a flat
    text color on top.
On the Rtd and Ext target rows, the direction color is INVERTED (a bullish leg's
targets are drawn in the bearish color and vice versa), because those targets
are prices price would reach by moving against (retracing) or beyond (extending)
the leg.

3.6  TABLE PADDING FRAME
----------------------------------------------------------------------
The table has an extra outer row above and below, and an extra column left and
right of the real content. Each of these four padding areas is a single merged,
fully transparent cell. Their sizes are user inputs (0-100). Since the table is
anchored to a chart edge or corner, growing a padding cell shifts the visible
content away from that anchor, giving fine position control beyond the nine
presets.

--------------------------------------------------------------------------------
4. DATA MODEL (INTERNAL ARRAYS AND STATE)
--------------------------------------------------------------------------------

  z          Pivot list, newest first, stored as pairs: [price, time, price,
             time, ...]. Index 0 = newest pivot price, index 1 = its time.
  zbar       Pivot bar indices, newest first.
  zatr       ATR(20) captured at each pivot, newest first.

  leg_bar_arr / leg_price_arr / leg_num_arr
             Numbered pivots, OLDEST first (opposite order from z). Filled at
             seeding and extended as pivots freeze.

  seeded             true once the counter has been seeded.
  last_recorded_bar  bar index of the last pivot already numbered.
  last_assigned_num  the phase number given to that pivot.
  anchor_*_saved     memory of which pivot was snapped to (for the marker).

  avg_bullish_length, avg_bearish_length
  avg_bullish_slope,  avg_bearish_slope
  avg_bullish_bars,   avg_bearish_bars
             Averages used by both the projection and the table's
             "vs Avg" metrics.

  Drawing object pools (lines, labels, table) are kept in persistent
  variables and deleted/recreated so old objects never pile up.

--------------------------------------------------------------------------------
5. REPAINTING, TIMING AND PERFORMANCE NOTES
--------------------------------------------------------------------------------

  - The newest ZigZag pivot repaints by design: it moves as price makes new
    extremes in the current direction. The most recent completed leg is
    therefore labeled "Unconfirmed".
  - Older pivots do not change unless you change the ZigZag Period.
  - Labels, the projection, the table, the active leg and the anchor marker are
    only (re)drawn on the last bar of the chart, so they update on each new
    tick/bar of the latest candle.
  - The script is limited to 500 lines and 500 labels. With very small ZigZag
    Periods on long histories, the oldest legs may be dropped by TradingView.
  - The projection average is calculated over the whole stored pivot history
    each time a pivot is added, so it adapts as more legs form.

################################################################################
# PART 2 - USER MANUAL
################################################################################

--------------------------------------------------------------------------------
6. QUICK START
--------------------------------------------------------------------------------

  1. Add the indicator to a chart on one of the supported timeframes:
     1H, 4H, 1D, 1W or 1M.
  2. Open Settings. Leave ZigZag Period at 45 for a first look.
  3. Under "Leg Numbering", set "Anchor Timeframe Selection" to Automatic (so
     the right saved anchor is used per chart), or leave Manual and pick the
     matching timeframe.
  4. Set the anchor date/time (Pivot anchor) and phase number for that
     timeframe (see Section 7).
  5. Look at the chart: ZigZag legs, numbered labels, a dotted projection from
     the current price, and the Phase Statistics table at the bottom left.
  6. Adjust colors, sizes and table position to taste.

If you see legs and the table but NO numbers, the chart timeframe does not
match the active anchor timeframe (see Troubleshooting, Q1).

--------------------------------------------------------------------------------
7. SETTING UP THE PHASE COUNTER (ANCHORS) STEP BY STEP
--------------------------------------------------------------------------------

The counter needs one reliable reference: "this specific pivot is phase N".

  1. Decide which pivot you consider a known phase, based on your own analysis.
  2. Note its date and time on that timeframe's chart.
  3. In the "Leg Numbering" group, find the row for that timeframe, for
     example "Pivot (1D)".
  4. Enter the pivot's date/time in the date field.
  5. Enter its phase number (1-5) in the small numeric box on the same row.
  6. Make sure the active timeframe (Manual pick or Automatic detection) equals
     the chart timeframe.
  7. Enable "Mark Anchor Pivot". An anchor marker should appear above or below
     a pivot. Verify it sits on the pivot you intended.
  8. If the marker is on the wrong pivot, adjust the date/time to sit closer to
     the intended pivot. The script always snaps to the NEAREST pivot in time.

Tips:
  - The anchor only needs to be near the pivot in time, not exact to the bar,
    but if two pivots are close together, be precise.
  - Re-check the anchor if you change the ZigZag Period: a different Period may
    produce different pivots, so the snapped pivot can change.
  - Each timeframe keeps its own anchor. Setting the 1D anchor does not affect
    the 4H anchor.
  - The anchor pivot must exist in the loaded chart history. If you scroll too
    little history or use a very large Period, the anchor pivot might not
    exist, and the snap will pick the nearest one that does.

--------------------------------------------------------------------------------
8. SETTINGS REFERENCE (EVERY INPUT, BY GROUP)
--------------------------------------------------------------------------------

GROUP: Phases (ZigZag)
----------------------
  Period (10-100, default 45)
      ZigZag lookback in bars. Higher = fewer, larger, later-confirming legs.
      Lower = more, smaller, faster legs. Drives everything else.

  Bullish Leg / Bearish Leg (colors)
      Colors for upward / downward legs, including the active leg and its
      markers.

  Confirmed Style (Solid/Dashed/Dotted) and Width (1-8)
      Style for settled older legs. Width applies to ALL legs.

  Active Leg Style (default Dotted)
      Style of the live leg to the current price.

  Unconfirmed Leg Style (default Dashed)
      Style of the most recent completed leg.

  Mark Active Leg Start/End + size (Tiny..Huge)
      Circle markers at both ends of the Active leg.

  Mark Unconfirmed Leg Start/End + size (Tiny..Huge)
      Circle markers at both ends of the Unconfirmed leg.

GROUP: Adaptive Projection
--------------------------
  Show Projection
      Master switch for the two projection segments.

  Bullish Projection / Bearish Projection (colors)
      Colors for upward / downward projection segments.

  Style and Width (1-5)
      Line style and width for both segments (default Dotted, width 1).

GROUP: Leg Numbering
--------------------
  Pivot (1H / 4H / 1D / 1W / 1M) - date/time + phase number (1-5)
      The five saved anchors. Only the active timeframe's anchor is used.

  Anchor Timeframe Selection (Manual / Automatic)
      Manual: uses the dropdown below regardless of the chart.
      Automatic: uses the chart's own timeframe (1h/4h/1d/1w/1m only).

  Anchor Timeframe (Manual)
      Which saved anchor to use in Manual mode. The counter displays only when
      the chart is on this timeframe.

  Mark Anchor Pivot
      Shows the anchor marker on the snapped pivot.

  Numbering Style
      Glyph set for phase numbers: circled, filled circled, Roman numerals,
      keycap emoji, subscript parentheses, or parenthesized. Rendering varies
      by OS/browser/font.

  Label Size (Tiny..Huge, default Huge)
      Size of the number labels on the chart (not the table).

  Auto-Color by Leg Direction
      On: labels use the Bullish/Bearish Label colors below.
      Off: labels use the custom colors below.

  Bullish Label Color / Bearish Label Color
      Also the bullish/bearish colors used throughout the Phase Statistics
      table (tendency text, tendency background lookup, inverted target rows).

  Custom Label Background Color / Custom Label Text Color
      Used only when Auto-Color is off.

  Label Background Fade % (0-100, default 90)
      0 = opaque background, 100 = fully transparent (only the glyph shows).
      Overrides any transparency of the picked colors.

  Label Position (Pivot / Leg Midpoint, default Leg Midpoint)
      Where each number sits relative to its leg.

GROUP: Phase Statistics Table
-----------------------------
  Show Table
      Master switch. Table appears once at least two pivots exist.

  Orientation (Vertical / Horizontal)
      Vertical: legs are columns, metrics are rows.
      Horizontal: legs are rows, metrics are columns.

  Position (nine presets)
      Chart corner/edge anchor. Default Bottom Left.

  Text Size (Tiny..Huge)
      Table text. Single-line leg headers are always Normal size; the
      Unconfirmed/Projected two-line headers follow this setting.

  Header Background / Header Text
      Colors for title bar, corner cell, leg headers and metric labels.

  Cell Background / Cell Text
      Value-cell colors for the White style, and the fallback otherwise.

  Value Cell Style (White / Tendency Color / Tendency Background)
      How value cells are colored (see Section 3.5).

  Tendency BG: Bullish / Bearish / Text Color
      Used only with the Tendency Background style.

  Border Color
      Grid line color. Use a transparent color for a borderless table.

  Retracement Bar Glyphs
      Four filled/empty glyph pairs for the 10-segment retracement bar.

  Show Retracement Progress Bar
      Adds a "Rtd %" row/column with the 10-segment bar.

  Legs Shown (2-10, default 7)
      Total legs displayed (Active + Previous + older).

  Show Retracement % Targets
      Adds Rtd 40%, 50%, 60% price targets per leg.

  Mark Reached Retracement Levels + Reached Marker Glyph
      Appends a marker (one of four glyphs) to a target price once price has
      retraced at least that far.

  Show Velocity, Show Size vs Avg, Show Bars vs Avg, Show ATR-Normalized Size
  (xATR), Show Ratio to Prior Leg
      Toggle the advanced metrics (Section 10).

  Show Extension % Targets (127/162/200%)
      Adds Ext 127%, 162%, 200% price targets per leg.

GROUP: Table Position Fine Tunning
----------------------------------
  Four padding inputs (top, bottom, left, right; 0-100 each, default 0).
      Adds invisible, merged, fully transparent space on that side of the
      table so the visible content shifts away from its anchor corner.
      Example: anchored Bottom Left, raising the bottom padding lifts the
      table up; raising the left padding pushes it right.

--------------------------------------------------------------------------------
9. READING THE CHART
--------------------------------------------------------------------------------

  ZigZag legs
      Teal legs (default) go up; orange legs (default) go down.
      Dashed = the most recent completed leg (may still shift).
      Dotted = the live leg running to the current price.
      Solid = older, settled legs.

  Circle markers
      Small circles mark the start and end of the Active and Unconfirmed legs.

  Number labels
      Each pivot/leg carries a 1-5 phase number. When Label Position is "Leg
      Midpoint", the number sits mid-leg. The newest number drifts with price
      until its leg is confirmed.

  Anchor marker
      Shows which pivot your anchor snapped to, with its phase number and
      timeframe.

  Projection
      Dotted two-part line from the current price. Segment 1 = expected
      continuation of the current leg to the average length; Segment 2 =
      expected reversal by the average opposite-leg length and slope. It is a
      statistical average of past behavior on this chart, not a forecast.

--------------------------------------------------------------------------------
10. READING THE PHASE STATISTICS TABLE (EVERY METRIC EXPLAINED)
--------------------------------------------------------------------------------

Column headers
  - Historical legs: the leg's phase number (or "Leg-N" if not numbered).
  - Previous leg: phase number + "Unconfirmed".
  - Active leg: phase number + "Projected".

Metrics
  Dir
      UP or DN: the leg's direction.

  High / Low
      Highest and lowest price of the leg.
      Historical legs: their two pivot prices.
      Previous leg: highest/lowest from the older pivot through the latest bar.
      Active leg: highest/lowest from the latest pivot through the latest bar.

  Growth
      Size of the leg in dollars (high minus low, per the definitions above).

  Bars
      Number of bars the leg lasted (pivot to pivot). For the Active leg, bars
      since the latest pivot.

  Retraced
      Two lines: percent and dollars.
      Historical legs: how much of that leg the NEXT (more recent) confirmed
      leg gave back.
      Previous leg: distance from the current close to that leg's end pivot,
      relative to the confirmed leg before it.
      Active leg: distance from the current close to the latest pivot, relative
      to the previous leg's size.

  Rtd %
      A 10-segment progress bar of the retracement percentage (one segment per
      10%). Optional.

  Velocity
      Growth divided by Bars, shown as dollars per bar.

  vs Avg Size
      The leg's Growth compared with the average leg of the same direction on
      the chart. Signed percent: +18% means 18% larger than average.

  vs Avg Bars
      The leg's duration compared with the average duration of same-direction
      legs. Signed percent.

  xATR
      Growth divided by the ATR(20) recorded at the leg's starting pivot.
      Makes sizes comparable across volatility regimes (shown as "1.8x ATR").

  Ratio to Prior
      The leg's size divided by the size of the leg immediately before it.
      Tagged with the nearest Fibonacci ratio if within tolerance, for example
      "0.62x (~.618)". Recognized tags: .382, .5, .618, .786, 1.0, 1.272,
      1.618, 2.0, 2.618.

  Rtd 40% / 50% / 60%
      Prices at 40/50/60% retracement of that leg's own range, measured from
      the leg's more recent pivot back toward its older pivot. A marker is
      appended if price has retraced at least that far (see Marker settings).
      The Previous leg uses the live Active retracement %.
      The Active column shows a dash: its own targets are not yet defined.

  Ext 127% / 162% / 200%
      Prices at 127.2%, 161.8% and 200% of the leg's range, projected beyond
      the leg's older end in the same direction as the leg. Same marker rules;
      the Active column shows a dash.

Color inversion
      On Rtd and Ext rows, a bullish leg's values use the bearish color (and
      vice versa), since they describe where price would go relative to the
      leg's direction.

Price formatting
      Prices are rounded to whole dollars with thousands separators ($12,345).
      This suits high-priced assets. For assets that trade in cents or a few
      dollars, the table values will look rounded/coarse (see Section 13).

--------------------------------------------------------------------------------
11. RECOMMENDED WORKFLOWS
--------------------------------------------------------------------------------

  A) Multi-timeframe counting
     Set Anchor Timeframe Selection to Automatic. Save an anchor for each of
     1H/4H/1D/1W/1M once. Then simply switch chart timeframe; the counter
     switches anchors automatically. Timeframes such as 15m or 2D show no
     numbering.

  B) Using the table as a checklist
     Keep Legs Shown at 7. Watch the Active column for Retraced % and the Rtd
     bar. Compare the Active leg's "vs Avg Size / Bars" to see if the current
     move is stretched or young relative to history.

  C) Target planning
     Use the Previous (Unconfirmed) column for live Rtd 40/50/60 and Ext
     127/162/200 prices, and the "reached" marker to see what has already been
     touched.

  D) Cleaner chart
     Turn off marker circles and the projection; set Label Background Fade to
     100 so only the glyphs show; or switch the table to Horizontal and reduce
     Legs Shown.

  E) Tuning the Period
     Start with 45. Raise it for macro swings on lower timeframes; lower it for
     more responsive legs. Re-verify your anchor afterwards.

--------------------------------------------------------------------------------
12. TROUBLESHOOTING AND FAQ
--------------------------------------------------------------------------------

Q1. I see legs and the table but no number labels or anchor marker.
    The chart timeframe does not match the active anchor timeframe. In Manual
    mode, set "Anchor Timeframe (Manual)" to the chart's timeframe. In
    Automatic mode, use exactly 1h, 4h, 1D, 1W or 1M (60m/240m/D/W/M).

Q2. The anchor marker is on the wrong pivot.
    The script snaps to the pivot nearest in time to your date/time. Move the
    date/time closer to the intended pivot. If you changed the ZigZag Period,
    pivots have changed; re-check.

Q3. Numbers changed after I changed the ZigZag Period.
    Expected. Different Period = different pivots = different sequence. Re-set
    the anchor.

Q4. The last pivot keeps moving.
    Expected. The newest pivot follows price while direction persists; that is
    why the latest completed leg is called Unconfirmed.

Q5. The projection has only one segment.
    The current leg already meets or exceeds the average same-direction leg, so
    only the reversal segment is drawn from the current price.

Q6. No projection at all.
    Check "Show Projection", and make sure at least two pivots exist (a longer
    history or a smaller Period).

Q7. The table does not appear.
    Check "Show Table". It also requires enough pivots to exist. If the table
    was moved off-screen with large padding values, reduce them.

Q8. Some legs/labels are missing on long histories.
    TradingView limits this script to 500 lines and 500 labels. Increase the
    Period so fewer legs are produced.

Q9. Emoji or glyphs render oddly.
    Glyph rendering depends on your OS/browser/font. Try another Numbering
    Style or Retracement Bar Glyph set.

Q10. Numbers on some older legs are "Leg-N" instead of a glyph.
    Those older table legs have no phase number assigned, for instance when
    the counter has not seeded yet.

--------------------------------------------------------------------------------
13. KNOWN LIMITATIONS AND BEHAVIORS WORTH KNOWING
--------------------------------------------------------------------------------

  1. Seeding happens once, on the first last-bar calculation where enough
     pivots exist. Changing a setting recalculates the script and reseeds.
  2. Numbering labels are only displayed when the chart timeframe matches the
     active anchor timeframe. The table's header glyphs use the numbering data
     whenever it has been seeded, even if labels are hidden for a timeframe
     mismatch.
  3. The newest phase label always uses the bullish label color (there is no
     later pivot yet to compare against for direction).
  4. The Previous (Unconfirmed) column's High/Low and Growth are measured from
     the older pivot through the current bar, so they can include movement
     from the Active leg. Historical columns use fixed pivot-to-pivot values.
  5. The Adaptive Projection is based on averages, so a few very large or very
     small legs can skew it. It is a statistical tool, not a prediction.
  6. Table prices are rounded to whole dollars, which suits high-priced assets
     (for example Bitcoin) and can look coarse on low-priced instruments.
  7. Anchors exist only for 1h, 4h, 1d, 1w and 1m. Other timeframes have no
     saved anchor and no numbering.
  8. No alerts are provided.
  9. Because the pivot direction logic uses one lookback in both directions,
     a bar that is simultaneously the highest high and lowest low of the window
     (an extreme outside bar) does not change direction.

--------------------------------------------------------------------------------
14. GLOSSARY
--------------------------------------------------------------------------------

  Active leg       Live line from the latest pivot to the current price.
  Anchor           A pivot you nominate as having a known phase number.
  ATR(20)          Average True Range over 20 bars, used for volatility scaling.
  Confirmed leg    A settled older leg that no longer changes.
  Extension        A price projected beyond a leg's range in its own direction.
  Leg              The move between two consecutive ZigZag pivots.
  Phase            The repeating 1-2-3-4-5 label given to each leg.
  Pivot            A swing high or low detected by the ZigZag Period.
  Retracement      The fraction of a leg that the following move gives back.
  Snap             Choosing the stored pivot closest in time to your anchor
                   date/time.
  Unconfirmed leg  The most recent completed leg, whose end pivot may still move.
  ZigZag Period    The lookback (in bars) that decides what counts as a pivot.

================================================================================
 END OF DOCUMENT
================================================================================

---

## Source Code

````pine
//@version=6
indicator('CQ_(9)_Phases Counter + Adaptive Projection v2', overlay = true, max_lines_count = 500, max_labels_count = 500)

// 🌀 ZIGZAG SETTINGS
grp_zz = "🌀 Phases (ZigZag)"
p1 = input.int(45, 'Period', 10, 100, group = grp_zz,
     tooltip = "ZigZag lookback length in bars. A bar becomes a pivot high (or pivot low) only when it is the highest high (or lowest low) of the last N bars, and pivots of alternating direction are connected into legs. Higher values give fewer, larger, smoother legs that confirm later; lower values give more, smaller, noisier legs that react faster. This one setting drives everything else in the script: leg drawing, phase numbering, the Adaptive Projection averages and every value in the Phase Statistics table.")

bull_color = input.color(color.rgb(0, 137, 123), 'Bullish Leg', inline = 'zzcol', group = grp_zz,
     tooltip = "Color of ZigZag legs that travel upward (price ended the leg higher than it started), including the live Active leg while price is above its starting pivot. Also colors the start/end circle markers of those legs. Pairs with the Bearish Leg color to its right.")
bear_color = input.color(color.rgb(255, 153, 0), 'Bearish Leg', inline = 'zzcol', group = grp_zz,
     tooltip = "Color of ZigZag legs that travel downward (price ended the leg lower than it started), including the live Active leg while price is below its starting pivot. Also colors the start/end circle markers of those legs. Pairs with the Bullish Leg color to its left.")

s = input.string('Solid', 'Confirmed Style', ['Solid', 'Dashed', 'Dotted'], inline = 'zzstyle', group = grp_zz,
     tooltip = "Line style (Solid, Dashed or Dotted) for confirmed, fully settled ZigZag legs. The two most recent legs are styled separately: see Unconfirmed Leg Style and Active Leg Style below. Pairs with the Width input to its right.")
w = input.int(2, 'Width', 1, 8, inline = 'zzstyle', group = grp_zz,
     tooltip = "Line width in pixels (1-8) shared by every ZigZag leg: confirmed, unconfirmed and active. Pairs with the Confirmed Style input to its left.")

last_leg_style = input.string('Dotted', 'Active Leg Style', ['Solid', 'Dashed', 'Dotted'], group = grp_zz,
     tooltip = "Line style of the Active leg: the still-forming leg drawn from the most recent pivot to the current price on the last bar. It moves with every price update until a new pivot forms and it becomes the Unconfirmed leg.")
prev_leg_style = input.string('Dashed', 'Unconfirmed Leg Style', ['Solid', 'Dashed', 'Dotted'], group = grp_zz,
     tooltip = "Line style of the Unconfirmed leg: the most recent completed pivot-to-pivot leg. Its end pivot can still shift while price keeps making new extremes, so it is styled apart from the older, settled legs, which use the Confirmed Style.")

show_leg_markers = input.bool(true, 'Mark Active Leg Start/End', inline = 'legmark', group = grp_zz,
     tooltip = "Draws a small circle marker at both ends of the Active leg (its starting pivot and the current price), colored to match the leg's direction. The marker size is chosen by the selector to its right.")
marker_size_choice = input.string('Small', '', options = ['Tiny', 'Small', 'Normal', 'Large', 'Huge'], inline = 'legmark', group = grp_zz,
     tooltip = "Size (Tiny to Huge) of the circle markers drawn on the Active leg. Only has an effect while Mark Active Leg Start/End is enabled.")

show_prev_leg_markers = input.bool(true, 'Mark Unconfirmed Leg Start/End', inline = 'legmark2', group = grp_zz,
     tooltip = "Draws a small circle marker at both ends of the Unconfirmed leg (the most recent completed pivot-to-pivot leg), colored to match that leg's direction. The marker size is chosen by the selector to its right.")
prev_marker_size_choice = input.string('Normal', '', options = ['Tiny', 'Small', 'Normal', 'Large', 'Huge'], inline = 'legmark2', group = grp_zz,
     tooltip = "Size (Tiny to Huge) of the circle markers drawn on the Unconfirmed leg. Only has an effect while Mark Unconfirmed Leg Start/End is enabled.")

f_drawLeg(arr, x1, y1, x2, y2, col, lw, sty) =>
    line_style = sty == 'Solid' ? line.style_solid : sty == 'Dashed' ? line.style_dashed : line.style_dotted
    ml = line.new(x1 = x1, y1 = y1, x2 = x2, y2 = y2, xloc = xloc.bar_time, color = col, width = lw, style = line_style)
    array.push(arr, ml)

f_labelSize(sel) =>
    sel == "Tiny" ? size.tiny : sel == "Small" ? size.small : sel == "Normal" ? size.normal : sel == "Large" ? size.large : size.huge

float ph = ta.highestbars(high, p1) == 0 ? high : na
float pl = ta.lowestbars(low, p1) == 0 ? low : na
atr20 = ta.atr(20)

isPh = not na(ph)
isPl = not na(pl)

var dir = 0
prev_dir = dir
dir := isPh and not isPl ? 1 : isPl and not isPh ? -1 : dir
dc = dir != prev_dir ? 1 : 0

var z = array.new_float(0)
var zbar = array.new_int(0)
var zatr = array.new_float(0)

add_to_zigzag(p, pb, v, b, bidx) =>
    array.unshift(p, b)
    array.unshift(p, v)
    array.unshift(pb, bidx)

update_zigzag(p, pb, v, b, d, bidx) =>
    if array.size(p) == 0
        add_to_zigzag(p, pb, v, b, bidx)
    else if (d == 1 and v > array.get(p, 0)) or (d == -1 and v < array.get(p, 0))
        array.set(p, 0, v)
        array.set(p, 1, b)
        array.set(pb, 0, bidx)
    0.

if isPh or isPl
    if dc != 0
        add_to_zigzag(z, zbar, dir == 1 ? ph : pl, time, bar_index)
        array.unshift(zatr, atr20)
    else if not(isPh and isPl)
        update_zigzag(z, zbar, dir == 1 ? ph : pl, time, dir, bar_index)
        if array.size(zatr) > 0
            array.set(zatr, 0, atr20)

var array<line> zigzag_lines = array.new_line()
var array<label> prev_leg_markers = array.new_label()
if array.size(z) >= 4
    while array.size(zigzag_lines) > 0
        line.delete(array.pop(zigzag_lines))
    while array.size(prev_leg_markers) > 0
        label.delete(array.pop(prev_leg_markers))

    last_valid = array.size(z) - 4
    if last_valid >= 0
        for i = 0 to last_valid by 2
            x1 = int(array.get(z, i + 1))
            y1 = array.get(z, i)
            x2 = int(array.get(z, i + 3))
            y2 = array.get(z, i + 2)
            leg_color = y1 > y2 ? bull_color : bear_color
            leg_style = i == 0 ? prev_leg_style : s
            f_drawLeg(zigzag_lines, x1, y1, x2, y2, leg_color, w, leg_style)

            if i == 0 and show_prev_leg_markers
                prev_marker_size = f_labelSize(prev_marker_size_choice)
                prev_start_marker = label.new(x1, y1, "◯",
                     xloc = xloc.bar_time,
                     style = label.style_label_center,
                     color = color.new(color.white, 100),
                     textcolor = leg_color,
                     size = prev_marker_size)
                prev_end_marker = label.new(x2, y2, "◯",
                     xloc = xloc.bar_time,
                     style = label.style_label_center,
                     color = color.new(color.white, 100),
                     textcolor = leg_color,
                     size = prev_marker_size)
                array.push(prev_leg_markers, prev_start_marker)
                array.push(prev_leg_markers, prev_end_marker)

grp_proj = "📈 Adaptive Projection"
show_projection = input.bool(true, "Show Projection", group = grp_proj,
     tooltip = "Master switch for the Adaptive Projection: two lines drawn forward from the current price. Segment 1 continues the current leg until it reaches the average length of past legs in the same direction (skipped if the leg is already longer than that average). Segment 2 then reverses, using the average length and average slope of past legs in the opposite direction. The averages are taken from every ZigZag leg in the chart history, so the projection adapts as more legs form. The projection never extends more than 500 bars ahead.")
proj_bull_color = input.color(color.rgb(0, 137, 123), 'Bullish Projection', inline = 'projcol', group = grp_proj,
     tooltip = "Color of projection segments that move upward. Segment 1 uses this color when the current leg is bullish; Segment 2 uses it when the projected reversal is upward (current leg bearish). Pairs with the Bearish Projection color to its right.")
proj_bear_color = input.color(color.rgb(255, 153, 0), 'Bearish Projection', inline = 'projcol', group = grp_proj,
     tooltip = "Color of projection segments that move downward. Segment 1 uses this color when the current leg is bearish; Segment 2 uses it when the projected reversal is downward (current leg bullish). Pairs with the Bullish Projection color to its left.")
proj_style = input.string("Dotted", "Style", options = ["Solid", "Dashed", "Dotted"], inline = 'proj', group = grp_proj,
     tooltip = "Line style (Solid, Dashed or Dotted) of both projection segments. Pairs with the Width input to its right.")
proj_width = input.int(1, "Width", 1, 5, inline = 'proj', group = grp_proj,
     tooltip = "Line width in pixels (1-5) of both projection segments. Pairs with the Style input to its left.")

var float avg_bearish_length = 0.0
var float avg_bullish_length = 0.0
var float avg_bearish_slope = 0.0
var float avg_bullish_slope = 0.0
var float avg_bearish_bars = 0.0
var float avg_bullish_bars = 0.0

if array.size(z) >= 4
    bearish_lengths = array.new_float(0)
    bullish_lengths = array.new_float(0)
    bearish_slopes = array.new_float(0)
    bullish_slopes = array.new_float(0)
    bearish_bars_arr = array.new_float(0)
    bullish_bars_arr = array.new_float(0)
    i = 0
    while i < array.size(z) - 2
        yA = array.get(z, i)
        xA = array.get(z, i + 1)
        yB = array.get(z, i + 2)
        xB = array.get(z, i + 3)
        if xA != xB
            segment_direction = yA > yB ? 1 : -1
            segment_length = math.abs(yA - yB)
            segment_slope = (yA - yB) / (xA - xB)
            seg_bar_idx = i / 2
            seg_bars = array.size(zbar) > seg_bar_idx + 1 ? array.get(zbar, seg_bar_idx) - array.get(zbar, seg_bar_idx + 1) : int(na)
            if segment_direction == -1
                array.push(bearish_lengths, segment_length)
                array.push(bearish_slopes, segment_slope)
                if not na(seg_bars)
                    array.push(bearish_bars_arr, seg_bars)
            else
                array.push(bullish_lengths, segment_length)
                array.push(bullish_slopes, segment_slope)
                if not na(seg_bars)
                    array.push(bullish_bars_arr, seg_bars)
        i += 2
    avg_bearish_length := array.size(bearish_lengths) > 0 ? array.avg(bearish_lengths) : 0
    avg_bullish_length := array.size(bullish_lengths) > 0 ? array.avg(bullish_lengths) : 0
    avg_bearish_slope := array.size(bearish_slopes) > 0 ? array.avg(bearish_slopes) : 0
    avg_bullish_slope := array.size(bullish_slopes) > 0 ? array.avg(bullish_slopes) : 0
    avg_bearish_bars := array.size(bearish_bars_arr) > 0 ? array.avg(bearish_bars_arr) : 0
    avg_bullish_bars := array.size(bullish_bars_arr) > 0 ? array.avg(bullish_bars_arr) : 0

grp_leg = "🔢 Leg Numbering"

anchor_time_1h = input.time(timestamp("2024-01-01 00:00"), "Pivot⚓ (1H)", group = grp_leg, inline = '1H',
     tooltip = "Date and time of a pivot whose phase number you have verified on the 1H timeframe. When the counter seeds itself it snaps to the ZigZag pivot closest in time to this timestamp, uses it as the numbering reference, then labels every other pivot 1-5 in a repeating cycle forward and backward from it. Only used when the active anchor timeframe is 1h (set by Anchor Timeframe Selection / Anchor Timeframe (Manual)); the other timeframes' anchors are ignored. Choose a real swing pivot you can identify on the chart, and re-check it if you change the ZigZag Period, since a different Period may produce different pivots.")
last_verified_leg_1h = input.int(1, "", minval = 1, maxval = 5, group = grp_leg, inline = '1H',
     tooltip = "Phase number (1-5) assigned to the 1H anchor pivot above. Neighboring pivots continue the repeating 1-2-3-4-5 cycle in both directions (older pivots count down, newer ones count up, wrapping from 5 back to 1), and newly confirmed pivots keep extending the count automatically. Only used when the active anchor timeframe is 1h.")

anchor_time_4h = input.time(timestamp("2026-08-01T11:00:00-0500"), "Pivot⚓ (4H)", group = grp_leg, inline = '4H',
     tooltip = "Date and time of a pivot whose phase number you have verified on the 4H timeframe. When the counter seeds itself it snaps to the ZigZag pivot closest in time to this timestamp, uses it as the numbering reference, then labels every other pivot 1-5 in a repeating cycle forward and backward from it. Only used when the active anchor timeframe is 4h (set by Anchor Timeframe Selection / Anchor Timeframe (Manual)); the other timeframes' anchors are ignored. Choose a real swing pivot you can identify on the chart, and re-check it if you change the ZigZag Period, since a different Period may produce different pivots.")
last_verified_leg_4h = input.int(1, "", minval = 1, maxval = 5, group = grp_leg, inline = '4H',
     tooltip = "Phase number (1-5) assigned to the 4H anchor pivot above. Neighboring pivots continue the repeating 1-2-3-4-5 cycle in both directions (older pivots count down, newer ones count up, wrapping from 5 back to 1), and newly confirmed pivots keep extending the count automatically. Only used when the active anchor timeframe is 4h.")

anchor_time_1d = input.time(timestamp("2026-05-05 19:00"), "Pivot⚓ (1D)", group = grp_leg, inline = '1D',
     tooltip = "Date and time of a pivot whose phase number you have verified on the 1D timeframe. When the counter seeds itself it snaps to the ZigZag pivot closest in time to this timestamp, uses it as the numbering reference, then labels every other pivot 1-5 in a repeating cycle forward and backward from it. Only used when the active anchor timeframe is 1d (set by Anchor Timeframe Selection / Anchor Timeframe (Manual)); the other timeframes' anchors are ignored. Choose a real swing pivot you can identify on the chart, and re-check it if you change the ZigZag Period, since a different Period may produce different pivots.")
last_verified_leg_1d = input.int(5, "", minval = 1, maxval = 5, group = grp_leg, inline = '1D',
     tooltip = "Phase number (1-5) assigned to the 1D anchor pivot above. Neighboring pivots continue the repeating 1-2-3-4-5 cycle in both directions (older pivots count down, newer ones count up, wrapping from 5 back to 1), and newly confirmed pivots keep extending the count automatically. Only used when the active anchor timeframe is 1d.")

anchor_time_1w = input.time(timestamp("2024-01-01 00:00"), "Pivot⚓ (1W)", group = grp_leg, inline = '1W',
     tooltip = "Date and time of a pivot whose phase number you have verified on the 1W timeframe. When the counter seeds itself it snaps to the ZigZag pivot closest in time to this timestamp, uses it as the numbering reference, then labels every other pivot 1-5 in a repeating cycle forward and backward from it. Only used when the active anchor timeframe is 1w (set by Anchor Timeframe Selection / Anchor Timeframe (Manual)); the other timeframes' anchors are ignored. Choose a real swing pivot you can identify on the chart, and re-check it if you change the ZigZag Period, since a different Period may produce different pivots.")
last_verified_leg_1w = input.int(1, "", minval = 1, maxval = 5, group = grp_leg, inline = '1W',
     tooltip = "Phase number (1-5) assigned to the 1W anchor pivot above. Neighboring pivots continue the repeating 1-2-3-4-5 cycle in both directions (older pivots count down, newer ones count up, wrapping from 5 back to 1), and newly confirmed pivots keep extending the count automatically. Only used when the active anchor timeframe is 1w.")

anchor_time_1m = input.time(timestamp("2024-01-01 00:00"), "Pivot⚓ (1M)", group = grp_leg, inline = '1M',
     tooltip = "Date and time of a pivot whose phase number you have verified on the 1M timeframe. When the counter seeds itself it snaps to the ZigZag pivot closest in time to this timestamp, uses it as the numbering reference, then labels every other pivot 1-5 in a repeating cycle forward and backward from it. Only used when the active anchor timeframe is 1m (set by Anchor Timeframe Selection / Anchor Timeframe (Manual)); the other timeframes' anchors are ignored. Choose a real swing pivot you can identify on the chart, and re-check it if you change the ZigZag Period, since a different Period may produce different pivots.")
last_verified_leg_1m = input.int(1, "", minval = 1, maxval = 5, group = grp_leg, inline = '1M',
     tooltip = "Phase number (1-5) assigned to the 1M anchor pivot above. Neighboring pivots continue the repeating 1-2-3-4-5 cycle in both directions (older pivots count down, newer ones count up, wrapping from 5 back to 1), and newly confirmed pivots keep extending the count automatically. Only used when the active anchor timeframe is 1m.")

f_tfMatches(sel) =>
    switch sel
        "1h" => timeframe.isintraday and timeframe.multiplier == 60
        "4h" => timeframe.isintraday and timeframe.multiplier == 240
        "1d" => timeframe.isdaily and timeframe.multiplier == 1
        "1w" => timeframe.isweekly and timeframe.multiplier == 1
        "1m" => timeframe.ismonthly and timeframe.multiplier == 1
        => false

f_detectTf() =>
    timeframe.isintraday and timeframe.multiplier == 60 ? "1h" :
     timeframe.isintraday and timeframe.multiplier == 240 ? "4h" :
     timeframe.isdaily and timeframe.multiplier == 1 ? "1d" :
     timeframe.isweekly and timeframe.multiplier == 1 ? "1w" :
     timeframe.ismonthly and timeframe.multiplier == 1 ? "1m" :
     "none"

anchor_tf_mode = input.string("Manual", "Anchor Timeframe Selection", options = ["Manual", "Automatic"], group = grp_leg,
     tooltip = "Manual: the 'Anchor Timeframe' picker below chooses which saved anchor/leg# setup is active, regardless of what timeframe the chart is actually on — the counter only displays when the chart happens to match your pick. Automatic: the script detects the chart's current timeframe itself and switches to that timeframe's saved anchor/leg# automatically, so the same instance keeps working as you flip between 1h/4h/1d/1w/1m charts with no manual switching. On a timeframe outside those 5 presets, Automatic has no saved anchor to use and the counter stays silent, same as an unmatched Manual pick.")
anchor_tf_manual = input.string("1h", "Anchor Timeframe (Manual)", options = ["1h", "4h", "1d", "1w", "1m"], group = grp_leg,
     tooltip = "Only used when Anchor Timeframe Selection above is set to Manual. The chart timeframe this anchor/leg-numbering setup was built for. Picking a timeframe here selects which anchor time above is active, and the counter (labels + anchor marker) only displays when the chart is actually on this timeframe — so the same indicator instance stays silent and uncluttered on every other timeframe instead of numbering pivots that don't correspond to this setup.")

detected_tf = f_detectTf()
anchor_tf = anchor_tf_mode == "Automatic" ? detected_tf : anchor_tf_manual

anchor_time = switch anchor_tf
    "1h" => anchor_time_1h
    "4h" => anchor_time_4h
    "1d" => anchor_time_1d
    "1w" => anchor_time_1w
    "1m" => anchor_time_1m
    => anchor_time_1h

tf_matches = f_tfMatches(anchor_tf)

last_verified_leg = switch anchor_tf
    "1h" => last_verified_leg_1h
    "4h" => last_verified_leg_4h
    "1d" => last_verified_leg_1d
    "1w" => last_verified_leg_1w
    "1m" => last_verified_leg_1m
    => last_verified_leg_1h
show_anchor_marker = input.bool(true, "Mark Anchor Pivot", group = grp_leg,
     tooltip = "Draws a small ⚓ marker on the pivot that was snapped to as the anchor, so you can confirm the right point was picked.")
char_style = input.string("①②③④⑤", "Numbering Style", options = ["①②③④⑤", "❶❷❸❹❺", "Ⅰ Ⅱ Ⅲ Ⅳ Ⅴ", "1️⃣2️⃣3️⃣4️⃣5️⃣", "₍₁₎ ₍₂₎ ₍₃₎ ₍₄₎ ₍₅₎", "⑴ ⑵ ⑶ ⑷ ⑸"], group = grp_leg,
     tooltip = "Glyph set used for phase numbers 1-5 on the chart labels and in the Phase Statistics table headers. Some sets (especially the keycap style and the subscript / parenthesized styles) render at different sizes or shapes depending on your OS, browser and font, so pick the one that looks best on your setup.")
size_choice = input.string("Huge", "Label Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grp_leg,
     tooltip = "Size (Tiny to Huge) of the phase-number labels drawn on the chart. Does not affect table text; use Text Size in the Phase Statistics Table group for that.")

auto_dir_color = input.bool(true, "Auto-Color by Leg Direction", group = grp_leg,
     tooltip = "When enabled, each label's background and text use the Bullish/Bearish Label colors set below, based on whether that leg's price rose or fell from the prior one (background shown faded per the Fade % below). Disable to use the custom colors below instead.")
label_bull_color = input.color(color.rgb(0, 137, 123), 'Bullish Label Color', inline = 'lblcol', group = grp_leg,
     tooltip = "Color for bullish phases (legs that rise from their pivot to the next). Colors the number label text and its faded background when Auto-Color by Leg Direction is on. Also acts as the bullish color throughout the Phase Statistics table: Tendency Color text, the Tendency Background lookup, and the inverted colors on the Retracement and Extension target rows. Pairs with the Bearish Label Color to its right.")
label_bear_color = input.color(color.rgb(255, 153, 0), 'Bearish Label Color', inline = 'lblcol', group = grp_leg,
     tooltip = "Color for bearish phases (legs that fall from their pivot to the next). Colors the number label text and its faded background when Auto-Color by Leg Direction is on. Also acts as the bearish color throughout the Phase Statistics table: Tendency Color text, the Tendency Background lookup, and the inverted colors on the Retracement and Extension target rows. Pairs with the Bullish Label Color to its left.")
manual_bg_color = input.color(color.rgb(54, 58, 69, 50), "Custom Label Background Color", group = grp_leg,
     tooltip = "Background color of the number labels when Auto-Color by Leg Direction is off. Label Background Fade % below is applied on top and overrides any transparency set in this color picker.")
manual_txt_color = input.color(color.rgb(255, 255, 255, 50), "Custom Label Text Color", group = grp_leg,
     tooltip = "Text color of the number labels when Auto-Color by Leg Direction is off. Any transparency set in this color picker is kept as-is.")
bg_fade_pct = input.int(90, "Label Background Fade %", minval = 0, maxval = 100, group = grp_leg,
     tooltip = "Transparency of the number label background: 0 is fully opaque, 100 is fully transparent (only the number glyph shows). Applies to both the automatic direction colors and the custom background color, overriding the transparency of the picked color.")
label_pos = input.string("Leg Midpoint", "Label Position", options = ["Pivot", "Leg Midpoint"], group = grp_leg,
     tooltip = "Pivot: label sits on the pivot point itself (original behavior). Leg Midpoint: label sits halfway (in both time and price) along the leg this pivot starts — the leg connecting it to the next numbered pivot. The newest numbered label tracks the leg's live in-progress endpoint until that leg is confirmed, so it walks smoothly toward the eventual midpoint instead of jumping once the leg freezes.")

lbl_size = f_labelSize(size_choice)

f_legChar(num, style) =>
    style1 = array.from("①", "②", "③", "④", "⑤")
    style2 = array.from("❶", "❷", "❸", "❹", "❺")
    style3 = array.from("Ⅰ", "Ⅱ", "Ⅲ", "Ⅳ", "Ⅴ")
    style4 = array.from("1️⃣", "2️⃣", "3️⃣", "4️⃣", "5️⃣")
    style5 = array.from("₍₁₎", "₍₂₎", "₍₃₎", "₍₄₎", "₍₅₎")
    style6 = array.from("⑴", "⑵", "⑶", "⑷", "⑸")
    chosen = style == "①②③④⑤" ? style1 : style == "❶❷❸❹❺" ? style2 : style == "Ⅰ Ⅱ Ⅲ Ⅳ Ⅴ" ? style3 : style == "1️⃣2️⃣3️⃣4️⃣5️⃣" ? style4 : style == "₍₁₎ ₍₂₎ ₍₃₎ ₍₄₎ ₍₅₎" ? style5 : style6
    array.get(chosen, num - 1)

f_invertTendencyCol(col) =>
    col == label_bull_color ? label_bear_color : col == label_bear_color ? label_bull_color : col

var array<int>   leg_bar_arr   = array.new_int(0)
var array<float> leg_price_arr = array.new_float(0)
var array<int>   leg_num_arr   = array.new_int(0)

var bool seeded             = false
var int  last_recorded_bar  = na
var int  last_assigned_num  = na
var label anchor_label      = na
var int  anchor_bar_saved   = na
var float anchor_price_saved = na
var bool  anchor_is_high    = false

if barstate.islast and not seeded and array.size(z) >= 4
    num_pairs = int(array.size(z) / 2)

    anchor_idx = 2
    best_diff = float(na)
    for i = 1 to num_pairs - 1
        t = array.get(z, i * 2 + 1)
        diff = math.abs(t - anchor_time)
        if na(best_diff) or diff < best_diff
            best_diff := diff
            anchor_idx := i * 2

    neighbor_idx = anchor_idx + 2 <= array.size(z) - 2 ? anchor_idx + 2 : (anchor_idx - 2 >= 0 ? anchor_idx - 2 : anchor_idx)
    anchor_is_high := array.get(z, anchor_idx) > array.get(z, neighbor_idx)

    for idx = (num_pairs - 1) * 2 to 2 by 2
        num = 0
        if idx > anchor_idx
            step_back = int((idx - anchor_idx) / 2)
            num := ((last_verified_leg - 1 - step_back) % 5 + 5) % 5 + 1
        else
            step_fwd = int((anchor_idx - idx) / 2)
            num := (last_verified_leg - 1 + step_fwd) % 5 + 1
        array.push(leg_bar_arr, int(array.get(z, idx + 1)))
        array.push(leg_price_arr, array.get(z, idx))
        array.push(leg_num_arr, num)

    anchor_bar_saved := int(array.get(z, anchor_idx + 1))
    anchor_price_saved := array.get(z, anchor_idx)

    last_recorded_bar := int(array.get(z, 3))
    last_assigned_num := array.get(leg_num_arr, array.size(leg_num_arr) - 1)
    seeded := true

if seeded and array.size(z) >= 4
    frozen_bar = int(array.get(z, 3))
    if frozen_bar != last_recorded_bar
        frozen_px = array.get(z, 2)
        next_num = last_assigned_num % 5 + 1
        array.push(leg_bar_arr, frozen_bar)
        array.push(leg_price_arr, frozen_px)
        array.push(leg_num_arr, next_num)
        last_assigned_num := next_num
        last_recorded_bar := frozen_bar

var array<label> leg_labels = array.new_label()
if barstate.islast
    while array.size(leg_labels) > 0
        label.delete(array.pop(leg_labels))
    label.delete(anchor_label)
    anchor_label := na

    if tf_matches
        if array.size(leg_num_arr) > 0
            last_leg_i = array.size(leg_num_arr) - 1
            for i = 0 to last_leg_i
                bx  = array.get(leg_bar_arr, i)
                px  = array.get(leg_price_arr, i)
                num = array.get(leg_num_arr, i)

                dir_color = i == last_leg_i ? label_bull_color : (array.get(leg_price_arr, i + 1) > px ? label_bull_color : label_bear_color)
                bg_col  = auto_dir_color ? color.new(dir_color, bg_fade_pct) : color.new(manual_bg_color, bg_fade_pct)
                txt_col = auto_dir_color ? dir_color : manual_txt_color

                next_x = i < last_leg_i ? array.get(leg_bar_arr, i + 1) : time
                next_y = i < last_leg_i ? array.get(leg_price_arr, i + 1) : close
                lbl_x = label_pos == "Leg Midpoint" ? int(math.round((bx + next_x) / 2.0)) : bx
                lbl_y = label_pos == "Leg Midpoint" ? (px + next_y) / 2.0 : px

                lbl = label.new(lbl_x, lbl_y, f_legChar(num, char_style),
                     xloc = xloc.bar_time,
                     style = label.style_label_center,
                     color = bg_col,
                     textcolor = txt_col,
                     size = lbl_size)
                array.push(leg_labels, lbl)

        if show_anchor_marker and not na(anchor_bar_saved)
            anchor_buf = ta.atr(20) * 2
            anchor_y = anchor_is_high ? anchor_price_saved + anchor_buf : anchor_price_saved - anchor_buf
            anchor_style = anchor_is_high ? label.style_label_down : label.style_label_up
            anchor_label := label.new(anchor_bar_saved, anchor_y, "⚓" + str.tostring(last_verified_leg) + " " + anchor_tf,
                 xloc = xloc.bar_time,
                 style = anchor_style,
                 color = color.new(color.blue, 0),
                 textcolor = color.white,
                 size = size.small)

var array<line> current_leg_lines = array.new_line()
var array<label> current_leg_markers = array.new_label()
var float last_pivot_y = na
var int last_pivot_x = na
if array.size(z) >= 2
    while array.size(current_leg_lines) > 0
        line.delete(array.pop(current_leg_lines))
    while array.size(current_leg_markers) > 0
        label.delete(array.pop(current_leg_markers))
    last_pivot_y := array.get(z, 0)
    last_pivot_x := int(array.get(z, 1))
    live_leg_color = close > last_pivot_y ? bull_color : bear_color
    f_drawLeg(current_leg_lines, last_pivot_x, last_pivot_y, time, close, live_leg_color, w, last_leg_style)

    if show_leg_markers
        marker_size = f_labelSize(marker_size_choice)
        start_marker = label.new(last_pivot_x, last_pivot_y, "◯",
             xloc = xloc.bar_time,
             style = label.style_label_center,
             color = color.new(color.white, 100),
             textcolor = live_leg_color,
             size = marker_size)
        end_marker = label.new(time, close, "◯",
             xloc = xloc.bar_time,
             style = label.style_label_center,
             color = color.new(color.white, 100),
             textcolor = live_leg_color,
             size = marker_size)
        array.push(current_leg_markers, start_marker)
        array.push(current_leg_markers, end_marker)

p0_bar = array.size(zbar) > 0 ? array.get(zbar, 0) : int(na)
p1_bar = array.size(zbar) > 1 ? array.get(zbar, 1) : int(na)

leg_window_len = na(p1_bar) ? int(na) : bar_index - p1_bar + 1
leg_high = na(leg_window_len) ? float(na) : ta.highest(high, leg_window_len)
leg_low = na(leg_window_len) ? float(na) : ta.lowest(low, leg_window_len)

active_window_len = na(p0_bar) ? int(na) : bar_index - p0_bar + 1
active_leg_high = na(active_window_len) ? float(na) : ta.highest(high, active_window_len)
active_leg_low = na(active_window_len) ? float(na) : ta.lowest(low, active_window_len)

prev_confirmed_leg_bars = array.size(zbar) >= 2 ? array.get(zbar, 0) - array.get(zbar, 1) : int(na)

var int current_direction = 0
var float current_length = 0.0
var float current_slope = 0.0
if not na(last_pivot_x)
    current_direction := close > last_pivot_y ? 1 : -1
    current_length := math.abs(close - last_pivot_y)
    dx = math.max(1.0, float(time - last_pivot_x))
    current_slope := (close - last_pivot_y) / dx

var line extension_line1 = na
var line extension_line2 = na
if array.size(z) >= 2 and show_projection and not na(current_slope)
    line.delete(extension_line1)
    line.delete(extension_line2)
    start_x = time
    start_y = close
    ms_per_bar = timeframe.in_seconds() * 1000
    max_future_ms = 500 * ms_per_bar
    max_x = start_x + max_future_ms
    last_zigzag_length = current_length
    projection_length1 = current_direction == 1 ? (avg_bullish_length > last_zigzag_length ? avg_bullish_length - last_zigzag_length : 0) : (avg_bearish_length > last_zigzag_length ? avg_bearish_length - last_zigzag_length : 0)
    abs_slope_current = math.max(1e-10, math.abs(current_slope))
    proj_line_style = proj_style == 'Solid' ? line.style_solid : proj_style == 'Dashed' ? line.style_dashed : line.style_dotted
    if projection_length1 > 0
        raw_dx1 = int(math.round(projection_length1 / abs_slope_current))
        dx1 = math.max(1, math.min(raw_dx1, max_x - start_x))
        end_x1 = start_x + dx1
        end_y1 = start_y + current_slope * dx1
        seg1_color = current_direction == 1 ? proj_bull_color : proj_bear_color
        extension_line1 := line.new(x1 = start_x, y1 = start_y, x2 = end_x1, y2 = end_y1, xloc = xloc.bar_time, extend = extend.none, color = seg1_color, width = proj_width, style = proj_line_style)
        projection_length2 = current_direction == 1 ? avg_bearish_length : avg_bullish_length
        projection_slope2 = current_direction == 1 ? avg_bearish_slope : avg_bullish_slope
        abs_slope2 = math.max(1e-10, math.abs(projection_slope2))
        raw_dx2 = int(math.round(projection_length2 / abs_slope2))
        dx2 = math.max(1, math.min(raw_dx2, max_x - end_x1))
        end_x2 = end_x1 + dx2
        end_y2 = end_y1 + projection_slope2 * dx2
        seg2_color = current_direction == 1 ? proj_bear_color : proj_bull_color
        extension_line2 := line.new(x1 = end_x1, y1 = end_y1, x2 = end_x2, y2 = end_y2, xloc = xloc.bar_time, extend = extend.none, color = seg2_color, width = proj_width, style = proj_line_style)
    else
        projection_length2 = current_direction == 1 ? avg_bearish_length : avg_bullish_length
        projection_slope2 = current_direction == 1 ? avg_bearish_slope : avg_bullish_slope
        abs_slope2 = math.max(1e-10, math.abs(projection_slope2))
        raw_dx2 = int(math.round(projection_length2 / abs_slope2))
        dx2 = math.max(1, math.min(raw_dx2, max_x - start_x))
        end_x2 = start_x + dx2
        end_y2 = start_y + projection_slope2 * dx2
        seg2_color = current_direction == 1 ? proj_bear_color : proj_bull_color
        extension_line2 := line.new(x1 = start_x, y1 = start_y, x2 = end_x2, y2 = end_y2, xloc = xloc.bar_time, extend = extend.none, color = seg2_color, width = proj_width, style = proj_line_style)

// === 📊 PHASE STATISTICS TABLE ===
grp_stats = "📊 Phase Statistics Table"
show_stats_table = input.bool(true, "Show Table", group = grp_stats,
     tooltip = "Master switch for the Phase Statistics table. Turn it off to hide the table entirely; all other table settings are then ignored. The table is only drawn once enough ZigZag history exists (at least the two most recent pivots).")
stats_orientation = input.string("Vertical", "Orientation", options = ["Vertical", "Horizontal"], group = grp_stats,
     tooltip = "Vertical: each leg is a column and each metric is a row (taller table). Horizontal: each leg is a row and each metric is a column (wider, shorter table). The data shown is identical either way.")
stats_position = input.string("Bottom Left", "Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = grp_stats,
     tooltip = "Chart corner or edge the table is anchored to. For finer control than these nine presets, use the padding inputs in the Table Position Fine Tunning group.")
stats_text_size = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grp_stats,
     tooltip = "Text size (Tiny to Huge) for the table's cells and headers. Single-line leg-number headers are always drawn at Normal size for visibility regardless of this setting; the two-line Unconfirmed and Projected headers do follow it.")
stats_header_bg = input.color(color.rgb(19, 29, 58, 30), "Header Background", inline = 'statshdr', group = grp_stats,
     tooltip = "Background color of the table's header cells: the title bar, the Metric / Phase corner cell, the leg column or row headers, and the metric labels. Pairs with the Header Text color to its right.")
stats_header_txt = input.color(color.rgb(104, 138, 212), "Header Text", inline = 'statshdr', group = grp_stats,
     tooltip = "Text color of the table's header cells: the title bar, the Metric / Phase corner cell, the leg column or row headers, and the metric labels. Pairs with the Header Background color to its left.")
stats_cell_bg = input.color(color.rgb(13, 20, 39, 30), "Cell Background", inline = 'statscell', group = grp_stats,
     tooltip = "Background color of the value cells. Used as-is in the White and Tendency Color styles, and as the fallback in the Tendency Background style for cells that have no leg direction yet. Pairs with the Cell Text color to its right.")
stats_cell_txt = input.color(color.rgb(255, 255, 255), "Cell Text", inline = 'statscell', group = grp_stats,
     tooltip = "Text color of the value cells in the White style. Also the fallback text color for cells that have no leg direction yet. Pairs with the Cell Background color to its left.")
stats_dir_text_mode = input.string("Tendency Color", "Value Cell Style", options = ["White", "Tendency Color", "Tendency Background"], group = grp_stats,
     tooltip = "Controls how every value cell in the table (Dir, High/Low, Growth, Bars, Retracement, etc.) is colored, based on which leg that cell belongs to. White: flat 'Cell Background' with flat 'Cell Text'. Tendency Color: flat 'Cell Background' with text colored by that leg's own Bullish/Bearish Label Color. Tendency Background: the cell's background itself is colored by that leg's Bullish/Bearish color (set below), with a single flat text color (set below) on top.")
stats_tendbg_bull_color = input.color(color.rgb(0, 137, 123, 85), "Tendency BG: Bullish", inline = 'tendbgcol', group = grp_stats,
     tooltip = "Only used when Value Cell Style above is set to Tendency Background. Background color for value cells belonging to a bullish leg.")
stats_tendbg_bear_color = input.color(color.rgb(255, 153, 0, 85), "Tendency BG: Bearish", inline = 'tendbgcol', group = grp_stats,
     tooltip = "Only used when Value Cell Style above is set to Tendency Background. Background color for value cells belonging to a bearish leg.")
stats_tendbg_txt_color = input.color(color.white, "Tendency BG: Text Color", group = grp_stats,
     tooltip = "Only used when Value Cell Style above is set to Tendency Background. Flat text color drawn over the colored backgrounds above.")
stats_border_color = input.color(color.rgb(0, 0, 0), "Border Color", group = grp_stats,
     tooltip = "Color of the 1-pixel grid lines between table cells. Use a fully transparent color for a borderless look.")
retrace_bar_style = input.string("⁞ / .", "Retracement Bar Glyphs", options = ["▩ / ▢", "▮ / ▯", "⁞ / .", "● / ◌"], group = grp_stats,
     tooltip = "Filled / empty character pair used to draw the 10-segment retracement scale in the table.")
show_retrace_bar = input.bool(true, "Show Retracement Progress Bar", group = grp_stats,
     tooltip = "When enabled, every Retracement value gets its own extra cell holding just the 10-segment progress bar, right next to its %/$ value. Disable to omit the bar entirely and show only the % and $ retracement values.")
num_legs_shown = input.int(7, "Legs Shown", minval = 2, maxval = 10, group = grp_stats,
     tooltip = "How many legs the Phase Statistics table displays, counting the active (still-forming) leg plus confirmed legs going backward in time. 2 shows just Active + Previous. Higher values add more historical, fully-closed legs as extra columns to the left (Vertical orientation) or extra rows (Horizontal orientation) — each computed from fixed pivot-to-pivot data, showing — for any leg beyond how much zigzag history has formed yet.")
show_retrace_targets = input.bool(true, "Show Retracement % Targets", group = grp_stats,
     tooltip = "Adds 3 separate 'Retracement %' cells (40%, 50%, 60%) for every leg shown in the table, each giving the price at that retracement level of the leg's own range (measured from its more recent pivot back toward its older one; the Active leg uses its forming pivot and the current price).")
show_reached_marker = input.bool(true, "Mark Reached Retracement Levels", group = grp_stats,
     tooltip = "When enabled, a Retracement % target cell (40/50/60%) gets the Reached Marker Glyph appended to its price once price has actually retraced that far. Historical legs use their final, confirmed retracement; the Previous leg uses the live Active Retracement %; the Active leg's own targets are forward-looking projections and never show as reached.")
reached_marker_glyph = input.string("✓", "Reached Marker Glyph", options = ["▶", "→", "✓", "★"], group = grp_stats,
     tooltip = "Symbol appended to a Retracement % target price once price has retraced at least that far. Only visible while Mark Reached Retracement Levels is enabled.")
highlight_reached = input.bool(true, "Highlight Reached Cells", group = grp_stats,
     tooltip = "When enabled, every table cell that carries the Reached Marker Glyph is also highlighted so reached levels stand out at a glance. Requires Mark Reached Retracement Levels to be on, since the highlight is applied to the cells that show the marker. The look is chosen by Highlight Style below.")
reached_hl_style = input.string("Brighter Tone", "Highlight Style", options = ["Brighter Tone", "Solid Fill", "Custom Color"], group = grp_stats,
     tooltip = "Brighter Tone: the cell keeps its own leg color but is drawn lighter — in Tendency Color style the text is brightened and a soft tint of that same color fills the cell; in Tendency Background style the cell background becomes stronger and brighter; in White style the background is lightened. Solid Fill: the cell is filled with its leg's color at full strength (black text over it in Tendency Color / White styles). Custom Color: the cell uses the flat Highlight Background / Highlight Text colors below, regardless of direction.")
reached_hl_strength = input.int(40, "Highlight Intensity %", minval = 5, maxval = 100, group = grp_stats,
     tooltip = "Only used by the Brighter Tone style. How strongly reached cells are brightened: higher values give a lighter text/background and a more opaque tint, lower values give a subtler glow.")
reached_hl_bg = input.color(color.rgb(255, 235, 59, 20), "Highlight Background", inline = 'reachedhl', group = grp_stats,
     tooltip = "Only used by the Custom Color style. Flat background color drawn behind reached cells. Pairs with the Highlight Text color to its right.")
reached_hl_txt = input.color(color.black, "Highlight Text", inline = 'reachedhl', group = grp_stats,
     tooltip = "Only used by the Custom Color style. Flat text color drawn over the Highlight Background of reached cells. Pairs with the Highlight Background color to its left.")
show_velocity = input.bool(true, "Show Velocity ($/bar)", inline = 'advmetrics1', group = grp_stats,
     tooltip = "Adds each leg's Velocity: its Growth divided by its Bars, i.e. how many dollars per bar it moved.")
show_vs_avg_size = input.bool(true, "Show Size vs Avg", inline = 'advmetrics1', group = grp_stats,
     tooltip = "Adds each leg's Growth compared to the average bullish/bearish leg size on the chart — the same averages the Adaptive Projection engine uses — as a signed percentage difference.")
show_vs_avg_bars = input.bool(true, "Show Bars vs Avg", inline = 'advmetrics2', group = grp_stats,
     tooltip = "Adds each leg's Bars compared to the average bullish/bearish leg duration on the chart, as a signed percentage difference.")
show_xatr = input.bool(true, "Show ATR-Normalized Size (xATR)", inline = 'advmetrics2', group = grp_stats,
     tooltip = "Adds each leg's Growth divided by the ATR(20) recorded at that leg's own starting pivot, making leg sizes comparable across different volatility regimes.")
show_ratio_to_prior = input.bool(true, "Show Ratio to Prior Leg", group = grp_stats,
     tooltip = "Adds each leg's size as a ratio of the leg immediately before it (older), tagged with the nearest canonical Fibonacci ratio when close enough (e.g. \"0.62x (≈.618)\").")
show_extension_targets = input.bool(true, "Show Extension % Targets (127/162/200%)", group = grp_stats,
     tooltip = "Adds 3 separate 'Extension %' cells (127.2%, 161.8%, 200%) for every leg shown in the table, projecting price beyond that leg's own range in the same direction — the counterpart to the Retracement % Targets above, for when price continues past the prior pivot instead of reversing.")

// 📐 TABLE POSITION PADDING
// Adds an invisible, fully transparent padding row above and below, and a
// padding column to the left and right of, the table's actual content —
// each merged into a single cell spanning its whole side, so no extra grid
// lines show through. Because the table is always anchored to one
// corner/edge (per the Position input above), growing one of these padding
// cells changes the table's total footprint and shifts where the visible
// content lands relative to that anchor — a fine-grained way to nudge the
// table without touching the coarse Position preset. Defaults to 0 (no
// padding, i.e. today's behavior). ▦▲ ▼▦ ►▦ ▦◄
//
// Claude Instructions:
// The pasted script shows a table, add a row at the top, bottom and left and right side,
// the extra rows will be used as padding to manually move the table from the original position up,
// down, right or left. Merge the cells on the added rows/columns and make them completely
// transparent. Allow the user to increase the size of the columns and/or rows in order to
// fine tune the location of the table on the chart.

grp_pad = "📐 Table Position Fine Tunning"
pad_top = input.float(0, "▼▦", minval = 0, maxval = 100, inline = 'padTB', group = grp_pad,
     tooltip = "Height (as a % of the table) of an invisible row added above the table's content. Tune this to nudge the table's on-screen position.")
pad_bottom = input.float(0, "▦▲", minval = 0, maxval = 100, inline = 'padTB', group = grp_pad,
     tooltip = "Height (as a % of the table) of an invisible row added below the table's content. Tune this to nudge the table's on-screen position.")
pad_left = input.float(0, "►▦", minval = 0, maxval = 100, inline = 'padLR', group = grp_pad,
     tooltip = "Width (as a % of the table) of an invisible column added to the left of the table's content. Tune this to nudge the table's on-screen position.")
pad_right = input.float(0, "▦◄", minval = 0, maxval = 100, inline = 'padLR', group = grp_pad,
     tooltip = "Width (as a % of the table) of an invisible column added to the right of the table's content. Tune this to nudge the table's on-screen position.")

f_tablePos(sel) =>
    switch sel
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_statsTextSize(sel) =>
    sel == "Tiny" ? size.tiny : sel == "Small" ? size.small : sel == "Normal" ? size.normal : sel == "Large" ? size.large : size.huge

stats_size = f_statsTextSize(stats_text_size)

f_addCommas(numStr) =>
    len = str.length(numStr)
    result = ""
    cnt = 0
    for i = len - 1 to 0
        ch = str.substring(numStr, i, i + 1)
        result := ch + result
        cnt += 1
        if cnt % 3 == 0 and i != 0
            result := "," + result
    result

f_fmtPrice(price) =>
    sign = price < 0 ? "-" : ""
    rounded = math.round(math.abs(price))
    intStr = str.tostring(rounded, "#")
    sign + "$" + f_addCommas(intStr)

f_fmtPct(pct) =>
    str.tostring(pct, "#.#") + "%"

// Signed percentage difference, e.g. "+18%" or "-30%", for the Size/Bars vs Average metrics.
f_fmtPctDiff(pct) =>
    na(pct) ? "—" : (pct >= 0 ? "+" : "") + str.tostring(pct, "#.#") + "%"

// Plain ratio, e.g. "0.62x", for the ATR-Normalized Size and Ratio-to-Prior-Leg metrics.
f_fmtRatio(r) =>
    na(r) ? "—" : str.tostring(r, "#.##") + "x"

// Tags a ratio with the nearest canonical Fibonacci ratio when it's close enough to be
// meaningful (e.g. "0.62x (≈.618)"), otherwise returns "". Used by Ratio to Prior Leg.
f_nearestFibTag(r) =>
    na(r) ? "" :
     math.abs(r - 0.382) <= 0.05 ? " (≈.382)" :
     math.abs(r - 0.5)   <= 0.05 ? " (≈.5)" :
     math.abs(r - 0.618) <= 0.05 ? " (≈.618)" :
     math.abs(r - 0.786) <= 0.05 ? " (≈.786)" :
     math.abs(r - 1.0)   <= 0.05 ? " (≈1.0)" :
     math.abs(r - 1.272) <= 0.05 ? " (≈1.272)" :
     math.abs(r - 1.618) <= 0.05 ? " (≈1.618)" :
     math.abs(r - 2.0)   <= 0.08 ? " (≈2.0)" :
     math.abs(r - 2.618) <= 0.08 ? " (≈2.618)" : ""

// Three target cells at arbitrary ratios (r1/r2/r3) of a leg spanning newPx (more recent end)
// -> oldPx (older end). Ratios 0-1 land within the leg's own range (retracement); ratios > 1
// project beyond the older end in the same direction (extension). Works regardless of whether
// the leg was bullish or bearish, and degrades to em-dashes when either endpoint isn't available
// yet. achieved_pct is the actual % already reached against this same leg's range (na when not
// applicable, e.g. the Active leg's own forward-looking targets) — any tier at or below it gets
// the Reached Marker Glyph appended.
f_levelTexts(newPx, oldPx, r1, r2, r3, achieved_pct) =>
    p1 = newPx - (newPx - oldPx) * r1
    p2 = newPx - (newPx - oldPx) * r2
    p3 = newPx - (newPx - oldPx) * r3
    marker = show_reached_marker ? " " + reached_marker_glyph : ""
    t1 = na(p1) ? "—" : f_fmtPrice(p1) + (not na(achieved_pct) and achieved_pct >= r1 * 100 ? marker : "")
    t2 = na(p2) ? "—" : f_fmtPrice(p2) + (not na(achieved_pct) and achieved_pct >= r2 * 100 ? marker : "")
    t3 = na(p3) ? "—" : f_fmtPrice(p3) + (not na(achieved_pct) and achieved_pct >= r3 * 100 ? marker : "")
    [t1, t2, t3]

// Retracement % targets (40/50/60%, within the leg's own range).
f_retraceLevelTexts(newPx, oldPx, achieved_pct) =>
    f_levelTexts(newPx, oldPx, 0.40, 0.50, 0.60, achieved_pct)

// Extension % targets (127.2/161.8/200%, beyond the leg's own range).
f_extensionLevelTexts(newPx, oldPx, achieved_pct) =>
    f_levelTexts(newPx, oldPx, 1.272, 1.618, 2.00, achieved_pct)

f_retraceBar(pct, glyph_style) =>
    filled = math.max(0, math.min(10, int(math.round(pct / 10))))
    fill_ch = glyph_style == "▩ / ▢" ? "▩" : glyph_style == "▮ / ▯" ? "▮" : glyph_style == "⁞ / ." ? "⁞" : "●"
    empty_ch = glyph_style == "▩ / ▢" ? "▢" : glyph_style == "▮ / ▯" ? "▯" : glyph_style == "⁞ / ." ? "." : "◌"
    bar = ""
    for i = 1 to 10
        bar := bar + (i <= filled ? fill_ch : empty_ch)
    bar

// Maps a leg's tendency color (either label_bull_color, label_bear_color, or a
// neutral fallback such as stats_cell_txt) to the corresponding user-customizable
// background color for the "Tendency Background" Value Cell Style. Neutral colors
// (no leg direction yet) fall back to the flat stats_cell_bg.
f_tendBgColor(col) =>
    col == label_bull_color ? stats_tendbg_bull_color : col == label_bear_color ? stats_tendbg_bear_color : stats_cell_bg

// Lightens a color toward white by pct (0-100) while preserving its own transparency.
// Used by the "Brighter Tone" style of Highlight Reached Cells.
f_brighten(col, pct) =>
    k = math.max(0.0, math.min(100.0, pct)) / 100.0
    color.rgb(color.r(col) + (255 - color.r(col)) * k, color.g(col) + (255 - color.g(col)) * k, color.b(col) + (255 - color.b(col)) * k, color.t(col))

// Draws the transparent padding frame (top/bottom rows, left/right
// columns) around a table's content block. `total_cols`/`total_rows` are
// the FULL grid dimensions — content plus the 2 extra padding columns and
// 2 extra padding rows the caller already added when sizing the table.
// The top/bottom rows each span the table's full width (so they also cover
// the top-left/top-right/bottom-left/bottom-right corners); the left/right
// columns then only need to span the remaining middle rows.
f_addTablePadding(t, total_cols, total_rows, top_h, bottom_h, left_w, right_w) =>
    transparent = color.new(color.black, 100)
    table.cell(t, 0, 0, "", height = top_h, bgcolor = transparent)
    table.merge_cells(t, 0, 0, total_cols - 1, 0)
    table.cell(t, 0, total_rows - 1, "", height = bottom_h, bgcolor = transparent)
    table.merge_cells(t, 0, total_rows - 1, total_cols - 1, total_rows - 1)
    table.cell(t, 0, 1, "", width = left_w, bgcolor = transparent)
    table.merge_cells(t, 0, 1, 0, total_rows - 2)
    table.cell(t, total_cols - 1, 1, "", width = right_w, bgcolor = transparent)
    table.merge_cells(t, total_cols - 1, 1, total_cols - 1, total_rows - 2)

var table statsTable = na
if barstate.islast
    table.delete(statsTable)
    if show_stats_table and not na(leg_high) and not na(leg_low)
        bars_in_leg = na(p0_bar) ? 0 : bar_index - p0_bar + 1
        leg_size = leg_high - leg_low

        prev_leg_num = seeded ? last_assigned_num : int(na)
        active_leg_num = seeded ? (last_assigned_num % 5 + 1) : na

        p1_price = array.size(z) >= 4 ? array.get(z, 2) : float(na)
        leg_tendency = na(p1_price) ? 0 : (close > p1_price ? 1 : close < p1_price ? -1 : 0)
        tendency_txt = leg_tendency == 1 ? "UP" : leg_tendency == -1 ? "DN" : "—"
        tendency_col = leg_tendency == 1 ? label_bull_color : leg_tendency == -1 ? label_bear_color : stats_cell_txt

        prior_leg_size = array.size(z) >= 4 ? math.abs(array.get(z, 0) - array.get(z, 2)) : na
        retrace_dollar = current_length
        retrace_pct = not na(prior_leg_size) and prior_leg_size > 0 ? (retrace_dollar / prior_leg_size) * 100 : na
        retrace_pct_txt = na(retrace_pct) ? "—" : f_fmtPct(retrace_pct)
        retrace_dollar_txt = na(prior_leg_size) ? "—" : f_fmtPrice(retrace_dollar)
        retrace_bar_txt = na(retrace_pct) ? "" : f_retraceBar(retrace_pct, retrace_bar_style)

        // === Per-leg Retracement % targets (40/50/60% of that leg's own range), each its own cell ===
        // Previous confirmed leg (P1 -> P0); achieved_pct is the live Active Retracement % (retrace_pct),
        // since the active leg retracing this same P1->P0 range is exactly what that figure measures:
        [prev_retrace_40, prev_retrace_50, prev_retrace_60] = f_retraceLevelTexts(array.size(z) >= 4 ? array.get(z, 0) : float(na), array.size(z) >= 4 ? array.get(z, 2) : float(na), retrace_pct)

        confirmed_prior_size = array.size(z) >= 6 ? math.abs(array.get(z, 2) - array.get(z, 4)) : na
        unconf_retrace_dollar = array.size(z) >= 4 ? math.abs(close - array.get(z, 2)) : na
        unconf_retrace_pct = not na(confirmed_prior_size) and confirmed_prior_size > 0 and not na(unconf_retrace_dollar) ? (unconf_retrace_dollar / confirmed_prior_size) * 100 : na
        unconf_retrace_pct_txt = na(unconf_retrace_pct) ? "—" : f_fmtPct(unconf_retrace_pct)
        unconf_retrace_dollar_txt = na(unconf_retrace_dollar) or na(confirmed_prior_size) ? "—" : f_fmtPrice(unconf_retrace_dollar)
        unconf_retrace_bar_txt = na(unconf_retrace_pct) ? "" : f_retraceBar(unconf_retrace_pct, retrace_bar_style)

        // === Historical legs further left (leg index j: 2 = one left of "Previous", 3 = two left, ...) ===
        // num_legs_shown counts Active + Previous + these historical legs, so we loop j = 2..num_legs_shown-1.
        num_hist_legs = num_legs_shown - 1
        hist_prefix          = array.new_string(0)
        hist_tendency_txt     = array.new_string(0)
        hist_tendency_col     = array.new_color(0)
        hist_hilo_txt         = array.new_string(0)
        hist_growth_txt       = array.new_string(0)
        hist_bars_txt         = array.new_string(0)
        hist_retrace_txt      = array.new_string(0)
        hist_retrace_bar_txt  = array.new_string(0)
        hist_retrace_40       = array.new_string(0)
        hist_retrace_50       = array.new_string(0)
        hist_retrace_60       = array.new_string(0)
        hist_size_raw         = array.new_float(0)
        hist_velocity_txt     = array.new_string(0)
        hist_vs_avg_txt       = array.new_string(0)
        hist_bars_avg_txt     = array.new_string(0)
        hist_atr_txt          = array.new_string(0)
        hist_ratio_txt        = array.new_string(0)
        hist_ext_127          = array.new_string(0)
        hist_ext_162          = array.new_string(0)
        hist_ext_200          = array.new_string(0)

        for j = 2 to num_hist_legs
            idx_new = 2 * (j - 1)
            idx_old = 2 * j
            has_leg_j = array.size(z) >= idx_old + 2
            leg_num_j = seeded and array.size(leg_num_arr) >= j ? array.get(leg_num_arr, array.size(leg_num_arr) - j) : int(na)
            prefix_j = na(leg_num_j) ? "Leg-" + str.tostring(j) : f_legChar(leg_num_j, char_style)
            bars_j = has_leg_j and array.size(zbar) >= j + 1 ? array.get(zbar, j - 1) - array.get(zbar, j) : int(na)
            high_j = has_leg_j ? math.max(array.get(z, idx_new), array.get(z, idx_old)) : float(na)
            low_j  = has_leg_j ? math.min(array.get(z, idx_new), array.get(z, idx_old)) : float(na)
            size_j = has_leg_j ? math.abs(array.get(z, idx_new) - array.get(z, idx_old)) : float(na)
            tendency_j = has_leg_j ? (array.get(z, idx_new) > array.get(z, idx_old) ? 1 : -1) : 0
            tendency_txt_j = tendency_j == 1 ? "UP" : tendency_j == -1 ? "DN" : "—"
            tendency_col_j = tendency_j == 1 ? label_bull_color : tendency_j == -1 ? label_bear_color : stats_cell_txt
            hilo_txt_j = na(high_j) or na(low_j) ? "—" : f_fmtPrice(high_j) + "\n" + f_fmtPrice(low_j)
            growth_txt_j = na(size_j) ? "—" : f_fmtPrice(size_j)
            bars_txt_j = na(bars_j) ? "—" : str.tostring(bars_j)
            // retracement: how much the NEXT (more recent) confirmed leg retraced this one
            next_new_idx = 2 * (j - 2)
            next_dollar_j = array.size(z) > idx_new ? math.abs(array.get(z, next_new_idx) - array.get(z, idx_new)) : float(na)
            next_pct_j = has_leg_j and not na(next_dollar_j) and size_j > 0 ? (next_dollar_j / size_j) * 100 : na
            next_pct_txt_j = na(next_pct_j) ? "—" : f_fmtPct(next_pct_j)
            next_dollar_txt_j = na(next_dollar_j) ? "—" : f_fmtPrice(next_dollar_j)
            next_bar_txt_j = na(next_pct_j) ? "" : f_retraceBar(next_pct_j, retrace_bar_style)
            retrace_combo_j = next_pct_txt_j + "\n" + next_dollar_txt_j
            // this leg's own Retracement % targets, marked reached against its actual (final) retracement next_pct_j:
            [retrace_40_j, retrace_50_j, retrace_60_j] = f_retraceLevelTexts(has_leg_j ? array.get(z, idx_new) : float(na), has_leg_j ? array.get(z, idx_old) : float(na), next_pct_j)
            [ext_127_j, ext_162_j, ext_200_j] = f_extensionLevelTexts(has_leg_j ? array.get(z, idx_new) : float(na), has_leg_j ? array.get(z, idx_old) : float(na), next_pct_j)

            avg_len_j = tendency_j == 1 ? avg_bullish_length : avg_bearish_length
            avg_bars_j = tendency_j == 1 ? avg_bullish_bars : avg_bearish_bars
            velocity_j = has_leg_j and not na(bars_j) and bars_j != 0 ? size_j / bars_j : float(na)
            vs_avg_pct_j = has_leg_j and avg_len_j > 0 ? (size_j / avg_len_j - 1) * 100 : float(na)
            bars_avg_pct_j = has_leg_j and avg_bars_j > 0 and not na(bars_j) ? (bars_j / avg_bars_j - 1) * 100 : float(na)
            atr_start_j = has_leg_j and array.size(zatr) > j ? array.get(zatr, j) : float(na)
            atr_norm_j = has_leg_j and not na(atr_start_j) and atr_start_j > 0 ? size_j / atr_start_j : float(na)

            array.push(hist_prefix, prefix_j)
            array.push(hist_tendency_txt, tendency_txt_j)
            array.push(hist_tendency_col, tendency_col_j)
            array.push(hist_hilo_txt, hilo_txt_j)
            array.push(hist_growth_txt, growth_txt_j)
            array.push(hist_bars_txt, bars_txt_j)
            array.push(hist_retrace_txt, retrace_combo_j)
            array.push(hist_retrace_bar_txt, next_bar_txt_j)
            array.push(hist_retrace_40, retrace_40_j)
            array.push(hist_retrace_50, retrace_50_j)
            array.push(hist_retrace_60, retrace_60_j)
            array.push(hist_size_raw, size_j)
            array.push(hist_velocity_txt, na(velocity_j) ? "—" : f_fmtPrice(velocity_j) + "/bar")
            array.push(hist_vs_avg_txt, f_fmtPctDiff(vs_avg_pct_j))
            array.push(hist_bars_avg_txt, f_fmtPctDiff(bars_avg_pct_j))
            array.push(hist_atr_txt, na(atr_norm_j) ? "—" : f_fmtRatio(atr_norm_j) + " ATR")
            array.push(hist_ext_127, ext_127_j)
            array.push(hist_ext_162, ext_162_j)
            array.push(hist_ext_200, ext_200_j)

        hist_n = array.size(hist_prefix)

        // Second pass: each historical leg's size as a ratio of the leg immediately before it
        // (older/prior) — needs hist_size_raw fully populated first, since "prior" for entry k
        // is simply the next array slot (k+1), one step further back in time.
        for k = 0 to hist_n - 1
            array.push(hist_ratio_txt, "—")
        for k = 0 to hist_n - 1
            size_k = array.get(hist_size_raw, k)
            prior_size_k = k + 1 < hist_n ? array.get(hist_size_raw, k + 1) : float(na)
            ratio_k = not na(size_k) and not na(prior_size_k) and prior_size_k > 0 ? size_k / prior_size_k : float(na)
            array.set(hist_ratio_txt, k, na(ratio_k) ? "—" : f_fmtRatio(ratio_k) + f_nearestFibTag(ratio_k))

        leg_hilo_txt = f_fmtPrice(leg_high) + "\n" + f_fmtPrice(leg_low)
        retrace_combo_txt = retrace_pct_txt + "\n" + retrace_dollar_txt
        unconf_retrace_combo_txt = unconf_retrace_pct_txt + "\n" + unconf_retrace_dollar_txt

        prev_bars_plain = na(prev_confirmed_leg_bars) ? "—" : str.tostring(prev_confirmed_leg_bars)
        active_bars_plain = str.tostring(bars_in_leg)

        active_tendency = current_direction
        active_tendency_txt = active_tendency == 1 ? "UP" : active_tendency == -1 ? "DN" : "—"
        active_tendency_col = active_tendency == 1 ? label_bull_color : active_tendency == -1 ? label_bear_color : stats_cell_txt
        active_hilo_txt = na(active_leg_high) or na(active_leg_low) ? "—" : f_fmtPrice(active_leg_high) + "\n" + f_fmtPrice(active_leg_low)
        active_growth_txt = na(active_leg_high) or na(active_leg_low) ? "—" : f_fmtPrice(active_leg_high - active_leg_low)

        // === Advanced leg metrics (Velocity, Size/Bars vs Average, ATR-Normalized Size, Ratio to
        // Prior) for the Previous and Active legs — historical legs' versions were computed inside
        // the j loop above, alongside their own hist_* arrays.
        prev_dir_sign = array.size(z) >= 4 ? (array.get(z, 0) > array.get(z, 2) ? 1 : -1) : int(na)
        prev_avg_len = prev_dir_sign == 1 ? avg_bullish_length : avg_bearish_length
        prev_avg_bars = prev_dir_sign == 1 ? avg_bullish_bars : avg_bearish_bars
        prev_velocity = not na(prev_confirmed_leg_bars) and prev_confirmed_leg_bars != 0 ? leg_size / prev_confirmed_leg_bars : float(na)
        prev_vs_avg_pct = prev_avg_len > 0 ? (leg_size / prev_avg_len - 1) * 100 : float(na)
        prev_bars_vs_avg_pct = prev_avg_bars > 0 and not na(prev_confirmed_leg_bars) ? (prev_confirmed_leg_bars / prev_avg_bars - 1) * 100 : float(na)
        prev_atr_start = array.size(zatr) > 1 ? array.get(zatr, 1) : float(na)
        prev_atr_norm = not na(prev_atr_start) and prev_atr_start > 0 ? leg_size / prev_atr_start : float(na)
        prev_prior_size = hist_n >= 1 ? array.get(hist_size_raw, 0) : float(na)
        prev_ratio_val = not na(prev_prior_size) and prev_prior_size > 0 ? leg_size / prev_prior_size : float(na)

        prev_velocity_txt = na(prev_velocity) ? "—" : f_fmtPrice(prev_velocity) + "/bar"
        prev_vs_avg_txt = f_fmtPctDiff(prev_vs_avg_pct)
        prev_bars_avg_txt = f_fmtPctDiff(prev_bars_vs_avg_pct)
        prev_atr_txt = na(prev_atr_norm) ? "—" : f_fmtRatio(prev_atr_norm) + " ATR"
        prev_ratio_txt = na(prev_ratio_val) ? "—" : f_fmtRatio(prev_ratio_val) + f_nearestFibTag(prev_ratio_val)

        active_dir_sign = current_direction
        active_avg_len = active_dir_sign == 1 ? avg_bullish_length : avg_bearish_length
        active_avg_bars = active_dir_sign == 1 ? avg_bullish_bars : avg_bearish_bars
        active_growth_raw = na(active_leg_high) or na(active_leg_low) ? float(na) : active_leg_high - active_leg_low
        active_velocity = not na(active_growth_raw) and bars_in_leg != 0 ? active_growth_raw / bars_in_leg : float(na)
        active_vs_avg_pct = active_avg_len > 0 and not na(active_growth_raw) ? (active_growth_raw / active_avg_len - 1) * 100 : float(na)
        active_bars_vs_avg_pct = active_avg_bars > 0 ? (bars_in_leg / active_avg_bars - 1) * 100 : float(na)
        active_atr_start = array.size(zatr) > 0 ? array.get(zatr, 0) : float(na)
        active_atr_norm = not na(active_atr_start) and active_atr_start > 0 and not na(active_growth_raw) ? active_growth_raw / active_atr_start : float(na)
        active_ratio_val = not na(active_growth_raw) and leg_size > 0 ? active_growth_raw / leg_size : float(na)

        active_velocity_txt = na(active_velocity) ? "—" : f_fmtPrice(active_velocity) + "/bar"
        active_vs_avg_txt = f_fmtPctDiff(active_vs_avg_pct)
        active_bars_avg_txt = f_fmtPctDiff(active_bars_vs_avg_pct)
        active_atr_txt = na(active_atr_norm) ? "—" : f_fmtRatio(active_atr_norm) + " ATR"
        active_ratio_txt = na(active_ratio_val) ? "—" : f_fmtRatio(active_ratio_val) + f_nearestFibTag(active_ratio_val)

        // Extension % targets (127.2/161.8/200%) for the Previous leg, same pivot pair as its
        // Retracement % targets above, just projecting beyond 100% instead of within 0-100%.
        [prev_ext_127, prev_ext_162, prev_ext_200] = f_extensionLevelTexts(array.size(z) >= 4 ? array.get(z, 0) : float(na), array.size(z) >= 4 ? array.get(z, 2) : float(na), retrace_pct)

        title_txt = na(active_leg_num) ? "PHASES STATISTICS" : "PHASES STATISTICS"

        metric_labels = array.from("Dir", "High\nLow", "Growth", "Bars", "Retraced")
        idx_dir = 0
        idx_hilo = 1
        idx_growth = 2
        idx_bars = 3
        idx_retraced = 4
        next_idx = 5
        idx_rtdbar = -1
        if show_retrace_bar
            array.push(metric_labels, "Rtd %")
            idx_rtdbar := next_idx
            next_idx := next_idx + 1
        idx_velocity = -1
        if show_velocity
            array.push(metric_labels, "Velocity")
            idx_velocity := next_idx
            next_idx := next_idx + 1
        idx_vsavgsize = -1
        if show_vs_avg_size
            array.push(metric_labels, "vs Avg\nSize")
            idx_vsavgsize := next_idx
            next_idx := next_idx + 1
        idx_vsavgbars = -1
        if show_vs_avg_bars
            array.push(metric_labels, "vs Avg\nBars")
            idx_vsavgbars := next_idx
            next_idx := next_idx + 1
        idx_xatr = -1
        if show_xatr
            array.push(metric_labels, "xATR")
            idx_xatr := next_idx
            next_idx := next_idx + 1
        idx_ratio = -1
        if show_ratio_to_prior
            array.push(metric_labels, "Ratio to\nPrior")
            idx_ratio := next_idx
            next_idx := next_idx + 1
        idx_rtd40 = -1
        idx_rtd50 = -1
        idx_rtd60 = -1
        if show_retrace_targets
            array.push(metric_labels, "Rtd 40%")
            array.push(metric_labels, "Rtd 50%")
            array.push(metric_labels, "Rtd 60%")
            idx_rtd40 := next_idx
            idx_rtd50 := next_idx + 1
            idx_rtd60 := next_idx + 2
            next_idx := next_idx + 3
        idx_ext127 = -1
        idx_ext162 = -1
        idx_ext200 = -1
        if show_extension_targets
            array.push(metric_labels, "Ext 127%")
            array.push(metric_labels, "Ext 162%")
            array.push(metric_labels, "Ext 200%")
            idx_ext127 := next_idx
            idx_ext162 := next_idx + 1
            idx_ext200 := next_idx + 2
            next_idx := next_idx + 3
        m = next_idx

        prev_col_hdr = (na(prev_leg_num) ? "Prev" : f_legChar(prev_leg_num, char_style)) + "\nUnconfirmed"
        active_col_hdr = (na(active_leg_num) ? "Active" : f_legChar(active_leg_num, char_style)) + "\nProjected"

        // Build a flattened [column][metric] matrix so the column count can vary with num_legs_shown.
        // Column order (left to right): oldest historical leg ... newest historical leg, Prev, Active.
        total_data_cols = hist_n + 2
        col_hdrs   = array.new_string(total_data_cols)
        col_vals   = array.new_string(total_data_cols * m)
        col_txtcol = array.new_color(total_data_cols * m)
        col_bgcol  = array.new_color(total_data_cols * m)

        for c = 0 to hist_n - 1
            k = hist_n - 1 - c
            array.set(col_hdrs, c, array.get(hist_prefix, k))
            array.set(col_vals, c * m + idx_dir, array.get(hist_tendency_txt, k))
            array.set(col_vals, c * m + idx_hilo, array.get(hist_hilo_txt, k))
            array.set(col_vals, c * m + idx_growth, array.get(hist_growth_txt, k))
            array.set(col_vals, c * m + idx_bars, array.get(hist_bars_txt, k))
            array.set(col_vals, c * m + idx_retraced, array.get(hist_retrace_txt, k))
            if show_retrace_bar
                array.set(col_vals, c * m + idx_rtdbar, array.get(hist_retrace_bar_txt, k))
            if show_velocity
                array.set(col_vals, c * m + idx_velocity, array.get(hist_velocity_txt, k))
            if show_vs_avg_size
                array.set(col_vals, c * m + idx_vsavgsize, array.get(hist_vs_avg_txt, k))
            if show_vs_avg_bars
                array.set(col_vals, c * m + idx_vsavgbars, array.get(hist_bars_avg_txt, k))
            if show_xatr
                array.set(col_vals, c * m + idx_xatr, array.get(hist_atr_txt, k))
            if show_ratio_to_prior
                array.set(col_vals, c * m + idx_ratio, array.get(hist_ratio_txt, k))
            if show_retrace_targets
                array.set(col_vals, c * m + idx_rtd40, array.get(hist_retrace_40, k))
                array.set(col_vals, c * m + idx_rtd50, array.get(hist_retrace_50, k))
                array.set(col_vals, c * m + idx_rtd60, array.get(hist_retrace_60, k))
            if show_extension_targets
                array.set(col_vals, c * m + idx_ext127, array.get(hist_ext_127, k))
                array.set(col_vals, c * m + idx_ext162, array.get(hist_ext_162, k))
                array.set(col_vals, c * m + idx_ext200, array.get(hist_ext_200, k))
            for i = 0 to m - 1
                // Retracement % and Extension % target rows get the inverted direction color
                // relative to the leg's own tendency color; all other metrics keep the normal color.
                base_col = array.get(hist_tendency_col, k)
                is_inv_row = (show_retrace_targets and (i == idx_rtd40 or i == idx_rtd50 or i == idx_rtd60)) or (show_extension_targets and (i == idx_ext127 or i == idx_ext162 or i == idx_ext200))
                row_col = is_inv_row ? f_invertTendencyCol(base_col) : base_col
                array.set(col_txtcol, c * m + i, stats_dir_text_mode == "Tendency Color" ? row_col : stats_dir_text_mode == "Tendency Background" ? stats_tendbg_txt_color : stats_cell_txt)
                array.set(col_bgcol, c * m + i, stats_dir_text_mode == "Tendency Background" ? f_tendBgColor(row_col) : stats_cell_bg)

        prev_c = hist_n
        array.set(col_hdrs, prev_c, prev_col_hdr)
        array.set(col_vals, prev_c * m + idx_dir, tendency_txt)
        array.set(col_vals, prev_c * m + idx_hilo, leg_hilo_txt)
        array.set(col_vals, prev_c * m + idx_growth, f_fmtPrice(leg_size))
        array.set(col_vals, prev_c * m + idx_bars, prev_bars_plain)
        array.set(col_vals, prev_c * m + idx_retraced, unconf_retrace_combo_txt)
        if show_retrace_bar
            array.set(col_vals, prev_c * m + idx_rtdbar, unconf_retrace_bar_txt)
        if show_velocity
            array.set(col_vals, prev_c * m + idx_velocity, prev_velocity_txt)
        if show_vs_avg_size
            array.set(col_vals, prev_c * m + idx_vsavgsize, prev_vs_avg_txt)
        if show_vs_avg_bars
            array.set(col_vals, prev_c * m + idx_vsavgbars, prev_bars_avg_txt)
        if show_xatr
            array.set(col_vals, prev_c * m + idx_xatr, prev_atr_txt)
        if show_ratio_to_prior
            array.set(col_vals, prev_c * m + idx_ratio, prev_ratio_txt)
        if show_retrace_targets
            array.set(col_vals, prev_c * m + idx_rtd40, prev_retrace_40)
            array.set(col_vals, prev_c * m + idx_rtd50, prev_retrace_50)
            array.set(col_vals, prev_c * m + idx_rtd60, prev_retrace_60)
        if show_extension_targets
            array.set(col_vals, prev_c * m + idx_ext127, prev_ext_127)
            array.set(col_vals, prev_c * m + idx_ext162, prev_ext_162)
            array.set(col_vals, prev_c * m + idx_ext200, prev_ext_200)
        for i = 0 to m - 1
            // Same inversion rule as above, applied to the Previous-leg column.
            is_inv_row = (show_retrace_targets and (i == idx_rtd40 or i == idx_rtd50 or i == idx_rtd60)) or (show_extension_targets and (i == idx_ext127 or i == idx_ext162 or i == idx_ext200))
            row_col = is_inv_row ? f_invertTendencyCol(tendency_col) : tendency_col
            array.set(col_txtcol, prev_c * m + i, stats_dir_text_mode == "Tendency Color" ? row_col : stats_dir_text_mode == "Tendency Background" ? stats_tendbg_txt_color : stats_cell_txt)
            array.set(col_bgcol, prev_c * m + i, stats_dir_text_mode == "Tendency Background" ? f_tendBgColor(row_col) : stats_cell_bg)

        active_c = hist_n + 1
        array.set(col_hdrs, active_c, active_col_hdr)
        array.set(col_vals, active_c * m + idx_dir, active_tendency_txt)
        array.set(col_vals, active_c * m + idx_hilo, active_hilo_txt)
        array.set(col_vals, active_c * m + idx_growth, active_growth_txt)
        array.set(col_vals, active_c * m + idx_bars, active_bars_plain)
        array.set(col_vals, active_c * m + idx_retraced, retrace_combo_txt)
        if show_retrace_bar
            array.set(col_vals, active_c * m + idx_rtdbar, retrace_bar_txt)
        if show_velocity
            array.set(col_vals, active_c * m + idx_velocity, active_velocity_txt)
        if show_vs_avg_size
            array.set(col_vals, active_c * m + idx_vsavgsize, active_vs_avg_txt)
        if show_vs_avg_bars
            array.set(col_vals, active_c * m + idx_vsavgbars, active_bars_avg_txt)
        if show_xatr
            array.set(col_vals, active_c * m + idx_xatr, active_atr_txt)
        if show_ratio_to_prior
            array.set(col_vals, active_c * m + idx_ratio, active_ratio_txt)
        if show_retrace_targets
            // Active (Projected) column: forward-looking Rtd % targets are intentionally
            // left blank here, since the leg hasn't confirmed yet.
            array.set(col_vals, active_c * m + idx_rtd40, "—")
            array.set(col_vals, active_c * m + idx_rtd50, "—")
            array.set(col_vals, active_c * m + idx_rtd60, "—")
        if show_extension_targets
            // Same rationale as the Rtd % blanking above.
            array.set(col_vals, active_c * m + idx_ext127, "—")
            array.set(col_vals, active_c * m + idx_ext162, "—")
            array.set(col_vals, active_c * m + idx_ext200, "—")
        for i = 0 to m - 1
            // Same inversion rule as above, applied to the Active-leg column.
            is_inv_row = (show_retrace_targets and (i == idx_rtd40 or i == idx_rtd50 or i == idx_rtd60)) or (show_extension_targets and (i == idx_ext127 or i == idx_ext162 or i == idx_ext200))
            row_col = is_inv_row ? f_invertTendencyCol(active_tendency_col) : active_tendency_col
            array.set(col_txtcol, active_c * m + i, stats_dir_text_mode == "Tendency Color" ? row_col : stats_dir_text_mode == "Tendency Background" ? stats_tendbg_txt_color : stats_cell_txt)
            array.set(col_bgcol, active_c * m + i, stats_dir_text_mode == "Tendency Background" ? f_tendBgColor(row_col) : stats_cell_bg)

        // === Highlight Reached Cells ===
        // Any value cell whose text ends with the Reached Marker Glyph gets its text/background
        // colors overridden per the chosen Highlight Style. Runs once on the flattened color
        // arrays, so it applies identically to Vertical and Horizontal orientations.
        if highlight_reached and show_reached_marker
            reached_suffix = " " + reached_marker_glyph
            for hl = 0 to total_data_cols * m - 1
                hl_val = array.get(col_vals, hl)
                if not na(hl_val) and str.endswith(hl_val, reached_suffix)
                    hl_txt = array.get(col_txtcol, hl)
                    hl_bg = array.get(col_bgcol, hl)
                    if reached_hl_style == "Custom Color"
                        array.set(col_txtcol, hl, reached_hl_txt)
                        array.set(col_bgcol, hl, reached_hl_bg)
                    else if reached_hl_style == "Solid Fill"
                        if stats_dir_text_mode == "Tendency Background"
                            array.set(col_bgcol, hl, color.new(hl_bg, 0))
                        else
                            array.set(col_bgcol, hl, color.new(hl_txt, 0))
                            array.set(col_txtcol, hl, color.black)
                    else
                        if stats_dir_text_mode == "Tendency Color"
                            array.set(col_bgcol, hl, color.new(hl_txt, 100 - reached_hl_strength))
                            array.set(col_txtcol, hl, f_brighten(hl_txt, reached_hl_strength))
                        else if stats_dir_text_mode == "Tendency Background"
                            array.set(col_bgcol, hl, f_brighten(color.new(hl_bg, math.max(0, color.t(hl_bg) - reached_hl_strength)), reached_hl_strength / 2.0))
                        else
                            array.set(col_bgcol, hl, f_brighten(hl_bg, reached_hl_strength))

        if stats_orientation == "Vertical"
            total_cols = total_data_cols + 3
            statsTable := table.new(f_tablePos(stats_position), total_cols, m + 4, border_width = 1, border_color = stats_border_color)
            table.cell(statsTable, 1, 1, title_txt, text_color = stats_header_txt, bgcolor = stats_header_bg, text_size = stats_size)
            table.merge_cells(statsTable, 1, 1, total_data_cols + 1, 1)
            table.cell(statsTable, 1, 2, "Metric", text_color = stats_header_txt, bgcolor = stats_header_bg, text_size = stats_size)
            for c = 0 to total_data_cols - 1
                // Single-line leg counter headers (historical legs) are always Normal size for visibility;
                // the Unconfirmed / Projected headers keep the user's Text Size.
                hdr_size_c = c < hist_n ? size.normal : stats_size
                table.cell(statsTable, c + 2, 2, array.get(col_hdrs, c), text_color = stats_header_txt, bgcolor = stats_header_bg, text_size = hdr_size_c)
            for i = 0 to m - 1
                table.cell(statsTable, 1, i + 3, array.get(metric_labels, i), text_color = stats_header_txt, bgcolor = stats_header_bg, text_size = stats_size)
                for c = 0 to total_data_cols - 1
                    table.cell(statsTable, c + 2, i + 3, array.get(col_vals, c * m + i), text_color = array.get(col_txtcol, c * m + i), bgcolor = array.get(col_bgcol, c * m + i), text_size = stats_size)
            f_addTablePadding(statsTable, total_cols, m + 4, pad_top, pad_bottom, pad_left, pad_right)
        else
            total_rows = total_data_cols + 4
            statsTable := table.new(f_tablePos(stats_position), m + 3, total_rows, border_width = 1, border_color = stats_border_color)
            table.cell(statsTable, 1, 1, title_txt, text_color = stats_header_txt, bgcolor = stats_header_bg, text_size = stats_size)
            table.merge_cells(statsTable, 1, 1, m + 1, 1)
            table.cell(statsTable, 1, 2, "Phase", text_color = stats_header_txt, bgcolor = stats_header_bg, text_size = stats_size)
            for i = 0 to m - 1
                table.cell(statsTable, i + 2, 2, array.get(metric_labels, i), text_color = stats_header_txt, bgcolor = stats_header_bg, text_size = stats_size)
            for c = 0 to total_data_cols - 1
                // Same rule as the Vertical branch: single-line leg counter headers are Normal size.
                hdr_size_c = c < hist_n ? size.normal : stats_size
                table.cell(statsTable, 1, c + 3, array.get(col_hdrs, c), text_color = stats_header_txt, bgcolor = stats_header_bg, text_size = hdr_size_c)
                for i = 0 to m - 1
                    table.cell(statsTable, i + 2, c + 3, array.get(col_vals, c * m + i), text_color = array.get(col_txtcol, c * m + i), bgcolor = array.get(col_bgcol, c * m + i), text_size = stats_size)
            f_addTablePadding(statsTable, m + 3, total_rows, pad_top, pad_bottom, pad_left, pad_right)

plot(na)

// EOF
````
