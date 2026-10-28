# Rolling 4H Range Bars

- url: https://www.tradingview.com/script/kR0qTO73-Rolling-4H-Range-Bars/
- type: indicator
- pine_id: PUB;62edc72153384cbd92243022b3ba2c72
- version: 1.0

## Description

4 hour time frames are marked for continuation of trends

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © dre4169

//@version=5
indicator("Rolling 4H Range Bars", overlay=true, max_boxes_count=20, max_labels_count=20)

//--------------------------------------------------
// SHOW ONLY BELOW DAILY
//--------------------------------------------------
showLevels = timeframe.in_seconds() < timeframe.in_seconds("D")

//--------------------------------------------------
// 4H DETECTION
//--------------------------------------------------
new4H = ta.change(time("240"))

// Current live 4H values
currHigh = request.security(
     syminfo.tickerid,
     "240",
     high,
     lookahead=barmerge.lookahead_on)

currLow = request.security(
     syminfo.tickerid,
     "240",
     low,
     lookahead=barmerge.lookahead_on)

//--------------------------------------------------
// STORAGE
//--------------------------------------------------
var float prevHigh1 = na
var float prevLow1 = na

var float prevHigh2 = na
var float prevLow2 = na

//--------------------------------------------------
// ROLL FORWARD
//--------------------------------------------------
if new4H
    prevHigh2 := prevHigh1
    prevLow2 := prevLow1

    prevHigh1 := currHigh[1]
    prevLow1 := currLow[1]

//--------------------------------------------------
// BOXES
//--------------------------------------------------
var box currentBox = na
var box previousBox = na
var box firstBox = na

//--------------------------------------------------
// LABELS
//--------------------------------------------------
var label currHighLbl = na
var label currLowLbl = na

var label prevHighLbl = na
var label prevLowLbl = na

var label firstHighLbl = na
var label firstLowLbl = na

//--------------------------------------------------
// NEW 4H START
//--------------------------------------------------
if new4H and showLevels

    box.delete(firstBox)

    firstBox := previousBox
    previousBox := currentBox

    currentBox := box.new(
         left=bar_index,
         top=currHigh,
         right=bar_index + 1,
         bottom=currLow,
         bgcolor=color.new(color.orange, 90),
         border_color=color.orange,
         border_width=1)

//--------------------------------------------------
// UPDATE CURRENT BOX
//--------------------------------------------------
if showLevels

    if na(currentBox)
        currentBox := box.new(
             left=bar_index,
             top=currHigh,
             right=bar_index + 1,
             bottom=currLow,
             bgcolor=color.new(color.orange, 90),
             border_color=color.orange,
             border_width=1)

    box.set_top(currentBox, currHigh)
    box.set_bottom(currentBox, currLow)
    box.set_right(currentBox, bar_index + 1)

    if not na(previousBox)
        box.set_border_color(previousBox, color.red)

    if not na(firstBox)
        box.set_border_color(firstBox, color.purple)

//--------------------------------------------------
// LABELS
//--------------------------------------------------
if barstate.islast

    label.delete(currHighLbl)
    label.delete(currLowLbl)

    label.delete(prevHighLbl)
    label.delete(prevLowLbl)

    label.delete(firstHighLbl)
    label.delete(firstLowLbl)

    if showLevels

        currHighLbl := label.new(
             bar_index + 2,
             currHigh,
             "4 Hour High",
             color=color.orange,
             textcolor=color.white,
             size=size.tiny)

        currLowLbl := label.new(
             bar_index + 2,
             currLow,
             "4 Hour Low",
             color=color.orange,
             textcolor=color.white,
             size=size.tiny)

        if not na(prevHigh1)

            prevHighLbl := label.new(
                 bar_index + 2,
                 prevHigh1,
                 "Previous Four Hour High",
                 color=color.red,
                 textcolor=color.white,
                 size=size.tiny)

            prevLowLbl := label.new(
                 bar_index + 2,
                 prevLow1,
                 "Previous Four Hour Low",
                 color=color.red,
                 textcolor=color.white,
                 size=size.tiny)

        if not na(prevHigh2)

            firstHighLbl := label.new(
                 bar_index + 2,
                 prevHigh2,
                 "First Four High",
                 color=color.purple,
                 textcolor=color.white,
                 size=size.tiny)

            firstLowLbl := label.new(
                 bar_index + 2,
                 prevLow2,
                 "First Four Low",
                 color=color.purple,
                 textcolor=color.white,
                 size=size.tiny)
````
