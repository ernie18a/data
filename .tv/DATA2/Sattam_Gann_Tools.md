<!-- tradingview-pine-id: PUB;f509791e6f964602992719aae1ba4882 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Sattam | Gann Tools

Source: https://www.tradingview.com/script/HuFPQogO-Sattam-Gann-Tools/

## Description

SATTAM | GANN TOOLS - a complete Gann geometry toolkit on two clicks

Four independent Gann constructions, all built from a single anchor you place
yourself: the Cycle Star, the Gann Grid, four Gann Fans, and tiling Gann
Squares. Each turns on or off without disturbing the others.

=== HOW TO PLACE IT ===

Add the indicator and it asks for two points:

  1. THE ANCHOR - one click sets both the starting price and the starting date.
  2. THE FIRST LEVEL DATE - one click sets the time unit.

Everything else is derived. The gap between the two clicks becomes the box's
time unit, and the starting price becomes the head of the cycle.

=== THE CORE IDEA: THE CYCLE LIVES IN SQUARE-ROOT SPACE ===

The cycle's reach is measured in the SQUARE ROOT of price, not in price:

  end = ( sqrt(startPrice) +/- 2 * sqrt(Space) * totalDegrees / 360 ) ^ 2

With Space = 100 one full turn spans exactly 20 units of sqrt(price). Because
the travel is linear in the root, the price gaps compress as price falls and
open up as it rises - the Square-of-Nine behaviour Gann worked in.

Space is the only input that sets the reach:
  2*sqrt(50)  = 14.1421
  2*sqrt(100) = 20.0000
  2*sqrt(200) = 28.2843

=== CYCLE SHAPE: A POLYGON'S ANGLE SUM ===

Cycle shape decides how far around the cycle travels and in how many steps.
Each polygon is walked in 2n steps covering its interior angle sum,
(n-2)*180, so a single step is (n-2)*90/n:

  SHAPE            SIDES   STEP        STEPS   TOTAL SWEEP
  Triangular         3     30                6     180
  Circular / Square  4     45                8     360
  Pentagon           5     54               10     540
  Hexagon            6     60               12     720
  Heptagon           7     64.2857          14     900
  Octagon            8     67.5             16    1080
  Nonagon            9     70               18    1260
  Decagon           10     72               20    1440
  Straight line      -     90                4     360
  Custom             -     your Angle    derived  derived

The root-space reach scales with the total sweep, so a Decagon travels four
whole turns and reaches four times as far as a Circular cycle. Circular and
Square are the same figure - both are the four-sided case.

Custom takes its step straight from the Angle input: set 60 and you get a
Hexagon; leave it at 0 and it falls back to 45.

=== ANGLES, SECONDARY ANGLES AND TIME LEVELS ===

[image]https://www.tradingview.com/x/ZtdWU8qB/[/image]

Two ways to distribute the levels:

  Calculate Angles by Averages ON
      Levels spaced EQUALLY IN PRICE. Even ladder, constant gaps.

  Calculate Angles by Averages OFF
      Levels spaced EQUALLY IN SQRT(PRICE). The gaps shrink steadily as the
      cycle descends and grow as it rises - the truer Gann reading.

Main and secondary levels alternate by index: even-numbered levels take the
main style and colour, odd-numbered ones the secondary. Draw Secondary Angles
hides the odd ones on their own.

TIME DIVISIONS - the box is (steps / 2) units wide.
  - Solid time levels on 0, 1/4, 1/2, 3/4, 1 of the width.
  - Dashed levels on 1/2 +/- {1/10, 1/6, 1/4, 3/10, 1/3} - the very same five
    fractions the price levels use, mirrored about the middle of time instead
    of the middle of price.

=== THE STAR ===

[image]https://www.tradingview.com/x/i640F7J6/[/image]

The signature figure: the box frame, its mid vertical and mid horizontal, and
FOURTEEN diagonals - corner to opposite corner, corner to the far side's
middle, corner to the mid vertical's opposite end, and the mid vertical's ends
back to both side middles. Twenty lines that mark every internal crossing of
the range.

INTERNAL PRICE LEVELS - five pairs mirrored about the box centre at
1/10, 1/6, 1/4, 3/10 and 1/3 of the span, drawn dotted with their prices
labelled. The quarter pair lands exactly on the 90 and 270 degree levels.

