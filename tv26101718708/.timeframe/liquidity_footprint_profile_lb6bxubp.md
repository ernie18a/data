# Liquidity Footprint Profile

- url: https://www.tradingview.com/script/lB6bXubp-Liquidity-Footprint-Profile/
- type: indicator
- pine_id: PUB;3901e3eaf2e64a3baaf6ab2f26ab4bd2
- version: 1.0

## Description

Liquidity Footprint Profile combines a session volume profile, real footprint order flow and liquidity levels in one indicator.

Session profile:
- Volume profile for each NY session (09:30-16:00) or the full day
- POC, Value Area High and Low, and a developing profile for the current session
- With footprint data, the profile is built from real buy and sell volume at each price, and each row is colored by delta (green = buyers dominated, red = sellers dominated)
- Previous VAH / VAL extended, and naked POCs that stay active until price trades back to them

Footprint features (require a TradingView plan with footprint data):
- Stacked imbalance zones: 3 or more consecutive imbalanced rows in a bar create a zone. Overlapping zones are merged, and a zone is removed once price closes back through it
- Absorption at liquidity (ABS): a liquidity level is swept with strong opposite delta, but the bar closes back beyond the level. Example: price sweeps a low while sellers are aggressive (negative delta) and still closes back above it, which suggests the selling was absorbed
- Session delta in the dashboard

Liquidity:
- Asia high/low, London high/low and previous day high/low
- Unswept levels stay active; swept levels turn into short dashed lines

Without footprint data:
The indicator still works. The profile is built from 1-minute data and the footprint features are disabled. The dashboard shows whether footprint data is available.

Alerts:
- Buy-side / sell-side liquidity swept
- Naked POC touched
- Bullish / bearish absorption

Notes:
- Designed for index futures such as NQ/MNQ and ES/MES on intraday charts.
- Absorption and imbalance signals are confirmed on bar close.
- This is an analysis tool, not financial advice or a trading signal.

## Source Code

