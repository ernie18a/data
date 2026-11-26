# SMACK Elite Pivotal Zones + Precision S/R

- url: https://www.tradingview.com/script/ZpMvh9eS-SMACK-Elite-Pivotal-Zones-Precision-S-R/
- type: indicator
- pine_id: PUB;bebfe5fcbf1146968bafbfd054cbccff
- version: 1.0

## Description

Smack Elite is a highly technical indicator using DEMA , stochastic, and pivotal zones in one indicator

## Source Code

````pine
//@version=6
indicator('SMACK Elite Pivotal Zones + Precision S/R', shorttitle = 'SMACK Elite Precision', overlay = true, max_labels_count = 500, max_lines_count = 300, max_boxes_count = 100)

// =====================================================
// SMACK ELITE PIVOTAL ZONES + PRECISION AUTO S/R
// Education only. Not financial advice.
// =====================================================

// ---------- Inputs ----------
src = input.source(close, 'Source')

showMAs = input.bool(true, 'Show DEMA / EMA / MA Lines')
showStrongLevels = input.bool(true, 'Show Strong High / Strong Low Lines')
showStrongLabels = input.bool(true, 'Show Strong High / Strong Low Labels')
showSignals = input.bool(true, 'Show SMACK Buy / Sell Labels')
showDashboard = input.bool(true, 'Show Dashboard')

// ---------- Custom MA Colors ----------
dema200ColorInput = input.color(color.orange, '200 DEMA Color')
ema200ColorInput = input.color(color.yellow, '200 EMA Color')
dema800ColorInput = input.color(color.rgb(190, 120, 255), '800 DEMA Color')
ema800ColorInput = input.color(color.white, '800 EMA Color')
sma800ColorInput = input.color(color.red, '800 SMA / MA Color')

// ---------- Buy / Sell Label Colors ----------
buyLabelColorInput = input.color(color.lime, 'SMACK Buy Label Color')
sellLabelColorInput = input.color(color.red, 'SMACK Sell Label Color')
buyLabelTextColorInput = input.color(color.black, 'SMACK Buy Text Color')
sellLabelTextColorInput = input.color(color.white, 'SMACK Sell Text Color')

// ---------- Bull / Bear Setup Label Colors + Text ----------
bullSetupLabelTextInput = input.string('BULL', 'Bull Setup Label Text')
bearSetupLabelTextInput = input.string('BEAR', 'Bear Setup Label Text')
bullSetupLabelColorInput = input.color(color.lime, 'Bull Setup Label Color')
bearSetupLabelColorInput = input.color(color.red, 'Bear Setup Label Color')
bullSetupTextColorInput = input.color(color.black, 'Bull Setup Text Color')
bearSetupTextColorInput = input.color(color.white, 'Bear Setup Text Color')

// ---------- Custom Support / Resistance Colors ----------
supportBlockColorInput = input.color(color.lime, 'Support Block Color')
resistanceBlockColorInput = input.color(color.red, 'Resistance Block Color')
supportBlockBorderColorInput = input.color(color.lime, 'Support Block Border Color')
resistanceBlockBorderColorInput = input.color(color.red, 'Resistance Block Border Color')

supportBlockOpacityInput = input.int(35, 'Support Block Opacity %', minval = 0, maxval = 100)
resistanceBlockOpacityInput = input.int(35, 'Resistance Block Opacity %', minval = 0, maxval = 100)
supportBorderOpacityInput = input.int(80, 'Support Border Opacity %', minval = 0, maxval = 100)
resistanceBorderOpacityInput = input.int(80, 'Resistance Border Opacity %', minval = 0, maxval = 100)
strengthOpacityBoost = input.int(2, 'Block Strength Opacity Boost', minval = 0, maxval = 10)

strongLowColorInput = input.color(color.lime, 'Strong Low / Support Line Color')
strongHighColorInput = input.color(color.red, 'Strong High / Resistance Line Color')

// ---------- Pivotal Zone Inputs ----------
showPivotalZones = input.bool(true, 'Show SMACK Pivotal Zone Labels')
showPivotGuideLines = input.bool(false, 'Show Pivotal Zone Guide Lines')
showPivotTPtags = input.bool(true, 'Show TP Tags On Pivotal Zone Labels')
showTPNearestMA = input.bool(true, 'Show Nearest MA Next To TP')
pivotLabelOffset = input.int(8, 'Pivotal Labels Right Offset', minval = 1, maxval = 50)

pivEngineMode = input.string('Frame Based', 'Pivotal Zone Engine', options = ['Frame Based', 'Previous Timeframe'])
frameSize = input.int(64, 'Frame Size', minval = 5, maxval = 500)
frameMultiplier = input.float(1.5, 'Frame Multiplier', minval = 0.25, maxval = 10.0)
ignoreWicks = input.bool(false, 'Ignore Wicks?')
showHistoricalLevels = input.bool(false, 'Show Historical Levels?')
lineExtensionInput = input.string('Right', 'Line Extension', options = ['None', 'Right', 'Both'])
showLevelsValue = input.bool(true, 'Show Levels Value?')
showCurrentLevels = input.bool(true, 'Show Current Levels')
pivotSourceTf = input.timeframe('D', 'Previous Timeframe Source')

// ---------- Auto S/R Blocks ----------
showAutoSRBlocks = input.bool(true, 'Show Auto Structure Support / Resistance Blocks')
srLeft = input.int(6, 'Auto S/R Left Bars', minval = 1, maxval = 50)
srRight = input.int(6, 'Auto S/R Right Bars', minval = 1, maxval = 50)
srZoneAtrMult = input.float(0.18, 'Auto S/R Block Thickness ATR', minval = 0.03, maxval = 2.0)
srConfirmAtrMult = input.float(0.35, 'Auto S/R Confirmation Distance ATR', minval = 0.05, maxval = 5.0)
maxSRZones = input.int(8, 'Max Auto S/R Blocks', minval = 2, maxval = 40)

// ---------- Precision Filters For Auto S/R Blocks ----------
usePreciseSRFilters = input.bool(true, 'Use Precise S/R Filters')
createBlocksOnCloseOnly = input.bool(true, 'Create Blocks Only On Confirmed Candle')
blockCooldownBars = input.int(20, 'Minimum Bars Between New Blocks', minval = 1, maxval = 500)
minBlockSpacingAtr = input.float(1.25, 'Minimum Distance Between Blocks ATR', minval = 0.1, maxval = 10.0)

showBullBearSetupLabels = input.bool(true, 'Show Bullish / Bearish Setup Labels')
bullBearSetupLabelSizeInput = input.string('Very Tiny', 'Bull/Bear Setup Label Size', options = ['Very Tiny', 'Tiny', 'Small', 'Medium', 'Large'])

// ---------- Timeframe Filter ----------
useTimeframeFilter = input.bool(true, 'Use Timeframe Filter For Blocks')
minTfSeconds = input.int(60, 'Minimum Timeframe Seconds', minval = 1)
maxTfSeconds = input.int(86400, 'Maximum Timeframe Seconds', minval = 1)

