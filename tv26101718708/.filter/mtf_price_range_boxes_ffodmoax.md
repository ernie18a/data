# MTF Price Range Boxes

- url: https://www.tradingview.com/script/FFodmoaX/
- type: indicator
- pine_id: PUB;94273bf374104595ab18d6734c45478a
- version: 1.0

## Description

新增背景色功能（基于北京时间，强制UTC+8，不依赖图表时区）：

周末（灰90）

亚洲盘 08:00–16:00（浅蓝95）

亚欧重叠 16:00–18:00（浅青绿92）

欧洲盘 18:00–20:00（浅橙88）

欧美重叠 20:00–24:00（红80）

美洲盘 00:00–08:00（浅紫85）

## Source Code

````pine
//@version=6
indicator("MTF Price Range Boxes [v5]", overlay=true)

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
// 交易时段背景色（强制使用北京时间，不依赖图表时区）
// ------------------------------------------------------------
getSessionColor(openTime, swWeekend, swAsia, swAsiaEuro, swEurope, swUSEuro, swUS) =>
    int beijingTimestamp = openTime + 8 * 60 * 60 * 1000
    int hourVal = hour(beijingTimestamp)
    int minuteVal = minute(beijingTimestamp)
    float timeOfDay = hourVal + minuteVal / 60.0
    int dow = dayofweek(beijingTimestamp)

    if (dow == dayofweek.saturday or dow == dayofweek.sunday) and swWeekend
        color.new(color.gray, 90)
    else if timeOfDay >= 8.0 and timeOfDay < 16.0 and swAsia
        color.new(color.blue, 95)
    else if timeOfDay >= 16.0 and timeOfDay < 18.0 and swAsiaEuro
        color.new(color.teal, 92)
    else if timeOfDay >= 18.0 and timeOfDay < 20.0 and swEurope
        color.new(color.orange, 88)
    else if timeOfDay >= 20.0 and timeOfDay < 24.0 and swUSEuro
        color.new(color.red, 80)
    else if timeOfDay >= 0.0 and timeOfDay < 8.0 and swUS
        color.new(color.purple, 85)
    else
        color(na)

// ------------------------------------------------------------
// 用户输入配置（全部隐藏）
// ------------------------------------------------------------
string mode = input.string("HL", "价格范围模式", options=["HL", "OHLC"], group="模式设置", display=display.none)
color colorUpBody   = input.color(color.new(color.orange, 80), "上涨实体颜色", group="颜色设置", display=display.none)
color colorUpWick   = input.color(color.new(color.orange, 90), "上涨影线颜色", group="颜色设置", display=display.none)
color colorDownBody = input.color(color.new(color.gray,  80), "下跌实体颜色", group="颜色设置", display=display.none)
color colorDownWick = input.color(color.new(color.gray,  90), "下跌影线颜色", group="颜色设置", display=display.none)

bool autoTarget = input.bool(true, "自动周期", group="周期设置", display=display.none)
string manualTarget = input.string("1小时", "手动设置目标周期", options=["1小时", "4小时", "日", "周"], group="周期设置", display=display.none)

bool showSessionBg = input.bool(true, "显示时段背景", group="背景设置", display=display.none, tooltip="显示北京时间交易时段背景色。已强制使用UTC+8，无需调整图表时区。")

bool showWeekend = input.bool(true, "显示周末背景", group="周期设置", display=display.none)
bool showAsia    = input.bool(true, "显示亚洲盘背景", group="周期设置", display=display.none)
bool showAsiaEuro = input.bool(true, "显示亚欧重叠背景", group="周期设置", display=display.none)
bool showEurope  = input.bool(true, "显示欧洲盘背景", group="周期设置", display=display.none)
bool showUSEuro  = input.bool(true, "显示欧美重叠背景", group="周期设置", display=display.none)
bool showUS      = input.bool(true, "显示美洲盘背景", group="周期设置", display=display.none)

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

// 右上角表格：增加第3行用于调试信息
var table infoTable = table.new(position.top_right, 1, 3, bgcolor = color.new(color.black, 80))

if barstate.islast
    table.cell(infoTable, 0, 0, "目标周期: " + targetDisplay, text_color = color.white, text_size = size.small)
    if not isValid
        table.cell(infoTable, 0, 1, "错误：手动周期必须大于当前周期", text_color = color.red, text_size = size.small)
    else
        // 调试信息：显示当前K线的北京时间时段
        int beijingTimestamp = time + 8 * 60 * 60 * 1000
        int hourCN = hour(beijingTimestamp)
        int minuteCN = minute(beijingTimestamp)
        int dowCN = dayofweek(beijingTimestamp)
        float timeOfDayCN = hourCN + minuteCN / 60.0
        string sessionName = ""
        if dowCN == dayofweek.saturday or dowCN == dayofweek.sunday
            sessionName := "周末"
        else if timeOfDayCN >= 8.0 and timeOfDayCN < 16.0
            sessionName := "亚洲盘"
        else if timeOfDayCN >= 16.0 and timeOfDayCN < 18.0
            sessionName := "亚欧重叠"
        else if timeOfDayCN >= 18.0 and timeOfDayCN < 20.0
            sessionName := "欧洲盘"
        else if timeOfDayCN >= 20.0 and timeOfDayCN < 24.0
            sessionName := "欧美重叠"
        else if timeOfDayCN >= 0.0 and timeOfDayCN < 8.0
            sessionName := "美洲盘"
        else
            sessionName := "未知"
        string debugMsg = "调试: 北京时间 " + str.tostring(hourCN) + ":" + str.tostring(minuteCN) + " 周" + str.tostring(dowCN) + " " + sessionName
        table.cell(infoTable, 0, 2, debugMsg, text_color = color.white, text_size = size.small)

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

// 绘制背景色
bgcolor(
    showSessionBg ? getSessionColor(time, showWeekend, showAsia, showAsiaEuro, showEurope, showUSEuro, showUS) : color(na),
    title="时段背景", editable=false)

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
