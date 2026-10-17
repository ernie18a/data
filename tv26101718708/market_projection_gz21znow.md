# Market Projection  

- url: https://www.tradingview.com/script/GZ21ZNOw/
- type: indicator
- pine_id: PUB;f29f69d763374238b15518499aee0d9e
- version: 1.0

## Description

Market Projection Engine is a visual projection tool designed to map potential future price paths using trend structure, volatility, and price displacement.

The indicator combines three projection phases:

• AB (Reaction Zone) — Initial response and stabilization area after a strong displacement.
• BC (Path Zone) — Primary projected route based on current trend pressure and directional slope.
• CD (Target Zone) — Extended objective area where projected movement may begin to lose momentum.

The model also includes:

• Ghost Candles to visualize a potential path rather than a single projected line.
• Stretch Clouds to highlight areas where price has moved significantly away from its center of gravity.
• Probability Corridors to display a wider range of possible price development rather than a fixed forecast.
• Trend Quality Score to estimate the strength of the current projection environment.

This indicator is intended as a visual market structure and projection tool. It does not predict future prices and should not be used as a standalone trading system.

Users should always combine its output with their own analysis, risk management, and market context.

━━━━━━━━━━━━━━━━━━━

⚠ Disclaimer

This script is provided for educational and informational purposes only.

The projections displayed by this indicator represent possible market paths derived from historical price behavior and volatility measurements. They are not forecasts, predictions, or guarantees of future performance.

Trading and investing involve risk. Past market behavior does not guarantee future results.

Always perform independent analysis and use appropriate risk management before making trading decisions.

## Source Code

````pine
//@version=6
indicator("Mirror Flux Ghost Candles V4.1 • Probability Corridor", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=100)
 
//━━━━━━━━ INPUTS
lang       = input.string("EN", "Language / Dil", options=["EN", "TR"])
trendLen   = input.int(200, "Main Trend EMA", minval=20)
centerLen  = input.int(34, "Center EMA", minval=5)
atrLen     = input.int(14, "ATR Length", minval=1)
projLen    = input.int(28, "Ghost Candle Count", minval=8, maxval=50)

extremeATR = input.float(1.5, "Stretch Start ATR", step=0.1)
slopePower = input.float(1.0, "Projection Power", step=0.1)
corr70     = input.float(0.70, "70% Corridor ATR", step=0.05)
corr90     = input.float(1.20, "90% Corridor ATR", step=0.05)

showGhost  = input.bool(true, "Show Ghost Candles")
showCloud  = input.bool(true, "Stretch Cloud")
showCorr   = input.bool(true, "Probability Corridor")
showPanel  = input.bool(true, "Show Panel")

//━━━━━━━━ LANGUAGE
t_dir   = lang == "TR" ? "Yön" : "Direction"
t_score = lang == "TR" ? "Skor" : "Score"
t_qual  = lang == "TR" ? "Kalite" : "Quality"
t_dev   = lang == "TR" ? "Sapma" : "Stretch"
t_ab    = lang == "TR" ? "AB\nTEPKİ" : "AB\nREACTION"
t_bc    = lang == "TR" ? "BC\nROTA" : "BC\nPATH"
t_cd    = lang == "TR" ? "CD\nHEDEF" : "CD\nTARGET"

t_vstrong = lang == "TR" ? "ÇOK GÜÇLÜ" : "VERY STRONG"
t_strong  = lang == "TR" ? "GÜÇLÜ" : "STRONG"
t_mid     = lang == "TR" ? "ORTA" : "MEDIUM"
t_weak    = lang == "TR" ? "ZAYIF" : "WEAK"

//━━━━━━━━ CORE
emaBase = ta.ema(close, trendLen)
center  = ta.ema(close, centerLen)
atr     = ta.atr(atrLen)

mirror = emaBase * 2.0 - close
norm = atr != 0.0 ? (close - center) / atr : 0.0
isExtreme = math.abs(norm) >= extremeATR

trendSlope  = emaBase - emaBase[1]
centerSlope = center - center[1]

bullPressure = close > center and center > emaBase
bearPressure = close < center and center < emaBase

direction = bullPressure ? 1 : bearPressure ? -1 : centerSlope >= 0 ? 1 : -1
ghostSlope = (centerSlope + trendSlope * 0.50) * slopePower

