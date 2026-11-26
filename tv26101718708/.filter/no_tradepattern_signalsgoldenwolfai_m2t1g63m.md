# NO TRADE_Pattern Signals[Golden_WolfAI]

- url: https://www.tradingview.com/script/m2t1G63m-no-trade-pattern-signals-golden-wolfai/
- type: indicator
- pine_id: PUB;95be3ad30082484892bb39622ef430a0
- version: 1.0

## Description

Golden_WolfAI — NO TRADE → Pattern Signals

This indicator looks for trading signals only after price exits the NO TRADE zone.

How it works:

1. NO TRADE zone
   The indicator builds a zone around VWAP using standard deviation. While price remains inside this zone, the market is considered neutral, and no signals are generated.

2. Exit from NO TRADE
   A signal can appear only when price exits the NO TRADE zone. This helps filter out sideways market conditions and low-directional movement.

3. Trend filter
   A moving average is used as a trend filter. The user can choose between SMA and EMA.
   LONG signals are allowed only when price is above the MA.
   SHORT signals are allowed only when price is below the MA.

4. Candlestick patterns
   The indicator checks several candlestick formations:

• Engulfing
• Harami
• Hammer / Hanging Man
• Morning Star / Evening Star
• Piercing Line / Dark Cloud Cover
• REB
• Sweep
• Body Dominance

Each pattern type can be enabled or disabled in the settings.

5. Signal conditions
   A LONG signal appears when price exits the NO TRADE zone, a bullish pattern is detected, and price is above the MA.
   A SHORT signal appears when price exits the NO TRADE zone, a bearish pattern is detected, and price is below the MA.

The indicator displays:

• VWAP
• Upper and lower NO TRADE zone boundaries
• Moving Average
• LONG and SHORT labels
• A table showing market status, trend direction, and current signal

The script also includes alert conditions for LONG and SHORT signals, allowing users to create TradingView alerts.

Important: this is an indicator, not a strategy. It does not open or close trades and is not designed for direct backtesting in the Strategy Tester. Signals should be used as an analytical tool and require additional confirmation before making trading decisions.

Subscribe to Golden_WolfAI

## Source Code

````pine
// This Pine Script® code is proprietary and confidential.
// Unauthorized copying, modification, redistribution, publication, or commercial use is prohibited.
//
// © 2026 Golden_WolfAI. All rights reserved.

//@version=6
indicator("Golden_WolfAI — NO TRADE → Pattern Signals", overlay=true, max_labels_count=500)

//========================================================
// NO TRADE ЗОНА
//========================================================
use_no_trade = input.bool(true, "NO TRADE: включить", group="NO TRADE")
nt_src       = input.source(hlc3, "Источник VWAP", group="NO TRADE")
nt_band_len  = input.int(30, "Длина stdev", minval=5, maxval=200, group="NO TRADE")
nt_band_mult = input.float(1.0, "Множитель полос", minval=0.2, maxval=5.0, group="NO TRADE")

//========================================================
// ТРЕНД MA
//========================================================
ma_type         = input.string("EMA", "Тип MA", options=["SMA", "EMA"], group="Тренд")
trend_ma_period = input.int(50, "Период MA", minval=9, maxval=200, group="Тренд")

//========================================================
// ПАТТЕРНЫ
//========================================================
show_engulfing = input.bool(true, "Поглощение", group="Паттерны")
show_harami    = input.bool(true, "Харами", group="Паттерны")
show_hammer    = input.bool(true, "Молот/Висельник", group="Паттерны")
show_star      = input.bool(true, "Звезды", group="Паттерны")
show_piercing  = input.bool(true, "Пронзающая/Завеса", group="Паттерны")
show_reb       = input.bool(true, "REB", group="Паттерны")
show_sweep     = input.bool(true, "Sweep", group="Паттерны")
show_bodydom   = input.bool(true, "Body Dominance", group="Паттерны")

//========================================================
// БАЗОВЫЕ РАСЧЁТЫ
//========================================================
atr_period = 14
atr_value  = ta.atr(atr_period)

get_body()         => math.abs(close - open)
get_range()        => high - low
get_upper_shadow() => high - math.max(open, close)
get_lower_shadow() => math.min(open, close) - low
is_bullish()       => close > open
is_bearish()       => close < open
get_body_mid()     => (open + close) / 2

