# BTC CME Weekend Gap Tracker

- url: https://www.tradingview.com/script/HunddRzh-BTC-CME-Weekend-Gap-Tracker/
- type: indicator
- pine_id: PUB;9da63db00fbd447589fff22fac435d3b
- version: 1.0

## Description

BTC CME Weekend Gap Tracker
Automatically detects and tracks weekend gaps on CME Bitcoin futures (BTC1!). When CME closes Friday evening and reopens Sunday/Monday, any price movement in spot during that window creates a gap — this indicator marks those gaps directly on your chart.
What it shows

Red boxes — weekend gap down (CME reopened lower than Friday close)
Green boxes — weekend gap up (CME reopened higher than Friday close)
Gray boxes — filled gaps (price has since traded back through the range)

Key features

Weekend-only filter — ignores daily maintenance gaps, only tracks the meaningful Friday-to-Monday gaps (and extended holiday closures)
Price levels labeled at the right edge of each unfilled gap so you can see exact gap boundaries at a glance
Date and percentage size shown inside each box
Unfilled gaps extend right until filled, then fade to gray
Stats table tracking total gaps, fill rate, gap-up vs gap-down fill rates, average fill time, and average gap size

How to use
Apply to any BTC chart (BTCUSD, BTCUSDT, BTCUSDT.P) on daily or intraday timeframes. The script pulls CME data automatically. Use unfilled gaps as potential price targets — historically, the majority of CME gaps fill over time, though large gaps in strong trends can remain open for extended periods.
Settings

Minimum gap size threshold (filter noise)
Max bars to track (history depth)
Toggle price levels, percentages, and dates independently
Customize gap colors

Alerts
Two alert conditions included: new weekend gap up and new weekend gap down. Set these up to get notified when CME reopens Monday with a gap.

## Source Code

