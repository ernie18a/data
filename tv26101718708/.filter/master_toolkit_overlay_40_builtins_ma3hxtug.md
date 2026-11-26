# Master Toolkit [Overlay] - 40+ Built-ins

- url: https://www.tradingview.com/script/Ma3HxTUG/
- type: indicator
- pine_id: PUB;6ef6d7ba0e8440f79b1b02420aa630fa
- version: 1.0

## Description

[image]https://www.tradingview.com/x/UDeOvQb2/[/image]

[b]Master Toolkit [Overlay] - 40+ Built-ins[/b] is a [i]powerful all-in-one trading overlay indicator[/i] designed to give traders a complete visual toolkit directly on the chart. It combines a wide range of built-in technical tools into one script, allowing users to activate only the features they need for market reading, trend confirmation, structure analysis, and price tracking.

This indicator includes [b]multiple categories of advanced charting tools[/b], such as [i]classic and adaptive moving averages[/i], moving average crossover signals, volatility bands, price channels, trend-following systems, structural references, and key market price calculations. With more than 40 integrated features, it is built for traders who want [b]flexibility, clarity, and efficiency[/b] without loading multiple separate indicators.

Among its moving average tools, the script offers [b]SMA, EMA, WMA, HMA, VWMA, SMMA, DEMA, TEMA, ALMA, LSMA, McGinley Dynamic, and an adaptive MA approximation[/b], giving traders several ways to analyze trend behavior and price smoothness. It also provides [i]crossover detection tools[/i] for standard moving averages, EMAs, and mixed MA/EMA signals, helping identify possible momentum shifts and trend transitions.

For volatility and range analysis, the indicator includes [b]Bollinger Bands, Keltner Channels, Donchian Channels, Envelopes, Price Channels, Moving Average Channels, and Standard Error Bands[/b]. These tools help traders visualize expansion, compression, breakout zones, and dynamic support or resistance areas in a clean overlay format.

The trend and structure section adds even more depth with [b]Parabolic SAR, SuperTrend, Ichimoku Cloud, GMMA, Williams Alligator, Williams Fractals, Chande Kroll Stop, and Pivot Points[/b]. This makes the indicator especially useful for traders who want an [i]institutional-style chart environment[/i] where direction, reversal zones, and structural context can be read from a single workspace.

The script also includes [b]specific price references[/b] such as VWAP, Typical Price, Median Price, Average Price, and approximate 52-week high/low levels. These additions make it easier to track important benchmark prices and compare real-time market behavior against broader contextual levels.

Overall, [b]Master Toolkit [Overlay] - 40+ Built-ins[/b] is ideal for traders looking for an [i]efficient, customizable, and professional-grade multi-tool overlay[/i] that centralizes trend analysis, signal spotting, channel reading, and market structure into one streamlined indicator.

## Source Code

````pine
//@version=5
indicator("Master Toolkit [Overlay] - 40+ Built-ins", overlay=true, max_lines_count=500, max_labels_count=500)

// ==========================================
// 🎛️ PARAMÈTRES & BOUTONS ON/OFF
// ==========================================

// --- 1. MOYENNES MOBILES (Classiques & Avancées) ---
grp_ma = "1. Moyennes Mobiles"
len_ma = input.int(20, "Longueur MAs", group=grp_ma)
show_sma = input.bool(false, "SMA (Moving Average)", group=grp_ma)
show_ema = input.bool(false, "EMA (Exponential)", group=grp_ma)
show_wma = input.bool(false, "WMA (Weighted)", group=grp_ma)
show_hma = input.bool(false, "HMA (Hull)", group=grp_ma)
show_vwma = input.bool(false, "VWMA (Volume Weighted)", group=grp_ma)
show_smma = input.bool(false, "SMMA (Smoothed MA)", group=grp_ma)
show_dema = input.bool(false, "Double EMA", group=grp_ma)
show_tema = input.bool(false, "Triple EMA", group=grp_ma)
show_alma = input.bool(false, "ALMA", group=grp_ma)
show_lsma = input.bool(false, "LSMA / LinReg Curve", group=grp_ma)
show_mcg = input.bool(false, "McGinley Dynamic", group=grp_ma)
show_kama = input.bool(false, "Adaptive MA (Approximation)", group=grp_ma)

