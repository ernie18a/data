<!-- tradingview-pine-id: PUB;5c45d8a9e94e497eb3b103e89c21a462 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Custom Key Levels

Source: https://www.tradingview.com/script/RWzw413k-Custom-Key-Levels/

## Description

Custom Key Levels

Simple tool for plotting your own price levels — support/resistance, liquidity zones, order blocks, whatever you're tracking. Set up to 10 levels, name them yourself, get alerted when price hits them. No auto-detection, no fancy calculations — just your levels, on your chart, the way you want them to look.

What it does

10 level slots, each with its own on/off switch, name, price, and color
Pick short tags near the current price or full lines across the whole chart
Solid/dashed/dotted, adjust width and label size
Turn labels off if you just want clean lines with no text
Crossing alerts built in — get pinged when price crosses a level, and the alert message tells you which one

---

## Source Code

````pine
//@version=6
indicator("Custom Key Levels", overlay = true, max_lines_count = 20, max_labels_count = 20)

// ============================================================================
// Global style settings
// ============================================================================
grpStyle = "Style"
extendInput   = input.string("Short (near price)", "Line length",
                              options = ["Short (near price)", "Full width"],
                              group = grpStyle,
                              tooltip = "Short draws a small tag near the live edge of the chart. Full width stretches " +
                                        "the line all the way across the visible chart in both directions.")
lineStyleInput = input.string("Solid", "Line style", options = ["Solid", "Dashed", "Dotted"], group = grpStyle)
widthInput      = input.int(1, "Line width", minval = 1, maxval = 5, group = grpStyle)
shortLenInput   = input.int(3, "Short line length (bars)", minval = 1, maxval = 50, group = grpStyle,
                             tooltip = "How many bars past the current bar the short line extends. Ignored when Line length is Full width.")
showNameLabels  = input.bool(true, "Show level name labels", group = grpStyle)
labelSizeInput  = input.string("Small", "Label size", options = ["Tiny", "Small", "Normal", "Large"], group = grpStyle)

extendVal = extendInput == "Full width" ? extend.both : extend.none
lineStyleVal = switch lineStyleInput
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted
    => line.style_solid
labelSizeVal = switch labelSizeInput
    "Tiny"   => size.tiny
    "Normal" => size.normal
    "Large"  => size.large
    => size.small

// ============================================================================
// Alerts
// ============================================================================
grpAlerts = "Alerts"
enableAlerts    = input.bool(true, "Enable alerts", group = grpAlerts)
alertDirInput   = input.string("Both", "Alert on", options = ["Cross Up Only", "Cross Down Only", "Both"], group = grpAlerts)
alertOncePerBar = input.bool(true, "Alert once per bar close (recommended)", group = grpAlerts,
                              tooltip = "If off, alerts can fire on every realtime price tick, which may spam you. " +
                                        "Leave this on unless you specifically need intra-bar alerts.")

// ============================================================================
// Custom levels — set your own name, price, and colour for each.
// Prices are plain numbers you type in (e.g. 21050.25) — there's no live
// price picker here, so use the price scale on your chart as reference.
// ============================================================================
grpLevels = "Custom levels"

show1  = input.bool(false, "Show", inline = "L1", group = grpLevels)
name1  = input.string("Level 1", "", inline = "L1", group = grpLevels)
price1 = input.float(0.0, "", inline = "L1", group = grpLevels)
color1 = input.color(color.yellow, "", inline = "L1", group = grpLevels)

show2  = input.bool(false, "Show", inline = "L2", group = grpLevels)
name2  = input.string("Level 2", "", inline = "L2", group = grpLevels)
price2 = input.float(0.0, "", inline = "L2", group = grpLevels)
color2 = input.color(color.aqua, "", inline = "L2", group = grpLevels)

show3  = input.bool(false, "Show", inline = "L3", group = grpLevels)
name3  = input.string("Level 3", "", inline = "L3", group = grpLevels)
price3 = input.float(0.0, "", inline = "L3", group = grpLevels)
color3 = input.color(color.fuchsia, "", inline = "L3", group = grpLevels)

show4  = input.bool(false, "Show", inline = "L4", group = grpLevels)
name4  = input.string("Level 4", "", inline = "L4", group = grpLevels)
price4 = input.float(0.0, "", inline = "L4", group = grpLevels)
color4 = input.color(color.orange, "", inline = "L4", group = grpLevels)

show5  = input.bool(false, "Show", inline = "L5", group = grpLevels)
name5  = input.string("Level 5", "", inline = "L5", group = grpLevels)
price5 = input.float(0.0, "", inline = "L5", group = grpLevels)
color5 = input.color(color.lime, "", inline = "L5", group = grpLevels)

show6  = input.bool(false, "Show", inline = "L6", group = grpLevels)
name6  = input.string("Level 6", "", inline = "L6", group = grpLevels)
price6 = input.float(0.0, "", inline = "L6", group = grpLevels)
color6 = input.color(color.red, "", inline = "L6", group = grpLevels)

show7  = input.bool(false, "Show", inline = "L7", group = grpLevels)
name7  = input.string("Level 7", "", inline = "L7", group = grpLevels)
price7 = input.float(0.0, "", inline = "L7", group = grpLevels)
color7 = input.color(color.blue, "", inline = "L7", group = grpLevels)

