# Pullback + CHoCH Confirmation (By ShadowQuant Trader)

- url: https://www.tradingview.com/script/Orv6YUwk-Pullback-CHoCH-Confirmation-By-ShadowQuant-Trader/
- type: indicator
- pine_id: PUB;b37ded3a5c2545d8a6bad367736c7786
- version: 1.0

## Description

This indicator Helps you plot Recent Pullbacks in the market by ignoring inside bar, also this indicator shows the break of Structure or Change of character when recent pullbacks are broken.

This Indicator is designed by Shadow Quant Trader (Finweal Finance)

Credits : Prajyot Mahajan

## Source Code

````pine
//@version=6
indicator("Pullback + CHoCH Confirmation", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

pullbackColor = input.color(#000000, "Pullback Arrow Color")
pullbackSizeInput = input.string("Small", "Pullback Arrow Size", options=["Tiny", "Small", "Normal", "Large"])
pullbackOffsetTicks = input.int(4, "Pullback Arrow Distance (Ticks)", minval=1)
showPullbacks = input.bool(true, "Show Pullbacks")
showHighPullbacks = input.bool(true, "Mark High Pullbacks")
showLowPullbacks = input.bool(true, "Mark Low Pullbacks")

chochLineColor = input.color(#0000FF, "CHoCH Line Color")
chochTextColor = input.color(#000000, "CHoCH Text Color")
showChochLines = input.bool(true, "Show CHoCH Lines")
chochHistoryCount = input.int(5, "Past CHoCH Lines To Show", minval=1, maxval=50)
starColor = input.color(#FFD700, "Confirmation Star Color")
starSizeInput = input.string("Small", "Confirmation Star Size", options=["Tiny", "Small", "Normal", "Large"])
showChStars = input.bool(true, "Show CH Stars")
starHistoryCount = input.int(5, "Past CH Stars To Show", minval=1, maxval=50)

pullbackSize = switch pullbackSizeInput
    "Tiny" => size.tiny
    "Small" => size.small
    "Normal" => size.normal
    => size.large

starSize = switch starSizeInput
    "Tiny" => size.tiny
    "Small" => size.small
    "Normal" => size.normal
    => size.large

var bool motherInitialized = false
var float motherHigh = na
var float motherLow = na

var float lastRealHigh = na
var float lastRealLow = na

var bool highCandidateActive = false
var int highCandidateTime = na
var float highCandidateHigh = na
var float highLeftHigh = na

var bool lowCandidateActive = false
var int lowCandidateTime = na
var float lowCandidateLow = na
var float lowLeftLow = na

var float nearestPullbackHigh = na
var int nearestPullbackHighTime = na
var float nearestPullbackLow = na
var int nearestPullbackLowTime = na

var line highChochLine = na
var line lowChochLine = na
var box activeHighChochBox = na
var box activeLowChochBox = na

var array<line> confirmedChochLines = array.new_line()
var array<box> confirmedChochBoxes = array.new_box()
var array<label> confirmedStarLabels = array.new_label()

var bool highChochActive = false
var bool highTouched = false
var float highBreakBarrier = na

var bool lowChochActive = false
var bool lowTouched = false
var float lowBreakBarrier = na

isInsideBar = motherInitialized and high <= motherHigh and low >= motherLow

pullbackArrowDown(targetTime, targetHigh) =>
    label.new(
         x=targetTime,
         y=targetHigh + syminfo.mintick * pullbackOffsetTicks,
         text="",
         xloc=xloc.bar_time,
         yloc=yloc.price,
         style=label.style_arrowdown,
         color=pullbackColor,
         textcolor=pullbackColor,
         size=pullbackSize)

pullbackArrowUp(targetTime, targetLow) =>
    label.new(
         x=targetTime,
         y=targetLow - syminfo.mintick * pullbackOffsetTicks,
         text="",
         xloc=xloc.bar_time,
         yloc=yloc.price,
         style=label.style_arrowup,
         color=pullbackColor,
         textcolor=pullbackColor,
         size=pullbackSize)

plotStarAbove(targetTime, targetHigh) =>
    label.new(
         x=targetTime,
         y=targetHigh + syminfo.mintick * pullbackOffsetTicks,
         text="CH",
         xloc=xloc.bar_time,
         yloc=yloc.price,
         style=label.style_label_down,
         color=starColor,
         textcolor=#000000,
         size=starSize)

plotStarBelow(targetTime, targetLow) =>
    label.new(
         x=targetTime,
         y=targetLow - syminfo.mintick * pullbackOffsetTicks,
         text="CH",
         xloc=xloc.bar_time,
         yloc=yloc.price,
         style=label.style_label_up,
         color=starColor,
         textcolor=#000000,
         size=starSize)

buildChochBox(leftTime, rightTime, level) =>
    box.new(
         left=leftTime,
         right=rightTime,
         top=level + syminfo.mintick * 0.5,
         bottom=level - syminfo.mintick * 0.5,
         xloc=xloc.bar_time,
         border_color=color.new(chochLineColor, 100),
         bgcolor=color.new(#FFFFFF, 100),
         text="CHoCH",
         text_color=chochTextColor,
         text_size=size.tiny,
         text_halign=text.align_center,
         text_valign=text.align_center)

storeConfirmedChoch(confirmedLine, confirmedBox) =>
    if showChochLines and not na(confirmedLine) and not na(confirmedBox)
        array.push(confirmedChochLines, confirmedLine)
        array.push(confirmedChochBoxes, confirmedBox)
    visibleActiveChochCount = (showChochLines and not na(highChochLine) ? 1 : 0) + (showChochLines and not na(lowChochLine) ? 1 : 0)
    maxArchivedChoch = math.max(chochHistoryCount - visibleActiveChochCount, 0)
    while array.size(confirmedChochLines) > maxArchivedChoch
        oldLine = array.shift(confirmedChochLines)
        oldBox = array.shift(confirmedChochBoxes)
        line.delete(oldLine)
        box.delete(oldBox)

storeConfirmedStar(confirmedStarLabel) =>
    if showChStars and not na(confirmedStarLabel)
        array.push(confirmedStarLabels, confirmedStarLabel)
    while array.size(confirmedStarLabels) > starHistoryCount
        oldStarLabel = array.shift(confirmedStarLabels)
        if not na(oldStarLabel)
            label.delete(oldStarLabel)

if not showChochLines
    if not na(highChochLine)
        line.delete(highChochLine)
    if not na(lowChochLine)
        line.delete(lowChochLine)
    if not na(activeHighChochBox)
        box.delete(activeHighChochBox)
    if not na(activeLowChochBox)
        box.delete(activeLowChochBox)
    highChochLine := na
    lowChochLine := na
    activeHighChochBox := na
    activeLowChochBox := na
    while array.size(confirmedChochLines) > 0
        oldLine = array.shift(confirmedChochLines)
        line.delete(oldLine)
    while array.size(confirmedChochBoxes) > 0
        oldBox = array.shift(confirmedChochBoxes)
        box.delete(oldBox)

if not showChStars
    while array.size(confirmedStarLabels) > 0
        oldStar = array.shift(confirmedStarLabels)
        if not na(oldStar)
            label.delete(oldStar)

if not motherInitialized
    motherInitialized := true
    motherHigh := high
    motherLow := low
    lastRealHigh := high
    lastRealLow := low
else
    if not isInsideBar
        currentTime = time
        currentHigh = high
        currentLow = low

        if not highCandidateActive
            if currentHigh > lastRealHigh
                highCandidateActive := true
                highCandidateTime := currentTime
                highCandidateHigh := currentHigh
                highLeftHigh := lastRealHigh
        else
            if currentHigh < highCandidateHigh
                if showPullbacks and showHighPullbacks and highCandidateHigh > highLeftHigh
                    pullbackArrowDown(highCandidateTime, highCandidateHigh)
                previousHighTime = nearestPullbackHighTime
                previousHighPrice = nearestPullbackHigh
                nearestPullbackHigh := highCandidateHigh
                nearestPullbackHighTime := highCandidateTime
                if highChochActive and not na(highChochLine)
                    line.set_extend(highChochLine, extend.none)
                    line.set_x2(highChochLine, currentTime)
                    if showChochLines and not na(activeHighChochBox)
                        box.set_right(activeHighChochBox, currentTime)
                        box.set_top(activeHighChochBox, previousHighPrice + syminfo.mintick * 0.5)
                        box.set_bottom(activeHighChochBox, previousHighPrice - syminfo.mintick * 0.5)
                    storeConfirmedChoch(highChochLine, activeHighChochBox)
                highChochLine := showChochLines ? line.new(nearestPullbackHighTime, nearestPullbackHigh, time, nearestPullbackHigh, xloc=xloc.bar_time, extend=extend.right, color=chochLineColor, style=line.style_dotted, width=1) : line(na)
                activeHighChochBox := showChochLines ? buildChochBox(nearestPullbackHighTime, time, nearestPullbackHigh) : box(na)
                highChochActive := true
                highTouched := false
                highBreakBarrier := nearestPullbackHigh
                highCandidateActive := false
                if currentHigh > lastRealHigh
                    highCandidateActive := true
                    highCandidateTime := currentTime
                    highCandidateHigh := currentHigh
                    highLeftHigh := lastRealHigh
            else if currentHigh > highCandidateHigh
                highCandidateTime := currentTime
                highCandidateHigh := currentHigh
                highLeftHigh := lastRealHigh

        if not lowCandidateActive
            if currentLow < lastRealLow
                lowCandidateActive := true
                lowCandidateTime := currentTime
                lowCandidateLow := currentLow
                lowLeftLow := lastRealLow
        else
            if currentLow > lowCandidateLow
                if showPullbacks and showLowPullbacks and lowCandidateLow < lowLeftLow
                    pullbackArrowUp(lowCandidateTime, lowCandidateLow)
                previousLowTime = nearestPullbackLowTime
                previousLowPrice = nearestPullbackLow
                nearestPullbackLow := lowCandidateLow
                nearestPullbackLowTime := lowCandidateTime
                if lowChochActive and not na(lowChochLine)
                    line.set_extend(lowChochLine, extend.none)
                    line.set_x2(lowChochLine, currentTime)
                    if showChochLines and not na(activeLowChochBox)
                        box.set_right(activeLowChochBox, currentTime)
                        box.set_top(activeLowChochBox, previousLowPrice + syminfo.mintick * 0.5)
                        box.set_bottom(activeLowChochBox, previousLowPrice - syminfo.mintick * 0.5)
                    storeConfirmedChoch(lowChochLine, activeLowChochBox)
                lowChochLine := showChochLines ? line.new(nearestPullbackLowTime, nearestPullbackLow, time, nearestPullbackLow, xloc=xloc.bar_time, extend=extend.right, color=chochLineColor, style=line.style_dotted, width=1) : line(na)
                activeLowChochBox := showChochLines ? buildChochBox(nearestPullbackLowTime, time, nearestPullbackLow) : box(na)
                lowChochActive := true
                lowTouched := false
                lowBreakBarrier := nearestPullbackLow
                lowCandidateActive := false
                if currentLow < lastRealLow
                    lowCandidateActive := true
                    lowCandidateTime := currentTime
                    lowCandidateLow := currentLow
                    lowLeftLow := lastRealLow
            else if currentLow < lowCandidateLow
                lowCandidateTime := currentTime
                lowCandidateLow := currentLow
                lowLeftLow := lastRealLow

        lastRealHigh := currentHigh
        lastRealLow := currentLow
        motherHigh := currentHigh
        motherLow := currentLow

    if highChochActive
        if not na(highChochLine)
            line.set_x2(highChochLine, time)
        if showChochLines and not na(activeHighChochBox)
            box.set_right(activeHighChochBox, time)
            box.set_top(activeHighChochBox, nearestPullbackHigh + syminfo.mintick * 0.5)
            box.set_bottom(activeHighChochBox, nearestPullbackHigh - syminfo.mintick * 0.5)
        if not highTouched
            if high >= nearestPullbackHigh
                if close > highBreakBarrier
                    confirmedHighStar = showChStars ? plotStarAbove(time, high) : label(na)
                    if not na(highChochLine)
                        line.set_extend(highChochLine, extend.none)
                        line.set_x2(highChochLine, time)
                    confirmedHighBox = showChochLines ? (na(activeHighChochBox) ? buildChochBox(nearestPullbackHighTime, time, nearestPullbackHigh) : activeHighChochBox) : box(na)
                    storeConfirmedChoch(highChochLine, confirmedHighBox)
                    storeConfirmedStar(confirmedHighStar)
                    highChochActive := false
                    highChochLine := na
                    activeHighChochBox := na
                else if high > highBreakBarrier
                    highTouched := true
                    highBreakBarrier := high
        else
            if close > highBreakBarrier
                confirmedHighStar = showChStars ? plotStarAbove(time, high) : label(na)
                if not na(highChochLine)
                    line.set_extend(highChochLine, extend.none)
                    line.set_x2(highChochLine, time)
                confirmedHighBox = showChochLines ? (na(activeHighChochBox) ? buildChochBox(nearestPullbackHighTime, time, nearestPullbackHigh) : activeHighChochBox) : box(na)
                storeConfirmedChoch(highChochLine, confirmedHighBox)
                storeConfirmedStar(confirmedHighStar)
                highChochActive := false
                highChochLine := na
                activeHighChochBox := na
            else if high > highBreakBarrier
                highBreakBarrier := high

    if lowChochActive
        if not na(lowChochLine)
            line.set_x2(lowChochLine, time)
        if showChochLines and not na(activeLowChochBox)
            box.set_right(activeLowChochBox, time)
            box.set_top(activeLowChochBox, nearestPullbackLow + syminfo.mintick * 0.5)
            box.set_bottom(activeLowChochBox, nearestPullbackLow - syminfo.mintick * 0.5)
        if not lowTouched
            if low <= nearestPullbackLow
                if close < lowBreakBarrier
                    confirmedLowStar = showChStars ? plotStarBelow(time, low) : label(na)
                    if not na(lowChochLine)
                        line.set_extend(lowChochLine, extend.none)
                        line.set_x2(lowChochLine, time)
                    confirmedLowBox = showChochLines ? (na(activeLowChochBox) ? buildChochBox(nearestPullbackLowTime, time, nearestPullbackLow) : activeLowChochBox) : box(na)
                    storeConfirmedChoch(lowChochLine, confirmedLowBox)
                    storeConfirmedStar(confirmedLowStar)
                    lowChochActive := false
                    lowChochLine := na
                    activeLowChochBox := na
                else if low < lowBreakBarrier
                    lowTouched := true
                    lowBreakBarrier := low
        else
            if close < lowBreakBarrier
                confirmedLowStar = showChStars ? plotStarBelow(time, low) : label(na)
                if not na(lowChochLine)
                    line.set_extend(lowChochLine, extend.none)
                    line.set_x2(lowChochLine, time)
                confirmedLowBox = showChochLines ? (na(activeLowChochBox) ? buildChochBox(nearestPullbackLowTime, time, nearestPullbackLow) : activeLowChochBox) : box(na)
                storeConfirmedChoch(lowChochLine, confirmedLowBox)
                storeConfirmedStar(confirmedLowStar)
                lowChochActive := false
                lowChochLine := na
                activeLowChochBox := na
            else if low < lowBreakBarrier
                lowBreakBarrier := low
````
