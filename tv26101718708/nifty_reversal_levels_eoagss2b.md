# Nifty Reversal Levels

- url: https://www.tradingview.com/script/eoAgSS2B-Nifty-Reversal-Levels/
- type: indicator
- pine_id: PUB;07d0bafa9c834bd89b9e20520b374f42
- version: 10.0

## Description

To mark expected reversal levels based on date and time on a Nifty chart

How to set up Alerts on 5-min TF

Switch chart to 5 min
Add indicator → Pine Editor → Paste → Save → Add to chart
Click Alerts (bell icon) → Create Alert
Condition: Nifty Reversal Levels → choose one of the 3 alert conditions
Set "Once Per Bar Close" for the price cross alert

## Source Code

````pine
// // //@version=6
// // indicator("Nifty Reversal Levels", overlay=true, max_lines_count=500, max_labels_count=500, max_bars_back=500)

// // // ═══════════════════════════════════════════════════════
// // //  INPUTS
// // // ═══════════════════════════════════════════════════════
// // priceInput = input.string("24476/24356/24266/24206/24146/24086/24059/23996/23876/23696/23670/23551", "Price Levels (/ separated)")
// // timeInput  = input.string("10:30, 12:45, 14:55",  "Reversal Times (HH:MM, comma separated)")
// // dateInput  = input.string("12/05/2026",          "Date (DD/MM/YYYY)")
// // nBars      = input.int(3, "Reversal Check Candles", minval=1, maxval=20, tooltip="How many candles after a touch to decide Reversal (green) or Broken (red)")

// // showInfoTable  = input.bool(true,                             title = "Show Info Table")
// // priceColor   = input.color(color.yellow,              "Default Level Color")
// // reversalColor = input.color(color.green,              "Respected / Reversal Color")
// // brokenColor  = input.color(color.red,                 "Broken Level Color")
// // timeColor    = input.color(color.orange,              "Time Line Color")
// // lineWidth    = input.int(1, "Line Width", minval=1, maxval=5)


// // // ═══════════════════════════════════════════════════════
// // //  PARSERS - Tewst
// // // ═══════════════════════════════════════════════════════
// // f_parsePrices(raw) =>
// //     float[] out = array.new_float()
// //     for tok in str.split(str.replace_all(raw, " ", ""), "/")
// //         v = str.tonumber(tok)
// //         if not na(v)
// //             array.push(out, v)
// //     out

// // f_parseTimes(raw) =>
// //     int[] out = array.new_int()
// //     for tok in str.split(raw, ",")
// //         trimmed = str.trim(tok)  // TRIM SPACES from each token
// //         parts = str.split(trimmed, ":")
// //         if array.size(parts) == 2
// //             h = str.tonumber(array.get(parts, 0))
// //             m = str.tonumber(array.get(parts, 1))
// //             if not na(h) and not na(m)
// //                 array.push(out, int(h) * 60 + int(m))
// //     out

// // f_parseDate(raw) =>
// //     p = str.split(raw, "/")
// //     [int(str.tonumber(array.get(p, 0))), int(str.tonumber(array.get(p, 1))), int(str.tonumber(array.get(p, 2)))]

// // // ═══════════════════════════════════════════════════════
// // //  STATUS: PRICE LEVEL
// // //  Scans back to find most recent touch of a price level.
// // //  If N candles have closed after the touch:
// // //    → price returned to approach side  = RESPECTED (green)
// // //    → price stayed on breakout side    = BROKEN    (red)
// // //  Not enough candles yet              = PENDING   (yellow)
// // // ═══════════════════════════════════════════════════════
// // f_priceStatus(lvl, n) =>
// //     color result = priceColor   // default: pending / untouched
// //     int   limit  = math.min(300, bar_index)

// //     for k = 0 to limit
// //         // Was this bar a touch? (level lies within the bar's range)
// //         if high[k] >= lvl and low[k] <= lvl
// //             bool fromAbove = close[k + 1] > lvl   // where price came from

// //             if k >= n
// //                 // N candles have already closed after this touch → verdict
// //                 float futClose = close[k - n]
// //                 bool reversed  = fromAbove ? futClose > lvl : futClose < lvl
// //                 result        := reversed ? reversalColor : brokenColor
// //             // else: touch is too recent, leave as pending (yellow)
// //             break   // only care about the most recent touch
// //     result

