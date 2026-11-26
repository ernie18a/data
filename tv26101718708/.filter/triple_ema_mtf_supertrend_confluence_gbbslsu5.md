# Triple EMA MTF Supertrend Confluence

- url: https://www.tradingview.com/script/GBBSlsu5-Triple-EMA-MTF-Supertrend-Confluence/
- type: indicator
- pine_id: PUB;3f431b50a3c64fbb9713f8853e5043fa
- version: 3.0

## Description

Triple EMA & Multi-Timeframe Supertrend Confluence is a technical analysis indicator designed to help traders identify market direction, trend changes, and potential areas of alignment across multiple moving averages.

The indicator features three fully adjustable Exponential Moving Averages (EMAs), with default settings of 20, 50, and 200. Each EMA is displayed using a distinct colour and generates individual bullish and bearish flip labels when price moves across the respective EMA.

The indicator also includes a configurable Multi-Timeframe Supertrend, allowing traders to monitor higher-timeframe trend direction while analysing lower-timeframe price action. The Supertrend is displayed with colour-coded bullish and bearish lines, together with optional shaded areas extending between the Supertrend line and the candles.

A confluence dashboard provides a clear overview of each EMA's current direction, overall EMA alignment, and Supertrend status. When all three EMAs align bullishly or bearishly, the indicator displays a confluence label and provides corresponding alert conditions.

Individual EMA flip labels include an optional expiry feature, allowing traders to automatically remove older labels after a selectable number of candles. This helps maintain a cleaner and more organised chart. 

Key Features:
• Three adjustable EMAs with individual colour coding
• Bullish and bearish EMA flip labels
• Configurable Multi-Timeframe Supertrend
• Bullish green and bearish red Supertrend shading
• EMA confluence detection
• Real-time trend status dashboard
• Optional Supertrend flip labels
• Selectable individual EMA label expiry
• Alert conditions for EMA flips, Supertrend flips, and EMA confluence

This indicator is intended as a visual decision-support tool. It does not guarantee trading results and should be used alongside appropriate risk management and independent market analysis.

## Source Code

````pine
//@version=6
indicator("Triple EMA + MTF Supertrend Confluence FIXED", overlay=true, scale=scale.none, behind_chart=false, max_labels_count=500)

//────────────────────────────────────
// EMA SETTINGS
//────────────────────────────────────

groupEMA = "EMA Settings"

showEMA1 = input.bool(true, "Show EMA 1", group=groupEMA)
showEMA2 = input.bool(true, "Show EMA 2", group=groupEMA)
showEMA3 = input.bool(true, "Show EMA 3", group=groupEMA)

ema1Length = input.int(20, "EMA 1 Length", minval=1, group=groupEMA)
ema2Length = input.int(50, "EMA 2 Length", minval=1, group=groupEMA)
ema3Length = input.int(200, "EMA 3 Length", minval=1, group=groupEMA)

emaWidth = input.int(2, "EMA Line Width", minval=1, maxval=5, group=groupEMA)


//────────────────────────────────────
// SUPERTREND SETTINGS
//────────────────────────────────────

groupST = "Multi-Timeframe Supertrend"

showSupertrend = input.bool(true, "Show Supertrend", group=groupST)

supertrendTimeframe = input.timeframe("60", "Supertrend Timeframe", group=groupST)

supertrendFactor = input.float(3.0, "Supertrend Factor", minval=0.1, step=0.1, group=groupST)

supertrendATRPeriod = input.int(10, "Supertrend ATR Period", minval=1, group=groupST)

supertrendWidth = input.int(2, "Supertrend Line Width", minval=1, maxval=5, group=groupST)

showSupertrendLabels = input.bool(true, "Show Supertrend Flip Labels", group=groupST)

showSupertrendShading = input.bool(true, "Show Supertrend Shading", group=groupST)

shadingTransparency = input.int(88, "Shading Transparency", minval=0, maxval=100, group=groupST)


//────────────────────────────────────
// DISPLAY SETTINGS
//────────────────────────────────────

groupDisplay = "Display Settings"

showFlipLabels = input.bool(true, "Show EMA Flip Labels", group=groupDisplay)

