<!-- tradingview-pine-id: PUB;8a5e27099cee406287ec1681dc0cf9f4 -->
<!-- tradingviewscripts-format: 1 -->
# TTG Brick Strategy — Auto Extend

Source: https://www.tradingview.com/script/ZHwNoT5V-TTG-Brick-Strategy-Auto-Extend/

## Description

Trading Goddess TTG Brick Strategy:

This is a measured move indicator that projects that exact measured range into equal-sized price bricks above and below.

It has 3 rectangles that block out the average true range of the overnight high and low for day trading.  

It has toggle 1: for day trading
Toggle 2: for Overnight futures trading:

Alerts added to help you see where price is headed:

---

## Source Code

````pine
//@version=6
indicator("TTG Brick Strategy — Auto Extend", overlay=true, max_boxes_count=200, max_lines_count=10)

//=====================================================================
// TIME ZONE
//=====================================================================
string TZ = "America/New_York"

//=====================================================================
// 1. RANGE SETTINGS
//=====================================================================
groupRanges = "1. RANGE SETTINGS"

showON = input.bool(
     true,
     "Toggle 1 — 4PM → 9:30AM",
     group=groupRanges,
     tooltip="Measures the high/low from 4:00 PM ET through 9:29 AM ET."
)

showRTH = input.bool(
     false,
     "Toggle 2 — 9:30AM → 4PM",
     group=groupRanges,
     tooltip="Measures the regular-session high/low from 9:30 AM through 4:00 PM ET."
)

maxContinuationBricks = input.int(
     6,
     "Max Continuation Bricks Per Side",
     minval=1,
     maxval=12,
     group=groupRanges,
     tooltip="After price closes beyond the outer brick, another equal-size brick is stacked in that direction."
)

//=====================================================================
// 2. BOX APPEARANCE
//=====================================================================
groupBox = "2. BOX APPEARANCE"

centerColor = input.color(
     color.rgb(205, 235, 245),
     "Center Rectangle",
     group=groupBox
)

upperInactiveColor = input.color(
     color.rgb(185, 215, 190),
     "Upper Rectangle",
     group=groupBox
)

lowerInactiveColor = input.color(
     color.rgb(245, 190, 205),
     "Lower Rectangle",
     group=groupBox
)

upperActiveColor = input.color(
     color.green,
     "Upper ACTIVE Color",
     group=groupBox
)

lowerActiveColor = input.color(
     color.red,
     "Lower ACTIVE Color",
     group=groupBox
)

boxTransparency = input.int(
     78,
     "Normal Transparency",
     minval=0,
     maxval=100,
     group=groupBox
)

activeTransparency = input.int(
     68,
     "Active Transparency",
     minval=0,
     maxval=100,
     group=groupBox
)

borderColor = input.color(
     color.black,
     "Border Color",
     group=groupBox
)

borderWidth = input.int(
     2,
     "Border Width",
     minval=1,
     maxval=5,
     group=groupBox
)

//=====================================================================
// 3. MIDLINE SETTINGS
//=====================================================================
groupMid = "3. MIDLINE"

showMidline = input.bool(
     true,
     "Show Rectangle Midlines",
     group=groupMid
)

midlineColor = input.color(
     color.red,
     "Midline Color",
     group=groupMid
)

midlineTicks = input.int(
     3,
     "Midline Thickness",
     minval=1,
     maxval=20,
     group=groupMid
)

float midThickness = syminfo.mintick * midlineTicks
float halfMidThickness = midThickness / 2.0

//=====================================================================
// 4. ALERT SETTINGS
//=====================================================================
groupAlerts = "4. ALERT SETTINGS"

enableAlerts = input.bool(
     true,
     "Enable Alerts",
     group=groupAlerts
)

alertOnClose = input.bool(
     true,
     "Require Candle Close",
     group=groupAlerts,
     tooltip="ON = candle must close across the level."
)

//=====================================================================
// SESSION LOGIC
//=====================================================================
int hh = hour(time, TZ)
int mm = minute(time, TZ)

bool after1600 = hh >= 16

bool before0930 =
     hh < 9 or
     (hh == 9 and mm < 30)

bool atOrAfter0930 =
     hh > 9 or
     (hh == 9 and mm >= 30)

bool before1600 = hh < 16

bool inOvernight =
     after1600 or before0930

bool inRTH =
     atOrAfter0930 and before1600

bool overnightStart =
     inOvernight and not inOvernight[1]

bool rthStart =
     inRTH and not inRTH[1]

bool onRangeLocked =
     showON and not inOvernight

bool rthRangeLocked =
     showRTH and not inRTH and after1600

bool breakoutConfirmed =
     not alertOnClose or barstate.isconfirmed

//=====================================================================
// DELETE ARRAY FUNCTION
//=====================================================================
f_delete_boxes(array<box> boxes) =>
    int n = array.size(boxes)

    if n > 0
        for i = 0 to n - 1
            box b = array.get(boxes, i)

            if not na(b)
                box.delete(b)

    array.clear(boxes)

