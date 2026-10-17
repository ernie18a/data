# Silver Bullet Sessions + Session FVGs

- url: https://www.tradingview.com/script/6JjkOgpC-Silver-Bullet-Sessions-Session-FVGs/
- type: indicator
- pine_id: PUB;5e7f6e55b58d4f95892ba0e9b9c117a4
- version: 1.0

## Description

If you are trading the Silver Bullet Hours this indicator is right for you. You can fully customize every Session which are London Session and New York Am and PM Session. it displays the FVG inside and it even gives alerts when one is created. I created this indicator within one day with ChatGPT to help me visualize the Silver Bullet Hours. Mistakes can be included I am open for your opinions.

## Source Code

````pine
//@version=6
indicator("Silver Bullet Sessions + Session FVGs", overlay=true, max_lines_count=500, max_boxes_count=500)

// Inputs
daysBack = input.int(20, "Back Days to Show", minval=1, maxval=80)
tz       = input.string("UTC-4", "Session Timezone", options=["UTC-4", "America/New_York"])

// Sessions
showLondon = input.bool(true, "London Silver Bullet 03:00–04:00")
showNYAM   = input.bool(true, "New York AM Silver Bullet 10:00–11:00")
showNYPM   = input.bool(true, "New York PM Silver Bullet 14:00–15:00")

// Session Backgrounds
showSessionBg = input.bool(true, "Show Session Background")
londonBgColor = input.color(color.new(color.blue, 90), "London Background Color")
nyAmBgColor   = input.color(color.new(color.green, 90), "NY AM Background Color")
nyPmBgColor   = input.color(color.new(color.orange, 90), "NY PM Background Color")

// Lines
lineColorLondon = input.color(color.new(color.blue, 0), "London Line Color")
lineColorNYAM   = input.color(color.new(color.green, 0), "NY AM Line Color")
lineColorNYPM   = input.color(color.new(color.orange, 0), "NY PM Line Color")

lineStyleInput = input.string("Dashed", "Line Style", options=["Solid", "Dashed", "Dotted"])
lineWidth      = input.int(1, "Line Width", minval=1, maxval=5)

// FVG Settings
showFVGs        = input.bool(true, "Show Fair Value Gaps")
showBullishFVG  = input.bool(true, "Show Bullish FVGs")
showBearishFVG  = input.bool(true, "Show Bearish FVGs")
fvgLengthBars   = input.int(6, "FVG Length in Candles", minval=1, maxval=50)
deleteMitigated = input.bool(true, "Delete FVG When Body Fully Mitigates")

bullFvgColor   = input.color(color.green, "Bullish FVG Color")
bearFvgColor   = input.color(color.red, "Bearish FVG Color")
fvgTransp      = input.int(80, "FVG Transparency", minval=0, maxval=100)
fvgBorderColor = input.color(color.new(color.gray, 70), "FVG Border Color")

// Alerts
enableAlerts = input.bool(true, "Enable FVG Alerts")
alertBullish = input.bool(true, "Alert Bullish FVG")
alertBearish = input.bool(true, "Alert Bearish FVG")

// Basics
style = lineStyleInput == "Solid" ? line.style_solid :
     lineStyleInput == "Dotted" ? line.style_dotted :
     line.style_dashed

msInDay = 24 * 60 * 60 * 1000
cutoff  = timenow - (daysBack + 1) * msInDay
allowed = time >= cutoff

londonSession = "0300-0400:23456"
nyAmSession   = "1000-1100:23456"
nyPmSession   = "1400-1500:23456"

fullBgTop    = 10000000000.0
fullBgBottom = -10000000000.0

// Session background boxes
var box londonBgBox = na
var box nyAmBgBox   = na
var box nyPmBgBox   = na

// FVG arrays
var box[] bullBoxes = array.new_box()
var float[] bullTops = array.new_float()
var float[] bullBottoms = array.new_float()

var box[] bearBoxes = array.new_box()
var float[] bearTops = array.new_float()
var float[] bearBottoms = array.new_float()

// Session Lines
drawSessionLines(sessionStr, enabled, clr) =>
    inSession = not na(time(timeframe.period, sessionStr, tz))
    startSess = enabled and allowed and inSession and not inSession[1]
    endSess   = enabled and allowed and not inSession and inSession[1]

    if startSess
        line.new(time, fullBgBottom, time, fullBgTop, xloc=xloc.bar_time, color=clr, style=style, width=lineWidth)

    if endSess
        line.new(time, fullBgBottom, time, fullBgTop, xloc=xloc.bar_time, color=clr, style=style, width=lineWidth)

