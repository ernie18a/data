# Ladder Planner v6 (Live, Compact RR)

- url: https://www.tradingview.com/script/fqP2ffL1-Ladder-Planner-v6-Live-Compact-RR/
- type: indicator
- pine_id: PUB;d97c28d53652416bbc01104b02f637cc
- version: 1.0

## Description

Ladder Planner v6 is a position-planning tool for scaling into a trade in multiple steps. Set a start price and end price, and the script automatically builds a ladder of entries, calculates position sizing from your capital and risk settings, places an ATR-based stop from the last step, and shows a compact summary of total size, capital used, max risk, and projected profit at your chosen reward-to-risk ratio.

How to use it:

[list]
[*]Add the script to your chart.
[*]Drag the Start Price and End Price anchors to define your ladder range.
[*]Set your Max Capital Allocated and Total Risk % of Allocated Capital.
[*]Choose the Number of Splits and the Split Weighting mode.
[*]Adjust Daily ATR Length, Stop Loss in Daily ATR Units, and Reward:Risk Ratio.
[*]Review the ladder lines, average entry, take-profit line, and compact summary table.
[*]If Start is above End, the script treats it as a long ladder. If Start is below End, it treats it as a short ladder.
[/list]

## Source Code

````pine
//@version=6
indicator("Ladder Planner v6 (Live, Compact RR)", overlay = true, max_labels_count = 500, max_lines_count = 500)

//====================================================
// Inputs
//====================================================
maxCapital        = input.float(20000, "Max Capital Allocated ($)", minval = 1, step = 100)
riskPctOfCapital  = input.float(5.0, "Total Risk % of Allocated Capital", minval = 0.1, maxval = 100, step = 0.1)
splits            = input.int(7, "Number of Splits", minval = 1, maxval = 20)

atrLen            = input.int(14, "Daily ATR Length", minval = 1)
atrMult           = input.float(0.5, "Stop Loss in Daily ATR Units", minval = 0.1, step = 0.1)
rrRatio           = input.float(3.0, "Reward:Risk Ratio", minval = 0.1, step = 0.1)

weightMode        = input.string("More Near First Step", "Split Weighting", options = ["Equal", "More Near Last Step", "More Near First Step"])
showStageLabels   = input.bool(true, "Show Stage Labels")
showSummaryTable  = input.bool(true, "Show Compact Table")
showLines         = input.bool(true, "Show Ladder Lines")
showAvgLine       = input.bool(true, "Show Avg Entry Line")
showTpLine        = input.bool(true, "Show Take Profit Line")
useConfirmedATR   = input.bool(true, "Use Confirmed Daily ATR (safer)")

// Interactive anchors: Start = first step, End = last step.
// Pairing price/time inputs keeps the draggable chart points; `confirm`
// is not needed after placement and can cause TradingView to keep adding
// numbered point prompts on recalculation.
pStart = input.price(100.0, "Start Price", inline = "START")
tStart = input.time(timestamp("2026-01-01 09:30 +0000"), "Start Time", inline = "START")

pEnd   = input.price(95.0, "End Price", inline = "END")
tEnd   = input.time(timestamp("2026-01-01 10:30 +0000"), "End Time", inline = "END")

//====================================================
// Helpers
//====================================================
f_round_qty(x) =>
    math.floor(x)

f_cash(x) =>
    "$" + str.tostring(math.round(x, 2))

f_qty(x) =>
    str.tostring(f_round_qty(x))

f_px(x) =>
    str.tostring(x, format.mintick)

f_weight(idx, total, mode) =>
    float w = 1.0
    if total <= 1
        w := 1.0
    else
        frac = idx / (total - 1.0)
        if mode == "Equal"
            w := 1.0
        else if mode == "More Near Last Step"
            w := 1.0 + frac
        else
            w := 2.0 - frac
    w

//====================================================
// Daily ATR
//====================================================
dailyAtrLive = request.security(syminfo.tickerid, "1D", ta.atr(atrLen))
dailyAtrConfirmed = request.security(syminfo.tickerid, "1D", ta.atr(atrLen)[1], lookahead = barmerge.lookahead_on)
atr = useConfirmedATR ? dailyAtrConfirmed : dailyAtrLive

//====================================================
// Auto side detection
//====================================================
startPrice = pStart
endPrice   = pEnd

isFlat  = startPrice == endPrice
isLong  = startPrice > endPrice
isShort = startPrice < endPrice

side = isFlat ? "Flat" : isLong ? "Long" : "Short"

// Stop derived from LAST STEP of ladder
stopPrice = isFlat ? na : isLong ? (endPrice - atr * atrMult) : (endPrice + atr * atrMult)
riskBudget = maxCapital * riskPctOfCapital / 100.0

//====================================================
// Persistent containers
//====================================================
var prices    = array.new_float()
var weights   = array.new_float()
var rawQtys   = array.new_float()
var finalQtys = array.new_float()

var lbls = array.new<label>()
var lns  = array.new<line>()

var table summary = table.new(position.top_right, 2, 5, border_width = 1)

