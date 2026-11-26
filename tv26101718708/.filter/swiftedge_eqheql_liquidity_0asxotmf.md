# SwiftEdge EQH/EQL Liquidity

- url: https://www.tradingview.com/script/0AsXotmF-SwiftEdge-EQH-EQL-Liquidity/
- type: indicator
- pine_id: PUB;3f5e62e8ba8242878f428ba2273b723b
- version: 1.0

## Description

SwiftEdge EQH/EQL Liquidity marks equal highs and equal lows: two or more swing highs (or swing lows) at nearly the same price. Many traders place stops and breakout orders just beyond such levels, so they often act as liquidity that price is drawn to. The script keeps only the levels that are still intact, removes them when they are swept or broken, and measures on your own chart how often a sweep of these levels was actually followed by a reversal.

WHAT IT SHOWS

• Equal highs (EQH) and equal lows (EQL)
Swing highs and lows are found with a pivot of "Swing length" bars on each side. Two swings count as equal when they are within a tolerance, set as a multiple of ATR(14) (0.1 by default) or as a percentage of price, so the same settings work on any symbol and timeframe. Every further swing at the same level adds a touch to the zone. The minimum and maximum number of bars between touches can be set.

• Zones
Each zone spans its touches, from the first touch to a few bars past the current bar, with a level line at the extreme touch (the price that has to be taken out), a dotted line through the touches and a label such as "EQH ×3". When there are more zones than the maximum per side, the one farthest from price is removed. Zones with more touches are shaded stronger, older zones fade slightly, and the nearest EQH above price and the nearest EQL below price are highlighted and shown on the price scale. Hover a label for the level, its distance in ATR, the age of the first and last touch and the relative volume around the touches.

• Sweeps and breaks
A sweep is a bar whose wick trades beyond the level but closes back inside. A break is a bar that closes beyond the level. Either way the zone is removed, so only intact liquidity stays on the chart. Sweeps leave a small × at the wick. Break marks and a dotted trail of the taken level can be switched on.

• Statistics panel
  – Live zones and the distance to the nearest EQH and EQL in ATR.
  – Sweep → reversal: the share of sweeps that were followed by a move of N × ATR in the reversal direction within a set number of bars, before any bar closed beyond the sweep wick. Shown for all sweeps and split by 2, 3 and 4+ touches.
  – Baseline: the same measurement started from every bar. A sweep result is shown green when it is at least 5 percentage points better than the baseline and red when it is 5 points worse (with at least 20 sweeps). This shows whether sweeps of equal highs/lows behaved differently from any other bar on your market, instead of assuming it.
  – Break → continuation: the share of breaks that continued N × ATR before closing back across the level.

HOW IT WORKS

1. A swing is confirmed "Swing length" bars after its high or low. A single swing waits for an equal partner. It can no longer pair once price has traded beyond it by more than the tolerance, or after the maximum number of bars.
2. When a new swing is equal to a waiting swing (or to an existing zone), a zone is created (or gets another touch).
3. On every closed bar, live zones are checked: a wick beyond the level with a close back inside is a sweep, a close beyond is a break.
4. The statistics follow each sweep, break and baseline bar until the target is reached, the invalidation close happens, or the time window ends. If the target and the invalidation happen on the same bar, it counts as a miss.

HOW TO USE IT

• Treat live EQH/EQL zones as areas where liquidity is likely resting and price may be drawn to.
• A sweep (wick through, close back) is the classic stop run. Use the panel to see whether sweeps on your symbol and timeframe reversed more often than the baseline, and whether more touches made a difference.
• A break shows that the level did not hold. The continuation row shows how often that led to follow-through.
• Adjust the tolerance to the market: a smaller tolerance gives fewer, cleaner levels; a larger one groups more swings.

SETTINGS

Detection (swing length, tolerance in ATR or percent, bars between touches, maximum zones per side, maximum zone age), zones (EQH/EQL on or off, zone box, minimum height, transparency, shading by touches, age fade, level line and style, line through the touches, label and label text, right extension, nearest highlight, price-scale marks), sweep and break marks, swept-level trail, number of marks kept, colours, label size, and the statistics (target in ATR, time window, panel position and text size). Alerts are available for new EQH/EQL, sweeps and breaks.