bullCol = color.rgb(0, 220, 120)
bearCol = color.rgb(255, 70, 70)
blueCol = color.rgb(60, 160, 255)
mainCol = direction == 1 ? bullCol : bearCol

plot(center, "Center Line", color=color.black, linewidth=2)
plot(emaBase, "Main Trend EMA", color=color.new(color.gray, 55), linewidth=1)
plot(mirror, "Mirror Line", color=color.new(mainCol, 82), linewidth=1)

//━━━━━━━━ SCORE
slopeScore = atr != 0.0 ? math.min(40.0, math.abs(ghostSlope) / atr * 400.0) : 0.0
trendScore = bullPressure or bearPressure ? 30.0 : 15.0
extremeScore = isExtreme ? 10.0 : 20.0
volScore = atr > ta.sma(atr, 20) ? 10.0 : 5.0
score = math.round(math.min(slopeScore + trendScore + extremeScore + volScore, 100.0))
scoreText = score >= 85 ? t_vstrong : score >= 70 ? t_strong : score >= 55 ? t_mid : t_weak
scoreCol = score >= 85 ? mainCol : score >= 70 ? blueCol : score >= 55 ? color.orange : color.gray

//━━━━━━━━ STORAGE
var line[] lineArr = array.new_line()
var box[] boxArr = array.new_box()
var label[] labelArr = array.new_label()

f_clear() =>
    if array.size(lineArr) > 0
        for i = 0 to array.size(lineArr) - 1
            line.delete(array.get(lineArr, i))
        array.clear(lineArr)
    if array.size(boxArr) > 0
        for i = 0 to array.size(boxArr) - 1
            box.delete(array.get(boxArr, i))
        array.clear(boxArr)
    if array.size(labelArr) > 0
        for i = 0 to array.size(labelArr) - 1
            label.delete(array.get(labelArr, i))
        array.clear(labelArr)

