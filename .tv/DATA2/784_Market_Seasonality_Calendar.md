<!-- tradingview-pine-id: PUB;84e18ceebd9d45028bc53baf0ce53d1e -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# 784 Market Seasonality Calendar

Source: https://www.tradingview.com/script/2QHxiVSp-Market-Seasonality-Calendar/

## Description

Market Seasonality Calendar adds a recurring calendar framework to the price chart. It highlights nine predefined seasonal periods, explains their assigned market context, displays the next three upcoming periods, and summarizes how the selected instrument moved during previous occurrences.

The indicator is designed for traders who want to include seasonal context in market preparation and chart analysis. It combines calendar shading, a timeline, explanatory text, instrument-specific historical statistics, and advance alerts in one overlay.

It provides context for an existing trading process. It does not generate trade entries, exits, stop-loss levels, or price targets.

**How the calendar works**

The model uses fixed date ranges that repeat every year. Each range has an assigned interpretation: a positive seasonal bias, a downside-risk context, or potential support from share buybacks.

These are predefined seasonal hypotheses. The script does not discover the dates by searching for the most profitable historical periods. The assigned color remains the same even when historical results disagree with the expected direction.

Event names describe the themes associated with the calendar model. The indicator does not retrieve actual earnings dates, GDP release schedules, contract expiration calendars, or executed buyback activity. An event label does not mean that the named event occurs within that exact date range every year or for every company.

**Included seasonal periods**

- January 3–12 — Green: positive seasonal context; Q4 earnings/GDP theme and beginning-of-year expectations.
- March 15–22 — Red: downside-risk context; futures and options expiration theme and profit-taking.
- April 5–10 — Green: positive seasonal context; Q1 earnings/GDP theme and the beginning of the second quarter.
- June 17–21 — Red: downside-risk context; contract expiration and portfolio rebalancing themes.
- July 4–11 — Green: positive seasonal context; Q2 earnings/GDP theme.
- September 16–20 — Red: downside-risk context; contract expiration and end-of-summer profit-taking themes.
- October 5–10 — Green: positive seasonal context; Q3 earnings/GDP theme and buyback expectations.
- November 1–7 — Gold: potential demand support associated with the share buyback theme.
- December 16–23 — Red: downside-risk context; contract expiration and year-end position unwinding themes.

Dates are inclusive and refer to calendar days. The schedule is not shifted to match holidays or actual event dates. Price zones and statistics use the available chart bars within those ranges.

**Reading the colors**

Green identifies periods assigned a positive or upward seasonal bias. Price can still fall during a green period.

Red identifies periods assigned a downside-risk and volatility theme. Price can still rise during a red period. The indicator does not test whether volatility actually increased; its historical match calculation measures price direction.

Gold identifies the model’s buyback-support period. It does not confirm that a company is buying shares, and it does not mark a technical support level.

Outside the listed periods, the panel reports no active window. This means that the calendar has no active classification; it does not mean that market risk is low.

**Suitable instruments**

The intended starting point is U.S. equity-market analysis. Broad U.S. equity benchmarks and related ETFs, such as the S&P 500/SPY and Nasdaq-100/QQQ, are sensible instruments for exploring the model because its themes concern corporate earnings, equity derivatives, and share buybacks.

This is a recommendation based on the model’s intended context, not evidence of superior predictive performance on those instruments.

Individual U.S. stocks can also be examined. However, company-specific news and earnings announcements may outweigh broad calendar effects. Verify those events separately.

For other equity markets, index futures, or CFDs, assess the relevance of the calendar model and the selected data feed, trading sessions, and timezone. Continuous futures can also be affected by contract rolls and historical adjustments. The script does not adapt its calendar to each local market.

The model was not specifically calibrated for cryptocurrency, foreign exchange, or commodities. Being able to display the overlay on an instrument does not establish that its seasonal assumptions apply there.

**Recommended timeframes**

Start with the daily chart, 1D, to review the multi-day periods and historical statistics.

Intraday charts, such as 4H, 1H, or 15 minutes, can provide a more detailed view of price behavior within a seasonal period. The calendar dates remain the same on every supported timeframe.

The supported calculation timeframes are 1D and intraday. Multi-day, weekly, and monthly charts are not supported for active-window tracking and statistics. Switch to 1D or lower when the panel requests it.

Standard time-based candlesticks or bars are recommended so that the statistics use ordinary market prices.

**What appears on the chart**

The information panel focuses on the active period, or the next period when none is active. It displays:

- The period’s dates and assigned market context.
- Its associated event theme.
- An explanation of the expected effect and underlying theme.
- Guidance on interpreting the seasonal context.
- A color guide.
- The next three upcoming periods with calendar-day countdowns.
- Historical statistics for the period currently in focus.

For example, when November 1–7 is in focus, the statistics summarize eligible past November 1–7 occurrences. They do not combine all green or gold periods.

The panel follows the latest chart bar rather than the bar under the cursor.

Colored boxes surround the observed price range during tracked periods. Their vertical padding uses ATR(14), and an active box can expand as new bars arrive. These boundaries are visual aids, not forecast ranges, stops, or targets.

The timeline places calendar segments above price. Future segments represent scheduled date ranges only. Its vertical position adjusts to the visible chart area.

In this version, the timeline depends on recorded colored windows. Keep “Show colored windows” enabled when using the timeline and allow enough chart history for at least one window to be tracked.

**Understanding the historical statistics**

SAMPLES is the number of completed, tracked occurrences available in the chart history for the selected period. An unfinished occurrence is not included. A period already in progress at the first loaded bar may also be excluded.

AVG MOVE is the arithmetic mean of each occurrence’s percentage price change:

100 × (last in-window bar close / first tracked in-window bar close − 1).

On a daily chart, this measures from the first included daily close to the last included daily close. It does not include the move from the previous day’s close into the first day.

On an intraday chart, the first and last included bar closes differ from those on the daily chart. Results can therefore change with timeframe and session settings. A completed observation is recorded when the first subsequent out-of-window bar arrives.

MATCH RATE is the percentage of completed occurrences whose price direction agrees with the assigned bias:

- Positive moves count as matches for green and gold periods.
- Negative moves count as matches for red periods.
- An unchanged close-to-close result is not a match.

A small move and a large move each count as one occurrence.

The accompanying labels use simple thresholds:

- LOW DATA: fewer than three observations.
- STRONG: at least three observations and a match rate of 70% or higher.
- MODERATE: at least three observations and a match rate from 55% to below 70%.
- WEAK: at least three observations and a match rate below 55%.

These labels summarize historical directional agreement. They are not confidence levels, statistical significance tests, or probability forecasts.

Match rate is not a trade win rate. Average move is not a strategy return. The calculations do not simulate orders, transaction costs, slippage, stops, or position sizing.

Available history, symbol, timeframe, session, timezone, and chart price adjustments can affect the results. The “Historical windows” setting limits the number of displayed boxes, not the number of observations used in the statistics.

**A practical workflow**

1. Open a standard daily chart, for example SPY, and add the indicator.
2. Keep “Use exchange timezone” enabled initially and load sufficient historical data.
3. Read the active or next period, its explanation, and the sample count before interpreting the percentages.
4. Compare the calendar context with your own trend, price-level, volume, and risk analysis. Check actual company and economic event dates separately.
5. If useful, switch to an intraday chart to inspect price behavior inside the period. Remember that statistics will be recalculated using that chart’s bars.
6. Use upcoming-period alerts as preparation reminders, then review completed outcomes without assuming that the seasonal bias must repeat.

For example, a red period approaching during an uptrend is a reason to review the risk context within your own process. The calendar alone does not confirm a reversal or specify a short entry.

**Settings and languages**

The panel supports English, Russian, German, Spanish, Arabic, and Simplified Chinese. Input titles remain in English.

Panel position offers four chart corners. Panel size offers Compact, Standard, and Large.

The display settings include:

- Show information panel — displays the dashboard.
- Show colored windows — displays the tracked seasonal price zones.
- Show timeline above chart — displays calendar segments above price.
- Window transparency — adjusts zone shading.
- Window padding (ATR) — adjusts spacing around the observed price range.
- Historical windows — controls the number of retained boxes.
- Timeline distance (ATR) — adjusts the timeline’s vertical distance from price.

