# Adpative Dual Cloud | NAL

- url: https://www.tradingview.com/script/9jXgavvC-Adpative-Dual-Cloud-NAL/
- type: indicator
- pine_id: PUB;392633fc95724aa38bd96a37f1509e6b
- version: 1.0

## Description

[b]1. Overview
[/b]
Adaptive Dual Cloud | NAL is a dual-baseline trend cloud built from two separate smoothing structures: a Kijun-style midpoint baseline and an ALMA baseline. Instead of relying on a single moving average or one volatility model, the indicator builds an adaptive cloud around both baselines and only confirms direction when price escapes the full combined structure.

The purpose of the indicator is to create a stricter trend envelope. The Kijun side captures broader structural balance, while the ALMA side adds a smoother adaptive layer. The final upper and lower cloud boundaries are selected from both systems, forcing price to clear the stronger side of the cloud before a bullish or bearish state is confirmed.


[b]2. Calculation
[/b]
The indicator starts by creating two independent baselines. The first baseline is a Kijun-style midpoint calculated from the highest and lowest values over the selected lookback. This represents a structural equilibrium zone.

[pine]kijun_sen = math.avg(ta.lowest(cloudLen1), ta.highest(cloudLen1))
[/pine]
The second baseline uses ALMA, giving the cloud a smoother weighted-average component with adjustable sigma and offset. This adds a more refined smoothing layer beside the Kijun structure.

[pine]alma_base = ta.alma(srcSeries, cloudLen2, cloud2Off, cloud2Sig)
[/pine]
The indicator then calculates volatility using a selectable deviation engine. The volatility source can be price, the residual between price and the cloud average, or the cloud structure itself. This allows the band width to be built from different layers of market behavior.

[pine]VolSrc = switch devSrc
"Price"     => srcSeries
"Residuals" => srcSeries - math.avg(alma_base, kijun_sen)
"Cloud"     => math.avg(alma_base, kijun_sen)[/pine]

The volatility engine supports multiple deviation types, including standard deviation, mean absolute deviation, median absolute deviation, exponential deviation, ATR, linear regression deviation, Hull deviation, FRAMA deviation, Kauffman adaptive deviation, Gaussian deviation, and quantile deviation.

After volatility is calculated, adaptive upper and lower bands are created around both baselines.

[pine]upper_kijun = kijun_sen + vol * multi_u
lower_kijun = kijun_sen - vol * multi_l

upper_alma = alma_base + vol * multi_u
lower_alma = alma_base - vol * multi_l[/pine]

The final cloud uses the highest upper boundary and the lowest lower boundary. This makes the signal more selective because price must break beyond the combined cloud, not just one individual baseline.

[pine]upper = math.max(upper_kijun, upper_alma)
lower = math.min(lower_kijun, lower_alma)[/pine]

A bullish state triggers when price closes above the final upper cloud. A bearish state triggers when price closes below the final lower cloud. When price remains inside the cloud, the previous state is held.


3. Key Features

[list=1]
[*]Dual-baseline cloud using Kijun structure and ALMA smoothing.
[*]Adaptive upper and lower bands built from selectable volatility models.
[*]Multiple deviation engines for different volatility interpretations.
[*]Selectable volatility source: price, residuals, or cloud structure.
[*]Final cloud requires price to clear the combined upper or lower boundary.
[*]State-based candle coloring, cloud coloring, glow effect, and directional fills.
[/list]


4. Use

Adaptive Dual Cloud is designed to identify when price escapes a combined structural and smoothed volatility envelope. A close above the upper cloud reflects bullish expansion beyond both baseline systems, while a close below the lower cloud reflects bearish expansion below the combined structure.

The indicator is intentionally stricter than a single-baseline channel. By combining a Kijun-style midpoint with an ALMA baseline, it creates a cloud that filters more of the internal noise before confirming a directional regime.

This indicator is best used as a specialized module within a complete strategy framework. Its role is to isolate a cloud-based volatility and structure layer, where price must prove strength or weakness against more than one adaptive baseline. The full value comes from how this regime signal is integrated into a broader process for timing, structure, and execution.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NordicAlphaLab

