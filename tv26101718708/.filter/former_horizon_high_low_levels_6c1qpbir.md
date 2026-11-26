# Former Horizon | High & Low Levels

- url: https://www.tradingview.com/script/6c1QPBIr-Former-Horizon-High-Low-Levels/
- type: indicator
- pine_id: PUB;c516e5138da84b79af37ead0c099fff3
- version: 2.0

## Description

Track key price levels with customisable horizontal lines anchored to the candle wicks that created them.
Displays previous day high and low (PDH / PDL), previous week high and low (PWH / PWL), previous month high and low (PMH / PML), plus optional developing current-day highs and lows.
Four additional high/low pairs support selectable timeframes or manually entered prices, with editable labels.
Customise each line independently:
- Colour, width and solid, dashed or dotted style
- Length in bars
- Label text, colour and font size
- Individual visibility
Choose to extend lines beyond the latest candle or use a fixed length from the originating wick. Optional price values can appear beside each label. When multiple candles share the same extreme, the first matching wick is used.
Previous-period levels use completed candles and follow the symbol’s exchange/session calendar. Automatic levels require a source timeframe equal to or higher than the chart timeframe, with sufficient chart history to locate the originating wick. Manual-price markers start at the latest candle.
Designed for standard time-based candlestick charts.

## Source Code

````pine
//@version=6
indicator("Horizon | High & Low Levels", overlay = true, max_lines_count = 32, max_labels_count = 32)
// Latest levels only. Periods follow the symbol's exchange/session calendar.
levelSource = input.string("Chart candles", "Automatic level source", options = ["Chart candles", "Official source candles"], tooltip = "Chart candles uses the extremes of loaded chart bars within each source period. Official source candles requires an exact matching chart wick and can hide levels when feeds differ.", group = "Layout")
showLabels = input.bool(true, "Show labels", group = "Layout")
showPrices = input.bool(false, "Include price in labels", group = "Layout")
lengthMode = input.string("Extend past latest candle", "Line length mode", options = ["Extend past latest candle", "Fixed length from wick"], group = "Layout")
labelGap = input.int(1, "Label gap (bars)", minval = 0, maxval = 50, group = "Layout")
f_style(string value) =>
    switch value
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid
f_size(string value) =>
    switch value
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        "Large" => size.large
        => size.huge
// Offsets plus lookahead_on return the last completed source candle.
f_previous(string tf) =>
    request.security(syminfo.tickerid, tf, [high[1], low[1]], lookahead = barmerge.lookahead_on)
f_supported(string tf) =>
    timeframe.in_seconds(tf) >= timeframe.in_seconds()
// Retain chart timestamps for old wick anchors (up to 100,000 chart bars).
var array<int> candleTimes = array.new<int>()
if array.size(candleTimes) >= 100000
    array.shift(candleTimes)
array.push(candleTimes, time)
f_barTime(int index) =>
    int firstIndex = bar_index - array.size(candleTimes) + 1
    int result = na
    if not na(index)
        if index >= firstIndex and index <= bar_index
            result := array.get(candleTimes, index - firstIndex)
        else if index > bar_index
            // Estimated future spacing; closures can change actual candle times.
            result := time + int((index - bar_index) * timeframe.in_seconds() * 1000)
    result
// Equal extremes retain the first wick. Each written call has independent state.
f_wicks(string tf) =>
    var bool fullPeriod = false
    var float hi = na
    var float lo = na
    var int hb = na
    var int lb = na
    var float ph = na
    var float pl = na
    var int phb = na
    var int plb = na
    if timeframe.change(tf) or na(hi)
        ph := hi
        pl := lo
        phb := hb
        plb := lb
        ph := fullPeriod ? hi : na
        pl := fullPeriod ? lo : na
        phb := fullPeriod ? hb : na
        plb := fullPeriod ? lb : na
        fullPeriod := not barstate.isfirst or time == time(tf)
        hi := high
        lo := low
        hb := bar_index
        lb := bar_index
    else
        if high > hi
            hi := high
            hb := bar_index
        if low < lo
            lo := low
            lb := bar_index
    [hi, lo, hb, lb, ph, pl, phb, plb]
f_match(float sourcePrice, float observedPrice, int anchor) =>
    not na(sourcePrice) and not na(observedPrice) and math.abs(sourcePrice - observedPrice) < syminfo.mintick * 0.5 ? anchor : int(na)
