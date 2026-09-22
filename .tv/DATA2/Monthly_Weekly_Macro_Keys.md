<!-- tradingview-pine-id: PUB;11debc7e3319460b938d7cc5c9facbad -->
<!-- tradingview-pine-version: 5.0 -->
<!-- tradingviewscripts-format: 1 -->
# Monthly & Weekly Macro Keys

Source: https://www.tradingview.com/script/qF4c7nsA-Monthly-Weekly-Macro-Keys/

## Description

Monthly & Weekly Macro Keys plots completed monthly and weekly High, Low, Open, and Close levels with composite IPDA-style premium/discount context.

Monthly macros default to the last three completed months. Each level is labeled by calendar month (for example, June 2026 Monthly High). Weekly macro key levels default to the prior completed week High and Low, with optional Open and Close. Lines begin on the day the print occurred and extend to a configurable right-side buffer next to the labels.

A composite range is built from the selected months or weeks. The indicator can draw the IPDA gradient through that range: 12.5%, 25%, 37.5%, equilibrium (50%), 62.5%, 75%, and 87.5%. High and Low of the composite are not duplicated on the gradient because they are already shown as the monthly or weekly macros.

An on-chart table reports Premium or Discount relative to equilibrium, percent location within the range, whether price is inside the 25–75% zone, and the key price levels for both the monthly and weekly composites.

Style controls include color, width, and line style (Solid, Dotted, Dashed) for monthly and weekly High, Low, and Open/Close, as well as for gradient quadrant and octant levels. Table position supports all nine chart anchors. Lookback counts are adjustable (up to six months and eight weeks).

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MadMonkTrading

//@version=6
indicator("Monthly & Weekly Macro Keys", shorttitle="M/W Macro Keys", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=50, max_bars_back=5000)

// ──────────────────────────────────
// SETTINGS
// ──────────────────────────────────

// === MONTHLY MACROS ===
showMonthlyMacros = input.bool(true, "Show Monthly Macros", group="MONTHLY MACROS")
monthlyMacroCount = input.int(3, "Months to Show", minval=1, maxval=6, group="MONTHLY MACROS",
     tooltip="Previous completed months only. Current month is excluded.")
showMonthlyOC = input.bool(true, "Show Monthly Open & Close", group="MONTHLY MACROS")
showMonthlyGradient = input.bool(true, "Show Monthly Composite IPDA Gradient", group="MONTHLY MACROS",
     tooltip="87.5% / 75% / 62.5% / EQ / 37.5% / 25% / 12.5% of the combined previous-N-month range. High and Low are the monthly macros themselves.")
monthlyHighColor = input.color(color.rgb(0, 51, 153), "Monthly High", group="MONTHLY MACROS", inline="mh")
monthlyHighStyle = input.string("Solid", "", options=["Solid", "Dotted", "Dashed"], group="MONTHLY MACROS", inline="mh")
monthlyHighWidth = input.int(2, "", minval=1, maxval=5, group="MONTHLY MACROS", inline="mh")
monthlyLowColor  = input.color(color.rgb(139, 0, 0), "Monthly Low", group="MONTHLY MACROS", inline="ml")
monthlyLowStyle  = input.string("Solid", "", options=["Solid", "Dotted", "Dashed"], group="MONTHLY MACROS", inline="ml")
monthlyLowWidth  = input.int(2, "", minval=1, maxval=5, group="MONTHLY MACROS", inline="ml")
monthlyOCColor   = input.color(color.black, "Monthly Open/Close", group="MONTHLY MACROS", inline="moc")
monthlyOCStyle   = input.string("Dashed", "", options=["Solid", "Dotted", "Dashed"], group="MONTHLY MACROS", inline="moc")
monthlyOCWidth   = input.int(1, "", minval=1, maxval=5, group="MONTHLY MACROS", inline="moc")

// === WEEKLY MACROS ===
showWeeklyMacros = input.bool(true, "Show Weekly Macros", group="WEEKLY MACROS")
weeklyMacroCount = input.int(1, "Weeks to Show", minval=1, maxval=8, group="WEEKLY MACROS",
     tooltip="Default 1 = previous completed week only.")
showWeeklyOC = input.bool(false, "Show Weekly Open & Close", group="WEEKLY MACROS",
     tooltip="OFF by default — weekly macros plot High and Low only.")
showWeeklyGradient = input.bool(true, "Show Weekly Composite IPDA Gradient", group="WEEKLY MACROS",
     tooltip="87.5% / 75% / 62.5% / EQ / 37.5% / 25% / 12.5% of the combined previous-N-week range. High and Low are the weekly macros themselves.")
weeklyHighColor = input.color(color.rgb(0, 51, 153), "Weekly High", group="WEEKLY MACROS", inline="wh")
weeklyHighStyle = input.string("Solid", "", options=["Solid", "Dotted", "Dashed"], group="WEEKLY MACROS", inline="wh")
weeklyHighWidth = input.int(2, "", minval=1, maxval=5, group="WEEKLY MACROS", inline="wh")
weeklyLowColor  = input.color(color.rgb(139, 0, 0), "Weekly Low", group="WEEKLY MACROS", inline="wl")
weeklyLowStyle  = input.string("Solid", "", options=["Solid", "Dotted", "Dashed"], group="WEEKLY MACROS", inline="wl")
weeklyLowWidth  = input.int(2, "", minval=1, maxval=5, group="WEEKLY MACROS", inline="wl")
weeklyOCColor   = input.color(color.black, "Weekly Open/Close", group="WEEKLY MACROS", inline="woc")
weeklyOCStyle   = input.string("Dashed", "", options=["Solid", "Dotted", "Dashed"], group="WEEKLY MACROS", inline="woc")
weeklyOCWidth   = input.int(1, "", minval=1, maxval=5, group="WEEKLY MACROS", inline="woc")