// ---------- Date Filter ----------
useDateFilter = input.bool(false, 'Use Date Range Filter')
fromYear = input.int(2000, 'From Year')
toYear = input.int(2100, 'To Year')
fromMonth = input.int(1, 'From Month', minval = 1, maxval = 12)
toMonth = input.int(12, 'To Month', minval = 1, maxval = 12)
fromDay = input.int(1, 'From Day', minval = 1, maxval = 31)
toDay = input.int(31, 'To Day', minval = 1, maxval = 31)

// ---------- Prime-Style Momentum Filters ----------
useTSIFilter = input.bool(true, 'Use TSI Filter')
tsiLongLength = input.int(14, 'TSI Long Length', minval = 1)
tsiShortLength = input.int(7, 'TSI Short Length', minval = 1)
tsiSignalLength = input.int(7, 'TSI Signal Length', minval = 1)

useRSIFilter = input.bool(true, 'Use RSI Filter')
rsiLengthInput = input.int(5, 'RSI Length', minval = 1)
rsiBuyLevel = input.float(50.0, 'RSI Cross Above Buy Level')
rsiSellLevel = input.float(50.0, 'RSI Cross Below Sell Level')

useHMAFilter = input.bool(true, 'Use HMA Trend Filter')
hmaLengthInput = input.int(4, 'HMA Length', minval = 1)

useCCIFilter = input.bool(true, 'Use CCI Filter')
cciLengthInput = input.int(6, 'CCI Length', minval = 1)
cciLowerLimit = input.float(-66.0, 'CCI Lower Limit')
cciUpperLimit = input.float(66.0, 'CCI Upper Limit')
cciLowerExit = input.float(-88.0, 'CCI Lower Exit')
cciUpperExit = input.float(88.0, 'CCI Upper Exit')

// ---------- Label Sizes ----------
signalSizeInput = input.string('Very Tiny', 'SMACK Buy/Sell Label Size', options = ['Very Tiny', 'Tiny', 'Small', 'Medium', 'Large'])
strongLabelSizeInput = input.string('Very Tiny', 'Strong High/Low Label Size', options = ['Very Tiny', 'Tiny', 'Small', 'Medium', 'Large'])
pivotLabelSizeInput = input.string('Small', 'Pivotal Zone Label Size', options = ['Tiny', 'Small', 'Medium', 'Large'])
dashboardSizeInput = input.string('Small', 'Dashboard Size', options = ['Small', 'Medium', 'Large'])

// ---------- Strong High / Low ----------
pivotLeft = input.int(5, 'Strong Level Left Bars', minval = 1, maxval = 50)
pivotRight = input.int(5, 'Strong Level Right Bars', minval = 1, maxval = 50)
strongLookback = input.int(100, 'Strong High/Low Lookback', minval = 20, maxval = 500)

// ---------- Signal Defaults ----------
scoreZoneAtrMult = input.float(1.25, 'Score Zone ATR Distance', minval = 0.1, maxval = 10.0)
signalZoneAtrMult = input.float(0.25, 'Closer Signal Zone ATR Distance', minval = 0.05, maxval = 5.0)
freshStrongBars = input.int(10, 'Fresh Strong Level Score Window', minval = 1, maxval = 100)

minBuyScore = input.int(70, 'Minimum Buy Score', minval = 0, maxval = 100)
minSellScore = input.int(70, 'Minimum Sell Score', minval = 0, maxval = 100)

useHTF = input.bool(false, 'Use Higher Timeframe Bias Filter')
htfTf = input.timeframe('15', 'Higher Timeframe Bias')
showOnlyFirstSignal = input.bool(true, 'Only Show First Signal In Setup')

// ---------- SL Settings ----------
slBufferMode = input.string('Auto', 'SL Buffer Mode', options = ['Auto', 'Index Points', 'ATR'])
indexSLPoints = input.float(45.0, 'Index SL Buffer Points', minval = 0.0, step = 1.0)
atrSLMult = input.float(0.75, 'Non-Index SL ATR Multiplier', minval = 0.05, maxval = 10.0)

// ---------- Size Helpers ----------
f_size(_s) =>
    _s == 'Very Tiny' ? size.tiny : _s == 'Tiny' ? size.tiny : _s == 'Small' ? size.small : _s == 'Large' ? size.large : size.normal

signalSize = f_size(signalSizeInput)
strongLabelSize = f_size(strongLabelSizeInput)
dashSize = f_size(dashboardSizeInput)
pivotLabelSize = f_size(pivotLabelSizeInput)
bullBearSetupLabelSize = f_size(bullBearSetupLabelSizeInput)

// ---------- Text Helpers ----------
f_buyText(_score) =>
    signalSizeInput == 'Very Tiny' ? 'BUY ' + str.tostring(_score) : signalSizeInput == 'Tiny' ? 'BUY\n' + str.tostring(_score) : 'SMACK BUY\nScore ' + str.tostring(_score)

f_sellText(_score) =>
    signalSizeInput == 'Very Tiny' ? 'SELL ' + str.tostring(_score) : signalSizeInput == 'Tiny' ? 'SELL\n' + str.tostring(_score) : 'SMACK SELL\nScore ' + str.tostring(_score)

f_strongHighText() =>
    strongLabelSizeInput == 'Very Tiny' ? 'SH' : strongLabelSizeInput == 'Tiny' ? 'HIGH' : 'STRONG HIGH'

f_strongLowText() =>
    strongLabelSizeInput == 'Very Tiny' ? 'SL' : strongLabelSizeInput == 'Tiny' ? 'LOW' : 'STRONG LOW'

// ---------- Base Colors ----------
cGold = color.rgb(212, 175, 55)
cBlack = color.rgb(0, 0, 0)
cWhite = color.white
cGray = color.gray
cAqua = color.aqua
cBlue = color.rgb(0, 170, 255)
cMagenta = color.rgb(180, 40, 135)

// ---------- Opacity Helpers ----------
f_opacityToTransparency(_opacity) =>
    100 - math.min(math.max(_opacity, 0), 100)

f_strengthOpacity(_baseOpacity, _strength) =>
    math.min(_baseOpacity + (_strength - 1) * strengthOpacityBoost, 100)

// ---------- DEMA Function ----------
f_dema(_src, _len) =>
    ema1 = ta.ema(_src, _len)
    ema2 = ta.ema(ema1, _len)
    2.0 * ema1 - ema2

// ---------- Full MA System ----------
dema200 = f_dema(src, 200)
ema200 = ta.ema(src, 200)
dema800 = f_dema(src, 800)
ema800 = ta.ema(src, 800)
sma800 = ta.sma(src, 800)

plot(showMAs ? dema200 : na, '200 DEMA', color = dema200ColorInput, linewidth = 2)
plot(showMAs ? ema200 : na, '200 EMA', color = ema200ColorInput, linewidth = 2)
plot(showMAs ? dema800 : na, '800 DEMA', color = dema800ColorInput, linewidth = 2)
plot(showMAs ? ema800 : na, '800 EMA', color = ema800ColorInput, linewidth = 2)
plot(showMAs ? sma800 : na, '800 SMA / 800 MA', color = sma800ColorInput, linewidth = 3)

// ---------- ATR ----------
atr = ta.atr(14)

