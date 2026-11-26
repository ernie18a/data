# Aurora Volume Momentum & MA Ribbon

- url: https://www.tradingview.com/script/V7dTzncy-Aurora-Volume-Momentum-MA-Ribbon/
- type: indicator
- pine_id: PUB;d444b0793a9546adbfa78fc7933d1539
- version: 1.0

## Description

[b]Aurora Volume Momentum & MA Ribbon[/b]

[b]Overview[/b]

Aurora Volume Momentum & MA Ribbon combines a volume momentum oscillator in a separate pane with an optional, four-line moving average ribbon on the price chart. The oscillator measures smoothed, volume-weighted price changes relative to recent price variability. Background shading identifies when that momentum agrees with price's position around a longer-term SMA. The ribbon adds independently configurable trend context without changing the oscillator calculation.

The design brings together three observations: momentum direction, alignment with a price baseline, and the arrangement of selected moving averages. Each remains visible and interpretable on its own.

[b]Calculation Framework[/b]

The oscillator uses the following sequence:

1. Calculate the change between the current close and the previous close.
2. Multiply that change by the chart's reported volume.
3. Smooth the result with an EMA using the Signal Period.
4. Divide the smoothed result by the population standard deviation of closing prices over the Volatility Period.
5. Calculate another EMA of the resulting histogram using the same Signal Period to produce the signal line.

[b]Histogram = EMA((close - previous close) × volume, Signal Period) / Standard Deviation(close, Volatility Period)[/b]

[b]Signal Line = EMA(Histogram, Signal Period)[/b]

[b]Price Filter = SMA(close, Price Filter MA Length)[/b]

Smoothing takes place before volatility normalization. The calculation uses standard deviation of closing prices. It does not use ATR or relative-volume normalization.

The histogram is unbounded and is not expressed as a percentage. Its magnitude depends on the instrument, timeframe, reported volume, and price variability. Values should be evaluated in their own chart context rather than treated as directly comparable across markets or feeds. Lower price deviation can amplify a reading even without an equivalent increase in volume-weighted price change.

[b]Core Calculation — Pine Script Excerpt[/b]

[pine]
float volatility = ta.stdev(close, volatilityPeriod, true)
float priceChange = ta.change(close)
float volumeMomentum = ta.ema(priceChange * volume, signalPeriod)
bool validData = not na(volume) and volume >= 0 and not na(volumeMomentum) and not na(volatility) and volatility > 0
float momentum = validData ? volumeMomentum / volatility : na
float signalLine = ta.ema(momentum, signalPeriod)
float priceFilter = ta.sma(close, maLength)
[/pine]

[b]What the Oscillator Displays[/b]

[b]Green histogram bars:[/b] Positive smoothed, volume-weighted price momentum. A green bar can remain visible during a falling candle because the calculation includes recent price changes through EMA smoothing.

[b]Red histogram bars:[/b] Negative smoothed, volume-weighted price momentum. A red bar can remain visible during a rising candle for the same reason.

[b]Blue signal line:[/b] An additional EMA of the histogram. Its position above or below zero describes the direction of the more heavily smoothed momentum. The histogram's position relative to this line shows whether its current reading is above or below its recent exponential average. A histogram crossing above the signal line while both remain negative can represent weakening negative momentum.

[b]Dashed zero line:[/b] The boundary between positive and negative oscillator values.

The histogram represents a price-and-volume proxy. It does not measure actual buyer-versus-seller executed volume, bid/ask delta, or cumulative volume delta.

[b]Background Interpretation[/b]

Background shading combines histogram direction with an independent SMA price filter:

- [b]Green:[/b] The histogram is above the positive Momentum Threshold and the close is above the price-filter SMA.
- [b]Red:[/b] The histogram is below the negative Momentum Threshold and the close is below the price-filter SMA.
- [b]Neutral:[/b] Neither condition is satisfied, including momentum/price disagreement, threshold equality, price at the SMA, or unavailable calculation data.

Neutral regions inherit the chart's background, so their appearance follows the selected TradingView theme. Directional zones use the histogram colors at 85% transparency.

At the default threshold of zero, shading requires a positive or negative histogram together with matching price alignment. Increasing the threshold requires a larger absolute histogram value for shading. This setting controls background qualification and does not create an alert or an entry signal.

[b]Optional Four-Line MA Ribbon[/b]

Enable [b]Show MA Ribbon[/b] to display up to four moving averages on the main price chart while keeping the oscillator in its own pane. Each line has independent settings for enable/disable, averaging method, length, source, color, and width.

Supported averaging methods:

