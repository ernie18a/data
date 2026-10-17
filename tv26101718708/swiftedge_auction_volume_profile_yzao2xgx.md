# Swiftedge Auction Volume Profile

- url: https://www.tradingview.com/script/yZaO2xGX-Swiftedge-Auction-Volume-Profile/
- type: indicator
- pine_id: PUB;ef04bed6ae1d4e0bab89f7250cab81e3
- version: 1.0

## Description

Swing-Anchored Auction Volume Profile

This indicator automatically builds a separate volume profile for each market swing, instead of using one fixed range or session. It is based on auction market theory: a market alternates between balance (acceptance) and imbalance (a directional swing). By anchoring a fresh profile to every significant swing leg, you can read where value was built during each individual move — and how those value areas line up as support and resistance.

What it does

Detects significant swings using an ATR- or point-based zigzag, so only moves above a size you choose are treated as new swings.
At every confirmed swing pivot (high or low), it freezes the previous leg's profile and starts a new one, running from one pivot to the next.
For each leg it calculates and plots three levels:
POC (Point of Control) – the most-traded price of that swing (the magnet / fair value).
VAH (Value Area High) and VAL (Value Area Low) – the upper and lower bounds of the area containing the chosen percentage of volume (70% by default).
It also draws two optional zones per profile: a strong box for the value area, and a faint box for the full swing range (high to low), so you can see both the 70% core and the extremes that were rejected on low volume.
Triangles mark each detected swing high and low.
How it works

Each bar's volume is distributed across the price levels it spans (low to high), accumulated into price bins for the current swing leg. The Point of Control is the bin with the most volume; the value area is then expanded outward from the POC, adding the higher-volume neighbouring level at each step until the target volume percentage is reached. When price closes beyond the swing extreme by more than the chosen swing size, a reversal is confirmed: the leg's profile is locked in place from pivot to pivot, and a new profile is anchored from the actual extreme.

Settings

Min. swing size (points) – the most important input. The smallest move (in price) that counts as a new swing. Larger values produce fewer, larger profiles; set to 0 to use the ATR-based alternative instead.
Swing size (× ATR) – used only when the point value is 0.
Bin size – the price resolution of the profile (smaller = finer).
Value Area % – the share of volume that defines the value area (default 70%).
Number of profiles shown – how many completed profiles remain on the chart.
Display toggles for the value-area box, full-range box, level labels and swing markers.
How to use it

Treat the POC of each completed swing as a fair-value reference; price often returns to and reacts at prior POCs.
Use VAH/VAL as the edges of accepted value: acceptance above a prior VAH or below a prior VAL signals a shift, while rejection at these levels can mark a turn.
Compare the current swing's value area against earlier ones to judge whether the market is building value higher, lower, or overlapping.
Notes and limitations

Pine cannot access true tick-by-tick traded volume at price, so each bar's volume is approximated across its high-low range. The profile shape is therefore an estimate, not exchange-level data, and the Point of Control may differ slightly from a native volume-profile tool. Use a lower chart timeframe for a finer approximation. On symbols without volume, time is used as a fallback so the tool still works.
Swing detection is rule-based; the Min. swing size input should be tuned to the instrument and timeframe so the marked swings match the structure you trade.
This script is provided for chart analysis and educational purposes only. It is not financial advice and does not predict future prices. Always do your own research and manage your own risk.

## Source Code

````pine
//@version=6
// =====================================================================================
//  SWIFTEDGE AUCTION VOLUME PROFILE — POC / VAH / VAL + full range
//  Swing-anchored volume profile: a fresh profile per market swing (pivot to pivot).
//  Method: a market alternates between balance (acceptance) and imbalance (a directional
//  swing). A new profile is anchored at every significant swing and runs to the next pivot.
//   - ATR/point zigzag finds significant swings (reversal >= swing size)
//   - at each confirmed swing: FREEZE the previous leg's profile, START a new one
//   - the profile is back-filled from the actual pivot (extreme), not the confirmation bar
//   - faint box = full range (swing-high -> swing-low) · strong box = value area (70%)
//  Green = VAH · Purple = POC · Red = VAL · triangles = swing pivots
// =====================================================================================
indicator("Swiftedge Auction Volume Profile", overlay=true, max_lines_count=500, max_boxes_count=200, max_labels_count=100)

// ============ INPUTS ============
g1 = "Profile"
binSize    = input.float(2.0, "Bin size (price per level)", minval=0.01, group=g1, tooltip="Finer = smaller value. DAX 5m ~2-5, BTC ~20, EURUSD ~0.0005")
vaPct      = input.float(70.0, "Value Area %", minval=50, maxval=95, group=g1) / 100.0
maxBinsBar = input.int(150,   "Max bins per bar (perf cap)", minval=10, group=g1)

