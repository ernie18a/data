# TW MNQ Intraday Range Assistant Pro

- url: https://www.tradingview.com/script/zGsxpVzg/
- type: indicator
- pine_id: PUB;bd63ed095e5d4818a680bdb6629529d3
- version: 1.0

## Description

完成率 70% 以上：今天波動已經偏充分
完成率 90% 以上 + 目前位置 80% 以上：追多風險高
完成率 90% 以上 + 目前位置 20% 以下：追空風險高
價格在 VWAP 上方 + 靠近高點：偏多
價格在 VWAP 下方 + 靠近低點：偏空
完成率低 + 靠近日內中線：比較像均值回歸盤

## Source Code

````pine
//@version=6
indicator("MNQ Intraday Range Assistant Pro", overlay=true)

sym = input.symbol("CME_MINI:MNQ1!", "Symbol")
adrLen = input.int(20, "ADR Length", minval=1)

todayHigh = request.security(sym, "D", high)
todayLow = request.security(sym, "D", low)
todayRange = todayHigh - todayLow
todayMid = (todayHigh + todayLow) / 2
adr20 = request.security(sym, "D", ta.sma(high - low, adrLen))

remaining = adr20 - todayRange
remainingFixed = remaining > 0 ? remaining : 0
completion = adr20 > 0 ? todayRange / adr20 * 100 : na

currentPrice = close
vwapValue = ta.vwap(hlc3)
positionPct = todayRange > 0 ? (currentPrice - todayLow) / todayRange * 100 : 50

upperSpaceLine = todayHigh + remainingFixed
lowerSpaceLine = todayLow - remainingFixed

level400 = todayLow + 400
level600 = todayLow + 600
level800 = todayLow + 800

hit400 = todayRange >= 400
hit600 = todayRange >= 600
hit800 = todayRange >= 800

aboveVWAP = currentPrice > vwapValue
belowVWAP = currentPrice < vwapValue

bias = "中性"
if aboveVWAP and positionPct >= 60
    bias := "偏多"
else if belowVWAP and positionPct <= 40
    bias := "偏空"

dayType = "混合盤"
if completion >= 70 and positionPct >= 75 and aboveVWAP
    dayType := "多方趨勢"
else if completion >= 70 and positionPct <= 25 and belowVWAP
    dayType := "空方趨勢"
else if completion < 60 and positionPct > 35 and positionPct < 65
    dayType := "均值回歸"

longRisk = "低"
if completion >= 90 and positionPct >= 80
    longRisk := "高"
else if completion >= 70 and positionPct >= 70
    longRisk := "中"

shortRisk = "低"
if completion >= 90 and positionPct <= 20
    shortRisk := "高"
else if completion >= 70 and positionPct <= 30
    shortRisk := "中"

progressText = "----------"
if completion >= 100
    progressText := "##########"
else if completion >= 90
    progressText := "#########-"
else if completion >= 80
    progressText := "########--"
else if completion >= 70
    progressText := "#######---"
else if completion >= 60
    progressText := "######----"
else if completion >= 50
    progressText := "#####-----"
else if completion >= 40
    progressText := "####------"
else if completion >= 30
    progressText := "###-------"
else if completion >= 20
    progressText := "##--------"
else if completion >= 10
    progressText := "#---------"

plot(todayHigh, title="今日高點", color=color.rgb(230, 70, 80), linewidth=1)
plot(todayLow, title="今日低點", color=color.rgb(60, 180, 110), linewidth=1)
plot(todayMid, title="今日中線", color=color.rgb(240, 220, 80), linewidth=2)
plot(vwapValue, title="VWAP", color=color.white, linewidth=2)

plot(upperSpaceLine, title="上方剩餘空間", color=color.rgb(255, 80, 90), linewidth=2)
plot(lowerSpaceLine, title="下方剩餘空間", color=color.rgb(60, 190, 100), linewidth=2)

