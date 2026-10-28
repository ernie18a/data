# Yield Curve Regimes

- url: https://www.tradingview.com/script/9U4xJ3Za-Yield-Curve-Regimes/
- type: indicator
- pine_id: PUB;7aeef1de06d44bf8816692bf293f33a6
- version: 1.0

## Description

Yield Curve Regimes Indicator

This indicator tracks macroeconomic market regimes by analyzing the spread delta between short-term (US02Y) and long-term (US30Y) Treasury yields over a custom n-period rolling window.

Core Mechanics:

Regime Classification: Automatically categorizes the yield curve environment into six distinct macro states (Bull/Bear Steepener, Bull/Bear Flattener, and Steepener/Flattener Twists) based on the directional shifts of the underlying yields.

Visual Output: Plots a color-coded spread histogram with an integrated dynamic legend, providing an immediate read on shifting macro and liquidity conditions.

Application: Delivers quantifiable, high-level data to filter directional bias and align price action setups with the overarching macroeconomic regime

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © alxest

//@version=6
indicator("Yield Curve Regimes", shorttitle="YC Regimes", overlay=false)

// --- Входные параметры ---
sym_short = input.symbol("TVC:US02Y", "Short-term Yield")
sym_long  = input.symbol("TVC:US30Y", "Long-term Yield")
n         = input.int(30, "Lookback Period (n)")

// --- Получение данных ---
short_y = request.security(sym_short, timeframe.period, close)
long_y  = request.security(sym_long, timeframe.period, close)

// --- Вычисления ---
// На графике отображается спред: короткие минус длинные (согласно легенде скрина)
plot_spread = short_y - long_y

// Для логики режимов используется классический спред (Long - Short)
spread = long_y - short_y

// Изменение доходности за n периодов
d_short  = short_y - short_y[n]
d_long   = long_y - long_y[n]
d_spread = spread - spread[n]

// --- Логика режимов ---
bool is_steepener = d_spread > 0
bool is_flattener = d_spread < 0

// Steepeners (Увеличение спреда)
bool bull_steepener  = is_steepener and d_short < 0 and d_long <= 0
bool bear_steepener  = is_steepener and d_short >= 0 and d_long > 0
bool steepener_twist = is_steepener and d_short < 0 and d_long > 0

// Flatteners (Уменьшение спреда)
bool bull_flattener  = is_flattener and d_short < 0 and d_long <= 0
bool bear_flattener  = is_flattener and d_short >= 0 and d_long > 0
bool flattener_twist = is_flattener and d_short > 0 and d_long < 0

// --- Цветовая схема (в соответствии с легендой) ---
color col_bull_steep  = #2196F3 // Синий
color col_bear_steep  = #FF9800 // Оранжевый
color col_steep_twist = #4CAF50 // Зеленый
color col_bull_flat   = #F44336 // Красный
color col_bear_flat   = #7E57C2 // Темно-фиолетовый
color col_flat_twist  = #AB47BC // Светло-фиолетовый/Розовый
color col_neutral     = color.gray

color bar_color = col_neutral
if bull_steepener
    bar_color := col_bull_steep
else if bear_steepener
    bar_color := col_bear_steep
else if steepener_twist
    bar_color := col_steep_twist
else if bull_flattener
    bar_color := col_bull_flat
else if bear_flattener
    bar_color := col_bear_flat
else if flattener_twist
    bar_color := col_flat_twist

// --- Отрисовка гистограммы ---
plot(plot_spread, title="Spread", style=plot.style_columns, color=bar_color)

// --- Кастомная таблица-легенда ---
var table legend = table.new(position.top_right, 1, 7, border_width=1, border_color=#363A45)
if barstate.islast
    table.cell(legend, 0, 0, "TVC:US02Y - TVC:US30Y | n = " + str.tostring(n), text_color=color.white, bgcolor=#1E222D, text_size=size.small)
    table.cell(legend, 0, 1, "Bull Steepener",  text_color=col_bull_steep,  bgcolor=#1E222D, text_size=size.small)
    table.cell(legend, 0, 2, "Bear Steepener",  text_color=col_bear_steep,  bgcolor=#1E222D, text_size=size.small)
    table.cell(legend, 0, 3, "Steepener Twist", text_color=col_steep_twist, bgcolor=#1E222D, text_size=size.small)
    table.cell(legend, 0, 4, "Bull Flattener",  text_color=col_bull_flat,   bgcolor=#1E222D, text_size=size.small)
    table.cell(legend, 0, 5, "Bear Flattener",  text_color=col_bear_flat,   bgcolor=#1E222D, text_size=size.small)
    table.cell(legend, 0, 6, "Flattener Twist", text_color=col_flat_twist,  bgcolor=#1E222D, text_size=size.small)
````