- [b]EMA[/b]: Exponential smoothing with greater weight on recent observations.
- [b]SMA[/b]: Arithmetic average over the selected length.
- [b]WMA[/b]: Linear weighting toward recent observations.
- [b]RMA[/b]: Wilder's smoothing, using a smoothing factor of 1 / length.
- [b]VWMA[/b]: Average of the selected source weighted by chart volume.
- [b]HMA[/b]: Hull moving average, combining weighted averages to reduce lag.

Optional fills connect adjacent enabled pairs: MA 1–2, MA 2–3, and MA 3–4. A fill is green when the first numbered MA is above the next and red when it is below. Equal values produce no fill. Fill transparency is adjustable. Disabling a line removes both fills connected to that line; the script does not bridge across disabled lines.

MA numbers are not automatically sorted by length. With ascending lengths and comparable averaging methods, consistent ordering can help visualize trend alignment. Mixed ordering identifies disagreement between the selected averages. These are contextual observations rather than automatic trade instructions.

The ribbon operates independently of the oscillator's SMA filter. Changing a ribbon length or method does not change the histogram, signal line, or background conditions.

[b]Default Configuration[/b]

- [b]Signal Period[/b]: 8
- [b]Volatility Period[/b]: 20
- [b]Price Filter MA Length[/b]: 200, SMA
- [b]Momentum Threshold[/b]: 0
- [b]MA Ribbon[/b]: Disabled
- [b]MA 1[/b]: 9 EMA, close source
- [b]MA 2[/b]: 21 EMA, close source
- [b]MA 3[/b]: 50 EMA, close source
- [b]MA 4[/b]: 200 SMA, close source
- [b]Adjacent ribbon fills[/b]: Enabled when the ribbon is shown; 90% transparency

All four individual MA switches are enabled initially. The master ribbon switch controls whether they appear on the price chart.

[b]Parameter Adjustment[/b]

A shorter Signal Period makes both smoothing stages more responsive. A longer period smooths both the histogram and signal line and generally delays directional changes.

The Volatility Period changes the price-deviation denominator. Its effect on magnitude depends on the underlying price sequence; shortening it does not always increase or decrease the histogram.

A shorter Price Filter MA Length makes the background's price baseline respond more quickly. A longer length provides a slower reference. Ribbon lengths and methods can be adjusted separately to inspect short-, medium-, and longer-term price structure.

[b]Data and Real-Time Behavior[/b]

All calculations use the current chart's data and timeframe. Higher-timeframe context can be inspected by opening a separate chart or changing the chart timeframe; the script does not request an additional timeframe internally.

The oscillator requires usable volume data and nonzero price standard deviation. Forex and some CFD feeds may report tick volume rather than centralized traded volume. Missing volume or a zero volatility denominator leaves the oscillator unavailable. The ribbon's price-based averages can still function without volume; VWMA requires usable volume.

The current candle's histogram, signal line, ribbon, and shading update as new data arrives. Their appearance can change before the candle closes. The script uses no future-bar references or higher-timeframe lookahead. Historical values can still change if the data provider revises its feed or the user changes settings.

[b]Scope and Attribution[/b]

Aurora is a visual analysis indicator. It contains no automatic buy/sell labels, entry rules, alerts, stop-loss levels, profit targets, or backtested strategy results. Momentum alignment does not guarantee continuation or profitability.

[b]Inspiration and Original Author[/b]

Aurora Volume Momentum & MA Ribbon is inspired by Nova Volume Indicator by SplitzMagic. Credit for the original indicator concept belongs to SplitzMagic.

This script presents my own interpretation of that idea through an independently written implementation, with the addition of a configurable four-line moving average ribbon. I am sharing my implementation as open source so the community can inspect the calculations, understand the design, and build on this interpretation.

This publication shares my own code. It does not disclose SplitzMagic’s original source code, and it is not an official release, collaboration, or endorsement by the original author.

## Source Code

````pine
// Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International.
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © Drizzle_Algo56
//@version=6
indicator("Aurora Volume Momentum & MA Ribbon", shorttitle="Aurora VMR", overlay=false, precision=2)

//────────────────────────────────────────────────────────────────────
// OSCILLATOR SETTINGS
//────────────────────────────────────────────────────────────────────
int signalPeriod = input.int(8, "Signal Period", minval=1)
int volatilityPeriod = input.int(20, "Volatility Period", minval=1)
int maLength = input.int(200, "Price Filter MA Length", minval=1)

float threshold = input.float(
     0.0, "Momentum Threshold",
     minval=0.0, step=1.0,
     tooltip="Minimum absolute histogram value required for background shading. No alerts or entry signals are generated.")

color bullishColor = input.color(
     color.rgb(76, 175, 80), "Histogram Bullish Color")

color bearishColor = input.color(
     color.rgb(255, 82, 82), "Histogram Bearish Color")

color signalColor = input.color(
     color.rgb(41, 98, 255), "Signal Line Color")