//━━━━━━━━ DRAW
if barstate.islast
    f_clear()

    // Stretch cloud
    if showCloud and isExtreme
        stretch = math.min(3.0, math.abs(norm))
        cloudTrans = int(math.max(68, 94 - stretch * 8))
        stretchBaseCol = norm > 0 ? color.red : color.lime
        cloudTop = norm > 0 ? high + atr * 0.55 : center + atr * 0.35
        cloudBot = norm > 0 ? center - atr * 0.35 : low - atr * 0.55

        sc1 = box.new(bar_index - 9, cloudTop, bar_index + 7, cloudBot, xloc=xloc.bar_index, bgcolor=color.new(stretchBaseCol, cloudTrans), border_color=color.new(stretchBaseCol, 100))
        sc2 = box.new(bar_index - 5, cloudTop - atr * 0.25, bar_index + 4, cloudBot + atr * 0.25, xloc=xloc.bar_index, bgcolor=color.new(stretchBaseCol, cloudTrans - 6), border_color=color.new(stretchBaseCol, 100))
        array.push(boxArr, sc1)
        array.push(boxArr, sc2)

    abEnd = int(math.round(projLen * 0.25))
    bcEnd = int(math.round(projLen * 0.70))

    // Probability corridor band
    if showCorr
        for i = 1 to projLen
            wave = math.sin(i * 1.35) * atr * 0.10
            mid = center + ghostSlope * i + wave
            widen = atr * (0.25 + i / projLen * 0.65)

            u90 = mid + atr * corr90 + widen * 0.70
            l90 = mid - atr * corr90 - widen * 0.70
            u70 = mid + atr * corr70 + widen * 0.35
            l70 = mid - atr * corr70 - widen * 0.35

            x1 = bar_index + i - 1
            x2 = bar_index + i

            outerBox = box.new(x1, u90, x2, l90, xloc=xloc.bar_index, bgcolor=color.new(mainCol, 96), border_color=color.new(mainCol, 100))
            innerBox = box.new(x1, u70, x2, l70, xloc=xloc.bar_index, bgcolor=color.new(mainCol, 92), border_color=color.new(mainCol, 100))
            array.push(boxArr, outerBox)
            array.push(boxArr, innerBox)

    // Ghost candles
    if showGhost
        prevClose = close

        for i = 1 to projLen
            isAB = i <= abEnd
            isBC = i > abEnd and i <= bcEnd
            isCD = i > bcEnd

            wave = math.sin(i * 1.35) * atr * 0.12
            pull = math.sin(i * 2.10) * atr * 0.07

            moveFactor = isAB ? i * 0.25 : isBC ? i * 0.85 : bcEnd * 0.85
            ghostClose = center + ghostSlope * moveFactor + wave + pull

            if isCD
                targetBase = center + ghostSlope * bcEnd * 0.90
                ghostClose := targetBase + math.sin(i * 1.60) * atr * 0.18

            ghostOpen = prevClose
            bodyTop = math.max(ghostOpen, ghostClose)
            bodyBot = math.min(ghostOpen, ghostClose)
            wickTop = bodyTop + atr * (0.12 + math.abs(math.sin(i)) * 0.10)
            wickBot = bodyBot - atr * (0.12 + math.abs(math.cos(i)) * 0.10)

            x = bar_index + i
            fade = math.min(88, 34 + i)

            gCol = ghostClose >= ghostOpen ? color.new(bullCol, fade) : color.new(bearCol, fade)
            bCol = ghostClose >= ghostOpen ? color.new(bullCol, fade + 5) : color.new(bearCol, fade + 5)

            wk = line.new(x, wickTop, x, wickBot, xloc=xloc.bar_index, color=gCol, width=1)
            bd = box.new(x - 1, bodyTop, x, bodyBot, xloc=xloc.bar_index, bgcolor=bCol, border_color=gCol)

            array.push(lineArr, wk)
            array.push(boxArr, bd)
            prevClose := ghostClose

    // Labels inside corridor
    abY = center + ghostSlope * abEnd * 0.25
    bcY = center + ghostSlope * bcEnd * 0.55
    cdY = center + ghostSlope * bcEnd * 0.90

    abLab = label.new(bar_index + int(abEnd * 0.50), abY, t_ab, xloc=xloc.bar_index, style=label.style_label_center, color=color.new(color.black, 80), textcolor=color.white, size=size.tiny)
    bcLab = label.new(bar_index + int((abEnd + bcEnd) * 0.50), bcY, t_bc, xloc=xloc.bar_index, style=label.style_label_center, color=color.new(mainCol, 72), textcolor=color.white, size=size.tiny)
    cdLab = label.new(bar_index + int((bcEnd + projLen) * 0.50), cdY, t_cd, xloc=xloc.bar_index, style=label.style_label_center, color=color.new(mainCol, 60), textcolor=color.white, size=size.tiny)

    array.push(labelArr, abLab)
    array.push(labelArr, bcLab)
    array.push(labelArr, cdLab)

//━━━━━━━━ PANEL
var table panel = table.new(position.top_right, 2, 5, border_width=1)

if barstate.islast and showPanel
    table.cell(panel, 0, 0, "Mirror Flux", text_color=color.white, bgcolor=color.black)
    table.cell(panel, 1, 0, "V4.1", text_color=color.white, bgcolor=color.black)
    table.cell(panel, 0, 1, t_dir, text_color=color.white, bgcolor=color.black)
    table.cell(panel, 1, 1, direction == 1 ? "BULL" : "BEAR", text_color=color.white, bgcolor=mainCol)
    table.cell(panel, 0, 2, t_score, text_color=color.white, bgcolor=color.black)
    table.cell(panel, 1, 2, str.tostring(score) + " / 100", text_color=color.white, bgcolor=scoreCol)
    table.cell(panel, 0, 3, t_qual, text_color=color.white, bgcolor=color.black)
    table.cell(panel, 1, 3, scoreText, text_color=color.white, bgcolor=color.new(scoreCol, 10))
    table.cell(panel, 0, 4, t_dev, text_color=color.white, bgcolor=color.black)
    table.cell(panel, 1, 4, str.tostring(norm, "#.##") + " ATR", text_color=color.white, bgcolor=isExtreme ? color.orange : color.gray)

alertcondition(score >= 85 and direction == 1, "Mirror Flux V4.1 Strong Bull", "Strong bullish ghost candle projection.")
alertcondition(score >= 85 and direction == -1, "Mirror Flux V4.1 Strong Bear", "Strong bearish ghost candle projection.")
alertcondition(isExtreme, "Mirror Flux V4.1 Stretch Cloud", "Price entered strong ATR stretch zone.")
````
