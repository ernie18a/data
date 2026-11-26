# BTC Average Daily Returns by Day

- url: https://www.tradingview.com/script/qvoGOVnz-BTC-Average-Daily-Returns-by-Day/
- type: indicator
- pine_id: PUB;6a663708c599448db5bb9efd54efd5a1
- version: 1.0

## Description

[b]Average Daily Returns by Day[/b]

A clean weekday performance dashboard that shows the average daily return for each day of the week using a selectable lookback period.
The script uses daily data internally, so it stays consistent across chart timeframes while letting you view the stats directly on your chart as either a table or a centered top bar.

[b]Features[/b]

[list]
[*]Weekday average returns
[*]1W, 2W, 1M, 3M, 6M, 1Y lookbacks
[*]Table or top bar display
[*]Current-day bias signal built into the UI
[*]Optional heatmap, best/worst day highlight, and sample count
[*]Custom colors and preset themes
[/list]

[b]How to use[/b]

Use it to quickly see whether a market has recently shown stronger or weaker performance on specific weekdays. It works best as a context tool alongside price action, structure, volatility, and broader market conditions.

[b]Important[/b]

This indicator is descriptive, not predictive. Weekday tendencies can shift, especially on shorter lookbacks, so it should not be used as a standalone signal.

[image]https://www.tradingview.com/x/pIUcDmty/[/image]

## Source Code

````pine
//@version=6
indicator("BTC Average Daily Returns by Day", overlay = true)

// ─── Inputs ───────────────────────────────────────────────────────────────────
tickerInput   = input.symbol("BINANCE:BTCUSDT", "Ticker")
lookbackInput = input.string("3 Months", "Lookback Period", options = ["1 Week", "2 Weeks", "1 Month", "3 Months", "6 Months", "1 Year"])

viewMode           = input.string("Table", "Display Mode", options = ["Table", "Top Bar"], group = "Layout")
tableTextSizeInput = input.string("Normal (default)", "Table Size", options = ["Normal (default)", "Medium", "Large"], group = "Layout")

