# Japanese Candlestick Patterns Pro

- url: https://www.tradingview.com/script/02g1MFnT-Japanese-Candlestick-Patterns-Pro/
- type: indicator
- pine_id: PUB;e8df76a005b64434a70a5af228f795b3
- version: 1.0

## Description

Japanese Candlestick Patterns Pro

Candlesticks are the language of the market. Every candle tells a story — pressure, hesitation, rejection, strength, weakness, fear, and momentum. Japanese Candlestick Patterns Pro is designed to help traders read that story faster and more clearly.

This indicator automatically detects key Japanese candlestick patterns directly on the chart, helping you identify potential reversal, continuation, and market reaction zones without manually scanning every candle.

It highlights both bullish and bearish formations, including engulfing patterns, harami, hammer, hanging man, inverted hammer, shooting star, morning star, evening star, piercing line, dark cloud cover, three white soldiers, three black crows, inside days, and outside days.

The goal of this tool is not to predict the market blindly. The goal is to bring structure to price action and help you notice moments where the balance between buyers and sellers may be changing.

Main features:

• Automatic detection of classic Japanese candlestick patterns
• Bullish and bearish pattern recognition
• Trend filter using SMA or EMA
• Optional volume filter
• Text labels, symbols, or both
• Visual table with active bullish and bearish patterns
• Alerts for key candlestick setups
• Flexible settings for body size, shadows, trend conditions, and pattern filtering

This indicator is useful for traders who want to combine traditional candlestick analysis with a more systematic approach. It can help you quickly spot important price action signals, confirm your own analysis, and avoid missing key candle formations during fast market movement.

Recommended use:

Start with higher timeframes to understand the main market direction.
Use candlestick patterns near support, resistance, liquidity zones, or trend areas.
Do not trade every signal blindly. Look for confirmation from structure, volume, and market context.
Use alerts to monitor important setups without watching the chart constantly.

Japanese Candlestick Patterns Pro is built for traders who respect price action and want to see the market with more discipline, clarity, and control.

This is not financial advice. Always use proper risk management and test the indicator on your own market, timeframe, and trading strategy.

Follow Golden_WolfAI.

## Source Code

````pine
//@version=6
indicator("Japanese Candlestick Patterns Pro", overlay=true, max_labels_count=500)

// Основные параметры
avg_period = input.int(10, "Период для среднего", minval=5, maxval=50, group="Основные")
use_atr = input.bool(true, "Использовать ATR", group="Основные")
atr_period = input.int(14, "Период ATR", minval=5, maxval=50, group="Основные")

// Длинные дни
min_body_price_percent = input.float(3.0, "Мин тело/цена %", minval=0, maxval=100, group="Длинные дни")
min_body_range_percent = input.float(60.0, "Мин тело/диапазон %", minval=0, maxval=100, group="Длинные дни")
min_body_avg_percent = input.float(150.0, "Мин тело/среднее %", minval=100, maxval=300, group="Длинные дни")

// Короткие дни
max_short_body_percent = input.float(30.0, "Макс короткое тело %", minval=0, maxval=100, group="Короткие дни")
max_doji_body_range = input.float(5.0, "Макс тело доджи %", minval=0, maxval=20, group="Короткие дни")

// Зонтики
max_body_shadow_ratio = input.float(40.0, "Макс тело/тень %", minval=0, maxval=100, group="Зонтики")
min_shadow_body_ratio = input.float(200.0, "Мин тень/тело %", minval=100, maxval=500, group="Зонтики")

// Фильтры
use_trend_filter = input.bool(true, "Использовать фильтр тренда", group="Фильтры")
ma_type = input.string("SMA", "Тип MA", options=["SMA", "EMA"], group="Фильтры")
trend_ma_period = input.int(50, "Период MA", minval=9, maxval=200, group="Фильтры")
use_volume_filter = input.bool(false, "Фильтр объема", group="Фильтры")
volume_threshold = input.float(120.0, "Мин объем %", minval=50, maxval=300, group="Фильтры")

// Визуализация
show_labels = input.bool(true, "Текстовые метки", group="Визуализация")
show_shapes = input.bool(true, "Фигуры", group="Визуализация")
show_table = input.bool(true, "Таблица", group="Визуализация")
show_label_type = input.string("Текст", "Тип меток", options=["Текст", "Символы", "Оба"], group="Визуализация")

