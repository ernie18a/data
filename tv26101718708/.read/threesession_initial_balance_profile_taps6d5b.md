# Three-Session Initial Balance Profile

- url: https://www.tradingview.com/script/tApS6D5B-Three-Session-Initial-Balance-Profile/
- type: indicator
- pine_id: PUB;1505973a75ac46c6a8580ba697ed0567
- version: 2.0

## Description

[b]Three-Session Initial Balance Profile[/b]
[b]Overview[/b]
This indicator organizes intraday market structure around three defined session windows: Tokyo, London, and New York. Each session has its own Initial Balance (IB), IB-window Volume Profile, and session VWAP. Optional Fib extensions, range-based target projections, VWAP deviation bands, OTE zones, and configurable moving averages add context around those session references.

The components share the same session schedule rather than being unrelated overlays: the IB establishes the session’s initial price range, the profile describes chart-volume distribution within that range, and the projections use the IB range as their measuring unit. VWAP and its deviation bands reset with the session handoffs.

[b]Session windows[/b]
Defaults are:

[b]Tokyo:[/b] 08:45–09:45 Japan Standard Time (JST)
[b]London:[/b] 08:00–09:00 London local time
[b]New York:[/b] 09:30–10:30 New York local time

The time-zone inputs use regional time zones, so London and New York follow their daylight-saving changes. The session windows can be adjusted in the settings.

[b]What it displays[/b]

[b]Initial Balance:[/b] The high and low of each session’s configured IB window. The previous session’s levels remain on their historical bars; the new session’s levels replace them when its IB completes.

I[b]B Volume Profile:[/b] A price-bin histogram built from volume during the IB window, bounded by the IB range. It marks the Point of Control (POC), Value Area High (VAH), and Value Area Low (VAL). Users can adjust the row count up to 500 and the Value Area percentage.

[b]Session VWAP and deviation bands:[/b] Separate Tokyo, London, and New York VWAP calculations, with a selectable number of symmetric standard-deviation band pairs from ±1σ through ±5σ. VWAP uses HLC3 weighted by chart volume; prior session curves remain as historical segments.

[b]Fib extensions:[/b] Optional 0.618, 1.272, 1.618, 2.618, and 3.618 IB-range projections above and below the IB.

[b]Range-based targets:[/b] Optional 1R, 2R, 3R, and 4R projections measured in multiples of the IB range. These are reference distances, not trade-entry-specific risk/reward calculations.

[b]OTE zones:[/b] Optional mirrored long and short retracement zones inside the IB range.

[b]Momentum averages:[/b] Two independently configured averages, defaulting to 9 EMA and 21 EMA. Each has its own length, type, and color. Available types are EMA, SMA, RMA, WMA, VWMA, HMA, DEMA, TEMA, ZLEMA, and ALMA.

[b]Level extensions:[/b] IBH, IBL, VAH, VAL, and POC can each be set to None, Left, Right, or Both. These controls do not extend Fib, OTE, or range-target drawings.

[b]How to use it[/b]
Add the indicator to an intraday chart and confirm the session windows and time zones match your intended schedule.
Enable the optional VWAP, Fib, OTE, and range-target features you want to view. Set the deviation-band count and profile row count to suit the chart.
Use the IB high and low as the opening-range boundaries. Review the profile’s POC and value-area levels for volume distribution within that range.
Compare price with the session VWAP, its deviation bands, and the selected moving averages for additional context. Treat projected levels as reference areas—not predictions or automatic entry signals.

[b]Originality and calculation notes[/b]
The standard building blocks—VWAP, standard deviation, moving averages, Fib ratios, and range projections—are established analytical techniques. The original design is their coordination around three separate session clocks: each session’s IB supplies the range for its profile and projections, while its VWAP calculation resets and its drawings follow the session handoffs. The indicator is intended as an integrated session-analysis framework, not simply a collection of unrelated studies.

[b]Limitations:[/b] The profile estimates volume at price by distributing each chart candle’s volume across its high–low range; it is not tick-by-tick volume-at-price. Results depend on the chart’s available OHLCV data. Lower intraday timeframes generally represent session boundaries more precisely.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Tradedailywithseb




