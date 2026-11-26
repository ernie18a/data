# Hindenburg Omen Pro Stealth (v6)

- url: https://www.tradingview.com/script/kmDlk1zS-hindenburg-omen-pro-stealth-v6/
- type: indicator
- pine_id: PUB;3f9bb34b9e7a4618b735dd8904311395
- version: 1.0

## Description

English: Hindenburg Omen Pro Stealth (v6) Indicator Description
Overview
This script is a professional-grade, high-precision implementation of the classic Hindenburg Omen macroeconomic indicator, tailored for the modern Pine Script v6 platform on TradingView.

Unlike standard versions, this indicator is specifically designed for experienced traders and analysts who prioritize chart cleanliness and visual flexibility. The indicator's primary goal is to predict a high probability of a systemic market crash or a significant correction on the US stock market (using NYSE data).

Unique Advantages of the Pro Stealth Version:
Clustering Logic (Confirmed Risk): A single signal is often a false positive. A real crash risk occurs when a cluster of signals (two or more) appears within a short period. This indicator automatically identifies such clusters and marks them uniquely.

Dynamic Adaptive Offset: Signals no longer overlap the price bars. The height of the icon above the chart is automatically calculated based on current market volatility (ATR). In a volatile market, the icon flies higher; in a calm market, it hugs closer.

Maximum Customization (Stealth Mode): In the settings menu ("gear" icon), you can customize the color and transparency of every element: dots, triangles, the risk zone background, and the entire text info-label (both the background plate color and the text color itself). You can make the indicator virtually invisible for daily analysis, and it will only appear brightly during a real threat.

Full Pine v6 Optimization: The script utilizes the latest v6 functions, ensuring maximum calculation speed and data stability.

Operating Principle (4 Classic Conditions)
The indicator gives a signal only when simultaneously 4 conditions are met for the broad US market (NYSE):

Breadth Condition (Split): The number of stocks reaching 52-week highs AND the number of stocks at 52-week lows simultaneously exceed a given threshold (default 2.2% of all stocks). This indicates extreme market uncertainty and division.

Trend Condition: The NYSE Composite Index is in an uptrend (above its value 50 trading days ago). The Omen is a top-finding indicator, not a bottom-catching one.

Momentum Condition: The McClellan Oscillator is in negative territory, indicating a loss of short-term bullish momentum.

Strength Ratio: The number of new highs should not be more than twice the number of new lows.

How to Interpret the Signals:
Single Signal (Gray Circle): Yellow flag. The market's internal structure is deteriorating. This is a warning, not a trigger to act.

Confirmed Signal / Cluster (Maroon Triangle + Text Label): Red flag. A second signal has appeared within the confirmation window (default 36 days). Historically, this is a state of high probability for a market crash or a prolonged correction.

Settings Guide (Input Menu)
Logic Parameters:

New Low/High Threshold (%): Set 2.2% (classic) or 2.8% (stricter filter).

Positive Trend Lookback (days): Period to verify the macro-index uptrend (usually 50).

Cluster Window (days): The period (in bars) within which two signals are considered a confirmed crash risk (usually 36).

Visuals:

Vertical Offset (ATR): Main parameter for chart cleanliness. Default 1.5. Increase to 2.0 or 3.0 to lift icons higher above the candles.

Colors & Transparency: Fully customize the color scheme for single signals, clusters, risk zone background, text colors, and the color/transparency of the informational label plate.

Русский язык: Описание индикатора Hindenburg Omen Pro Stealth (v6)
Обзор
Данный скрипт представляет собой профессиональную, высокоточную реализацию классического макроэкономического индикатора Hindenburg Omen (Омен Хинденбурга), адаптированную для современной платформы Pine Script v6 на TradingView.

В отличие от стандартных версий, этот индикатор разработан специально для опытных трейдеров и аналитиков, которым важен чистый график и гибкость настройки визуализации. Основная цель индикатора — предсказать высокую вероятность начала системного краха или серьезной коррекции на фондовом рынке США (опираясь на данные NYSE).

