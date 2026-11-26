# Dealer Volume

- url: https://www.tradingview.com/script/T3v3hfXP-Dealer-Volume/
- type: indicator
- pine_id: PUB;e05a8354592c4ac98b4787f6d9ca1fdc
- version: 2.0

## Description

Dealer Volume transforms ordinary volume into a real-time map of who is actually trading and where it matters most.

Standard volume indicators show you HOW MUCH traded. Dealer Volume shows you WHO was forced to trade and WHERE.

Every volume bar is analyzed through the lens of options dealer mechanics and gamma physics. The result is a five-tier visual hierarchy that instantly separates institutional positioning from retail noise.

[b]The five visual tiers[/b]
Each bar communicates through three simultaneous visual channels — physical width, color intensity, and luminous glow — so you can read the story at a glance:

[b]MEGA DEALER PRINT [/b]— Massive volume at a critical gamma level. Renders as a chunky solid jewel core wrapped in a double halo of glow with a bright neon center stripe. These are the rarest, most important prints. The dealer desk is being forced to hedge mechanically and you can see it on the tape.

[b]DEALER PRINT [/b]— Elevated volume at a gamma level, absorption events, climactic volume, or aggressive institutional buying or selling. Renders as a chunky solid core wrapped in a warm glowing halo. Mechanical hedging in progress.

[b]STRONG [/b]— Above-average volume without dealer signature. Renders as a solid bright bar in vibrant emerald or ruby. Real directional flow.

[b]NORMAL[/b] — Average volume. Renders as a thin semi-transparent bar in soft tones. Background market activity.

[b]WEAK[/b] — Below-average volume. Renders as a hair-thin ghost bar that recedes into the chart. Quiet flow.

[b]Delta Volume Mode[/b] (toggleable) mirrors bars around a zero baseline — green bars grow upward, red bars grow downward. This is how professional desks render volume because direction and imbalance become immediately readable from the histogram shape itself.

[b]The indicator monitors five distinct gamma zones simultaneously: [/b]
Call Wall, Put Wall, GEX Flip, and the two inner gravity centers (M2c and M2p). When elevated volume hits any of these zones, dealers are being forced to hedge — and you see it the instant it happens.

[b]Built-in alerts:[/b]

Mega Dealer Print
Dealer Print
Climactic Volume
Absorption Detected
Institutional Buying
Institutional Selling


[b]How To Utilize[/b]
Step 1 — Add to chart
Apply to any timeframe on liquid US equity, index, or futures instruments (SPY, SPX, ES, QQQ, NDX, NQ, IWM, etc.). The indicator auto-detects the symbol and calibrates its gamma zones at the first bar of each regular trading hours session.

Step 2 — Read the bars
The chart curates itself. Your eye will naturally land on the glowing chunky bars. Those are the prints that matter.

A row of thin ghost bars with a single GLOWING bar interrupting them — that's where dealers got involved.

A solid bright bar without glow — real money is committed but not at a gamma level.
Hair-thin ghost bars across the chart — quiet flow, low conviction environment.

Step 3 — Trade the cluster
The most powerful setups happen when 2-3 dealer prints cluster in a short window. This signals institutional positioning being built at a specific level. Trade the resolution — either the level holds (cluster fades, price reverses) or the level fails (cluster precedes breakout).

Step 4 — Confirm with price action
A mega dealer print is not a signal to enter — it's a signal to PAY ATTENTION. The bar tells you something forced just happened. Confirm with your usual entry triggers (candle close, structure break, etc.) before acting.

Step 5 — Use alerts for hands-off monitoring
Set the "Mega Dealer Print" alert on your watchlist symbols. You'll get notified the moment a major institutional event hits a gamma zone — even if you're away from the screen.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TheRealDrip2Rip

//@version=5
indicator("Volume Profile + VAH, VAL, and POC", overlay=true, max_boxes_count=500, max_lines_count=500)

// ───────────────────────────────────────── Theme
grpTheme = "Theme"
stealthMode = input.bool(false, "Stealth Mode", group=grpTheme, tooltip="Switch to a muted grayscale palette. Great on dark charts.")

// ───────────────────────────────────────── Core
grpCore = "Core"
bins      = input.int(50,  "Price Bins",        minval=10,  maxval=300,   group=grpCore)
barsBack  = input.int(500, "Lookback (Bars)",   minval=50,  maxval=500, group=grpCore)

// ───────────────────────────────────────── Layout
grpLayout = "Layout"
profilePos = input.string("Right of Price", "Profile Position",
     options=["Right of Price","Inside Right","Inside Left"], group=grpLayout,
     tooltip="Where the profile renders relative to your Bars Back window.")
