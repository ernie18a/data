# Volume Profile XL

- url: https://www.tradingview.com/script/OUL0w595-Volume-Profile-XL/
- type: indicator
- pine_id: PUB;240d7ef7d69841e7ab84a2551a861754
- version: 4.0

## Description

**Volume Profile XL — Overview**

Volume Profile XL shows *where* trading activity concentrated across price, rather than just when it happened. It divides price into horizontal bins and draws a sideways histogram: the longer a row, the more volume traded at that price. This reveals the levels the market accepted (heavy rows) and the levels it passed through quickly (thin rows), plus three key reference prices — the POC and the Value Area boundaries.

**The two ways it can display**

- **Per Day (Historical)** — the default. It draws a separate profile over each of the last several periods, sitting on top of that period's candles. This lets you see how accepted price shifted from one day to the next.
- **Combined** — one single profile built from a fixed number of recent bars, drawn off to one side of price. This gives a clean, current read of fair value across the recent move without splitting it by day.

**The three reference markers on every profile**

- **POC (Point of Control)** — the single price with the most volume; the profile's center of gravity.
- **VAH / VAL (Value Area High / Low)** — the top and bottom of the price band containing the chosen percentage of volume. Price inside this band is "in balance"; price leaving it signals the market is exploring new territory.

---

**Mode settings (top of the panel)**

- **Profile Mode** — switches between Per Day and Combined, as described above.
- **Split Up/Down Volume** — when on, each row is colored in two parts, showing how much of that level's volume came from up-closing versus down-closing bars, so you can read buying vs. selling pressure within a level. When off, each row is a single color based on whichever side dominated. Turning it off also halves the drawing load, which lets you display roughly twice as many days at the same detail — the main lever when you want more history on screen.

**Calculation settings**

- **Number of Rows** — how finely price is sliced. More rows means more detail but, in Per Day mode, fewer days fit on screen at once. Fewer rows means a coarser profile but more history.
- **Value Area %** — the share of volume the Value Area captures. Seventy percent is the long-standing market convention; raising or lowering it widens or narrows the VAH–VAL band.

**Per Day (Historical) settings**

- **Period** — whether each profile covers a Day, a Week, or a Month.
- **Historical Lookback (Days)** — how many periods back to draw. If you request more than the screen can hold, it automatically shows as many as fit rather than erroring.
- **Profile Width (% of period)** — how much of each period's horizontal space the widest row fills. Lower values make slimmer, less overlapping profiles; higher values make bolder ones.

**Combined settings**

- **Lookback Bars** — how many recent bars feed the single combined profile.
- **Placement** — draws the profile to the Left or Right of current price.
- **Max Profile Width** — the on-screen length of the busiest row; controls the overall size of the histogram.
- **Gap From Price** — spacing between the profile and the candles.

**Colors & Lines settings**

- **Up Volume / Down Volume** — the two histogram colors.
- **Show POC** and **POC Color / POC Line Style** — toggle the Point of Control line and set its color and style (Solid, Dashed, or Dotted).
- **Show Value Area** and **VA Color / VA Line Style** — toggle the Value Area lines and set their color and style.
- **Label Size** — the size of the POC, VAH, and VAL price tags, from Tiny to Huge.

---

**How to use it in practice**

- **Read the shape first.** Fat rows are magnets where price tends to stall; thin rows and gaps are fast zones price tends to slice through.
- **Watch behavior at the edges.** Price stalling at VAH or VAL and turning back suggests balance and a move toward the POC. Price pushing through an edge and *holding* there suggests acceptance and a possible trend in that direction.
- **Compare day to day (Per Day mode).** Overlapping value areas across days point to a sideways, balancing market; value areas stepping steadily up or down point to a trend. Where today opens relative to yesterday's Value Area is one of the most useful tells for whether the session is likely to rotate or run.
- **Use Combined for the big picture.** When you want one clean map of the current support and resistance shelves rather than a day-by-day breakdown, switch to Combined and place it on whichever side keeps your price action clear.

**A note on the data**
The profile is built from each bar's price range and volume, which is the standard approach for this kind of tool on this platform. It's a close approximation of the true volume-at-price distribution, not a tick-by-tick reconstruction, so treat the levels as high-quality reference points rather than exact measurements.

## Source Code

````pine
//@version=6
indicator("Volume Profile XL", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 100, max_bars_back = 5000)