body_ref = atr_value

trend_ma     = ma_type == "SMA" ? ta.sma(close, trend_ma_period) : ta.ema(close, trend_ma_period)
is_uptrend   = close > trend_ma
is_downtrend = close < trend_ma

plot(trend_ma, "MA", color=color.new(color.yellow, 0), linewidth=2)

//========================================================
// NO TRADE ЗОНА
//========================================================
vwap  = ta.vwap(nt_src)
dev   = ta.stdev(nt_src - vwap, nt_band_len)
upper = vwap + nt_band_mult * dev
lower = vwap - nt_band_mult * dev

no_trade      = use_no_trade and close <= upper and close >= lower
exit_no_trade = no_trade[1] and not no_trade

pU = plot(use_no_trade ? upper : na, "NO TRADE upper", color=color.new(color.lime, 0))
pL = plot(use_no_trade ? lower : na, "NO TRADE lower", color=color.new(color.lime, 0))
fill(pU, pL, color=use_no_trade ? color.new(color.lime, 85) : na)

plot(vwap, "VWAP", color=color.new(color.blue, 0), linewidth=1)

bgcolor(exit_no_trade ? color.new(color.lime, 85) : na)

//========================================================
// ПАТТЕРНЫ
//========================================================
min_body_price_percent = 3.0
min_body_range_percent = 60.0
min_body_avg_percent   = 150.0
max_short_body_percent = 30.0
min_shadow_body_ratio  = 200.0

is_long_day =
     (get_body() / close) * 100 >= min_body_price_percent and
     (get_body() / get_range()) * 100 >= min_body_range_percent and
     (get_body() / body_ref) * 100 >= min_body_avg_percent

is_short_day = (get_body() / get_range()) * 100 <= max_short_body_percent

bullish_engulfing_raw =
     is_bearish()[1] and is_bullish() and
     open <= close[1] and close > open[1] and
     get_body() > get_body()[1] * 1.1 and is_downtrend[1]

bearish_engulfing_raw =
     is_bullish()[1] and is_bearish() and
     open >= close[1] and close < open[1] and
     get_body() > get_body()[1] * 1.1 and is_uptrend[1]

bullish_harami_raw =
     is_bearish()[1] and is_bullish() and
     open > close[1] and close < open[1] and
     get_body() < get_body()[1] * 0.5 and is_long_day[1] and is_downtrend[1]

bearish_harami_raw =
     is_bullish()[1] and is_bearish() and
     open < close[1] and close > open[1] and
     get_body() < get_body()[1] * 0.5 and is_long_day[1] and is_uptrend[1]

is_hammer_shape =
     get_lower_shadow() > get_body() * (min_shadow_body_ratio / 100.0) and
     get_upper_shadow() < get_range() * 0.2 and
     get_range() > body_ref * 0.3 and get_body() > 0

hammer_raw      = is_hammer_shape and is_downtrend
hanging_man_raw = is_hammer_shape and is_uptrend

is_inverted_shape =
     get_upper_shadow() > get_body() * (min_shadow_body_ratio / 100.0) and
     get_lower_shadow() < get_range() * 0.2 and
     get_range() > body_ref * 0.3 and get_body() > 0

inverted_hammer_raw = is_inverted_shape and is_downtrend
shooting_star_raw   = is_inverted_shape and is_uptrend

morning_star_raw =
     is_bearish()[2] and get_body()[2] > body_ref[2] and
     is_short_day[1] and close[1] < close[2] and
     is_bullish() and close > close[1] and is_downtrend[2]

evening_star_raw =
     is_bullish()[2] and get_body()[2] > body_ref[2] and
     is_short_day[1] and close[1] > close[2] and
     is_bearish() and close < close[1] and is_uptrend[2]

piercing_line_raw =
     is_bearish()[1] and get_body()[1] > body_ref[1] * 0.8 and
     is_bullish() and open < close[1] and
     close > get_body_mid()[1] and close < open[1] and is_downtrend[1]

dark_cloud_raw =
     is_bullish()[1] and get_body()[1] > body_ref[1] * 0.8 and
     is_bearish() and open > close[1] and
     close < get_body_mid()[1] and close > open[1] and is_uptrend[1]

