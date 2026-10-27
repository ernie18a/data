# Prev Day/Week VP Levels MADE BY ADAM

- url: https://www.tradingview.com/script/fo6T2Gqq-Prev-Day-Week-VP-Levels-MADE-BY-ADAM/
- type: indicator
- pine_id: PUB;9f4b251ffaf849109e8e0fcf559dc743
- version: 1.0

## Description

Previous Day & Week Volume Profile Levels (POC / VAH / VAL)
This indicator automatically plots the previous day's and previous week's volume profile levels — Point of Control (POC), Value Area High (VAH), and Value Area Low (VAL) — as clean horizontal levels extended to the right of the chart, replicating the look of manually drawn key levels.
How it works
Sessions are defined by a custom reset hour in a chosen timezone rather than midnight exchange time. The default is 19:00 New York (crypto perpetual sessions); set it to 18:00 for CME futures like MNQ/NQ to match the Globex daily open. Weeks run from the Sunday-evening session open through the Friday close.
All profiles are calculated on a separate, configurable calculation timeframe (default 5-minute) through request.security, independent of the chart timeframe. This means the levels are identical on every chart resolution and remain visible even on a 1-minute chart, where the chart itself doesn't hold enough history to cover a full week. Each period's profile distributes bar volume across price rows (default 100), locates the POC as the highest-volume row, and expands the value area around it until it contains the configured share of total volume (default 70%).
Once a day or week completes, its levels are drawn across the current period and stay fixed until the next rollover — the exact levels a trader would mark by hand at the start of each session.
Features

Previous day and previous week POC, VAH, VAL (each toggleable)
Custom session reset hour and timezone (DST-safe)
Configurable calculation timeframe, row count, and value area percentage
Minimalist styling: line color, width, style (solid/dashed/dotted), plain text labels (pdaypoc, pweekvah, etc.) with adjustable offset and size
No repainting: only completed periods are plotted

Intended use
Built for intraday traders who anchor their execution around prior-session value: value area rotations, POC retests, acceptance/rejection outside prior value, and confluence with order flow or options-derived levels.

## Source Code

````pine
//@version=6
indicator("Prev Day/Week VP Levels (HTF Calc)", "pD/pW VP HTF",
     overlay = true, max_lines_count = 50, max_labels_count = 50)

// ─────────────────────────────────────────────
//  Inputs
// ─────────────────────────────────────────────
grpS    = "Session"
tzIn    = input.string("America/New_York", "Timezone", group = grpS)
rstHour = input.int(19, "Session reset hour (19 = Bybit BTC, 18 = CME futures)", minval = 0, maxval = 23, group = grpS)

grpP   = "Profile"
calcTF = input.timeframe("5", "Calculation timeframe", group = grpP,
     tooltip = "The profile is built from this timeframe's bars, independent of the chart timeframe. 5m gives weeks of history even on a 1m chart.")
rowsN  = input.int(100, "Rows per profile", minval = 10, maxval = 250, group = grpP)
vaIn   = input.float(70.0, "Value Area %", minval = 50, maxval = 95, group = grpP)

grpT  = "Periods"
showD = input.bool(true, "Previous Day", group = grpT)
showW = input.bool(true, "Previous Week", group = grpT)

grpV    = "Style"
lnCol   = input.color(color.black, "Line color", group = grpV)
txtCol  = input.color(color.black, "Text color", group = grpV)
lnW     = input.int(1, "Line width", minval = 1, maxval = 4, group = grpV)
styleIn = input.string("Dotted", "Line style", options = ["Solid", "Dashed", "Dotted"], group = grpV)
lblOff  = input.int(15, "Label offset (bars right)", minval = 0, maxval = 100, group = grpV)
txtSize = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = grpV)

lnStyle = styleIn == "Solid" ? line.style_solid : styleIn == "Dashed" ? line.style_dashed : line.style_dotted
lblSize = txtSize == "Tiny" ? size.tiny : txtSize == "Small" ? size.small : size.normal

// ─────────────────────────────────────────────
//  Volume profile calculation
// ─────────────────────────────────────────────
f_profile(array<float> hs, array<float> ls, array<float> vs, int nRows, float vaP) =>
    float pLo = ls.min()
    float pHi = hs.max()
    float poc = pLo
    float vah = pHi
    float val = pLo
    if pHi > pLo
        float step = (pHi - pLo) / nRows
        binV = array.new_float(nRows, 0.0)
        for i = 0 to hs.size() - 1
            float bh = hs.get(i)
            float bl = ls.get(i)
            float bv = vs.get(i)
            int i1 = math.max(0, math.min(nRows - 1, int((bl - pLo) / step)))
            int i2 = math.max(0, math.min(nRows - 1, int((bh - pLo) / step)))
            float per = bv / (i2 - i1 + 1)
            for j = i1 to i2
                binV.set(j, binV.get(j) + per)
        float total = binV.sum()
        int pIdx = 0
        float maxV = -1.0
        for j = 0 to nRows - 1
            if binV.get(j) > maxV
                maxV := binV.get(j)
                pIdx := j
        poc := pLo + (pIdx + 0.5) * step
        float acc = binV.get(pIdx)
        int up = pIdx
        int dn = pIdx
        float target = total * vaP
        while acc < target and (up < nRows - 1 or dn > 0)
            float uV = up < nRows - 1 ? binV.get(up + 1) : -1.0
            float dV = dn > 0 ? binV.get(dn - 1) : -1.0
            if uV >= dV
                up += 1
                acc += uV
            else
                dn -= 1
                acc += dV
        vah := pLo + (up + 1) * step
        val := pLo + dn * step
    [poc, vah, val]

