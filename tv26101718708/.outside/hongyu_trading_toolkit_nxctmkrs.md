# Hongyu Trading Toolkit

- url: https://www.tradingview.com/script/NxCTmKrs/
- type: indicator
- pine_id: PUB;569d3cb969aa44d38e4c6a542e6f993e
- version: 1.0

## Description

1.日内极值范围概率
2.Bar count
3.Time Count
4. ema
5.VIX/VXN

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
//@version=6
indicator("Hongyu Trading Toolkit", overlay = true, max_labels_count = 500, max_lines_count = 500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 0. Master Module Switches
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string MS = "0. Module Switches"
bool enableExtremeModule = input.bool(true, "Show 1. Daily Extreme Gauge", group = MS)
bool enableBarCountModule = input.bool(true, "Show 2. Bar Count", group = MS)
bool enableCountdownModule = input.bool(true, "Show 3. Countdown Timer", group = MS)
bool enableMAModule = input.bool(true, "Show 4. Moving Averages", group = MS)
bool enableVIXRangeModule = input.bool(true, "Show 5. VIX / VXN Range", group = MS)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 1. Daily Extreme Formation Gauge
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string GP = "1. Daily Extreme Gauge"
bool showExtremeGauge = enableExtremeModule
string instrumentInput = input.string("Auto", "Instrument curve", options = ["Auto", "ES", "NQ"], group = GP)
string gaugePosInput = input.string("bottom_right", "Gauge position", options = ["top_left", "top_right", "bottom_left", "bottom_right"], group = GP)

// Fixed Gauge colors, inputs removed per request
color bgColorInput = #ECF1EC
color trackColorInput = #C5CFC5
color lowFillInput = #22c55e
color midFillInput = #eab308
color highFillInput = #ef4444
color valueTextInput = #1f2937
int bgTranspInput = 50
int trackTranspInput = 60
int fillTranspInput = 35

int BAR_ROWS = 10
int ROW_VAL = 10
int ROW_BAR_BOT = 9

var float[] ES_PROBS = array.from(
     15.43, 19.84, 22.91, 24.96, 27.01, 29.13, 30.87, 32.13, 33.15, 34.57,
     36.22, 37.32, 38.58, 39.45, 40.63, 42.83, 44.25, 45.35, 46.38, 47.24,
     48.43, 49.53, 50.08, 50.63, 51.50, 52.60, 52.99, 53.46, 54.09, 54.49,
     56.93, 58.35, 58.98, 59.92, 60.47, 60.63, 61.57, 62.20, 62.76, 63.46,
     64.17, 64.96, 65.51, 65.98, 66.22, 66.69, 67.24, 68.11, 68.19, 68.58,
     69.29, 69.84, 70.55, 70.87, 71.34, 71.42, 71.73, 72.05, 72.20, 72.44,
     73.39, 74.02, 74.33, 74.65, 74.88, 75.20, 75.35, 75.59, 75.91, 75.98,
     76.46, 76.77, 77.17, 77.32, 77.56, 78.19, 78.50, 78.82, 78.90, 79.06,
     79.37, 79.53, 79.69, 79.92, 79.92, 80.16, 80.55, 80.71, 80.94, 81.02,
     81.34)

var float[] NQ_PROBS = array.from(
     16.08, 21.96, 26.51, 29.65, 31.53, 34.35, 36.71, 38.59, 40.55, 41.96,
     43.84, 44.78, 46.20, 47.22, 48.47, 50.67, 52.31, 53.02, 53.88, 55.14,
     56.63, 57.80, 58.98, 59.61, 60.47, 61.80, 62.35, 63.06, 63.22, 63.45,
     65.49, 66.51, 66.90, 67.37, 68.24, 68.47, 69.02, 69.49, 70.04, 70.43,
     70.82, 71.45, 72.00, 72.63, 73.10, 74.04, 74.59, 75.37, 75.45, 76.16,
     76.78, 77.41, 77.88, 78.04, 78.35, 78.59, 78.75, 79.14, 79.61, 80.00,
     80.86, 81.25, 81.73, 81.96, 82.04, 82.27, 82.51, 82.82, 82.98, 83.14,
     83.45, 83.76, 84.08, 84.31, 84.39, 84.78, 84.94, 85.10, 85.18, 85.41,
     85.80, 86.12, 86.12, 86.35, 86.35, 86.59, 86.75, 86.82, 86.90, 86.90,
     87.06)

f_gaugePos() =>
    gaugePosInput == "top_left" ? position.top_left :
     gaugePosInput == "top_right" ? position.top_right :
     gaugePosInput == "bottom_left" ? position.bottom_left :
     position.bottom_right

f_fillColor(float pct) =>
    color baseColor = pct < 40 ? lowFillInput : pct < 70 ? midFillInput : highFillInput
    color.new(baseColor, fillTranspInput)

var table gaugeTable = table.new(f_gaugePos(), 1, 11, bgcolor = color.new(bgColorInput, bgTranspInput), border_width = 0, frame_width = 0)

string ticker = syminfo.ticker
bool isSPX = str.contains(ticker, "SPY") or str.contains(ticker, "SPX") or str.contains(ticker, "SP500") or str.contains(ticker, "US500") or ticker == "XSP" or str.contains(ticker, "ES")
bool isNDX = str.contains(ticker, "QQQ") or str.contains(ticker, "NQ") or str.contains(ticker, "NDX") or str.contains(ticker, "US100") or str.contains(ticker, "UST100")
bool supportedGauge = isSPX or isNDX

int nyH = hour(time, "America/New_York")
int nyM = minute(time, "America/New_York")
int minsFrom930 = (nyH - 9) * 60 + nyM - 30
bool inRTH = (nyH > 9 or (nyH == 9 and nyM >= 30)) and nyH < 16
bool afterB18 = inRTH and minsFrom930 > 90
bool useNQ = instrumentInput == "NQ" or (instrumentInput == "Auto" and isNDX)

int probIdx = int(math.min(90, math.max(0, minsFrom930)))
float prob = useNQ ? array.get(NQ_PROBS, probIdx) : array.get(ES_PROBS, probIdx)
string probText = afterB18 ? ">" + str.tostring(prob, "#.#") + "%" : str.tostring(prob, "#.#") + "%"

if barstate.islast
    table.set_position(gaugeTable, f_gaugePos())

    if showExtremeGauge and supportedGauge and inRTH
        color bg = color.new(bgColorInput, bgTranspInput)
        color track = color.new(trackColorInput, trackTranspInput)
        color fill = f_fillColor(prob)
        color valueText = color.new(valueTextInput, 0)

        for i = 0 to BAR_ROWS - 1
            int row = ROW_BAR_BOT - i
            float segPct = (float(i) + 1.0) / float(BAR_ROWS) * 100.0
            bool filled = prob >= segPct - 0.01
            table.cell(gaugeTable, 0, row, "", bgcolor = filled ? fill : track, text_size = size.tiny)

        table.cell(gaugeTable, 0, ROW_VAL, probText, text_color = valueText, text_size = size.tiny, bgcolor = bg)
    else
        table.clear(gaugeTable, 0, 0, 0, ROW_VAL)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 2. Bar Count
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string BC = "2. Bar Count"
bool showBarCount = enableBarCountModule
string barCountSizeInput = input.string("Normal", "Label Size", options = ["Auto", "Huge", "Large", "Normal", "Small", "Tiny"], group = BC)
color barCountTextColor = input.color(color.orange, "Text Color", group = BC)
int barCountInterval = input.int(2, "Display at every X bars", minval = 1, group = BC)

f_labelSize(string s) =>
    s == "Huge" ? size.huge :
     s == "Large" ? size.large :
     s == "Small" ? size.small :
     s == "Tiny" ? size.tiny :
     s == "Auto" ? size.auto :
     size.normal

bool newDay = ta.change(time("D")) != 0
var int barCount = 1

if newDay
    barCount := 1
else
    barCount += 1

if showBarCount and barCount % barCountInterval == 0
    label.new(
         bar_index,
         low,
         str.tostring(barCount),
         style = label.style_none,
         textcolor = barCountTextColor,
         yloc = yloc.belowbar,
         size = f_labelSize(barCountSizeInput))


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 3. Countdown Candle Timer
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string CT = "3. Countdown Timer"
bool showCountdown = enableCountdownModule
string countdownSizeInput = input.string("Large", "Countdown Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = CT)
string countdownPosInput = input.string("Bottom Center", "Countdown Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = CT)
color countdownColor = input.color(color.white, "Countdown Color", group = CT)

f_countdownSize(string s) =>
    s == "Tiny" ? size.tiny :
     s == "Small" ? size.small :
     s == "Normal" ? size.normal :
     s == "Large" ? size.large :
     size.huge

f_countdownPos() =>
    countdownPosInput == "Top Left" ? position.top_left :
     countdownPosInput == "Top Center" ? position.top_center :
     countdownPosInput == "Top Right" ? position.top_right :
     countdownPosInput == "Middle Left" ? position.middle_left :
     countdownPosInput == "Middle Center" ? position.middle_center :
     countdownPosInput == "Middle Right" ? position.middle_right :
     countdownPosInput == "Bottom Left" ? position.bottom_left :
     countdownPosInput == "Bottom Center" ? position.bottom_center :
     position.bottom_right

f_secondsToTime(float seconds) =>
    int tfSec = timeframe.in_seconds()
    int total = int(math.max(0, math.floor(seconds)))

    if tfSec >= 86400
        int days = int(math.floor(total / 86400))
        int hours = int(math.floor((total % 86400) / 3600))
        int minutes = int(math.floor((total % 3600) / 60))
        int secs = int(total % 60)
        string h = hours < 10 ? "0" + str.tostring(hours) : str.tostring(hours)
        string m = minutes < 10 ? "0" + str.tostring(minutes) : str.tostring(minutes)
        string s = secs < 10 ? "0" + str.tostring(secs) : str.tostring(secs)
        str.tostring(days) + "d " + h + ":" + m + ":" + s
    else if tfSec >= 3600
        int hours = int(math.floor(total / 3600))
        int minutes = int(math.floor((total % 3600) / 60))
        int secs = int(total % 60)
        string m = minutes < 10 ? "0" + str.tostring(minutes) : str.tostring(minutes)
        string s = secs < 10 ? "0" + str.tostring(secs) : str.tostring(secs)

        if timeframe.period == "60"
            str.tostring(minutes) + ":" + s
        else
            str.tostring(hours) + ":" + m + ":" + s
    else
        int minutes = int(math.floor(total / 60))
        int secs = int(total % 60)
        string s = secs < 10 ? "0" + str.tostring(secs) : str.tostring(secs)
        str.tostring(minutes) + ":" + s

f_updateCountdown() =>
    float tilNext = float(time_close - timenow) / 1000.0
    tilNext := tilNext < 0 ? 0 : tilNext
    f_secondsToTime(tilNext)

var table countdownTable = table.new(f_countdownPos(), 1, 1)

if barstate.islast
    table.set_position(countdownTable, f_countdownPos())

    if showCountdown
        table.cell(
             countdownTable,
             0,
             0,
             f_updateCountdown(),
             bgcolor = color.new(color.black, 70),
             text_color = countdownColor,
             text_size = f_countdownSize(countdownSizeInput))
    else
        table.clear(countdownTable, 0, 0, 0, 0)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 4. Moving Average Ribbon
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string MA = "4. Moving Averages"

f_ma(series float source, int length, string maType) =>
    maType == "SMA" ? ta.sma(source, length) :
     maType == "EMA" ? ta.ema(source, length) :
     maType == "SMMA (RMA)" ? ta.rma(source, length) :
     maType == "WMA" ? ta.wma(source, length) :
     maType == "VWMA" ? ta.vwma(source, length) :
     na

bool showMA1 = input.bool(true, "MA #1", inline = "MA1", group = MA)
string ma1Type = input.string("SMA", "", inline = "MA1", options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group = MA)
int ma1Length = input.int(20, "", inline = "MA1", minval = 1, group = MA)
color ma1Color = input.color(#f6c309, "", inline = "MA1", group = MA)

bool showMA2 = input.bool(true, "MA #2", inline = "MA2", group = MA)
string ma2Type = input.string("SMA", "", inline = "MA2", options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group = MA)
int ma2Length = input.int(50, "", inline = "MA2", minval = 1, group = MA)
color ma2Color = input.color(#fb9800, "", inline = "MA2", group = MA)

bool showMA3 = input.bool(true, "MA #3", inline = "MA3", group = MA)
string ma3Type = input.string("SMA", "", inline = "MA3", options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group = MA)
int ma3Length = input.int(100, "", inline = "MA3", minval = 1, group = MA)
color ma3Color = input.color(#fb6500, "", inline = "MA3", group = MA)

bool showMA4 = input.bool(true, "MA #4", inline = "MA4", group = MA)
string ma4Type = input.string("SMA", "", inline = "MA4", options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group = MA)
int ma4Length = input.int(200, "", inline = "MA4", minval = 1, group = MA)
color ma4Color = input.color(#f60c0c, "", inline = "MA4", group = MA)

float ma1 = f_ma(close, ma1Length, ma1Type)
float ma2 = f_ma(close, ma2Length, ma2Type)
float ma3 = f_ma(close, ma3Length, ma3Type)
float ma4 = f_ma(close, ma4Length, ma4Type)

plot(enableMAModule and showMA1 ? ma1 : na, color = ma1Color, title = "MA #1")
plot(enableMAModule and showMA2 ? ma2 : na, color = ma2Color, title = "MA #2")
plot(enableMAModule and showMA3 ? ma3 : na, color = ma3Color, title = "MA #3")
plot(enableMAModule and showMA4 ? ma4 : na, color = ma4Color, title = "MA #4")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 5. Index VIX / VXN / Volatility Range
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string VR = "5. Index VIX / VXN Range"

bool enableRangeLines = enableVIXRangeModule
bool onlyDrawUSSession = input.bool(true, title = "Only Draw During US RTH", group = VR)
bool showInnerBands = input.bool(true, title = "Show Inner Bands", group = VR)
bool showOuterBands = input.bool(true, title = "Show Outer Bands", group = VR)

float vrMultiplier1 = input.float(0.5, title = "Inner Band Multiplier (σ×N)", step = 0.1, group = VR)
float vrMultiplier2 = input.float(0.8, title = "Outer Band Multiplier (σ×N)", step = 0.1, group = VR)

color vrLineColorUp1 = input.color(color.new(color.green, 20), title = "Inner Upper Band Color", group = VR)
color vrLineColorDown1 = input.color(color.new(color.red, 20), title = "Inner Lower Band Color", group = VR)
color vrLineColorUp2 = input.color(color.new(color.green, 20), title = "Outer Upper Band Color", group = VR)
color vrLineColorDown2 = input.color(color.new(color.red, 20), title = "Outer Lower Band Color", group = VR)
int vrLineWidth = input.int(1, title = "Line Width", minval = 1, maxval = 4, group = VR)

string vrUsSession = input.session("0930-1600", title = "US RTH Session", group = VR)
string vrUsTimezone = input.string("America/New_York", title = "US RTH Timezone", group = VR)

string vrTicker = str.upper(syminfo.ticker)

bool vrIsSPX = vrTicker == "SPY" or str.contains(vrTicker, "SPX") or str.contains(vrTicker, "SP500") or str.contains(vrTicker, "US500") or vrTicker == "XSP" or str.contains(vrTicker, "ES")
bool vrIsNDX = str.contains(vrTicker, "QQQ") or str.contains(vrTicker, "NQ") or str.contains(vrTicker, "NDX") or str.contains(vrTicker, "US100") or str.contains(vrTicker, "UST100")
bool vrIsDow = vrTicker == "DIA" or str.contains(vrTicker, "YM") or str.contains(vrTicker, "US30")
bool vrIsR2k = vrTicker == "IWM" or vrTicker == "RUT" or str.contains(vrTicker, "RTY") or str.contains(vrTicker, "M2K") or str.contains(vrTicker, "US2000")
bool vrIsGold = vrTicker == "GLD" or vrTicker == "IAU" or str.contains(vrTicker, "GC") or str.contains(vrTicker, "GOLD") or str.contains(vrTicker, "XAUUSD")
bool vrIsOil = vrTicker == "USO" or str.contains(vrTicker, "CL") or str.contains(vrTicker, "USOIL")

bool vrIsTargetSymbol = vrIsSPX or vrIsNDX or vrIsDow or vrIsR2k or vrIsGold or vrIsOil

string vrVixSymbol = vrIsSPX ? "VIX" :
     vrIsNDX ? "VXN" :
     vrIsDow ? "VXD" :
     vrIsR2k ? "RVX" :
     vrIsGold ? "GVZ" :
     vrIsOil ? "OVX" :
     "VIX"

float vrVixClose = request.security(vrVixSymbol, timeframe.period, close)

bool vrInUSSession = not na(time(timeframe.period, vrUsSession, vrUsTimezone))
bool vrPrevInUSSession = bar_index > 0 ? vrInUSSession[1] : false
bool vrIsUSFirstBar = vrInUSSession and not vrPrevInUSSession
bool vrIsUSEnded = not vrInUSSession and vrPrevInUSSession

var float vrUsOpenPrice = na
var float vrUpper1 = na
var float vrLower1 = na
var float vrUpper2 = na
var float vrLower2 = na

var line vrLineUpper1 = na
var line vrLineLower1 = na
var line vrLineUpper2 = na
var line vrLineLower2 = na

if enableRangeLines and vrIsUSFirstBar and vrIsTargetSymbol and not na(vrVixClose)
    vrUsOpenPrice := open
    float vrSigma = vrUsOpenPrice * (vrVixClose / 100.0) / math.sqrt(252)
    vrUpper1 := vrUsOpenPrice + vrSigma * vrMultiplier1
    vrLower1 := vrUsOpenPrice - vrSigma * vrMultiplier1
    vrUpper2 := vrUsOpenPrice + vrSigma * vrMultiplier2
    vrLower2 := vrUsOpenPrice - vrSigma * vrMultiplier2

    if showInnerBands
        vrLineUpper1 := line.new(bar_index, vrUpper1, bar_index, vrUpper1, color = vrLineColorUp1, width = vrLineWidth)
        vrLineLower1 := line.new(bar_index, vrLower1, bar_index, vrLower1, color = vrLineColorDown1, width = vrLineWidth)
    else
        vrLineUpper1 := na
        vrLineLower1 := na

    if showOuterBands
        vrLineUpper2 := line.new(bar_index, vrUpper2, bar_index, vrUpper2, color = vrLineColorUp2, width = vrLineWidth)
        vrLineLower2 := line.new(bar_index, vrLower2, bar_index, vrLower2, color = vrLineColorDown2, width = vrLineWidth)
    else
        vrLineUpper2 := na
        vrLineLower2 := na

bool vrCanExtendLines = enableRangeLines and vrIsTargetSymbol and not na(vrUpper1) and (onlyDrawUSSession ? vrInUSSession : true)

if vrCanExtendLines
    if not na(vrLineUpper1)
        line.set_x2(vrLineUpper1, bar_index)
    if not na(vrLineLower1)
        line.set_x2(vrLineLower1, bar_index)
    if not na(vrLineUpper2)
        line.set_x2(vrLineUpper2, bar_index)
    if not na(vrLineLower2)
        line.set_x2(vrLineLower2, bar_index)

if (onlyDrawUSSession and vrIsUSEnded) or not enableRangeLines
    vrLineUpper1 := na
    vrLineLower1 := na
    vrLineUpper2 := na
    vrLineLower2 := na
````
