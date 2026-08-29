<!-- tradingview-pine-id: PUB;9e8c5a81a4d44ba19709a05575db0143 -->
<!-- tradingviewscripts-format: 1 -->
# Ronaldo Bicycle Kick - Orbit Break Reversal (Viprasol)

Source: https://www.tradingview.com/script/SvAqqY50-Ronaldo-Bicycle-Kick-Orbit-Break-Reversal-Viprasol/

## Description

Ronaldo Bicycle Kick — Orbit Break Reversal (Viprasol)

WHAT IT DOES (the idea)
Most reversal tools watch a single line. This one watches a region. It treats recent price structure as a set of confirmed swing points that "orbit" a structural centre of mass, and it trades the moment price escapes that orbit to the upside. Like a ball coiling around a centre and then leaving orbit — that break is the signal. The name is a sporting homage to a spectacular finish; the tool itself is pure geometry.

HOW IT DETECTS
1. Swings: a lightweight zigzag keeps the last several confirmed pivots. A pivot is only accepted after the required number of bars close to its right, so swings do not move once printed.
2. Orbit geometry: from the last K swings (default 6) it computes the geometric centroid — the mean bar position and mean price. It then measures the average (root-mean-square) distance those swings sit from the centroid price. That distance, scaled by "Orbit radius," becomes the orbit ring. A minimum radius floor (in ATR) filters out flat, meaningless rings.
3. Escape: the setup arms only when the orbit is valid. The signal fires on the first bar that CLOSES above the top of the orbit ring (centroid price + radius) having closed at or below it on the prior bar.

ENTRY / STOP / TARGET
- Entry: the close of the escape bar (long only).
- Stop: the lowest swing price inside the orbit, minus an ATR buffer.
- Target: Entry + R multiple x risk (default 2R), where risk = Entry - Stop.
Each trade draws an entry line plus filled TP and SL zones that extend forward bar by bar until price touches one of them, then freeze.

NON-REPAINTING
Signals are built from confirmed pivots and only evaluated on a confirmed (closed) bar. Nothing is placed on the developing bar, so a printed signal does not disappear or shift on later ticks. The dotted "live orbit" preview is a forward-looking sketch of the current geometry and is not a signal.

KEY FEATURES
- A real orbit ellipse is drawn around the centroid so you can see the ring being broken.
- Extend-until-hit TP/SL zones with a one-trade-at-a-time option.
- Optional hide-new-setup-while-in-trade to reduce clutter.
- Adjustable pivot width, swing count, orbit radius, ATR floor, R multiple, stop buffer, and a minimum-bars-between-signals gap.

INPUTS OVERVIEW
Swing pivot left/right bars; swings used for the orbit; minimum swings for validity; orbit radius multiplier; minimum orbit radius in ATR; ATR length; TP R multiple; SL ATR buffer; signal gap; one-trade toggle; visual colours and label offset.

HOW TO USE
1. Add to any liquid symbol and timeframe; it works on all.
2. Watch for the dotted orbit ring to form around recent structure.
3. Take note when a bar closes above the ring and the GOAL label prints.
4. Use the drawn entry, TP, and SL zones as a visual trade map; adjust the R multiple and stop buffer to your own plan.
5. Raise the pivot width or ATR floor on noisy, low-timeframe charts to demand cleaner structure.

LIMITATIONS (honest)
- This is a pattern and education tool, not a signal service or an autotrading system. It highlights a geometric condition; it does not predict outcomes.
- Long-only by design. It will not flag downside setups.
- In strong one-way trends the orbit ring can be escaped repeatedly; in choppy ranges valid orbits may be sparse. Context and discretion still matter.
- Requiring confirmed pivots means the orbit is defined slightly after a swing forms, which is the cost of non-repainting behaviour.
- Past behaviour of any pattern does not guarantee future results.

CREDITS
Built on public, well-known concepts: Average True Range (J. Welles Wilder) for volatility scaling, and standard pivot/zigzag swing detection. The orbit-centroid geometry and the escape logic are original Viprasol work. The "Bicycle Kick" name is an affectionate sporting homage and does not imply any endorsement or affiliation.

This script is an educational tool and is not financial advice. Trade your own plan and manage risk.

Original Viprasol work; no third-party Pine code reused.

---

## Source Code

