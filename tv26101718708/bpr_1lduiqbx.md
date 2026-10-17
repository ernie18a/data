# BPR

- url: https://www.tradingview.com/script/1lDUIQbX-BPR/
- type: indicator
- pine_id: PUB;d5ccc6d047f64fdab4e988262aa4c2de
- version: 1.0

## Description

places blocks on the tabel for support and resistance this is just so fire tbh

## Source Code

````pine
//@version=6
indicator("BPR", overlay=true, max_boxes_count=500)

// ═══════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════

grp1 = "Detection"
minGap  = input.float(0.2, "Min FVG Gap (ATR x)", minval=0, step=0.1, group=grp1)
maxAge  = input.int(50,    "Max FVG Age (bars)",   minval=5, maxval=200, group=grp1)

grp2 = "Display"
maxShow = input.int(50,  "Max BPR Shown",       minval=1, maxval=100, group=grp2)
maxLife = input.int(500, "Max BPR Life (bars)",  minval=50, maxval=2000, group=grp2)
extBars = input.int(20,  "Extend Right (bars)",  minval=1, maxval=100, group=grp2)
cLong   = input.color(color.new(#26A69A, 78), "Long BPR",  group=grp2)
cShort  = input.color(color.new(#9C27B0, 78), "Short BPR", group=grp2)

// ═══════════════════════════════════════════════════════════════
// ATR FILTER
// ═══════════════════════════════════════════════════════════════

atr   = ta.atr(14)
minSz = minGap * nz(atr, 1.0)

// ═══════════════════════════════════════════════════════════════
// DATA TYPES
// ═══════════════════════════════════════════════════════════════

type FVGdata
    float hi
    float lo
    int   bar

type BPRdata
    box   bx
    float hi
    float lo
    int   dir     // 1 = bullish BPR (look for longs), -1 = bearish BPR (look for shorts)
    int   born
    bool  tested  // price has entered the zone at least once

// ═══════════════════════════════════════════════════════════════
// STORAGE
// ═══════════════════════════════════════════════════════════════

var array<FVGdata> bulls = array.new<FVGdata>()
var array<FVGdata> bears = array.new<FVGdata>()
var array<BPRdata> bprs  = array.new<BPRdata>()

// ═══════════════════════════════════════════════════════════════
// FVG DETECTION + BPR MATCHING
// ═══════════════════════════════════════════════════════════════

bullFVG = bar_index >= 2 and low > high[2] and (low - high[2]) >= minSz
bearFVG = bar_index >= 2 and low[2] > high and (low[2] - high) >= minSz

// New bullish FVG — check for overlap with recent bearish FVGs
if bullFVG
    FVGdata f = FVGdata.new()
    f.hi  := low
    f.lo  := high[2]
    f.bar := bar_index
    array.push(bulls, f)

    if array.size(bears) > 0
        for i = array.size(bears) - 1 to 0
            FVGdata b = array.get(bears, i)
            if bar_index - b.bar <= maxAge
                float oT = math.min(f.hi, b.hi)
                float oB = math.max(f.lo, b.lo)
                if oT > oB
                    // Overlap found = BPR
                    // Direction: most recent FVG is bullish, so this is a bullish BPR
                    // (price left upward, zone below = support = look for longs)
                    BPRdata bp = BPRdata.new()
                    bp.hi     := oT
                    bp.lo     := oB
                    bp.dir    := 1
                    bp.born   := bar_index
                    bp.tested := false
                    bp.bx     := box.new(bar_index - 2, oT, bar_index + extBars, oB,
                                   border_color=cLong, border_width=2,
                                   bgcolor=cLong)
                    array.push(bprs, bp)
                    if array.size(bprs) > maxShow
                        box.delete(array.shift(bprs).bx)
                    break  // one BPR per new FVG

// New bearish FVG — check for overlap with recent bullish FVGs
if bearFVG
    FVGdata f = FVGdata.new()
    f.hi  := low[2]
    f.lo  := high
    f.bar := bar_index
    array.push(bears, f)

    if array.size(bulls) > 0
        for i = array.size(bulls) - 1 to 0
            FVGdata b = array.get(bulls, i)
            if bar_index - b.bar <= maxAge
                float oT = math.min(f.hi, b.hi)
                float oB = math.max(f.lo, b.lo)
                if oT > oB
                    BPRdata bp = BPRdata.new()
                    bp.hi     := oT
                    bp.lo     := oB
                    bp.dir    := -1
                    bp.born   := bar_index
                    bp.tested := false
                    bp.bx     := box.new(bar_index - 2, oT, bar_index + extBars, oB,
                                   border_color=cShort, border_width=2,
                                   bgcolor=cShort)
                    array.push(bprs, bp)
                    if array.size(bprs) > maxShow
                        box.delete(array.shift(bprs).bx)
                    break

// ═══════════════════════════════════════════════════════════════
// BPR MANAGEMENT — EXTEND, TEST, INVALIDATE
// ═══════════════════════════════════════════════════════════════

if array.size(bprs) > 0
    for i = array.size(bprs) - 1 to 0
        BPRdata bp = array.get(bprs, i)

        // Check if price is testing the zone
        bool inZone = low <= bp.hi and high >= bp.lo
        if inZone and not bp.tested
            bp.tested := true
            // Thicken border when zone gets tested (visual feedback)
            box.set_border_width(bp.bx, 3)

        // Invalidation: close through the zone
        bool dead = false
        if bp.dir == 1 and close < bp.lo
            dead := true
        if bp.dir == -1 and close > bp.hi
            dead := true

        // Expiry
        bool expired = bar_index - bp.born > maxLife

        if dead or expired
            box.delete(bp.bx)
            array.remove(bprs, i)
        else
            // Extend active boxes forward
            box.set_right(bp.bx, bar_index + 5)

// ═══════════════════════════════════════════════════════════════
// CLEANUP OLD FVGs
// ═══════════════════════════════════════════════════════════════

if array.size(bulls) > 0
    for i = array.size(bulls) - 1 to 0
        if bar_index - array.get(bulls, i).bar > maxAge * 2
            array.remove(bulls, i)

if array.size(bears) > 0
    for i = array.size(bears) - 1 to 0
        if bar_index - array.get(bears, i).bar > maxAge * 2
            array.remove(bears, i)
````
