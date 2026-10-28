# eltrad3r strategie

- url: https://www.tradingview.com/script/jxr8oJIK-eltrad3r-strategie/
- type: indicator
- pine_id: PUB;ff3e413073e14185b0a853197d517f41
- version: 1.0

## Description

eltrad3r REAL SYSTEM v6 — Consolidation Breakout with Dynamic R:R Management

This indicator automatically identifies the pre-market consolidation range (9:00–9:30 AM ET) and generates entry signals when price breaks out of that range with trend confirmation, using dynamic risk management that adapts to any instrument.

─── HOW IT WORKS ───

During the consolidation window (9:00–9:30 AM) the system plots the High and Low of the range. Once the market opens in full (9:30 AM), it waits for a confirmation candle that closes above the range for LONG, or below for SHORT, with price always on the same side of the EMA 9.

Stop Loss is placed automatically at the Low of the previous candle (LONG) or the High of the previous candle (SHORT). Take Profit is calculated by multiplying that risk by the minimum configured R:R (default 2:1). This makes the system work on any asset — futures, stocks, ETFs, crypto — without needing to adjust fixed points.

─── SIGNALS ───

🟢 LONG — candle closes above the consolidation range and above EMA 9
🔴 SHORT — candle closes below the consolidation range and below EMA 9
⚪ EXIT L / EXIT S — exit when price crosses EMA 9, hits the Stop, or reaches the Target

─── SETTINGS ───

- Minimum R:R — minimum ratio required to open a trade (default 2.0)
- Max trades per day — daily trade limit (default 5)
- Consolidation window — range time window (default 09:00–09:30)
- Trading window — active hours for entries (default 09:30–16:00)

─── COMPATIBILITY ───

Works on any minute timeframe. Optimized for NQ Futures, QQQ, SPY, NVDA, AAPL, MSFT, META and any instrument with a regular US market session. Time windows are fully configurable to adapt to other markets.

─── RISK MANAGEMENT ───

The system never enters a trade where the R:R does not meet the configured minimum. The actual risk per trade is displayed in the info table in real time. Maximum 5 trades per day by default to protect capital on high volatility days.

This indicator is a technical analysis tool. It does not constitute financial advice or guarantee results. Always trade with risk management appropriate to your capital.

## Source Code

````pine
//@version=6
indicator("eltrad3r strategie – REAL SYSTEM v6", overlay=true)

// ═══════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════
rr_min      = input.float(2.0,  "R:R mínimo",          minval=1.0, step=0.5)
max_trades  = input.int(5,      "Máx. trades por día", minval=1,   maxval=10)
consol_sess = input.session("0900-0930", "Ventana de consolidación")
trade_sess  = input.session("0930-1600", "Ventana de trading")

// ═══════════════════════════════════════════════════════════
// EMA 9 — amarillo
// ═══════════════════════════════════════════════════════════
ema9     = ta.ema(close, 9)
plot(ema9, color=color.yellow, linewidth=2, title="EMA 9")
ema_bull = close > ema9
ema_bear = close < ema9

// ═══════════════════════════════════════════════════════════
// SESIONES
// ═══════════════════════════════════════════════════════════
in_consol  = not na(time(timeframe.period, consol_sess))
in_trading = not na(time(timeframe.period, trade_sess))
new_day    = ta.change(time("D")) != 0

// ═══════════════════════════════════════════════════════════
// RANGO DE CONSOLIDACIÓN
// ═══════════════════════════════════════════════════════════
var float consol_high = na
var float consol_low  = na
var bool  consol_done = false

if new_day
    consol_high := na
    consol_low  := na
    consol_done := false

if in_consol
    consol_high := na(consol_high) ? high : math.max(consol_high, high)
    consol_low  := na(consol_low)  ? low  : math.min(consol_low,  low)
    consol_done := false

if not in_consol and not na(consol_high)
    consol_done := true

show_consol = (in_consol or (consol_done and in_trading)) and not na(consol_high)

plot(show_consol ? consol_high : na, color=color.white, linewidth=2, style=plot.style_linebr, title="Consolidation High")
plot(show_consol ? consol_low  : na, color=color.white, linewidth=2, style=plot.style_linebr, title="Consolidation Low")
bgcolor(in_consol ? color.new(color.white, 90) : na, title="Ventana Consolidación")

// ═══════════════════════════════════════════════════════════
// ESTADO DEL TRADE
// ═══════════════════════════════════════════════════════════
after_consol = consol_done and in_trading and not na(consol_high)

var int   trades_count = 0
var int   direction    = 0
var float entry_price  = na
var float stop_price   = na
var float target_price = na
var bool  in_trade     = false

if new_day
    trades_count := 0
    direction    := 0
    entry_price  := na
    stop_price   := na
    target_price := na
    in_trade     := false

// ═══════════════════════════════════════════════════════════
// ENTRADAS — stop en vela anterior, target con R:R mínimo
// ═══════════════════════════════════════════════════════════
prev_low  = low[1]
prev_high = high[1]

long_sl    = prev_low
long_risk  = close - long_sl
long_tp    = close + (long_risk * rr_min)
long_valid = long_risk > 0

short_sl    = prev_high
short_risk  = short_sl - close
short_tp    = close - (short_risk * rr_min)
short_valid = short_risk > 0