````pine
//@version=6
// Ronaldo Bicycle Kick — "Orbit Break" ⚽  ·  Viprasol   ·  ORIGINAL geometry (long)
// ─────────────────────────────────────────────────────────────────────────────
// The idea nobody ships: price ORBITS a structural centre. We take the last N confirmed
// swing points (a zigzag), find their geometric centroid (the centre of mass), and the
// average radius those swings sit from it. While price stays inside that radius it's "in
// orbit" — coiling around the centre. The trade is the ESCAPE: a close that breaks outside
// the orbit ring while the centre is drifting up = the ball leaves orbit → LONG.
// Pure geometry. Non-repainting (swings are confirmed pivots; entry fires on bar close).
// A real ORBIT ELLIPSE is drawn around the centroid so you can see the ring being broken.
// Entry/TP/SL lines extend forward until one is hit, then freeze (like Mother & Son).
indicator("Ronaldo Bicycle Kick - Orbit Break Reversal (Viprasol)", "Ronaldo", overlay=true, max_labels_count=500, max_lines_count=500, max_polylines_count=100, max_boxes_count=200)

// ── The orbit (swing geometry) ───────────────────────────
gA = "The orbit (swing geometry)"
pL        = input.int(3,   "Swing pivot — left bars", minval=1, group=gA)
pR        = input.int(3,   "Swing pivot — right bars", minval=1, group=gA)
kSwings   = input.int(6,   "Swings used for the orbit", minval=3, maxval=10, group=gA)
minSwings = input.int(5,   "Min swings before a valid orbit", minval=3, group=gA)
orbitMult = input.float(1.0,"Orbit radius (× swing spread)", minval=0.2, step=0.1, group=gA)
minRadATR = input.float(0.8,"Min orbit radius (× ATR)", minval=0.1, step=0.1, group=gA)
atrLen    = input.int(14,  "ATR length", minval=1, group=gA)

// ── The escape (entry & exits) ───────────────────────────
gE = "The escape (entry & exits)"
rr         = input.float(2.0, "TP = R multiple (× risk)", minval=0.5, step=0.5, group=gE)
slBuf      = input.float(0.3, "SL buffer (× ATR)", minval=0.0, step=0.1, group=gE)
sigGap     = input.int(15,   "Min bars between signals", minval=0, group=gE)
oneAtATime = input.bool(true, "One trade at a time", group=gE)
hideSetupInTrade = input.bool(true, "Hide new setup while a trade is active", group=gE)

