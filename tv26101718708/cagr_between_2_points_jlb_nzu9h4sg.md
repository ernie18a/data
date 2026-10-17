# CAGR Between 2 Points (JLB)

- url: https://www.tradingview.com/script/nzu9h4Sg-CAGR-Between-2-Points-JLB/
- type: indicator
- pine_id: PUB;2fcf1902967d47e6b251287647ea64fa
- version: 5.0

## Description

CAGR Between 2 Points.
CAGR: Compound Annual Growth Rate
TCAC: Taux de Croissance Annuel Composé

Annualised Return Rate
Yearly Return Rate

## Source Code

````pine
//@version=6
indicator("CAGR Between 2 Close Points (Stable Index Version)", overlay = true, max_lines_count = 10, max_labels_count = 10, max_boxes_count = 10, max_bars_back = 5000)

// Interactive point dates
int t1 = input.time(0, "Date 1", inline = "P1", confirm = true)
int t2 = input.time(0, "Date 2", inline = "P2", confirm = true)

// Display Options
bool showLine   = input.bool(true, "Show line", group="Display")
bool showLabel  = input.bool(true, "Show label on chart", group="Display")
bool showBg     = input.bool(true, "Highlight Background", group="Display") 
bool use36525   = input.bool(true, "Use 365.25 days/year", group="Settings")

// COLOR & STYLE SETTINGS
color posColor  = input.color(color.green, "Positive Master Color", group="Style")
color negColor  = input.color(color.red, "Negative Master Color", group="Style") 
string lineType = input.string("Dotted", "Line Style", options=["Solid", "Dashed", "Dotted"], group="Style")

// DEFAULT SETTINGS UPDATED: "X" and "Tiny"
string endType   = input.string("X", "Line Ends Shape", options=["None", "Circle", "X", "+ (Cross)"], group="Style") 
string shapeSize = input.string("Tiny", "Shape Size", options=["Tiny", "Small", "Normal", "Large"], group="Style")

int bgTrans     = input.int(90, "Highlight Transparency", minval=0, maxval=100, group="Style")
int borderTrans = input.int(65, "Highlight Border Transparency", minval=0, maxval=100, group="Style") 
int labelTrans  = input.int(80, "Label Box Transparency", minval=0, maxval=100, group="Style")

// POSITION SETTINGS (Manual Controls)
int labelOffsetPercent = input.int(0, "Adjust Label Height (%)", minval=-50, maxval=50, step=1, group="Manual Position")
int labelOffsetBars    = input.int(25, "Adjust Label Width (Bars)", minval=-50, maxval=100, step=1, group="Manual Position")

// Dynamically fetch closing prices and bar indices
float p1 = ta.valuewhen(time <= t1 and time + 86400000 > t1, close, 0)
float p2 = ta.valuewhen(time <= t2 and time + 86400000 > t2, close, 0)
int   b1 = ta.valuewhen(time <= t1 and time + 86400000 > t1, bar_index, 0)
int   b2 = ta.valuewhen(time <= t2 and time + 86400000 > t2, bar_index, 0)

// Helpers
f_pct(x) => na(x) ? "n/a" : str.tostring(x * 100, "#.##") + "%"
f_num(x) => na(x) ? "n/a" : str.tostring(x, "#.##")

f_get_line_style(styleStr) =>
    switch styleStr
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

f_get_shape_style(styleStr) =>
    switch styleStr
        "Circle"    => label.style_circle
        "X"         => label.style_xcross
        "+ (Cross)" => label.style_cross
        => label.style_none

f_get_shape_size(sizeStr) =>
    switch sizeStr
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

f_pad(strItem, targetLen) =>
    int diff = targetLen - str.length(strItem)
    string padding = ""
    if diff > 0
        for i = 1 to diff
            padding := padding + " "
    padding + strItem

// Validation
bool validPoints = p1 > 0 and p2 > 0 and t1 > 0 and t2 > 0 and t1 != t2

int   barStart = math.min(b1, b2)
int   barEnd   = math.max(b1, b2)
float pStart   = b1 < b2 ? p1 : p2
float pEnd     = b1 < b2 ? p2 : p1

// Calculations
float days     = float(math.max(t1, t2) - math.min(t1, t2)) / (24 * 60 * 60 * 1000)
float years    = float(math.max(t1, t2) - math.min(t1, t2)) / ((use36525 ? 365.25 : 365.0) * 24 * 60 * 60 * 1000)
float ret      = pEnd / pStart - 1.0
float cagr     = math.pow(pEnd / pStart, 1.0 / years) - 1.0

// Drawings
var line ln    = na
var label lb   = na
var box bx     = na 
var label dot1 = na 
var label dot2 = na 

if barstate.islast
    if not na(ln)
        line.delete(ln)
    if not na(lb)
        label.delete(lb)
    if not na(bx)
        box.delete(bx)
    if not na(dot1)
        label.delete(dot1)
    if not na(dot2)
        label.delete(dot2)

    color dynamicColor = (not na(cagr) and cagr < 0) ? negColor : posColor

    if validPoints
        if showBg
            bx := box.new(left = barStart, top = math.max(pStart, pEnd), right = barEnd, bottom = math.min(pStart, pEnd), xloc = xloc.bar_index, border_color = color.new(dynamicColor, borderTrans), bgcolor = color.new(dynamicColor, bgTrans))

        if showLine
            ln := line.new(x1 = barStart, y1 = pStart, x2 = barEnd, y2 = pEnd, xloc = xloc.bar_index, color = dynamicColor, style = f_get_line_style(lineType), width = 2)
            
            string styleChoice = f_get_shape_style(endType)
            string sizeChoice  = f_get_shape_size(shapeSize)
                
            if styleChoice != label.style_none
                dot1 := label.new(x = barStart, y = pStart, text = "", xloc = xloc.bar_index, style = styleChoice, color = dynamicColor, size = sizeChoice)
                dot2 := label.new(x = barEnd,   y = pEnd,   text = "", xloc = xloc.bar_index, style = styleChoice, color = dynamicColor, size = sizeChoice)

        if showLabel and not na(cagr)
            string s_cagr = "CAGR: " + f_pct(cagr)
            string s_ret  = "Return: " + f_pct(ret)
            string s_days = "Days: " + f_num(days)
            string s_yrs  = "Years: " + f_num(years)
            int maxLen    = math.max(str.length(s_cagr), math.max(str.length(s_ret), math.max(str.length(s_days), str.length(s_yrs))))
            string txt    = f_pad(s_cagr, maxLen) + "\n" + f_pad(s_ret, maxLen) + "\n" + f_pad(s_days, maxLen) + "\n" + f_pad(s_yrs, maxLen)

            lb := label.new(x = barEnd + labelOffsetBars, y = pEnd * (1 + (labelOffsetPercent / 100.0)), text = txt, xloc = xloc.bar_index, style = label.style_label_left, textcolor = dynamicColor, color = color.new(dynamicColor, labelTrans), size = size.normal, text_font_family = font.family_monospace, text_formatting = text.format_bold)
````
