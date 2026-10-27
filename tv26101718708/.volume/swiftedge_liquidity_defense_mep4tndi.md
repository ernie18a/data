# SwiftEdge Liquidity Defense

- url: https://www.tradingview.com/script/meP4Tndi-SwiftEdge-Liquidity-Defense/
- type: indicator
- pine_id: PUB;a16c8621d6284975a35285baaca154b5
- version: 1.0

## Description

SwiftEdge Liquidity Defense maps the liquidity resting above swing highs and below swing lows, and shows who has been trading at each level since it formed. Each pool is split into how the level was built and how it has been defended, using volume delta. That way you can see whether a level is being absorbed or abandoned before price returns to it.

WHAT IT SHOWS

• Liquidity pools
Buy-side liquidity (BSL) sits above confirmed swing highs, where stops of short positions and breakout orders typically rest. Sell-side liquidity (SSL) sits below confirmed swing lows. Each pool is drawn as a zone from the swing candle's body to its wick tip (or as an ATR band), with a level line and a price tag at the right edge.

• Formation (left section of each zone)
Two horizontal bars show the volume of the bars that built the swing: sellers on top, buyers below. The length of each bar is that side's share of the volume.

• Defense profile (right section, projected forward)
A small volume profile of everything traded inside the zone after it formed. The zone is split into rows by price, and each row's length is the volume traded at that slice, split into buyers and sellers. The profile updates while the level is alive, so you can see where inside the zone the activity happened and which side was in control.

• Pool size and nearest pools
Zone intensity follows the formation volume relative to the 100-bar average, so larger pools stand out. The nearest buy-side pool above price and the nearest sell-side pool below price are highlighted and marked on the price scale.

• Sweeps and breaks
When a wick trades beyond a level but the bar closes back inside, the pool is marked as swept: the level becomes a dotted line, the grab is shaded and an × marks the wick. When a bar closes beyond the level, the pool is treated as broken and removed. A sweep whose bar delta leans toward the reversal side, above a share you choose (55% by default), is additionally marked with a small triangle.

• Panel
The panel shows bar delta and session delta, the nearest BSL and SSL with distance in percent, and the number of active pools. It also shows a simple measurement on the loaded history: how often a sweep was followed by a move of N × ATR in the reversal direction within a set number of bars, before any bar closed beyond the sweep wick. The result is shown for all sweeps, for sweeps with delta confirmation, and for sweeps without it. This lets you check on your own symbol and timeframe whether delta confirmation adds anything.

HOW IT WORKS

1. Swings are found with a pivot of "Swing length" bars on each side. A pool is created once the swing is confirmed.
2. Buy and sell volume is estimated per bar from lower-timeframe candles: an up candle counts as buy volume and a down candle as sell volume. The lower timeframe is chosen automatically from the chart timeframe (15m and below use 1m, 1H uses 5m, 4H uses 15m, daily uses 1H, higher uses 4H) or set manually. Without lower-timeframe data, the bar's close location within its range is used instead.
3. Formation volume is the sum over the bars around the swing (Swing length bars on each side).
4. Defense volume: every bar that overlaps a zone adds its buy and sell volume to the rows it touches, in proportion to how much of the bar's range overlaps each row.
5. Sweeps, breaks and signals are evaluated on bar close by default.

HOW TO USE IT

• Treat active pools as areas price is likely to be drawn toward, and the defense profile as context for how the level is being handled.
• A pool whose defense is dominated by the opposite side (for example sell-side liquidity defended by sellers) suggests the level is being worked through rather than held.
• Use the sweep statistics to judge, on your own market and timeframe, how often sweeps reversed and whether delta confirmation helped, instead of assuming it does.
• All elements (formation, profile, level lines, tags, sweep marks, reversal marks, price-scale marks, panel) can be switched off, and four colour themes are included.

WHAT MAKES IT DIFFERENT

Most liquidity tools only mark where swing highs and lows are and when they are taken. This script adds:
• a separation between the volume that formed a level and the volume traded at it afterwards,
• a per-zone volume profile split by buyers and sellers, so you can see where inside the zone the activity happened,
• a clear separation between a sweep (wick and close back) and a break (close beyond),
• a built-in measurement of sweep outcomes with and without delta confirmation, so the delta filter can be judged on data.

LIMITATIONS

