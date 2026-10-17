# Uptrick: Vector Trail Trend

- url: https://www.tradingview.com/script/5X9BnuD4-Uptrick-Vector-Trail-Trend/
- type: indicator
- pine_id: PUB;3d34bbc8476d42df96c1f27ef71d8eff
- version: 1.0

## Description

[b][i]Introduction[/i][/b]
Uptrick: Vector Trail Trend (VTT) is an overlay tool that combines a velocity-projected trend line with an ATR-based adaptive trailing band to identify directional bias and trend reversals. A secondary momentum module layered on top flags statistically extreme momentum conditions that traders can use as dynamic take-profit references within the prevailing trend. The script also includes a configurable overlay presentation and an on-chart dashboard summarizing current trend state.

[b][i]Originality[/i][/b]
This script combines three distinct calculation layers that are not typically merged in a single publication, and each is included for a specific reason.
The first layer builds a trend center from a smoothed moving average of price, then projects that line forward using a smoothed rate of change of the trend center itself, scaled by a user-defined projection factor. This produces a trend reference that leans in the direction of recent acceleration rather than simply lagging price, which is the basis used for the trailing band below it.

The second layer wraps that projected trend center in an ATR-based band that only trails in the favorable direction and resets on a confirmed close beyond the opposite band, similar in mechanism to a ratcheting stop line. This layer is responsible for the directional flips and the up and down signals plotted on the chart.

The third layer is independent of the first two and evaluates RSI relative to its own rolling mean and standard deviation, expressed as a Z-score. This is used to flag when momentum has reached a statistically extreme reading relative to its recent history, which the script surfaces as separate dynamic take-profit markers. This layer exists because trend direction and momentum exhaustion are different pieces of information, and combining them gives traders both a directional read and a separate overextension read without conflating the two into a single signal.

The overlay is user-selectable between a gradient fill between price and the trail, a dual EMA trend ribbon, both together, or neither, so the visual presentation can be adjusted without changing the underlying trend or TP logic.

[b][i]Features[/i][/b]
[list]
[*]Velocity-projected trend center using a smoothed moving average and a smoothed rate of change projection
[*]ATR-based adaptive trailing band with directional flip logic
[*]Confirmed-bar trend state calculation to avoid intrabar repainting of the trend flip
[*]Dynamic take-profit engine based on a Z-score of RSI relative to its own rolling mean and standard deviation
[*]Selectable TP marker style, cross or circle
[*]Up and down trend signal labels plotted at the trail
[*]Selectable overlay mode: vector gradient fill, trend ribbon, both, or none
[*]Adjustable gradient and ribbon transparency
[*]Optional candle coloring based on active trend direction
[*]Adjustable trail line width
[*]On-chart dashboard showing trend, signal, Z-score, TP state, distance from trail in ATR units, and active overlay mode
[*]Nine selectable dashboard positions
[*]Seven alert conditions: up signal, down signal, long dynamic TP, short dynamic TP, any trend signal, any dynamic TP, and all VTT signals combined
[/list]

[b][i]Inputs[/i][/b]
[list]
[*]Trend Settings: source, trend length, velocity smoothing length, vector projection factor.
[*]Trail Settings: ATR length, ATR multiplier.
[*]Dynamic TP Settings: show/hide dynamic TPs, TP marker style, momentum (RSI) length, Z-score length, TP extreme level threshold.
[*]Overlay: overlay style selection, gradient transparency, ribbon fast length, ribbon slow length, ribbon transparency.
[*]Visuals: show/hide up and down signals, candle coloring toggle, trail width.
[*]Dashboard: show/hide dashboard, dashboard position.
[/list]
[b][i]How It Works / How to Use[/i][/b]
The trend center is calculated from a moving average of the chosen source, then projected forward using a smoothed measure of its own rate of change. An ATR-based band is built around this projected line and only moves in the direction favorable to the current trend, flipping only on a confirmed close beyond the opposite band. This flip is what produces the up and down signals and the trend color change.

Once a trend is established, the script tracks RSI relative to its own recent mean and standard deviation. When this Z-score reaches the user-defined extreme level and then crosses back toward normal, a dynamic take-profit marker is plotted for the active trend, using the opposite color for visual distinction, indicating that momentum has cooled from an extreme reading.

Traders can use the trail flips for directional bias and entries, and the dynamic TP markers as a secondary reference for potential exhaustion points within that trend. The overlay mode, transparency, candle coloring, and dashboard are all cosmetic and can be adjusted without affecting the underlying calculations.

