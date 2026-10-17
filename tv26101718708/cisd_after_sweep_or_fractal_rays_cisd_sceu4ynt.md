# CISD after Sweep or Fractal Rays  CISD

- url: https://www.tradingview.com/script/sCeU4Ynt-CISD-after-Sweep-or-Fractal-Rays-CISD/
- type: indicator
- pine_id: PUB;a61c8f40c4664984a679fafebdd10519
- version: 1.0

## Description

CISD after Sweep — Fractal Rays + CISD

This indicator maps out swing-point liquidity sweeps and the "Change in State of Delivery" (CISD) reactions that follow them.

How it works

Fractal rays — the script marks swing highs/lows using a standard fractal (N bars on each side). Each fractal is drawn as a horizontal ray from its bar forward, and its state is tracked live:
Untested — price hasn't reached the level yet
Tested — price wicked into the level but the candle body didn't close through it
Broken — a candle closed through the level (ray stops at the break)

An optional 2-candle reversal rule can downgrade what looks like a break back to "tested" if the very next candle closes back on the safe side of the level.

CISD detection — once a fractal is wick-tested (swept), the script scans back over the recent candles for the last displacement candle in the opposite direction (a bearish candle closing below the sweep's low for a swept high, or a bullish candle closing above the sweep's high for a swept low). That candle's close becomes a CISD level:
Drawn as a dashed, faded line while pending
Turns solid once price closes back through the CISD level (confirmed shift in delivery)
Removed if price instead closes back through the original fractal price first (invalidated)

Inputs

Fractal period, history depth, and broken-ray display limit
Independent color/width/style controls for untested, tested, and broken rays
CISD scan depth, line width, label toggle, bullish/bearish colors, and pending-line opacity
Optional 2-candle tested-reversal rule
Anti-blink option that defers break verdicts until the forming candle closes, so lines don't flicker between states intra-bar

Notes

