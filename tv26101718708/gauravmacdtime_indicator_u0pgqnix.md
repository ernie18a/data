# Gaurav_MACD(Time indicator)

- url: https://www.tradingview.com/script/u0pGQnix-Gaurav-MACD-Time-indicator/
- type: indicator
- pine_id: PUB;1f864a36b7f84433a77d0b3b0a6fa540
- version: 1.0

## Description

See MACD indicator with Time frame . Example if ur time frame if 15 mins for MACD, this indicator will show time along with MACD and is helpful when u have multiple Tfs on screen

## Source Code

````pine
//@version=6
indicator("MACD Pro TF", shorttitle="MACD TF PRO", overlay=false)

// ===== INPUTS =====
src   = input.source(close, "Source")
fast  = input.int(12, "Fast Length")
slow  = input.int(26, "Slow Length")
sig   = input.int(9,  "Signal Length")

// ===== TIMEFRAME BOX SETTINGS =====
fontInput = input.string("Normal", "TF Font Size",
     options = ["Tiny","Small","Normal","Large","Huge"])

bgColor  = input.color(color.yellow, "TF Background")
txtColor = input.color(color.black, "TF Text Color")

posInput = input.string("Top Right", "TF Box Position",
     options = ["Top Right","Top Left","Bottom Right","Bottom Left"])

// ===== MACD (BUILT-IN) =====
[macdLine, signalLine, histLine] = ta.macd(src, fast, slow, sig)

// ===== HISTOGRAM COLOR (TV STYLE) =====
histColor =
     histLine >= 0 ?
         (histLine > histLine[1] ? color.green : color.new(color.green, 60)) :
         (histLine < histLine[1] ? color.red : color.new(color.red, 60))

// ===== PLOTS =====
hline(0, "Zero Line", color=color.gray)
plot(histLine, style=plot.style_columns, color=histColor, title="Histogram")
plot(macdLine, color=color.blue, title="MACD")
plot(signalLine, color=color.orange, title="Signal")

// ===== TIMEFRAME TEXT =====
string tfText = timeframe.period
float tfNum = str.tonumber(timeframe.period)

if not na(tfNum)
    if tfNum >= 60
        tfText := str.tostring(tfNum / 60) + "H"
    else
        tfText := str.tostring(tfNum) + "m"

// ===== FONT SIZE =====
txtSize = size.normal
if fontInput == "Tiny"
    txtSize := size.tiny
else if fontInput == "Small"
    txtSize := size.small
else if fontInput == "Large"
    txtSize := size.large
else if fontInput == "Huge"
    txtSize := size.huge

// ===== POSITION =====
tablePos = position.top_right
if posInput == "Top Left"
    tablePos := position.top_left
else if posInput == "Bottom Right"
    tablePos := position.bottom_right
else if posInput == "Bottom Left"
    tablePos := position.bottom_left

// ===== TABLE =====
var table tfTable = table.new(tablePos, 1, 1)

if barstate.islast
    table.cell(tfTable, 0, 0,
         tfText,
         bgcolor = bgColor,
         text_color = txtColor,
         text_size = txtSize)
````