[b][i]Conclusion[/i][/b]
Uptrick: Vector Trail Trend combines a velocity-projected trend line, an adaptive ATR trailing band, and a momentum Z-score take-profit layer into a single overlay tool, giving traders both a directional trend read and a separate momentum-exhaustion reference from one indicator.

[quote]Disclaimer
This script is provided for informational and educational purposes only and does not constitute financial advice. Past performance, whether shown historically or implied through the script's logic, does not guarantee future results. Always perform your own due diligence and risk management before making trading decisions.[/quote]

## Source Code

````pine
// This work is licensed under an Attribution-ShareAlike 4.0 International License (CC BY-SA 4.0)
// https://creativecommons.org/licenses/by-sa/4.0/
// © Uptrick

//@version=6

//    ██╗   ██╗██████╗ ████████╗██████╗ ██╗ ██████╗██╗  ██╗
//    ██║   ██║██╔══██╗╚══██╔══╝██╔══██╗██║██╔════╝██║ ██╔╝
//    ██║   ██║██████╔╝   ██║   ██████╔╝██║██║     █████╔╝
//    ██║   ██║██╔═══╝    ██║   ██╔══██╗██║██║     ██╔═██╗
//    ╚██████╔╝██║        ██║   ██║  ██║██║╚██████╗██║  ██╗
//     ╚═════╝ ╚═╝        ╚═╝   ╚═╝  ╚═╝╚═╝ ╚═════╝╚═╝  ╚═╝