// =====================================================
// SMACK PIVOTAL ZONE SYSTEM - FRAME BASED
// =====================================================
frameLookbackRaw = math.round(frameSize * frameMultiplier)
frameLookback = math.max(frameLookbackRaw, 5)

bodyHigh = math.max(open, close)
bodyLow = math.min(open, close)

rangeHighSource = ignoreWicks ? bodyHigh : high
rangeLowSource = ignoreWicks ? bodyLow : low

frameHigh = ta.highest(rangeHighSource, frameLookback)
frameLow = ta.lowest(rangeLowSource, frameLookback)

prevTfHigh = request.security(syminfo.tickerid, pivotSourceTf, ignoreWicks ? math.max(open[1], close[1]) : high[1], lookahead = barmerge.lookahead_on)
prevTfLow = request.security(syminfo.tickerid, pivotSourceTf, ignoreWicks ? math.min(open[1], close[1]) : low[1], lookahead = barmerge.lookahead_on)

pivHigh = pivEngineMode == 'Frame Based' ? frameHigh : prevTfHigh
pivLow = pivEngineMode == 'Frame Based' ? frameLow : prevTfLow

pivStep = math.max((pivHigh - pivLow) / 8.0, syminfo.mintick)

lvlM3 = pivLow - pivStep * 3.0
lvlM2 = pivLow - pivStep * 2.0
lvlM1 = pivLow - pivStep * 1.0

lvlS0 = pivLow
lvlS1 = pivLow + pivStep * 1.0
lvlS2 = pivLow + pivStep * 2.0
lvlS3 = pivLow + pivStep * 3.0
lvlP4 = pivLow + pivStep * 4.0
lvlR5 = pivLow + pivStep * 5.0
lvlR6 = pivLow + pivStep * 6.0
lvlR7 = pivLow + pivStep * 7.0
lvlR8 = pivLow + pivStep * 8.0

lvlP1 = pivHigh + pivStep * 1.0
lvlP2 = pivHigh + pivStep * 2.0
lvlP3 = pivHigh + pivStep * 3.0

showPivLines = showPivotGuideLines and showCurrentLevels

plot(showPivLines ? lvlM3 : na, '-3 Extreme Oversold', color = cMagenta, linewidth = 1, style = plot.style_linebr)
plot(showPivLines ? lvlM2 : na, '-2 Extreme Oversold', color = color.blue, linewidth = 1, style = plot.style_linebr)
plot(showPivLines ? lvlM1 : na, '-1 Extreme Oversold', color = color.purple, linewidth = 1, style = plot.style_linebr)

plot(showPivLines ? lvlS0 : na, 'S0', color = cBlue, linewidth = 1, style = plot.style_linebr)
plot(showPivLines ? lvlS1 : na, 'S1', color = color.yellow, linewidth = 1, style = plot.style_linebr)
plot(showPivLines ? lvlS2 : na, 'S2 Reversal Buy Zone', color = color.orange, linewidth = 2, style = plot.style_linebr)
plot(showPivLines ? lvlS3 : na, 'S3', color = color.lime, linewidth = 1, style = plot.style_linebr)
plot(showPivLines ? lvlP4 : na, 'P4 Equilibrium', color = cBlue, linewidth = 2, style = plot.style_linebr)
plot(showPivLines ? lvlR5 : na, 'R5', color = color.lime, linewidth = 1, style = plot.style_linebr)
plot(showPivLines ? lvlR6 : na, 'R6 Reversal Sell Zone', color = color.orange, linewidth = 2, style = plot.style_linebr)
plot(showPivLines ? lvlR7 : na, 'R7', color = color.yellow, linewidth = 1, style = plot.style_linebr)
plot(showPivLines ? lvlR8 : na, 'R8', color = cBlue, linewidth = 1, style = plot.style_linebr)

plot(showPivLines ? lvlP1 : na, '+1 Extreme Overbought', color = color.purple, linewidth = 1, style = plot.style_linebr)
plot(showPivLines ? lvlP2 : na, '+2 Extreme Overbought', color = color.blue, linewidth = 1, style = plot.style_linebr)
plot(showPivLines ? lvlP3 : na, '+3 Extreme Overbought', color = cMagenta, linewidth = 1, style = plot.style_linebr)

// ---------- Pivotal Arrays ----------
var array<string> pivNames = array.from('-3', '-2', '-1', 'S0', 'S1', 'S2', 'S3', 'P4', 'R5', 'R6', 'R7', 'R8', '+1', '+2', '+3')
var array<float> pivVals = array.new_float(15, na)

array.set(pivVals, 0, lvlM3)
array.set(pivVals, 1, lvlM2)
array.set(pivVals, 2, lvlM1)
array.set(pivVals, 3, lvlS0)
array.set(pivVals, 4, lvlS1)
array.set(pivVals, 5, lvlS2)
array.set(pivVals, 6, lvlS3)
array.set(pivVals, 7, lvlP4)
array.set(pivVals, 8, lvlR5)
array.set(pivVals, 9, lvlR6)
array.set(pivVals, 10, lvlR7)
array.set(pivVals, 11, lvlR8)
array.set(pivVals, 12, lvlP1)
array.set(pivVals, 13, lvlP2)
array.set(pivVals, 14, lvlP3)

f_pivColor(_idx) =>
    _idx == 0 ? cMagenta : _idx == 1 ? color.blue : _idx == 2 ? color.purple : _idx == 3 ? cBlue : _idx == 4 ? color.yellow : _idx == 5 ? color.orange : _idx == 6 ? color.lime : _idx == 7 ? cBlue : _idx == 8 ? color.lime : _idx == 9 ? color.orange : _idx == 10 ? color.yellow : _idx == 11 ? cBlue : _idx == 12 ? color.purple : _idx == 13 ? color.blue : cMagenta

f_nearestPivotIndex(_price) =>
    int idx = 0
    float best = 100000000000.0
    for i = 0 to 14 by 1
        lv = array.get(pivVals, i)
        d = math.abs(_price - lv)
        if d < best
            best := d
            idx := i
            idx
    idx

f_nextPivotIndex(_side, _base, _rank) =>
    _side == 'BUY' ? math.min(_base + _rank, 14) : math.max(_base - _rank, 0)

f_nearestMAText(_price) =>
    float best = math.abs(_price - dema200)
    string nm = '200 DEMA'
    float val = dema200

    d1 = math.abs(_price - ema200)
    if d1 < best
        best := d1
        nm := '200 EMA'
        val := ema200
        val

    d2 = math.abs(_price - dema800)
    if d2 < best
        best := d2
        nm := '800 DEMA'
        val := dema800
        val

    d3 = math.abs(_price - ema800)
    if d3 < best
        best := d3
        nm := '800 EMA'
        val := ema800
        val

    d4 = math.abs(_price - sma800)
    if d4 < best
        best := d4
        nm := '800 SMA'
        val := sma800
        val

    nm + ' ' + str.tostring(val, format.mintick)

nearestPivotIndex = f_nearestPivotIndex(close)

// ---------- Pivotal Zone Logic ----------
nearS0 = math.abs(close - lvlS0) <= atr * signalZoneAtrMult
nearS1 = math.abs(close - lvlS1) <= atr * signalZoneAtrMult
nearS2 = math.abs(close - lvlS2) <= atr * signalZoneAtrMult
nearS3 = math.abs(close - lvlS3) <= atr * signalZoneAtrMult

