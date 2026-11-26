# CQ_(1)_[PRICE ACTION / INTRADAY-WEEK LEVELS] v1

- url: https://www.tradingview.com/script/tFssHXYf-CQ-1-PRICE-ACTION-INTRADAY-WEEK-LEVELS-v1/
- type: indicator
- pine_id: PUB;53d9c0fd3ded449eb243a396ea42d0a6
- version: 1.0

## Description

================================================================================
  CQ_(1)_[PRICE ACTION / INTRADAY-WEEK LEVELS] v1
  Description & User Manual
  Pine Script v6 indicator for TradingView  -  (c) CQuevedo345 / UkutaLabs
================================================================================

TABLE OF CONTENTS
-----------------
  1.  Description
  2.  Quick Start
  3.  How the Levels Are Calculated
  4.  How the Indicator Draws
  5.  Daily Ladder
  6.  Weekly Ladder
        6.1  Scaling Modes
  7.  Extra Levels
  8.  Style
        8.1  Palettes
  9.  Labels & Caption Mode
        9.1  Label Content
        9.2  Caption Mode (Labels / Boxes)
  10. History (Past Periods)
  11. Summary Tables
  12. Hit Tracking
  13. Auto-Hide & Timeframe Rules
  14. Troubleshooting / FAQ


================================================================================
1. DESCRIPTION
================================================================================

CQ_(1)_[PRICE ACTION / INTRADAY-WEEK LEVELS] merges two earlier indicators,
CQ_(O)_[INTRADAY OPEN LADDER] and CQ_(W)_[INTRAWEEK OPEN LADDER], into one
overlay.

It draws two independent ladders of Crecetrader-style (Esteban Perez)
levels. Each ladder is a symmetric set of bullish levels above and bearish
levels below its period's opening price:

  - DAILY LADDER  - anchored to the daily open (intraday levels).
  - WEEKLY LADDER - anchored to the weekly open (intraweek levels). Its
                    distances are the daily distances multiplied by a weekly
                    scale factor.

Features:
  - Configurable percent lists, plus up to five extra levels.
  - Levels reached during the current period are marked with ✓ and faded.
  - Optional ladders for past days/weeks (History).
  - Captions as pointer labels or as thin boxes riding on the lines.
  - Nine color palettes with a brightness control.
  - One optional summary table per ladder.
  - Automatic hiding on timeframes where a ladder does not make sense.

Levels do not repaint: a period's open is fixed when the period starts.


================================================================================
2. QUICK START
================================================================================

  1. Add the indicator to a chart. Use the same data feed as your level
     source (e.g. BITSTAMP:BTCUSD) so the opens match.
  2. Use a chart timeframe between 1H and 4H to see both ladders together.
     Below 1H only the Daily ladder shows; at 1D and above only the Weekly
     ladder shows (default Auto-Hide settings).
  3. Adjust each ladder's Percent List if your source uses other distances.
  4. Choose Caption Mode (Boxes or Labels) and set each ladder's Label
     Offset so the two sets of captions don't overlap.
  5. Optional: enable the Daily and/or Weekly summary tables.


================================================================================
3. HOW THE LEVELS ARE CALCULATED
================================================================================

  For every percentage p in a ladder's list:

      Bullish level = Open x (1 + p x factor / 100)
      Bearish level = Open x (1 - p x factor / 100)

  Daily ladder:   factor = 1
  Weekly ladder:  factor = Scaling factor (see 6.1)

  Example - Daily, open 84,394, list 0.382, 1, 1.5, 2:
      Bullish  84,716 · 85,238 · 85,660 · 86,082
      Bearish  84,071 · 83,550 · 83,128 · 82,706

  Example - Weekly, √Time scaling, 7 days (factor 2.646):
      0.382 % -> 1.011 %   ·   1 % -> 2.646 %
      1.5 %   -> 3.969 %   ·   2 % -> 5.292 %

  Levels are rounded according to the "Rounding" setting (default Round).


================================================================================
4. HOW THE INDICATOR DRAWS
================================================================================

  - All lines, labels, boxes and tables are rebuilt on the LAST bar of the
    chart, so they appear even when the market is closed.
  - The current period's lines run from the period start to that ladder's
    label position (Label Offset bars to the right of the last bar).
  - Past periods (History) run from their start to the next period's start.
  - Opening-price lines are always solid and one width step thicker than
    the level lines.
  - Object limits: 500 lines, 500 labels, 500 boxes. Many History periods
    combined with many percentages and extras can reach the line limit.


================================================================================
5. DAILY LADDER  (group: DAILY LADDER)
================================================================================

  Show Daily Ladder ...... on/off.
  Anchor Timeframe ....... timeframe whose open anchors the ladder
                           (default D). The chart timeframe must be lower.
  Percent List ........... comma-separated distances in %.
                           Default "0.382, 1, 1.5, 2". Spaces ignored;
                           invalid, zero or negative entries skipped;
                           duplicates removed.
  Auto-Hide Above 1D ..... hides the ladder (and its table) when the chart
                           timeframe is 1D or higher. Default ON.
  Active Lines / Width ... style (Solid, Dashed, Dotted) and width of the
                           current day's level lines.
  Open (color) ........... color of the daily open line and caption.
  Open Tag ............... text shown on the open caption (default "D-O").
  Label Offset (bars) .... default 10. Where the daily captions sit and
                           where current-day lines stop.


================================================================================
6. WEEKLY LADDER  (group: WEEKLY LADDER)
================================================================================

  Show Weekly Ladder ..... on/off.
  Anchor Timeframe ....... default W. The chart timeframe must be lower.
  Percent List ........... DAILY base distances in %; each is multiplied by
                           the Scaling factor. Default "0.382, 1, 1.5, 2".
  Scaling ................ √Time (default), ATR Ratio, Linear, None.
  Days per Week .......... 7 for crypto (default), 5 for stocks/indices.
  ATR Length ............. default 14; used by ATR Ratio.
  Auto-Hide Below ........ hides the ladder (and its table) when the chart
                           timeframe is lower than the chosen timeframe
                           (default 60 = 1 hour). Default ON.
  Active Lines / Width ... style and width of the current week's lines.
  Open (color) ........... color of the weekly open line and caption.
  Open Tag ............... default "WK-O".
  Label Offset (bars) .... default 24.