````pine
//@version=6
indicator("BTC CME Weekend Gap Tracker", overlay = true,
     max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ─── inputs ──────────────────────────────────────────────────────────────────
grp_src      = "Data Source"
cmeSymbol    = input.symbol("CME:BTC1!", "CME symbol", group = grp_src)

grp_gap      = "Gap Detection"
minGapPct    = input.float(0.1, "Minimum gap size (%)", minval = 0.0, step = 0.05, group = grp_gap)
maxAgeBars   = input.int(500, "Max bars to track", minval = 50, maxval = 2000, group = grp_gap)

grp_visual   = "Visuals"
gapUpCol     = input.color(color.new(#26a69a, 82), "Gap up box",   group = grp_visual)
gapDnCol     = input.color(color.new(#ef5350, 82), "Gap down box", group = grp_visual)
filledCol    = input.color(color.new(color.gray, 92), "Filled gap", group = grp_visual)
showPrices   = input.bool(true, "Show gap price levels",            group = grp_visual)
showPct      = input.bool(true, "Show gap size %",                  group = grp_visual)
showDate     = input.bool(true, "Show weekend date",                group = grp_visual)
extendRight  = input.bool(true, "Extend unfilled gaps",             group = grp_visual)

grp_stats    = "Stats"
showStats    = input.bool(true, "Show stats table", group = grp_stats)

// ─── fetch CME data ─────────────────────────────────────────────────────────
[cmeOpen, cmeClose, cmeHigh, cmeLow, cmeTime] = request.security(
     cmeSymbol, "D", [open, close, high, low, time],
     lookahead = barmerge.lookahead_off)

prevCmeClose = cmeClose[1]
prevCmeTime  = cmeTime[1]
rawGap       = cmeOpen - prevCmeClose
rawGapPct    = not na(prevCmeClose) and prevCmeClose != 0 ? rawGap / prevCmeClose * 100 : 0.0
isGap        = math.abs(rawGapPct) >= minGapPct and not na(prevCmeClose) and cmeOpen != prevCmeClose
isGapUp      = isGap and rawGap > 0
isGapDown    = isGap and rawGap < 0

hoursSincePrev = not na(prevCmeTime) ? (cmeTime - prevCmeTime) / (1000 * 60 * 60) : 0.0
isWeekendGap   = hoursSincePrev > 30

newGap = isGap and isWeekendGap and (na(cmeOpen[1]) or cmeOpen != cmeOpen[1])

// ─── gap tracking arrays ────────────────────────────────────────────────────
var array<float> gapTops    = array.new<float>()
var array<float> gapBots    = array.new<float>()
var array<int>   gapStarts  = array.new<int>()
var array<bool>  gapIsUp    = array.new<bool>()
var array<bool>  gapFilled  = array.new<bool>()
var array<box>   gapBoxes   = array.new<box>()
var array<label> topLabels  = array.new<label>()
var array<label> botLabels  = array.new<label>()
var array<label> pctLabels  = array.new<label>()
var array<label> dateLabels = array.new<label>()

// stats
var int totalGaps   = 0
var int filledGaps  = 0
var int gapUpCount  = 0
var int gapDnCount  = 0
var int gapUpFilled = 0
var int gapDnFilled = 0
var float sumFillBars = 0.0
var float sumGapSize  = 0.0

// ─── helpers ────────────────────────────────────────────────────────────────
f_price(float p) =>
    p >= 1000 ? str.tostring(p, "#,###") : str.tostring(p, "#.##")

// format the Friday close date (prevCmeTime - which is the Friday session)
f_fridayDate(int t) =>
    str.format_time(t, "MMM dd", "UTC")

// ─── register new weekend gap ───────────────────────────────────────────────
if newGap
    topPrice = math.max(cmeOpen, prevCmeClose)
    botPrice = math.min(cmeOpen, prevCmeClose)

    array.push(gapTops,   topPrice)
    array.push(gapBots,   botPrice)
    array.push(gapStarts, bar_index)
    array.push(gapIsUp,   isGapUp)
    array.push(gapFilled, false)

    boxCol = isGapUp ? gapUpCol : gapDnCol
    newBox = box.new(bar_index, topPrice, bar_index + 1, botPrice,
         border_color = color.new(isGapUp ? #26a69a : #ef5350, 40),
         bgcolor = boxCol, border_width = 1,
         extend = extendRight ? extend.right : extend.none)
    array.push(gapBoxes, newBox)

    accentCol = isGapUp ? #26a69a : #ef5350

    if showPrices
        topLbl = label.new(bar_index, topPrice, f_price(topPrice),
             xloc = xloc.bar_index, yloc = yloc.price,
             style = label.style_label_left,
             color = color.new(accentCol, 15),
             textcolor = color.white, size = size.small)
        botLbl = label.new(bar_index, botPrice, f_price(botPrice),
             xloc = xloc.bar_index, yloc = yloc.price,
             style = label.style_label_left,
             color = color.new(accentCol, 15),
             textcolor = color.white, size = size.small)
        array.push(topLabels, topLbl)
        array.push(botLabels, botLbl)
    else
        array.push(topLabels, label.new(na, na, "", color = color.new(color.black, 100)))
        array.push(botLabels, label.new(na, na, "", color = color.new(color.black, 100)))

    // combined date + percentage label at gap start
    midPrice = (topPrice + botPrice) / 2
    fridayDate = f_fridayDate(prevCmeTime)
    pctStr = (isGapUp ? "▲" : "▼") + " " + str.tostring(math.abs(rawGapPct), "#.##") + "%"

    if showDate and showPct
        combinedTxt = fridayDate + "\n" + pctStr
        dateLbl = label.new(bar_index, midPrice, combinedTxt,
             xloc = xloc.bar_index, yloc = yloc.price,
             style = label.style_none,
             textcolor = color.new(accentCol, 0),
             size = size.small)
        array.push(dateLabels, dateLbl)
        array.push(pctLabels, label.new(na, na, "", color = color.new(color.black, 100)))
    else if showPct
        pctLbl = label.new(bar_index, midPrice, pctStr,
             xloc = xloc.bar_index, yloc = yloc.price,
             style = label.style_none,
             textcolor = color.new(accentCol, 0),
             size = size.small)
        array.push(pctLabels, pctLbl)
        array.push(dateLabels, label.new(na, na, "", color = color.new(color.black, 100)))
    else if showDate
        dateLbl = label.new(bar_index, midPrice, fridayDate,
             xloc = xloc.bar_index, yloc = yloc.price,
             style = label.style_none,
             textcolor = color.new(accentCol, 0),
             size = size.small)
        array.push(dateLabels, dateLbl)
        array.push(pctLabels, label.new(na, na, "", color = color.new(color.black, 100)))
    else
        array.push(dateLabels, label.new(na, na, "", color = color.new(color.black, 100)))
        array.push(pctLabels, label.new(na, na, "", color = color.new(color.black, 100)))

    totalGaps  += 1
    sumGapSize += math.abs(rawGapPct)
    if isGapUp
        gapUpCount += 1
    else
        gapDnCount += 1

// ─── move price labels to right edge each bar ───────────────────────────────
if extendRight and showPrices and array.size(gapTops) > 0
    for i = 0 to array.size(gapTops) - 1
        if not array.get(gapFilled, i)
            topLbl = array.get(topLabels, i)
            botLbl = array.get(botLabels, i)
            if not na(label.get_text(topLbl))
                label.set_x(topLbl, bar_index)
            if not na(label.get_text(botLbl))
                label.set_x(botLbl, bar_index)

// ─── check fills ────────────────────────────────────────────────────────────
if array.size(gapTops) > 0
    for i = 0 to array.size(gapTops) - 1
        if not array.get(gapFilled, i)
            top  = array.get(gapTops, i)
            bot  = array.get(gapBots, i)
            isUp = array.get(gapIsUp, i)
            filled = (isUp and low <= bot) or (not isUp and high >= top)

            if filled
                array.set(gapFilled, i, true)
                b = array.get(gapBoxes, i)
                box.set_bgcolor(b, filledCol)
                box.set_border_color(b, color.new(color.gray, 60))
                box.set_right(b, bar_index)
                box.set_extend(b, extend.none)

                topLbl  = array.get(topLabels, i)
                botLbl  = array.get(botLabels, i)
                pctLbl  = array.get(pctLabels, i)
                dateLbl = array.get(dateLabels, i)
                if not na(label.get_text(topLbl))
                    label.set_color(topLbl, color.new(color.gray, 60))
                    label.set_x(topLbl, bar_index)
                if not na(label.get_text(botLbl))
                    label.set_color(botLbl, color.new(color.gray, 60))
                    label.set_x(botLbl, bar_index)
                if not na(label.get_text(pctLbl))
                    label.set_textcolor(pctLbl, color.new(color.gray, 50))
                if not na(label.get_text(dateLbl))
                    label.set_textcolor(dateLbl, color.new(color.gray, 50))

                filledGaps  += 1
                sumFillBars += bar_index - array.get(gapStarts, i)
                if isUp
                    gapUpFilled += 1
                else
                    gapDnFilled += 1

// ─── prune old gaps ─────────────────────────────────────────────────────────
if array.size(gapStarts) > 0 and bar_index - array.get(gapStarts, 0) > maxAgeBars
    box.delete(array.shift(gapBoxes))
    tl = array.shift(topLabels)
    bl = array.shift(botLabels)
    pl = array.shift(pctLabels)
    dl = array.shift(dateLabels)
    if not na(label.get_text(tl))
        label.delete(tl)
    if not na(label.get_text(bl))
        label.delete(bl)
    if not na(label.get_text(pl))
        label.delete(pl)
    if not na(label.get_text(dl))
        label.delete(dl)
    array.shift(gapTops)
    array.shift(gapBots)
    array.shift(gapStarts)
    array.shift(gapIsUp)
    array.shift(gapFilled)

// ─── alerts ─────────────────────────────────────────────────────────────────
alertcondition(newGap and isGapUp,   "New weekend gap up",   "BTC CME weekend gap up detected")
alertcondition(newGap and isGapDown, "New weekend gap down", "BTC CME weekend gap down detected")

// ─── stats table ────────────────────────────────────────────────────────────
var table t = table.new(position.top_right, 2, 8,
     bgcolor = color.new(color.black, 80), border_width = 1)

if showStats and barstate.islast
    fillRate   = totalGaps > 0 ? filledGaps / totalGaps * 100 : 0.0
    upFillRate = gapUpCount > 0 ? gapUpFilled / gapUpCount * 100 : 0.0
    dnFillRate = gapDnCount > 0 ? gapDnFilled / gapDnCount * 100 : 0.0
    avgFill    = filledGaps > 0 ? sumFillBars / filledGaps : 0.0
    avgSize    = totalGaps > 0 ? sumGapSize / totalGaps : 0.0
    openGaps   = totalGaps - filledGaps

    table.cell(t, 0, 0, "Weekend Gaps", text_color = color.white, bgcolor = color.new(#f5a524, 40))
    table.cell(t, 1, 0, "",             text_color = color.white, bgcolor = color.new(#f5a524, 40))
    table.cell(t, 0, 1, "Total",    text_color = color.white)
    table.cell(t, 1, 1, str.tostring(totalGaps), text_color = color.white)
    table.cell(t, 0, 2, "Filled",   text_color = color.white)
    table.cell(t, 1, 2, str.tostring(filledGaps) + " (" + str.tostring(fillRate, "#.#") + "%)",
         text_color = #26a69a)
    table.cell(t, 0, 3, "Open",     text_color = color.white)
    table.cell(t, 1, 3, str.tostring(openGaps), text_color = #f5a524)
    table.cell(t, 0, 4, "Up fills", text_color = color.white)
    table.cell(t, 1, 4, str.tostring(gapUpFilled) + "/" + str.tostring(gapUpCount) +
         " (" + str.tostring(upFillRate, "#.#") + "%)", text_color = color.white)
    table.cell(t, 0, 5, "Dn fills", text_color = color.white)
    table.cell(t, 1, 5, str.tostring(gapDnFilled) + "/" + str.tostring(gapDnCount) +
         " (" + str.tostring(dnFillRate, "#.#") + "%)", text_color = color.white)
    table.cell(t, 0, 6, "Avg fill", text_color = color.white)
    table.cell(t, 1, 6, str.tostring(avgFill, "#.#") + " bars", text_color = color.white)
    table.cell(t, 0, 7, "Avg size", text_color = color.white)
    table.cell(t, 1, 7, str.tostring(avgSize, "#.##") + "%", text_color = color.white)
````
