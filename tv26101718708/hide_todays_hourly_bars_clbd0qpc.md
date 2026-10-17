# Hide Today's Hourly Bars

- url: https://www.tradingview.com/script/cLbd0qPC-Hide-Today-s-Hourly-Bars/
- type: indicator
- pine_id: PUB;b64b925bf37642d9b79084cb041dd19e
- version: 2.0

## Description

This lightweight script is designed to hide all price action data for the current trading day. It creates a "clean slate" on your chart by masking the current day's bars with a solid background color, regardless of whether the market session is still active or has already closed.

Key Features:

Complete Masking: Uses high-priority background fills and bar coloring to make current-day candles invisible.

Time-Based Logic: Works based on calendar time, ensuring bars remain hidden even after hours.

Customizable: Users can easily adjust the mask color to match their specific chart theme (Light/Dark).

Use Cases:

Psychological Discipline: Helps traders avoid FOMO (Fear Of Missing Out) and emotional reactions to intraday price fluctuations.

Focus on Closed Data: Ideal for strategies based strictly on historical analysis and previous day's closes.

Backtesting: Allows you to analyze past price action without being distracted by the unfinished current day.

## Source Code

````pine
//@version=6
indicator("Hide Today's Hourly Bars", overlay=true)

// --- ОБЩИЕ НАСТРОЙКИ ---
transparency = input.int(100, "Invisibility Level (0-100)", minval=0, maxval=100)
manual_hide_friday = input.bool(false, "Hide Last Friday? (Turn off on Monday afternoon)")

// --- РЕЖИМ 1: Скрытие последних N дней от текущего момента ---
use_custom_days = input.bool(false, "Hide Custom Number of Days?", group="Mode 1: Last N Days")
days_to_hide = input.int(1, "Days to Hide", minval=1, group="Mode 1: Last N Days")

// --- РЕЖИМ 2: Скрытие всего после конкретной даты ---
use_specific_date = input.bool(false, "Set Last Visible Date?", group="Mode 2: Specific Date")
target_year = input.int(2026, "Year", minval=2000, group="Mode 2: Specific Date")
target_month = input.int(10, "Month", minval=1, maxval=12, group="Mode 2: Specific Date")
target_day = input.int(12, "Day", minval=1, maxval=31, group="Mode 2: Specific Date")

// --- ЛОГИКА ОТСЕЧКИ ВРЕМЕНИ ---
// Сохраняем логику отображения: на локальных ТФ отсечка в 09:30, на дневке в 00:00
int cutoff_hour = timeframe.isintraday ? 9 : 0
int cutoff_minute = timeframe.isintraday ? 30 : 0

var int final_cutoff_time = na

if use_specific_date
    // РЕЖИМ 2: Пользователь ввел конкретную дату.
    // Эта дата должна быть ПОСЛЕДНЕЙ видимой. Значит, стена невидимости 
    // ставится на следующий день (+ 24 часа = 86 400 000 мс).
    int base_time = timestamp("America/New_York", target_year, target_month, target_day, cutoff_hour, cutoff_minute, 0)
    final_cutoff_time := base_time + 86400000
else
    // РЕЖИМ 1 (или по умолчанию): Отсчет от текущего времени по Нью-Йорку
    int ny_year = year(timenow, "America/New_York")
    int ny_month = month(timenow, "America/New_York")
    int ny_day = dayofmonth(timenow, "America/New_York")

    // Базовая точка отсчета — сегодня, старт сессии
    int base_cutoff_time = timestamp("America/New_York", ny_year, ny_month, ny_day, cutoff_hour, cutoff_minute, 0)

    // Сдвигаем стену назад на N дней, если включен кастомный режим
    int target_days_count = use_custom_days ? days_to_hide : 1
    final_cutoff_time := base_cutoff_time - ((target_days_count - 1) * 86400000)

// --- ПРОВЕРКА БАРОВ ---
// Бар скрыт, если его время открытия больше или равно времени итоговой отсечки
bool is_hidden_days_bar = time >= final_cutoff_time

// --- ПРОШЛАЯ ПЯТНИЦА (Очистка графика в понедельник) ---
bool is_friday = (dayofweek(time, syminfo.timezone) == dayofweek.friday) and not is_hidden_days_bar
bool is_last_friday = is_friday and ((timenow - time) < 86400000 * 7) 

// --- ПРИМЕНЕНИЕ ЦВЕТА ---
bool should_hide = false
if is_hidden_days_bar
    should_hide := true
else if is_last_friday and manual_hide_friday
    should_hide := true

// Делаем бары невидимыми
color hide_color = color.new(color.white, transparency)
barcolor(should_hide ? hide_color : na, editable=false)
````