g2 = "Swing Anchor (new profile at each significant swing)"
swingPts   = input.float(100.0,"Min. swing size (PRICE POINTS)", minval=0, group=g2, tooltip="THE KEY INPUT. The smallest swing you want marked, in price points. Larger = only big swings = fewer, larger profiles. Set to 0 to use ATR instead. DAX big swings ~60-120")
atrLen     = input.int(14,    "ATR length (only if points = 0)", minval=2, group=g2)
swingMult  = input.float(5.0, "Swing size (x ATR, if points = 0)", minval=0.5, group=g2, tooltip="Used only when 'Min. swing size (points)' = 0")
minLegBars = input.int(8,     "Min. bars per swing leg", minval=2, group=g2, tooltip="Prevents rapid flip-flop swings")

g3 = "Display"
colVAH   = input.color(color.new(color.green,  0), "VAH (Value Area High)", group=g3)
colPOC   = input.color(color.new(color.purple, 0), "POC (Point of Control)", group=g3)
colVAL   = input.color(color.new(color.red,    0), "VAL (Value Area Low)", group=g3)
showBox   = input.bool(true, "Value area box (strong)", group=g3)
showRange = input.bool(true, "Full range box: high to low (faint)", group=g3)
showSeg   = input.int(6, "Number of completed profiles shown", minval=1, maxval=6, group=g3)
extR      = input.int(8, "Extend lines (bars to the right)", minval=0, group=g3)
showLbl   = input.bool(true, "POC / VAH / VAL labels", group=g3)
showPiv   = input.bool(true, "Show swing markers", group=g3)

// ============ STATE ============
var map<int, float> bins = map.new<int, float>()
var int   dir      = 1          // 1 = up leg (seeking high) · -1 = down leg (seeking low)
var float ext      = high       // running extreme of the current leg
var int   extBar   = bar_index  // bar of the extreme (= upcoming pivot)
var int   legStart = bar_index  // bar where the current leg's profile starts (previous pivot)
var float legHi    = high       // leg's actual high (full range)
var float legLo    = low        // leg's actual low
var line  aVAH = na
var line  aPOC = na
var line  aVAL = na
var box   aBox   = na
var box   aRange = na
var label aLbl = na
var array<line> doneL = array.new<line>()
var array<box>  doneB = array.new<box>()
var array<box>  doneR = array.new<box>()

// ============ HELPERS ============
// add the bar at offset 'off' (0 = current) to the profile. Only map.put (by-reference -> persists)
addBarAt(off) =>
    float v   = na(volume[off]) or volume[off] <= 0 ? 1.0 : volume[off]
    int   loB = int(math.floor(low[off]  / binSize))
    int   hiB = int(math.floor(high[off] / binSize))
    int   nb  = math.min(maxBinsBar, math.max(1, hiB - loB + 1))
    float per = v / nb
    int   b   = loB
    int   c   = 0
    while b <= hiB and c < maxBinsBar
        float cur = map.contains(bins, b) ? map.get(bins, b) : 0.0
        map.put(bins, b, cur + per)
        b   := b + 1
        c   := c + 1

// returns [poc, vah, val] in price; total computed from the map (no global mutation)
calcVA() =>
    float poc = na
    float vah = na
    float val = na
    if map.size(bins) > 0
        array<int> ks    = map.keys(bins)
        int        pocB  = array.get(ks, 0)
        float      pocV  = map.get(bins, pocB)
        float      total = 0.0
        for i = 0 to array.size(ks) - 1
            int   k  = array.get(ks, i)
            float vv = map.get(bins, k)
            total := total + vv
            if vv > pocV
                pocV := vv
                pocB := k
        int   loB = pocB
        int   hiB = pocB
        float inc = pocV
        float tgt = vaPct * total
        int   gd  = 0
        while inc < tgt and gd < 4000
            float vLo = map.contains(bins, loB - 1) ? map.get(bins, loB - 1) : 0.0
            float vHi = map.contains(bins, hiB + 1) ? map.get(bins, hiB + 1) : 0.0
            if vHi >= vLo
                hiB := hiB + 1
                inc := inc + vHi
            else
                loB := loB - 1
                inc := inc + vLo
            gd := gd + 1
        poc := (pocB + 0.5) * binSize
        vah := (hiB + 1) * binSize
        val := loB * binSize
    [poc, vah, val]

// ============ SWING DETECTION (zigzag) + ACCUMULATION ============
atr    = ta.atr(atrLen)
revAmt = swingPts > 0 ? swingPts : (na(atr) ? na : swingMult * atr)
[poc, vah, val] = calcVA()          // current leg's VA (before this bar) -> used when freezing
bool swingHi = false
bool swingLo = false

