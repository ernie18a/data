# High-Low Offset Levels PRO

- url: https://www.tradingview.com/script/HITEZbpe-High-Low-Offset-Levels-PRO/
- type: indicator
- pine_id: PUB;d32b85a7775747e8aadc62954617bb65
- version: 3.0

## Description

This indicator can help draw lines from:
High -25, -35, -50, -65, -80....
Low +25, +35, +50, +65, +80 .....
The values ​​can be adjusted as needed.

## Source Code

````pine
//@version=6
indicator("High-Low Offset Levels PRO + ATH", overlay=true, max_lines_count=500, max_labels_count=500)

// ===== PRICE SETTINGS =====
highPrice = input.float(4500.0, "High Price", group="Price")
lowPrice  = input.float(4441.0, "Low Price", group="Price")

// ===== LABEL POSITION =====
highLabelOffset = input.int(20, "High Label Offset Right", minval=0, maxval=1000, group="Label Position")
lowLabelOffset  = input.int(40, "Low Label Offset Right", minval=0, maxval=1000, group="Label Position")
athLabelOffset  = input.int(60, "ATH Label Offset Right", minval=0, maxval=1000, group="Label Position")

// ===== DISPLAY =====
showHighLevels = input.bool(true, "High", inline="show", group="Display")
showLowLevels = input.bool(true, "Low", inline="show", group="Display")
showBaseLow  = input.bool(true, "Show Base Low", group="Display")
showBaseHigh = input.bool(true, "Show Base High", group="Display")
showMid      = input.bool(true, "Show Mid", group="Display")

// ===== COLORS =====
lowColor  = input.color(color.rgb(3, 62, 33), "Low Line Color", group="Colors")
highColor = input.color(color.red, "High Line Color", group="Colors")
midColor  = input.color(color.rgb(228, 151, 28), "Mid Line Color", group="Colors")

lineWidth = input.int(1, "Line Width", minval=1, maxval=5, group="Colors")
lineStyleInput = input.string("Solid", "Line Style", options=["Solid","Dashed","Dotted"], group="Colors")

lineStyle = lineStyleInput == "Dashed" ? line.style_dashed : lineStyleInput == "Dotted" ? line.style_dotted : line.style_solid


// ===== ATH LEVELS =====
showATH = input.bool(false, "Show ATH", group="ATH Levels")
athValues = input.string("5595.33, 5311.51, 5111.14, 4967.52, 4888.30, 4737.43, 4690.70, 4630.25, 4601.30, 4550.22, 4525.96, 4497.83, 4420.53, 4380.10, 4247.50, 4218.20, 4180.00, 4085.20, 4049.50, 3977.40, 3949.60, 3895.30, 3831.30,3791.10, 3728.30, 3699.50, 3674.60, 3646.40, 3622.60, 3600.00, 3578.00, 3549.60, 3500.00, 3472.40, 3443.40, 3387.00, 3373.40, 3357.10, 3343.80, 3317.80, 3282.00, 3295.00, 3245.00, 3149.20, 3130.00", "ATH Values", group="ATH Levels")
athColor = input.color(color.blue, "ATH Color", group="ATH Levels")
athWidth = input.int(1, "ATH Width", minval=1, maxval=5, group="ATH Levels")
showATHLabels = input.bool(true, "Show ATH Label", group="ATH Levels")
athStyleInput = input.string("Dashed", "ATH Style", options=["Solid","Dashed","Dotted"], group="ATH Levels")
athStyle = athStyleInput == "Dashed" ? line.style_dashed : athStyleInput == "Dotted" ? line.style_dotted : line.style_solid


// ===== 24 CUSTOM LEVELS (3 COLUMNS) =====
en1=input.bool(true,"1",inline="r1",group="Levels") , lv1=input.float(25,"",inline="r1",group="Levels")
en9=input.bool(true,"9",inline="r1",group="Levels") , lv9=input.float(125,"",inline="r1",group="Levels")
en17=input.bool(false,"17",inline="r1",group="Levels"), lv17=input.float(250,"",inline="r1",group="Levels")

en2=input.bool(true,"2",inline="r2",group="Levels") , lv2=input.float(35,"",inline="r2",group="Levels")
en10=input.bool(true,"10",inline="r2",group="Levels"), lv10=input.float(135,"",inline="r2",group="Levels")
en18=input.bool(false,"18",inline="r2",group="Levels"), lv18=input.float(275,"",inline="r2",group="Levels")

en3=input.bool(true,"3",inline="r3",group="Levels") , lv3=input.float(50,"",inline="r3",group="Levels")
en11=input.bool(false,"11",inline="r3",group="Levels"), lv11=input.float(150,"",inline="r3",group="Levels")
en19=input.bool(false,"19",inline="r3",group="Levels"), lv19=input.float(300,"",inline="r3",group="Levels")

en4=input.bool(true,"4",inline="r4",group="Levels") , lv4=input.float(65,"",inline="r4",group="Levels")
en12=input.bool(false,"12",inline="r4",group="Levels"), lv12=input.float(155,"",inline="r4",group="Levels")
en20=input.bool(false,"20",inline="r4",group="Levels"), lv20=input.float(325,"",inline="r4",group="Levels")