// // // ═══════════════════════════════════════════════════════
// // //  STATUS: TIME LEVEL
// // //  At the reversal-time bar:
// // //    note the bar's direction (bullish/bearish candle body)
// // //    N candles later: price flipped direction → RESPECTED
// // //                     price kept going        → BROKEN
// // // ═══════════════════════════════════════════════════════
// // f_timeStatus(tMin, tDay, tMonth, tYear, n) =>
// //     color result  = timeColor   // default
// //     int   limit   = math.min(400, bar_index)

// //     for k = 0 to limit
// //         bool matchTime = hour[k] * 60 + minute[k] == tMin
// //         bool matchDate = dayofmonth[k] == tDay and month[k] == tMonth and year[k] == tYear

// //         if matchTime and matchDate
// //             if k >= n
// //                 bool wasUp    = close[k] >= open[k]          // direction AT reversal bar
// //                 float futClose = close[k - n]
// //                 bool reversed  = wasUp ? futClose < close[k] : futClose > close[k]
// //                 result        := reversed ? reversalColor : brokenColor
// //             break
// //     result

// // // ═══════════════════════════════════════════════════════
// // //  PARSE
// // // ═══════════════════════════════════════════════════════
// // priceLevels           = f_parsePrices(priceInput)
// // timeLevels            = f_parseTimes(timeInput)
// // [tDay, tMonth, tYear] = f_parseDate(dateInput)

// // bool isTargetDate = dayofmonth == tDay and month == tMonth and year == tYear
// // int  curMin       = hour * 60 + minute
// // int  prevMin      = hour[1] * 60 + minute[1]

// // // ═══════════════════════════════════════════════════════
// // //  DRAW PRICE LEVELS  (at last bar, with status colour)
// // //  USING VAR TO PREVENT RECREATION ON EVERY UPDATE
// // // ═══════════════════════════════════════════════════════
// // var array<line> priceLines = array.new<line>()
// // var array<label> priceLabels = array.new<label>()

// // if barstate.islast and array.size(priceLines) == 0
// //     for i = 0 to array.size(priceLevels) - 1
// //         lvl    = array.get(priceLevels, i)
// //         clr    = f_priceStatus(lvl, nBars)

// //         newLine = line.new(bar_index - 500, lvl, bar_index, lvl,
// //              extend = extend.right,
// //              color  = clr,
// //              width  = lineWidth)
// //         array.push(priceLines, newLine)

// //         newLabel = label.new(bar_index, lvl,
// //              text      = str.tostring(lvl),
// //              color     = color.new(color.black, 100),
// //              textcolor = clr,
// //              style     = label.style_label_left,
// //              size      = size.small)
// //         array.push(priceLabels, newLabel)

// // // Update colors on every bar (to reflect reversal/broken status)
// // if barstate.islast
// //     for i = 0 to array.size(priceLines) - 1
// //         lvl = array.get(priceLevels, i)
// //         clr = f_priceStatus(lvl, nBars)
// //         line.set_color(array.get(priceLines, i), clr)
// //         label.set_textcolor(array.get(priceLabels, i), clr)

// // // ═══════════════════════════════════════════════════════
// // //  DRAW TIME LEVELS
// // //  Past/current times: draw when bar crosses (existing logic)
// // //  Future times on target date: draw in advance from last bar
// // // ═══════════════════════════════════════════════════════
// // var array<int>   drawnTimes    = array.new<int>()
// // var array<line>  futureLines   = array.new<line>()   // stored so we can wipe+redo each tick
// // var array<label> futureLabels  = array.new<label>()

// // array<color> timeStatuses = array.new<color>()
// // for i = 0 to array.size(timeLevels) - 1
// //     tMin = array.get(timeLevels, i)
// //     clr = f_timeStatus(tMin, tDay, tMonth, tYear, nBars)
// //     array.push(timeStatuses, clr)

// // // ── Past / current times ─────────────────────────────────────────────────────
// // // Guard with barstate.isconfirmed: executes only once per CLOSED bar,
// // // never on intra-bar realtime ticks → prevents stacking.
// // if isTargetDate and barstate.isconfirmed
// //     for i = 0 to array.size(timeLevels) - 1
// //         tMin = array.get(timeLevels, i)
// //         bool crossedIntoTime = prevMin < tMin and curMin >= tMin
// //         bool atExactTime     = curMin == tMin
// //         bool alreadyDrawn    = array.includes(drawnTimes, tMin)

