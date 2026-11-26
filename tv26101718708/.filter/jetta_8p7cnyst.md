# jettA

- url: https://www.tradingview.com/script/8P7CnYST/
- type: indicator
- pine_id: PUB;77b00c393a714cbf8902e92f7e65082a
- version: 1.0

## Description

jettA专用指标

## Source Code

````pine
//@version=6
indicator(
     title="Draggable Range Anchored VWAP",
     shorttitle="Range A-VWAP",
     overlay=true,
     max_labels_count=50,
     max_lines_count=50
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Anchor Settings
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ANCHOR_GROUP = "Anchor Settings"

startTime = input.time(
     defval=0,
     title="Start Point",
     group=ANCHOR_GROUP,
     confirm=true,
     tooltip="选择VWAP计算起点。该锚点只使用时间，不绑定价格，因此切换品种后更稳定。"
)

updateEndToLatest = input.bool(
     false,
     title="Update End To Latest Bar",
     group=ANCHOR_GROUP,
     tooltip="开启后，终点自动更新至最新K线；关闭后，使用手动选择的终点。"
)

endTime = input.time(
     defval=0,
     title="End Point",
     group=ANCHOR_GROUP,
     confirm=true,
     active=not updateEndToLatest,
     tooltip="选择VWAP计算终点。若开启“Update End To Latest Bar”，该终点会被最新K线替代。"
)

src = input.source(hlc3, "Source", group=ANCHOR_GROUP)
hideonDWM = input.bool(false, "Hide VWAP on 1D or Above", group=ANCHOR_GROUP)
offset = input.int(0, "Offset", group=ANCHOR_GROUP)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Display Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DISPLAY_GROUP = "Display Logic"

drawMode = input.string(
     "VWAP线段",
     "Draw Mode",
     options=["VWAP线段", "起终点直线", "两者都显示"],
     group=DISPLAY_GROUP,
     tooltip="VWAP线段：显示起点到终点之间的VWAP；起终点直线：只画起点VWAP到终点VWAP的直线；两者都显示：同时显示VWAP与直线。"
)

straightExtendMode = input.string(
     "不延伸",
     "Straight Line Extend",
     options=["不延伸", "向右延伸"],
     group=DISPLAY_GROUP,
     active=drawMode != "VWAP线段"
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Bands Settings
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
BANDS_GROUP = "Bands Settings"

calcModeInput = input.string(
     "Standard Deviation",
     "Bands Calculation Mode",
     options=["Standard Deviation", "Percentage"],
     group=BANDS_GROUP
)

showBand_1 = input.bool(true, "", group=BANDS_GROUP, inline="band_1")
bandMult_1 = input.float(1.0, "Bands Multiplier #1", group=BANDS_GROUP, inline="band_1", step=0.5, minval=0)

showBand_2 = input.bool(false, "", group=BANDS_GROUP, inline="band_2")
bandMult_2 = input.float(2.0, "Bands Multiplier #2", group=BANDS_GROUP, inline="band_2", step=0.5, minval=0)

showBand_3 = input.bool(false, "", group=BANDS_GROUP, inline="band_3")
bandMult_3 = input.float(3.0, "Bands Multiplier #3", group=BANDS_GROUP, inline="band_3", step=0.5, minval=0)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Visual Settings
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
VISUAL_GROUP = "Visual Settings"

vwapColor = input.color(#2962FF, "VWAP Color", group=VISUAL_GROUP)
vwapWidth = input.int(2, "VWAP Width", minval=1, maxval=5, group=VISUAL_GROUP)

straightColor = input.color(color.orange, "Straight Line Color", group=VISUAL_GROUP)
straightWidth = input.int(2, "Straight Line Width", minval=1, maxval=5, group=VISUAL_GROUP)

showAnchorCircle = input.bool(true, "Show Anchor Circles", group=VISUAL_GROUP)
showAnchorLine = input.bool(true, "Show Anchor Vertical Lines", group=VISUAL_GROUP)
anchorColor = input.color(color.red, "Anchor Color", group=VISUAL_GROUP)

bandColor1 = input.color(color.green, "Band #1 Color", group=VISUAL_GROUP)
bandColor2 = input.color(color.olive, "Band #2 Color", group=VISUAL_GROUP)
bandColor3 = input.color(color.teal, "Band #3 Color", group=VISUAL_GROUP)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Volume Check
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
cumVolumeAll = ta.cum(nz(volume))

if barstate.islast and cumVolumeAll == 0
    runtime.error("No volume is provided by the data vendor.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Range Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
hasStart = startTime > 0
hasManualEnd = endTime > 0
hasEnd = updateEndToLatest or hasManualEnd

canShow = hasStart and hasEnd and not (hideonDWM and timeframe.isdwm)

// 如果手动终点早于起点，则自动取较早者为计算起点、较晚者为计算终点
int rangeStart = na
int rangeEnd = na

if canShow
    if updateEndToLatest
        rangeStart := startTime
        rangeEnd := time_close
    else
        rangeStart := math.min(startTime, endTime)
        rangeEnd := math.max(startTime, endTime)

// 起点落在某根K线内部时，也从这根K线开始算
barContainsStart = canShow and time <= rangeStart and time_close > rangeStart

isAfterStart = canShow and (time >= rangeStart or barContainsStart)
isBeforeEnd = canShow and (updateEndToLatest ? true : time <= rangeEnd)

isActive = canShow and isAfterStart and isBeforeEnd

prevActive = isActive[1] == true
isStartBar = isActive and not prevActive

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Anchored VWAP Calculation
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vol = nz(volume)

var float cumPV = na
var float cumV = na
var float cumPV2 = na

if isStartBar
    cumPV := src * vol
    cumV := vol
    cumPV2 := src * src * vol
else if isActive
    cumPV := nz(cumPV) + src * vol
    cumV := nz(cumV) + vol
    cumPV2 := nz(cumPV2) + src * src * vol
else
    cumPV := na
    cumV := na
    cumPV2 := na

float vwapValue = na
float bandBasis = na

if not na(cumV) and cumV > 0
    vwapValue := cumPV / cumV

    variance = math.max(cumPV2 / cumV - vwapValue * vwapValue, 0.0)
    stdevAbs = math.sqrt(variance)

    bandBasis := calcModeInput == "Standard Deviation" ? stdevAbs : vwapValue * 0.01

upperBandValue1 = not na(vwapValue) ? vwapValue + bandBasis * bandMult_1 : na
lowerBandValue1 = not na(vwapValue) ? vwapValue - bandBasis * bandMult_1 : na

upperBandValue2 = not na(vwapValue) ? vwapValue + bandBasis * bandMult_2 : na
lowerBandValue2 = not na(vwapValue) ? vwapValue - bandBasis * bandMult_2 : na

upperBandValue3 = not na(vwapValue) ? vwapValue + bandBasis * bandMult_3 : na
lowerBandValue3 = not na(vwapValue) ? vwapValue - bandBasis * bandMult_3 : na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Store Start / End Coordinates
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var int startBarTime = na
var float startBarPrice = na
var float startBarVwap = na

var int endBarTime = na
var float endBarPrice = na
var float endBarVwap = na

if isStartBar and not na(vwapValue)
    startBarTime := time
    startBarPrice := close
    startBarVwap := vwapValue

if isActive and not na(vwapValue)
    endBarTime := time
    endBarPrice := close
    endBarVwap := vwapValue

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Plots
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showVwapCurve = drawMode == "VWAP线段" or drawMode == "两者都显示"
showStraightLine = drawMode == "起终点直线" or drawMode == "两者都显示"

plotVwapValue = showVwapCurve ? vwapValue : na

plot(
     plotVwapValue,
     title="Range Anchored VWAP",
     color=vwapColor,
     linewidth=vwapWidth,
     offset=offset,
     style=plot.style_linebr
)

displayBand1 = showVwapCurve and showBand_1 ? display.all : display.none
upperBand_1 = plot(upperBandValue1, title="Upper Band #1", color=bandColor1, offset=offset, display=displayBand1, style=plot.style_linebr)
lowerBand_1 = plot(lowerBandValue1, title="Lower Band #1", color=bandColor1, offset=offset, display=displayBand1, style=plot.style_linebr)
fill(upperBand_1, lowerBand_1, title="Bands Fill #1", color=color.new(bandColor1, 90), display=displayBand1)

displayBand2 = showVwapCurve and showBand_2 ? display.all : display.none
upperBand_2 = plot(upperBandValue2, title="Upper Band #2", color=bandColor2, offset=offset, display=displayBand2, style=plot.style_linebr)
lowerBand_2 = plot(lowerBandValue2, title="Lower Band #2", color=bandColor2, offset=offset, display=displayBand2, style=plot.style_linebr)
fill(upperBand_2, lowerBand_2, title="Bands Fill #2", color=color.new(bandColor2, 92), display=displayBand2)

displayBand3 = showVwapCurve and showBand_3 ? display.all : display.none
upperBand_3 = plot(upperBandValue3, title="Upper Band #3", color=bandColor3, offset=offset, display=displayBand3, style=plot.style_linebr)
lowerBand_3 = plot(lowerBandValue3, title="Lower Band #3", color=bandColor3, offset=offset, display=displayBand3, style=plot.style_linebr)
fill(upperBand_3, lowerBand_3, title="Bands Fill #3", color=color.new(bandColor3, 94), display=displayBand3)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Anchor Markers & Straight Line
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var label startCircle = na
var label endCircle = na

var line startVerticalLine = na
var line endVerticalLine = na
var line straightLine = na

if barstate.islast
    if not na(startCircle)
        label.delete(startCircle)
        startCircle := na

    if not na(endCircle)
        label.delete(endCircle)
        endCircle := na

    if not na(startVerticalLine)
        line.delete(startVerticalLine)
        startVerticalLine := na

    if not na(endVerticalLine)
        line.delete(endVerticalLine)
        endVerticalLine := na

    if not na(straightLine)
        line.delete(straightLine)
        straightLine := na

    // 起点圆圈
    if showAnchorCircle and not na(startBarTime) and not na(startBarPrice)
        startCircle := label.new(
             x=startBarTime,
             y=startBarPrice,
             text="S",
             xloc=xloc.bar_time,
             yloc=yloc.price,
             style=label.style_circle,
             color=anchorColor,
             textcolor=color.white,
             size=size.small
        )

    // 终点圆圈
    if showAnchorCircle and not na(endBarTime) and not na(endBarPrice)
        endCircle := label.new(
             x=endBarTime,
             y=endBarPrice,
             text=updateEndToLatest ? "L" : "E",
             xloc=xloc.bar_time,
             yloc=yloc.price,
             style=label.style_circle,
             color=color.new(anchorColor, 0),
             textcolor=color.white,
             size=size.small
        )

    // 起点垂直线
    if showAnchorLine and not na(startBarTime)
        startVerticalLine := line.new(
             x1=startBarTime,
             y1=low,
             x2=startBarTime,
             y2=high,
             xloc=xloc.bar_time,
             extend=extend.both,
             color=color.new(anchorColor, 65),
             style=line.style_dashed,
             width=1
        )

    // 终点垂直线
    if showAnchorLine and not na(endBarTime)
        endVerticalLine := line.new(
             x1=endBarTime,
             y1=low,
             x2=endBarTime,
             y2=high,
             xloc=xloc.bar_time,
             extend=extend.both,
             color=color.new(anchorColor, 75),
             style=line.style_dotted,
             width=1
        )

    // 起点VWAP到终点VWAP的直线
    if showStraightLine and not na(startBarTime) and not na(endBarTime) and not na(startBarVwap) and not na(endBarVwap)
        straightLine := line.new(
             x1=startBarTime,
             y1=startBarVwap,
             x2=endBarTime,
             y2=endBarVwap,
             xloc=xloc.bar_time,
             extend=straightExtendMode == "向右延伸" ? extend.right : extend.none,
             color=straightColor,
             width=straightWidth,
             style=line.style_solid
        )
````