The calendar uses the symbol’s exchange timezone by default. Disable “Use exchange timezone” to apply the “Custom timezone (IANA)” setting.

Date classification uses each bar’s opening timestamp in the selected timezone. Changing only the chart’s displayed timezone does not change the indicator’s timezone setting.

**Alerts**

The indicator supports a window-start alert and an advance warning.

“Warn N calendar days before” sets the warning range, with a default of three calendar days. The warning occurs when the chart first enters that range; it is not intended as a daily reminder.

Enable the desired alert types in the indicator settings, then create a TradingView alert for this indicator.

Choose “Any alert() function call” for detailed messages localized to the selected language. Alternatively, select an individual “Calendar window started” or “Calendar window approaching” condition for its fixed English message.

Alerts run on live chart updates. They are not independent weekend or holiday calendar notifications. Adding the indicator does not automatically create a running alert.

If a boundary passes while no bars arrive, delivery can be delayed or the warning can be missed. Recreate alerts after changing the settings or language that they should use.

**Scope and limitations**

This indicator provides a fixed-calendar overlay with descriptive historical statistics. Future dates are known because the calendar is predefined, not because future price information is available.

Active price boxes evolve with incoming bars. Completed-window statistics become available after the window ends and a subsequent bar arrives.

The script does not validate the economic explanation behind each period, establish causation, or guarantee that historical effects will persist.

Use it as an educational and analytical aid alongside independent analysis and risk management.

**English**

Highlights nine fixed seasonal periods, shows upcoming windows, and summarizes historical price changes and directional agreement for the selected instrument. Start with U.S. equity indices or ETFs on 1D; intraday charts are also supported. Provides calendar context, not trade signals or a live economic calendar.

**Русский**

Отмечает девять фиксированных сезонных периодов, показывает ближайшие окна и историческую статистику изменения цены и совпадения направления. Начните с фондовых индексов США или ETF на 1D; внутридневные графики также поддерживаются. Это календарный контекст, а не торговые сигналы или актуальное расписание экономических событий.

**Deutsch**

Markiert neun feste saisonale Zeitfenster und zeigt kommende Zeiträume sowie historische Kursveränderungen und die Übereinstimmung mit der erwarteten Richtung. Als Einstieg eignen sich US-Aktienindizes oder ETFs im Tageschart; Intraday-Charts werden ebenfalls unterstützt. Liefert saisonalen Kontext, keine Handelssignale und keinen aktuellen Wirtschaftskalender.

**Español**

Señala nueve períodos estacionales fijos y muestra los próximos períodos, la variación histórica del precio y la coincidencia con el sesgo previsto. Para empezar, utilice índices bursátiles estadounidenses o ETF en 1D; también admite gráficos intradía. Aporta contexto estacional, no señales de operativa ni un calendario económico actualizado.

**العربية**

يحدد تسع فترات موسمية ثابتة، ويعرض الفترات القادمة والتغيرات التاريخية للأسعار ومدى توافق اتجاهها مع الميل الموسمي المفترض. يُنصح بالبدء بمؤشرات الأسهم الأمريكية أو صناديق المؤشرات المتداولة على الإطار اليومي؛ كما يدعم الأطر الزمنية خلال اليوم. يقدم سياقًا موسميًا، وليس إشارات تداول أو تقويمًا اقتصاديًا محدثًا.

**中文（简体）**

标示九个固定的季节性时段，展示即将到来的时段、历史价格变动及其与预设方向的一致率。建议从美国股票指数或相关ETF的日线图开始，也支持日内周期。提供季节性背景参考，不提供交易信号，也不是实时经济日历。

---

## Source Code

````pine
//@version=6
// WORKING: Multilingual edition • English / Russian / German / Spanish / Arabic / Simplified Chinese
indicator("784 Market Seasonality Calendar", shorttitle = "784 Market Seasonality Calendar", overlay = true, max_labels_count = 50, max_boxes_count = 100, max_lines_count = 500)