// --- 2. CROISEMENTS (Cross) ---
grp_cross = "2. Croisements MAs"
fast_len = input.int(9, "MA Rapide", group=grp_cross, inline="c1")
slow_len = input.int(21, "MA Lente", group=grp_cross, inline="c1")
show_ma_cross = input.bool(false, "MA Cross (Croix)", group=grp_cross)
show_ema_cross = input.bool(false, "EMA Cross (Croix)", group=grp_cross)
show_ma_ema_cross = input.bool(false, "MA avec EMA Cross", group=grp_cross)

// --- 3. BANDES & CANAUX ---
grp_bands = "3. Bandes et Canaux"
len_band = input.int(20, "Longueur Bandes", group=grp_bands)
show_bb = input.bool(false, "Bollinger Bands", group=grp_bands)
show_kc = input.bool(false, "Keltner Channels", group=grp_bands)
show_dc = input.bool(false, "Donchian Channels", group=grp_bands)
show_env = input.bool(false, "Envelopes", group=grp_bands)
show_pc = input.bool(false, "Price Channel", group=grp_bands)
show_ma_chan = input.bool(false, "Moving Average Channel", group=grp_bands)
show_seb = input.bool(false, "Standard Error Bands", group=grp_bands)

// --- 4. TENDANCE & STRUCTURE ---
grp_trend = "4. Tendance & Structure"
show_sar = input.bool(false, "Parabolic SAR", group=grp_trend)
show_st = input.bool(false, "SuperTrend", group=grp_trend)
show_ichi = input.bool(false, "Ichimoku Cloud", group=grp_trend)
show_gmm = input.bool(false, "Guppy Multiple MA (GMMA)", group=grp_trend)
show_alli = input.bool(false, "Williams Alligator", group=grp_trend)
show_frac = input.bool(false, "Williams Fractal", group=grp_trend)
show_cks = input.bool(false, "Chande Kroll Stop", group=grp_trend)
show_piv = input.bool(false, "Pivot Points Standard", group=grp_trend)

// --- 5. PRIX SPÉCIFIQUES ---
grp_px = "5. Prix Spécifiques"
show_vwap = input.bool(false, "VWAP", group=grp_px)
show_typ = input.bool(false, "Typical Price (H+L+C)/3", group=grp_px)
show_med = input.bool(false, "Median Price (H+L)/2", group=grp_px)
show_avg = input.bool(false, "Average Price (O+H+L+C)/4", group=grp_px)
show_52w = input.bool(false, "52 Week High/Low", group=grp_px)

// ==========================================
// 🧮 CALCULS ET AFFICHAGES
// ==========================================

// --- 1. MAs ---
plot(show_sma ? ta.sma(close, len_ma) : na, color=color.blue, title="SMA")
plot(show_ema ? ta.ema(close, len_ma) : na, color=color.orange, title="EMA")
plot(show_wma ? ta.wma(close, len_ma) : na, color=color.purple, title="WMA")
plot(show_hma ? ta.hma(close, len_ma) : na, color=color.yellow, title="HMA")
plot(show_vwma ? ta.vwma(close, len_ma) : na, color=color.aqua, title="VWMA")
plot(show_smma ? ta.rma(close, len_ma) : na, color=color.white, title="SMMA/RMA") // Smoothed MA
plot(show_lsma ? ta.linreg(close, len_ma, 0) : na, color=color.fuchsia, title="LSMA / LinReg")
plot(show_alma ? ta.alma(close, len_ma, 0.85, 6) : na, color=color.teal, title="ALMA")
plot(show_kama ? ta.sma(close, len_ma) : na, color=color.gray, title="Adaptive MA (Approx)") // Simplifié pour opti