//=====================================================================
// TOGGLE 1 VARIABLES
//=====================================================================
var float onHigh = na
var float onLow = na
var int onLeft = na

var box onUpperBox = na
var box onCenterBox = na
var box onLowerBox = na

var box onUpperMidBox = na
var box onCenterMidBox = na
var box onLowerMidBox = na

var array<box> onUpExtBoxes = array.new<box>()
var array<box> onDnExtBoxes = array.new<box>()

var array<box> onUpExtMidBoxes = array.new<box>()
var array<box> onDnExtMidBoxes = array.new<box>()

//=====================================================================
// TOGGLE 2 VARIABLES
//=====================================================================
var float rthHigh = na
var float rthLow = na
var int rthLeft = na

var box rthUpperBox = na
var box rthCenterBox = na
var box rthLowerBox = na

var box rthUpperMidBox = na
var box rthCenterMidBox = na
var box rthLowerMidBox = na

var array<box> rthUpExtBoxes = array.new<box>()
var array<box> rthDnExtBoxes = array.new<box>()

var array<box> rthUpExtMidBoxes = array.new<box>()
var array<box> rthDnExtMidBoxes = array.new<box>()

//#####################################################################
//#####################################################################
// TOGGLE 1 — OVERNIGHT RANGE
//#####################################################################
//#####################################################################

//=====================================================================
// START NEW OVERNIGHT RANGE
//=====================================================================
if overnightStart

    if not na(onUpperBox)
        box.delete(onUpperBox)

    if not na(onCenterBox)
        box.delete(onCenterBox)

    if not na(onLowerBox)
        box.delete(onLowerBox)

    if not na(onUpperMidBox)
        box.delete(onUpperMidBox)

    if not na(onCenterMidBox)
        box.delete(onCenterMidBox)

    if not na(onLowerMidBox)
        box.delete(onLowerMidBox)

    f_delete_boxes(onUpExtBoxes)
    f_delete_boxes(onDnExtBoxes)

    f_delete_boxes(onUpExtMidBoxes)
    f_delete_boxes(onDnExtMidBoxes)

    onUpperBox := na
    onCenterBox := na
    onLowerBox := na

    onUpperMidBox := na
    onCenterMidBox := na
    onLowerMidBox := na

    onHigh := high
    onLow := low
    onLeft := time

//=====================================================================
// MEASURE OVERNIGHT
//=====================================================================
if inOvernight

    if na(onHigh)
        onHigh := high

    if na(onLow)
        onLow := low

    if na(onLeft)
        onLeft := time

    onHigh := math.max(onHigh, high)
    onLow := math.min(onLow, low)