if barstate.isconfirmed
    // update the running extreme
    if dir == 1 and high > ext
        ext    := high
        extBar := bar_index
    if dir == -1 and low < ext
        ext    := low
        extBar := bar_index
    // confirmed swing? (reversal >= revAmt, and the leg is long enough)
    bool canRev = (bar_index - legStart) >= minLegBars and not na(revAmt)
    bool rev = false
    if canRev and dir == 1 and close <= ext - revAmt
        rev := true
    if canRev and dir == -1 and close >= ext + revAmt
        rev := true
    if rev
        bool wasUp = dir == 1
        // FREEZE the current leg: lines + boxes locked to pivot -> pivot (legStart -> extBar)
        if not na(aVAH)
            line.set_xy1(aVAH, legStart, vah)
            line.set_xy2(aVAH, extBar, vah)
            line.set_xy1(aPOC, legStart, poc)
            line.set_xy2(aPOC, extBar, poc)
            line.set_xy1(aVAL, legStart, val)
            line.set_xy2(aVAL, extBar, val)
            array.push(doneL, aVAH)
            array.push(doneL, aPOC)
            array.push(doneL, aVAL)
            aVAH := na
            aPOC := na
            aVAL := na
        if showRange and not na(aRange)
            box.set_right(aRange, extBar)
            array.push(doneR, aRange)
            aRange := na
        if showBox and not na(aBox)
            box.set_right(aBox, extBar)
            array.push(doneB, aBox)
            aBox := na
        if not na(aLbl)
            label.delete(aLbl)
            aLbl := na
        while array.size(doneL) > showSeg * 3
            line.delete(array.shift(doneL))
        while array.size(doneB) > showSeg
            box.delete(array.shift(doneB))
        while array.size(doneR) > showSeg
            box.delete(array.shift(doneR))
        // start the new leg FROM the pivot (extBar) — back-fill bars from pivot to now
        dir      := wasUp ? -1 : 1
        legStart := extBar
        map.clear(bins)
        int   span = bar_index - extBar
        float nHi = na
        float nLo = na
        for off = 0 to span
            addBarAt(off)
            nHi := na(nHi) ? high[off] : math.max(nHi, high[off])
            nLo := na(nLo) ? low[off]  : math.min(nLo, low[off])
        legHi   := nHi
        legLo   := nLo
        ext     := dir == 1 ? high : low
        extBar  := bar_index
        swingHi := wasUp
        swingLo := not wasUp
    else
        addBarAt(0)
        legHi := math.max(legHi, high)
        legLo := math.min(legLo, low)

// ============ DRAW ACTIVE LEG ============
[poc2, vah2, val2] = calcVA()
if not na(vah2)
    int x1 = legStart
    int x2 = bar_index + extR
    if na(aVAH)
        aVAH := line.new(x1, vah2, x2, vah2, color=colVAH, width=2)
        aPOC := line.new(x1, poc2, x2, poc2, color=colPOC, width=2)
        aVAL := line.new(x1, val2, x2, val2, color=colVAL, width=2)
    else
        line.set_xy1(aVAH, x1, vah2)
        line.set_xy2(aVAH, x2, vah2)
        line.set_xy1(aPOC, x1, poc2)
        line.set_xy2(aPOC, x2, poc2)
        line.set_xy1(aVAL, x1, val2)
        line.set_xy2(aVAL, x2, val2)
    // full range (faint box BEHIND the value area) — shows the whole leg high -> low
    if showRange and not na(legHi)
        if na(aRange)
            aRange := box.new(x1, legHi, x2, legLo, border_color=color.new(color.gray, 70), bgcolor=color.new(color.gray, 90))
        else
            box.set_lefttop(aRange, x1, legHi)
            box.set_rightbottom(aRange, x2, legLo)
    // value area (strong box WITHOUT border — so the VAH/VAL lines are not hidden)
    if showBox
        if na(aBox)
            aBox := box.new(x1, vah2, x2, val2, border_width=0, bgcolor=color.new(colPOC, 88))
        else
            box.set_lefttop(aBox, x1, vah2)
            box.set_rightbottom(aBox, x2, val2)
    if showLbl
        if na(aLbl)
            aLbl := label.new(x2, poc2, "", style=label.style_label_left, textcolor=colPOC, color=color.new(color.black, 100), size=size.small)
        label.set_xy(aLbl, x2, poc2)
        label.set_text(aLbl, "POC " + str.tostring(poc2, format.mintick) + "  VAH " + str.tostring(vah2, format.mintick) + "  VAL " + str.tostring(val2, format.mintick))

// swing markers
plotshape(showPiv and swingHi, title="Swing High", style=shape.triangledown, location=location.abovebar, color=color.new(color.red, 0), size=size.tiny)
plotshape(showPiv and swingLo, title="Swing Low", style=shape.triangleup, location=location.belowbar, color=color.new(color.green, 0), size=size.tiny)
````