// Паттерны
show_engulfing = input.bool(true, "Поглощение", group="Паттерны")
show_harami = input.bool(true, "Харами", group="Паттерны")
show_hammer = input.bool(true, "Молот/Висельник", group="Паттерны")
show_star = input.bool(true, "Звезды", group="Паттерны")
show_piercing = input.bool(true, "Пронзающая/Завеса", group="Паттерны")
show_soldiers = input.bool(true, "Солдаты/Вороны", group="Паттерны")
show_inside_days = input.bool(true, "Дни изнутри", group="Паттерны")
show_outside_days = input.bool(true, "Внешние дни", group="Паттерны")

// Функции
get_body() => math.abs(close - open)
get_range() => high - low
get_upper_shadow() => high - math.max(open, close)
get_lower_shadow() => math.min(open, close) - low
is_bullish() => close > open
is_bearish() => close < open
get_body_mid() => (open + close) / 2

// Расчеты
avg_body = ta.sma(get_body(), avg_period)
atr_value = ta.atr(atr_period)
trend_ma = ma_type == "SMA" ? ta.sma(close, trend_ma_period) : ta.ema(close, trend_ma_period)
is_uptrend = close > trend_ma
is_downtrend = close < trend_ma
avg_volume = ta.sma(volume, 20)
is_high_volume = volume > (avg_volume * volume_threshold / 100)

// Отображение MA на графике
plot(use_trend_filter ? trend_ma : na, "Trend MA", color=color.new(color.yellow, 0), linewidth=2)

// Базовые элементы
is_long_day = (get_body() / close) * 100 >= min_body_price_percent and (get_body() / get_range()) * 100 >= min_body_range_percent and (get_body() / avg_body) * 100 >= min_body_avg_percent
is_short_day = (get_body() / get_range()) * 100 <= max_short_body_percent
is_doji = (get_body() / get_range()) * 100 <= max_doji_body_range and get_range() > 0

// Паттерны
bullish_engulfing = is_bearish()[1] and is_bullish() and open <= close[1] and close > open[1] and get_body() > get_body()[1] * 1.1 and (not use_trend_filter or is_downtrend[1]) and (not use_volume_filter or is_high_volume)

bearish_engulfing = is_bullish()[1] and is_bearish() and open >= close[1] and close < open[1] and get_body() > get_body()[1] * 1.1 and (not use_trend_filter or is_uptrend[1]) and (not use_volume_filter or is_high_volume)

bullish_harami = is_bearish()[1] and is_bullish() and open > close[1] and close < open[1] and get_body() < get_body()[1] * 0.5 and is_long_day[1] and (not use_trend_filter or is_downtrend[1])

bearish_harami = is_bullish()[1] and is_bearish() and open < close[1] and close > open[1] and get_body() < get_body()[1] * 0.5 and is_long_day[1] and (not use_trend_filter or is_uptrend[1])

is_hammer_shape = get_lower_shadow() > get_body() * (min_shadow_body_ratio / 100) and get_upper_shadow() < get_range() * 0.2 and get_range() > avg_body * 0.3 and get_body() > 0

hammer = is_hammer_shape and (not use_trend_filter or is_downtrend)

hanging_man = is_hammer_shape and (not use_trend_filter or is_uptrend)

is_inverted_shape = get_upper_shadow() > get_body() * (min_shadow_body_ratio / 100) and get_lower_shadow() < get_range() * 0.2 and get_range() > avg_body * 0.3 and get_body() > 0

inverted_hammer = is_inverted_shape and (not use_trend_filter or is_downtrend)

shooting_star = is_inverted_shape and (not use_trend_filter or is_uptrend)

morning_star = is_bearish()[2] and get_body()[2] > avg_body and is_short_day[1] and close[1] < close[2] and is_bullish() and close > close[1] and (not use_trend_filter or is_downtrend[2])

evening_star = is_bullish()[2] and get_body()[2] > avg_body and is_short_day[1] and close[1] > close[2] and is_bearish() and close < close[1] and (not use_trend_filter or is_uptrend[2])

piercing_line = is_bearish()[1] and get_body()[1] > avg_body * 0.8 and is_bullish() and open < close[1] and close > get_body_mid()[1] and close < open[1] and (not use_trend_filter or is_downtrend[1])

dark_cloud = is_bullish()[1] and get_body()[1] > avg_body * 0.8 and is_bearish() and open > close[1] and close < get_body_mid()[1] and close > open[1] and (not use_trend_filter or is_uptrend[1])