// ─────────────────────────────────────────────
//  Runs inside the HTF (calcTF) context via request.security
// ─────────────────────────────────────────────
f_calc() =>
    int shiftMs = (24 - rstHour) % 24 * 3600 * 1000
    int sT      = time + shiftMs
    int yS      = year(sT, tzIn)
    int mS      = month(sT, tzIn)
    int dSm     = dayofmonth(sT, tzIn)
    int dNum    = int(timestamp("GMT", yS, mS, dSm, 0, 0) / 86400000)
    int wNum    = int(math.floor((dNum + 3) / 7))

    var hsD = array.new_float()
    var lsD = array.new_float()
    var vsD = array.new_float()
    var hsW = array.new_float()
    var lsW = array.new_float()
    var vsW = array.new_float()

    var int lastD  = na
    var int lastW  = na
    var bool dSaw  = false
    var bool wSaw  = false

    var float dPoc = na
    var float dVah = na
    var float dVal = na
    var float wPoc = na
    var float wVah = na
    var float wVal = na

    bool dNew = not na(lastD) and dNum != lastD
    bool wNew = not na(lastW) and wNum != lastW

    if dNew
        if dSaw and hsD.size() > 0
            [p, h, l] = f_profile(hsD, lsD, vsD, rowsN, vaIn / 100)
            dPoc := p
            dVah := h
            dVal := l
        hsD.clear()
        lsD.clear()
        vsD.clear()
        dSaw := true
    if wNew
        if wSaw and hsW.size() > 0
            [p, h, l] = f_profile(hsW, lsW, vsW, rowsN, vaIn / 100)
            wPoc := p
            wVah := h
            wVal := l
        hsW.clear()
        lsW.clear()
        vsW.clear()
        wSaw := true

    hsD.push(high)
    lsD.push(low)
    vsD.push(volume)
    hsW.push(high)
    lsW.push(low)
    vsW.push(volume)

    lastD := dNum
    lastW := wNum

    [dPoc, dVah, dVal, wPoc, wVah, wVal]

[dPoc, dVah, dVal, wPoc, wVah, wVal] =
     request.security(syminfo.tickerid, calcTF, f_calc(), lookahead = barmerge.lookahead_off)

// ─────────────────────────────────────────────
//  Drawing (chart context)
// ─────────────────────────────────────────────
f_draw(bool show, float poc, float vah, float val, string tagPre) =>
    var line  lnP = na
    var line  lnH = na
    var line  lnL = na
    var label lbP = na
    var label lbH = na
    var label lbL = na
    var float lstP = na
    var float lstH = na
    var float lstL = na

    bool changed = not na(poc) and (na(lstP) or poc != lstP or vah != lstH or val != lstL)

    if show and changed
        if not na(lnP)
            line.delete(lnP)
            line.delete(lnH)
            line.delete(lnL)
            label.delete(lbP)
            label.delete(lbH)
            label.delete(lbL)
        int x1 = bar_index
        lnP := line.new(x1, poc, x1 + 1, poc, color = lnCol, width = lnW, style = lnStyle, extend = extend.right)
        lnH := line.new(x1, vah, x1 + 1, vah, color = lnCol, width = lnW, style = lnStyle, extend = extend.right)
        lnL := line.new(x1, val, x1 + 1, val, color = lnCol, width = lnW, style = lnStyle, extend = extend.right)
        lbP := label.new(x1 + lblOff, poc, tagPre + "poc", style = label.style_none, textcolor = txtCol, size = lblSize)
        lbH := label.new(x1 + lblOff, vah, tagPre + "vah", style = label.style_none, textcolor = txtCol, size = lblSize)
        lbL := label.new(x1 + lblOff, val, tagPre + "val", style = label.style_none, textcolor = txtCol, size = lblSize)
        lstP := poc
        lstH := vah
        lstL := val

    if not show and not na(lnP)
        line.delete(lnP)
        line.delete(lnH)
        line.delete(lnL)
        label.delete(lbP)
        label.delete(lbH)
        label.delete(lbL)
        lstP := na

    if show and barstate.islast and not na(lbP)
        label.set_x(lbP, bar_index + lblOff)
        label.set_x(lbH, bar_index + lblOff)
        label.set_x(lbL, bar_index + lblOff)

f_draw(showD, dPoc, dVah, dVal, "pday")
f_draw(showW, wPoc, wVah, wVal, "pweek")
````