insideRightPadBars = input.int(15, "Inside Right Offset (bars)", minval=0, maxval=200, group=grpLayout,
     tooltip="How many bars to the RIGHT of the current candle to anchor Inside Right (profile extends left).")
insideLeftPadBars  = input.int(2,  "Inside Left Offset (bars)",  minval=0, maxval=100,  group=grpLayout,
     tooltip="Added to the 9:30 ET anchor when using Inside Left.")

// ───────────────────────────────────────── Style
grpStyle = "Style"
profileWidthBars = input.int(30, "Profile Width (bars)", minval=5, maxval=200, group=grpStyle)
binBorderWidth   = input.int(1,  "Bin Border Width",     minval=1, maxval=4,   group=grpStyle)

// ───────────────────────────────────────── Markers & Lines
grpLines = "Markers & Lines"
showPOC     = input.bool(true,  "Show POC",      group=grpLines)
showVAHL    = input.bool(true,  "Show VAH/VAL",  group=grpLines)
vaPercent   = input.float(70.0, "Value Area %",  minval=10, maxval=99, step=0.5, group=grpLines)
vaLineWidth = input.int(1,      "VA Line Width", minval=1, maxval=4,            group=grpLines)

// Per-line extension side
pocExtendOpt = input.string("None", "POC Extend", options=["None","Right","Left","Both"], group=grpLines)
vahExtendOpt = input.string("None", "VAH Extend", options=["None","Right","Left","Both"], group=grpLines)
valExtendOpt = input.string("None", "VAL Extend", options=["None","Right","Left","Both"], group=grpLines)
// Extend distance mode
extendMode        = input.string("Infinite", "Line Extend Mode", options=["Infinite","Custom (bars)"], group=grpLines,tooltip="Infinite = TradingView extend.*. Custom = extend by a fixed number of bars.")
customExtendBars  = input.int(100, "Custom Extend Bars", minval=1, maxval=500, step=5, group=grpLines,tooltip="How many bars to add on the selected side(s) when using Custom (bars).")

// ───────────────────────────────────────── Regime Signal
grpReg = "Regime Signal"
useRegime      = input.bool(true, "Show Bull/Bear Regime", group=grpReg,tooltip="Determines trend state from the volume profile and shows it in a table.")
regSmoothLen   = input.int(21, "Smoothing (bars)", minval=1, maxval=200, group=grpReg,tooltip="Higher = steadier regime, slower to flip.")
regBand        = input.float(0.25, "Hysteresis Band", minval=0.05, maxval=0.9, step=0.05, group=grpReg, tooltip="Bull if score > +band, Bear if < -band; else hold.")
showRegTable   = input.bool(true, "Show Regime Table", group=grpReg)

// ───────────────────────────────────────── Advanced
grpAdv = "Advanced"
distributeAcross = input.bool(true, "Distribute Volume Across Bar Range (Hi–Lo)", group=grpAdv,tooltip="More accurate: spreads each bar’s volume across all price bins it overlaps.")
splitMethod = input.string("Body Proportional", "Buy/Sell Split Method",options=["Up/Down Candle","Body Proportional"], group=grpAdv,tooltip="Up/Down: 100% buy if bar closes up, else 100% sell. Body Proportional: split by |close-open| shares.")

