# Historical Events for DXY

- url: https://www.tradingview.com/script/eahbermz-historical-events-for-dxy/
- type: indicator
- pine_id: PUB;423d06f9baae4d60a1fbdf3e6e20ca62
- version: 4.0

## Description

Исторические события для DXY для NZT
Индикатор сырой, хотелось бы доработать с вашей помощью

## Source Code

````pine
//@version=6
indicator("DXY Macro Chains & Icons", overlay=true, max_labels_count=500)

// ═══════════════════════════════════════════════════════
// НАСТРОЙКИ
// ═══════════════════════════════════════════════════════
grp_cat = "Фильтр категорий"
show_good     = input.bool(true, "✅ Позитивные события (Рост DXY)", group=grp_cat)
show_neutral  = input.bool(true, "🏦 Нейтральные / ЦБ",             group=grp_cat)
show_warn     = input.bool(true, "⚠️ Предупреждения",                group=grp_cat)
show_bad      = input.bool(true, "🔴 Кризисы (Падение DXY)",        group=grp_cat)
show_severe   = input.bool(true, "💥 Критические события",           group=grp_cat)
show_forecast = input.bool(true, "🔮 Прогнозные зоны",              group=grp_cat)

grp_bg = "Визуал цепочек"
show_chains_bg = input.bool(true, "🌫 Показывать фон и названия цепочек", group=grp_bg)
bg_transp      = input.int(92, "Уровень прозрачности фона (0-100)", minval=0, maxval=100, group=grp_bg)
show_vlines    = input.bool(false, "📏 Вертикальные линии к событиям", group=grp_bg)