showConfluenceLabels = input.bool(true, "Show Confluence Labels", group=groupDisplay)

showDashboard = input.bool(true, "Show Dashboard", group=groupDisplay)

enableLabelExpiry = input.bool(true, "Enable EMA Label Expiry", group=groupDisplay)

labelExpiryBars = input.int(50, "EMA Label Expiry Bars", minval=1, group=groupDisplay)


//────────────────────────────────────
// CONFLUENCE SETTINGS
//────────────────────────────────────

groupConfluence = "Confluence Settings"

enableConfluenceExpiry = input.bool(true, "Enable Confluence Label Expiry", group=groupConfluence)

confluenceExpiryBars = input.int(50, "Confluence Expiry Bars", minval=1, group=groupConfluence)

keepLatestBullish = input.bool(true, "Keep Latest Bullish Confluence", group=groupConfluence)

keepLatestBearish = input.bool(true, "Keep Latest Bearish Confluence", group=groupConfluence)


//────────────────────────────────────
// DASHBOARD SETTINGS
//────────────────────────────────────

groupDashboard = "Dashboard Settings"

dashboardPositionInput = input.string("Top Right", "Dashboard Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=groupDashboard)

showDistanceInTicks = input.bool(false, "Show Distance In Ticks", group=groupDashboard)


//────────────────────────────────────
// DASHBOARD POSITION
//────────────────────────────────────

dashboardPosition = dashboardPositionInput == "Top Left" ? position.top_left : dashboardPositionInput == "Top Center" ? position.top_center : dashboardPositionInput == "Top Right" ? position.top_right : dashboardPositionInput == "Middle Left" ? position.middle_left : dashboardPositionInput == "Middle Center" ? position.middle_center : dashboardPositionInput == "Middle Right" ? position.middle_right : dashboardPositionInput == "Bottom Left" ? position.bottom_left : dashboardPositionInput == "Bottom Center" ? position.bottom_center : position.bottom_right


//────────────────────────────────────
// EMA CALCULATIONS
//────────────────────────────────────

ema1 = ta.ema(close, ema1Length)
ema2 = ta.ema(close, ema2Length)
ema3 = ta.ema(close, ema3Length)


//────────────────────────────────────
// EMA STATES
//────────────────────────────────────

ema1Bullish = close > ema1
ema1Bearish = close < ema1

ema2Bullish = close > ema2
ema2Bearish = close < ema2

ema3Bullish = close > ema3
ema3Bearish = close < ema3


//────────────────────────────────────
// EMA PLOTS
// FORCE ONTO MAIN CHART
//────────────────────────────────────

plot(
     showEMA1 ? ema1 : na,
     title="EMA 20",
     color=color.blue,
     linewidth=emaWidth,
     style=plot.style_line,
     force_overlay=true
     )

plot(
     showEMA2 ? ema2 : na,
     title="EMA 50",
     color=color.yellow,
     linewidth=emaWidth,
     style=plot.style_line,
     force_overlay=true
     )

plot(
     showEMA3 ? ema3 : na,
     title="EMA 200",
     color=color.orange,
     linewidth=emaWidth,
     style=plot.style_line,
     force_overlay=true
     )


//────────────────────────────────────
// EMA DISTANCE
//────────────────────────────────────

ema1Distance = close - ema1
ema2Distance = close - ema2
ema3Distance = close - ema3

ema1DistanceTicks = ema1Distance / syminfo.mintick
ema2DistanceTicks = ema2Distance / syminfo.mintick
ema3DistanceTicks = ema3Distance / syminfo.mintick


//────────────────────────────────────
// DISTANCE TEXT
//────────────────────────────────────

ema1DistanceText = showDistanceInTicks ? str.tostring(ema1Distance, format.mintick) + " pts / " + str.tostring(math.round(ema1DistanceTicks)) + " ticks" : str.tostring(ema1Distance, format.mintick) + " pts"

ema2DistanceText = showDistanceInTicks ? str.tostring(ema2Distance, format.mintick) + " pts / " + str.tostring(math.round(ema2DistanceTicks)) + " ticks" : str.tostring(ema2Distance, format.mintick) + " pts"

ema3DistanceText = showDistanceInTicks ? str.tostring(ema3Distance, format.mintick) + " pts / " + str.tostring(math.round(ema3DistanceTicks)) + " ticks" : str.tostring(ema3Distance, format.mintick) + " pts"


//────────────────────────────────────
// DISTANCE COLOURS
//────────────────────────────────────

ema1DistanceColor = ema1Distance > 0 ? color.green : ema1Distance < 0 ? color.red : color.gray

ema2DistanceColor = ema2Distance > 0 ? color.green : ema2Distance < 0 ? color.red : color.gray

ema3DistanceColor = ema3Distance > 0 ? color.green : ema3Distance < 0 ? color.red : color.gray


//────────────────────────────────────
// EMA FLIPS
//────────────────────────────────────

ema1BullishFlip = ema1Bullish and not ema1Bullish[1]
ema1BearishFlip = ema1Bearish and not ema1Bearish[1]

ema2BullishFlip = ema2Bullish and not ema2Bullish[1]
ema2BearishFlip = ema2Bearish and not ema2Bearish[1]

ema3BullishFlip = ema3Bullish and not ema3Bullish[1]
ema3BearishFlip = ema3Bearish and not ema3Bearish[1]


//────────────────────────────────────
// EMA LABEL STORAGE
//────────────────────────────────────

var array<label> emaLabels = array.new<label>()


//────────────────────────────────────
// EMA LABEL FUNCTION
//────────────────────────────────────

f_createEMALabel(_x, _y, _text, _style, _bgColor, _textColor) =>
    label newLabel = label.new(
         x=_x,
         y=_y,
         text=_text,
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=_style,
         color=_bgColor,
         textcolor=_textColor,
         size=size.tiny,
         force_overlay=true
         )

    array.push(emaLabels, newLabel)


//────────────────────────────────────
// EMA LABEL EXPIRY
//────────────────────────────────────

if enableLabelExpiry and array.size(emaLabels) > 0

    for i = array.size(emaLabels) - 1 to 0

        label currentLabel = array.get(emaLabels, i)

        int labelAge = bar_index - label.get_x(currentLabel)

        if labelAge >= labelExpiryBars

            label.delete(currentLabel)

            array.remove(emaLabels, i)


//────────────────────────────────────
// EMA 20 LABELS
//────────────────────────────────────

if showFlipLabels and ema1BullishFlip and barstate.isconfirmed
    f_createEMALabel(bar_index, low, "EMA " + str.tostring(ema1Length) + "\nBULL", label.style_label_up, color.blue, color.white)

if showFlipLabels and ema1BearishFlip and barstate.isconfirmed
    f_createEMALabel(bar_index, high, "EMA " + str.tostring(ema1Length) + "\nBEAR", label.style_label_down, color.blue, color.white)


//────────────────────────────────────
// EMA 50 LABELS
//────────────────────────────────────

if showFlipLabels and ema2BullishFlip and barstate.isconfirmed
    f_createEMALabel(bar_index, low, "EMA " + str.tostring(ema2Length) + "\nBULL", label.style_label_up, color.yellow, color.black)

if showFlipLabels and ema2BearishFlip and barstate.isconfirmed
    f_createEMALabel(bar_index, high, "EMA " + str.tostring(ema2Length) + "\nBEAR", label.style_label_down, color.yellow, color.black)


//────────────────────────────────────
// EMA 200 LABELS
//────────────────────────────────────

if showFlipLabels and ema3BullishFlip and barstate.isconfirmed
    f_createEMALabel(bar_index, low, "EMA " + str.tostring(ema3Length) + "\nBULL", label.style_label_up, color.orange, color.black)

if showFlipLabels and ema3BearishFlip and barstate.isconfirmed
    f_createEMALabel(bar_index, high, "EMA " + str.tostring(ema3Length) + "\nBEAR", label.style_label_down, color.orange, color.black)


//────────────────────────────────────
// SUPERTREND FUNCTION
//────────────────────────────────────

f_getSupertrend() =>
    ta.supertrend(supertrendFactor, supertrendATRPeriod)


//────────────────────────────────────
// MTF SUPERTREND
//────────────────────────────────────

[supertrendValue, supertrendDirection] = request.security(
     syminfo.tickerid,
     supertrendTimeframe,
     f_getSupertrend(),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off
     )


//────────────────────────────────────
// SUPERTREND STATE
//────────────────────────────────────

supertrendBullish = supertrendDirection < 0

supertrendBearish = supertrendDirection > 0

supertrendBullishFlip = supertrendBullish and not supertrendBullish[1]

supertrendBearishFlip = supertrendBearish and not supertrendBearish[1]

supertrendColor = supertrendBullish ? color.green : color.red


//────────────────────────────────────
// SUPERTREND PLOT
// FORCE ONTO MAIN CHART
//────────────────────────────────────

supertrendPlot = plot(
     showSupertrend ? supertrendValue : na,
     title="MTF Supertrend",
     color=supertrendColor,
     linewidth=supertrendWidth,
     style=plot.style_linebr,
     force_overlay=true
     )


//────────────────────────────────────
// SUPERTREND SHADING
//────────────────────────────────────

bullishBase = plot(
     showSupertrend and showSupertrendShading and supertrendBullish ? low : na,
     title="Bullish Shading Base",
     display=display.none,
     force_overlay=true
     )

bearishBase = plot(
     showSupertrend and showSupertrendShading and supertrendBearish ? high : na,
     title="Bearish Shading Base",
     display=display.none,
     force_overlay=true
     )

fill(
     supertrendPlot,
     bullishBase,
     color=color.new(color.green, shadingTransparency),
     title="Bullish Supertrend Shading"
     )

fill(
     supertrendPlot,
     bearishBase,
     color=color.new(color.red, shadingTransparency),
     title="Bearish Supertrend Shading"
     )


//────────────────────────────────────
// SUPERTREND LABELS
//────────────────────────────────────

if showSupertrendLabels and supertrendBullishFlip and barstate.isconfirmed

    label.new(
         x=bar_index,
         y=low,
         text="ST " + supertrendTimeframe + "\nBULL",
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white,
         size=size.tiny,
         force_overlay=true
         )

if showSupertrendLabels and supertrendBearishFlip and barstate.isconfirmed

    label.new(
         x=bar_index,
         y=high,
         text="ST " + supertrendTimeframe + "\nBEAR",
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white,
         size=size.tiny,
         force_overlay=true
         )


//────────────────────────────────────
// EMA CONFLUENCE
//────────────────────────────────────

allBullish = ema1Bullish and ema2Bullish and ema3Bullish

allBearish = ema1Bearish and ema2Bearish and ema3Bearish

confluenceState = allBullish ? 1 : allBearish ? -1 : 0

previousConfluenceState = confluenceState[1]

bullishConfluence = confluenceState == 1 and previousConfluenceState != 1

bearishConfluence = confluenceState == -1 and previousConfluenceState != -1

neutralConfluence = confluenceState == 0 and previousConfluenceState != 0


//────────────────────────────────────
// CONFLUENCE STORAGE
//────────────────────────────────────

var array<label> confluenceLabels = array.new<label>()

var array<int> confluenceLabelBars = array.new<int>()

var array<bool> confluenceLabelBullish = array.new<bool>()


//────────────────────────────────────
// BULLISH CONFLUENCE
//────────────────────────────────────

if showConfluenceLabels and bullishConfluence and barstate.isconfirmed

    if keepLatestBullish and array.size(confluenceLabels) > 0

        for i = array.size(confluenceLabels) - 1 to 0

            bool existingBullish = array.get(confluenceLabelBullish, i)

            if existingBullish

                label.delete(array.get(confluenceLabels, i))

                array.remove(confluenceLabels, i)

                array.remove(confluenceLabelBars, i)

                array.remove(confluenceLabelBullish, i)

    label bullishLabel = label.new(
         x=bar_index,
         y=low,
         text="BULLISH\nCONFLUENCE",
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white,
         size=size.small,
         force_overlay=true
         )

    array.push(confluenceLabels, bullishLabel)

    array.push(confluenceLabelBars, bar_index)

    array.push(confluenceLabelBullish, true)


//────────────────────────────────────
// BEARISH CONFLUENCE
//────────────────────────────────────

if showConfluenceLabels and bearishConfluence and barstate.isconfirmed

    if keepLatestBearish and array.size(confluenceLabels) > 0

        for i = array.size(confluenceLabels) - 1 to 0

            bool existingBullish = array.get(confluenceLabelBullish, i)

            if not existingBullish

                label.delete(array.get(confluenceLabels, i))

                array.remove(confluenceLabels, i)

                array.remove(confluenceLabelBars, i)

                array.remove(confluenceLabelBullish, i)

    label bearishLabel = label.new(
         x=bar_index,
         y=high,
         text="BEARISH\nCONFLUENCE",
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white,
         size=size.small,
         force_overlay=true
         )

    array.push(confluenceLabels, bearishLabel)

    array.push(confluenceLabelBars, bar_index)

    array.push(confluenceLabelBullish, false)


//────────────────────────────────────
// CONFLUENCE EXPIRY
//────────────────────────────────────

if enableConfluenceExpiry and array.size(confluenceLabels) > 0

    for i = array.size(confluenceLabels) - 1 to 0

        int createdBar = array.get(confluenceLabelBars, i)

        if bar_index - createdBar >= confluenceExpiryBars

            label.delete(array.get(confluenceLabels, i))

            array.remove(confluenceLabels, i)

            array.remove(confluenceLabelBars, i)

            array.remove(confluenceLabelBullish, i)


//────────────────────────────────────
// DASHBOARD
//────────────────────────────────────

var table dashboard = table.new(
     dashboardPosition,
     3,
     8,
     border_width=1
     )


//────────────────────────────────────
// DASHBOARD STATUS
//────────────────────────────────────

overallStatus = allBullish ? "BULLISH" : allBearish ? "BEARISH" : "NEUTRAL"

overallStatusColor = allBullish ? color.green : allBearish ? color.red : color.gray

supertrendStatus = supertrendBullish ? "BULLISH" : supertrendBearish ? "BEARISH" : "NEUTRAL"

supertrendStatusColor = supertrendBullish ? color.green : supertrendBearish ? color.red : color.gray


//────────────────────────────────────
// DASHBOARD
//────────────────────────────────────

if barstate.islast and showDashboard

    table.cell(dashboard, 0, 0, "EMA", bgcolor=color.black, text_color=color.white)

    table.cell(dashboard, 1, 0, "PRICE", bgcolor=color.black, text_color=color.white)

    table.cell(dashboard, 2, 0, "DISTANCE", bgcolor=color.black, text_color=color.white)


    table.cell(dashboard, 0, 1, "EMA " + str.tostring(ema1Length), bgcolor=color.blue, text_color=color.white)

    table.cell(dashboard, 1, 1, str.tostring(ema1, format.mintick), bgcolor=ema1Bullish ? color.green : color.red, text_color=color.white)

    table.cell(dashboard, 2, 1, ema1DistanceText, bgcolor=ema1DistanceColor, text_color=color.white)


    table.cell(dashboard, 0, 2, "EMA " + str.tostring(ema2Length), bgcolor=color.yellow, text_color=color.black)

    table.cell(dashboard, 1, 2, str.tostring(ema2, format.mintick), bgcolor=ema2Bullish ? color.green : color.red, text_color=color.white)

    table.cell(dashboard, 2, 2, ema2DistanceText, bgcolor=ema2DistanceColor, text_color=color.white)


    table.cell(dashboard, 0, 3, "EMA " + str.tostring(ema3Length), bgcolor=color.orange, text_color=color.black)

    table.cell(dashboard, 1, 3, str.tostring(ema3, format.mintick), bgcolor=ema3Bullish ? color.green : color.red, text_color=color.white)

    table.cell(dashboard, 2, 3, ema3DistanceText, bgcolor=ema3DistanceColor, text_color=color.white)


    table.cell(dashboard, 0, 4, "EMA OVERALL", bgcolor=color.black, text_color=color.white)

    table.cell(dashboard, 1, 4, overallStatus, bgcolor=overallStatusColor, text_color=color.white)

    table.cell(dashboard, 2, 4, allBullish ? "ALL ABOVE" : allBearish ? "ALL BELOW" : "MIXED", bgcolor=overallStatusColor, text_color=color.white)


    table.cell(dashboard, 0, 5, "ST " + supertrendTimeframe, bgcolor=color.black, text_color=color.white)

    table.cell(dashboard, 1, 5, supertrendStatus, bgcolor=supertrendStatusColor, text_color=color.white)

    table.cell(dashboard, 2, 5, str.tostring(supertrendValue, format.mintick), bgcolor=supertrendStatusColor, text_color=color.white)


    table.cell(dashboard, 0, 6, "CURRENT PRICE", bgcolor=color.black, text_color=color.white)

    table.cell(dashboard, 1, 6, str.tostring(close, format.mintick), bgcolor=color.gray, text_color=color.white)

    table.cell(dashboard, 2, 6, "", bgcolor=color.gray)


    table.cell(dashboard, 0, 7, "TICK SIZE", bgcolor=color.black, text_color=color.white)

    table.cell(dashboard, 1, 7, str.tostring(syminfo.mintick, format.mintick), bgcolor=color.gray, text_color=color.white)

    table.cell(dashboard, 2, 7, "1 TICK", bgcolor=color.gray, text_color=color.white)


//────────────────────────────────────
// HIDE DASHBOARD
//────────────────────────────────────

if barstate.islast and not showDashboard

    table.clear(dashboard, 0, 0, 2, 7)


//────────────────────────────────────
// ALERTS
//────────────────────────────────────

alertcondition(
     ema1BullishFlip and barstate.isconfirmed,
     title="EMA 1 Bullish Flip",
     message="EMA 1 has flipped BULLISH."
     )

alertcondition(
     ema1BearishFlip and barstate.isconfirmed,
     title="EMA 1 Bearish Flip",
     message="EMA 1 has flipped BEARISH."
     )

alertcondition(
     ema2BullishFlip and barstate.isconfirmed,
     title="EMA 2 Bullish Flip",
     message="EMA 2 has flipped BULLISH."
     )

alertcondition(
     ema2BearishFlip and barstate.isconfirmed,
     title="EMA 2 Bearish Flip",
     message="EMA 2 has flipped BEARISH."
     )

alertcondition(
     ema3BullishFlip and barstate.isconfirmed,
     title="EMA 3 Bullish Flip",
     message="EMA 3 has flipped BULLISH."
     )

alertcondition(
     ema3BearishFlip and barstate.isconfirmed,
     title="EMA 3 Bearish Flip",
     message="EMA 3 has flipped BEARISH."
     )

alertcondition(
     supertrendBullishFlip and barstate.isconfirmed,
     title="MTF Supertrend Bullish Flip",
     message="MTF Supertrend has flipped BULLISH."
     )

alertcondition(
     supertrendBearishFlip and barstate.isconfirmed,
     title="MTF Supertrend Bearish Flip",
     message="MTF Supertrend has flipped BEARISH."
     )

alertcondition(
     bullishConfluence and barstate.isconfirmed,
     title="Bullish EMA Confluence",
     message="BULLISH EMA CONFLUENCE."
     )

alertcondition(
     bearishConfluence and barstate.isconfirmed,
     title="Bearish EMA Confluence",
     message="BEARISH EMA CONFLUENCE."
     )


//────────────────────────────────────
// DYNAMIC ALERTS
//────────────────────────────────────

if bullishConfluence and barstate.isconfirmed
    alert("BULLISH EMA CONFLUENCE: EMA 20, EMA 50 and EMA 200 are all bullish.", alert.freq_once_per_bar_close)

if bearishConfluence and barstate.isconfirmed
    alert("BEARISH EMA CONFLUENCE: EMA 20, EMA 50 and EMA 200 are all bearish.", alert.freq_once_per_bar_close)

if supertrendBullishFlip and barstate.isconfirmed
    alert("MTF SUPERTREND BULLISH FLIP.", alert.freq_once_per_bar_close)

if supertrendBearishFlip and barstate.isconfirmed
    alert("MTF SUPERTREND BEARISH FLIP.", alert.freq_once_per_bar_close)
````