// ───────────────────────────────────────── Internals
src = hlc3
showBinBorder = true
binBorderColor_in = color.new(#09090a, 0)

// Normal palette
buyColor_norm  = color.new(color.lime, 60)
sellColor_norm = color.new(color.red,  60)
pocColor_norm  = color.new(color.orange, 0)
vaLine_norm    = color.new(color.yellow, 0)

// Stealth palette
buyColor_stealth  = color.new(color.rgb(190,195,205), 65)
sellColor_stealth = color.new(color.rgb(125,130,140), 65)
pocColor_stealth  = color.new(color.rgb(235,235,240),  0)
vaLine_stealth    = color.new(color.rgb(165,170,180),  0)
border_stealth    = color.new(color.rgb(90,95,105),    0)

// Effective colors
colBuy    = stealthMode ? buyColor_stealth  : buyColor_norm
colSell   = stealthMode ? sellColor_stealth : sellColor_norm
colPOC    = stealthMode ? pocColor_stealth  : pocColor_norm
colVA     = stealthMode ? vaLine_stealth    : vaLine_norm
colBorder = stealthMode ? border_stealth    : binBorderColor_in

// ───────────────────────────────────────── Drawing/State
var box[] boxes = array.new_box()
var line pocLine = na
var line vahLine = na
var line valLine = na

// Regime state & table
var float rgmScoreSm = na
var int   rgmState   = 0           // -1 Bear, 0 Neutral, 1 Bull
var table rgmTbl     = na
if showRegTable and na(rgmTbl)
    rgmTbl := table.new(position.top_right, 1, 1)

// ───────────────────────────────────────── Helpers
f_clear_boxes() =>
    int sz = array.size(boxes)
    if sz > 0
        for j = 0 to sz - 1
            box b = array.get(boxes, j)
            if not na(b)
                box.delete(b)
    array.clear(boxes)

f_clamp_int(v, lo, hi) =>
    v < lo ? lo : v > hi ? hi : v

f_to_extend(s) =>
    s == "Right" ? extend.right :
     s == "Left" ? extend.left  :
     s == "Both" ? extend.both  : extend.none

// Stable tanh replacement (for environments without math.tanh)
f_tanh(x) =>
    float xx = math.max(-10.0, math.min(10.0, x))
    float e2x = math.exp(2.0 * xx)
    (e2x - 1.0) / (e2x + 1.0)

// ───────────────────────────────────────── Main (compute at last bar)
if barstate.islast
    int barsToScan = math.min(barsBack, bar_index + 1)
    int startIdx   = bar_index - barsToScan + 1

    // Window price range (typed)
    float minP = na
    float maxP = na
    for i = 0 to barsToScan - 1
        float lo = low[i]
        float hi = high[i]
        minP := na(minP) ? lo : math.min(minP, lo)
        maxP := na(maxP) ? hi : math.max(maxP, hi)

    if not na(minP) and not na(maxP) and maxP > minP
        float step = (maxP - minP) / bins

        // Volume bins (buy/sell)
        var float[] buyVols  = array.new_float()
        var float[] sellVols = array.new_float()
        array.clear(buyVols), array.clear(sellVols)
        for _ = 0 to bins - 1
            array.push(buyVols,  0.0), array.push(sellVols, 0.0)

        // Accumulate buy/sell per bin
        for i = 0 to barsToScan - 1
            float hi_   = high[i]
            float lo_   = low[i]
            float vol   = volume[i]
            float rng   = hi_ - lo_

            // Split fractions
            float bullFrac = 0.0
            float bearFrac = 1.0
            if splitMethod == "Up/Down Candle"
                bullFrac := close[i] >= open[i] ? 1.0 : 0.0
                bearFrac := 1.0 - bullFrac
            else
                float bodyUp   = math.max(close[i] - open[i], 0.0)
                float bodyDown = math.max(open[i] - close[i], 0.0)
                float bodySum  = bodyUp + bodyDown
                if bodySum > 0
                    bullFrac := bodyUp / bodySum
                    bearFrac := bodyDown / bodySum
                else
                    bullFrac := 0.5
                    bearFrac := 0.5

            if distributeAcross and rng > 0 and step > 0
                int startBin = f_clamp_int(int(math.floor((lo_ - minP) / step)), 0, bins - 1)
                int endBin   = f_clamp_int(int(math.floor((hi_ - minP) / step)), 0, bins - 1)
                for b = startBin to endBin
                    float binLo = minP + b * step
                    float binHi = binLo + step
                    float overLo = math.max(lo_, binLo)
                    float overHi = math.min(hi_, binHi)
                    float overlap = math.max(overHi - overLo, 0.0)
                    if overlap > 0
                        float share  = overlap / rng
                        float vShare = vol * share
                        array.set(buyVols,  b, array.get(buyVols,  b) + vShare * bullFrac)
                        array.set(sellVols, b, array.get(sellVols, b) + vShare * bearFrac)
            else
                float px  = src[i]
                int   idx = f_clamp_int(int(math.floor((px - minP) / step)), 0, bins - 1)
                array.set(buyVols,  idx, array.get(buyVols,  idx) + vol * bullFrac)
                array.set(sellVols, idx, array.get(sellVols, idx) + vol * bearFrac)

        // Totals & POC
        var float[] totals = array.new_float()
        array.clear(totals)
        float totalVolSum = 0.0
        float maxVol = 0.0
        int   pocIdx = 0
        for b = 0 to bins - 1
            float tot = array.get(buyVols, b) + array.get(sellVols, b)
            array.push(totals, tot)
            totalVolSum += tot
            if tot > maxVol
                maxVol := tot
                pocIdx := b

        // Value Area from POC
        float target = totalVolSum * (vaPercent / 100.0)
        int   left  = pocIdx
        int   right = pocIdx
        float cum   = array.get(totals, pocIdx)
        while cum < target and (left > 0 or right < bins - 1)
            float leftVol  = left  > 0        ? array.get(totals, left  - 1) : -1.0
            float rightVol = right < bins - 1 ? array.get(totals, right + 1) : -1.0
            bool  useRight = rightVol >= leftVol
            if useRight and right < bins - 1
                right += 1
                cum   += array.get(totals, right)
            else if left > 0
                left  -= 1
                cum   += array.get(totals, left)
            else
                break
        float vaLow  = minP + left  * step
        float vaHigh = minP + (right + 1) * step

        // Clear previous drawings
        f_clear_boxes()
        if not na(pocLine)  
            line.delete(pocLine),  pocLine := na
        if not na(vahLine)  
            line.delete(vahLine),  vahLine := na
        if not na(valLine)  
            line.delete(valLine),  valLine := na

        // ───────────────────────────────────── Placement (Inside Left locks to 9:30 ET)
        string tzNY = "America/New_York"
        int yNY = year(time, tzNY), mNY = month(time, tzNY), dNY = dayofmonth(time, tzNY)
        int open930Idx = na
        for i = 0 to barsToScan - 1
            bool sameDay = (year(time[i], tzNY) == yNY) and (month(time[i], tzNY) == mNY) and (dayofmonth(time[i], tzNY) == dNY)
            bool is930   = (hour(time[i], tzNY) == 9) and (minute(time[i], tzNY) == 30)
            if sameDay and is930
                open930Idx := bar_index - i
                break

        int lineX1 = na, int lineX2 = na
        if profilePos == "Right of Price"
            lineX1 := bar_index + 1
            lineX2 := bar_index + 1 + profileWidthBars + 1
        else if profilePos == "Inside Right"
            int anchorR = bar_index + insideRightPadBars
            lineX1 := anchorR - profileWidthBars
            lineX2 := anchorR
        else
            int anchorL = na(open930Idx) ? (startIdx + insideLeftPadBars) : (open930Idx + insideLeftPadBars)
            lineX1 := anchorL
            lineX2 := anchorL + profileWidthBars

        // ───────────────────────────────────── Draw profile at chosen location
        for b = 0 to bins - 1
            float buyV = array.get(buyVols,  b)
            float sellV= array.get(sellVols, b)
            float totV = buyV + sellV
            if totV > 0 and maxVol > 0
                float y1 = minP + b * step
                float y2 = y1 + step
                int   wTot = int(math.round(profileWidthBars * (totV / maxVol)))
                if wTot > 0
                    int leftEdge = na, int rightEdge = na
                    if profilePos == "Right of Price"
                        leftEdge  := bar_index + 1
                        rightEdge := leftEdge + wTot
                    else if profilePos == "Inside Right"
                        rightEdge := bar_index + insideRightPadBars
                        leftEdge  := rightEdge - wTot
                    else
                        int anchorLeft = na(open930Idx) ? (startIdx + insideLeftPadBars) : (open930Idx + insideLeftPadBars)
                        leftEdge  := anchorLeft
                        rightEdge := leftEdge + wTot

                    int buyW  = int(math.round(wTot * (buyV / totV)))
                    int sellW = wTot - buyW
                    if sellW > 0
                        box bxS = box.new(leftEdge, y2, leftEdge + sellW, y1, xloc=xloc.bar_index, bgcolor=colSell, border_color=na)
                        array.push(boxes, bxS)
                    if buyW > 0
                        box bxB = box.new(leftEdge + sellW, y2, leftEdge + sellW + buyW, y1, xloc=xloc.bar_index, bgcolor=colBuy, border_color=na)
                        array.push(boxes, bxB)
                    if showBinBorder
                        box bxO = box.new(leftEdge, y2, leftEdge + wTot, y1, xloc=xloc.bar_index, bgcolor=color.new(color.black, 100), border_color=colBorder)
                        box.set_border_width(bxO, binBorderWidth)
                        array.push(boxes, bxO)

        // ───────────────────────────────────── Lines (Infinite vs Custom length)
        if showPOC and maxVol > 0
            float pocPrice = minP + (pocIdx + 0.5) * step
            if extendMode == "Infinite"
                pocLine := line.new(lineX1, pocPrice, lineX2, pocPrice, xloc=xloc.bar_index, extend=f_to_extend(pocExtendOpt), color=colPOC, width=2)
            else
                int lAdd = (pocExtendOpt == "Left" or pocExtendOpt == "Both")  ? customExtendBars : 0
                int rAdd = (pocExtendOpt == "Right" or pocExtendOpt == "Both") ? customExtendBars : 0
                int px1  = math.max(0, lineX1 - lAdd)
                int px2  = lineX2 + rAdd
                pocLine := line.new(px1, pocPrice, px2, pocPrice, xloc=xloc.bar_index, extend=extend.none, color=colPOC, width=2)

        if showVAHL
            if extendMode == "Infinite"
                vahLine := line.new(lineX1, vaHigh, lineX2, vaHigh, xloc=xloc.bar_index, extend=f_to_extend(vahExtendOpt), color=colVA, width=vaLineWidth)
                valLine := line.new(lineX1, vaLow,  lineX2, vaLow,  xloc=xloc.bar_index, extend=f_to_extend(valExtendOpt), color=colVA, width=vaLineWidth)
            else
                int lAddVah = (vahExtendOpt == "Left" or vahExtendOpt == "Both")  ? customExtendBars : 0
                int rAddVah = (vahExtendOpt == "Right" or vahExtendOpt == "Both") ? customExtendBars : 0
                int lAddVal = (valExtendOpt == "Left" or valExtendOpt == "Both")  ? customExtendBars : 0
                int rAddVal = (valExtendOpt == "Right" or valExtendOpt == "Both") ? customExtendBars : 0
                int vx1 = math.max(0, lineX1 - lAddVah), vx2 = lineX2 + rAddVah
                int lx1 = math.max(0, lineX1 - lAddVal), lx2 = lineX2 + rAddVal
                vahLine := line.new(vx1, vaHigh, vx2, vaHigh, xloc=xloc.bar_index, extend=extend.none, color=colVA, width=vaLineWidth)
                valLine := line.new(lx1, vaLow,  lx2, vaLow,  xloc=xloc.bar_index, extend=extend.none, color=colVA, width=vaLineWidth)
            if not na(vahLine)
                line.set_style(vahLine, line.style_dashed)
            if not na(valLine)
                line.set_style(valLine, line.style_dashed)

        // ───────────────────────────────────── Regime calculation & table (uses f_tanh)
        if useRegime
            float totalBuy  = 0.0, totalSell = 0.0, sumMidW = 0.0
            for b = 0 to bins - 1
                float buyB  = array.get(buyVols,  b)
                float sellB = array.get(sellVols, b)
                float totB  = buyB + sellB
                float midP  = minP + (b + 0.5) * step
                totalBuy  += buyB
                totalSell += sellB
                sumMidW   += midP * totB

            float totalAll  = math.max(totalBuy + totalSell, 1e-6)
            float deltaFrac = (totalBuy - totalSell) / totalAll
            float muPrice   = sumMidW / totalAll
            float atr14     = ta.atr(14)
            float normClose = (close - muPrice) / math.max(atr14, syminfo.mintick)
            float posVA     = close > vaHigh ? 1.0 : (close < vaLow ? -1.0 : 0.0)

            float rawScore  = 0.5 * deltaFrac + 0.3 * f_tanh(normClose) + 0.2 * posVA
            rawScore        := f_tanh(rawScore)

            float alpha     = 2.0 / (regSmoothLen + 1.0)
            rgmScoreSm := na(rgmScoreSm) ? rawScore : (rgmScoreSm + alpha * (rawScore - rgmScoreSm))

            float upTh = regBand, dnTh = -regBand
            rgmState :=
                 rgmState == 1  ? (rgmScoreSm < dnTh ? -1 : 1) :
                 rgmState == -1 ? (rgmScoreSm > upTh ?  1 : -1) :
                 (rgmScoreSm > upTh ? 1 : (rgmScoreSm < dnTh ? -1 : 0))

            if showRegTable
                color colBull = stealthMode ? color.new(color.lime,  10) : color.new(color.lime,  0)
                color colBear = stealthMode ? color.new(color.red,   10) : color.new(color.red,   0)
                color colNeu  = stealthMode ? color.new(color.gray,  10) : color.new(color.gray,  0)
                string txt = rgmState == 1 ? "BULLISH ▲" : rgmState == -1 ? "BEARISH ▼" : "NEUTRAL •"
                txt += "  " + str.tostring(rgmScoreSm, format.mintick)
                color bgCol = rgmState == 1 ? colBull : rgmState == -1 ? colBear : colNeu
                table.cell(rgmTbl, 0, 0, txt, text_color=color.white, bgcolor=bgCol, text_size=size.large)
        else
            if showRegTable and not na(rgmTbl)
                table.cell(rgmTbl, 0, 0, "REGIME: OFF", text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.large)
    else
        // No valid range — clear
        f_clear_boxes()
        if not na(pocLine) 
            line.delete(pocLine), pocLine := na
        if not na(vahLine) 
            line.delete(vahLine), vahLine := na
        if not na(valLine) 
            line.delete(valLine), valLine := na
````