three_white_soldiers = is_bullish() and is_bullish()[1] and is_bullish()[2] and close > close[1] and close[1] > close[2] and open > open[1] and open[1] > open[2] and open < close[1] and open[1] < close[2] and get_body() > avg_body * 0.6 and get_body()[1] > avg_body * 0.6 and get_body()[2] > avg_body * 0.6 and (not use_trend_filter or is_downtrend[2])

three_black_crows = is_bearish() and is_bearish()[1] and is_bearish()[2] and close < close[1] and close[1] < close[2] and open < open[1] and open[1] < open[2] and open > close[1] and open[1] > close[2] and get_body() > avg_body * 0.6 and get_body()[1] > avg_body * 0.6 and get_body()[2] > avg_body * 0.6 and (not use_trend_filter or is_uptrend[2])

// Новые паттерны
three_inside_up = is_bearish()[2] and is_long_day[2] and is_bullish()[1] and high[1] < high[2] and low[1] > low[2] and open[1] > close[2] and close[1] < open[2] and is_bullish() and close > high[2] and (not use_trend_filter or is_downtrend[2])

three_inside_down = is_bullish()[2] and is_long_day[2] and is_bearish()[1] and high[1] < high[2] and low[1] > low[2] and open[1] < close[2] and close[1] > open[2] and is_bearish() and close < low[2] and (not use_trend_filter or is_uptrend[2])

three_outside_up = is_bearish()[2] and is_bullish()[1] and open[1] < close[2] and close[1] > open[2] and high[1] > high[2] and low[1] < low[2] and is_bullish() and close > close[1] and (not use_trend_filter or is_downtrend[2])

three_outside_down = is_bullish()[2] and is_bearish()[1] and open[1] > close[2] and close[1] < open[2] and high[1] > high[2] and low[1] < low[2] and is_bearish() and close < close[1] and (not use_trend_filter or is_uptrend[2])

// Визуализация
plotshape(show_shapes and show_engulfing and bullish_engulfing and show_label_type != "Текст", "Бычье поглощение", shape.triangleup, location.belowbar, color.new(color.green, 0), size=size.small)
plotshape(show_shapes and show_engulfing and bearish_engulfing and show_label_type != "Текст", "Медвежье поглощение", shape.triangledown, location.abovebar, color.new(color.red, 0), size=size.small)
plotshape(show_shapes and show_harami and bullish_harami and show_label_type != "Текст", "Бычья харами", shape.diamond, location.belowbar, color.new(color.lime, 0), size=size.tiny)
plotshape(show_shapes and show_harami and bearish_harami and show_label_type != "Текст", "Медвежья харами", shape.diamond, location.abovebar, color.new(color.maroon, 0), size=size.tiny)
plotshape(show_shapes and show_hammer and hammer and show_label_type != "Текст", "Молот", shape.circle, location.belowbar, color.new(color.aqua, 0), size=size.tiny)
plotshape(show_shapes and show_hammer and hanging_man and show_label_type != "Текст", "Висельник", shape.circle, location.abovebar, color.new(color.orange, 0), size=size.tiny)
plotshape(show_shapes and show_hammer and inverted_hammer and show_label_type != "Текст", "Перевернутый молот", shape.square, location.belowbar, color.new(color.blue, 0), size=size.tiny)
plotshape(show_shapes and show_hammer and shooting_star and show_label_type != "Текст", "Падающая звезда", shape.square, location.abovebar, color.new(color.purple, 0), size=size.tiny)
plotshape(show_shapes and show_star and morning_star and show_label_type != "Текст", "Утренняя звезда", shape.labelup, location.belowbar, color.new(color.green, 0), text="MS", size=size.small)
plotshape(show_shapes and show_star and evening_star and show_label_type != "Текст", "Вечерняя звезда", shape.labeldown, location.abovebar, color.new(color.red, 0), text="ES", size=size.small)
plotshape(show_shapes and show_piercing and piercing_line and show_label_type != "Текст", "Пронзающая", shape.cross, location.belowbar, color.new(color.teal, 0), size=size.small)
plotshape(show_shapes and show_piercing and dark_cloud and show_label_type != "Текст", "Завеса", shape.cross, location.abovebar, color.new(color.fuchsia, 0), size=size.small)
plotshape(show_shapes and show_soldiers and three_white_soldiers and show_label_type != "Текст", "3 солдата", shape.labelup, location.belowbar, color.new(color.lime, 0), text="3W", size=size.small)
plotshape(show_shapes and show_soldiers and three_black_crows and show_label_type != "Текст", "3 вороны", shape.labeldown, location.abovebar, color.new(color.red, 0), text="3B", size=size.small)
plotshape(show_shapes and show_inside_days and three_inside_up and show_label_type != "Текст", "3 изнутри вверх", shape.arrowup, location.belowbar, color.new(color.green, 0), text="3IU", size=size.small)
plotshape(show_shapes and show_inside_days and three_inside_down and show_label_type != "Текст", "3 изнутри вниз", shape.arrowdown, location.abovebar, color.new(color.red, 0), text="3ID", size=size.small)
plotshape(show_shapes and show_outside_days and three_outside_up and show_label_type != "Текст", "3 снаружи вверх", shape.flag, location.belowbar, color.new(color.lime, 0), text="3OU", size=size.small)
plotshape(show_shapes and show_outside_days and three_outside_down and show_label_type != "Текст", "3 снаружи вниз", shape.flag, location.abovebar, color.new(color.maroon, 0), text="3OD", size=size.small)