// //         if (crossedIntoTime or atExactTime) and not alreadyDrawn
// //             array.push(drawnTimes, tMin)
// //             clr = array.get(timeStatuses, i)

// //             line.new(bar_index, high, bar_index, low,
// //                  color = clr, width = lineWidth + 1,
// //                  style = line.style_dashed)
// //             label.new(bar_index, high,
// //                  text      = str.tostring(int(tMin/60), "00") + ":" + str.tostring(tMin % 60, "00"),
// //                  color     = color.new(clr, 15),
// //                  textcolor = color.white,
// //                  style     = label.style_label_down,
// //                  size      = size.small)

// // // ── Future times ─────────────────────────────────────────────────────────────
// // // Run on every barstate.islast tick BUT always wipe and recreate from scratch
// // // so there is never more than one set of future labels on screen at a time.
// // if barstate.islast and isTargetDate
// //     // Delete previous future drawings
// //     for ln in futureLines
// //         line.delete(ln)
// //     futureLines.clear()
// //     for lb in futureLabels
// //         label.delete(lb)
// //     futureLabels.clear()

// //     float minsPerBar = timeframe.in_seconds() / 60.0

// //     for i = 0 to array.size(timeLevels) - 1
// //         tMin          = array.get(timeLevels, i)
// //         bool isFuture = tMin > curMin
// //         bool alreadyDrawn = array.includes(drawnTimes, tMin)

// //         if isFuture and not alreadyDrawn
// //             int barsAhead = math.round((tMin - curMin) / minsPerBar)
// //             int futureBar = bar_index + barsAhead

// //             futureLines.push(
// //                  line.new(futureBar, high * 1.002, futureBar, low * 0.998,
// //                      color = timeColor,
// //                      width = lineWidth + 1,
// //                      style = line.style_dashed))
// //             futureLabels.push(
// //                  label.new(futureBar, high * 1.002,
// //                      text      = str.tostring(int(tMin/60), "00") + ":" + str.tostring(tMin % 60, "00") + " ⏳",
// //                      color     = color.new(timeColor, 15),
// //                      textcolor = color.white,
// //                      style     = label.style_label_down,
// //                      size      = size.small))
// // // ═══════════════════════════════════════════════════════
// // //  ALERTS
// // // ═══════════════════════════════════════════════════════
// // bool priceCross = false
// // for i = 0 to array.size(priceLevels) - 1
// //     lvl = array.get(priceLevels, i)
// //     if low <= lvl and high >= lvl
// //         priceCross := true

// // bool timeHit = false
// // for i = 0 to array.size(timeLevels) - 1
// //     tMin = array.get(timeLevels, i)
// //     if (curMin == tMin or (prevMin < tMin and curMin >= tMin)) and isTargetDate
// //         timeHit := true

// // alertcondition(priceCross,            "Price Level Hit",  "Nifty hit price level | {{close}} | {{time}}")
// // alertcondition(timeHit,               "Reversal Time",    "Nifty reversal time reached | {{time}} | {{close}}")
// // alertcondition(priceCross or timeHit, "Any Alert",        "Nifty reversal trigger | {{close}} | {{time}}")



// // // ════════════════════════════════════════════════════════════════
// // //  INFO TABLE  (top-right corner summary)
// // // ════════════════════════════════════════════════════════════════
// // if barstate.islast and showInfoTable
// //     var table infoTbl = table.new(
// //          position          = position.top_right,
// //          columns           = 2,
// //          rows              = 20,
// //          bgcolor           = color.new(color.black, 30),
// //          border_color      = color.new(color.gray, 50),
// //          border_width      = 1,
// //          frame_color       = color.new(color.gray, 20),
// //          frame_width       = 1
// //      )

// //     // Header
// //     table.cell(infoTbl, 0, 0, "NIFTY REVERSAL LEVELS",
// //          bgcolor   = color.new(color.navy, 10),
// //          text_color = color.white,
// //          text_size  = size.small,
// //          text_halign = text.align_center
// //      )
// //     table.cell(infoTbl, 1, 0, dateInput,
// //          bgcolor   = color.new(color.navy, 10),
// //          text_color = color.yellow,
// //          text_size  = size.small,
// //          text_halign = text.align_center
// //      )

