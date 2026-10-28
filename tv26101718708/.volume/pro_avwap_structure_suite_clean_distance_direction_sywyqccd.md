# Pro AVWAP Structure Suite - Clean Distance Direction

- url: https://www.tradingview.com/script/SYWyqcCD-Pro-AVWAP-Structure-Suite-Clean-Distance-Direction/
- type: indicator
- pine_id: PUB;9492c8fadc894b5a90e3b2ac6277d04f
- version: 1.0

## Description

Pro AVWAP Structure Suite - Clean Distance Direction is a clean anchored VWAP structure indicator designed for traders who want AVWAP context without losing focus on candlesticks and price action.

The script includes multiple AVWAP groups:

1. Core AVWAPs:
- WTD AVWAP
- MTD AVWAP
- QTD AVWAP
- YTD AVWAP
- IPO AVWAP

2. Session / Range Levels:
- Today’s AVWAP
- Today’s High
- Today’s Low
- Previous Day High
- Previous Day Low
- This Week High
- This Week Low

3. Historical Event AVWAPs:
- COVID High
- COVID Low
- GFC Low
- Dotcom Low
- April Tariff Low
- March 2026 Low

4. Rolling Daily AVWAP Anchors:
- 10D
- 20D
- 50D
- 100D
- 150D
- 200D
- 250D

5. Rolling Weekly AVWAP Anchors:
- 10W
- 30W

6. Structure / Event AVWAPs:
- 52W High
- 52W Low
- YTD High
- YTD Low
- Swing High
- Swing Low
- Gap Up
- Gap Down
- Earnings Gap Proxy

7. Manual AVWAPs:
- Manual 1
- Manual 2
- Manual 3

The indicator includes a special visibility mode:
- Show Lines + Labels
- Labels Only
- Lines Only
- Hide All

Labels Only mode is useful when you want a clean chart where candlesticks remain the main focus, while still keeping AVWAP values and distance information visible on the right side.

Right-side AVWAP label boxes can show:
- AVWAP name
- AVWAP value
- Distance percentage from current price
- Direction arrow

Direction arrow meaning:
- ▲ = price is above the AVWAP
- ▼ = price is below the AVWAP

The label text can also use direction-based coloring:
- Green = price above AVWAP
- Red = price below AVWAP

The indicator also includes optional historical touch markers. These are intentionally limited to selected important AVWAPs to avoid clutter:

- Circle = YTD AVWAP touch
- Diamond = IPO AVWAP touch
- Square = 52W Low AVWAP touch

Marker color meaning:
- Green = candle closed above the touched AVWAP
- Red = candle closed below the touched AVWAP

Historical touch markers are OFF by default to keep the chart clean. A touch sensitivity setting and lookback control are included for historical AVWAP reaction study.

The script also includes dark and light chart visibility settings, auto colors, softer line transparency, and auto-contrast label boxes for better readability.

This indicator is designed as a visual structure and price-action support tool. It does not generate buy or sell signals and should not be used as a standalone trading system.

## Source Code

````pine
//@version=6
indicator("Pro AVWAP Structure Suite - Clean Distance Direction", overlay=true, format=format.price, max_labels_count=150)

//====================================================
// 00. MASTER CONTROL
//====================================================

gMaster = "00. Master Control"

masterEnabled = input.bool(true, "MASTER AVWAP SUITE ON/OFF", group=gMaster, tooltip="Main switch for the entire indicator. OFF hides all AVWAP lines, labels, and markers without removing the indicator from the chart.")

//====================================================
// 01. THEME / DISPLAY
//====================================================

gTheme = "01. Theme / Display"

chartBg = input.string("Black", "Chart background", options=["Black", "White"], group=gTheme, tooltip="Choose your TradingView chart background. Pine cannot automatically detect your chart theme, so this setting helps the script choose readable colors.")
useAutoColors = input.bool(true, "Auto colors for background", group=gTheme, tooltip="ON = script chooses high-contrast colors for black or white backgrounds. OFF = uses default/custom colors.")

suiteVisibilityMode = input.string("Show Lines + Labels", "Suite visibility mode", options=["Show Lines + Labels", "Labels Only", "Lines Only", "Hide All"], group=gTheme, tooltip="Labels Only hides AVWAP lines but keeps right-side label boxes. Best for clean candlestick-first reading.")
lineTransparency = input.int(40, "AVWAP line transparency", minval=0, maxval=90, group=gTheme, tooltip="Higher = lighter lines. 35-55 is best for candlestick-first reading.")

showSuiteLines = suiteVisibilityMode == "Show Lines + Labels" or suiteVisibilityMode == "Lines Only"
showSuiteLabels = suiteVisibilityMode == "Show Lines + Labels" or suiteVisibilityMode == "Labels Only"

isBlackBg = chartBg == "Black"

themeTextColor = isBlackBg ? color.white : color.black

autoContrastBoxColor = isBlackBg ? color.rgb(245, 245, 245) : color.rgb(12, 12, 12)
autoContrastTextColor = isBlackBg ? color.black : color.white

directionUpFlatColor = isBlackBg ? color.rgb(0, 120, 0) : color.lime
directionDownColor = isBlackBg ? color.rgb(180, 0, 0) : color.rgb(255, 80, 80)

//====================================================
// 02. LABEL SETTINGS
//====================================================

gLabels = "02. Labels"

labelsEnabled = input.bool(true, "Labels section ON/OFF", group=gLabels, tooltip="Section switch for all labels.")

labelMode = input.string("Name + Price + Distance + Direction", "Label mode", options=["Name + Price + Distance + Direction", "Name + Price + Distance", "Name + Price", "Name Only"], group=gLabels)