// === GRADIENT LINE STYLES ===
gradQuadColor = input.color(color.black, "Quadrants / EQ (25/50/75)", group="GRADIENT STYLES", inline="gq")
gradQuadStyle = input.string("Dashed", "", options=["Solid", "Dotted", "Dashed"], group="GRADIENT STYLES", inline="gq")
gradQuadWidth = input.int(1, "", minval=1, maxval=5, group="GRADIENT STYLES", inline="gq")
gradOctColor  = input.color(color.gray, "Octants (12.5/37.5/62.5/87.5)", group="GRADIENT STYLES", inline="go")
gradOctStyle  = input.string("Dotted", "", options=["Solid", "Dotted", "Dashed"], group="GRADIENT STYLES", inline="go")
gradOctWidth  = input.int(1, "", minval=1, maxval=5, group="GRADIENT STYLES", inline="go")

// === APPEARANCE ===
bufferCandles  = input.int(10, "Right Buffer (Candles)", minval=0, group="APPEARANCE")
labelSizeIn    = input.string("small", "Label Size", options=["tiny", "small", "normal", "large"], group="APPEARANCE")
tablePos       = input.string("top_right", "Table Position", options=["top_left","top_center","top_right","middle_left","middle_center","middle_right","bottom_left","bottom_center","bottom_right"], group="APPEARANCE")
tableTextSize  = input.string("small", "Table Text Size", options=["tiny", "small", "normal", "large"], group="APPEARANCE")
tableBgOpacity = input.int(20, "Table Background Opacity", minval=0, maxval=100, group="APPEARANCE")

// ──────────────────────────────────
// HELPERS
// ──────────────────────────────────
get_precision() =>
    float mt = syminfo.mintick
    int prec = 0
    while mt != math.round(mt)
        mt := mt * 10
        prec += 1
    prec

var int precision_val = get_precision()
var string priceFmt = "#." + str.repeat("#", precision_val)

getLabelSize() =>
    labelSizeIn == "tiny" ? size.tiny : labelSizeIn == "small" ? size.small : labelSizeIn == "normal" ? size.normal : size.large

getTableTextSize() =>
    tableTextSize == "tiny" ? size.tiny : tableTextSize == "small" ? size.small : tableTextSize == "normal" ? size.normal : size.large

styleFromString(_s) =>
    _s == "Dotted" ? line.style_dotted : _s == "Dashed" ? line.style_dashed : line.style_solid

monthlyHighStyleEnum = styleFromString(monthlyHighStyle)
monthlyLowStyleEnum  = styleFromString(monthlyLowStyle)
monthlyOCStyleEnum   = styleFromString(monthlyOCStyle)
weeklyHighStyleEnum  = styleFromString(weeklyHighStyle)
weeklyLowStyleEnum   = styleFromString(weeklyLowStyle)
weeklyOCStyleEnum    = styleFromString(weeklyOCStyle)
gradQuadStyleEnum    = styleFromString(gradQuadStyle)
gradOctStyleEnum     = styleFromString(gradOctStyle)

tablePositionFrom(_s) =>
    _s == "top_left" ? position.top_left :
     _s == "top_center" ? position.top_center :
     _s == "top_right" ? position.top_right :
     _s == "middle_left" ? position.middle_left :
     _s == "middle_center" ? position.middle_center :
     _s == "middle_right" ? position.middle_right :
     _s == "bottom_left" ? position.bottom_left :
     _s == "bottom_center" ? position.bottom_center :
     position.bottom_right

rightEdgeTime() =>
    time + int(math.max(bufferCandles, 1) * timeframe.in_seconds() * 1000)

percenter(top, bottom) =>
    top == bottom ? na : math.round(((close - bottom) / (top - bottom)) * 100, 1)

// Midpoint of the HTF bar so a June bar that opens May 31 is still named June.
periodNameFromTimes(int tStart, int tEnd, string style) =>
    int mid = tStart
    if not na(tEnd) and tEnd > tStart
        mid := int((tStart + tEnd) / 2)
    style == "week" ? "Week of " + str.format_time(mid, "MMM dd yyyy", syminfo.timezone) : str.format_time(mid, "MMMM yyyy", syminfo.timezone)

