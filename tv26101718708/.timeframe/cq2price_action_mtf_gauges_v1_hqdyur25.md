# CQ_(2)_[PRICE ACTION / MTF GAUGES] v1

- url: https://www.tradingview.com/script/hQDYur25-CQ-2-PRICE-ACTION-MTF-GAUGES-v1/
- type: indicator
- pine_id: PUB;5a1f95efe04648748e1158fcac36a38b
- version: 1.0

## Description

================================================================================
  CQ_(2)_[PRICE ACTION / MTF GAUGES] v1
  Description & User Manual
  Pine Script v6 indicator for TradingView  -  (c) CQuevedo345 / UkutaLabs
================================================================================

TABLE OF CONTENTS
-----------------
  1.  Description
  2.  Quick Start
  3.  Anatomy of a Gauge
  4.  Gauge Selection
  5.  Gauge Layout
  6.  Previous Candle Gauges
  7.  Gauge Display
        7.1  Width Modes
        7.2  Label Placement
  8.  Caption Mode (Labels / Boxes)
  9.  Sells / Buys Arrows
        9.1  Significance Gates
        9.2  Candle Insight Tooltip
  10. Gauge Colors & Palettes
  11. Timeframe Availability
  12. Troubleshooting / FAQ


================================================================================
1. DESCRIPTION
================================================================================

CQ_(2)_[PRICE ACTION / MTF GAUGES] is a gauges-only extraction of the
CQ Fibonacci MTF Ranges Suite, based on "Fibonacci IntraDay Range
[UkutaLabs]". It draws up to five "price tendency gauges" in the empty space
to the right of the current bar:

      4H   ·   DAY   ·   WEEK   ·   MONTH   ·   YEAR

Each gauge is a compact vertical candle of its timeframe's CURRENT period:
  - the period's High, Low and Open,
  - where the current price sits between them,
  - the dollar growth (P&L) from the open.

At a glance you can see, for every timeframe at once, whether price is above
or below that period's open and how much of the range has been used.

Optional extras:
  - Previous Candle Gauges: a faded reference gauge of each timeframe's last
    completed candle, drawn just left of its live gauge.
  - Sells / Buys Arrows (Day, Week, Month): arrows showing the upper wick
    (selling pressure) and lower wick (buying pressure) of the live candle,
    shown only when they are significant versus that timeframe's ATR.
  - Box captions riding on the gauge levels.

Gauges are laid out automatically: disabled or unavailable gauges are
skipped and the rest close the gap.


================================================================================
2. QUICK START
================================================================================

  1. Add the indicator to any chart. By default the DAY, WEEK and MONTH
     gauges are enabled; enable 4H and/or YEAR if you want them.
  2. Move the gauges with "Starting Offset" and space them with
     "Separation Between Gauges".
  3. Pick a Width Mode (Original / Reduced / Thin) and a Caption Mode
     (Boxes or Labels).
  4. Optional: turn on "Show Previous Candle Gauges".
  5. Hover the "Sells" / "Buys" labels and the Open / P&L labels for
     detailed tooltips.


================================================================================
3. ANATOMY OF A GAUGE
================================================================================

         High label  ─────────────  ← High line (bullish foreground color)
                     │ bull scope │  ← High → Open box (bullish background)
                     │   ┌────┐   │
                     │   │inner│  │  ← inner price box: Open → current price
         Open label ═══════════════ ← Open marker (white)
                     │ bear scope │  ← Open → Low box (bearish background)
         Low label   ─────────────  ← Low line (bearish foreground color)

  - Scope boxes: High → Open (bullish background) and Open → Low (bearish
    background), with dotted borders. The timeframe name (4H, DAY, WEEK...)
    is printed inside them.
  - Inner price box: spans from the Open to the current price. Its color
    follows the direction: bullish colors when price is at/above the open,
    bearish colors when below.
  - Current-price marker: a thick line at the current price.
  - Open marker: white line at the period's open.
  - Labels: High, Low, Open price and P&L (growth from the open).

  The gauges update on every bar, so they are always visible, including
  when the market is closed.


================================================================================
4. GAUGE SELECTION  (group: ── Gauge Selection ──)
================================================================================

  Enable 4H Gauge ........... default OFF. Intraday charts only.
  Enable IntraDay Gauge ..... default ON. Hidden on weekly/monthly charts.
  Enable IntraWeek Gauge .... default ON. Hidden on monthly charts.
  Enable IntraMonth Gauge ... default ON.
  Enable IntraYear Gauge .... default OFF.

  When a gauge is off or hidden, the remaining gauges shift left to close
  the gap. Order is always 4H → DAY → WEEK → MONTH → YEAR.


================================================================================
5. GAUGE LAYOUT  (group: ── Gauge Layout ──)
================================================================================

  Starting Offset ............... bars to the right of the current bar where
                                  the first visible gauge sits (0 - 300,
                                  default 50).
  Separation Between Gauges ..... empty bars between the outer boxes of
                                  consecutive gauges (0 - 50, default 8).

  When Previous Candle Gauges are on, each slot automatically reserves room
  for the previous gauge (its width + gap), so gauges never overlap and the
  Separation is still kept between outer edges.


================================================================================
6. PREVIOUS CANDLE GAUGES  (group: ── Previous Candle Gauges ──)
================================================================================

  Show Previous Candle Gauges .... default OFF. Draws the last COMPLETED
                                   candle of each visible gauge's timeframe
                                   just left of its live gauge.
  Gap to Live Gauge .............. empty bars between them (1 - 20,
                                   default 2).
  Previous Gauge Opacity % ....... 100 = same opacity as the live gauge,
                                   0 = invisible (default 50).

  A previous gauge is reference only: scope boxes (High → Open, Open → Low),
  body box (Open → Close), High/Low lines, white Open marker and a Close
  marker. No labels, captions or arrows. It uses the same width mode and
  colors as the live gauges. Its body color follows the candle's own
  direction (bullish if Close >= Open). It never repaints.


================================================================================
7. GAUGE DISPLAY  (group: ── Gauge Display ──)
================================================================================

  Show Percentage on Gauge Levels ... adds the % change from the open under
                                      the High and Low labels. Default OFF.
  Inner Price Box Opacity % ......... default 50.
  Scope Box Opacity % ............... default 25.
  Scope Box Border Opacity % ........ default 90.
  Inner Price Box Border Opacity % .. default 90.
  Inner Box Brightness % ............ blends the inner box toward white for
                                      contrast against the scope box
                                      (default 30; 0 = no change).
  Gauge Price Label Color ........... text color of the Open-price and P&L
                                      labels (default white).
  Show Gauge Price Label ............ show/hide the Open-price and P&L
                                      labels (and their boxes in Boxes mode).
  Gauge Price Label Side ............ Left or Right (default Right).
  Gauge Width Mode .................. see 7.1.
  Reduced Mode Inner Bar Width ...... pixel thickness of the inner bar in
                                      Reduced mode (3 - 9, default 7).

  All opacity values: 0 = fully transparent, 100 = fully opaque.

7.1 WIDTH MODES
-----------------------------------------------------------------------------
  Original ........... (default) scope boxes span 3 bars, with the inner
                       price box inset inside them.
  Reduced (2 Bars) ... scope boxes span 2 bars; the inner price marker
                       becomes a centered bar drawn from its border
                       thickness (Reduced Mode Inner Bar Width).
  Thin (1 Bar) ....... scope boxes span 1 bar; the inner box fills that bar.

7.2 LABEL PLACEMENT
-----------------------------------------------------------------------------
  - Open price + P&L labels sit on the chosen Price Label Side, one bar
    inside the outer edge (on the edge itself in Thin mode).
  - High / Low labels hug the OPPOSITE edge, so the two groups never stack.
  - Open label format: "◄$84,394" (Right side) or "$84,394 ▸" (Left side).
  - P&L label: dollar change from the open (e.g. "$1,250" / "-$830").
  - Tooltips: hover the Open label for the open price; hover the P&L label
    for % change, $ change and the open.


================================================================================
8. CAPTION MODE  (group: ── Caption Mode ──)
================================================================================

  Caption Mode
    Labels ... classic pointer labels only.
    Boxes .... (default) box captions riding on the gauge levels, PLUS the
               pointer labels on the gauge's RIGHT-hand side. The pointer
               labels on the LEFT-hand side are hidden:
                 Price Label Side = Right -> High/Low labels hidden
                 Price Label Side = Left  -> Open/P&L labels hidden

  Box captions:
    High ..... gauge-wide box, text reads ABOVE the High line.
    Low ...... gauge-wide box, text reads BELOW the Low line.
    Open ..... 1-candle-wide box just outside the gauge on the Price Label
               Side; text reads on the side of the Open line AWAY from
               current price.
    Growth ... 1-candle-wide box on the same side, at the current price;
               text reads beyond it (above when bullish, below when
               bearish): the $ change from the open (+ optional %).

  Align (Boxes, High/Low only) ... Center (default), Left or Right edge of
                                   the gauge. Open/Growth text always flows
                                   outward from the gauge.
  Show % In Growth Box ........... default ON. Appends the % change to the
                                   Growth box.

  Box height scales with price (≈0.001 % of the open, at least one tick).
  Boxes cannot show tooltips (a Pine limitation) - that is why the % can be
  shown directly in the Growth box.