nearR5 = math.abs(close - lvlR5) <= atr * signalZoneAtrMult
nearR6 = math.abs(close - lvlR6) <= atr * signalZoneAtrMult
nearR7 = math.abs(close - lvlR7) <= atr * signalZoneAtrMult
nearR8 = math.abs(close - lvlR8) <= atr * signalZoneAtrMult

nearOversoldExtreme = close <= lvlM1
nearOverboughtExtreme = close >= lvlP1

pivotalBuyZone = nearS0 or nearS1 or nearS2 or nearS3 or nearOversoldExtreme
pivotalSellZone = nearR5 or nearR6 or nearR7 or nearR8 or nearOverboughtExtreme

// =====================================================
// STOCHASTIC
// =====================================================
stochFastRaw = ta.stoch(close, high, low, 14)
stochFast = ta.sma(stochFastRaw, 6)

stochSlowRaw = ta.stoch(close, high, low, 100)
stochSlow = ta.sma(stochSlowRaw, 6)

stochBuy = stochFast > stochSlow and stochFast > stochFast[1]
stochSell = stochFast < stochSlow and stochFast < stochFast[1]

// =====================================================
// PRIME-STYLE BULLISH / BEARISH SETUP FILTERS
// =====================================================
chartTfSecondsRaw = timeframe.in_seconds(timeframe.period)
chartTfSeconds = na(chartTfSecondsRaw) ? 60 : chartTfSecondsRaw

timeframeOk = not useTimeframeFilter or chartTfSeconds >= minTfSeconds and chartTfSeconds <= maxTfSeconds

startTime = timestamp(fromYear, fromMonth, fromDay, 0, 0)
endTime = timestamp(toYear, toMonth, toDay, 23, 59)
dateOk = not useDateFilter or time >= startTime and time <= endTime

confirmedBarOk = not createBlocksOnCloseOnly or barstate.isconfirmed

// ---------- TSI ----------
tsiMomentum = ta.change(close)
tsiAbsMomentum = math.abs(tsiMomentum)

tsiDoubleSmooth = ta.ema(ta.ema(tsiMomentum, tsiShortLength), tsiLongLength)
tsiAbsDoubleSmooth = ta.ema(ta.ema(tsiAbsMomentum, tsiShortLength), tsiLongLength)

tsiValue = tsiAbsDoubleSmooth != 0 ? 100 * tsiDoubleSmooth / tsiAbsDoubleSmooth : 0
tsiSignal = ta.ema(tsiValue, tsiSignalLength)

tsiBull = tsiValue > tsiSignal and tsiValue > tsiValue[1]
tsiBear = tsiValue < tsiSignal and tsiValue < tsiValue[1]

// ---------- RSI ----------
rsiValue = ta.rsi(close, rsiLengthInput)
rsiBull = rsiValue > rsiBuyLevel and rsiValue >= rsiValue[1]
rsiBear = rsiValue < rsiSellLevel and rsiValue <= rsiValue[1]

// ---------- HMA ----------
hmaValue = ta.hma(close, hmaLengthInput)
hmaBull = close > hmaValue and hmaValue > hmaValue[1]
hmaBear = close < hmaValue and hmaValue < hmaValue[1]

// ---------- CCI ----------
cciValue = ta.cci(hlc3, cciLengthInput)
cciBull = cciValue > cciLowerLimit and cciValue > cciValue[1]
cciBear = cciValue < cciUpperLimit and cciValue < cciValue[1]

// ---------- Filter Pass Conditions ----------
tsiBullOk = not useTSIFilter or tsiBull
tsiBearOk = not useTSIFilter or tsiBear

rsiBullOk = not useRSIFilter or rsiBull
rsiBearOk = not useRSIFilter or rsiBear

hmaBullOk = not useHMAFilter or hmaBull
hmaBearOk = not useHMAFilter or hmaBear

cciBullOk = not useCCIFilter or cciBull
cciBearOk = not useCCIFilter or cciBear

bullishSetup = timeframeOk and dateOk and confirmedBarOk and tsiBullOk and rsiBullOk and hmaBullOk and cciBullOk
bearishSetup = timeframeOk and dateOk and confirmedBarOk and tsiBearOk and rsiBearOk and hmaBearOk and cciBearOk

precisionBullOk = not usePreciseSRFilters or bullishSetup
precisionBearOk = not usePreciseSRFilters or bearishSetup

// =====================================================
// STRONG HIGH / STRONG LOW
// =====================================================
ph = ta.pivothigh(high, pivotLeft, pivotRight)
pl = ta.pivotlow(low, pivotLeft, pivotRight)

isStrongHigh = not na(ph) and ph >= ta.highest(high, strongLookback)[pivotRight]
isStrongLow = not na(pl) and pl <= ta.lowest(low, strongLookback)[pivotRight]

var float strongHigh = na
var float strongLow = na
var int strongHighBar = na
var int strongLowBar = na

if isStrongHigh
    strongHigh := ph
    strongHighBar := bar_index - pivotRight
    if showStrongLabels
        label.new(strongHighBar, ph, f_strongHighText(), style = label.style_label_down, color = strongHighColorInput, textcolor = cWhite, size = strongLabelSize)

if isStrongLow
    strongLow := pl
    strongLowBar := bar_index - pivotRight
    if showStrongLabels
        label.new(strongLowBar, pl, f_strongLowText(), style = label.style_label_up, color = strongLowColorInput, textcolor = color.black, size = strongLabelSize)

plot(showStrongLevels ? strongHigh : na, 'Strong High', color = strongHighColorInput, linewidth = 2, style = plot.style_linebr)
plot(showStrongLevels ? strongLow : na, 'Strong Low', color = strongLowColorInput, linewidth = 2, style = plot.style_linebr)

// =====================================================
// SMACK AUTO STRUCTURE SUPPORT / RESISTANCE BLOCKS
// =====================================================
srPH = ta.pivothigh(high, srLeft, srRight)
srPL = ta.pivotlow(low, srLeft, srRight)

var array<box> zoneBoxes = array.new_box()
var array<float> zoneTops = array.new_float()
var array<float> zoneBottoms = array.new_float()
var array<int> zoneTypes = array.new_int()
var array<int> zoneStrengths = array.new_int()

f_zoneColor(_type, _strength) =>
    int supportOpacity = f_strengthOpacity(supportBlockOpacityInput, _strength)
    int resistanceOpacity = f_strengthOpacity(resistanceBlockOpacityInput, _strength)
    int supportTrans = f_opacityToTransparency(supportOpacity)
    int resistanceTrans = f_opacityToTransparency(resistanceOpacity)
    _type == 1 ? color.new(supportBlockColorInput, supportTrans) : color.new(resistanceBlockColorInput, resistanceTrans)

