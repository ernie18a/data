# Trend Indicator A + VWAP Band 3 Can

- url: https://www.tradingview.com/script/54oh3Y5Q-Trend-Indicator-A-VWAP-Band-3-Can/
- type: indicator
- pine_id: PUB;1af1e33b26344a3ba79bcc0f0e6861b3
- version: 12.0

## Description

New York Session VWAP with Dynamic Deviation Bands
Overview
This indicator is specifically designed for intraday traders looking to capitalize on the high volatility, volume, and momentum generated during the New York market session open. By combining the Volume Weighted Average Price (VWAP) with customizable deviation bands, this tool helps traders identify key institutional liquidity pools, dynamic support/resistance levels, and high-probability mean-reversion or breakout setups.

Key Features

Session-Optimized Logic: Tailored to track price action accurately around the New York opening bell (15:30 CET / 14:30 CET winter time), filtering out low-volume pre-market noise.

Dynamic Deviation Bands: Multi-layered bands act as volatility-adjusted overbought and oversold zones, adapting instantly to sudden market expansions.

Intraday Precision: Ideal for scalping and day trading highly liquid instruments such as market indices (NAS100, US30) and commodities (XAUUSD).

How to Use & Trade Setup

Mean Reversion (The Fade): Look for price exhaustion at the outer deviation bands during the initial New York open rush. A rejection candle at these extremes often signals a high-probability retracement back to the VWAP baseline.

Trend Following (The Breakout): If price breaks and closes decisively outside the first deviation band with strong volume during the first hour of the NY session, it often validates a strong institutional trend.

VWAP Cross: Use the central VWAP line as a dynamic bias filter. Trading above the VWAP indicates bullish sentiment, while trading below indicates bearish control.

Disclaimer: This indicator is for educational and analysis purposes only. Always combine technical indicators with strict risk management and a defined trading plan.

## Source Code

````pine
//@version=6
// ============================================================
// build: clean-4.6 + RSI Dashboard + Extra VWAP Bands + Sessie AVWAP Bands (1-3)
//
// FIX: Harde onderbreking van lijnen via plot.style_linebr en na-breaks
// ============================================================