LIMITATIONS

• TradingView can only draw objects up to about 10,000 bars back. A zone whose first touch is older than that (for example on 1-minute charts) is drawn from the oldest drawable bar.
• Swings are only known "Swing length" bars after the high or low, so zones appear with that delay and are then drawn back to the first touch. Sweeps and breaks are evaluated on bar close and do not change afterwards.
• Equal highs and lows are a price pattern. The script does not see actual stop orders.
• Statistics describe the history loaded on your chart and depend on the settings, the symbol, the timeframe and the data feed. They are a measurement, not a forecast, and not a trading system.

This script is for analysis and education. It does not provide trading advice, and past behaviour shown on the chart does not imply future results.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════
//  SwiftEdge EQH/EQL Liquidity
//  Equal highs and equal lows: two or more swing highs (or lows) at nearly
//  the same price. Stops and breakout orders tend to cluster just beyond
//  them, which makes them obvious liquidity targets.
//
//   • Detection: swing highs/lows within a tolerance (ATR multiple or
//     percent) are grouped into one zone. Every further swing at the same
//     level adds a touch.
//   • Only live zones stay on the chart. A wick beyond the level that closes
//     back inside is a sweep, a close beyond it is a break. Either removes
//     the zone; sweeps (and optionally breaks) leave a small mark.
//   • Statistics: how often a sweep was followed by a reversal of N × ATR
//     within a set number of bars, split by the number of touches, against
//     a baseline of any bar, plus how often a break continued.
//
//  Swings are confirmed "Swing length" bars after the high or low, so zones
//  appear with that delay and are drawn back from the first touch. Sweeps
//  and breaks are decided on bar close; nothing changes after a bar closes.
//  A research tool: statistics describe the loaded history only.
// ═══════════════════════════════════════════════════════════════════════════
indicator("SwiftEdge EQH/EQL Liquidity", "SE EQH/EQL", overlay = true,
     max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ═══ Inputs ════════════════════════════════════════════════════════════════
grpD = "1 · Detection"
pvLen   = input.int(5, "Swing length", minval = 1, maxval = 50, group = grpD,
     tooltip = "A swing high needs this many lower highs on each side (a swing low the same with higher lows). Swings are confirmed this many bars after the high or low.")
tolMode = input.string("ATR ×", "Equal within", options = ["ATR ×", "Percent"], inline = "tol", group = grpD)
tolV    = input.float(0.10, "", minval = 0.0, step = 0.01, inline = "tol", group = grpD,
     tooltip = "Two swing highs (or lows) count as equal when they are at most this far apart: a multiple of ATR(14) or a percentage of price.")
minGap  = input.int(5, "Bars between touches: min", minval = 1, inline = "gap", group = grpD)
maxGap  = input.int(150, "max", minval = 2, inline = "gap", group = grpD)
maxZ    = input.int(8, "Max zones per side", minval = 1, maxval = 40, group = grpD,
     tooltip = "When a new zone would exceed this number, the zone on that side farthest from price is removed.")
maxAge  = input.int(0, "Remove zones older than (bars, 0 = keep)", minval = 0, group = grpD)

grpV = "2 · Zones"
showH   = input.bool(true, "Equal highs (EQH)", inline = "s", group = grpV)
showL   = input.bool(true, "Equal lows (EQL)", inline = "s", group = grpV)
showBox = input.bool(true, "Zone", inline = "z", group = grpV)
zoneMin = input.float(0.15, "min height (ATR)", minval = 0.0, step = 0.05, inline = "z", group = grpV,
     tooltip = "The zone spans the touches. When they are almost identical, the zone is drawn at least this tall so it stays visible.")
fillTr  = input.int(84, "Zone transparency", minval = 0, maxval = 100, group = grpV)
byTouch = input.bool(true, "Stronger shading with more touches", group = grpV)
ageFade = input.int(300, "Fade with age over (bars, 0 = off)", minval = 0, group = grpV)
showLvl = input.bool(true, "Level line", inline = "l", group = grpV)
lvlSty  = input.string("Solid", "", options = ["Solid", "Dashed", "Dotted"], inline = "l", group = grpV)
showCon = input.bool(true, "Line through the touches", group = grpV)
showLbl = input.bool(true, "Label", inline = "lb", group = grpV)
lblMode = input.string("Name + touches", "", options = ["Name + touches", "Name", "Name + price"], inline = "lb", group = grpV)
extBars = input.int(15, "Extend right (bars)", minval = 0, maxval = 200, group = grpV)
hiNear  = input.bool(true, "Highlight nearest EQH above / EQL below", group = grpV)
showSc  = input.bool(true, "Nearest levels on the price scale", group = grpV)

grpM = "3 · Sweeps & breaks"
showSw  = input.bool(true, "Sweep marks", inline = "m", group = grpM)
showBr  = input.bool(false, "Break marks", inline = "m", group = grpM)
showTrl = input.bool(false, "Keep swept or broken level as a dotted line", group = grpM)
keepMk  = input.int(40, "Marks kept on chart", minval = 1, maxval = 200, group = grpM)

grpC = "4 · Colours & text"
cH      = input.color(#f23645, "EQH", inline = "c", group = grpC)
cL      = input.color(#089981, "EQL", inline = "c", group = grpC)
txtOwn  = input.bool(true, "Label text in zone colour", inline = "t", group = grpC)
cTx     = input.color(#787b86, "else", inline = "t", group = grpC)
lblSz   = input.string("Small", "Label size", options = ["Tiny", "Small", "Normal"], group = grpC)

grpS = "5 · Statistics"
showPan = input.bool(true, "Panel", inline = "p", group = grpS)
panPos  = input.string("Top right", "", options = ["Top right", "Top left", "Bottom right", "Bottom left", "Middle right"], inline = "p", group = grpS)
panSz   = input.string("Tiny", "Text size", options = ["Tiny", "Small", "Normal"], group = grpS)
revAtr  = input.float(1.0, "Target move (ATR)", minval = 0.1, step = 0.1, inline = "rv", group = grpS,
     tooltip = "A sweep counts as a hit when price moves this many ATR in the reversal direction within the given bars, before any bar closes beyond the sweep wick. A break counts as a hit when price continues this far before closing back across the level.")
revBars = input.int(20, "within bars", minval = 1, maxval = 300, inline = "rv", group = grpS)

// ═══ Data ══════════════════════════════════════════════════════════════════
atr  = ta.atr(14)
ph   = ta.pivothigh(high, pvLen, pvLen)
pl   = ta.pivotlow(low, pvLen, pvLen)
win  = 2 * pvLen + 1
avgV = ta.sma(nz(volume), 100)
rvNow = avgV > 0 ? math.sum(nz(volume), win) / (avgV * win) : float(na)
tol  = tolMode == "ATR ×" ? tolV * atr : close * tolV / 100

// drawings cannot reach more than ~10,000 bars back: clamp old x-coordinates
xc(int b) =>
    math.max(b, bar_index - 9000)

vis(int d) =>
    d == 1 ? showH : showL

colOf(int d) =>
    d == 1 ? cH : cL

lsOf(string s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

sizeOf(string s) =>
    s == "Small" ? size.small : s == "Normal" ? size.normal : size.tiny

posOf(string s) =>
    s == "Top left" ? position.top_left : s == "Bottom right" ? position.bottom_right :
     s == "Bottom left" ? position.bottom_left : s == "Middle right" ? position.middle_right : position.top_right

// ═══ Zones ═════════════════════════════════════════════════════════════════
type Zone
    int   dir          // 1 = equal highs, -1 = equal lows
    float lvl          // the extreme touch: the level that has to be taken
    float far          // the opposite edge of the touches
    int   b1           // first touch
    int   bL           // last touch
    float p1
    float pL
    int   touches
    float rv           // average relative volume around the touches
    box   bx
    line  ln
    line  cn
    label lb

method kill(Zone z) =>
    box.delete(z.bx)
    line.delete(z.ln)
    line.delete(z.cn)
    label.delete(z.lb)
    true

newZone(int d, float lvl, float far, int b1, int bL, float p1, float pL, int t, float rv) =>
    z = Zone.new(d, lvl, far, b1, bL, p1, pL, t, rv)
    if vis(d)
        c = colOf(d)
        if showBox
            z.bx := box.new(xc(b1), lvl, bar_index, far, border_color = color(na), bgcolor = color.new(c, fillTr))
        if showLvl
            z.ln := line.new(xc(b1), lvl, bar_index, lvl, color = color.new(c, 35), style = lsOf(lvlSty))
        if showCon
            z.cn := line.new(xc(b1), p1, xc(bL), pL, color = color.new(c, 45), style = line.style_dotted)
        if showLbl
            z.lb := label.new(bar_index, lvl, "", style = label.style_label_left, color = color(na), size = sizeOf(lblSz))
    z

method paint(Zone z, bool near) =>
    c     = colOf(z.dir)
    name  = z.dir == 1 ? "EQH" : "EQL"
    age   = bar_index - z.bL
    fade  = ageFade > 0 ? math.min(age / float(ageFade), 1.0) * 10 : 0.0
    tB    = math.max(0.0, math.min(100.0, fillTr - (byTouch ? (math.min(z.touches, 5) - 2) * 6 : 0) + fade - (near ? 6 : 0)))
    right = bar_index + extBars
    h     = math.max(math.abs(z.lvl - z.far), zoneMin * atr)
    top   = z.dir == 1 ? z.lvl : z.lvl + h
    bot   = z.dir == 1 ? z.lvl - h : z.lvl
    if not na(z.bx)
        box.set_lefttop(z.bx, xc(z.b1), top)
        box.set_rightbottom(z.bx, right, bot)
        box.set_bgcolor(z.bx, color.new(c, tB))
    if not na(z.ln)
        line.set_xy1(z.ln, xc(z.b1), z.lvl)
        line.set_xy2(z.ln, right, z.lvl)
        line.set_color(z.ln, color.new(c, near ? 0 : 35))
        line.set_width(z.ln, near ? 2 : 1)
    if not na(z.cn)
        // when the first touch is too old to draw, start the line where it is still drawable
        x1 = xc(z.b1)
        x2 = xc(z.bL)
        y1 = x1 == z.b1 or z.bL == z.b1 ? z.p1 : z.p1 + (z.pL - z.p1) * float(x1 - z.b1) / float(z.bL - z.b1)
        line.set_xy1(z.cn, x1, y1)
        line.set_xy2(z.cn, x2, z.pL)
    if not na(z.lb)
        txt = lblMode == "Name" ? name : lblMode == "Name + price" ? name + "  " + str.tostring(z.lvl, format.mintick) :
             name + " ×" + str.tostring(z.touches)
        dist = atr > 0 ? math.abs(z.lvl - close) / atr : float(na)
        label.set_xy(z.lb, right, z.lvl)
        label.set_text(z.lb, txt)
        label.set_textcolor(z.lb, txtOwn ? c : cTx)
        label.set_tooltip(z.lb, (z.dir == 1 ? "Equal highs" : "Equal lows") + " · " + str.tostring(z.touches) + " touches" +
             "\nLevel " + str.tostring(z.lvl, format.mintick) + (na(dist) ? "" : " · " + str.tostring(dist, "#.#") + " ATR away") +
             "\nFirst touch " + str.tostring(bar_index - z.b1) + " bars ago · last " + str.tostring(age) + " bars ago" +
             (na(z.rv) ? "" : "\nVolume around the touches " + str.tostring(z.rv, "#.#") + "× average"))
    true

var zH  = array.new<Zone>()
var zL  = array.new<Zone>()
// single swings waiting for an equal partner
var cHp = array.new_float()
var cHb = array.new_int()
var cHv = array.new_float()
var cLp = array.new_float()
var cLb = array.new_int()
var cLv = array.new_float()
// open measurements: expected direction, target, invalidation (close beyond), start bar, stat slot
var evD = array.new_int()
var evT = array.new_float()
var evI = array.new_float()
var evB = array.new_int()
var evK = array.new_int()
// stat slots per side (EQH 0-5, EQL 6-11): 0-2 sweeps by touches (2, 3, 4+), 3 breaks, 4 baseline
var stN = array.new_int(12, 0)
var stW = array.new_int(12, 0)
var mkL = array.new_label()
var mkT = array.new_line()

addEv(int d, float tgt, float inv, int k) =>
    evD.push(d)
    evT.push(tgt)
    evI.push(inv)
    evB.push(bar_index)
    evK.push(k)
    true

qMark(label l) =>
    mkL.push(l)
    if mkL.size() > keepMk
        label.delete(mkL.shift())
    true

qTrail(line l) =>
    mkT.push(l)
    if mkT.size() > keepMk
        line.delete(mkT.shift())
    true

// sweeps and breaks of live zones on this bar
checkSide(array<Zone> zs, int d) =>
    bool sw = false
    bool br = false
    if zs.size() > 0
        for i = zs.size() - 1 to 0
            z = zs.get(i)
            took = d == 1 ? high > z.lvl : low < z.lvl
            aged = maxAge > 0 and bar_index - z.bL > maxAge
            if took
                c = colOf(d)
                name = d == 1 ? "EQH" : "EQL"
                isSw = d == 1 ? close <= z.lvl : close >= z.lvl
                slot = (d == 1 ? 0 : 6)
                if isSw
                    sw := true
                    addEv(-d, close - d * revAtr * atr, d == 1 ? high : low, slot + math.min(z.touches, 4) - 2)
                    if showSw and vis(d)
                        qMark(label.new(bar_index, d == 1 ? high : low, "", style = label.style_xcross, color = color.new(c, 35), size = size.tiny,
                             tooltip = name + " swept · " + str.tostring(z.touches) + " touches\nLevel " + str.tostring(z.lvl, format.mintick) +
                             " · wick " + str.tostring(d == 1 ? high : low, format.mintick) + "\nClosed back " + (d == 1 ? "below" : "above") + " the level"))
                else
                    br := true
                    addEv(d, close + d * revAtr * atr, z.lvl, slot + 3)
                    if showBr and vis(d)
                        qMark(label.new(bar_index, d == 1 ? high : low, "", style = label.style_circle, color = color.new(c, 40), size = size.tiny,
                             tooltip = name + " broken · " + str.tostring(z.touches) + " touches\nClosed " + (d == 1 ? "above " : "below ") +
                             str.tostring(z.lvl, format.mintick)))
                if showTrl and vis(d)
                    qTrail(line.new(xc(z.b1), z.lvl, bar_index, z.lvl, color = color.new(c, 60), style = line.style_dotted))
                z.kill()
                zs.remove(i)
            else if aged
                z.kill()
                zs.remove(i)
    [sw, br]

// single swings that were traded through or are too old can no longer pair
pruneCand(array<float> ps, array<int> bs, array<float> vs, int d) =>
    if ps.size() > 0
        for i = ps.size() - 1 to 0
            p = ps.get(i)
            gone = (d == 1 ? high > p + tol : low < p - tol) or bar_index - bs.get(i) > maxGap + pvLen
            if gone
                ps.remove(i)
                bs.remove(i)
                vs.remove(i)
    true

// a newly confirmed swing: join a zone, pair with single swings, or wait
onSwing(array<Zone> zs, array<float> ps, array<int> bs, array<float> vs, int d, float p, int b, float rv) =>
    bool made = false
    int best = -1
    float bestD = 1e18
    if zs.size() > 0
        for i = 0 to zs.size() - 1
            z = zs.get(i)
            dist = math.abs(p - z.lvl)
            if dist <= tol and dist < bestD
                best := i
                bestD := dist
    if best >= 0 and b - zs.get(best).bL < minGap
        made := false    // same level, too close to the last touch: not a new touch, and no duplicate zone
    else if best >= 0
        z = zs.get(best)
        z.touches := z.touches + 1
        z.far := d == 1 ? math.min(z.far, p) : math.max(z.far, p)
        z.lvl := d == 1 ? math.max(z.lvl, p) : math.min(z.lvl, p)
        z.rv := na(rv) ? z.rv : na(z.rv) ? rv : (z.rv * (z.touches - 1) + rv) / z.touches
        z.bL := b
        z.pL := p
    else
        int n = 0
        float hiP = p
        float loP = p
        int b1 = b
        float p1 = p
        float rvS = nz(rv)
        int rvN = na(rv) ? 0 : 1
        if ps.size() > 0
            for i = ps.size() - 1 to 0
                q = ps.get(i)
                qb = bs.get(i)
                if math.abs(q - p) <= tol and b - qb >= minGap and b - qb <= maxGap
                    n += 1
                    hiP := math.max(hiP, q)
                    loP := math.min(loP, q)
                    if qb < b1
                        b1 := qb
                        p1 := q
                    if not na(vs.get(i))
                        rvS += vs.get(i)
                        rvN += 1
                    ps.remove(i)
                    bs.remove(i)
                    vs.remove(i)
        if n > 0
            zs.push(newZone(d, d == 1 ? hiP : loP, d == 1 ? loP : hiP, b1, b, p1, p, n + 1, rvN > 0 ? rvS / rvN : float(na)))
            made := true
            if zs.size() > maxZ
                int far = 0
                float farD = -1.0
                for i = 0 to zs.size() - 1
                    dd = math.abs(zs.get(i).lvl - close)
                    if dd > farD
                        far := i
                        farD := dd
                old = zs.remove(far)
                old.kill()
        else
            ps.push(p)
            bs.push(b)
            vs.push(rv)
            if ps.size() > 60
                ps.shift()
                bs.shift()
                vs.shift()
    made

// ═══ Engine (on bar close) ═════════════════════════════════════════════════
bool newH = false
bool newL = false
bool swH  = false
bool swL  = false
bool brH  = false
bool brL  = false

if barstate.isconfirmed
    // 1) resolve open measurements
    if evB.size() > 0
        for i = evB.size() - 1 to 0
            if evB.get(i) < bar_index
                d   = evD.get(i)
                hit = d == 1 ? high >= evT.get(i) : low <= evT.get(i)
                bad = d == 1 ? close < evI.get(i) : close > evI.get(i)
                out = bar_index - evB.get(i) >= revBars
                if hit or bad or out
                    k = evK.get(i)
                    stN.set(k, stN.get(k) + 1)
                    if hit and not bad
                        stW.set(k, stW.get(k) + 1)
                    evD.remove(i)
                    evT.remove(i)
                    evI.remove(i)
                    evB.remove(i)
                    evK.remove(i)
    // 2) sweeps and breaks
    [s1, b1] = checkSide(zH, 1)
    [s2, b2] = checkSide(zL, -1)
    swH := s1
    brH := b1
    swL := s2
    brL := b2
    // 3) baseline: the same measurement from every bar
    if atr > 0
        addEv(-1, close - revAtr * atr, high, 4)
        addEv(1, close + revAtr * atr, low, 10)
    // 4) single swings that can no longer pair
    pruneCand(cHp, cHb, cHv, 1)
    pruneCand(cLp, cLb, cLv, -1)
    // 5) newly confirmed swings
    if not na(ph)
        newH := onSwing(zH, cHp, cHb, cHv, 1, ph, bar_index - pvLen, rvNow)
    if not na(pl)
        newL := onSwing(zL, cLp, cLb, cLv, -1, pl, bar_index - pvLen, rvNow)

// nearest live levels
float nearH = na
float nearL = na
if zH.size() > 0
    for z in zH
        if z.lvl >= close and (na(nearH) or z.lvl < nearH)
            nearH := z.lvl
if zL.size() > 0
    for z in zL
        if z.lvl <= close and (na(nearL) or z.lvl > nearL)
            nearL := z.lvl
plot(showSc and showH ? nearH : na, "Nearest EQH", cH, display = display.price_scale)
plot(showSc and showL ? nearL : na, "Nearest EQL", cL, display = display.price_scale)

if barstate.islast
    if zH.size() > 0
        for z in zH
            z.paint(hiNear and z.lvl == nearH)
    if zL.size() > 0
        for z in zL
            z.paint(hiNear and z.lvl == nearL)

// ═══ Panel ═════════════════════════════════════════════════════════════════
cTxt  = #d1d4dc
cMute = #787b86
cGood = #089981
cBad  = #f23645

rate(int k) =>
    n = stN.get(k)
    n == 0 ? float(na) : stW.get(k) * 100.0 / n

cellTxt(int n, int w) =>
    n == 0 ? "—" : str.tostring(w * 100.0 / n, "#") + "%  (" + str.tostring(n) + ")"

var table pt = na
if barstate.islast and showPan
    if not na(pt)
        table.delete(pt)
    PS = sizeOf(panSz)
    pt := table.new(posOf(panPos), 3, 12, bgcolor = color.new(#131722, 8), frame_color = #2a2e39, frame_width = 1, border_width = 0)
    table.cell(pt, 0, 0, "SwiftEdge EQH/EQL", text_color = cTxt, text_size = PS, text_halign = text.align_left)
    table.cell(pt, 1, 0, "EQH", text_color = cH, text_size = PS, text_halign = text.align_right)
    table.cell(pt, 2, 0, "EQL", text_color = cL, text_size = PS, text_halign = text.align_right)
    table.cell(pt, 0, 1, "Live zones", text_color = cMute, text_size = PS, text_halign = text.align_left)
    table.cell(pt, 1, 1, str.tostring(zH.size()), text_color = cTxt, text_size = PS, text_halign = text.align_right)
    table.cell(pt, 2, 1, str.tostring(zL.size()), text_color = cTxt, text_size = PS, text_halign = text.align_right)
    table.cell(pt, 0, 2, "Nearest", text_color = cMute, text_size = PS, text_halign = text.align_left)
    table.cell(pt, 1, 2, na(nearH) or atr <= 0 ? "—" : str.tostring((nearH - close) / atr, "#.#") + " ATR", text_color = cTxt, text_size = PS, text_halign = text.align_right)
    table.cell(pt, 2, 2, na(nearL) or atr <= 0 ? "—" : str.tostring((close - nearL) / atr, "#.#") + " ATR", text_color = cTxt, text_size = PS, text_halign = text.align_right)
    table.cell(pt, 0, 3, "Sweep → " + str.tostring(revAtr, "#.##") + " ATR reversal in " + str.tostring(revBars) + " bars", text_color = color.new(cMute, 20), text_size = PS, text_halign = text.align_left)
    names = array.from("  All sweeps", "  2 touches", "  3 touches", "  4+ touches", "  Any bar (baseline)")
    for r = 0 to 4
        table.cell(pt, 0, 4 + r, names.get(r), text_color = r == 4 ? cMute : cTxt, text_size = PS, text_halign = text.align_left)
        for s = 0 to 1
            o = s * 6
            int n = 0
            int w = 0
            if r == 0
                for k = 0 to 2
                    n += stN.get(o + k)
                    w += stW.get(o + k)
            else
                kk = r == 4 ? 4 : r - 1
                n := stN.get(o + kk)
                w := stW.get(o + kk)
            base = rate(o + 4)
            pc = n > 0 ? w * 100.0 / n : float(na)
            col = r == 4 or na(pc) or na(base) or n < 20 ? (r == 4 ? cMute : cTxt) : pc >= base + 5 ? cGood : pc <= base - 5 ? cBad : cTxt
            table.cell(pt, 1 + s, 4 + r, cellTxt(n, w), text_color = col, text_size = PS, text_halign = text.align_right)
    table.cell(pt, 0, 9, "Break → " + str.tostring(revAtr, "#.##") + " ATR continuation", text_color = color.new(cMute, 20), text_size = PS, text_halign = text.align_left)
    table.cell(pt, 0, 10, "  All breaks", text_color = cTxt, text_size = PS, text_halign = text.align_left)
    table.cell(pt, 1, 10, cellTxt(stN.get(3), stW.get(3)), text_color = cTxt, text_size = PS, text_halign = text.align_right)
    table.cell(pt, 2, 10, cellTxt(stN.get(9), stW.get(9)), text_color = cTxt, text_size = PS, text_halign = text.align_right)
    table.cell(pt, 0, 11, "hit rate (n) · green/red = 5 pts above/below baseline", text_color = color.new(cMute, 30), text_size = PS, text_halign = text.align_left)

// ═══ Alerts ════════════════════════════════════════════════════════════════
alertcondition(newH, "New EQH", "SE EQH/EQL: new equal highs")
alertcondition(newL, "New EQL", "SE EQH/EQL: new equal lows")
alertcondition(swH, "EQH swept", "SE EQH/EQL: equal highs swept (wick above, close back below)")
alertcondition(swL, "EQL swept", "SE EQH/EQL: equal lows swept (wick below, close back above)")
alertcondition(brH, "EQH broken", "SE EQH/EQL: close above equal highs")
alertcondition(brL, "EQL broken", "SE EQH/EQL: close below equal lows")
````
