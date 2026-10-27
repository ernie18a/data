# Avg Weekly Move + Implied

- url: https://www.tradingview.com/script/cXnUYyVY-Avg-Weekly-Move-Implied/
- type: indicator
- pine_id: PUB;90c3a499fadf4069a540220418b715ad
- version: 2.0

## Description

Projects the expected weekly range and the key levels that drive it, anchored to the current week and readable on any timeframe; no repaint.

[b]What it plots[/b]
- Average weekly move band — the mean weekly move over a configurable lookback, drawn as upper/lower lines around an anchor (this week's open or prior week's close). Choose Close-to-Close or High-Low Range, and Percent basis (scales to current price) or raw Points.

- Implied move overlay (manual) — enter the expected move from your broker's option chain for the weekly expiry; plots a dashed band and shows the implied-vs-realized ratio so you can see if options are pricing more or less than history.

- Prior-week high / low — the prior week's range edges, the levels price most often reaches for.

- OpEx markers — faded shading on monthly 3rd-Friday expirations, with quad-witching (Mar/Jun/Sep/Dec) in its own color and an optional charm run-in shade.

- Dashboard (bottom-right) — avg move, implied (+ ratio), band "held %" reliability, prior-week levels, next OpEx. date/type/phase, and a per-symbol PWH-reliability flag.

[b]How to read it[/b]
- "Held %" tells you how often the band actually contained the week — high = trustworthy, low = the symbol's vol outruns its average (treat the band loosely).

- The PWH flag reads "Reliable here" on broad-index symbols and "Weak" on range-bound names...the prior-high draw is strongest on indices; back-tested this over 3 years.

[b]Notes[/b]
- Non-repainting: all weekly values come from completed weeks via higher-timeframe data, so they stay fixed intra-week and read identically on 15m, 1H, or daily.

