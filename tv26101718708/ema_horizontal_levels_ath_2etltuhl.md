# EMA + Horizontal Levels + ATH

- url: https://www.tradingview.com/script/2EtltuHl/
- type: indicator
- pine_id: PUB;b207c89efa7c46cabaf71cba1bdd49fe
- version: 3.0

## Description

[b]EMA + Horizontal Levels + ATH[/b]
อินดิเคเตอร์รวม 3 ฟีเจอร์ในตัวเดียว ออกแบบมาเพื่อใช้ดูแนวรับ-แนวต้านและทิศทางเทรนด์ในการเทรด เหมาะกับการเทรดทอง (XAU/USD) และสินทรัพย์อื่นๆ
ฟีเจอร์หลัก

EMA 5 เส้น – เปิด/ปิดและตั้งค่าได้อิสระทุกเส้น (ความยาว/สี) พร้อมป้ายแสดงราคาปัจจุบันของแต่ละเส้น
Horizontal Lines อัตโนมัติ – ลากเส้นแนวนอนรอบราคาปัจจุบัน ห่างกันเท่าๆกันตามค่าที่ตั้ง (default ห่างกัน 5) พร้อมป้ายราคากำกับทุกเส้น ช่วยดูระดับราคาได้ละเอียดในกรอบที่กำลังเคลื่อนไหว
ATH Levels – ลากเส้นระดับราคาสูงสุดเป็นประวัติการณ์ (All-Time High) ตามค่าที่กำหนดไว้ล่วงหน้า ปรับแก้ไขรายการราคาได้เองในช่อง Input พร้อมป้ายกำกับ

[b]EMA + Horizontal Levels + ATH[/b]
An all-in-one indicator combining 3 features, designed to help you read support/resistance levels and trend direction at a glance. Great for gold (XAU/USD) trading and other instruments.
Key Features

5 Configurable EMAs – Enable/disable and customize each EMA independently (length, color), with live price labels for each line.
Automatic Horizontal Lines – Draws evenly spaced horizontal levels around the current price (default spacing: 5), each labeled with its price. Helps you spot fine-grained price levels within the current trading range.
ATH Levels – Plots All-Time High price levels from a fully customizable list. Edit the values directly in the inputs, with optional labels for each level.

## Source Code

````pine
//@version=6
indicator("EMA + Horizontal Levels + ATH", overlay=true, max_lines_count=500, max_labels_count=500)

// =====================================================================
// 1) EMA SECTION (5 configurable EMAs)
// =====================================================================
emaGroup = "EMA Settings"

