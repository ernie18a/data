# Strong PDH PDL Zones | ProjectSyndicate

- url: https://www.tradingview.com/script/NNhU868w-Strong-PDH-PDL-Zones-ProjectSyndicate/
- type: indicator
- pine_id: PUB;841a6628536f4cd0a7777e040d8b450c
- version: 2.0

## Description

[b]Strong PDH PDL Zones[/b]

Strong PDH PDL Zones power-ranks the daily levels that price keeps reacting to. For every session it plots the prior day's High, Low, and Golden Pocket (the 50–61.8% retracement of the previous day's range) as clean equal-height zones, then scores each High and Low 0–10 from real, measurable level quality — so you instantly know which previous-day level is likely to hold and which is likely to break. It also projects Sweep Trap and Price Breakout lines above PDH and below PDL to frame liquidity grabs and genuine breakouts.

🎯 Power-Ranking System (0–10) — every PDH and PDL earns a live grade from five sign-stable, data-validated factors: prior-day volume vs its baseline, range significance vs ADR, the rejection candle (how far price closed off the extreme), distance from round numbers (levels sitting on round numbers get swept more, so they score lower), and isolation (levels clustered with recent days' extremes break more). The model was prototyped and validated across FX and metals datasets — low-scored levels reacted far less often than high-scored ones, so the number reflects genuine edge, not decoration.
🏷️ In-Zone Strength Labels — each level carries its grade inside the band: stars, the X.X/10 score, and a tier (FORMING → WEAK → MODERATE → STRONG → ELITE). Quality reads instantly without a separate panel.
📐 Previous Day Golden Pocket — the prior session's 50–61.8% fib zone, plotted automatically as the high-probability mean-reversion pocket where intraday pullbacks so often stall.
🚧 Sweep Trap & Price Breakout Lines — two dashed levels above the PDH and two below the PDL. The amber Sweep Trap sits just beyond the level to mark the stop-hunt / liquidity-grab zone; the red Price Breakout sits further out to mark where a move becomes a real breakout rather than a wick. Both are fully offset-adjustable in ATR terms.
⚙️ Uniform ATR Zone Height — every zone (High, Low, Golden Pocket) is normalized to one identical ATR-based thickness, centered on its level, for a clean and consistent look on any instrument or timeframe.

🎨 Strength-Shaded Fill — stronger levels render sharper and more opaque while weak ones stay faint, so the chart shows which levels carry weight before you even read the score.
🧹 Score Filter — hide every level below a score threshold so the chart only carries the levels that earned their place.
🔒 Non-Repainting — each day's levels and scores lock in from the completed prior session and never change intraday. Zones span exactly one session and close cleanly at the day boundary — no bleed into the next session.
🔔 Native Alerts — touch alerts for the PDH zone, PDL zone, and Golden Pocket, plus dedicated alerts for touches of STRONG (≥7/10) PDH and PDL levels, so you never miss a high-quality interaction.
🔧 Fully Customizable — scoring weights and normalizers, zone height, golden-pocket fib bounds, sweep/breakout offsets, colors, transparency, label text and size, and round-number step — all adjustable.

🎯 Why this is different — most "previous day high/low" tools draw three equal-weight lines and leave you to guess which one matters. This one quantifies each level from real prior-day behavior and tells you the probability-weighted answer: a STRONG/ELITE level is one to fade, a WEAK level is one that's likely to give way. The validation work behind the score even informs how you trade each level (see below).
🚀 Apply to Gold (XAUUSD), Silver, Forex, Crypto, and Indices on any intraday timeframe.

[b]🎯 How To Trade It — Two Approaches[/b]

The score is the filter that decides which approach fits. In validation, high-scored levels rejected far more often and low-scored levels broke more often — so play them differently.

[b]1) Break → Sweep Trap → Reversal (fade the trap) — use on STRONG / ELITE levels (≥7)
Best when the PDH or PDL is rated STRONG or ELITE — statistically these are the levels most likely to hold.[/b]

Wait for price to push through the previous-day level and tag the amber Sweep Trap line beyond it (the liquidity grab that takes stops).
Look for failure to reach or hold the red Price Breakout line — i.e. the move stalls inside the trap band and prints rejection back through the level.

Entry: on the reversal back inside the level (a close back below PDH / above PDL).
Stop: just beyond the Price Breakout line — if price reaches it, the trap thesis is wrong and it's a real breakout.