//=====================================================================
// DRAW OVERNIGHT STRUCTURE
//=====================================================================
if showON and not na(onHigh) and not na(onLow)

    float onRange = onHigh - onLow

    if onRange > 0

        //-------------------------------------------------------------
        // ORIGINAL THREE BRICKS
        //-------------------------------------------------------------
        float onUpperTop = onHigh + onRange
        float onUpperBottom = onHigh
        float onUpperMid = onHigh + onRange / 2.0

        float onCenterTop = onHigh
        float onCenterBottom = onLow
        float onCenterMid = onLow + onRange / 2.0

        float onLowerTop = onLow
        float onLowerBottom = onLow - onRange
        float onLowerMid = onLow - onRange / 2.0

        //-------------------------------------------------------------
        // CREATE ORIGINAL BRICKS
        //-------------------------------------------------------------
        if na(onCenterBox)

            onUpperBox := box.new(
                 left=onLeft,
                 top=onUpperTop,
                 right=time,
                 bottom=onUpperBottom,
                 xloc=xloc.bar_time,
                 extend=extend.right,
                 border_color=borderColor,
                 border_width=borderWidth,
                 bgcolor=color.new(upperInactiveColor, boxTransparency)
            )

            onCenterBox := box.new(
                 left=onLeft,
                 top=onCenterTop,
                 right=time,
                 bottom=onCenterBottom,
                 xloc=xloc.bar_time,
                 extend=extend.right,
                 border_color=borderColor,
                 border_width=borderWidth,
                 bgcolor=color.new(centerColor, boxTransparency)
            )

            onLowerBox := box.new(
                 left=onLeft,
                 top=onLowerTop,
                 right=time,
                 bottom=onLowerBottom,
                 xloc=xloc.bar_time,
                 extend=extend.right,
                 border_color=borderColor,
                 border_width=borderWidth,
                 bgcolor=color.new(lowerInactiveColor, boxTransparency)
            )

        //-------------------------------------------------------------
        // UPDATE WHILE MEASURING
        //-------------------------------------------------------------
        if inOvernight

            box.set_top(onUpperBox, onUpperTop)
            box.set_bottom(onUpperBox, onUpperBottom)

            box.set_top(onCenterBox, onCenterTop)
            box.set_bottom(onCenterBox, onCenterBottom)

            box.set_top(onLowerBox, onLowerTop)
            box.set_bottom(onLowerBox, onLowerBottom)

        //-------------------------------------------------------------
        // ORIGINAL MIDLINES
        //-------------------------------------------------------------
        if showMidline

            if na(onUpperMidBox)

                onUpperMidBox := box.new(
                     left=onLeft,
                     top=onUpperMid + halfMidThickness,
                     right=time,
                     bottom=onUpperMid - halfMidThickness,
                     xloc=xloc.bar_time,
                     extend=extend.right,
                     border_color=midlineColor,
                     border_width=1,
                     bgcolor=midlineColor
                )

            else

                box.set_top(
                     onUpperMidBox,
                     onUpperMid + halfMidThickness
                )

                box.set_bottom(
                     onUpperMidBox,
                     onUpperMid - halfMidThickness
                )

            if na(onCenterMidBox)

                onCenterMidBox := box.new(
                     left=onLeft,
                     top=onCenterMid + halfMidThickness,
                     right=time,
                     bottom=onCenterMid - halfMidThickness,
                     xloc=xloc.bar_time,
                     extend=extend.right,
                     border_color=midlineColor,
                     border_width=1,
                     bgcolor=midlineColor
                )

            else

                box.set_top(
                     onCenterMidBox,
                     onCenterMid + halfMidThickness
                )

                box.set_bottom(
                     onCenterMidBox,
                     onCenterMid - halfMidThickness
                )

            if na(onLowerMidBox)

                onLowerMidBox := box.new(
                     left=onLeft,
                     top=onLowerMid + halfMidThickness,
                     right=time,
                     bottom=onLowerMid - halfMidThickness,
                     xloc=xloc.bar_time,
                     extend=extend.right,
                     border_color=midlineColor,
                     border_width=1,
                     bgcolor=midlineColor
                )

            else

                box.set_top(
                     onLowerMidBox,
                     onLowerMid + halfMidThickness
                )

                box.set_bottom(
                     onLowerMidBox,
                     onLowerMid - halfMidThickness
                )

        else

            if not na(onUpperMidBox)
                box.delete(onUpperMidBox)
                onUpperMidBox := na

            if not na(onCenterMidBox)
                box.delete(onCenterMidBox)
                onCenterMidBox := na

            if not na(onLowerMidBox)
                box.delete(onLowerMidBox)
                onLowerMidBox := na

            f_delete_boxes(onUpExtMidBoxes)
            f_delete_boxes(onDnExtMidBoxes)

        //-------------------------------------------------------------
        // ORIGINAL ACTIVE COLORS
        //-------------------------------------------------------------
        bool onPriceInUpper =
             close >= onUpperBottom and
             close <= onUpperTop

        bool onPriceInLower =
             close >= onLowerBottom and
             close <= onLowerTop

        box.set_bgcolor(
             onUpperBox,
             onPriceInUpper
                 ? color.new(upperActiveColor, activeTransparency)
                 : color.new(upperInactiveColor, boxTransparency)
        )

        box.set_bgcolor(
             onCenterBox,
             color.new(centerColor, boxTransparency)
        )

        box.set_bgcolor(
             onLowerBox,
             onPriceInLower
                 ? color.new(lowerActiveColor, activeTransparency)
                 : color.new(lowerInactiveColor, boxTransparency)
        )

        //=============================================================
        // UPSIDE AUTO-EXTENSION
        //=============================================================
        if onRangeLocked and breakoutConfirmed

            int currentUpCount = array.size(onUpExtBoxes)

            float nextUpBreak =
                 onUpperTop +
                 onRange * currentUpCount

            if close > nextUpBreak and
               currentUpCount < maxContinuationBricks

                float newBottom = nextUpBreak
                float newTop = newBottom + onRange
                float newMid = newBottom + onRange / 2.0

                box newUpBox = box.new(
                     left=onLeft,
                     top=newTop,
                     right=time,
                     bottom=newBottom,
                     xloc=xloc.bar_time,
                     extend=extend.right,
                     border_color=borderColor,
                     border_width=borderWidth,
                     bgcolor=color.new(
                          upperActiveColor,
                          activeTransparency
                     )
                )

                array.push(
                     onUpExtBoxes,
                     newUpBox
                )

                if showMidline

                    box newUpMid = box.new(
                         left=onLeft,
                         top=newMid + halfMidThickness,
                         right=time,
                         bottom=newMid - halfMidThickness,
                         xloc=xloc.bar_time,
                         extend=extend.right,
                         border_color=midlineColor,
                         border_width=1,
                         bgcolor=midlineColor
                    )

                    array.push(
                         onUpExtMidBoxes,
                         newUpMid
                    )

        //=============================================================
        // DOWNSIDE AUTO-EXTENSION
        //=============================================================
        if onRangeLocked and breakoutConfirmed

            int currentDnCount = array.size(onDnExtBoxes)

            float nextDnBreak =
                 onLowerBottom -
                 onRange * currentDnCount

            if close < nextDnBreak and
               currentDnCount < maxContinuationBricks

                float newTop = nextDnBreak
                float newBottom = newTop - onRange
                float newMid = newBottom + onRange / 2.0

                box newDnBox = box.new(
                     left=onLeft,
                     top=newTop,
                     right=time,
                     bottom=newBottom,
                     xloc=xloc.bar_time,
                     extend=extend.right,
                     border_color=borderColor,
                     border_width=borderWidth,
                     bgcolor=color.new(
                          lowerActiveColor,
                          activeTransparency
                     )
                )

                array.push(
                     onDnExtBoxes,
                     newDnBox
                )

                if showMidline

                    box newDnMid = box.new(
                         left=onLeft,
                         top=newMid + halfMidThickness,
                         right=time,
                         bottom=newMid - halfMidThickness,
                         xloc=xloc.bar_time,
                         extend=extend.right,
                         border_color=midlineColor,
                         border_width=1,
                         bgcolor=midlineColor
                    )

                    array.push(
                         onDnExtMidBoxes,
                         newDnMid
                    )

        //=============================================================
        // UPDATE UPSIDE EXTENSION COLORS
        //=============================================================
        int onUpCount = array.size(onUpExtBoxes)

        if onUpCount > 0

            for i = 0 to onUpCount - 1

                box b = array.get(
                     onUpExtBoxes,
                     i
                )

                float bBottom =
                     onUpperTop +
                     onRange * i

                float bTop =
                     bBottom + onRange

                bool inside =
                     close >= bBottom and
                     close <= bTop

                box.set_bgcolor(
                     b,
                     inside
                         ? color.new(
                              upperActiveColor,
                              activeTransparency
                           )
                         : color.new(
                              upperInactiveColor,
                              boxTransparency
                           )
                )

        //=============================================================
        // UPDATE DOWNSIDE EXTENSION COLORS
        //=============================================================
        int onDnCount = array.size(onDnExtBoxes)

        if onDnCount > 0

            for i = 0 to onDnCount - 1

                box b = array.get(
                     onDnExtBoxes,
                     i
                )

                float bTop =
                     onLowerBottom -
                     onRange * i

                float bBottom =
                     bTop - onRange

                bool inside =
                     close >= bBottom and
                     close <= bTop

                box.set_bgcolor(
                     b,
                     inside
                         ? color.new(
                              lowerActiveColor,
                              activeTransparency
                           )
                         : color.new(
                              lowerInactiveColor,
                              boxTransparency
                           )
                )

