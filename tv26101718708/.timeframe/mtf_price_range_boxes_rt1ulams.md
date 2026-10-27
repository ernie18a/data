# MTF Price Range Boxes 

- url: https://www.tradingview.com/script/RT1ULaMs/
- type: indicator
- pine_id: PUB;266c31a50b3b4ad29037e9786d43dced
- version: 5.0

## Description

[image]https://www.tradingview.com/x/V1KnmXif/[/image]

[b]MTF Price Range Boxes v4[/b]
[i]Multi‑Timeframe Price Range Boxes + Fibonacci Levels[/i]

[b]Purpose[/b]
Displays higher timeframe price range rectangles (High↔Low / Open↔Close) on the current chart, plus optional 0.382, 0.5, 0.618 Fibonacci lines.

[b]Parameters[/b]
[list]
[*][b]Price range mode[/b] – HL (High/Low only) or OHLC (body + wick)
[*][b]Up body color[/b] – Bullish body color (default orange, transp. 80)
[*][b]Up wick color[/b] – Bullish wick color in OHLC mode (default orange, transp. 90)
[*][b]Down body color[/b] – Bearish body color (default gray, transp. 80)
[*][b]Down wick color[/b] – Bearish wick color in OHLC mode (default gray, transp. 90)
[*][b]Show Fibonacci lines[/b] – Toggle 0.382/0.5/0.618 solid lines on/off
[*][b]Target timeframe[/b] – 1 hour, 4 hours, Day, Week (must be higher than current timeframe)
[/list]

[b]Notes[/b]
Rectangles and lines are drawn once when the target timeframe closes – no repainting. If target ≤ current timeframe, an error message appears in the top‑right corner.

## Source Code

````pine
//@version=6
indicator("MTF Price Range Boxes", overlay=true)

// ------------------------------------------------------------
// 全局辅助函数
// ------------------------------------------------------------
getLineStyle(style) =>
    if style == "虚线"
        line.style_dashed
    else if style == "点线"
        line.style_dotted
    else
        line.style_solid

getLinePrice(percent, isUpCandle, highP, lowP) =>
    float rng = highP - lowP
    if percent >= 0
        isUpCandle ? highP - percent / 100 * rng : lowP + percent / 100 * rng
    else
        isUpCandle ? highP + math.abs(percent) / 100 * rng : lowP - math.abs(percent) / 100 * rng

periodToMinutes(periodStr) =>
    int minutes = na
    if periodStr == "1"
        minutes := 1
    else if periodStr == "3"
        minutes := 3
    else if periodStr == "5"
        minutes := 5
    else if periodStr == "15"
        minutes := 15
    else if periodStr == "30"
        minutes := 30
    else if periodStr == "45"
        minutes := 45
    else if periodStr == "60" or periodStr == "1H"
        minutes := 60
    else if periodStr == "120" or periodStr == "2H"
        minutes := 120
    else if periodStr == "180" or periodStr == "3H"
        minutes := 180
    else if periodStr == "240" or periodStr == "4H"
        minutes := 240
    else if periodStr == "360" or periodStr == "6H"
        minutes := 360
    else if periodStr == "720" or periodStr == "12H"
        minutes := 720
    else if periodStr == "D" or periodStr == "1D"
        minutes := 1440
    else if periodStr == "W"
        minutes := 10080
    else if periodStr == "M"
        minutes := 43200
    else if periodStr == "3M"
        minutes := 129600
    else if periodStr == "6M"
        minutes := 259200
    else if periodStr == "12M"
        minutes := 518400
    else
        minutes := 0
    minutes

getAutoTarget(currentTF) =>
    bool isSeconds = str.contains(currentTF, "S")
    if isSeconds
        "60"
    else
        int mins = periodToMinutes(currentTF)
        if mins <= 1
            "60"
        else if mins <= 3
            "60"
        else if mins <= 5
            "60"
        else if mins <= 15
            "60"
        else if mins == 30
            "120"
        else if mins == 45
            "240"
        else if mins <= 60
            "240"
        else if mins <= 120
            "720"
        else if mins <= 180
            "720"
        else if mins <= 240
            "D"
        else if mins <= 360
            "D"
        else if mins <= 720
            "W"
        else if mins <= 1440
            "W"
        else if mins <= 10080
            "M"
        else if mins <= 43200
            "6M"
        else if mins <= 129600
            "12M"
        else if mins <= 259200
            "12M"
        else
            "12M"

