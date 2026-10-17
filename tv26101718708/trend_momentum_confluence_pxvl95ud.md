# Trend Momentum Confluence

- url: https://www.tradingview.com/script/PxVl95UD-trend-momentum-confluence/
- type: indicator
- pine_id: PUB;0f31dabf5162415aa1fb49fbce6010a5
- version: 1.0

## Description

🇷🇺 На русском
High WR Signal — высоковероятные сигналы по тренду
Краткое описание
Индикатор для поиска точек входа с высокой вероятностью отработки. Подаёт сигнал только когда совпадают четыре независимых условия: глобальный тренд, краткосрочный тренд, разворот импульса и подтверждение момента. Работает на любом таймфрейме и любом активе.

Как работает
В основе — комбинация трёх классических инструментов: трёх EMA, RSI и MACD. Сигнал появляется только тогда, когда все они согласованы.
🟢 Сигнал ЛОНГ — выполняются одновременно:

EMA 50 > EMA 200 — глобальный тренд направлен вверх
Close > EMA 21 — цена выше краткосрочной скользящей
RSI пересекает 50 снизу вверх — импульс разворачивается в сторону покупателей
MACD гистограмма > 0 — подтверждение бычьего момента

🔴 Сигнал ШОРТ — зеркальные условия:

EMA 50 < EMA 200 — глобальный тренд вниз
Close < EMA 21 — цена ниже краткосрочной скользящей
RSI пересекает 50 сверху вниз — импульс уходит к продавцам
MACD гистограмма < 0 — подтверждение медвежьего момента


Почему высокий Win Rate

Входы только по тренду — никаких контртрендовых сделок
Сигнал требует одновременного совпадения 4 условий, что отсекает шум
RSI cross 50 ловит точку перелома силы, а не перекупленность/перепроданность
MACD служит фильтром: даже при разворотах RSI ложные сигналы отсеиваются


Возможности

⚙️ Настраиваемые периоды EMA и RSI
📊 Таблица текущего состояния всех условий в реальном времени
🏷️ Метки сигналов с датой и временем прямо на графике
🔔 Три типа алертов: ЛОНГ, ШОРТ и универсальный
🤖 Поддержка alert() с webhook для автоматизации (боты, биржи)
🛡️ Опция «только на закрытии свечи» — защита от repaint
🎨 Настройка размера меток и отображения EMA


Как использовать

Добавьте индикатор на график любого таймфрейма
Дождитесь появления зелёной или красной метки
Сверьтесь с таблицей в правом верхнем углу — все 4 галочки должны стоять
Для алертов: Alt+A → выберите High WR Signal → нужный сигнал → Once Per Bar Close

Алерты автоматически привязываются к таймфрейму графика: создали на 15m — будут срабатывать по 15-минутным свечам, создали на 1H — по часовым. Можно создавать сколько угодно алертов на разных ТФ параллельно.

Рекомендуемые таймфреймы: 30m, 1H, 2H, 4H. На младших ТФ возможен повышенный шум.
⚠️ Индикатор не является финансовой рекомендацией. Используйте вместе с риск-менеджментом и собственным анализом.


🇬🇧 In English
High WR Signal — High-Probability Trend Signals
Short description
An indicator that finds high-probability entry points by combining four independent confirmations: global trend, short-term trend, momentum reversal and momentum confirmation. Works on any timeframe and any asset.

How it works
Based on a combination of three classic tools: three EMAs, RSI and MACD. A signal is generated only when all of them agree.
🟢 LONG signal — all conditions met simultaneously:

EMA 50 > EMA 200 — global uptrend
Close > EMA 21 — price above short-term moving average
RSI crosses 50 upward — momentum shifts to buyers
MACD histogram > 0 — bullish momentum confirmation

🔴 SHORT signal — mirrored conditions:

EMA 50 < EMA 200 — global downtrend
Close < EMA 21 — price below short-term moving average
RSI crosses 50 downward — momentum shifts to sellers
MACD histogram < 0 — bearish momentum confirmation


Why high Win Rate

Entries are trend-aligned only — no counter-trend trades
Signal requires 4 simultaneous conditions to filter out noise
RSI crossing 50 catches the momentum shift, not overbought/oversold extremes
MACD acts as an additional filter against false RSI signals


Features

⚙️ Configurable EMA and RSI periods
📊 Real-time conditions dashboard
🏷️ Signal labels with timestamp directly on the chart
🔔 Three alert types: LONG, SHORT, and Any Signal
🤖 alert() support with webhook for automation (bots, exchanges)
🛡️ "Bar close only" option — repaint protection
🎨 Customizable label sizes and EMA display