// Метки
if show_labels and show_label_type != "Символы"
    if bullish_engulfing and show_engulfing
        label.new(bar_index, low, "Бычье поглощение", style=label.style_label_up, color=color.green, textcolor=color.white, size=size.small)
    if bearish_engulfing and show_engulfing
        label.new(bar_index, high, "Медвежье поглощение", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)
    if bullish_harami and show_harami
        label.new(bar_index, low, "Бычья харами", style=label.style_label_up, color=color.lime, textcolor=color.black, size=size.small)
    if bearish_harami and show_harami
        label.new(bar_index, high, "Медвежья харами", style=label.style_label_down, color=color.maroon, textcolor=color.white, size=size.small)
    if hammer and show_hammer
        label.new(bar_index, low, "Молот", style=label.style_label_up, color=color.aqua, textcolor=color.black, size=size.small)
    if hanging_man and show_hammer
        label.new(bar_index, high, "Висельник", style=label.style_label_down, color=color.orange, textcolor=color.white, size=size.small)
    if inverted_hammer and show_hammer
        label.new(bar_index, low, "Перевернутый молот", style=label.style_label_up, color=color.blue, textcolor=color.white, size=size.small)
    if shooting_star and show_hammer
        label.new(bar_index, high, "Падающая звезда", style=label.style_label_down, color=color.purple, textcolor=color.white, size=size.small)
    if morning_star and show_star
        label.new(bar_index, low, "Утренняя звезда", style=label.style_label_up, color=color.green, textcolor=color.white, size=size.small)
    if evening_star and show_star
        label.new(bar_index, high, "Вечерняя звезда", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)
    if piercing_line and show_piercing
        label.new(bar_index, low, "Пронзающая линия", style=label.style_label_up, color=color.teal, textcolor=color.white, size=size.small)
    if dark_cloud and show_piercing
        label.new(bar_index, high, "Завеса облаков", style=label.style_label_down, color=color.fuchsia, textcolor=color.white, size=size.small)
    if three_white_soldiers and show_soldiers
        label.new(bar_index, low, "3 белых солдата", style=label.style_label_up, color=color.lime, textcolor=color.black, size=size.small)
    if three_black_crows and show_soldiers
        label.new(bar_index, high, "3 черные вороны", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)
    if three_inside_up and show_inside_days
        label.new(bar_index, low, "3 дня изнутри вверх", style=label.style_label_up, color=color.green, textcolor=color.white, size=size.small)
    if three_inside_down and show_inside_days
        label.new(bar_index, high, "3 дня изнутри вниз", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)
    if three_outside_up and show_outside_days
        label.new(bar_index, low, "3 внешних дня вверх", style=label.style_label_up, color=color.lime, textcolor=color.black, size=size.small)
    if three_outside_down and show_outside_days
        label.new(bar_index, high, "3 внешних дня вниз", style=label.style_label_down, color=color.maroon, textcolor=color.white, size=size.small)