//#####################################################################
//#####################################################################
// TOGGLE 2 — REGULAR SESSION RANGE
//#####################################################################
//#####################################################################

//=====================================================================
// START NEW RTH RANGE
//=====================================================================
if rthStart

    if not na(rthUpperBox)
        box.delete(rthUpperBox)

    if not na(rthCenterBox)
        box.delete(rthCenterBox)

    if not na(rthLowerBox)
        box.delete(rthLowerBox)

    if not na(rthUpperMidBox)
        box.delete(rthUpperMidBox)

    if not na(rthCenterMidBox)
        box.delete(rthCenterMidBox)

    if not na(rthLowerMidBox)
        box.delete(rthLowerMidBox)

    f_delete_boxes(rthUpExtBoxes)
    f_delete_boxes(rthDnExtBoxes)

    f_delete_boxes(rthUpExtMidBoxes)
    f_delete_boxes(rthDnExtMidBoxes)

    rthUpperBox := na
    rthCenterBox := na
    rthLowerBox := na

    rthUpperMidBox := na
    rthCenterMidBox := na
    rthLowerMidBox := na

    rthHigh := high
    rthLow := low
    rthLeft := time

//=====================================================================
// MEASURE RTH
//=====================================================================
if inRTH

    if na(rthHigh)
        rthHigh := high

    if na(rthLow)
        rthLow := low

    if na(rthLeft)
        rthLeft := time

    rthHigh := math.max(rthHigh, high)
    rthLow := math.min(rthLow, low)