ema1_enable = input.bool(true,  "Enable EMA 1", inline="e1", group=emaGroup, display=display.data_window)
ema1_len    = input.int(10,     "Length",       inline="e1", group=emaGroup, minval=1, display=display.data_window)
ema1_color  = input.color(color.new(#FF9800, 0), "Color", inline="e1", group=emaGroup, display=display.data_window)

ema2_enable = input.bool(true,  "Enable EMA 2", inline="e2", group=emaGroup, display=display.data_window)
ema2_len    = input.int(14,     "Length",       inline="e2", group=emaGroup, minval=1, display=display.data_window)
ema2_color  = input.color(color.new(#2196F3, 0), "Color", inline="e2", group=emaGroup, display=display.data_window)

ema3_enable = input.bool(true,  "Enable EMA 3", inline="e3", group=emaGroup, display=display.data_window)
ema3_len    = input.int(50,    "Length",       inline="e3", group=emaGroup, minval=1, display=display.data_window)
ema3_color  = input.color(color.new(#9E9E9E, 0), "Color", inline="e3", group=emaGroup, display=display.data_window)

ema4_enable = input.bool(true,  "Enable EMA 4", inline="e4", group=emaGroup, display=display.data_window)
ema4_len    = input.int(100,    "Length",       inline="e4", group=emaGroup, minval=1, display=display.data_window)
ema4_color  = input.color(color.new(#144133, 0), "Color", inline="e4", group=emaGroup, display=display.data_window)

ema5_enable = input.bool(true,  "Enable EMA 5", inline="e5", group=emaGroup, display=display.data_window)
ema5_len    = input.int(200,    "Length",       inline="e5", group=emaGroup, minval=1, display=display.data_window)
ema5_color  = input.color(color.new(#E91E63, 0), "Color", inline="e5", group=emaGroup, display=display.data_window)

showEmaLabels = input.bool(true, "Show EMA Price Labels", group=emaGroup, display=display.data_window)
emaLabelSize  = input.int(10, "EMA Label Font Size", minval=5, maxval=30, group=emaGroup, display=display.data_window)
emaLabelOffset = input.int(10, "EMA Label Offset Right", minval=0, maxval=200, group=emaGroup, display=display.data_window)

ema1 = ta.ema(close, ema1_len)
ema2 = ta.ema(close, ema2_len)
ema3 = ta.ema(close, ema3_len)
ema4 = ta.ema(close, ema4_len)
ema5 = ta.ema(close, ema5_len)

plot(ema1_enable ? ema1 : na, "EMA 1", color=ema1_color, linewidth=1)
plot(ema2_enable ? ema2 : na, "EMA 2", color=ema2_color, linewidth=1)
plot(ema3_enable ? ema3 : na, "EMA 3", color=ema3_color, linewidth=1)
plot(ema4_enable ? ema4 : na, "EMA 4", color=ema4_color, linewidth=1)
plot(ema5_enable ? ema5 : na, "EMA 5", color=ema5_color, linewidth=1)

var label ema1_lbl = na
var label ema2_lbl = na
var label ema3_lbl = na
var label ema4_lbl = na
var label ema5_lbl = na

if barstate.islast
    label.delete(ema1_lbl)
    label.delete(ema2_lbl)
    label.delete(ema3_lbl)
    label.delete(ema4_lbl)
    label.delete(ema5_lbl)

    if showEmaLabels
        emaLblX = bar_index + emaLabelOffset
        if ema1_enable
            ema1_lbl := label.new(emaLblX, ema1, "EMA " + str.tostring(ema1_len) + " - " + str.tostring(ema1, format.mintick), style=label.style_none, textcolor=ema1_color, size=emaLabelSize)
        if ema2_enable
            ema2_lbl := label.new(emaLblX, ema2, "EMA " + str.tostring(ema2_len) + " - " + str.tostring(ema2, format.mintick), style=label.style_none, textcolor=ema2_color, size=emaLabelSize)
        if ema3_enable
            ema3_lbl := label.new(emaLblX, ema3, "EMA " + str.tostring(ema3_len) + " - " + str.tostring(ema3, format.mintick), style=label.style_none, textcolor=ema3_color, size=emaLabelSize)
        if ema4_enable
            ema4_lbl := label.new(emaLblX, ema4, "EMA " + str.tostring(ema4_len) + " - " + str.tostring(ema4, format.mintick), style=label.style_none, textcolor=ema4_color, size=emaLabelSize)
        if ema5_enable
            ema5_lbl := label.new(emaLblX, ema5, "EMA " + str.tostring(ema5_len) + " - " + str.tostring(ema5, format.mintick), style=label.style_none, textcolor=ema5_color, size=emaLabelSize)

// =====================================================================
// 2) HORIZONTAL LINES SECTION (auto levels around rounded price)
// =====================================================================
hGroup = "Horizontal Lines"

showHLines    = input.bool(true,  "Show Horizontal Lines", group=hGroup, display=display.data_window)
hIncrement    = input.float(5,    "Increment Value", group=hGroup, minval=0.01, display=display.data_window)
hLevelsEach   = input.int(20,     "Levels Each Side", group=hGroup, minval=1, maxval=20, display=display.data_window)
hColor        = input.color(color.new(color.blue, 65), "Line Color", group=hGroup, display=display.data_window)
showHLabels   = input.bool(true,  "Show Labels", group=hGroup, display=display.data_window)
hLabelSize    = input.int(8,      "Label Font Size", group=hGroup, minval=5, maxval=30, display=display.data_window)
hLabelOffset  = input.int(20,      "Label Offset Right", group=hGroup, minval=0, maxval=200, display=display.data_window)

selectedPrice = math.ceil(math.round(close) / 10) * 10

var line[]  hLines  = array.new_line()
var label[] hLabels = array.new_label()

if barstate.islast
    while array.size(hLines) > 0
        line.delete(array.pop(hLines))
    while array.size(hLabels) > 0
        label.delete(array.pop(hLabels))

    if showHLines
        lineX1 = bar_index - 500
        lineX2 = bar_index + 500
        labelX = bar_index + hLabelOffset

        for i = -hLevelsEach to hLevelsEach
            lvl = selectedPrice + hIncrement * i
            ln  = line.new(lineX1, lvl, lineX2, lvl, extend=extend.both, color=hColor)
            array.push(hLines, ln)
            if showHLabels
                lbl = label.new(labelX, lvl, str.tostring(lvl, format.mintick), xloc=xloc.bar_index, style=label.style_none, textcolor=hColor, size=hLabelSize)
                array.push(hLabels, lbl)

// =====================================================================
// 3) ATH LEVELS SECTION (values/defaults taken from ath.txt)
// =====================================================================
athGroup = "ATH Levels"

showATH        = input.bool(true, "Show ATH", group=athGroup, display=display.data_window)
athValues      = input.string("5595.33, 5311.51, 5111.14, 4967.52, 4888.30, 4737.43, 4690.70, 4630.25, 4601.30, 4550.22, 4525.96, 4497.83, 4420.53, 4380.10, 4247.50, 4218.20, 4180.00, 4085.20, 4049.50, 3977.40, 3949.60, 3895.30, 3831.30,3791.10, 3728.30, 3699.50, 3674.60, 3646.40, 3622.60, 3600.00, 3578.00, 3549.60, 3500.00, 3472.40, 3443.40, 3387.00, 3373.40, 3357.10, 3343.80, 3317.80, 3282.00, 3295.00, 3245.00, 3149.20, 3130.00", "ATH Values", group=athGroup, display=display.data_window)
athColor       = input.color(color.blue, "ATH Color", group=athGroup, display=display.data_window)
athWidth       = input.int(1, "ATH Width", minval=1, maxval=5, group=athGroup, display=display.data_window)
showATHLabels  = input.bool(true, "Show ATH Label", group=athGroup, display=display.data_window)
athLabelOffset = input.int(27, "ATH Label Offset Right", minval=0, maxval=1000, group=athGroup, display=display.data_window)
athLabelSize   = input.int(8, "ATH Label Font Size", minval=5, maxval=30, group=athGroup, display=display.data_window)
athStyleInput  = input.string("Dashed", "ATH Style", options=["Solid", "Dashed", "Dotted"], group=athGroup, display=display.data_window)
athStyle       = athStyleInput == "Dashed" ? line.style_dashed : athStyleInput == "Dotted" ? line.style_dotted : line.style_solid

var line[]  athLines  = array.new_line()
var label[] athLabels = array.new_label()

if barstate.islast
    while array.size(athLines) > 0
        line.delete(array.pop(athLines))
    while array.size(athLabels) > 0
        label.delete(array.pop(athLabels))

    if showATH
        rightPosATH = bar_index + athLabelOffset
        athClean = str.replace_all(athValues, " ", "")
        athArr   = str.split(athClean, ",")
        for a = 0 to array.size(athArr) - 1
            valStr   = array.get(athArr, a)
            athPrice = str.tonumber(valStr)
            if not na(athPrice)
                athLine = line.new(bar_index - 500, athPrice, bar_index + 500, athPrice, extend=extend.right, color=athColor, width=athWidth)
                line.set_style(athLine, athStyle)
                array.push(athLines, athLine)
                if showATHLabels
                    athLbl = label.new(rightPosATH, athPrice, "ATH " + str.tostring(athPrice), xloc=xloc.bar_index, style=label.style_none, textcolor=athColor, size=athLabelSize)
                    array.push(athLabels, athLbl)
````
