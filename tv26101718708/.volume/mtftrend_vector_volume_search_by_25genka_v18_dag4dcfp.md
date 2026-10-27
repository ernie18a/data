# MtfTrend: Vector Volume Search by 25Genka v1.8

- url: https://www.tradingview.com/script/dag4DcfP-mtftrend-vector-volume-search-by-25genka-v1-8/
- type: indicator
- pine_id: PUB;1d3b8b5c646147859c21b151e56fbf32
- version: 1.0

## Description

[b]This indicator was created based on an idea from our community subscriber, 25Genka. The primary goal is to detect anomalous volume injections ("smart money" or insider activity) strictly before major macroeconomic news events or speeches.[/b]

How it works:
The script utilizes PVSRA (Vector Candles) logic to identify climax volumes (volume that is 1.5x-2x higher than the 10-bar average or has the maximum spread). Instead of analyzing the entire chart and collecting market noise, the indicator activates only within a specific time window defined by the user right before an event.

Key Features:
* Event Marker: A red vertical background line marks the exact time of the news event.
* Time Window: You set how many minutes before the event the indicator should scan for volume (e.g., 15-30 minutes).
* Smart Alerts: Receive notifications for Long or Short volume injections exactly when they matter.

Usage:
Best used on 1m or 5m timeframes. Use the built-in TradingView Economic Calendar to find exact event times.
Disclaimer: Not financial advice. Use for educational purposes and hypothesis testing.

================================================================================

[b]Индикатор создан по задумке подписчика нашего комьюнити — 25Genka. Главная цель: поймать аномальные вливания объема («умные деньги» или инсайдерские сделки) строго перед выходом важных макроэкономических новостей или выступлений.[/b]

Как это работает:
Скрипт использует алгоритм PVSRA (векторные свечи) для поиска кульминаций объема (объем в 1.5-2 раза выше среднего за 10 баров или свеча с максимальным спредом). Чтобы отсеять рыночный шум, индикатор не работает постоянно. Он включается только в заданное вами временное окно прямо перед наступлением события.

Главные функции:
* Маркер события: Точное время новости отмечается красной вертикальной линией на фоне.
* Окно поиска: Вы сами задаете, за сколько минут до события начинать сканировать объемы (например, 15-30 минут).
* Умные алерты: Получайте сигналы о Лонг или Шорт вливаниях в самый важный момент.

Использование:
Лучше всего работает на таймфреймах 1m или 5m. Используйте встроенный Экономический календарь TradingView для поиска точного времени новостей. 
Дисклеймер: Не является финансовой рекомендацией. Создан исключительно для проверки гипотез и обучения.

## Source Code

````pine
//@version=5
indicator("MtfTrend: Vector Volume Search by 25Genka v1.8", shorttitle="MtfTrend 25Genka v1.8", overlay=true)

// ==========================================
// 1. INFO, INSTRUCTIONS & FAQ
// ==========================================
infoText = "HOW IT WORKS (Vector Candles / PVSRA):\n1. Key: Set the exact time of the news event.\n2. Gear: Set the 'Window' (e.g., 30 min).\n3. Drive: The indicator scans for massive volume injections strictly within this window.\n\nРУС: ИНСТРУКЦИЯ:\n1. Узнай время новости, впиши Час и Минуту.\n2. Задай 'Окно' (например, 30 мин).\n3. Индикатор ищет аномальные объемы строго в это окно."
info = input.bool(true, title="HOW IT WORKS --->", tooltip=infoText, group="Instructions & FAQ")

faqText = "FAQ:\nQ: Best timeframe? A: 1m or 5m.\nQ: Best window? A: 15-60 mins. DO NOT set 720 mins!\nQ: What is the RED LINE? A: It marks the exact time of the event. The indicator scans for volume BEFORE this line.\n\nРУС: ЧАСТЫЕ ВОПРОСЫ (FAQ):\nВ: Какой таймфрейм? О: 1м или 5м.\nВ: Какое окно? О: 15-60 мин. Не ставьте 720 мин!\nВ: Что за КРАСНАЯ ЛИНИЯ? О: Это точное время самой новости (Точка Икс). Индикатор ищет сигналы строго ДО этой линии."
infoFaq = input.bool(true, title="FAQ (READ THIS!) --->", tooltip=faqText, group="Instructions & FAQ")