f_zoneBorder(_type, _strength) =>
    int supportOpacity = f_strengthOpacity(supportBorderOpacityInput, _strength)
    int resistanceOpacity = f_strengthOpacity(resistanceBorderOpacityInput, _strength)
    int supportTrans = f_opacityToTransparency(supportOpacity)
    int resistanceTrans = f_opacityToTransparency(resistanceOpacity)
    _type == 1 ? color.new(supportBlockBorderColorInput, supportTrans) : color.new(resistanceBlockBorderColorInput, resistanceTrans)

f_farFromExistingZones(_price) =>
    bool ok = true
    if array.size(zoneBoxes) > 0
        for i = 0 to array.size(zoneBoxes) - 1 by 1
            zTopCheck = array.get(zoneTops, i)
            zBotCheck = array.get(zoneBottoms, i)
            zMidCheck = (zTopCheck + zBotCheck) / 2.0
            if math.abs(_price - zMidCheck) <= atr * minBlockSpacingAtr
                ok := false
                ok
    ok

var int lastSupportBlockBar = na
var int lastResistanceBlockBar = na

supportCooldownOk = na(lastSupportBlockBar) or bar_index - lastSupportBlockBar >= blockCooldownBars
resistanceCooldownOk = na(lastResistanceBlockBar) or bar_index - lastResistanceBlockBar >= blockCooldownBars

// ---------- Create Resistance Block From Pivot High ----------
resistanceBlockAllowed = showAutoSRBlocks and not na(srPH) and precisionBearOk and resistanceCooldownOk and f_farFromExistingZones(srPH)

if resistanceBlockAllowed
    zMid = srPH
    zTop = zMid + atr * srZoneAtrMult
    zBot = zMid - atr * srZoneAtrMult

    if array.size(zoneBoxes) >= maxSRZones
        oldBox = array.shift(zoneBoxes)
        box.delete(oldBox)
        array.shift(zoneTops)
        array.shift(zoneBottoms)
        array.shift(zoneTypes)
        array.shift(zoneStrengths)

    b = box.new(left = bar_index - srRight, top = zTop, right = bar_index, bottom = zBot, bgcolor = f_zoneColor(-1, 1), border_color = f_zoneBorder(-1, 1))
    array.push(zoneBoxes, b)
    array.push(zoneTops, zTop)
    array.push(zoneBottoms, zBot)
    array.push(zoneTypes, -1)
    array.push(zoneStrengths, 1)

    lastResistanceBlockBar := bar_index

    if showBullBearSetupLabels
        label.new(bar_index - srRight, zTop, bearSetupLabelTextInput, style = label.style_label_down, color = bearSetupLabelColorInput, textcolor = bearSetupTextColorInput, size = bullBearSetupLabelSize)

// ---------- Create Support Block From Pivot Low ----------
supportBlockAllowed = showAutoSRBlocks and not na(srPL) and precisionBullOk and supportCooldownOk and f_farFromExistingZones(srPL)

if supportBlockAllowed
    zMid = srPL
    zTop = zMid + atr * srZoneAtrMult
    zBot = zMid - atr * srZoneAtrMult

    if array.size(zoneBoxes) >= maxSRZones
        oldBox = array.shift(zoneBoxes)
        box.delete(oldBox)
        array.shift(zoneTops)
        array.shift(zoneBottoms)
        array.shift(zoneTypes)
        array.shift(zoneStrengths)

    b = box.new(left = bar_index - srRight, top = zTop, right = bar_index, bottom = zBot, bgcolor = f_zoneColor(1, 1), border_color = f_zoneBorder(1, 1))
    array.push(zoneBoxes, b)
    array.push(zoneTops, zTop)
    array.push(zoneBottoms, zBot)
    array.push(zoneTypes, 1)
    array.push(zoneStrengths, 1)

    lastSupportBlockBar := bar_index

    if showBullBearSetupLabels
        label.new(bar_index - srRight, zBot, bullSetupLabelTextInput, style = label.style_label_up, color = bullSetupLabelColorInput, textcolor = bullSetupTextColorInput, size = bullBearSetupLabelSize)

// ---------- Maintain Blocks ----------
bool nearBlockSupport = false
bool nearBlockResistance = false
bool supportBlockReject = false
bool resistanceBlockReject = false
int strongestSupportStrength = 0
int strongestResistanceStrength = 0

if showAutoSRBlocks and array.size(zoneBoxes) > 0
    for i = 0 to array.size(zoneBoxes) - 1 by 1
        bx = array.get(zoneBoxes, i)
        zTop = array.get(zoneTops, i)
        zBot = array.get(zoneBottoms, i)
        zType = array.get(zoneTypes, i)
        zStrength = array.get(zoneStrengths, i)

        box.set_right(bx, bar_index)

        zoneTouched = high >= zBot and low <= zTop
        if zoneTouched
            zStrength := math.min(zStrength + 1, 15)
            zStrength

        if zType == 1 and close < zBot
            zType := -1
            zType
        else if zType == -1 and close > zTop
            zType := 1
            zType

        array.set(zoneTypes, i, zType)
        array.set(zoneStrengths, i, zStrength)

        box.set_bgcolor(bx, f_zoneColor(zType, zStrength))
        box.set_border_color(bx, f_zoneBorder(zType, zStrength))

        if zType == 1
            if math.abs(close - (zTop + zBot) / 2.0) <= atr * srConfirmAtrMult or zoneTouched
                nearBlockSupport := true
                strongestSupportStrength := math.max(strongestSupportStrength, zStrength)
                strongestSupportStrength
            if low <= zTop and close > zBot and close > open
                supportBlockReject := true
                supportBlockReject

        if zType == -1
            if math.abs(close - (zTop + zBot) / 2.0) <= atr * srConfirmAtrMult or zoneTouched
                nearBlockResistance := true
                strongestResistanceStrength := math.max(strongestResistanceStrength, zStrength)
                strongestResistanceStrength
            if high >= zBot and close < zTop and close < open
                resistanceBlockReject := true
                resistanceBlockReject

// =====================================================
// MARKET STRUCTURE
// =====================================================
var float lastPivotHigh = na
var float lastPivotLow = na
var string highType = 'None'
var string lowType = 'None'
var string structure = 'Neutral'

if not na(ph)
    highType := na(lastPivotHigh) ? 'H' : ph > lastPivotHigh ? 'HH' : 'LH'
    lastPivotHigh := ph
    lastPivotHigh

if not na(pl)
    lowType := na(lastPivotLow) ? 'L' : pl > lastPivotLow ? 'HL' : 'LL'
    lastPivotLow := pl
    lastPivotLow

bullBOS = not na(lastPivotHigh) and ta.crossover(close, lastPivotHigh)
bearBOS = not na(lastPivotLow) and ta.crossunder(close, lastPivotLow)

if bullBOS or lowType == 'HL'
    structure := 'Bullish'
    structure
else if bearBOS or highType == 'LH'
    structure := 'Bearish'
    structure

// ---------- Strong Zone Logic ----------
nearStrongLowScore = not na(strongLow) and math.abs(close - strongLow) <= atr * scoreZoneAtrMult
nearStrongHighScore = not na(strongHigh) and math.abs(close - strongHigh) <= atr * scoreZoneAtrMult

nearStrongLowSignal = not na(strongLow) and math.abs(close - strongLow) <= atr * signalZoneAtrMult
nearStrongHighSignal = not na(strongHigh) and math.abs(close - strongHigh) <= atr * signalZoneAtrMult