long_entry  = after_consol and not in_trade and close > consol_high and ema_bull and long_valid  and trades_count < max_trades
short_entry = after_consol and not in_trade and close < consol_low  and ema_bear and short_valid and trades_count < max_trades

if long_entry
    trades_count := trades_count + 1
    direction    := 1
    entry_price  := close
    stop_price   := long_sl
    target_price := long_tp
    in_trade     := true

if short_entry
    trades_count := trades_count + 1
    direction    := -1
    entry_price  := close
    stop_price   := short_sl
    target_price := short_tp
    in_trade     := true

// ═══════════════════════════════════════════════════════════
// CONDICIONES DE SALIDA
// ═══════════════════════════════════════════════════════════
exit_long_ema  = in_trade and direction ==  1 and close < ema9
exit_short_ema = in_trade and direction == -1 and close > ema9
exit_long_sl   = in_trade and direction ==  1 and low  <= stop_price
exit_short_sl  = in_trade and direction == -1 and high >= stop_price
exit_long_tp   = in_trade and direction ==  1 and high >= target_price
exit_short_tp  = in_trade and direction == -1 and low  <= target_price

exit_long   = exit_long_ema  or exit_long_sl  or exit_long_tp
exit_short  = exit_short_ema or exit_short_sl or exit_short_tp
exit_signal = exit_long or exit_short

if exit_signal
    direction    := 0
    entry_price  := na
    stop_price   := na
    target_price := na
    in_trade     := false

// ═══════════════════════════════════════════════════════════
// NIVELES SL / TP EN CHART
// ═══════════════════════════════════════════════════════════
plot(in_trade and direction ==  1 ? stop_price   : na, color=color.red,   style=plot.style_linebr, linewidth=1, title="SL Long")
plot(in_trade and direction ==  1 ? target_price : na, color=color.green, style=plot.style_linebr, linewidth=1, title="TP Long")
plot(in_trade and direction == -1 ? stop_price   : na, color=color.red,   style=plot.style_linebr, linewidth=1, title="SL Short")
plot(in_trade and direction == -1 ? target_price : na, color=color.green, style=plot.style_linebr, linewidth=1, title="TP Short")

// ═══════════════════════════════════════════════════════════
// VISUALES
// ═══════════════════════════════════════════════════════════
plotshape(long_entry,  location=location.belowbar, style=shape.labelup,   text="LONG",   color=color.green, textcolor=color.white, size=size.small, title="Long Entry")
plotshape(short_entry, location=location.abovebar, style=shape.labeldown, text="SHORT",  color=color.red,   textcolor=color.white, size=size.small, title="Short Entry")
plotshape(exit_long,   location=location.abovebar, style=shape.labeldown, text="EXIT L", color=color.white, textcolor=color.black, size=size.tiny,  title="Exit Long")
plotshape(exit_short,  location=location.belowbar, style=shape.labelup,   text="EXIT S", color=color.white, textcolor=color.black, size=size.tiny,  title="Exit Short")

// ═══════════════════════════════════════════════════════════
// INFO TABLE
// ═══════════════════════════════════════════════════════════
var table info = table.new(position.top_right, 2, 5, bgcolor=color.new(color.black, 70), border_width=1)
if barstate.islast
    dir_txt   = direction ==  1 ? "LONG  📈" : direction == -1 ? "SHORT 📉" : "FLAT  –"
    dir_color = direction ==  1 ? color.green : direction == -1 ? color.red : color.gray
    riesgo    = in_trade and direction == 1 ? entry_price - stop_price : in_trade and direction == -1 ? stop_price - entry_price : 0.0
    table.cell(info, 0, 0, "eltrad3r v6",  text_color=color.white, bgcolor=color.new(color.gray, 60))
    table.cell(info, 1, 0, "",             bgcolor=color.new(color.gray, 60))
    table.cell(info, 0, 1, "Trades hoy",   text_color=color.silver)
    table.cell(info, 1, 1, str.tostring(trades_count) + " / " + str.tostring(max_trades), text_color=color.white)
    table.cell(info, 0, 2, "Dirección",    text_color=color.silver)
    table.cell(info, 1, 2, dir_txt,        text_color=dir_color)
    table.cell(info, 0, 3, "Riesgo",       text_color=color.silver)
    table.cell(info, 1, 3, riesgo > 0 ? str.tostring(math.round(riesgo, 2)) + " pts" : "–", text_color=color.white)
    table.cell(info, 0, 4, "R:R mín",      text_color=color.silver)
    table.cell(info, 1, 4, "1 : " + str.tostring(rr_min), text_color=color.yellow)

// ═══════════════════════════════════════════════════════════
// ALERTAS
// ═══════════════════════════════════════════════════════════
alertcondition(long_entry,  title="🟢 LONG",       message="eltrad3r – LONG SIGNAL | Precio: {{close}}")
alertcondition(short_entry, title="🔴 SHORT",      message="eltrad3r – SHORT SIGNAL | Precio: {{close}}")
alertcondition(exit_long,   title="⚪ EXIT LONG",  message="eltrad3r – EXIT LONG | Precio: {{close}}")
alertcondition(exit_short,  title="⚪ EXIT SHORT", message="eltrad3r – EXIT SHORT | Precio: {{close}}")
````
