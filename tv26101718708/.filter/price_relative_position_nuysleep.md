# Price Relative Position

- url: https://www.tradingview.com/script/NuySLeep-Price-Relative-Position/
- type: indicator
- pine_id: PUB;c2a34c64c7084dc4a0e488fef9feec17
- version: 1.0

## Description

To check the current price position relative to moving averages, 52wk high/low and intraday high/low

## Source Code

````pine
//@version=6
indicator("Price Relative Position", overlay=true)

// Status line order:
// 1) Day High   = running session high up to hovered/current bar
// 2) Day Low    = running session low up to hovered/current bar
// 3) Position   = ((close - Day Low) / (Day High - Day Low)) * 100
// 4) HighLowPct = ((Day High / Day Low) - 1) * 100

// Inputs
avgType = input.string("SMA", "Average Type", options=["SMA", "EMA"])
showTable = input.bool(true, "Show Table")
showAverages = input.bool(true, "Show Averages")
show52WeekLevels = input.bool(true, "Show 52 Week Levels")
showIntradayLevels = input.bool(true, "Show Intraday Levels")
showVWAP = input.bool(true, "Show VWAP")
tablePos = input.string("Top Right", "Table Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], display=display.none)
textSize = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal"], display=display.none)

// Position
tablePosition = position.top_right
if tablePos == "Top Left"
    tablePosition := position.top_left
else if tablePos == "Bottom Left"
    tablePosition := position.bottom_left
else if tablePos == "Bottom Right"
    tablePosition := position.bottom_right
else
    tablePosition := position.top_right

// Text size
tableTextSize = size.small
if textSize == "Tiny"
    tableTextSize := size.tiny
else if textSize == "Normal"
    tableTextSize := size.normal
else
    tableTextSize := size.small

// Daily moving averages, regardless of chart timeframe
ma10 = avgType == "EMA" ? request.security(syminfo.tickerid, "D", ta.ema(close, 10)) : request.security(syminfo.tickerid, "D", ta.sma(close, 10))
ma20 = avgType == "EMA" ? request.security(syminfo.tickerid, "D", ta.ema(close, 20)) : request.security(syminfo.tickerid, "D", ta.sma(close, 20))
ma50 = avgType == "EMA" ? request.security(syminfo.tickerid, "D", ta.ema(close, 50)) : request.security(syminfo.tickerid, "D", ta.sma(close, 50))
ma100 = avgType == "EMA" ? request.security(syminfo.tickerid, "D", ta.ema(close, 100)) : request.security(syminfo.tickerid, "D", ta.sma(close, 100))
ma200 = avgType == "EMA" ? request.security(syminfo.tickerid, "D", ta.ema(close, 200)) : request.security(syminfo.tickerid, "D", ta.sma(close, 200))

// 52-week values from daily timeframe
high52w = request.security(syminfo.tickerid, "D", ta.highest(high, 252))
low52w = request.security(syminfo.tickerid, "D", ta.lowest(low, 252))

// Running intraday high/low for the current session
bool newDay = timeframe.change("1D")

var float dayHigh = na
var float dayLow = na

if newDay
    dayHigh := high
    dayLow := low
else
    dayHigh := na(dayHigh) ? high : math.max(dayHigh, high)
    dayLow := na(dayLow) ? low : math.min(dayLow, low)

vwapValue = ta.vwap(hlc3)

// Percent calculations
float pct10 = na
if ma10 != 0
    pct10 := ((close / ma10) - 1.0) * 100.0

float pct20 = na
if ma20 != 0
    pct20 := ((close / ma20) - 1.0) * 100.0

float pct50 = na
if ma50 != 0
    pct50 := ((close / ma50) - 1.0) * 100.0

float pct100 = na
if ma100 != 0
    pct100 := ((close / ma100) - 1.0) * 100.0

float pct200 = na
if ma200 != 0
    pct200 := ((close / ma200) - 1.0) * 100.0

float pct52Hi = na
if high52w != 0
    pct52Hi := ((close / high52w) - 1.0) * 100.0

float pct52Lo = na
if low52w != 0
    pct52Lo := ((close / low52w) - 1.0) * 100.0

float pctDHi = na
if dayHigh != 0
    pctDHi := ((close / dayHigh) - 1.0) * 100.0

float pctDLo = na
if dayLow != 0
    pctDLo := ((close / dayLow) - 1.0) * 100.0

float pctVWAP = na
if vwapValue != 0
    pctVWAP := ((close / vwapValue) - 1.0) * 100.0

// Intraday range metrics
float dayRangePos = na
if dayHigh != dayLow
    dayRangePos := ((close - dayLow) / (dayHigh - dayLow)) * 100.0

float highLowPct = na
if dayLow != 0
    highLowPct := ((dayHigh / dayLow) - 1.0) * 100.0

// Status line values only
plot(dayHigh, title="H", color=color.new(color.orange, 100), linewidth=1, display=display.status_line, format=format.price)
plot(dayLow, title="L", color=color.new(color.yellow, 100), linewidth=1, display=display.status_line, format=format.price)
plot(dayRangePos, title="Pos", color=color.new(color.aqua, 100), linewidth=1, display=display.status_line, precision=2)
plot(highLowPct, title="HL%", color=color.new(color.fuchsia, 100), linewidth=1, display=display.status_line, precision=2)

// Table
var table t = table.new(tablePosition, 3, 11, border_width=1, frame_color=color.new(color.white, 70))

if barstate.islast
    if showTable
        table.cell(t, 0, 0, "Label", text_color=color.white, bgcolor=color.new(color.blue, 60), text_size=tableTextSize)
        table.cell(t, 1, 0, "Value", text_color=color.white, bgcolor=color.new(color.blue, 60), text_size=tableTextSize)
        table.cell(t, 2, 0, "% From", text_color=color.white, bgcolor=color.new(color.blue, 60), text_size=tableTextSize)

        row = 1

        if showAverages
            bg10 = na(pct10) ? color.new(color.gray, 85) : pct10 >= 0 ? color.new(color.green, 70) : color.new(color.red, 70)
            bg20 = na(pct20) ? color.new(color.gray, 85) : pct20 >= 0 ? color.new(color.green, 70) : color.new(color.red, 70)
            bg50 = na(pct50) ? color.new(color.gray, 85) : pct50 >= 0 ? color.new(color.green, 70) : color.new(color.red, 70)
            bg100 = na(pct100) ? color.new(color.gray, 85) : pct100 >= 0 ? color.new(color.green, 70) : color.new(color.red, 70)
            bg200 = na(pct200) ? color.new(color.gray, 85) : pct200 >= 0 ? color.new(color.green, 70) : color.new(color.red, 70)

            table.cell(t, 0, row, "10D " + avgType, text_color=color.white, bgcolor=color.new(color.black, 0), text_size=tableTextSize)
            table.cell(t, 1, row, str.tostring(ma10, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 0), text_size=tableTextSize)
            table.cell(t, 2, row, str.tostring(pct10, "#.##") + "%", text_color=color.white, bgcolor=bg10, text_size=tableTextSize)
            row := row + 1

            table.cell(t, 0, row, "20D " + avgType, text_color=color.white, bgcolor=color.new(color.black, 0), text_size=tableTextSize)
            table.cell(t, 1, row, str.tostring(ma20, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 0), text_size=tableTextSize)
            table.cell(t, 2, row, str.tostring(pct20, "#.##") + "%", text_color=color.white, bgcolor=bg20, text_size=tableTextSize)
            row := row + 1

            table.cell(t, 0, row, "50D " + avgType, text_color=color.white, bgcolor=color.new(color.black, 0), text_size=tableTextSize)
            table.cell(t, 1, row, str.tostring(ma50, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 0), text_size=tableTextSize)
            table.cell(t, 2, row, str.tostring(pct50, "#.##") + "%", text_color=color.white, bgcolor=bg50, text_size=tableTextSize)
            row := row + 1

            table.cell(t, 0, row, "100D " + avgType, text_color=color.white, bgcolor=color.new(color.black, 0), text_size=tableTextSize)
            table.cell(t, 1, row, str.tostring(ma100, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 0), text_size=tableTextSize)
            table.cell(t, 2, row, str.tostring(pct100, "#.##") + "%", text_color=color.white, bgcolor=bg100, text_size=tableTextSize)
            row := row + 1

            table.cell(t, 0, row, "200D " + avgType, text_color=color.white, bgcolor=color.new(color.black, 0), text_size=tableTextSize)
            table.cell(t, 1, row, str.tostring(ma200, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 0), text_size=tableTextSize)
            table.cell(t, 2, row, str.tostring(pct200, "#.##") + "%", text_color=color.white, bgcolor=bg200, text_size=tableTextSize)
            row := row + 1

        if show52WeekLevels
            bg52h = na(pct52Hi) ? color.new(color.gray, 85) : pct52Hi >= 0 ? color.new(color.green, 70) : color.new(color.red, 70)
            bg52l = na(pct52Lo) ? color.new(color.gray, 85) : pct52Lo >= 0 ? color.new(color.green, 70) : color.new(color.red, 70)

            table.cell(t, 0, row, "52W High", text_color=color.white, bgcolor=color.new(color.black, 0), text_size=tableTextSize)
            table.cell(t, 1, row, str.tostring(high52w, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 0), text_size=tableTextSize)
            table.cell(t, 2, row, str.tostring(pct52Hi, "#.##") + "%", text_color=color.white, bgcolor=bg52h, text_size=tableTextSize)
            row := row + 1

            table.cell(t, 0, row, "52W Low", text_color=color.white, bgcolor=color.new(color.black, 0), text_size=tableTextSize)
            table.cell(t, 1, row, str.tostring(low52w, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 0), text_size=tableTextSize)
            table.cell(t, 2, row, str.tostring(pct52Lo, "#.##") + "%", text_color=color.white, bgcolor=bg52l, text_size=tableTextSize)
            row := row + 1

        if showIntradayLevels
            bgDh = na(pctDHi) ? color.new(color.gray, 85) : pctDHi >= 0 ? color.new(color.green, 70) : color.new(color.red, 70)
            bgDl = na(pctDLo) ? color.new(color.gray, 85) : pctDLo >= 0 ? color.new(color.green, 70) : color.new(color.red, 70)

            table.cell(t, 0, row, "Day High", text_color=color.white, bgcolor=color.new(color.black, 0), text_size=tableTextSize)
            table.cell(t, 1, row, str.tostring(dayHigh, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 0), text_size=tableTextSize)
            table.cell(t, 2, row, str.tostring(pctDHi, "#.##") + "%", text_color=color.white, bgcolor=bgDh, text_size=tableTextSize)
            row := row + 1

            table.cell(t, 0, row, "Day Low", text_color=color.white, bgcolor=color.new(color.black, 0), text_size=tableTextSize)
            table.cell(t, 1, row, str.tostring(dayLow, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 0), text_size=tableTextSize)
            table.cell(t, 2, row, str.tostring(pctDLo, "#.##") + "%", text_color=color.white, bgcolor=bgDl, text_size=tableTextSize)
            row := row + 1

        if showVWAP
            bgV = na(pctVWAP) ? color.new(color.gray, 85) : pctVWAP >= 0 ? color.new(color.green, 70) : color.new(color.red, 70)

            table.cell(t, 0, row, "VWAP", text_color=color.white, bgcolor=color.new(color.black, 0), text_size=tableTextSize)
            table.cell(t, 1, row, str.tostring(vwapValue, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 0), text_size=tableTextSize)
            table.cell(t, 2, row, str.tostring(pctVWAP, "#.##") + "%", text_color=color.white, bgcolor=bgV, text_size=tableTextSize)
    else
        table.clear(t, 0, 0, 2, 10)
````