// ──────────────────────────────────
// HTF DATA — previous completed periods only
// ──────────────────────────────────
// Include the current HTF bar when that bar is already complete
// (common after the last session of a month, before the next month prints).
// Skip it only while its calendar month/week is still the live one.
[mO0, mH0, mL0, mC0, mT0, mTC0, mO1, mH1, mL1, mC1, mT1, mTC1, mO2, mH2, mL2, mC2, mT2, mTC2, mO3, mH3, mL3, mC3, mT3, mTC3, mO4, mH4, mL4, mC4, mT4, mTC4, mO5, mH5, mL5, mC5, mT5, mTC5, mO6, mH6, mL6, mC6, mT6, mTC6] =
     request.security(syminfo.tickerid, "1M",
          [open, high, low, close, time, time_close,
           open[1], high[1], low[1], close[1], time[1], time_close[1],
           open[2], high[2], low[2], close[2], time[2], time_close[2],
           open[3], high[3], low[3], close[3], time[3], time_close[3],
           open[4], high[4], low[4], close[4], time[4], time_close[4],
           open[5], high[5], low[5], close[5], time[5], time_close[5],
           open[6], high[6], low[6], close[6], time[6], time_close[6]])

// Skip the HTF bar while its calendar month is still live, or its close is still ahead.
bool liveMonthBar = not na(mT0) and year(timenow, syminfo.timezone) * 12 + month(timenow, syminfo.timezone) == year(mT0, syminfo.timezone) * 12 + month(mT0, syminfo.timezone)
int mOff = liveMonthBar or na(mTC0) or mTC0 > timenow ? 1 : 0

[wO0, wH0, wL0, wC0, wT0, wTC0, wO1, wH1, wL1, wC1, wT1, wTC1, wO2, wH2, wL2, wC2, wT2, wTC2, wO3, wH3, wL3, wC3, wT3, wTC3, wO4, wH4, wL4, wC4, wT4, wTC4, wO5, wH5, wL5, wC5, wT5, wTC5, wO6, wH6, wL6, wC6, wT6, wTC6, wO7, wH7, wL7, wC7, wT7, wTC7, wO8, wH8, wL8, wC8, wT8, wTC8] =
     request.security(syminfo.tickerid, "1W",
          [open, high, low, close, time, time_close,
           open[1], high[1], low[1], close[1], time[1], time_close[1],
           open[2], high[2], low[2], close[2], time[2], time_close[2],
           open[3], high[3], low[3], close[3], time[3], time_close[3],
           open[4], high[4], low[4], close[4], time[4], time_close[4],
           open[5], high[5], low[5], close[5], time[5], time_close[5],
           open[6], high[6], low[6], close[6], time[6], time_close[6],
           open[7], high[7], low[7], close[7], time[7], time_close[7],
           open[8], high[8], low[8], close[8], time[8], time_close[8]])

int wOff = not na(wTC0) and wTC0 > timenow ? 1 : 0

f_mOHLC(int raw, string field) =>
    raw == 0 ? (field == "H" ? mH0 : field == "L" ? mL0 : field == "O" ? mO0 : field == "C" ? mC0 : field == "T" ? mT0 : mTC0) :
     raw == 1 ? (field == "H" ? mH1 : field == "L" ? mL1 : field == "O" ? mO1 : field == "C" ? mC1 : field == "T" ? mT1 : mTC1) :
     raw == 2 ? (field == "H" ? mH2 : field == "L" ? mL2 : field == "O" ? mO2 : field == "C" ? mC2 : field == "T" ? mT2 : mTC2) :
     raw == 3 ? (field == "H" ? mH3 : field == "L" ? mL3 : field == "O" ? mO3 : field == "C" ? mC3 : field == "T" ? mT3 : mTC3) :
     raw == 4 ? (field == "H" ? mH4 : field == "L" ? mL4 : field == "O" ? mO4 : field == "C" ? mC4 : field == "T" ? mT4 : mTC4) :
     raw == 5 ? (field == "H" ? mH5 : field == "L" ? mL5 : field == "O" ? mO5 : field == "C" ? mC5 : field == "T" ? mT5 : mTC5) :
     (field == "H" ? mH6 : field == "L" ? mL6 : field == "O" ? mO6 : field == "C" ? mC6 : field == "T" ? mT6 : mTC6)

f_wOHLC(int raw, string field) =>
    raw == 0 ? (field == "H" ? wH0 : field == "L" ? wL0 : field == "O" ? wO0 : field == "C" ? wC0 : field == "T" ? wT0 : wTC0) :
     raw == 1 ? (field == "H" ? wH1 : field == "L" ? wL1 : field == "O" ? wO1 : field == "C" ? wC1 : field == "T" ? wT1 : wTC1) :
     raw == 2 ? (field == "H" ? wH2 : field == "L" ? wL2 : field == "O" ? wO2 : field == "C" ? wC2 : field == "T" ? wT2 : wTC2) :
     raw == 3 ? (field == "H" ? wH3 : field == "L" ? wL3 : field == "O" ? wO3 : field == "C" ? wC3 : field == "T" ? wT3 : wTC3) :
     raw == 4 ? (field == "H" ? wH4 : field == "L" ? wL4 : field == "O" ? wO4 : field == "C" ? wC4 : field == "T" ? wT4 : wTC4) :
     raw == 5 ? (field == "H" ? wH5 : field == "L" ? wL5 : field == "O" ? wO5 : field == "C" ? wC5 : field == "T" ? wT5 : wTC5) :
     raw == 6 ? (field == "H" ? wH6 : field == "L" ? wL6 : field == "O" ? wO6 : field == "C" ? wC6 : field == "T" ? wT6 : wTC6) :
     raw == 7 ? (field == "H" ? wH7 : field == "L" ? wL7 : field == "O" ? wO7 : field == "C" ? wC7 : field == "T" ? wT7 : wTC7) :
     (field == "H" ? wH8 : field == "L" ? wL8 : field == "O" ? wO8 : field == "C" ? wC8 : field == "T" ? wT8 : wTC8)

