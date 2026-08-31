<!-- tradingview-pine-id: PUB;6d4ca8471c46435a803f01b17b02293e -->
<!-- tradingviewscripts-format: 1 -->
# Multi-Timeframe Adaptive EMA + 1M Channel

Source: https://www.tradingview.com/script/QidLDdy1-Multi-Timeframe-Adaptive-EMA-1M-Channel/

## Description

1-minute high/low EMA channel
5-minute adaptive EMA
15-minute adaptive EMA
30-minute adaptive EMA
Individual timeframe toggles
Master adaptive toggle
“Show both high and low” toggle
Separate colours for every timeframe
State table
Alerts

---

## Source Code

````pine
//@version=6
indicator(
     "Multi-Timeframe Adaptive EMA + 1M Channel",
     shorttitle = "Adaptive EMA Suite",
     overlay = true
)

//────────────────────────────────────────────
// Adaptive EMA settings
//────────────────────────────────────────────
adaptiveLength = input.int(
     50,
     "Adaptive EMA Length",
     minval = 1,
     group = "Adaptive EMA Settings"
)

adaptiveLineWidth = input.int(
     2,
     "Adaptive Line Width",
     minval = 1,
     maxval = 5,
     group = "Adaptive EMA Settings"
)

//────────────────────────────────────────────
// Adaptive display mode
//────────────────────────────────────────────
showAllAdaptive = input.bool(
     true,
     "Show Adaptive EMA Lines",
     group = "Adaptive Visibility"
)

showBothAdaptiveLines = input.bool(
     false,
     "Show Both High and Low EMA Lines",
     group = "Adaptive Visibility"
)

show5Minute = input.bool(
     true,
     "Show 5-Minute EMA",
     group = "Adaptive Visibility"
)

show15Minute = input.bool(
     true,
     "Show 15-Minute EMA",
     group = "Adaptive Visibility"
)

show30Minute = input.bool(
     true,
     "Show 30-Minute EMA",
     group = "Adaptive Visibility"
)

//────────────────────────────────────────────
// 5-minute colours
//────────────────────────────────────────────
color5High = input.color(
     color.purple,
     "5M EMA High Colour",
     group = "5-Minute EMA"
)

color5Low = input.color(
     color.aqua,
     "5M EMA Low Colour",
     group = "5-Minute EMA"
)

//────────────────────────────────────────────
// 15-minute colours
//────────────────────────────────────────────
color15High = input.color(
     color.orange,
     "15M EMA High Colour",
     group = "15-Minute EMA"
)

color15Low = input.color(
     color.yellow,
     "15M EMA Low Colour",
     group = "15-Minute EMA"
)

//────────────────────────────────────────────
// 30-minute colours
//────────────────────────────────────────────
color30High = input.color(
     color.fuchsia,
     "30M EMA High Colour",
     group = "30-Minute EMA"
)

color30Low = input.color(
     color.blue,
     "30M EMA Low Colour",
     group = "30-Minute EMA"
)

//────────────────────────────────────────────
// 1-minute EMA channel
//────────────────────────────────────────────
show1MinuteChannel = input.bool(
     true,
     "Show 1-Minute EMA Channel",
     group = "1-Minute EMA Channel"
)

channelLength = input.int(
     50,
     "1-Minute EMA Length",
     minval = 1,
     group = "1-Minute EMA Channel"
)

channelLowColor = input.color(
     color.red,
     "1-Minute Low EMA Colour",
     group = "1-Minute EMA Channel"
)

channelHighColor = input.color(
     color.green,
     "1-Minute High EMA Colour",
     group = "1-Minute EMA Channel"
)

channelLineWidth = input.int(
     2,
     "1-Minute Channel Width",
     minval = 1,
     maxval = 5,
     group = "1-Minute EMA Channel"
)

//────────────────────────────────────────────
// Table settings
//────────────────────────────────────────────
showStateTable = input.bool(
     true,
     "Show State Table",
     group = "Display"
)

