# Multi-Exchange OI + Bybit LSR + Funding

- url: https://www.tradingview.com/script/dgClGdFm-multi-exchange-oi-bybit-lsr-funding/
- type: indicator
- pine_id: PUB;5d05b6d4dfd14998997a60aad30f610e
- version: 1.0

## Description

В настройках ты сможешь:

включать/выключать Binance USDT / Binance USDC / Bybit USDT / Bybit USDC;

показывать OI свечами или линией;

отдельно включать/отключать LSR и funding.

## Source Code

````pine
// © Balabasik
//@version=6
indicator("Multi-Exchange OI + Bybit LSR + Funding", overlay=false)

// ---------- INPUTS ----------
group_oi = "OI Sources"
show_binance_usdt = input.bool(true,  "Binance USDT OI", group=group_oi)
show_binance_usdc = input.bool(true,  "Binance USDC OI", group=group_oi)
show_bybit_usdt   = input.bool(true,  "Bybit USDT OI",   group=group_oi)
show_bybit_usdc   = input.bool(true,  "Bybit USDC OI",   group=group_oi)

group_plot = "Display"
show_oi_candles = input.bool(true,  "Show summed OI candles", group=group_plot)
show_oi_line    = input.bool(false, "Show summed OI line",    group=group_plot)
show_lsr        = input.bool(true,  "Show Bybit LSR",         group=group_plot)
show_funding    = input.bool(true,  "Show funding proxy",     group=group_plot)

group_misc = "Symbols"
use_usdt_lsr = input.bool(true, "Use Bybit USDT pair for LSR", group=group_misc)
use_usdt_funding = input.bool(true, "Use Binance USDT pair for funding proxy", group=group_misc)

// ---------- BASE ----------
base = syminfo.basecurrency

// ---------- SYMBOLS ----------
binance_usdt_oi = "BINANCE:" + base + "USDT.P_OI"
binance_usdc_oi = "BINANCE:" + base + "USDC.P_OI"
bybit_usdt_oi   = "BYBIT:"   + base + "USDT.P_OI"
bybit_usdc_oi   = "BYBIT:"   + base + "USDC.P_OI"

lsr_symbol = use_usdt_lsr ? "BYBIT:" + base + "USDT.P_LSR" : "BYBIT:" + base + "USDC.P_LSR"

spot_symbol = use_usdt_funding ? "BINANCE:" + base + "USDT"   : "BINANCE:" + base + "USDC"
perp_symbol = use_usdt_funding ? "BINANCE:" + base + "USDT.P" : "BINANCE:" + base + "USDC.P"

// ---------- FETCH OI ----------
b_u_o = request.security(binance_usdt_oi, timeframe.period, open,  ignore_invalid_symbol=true)
b_u_h = request.security(binance_usdt_oi, timeframe.period, high,  ignore_invalid_symbol=true)
b_u_l = request.security(binance_usdt_oi, timeframe.period, low,   ignore_invalid_symbol=true)
b_u_c = request.security(binance_usdt_oi, timeframe.period, close, ignore_invalid_symbol=true)

b_c_o = request.security(binance_usdc_oi, timeframe.period, open,  ignore_invalid_symbol=true)
b_c_h = request.security(binance_usdc_oi, timeframe.period, high,  ignore_invalid_symbol=true)
b_c_l = request.security(binance_usdc_oi, timeframe.period, low,   ignore_invalid_symbol=true)
b_c_c = request.security(binance_usdc_oi, timeframe.period, close, ignore_invalid_symbol=true)

y_u_o = request.security(bybit_usdt_oi, timeframe.period, open,  ignore_invalid_symbol=true)
y_u_h = request.security(bybit_usdt_oi, timeframe.period, high,  ignore_invalid_symbol=true)
y_u_l = request.security(bybit_usdt_oi, timeframe.period, low,   ignore_invalid_symbol=true)
y_u_c = request.security(bybit_usdt_oi, timeframe.period, close, ignore_invalid_symbol=true)

y_c_o = request.security(bybit_usdc_oi, timeframe.period, open,  ignore_invalid_symbol=true)
y_c_h = request.security(bybit_usdc_oi, timeframe.period, high,  ignore_invalid_symbol=true)
y_c_l = request.security(bybit_usdc_oi, timeframe.period, low,   ignore_invalid_symbol=true)
y_c_c = request.security(bybit_usdc_oi, timeframe.period, close, ignore_invalid_symbol=true)

// ---------- SAFE ADD ----------
f_add(a, enabled) =>
    enabled and not na(a) ? a : 0.0

oi_open_sum  = f_add(b_u_o, show_binance_usdt) + f_add(b_c_o, show_binance_usdc) + f_add(y_u_o, show_bybit_usdt) + f_add(y_c_o, show_bybit_usdc)
oi_high_sum  = f_add(b_u_h, show_binance_usdt) + f_add(b_c_h, show_binance_usdc) + f_add(y_u_h, show_bybit_usdt) + f_add(y_c_h, show_bybit_usdc)
oi_low_sum   = f_add(b_u_l, show_binance_usdt) + f_add(b_c_l, show_binance_usdc) + f_add(y_u_l, show_bybit_usdt) + f_add(y_c_l, show_bybit_usdc)
oi_close_sum = f_add(b_u_c, show_binance_usdt) + f_add(b_c_c, show_binance_usdc) + f_add(y_u_c, show_bybit_usdt) + f_add(y_c_c, show_bybit_usdc)

