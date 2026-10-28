# Market Internals Dashboard

- url: https://www.tradingview.com/script/p8mnVkiH-Market-Internals-Dashboard/
- type: indicator
- pine_id: PUB;ded7a68cdfcd4dfda3dd0eef91aabdde
- version: 1.0

## Description

Market Internals Dashboard
Market Internals Dashboard is a confirmation tool for monitoring TICK, ADD, and VOLD during the U.S. trading session. It is designed to help evaluate whether internal market participation supports or diverges from price action.
The indicator supports NYSE and NASDAQ internals and can be loaded multiple times to monitor different internals simultaneously.
Internals
TICK measures the number of stocks trading on an uptick versus a downtick. It is useful for evaluating short-term buying and selling pressure.
ADD represents advancing issues minus declining issues and provides a broader view of market breadth.
VOLD represents up volume minus down volume and provides information about the volume participation behind market direction.
When VOLD is selected, the dashboard also displays NYSE and NASDAQ Up/Down Volume ratios. Positive ratios indicate greater up-volume participation, while negative ratios indicate greater down-volume participation.
Display Modes
The selected internal can be displayed as:
- Candles
- Bars
- Columns
The indicator also supports Bar Value and Cumulative display modes.
Cumulative values reset at the beginning of the NY regular session.
Signal Zones
Default signal zones are based on the selected internal:
TICK
- Signal: ±600
- Strong: ±1000
ADD
- Signal: ±1000
- Strong: ±2000
VOLD
- Signal: ±500 million
- Strong: ±1 billion
These levels are intended as contextual references rather than standalone trade signals.
The signal-zone limits can be overridden through the indicator settings when different thresholds are preferred.
TICK Zero Cross
When enabled, confirmed TICK closes crossing the zero line are marked on the chart.
A bullish marker identifies a confirmed cross above zero, while a bearish marker identifies a confirmed cross below zero.
This provides a simple visual reference for changes in short-term internal pressure.
Internal Extreme Alerts
Alerts are available for confirmed threshold crosses during the NY regular session:
TICK: ±700
ADD: ±1500
The alert occurs on the first confirmed cross of the threshold, rather than continuously while the internal remains beyond it.
VOLD does not use an extreme alert because volume participation is additionally evaluated through the NYSE and NASDAQ Up/Down Volume ratios.
Custom Market-Internal Symbols
The default configuration uses TradingView's USI market-internal symbols for NYSE and NASDAQ data.
Symbol inputs are configurable so compatible alternative market-internal feeds can be substituted.
Alternative feeds may differ in:
- constituent universe
- calculation methodology
- session availability
- scaling
Therefore, the default signal and alert thresholds may require adjustment when alternative symbols are used.
Intended Use
This indicator is designed as a market-confirmation tool, not an entry system.
A typical workflow is to first identify important price structure or key levels, then use TICK, ADD, and VOLD to evaluate whether market participation confirms or diverges from the price move.
For example:
Price structure → acceptance/rejection → market-internal confirmation
Agreement between price and multiple internals can provide evidence of broader participation. Divergence can indicate that a price move lacks internal confirmation.
Notes
Market-internal data availability depends on the selected symbol and Trading View data feed. Missing or unavailable source data may result in gaps.
The default thresholds are reference levels and should not be interpreted as guaranteed reversal, continuation, or trade-entry signals.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//
// © immediatePerso44773

//@version=6
indicator("Market Internals Dashboard", "Mkt Dash",
 overlay = false, format = format.volume, precision = 2, max_bars_back = 1440)

// Colors
color none    = color.rgb(0, 0, 0, 100)
color clrBull = color.lime
color clrBear = color.maroon
color sigBull = color.aqua
color sigBear = color.maroon
color maxBull = color.rgb(175, 235, 245)
color maxBear = color.rgb(255, 205, 205)
string TICK = "TICK"
string ADD = "ADD"
string VOLD = "VOLD"
string ny = "NYSE"
string nq = "NASDAQ"
string bv = "Bar Value"
string cm = "Cumulative"

g = "SELECTED INDICATOR AND EXCHANGE"

ind        = input.string(VOLD, "Indicator", options = [TICK, ADD, VOLD], group = g)
exch       = input.string(ny, "Exchange", options = [ny, nq], inline = "internal", group = g)
modeInput  = input.string("Candles", "Mode", options = ["Candles", "Bars", "Columns"], group = g)
scale      = input.string(bv, "Scale", options = [bv, cm])
cumulative = scale == cm