f_monthHigh(int i) => f_mOHLC(mOff + i - 1, "H")
f_monthLow(int i)  => f_mOHLC(mOff + i - 1, "L")
f_monthOpen(int i) => f_mOHLC(mOff + i - 1, "O")
f_monthClose(int i)=> f_mOHLC(mOff + i - 1, "C")
f_monthTime(int i) => f_mOHLC(mOff + i - 1, "T")
f_monthTimeClose(int i) => f_mOHLC(mOff + i - 1, "TC")

f_weekHigh(int i) => f_wOHLC(wOff + i - 1, "H")
f_weekLow(int i)  => f_wOHLC(wOff + i - 1, "L")
f_weekOpen(int i) => f_wOHLC(wOff + i - 1, "O")
f_weekClose(int i)=> f_wOHLC(wOff + i - 1, "C")
f_weekTime(int i) => f_wOHLC(wOff + i - 1, "T")
f_weekTimeClose(int i) => f_wOHLC(wOff + i - 1, "TC")

// Daily context: timestamp of the day the period high/low/open/close printed.
// Tracks extremes on the daily series, then reads the completed period via valuewhen.
// occurrence n-1: n=1 → most recent completed month/week.
periodPrintTimes(string periodTF, int n) =>
    bool newP = ta.change(time(periodTF)) != 0
    var float runH = high
    var float runL = low
    var int runHT = time
    var int runLT = time
    if newP
        runH := high
        runL := low
        runHT := time
        runLT := time
    else
        if high >= runH
            runH := high
            runHT := time
        if low <= runL
            runL := low
            runLT := time
    int occ = n - 1
    int hT = ta.valuewhen(newP, runHT[1], occ)
    int lT = ta.valuewhen(newP, runLT[1], occ)
    int oT = ta.valuewhen(newP, time, n)
    int cT = ta.valuewhen(newP, time[1], occ)
    [hT, lT, oT, cT]

[mHT1, mLT1, mOT1, mCT1] = request.security(syminfo.tickerid, "D", periodPrintTimes("1M", 1))
[mHT2, mLT2, mOT2, mCT2] = request.security(syminfo.tickerid, "D", periodPrintTimes("1M", 2))
[mHT3, mLT3, mOT3, mCT3] = request.security(syminfo.tickerid, "D", periodPrintTimes("1M", 3))
[mHT4, mLT4, mOT4, mCT4] = request.security(syminfo.tickerid, "D", periodPrintTimes("1M", 4))
[mHT5, mLT5, mOT5, mCT5] = request.security(syminfo.tickerid, "D", periodPrintTimes("1M", 5))
[mHT6, mLT6, mOT6, mCT6] = request.security(syminfo.tickerid, "D", periodPrintTimes("1M", 6))

[wHT1, wLT1, wOT1, wCT1] = request.security(syminfo.tickerid, "D", periodPrintTimes("1W", 1))
[wHT2, wLT2, wOT2, wCT2] = request.security(syminfo.tickerid, "D", periodPrintTimes("1W", 2))
[wHT3, wLT3, wOT3, wCT3] = request.security(syminfo.tickerid, "D", periodPrintTimes("1W", 3))
[wHT4, wLT4, wOT4, wCT4] = request.security(syminfo.tickerid, "D", periodPrintTimes("1W", 4))
[wHT5, wLT5, wOT5, wCT5] = request.security(syminfo.tickerid, "D", periodPrintTimes("1W", 5))
[wHT6, wLT6, wOT6, wCT6] = request.security(syminfo.tickerid, "D", periodPrintTimes("1W", 6))
[wHT7, wLT7, wOT7, wCT7] = request.security(syminfo.tickerid, "D", periodPrintTimes("1W", 7))
[wHT8, wLT8, wOT8, wCT8] = request.security(syminfo.tickerid, "D", periodPrintTimes("1W", 8))

f_monthHighTime(int i) => i == 1 ? mHT1 : i == 2 ? mHT2 : i == 3 ? mHT3 : i == 4 ? mHT4 : i == 5 ? mHT5 : mHT6
f_monthLowTime(int i)  => i == 1 ? mLT1 : i == 2 ? mLT2 : i == 3 ? mLT3 : i == 4 ? mLT4 : i == 5 ? mLT5 : mLT6
f_monthOpenTime(int i) => i == 1 ? mOT1 : i == 2 ? mOT2 : i == 3 ? mOT3 : i == 4 ? mOT4 : i == 5 ? mOT5 : mOT6
f_monthCloseTime(int i)=> i == 1 ? mCT1 : i == 2 ? mCT2 : i == 3 ? mCT3 : i == 4 ? mCT4 : i == 5 ? mCT5 : mCT6

