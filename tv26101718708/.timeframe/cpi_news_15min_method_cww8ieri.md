# CPI News - 15min Method

- url: https://www.tradingview.com/script/CWw8ierI-CPI-News-15min-Method/
- type: indicator
- pine_id: PUB;ad4f7c5c0d0c40c8b7dd4cda4d936789
- version: 6.0

## Description

Use this indicator to easily pass eval of any firm trading CPI News using 15min Method.

**REMINDER - this is not a financial advice, just spreading the knowledge. Do your own research before taking any financial action. Do it in your own risk.**

Your Welcome!!!

## Source Code

````pine
//@version=6
indicator("CPI News Trading", overlay = true)

// ================= INPUTS =================
// ---- Settings group ----
tf = input.string("15", "Reference Timeframe", options = ["1", "2", "3", "4", "5", "15"], group = "Settings")

baseMode = input.string(
     "HTF",
     "Base Source",
     options = ["HTF", "LTP"],
     group = "Settings"
)

// ---- Levels group ----
// Indicator box labels are NOT changed — only chart labels are swapped below
point1 = input.float(30, "Stops Order", group = "Levels")
point2 = input.float(80, "Limit Order", group = "Levels")

// ---- Display group ----
lineWidth  = input.int(1, "Line Width", minval = 1, maxval = 4, group = "Display")
styleInput = input.string("Solid", "Line Style", options = ["Solid", "Dashed", "Dotted"], group = "Display")

// ---- Labels group ----
orderLabelSizeInput = input.string("Small", "Order Label Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = "Labels")
offset = input.int(5, "Offset", minval = 1, group = "Labels")

// ---- Colors group ----
lineColor       = input.color(color.blue,                "Line Color",  group = "Colors")
textColor       = input.color(color.white,               "Text Color",  group = "Colors")
panelLabelColor = input.color(color.new(color.gray, 80), "Background",  group = "Colors")

// ================= STYLE =================
line_style =
     styleInput == "Dashed" ? line.style_dashed :
     styleInput == "Dotted" ? line.style_dotted :
     line.style_solid

// ---- Label size (inline only — no function, avoids CE10110) ----
orderLabelSize = 
     orderLabelSizeInput == "Tiny"   ? size.tiny   :
     orderLabelSizeInput == "Normal" ? size.normal :
     orderLabelSizeInput == "Large"  ? size.large  :
     orderLabelSizeInput == "Huge"   ? size.huge   :
     size.small

// ================= HTF DATA =================
htfHigh = request.security(syminfo.tickerid, tf, high, lookahead = barmerge.lookahead_on)
htfLow  = request.security(syminfo.tickerid, tf, low,  lookahead = barmerge.lookahead_on)

// ================= CURRENT PRICE =================
price = close

// ================= BASE LOGIC =================
buyBase  = baseMode == "HTF" ? htfHigh : price
sellBase = baseMode == "HTF" ? htfLow  : price

// ================= LEVELS =================
buy1  = buyBase  + point1
buy2  = buyBase  + point2
sell1 = sellBase - point1
sell2 = sellBase - point2

// ================= LINE ENDPOINT =================
labelBar = bar_index + offset

// ================= OBJECTS =================
var line  l_hh  = na
var line  l_ll  = na
var line  l_b1  = na
var line  l_b2  = na
var line  l_s1  = na
var line  l_s2  = na
var label lb_hh = na
var label lb_ll = na
var label lb_b1 = na
var label lb_b2 = na
var label lb_s1 = na
var label lb_s2 = na

// ================= CLEAN =================
line.delete(l_hh)
line.delete(l_ll)
line.delete(l_b1)
line.delete(l_b2)
line.delete(l_s1)
line.delete(l_s2)
label.delete(lb_hh)
label.delete(lb_ll)
label.delete(lb_b1)
label.delete(lb_b2)
label.delete(lb_s1)
label.delete(lb_s2)

// ================= HTF LINES =================
if baseMode == "HTF"
    l_hh := line.new(bar_index, htfHigh, labelBar, htfHigh,
         extend = extend.none,
         color  = lineColor,
         width  = lineWidth,
         style  = line_style)

    l_ll := line.new(bar_index, htfLow, labelBar, htfLow,
         extend = extend.none,
         color  = lineColor,
         width  = lineWidth,
         style  = line_style)

    lb_hh := label.new(labelBar, htfHigh,
         "HTF High: " + str.tostring(htfHigh, format.mintick),
         style     = label.style_label_left,
         color     = panelLabelColor,
         textcolor = textColor,
         size      = orderLabelSize)

    lb_ll := label.new(labelBar, htfLow,
         "HTF Low: " + str.tostring(htfLow, format.mintick),
         style     = label.style_label_left,
         color     = panelLabelColor,
         textcolor = textColor,
         size      = orderLabelSize)

// ================= BUY LEVELS (above base) =================
l_b1 := line.new(bar_index, buy1, labelBar, buy1,
     extend = extend.none, color = lineColor, width = lineWidth, style = line_style)

l_b2 := line.new(bar_index, buy2, labelBar, buy2,
     extend = extend.none, color = lineColor, width = lineWidth, style = line_style)

// CHART LABELS SWAPPED HERE (input box names above are untouched)
lb_b1 := label.new(labelBar, buy1, "Buy Stop: " + str.tostring(buy1, format.mintick),
     style = label.style_label_left, color = panelLabelColor, textcolor = textColor, size = orderLabelSize)

lb_b2 := label.new(labelBar, buy2, "Sell Limit: " + str.tostring(buy2, format.mintick),
     style = label.style_label_left, color = panelLabelColor, textcolor = textColor, size = orderLabelSize)

// ================= SELL LEVELS (below base) =================
l_s1 := line.new(bar_index, sell1, labelBar, sell1,
     extend = extend.none, color = lineColor, width = lineWidth, style = line_style)

l_s2 := line.new(bar_index, sell2, labelBar, sell2,
     extend = extend.none, color = lineColor, width = lineWidth, style = line_style)

// CHART LABELS SWAPPED HERE (input box names above are untouched)
lb_s1 := label.new(labelBar, sell1, "Sell Stop: " + str.tostring(sell1, format.mintick),
     style = label.style_label_left, color = panelLabelColor, textcolor = textColor, size = orderLabelSize)

lb_s2 := label.new(labelBar, sell2, "Buy Limit: " + str.tostring(sell2, format.mintick),
     style = label.style_label_left, color = panelLabelColor, textcolor = textColor, size = orderLabelSize)
````