6.1 SCALING MODES
-----------------------------------------------------------------------------
  √Time ...... factor = √(Days per Week). 7 days -> x2.646; 5 days -> x2.236.
  ATR Ratio .. factor = Weekly ATR / Daily ATR, both from the last COMPLETED
               bars when the week starts. Fixed for the whole week (no
               repaint). Falls back to √Time until enough history exists.
               Note: the daily ATR always uses the D timeframe; the weekly
               ATR uses the Weekly Anchor Timeframe.
  Linear ..... factor = Days per Week (usually too wide).
  None ....... factor = 1 (weekly distances equal the daily ones).

  Each week, current and past, keeps the factor it started with. The
  current factor is shown in the Weekly table title (e.g. "x2.65").


================================================================================
7. EXTRA LEVELS  (group: EXTRA LEVELS)
================================================================================

  Apply To ........ Both (default), Daily, or Weekly.
  Extra 1 - 5 ..... toggle + percentage (defaults 2.5, 3.0, 3.5, 4.0, 5.0;
                    all OFF). Each enabled extra adds one bullish and one
                    bearish level, extending the ladder outward.

  Extras are merged into the Percent List, sorted, and skipped if already
  present. On the Weekly ladder they are multiplied by the Scaling factor.


================================================================================
8. STYLE  (group: STYLE)
================================================================================

  Palette .............. source of the Bullish / Bearish colors for BOTH
                         ladders (default Custom).
  Brightness (%) ....... -100 to +100. Positive blends toward white,
                         negative toward black. Never affects Open colors.
  Bullish / Bearish .... color pickers; used only when Palette = Custom.
  Active Opacity (%) ... opacity of the current period's lines (both
                         ladders, open lines included). Default 100.
  Fade Hit Levels ...... ON (default): reached levels draw with lines and
                         caption backgrounds at 40 % of their opacity and
                         caption text at 60 % transparency.
  Rounding ............. Round (default) reproduces published numbers;
                         Floor rounds down; None keeps full precision
                         (tables show the symbol's tick size). Captions
                         always show 0 decimals.

8.1 PALETTES
-----------------------------------------------------------------------------
  Custom, Classic, Ocean, Sunset, Neon, Monochrome, Desert, Oldbook,
  OldWest, Default. Any choice other than Custom overrides the pickers.


================================================================================
9. LABELS & CAPTION MODE  (group: LABELS)
================================================================================

9.1 LABEL CONTENT
-----------------------------------------------------------------------------
  Caption format:  [Open Tag / Arrow / Percent]  $price  (distance)  ✓

  Label Size ............ Tiny, Small (default), Normal, Large.
  Match Level Color ..... ON (default): text uses the level's color (Open /
                          Bullish / Bearish). OFF: uses the Text color.
  Text .................. caption text color when Match is OFF.
  Background ............ Direction (level color) or Custom (picked color).
  Opacity (%) ........... caption background opacity (default 20; 0 = none).
  Price Prefix .......... text before every price (default "$").
  Open Tag .............. prefixes open captions with the ladder's Open Tag.
  Arrow ................. prefixes levels with ▲ (bullish) / ▼ (bearish).
  Percent ............... shows the level's distance from the open
                          (scaled on the Weekly ladder). Default OFF.
  Distance % ............ distance from the current close in %. Default OFF.
  Distance (pts) ........ same distance in price units. Default OFF.
  Hit ✓ ................. marks levels reached this period. Default ON.

9.2 CAPTION MODE
-----------------------------------------------------------------------------
  Caption Mode
    Labels ... pointer labels to the right of each line's end.
    Boxes .... (default) a thin box spanning the level's line from the
               period start to the line end. Bullish levels and opens read
               ABOVE their line; bearish levels read BELOW. Box height
               scales with price (≈0.001 % of the open, at least one tick).
  Align (Boxes only)
    Right (default) - text ends at the line tip.
    Left            - text starts at the period start.
    Center          - text centered on the line.
  Caption Past Periods (Boxes) ... also captions every History ladder at its
    own period end. Past captions use faded text, no background and no hit
    mark. Default OFF. (In Labels mode past periods are never captioned.)


================================================================================
10. HISTORY  (group: HISTORY)
================================================================================

  Past Days ............ previous daily ladders to draw (0 - 20, default 1).
  Past Weeks ........... previous weekly ladders to draw (0 - 20, default 1).
                         0 = current period only.
  Line Style / Width ... style (default Dashed) and width of past lines.
  Line Opacity (%) ..... opacity of past lines (default 30).

  Past periods have no captions unless Caption Past Periods is ON in Boxes
  mode, and never show hit marks.


================================================================================
11. SUMMARY TABLES  (group: SUMMARY TABLES)
================================================================================

  Daily Table + position ..... default OFF, Top Right.
  Weekly Table + position .... default OFF, Bottom Right.
  Orientation ................ Vertical (one row per level) or Horizontal
                               (one column per level).
  Text Size .................. Tiny, Small, Normal, Large.
  Background / Frame ......... table colors.
  Header Text / Body Text .... title/field-name and value colors.

  Each table shows the CURRENT period only:
    Title .... "INTRADAY LEVELS  yyyy-MM-dd" or
               "INTRAWEEK LEVELS  Week of yyyy-MM-dd  ·  x<factor>"
    Columns .. Side | % | Level | Dist | Hit
    Rows ..... Bullish levels (highest first), Open, Bearish levels.
    Dist ..... distance of the level from the current close, in %.
    Hit ...... ✓ once the level was reached this period.

  If the chart timeframe is not lower than the anchor timeframe, the table
  shows a warning: "⚠ Use a chart timeframe lower than ...".
  A table is not shown while its ladder is hidden or switched off.


