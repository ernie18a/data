# jettB

- url: https://www.tradingview.com/script/GqtQUKKC/
- type: indicator
- pine_id: PUB;0084cac903b34d24b3774f72a40eb97e
- version: 1.0

## Description

jettB专用指标

## Source Code

````pine
//@version=6
indicator(
     title="Multi Anchored VWAP - Lite Symbol Lock",
     shorttitle="Multi A-VWAP Lite",
     overlay=true,
     max_lines_count=20,
     max_bars_back=5000
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Symbol Lock Settings
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SYMBOL_GROUP = "Symbol Lock Settings"

lockedSymbol = input.string(
     "MNQ1!",
     "Lock This Indicator To",
     options=["Any", "MGC1!", "MNQ1!", "MES1!"],
     group=SYMBOL_GROUP,
     tooltip="选择该 VWAP 指标只在哪个品种显示。选择 Any 则所有品种都显示。"
)

showLockHint = input.bool(
     true,
     "Show Lock Hint",
     group=SYMBOL_GROUP
)

currentSymbol = syminfo.ticker
symbolAllowed = lockedSymbol == "Any" or currentSymbol == lockedSymbol

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// General Settings
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
GENERAL_GROUP = "General Settings"

vwapCount = input.int(
     1,
     "VWAP Count",
     minval=1,
     maxval=5,
     group=GENERAL_GROUP,
     tooltip="选择当前指标显示几条 VWAP，最多 5 条。"
)

src = input.source(hlc3, "Source", group=GENERAL_GROUP)

hideonDWM = input.bool(
     false,
     "Hide VWAP on 1D or Above",
     group=GENERAL_GROUP
)

offset = input.int(
     0,
     "Offset",
     group=GENERAL_GROUP
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VWAP #1
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
VWAP1_GROUP = "VWAP #1"

anchorTime1 = input.time(
     defval=0,
     title="Anchor Time #1",
     group=VWAP1_GROUP,
     confirm=true,
     tooltip="首次添加或修改时，在图表上点击 VWAP #1 的锚定K线。"
)

vwapColor1 = input.color(#2962FF, "Color #1", group=VWAP1_GROUP)
vwapWidth1 = input.int(2, "Width #1", minval=1, maxval=5, group=VWAP1_GROUP)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VWAP #2
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
VWAP2_GROUP = "VWAP #2"

anchorTime2 = input.time(
     defval=0,
     title="Anchor Time #2",
     group=VWAP2_GROUP,
     confirm=true,
     tooltip="在图表上点击 VWAP #2 的锚定K线。"
)

vwapColor2 = input.color(#F23645, "Color #2", group=VWAP2_GROUP)
vwapWidth2 = input.int(2, "Width #2", minval=1, maxval=5, group=VWAP2_GROUP)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VWAP #3
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
VWAP3_GROUP = "VWAP #3"

anchorTime3 = input.time(
     defval=0,
     title="Anchor Time #3",
     group=VWAP3_GROUP,
     confirm=true,
     tooltip="在图表上点击 VWAP #3 的锚定K线。"
)

vwapColor3 = input.color(#089981, "Color #3", group=VWAP3_GROUP)
vwapWidth3 = input.int(2, "Width #3", minval=1, maxval=5, group=VWAP3_GROUP)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VWAP #4
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
VWAP4_GROUP = "VWAP #4"

anchorTime4 = input.time(
     defval=0,
     title="Anchor Time #4",
     group=VWAP4_GROUP,
     confirm=true,
     tooltip="在图表上点击 VWAP #4 的锚定K线。"
)

vwapColor4 = input.color(#FF9800, "Color #4", group=VWAP4_GROUP)
vwapWidth4 = input.int(2, "Width #4", minval=1, maxval=5, group=VWAP4_GROUP)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VWAP #5
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
VWAP5_GROUP = "VWAP #5"

anchorTime5 = input.time(
     defval=0,
     title="Anchor Time #5",
     group=VWAP5_GROUP,
     confirm=true,
     tooltip="在图表上点击 VWAP #5 的锚定K线。"
)

vwapColor5 = input.color(#9C27B0, "Color #5", group=VWAP5_GROUP)
vwapWidth5 = input.int(2, "Width #5", minval=1, maxval=5, group=VWAP5_GROUP)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Visual Settings
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
VISUAL_GROUP = "Visual Settings"

showAnchorLine = input.bool(
     true,
     "Show Anchor Vertical Lines",
     group=VISUAL_GROUP,
     tooltip="只显示锚定竖线，不显示圆点。竖线不占用 plot。"
)

anchorLineTransp = input.int(
     65,
     "Anchor Line Transparency",
     minval=0,
     maxval=100,
     group=VISUAL_GROUP
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Lock Hint Table
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table lockHintTable = na

if barstate.islast
    if showLockHint
        if na(lockHintTable)
            lockHintTable := table.new(position.top_right, 1, 1, border_width=1)

        string hintText = ""
        color hintBg = color.new(color.black, 15)

        if symbolAllowed
            hintText := "Multi VWAP 已显示\n当前品种: " + currentSymbol + "\n锁定品种: " + lockedSymbol + "\nVWAP 数量: " + str.tostring(vwapCount)
            hintBg := color.new(color.green, 15)
        else
            hintText := "Multi VWAP 已隐藏\n当前品种: " + currentSymbol + "\n锁定品种: " + lockedSymbol
            hintBg := color.new(color.red, 15)

        table.cell(
             lockHintTable,
             0,
             0,
             hintText,
             text_color=color.white,
             bgcolor=hintBg,
             text_size=size.small
        )
    else
        if not na(lockHintTable)
            table.delete(lockHintTable)
            lockHintTable := na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Volume Check
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vol = nz(volume)
cumVolumeAll = ta.cum(vol)

use1 = vwapCount >= 1
use2 = vwapCount >= 2
use3 = vwapCount >= 3
use4 = vwapCount >= 4
use5 = vwapCount >= 5

hasAnyAnchor =
     (use1 and anchorTime1 > 0) or
     (use2 and anchorTime2 > 0) or
     (use3 and anchorTime3 > 0) or
     (use4 and anchorTime4 > 0) or
     (use5 and anchorTime5 > 0)

if barstate.islast and symbolAllowed and hasAnyAnchor and cumVolumeAll == 0
    runtime.error("No volume is provided by the data vendor.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Global Cumulative Values
// 用全局累计值计算每条 Anchored VWAP，减少重复逻辑
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
cumPVAll = ta.cum(src * vol)
cumVAll = ta.cum(vol)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Anchored VWAP Function
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_avwap(_anchorTime, _enabled) =>
    bool _hasAnchor = _anchorTime > 0
    bool _canShow = symbolAllowed and _enabled and _hasAnchor and not (hideonDWM and timeframe.isdwm)

    bool _barContainsAnchor = _hasAnchor and time <= _anchorTime and time_close > _anchorTime
    bool _isActive = _canShow and (time >= _anchorTime or _barContainsAnchor)

    bool _prevActive = _isActive[1] == true
    bool _isAnchorBar = _isActive and not _prevActive

    float _basePV = ta.valuewhen(_isAnchorBar, nz(cumPVAll[1], 0.0), 0)
    float _baseV = ta.valuewhen(_isAnchorBar, nz(cumVAll[1], 0.0), 0)

    float _cumPV = _isActive ? cumPVAll - nz(_basePV, 0.0) : na
    float _cumV = _isActive ? cumVAll - nz(_baseV, 0.0) : na

    float _vwap = na

    if not na(_cumV) and _cumV > 0
        _vwap := _cumPV / _cumV

    int _anchorBarTime = ta.valuewhen(_isAnchorBar, time, 0)

    [_vwap, _anchorBarTime]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Calculate VWAPs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[vwap1, anchorBarTime1] = f_avwap(anchorTime1, use1)
[vwap2, anchorBarTime2] = f_avwap(anchorTime2, use2)
[vwap3, anchorBarTime3] = f_avwap(anchorTime3, use3)
[vwap4, anchorBarTime4] = f_avwap(anchorTime4, use4)
[vwap5, anchorBarTime5] = f_avwap(anchorTime5, use5)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Plot VWAP Lines
// 最多只占用 5 个 plot
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(
     vwap1,
     title="VWAP #1",
     color=vwapColor1,
     linewidth=vwapWidth1,
     offset=offset,
     style=plot.style_linebr
)

plot(
     vwap2,
     title="VWAP #2",
     color=vwapColor2,
     linewidth=vwapWidth2,
     offset=offset,
     style=plot.style_linebr
)

plot(
     vwap3,
     title="VWAP #3",
     color=vwapColor3,
     linewidth=vwapWidth3,
     offset=offset,
     style=plot.style_linebr
)

plot(
     vwap4,
     title="VWAP #4",
     color=vwapColor4,
     linewidth=vwapWidth4,
     offset=offset,
     style=plot.style_linebr
)

plot(
     vwap5,
     title="VWAP #5",
     color=vwapColor5,
     linewidth=vwapWidth5,
     offset=offset,
     style=plot.style_linebr
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Anchor Vertical Lines
// 不使用圆点，不使用 label
// 竖线使用 line.new，不占用 plot
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var line anchorLine1 = na
var line anchorLine2 = na
var line anchorLine3 = na
var line anchorLine4 = na
var line anchorLine5 = na

if barstate.islast
    if not na(anchorLine1)
        line.delete(anchorLine1)
        anchorLine1 := na
    if not na(anchorLine2)
        line.delete(anchorLine2)
        anchorLine2 := na
    if not na(anchorLine3)
        line.delete(anchorLine3)
        anchorLine3 := na
    if not na(anchorLine4)
        line.delete(anchorLine4)
        anchorLine4 := na
    if not na(anchorLine5)
        line.delete(anchorLine5)
        anchorLine5 := na

    if symbolAllowed and showAnchorLine and use1 and anchorTime1 > 0 and not na(anchorBarTime1)
        anchorLine1 := line.new(
             x1=anchorBarTime1,
             y1=low,
             x2=anchorBarTime1,
             y2=high,
             xloc=xloc.bar_time,
             extend=extend.both,
             color=color.new(vwapColor1, anchorLineTransp),
             style=line.style_dashed,
             width=1
        )

    if symbolAllowed and showAnchorLine and use2 and anchorTime2 > 0 and not na(anchorBarTime2)
        anchorLine2 := line.new(
             x1=anchorBarTime2,
             y1=low,
             x2=anchorBarTime2,
             y2=high,
             xloc=xloc.bar_time,
             extend=extend.both,
             color=color.new(vwapColor2, anchorLineTransp),
             style=line.style_dashed,
             width=1
        )

    if symbolAllowed and showAnchorLine and use3 and anchorTime3 > 0 and not na(anchorBarTime3)
        anchorLine3 := line.new(
             x1=anchorBarTime3,
             y1=low,
             x2=anchorBarTime3,
             y2=high,
             xloc=xloc.bar_time,
             extend=extend.both,
             color=color.new(vwapColor3, anchorLineTransp),
             style=line.style_dashed,
             width=1
        )

    if symbolAllowed and showAnchorLine and use4 and anchorTime4 > 0 and not na(anchorBarTime4)
        anchorLine4 := line.new(
             x1=anchorBarTime4,
             y1=low,
             x2=anchorBarTime4,
             y2=high,
             xloc=xloc.bar_time,
             extend=extend.both,
             color=color.new(vwapColor4, anchorLineTransp),
             style=line.style_dashed,
             width=1
        )

    if symbolAllowed and showAnchorLine and use5 and anchorTime5 > 0 and not na(anchorBarTime5)
        anchorLine5 := line.new(
             x1=anchorBarTime5,
             y1=low,
             x2=anchorBarTime5,
             y2=high,
             xloc=xloc.bar_time,
             extend=extend.both,
             color=color.new(vwapColor5, anchorLineTransp),
             style=line.style_dashed,
             width=1
        )
````