string g0 = "Market Internal Symbols"

tickNY = input.symbol("USI:TICK",  "NYSE TICK",   
 tooltip = "Default TradingView market-internal symbol. Alternative data feeds may use different values or scaling.",
 group = g0)
tickNQ = input.symbol("USI:TICKQ", "NASDAQ TICK", group = g0)
addNY  = input.symbol("USI:ADD",   "NYSE ADD",    group = g0)
addNQ  = input.symbol("USI:ADDQ",  "NASDAQ ADD",  group = g0)
voldNY = input.symbol("USI:VOLD",  "NYSE VOLD",   group = g0)
voldNQ = input.symbol("USI:VOLDQ", "NASDAQ VOLD", group = g0)
uvolNY = input.symbol("USI:UVOL",  "NYSE Up Volume",     group = g0)
dvolNY = input.symbol("USI:DVOL",  "NYSE Down Volume",   group = g0)
uvolNQ = input.symbol("USI:UVOLQ", "NASDAQ Up Volume",   group = g0)
dvolNQ = input.symbol("USI:DVOLQ", "NASDAQ Down Volume", group = g0)

string g1 = "Signal Settings"

shoSig = input.bool(true, "Show signal zones", group = g1)
ovrMax = input.bool(false, "Override Max", inline = "max", group = g1)
sigMax = input.float(3000, "", inline = "max", group = g1)
ovrMin = input.bool(false, "Override Min", inline = "min", group = g1)
sigMin = input.float(1500, "", inline = "min", group = g1)

string g2 = "Display"

shoZro            = input.bool(true, "Show Zero Line", group = g2)
shoNmh            = input.bool(true, "Differentiate ETH", group = g2)
showTickZeroCross = input.bool( true, "Show TICK Zero Cross",
 tooltip = "Marks confirmed TICK closes that cross the zero line.", group = g2)

float tikRawLo = 600
float tikRawHi = 1000
float addRawLo = 1000
float addRawHi = 2000
float vldRawLo = 500000000
float vldRawHi = 1000000000

var float cumulativeValue = 0.0
var string sym1 = ""
var string sym2 = ""

setSig(s) =>

    minSig = s == sigMin
    maxSig = s == sigMax

    if (minSig and ovrMin) or (maxSig and ovrMax) 

        s

    else

        switch ind
            TICK => 
             minSig ? tikRawLo : tikRawHi
            ADD => 
             minSig ? addRawLo : addRawHi
            VOLD => 
             minSig ? vldRawLo : vldRawHi

sMin = setSig(sigMin)
sMax = setSig(sigMax)

reqSec(sym) =>

    request.security(sym, timeframe.period, [open, high, low, close], barmerge.gaps_on)

reqClose(sym) =>

    request.security(sym, timeframe.period, close, barmerge.gaps_off)
    
calc_ratio(u, d) =>

    d == 0 or u == 0
     ? 0.0 : u >= d
     ? u / d : -(d / u)

getPlotColor(v) =>

    v >= sMax  ? maxBull :
     v >= sMin  ? sigBull :
     v > 0      ? clrBull :
     v <= -sMax ? maxBear :
     v <= -sMin ? sigBear :
     clrBear

if barstate.isfirst and not chart.is_standard

    runtime.error("Only standard time-based charts are supported.")

market = bool(time(timeframe.period, "0930-1600:1234567", "America/New_York"))
firstMarketBar = market and not market[1]

if barstate.isfirst

    switch ind
        TICK =>
            sym1 := tickNY
            sym2 := tickNQ

        ADD =>
            sym1 := addNY
            sym2 := addNQ

        VOLD =>
            sym1 := voldNY
            sym2 := voldNQ

[o1, h1, l1, c1] = reqSec(sym1)
[o2, h2, l2, c2] = reqSec(sym2)

p1O = exch == nq ? o2 : o1
p1H = exch == nq ? h2 : h1
p1L = exch == nq ? l2 : l1
p1C = exch == nq ? c2 : c1

bool testCrossover = ta.crossover(p1C, 0)
bool testCrossunder = ta.crossunder(p1C, 0)

bool tickBullZeroCross = showTickZeroCross and
 ind == TICK and market and barstate.isconfirmed and testCrossover