backtestText = "BACKTESTING:\n1. Open 1m/5m timeframe.\n2. Find a past major news event.\n3. Enter its exact time in the settings.\n4. Scroll back and check for signals. Red background line marks the event time.\n\nРУС: БЭКТЕСТ:\nОткрой 1м/5м, найди прошлую новость, вбей ее время и проверь сигналы перед событием. Красная фоновая линия отмечает время самого события."
infoBacktest = input.bool(true, title="HOW TO BACKTEST --->", tooltip=backtestText, group="Instructions & FAQ")

disclaimerText = "DISCLAIMER:\nNot financial advice. Educational purposes only. Always verify signals.\n\nРУС: ДИСКЛЕЙМЕР:\nНе финансовая рекомендация. Только для обучения."
infoDisclaimer = input.bool(true, title="DISCLAIMER --->", tooltip=disclaimerText, group="Instructions & FAQ")

// ==========================================
// 2. TIME SETTINGS
// ==========================================
targetHour = input.int(20, title="Event Hour (0-23)", minval=0, maxval=23, tooltip="ENG: Hour of the event (e.g., 21).\nRU: Час новости (например, 21).", group="Time Settings")
targetMinute = input.int(0, title="Event Minute (0-59)", minval=0, maxval=59, tooltip="ENG: Minute of the event (e.g., 0).\nRU: Минута новости (например, 0).", group="Time Settings")
window = input.int(30, title="Scan Window Before Event (min)", minval=1, tooltip="ENG: Minutes before the event (e.g., 30).\nRU: За сколько минут до события сканировать (например, 30).", group="Time Settings")

// ==========================================
// 3. TIME LOGIC & EVENT LINE
// ==========================================
currentMins = hour(time) * 60 + minute(time)
targetMins = targetHour * 60 + targetMinute

diff = targetMins - currentMins
diff := diff < 0 ? diff + 1440 : diff

inWindow = diff > 0 and diff <= window

// Визуальный маркер самого события (красная вертикальная линия)
isEventTime = (hour(time) == targetHour) and (minute(time) == targetMinute)
bgcolor(isEventTime ? color.new(color.red, 80) : na, title="Event Time Marker")

// ==========================================
// 4. VOLUME LOGIC (PVSRA / VECTOR CANDLES)
// ==========================================
av = math.sum(volume, 10) / 10
value2 = volume * (high - low)
hivalue2 = ta.highest(value2, 10)

// va = 1: climax (anomalous volume), va = 2: rising, 0: normal
va_temp = volume >= av * 1.5 ? 2 : 0
va = (volume >= av * 2) or (value2 >= hivalue2) ? 1 : va_temp

isHighVol = va > 0 // Counting any volume anomaly
isBull = close > open

// ==========================================
// 5. SIGNAL CONDITIONS
// ==========================================
isShortSignal = inWindow and isHighVol and not isBull
isLongSignal  = inWindow and isHighVol and isBull

// ==========================================
// 6. PLOTTING & ALERTS
// ==========================================
plotshape(isShortSignal, title="Anomalous Short", style=shape.labeldown, location=location.abovebar, color=color.red, text="SHORT", textcolor=color.white, size=size.small)
plotshape(isLongSignal, title="Anomalous Long", style=shape.labelup, location=location.belowbar, color=color.green, text="LONG", textcolor=color.white, size=size.small)

alertcondition(isShortSignal, title="Signal: Short Before Event", message="MtfTrend 25Genka [{{ticker}}]: Anomalous selling volume (PVSRA Vector) detected before the event.")
alertcondition(isLongSignal, title="Signal: Long Before Event", message="MtfTrend 25Genka [{{ticker}}]: Anomalous buying volume (PVSRA Vector) detected before the event.")
````