plot(level400, title="400點線", color=hit400 ? color.rgb(40, 190, 110) : color.rgb(90, 90, 90), linewidth=1)
plot(level600, title="600點線", color=hit600 ? color.rgb(220, 160, 40) : color.rgb(90, 90, 90), linewidth=1)
plot(level800, title="800點線", color=hit800 ? color.rgb(230, 70, 80) : color.rgb(90, 90, 90), linewidth=1)

bgHeader = color.rgb(18, 24, 31)
bgSection = color.rgb(36, 47, 58)
bgLabel = color.rgb(28, 36, 44)
bgValue = color.rgb(12, 16, 20)
bgMuted = color.rgb(65, 70, 76)
bgGreen = color.rgb(35, 140, 90)
bgYellow = color.rgb(190, 135, 28)
bgRed = color.rgb(185, 55, 60)
bgBlue = color.rgb(45, 100, 165)

completionBg = bgGreen
if completion >= 100
    completionBg := bgRed
else if completion >= 70
    completionBg := bgYellow

biasBg = bgMuted
if bias == "偏多"
    biasBg := bgGreen
else if bias == "偏空"
    biasBg := bgRed

typeBg = bgMuted
if dayType == "多方趨勢"
    typeBg := bgGreen
else if dayType == "空方趨勢"
    typeBg := bgRed
else if dayType == "均值回歸"
    typeBg := bgBlue

longRiskBg = longRisk == "高" ? bgRed : longRisk == "中" ? bgYellow : bgGreen
shortRiskBg = shortRisk == "高" ? bgRed : shortRisk == "中" ? bgYellow : bgGreen

var table t = table.new(position.top_right, 3, 15, border_width=1, frame_color=color.rgb(70, 80, 90), border_color=color.rgb(55, 65, 75))

