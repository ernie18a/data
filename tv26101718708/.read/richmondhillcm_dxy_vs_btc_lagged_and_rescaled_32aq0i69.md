# RichmondHillCM - DXY vs BTC Lagged and Rescaled

- url: https://www.tradingview.com/script/32aq0I69-RichmondHillCM-DXY-vs-BTC-Lagged-and-Rescaled/
- type: indicator
- pine_id: PUB;0c2444be7dda49a58694a8f699674d09
- version: 2.0

## Description

[b]DXY vs BTC — Lagged & Rescaled[/b]

This indicator compares Bitcoin against a time-shifted, inverted US Dollar Index (DXY) to visualize the inverse relationship between dollar strength and risk assets — with the dollar shifted forward so its past moves line up against where Bitcoin tends to follow.

[b]How it works[/b]
- Both DXY and BTC are normalized to a 0–100 range over a rolling window, putting two very differently-scaled instruments on the same axis so they can be read side by side.
- DXY is lagged forward by an adjustable number of bars (default 18 ≈ 4.5 months on the weekly), reflecting the idea that dollar moves tend to lead Bitcoin rather than move with it.
- DXY is inverted by default, so the two lines track together whenever the historical inverse correlation is holding.
- The shaded fill marks divergence: green when BTC is running above the projected dollar path, red when it's below.
- A rolling correlation line is rescaled onto the same 0–100 axis: 50 = no correlation, below 50 = inverse (the normal regime for these two), above 50 = positive. It tells you how much to trust the overlay at any given moment.

[b]Inputs[/b]
- DXY Lag — bars to shift the dollar forward
- Normalization Window — lookback used for the 0–100 rescaling
- Correlation Lookback — window for the rolling correlation
- Invert DXY — toggle the inverse view on/off
- Show Divergence Fill / Show Rolling Correlation — visibility toggles
- Configurable DXY and BTC symbols

[b]Reading it[/b]
When the inverted, lagged DXY line and BTC line track closely and the correlation line sits well below 50, the dollar overlay is acting as a rough roadmap for price. When the correlation line drifts toward or above 50, the relationship has weakened and the overlay should be discounted. Large green/red divergences flag where BTC is leading or lagging the dollar's implied path.

[b]Notes[/b]
The lag is a heuristic, not a fixed law — the optimal shift drifts across market regimes, so experiment with the lag and lookback values. This is a research and visualization tool, not a trading signal, and nothing here is financial advice.

## Source Code

````pine
//@version=6
indicator("RichmondHillCM - DXY vs BTC — Lagged and Rescaled", overlay=false, max_bars_back=1000)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
auto_lag   = input.bool(true, "Auto-optimize Lag", group="Lag")
lag_bars   = input.int(18, "Manual DXY Lag (bars)", minval=1, maxval=200, group="Lag", tooltip="Used only when Auto-optimize is OFF.")
min_lag    = input.int(4,  "Scan: Min Lag", minval=1, maxval=200, group="Lag")
max_lag    = input.int(30, "Scan: Max Lag", minval=2, maxval=200, group="Lag", tooltip="Indicator scans this range and picks the lag with the strongest inverse fit.")

dxy_sym    = input.symbol("TVC:DXY", "DXY Symbol", group="Data")
btc_sym    = input.symbol("BITSTAMP:BTCUSD", "BTC Symbol", group="Data")

show_corr  = input.bool(true, "Show Rolling Correlation", group="Display")
corr_len   = input.int(52, "Correlation Lookback (bars)", minval=10, maxval=200, group="Display")
show_fills = input.bool(true, "Show Divergence Fill", group="Display")
norm_len   = input.int(200, "Normalization Window (bars)", minval=50, maxval=500, group="Display")
invert_dxy = input.bool(true, "Invert DXY (show inverse correlation)", group="Display")
show_lbls  = input.bool(true, "Show Line + Signal Labels", group="Display")