// ═══════════════════════════════ INPUTS ═══════════════════════════════
grpMode = "Mode"
profileMode = input.string("Per Day (Historical)", "Profile Mode", options = ["Combined", "Per Day (Historical)"], group = grpMode, tooltip = "Combined = one profile from the last N bars, drawn beside price.\nPer Day = a separate profile drawn over each of the last N periods.")
splitVol  = input.bool(true, "Split Up/Down Volume", group = grpMode, tooltip = "On: each row shows separate up/down segments (2 boxes per row).\nOff: one box per row, colored by the dominant side — halves box use, so you can show roughly twice as many days at the same row count.")

grpCalc = "Calculation"
rows      = input.int(24,  "Number of Rows",  minval = 5,  maxval = 100,  group = grpCalc, tooltip = "Price is split into this many horizontal bins per profile.")
vaPercent = input.float(70, "Value Area %",   minval = 1,  maxval = 100,  group = grpCalc, tooltip = "Share of total volume the Value Area covers, centered on the POC. 70% is the standard convention; the VAH and VAL lines mark its upper and lower edges.") / 100.0

grpHist = "Per Day (Historical) Mode"
periodSel = input.string("Day", "Period", options = ["Day", "Week", "Month"], group = grpHist, tooltip = "The unit each profile covers.")
numDays   = input.int(5, "Historical Lookback (Days)", minval = 1, maxval = 30, group = grpHist, tooltip = "How many periods back to draw, counted in the Period unit above (days by default). Auto-capped so the chart stays under TradingView's drawing limit.")
histWidth = input.float(0.9, "Profile Width (% of period)", minval = 0.1, maxval = 1.0, step = 0.05, group = grpHist, tooltip = "How much of each period's horizontal space the widest row fills.")

grpComb = "Combined Mode"
lookback     = input.int(200, "Lookback Bars",  minval = 10, maxval = 5000, group = grpComb, tooltip = "How many bars back the Combined profile is built from. Also sets the price high/low range the profile spans.")
placement    = input.string("Left", "Placement", options = ["Right", "Left"], group = grpComb, tooltip = "Which side of the latest candle the Combined profile is drawn on.")
profileWidth = input.int(80, "Max Profile Width (bars)", minval = 10, maxval = 450, group = grpComb, tooltip = "Horizontal length, in bars, of the highest-volume (POC) row. Every other row scales proportionally to this width.")
gap          = input.int(5,  "Gap From Price (bars)",    minval = 0,  maxval = 40,  group = grpComb, tooltip = "Empty space, in bars, between the latest candle and the near edge of the profile.")

