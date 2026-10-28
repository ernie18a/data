# OBV + WaveTrend Volume Scalper [GratefulFutures]

- url: https://www.tradingview.com/script/xtcI9g2p-OBV-WaveTrend-Volume-Scalper-GratefulFutures/
- type: indicator
- pine_id: PUB;29fed00f525e42dd95921ed39f0fd74b
- version: 1.0

## Description

This script is a combination script of three different strategies that provides buy and sell signals based on the change of volume with momentum confirmations. 

[image]https://www.tradingview.com/x/EpOH9DBu/[/image]

[b]Sources used:[/b]
This script relies on the outstanding scripts of the great script writer LazyBear:[url=https://www.tradingview.com/u/LazyBear/]LazyBear[/url]

The following scripts were used in this publication:
1. A modified "On-Balance Volume Oscillator" modified from LazyBear's original script:
https://www.tradingview.com/v/Ox9gyUFA/

2. Wavetrend Oscillator with crosses, Author: LazyBear 
https://www.tradingview.com/v/jFQn4jYZ/

3. Squeeze Momentum Oscillator, Author: LazyBear
https://www.tradingview.com/v/nqQ1DT5a/

This script functions based on the following criteria being true:
1. On balance volume oscillator turning from negative to positive (buy) or positive to negative (sell)
2. Squeeze Momentum value is increasing (buy) or decreasing (sell)
3. Wavetrend 1 (wt1) is greater than wavetrend 2 (wt2) (buy)/ Wavetrend 1 (wt1) is less than wavetrend 2 (wt2) (sell)

By combining these factors the indicator is able to signal exactly when net buying turns to net selling (OBV) and when this change is most advantageous to continue based on the momentum and price action of the underlying asset (SQMOMO and Wavetrend).

This allows you to pair volume and price action for a powerful tool to identify where price will reverse or continue providing exceptional entries for short term trades, especially when combined with other aspects such as support and resistance, or volume profile.

[b]How to use:[/b]
Simply adjust the settings to your preference and read the given signals as generated.

[b]Settings[/b]
There are multiple ways to tune the signals generated. It is set standard for my preferred use on a 1 minute chart.

[b][i]OBV Oscillator Settings[/i][/b]
The first 4 dropdowns in the [i]Inputs[/i] section tune the On Balance Volume Oscillator (OBVO) portion of the indicator. You can choose if you want it to calculate based on close, open, high, low, or other value.
The most impactful in the entire settings is going to be the length and smoothing of the OBVO EMA. Making this number lower increasing the sensitivity to changes in volume, making the signals come quicker but is more susceptible to quick fluctuations. A value of between (5-20) is reasonable for the OBVO EMA length. There is a separate smoothing factor titled [i]OBV Smoothing Length[/i] and below that, [i]OBV Smoothing Type[/i], a value of (2) is standard with "SMA" for smoothing type with a value of between 2-10 being reasonable. You may also play with these values to see what you like for your trading style. 

[i]Wavetrend Settings[/i]
The next 3 options are to modify the wavetrend portion of the indicator. I do not modify these from standard, and feel that they work appropriately on all time frames at the following values: [i]n1 length[/i] (10), [i]n2 length[/i] (20), [i]Wavetrend Signal SMA length[/i] (4)

[i]Squeeze Momentum Settings[/i]
The following 5 options through the end modify the Squeeze momentum portion of the indicator. The only one that modifies the signals generated is the [i]KC Length[/i], Making this number lower increasing the sensitivity to changes in price action, making the signals come quicker but is more susceptible to quick fluctuations. A value of between (18-25) is reasonable for [i]KC Length[/i].

[i]Style Setting[/i]
You may select if you want to see the buy and sell signals. The following 5 options [i]Raw OBV Osc [/i] through [i]Squeeze Momentum[/i] allow you to see where each specific requirement was met, posted as a vertical line, but for live use it is recommended to turn all of these vertical lines off and only use the buy and sell signals. 

[i]Time Frames:[/i]
While this script is most effective on shorter time frames (1 minute for scalping and daytrading) it is also viable to use it on longer timeframes, due to the nature of its components being independent of time frame. 

[b]Examples of use[/b] - (Green and red vertical lines are for visualization purpose and are not part of the script)

SPY 1 Minute (Factory Settings):
https://www.tradingview.com/x/7uvzsaXm/

SPX 15 minutes (Factory Settings):
https://www.tradingview.com/x/c6bZtcwb/

[b]Considerations[/b]
This script is meant primarily for short term trading, trades on the basis of seconds to minutes primarily. While they can be a good indication of volume lining up with momentum, it is always wise to use them in combination with other factors such as support, resistance, market structure, volume levels, or the many other techniques out there...

As Always... Happy Trading.
-Not_A_Mad_Scientist (GreatfulFutures Trade University)

## Source Code

````pine
//@version=5
indicator("OBV + WaveTrend Volume Scalper [GratefulFutures]", shorttitle="GF Volume Scalper", overlay=true)

// ------------------------------
// USER INPUTS - OBV OSCILLATOR
// ------------------------------
obv_src     = input.source(close, "OBV Source")
obv_ema_len = input.int(10, "OBV EMA Length", minval=1)
obv_smooth  = input.int(2, "OBV Smoothing Length", minval=1)
obv_smooth_type = input.string("SMA", "OBV Smoothing Type", options=["SMA","EMA","SMMA"]) 
show_raw_obv = input.bool(true, "Show Raw OBV Oscillator")

// ------------------------------
// USER INPUTS - WaveTrend (WT)
// ------------------------------
wt_n1 = input.int(10, "WT Channel Length (n1)")
wt_n2 = input.int(21, "WT Average Length (n2)")
wt_sma_len = input.int(4, "WT Signal SMA Length")

// ------------------------------
// USER INPUTS - Squeeze Momentum
// ------------------------------
sqz_bb_len = input.int(20, "BB Length")
sqz_bb_mult = input.float(2.0, "BB MultFactor")
sqz_kc_len = input.int(20, "KC Length")
sqz_kc_mult = input.float(1.5, "KC MultFactor")
sqz_use_tr = input.bool(true, "Use TrueRange for KC")

// ------------------------------
// OBV OSCILLATOR
// ------------------------------
obv_func(_src) =>
    delta = ta.change(_src)
    ta.cum(delta > 0 ? volume : delta < 0 ? -volume : 0)

_os = obv_func(obv_src)
obv_osc = _os - ta.ema(_os, obv_ema_len)

smooth_fn(srcSeries, len, method) =>
    switch method
        "EMA" => ta.ema(srcSeries, len)
        "SMMA" => ta.rma(srcSeries, len)
        => ta.sma(srcSeries, len)

smoothed_obv_osc = smooth_fn(obv_osc, obv_smooth, obv_smooth_type)

obvBull = smoothed_obv_osc[1] < 0 and smoothed_obv_osc > 0
obvBear = smoothed_obv_osc[1] > 0 and smoothed_obv_osc < 0

// ------------------------------
// SQUEEZE MOMENTUM
// ------------------------------
src = close
basis = ta.sma(src, sqz_bb_len)
dev = sqz_bb_mult * ta.stdev(src, sqz_bb_len)
upperBB = basis + dev
lowerBB = basis - dev

ma = ta.sma(src, sqz_kc_len)
rng = sqz_use_tr ? ta.tr : (high - low)
rangema = ta.sma(rng, sqz_kc_len)
upperKC = ma + rangema * sqz_kc_mult
lowerKC = ma - rangema * sqz_kc_mult

sqzOn  = (lowerBB > lowerKC) and (upperBB < upperKC)
sqzOff = (lowerBB < lowerKC) and (upperBB > upperKC)
noSqz  = not sqzOn and not sqzOff

hh = ta.highest(high, sqz_kc_len)
ll = ta.lowest(low, sqz_kc_len)
avg1 = (hh + ll) / 2
avg2 = (avg1 + ta.sma(close, sqz_kc_len)) / 2

val = ta.linreg(src - avg2, sqz_kc_len, 0)

sqzBull = val > val[1]
sqzBear = val < val[1]

// ------------------------------
// WAVETREND
// ------------------------------
ap = hlc3
esa = ta.ema(ap, wt_n1)
d = ta.ema(math.abs(ap - esa), wt_n1)
ci = (ap - esa) / (0.015 * d)
tci = ta.ema(ci, wt_n2)
wt1 = tci
wt2 = ta.sma(wt1, wt_sma_len)

wtBull = wt1 > wt2
wtBear = wt1 < wt2

// ------------------------------
// SIGNAL CONDITIONS
// ------------------------------
buySignal = obvBull and sqzBull and wtBull
sellSignal = obvBear and sqzBear and wtBear

// ------------------------------
// SIGNAL PLOTS ONLY (no strategy, no backtesting)
// ------------------------------
plotshape(buySignal, title="Buy Signal", location=location.belowbar, color=color.green, style=shape.labelup, text="BUY")
plotshape(sellSignal, title="Sell Signal", location=location.abovebar, color=color.red, style=shape.labeldown, text="SELL")

// OPTIONAL diagnostic plots (non-trading)
plot(show_raw_obv ? obv_osc : na, title="Raw OBV Osc")
plot(smoothed_obv_osc, title="Smoothed OBV Osc")
plot(wt1, title="WT1")
plot(wt2, title="WT2")
plot(val, title="Squeeze Momentum", style=plot.style_columns)
````