// ------------------------------------------------------------
// 用户输入配置（全部隐藏）
// ------------------------------------------------------------
string mode = input.string("HL", "价格范围模式", options=["HL", "OHLC"], group="模式设置", display=display.none)

color colorUpBody   = input.color(color.new(color.orange, 80), "上涨实体颜色", group="颜色设置", display=display.none)
color colorUpWick   = input.color(color.new(color.orange, 90), "上涨影线颜色", group="颜色设置", display=display.none)
color colorDownBody = input.color(color.new(color.gray,  80), "下跌实体颜色", group="颜色设置", display=display.none)
color colorDownWick = input.color(color.new(color.gray,  90), "下跌影线颜色", group="颜色设置", display=display.none)

// 周期设置
bool autoTarget = input.bool(true, "自动周期", group="周期设置", display=display.none)
string manualTarget = input.string("1小时", "手动设置目标周期", options=["1小时", "4小时", "日", "周"], group="周期设置", display=display.none)

tfToCode(tf) =>
    if tf == "1小时"
        "60"
    else if tf == "4小时"
        "240"
    else if tf == "日"
        "D"
    else if tf == "周"
        "W"
    else
        "60"

targetCode = autoTarget ? getAutoTarget(timeframe.period) : tfToCode(manualTarget)

targetDisplay = autoTarget ?
   (targetCode == "60" ? "1小时" :
    targetCode == "120" ? "2小时" :
    targetCode == "240" ? "4小时" :
    targetCode == "720" ? "12小时" :
    targetCode == "D" ? "日" :
    targetCode == "W" ? "周" :
    targetCode == "M" ? "月" :
    targetCode == "6M" ? "6个月" : "12个月") :
   manualTarget

// 进场/出场线配置
bool   showLine1   = input.bool(true,  "显示1号进场位", group="进场/出场位线", display=display.none)
float  level1_perc = input.float(50.0, "1号位百分比 (%)", minval=-100, maxval=200, step=0.5, group="进场/出场位线", display=display.none)
color  color1      = input.color(color.gray, "1号位颜色", group="进场/出场位线", display=display.none)
int    width1      = input.int(1, "1号位线宽", minval=1, maxval=3, group="进场/出场位线", display=display.none)
string style1_str  = input.string("点线", "1号位线型", options=["实线","虚线","点线"], group="进场/出场位线", display=display.none)

bool   showLine2   = input.bool(true,  "显示2号进场位", group="进场/出场位线", display=display.none)
float  level2_perc = input.float(62.0, "2号位百分比 (%)", minval=-100, maxval=200, step=0.5, group="进场/出场位线", display=display.none)
color  color2      = input.color(color.gray, "2号位颜色", group="进场/出场位线", display=display.none)
int    width2      = input.int(1, "2号位线宽", minval=1, maxval=3, group="进场/出场位线", display=display.none)
string style2_str  = input.string("点线", "2号位线型", options=["实线","虚线","点线"], group="进场/出场位线", display=display.none)

bool   showLine3   = input.bool(true,  "显示3号进场位", group="进场/出场位线", display=display.none)
float  level3_perc = input.float(72.0, "3号位百分比 (%)", minval=-100, maxval=200, step=0.5, group="进场/出场位线", display=display.none)
color  color3      = input.color(color.gray, "3号位颜色", group="进场/出场位线", display=display.none)
int    width3      = input.int(1, "3号位线宽", minval=1, maxval=3, group="进场/出场位线", display=display.none)
string style3_str  = input.string("点线", "3号位线型", options=["实线","虚线","点线"], group="进场/出场位线", display=display.none)

bool   showLine4   = input.bool(true,  "显示4号出场位", group="进场/出场位线", display=display.none)
float  level4_perc = input.float(-28.0, "4号位百分比 (%)", minval=-100, maxval=200, step=0.5, group="进场/出场位线", display=display.none)
color  color4      = input.color(color.blue, "4号位颜色", group="进场/出场位线", display=display.none)
int    width4      = input.int(1, "4号位线宽", minval=1, maxval=3, group="进场/出场位线", display=display.none)
string style4_str  = input.string("实线", "4号位线型", options=["实线","虚线","点线"], group="进场/出场位线", display=display.none)