// //     // Price levels
// //     table.cell(infoTbl, 0, 1, "📊 PRICE",
// //          bgcolor    = color.new(color.gray, 60),
// //          text_color = color.yellow,
// //          text_size  = size.tiny,
// //          text_halign = text.align_center
// //      )
// //     table.cell(infoTbl, 1, 1, "Distance",
// //          bgcolor    = color.new(color.gray, 60),
// //          text_color = color.yellow,
// //          text_size  = size.tiny,
// //          text_halign = text.align_center
// //      )

// //     nLvls = math.min(array.size(priceLevels), 15)
// //     for i = 0 to nLvls - 1
// //         lvl     = array.get(priceLevels, i)
// //         dist    = close - lvl
// //         distPct = dist / close * 100
// //         isAbove = dist > 0
// //         rowBg   = isAbove
// //              ? color.new(color.green,  75)
// //              : color.new(color.red,    75)
// //         arrow   = isAbove ? "▲ " : "▼ "

// //         table.cell(infoTbl, 0, i + 2,
// //              arrow + str.tostring(lvl, "#.##"),
// //              bgcolor    = rowBg,
// //              text_color =  color.yellow,
// //              text_size  = size.tiny,
// //              text_halign = text.align_center
// //          )
// //         table.cell(infoTbl, 1, i + 2,
// //              str.tostring(math.abs(distPct), "#.00") + "%",
// //              bgcolor    = rowBg,
// //              text_color = color.white,
// //              text_size  = size.tiny,
// //              text_halign = text.align_center
// //          )

// //     // Time levels section
// //     tRow = nLvls + 2
// //     table.cell(infoTbl, 0, tRow, "⏰ REV TIMES",
// //          bgcolor    = color.new(color.gray, 60),
// //          text_color = color.yellow,
// //          text_size  = size.tiny,
// //          text_halign = text.align_center
// //      )
// //     table.cell(infoTbl, 1, tRow, "Status",
// //          bgcolor    = color.new(color.gray, 60),
// //          text_color =  color.yellow,
// //          text_size  = size.tiny,
// //          text_halign = text.align_center
// //      )

// //     for i = 0 to array.size(timeLevels) - 1
// //         tMin    = array.get(timeLevels, i)
// //         hStr    = str.tostring(int(tMin / 60), "00")
// //         mStr    = str.tostring(tMin % 60, "00")
// //         isPast  = (isTargetDate and curMin > tMin) or
// //                   (year > tYear) or
// //                   (year == tYear and month > tMonth) or
// //                   (year == tYear and month == tMonth and dayofmonth > tDay)
// //         isCurr  = isTargetDate and curMin == tMin
// //         status  = isCurr ? "🔴 NOW" : isPast ? "✅ Done" : "⏳ Upcoming"
// //         rowBg   = isCurr
// //              ? color.new(color.red,    30)
// //              : isPast
// //                ? color.new(color.gray, 70)
// //                : color.new(color.blue, 60)

// //         table.cell(infoTbl, 0, tRow + i + 1,
// //              hStr + ":" + mStr,
// //              bgcolor    = rowBg,
// //              text_color =  color.yellow,
// //              text_size  = size.tiny,
// //              text_halign = text.align_center
// //          )
// //         table.cell(infoTbl, 1, tRow + i + 1,
// //              status,
// //              bgcolor    = rowBg,
// //              text_color = color.white,
// //              text_size  = size.tiny,
// //              text_halign = text.align_center
// //          )


// //@version=6
// indicator("Nifty Key Levels + Gann Square (10:00 AM)", overlay=true, max_lines_count=500, max_labels_count=500, max_bars_back=500)

// // ═══════════════════════════════════════════════════════
// //  INPUTS
// // ═══════════════════════════════════════════════════════
// showInfoTable = input.bool(true, title = "Show Gann Table")