//=====================================================================
// DRAW RTH STRUCTURE
//=====================================================================
if showRTH and not na(rthHigh) and not na(rthLow)

    float rthRange = rthHigh - rthLow

    if rthRange > 0

        //-------------------------------------------------------------
        // ORIGINAL THREE BRICKS
        //-------------------------------------------------------------
        float rthUpperTop =
             rthHigh + rthRange

        float rthUpperBottom =
             rthHigh

        float rthUpperMid =
             rthHigh + rthRange / 2.0


        float rthCenterTop =
             rthHigh

        float rthCenterBottom =
             rthLow

        float rthCenterMid =
             rthLow + rthRange / 2.0


        float rthLowerTop =
             rthLow

        float rthLowerBottom =
             rthLow - rthRange

        float rthLowerMid =
             rthLow - rthRange / 2.0

        //-------------------------------------------------------------
        // CREATE ORIGINAL BRICKS
        //-------------------------------------------------------------
        if na(rthCenterBox)

            rthUpperBox := box.new(
                 left=rthLeft,
                 top=rthUpperTop,
                 right=time,
                 bottom=rthUpperBottom,
                 xloc=xloc.bar_time,
                 extend=extend.right,
                 border_color=borderColor,
                 border_width=borderWidth,
                 bgcolor=color.new(
                      upperInactiveColor,
                      boxTransparency
                 )
            )

            rthCenterBox := box.new(
                 left=rthLeft,
                 top=rthCenterTop,
                 right=time,
                 bottom=rthCenterBottom,
                 xloc=xloc.bar_time,
                 extend=extend.right,
                 border_color=borderColor,
                 border_width=borderWidth,
                 bgcolor=color.new(
                      centerColor,
                      boxTransparency
                 )
            )

            rthLowerBox := box.new(
                 left=rthLeft,
                 top=rthLowerTop,
                 right=time,
                 bottom=rthLowerBottom,
                 xloc=xloc.bar_time,
                 extend=extend.right,
                 border_color=borderColor,
                 border_width=borderWidth,
                 bgcolor=color.new(
                      lowerInactiveColor,
                      boxTransparency
                 )
            )

        //-------------------------------------------------------------
        // UPDATE DURING RTH
        //-------------------------------------------------------------
        if inRTH

            box.set_top(
                 rthUpperBox,
                 rthUpperTop
            )

            box.set_bottom(
                 rthUpperBox,
                 rthUpperBottom
            )

            box.set_top(
                 rthCenterBox,
                 rthCenterTop
            )

            box.set_bottom(
                 rthCenterBox,
                 rthCenterBottom
            )

            box.set_top(
                 rthLowerBox,
                 rthLowerTop
            )

            box.set_bottom(
                 rthLowerBox,
                 rthLowerBottom
            )

        //-------------------------------------------------------------
        // RTH MIDLINES
        //-------------------------------------------------------------
        if showMidline

            if na(rthUpperMidBox)

                rthUpperMidBox := box.new(
                     left=rthLeft,
                     top=rthUpperMid + halfMidThickness,
                     right=time,
                     bottom=rthUpperMid - halfMidThickness,
                     xloc=xloc.bar_time,
                     extend=extend.right,
                     border_color=midlineColor,
                     border_width=1,
                     bgcolor=midlineColor
                )

            else

                box.set_top(
                     rthUpperMidBox,
                     rthUpperMid + halfMidThickness
                )

                box.set_bottom(
                     rthUpperMidBox,
                     rthUpperMid - halfMidThickness
                )

            if na(rthCenterMidBox)

                rthCenterMidBox := box.new(
                     left=rthLeft,
                     top=rthCenterMid + halfMidThickness,
                     right=time,
                     bottom=rthCenterMid - halfMidThickness,
                     xloc=xloc.bar_time,
                     extend=extend.right,
                     border_color=midlineColor,
                     border_width=1,
                     bgcolor=midlineColor
                )

            else

                box.set_top(
                     rthCenterMidBox,
                     rthCenterMid + halfMidThickness
                )

                box.set_bottom(
                     rthCenterMidBox,
                     rthCenterMid - halfMidThickness
                )

            if na(rthLowerMidBox)

                rthLowerMidBox := box.new(
                     left=rthLeft,
                     top=rthLowerMid + halfMidThickness,
                     right=time,
                     bottom=rthLowerMid - halfMidThickness,
                     xloc=xloc.bar_time,
                     extend=extend.right,
                     border_color=midlineColor,
                     border_width=1,
                     bgcolor=midlineColor
                )

            else

                box.set_top(
                     rthLowerMidBox,
                     rthLowerMid + halfMidThickness
                )

                box.set_bottom(
                     rthLowerMidBox,
                     rthLowerMid - halfMidThickness
                )

        else

            if not na(rthUpperMidBox)
                box.delete(rthUpperMidBox)
                rthUpperMidBox := na

            if not na(rthCenterMidBox)
                box.delete(rthCenterMidBox)
                rthCenterMidBox := na

            if not na(rthLowerMidBox)
                box.delete(rthLowerMidBox)
                rthLowerMidBox := na

            f_delete_boxes(rthUpExtMidBoxes)
            f_delete_boxes(rthDnExtMidBoxes)

        //-------------------------------------------------------------
        // ORIGINAL ACTIVE COLORS
        //-------------------------------------------------------------
        bool rthPriceInUpper =
             close >= rthUpperBottom and
             close <= rthUpperTop

        bool rthPriceInLower =
             close >= rthLowerBottom and
             close <= rthLowerTop

        box.set_bgcolor(
             rthUpperBox,
             rthPriceInUpper
                 ? color.new(
                      upperActiveColor,
                      activeTransparency
                   )
                 : color.new(
                      upperInactiveColor,
                      boxTransparency
                   )
        )

        box.set_bgcolor(
             rthCenterBox,
             color.new(
                  centerColor,
                  boxTransparency
             )
        )

        box.set_bgcolor(
             rthLowerBox,
             rthPriceInLower
                 ? color.new(
                      lowerActiveColor,
                      activeTransparency
                   )
                 : color.new(
                      lowerInactiveColor,
                      boxTransparency
                   )
        )

        //=============================================================
        // RTH UPSIDE AUTO-EXTENSION
        //=============================================================
        if rthRangeLocked and breakoutConfirmed

            int currentUpCount =
                 array.size(rthUpExtBoxes)

            float nextUpBreak =
                 rthUpperTop +
                 rthRange * currentUpCount

            if close > nextUpBreak and
               currentUpCount < maxContinuationBricks

                float newBottom =
                     nextUpBreak

                float newTop =
                     newBottom + rthRange

                float newMid =
                     newBottom + rthRange / 2.0

                box newUpBox = box.new(
                     left=rthLeft,
                     top=newTop,
                     right=time,
                     bottom=newBottom,
                     xloc=xloc.bar_time,
                     extend=extend.right,
                     border_color=borderColor,
                     border_width=borderWidth,
                     bgcolor=color.new(
                          upperActiveColor,
                          activeTransparency
                     )
                )

                array.push(
                     rthUpExtBoxes,
                     newUpBox
                )

                if showMidline

                    box newUpMid = box.new(
                         left=rthLeft,
                         top=newMid + halfMidThickness,
                         right=time,
                         bottom=newMid - halfMidThickness,
                         xloc=xloc.bar_time,
                         extend=extend.right,
                         border_color=midlineColor,
                         border_width=1,
                         bgcolor=midlineColor
                    )

                    array.push(
                         rthUpExtMidBoxes,
                         newUpMid
                    )

        //=============================================================
        // RTH DOWNSIDE AUTO-EXTENSION
        //=============================================================
        if rthRangeLocked and breakoutConfirmed

            int currentDnCount =
                 array.size(rthDnExtBoxes)

            float nextDnBreak =
                 rthLowerBottom -
                 rthRange * currentDnCount

            if close < nextDnBreak and
               currentDnCount < maxContinuationBricks

                float newTop =
                     nextDnBreak

                float newBottom =
                     newTop - rthRange

                float newMid =
                     newBottom + rthRange / 2.0

                box newDnBox = box.new(
                     left=rthLeft,
                     top=newTop,
                     right=time,
                     bottom=newBottom,
                     xloc=xloc.bar_time,
                     extend=extend.right,
                     border_color=borderColor,
                     border_width=borderWidth,
                     bgcolor=color.new(
                          lowerActiveColor,
                          activeTransparency
                     )
                )

                array.push(
                     rthDnExtBoxes,
                     newDnBox
                )

                if showMidline

                    box newDnMid = box.new(
                         left=rthLeft,
                         top=newMid + halfMidThickness,
                         right=time,
                         bottom=newMid - halfMidThickness,
                         xloc=xloc.bar_time,
                         extend=extend.right,
                         border_color=midlineColor,
                         border_width=1,
                         bgcolor=midlineColor
                    )

                    array.push(
                         rthDnExtMidBoxes,
                         newDnMid
                    )

        //=============================================================
        // RTH UPSIDE EXTENSION COLORS
        //=============================================================
        int rthUpCount =
             array.size(rthUpExtBoxes)

        if rthUpCount > 0

            for i = 0 to rthUpCount - 1

                box b =
                     array.get(
                          rthUpExtBoxes,
                          i
                     )

                float bBottom =
                     rthUpperTop +
                     rthRange * i

                float bTop =
                     bBottom + rthRange

                bool inside =
                     close >= bBottom and
                     close <= bTop

                box.set_bgcolor(
                     b,
                     inside
                         ? color.new(
                              upperActiveColor,
                              activeTransparency
                           )
                         : color.new(
                              upperInactiveColor,
                              boxTransparency
                           )
                )

        //=============================================================
        // RTH DOWNSIDE EXTENSION COLORS
        //=============================================================
        int rthDnCount =
             array.size(rthDnExtBoxes)

        if rthDnCount > 0

            for i = 0 to rthDnCount - 1

                box b =
                     array.get(
                          rthDnExtBoxes,
                          i
                     )

                float bTop =
                     rthLowerBottom -
                     rthRange * i

                float bBottom =
                     bTop - rthRange

                bool inside =
                     close >= bBottom and
                     close <= bTop

                box.set_bgcolor(
                     b,
                     inside
                         ? color.new(
                              lowerActiveColor,
                              activeTransparency
                           )
                         : color.new(
                              lowerInactiveColor,
                              boxTransparency
                           )
                )