showPlusSign = input.bool(true, "Show plus sign for positive distance", group=gLabels, tooltip="ON = positive distance shows + sign. Example: +2.35%. Negative values always show - sign.")
distanceDecimals = input.int(2, "Distance decimals", minval=0, maxval=2, group=gLabels)

directionArrowSource = input.string("Price Direction", "Direction arrow source", options=["Price Direction", "Off"], group=gLabels, tooltip="Price Direction: ▲ means price is above AVWAP. ▼ means price is below AVWAP.")

labelOffset = input.int(3, "Label right offset", minval=0, maxval=50, group=gLabels, tooltip="Moves labels to the right of the current candle.")
labelSizeInput = input.string("Normal", "Label size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=gLabels, tooltip="Pine does not support true bold labels. Use Large or Huge for stronger visibility.")

labelBackgroundStyle = input.string("Auto Contrast Box", "Label background style", options=["Auto Contrast Box", "Clean Text Only", "Line Color Box", "Dark Box", "Light Box", "Custom Box"], group=gLabels, tooltip="Auto Contrast Box is best for readability. It uses a light box on black charts and a dark box on white charts.")

labelBoxTransparency = input.int(20, "Label box transparency", minval=0, maxval=100, group=gLabels, tooltip="0 = solid label background. 100 = invisible label background.")
labelCustomBgColor = input.color(color.black, "Custom label box color", group=gLabels)

labelTextMode = input.string("Direction Color", "Label text color mode", options=["Direction Color", "Auto Readable", "Line Color", "Auto Theme Color", "Custom Color"], group=gLabels, tooltip="Direction Color = green/red text based on price above or below AVWAP.")
labelCustomTextColor = input.color(color.white, "Custom label text color", group=gLabels)

//====================================================
// HELPERS
//====================================================

f_labelSize(_s) =>
    _s == "Tiny" ? size.tiny :
     _s == "Small" ? size.small :
     _s == "Large" ? size.large :
     _s == "Huge" ? size.huge :
     size.normal

f_style(_s) =>
    _s == "Stepline" ? plot.style_stepline :
     _s == "Circles" ? plot.style_circles :
     plot.style_line

f_pickColor(_dark, _light, _custom) =>
    useAutoColors ? (isBlackBg ? _dark : _light) : _custom

f_lineColor(_baseColor) =>
    color.new(_baseColor, lineTransparency)

f_anchorTime(_t) =>
    time >= _t and (na(time[1]) or time[1] < _t)

f_distPct(_val) =>
    not na(_val) and _val != 0 ? (close - _val) / _val * 100 : na

f_distText(_val, _showPlus, _decimals) =>
    pct = f_distPct(_val)
    fmt = _decimals == 0 ? "#" : _decimals == 1 ? "#.#" : "#.##"
    signTxt = _showPlus and not na(pct) and pct >= 0 ? "+" : ""
    not na(pct) ? signTxt + str.tostring(pct, fmt) + "%" : ""

f_priceDirectionArrow(_val) =>
    close >= _val ? "▲" : "▼"

f_priceDirectionColor(_val) =>
    close >= _val ? directionUpFlatColor : directionDownColor

f_activeDirectionArrow(_val) =>
    directionArrowSource == "Price Direction" ? f_priceDirectionArrow(_val) : ""

f_activeDirectionColor(_val) =>
    directionArrowSource == "Price Direction" ? f_priceDirectionColor(_val) : autoContrastTextColor

f_labelText(_name, _val) =>
    priceTxt = str.tostring(_val, format.mintick)
    distTxt = f_distText(_val, showPlusSign, distanceDecimals)
    directionTxt = f_activeDirectionArrow(_val)

    string txt = str.upper(_name)

    if labelMode != "Name Only"
        txt += "  " + priceTxt

        if labelMode == "Name + Price + Distance" or labelMode == "Name + Price + Distance + Direction"
            txt += "  " + distTxt

        if labelMode == "Name + Price + Distance + Direction" and directionArrowSource != "Off"
            txt += "  " + directionTxt

    txt

f_labelTextColor(_lineColor, _val) =>
    labelTextMode == "Direction Color" ? f_activeDirectionColor(_val) :
     labelTextMode == "Line Color" ? _lineColor :
     labelTextMode == "Auto Theme Color" ? themeTextColor :
     labelTextMode == "Custom Color" ? labelCustomTextColor :
     labelBackgroundStyle == "Auto Contrast Box" ? autoContrastTextColor :
     themeTextColor

f_labelBgColor(_lineColor) =>
    labelBackgroundStyle == "Clean Text Only" ? color.new(_lineColor, 100) :
     labelBackgroundStyle == "Auto Contrast Box" ? color.new(autoContrastBoxColor, labelBoxTransparency) :
     labelBackgroundStyle == "Line Color Box" ? color.new(_lineColor, labelBoxTransparency) :
     labelBackgroundStyle == "Dark Box" ? color.new(color.black, labelBoxTransparency) :
     labelBackgroundStyle == "Light Box" ? color.new(color.white, labelBoxTransparency) :
     color.new(labelCustomBgColor, labelBoxTransparency)

f_touchedAVWAP(_avwap, _sensitivityPct) =>
    band = _avwap * _sensitivityPct / 100
    low <= _avwap + band and high >= _avwap - band

f_touchMarkerColor(_avwap) =>
    close >= _avwap ? directionUpFlatColor : directionDownColor

//====================================================
// SOURCE / ENGINE
//====================================================

src = hlc3
vol = na(volume) or volume <= 0 ? 1.0 : volume

cumPV = ta.cum(src * vol)
cumV = ta.cum(vol)

f_avwapFromStored(_startPV, _startV) =>
    not na(_startPV) and not na(_startV) and cumV > _startV ? (cumPV - _startPV) / (cumV - _startV) : na

//====================================================
// 03. CORE AVWAPS
//====================================================

gCore = "03. Core AVWAPs"

coreEnabled = input.bool(true, "Core AVWAPs section ON/OFF", group=gCore, tooltip="Section switch for WTD, MTD, QTD, YTD, and IPOAVWAP.")

showWTD = input.bool(true, "WTD AVWAP", group=gCore, tooltip="Week-To-Date AVWAP. Resets every new trading week.")
showMTD = input.bool(true, "MTD AVWAP", group=gCore, tooltip="Month-To-Date AVWAP. Resets every new month.")
showQTD = input.bool(false, "QTD AVWAP", group=gCore, tooltip="Quarter-To-Date AVWAP. Resets every new calendar quarter. OFF by default.")
showYTD = input.bool(true, "YTD AVWAP", group=gCore, tooltip="Year-To-Date AVWAP. Resets every new year.")
showIPOAVWAP = input.bool(true, "IPOAVWAP", group=gCore, tooltip="IPOAVWAP starts automatically from the first available chart bar.")

coreWidth = input.int(1, "Core line width", minval=1, maxval=5, group=gCore)
coreStyle = input.string("Line", "Core line style", options=["Line", "Stepline", "Circles"], group=gCore)

firstBar = bar_index == 0

newDay = timeframe.change("D") or firstBar
newWeek = timeframe.change("W") or firstBar
newMonth = timeframe.change("M") or firstBar
newQuarter = timeframe.change("3M") or firstBar
newYear = timeframe.change("12M") or firstBar

wtd = ta.vwap(src, newWeek)
mtd = ta.vwap(src, newMonth)
qtd = ta.vwap(src, newQuarter)
ytd = ta.vwap(src, newYear)

var float ipoPV = na
var float ipoV = na

if firstBar
    ipoPV := src * vol
    ipoV := vol
else
    ipoPV += src * vol
    ipoV += vol

ipoAVWAP = ipoV > 0 ? ipoPV / ipoV : na

wtdColor = f_pickColor(color.rgb(0, 180, 255), color.rgb(0, 70, 200), color.blue)
mtdColor = f_pickColor(color.rgb(255, 170, 0), color.rgb(180, 85, 0), color.orange)
qtdColor = f_pickColor(color.rgb(0, 230, 200), color.rgb(0, 120, 110), color.teal)
ytdColor = f_pickColor(color.rgb(200, 120, 255), color.rgb(115, 40, 180), color.purple)
ipoColor = f_pickColor(color.rgb(255, 235, 0), color.rgb(150, 120, 0), color.yellow)

plot(masterEnabled and showSuiteLines and coreEnabled and showWTD ? wtd : na, "WTD AVWAP", color=f_lineColor(wtdColor), linewidth=coreWidth, style=f_style(coreStyle), force_overlay=true)
plot(masterEnabled and showSuiteLines and coreEnabled and showMTD ? mtd : na, "MTD AVWAP", color=f_lineColor(mtdColor), linewidth=coreWidth, style=f_style(coreStyle), force_overlay=true)
plot(masterEnabled and showSuiteLines and coreEnabled and showQTD ? qtd : na, "QTD AVWAP", color=f_lineColor(qtdColor), linewidth=coreWidth, style=f_style(coreStyle), force_overlay=true)
plot(masterEnabled and showSuiteLines and coreEnabled and showYTD ? ytd : na, "YTD AVWAP", color=f_lineColor(ytdColor), linewidth=coreWidth, style=f_style(coreStyle), force_overlay=true)
plot(masterEnabled and showSuiteLines and coreEnabled and showIPOAVWAP ? ipoAVWAP : na, "IPOAVWAP", color=f_lineColor(ipoColor), linewidth=coreWidth, style=f_style(coreStyle), force_overlay=true)

//====================================================
// 04. SESSION / RANGE LEVELS
//====================================================

gSession = "04. Session / Range Levels"

sessionEnabled = input.bool(false, "Session / Range Levels section ON/OFF", group=gSession, tooltip="Optional fast context levels. OFF by default so it does not disturb the main AVWAP suite.")

showTodayAVWAP = input.bool(true, "Today's AVWAP", group=gSession, tooltip="AVWAP from the start of the current trading day.")
showTodayHigh = input.bool(true, "Today's High", group=gSession, tooltip="Current day's high. Resets every new trading day.")
showTodayLow = input.bool(true, "Today's Low", group=gSession, tooltip="Current day's low. Resets every new trading day.")

showPrevDayHigh = input.bool(true, "Previous Day High", group=gSession, tooltip="Previous completed daily candle high.")
showPrevDayLow = input.bool(true, "Previous Day Low", group=gSession, tooltip="Previous completed daily candle low.")

showThisWeekHigh = input.bool(true, "This Week High", group=gSession, tooltip="Current week high. Resets every new week.")
showThisWeekLow = input.bool(true, "This Week Low", group=gSession, tooltip="Current week low. Resets every new week.")

sessionWidth = input.int(1, "Session / Range line width", minval=1, maxval=5, group=gSession)
sessionStyle = input.string("Line", "Session / Range line style", options=["Line", "Stepline", "Circles"], group=gSession)

todayAVWAP = ta.vwap(src, newDay)

var float todayHigh = na
var float todayLow = na

if newDay or na(todayHigh)
    todayHigh := high
    todayLow := low
else
    todayHigh := math.max(todayHigh, high)
    todayLow := math.min(todayLow, low)

prevDayHigh = request.security(syminfo.tickerid, "D", high[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
prevDayLow = request.security(syminfo.tickerid, "D", low[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

var float thisWeekHigh = na
var float thisWeekLow = na

if newWeek or na(thisWeekHigh)
    thisWeekHigh := high
    thisWeekLow := low
else
    thisWeekHigh := math.max(thisWeekHigh, high)
    thisWeekLow := math.min(thisWeekLow, low)

todayAVWAPColor = f_pickColor(color.rgb(255, 255, 255), color.rgb(0, 0, 0), color.white)
todayHighColor = f_pickColor(color.rgb(0, 255, 120), color.rgb(0, 130, 60), color.green)
todayLowColor = f_pickColor(color.rgb(255, 80, 80), color.rgb(180, 0, 0), color.red)
prevDayHighColor = f_pickColor(color.rgb(80, 220, 255), color.rgb(0, 100, 200), color.blue)
prevDayLowColor = f_pickColor(color.rgb(255, 170, 0), color.rgb(180, 85, 0), color.orange)
thisWeekHighColor = f_pickColor(color.rgb(180, 255, 120), color.rgb(80, 130, 20), color.lime)
thisWeekLowColor = f_pickColor(color.rgb(255, 120, 220), color.rgb(160, 40, 130), color.fuchsia)

plot(masterEnabled and showSuiteLines and sessionEnabled and showTodayAVWAP ? todayAVWAP : na, "Today's AVWAP", color=f_lineColor(todayAVWAPColor), linewidth=sessionWidth, style=f_style(sessionStyle), force_overlay=true)
plot(masterEnabled and showSuiteLines and sessionEnabled and showTodayHigh ? todayHigh : na, "Today's High", color=f_lineColor(todayHighColor), linewidth=sessionWidth, style=f_style(sessionStyle), force_overlay=true)
plot(masterEnabled and showSuiteLines and sessionEnabled and showTodayLow ? todayLow : na, "Today's Low", color=f_lineColor(todayLowColor), linewidth=sessionWidth, style=f_style(sessionStyle), force_overlay=true)
plot(masterEnabled and showSuiteLines and sessionEnabled and showPrevDayHigh ? prevDayHigh : na, "Previous Day High", color=f_lineColor(prevDayHighColor), linewidth=sessionWidth, style=f_style(sessionStyle), force_overlay=true)
plot(masterEnabled and showSuiteLines and sessionEnabled and showPrevDayLow ? prevDayLow : na, "Previous Day Low", color=f_lineColor(prevDayLowColor), linewidth=sessionWidth, style=f_style(sessionStyle), force_overlay=true)
plot(masterEnabled and showSuiteLines and sessionEnabled and showThisWeekHigh ? thisWeekHigh : na, "This Week High", color=f_lineColor(thisWeekHighColor), linewidth=sessionWidth, style=f_style(sessionStyle), force_overlay=true)
plot(masterEnabled and showSuiteLines and sessionEnabled and showThisWeekLow ? thisWeekLow : na, "This Week Low", color=f_lineColor(thisWeekLowColor), linewidth=sessionWidth, style=f_style(sessionStyle), force_overlay=true)

//====================================================
// 05. HISTORICAL EVENT AVWAP SLOTS
//====================================================

gHist = "05. Historical Event AVWAP Slots"

histEnabled = input.bool(true, "Historical Events section ON/OFF", group=gHist, tooltip="Section switch for historical event AVWAP slots.")

histSlot1 = input.string("COVID LOW", "Historical Slot 1", options=["OFF", "COVID HIGH", "COVID LOW", "GFC LOW", "DOTCOM LOW", "APRIL TARIFF LOW", "MARCH 2026 LOW"], group=gHist)
histSlot2 = input.string("OFF", "Historical Slot 2", options=["OFF", "COVID HIGH", "COVID LOW", "GFC LOW", "DOTCOM LOW", "APRIL TARIFF LOW", "MARCH 2026 LOW"], group=gHist)

histWidth = input.int(1, "Historical line width", minval=1, maxval=5, group=gHist)
histStyle = input.string("Line", "Historical line style", options=["Line", "Stepline", "Circles"], group=gHist)

covidHigh = ta.vwap(src, f_anchorTime(timestamp("19 Feb 2020 00:00 +0000")))
covidLow = ta.vwap(src, f_anchorTime(timestamp("23 Mar 2020 00:00 +0000")))
gfcLow = ta.vwap(src, f_anchorTime(timestamp("09 Mar 2009 00:00 +0000")))
dotcomLow = ta.vwap(src, f_anchorTime(timestamp("09 Oct 2002 00:00 +0000")))
tariffLow = ta.vwap(src, f_anchorTime(timestamp("07 Apr 2025 00:00 +0000")))
march2026Low = ta.vwap(src, f_anchorTime(timestamp("30 Mar 2026 00:00 +0000")))

f_histValue(_type) =>
    switch _type
        "COVID HIGH" => covidHigh
        "COVID LOW" => covidLow
        "GFC LOW" => gfcLow
        "DOTCOM LOW" => dotcomLow
        "APRIL TARIFF LOW" => tariffLow
        "MARCH 2026 LOW" => march2026Low
        => na

hist1Val = f_histValue(histSlot1)
hist2Val = f_histValue(histSlot2)

hist1Color = f_pickColor(color.lime, color.green, color.lime)
hist2Color = f_pickColor(color.aqua, color.blue, color.aqua)

plot(masterEnabled and showSuiteLines and histEnabled and histSlot1 != "OFF" ? hist1Val : na, "Historical Slot 1", color=f_lineColor(hist1Color), linewidth=histWidth, style=f_style(histStyle), force_overlay=true)
plot(masterEnabled and showSuiteLines and histEnabled and histSlot2 != "OFF" ? hist2Val : na, "Historical Slot 2", color=f_lineColor(hist2Color), linewidth=histWidth, style=f_style(histStyle), force_overlay=true)

//====================================================
// 06. ROLLING DAILY AVWAP ANCHORS
//====================================================

gDaily = "06. Rolling Daily AVWAP Anchors"

dailyEnabled = input.bool(false, "Rolling Daily AVWAP section ON/OFF", group=gDaily, tooltip="Pure AVWAPs anchored from recent daily starts. OFF by default to keep the chart clean.")

dailySlot1 = input.string("20D", "Daily Anchor Slot 1", options=["OFF", "10D", "20D", "50D", "100D", "150D", "200D", "250D"], group=gDaily)
dailySlot2 = input.string("50D", "Daily Anchor Slot 2", options=["OFF", "10D", "20D", "50D", "100D", "150D", "200D", "250D"], group=gDaily)
dailySlot3 = input.string("200D", "Daily Anchor Slot 3", options=["OFF", "10D", "20D", "50D", "100D", "150D", "200D", "250D"], group=gDaily)

dailyWidth = input.int(1, "Daily AVWAP line width", minval=1, maxval=5, group=gDaily)
dailyStyle = input.string("Line", "Daily AVWAP line style", options=["Line", "Stepline", "Circles"], group=gDaily)

d10StartPV = ta.valuewhen(newDay, nz(cumPV[1], 0.0), 10)
d10StartV = ta.valuewhen(newDay, nz(cumV[1], 0.0), 10)

d20StartPV = ta.valuewhen(newDay, nz(cumPV[1], 0.0), 20)
d20StartV = ta.valuewhen(newDay, nz(cumV[1], 0.0), 20)

d50StartPV = ta.valuewhen(newDay, nz(cumPV[1], 0.0), 50)
d50StartV = ta.valuewhen(newDay, nz(cumV[1], 0.0), 50)

d100StartPV = ta.valuewhen(newDay, nz(cumPV[1], 0.0), 100)
d100StartV = ta.valuewhen(newDay, nz(cumV[1], 0.0), 100)

d150StartPV = ta.valuewhen(newDay, nz(cumPV[1], 0.0), 150)
d150StartV = ta.valuewhen(newDay, nz(cumV[1], 0.0), 150)

d200StartPV = ta.valuewhen(newDay, nz(cumPV[1], 0.0), 200)
d200StartV = ta.valuewhen(newDay, nz(cumV[1], 0.0), 200)

d250StartPV = ta.valuewhen(newDay, nz(cumPV[1], 0.0), 250)
d250StartV = ta.valuewhen(newDay, nz(cumV[1], 0.0), 250)

d10 = f_avwapFromStored(d10StartPV, d10StartV)
d20 = f_avwapFromStored(d20StartPV, d20StartV)
d50 = f_avwapFromStored(d50StartPV, d50StartV)
d100 = f_avwapFromStored(d100StartPV, d100StartV)
d150 = f_avwapFromStored(d150StartPV, d150StartV)
d200 = f_avwapFromStored(d200StartPV, d200StartV)
d250 = f_avwapFromStored(d250StartPV, d250StartV)

f_dailyValue(_type) =>
    switch _type
        "10D" => d10
        "20D" => d20
        "50D" => d50
        "100D" => d100
        "150D" => d150
        "200D" => d200
        "250D" => d250
        => na

daily1Val = f_dailyValue(dailySlot1)
daily2Val = f_dailyValue(dailySlot2)
daily3Val = f_dailyValue(dailySlot3)

daily1Color = f_pickColor(color.rgb(80, 220, 255), color.rgb(0, 100, 200), color.blue)
daily2Color = f_pickColor(color.rgb(255, 210, 80), color.rgb(180, 110, 0), color.orange)
daily3Color = f_pickColor(color.rgb(255, 120, 220), color.rgb(160, 40, 130), color.fuchsia)

plot(masterEnabled and showSuiteLines and dailyEnabled and dailySlot1 != "OFF" ? daily1Val : na, "Rolling Daily AVWAP Slot 1", color=f_lineColor(daily1Color), linewidth=dailyWidth, style=f_style(dailyStyle), force_overlay=true)
plot(masterEnabled and showSuiteLines and dailyEnabled and dailySlot2 != "OFF" ? daily2Val : na, "Rolling Daily AVWAP Slot 2", color=f_lineColor(daily2Color), linewidth=dailyWidth, style=f_style(dailyStyle), force_overlay=true)
plot(masterEnabled and showSuiteLines and dailyEnabled and dailySlot3 != "OFF" ? daily3Val : na, "Rolling Daily AVWAP Slot 3", color=f_lineColor(daily3Color), linewidth=dailyWidth, style=f_style(dailyStyle), force_overlay=true)

//====================================================
// 07. ROLLING WEEKLY AVWAP ANCHORS
//====================================================

gWeekly = "07. Rolling Weekly AVWAP Anchors"

weeklyEnabled = input.bool(false, "Rolling Weekly AVWAP section ON/OFF", group=gWeekly, tooltip="Pure AVWAPs anchored from recent weekly starts. OFF by default to keep the chart clean.")

weeklySlot1 = input.string("10W", "Weekly Anchor Slot 1", options=["OFF", "10W", "30W"], group=gWeekly)
weeklySlot2 = input.string("30W", "Weekly Anchor Slot 2", options=["OFF", "10W", "30W"], group=gWeekly)

weeklyWidth = input.int(1, "Weekly AVWAP line width", minval=1, maxval=5, group=gWeekly)
weeklyStyle = input.string("Line", "Weekly AVWAP line style", options=["Line", "Stepline", "Circles"], group=gWeekly)

w10StartPV = ta.valuewhen(newWeek, nz(cumPV[1], 0.0), 10)
w10StartV = ta.valuewhen(newWeek, nz(cumV[1], 0.0), 10)

w30StartPV = ta.valuewhen(newWeek, nz(cumPV[1], 0.0), 30)
w30StartV = ta.valuewhen(newWeek, nz(cumV[1], 0.0), 30)

w10 = f_avwapFromStored(w10StartPV, w10StartV)
w30 = f_avwapFromStored(w30StartPV, w30StartV)

f_weeklyValue(_type) =>
    switch _type
        "10W" => w10
        "30W" => w30
        => na

weekly1Val = f_weeklyValue(weeklySlot1)
weekly2Val = f_weeklyValue(weeklySlot2)

weekly1Color = f_pickColor(color.rgb(180, 255, 120), color.rgb(80, 130, 20), color.green)
weekly2Color = f_pickColor(color.rgb(255, 255, 120), color.rgb(150, 120, 0), color.yellow)

plot(masterEnabled and showSuiteLines and weeklyEnabled and weeklySlot1 != "OFF" ? weekly1Val : na, "Rolling Weekly AVWAP Slot 1", color=f_lineColor(weekly1Color), linewidth=weeklyWidth, style=f_style(weeklyStyle), force_overlay=true)
plot(masterEnabled and showSuiteLines and weeklyEnabled and weeklySlot2 != "OFF" ? weekly2Val : na, "Rolling Weekly AVWAP Slot 2", color=f_lineColor(weekly2Color), linewidth=weeklyWidth, style=f_style(weeklyStyle), force_overlay=true)

//====================================================
// 08. STRUCTURE / EVENT AVWAP SLOTS
//====================================================

gStruct = "08. Structure / Event AVWAP Slots"

structEnabled = input.bool(true, "Structure / Event section ON/OFF", group=gStruct, tooltip="Section switch for structure/event AVWAP slots. Uses slots to stay below TradingView plot-count limits.")

structSlot1 = input.string("52W LOW", "Structure Slot 1", options=["OFF", "52W HIGH", "52W LOW", "YTD HIGH", "YTD LOW", "SWING HIGH", "SWING LOW", "GAP UP", "GAP DOWN", "EARNINGS GAP PROXY"], group=gStruct)
structSlot2 = input.string("YTD LOW", "Structure Slot 2", options=["OFF", "52W HIGH", "52W LOW", "YTD HIGH", "YTD LOW", "SWING HIGH", "SWING LOW", "GAP UP", "GAP DOWN", "EARNINGS GAP PROXY"], group=gStruct)
structSlot3 = input.string("OFF", "Structure Slot 3", options=["OFF", "52W HIGH", "52W LOW", "YTD HIGH", "YTD LOW", "SWING HIGH", "SWING LOW", "GAP UP", "GAP DOWN", "EARNINGS GAP PROXY"], group=gStruct)

structWidth = input.int(1, "Structure line width", minval=1, maxval=5, group=gStruct)
structStyle = input.string("Line", "Structure line style", options=["Line", "Stepline", "Circles"], group=gStruct)

pivotLeft = input.int(5, "Swing pivot left", minval=1, maxval=20, group=gStruct)
pivotRight = input.int(5, "Swing pivot right", minval=1, maxval=20, group=gStruct)
gapPct = input.float(3.0, "Gap threshold %", minval=0.1, step=0.1, group=gStruct)
earnGapPct = input.float(6.0, "Earnings proxy gap %", minval=1.0, step=0.5, group=gStruct)
earnVolMult = input.float(1.5, "Earnings proxy volume multiplier", minval=0.5, step=0.1, group=gStruct)

highest52 = ta.highest(high, 252)
lowest52 = ta.lowest(low, 252)
avgVol20 = ta.sma(vol, 20)

enough52 = bar_index >= 251
is52High = enough52 and high >= highest52
is52Low = enough52 and low <= lowest52

var float ytdHigh = na
var float ytdLow = na

newYTDHigh = newYear or na(ytdHigh) or high > ytdHigh
newYTDLow = newYear or na(ytdLow) or low < ytdLow

if newYear or na(ytdHigh)
    ytdHigh := high
    ytdLow := low
else
    ytdHigh := math.max(ytdHigh, high)
    ytdLow := math.min(ytdLow, low)

swingHighTrigger = not na(ta.pivothigh(high, pivotLeft, pivotRight))
swingLowTrigger = not na(ta.pivotlow(low, pivotLeft, pivotRight))

gapUpTrigger = not na(high[1]) and open > high[1] * (1 + gapPct / 100)
gapDownTrigger = not na(low[1]) and open < low[1] * (1 - gapPct / 100)
earningsGapProxyTrigger = not na(close[1]) and math.abs(open - close[1]) / close[1] * 100 >= earnGapPct and vol > avgVol20 * earnVolMult

avwap52High = ta.vwap(src, is52High)
avwap52Low = ta.vwap(src, is52Low)
avwapYTDHigh = ta.vwap(src, newYTDHigh)
avwapYTDLow = ta.vwap(src, newYTDLow)
avwapSwingHigh = ta.vwap(src, swingHighTrigger)
avwapSwingLow = ta.vwap(src, swingLowTrigger)
avwapGapUp = ta.vwap(src, gapUpTrigger)
avwapGapDown = ta.vwap(src, gapDownTrigger)
avwapEarningsGap = ta.vwap(src, earningsGapProxyTrigger)

f_structValue(_type) =>
    switch _type
        "52W HIGH" => avwap52High
        "52W LOW" => avwap52Low
        "YTD HIGH" => avwapYTDHigh
        "YTD LOW" => avwapYTDLow
        "SWING HIGH" => avwapSwingHigh
        "SWING LOW" => avwapSwingLow
        "GAP UP" => avwapGapUp
        "GAP DOWN" => avwapGapDown
        "EARNINGS GAP PROXY" => avwapEarningsGap
        => na

struct1Val = f_structValue(structSlot1)
struct2Val = f_structValue(structSlot2)
struct3Val = f_structValue(structSlot3)

struct1Color = f_pickColor(color.rgb(255, 120, 120), color.rgb(180, 0, 0), color.red)
struct2Color = f_pickColor(color.rgb(120, 255, 120), color.rgb(0, 130, 0), color.green)
struct3Color = f_pickColor(color.rgb(255, 255, 120), color.rgb(150, 120, 0), color.yellow)

plot(masterEnabled and showSuiteLines and structEnabled and structSlot1 != "OFF" ? struct1Val : na, "Structure Slot 1", color=f_lineColor(struct1Color), linewidth=structWidth, style=f_style(structStyle), force_overlay=true)
plot(masterEnabled and showSuiteLines and structEnabled and structSlot2 != "OFF" ? struct2Val : na, "Structure Slot 2", color=f_lineColor(struct2Color), linewidth=structWidth, style=f_style(structStyle), force_overlay=true)
plot(masterEnabled and showSuiteLines and structEnabled and structSlot3 != "OFF" ? struct3Val : na, "Structure Slot 3", color=f_lineColor(struct3Color), linewidth=structWidth, style=f_style(structStyle), force_overlay=true)

//====================================================
// 09. HISTORICAL AVWAP TOUCH MARKERS
//====================================================

gMarkers = "09. Historical AVWAP Touch Markers"

markersEnabled = input.bool(false, "Historical touch markers ON/OFF", group=gMarkers, tooltip="OFF by default for a clean chart. Turn ON only when studying past AVWAP reactions.")

showYTDTouchMarkers = input.bool(true, "YTD AVWAP touch markers", group=gMarkers, tooltip="Circle marker for YTD AVWAP touches.")
showIPOTouchMarkers = input.bool(true, "IPO AVWAP touch markers", group=gMarkers, tooltip="Diamond marker for IPO AVWAP touches.")
show52LowTouchMarkers = input.bool(false, "52W LOW AVWAP touch markers", group=gMarkers, tooltip="Square marker for 52W LOW AVWAP touches. Default OFF to reduce clutter.")

touchSensitivityPct = input.float(0.20, "Touch sensitivity %", minval=0.01, maxval=2.00, step=0.01, group=gMarkers, tooltip="How close price must come to the AVWAP to count as a touch. 0.20% is a clean default.")
markerLookbackBars = input.int(300, "Marker lookback bars", minval=50, maxval=2000, group=gMarkers, tooltip="Only show markers for recent historical bars. 300 is good for swing study.")

markerRecentEnough = last_bar_index - bar_index <= markerLookbackBars

touchYTD = masterEnabled and markersEnabled and showYTDTouchMarkers and markerRecentEnough and not na(ytd) and f_touchedAVWAP(ytd, touchSensitivityPct)
touchIPO = masterEnabled and markersEnabled and showIPOTouchMarkers and markerRecentEnough and not na(ipoAVWAP) and f_touchedAVWAP(ipoAVWAP, touchSensitivityPct)
touch52Low = masterEnabled and markersEnabled and show52LowTouchMarkers and markerRecentEnough and not na(avwap52Low) and f_touchedAVWAP(avwap52Low, touchSensitivityPct)

plotshape(touchYTD ? ytd : na, title="YTD AVWAP Touch Marker", style=shape.circle, location=location.absolute, color=f_touchMarkerColor(ytd), size=size.tiny)
plotshape(touchIPO ? ipoAVWAP : na, title="IPO AVWAP Touch Marker", style=shape.diamond, location=location.absolute, color=f_touchMarkerColor(ipoAVWAP), size=size.tiny)
plotshape(touch52Low ? avwap52Low : na, title="52W LOW AVWAP Touch Marker", style=shape.square, location=location.absolute, color=f_touchMarkerColor(avwap52Low), size=size.tiny)

//====================================================
// 10. MANUAL AVWAPS
//====================================================

gManual = "10. Manual AVWAPs"

manualEnabled = input.bool(true, "Manual AVWAPs section ON/OFF", group=gManual, tooltip="Section switch for manual AVWAPs. Manual anchors are best for exact IPO dates, earnings dates, breakout days, and personal custom anchors.")

manualWidth = input.int(1, "Manual line width", minval=1, maxval=5, group=gManual)
manualStyle = input.string("Line", "Manual line style", options=["Line", "Stepline", "Circles"], group=gManual)

showManual1 = input.bool(false, "Manual 1", group=gManual)
manual1Time = input.time(timestamp("01 Jan 2024 09:30 +0000"), "Manual 1 time", confirm=true, group=gManual)
manual1Name = input.string("MANUAL 1", "Manual 1 label", group=gManual)

showManual2 = input.bool(false, "Manual 2", group=gManual)
manual2Time = input.time(timestamp("01 Jan 2024 09:30 +0000"), "Manual 2 time", confirm=true, group=gManual)
manual2Name = input.string("MANUAL 2", "Manual 2 label", group=gManual)

showManual3 = input.bool(false, "Manual 3", group=gManual)
manual3Time = input.time(timestamp("01 Jan 2024 09:30 +0000"), "Manual 3 time", confirm=true, group=gManual)
manual3Name = input.string("MANUAL 3", "Manual 3 label", group=gManual)

manual1 = ta.vwap(src, f_anchorTime(manual1Time))
manual2 = ta.vwap(src, f_anchorTime(manual2Time))
manual3 = ta.vwap(src, f_anchorTime(manual3Time))

manualColor = f_pickColor(color.white, color.black, color.white)

plot(masterEnabled and showSuiteLines and manualEnabled and showManual1 ? manual1 : na, "Manual 1 AVWAP", color=f_lineColor(manualColor), linewidth=manualWidth, style=f_style(manualStyle), force_overlay=true)
plot(masterEnabled and showSuiteLines and manualEnabled and showManual2 ? manual2 : na, "Manual 2 AVWAP", color=f_lineColor(manualColor), linewidth=manualWidth, style=f_style(manualStyle), force_overlay=true)
plot(masterEnabled and showSuiteLines and manualEnabled and showManual3 ? manual3 : na, "Manual 3 AVWAP", color=f_lineColor(manualColor), linewidth=manualWidth, style=f_style(manualStyle), force_overlay=true)

//====================================================
// LABEL VARIABLES
//====================================================

var label lWTD = na
var label lMTD = na
var label lQTD = na
var label lYTD = na
var label lIPO = na

var label lTodayAVWAP = na
var label lTodayHigh = na
var label lTodayLow = na
var label lPrevDayHigh = na
var label lPrevDayLow = na
var label lThisWeekHigh = na
var label lThisWeekLow = na

var label lHist1 = na
var label lHist2 = na

var label lDaily1 = na
var label lDaily2 = na
var label lDaily3 = na

var label lWeekly1 = na
var label lWeekly2 = na

var label lStruct1 = na
var label lStruct2 = na
var label lStruct3 = na

var label lManual1 = na
var label lManual2 = na
var label lManual3 = na

f_label(_old, _show, _val, _txt, _col) =>
    label result = _old

    if not na(result)
        label.delete(result)
        result := na

    if masterEnabled and labelsEnabled and showSuiteLabels and _show and not na(_val) and barstate.islast
        t = f_labelText(_txt, _val)
        txtColor = f_labelTextColor(_col, _val)
        bgColor = f_labelBgColor(_col)

        result := label.new(x=bar_index + labelOffset, y=_val, text=t, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, textcolor=txtColor, color=bgColor, size=f_labelSize(labelSizeInput))

    result

//====================================================
// LABEL DRAWING
//====================================================

if barstate.islast
    lWTD := f_label(lWTD, coreEnabled and showWTD, wtd, "WTD", wtdColor)
    lMTD := f_label(lMTD, coreEnabled and showMTD, mtd, "MTD", mtdColor)
    lQTD := f_label(lQTD, coreEnabled and showQTD, qtd, "QTD", qtdColor)
    lYTD := f_label(lYTD, coreEnabled and showYTD, ytd, "YTD", ytdColor)
    lIPO := f_label(lIPO, coreEnabled and showIPOAVWAP, ipoAVWAP, "IPOAVWAP", ipoColor)

    lTodayAVWAP := f_label(lTodayAVWAP, sessionEnabled and showTodayAVWAP, todayAVWAP, "TODAY AVWAP", todayAVWAPColor)
    lTodayHigh := f_label(lTodayHigh, sessionEnabled and showTodayHigh, todayHigh, "TODAY HIGH", todayHighColor)
    lTodayLow := f_label(lTodayLow, sessionEnabled and showTodayLow, todayLow, "TODAY LOW", todayLowColor)
    lPrevDayHigh := f_label(lPrevDayHigh, sessionEnabled and showPrevDayHigh, prevDayHigh, "PDH", prevDayHighColor)
    lPrevDayLow := f_label(lPrevDayLow, sessionEnabled and showPrevDayLow, prevDayLow, "PDL", prevDayLowColor)
    lThisWeekHigh := f_label(lThisWeekHigh, sessionEnabled and showThisWeekHigh, thisWeekHigh, "THIS WEEK HIGH", thisWeekHighColor)
    lThisWeekLow := f_label(lThisWeekLow, sessionEnabled and showThisWeekLow, thisWeekLow, "THIS WEEK LOW", thisWeekLowColor)

    lHist1 := f_label(lHist1, histEnabled and histSlot1 != "OFF", hist1Val, histSlot1, hist1Color)
    lHist2 := f_label(lHist2, histEnabled and histSlot2 != "OFF", hist2Val, histSlot2, hist2Color)

    lDaily1 := f_label(lDaily1, dailyEnabled and dailySlot1 != "OFF", daily1Val, dailySlot1, daily1Color)
    lDaily2 := f_label(lDaily2, dailyEnabled and dailySlot2 != "OFF", daily2Val, dailySlot2, daily2Color)
    lDaily3 := f_label(lDaily3, dailyEnabled and dailySlot3 != "OFF", daily3Val, dailySlot3, daily3Color)

    lWeekly1 := f_label(lWeekly1, weeklyEnabled and weeklySlot1 != "OFF", weekly1Val, weeklySlot1, weekly1Color)
    lWeekly2 := f_label(lWeekly2, weeklyEnabled and weeklySlot2 != "OFF", weekly2Val, weeklySlot2, weekly2Color)

    lStruct1 := f_label(lStruct1, structEnabled and structSlot1 != "OFF", struct1Val, structSlot1, struct1Color)
    lStruct2 := f_label(lStruct2, structEnabled and structSlot2 != "OFF", struct2Val, structSlot2, struct2Color)
    lStruct3 := f_label(lStruct3, structEnabled and structSlot3 != "OFF", struct3Val, structSlot3, struct3Color)

    lManual1 := f_label(lManual1, manualEnabled and showManual1, manual1, manual1Name, manualColor)
    lManual2 := f_label(lManual2, manualEnabled and showManual2, manual2, manual2Name, manualColor)
    lManual3 := f_label(lManual3, manualEnabled and showManual3, manual3, manual3Name, manualColor)
````