//@version=6
indicator("Three-Session Initial Balance Profile", "3-Session IB Profile", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// --- Constants ---
color TOKYO_COLOR = #5b9cf6
color LONDON_COLOR = #089981
color NEW_YORK_COLOR = #f59e0b
color POC_COLOR = #f0b90b

// --- Inputs ---
string tokyoWindowInput = input.session("0845-0945:23456", "Tokyo IB window", tooltip = "Exact Tokyo Initial Balance window in Japan Standard Time.", group = "Sessions")
string tokyoTimezoneInput = input.string("Asia/Tokyo", "Tokyo time zone", tooltip = "IANA time zone used to interpret the Tokyo IB window.", group = "Sessions")
string londonWindowInput = input.session("0800-0900:23456", "London IB window", tooltip = "Exact London Initial Balance window in local London time, including BST/GMT changes.", group = "Sessions")
string londonTimezoneInput = input.string("Europe/London", "London time zone", tooltip = "IANA time zone used to interpret the London IB window.", group = "Sessions")
string newYorkWindowInput = input.session("0930-1030:23456", "New York IB window", tooltip = "Exact New York Initial Balance window in local Eastern time, including daylight-saving changes.", group = "Sessions")
string newYorkTimezoneInput = input.string("America/New_York", "New York time zone", tooltip = "IANA time zone used to interpret the New York IB window.", group = "Sessions")
int profileRowsInput = input.int(24, "Volume Profile rows", minval = 8, maxval = 500, tooltip = "Number of price bins used to approximate the Initial Balance volume profile. Supports up to 500 rows.", group = "Volume Profile")
float valueAreaInput = input.float(70.0, "Value Area (%)", minval = 50.0, maxval = 99.0, step = 1.0, tooltip = "Percentage of in-range Initial Balance volume included around the POC.", group = "Volume Profile")
int profileWidthInput = input.int(24, "Maximum profile width (bars)", minval = 4, maxval = 80, tooltip = "Maximum horizontal width of the profile histogram beside its IB box.", group = "Volume Profile")
bool showOteInput = input.bool(false, "Show OTE zones", tooltip = "Show mirrored 61.8%–79% retracement zones inside the IB: long zone in the lower portion and short zone in the upper portion.", group = "Optional Targets")
bool showFibInput = input.bool(false, "Show Fib extensions", tooltip = "Project 0.618, 1.272, 1.618, 2.618 and 3.618 times the IB range above the high and below the low.", group = "Optional Targets")
bool showRrInput = input.bool(false, "Show IB-range R targets", tooltip = "Project 1R, 2R, 3R and 4R multiples of the IB range beyond both IB boundaries. These are range-based reference levels, not trade-specific R multiples.", group = "Optional Targets")
string ibhExtendInput = input.string("None", "IB High line", options = ["None", "Left", "Right", "Both"], tooltip = "Extend the IB High line to the left, right, both sides, or leave it session-bounded.", group = "Line Extensions")
string iblExtendInput = input.string("None", "IB Low line", options = ["None", "Left", "Right", "Both"], tooltip = "Extend the IB Low line to the left, right, both sides, or leave it session-bounded.", group = "Line Extensions")
string vahExtendInput = input.string("None", "VAH line", options = ["None", "Left", "Right", "Both"], tooltip = "Extend the Value Area High line to the left, right, both sides, or leave it session-bounded.", group = "Line Extensions")
string valExtendInput = input.string("None", "VAL line", options = ["None", "Left", "Right", "Both"], tooltip = "Extend the Value Area Low line to the left, right, both sides, or leave it session-bounded.", group = "Line Extensions")
string pocExtendInput = input.string("None", "POC line", options = ["None", "Left", "Right", "Both"], tooltip = "Extend the Point of Control line to the left, right, both sides, or leave it session-bounded.", group = "Line Extensions")
bool showSessionVwapInput = input.bool(false, "Show session VWAPs", tooltip = "Show separate session VWAPs and their standard-deviation bands. Tokyo runs until London opens, London until New York opens, and New York until 16:00 local time.", group = "Session VWAP")
int deviationBandCountInput = input.int(2, "Deviation band count", minval = 1, maxval = 5, tooltip = "Number of symmetric standard-deviation bands per session VWAP. At least one pair is always shown when VWAP is enabled; choose up to five pairs at 1σ through 5σ.", group = "Session VWAP")
bool showMovingAveragesInput = input.bool(true, "Show momentum averages", tooltip = "Show two configurable moving averages on price. Defaults are 9 EMA and 21 EMA.", group = "Momentum Averages")
string maOneTypeInput = input.string("EMA", "MA 1 type", options = ["EMA", "SMA", "RMA", "WMA", "VWMA", "HMA", "DEMA", "TEMA", "ZLEMA", "ALMA"], tooltip = "Choose the first moving-average calculation; select its length separately.", group = "Momentum Averages")
int maOneLengthInput = input.int(9, "MA 1 length", minval = 1, maxval = 500, tooltip = "Lookback length for the first moving average.", group = "Momentum Averages")
string maTwoTypeInput = input.string("EMA", "MA 2 type", options = ["EMA", "SMA", "RMA", "WMA", "VWMA", "HMA", "DEMA", "TEMA", "ZLEMA", "ALMA"], tooltip = "Choose the second moving-average calculation independently of MA 1.", group = "Momentum Averages")
int maTwoLengthInput = input.int(21, "MA 2 length", minval = 1, maxval = 500, tooltip = "Lookback length for the second moving average.", group = "Momentum Averages")
color tokyoVwapColorInput = input.color(TOKYO_COLOR, "Tokyo VWAP color", tooltip = "Color used for Tokyo VWAP and its deviation bands.", group = "Style")
color londonVwapColorInput = input.color(LONDON_COLOR, "London VWAP color", tooltip = "Color used for London VWAP and its deviation bands.", group = "Style")
color newYorkVwapColorInput = input.color(NEW_YORK_COLOR, "New York VWAP color", tooltip = "Color used for New York VWAP and its deviation bands.", group = "Style")
color maOneColorInput = input.color(#b18cff, "MA 1 color", tooltip = "Plot color for the first moving average.", group = "Style")
color maTwoColorInput = input.color(#ffb74d, "MA 2 color", tooltip = "Plot color for the second moving average.", group = "Style")

// --- Helpers ---
clearDrawings(array<box> boxIds, array<line> lineIds, array<label> labelIds, array<polyline> profileIds) =>
    while array.size(boxIds) > 0
        box.delete(array.pop(boxIds))
    while array.size(lineIds) > 0
        line.delete(array.pop(lineIds))
    while array.size(labelIds) > 0
        label.delete(array.pop(labelIds))
    while array.size(profileIds) > 0
        polyline.delete(array.pop(profileIds))

profileStats(array<float> sampleHighs, array<float> sampleLows, array<float> sampleVolumes, float ibLow, float ibHigh, int rowCount, float valueAreaPercent) =>
    array<float> profileBins = array.new_float(rowCount, 0.0)
    float ibRange = ibHigh - ibLow
    float rowHeight = ibRange / rowCount
    int sampleCount = array.size(sampleHighs)
    if sampleCount > 0 and ibRange > 0
        for sampleIndex = 0 to sampleCount - 1
            float barHigh = array.get(sampleHighs, sampleIndex)
            float barLow = array.get(sampleLows, sampleIndex)
            float barVolume = array.get(sampleVolumes, sampleIndex)
            float barRange = barHigh - barLow
            if barRange > 0
                float clippedLow = math.max(barLow, ibLow)
                float clippedHigh = math.min(barHigh, ibHigh)
                if clippedHigh > clippedLow
                    int firstRow = math.max(0, math.min(rowCount - 1, int(math.floor((clippedLow - ibLow) / rowHeight))))
                    int lastRow = math.max(0, math.min(rowCount - 1, int(math.floor((clippedHigh - ibLow) / rowHeight))))
                    for rowIndex = firstRow to lastRow
                        float rowLow = ibLow + rowHeight * rowIndex
                        float rowHigh = rowLow + rowHeight
                        float overlap = math.max(0.0, math.min(barHigh, rowHigh) - math.max(barLow, rowLow))
                        if overlap > 0
                            array.set(profileBins, rowIndex, array.get(profileBins, rowIndex) + barVolume * overlap / barRange)
            else
                int flatIndex = math.max(0, math.min(rowCount - 1, int(math.floor((barLow - ibLow) / rowHeight))))
                array.set(profileBins, flatIndex, array.get(profileBins, flatIndex) + barVolume)
    float totalVolume = array.sum(profileBins)
    int pocIndex = 0
    float pocVolume = -1.0
    for rowIndex = 0 to rowCount - 1
        float rowVolume = array.get(profileBins, rowIndex)
        if rowVolume > pocVolume
            pocVolume := rowVolume
            pocIndex := rowIndex
    int valueLowIndex = pocIndex
    int valueHighIndex = pocIndex
    float accumulatedVolume = array.get(profileBins, pocIndex)
    float targetVolume = totalVolume * valueAreaPercent / 100.0
    while accumulatedVolume < targetVolume and (valueLowIndex > 0 or valueHighIndex < rowCount - 1)
        float lowerVolume = valueLowIndex > 0 ? array.get(profileBins, valueLowIndex - 1) : -1.0
        float upperVolume = valueHighIndex < rowCount - 1 ? array.get(profileBins, valueHighIndex + 1) : -1.0
        if upperVolume > lowerVolume
            valueHighIndex += 1
            accumulatedVolume += math.max(upperVolume, 0.0)
        else
            valueLowIndex -= 1
            accumulatedVolume += math.max(lowerVolume, 0.0)
    float pocPrice = ibLow + rowHeight * (pocIndex + 0.5)
    float valueLow = ibLow + rowHeight * valueLowIndex
    float valueHigh = ibLow + rowHeight * (valueHighIndex + 1)
    [profileBins, pocPrice, valueHigh, valueLow, valueLowIndex, valueHighIndex]

profileRowWidth(float rowVolume, float maxVolume, int maxWidth) =>
    maxVolume > 0 ? math.max(1, int(math.round(maxWidth * rowVolume / maxVolume))) : 1

makeProfilePoints(array<float> bins, int firstRow, int lastRow, int baseX, float ibLow, float rowHeight, int maxWidth, float maxVolume) =>
    array<chart.point> points = array.new<chart.point>()
    array.push(points, chart.point.from_index(baseX, ibLow + rowHeight * firstRow))
    for rowIndex = firstRow to lastRow
        int width = profileRowWidth(array.get(bins, rowIndex), maxVolume, maxWidth)
        int rightX = baseX + width
        float rowBottom = ibLow + rowHeight * rowIndex
        float rowTop = rowBottom + rowHeight
        array.push(points, chart.point.from_index(rightX, rowBottom))
        array.push(points, chart.point.from_index(rightX, rowTop))
    array.push(points, chart.point.from_index(baseX, ibLow + rowHeight * (lastRow + 1)))
    points

nextLondonOpen(int referenceTime) =>
    int referenceYear = year(referenceTime, londonTimezoneInput)
    int referenceMonth = month(referenceTime, londonTimezoneInput)
    int referenceDay = dayofmonth(referenceTime, londonTimezoneInput)
    int todayOpen = timestamp(londonTimezoneInput, referenceYear, referenceMonth, referenceDay, 8, 0)
    todayOpen > referenceTime ? todayOpen : timestamp(londonTimezoneInput, referenceYear, referenceMonth, referenceDay + 1, 8, 0)

nextNewYorkOpen(int referenceTime) =>
    int referenceYear = year(referenceTime, newYorkTimezoneInput)
    int referenceMonth = month(referenceTime, newYorkTimezoneInput)
    int referenceDay = dayofmonth(referenceTime, newYorkTimezoneInput)
    int todayOpen = timestamp(newYorkTimezoneInput, referenceYear, referenceMonth, referenceDay, 9, 30)
    todayOpen > referenceTime ? todayOpen : timestamp(newYorkTimezoneInput, referenceYear, referenceMonth, referenceDay + 1, 9, 30)

newYorkCashClose(int referenceTime) =>
    timestamp(newYorkTimezoneInput, year(referenceTime, newYorkTimezoneInput), month(referenceTime, newYorkTimezoneInput), dayofmonth(referenceTime, newYorkTimezoneInput), 16, 0)

drawLevel(float price, string caption, color levelColor, string lineStyle, int startTime, int endTime, array<line> lineIds, array<label> labelIds) =>
    if endTime > startTime
        line levelLine = line.new(startTime, price, endTime, price, xloc = xloc.bar_time, extend = extend.none, color = levelColor, style = lineStyle, width = 1)
        label levelLabel = label.new(endTime, price, caption, xloc = xloc.bar_time, style = label.style_label_left, color = color.new(levelColor, 100), textcolor = levelColor, size = size.tiny)
        array.push(lineIds, levelLine)
        array.push(labelIds, levelLabel)

lineExtension(string setting) =>
    setting == "Left" ? extend.left : setting == "Right" ? extend.right : setting == "Both" ? extend.both : extend.none

movingAverage(float source, int length, string averageType) =>
    float emaOne = ta.ema(source, length)
    float emaTwo = ta.ema(emaOne, length)
    float emaThree = ta.ema(emaTwo, length)
    float smaValue = ta.sma(source, length)
    float rmaValue = ta.rma(source, length)
    float wmaValue = ta.wma(source, length)
    float vwmaValue = ta.vwma(source, length)
    float hmaValue = ta.hma(source, length)
    int lag = math.max(0, int(math.floor((length - 1) / 2)))
    float zlemaValue = ta.ema(source + (source - nz(source[lag], source)), length)
    float almaValue = ta.alma(source, length, 0.85, 6)
    switch averageType
        "EMA" => emaOne
        "SMA" => smaValue
        "RMA" => rmaValue
        "WMA" => wmaValue
        "VWMA" => vwmaValue
        "HMA" => hmaValue
        "DEMA" => 2.0 * emaOne - emaTwo
        "TEMA" => 3.0 * emaOne - 3.0 * emaTwo + emaThree
        "ZLEMA" => zlemaValue
        "ALMA" => almaValue
        => emaOne

drawExtendedLevel(float price, string caption, color levelColor, string lineStyle, string extensionSetting, int startTime, int endTime, array<line> lineIds, array<label> labelIds) =>
    if endTime > startTime
        line levelLine = line.new(startTime, price, endTime, price, xloc = xloc.bar_time, extend = lineExtension(extensionSetting), color = levelColor, style = lineStyle, width = 1)
        label levelLabel = label.new(endTime, price, caption, xloc = xloc.bar_time, style = label.style_label_left, color = color.new(levelColor, 100), textcolor = levelColor, size = size.tiny)
        array.push(lineIds, levelLine)
        array.push(labelIds, levelLabel)

drawFibPair(float ibHigh, float ibLow, float multiple, string caption, int startTime, int endTime, array<line> lineIds, array<label> labelIds) =>
    float ibRange = ibHigh - ibLow
    color extensionColor = str.contains(caption, "TOKYO") or str.contains(caption, "TKY") ? TOKYO_COLOR : str.contains(caption, "LONDON") or str.contains(caption, "LDN") ? LONDON_COLOR : NEW_YORK_COLOR
    drawLevel(ibHigh + ibRange * multiple, caption + " ↑", extensionColor, line.style_dashed, startTime, endTime, lineIds, labelIds)
    drawLevel(ibLow - ibRange * multiple, caption + " ↓", extensionColor, line.style_dashed, startTime, endTime, lineIds, labelIds)

drawRrPair(float ibHigh, float ibLow, float multiple, string caption, int startTime, int endTime, array<line> lineIds, array<label> labelIds) =>
    float ibRange = ibHigh - ibLow
    color targetColor = str.contains(caption, "TOKYO") or str.contains(caption, "TKY") ? TOKYO_COLOR : str.contains(caption, "LONDON") or str.contains(caption, "LDN") ? LONDON_COLOR : NEW_YORK_COLOR
    drawLevel(ibHigh + ibRange * multiple, caption + " ↑", targetColor, line.style_dotted, startTime, endTime, lineIds, labelIds)
    drawLevel(ibLow - ibRange * multiple, caption + " ↓", targetColor, line.style_dotted, startTime, endTime, lineIds, labelIds)

drawSession(string sessionName, color sessionColor, int startBar, int endBar, int levelStartTime, int levelEndTime, float ibHigh, float ibLow, array<float> bins, float poc, float vah, float val, int valueLowIndex, int valueHighIndex, bool showOte, bool showFib, bool showRr, array<box> boxIds, array<line> lineIds, array<label> labelIds, array<polyline> profileIds) =>
    float ibRange = ibHigh - ibLow
    int rowCount = array.size(bins)
    float rowHeight = ibRange / rowCount
    box rangeBox = box.new(startBar, ibHigh, endBar, ibLow, xloc = xloc.bar_index, border_color = sessionColor, border_width = 1, bgcolor = color.new(sessionColor, 90), text = sessionName + " IB", text_color = sessionColor, text_size = size.tiny)
    array.push(boxIds, rangeBox)
    drawExtendedLevel(ibHigh, sessionName + " IBH", sessionColor, line.style_solid, ibhExtendInput, levelStartTime, levelEndTime, lineIds, labelIds)
    drawExtendedLevel(ibLow, sessionName + " IBL", sessionColor, line.style_solid, iblExtendInput, levelStartTime, levelEndTime, lineIds, labelIds)
    drawExtendedLevel(vah, sessionName + " VAH", sessionColor, line.style_dashed, vahExtendInput, levelStartTime, levelEndTime, lineIds, labelIds)
    drawExtendedLevel(val, sessionName + " VAL", sessionColor, line.style_dashed, valExtendInput, levelStartTime, levelEndTime, lineIds, labelIds)
    drawExtendedLevel(poc, sessionName + " POC", POC_COLOR, line.style_solid, pocExtendInput, levelStartTime, levelEndTime, lineIds, labelIds)
    if showOte
        box longOte = box.new(startBar, ibLow + ibRange * 0.382, endBar, ibLow + ibRange * 0.21, xloc = xloc.bar_index, border_color = color.new(#089981, 35), bgcolor = color.new(#089981, 82), text = "LONG OTE", text_color = #089981, text_size = size.tiny)
        box shortOte = box.new(startBar, ibLow + ibRange * 0.79, endBar, ibLow + ibRange * 0.618, xloc = xloc.bar_index, border_color = color.new(#f23645, 35), bgcolor = color.new(#f23645, 82), text = "SHORT OTE", text_color = #f23645, text_size = size.tiny)
        array.push(boxIds, longOte)
        array.push(boxIds, shortOte)
    string sessionTag = sessionName == "TOKYO" ? "TKY" : sessionName == "LONDON" ? "LDN" : "NY"
    if showFib
        drawFibPair(ibHigh, ibLow, 0.618, sessionTag + " 0.618 Ext", levelStartTime, levelEndTime, lineIds, labelIds)
        drawFibPair(ibHigh, ibLow, 1.272, sessionTag + " 1.272 Ext", levelStartTime, levelEndTime, lineIds, labelIds)
        drawFibPair(ibHigh, ibLow, 1.618, sessionTag + " 1.618 Ext", levelStartTime, levelEndTime, lineIds, labelIds)
        drawFibPair(ibHigh, ibLow, 2.618, sessionTag + " 2.618 Ext", levelStartTime, levelEndTime, lineIds, labelIds)
        drawFibPair(ibHigh, ibLow, 3.618, sessionTag + " 3.618 Ext", levelStartTime, levelEndTime, lineIds, labelIds)
    if showRr
        drawRrPair(ibHigh, ibLow, 1.0, sessionTag + " 1R", levelStartTime, levelEndTime, lineIds, labelIds)
        drawRrPair(ibHigh, ibLow, 2.0, sessionTag + " 2R", levelStartTime, levelEndTime, lineIds, labelIds)
        drawRrPair(ibHigh, ibLow, 3.0, sessionTag + " 3R", levelStartTime, levelEndTime, lineIds, labelIds)
        drawRrPair(ibHigh, ibLow, 4.0, sessionTag + " 4R", levelStartTime, levelEndTime, lineIds, labelIds)
    float maxVolume = array.max(bins)
    int profileLeft = endBar + 5
    array<chart.point> profilePoints = makeProfilePoints(bins, 0, rowCount - 1, profileLeft, ibLow, rowHeight, profileWidthInput, maxVolume)
    polyline profileShape = polyline.new(profilePoints, curved = false, closed = true, xloc = xloc.bar_index, line_color = color.new(sessionColor, 45), fill_color = color.new(sessionColor, 80), line_width = 1)
    array.push(profileIds, profileShape)
    array<chart.point> valuePoints = makeProfilePoints(bins, valueLowIndex, valueHighIndex, profileLeft, ibLow, rowHeight, profileWidthInput, maxVolume)
    polyline valueShape = polyline.new(valuePoints, curved = false, closed = true, xloc = xloc.bar_index, line_color = color.new(sessionColor, 15), fill_color = color.new(sessionColor, 55), line_width = 1)
    array.push(profileIds, valueShape)
    int pocIndex = math.max(0, math.min(rowCount - 1, int(math.floor((poc - ibLow) / rowHeight))))
    float pocBottom = ibLow + rowHeight * pocIndex
    int pocWidth = profileRowWidth(array.get(bins, pocIndex), maxVolume, profileWidthInput)
    box pocRow = box.new(profileLeft, pocBottom + rowHeight, profileLeft + pocWidth, pocBottom, xloc = xloc.bar_index, border_color = POC_COLOR, bgcolor = color.new(POC_COLOR, 15))
    array.push(boxIds, pocRow)

// --- Session windows ---
int tokyoWindowTime = time(timeframe.period, tokyoWindowInput, tokyoTimezoneInput)
int londonWindowTime = time(timeframe.period, londonWindowInput, londonTimezoneInput)
int newYorkWindowTime = time(timeframe.period, newYorkWindowInput, newYorkTimezoneInput)
bool tokyoStartEvent = not na(tokyoWindowTime) and na(tokyoWindowTime[1])
bool tokyoEndEvent = na(tokyoWindowTime) and not na(tokyoWindowTime[1])
bool londonStartEvent = not na(londonWindowTime) and na(londonWindowTime[1])
bool londonEndEvent = na(londonWindowTime) and not na(londonWindowTime[1])
bool newYorkStartEvent = not na(newYorkWindowTime) and na(newYorkWindowTime[1])
bool newYorkEndEvent = na(newYorkWindowTime) and not na(newYorkWindowTime[1])

// --- Session VWAP accumulators ---
var bool tokyoVwapActive = false
var bool londonVwapActive = false
var bool newYorkVwapActive = false
var float tokyoVolumeSum = 0.0
var float tokyoPriceVolumeSum = 0.0
var float tokyoWeightedM2 = 0.0
var float londonVolumeSum = 0.0
var float londonPriceVolumeSum = 0.0
var float londonWeightedM2 = 0.0
var float newYorkVolumeSum = 0.0
var float newYorkPriceVolumeSum = 0.0
var float newYorkWeightedM2 = 0.0
if tokyoStartEvent
    tokyoVwapActive := true
    tokyoVolumeSum := 0.0
    tokyoPriceVolumeSum := 0.0
    tokyoWeightedM2 := 0.0
if londonStartEvent
    tokyoVwapActive := false
    londonVwapActive := true
    londonVolumeSum := 0.0
    londonPriceVolumeSum := 0.0
    londonWeightedM2 := 0.0
if newYorkStartEvent
    londonVwapActive := false
    newYorkVwapActive := true
    newYorkVolumeSum := 0.0
    newYorkPriceVolumeSum := 0.0
    newYorkWeightedM2 := 0.0
int currentNewYorkClose = timestamp(newYorkTimezoneInput, year(time, newYorkTimezoneInput), month(time, newYorkTimezoneInput), dayofmonth(time, newYorkTimezoneInput), 16, 0)
if newYorkVwapActive and time >= currentNewYorkClose
    newYorkVwapActive := false
float vwapSource = hlc3
float vwapBarVolume = nz(volume, 0.0)
if showSessionVwapInput and vwapBarVolume > 0
    if tokyoVwapActive
        float tokyoMeanBefore = tokyoVolumeSum > 0 ? tokyoPriceVolumeSum / tokyoVolumeSum : vwapSource
        float tokyoVolumeAfter = tokyoVolumeSum + vwapBarVolume
        float tokyoMeanAfter = (tokyoPriceVolumeSum + vwapSource * vwapBarVolume) / tokyoVolumeAfter
        tokyoWeightedM2 += vwapBarVolume * (vwapSource - tokyoMeanBefore) * (vwapSource - tokyoMeanAfter)
        tokyoVolumeSum := tokyoVolumeAfter
        tokyoPriceVolumeSum += vwapSource * vwapBarVolume
    if londonVwapActive
        float londonMeanBefore = londonVolumeSum > 0 ? londonPriceVolumeSum / londonVolumeSum : vwapSource
        float londonVolumeAfter = londonVolumeSum + vwapBarVolume
        float londonMeanAfter = (londonPriceVolumeSum + vwapSource * vwapBarVolume) / londonVolumeAfter
        londonWeightedM2 += vwapBarVolume * (vwapSource - londonMeanBefore) * (vwapSource - londonMeanAfter)
        londonVolumeSum := londonVolumeAfter
        londonPriceVolumeSum += vwapSource * vwapBarVolume
    if newYorkVwapActive
        float newYorkMeanBefore = newYorkVolumeSum > 0 ? newYorkPriceVolumeSum / newYorkVolumeSum : vwapSource
        float newYorkVolumeAfter = newYorkVolumeSum + vwapBarVolume
        float newYorkMeanAfter = (newYorkPriceVolumeSum + vwapSource * vwapBarVolume) / newYorkVolumeAfter
        newYorkWeightedM2 += vwapBarVolume * (vwapSource - newYorkMeanBefore) * (vwapSource - newYorkMeanAfter)
        newYorkVolumeSum := newYorkVolumeAfter
        newYorkPriceVolumeSum += vwapSource * vwapBarVolume
float tokyoSessionVwap = tokyoVwapActive and tokyoVolumeSum > 0 ? tokyoPriceVolumeSum / tokyoVolumeSum : na
float londonSessionVwap = londonVwapActive and londonVolumeSum > 0 ? londonPriceVolumeSum / londonVolumeSum : na
float newYorkSessionVwap = newYorkVwapActive and newYorkVolumeSum > 0 ? newYorkPriceVolumeSum / newYorkVolumeSum : na
float tokyoSessionVariance = tokyoVolumeSum > 0 ? math.max(tokyoWeightedM2 / tokyoVolumeSum, 0.0) : na
float londonSessionVariance = londonVolumeSum > 0 ? math.max(londonWeightedM2 / londonVolumeSum, 0.0) : na
float newYorkSessionVariance = newYorkVolumeSum > 0 ? math.max(newYorkWeightedM2 / newYorkVolumeSum, 0.0) : na
float tokyoSessionDeviation = math.sqrt(tokyoSessionVariance)
float londonSessionDeviation = math.sqrt(londonSessionVariance)
float newYorkSessionDeviation = math.sqrt(newYorkSessionVariance)

// --- Persistent Tokyo state ---
var int tokyoStartBar = na
var float tokyoHigh = na
var float tokyoLow = na
var bool tokyoFinalized = false
var array<float> tokyoSampleHighs = array.new_float()
var array<float> tokyoSampleLows = array.new_float()
var array<float> tokyoSampleVolumes = array.new_float()
var array<box> tokyoBoxes = array.new_box()
var array<line> tokyoLines = array.new_line()
var array<label> tokyoLabels = array.new_label()
var array<polyline> tokyoProfiles = array.new<polyline>()
if tokyoStartEvent
    tokyoStartBar := bar_index
    tokyoHigh := na
    tokyoLow := na
    tokyoFinalized := false
    array.clear(tokyoSampleHighs)
    array.clear(tokyoSampleLows)
    array.clear(tokyoSampleVolumes)
if not na(tokyoWindowTime)
    tokyoHigh := na(tokyoHigh) ? high : math.max(tokyoHigh, high)
    tokyoLow := na(tokyoLow) ? low : math.min(tokyoLow, low)
    array.push(tokyoSampleHighs, high)
    array.push(tokyoSampleLows, low)
    array.push(tokyoSampleVolumes, nz(volume, 0.0))
if tokyoEndEvent and not tokyoFinalized and array.size(tokyoSampleHighs) > 0 and tokyoHigh > tokyoLow
    clearDrawings(tokyoBoxes, tokyoLines, tokyoLabels, tokyoProfiles)
    [tokyoBins, tokyoPoc, tokyoVah, tokyoVal, tokyoValueLowIndex, tokyoValueHighIndex] = profileStats(tokyoSampleHighs, tokyoSampleLows, tokyoSampleVolumes, tokyoLow, tokyoHigh, profileRowsInput, valueAreaInput)
    drawSession("TOKYO", TOKYO_COLOR, tokyoStartBar, bar_index - 1, time, nextLondonOpen(time), tokyoHigh, tokyoLow, tokyoBins, tokyoPoc, tokyoVah, tokyoVal, tokyoValueLowIndex, tokyoValueHighIndex, showOteInput, showFibInput, showRrInput, tokyoBoxes, tokyoLines, tokyoLabels, tokyoProfiles)
    tokyoFinalized := true

// --- Persistent London state ---
var int londonStartBar = na
var float londonHigh = na
var float londonLow = na
var bool londonFinalized = false
var array<float> londonSampleHighs = array.new_float()
var array<float> londonSampleLows = array.new_float()
var array<float> londonSampleVolumes = array.new_float()
var array<box> londonBoxes = array.new_box()
var array<line> londonLines = array.new_line()
var array<label> londonLabels = array.new_label()
var array<polyline> londonProfiles = array.new<polyline>()
if londonStartEvent
    londonStartBar := bar_index
    londonHigh := na
    londonLow := na
    londonFinalized := false
    array.clear(londonSampleHighs)
    array.clear(londonSampleLows)
    array.clear(londonSampleVolumes)
if not na(londonWindowTime)
    londonHigh := na(londonHigh) ? high : math.max(londonHigh, high)
    londonLow := na(londonLow) ? low : math.min(londonLow, low)
    array.push(londonSampleHighs, high)
    array.push(londonSampleLows, low)
    array.push(londonSampleVolumes, nz(volume, 0.0))
if londonEndEvent and not londonFinalized and array.size(londonSampleHighs) > 0 and londonHigh > londonLow
    clearDrawings(londonBoxes, londonLines, londonLabels, londonProfiles)
    [londonBins, londonPoc, londonVah, londonVal, londonValueLowIndex, londonValueHighIndex] = profileStats(londonSampleHighs, londonSampleLows, londonSampleVolumes, londonLow, londonHigh, profileRowsInput, valueAreaInput)
    drawSession("LONDON", LONDON_COLOR, londonStartBar, bar_index - 1, time, nextNewYorkOpen(time), londonHigh, londonLow, londonBins, londonPoc, londonVah, londonVal, londonValueLowIndex, londonValueHighIndex, showOteInput, showFibInput, showRrInput, londonBoxes, londonLines, londonLabels, londonProfiles)
    londonFinalized := true

// --- Persistent New York state ---
var int newYorkStartBar = na
var float newYorkHigh = na
var float newYorkLow = na
var bool newYorkFinalized = false
var array<float> newYorkSampleHighs = array.new_float()
var array<float> newYorkSampleLows = array.new_float()
var array<float> newYorkSampleVolumes = array.new_float()
var array<box> newYorkBoxes = array.new_box()
var array<line> newYorkLines = array.new_line()
var array<label> newYorkLabels = array.new_label()
var array<polyline> newYorkProfiles = array.new<polyline>()
if newYorkStartEvent
    newYorkStartBar := bar_index
    newYorkHigh := na
    newYorkLow := na
    newYorkFinalized := false
    array.clear(newYorkSampleHighs)
    array.clear(newYorkSampleLows)
    array.clear(newYorkSampleVolumes)
if not na(newYorkWindowTime)
    newYorkHigh := na(newYorkHigh) ? high : math.max(newYorkHigh, high)
    newYorkLow := na(newYorkLow) ? low : math.min(newYorkLow, low)
    array.push(newYorkSampleHighs, high)
    array.push(newYorkSampleLows, low)
    array.push(newYorkSampleVolumes, nz(volume, 0.0))
if newYorkEndEvent and not newYorkFinalized and array.size(newYorkSampleHighs) > 0 and newYorkHigh > newYorkLow
    clearDrawings(newYorkBoxes, newYorkLines, newYorkLabels, newYorkProfiles)
    [newYorkBins, newYorkPoc, newYorkVah, newYorkVal, newYorkValueLowIndex, newYorkValueHighIndex] = profileStats(newYorkSampleHighs, newYorkSampleLows, newYorkSampleVolumes, newYorkLow, newYorkHigh, profileRowsInput, valueAreaInput)
    drawSession("NEW YORK", NEW_YORK_COLOR, newYorkStartBar, bar_index - 1, time, newYorkCashClose(time), newYorkHigh, newYorkLow, newYorkBins, newYorkPoc, newYorkVah, newYorkVal, newYorkValueLowIndex, newYorkValueHighIndex, showOteInput, showFibInput, showRrInput, newYorkBoxes, newYorkLines, newYorkLabels, newYorkProfiles)
    newYorkFinalized := true

// --- Consolidated session VWAP and deviation-band plots ---
bool vwapResetBar = tokyoStartEvent or londonStartEvent or newYorkStartEvent
float activeSessionVwap = tokyoVwapActive ? tokyoSessionVwap : londonVwapActive ? londonSessionVwap : newYorkVwapActive ? newYorkSessionVwap : na
float activeSessionDeviation = tokyoVwapActive ? tokyoSessionDeviation : londonVwapActive ? londonSessionDeviation : newYorkVwapActive ? newYorkSessionDeviation : na
color activeSessionVwapColor = tokyoVwapActive ? tokyoVwapColorInput : londonVwapActive ? londonVwapColorInput : newYorkVwapColorInput
float plottedSessionVwap = vwapResetBar ? na : activeSessionVwap
float plottedSessionDeviation = vwapResetBar ? na : activeSessionDeviation
plot(showSessionVwapInput ? plottedSessionVwap : na, "Session VWAP", color = activeSessionVwapColor, linewidth = 2, style = plot.style_linebr)
plot(showSessionVwapInput and deviationBandCountInput >= 1 ? plottedSessionVwap + plottedSessionDeviation : na, "Session VWAP +1σ", color = color.new(activeSessionVwapColor, 40), style = plot.style_linebr)
plot(showSessionVwapInput and deviationBandCountInput >= 1 ? plottedSessionVwap - plottedSessionDeviation : na, "Session VWAP -1σ", color = color.new(activeSessionVwapColor, 40), style = plot.style_linebr)
plot(showSessionVwapInput and deviationBandCountInput >= 2 ? plottedSessionVwap + plottedSessionDeviation * 2.0 : na, "Session VWAP +2σ", color = color.new(activeSessionVwapColor, 52), style = plot.style_linebr)
plot(showSessionVwapInput and deviationBandCountInput >= 2 ? plottedSessionVwap - plottedSessionDeviation * 2.0 : na, "Session VWAP -2σ", color = color.new(activeSessionVwapColor, 52), style = plot.style_linebr)
plot(showSessionVwapInput and deviationBandCountInput >= 3 ? plottedSessionVwap + plottedSessionDeviation * 3.0 : na, "Session VWAP +3σ", color = color.new(activeSessionVwapColor, 62), style = plot.style_linebr)
plot(showSessionVwapInput and deviationBandCountInput >= 3 ? plottedSessionVwap - plottedSessionDeviation * 3.0 : na, "Session VWAP -3σ", color = color.new(activeSessionVwapColor, 62), style = plot.style_linebr)
plot(showSessionVwapInput and deviationBandCountInput >= 4 ? plottedSessionVwap + plottedSessionDeviation * 4.0 : na, "Session VWAP +4σ", color = color.new(activeSessionVwapColor, 72), style = plot.style_linebr)
plot(showSessionVwapInput and deviationBandCountInput >= 4 ? plottedSessionVwap - plottedSessionDeviation * 4.0 : na, "Session VWAP -4σ", color = color.new(activeSessionVwapColor, 72), style = plot.style_linebr)
plot(showSessionVwapInput and deviationBandCountInput >= 5 ? plottedSessionVwap + plottedSessionDeviation * 5.0 : na, "Session VWAP +5σ", color = color.new(activeSessionVwapColor, 82), style = plot.style_linebr)
plot(showSessionVwapInput and deviationBandCountInput >= 5 ? plottedSessionVwap - plottedSessionDeviation * 5.0 : na, "Session VWAP -5σ", color = color.new(activeSessionVwapColor, 82), style = plot.style_linebr)

// --- Configurable momentum averages ---
float movingAverageOne = movingAverage(close, maOneLengthInput, maOneTypeInput)
float movingAverageTwo = movingAverage(close, maTwoLengthInput, maTwoTypeInput)
plot(showMovingAveragesInput ? movingAverageOne : na, "Momentum MA 1", color = maOneColorInput, linewidth = 2)
plot(showMovingAveragesInput ? movingAverageTwo : na, "Momentum MA 2", color = maTwoColorInput, linewidth = 2)
````