//#####################################################################
// ALERT ENGINE
//#####################################################################

bool alertConfirmed =
     not alertOnClose or
     barstate.isconfirmed

//=====================================================================
// TOGGLE 1 ALERT LEVELS
//=====================================================================
float onAlertRange =
     not na(onHigh) and not na(onLow)
         ? onHigh - onLow
         : na

float onUpperTopAlert =
     not na(onAlertRange)
         ? onHigh + onAlertRange
         : na

float onUpperMidAlert =
     not na(onAlertRange)
         ? onHigh + onAlertRange / 2.0
         : na

float onUpperBottomAlert =
     onHigh

float onCenterTopAlert =
     onHigh

float onCenterMidAlert =
     not na(onAlertRange)
         ? onLow + onAlertRange / 2.0
         : na

float onCenterBottomAlert =
     onLow

float onLowerTopAlert =
     onLow

float onLowerMidAlert =
     not na(onAlertRange)
         ? onLow - onAlertRange / 2.0
         : na

float onLowerBottomAlert =
     not na(onAlertRange)
         ? onLow - onAlertRange
         : na

//=====================================================================
// TOGGLE 1 CONDITIONS
//=====================================================================
bool onUpperMidCross =
     enableAlerts and
     showMidline and
     onRangeLocked and
     alertConfirmed and
     not na(onUpperMidAlert) and
     ta.cross(close, onUpperMidAlert)