avg_range    = ta.sma(get_range(), 20)
reb_mult     = 1.5
is_reb_range = get_range() > avg_range * reb_mult

bullish_reb_raw =
     is_reb_range and is_bullish() and
     close >= high - get_range() / 3.0 and is_uptrend

bearish_reb_raw =
     is_reb_range and is_bearish() and
     close <= low + get_range() / 3.0 and is_downtrend

sweep_lookback = 5
highest_prev   = ta.highest(high[1], sweep_lookback)
lowest_prev    = ta.lowest(low[1], sweep_lookback)

bullish_sweep_raw = low < lowest_prev and close > lowest_prev and is_bullish() and is_downtrend
bearish_sweep_raw = high > highest_prev and close < highest_prev and is_bearish() and is_uptrend

body_dom_percent = 70.0
body_ratio       = get_range() > 0 ? (get_body() / get_range()) * 100.0 : 0.0

bullish_bodydom_raw = is_bullish() and body_ratio >= body_dom_percent
bearish_bodydom_raw = is_bearish() and body_ratio >= body_dom_percent

//========================================================
// АГРЕГАТЫ СИГНАЛОВ
//========================================================
any_bull_raw =
     (show_engulfing and bullish_engulfing_raw) or
     (show_harami    and bullish_harami_raw) or
     (show_hammer    and hammer_raw) or
     (show_hammer    and inverted_hammer_raw) or
     (show_star      and morning_star_raw) or
     (show_piercing  and piercing_line_raw) or
     (show_reb       and bullish_reb_raw) or
     (show_sweep     and bullish_sweep_raw) or
     (show_bodydom   and bullish_bodydom_raw)

any_bear_raw =
     (show_engulfing and bearish_engulfing_raw) or
     (show_harami    and bearish_harami_raw) or
     (show_hammer    and hanging_man_raw) or
     (show_hammer    and shooting_star_raw) or
     (show_star      and evening_star_raw) or
     (show_piercing  and dark_cloud_raw) or
     (show_reb       and bearish_reb_raw) or
     (show_sweep     and bearish_sweep_raw) or
     (show_bodydom   and bearish_bodydom_raw)

//========================================================
// СИГНАЛЫ
//========================================================
long_signal  = exit_no_trade and any_bull_raw and is_uptrend
short_signal = exit_no_trade and any_bear_raw and is_downtrend

//========================================================
// ВИЗУАЛИЗАЦИЯ
//========================================================
plotshape(long_signal, "Long Signal", shape.triangleup, location.belowbar, color.new(color.green, 0), size=size.normal, text="LONG")
plotshape(short_signal, "Short Signal", shape.triangledown, location.abovebar, color.new(color.red, 0), size=size.normal, text="SHORT")

//========================================================
// ТАБЛИЦА
//========================================================
var table info = table.new(position.top_right, 2, 3, bgcolor=color.new(color.black, 0), border_width=1)

if barstate.islast
    table.cell(info, 0, 0, "STATUS", text_color=color.white, bgcolor=color.new(color.gray, 50))
    table.cell(info, 1, 0, no_trade ? "NO TRADE" : "TRADE OK", text_color=color.white, bgcolor=no_trade ? color.new(color.red, 30) : color.new(color.lime, 30))

    table.cell(info, 0, 1, "TREND", text_color=color.white)
    table.cell(info, 1, 1, is_uptrend ? "UP" : is_downtrend ? "DOWN" : "FLAT", text_color=color.white, bgcolor=is_uptrend ? color.new(color.green, 70) : is_downtrend ? color.new(color.red, 70) : color.new(color.gray, 70))

    table.cell(info, 0, 2, "SIGNAL", text_color=color.white)
    table.cell(info, 1, 2, long_signal ? "LONG" : short_signal ? "SHORT" : "-", text_color=long_signal ? color.lime : short_signal ? color.red : color.white)

//========================================================
// АЛЕРТЫ
//========================================================
alertcondition(long_signal, "Long Signal", "LONG: Exit NO TRADE + Pattern")
alertcondition(short_signal, "Short Signal", "SHORT: Exit NO TRADE + Pattern")
````