if barstate.islast
    table.cell(t, 0, 0, "MNQ", bgcolor=bgHeader, text_color=color.white, text_size=size.normal)
    table.cell(t, 1, 0, "日內波動助手", bgcolor=bgHeader, text_color=color.white, text_size=size.normal)
    table.cell(t, 2, 0, "PRO", bgcolor=bgHeader, text_color=color.rgb(130, 210, 255), text_size=size.normal)

    table.cell(t, 0, 1, "目前已走", bgcolor=bgSection, text_color=color.white)
    table.cell(t, 1, 1, str.tostring(todayRange, "#.0"), bgcolor=bgSection, text_color=color.white, text_size=size.large)
    table.cell(t, 2, 1, "點", bgcolor=bgSection, text_color=color.white)

    table.cell(t, 0, 2, "ADR20", bgcolor=bgLabel, text_color=color.rgb(200, 210, 220))
    table.cell(t, 1, 2, str.tostring(adr20, "#.0"), bgcolor=bgValue, text_color=color.white)
    table.cell(t, 2, 2, "點", bgcolor=bgValue, text_color=color.white)

    table.cell(t, 0, 3, "完成率", bgcolor=bgLabel, text_color=color.rgb(200, 210, 220))
    table.cell(t, 1, 3, str.tostring(completion, "#.0") + "%", bgcolor=completionBg, text_color=color.white, text_size=size.large)
    table.cell(t, 2, 3, progressText, bgcolor=completionBg, text_color=color.white)

    table.cell(t, 0, 4, "剩餘", bgcolor=bgLabel, text_color=color.rgb(200, 210, 220))
    table.cell(t, 1, 4, str.tostring(remainingFixed, "#.0"), bgcolor=bgValue, text_color=color.white)
    table.cell(t, 2, 4, "點", bgcolor=bgValue, text_color=color.white)

    table.cell(t, 0, 5, "市場狀態", bgcolor=bgSection, text_color=color.white)
    table.cell(t, 1, 5, dayType, bgcolor=typeBg, text_color=color.white)
    table.cell(t, 2, 5, bias, bgcolor=biasBg, text_color=color.white)

    table.cell(t, 0, 6, "日內位置", bgcolor=bgLabel, text_color=color.rgb(200, 210, 220))
    table.cell(t, 1, 6, str.tostring(positionPct, "#.0") + "%", bgcolor=bgValue, text_color=color.white)
    table.cell(t, 2, 6, aboveVWAP ? "VWAP上" : belowVWAP ? "VWAP下" : "VWAP", bgcolor=aboveVWAP ? bgGreen : belowVWAP ? bgRed : bgMuted, text_color=color.white)

    table.cell(t, 0, 7, "追多風險", bgcolor=bgLabel, text_color=color.rgb(200, 210, 220))
    table.cell(t, 1, 7, longRisk, bgcolor=longRiskBg, text_color=color.white)
    table.cell(t, 2, 7, "", bgcolor=longRiskBg)

    table.cell(t, 0, 8, "追空風險", bgcolor=bgLabel, text_color=color.rgb(200, 210, 220))
    table.cell(t, 1, 8, shortRisk, bgcolor=shortRiskBg, text_color=color.white)
    table.cell(t, 2, 8, "", bgcolor=shortRiskBg)

    table.cell(t, 0, 9, "400點", bgcolor=bgLabel, text_color=color.rgb(200, 210, 220))
    table.cell(t, 1, 9, hit400 ? "已達到" : "未達到", bgcolor=hit400 ? bgGreen : bgMuted, text_color=color.white)
    table.cell(t, 2, 9, "", bgcolor=hit400 ? bgGreen : bgMuted)

    table.cell(t, 0, 10, "600點", bgcolor=bgLabel, text_color=color.rgb(200, 210, 220))
    table.cell(t, 1, 10, hit600 ? "已達到" : "未達到", bgcolor=hit600 ? bgYellow : bgMuted, text_color=color.white)
    table.cell(t, 2, 10, "", bgcolor=hit600 ? bgYellow : bgMuted)

    table.cell(t, 0, 11, "800點", bgcolor=bgLabel, text_color=color.rgb(200, 210, 220))
    table.cell(t, 1, 11, hit800 ? "已達到" : "未達到", bgcolor=hit800 ? bgRed : bgMuted, text_color=color.white)
    table.cell(t, 2, 11, "", bgcolor=hit800 ? bgRed : bgMuted)

    table.cell(t, 0, 12, "今日高點", bgcolor=bgLabel, text_color=color.rgb(200, 210, 220))
    table.cell(t, 1, 12, str.tostring(todayHigh, "#.1"), bgcolor=bgValue, text_color=color.white)
    table.cell(t, 2, 12, "", bgcolor=bgValue)

    table.cell(t, 0, 13, "今日低點", bgcolor=bgLabel, text_color=color.rgb(200, 210, 220))
    table.cell(t, 1, 13, str.tostring(todayLow, "#.1"), bgcolor=bgValue, text_color=color.white)
    table.cell(t, 2, 13, "", bgcolor=bgValue)

    table.cell(t, 0, 14, "中線", bgcolor=bgLabel, text_color=color.rgb(200, 210, 220))
    table.cell(t, 1, 14, str.tostring(todayMid, "#.1"), bgcolor=bgValue, text_color=color.rgb(240, 220, 80))
    table.cell(t, 2, 14, "", bgcolor=bgValue)

alertcondition(hit400, title="今日波動達到400點", message="MNQ 今日波動已達到 400 點")
alertcondition(hit600, title="今日波動達到600點", message="MNQ 今日波動已達到 600 點")
alertcondition(hit800, title="今日波動達到800點", message="MNQ 今日波動已達到 800 點")
alertcondition(completion >= 70, title="ADR完成率達70%", message="MNQ ADR20 完成率已達 70%")
alertcondition(completion >= 90, title="ADR完成率達90%", message="MNQ ADR20 完成率已達 90%")
alertcondition(completion >= 100, title="ADR完成率達100%", message="MNQ ADR20 完成率已達 100%")
````