Уникальные преимущества версии Pro Stealth:
Логика Кластеризации (Подтвержденный Риск): Один сигнал часто бывает ложным. Настоящий риск обвала возникает, когда появляется кластер сигналов (два и более) в течение короткого периода времени. Этот индикатор автоматически идентифицирует такие кластеры и помечает их особым образом.

Динамический Адаптивный Отступ: Сигналы больше не перекрывают свечи. Высота расположения значка над графиком автоматически рассчитывается на основе текущей волатильности рынка (ATR). На волатильном рынке значок улетает выше, на спокойном — прижимается ближе.

Максимальная Гибкость Настройки (Stealth Mode): В меню настроек («шестеренка») вы можете настроить цвет и прозрачность для каждого элемента: точек, треугольников, фона зоны риска и всей текстовой инфо-метки (цвет фона плашки и цвет самого текста). Вы можете сделать индикатор практически невидимым для повседневного анализа, и он проявит себя ярко только при реальной угрозе.

Полная оптимизация Pine v6: Скрипт использует новейшие функции v6, что обеспечивает максимальную скорость расчета и стабильность данных.

Принцип работы (4 классических условия)
Индикатор подает сигнал только тогда, когда одновременно выполняются 4 условия для широкого рынка США (NYSE):

Условие Ширины (Раскол): Количество акций, достигших 52-недельных максимумов, И количество акций на 52-недельных минимумах одновременно превышают заданный порог (по умолчанию 2.2% от общего числа акций). Это показывает предельную неуверенность и раскол на рынке.

Условие Тренда: Индекс NYSE Composite находится в растущем тренде (выше своего значения 50 торговых дней назад). Омен ловит вершину, а не дно.

Условие Импульса: Осциллятор Макклеллана (McClellan Oscillator) находится в отрицательной зоне, что указывает на потерю краткосрочного бычьего импульса.

Соотношение Сил: Количество новых максимумов не должно более чем в два раза превышать количество новых минимумов.

Как интерпретировать сигналы:
Одиночный Сигнал (Серый круг): Желтый флаг. Внутренняя структура рынка ухудшается. Это предупреждение, но не триггер к действию.

Подтвержденный Сигнал / Кластер (Бордовый треугольник + Текстовая метка): Красный флаг. Появился второй сигнал в течение окна подтверждения (по умолчанию 36 дней). Исторически это состояние высокой вероятности рыночного краха или затяжной коррекции.

Инструкция по Настройке (Меню Input)
Параметры Расчета (Logic):

Порог Hi/Lo (%): Установите 2.2% (классика) или 2.8% (более строгий фильтр).

Тренд индекса (дни): Период для проверки растущего тренда макро-индекса (обычно 50).

Окно кластера (дни): Период (в барах), внутри которого два сигнала считаются подтвержденным риском обвала (обычно 36).

Внешний вид (Visuals):

Вертикальный отступ (ATR): Главный параметр для чистоты графика. По умолчанию 1.5. Увеличьте до 2.0 или 3.0, чтобы поднять значки выше над свечами.

Цвета и Прозрачность: Полностью настройте цветовую гамму для одиночных сигналов, кластеров, фона зоны риска, цвета текста, а также цвета и прозрачности плашки информационной метки.

## Source Code

````pine
//@version=6
indicator("Hindenburg Omen Flexible V6", shorttitle="HO Flex", overlay=true)

// ==========================================
// ГРУППА: ОСНОВНЫЕ НАСТРОЙКИ (ЛОГИКА)
// ==========================================
grp_logic = "Параметры расчета"
threshold  = input.float(2.2, "Порог Hi/Lo (%)", minval=0.1, step=0.1, group=grp_logic)
lookback   = input.int(50, "Тренд индекса (дни)", minval=1, group=grp_logic)
mcc_fast   = input.int(19, "McClellan Fast EMA", minval=1, group=grp_logic)
mcc_slow   = input.int(39, "McClellan Slow EMA", minval=1, group=grp_logic)
ratio_lim  = input.float(2.0, "Лимит Ratio NH/NL", minval=0.1, group=grp_logic)
sig_window = input.int(36, "Окно кластера (дни)", minval=1, group=grp_logic)