grpColor = "Colors & Lines"
upColor   = input.color(color.new(#26a69a, 55), "Up Volume",   group = grpColor, tooltip = "Fill color for volume on bars that closed at or above their open (buying side).")
downColor = input.color(color.new(#ef5350, 55), "Down Volume", group = grpColor, tooltip = "Fill color for volume on bars that closed below their open (selling side).")
showPOC   = input.bool(true,  "Show POC",        group = grpColor, tooltip = "Draws the Point of Control — a horizontal line at the single highest-volume price row.")
pocColor  = input.color(color.new(#ff9800, 0),   "POC Color",  group = grpColor, tooltip = "Line color for the Point of Control.")
pocStyleSel = input.string("Solid", "POC Line Style", options = ["Solid", "Dashed", "Dotted"], group = grpColor, tooltip = "Line style for the Point of Control.")
pocWidth  = input.int(2, "POC Line Width", minval = 1, maxval = 10, group = grpColor, tooltip = "Line thickness for the Point of Control.")
showVA    = input.bool(true,  "Show Value Area", group = grpColor, tooltip = "Draws the Value Area High (VAH) and Value Area Low (VAL) lines that bound the Value Area %.")
vaColor   = input.color(color.new(#2962ff, 0),   "VA Color",   group = grpColor, tooltip = "Line color for the Value Area High/Low.")
vaStyleSel = input.string("Dashed", "VA Line Style", options = ["Solid", "Dashed", "Dotted"], group = grpColor, tooltip = "Line style for the Value Area High/Low.")
vaWidth   = input.int(1, "VA Line Width", minval = 1, maxval = 10, group = grpColor, tooltip = "Line thickness for the Value Area High/Low.")
lblShow    = input.bool(true, "Show Labels", group = grpColor, tooltip = "Turns the POC/VAH/VAL price tags on or off.")
lblSizeSel = input.string("Tiny", "Label Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpColor, tooltip = "Text size of the POC/VAH/VAL price tags.")
lblOffset  = input.int(2, "Label Bar Offset", minval = 0, maxval = 20, group = grpColor, tooltip = "Pushes the POC/VAH/VAL price tags this many bars sideways so they clear the profile and candles.")
lblSize = lblSizeSel == "Tiny" ? size.tiny : lblSizeSel == "Small" ? size.small : lblSizeSel == "Normal" ? size.normal : lblSizeSel == "Large" ? size.large : size.huge
pocStyle = pocStyleSel == "Solid" ? line.style_solid : pocStyleSel == "Dashed" ? line.style_dashed : line.style_dotted
vaStyle  = vaStyleSel  == "Solid" ? line.style_solid : vaStyleSel  == "Dashed" ? line.style_dashed : line.style_dotted

// ═══════════════════════ SERIES (evaluated every bar) ═══════════════════════
periodTF  = periodSel == "Day" ? "1D" : periodSel == "Week" ? "1W" : "1M"
newPeriod = timeframe.change(periodTF)
rangeHigh = ta.highest(high, lookback)
rangeLow  = ta.lowest(low,  lookback)

// ═══════════════════════ PERSISTENT DRAWING STORAGE ═══════════════════════
var array<box>   boxUp   = array.new<box>()
var array<box>   boxDn   = array.new<box>()
var array<line>  vaLines = array.new<line>()
var array<label> vaLbls  = array.new<label>()

wipe() =>
    for b in boxUp
        box.delete(b)
    for b in boxDn
        box.delete(b)
    for l in vaLines
        line.delete(l)
    for lb in vaLbls
        label.delete(lb)
    array.clear(boxUp)
    array.clear(boxDn)
    array.clear(vaLines)
    array.clear(vaLbls)

// ═══════════════════════════════ MAIN ═══════════════════════════════
if barstate.islast

    // ─────────────────────────── COMBINED MODE ───────────────────────────
    if profileMode == "Combined" and rangeHigh > rangeLow
        wipe()
        rowH = (rangeHigh - rangeLow) / rows
        upVol = array.new<float>(rows, 0.0)
        dnVol = array.new<float>(rows, 0.0)

        for i = 0 to lookback - 1
            bH = high[i], bL = low[i], bVol = volume[i], bRange = high[i] - low[i]
            isUp = close[i] >= open[i]
            if bRange <= 0
                idx = math.max(0, math.min(rows - 1, int((close[i] - rangeLow) / rowH)))
                array.set(isUp ? upVol : dnVol, idx, array.get(isUp ? upVol : dnVol, idx) + bVol)
            else
                for r = 0 to rows - 1
                    rLow = rangeLow + r * rowH, rHigh = rLow + rowH
                    overlap = math.min(bH, rHigh) - math.max(bL, rLow)
                    if overlap > 0
                        array.set(isUp ? upVol : dnVol, r, array.get(isUp ? upVol : dnVol, r) + bVol * overlap / bRange)

        maxVol = 0.0, pocIdx = 0, grandTot = 0.0
        totVol = array.new<float>(rows, 0.0)
        for r = 0 to rows - 1
            t = array.get(upVol, r) + array.get(dnVol, r)
            array.set(totVol, r, t)
            grandTot += t
            if t > maxVol
                maxVol := t
                pocIdx := r

        vaSum = array.get(totVol, pocIdx), upPtr = pocIdx, dnPtr = pocIdx
        while vaSum < grandTot * vaPercent and (upPtr < rows - 1 or dnPtr > 0)
            va = upPtr < rows - 1 ? array.get(totVol, upPtr + 1) : -1.0
            vb = dnPtr > 0        ? array.get(totVol, dnPtr - 1) : -1.0
            if va >= vb
                upPtr += 1, vaSum += va
            else
                dnPtr -= 1, vaSum += vb

        isRight = placement == "Right"
        anchor = bar_index
        for r = 0 to rows - 1
            rLow = rangeLow + r * rowH, rHigh = rLow + rowH
            uV = array.get(upVol, r), dV = array.get(dnVol, r), tV = uV + dV
            if tV > 0
                wTot = math.max(1, int(math.round(tV / maxVol * profileWidth)))
                if not splitVol
                    col = uV >= dV ? upColor : downColor
                    if isRight
                        array.push(boxUp, box.new(anchor + gap, rHigh, anchor + gap + wTot, rLow, xloc = xloc.bar_index, border_width = 0, bgcolor = col))
                    else
                        array.push(boxUp, box.new(anchor - gap - wTot, rHigh, anchor - gap, rLow, xloc = xloc.bar_index, border_width = 0, bgcolor = col))
                else
                    wUp = int(math.round(wTot * uV / tV)), wDn = wTot - wUp
                    if isRight
                        base = anchor + gap
                        if wDn > 0
                            array.push(boxDn, box.new(base, rHigh, base + wDn, rLow, xloc = xloc.bar_index, border_width = 0, bgcolor = downColor))
                        if wUp > 0
                            array.push(boxUp, box.new(base + wDn, rHigh, base + wDn + wUp, rLow, xloc = xloc.bar_index, border_width = 0, bgcolor = upColor))
                    else
                        base = anchor - gap
                        if wDn > 0
                            array.push(boxDn, box.new(base - wDn, rHigh, base, rLow, xloc = xloc.bar_index, border_width = 0, bgcolor = downColor))
                        if wUp > 0
                            array.push(boxUp, box.new(base - wDn - wUp, rHigh, base - wDn, rLow, xloc = xloc.bar_index, border_width = 0, bgcolor = upColor))

        lineL = isRight ? anchor + gap : anchor - gap - profileWidth
        lineR = isRight ? anchor + gap + profileWidth : anchor - gap
        if showPOC
            pocP = rangeLow + pocIdx * rowH + rowH / 2
            array.push(vaLines, line.new(lineL, pocP, lineR, pocP, xloc = xloc.bar_index, color = pocColor, width = pocWidth, style = pocStyle))
            if lblShow
                array.push(vaLbls, label.new(lineR + lblOffset, pocP, "POC " + str.tostring(pocP, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(pocColor, 20), textcolor = color.black, size = lblSize))
        if showVA
            vah = rangeLow + (upPtr + 1) * rowH, val = rangeLow + dnPtr * rowH
            array.push(vaLines, line.new(lineL, vah, lineR, vah, xloc = xloc.bar_index, color = vaColor, width = vaWidth, style = vaStyle))
            array.push(vaLines, line.new(lineL, val, lineR, val, xloc = xloc.bar_index, color = vaColor, width = vaWidth, style = vaStyle))
            if lblShow
                array.push(vaLbls, label.new(lineR + lblOffset, vah, "VAH " + str.tostring(vah, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(vaColor, 20), textcolor = color.white, size = lblSize))
                array.push(vaLbls, label.new(lineR + lblOffset, val, "VAL " + str.tostring(val, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(vaColor, 20), textcolor = color.white, size = lblSize))

    // ─────────────────────── PER DAY (HISTORICAL) MODE ───────────────────────
    if profileMode == "Per Day (Historical)"
        wipe()

        // Find the opening-bar offset of each recent period (offset 0 = current bar, older = larger).
        opens = array.new<int>()
        maxBack = 4999
        i = 0
        while i <= maxBack and (bar_index - i) >= 0 and array.size(opens) < numDays
            if newPeriod[i]
                array.push(opens, i)
            i += 1
        numFound = array.size(opens)

        // Clamp how many periods we actually draw so we never blow the 500-box / 500-line ceiling.
        boxesPerRow = splitVol ? 2 : 1
        budgetDays = math.max(1, int(math.floor(500.0 / (rows * boxesPerRow))))
        drawDays = math.min(numFound, budgetDays)

        for d = 0 to drawDays - 1
            startOff = array.get(opens, d)                       // oldest bar of this period (its open)
            endOff   = d == 0 ? 0 : array.get(opens, d - 1) + 1  // newest bar of this period
            spanBars = startOff - endOff
            if spanBars >= 1
                // Period high / low
                dHigh = high[endOff], dLow = low[endOff]
                for o = endOff to startOff
                    dHigh := math.max(dHigh, high[o])
                    dLow  := math.min(dLow,  low[o])

                if dHigh > dLow
                    rowH = (dHigh - dLow) / rows
                    upVol = array.new<float>(rows, 0.0)
                    dnVol = array.new<float>(rows, 0.0)

                    for o = endOff to startOff
                        bH = high[o], bL = low[o], bVol = volume[o], bRange = high[o] - low[o]
                        isUp = close[o] >= open[o]
                        if bRange <= 0
                            idx = math.max(0, math.min(rows - 1, int((close[o] - dLow) / rowH)))
                            array.set(isUp ? upVol : dnVol, idx, array.get(isUp ? upVol : dnVol, idx) + bVol)
                        else
                            for r = 0 to rows - 1
                                rLow = dLow + r * rowH, rHigh = rLow + rowH
                                overlap = math.min(bH, rHigh) - math.max(bL, rLow)
                                if overlap > 0
                                    array.set(isUp ? upVol : dnVol, r, array.get(isUp ? upVol : dnVol, r) + bVol * overlap / bRange)

                    // Totals / POC / Value Area for this period
                    totVol = array.new<float>(rows, 0.0)
                    dayMax = 0.0, pocIdx = 0, grandTot = 0.0
                    for r = 0 to rows - 1
                        t = array.get(upVol, r) + array.get(dnVol, r)
                        array.set(totVol, r, t)
                        grandTot += t
                        if t > dayMax
                            dayMax := t
                            pocIdx := r

                    vaSum = array.get(totVol, pocIdx), upPtr = pocIdx, dnPtr = pocIdx
                    while vaSum < grandTot * vaPercent and (upPtr < rows - 1 or dnPtr > 0)
                        va = upPtr < rows - 1 ? array.get(totVol, upPtr + 1) : -1.0
                        vb = dnPtr > 0        ? array.get(totVol, dnPtr - 1) : -1.0
                        if va >= vb
                            upPtr += 1, vaSum += va
                        else
                            dnPtr -= 1, vaSum += vb

                    // Draw this period's profile, anchored at its open, growing right into the period
                    leftBar  = bar_index - startOff
                    rightBar = bar_index - endOff
                    maxRowW  = math.max(1, int((rightBar - leftBar) * histWidth))
                    if dayMax > 0
                        for r = 0 to rows - 1
                            rLow = dLow + r * rowH, rHigh = rLow + rowH
                            uV = array.get(upVol, r), dV = array.get(dnVol, r), tV = uV + dV
                            if tV > 0
                                wTot = math.max(1, int(math.round(tV / dayMax * maxRowW)))
                                if not splitVol
                                    col = uV >= dV ? upColor : downColor
                                    array.push(boxUp, box.new(leftBar, rHigh, leftBar + wTot, rLow, xloc = xloc.bar_index, border_width = 0, bgcolor = col))
                                else
                                    wUp = int(math.round(wTot * uV / tV)), wDn = wTot - wUp
                                    if wDn > 0
                                        array.push(boxDn, box.new(leftBar, rHigh, leftBar + wDn, rLow, xloc = xloc.bar_index, border_width = 0, bgcolor = downColor))
                                    if wUp > 0
                                        array.push(boxUp, box.new(leftBar + wDn, rHigh, leftBar + wDn + wUp, rLow, xloc = xloc.bar_index, border_width = 0, bgcolor = upColor))

                        if showPOC
                            pocP = dLow + pocIdx * rowH + rowH / 2
                            array.push(vaLines, line.new(leftBar, pocP, rightBar, pocP, xloc = xloc.bar_index, color = pocColor, width = pocWidth, style = pocStyle))
                            if d == 0 and lblShow
                                array.push(vaLbls, label.new(rightBar + lblOffset, pocP, "POC " + str.tostring(pocP, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(pocColor, 20), textcolor = color.black, size = lblSize))
                        if showVA
                            vah = dLow + (upPtr + 1) * rowH, val = dLow + dnPtr * rowH
                            array.push(vaLines, line.new(leftBar, vah, rightBar, vah, xloc = xloc.bar_index, color = vaColor, width = vaWidth, style = vaStyle))
                            array.push(vaLines, line.new(leftBar, val, rightBar, val, xloc = xloc.bar_index, color = vaColor, width = vaWidth, style = vaStyle))
                            if d == 0 and lblShow
                                array.push(vaLbls, label.new(rightBar + lblOffset, vah, "VAH " + str.tostring(vah, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(vaColor, 20), textcolor = color.white, size = lblSize))
                                array.push(vaLbls, label.new(rightBar + lblOffset, val, "VAL " + str.tostring(val, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(vaColor, 20), textcolor = color.white, size = lblSize))
````