f_draw(bool enabled, float price, int originBar, string caption, color lineColor, color textColor, string styleName, int width, int length, string fontSize) =>
    var line levelLine = na
    var label levelLabel = na
    if barstate.islast
        if enabled and not na(price) and not na(f_barTime(originBar))
            int endBar = (lengthMode == "Fixed length from wick" ? originBar : bar_index) + length
            int startTime = f_barTime(originBar)
            int endTime = f_barTime(endBar)
            if na(levelLine)
                levelLine := line.new(startTime, price, endTime, price, xloc = xloc.bar_time, force_overlay = true)
            line.set_xy1(levelLine, startTime, price)
            line.set_xy2(levelLine, endTime, price)
            line.set_color(levelLine, lineColor)
            line.set_style(levelLine, f_style(styleName))
            line.set_width(levelLine, width)
            if showLabels
                string labelText = caption + (showPrices ? "  " + str.tostring(price, format.mintick) : "")
                if na(levelLabel)
                    levelLabel := label.new(f_barTime(endBar + labelGap), price, labelText, xloc = xloc.bar_time, style = label.style_none, textalign = text.align_left, force_overlay = true)
                label.set_xy(levelLabel, f_barTime(endBar + labelGap), price)
                label.set_text(levelLabel, labelText)
                label.set_textcolor(levelLabel, textColor)
                label.set_size(levelLabel, f_size(fontSize))
            else
                label.delete(levelLabel)
                levelLabel := na
        else
            line.delete(levelLine)
            label.delete(levelLabel)
            levelLine := na
            levelLabel := na
    true // Explicit, consistent function return value.