================================================================================
12. HIT TRACKING
================================================================================

  For the current period of each ladder:
    - a bullish level is HIT once the period's high reaches it;
    - a bearish level is HIT once the period's low reaches it.
  Hit levels get a ✓ (if Hit ✓ is on) and are faded (if Fade Hit Levels is
  on). The high/low tracking resets at the start of each new period.


================================================================================
13. AUTO-HIDE & TIMEFRAME RULES
================================================================================

  Default visibility by chart timeframe:

    Chart TF          Daily ladder     Weekly ladder
    ----------------  ---------------  ---------------
    below 1H          shown            hidden
    1H - 4H (<1D)     shown            shown
    1D                hidden           shown
    1W or higher      hidden           hidden (TF not lower than anchor)

  - A ladder is never drawn if the chart timeframe is not lower than its
    Anchor Timeframe.
  - Turn off Auto-Hide Above 1D / Auto-Hide Below to override the hiding.


================================================================================
14. TROUBLESHOOTING / FAQ
================================================================================

  Q: The Weekly ladder doesn't appear.
  A: The chart is probably below 1H. Switch to 1H+ or change/disable
     "Auto-Hide Below".

  Q: The Daily ladder doesn't appear.
  A: The chart is at 1D or higher. Use an intraday timeframe or disable
     "Auto-Hide Above 1D".

  Q: My levels differ by a few dollars from the published ones.
  A: Use the same exchange feed as the source, and keep Rounding = Round.

  Q: Daily and weekly captions overlap.
  A: Give each ladder a different Label Offset (defaults 10 and 24).

  Q: Changing the Percent List or extras doesn't seem to apply.
  A: They are read when the script loads; pressing OK in the settings
     reloads the indicator automatically.

  Q: Some lines are missing with large History settings.
  A: The 500-line limit was reached. Lower Past Days / Past Weeks or the
     number of percentages and extras.

================================================================================
  End of manual
================================================================================

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CQuevedo345

// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CQuevedo345