//────────────────────────────────────────────────────────────────────
// RIBBON DISPLAY
//────────────────────────────────────────────────────────────────────
string ribbonGroup = "MA Ribbon: Display"

bool showRibbon = input.bool(
     false, "Show MA Ribbon", group=ribbonGroup,
     tooltip="Display the selected moving averages on the price chart.")

bool showRibbonFill = input.bool(
     true, "Fill Between Adjacent MAs", group=ribbonGroup,
     tooltip="Fill enabled pairs: MA 1–2, MA 2–3 and MA 3–4. Green when the first MA is above the next; red when below.")

int ribbonTransparency = input.int(
     90, "Ribbon Fill Transparency",
     minval=0, maxval=100, group=ribbonGroup)

//────────────────────────────────────────────────────────────────────
// MA 1
//────────────────────────────────────────────────────────────────────
string ma1Group = "MA Ribbon: MA 1"

bool showMa1 = input.bool(true, "Enable MA 1", group=ma1Group)

string ma1Type = input.string(
     "EMA", "MA Type",
     options=["EMA", "SMA", "WMA", "RMA", "VWMA", "HMA"],
     group=ma1Group)

int ma1Length = input.int(
     9, "Length", minval=1, maxval=5000, group=ma1Group)

float ma1Source = input.source(close, "Source", group=ma1Group)

color ma1Color = input.color(
     color.rgb(255, 193, 7), "Line Color", group=ma1Group)

int ma1Width = input.int(
     2, "Line Width", minval=1, maxval=5, group=ma1Group)

//────────────────────────────────────────────────────────────────────
// MA 2
//────────────────────────────────────────────────────────────────────
string ma2Group = "MA Ribbon: MA 2"

bool showMa2 = input.bool(true, "Enable MA 2", group=ma2Group)

string ma2Type = input.string(
     "EMA", "MA Type",
     options=["EMA", "SMA", "WMA", "RMA", "VWMA", "HMA"],
     group=ma2Group)

int ma2Length = input.int(
     21, "Length", minval=1, maxval=5000, group=ma2Group)

float ma2Source = input.source(close, "Source", group=ma2Group)

color ma2Color = input.color(
     color.rgb(0, 188, 212), "Line Color", group=ma2Group)

int ma2Width = input.int(
     2, "Line Width", minval=1, maxval=5, group=ma2Group)

//────────────────────────────────────────────────────────────────────
// MA 3
//────────────────────────────────────────────────────────────────────
string ma3Group = "MA Ribbon: MA 3"

bool showMa3 = input.bool(true, "Enable MA 3", group=ma3Group)

string ma3Type = input.string(
     "EMA", "MA Type",
     options=["EMA", "SMA", "WMA", "RMA", "VWMA", "HMA"],
     group=ma3Group)

int ma3Length = input.int(
     50, "Length", minval=1, maxval=5000, group=ma3Group)

float ma3Source = input.source(close, "Source", group=ma3Group)

color ma3Color = input.color(
     color.rgb(171, 71, 188), "Line Color", group=ma3Group)

int ma3Width = input.int(
     2, "Line Width", minval=1, maxval=5, group=ma3Group)

//────────────────────────────────────────────────────────────────────
// MA 4
//────────────────────────────────────────────────────────────────────
string ma4Group = "MA Ribbon: MA 4"

bool showMa4 = input.bool(true, "Enable MA 4", group=ma4Group)

string ma4Type = input.string(
     "SMA", "MA Type",
     options=["EMA", "SMA", "WMA", "RMA", "VWMA", "HMA"],
     group=ma4Group)

int ma4Length = input.int(
     200, "Length", minval=1, maxval=5000, group=ma4Group)

float ma4Source = input.source(close, "Source", group=ma4Group)

color ma4Color = input.color(
     color.rgb(144, 164, 174), "Line Color", group=ma4Group)

int ma4Width = input.int(
     2, "Line Width", minval=1, maxval=5, group=ma4Group)

//────────────────────────────────────────────────────────────────────
// MA FUNCTION — CONSISTENT CALCULATIONS
//────────────────────────────────────────────────────────────────────
f_ma(series float source, simple int length, simple string maType) =>
    // Each historical calculation runs on every function call.
    float emaValue = ta.ema(source, length)
    float smaValue = ta.sma(source, length)
    float wmaValue = ta.wma(source, length)
    float rmaValue = ta.rma(source, length)
    float vwmaValue = ta.vwma(source, length)
    float hmaValue = ta.hma(source, math.max(length, 2))

    // Select an already-calculated value.
    switch maType
        "EMA"  => emaValue
        "SMA"  => smaValue
        "WMA"  => wmaValue
        "RMA"  => rmaValue
        "VWMA" => vwmaValue
        "HMA"  => length == 1 ? source : hmaValue
        => emaValue