================================================================================
9. SELLS / BUYS ARROWS  (group: ── Sells / Buys Arrows ──)
================================================================================

  Day, Week and Month gauges only (not 4H or Year).

    Sells ... 1px arrow from the period HIGH down to current price, never
              past the Open  = the candle's UPPER wick (selling pressure).
    Buys .... 1px arrow from the period LOW up to current price, never past
              the Open       = the candle's LOWER wick (buying pressure).

  Show Sells / Buys Arrows .... default ON.
  ATR Length .................. default 14. ATR computed on each gauge's own
                                timeframe from completed candles (no
                                repaint).
  Min Body (x ATR) ............ gate 1, default 0.10.
  Min Wick (x ATR) ............ gate 2a, default 0.15.
  % of Range .................. gate 2b, default 25 %.
  Min Elapsed % of Period ..... optional gate 3, default 0 (off).
  Bars Right of Gauge ......... arrow column, counted from the gauge's outer
                                box (1 - 20, default 1).
  Label Bars Right of Arrow ... horizontal offset of the "Sells"/"Buys"
                                labels (0 = on the arrow).
  Arrow Opacity % ............. opacity of the arrow lines (default 50).
                                Label backgrounds are not affected.

  Colors: the Sells arrow uses the Low label color, the Buys arrow the High
  label color. Label backgrounds use the bearish / bullish backgrounds;
  label text is white.

9.1 SIGNIFICANCE GATES
-----------------------------------------------------------------------------
  An arrow is shown only when ALL of these pass:
    Gate 1 (both arrows):  body = |price - Open|  >=  Min Body x ATR
    Gate 2 (each arrow):   its wick >= Min Wick x ATR
                           AND its wick >= "% of Range" of the High-Low range
    Gate 3 (both arrows):  elapsed share of the period >= Min Elapsed %

  Gate 1 hides the arrows right after the open and while price hovers around
  it. Gate 2 filters tiny wicks on quiet candles and wicks that are trivial
  next to a large body. Gate 3 optionally waits until part of the day/week/
  month has passed.

9.2 CANDLE INSIGHT TOOLTIP
-----------------------------------------------------------------------------
  Hover a "Sells" or "Buys" label to see:
    - how far price was pushed from the High / lifted from the Low;
    - direction (Bullish / Bearish) and O / H / L / Now;
    - range ($ and % of open), body ($, %, % of range);
    - upper and lower wick: $, % of body, % of range, % from High/Low;
    - price position within the range (0 = Low, 100 = High);
    - balance: Sellers stronger / Buyers stronger / Balanced wicks
      (a wick counts as dominant when it is more than 1.2x the other);
    - each gate's value, its minimum, and ✓ / ✗.


================================================================================
10. GAUGE COLORS & PALETTES  (group: ── Gauge Colors ──)
================================================================================

  Gauge Color Palette ...... Custom (default), Classic, Ocean, Sunset, Neon,
                             Monochrome, Desert, Oldbook, OldWest, Vivid.
  Bullish Background ....... scope/label background, bull side (Custom).
  Foreground ............... High line / bullish accents (always editable).
  Bearish Background ....... scope/label background, bear side (Custom).
  Foreground ............... Low line / bearish accents (always editable).
  Scope High Label Color ... High label text (Custom).
  Scope Low Label Color .... Low label text (Custom).

  Custom: every gauge uses the pickers above.
  Any other palette: overrides the Bullish/Bearish Backgrounds and the
  High/Low label text (palette colors lightened 50 % toward white).
  Foreground colors stay editable at all times.


================================================================================
11. TIMEFRAME AVAILABILITY
================================================================================

    Chart TF           4H     DAY    WEEK   MONTH  YEAR
    -----------------  -----  -----  -----  -----  -----
    Intraday (<1D)     yes    yes    yes    yes    yes
    Daily              no     yes    yes    yes    yes
    Weekly             no     no     yes    yes    yes
    Monthly            no     no     no     yes    yes

  ("yes" = allowed when the gauge is enabled.)

  Data is requested from the 240, D, W, M and 12M timeframes of the chart
  symbol. The live gauges show the CURRENT period; the previous gauges show
  the last completed one.


================================================================================
12. TROUBLESHOOTING / FAQ
================================================================================

  Q: A gauge is missing.
  A: Check it is enabled and allowed on the current chart timeframe (see
     section 11).

  Q: Gauges overlap other drawings or the price scale.
  A: Change "Starting Offset", or reduce "Separation Between Gauges".

  Q: The Sells / Buys arrows never show.
  A: They only appear on Day/Week/Month gauges when all gates pass. Lower
     Min Body, Min Wick or % of Range, or set Min Elapsed to 0. Hover a
     label (when visible) to see which gate fails.

  Q: In Boxes mode the High/Low (or Open/P&L) pointer labels disappeared.
  A: By design, Boxes mode hides the pointer labels on the gauge's left-hand
     side; their values are shown by the box captions instead.

  Q: With the Vivid palette the Low label text is invisible.
  A: The Vivid bearish color is defined fully transparent in the script, so
     its lightened Low-label text is transparent too. Use another palette
     or Custom.

  Q: Why no tooltip on box captions?
  A: Pine Script boxes do not support tooltips; use Labels mode or hover
     the remaining pointer labels.

================================================================================
  End of manual
================================================================================

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CQuevedo345

