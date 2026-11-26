# Previous High Low

- url: https://www.tradingview.com/script/OLgHm6ew/
- type: indicator
- pine_id: PUB;d65f73d6febb48df8259b317183f3635
- version: 1.0

## Description

Previous Montly, Weekly and Daily Highs and Lows are marked

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// Previous High & Low — Daily, Weekly, Monthly
// © alzv
// @version=6
indicator("Previous High Low", "Prev H/L", overlay = true, max_lines_count = 500, max_labels_count = 500)

//--------------------------------------------------------------------
// Inputs
//--------------------------------------------------------------------

string g1 = "Levels"
string g2 = "Style"

bool  showDailyInput   = input.bool(true,  "Daily",   group = g1, inline = "D")
color colorDailyHInput = input.color(color.new(color.green,  0), "", group = g1, inline = "D")
color colorDailyLInput = input.color(color.new(color.red,    0), "", group = g1, inline = "D")

bool  showWeeklyInput   = input.bool(true,  "Weekly",  group = g1, inline = "W")
color colorWeeklyHInput = input.color(color.new(color.teal,   0), "", group = g1, inline = "W")
color colorWeeklyLInput = input.color(color.new(color.orange, 0), "", group = g1, inline = "W")

bool  showMonthlyInput   = input.bool(true,  "Monthly", group = g1, inline = "M")
color colorMonthlyHInput = input.color(color.new(color.blue,   0), "", group = g1, inline = "M")
color colorMonthlyLInput = input.color(color.new(color.purple, 0), "", group = g1, inline = "M")

int    offsetInput    = input.int   (5,        "Abstand Text (bars)", group = g2, minval = 0)
int    lineWidthInput = input.int   (1,        "Line Width",          group = g2, minval = 1, maxval = 4)
string labelVInput    = input.string("Mitte",  "Textausrichtung",     group = g2, options = ["Oben", "Mitte", "Unten"])
bool   showPriceInput = input.bool  (true,     "Kurs anzeigen",       group = g2)

//--------------------------------------------------------------------
// Functions
//--------------------------------------------------------------------

isVisible(simple string tf) =>
    timeframe.in_seconds(tf) > timeframe.in_seconds()

getLabelStyle(string v) =>
    switch v
        "Oben"  => label.style_label_upper_left
        "Unten" => label.style_label_lower_left
        =>         label.style_label_left

buildText(string name, float price, bool withPrice) =>
    withPrice ? name + "  " + str.tostring(price, format.mintick) : name

drawLevel(float price, color col, string name, int xOffset,
          array<line> lines, array<label> labels) =>
    int lineEnd = bar_index + xOffset
    array.push(lines, line.new(bar_index, price, lineEnd, price,
         color  = col,
         style  = line.style_solid,
         width  = lineWidthInput,
         extend = extend.left))
    array.push(labels, label.new(lineEnd, price,
         text      = buildText(name, price, showPriceInput),
         style     = getLabelStyle(labelVInput),
         textcolor = col,
         color     = color.new(color.white, 100),
         size      = size.small))

//--------------------------------------------------------------------
// Data requests
//--------------------------------------------------------------------

[prevDayHigh,   prevDayLow]   = request.security(syminfo.tickerid, "1D", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[prevWeekHigh,  prevWeekLow]  = request.security(syminfo.tickerid, "1W", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[prevMonthHigh, prevMonthLow] = request.security(syminfo.tickerid, "1M", [high[1], low[1]], lookahead = barmerge.lookahead_on)

//--------------------------------------------------------------------
// Visibility guards
//--------------------------------------------------------------------

var bool canShowDaily   = true
var bool canShowWeekly  = true
var bool canShowMonthly = true

//--------------------------------------------------------------------
// Persistente Arrays
//--------------------------------------------------------------------

var array<line>  allLines  = array.new<line>()
var array<label> allLabels = array.new<label>()

//--------------------------------------------------------------------
// Draw
//--------------------------------------------------------------------

if barstate.islast
    // Alte Objekte löschen
    for ln in allLines
        line.delete(ln)
    for lb in allLabels
        label.delete(lb)
    array.clear(allLines)
    array.clear(allLabels)

    if showMonthlyInput and canShowMonthly
        drawLevel(prevMonthHigh, colorMonthlyHInput, "PMH", offsetInput, allLines, allLabels)
        drawLevel(prevMonthLow,  colorMonthlyLInput, "PML", offsetInput, allLines, allLabels)

    if showWeeklyInput and canShowWeekly
        drawLevel(prevWeekHigh, colorWeeklyHInput, "PWH", offsetInput, allLines, allLabels)
        drawLevel(prevWeekLow,  colorWeeklyLInput, "PWL", offsetInput, allLines, allLabels)

    if showDailyInput and canShowDaily
        drawLevel(prevDayHigh, colorDailyHInput, "PDH", offsetInput, allLines, allLabels)
        drawLevel(prevDayLow,  colorDailyLInput, "PDL", offsetInput, allLines, allLabels)

//--------------------------------------------------------------------
// Plot for data window / alerts
//--------------------------------------------------------------------

displayCtrl = display.data_window + display.status_line

plot(showDailyInput   and canShowDaily   ? prevDayHigh   : na, "PDH", colorDailyHInput,   display = displayCtrl)
plot(showDailyInput   and canShowDaily   ? prevDayLow    : na, "PDL", colorDailyLInput,   display = displayCtrl)
plot(showWeeklyInput  and canShowWeekly  ? prevWeekHigh  : na, "PWH", colorWeeklyHInput,  display = displayCtrl)
plot(showWeeklyInput  and canShowWeekly  ? prevWeekLow   : na, "PWL", colorWeeklyLInput,  display = displayCtrl)
plot(showMonthlyInput and canShowMonthly ? prevMonthHigh : na, "PMH", colorMonthlyHInput, display = displayCtrl)
plot(showMonthlyInput and canShowMonthly ? prevMonthLow  : na, "PML", colorMonthlyLInput, display = displayCtrl)
````