// ==========================================
// ГРУППА: ВИЗУАЛИЗАЦИЯ И ОТСТУПЫ
// ==========================================
grp_vis = "Внешний вид"
offset_mult = input.float(1.5, "Вертикальный отступ (ATR)", minval=0.0, step=0.1, group=grp_vis)
show_labels = input.bool(true, "Показывать инфо-метки", group=grp_vis)
color_single = input.color(color.new(color.gray, 50), "Цвет одиночного сигнала", group=grp_vis)
color_clust  = input.color(color.new(color.maroon, 20), "Цвет кластера (риск)", group=grp_vis)
color_bg     = input.color(color.new(color.maroon, 97), "Цвет фона зоны риска", group=grp_vis)

// --- НОВЫЕ НАСТРОЙКИ ---
color_text_single = input.color(color.new(color.white, 0), "Цвет текста одиночного сигнала", group=grp_vis)
color_text_clust  = input.color(color.new(color.white, 0), "Цвет текста кластера", group=grp_vis)
color_text_desc   = input.color(color.new(color.white, 0), "Цвет описания сигнала", group=grp_vis)
color_box_desc    = input.color(color.new(color.black, 40), "Цвет фона описания", group=grp_vis)


// ==========================================
// ПОЛУЧЕНИЕ ДАННЫХ
// ==========================================
f_get_data(t) => request.security(t, "D", close, ignore_invalid_symbol = true)

adv = f_get_data("USI:ADV"), dec = f_get_data("USI:DECL"), unc = f_get_data("USI:UNCH.NY")
nh  = f_get_data("INDEX:MAHN"), nl  = f_get_data("INDEX:MALN"), idx = f_get_data("NYA")

// ==========================================
// РАСЧЕТЫ
// ==========================================
total = adv + dec + unc
hiP = (nh / total) * 100
loP = (nl / total) * 100

// Условия
cond1 = hiP >= threshold and loP >= threshold
cond2 = idx >= idx[lookback]
mcc_src = 1000 * ((adv - dec) / (adv + dec))
mcc = ta.ema(mcc_src, mcc_fast) - ta.ema(mcc_src, mcc_slow)
cond3 = mcc < 0
cond4 = (nh / nl) < ratio_lim

hoSignal = cond1 and cond2 and cond3 and cond4

// Расчет подтверждения (кластера)
bars_since_last = ta.barssince(hoSignal[1])
isConfirmed = hoSignal and bars_since_last <= sig_window

// Динамический отступ
atr = ta.atr(14)
y_pos = high + (atr * offset_mult)

// ==========================================
// ОТРИСОВКА
// ==========================================

// 1. Одиночный сигнал (точка)
// При location.absolute значение Y передается как первый аргумент
plot_y = hoSignal and not isConfirmed ? y_pos : na
plotshape(plot_y, "Single Signal", shape.circle, location.absolute, color_single, size=size.tiny)

// 2. Кластер и Метки
if hoSignal
    if isConfirmed
        // Отрисовка треугольника кластера через label для идеального контроля
        label.new(bar_index, y_pos, "▼", color=color.new(color.white, 100), textcolor=color_clust, style=label.style_none, size=size.normal)
        
        if show_labels
            txt = "Hindenburg Omen\nConfirmed Risk\nHi: " + str.tostring(hiP, "#.#") + "% | Lo: " + str.tostring(loP, "#.#") + "%"
            label.new(bar_index, y_pos + (atr * 0.5), txt, style=label.style_label_down, color=color_box_desc, textcolor=color_text_desc, size=size.small)
    else if show_labels
        // Крошечная подпись для одиночного сигнала, чтобы не путать
        label.new(bar_index, y_pos + (atr * 0.2), "HO", style=label.style_label_down, color=color.new(color.black, 100), textcolor=color_text_single, size=size.tiny)

// 3. Фон (Зона риска)
var int lastS = 0
if hoSignal
    lastS := bar_index
    
in_risk_zone = (bar_index - lastS) <= sig_window
bgcolor(in_risk_zone ? color_bg : na)
````