//====================================================
// Main render
//====================================================
if barstate.islast
    if array.size(lbls) > 0
        for i = 0 to array.size(lbls) - 1
            label.delete(array.get(lbls, i))
    array.clear(lbls)

    if array.size(lns) > 0
        for i = 0 to array.size(lns) - 1
            line.delete(array.get(lns, i))
    array.clear(lns)

    array.clear(prices)
    array.clear(weights)
    array.clear(rawQtys)
    array.clear(finalQtys)

    if not isFlat
        stepSize = splits == 1 ? 0.0 : (endPrice - startPrice) / (splits - 1)

        weightSum = 0.0
        for i = 0 to splits - 1
            entry = startPrice + stepSize * i
            w = f_weight(i, splits, weightMode)
            array.push(prices, entry)
            array.push(weights, w)
            weightSum += w

        capitalUsedRaw = 0.0
        totalRiskRaw = 0.0

        for i = 0 to splits - 1
            entry = array.get(prices, i)
            w = array.get(weights, i)
            capitalSlice = maxCapital * (w / weightSum)
            qtyRaw = capitalSlice / entry
            riskPerUnit = math.abs(entry - stopPrice)

            capitalUsedRaw += qtyRaw * entry
            totalRiskRaw += qtyRaw * riskPerUnit
            array.push(rawQtys, qtyRaw)

        capitalScale = capitalUsedRaw > 0 ? maxCapital / capitalUsedRaw : 0.0
        riskScale    = totalRiskRaw > 0 ? riskBudget / totalRiskRaw : 0.0
        scale        = math.min(capitalScale, riskScale)

        totalQty  = 0.0
        totalCost = 0.0
        totalRisk = 0.0

        for i = 0 to splits - 1
            entry = array.get(prices, i)
            qty   = f_round_qty(array.get(rawQtys, i) * scale)
            riskPerUnit = math.abs(entry - stopPrice)

            totalQty  := totalQty + qty
            totalCost := totalCost + qty * entry
            totalRisk := totalRisk + qty * riskPerUnit

            array.push(finalQtys, qty)

        float avgEntry = totalQty > 0 ? totalCost / totalQty : na
        float riskPerUnitFromAvg = not na(avgEntry) and not na(stopPrice) ? math.abs(avgEntry - stopPrice) : na
        float tpPrice = na
        if not na(avgEntry) and not na(riskPerUnitFromAvg)
            tpPrice := isLong ? (avgEntry + riskPerUnitFromAvg * rrRatio) : (avgEntry - riskPerUnitFromAvg * rrRatio)

        float maxProfit = not na(tpPrice) ? totalQty * math.abs(tpPrice - avgEntry) : na

        stageColor = isLong ? color.teal : color.orange
        stopColor  = color.red
        avgColor   = color.yellow
        tpColor    = color.lime

        if showLines
            pathLine = line.new(tStart, pStart, tEnd, pEnd, xloc = xloc.bar_time, extend = extend.none, color = color.new(color.silver, 20), width = 2)
            array.push(lns, pathLine)

            stopLine = line.new(bar_index - 20, stopPrice, bar_index + 200, stopPrice, extend = extend.right, color = color.new(stopColor, 0), style = line.style_dashed, width = 2)
            array.push(lns, stopLine)

            if showAvgLine and not na(avgEntry)
                avgLine = line.new(bar_index - 20, avgEntry, bar_index + 200, avgEntry, extend = extend.right, color = color.new(avgColor, 0), style = line.style_dotted, width = 2)
                array.push(lns, avgLine)

            if showTpLine and not na(tpPrice)
                tpLine = line.new(bar_index - 20, tpPrice, bar_index + 200, tpPrice, extend = extend.right, color = color.new(tpColor, 0), style = line.style_dashed, width = 2)
                array.push(lns, tpLine)

        for i = 0 to splits - 1
            entry = array.get(prices, i)
            qty   = array.get(finalQtys, i)
            stageCost = qty * entry

            if showLines
                stageLine = line.new(bar_index - 20, entry, bar_index + 200, entry, extend = extend.right, color = color.new(stageColor, 45), width = 1)
                array.push(lns, stageLine)

            if showStageLabels
                txt = f_qty(qty) + " / " + f_cash(stageCost)
                stageLabel = label.new(bar_index + 2, entry, txt, style = label.style_label_left, textcolor = color.white, color = color.new(stageColor, 55), size = size.small)
                array.push(lbls, stageLabel)

        if showSummaryTable
            table.cell(summary, 0, 0, "Metric", text_color = color.white, bgcolor = color.new(color.gray, 20))
            table.cell(summary, 1, 0, "Value",  text_color = color.white, bgcolor = color.new(color.gray, 20))

            table.cell(summary, 0, 1, "Stock / Capital")
            table.cell(summary, 1, 1, f_qty(totalQty) + " / " + f_cash(totalCost))

            table.cell(summary, 0, 2, "Max Risk")
            table.cell(summary, 1, 2, f_cash(totalRisk))

            table.cell(summary, 0, 3, "Max Profit")
            table.cell(summary, 1, 3, (na(maxProfit) ? "n/a" : f_cash(maxProfit)) + "  (1:" + str.tostring(rrRatio) + ")")

            table.cell(summary, 0, 4, "Side")
            table.cell(summary, 1, 4, side)

    else
        if showSummaryTable
            table.cell(summary, 0, 0, "Metric", text_color = color.white, bgcolor = color.new(color.gray, 20))
            table.cell(summary, 1, 0, "Value",  text_color = color.white, bgcolor = color.new(color.gray, 20))

            table.cell(summary, 0, 1, "Stock / Capital")
            table.cell(summary, 1, 1, "n/a")

            table.cell(summary, 0, 2, "Max Risk")
            table.cell(summary, 1, 2, "n/a")

            table.cell(summary, 0, 3, "Max Profit")
            table.cell(summary, 1, 3, "Move Start and End")

            table.cell(summary, 0, 4, "Side")
            table.cell(summary, 1, 4, "Flat")
````