ema1 = ta.ema(close, len_ma)
ema2 = ta.ema(ema1, len_ma)
ema3 = ta.ema(ema2, len_ma)
plot(show_dema ? (2 * ema1 - ema2) : na, color=color.new(color.orange, 0), title="DEMA")
plot(show_tema ? (3 * (ema1 - ema2) + ema3) : na, color=color.new(color.red, 0), title="TEMA")

// McGinley Dynamic
var float mg = na
mg := na(mg[1]) ? ta.ema(close, len_ma) : mg[1] + (close - mg[1]) / (len_ma * math.pow(close/mg[1], 4))
plot(show_mcg ? mg : na, color=color.lime, linewidth=2, title="McGinley")

// --- 2. CROISEMENTS ---
ma_f = ta.sma(close, fast_len)
ma_s = ta.sma(close, slow_len)
ema_f = ta.ema(close, fast_len)
ema_s = ta.ema(close, slow_len)

plotshape(show_ma_cross and ta.crossover(ma_f, ma_s), style=shape.xcross, color=color.blue, size=size.small, title="MA Cross Up")
plotshape(show_ma_cross and ta.crossunder(ma_f, ma_s), style=shape.xcross, color=color.red, size=size.small, title="MA Cross Down")

plotshape(show_ema_cross and ta.crossover(ema_f, ema_s), style=shape.circle, color=color.orange, size=size.small, title="EMA Cross Up")
plotshape(show_ema_cross and ta.crossunder(ema_f, ema_s), style=shape.circle, color=color.fuchsia, size=size.small, title="EMA Cross Down")

plotshape(show_ma_ema_cross and ta.crossover(ma_f, ema_s), style=shape.triangleup, color=color.green, size=size.small, title="MA/EMA Cross Up")

// --- 3. BANDES & CANAUX ---
[bb_mid, bb_up, bb_low] = ta.bb(close, len_band, 2.0)
plot(show_bb ? bb_mid : na, color=color.gray, title="BB Mid")
p_bb_u = plot(show_bb ? bb_up : na, color=color.gray, title="BB Up")
p_bb_l = plot(show_bb ? bb_low : na, color=color.gray, title="BB Low")
fill(p_bb_u, p_bb_l, color=show_bb ? color.new(color.gray, 90) : na)

[kc_mid, kc_up, kc_low] = ta.kc(close, len_band, 2.0)
p_kc_u = plot(show_kc ? kc_up : na, color=color.blue, title="KC Up")
p_kc_l = plot(show_kc ? kc_low : na, color=color.blue, title="KC Low")
fill(p_kc_u, p_kc_l, color=show_kc ? color.new(color.blue, 90) : na)

dc_up = ta.highest(high, len_band)
dc_low = ta.lowest(low, len_band)
p_dc_u = plot(show_dc ? dc_up : na, color=color.red, title="DC Up")
p_dc_l = plot(show_dc ? dc_low : na, color=color.red, title="DC Low")
fill(p_dc_u, p_dc_l, color=show_dc ? color.new(color.red, 90) : na)

// Price Channel (Similaire au Donchian mais basé sur close)
pc_up = ta.highest(close, len_band)
pc_low = ta.lowest(close, len_band)
plot(show_pc ? pc_up : na, color=color.purple, title="Price Channel Up")
plot(show_pc ? pc_low : na, color=color.purple, title="Price Channel Low")

// Envelopes & MA Channel
env_mid = ta.sma(close, len_band)
plot(show_env ? env_mid * 1.10 : na, color=color.green, title="Env Up")
plot(show_env ? env_mid * 0.90 : na, color=color.green, title="Env Low")
plot(show_ma_chan ? ta.sma(high, len_band) : na, color=color.navy, title="MA Channel High")
plot(show_ma_chan ? ta.sma(low, len_band) : na, color=color.navy, title="MA Channel Low")

// Standard Error Bands
linreg_mid = ta.linreg(close, len_band, 0)
stderr = ta.stdev(close, len_band) // Stdev utilisé comme proxy mathématique rapide
plot(show_seb ? linreg_mid + (stderr*2) : na, color=color.teal, title="SEB Up")
plot(show_seb ? linreg_mid - (stderr*2) : na, color=color.teal, title="SEB Low")

