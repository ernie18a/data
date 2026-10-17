# 2K Range Filter

- url: https://www.tradingview.com/script/hRLC94sf-2K-Range-Filter/
- type: indicator
- pine_id: PUB;b6e73e61be144f1cb56e939289ec125a
- version: 1.0

## Description

[b]How it works[/b]

The indicator builds a filtered price line based on a configurable range size. This range can be derived from multiple volatility measures, including:

Average True Range (ATR)
Average price change
Standard deviation
Percentage of price
Fixed points, ticks, or pips

Only when price moves beyond this defined range does the filter update, effectively filtering out sideways noise and minor fluctuations.

[b]Signal logic[/b]

The core signal is based on the direction of the filtered line:

Upward slope → Bullish trend
Downward slope → Bearish trend
Flat → No change (previous state maintained)

[b]The line is color-coded for clarity:[/b]

Green: Uptrend
Red/Pink: Downtrend
Gray: Neutral / unchanged
Key features
Adaptive range filtering based on volatility
Optional smoothing for more stable signals
Two filter types for different sensitivity profiles
Ability to average filter changes for additional noise reduction
Works with either candle wicks or closing prices
Use cases

[b]This indicator is best used as a trend filter or directional bias tool, for example:[/b]

Trade in the direction of the filter (long in uptrends, short in downtrends)
Combine with entry signals from other indicators
Identify trend reversals when the filter changes direction

[b]Summary[/b]

The 2K Range Filter helps traders focus on significant market moves by eliminating noise and emphasizing true directional shifts. It is particularly useful in volatile or choppy markets where traditional indicators may generate false signals.

## Source Code

````pine
//@version=5
indicator(title="2K Range Filter", shorttitle="2K", overlay=true)

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------
// Functions
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------

// Conditional Sampling EMA Function
Cond_EMA(x, cond, n) =>
    var val = array.new_float(0)
    var ema_val = array.new_float(1)
    if bool(cond)  // Sicherstellen, dass 'cond' ein Boolean ist
        array.push(val, x)
        if array.size(val) > 1
            array.remove(val, 0)
        if na(array.get(ema_val, 0))
            array.fill(ema_val, array.get(val, 0))
        array.set(ema_val, 0, (array.get(val, 0) - array.get(ema_val, 0)) * (2 / (n + 1)) + array.get(ema_val, 0))
    array.get(ema_val, 0)

// Conditional Sampling SMA Function
Cond_SMA(x, cond, n) =>
    var vals = array.new_float(0)
    if bool(cond)  // Sicherstellen, dass 'cond' ein Boolean ist
        array.push(vals, x)
        if array.size(vals) > n
            array.remove(vals, 0)
    array.avg(vals)

// Standard Deviation Function
Stdev(x, n) =>
    math.sqrt(Cond_SMA(math.pow(x, 2), true, n) - math.pow(Cond_SMA(x, true, n), 2))

// Range Size Calculation
rng_size(x, scale, qty, n) =>
    ATR = Cond_EMA(ta.tr(true), true, n)
    AC = Cond_EMA(math.abs(x - x[1]), true, n)
    SD = Stdev(x, n)
    scale == "Pips" ? qty * 0.0001 : scale == "Points" ? qty * syminfo.pointvalue : scale == "% of Price" ? close * qty / 100 : scale == "ATR" ? qty * ATR : scale == "Average Change" ? qty * AC : scale == "Standard Deviation" ? qty * SD : scale == "Ticks" ? qty * syminfo.mintick : qty

// Range Filter Logic
rng_filt(h, l, rng_, n, type, smooth, sn, av_rf, av_n) =>
    rng_smooth = Cond_EMA(rng_, true, sn)
    r = smooth ? rng_smooth : rng_
    var rfilt = array.new_float(2, (h + l) / 2)
    array.set(rfilt, 1, array.get(rfilt, 0))
    if bool(type == "Type 1")  // Sicherstellen, dass der Vergleich ein Boolean ist
        if h - r > array.get(rfilt, 1)
            array.set(rfilt, 0, h - r)
        if l + r < array.get(rfilt, 1)
            array.set(rfilt, 0, l + r)
    if bool(type == "Type 2")  // Sicherstellen, dass der Vergleich ein Boolean ist
        if h >= array.get(rfilt, 1) + r
            array.set(rfilt, 0, array.get(rfilt, 1) + math.floor(math.abs(h - array.get(rfilt, 1)) / r) * r)
        if l <= array.get(rfilt, 1) - r
            array.set(rfilt, 0, array.get(rfilt, 1) - math.floor(math.abs(l - array.get(rfilt, 1)) / r) * r)
    rng_filt1 = array.get(rfilt, 0)
    hi_band1 = rng_filt1 + r
    lo_band1 = rng_filt1 - r
    rng_filt2 = Cond_EMA(rng_filt1, rng_filt1 != rng_filt1[1], av_n)
    hi_band2 = Cond_EMA(hi_band1, rng_filt1 != rng_filt1[1], av_n)
    lo_band2 = Cond_EMA(lo_band1, rng_filt1 != rng_filt1[1], av_n)
    result_rf = av_rf ? rng_filt2 : rng_filt1
    result_hi = av_rf ? hi_band2 : hi_band1
    result_lo = av_rf ? lo_band2 : lo_band1
    [result_rf, result_hi, result_lo]

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------
// Inputs
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------

f_type = input.string(defval="Type 1", options=["Type 1", "Type 2"], title="Filter Type")
mov_src = input.string(defval="Close", options=["Wicks", "Close"], title="Movement Source")
rng_qty = input.float(defval=2.618, minval=0.0000001, title="Range Size")
rng_scale = input.string(defval="Average Change", options=["Points", "Pips", "Ticks", "% of Price", "ATR", "Average Change", "Standard Deviation", "Absolute"], title="Range Scale")
rng_per = input.int(defval=14, minval=1, title="Range Period (for ATR, Average Change, and Standard Deviation)")
smooth_range = input.bool(defval=true, title="Smooth Range")
smooth_per = input.int(defval=27, minval=1, title="Smoothing Period")
av_vals = input.bool(defval=false, title="Average Filter Changes")
av_samples = input.int(defval=2, minval=1, title="Number Of Changes To Average")

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------
// Calculations
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------

h_val = mov_src == "Wicks" ? high : close
l_val = mov_src == "Wicks" ? low : close
[filt, h_band, l_band] = rng_filt(h_val, l_val, rng_size((h_val + l_val) / 2, rng_scale, rng_qty, rng_per), rng_per, f_type, smooth_range, smooth_per, av_vals, av_samples)

var fdir = 0.0
fdir := filt > filt[1] ? 1 : filt < filt[1] ? -1 : fdir
upward = fdir == 1
downward = fdir == -1

// Farben für die Linie basierend auf der Richtung
line_color = upward ? color.new(#05ff9b, 0) : downward ? color.new(#ff0583, 0) : color.new(#cccccc, 0)

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------
// Outputs
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------

plot(filt, "Filtered Line", color=line_color, linewidth=2)
````
