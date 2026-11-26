# FagoriTools 1.0

- url: https://www.tradingview.com/script/IsqqYtxW-FagoriTools-1-0/
- type: indicator
- pine_id: PUB;c81f2872c7a14285967c4592a6767b4a
- version: 1.0

## Description

**FagoriTools — Multi-TF Trend + Reverse RSI Levels**

All-in-one indicator that combines three utilities into a single script to reduce visual clutter on the chart:

**1) Configurable EMAs**

Five independent exponential moving averages, each with its own period, color, and on/off toggle. Default values follow common combinations: 9, 12, 26, 50, and 200. Useful for those who rely on classic crossovers (12/26, 50/200) and want all references consolidated within one indicator.

**2) Reverse RSI Levels**

Instead of displaying the RSI in a separate panel, this module plots two lines directly over price, indicating the exact value at which the asset would need to close for the RSI to reach the oversold (default 30) and overbought (default 70) thresholds.

The calculation inverts the RSI formula: starting from the current gain and loss averages (RMA), it solves the equation for the `close` value that would produce the target RSI, accounting for Wilder's smoothing. This allows you to see at a glance, "if it drops to X, it becomes oversold" or "to turn overbought, it needs to rise to Y," without switching between panels.

Both the RSI levels and the period (default 14) are fully customizable.

**3) Multi-Timeframe Table**

A consolidated panel displaying the asset's reading across seven timeframes: 5m, 15m, 1h, 4h, 1D, 1W, and 1M (each can be toggled on or off individually).

For each timeframe, the table shows:

* Trend — trend direction (Up/Down) based on the close relative to the slow EMA. Green = Up, Red = Down.
* RSI — numeric RSI value for that timeframe, with the background color reflecting the trend.
* Fixed (optional) — the same trend reading applied to a fixed pair chosen by the user (e.g., SPX500, DXY, BTCUSDT). Useful for tracking correlation with a benchmark without switching charts.

The table position is configurable across two dimensions (vertical: Top/Middle/Bottom; horizontal: Left/Right).

**How to Use**

1. Enable the EMAs that align with your strategy.
2. Adjust the RSI levels according to your style (some prefer 20/80 in crypto, 30/70 in stocks).
3. Use the multi-TF table to align your trades with the higher timeframe trend. Entries against the trend of larger timeframes typically have a lower win rate.

**Notes**

* The Reverse RSI is a deterministic calculation, not a projection. The value displayed is the current price required for the RSI to reach the target, and it updates with every candle.
* The "Fixed" column depends on the chosen symbol being available on the broker. Otherwise, it remains blank.
* Indicator is overlaid on price, working with any asset and timeframe.

## Source Code

````pine
//@version=6
indicator("FagoriTools 1.0", "Fagori", overlay = true)

// =====================================================================
// FagoriTools 1.0
// =====================================================================

// ── Groups ───────────────────────────────────────────────────────────
G_EMA = "(E)MAs"
G_RSI = "RSI Levels"
G_TBL = "Tabela"
G_TF  = "Timeframes"