bool tickBearZeroCross =  showTickZeroCross and
 ind == TICK and market and barstate.isconfirmed and testCrossunder

plotshape(tickBullZeroCross, title = "TICK Bull Zero Cross",
 style = shape.triangleup, location = location.top,
 color = color.lime, size = size.tiny)

plotshape(tickBearZeroCross, title = "TICK Bear Zero Cross",
 style = shape.triangledown, location = location.bottom,
 color = color.red, size = size.tiny)

float tickAlertLevel = 700
float addAlertLevel  = 1500

bool tickBullExtreme = ta.crossover(p1C, tickAlertLevel)
bool tickBearExtreme = ta.crossunder(p1C, -tickAlertLevel)

bool addBullExtreme = ta.crossover(p1C, addAlertLevel)
bool addBearExtreme = ta.crossunder(p1C, -addAlertLevel)

bool bullExtreme = market and barstate.isconfirmed and
 ((ind == TICK and tickBullExtreme) or (ind == ADD  and addBullExtreme))

bool bearExtreme = market and barstate.isconfirmed and
 ((ind == TICK and tickBearExtreme) or (ind == ADD  and addBearExtreme))

alertcondition(bullExtreme, title = "Bullish Internal Extreme",
 message = "Selected market internal crossed above its bullish extreme.")

alertcondition(bearExtreme, title = "Bearish Internal Extreme",
 message = "Selected market internal crossed below its bearish extreme.")

if cumulative

    if firstMarketBar

        cumulativeValue := 0.0
        p1O := 0.0
        p1H := 0.0
        p1L := 0.0
        p1C := 0.0

    else if market

        float previousCum = nz(cumulativeValue[1], 0.0)
        cumulativeValue := previousCum + nz(p1C)
        p1O := previousCum
        p1H := math.max(cumulativeValue, previousCum)
        p1L := math.min(cumulativeValue, previousCum)
        p1C := cumulativeValue

plotColor = getPlotColor(p1C)

bgcolor(shoNmh and not market
 ? color.new(color.gray, 95) : na)

hline(0, "", color.gray, hline.style_solid, 1, false, shoZro
 ? display.all : display.none)

bull1 = hline(sMin, color = none)
bull2 = hline(sMax, color = none)
bear1 = hline(-sMin, color = none)
bear2 = hline(-sMax, color = none)

fill(bull1, bull2, color.new(color.green, 70), display = shoSig
 ? display.all : display.none)

fill(bear1, bear2, color.new(color.red, 70), display = shoSig
 ? display.all : display.none)

plotcandle(p1O, p1H, p1L, p1C, color = plotColor,
 wickcolor = plotColor, bordercolor = plotColor,
 display = modeInput == "Candles"
 ? display.all : display.none)
 
plotbar(p1O, p1H, p1L, p1C, color = plotColor,
 display = modeInput == "Bars"
 ? display.all : display.none)

plot(p1C, "Selected Internal",
 color = plotColor, linewidth = 2, style = plot.style_columns, 
 display = modeInput == "Columns"
 ? display.all : display.none)

uvol_ny = reqClose(uvolNY)
dvol_ny = reqClose(dvolNY)
uvol_nq = reqClose(uvolNQ)
dvol_nq = reqClose(dvolNQ)

ny_ratio = calc_ratio(uvol_ny, dvol_ny)
nq_ratio = calc_ratio(uvol_nq, dvol_nq)

var table breadthTable = table.new(position.bottom_right, 5, 1,
 frame_color = color.new(color.gray, 50), frame_width = 1)

if ind == VOLD and barstate.islast

    ny_color = ny_ratio >= 0
     ? color.green : #cb0526
    nq_color = nq_ratio >= 0
     ? color.green : #cb0526

    table.cell(breadthTable, 0, 0, "NYSE VOLD",
     text_color = color.white,
     bgcolor = color.new(color.gray, 80))
    table.cell(breadthTable, 1, 0,
     str.format("{0,number,#.##}:1", ny_ratio),
     text_color = color.white, bgcolor = ny_color)
    table.cell(breadthTable, 3, 0, "NASDAQ VOLD", 
     text_color = color.white, bgcolor =  color.new(color.gray, 80))
    table.cell(breadthTable, 4, 0,
     str.format("{0,number,#.##}:1", nq_ratio),
     text_color = color.white, bgcolor = nq_color)
````
