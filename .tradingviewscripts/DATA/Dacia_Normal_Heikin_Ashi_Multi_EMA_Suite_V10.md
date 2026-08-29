<!-- tradingview-pine-id: PUB;b3b5739b890941cc9a560a27661019a7 -->
<!-- tradingviewscripts-format: 1 -->
# Dacia Normal Heikin Ashi + Multi EMA Suite V1.0

Source: https://www.tradingview.com/script/bOQ5tZql-Dacia-Normal-Heikin-Ashi-Multi-EMA-Suite-V1-0/

## Description

Dacia Normal Heikin Ashi + Multi EMA Suite V1.0
Dacia Normal Heikin Ashi + Multi EMA Suite V1.0

---

## Source Code

````pine
//@version=6
indicator("Dacia Normal Heikin Ashi + Multi EMA Suite V1.0", shorttitle="Dacia HA + EMA V1", overlay=true, max_labels_count=100)

// 1. Normal Heikin Ashi
string haGroup = "1. Normal Heikin Ashi"
bool showHACandles = input.bool(true, "Show Normal HA Candles", group=haGroup)

bool useTransparentCandles = input.bool(
     true,
     "Use Transparent HA Candles",
     tooltip="Turn this off for fully solid normal Heikin Ashi candles.",
     group=haGroup)

int bodyTransparency = input.int(
     30,
     "Body Transparency",
     minval=0,
     maxval=100,
     tooltip="Higher values make the normal HA candles more transparent so EMA crossings remain visible.",
     group=haGroup)

int wickTransparency = input.int(
     5,
     "Wick Transparency",
     minval=0,
     maxval=100,
     group=haGroup)

int borderTransparency = input.int(
     0,
     "Border Transparency",
     minval=0,
     maxval=100,
     group=haGroup)

color bullBodyColor = input.color(color.lime, "Bullish Body", inline="body", group=haGroup)
color bearBodyColor = input.color(color.red, "Bearish Body", inline="body", group=haGroup)
color bullWickColor = input.color(color.lime, "Bullish Wick", inline="wick", group=haGroup)
color bearWickColor = input.color(color.red, "Bearish Wick", inline="wick", group=haGroup)
color bullBorderColor = input.color(color.lime, "Bullish Border", inline="border", group=haGroup)
color bearBorderColor = input.color(color.red, "Bearish Border", inline="border", group=haGroup)

float haClose = (open + high + low + close) / 4.0
var float haOpen = na
haOpen := na(haOpen[1]) ? (open + close) / 2.0 : (haOpen[1] + haClose[1]) / 2.0
float haHigh = math.max(high, math.max(haOpen, haClose))
float haLow = math.min(low, math.min(haOpen, haClose))

bool haBull = haClose >= haOpen
color rawBodyColor = haBull ? bullBodyColor : bearBodyColor
color rawWickColor = haBull ? bullWickColor : bearWickColor
color rawBorderColor = haBull ? bullBorderColor : bearBorderColor

int activeBodyTransparency = useTransparentCandles ? bodyTransparency : 0
int activeWickTransparency = useTransparentCandles ? wickTransparency : 0
int activeBorderTransparency = useTransparentCandles ? borderTransparency : 0

color bodyColor = color.new(rawBodyColor, activeBodyTransparency)
color wickColor = color.new(rawWickColor, activeWickTransparency)
color borderColor = color.new(rawBorderColor, activeBorderTransparency)

plotcandle(
     showHACandles ? haOpen : na,
     showHACandles ? haHigh : na,
     showHACandles ? haLow : na,
     showHACandles ? haClose : na,
     title="Normal Heikin Ashi",
     color=bodyColor,
     wickcolor=wickColor,
     bordercolor=borderColor)

// 2. EMA source
string emaGroup = "2. EMA Lines"
string emaSourceInput = input.string("Normal HA Close", "EMA Source", options=["Normal HA Close", "Regular Close"], group=emaGroup)
float emaSource = emaSourceInput == "Normal HA Close" ? haClose : close
int defaultLineWidth = input.int(2, "EMA Width", minval=1, maxval=5, group=emaGroup)