barsSinceStrongLow = ta.barssince(isStrongLow)
barsSinceStrongHigh = ta.barssince(isStrongHigh)

freshStrongLow = not na(barsSinceStrongLow) and barsSinceStrongLow <= freshStrongBars
freshStrongHigh = not na(barsSinceStrongHigh) and barsSinceStrongHigh <= freshStrongBars

bullSweep = not na(strongLow[1]) and low < strongLow[1] and close > strongLow[1]
bearSweep = not na(strongHigh[1]) and high > strongHigh[1] and close < strongHigh[1]

buySignalContext = nearStrongLowSignal or bullSweep or supportBlockReject or nearBlockSupport or pivotalBuyZone
sellSignalContext = nearStrongHighSignal or bearSweep or resistanceBlockReject or nearBlockResistance or pivotalSellZone

buyScoreContext = nearStrongLowScore or freshStrongLow or bullSweep or nearBlockSupport or pivotalBuyZone
sellScoreContext = nearStrongHighScore or freshStrongHigh or bearSweep or nearBlockResistance or pivotalSellZone

// =====================================================
// MA CONFIRMATION
// =====================================================
dema200CurlUp = dema200 > dema200[1]
dema800CurlUp = dema800 > dema800[1]
ema200CurlUp = ema200 > ema200[1]
ema800CurlUp = ema800 > ema800[1]
sma800CurlUp = sma800 > sma800[1]

dema200CurlDown = dema200 < dema200[1]
dema800CurlDown = dema800 < dema800[1]
ema200CurlDown = ema200 < ema200[1]
ema800CurlDown = ema800 < ema800[1]
sma800CurlDown = sma800 < sma800[1]

priceAbove200s = close > dema200 and close > ema200
priceAbove800s = close > dema800 and close > ema800 and close > sma800

priceBelow200s = close < dema200 and close < ema200
priceBelow800s = close < dema800 and close < ema800 and close < sma800

priceAboveAllMAs = priceAbove200s and priceAbove800s
priceBelowAllMAs = priceBelow200s and priceBelow800s

maCurlBuy = dema200CurlUp or dema800CurlUp or ema200CurlUp or ema800CurlUp or sma800CurlUp
maCurlSell = dema200CurlDown or dema800CurlDown or ema200CurlDown or ema800CurlDown or sma800CurlDown

maBuyConfirm = priceAboveAllMAs or ta.crossover(close, dema200) or ta.crossover(close, ema200) or maCurlBuy
maSellConfirm = priceBelowAllMAs or ta.crossunder(close, dema200) or ta.crossunder(close, ema200) or maCurlSell

// ---------- Candles ----------
bullCandle = close > open
bearCandle = close < open

bullStrongCandle = close > open and close > high[1]
bearStrongCandle = close < open and close < low[1]

bullEngulf = close > open and close[1] < open[1] and close > open[1]
bearEngulf = close < open and close[1] > open[1] and close < open[1]

// ---------- Premium / Discount ----------
rangeReady = not na(strongHigh) and not na(strongLow) and strongHigh > strongLow
rangeMid = rangeReady ? (strongHigh + strongLow) / 2.0 : na

discount = rangeReady and close < rangeMid
premium = rangeReady and close > rangeMid

plot(rangeReady ? rangeMid : na, 'Strong High/Low Midpoint', color = color.new(cGold, 60), linewidth = 1)

// ---------- Higher Timeframe Bias ----------
htfClose = request.security(syminfo.tickerid, htfTf, close)
htfDema200 = request.security(syminfo.tickerid, htfTf, f_dema(close, 200))
htfEma200 = request.security(syminfo.tickerid, htfTf, ta.ema(close, 200))
htfDema800 = request.security(syminfo.tickerid, htfTf, f_dema(close, 800))
htfEma800 = request.security(syminfo.tickerid, htfTf, ta.ema(close, 800))
htfSma800 = request.security(syminfo.tickerid, htfTf, ta.sma(close, 800))

htfBull = htfClose > htfDema200 and htfClose > htfEma200 and htfClose > htfDema800 and htfClose > htfEma800 and htfClose > htfSma800
htfBear = htfClose < htfDema200 and htfClose < htfEma200 and htfClose < htfDema800 and htfClose < htfEma800 and htfClose < htfSma800

htfBuyOk = useHTF ? htfBull : true
htfSellOk = useHTF ? htfBear : true

bullStructureConfirm = structure == 'Bullish' or bullBOS or lowType == 'HL'
bearStructureConfirm = structure == 'Bearish' or bearBOS or highType == 'LH'

// =====================================================
// SCORE SYSTEM
// =====================================================
int buyScore = 0
int sellScore = 0

buyScore := buyScore + (buyScoreContext ? 20 : 0)
buyScore := buyScore + (maBuyConfirm ? 18 : 0)
buyScore := buyScore + (priceAbove200s ? 7 : 0)
buyScore := buyScore + (priceAbove800s ? 7 : 0)
buyScore := buyScore + (stochBuy ? 12 : 0)
buyScore := buyScore + (bullStructureConfirm ? 8 : 0)
buyScore := buyScore + (bullStrongCandle or bullEngulf or bullCandle ? 8 : 0)
buyScore := buyScore + (bullSweep ? 8 : 0)
buyScore := buyScore + (discount ? 5 : 0)
buyScore := buyScore + (htfBuyOk ? 5 : 0)
buyScore := buyScore + (nearBlockSupport ? 8 : 0)
buyScore := buyScore + (supportBlockReject ? 10 : 0)
buyScore := buyScore + (nearS2 ? 12 : nearS1 or nearS0 or nearS3 ? 7 : 0)
buyScore := buyScore + (nearOversoldExtreme ? 10 : 0)
buyScore := buyScore + (bullishSetup ? 10 : 0)

sellScore := sellScore + (sellScoreContext ? 20 : 0)
sellScore := sellScore + (maSellConfirm ? 18 : 0)
sellScore := sellScore + (priceBelow200s ? 7 : 0)
sellScore := sellScore + (priceBelow800s ? 7 : 0)
sellScore := sellScore + (stochSell ? 12 : 0)
sellScore := sellScore + (bearStructureConfirm ? 8 : 0)
sellScore := sellScore + (bearStrongCandle or bearEngulf or bearCandle ? 8 : 0)
sellScore := sellScore + (bearSweep ? 8 : 0)
sellScore := sellScore + (premium ? 5 : 0)
sellScore := sellScore + (htfSellOk ? 5 : 0)
sellScore := sellScore + (nearBlockResistance ? 8 : 0)
sellScore := sellScore + (resistanceBlockReject ? 10 : 0)
sellScore := sellScore + (nearR6 ? 12 : nearR5 or nearR7 or nearR8 ? 7 : 0)
sellScore := sellScore + (nearOverboughtExtreme ? 10 : 0)
sellScore := sellScore + (bearishSetup ? 10 : 0)

buyScore := math.min(buyScore, 100)
sellScore := math.min(sellScore, 100)