f_weekHighTime(int i) => i == 1 ? wHT1 : i == 2 ? wHT2 : i == 3 ? wHT3 : i == 4 ? wHT4 : i == 5 ? wHT5 : i == 6 ? wHT6 : i == 7 ? wHT7 : wHT8
f_weekLowTime(int i)  => i == 1 ? wLT1 : i == 2 ? wLT2 : i == 3 ? wLT3 : i == 4 ? wLT4 : i == 5 ? wLT5 : i == 6 ? wLT6 : i == 7 ? wLT7 : wLT8
f_weekOpenTime(int i) => i == 1 ? wOT1 : i == 2 ? wOT2 : i == 3 ? wOT3 : i == 4 ? wOT4 : i == 5 ? wOT5 : i == 6 ? wOT6 : i == 7 ? wOT7 : wOT8
f_weekCloseTime(int i)=> i == 1 ? wCT1 : i == 2 ? wCT2 : i == 3 ? wCT3 : i == 4 ? wCT4 : i == 5 ? wCT5 : i == 6 ? wCT6 : i == 7 ? wCT7 : wCT8

// Composite ranges (respect mOff / wOff)
float monthlyRangeHigh = f_monthHigh(1)
float monthlyRangeLow  = f_monthLow(1)
if monthlyMacroCount >= 2
    monthlyRangeHigh := math.max(monthlyRangeHigh, f_monthHigh(2))
    monthlyRangeLow  := math.min(monthlyRangeLow, f_monthLow(2))
if monthlyMacroCount >= 3
    monthlyRangeHigh := math.max(monthlyRangeHigh, f_monthHigh(3))
    monthlyRangeLow  := math.min(monthlyRangeLow, f_monthLow(3))
if monthlyMacroCount >= 4
    monthlyRangeHigh := math.max(monthlyRangeHigh, f_monthHigh(4))
    monthlyRangeLow  := math.min(monthlyRangeLow, f_monthLow(4))
if monthlyMacroCount >= 5
    monthlyRangeHigh := math.max(monthlyRangeHigh, f_monthHigh(5))
    monthlyRangeLow  := math.min(monthlyRangeLow, f_monthLow(5))
if monthlyMacroCount >= 6
    monthlyRangeHigh := math.max(monthlyRangeHigh, f_monthHigh(6))
    monthlyRangeLow  := math.min(monthlyRangeLow, f_monthLow(6))

float weeklyRangeHigh = f_weekHigh(1)
float weeklyRangeLow  = f_weekLow(1)
if weeklyMacroCount >= 2
    weeklyRangeHigh := math.max(weeklyRangeHigh, f_weekHigh(2))
    weeklyRangeLow  := math.min(weeklyRangeLow, f_weekLow(2))
if weeklyMacroCount >= 3
    weeklyRangeHigh := math.max(weeklyRangeHigh, f_weekHigh(3))
    weeklyRangeLow  := math.min(weeklyRangeLow, f_weekLow(3))
if weeklyMacroCount >= 4
    weeklyRangeHigh := math.max(weeklyRangeHigh, f_weekHigh(4))
    weeklyRangeLow  := math.min(weeklyRangeLow, f_weekLow(4))
if weeklyMacroCount >= 5
    weeklyRangeHigh := math.max(weeklyRangeHigh, f_weekHigh(5))
    weeklyRangeLow  := math.min(weeklyRangeLow, f_weekLow(5))
if weeklyMacroCount >= 6
    weeklyRangeHigh := math.max(weeklyRangeHigh, f_weekHigh(6))
    weeklyRangeLow  := math.min(weeklyRangeLow, f_weekLow(6))
if weeklyMacroCount >= 7
    weeklyRangeHigh := math.max(weeklyRangeHigh, f_weekHigh(7))
    weeklyRangeLow  := math.min(weeklyRangeLow, f_weekLow(7))
if weeklyMacroCount >= 8
    weeklyRangeHigh := math.max(weeklyRangeHigh, f_weekHigh(8))
    weeklyRangeLow  := math.min(weeklyRangeLow, f_weekLow(8))

float monthlyEq  = (monthlyRangeHigh + monthlyRangeLow) / 2
float weeklyEq   = (weeklyRangeHigh + weeklyRangeLow) / 2
float monthlyQ25 = monthlyRangeLow + 0.25 * (monthlyRangeHigh - monthlyRangeLow)
float monthlyQ75 = monthlyRangeLow + 0.75 * (monthlyRangeHigh - monthlyRangeLow)
float weeklyQ25  = weeklyRangeLow + 0.25 * (weeklyRangeHigh - weeklyRangeLow)
float weeklyQ75  = weeklyRangeLow + 0.75 * (weeklyRangeHigh - weeklyRangeLow)

percentMonthly = percenter(monthlyRangeHigh, monthlyRangeLow)
percentWeekly  = percenter(weeklyRangeHigh, weeklyRangeLow)
locMonthly = close < monthlyEq
locWeekly  = close < weeklyEq
midMonthly = close >= monthlyQ25 and close <= monthlyQ75
midWeekly  = close >= weeklyQ25 and close <= weeklyQ75

// ──────────────────────────────────
// DRAW
// ──────────────────────────────────
var array<line> monthlyMacroLines = array.new_line()
var array<label> monthlyMacroLabels = array.new_label()
var array<line> weeklyMacroLines = array.new_line()
var array<label> weeklyMacroLabels = array.new_label()