//@version=6
indicator("Adpative Dual Cloud | NAL", "Adpative Dual Cloud", overlay = true)
import TradingView/ta/12 as ta


//                                     ███╗   ██╗ █████╗ ██╗
//                                     ████╗  ██║██╔══██╗██║
//                                     ██╔██╗ ██║███████║██║
//                                     ██║╚██╗██║██╔══██║██║
//                                     ██║ ╚████║██║  ██║███████╗
//                                     ╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝


// ══════════════════════════════════════  ◈  Colors  ◈ ══════════════════════════════════════

col_mode = input.string("Standard", title = "Color Mode", group = "Visuals", options = ["Standard", "Nordic", "Simple"])

[col_up, col_dn, col_nu] = switch col_mode
    "Standard"  => [color.rgb(0, 255, 200), color.rgb(32, 94, 144), color.gray]
    "Nordic"    => [color.rgb(46, 161, 255), color.rgb(150, 154, 169), color.gray]
    "Simple"    => [color.lime, color.red, color.gray]

tight_tp = "Higher value = tighter band."

// ══════════════════════════════════════ ◈ Inputs ◈ ══════════════════════════════════════

G = "Cloud 1"
G2 = "Cloud 2"
V = "Volatility"

srcSeries             = input.source(close, "Source")
cloudLen1             = input.int(32, 'Cloud 1 Len', group = G)
cloudLen2             = input.int(28, 'Cloud 2 Len', group = G2)
cloud2Sig             = input.float(16, 'Sigma', step = 0.5, group = G2, inline = "CLOUD")
cloud2Off             = input.float(0.42, 'Offset', step = 0.01, minval=0.01, maxval=0.99, group = G2, inline = "CLOUD")


devType = input.string("Gaussian Deviation", "Volatility Type", 
 [ "Standard Deviation" 
 , "Mean Absolute Deviation"
 , "Median Absolute Deviation"
 , "Exponential Deviation"
 , "Average True Range"
 , "Linear Regression Deviation"
 , "Hull Deviation"
 , "Frama Deviation"
 , "Kauffman Adaptive Deviation"
 , "Gaussian Deviation"
 , "Quantile Deviation"],group=V)
devSrc = input.string("Cloud", "Volatility Source", ["Price", "Residuals", "Cloud"], group=V)
volLen                = input.int(30, 'Volatility Lenght', group = V, tooltip = "Uses Custom volatility")
multi_u               = input.float(1.5, 'Upper Mul', step = 0.05, group = V, inline = "VOLAL")
multi_l               = input.float(1, 'Lower Mul', step = 0.05, group = V, inline = "VOLAL")

// ══════════════════════════════════════ ◈ Calculations ◈ ══════════════════════════════════════

// Credits: The Deviation Calculation Functions were used from MintLeafEdge.
// Deviation Calculation Functions
calcStdev(src, period) =>
    ta.stdev(src, period)

calcMAD(src, period) =>
    mean = ta.sma(src, period)
    ta.sma(math.abs(src - mean), period)

calcMedAD(src, period) =>
    float[] deviations = array.new_float()
    for i = 0 to period - 1
        array.push(deviations, math.abs(src[i] - ta.median(src, period)))
    deviations.median()

calcExpDev(src, period) =>
    ema = ta.ema(src, period)
    ta.ema(math.abs(src - ema), period)


calcHullDev(src, period) =>
    hma = ta.hma(src, period)
    math.abs(src - hma)

calcFramaDev(src, period) =>
    frama = ta.frama(src, period)
    math.abs(src - frama)

calcKaufmanDev(src, period) =>
    change = math.abs(src - src[period])
    volatility = 0.0
    for i = 0 to period - 1
        volatility += math.abs(src[i] - src[i + 1])
    er = volatility == 0 ? 0 : change / volatility
    fastSC = 2.0 / (2 + 1)
    slowSC = 2.0 / (30 + 1)
    sc = math.pow(er * (fastSC - slowSC) + slowSC, 2)
    emaSrc = ta.ema(src, period)
    dev = math.abs(src - emaSrc)
    var float kamaDev = na
    kamaDev := na(kamaDev) ? dev : kamaDev + sc * (dev - kamaDev)
    kamaDev