// Session Background
updateSessionBackground(sessionStr, enabled, bgBox, bgColor) =>
    inSession  = not na(time(timeframe.period, sessionStr, tz))
    startSess  = enabled and allowed and showSessionBg and inSession and not inSession[1]
    activeSess = enabled and allowed and showSessionBg and inSession

    newBgBox = bgBox

    if startSess
        newBgBox := box.new(
             left=time,
             top=fullBgTop,
             right=time_close,
             bottom=fullBgBottom,
             xloc=xloc.bar_time,
             bgcolor=bgColor,
             border_color=color.new(bgColor, 100)
        )

    if activeSess and not na(newBgBox)
        box.set_right(newBgBox, time_close)
        box.set_top(newBgBox, fullBgTop)
        box.set_bottom(newBgBox, fullBgBottom)

    newBgBox

// FVGs
drawFVGs(sessionStr, enabled) =>
    inSession = not na(time(timeframe.period, sessionStr, tz))
    validSession = enabled and showFVGs and allowed and inSession and inSession[1] and inSession[2]

    bullishFVG = barstate.isconfirmed and validSession and showBullishFVG and low > high[2]
    bearishFVG = barstate.isconfirmed and validSession and showBearishFVG and high < low[2]

    if bullishFVG
        topLevel = low
        bottomLevel = high[2]

        b = box.new(
             left=bar_index - 2,
             top=topLevel,
             right=bar_index + fvgLengthBars,
             bottom=bottomLevel,
             bgcolor=color.new(bullFvgColor, fvgTransp),
             border_color=fvgBorderColor
        )

        array.push(bullBoxes, b)
        array.push(bullTops, topLevel)
        array.push(bullBottoms, bottomLevel)

    if bearishFVG
        topLevel = low[2]
        bottomLevel = high

        b = box.new(
             left=bar_index - 2,
             top=topLevel,
             right=bar_index + fvgLengthBars,
             bottom=bottomLevel,
             bgcolor=color.new(bearFvgColor, fvgTransp),
             border_color=fvgBorderColor
        )

        array.push(bearBoxes, b)
        array.push(bearTops, topLevel)
        array.push(bearBottoms, bottomLevel)

    [bullishFVG, bearishFVG]

// Mitigation by full candle body through FVG
if deleteMitigated
    bodyHigh = math.max(open, close)
    bodyLow  = math.min(open, close)

    bullCount = array.size(bullBoxes)
    if bullCount > 0
        for i = bullCount - 1 to 0
            bullBox = array.get(bullBoxes, i)
            bullTop = array.get(bullTops, i)
            bullBottom = array.get(bullBottoms, i)

            if bodyHigh >= bullTop and bodyLow <= bullBottom
                box.delete(bullBox)
                array.remove(bullBoxes, i)
                array.remove(bullTops, i)
                array.remove(bullBottoms, i)

    bearCount = array.size(bearBoxes)
    if bearCount > 0
        for i = bearCount - 1 to 0
            bearBox = array.get(bearBoxes, i)
            bearTop = array.get(bearTops, i)
            bearBottom = array.get(bearBottoms, i)

            if bodyHigh >= bearTop and bodyLow <= bearBottom
                box.delete(bearBox)
                array.remove(bearBoxes, i)
                array.remove(bearTops, i)
                array.remove(bearBottoms, i)

// Draw session backgrounds
londonBgBox := updateSessionBackground(londonSession, showLondon, londonBgBox, londonBgColor)
nyAmBgBox   := updateSessionBackground(nyAmSession, showNYAM, nyAmBgBox, nyAmBgColor)
nyPmBgBox   := updateSessionBackground(nyPmSession, showNYPM, nyPmBgBox, nyPmBgColor)

// Draw session lines
drawSessionLines(londonSession, showLondon, lineColorLondon)
drawSessionLines(nyAmSession, showNYAM, lineColorNYAM)
drawSessionLines(nyPmSession, showNYPM, lineColorNYPM)

// Draw FVGs
[londonBull, londonBear] = drawFVGs(londonSession, showLondon)
[nyAmBull, nyAmBear]     = drawFVGs(nyAmSession, showNYAM)
[nyPmBull, nyPmBear]     = drawFVGs(nyPmSession, showNYPM)

// Alerts
bullishAlert = enableAlerts and alertBullish and (londonBull or nyAmBull or nyPmBull)
bearishAlert = enableAlerts and alertBearish and (londonBear or nyAmBear or nyPmBear)
anyFvgAlert  = bullishAlert or bearishAlert

alertcondition(bullishAlert, "Bullish Session FVG Created", "Bullish FVG created inside an active Silver Bullet Session.")
alertcondition(bearishAlert, "Bearish Session FVG Created", "Bearish FVG created inside an active Silver Bullet Session.")
alertcondition(anyFvgAlert, "Any Session FVG Created", "FVG created inside an active Silver Bullet Session.")
````