// ─────────────────────────────────────────────
// DATA FETCH
// ─────────────────────────────────────────────
dxy_raw    = request.security(dxy_sym, timeframe.period, close)
btc_raw    = request.security(btc_sym, timeframe.period, close)

// ─────────────────────────────────────────────
// LAG OPTIMIZER — pick lag with the most-inverse correlation
// (raw DXY vs BTC; most negative = strongest inverse lead/lag)
// ─────────────────────────────────────────────
float best_corr = 2.0      // sentinel above max possible corr (+1)
int   bl        = na
for lag = min_lag to max_lag
    c = ta.correlation(dxy_raw[lag], btc_raw, corr_len)
    if not na(c) and c < best_corr
        best_corr := c
        bl        := lag
best_lag   = na(bl) ? lag_bars : bl
active_lag = auto_lag ? best_lag : lag_bars

dxy_lagged = dxy_raw[active_lag]

// ─────────────────────────────────────────────
// RESCALING — Normalize both to 0–100
// ─────────────────────────────────────────────
dxy_min  = ta.lowest(dxy_lagged, norm_len)
dxy_max  = ta.highest(dxy_lagged, norm_len)
btc_min  = ta.lowest(btc_raw, norm_len)
btc_max  = ta.highest(btc_raw, norm_len)

dxy_norm = (dxy_lagged - dxy_min) / (dxy_max - dxy_min) * 100
btc_norm = (btc_raw    - btc_min) / (btc_max - btc_min) * 100
dxy_plot = invert_dxy ? (100 - dxy_norm) : dxy_norm

// ─────────────────────────────────────────────
// FORWARD PROJECTION — current (un-lagged) DXY implies BTC ~active_lag bars AHEAD
// ─────────────────────────────────────────────
proj_norm = (dxy_raw - dxy_min) / (dxy_max - dxy_min) * 100
proj_plot = invert_dxy ? (100 - proj_norm) : proj_norm
gap       = proj_plot - btc_norm

// ─────────────────────────────────────────────
// CORRELATION + RELIABILITY
// ─────────────────────────────────────────────
corr_val    = ta.correlation(dxy_lagged, btc_raw, corr_len)            // raw (un-inverted) corr
plotted_corr = invert_dxy ? -corr_val : corr_val                       // corr of the lines as drawn
status   = plotted_corr >= 0.3 ? "RELIABLE (tracking)" : plotted_corr <= -0.3 ? "UNRELIABLE (regime flip)" : "WEAK (near zero)"
reliable = plotted_corr >= 0.3

lag_days = active_lag * 7
lag_mo   = math.round(lag_days / 30.44 * 10) / 10
bias     = gap > 0 ? "HIGHER ▲" : "LOWER ▼"

// ─────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────
p_btc = plot(btc_norm, "BTC (normalized)", color=color.new(color.orange, 0), linewidth=2)
p_dxy = plot(dxy_plot, "DXY lagged (inverted)", color=color.new(color.aqua, 0), linewidth=2)

fill(p_btc, p_dxy, color=show_fills ? (btc_norm > dxy_plot ? color.new(color.green, 85) : color.new(color.red, 85)) : na)

hline(50,  "Midline", color=color.new(color.gray, 60), linestyle=hline.style_dashed)
hline(100, "Top",     color=color.new(color.gray, 80), linestyle=hline.style_dotted)
hline(0,   "Bottom",  color=color.new(color.gray, 80), linestyle=hline.style_dotted)

corr_plot = corr_val * 50 + 50
plot(show_corr ? corr_plot : na, "Rolling Correlation", color=color.new(color.yellow, 20), linewidth=1)
hline(50, "Corr = 0", color=color.new(color.yellow, 70), linestyle=hline.style_dashed)

// ─────────────────────────────────────────────
// LINE LABELS + SIGNAL LABEL
// ─────────────────────────────────────────────
var label lblBTC  = na
var label lblDXY  = na
var label lblCorr = na
var label lblSig  = na