bool onUpperTopCross =
     enableAlerts and
     onRangeLocked and
     alertConfirmed and
     not na(onUpperTopAlert) and
     ta.crossover(close, onUpperTopAlert)

bool onUpperBottomCross =
     enableAlerts and
     onRangeLocked and
     alertConfirmed and
     not na(onUpperBottomAlert) and
     ta.crossunder(close, onUpperBottomAlert)

bool onCenterMidCross =
     enableAlerts and
     showMidline and
     onRangeLocked and
     alertConfirmed and
     not na(onCenterMidAlert) and
     ta.cross(close, onCenterMidAlert)

bool onCenterTopCross =
     enableAlerts and
     onRangeLocked and
     alertConfirmed and
     not na(onCenterTopAlert) and
     ta.crossover(close, onCenterTopAlert)

bool onCenterBottomCross =
     enableAlerts and
     onRangeLocked and
     alertConfirmed and
     not na(onCenterBottomAlert) and
     ta.crossunder(close, onCenterBottomAlert)

bool onLowerMidCross =
     enableAlerts and
     showMidline and
     onRangeLocked and
     alertConfirmed and
     not na(onLowerMidAlert) and
     ta.cross(close, onLowerMidAlert)

bool onLowerTopCross =
     enableAlerts and
     onRangeLocked and
     alertConfirmed and
     not na(onLowerTopAlert) and
     ta.crossover(close, onLowerTopAlert)

bool onLowerBottomCross =
     enableAlerts and
     onRangeLocked and
     alertConfirmed and
     not na(onLowerBottomAlert) and
     ta.crossunder(close, onLowerBottomAlert)

//=====================================================================
// TOGGLE 2 ALERT LEVELS
//=====================================================================
float rthAlertRange =
     not na(rthHigh) and not na(rthLow)
         ? rthHigh - rthLow
         : na

float rthUpperTopAlert =
     not na(rthAlertRange)
         ? rthHigh + rthAlertRange
         : na

float rthUpperMidAlert =
     not na(rthAlertRange)
         ? rthHigh + rthAlertRange / 2.0
         : na

float rthUpperBottomAlert =
     rthHigh

float rthCenterTopAlert =
     rthHigh

float rthCenterMidAlert =
     not na(rthAlertRange)
         ? rthLow + rthAlertRange / 2.0
         : na

float rthCenterBottomAlert =
     rthLow

float rthLowerTopAlert =
     rthLow

float rthLowerMidAlert =
     not na(rthAlertRange)
         ? rthLow - rthAlertRange / 2.0
         : na

float rthLowerBottomAlert =
     not na(rthAlertRange)
         ? rthLow - rthAlertRange
         : na

//=====================================================================
// TOGGLE 2 CONDITIONS
//=====================================================================
bool rthUpperMidCross =
     enableAlerts and
     showMidline and
     rthRangeLocked and
     alertConfirmed and
     not na(rthUpperMidAlert) and
     ta.cross(close, rthUpperMidAlert)

bool rthUpperTopCross =
     enableAlerts and
     rthRangeLocked and
     alertConfirmed and
     not na(rthUpperTopAlert) and
     ta.crossover(close, rthUpperTopAlert)

bool rthUpperBottomCross =
     enableAlerts and
     rthRangeLocked and
     alertConfirmed and
     not na(rthUpperBottomAlert) and
     ta.crossunder(close, rthUpperBottomAlert)

bool rthCenterMidCross =
     enableAlerts and
     showMidline and
     rthRangeLocked and
     alertConfirmed and
     not na(rthCenterMidAlert) and
     ta.cross(close, rthCenterMidAlert)

