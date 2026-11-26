# SU-DRAGON

- url: https://www.tradingview.com/script/v0IR3Xk8/
- type: indicator
- pine_id: PUB;12907d00edae489f8bc36a4b38dd11ab
- version: 7.0

## Description

진이가 만든 챠트

## Source Code

````pine
//@version=6
indicator("su-dragon 10M Calibrated Forecast + Entry Triangles", shorttitle="su-dragon 10M Calibrated Forecast + Entry Triangles", overlay=true, max_labels_count=500, max_lines_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SU-DRAGON PHOTO SETTINGS
// 사진 상단 표시 순서:
// Full Predator 21 9 21 55 14 2.5 14 50 14 61.8 10 60 100 8 52 1 1.5 62 38 First Bar Only
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
mode          = input.string("Full Predator", "Mode", options=["Full Predator", "Fast Predator", "Safe Predator"], display=display.status_line)
mainLen       = input.int(21, "Main Length", minval=1, display=display.status_line)
fastLen       = input.int(9, "Fast Length", minval=1, display=display.status_line)
midLen        = input.int(21, "Mid Length", minval=1, display=display.status_line)
slowLen       = input.int(55, "Slow Length", minval=1, display=display.status_line)
atrLen        = input.int(14, "ATR Length", minval=1, display=display.status_line)
atrMult       = input.float(2.5, "ATR Mult", minval=0.1, step=0.1, display=display.status_line)
rsiLen        = input.int(14, "RSI Length", minval=1, display=display.status_line)
rsiMid        = input.int(50, "RSI Mid", minval=1, maxval=99, display=display.status_line)
adxLen        = input.int(14, "ADX Length", minval=1, display=display.status_line)
fibRatio      = input.float(61.8, "Fib Ratio", minval=1, step=0.1, display=display.status_line)
forecastMin   = input.int(10, "Forecast Minutes", minval=1, maxval=240, display=display.status_line)
scoreNeed     = input.int(60, "Entry Score Need", minval=1, maxval=100, display=display.status_line)
volLen        = input.int(100, "Volume Length", minval=1, display=display.status_line)
chopLen       = input.int(8, "Chop Length", minval=1, display=display.status_line)
learnLen      = input.int(52, "Learning Window", minval=5, display=display.status_line)
minTickFilter = input.int(1, "Min Tick Filter", minval=1, display=display.status_line)
targetMult    = input.float(1.5, "Target Mult", minval=0.1, step=0.1, display=display.status_line)
bullRsi       = input.int(62, "Bull RSI", minval=1, maxval=99, display=display.status_line)
bearRsi       = input.int(38, "Bear RSI", minval=1, maxval=99, display=display.status_line)
entryMode     = input.string("First Bar Only", "Entry Mode", options=["First Bar Only", "Every Signal"], display=display.status_line)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HIDDEN STYLE OPTIONS
// 상태줄에는 사진처럼 설정값만 보이게 숨김
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showDragonLine = input.bool(true, "Show Dragon Line", group="Style", display=display.none)
showEmaLine    = input.bool(true, "Show EMA Lines", group="Style", display=display.none)
showTriangles  = input.bool(true, "Show BUY/SELL Triangles", group="Style", display=display.none)
showYellowDots = input.bool(true, "Show Yellow Dots", group="Style", display=display.none)
showDash       = input.bool(true, "Show Right Dashboard", group="Style", display=display.none)
showBox        = input.bool(true, "Show Forecast Box", group="Style", display=display.none)
accuracyOn     = input.bool(true, "Accuracy Calibration", group="Style", display=display.none)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_clamp(x, lo, hi) =>
    math.min(math.max(x, lo), hi)

f_price(x) =>
    na(x) ? "n/a" : str.tostring(x, format.mintick)

f_signed_price(x) =>
    na(x) ? "n/a" : (x >= 0 ? "+" : "") + str.tostring(x, format.mintick)

f_pct(x) =>
    na(x) ? "n/a" : str.tostring(x, "#.##") + "%"

f_signed_pct(x) =>
    na(x) ? "n/a" : (x >= 0 ? "+" : "") + str.tostring(x, "#.##") + "%"

f_bars_from_minutes(_minutes) =>
    tfSec = timeframe.in_seconds(timeframe.period)
    tfMin = na(tfSec) or tfSec <= 0 ? 1.0 : tfSec / 60.0
    raw = int(math.round(_minutes / tfMin))
    math.max(1, math.min(500, raw))

f_cell(_table, _col, _row, _text, _bg) =>
    table.cell(_table, _col, _row, _text, text_color=color.white, bgcolor=_bg, text_size=size.normal)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BASIC CALCULATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
src = close

emaMain = ta.ema(src, mainLen)
emaFast = ta.ema(src, fastLen)
emaMid  = ta.ema(src, midLen)
emaSlow = ta.ema(src, slowLen)

atr = ta.atr(atrLen)
rsi = ta.rsi(src, rsiLen)

[plusDI, minusDI, adx] = ta.dmi(adxLen, adxLen)

volAvg = ta.sma(volume, volLen)

barsAhead = f_bars_from_minutes(forecastMin)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRAGON STEP LINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
basicUpper = hl2 + atr * atrMult
basicLower = hl2 - atr * atrMult

var float finalUpper = na
var float finalLower = na

finalUpper := na(finalUpper[1]) ? basicUpper : basicUpper < finalUpper[1] or close[1] > finalUpper[1] ? basicUpper : finalUpper[1]
finalLower := na(finalLower[1]) ? basicLower : basicLower > finalLower[1] or close[1] < finalLower[1] ? basicLower : finalLower[1]

var int dragonTrend = 1

dragonTrend := close > nz(finalUpper[1], basicUpper) ? 1 : close < nz(finalLower[1], basicLower) ? -1 : nz(dragonTrend[1], 1)

dragonLine = dragonTrend == 1 ? finalLower : finalUpper


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SCORE / BIAS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
regLine = ta.linreg(src, learnLen, 0)
slope = regLine - regLine[1]

trendVote = dragonTrend == 1 ? 20 : -20
emaVote   = emaMain >= emaSlow ? 20 : -20
fastVote  = emaFast >= emaMid ? 10 : -10
slopeVote = nz(slope, 0) >= 0 ? 15 : -15
dmiVote   = plusDI >= minusDI ? 10 : -10

rsiVote = rsi >= bullRsi ? 15 : rsi <= bearRsi ? -15 : rsi >= rsiMid ? 8 : -8

volVote = na(volAvg) ? 0 : volume > volAvg ? close >= open ? 5 : -5 : 0

rawBias = trendVote + emaVote + fastVote + slopeVote + dmiVote + rsiVote + volVote

biasVal = int(math.round(f_clamp(rawBias, -100, 100)))
score = int(math.round(f_clamp(50 + math.abs(biasVal) / 2.0, 0, 100)))

forecastDir = biasVal >= 0 ? 1 : -1

sideText = forecastDir == 1 ? "UP" : "DOWN"
biasText = biasVal >= 0 ? "Bull +" + str.tostring(biasVal) : "Bear " + str.tostring(biasVal)
marketText = math.abs(biasVal) < 20 ? "Neutral" : forecastDir == 1 ? "Bullish" : "Bearish"


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CHOP FILTER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
rangeNow = ta.highest(high, chopLen) - ta.lowest(low, chopLen)

isChop = adx < 18 or rangeNow < atr * 1.2 or math.abs(emaMain - emaSlow) < atr * 0.15

chopText = isChop ? "YES" : "NO"


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LEARNING ACCURACY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
oldDir = forecastDir[barsAhead]
oldClose = close[barsAhead]

validOld = not na(oldClose)

tickFilter = syminfo.mintick * minTickFilter

upCase = validOld and nz(oldDir, 0) == 1
downCase = validOld and nz(oldDir, 0) == -1

upHit = upCase and close > oldClose + tickFilter
downHit = downCase and close < oldClose - tickFilter

upCnt = ta.sma(upCase ? 1.0 : 0.0, learnLen) * learnLen
downCnt = ta.sma(downCase ? 1.0 : 0.0, learnLen) * learnLen

upHitCnt = ta.sma(upHit ? 1.0 : 0.0, learnLen) * learnLen
downHitCnt = ta.sma(downHit ? 1.0 : 0.0, learnLen) * learnLen

upAcc = upCnt > 0 ? upHitCnt / upCnt * 100.0 : na
downAcc = downCnt > 0 ? downHitCnt / downCnt * 100.0 : na

dirAcc = forecastDir == 1 ? upAcc : downAcc

accFactor = accuracyOn and not na(dirAcc) ? f_clamp(dirAcc / 50.0, 0.65, 1.35) : 1.0


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 10M CALIBRATED FORECAST
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
modeBoost = mode == "Fast Predator" ? 1.15 : mode == "Safe Predator" ? 0.85 : 1.0
fibBoost = fibRatio / 61.8

slopeMove = math.abs(nz(slope, 0) * barsAhead)
atrMove = atr * targetMult * score / 100.0

baseMove = slopeMove + atrMove
mainMove = math.max(tickFilter, baseMove * accFactor * modeBoost * fibBoost)

minorMove = mainMove * 0.20

predPrice = forecastDir == 1 ? close + mainMove : close - mainMove

upTarget = forecastDir == 1 ? predPrice : close + minorMove
downTarget = forecastDir == 1 ? close - minorMove : predPrice

expectedMove = predPrice - close
expectedRate = expectedMove / close * 100.0

upTargetRate = (upTarget - close) / close * 100.0
downTargetRate = (downTarget - close) / close * 100.0


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ENTRY SIGNAL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
scoreOk = score >= scoreNeed

bullSetup = forecastDir == 1 and dragonTrend == 1 and emaFast > emaMid and close > emaMain and scoreOk and not isChop
bearSetup = forecastDir == -1 and dragonTrend == -1 and emaFast < emaMid and close < emaMain and scoreOk and not isChop

buySignal = entryMode == "First Bar Only" ? bullSetup and not (bullSetup[1] == true) : bullSetup
sellSignal = entryMode == "First Bar Only" ? bearSetup and not (bearSetup[1] == true) : bearSetup

entryText = buySignal ? "BUY" : sellSignal ? "SELL" : "NO ENTRY"


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// YELLOW DOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
yellowDotUp = ta.crossover(emaFast, emaMain)
yellowDotDown = ta.crossunder(emaFast, emaMain)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PLOTS - LINES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(showEmaLine ? emaMain : na, "Dragon EMA 21", color=color.new(color.teal, 0), linewidth=2)
plot(showEmaLine ? emaFast : na, "Fast EMA 9", color=color.new(color.orange, 0), linewidth=1)

plot(showDragonLine and dragonTrend == 1 ? dragonLine : na, "Dragon UP Step", color=color.new(color.lime, 0), linewidth=3, style=plot.style_stepline)
plot(showDragonLine and dragonTrend == -1 ? dragonLine : na, "Dragon DOWN Step", color=color.new(color.red, 0), linewidth=3, style=plot.style_stepline)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PLOTS - TRIANGLES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plotshape(showTriangles and buySignal, title="BUY", text="BUY", style=shape.triangleup, location=location.belowbar, size=size.huge, color=color.new(color.lime, 0), textcolor=color.white)
plotshape(showTriangles and sellSignal, title="SELL", text="SELL", style=shape.triangledown, location=location.abovebar, size=size.huge, color=color.new(color.red, 0), textcolor=color.white)

plotshape(showYellowDots and yellowDotUp, title="Yellow Dot UP", style=shape.circle, location=location.belowbar, size=size.small, color=color.new(color.yellow, 0))
plotshape(showYellowDots and yellowDotDown, title="Yellow Dot DOWN", style=shape.circle, location=location.abovebar, size=size.small, color=color.new(color.yellow, 0))


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FORECAST BOX
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var label forecastLabel = na
var line forecastLine = na
var line upLine = na
var line downLine = na

forecastColor = forecastDir == 1 ? color.rgb(0, 210, 110) : color.rgb(245, 55, 70)

forecastText = sideText + " " + str.tostring(forecastMin) + "M\n" +
     str.tostring(forecastMin) + "분 예상가: " + f_price(predPrice) + "\n" +
     "상승목표: " + f_price(upTarget) + "\n" +
     "하락목표: " + f_price(downTarget) + "\n" +
     "UP 학습: " + f_pct(upAcc) + " / " + str.tostring(int(nz(upCnt, 0))) + "\n" +
     "DOWN 학습: " + f_pct(downAcc) + " / " + str.tostring(int(nz(downCnt, 0)))

if barstate.islast
    if not na(forecastLabel)
        label.delete(forecastLabel)
    if not na(forecastLine)
        line.delete(forecastLine)
    if not na(upLine)
        line.delete(upLine)
    if not na(downLine)
        line.delete(downLine)

    if showBox
        forecastLine := line.new(bar_index, close, bar_index + barsAhead, predPrice, color=forecastColor, width=2, style=line.style_dotted)
        upLine := line.new(bar_index, upTarget, bar_index + barsAhead, upTarget, color=color.new(color.lime, 0), width=1, style=line.style_dotted)
        downLine := line.new(bar_index, downTarget, bar_index + barsAhead, downTarget, color=color.new(color.red, 0), width=1, style=line.style_dotted)

        forecastLabel := label.new(
             x=bar_index + barsAhead,
             y=predPrice,
             text=forecastText,
             style=label.style_label_left,
             color=forecastColor,
             textcolor=color.white,
             size=size.small
        )


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RIGHT DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table dash = table.new(position.top_right, 2, 14, border_width=1, frame_width=1)

bodyBg = color.rgb(42, 45, 55)
leftBg = color.rgb(35, 38, 48)
headBg = forecastDir == 1 ? color.rgb(0, 210, 110) : color.rgb(245, 55, 70)

if barstate.islast and showDash
    f_cell(dash, 0, 0, str.tostring(forecastMin) + "M Forecast", headBg)
    f_cell(dash, 1, 0, sideText + " " + str.tostring(forecastMin) + "M", headBg)

    f_cell(dash, 0, 1, "Score", leftBg)
    f_cell(dash, 1, 1, str.tostring(score), bodyBg)

    f_cell(dash, 0, 2, "예상가", leftBg)
    f_cell(dash, 1, 2, f_price(predPrice), bodyBg)

    f_cell(dash, 0, 3, "상승목표", leftBg)
    f_cell(dash, 1, 3, f_price(upTarget) + " / " + f_signed_pct(upTargetRate), bodyBg)

    f_cell(dash, 0, 4, "하락목표", leftBg)
    f_cell(dash, 1, 4, f_price(downTarget) + " / " + f_signed_pct(downTargetRate), bodyBg)

    f_cell(dash, 0, 5, "예상폭", leftBg)
    f_cell(dash, 1, 5, f_signed_price(expectedMove), bodyBg)

    f_cell(dash, 0, 6, "예상률", leftBg)
    f_cell(dash, 1, 6, f_signed_pct(expectedRate), bodyBg)

    f_cell(dash, 0, 7, "UP 학습", leftBg)
    f_cell(dash, 1, 7, f_pct(upAcc) + " / " + str.tostring(int(nz(upCnt, 0))), bodyBg)

    f_cell(dash, 0, 8, "DOWN 학습", leftBg)
    f_cell(dash, 1, 8, f_pct(downAcc) + " / " + str.tostring(int(nz(downCnt, 0))), bodyBg)

    f_cell(dash, 0, 9, "Bias", leftBg)
    f_cell(dash, 1, 9, biasText, bodyBg)

    f_cell(dash, 0, 10, "Market", leftBg)
    f_cell(dash, 1, 10, marketText, bodyBg)

    f_cell(dash, 0, 11, "Chop", leftBg)
    f_cell(dash, 1, 11, chopText, bodyBg)

    f_cell(dash, 0, 12, "Accuracy", leftBg)
    f_cell(dash, 1, 12, accuracyOn ? "ON" : "OFF", bodyBg)

    f_cell(dash, 0, 13, "Entry", leftBg)
    f_cell(dash, 1, 13, entryText, bodyBg)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(buySignal, title="SU-DRAGON BUY", message="SU-DRAGON BUY")
alertcondition(sellSignal, title="SU-DRAGON SELL", message="SU-DRAGON SELL")
````