Targets: the Golden Pocket first, then the opposite previous-day level.
Use the Touch STRONG PDH/PDL alert to get notified the moment a high-grade level is being tested.

[b]2) High-Volume Breakout → Trade With the Move — use on WEAK / MODERATE levels
Best when the level is rated WEAK or MODERATE (or formed on low prior-day volume) — these are the levels most likely to break.[/b]

Wait for a decisive break of the PDH or PDL that closes beyond the red Price Breakout line on expanding volume (not a single wick).

The Sweep Trap line being cleared and held is your confirmation that it's a genuine breakout, not a stop-hunt.

Entry: in the direction of the breakout on the close beyond the Price Breakout line (or on a retest of the broken level).

Stop: back inside the level, beyond the Golden Pocket.
Targets: measured-move / next session's range, trailing as the move extends.
A broken PDH flips to support, a broken PDL flips to resistance — the old level often becomes the retest entry.

[b]Rule of thumb: ⭐ STRONG/ELITE → expect a reaction, trade the trap reversal. ⭐ WEAK/MODERATE on volume → expect follow-through, trade the breakout.[/b]

⚠️ IMPORTANT NOTICE: This indicator identifies high-probability previous-day levels and frames trap vs breakout scenarios. It should NOT be used as a standalone signal for entering trades. Always combine it with your own strategy, price-action analysis, and risk management to confirm setups. Past statistical behavior does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("Strong PDH PDL Zones", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

grpZ      = "Zones"
daysStr    = input.string("10", "Days of Zones to Plot", options=["1","2","3","4","5","6","10","25","30"], group=grpZ, tooltip="How many of the most recent completed days keep their zones, golden pockets and dashed levels drawn. Older days are removed from the chart.")
maxDays    = int(str.tonumber(daysStr))
heightLen  = input.int(14, "Universal Height — ATR Length (days)", minval=1, maxval=200, group=grpZ, tooltip="Daily ATR used to size every zone. All zones get the SAME thickness.")
uniHeight  = input.float(0.075, "Universal Zone Height (× daily ATR)", minval=0.02, maxval=3.0, step=0.01, group=grpZ, tooltip="Exact thickness applied to PDH, PDL and Golden Pocket alike, centered on each level.")
extendBars = input.int(0, "Extend Latest Day Zones (bars)", minval=0, maxval=200, group=grpZ)
showLabels = input.bool(true, "Show Labels", group=grpZ)
tintByStr  = input.bool(true, "Shade Zone Opacity by Strength", group=grpZ, tooltip="Stronger levels render more opaque.")

grpGP     = "Golden Pocket (prior day low \u2192 high)"
gpFibLow  = input.float(0.50,  "Lower Fib", minval=0.0, maxval=1.0, step=0.001, group=grpGP)
gpFibHigh = input.float(0.618, "Upper Fib", minval=0.0, maxval=1.0, step=0.001, group=grpGP)

grpS      = "Strength Scoring (0–10)"
adrLen    = input.int(14, "ADR / Volume Baseline (days)", minval=3, maxval=60, group=grpS)
wVol      = input.float(0.30, "Weight: Prior-Day Volume", minval=0, maxval=1, step=0.05, group=grpS, tooltip="Higher prior-day volume = stronger level (validated +, 5/5 symbols).")
wRange    = input.float(0.20, "Weight: Range Significance", minval=0, maxval=1, step=0.05, group=grpS, tooltip="Bigger prior-day range vs ADR = stronger (+).")
wRej      = input.float(0.15, "Weight: Rejection Candle", minval=0, maxval=1, step=0.05, group=grpS, tooltip="Prior day closing away from its extreme = stronger (+).")
wRound    = input.float(0.20, "Weight: Round-Number Distance", minval=0, maxval=1, step=0.05, group=grpS, tooltip="Levels NEAR round numbers reject less (get swept). Distance from round = stronger (validated -, 5/5).")
wConf     = input.float(0.15, "Weight: Isolation (low confluence)", minval=0, maxval=1, step=0.05, group=grpS, tooltip="Levels clustered with recent days' extremes break more. Isolation = stronger (validated -, 4/5).")
volFull   = input.float(1.30, "Full-credit Volume (x avg)", minval=1.0, maxval=4.0, step=0.05, group=grpS)
rngFull   = input.float(1.40, "Full-credit Range (x ADR)", minval=1.0, maxval=4.0, step=0.05, group=grpS)
rejFull   = input.float(0.60, "Full-credit Rejection (frac of range)", minval=0.1, maxval=1.0, step=0.05, group=grpS)
roundStepIn = input.float(0.0, "Round-Number Step (0 = auto)", minval=0.0, group=grpS)
minScore  = input.float(0.0, "Hide Levels Below Score", minval=0.0, maxval=10.0, step=0.5, group=grpS)

grpL      = "Labels"
txtHigh   = input.string("PREVIOUS DAY HIGH", "PDH Text", group=grpL)
txtLow    = input.string("PREVIOUS DAY LOW",  "PDL Text", group=grpL)
txtGP     = input.string("PREVIOUS DAY GOLDEN POCKET",  "Golden Pocket Text", group=grpL)
showStars = input.bool(true, "Show Stars & Tier", group=grpL)
labelSz   = input.string("normal", "Label Size", options=["tiny","small","normal","large"], group=grpL)

grpLv     = "Dashed Levels"
showLevels = input.bool(true, "Show Dashed Levels", group=grpLv)
sweepMult  = input.float(0.10, "Sweep Trap Offset (× daily ATR)", minval=0.0, maxval=5.0, step=0.01, group=grpLv, tooltip="Distance of the SWEEP TRAP lines above PDH / below PDL. Lower = closer.")
breakMult  = input.float(0.35, "Price Breakout Offset (× daily ATR)", minval=0.0, maxval=5.0, step=0.01, group=grpLv, tooltip="Distance of the PRICE BREAKOUT lines above PDH / below PDL. Lower = closer.")
txtSweep   = input.string("SWEEP TRAP LEVEL", "Sweep Trap Text", group=grpLv)
txtBreak   = input.string("PRICE BREAKOUT LEVEL", "Price Breakout Text", group=grpLv)
sweepCol   = input.color(#E0A52E, "Sweep Trap Color", group=grpLv)
breakCol   = input.color(#BE3B3B, "Price Breakout Color", group=grpLv)
lvWidth    = input.int(2, "Line Width", minval=1, maxval=5, group=grpLv)
lvLabelSz  = input.string("normal", "Level Label Size", options=["tiny","small","normal","large","huge"], group=grpLv)
lvTxtColor = input.color(#A8A8A8, "Level Label Text", group=grpLv)

grpC      = "Colors"
highColor = input.color(#0D5447, "PDH Zone", group=grpC)
gpColor   = input.color(#787878, "Golden Pocket Zone", group=grpC)
lowColor  = input.color(#6E1E28, "PDL Zone", group=grpC)
gpTransp  = input.int(72, "Golden Pocket Transparency", minval=40, maxval=96, group=grpC)
baseTransp = input.int(58, "Zone Transparency (weakest)", minval=40, maxval=96, group=grpC)
txtColor  = input.color(#CFCFCF, "Label Text", group=grpC)
showBorder = input.bool(false, "Show Zone Borders", group=grpC)
borderCol = input.color(color.new(#9A9A9A, 60), "Border Color", group=grpC)

// One day's drawing objects, so older days can be removed when the day limit is exceeded
type DayDraw
    box   bHigh = na
    box   bGP   = na
    box   bLow  = na
    label lHigh = na
    label lGP   = na
    label lLow  = na
    line  nUS   = na
    line  nUB   = na
    line  nLS   = na
    line  nLB   = na
    label aUS   = na
    label aUB   = na
    label aLS   = na
    label aLB   = na

f_deleteDay(DayDraw d) =>
    if not na(d.bHigh)
        box.delete(d.bHigh)
    if not na(d.bGP)
        box.delete(d.bGP)
    if not na(d.bLow)
        box.delete(d.bLow)
    if not na(d.lHigh)
        label.delete(d.lHigh)
    if not na(d.lGP)
        label.delete(d.lGP)
    if not na(d.lLow)
        label.delete(d.lLow)
    if not na(d.nUS)
        line.delete(d.nUS)
    if not na(d.nUB)
        line.delete(d.nUB)
    if not na(d.nLS)
        line.delete(d.nLS)
    if not na(d.nLB)
        line.delete(d.nLB)
    if not na(d.aUS)
        label.delete(d.aUS)
    if not na(d.aUB)
        label.delete(d.aUB)
    if not na(d.aLS)
        label.delete(d.aLS)
    if not na(d.aLB)
        label.delete(d.aLB)

f_size() => labelSz=="tiny" ? size.tiny : labelSz=="small" ? size.small : labelSz=="large" ? size.large : size.normal
f_lvSize() => lvLabelSz=="tiny" ? size.tiny : lvLabelSz=="small" ? size.small : lvLabelSz=="normal" ? size.normal : lvLabelSz=="huge" ? size.huge : size.large
f_stars(s) => s>=8 ? "★★★★" : s>=6.5 ? "★★★" : s>=5 ? "★★" : s>=3 ? "★" : "·"
f_tier(s)  => s>=8 ? "ELITE" : s>=6.5 ? "STRONG" : s>=5 ? "MODERATE" : s>=3 ? "WEAK" : "FORMING"

f_roundStep(float px) =>
    roundStepIn > 0 ? roundStepIn : math.pow(10.0, math.floor(math.log10(math.max(px, 1e-9))) - 2.0)

f_roundProx(float level, float px) =>
    step = f_roundStep(px)
    d = math.abs(level - math.round(level/step)*step) / step
    1.0 - math.min(d/0.5, 1.0)

var float dHigh = na
var float dLow  = na
var float dVol  = na

var array<DayDraw> drawDays = array.new<DayDraw>()

var array<float> rngHist = array.new<float>()
var array<float> volHist = array.new<float>()
var array<float> hiHist  = array.new<float>()
var array<float> loHist  = array.new<float>()

var int   abLeft = na
var box   abHigh = na
var box   abGP   = na
var box   abLow  = na
var label alHigh = na
var label alGP   = na
var label alLow  = na

var line  lnUS = na
var line  lnUB = na
var line  lnLS = na
var line  lnLB = na
var label laUS = na
var label laUB = na
var label laLS = na
var label laLB = na

newDay = ta.change(time("D")) != 0

f_avg(array<float> a, int n) =>
    sz = array.size(a)
    cnt = math.min(sz, n)
    s = 0.0
    if cnt > 0
        for k = 0 to cnt-1
            s += array.get(a, k)
    cnt > 0 ? s/cnt : na

f_confluence(array<float> a, float level, float tol) =>
    sz = array.size(a)
    cnt = math.min(sz, 5)
    c = 0
    if cnt > 0
        for k = 0 to cnt-1
            if math.abs(array.get(a, k) - level) <= tol
                c += 1
    c

f_score(float rejFrac, float volR, float rangeR, float level, float px, int confN) =>
    volSc = math.min(math.max(volR,0.0) / math.max(volFull,1.0), 1.0)
    rngSc = math.min(math.max(rangeR,0.0) / math.max(rngFull,1.0), 1.0)
    rejSc = math.min(math.max(rejFrac,0.0) / math.max(rejFull,0.1), 1.0)
    rndSc = 1.0 - f_roundProx(level, px)
    confSc = 1.0 - math.min(confN/2.0, 1.0)
    wTot = wVol + wRange + wRej + wRound + wConf
    raw = wTot>0 ? (wVol*volSc + wRange*rngSc + wRej*rejSc + wRound*rndSc + wConf*confSc)/wTot : 0.0
    math.round(math.min(math.max(raw,0.0),1.0) * 100.0) / 10.0

f_transp(float sc) =>
    t = tintByStr ? baseTransp - (sc/10.0)*30.0 : baseTransp - 12.0
    math.round(math.max(math.min(t, 96.0), 30.0))

f_centerLabel(label lb, int leftB, int rightB) =>
    if not na(lb)
        label.set_x(lb, math.round((leftB + rightB)/2.0))

var float scHighActive = na
var float scLowActive  = na

if newDay
    boundaryBar = bar_index
    prevEnd = bar_index - 1

    if not na(abHigh)
        box.set_right(abHigh, prevEnd)
        box.set_right(abGP, prevEnd)
        box.set_right(abLow, prevEnd)
        f_centerLabel(alHigh, abLeft, prevEnd)
        f_centerLabel(alGP, abLeft, prevEnd)
        f_centerLabel(alLow, abLeft, prevEnd)
    if not na(lnUS)
        line.set_x2(lnUS, prevEnd)
        line.set_x2(lnUB, prevEnd)
        line.set_x2(lnLS, prevEnd)
        line.set_x2(lnLB, prevEnd)
        f_centerLabel(laUS, abLeft, prevEnd)
        f_centerLabel(laUB, abLeft, prevEnd)
        f_centerLabel(laLS, abLeft, prevEnd)
        f_centerLabel(laLB, abLeft, prevEnd)

    prevH = dHigh
    prevL = dLow
    prevC = close[1]
    prevV = dVol

    valid = not na(prevH) and not na(prevL) and prevH > prevL and not na(prevC)

    if valid
        rng = prevH - prevL

        array.unshift(rngHist, rng)
        array.unshift(volHist, na(prevV) ? na : prevV)
        if array.size(rngHist) > 60
            array.pop(rngHist)
            array.pop(volHist)

        adr   = f_avg(rngHist, adrLen)
        avgV  = f_avg(volHist, adrLen)
        tol   = na(adr) ? rng*0.10 : adr*0.10
        volR  = (not na(avgV) and avgV>0 and not na(prevV)) ? prevV/avgV : 1.0
        rangeR = (not na(adr) and adr>0) ? rng/adr : 1.0

        confH = f_confluence(hiHist, prevH, tol)
        confL = f_confluence(loHist, prevL, tol)

        rejH = (prevH - prevC)/rng
        rejL = (prevC - prevL)/rng

        scH = f_score(rejH, volR, rangeR, prevH, prevC, confH)
        scL = f_score(rejL, volR, rangeR, prevL, prevC, confL)
        scHighActive := scH
        scLowActive  := scL

        array.unshift(hiHist, prevH)
        array.unshift(loHist, prevL)
        if array.size(hiHist) > 20
            array.pop(hiHist)
            array.pop(loHist)

        atrD   = f_avg(rngHist, heightLen)
        zh     = (not na(atrD) and atrD > 0 ? atrD : rng) * uniHeight
        halfH  = zh / 2.0
        gpMid  = prevL + rng * ((gpFibLow + gpFibHigh) / 2.0)
        gpU = gpMid + halfH
        gpL = gpMid - halfH

        bw = showBorder ? 1 : 0

        showH = scH >= minScore
        showL = scL >= minScore

        abLeft := boundaryBar
        if showH
            abHigh := box.new(boundaryBar, prevH+halfH, boundaryBar, prevH-halfH, border_color=showBorder?borderCol:color.new(color.gray,100), border_width=bw, bgcolor=color.new(highColor, f_transp(scH)))
        else
            abHigh := na
        abGP := box.new(boundaryBar, gpU, boundaryBar, gpL, border_color=showBorder?borderCol:color.new(color.gray,100), border_width=bw, bgcolor=color.new(gpColor, gpTransp))
        if showL
            abLow := box.new(boundaryBar, prevL+halfH, boundaryBar, prevL-halfH, border_color=showBorder?borderCol:color.new(color.gray,100), border_width=bw, bgcolor=color.new(lowColor, f_transp(scL)))
        else
            abLow := na

        if showLabels
            sH = showStars ? "  " + f_stars(scH) + "  " + str.tostring(scH,"#.0") + "/10 (" + f_tier(scH) + ")" : "  " + str.tostring(scH,"#.0") + "/10"
            sL = showStars ? "  " + f_stars(scL) + "  " + str.tostring(scL,"#.0") + "/10 (" + f_tier(scL) + ")" : "  " + str.tostring(scL,"#.0") + "/10"
            alHigh := showH ? label.new(boundaryBar, prevH, txtHigh + sH, xloc=xloc.bar_index, color=color.new(color.gray,100), textcolor=txtColor, style=label.style_none, size=f_size(), textalign=text.align_center) : na
            alGP   := label.new(boundaryBar, gpMid, txtGP, xloc=xloc.bar_index, color=color.new(color.gray,100), textcolor=txtColor, style=label.style_none, size=f_size(), textalign=text.align_center)
            alLow  := showL ? label.new(boundaryBar, prevL, txtLow + sL, xloc=xloc.bar_index, color=color.new(color.gray,100), textcolor=txtColor, style=label.style_none, size=f_size(), textalign=text.align_center) : na
        else
            alHigh := na
            alGP := na
            alLow := na

        if showLevels
            usY = prevH + atrD*sweepMult
            ubY = prevH + atrD*breakMult
            lsY = prevL - atrD*sweepMult
            lbY = prevL - atrD*breakMult
            lnUS := line.new(boundaryBar, usY, boundaryBar, usY, xloc=xloc.bar_index, color=sweepCol, width=lvWidth, style=line.style_dashed)
            lnUB := line.new(boundaryBar, ubY, boundaryBar, ubY, xloc=xloc.bar_index, color=breakCol, width=lvWidth, style=line.style_dashed)
            lnLS := line.new(boundaryBar, lsY, boundaryBar, lsY, xloc=xloc.bar_index, color=sweepCol, width=lvWidth, style=line.style_dashed)
            lnLB := line.new(boundaryBar, lbY, boundaryBar, lbY, xloc=xloc.bar_index, color=breakCol, width=lvWidth, style=line.style_dashed)
            laUS := label.new(boundaryBar, usY, txtSweep, xloc=xloc.bar_index, color=color.new(color.gray,100), textcolor=lvTxtColor, style=label.style_none, size=f_lvSize(), textalign=text.align_center)
            laUB := label.new(boundaryBar, ubY, txtBreak, xloc=xloc.bar_index, color=color.new(color.gray,100), textcolor=lvTxtColor, style=label.style_none, size=f_lvSize(), textalign=text.align_center)
            laLS := label.new(boundaryBar, lsY, txtSweep, xloc=xloc.bar_index, color=color.new(color.gray,100), textcolor=lvTxtColor, style=label.style_none, size=f_lvSize(), textalign=text.align_center)
            laLB := label.new(boundaryBar, lbY, txtBreak, xloc=xloc.bar_index, color=color.new(color.gray,100), textcolor=lvTxtColor, style=label.style_none, size=f_lvSize(), textalign=text.align_center)
        else
            lnUS := na
            lnUB := na
            lnLS := na
            lnLB := na
            laUS := na
            laUB := na
            laLS := na
            laLB := na

        array.push(drawDays, DayDraw.new(bHigh=abHigh, bGP=abGP, bLow=abLow, lHigh=alHigh, lGP=alGP, lLow=alLow, nUS=lnUS, nUB=lnUB, nLS=lnLS, nLB=lnLB, aUS=laUS, aUB=laUB, aLS=laLS, aLB=laLB))
        while array.size(drawDays) > maxDays
            f_deleteDay(array.shift(drawDays))
    else
        abHigh := na
        abGP := na
        abLow := na
        alHigh := na
        alGP := na
        alLow := na
        lnUS := na
        lnUB := na
        lnLS := na
        lnLB := na

    dHigh := high
    dLow  := low
    dVol  := volume
else
    dHigh := na(dHigh) ? high : math.max(dHigh, high)
    dLow  := na(dLow)  ? low  : math.min(dLow, low)
    dVol  := na(dVol)  ? volume : dVol + volume
    if not na(abGP)
        rightB = bar_index + (barstate.islast ? extendBars : 0)
        if not na(abHigh)
            box.set_right(abHigh, rightB)
        box.set_right(abGP, rightB)
        if not na(abLow)
            box.set_right(abLow, rightB)
        f_centerLabel(alHigh, abLeft, rightB)
        f_centerLabel(alGP, abLeft, rightB)
        f_centerLabel(alLow, abLeft, rightB)
        if not na(lnUS)
            line.set_x2(lnUS, rightB)
            line.set_x2(lnUB, rightB)
            line.set_x2(lnLS, rightB)
            line.set_x2(lnLB, rightB)
            f_centerLabel(laUS, abLeft, rightB)
            f_centerLabel(laUB, abLeft, rightB)
            f_centerLabel(laLS, abLeft, rightB)
            f_centerLabel(laLB, abLeft, rightB)

touchH = not na(abHigh) and high >= box.get_bottom(abHigh) and low <= box.get_top(abHigh)
touchL = not na(abLow)  and high >= box.get_bottom(abLow)  and low <= box.get_top(abLow)
touchG = not na(abGP)   and high >= box.get_bottom(abGP)   and low <= box.get_top(abGP)
alertcondition(touchH, "Touch PDH Zone", "Price touched the Previous Day High zone")
alertcondition(touchL, "Touch PDL Zone", "Price touched the Previous Day Low zone")
alertcondition(touchG, "Touch Golden Pocket", "Price touched the prior-day Golden Pocket")
alertcondition(touchH and scHighActive >= 7.0, "Touch STRONG PDH", "Price touched a STRONG (≥7) Previous Day High")
alertcondition(touchL and scLowActive  >= 7.0, "Touch STRONG PDL", "Price touched a STRONG (≥7) Previous Day Low")
````