````pine
//@version=6
indicator("Liquidity Footprint Profile", shorttitle = "LFP", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// =====================================================
// INPUTS
// =====================================================
G_P   = "Profile"
G_LV  = "Profile levels"
G_LQ  = "Liquidity"
G_D   = "Dashboard & colors"

anchor   = input.string("NY session", "Profile period", options = ["NY session", "Full day"], group = G_P)
profSess = input.session("0930-1600", "NY session time", group = G_P)
tz       = input.string("America/New_York", "Timezone", group = G_P)
rowsN    = input.int(40, "Rows", minval = 10, maxval = 100, group = G_P)
vaPct    = input.int(70, "Value area %", minval = 10, maxval = 95, group = G_P)
ltfIn    = input.timeframe("1", "Precision timeframe", group = G_P, tooltip = "Lower timeframe used to distribute volume. On charts at or below this timeframe, chart bars are used.")
widthPct = input.int(30, "Histogram width (% of session)", minval = 5, maxval = 100, group = G_P)
showHist = input.bool(true, "Show histogram", group = G_P)
showDev  = input.bool(true, "Show developing profile", group = G_P)

showVA     = input.bool(true, "Extend previous VAH / VAL", group = G_LV)
showNaked  = input.bool(true, "Naked POCs (extend until touched)", group = G_LV)
maxNaked   = input.int(5, "Max naked POCs", minval = 1, maxval = 20, group = G_LV)

useAsia    = input.bool(true, "Asia high / low", inline = "as", group = G_LQ)
asiaSess   = input.session("2000-0000", "", inline = "as", group = G_LQ)
useLondon  = input.bool(true, "London high / low", inline = "ld", group = G_LQ)
londonSess = input.session("0200-0500", "", inline = "ld", group = G_LQ)
usePD      = input.bool(true, "Previous day high / low", group = G_LQ)
maxLiq     = input.int(12, "Max active liquidity levels", minval = 2, maxval = 30, group = G_LQ)

showDash = input.bool(true, "Show dashboard", group = G_D)
dashPosIn = input.string("Top Right", "Dashboard position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = G_D)
cPOC  = input.color(#f59e0b, "POC", inline = "c1", group = G_D)
cVA   = input.color(#38bdf8, "Value area", inline = "c1", group = G_D)
cOut  = input.color(color.gray, "Outside VA", inline = "c1", group = G_D)
cLiqH = input.color(#ef4444, "Liquidity high", inline = "c2", group = G_D)
cLiqL = input.color(#22c55e, "Liquidity low", inline = "c2", group = G_D)

G_FP = "Footprint (Premium / Ultimate plans)"
fpTicks    = input.int(4, "Footprint ticks per row", minval = 1, group = G_FP)
imbPct     = input.int(300, "Imbalance %", minval = 100, group = G_FP)
colorDelta = input.bool(true, "Color profile rows by delta", group = G_FP)
showStack  = input.bool(true, "Stacked imbalance zones", inline = "st", group = G_FP)
stackN     = input.int(3, "min rows", minval = 2, inline = "st", group = G_FP)
maxZones   = input.int(6, "Max zones per side", minval = 1, maxval = 20, group = G_FP)
keepBroken = input.bool(false, "Keep broken zones (faded)", group = G_FP)
showAbs    = input.bool(true, "Absorption at liquidity", inline = "ab", group = G_FP)
absPct     = input.float(15, "min |delta| %", minval = 0, inline = "ab", group = G_FP)
cBuy       = input.color(#22c55e, "Buy", inline = "fc", group = G_FP)
cSell      = input.color(#ef4444, "Sell", inline = "fc", group = G_FP)

// =====================================================
// HELPERS
// =====================================================
// Spread a bar's volume evenly across the fine price buckets it covers
f_add(map<int, float> m, float h, float l, float v, float fsz) =>
    if not na(v) and v > 0 and fsz > 0 and not na(h) and not na(l)
        int kLo = int(math.floor(l / fsz))
        int kHi = int(math.floor(h / fsz))
        float per = v / (kHi - kLo + 1)
        for k = kLo to kHi
            m.put(k, nz(m.get(k)) + per)
    fsz

// Aggregate fine buckets into display rows between lo and hi
f_rows(map<int, float> m, map<int, float> dm, float lo, float hi, float fsz) =>
    array<float> rv = array.new<float>(rowsN, 0.0)
    array<float> dv = array.new<float>(rowsN, 0.0)
    float rowH = (hi - lo) / rowsN
    if rowH > 0 and m.size() > 0
        keys = m.keys()
        vals = m.values()
        for i = 0 to keys.size() - 1
            int k = keys.get(i)
            float px = k * fsz + fsz / 2
            int idx = math.max(0, math.min(rowsN - 1, int(math.floor((px - lo) / rowH))))
            rv.set(idx, rv.get(idx) + vals.get(i))
            dv.set(idx, dv.get(idx) + nz(dm.get(k)))
    [rv, dv, rowH]

// POC row and value area rows
f_va(array<float> rv) =>
    int n    = rv.size()
    int poc  = rv.indexof(rv.max())
    float target = rv.sum() * vaPct / 100
    int up = poc
    int dn = poc
    float acc = rv.get(poc)
    while acc < target and (up < n - 1 or dn > 0)
        float nu = up < n - 1 ? rv.get(up + 1) : -1.0
        float nd = dn > 0 ? rv.get(dn - 1) : -1.0
        if nu >= nd
            up  += 1
            acc += nu
        else
            dn  -= 1
            acc += nd
    [poc, up, dn]

f_draw(array<float> rv, array<float> dv, bool useDelta, float lo, float rowH, int x1, int x2, int poc, int up, int dn, array<box> store) =>
    float maxV = rv.max()
    int widthBars = math.max(1, int(math.round((x2 - x1) * widthPct / 100)))
    if maxV > 0
        for i = 0 to rv.size() - 1
            float v = rv.get(i)
            int w = int(math.round(v / maxV * widthBars))
            if w > 0
                bool inVA = i >= dn and i <= up
                color base = useDelta ? (dv.get(i) >= 0 ? cBuy : cSell) : cVA
                color col = i == poc ? color.new(cPOC, 35) : inVA ? color.new(base, 68) : useDelta ? color.new(base, 80) : color.new(cOut, 85)
                store.push(box.new(x1, lo + (i + 1) * rowH, x1 + w, lo + i * rowH, border_width = 0, bgcolor = col))
    maxV

// =====================================================
// PROFILE PERIOD
// =====================================================
inSessRaw = not na(time(timeframe.period, profSess + ":1234567", tz))
dayChange = timeframe.change("D")
isStart = anchor == "Full day" ? dayChange : inSessRaw and not inSessRaw[1]
isEnd   = anchor == "Full day" ? dayChange : inSessRaw[1] and not inSessRaw
inProf  = anchor == "Full day" ? true : inSessRaw

dayATR = request.security(syminfo.tickerid, "D", ta.atr(14)[1], lookahead = barmerge.lookahead_on)

useChart = timeframe.in_seconds() <= timeframe.in_seconds(ltfIn)
ltfReq   = useChart ? timeframe.period : ltfIn
[ltfH, ltfL, ltfV] = request.security_lower_tf(syminfo.tickerid, ltfReq, [high, low, volume])

footprint fp = request.footprint(fpTicks, vaPct, imbPct)
bool fpOK = not na(fp)
float fpDelta = fpOK ? fp.delta() : na
float fpVol   = fpOK ? fp.buy_volume() + fp.sell_volume() : na
float dPct    = fpOK and fpVol > 0 ? 100 * fpDelta / fpVol : na

var map<int, float> vmap = map.new<int, float>()
var map<int, float> dmap = map.new<int, float>()
var bool  sessHasDelta = false
var float sessDelta    = na
var float fineSz    = na
var float sHi       = na
var float sLo       = na
var int   sStartBar = na
var bool  active    = false

var array<box>  histBoxes = array.new<box>()
var array<line> sessLines = array.new<line>()
var array<line> nakedLns  = array.new<line>()
var array<float> nakedPx  = array.new<float>()
var line prevVAH = na
var line prevVAL = na

var float lastPOC = na
var float lastVAH = na
var float lastVAL = na

// ---------- Finalize the completed session ----------
if isEnd and active and not na(sHi) and sHi > sLo
    [rv, dv, rowH] = f_rows(vmap, dmap, sLo, sHi, fineSz)
    if rv.sum() > 0
        [poc, up, dn] = f_va(rv)
        int x1 = sStartBar
        int x2 = bar_index - 1
        if showHist
            f_draw(rv, dv, colorDelta and sessHasDelta, sLo, rowH, x1, x2, poc, up, dn, histBoxes)
            while histBoxes.size() > 420
                histBoxes.shift().delete()
        lastPOC := sLo + (poc + 0.5) * rowH
        lastVAH := sLo + (up + 1) * rowH
        lastVAL := sLo + dn * rowH
        sessLines.push(line.new(x1, lastPOC, x2, lastPOC, color = cPOC, width = 2))
        sessLines.push(line.new(x1, lastVAH, x2, lastVAH, color = color.new(cVA, 20), width = 1))
        sessLines.push(line.new(x1, lastVAL, x2, lastVAL, color = color.new(cVA, 20), width = 1))
        while sessLines.size() > 90
            sessLines.shift().delete()
        if showVA
            line.delete(prevVAH)
            line.delete(prevVAL)
            prevVAH := line.new(x2, lastVAH, bar_index, lastVAH, color = color.new(cVA, 40), style = line.style_dashed)
            prevVAL := line.new(x2, lastVAL, bar_index, lastVAL, color = color.new(cVA, 40), style = line.style_dashed)
        if showNaked
            nakedLns.push(line.new(x2, lastPOC, bar_index, lastPOC, color = cPOC, style = line.style_dotted, width = 2))
            nakedPx.push(lastPOC)
            if nakedLns.size() > maxNaked
                nakedLns.shift().delete()
                nakedPx.shift()
    active := false

// ---------- Start a new session ----------
if isStart
    vmap.clear()
    dmap.clear()
    sessHasDelta := false
    sessDelta    := 0.0
    fineSz    := na(dayATR) ? syminfo.mintick * 4 : math.max(syminfo.mintick, math.round(dayATR / 100 / syminfo.mintick) * syminfo.mintick)
    sHi       := high
    sLo       := low
    sStartBar := bar_index
    active    := true

// ---------- Accumulate volume ----------
if active and inProf
    sHi := math.max(sHi, high)
    sLo := math.min(sLo, low)
    if fpOK
        sessHasDelta := true
        sessDelta    := nz(sessDelta) + fpDelta
        for row in fp.rows()
            int k = int(math.floor((row.up_price() + row.down_price()) / 2 / fineSz))
            vmap.put(k, nz(vmap.get(k)) + row.total_volume())
            dmap.put(k, nz(dmap.get(k)) + row.delta())
    else if useChart
        f_add(vmap, high, low, volume, fineSz)
    else if ltfH.size() > 0
        for i = 0 to ltfH.size() - 1
            f_add(vmap, ltfH.get(i), ltfL.get(i), ltfV.get(i), fineSz)

// ---------- Extend reference lines / naked POCs ----------
if not na(prevVAH)
    prevVAH.set_x2(bar_index)
    prevVAL.set_x2(bar_index)

bool nakedTouched = false
if nakedPx.size() > 0
    for i = nakedPx.size() - 1 to 0
        float px = nakedPx.get(i)
        line ln = nakedLns.get(i)
        if high >= px and low <= px and ln.get_x1() < bar_index - 1
            ln.set_x2(bar_index)
            ln.set_style(line.style_solid)
            ln.set_color(color.new(cPOC, 60))
            nakedLns.remove(i)
            nakedPx.remove(i)
            nakedTouched := true
        else
            ln.set_x2(bar_index)

// =====================================================
// LIQUIDITY LEVELS
// =====================================================
f_sessHL(string sess) =>
    inS = not na(time(timeframe.period, sess + ":1234567", tz))
    var float h  = na
    var float l  = na
    var int   sb = na
    if inS and not inS[1]
        h  := high
        l  := low
        sb := bar_index
    else if inS
        h := math.max(h, high)
        l := math.min(l, low)
    ended = inS[1] and not inS
    [ended, h, l, sb]

var array<line>   liqLines = array.new<line>()
var array<label>  liqLbls  = array.new<label>()
var array<float>  liqPx    = array.new<float>()
var array<bool>   liqHigh  = array.new<bool>()
var array<string> liqName  = array.new<string>()

f_addLiq(float px, bool isHigh, string name, int x1) =>
    if not na(px)
        color col = isHigh ? cLiqH : cLiqL
        liqLines.push(line.new(x1, px, bar_index, px, color = col, width = 1))
        liqLbls.push(label.new(bar_index, px, name, style = label.style_label_left, color = color.new(col, 85), textcolor = col, size = size.small))
        liqPx.push(px)
        liqHigh.push(isHigh)
        liqName.push(name)
        if liqPx.size() > maxLiq
            liqLines.shift().delete()
            liqLbls.shift().delete()
            liqPx.shift()
            liqHigh.shift()
            liqName.shift()
    px

[asiaEnd, asiaH, asiaL, asiaSB] = f_sessHL(asiaSess)
[lonEnd, lonH, lonL, lonSB]     = f_sessHL(londonSess)
pdh = request.security(syminfo.tickerid, "D", high[1], lookahead = barmerge.lookahead_on)
pdl = request.security(syminfo.tickerid, "D", low[1],  lookahead = barmerge.lookahead_on)

if useAsia and asiaEnd
    f_addLiq(asiaH, true,  "Asia H", asiaSB)
    f_addLiq(asiaL, false, "Asia L", asiaSB)
if useLondon and lonEnd
    f_addLiq(lonH, true,  "London H", lonSB)
    f_addLiq(lonL, false, "London L", lonSB)
if usePD and dayChange
    f_addLiq(pdh, true,  "PDH", bar_index)
    f_addLiq(pdl, false, "PDL", bar_index)

bool highSwept = false
bool lowSwept  = false
float sweptHighPx = na
float sweptLowPx  = na
string sweptTxt = ""
if liqPx.size() > 0
    for i = liqPx.size() - 1 to 0
        float px   = liqPx.get(i)
        bool isH   = liqHigh.get(i)
        line ln    = liqLines.get(i)
        label lb   = liqLbls.get(i)
        bool swept = ln.get_x2() < bar_index and ((isH and high > px) or (not isH and low < px))
        ln.set_x2(bar_index)
        lb.set_x(bar_index)
        if swept
            ln.set_style(line.style_dashed)
            ln.set_color(color.new(color.gray, 50))
            lb.delete()
            sweptTxt := sweptTxt + (sweptTxt == "" ? "" : ", ") + liqName.get(i)
            if isH
                highSwept   := true
                sweptHighPx := na(sweptHighPx) ? px : math.min(sweptHighPx, px)
            else
                lowSwept   := true
                sweptLowPx := na(sweptLowPx) ? px : math.max(sweptLowPx, px)
            liqLines.remove(i)
            liqLbls.remove(i)
            liqPx.remove(i)
            liqHigh.remove(i)
            liqName.remove(i)

// =====================================================
// STACKED IMBALANCE ZONES (footprint)
// A zone stays active until price closes back through it
// =====================================================
var array<box>   buyZones  = array.new<box>()
var array<float> buyZoneLo = array.new<float>()
var array<box>   sellZones = array.new<box>()
var array<float> sellZoneHi = array.new<float>()

// New zones that overlap or touch an active zone are merged into it
f_newZone(array<box> zones, array<float> lvl, float top, float bot, color col, bool isBuy) =>
    bool merged = false
    float tol = syminfo.mintick * fpTicks
    if zones.size() > 0
        for i = 0 to zones.size() - 1
            box z = zones.get(i)
            if not merged and top >= z.get_bottom() - tol and bot <= z.get_top() + tol
                float nt = math.max(top, z.get_top())
                float nb = math.min(bot, z.get_bottom())
                z.set_top(nt)
                z.set_bottom(nb)
                lvl.set(i, isBuy ? nb : nt)
                merged := true
    if not merged
        zones.push(box.new(bar_index, top, bar_index, bot, border_color = color.new(col, 40), bgcolor = color.new(col, 82)))
        lvl.push(isBuy ? bot : top)
        if zones.size() > maxZones
            zones.shift().delete()
            lvl.shift()
    merged

if showStack and fpOK and barstate.isconfirmed
    array<volume_row> rws = fp.rows()
    int n = rws.size()
    int runB = 0
    int runS = 0
    for [i, row] in rws
        runB := row.has_buy_imbalance() ? runB + 1 : 0
        runS := row.has_sell_imbalance() ? runS + 1 : 0
        bool lastRow = i == n - 1
        bool endB = runB > 0 and (lastRow or not rws.get(math.min(i + 1, n - 1)).has_buy_imbalance())
        bool endS = runS > 0 and (lastRow or not rws.get(math.min(i + 1, n - 1)).has_sell_imbalance())
        if endB and runB >= stackN
            float bot = rws.get(i - runB + 1).down_price()
            f_newZone(buyZones, buyZoneLo, row.up_price(), bot, cBuy, true)
        if endS and runS >= stackN
            float top = row.up_price()
            f_newZone(sellZones, sellZoneHi, top, rws.get(i - runS + 1).down_price(), cSell, false)

// Extend active zones, retire them when price closes through
if buyZones.size() > 0
    for i = buyZones.size() - 1 to 0
        box z = buyZones.get(i)
        z.set_right(bar_index)
        if close < buyZoneLo.get(i) and z.get_left() < bar_index
            if keepBroken
                z.set_bgcolor(color.new(cBuy, 94))
                z.set_border_color(color.new(cBuy, 80))
            else
                z.delete()
            buyZones.remove(i)
            buyZoneLo.remove(i)
if sellZones.size() > 0
    for i = sellZones.size() - 1 to 0
        box z = sellZones.get(i)
        z.set_right(bar_index)
        if close > sellZoneHi.get(i) and z.get_left() < bar_index
            if keepBroken
                z.set_bgcolor(color.new(cSell, 94))
                z.set_border_color(color.new(cSell, 80))
            else
                z.delete()
            sellZones.remove(i)
            sellZoneHi.remove(i)

// =====================================================
// ABSORPTION AT LIQUIDITY (footprint)
// Bullish: a low is swept, sellers are aggressive (negative delta),
// yet the bar closes back above the level -> selling was absorbed.
// =====================================================
bullAbs = showAbs and fpOK and barstate.isconfirmed and lowSwept  and close > sweptLowPx  and not na(dPct) and dPct <= -absPct
bearAbs = showAbs and fpOK and barstate.isconfirmed and highSwept and close < sweptHighPx and not na(dPct) and dPct >=  absPct

plotshape(bullAbs, "Bullish absorption", shape.labelup,   location.belowbar, color.new(cBuy, 10),  text = "ABS", textcolor = color.white, size = size.small)
plotshape(bearAbs, "Bearish absorption", shape.labeldown, location.abovebar, color.new(cSell, 10), text = "ABS", textcolor = color.white, size = size.small)

// =====================================================
// DEVELOPING PROFILE (drawn on the last bar only)
// =====================================================
var array<box>  devBoxes = array.new<box>()
var array<line> devLines = array.new<line>()
var float devPOC = na
var float devVAH = na
var float devVAL = na

if barstate.islast
    while devBoxes.size() > 0
        devBoxes.pop().delete()
    while devLines.size() > 0
        devLines.pop().delete()
    devPOC := na
    devVAH := na
    devVAL := na
    if showDev and active and inProf and sHi > sLo
        [rv, dv, rowH] = f_rows(vmap, dmap, sLo, sHi, fineSz)
        if rv.sum() > 0
            [poc, up, dn] = f_va(rv)
            if showHist
                f_draw(rv, dv, colorDelta and sessHasDelta, sLo, rowH, sStartBar, bar_index, poc, up, dn, devBoxes)
            devPOC := sLo + (poc + 0.5) * rowH
            devVAH := sLo + (up + 1) * rowH
            devVAL := sLo + dn * rowH
            devLines.push(line.new(sStartBar, devPOC, bar_index, devPOC, color = cPOC, width = 2, style = line.style_dashed))
            devLines.push(line.new(sStartBar, devVAH, bar_index, devVAH, color = color.new(cVA, 30), style = line.style_dashed))
            devLines.push(line.new(sStartBar, devVAL, bar_index, devVAL, color = color.new(cVA, 30), style = line.style_dashed))

// =====================================================
// DASHBOARD
// =====================================================
dashPos = switch dashPosIn
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right

var table dash = table.new(dashPos, 2, 12, bgcolor = color.new(#0b1220, 10), border_color = color.new(color.gray, 70), border_width = 1)

f_row(int r, string k, string v, color vbg) =>
    table.cell(dash, 0, r, k, text_color = color.silver, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, r, v, text_color = color.white, bgcolor = vbg, text_size = size.small)

f_fmt(float v) =>
    na(v) ? "-" : str.tostring(v, format.mintick)

if showDash and barstate.islast
    bool dev = not na(devPOC)
    float refVAH = lastVAH
    float refVAL = lastVAL
    string vsValue = na(refVAH) ? "-" : close > refVAH ? "Above value" : close < refVAL ? "Below value" : "Inside value"
    color vsCol = vsValue == "Above value" ? color.new(color.green, 40) : vsValue == "Below value" ? color.new(color.red, 40) : color.new(color.gray, 50)

    float liqAbove = na
    float liqBelow = na
    if liqPx.size() > 0
        for i = 0 to liqPx.size() - 1
            float px = liqPx.get(i)
            if px > close and (na(liqAbove) or px < liqAbove)
                liqAbove := px
            if px < close and (na(liqBelow) or px > liqBelow)
                liqBelow := px

    table.cell(dash, 0, 0, "LIQUIDITY PROFILE", text_color = color.white, text_size = size.small)
    table.merge_cells(dash, 0, 0, 1, 0)
    int r = 1
    if dev
        f_row(r, "Developing POC", f_fmt(devPOC), color.new(cPOC, 50))
        r += 1
        f_row(r, "Developing VAH / VAL", f_fmt(devVAH) + " / " + f_fmt(devVAL), na)
        r += 1
    f_row(r, "Last POC", f_fmt(lastPOC), dev ? na : color.new(cPOC, 50))
    r += 1
    f_row(r, "Last VAH / VAL", f_fmt(lastVAH) + " / " + f_fmt(lastVAL), na)
    r += 1
    f_row(r, "Price vs last value", vsValue, vsCol)
    r += 1
    f_row(r, "Liquidity above", f_fmt(liqAbove), color.new(cLiqH, 60))
    r += 1
    f_row(r, "Liquidity below", f_fmt(liqBelow), color.new(cLiqL, 60))
    r += 1
    f_row(r, "Naked POCs", str.tostring(nakedPx.size()), na)
    r += 1
    if fpOK or sessHasDelta
        f_row(r, "Session delta", na(sessDelta) ? "-" : str.tostring(math.round(sessDelta)), nz(sessDelta) >= 0 ? color.new(cBuy, 50) : color.new(cSell, 50))
        r += 1
        f_row(r, "Imbalance zones", str.tostring(buyZones.size()) + " buy / " + str.tostring(sellZones.size()) + " sell", na)
        r += 1
    f_row(r, "Footprint data", fpOK ? "On" : "Off (Premium plan needed)", fpOK ? color.new(cBuy, 60) : color.new(color.gray, 50))
    r += 1
    if r <= 11
        table.clear(dash, 0, r, 1, 11)

// =====================================================
// ALERTS
// =====================================================
alertcondition(highSwept, "Liquidity high swept", "{{ticker}}: buy-side liquidity swept")
alertcondition(lowSwept,  "Liquidity low swept",  "{{ticker}}: sell-side liquidity swept")
alertcondition(nakedTouched, "Naked POC touched", "{{ticker}}: price touched a naked POC")
alertcondition(bullAbs, "Bullish absorption", "{{ticker}}: sell-side liquidity swept with absorption")
alertcondition(bearAbs, "Bearish absorption", "{{ticker}}: buy-side liquidity swept with absorption")
if highSwept or lowSwept
    alert(syminfo.ticker + ": liquidity swept (" + sweptTxt + ")", alert.freq_once_per_bar_close)
````
