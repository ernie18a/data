# Lowest Candle Block

- url: https://www.tradingview.com/script/H8EcSX64-Lowest-Candle-Block/
- type: indicator
- pine_id: PUB;68053d60ff2344d1b9a3864529304052
- version: 1.0

## Description

Box Highlighting the lowest candle in the option contract chart to be utilized as an entry point when retest

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MoAjaj88
//@version=6
indicator("Lowest Candle Confirmed Later Block Extended", overlay=true, max_boxes_count=20)

// Settings
blockColor  = input.color(color.new(#d9ecda, 80), "Block Color")
borderColor = input.color(color.rgb(232, 242, 233, 61), "Border Color")

var float lowestLow   = na
var float lowestHigh  = na
var int   lowestIndex = na
var bool  confirmed   = false

var box lowestBox = na

// أول شمعة
if na(lowestLow)
    lowestLow   := low
    lowestHigh  := high
    lowestIndex := bar_index

// إذا جاء Low جديد أقل قبل التأكيد، نحدث شمعة الأدنى ونلغي القديم
if not confirmed and low < lowestLow
    lowestLow   := low
    lowestHigh  := high
    lowestIndex := bar_index

    if not na(lowestBox)
        box.delete(lowestBox)
        lowestBox := na

// طالما ما تأكدت، ننتظر أي شمعة بعدها تغلق فوق High شمعة الأدنى
confirmSignal = not confirmed and na(lowestBox) and bar_index > lowestIndex and close > lowestHigh

if confirmSignal
    confirmed := true

    lowestBox := box.new(
         left = lowestIndex,
         top = lowestHigh,
         right = bar_index,
         bottom = lowestLow,
         xloc = xloc.bar_index,
         bgcolor = blockColor,
         border_color = borderColor,
         extend = extend.right
    )

// البوكس يبقى ممتد لليمين
// وينحذف فقط إذا أغلقت شمعة تحت Low أدنى شمعة
if not na(lowestBox)
    if close < box.get_bottom(lowestBox)
        box.delete(lowestBox)
        lowestBox := na
        confirmed := false

        // بعد الكسر، نبدأ من شمعة الكسر كأدنى شمعة جديدة
        lowestLow   := low
        lowestHigh  := high
        lowestIndex := bar_index
````