pdEnabled = input.bool(true, "Enable pair", group = "01 | Previous day")
pdhShow = input.bool(true, "High", inline = "pdhmain", group = "01 | Previous day")
pdhName = input.string("PDH", "Label", inline = "pdhmain", group = "01 | Previous day")
pdhColor = input.color(#26A69A, "High line", inline = "pdhcolor", group = "01 | Previous day")
pdhText = input.color(#26A69A, "Text", inline = "pdhcolor", group = "01 | Previous day")
pdhStyle = input.string("Solid", "High style", options = ["Solid", "Dashed", "Dotted"], inline = "pdhstyle", group = "01 | Previous day")
pdhWidth = input.int(1, "Width", minval = 1, maxval = 5, inline = "pdhstyle", group = "01 | Previous day")
pdhLength = input.int(40, "High length (bars)", minval = 1, maxval = 5000, group = "01 | Previous day")
pdhSize = input.string("Small", "High label size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = "01 | Previous day")
pdlShow = input.bool(true, "Low", inline = "pdlmain", group = "01 | Previous day")
pdlName = input.string("PDL", "Label", inline = "pdlmain", group = "01 | Previous day")
pdlColor = input.color(#EF5350, "Low line", inline = "pdlcolor", group = "01 | Previous day")
pdlText = input.color(#EF5350, "Text", inline = "pdlcolor", group = "01 | Previous day")
pdlStyle = input.string("Solid", "Low style", options = ["Solid", "Dashed", "Dotted"], inline = "pdlstyle", group = "01 | Previous day")
pdlWidth = input.int(1, "Width", minval = 1, maxval = 5, inline = "pdlstyle", group = "01 | Previous day")
pdlLength = input.int(40, "Low length (bars)", minval = 1, maxval = 5000, group = "01 | Previous day")
pdlSize = input.string("Small", "Low label size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = "01 | Previous day")
pwEnabled = input.bool(true, "Enable pair", group = "02 | Previous week")
pwhShow = input.bool(true, "High", inline = "pwhmain", group = "02 | Previous week")
pwhName = input.string("PWH", "Label", inline = "pwhmain", group = "02 | Previous week")
pwhColor = input.color(#26A69A, "High line", inline = "pwhcolor", group = "02 | Previous week")
pwhText = input.color(#26A69A, "Text", inline = "pwhcolor", group = "02 | Previous week")
pwhStyle = input.string("Solid", "High style", options = ["Solid", "Dashed", "Dotted"], inline = "pwhstyle", group = "02 | Previous week")
pwhWidth = input.int(1, "Width", minval = 1, maxval = 5, inline = "pwhstyle", group = "02 | Previous week")
pwhLength = input.int(40, "High length (bars)", minval = 1, maxval = 5000, group = "02 | Previous week")
pwhSize = input.string("Small", "High label size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = "02 | Previous week")
pwlShow = input.bool(true, "Low", inline = "pwlmain", group = "02 | Previous week")
pwlName = input.string("PWL", "Label", inline = "pwlmain", group = "02 | Previous week")
pwlColor = input.color(#EF5350, "Low line", inline = "pwlcolor", group = "02 | Previous week")
pwlText = input.color(#EF5350, "Text", inline = "pwlcolor", group = "02 | Previous week")
pwlStyle = input.string("Solid", "Low style", options = ["Solid", "Dashed", "Dotted"], inline = "pwlstyle", group = "02 | Previous week")
pwlWidth = input.int(1, "Width", minval = 1, maxval = 5, inline = "pwlstyle", group = "02 | Previous week")
pwlLength = input.int(40, "Low length (bars)", minval = 1, maxval = 5000, group = "02 | Previous week")
pwlSize = input.string("Small", "Low label size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = "02 | Previous week")
pmEnabled = input.bool(true, "Enable pair", group = "03 | Previous month")
pmhShow = input.bool(true, "High", inline = "pmhmain", group = "03 | Previous month")
pmhName = input.string("PMH", "Label", inline = "pmhmain", group = "03 | Previous month")
pmhColor = input.color(#26A69A, "High line", inline = "pmhcolor", group = "03 | Previous month")
pmhText = input.color(#26A69A, "Text", inline = "pmhcolor", group = "03 | Previous month")
pmhStyle = input.string("Solid", "High style", options = ["Solid", "Dashed", "Dotted"], inline = "pmhstyle", group = "03 | Previous month")
pmhWidth = input.int(1, "Width", minval = 1, maxval = 5, inline = "pmhstyle", group = "03 | Previous month")
pmhLength = input.int(40, "High length (bars)", minval = 1, maxval = 5000, group = "03 | Previous month")
pmhSize = input.string("Small", "High label size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = "03 | Previous month")
pmlShow = input.bool(true, "Low", inline = "pmlmain", group = "03 | Previous month")
pmlName = input.string("PML", "Label", inline = "pmlmain", group = "03 | Previous month")
pmlColor = input.color(#EF5350, "Low line", inline = "pmlcolor", group = "03 | Previous month")
pmlText = input.color(#EF5350, "Text", inline = "pmlcolor", group = "03 | Previous month")
pmlStyle = input.string("Solid", "Low style", options = ["Solid", "Dashed", "Dotted"], inline = "pmlstyle", group = "03 | Previous month")
pmlWidth = input.int(1, "Width", minval = 1, maxval = 5, inline = "pmlstyle", group = "03 | Previous month")
pmlLength = input.int(40, "Low length (bars)", minval = 1, maxval = 5000, group = "03 | Previous month")
pmlSize = input.string("Small", "Low label size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = "03 | Previous month")
cdEnabled = input.bool(false, "Enable pair", group = "04 | Current day")
cdhShow = input.bool(true, "High", inline = "cdhmain", group = "04 | Current day")
cdhName = input.string("DH", "Label", inline = "cdhmain", group = "04 | Current day")
cdhColor = input.color(#26A69A, "High line", inline = "cdhcolor", group = "04 | Current day")
cdhText = input.color(#26A69A, "Text", inline = "cdhcolor", group = "04 | Current day")
cdhStyle = input.string("Solid", "High style", options = ["Solid", "Dashed", "Dotted"], inline = "cdhstyle", group = "04 | Current day")
cdhWidth = input.int(1, "Width", minval = 1, maxval = 5, inline = "cdhstyle", group = "04 | Current day")
cdhLength = input.int(40, "High length (bars)", minval = 1, maxval = 5000, group = "04 | Current day")
cdhSize = input.string("Small", "High label size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = "04 | Current day")
cdlShow = input.bool(true, "Low", inline = "cdlmain", group = "04 | Current day")
cdlName = input.string("DL", "Label", inline = "cdlmain", group = "04 | Current day")
cdlColor = input.color(#EF5350, "Low line", inline = "cdlcolor", group = "04 | Current day")
cdlText = input.color(#EF5350, "Text", inline = "cdlcolor", group = "04 | Current day")
cdlStyle = input.string("Solid", "Low style", options = ["Solid", "Dashed", "Dotted"], inline = "cdlstyle", group = "04 | Current day")
cdlWidth = input.int(1, "Width", minval = 1, maxval = 5, inline = "cdlstyle", group = "04 | Current day")
cdlLength = input.int(40, "Low length (bars)", minval = 1, maxval = 5000, group = "04 | Current day")
cdlSize = input.string("Small", "Low label size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = "04 | Current day")
c1Enabled = input.bool(false, "Enable pair", group = "05 | Custom pair 1")
c1Mode = input.string("Previous candle", "Source", options = ["Previous candle", "Manual prices"], group = "05 | Custom pair 1")
c1Tf = input.timeframe("240", "Source timeframe", group = "05 | Custom pair 1")
c1ManualHigh = input.float(0.0, "Manual high price", group = "05 | Custom pair 1")
c1ManualLow = input.float(0.0, "Manual low price", group = "05 | Custom pair 1")
c1hShow = input.bool(true, "High", inline = "c1hmain", group = "05 | Custom pair 1")
c1hName = input.string("4H H", "Label", inline = "c1hmain", group = "05 | Custom pair 1")
c1hColor = input.color(#26A69A, "High line", inline = "c1hcolor", group = "05 | Custom pair 1")
c1hText = input.color(#26A69A, "Text", inline = "c1hcolor", group = "05 | Custom pair 1")
c1hStyle = input.string("Solid", "High style", options = ["Solid", "Dashed", "Dotted"], inline = "c1hstyle", group = "05 | Custom pair 1")
c1hWidth = input.int(1, "Width", minval = 1, maxval = 5, inline = "c1hstyle", group = "05 | Custom pair 1")
c1hLength = input.int(40, "High length (bars)", minval = 1, maxval = 5000, group = "05 | Custom pair 1")
c1hSize = input.string("Small", "High label size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = "05 | Custom pair 1")
c1lShow = input.bool(true, "Low", inline = "c1lmain", group = "05 | Custom pair 1")
c1lName = input.string("4H L", "Label", inline = "c1lmain", group = "05 | Custom pair 1")
c1lColor = input.color(#EF5350, "Low line", inline = "c1lcolor", group = "05 | Custom pair 1")
c1lText = input.color(#EF5350, "Text", inline = "c1lcolor", group = "05 | Custom pair 1")
c1lStyle = input.string("Solid", "Low style", options = ["Solid", "Dashed", "Dotted"], inline = "c1lstyle", group = "05 | Custom pair 1")
c1lWidth = input.int(1, "Width", minval = 1, maxval = 5, inline = "c1lstyle", group = "05 | Custom pair 1")
c1lLength = input.int(40, "Low length (bars)", minval = 1, maxval = 5000, group = "05 | Custom pair 1")
c1lSize = input.string("Small", "Low label size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = "05 | Custom pair 1")
c2Enabled = input.bool(false, "Enable pair", group = "06 | Custom pair 2")
c2Mode = input.string("Previous candle", "Source", options = ["Previous candle", "Manual prices"], group = "06 | Custom pair 2")
c2Tf = input.timeframe("480", "Source timeframe", group = "06 | Custom pair 2")
c2ManualHigh = input.float(0.0, "Manual high price", group = "06 | Custom pair 2")
c2ManualLow = input.float(0.0, "Manual low price", group = "06 | Custom pair 2")
c2hShow = input.bool(true, "High", inline = "c2hmain", group = "06 | Custom pair 2")
c2hName = input.string("8H H", "Label", inline = "c2hmain", group = "06 | Custom pair 2")
c2hColor = input.color(#26A69A, "High line", inline = "c2hcolor", group = "06 | Custom pair 2")
c2hText = input.color(#26A69A, "Text", inline = "c2hcolor", group = "06 | Custom pair 2")
c2hStyle = input.string("Solid", "High style", options = ["Solid", "Dashed", "Dotted"], inline = "c2hstyle", group = "06 | Custom pair 2")
c2hWidth = input.int(1, "Width", minval = 1, maxval = 5, inline = "c2hstyle", group = "06 | Custom pair 2")
c2hLength = input.int(40, "High length (bars)", minval = 1, maxval = 5000, group = "06 | Custom pair 2")
c2hSize = input.string("Small", "High label size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = "06 | Custom pair 2")
c2lShow = input.bool(true, "Low", inline = "c2lmain", group = "06 | Custom pair 2")
c2lName = input.string("8H L", "Label", inline = "c2lmain", group = "06 | Custom pair 2")
c2lColor = input.color(#EF5350, "Low line", inline = "c2lcolor", group = "06 | Custom pair 2")
c2lText = input.color(#EF5350, "Text", inline = "c2lcolor", group = "06 | Custom pair 2")
c2lStyle = input.string("Solid", "Low style", options = ["Solid", "Dashed", "Dotted"], inline = "c2lstyle", group = "06 | Custom pair 2")
c2lWidth = input.int(1, "Width", minval = 1, maxval = 5, inline = "c2lstyle", group = "06 | Custom pair 2")
c2lLength = input.int(40, "Low length (bars)", minval = 1, maxval = 5000, group = "06 | Custom pair 2")
c2lSize = input.string("Small", "Low label size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = "06 | Custom pair 2")
c3Enabled = input.bool(false, "Enable pair", group = "07 | Custom pair 3")
c3Mode = input.string("Previous candle", "Source", options = ["Previous candle", "Manual prices"], group = "07 | Custom pair 3")
c3Tf = input.timeframe("60", "Source timeframe", group = "07 | Custom pair 3")
c3ManualHigh = input.float(0.0, "Manual high price", group = "07 | Custom pair 3")
c3ManualLow = input.float(0.0, "Manual low price", group = "07 | Custom pair 3")
c3hShow = input.bool(true, "High", inline = "c3hmain", group = "07 | Custom pair 3")
c3hName = input.string("1H H", "Label", inline = "c3hmain", group = "07 | Custom pair 3")
c3hColor = input.color(#26A69A, "High line", inline = "c3hcolor", group = "07 | Custom pair 3")
c3hText = input.color(#26A69A, "Text", inline = "c3hcolor", group = "07 | Custom pair 3")
c3hStyle = input.string("Solid", "High style", options = ["Solid", "Dashed", "Dotted"], inline = "c3hstyle", group = "07 | Custom pair 3")
c3hWidth = input.int(1, "Width", minval = 1, maxval = 5, inline = "c3hstyle", group = "07 | Custom pair 3")
c3hLength = input.int(40, "High length (bars)", minval = 1, maxval = 5000, group = "07 | Custom pair 3")
c3hSize = input.string("Small", "High label size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = "07 | Custom pair 3")
c3lShow = input.bool(true, "Low", inline = "c3lmain", group = "07 | Custom pair 3")
c3lName = input.string("1H L", "Label", inline = "c3lmain", group = "07 | Custom pair 3")
c3lColor = input.color(#EF5350, "Low line", inline = "c3lcolor", group = "07 | Custom pair 3")
c3lText = input.color(#EF5350, "Text", inline = "c3lcolor", group = "07 | Custom pair 3")
c3lStyle = input.string("Solid", "Low style", options = ["Solid", "Dashed", "Dotted"], inline = "c3lstyle", group = "07 | Custom pair 3")
c3lWidth = input.int(1, "Width", minval = 1, maxval = 5, inline = "c3lstyle", group = "07 | Custom pair 3")
c3lLength = input.int(40, "Low length (bars)", minval = 1, maxval = 5000, group = "07 | Custom pair 3")
c3lSize = input.string("Small", "Low label size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = "07 | Custom pair 3")
c4Enabled = input.bool(false, "Enable pair", group = "08 | Custom pair 4")
c4Mode = input.string("Previous candle", "Source", options = ["Previous candle", "Manual prices"], group = "08 | Custom pair 4")
c4Tf = input.timeframe("120", "Source timeframe", group = "08 | Custom pair 4")
c4ManualHigh = input.float(0.0, "Manual high price", group = "08 | Custom pair 4")
c4ManualLow = input.float(0.0, "Manual low price", group = "08 | Custom pair 4")
c4hShow = input.bool(true, "High", inline = "c4hmain", group = "08 | Custom pair 4")
c4hName = input.string("2H H", "Label", inline = "c4hmain", group = "08 | Custom pair 4")
c4hColor = input.color(#26A69A, "High line", inline = "c4hcolor", group = "08 | Custom pair 4")
c4hText = input.color(#26A69A, "Text", inline = "c4hcolor", group = "08 | Custom pair 4")
c4hStyle = input.string("Solid", "High style", options = ["Solid", "Dashed", "Dotted"], inline = "c4hstyle", group = "08 | Custom pair 4")
c4hWidth = input.int(1, "Width", minval = 1, maxval = 5, inline = "c4hstyle", group = "08 | Custom pair 4")
c4hLength = input.int(40, "High length (bars)", minval = 1, maxval = 5000, group = "08 | Custom pair 4")
c4hSize = input.string("Small", "High label size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = "08 | Custom pair 4")
c4lShow = input.bool(true, "Low", inline = "c4lmain", group = "08 | Custom pair 4")
c4lName = input.string("2H L", "Label", inline = "c4lmain", group = "08 | Custom pair 4")
c4lColor = input.color(#EF5350, "Low line", inline = "c4lcolor", group = "08 | Custom pair 4")
c4lText = input.color(#EF5350, "Text", inline = "c4lcolor", group = "08 | Custom pair 4")
c4lStyle = input.string("Solid", "Low style", options = ["Solid", "Dashed", "Dotted"], inline = "c4lstyle", group = "08 | Custom pair 4")
c4lWidth = input.int(1, "Width", minval = 1, maxval = 5, inline = "c4lstyle", group = "08 | Custom pair 4")
c4lLength = input.int(40, "Low length (bars)", minval = 1, maxval = 5000, group = "08 | Custom pair 4")
c4lSize = input.string("Small", "Low label size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = "08 | Custom pair 4")
// Fetch on every bar so requests remain consistent in history and realtime.
[pdHigh, pdLow] = f_previous("1D")
pdValid = f_supported("1D")
[pwHigh, pwLow] = f_previous("1W")
pwValid = f_supported("1W")
[pmHigh, pmLow] = f_previous("1M")
pmValid = f_supported("1M")

[cdHigh, cdLow, cdHighBar, cdLowBar, cdPriorHigh, cdPriorLow, cdPriorHighBar, cdPriorLowBar] = f_wicks("1D")
cdValid = f_supported("1D")
[c1AutoHigh, c1AutoLow] = f_previous(c1Tf)
c1High = c1Mode == "Manual prices" ? c1ManualHigh : c1AutoHigh
c1Low = c1Mode == "Manual prices" ? c1ManualLow : c1AutoLow
c1Valid = c1Mode == "Manual prices" or f_supported(c1Tf)
[c2AutoHigh, c2AutoLow] = f_previous(c2Tf)
c2High = c2Mode == "Manual prices" ? c2ManualHigh : c2AutoHigh
c2Low = c2Mode == "Manual prices" ? c2ManualLow : c2AutoLow
c2Valid = c2Mode == "Manual prices" or f_supported(c2Tf)
[c3AutoHigh, c3AutoLow] = f_previous(c3Tf)
c3High = c3Mode == "Manual prices" ? c3ManualHigh : c3AutoHigh
c3Low = c3Mode == "Manual prices" ? c3ManualLow : c3AutoLow
c3Valid = c3Mode == "Manual prices" or f_supported(c3Tf)
[c4AutoHigh, c4AutoLow] = f_previous(c4Tf)
c4High = c4Mode == "Manual prices" ? c4ManualHigh : c4AutoHigh
c4Low = c4Mode == "Manual prices" ? c4ManualLow : c4AutoLow
c4Valid = c4Mode == "Manual prices" or f_supported(c4Tf)
// Match official source prices to chart wick locations.
[pdActiveHigh, pdActiveLow, pdActiveHighBar, pdActiveLowBar, pdObservedHigh, pdObservedLow, pdObservedHighBar, pdObservedLowBar] = f_wicks("1D")


pdHighBar = (levelSource == "Chart candles" ? pdObservedHighBar : f_match(pdHigh, pdObservedHigh, pdObservedHighBar))
pdLowBar = (levelSource == "Chart candles" ? pdObservedLowBar : f_match(pdLow, pdObservedLow, pdObservedLowBar))
[pwActiveHigh, pwActiveLow, pwActiveHighBar, pwActiveLowBar, pwObservedHigh, pwObservedLow, pwObservedHighBar, pwObservedLowBar] = f_wicks("1W")

pwHighBar = (levelSource == "Chart candles" ? pwObservedHighBar : f_match(pwHigh, pwObservedHigh, pwObservedHighBar))
pwLowBar = (levelSource == "Chart candles" ? pwObservedLowBar : f_match(pwLow, pwObservedLow, pwObservedLowBar))
[pmActiveHigh, pmActiveLow, pmActiveHighBar, pmActiveLowBar, pmObservedHigh, pmObservedLow, pmObservedHighBar, pmObservedLowBar] = f_wicks("1M")

pmHighBar = (levelSource == "Chart candles" ? pmObservedHighBar : f_match(pmHigh, pmObservedHigh, pmObservedHighBar))
pmLowBar = (levelSource == "Chart candles" ? pmObservedLowBar : f_match(pmLow, pmObservedLow, pmObservedLowBar))
[c1ActiveHigh, c1ActiveLow, c1ActiveHighBar, c1ActiveLowBar, c1ObservedHigh, c1ObservedLow, c1ObservedHighBar, c1ObservedLowBar] = f_wicks(c1Tf)

c1HighBar = c1Mode == "Manual prices" ? bar_index : (levelSource == "Chart candles" ? c1ObservedHighBar : f_match(c1High, c1ObservedHigh, c1ObservedHighBar))
c1LowBar = c1Mode == "Manual prices" ? bar_index : (levelSource == "Chart candles" ? c1ObservedLowBar : f_match(c1Low, c1ObservedLow, c1ObservedLowBar))
[c2ActiveHigh, c2ActiveLow, c2ActiveHighBar, c2ActiveLowBar, c2ObservedHigh, c2ObservedLow, c2ObservedHighBar, c2ObservedLowBar] = f_wicks(c2Tf)

c2HighBar = c2Mode == "Manual prices" ? bar_index : (levelSource == "Chart candles" ? c2ObservedHighBar : f_match(c2High, c2ObservedHigh, c2ObservedHighBar))
c2LowBar = c2Mode == "Manual prices" ? bar_index : (levelSource == "Chart candles" ? c2ObservedLowBar : f_match(c2Low, c2ObservedLow, c2ObservedLowBar))
[c3ActiveHigh, c3ActiveLow, c3ActiveHighBar, c3ActiveLowBar, c3ObservedHigh, c3ObservedLow, c3ObservedHighBar, c3ObservedLowBar] = f_wicks(c3Tf)
c3HighBar = c3Mode == "Manual prices" ? bar_index : f_match(c3High, c3ObservedHigh, c3ObservedHighBar)
c3LowBar = c3Mode == "Manual prices" ? bar_index : f_match(c3Low, c3ObservedLow, c3ObservedLowBar)


[c4ActiveHigh, c4ActiveLow, c4ActiveHighBar, c4ActiveLowBar, c4ObservedHigh, c4ObservedLow, c4ObservedHighBar, c4ObservedLowBar] = f_wicks(c4Tf)
c4HighBar = c4Mode == "Manual prices" ? bar_index : f_match(c4High, c4ObservedHigh, c4ObservedHighBar)
c4LowBar = c4Mode == "Manual prices" ? bar_index : f_match(c4Low, c4ObservedLow, c4ObservedLowBar)

   
// Choose chart-derived extremes together with their matching wick anchors.
if levelSource == "Chart candles"
    pdHigh := pdObservedHigh
    pdLow := pdObservedLow
if levelSource == "Chart candles"
    pwHigh := pwObservedHigh
    pwLow := pwObservedLow
if levelSource == "Chart candles"
    pmHigh := pmObservedHigh
    pmLow := pmObservedLow
if levelSource == "Chart candles" and c1Mode != "Manual prices"
    c1High := c1ObservedHigh
    c1Low := c1ObservedLow
if levelSource == "Chart candles" and c2Mode != "Manual prices"
    c2High := c2ObservedHigh
    c2Low := c2ObservedLow
if levelSource == "Chart candles" and c3Mode != "Manual prices"
    c3High := c3ObservedHigh
    c3Low := c3ObservedLow
if levelSource == "Chart candles" and c4Mode != "Manual prices"
    c4High := c4ObservedHigh
    c4Low := c4ObservedLow
f_draw(pdEnabled and pdValid and pdhShow, pdHigh, pdHighBar, pdhName, pdhColor, pdhText, pdhStyle, pdhWidth, pdhLength, pdhSize)
f_draw(pdEnabled and pdValid and pdlShow, pdLow, pdLowBar, pdlName, pdlColor, pdlText, pdlStyle, pdlWidth, pdlLength, pdlSize)
f_draw(pwEnabled and pwValid and pwhShow, pwHigh, pwHighBar, pwhName, pwhColor, pwhText, pwhStyle, pwhWidth, pwhLength, pwhSize)
f_draw(pwEnabled and pwValid and pwlShow, pwLow, pwLowBar, pwlName, pwlColor, pwlText, pwlStyle, pwlWidth, pwlLength, pwlSize)
f_draw(pmEnabled and pmValid and pmhShow, pmHigh, pmHighBar, pmhName, pmhColor, pmhText, pmhStyle, pmhWidth, pmhLength, pmhSize)
f_draw(pmEnabled and pmValid and pmlShow, pmLow, pmLowBar, pmlName, pmlColor, pmlText, pmlStyle, pmlWidth, pmlLength, pmlSize)
f_draw(cdEnabled and cdValid and cdhShow, cdHigh, cdHighBar, cdhName, cdhColor, cdhText, cdhStyle, cdhWidth, cdhLength, cdhSize)
f_draw(cdEnabled and cdValid and cdlShow, cdLow, cdLowBar, cdlName, cdlColor, cdlText, cdlStyle, cdlWidth, cdlLength, cdlSize)
f_draw(c1Enabled and c1Valid and c1hShow, c1High, c1HighBar, c1hName, c1hColor, c1hText, c1hStyle, c1hWidth, c1hLength, c1hSize)
f_draw(c1Enabled and c1Valid and c1lShow, c1Low, c1LowBar, c1lName, c1lColor, c1lText, c1lStyle, c1lWidth, c1lLength, c1lSize)
f_draw(c2Enabled and c2Valid and c2hShow, c2High, c2HighBar, c2hName, c2hColor, c2hText, c2hStyle, c2hWidth, c2hLength, c2hSize)
f_draw(c2Enabled and c2Valid and c2lShow, c2Low, c2LowBar, c2lName, c2lColor, c2lText, c2lStyle, c2lWidth, c2lLength, c2lSize)
f_draw(c3Enabled and c3Valid and c3hShow, c3High, c3HighBar, c3hName, c3hColor, c3hText, c3hStyle, c3hWidth, c3hLength, c3hSize)
f_draw(c3Enabled and c3Valid and c3lShow, c3Low, c3LowBar, c3lName, c3lColor, c3lText, c3lStyle, c3lWidth, c3lLength, c3lSize)
f_draw(c4Enabled and c4Valid and c4hShow, c4High, c4HighBar, c4hName, c4hColor, c4hText, c4hStyle, c4hWidth, c4hLength, c4hSize)
f_draw(c4Enabled and c4Valid and c4lShow, c4Low, c4LowBar, c4lName, c4lColor, c4lText, c4lStyle, c4lWidth, c4lLength, c4lSize)
// Lower source timeframes are hidden rather than showing sampled, incomplete levels.
var table notice = table.new(position.bottom_right, 1, 1, force_overlay = true)
if barstate.islast
    string hidden = ""
    if pdEnabled and not pdValid
        hidden += "Previous day; "
    if pwEnabled and not pwValid
        hidden += "Previous week; "
    if pmEnabled and not pmValid
        hidden += "Previous month; "
    if cdEnabled and not cdValid
        hidden += "Current day; "
    if c1Enabled and not c1Valid
        hidden += "Custom pair 1; "
    if c2Enabled and not c2Valid
        hidden += "Custom pair 2; "
    if c3Enabled and not c3Valid
        hidden += "Custom pair 3; "
    if c4Enabled and not c4Valid
        hidden += "Custom pair 4; "
    table.cell(notice, 0, 0, hidden == "" ? "" : "Hidden: " + hidden + "\nUse a chart timeframe at or below the source timeframe.", text_color = color.orange, text_size = size.small, bgcolor = hidden == "" ? na : color.new(color.black, 15))
    string missing = ""
    if pdEnabled and pdValid and pdhShow and na(f_barTime(pdHighBar))
        missing += pdhName + "; "
    if pdEnabled and pdValid and pdlShow and na(f_barTime(pdLowBar))
        missing += pdlName + "; "
    if pwEnabled and pwValid and pwhShow and na(f_barTime(pwHighBar))
        missing += pwhName + "; "
    if pwEnabled and pwValid and pwlShow and na(f_barTime(pwLowBar))
        missing += pwlName + "; "
    if pmEnabled and pmValid and pmhShow and na(f_barTime(pmHighBar))
        missing += pmhName + "; "
    if pmEnabled and pmValid and pmlShow and na(f_barTime(pmLowBar))
        missing += pmlName + "; "
    if cdEnabled and cdValid and cdhShow and na(f_barTime(cdHighBar))
        missing += cdhName + "; "
    if cdEnabled and cdValid and cdlShow and na(f_barTime(cdLowBar))
        missing += cdlName + "; "
    if c1Enabled and c1Valid and c1hShow and na(f_barTime(c1HighBar))
        missing += c1hName + "; "
    if c1Enabled and c1Valid and c1lShow and na(f_barTime(c1LowBar))
        missing += c1lName + "; "
    if c2Enabled and c2Valid and c2hShow and na(f_barTime(c2HighBar))
        missing += c2hName + "; "
    if c2Enabled and c2Valid and c2lShow and na(f_barTime(c2LowBar))
        missing += c2lName + "; "
    if c3Enabled and c3Valid and c3hShow and na(f_barTime(c3HighBar))
        missing += c3hName + "; "
    if c3Enabled and c3Valid and c3lShow and na(f_barTime(c3LowBar))
        missing += c3lName + "; "
    if c4Enabled and c4Valid and c4hShow and na(f_barTime(c4HighBar))
        missing += c4hName + "; "
    if c4Enabled and c4Valid and c4lShow and na(f_barTime(c4LowBar))
        missing += c4lName + "; "
    string message = (hidden == "" ? "" : "Source timeframe below chart: " + hidden) + (missing == "" ? "" : "\nNo loaded matching wick: " + missing + "\nLoad more history or choose Chart candles in Layout.")
    table.cell(notice, 0, 0, message, text_color = color.orange, text_size = size.small, bgcolor = message == "" ? na : color.new(color.black, 15))
````