//────────────────────────────────────────────────────────────────────
// VOLUME MOMENTUM CALCULATION
//────────────────────────────────────────────────────────────────────
float volatility = ta.stdev(close, volatilityPeriod, true)
float priceChange = ta.change(close)
float volumeMomentum = ta.ema(priceChange * volume, signalPeriod)

bool validData = (
     not na(volume) and
     volume >= 0 and
     not na(volumeMomentum) and
     not na(volatility) and
     volatility > 0)

float momentum = validData ? volumeMomentum / volatility : na
float signalLine = ta.ema(momentum, signalPeriod)
float priceFilter = ta.sma(close, maLength)

//────────────────────────────────────────────────────────────────────
// OSCILLATOR DISPLAY
//────────────────────────────────────────────────────────────────────
color histogramColor = momentum >= 0 ? bullishColor : bearishColor

plot(
     momentum,
     title="VMO Histogram",
     color=histogramColor,
     linewidth=2,
     style=plot.style_histogram)

plot(
     validData ? signalLine : na,
     title="Signal Line",
     color=signalColor,
     linewidth=1,
     style=plot.style_linebr)

hline(
     0.0,
     title="Zero",
     color=color.gray,
     linestyle=hline.style_dashed)

//────────────────────────────────────────────────────────────────────
// MOMENTUM / PRICE ALIGNMENT BACKGROUND
//────────────────────────────────────────────────────────────────────
bool bullishZone = (
     validData and
     momentum > threshold and
     close > priceFilter)

bool bearishZone = (
     validData and
     momentum < -threshold and
     close < priceFilter)

color zoneColor = bullishZone ? color.new(bullishColor, 85) :
     bearishZone ? color.new(bearishColor, 85) : na

bgcolor(zoneColor, title="Trading Zones")

//────────────────────────────────────────────────────────────────────
// RIBBON CALCULATIONS — ALWAYS EXECUTED
//────────────────────────────────────────────────────────────────────
float ma1 = f_ma(ma1Source, ma1Length, ma1Type)
float ma2 = f_ma(ma2Source, ma2Length, ma2Type)
float ma3 = f_ma(ma3Source, ma3Length, ma3Type)
float ma4 = f_ma(ma4Source, ma4Length, ma4Type)

//────────────────────────────────────────────────────────────────────
// PRICE-CHART OVERLAY
//────────────────────────────────────────────────────────────────────
ma1Plot = plot(
     showRibbon and showMa1 ? ma1 : na,
     title="Ribbon MA 1",
     color=ma1Color,
     linewidth=ma1Width,
     style=plot.style_linebr,
     force_overlay=true)

ma2Plot = plot(
     showRibbon and showMa2 ? ma2 : na,
     title="Ribbon MA 2",
     color=ma2Color,
     linewidth=ma2Width,
     style=plot.style_linebr,
     force_overlay=true)

ma3Plot = plot(
     showRibbon and showMa3 ? ma3 : na,
     title="Ribbon MA 3",
     color=ma3Color,
     linewidth=ma3Width,
     style=plot.style_linebr,
     force_overlay=true)

ma4Plot = plot(
     showRibbon and showMa4 ? ma4 : na,
     title="Ribbon MA 4",
     color=ma4Color,
     linewidth=ma4Width,
     style=plot.style_linebr,
     force_overlay=true)

//────────────────────────────────────────────────────────────────────
// OPTIONAL RIBBON FILLS
//────────────────────────────────────────────────────────────────────
bool enableFill12 = showRibbon and showRibbonFill and showMa1 and showMa2
bool enableFill23 = showRibbon and showRibbonFill and showMa2 and showMa3
bool enableFill34 = showRibbon and showRibbonFill and showMa3 and showMa4

color fill12 = enableFill12 and ma1 != ma2 ?
     color.new(ma1 > ma2 ? bullishColor : bearishColor, ribbonTransparency) : na

color fill23 = enableFill23 and ma2 != ma3 ?
     color.new(ma2 > ma3 ? bullishColor : bearishColor, ribbonTransparency) : na

color fill34 = enableFill34 and ma3 != ma4 ?
     color.new(ma3 > ma4 ? bullishColor : bearishColor, ribbonTransparency) : na

fill(
     ma1Plot, ma2Plot,
     color=fill12,
     title="Ribbon Fill 1-2",
     fillgaps=false)

fill(
     ma2Plot, ma3Plot,
     color=fill23,
     title="Ribbon Fill 2-3",
     fillgaps=false)

fill(
     ma3Plot, ma4Plot,
     color=fill34,
     title="Ribbon Fill 3-4",
     fillgaps=false)
````