// ═══════════════════════════════════════════════════════
// ЦВЕТОВАЯ ГАММА
// ═══════════════════════════════════════════════════════
C_GOOD    = color.new(#27ae60, 0)
C_NEUTRAL = color.new(#2980b9, 0)
C_WARN    = color.new(#e67e22, 0)
C_BAD     = color.new(#c0392b, 0)
C_SEVERE  = color.new(#2c3e50, 0)
C_FCAST   = color.new(#8e44ad, 0)

// Цвета для фона и заголовков
BG_HIST   = color.new(#7f8c8d, bg_transp) 
TXT_HIST  = color.new(#7f8c8d, 0)  
BG_FCAST  = color.new(#8e44ad, bg_transp) 
TXT_FCAST = color.new(#8e44ad, 0)  

// ═══════════════════════════════════════════════════════
// ФУНКЦИИ СОЗДАНИЯ МЕТОК И ЗАГОЛОВКОВ
// ═══════════════════════════════════════════════════════
make_label(dt, title, desc, clr, above, enabled, forecast=false) =>
    if enabled
        if not na(time[1]) and time >= dt and time[1] < dt
            _style = above ? label.style_label_down : label.style_label_up
            _yloc  = above ? yloc.abovebar : yloc.belowbar
            
            _icon = forecast ? "🔮" : 
                     (clr == C_GOOD ? "✅" : 
                      clr == C_NEUTRAL ? "🏦" : 
                       clr == C_WARN ? "⚠️" : 
                        clr == C_BAD ? "🔴" : "💥")
            
            _tt = title + "\n" + "—" + "\n" + desc
            
            label.new(x=bar_index, y=na, text=_icon,
                 yloc=_yloc, color=clr, textcolor=color.white,
                 style=_style, size=size.small, tooltip=_tt)
                 
            if show_vlines
                line.new(x1=bar_index, y1=close, x2=bar_index, y2=close * 1.01, 
                     extend=extend.both, color=color.new(clr, 60), 
                     style=line.style_dotted, width=1)

make_chain_title(dt, txt, is_forecast) =>
    if show_chains_bg
        if not na(time[1]) and time >= dt and time[1] < dt
            _clr = is_forecast ? TXT_FCAST : TXT_HIST
            _spaced_txt = txt + "\n\n\n" 
            label.new(x=bar_index, y=na, text=_spaced_txt, yloc=yloc.abovebar, 
                 color=color.new(color.white, 100), textcolor=_clr, 
                 style=label.style_none, size=size.normal)

// ═══════════════════════════════════════════════════════
// ХРОНОЛОГИЯ И ЦЕПОЧКИ СОБЫТИЙ
// ═══════════════════════════════════════════════════════

// ── ЦЕПОЧКА 1: Крах доткомов (1996 - 2001) ───────────
make_chain_title(timestamp(1996, 12, 5), "КРАХ ДОТКОМОВ", false)
make_label(timestamp(1996, 12, 5), "Иррациональный оптимизм", "Алан Гринспен (ФРС) предупреждает о перегреве фондового рынка.", C_WARN, false, show_warn)
make_label(timestamp(1999, 1, 1), "Рождение Евро", "Введение единой европейской валюты. Крупнейшая ребалансировка DXY (вес евро 57.6%).", C_NEUTRAL, true, show_neutral)
make_label(timestamp(1999, 6, 30), "ФРС повышает ставки", "Начало цикла ужесточения ДКП.", C_NEUTRAL, false, show_neutral)
make_label(timestamp(2000, 3, 10), "Крах доткомов", "Пик пузыря. Начало затяжного падения индексов Nasdaq.", C_BAD, true, show_bad)
make_label(timestamp(2001, 9, 11), "Теракты 9/11", "Краткосрочный шок и паника на биржах.", C_SEVERE, false, show_severe)

// ── ЦЕПОЧКА 2: Ипотечный кризис 2008 (2006 - 2008) ───
make_chain_title(timestamp(2006, 7, 1), "ИПОТЕЧНЫЙ КРИЗИС", false)
make_label(timestamp(2006, 7, 1), "Пик рынка недвижимости", "Продажи домов в США начинают падать.", C_WARN, true, show_warn)
make_label(timestamp(2007, 8, 9), "Шок ликвидности", "BNP Paribas замораживает три фонда из-за 'испарения ликвидности'.", C_BAD, false, show_bad)
make_label(timestamp(2008, 3, 16), "Крах Bear Stearns", "Экстренное поглощение банка JPMorgan.", C_SEVERE, false, show_severe)
make_label(timestamp(2008, 9, 15), "Крах Lehman Bros", "Старт острой фазы мирового финансового кризиса.", C_SEVERE, true, show_severe)
make_label(timestamp(2008, 11, 25), "Запуск QE1", "ФРС начинает выкуп активов. Давление на доллар.", C_BAD, false, show_bad)

// ── ЦЕПОЧКА 3: Долговой кризис Еврозоны (2009 - 2012) 
make_chain_title(timestamp(2009, 10, 20), "КРИЗИС ЕВРОЗОНЫ", false)
make_label(timestamp(2009, 10, 20), "Греция скрывала долги", "Признание огромного дефицита. Давление на евро толкает DXY вверх.", C_GOOD, true, show_good)
make_label(timestamp(2010, 5, 2), "Спасение Греции", "Выделение первого пакета помощи на €110 млрд.", C_NEUTRAL, false, show_neutral)
make_label(timestamp(2011, 8, 5), "Рейтинг США понижен", "S&P снизило кредитный рейтинг США.", C_BAD, true, show_bad)
make_label(timestamp(2012, 7, 26), "Речь Марио Драги", "ЕЦБ обещает спасти евро 'любой ценой'. Восстановление EUR, откат DXY.", C_BAD, false, show_bad)

// ── ЦЕПОЧКА 4: Шок сырья и Brexit (2013 - 2016) ──────
make_chain_title(timestamp(2013, 5, 22), "ШОК СЫРЬЯ И BREXIT", false)
make_label(timestamp(2013, 5, 22), "Taper Tantrum", "Намёк Бернанке на сворачивание QE. Рост доходностей и рост доллара.", C_GOOD, true, show_good)
make_label(timestamp(2014, 11, 27), "Война ОПЕК", "Обвал цен на нефть. Поддержка для энерго-импортеров и доллара.", C_WARN, false, show_warn)
make_label(timestamp(2015, 1, 15), "Отвязка франка", "Шок от ЦБ Швейцарии. Рост волатильности на Forex.", C_SEVERE, true, show_severe)
make_label(timestamp(2016, 6, 23), "Brexit", "Великобритания голосует за выход из ЕС. Бегство в доллар.", C_GOOD, false, show_good)

// ── ЦЕПОЧКА 5: COVID-19 (2019 - 2020) ────────────────
make_chain_title(timestamp(2019, 12, 31), "ПАНДЕМИЯ COVID-19", false)
make_label(timestamp(2019, 12, 31), "Вспышка в Ухане", "Китай уведомляет ВОЗ о пневмонии.", C_WARN, true, show_warn)
make_label(timestamp(2020, 3, 11), "Пандемия COVID-19", "Массовые локдауны. Экстремальный дефицит долларовой ликвидности (Cash is King).", C_SEVERE, false, show_severe)
make_label(timestamp(2020, 3, 23), "Безлимитное QE", "ФРС запускает неограниченный выкуп активов. Начало падения DXY.", C_BAD, true, show_bad)
make_label(timestamp(2020, 4, 20), "Нефть < $0", "Майские фьючерсы WTI уходят в отрицательную зону.", C_SEVERE, false, show_severe)

// ── ЦЕПОЧКА 6: Инфляция и Геополитика (2021 - 2022) ──
make_chain_title(timestamp(2021, 5, 12), "ИНФЛЯЦИЯ И ГЕОПОЛИТИКА", false)
make_label(timestamp(2021, 5, 12), "Инфляционный сюрприз", "CPI США резко ускоряется (4.2%).", C_WARN, true, show_warn)
make_label(timestamp(2021, 11, 30), "Смена риторики ФРС", "Инфляция больше не 'временная'.", C_NEUTRAL, false, show_neutral)
make_label(timestamp(2022, 2, 24), "Геополитический шок", "Начало конфликта в Европе. Мощный уход от риска в доллар.", C_SEVERE, true, show_severe)
make_label(timestamp(2022, 3, 16), "Старт цикла ФРС", "ФРС впервые с 2018 года повышает базовую ставку.", C_GOOD, false, show_good)
make_label(timestamp(2022, 6, 15), "ФРС +75 б.п.", "Рекордное агрессивное повышение ставки.", C_GOOD, true, show_good)

// ── ЦЕПОЧКА 7: Разворот ДКП и Новые реалии (2023 - Начало 2025)
make_chain_title(timestamp(2023, 3, 10), "РАЗВОРОТ ЦИКЛА ДКП", false)
make_label(timestamp(2023, 3, 10), "Крах SVB", "Банкротство Silicon Valley Bank.", C_BAD, false, show_bad)
make_label(timestamp(2023, 12, 13), "Разворот ФРС (Pivot)", "ФРС сигнализирует об окончании цикла. Давление на доллар.", C_BAD, true, show_bad)
make_label(timestamp(2024, 3, 19), "Исторический шаг BOJ", "Банк Японии выходит из отрицательных ставок. Влияние на иену (13.6% в DXY).", C_WARN, false, show_warn)
make_label(timestamp(2024, 6, 6), "Рассинхронизация ЦБ", "ЕЦБ снижает ставку раньше ФРС. Давление на евро толкает DXY вверх.", C_GOOD, true, show_good)
make_label(timestamp(2024, 9, 18), "Первое снижение ФРС", "Начало цикла смягчения в США.", C_BAD, false, show_bad)
make_label(timestamp(2024, 11, 5), "Победа Трампа", "Рынки закладывают проинфляционные тарифы. Импульс роста доллара.", C_GOOD, true, show_good)

// ── ЦЕПОЧКА 8: Эпоха Трампа и Инфляция 2.0 (2025 - Август 2026) 
make_chain_title(timestamp(2025, 1, 20), "ЭПОХА ТРАМПА И ИНФЛЯЦИЯ 2.0", false)
make_label(timestamp(2025, 1, 20), "Инаугурация", "Старт жесткой торговой политики.", C_NEUTRAL, false, show_neutral)
make_label(timestamp(2025, 3, 15), "Новые тарифы", "Пошлины на импорт ослабляют валюты торговых партнеров. DXY растет.", C_GOOD, true, show_good)
make_label(timestamp(2026, 1, 28), "Пауза ФРС", "Остановка снижения ставок из-за упрямой инфляции в США.", C_GOOD, false, show_good)
make_label(timestamp(2026, 5, 14), "Обвал Евро (Агрессия ЕЦБ)", "ЕЦБ ускоряет снижение ставок из-за спада в ЕС. Массовый переток капитала в доллар.", C_GOOD, true, show_good)
make_label(timestamp(2026, 6, 12), "ФРС держит удар", "Сильные данные США. Расширение спреда доходностей толкает DXY к новым максимумам.", C_GOOD, false, show_good)
make_label(timestamp(2026, 7, 29), "Ястребиный раскол в ФРС", "ФРС удержала ставку (3.50-3.75%), но 3 члена FOMC требовали повышения на +25 б.п. Импульс роста DXY.", C_GOOD, true, show_good)
make_label(timestamp(2026, 8, 7), "Слабый NFP и розница", "Отрицательная динамика рынка труда и продаж США усилила ожидания смягчения ДКП. Локальный откат DXY.", C_BAD, false, show_bad)
make_label(timestamp(2026, 8, 19), "Госдолг $40 трлн и Выкуп облигаций", "Минфин США удвоил выкуп долгосрочных Treasuries. Снижение доходностей обвалило DXY на 0.9%.", C_BAD, true, show_bad)
make_label(timestamp(2026, 9, 3), "Спад ISM и JOLTS", "Слабые макроданные и падение вакансий в США усилили опасения рецессии и ожидания смягчения ФРС. Давление на DXY.", C_BAD, true, show_bad)

// ── ЦЕПОЧКА 9: ПРОГНОЗНЫЕ ЗОНЫ (Конец 2026 - 2027) ───────────
make_chain_title(timestamp(2026, 9, 15), "ПРОГНОЗ: ДОЛГОВОЙ СТРЕСС И QE 2.0", true)
make_label(timestamp(2026, 9, 15), "Кризис госдолга", "Стоимость обслуживания долга США достигает критических отметок. Угроза для доллара.", C_FCAST, true, show_forecast, forecast=true)
make_label(timestamp(2026, 11, 3), "Промежуточные выборы", "Политическая турбулентность в Конгрессе, угроза шатдауна.", C_FCAST, false, show_forecast, forecast=true)
make_label(timestamp(2027, 3, 20), "Экстренная ликвидность", "Ожидание возвращения QE для спасения долгового рынка. Риск обвала DXY.", C_FCAST, true, show_forecast, forecast=true)

// ═══════════════════════════════════════════════════════
// ЛОГИКА ФОНОВОЙ ПОДСВЕТКИ ЦЕПОЧЕК
// ═══════════════════════════════════════════════════════
in_range(start_t, end_t) => time >= start_t and time <= end_t

c1 = in_range(timestamp(1996, 12, 5), timestamp(2001, 9, 11))
c2 = in_range(timestamp(2006, 7, 1),  timestamp(2008, 11, 25))
c3 = in_range(timestamp(2009, 10, 20), timestamp(2012, 7, 26))
c4 = in_range(timestamp(2013, 5, 22), timestamp(2016, 6, 23))
c5 = in_range(timestamp(2019, 12, 31), timestamp(2020, 4, 20))
c6 = in_range(timestamp(2021, 5, 12), timestamp(2022, 6, 15))
c7 = in_range(timestamp(2023, 3, 10), timestamp(2024, 11, 5))
c8 = in_range(timestamp(2025, 1, 20), timestamp(2026, 8, 23))
c9 = in_range(timestamp(2026, 9, 15), timestamp(2027, 3, 20))

in_hist_chain = c1 or c2 or c3 or c4 or c5 or c6 or c7 or c8
in_fcast_chain = c9

bg_color = show_chains_bg ? (in_hist_chain ? BG_HIST : in_fcast_chain ? BG_FCAST : na) : na

bgcolor(bg_color, title="Фон цепочек")
````