indicator(
     "Uptrick: Vector Trail Trend",
     shorttitle = "VTT",
     overlay = true,
     max_labels_count = 500
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

grpTrend = "01. Trend Settings"

source = input.source(
     hlc3,
     "Source",
     group = grpTrend
)

trendLength = input.int(
     34,
     "Trend Length",
     minval = 1,
     group = grpTrend
)

velocityLength = input.int(
     8,
     "Velocity Smoothing",
     minval = 1,
     group = grpTrend
)

projection = input.float(
     3.0,
     "Vector Projection",
     minval = 0.0,
     step = 0.25,
     group = grpTrend
)

grpTrail = "02. Trail Settings"

atrLength = input.int(
     14,
     "ATR Length",
     minval = 1,
     group = grpTrail
)

atrMultiplier = input.float(
     1.8,
     "ATR Multiplier",
     minval = 0.1,
     step = 0.1,
     group = grpTrail
)

grpTp = "03. Dynamic TP Settings"

showDynamicTp = input.bool(
     true,
     "Show Dynamic TPs",
     group = grpTp
)

tpMarker = input.string(
     "Cross",
     "TP Marker",
     options = [
          "Cross",
          "Circle"
     ],
     group = grpTp
)

momentumLength = input.int(
     14,
     "Momentum Length",
     minval = 1,
     group = grpTp
)

zScoreLength = input.int(
     50,
     "Z-Score Length",
     minval = 5,
     group = grpTp
)

tpExtremeLevel = input.float(
     1.5,
     "TP Extreme Level",
     minval = 0.1,
     step = 0.1,
     group = grpTp
)

grpOverlay = "04. Overlay"

overlayMode = input.string(
     "Vector Gradient",
     "Overlay Style",
     options = [
          "Vector Gradient",
          "Trend Ribbon",
          "Both",
          "None"
     ],
     group = grpOverlay
)

gradientTransparency = input.int(
     50,
     "Gradient Transparency",
     minval = 0,
     maxval = 100,
     group = grpOverlay
)

ribbonFastLength = input.int(
     21,
     "Ribbon Fast Length",
     minval = 1,
     group = grpOverlay
)

ribbonSlowLength = input.int(
     50,
     "Ribbon Slow Length",
     minval = 2,
     group = grpOverlay
)

ribbonTransparency = input.int(
     80,
     "Ribbon Transparency",
     minval = 0,
     maxval = 100,
     group = grpOverlay
)

grpVisuals = "05. Visuals"

showSignals = input.bool(
     true,
     "Show Up / Down Signals",
     group = grpVisuals
)

colorCandles = input.bool(
     true,
     "Color Candles",
     group = grpVisuals
)

trailWidth = input.int(
     3,
     "Trail Width",
     minval = 1,
     maxval = 8,
     group = grpVisuals
)

grpDashboard = "06. Dashboard"

showDashboard = input.bool(
     true,
     "Show Dashboard",
     group = grpDashboard
)

dashboardPosition = input.string(
     "Top Right",
     "Dashboard Position",
     options = [
          "Top Left",
          "Top Center",
          "Top Right",
          "Middle Left",
          "Middle Center",
          "Middle Right",
          "Bottom Left",
          "Bottom Center",
          "Bottom Right"
     ],
     group = grpDashboard
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Colors
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullColor = color.new(#00d7c1, 0)
bearColor = color.new(#9d01d6, 0)
neutralColor = color.new(#FFD84D, 0)

blackText = color.new(#000000, 0)
whiteText = color.new(#FFFFFF, 0)

darkBackground = color.new(#000104, 12)
headerBackground = color.new(#111827, 0)
softBorder = color.new(color.white, 55)

transparentColor = color.new(color.black, 100)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Functions
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_tablePosition(_position) =>
    _position == "Top Left" ? position.top_left :
     _position == "Top Center" ? position.top_center :
     _position == "Middle Left" ? position.middle_left :
     _position == "Middle Center" ? position.middle_center :
     _position == "Middle Right" ? position.middle_right :
     _position == "Bottom Left" ? position.bottom_left :
     _position == "Bottom Center" ? position.bottom_center :
     _position == "Bottom Right" ? position.bottom_right :
     position.top_right

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Vector Trend Engine
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

trendCenter = ta.ema(
     source,
     trendLength
)

trendVelocity = ta.ema(
     ta.change(trendCenter),
     velocityLength
)

trendVector =
     trendCenter +
     trendVelocity * projection

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Adaptive Vector Trails
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

atrValue = ta.atr(atrLength)

safeAtr =
     atrValue != 0.0 ?
     atrValue :
     syminfo.mintick

basicUpper =
     trendVector +
     safeAtr * atrMultiplier

basicLower =
     trendVector -
     safeAtr * atrMultiplier

var float upperTrail = na
var float lowerTrail = na

upperTrail :=
     na(upperTrail[1]) ?
     basicUpper :
     basicUpper < upperTrail[1] or close[1] > upperTrail[1] ?
     basicUpper :
     upperTrail[1]

lowerTrail :=
     na(lowerTrail[1]) ?
     basicLower :
     basicLower > lowerTrail[1] or close[1] < lowerTrail[1] ?
     basicLower :
     lowerTrail[1]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Confirmed Trend State
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var int trend = 1

trend := nz(trend[1], 1)

if barstate.isconfirmed
    if trend[1] == -1 and close > upperTrail[1]
        trend := 1
    else if trend[1] == 1 and close < lowerTrail[1]
        trend := -1

bullish = trend == 1
bearish = trend == -1

upSignal =
     barstate.isconfirmed and
     bullish and
     trend[1] == -1

downSignal =
     barstate.isconfirmed and
     bearish and
     trend[1] == 1

activeColor =
     bullish ?
     bullColor :
     bearColor

activeTrail =
     bullish ?
     lowerTrail :
     upperTrail

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Dynamic TP Engine
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

momentumValue = ta.rsi(
     source,
     momentumLength
)

momentumBasis = ta.sma(
     momentumValue,
     zScoreLength
)

momentumDeviation = ta.stdev(
     momentumValue,
     zScoreLength
)

safeMomentumDeviation =
     momentumDeviation != 0.0 ?
     momentumDeviation :
     1.0

momentumZScore =
     (momentumValue - momentumBasis) /
     safeMomentumDeviation

longTpArmed =
     bullish and
     momentumZScore >= tpExtremeLevel

shortTpArmed =
     bearish and
     momentumZScore <= -tpExtremeLevel

longTpSignal =
     showDynamicTp and
     barstate.isconfirmed and
     bullish and
     ta.crossunder(
          momentumZScore,
          tpExtremeLevel
     )

shortTpSignal =
     showDynamicTp and
     barstate.isconfirmed and
     bearish and
     ta.crossover(
          momentumZScore,
          -tpExtremeLevel
     )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Overlay Modes
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

showVectorGradient =
     overlayMode == "Vector Gradient" or
     overlayMode == "Both"

showTrendRibbon =
     overlayMode == "Trend Ribbon" or
     overlayMode == "Both"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Outer Vector Trails
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullTrailPlot = plot(
     showVectorGradient and bullish ? lowerTrail : na,
     title = "Bullish Vector Trail",
     color = bullColor,
     linewidth = trailWidth,
     style = plot.style_linebr
)

bearTrailPlot = plot(
     showVectorGradient and bearish ? upperTrail : na,
     title = "Bearish Vector Trail",
     color = bearColor,
     linewidth = trailWidth,
     style = plot.style_linebr
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Default Vector Gradient Overlay
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullPricePlot = plot(
     showVectorGradient and bullish ? close : na,
     title = "Bullish Price Anchor",
     color = transparentColor,
     editable = false
)

bearPricePlot = plot(
     showVectorGradient and bearish ? close : na,
     title = "Bearish Price Anchor",
     color = transparentColor,
     editable = false
)

fill(
     bullTrailPlot,
     bullPricePlot,
     close,
     lowerTrail,
     transparentColor,
     color.new(
          bullColor,
          gradientTransparency
     ),
     title = "Bullish Vector Gradient"
)

fill(
     bearTrailPlot,
     bearPricePlot,
     upperTrail,
     close,
     color.new(
          bearColor,
          gradientTransparency
     ),
     transparentColor,
     title = "Bearish Vector Gradient"
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Alternative Trend Ribbon Overlay
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ribbonFast = ta.ema(
     source,
     ribbonFastLength
)

ribbonSlow = ta.ema(
     source,
     ribbonSlowLength
)

ribbonBullish =
     ribbonFast >= ribbonSlow

ribbonColor =
     ribbonBullish ?
     bullColor :
     bearColor

ribbonFastPlot = plot(
     showTrendRibbon ? ribbonFast : na,
     title = "Ribbon Fast",
     color = color.new(ribbonColor, 20),
     linewidth = 1
)

ribbonSlowPlot = plot(
     showTrendRibbon ? ribbonSlow : na,
     title = "Ribbon Slow",
     color = color.new(ribbonColor, 50),
     linewidth = 1
)

fill(
     ribbonFastPlot,
     ribbonSlowPlot,
     color = color.new(
          ribbonColor,
          ribbonTransparency
     ),
     title = "Trend Ribbon"
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Up / Down Labels Anchored to Outer Trail
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

upLabelAnchor =
     showSignals and upSignal ?
     lowerTrail :
     na

downLabelAnchor =
     showSignals and downSignal ?
     upperTrail :
     na

plotshape(
     upLabelAnchor,
     title = "Up Signal",
     location = location.absolute,
     style = shape.labelup,
     text = "𝓤𝓹",
     color = bullColor,
     textcolor = blackText,
     size = size.normal
)

plotshape(
     downLabelAnchor,
     title = "Down Signal",
     location = location.absolute,
     style = shape.labeldown,
     text = "𝓓𝓸𝔀𝓷",
     color = bearColor,
     textcolor = whiteText,
     size = size.normal
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Dynamic TP Markers
//
// Long-trend TPs use the bearish color.
// Short-trend TPs use the bullish color.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plotshape(
     tpMarker == "Cross" and longTpSignal,
     title = "Long Dynamic TP Cross",
     location = location.abovebar,
     style = shape.xcross,
     color = bearColor,
     size = size.tiny
)

plotshape(
     tpMarker == "Cross" and shortTpSignal,
     title = "Short Dynamic TP Cross",
     location = location.belowbar,
     style = shape.xcross,
     color = bullColor,
     size = size.tiny
)

plotshape(
     tpMarker == "Circle" and longTpSignal,
     title = "Long Dynamic TP Circle",
     location = location.abovebar,
     style = shape.circle,
     color = bearColor,
     size = size.tiny
)

plotshape(
     tpMarker == "Circle" and shortTpSignal,
     title = "Short Dynamic TP Circle",
     location = location.belowbar,
     style = shape.circle,
     color = bullColor,
     size = size.tiny
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Candle Coloring
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

candleColor =
     colorCandles ?
     activeColor :
     na

plotcandle(
     open,
     high,
     low,
     close,
     title = "Vector Trend Candles",
     color = candleColor,
     wickcolor = candleColor,
     bordercolor = candleColor
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Dashboard Values
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

trendText =
     bullish ?
     "Bullish" :
     "Bearish"

signalText =
     bullish ?
     "Up" :
     "Down"

zScoreText =
     na(momentumZScore) ?
     "N/A" :
     str.tostring(
          momentumZScore,
          "#.00"
     )

tpStateText =
     longTpArmed ?
     "Long TP Armed" :
     shortTpArmed ?
     "Short TP Armed" :
     "Neutral"

tpStateColor =
     longTpArmed ?
     bearColor :
     shortTpArmed ?
     bullColor :
     neutralColor

trailDistance =
     math.abs(close - activeTrail) /
     safeAtr

trailDistanceText =
     na(trailDistance) ?
     "N/A" :
     str.tostring(
          trailDistance,
          "#.00"
     ) + " ATR"

overlayText =
     overlayMode == "Vector Gradient" ?
     "Vector Gradient" :
     overlayMode == "Trend Ribbon" ?
     "Trend Ribbon" :
     overlayMode

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Dashboard
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var table dashboard = table.new(
     f_tablePosition(dashboardPosition),
     2,
     7,
     frame_color = color.new(color.white, 35),
     frame_width = 1,
     border_color = softBorder,
     border_width = 1
)

if barstate.isfirst
    table.merge_cells(
         dashboard,
         0,
         0,
         1,
         0
    )

if showDashboard and barstate.islast
    table.cell(
         dashboard,
         0,
         0,
         "VTT",
         text_color = whiteText,
         bgcolor = headerBackground,
         text_halign = text.align_center
    )

    table.cell(
         dashboard,
         0,
         1,
         "Trend",
         text_color = whiteText,
         bgcolor = darkBackground
    )

    table.cell(
         dashboard,
         1,
         1,
         trendText,
         text_color = bullish ? blackText : whiteText,
         bgcolor = activeColor
    )

    table.cell(
         dashboard,
         0,
         2,
         "Signal",
         text_color = whiteText,
         bgcolor = darkBackground
    )

    table.cell(
         dashboard,
         1,
         2,
         signalText,
         text_color = bullish ? blackText : whiteText,
         bgcolor = activeColor
    )

    table.cell(
         dashboard,
         0,
         3,
         "Z-Score",
         text_color = whiteText,
         bgcolor = darkBackground
    )

    table.cell(
         dashboard,
         1,
         3,
         zScoreText,
         text_color = whiteText,
         bgcolor = tpStateColor
    )

    table.cell(
         dashboard,
         0,
         4,
         "TP State",
         text_color = whiteText,
         bgcolor = darkBackground
    )

    table.cell(
         dashboard,
         1,
         4,
         tpStateText,
         text_color = longTpArmed ? whiteText : blackText,
         bgcolor = tpStateColor
    )

    table.cell(
         dashboard,
         0,
         5,
         "Distance",
         text_color = whiteText,
         bgcolor = darkBackground
    )

    table.cell(
         dashboard,
         1,
         5,
         trailDistanceText,
         text_color = whiteText,
         bgcolor = darkBackground
    )

    table.cell(
         dashboard,
         0,
         6,
         "Overlay",
         text_color = whiteText,
         bgcolor = darkBackground
    )

    table.cell(
         dashboard,
         1,
         6,
         overlayText,
         text_color = whiteText,
         bgcolor = darkBackground
    )

if not showDashboard and barstate.islast
    table.clear(
         dashboard,
         0,
         0,
         1,
         6
    )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Alert Conditions
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(
     upSignal,
     title = "Up Signal",
     message = "Uptrick VTT: Up signal printed on {{ticker}} at {{close}}"
)

alertcondition(
     downSignal,
     title = "Down Signal",
     message = "Uptrick VTT: Down signal printed on {{ticker}} at {{close}}"
)

alertcondition(
     longTpSignal,
     title = "Long Dynamic TP",
     message = "Uptrick VTT: Long dynamic TP printed on {{ticker}} at {{close}}"
)

alertcondition(
     shortTpSignal,
     title = "Short Dynamic TP",
     message = "Uptrick VTT: Short dynamic TP printed on {{ticker}} at {{close}}"
)

alertcondition(
     upSignal or downSignal,
     title = "Any Trend Signal",
     message = "Uptrick VTT: New trend signal printed on {{ticker}} at {{close}}"
)

alertcondition(
     longTpSignal or shortTpSignal,
     title = "Any Dynamic TP",
     message = "Uptrick VTT: New dynamic TP printed on {{ticker}} at {{close}}"
)

alertcondition(
     upSignal or downSignal or longTpSignal or shortTpSignal,
     title = "All VTT Signals",
     message = "Uptrick VTT: New signal printed on {{ticker}} at {{close}}"
)
````
