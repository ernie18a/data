# ticker background

- url: https://www.tradingview.com/script/g6lrq9k5-ticker-background/
- type: indicator
- pine_id: PUB;8d99070f5b29438dac317504e56a5106
- version: 1.0

## Description

Простой индикатор, в котором можно поставить 
другой тикер в качестве фона. Выбрать можно тикер, таймфрейм и порог изменения для отрисовки фона.

## Source Code

````pine
//@version=6
indicator("Универсальный фон изменения", shorttitle="Фон изменения", overlay=true)

// ==========================================
// 1. Входные параметры (вкладка "Аргументы")
// ==========================================
ticker_input = input.symbol("RUS:IRUS2", title="Тикер для фона")
tf_input = input.timeframe("D", title="Таймфрейм")

grp_thresholds = "Пороги"
pos_threshold = input.float(0.1, "больше чем", group=grp_thresholds)
neg_threshold = input.float(-0.1, "меньше чем", group=grp_thresholds)

grp_colors = "Цвета"
color_up = input.color(color.new(#00E676, 70), "Положительный", group=grp_colors)
color_down = input.color(color.new(#FF1744, 70), "Отрицательный", group=grp_colors)

// ==========================================
// 2. Получение данных и расчет
// ==========================================
[idx_close, idx_prev_close] = request.security(
    ticker_input, 
    tf_input, 
    [close, close[1]],
    lookahead=barmerge.lookahead_on
)

pct_change = na(idx_prev_close) or idx_prev_close == 0 ? 0 : ((idx_close - idx_prev_close) / idx_prev_close) * 100

// ==========================================
// 3. Логика выбора цвета фона
// ==========================================
bg_color = if na(pct_change)
    color(na)
else if pct_change >= pos_threshold
    color_up
else if pct_change <= neg_threshold
    color_down
else
    color(na)  // нейтральная зона — фон не рисуется

// ==========================================
// 4. Отрисовка фона
// ==========================================
bgcolor(bg_color, title="Фон изменения")

// ==========================================
// 5. Информационная таблица
// ==========================================
var table info_table = table.new(position.top_right, 1, 1, border_width=1)
if barstate.islast
    label_text = str.tostring(ticker_input) + ": " + str.tostring(pct_change, "#.##") + "%"
    table.cell(info_table, 0, 0, label_text, 
     bgcolor=bg_color, text_color=color.white, text_size=size.small)
````