posColorInput = input.color(#00E676, "Positive Color", inline = "Colors")
negColorInput = input.color(#FF1744, "Negative Color", inline = "Colors")
colorTheme    = input.string("Custom", "Color Theme", options = ["Custom", "Bubblegum", "Toxic Waste", "Solar Flare", "Ice Voltage", "Midnight Candy"], group = "Style")

showHeatmap       = input.bool(false, "Heatmap Backgrounds",      group = "Display")
highlightExtremes = input.bool(false, "Highlight Best/Worst Day", group = "Display")
showSampleCount   = input.bool(false, "Show Sample Count",        group = "Display")

showDaySignal = input.bool(true,          "Show Today's Bias Signal", group = "Day Signal")
signalContent = input.string("Arrow + %", "Signal Content",           group = "Day Signal", options = ["Arrow Only", "Arrow + %", "Arrow + Day + %"])
signalOpacity = input.int(20,             "Signal Opacity %",         group = "Day Signal", minval = 0, maxval = 90)

// ─── Theme Colors ─────────────────────────────────────────────────────────────
color posColor = switch colorTheme
    "Bubblegum"      => #FF4FD8
    "Toxic Waste"    => #39FF14
    "Solar Flare"    => #FFD400
    "Ice Voltage"    => #00E5FF
    "Midnight Candy" => #7C4DFF
    => posColorInput

color negColor = switch colorTheme
    "Bubblegum"      => #8A2BE2
    "Toxic Waste"    => #FF007A
    "Solar Flare"    => #FF5A00
    "Ice Voltage"    => #2962FF
    "Midnight Candy" => #FF2DA6
    => negColorInput

// ─── Helpers ──────────────────────────────────────────────────────────────────
getDayName(idx) =>
    switch idx
        1 => "Sunday"
        2 => "Monday"
        3 => "Tuesday"
        4 => "Wednesday"
        5 => "Thursday"
        6 => "Friday"
        7 => "Saturday"
        => ""

getDayShort(idx) =>
    switch idx
        1 => "Sun"
        2 => "Mon"
        3 => "Tue"
        4 => "Wed"
        5 => "Thu"
        6 => "Fri"
        7 => "Sat"
        => ""

getTextSize(sz) =>
    switch sz
        "Medium" => size.normal
        "Large"  => size.large
        => size.small

avgReturnAndCountForWeekday(targetDay, lookbackDays) =>
    float sumRet   = 0.0
    int   countRet = 0
    for i = 1 to lookbackDays
        float currClose = close[i]
        float prevClose = close[i + 1]
        int   dayIdx    = dayofweek(time[i], "UTC")
        if not na(currClose) and not na(prevClose) and prevClose != 0 and dayIdx == targetDay
            sumRet   += (currClose - prevClose) / prevClose * 100.0
            countRet += 1
    float avgRet = countRet > 0 ? sumRet / countRet : na
    [avgRet, countRet]

heatmapBg(avg, maxAbs, positiveColor, negativeColor, enabled) =>
    if na(avg) or not enabled or maxAbs <= 0
        na
    else
        float strength = math.min(math.abs(avg) / maxAbs, 1.0)
        int   transp   = 92 - int(math.round(strength * 32.0))
        color.new(avg >= 0 ? positiveColor : negativeColor, transp)

formatPct(v) =>
    na(v) ? "N/A" : (v >= 0 ? "+" : "") + str.format("{0,number,#.##}%", v)

getSignalText(contentMode, todayDow, todayAvg) =>
    bool   isPos  = todayAvg >= 0
    string arrow  = isPos ? "▲" : "▼"
    string pctStr = formatPct(todayAvg)
    string dayStr = getDayShort(todayDow)

    switch contentMode
        "Arrow Only"    => arrow
        "Arrow + %"     => arrow + " " + pctStr
        =>                 arrow + " " + dayStr + " " + pctStr

// ─── Core Logic ───────────────────────────────────────────────────────────────
int lookbackDays = switch lookbackInput
    "1 Week"   => 7
    "2 Weeks"  => 14
    "1 Month"  => 30
    "3 Months" => 90
    "6 Months" => 180
    "1 Year"   => 365
    => 90

tableTextSize = getTextSize(tableTextSizeInput)

[avgSun, cntSun] = request.security(tickerInput, "D", avgReturnAndCountForWeekday(1, lookbackDays), lookahead = barmerge.lookahead_off, gaps = barmerge.gaps_off)
[avgMon, cntMon] = request.security(tickerInput, "D", avgReturnAndCountForWeekday(2, lookbackDays), lookahead = barmerge.lookahead_off, gaps = barmerge.gaps_off)
[avgTue, cntTue] = request.security(tickerInput, "D", avgReturnAndCountForWeekday(3, lookbackDays), lookahead = barmerge.lookahead_off, gaps = barmerge.gaps_off)
[avgWed, cntWed] = request.security(tickerInput, "D", avgReturnAndCountForWeekday(4, lookbackDays), lookahead = barmerge.lookahead_off, gaps = barmerge.gaps_off)
[avgThu, cntThu] = request.security(tickerInput, "D", avgReturnAndCountForWeekday(5, lookbackDays), lookahead = barmerge.lookahead_off, gaps = barmerge.gaps_off)
[avgFri, cntFri] = request.security(tickerInput, "D", avgReturnAndCountForWeekday(6, lookbackDays), lookahead = barmerge.lookahead_off, gaps = barmerge.gaps_off)
[avgSat, cntSat] = request.security(tickerInput, "D", avgReturnAndCountForWeekday(7, lookbackDays), lookahead = barmerge.lookahead_off, gaps = barmerge.gaps_off)

float[] avgValues   = array.from(avgMon, avgTue, avgWed, avgThu, avgFri, avgSat, avgSun)
int[]   countValues = array.from(cntMon, cntTue, cntWed, cntThu, cntFri, cntSat, cntSun)
int[]   dayOrder    = array.from(2, 3, 4, 5, 6, 7, 1)

float maxAbs   = 0.0
float bestVal  = na
float worstVal = na

for i = 0 to array.size(avgValues) - 1
    float v = array.get(avgValues, i)
    if not na(v)
        maxAbs   := math.max(maxAbs, math.abs(v))
        bestVal  := na(bestVal)  ? v : math.max(bestVal, v)
        worstVal := na(worstVal) ? v : math.min(worstVal, v)

// ─── Today's Bias Signal (for table/top bar only) ────────────────────────────
int todayDow = dayofweek(time, "UTC")

float todayAvg = switch todayDow
    1 => avgSun
    2 => avgMon
    3 => avgTue
    4 => avgWed
    5 => avgThu
    6 => avgFri
    7 => avgSat
    => float(na)

bool hasSignal = showDaySignal and not na(todayAvg)
bool signalPos = hasSignal and todayAvg >= 0
string signalText = hasSignal ? getSignalText(signalContent, todayDow, todayAvg) : ""
color signalTextColor = signalPos ? posColor : negColor
color signalBgColor = hasSignal ? color.new(signalPos ? posColor : negColor, math.min(95, 100 - signalOpacity)) : na

// ─── Tables ───────────────────────────────────────────────────────────────────
var table statsTable = table.new(
     position.top_right, 2, 10,
     bgcolor      = chart.bg_color,
     frame_color  = chart.fg_color,
     frame_width  = 1,
     border_color = chart.fg_color,
     border_width = 1)

var table barTable = table.new(
     position.top_center, 7, 4,
     bgcolor      = chart.bg_color,
     frame_color  = chart.fg_color,
     frame_width  = 1,
     border_color = chart.fg_color,
     border_width = 1)

// ─── Render ───────────────────────────────────────────────────────────────────
if barstate.islast
    table.clear(statsTable, 0, 0, 1, 9)
    table.clear(barTable,   0, 0, 6, 3)

    if viewMode == "Table"
        int headerRow = hasSignal ? 2 : 1
        int firstDataRow = hasSignal ? 3 : 2

        table.cell(statsTable, 0, 0, tickerInput + " (" + lookbackInput + ")", text_color = chart.fg_color, text_size = tableTextSize)
        table.merge_cells(statsTable, 0, 0, 1, 0)

        if hasSignal
            table.cell(statsTable, 0, 1, signalText, text_color = signalTextColor, text_size = tableTextSize, bgcolor = signalBgColor, text_halign = text.align_center)
            table.merge_cells(statsTable, 0, 1, 1, 1)

        table.cell(statsTable, 0, headerRow, "Day",          text_color = chart.fg_color, text_size = tableTextSize, bgcolor = color.new(chart.fg_color, 90))
        table.cell(statsTable, 1, headerRow, "Avg Return %", text_color = chart.fg_color, text_size = tableTextSize, bgcolor = color.new(chart.fg_color, 90))

        for i = 0 to array.size(dayOrder) - 1
            int    dayIdx  = array.get(dayOrder, i)
            float  avg     = array.get(avgValues, i)
            int    count   = array.get(countValues, i)
            bool   isBest  = highlightExtremes and not na(avg) and not na(bestVal)  and avg == bestVal
            bool   isWorst = highlightExtremes and not na(avg) and not na(worstVal) and avg == worstVal

            string dayLabel  = getDayName(dayIdx) + (isBest ? " ▲" : isWorst ? " ▼" : "")
            color  cellColor = na(avg) ? chart.fg_color : avg >= 0 ? posColor : negColor
            color  valueBg   = heatmapBg(avg, maxAbs, posColor, negColor, showHeatmap)
            color  dayBg     = isBest ? color.new(posColor, 88) : isWorst ? color.new(negColor, 88) : na

            string txt = na(avg) ? "N/A" : formatPct(avg)
            if showSampleCount
                txt := na(avg) ? "N/A" : txt + "  (" + str.tostring(count) + ")"

            table.cell(statsTable, 0, firstDataRow + i, dayLabel, text_color = chart.fg_color, text_size = tableTextSize, bgcolor = dayBg)
            table.cell(statsTable, 1, firstDataRow + i, txt,      text_color = cellColor, text_halign = text.align_right, text_size = tableTextSize, bgcolor = valueBg)

    else
        int dayHeaderRow = hasSignal ? 2 : 1
        int valueRow     = hasSignal ? 3 : 2

        table.cell(barTable, 0, 0, tickerInput + " (" + lookbackInput + ")", text_color = chart.fg_color, text_size = tableTextSize)
        table.merge_cells(barTable, 0, 0, 6, 0)

        if hasSignal
            table.cell(barTable, 0, 1, signalText, text_color = signalTextColor, text_size = tableTextSize, bgcolor = signalBgColor, text_halign = text.align_center)
            table.merge_cells(barTable, 0, 1, 6, 1)

        for i = 0 to array.size(dayOrder) - 1
            int    dayIdx  = array.get(dayOrder, i)
            float  avg     = array.get(avgValues, i)
            int    count   = array.get(countValues, i)
            bool   isBest  = highlightExtremes and not na(avg) and not na(bestVal)  and avg == bestVal
            bool   isWorst = highlightExtremes and not na(avg) and not na(worstVal) and avg == worstVal

            string dayLabel  = getDayShort(dayIdx) + (isBest ? " ▲" : isWorst ? " ▼" : "")
            color  cellColor = na(avg) ? chart.fg_color : avg >= 0 ? posColor : negColor
            color  valueBg   = heatmapBg(avg, maxAbs, posColor, negColor, showHeatmap)

            string txt = na(avg) ? "N/A" : formatPct(avg)
            if showSampleCount
                txt := na(avg) ? "N/A" : txt + " (" + str.tostring(count) + ")"

            table.cell(barTable, i, dayHeaderRow, dayLabel, text_color = chart.fg_color, text_size = tableTextSize, bgcolor = color.new(chart.fg_color, 90), text_halign = text.align_center)
            table.cell(barTable, i, valueRow,     txt,      text_color = cellColor,      text_size = tableTextSize, bgcolor = valueBg,                        text_halign = text.align_center)
````
