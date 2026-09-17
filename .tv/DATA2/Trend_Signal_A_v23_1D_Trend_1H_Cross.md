<!-- tradingview-pine-id: PUB;29909e0f19dc40c5848422990d2260dc -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Trend Signal A (v2.3) - 1D Trend + 1H Cross

Source: https://www.tradingview.com/script/y8NNCFbK-Trend-Signal-A-v2-3-1D-Trend-1H-Cross/

## Description

This indicator combines multi-timeframe trend analysis using Heikin-Ashi candles
smoothed with a configurable moving average (EMA, HMA, ALMA, SMA, etc.).

📌 How it works:
- Calculates trend on a higher timeframe (Daily by default) using the last
  CLOSED Heikin-Ashi candle only (no repainting).
- Looks for a trend cross confirmation on the chart's timeframe (designed for 1H).
- BUY signal: daily trend is bullish + bullish cross on the current timeframe.
- EXIT signal: bearish cross OR ATR-based dynamic stop loss, whichever comes first.

📊 Built-in panel:
Shows in real time the daily trend state, whether a position is currently open,
the unrealized PnL of the open trade, and the cumulative historical PnL
(simulated, no fees/slippage) since the indicator was loaded on the chart.

⚙️ Fully configurable: moving average type and length, higher-timeframe
selection, ATR multiplier for the stop loss, colors, and panel visibility.

⚠️ This script is an analysis tool, not financial advice. Past results shown
in the panel do not guarantee future performance. The PnL displayed is a
simplified simulation for educational purposes, not a full strategy backtest
(no fees, slippage, or position sizing are accounted for).

🙏 Credits: based on "Trend Indicator A" by DZIV (dzi_v_), published under
CC BY-NC-SA 4.0. This script is released under the same license.

---

## Source Code

````pine
//@version=6
//
//╔════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
//║ Basado en "Trend Indicator A (v2.3)" de DZIV (dzi_v_) — CC BY-NC-SA 4.0
//║ Versión INDICADOR (sin backtest) con señales de entrada/salida:
//║   BUY  -> Tendencia 1D alcista (vela HA confirmada) + cruce alcista de la tendencia en la TF actual (1H)
//║   SELL -> Cruce bajista de la tendencia en la TF actual (1H)
//╚════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
indicator('Trend Signal A (v2.3) - 1D Trend + 1H Cross', 'TS A v2.3', overlay = true)

//╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
//║ Settings :
ma_type = input.string('EMA', 'MA Type', ['ALMA', 'HMA', 'SMA', 'SWMA', 'VWMA', 'WMA', 'ZLEMA', 'EMA'], group = 'Setup')
ma_period = input.int(9, 'MA Period (Length)', 1, group = 'Setup')

alma_offset = input.float(0.85, 'ALMA Shift', 0, 1, 0.05, group = 'Setup (ALMA)')
alma_sigma = input.int(6, 'ALMA Deviation', 1, step = 1, group = 'Setup (ALMA)')

tf_higher = input.timeframe('D', 'Temporalidad de tendencia (Higher TF)', group = 'Multi-Timeframe')

show_line_1(x) =>
    input.bool(true, 'Show Close line', group = 'On/Off') ? x : na
show_line_2(x) =>
    input.bool(false, 'Show High/Low lines', group = 'On/Off') ? x : na
show_fill(x) =>
    input.bool(true, 'Show fill', group = 'On/Off') ? x : na

show_panel = input.bool(true, 'Mostrar panel de estado', group = 'Panel')
panel_position = input.string('top_right', 'Posición del panel', ['top_right', 'top_left', 'bottom_right', 'bottom_left'], group = 'Panel')

use_atr_sl = input.bool(true, 'Usar Stop Loss por ATR', group = 'Stop Loss (ATR)')
atr_period = input.int(14, 'ATR Period', minval = 1, group = 'Stop Loss (ATR)')
atr_mult = input.float(1.5, 'ATR Multiplier', minval = 0.1, step = 0.1, group = 'Stop Loss (ATR)')
show_sl_line = input.bool(true, 'Mostrar línea de Stop Loss', group = 'Stop Loss (ATR)')
//╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
//║ Calculations :
f(x) =>
    switch ma_type
        'ALMA' => ta.alma(x, ma_period, alma_offset, alma_sigma)
        'HMA' => ta.hma(x, ma_period)
        'SMA' => ta.sma(x, ma_period)
        'SWMA' => ta.swma(x)
        'VWMA' => ta.vwma(x, ma_period)
        'WMA' => ta.vwma(x, ma_period)
        'ZLEMA' => ta.ema(x + x - x[math.floor((ma_period - 1) / 2)], ma_period)
        => ta.ema(x, ma_period)