// 3. Preset EMAs
string presetGroup = "3. Preset EMAs"
bool showEMA5 = input.bool(true, "EMA 5", inline="e5", group=presetGroup)
color colorEMA5 = input.color(#00e676, "", inline="e5", group=presetGroup)
bool showEMA8 = input.bool(false, "EMA 8", inline="e8", group=presetGroup)
color colorEMA8 = input.color(#69f0ae, "", inline="e8", group=presetGroup)
bool showEMA9 = input.bool(false, "EMA 9", inline="e9", group=presetGroup)
color colorEMA9 = input.color(#00bfa5, "", inline="e9", group=presetGroup)
bool showEMA10 = input.bool(false, "EMA 10", inline="e10", group=presetGroup)
color colorEMA10 = input.color(#1de9b6, "", inline="e10", group=presetGroup)
bool showEMA13 = input.bool(true, "EMA 13", inline="e13", group=presetGroup)
color colorEMA13 = input.color(#00b0ff, "", inline="e13", group=presetGroup)
bool showEMA20 = input.bool(false, "EMA 20", inline="e20", group=presetGroup)
color colorEMA20 = input.color(#40c4ff, "", inline="e20", group=presetGroup)
bool showEMA21 = input.bool(false, "EMA 21", inline="e21", group=presetGroup)
color colorEMA21 = input.color(#2979ff, "", inline="e21", group=presetGroup)
bool showEMA34 = input.bool(false, "EMA 34", inline="e34", group=presetGroup)
color colorEMA34 = input.color(#536dfe, "", inline="e34", group=presetGroup)
bool showEMA50 = input.bool(true, "EMA 50", inline="e50", group=presetGroup)
color colorEMA50 = input.color(#ffd740, "", inline="e50", group=presetGroup)
bool showEMA100 = input.bool(false, "EMA 100", inline="e100", group=presetGroup)
color colorEMA100 = input.color(#ff9100, "", inline="e100", group=presetGroup)
bool showEMA200 = input.bool(true, "EMA 200", inline="e200", group=presetGroup)
color colorEMA200 = input.color(#e040fb, "", inline="e200", group=presetGroup)

// 4. Custom EMA slots
string customGroup = "4. Custom EMA Slots"
bool showCustom1 = input.bool(false, "Custom 1", inline="c1", group=customGroup)
int customLength1 = input.int(12, "", minval=1, maxval=500, inline="c1", group=customGroup)
color customColor1 = input.color(color.white, "", inline="c1", group=customGroup)
bool showCustom2 = input.bool(false, "Custom 2", inline="c2", group=customGroup)
int customLength2 = input.int(26, "", minval=1, maxval=500, inline="c2", group=customGroup)
color customColor2 = input.color(#ff5252, "", inline="c2", group=customGroup)
bool showCustom3 = input.bool(false, "Custom 3", inline="c3", group=customGroup)
int customLength3 = input.int(34, "", minval=1, maxval=500, inline="c3", group=customGroup)
color customColor3 = input.color(#7c4dff, "", inline="c3", group=customGroup)

float ema5 = ta.ema(emaSource, 5)
float ema8 = ta.ema(emaSource, 8)
float ema9 = ta.ema(emaSource, 9)
float ema10 = ta.ema(emaSource, 10)
float ema13 = ta.ema(emaSource, 13)
float ema20 = ta.ema(emaSource, 20)
float ema21 = ta.ema(emaSource, 21)
float ema34 = ta.ema(emaSource, 34)
float ema50 = ta.ema(emaSource, 50)
float ema100 = ta.ema(emaSource, 100)
float ema200 = ta.ema(emaSource, 200)
float customEMA1 = ta.ema(emaSource, customLength1)
float customEMA2 = ta.ema(emaSource, customLength2)
float customEMA3 = ta.ema(emaSource, customLength3)

plot(showEMA5 ? ema5 : na, "EMA 5", color=colorEMA5, linewidth=defaultLineWidth)
plot(showEMA8 ? ema8 : na, "EMA 8", color=colorEMA8, linewidth=defaultLineWidth)
plot(showEMA9 ? ema9 : na, "EMA 9", color=colorEMA9, linewidth=defaultLineWidth)
plot(showEMA10 ? ema10 : na, "EMA 10", color=colorEMA10, linewidth=defaultLineWidth)
plot(showEMA13 ? ema13 : na, "EMA 13", color=colorEMA13, linewidth=defaultLineWidth)
plot(showEMA20 ? ema20 : na, "EMA 20", color=colorEMA20, linewidth=defaultLineWidth)
plot(showEMA21 ? ema21 : na, "EMA 21", color=colorEMA21, linewidth=defaultLineWidth)
plot(showEMA34 ? ema34 : na, "EMA 34", color=colorEMA34, linewidth=defaultLineWidth)
plot(showEMA50 ? ema50 : na, "EMA 50", color=colorEMA50, linewidth=defaultLineWidth)
plot(showEMA100 ? ema100 : na, "EMA 100", color=colorEMA100, linewidth=defaultLineWidth)
plot(showEMA200 ? ema200 : na, "EMA 200", color=colorEMA200, linewidth=defaultLineWidth)
plot(showCustom1 ? customEMA1 : na, "Custom EMA 1", color=customColor1, linewidth=defaultLineWidth)
plot(showCustom2 ? customEMA2 : na, "Custom EMA 2", color=customColor2, linewidth=defaultLineWidth)
plot(showCustom3 ? customEMA3 : na, "Custom EMA 3", color=customColor3, linewidth=defaultLineWidth)

// 5. EMA end labels
string labelGroup = "5. EMA End Labels"
bool showEMALabels = input.bool(true, "Show EMA End Labels", group=labelGroup)
bool showPriceInLabel = input.bool(true, "Show Current Price", group=labelGroup)
string labelSizeInput = input.string("Tiny", "Label Font Size", options=["Tiny", "Small", "Normal"], group=labelGroup)
int labelOffsetBars = input.int(2, "Label Offset Right", minval=1, maxval=20, group=labelGroup)

f_label_size(string value) =>
    switch value
        "Small" => size.small
        "Normal" => size.normal
        => size.tiny

f_label_text(string name, float value) =>
    showPriceInLabel ? name + " | " + str.tostring(value, format.mintick) : name

f_update_label(label lbl, bool enabled, float value, string name, color col) =>
    label result = lbl
    if barstate.islast
        if enabled and showEMALabels and not na(value)
            if na(result)
                result := label.new(bar_index + labelOffsetBars, value, f_label_text(name, value), xloc=xloc.bar_index, style=label.style_label_left, color=col, textcolor=color.white, size=f_label_size(labelSizeInput))
            else
                label.set_x(result, bar_index + labelOffsetBars)
                label.set_y(result, value)
                label.set_text(result, f_label_text(name, value))
                label.set_color(result, col)
                label.set_textcolor(result, color.white)
                label.set_size(result, f_label_size(labelSizeInput))
        else if not na(result)
            label.delete(result)
            result := na
    result

var label labelEMA5 = na
var label labelEMA8 = na
var label labelEMA9 = na
var label labelEMA10 = na
var label labelEMA13 = na
var label labelEMA20 = na
var label labelEMA21 = na
var label labelEMA34 = na
var label labelEMA50 = na
var label labelEMA100 = na
var label labelEMA200 = na
var label labelCustom1 = na
var label labelCustom2 = na
var label labelCustom3 = na

labelEMA5 := f_update_label(labelEMA5, showEMA5, ema5, "EMA 5", colorEMA5)
labelEMA8 := f_update_label(labelEMA8, showEMA8, ema8, "EMA 8", colorEMA8)
labelEMA9 := f_update_label(labelEMA9, showEMA9, ema9, "EMA 9", colorEMA9)
labelEMA10 := f_update_label(labelEMA10, showEMA10, ema10, "EMA 10", colorEMA10)
labelEMA13 := f_update_label(labelEMA13, showEMA13, ema13, "EMA 13", colorEMA13)
labelEMA20 := f_update_label(labelEMA20, showEMA20, ema20, "EMA 20", colorEMA20)
labelEMA21 := f_update_label(labelEMA21, showEMA21, ema21, "EMA 21", colorEMA21)
labelEMA34 := f_update_label(labelEMA34, showEMA34, ema34, "EMA 34", colorEMA34)
labelEMA50 := f_update_label(labelEMA50, showEMA50, ema50, "EMA 50", colorEMA50)
labelEMA100 := f_update_label(labelEMA100, showEMA100, ema100, "EMA 100", colorEMA100)
labelEMA200 := f_update_label(labelEMA200, showEMA200, ema200, "EMA 200", colorEMA200)
labelCustom1 := f_update_label(labelCustom1, showCustom1, customEMA1, "EMA " + str.tostring(customLength1), customColor1)
labelCustom2 := f_update_label(labelCustom2, showCustom2, customEMA2, "EMA " + str.tostring(customLength2), customColor2)
labelCustom3 := f_update_label(labelCustom3, showCustom3, customEMA3, "EMA " + str.tostring(customLength3), customColor3)

// 6. Cross pair and arrows
string crossGroup = "6. Cross Pair + Arrows"
string fastChoice = input.string("5", "Fast EMA", options=["5", "8", "9", "10", "13", "20", "21", "34", "50", "100", "200", "Custom 1", "Custom 2", "Custom 3"], group=crossGroup)
string slowChoice = input.string("13", "Slow EMA", options=["5", "8", "9", "10", "13", "20", "21", "34", "50", "100", "200", "Custom 1", "Custom 2", "Custom 3"], group=crossGroup)
bool showCrossArrows = input.bool(true, "Show EMA Cross Arrows", group=crossGroup)

f_select_ema(string choice) =>
    switch choice
        "5" => ema5
        "8" => ema8
        "9" => ema9
        "10" => ema10
        "13" => ema13
        "20" => ema20
        "21" => ema21
        "34" => ema34
        "50" => ema50
        "100" => ema100
        "200" => ema200
        "Custom 1" => customEMA1
        "Custom 2" => customEMA2
        => customEMA3

float selectedFast = f_select_ema(fastChoice)
float selectedSlow = f_select_ema(slowChoice)
bool bullishCross = ta.crossover(selectedFast, selectedSlow)
bool bearishCross = ta.crossunder(selectedFast, selectedSlow)
plotshape(showCrossArrows and bullishCross, title="Bullish EMA Cross", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.tiny)
plotshape(showCrossArrows and bearishCross, title="Bearish EMA Cross", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.tiny)

// 7. SHA position signals
string signalGroup = "7. HA Position Signals"
bool showPositionMarkers = input.bool(false, "Show HA Position Markers", group=signalGroup)
bool requireBodyAboveBelow = input.bool(true, "Require Entire SHA Body Above / Below Pair", group=signalGroup)
float bodyTop = math.max(haOpen, haClose)
float bodyBottom = math.min(haOpen, haClose)
bool bullishPosition = haBull and selectedFast > selectedSlow and (requireBodyAboveBelow ? bodyBottom > selectedFast and bodyBottom > selectedSlow : haClose > selectedFast and haClose > selectedSlow)
bool bearishPosition = not haBull and selectedFast < selectedSlow and (requireBodyAboveBelow ? bodyTop < selectedFast and bodyTop < selectedSlow : haClose < selectedFast and haClose < selectedSlow)
bool newBullishPosition = bullishPosition and not bullishPosition[1]
bool newBearishPosition = bearishPosition and not bearishPosition[1]
plotshape(showPositionMarkers and newBullishPosition, title="Bullish HA Above EMA Pair", style=shape.labelup, location=location.belowbar, color=color.lime, textcolor=color.black, size=size.tiny, text="HA+")
plotshape(showPositionMarkers and newBearishPosition, title="Bearish HA Below EMA Pair", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.tiny, text="HA-")

// 8. Alerts
string alertGroup = "8. Alerts"
bool enableAlerts = input.bool(true, "Enable Alerts", group=alertGroup)
bool alertCrosses = input.bool(true, "Alert On EMA Cross", group=alertGroup)
bool alertSHAPosition = input.bool(false, "Alert On New HA Above / Below Pair", tooltip="Optional confirmation alert. EMA cross alerts are the cleaner default.", group=alertGroup)
bool confirmAlertsOnClose = input.bool(true, "Confirm Alerts On Candle Close", group=alertGroup)
bool alertReady = not confirmAlertsOnClose or barstate.isconfirmed
bool bullishCrossAlert = enableAlerts and alertCrosses and bullishCross and alertReady
bool bearishCrossAlert = enableAlerts and alertCrosses and bearishCross and alertReady
bool bullishPositionAlert = enableAlerts and alertSHAPosition and newBullishPosition and alertReady
bool bearishPositionAlert = enableAlerts and alertSHAPosition and newBearishPosition and alertReady

alertcondition(bullishCrossAlert, "Bullish Selected EMA Cross", "{{ticker}} {{interval}}: Selected fast EMA crossed above selected slow EMA.")
alertcondition(bearishCrossAlert, "Bearish Selected EMA Cross", "{{ticker}} {{interval}}: Selected fast EMA crossed below selected slow EMA.")
alertcondition(bullishPositionAlert, "Bullish HA Above EMA Pair", "{{ticker}} {{interval}}: Bullish normal Heikin Ashi body moved above the selected EMA pair.")
alertcondition(bearishPositionAlert, "Bearish HA Below EMA Pair", "{{ticker}} {{interval}}: Bearish normal Heikin Ashi body moved below the selected EMA pair.")
alertcondition(bullishCrossAlert or bearishCrossAlert or bullishPositionAlert or bearishPositionAlert, "ALL HA + EMA Events", "{{ticker}} {{interval}}: Smoothed Heikin Ashi and EMA event.")

if bullishCrossAlert or bearishCrossAlert or bullishPositionAlert or bearishPositionAlert
    string message = syminfo.ticker + " | " + timeframe.period + " | "
    if bullishCrossAlert
        message += "Bullish EMA cross; "
    if bearishCrossAlert
        message += "Bearish EMA cross; "
    if bullishPositionAlert
        message += "Bullish HA above EMA pair; "
    if bearishPositionAlert
        message += "Bearish HA below EMA pair; "
    if confirmAlertsOnClose
        alert(message, alert.freq_once_per_bar_close)
    else
        alert(message, alert.freq_once_per_bar)
````
