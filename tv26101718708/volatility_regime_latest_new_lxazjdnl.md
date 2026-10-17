# Volatility Regime (Latest) New!

- url: https://www.tradingview.com/script/LxazJdNl-Volatility-Regime-Latest-New/
- type: indicator
- pine_id: PUB;77fa60b454e349258d1b55f23ceaf5ac
- version: 1.0

## Description

This indicator is designed to separate two different market concepts: volatility regime and price displacement.

The main visualization focuses on Volatility Regime, calculated from the standard deviation of log returns over a selected lookback period. The result is ranked against its own historical distribution using a rolling percentile filter, allowing the market to be classified into Low, Mid, or High Volatility regimes without assuming a normal distribution.

A secondary reference metric, Price Displacement, is also included. It measures how far the current price is from its rolling mean using a price z-score. This helps identify whether price is extended from its local average, while keeping it separate from the main volatility regime logic.

Core concept:

* Volatility Regime measures how unstable returns are.
* Price Displacement measures how far price is from its mean.
* Rolling percentile ranking is used to classify regimes empirically.
* The model does not assume that market returns follow a normal distribution.

This tool is intended for regime awareness, risk context, volatility filtering, and market condition analysis. It should not be used as a standalone buy or sell signal.

P-Value

## Source Code

````pine
//@version=6
indicator(
    "Volatility Regime + Price Displacement",
    shorttitle = "VolReg + Disp",
    overlay = false,
    precision = 4
)

//====================================================
// Inputs
//====================================================
string grpVol = "1) Volatility Regime"
volSrc = input.source(close, "Volatility Source", group = grpVol)
int volLength = input.int(20, "Volatility SD Length", minval = 2, group = grpVol)

string grpDisp = "2) Price Displacement"
dispSrc = input.source(hlc3, "Displacement Source", group = grpDisp)
int dispLength = input.int(20, "Price Z-Score Length", minval = 2, group = grpDisp)

string grpRegime = "Regime Filter"
int regimeLookback = input.int(100, "Percentile Lookback", minval = 5, group = grpRegime)
int lowPctInput = input.int(33, "Low %", minval = 0, maxval = 100, inline = "pct", group = grpRegime)
int highPctInput = input.int(67, "High %", minval = 0, maxval = 100, inline = "pct", group = grpRegime)

string grpCalc = "Calculation"
string estimator = input.string(
    "Population (n)",
    "Estimator",
    options = ["Population (n)", "Sample (n-1)"],
    group = grpCalc
)

string grpDisp2 = "Display"
bool showTable = input.bool(true, "Show Status Table", group = grpDisp2)
bool showVolLine = input.bool(true, "Plot Volatility Percentile", group = grpDisp2)

//====================================================
// Setup
//====================================================
int lowPct = lowPctInput <= highPctInput ? lowPctInput : highPctInput
int highPct = lowPctInput <= highPctInput ? highPctInput : lowPctInput
bool useSample = estimator == "Sample (n-1)"

//====================================================
// Standard Deviation Function
//====================================================
calcStdDev(series float x, int len, bool sample) =>
    float meanX = ta.sma(x, len)
    float sumSq = 0.0
    float result = na

    if not na(meanX)
        for i = 0 to len - 1
            float xi = x[i]
            sumSq += math.pow(xi - meanX, 2)

        float denom = sample ? (len - 1.0) : len * 1.0
        result := denom > 0 ? math.sqrt(sumSq / denom) : na

    result

//====================================================
// 1) Volatility Regime
//    SD(log return, N) -> percentile
//====================================================
float logRet = volSrc > 0 and volSrc[1] > 0 ? math.log(volSrc / volSrc[1]) : na
float hv = calcStdDev(logRet, volLength, useSample) * 100.0   // % per bar
float hvPctRank = ta.percentrank(hv, regimeLookback)

string volRegime = if na(hv) or na(hvPctRank)
    "NA"
else if hvPctRank <= lowPct
    "Low Vol"
else if hvPctRank >= highPct
    "High Vol"
else
    "Mid Vol"

color volColor = switch volRegime
    "Low Vol"  => color.teal
    "High Vol" => color.orange
    "Mid Vol"  => color.gray
    => color.gray

color bgColor = switch volRegime
    "Low Vol"  => color.new(color.teal, 93)
    "High Vol" => color.new(color.orange, 92)
    "Mid Vol"  => color.new(color.gray, 96)
    => na

//====================================================
// 2) Price Displacement
//    abs(price z-score) -> percentile
//====================================================
float priceMean = ta.sma(dispSrc, dispLength)
float priceSd = calcStdDev(dispSrc, dispLength, useSample)

float priceZ = not na(priceMean) and not na(priceSd) and priceSd > 0
     ? (dispSrc - priceMean) / priceSd
     : na

float absPriceZ = math.abs(priceZ)
float absZPctRank = ta.percentrank(absPriceZ, regimeLookback)

//====================================================
// Plots
//====================================================
plot(
    showVolLine ? hvPctRank : na,
    title = "Volatility Percentile Rank",
    color = volColor,
    linewidth = 2
)

hline(lowPct, "Low Boundary", color = color.new(color.teal, 15))
hline(highPct, "High Boundary", color = color.new(color.orange, 15))
hline(50, "Midline", color = color.new(color.gray, 80))

bgcolor(bgColor, title = "Volatility Regime Background")

//====================================================
// Status Table
//====================================================
var table statusTable = table.new(position.top_right, 2, 6, border_width = 1)

if barstate.islast and showTable
    table.cell(statusTable, 0, 0, "Volatility")
    table.cell(statusTable, 1, 0, str.tostring(hv, "#.####") + "% / bar")

    table.cell(statusTable, 0, 1, "Vol Percentile")
    table.cell(statusTable, 1, 1, str.tostring(hvPctRank, "#.##") + "%")

    table.cell(statusTable, 0, 2, "Vol Regime")
    table.cell(statusTable, 1, 2, volRegime, text_color = volColor)

    table.cell(statusTable, 0, 3, "Price Z-Score")
    table.cell(statusTable, 1, 3, str.tostring(priceZ, "#.####"))

    table.cell(statusTable, 0, 4, "|Price Z|")
    table.cell(statusTable, 1, 4, str.tostring(absPriceZ, "#.####"))

    table.cell(statusTable, 0, 5, "|Z| Percentile")
    table.cell(statusTable, 1, 5, str.tostring(absZPctRank, "#.##") + "%")
````
