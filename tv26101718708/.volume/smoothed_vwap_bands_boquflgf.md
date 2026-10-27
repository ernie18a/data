# Smoothed VWAP Bands

- url: https://www.tradingview.com/script/bOQUfLgf-Smoothed-VWAP-Bands/
- type: indicator
- pine_id: PUB;ba2f7c665411414cae3963fafbda5804
- version: 1.0

## Description

This indicator is a smoothed version of the VWAP (Volume Weighted Average Price) with dynamic standard deviation bands. Unlike the classic VWAP that resets at each session, it uses a 200-period volume-weighted SMA on a rolling window, giving it smoother price levels that adapt in real time to actual market flow.
It calculates three separate VWAPs — based on close, high and low — forming a central zone that represents the true market equilibrium over the calculation window. Around this zone, standard deviation bands (×2 multiplier by default) define extension areas where price is statistically outside its fair value.

## Source Code

````pine
//@version=6
indicator("Smoothed VWAP Bands", overlay=true)

// ─── SETTINGS ─────────────────────────────────────────────────────────────────
length      = input.int(200,  "Longueur (SMA)",     minval=1,   group="Paramètres")
band_mult   = input.float(2.0, "Multiplicateur bande", step=0.1, group="Paramètres")
show_bands  = input.bool(true, "Afficher bandes",               group="Paramètres")
show_hl     = input.bool(true, "Afficher zone High/Low",        group="Paramètres")
show_close  = input.bool(true, "Afficher ligne Close",          group="Paramètres")

col_close   = input.color(color.white,             "Ligne close",     group="Couleurs")
col_band    = input.color(color.new(#2962FF, 0),   "Lignes bandes",   group="Couleurs")
col_fill_hl = input.color(color.new(#2962FF, 80),  "Fill HL central", group="Couleurs")
col_fill_b  = input.color(color.new(#2962FF, 80),  "Fill bandes",     group="Couleurs")

// ─── CALCUL (fidèle au script Exocharts) ──────────────────────────────────────
vol = volume

vol_sma          = ta.sma(vol,            length)
src_vol_close    = ta.sma(close * vol,    length)
src_vol_high     = ta.sma(high  * vol,    length)
src_vol_low      = ta.sma(low   * vol,    length)

vwap_close = vol_sma != 0 ? src_vol_close / vol_sma : close
vwap_high  = vol_sma != 0 ? src_vol_high  / vol_sma : high
vwap_low   = vol_sma != 0 ? src_vol_low   / vol_sma : low

// Écart-type par source
src2_close = ta.sma(vol * math.pow(close, 2), length)
src2_high  = ta.sma(vol * math.pow(high,  2), length)
src2_low   = ta.sma(vol * math.pow(low,   2), length)

stdev_close = math.sqrt(math.max(src2_close / vol_sma - math.pow(vwap_close, 2), 0))
stdev_high  = math.sqrt(math.max(src2_high  / vol_sma - math.pow(vwap_high,  2), 0))
stdev_low   = math.sqrt(math.max(src2_low   / vol_sma - math.pow(vwap_low,   2), 0))

upper_close = vwap_close + stdev_close * band_mult
lower_close = vwap_close - stdev_close * band_mult
upper_high  = vwap_high  + stdev_high  * band_mult
upper_low   = vwap_low   + stdev_low   * band_mult
lower_high  = vwap_high  - stdev_high  * band_mult
lower_low   = vwap_low   - stdev_low   * band_mult

// ─── PLOTS ────────────────────────────────────────────────────────────────────
p_close = plot(show_close ? vwap_close : na, "VWAP Close", col_close, linewidth=2)
p_high  = plot(show_hl    ? vwap_high  : na, "VWAP High",  color.new(col_band, 60), linewidth=1)
p_low   = plot(show_hl    ? vwap_low   : na, "VWAP Low",   color.new(col_band, 60), linewidth=1)

p_uc = plot(show_bands ? upper_close : na, "Upper Close", col_band, linewidth=1)
p_lc = plot(show_bands ? lower_close : na, "Lower Close", col_band, linewidth=1)
p_uh = plot(show_bands and show_hl ? upper_high : na, "Upper High", color.new(col_band, 60), linewidth=1)
p_ul = plot(show_bands and show_hl ? upper_low  : na, "Upper Low",  color.new(col_band, 60), linewidth=1)
p_lh = plot(show_bands and show_hl ? lower_high : na, "Lower High", color.new(col_band, 60), linewidth=1)
p_ll = plot(show_bands and show_hl ? lower_low  : na, "Lower Low",  color.new(col_band, 60), linewidth=1)

// ─── FILLS ────────────────────────────────────────────────────────────────────
fill(p_high, p_low, col_fill_hl)

fill(p_uc, p_uh, col_fill_b)
fill(p_ul, p_lc, col_fill_b)
fill(p_lh, p_lc, col_fill_b)
fill(p_ll, p_lh, col_fill_b)
````