=== THE GANN GRID ===

  Full grid       [image]https://www.tradingview.com/x/9yuccRuQ/[/image]
  Main channel    [image]https://www.tradingview.com/x/Aw2Jum7D/[/image]

A 4 x 4 lattice over the box: the time quarters against the price quarters,
which are the 0/90/180/270/360 degree levels. Every cell carries both of its
diagonals - 32 lines, and nothing else; the grid draws no frame of its own.

Draw only main channel keeps the 1x1 band alone: the diagonal cells keep both
diagonals, the cells directly above and below keep the main one. Fourteen
lines instead of thirty-two.

=== THE GANN FANS ===

  1st fan         [image]https://www.tradingview.com/x/bypt5wbG/[/image]
  2nd fan         [image]https://www.tradingview.com/x/5mncr08E/[/image]
  3rd fan         [image]https://www.tradingview.com/x/af5rjvFH/[/image]
  4th fan         [image]https://www.tradingview.com/x/IDENF8mZ/[/image]
  All four        [image]https://www.tradingview.com/x/5KtmDwuG/[/image]
  Extra Angles    [image]https://www.tradingview.com/x/i8H11Siv/[/image]
  Extend          [image]https://www.tradingview.com/x/qPdf1h8z/[/image]

A fan from any of the four corners of the box, each on or off independently.

Every fan carries the nine classic Gann angles - 1x8, 1x4, 1x3, 1x2, 1x1,
2x1, 3x1, 4x1, 8x1. Each ratio is drawn as two lines: one crossing the full
width and landing on that fraction of the price span, one crossing the full
span and landing on that fraction of the width. The 1x1 belongs to both
families, so a fan is ten lines.

  - Extra Angles adds 5x8, 8x5, 7x8 and 8x7 - four more lines.
  - Extend turns the fan into rays that carry on past the box.

=== THE GANN SQUARE ===

  One square      [image]https://www.tradingview.com/x/Lm5ZdaDL/[/image]
  Tiled squares   [image]https://www.tradingview.com/x/hWBejsCs/[/image]

A square of price against time, drawn as the same twenty-line figure the Star
uses, at its own size.

  - Box Size is the width in CALENDAR DAYS.
  - Height = Box Size x Price Unit.
  - Leave Price Unit at 0 and it resolves automatically to one hundred ticks
    of the symbol - 10 on a 0.1-tick future, 1 on a 0.01-tick stock.
  - Boxes Left / Right / Up / Down tile the identical square in each
    direction, so you can carry the grid of squares across the chart.

The square runs the way the cycle runs: down from the anchor on a falling
cycle, up on a rising one.

=== DIRECTION ===

Trend decides which way the cycle travels from the anchor.

  - Bullish - up.
  - Bearish - down.
  - Auto - compares your anchor price with the LAST CLOSE: an anchor above the
    market runs down, an anchor below it runs up.

=== EXTENDING THE CYCLE ===

  - Extra whole cycle multiplies the walk. On a Circular cycle, 1 takes it
    from 360 to 720 degrees and doubles the reach.
  - Extra primary angle adds one primary angle - 90 degrees, so two steps. On
    a Circular cycle, 1 takes it from 360 to 450 degrees.
  - Time space, when set, replaces the First-Level unit with a plain span of
    calendar days.

=== STYLING ===

Every family has its own style, width and colour: main angles, secondary
angles, time levels, the star, the star's time levels, the star's price
levels, the grid, the fans and the squares. Label size follows the Size input.

=== NOTES ===

  - The two anchor points are interactive inputs. If you edit and recompile
    the script, TradingView clears them and asks for the two clicks again.
  - The drawing is placed by date, so it keeps the same calendar position
    across timeframes.
  - On very long sweeps (Decagon, or a large Extra whole cycle) the root can
    cross zero and square back up. That is the geometry doing what it is
    defined to do, not an error.

---

## Source Code

````pine
// This Pine Script code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (c) SATTAM