// --- Tendencia en temporalidad ACTUAL (pensado para usarse en gráfico de 1H) ---
ma_ha_open = f(request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, open))
ma_ha_close = f(request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, close))
ma_ha_high = f(request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, high))
ma_ha_low = f(request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, low))

trend = 100 * (ma_ha_close - ma_ha_open) / (ma_ha_high - ma_ha_low)

// --- Tendencia en la TEMPORALIDAD SUPERIOR (1D por defecto), SIN REPINTADO ---
// Técnica close[1] + lookahead_on: siempre toma la última vela de 1D ya CERRADA.
get_htf_trend() =>
    ha_open = f(open)
    ha_close = f(close)
    ha_close[1] > ha_open[1]

trend_htf_bullish = request.security(ticker.heikinashi(syminfo.tickerid), tf_higher, get_htf_trend(), lookahead = barmerge.lookahead_on)

atr_val = ta.atr(atr_period)

//╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
//║ Señales y gestión de posición :
//║  BUY  -> 1D alcista (confirmado) + cruce alcista de la tendencia en TF actual, y NO estamos ya dentro
//║          Al entrar se fija un Stop Loss = precio de entrada - ATR * multiplicador
//║  SALIDA -> lo que ocurra primero:
//║       a) el precio toca el Stop Loss (SL)
//║       b) cruce bajista de la tendencia en TF actual (SELL)
//║  (Nunca sale "sell" si no hay una compra activa que cerrar — evita señales sueltas)
cross_up_local = trend > 0 and trend[1] <= 0
cross_down_local = trend < 0 and trend[1] >= 0

var bool in_position = false
var float entry_price = na
var float stop_price = na
var float total_pnl_pct = 0.0
var int trade_count = 0
var int win_count = 0
var float last_trade_pnl_pct = na

buy_signal = trend_htf_bullish and cross_up_local and not in_position

sl_hit = use_atr_sl and in_position and low <= stop_price
sell_cross = cross_down_local and in_position and not sl_hit // si el SL ya se tocó, ese es el motivo de salida
sell_signal = sl_hit or sell_cross

// --- Entrada ---
if buy_signal
    entry_price := close
    stop_price := use_atr_sl ? close - atr_val * atr_mult : na
    in_position := true
    in_position

// --- Salida (y cálculo de PnL del trade cerrado) ---
if sell_signal
    exit_price = sl_hit ? stop_price : close
    trade_pnl_pct = (exit_price - entry_price) / entry_price * 100
    total_pnl_pct := total_pnl_pct + trade_pnl_pct
    trade_count := trade_count + 1
    if trade_pnl_pct > 0
        win_count := win_count + 1
        win_count
    last_trade_pnl_pct := trade_pnl_pct
    in_position := false
    entry_price := na
    stop_price := na
    stop_price