//────────────────────────────────────────────
// Adaptive EMA calculation
//────────────────────────────────────────────
getAdaptiveData() =>
    selectedClose = close
    selectedEmaHigh = ta.ema(high, adaptiveLength)
    selectedEmaLow = ta.ema(low, adaptiveLength)
    [selectedClose, selectedEmaHigh, selectedEmaLow]

//────────────────────────────────────────────
// Request timeframe data
//────────────────────────────────────────────
[close5, emaHigh5, emaLow5] = request.security(
     syminfo.tickerid,
     "5",
     getAdaptiveData(),
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

[close15, emaHigh15, emaLow15] = request.security(
     syminfo.tickerid,
     "15",
     getAdaptiveData(),
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

[close30, emaHigh30, emaLow30] = request.security(
     syminfo.tickerid,
     "30",
     getAdaptiveData(),
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

//────────────────────────────────────────────
// 5-minute adaptive state
//────────────────────────────────────────────
var int state5 = 0

if close5 > emaHigh5
    state5 := 1
else if close5 < emaLow5
    state5 := -1

bullish5 = state5 == 1
bearish5 = state5 == -1

//────────────────────────────────────────────
// 15-minute adaptive state
//────────────────────────────────────────────
var int state15 = 0

if close15 > emaHigh15
    state15 := 1
else if close15 < emaLow15
    state15 := -1

bullish15 = state15 == 1
bearish15 = state15 == -1

//────────────────────────────────────────────
// 30-minute adaptive state
//────────────────────────────────────────────
var int state30 = 0

if close30 > emaHigh30
    state30 := 1
else if close30 < emaLow30
    state30 := -1

bullish30 = state30 == 1
bearish30 = state30 == -1

//────────────────────────────────────────────
// Display conditions
//
// Show Both OFF:
// Bullish = low EMA only.
// Bearish = high EMA only.
//
// Show Both ON:
// High and low EMAs are both visible.
//────────────────────────────────────────────
show5Low =
     showAllAdaptive and
     show5Minute and
     (showBothAdaptiveLines or bullish5)

show5High =
     showAllAdaptive and
     show5Minute and
     (showBothAdaptiveLines or bearish5)

show15Low =
     showAllAdaptive and
     show15Minute and
     (showBothAdaptiveLines or bullish15)

show15High =
     showAllAdaptive and
     show15Minute and
     (showBothAdaptiveLines or bearish15)

show30Low =
     showAllAdaptive and
     show30Minute and
     (showBothAdaptiveLines or bullish30)

show30High =
     showAllAdaptive and
     show30Minute and
     (showBothAdaptiveLines or bearish30)

//────────────────────────────────────────────
// 5-minute plots
//────────────────────────────────────────────
plot(
     show5Low ? emaLow5 : na,
     title = "5M EMA Low",
     color = color5Low,
     linewidth = adaptiveLineWidth,
     style = plot.style_linebr
)

plot(
     show5High ? emaHigh5 : na,
     title = "5M EMA High",
     color = color5High,
     linewidth = adaptiveLineWidth,
     style = plot.style_linebr
)

//────────────────────────────────────────────
// 15-minute plots
//────────────────────────────────────────────
plot(
     show15Low ? emaLow15 : na,
     title = "15M EMA Low",
     color = color15Low,
     linewidth = adaptiveLineWidth,
     style = plot.style_linebr
)

plot(
     show15High ? emaHigh15 : na,
     title = "15M EMA High",
     color = color15High,
     linewidth = adaptiveLineWidth,
     style = plot.style_linebr
)

//────────────────────────────────────────────
// 30-minute plots
//────────────────────────────────────────────
plot(
     show30Low ? emaLow30 : na,
     title = "30M EMA Low",
     color = color30Low,
     linewidth = adaptiveLineWidth,
     style = plot.style_linebr
)

plot(
     show30High ? emaHigh30 : na,
     title = "30M EMA High",
     color = color30High,
     linewidth = adaptiveLineWidth,
     style = plot.style_linebr
)

//────────────────────────────────────────────
// 1-minute EMA channel calculation
//────────────────────────────────────────────
getOneMinuteChannel() =>
    oneMinuteLowEma = ta.ema(low, channelLength)
    oneMinuteHighEma = ta.ema(high, channelLength)
    [oneMinuteLowEma, oneMinuteHighEma]

[emaLow1, emaHigh1] = request.security(
     syminfo.tickerid,
     "1",
     getOneMinuteChannel(),
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

//────────────────────────────────────────────
// 1-minute channel plots
//────────────────────────────────────────────
plot(
     show1MinuteChannel ? emaLow1 : na,
     title = "1M EMA Low",
     color = channelLowColor,
     linewidth = channelLineWidth
)

plot(
     show1MinuteChannel ? emaHigh1 : na,
     title = "1M EMA High",
     color = channelHighColor,
     linewidth = channelLineWidth
)

//────────────────────────────────────────────
// State table functions
//────────────────────────────────────────────
getStateText(int currentState) =>
    currentState == 1
         ? "EMA LOW ACTIVE"
         : currentState == -1
             ? "EMA HIGH ACTIVE"
             : "WAITING"

getStateColour(int currentState) =>
    currentState == 1
         ? color.green
         : currentState == -1
             ? color.red
             : color.gray

//────────────────────────────────────────────
// State table
//────────────────────────────────────────────
var table stateTable = table.new(
     position.top_right,
     2,
     3,
     border_width = 1
)

if barstate.islast
    if showStateTable
        table.cell(
             stateTable,
             0,
             0,
             "5 MIN",
             text_color = color.white,
             bgcolor = color.black
        )

        table.cell(
             stateTable,
             1,
             0,
             getStateText(state5),
             text_color = color.white,
             bgcolor = getStateColour(state5)
        )

        table.cell(
             stateTable,
             0,
             1,
             "15 MIN",
             text_color = color.white,
             bgcolor = color.black
        )

        table.cell(
             stateTable,
             1,
             1,
             getStateText(state15),
             text_color = color.white,
             bgcolor = getStateColour(state15)
        )

        table.cell(
             stateTable,
             0,
             2,
             "30 MIN",
             text_color = color.white,
             bgcolor = color.black
        )

        table.cell(
             stateTable,
             1,
             2,
             getStateText(state30),
             text_color = color.white,
             bgcolor = getStateColour(state30)
        )
    else
        table.clear(
             stateTable,
             0,
             0,
             1,
             2
        )

//────────────────────────────────────────────
// State-change alerts
//────────────────────────────────────────────
bullish5Started =
     state5 == 1 and
     state5[1] != 1

bearish5Started =
     state5 == -1 and
     state5[1] != -1

bullish15Started =
     state15 == 1 and
     state15[1] != 1

bearish15Started =
     state15 == -1 and
     state15[1] != -1

bullish30Started =
     state30 == 1 and
     state30[1] != 1

bearish30Started =
     state30 == -1 and
     state30[1] != -1

alertcondition(
     bullish5Started,
     title = "5M Price Above Both EMAs",
     message = "The 5-minute price closed above both EMAs."
)

alertcondition(
     bearish5Started,
     title = "5M Price Below Both EMAs",
     message = "The 5-minute price closed below both EMAs."
)

alertcondition(
     bullish15Started,
     title = "15M Price Above Both EMAs",
     message = "The 15-minute price closed above both EMAs."
)

alertcondition(
     bearish15Started,
     title = "15M Price Below Both EMAs",
     message = "The 15-minute price closed below both EMAs."
)

alertcondition(
     bullish30Started,
     title = "30M Price Above Both EMAs",
     message = "The 30-minute price closed above both EMAs."
)

alertcondition(
     bearish30Started,
     title = "30M Price Below Both EMAs",
     message = "The 30-minute price closed below both EMAs."
)
````
