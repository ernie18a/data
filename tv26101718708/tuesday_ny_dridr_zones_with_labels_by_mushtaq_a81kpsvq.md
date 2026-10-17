# Tuesday NY DR/IDR Zones with Labels by MUSHTAQ

- url: https://www.tradingview.com/script/a81kPsvQ-Tuesday-NY-DR-IDR-Zones-with-Labels-by-MUSHTAQ/
- type: indicator
- pine_id: PUB;51546a00efbc438083285b30a6c8de2a
- version: 1.0

## Description

tuesday historic dr idr levels and it also marks the month and week

## Source Code

````pine
//@version=5
indicator("Adjustable Tuesday NY DR/IDR Zones with Labels", overlay=true, max_boxes_count=500, max_labels_count=500)

// --- User Inputs ---
string sessionInput = input.session("0930-1030", title="NY DR/IDR Session Time")
string tzInput      = input.string("America/New_York", title="Timezone")
int weeksToLookback = input.int(10, title="Number of Weeks to Display", minval=1, maxval=250)

// Color & Style Settings
groupHigh = "DR/IDR Upper Zone Settings"
color colorHighZone = input.color(color.new(#2196f3, 85), title="Upper Zone Fill Color", group=groupHigh)
color colorHighBrd  = input.color(#2196f3, title="Upper Zone Border Color", group=groupHigh)
string styleHighBrd = input.string("Solid", title="Upper Border Style", options=["Solid", "Dashed", "Dotted"], group=groupHigh)

groupLow = "DR/IDR Lower Zone Settings"
color colorLowZone  = input.color(color.new(#ff9800, 85), title="Lower Zone Fill Color", group=groupLow)
color colorLowBrd   = input.color(#ff9800, title="Lower Zone Border Color", group=groupLow)
string styleLowBrd  = input.string("Solid", title="Lower Border Style", options=["Solid", "Dashed", "Dotted"], group=groupLow)

// --- Helper Functions ---
getLineStyle(styleText) =>
    styleText == "Dashed" ? line.style_dashed : styleText == "Dotted" ? line.style_dotted : line.style_solid

getMonthName(m) =>
    m == 1 ? "JAN" : m == 2 ? "FEB" : m == 3 ? "MAR" : m == 4 ? "APR" : m == 5 ? "MAY" : m == 6 ? "JUN" : m == 7 ? "JUL" : m == 8 ? "AUG" : m == 9 ? "SEP" : m == 10 ? "OCT" : m == 11 ? "NOV" : "DEC"

getWeekOfMonth(d) =>
    d <= 7 ? 1 : d <= 14 ? 2 : d <= 21 ? 3 : d <= 28 ? 4 : 5

// --- Calculations and Logic ---
inSession = not na(time(timeframe.period, sessionInput, tzInput))
isTuesday = dayofweek(time, tzInput) == dayofweek.tuesday

var bool processingSession = false
var int startBarIdx = na
var float currentDrHigh  = na
var float currentDrLow   = na
var float currentIdrHigh = na
var float currentIdrLow  = na

// Arrays to store historic elements for cleanup and tracking
var box[] topBoxes = array.new_box()
var box[] btmBoxes = array.new_box()
var label[] topLabels = array.new_label()
var label[] btmLabels = array.new_label()

sessionStarted = inSession and isTuesday and not processingSession
sessionEnded   = not inSession and processingSession

if sessionStarted
    processingSession := true
    startBarIdx     := bar_index
    currentDrHigh   := high
    currentDrLow    := low
    currentIdrHigh  := math.max(open, close)
    currentIdrLow   := math.min(open, close)
else if inSession and isTuesday and processingSession
    currentDrHigh   := math.max(high, currentDrHigh)
    currentDrLow    := math.min(low, currentDrLow)
    currentIdrHigh  := math.max(math.max(open, close), currentIdrHigh)
    currentIdrLow   := math.min(math.min(open, close), currentIdrLow)

if sessionEnded
    processingSession := false
    
    // Generate text label based on session date
    int sessionMonth = month(time, tzInput)
    int sessionDay   = dayofmonth(time, tzInput)
    string labelText = getMonthName(sessionMonth) + " Week " + str.tostring(getWeekOfMonth(sessionDay))
    
    // Create boxes
    tBox = box.new(left=startBarIdx, top=currentDrHigh, right=bar_index, bottom=currentIdrHigh,
                   bgcolor=colorHighZone, border_color=colorHighBrd, border_style=getLineStyle(styleHighBrd))
    bBox = box.new(left=startBarIdx, top=currentIdrLow, right=bar_index, bottom=currentDrLow,
                   bgcolor=colorLowZone, border_color=colorLowBrd, border_style=getLineStyle(styleLowBrd))
    
    // Create corresponding text labels placed at the right edge
    tLab = label.new(x=bar_index, y=currentDrHigh, text=labelText, color=color.new(color.black, 100), textcolor=colorHighBrd, style=label.style_label_left, size=size.small)
    bLab = label.new(x=bar_index, y=currentDrLow, text=labelText, color=color.new(color.black, 100), textcolor=colorLowBrd, style=label.style_label_left, size=size.small)
    
    // Push new structures into arrays
    array.push(topBoxes, tBox)
    array.push(btmBoxes, bBox)
    array.push(topLabels, tLab)
    array.push(btmLabels, bLab)
    
    // Dynamic clean up to maintain user lookback preference
    if array.size(topBoxes) > weeksToLookback
        box.delete(array.shift(topBoxes))
        box.delete(array.shift(btmBoxes))
        label.delete(array.shift(topLabels))
        label.delete(array.shift(btmLabels))

// Dynamically update positions to extend to the far right live edge
if array.size(topBoxes) > 0
    for i = 0 to array.size(topBoxes) - 1
        box.set_right(array.get(topBoxes, i), bar_index)
        box.set_right(array.get(btmBoxes, i), bar_index)
        label.set_x(array.get(topLabels, i), bar_index)
        label.set_x(array.get(btmLabels, i), bar_index)
````