en5=input.bool(true,"5",inline="r5",group="Levels") , lv5=input.float(80,"",inline="r5",group="Levels")
en13=input.bool(false,"13",inline="r5",group="Levels"), lv13=input.float(180,"",inline="r5",group="Levels")
en21=input.bool(false,"21",inline="r5",group="Levels"), lv21=input.float(350,"",inline="r5",group="Levels")

en6=input.bool(true,"6",inline="r6",group="Levels") , lv6=input.float(95,"",inline="r6",group="Levels")
en14=input.bool(false,"14",inline="r6",group="Levels"), lv14=input.float(195,"",inline="r6",group="Levels")
en22=input.bool(false,"22",inline="r6",group="Levels"), lv22=input.float(375,"",inline="r6",group="Levels")

en7=input.bool(true,"7",inline="r7",group="Levels") , lv7=input.float(100,"",inline="r7",group="Levels")
en15=input.bool(false,"15",inline="r7",group="Levels"), lv15=input.float(200,"",inline="r7",group="Levels")
en23=input.bool(false,"23",inline="r7",group="Levels"), lv23=input.float(400,"",inline="r7",group="Levels")

en8=input.bool(true,"8",inline="r8",group="Levels") , lv8=input.float(105,"",inline="r8",group="Levels")
en16=input.bool(false,"16",inline="r8",group="Levels"), lv16=input.float(225,"",inline="r8",group="Levels")
en24=input.bool(false,"24",inline="r8",group="Levels"), lv24=input.float(425,"",inline="r8",group="Levels")

bool[] enabled = array.from(en1,en2,en3,en4,en5,en6,en7,en8,en9,en10,en11,en12,en13,en14,en15,en16,en17,en18,en19,en20,en21,en22,en23,en24)
float[] levels = array.from(lv1,lv2,lv3,lv4,lv5,lv6,lv7,lv8,lv9,lv10,lv11,lv12,lv13,lv14,lv15,lv16,lv17,lv18,lv19,lv20,lv21,lv22,lv23,lv24)

midPrice = (highPrice + lowPrice) / 2

plot(showBaseHigh ? highPrice : na, "High", color=highColor, linewidth=2, trackprice=true)
plot(showBaseLow ? lowPrice : na, "Low", color=lowColor, linewidth=2, trackprice=true)
plot(showMid ? midPrice : na, "Mid", color=midColor, linewidth=1, trackprice=true)

var line[] lines = array.new_line()
var label[] labels = array.new_label()


if barstate.islast
    while array.size(lines) > 0
        line.delete(array.pop(lines))

    while array.size(labels) > 0
        label.delete(array.pop(labels))

    rightPosHigh = last_bar_index + highLabelOffset
    rightPosLow  = last_bar_index + lowLabelOffset
    rightPosATH  = last_bar_index + athLabelOffset

    if showBaseHigh
        array.push(labels, label.new(rightPosHigh, highPrice, "High / " + str.tostring(highPrice, format.mintick), style=label.style_none, textcolor=highColor))

    if showBaseLow
        array.push(labels, label.new(rightPosLow, lowPrice, "Low / " + str.tostring(lowPrice, format.mintick), style=label.style_none, textcolor=lowColor))

    if showMid
        array.push(labels, label.new(rightPosHigh, midPrice, "Mid / " + str.tostring(midPrice, format.mintick), style=label.style_none, textcolor=midColor))


    if showATH
        athClean = str.replace_all(athValues, " ", "")
        athArr = str.split(athClean, ",")
        for a = 0 to array.size(athArr) - 1
            valStr = array.get(athArr, a)
            athPrice = str.tonumber(valStr)
            if not na(athPrice)
                athLine = line.new(bar_index - 500, athPrice, bar_index + 500, athPrice, extend=extend.right, color=athColor, width=athWidth)
                line.set_style(athLine, athStyle)
                array.push(lines, athLine)
                if showATHLabels
                    array.push(labels, label.new(rightPosATH, athPrice, "ATH " + str.tostring(athPrice), style=label.style_none, textcolor=athColor))


    for i = 0 to array.size(levels) - 1
        if array.get(enabled, i)
            off = array.get(levels, i)

            lp = lowPrice + off
            hp = highPrice - off

            if showLowLevels
                ln1 = line.new(bar_index - 500, lp, bar_index + 500, lp, extend=extend.both, color=lowColor, width=lineWidth)
                line.set_style(ln1, lineStyle)
                array.push(lines, ln1)

                labelLow = "L " + str.tostring(int(off * 100)) + " / " + str.tostring(lp, format.mintick)
                array.push(labels, label.new(rightPosLow, lp, labelLow, style=label.style_none, textcolor=lowColor))

            if showHighLevels
                ln2 = line.new(bar_index - 500, hp, bar_index + 500, hp, extend=extend.both, color=highColor, width=lineWidth)
                line.set_style(ln2, lineStyle)
                array.push(lines, ln2)

                labelHigh = "H " + str.tostring(int(off * 100)) + " / " + str.tostring(hp, format.mintick)
                array.push(labels, label.new(rightPosHigh, hp, labelHigh, style=label.style_none, textcolor=highColor))
````