How to use

Add the indicator to any chart and any timeframe
Wait for a green or red label to appear
Check the dashboard in the top-right corner — all 4 conditions should be ✓
For alerts: Alt+A → select High WR Signal → choose alert type → Once Per Bar Close

Alerts are automatically tied to the chart's timeframe: an alert created on 15m fires on 15-minute candles, one created on 1H fires on hourly candles. You can run multiple alerts across different timeframes in parallel.

Recommended timeframes: 30m, 1H, 2H, 4H. Lower timeframes may produce more noise.
⚠️ This indicator is not financial advice. Use together with proper risk management and your own analysis.

## Source Code

````pine
//@version=6
indicator("High WR Signal", overlay=true, max_bars_back=500)

// ══════════════════════════════════════════════════════════════════════════════
//  HIGH WIN RATE SIGNAL
//  Стратегия: EMA Trend + RSI Cross 50 + MACD подтверждение
//  Работает на любом таймфрейме. Алерт создаётся на нужном ТФ — там и сработает.
// ══════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────
// НАСТРОЙКИ
// ─────────────────────────────────────────────────────────────
g1 = "Параметры"
g2 = "Отображение"
g3 = "Алерты"

ema_fast   = input.int(21,  "EMA Fast",  minval=5,  group=g1)
ema_mid    = input.int(50,  "EMA Mid",   minval=10, group=g1)
ema_slow   = input.int(200, "EMA Slow",  minval=50, group=g1)
rsi_period = input.int(14,  "RSI Period",minval=5,  group=g1)

show_ema   = input.bool(true, "Показывать EMA линии",  group=g2)
dot_size   = input.string("small", "Размер точек", options=["tiny","small","normal","large"], group=g2)
show_table = input.bool(true, "Таблица условий",       group=g2)

alert_on_close = input.bool(true,  "Только на закрытии свечи (без repaint)", group=g3, tooltip="Алерт срабатывает только после закрытия свечи. Рекомендуется.")
use_auto_alert = input.bool(false, "Авто-отправка alert() (webhook/бот)", group=g3, tooltip="Включите для автоматических webhook алертов. Создайте 1 алерт с условием 'Any alert() function call'.")

// ─────────────────────────────────────────────────────────────
// ИНДИКАТОРЫ
// ─────────────────────────────────────────────────────────────
ema21  = ta.ema(close, ema_fast)
ema50  = ta.ema(close, ema_mid)
ema200 = ta.ema(close, ema_slow)

rsi    = ta.rsi(close, rsi_period)

macd_line  = ta.ema(close, 12) - ta.ema(close, 26)
macd_sig   = ta.ema(macd_line, 9)
macd_hist  = macd_line - macd_sig

// ─────────────────────────────────────────────────────────────
// УСЛОВИЯ
// ─────────────────────────────────────────────────────────────
l1 = ema50 > ema200
l2 = close > ema21
l3 = ta.crossover(rsi, 50)
l4 = macd_hist > 0
is_long = l1 and l2 and l3 and l4

s1 = ema50 < ema200
s2 = close < ema21
s3 = ta.crossunder(rsi, 50)
s4 = macd_hist < 0
is_short = s1 and s2 and s3 and s4

// Финальные сигналы с учётом фильтра закрытия свечи
long_signal  = alert_on_close ? (is_long  and barstate.isconfirmed) : is_long
short_signal = alert_on_close ? (is_short and barstate.isconfirmed) : is_short

// ─────────────────────────────────────────────────────────────
// МЕТКИ
// ─────────────────────────────────────────────────────────────
lbl_time = str.format("{0,date,dd.MM.yyyy HH:mm}", time)

lbl_sz = dot_size == "tiny"   ? size.tiny   : dot_size == "normal" ? size.normal : dot_size == "large"  ? size.large  : size.small