- The Implied Move is a manual input (Pine can't access options data) — refresh it each week per symbol. I use ThinkOrSwim for finding the Implied Move.

- Works on any symbol; OpEx dates are universal, but the OpEx behavioral context was studied on index products. I imagine, a date or two could be off, but you can save and adjust the code as you see fit.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Warner_Bear

//@version=6
indicator("Avg Weekly Move + Implied", "Wk Move", overlay = true, max_lines_count = 30, max_labels_count = 25, max_boxes_count = 20)

// ============ INPUTS ============
// -- Realized move --
lookback    = input.int(104, "Lookback (weeks)", minval=1, maxval=500, group="Realized Move", tooltip="Completed weeks averaged. Change to re-scale the move.")
measure     = input.string("Close-to-Close", "Move measure", options=["Close-to-Close","High-Low Range"], group="Realized Move")
basis       = input.string("Percent (scales to price)", "Move basis", options=["Percent (scales to price)","Points (raw)"], group="Realized Move")
anchorType  = input.string("Prior week's close", "Anchor from", options=["This week's open","Prior week's close"], group="Realized Move")
showMid     = input.bool(true,  "Show anchor line", group="Realized Move")
showLabels  = input.bool(true,  "Show labels", group="Realized Move")
labelOffset = input.int(3, "Label offset (bars right)", minval=0, maxval=50, group="Realized Move")

// -- Implied move (manual, from your option chain) --
showImp = input.bool(true,  "Show implied move", group="Implied Move", tooltip="Pine can't read options data. Type the expected move from your platform's option chain for the weekly expiry; refresh weekly.")
impVal  = input.float(0.0,  "Implied move value (manual)", minval=0.0, group="Implied Move")
impUnit = input.string("Points","Units", options=["Points","Percent"], group="Implied Move")
useVix    = input.bool(true, "VIX-auto implied band", group="Implied Move", tooltip="Auto-fill the implied band from the matching vol index (VIX/VXN/RVX) instead of manual entry. Valid only on SPX/SPY, QQQ/NDX, IWM/RUT (it's the INDEX's vol, not a single stock's). Turn OFF to use the manual value above.")
vixSource = input.string("VIX9D (best for weekly)", "VIX tenor (SPX/SPY)", options=["VIX9D (best for weekly)","VIX (30-day)"], group="Implied Move", tooltip="VIX9D (9-day) matches the weekly horizon; VIX (30-day) runs ~15% rich for a 1-week move due to term structure.")

// -- Prior-week levels --
showPW = input.bool(true, "Show prior-week high/low", group="Prior-Week Levels", tooltip="PWH is the dominant draw (tested ~72% of weeks in the SPX study).")
pwhCol = input.color(#2962ff, "Prior wk high", group="Prior-Week Levels", inline="pw")
pwlCol = input.color(#9c27b0, "Prior wk low",  group="Prior-Week Levels", inline="pw")

// -- OpEx markers --
showOpEx   = input.bool(true,  "Show OpEx markers (faded)", group="OpEx", tooltip="Faded vertical shade on 3rd-Friday expirations. Dates are universal; the drift/quad-witching edge was measured on SPX/index products. Best on daily/intraday charts.")
showCharm  = input.bool(true,  "Shade charm run-in (~T-5..T0)", group="OpEx")
monOpExCol = input.color(#787b86, "Monthly OpEx", group="OpEx", inline="ox")
quadOpExCol= input.color(#ff9800, "Quad-witching", group="OpEx", inline="ox")

// -- Dashboard --
showDash = input.bool(true, "Show dashboard (bottom-right)", group="Dashboard")
dashSz   = input.string("Normal", "Text size", options=["Small","Normal","Large"], group="Dashboard")

// -- Style --
upCol = input.color(#26a69a, "Realized up", group="Style", inline="1")
dnCol = input.color(#ef5350, "Realized down", group="Style", inline="1")
miCol = input.color(color.gray, "Anchor", group="Style", inline="2")
impCol= input.color(#ffa726, "Implied", group="Style", inline="2")
lw    = input.int(2, "Line width", minval=1, maxval=5, group="Style")

// -- Manual GEX levels (Pine can't read options data — key these from Periscope) --
gGex    = "Manual GEX Levels"
maxPain = input.float(0.0, "Max Pain price", group=gGex, tooltip="0 = hidden. Enter the Max Pain level; refresh daily (it moves with OI).")
gexFlip = input.float(0.0, "GEX Flip price", group=gGex, tooltip="0 = hidden. Enter the gamma flip; refresh weekly / post-OpEx (it migrates).")
glowOn  = input.bool(true, "Glow effect", group=gGex)
mpCol   = input.color(#e040fb, "Max Pain", group=gGex, inline="gc")
flipCol = input.color(#00e5ff, "GEX Flip", group=gGex, inline="gc")
mpLblOff = input.int(3, "Max Pain label offset (bars)", minval=0, maxval=120, group=gGex)
fpLblOff = input.int(3, "GEX Flip label offset (bars)", minval=0, maxval=120, group=gGex)

// -- Positive gamma zones (enter top & bottom of each; 0 = hidden) --
gPos = "Positive Gamma Zones"
pz1t = input.float(0.0, "Zone 1 top", group=gPos, inline="pz1")
pz1b = input.float(0.0, "bottom",     group=gPos, inline="pz1")
pz2t = input.float(0.0, "Zone 2 top", group=gPos, inline="pz2")
pz2b = input.float(0.0, "bottom",     group=gPos, inline="pz2")
pz3t = input.float(0.0, "Zone 3 top", group=gPos, inline="pz3")
pz3b = input.float(0.0, "bottom",     group=gPos, inline="pz3")
posCol = input.color(color.new(#26a69a, 82), "Positive zone fill", group=gPos)

// -- Negative gamma zones (enter top & bottom of each; 0 = hidden) --
gNeg = "Negative Gamma Zones"
nz1t = input.float(0.0, "Zone 1 top", group=gNeg, inline="nz1")
nz1b = input.float(0.0, "bottom",     group=gNeg, inline="nz1")
nz2t = input.float(0.0, "Zone 2 top", group=gNeg, inline="nz2")
nz2b = input.float(0.0, "bottom",     group=gNeg, inline="nz2")
nz3t = input.float(0.0, "Zone 3 top", group=gNeg, inline="nz3")
nz3b = input.float(0.0, "bottom",     group=gNeg, inline="nz3")
negCol = input.color(color.new(#ef5350, 82), "Negative zone fill", group=gNeg)

// -- OpEx 14-day max-pain watch shade --
g14    = "OpEx 14-Day Watch"
show14 = input.bool(true, "Highlight 14 days before OpEx", group=g14)
col14  = input.color(#ffd54f, "14-day watch shade", group=g14)

// ============ WEEKLY STATS (non-repainting; [1] = completed weeks only) ============
ptsExpr = measure=="High-Low Range" ? high-low : math.abs(close-close[1])
pctExpr = ptsExpr/close[1]*100
avgPctE = ta.sma(pctExpr[1], lookback)
avgPtsE = ta.sma(ptsExpr[1], lookback)
heldE   = ta.sma((ptsExpr[1] <= avgPtsE[1]) ? 1.0 : 0.0, lookback)*100
[avgPct, avgPts, heldHist, wkOpen, prevClose, pwh, pwl] = request.security(syminfo.tickerid, "W", [avgPctE, avgPtsE, heldE, open, close[1], high[1], low[1]], lookahead=barmerge.lookahead_off)

anchor  = anchorType=="Prior week's close" ? prevClose : wkOpen
avgMove = basis=="Points (raw)" ? avgPts : avgPct/100*anchor
half    = measure=="High-Low Range" ? avgMove/2 : avgMove
upper   = anchor+half
lower   = anchor-half
realPct = half/anchor*100

// VIX-auto implied: pick the matching vol index by symbol family (it's the INDEX's vol)
isSPXfam = syminfo.ticker=="SPX" or syminfo.ticker=="SPY" or syminfo.ticker=="XSP" or syminfo.ticker=="ES1!"
isNDXfam = syminfo.ticker=="QQQ" or syminfo.ticker=="NDX" or syminfo.ticker=="NQ1!"
isRUTfam = syminfo.ticker=="IWM" or syminfo.ticker=="RUT" or syminfo.ticker=="RTY1!"
vixApplies = isSPXfam or isNDXfam or isRUTfam
volSym = isNDXfam ? "CBOE:VXN" : isRUTfam ? "CBOE:RVX" : (vixSource=="VIX (30-day)" ? "CBOE:VIX" : "CBOE:VIX9D")
volIV = request.security(volSym, "D", close, lookahead=barmerge.lookahead_off)
useImpVix = showImp and useVix and vixApplies and not na(volIV)
impMove  = useImpVix ? anchor*volIV/100*math.sqrt(1.0/52) : (impUnit=="Percent" ? anchor*impVal/100 : impVal)
impUpper = anchor+impMove
impLower = anchor-impMove
impPct   = impMove/anchor*100
impOn    = showImp and impMove>0

// ============ OpEx CALENDAR (deterministic = zero repaint, any symbol) ============
f_thirdFri(y, m) =>
    dow1 = dayofweek(timestamp(y, m, 1, 0, 0))
    off  = (dayofweek.friday - dow1 + 7) % 7
    timestamp(y, m, 1 + off + 14, 0, 0)

tfTs    = f_thirdFri(year(time), month(time))
tfDom   = dayofmonth(tfTs)
isQuadM = month(time)==3 or month(time)==6 or month(time)==9 or month(time)==12
isOpEx  = showOpEx and dayofmonth(time)==tfDom
inCharm = showOpEx and showCharm and dayofmonth(time) >= tfDom-5 and dayofmonth(time) < tfDom
nyG = month(time)==12 ? year(time)+1 : year(time)
nmG = month(time)==12 ? 1 : month(time)+1
nextOpExTs = time<=tfTs ? tfTs : f_thirdFri(nyG, nmG)
in14 = show14 and time >= nextOpExTs - 1209600000 and time < nextOpExTs
bgcolor(isOpEx ? (isQuadM ? color.new(quadOpExCol,75) : color.new(monOpExCol,80)) : inCharm ? color.new(isQuadM?quadOpExCol:monOpExCol, 92) : in14 ? color.new(col14, 90) : na)

// ============ DRAW (last bar only -> clean, no historical clutter) ============
var int wkStart = bar_index
if timeframe.change("W")
    wkStart := bar_index

var line  upLine  = na
var line  dnLine  = na
var line  miLine  = na
var line  iuLine  = na
var line  idLine  = na
var line  pwhLine = na
var line  pwlLine = na
var label upLbl   = na
var label dnLbl   = na
var label miLbl   = na
var label iuLbl   = na
var label idLbl   = na
var label pwhLbl  = na
var label pwlLbl  = na
var table dash    = na
var line  mpL1 = na
var line  mpL2 = na
var line  fpL1 = na
var line  fpL2 = na
var label mpLbl = na
var label fpLbl = na
var box   pzb1 = na
var box   pzb2 = na
var box   pzb3 = na
var box   nzb1 = na
var box   nzb2 = na
var box   nzb3 = na

if barstate.islast
    int xR = bar_index + labelOffset

    // ---- realized + implied bands ----
    if not na(avgMove)
        if na(upLine)
            upLine := line.new(wkStart, upper, xR, upper, xloc.bar_index, extend.none, upCol, line.style_solid, lw)
            dnLine := line.new(wkStart, lower, xR, lower, xloc.bar_index, extend.none, dnCol, line.style_solid, lw)
            miLine := line.new(wkStart, anchor, xR, anchor, xloc.bar_index, extend.none, miCol, line.style_dotted, 1)
        else
            line.set_xy1(upLine, wkStart, upper)
            line.set_xy2(upLine, xR, upper)
            line.set_xy1(dnLine, wkStart, lower)
            line.set_xy2(dnLine, xR, lower)
            line.set_xy1(miLine, wkStart, anchor)
            line.set_xy2(miLine, xR, anchor)
        line.set_color(miLine, showMid ? miCol : color.new(miCol, 100))

        if impOn
            if na(iuLine)
                iuLine := line.new(wkStart, impUpper, xR, impUpper, xloc.bar_index, extend.none, impCol, line.style_dashed, lw)
                idLine := line.new(wkStart, impLower, xR, impLower, xloc.bar_index, extend.none, impCol, line.style_dashed, lw)
            else
                line.set_xy1(iuLine, wkStart, impUpper)
                line.set_xy2(iuLine, xR, impUpper)
                line.set_xy1(idLine, wkStart, impLower)
                line.set_xy2(idLine, xR, impLower)

        if showLabels
            prefix = measure=="High-Low Range" ? "1/2 range +/-" : "Avg move +/-"
            miT = prefix + str.tostring(half,"#.#") + " (" + str.tostring(realPct,"#.##") + "%)"
            miT := not na(heldHist) ? miT + " | held " + str.tostring(heldHist,"#.#") + "%" : miT
            miT := impOn ? miT + "\nImplied +/-" + str.tostring(impMove,"#.#") + " (" + str.tostring(impPct,"#.##") + "%) | " + str.tostring(impMove/half,"#.##") + "x avg" : miT
            upT = str.tostring(upper,format.mintick) + "   +" + str.tostring(half,"#.#") + " (+" + str.tostring(realPct,"#.##") + "%)"
            dnT = str.tostring(lower,format.mintick) + "   -" + str.tostring(half,"#.#") + " (-" + str.tostring(realPct,"#.##") + "%)"
            if na(upLbl)
                upLbl := label.new(xR, upper,  upT, xloc.bar_index, yloc.price, color.new(upCol,80), label.style_label_left, upCol, size.normal)
                dnLbl := label.new(xR, lower,  dnT, xloc.bar_index, yloc.price, color.new(dnCol,80), label.style_label_left, dnCol, size.normal)
                miLbl := label.new(xR, anchor, miT, xloc.bar_index, yloc.price, color.new(miCol,80), label.style_label_left, chart.fg_color, size.small)
            else
                label.set_xy(upLbl, xR, upper)
                label.set_text(upLbl, upT)
                label.set_xy(dnLbl, xR, lower)
                label.set_text(dnLbl, dnT)
                label.set_xy(miLbl, xR, anchor)
                label.set_text(miLbl, showMid ? miT : "")
            if impOn
                iuT = str.tostring(impUpper,format.mintick) + "   IM +" + str.tostring(impMove,"#.#") + " (+" + str.tostring(impPct,"#.##") + "%)"
                idT = str.tostring(impLower,format.mintick) + "   IM -" + str.tostring(impMove,"#.#") + " (-" + str.tostring(impPct,"#.##") + "%)"
                if na(iuLbl)
                    iuLbl := label.new(xR, impUpper, iuT, xloc.bar_index, yloc.price, color.new(impCol,80), label.style_label_left, impCol, size.normal)
                    idLbl := label.new(xR, impLower, idT, xloc.bar_index, yloc.price, color.new(impCol,80), label.style_label_left, impCol, size.normal)
                else
                    label.set_xy(iuLbl, xR, impUpper)
                    label.set_text(iuLbl, iuT)
                    label.set_xy(idLbl, xR, impLower)
                    label.set_text(idLbl, idT)

    // ---- prior-week high/low (PWH = dominant draw, emphasized) ----
    if showPW and not na(pwh)
        if na(pwhLine)
            pwhLine := line.new(wkStart, pwh, xR, pwh, xloc.bar_index, extend.none, pwhCol, line.style_solid, lw)
            pwlLine := line.new(wkStart, pwl, xR, pwl, xloc.bar_index, extend.none, pwlCol, line.style_solid, 1)
        else
            line.set_xy1(pwhLine, wkStart, pwh)
            line.set_xy2(pwhLine, xR, pwh)
            line.set_xy1(pwlLine, wkStart, pwl)
            line.set_xy2(pwlLine, xR, pwl)
        if showLabels
            if na(pwhLbl)
                pwhLbl := label.new(xR, pwh, str.tostring(pwh,format.mintick)+"  PWH", xloc.bar_index, yloc.price, color.new(pwhCol,80), label.style_label_left, pwhCol, size.normal)
                pwlLbl := label.new(xR, pwl, str.tostring(pwl,format.mintick)+"  PWL", xloc.bar_index, yloc.price, color.new(pwlCol,80), label.style_label_left, pwlCol, size.normal)
            else
                label.set_xy(pwhLbl, xR, pwh)
                label.set_text(pwhLbl, str.tostring(pwh,format.mintick)+"  PWH")
                label.set_xy(pwlLbl, xR, pwl)
                label.set_text(pwlLbl, str.tostring(pwl,format.mintick)+"  PWL")

    // ---- manual Max Pain & GEX Flip (glow = wide faint halo + crisp core) + gamma zones ----
    int zL = math.max(0, bar_index - 120)
    if maxPain > 0
        int mpX = bar_index + mpLblOff
        if na(mpL1)
            mpL1  := line.new(zL, maxPain, xR, maxPain, xloc.bar_index, extend.none, color.new(mpCol, glowOn?78:100), line.style_solid, 5)
            mpL2  := line.new(zL, maxPain, xR, maxPain, xloc.bar_index, extend.none, mpCol, line.style_solid, 1)
            mpLbl := label.new(mpX, maxPain, "Max Pain "+str.tostring(maxPain, format.mintick), xloc.bar_index, yloc.price, color.new(mpCol,80), label.style_label_left, mpCol, size.normal)
        else
            line.set_xy1(mpL1, zL, maxPain)
            line.set_xy2(mpL1, xR, maxPain)
            line.set_color(mpL1, color.new(mpCol, glowOn?78:100))
            line.set_xy1(mpL2, zL, maxPain)
            line.set_xy2(mpL2, xR, maxPain)
            line.set_color(mpL2, mpCol)
            label.set_xy(mpLbl, mpX, maxPain)
            label.set_text(mpLbl, "Max Pain "+str.tostring(maxPain, format.mintick))

    if gexFlip > 0
        int fpX = bar_index + fpLblOff
        if na(fpL1)
            fpL1  := line.new(zL, gexFlip, xR, gexFlip, xloc.bar_index, extend.none, color.new(flipCol, glowOn?78:100), line.style_solid, 5)
            fpL2  := line.new(zL, gexFlip, xR, gexFlip, xloc.bar_index, extend.none, flipCol, line.style_solid, 1)
            fpLbl := label.new(fpX, gexFlip, "GEX Flip "+str.tostring(gexFlip, format.mintick), xloc.bar_index, yloc.price, color.new(flipCol,80), label.style_label_left, flipCol, size.normal)
        else
            line.set_xy1(fpL1, zL, gexFlip)
            line.set_xy2(fpL1, xR, gexFlip)
            line.set_color(fpL1, color.new(flipCol, glowOn?78:100))
            line.set_xy1(fpL2, zL, gexFlip)
            line.set_xy2(fpL2, xR, gexFlip)
            line.set_color(fpL2, flipCol)
            label.set_xy(fpLbl, fpX, gexFlip)
            label.set_text(fpLbl, "GEX Flip "+str.tostring(gexFlip, format.mintick))

    if pz1t > 0 and pz1b > 0
        if na(pzb1)
            pzb1 := box.new(zL, math.max(pz1t,pz1b), xR, math.min(pz1t,pz1b), border_color=color.new(posCol,50), border_width=1, bgcolor=posCol)
        else
            box.set_lefttop(pzb1, zL, math.max(pz1t,pz1b))
            box.set_rightbottom(pzb1, xR, math.min(pz1t,pz1b))
    if pz2t > 0 and pz2b > 0
        if na(pzb2)
            pzb2 := box.new(zL, math.max(pz2t,pz2b), xR, math.min(pz2t,pz2b), border_color=color.new(posCol,50), border_width=1, bgcolor=posCol)
        else
            box.set_lefttop(pzb2, zL, math.max(pz2t,pz2b))
            box.set_rightbottom(pzb2, xR, math.min(pz2t,pz2b))
    if pz3t > 0 and pz3b > 0
        if na(pzb3)
            pzb3 := box.new(zL, math.max(pz3t,pz3b), xR, math.min(pz3t,pz3b), border_color=color.new(posCol,50), border_width=1, bgcolor=posCol)
        else
            box.set_lefttop(pzb3, zL, math.max(pz3t,pz3b))
            box.set_rightbottom(pzb3, xR, math.min(pz3t,pz3b))
    if nz1t > 0 and nz1b > 0
        if na(nzb1)
            nzb1 := box.new(zL, math.max(nz1t,nz1b), xR, math.min(nz1t,nz1b), border_color=color.new(negCol,50), border_width=1, bgcolor=negCol)
        else
            box.set_lefttop(nzb1, zL, math.max(nz1t,nz1b))
            box.set_rightbottom(nzb1, xR, math.min(nz1t,nz1b))
    if nz2t > 0 and nz2b > 0
        if na(nzb2)
            nzb2 := box.new(zL, math.max(nz2t,nz2b), xR, math.min(nz2t,nz2b), border_color=color.new(negCol,50), border_width=1, bgcolor=negCol)
        else
            box.set_lefttop(nzb2, zL, math.max(nz2t,nz2b))
            box.set_rightbottom(nzb2, xR, math.min(nz2t,nz2b))
    if nz3t > 0 and nz3b > 0
        if na(nzb3)
            nzb3 := box.new(zL, math.max(nz3t,nz3b), xR, math.min(nz3t,nz3b), border_color=color.new(negCol,50), border_width=1, bgcolor=negCol)
        else
            box.set_lefttop(nzb3, zL, math.max(nz3t,nz3b))
            box.set_rightbottom(nzb3, xR, math.min(nz3t,nz3b))

    // ---- dashboard (bottom-right) ----
    if showDash
        cy = year(time)
        cm = month(time)
        thisTF = f_thirdFri(cy, cm)
        ny = cm==12 ? cy+1 : cy
        nm = cm==12 ? 1 : cm+1
        nextTF    = time<=thisTF ? thisTF : f_thirdFri(ny, nm)
        nextMonth = time<=thisTF ? cm : nm
        isQuadNext = nextMonth==3 or nextMonth==6 or nextMonth==9 or nextMonth==12
        daysTo = math.round((nextTF - time)/86400000)
        py1 = cm==1 ? cy-1 : cy
        pm  = cm==1 ? 12 : cm-1
        lastTF = time>thisTF ? thisTF : f_thirdFri(py1, pm)
        daysSince = math.round((time - lastTF)/86400000)
        phase = daysTo<=7 ? (isQuadNext ? "Quad run-in" : "Charm run-in") : (daysSince<=5 ? "Post-OpEx" : "Neutral")
        nMo = month(nextTF)
        nDy = dayofmonth(nextTF)
        nextStr = str.tostring(year(nextTF)) + "-" + (nMo<10?"0":"") + str.tostring(nMo) + "-" + (nDy<10?"0":"") + str.tostring(nDy)
        sz = dashSz=="Small" ? size.small : dashSz=="Large" ? size.large : size.normal
        pcol = phase=="Charm run-in" ? upCol : phase=="Quad run-in" ? quadOpExCol : phase=="Post-OpEx" ? color.new(#ffd54f,0) : color.gray

        if na(dash)
            dash := table.new(position.bottom_right, 2, 11, frame_color=color.new(color.gray,40), frame_width=1, border_color=color.new(color.gray,70), border_width=1)
        hdrbg = color.new(color.gray,70)
        table.cell(dash,0,0,"WEEKLY MOVE", text_color=chart.fg_color, bgcolor=hdrbg, text_size=sz)
        table.cell(dash,1,0,"", bgcolor=hdrbg, text_size=sz)
        table.cell(dash,0,1,"Avg move", text_color=chart.fg_color, text_size=sz)
        table.cell(dash,1,1,"+/-"+str.tostring(half,"#.#")+" ("+str.tostring(realPct,"#.##")+"%)", text_color=upCol, text_size=sz)
        table.cell(dash,0,2,"Implied", text_color=chart.fg_color, text_size=sz)
        table.cell(dash,1,2, impOn ? "+/-"+str.tostring(impMove,"#.#")+" ("+str.tostring(impMove/half,"#.##")+"x)" : "—", text_color=impCol, text_size=sz)
        table.cell(dash,0,3,"Held", text_color=chart.fg_color, text_size=sz)
        table.cell(dash,1,3, na(heldHist) ? "—" : str.tostring(heldHist,"#.#")+"%", text_color=chart.fg_color, text_size=sz)
        table.cell(dash,0,4,"PW High", text_color=chart.fg_color, text_size=sz)
        table.cell(dash,1,4, na(pwh) ? "—" : str.tostring(pwh,format.mintick), text_color=pwhCol, text_size=sz)
        table.cell(dash,0,5,"PW Low", text_color=chart.fg_color, text_size=sz)
        table.cell(dash,1,5, na(pwl) ? "—" : str.tostring(pwl,format.mintick), text_color=pwlCol, text_size=sz)
        table.cell(dash,0,6,"Next OpEx", text_color=chart.fg_color, text_size=sz)
        table.cell(dash,1,6, nextStr+" ("+str.tostring(daysTo)+"d)", text_color=chart.fg_color, text_size=sz)
        table.cell(dash,0,7,"Type", text_color=chart.fg_color, text_size=sz)
        table.cell(dash,1,7, isQuadNext ? "QUAD-WITCH" : "Monthly", text_color=isQuadNext ? quadOpExCol : chart.fg_color, text_size=sz)
        table.cell(dash,0,8,"Phase", text_color=chart.fg_color, text_size=sz)
        table.cell(dash,1,8, phase, text_color=pcol, text_size=sz)
        pwhTrust = syminfo.ticker == "SPX" or syminfo.ticker == "SPY" or syminfo.ticker == "QQQ"
        table.cell(dash,0,9,"PWH", text_color=chart.fg_color, text_size=sz)
        table.cell(dash,1,9, pwhTrust ? "Reliable here" : "Weak — use PWH+PWL", text_color = pwhTrust ? upCol : color.gray, text_size=sz)
        vixLabel  = isNDXfam ? "VXN" : isRUTfam ? "RVX" : (vixSource=="VIX (30-day)" ? "VIX" : "VIX9D")
        vixRegime = na(volIV) ? "—" : volIV<15 ? "calm" : volIV<20 ? "normal" : volIV<30 ? "elevated" : "stress"
        vixCol    = na(volIV) ? color.gray : volIV<15 ? upCol : volIV<20 ? color.gray : volIV<30 ? quadOpExCol : dnCol
        table.cell(dash,0,10, vixApplies ? vixLabel : "VIX", text_color=chart.fg_color, text_size=sz)
        table.cell(dash,1,10, (vixApplies and not na(volIV)) ? str.tostring(volIV,"#.#")+"  "+vixRegime : "n/a here", text_color = vixApplies ? vixCol : color.gray, text_size=sz)
````