deleteLinesAndLabels(_lines_array, _labels_array) =>
    for l in _lines_array
        line.delete(l)
    for lb in _labels_array
        label.delete(lb)
    array.clear(_lines_array)
    array.clear(_labels_array)

// Last-bar scan: exact pivot candle on the active chart timeframe.
scanPivots(int tStart, int tEnd, float offH, float offL) =>
    int ht = tStart
    int lt = tStart
    int ot = tStart
    int ct = tEnd
    float tick = syminfo.mintick
    int sec = math.max(timeframe.in_seconds(), 1)
    int pad = 12 * 60 * 60 * 1000
    int winStart = tStart > pad ? tStart - pad : tStart
    int need = int((time - winStart) / (sec * 1000)) + 300
    int maxLook = math.min(bar_index, need)
    if maxLook > 4998
        maxLook := 4998
    bool seen = false
    if winStart > 0
        for i = 0 to maxLook
            if i > bar_index
                break
            int ti = time[i]
            if ti < winStart
                break
            if not na(tEnd) and tEnd > 0 and ti > tEnd + pad
                continue
            bool inCore = ti >= tStart and (na(tEnd) or tEnd <= 0 or ti <= tEnd)
            if inCore
                if not seen
                    ct := ti
                    seen := true
                ot := ti
                if not na(offH) and math.abs(high[i] - offH) <= tick
                    ht := ti
                if not na(offL) and math.abs(low[i] - offL) <= tick
                    lt := ti
    [ht, lt, ot, ct]

scanOne(int tStart, int tEnd, float offH, float offL, string kind) =>
    [ht, lt, ot, ct] = scanPivots(tStart, tEnd, offH, offL)
    kind == "H" ? ht : kind == "L" ? lt : kind == "O" ? ot : ct

drawMacroLevel(int printTime, int tStart, int tEnd, float lvl, string kind, color col, string sty, int w, string txt, color txtCol, array<line> linesArr, array<label> labelsArr) =>
    int leftT = printTime
    if na(leftT) or leftT <= 0
        leftT := kind == "C" ? tEnd : tStart
    int rightT = rightEdgeTime()
    if na(leftT) or leftT <= 0
        leftT := time
    if leftT > rightT
        leftT := time
    line ln = line.new(leftT, lvl, rightT, lvl, xloc=xloc.bar_time, extend=extend.none, color=col, style=sty, width=w)
    array.push(linesArr, ln)
    label lb = label.new(bar_index + bufferCandles, lvl, txt + "  " + str.tostring(lvl, priceFmt), xloc=xloc.bar_index, style=label.style_label_left, size=getLabelSize(), color=color.new(color.black, 100), textcolor=txtCol)
    array.push(labelsArr, lb)

drawCompositeGradient(int tStart, float rngHigh, float rngLow, string prefix, array<line> linesArr, array<label> labelsArr) =>
    float r = rngHigh - rngLow
    float eq  = rngLow + 0.50 * r
    float q25 = rngLow + 0.25 * r
    float q75 = rngLow + 0.75 * r
    float o12 = rngLow + 0.125 * r
    float o37 = rngLow + 0.375 * r
    float o62 = rngLow + 0.625 * r
    float o87 = rngLow + 0.875 * r
    int rightT = rightEdgeTime()
    int rightX = bar_index + bufferCandles
    lSize = getLabelSize()
    // Quadrants + EQ
    array.push(linesArr, line.new(tStart, q75, rightT, q75, xloc=xloc.bar_time, extend=extend.none, color=gradQuadColor, style=gradQuadStyleEnum, width=gradQuadWidth))
    array.push(linesArr, line.new(tStart, eq,  rightT, eq,  xloc=xloc.bar_time, extend=extend.none, color=gradQuadColor, style=gradQuadStyleEnum, width=gradQuadWidth))
    array.push(linesArr, line.new(tStart, q25, rightT, q25, xloc=xloc.bar_time, extend=extend.none, color=gradQuadColor, style=gradQuadStyleEnum, width=gradQuadWidth))
    // Octants
    array.push(linesArr, line.new(tStart, o87, rightT, o87, xloc=xloc.bar_time, extend=extend.none, color=gradOctColor, style=gradOctStyleEnum, width=gradOctWidth))
    array.push(linesArr, line.new(tStart, o62, rightT, o62, xloc=xloc.bar_time, extend=extend.none, color=gradOctColor, style=gradOctStyleEnum, width=gradOctWidth))
    array.push(linesArr, line.new(tStart, o37, rightT, o37, xloc=xloc.bar_time, extend=extend.none, color=gradOctColor, style=gradOctStyleEnum, width=gradOctWidth))
    array.push(linesArr, line.new(tStart, o12, rightT, o12, xloc=xloc.bar_time, extend=extend.none, color=gradOctColor, style=gradOctStyleEnum, width=gradOctWidth))
    array.push(labelsArr, label.new(rightX, o87, prefix + " 87.5%  " + str.tostring(o87, priceFmt), xloc=xloc.bar_index, style=label.style_label_left, size=lSize, color=color.new(color.black, 100), textcolor=gradOctColor))
    array.push(labelsArr, label.new(rightX, q75, prefix + " 75%  " + str.tostring(q75, priceFmt), xloc=xloc.bar_index, style=label.style_label_left, size=lSize, color=color.new(color.black, 100), textcolor=gradQuadColor))
    array.push(labelsArr, label.new(rightX, o62, prefix + " 62.5%  " + str.tostring(o62, priceFmt), xloc=xloc.bar_index, style=label.style_label_left, size=lSize, color=color.new(color.black, 100), textcolor=gradOctColor))
    array.push(labelsArr, label.new(rightX, eq,  prefix + " EQ  " + str.tostring(eq, priceFmt), xloc=xloc.bar_index, style=label.style_label_left, size=lSize, color=color.new(color.black, 100), textcolor=gradQuadColor))
    array.push(labelsArr, label.new(rightX, o37, prefix + " 37.5%  " + str.tostring(o37, priceFmt), xloc=xloc.bar_index, style=label.style_label_left, size=lSize, color=color.new(color.black, 100), textcolor=gradOctColor))
    array.push(labelsArr, label.new(rightX, q25, prefix + " 25%  " + str.tostring(q25, priceFmt), xloc=xloc.bar_index, style=label.style_label_left, size=lSize, color=color.new(color.black, 100), textcolor=gradQuadColor))
    array.push(labelsArr, label.new(rightX, o12, prefix + " 12.5%  " + str.tostring(o12, priceFmt), xloc=xloc.bar_index, style=label.style_label_left, size=lSize, color=color.new(color.black, 100), textcolor=gradOctColor))

