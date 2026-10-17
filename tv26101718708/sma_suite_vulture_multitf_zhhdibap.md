# SMA Suite Vulture Multi-TF

- url: https://www.tradingview.com/script/ZhhDIbAp-SMA-Suite-Vulture-Multi-TF/
- type: indicator
- pine_id: PUB;ba298dad68614e57839fcc8826019478
- version: 1.0

## Description

its a moving average indicator for multiple time frame

## Source Code

````pine
//@version=5
indicator("SMA Suite — Vulture (Multi-TF)", overlay=true, max_lines_count=15)

// ════════════════════════════════════════════════════════════════
// DAILY SMAs (active when chart is on daily timeframe)
// ════════════════════════════════════════════════════════════════
showD5    = input.bool(false, "Show",   inline="d5",   group="Daily — SMA 5")
lenD5     = input.int(5,      "Length", inline="d5",   group="Daily — SMA 5")
colD5     = input.color(color.yellow,  "Color", inline="d5", group="Daily — SMA 5")

showD10   = input.bool(true,  "Show",   inline="d10",  group="Daily — SMA 10")
lenD10    = input.int(10,     "Length", inline="d10",  group="Daily — SMA 10")
colD10    = input.color(color.aqua,    "Color", inline="d10", group="Daily — SMA 10")

showD20   = input.bool(true,  "Show",   inline="d20",  group="Daily — SMA 20")
lenD20    = input.int(20,     "Length", inline="d20",  group="Daily — SMA 20")
colD20    = input.color(color.orange,  "Color", inline="d20", group="Daily — SMA 20")

showD50   = input.bool(false, "Show",   inline="d50",  group="Daily — SMA 50")
lenD50    = input.int(50,     "Length", inline="d50",  group="Daily — SMA 50")
colD50    = input.color(color.fuchsia, "Color", inline="d50", group="Daily — SMA 50")

showD150  = input.bool(false, "Show",   inline="d150", group="Daily — SMA 150")
lenD150   = input.int(150,    "Length", inline="d150", group="Daily — SMA 150")
colD150   = input.color(color.blue,    "Color", inline="d150", group="Daily — SMA 150")

showD200  = input.bool(false, "Show",   inline="d200", group="Daily — SMA 200")
lenD200   = input.int(200,    "Length", inline="d200", group="Daily — SMA 200")
colD200   = input.color(color.white,   "Color", inline="d200", group="Daily — SMA 200")

// ════════════════════════════════════════════════════════════════
// WEEKLY SMAs (active when chart is on weekly timeframe)
// ════════════════════════════════════════════════════════════════
showW10  = input.bool(true,  "Show",   inline="w10", group="Weekly — SMA 10")
lenW10   = input.int(10,     "Length", inline="w10", group="Weekly — SMA 10")
colW10   = input.color(color.aqua,   "Color", inline="w10", group="Weekly — SMA 10")

showW30  = input.bool(true,  "Show",   inline="w30", group="Weekly — SMA 30")
lenW30   = input.int(30,     "Length", inline="w30", group="Weekly — SMA 30")
colW30   = input.color(color.orange, "Color", inline="w30", group="Weekly — SMA 30")

showW40  = input.bool(true,  "Show",   inline="w40", group="Weekly — SMA 40")
lenW40   = input.int(40,     "Length", inline="w40", group="Weekly — SMA 40")
colW40   = input.color(color.fuchsia,"Color", inline="w40", group="Weekly — SMA 40")

// ════════════════════════════════════════════════════════════════
// MONTHLY SMAs (active when chart is on monthly timeframe)
// ════════════════════════════════════════════════════════════════
showM10  = input.bool(true, "Show",   inline="m10", group="Monthly — SMA 10")
lenM10   = input.int(10,    "Length", inline="m10", group="Monthly — SMA 10")
colM10   = input.color(color.aqua,  "Color", inline="m10", group="Monthly — SMA 10")

// ════════════════════════════════════════════════════════════════
// LINE WIDTH
// ════════════════════════════════════════════════════════════════
maWidth  = input.int(1, "Line width", minval=1, maxval=5, group="SMA Lines")

// ════════════════════════════════════════════════════════════════
// % DISTANCE PANEL
// ════════════════════════════════════════════════════════════════
showPanel    = input.bool(true,  "Show % distance panel (daily + weekly)", group="Distance Panel")
panelShow50  = input.bool(false, "Include SMA 50 in daily panel",          group="Distance Panel")

position  = input.string("top_right", "Position",
     options=["top_left", "top_right", "bottom_left", "bottom_right", "middle_right"],
     group="Distance Panel")
textSize  = input.string("small", "Text size",
     options=["tiny", "small", "normal", "large"], group="Distance Panel")

colorAbove = input.color(color.lime,  "Color: ABOVE SMA", group="Distance Panel — Colors")
colorBelow = input.color(color.red,   "Color: BELOW SMA", group="Distance Panel — Colors")
labelColor = input.color(color.white, "Label text color", group="Distance Panel — Colors")
bgColor    = input.color(color.black, "Background color", group="Distance Panel — Colors")
bgOpacity  = input.int(70, "Background opacity (0=solid, 100=invisible)",
     minval=0, maxval=100, group="Distance Panel — Colors")

// ════════════════════════════════════════════════════════════════
// TIMEFRAME DETECTION
// ════════════════════════════════════════════════════════════════
isDaily   = timeframe.isdaily
isWeekly  = timeframe.isweekly
isMonthly = timeframe.ismonthly