// Таблица
if show_table
    var table info_table = table.new(position.top_right, 3, 13, bgcolor=color.new(color.white, 10), border_width=2, border_color=color.gray, frame_width=1, frame_color=color.gray)
    if barstate.islast
        table.cell(info_table, 0, 0, "📊 ПАТТЕРНЫ", bgcolor=color.new(color.gray, 20), text_color=color.white, text_size=size.normal)
        table.cell(info_table, 1, 0, "🟢 БЫЧИЙ", bgcolor=color.new(color.green, 40), text_color=color.white, text_size=size.normal)
        table.cell(info_table, 2, 0, "🔴 МЕДВЕЖИЙ", bgcolor=color.new(color.red, 40), text_color=color.white, text_size=size.normal)

        table.cell(info_table, 0, 1, "Поглощение", text_size=size.normal)
        table.cell(info_table, 1, 1, bullish_engulfing ? "✓ ДА" : "-", bgcolor=bullish_engulfing ? color.new(color.green, 60) : color.new(color.white, 80), text_color=bullish_engulfing ? color.white : color.gray, text_size=size.normal)
        table.cell(info_table, 2, 1, bearish_engulfing ? "✓ ДА" : "-", bgcolor=bearish_engulfing ? color.new(color.red, 60) : color.new(color.white, 80), text_color=bearish_engulfing ? color.white : color.gray, text_size=size.normal)

        table.cell(info_table, 0, 2, "Харами", text_size=size.normal)
        table.cell(info_table, 1, 2, bullish_harami ? "✓ ДА" : "-", bgcolor=bullish_harami ? color.new(color.green, 60) : color.new(color.white, 80), text_color=bullish_harami ? color.white : color.gray, text_size=size.normal)
        table.cell(info_table, 2, 2, bearish_harami ? "✓ ДА" : "-", bgcolor=bearish_harami ? color.new(color.red, 60) : color.new(color.white, 80), text_color=bearish_harami ? color.white : color.gray, text_size=size.normal)

        table.cell(info_table, 0, 3, "Молот", text_size=size.normal)
        table.cell(info_table, 1, 3, hammer ? "✓ ДА" : "-", bgcolor=hammer ? color.new(color.green, 60) : color.new(color.white, 80), text_color=hammer ? color.white : color.gray, text_size=size.normal)
        table.cell(info_table, 2, 3, hanging_man ? "✓ ДА" : "-", bgcolor=hanging_man ? color.new(color.red, 60) : color.new(color.white, 80), text_color=hanging_man ? color.white : color.gray, text_size=size.normal)

        table.cell(info_table, 0, 4, "Перев. молот", text_size=size.normal)
        table.cell(info_table, 1, 4, inverted_hammer ? "✓ ДА" : "-", bgcolor=inverted_hammer ? color.new(color.green, 60) : color.new(color.white, 80), text_color=inverted_hammer ? color.white : color.gray, text_size=size.normal)
        table.cell(info_table, 2, 4, shooting_star ? "✓ ДА" : "-", bgcolor=shooting_star ? color.new(color.red, 60) : color.new(color.white, 80), text_color=shooting_star ? color.white : color.gray, text_size=size.normal)

        table.cell(info_table, 0, 5, "Звезда", text_size=size.normal)
        table.cell(info_table, 1, 5, morning_star ? "✓ ДА" : "-", bgcolor=morning_star ? color.new(color.green, 60) : color.new(color.white, 80), text_color=morning_star ? color.white : color.gray, text_size=size.normal)
        table.cell(info_table, 2, 5, evening_star ? "✓ ДА" : "-", bgcolor=evening_star ? color.new(color.red, 60) : color.new(color.white, 80), text_color=evening_star ? color.white : color.gray, text_size=size.normal)

        table.cell(info_table, 0, 6, "Пронзающая", text_size=size.normal)
        table.cell(info_table, 1, 6, piercing_line ? "✓ ДА" : "-", bgcolor=piercing_line ? color.new(color.green, 60) : color.new(color.white, 80), text_color=piercing_line ? color.white : color.gray, text_size=size.normal)
        table.cell(info_table, 2, 6, dark_cloud ? "✓ ДА" : "-", bgcolor=dark_cloud ? color.new(color.red, 60) : color.new(color.white, 80), text_color=dark_cloud ? color.white : color.gray, text_size=size.normal)

        table.cell(info_table, 0, 7, "3 Солдата", text_size=size.normal)
        table.cell(info_table, 1, 7, three_white_soldiers ? "✓ ДА" : "-", bgcolor=three_white_soldiers ? color.new(color.green, 60) : color.new(color.white, 80), text_color=three_white_soldiers ? color.white : color.gray, text_size=size.normal)
        table.cell(info_table, 2, 7, three_black_crows ? "✓ ДА" : "-", bgcolor=three_black_crows ? color.new(color.red, 60) : color.new(color.white, 80), text_color=three_black_crows ? color.white : color.gray, text_size=size.normal)

        table.cell(info_table, 0, 8, "3 изнутри", text_size=size.normal)
        table.cell(info_table, 1, 8, three_inside_up ? "✓ ДА" : "-", bgcolor=three_inside_up ? color.new(color.green, 60) : color.new(color.white, 80), text_color=three_inside_up ? color.white : color.gray, text_size=size.normal)
        table.cell(info_table, 2, 8, three_inside_down ? "✓ ДА" : "-", bgcolor=three_inside_down ? color.new(color.red, 60) : color.new(color.white, 80), text_color=three_inside_down ? color.white : color.gray, text_size=size.normal)

        table.cell(info_table, 0, 9, "3 снаружи", text_size=size.normal)
        table.cell(info_table, 1, 9, three_outside_up ? "✓ ДА" : "-", bgcolor=three_outside_up ? color.new(color.green, 60) : color.new(color.white, 80), text_color=three_outside_up ? color.white : color.gray, text_size=size.normal)
        table.cell(info_table, 2, 9, three_outside_down ? "✓ ДА" : "-", bgcolor=three_outside_down ? color.new(color.red, 60) : color.new(color.white, 80), text_color=three_outside_down ? color.white : color.gray, text_size=size.normal)

        table.cell(info_table, 0, 10, "───────────", text_color=color.gray, text_size=size.small)
        table.cell(info_table, 1, 10, "───────", text_color=color.gray, text_size=size.small)
        table.cell(info_table, 2, 10, "───────", text_color=color.gray, text_size=size.small)

        total_bullish = (bullish_engulfing ? 1 : 0) + (bullish_harami ? 1 : 0) + (hammer ? 1 : 0) + (inverted_hammer ? 1 : 0) + (morning_star ? 1 : 0) + (piercing_line ? 1 : 0) + (three_white_soldiers ? 1 : 0) + (three_inside_up ? 1 : 0) + (three_outside_up ? 1 : 0)
        total_bearish = (bearish_engulfing ? 1 : 0) + (bearish_harami ? 1 : 0) + (hanging_man ? 1 : 0) + (shooting_star ? 1 : 0) + (evening_star ? 1 : 0) + (dark_cloud ? 1 : 0) + (three_black_crows ? 1 : 0) + (three_inside_down ? 1 : 0) + (three_outside_down ? 1 : 0)

        table.cell(info_table, 0, 11, "ВСЕГО:", bgcolor=color.new(color.gray, 30), text_color=color.white, text_size=size.normal)
        table.cell(info_table, 1, 11, str.tostring(total_bullish), bgcolor=total_bullish > 0 ? color.new(color.green, 50) : color.new(color.white, 80), text_color=total_bullish > 0 ? color.white : color.gray, text_size=size.large)
        table.cell(info_table, 2, 11, str.tostring(total_bearish), bgcolor=total_bearish > 0 ? color.new(color.red, 50) : color.new(color.white, 80), text_color=total_bearish > 0 ? color.white : color.gray, text_size=size.large)

// Алерты
alertcondition(bullish_engulfing, "Бычье поглощение", "Обнаружено бычье поглощение")
alertcondition(bearish_engulfing, "Медвежье поглощение", "Обнаружено медвежье поглощение")
alertcondition(morning_star, "Утренняя звезда", "Обнаружена утренняя звезда")
alertcondition(evening_star, "Вечерняя звезда", "Обнаружена вечерняя звезда")
alertcondition(three_white_soldiers, "3 белых солдата", "Обнаружены 3 белых солдата")
alertcondition(three_black_crows, "3 черные вороны", "Обнаружены 3 черные вороны")
alertcondition(hammer, "Молот", "Обнаружен молот")
alertcondition(hanging_man, "Висельник", "Обнаружен висельник")
alertcondition(three_inside_up, "3 дня изнутри вверх", "Обнаружены 3 дня изнутри вверх")
alertcondition(three_inside_down, "3 дня изнутри вниз", "Обнаружены 3 дня изнутри вниз")
alertcondition(three_outside_up, "3 внешних дня вверх", "Обнаружены 3 внешних дня вверх")
alertcondition(three_outside_down, "3 внешних дня вниз", "Обнаружены 3 внешних дня вниз")
````