// // (Keeping your old line inputs in case you still want the lines drawn on the chart)
// priceInput = input.string("24476/24356/24266/24206/24146/24086/24059/23996/23876/23696/23670/23551", "Price Levels (/ separated)", group="Old Chart Lines")
// timeInput  = input.string("10:30, 12:45, 14:55",  "Reversal Times (HH:MM, comma separated)", group="Old Chart Lines")
// nBars      = input.int(3, "Reversal Check Candles", minval=1, maxval=20, group="Old Chart Lines")
// priceColor    = input.color(color.yellow, "Default Level Color", group="Old Chart Lines")
// reversalColor = input.color(color.green,  "Respected / Reversal Color", group="Old Chart Lines")
// brokenColor   = input.color(color.red,    "Broken Level Color", group="Old Chart Lines")
// timeColor     = input.color(color.orange, "Time Line Color", group="Old Chart Lines")
// lineWidth     = input.int(1, "Line Width", minval=1, maxval=5, group="Old Chart Lines")


//@version=6
indicator("Nifty Vedic Reversal + Gann Square (10:00 AM)", overlay=true, max_lines_count=500, max_labels_count=500, max_bars_back=500)


// ═══════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════

// --- Gann Table Settings ---
showInfoTable = input.bool(true, title = "Show Gann Table", group="Gann Table Settings")
tablePosStr   = input.string("Top Right", "Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group="Gann Table Settings")

// --- 10:00 AM Line Settings ---
show10AmLine  = input.bool(true, "Draw 10:00 AM Vertical Line", group="10:00 AM Line Settings")
line10AmColor = input.color(color.new(#7c3aed, 0), "Line Color", group="10:00 AM Line Settings")
line10AmWidth = input.int(2, "Line Width", minval=1, maxval=5, group="10:00 AM Line Settings")
line10AmStyleStr = input.string("Dashed", "Line Style", options=["Solid", "Dotted", "Dashed"], group="10:00 AM Line Settings")

// --- Old Chart Lines (Hidden from Table) ---
priceInput = input.string("24476/24356/24266/24206/24146/24086/24059/23996/23876/23696/23670/23551", "Price Levels (/ separated)", group="Old Chart Lines")
timeInput  = input.string("10:30, 12:45, 14:55",  "Reversal Times (HH:MM, comma separated)", group="Old Chart Lines")
nBars      = input.int(3, "Reversal Check Candles", minval=1, maxval=20, group="Old Chart Lines")
priceColor    = input.color(color.yellow, "Default Level Color", group="Old Chart Lines")
reversalColor = input.color(color.green,  "Respected / Reversal Color", group="Old Chart Lines")
brokenColor   = input.color(color.red,    "Broken Level Color", group="Old Chart Lines")
timeColor     = input.color(color.orange, "Time Line Color", group="Old Chart Lines")
lineWidth     = input.int(1, "Line Width", minval=1, maxval=5, group="Old Chart Lines")


// ═══════════════════════════════════════════════════════
//  GANN SQUARE OF 9 (10:00 AM IST CAPTURE)
// ═══════════════════════════════════════════════════════
var float gannAnchorPrice = na
var float buyAbove = na
var float sellBelow = na
var float buyT1 = na
var float buyT2 = na
var float buyT3 = na
var float sellT1 = na
var float sellT2 = na
var float sellT3 = na

line10AmStyle = line10AmStyleStr == "Solid" ? line.style_solid : line10AmStyleStr == "Dotted" ? line.style_dotted : line.style_dashed

// Capture 10:00 AM close every day natively (Works perfectly in Replay Mode)
if hour(time_close, "Asia/Kolkata") == 10 and minute(time_close, "Asia/Kolkata") == 0
    gannAnchorPrice := close
    buyAbove := na // Reset so it recalculates for the new day
    
    // Draw Vertical Line
    if show10AmLine
        line.new(bar_index, low, bar_index, high, extend=extend.both, color=line10AmColor, width=line10AmWidth, style=line10AmStyle)

// Calculate Gann Levels
if not na(gannAnchorPrice) and na(buyAbove)
    float baseSqrt = math.floor(math.sqrt(gannAnchorPrice))
    float centerSqrt = baseSqrt - 1
    
    float lowerVal = na
    float upperVal = na
    int lowerIdx = 0
    
    for i = 0 to 24
        float val = math.pow(centerSqrt + (i * 0.125), 2)
        float nextVal = math.pow(centerSqrt + ((i+1) * 0.125), 2)
        if gannAnchorPrice >= val and gannAnchorPrice < nextVal
            lowerIdx := i
            lowerVal := val
            upperVal := nextVal
            break
            
    sellBelow := lowerVal
    buyAbove  := upperVal
    
    // Applying the 0.05% margin of safety offset
    buyT1 := math.pow(centerSqrt + ((lowerIdx + 2) * 0.125), 2) * 0.9995
    buyT2 := math.pow(centerSqrt + ((lowerIdx + 3) * 0.125), 2) * 0.9995
    buyT3 := math.pow(centerSqrt + ((lowerIdx + 4) * 0.125), 2) * 0.9995
    
    sellT1 := math.pow(centerSqrt + ((lowerIdx - 1) * 0.125), 2) * 1.0005
    sellT2 := math.pow(centerSqrt + ((lowerIdx - 2) * 0.125), 2) * 1.0005
    sellT3 := math.pow(centerSqrt + ((lowerIdx - 3) * 0.125), 2) * 1.0005


// ════════════════════════════════════════════════════════════════
//  CLEAN GANN INFO TABLE
// ════════════════════════════════════════════════════════════════
if barstate.islast and showInfoTable
    pos = tablePosStr == "Top Right" ? position.top_right : tablePosStr == "Top Left" ? position.top_left : tablePosStr == "Bottom Right" ? position.bottom_right : position.bottom_left
    var table infoTbl = table.new(position = pos, columns = 2, rows = 6, bgcolor = color.new(color.black, 30), border_color = color.new(color.gray, 50), border_width = 1, frame_color = color.new(color.gray, 20), frame_width = 1)

    table.merge_cells(infoTbl, 0, 0, 1, 0)
    table.cell(infoTbl, 0, 0, "GANN SQUARE OF 9", bgcolor = color.new(#7c3aed, 20), text_color = color.white, text_size = size.normal, text_halign = text.align_center)
    
    table.merge_cells(infoTbl, 0, 1, 1, 1)
    table.cell(infoTbl, 0, 1, "10:00 AM Anchor: " + (na(gannAnchorPrice) ? "Waiting..." : str.tostring(gannAnchorPrice, "#.00")), bgcolor = color.new(color.navy, 30), text_color = color.yellow, text_size = size.small, text_halign = text.align_center)
     
    if not na(gannAnchorPrice)
        table.cell(infoTbl, 0, 2, "BUY > " + str.tostring(buyAbove, "#.00"), bgcolor=color.new(color.green, 80), text_color=color.green, text_size=size.small)
        table.cell(infoTbl, 1, 2, "T1: " + str.tostring(buyT1, "#") + " | T2: " + str.tostring(buyT2, "#") + " | T3: " + str.tostring(buyT3, "#"), bgcolor=color.new(color.green, 80), text_color=color.white, text_size=size.small)
        
        table.cell(infoTbl, 0, 3, "SELL < " + str.tostring(sellBelow, "#.00"), bgcolor=color.new(color.red, 80), text_color=color.red, text_size=size.small)
        table.cell(infoTbl, 1, 3, "T1: " + str.tostring(sellT1, "#") + " | T2: " + str.tostring(sellT2, "#") + " | T3: " + str.tostring(sellT3, "#"), bgcolor=color.new(color.red, 80), text_color=color.white, text_size=size.small)


// ═══════════════════════════════════════════════════════
//  OLD CHART DRAWING LOGIC (Lines & Future Time Labels)
// ═══════════════════════════════════════════════════════
f_parsePrices(raw) =>
    float[] out = array.new_float()
    for tok in str.split(str.replace_all(raw, " ", ""), "/")
        v = str.tonumber(tok)
        if not na(v)
            array.push(out, v)
    out

f_parseTimes(raw) =>
    int[] out = array.new_int()
    for tok in str.split(raw, ",")
        trimmed = str.trim(tok)
        parts = str.split(trimmed, ":")
        if array.size(parts) == 2
            h = str.tonumber(array.get(parts, 0))
            m = str.tonumber(array.get(parts, 1))
            if not na(h) and not na(m)
                array.push(out, int(h) * 60 + int(m))
    out

priceLevels = f_parsePrices(priceInput)
timeLevels  = f_parseTimes(timeInput)
int curMin  = hour(time, "Asia/Kolkata") * 60 + minute(time, "Asia/Kolkata")
int prevMin = hour(time[1], "Asia/Kolkata") * 60 + minute(time[1], "Asia/Kolkata")

f_priceStatus(lvl, n) =>
    color result = priceColor
    int limit = math.min(300, bar_index)
    for k = 0 to limit
        if high[k] >= lvl and low[k] <= lvl
            bool fromAbove = close[k + 1] > lvl
            if k >= n
                float futClose = close[k - n]
                bool reversed = fromAbove ? futClose > lvl : futClose < lvl
                result := reversed ? reversalColor : brokenColor
            break
    result

f_timeStatus(tMin, n) =>
    color result = timeColor
    int limit = math.min(400, bar_index)
    for k = 0 to limit
        if hour(time[k], "Asia/Kolkata") * 60 + minute(time[k], "Asia/Kolkata") == tMin
            if k >= n
                bool wasUp = close[k] >= open[k]
                float futClose = close[k - n]
                bool reversed = wasUp ? futClose < close[k] : futClose > close[k]
                result := reversed ? reversalColor : brokenColor
            break
    result

var array<line> priceLines = array.new<line>()
var array<label> priceLabels = array.new<label>()

if barstate.islast and array.size(priceLines) == 0
    for i = 0 to array.size(priceLevels) - 1
        lvl = array.get(priceLevels, i)
        clr = f_priceStatus(lvl, nBars)
        newLine = line.new(bar_index - 500, lvl, bar_index, lvl, extend = extend.right, color = clr, width = lineWidth)
        array.push(priceLines, newLine)
        newLabel = label.new(bar_index, lvl, text = str.tostring(lvl), color = color.new(color.black, 100), textcolor = clr, style = label.style_label_left, size = size.small)
        array.push(priceLabels, newLabel)

if barstate.islast
    for i = 0 to array.size(priceLines) - 1
        lvl = array.get(priceLevels, i)
        clr = f_priceStatus(lvl, nBars)
        line.set_color(array.get(priceLines, i), clr)
        label.set_textcolor(array.get(priceLabels, i), clr)


// --- NEW DAY RESET FOR REPLAY MODE ---
var array<int> drawnTimes = array.new<int>()
var int lastSeenDay = dayofmonth(time, "Asia/Kolkata")

if dayofmonth(time, "Asia/Kolkata") != lastSeenDay
    array.clear(drawnTimes)
    lastSeenDay := dayofmonth(time, "Asia/Kolkata")

array<color> timeStatuses = array.new<color>()
for i = 0 to array.size(timeLevels) - 1
    tMin = array.get(timeLevels, i)
    clr = f_timeStatus(tMin, nBars)
    array.push(timeStatuses, clr)

if barstate.isconfirmed
    for i = 0 to array.size(timeLevels) - 1
        tMin = array.get(timeLevels, i)
        if (prevMin < tMin and curMin >= tMin) or (curMin == tMin)
            if not array.includes(drawnTimes, tMin)
                array.push(drawnTimes, tMin)
                clr = array.get(timeStatuses, i)
                line.new(bar_index, high, bar_index, low, color = clr, width = lineWidth + 1, style = line.style_dashed)
                label.new(bar_index, high, text = str.tostring(int(tMin/60), "00") + ":" + str.tostring(tMin % 60, "00"), color = color.new(clr, 15), textcolor = color.white, style = label.style_label_down, size = size.small)


// --- Restore Future Time Labels (Hourglass) ---
var array<line>  futureLines  = array.new<line>()
var array<label> futureLabels = array.new<label>()

if barstate.islast
    for ln in futureLines
        line.delete(ln)
    futureLines.clear()
    for lb in futureLabels
        label.delete(lb)
    futureLabels.clear()

    float minsPerBar = timeframe.in_seconds() / 60.0
    for i = 0 to array.size(timeLevels) - 1
        tMin = array.get(timeLevels, i)
        if tMin > curMin and not array.includes(drawnTimes, tMin)
            int barsAhead = math.round((tMin - curMin) / minsPerBar)
            int futureBar = bar_index + barsAhead
            futureLines.push(line.new(futureBar, high * 1.002, futureBar, low * 0.998, color = timeColor, width = lineWidth + 1, style = line.style_dashed))
            futureLabels.push(label.new(futureBar, high * 1.002, text = str.tostring(int(tMin/60), "00") + ":" + str.tostring(tMin % 60, "00") + " ⏳", color = color.new(timeColor, 15), textcolor = color.white, style = label.style_label_down, size = size.small))
````