// ── EMAs ─────────────────────────────────────────────────────────────
ema1_on  = input.bool(false, "EMA 1", inline = "e1", group = G_EMA)
ema1_len = input.int(9, "", inline = "e1", minval = 1, group = G_EMA)
ema1_col = input.color(#e040fb, "", inline = "e1", group = G_EMA)

ema2_on  = input.bool(true, "EMA 2", inline = "e2", group = G_EMA)
ema2_len = input.int(12, "", inline = "e2", minval = 1, group = G_EMA)
ema2_col = input.color(#ff9800, "", inline = "e2", group = G_EMA)

ema3_on  = input.bool(true, "EMA 3", inline = "e3", group = G_EMA)
ema3_len = input.int(26, "", inline = "e3", minval = 1, group = G_EMA)
ema3_col = input.color(#2962ff, "", inline = "e3", group = G_EMA)

ema4_on  = input.bool(false, "EMA 4", inline = "e4", group = G_EMA)
ema4_len = input.int(50, "", inline = "e4", minval = 1, group = G_EMA)
ema4_col = input.color(#00c853, "", inline = "e4", group = G_EMA)

ema5_on  = input.bool(true, "EMA 5", inline = "e5", group = G_EMA)
ema5_len = input.int(200, "", inline = "e5", minval = 1, group = G_EMA)
ema5_col = input.color(#ff1744, "", inline = "e5", group = G_EMA)

// ── RSI ──────────────────────────────────────────────────────────────
rsi_on   = input.bool(true, "Mostrar RSI Levels (reverso)", group = G_RSI)
rsi_len  = input.int(14, "Período do RSI", minval = 2, group = G_RSI)
rsi_low  = input.int(30, "Nível inferior (sobrevenda)",  minval = 1, maxval = 49, group = G_RSI)
rsi_high = input.int(70, "Nível superior (sobrecompra)", minval = 51, maxval = 99, group = G_RSI)
rsi_col_sv = input.color(color.new(color.lime, 50), "Cor sobrevenda", group = G_RSI)
rsi_col_sc = input.color(color.new(color.red,  50), "Cor sobrecompra", group = G_RSI)

// ── Tabela ───────────────────────────────────────────────────────────
tbl_on  = input.bool(true, "Mostrar Tabela", group = G_TBL)
tbl_pos_v = input.string("Inferior",  "Posição vertical",   options = ["Topo", "Meio", "Inferior"], inline = "pos", group = G_TBL)
tbl_pos_h = input.string("Esquerda",  "Posição horizontal", options = ["Esquerda", "Direita"],      inline = "pos", group = G_TBL)
tbl_fx_on    = input.bool(false, "Usar Par Fixo", inline = "fx", group = G_TBL)
tbl_fx_sy    = input.symbol("FOREXCOM:SPX500", "", inline = "fx", group = G_TBL)

r1_on = input.bool(true, "5m",  inline = "r1", group = G_TF)
r1_tf = input.timeframe("5",   "", inline = "r1", group = G_TF)
r2_on = input.bool(true, "15m", inline = "r2", group = G_TF)
r2_tf = input.timeframe("15",  "", inline = "r2", group = G_TF)
r3_on = input.bool(true, "1h",  inline = "r3", group = G_TF)
r3_tf = input.timeframe("60",  "", inline = "r3", group = G_TF)
r4_on = input.bool(true, "4h",  inline = "r4", group = G_TF)
r4_tf = input.timeframe("240", "", inline = "r4", group = G_TF)
r5_on = input.bool(true, "1D",  inline = "r5", group = G_TF)
r5_tf = input.timeframe("D",   "", inline = "r5", group = G_TF)
r6_on = input.bool(true, "1S",  inline = "r6", group = G_TF)
r6_tf = input.timeframe("W",   "", inline = "r6", group = G_TF)
r7_on = input.bool(true, "1M",  inline = "r7", group = G_TF)
r7_tf = input.timeframe("M",   "", inline = "r7", group = G_TF)

// =====================================================================
// EMAs
// =====================================================================
ma1 = ta.ema(close, ema1_len)
ma2 = ta.ema(close, ema2_len)
ma3 = ta.ema(close, ema3_len)
ma4 = ta.ema(close, ema4_len)
ma5 = ta.ema(close, ema5_len)

plot(ema1_on ? ma1 : na, "EMA 1", color = ema1_col, linewidth = 2)
plot(ema2_on ? ma2 : na, "EMA 2", color = ema2_col, linewidth = 2)
plot(ema3_on ? ma3 : na, "EMA 3", color = ema3_col, linewidth = 2)
plot(ema4_on ? ma4 : na, "EMA 4", color = ema4_col, linewidth = 2)
plot(ema5_on ? ma5 : na, "EMA 5", color = ema5_col, linewidth = 2)

// =====================================================================
// RSI Reverso (preço que produziria o RSI alvo)
// =====================================================================
f_rsi_price(tgt, len) =>
    chg   = ta.change(close)
    gain  = math.max(chg, 0)
    loss  = math.max(-chg, 0)
    ag    = ta.rma(gain, len)
    al    = ta.rma(loss, len)
    alpha = 1.0 / len
    agp   = nz(ag[1])
    alp   = nz(al[1])
    cp    = close[1]
    rs_t  = tgt / (100.0 - tgt)
    d_up  = ((1 - alpha) / alpha) * (rs_t * alp - agp)
    d_dn  = ((1 - alpha) / alpha) * (agp / rs_t - alp)
    result = d_up > 0 ? cp + d_up : cp - d_dn
    result

p_low  = rsi_on ? f_rsi_price(rsi_low,  rsi_len) : na
p_high = rsi_on ? f_rsi_price(rsi_high, rsi_len) : na

plot(p_low,  "RSI Sobrevenda",  color = rsi_col_sv, linewidth = 1)
plot(p_high, "RSI Sobrecompra", color = rsi_col_sc, linewidth = 1)

var label rsi_lbl_lo = na
var label rsi_lbl_hi = na

if barstate.islast
    label.delete(rsi_lbl_lo)
    label.delete(rsi_lbl_hi)
    if rsi_on and not na(p_low)
        rsi_lbl_lo := label.new(bar_index + 3, p_low, "RSI " + str.tostring(rsi_low), style = label.style_none, textcolor = color.gray, size = size.small)
    if rsi_on and not na(p_high)
        rsi_lbl_hi := label.new(bar_index + 3, p_high, "RSI " + str.tostring(rsi_high), style = label.style_none, textcolor = color.gray, size = size.small)

// =====================================================================
// Tendência multi-TF — codifica trend + rsi num float
//   alta  → rsi + 1000
//   baixa → rsi
// =====================================================================
f_combined() =>
    e_slow  = ta.ema(close, ema3_len)
    is_alta = close > e_slow
    rsi_v   = ta.rsi(close, rsi_len)
    is_alta ? rsi_v + 1000.0 : rsi_v

tc1 = request.security(syminfo.tickerid, r1_tf, f_combined())
tc2 = request.security(syminfo.tickerid, r2_tf, f_combined())
tc3 = request.security(syminfo.tickerid, r3_tf, f_combined())
tc4 = request.security(syminfo.tickerid, r4_tf, f_combined())
tc5 = request.security(syminfo.tickerid, r5_tf, f_combined())
tc6 = request.security(syminfo.tickerid, r6_tf, f_combined())
tc7 = request.security(syminfo.tickerid, r7_tf, f_combined())

fc1 = request.security(tbl_fx_sy, r1_tf, f_combined(), ignore_invalid_symbol = true)
fc2 = request.security(tbl_fx_sy, r2_tf, f_combined(), ignore_invalid_symbol = true)
fc3 = request.security(tbl_fx_sy, r3_tf, f_combined(), ignore_invalid_symbol = true)
fc4 = request.security(tbl_fx_sy, r4_tf, f_combined(), ignore_invalid_symbol = true)
fc5 = request.security(tbl_fx_sy, r5_tf, f_combined(), ignore_invalid_symbol = true)
fc6 = request.security(tbl_fx_sy, r6_tf, f_combined(), ignore_invalid_symbol = true)
fc7 = request.security(tbl_fx_sy, r7_tf, f_combined(), ignore_invalid_symbol = true)

// =====================================================================
// Tabela
// =====================================================================
COL_ALTA  = color.rgb(167, 230, 175)
COL_BAIXA = color.rgb(240, 168, 168)
COL_HEAD  = color.new(color.gray, 60)
COL_BG    = color.new(color.black, 30)
COL_NA    = color.new(color.gray, 80)
COL_RSI   = color.rgb(245, 245, 245)
TXT_DARK  = color.rgb(20, 20, 20)

f_trend_txt(c) => na(c) ? "" : c > 500 ? "Alta" : "Baixa"
f_rsi_txt(c)   => na(c) ? "" : c > 500 ? str.tostring(c - 1000.0, "#.##") : str.tostring(c, "#.##")
f_trend_bg(c)  => na(c) ? COL_NA : c > 500 ? COL_ALTA : COL_BAIXA

tbl_pos_const = tbl_pos_v == "Topo" and tbl_pos_h == "Esquerda" ? position.top_left :
   tbl_pos_v == "Topo" and tbl_pos_h == "Direita"  ? position.top_right :
   tbl_pos_v == "Meio" and tbl_pos_h == "Esquerda" ? position.middle_left :
   tbl_pos_v == "Meio" and tbl_pos_h == "Direita"  ? position.middle_right :
   tbl_pos_v == "Inferior" and tbl_pos_h == "Direita" ? position.bottom_right :
   position.bottom_left

var table tbl = na

if barstate.islast and tbl_on
    table.delete(tbl)

    n_cols = 3 + (tbl_fx_on ? 1 : 0)
    n_rows = (r1_on ? 1 : 0) + (r2_on ? 1 : 0) + (r3_on ? 1 : 0) + (r4_on ? 1 : 0) + (r5_on ? 1 : 0) + (r6_on ? 1 : 0) + (r7_on ? 1 : 0)
    tbl := table.new(tbl_pos_const, n_cols, n_rows + 1, bgcolor = COL_BG, frame_color = color.gray, frame_width = 1, border_color = color.new(color.gray, 70), border_width = 1)

    // Header
    c = 0
    table.cell(tbl, c, 0, syminfo.ticker, text_color = color.white, bgcolor = COL_HEAD)
    c += 1
    table.cell(tbl, c, 0, "Tend", text_color = color.white, bgcolor = COL_HEAD)
    c += 1
    table.cell(tbl, c, 0, "RSI", text_color = color.white, bgcolor = COL_HEAD)
    c += 1
    if tbl_fx_on
        table.cell(tbl, c, 0, "Fixo", text_color = color.white, bgcolor = COL_HEAD)

    var int idx = 0
    idx := 1

    labels = array.new_string()
    own_v  = array.new_float()
    fx_v   = array.new_float()

    if r1_on
        array.push(labels, "5m"),  array.push(own_v, tc1), array.push(fx_v, fc1)
    if r2_on
        array.push(labels, "15m"), array.push(own_v, tc2), array.push(fx_v, fc2)
    if r3_on
        array.push(labels, "1h"),  array.push(own_v, tc3), array.push(fx_v, fc3)
    if r4_on
        array.push(labels, "4h"),  array.push(own_v, tc4), array.push(fx_v, fc4)
    if r5_on
        array.push(labels, "1D"),  array.push(own_v, tc5), array.push(fx_v, fc5)
    if r6_on
        array.push(labels, "1S"),  array.push(own_v, tc6), array.push(fx_v, fc6)
    if r7_on
        array.push(labels, "1M"),  array.push(own_v, tc7), array.push(fx_v, fc7)

    for i = 0 to array.size(labels) - 1
        own = array.get(own_v, i)
        ft  = array.get(fx_v, i)
        col = 0
        table.cell(tbl, col, idx, array.get(labels, i), text_color = color.white, bgcolor = COL_HEAD)
        col += 1
        table.cell(tbl, col, idx, f_trend_txt(own), text_color = TXT_DARK, bgcolor = f_trend_bg(own))
        col += 1
        table.cell(tbl, col, idx, f_rsi_txt(own), text_color = TXT_DARK, bgcolor = COL_RSI)
        col += 1
        if tbl_fx_on
            table.cell(tbl, col, idx, f_trend_txt(ft), text_color = TXT_DARK, bgcolor = f_trend_bg(ft))
        idx += 1
````