// =====================================================
// TP / SL LOGIC
// =====================================================
isIndexLike = syminfo.type == 'index' or str.contains(syminfo.ticker, 'US30') or str.contains(syminfo.ticker, 'NAS') or str.contains(syminfo.ticker, 'US100') or str.contains(syminfo.ticker, 'DJI') or str.contains(syminfo.ticker, 'SPX') or str.contains(syminfo.ticker, 'US500')

useIndexPointSL = slBufferMode == 'Index Points' or slBufferMode == 'Auto' and isIndexLike
slBuffer = useIndexPointSL ? indexSLPoints : atr * atrSLMult

buySL = not na(strongLow) ? strongLow - slBuffer : low - slBuffer
sellSL = not na(strongHigh) ? strongHigh + slBuffer : high + slBuffer

// ---------- Signal Logic ----------
rawBuySignal = showSignals and buyScore >= minBuyScore and buySignalContext and htfBuyOk and not sellSignalContext
rawSellSignal = showSignals and sellScore >= minSellScore and sellSignalContext and htfSellOk and not buySignalContext

buySignal = showOnlyFirstSignal ? rawBuySignal and not rawBuySignal[1] : rawBuySignal
sellSignal = showOnlyFirstSignal ? rawSellSignal and not rawSellSignal[1] : rawSellSignal

// ---------- Active Trade State ----------
var float activeEntry = na
var float activeSL = na
var string activeSide = 'None'
var int activeBaseIdx = na
var int activeTP1Idx = na
var int activeTP2Idx = na
var int activeTP3Idx = na
var int activeExtIdx = na

if buySignal
    activeSide := 'BUY'
    activeEntry := close
    activeBaseIdx := nearestPivotIndex
    activeTP1Idx := f_nextPivotIndex(activeSide, activeBaseIdx, 1)
    activeTP2Idx := f_nextPivotIndex(activeSide, activeBaseIdx, 2)
    activeTP3Idx := f_nextPivotIndex(activeSide, activeBaseIdx, 3)
    activeExtIdx := f_nextPivotIndex(activeSide, activeBaseIdx, 4)
    activeSL := buySL
    activeSL

if sellSignal
    activeSide := 'SELL'
    activeEntry := close
    activeBaseIdx := nearestPivotIndex
    activeTP1Idx := f_nextPivotIndex(activeSide, activeBaseIdx, 1)
    activeTP2Idx := f_nextPivotIndex(activeSide, activeBaseIdx, 2)
    activeTP3Idx := f_nextPivotIndex(activeSide, activeBaseIdx, 3)
    activeExtIdx := f_nextPivotIndex(activeSide, activeBaseIdx, 4)
    activeSL := sellSL
    activeSL

// ---------- Buy / Sell Labels ----------
buyLabelY = not na(strongLow) and nearStrongLowSignal ? strongLow : low - atr * 0.15
sellLabelY = not na(strongHigh) and nearStrongHighSignal ? strongHigh : high + atr * 0.15

if buySignal
    label.new(bar_index, buyLabelY, f_buyText(buyScore), style = label.style_label_up, color = color.new(buyLabelColorInput, 0), textcolor = buyLabelTextColorInput, size = signalSize)

if sellSignal
    label.new(bar_index, sellLabelY, f_sellText(sellScore), style = label.style_label_down, color = color.new(sellLabelColorInput, 0), textcolor = sellLabelTextColorInput, size = signalSize)

// =====================================================
// RIGHT-SIDE PIVOTAL LABELS WITH TP TAGS
// NO TP LINES FOLLOWING CHART
// =====================================================
var array<label> pivotLabels = array.new_label()

displaySide = activeSide != 'None' ? activeSide : buyScore >= sellScore ? 'BUY' : 'SELL'
displayBaseIdx = na(activeBaseIdx) ? nearestPivotIndex : activeBaseIdx
displayTP1Idx = f_nextPivotIndex(displaySide, displayBaseIdx, 1)
displayTP2Idx = f_nextPivotIndex(displaySide, displayBaseIdx, 2)
displayTP3Idx = f_nextPivotIndex(displaySide, displayBaseIdx, 3)
displayExtIdx = f_nextPivotIndex(displaySide, displayBaseIdx, 4)

rightOffset = lineExtensionInput == 'None' ? 1 : pivotLabelOffset

if barstate.islast
    if array.size(pivotLabels) > 0
        for i = 0 to array.size(pivotLabels) - 1 by 1
            label.delete(array.get(pivotLabels, i))
        array.clear(pivotLabels)

    if showPivotalZones and showCurrentLevels
        for i = 0 to 14 by 1
            nm = array.get(pivNames, i)
            lv = array.get(pivVals, i)
            clr = f_pivColor(i)

            tpTag = ''
            if showPivotTPtags
                tpTag := i == displayTP1Idx ? 'TP1 ' : i == displayTP2Idx ? 'TP2 ' : i == displayTP3Idx ? 'TP3 ' : i == displayExtIdx ? 'EXT ' : ''
                tpTag

            valueText = showLevelsValue ? ' -- ' + str.tostring(lv, format.mintick) : ''
            maText = tpTag != '' and showTPNearestMA ? ' | ' + f_nearestMAText(lv) : ''

            extra = i == 5 ? ' REV BUY' : i == 9 ? ' REV SELL' : i == 7 ? ' MID' : i <= 2 ? ' EXT OS' : i >= 12 ? ' EXT OB' : ''

            labText = tpTag + nm + valueText + maText + extra

            lab = label.new(bar_index + rightOffset, lv, labText, style = label.style_label_left, color = color.new(cBlack, 100), textcolor = clr, size = pivotLabelSize)
            array.push(pivotLabels, lab)

// ---------- Background Hints ----------
bgcolor(buyScore >= minBuyScore and buySignalContext ? color.new(buyLabelColorInput, 92) : na)
bgcolor(sellScore >= minSellScore and sellSignalContext ? color.new(sellLabelColorInput, 92) : na)

// ---------- Alerts ----------
alertcondition(buySignal, title = 'SMACK Buy Strong Low / Pivot Setup', message = 'SMACK Buy setup on {{ticker}} {{interval}}. Education only. Manage risk.')
alertcondition(sellSignal, title = 'SMACK Sell Strong High / Pivot Setup', message = 'SMACK Sell setup on {{ticker}} {{interval}}. Education only. Manage risk.')

// =====================================================
// DASHBOARD
// =====================================================
var table dash = table.new(position.top_right, 2, 20, border_width = 1)