// ── Visuals ──────────────────────────────────────────────
gV = "Visuals"
cOrbit  = input.color(color.new(#26c6da,0), "Orbit ring", group=gV)
cCentre = input.color(color.new(#ffa726,0), "Centroid", group=gV)
cEntry  = input.color(color.blue,   "Entry line", group=gV)
cTP     = input.color(color.green,  "TP line", group=gV)
cSL     = input.color(color.red,    "SL line", group=gV)
labelOff= input.float(1.0, "Label offset (× ATR)", minval=0.0, step=0.1, group=gV)
zoneTrans= input.int(85, "TP/SL zone fill transparency (0-100)", minval=0, maxval=100, group=gV)
showLive= input.bool(true, "Show live orbit (dotted)", group=gV)

atr = ta.atr(atrLen)
var int lastSig = -100000

// ── Zigzag: alternating confirmed swing points ───────────
var array<float> zP = array.new_float()
var array<int>   zB = array.new_int()
var array<int>   zT = array.new_int()   // 1 = swing high, -1 = swing low

ph = ta.pivothigh(pL, pR)
pl = ta.pivotlow(pL, pR)
pvPrice = not na(ph) ? ph : pl
pvType  = not na(ph) ? 1 : (not na(pl) ? -1 : 0)
if pvType != 0
    nn = array.size(zT)
    if nn > 0 and array.get(zT, nn - 1) == pvType
        li = nn - 1
        lp = array.get(zP, li)
        if (pvType == 1 and pvPrice > lp) or (pvType == -1 and pvPrice < lp)
            array.set(zP, li, pvPrice)
            array.set(zB, li, bar_index - pR)
    else
        array.push(zP, pvPrice)
        array.push(zB, bar_index - pR)
        array.push(zT, pvType)
        if array.size(zP) > 12
            array.shift(zP)
            array.shift(zB)
            array.shift(zT)

// ── Orbit geometry from the last K swings ────────────────
float cxB = na
float cyP = na
float ryP = na
float rxB = na
float minP = na
bool  orbitOK = false

n = array.size(zP)
useN = n < kSwings ? n : kSwings
if useN >= minSwings
    sumB = 0.0
    sumP = 0.0
    for i = n - useN to n - 1
        sumB += array.get(zB, i)
        sumP += array.get(zP, i)
    cxB := sumB / useN
    cyP := sumP / useN
    sumsq = 0.0
    lo = 1e12
    minB = 1e12
    maxB = -1e12
    for i = n - useN to n - 1
        p = array.get(zP, i)
        b = array.get(zB, i)
        d = p - cyP
        sumsq += d * d
        lo := math.min(lo, p)
        minB := math.min(minB, b)
        maxB := math.max(maxB, b)
    ryP := math.sqrt(sumsq / useN) * orbitMult
    rxB := math.max(3.0, (maxB - minB) / 2.0)
    minP := lo
    orbitOK := ryP >= minRadATR * atr

// helper: build an orbit ellipse (bar,price) around the centroid
buildOrbit(cB, cP, rB, rP) =>
    pts = array.new<chart.point>()
    steps = 24
    for i = 0 to steps
        ang = 2.0 * math.pi * i / steps
        bxi = int(math.round(cB + rB * math.cos(ang)))
        pyv = cP + rP * math.sin(ang)
        array.push(pts, chart.point.from_index(bxi, pyv))
    pts

// ── Active trades (extend-until-hit) ─────────────────────
var array<line>  tEntry = array.new<line>()
var array<box>   tTPb   = array.new<box>()
var array<box>   tSLb   = array.new<box>()
var array<float> tTPl   = array.new_float()
var array<float> tSLl   = array.new_float()

openTrades = array.size(tTPl)
blocked    = oneAtATime and openTrades > 0

// live orbit preview (dotted)
var polyline liveOrbit = na
if showLive
    if not na(liveOrbit)
        polyline.delete(liveOrbit)
        liveOrbit := na
    if orbitOK and not blocked and not (hideSetupInTrade and openTrades > 0)
        liveOrbit := polyline.new(buildOrbit(cxB, cyP, rxB, ryP), curved = true, line_color = color.new(cOrbit, 60), line_width = 1, line_style = line.style_dotted)

// ── Escape: first close outside the orbit ring, to the upside ──
orbitTop = orbitOK ? cyP + ryP : na
escape   = orbitOK and close > orbitTop and close[1] <= orbitTop
sig      = escape and not blocked and (bar_index - lastSig) > sigGap and barstate.isconfirmed

if sig
    lastSig := bar_index
    entry   = close
    slLvl   = minP - atr * slBuf
    tpLvl   = entry + rr * (entry - slLvl)
    // solid orbit ring + centroid
    polyline.new(buildOrbit(cxB, cyP, rxB, ryP), curved = true, line_color = color.new(cOrbit, 0), line_width = 2)
    label.new(int(math.round(cxB)), cyP, "", xloc=xloc.bar_index, style=label.style_cross, color=color.new(cCentre, 0), size=size.small)
    label.new(bar_index, low - atr * labelOff, "GOAL ⚽", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=color.new(color.green, 0), textcolor=color.white, size=size.normal)
    array.push(tEntry, line.new(bar_index, entry, bar_index, entry, xloc=xloc.bar_index, color=color.new(cEntry, 0), width=1))
    array.push(tTPb,   box.new(bar_index, math.max(entry, tpLvl), bar_index, math.min(entry, tpLvl), xloc=xloc.bar_index, border_color=color.new(cTP, 0), border_width=1, bgcolor=color.new(cTP, zoneTrans)))
    array.push(tSLb,   box.new(bar_index, math.max(entry, slLvl), bar_index, math.min(entry, slLvl), xloc=xloc.bar_index, border_color=color.new(cSL, 0), border_width=1, bgcolor=color.new(cSL, zoneTrans)))
    array.push(tTPl,   tpLvl)
    array.push(tSLl,   slLvl)

// ── Extend each long trade until TP (above) or SL (below) is hit ──
if barstate.isconfirmed and array.size(tTPl) > 0
    idx = array.size(tTPl) - 1
    while idx >= 0
        le = array.get(tEntry, idx)
        bt = array.get(tTPb, idx)
        bs = array.get(tSLb, idx)
        tp = array.get(tTPl, idx)
        sl = array.get(tSLl, idx)
        line.set_x2(le, bar_index)
        box.set_right(bt, bar_index)
        box.set_right(bs, bar_index)
        hitTP = high >= tp
        hitSL = low  <= sl
        if hitTP or hitSL
            box.set_border_width(hitTP ? bt : bs, 2)
            array.remove(tEntry, idx)
            array.remove(tTPb, idx)
            array.remove(tSLb, idx)
            array.remove(tTPl, idx)
            array.remove(tSLl, idx)
        idx := idx - 1

alertcondition(sig, "Ronaldo Orbit Break", "Ronaldo Orbit Break — escape (buy) on {{ticker}}")

var table tb = table.new(position.top_right, 1, 2, border_width=1)
if barstate.islast
    table.cell(tb, 0, 0, "Ronaldo · Orbit Break ⚽", bgcolor=color.new(color.green, 0), text_color=color.white, text_size=size.small)
    table.cell(tb, 0, 1, "Open trades: " + str.tostring(array.size(tTPl)), bgcolor=color.new(color.black, 20), text_color=color.white, text_size=size.small)
````