// ════════════════════════════════════════════════════════════════
// CALCULATIONS
// ════════════════════════════════════════════════════════════════
// Daily set
smaD5   = ta.sma(close, lenD5)
smaD10  = ta.sma(close, lenD10)
smaD20  = ta.sma(close, lenD20)
smaD50  = ta.sma(close, lenD50)
smaD150 = ta.sma(close, lenD150)
smaD200 = ta.sma(close, lenD200)

// Weekly set
smaW10  = ta.sma(close, lenW10)
smaW30  = ta.sma(close, lenW30)
smaW40  = ta.sma(close, lenW40)

// Monthly set
smaM10  = ta.sma(close, lenM10)

// ════════════════════════════════════════════════════════════════
// PLOT — only the SMAs that match the current timeframe
// ════════════════════════════════════════════════════════════════
// Daily
plot(isDaily and showD5   ? smaD5   : na, "Daily SMA 5",   color=colD5,   linewidth=maWidth)
plot(isDaily and showD10  ? smaD10  : na, "Daily SMA 10",  color=colD10,  linewidth=maWidth)
plot(isDaily and showD20  ? smaD20  : na, "Daily SMA 20",  color=colD20,  linewidth=maWidth)
plot(isDaily and showD50  ? smaD50  : na, "Daily SMA 50",  color=colD50,  linewidth=maWidth)
plot(isDaily and showD150 ? smaD150 : na, "Daily SMA 150", color=colD150, linewidth=maWidth)
plot(isDaily and showD200 ? smaD200 : na, "Daily SMA 200", color=colD200, linewidth=maWidth)

// Weekly
plot(isWeekly and showW10 ? smaW10 : na, "Weekly SMA 10", color=colW10, linewidth=maWidth)
plot(isWeekly and showW30 ? smaW30 : na, "Weekly SMA 30", color=colW30, linewidth=maWidth)
plot(isWeekly and showW40 ? smaW40 : na, "Weekly SMA 40", color=colW40, linewidth=maWidth)

// Monthly
plot(isMonthly and showM10 ? smaM10 : na, "Monthly SMA 10", color=colM10, linewidth=maWidth)

// ════════════════════════════════════════════════════════════════
// HELPERS
// ════════════════════════════════════════════════════════════════
getPos(p) =>
    p == "top_left"     ? position.top_left     :
     p == "top_right"    ? position.top_right    :
     p == "bottom_left"  ? position.bottom_left  :
     p == "bottom_right" ? position.bottom_right :
     position.middle_right

getSize(s) =>
    s == "tiny"   ? size.tiny   :
     s == "small"  ? size.small  :
     s == "normal" ? size.normal :
     size.large

fmtPct(v) => (v >= 0 ? "+" : "") + str.tostring(v, "0.00") + "%"

// ════════════════════════════════════════════════════════════════
// DISTANCE CALCULATIONS — every timeframe
// ════════════════════════════════════════════════════════════════
// Daily
dD10 = (close - smaD10) / smaD10 * 100
dD20 = (close - smaD20) / smaD20 * 100
dD50 = (close - smaD50) / smaD50 * 100

// Weekly
dW10 = (close - smaW10) / smaW10 * 100
dW30 = (close - smaW30) / smaW30 * 100
dW40 = (close - smaW40) / smaW40 * 100

// Monthly
dM10 = (close - smaM10) / smaM10 * 100

// ════════════════════════════════════════════════════════════════
// PANEL — DAILY (10, 20, optional 50) + WEEKLY (10W)
// ════════════════════════════════════════════════════════════════
var table panel = table.new(getPos(position), 2, 3,
     bgcolor=color.new(bgColor, bgOpacity),
     border_width=1, border_color=color.gray)

addRow(rowIdx, lbl, val) =>
    c = val >= 0 ? colorAbove : colorBelow
    table.cell(panel, 0, rowIdx, lbl, text_color=labelColor, text_size=getSize(textSize))
    table.cell(panel, 1, rowIdx, fmtPct(val), text_color=c, text_size=getSize(textSize))

if showPanel and barstate.islast
    table.clear(panel, 0, 0, 1, 2)
    if isDaily
        addRow(0, "SMA " + str.tostring(lenD10), dD10)
        addRow(1, "SMA " + str.tostring(lenD20), dD20)
        if panelShow50
            addRow(2, "SMA " + str.tostring(lenD50), dD50)
    if isWeekly
        addRow(0, "W-SMA " + str.tostring(lenW10), dW10)

// ════════════════════════════════════════════════════════════════
// DATA WINDOW — distances visible at crosshair (hover any bar)
// Press Alt+D (Cmd+Option+D on Mac) to open the Data Window panel.
// Move the crosshair over any bar — values update for that bar.
// ════════════════════════════════════════════════════════════════
plot(isDaily   ? dD10 : na, "Dist % SMA 10D",  display=display.data_window)
plot(isDaily   ? dD20 : na, "Dist % SMA 20D",  display=display.data_window)
plot(isDaily   ? dD50 : na, "Dist % SMA 50D",  display=display.data_window)

plot(isWeekly  ? dW10 : na, "Dist % SMA 10W",  display=display.data_window)
plot(isWeekly  ? dW30 : na, "Dist % SMA 30W",  display=display.data_window)
plot(isWeekly  ? dW40 : na, "Dist % SMA 40W",  display=display.data_window)

plot(isMonthly ? dM10 : na, "Dist % SMA 10M",  display=display.data_window)
````