• Delta is an estimate based on candle direction or close location. TradingView does not provide bid/ask tape data to Pine scripts, so it is not true order-flow delta.
• Lower-timeframe history is limited by TradingView. On older bars, or when no lower-timeframe data is available, the close-location estimate is used.
• Swings are only known Swing length bars after the high or low, so each zone is drawn back from its swing point once confirmed. With "Confirm on bar close" enabled (default), sweeps, breaks and marks do not change after the bar closes.
• The volume used depends on your data feed. On symbols without volume the delta features cannot work.
• The sweep statistics describe the history loaded on your chart. They are not a forecast and are not a trading system.

This script is for analysis and education. It does not provide trading advice, and past behaviour shown on the chart does not imply future results.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════
//  SwiftEdge Liquidity Defense
//  Maps buy-side liquidity (above swing highs) and sell-side liquidity (below
//  swing lows) and shows who traded at each level:
//   • FORMATION (left): sellers on top, buyers below. Bar length = share of
//     the volume that built the swing.
//   • DEFENSE PROFILE (right, projected forward): a volume profile of
//     everything traded inside the zone since it formed, split into rows,
//     each row split into buyers and sellers.
//  Pool size (formation volume vs average) drives zone intensity; the nearest
//  buy-side and sell-side pools are highlighted and marked on the price scale.
//  A wick through a level that closes back is a SWEEP; a close beyond is a
//  BREAK. Sweeps whose candle delta leans toward the reversal are marked.
//  The panel measures how often sweeps reversed on the loaded history, with
//  and without delta confirmation.
//
//  Notes
//   • Swings are confirmed "Swing length" bars after the high/low, so a zone
//     is drawn back from its swing point once confirmed.
//   • With "Confirm on bar close" (default) sweeps, breaks and signals are
//     only decided on closed bars and do not change afterwards.
//   • Delta is estimated from lower-timeframe candles (up candle = buy volume,
//     down candle = sell volume) or from the close location within each bar.
//     TradingView does not provide bid/ask tape data to Pine.
//   • A visualization and research tool. Statistics describe the loaded
//     history only.
// ═══════════════════════════════════════════════════════════════════════════
indicator("SwiftEdge Liquidity Defense", "SE Liquidity Defense", overlay = true, max_bars_back = 500,
     max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

// ═══ Inputs ════════════════════════════════════════════════════════════════
grpL = "1 · Liquidity levels"
pivLen   = input.int(10, "Swing length", minval = 2, maxval = 50, group = grpL)
maxZ     = input.int(5, "Max active zones per side", minval = 1, maxval = 10, group = grpL)
zoneMode = input.string("Wick", "Zone height", options = ["Wick", "ATR band"], group = grpL,
     tooltip = "Wick: from the swing candle's body to its wick tip. ATR band: a fixed band of ATR × multiplier from the swing price.")
zoneAtr  = input.float(0.40, "ATR band / minimum height (× ATR14)", minval = 0.05, maxval = 2.0, step = 0.05, group = grpL)
extBars  = input.int(20, "Project active zones forward (bars)", minval = 2, maxval = 200, group = grpL)
nRows    = input.int(4, "Defense profile rows", minval = 2, maxval = 8, group = grpL)

grpD = "2 · Volume delta"
deltaMode = input.string("Lower timeframe", "Delta method", options = ["Lower timeframe", "Bar close location"], group = grpD)
ltfAuto   = input.bool(true, "Auto lower timeframe", group = grpD,
     tooltip = "≤15m charts use 1m, 1H uses 5m, 4H uses 15m, daily uses 1H, higher uses 4H.")
ltfIn     = input.timeframe("1", "Manual lower timeframe", group = grpD)

grpS = "3 · Sweeps & reversals"
confOnly  = input.bool(true, "Confirm on bar close", group = grpS,
     tooltip = "Sweeps, breaks and signals are decided only when the bar closes, so nothing appears and disappears inside a live bar.")
needDelta = input.bool(true, "Reversal mark needs delta confirmation", group = grpS)
deltaMin  = input.float(55, "Confirmation: reversal-side share of sweep-bar volume (%)", minval = 50, maxval = 90, group = grpS)
revMult   = input.float(1.5, "Reversal = price moves (× ATR14)", minval = 0.25, maxval = 10, step = 0.25, group = grpS)
revBars   = input.int(20, "… within (bars)", minval = 2, maxval = 300, group = grpS,
     tooltip = "A sweep counts as reversed when price moves this far in the reversal direction before any candle closes beyond the sweep wick.")

grpV = "4 · Style"
theme    = input.string("Classic", "Theme", options = ["Classic", "Neon", "Ocean", "Mono", "Custom"], group = grpV)
cBSLi    = input.color(#2962ff, "Custom: buy-side", inline = "c0", group = grpV)
cSSLi    = input.color(#ff9800, "sell-side", inline = "c0", group = grpV)
cBuyi    = input.color(#26a69a, "Custom: buyers", inline = "c1", group = grpV)
cSelli   = input.color(#ef5350, "sellers", inline = "c1", group = grpV)
qTr      = input.int(40, "Delta bar transparency", minval = 0, maxval = 90, group = grpV)
showGlow = input.bool(false, "Glow", inline = "v0", group = grpV)
showForm = input.bool(true, "Formation", inline = "v0", group = grpV)
showProf = input.bool(true, "Defense profile", inline = "v0", group = grpV)
showLvl  = input.bool(true, "Level line", inline = "v1", group = grpV)
showTag  = input.bool(true, "Price tags", inline = "v1", group = grpV)
showAxis = input.bool(true, "Price-scale marks", inline = "v1", group = grpV)
showGrab = input.bool(true, "Sweep grab box", inline = "v2", group = grpV)
showSwp  = input.bool(true, "SWEEP marks", inline = "v2", group = grpV)
showSig  = input.bool(true, "Reversal marks", inline = "v2", group = grpV)
keepTaken = input.bool(true, "Keep swept levels as dotted lines", group = grpV)
deltaCdl = input.bool(false, "Delta candles (colour bars by buy/sell balance)", group = grpV)
keepMk   = input.int(30, "Marks / taken levels kept", minval = 5, maxval = 150, group = grpV)

grpT = "5 · Dashboard"
showDash = input.bool(true, "Show dashboard", inline = "d0", group = grpT)
dashPos  = input.string("Top right", "", options = ["Top right", "Top left", "Bottom right", "Bottom left", "Middle right"], inline = "d0", group = grpT)
dashSz   = input.string("Tiny", "Text size", options = ["Tiny", "Small", "Normal"], group = grpT)
secStats = input.bool(true, "Sweep statistics", group = grpT)

// ═══ Theme ═════════════════════════════════════════════════════════════════
cBSL  = theme == "Classic" ? #9598a1 : theme == "Neon" ? #00e5ff : theme == "Ocean" ? #2962ff : theme == "Mono" ? #cfd8dc : cBSLi
cSSL  = theme == "Classic" ? #9598a1 : theme == "Neon" ? #ff4ecd : theme == "Ocean" ? #ff9800 : theme == "Mono" ? #78909c : cSSLi
cBuy  = theme == "Classic" ? #089981 : theme == "Neon" ? #00e676 : theme == "Ocean" ? #26a69a : theme == "Mono" ? #e0e0e0 : cBuyi
cSell = theme == "Classic" ? #f23645 : theme == "Neon" ? #ff1744 : theme == "Ocean" ? #ef5350 : theme == "Mono" ? #616161 : cSelli
cTxt  = #d1d4dc
cMute = #787b86

// ═══ Helpers ═══════════════════════════════════════════════════════════════
sizeOf(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : size.normal

posOf(string s) =>
    s == "Top left" ? position.top_left : s == "Bottom right" ? position.bottom_right :
     s == "Bottom left" ? position.bottom_left : s == "Middle right" ? position.middle_right : position.top_right

fv(float x) =>
    na(x) ? "—" : (x >= 0 ? "+" : "") + str.tostring(x, format.volume)

qLbl(array<label> q, label l, int cap) =>
    array.push(q, l)
    if array.size(q) > cap
        old = array.shift(q)
        if not na(old)
            label.delete(old)

qLine(array<line> q, line l, int cap) =>
    array.push(q, l)
    if array.size(q) > cap
        old = array.shift(q)
        if not na(old)
            line.delete(old)

qBox(array<box> q, box b, int cap) =>
    array.push(q, b)
    if array.size(q) > cap
        old = array.shift(q)
        if not na(old)
            box.delete(old)

// ═══ Per-bar buy / sell volume ═════════════════════════════════════════════
atr   = ta.atr(14)
tfSec = timeframe.in_seconds()
autoLtf = tfSec <= 900 ? "1" : tfSec <= 3600 ? "5" : tfSec <= 14400 ? "15" : tfSec <= 86400 ? "60" : "240"
ltf = ltfAuto ? autoLtf : ltfIn
[lV, lC, lO] = request.security_lower_tf(syminfo.tickerid, ltf, [volume, close, open])

float bV = 0.0
float sV = 0.0
if deltaMode == "Lower timeframe" and array.size(lV) > 0
    for i = 0 to array.size(lV) - 1
        v = nz(array.get(lV, i))
        if array.get(lC, i) >= array.get(lO, i)
            bV += v
        else
            sV += v
else
    v = nz(volume)
    rng = high - low
    bV := rng > 0 ? v * (close - low) / rng : v * 0.5
    sV := v - bV
volAvg = ta.sma(nz(volume), 100)
tot    = bV + sV
buyShr = tot > 0 ? bV * 100 / tot : 50.0
sellShr = 100 - buyShr

var float dayB = 0.0
var float dayS = 0.0
if timeframe.change("D")
    dayB := 0.0
    dayS := 0.0
dayB += bV
dayS += sV

barcolor(deltaCdl and tot > 0 ? color.from_gradient((bV - sV) / tot, -1, 1, cSell, cBuy) : na)

// ═══ Zone object ═══════════════════════════════════════════════════════════
type Zone
    int d
    float top
    float bot
    int x
    float fb
    float fs
    float stren
    array<float> rb
    array<float> rs
    box glow
    box frame
    box fSell
    box fBuy
    array<box> pBuy
    array<box> pSell
    line lvl
    label tag

var zones  = array.new<Zone>()
var mkQ    = array.new_label()
var takenQ = array.new_line()
var grabQ  = array.new_box()
var int nFormed = 0
var int nBroken = 0
var int nSwept  = 0
var float lifeSum = 0.0
var int   lifeN = 0

hiddenBox(color c, bool on) =>
    box b = na
    if on
        b := box.new(bar_index, 0.0, bar_index, 0.0, border_color = color(na), bgcolor = c)
    b

setSpan(box b, int x1, int len, float yTop, float yBot) =>
    if not na(b)
        box.set_lefttop(b, x1, yTop)
        box.set_rightbottom(b, x1 + math.max(len, 0), yBot)

method dB(Zone z) =>
    sum = 0.0
    for v in z.rb
        sum += v
    sum

method dS(Zone z) =>
    sum = 0.0
    for v in z.rs
        sum += v
    sum

method draw(Zone z, bool hot) =>
    sideC = z.d == 1 ? cBSL : cSSL
    h   = z.top - z.bot
    mid = (z.top + z.bot) / 2
    x0  = z.x - pivLen
    xF  = z.x + pivLen
    xR  = math.max(bar_index + extBars, xF + 2)
    tr  = int(95 - math.min(1.0, math.max(0.0, (z.stren - 0.5) / 2.0)) * 9)
    if not na(z.glow)
        gp = h * 0.7
        box.set_lefttop(z.glow, x0, z.top + gp)
        box.set_rightbottom(z.glow, xR, z.bot - gp)
        box.set_bgcolor(z.glow, color.new(sideC, hot ? 90 : 96))
    if not na(z.frame)
        box.set_lefttop(z.frame, x0, z.top)
        box.set_rightbottom(z.frame, xR, z.bot)
        box.set_bgcolor(z.frame, color.new(sideC, hot ? tr - 3 : tr))
        box.set_border_color(z.frame, hot ? color.new(sideC, 55) : color(na))
        box.set_border_width(z.frame, 1)
    // formation: sellers on top, buyers below, length = share
    fT = z.fb + z.fs
    wF = xF - x0
    setSpan(z.fSell, x0, int(math.round(wF * (fT > 0 ? z.fs / fT : 0.5))), z.top - h * 0.18, mid + h * 0.06)
    setSpan(z.fBuy, x0, int(math.round(wF * (fT > 0 ? z.fb / fT : 0.5))), mid - h * 0.06, z.bot + h * 0.18)
    // defense profile: one row per price slice, length = row volume, split buyers | sellers
    if array.size(z.pBuy) > 0
        rowH = h / nRows
        W = xR - xF
        float mx = 0.0
        for r = 0 to nRows - 1
            mx := math.max(mx, z.rb.get(r) + z.rs.get(r))
        for r = 0 to nRows - 1
            b = z.rb.get(r)
            s = z.rs.get(r)
            t = b + s
            yB = z.bot + r * rowH + rowH * 0.22
            yT = z.bot + (r + 1) * rowH - rowH * 0.22
            len = mx > 0 ? int(math.round(W * 0.94 * t / mx)) : 0
            lb  = t > 0 ? int(math.round(len * b / t)) : 0
            setSpan(z.pBuy.get(r), xF, lb, yT, yB)
            setSpan(z.pSell.get(r), xF + lb, len - lb, yT, yB)
    lv = z.d == 1 ? z.top : z.bot
    if not na(z.lvl)
        line.set_xy1(z.lvl, x0, lv)
        line.set_xy2(z.lvl, xR, lv)
        line.set_width(z.lvl, hot ? 2 : 1)
        line.set_color(z.lvl, hot ? (theme == "Classic" ? cTxt : sideC) : color.new(sideC, 50))
        line.set_style(z.lvl, hot ? line.style_solid : line.style_dotted)
    if not na(z.tag)
        dBv = z.dB()
        dSv = z.dS()
        dT  = dBv + dSv
        label.set_xy(z.tag, xR, lv)
        label.set_text(z.tag, (z.d == 1 ? "BSL " : "SSL ") + str.tostring(lv, format.mintick))
        label.set_textcolor(z.tag, hot ? (theme == "Classic" ? cTxt : sideC) : color.new(sideC, 35))
        label.set_tooltip(z.tag, (z.d == 1 ? "Buy-side liquidity" : "Sell-side liquidity") + " · pool " + str.tostring(z.stren, "#.#") + "× average volume" +
             "\nFormation: " + (fT > 0 ? str.tostring(z.fb * 100 / fT, "#") + "% buyers" : "—") + " · Δ " + fv(z.fb - z.fs) +
             "\nDefense: " + (dT > 0 ? str.tostring(dBv * 100 / dT, "#") + "% buyers" : "no trades yet") + " · Δ " + fv(dBv - dSv) +
             "\nDistance: " + str.tostring(math.abs(lv - close) / atr, "#.##") + " ATR")

method del(Zone z) =>
    if not na(z.glow)
        box.delete(z.glow)
    if not na(z.frame)
        box.delete(z.frame)
    if not na(z.fSell)
        box.delete(z.fSell)
    if not na(z.fBuy)
        box.delete(z.fBuy)
    for b in z.pBuy
        box.delete(b)
    for b in z.pSell
        box.delete(b)
    if not na(z.lvl)
        line.delete(z.lvl)
    if not na(z.tag)
        label.delete(z.tag)

addZone(int d, float top, float bot, int x, float fb, float fs, float stren) =>
    sideC = d == 1 ? cBSL : cSSL
    lv = d == 1 ? top : bot
    gl = showGlow ? box.new(x - pivLen, top, bar_index, bot, border_color = color(na), bgcolor = color.new(sideC, 94)) : box(na)
    fr = box.new(x - pivLen, top, bar_index, bot, border_color = color(na), bgcolor = color.new(sideC, 94))
    pb = array.new_box()
    ps = array.new_box()
    if showProf
        for r = 0 to nRows - 1
            array.push(pb, hiddenBox(color.new(cBuy, qTr), true))
            array.push(ps, hiddenBox(color.new(cSell, qTr), true))
    ln = showLvl ? line.new(x - pivLen, lv, bar_index, lv, color = color.new(sideC, 30), style = line.style_dashed, width = 1) : line(na)
    tg = showTag ? label.new(bar_index, lv, "", style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.new(sideC, 35), size = size.tiny) : label(na)
    z = Zone.new(d, top, bot, x, fb, fs, stren, array.new_float(nRows, 0.0), array.new_float(nRows, 0.0),
         gl, fr, hiddenBox(color.new(cSell, qTr), showForm), hiddenBox(color.new(cBuy, qTr), showForm), pb, ps, ln, tg)
    array.push(zones, z)
    z.draw(false)
    // cap per side: drop the oldest zone of this side
    int cnt = 0
    int oldest = -1
    for i = 0 to array.size(zones) - 1
        if array.get(zones, i).d == d
            cnt += 1
            if oldest == -1
                oldest := i
    if cnt > maxZ and oldest >= 0
        array.get(zones, oldest).del()
        array.remove(zones, oldest)

// ═══ Sweep tracking (statistics) ═══════════════════════════════════════════
var swDir  = array.new_int()
var swRef  = array.new_float()
var swExt  = array.new_float()
var swAtr  = array.new_float()
var swBar  = array.new_int()
var swConf = array.new_bool()
var swSt   = array.new_int()     // 0 open, 1 reversed, 2 failed
var swMfe  = array.new_float()

if array.size(swSt) > 0
    for i = 0 to array.size(swSt) - 1
        if array.get(swSt, i) == 0 and array.get(swBar, i) < bar_index
            d   = array.get(swDir, i)
            fav = d == 1 ? high - array.get(swRef, i) : array.get(swRef, i) - low
            failC = d == 1 ? close < array.get(swExt, i) : close > array.get(swExt, i)
            if failC
                array.set(swSt, i, 2)
            else
                array.set(swMfe, i, math.max(array.get(swMfe, i), fav / array.get(swAtr, i)))
                if fav >= revMult * array.get(swAtr, i)
                    array.set(swSt, i, 1)
                else if bar_index - array.get(swBar, i) >= revBars
                    array.set(swSt, i, 2)

// ═══ Update zones ══════════════════════════════════════════════════════════
// nearest pools (before this bar's updates) get the glow
int hotUp = -1
int hotDn = -1
if array.size(zones) > 0
    for i = 0 to array.size(zones) - 1
        z = array.get(zones, i)
        if z.d == 1 and z.top > close and (hotUp == -1 or z.top < array.get(zones, hotUp).top)
            hotUp := i
        if z.d == -1 and z.bot < close and (hotDn == -1 or z.bot > array.get(zones, hotDn).bot)
            hotDn := i

bool bsSwept = false
bool ssSwept = false
float bsExt = na
float ssExt = na
if array.size(zones) > 0
    for i = array.size(zones) - 1 to 0
        z = array.get(zones, i)
        if z.x + pivLen < bar_index
            // defense profile: split the bar's volume over the rows it overlaps
            if high >= z.bot and low <= z.top
                rowH = (z.top - z.bot) / nRows
                rng  = high - low
                for r = 0 to nRows - 1
                    rB = z.bot + r * rowH
                    rT = rB + rowH
                    ov = math.min(high, rT) - math.max(low, rB)
                    sh = rng > 0 ? math.max(ov, 0) / rng : (close >= rB and close <= rT ? 1.0 : 0.0)
                    if sh > 0
                        z.rb.set(r, z.rb.get(r) + bV * sh)
                        z.rs.set(r, z.rs.get(r) + sV * sh)
            decide = barstate.isconfirmed or not confOnly
            broken = decide and (z.d == 1 ? close > z.top : close < z.bot)
            swept  = decide and not broken and (z.d == 1 ? high > z.top : low < z.bot)
            if broken or swept
                lifeSum += bar_index - z.x
                lifeN += 1
                lv = z.d == 1 ? z.top : z.bot
                sideC = z.d == 1 ? cBSL : cSSL
                if broken
                    nBroken += 1
                else
                    nSwept += 1
                    ext = z.d == 1 ? high : low
                    if z.d == 1
                        bsSwept := true
                        bsExt := na(bsExt) ? high : math.max(bsExt, high)
                    else
                        ssSwept := true
                        ssExt := na(ssExt) ? low : math.min(ssExt, low)
                    if keepTaken
                        qLine(takenQ, line.new(z.x, lv, bar_index, lv, color = color.new(sideC, 40), style = line.style_dotted, width = 1), keepMk)
                    if showGrab
                        qBox(grabQ, box.new(bar_index - 1, math.max(lv, ext), bar_index + 1, math.min(lv, ext),
                             border_color = color(na), bgcolor = color.new(sideC, 75)), keepMk)
                z.del()
                array.remove(zones, i)
            else
                z.draw(i == hotUp or i == hotDn)
        else
            z.draw(i == hotUp or i == hotDn)

// ═══ Sweep marks + reversal signals ════════════════════════════════════════
confDn = sellShr >= deltaMin
confUp = buyShr >= deltaMin
sigDn  = bsSwept and (confDn or not needDelta)
sigUp  = ssSwept and (confUp or not needDelta)

if bsSwept
    array.push(swDir, -1)
    array.push(swRef, close)
    array.push(swExt, bsExt)
    array.push(swAtr, atr)
    array.push(swBar, bar_index)
    array.push(swConf, confDn)
    array.push(swSt, 0)
    array.push(swMfe, 0.0)
    if showSig and sigDn
        qLbl(mkQ, label.new(bar_index, bsExt, "", yloc = yloc.abovebar, style = label.style_triangledown, color = cSell, size = size.tiny,
             tooltip = "Buy-side liquidity swept → bearish reversal candidate" + (confDn ? "\nDelta confirmed: " + str.tostring(sellShr, "#") + "% sell volume" : "")), keepMk)
    if showSwp
        qLbl(mkQ, label.new(bar_index, bsExt, "×", style = label.style_label_down, color = color.new(color.black, 100), textcolor = color.new(cBSL, 20), size = size.small,
             tooltip = "Buy-side liquidity swept\nSweep bar: " + str.tostring(sellShr, "#") + "% sell volume (Δ " + fv(bV - sV) + ")"), keepMk)
if ssSwept
    array.push(swDir, 1)
    array.push(swRef, close)
    array.push(swExt, ssExt)
    array.push(swAtr, atr)
    array.push(swBar, bar_index)
    array.push(swConf, confUp)
    array.push(swSt, 0)
    array.push(swMfe, 0.0)
    if showSig and sigUp
        qLbl(mkQ, label.new(bar_index, ssExt, "", yloc = yloc.belowbar, style = label.style_triangleup, color = cBuy, size = size.tiny,
             tooltip = "Sell-side liquidity swept → bullish reversal candidate" + (confUp ? "\nDelta confirmed: " + str.tostring(buyShr, "#") + "% buy volume" : "")), keepMk)
    if showSwp
        qLbl(mkQ, label.new(bar_index, ssExt, "×", style = label.style_label_up, color = color.new(color.black, 100), textcolor = color.new(cSSL, 20), size = size.small,
             tooltip = "Sell-side liquidity swept\nSweep bar: " + str.tostring(buyShr, "#") + "% buy volume (Δ " + fv(bV - sV) + ")"), keepMk)

// ═══ New swings → new zones ════════════════════════════════════════════════
ph = ta.pivothigh(high, pivLen, pivLen)
pl = ta.pivotlow(low, pivLen, pivLen)
minH = zoneAtr * atr

if not na(ph)
    top = ph
    bot = zoneMode == "Wick" ? math.max(open[pivLen], close[pivLen]) : top - zoneAtr * atr
    bot := math.min(bot, top - minH)
    float fb = 0.0
    float fs = 0.0
    for k = 0 to 2 * pivLen
        fb += bV[k]
        fs += sV[k]
    addZone(1, top, bot, bar_index - pivLen, fb, fs, volAvg > 0 ? (fb + fs) / (volAvg * (2 * pivLen + 1)) : 1.0)
    nFormed += 1

if not na(pl)
    bot = pl
    top = zoneMode == "Wick" ? math.min(open[pivLen], close[pivLen]) : bot + zoneAtr * atr
    top := math.max(top, bot + minH)
    float fb = 0.0
    float fs = 0.0
    for k = 0 to 2 * pivLen
        fb += bV[k]
        fs += sV[k]
    addZone(-1, top, bot, bar_index - pivLen, fb, fs, volAvg > 0 ? (fb + fs) / (volAvg * (2 * pivLen + 1)) : 1.0)
    nFormed += 1

// ═══ Nearest pools on the price scale ══════════════════════════════════════
float nBSL = na
float nSSL = na
if array.size(zones) > 0
    for i = 0 to array.size(zones) - 1
        z = array.get(zones, i)
        if z.d == 1 and z.top > close and (na(nBSL) or z.top < nBSL)
            nBSL := z.top
        if z.d == -1 and z.bot < close and (na(nSSL) or z.bot > nSSL)
            nSSL := z.bot
plot(showAxis ? nBSL : na, "Nearest BSL", color = cBSL, display = display.price_scale)
plot(showAxis ? nSSL : na, "Nearest SSL", color = cSSL, display = display.price_scale)

// ═══ Dashboard ═════════════════════════════════════════════════════════════
DS = sizeOf(dashSz)

rowKV(table t, int r, string k, string v, color c) =>
    table.cell(t, 0, r, k, text_color = cMute, text_size = DS, text_halign = text.align_left)
    table.cell(t, 1, r, v, text_color = c, text_size = DS, text_halign = text.align_right)
    r + 1

rowGap(table t, int r) =>
    table.cell(t, 0, r, "", text_size = size.tiny, height = 0.6)
    table.cell(t, 1, r, "", text_size = size.tiny, height = 0.6)
    r + 1

sweepStats(int conf) =>
    int n = 0
    int w = 0
    float mf = 0.0
    if array.size(swSt) > 0
        for i = 0 to array.size(swSt) - 1
            st = array.get(swSt, i)
            c  = array.get(swConf, i)
            if (conf == 0 or (conf == 1 and c) or (conf == 2 and not c)) and st != 0
                n += 1
                mf += array.get(swMfe, i)
                if st == 1
                    w += 1
    [n, n > 0 ? w * 100.0 / n : na, n > 0 ? mf / n : na]

var table dash = na
if showDash and barstate.islast
    if na(dash)
        dash := table.new(posOf(dashPos), 2, 16, bgcolor = color.new(#131722, 8), frame_color = #2a2e39, frame_width = 1,
             border_width = 0)
    table.clear(dash, 0, 0, 1, 15)
    int row = 0
    table.cell(dash, 0, row, "SwiftEdge Liquidity Defense", text_color = cTxt, text_size = DS, text_halign = text.align_left)
    table.cell(dash, 1, row, "", text_size = DS)
    row += 1
    dT = dayB + dayS
    row := rowKV(dash, row, "Bar delta", fv(bV - sV) + "  ·  " + str.tostring(buyShr, "#") + "% buy", bV >= sV ? cBuy : cSell)
    row := rowKV(dash, row, "Session delta", fv(dayB - dayS) + "  ·  " + (dT > 0 ? str.tostring(dayB * 100 / dT, "#") : "50") + "% buy", dayB >= dayS ? cBuy : cSell)
    row := rowGap(dash, row)
    row := rowKV(dash, row, "Nearest BSL", na(nBSL) ? "—" : str.tostring(nBSL, format.mintick) + "   +" + str.tostring((nBSL / close - 1) * 100, "#.##") + "%", cTxt)
    row := rowKV(dash, row, "Nearest SSL", na(nSSL) ? "—" : str.tostring(nSSL, format.mintick) + "   −" + str.tostring((1 - nSSL / close) * 100, "#.##") + "%", cTxt)
    int nBs = 0
    int nSs = 0
    for z in zones
        if z.d == 1
            nBs += 1
        else
            nSs += 1
    row := rowKV(dash, row, "Active pools", str.tostring(nBs) + " BSL  ·  " + str.tostring(nSs) + " SSL", cTxt)
    if secStats
        [nA, rA, mA] = sweepStats(0)
        [nC, rC, mC] = sweepStats(1)
        [nU, rU, mU] = sweepStats(2)
        row := rowGap(dash, row)
        row := rowKV(dash, row, "Sweeps reversed", nA == 0 ? "—" : str.tostring(rA, "#") + "%  (" + str.tostring(nA) + ")", cTxt)
        row := rowKV(dash, row, "with delta", nC == 0 ? "—" : str.tostring(rC, "#") + "%  (" + str.tostring(nC) + ")", cTxt)
        row := rowKV(dash, row, "without delta", nU == 0 ? "—" : str.tostring(rU, "#") + "%  (" + str.tostring(nU) + ")", cTxt)
        row := rowKV(dash, row, "Reversal test", str.tostring(revMult) + " ATR / " + str.tostring(revBars) + " bars", color.new(cMute, 20))
        row := rowKV(dash, row, "Delta source", deltaMode == "Lower timeframe" ? (array.size(lV) == 0 ? "bar" : "LTF " + ltf) : "bar", color.new(cMute, 20))

// ═══ Alerts ════════════════════════════════════════════════════════════════
alertcondition(bsSwept, "Buy-side liquidity swept", "SE Liquidity Defense: buy-side liquidity swept")
alertcondition(ssSwept, "Sell-side liquidity swept", "SE Liquidity Defense: sell-side liquidity swept")
alertcondition(sigDn, "Bearish reversal signal", "SE Liquidity Defense: bearish reversal candidate after buy-side sweep")
alertcondition(sigUp, "Bullish reversal signal", "SE Liquidity Defense: bullish reversal candidate after sell-side sweep")
````