win_rate = trade_count > 0 ? win_count / trade_count * 100 : na
//╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
//║ Colors :
color_positive = input.color(color.new(#26A69A, 0), 'Positive color (Bullish)', group = 'Colors')
color_negative = input.color(color.new(#EF5350, 0), 'Negative color (Bearish)', group = 'Colors')
color_neutral = input.color(color.new(#808080, 0), 'Neutral color', group = 'Colors')

color_trend = trend > 0 ? color_positive : color_negative
//╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
//║ Plot :
plot_open = plot(ma_ha_open, 'Open line', na)
plot_close = plot(ma_ha_close, 'Close line', show_line_1(color_trend), 2)
plot_high = plot(ma_ha_high, 'High line', show_line_2(color_neutral))
plot_low = plot(ma_ha_low, 'Low line', show_line_2(color_neutral))

plot_highest = plot(math.max(ma_ha_open, ma_ha_close), 'Highest Body line', na)
plot_lowest = plot(math.min(ma_ha_open, ma_ha_close), 'Lowest Body line', na)

fill(plot_open, plot_close, color.new(color_trend, 50), 'Open/Close Cloud')
fill(plot_high, plot_highest, show_fill(color.new(color_neutral, 87.5)), title = 'High Cloud')
fill(plot_lowest, plot_low, show_fill(color.new(color_neutral, 87.5)), title = 'Low Cloud')

sell_pnl_text = sl_hit ? 'SL ' : 'SELL '
sell_pnl_text := sell_pnl_text + (last_trade_pnl_pct >= 0 ? '+' : '') + str.tostring(math.round(last_trade_pnl_pct, 1)) + '%'

plotshape(buy_signal, title = 'Buy Signal', style = shape.triangleup, location = location.belowbar, color = color_positive, size = size.tiny, text = 'BUY', textcolor = color_positive)

exit_color = last_trade_pnl_pct >= 0 ? color_positive : color_negative

if sell_cross
    label.new(bar_index, high, sell_pnl_text, style = label.style_label_down, size = size.tiny, color = color.new(exit_color, 0), textcolor = color.white, yloc = yloc.abovebar)

if sl_hit
    label.new(bar_index, high, sell_pnl_text, style = label.style_label_down, size = size.tiny, color = color.new(exit_color, 0), textcolor = color.white, yloc = yloc.abovebar)

plot(show_sl_line and in_position ? stop_price : na, title = 'Stop Loss', color = color.new(color.orange, 0), style = plot.style_linebr, linewidth = 1)

//╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
//║ Panel de estado (limpio y profesional) :
var table panel = table.new(panel_position == 'top_right' ? position.top_right : panel_position == 'top_left' ? position.top_left : panel_position == 'bottom_right' ? position.bottom_right : position.bottom_left, 2, 7, border_width = 1, border_color = color.new(color.gray, 70), frame_color = color.new(color.gray, 70), frame_width = 1)

if show_panel and barstate.islast
    bg_head = color.new(color.black, 20)
    table.cell(panel, 0, 0, 'Tendencia 1D', text_color = color.white, bgcolor = bg_head, text_size = size.small)
    table.cell(panel, 1, 0, trend_htf_bullish ? 'ALCISTA' : 'BAJISTA', text_color = color.white, bgcolor = trend_htf_bullish ? color_positive : color_negative, text_size = size.small)

    table.cell(panel, 0, 1, 'Trend 1H', text_color = color.white, bgcolor = bg_head, text_size = size.small)
    table.cell(panel, 1, 1, str.tostring(math.round(trend, 1)), text_color = color.white, bgcolor = trend > 0 ? color_positive : color_negative, text_size = size.small)

    table.cell(panel, 0, 2, 'En posición', text_color = color.white, bgcolor = bg_head, text_size = size.small)
    table.cell(panel, 1, 2, in_position ? 'SÍ (esperando salida)' : 'NO (esperando BUY)', text_color = color.white, bgcolor = in_position ? color_positive : color.new(color_neutral, 30), text_size = size.small)

    unrealized_pct = in_position ? (close - entry_price) / entry_price * 100 : na
    table.cell(panel, 0, 3, 'PnL trade abierto', text_color = color.white, bgcolor = bg_head, text_size = size.small)
    table.cell(panel, 1, 3, in_position ? str.tostring(math.round(unrealized_pct, 2)) + '%' : '—', text_color = color.white, bgcolor = in_position ? unrealized_pct > 0 ? color_positive : color_negative : color.new(color_neutral, 30), text_size = size.small)

    ultima = buy_signal ? 'BUY' : sl_hit ? 'STOP LOSS' : sell_cross ? 'SELL' : '—'
    color_ultima = buy_signal ? color_positive : sl_hit or sell_cross ? color_negative : color.new(color_neutral, 30)
    table.cell(panel, 0, 4, 'Señal actual', text_color = color.white, bgcolor = bg_head, text_size = size.small)
    table.cell(panel, 1, 4, ultima, text_color = color.white, bgcolor = color_ultima, text_size = size.small)

    table.cell(panel, 0, 5, 'PnL total (histórico)', text_color = color.white, bgcolor = bg_head, text_size = size.small)
    table.cell(panel, 1, 5, str.tostring(math.round(total_pnl_pct, 2)) + '%', text_color = color.white, bgcolor = total_pnl_pct >= 0 ? color_positive : color_negative, text_size = size.small)

    table.cell(panel, 0, 6, 'Trades / Win rate', text_color = color.white, bgcolor = bg_head, text_size = size.small)
    table.cell(panel, 1, 6, str.tostring(trade_count) + ' / ' + (trade_count > 0 ? str.tostring(math.round(win_rate, 1)) + '%' : '—'), text_color = color.white, bgcolor = color.new(color_neutral, 30), text_size = size.small)

//╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
//║ Alertas :
alertcondition(buy_signal, title = 'BUY Signal', message = 'Trend Signal A: BUY - 1D alcista + cruce alcista 1H')
alertcondition(sell_cross, title = 'SELL Signal (cruce)', message = 'Trend Signal A: SELL - cruce bajista 1H')
alertcondition(sl_hit, title = 'Stop Loss Hit', message = 'Trend Signal A: STOP LOSS alcanzado')
//╚════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
````