//@version=6
// Gann Tools -- four Gann constructions from one anchor you place yourself:
// the Cycle Star, the Gann Grid, four Gann Fans and tiling Gann Squares.
//
// The whole geometry rests on Gann's square of nine, where a cycle is a fixed
// distance in the SQUARE ROOT of price rather than in price:
//
//   end = ( sqrt(startPrice) +/- 2*sqrt(Space) * totalDegrees/360 ) ^ 2
//
// Space alone sets the reach, and the cycle shape sets how far round the
// sweep goes. Because the travel is linear in the root, the price gaps
// compress as price falls and open as it rises.
indicator("Sattam | Gann Tools", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ---------------------------------------------------------------------
// DRAWING DETAILS
// ---------------------------------------------------------------------
gD = "DRAWING DETAILS"
iTitle      = input.string("", "Title", group = gD)
iTf         = input.timeframe("1D", "Timeframe", group = gD)
// Two clicks place the tool: the shared inline makes price and date a single
// interactive point, so the first click sets both, and the second click sets
// the first level date on its own.
iStartPrice = input.price(0.0, "Starting Price", inline = "anchor", group = gD, confirm = true)
iStartTime  = input.time(0, "Date", inline = "anchor", group = gD, confirm = true)
iFirstLevel = input.time(0, "First Level Date", group = gD, confirm = true)
iAngle      = input.int(0, "Angle", group = gD)
iSpace      = input.int(100, "Space", minval = 1, group = gD)
iCycleShape = input.string("Circular", "Cycle shape", options = ["Circular", "Straight line", "Triangular", "Square", "Pentagon", "Hexagon", "Heptagon", "Octagon", "Nonagon", "Decagon", "Custom"], group = gD)
iTrend      = input.string("Auto", "Trend", options = ["Auto", "Bullish", "Bearish"], group = gD)
iTimeSpace  = input.int(0, "Time space", group = gD)
iExtraPrim  = input.int(0, "Extra primary angle?", group = gD)
iExtraCycle = input.int(0, "Extra whole cycle?", group = gD)
iDrawTimeL  = input.bool(true, "Draw Time Levels", group = gD)
iDrawSecAng = input.bool(true, "Draw Secondary Angles", group = gD)
iAngByAvg   = input.bool(true, "Calculate Angles by Averages", group = gD)
iShowAngles = input.bool(true, "Show angles", inline = "ang", group = gD)
iAngTextCol = input.color(color.white, "", inline = "ang", group = gD)
iSize       = input.string("Normal", "Size", options = ["Auto", "Tiny", "Small", "Normal", "Large", "Huge"], group = gD)
iAngTextOff = input.int(50, "Angle text offset", group = gD)
iMainAngSty = input.string("Solid", "Main angle style", options = ["Solid", "Dashed", "Dotted"], group = gD)
iSecAngSty  = input.string("Dashed", "Secondary angle style", options = ["Solid", "Dashed", "Dotted"], group = gD)
iTimeLvlSty = input.string("Solid", "Time levels style", options = ["Solid", "Dashed", "Dotted"], group = gD)
iMainAngCol = input.color(color.white, "Main angles color", group = gD)
iSecAngCol  = input.color(color.white, "Secondary angles color", group = gD)
iTimeLvlCol = input.color(color.white, "Time levels color", group = gD)

// ---------------------------------------------------------------------
// STAR
// ---------------------------------------------------------------------
gS = "STAR"
iShowStar    = input.bool(true, "Show Star", group = gS)
iStarSty     = input.string("Solid", "Star Style", options = ["Solid", "Dashed", "Dotted"], inline = "s1", group = gS)
iStarW       = input.int(1, "Width", minval = 1, inline = "s1", group = gS)
iStarCol     = input.color(color.white, "", inline = "s1", group = gS)
iStarTimeSty = input.string("Dashed", "Time Levels Style", options = ["Solid", "Dashed", "Dotted"], inline = "s2", group = gS)
iStarTimeW   = input.int(1, "Width", minval = 1, inline = "s2", group = gS)
iStarTimeCol = input.color(color.white, "", inline = "s2", group = gS)
iStarPxSty   = input.string("Dotted", "Price Levels Style", options = ["Solid", "Dashed", "Dotted"], inline = "s3", group = gS)
iStarPxW     = input.int(1, "Width", minval = 1, inline = "s3", group = gS)
iStarPxCol   = input.color(color.white, "", inline = "s3", group = gS)
iStarTextOff = input.int(20, "Angle text offset", group = gS)
iStarMidOff  = input.int(0, "Middle offset", group = gS)
iStarType    = input.string("Dynamic", "Type", options = ["Static", "Dynamic"], group = gS)
iStarTimeLvl = input.bool(true, "Draw Time Levels", group = gS)
iStarPxLvl   = input.bool(true, "Draw Price Levels", group = gS)
iStarPxLabel = input.bool(true, "Draw Price Labels", group = gS)

// ---------------------------------------------------------------------
// GANN GRID
// ---------------------------------------------------------------------
gG = "GANN GRID"
iShowGrid     = input.bool(false, "Show Gann Grid", group = gG)
iGridMainOnly = input.bool(false, "Draw only main channel", group = gG)
iGridSty      = input.string("Dashed", "Grid Style", options = ["Solid", "Dashed", "Dotted"], inline = "g1", group = gG)
iGridW        = input.int(1, "Width", minval = 1, inline = "g1", group = gG)
iGridCol      = input.color(color.white, "", inline = "g1", group = gG)

// ---------------------------------------------------------------------
// GANN ANGLES (FANS)
// ---------------------------------------------------------------------
gF = "GANN ANGLES (FANS)"
iShowFan   = input.bool(false, "Show Fan", group = gF)
iFanSty    = input.string("Dashed", "Style", options = ["Solid", "Dashed", "Dotted"], inline = "f1", group = gF)
iFanW      = input.int(1, "Width", minval = 1, inline = "f1", group = gF)
iFanCol    = input.color(color.white, "", inline = "f1", group = gF)
iFanExtra  = input.bool(false, "Extra Angles", group = gF)
iFanExtend = input.bool(false, "Extend", group = gF)
iFan1      = input.bool(true, "1st Fan", group = gF)
iFan2      = input.bool(false, "2nd Fan", group = gF)
iFan3      = input.bool(false, "3rd Fan", group = gF)
iFan4      = input.bool(false, "4th Fan", group = gF)

// ---------------------------------------------------------------------
// GANN SQUARE
// ---------------------------------------------------------------------
gQ = "GANN SQUARE"
iShowSquare = input.bool(false, "Draw Square/s", group = gQ)
iBoxSize    = input.int(90, "Box Size", minval = 1, group = gQ)
iPriceUnit  = input.float(0.0, "Price Unit", group = gQ)
iBoxLeft    = input.int(0, "Boxes Left", minval = 0, group = gQ)
iBoxRight   = input.int(0, "Boxes Right", minval = 0, group = gQ)
iBoxUp      = input.int(0, "Boxes Up", minval = 0, group = gQ)
iBoxDown    = input.int(0, "Boxes Down", minval = 0, group = gQ)
iSquareSty  = input.string("Solid", "Style", options = ["Solid", "Dashed", "Dotted"], inline = "q1", group = gQ)
iSquareW    = input.int(1, "Width", minval = 1, inline = "q1", group = gQ)
iSquareCol  = input.color(color.white, "", inline = "q1", group = gQ)

// ---------------------------------------------------------------------
// Style layer -- the only place input strings become drawing arguments
// ---------------------------------------------------------------------
f_lineStyle(s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

f_textSize(s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Large" ? size.large : s == "Huge" ? size.huge : s == "Auto" ? size.auto : size.normal

// ---------------------------------------------------------------------
// Drawing store -- everything drawn is owned here and cleared together
// ---------------------------------------------------------------------
var line[]  LINES  = array.new<line>()
var label[] LABELS = array.new<label>()

f_clear() =>
    if array.size(LINES) > 0
        for i = 0 to array.size(LINES) - 1
            line.delete(array.get(LINES, i))
        array.clear(LINES)
    if array.size(LABELS) > 0
        for i = 0 to array.size(LABELS) - 1
            label.delete(array.get(LABELS, i))
        array.clear(LABELS)

f_hline(p, t1, t2, sty, w, col) =>
    array.push(LINES, line.new(t1, p, t2, p, xloc = xloc.bar_time, style = f_lineStyle(sty), width = w, color = col))

f_hlineExt(p, t1, t2, sty, w, col) =>
    array.push(LINES, line.new(t1, p, t2, p, xloc = xloc.bar_time, extend = extend.both, style = f_lineStyle(sty), width = w, color = col))

f_vline(t, p1, p2, sty, w, col) =>
    array.push(LINES, line.new(t, p1, t, p2, xloc = xloc.bar_time, style = f_lineStyle(sty), width = w, color = col))

f_diag(t1, p1, t2, p2, sty, w, col) =>
    array.push(LINES, line.new(t1, p1, t2, p2, xloc = xloc.bar_time, style = f_lineStyle(sty), width = w, color = col))

f_fanLine(t1, p1, t2, p2) =>
    // Extend turns the whole fan into rays that carry on past the box.
    array.push(LINES, line.new(t1, p1, t2, p2, xloc = xloc.bar_time, extend = iFanExtend ? extend.right : extend.none, style = f_lineStyle(iFanSty), width = iFanW, color = iFanCol))

// Degree texts. The number keeps Pine's default float formatting, so a
// Heptagon step prints in full as 64.2857142857 rather than rounded away.
f_degText(deg, price) =>
    str.tostring(deg) + "° (" + str.tostring(price, "#.##") + ")"

f_pxText(price) =>
    // Two decimals with trailing zeros trimmed. format.mintick would be too
    // coarse on instruments whose tick is larger than a cent.
    str.tostring(price, "#.##")

f_label(t, p, txt, col) =>
    array.push(LABELS, label.new(t, p, txt, xloc = xloc.bar_time, style = label.style_none, textcolor = col, size = f_textSize(iSize)))

// An indicator with no output at all fails to compile (CE10246).
plot(na, "anchor", display = display.none)

// ---------------------------------------------------------------------
// Cycle layer -- direction, sweep and the square-of-nine reach
// ---------------------------------------------------------------------
f_dirSign() =>
    // Bearish runs the cycle down from the anchor, Bullish up, and Auto reads
    // the market: an anchor above the last close runs down, below it runs up.
    iTrend == "Bullish" ? 1.0 : iTrend == "Bearish" ? -1.0 : iStartPrice > close ? -1.0 : 1.0

// Cycle shape. Each polygon is walked in 2n steps covering its angle sum,
// (n-2)*180 degrees, so one step is (n-2)*90/n. Circular and Square are both
// the four-sided case and draw the same figure. Straight line is the one
// member that is not a polygon: four steps of 90. Custom takes its step
// straight from Angle, and 0 falls back to 45.
f_stepDeg() =>
    n = iCycleShape == "Triangular" ? 3 : iCycleShape == "Pentagon" ? 5 : iCycleShape == "Hexagon" ? 6 : iCycleShape == "Heptagon" ? 7 : iCycleShape == "Octagon" ? 8 : iCycleShape == "Nonagon" ? 9 : iCycleShape == "Decagon" ? 10 : 4
    iCycleShape == "Straight line" ? 90.0 : iCycleShape == "Custom" ? (iAngle > 0 ? float(iAngle) : 45.0) : (n - 2) * 90.0 / n

f_stepCount() =>
    // Extra whole cycle multiplies the walk: 1 takes Circular from 360 to 720
    // degrees. Extra primary angle adds one primary angle, which is 90 degrees
    // and therefore two steps: 1 takes Circular to 450.
    base = iCycleShape == "Straight line" ? 4 : int(math.round(360.0 / (90.0 - f_stepDeg())))
    base * (1 + iExtraCycle) + 2 * iExtraPrim

f_totalDeg() =>
    f_stepCount() * f_stepDeg()

f_cycleSqrt() =>
    // One whole cycle reaches this far in sqrt(price). Space sets the base --
    // 2*sqrt(50)=14.1421, 2*sqrt(100)=20, 2*sqrt(200)=28.2843 -- and the shape
    // scales it by how far round the sweep goes. A Decagon covers four whole
    // turns, so on a small anchor its root can cross zero and square back up.
    // That is the definition doing its work, not an error.
    2.0 * math.sqrt(iSpace) * f_totalDeg() / 360.0

f_cycleEnd() =>
    math.pow(math.sqrt(iStartPrice) + f_dirSign() * f_cycleSqrt(), 2)

f_cycleSpan() =>
    math.abs(iStartPrice - f_cycleEnd())

f_cycleMid() =>
    (iStartPrice + f_cycleEnd()) / 2.0

// ---------------------------------------------------------------------
// STAR -- price levels
// ---------------------------------------------------------------------
f_degPrice(i) =>
    // i counts steps down the cycle. With Calculate Angles by Averages the
    // steps are equal in price; without it they are equal in sqrt(price),
    // which is what makes the gaps shrink by a constant.
    d = f_dirSign()
    n = f_stepCount()
    iAngByAvg ? iStartPrice + d * f_cycleSpan() * i / n : math.pow(math.sqrt(iStartPrice) + d * f_cycleSqrt() * i / n, 2)

f_degreeLevels(t1, t2, tLab) =>
    // The degree levels and their texts. Show angles owns all of them, and
    // Draw Secondary Angles owns the odd-indexed ones inside that.
    //
    // Main and secondary alternate by level INDEX, not by multiples of 90, so
    // the alternation holds for every shape: Straight line has five levels,
    // all of them multiples of 90, and still splits three against two.
    a = f_stepDeg()
    for i = 0 to f_stepCount()
        isMain = i % 2 == 0
        if isMain or iDrawSecAng
            p = f_degPrice(i)
            f_hlineExt(p, t1, t2, isMain ? iMainAngSty : iSecAngSty, 1, isMain ? iMainAngCol : iSecAngCol)
            f_label(tLab, p, f_degText(a * i, p), iAngTextCol)

f_starInternals(t1, t2, tLab) =>
    // Five pairs mirrored about the box centre, at 1/10, 1/6, 1/4, 3/10 and
    // 1/3 of the span. The quarter pair lands on the 90 and 270 degree levels,
    // so those two prices carry two lines each -- ten dotted lines, not eight.
    //
    // Draw Price Levels owns this whole block, texts included; Draw Price
    // Labels sits inside it and drops the texts alone.
    mid = f_cycleMid()
    span = f_cycleSpan()
    fr = array.from(0.1, 1.0 / 6.0, 0.25, 0.3, 1.0 / 3.0)
    // The first pair's texts come out before the centre and the end, so the
    // labels read outward from the middle of the range.
    if array.size(fr) > 0
        for i = 0 to array.size(fr) - 1
            f = array.get(fr, i)
            pDn = mid - f * span
            pUp = mid + f * span
            if iStarPxLabel
                f_label(tLab, pDn, f_pxText(pDn), iStarPxCol)
                f_label(tLab, pUp, f_pxText(pUp), iStarPxCol)
                if i == 0
                    f_label(tLab, mid, f_pxText(mid), iStarPxCol)
                    f_label(tLab, f_cycleEnd(), f_pxText(f_cycleEnd()), iStarPxCol)
            f_hline(pDn, t1, t2, iStarPxSty, iStarPxW, iStarPxCol)
            f_hline(pUp, t1, t2, iStarPxSty, iStarPxW, iStarPxCol)

// ---------------------------------------------------------------------
// STAR -- time levels and the star figure
// ---------------------------------------------------------------------
// The box is half the step count wide in First-Level units. Its time
// divisions carry the very same five fractions the price levels do: the solid
// levels land on 0, 1/4, 1/2, 3/4 and 1 of the width, and the dashed ones on
// 1/2 +/- {1/10, 1/6, 1/4, 3/10, 1/3} -- the same set, mirrored about the
// middle of time instead of the middle of price.
f_mainTimeLevels(t0, tUnit, pA, pB) =>
    // One per First-Level unit across the box, so half the step count plus
    // one. These belong to the angles group, not the star: Show angles takes
    // them down along with the degree levels.
    //
    // pA is the ANCHOR side and pB the far side, in that order -- not
    // geometric top and bottom, so a rising cycle keeps the same handedness.
    for k = 0 to f_stepCount() / 2
        f_vline(t0 + tUnit * k, pA, pB, iTimeLvlSty, 1, iTimeLvlCol)

f_starTimeLevels(t0, tUnit, pA, pB) =>
    fr = array.from(0.1, 1.0 / 6.0, 0.25, 0.3, 1.0 / 3.0)
    w = tUnit * f_stepCount() / 2
    if array.size(fr) > 0
        for i = 0 to array.size(fr) - 1
            f = array.get(fr, i)
            f_vline(t0 + int(w * (0.5 - f)), pA, pB, iStarTimeSty, iStarTimeW, iStarTimeCol)
            f_vline(t0 + int(w * (0.5 + f)), pA, pB, iStarTimeSty, iStarTimeW, iStarTimeCol)

f_figure(t0, tEnd, tMid, pA, pB, sty, w, col) =>
    // Twenty lines: the frame, the two middles, and fourteen diagonals that
    // run corner to corner, corner to far middle, corner to the mid vertical's
    // opposite end, and the mid vertical's ends to both side middles.
    //
    // pA is the ANCHOR side, pB the far side, and keeping that order is what
    // keeps a rising cycle consistent with a falling one.
    //
    // The Gann Square draws this very same figure at its own size.
    pMid = (pA + pB) / 2.0
    f_vline(t0,   pA, pB, sty, w, col)
    f_vline(tEnd, pA, pB, sty, w, col)
    f_vline(tMid, pA, pB, sty, w, col)
    f_hline(pA,   t0, tEnd, sty, w, col)
    f_hline(pB,   t0, tEnd, sty, w, col)
    f_hline(pMid, t0, tEnd, sty, w, col)
    f_diag(t0,   pA, tEnd, pB,   sty, w, col)
    f_diag(t0,   pB, tEnd, pA,   sty, w, col)
    f_diag(t0,   pA, tEnd, pMid, sty, w, col)
    f_diag(t0,   pB, tEnd, pMid, sty, w, col)
    f_diag(tEnd, pA, t0,   pMid, sty, w, col)
    f_diag(tEnd, pB, t0,   pMid, sty, w, col)
    f_diag(t0,   pA, tMid, pB,   sty, w, col)
    f_diag(t0,   pB, tMid, pA,   sty, w, col)
    f_diag(tEnd, pA, tMid, pB,   sty, w, col)
    f_diag(tEnd, pB, tMid, pA,   sty, w, col)
    f_diag(tMid, pA, t0,   pMid, sty, w, col)
    f_diag(tMid, pA, tEnd, pMid, sty, w, col)
    f_diag(tMid, pB, t0,   pMid, sty, w, col)
    f_diag(tMid, pB, tEnd, pMid, sty, w, col)

f_star(t0, tUnit, pA, pB) =>
    w = tUnit * f_stepCount() / 2
    f_figure(t0, t0 + w, t0 + w / 2 + iStarMidOff, pA, pB, iStarSty, iStarW, iStarCol)

// ---------------------------------------------------------------------
// GANN ANGLES (FANS)
// ---------------------------------------------------------------------
// Nine Gann angles from one corner of the box. Each fraction gives two lines:
// one crossing the full width and landing on that fraction of the span, one
// crossing the full span and landing on that fraction of the width. The 1x1
// belongs to both families and is emitted in each, so a fan is ten lines and
// not nine. Extra Angles adds 5/8 and 7/8 both ways.
f_fan(tCorner, pCorner, tFar, pFar) =>
    fr = array.from(0.125, 0.25, 1.0 / 3.0, 0.5, 1.0)
    ex = array.from(0.625, 0.875)
    if array.size(fr) > 0
        for i = 0 to array.size(fr) - 1
            f = array.get(fr, i)
            f_fanLine(tCorner, pCorner, tFar, pCorner + (pFar - pCorner) * f)
            f_fanLine(tCorner, pCorner, tCorner + int((tFar - tCorner) * f), pFar)
    if iFanExtra and array.size(ex) > 0
        for i = 0 to array.size(ex) - 1
            f = array.get(ex, i)
            f_fanLine(tCorner, pCorner, tFar, pCorner + (pFar - pCorner) * f)
            f_fanLine(tCorner, pCorner, tCorner + int((tFar - tCorner) * f), pFar)

// ---------------------------------------------------------------------
// GANN GRID
// ---------------------------------------------------------------------
// A 4 x 4 lattice: the box's time quarters against its price quarters, which
// are the 0/90/180/270/360 degree levels. Every cell carries both of its
// diagonals and nothing else -- the grid draws no frame of its own.
// Draw only main channel keeps the 1x1 band: the diagonal cells keep both
// diagonals, their immediate neighbours above and below keep the main one.
f_grid(t0, tUnit, pA, pB) =>
    // A 4 x 4 lattice regardless of cycle shape. Rows run from the anchor side
    // towards the far side, so the signs carry both directions without a
    // special case.
    cellW = (tUnit * f_stepCount() / 2) / 4
    quarter = (pA - pB) / 4.0
    goingDown = f_dirSign() < 0
    for col = 0 to 3
        for row = 0 to 3
            tA = t0 + cellW * col
            tB = tA + cellW
            pHi = pA - quarter * row
            pLo = pHi - quarter
            // On a falling cycle the anchor is the top-left corner, so the
            // 1x1 runs through the diagonal cells; a rising cycle mirrors it.
            onBand = goingDown ? row == col : row == 3 - col
            nextTo = goingDown ? math.abs(row - col) == 1 : math.abs(row - (3 - col)) == 1
            if not iGridMainOnly or onBand
                f_diag(tA, pHi, tB, pLo, iGridSty, iGridW, iGridCol)
                f_diag(tB, pHi, tA, pLo, iGridSty, iGridW, iGridCol)
            else if nextTo
                if goingDown
                    f_diag(tA, pHi, tB, pLo, iGridSty, iGridW, iGridCol)
                else
                    f_diag(tB, pHi, tA, pLo, iGridSty, iGridW, iGridCol)

// ---------------------------------------------------------------------
// GANN SQUARE
// ---------------------------------------------------------------------
// Box Size is the width in CALENDAR days, and the height is
// Box Size x Price Unit. Price Unit 0 resolves automatically to one hundred
// ticks of the symbol: 10 on a 0.1-tick future, 1 on a 0.01-tick stock.
f_squares(t0, pAnchor) =>
    unit = iPriceUnit > 0 ? iPriceUnit : syminfo.mintick * 100
    // The square runs the way the cycle runs: down from the anchor on a
    // falling cycle, up on a rising one.
    boxH = iBoxSize * unit * f_dirSign()
    boxW = iBoxSize * 86400000
    for cx = -iBoxLeft to iBoxRight
        for cy = -iBoxDown to iBoxUp
            tA = t0 + boxW * cx
            pNear = pAnchor + boxH * cy
            pFar = pNear + boxH
            f_figure(tA, tA + boxW, tA + boxW / 2, pNear, pFar, iSquareSty, iSquareW, iSquareCol)

// ---------------------------------------------------------------------
// One drawing block owns the whole indicator. Every unit reads the anchor
// and the cycle from here, so turning STAR off must not silence the rest.
// ---------------------------------------------------------------------
if barstate.islast and iStartTime > 0 and iStartPrice > 0
    f_clear()
    // Time space, when set, replaces the First-Level unit with a plain span
    // of calendar days.
    tUnit = iTimeSpace > 0 ? iTimeSpace * 86400000 : math.max(iFirstLevel - iStartTime, 1)
    tEnd = iStartTime + tUnit * f_stepCount() / 2
    // Anchor side first, far side second -- not geometric top and bottom.
    pA = iStartPrice
    pB = f_cycleEnd()
    // Label columns: the degree texts sit at 5/6 of the box width and the
    // price texts a quarter-unit past its right edge.
    tDegLab = iStartTime + int((tEnd - iStartTime) * 5.0 / 6.0)
    tPxLab = tEnd + tUnit / 4
    // Two independent groups: the angles and the star gate separately.
    if iShowAngles
        f_degreeLevels(iStartTime, tEnd, tDegLab)
        if iDrawTimeL
            f_mainTimeLevels(iStartTime, tUnit, pA, pB)
    if iShowStar
        f_star(iStartTime, tUnit, pA, pB)
        if iStarTimeLvl
            f_starTimeLevels(iStartTime, tUnit, pA, pB)
        if iStarPxLvl
            f_starInternals(iStartTime, tEnd, tPxLab)
    if iShowGrid
        f_grid(iStartTime, tUnit, pA, pB)
    if iShowSquare
        f_squares(iStartTime, iStartPrice)
    // The four fans are the four corners of the box.
    if iShowFan
        if iFan1
            f_fan(iStartTime, pA, tEnd, pB)
        if iFan2
            f_fan(iStartTime, pB, tEnd, pA)
        if iFan3
            f_fan(tEnd, pB, iStartTime, pA)
        if iFan4
            f_fan(tEnd, pA, iStartTime, pB)
````