bool rthCenterTopCross =
     enableAlerts and
     rthRangeLocked and
     alertConfirmed and
     not na(rthCenterTopAlert) and
     ta.crossover(close, rthCenterTopAlert)

bool rthCenterBottomCross =
     enableAlerts and
     rthRangeLocked and
     alertConfirmed and
     not na(rthCenterBottomAlert) and
     ta.crossunder(close, rthCenterBottomAlert)

bool rthLowerMidCross =
     enableAlerts and
     showMidline and
     rthRangeLocked and
     alertConfirmed and
     not na(rthLowerMidAlert) and
     ta.cross(close, rthLowerMidAlert)

bool rthLowerTopCross =
     enableAlerts and
     rthRangeLocked and
     alertConfirmed and
     not na(rthLowerTopAlert) and
     ta.crossover(close, rthLowerTopAlert)

bool rthLowerBottomCross =
     enableAlerts and
     rthRangeLocked and
     alertConfirmed and
     not na(rthLowerBottomAlert) and
     ta.crossunder(close, rthLowerBottomAlert)

//=====================================================================
// ALERTS
//=====================================================================
alertcondition(
     onUpperMidCross,
     "T1 Upper Midline Cross",
     "🔥 {{ticker}} | T1 UPPER MIDLINE CROSS | Price {{close}}"
)

alertcondition(
     onUpperTopCross,
     "T1 Upper Rectangle — Cross Above",
     "🚀 {{ticker}} | T1 CROSSED ABOVE UPPER RECTANGLE | Price {{close}}"
)

alertcondition(
     onUpperBottomCross,
     "T1 Upper Rectangle — Cross Below",
     "🔻 {{ticker}} | T1 CROSSED BELOW UPPER RECTANGLE | Price {{close}}"
)

alertcondition(
     onCenterMidCross,
     "T1 Center Midline Cross",
     "🔥 {{ticker}} | T1 CENTER MIDLINE CROSS | Price {{close}}"
)

alertcondition(
     onCenterTopCross,
     "T1 Center Rectangle — Cross Above",
     "🟢 {{ticker}} | T1 CROSSED ABOVE CENTER RECTANGLE | Price {{close}}"
)

alertcondition(
     onCenterBottomCross,
     "T1 Center Rectangle — Cross Below",
     "🔴 {{ticker}} | T1 CROSSED BELOW CENTER RECTANGLE | Price {{close}}"
)

alertcondition(
     onLowerMidCross,
     "T1 Lower Midline Cross",
     "🔥 {{ticker}} | T1 LOWER MIDLINE CROSS | Price {{close}}"
)

alertcondition(
     onLowerTopCross,
     "T1 Lower Rectangle — Cross Above",
     "⬆️ {{ticker}} | T1 CROSSED ABOVE LOWER RECTANGLE | Price {{close}}"
)

alertcondition(
     onLowerBottomCross,
     "T1 Lower Rectangle — Cross Below",
     "🔻 {{ticker}} | T1 CROSSED BELOW LOWER RECTANGLE | Price {{close}}"
)

alertcondition(
     rthUpperMidCross,
     "T2 Upper Midline Cross",
     "🔥 {{ticker}} | T2 UPPER MIDLINE CROSS | Price {{close}}"
)

alertcondition(
     rthUpperTopCross,
     "T2 Upper Rectangle — Cross Above",
     "🚀 {{ticker}} | T2 CROSSED ABOVE UPPER RECTANGLE | Price {{close}}"
)

alertcondition(
     rthUpperBottomCross,
     "T2 Upper Rectangle — Cross Below",
     "🔻 {{ticker}} | T2 CROSSED BELOW UPPER RECTANGLE | Price {{close}}"
)

alertcondition(
     rthCenterMidCross,
     "T2 Center Midline Cross",
     "🔥 {{ticker}} | T2 CENTER MIDLINE CROSS | Price {{close}}"
)

alertcondition(
     rthCenterTopCross,
     "T2 Center Rectangle — Cross Above",
     "🟢 {{ticker}} | T2 CROSSED ABOVE CENTER RECTANGLE | Price {{close}}"
)

alertcondition(
     rthCenterBottomCross,
     "T2 Center Rectangle — Cross Below",
     "🔴 {{ticker}} | T2 CROSSED BELOW CENTER RECTANGLE | Price {{close}}"
)

alertcondition(
     rthLowerMidCross,
     "T2 Lower Midline Cross",
     "🔥 {{ticker}} | T2 LOWER MIDLINE CROSS | Price {{close}}"
)

alertcondition(
     rthLowerTopCross,
     "T2 Lower Rectangle — Cross Above",
     "⬆️ {{ticker}} | T2 CROSSED ABOVE LOWER RECTANGLE | Price {{close}}"
)

alertcondition(
     rthLowerBottomCross,
     "T2 Lower Rectangle — Cross Below",
     "🔻 {{ticker}} | T2 CROSSED BELOW LOWER RECTANGLE | Price {{close}}"
)
````