All levels are read from confirmed price action only (or the forming candle's wick, where noted) — nothing is calculated from future data.
Ray extension and CISD-level scan depth are both bar-limited for performance; very old fractals beyond the "Max Candles Back" setting are not tracked.
This is a structure/context tool, not a standalone signal generator — combine it with your own entry and risk criteria.

## Source Code

````pine
//@version=6
indicator("CISD after Sweep — Fractal Rays + CISD", shorttitle="CISD after Sweep",
     overlay=true, max_bars_back=500, max_lines_count=500, max_labels_count=500)

// ============================================================================
//  Fractal Rays + CISD (Change in State of Delivery)

// ============================================================================

// ---------------- Inputs ----------------
grpFractal = "Fractal Settings"
fp                  = input.int(5, "Fractal Period", minval=1, group=grpFractal)
candleLimit         = input.int(200, "Max Candles Back (history depth processed)", minval=1, group=grpFractal)
extendTestedRay     = input.bool(true, "Extend Tested Ray to current bar", group=grpFractal)
showBroken          = input.int(50, "Show Broken (count). 0 = unlimited", minval=0, group=grpFractal)
enable2CandleTested = input.bool(false, "Enable 2-Candle Tested Reversal", group=grpFractal)

grpStyle = "Fractal Ray Styles"
colUntested   = input.color(#1E90FF, "Untested", group=grpStyle)
widthUntested = input.int(1, "Untested Width", minval=1, group=grpStyle)
dashUntested  = input.bool(false, "Untested Dashed", group=grpStyle)
colTested     = input.color(color.rgb(255, 174, 0), "Tested", group=grpStyle)
widthTested   = input.int(2, "Tested Width", minval=1, group=grpStyle)
dashTested    = input.bool(true, "Tested Dashed", group=grpStyle)
colBroken     = input.color(#808080, "Broken", group=grpStyle)
widthBroken   = input.int(1, "Broken Width", minval=1, group=grpStyle)
dashBroken    = input.bool(true, "Broken Dashed", group=grpStyle)

grpCisd = "CISD Settings"
showCisd       = input.bool(true, "Show CISD", group=grpCisd)
cisdScanLeft   = input.int(30, "Max Scan Left (bars)", minval=1, maxval=490, group=grpCisd)
cisdWidth      = input.int(2, "CISD Width", minval=1, group=grpCisd)
cisdShowLabel  = input.bool(true, "Show CISD Label", group=grpCisd)
colBull        = input.color(#1E90FF, "+CISD", group=grpCisd)
colBear        = input.color(#DC143C, "-CISD", group=grpCisd)
pendingOpacity = input.float(0.4, "Pending Opacity (0..1)", minval=0.0, maxval=1.0, step=0.05, group=grpCisd)

grpBeh = "Behaviour"
deferLiveBreak = input.bool(true, "Defer break verdicts on forming bar (anti-blink)", group=grpBeh)

// ---------------- Types ----------------
type Fractal
    int   fractalBar
    int   confirmBar
    int   testedBar      = na
    int   breakBar        = na
    float price
    bool  isHigh
    int   state           = 0     // 0 untested, 1 tested, 2 broken
    bool  cisdSpawned     = false
    bool  skip            = false
    bool  pendingBreak    = false
    int   pendingBreakBar = na
    line  ray             = na

type Cisd
    bool    isBullish
    int     testBar
    int     displaceBar
    float   level
    int     step          = 0     // 0 pending(dashed), 1 confirmed, 2 invalidated
    int     confirmBar    = na
    Fractal src
    line    ray           = na
    label   lbl           = na

var Fractal[] fractals    = array.new<Fractal>()
var Cisd[]    cisds       = array.new<Cisd>()
var Fractal[] brokenOrder = array.new<Fractal>()

// ---------------- helpers ----------------
pendingTransp = int(math.round((1.0 - pendingOpacity) * 100))

f_lineStyle(dashed) =>
    dashed ? line.style_dashed : line.style_solid

// ============================================================================
// 1. Fractal detection - pivot confirmation is delayed fp bars automatically
// ============================================================================
ph = ta.pivothigh(high, fp, fp)
pl = ta.pivotlow(low, fp, fp)

withinLimit = bar_index >= last_bar_index - candleLimit - fp - 5

if not na(ph) and withinLimit
    array.push(fractals, Fractal.new(fractalBar=bar_index - fp, confirmBar=bar_index, price=ph, isHigh=true))
if not na(pl) and withinLimit
    array.push(fractals, Fractal.new(fractalBar=bar_index - fp, confirmBar=bar_index, price=pl, isHigh=false))

// ============================================================================
// 2. Fractal state machine (Untested -> Tested -> Broken) + 3. CISD spawn
// ============================================================================
nFractals = array.size(fractals)
if nFractals > 0
    for i = 0 to nFractals - 1
        f = array.get(fractals, i)

        if f.state != 2
            if f.pendingBreak
                // Resolve on the bar AFTER the pierce, using this bar's close -
                // mirrors MQL5's `close[i-1]` next-candle check.
                reclaimed = f.isHigh ? close <= f.price : close >= f.price
                if reclaimed
                    f.state := 1
                    f.testedBar := f.pendingBreakBar
                else
                    f.state := 2
                    f.breakBar := f.pendingBreakBar
                    array.push(brokenOrder, f)
                    if showBroken > 0
                        while array.size(brokenOrder) > showBroken
                            oldest = array.shift(brokenOrder)
                            oldest.skip := true
                            if not na(oldest.ray)
                                line.delete(oldest.ray)
                                oldest.ray := na
                f.pendingBreak := false
            else
                piercedBody = f.isHigh ? close > f.price : close < f.price
                allowBreak  = not deferLiveBreak or barstate.isconfirmed
                if piercedBody and allowBreak
                    if enable2CandleTested
                        f.pendingBreak := true
                        f.pendingBreakBar := bar_index
                    else
                        f.state := 2
                        f.breakBar := bar_index
                        array.push(brokenOrder, f)
                        if showBroken > 0
                            while array.size(brokenOrder) > showBroken
                                oldest = array.shift(brokenOrder)
                                oldest.skip := true
                                if not na(oldest.ray)
                                    line.delete(oldest.ray)
                                    oldest.ray := na
                else
                    wicked = f.isHigh ? high >= f.price : low <= f.price
                    if wicked and f.state == 0
                        f.state := 1
                        f.testedBar := bar_index

        // ---- CISD spawn on the exact bar this fractal becomes wick-tested ----
        if showCisd and f.testedBar == bar_index and not f.cisdSpawned
            testHigh = high
            testLow  = low
            displaceOffset = -1
            float displaceClose = na
            for s = 1 to cisdScanLeft
                if bar_index - s < 0
                    break
                so = open[s]
                sc = close[s]
                if f.isHigh
                    if sc < so and sc < testLow
                        displaceOffset := s
                        displaceClose  := sc
                        break
                else
                    if sc > so and sc > testHigh
                        displaceOffset := s
                        displaceClose  := sc
                        break
            if displaceOffset > 0
                f.cisdSpawned := true
                array.push(cisds, Cisd.new(isBullish=not f.isHigh, testBar=bar_index,
                     displaceBar=bar_index - displaceOffset, level=displaceClose, src=f))

// ============================================================================
// 4. CISD confirm / invalidate
// ============================================================================
nCisds = array.size(cisds)
if showCisd and nCisds > 0
    for j = 0 to nCisds - 1
        c = array.get(cisds, j)
        if c.step == 0 and bar_index > c.testBar
            bodyBroke = c.isBullish ? close < c.src.price : close > c.src.price
            if bodyBroke
                c.step := 2
            else
                confirmed = c.isBullish ? close > c.level : close < c.level
                if confirmed
                    c.step := 1
                    c.confirmBar := bar_index

// ============================================================================
// 5. Drawing - persistent line/label objects moved & re-styled in place
//    (no delete+recreate per bar, so no flicker)
// ============================================================================
nFractals2 = array.size(fractals)
if nFractals2 > 0
    for i = 0 to nFractals2 - 1
        f = array.get(fractals, i)
        if not f.skip
            x1  = f.fractalBar
            x2  = bar_index
            col = colUntested
            wid = widthUntested
            sty = f_lineStyle(dashUntested)
            drawIt = true
            if f.state == 2
                if na(f.breakBar)
                    drawIt := false
                else
                    x2  := f.breakBar
                    col := colBroken
                    wid := widthBroken
                    sty := f_lineStyle(dashBroken)
            else if f.state == 1
                x2  := extendTestedRay ? bar_index : f.testedBar
                col := colTested
                wid := widthTested
                sty := f_lineStyle(dashTested)
            if drawIt
                if na(f.ray)
                    f.ray := line.new(x1, f.price, x2, f.price, xloc=xloc.bar_index, color=col, width=wid, style=sty)
                else
                    line.set_xy1(f.ray, x1, f.price)
                    line.set_xy2(f.ray, x2, f.price)
                    line.set_color(f.ray, col)
                    line.set_width(f.ray, wid)
                    line.set_style(f.ray, sty)

nCisds2 = array.size(cisds)
if showCisd and nCisds2 > 0
    for j = 0 to nCisds2 - 1
        c = array.get(cisds, j)
        if c.step == 2
            if not na(c.ray)
                line.delete(c.ray)
                c.ray := na
            if not na(c.lbl)
                label.delete(c.lbl)
                c.lbl := na
        else
            isSolid = c.step == 1
            baseCol = c.isBullish ? colBull : colBear
            lineCol = isSolid ? baseCol : color.new(baseCol, pendingTransp)
            sty     = isSolid ? line.style_solid : line.style_dashed
            x1      = c.displaceBar
            x2      = isSolid ? c.confirmBar : bar_index
            if na(c.ray)
                c.ray := line.new(x1, c.level, x2, c.level, xloc=xloc.bar_index, color=lineCol, width=cisdWidth, style=sty)
            else
                line.set_xy1(c.ray, x1, c.level)
                line.set_xy2(c.ray, x2, c.level)
                line.set_color(c.ray, lineCol)
                line.set_style(c.ray, sty)
            if cisdShowLabel
                txt = isSolid ? (c.isBullish ? "+CISD" : "-CISD") : (c.isBullish ? "+CISD protection" : "-CISD protection")
                if na(c.lbl)
                    c.lbl := label.new(x1, c.level, txt, xloc=xloc.bar_index, style=label.style_label_up,
                         color=color.new(color.black, 100), textcolor=lineCol, size=size.small)
                else
                    label.set_text(c.lbl, txt)
                    label.set_textcolor(c.lbl, lineCol)
````