if is_long
    label.new(bar_index, low * 0.9985, "🟢 " + lbl_time, color=#00c853, textcolor=color.white, style=label.style_label_up, size=lbl_sz)

if is_short
    label.new(bar_index, high * 1.0015, "🔴 " + lbl_time, color=#d50000, textcolor=color.white, style=label.style_label_down, size=lbl_sz)

// ─────────────────────────────────────────────────────────────
// EMA ЛИНИИ
// ─────────────────────────────────────────────────────────────
plot(show_ema ? ema21  : na, "EMA 21",  color=color.new(#29b6f6, 20), linewidth=1)
plot(show_ema ? ema50  : na, "EMA 50",  color=color.new(#ffb300, 20), linewidth=1)
plot(show_ema ? ema200 : na, "EMA 200", color=color.new(#ab47bc, 20), linewidth=2)

// ─────────────────────────────────────────────────────────────
// АЛЕРТЫ
// ─────────────────────────────────────────────────────────────
long_msg  = "🟢 ЛОНГ " + syminfo.ticker + " | TF: " + timeframe.period + " | Price: " + str.tostring(close, format.mintick) + " | RSI: " + str.tostring(math.round(rsi, 1)) + " | " + lbl_time
short_msg = "🔴 ШОРТ " + syminfo.ticker + " | TF: " + timeframe.period + " | Price: " + str.tostring(close, format.mintick) + " | RSI: " + str.tostring(math.round(rsi, 1)) + " | " + lbl_time

// Способ 1: alertcondition — настраиваются через UI ("Create Alert")
alertcondition(long_signal,  title="🟢 Сигнал ЛОНГ",  message="🟢 ЛОНГ {{ticker}} | {{interval}} | Price: {{close}}")
alertcondition(short_signal, title="🔴 Сигнал ШОРТ", message="🔴 ШОРТ {{ticker}} | {{interval}} | Price: {{close}}")
alertcondition(long_signal or short_signal, title="⚡ Любой сигнал", message="⚡ Сигнал {{ticker}} | {{interval}} | Price: {{close}}")

// Способ 2: alert() — автоматическая отправка (для webhook/ботов)
if use_auto_alert
    if long_signal
        alert(long_msg,  alert.freq_once_per_bar_close)
    if short_signal
        alert(short_msg, alert.freq_once_per_bar_close)

// ─────────────────────────────────────────────────────────────
// ТАБЛИЦА УСЛОВИЙ
// ─────────────────────────────────────────────────────────────
var table tbl = table.new(position.top_right, 3, 7, border_color = color.new(#37474f, 40), border_width = 1, bgcolor = color.new(#0d1117, 20))

CON = #00e676
COF = #ff1744
CHD = #42a5f5
CTX = #cfd8dc
CGR = #546e7a

cell(col, row, txt, tcol, sz2) =>
    table.cell(tbl, col, row, txt, text_color=tcol, text_size=sz2, bgcolor=color.new(#0d1117, 45))

if barstate.islast and show_table
    cell(0, 0, "TF: " + timeframe.period, CHD, size.small)
    cell(1, 0, "🟢 ЛОНГ",                 CHD, size.small)
    cell(2, 0, "🔴 ШОРТ",                 CHD, size.small)

    cell(0, 1, "EMA50 vs EMA200",       CTX, size.tiny)
    cell(1, 1, l1 ? "✓" : "✗",          l1 ? CON : COF, size.normal)
    cell(2, 1, s1 ? "✓" : "✗",          s1 ? CON : COF, size.normal)

    cell(0, 2, "Close vs EMA21",        CTX, size.tiny)
    cell(1, 2, l2 ? "✓" : "✗",          l2 ? CON : COF, size.normal)
    cell(2, 2, s2 ? "✓" : "✗",          s2 ? CON : COF, size.normal)

    cell(0, 3, "RSI cross 50",          CTX, size.tiny)
    cell(1, 3, l3 ? "✓" : "✗",          l3 ? CON : COF, size.normal)
    cell(2, 3, s3 ? "✓" : "✗",          s3 ? CON : COF, size.normal)

    cell(0, 4, "MACD hist",             CTX, size.tiny)
    cell(1, 4, l4 ? "✓" : "✗",          l4 ? CON : COF, size.normal)
    cell(2, 4, s4 ? "✓" : "✗",          s4 ? CON : COF, size.normal)

    cell(0, 5, "RSI: " + str.tostring(math.round(rsi, 1)),  CGR, size.tiny)
    cell(1, 5, "MACD h: " + str.tostring(math.round(macd_hist, 2)), CTX, size.tiny)
    cell(2, 5, ema50 > ema200 ? "Тренд ↑" : "Тренд ↓", ema50 > ema200 ? CON : COF, size.tiny)

    cell(0, 6, "═══ ИТОГ ═══",                              CHD, size.small)
    cell(1, 6, is_long  ? "● ЛОНГ"  : "—", is_long  ? CON : CGR, size.small)
    cell(2, 6, is_short ? "● ШОРТ" : "—", is_short ? COF : CGR, size.small)
````