calcGaussianDev(src, period) =>
    weights = array.new_float()
    sumw    = 0.0
    for i = 0 to period - 1
        w = math.exp(-math.pow((i / period) / 2,2))
        array.push(weights, w)
        sumw += w

    wmean = 0.0
    for i = 0 to period - 1
        wmean += src[i] * array.get(weights, i)
    wmean := wmean / sumw

    wvar = 0.0
    for i = 0 to period - 1
        diff = src[i] - wmean
        wvar += math.pow(diff,2) * array.get(weights, i)
    math.sqrt(wvar / sumw)

calcQuantileDev(src, period) =>
    float[] values = array.new_float()
    for i = 0 to period - 1
        array.push(values, src[i])
    array.sort(values)
    q90 = array.get(values, math.round(period * 0.75))
    q10 = array.get(values, math.round(period * 0.25))
    q90 - q10

calcLinRegDev(src, period) =>
    linreg_val = ta.linreg(src, period, 0)
    math.abs(src - linreg_val)
// Main Deviation Calculation
getDeviation(src, period) =>
    switch devType
        "Standard Deviation"        => calcStdev(src, period)
        "Mean Absolute Deviation"   => calcMAD(src, period)
        "Median Absolute Deviation" => calcMedAD(src, period)
        "Exponential Deviation"     => calcExpDev(src, period)
        "Average True Range"        => ta.atr(period)
        "Linear Regression Deviation" => calcLinRegDev(src, period)
        "Hull Deviation"            => calcHullDev(src, period)
        "Frama Deviation"            => calcFramaDev(src, period)
        "Kauffman Adaptive Deviation"=> calcKaufmanDev(src, period)
        "Gaussian Deviation"        => calcGaussianDev(src, period)
        "Quantile Deviation"        => calcQuantileDev(src, period)
        => calcStdev(src, period)

//Kijun-sen
kijun_sen = math.avg(ta.lowest(cloudLen1), ta.highest(cloudLen1))

//ALMA
alma_base = ta.alma(srcSeries, cloudLen2, cloud2Off, cloud2Sig)

//Volatility
VolSrc = switch devSrc
    "Price"     => srcSeries
    "Residuals" => (srcSeries - math.avg(alma_base, kijun_sen))
    "Cloud"     => math.avg(alma_base, kijun_sen)
    => srcSeries

vol = getDeviation(VolSrc, volLen)

//Kijun Adaptive
upper_kijun = kijun_sen + vol * multi_u
lower_kijun = kijun_sen - vol * multi_l

//ALMA Adaptive
upper_alma = alma_base + vol * multi_u
lower_alma = alma_base - vol * multi_l

//Selecting the highest/lowest
//Makes it so both must be long/short
upper = math.max(upper_kijun, upper_alma)
lower = math.min(lower_kijun, lower_alma)

int cloud = 0
cloud := srcSeries > upper ? 1 : srcSeries < lower ? -1 : cloud[1]

// ══════════════════════════════════════ ◈ Plots ◈ ══════════════════════════════════════

color cons_col = col_nu
cons_col := cloud == 1 ? col_up : cloud == -1 ? col_dn : cons_col[1]

//plot
mid = math.avg(upper, lower)
u = plot(upper,color = cons_col, title = "Upper Band")
l = plot(lower,color = cons_col, title = "Lower Band")
m = plot(mid ,color = color.white, display = display.none)
fill(u, m, upper, mid,  color.new(cons_col, 30), color.new(cons_col, 100))
fill(l, m, lower, mid,  color.new(cons_col, 30), color.new(cons_col, 100))

plot(upper, title = "Upper Band Glow", color = color.new(cons_col, 50), display = display.pane, linewidth = 5)
plot(lower, title = "Lower Band Glow", color = color.new(cons_col, 50), display = display.pane, linewidth = 5)

plotcandle(open, high, low, close, "Bar Color", cons_col, cons_col, bordercolor = cons_col, force_overlay = true, display = display.pane)
````