// © CQuevedo345 / UkutaLabs
//@version=6
indicator("CQ_(1)_[PRICE ACTION / INTRADAY-WEEK LEVELS] v1", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ═════════════════════════════════════════════════════════════════════════════
//  CQ_(1)_[PRICE ACTION / INTRADAY-WEEK LEVELS] v1 — NOTES
// ═════════════════════════════════════════════════════════════════════════════
//
//  PURPOSE
//  Merges CQ_(O)_[INTRADAY OPEN LADDER] and CQ_(W)_[INTRAWEEK OPEN LADDER]
//  into one indicator. Two independent ladders of Crecetrader-style levels,
//  each a symmetric set of bullish and bearish levels around its period's
//  opening price:
//
//        Bullish level = Open × (1 + pct × factor / 100)
//        Bearish level = Open × (1 − pct × factor / 100)
//
//  DAILY LADDER (factor = 1)
//  Anchored to the Daily open by default. Percent List default reproduces
//  the Sep 24, 2026 sample (open 84,394):
//      Bullish 84,716 · 85,238 · 85,660 · 86,087
//      Bearish 84,071 · 83,550 · 83,128 · 82,706
//  Distances are 0.382%, 1%, 1.5% and 2%. Seven of eight reproduce to the
//  dollar; the bullish 2% computes to 86,082, so the published 86,087 is
//  most likely a typo (its bearish mirror 82,706 matches exactly).
//  Confirm with more days that the percentages stay fixed.
//
//  WEEKLY LADDER (factor from Scaling)
//  Anchored to the Weekly open by default. Its Percent List holds DAILY base
//  distances, multiplied by a weekly scale factor:
//    √Time     Factor = √(Days per Week). 7 days (crypto) → ×2.646:
//              0.382 → 1.011% · 1 → 2.646% · 1.5 → 3.969% · 2 → 5.292%
//    ATR Ratio Factor = Weekly ATR / Daily ATR from the last completed bars
//              at the week's start; fixed for the week (no repaint). Falls
//              back to √Time until enough history exists.
//    Linear    Factor = Days per Week (usually too wide).
//    None      Factor = 1.
//  Each week (current and History) keeps the factor it started with.
//  Not yet confirmed against his published weekly levels.
//
//  EXTRA LEVELS
//  Up to five optional percentages extend the ladders at both ends, applied
//  to Both, Daily only or Weekly only. Merged with each Percent List,
//  sorted, duplicates skipped. On the Weekly ladder they are scaled too.
//
//  ANCHOR
//  Opens are taken from each ladder's Anchor Timeframe on the chart symbol.
//  Use the same feed he uses (e.g. BITSTAMP:BTCUSD). Opens are requested
//  with lookahead, which is safe: a period's open is fixed at its start, so
//  levels do not repaint.
//
//  AUTO-HIDE
//  Daily: hidden when the chart timeframe is 1D or higher.
//  Weekly: hidden when the chart timeframe is lower than the chosen one
//  (default 1 hour). Both ladders are visible together on 1H–4H.
//
//  HIT TRACKING
//  For the current period of each ladder, a bullish level is hit (✓) once
//  the period's high reaches it, a bearish level once its low reaches it.
//  Hit levels are drawn faded (line, label text and background).
//
//  PALETTE
//  Bullish / Bearish colors are shared by both ladders and come from the
//  selected Palette ("Custom" uses the pickers). Brightness blends them
//  toward white (+) or black (−); it never affects the Open colors. Each
//  ladder has its own Open color so the two opens are easy to tell apart.
//
//  DRAWING
//  Each ladder's current period runs from its start to its own label
//  position, with its own line style and width. Past periods (History) run
//  from their start to the next period's start, without labels. Opening-
//  price lines are always solid and one step wider. All objects are rebuilt
//  on the last bar (collect-then-draw) in bar-time coordinates.
//
//  LABELS
//  Price always shown with the Price Prefix and 0 decimals. Open tag,
//  arrow, percent, distance (% and points) and hit mark are toggles shared
//  by both ladders. Each ladder has its own Label Offset (Daily 2, Weekly
//  15 by default) so their labels do not stack.
//
//  CAPTION MODE
//  Labels: classic pointer labels placed to the right of each line's end.
//  Boxes:  each caption is a thin box spanning the level's line, from the
//          period start to its line end. Text is aligned inside it (Right
//          by default, so it ends flush with the line tip); bullish levels
//          and opens read above the line, bearish levels below it. The box
//          height scales with price (≈0.001% of the open, at least one
//          tick), so placement works on any symbol. "Caption Past Periods"
//          also captions every History ladder at its own period end, so all
//          calculated levels on screen carry their value. Past captions use
//          faded text, no background and no hit mark.
//
//  TABLES
//  One table per ladder, each with its own toggle and screen position.
//  Orientation, size and colors are shared.
// ═════════════════════════════════════════════════════════════════════════════

// ── Groups ───────────────────────────────────────────────────────────────────
string G_D = "📅  DAILY LADDER"
string G_W = "🗓️  WEEKLY LADDER"
string G_X = "➕  EXTRA LEVELS"
string G_S = "🎨  STYLE"
string G_B = "🏷️  LABELS"
string G_H = "🕘  HISTORY"
string G_T = "📋  SUMMARY TABLES"

// ── Daily Ladder ─────────────────────────────────────────────────────────────
bool   dOn       = input.bool(true, "Show Daily Ladder", group = G_D)
string dTf       = input.timeframe("D", "Anchor Timeframe", group = G_D, tooltip = "Timeframe whose opening price anchors the daily ladder. Daily reproduces the published intraday levels. The chart timeframe must be lower than this.")
string dPctTxt   = input.string("0.382, 1, 1.5, 2", "Percent List", group = G_D, tooltip = "Comma-separated distances from the open, in percent. Each value creates one bullish level (Open × (1 + pct/100)) and one bearish level (Open × (1 − pct/100)). Default reproduces the Sep 24, 2026 sample. Spaces ignored; invalid or non-positive entries skipped.")
bool   dAutoHide = input.bool(true, "Auto-Hide Above 1D", group = G_D, tooltip = "When on, the daily ladder (lines, labels and table) is not drawn if the chart timeframe is 1D or higher.")
string dStyleI   = input.string("Solid", "Active Lines", options = ["Solid", "Dashed", "Dotted"], inline = "d1", group = G_D)
int    dWidth    = input.int(1, "Width", minval = 1, maxval = 10, inline = "d1", group = G_D, tooltip = "Style and width of the current day's level lines. The opening-price line is always solid and one step wider.")
color  dOpenC    = input.color(#D1D4DC, "Open", inline = "d2", group = G_D)
string dTag      = input.string("D-O", "Open Tag", inline = "d2", group = G_D, tooltip = "Color of the daily opening-price line/label, and the text shown on its label when Open Tag is on.")
int    dOff      = input.int(10, "Label Offset (bars)", minval = 0, maxval = 500, group = G_D, tooltip = "Bars to the right of the last bar where the daily labels sit. Current-day lines stop exactly at this point. In Boxes caption mode, right-aligned captions end here.")

// ── Weekly Ladder ────────────────────────────────────────────────────────────
bool   wOn       = input.bool(true, "Show Weekly Ladder", group = G_W)
string wTf       = input.timeframe("W", "Anchor Timeframe", group = G_W, tooltip = "Timeframe whose opening price anchors the weekly ladder. The chart timeframe must be lower than this.")
string wPctTxt   = input.string("0.382, 1, 1.5, 2", "Percent List", group = G_W, tooltip = "Comma-separated DAILY base distances from the open, in percent. Each is multiplied by the Scaling factor, then creates one bullish and one bearish level.")
string scMode    = input.string("√Time", "Scaling", options = ["√Time", "ATR Ratio", "Linear", "None"], group = G_W, tooltip = "Converts the daily base percentages into weekly ones. √Time: × √(Days per Week). ATR Ratio: × Weekly ATR / Daily ATR, measured at the week's start. Linear: × Days per Week. None: × 1.")
int    daysWk    = input.int(7, "Days per Week", minval = 1, maxval = 7, inline = "sc", group = G_W)
int    atrLen    = input.int(14, "ATR Length", minval = 1, inline = "sc", group = G_W, tooltip = "Days per Week: 7 for crypto, 5 for stocks/indices; used by √Time and Linear, and as the ATR Ratio fallback. ATR Length: bars for the weekly and daily ATR used by ATR Ratio.")
bool   wAutoHide = input.bool(true, "Auto-Hide Below", inline = "ah", group = G_W)
string wHideTf   = input.timeframe("60", "", inline = "ah", group = G_W, tooltip = "Hides the weekly ladder (lines, labels and table) when the chart timeframe is lower than this (default 1 hour).")
string wStyleI   = input.string("Solid", "Active Lines", options = ["Solid", "Dashed", "Dotted"], inline = "w1", group = G_W)
int    wWidth    = input.int(1, "Width", minval = 1, maxval = 10, inline = "w1", group = G_W, tooltip = "Style and width of the current week's level lines. The opening-price line is always solid and one step wider.")
color  wOpenC    = input.color(#FFD54F, "Open", inline = "w2", group = G_W)
string wTag      = input.string("WK-O", "Open Tag", inline = "w2", group = G_W, tooltip = "Color of the weekly opening-price line/label, and the text shown on its label when Open Tag is on.")
int    wOff      = input.int(24, "Label Offset (bars)", minval = 0, maxval = 500, group = G_W, tooltip = "Bars to the right of the last bar where the weekly labels sit. Current-week lines stop exactly at this point. In Boxes caption mode, right-aligned captions end here.")

// ── Extra Levels ─────────────────────────────────────────────────────────────
string exTo  = input.string("Both", "Apply To", options = ["Both", "Daily", "Weekly"], group = G_X, tooltip = "Which ladder(s) receive the enabled extra levels. On the Weekly ladder they are multiplied by the Scaling factor like the Percent List.")
bool   ex1On = input.bool(false, "Extra 1", inline = "x1", group = G_X)
float  ex1P  = input.float(2.5, "%", minval = 0.001, step = 0.1, inline = "x1", group = G_X, tooltip = "Each enabled extra adds one bullish and one bearish level, extending the ladder at both ends. Values already in the Percent List are skipped.")
bool   ex2On = input.bool(false, "Extra 2", inline = "x2", group = G_X)
float  ex2P  = input.float(3.0, "%", minval = 0.001, step = 0.1, inline = "x2", group = G_X)
bool   ex3On = input.bool(false, "Extra 3", inline = "x3", group = G_X)
float  ex3P  = input.float(3.5, "%", minval = 0.001, step = 0.1, inline = "x3", group = G_X)
bool   ex4On = input.bool(false, "Extra 4", inline = "x4", group = G_X)
float  ex4P  = input.float(4.0, "%", minval = 0.001, step = 0.1, inline = "x4", group = G_X)
bool   ex5On = input.bool(false, "Extra 5", inline = "x5", group = G_X)
float  ex5P  = input.float(5.0, "%", minval = 0.001, step = 0.1, inline = "x5", group = G_X)

// ── Style ────────────────────────────────────────────────────────────────────
string palette   = input.string("Custom", "Palette", options = ["Custom", "Classic", "Ocean", "Sunset", "Neon", "Monochrome", "Desert", "Oldbook", "OldWest", "Default"], inline = "sp", group = G_S)
int    palBright = input.int(0, "Brightness (%)", minval = -100, maxval = 100, step = 5, inline = "sp", group = G_S, tooltip = "Palette: source of the Bullish and Bearish colors for both ladders. Custom uses the pickers below; any other palette overrides them. Brightness: blends both colors toward white (positive) or black (negative). The Open colors are never affected.")
color  bullColI  = input.color(#00E676, "Bullish", inline = "s0", group = G_S)
color  bearColI  = input.color(#FF5252, "Bearish", inline = "s0", group = G_S, tooltip = "Colors of the bullish and bearish levels (lines, labels and tables) of both ladders. Apply only when Palette is Custom.")
int    actOp     = input.int(100, "Active Opacity (%)", minval = 0, maxval = 100, step = 5, group = G_S, tooltip = "Opacity of the current period's lines on both ladders, opening-price lines included.")
bool   fadeHit   = input.bool(true, "Fade Hit Levels", group = G_S, tooltip = "Draws levels already reached during the current period more faded: lines and label backgrounds at 40% of their opacity, label text at 60% transparency.")
string rndMode   = input.string("Round", "Rounding", options = ["Round", "Floor", "None"], group = G_S, tooltip = "How levels are rounded for drawing and table display. Round reproduces the published numbers. None keeps full precision, formatted to the symbol's tick size. Labels always show 0 decimals.")

// ── Labels ───────────────────────────────────────────────────────────────────
string capMode   = input.string("Boxes", "Caption Mode", options = ["Labels", "Boxes"], inline = "b4", group = G_B)
string capAlignI = input.string("Right", "Align", options = ["Left", "Center", "Right"], inline = "b4", group = G_B, tooltip = "Labels: pointer labels to the right of each line's end. Boxes: captions ride on the lines themselves (bullish and open above, bearish below), inside a thin box spanning the period. Align applies to Boxes only: Right ends the text at the line tip, Left starts it at the period start.")
bool   capHist   = input.bool(false, "Caption Past Periods (Boxes)", group = G_B, tooltip = "Boxes mode only: also captions every History ladder at its own period end, so all calculated levels on screen carry their value. Past captions use faded text, no background and no hit mark.")
string lblSizeI  = input.string("Small", "Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_B, tooltip = "Label text size.")
bool   lblMatch  = input.bool(true, "Match Level Color", inline = "b0", group = G_B)
color  lblTxtC   = input.color(#D1D4DC, "Text", inline = "b0", group = G_B, tooltip = "Label text color. With Match Level Color on, each label uses its level's color (Open / Bullish / Bearish) and the Text color is ignored.")
string lblBgMode = input.string("Direction", "Background", options = ["Direction", "Custom"], inline = "b3", group = G_B)
color  lblBgC    = input.color(#131722, "", inline = "b3", group = G_B)
int    lblBgOp   = input.int(20, "Opacity (%)", minval = 0, maxval = 100, step = 5, inline = "b3", group = G_B, tooltip = "Direction: each label background uses its level's color. Custom: all labels use the picked color. Opacity applies to both modes; 0 = no background.")
string lblPfx    = input.string("$", "Price Prefix", group = G_B, tooltip = "Text placed before every label price (default $). Leave empty for none.")
bool   showOpenT = input.bool(true, "Open Tag", inline = "b1", group = G_B)
bool   showArrow = input.bool(true, "Arrow", inline = "b1", group = G_B)
bool   showPct   = input.bool(false, "Percent", inline = "b1", group = G_B, tooltip = "Open Tag: prefixes each open label with its ladder's Open Tag text. Arrow: prefixes levels with ▲ / ▼. Percent: shows each level's distance from the open (scaled on the Weekly ladder).")
bool   showDist  = input.bool(false, "Distance %", inline = "b2", group = G_B)
bool   showPts   = input.bool(false, "Distance (pts)", inline = "b2", group = G_B)
bool   showHit   = input.bool(true, "Hit ✓", inline = "b2", group = G_B, tooltip = "Distance %: distance from the current close in percent. Distance (pts): the same distance in price units. Hit ✓: marks levels already reached this period.")

// ── History ──────────────────────────────────────────────────────────────────
int    dHistN     = input.int(1, "Past Days", minval = 0, maxval = 20, inline = "h0", group = G_H)
int    wHistN     = input.int(1, "Past Weeks", minval = 0, maxval = 20, inline = "h0", group = G_H, tooltip = "How many previous periods' ladders to draw (without labels) for each ladder. 0 shows only the current period.")
string histStyleI = input.string("Dashed", "Line Style", options = ["Solid", "Dashed", "Dotted"], inline = "h1", group = G_H)
int    histWidth  = input.int(1, "Width", minval = 1, maxval = 10, inline = "h1", group = G_H, tooltip = "Style and width of past periods' level lines. Past opening-price lines are always solid and one step wider.")
int    histOp     = input.int(30, "Line Opacity (%)", minval = 0, maxval = 100, step = 5, group = G_H, tooltip = "Opacity of past periods' lines on both ladders.")

// ── Tables ───────────────────────────────────────────────────────────────────
bool   dTblOn    = input.bool(false, "Daily Table", inline = "t0", group = G_T)
string dTblPosI  = input.string("Top Right", "", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], inline = "t0", group = G_T)
bool   wTblOn    = input.bool(false, "Weekly Table", inline = "t4", group = G_T)
string wTblPosI  = input.string("Bottom Right", "", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], inline = "t4", group = G_T, tooltip = "Each table shows its ladder's current period: side, percent, level, distance from price and hit status. Also warns when the chart timeframe is not lower than the anchor.")
string tblOrient = input.string("Vertical", "Orientation", options = ["Vertical", "Horizontal"], inline = "t1", group = G_T)
string tblSizeI  = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal", "Large"], inline = "t1", group = G_T, tooltip = "Vertical: one row per level. Horizontal: one column per level, fields as rows.")
color  tblBg     = input.color(color.new(#131722, 10), "Background", inline = "t2", group = G_T)
color  tblFrm    = input.color(#363A45, "Frame", inline = "t2", group = G_T, tooltip = "Table background and frame/border colors.")
color  tblHdrC   = input.color(#D1D4DC, "Header Text", inline = "t3", group = G_T)
color  tblTxtC   = input.color(#D1D4DC, "Body Text", inline = "t3", group = G_T, tooltip = "Header Text: title and field names. Body Text: percent, level and distance values. Side names and hit marks keep the Open / Bullish / Bearish colors.")

// ── Palette ──────────────────────────────────────────────────────────────────
// Blends a color toward white (b > 0) or black (b < 0) by |b| %, keeping its transparency.
f_bright(color c, int b) =>
    float k = b / 100.0
    float r = color.r(c)
    float g = color.g(c)
    float u = color.b(c)
    k >= 0 ? color.rgb(r + (255 - r) * k, g + (255 - g) * k, u + (255 - u) * k, color.t(c)) : color.rgb(r * (1 + k), g * (1 + k), u * (1 + k), color.t(c))

color bullBase = switch palette
    "Classic"    => color.rgb(0, 177, 171)
    "Ocean"      => color.rgb(0, 104, 179)
    "Sunset"     => color.rgb(180, 108, 0)
    "Neon"       => color.rgb(0, 105, 190)
    "Monochrome" => color.rgb(172, 172, 172)
    "Desert"     => color.rgb(0, 179, 161)
    "Oldbook"    => color.rgb(139, 163, 0)
    "OldWest"    => color.rgb(148, 182, 0)
    "Default"    => color.rgb(0, 187, 140)
    => bullColI

color bearBase = switch palette
    "Classic"    => color.rgb(182, 0, 0)
    "Ocean"      => color.rgb(0, 43, 185)
    "Sunset"     => color.rgb(151, 147, 140)
    "Neon"       => color.rgb(112, 119, 133)
    "Monochrome" => color.rgb(119, 116, 116)
    "Desert"     => color.rgb(173, 104, 0)
    "Oldbook"    => color.rgb(168, 146, 0)
    "OldWest"    => color.rgb(165, 33, 0)
    "Default"    => color.rgb(206, 0, 0)
    => bearColI

color bullCol = f_bright(bullBase, palBright)
color bearCol = f_bright(bearBase, palBright)

// ── Helpers ──────────────────────────────────────────────────────────────────
f_size(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

f_style(string s) =>
    switch s
        "Solid"  => line.style_solid
        "Dotted" => line.style_dotted
        => line.style_dashed

f_pos(string s) =>
    switch s
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        => position.top_right

f_rnd(float x) =>
    switch rndMode
        "Round" => math.round(x) * 1.0
        "Floor" => math.floor(x) * 1.0
        => x

f_fmtP(float p)   => rndMode == "None" ? str.tostring(p, format.mintick) : str.tostring(p, "#,###")
f_fmtL(float p)   => lblPfx + str.tostring(math.round(p), "#,##0")
f_fmtD(float d)   => (d >= 0 ? "+" : "") + str.tostring(d, "0.00") + "%"
f_fmtPts(float d) => (d >= 0 ? "+" : "") + str.tostring(math.round(d), "#,##0")

// Label background: direction color or custom, at the chosen opacity; hit levels fade to 40% of it.
f_lblBg(color dirCol, bool hit) =>
    color base = lblBgMode == "Direction" ? dirCol : lblBgC
    float op   = hit and fadeHit ? lblBgOp * 0.4 : lblBgOp
    color.new(base, 100 - op)

// Label text: tag + $price (0 decimals) + optional (distance % · distance pts) + optional hit mark.
f_lblTxt(string tag, float lvl, bool hit) =>
    string d = ""
    if showDist
        d := f_fmtD((lvl - close) / close * 100)
    if showPts
        d := d + (d != "" ? " · " : "") + f_fmtPts(lvl - close)
    tag + f_fmtL(lvl) + (d != "" ? "   (" + d + ")" : "") + (showHit and hit ? "  ✓" : "")

// ── Box captions ─────────────────────────────────────────────────────────────
bool   boxMode = capMode == "Boxes"
string capHAl  = switch capAlignI
    "Left"   => text.align_left
    "Center" => text.align_center
    => text.align_right

// Thin box spanning the level's line (x1 → x2). Height scales with price (≈0.001% of the open,
// at least one tick). Above: box sits on the line, text bottom-aligned → reads above it.
// Below: box hangs under the line, text top-aligned → reads below it.
f_cap(int x1, int x2, float lvl, float h, bool above, string txt, color bg, color tc, string sz) =>
    box.new(x1, above ? lvl + h : lvl, x2, above ? lvl : lvl - h, border_color = color(na), border_width = 0, xloc = xloc.bar_time, bgcolor = bg, text = txt, text_size = sz, text_color = tc, text_halign = capHAl, text_valign = above ? text.align_bottom : text.align_top)

// Table cell addressed by field (f) and entry (e); swaps axes when horizontal.
f_tc(table t, bool hz, int f, int e, string txt, color tc, string sz) =>
    t.cell(hz ? e : f, hz ? 1 + f : 1 + e, txt, text_color = tc, text_size = sz)

// Percent list + (optionally) enabled extras: sorted, duplicates skipped.
f_parse(string txt, bool useEx) =>
    array<float> a = array.new<float>()
    for part in str.split(txt, ",")
        float v = str.tonumber(str.replace_all(part, " ", ""))
        if not na(v) and v > 0 and not a.includes(v)
            a.push(v)
    if useEx
        array<bool>  exOn = array.from(ex1On, ex2On, ex3On, ex4On, ex5On)
        array<float> exP  = array.from(ex1P, ex2P, ex3P, ex4P, ex5P)
        for j = 0 to 4
            float x = exP.get(j)
            if exOn.get(j) and x > 0 and not a.includes(x)
                a.push(x)
    a.sort(order.ascending)
    a

// ── Ladder state ─────────────────────────────────────────────────────────────
// Period registry (start time + open + scale factor) and current-period high/low for hits.
type Ladder
    array<int>   st
    array<float> op
    array<float> fac
    float        hi = na
    float        lo = na

method track(Ladder L, bool newP, float aOpen, float fac, int keep) =>
    if barstate.isfirst or newP
        L.st.push(time)
        L.op.push(aOpen)
        L.fac.push(fac)
        if L.st.size() > keep + 1
            L.st.shift()
            L.op.shift()
            L.fac.shift()
        L.hi := high
        L.lo := low
    else
        L.hi := math.max(L.hi, high)
        L.lo := math.min(L.lo, low)
        if L.op.size() > 0 and not na(aOpen)
            L.op.set(L.op.size() - 1, aOpen)
    L

// ── Data ─────────────────────────────────────────────────────────────────────
// Anchor-period opens. Lookahead is safe for `open`: it is fixed at period start.
float dOpen = request.security(syminfo.tickerid, dTf, open, lookahead = barmerge.lookahead_on)
float wOpen = request.security(syminfo.tickerid, wTf, open, lookahead = barmerge.lookahead_on)
bool  dNewP = timeframe.change(dTf)
bool  wNewP = timeframe.change(wTf)

int   chSec   = timeframe.in_seconds()
bool  dTfOk   = chSec < timeframe.in_seconds(dTf)
bool  wTfOk   = chSec < timeframe.in_seconds(wTf)
bool  dHidden = dAutoHide and chSec >= timeframe.in_seconds("1D")
bool  wHidden = wAutoHide and chSec < timeframe.in_seconds(wHideTf)

// Weekly / daily ATR from the last completed bars ([1] + lookahead = fixed, no repaint).
float wAtr = request.security(syminfo.tickerid, wTf, ta.atr(atrLen)[1], lookahead = barmerge.lookahead_on)
float dAtr = request.security(syminfo.tickerid, "D", ta.atr(atrLen)[1], lookahead = barmerge.lookahead_on)

// Daily → weekly scale factor for the weekly base percentages.
float wFac = switch scMode
    "√Time"     => math.sqrt(daysWk)
    "Linear"    => daysWk * 1.0
    "ATR Ratio" => na(wAtr) or na(dAtr) or dAtr <= 0 ? math.sqrt(daysWk) : wAtr / dAtr
    => 1.0

var array<float> dPcts = f_parse(dPctTxt, exTo != "Weekly")
var array<float> wPcts = f_parse(wPctTxt, exTo != "Daily")

var Ladder LD = Ladder.new(array.new<int>(), array.new<float>(), array.new<float>())
var Ladder LW = Ladder.new(array.new<int>(), array.new<float>(), array.new<float>())
LD.track(dNewP, dOpen, 1.0, dHistN)
LW.track(wNewP, wOpen, wFac, wHistN)

// Drawing containers.
var array<line>  lns  = array.new<line>()
var array<label> lbs  = array.new<label>()
var array<box>   bxs  = array.new<box>()
var table        dTbl = na
var table        wTbl = na

// ── Draw one ladder (current period with labels + history) ───────────────────
f_draw(Ladder L, array<float> pcts, color openCol, string tagTxt, string actStyle, int actW, int off) =>
    int    barMs     = timeframe.in_seconds() * 1000
    int    xLbl      = time + off * barMs
    string histStyle = f_style(histStyleI)
    string lblSize   = f_size(lblSizeI)
    int    nP        = L.st.size()
    int    actTr     = 100 - actOp
    int    hitTr     = 100 - math.round(actOp * 0.4)
    int    histTr    = 100 - histOp
    if nP > 0
        for i = 0 to nP - 1
            float o = L.op.get(i)
            if na(o)
                continue
            bool   isCur = i == nP - 1
            bool   cap   = isCur or (boxMode and capHist)
            int    x1    = L.st.get(i)
            int    x2    = isCur ? (xLbl > x1 ? xLbl : x1 + barMs) : L.st.get(i + 1)
            float  oR    = f_rnd(o)
            float  fac   = L.fac.get(i)
            float  capH  = math.max(syminfo.mintick, o * 0.00001)
            string lSt   = isCur ? actStyle : histStyle
            int    lW    = isCur ? actW : histWidth

            // Opening-price line.
            color oCol = color.new(openCol, isCur ? actTr : histTr)
            lns.push(line.new(x1, oR, x2, oR, xloc.bar_time, extend.none, oCol, line.style_solid, lW + 1))
            if cap
                string oTxt = f_lblTxt(showOpenT and tagTxt != "" ? tagTxt + "   " : "", oR, false)
                color  oTb  = lblMatch ? openCol : lblTxtC
                if boxMode
                    bxs.push(f_cap(x1, x2, oR, capH, true, oTxt, isCur ? f_lblBg(openCol, false) : color(na), isCur ? oTb : color.new(oTb, 60), lblSize))
                else
                    lbs.push(label.new(x2, oR, oTxt, xloc.bar_time, yloc.price, f_lblBg(openCol, false), label.style_label_left, oTb, lblSize))

            // Bullish and bearish levels.
            for pb in pcts
                float p = pb * fac
                for side = 0 to 1
                    bool  bull = side == 0
                    float lvl  = f_rnd(bull ? o * (1 + p / 100) : o * (1 - p / 100))
                    bool  hit  = isCur and (bull ? L.hi >= lvl : L.lo <= lvl)
                    color c0   = bull ? bullCol : bearCol
                    color c    = color.new(c0, not isCur ? histTr : hit and fadeHit ? hitTr : actTr)
                    lns.push(line.new(x1, lvl, x2, lvl, xloc.bar_time, extend.none, c, lSt, lW))
                    if cap
                        string tag  = (showArrow ? (bull ? "▲ " : "▼ ") : "") + (showPct ? str.tostring(p, "#.###") + "%" : "")
                        string tagF = tag != "" ? str.trim(tag) + "   " : ""
                        color  tb   = lblMatch ? c0 : lblTxtC
                        color  tc   = (hit and fadeHit) or not isCur ? color.new(tb, 60) : tb
                        string txt  = f_lblTxt(tagF, lvl, hit)
                        if boxMode
                            bxs.push(f_cap(x1, x2, lvl, capH, bull, txt, isCur ? f_lblBg(c0, hit) : color(na), tc, lblSize))
                        else
                            lbs.push(label.new(x2, lvl, txt, xloc.bar_time, yloc.price, f_lblBg(c0, hit), label.style_label_left, tc, lblSize))

// ── Summary table for one ladder: bullish (highest first), open, bearish ────
f_table(Ladder L, array<float> pcts, string posI, bool tfOk, string tfIn, color openCol, string title, bool showFac) =>
    string tSize   = f_size(tblSizeI)
    int    k       = pcts.size()
    int    nE      = 2 * k + 2
    bool   hz      = tblOrient == "Horizontal"
    int    lastCol = hz ? nE - 1 : 4
    int    nP      = L.st.size()
    table  t       = table.new(f_pos(posI), hz ? nE : 5, hz ? 6 : nE + 1, bgcolor = tblBg, frame_color = tblFrm, frame_width = 1, border_color = tblFrm, border_width = 1)
    if not tfOk
        t.cell(0, 0, "⚠ Use a chart timeframe lower than " + tfIn, text_color = color.orange, text_size = tSize)
        t.merge_cells(0, 0, lastCol, 0)
    else if nP > 0 and not na(L.op.get(nP - 1))
        float o  = L.op.get(nP - 1)
        float oR = f_rnd(o)
        float fc = L.fac.get(nP - 1)
        t.cell(0, 0, title + str.format_time(L.st.get(nP - 1), "yyyy-MM-dd", syminfo.timezone) + (showFac ? "  ·  ×" + str.tostring(fc, "0.00") : ""), text_color = tblHdrC, text_size = tSize)
        t.merge_cells(0, 0, lastCol, 0)
        f_tc(t, hz, 0, 0, "Side",  tblHdrC, tSize)
        f_tc(t, hz, 1, 0, "%",     tblHdrC, tSize)
        f_tc(t, hz, 2, 0, "Level", tblHdrC, tSize)
        f_tc(t, hz, 3, 0, "Dist",  tblHdrC, tSize)
        f_tc(t, hz, 4, 0, "Hit",   tblHdrC, tSize)
        int e = 1
        if k > 0
            for j = k - 1 to 0
                float p   = pcts.get(j) * fc
                float lvl = f_rnd(o * (1 + p / 100))
                f_tc(t, hz, 0, e, "Bull", bullCol, tSize)
                f_tc(t, hz, 1, e, str.tostring(p, "#.###"), tblTxtC, tSize)
                f_tc(t, hz, 2, e, f_fmtP(lvl), tblTxtC, tSize)
                f_tc(t, hz, 3, e, f_fmtD((lvl - close) / close * 100), tblTxtC, tSize)
                f_tc(t, hz, 4, e, L.hi >= lvl ? "✓" : "", bullCol, tSize)
                e += 1
        f_tc(t, hz, 0, e, "Open", openCol, tSize)
        f_tc(t, hz, 1, e, "0", tblTxtC, tSize)
        f_tc(t, hz, 2, e, f_fmtP(oR), tblTxtC, tSize)
        f_tc(t, hz, 3, e, f_fmtD((oR - close) / close * 100), tblTxtC, tSize)
        f_tc(t, hz, 4, e, "", tblTxtC, tSize)
        e += 1
        for pb in pcts
            float p   = pb * fc
            float lvl = f_rnd(o * (1 - p / 100))
            f_tc(t, hz, 0, e, "Bear", bearCol, tSize)
            f_tc(t, hz, 1, e, str.tostring(p, "#.###"), tblTxtC, tSize)
            f_tc(t, hz, 2, e, f_fmtP(lvl), tblTxtC, tSize)
            f_tc(t, hz, 3, e, f_fmtD((lvl - close) / close * 100), tblTxtC, tSize)
            f_tc(t, hz, 4, e, L.lo <= lvl ? "✓" : "", bearCol, tSize)
            e += 1
    t

// ── Collect → Draw ───────────────────────────────────────────────────────────
if barstate.islast
    for l in lns
        l.delete()
    lns.clear()
    for lb in lbs
        lb.delete()
    lbs.clear()
    for bx in bxs
        bx.delete()
    bxs.clear()
    if not na(dTbl)
        dTbl.delete()
        dTbl := na
    if not na(wTbl)
        wTbl.delete()
        wTbl := na

    if dOn and dTfOk and not dHidden
        f_draw(LD, dPcts, dOpenC, dTag, f_style(dStyleI), dWidth, dOff)
    if wOn and wTfOk and not wHidden
        f_draw(LW, wPcts, wOpenC, wTag, f_style(wStyleI), wWidth, wOff)

    if dTblOn and dOn and not dHidden
        dTbl := f_table(LD, dPcts, dTblPosI, dTfOk, dTf, dOpenC, "INTRADAY LEVELS  ", false)
    if wTblOn and wOn and not wHidden
        wTbl := f_table(LW, wPcts, wTblPosI, wTfOk, wTf, wOpenC, "INTRAWEEK LEVELS  Week of ", true)
````