if barstate.islast and showDashboard
    direction = buyScore > sellScore ? 'Bullish' : sellScore > buyScore ? 'Bearish' : 'Neutral'
    bestScore = math.max(buyScore, sellScore)
    status = bestScore < 40 ? 'NO TRADE' : bestScore < 60 ? 'WATCH' : bestScore < 70 ? 'SETUP FORMING' : bestScore < 90 ? 'STRONG SETUP' : 'ELITE SETUP'

    tp1Name = array.get(pivNames, displayTP1Idx)
    tp2Name = array.get(pivNames, displayTP2Idx)
    tp3Name = array.get(pivNames, displayTP3Idx)
    extName = array.get(pivNames, displayExtIdx)

    tp1Val = array.get(pivVals, displayTP1Idx)
    tp2Val = array.get(pivVals, displayTP2Idx)
    tp3Val = array.get(pivVals, displayTP3Idx)
    extVal = array.get(pivVals, displayExtIdx)

    table.cell(dash, 0, 0, 'SMACK ELITE', bgcolor = cBlack, text_color = cGold, text_size = dashSize)
    table.cell(dash, 1, 0, 'PRECISION S/R', bgcolor = cBlack, text_color = cGold, text_size = dashSize)

    table.cell(dash, 0, 1, 'Direction', bgcolor = cBlack, text_color = cWhite, text_size = dashSize)
    table.cell(dash, 1, 1, direction, bgcolor = direction == 'Bullish' ? color.new(buyLabelColorInput, 20) : direction == 'Bearish' ? color.new(sellLabelColorInput, 20) : color.new(cGray, 40), text_color = cWhite, text_size = dashSize)

    table.cell(dash, 0, 2, 'Buy Score', bgcolor = cBlack, text_color = cWhite, text_size = dashSize)
    table.cell(dash, 1, 2, str.tostring(buyScore) + '/100', bgcolor = buyScore >= minBuyScore ? cGold : color.new(cGray, 40), text_color = color.black, text_size = dashSize)

    table.cell(dash, 0, 3, 'Sell Score', bgcolor = cBlack, text_color = cWhite, text_size = dashSize)
    table.cell(dash, 1, 3, str.tostring(sellScore) + '/100', bgcolor = sellScore >= minSellScore ? cGold : color.new(cGray, 40), text_color = color.black, text_size = dashSize)

    table.cell(dash, 0, 4, 'Status', bgcolor = cBlack, text_color = cWhite, text_size = dashSize)
    table.cell(dash, 1, 4, status, bgcolor = bestScore >= 70 ? cGold : color.new(cGray, 40), text_color = color.black, text_size = dashSize)

    table.cell(dash, 0, 5, 'Prime Setup', bgcolor = cBlack, text_color = cWhite, text_size = dashSize)
    table.cell(dash, 1, 5, bullishSetup ? bullSetupLabelTextInput + ' Setup' : bearishSetup ? bearSetupLabelTextInput + ' Setup' : 'Waiting', bgcolor = color.new(cGray, 70), text_color = cWhite, text_size = dashSize)

    table.cell(dash, 0, 6, 'Pivot Zone', bgcolor = cBlack, text_color = cWhite, text_size = dashSize)
    table.cell(dash, 1, 6, array.get(pivNames, nearestPivotIndex), bgcolor = color.new(cGray, 70), text_color = cWhite, text_size = dashSize)

    table.cell(dash, 0, 7, 'Key Zone', bgcolor = cBlack, text_color = cWhite, text_size = dashSize)
    table.cell(dash, 1, 7, nearS2 ? 'S2 Buy Reversal' : nearR6 ? 'R6 Sell Reversal' : nearOversoldExtreme ? 'Oversold Ext' : nearOverboughtExtreme ? 'Overbought Ext' : 'Normal Range', bgcolor = color.new(cGray, 70), text_color = cWhite, text_size = dashSize)

    table.cell(dash, 0, 8, 'Auto S/R', bgcolor = cBlack, text_color = cWhite, text_size = dashSize)
    table.cell(dash, 1, 8, nearBlockSupport ? 'Support x' + str.tostring(strongestSupportStrength) : nearBlockResistance ? 'Resistance x' + str.tostring(strongestResistanceStrength) : 'Waiting', bgcolor = color.new(cGray, 70), text_color = cWhite, text_size = dashSize)

    table.cell(dash, 0, 9, 'MA Direction', bgcolor = cBlack, text_color = cWhite, text_size = dashSize)
    table.cell(dash, 1, 9, priceAboveAllMAs ? 'Above All MAs' : priceBelowAllMAs ? 'Below All MAs' : 'Mixed', bgcolor = color.new(cGray, 70), text_color = cWhite, text_size = dashSize)

    table.cell(dash, 0, 10, 'Stochastic', bgcolor = cBlack, text_color = cWhite, text_size = dashSize)
    table.cell(dash, 1, 10, stochBuy ? 'Bullish' : stochSell ? 'Bearish' : 'Neutral', bgcolor = color.new(cGray, 70), text_color = cWhite, text_size = dashSize)

    table.cell(dash, 0, 11, 'TSI', bgcolor = cBlack, text_color = cWhite, text_size = dashSize)
    table.cell(dash, 1, 11, tsiBull ? 'Bullish' : tsiBear ? 'Bearish' : 'Neutral', bgcolor = color.new(cGray, 70), text_color = cWhite, text_size = dashSize)

    table.cell(dash, 0, 12, 'RSI', bgcolor = cBlack, text_color = cWhite, text_size = dashSize)
    table.cell(dash, 1, 12, str.tostring(rsiValue, '#.0'), bgcolor = color.new(cGray, 70), text_color = cWhite, text_size = dashSize)

    table.cell(dash, 0, 13, 'Active Side', bgcolor = cBlack, text_color = cWhite, text_size = dashSize)
    table.cell(dash, 1, 13, activeSide, bgcolor = color.new(cGray, 70), text_color = cWhite, text_size = dashSize)

    table.cell(dash, 0, 14, 'Entry', bgcolor = cBlack, text_color = cGold, text_size = dashSize)
    table.cell(dash, 1, 14, not na(activeEntry) ? str.tostring(activeEntry, format.mintick) : 'Waiting', bgcolor = color.new(cGray, 70), text_color = cGold, text_size = dashSize)

    table.cell(dash, 0, 15, 'TP1 ' + tp1Name, bgcolor = cBlack, text_color = color.lime, text_size = dashSize)
    table.cell(dash, 1, 15, str.tostring(tp1Val, format.mintick), bgcolor = color.new(cGray, 70), text_color = color.lime, text_size = dashSize)

    table.cell(dash, 0, 16, 'TP1 MA Near', bgcolor = cBlack, text_color = color.lime, text_size = dashSize)
    table.cell(dash, 1, 16, f_nearestMAText(tp1Val), bgcolor = color.new(cGray, 70), text_color = color.lime, text_size = dashSize)

    table.cell(dash, 0, 17, 'TP2 ' + tp2Name, bgcolor = cBlack, text_color = color.lime, text_size = dashSize)
    table.cell(dash, 1, 17, str.tostring(tp2Val, format.mintick), bgcolor = color.new(cGray, 70), text_color = color.lime, text_size = dashSize)

    table.cell(dash, 0, 18, 'SL', bgcolor = cBlack, text_color = color.red, text_size = dashSize)
    table.cell(dash, 1, 18, not na(activeSL) ? str.tostring(activeSL, format.mintick) : 'Waiting', bgcolor = color.new(cGray, 70), text_color = color.red, text_size = dashSize)

    table.cell(dash, 0, 19, 'SL Mode', bgcolor = cBlack, text_color = cGold, text_size = dashSize)
    table.cell(dash, 1, 19, useIndexPointSL ? 'Index ' + str.tostring(indexSLPoints) + ' pts' : 'ATR x ' + str.tostring(atrSLMult), bgcolor = cBlack, text_color = cGold, text_size = dashSize)
````