// Gauges-only extraction of "CQ_(1-5)_Fibonacci MTF Ranges Suite v5"
// Based on "Fibonacci IntraDay Range [UkutaLabs]"
// Price Tendency Gauges: 4H + IntraDay + IntraWeek + IntraMonth + IntraYear
// Each gauge can be enabled/disabled; visible gauges are laid out automatically.
// Caption Mode (global): gauge captions (High, Low, Open price, P&L) drawn as
// pointer labels only (Labels), or as thin boxes riding on each gauge level
// PLUS the pointer labels on the right-hand side of the gauge (Boxes — the
// labels on the left-hand side are hidden). In Boxes mode the Open price and the growth from
// the open (P&L, optional %) get their own 1-candle-wide boxes beside the
// gauge, on the Price Label Side.
// Sells / Buys arrows (Day, Week, Month): 1px arrows just right of the
// gauge — High down to price (Sells) and Low up to price (Buys), both
// stopping at the Open — shown only when the candle body and the wick are
// significant versus that timeframe's ATR (optional elapsed-time gate).
// Previous Candle Gauges (optional): a faded, label-free reference gauge of
// each timeframe's previous completed candle, just left of its live gauge.
// Author: CQuevedo345 / UkutaLabs
//@version=6
indicator("CQ_(2)_[PRICE ACTION / MTF GAUGES] v1", overlay=true,
     max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// ════════════════════════════════════════════════════════════════════════════════
// ── GAUGE SELECTION ───────────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
bool h4_enable  = input.bool(false, "Enable 4H Gauge",         group="── Gauge Selection ──", tooltip="Only drawn on intraday charts. When off or hidden, the remaining gauges shift to close the gap.")
bool day_enable = input.bool(true,  "Enable IntraDay Gauge",   group="── Gauge Selection ──", tooltip="Hidden on weekly and monthly charts. When off or hidden, the remaining gauges shift to close the gap.")
bool wk_enable  = input.bool(true,  "Enable IntraWeek Gauge",  group="── Gauge Selection ──", tooltip="Hidden on monthly charts. When off or hidden, the remaining gauges shift to close the gap.")
bool mo_enable  = input.bool(true,  "Enable IntraMonth Gauge", group="── Gauge Selection ──", tooltip="When off, the remaining gauges shift to close the gap.")
bool yr_enable  = input.bool(false,  "Enable IntraYear Gauge",  group="── Gauge Selection ──", tooltip="When off, the remaining gauges shift to close the gap.")

// ════════════════════════════════════════════════════════════════════════════════
// ── GAUGE LAYOUT ──────────────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
int gauge_startOffset = input.int(50, "Starting Offset", minval=0, maxval=300, group="── Gauge Layout ──", tooltip="Horizontal position of the first visible gauge, in bars to the right of the current bar.")
int gauge_separation  = input.int(8, "Separation Between Gauges", minval=0, maxval=50, group="── Gauge Layout ──", tooltip="Empty bars between the outer boxes of consecutive gauges. Gauges that are disabled or hidden on the current timeframe are skipped, and the remaining ones shift automatically to close the gap.")

// ════════════════════════════════════════════════════════════════════════════════
// ── PREVIOUS CANDLE GAUGES ────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
// Reference only: the previous completed candle of each visible gauge's
// timeframe, drawn just left of the live gauge with the same width mode and
// colors, faded. Scope boxes (High→Open, Open→Low), Open→Close body, High/Low
// lines and Open/Close markers — no labels, captions or arrows.
bool prev_enable  = input.bool(false, "Show Previous Candle Gauges", group="── Previous Candle Gauges ──", tooltip="Draws a reference gauge of each visible timeframe's previous (completed) candle just left of its live gauge. No labels, captions or arrows. Uses the live gauges' width mode and colors. The layout widens automatically so gauges never overlap.")
int  prev_gap     = input.int(2, "Gap to Live Gauge", minval=1, maxval=20, group="── Previous Candle Gauges ──", tooltip="Empty bars between the previous-candle gauge and its live gauge.")
int  prev_opacity = input.int(50, "Previous Gauge Opacity %", minval=0, maxval=100, group="── Previous Candle Gauges ──", tooltip="Fades the whole previous-candle gauge relative to the live gauge. 100 = same opacity as the live gauge, 0 = invisible.")
int  prev_fade    = 100 - prev_opacity

// ════════════════════════════════════════════════════════════════════════════════
// ── GAUGE DISPLAY SETTINGS (SHARED BY ALL GAUGES) ─────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
bool gauge_showPercent = input.bool(false, "Show Percentage on Gauge Levels", group="── Gauge Display ──", tooltip="Appends the % change from the period's open to the High/Low labels on every gauge (4H, Day, Week, Month, Year).")
int gauge_innerBoxOpacity = input.int(50, "Inner Price Box Opacity %", minval=0, maxval=100, group="── Gauge Display ──", tooltip="Opacity of the small price box drawn inside the scope box on every gauge. 0 = fully transparent, 100 = fully opaque.")
int gauge_innerBoxTrans = 100 - gauge_innerBoxOpacity
int gauge_scopeBoxOpacity = input.int(25, "Scope Box Opacity %", minval=0, maxval=100, group="── Gauge Display ──", tooltip="Opacity of the larger bull/bear scope box (High-to-Open and Open-to-Low background) on every gauge. 0 = fully transparent, 100 = fully opaque.")
int gauge_scopeBoxTrans = 100 - gauge_scopeBoxOpacity
int gauge_scopeBorderOpacity = input.int(90, "Scope Box Border Opacity %", minval=0, maxval=100, group="── Gauge Display ──", tooltip="Opacity of the scope box border on every gauge. 0 = fully transparent, 100 = fully opaque.")
int gauge_scopeBorderTrans = 100 - gauge_scopeBorderOpacity
int gauge_innerBorderOpacity = input.int(90, "Inner Price Box Border Opacity %", minval=0, maxval=100, group="── Gauge Display ──", tooltip="Opacity of the inner price box border on every gauge. 0 = fully transparent, 100 = fully opaque.")
int gauge_innerBorderTrans = 100 - gauge_innerBorderOpacity
int gauge_innerBoxBrightness = input.int(30, "Inner Box Brightness %", minval=0, maxval=100, group="── Gauge Display ──", tooltip="Blends the inner price box's color toward white to improve visibility against the scope box on every gauge. 0 = no change, 100 = fully white.")
color gauge_priceLabelColor = input.color(color.white, "Gauge Price Label Color", group="── Gauge Display ──", tooltip="Text color of the Open-price label and the P&L label on every gauge.")
bool gauge_showPriceLabel = input.bool(true, "Show Gauge Price Label", group="── Gauge Display ──", tooltip="Shows/hides the Open-price label and P&L label on every gauge.")
string gauge_priceLabelSide = input.string("Right", "Gauge Price Label Side", options=["Left","Right"], group="── Gauge Display ──", tooltip="Which side of the gauge the Open-price and P&L labels sit on (one bar inside the outer edge; on the edge itself in Thin mode). The High/Low labels hug the opposite edge. In Boxes caption mode it picks the side of the 1-candle-wide Open and Growth boxes.")
string gauge_widthMode = input.string("Original", "Gauge Width Mode", options=["Original", "Reduced (2 Bars)", "Thin (1 Bar)"], group="── Gauge Display ──", tooltip="Original: scope boxes span 3 bars with the inner price box inset inside them (default).\nReduced (2 Bars): scope boxes span 2 bars, and the inner price marker collapses to a centered bar drawn purely from the inner box's border.\nThin (1 Bar): scope boxes span a single bar, and the inner price box fills that same bar.\nApplies to every gauge.")
int gauge_reducedBarWidth = input.int(7, "Reduced Mode Inner Bar Width", minval=3, maxval=9, group="── Gauge Display ──", tooltip="Border thickness (in pixels) used to render the centered inner price bar when Gauge Width Mode is set to Reduced (2 Bars). Ignored in Original and Thin modes.")

// ════════════════════════════════════════════════════════════════════════════════
// ── CAPTION MODE (GLOBAL) ─────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
// Labels: the classic pointer labels (High/Low on one edge, Open + P&L on the
// chosen Price Label Side). Boxes: the pointer labels on the gauge's left-hand
// side are hidden (High/Low when Price Label Side = Right, Open + P&L when it
// = Left), the right-hand ones stay, and each caption is ALSO drawn as a thin
// box on its own level, with the text reading just above or below the line:
//   High   → gauge-wide box, text above the High line
//   Low    → gauge-wide box, text below the Low line
//   Open   → 1-candle-wide box just outside the gauge on the Price Label Side,
//            text on the side of the Open line AWAY from current price
//   Growth → 1-candle-wide box on the same side, at the current price, text
//            beyond it (above when bullish, below when bearish): the $ change
//            from the open plus, optionally, the % change
// Open/Growth text flows outward from the gauge (left-aligned on the Right
// side, right-aligned on the Left side). Box height scales with price
// (≈0.001% of the open, at least one tick). Boxes carry no tooltips (Pine
// boxes don't support them), which is why the % can be shown in the box.
string gauge_captionMode  = input.string("Boxes", "Caption Mode", options=["Labels", "Boxes"], inline="cap", group="── Caption Mode ──")
string gauge_captionAlign = input.string("Center", "Align", options=["Left", "Center", "Right"], inline="cap", group="── Caption Mode ──", tooltip="Labels: classic pointer labels beside the gauge. Boxes: the pointer labels on the left-hand side of the gauge are hidden (the right-hand ones stay), plus box captions — High/Low captions ride on their lines inside a thin box spanning the gauge width (High above, Low below); the Open price and the growth from the open each get a 1-candle-wide box just outside the gauge on the Price Label Side. Align applies to the High/Low boxes only: Center centers them over the gauge, Left/Right anchor them to that edge. Open/Growth text always flows outward from the gauge.")
bool   gauge_capGrowthPct = input.bool(true, "Show % In Growth Box", group="── Caption Mode ──", tooltip="Boxes mode only: appends the % change from the period's open to the growth box ($ change) on every gauge.")
bool   gauge_capBoxes     = gauge_captionMode == "Boxes"
string gauge_capHAl       = gauge_captionAlign == "Left" ? text.align_left : gauge_captionAlign == "Right" ? text.align_right : text.align_center

// ════════════════════════════════════════════════════════════════════════════════
// ── SELLS / BUYS ARROWS (DAY / WEEK / MONTH) ─────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
// Sells: 1px arrow from the period High down to current price, never past the
// Open (= the candle's upper wick). Buys: from the period Low up to current
// price, never past the Open (= the lower wick). Each arrow is drawn only when
// it passes the significance gates: body ≥ Min Body × ATR, wick ≥ Min Wick × ATR
// and ≥ Min Wick % of the High–Low range, and (optionally) enough of the period
// has elapsed. ATR = that timeframe's ATR of completed candles (no repaint).
// Arrow color follows the palette (High/Low
// label colors), the label background uses the palette's bull/bear background,
// text is white; hover the label for candle insight.
bool   flow_enable  = input.bool(true, "Show Sells / Buys Arrows", group="── Sells / Buys Arrows ──", tooltip="Day, Week and Month gauges only. Sells: arrow from the period High down to current price, stopping at the Open. Buys: arrow from the period Low up to current price, stopping at the Open. Hover the label for candle details.")
int    flow_atrLen     = input.int(14, "ATR Length", minval=1, maxval=100, group="── Sells / Buys Arrows ──", tooltip="Length of the ATR used for the significance gates, computed on each gauge's own timeframe (Day / Week / Month) from completed candles, so it doesn't repaint.")
float  flow_minBodyAtr = input.float(0.10, "Min Body (× ATR)", minval=0, step=0.05, group="── Sells / Buys Arrows ──", tooltip="Gate 1: both arrows stay hidden until the candle body (|price − Open|) reaches this multiple of the timeframe's ATR. Hides the arrows right after the open and while price hovers around the Open.")
float  flow_minWickAtr = input.float(0.15, "Min Wick (× ATR)", minval=0, step=0.05, inline="wick", group="── Sells / Buys Arrows ──")
float  flow_minWickRng = input.float(25.0, "% of Range", minval=0, maxval=100, step=1, inline="wick", group="── Sells / Buys Arrows ──", tooltip="Gate 2: each arrow shows only when its own wick is at least this multiple of the timeframe's ATR AND at least this % of the current High–Low range. The first filters tiny wicks on quiet candles; the second filters wicks that are trivial next to a large body.")
float  flow_minElapsed = input.float(0.0, "Min Elapsed % of Period", minval=0, maxval=100, step=1, group="── Sells / Buys Arrows ──", tooltip="Optional gate 3: no arrows until this share of the Day / Week / Month has elapsed. 0 = off.")
int    flow_offset  = input.int(1, "Bars Right of Gauge", minval=1, maxval=20, group="── Sells / Buys Arrows ──", tooltip="Column of both arrows, counted from the gauge's outer box. 1 = the next candle.")
int    flow_lblOffset = input.int(0, "Label Bars Right of Arrow", minval=0, maxval=20, group="── Sells / Buys Arrows ──", tooltip="Horizontal position of the 'Sells' / 'Buys' labels, in bars to the right of the arrows. The labels are left-aligned, so their text flows to the right from that point. 0 = on the arrow.")
int    flow_arrOpacity = input.int(50, "Arrow Opacity %", minval=0, maxval=100, group="── Sells / Buys Arrows ──", tooltip="Opacity of the Sells and Buys arrow lines. 0 = fully transparent, 100 = fully opaque. Label backgrounds are not affected.")
int    flow_arrTrans   = 100 - flow_arrOpacity

// ════════════════════════════════════════════════════════════════════════════════
// ── GAUGE COLORS (GLOBAL) ─────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
string palette = input.string("Custom", "Gauge Color Palette", options=["Custom", "Classic", "Ocean", "Sunset", "Neon", "Monochrome", "Desert", "Oldbook", "OldWest", "Vivid"], group="── Gauge Colors ──", tooltip="Custom: every gauge uses the Bullish/Bearish Background and Scope High/Low Label colors below.\nAny other option: overrides the backgrounds and the High/Low label text on every gauge with the selected palette's colors. Foreground colors stay editable at all times.")
color gauge_bull_bg_in = input.color(color.rgb(0,83,75),   "Bullish Background", group="── Gauge Colors ──", inline="gb")
color gauge_bull_fg    = input.color(color.rgb(0,194,174), "Foreground",         group="── Gauge Colors ──", inline="gb")
color gauge_bear_bg_in = input.color(color.rgb(85,48,0),   "Bearish Background", group="── Gauge Colors ──", inline="br")
color gauge_bear_fg    = input.color(color.rgb(255,153,0), "Foreground",         group="── Gauge Colors ──", inline="br")
color gauge_scopeHighLabelColor = input.color(color.rgb(0,194,174), "Scope High Label Color", group="── Gauge Colors ──", tooltip="Text color of the High price label on every gauge when Gauge Color Palette is Custom. Any other palette overrides it with a lightened version of the palette's bullish color.")
color gauge_scopeLowLabelColor  = input.color(color.rgb(255,153,0), "Scope Low Label Color",  group="── Gauge Colors ──", tooltip="Text color of the Low price label on every gauge when Gauge Color Palette is Custom. Any other palette overrides it with a lightened version of the palette's bearish color.")

// === Palette Definitions === 
colorGreen = palette == 'Classic' ? color.rgb(0, 57, 55) : palette == 'Ocean' ? color.rgb(0, 54, 93) : palette == 'Sunset' ? color.rgb(102, 61, 0) : palette == 'Neon' ? color.rgb(0, 80, 145) : palette == 'Monochrome' ? color.rgb(117, 117, 117) : palette == 'Desert' ? color.rgb(0, 39, 35) : palette == 'Oldbook' ? color.rgb(63, 73, 7) : palette == 'OldWest' ? color.rgb(63, 77, 3) : color.rgb(0, 255, 191)
colorRed   = palette == 'Classic' ? color.rgb(72, 0, 0)  : palette == 'Ocean' ? color.rgb(0, 20, 85) : palette == 'Sunset' ? color.rgb(35, 34, 32) : palette == 'Neon' ? color.rgb(42, 45, 51) : palette == 'Monochrome' ? color.rgb(65, 65, 65) : palette == 'Desert' ? color.rgb(61, 37, 0) : palette == 'Oldbook' ? color.rgb(49, 43, 5)    : palette == 'OldWest' ? color.rgb(49, 10, 0) : color.rgb(255, 0, 0, 100)

// ════════════════════════════════════════════════════════════════════════════════
// ── TIMEFRAME GUARDS ──────────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
bool tf_4H    = timeframe.isintraday
bool tf_Day   = not timeframe.isweekly and not timeframe.ismonthly
bool tf_Week  = not timeframe.ismonthly
bool tf_Month = true
bool tf_Year  = true

// ════════════════════════════════════════════════════════════════════════════════
// ── AUTO LAYOUT ───────────────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
// Only gauges that are enabled AND allowed on the current timeframe take a slot,
// in order 4H → Day → Week → Month → Year. Step = scope box width + separation,
// so the gap between outer boxes always equals the Separation input. When the
// previous-candle gauges are on, each slot also reserves room for one on the
// left (width + gap), and the Separation is kept between outer edges.
int gauge_widthBars = gauge_widthMode == "Reduced (2 Bars)" ? 2 : gauge_widthMode == "Thin (1 Bar)" ? 1 : 3
int gauge_prevBlock = prev_enable ? gauge_widthBars + prev_gap : 0
int gauge_step      = gauge_widthBars + gauge_separation + gauge_prevBlock
int gauge_base      = gauge_startOffset + gauge_prevBlock

bool h4_on  = h4_enable  and tf_4H
bool day_on = day_enable and tf_Day
bool wk_on  = wk_enable  and tf_Week
bool mo_on  = mo_enable  and tf_Month
bool yr_on  = yr_enable  and tf_Year

int gauge_slot = 0
int h4_pos  = gauge_base + gauge_step * gauge_slot
gauge_slot := gauge_slot + (h4_on  ? 1 : 0)
int day_pos = gauge_base + gauge_step * gauge_slot
gauge_slot := gauge_slot + (day_on ? 1 : 0)
int wk_pos  = gauge_base + gauge_step * gauge_slot
gauge_slot := gauge_slot + (wk_on  ? 1 : 0)
int mo_pos  = gauge_base + gauge_step * gauge_slot
gauge_slot := gauge_slot + (mo_on  ? 1 : 0)
int yr_pos  = gauge_base + gauge_step * gauge_slot

// ════════════════════════════════════════════════════════════════════════════════
// ── HELPERS ───────────────────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
// Blend a color toward white to make it appear brighter, preserving its base hue.
f_brighten(color c, float amt) =>
    int r = int(math.round(color.r(c) + (255 - color.r(c)) * amt))
    int g = int(math.round(color.g(c) + (255 - color.g(c)) * amt))
    int b = int(math.round(color.b(c) + (255 - color.b(c)) * amt))
    color.new(color.rgb(r, g, b), color.t(c))

// Pushes a transparency toward 100 by fade % (previous-candle gauges).
f_fade(int t, int fade) => int(math.round(t + (100 - t) * fade / 100.0))

// Positions one caption box (Boxes caption mode): a thin box spanning x1 → x2
// on level y. above = true: box sits on the line with bottom-aligned text, so
// the text reads above the line; false: box hangs under the line with
// top-aligned text, so it reads below.
f_setCap(box b, int x1, int x2, float y, float h, bool above, string txt, color tc, color bg, string hal) =>
    box.set_lefttop     (b, x1, above ? y + h : y)
    box.set_rightbottom (b, x2, above ? y : y - h)
    box.set_text        (b, txt)
    box.set_text_color  (b, tc)
    box.set_bgcolor     (b, bg)
    box.set_text_halign (b, hal)
    box.set_text_valign (b, above ? text.align_bottom : text.align_top)

// Hides a caption box (empty text, no background).
f_hideCap(box b) =>
    box.set_text   (b, "")
    box.set_bgcolor(b, color(na))

// Tooltip formatters (Sells / Buys arrows).
f_usd(float v) => str.tostring(math.round(v, 0), "$#,##0")
f_pct(float v) => (v >= 0 ? "+" : "") + str.tostring(v, "0.00") + "%"

// Share of the current higher-timeframe period that has elapsed, 0–100.
f_elapsed(string tf) =>
    int t0 = time(tf)
    int t1 = time_close(tf)
    na(t0) or na(t1) or t1 <= t0 ? 100.0 : math.max(0.0, math.min(100.0, float(timenow - t0) / float(t1 - t0) * 100))

// ════════════════════════════════════════════════════════════════════════════════
// ── EFFECTIVE GAUGE COLORS (Palette override) ─────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
bool useCustomGaugeColors = palette == "Custom"

color gauge_bullBg = useCustomGaugeColors ? gauge_bull_bg_in : colorGreen
color gauge_bearBg = useCustomGaugeColors ? gauge_bear_bg_in : colorRed

// High/Low label text: Custom uses the Scope Label inputs; any other palette uses
// its own bullish/bearish colors, lightened 50% toward white for readability.
color gauge_highTxtCol = useCustomGaugeColors ? gauge_scopeHighLabelColor : f_brighten(colorGreen, 0.5)
color gauge_lowTxtCol  = useCustomGaugeColors ? gauge_scopeLowLabelColor  : f_brighten(colorRed,   0.5)

// ════════════════════════════════════════════════════════════════════════════════
// ── SECURITY DATA ─────────────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
h4_open    = request.security(syminfo.tickerid, "240", open,  lookahead=barmerge.lookahead_on)
h4_high    = request.security(syminfo.tickerid, "240", high,  lookahead=barmerge.lookahead_on)
h4_low     = request.security(syminfo.tickerid, "240", low,   lookahead=barmerge.lookahead_on)

daily_open  = request.security(syminfo.tickerid, "D", open,  lookahead=barmerge.lookahead_on)
daily_high  = request.security(syminfo.tickerid, "D", high,  lookahead=barmerge.lookahead_on)
daily_low   = request.security(syminfo.tickerid, "D", low,   lookahead=barmerge.lookahead_on)

weekly_open  = request.security(syminfo.tickerid, "W", open,  lookahead=barmerge.lookahead_on)
weekly_high  = request.security(syminfo.tickerid, "W", high,  lookahead=barmerge.lookahead_on)
weekly_low   = request.security(syminfo.tickerid, "W", low,   lookahead=barmerge.lookahead_on)

monthly_open  = request.security(syminfo.tickerid, "M", open,  lookahead=barmerge.lookahead_on)
monthly_high  = request.security(syminfo.tickerid, "M", high,  lookahead=barmerge.lookahead_on)
monthly_low   = request.security(syminfo.tickerid, "M", low,   lookahead=barmerge.lookahead_on)

yearly_open  = request.security(syminfo.tickerid, "12M", open,  lookahead=barmerge.lookahead_on)
yearly_high  = request.security(syminfo.tickerid, "12M", high,  lookahead=barmerge.lookahead_on)
yearly_low   = request.security(syminfo.tickerid, "12M", low,   lookahead=barmerge.lookahead_on)

// Previous completed candle per gauge timeframe (Previous Candle Gauges).
// [1] + lookahead_on = the last closed candle, no repaint.
[h4_p_open, h4_p_high, h4_p_low, h4_p_close] = request.security(syminfo.tickerid, "240", [open[1], high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)
[daily_p_open, daily_p_high, daily_p_low, daily_p_close] = request.security(syminfo.tickerid, "D", [open[1], high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)
[weekly_p_open, weekly_p_high, weekly_p_low, weekly_p_close] = request.security(syminfo.tickerid, "W", [open[1], high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)
[monthly_p_open, monthly_p_high, monthly_p_low, monthly_p_close] = request.security(syminfo.tickerid, "M", [open[1], high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)
[yearly_p_open, yearly_p_high, yearly_p_low, yearly_p_close] = request.security(syminfo.tickerid, "12M", [open[1], high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)

// ATR of completed candles per gauge timeframe (Sells / Buys significance gates).
daily_atr   = request.security(syminfo.tickerid, "D", ta.atr(flow_atrLen)[1], lookahead=barmerge.lookahead_on)
weekly_atr  = request.security(syminfo.tickerid, "W", ta.atr(flow_atrLen)[1], lookahead=barmerge.lookahead_on)
monthly_atr = request.security(syminfo.tickerid, "M", ta.atr(flow_atrLen)[1], lookahead=barmerge.lookahead_on)

daily_elapsed   = f_elapsed("D")
weekly_elapsed  = f_elapsed("W")
monthly_elapsed = f_elapsed("M")

// ════════════════════════════════════════════════════════════════════════════════
// ── GAUGE DRAWING PROCEDURE ───────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
drawGauge(
     int    gOffset,
     float  refOpen,  float  refHigh,  float  refLow,
     color  bullBg,   color  bullFg,
     color  bearBg,   color  bearFg,
     string labelTxt,
     bool   showPercent,
     int    innerBoxTrans,
     int    scopeBoxTrans,
     int    scopeBorderTrans,
     int    innerBorderTrans,
     color  priceLabelColor,
     color  scopeHighLabelColor,
     color  scopeLowLabelColor,
     bool   showPriceLabel,
     string priceLabelSide,
     int    innerBrightness,
     int    widthBars,
     int    reducedBarWidth,
     bool   captionBoxes,
     string capHAlign,
     bool   capGrowthPct,
     bool   showFlow,
     float  gAtr,
     float  elapsedPct,
     float  minBodyAtr,
     float  minWickAtr,
     float  minWickRng,
     float  minElapsed,
     int    flowOffset,
     int    flowLblOffset,
     int    flowArrTrans) =>

    isAbove = close >= refOpen
    dynCol  = isAbove ? bullFg : bearFg
    dynBg   = isAbove ? bullBg : bearBg
    innerDynBg = innerBrightness > 0 ? f_brighten(dynBg, innerBrightness / 100.0) : dynBg

    var box  g_bull_scope = box.new(0, open, 0, open,
         border_color=color.new(bullBg, scopeBorderTrans), border_width=1,
         border_style=line.style_dotted,
         text=labelTxt, text_valign=text.align_top, text_size=size.tiny,
         text_color=color.white, bgcolor=color.new(bullBg, scopeBoxTrans))
    var line g_bull_top   = line.new(0, open, 0, open, color=bullFg, width=2)
    var line g_bull_base  = line.new(0, open, 0, open, color=bullBg, width=3)
    var box  g_bull_prc   = box.new(0, open, 0, open,
         border_color=color.new(bullBg, innerBorderTrans), border_width=1,
         bgcolor=color.new(innerDynBg, innerBoxTrans))
    var line g_bull_prc_l = line.new(0, open, 0, open, color=bullBg, width=4)

    var box  g_bear_scope = box.new(0, open, 0, open,
         border_color=color.new(bearBg, scopeBorderTrans), border_width=1,
         border_style=line.style_dotted,
         text=labelTxt, text_valign=text.align_bottom, text_size=size.tiny,
         text_color=color.white, bgcolor=color.new(bearBg, scopeBoxTrans))
    var line g_bear_top   = line.new(0, open, 0, open, color=bullBg, width=3)
    var line g_bear_base  = line.new(0, open, 0, open, color=bearFg, width=2)
    var box  g_bear_prc   = box.new(0, open, 0, open,
         border_color=color.new(bullBg, innerBorderTrans), border_width=1,
         bgcolor=color.new(innerDynBg, innerBoxTrans))
    var line g_bear_prc_l = line.new(0, open, 0, open, color=dynCol, width=4)

    var line  g_open_mk  = line.new(0, open, 0, open,
         color=color.white, width=3, style=line.style_solid)
    var label g_open_price_lbl = label.new(0, open,
         text="", style=label.style_label_left, textalign=text.align_left,
         color=color.new(color.black, 100), textcolor=priceLabelColor, size=size.small)

    var label g_high_lbl = label.new(0, open,
         text="", style=label.style_label_right,
         color=color.new(bullBg, 80), textcolor=scopeHighLabelColor, size=size.small)
    var label g_low_lbl  = label.new(0, open,
         text="", style=label.style_label_right,
         color=color.new(bearBg, 80), textcolor=scopeLowLabelColor, size=size.small)

    var int   y_adj     = 1
    var label g_pnl_lbl = label.new(0, open,
         text="", style=label.style_label_left, textalign=text.align_left,
         color=color.new(dynCol, 100), textcolor=priceLabelColor, size=size.small)

    // Caption boxes (Boxes caption mode) — created once, hidden in Labels mode.
    // The pointer labels above are drawn in both modes, except that Boxes mode
    // hides the group on the gauge's left-hand side (see hideRangeLbl/hidePriceLbl).
    var box g_high_cap = box.new(0, open, 0, open, border_color=color(na), border_width=0, bgcolor=color(na), text="", text_size=size.small)
    var box g_low_cap  = box.new(0, open, 0, open, border_color=color(na), border_width=0, bgcolor=color(na), text="", text_size=size.small)
    var box g_open_cap = box.new(0, open, 0, open, border_color=color(na), border_width=0, bgcolor=color(na), text="", text_size=size.small)
    var box g_pnl_cap  = box.new(0, open, 0, open, border_color=color(na), border_width=0, bgcolor=color(na), text="", text_size=size.small)

    // Sells / Buys arrows — created once, hidden unless shown.
    var line  g_sell_arr = line.new(0, open, 0, open, color=color(na), style=line.style_arrow_right, width=1)
    var line  g_buy_arr  = line.new(0, open, 0, open, color=color(na), style=line.style_arrow_right, width=1)
    var label g_sell_lbl = label.new(0, open, text="", style=label.style_label_left, textalign=text.align_left, color=color(na), textcolor=color.white, size=size.tiny)
    var label g_buy_lbl  = label.new(0, open, text="", style=label.style_label_left, textalign=text.align_left, color=color(na), textcolor=color.white, size=size.tiny)

    // Scope box span by width mode (L..R):
    //   Original (3): gOffset-2 .. gOffset+1, inner box inset at gOffset-1 .. gOffset
    //   Reduced  (2): gOffset-1 .. gOffset+1, inner marker collapsed to gOffset,
    //                 rendered as a centered bar from its border thickness
    //   Thin     (1): gOffset-1 .. gOffset,   inner box fills the same single bar
    int L = widthBars == 3 ? bar_index + gOffset - 2 : bar_index + gOffset - 1
    int R = widthBars == 1 ? bar_index + gOffset     : bar_index + gOffset + 1
    int l = widthBars == 2 ? bar_index + gOffset     : bar_index + gOffset - 1
    int r = bar_index + gOffset
    int innerBorderW = widthBars == 2 ? reducedBarWidth : 1

    // Label anchoring: text flows outward from the scope box. Open price + P&L
    // sit on the chosen side, one bar inside the outer edge (on the edge itself
    // in Thin mode, where one bar inward would be the opposite edge); High/Low
    // hug the opposite outer edge so the two groups never stack.
    bool   sideRight  = priceLabelSide == "Right"
    int    priceInset = widthBars == 1 ? 0 : 1
    int    priceEdgeX = sideRight ? R - priceInset : L + priceInset
    int    rangeEdgeX = sideRight ? L : R
    string priceStyle = sideRight ? label.style_label_left  : label.style_label_right
    string priceAlign = sideRight ? text.align_left         : text.align_right
    string rangeStyle = sideRight ? label.style_label_right : label.style_label_left
    string rangeAlign = sideRight ? text.align_right        : text.align_left

    // Boxes caption mode hides whichever pointer-label group sits on the
    // gauge's LEFT-hand side: High/Low when Price Label Side = Right, Open +
    // P&L when it = Left. The right-hand group stays visible.
    bool hideRangeLbl = captionBoxes and sideRight
    bool hidePriceLbl = captionBoxes and not sideRight

    box.set_lefttop    (g_bull_scope, L, refHigh)
    box.set_rightbottom(g_bull_scope, R, refOpen)
    line.set_xy1(g_bull_top,  L, refHigh)
    line.set_xy2(g_bull_top,  R, refHigh)
    line.set_xy1(g_bull_base, L, refOpen)
    line.set_xy2(g_bull_base, R, refOpen)
    box.set_lefttop    (g_bull_prc, l, close)
    box.set_rightbottom(g_bull_prc, r, refOpen)
    box.set_bgcolor    (g_bull_prc, color.new(innerDynBg, innerBoxTrans))
    box.set_border_color(g_bull_prc, color.new(dynBg, innerBorderTrans))
    box.set_border_width(g_bull_prc, innerBorderW)
    line.set_xy1(g_bull_prc_l, l, close)
    line.set_xy2(g_bull_prc_l, r, close)
    line.set_color(g_bull_prc_l, bullBg)

    box.set_lefttop    (g_bear_scope, L, refOpen)
    box.set_rightbottom(g_bear_scope, R, refLow)
    line.set_xy1(g_bear_top,  L, refOpen)
    line.set_xy2(g_bear_top,  R, refOpen)
    line.set_xy1(g_bear_base, L, refLow)
    line.set_xy2(g_bear_base, R, refLow)
    box.set_lefttop    (g_bear_prc, l, close)
    box.set_rightbottom(g_bear_prc, r, refOpen)
    box.set_bgcolor    (g_bear_prc, color.new(innerDynBg, innerBoxTrans))
    box.set_border_color(g_bear_prc, color.new(dynBg, innerBorderTrans))
    box.set_border_width(g_bear_prc, innerBorderW)
    line.set_xy1(g_bear_prc_l, l, close)
    line.set_xy2(g_bear_prc_l, r, close)
    line.set_color(g_bear_prc_l, dynCol)

    line.set_xy1(g_open_mk, L, refOpen)
    line.set_xy2(g_open_mk, R, refOpen)

    string openPriceTxt = str.tostring(math.round(refOpen, 0), "$0,000")
    if showPriceLabel and not hidePriceLbl
        label.set_xy       (g_open_price_lbl, priceEdgeX - 2, refOpen)
        label.set_style    (g_open_price_lbl, priceStyle)
        label.set_textalign(g_open_price_lbl, priceAlign)
        label.set_text     (g_open_price_lbl, sideRight ? "◄" + openPriceTxt : openPriceTxt + " ▸")
        label.set_tooltip  (g_open_price_lbl, labelTxt + " Open: " + openPriceTxt)
    else
        label.set_text     (g_open_price_lbl, "")

    float pctHigh = refOpen != 0 ? (refHigh - refOpen) / refOpen * 100 : 0
    float pctLow  = refOpen != 0 ? (refLow  - refOpen) / refOpen * 100 : 0

    string highTxt = str.tostring(math.round(refHigh, 0), "$0,000")
         + (showPercent ? "\n(" + (pctHigh >= 0 ? "+" : "") + str.tostring(math.round(pctHigh, 2)) + "%)" : "")
    string lowTxt  = str.tostring(math.round(refLow, 0), "$0,000")
         + (showPercent ? "\n(" + (pctLow >= 0 ? "+" : "") + str.tostring(math.round(pctLow, 2)) + "%)" : "")

    if not hideRangeLbl
        label.set_xy       (g_high_lbl, rangeEdgeX, refHigh)
        label.set_style    (g_high_lbl, rangeStyle)
        label.set_textalign(g_high_lbl, rangeAlign)
        label.set_text     (g_high_lbl, highTxt)
        label.set_color    (g_high_lbl, color.new(bullBg, 80))
        label.set_textcolor(g_high_lbl, scopeHighLabelColor)
        label.set_xy       (g_low_lbl,  rangeEdgeX, refLow)
        label.set_style    (g_low_lbl,  rangeStyle)
        label.set_textalign(g_low_lbl,  rangeAlign)
        label.set_text     (g_low_lbl,  lowTxt)
        label.set_color    (g_low_lbl,  color.new(bearBg, 80))
        label.set_textcolor(g_low_lbl,  scopeLowLabelColor)
    else
        label.set_text     (g_high_lbl, "")
        label.set_color    (g_high_lbl, color.new(color.black, 100))
        label.set_text     (g_low_lbl,  "")
        label.set_color    (g_low_lbl,  color.new(color.black, 100))

    string pnlTxt = str.tostring(math.round(close - refOpen, 0), "$#,000")
    y_adj := close - refOpen < 0 ? -1 : 1
    if showPriceLabel and not hidePriceLbl
        label.set_xy       (g_pnl_lbl, priceEdgeX, close + y_adj)
        label.set_style    (g_pnl_lbl, priceStyle)
        label.set_textalign(g_pnl_lbl, priceAlign)
        label.set_text     (g_pnl_lbl, pnlTxt)
        label.set_tooltip  (g_pnl_lbl,
             str.tostring(((close - refOpen) / refOpen) * 100, format.percent) + "  " +
             str.tostring(math.round(close - refOpen, 0), "$#,000") +
             "  from " + labelTxt + " Open: " +
             str.tostring(math.round(refOpen, 0), "$0,000"))
        label.set_color    (g_pnl_lbl, color.new(dynCol, 100))
        label.set_textcolor(g_pnl_lbl, priceLabelColor)
    else
        label.set_text     (g_pnl_lbl, "")

    // ── Box captions (Caption Mode = Boxes) ──────────────────────────────────
    // High above its line, Low below its line, both spanning the gauge width.
    // Open and Growth get 1-candle-wide boxes just outside the gauge on the
    // Price Label Side (capX1 → capX2), text flowing outward. Open reads on the
    // side of the Open line away from current price (below it when price is
    // above the open, above it when price is below); Growth reads beyond the
    // current price (above close when bullish, below when bearish).
    if captionBoxes
        float  capH       = math.max(syminfo.mintick, math.abs(refOpen) * 0.00001)
        int    capX1      = sideRight ? R + 1 : L - 2
        int    capX2      = capX1 + 1
        string capOutAl   = sideRight ? text.align_left : text.align_right
        float  growthPct  = refOpen != 0 ? (close - refOpen) / refOpen * 100 : 0
        string growthTxt  = pnlTxt + (capGrowthPct ? "  (" + (growthPct >= 0 ? "+" : "") + str.tostring(growthPct, "0.00") + "%)" : "")
        string openCapTxt = sideRight ? "◄" + openPriceTxt : openPriceTxt + " ▸"
        f_setCap(g_high_cap, L, R, refHigh, capH, true,  highTxt, scopeHighLabelColor, color.new(bullBg, 80), capHAlign)
        f_setCap(g_low_cap,  L, R, refLow,  capH, false, lowTxt,  scopeLowLabelColor,  color.new(bearBg, 80), capHAlign)
        if showPriceLabel
            f_setCap(g_open_cap, capX1, capX2, refOpen, capH, not isAbove, openCapTxt, priceLabelColor, color(na), capOutAl)
            f_setCap(g_pnl_cap,  capX1, capX2, close,   capH, isAbove,     growthTxt,  priceLabelColor, color(na), capOutAl)
        else
            f_hideCap(g_open_cap)
            f_hideCap(g_pnl_cap)
    else
        f_hideCap(g_high_cap)
        f_hideCap(g_low_cap)
        f_hideCap(g_open_cap)
        f_hideCap(g_pnl_cap)

    // ── Sells / Buys arrows (Day / Week / Month) ────────────────────────
    // Column: flowOffset bars right of the outer box. Sells runs High → price,
    // clamped at the Open (the upper wick); Buys runs Low → price, clamped
    // at the Open (the lower wick). Gates: body ≥ minBodyAtr × ATR (both
    // arrows), wick ≥ minWickAtr × ATR and ≥ minWickRng % of range (each arrow),
    // elapsed ≥ minElapsed % of the period (both arrows).
    float fRng     = refHigh - refLow
    float sellEnd  = math.max(close, refOpen)
    float buyEnd   = math.min(close, refOpen)
    float sellLen  = refHigh - sellEnd
    float buyLen   = buyEnd - refLow
    float sellPctR = fRng > 0 ? sellLen / fRng * 100 : 0
    float buyPctR  = fRng > 0 ? buyLen  / fRng * 100 : 0
    float sellPctP = refHigh != 0 ? sellLen / refHigh * 100 : 0
    float buyPctP  = refLow  != 0 ? buyLen  / refLow  * 100 : 0
    float fBody    = math.abs(close - refOpen)
    float sellPctB = fBody > 0 ? sellLen / fBody * 100 : 0
    float buyPctB  = fBody > 0 ? buyLen  / fBody * 100 : 0
    bool  atrOk    = not na(gAtr) and gAtr > 0
    float bodyAtr  = atrOk ? fBody   / gAtr : 0
    float sellAtr  = atrOk ? sellLen / gAtr : 0
    float buyAtr   = atrOk ? buyLen  / gAtr : 0
    bool  bodyOk   = atrOk and bodyAtr >= minBodyAtr
    bool  timeOk   = elapsedPct >= minElapsed
    bool  sellOk   = sellLen > 0 and sellAtr >= minWickAtr and sellPctR >= minWickRng
    bool  buyOk    = buyLen  > 0 and buyAtr  >= minWickAtr and buyPctR  >= minWickRng
    bool  showSell = showFlow and bodyOk and timeOk and sellOk
    bool  showBuy  = showFlow and bodyOk and timeOk and buyOk
    int   fX       = R + flowOffset
    int   fLblX    = fX + flowLblOffset

    string candleTip = ""
    if showSell or showBuy
        float  bodyChg  = close - refOpen
        float  bodyPct  = refOpen != 0 ? bodyChg / refOpen * 100 : 0
        float  bodyOfR  = fRng > 0 ? math.abs(bodyChg) / fRng * 100 : 0
        float  rngPct   = refOpen != 0 ? fRng / refOpen * 100 : 0
        float  closePos = fRng > 0 ? (close - refLow) / fRng * 100 : 50
        string balance  = sellLen > buyLen * 1.2 ? "Sellers stronger (upper wick dominates)" : buyLen > sellLen * 1.2 ? "Buyers stronger (lower wick dominates)" : "Balanced wicks"
        candleTip := labelTxt + " CANDLE — " + (bodyChg >= 0 ? "Bullish" : "Bearish") +
             "\nO " + f_usd(refOpen) + "   H " + f_usd(refHigh) + "   L " + f_usd(refLow) + "   Now " + f_usd(close) +
             "\nRange: " + f_usd(fRng) + "  (" + str.tostring(rngPct, "0.00") + "% of open)" +
             "\nBody: " + f_usd(math.abs(bodyChg)) + "  " + f_pct(bodyPct) + "  |  " + str.tostring(bodyOfR, "0.0") + "% of range" +
             "\nUpper wick (Sells): " + f_usd(sellLen) + "  |  " + str.tostring(sellPctB, "0.0") + "% of body  |  " + str.tostring(sellPctR, "0.0") + "% of range  |  " + f_pct(-sellPctP) + " from High" +
             "\nLower wick (Buys): " + f_usd(buyLen) + "  |  " + str.tostring(buyPctB, "0.0") + "% of body  |  " + str.tostring(buyPctR, "0.0") + "% of range  |  " + f_pct(buyPctP) + " from Low" +
             "\nPrice at " + str.tostring(closePos, "0.0") + "% of range (0 = Low, 100 = High)" +
             "\n" + balance +
             "\n\nGATES  (ATR " + f_usd(gAtr) + ")" +
             "\nBody: " + str.tostring(bodyAtr, "0.00") + "× ATR  (min " + str.tostring(minBodyAtr, "0.00") + ")  " + (bodyOk ? "✓" : "✗") +
             "\nUpper wick: " + str.tostring(sellAtr, "0.00") + "× ATR, " + str.tostring(sellPctR, "0.0") + "% of range  (min " + str.tostring(minWickAtr, "0.00") + "× / " + str.tostring(minWickRng, "0.#") + "%)  " + (sellOk ? "✓" : "✗") +
             "\nLower wick: " + str.tostring(buyAtr, "0.00") + "× ATR, " + str.tostring(buyPctR, "0.0") + "% of range  (min " + str.tostring(minWickAtr, "0.00") + "× / " + str.tostring(minWickRng, "0.#") + "%)  " + (buyOk ? "✓" : "✗") +
             "\nElapsed: " + str.tostring(elapsedPct, "0.0") + "% of period  (min " + str.tostring(minElapsed, "0.#") + "%)  " + (timeOk ? "✓" : "✗")

    if showSell
        line.set_xy1     (g_sell_arr, fX, refHigh)
        line.set_xy2     (g_sell_arr, fX, sellEnd)
        line.set_color   (g_sell_arr, color.new(scopeLowLabelColor, flowArrTrans))
        label.set_xy     (g_sell_lbl, fLblX, (refHigh + sellEnd) / 2)
        label.set_text   (g_sell_lbl, "Sells")
        label.set_color  (g_sell_lbl, color.new(bearBg, 0))
        label.set_tooltip(g_sell_lbl, "SELLS — price pushed " + f_usd(sellLen) + " down from the " + labelTxt + " High" + (close < refOpen ? " (clamped at the Open)" : "") + "\n\n" + candleTip)
    else
        line.set_color   (g_sell_arr, color(na))
        label.set_text   (g_sell_lbl, "")
        label.set_color  (g_sell_lbl, color(na))
        label.set_tooltip(g_sell_lbl, "")

    if showBuy
        line.set_xy1     (g_buy_arr, fX, refLow)
        line.set_xy2     (g_buy_arr, fX, buyEnd)
        line.set_color   (g_buy_arr, color.new(scopeHighLabelColor, flowArrTrans))
        label.set_xy     (g_buy_lbl, fLblX, (refLow + buyEnd) / 2)
        label.set_text   (g_buy_lbl, "Buys")
        label.set_color  (g_buy_lbl, color.new(bullBg, 0))
        label.set_tooltip(g_buy_lbl, "BUYS — price lifted " + f_usd(buyLen) + " up from the " + labelTxt + " Low" + (close > refOpen ? " (clamped at the Open)" : "") + "\n\n" + candleTip)
    else
        line.set_color   (g_buy_arr, color(na))
        label.set_text   (g_buy_lbl, "")
        label.set_color  (g_buy_lbl, color(na))
        label.set_tooltip(g_buy_lbl, "")

// ════════════════════════════════════════════════════════════════════════════════
// ── PREVIOUS CANDLE GAUGE PROCEDURE (reference only, no labels) ──────────────
// ════════════════════════════════════════════════════════════════════════════════
// gOffset = the LIVE gauge's offset. The previous-candle gauge is placed so its
// right edge sits `gap` bars left of the live gauge's left edge, with the same
// width-mode geometry. Scope boxes High→Open / Open→Low, inner body Open→Close,
// High/Low lines, Open marker (white) and Close marker — all faded by `fade`.
drawPrevGauge(
     int   gOffset,
     int   gap,
     float pOpen, float pHigh, float pLow, float pClose,
     color bullBg, color bullFg,
     color bearBg, color bearFg,
     int   innerBoxTrans,
     int   scopeBoxTrans,
     int   scopeBorderTrans,
     int   innerBorderTrans,
     int   innerBrightness,
     int   widthBars,
     int   reducedBarWidth,
     int   fade) =>

    bool  isBull  = pClose >= pOpen
    color dynBg   = isBull ? bullBg : bearBg
    color dynFg   = isBull ? bullFg : bearFg
    color innerBg = innerBrightness > 0 ? f_brighten(dynBg, innerBrightness / 100.0) : dynBg

    var box  p_bull_scope = box.new(0, open, 0, open, border_width=1, border_style=line.style_dotted)
    var box  p_bear_scope = box.new(0, open, 0, open, border_width=1, border_style=line.style_dotted)
    var box  p_body       = box.new(0, open, 0, open, border_width=1)
    var line p_high_ln    = line.new(0, open, 0, open, width=2)
    var line p_low_ln     = line.new(0, open, 0, open, width=2)
    var line p_open_mk    = line.new(0, open, 0, open, width=3)
    var line p_close_mk   = line.new(0, open, 0, open, width=4)

    // Same span rules as drawGauge, applied to the previous gauge's own offset.
    int mL   = widthBars == 3 ? gOffset - 2 : gOffset - 1
    int pOff = mL - gap - (widthBars == 1 ? 0 : 1)
    int L = widthBars == 3 ? bar_index + pOff - 2 : bar_index + pOff - 1
    int R = widthBars == 1 ? bar_index + pOff     : bar_index + pOff + 1
    int l = widthBars == 2 ? bar_index + pOff     : bar_index + pOff - 1
    int r = bar_index + pOff
    int innerBorderW = widthBars == 2 ? reducedBarWidth : 1

    box.set_lefttop     (p_bull_scope, L, pHigh)
    box.set_rightbottom (p_bull_scope, R, pOpen)
    box.set_bgcolor     (p_bull_scope, color.new(bullBg, f_fade(scopeBoxTrans, fade)))
    box.set_border_color(p_bull_scope, color.new(bullBg, f_fade(scopeBorderTrans, fade)))

    box.set_lefttop     (p_bear_scope, L, pOpen)
    box.set_rightbottom (p_bear_scope, R, pLow)
    box.set_bgcolor     (p_bear_scope, color.new(bearBg, f_fade(scopeBoxTrans, fade)))
    box.set_border_color(p_bear_scope, color.new(bearBg, f_fade(scopeBorderTrans, fade)))

    box.set_lefttop     (p_body, l, math.max(pOpen, pClose))
    box.set_rightbottom (p_body, r, math.min(pOpen, pClose))
    box.set_bgcolor     (p_body, color.new(innerBg, f_fade(innerBoxTrans, fade)))
    box.set_border_color(p_body, color.new(dynBg, f_fade(innerBorderTrans, fade)))
    box.set_border_width(p_body, innerBorderW)

    line.set_xy1  (p_high_ln, L, pHigh)
    line.set_xy2  (p_high_ln, R, pHigh)
    line.set_color(p_high_ln, color.new(bullFg, f_fade(0, fade)))
    line.set_xy1  (p_low_ln,  L, pLow)
    line.set_xy2  (p_low_ln,  R, pLow)
    line.set_color(p_low_ln,  color.new(bearFg, f_fade(0, fade)))

    line.set_xy1  (p_open_mk, L, pOpen)
    line.set_xy2  (p_open_mk, R, pOpen)
    line.set_color(p_open_mk, color.new(color.white, f_fade(0, fade)))
    line.set_xy1  (p_close_mk, l, pClose)
    line.set_xy2  (p_close_mk, r, pClose)
    line.set_color(p_close_mk, color.new(dynFg, f_fade(0, fade)))

// ════════════════════════════════════════════════════════════════════════════════
// ── GAUGE CALLS ───────────────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
if h4_on
    drawGauge(h4_pos,
         h4_open, h4_high, h4_low,
         gauge_bullBg, gauge_bull_fg,
         gauge_bearBg, gauge_bear_fg,
         "4H", gauge_showPercent, gauge_innerBoxTrans, gauge_scopeBoxTrans, gauge_scopeBorderTrans, gauge_innerBorderTrans,
         gauge_priceLabelColor, gauge_highTxtCol, gauge_lowTxtCol,
         gauge_showPriceLabel, gauge_priceLabelSide, gauge_innerBoxBrightness,
         gauge_widthBars, gauge_reducedBarWidth,
         gauge_capBoxes, gauge_capHAl, gauge_capGrowthPct,
         false, na, 100.0, flow_minBodyAtr, flow_minWickAtr, flow_minWickRng, flow_minElapsed, flow_offset, flow_lblOffset, flow_arrTrans)
    if prev_enable
        drawPrevGauge(h4_pos, prev_gap, h4_p_open, h4_p_high, h4_p_low, h4_p_close,
             gauge_bullBg, gauge_bull_fg, gauge_bearBg, gauge_bear_fg,
             gauge_innerBoxTrans, gauge_scopeBoxTrans, gauge_scopeBorderTrans, gauge_innerBorderTrans,
             gauge_innerBoxBrightness, gauge_widthBars, gauge_reducedBarWidth, prev_fade)

if day_on
    drawGauge(day_pos,
         daily_open, daily_high, daily_low,
         gauge_bullBg, gauge_bull_fg,
         gauge_bearBg, gauge_bear_fg,
         "DAY", gauge_showPercent, gauge_innerBoxTrans, gauge_scopeBoxTrans, gauge_scopeBorderTrans, gauge_innerBorderTrans,
         gauge_priceLabelColor, gauge_highTxtCol, gauge_lowTxtCol,
         gauge_showPriceLabel, gauge_priceLabelSide, gauge_innerBoxBrightness,
         gauge_widthBars, gauge_reducedBarWidth,
         gauge_capBoxes, gauge_capHAl, gauge_capGrowthPct,
         flow_enable, daily_atr, daily_elapsed, flow_minBodyAtr, flow_minWickAtr, flow_minWickRng, flow_minElapsed, flow_offset, flow_lblOffset, flow_arrTrans)
    if prev_enable
        drawPrevGauge(day_pos, prev_gap, daily_p_open, daily_p_high, daily_p_low, daily_p_close,
             gauge_bullBg, gauge_bull_fg, gauge_bearBg, gauge_bear_fg,
             gauge_innerBoxTrans, gauge_scopeBoxTrans, gauge_scopeBorderTrans, gauge_innerBorderTrans,
             gauge_innerBoxBrightness, gauge_widthBars, gauge_reducedBarWidth, prev_fade)

if wk_on
    drawGauge(wk_pos,
         weekly_open, weekly_high, weekly_low,
         gauge_bullBg, gauge_bull_fg,
         gauge_bearBg, gauge_bear_fg,
         "WEEK", gauge_showPercent, gauge_innerBoxTrans, gauge_scopeBoxTrans, gauge_scopeBorderTrans, gauge_innerBorderTrans,
         gauge_priceLabelColor, gauge_highTxtCol, gauge_lowTxtCol,
         gauge_showPriceLabel, gauge_priceLabelSide, gauge_innerBoxBrightness,
         gauge_widthBars, gauge_reducedBarWidth,
         gauge_capBoxes, gauge_capHAl, gauge_capGrowthPct,
         flow_enable, weekly_atr, weekly_elapsed, flow_minBodyAtr, flow_minWickAtr, flow_minWickRng, flow_minElapsed, flow_offset, flow_lblOffset, flow_arrTrans)
    if prev_enable
        drawPrevGauge(wk_pos, prev_gap, weekly_p_open, weekly_p_high, weekly_p_low, weekly_p_close,
             gauge_bullBg, gauge_bull_fg, gauge_bearBg, gauge_bear_fg,
             gauge_innerBoxTrans, gauge_scopeBoxTrans, gauge_scopeBorderTrans, gauge_innerBorderTrans,
             gauge_innerBoxBrightness, gauge_widthBars, gauge_reducedBarWidth, prev_fade)

if mo_on
    drawGauge(mo_pos,
         monthly_open, monthly_high, monthly_low,
         gauge_bullBg, gauge_bull_fg,
         gauge_bearBg, gauge_bear_fg,
         "MONTH", gauge_showPercent, gauge_innerBoxTrans, gauge_scopeBoxTrans, gauge_scopeBorderTrans, gauge_innerBorderTrans,
         gauge_priceLabelColor, gauge_highTxtCol, gauge_lowTxtCol,
         gauge_showPriceLabel, gauge_priceLabelSide, gauge_innerBoxBrightness,
         gauge_widthBars, gauge_reducedBarWidth,
         gauge_capBoxes, gauge_capHAl, gauge_capGrowthPct,
         flow_enable, monthly_atr, monthly_elapsed, flow_minBodyAtr, flow_minWickAtr, flow_minWickRng, flow_minElapsed, flow_offset, flow_lblOffset, flow_arrTrans)
    if prev_enable
        drawPrevGauge(mo_pos, prev_gap, monthly_p_open, monthly_p_high, monthly_p_low, monthly_p_close,
             gauge_bullBg, gauge_bull_fg, gauge_bearBg, gauge_bear_fg,
             gauge_innerBoxTrans, gauge_scopeBoxTrans, gauge_scopeBorderTrans, gauge_innerBorderTrans,
             gauge_innerBoxBrightness, gauge_widthBars, gauge_reducedBarWidth, prev_fade)

if yr_on
    drawGauge(yr_pos,
         yearly_open, yearly_high, yearly_low,
         gauge_bullBg, gauge_bull_fg,
         gauge_bearBg, gauge_bear_fg,
         "YEAR", gauge_showPercent, gauge_innerBoxTrans, gauge_scopeBoxTrans, gauge_scopeBorderTrans, gauge_innerBorderTrans,
         gauge_priceLabelColor, gauge_highTxtCol, gauge_lowTxtCol,
         gauge_showPriceLabel, gauge_priceLabelSide, gauge_innerBoxBrightness,
         gauge_widthBars, gauge_reducedBarWidth,
         gauge_capBoxes, gauge_capHAl, gauge_capGrowthPct,
         false, na, 100.0, flow_minBodyAtr, flow_minWickAtr, flow_minWickRng, flow_minElapsed, flow_offset, flow_lblOffset, flow_arrTrans)
    if prev_enable
        drawPrevGauge(yr_pos, prev_gap, yearly_p_open, yearly_p_high, yearly_p_low, yearly_p_close,
             gauge_bullBg, gauge_bull_fg, gauge_bearBg, gauge_bear_fg,
             gauge_innerBoxTrans, gauge_scopeBoxTrans, gauge_scopeBorderTrans, gauge_innerBorderTrans,
             gauge_innerBoxBrightness, gauge_widthBars, gauge_reducedBarWidth, prev_fade)

// EOF
````