if barstate.islast
    deleteLinesAndLabels(monthlyMacroLines, monthlyMacroLabels)
    if showMonthlyMacros
        for i = 1 to monthlyMacroCount
            float mh = f_monthHigh(i)
            float ml = f_monthLow(i)
            float mo = f_monthOpen(i)
            float mc = f_monthClose(i)
            int   mt = math.round(f_monthTime(i))
            int   mtc = math.round(f_monthTimeClose(i))
            bool monthStillLive = mt > 0 and year(mt, syminfo.timezone) == year(timenow, syminfo.timezone) and month(mt, syminfo.timezone) == month(timenow, syminfo.timezone)
            if not na(mh) and not na(ml) and mt > 0 and not monthStillLive and (na(mtc) or mtc <= timenow)
                string mName = periodNameFromTimes(mt, mtc, "month")
                drawMacroLevel(scanOne(mt, mtc, mh, ml, "H"), mt, mtc, mh, "H", monthlyHighColor, monthlyHighStyleEnum, monthlyHighWidth, mName + " Monthly High", monthlyHighColor, monthlyMacroLines, monthlyMacroLabels)
                drawMacroLevel(scanOne(mt, mtc, mh, ml, "L"), mt, mtc, ml, "L", monthlyLowColor, monthlyLowStyleEnum, monthlyLowWidth, mName + " Monthly Low", monthlyLowColor, monthlyMacroLines, monthlyMacroLabels)
                if showMonthlyOC
                    drawMacroLevel(scanOne(mt, mtc, mh, ml, "O"), mt, mtc, mo, "O", monthlyOCColor, monthlyOCStyleEnum, monthlyOCWidth, mName + " Monthly Open", monthlyOCColor, monthlyMacroLines, monthlyMacroLabels)
                    drawMacroLevel(scanOne(mt, mtc, mh, ml, "C"), mt, mtc, mc, "C", monthlyOCColor, monthlyOCStyleEnum, monthlyOCWidth, mName + " Monthly Close", monthlyOCColor, monthlyMacroLines, monthlyMacroLabels)
        if showMonthlyGradient and not na(monthlyRangeHigh) and monthlyRangeHigh > monthlyRangeLow
            drawCompositeGradient(math.round(f_monthTime(monthlyMacroCount)), monthlyRangeHigh, monthlyRangeLow, "Monthly", monthlyMacroLines, monthlyMacroLabels)

    deleteLinesAndLabels(weeklyMacroLines, weeklyMacroLabels)
    if showWeeklyMacros
        for i = 1 to weeklyMacroCount
            float wh = f_weekHigh(i)
            float wl = f_weekLow(i)
            float wo = f_weekOpen(i)
            float wc = f_weekClose(i)
            int   wt = math.round(f_weekTime(i))
            int   wtc = math.round(f_weekTimeClose(i))
            if not na(wh) and not na(wl) and wt > 0 and (na(wtc) or wtc <= timenow)
                string wName = periodNameFromTimes(wt, wtc, "week")
                drawMacroLevel(scanOne(wt, wtc, wh, wl, "H"), wt, wtc, wh, "H", weeklyHighColor, weeklyHighStyleEnum, weeklyHighWidth, wName + " High", weeklyHighColor, weeklyMacroLines, weeklyMacroLabels)
                drawMacroLevel(scanOne(wt, wtc, wh, wl, "L"), wt, wtc, wl, "L", weeklyLowColor, weeklyLowStyleEnum, weeklyLowWidth, wName + " Low", weeklyLowColor, weeklyMacroLines, weeklyMacroLabels)
                if showWeeklyOC
                    drawMacroLevel(scanOne(wt, wtc, wh, wl, "O"), wt, wtc, wo, "O", weeklyOCColor, weeklyOCStyleEnum, weeklyOCWidth, wName + " Open", weeklyOCColor, weeklyMacroLines, weeklyMacroLabels)
                    drawMacroLevel(scanOne(wt, wtc, wh, wl, "C"), wt, wtc, wc, "C", weeklyOCColor, weeklyOCStyleEnum, weeklyOCWidth, wName + " Close", weeklyOCColor, weeklyMacroLines, weeklyMacroLabels)
        if showWeeklyGradient and not na(weeklyRangeHigh) and weeklyRangeHigh > weeklyRangeLow
            drawCompositeGradient(math.round(f_weekTime(weeklyMacroCount)), weeklyRangeHigh, weeklyRangeLow, "Weekly", weeklyMacroLines, weeklyMacroLabels)