indicator('Deviation Bands Reversal Indicator', 'Deviation Bands Reversal Indicator', overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

// --- 1. SETUP TREND INDICATOR A ---
ma_type     = input.string('EMA', 'MA Type', ['ALMA', 'HMA', 'SMA', 'SWMA', 'VWMA', 'WMA', 'ZLEMA', 'EMA'], group = 'Setup Trend Indicator')
ma_period   = input.int(6, 'MA Period (Length)', 1, group = 'Setup Trend Indicator')
alma_offset = input.float(0.85, 'ALMA Shift', 0, 1, 0.05, group = 'Setup (ALMA)')
alma_sigma  = input.int(6, 'ALMA Deviation', 1, step = 1, group = 'Setup (ALMA)')

// --- 2. SETUP VWAP BANDEN ---
vwap_src         = input.source(hlc3, 'VWAP Bron', group = 'Setup VWAP Banden')
show_band1       = input.bool(false, 'Toon VWAP Band 1', group = 'Setup VWAP Banden', inline = 'b1')
band_mult1       = input.float(1.0, 'StDev 1', group = 'Setup VWAP Banden', inline = 'b1')
show_band2       = input.bool(false, 'Toon VWAP Band 2', group = 'Setup VWAP Banden', inline = 'b2')
band_mult2       = input.float(2.0, 'StDev 2', group = 'Setup VWAP Banden', inline = 'b2')
show_band3       = input.bool(true, 'Toon VWAP Band 3 (Signaal Band)', group = 'Setup VWAP Banden', inline = 'b3')
band_mult        = input.float(3.0, 'StDev 3', group = 'Setup VWAP Banden', inline = 'b3')
show_band4       = input.bool(false, 'Toon VWAP Band 4', group = 'Setup VWAP Banden', inline = 'b4')
band_mult4       = input.float(4.0, 'StDev 4', group = 'Setup VWAP Banden', inline = 'b4')
band_mode        = input.string('Lont raakt band', 'Band-treffer modus', ['Lont raakt band', 'Kaars sluit voorbij band', 'Lont erdoor + close terug binnen'], group = 'Setup VWAP Banden')
lookback         = input.int(10, 'Max kaarsen geleden band geraakt', group = 'Setup VWAP Banden')
min_bars_session = input.int(3, 'Min. kaarsen na sessiestart voor geldige band-treffer', minval = 0, group = 'Setup VWAP Banden')
vwap_anchor      = input.string('Dag (origineel)', 'VWAP ankerpunt', ['Dag (origineel)', 'Sessie-open (AS / LN / NY)'], group = 'Setup VWAP Banden')

// --- 2b. SESSIE ANCHORED VWAPs ---
show_as_vwap   = input.bool(false, 'Toon Azië VWAP (AS)', group = 'Sessie Anchored VWAPs', inline = 'as_vwap')
as_vwap_col    = input.color(#E91E63, '', group = 'Sessie Anchored VWAPs', inline = 'as_vwap')
show_ln_vwap   = input.bool(false, 'Toon Londen VWAP (LN)', group = 'Sessie Anchored VWAPs', inline = 'ln_vwap')
ln_vwap_col    = input.color(#2962FF, '', group = 'Sessie Anchored VWAPs', inline = 'ln_vwap')
show_ny_vwap   = input.bool(false, 'Toon New York VWAP (NY)', group = 'Sessie Anchored VWAPs', inline = 'ny_vwap')
ny_vwap_col    = input.color(#FF9800, '', group = 'Sessie Anchored VWAPs', inline = 'ny_vwap')

show_sess_b1   = input.bool(false, 'Toon Sessie AVWAP Band 1 (StDev 1)', group = 'Sessie Anchored VWAPs')
show_sess_b2   = input.bool(false, 'Toon Sessie AVWAP Band 2 (StDev 2)', group = 'Sessie Anchored VWAPs')
show_sess_b3   = input.bool(false, 'Toon Sessie AVWAP Band 3 (StDev 3)', group = 'Sessie Anchored VWAPs')

// --- 2c. VWAP TRENDKLEUR ---
vwap_color_on   = input.bool(true, 'Kleur de VWAP mee met de trend', group = 'VWAP Trendkleur')
vwap_trend_mode = input.string('Prijs t.o.v. VWAP', 'Wat bepaalt de richting', ['Prijs t.o.v. VWAP', 'VWAP-helling', 'Helling + prijs'], group = 'VWAP Trendkleur')
vwap_price_buf  = input.float(0.25, 'Prijs moet ... ATR van de VWAP af staan', minval = 0.0, maxval = 5.0, step = 0.05, group = 'VWAP Trendkleur')
vwap_slope_len  = input.int(5, 'Helling meten over ... kaarsen', minval = 1, maxval = 60, group = 'VWAP Trendkleur')
vwap_dead_zone  = input.float(0.15, 'Dode zone helling (ATR over dat hele venster)', minval = 0.0, maxval = 5.0, step = 0.05, group = 'VWAP Trendkleur')
vwap_hold       = input.bool(true, 'Kleur vasthouden in de tussenzone', group = 'VWAP Trendkleur')
vwap_warmup     = input.int(3, 'Blauw blijven de eerste ... kaarsen na een reset', minval = 0, maxval = 30, group = 'VWAP Trendkleur')
col_up          = input.color(color.new(#26A69A, 0), 'Kleur uptrend', group = 'VWAP Trendkleur', inline = 'vc')
col_dn          = input.color(color.new(#EF5350, 0), 'downtrend', group = 'VWAP Trendkleur', inline = 'vc')
col_flat        = input.color(color.new(#42A5F5, 0), 'vlak', group = 'VWAP Trendkleur', inline = 'vc')
vwap_width      = input.int(2, 'Dikte VWAP-lijn', minval = 1, maxval = 6, group = 'VWAP Trendkleur')
vwap_glow       = input.bool(false, 'Extra gloed onder de VWAP', group = 'VWAP Trendkleur')

// --- 3. RSI & DIVERGENCE FILTER ---
use_rsi_filter  = input.bool(true, 'Eis RSI extreem (OB/OS) voor pijlen', group = 'RSI & Divergence Instellingen')
rsi_len          = input.int(14, 'RSI Lengte', minval = 1, group = 'RSI & Divergence Instellingen')
rsi_os          = input.int(25, 'Oversold grens (Buy zone)', minval = 1, maxval = 99, group = 'RSI & Divergence Instellingen', inline = 'lim')
rsi_ob          = input.int(75, 'Overbought grens (Sell zone)', minval = 1, maxval = 99, group = 'RSI & Divergence Instellingen', inline = 'lim')
rsi_lookback    = input.int(10, 'Max kaarsen geleden RSI extreem', minval = 0, group = 'RSI & Divergence Instellingen')

use_div_filter  = input.bool(false, 'Eis ook RSI Divergence voor pijlen', group = 'RSI & Divergence Instellingen')
show_div_lines  = input.bool(true, 'Teken Divergence lijnen op de grafiek', group = 'RSI & Divergence Instellingen')
div_requires_ob = input.bool(true, 'Divergence moet in de OB/OS zone plaatsvinden', group = 'RSI & Divergence Instellingen')
div_pivot_len   = input.int(5, 'Pivot Lengte voor Divergence', minval = 1, group = 'RSI & Divergence Instellingen')
div_lookback    = input.int(15, 'Max kaarsen geleden Divergence gespot', minval = 0, group = 'RSI & Divergence Instellingen')

// --- 3b. RSI DASHBOARD ---
show_rsi_dash = input.bool(true, 'Toon RSI Tabel op scherm', group = 'RSI Dashboard')
dash_pos      = input.string('Rechtsonder', 'Positie van Tabel', options = ['Rechtsonder', 'Rechtsboven', 'Linksonder', 'Linksboven'], group = 'RSI Dashboard')

// --- 4. SESSIES (New York tijd) ---
as_session       = input.session('1700-0300', 'AS - Azië', group = 'Sessies (New York tijd)')
ln_session       = input.session('0300-0930', 'LN - Londen', group = 'Sessies (New York tijd)')
ny_session       = input.session('0930-1700', 'NY - New York', group = 'Sessies (New York tijd)')

// --- 4b. SESSIE-RANGES ALS BOX ---
show_boxes    = input.bool(true, 'Teken sessie-ranges als box', group = 'Sessie-ranges')
show_box_lbl  = input.bool(true, 'Naam van de sessie erboven', group = 'Sessie-ranges')
keep_sessions = input.int(12, 'Hoeveel sessies bewaren', minval = 1, maxval = 400, group = 'Sessie-ranges')
box_transp    = input.int(92, 'Doorzichtigheid vulling', minval = 50, maxval = 100, group = 'Sessie-ranges')
as_box_col    = input.color(#E91E63, 'Azië', group = 'Sessie-ranges', inline = 'bc')
ln_box_col    = input.color(#2962FF, 'Londen', group = 'Sessie-ranges', inline = 'bc')
ny_box_col    = input.color(#FF9800, 'New York', group = 'Sessie-ranges', inline = 'bc')
as_box_txt    = input.string('Tokyo', 'Naam Azië', group = 'Sessie-ranges', inline = 'bt')
ln_box_txt    = input.string('London', 'Londen', group = 'Sessie-ranges', inline = 'bt')
ny_box_txt    = input.string('New York', 'New York', group = 'Sessie-ranges', inline = 'bt')

// --- 5. VISUELE INSTELLINGEN ---
pijlen_klein   = input.bool(true, 'Gebruik kleine signaalpijlen', group = 'Visuele Instellingen')
lijn_dikte     = input.int(4, 'Trendlijn Dikte (Vetdruk)', minval = 1, maxval = 6, group = 'Visuele Instellingen')
only_confirmed = input.bool(false, 'Toon pijl pas op gesloten kaars', group = 'Visuele Instellingen')

// --- 6. OPTIONELE EXTRA FILTERS ---
use_mtf_filter = input.bool(false, 'Eis 3-Minuten Trend Bevestiging', group = 'Optionele Extra Filters')
use_atr_filter = input.bool(false, 'Eis Minimale Volatiliteit (ATR)', group = 'Optionele Extra Filters')
min_atr_value  = input.float(0.00015, 'Minimale ATR Waarde', group = 'Optionele Extra Filters')

// ============================================================
// --- BEREKENINGEN & LOGICA ---
// ============================================================
ny_tz = 'America/New_York'
in_as = not na(time(timeframe.period, as_session, ny_tz))
in_ln = not na(time(timeframe.period, ln_session, ny_tz))
in_ny = not na(time(timeframe.period, ny_session, ny_tz))

as_start = in_as and not in_as[1]
ln_start = in_ln and not in_ln[1]
ny_start = in_ny and not in_ny[1]

day_open_bar = bool(ta.change(time('D', ny_tz)))
new_session = vwap_anchor == 'Sessie-open (AS / LN / NY)' ? (as_start or ln_start or ny_start) : day_open_bar

atr_1m = ta.atr(14)
atr_ok = not use_atr_filter or atr_1m >= min_atr_value

fv = na(volume) or volume == 0 ? 1.0 : volume

// Hoofd Daily VWAP
var float sum_src_vol = na, var float sum_vol = na, var float sum_src_src_vol = na
if new_session
    sum_src_vol := vwap_src * fv
    sum_vol := fv
    sum_src_src_vol := vwap_src * vwap_src * fv
else
    sum_src_vol := nz(sum_src_vol) + vwap_src * fv
    sum_vol := nz(sum_vol) + fv
    sum_src_src_vol := nz(sum_src_src_vol) + vwap_src * vwap_src * fv

my_vwap = sum_src_vol / sum_vol
variance = sum_src_src_vol / sum_vol - my_vwap * my_vwap
std_dev = math.sqrt(math.max(0, variance))

// --- SESSIE ANCHORED VWAPs ---
// Azië (AS)
var float sum_src_vol_as = na, var float sum_vol_as = na, var float sum_src_src_vol_as = na
if as_start
    sum_src_vol_as := vwap_src * fv
    sum_vol_as := fv
    sum_src_src_vol_as := vwap_src * vwap_src * fv
else if in_as
    sum_src_vol_as := nz(sum_src_vol_as) + vwap_src * fv
    sum_vol_as := nz(sum_vol_as) + fv
    sum_src_src_vol_as := nz(sum_src_src_vol_as) + vwap_src * vwap_src * fv
else
    sum_src_vol_as := na
    sum_vol_as := na
    sum_src_src_vol_as := na

vwap_as = in_as and not na(sum_vol_as) and sum_vol_as > 0 ? sum_src_vol_as / sum_vol_as : na
var_as  = in_as and not na(sum_vol_as) and sum_vol_as > 0 ? math.max(0, sum_src_src_vol_as / sum_vol_as - vwap_as * vwap_as) : 0.0
std_as  = in_as ? math.sqrt(var_as) : na

// Londen (LN)
var float sum_src_vol_ln = na, var float sum_vol_ln = na, var float sum_src_src_vol_ln = na
if ln_start
    sum_src_vol_ln := vwap_src * fv
    sum_vol_ln := fv
    sum_src_src_vol_ln := vwap_src * vwap_src * fv
else if in_ln
    sum_src_vol_ln := nz(sum_src_vol_ln) + vwap_src * fv
    sum_vol_ln := nz(sum_vol_ln) + fv
    sum_src_src_vol_ln := nz(sum_src_src_vol_ln) + vwap_src * vwap_src * fv
else
    sum_src_vol_ln := na
    sum_vol_ln := na
    sum_src_src_vol_ln := na

vwap_ln = in_ln and not na(sum_vol_ln) and sum_vol_ln > 0 ? sum_src_vol_ln / sum_vol_ln : na
var_ln  = in_ln and not na(sum_vol_ln) and sum_vol_ln > 0 ? math.max(0, sum_src_src_vol_ln / sum_vol_ln - vwap_ln * vwap_ln) : 0.0
std_ln  = in_ln ? math.sqrt(var_ln) : na

// New York (NY)
var float sum_src_vol_ny = na, var float sum_vol_ny = na, var float sum_src_src_vol_ny = na
if ny_start
    sum_src_vol_ny := vwap_src * fv
    sum_vol_ny := fv
    sum_src_src_vol_ny := vwap_src * vwap_src * fv
else if in_ny
    sum_src_vol_ny := nz(sum_src_vol_ny) + vwap_src * fv
    sum_vol_ny := nz(sum_vol_ny) + fv
    sum_src_src_vol_ny := nz(sum_src_src_vol_ny) + vwap_src * vwap_src * fv
else
    sum_src_vol_ny := na
    sum_vol_ny := na
    sum_src_src_vol_ny := na

vwap_ny = in_ny and not na(sum_vol_ny) and sum_vol_ny > 0 ? sum_src_vol_ny / sum_vol_ny : na
var_ny  = in_ny and not na(sum_vol_ny) and sum_vol_ny > 0 ? math.max(0, sum_src_src_vol_ny / sum_vol_ny - vwap_ny * vwap_ny) : 0.0
std_ny  = in_ny ? math.sqrt(var_ny) : na

// Hoofd VWAP Deviatiebanden
upper_band1 = my_vwap + band_mult1 * std_dev
lower_band1 = my_vwap - band_mult1 * std_dev
upper_band2 = my_vwap + band_mult2 * std_dev
lower_band2 = my_vwap - band_mult2 * std_dev
upper_band3 = my_vwap + band_mult * std_dev
lower_band3 = my_vwap - band_mult * std_dev
upper_band4 = my_vwap + band_mult4 * std_dev
lower_band4 = my_vwap - band_mult4 * std_dev

f(x) =>
    float ma = ta.ema(x, ma_period)
    if ma_type == 'ALMA'
        ma := ta.alma(x, ma_period, alma_offset, alma_sigma)
    else if ma_type == 'HMA'
        ma := ta.hma(x, ma_period)
    else if ma_type == 'SMA'
        ma := ta.sma(x, ma_period)
    else if ma_type == 'VWMA'
        ma := ta.vwma(x, ma_period)
    ma

var float ha_open = na
ha_close = (open + high + low + close) / 4
ha_open := na(ha_open[1]) ? (open + close) / 2 : (ha_open[1] + ha_close[1]) / 2
ha_high  = math.max(high, math.max(ha_open, ha_close))
ha_low   = math.min(low, math.min(ha_open, ha_close))

ma_ha_open  = f(ha_open)
ma_ha_close = f(ha_close)
trend_1m    = 100 * (ma_ha_close - ma_ha_open) / math.max(0.000001, f(ha_high) - f(ha_low))

ha_ticker      = ticker.heikinashi(syminfo.tickerid)
ha_open_3m     = request.security(ha_ticker, '3', open,  gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
ha_close_3m    = request.security(ha_ticker, '3', close, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
trend_3m       = 100 * (f(ha_close_3m) - f(ha_open_3m)) / math.max(0.000001, f(request.security(ha_ticker, '3', high)) - f(request.security(ha_ticker, '3', low)))

// --- Sessie boxen ---
var box[] sess_boxes = array.new_box()
var label[] sess_labels = array.new_label()
trimSessions() =>
    while array.size(sess_boxes) > keep_sessions
        box.delete(array.shift(sess_boxes))
    while array.size(sess_labels) > keep_sessions
        label.delete(array.shift(sess_labels))

sessionBox(bool started, bool inside, color col, string txt) =>
    var box b = na, var label l = na, var float hi = na, var float lo = na
    if show_boxes
        if started
            hi := high, lo := low
            b := box.new(bar_index, hi, bar_index, lo, border_color = col, border_style = line.style_dotted, bgcolor = color.new(col, box_transp))
            array.push(sess_boxes, b)
            if show_box_lbl
                l := label.new(bar_index, hi, txt, style = label.style_none, textcolor = col, size = size.small)
                array.push(sess_labels, l)
            trimSessions()
        else if inside and not na(b)
            hi := math.max(hi, high), lo := math.min(lo, low)
            box.set_right(b, bar_index), box.set_top(b, hi), box.set_bottom(b, lo)
            if not na(l)
                label.set_x(l, int(math.avg(box.get_left(b), bar_index)))
                label.set_y(l, hi + atr_1m)

sessionBox(as_start, in_as, as_box_col, as_box_txt)
sessionBox(ln_start, in_ln, ln_box_col, ln_box_txt)
sessionBox(ny_start, in_ny, ny_box_col, ny_box_txt)

// --- VWAP Kleuren ---
bars_since_reset = nz(ta.barssince(new_session), 999999)
vwap_warm = bars_since_reset >= math.max(vwap_warmup, vwap_slope_len)
vwap_slope = atr_1m > 0 ? (my_vwap - my_vwap[vwap_slope_len]) / atr_1m : 0.0
vwap_gap   = atr_1m > 0 ? (close - my_vwap) / atr_1m : 0.0
slope_up = vwap_warm and vwap_slope >  vwap_dead_zone
slope_dn = vwap_warm and vwap_slope < -vwap_dead_zone
price_up = vwap_warm and vwap_gap   >  vwap_price_buf
price_dn = vwap_warm and vwap_gap   < -vwap_price_buf

raw_up = vwap_trend_mode == 'Prijs t.o.v. VWAP' ? price_up : vwap_trend_mode == 'VWAP-helling' ? slope_up : slope_up and price_up
raw_dn = vwap_trend_mode == 'Prijs t.o.v. VWAP' ? price_dn : vwap_trend_mode == 'VWAP-helling' ? slope_dn : slope_dn and price_dn

var int vwap_state = 0
if not vwap_warm
    vwap_state := 0
else if raw_up
    vwap_state := 1
else if raw_dn
    vwap_state := -1
else if not vwap_hold
    vwap_state := 0

vwap_up = vwap_state == 1
vwap_dn = vwap_state == -1
vwap_col = not vwap_color_on ? color.orange : vwap_up ? col_up : vwap_dn ? col_dn : col_flat

// --- RSI & Divergence ---
rsi_v      = ta.rsi(close, rsi_len)
rsi_os_hit = rsi_v <= rsi_os
rsi_ob_hit = rsi_v >= rsi_ob
rsi_long_ok  = not use_rsi_filter or nz(ta.barssince(rsi_os_hit), 999999) <= rsi_lookback
rsi_short_ok = not use_rsi_filter or nz(ta.barssince(rsi_ob_hit), 999999) <= rsi_lookback

pl = ta.pivotlow(low, div_pivot_len, div_pivot_len)
ph = ta.pivothigh(high, div_pivot_len, div_pivot_len)

var float prev_pl_price = na, var float prev_pl_rsi = na, var int prev_pl_bar = na
var float pl_price = na,      var float pl_rsi = na,      var int pl_bar = na
var float prev_ph_price = na, var float prev_ph_rsi = na, var int prev_ph_bar = na
var float ph_price = na,      var float ph_rsi = na,      var int ph_bar = na

bull_div = false
bear_div = false

if not na(pl)
    prev_pl_price := pl_price, prev_pl_rsi := pl_rsi, prev_pl_bar := pl_bar
    pl_price := low[div_pivot_len], pl_rsi := rsi_v[div_pivot_len], pl_bar := bar_index[div_pivot_len]
    if not na(prev_pl_price) and pl_price < prev_pl_price and pl_rsi > prev_pl_rsi
        if not div_requires_ob or (pl_rsi <= rsi_os or prev_pl_rsi <= rsi_os)
            bull_div := true
            if show_div_lines
                line.new(prev_pl_bar, prev_pl_price, pl_bar, pl_price, color=color.new(color.green, 0), width=2, style=line.style_dashed)

if not na(ph)
    prev_ph_price := ph_price, prev_ph_rsi := ph_rsi, prev_ph_bar := ph_bar
    ph_price := high[div_pivot_len], ph_rsi := rsi_v[div_pivot_len], ph_bar := bar_index[div_pivot_len]
    if not na(prev_ph_price) and ph_price > prev_ph_price and ph_rsi < prev_ph_rsi
        if not div_requires_ob or (ph_rsi >= rsi_ob or prev_ph_rsi >= rsi_ob)
            bear_div := true
            if show_div_lines
                line.new(prev_ph_bar, prev_ph_price, ph_bar, ph_price, color=color.new(color.red, 0), width=2, style=line.style_dashed)

div_long_ok  = not use_div_filter or nz(ta.barssince(bull_div), 999999) <= div_lookback
div_short_ok = not use_div_filter or nz(ta.barssince(bear_div), 999999) <= div_lookback

// --- Signalen ---
band_touch_upper = band_mode == 'Lont raakt band' ? high >= upper_band3 : band_mode == 'Kaars sluit voorbij band' ? close >= upper_band3 : high >= upper_band3 and close < upper_band3
band_touch_lower = band_mode == 'Lont raakt band' ? low <= lower_band3 : band_mode == 'Kaars sluit voorbij band' ? close <= lower_band3 : low <= lower_band3 and close > lower_band3

bars_into_session = nz(ta.barssince(new_session), 999999)
band_ready = bars_into_session >= min_bars_session
effective_lookback = math.min(lookback, bars_into_session)
hit_upper_band = band_ready and nz(ta.barssince(band_touch_upper), 999999) <= effective_lookback
hit_lower_band = band_ready and nz(ta.barssince(band_touch_lower), 999999) <= effective_lookback

base_long = trend_1m > 0 and trend_1m[1] <= 0
base_short = trend_1m < 0 and trend_1m[1] >= 0
confirm_ok = not only_confirmed or barstate.isconfirmed

long_signal = base_long and hit_lower_band and rsi_long_ok and div_long_ok and (not use_mtf_filter or trend_3m > 0) and atr_ok and confirm_ok
short_signal = base_short and hit_upper_band and rsi_short_ok and div_short_ok and (not use_mtf_filter or trend_3m < 0) and atr_ok and confirm_ok

// --- Visueel (Pijlen) ---
plotshape(long_signal  and pijlen_klein     ? low  : na, title = 'Buy Pijl Klein',    style = shape.triangleup,   location = location.belowbar, color = color.green, size = size.small)
plotshape(long_signal  and not pijlen_klein ? low  : na, title = 'Buy Pijl Normaal',  style = shape.triangleup,   location = location.belowbar, color = color.green, size = size.normal)
plotshape(short_signal and pijlen_klein     ? high : na, title = 'Sell Pijl Klein',   style = shape.triangledown, location = location.abovebar, color = color.red,   size = size.small)
plotshape(short_signal and not pijlen_klein ? high : na, title = 'Sell Pijl Normaal', style = shape.triangledown, location = location.abovebar, color = color.red,   size = size.normal)

// --- PLOTS MET STRIKT LINEWITHBREAKS (GEEN VERBINDINGSLIJNEN MEER) ---
plot_vwap = new_session ? na : my_vwap

plot(vwap_glow ? plot_vwap : na, 'VWAP Gloed', color = color.new(vwap_col, 78), linewidth = vwap_width + 5, style = plot.style_linebr)
plot(plot_vwap, 'VWAP Middenlijn', color = vwap_col, linewidth = vwap_width, style = plot.style_linebr)

// Hoofd VWAP Bands
plot(show_band1 and not new_session ? upper_band1 : na, 'VWAP Bovenste Band 1', color = color.new(color.red, 50), style = plot.style_linebr)
plot(show_band1 and not new_session ? lower_band1 : na, 'VWAP Onderste Band 1', color = color.new(color.green, 50), style = plot.style_linebr)
plot(show_band2 and not new_session ? upper_band2 : na, 'VWAP Bovenste Band 2', color = color.new(color.red, 35), style = plot.style_linebr)
plot(show_band2 and not new_session ? lower_band2 : na, 'VWAP Onderste Band 2', color = color.new(color.green, 35), style = plot.style_linebr)
plot(show_band3 and not new_session ? upper_band3 : na, 'VWAP Bovenste Band 3 (Sell Zone)', color = color.red, style = plot.style_linebr)
plot(show_band3 and not new_session ? lower_band3 : na, 'VWAP Onderste Band 3 (Buy Zone)',  color = color.green, style = plot.style_linebr)
plot(show_band4 and not new_session ? upper_band4 : na, 'VWAP Bovenste Band 4', color = color.new(color.red, 20), style = plot.style_linebr)
plot(show_band4 and not new_session ? lower_band4 : na, 'VWAP Onderste Band 4', color = color.new(color.green, 20), style = plot.style_linebr)

// Azië Sessie AVWAP Plots
plot(show_as_vwap and in_as and not as_start ? vwap_as : na, 'Azië Session VWAP', color = as_vwap_col, linewidth = 2, style = plot.style_linebr)
plot(show_as_vwap and show_sess_b1 and in_as and not as_start ? vwap_as + band_mult1 * std_as : na, 'Azië Band 1 Upper', color = color.new(as_vwap_col, 40), style = plot.style_linebr)
plot(show_as_vwap and show_sess_b1 and in_as and not as_start ? vwap_as - band_mult1 * std_as : na, 'Azië Band 1 Lower', color = color.new(as_vwap_col, 40), style = plot.style_linebr)
plot(show_as_vwap and show_sess_b2 and in_as and not as_start ? vwap_as + band_mult2 * std_as : na, 'Azië Band 2 Upper', color = color.new(as_vwap_col, 50), style = plot.style_linebr)
plot(show_as_vwap and show_sess_b2 and in_as and not as_start ? vwap_as - band_mult2 * std_as : na, 'Azië Band 2 Lower', color = color.new(as_vwap_col, 50), style = plot.style_linebr)
plot(show_as_vwap and show_sess_b3 and in_as and not as_start ? vwap_as + band_mult  * std_as : na, 'Azië Band 3 Upper', color = color.new(as_vwap_col, 60), style = plot.style_linebr)
plot(show_as_vwap and show_sess_b3 and in_as and not as_start ? vwap_as - band_mult  * std_as : na, 'Azië Band 3 Lower', color = color.new(as_vwap_col, 60), style = plot.style_linebr)

// Londen Sessie AVWAP Plots
plot(show_ln_vwap and in_ln and not ln_start ? vwap_ln : na, 'Londen Session VWAP', color = ln_vwap_col, linewidth = 2, style = plot.style_linebr)
plot(show_ln_vwap and show_sess_b1 and in_ln and not ln_start ? vwap_ln + band_mult1 * std_ln : na, 'Londen Band 1 Upper', color = color.new(ln_vwap_col, 40), style = plot.style_linebr)
plot(show_ln_vwap and show_sess_b1 and in_ln and not ln_start ? vwap_ln - band_mult1 * std_ln : na, 'Londen Band 1 Lower', color = color.new(ln_vwap_col, 40), style = plot.style_linebr)
plot(show_ln_vwap and show_sess_b2 and in_ln and not ln_start ? vwap_ln + band_mult2 * std_ln : na, 'Londen Band 2 Upper', color = color.new(ln_vwap_col, 50), style = plot.style_linebr)
plot(show_ln_vwap and show_sess_b2 and in_ln and not ln_start ? vwap_ln - band_mult2 * std_ln : na, 'Londen Band 2 Lower', color = color.new(ln_vwap_col, 50), style = plot.style_linebr)
plot(show_ln_vwap and show_sess_b3 and in_ln and not ln_start ? vwap_ln + band_mult  * std_ln : na, 'Londen Band 3 Upper', color = color.new(ln_vwap_col, 60), style = plot.style_linebr)
plot(show_ln_vwap and show_sess_b3 and in_ln and not ln_start ? vwap_ln - band_mult  * std_ln : na, 'Londen Band 3 Lower', color = color.new(ln_vwap_col, 60), style = plot.style_linebr)

// New York Sessie AVWAP Plots
plot(show_ny_vwap and in_ny and not ny_start ? vwap_ny : na, 'New York Session VWAP', color = ny_vwap_col, linewidth = 2, style = plot.style_linebr)
plot(show_ny_vwap and show_sess_b1 and in_ny and not ny_start ? vwap_ny + band_mult1 * std_ny : na, 'New York Band 1 Upper', color = color.new(ny_vwap_col, 40), style = plot.style_linebr)
plot(show_ny_vwap and show_sess_b1 and in_ny and not ny_start ? vwap_ny - band_mult1 * std_ny : na, 'New York Band 1 Lower', color = color.new(ny_vwap_col, 40), style = plot.style_linebr)
plot(show_ny_vwap and show_sess_b2 and in_ny and not ny_start ? vwap_ny + band_mult2 * std_ny : na, 'New York Band 2 Upper', color = color.new(ny_vwap_col, 50), style = plot.style_linebr)
plot(show_ny_vwap and show_sess_b2 and in_ny and not ny_start ? vwap_ny - band_mult2 * std_ny : na, 'New York Band 2 Lower', color = color.new(ny_vwap_col, 50), style = plot.style_linebr)
plot(show_ny_vwap and show_sess_b3 and in_ny and not ny_start ? vwap_ny + band_mult  * std_ny : na, 'New York Band 3 Upper', color = color.new(ny_vwap_col, 60), style = plot.style_linebr)
plot(show_ny_vwap and show_sess_b3 and in_ny and not ny_start ? vwap_ny - band_mult  * std_ny : na, 'New York Band 3 Lower', color = color.new(ny_vwap_col, 60), style = plot.style_linebr)

plot(ma_ha_close, 'Trend Indicator A Lijn', color = trend_1m > 0 ? color.green : color.red, linewidth = math.max(1, lijn_dikte))

// ============================================================
// --- DASHBOARD TEKENEN ---
// ============================================================
var pos = dash_pos == 'Rechtsboven' ? position.top_right : dash_pos == 'Rechtsonder' ? position.bottom_right : dash_pos == 'Linksboven' ? position.top_left : position.bottom_left
var table rsi_tb = table.new(pos, 2, 3, bgcolor = color.new(#1e222d, 10), border_color = color.gray, border_width = 1, frame_color = color.gray, frame_width = 1)

if barstate.islast and show_rsi_dash
    c_val    = rsi_v >= rsi_ob ? color.red : rsi_v <= rsi_os ? color.green : color.white
    s_stat   = rsi_v >= rsi_ob ? 'OVERBOUGHT' : rsi_v <= rsi_os ? 'OVERSOLD' : 'Neutraal'
    c_stat   = rsi_v >= rsi_ob ? color.red : rsi_v <= rsi_os ? color.green : color.gray
    
    recent_bull = nz(ta.barssince(bull_div), 999) <= div_lookback
    recent_bear = nz(ta.barssince(bear_div), 999) <= div_lookback
    s_div       = recent_bull ? 'BULLISH' : recent_bear ? 'BEARISH' : '-'
    c_div       = recent_bull ? color.green : recent_bear ? color.red : color.gray

    table.cell(rsi_tb, 0, 0, 'RSI (14):', text_color = color.white, text_halign = text.align_left, text_size = size.small)
    table.cell(rsi_tb, 1, 0, str.tostring(rsi_v, '#.00'), text_color = c_val, text_halign = text.align_right, text_size = size.small)

    table.cell(rsi_tb, 0, 1, 'Status:', text_color = color.white, text_halign = text.align_left, text_size = size.small)
    table.cell(rsi_tb, 1, 1, s_stat, text_color = c_stat, text_halign = text.align_right, text_size = size.small)

    table.cell(rsi_tb, 0, 2, 'Divergence:', text_color = color.white, text_halign = text.align_left, text_size = size.small)
    table.cell(rsi_tb, 1, 2, s_div, text_color = c_div, text_halign = text.align_right, text_size = size.small)
````
