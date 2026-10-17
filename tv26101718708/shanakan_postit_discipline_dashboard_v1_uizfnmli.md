# Shanakan Post-it Discipline Dashboard V1

- url: https://www.tradingview.com/script/UIZfNMLi-Shanakan-Post-it-Discipline-Dashboard-V1/
- type: indicator
- pine_id: PUB;040ee8643c844477b62f0108799615a5
- version: 1.0

## Description

Trader Discipline Seal
A visual reminder to stay aligned with your plan, maintain focus, and execute with discipline.
Placed at the top-right of your chart as a mental anchor.
Fully customizable to match your own trading philosophy.

## Source Code

````pine
//@version=6
indicator("Shanakan Post-it Discipline Dashboard V1", overlay=true, max_boxes_count=10, max_labels_count=50)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SHANAKAN POST-IT DISCIPLINE DASHBOARD
// ทำกล่อง Post-it เตือนสติบนกราฟ
// ไม่ใช่สัญญาณ Buy/Sell
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// INPUTS
showDashboard = input.bool(true, "Show Post-it Dashboard")

// ตำแหน่ง / ขนาด
xOffset     = input.int(35, "Move Right / Left", minval=-200, maxval=300)
boxWidth    = input.int(55, "Box Width", minval=20, maxval=200)
boxHeightATR = input.float(9.0, "Box Height ATR", minval=2.0, step=0.5)
yOffsetATR   = input.float(3.0, "Move Up / Down ATR", step=0.5)

// ข้อความ
line1 = input.string("Shanakan System", "Line 1")
line2 = input.string("I Trade with my Pattern Only", "Line 2")
line3 = input.string("I Stay Focus !!!", "Line 3")
line4 = input.string("I Wait with Patience", "Line 4")
line5 = input.string("I Accept the Result", "Line 5")
line6 = input.string("I will be win !!!", "Line 6")

// สี
postItBg     = input.color(color.new(color.rgb(255, 160, 175), 78), "Post-it Background")
postItBorder = input.color(color.new(color.rgb(220, 45, 70), 0), "Post-it Border")
textColor    = input.color(color.rgb(35, 105, 220), "Text Color")
textBg       = input.color(color.new(color.white, 25), "Text Highlight")

textSizeOpt = input.string("Large", "Text Size", options=["Small", "Normal", "Large", "Huge"])
textSize = textSizeOpt == "Small" ? size.small : textSizeOpt == "Normal" ? size.normal : textSizeOpt == "Huge" ? size.huge : size.large

atrLen = input.int(14, "ATR Length")
atr = ta.atr(atrLen)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// POSITION CALC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
centerX = bar_index + xOffset
leftX   = centerX - math.floor(boxWidth / 2)
rightX  = centerX + math.floor(boxWidth / 2)

centerY = close + atr * yOffsetATR
topY    = centerY + atr * boxHeightATR / 2
botY    = centerY - atr * boxHeightATR / 2

lineStep = (topY - botY) / 7.0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OBJECTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var box postBox = na
var label l1 = na
var label l2 = na
var label l3 = na
var label l4 = na
var label l5 = na
var label l6 = na

f_delete() =>
    if not na(postBox)
        box.delete(postBox)
    if not na(l1)
        label.delete(l1)
    if not na(l2)
        label.delete(l2)
    if not na(l3)
        label.delete(l3)
    if not na(l4)
        label.delete(l4)
    if not na(l5)
        label.delete(l5)
    if not na(l6)
        label.delete(l6)

f_make_label(_txt, _y) =>
    label.new(centerX, _y, _txt, style=label.style_label_center, textcolor=textColor, color=textBg, size=textSize)

if barstate.islast
    f_delete()
    if showDashboard
        postBox := box.new(left=leftX, top=topY, right=rightX, bottom=botY, bgcolor=postItBg, border_color=postItBorder, border_width=2)
        l1 := f_make_label(line1, topY - lineStep * 1.0)
        l2 := f_make_label(line2, topY - lineStep * 2.0)
        l3 := f_make_label(line3, topY - lineStep * 3.0)
        l4 := f_make_label(line4, topY - lineStep * 4.0)
        l5 := f_make_label(line5, topY - lineStep * 5.0)
        l6 := f_make_label(line6, topY - lineStep * 6.0)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NOTES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// วิธีปรับให้เหมือนรูป:
// - Move Right / Left = ขยับกล่องไปขวา/ซ้าย
// - Box Width = ความกว้าง
// - Box Height ATR = ความสูง
// - Move Up / Down ATR = ขยับขึ้น/ลง
// - Text Size = ขนาดตัวอักษร
//
// TradingView Pine ไม่สามารถ fix ขนาดเป็น pixel แบบรูปภาพได้ 100%
// แต่ปรับด้วย input จนใกล้ภาพตัวอย่างได้
````