// ──────────────────────────────────
// TABLE
// ──────────────────────────────────
tableBg = color.new(color.black, 100 - tableBgOpacity)
tSize = getTableTextSize()

var table macroTable = na
bool showMacroTable = showMonthlyMacros or showWeeklyMacros
if showMacroTable
    if na(macroTable)
        macroTable := table.new(tablePositionFrom(tablePos), 3, 8, bgcolor=tableBg, frame_color=color.gray, frame_width=1, border_color=color.new(color.gray, 50), border_width=1)
    table.clear(macroTable, 0, 0, 2, 7)
    int r = 0
    if showMonthlyMacros
        string mSpan = periodNameFromTimes(math.round(f_monthTime(monthlyMacroCount)), math.round(f_monthTimeClose(monthlyMacroCount)), "month") + " – " + periodNameFromTimes(math.round(f_monthTime(1)), math.round(f_monthTimeClose(1)), "month")
        table.cell(macroTable, 0, r, "MONTHLY MACRO", text_color=color.white, bgcolor=color.new(monthlyHighColor, 40), text_size=tSize)
        table.merge_cells(macroTable, 0, r, 2, r)
        r += 1
        table.cell(macroTable, 0, r, mSpan, text_color=color.gray, text_size=tSize)
        table.cell(macroTable, 1, r, locMonthly ? "Discount" : "Premium", text_color=midMonthly ? color.green : color.red, text_size=tSize)
        table.cell(macroTable, 2, r, str.tostring(percentMonthly) + "%", text_color=midMonthly ? color.green : color.red, text_size=tSize)
        r += 1
        table.cell(macroTable, 0, r, "H " + str.tostring(monthlyRangeHigh, priceFmt), text_color=monthlyHighColor, text_size=tSize)
        table.cell(macroTable, 1, r, "EQ " + str.tostring(monthlyEq, priceFmt), text_color=color.gray, text_size=tSize)
        table.cell(macroTable, 2, r, "L " + str.tostring(monthlyRangeLow, priceFmt), text_color=monthlyLowColor, text_size=tSize)
        r += 1
        table.cell(macroTable, 0, r, "75% " + str.tostring(monthlyQ75, priceFmt), text_color=color.gray, text_size=tSize)
        table.cell(macroTable, 1, r, midMonthly ? "25-75 Zone" : (locMonthly ? "Below 25%" : "Above 75%"), text_color=midMonthly ? color.green : color.orange, text_size=tSize)
        table.cell(macroTable, 2, r, "25% " + str.tostring(monthlyQ25, priceFmt), text_color=color.gray, text_size=tSize)
        r += 1
    if showWeeklyMacros
        string wSpan = periodNameFromTimes(math.round(f_weekTime(weeklyMacroCount)), math.round(f_weekTimeClose(weeklyMacroCount)), "week") + " → last"
        table.cell(macroTable, 0, r, "WEEKLY MACRO", text_color=color.white, bgcolor=color.new(weeklyHighColor, 40), text_size=tSize)
        table.merge_cells(macroTable, 0, r, 2, r)
        r += 1
        table.cell(macroTable, 0, r, wSpan, text_color=color.gray, text_size=tSize)
        table.cell(macroTable, 1, r, locWeekly ? "Discount" : "Premium", text_color=midWeekly ? color.green : color.red, text_size=tSize)
        table.cell(macroTable, 2, r, str.tostring(percentWeekly) + "%", text_color=midWeekly ? color.green : color.red, text_size=tSize)
        r += 1
        table.cell(macroTable, 0, r, "H " + str.tostring(weeklyRangeHigh, priceFmt), text_color=weeklyHighColor, text_size=tSize)
        table.cell(macroTable, 1, r, "EQ " + str.tostring(weeklyEq, priceFmt), text_color=color.gray, text_size=tSize)
        table.cell(macroTable, 2, r, "L " + str.tostring(weeklyRangeLow, priceFmt), text_color=weeklyLowColor, text_size=tSize)
        r += 1
        table.cell(macroTable, 0, r, "75% " + str.tostring(weeklyQ75, priceFmt), text_color=color.gray, text_size=tSize)
        table.cell(macroTable, 1, r, midWeekly ? "25-75 Zone" : (locWeekly ? "Below 25%" : "Above 75%"), text_color=midWeekly ? color.green : color.orange, text_size=tSize)
        table.cell(macroTable, 2, r, "25% " + str.tostring(weeklyQ25, priceFmt), text_color=color.gray, text_size=tSize)
else if not na(macroTable)
    table.clear(macroTable, 0, 0, 2, 7)
````