// ─────────────────────────────────────────────────────────────────────────────
// SETTINGS — input titles remain in English; the on-chart terminal is localized.
// ─────────────────────────────────────────────────────────────────────────────
string language    = input.string("English", "Language / Язык / Sprache / Idioma / اللغة / 语言", options = ["English", "Русский", "Deutsch", "Español", "العربية", "中文"], group = "784 • Interface", display = display.none)
bool showPanel      = input.bool(true,  "Show information panel", group = "784 • Interface", display = display.none)
bool showZones      = input.bool(true, "Show colored windows", group = "784 • Interface", display = display.none)
bool showTimeline   = input.bool(true,  "Show timeline above chart", group = "784 • Interface", display = display.none)
int transparency   = input.int(70, "Window transparency", minval = 50, maxval = 95, group = "784 • Interface", display = display.none)
float zonePadding  = input.float(0.35, "Window padding (ATR)", minval = 0.0, maxval = 2.0, step = 0.05, group = "784 • Interface", display = display.none)
int maxZones       = input.int(36, "Historical windows", minval = 6, maxval = 50, group = "784 • Interface", display = display.none)
float timelineGap  = input.float(3.0, "Timeline distance (ATR)", minval = 1.0, maxval = 8.0, step = 0.25, group = "784 • Interface", display = display.none)
string corner      = input.string("Top Right", "Panel position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = "784 • Interface", display = display.none)
string panelSize   = input.string("Compact", "Panel size", options = ["Compact", "Standard", "Large"], group = "784 • Interface", display = display.none)

bool exchangeZone = input.bool(true, "Use exchange timezone", group = "784 • Calendar", display = display.none)
string customZone = input.string("Europe/Berlin", "Custom timezone (IANA)", group = "784 • Calendar", display = display.none)

int leadDays       = input.int(3, "Warn N calendar days before", minval = 1, maxval = 30, group = "784 • Alerts", display = display.none)
bool notifyStart   = input.bool(true, "Alert when a window starts", group = "784 • Alerts", display = display.none)
bool notifySoon    = input.bool(true, "Alert before the next window", group = "784 • Alerts", display = display.none)

// ─────────────────────────────────────────────────────────────────────────────
// FIXED CALENDAR DATA — calculation logic preserved
// ─────────────────────────────────────────────────────────────────────────────
var array<int> months = array.from(1, 3, 4, 6, 7, 9, 10, 11, 12)
var array<int> starts = array.from(3, 15, 5, 17, 4, 16, 5, 1, 16)
var array<int> ends   = array.from(12, 22, 10, 21, 11, 20, 10, 7, 23)
// 0 = positive activity, 1 = volatility / downside risk, 2 = buybacks
var array<int> kinds  = array.from(0, 1, 0, 1, 0, 1, 0, 2, 1)

// 784 MarketAgent master visual system.
color C_GREEN       = color.rgb(0, 166, 116)
color C_RED         = color.rgb(214, 24, 32)
color C_GOLD        = color.rgb(224, 145, 0)
color C_BRAND       = color.rgb(214, 24, 32)
color C_HEADER      = color.rgb(25, 29, 33)
color C_BG          = color.rgb(248, 249, 250)
color C_CELL        = color.rgb(248, 249, 250)
color C_CELL_ALT    = color.rgb(238, 241, 243)
color C_SECTION     = color.rgb(225, 229, 232)
color C_TEXT        = color.rgb(25, 29, 33)
color C_MUTED       = color.rgb(103, 111, 118)
color C_SILVER      = color.rgb(205, 210, 214)
color C_SILVER_DARK = color.rgb(151, 158, 164)

f_ru(string en) =>
    switch en
        "No active window" => "Нет активного периода"
        "POSITIVE SEASONAL EFFECT" => "ПОЗИТИВНЫЙ ЭФФЕКТ"
        "DOWNSIDE-RISK WINDOW" => "РИСК СНИЖЕНИЯ"
        "BUYBACK SUPPORT" => "ПОДДЕРЖКА BUYBACKS"
        "ACTIVITY ↑\nPOSITIVE BIAS" => "АКТИВНОСТЬ ↑ • ПОЗИТИВНЫЙ ФОН"
        "VOLATILITY ↑\nDOWNSIDE RISK" => "ВОЛАТИЛЬНОСТЬ ↑ • РИСК СНИЖЕНИЯ"
        "DEMAND SUPPORT\nPRICE ↑" => "ПОДДЕРЖКА СПРОСА • КУРС ↑"
        "NEUTRAL BACKDROP" => "НЕЙТРАЛЬНЫЙ ФОН"
        "Stronger sentiment\nand buying activity" => "Позитивный фон и покупательская\nактивность могут усилиться"
        "Sharper price moves;\nhigher downside risk" => "Движения могут стать резче;\nриск снижения — выше обычного"
        "Buybacks may support\ndemand and price" => "Обратные выкупы могут\nподдержать спрос и цену"
        "No clear seasonal bias" => "Выраженного сезонного ожидания нет"
        "Seasonal context\nfavoring upside" => "Учитывать как сезонный фон в пользу роста"
        "Period of\nelevated risk" => "Учитывать как период повышенного риска"
        "Potential\nmarket support" => "Учитывать как возможную поддержку рынка"
        "Wait for the\nnext window" => "Ждать следующего календарного окна"
        "Q4 earnings season + GDP" => "Отчётность Q4 + ВВП"
        "Futures and options expiration" => "Экспирация фьючерсов и опционов"
        "Q1 earnings season + GDP" => "Отчётность Q1 + ВВП"
        "Contract expiration" => "Экспирация контрактов"
        "Q2 earnings season + GDP" => "Отчётность Q2 + ВВП"
        "Q3 earnings season + GDP" => "Отчётность Q3 + ВВП"
        "Share buybacks" => "Обратные выкупы акций"
        "Start of year;\npositive expectations" => "Начало года, позитивные ожидания"
        "Profit-taking;\nhigher uncertainty" => "Фиксация прибыли, нервозность"
        "Start of the second quarter" => "Начало второго квартала"
        "Portfolio rebalancing" => "Ребалансировка портфелей"
        "Earnings season" => "Сезон отчётности"
        "End of summer;\nprofit-taking" => "Конец лета, фиксация прибыли"
        "Start of Q4;\nbuyback expectations" => "Начало Q4, ожидание buybacks"
        "Buybacks may support the market" => "Buybacks поддерживают рынок"
        "Year-end;\nposition unwinding" => "Закрытие года, фиксация позиций"
        "Q4 + GDP" => "Q4 + ВВП"
        "Q1 + GDP" => "Q1 + ВВП"
        "Q2 + GDP" => "Q2 + ВВП"
        "Q3 + GDP" => "Q3 + ВВП"
        "EXPIRATION" => "ЭКСПИРАЦИЯ"
        "BUYBACKS" => "BUYBACKS"
        "SEASONALITY" => "СЕЗОННОСТЬ"
        "VOLATILITY" => "ВОЛАТИЛЬНО"
        "SUPPORT" => "ПОДДЕРЖКА"
        "03–12 JAN" => "03–12 ЯНВ"
        "15–22 MAR" => "15–22 МАР"
        "05–10 APR" => "05–10 АПР"
        "17–21 JUN" => "17–21 ИЮН"
        "04–11 JUL" => "04–11 ИЮЛ"
        "16–20 SEP" => "16–20 СЕН"
        "05–10 OCT" => "05–10 ОКТ"
        "01–07 NOV" => "01–07 НОЯ"
        "16–23 DEC" => "16–23 ДЕК"
        "3–12 January" => "3–12 января"
        "15–22 March" => "15–22 марта"
        "5–10 April" => "5–10 апреля"
        "17–21 June" => "17–21 июня"
        "4–11 July" => "4–11 июля"
        "16–20 September" => "16–20 сентября"
        "5–10 October" => "5–10 октября"
        "1–7 November" => "1–7 ноября"
        "16–23 December" => "16–23 декабря"
        "LOW DATA" => "МАЛО ДАННЫХ"
        "STRONG" => "ВЫСОКАЯ"
        "MODERATE" => "СРЕДНЯЯ"
        "WEAK" => "НИЗКАЯ"
        "UPCOMING IN " => "Через "
        " DAYS" => " дн."
        "▲ POSITIVE" => "▲ ПОЗИТИВНЫЙ"
        "▼ RISK" => "▼ РИСК"
        "◆ SUPPORT" => "◆ ПОДДЕРЖКА"
        "ACTIVE WINDOW" => "АКТИВНОЕ ОКНО"
        "NEXT WINDOW" => "БЛИЖАЙШЕЕ ОКНО"
        "NOW  •  WINDOW ACTIVE\nBIAS  •  " => "СЕЙЧАС  •  ОКНО АКТИВНО\nОЖИДАНИЕ  •  "
        "NOW  •  NO ACTIVE WINDOW\nNEXT WINDOW BELOW" => "СЕЙЧАС  •  ВНЕ КАЛЕНДАРНОГО ОКНА\nСЛЕДУЮЩЕЕ ОКНО ПОКАЗАНО НИЖЕ"
        "EVENT" => "СОБЫТИЕ"
        "MEANING" => "СМЫСЛ"
        "DRIVER" => "ПРИЧИНА"
        "CONSIDER" => "КАК УЧИТЫВАТЬ"
        "D" => "ДН."
        "MARKET\nSEASONALITY" => "РЫНОЧНАЯ\nСЕЗОННОСТЬ"
        "CALENDAR" => "КАЛЕНДАРЬ"
        "PERIOD" => "ПЕРИОД"
        "MODE" => "РЕЖИМ"
        "1D OR LOWER" => "ТФ 1D ИЛИ НИЖЕ"
        "COLOR GUIDE" => "РАСШИФРОВКА ЦВЕТОВ"
        "▲ POSITIVE\nGREEN" => "▲ POSITIVE\nЗЕЛЁНЫЙ"
        "▼ RISK\nRED" => "▼ RISK\nКРАСНЫЙ"
        "◆ SUPPORT\nGOLD" => "◆ SUPPORT\nЗОЛОТОЙ"
        "Positive sentiment\nand activity may\nstrengthen" => "Чаще усиливаются\nпозитивный фон\nи активность"
        "Sharper moves;\ndownside risk\nabove normal" => "Движения резче;\nриск снижения\nвыше обычного"
        "Buybacks may\nsupport demand\nand price" => "Выкупы могут\nподдержать спрос\nи цену"
        "UPCOMING WINDOWS" => "БЛИЖАЙШИЕ ОКНА"
        "SAMPLES" => "НАБЛ."
        "AVG MOVE" => "СР. ДВИЖ."
        "MATCH RATE" => "СОВПАДЕНИЕ"
        "CONTEXT ONLY, NOT A TRADE SIGNAL" => "КОНТЕКСТ, НЕ ТОРГОВЫЙ СИГНАЛ"
        "784 • Calendar window started" => "784 • Начало календарного периода"
        "784 Market Seasonality Calendar: an active window has started" => "784 Market Seasonality Calendar: начался активный период"
        "784 • Calendar window approaching" => "784 • Приближается календарный период"
        "784 Market Seasonality Calendar: the next window is approaching" => "784 Market Seasonality Calendar: приближается новое окно"
        => en

// Spanish financial terminology; support means buyback demand, not a technical price level.
f_es(string en) =>
    switch en
        "No active window" => "Sin período activo"
        "POSITIVE SEASONAL EFFECT" => "EFECTO ESTACIONAL ALCISTA"
        "DOWNSIDE-RISK WINDOW" => "PERÍODO CON RIESGO BAJISTA"
        "BUYBACK SUPPORT" => "APOYO DE LAS RECOMPRAS"
        "ACTIVITY ↑\nPOSITIVE BIAS" => "ACTIVIDAD ↑\nSESGO ALCISTA"
        "VOLATILITY ↑\nDOWNSIDE RISK" => "VOLATILIDAD ↑\nRIESGO BAJISTA"
        "DEMAND SUPPORT\nPRICE ↑" => "APOYO A LA DEMANDA\nPRECIO ↑"
        "NEUTRAL BACKDROP" => "CONTEXTO NEUTRAL"
        "Stronger sentiment\nand buying activity" => "El sentimiento del mercado y la\nactividad compradora pueden mejorar"
        "Sharper price moves;\nhigher downside risk" => "Movimientos más bruscos;\nmayor riesgo de caídas"
        "Buybacks may support\ndemand and price" => "Las recompras pueden sostener\nla demanda y la cotización"
        "No clear seasonal bias" => "Sin un sesgo estacional claro"
        "Seasonal context\nfavoring upside" => "Contexto estacional\nfavorable a las subidas"
        "Period of\nelevated risk" => "Período de\nriesgo elevado"
        "Potential\nmarket support" => "Posible apoyo\nal mercado"
        "Wait for the\nnext window" => "Esperar al siguiente\nperíodo estacional"
        "Q4 earnings season + GDP" => "Temporada de resultados del 4T + PIB"
        "Futures and options expiration" => "Vencimiento de futuros y opciones"
        "Q1 earnings season + GDP" => "Temporada de resultados del 1T + PIB"
        "Contract expiration" => "Vencimiento de contratos"
        "Q2 earnings season + GDP" => "Temporada de resultados del 2T + PIB"
        "Q3 earnings season + GDP" => "Temporada de resultados del 3T + PIB"
        "Share buybacks" => "Recompra de acciones"
        "Start of year;\npositive expectations" => "Inicio de año;\nexpectativas favorables"
        "Profit-taking;\nhigher uncertainty" => "Toma de beneficios;\nmayor incertidumbre"
        "Start of the second quarter" => "Inicio del segundo trimestre"
        "Portfolio rebalancing" => "Reequilibrio de carteras"
        "Earnings season" => "Temporada de resultados"
        "End of summer;\nprofit-taking" => "Fin del verano;\ntoma de beneficios"
        "Start of Q4;\nbuyback expectations" => "Inicio del 4T;\nexpectativas de recompra de acciones"
        "Buybacks may support the market" => "Las recompras pueden\nsostener el mercado"
        "Year-end;\nposition unwinding" => "Cierre de año;\ncierre de posiciones"
        "Q4 + GDP" => "4T + PIB"
        "EXPIRATION" => "VENCIMIENTO"
        "Q1 + GDP" => "1T + PIB"
        "Q2 + GDP" => "2T + PIB"
        "Q3 + GDP" => "3T + PIB"
        "BUYBACKS" => "RECOMPRAS"
        "SEASONALITY" => "ESTACIONALIDAD"
        "VOLATILITY" => "VOLATILIDAD"
        "SUPPORT" => "APOYO"
        "03–12 JAN" => "03–12 ENE"
        "15–22 MAR" => "15–22 MAR"
        "05–10 APR" => "05–10 ABR"
        "17–21 JUN" => "17–21 JUN"
        "04–11 JUL" => "04–11 JUL"
        "16–20 SEP" => "16–20 SEP"
        "05–10 OCT" => "05–10 OCT"
        "01–07 NOV" => "01–07 NOV"
        "16–23 DEC" => "16–23 DIC"
        "3–12 January" => "3–12 de enero"
        "15–22 March" => "15–22 de marzo"
        "5–10 April" => "5–10 de abril"
        "17–21 June" => "17–21 de junio"
        "4–11 July" => "4–11 de julio"
        "16–20 September" => "16–20 de septiembre"
        "5–10 October" => "5–10 de octubre"
        "1–7 November" => "1–7 de noviembre"
        "16–23 December" => "16–23 de diciembre"
        "LOW DATA" => "DATOS INSUFICIENTES"
        "STRONG" => "ALTA"
        "MODERATE" => "MODERADA"
        "WEAK" => "BAJA"
        "UPCOMING IN " => "PRÓXIMO PERÍODO EN "
        " DAYS" => " DÍAS"
        "▲ POSITIVE" => "▲ ALCISTA"
        "▼ RISK" => "▼ RIESGO"
        "◆ SUPPORT" => "◆ APOYO"
        "ACTIVE WINDOW" => "PERÍODO ACTIVO"
        "NEXT WINDOW" => "PRÓXIMO PERÍODO"
        "NOW  •  WINDOW ACTIVE\nBIAS  •  " => "AHORA  •  PERÍODO ACTIVO\nSESGO  •  "
        "NOW  •  NO ACTIVE WINDOW\nNEXT WINDOW BELOW" => "AHORA  •  SIN PERÍODO ACTIVO\nPRÓXIMO PERÍODO MÁS ABAJO"
        "EVENT" => "EVENTO"
        "MEANING" => "QUÉ IMPLICA"
        "DRIVER" => "FACTOR IMPULSOR"
        "CONSIDER" => "CÓMO INTERPRETARLO"
        "D" => "d"
        "MARKET\nSEASONALITY" => "ESTACIONALIDAD\nDEL MERCADO"
        "CALENDAR" => "CALENDARIO"
        "PERIOD" => "PERÍODO"
        "MODE" => "CONTEXTO"
        "1D OR LOWER" => "1D O INFERIOR"
        "COLOR GUIDE" => "LEYENDA DE COLORES"
        "GREEN" => "VERDE"
        "RED" => "ROJO"
        "GOLD" => "DORADO"
        "Positive sentiment\nand activity may\nstrengthen" => "Pueden mejorar\nel sentimiento y la\nactividad compradora"
        "Sharper moves;\ndownside risk\nabove normal" => "Movimientos bruscos;\nriesgo de caídas\nsuperior al habitual"
        "Buybacks may\nsupport demand\nand price" => "Las recompras pueden\nsostener la demanda\ny la cotización"
        "UPCOMING WINDOWS" => "PRÓXIMOS PERÍODOS"
        "SAMPLES" => "OBSERVACIONES"
        "AVG MOVE" => "VARIACIÓN MEDIA"
        "MATCH RATE" => "COINCIDENCIA\nDIRECCIONAL"
        "CONTEXT ONLY, NOT A TRADE SIGNAL" => "SOLO CONTEXTO, NO ES UNA SEÑAL DE OPERATIVA"
        => en

f_t(string en, string de, string ar, string zh) =>
    language == "Español" ? f_es(en) : language == "Русский" ? f_ru(en) : language == "Deutsch" ? de : language == "العربية" ? ar : language == "中文" ? zh : en

f_color(int id) =>
    color result = C_MUTED
    if id >= 0
        int kind = array.get(kinds, id)
        result := kind == 0 ? C_GREEN : kind == 1 ? C_RED : C_GOLD
    result

f_effect(int id) =>
    string result = f_t("No active window", "Kein aktives Zeitfenster", "لا توجد نافذة نشطة", "当前无活跃窗口")
    if id >= 0
        int kind = array.get(kinds, id)
        result := kind == 0 ? f_t("POSITIVE SEASONAL EFFECT", "POSITIVER SAISONEFFEKT", "تأثير موسمي إيجابي", "积极季节性效应") : kind == 1 ? f_t("DOWNSIDE-RISK WINDOW", "ZEITFENSTER MIT ABWÄRTSRISIKO", "نافذة مخاطر الهبوط", "下行风险窗口") : f_t("BUYBACK SUPPORT", "UNTERSTÜTZUNG DURCH AKTIENRÜCKKÄUFE", "دعم من إعادة شراء الأسهم", "股票回购支撑")
    result

f_effect_detail(int id) =>
    int kind = id >= 0 ? array.get(kinds, id) : -1
    kind == 0 ? f_t("ACTIVITY ↑\nPOSITIVE BIAS", "AKTIVITÄT ↑ • POSITIVES UMFELD", "النشاط ↑ • بيئة إيجابية", "活跃度 ↑ • 积极倾向") : kind == 1 ? f_t("VOLATILITY ↑\nDOWNSIDE RISK", "VOLATILITÄT ↑ • ABWÄRTSRISIKO", "التقلب ↑ • مخاطر هبوط", "波动率 ↑ • 下行风险") : kind == 2 ? f_t("DEMAND SUPPORT\nPRICE ↑", "NACHFRAGESTÜTZE • KURS ↑", "دعم الطلب • السعر ↑", "需求支撑 • 价格 ↑") : f_t("NEUTRAL BACKDROP", "NEUTRALES UMFELD", "بيئة محايدة", "中性背景")

f_plain_meaning(int id) =>
    int kind = id >= 0 ? array.get(kinds, id) : -1
    kind == 0 ? f_t("Stronger sentiment\nand buying activity", "Stärkeres Sentiment\nund mehr Kaufaktivität möglich", "قد يتحسن المزاج الإيجابي\nويزداد نشاط الشراء", "情绪与买盘活跃度\n可能增强") : kind == 1 ? f_t("Sharper price moves;\nhigher downside risk", "Bewegungen können heftiger werden;\nhöheres Abwärtsrisiko als üblich", "قد تصبح التحركات أكثر حدة؛\nمخاطر الهبوط أعلى من المعتاد", "价格波动可能加剧；\n下行风险高于平常") : kind == 2 ? f_t("Buybacks may support\ndemand and price", "Rückkäufe können Nachfrage\nund Kurs stützen", "قد تدعم إعادة الشراء\nالطلب والسعر", "股票回购可能支撑\n需求与价格") : f_t("No clear seasonal bias", "Keine ausgeprägte saisonale Erwartung", "لا يوجد توقع موسمي واضح", "无明显的季节性预期")

f_usage_hint(int id) =>
    int kind = id >= 0 ? array.get(kinds, id) : -1
    kind == 0 ? f_t("Seasonal context\nfavoring upside", "Berücksichtigen als saisonalen\nRückenwind für die Oberseite", "يُعتبر سياقًا موسميًا\nداعمًا للصعود", "作为偏向上涨的\n季节性背景加以参考") : kind == 1 ? f_t("Period of\nelevated risk", "Berücksichtigen als Phase\nmit erhöhtem Risiko", "يُعتبر فترة\nذات مخاطر مرتفعة", "作为风险上升期\n加以参考") : kind == 2 ? f_t("Potential\nmarket support", "Berücksichtigen als mögliche\nMarktstütze", "يُعتبر دعمًا محتملًا\nللسوق", "作为潜在的\n市场支撑加以参考") : f_t("Wait for the\nnext window", "Auf das nächste\nZeitfenster warten", "انتظر النافذة\nالتقويمية التالية", "等待下一个\n日历窗口")

f_event_title(int id) =>
    switch id
        0 => f_t("Q4 earnings season + GDP", "Berichtssaison Q4 + BIP", "نتائج الربع الرابع + الناتج المحلي الإجمالي", "第四季度财报季 + GDP")
        1 => f_t("Futures and options expiration", "Verfall von Futures und Optionen", "استحقاق العقود الآجلة والخيارات", "期货与期权到期")
        2 => f_t("Q1 earnings season + GDP", "Berichtssaison Q1 + BIP", "نتائج الربع الأول + الناتج المحلي الإجمالي", "第一季度财报季 + GDP")
        3 => f_t("Contract expiration", "Kontraktverfall", "استحقاق العقود", "合约到期")
        4 => f_t("Q2 earnings season + GDP", "Berichtssaison Q2 + BIP", "نتائج الربع الثاني + الناتج المحلي الإجمالي", "第二季度财报季 + GDP")
        5 => f_t("Contract expiration", "Kontraktverfall", "استحقاق العقود", "合约到期")
        6 => f_t("Q3 earnings season + GDP", "Berichtssaison Q3 + BIP", "نتائج الربع الثالث + الناتج المحلي الإجمالي", "第三季度财报季 + GDP")
        7 => f_t("Share buybacks", "Aktienrückkäufe", "إعادة شراء الأسهم", "股票回购")
        => f_t("Contract expiration", "Kontraktverfall", "استحقاق العقود", "合约到期")

f_reason(int id) =>
    switch id
        0 => f_t("Start of year;\npositive expectations", "Jahresauftakt,\npositive Erwartungen", "بداية العام،\nتوقعات إيجابية", "年初，\n市场预期偏积极")
        1 => f_t("Profit-taking;\nhigher uncertainty", "Gewinnmitnahmen,\nNervosität", "جني الأرباح،\nتوتر السوق", "获利了结，\n市场情绪紧张")
        2 => f_t("Start of the second quarter", "Beginn des zweiten Quartals", "بداية الربع الثاني", "第二季度开始")
        3 => f_t("Portfolio rebalancing", "Portfolio-Rebalancing", "إعادة موازنة المحافظ", "投资组合再平衡")
        4 => f_t("Earnings season", "Berichtssaison", "موسم نتائج الشركات", "财报季")
        5 => f_t("End of summer;\nprofit-taking", "Sommerende,\nGewinnmitnahmen", "نهاية الصيف،\nجني الأرباح", "夏末，\n获利了结")
        6 => f_t("Start of Q4;\nbuyback expectations", "Beginn von Q4,\nRückkäufe erwartet", "بداية الربع الرابع،\nتوقعات بإعادة الشراء", "第四季度开始，\n预期出现回购")
        7 => f_t("Buybacks may support the market", "Rückkäufe stützen den Markt", "إعادة الشراء تدعم السوق", "股票回购支撑市场")
        => f_t("Year-end;\nposition unwinding", "Jahresende,\nPositionsabbau", "نهاية العام،\nإغلاق المراكز", "年末，\n平仓调整")

f_icon(int id) =>
    int kind = id >= 0 ? array.get(kinds, id) : -1
    kind == 1 ? "▼" : kind >= 0 ? "▲" : "•"

f_card_title(int id) =>
    switch id
        0 => f_t("Q4 + GDP", "Q4 + BIP", "Q4 + GDP", "Q4 + GDP")
        1 => f_t("EXPIRATION", "VERFALL", "الاستحقاق", "到期")
        2 => f_t("Q1 + GDP", "Q1 + BIP", "Q1 + GDP", "Q1 + GDP")
        3 => f_t("EXPIRATION", "VERFALL", "الاستحقاق", "到期")
        4 => f_t("Q2 + GDP", "Q2 + BIP", "Q2 + GDP", "Q2 + GDP")
        5 => f_t("EXPIRATION", "VERFALL", "الاستحقاق", "到期")
        6 => f_t("Q3 + GDP", "Q3 + BIP", "Q3 + GDP", "Q3 + GDP")
        7 => f_t("BUYBACKS", "RÜCKKÄUFE", "إعادة الشراء", "股票回购")
        => f_t("EXPIRATION", "VERFALL", "الاستحقاق", "到期")

f_card_note(int id) =>
    int kind = array.get(kinds, id)
    kind == 0 ? f_t("SEASONALITY", "SAISONALITÄT", "الموسمية", "季节性") : kind == 1 ? f_t("VOLATILITY", "VOLATILITÄT", "التقلب", "波动率") : f_t("SUPPORT", "UNTERSTÜTZUNG", "الدعم", "支撑")

f_card_period(int id) =>
    switch id
        0 => f_t("03–12 JAN", "03.–12. JAN", "03–12 يناير", "1月3–12日")
        1 => f_t("15–22 MAR", "15.–22. MÄR", "15–22 مارس", "3月15–22日")
        2 => f_t("05–10 APR", "05.–10. APR", "05–10 أبريل", "4月5–10日")
        3 => f_t("17–21 JUN", "17.–21. JUN", "17–21 يونيو", "6月17–21日")
        4 => f_t("04–11 JUL", "04.–11. JUL", "04–11 يوليو", "7月4–11日")
        5 => f_t("16–20 SEP", "16.–20. SEP", "16–20 سبتمبر", "9月16–20日")
        6 => f_t("05–10 OCT", "05.–10. OKT", "05–10 أكتوبر", "10月5–10日")
        7 => f_t("01–07 NOV", "01.–07. NOV", "01–07 نوفمبر", "11月1–7日")
        => f_t("16–23 DEC", "16.–23. DEZ", "16–23 ديسمبر", "12月16–23日")

f_full_period(int id) =>
    switch id
        0 => f_t("3–12 January", "3.–12. Januar", "3–12 يناير", "1月3日–12日")
        1 => f_t("15–22 March", "15.–22. März", "15–22 مارس", "3月15日–22日")
        2 => f_t("5–10 April", "5.–10. April", "5–10 أبريل", "4月5日–10日")
        3 => f_t("17–21 June", "17.–21. Juni", "17–21 يونيو", "6月17日–21日")
        4 => f_t("4–11 July", "4.–11. Juli", "4–11 يوليو", "7月4日–11日")
        5 => f_t("16–20 September", "16.–20. September", "16–20 سبتمبر", "9月16日–20日")
        6 => f_t("5–10 October", "5.–10. Oktober", "5–10 أكتوبر", "10月5日–10日")
        7 => f_t("1–7 November", "1.–7. November", "1–7 نوفمبر", "11月1日–7日")
        => f_t("16–23 December", "16.–23. Dezember", "16–23 ديسمبر", "12月16日–23日")

string tz = exchangeZone ? syminfo.timezone : customZone
int yy = year(time, tz)
int mm = month(time, tz)
int dd = dayofmonth(time, tz)
int dateKey = timestamp("Etc/UTC", yy, mm, dd, 0, 0)

int activeId = -1
int nextId = -1
int nextId2 = -1
int nextId3 = -1
int nextDate = na
int nextDate2 = na
int nextDate3 = na
int nextYear = na
int nextYear2 = na
int nextYear3 = na
for i = 0 to array.size(months) - 1
    int eventMonth = array.get(months, i)
    int firstDay = array.get(starts, i)
    int lastDay = array.get(ends, i)
    if mm == eventMonth and dd >= firstDay and dd <= lastDay
        activeId := i
    int candidateYear = yy
    int candidate = timestamp("Etc/UTC", candidateYear, eventMonth, firstDay, 0, 0)
    if candidate <= dateKey
        candidateYear += 1
        candidate := timestamp("Etc/UTC", candidateYear, eventMonth, firstDay, 0, 0)
    if na(nextDate) or candidate < nextDate
        nextDate3 := nextDate2
        nextId3 := nextId2
        nextYear3 := nextYear2
        nextDate2 := nextDate
        nextId2 := nextId
        nextYear2 := nextYear
        nextDate := candidate
        nextId := i
        nextYear := candidateYear
    else if na(nextDate2) or candidate < nextDate2
        nextDate3 := nextDate2
        nextId3 := nextId2
        nextYear3 := nextYear2
        nextDate2 := candidate
        nextId2 := i
        nextYear2 := candidateYear
    else if na(nextDate3) or candidate < nextDate3
        nextDate3 := candidate
        nextId3 := i
        nextYear3 := candidateYear

int daysToNext = int((nextDate - dateKey) / 86400000)
int daysToNext2 = int((nextDate2 - dateKey) / 86400000)
int daysToNext3 = int((nextDate3 - dateKey) / 86400000)
bool supported = timeframe.isintraday or (timeframe.isdaily and timeframe.multiplier == 1)
bool active = supported and activeId >= 0
bool beginning = active and not barstate.isfirst and (activeId != activeId[1] or yy != yy[1])
bool ending = not active and not barstate.isfirst and activeId[1] >= 0
bool upcoming = supported and daysToNext >= 1 and daysToNext <= leadDays
bool warning = upcoming and not barstate.isfirst and (not upcoming[1] or nextDate != nextDate[1])

// ─────────────────────────────────────────────────────────────────────────────
// HISTORICAL STATISTICS FOR THE CURRENT INSTRUMENT
// ─────────────────────────────────────────────────────────────────────────────
var array<float> statMoveSum = array.new_float(9, 0.0)
var array<int> statMatches = array.new_int(9, 0)
var array<int> statSamples = array.new_int(9, 0)
var float trackedEntry = na
var int trackedId = -1

if beginning
    trackedEntry := close
    trackedId := activeId

if ending and trackedId >= 0 and not na(trackedEntry)
    float windowMove = (close[1] / trackedEntry - 1.0) * 100.0
    int trackedKind = array.get(kinds, trackedId)
    bool directionMatched = trackedKind == 1 ? windowMove < 0 : windowMove > 0
    array.set(statMoveSum, trackedId, array.get(statMoveSum, trackedId) + windowMove)
    array.set(statSamples, trackedId, array.get(statSamples, trackedId) + 1)
    if directionMatched
        array.set(statMatches, trackedId, array.get(statMatches, trackedId) + 1)
    trackedEntry := na
    trackedId := -1

f_avg_move(int id) =>
    int samples = id >= 0 ? array.get(statSamples, id) : 0
    samples > 0 ? array.get(statMoveSum, id) / samples : na

f_match_rate(int id) =>
    int samples = id >= 0 ? array.get(statSamples, id) : 0
    samples > 0 ? array.get(statMatches, id) * 100.0 / samples : na

f_quality(float rate, int samples) =>
    samples < 3 ? f_t("LOW DATA", "WENIG DATEN", "بيانات غير كافية", "数据不足") : rate >= 70 ? f_t("STRONG", "STARK", "قوية", "强") : rate >= 55 ? f_t("MODERATE", "MITTEL", "متوسطة", "中") : f_t("WEAK", "SCHWACH", "ضعيفة", "弱")

f_quality_color(float rate, int samples) =>
    samples < 3 ? C_MUTED : rate >= 70 ? C_GREEN : rate >= 55 ? color.rgb(242, 188, 55) : C_RED

// ─────────────────────────────────────────────────────────────────────────────
// LOCAL COLORED ZONES AND TIMELINE
// ─────────────────────────────────────────────────────────────────────────────
float atr = ta.atr(14)
var float viewportHigh = na
var float viewportAtr = na
var array<box> zones = array.new<box>()
var array<int> zoneStartTimes = array.new_int()
var array<int> zoneEndTimes = array.new_int()
var array<line> timelineLines = array.new<line>()
var box activeZone = na

if time < chart.left_visible_bar_time
    viewportHigh := na
    viewportAtr := na
else if time <= chart.right_visible_bar_time
    viewportHigh := na(viewportHigh) ? high : math.max(viewportHigh, high)
    viewportAtr := atr

if showZones and beginning
    float pad = atr * zonePadding
    activeZone := box.new(left = bar_index, top = high + pad, right = bar_index, bottom = low - pad, xloc = xloc.bar_index, border_color = color.new(f_color(activeId), 25), border_width = 1, bgcolor = color.new(f_color(activeId), transparency))
    array.push(zones, activeZone)
    array.push(zoneStartTimes, time)
    array.push(zoneEndTimes, time)
    if array.size(zones) > maxZones
        box.delete(array.shift(zones))
        array.shift(zoneStartTimes)
        array.shift(zoneEndTimes)
else if showZones and active and not na(activeZone)
    float pad = atr * zonePadding
    box.set_right(activeZone, bar_index)
    box.set_top(activeZone, math.max(box.get_top(activeZone), high + pad))
    box.set_bottom(activeZone, math.min(box.get_bottom(activeZone), low - pad))
    if array.size(zoneEndTimes) > 0
        array.set(zoneEndTimes, array.size(zoneEndTimes) - 1, time)

if ending
    activeZone := na

if barstate.islast
    if array.size(timelineLines) > 0
        for i = 0 to array.size(timelineLines) - 1
            line.delete(array.get(timelineLines, i))
    array.clear(timelineLines)

    if showTimeline and array.size(zoneStartTimes) > 0
        float timelineY = nz(viewportHigh, high) + nz(viewportAtr, atr) * timelineGap
        int scaleStart = array.get(zoneStartTimes, 0)
        int scaleEnd = timestamp(tz, yy + 1, 12, 31, 23, 59)
        line baseLine = line.new(scaleStart, timelineY, scaleEnd, timelineY, xloc = xloc.bar_time, color = color.new(C_HEADER, 35), width = 1)
        array.push(timelineLines, baseLine)

        for yearStep = -10 to 1
            int eventYear = yy + yearStep
            for eventId = 0 to array.size(months) - 1
                int eventMonth = array.get(months, eventId)
                int firstDay = array.get(starts, eventId)
                int lastDay = array.get(ends, eventId)
                int eventStart = timestamp(tz, eventYear, eventMonth, firstDay, 0, 0)
                int eventEnd = timestamp(tz, eventYear, eventMonth, lastDay, 23, 59)
                int eventStartKey = timestamp("Etc/UTC", eventYear, eventMonth, firstDay, 0, 0)
                int eventEndKey = timestamp("Etc/UTC", eventYear, eventMonth, lastDay, 0, 0)
                bool eventActive = dateKey >= eventStartKey and dateKey <= eventEndKey
                bool eventFuture = eventStartKey > dateKey
                bool insideScale = eventEnd >= scaleStart and eventStart <= scaleEnd
                int eventAlpha = eventActive ? 0 : eventFuture ? 18 : 52
                int eventWidth = eventActive ? 11 : 8
                if insideScale
                    int clippedStart = math.max(eventStart, scaleStart)
                    int clippedEnd = math.min(eventEnd, scaleEnd)
                    line eventSegment = line.new(clippedStart, timelineY, clippedEnd, timelineY, xloc = xloc.bar_time, color = color.new(f_color(eventId), eventAlpha), width = eventWidth)
                    array.push(timelineLines, eventSegment)

// ─────────────────────────────────────────────────────────────────────────────
// ALERTS — now localized to the selected language
// ─────────────────────────────────────────────────────────────────────────────
// NOTE: alertcondition() titles/messages must be `const string` in Pine v6 — they
// cannot depend on the `language` input, so f_t() cannot be used here (this caused
// compile error CE10123). These two lines stay in English in every language mode,
// exactly like both single-language originals. Only alert() below is localized,
// since alert() accepts `series string`.
alertcondition(notifyStart and beginning, "784 • Calendar window started", "784 Market Seasonality Calendar: an active window has started — {{ticker}}, {{interval}}.")
alertcondition(notifySoon and warning, "784 • Calendar window approaching", "784 Market Seasonality Calendar: the next window is approaching — {{ticker}}, {{interval}}.")
if notifyStart and beginning
    alert("784 MarketAgent | " + syminfo.ticker + " | " + f_full_period(activeId) + " | " + f_event_title(activeId) + " | " + f_effect(activeId), alert.freq_once_per_bar)
else if notifySoon and warning
    alert("784 MarketAgent | " + syminfo.ticker + " | " + f_t("UPCOMING IN ", "IN ", "خلال ", "距离还有 ") + str.tostring(daysToNext) + (language == "Español" and daysToNext == 1 ? " DÍA" : f_t(" DAYS", " TAGEN", " أيام", " 天")) + " | " + f_full_period(nextId), alert.freq_once_per_bar)

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────
string panelPosition = switch corner
    "Top Left" => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left" => position.bottom_left
    => position.top_right
// Cyrillic and German words run noticeably longer than their English source
// strings (compound nouns in German, wider Cyrillic glyphs), which otherwise
// makes the RU/DE panel visibly larger than the EN one at the same size
// setting. Step every text size down by one notch for these two languages so
// the rendered table footprint stays close to the English version.
f_size_down(string sz) =>
    sz == size.huge ? size.large : sz == size.large ? size.normal : sz == size.normal ? size.small : size.tiny

// Apply the same compact typography to longer Spanish headings.
bool compactLang = language == "Русский" or language == "Deutsch" or language == "Español"
string fontSizeBase = panelSize == "Large" ? size.normal : panelSize == "Standard" ? size.small : size.tiny
string infoSizeBase = panelSize == "Large" ? size.large : panelSize == "Standard" ? size.normal : size.small
string headerSizeBase = panelSize == "Large" ? size.huge : panelSize == "Standard" ? size.large : size.normal
string brandSizeBase = panelSize == "Compact" ? size.large : size.huge
string fontSize = compactLang ? f_size_down(fontSizeBase) : fontSizeBase
string infoSize = compactLang ? f_size_down(infoSizeBase) : infoSizeBase
string headerSize = compactLang ? f_size_down(headerSizeBase) : headerSizeBase
string brandSize = compactLang ? f_size_down(brandSizeBase) : brandSizeBase
string uiFont = (language == "العربية" or language == "中文") ? font.family_default : font.family_monospace
string readingAlign = language == "العربية" ? text.align_right : text.align_left
var table panel = table.new(panelPosition, 6, 12, bgcolor = C_BG, frame_color = C_SILVER_DARK, frame_width = 1, border_color = C_SILVER, border_width = 1)

if barstate.isfirst
    table.merge_cells(panel, language == "English" ? 0 : 1, 0, 3, 0)
    table.merge_cells(panel, 4, 0, 5, 0)
    table.merge_cells(panel, 0, 1, 5, 1)
    table.merge_cells(panel, 0, 2, 1, 2)
    table.merge_cells(panel, 2, 2, 3, 2)
    table.merge_cells(panel, 4, 2, 5, 2)
    table.merge_cells(panel, 0, 3, 1, 3)
    table.merge_cells(panel, 2, 3, 3, 3)
    table.merge_cells(panel, 4, 3, 5, 3)
    table.merge_cells(panel, 0, 4, 5, 4)
    table.merge_cells(panel, 0, 5, 5, 5)
    table.merge_cells(panel, 0, 6, 1, 6)
    table.merge_cells(panel, 2, 6, 3, 6)
    table.merge_cells(panel, 4, 6, 5, 6)
    table.merge_cells(panel, 0, 7, 1, 7)
    table.merge_cells(panel, 2, 7, 3, 7)
    table.merge_cells(panel, 4, 7, 5, 7)
    table.merge_cells(panel, 0, 8, 5, 8)
    table.merge_cells(panel, 0, 9, 1, 9)
    table.merge_cells(panel, 2, 9, 3, 9)
    table.merge_cells(panel, 4, 9, 5, 9)
    table.merge_cells(panel, 0, 10, 1, 10)
    table.merge_cells(panel, 2, 10, 3, 10)
    table.merge_cells(panel, 4, 10, 5, 10)
    table.merge_cells(panel, 0, 11, 5, 11)

f_cell(int col, int row, string value, color bg, color fg, string align) =>
    table.cell(panel, col, row, value, bgcolor = bg, text_color = fg, text_size = fontSize, text_halign = align, text_font_family = uiFont)

f_bold_cell(int col, int row, string value, color bg, color fg, string align) =>
    table.cell(panel, col, row, value, bgcolor = bg, text_color = fg, text_size = fontSize, text_halign = align, text_font_family = uiFont, text_formatting = text.format_bold)

f_info_cell(int col, int row, string value, color bg, color fg, string align) =>
    table.cell(panel, col, row, value, bgcolor = bg, text_color = fg, text_size = infoSize, text_halign = align, text_font_family = uiFont)

f_header_cell(int col, string value, color bg, string align, string cellSize) =>
    table.cell(panel, col, 0, value, bgcolor = bg, text_color = color.white, text_size = cellSize, text_halign = align, text_font_family = uiFont, text_formatting = text.format_bold)

if barstate.islast
    if showPanel
        color accent = active ? f_color(activeId) : C_MUTED
        int statsId = active ? activeId : nextId
        int sampleCount = array.get(statSamples, statsId)
        float avgMove = f_avg_move(statsId)
        float matchRate = f_match_rate(statsId)
        string avgText = sampleCount > 0 ? str.tostring(avgMove, "#.##") + "%" : "—"
        string matchText = sampleCount > 0 ? str.tostring(matchRate, "#") + "%" : "—"
        color qualityColor = f_quality_color(matchRate, sampleCount)
        int focusId = active ? activeId : nextId
        int focusYear = active ? yy : nextYear
        int focusKind = array.get(kinds, focusId)
        string currentMode = focusKind == 0 ? f_t("▲ POSITIVE", "▲ POSITIV", "▲ إيجابي", "▲ 积极") : focusKind == 1 ? f_t("▼ RISK", "▼ RISIKO", "▼ مخاطر", "▼ 风险") : f_t("◆ SUPPORT", "◆ UNTERSTÜTZUNG", "◆ دعم", "◆ 支撑")
        string focusState = active ? f_t("ACTIVE WINDOW", "AKTIVES ZEITFENSTER", "النافذة النشطة", "当前窗口") : f_t("NEXT WINDOW", "NÄCHSTES ZEITFENSTER", "النافذة التالية", "下一窗口")
        string statusText = active ? f_t("NOW  •  WINDOW ACTIVE\nBIAS  •  ", "JETZT  •  ZEITFENSTER AKTIV\nTENDENZ  •  ", "الآن  •  النافذة نشطة\nالتوجه  •  ", "当前  •  窗口已激活\n倾向  •  ") + f_effect_detail(activeId) : f_t("NOW  •  NO ACTIVE WINDOW\nNEXT WINDOW BELOW", "JETZT  •  KEIN AKTIVES ZEITFENSTER\nNÄCHSTES ZEITFENSTER UNTEN", "الآن  •  لا توجد نافذة نشطة\nالنافذة التالية أدناه", "当前  •  无活跃窗口\n下一窗口见下方")
        string contextNote = focusState + "  •  " + f_card_period(focusId) + " · " + str.tostring(focusYear) + "\n" + f_t("EVENT", "EREIGNIS", "الحدث", "事件") + "  •  " + f_event_title(focusId) + "\n" + f_t("MEANING", "BEDEUTUNG", "المعنى", "含义") + "  •  " + f_plain_meaning(focusId) + "\n" + f_t("DRIVER", "URSACHE", "السبب", "原因") + "  •  " + f_reason(focusId) + "\n" + f_t("CONSIDER", "EINORDNUNG", "التعامل", "参考") + "  •  " + f_usage_hint(focusId)
        string dayUnit = f_t("D", "T", "يوم", "天")

        if language != "English"
            f_header_cell(0, "784", C_BRAND, text.align_left, brandSize)
        f_header_cell(language == "English" ? 0 : 1, f_t("MARKET\nSEASONALITY", "MARKT-\nSAISONALITÄT", "موسمية\nالسوق", "市场\n季节性"), C_HEADER, readingAlign, headerSize)
        f_header_cell(4, f_t("CALENDAR", "KALENDER", "التقويم", "日历"), C_HEADER, text.align_right, headerSize)
        f_bold_cell(0, 1, statusText, C_CELL_ALT, active ? accent : C_TEXT, readingAlign)
        f_cell(0, 2, f_t("PERIOD", "ZEITRAUM", "الفترة", "周期"), C_CELL, C_MUTED, text.align_center)
        f_cell(2, 2, f_t("MODE", "MODUS", "النمط", "模式"), C_CELL, C_MUTED, text.align_center)
        f_cell(4, 2, f_t("EVENT", "EREIGNIS", "الحدث", "事件"), C_CELL, C_MUTED, text.align_center)
        f_bold_cell(0, 3, not supported ? f_t("1D OR LOWER", "≤ 1 TAG", "يومي أو أقل", "1日或更低") : f_card_period(focusId), C_CELL_ALT, f_color(focusId), text.align_center)
        f_bold_cell(2, 3, currentMode, C_CELL_ALT, f_color(focusId), text.align_center)
        f_bold_cell(4, 3, f_card_title(focusId), C_CELL_ALT, C_TEXT, text.align_center)
        f_info_cell(0, 4, contextNote, C_CELL, C_TEXT, readingAlign)

        f_bold_cell(0, 5, f_t("COLOR GUIDE", "FARBLEGENDE", "دليل الألوان", "颜色说明"), C_SECTION, C_BRAND, readingAlign)
        f_bold_cell(0, 6, (language == "Español" ? f_es("▲ POSITIVE") + "\n" : "▲ POSITIVE\n") + f_t("GREEN", "GRÜN", "أخضر", "绿色"), C_GREEN, color.white, text.align_center)
        f_bold_cell(2, 6, (language == "Español" ? f_es("▼ RISK") + "\n" : "▼ RISK\n") + f_t("RED", "ROT", "أحمر", "红色"), C_RED, color.white, text.align_center)
        f_bold_cell(4, 6, (language == "Español" ? f_es("◆ SUPPORT") + "\n" : "◆ SUPPORT\n") + f_t("GOLD", "GOLD", "ذهبي", "金色"), C_GOLD, color.white, text.align_center)
        f_info_cell(0, 7, f_t("Positive sentiment\nand activity may\nstrengthen", "Positives Sentiment\nund Aktivität können\nzunehmen", "قد يتحسن المزاج\nالإيجابي ويزداد\nالنشاط", "积极情绪与\n市场活跃度\n可能增强"), C_CELL_ALT, C_TEXT, text.align_center)
        f_info_cell(2, 7, f_t("Sharper moves;\ndownside risk\nabove normal", "Heftigere Bewegungen;\nerhöhtes\nAbwärtsrisiko", "تحركات أكثر حدة؛\nمخاطر الهبوط\nأعلى من المعتاد", "波动可能加剧；\n下行风险\n高于平常"), C_CELL_ALT, C_TEXT, text.align_center)
        f_info_cell(4, 7, f_t("Buybacks may\nsupport demand\nand price", "Rückkäufe können\nNachfrage und Kurs\nstützen", "إعادة الشراء قد\nتدعم الطلب\nوالسعر", "股票回购可能\n支撑需求\n与价格"), C_CELL_ALT, C_TEXT, text.align_center)

        f_bold_cell(0, 8, f_t("UPCOMING WINDOWS", "NÄCHSTE ZEITFENSTER", "النوافذ القادمة", "即将到来的窗口"), C_SECTION, C_BRAND, readingAlign)
        f_bold_cell(0, 9, "01  ·  " + str.tostring(daysToNext) + " " + dayUnit + "\n" + f_card_period(nextId) + " · " + str.tostring(nextYear) + "\n" + f_card_title(nextId), color.new(f_color(nextId), 94), f_color(nextId), text.align_center)
        f_bold_cell(2, 9, "02  ·  " + str.tostring(daysToNext2) + " " + dayUnit + "\n" + f_card_period(nextId2) + " · " + str.tostring(nextYear2) + "\n" + f_card_title(nextId2), color.new(f_color(nextId2), 94), f_color(nextId2), text.align_center)
        f_bold_cell(4, 9, "03  ·  " + str.tostring(daysToNext3) + " " + dayUnit + "\n" + f_card_period(nextId3) + " · " + str.tostring(nextYear3) + "\n" + f_card_title(nextId3), color.new(f_color(nextId3), 94), f_color(nextId3), text.align_center)

        f_bold_cell(0, 10, str.tostring(sampleCount) + "\n" + f_t("SAMPLES", "BEOB.", "عينات", "样本"), C_CELL_ALT, C_TEXT, text.align_center)
        f_bold_cell(2, 10, avgText + "\n" + f_t("AVG MOVE", "Ø BEWEG.", "متوسط الحركة", "平均涨跌"), C_CELL_ALT, sampleCount > 0 ? (avgMove >= 0 ? C_GREEN : C_RED) : C_MUTED, text.align_center)
        f_bold_cell(4, 10, matchText + "\n" + f_t("MATCH RATE", "TREFFERQUOTE", "معدل الإصابة", "方向一致率") + "\n" + f_quality(matchRate, sampleCount), C_CELL_ALT, qualityColor, text.align_center)
        f_cell(0, 11, (language == "Español" ? "784 MARKETAGENT  •  CALENDARIO\n" : "784 MARKETAGENT  •  CALENDAR\n") + f_t("CONTEXT ONLY, NOT A TRADE SIGNAL", "NUR KONTEXT, KEIN HANDELSSIGNAL", "للسياق فقط، وليست إشارة تداول", "仅供背景参考，不构成交易信号"), C_HEADER, color.rgb(210, 215, 219), text.align_center)
    else
        table.clear(panel, 0, 0, 5, 11)
````