// ------------------------------------------------------------
// 周期合理性检查
// ------------------------------------------------------------
getPeriodLevel(periodStr) =>
    if periodStr == "1" or periodStr == "3" or periodStr == "5"
        1
    else if periodStr == "15" or periodStr == "30" or periodStr == "45"
        2
    else if periodStr == "60" or periodStr == "1H"
        3
    else if periodStr == "120" or periodStr == "2H"
        4
    else if periodStr == "180" or periodStr == "3H"
        5
    else if periodStr == "240" or periodStr == "4H"
        6
    else if periodStr == "360" or periodStr == "6H"
        7
    else if periodStr == "720" or periodStr == "12H"
        8
    else if periodStr == "D" or periodStr == "1D"
        9
    else if periodStr == "W"
        10
    else if periodStr == "M"
        11
    else if periodStr == "3M"
        12
    else if periodStr == "6M"
        13
    else if periodStr == "12M"
        14
    else
        0

currentLevel = getPeriodLevel(timeframe.period)
targetLevel = getPeriodLevel(targetCode)
isValid = autoTarget or (targetLevel > currentLevel)

var table infoTable = table.new(position.top_right, 1, 2, bgcolor = color.new(color.black, 80))
if barstate.islast
    table.cell(infoTable, 0, 0, "目标周期: " + targetDisplay, text_color = color.white, text_size = size.small)
    if not isValid
        table.cell(infoTable, 0, 1, "错误：手动周期必须大于当前周期", text_color = color.red, text_size = size.small)

showBoxes = isValid

// ------------------------------------------------------------
// 获取高周期数据
// ------------------------------------------------------------
[htfOpen, htfHigh, htfLow, htfClose, htfTime, htfTimeClose] = request.security(
   syminfo.tickerid,
   targetCode,
   [open, high, low, close, time, time_close],
   lookahead = barmerge.lookahead_off,
   ignore_invalid_symbol = true
   )

var int lastHtfClose = na
bool isHtfEnd = not na(htfTimeClose) and (na(lastHtfClose) or htfTimeClose != lastHtfClose) and time_close >= htfTimeClose
if isHtfEnd
    lastHtfClose := htfTimeClose

int barMs = timeframe.in_seconds() * 1000
int rightTime = htfTimeClose - barMs

// ------------------------------------------------------------
// 绘制矩形和线
// ------------------------------------------------------------
if showBoxes and isHtfEnd and not na(htfTime) and not na(htfTimeClose)
    bool isUp = (htfClose >= htfOpen)
    float highPrice = htfHigh
    float lowPrice = htfLow
    float priceRange = highPrice - lowPrice

    if mode == "HL"
        color fillColor = isUp ? colorUpBody : colorDownBody
        box.new(left=htfTime, right=rightTime, top=highPrice, bottom=lowPrice,
                xloc=xloc.bar_time, bgcolor=fillColor, border_color=fillColor, extend=extend.none)
    else
        color bodyColor = isUp ? colorUpBody : colorDownBody
        box.new(left=htfTime, right=rightTime, top=math.max(htfOpen, htfClose), bottom=math.min(htfOpen, htfClose),
                xloc=xloc.bar_time, bgcolor=bodyColor, border_color=bodyColor, extend=extend.none)
        color wickColor = isUp ? colorUpWick : colorDownWick
        box.new(left=htfTime, right=rightTime, top=highPrice, bottom=lowPrice,
                xloc=xloc.bar_time, bgcolor=wickColor, border_color=wickColor, extend=extend.none)

    if showLine1
        float price1 = getLinePrice(level1_perc, isUp, highPrice, lowPrice)
        line.new(x1=htfTime, y1=price1, x2=rightTime, y2=price1,
                 xloc=xloc.bar_time, color=color1, width=width1, style=getLineStyle(style1_str), extend=extend.none)
    if showLine2
        float price2 = getLinePrice(level2_perc, isUp, highPrice, lowPrice)
        line.new(x1=htfTime, y1=price2, x2=rightTime, y2=price2,
                 xloc=xloc.bar_time, color=color2, width=width2, style=getLineStyle(style2_str), extend=extend.none)
    if showLine3
        float price3 = getLinePrice(level3_perc, isUp, highPrice, lowPrice)
        line.new(x1=htfTime, y1=price3, x2=rightTime, y2=price3,
                 xloc=xloc.bar_time, color=color3, width=width3, style=getLineStyle(style3_str), extend=extend.none)
    if showLine4
        float price4 = getLinePrice(level4_perc, isUp, highPrice, lowPrice)
        line.new(x1=htfTime, y1=price4, x2=rightTime, y2=price4,
                 xloc=xloc.bar_time, color=color4, width=width4, style=getLineStyle(style4_str), extend=extend.none)
````