if show_lbls and barstate.islast
    label.delete(lblBTC)
    label.delete(lblDXY)
    label.delete(lblCorr)
    label.delete(lblSig)

    lblBTC  := label.new(bar_index + 1, btc_norm,  "BTC", style=label.style_none, textcolor=color.orange, size=size.small)
    lblDXY  := label.new(bar_index + 1, dxy_plot,  "DXY " + (invert_dxy ? "inv " : "") + "(lag " + str.tostring(active_lag) + ")", style=label.style_none, textcolor=color.aqua, size=size.small)
    if show_corr
        lblCorr := label.new(bar_index + 1, corr_plot, "Corr", style=label.style_none, textcolor=color.yellow, size=size.small)

    sigCol = not reliable ? color.gray : (gap > 0 ? color.green : color.red)
    sigTxt = "DXY → BTC projection (next ~" + str.tostring(active_lag) + " bars / " + str.tostring(lag_mo) + " mo)" + "\nBias:  BTC " + bias + "\nOverlay:  " + status
    lblSig := label.new(bar_index + 8, 50, sigTxt, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(sigCol, 75), textcolor=color.white, size=size.normal)

// ─────────────────────────────────────────────
// INFO TABLE
// ─────────────────────────────────────────────
var table t = table.new(position.top_right, 2, 11, bgcolor=color.new(color.black, 70), border_width=1, border_color=color.new(color.gray, 50))

if barstate.islast
    table.cell(t, 0, 0,  "Parameter",    text_color=color.gray,  text_size=size.small)
    table.cell(t, 1, 0,  "Value",        text_color=color.gray,  text_size=size.small)
    table.cell(t, 0, 1,  "Auto Lag",     text_color=color.white, text_size=size.small)
    table.cell(t, 1, 1,  auto_lag ? "ON" : "OFF", text_color=auto_lag ? color.green : color.gray, text_size=size.small)
    table.cell(t, 0, 2,  "Active Lag",   text_color=color.white, text_size=size.small)
    table.cell(t, 1, 2,  str.tostring(active_lag) + " bars / " + str.tostring(lag_mo) + " mo", text_color=color.aqua, text_size=size.small)
    table.cell(t, 0, 3,  "Optimal Lag",  text_color=color.white, text_size=size.small)
    table.cell(t, 1, 3,  str.tostring(best_lag) + " bars", text_color=color.aqua, text_size=size.small)
    table.cell(t, 0, 4,  "DXY Inverted", text_color=color.white, text_size=size.small)
    table.cell(t, 1, 4,  invert_dxy ? "YES" : "NO", text_color=invert_dxy ? color.green : color.red, text_size=size.small)
    table.cell(t, 0, 5,  "Corr Window",  text_color=color.white, text_size=size.small)
    table.cell(t, 1, 5,  str.tostring(corr_len) + " bars", text_color=color.yellow, text_size=size.small)
    table.cell(t, 0, 6,  "Rolling Corr", text_color=color.white, text_size=size.small)
    table.cell(t, 1, 6,  str.tostring(math.round(corr_val * 100) / 100), text_color=corr_val < 0 ? color.green : color.red, text_size=size.small)
    table.cell(t, 0, 7,  "Overlay",      text_color=color.white, text_size=size.small)
    table.cell(t, 1, 7,  status, text_color=reliable ? color.green : (plotted_corr <= -0.3 ? color.red : color.gray), text_size=size.small)
    table.cell(t, 0, 8,  "Projection",   text_color=color.white, text_size=size.small)
    table.cell(t, 1, 8,  "BTC " + bias, text_color=gap > 0 ? color.green : color.red, text_size=size.small)
    table.cell(t, 0, 9,  "Norm Window",  text_color=color.white, text_size=size.small)
    table.cell(t, 1, 9,  str.tostring(norm_len) + " bars", text_color=color.gray, text_size=size.small)
    table.cell(t, 0, 10, "Scan Range",   text_color=color.white, text_size=size.small)
    table.cell(t, 1, 10, str.tostring(min_lag) + "–" + str.tostring(max_lag), text_color=color.gray, text_size=size.small)
````