show8  = input.bool(false, "Show", inline = "L8", group = grpLevels)
name8  = input.string("Level 8", "", inline = "L8", group = grpLevels)
price8 = input.float(0.0, "", inline = "L8", group = grpLevels)
color8 = input.color(color.purple, "", inline = "L8", group = grpLevels)

show9  = input.bool(false, "Show", inline = "L9", group = grpLevels)
name9  = input.string("Level 9", "", inline = "L9", group = grpLevels)
price9 = input.float(0.0, "", inline = "L9", group = grpLevels)
color9 = input.color(color.white, "", inline = "L9", group = grpLevels)

show10  = input.bool(false, "Show", inline = "L10", group = grpLevels)
name10  = input.string("Level 10", "", inline = "L10", group = grpLevels)
price10 = input.float(0.0, "", inline = "L10", group = grpLevels)
color10 = input.color(color.gray, "", inline = "L10", group = grpLevels)

// ============================================================================
// State — one line + one label per level slot, reused/updated in place
// rather than deleted and recreated every bar.
// ============================================================================
var line[]  lvlLines  = array.new<line>(10, na)
var label[] lvlLabels = array.new<label>(10, na)

// ============================================================================
// Helpers — create-or-update a horizontal level line / label
// ============================================================================
f_drawLevelLine(existingLine, x1, y, x2, col, wdth, ext, lstyle) =>
    line result = na(existingLine) ? line.new(x1, y, x2, y, xloc = xloc.bar_index, color = col, width = wdth, extend = ext, style = lstyle) : existingLine
    if not na(existingLine)
        line.set_xy1(result, x1, y)
        line.set_xy2(result, x2, y)
        line.set_color(result, col)
        line.set_width(result, wdth)
        line.set_extend(result, ext)
        line.set_style(result, lstyle)
    result

f_drawLevelLabel(existingLabel, x, y, txt, col, sz) =>
    label result = na(existingLabel) ? label.new(x, y, txt, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_none, textcolor = col, size = sz, textalign = text.align_right) : existingLabel
    if not na(existingLabel)
        label.set_xy(result, x, y)
        label.set_text(result, txt)
        label.set_textcolor(result, col)
        label.set_size(result, sz)
    result

// ============================================================================
// Draw / refresh every bar so short lines and labels track the live edge
// as the chart scrolls. Crossing detection is done manually with close[1]
// rather than ta.crossover/ta.crossunder, because those functions keep
// their internal state per CALL SITE, not per loop iteration — calling them
// inside a for loop with a changing "level price" argument would mix up
// the 10 levels' histories with each other. Comparing close[1] to a plain
// (non-changing-per-bar) price value sidesteps that entirely.
// ============================================================================
showArr  = array.from(show1, show2, show3, show4, show5, show6, show7, show8, show9, show10)
nameArr  = array.from(name1, name2, name3, name4, name5, name6, name7, name8, name9, name10)
priceArr = array.from(price1, price2, price3, price4, price5, price6, price7, price8, price9, price10)
colorArr = array.from(color1, color2, color3, color4, color5, color6, color7, color8, color9, color10)

x1 = bar_index
x2 = bar_index + shortLenInput

bool anyCrossUp   = false
bool anyCrossDown = false

for i = 0 to 9
    bool   s  = array.get(showArr, i)
    string nm = array.get(nameArr, i)
    float  pr = array.get(priceArr, i)
    color  cl = array.get(colorArr, i)
    line   ln = array.get(lvlLines, i)
    label  lb = array.get(lvlLabels, i)

    if s and not na(pr)
        ln := f_drawLevelLine(ln, x1, pr, x2, cl, widthInput, extendVal, lineStyleVal)
        array.set(lvlLines, i, ln)
        if showNameLabels
            lb := f_drawLevelLabel(lb, x2, pr, nm, cl, labelSizeVal)
            array.set(lvlLabels, i, lb)
        else
            if not na(lb)
                label.delete(lb)
                array.set(lvlLabels, i, na)

        // Crossing detection for alerts
        if enableAlerts
            bool crossUp   = close[1] <= pr and close > pr and alertDirInput != "Cross Down Only"
            bool crossDown = close[1] >= pr and close < pr and alertDirInput != "Cross Up Only"
            if crossUp
                anyCrossUp := true
                alert(nm + " crossed above " + str.tostring(pr) + " on " + syminfo.ticker,
                      alertOncePerBar ? alert.freq_once_per_bar_close : alert.freq_all)
            if crossDown
                anyCrossDown := true
                alert(nm + " crossed below " + str.tostring(pr) + " on " + syminfo.ticker,
                      alertOncePerBar ? alert.freq_once_per_bar_close : alert.freq_all)
    else
        if not na(ln)
            line.delete(ln)
            array.set(lvlLines, i, na)
        if not na(lb)
            label.delete(lb)
            array.set(lvlLabels, i, na)

// ============================================================================
// Alert conditions — appear as selectable options in TradingView's
// "Create Alert" dialog under Condition. For alerts with the specific level
// name in the message, choose "Any alert() function call" as the condition
// instead — that picks up the dynamic messages built in the loop above.
// ============================================================================
alertcondition(anyCrossUp,   title = "Any Level Crossed Up",   message = "Price crossed above a custom key level")
alertcondition(anyCrossDown, title = "Any Level Crossed Down", message = "Price crossed below a custom key level")
````