active_sources =
     (show_binance_usdt ? 1 : 0) +
     (show_binance_usdc ? 1 : 0) +
     (show_bybit_usdt   ? 1 : 0) +
     (show_bybit_usdc   ? 1 : 0)

oi_open_final  = active_sources > 0 ? oi_open_sum  : na
oi_high_final  = active_sources > 0 ? oi_high_sum  : na
oi_low_final   = active_sources > 0 ? oi_low_sum   : na
oi_close_final = active_sources > 0 ? oi_close_sum : na

// ---------- LSR ----------
lsr = request.security(lsr_symbol, timeframe.period, close, ignore_invalid_symbol=true)

// ---------- FUNDING PROXY ----------
spot_close = request.security(spot_symbol, timeframe.period, close, ignore_invalid_symbol=true)
perp_close = request.security(perp_symbol, timeframe.period, close, ignore_invalid_symbol=true)
premium_pct = na(spot_close) or spot_close == 0 ? na : ((perp_close - spot_close) / spot_close) * 100.0
funding_proxy = premium_pct

// ---------- PLOTS ----------
plotcandle(
    show_oi_candles ? oi_open_final : na,
    show_oi_candles ? oi_high_final : na,
    show_oi_candles ? oi_low_final  : na,
    show_oi_candles ? oi_close_final : na,
    title="Summed OI",
    color=oi_close_final >= oi_open_final ? color.green : color.red,
    wickcolor=oi_close_final >= oi_open_final ? color.green : color.red,
    bordercolor=oi_close_final >= oi_open_final ? color.green : color.red
)

plot(show_oi_line ? oi_close_final : na, title="Summed OI Line", color=color.new(color.blue, 0), linewidth=2)
plot(show_lsr ? lsr : na, title="Bybit LSR", color=color.orange, linewidth=2)
plot(show_funding ? funding_proxy : na, title="Funding Proxy %", color=color.aqua, linewidth=2)

hline(1.0, "LSR Neutral", color=color.gray, linestyle=hline.style_dashed)
hline(0.0, "Funding Zero", color=color.silver, linestyle=hline.style_dotted)

// ---------- TABLE ----------
var table tbl = table.new(position.top_right, 2, 9, bgcolor=color.new(color.black, 80))
if barstate.islast
    table.cell(tbl, 0, 0, "OI Sum", text_color=color.white)
    table.cell(tbl, 1, 0, str.tostring(oi_close_final, "#,###"), text_color=color.lime)

    table.cell(tbl, 0, 1, "Binance USDT", text_color=color.white)
    table.cell(tbl, 1, 1, show_binance_usdt ? "ON" : "OFF", text_color=show_binance_usdt ? color.lime : color.gray)

    table.cell(tbl, 0, 2, "Binance USDC", text_color=color.white)
    table.cell(tbl, 1, 2, show_binance_usdc ? "ON" : "OFF", text_color=show_binance_usdc ? color.lime : color.gray)

    table.cell(tbl, 0, 3, "Bybit USDT", text_color=color.white)
    table.cell(tbl, 1, 3, show_bybit_usdt ? "ON" : "OFF", text_color=show_bybit_usdt ? color.lime : color.gray)

    table.cell(tbl, 0, 4, "Bybit USDC", text_color=color.white)
    table.cell(tbl, 1, 4, show_bybit_usdc ? "ON" : "OFF", text_color=show_bybit_usdc ? color.lime : color.gray)

    table.cell(tbl, 0, 5, "LSR", text_color=color.white)
    table.cell(tbl, 1, 5, str.tostring(lsr, "#.###"), text_color=color.orange)

    table.cell(tbl, 0, 6, "Crowd Bias", text_color=color.white)
    table.cell(
         tbl, 1, 6,
         na(lsr) ? "No data" :
         lsr > 1 ? "More longs" :
         lsr < 1 ? "More shorts" : "Neutral",
         text_color = na(lsr) ? color.orange :
                      lsr > 1 ? color.lime :
                      lsr < 1 ? color.red : color.silver
    )

    table.cell(tbl, 0, 7, "Premium %", text_color=color.white)
    table.cell(tbl, 1, 7, str.tostring(premium_pct, "#.####"), text_color=color.aqua)

    table.cell(tbl, 0, 8, "Funding Bias", text_color=color.white)
    table.cell(
         tbl, 1, 8,
         na(funding_proxy) ? "No data" :
         funding_proxy > 0 ? "Longs pay shorts" :
         funding_proxy < 0 ? "Shorts pay longs" : "Neutral",
         text_color = na(funding_proxy) ? color.orange :
                      funding_proxy > 0 ? color.lime :
                      funding_proxy < 0 ? color.red : color.silver
    )
````