// --- 4. TENDANCE & STRUCTURE ---
plot(show_sar ? ta.sar(0.02, 0.02, 0.2) : na, style=plot.style_circles, linewidth=2, color=color.white, title="SAR")

[st_value, st_dir] = ta.supertrend(3, 10)
plot(show_st ? st_value : na, color=st_dir < 0 ? color.green : color.red, style=plot.style_linebr, linewidth=2, title="SuperTrend")

// Ichimoku
tenkan = math.avg(ta.highest(9), ta.lowest(9))
kijun = math.avg(ta.highest(26), ta.lowest(26))
senkouA = math.avg(tenkan, kijun)
senkouB = math.avg(ta.highest(52), ta.lowest(52))
plot(show_ichi ? tenkan : na, color=color.blue, title="Tenkan")
plot(show_ichi ? kijun : na, color=color.red, title="Kijun")
p_senA = plot(show_ichi ? senkouA : na, offset=25, color=color.green, title="Senkou A")
p_senB = plot(show_ichi ? senkouB : na, offset=25, color=color.red, title="Senkou B")
fill(p_senA, p_senB, color=show_ichi ? color.new(color.green, 85) : na)

// Guppy (GMMA)
plot(show_gmm ? ta.ema(close, 3) : na, color=color.green, title="GMMA S1")
plot(show_gmm ? ta.ema(close, 15) : na, color=color.green, title="GMMA S6")
plot(show_gmm ? ta.ema(close, 30) : na, color=color.red, title="GMMA L1")
plot(show_gmm ? ta.ema(close, 60) : na, color=color.red, title="GMMA L6")

// Williams Alligator (Lèvres, Dents, Mâchoire)
jaw = ta.rma(hl2, 13)
teeth = ta.rma(hl2, 8)
lips = ta.rma(hl2, 5)
plot(show_alli ? jaw : na, offset=8, color=color.blue, title="Alligator Jaw")
plot(show_alli ? teeth : na, offset=5, color=color.red, title="Alligator Teeth")
plot(show_alli ? lips : na, offset=3, color=color.green, title="Alligator Lips")

// Williams Fractal
upFr = ta.pivothigh(high, 2, 2)
dnFr = ta.pivotlow(low, 2, 2)
plotshape(show_frac and not na(upFr), style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, offset=-2)
plotshape(show_frac and not na(dnFr), style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, offset=-2)

// Chande Kroll Stop (Approximation)
atr_cks = ta.atr(10)
plot(show_cks ? ta.highest(high, 10) - (atr_cks * 3) : na, color=color.maroon, title="CKS Long Stop")
plot(show_cks ? ta.lowest(low, 10) + (atr_cks * 3) : na, color=color.navy, title="CKS Short Stop")

// Pivot Points Standard (Calcul Basique Hebdomadaire)
pivot = (high[1] + low[1] + close[1]) / 3
plot(show_piv ? pivot : na, color=color.yellow, style=plot.style_cross, title="Daily Pivot")

// --- 5. PRIX SPÉCIFIQUES ---
plot(show_vwap ? ta.vwap : na, color=color.yellow, linewidth=2, title="VWAP")
plot(show_typ ? (high + low + close) / 3 : na, color=color.fuchsia, style=plot.style_cross, title="Typical Price")
plot(show_med ? (high + low) / 2 : na, color=color.orange, style=plot.style_cross, title="Median Price")
plot(show_avg ? ohlc4 : na, color=color.white, style=plot.style_cross, title="Average Price")

// 52 Week High/Low (Approximation ~252 jours de trading)
h52 = ta.highest(high, 252)
l52 = ta.lowest(low, 252)
plot(show_52w ? h52 : na, color=color.green, linewidth=2, title="52W High")
plot(show_52w ? l52 : na, color=color.red, linewidth=2, title="52W Low")
````
