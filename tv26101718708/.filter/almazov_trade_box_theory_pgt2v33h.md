# Almazov Trade: Box Theory

- url: https://www.tradingview.com/script/PgT2v33h-almazov-trade-box-theory/
- type: indicator
- pine_id: PUB;32b0e23c2d7d4456af44560ae30a7ff1
- version: 1.0

## Description

[b]Almazov Trade: Box Theory[/b]

Almazov Trade: Box Theory is an open-source indicator that identifies confirmed intraday rejection setups within the previous trading day's range.

It constructs the daily range from chart bars, marks configurable upper and lower zones, and applies a wick-and-body candle filter. Confirmed setups receive hypothetical entry, stop-loss and take-profit levels. The script tracks one active setup at a time and displays completed signal outcomes.

[b]Daily range and zones[/b]

The script accumulates highs and lows from the current chart timeframe without requesting daily prices through request.security().

Daily periods follow the instrument's daily-session timestamps, independently of the user's local timezone or chart display timezone. On the first available bar of a new daily period, the preceding period's accumulated high and low become the reference range. The new bar belongs only to the new period.

An initial partial day at the beginning of loaded history is excluded. Signals require an available, positive reference range. After non-trading days, the reference is the preceding available trading-day period, not necessarily yesterday's calendar date.

For previous-day high H, low L and range D = H − L:
[list]
[*]Lower zone: L to L + D × zone percentage / 100.
[*]Upper zone: H − D × zone percentage / 100 to H.
[*]Midpoint: (H + L) / 2.
[/list]

The default zone width is 25% on each side. A candle interacts with a zone when its high-to-low range intersects it; closing inside the zone is not required.

If any current-day candle trades strictly above H or below L, new entries are disabled until the next daily period. An exact boundary touch does not invalidate the range. The breach candle cannot generate an entry, and returning inside the range does not restore eligibility that day.

Invalidated zones remain visible. An already active setup is not closed by range invalidation.

[b]Rejection-candle filter[/b]

“John Wick candle” is the name used for the following configurable filter:
[list]
[*]Body = absolute difference between close and open.
[*]Upper wick = high − max(open, close).
[*]Lower wick = min(open, close) − low.
[*]Wick ratios use an effective body of max(actual body, minimum price tick).
[*]Body percentage uses the actual body divided by the full candle range.
[/list]

A bullish candle requires a sufficiently long lower wick, a limited upper wick and a sufficiently small body. A bearish candle uses the inverse conditions. The full candle range must be positive.

Defaults are a main wick of at least 2.0 effective bodies, an opposite wick of at most 0.5 effective bodies, and an actual body of at most 35% of the candle range.

The direction filter is enabled by default: LONG requires close > open; SHORT requires close < open. Disabling it removes only this direction requirement. The minimum-tick body adjustment also allows meaningful wick comparisons for zero-body candles.

[b]Signals and setup management[/b]

LONG requires a qualifying bullish candle intersecting the lower zone; SHORT requires a qualifying bearish candle intersecting the upper zone.

A signal is confirmed at candle close only when the reference range remains valid, no setup is active, no setup has exited on that same candle, and the entry-to-stop distance is strictly greater than one minimum price tick. If both directions qualify, LONG has priority.

The hypothetical entry is the signal candle's close. Only one setup can be active, but multiple sequential setups per day are possible. Another entry may occur on a later candle after an exit if the range remains valid.

For LONG, the stop is below the previous-day low; for SHORT, above the previous-day high. The default buffer is one price tick. The initial entry-to-stop distance defines 1R, and the default target is 2R:
[list]
[*]LONG target = entry + initial risk × target multiple.
[*]SHORT target = entry − initial risk × target multiple.
[/list]

Entry, stop and target remain fixed across day changes and range invalidation. There are no partial exits, trailing stops, breakeven adjustments or end-of-day exits.

[b]Exit confirmation and label placement[/b]

Stop and target checks begin on the candle after entry. A touch, including equality, qualifies, but the exit is recorded only when that candle closes.

If one candle touches both levels, SL takes priority. The script does not reconstruct their intrabar order.

Exit markers identify the event candle:
[list]
[*]LONG TP and SHORT SL are placed at its high.
[*]LONG SL and SHORT TP are placed at its low.
[/list]

These marker positions are not execution prices. Entry and exit signals are not shifted into earlier bars.

[b]Display and alerts[/b]

The upper reference zone is red, the lower zone teal, and the midpoint grey. Active entry, stop and target lines are white, red and green. Risk shading is purple; potential-reward shading is green.

Active levels and fills stop being plotted on the confirmed exit candle. Entry and exit labels remain subject to the 500-label limit: older labels may disappear while their outcomes remain counted.

All display switches are enabled by default. Hiding zones, labels, candle colouring, levels or the table does not disable calculations or alert conditions. The midpoint has its own display switch.

Four alerts are available: LONG, SHORT, TP and SL. They confirm at candle close; exit alerts report a completed candle's level touch, not immediate execution. Create the required alerts in TradingView using “Once Per Bar Close”.

[b]Hypothetical statistics[/b]

The table summarizes completed setups on loaded chart history:
[list]
[*]Closed signals: completed setups, excluding the active one.
[*]TP / SL: target and stop counts.
[*]TP rate: TP count / closed signals × 100; displayed as 0% when none have closed.
[*]Gross R: each TP adds the selected target multiple; each SL subtracts 1R.
[*]Status: active LONG/SHORT takes priority; otherwise “Box invalid” or “No signal”.
[/list]

“No signal” means idle and does not guarantee that a reference range is already available.

[quote]This is a simplified signal-outcome calculation, not a Strategy Tester report or actual trading history. Entry is assumed at the signal close; outcomes are fixed at −1R or the target multiple. Fees, spread, slippage, funding, liquidity, position sizing, leverage and gap execution are not modeled. Gross R is not percentage return or account equity, and historical results do not establish future profitability.[/quote]

[b]Timeframes and historical behaviour[/b]

Use standard, time-based intraday candles with enough history to form a completed reference day. Daily and higher intervals are rejected, as are chart candles extending outside their assigned daily boundaries: their highs and lows cannot be accurately split between days.

The range reflects available chart bars and session settings. Missing bars affect it, and it may differ from a separately supplied daily feed. Synthetic charts such as Heikin Ashi or Renko are unsuitable for interpreting outcomes as executable market prices.

The script does not use future daily prices. Entries and exits require closed candles, while the developing candle and range-invalidation status can update intrabar. Changes to data, loaded history, sessions, timeframe or inputs can change the reconstructed ranges and subsequent setup sequence.

[b]Implementation and purpose[/b]

Previous-day ranges and rejection candles are established concepts. This implementation combines internal daily aggregation, percentage-based setup locations, explicit candle filters, day-long invalidation after a boundary breach, and non-overlapping setup tracking.

These rules provide a consistent, inspectable way to study the setup. Default values are starting parameters, not claimed optimal settings. The indicator does not place orders or establish a proven trading advantage. Its source is open for inspection.

[b]Interface translations and settings[/b]

The interface uses Russian. English equivalents and input limits are listed below.

[i]Groups[/i]
[list]
[*]«Диапазон предыдущего дня» — Previous-day range.
[*]«Свеча Джона Уика» — John Wick candle.
[*]«Управление сделкой» — Trade management.
[*]«Отображение» — Display.
[/list]

[i]Calculation settings[/i]
[list]
[*]«Верхняя / нижняя зона, %» — Upper / lower zone, %. Default 25; range 1–49; step 1.
[*]«Мин. отношение основной тени к телу» — Minimum main-wick/body ratio. Default 2.0; minimum 0.1; step 0.1.
[*]«Макс. отношение противоположной тени к телу» — Maximum opposite-wick/body ratio. Default 0.5; minimum 0; step 0.1.
[*]«Макс. доля тела в диапазоне свечи, %» — Maximum body / candle range, %. Default 35; range 1–100; step 1.
[*]«Учитывать направление свечи» — Require candle direction. Default enabled. Tooltip: “For LONG, the candle close must be above its open; for SHORT, below.”
[*]«Тейк-профит, R» — Take-profit, R. Default 2.0; minimum 0.1; step 0.1.
[*]«Отступ стоп-лосса, тиков» — Stop-loss buffer, ticks. Default 1; range 0–1000.
[/list]

[i]Display settings[/i]
[list]
[*]«Показывать зоны» — Show zones.
[*]«Показывать линию 50%» — Show the 50% line.
[*]«Показывать метки входов, тейков и стопов» — Show entry, TP and SL labels.
[*]«Окрашивать сигнальные свечи» — Colour signal candles.
[*]«Показывать уровни входа, стопа и тейка» — Show entry, stop and target levels.
[*]«Показывать условную статистику сигналов» — Show hypothetical signal statistics.
[/list]

Statistics tooltip: “Simplified signal outcomes on loaded chart history, not a Strategy Tester report. Entry is assumed at the signal close. Exits are checked from the next candle and confirmed at its close. If one candle touches both stop and target, the stop is counted. Outcomes are fixed at −1R or the target multiple. Fees, slippage and gap execution are excluded. Results depend on timeframe and available history. Only one signal is active at a time; multiple signals per day are possible. Day changes and range invalidation do not close an active signal.”

[i]Plots and fills[/i]
[list]
[*]«Максимум предыдущего дня» / «Минимум предыдущего дня» — Previous-day high / Previous-day low.
[*]«Граница зоны шорта» / «Граница зоны лонга» — Short-zone boundary / Long-zone boundary.
[*]«Середина диапазона предыдущего дня» — Previous-day range midpoint.
[*]«Зона шорта» / «Зона лонга» — Short zone / Long zone.
[*]«Вход» / «Стоп-лосс» / «Тейк-профит» — Entry / Stop-loss / Take-profit.
[*]«Риск» / «Потенциальная прибыль» — Risk / Potential reward.
[/list]

[i]Table[/i]
[list]
[*]«Условные результаты» — Hypothetical outcomes.
[*]«Закрытые сигналы» — Closed signals.
[*]«Тейк / Стоп» — TP / SL.
[*]«Доля тейков» — TP rate.
[*]«Сумма R до издержек» — Gross R before costs.
[*]«Статус» — Status.
[*]«Комиссии / проскальзывание» — Fees / slippage.
[*]«Не учтены» — Not included.
[*]«ЛОНГ» / «ШОРТ» — LONG / SHORT.
[*]«Диапазон аннулирован» — Box invalid.
[*]«Нет сигнала» — No signal.
[/list]

[i]Alerts[/i]
[list]
[*]«Box Theory: лонг» — “Box Theory: LONG”; message: “Box Theory: LONG signal confirmed at bar close.”
[*]«Box Theory: шорт» — “Box Theory: SHORT”; message: “Box Theory: SHORT signal confirmed at bar close.”
[*]«Box Theory: тейк-профит» — “Box Theory: take-profit”; message: “Box Theory: take-profit touch confirmed at bar close.”
[*]«Box Theory: стоп-лосс» — “Box Theory: stop-loss”; message: “Box Theory: stop-loss touch confirmed at bar close.”
[/list]

[i]Runtime messages[/i]
[list]
[*]«Используйте внутридневный таймфрейм — меньше одного дня.» — “Use an intraday timeframe — less than one day.”
[*]«Свеча текущего таймфрейма пересекает границу дневной сессии. Выберите меньший таймфрейм, свечи которого укладываются в дневную сессию.» — “A chart candle crosses a daily-session boundary. Select a smaller timeframe whose candles fit within the daily session.”
[/list]

[b]РУССКАЯ ВЕРСИЯ[/b]

[b]Almazov Trade: Box Theory[/b]

Almazov Trade: Box Theory — индикатор с открытым кодом для поиска подтверждённых внутридневных свечных сетапов отторжения цены внутри диапазона предыдущего торгового дня.

Он самостоятельно формирует дневной диапазон из свечей графика, выделяет настраиваемые верхнюю и нижнюю зоны и применяет фильтр соотношения теней и тела. Для подтверждённых сетапов отображаются условные уровни входа, стопа и тейка. Одновременно сопровождается один сетап; завершённые сигналы учитываются в таблице.

[b]Дневной диапазон и зоны[/b]

Максимум и минимум дня накапливаются из свечей текущего таймфрейма без запроса дневных цен через request.security().

Границы периодов определяются дневной сессией инструмента и не зависят от местного времени пользователя или часового пояса отображения графика. На первом доступном баре нового дневного периода накопленные экстремумы предыдущего становятся опорными. Новый бар относится только к новому периоду.

Первый неполный день в начале загруженной истории исключается. Для сигналов нужен доступный диапазон положительной ширины. После неторговых дней используется предыдущий доступный торговый дневной период, а не обязательно вчерашняя календарная дата.

При максимуме предыдущего дня H, минимуме L и диапазоне D = H − L:
[list]
[*]Нижняя зона: от L до L + D × процент зоны / 100.
[*]Верхняя зона: от H − D × процент зоны / 100 до H.
[*]Середина: (H + L) / 2.
[/list]

По умолчанию каждая зона занимает 25% диапазона. Для взаимодействия достаточно пересечения зоны диапазоном свечи от минимума до максимума; закрытие внутри зоны не требуется.

Если любая свеча текущего дня проходит строго выше H или ниже L, новые входы запрещаются до следующего дневного периода. Точное касание границы диапазон не аннулирует. На свече пробоя вход невозможен, а возврат внутрь диапазона не возобновляет поиск сигналов в тот же день.

Аннулированные зоны остаются видимыми. Уже активный сетап при аннулировании не закрывается.

[b]Свечной фильтр[/b]

«Свеча Джона Уика» — название следующего настраиваемого фильтра:
[list]
[*]Тело — абсолютная разница между закрытием и открытием.
[*]Верхняя тень — максимум минус большее из открытия и закрытия.
[*]Нижняя тень — меньшее из открытия и закрытия минус минимум.
[*]Для отношений теней к телу используется большее из фактического тела и минимального ценового тика.
[*]Доля тела рассчитывается по фактическому телу относительно полного диапазона свечи.
[/list]

Бычья свеча должна иметь достаточно длинную нижнюю тень, ограниченную верхнюю тень и небольшое тело. Для медвежьей условия зеркальные. Полный диапазон свечи должен быть положительным.

По умолчанию основная тень составляет не меньше 2,0 расчётных тел, противоположная — не больше 0,5, фактическое тело — не больше 35% диапазона свечи.

Фильтр направления включён: для LONG закрытие выше открытия, для SHORT — ниже. Его отключение убирает только это требование. Ограничение расчётного тела минимальным тиком сохраняет смысл сравнения теней и для свечей с нулевым телом.

[b]Сигналы и сопровождение[/b]

LONG требует подходящей бычьей свечи, пересекающей нижнюю зону; SHORT — подходящей медвежьей свечи, пересекающей верхнюю.

Сигнал подтверждается на закрытии свечи, если опорный диапазон действителен, активного сетапа нет, на этой же свече не завершился предыдущий сетап, а расстояние от входа до стопа строго больше минимального ценового тика. При одновременном выполнении обоих условий приоритет имеет LONG.

Условный вход — закрытие сигнальной свечи. Одновременно активен один сетап, но за день возможно несколько последовательных входов. После выхода новый сигнал разрешён на более поздней свече, если диапазон остаётся действительным.

Стоп LONG располагается ниже минимума предыдущего дня, стоп SHORT — выше максимума. Отступ по умолчанию равен одному ценовому тику. Исходное расстояние от входа до стопа определяет 1R; тейк по умолчанию — 2R:
[list]
[*]Тейк LONG = вход + исходный риск × множитель тейка.
[*]Тейк SHORT = вход − исходный риск × множитель тейка.
[/list]

Вход, стоп и тейк фиксированы и сохраняются при смене дня и аннулировании диапазона. Частичных выходов, переноса стопа, безубытка и закрытия в конце дня нет.

[b]Подтверждение выхода и положение меток[/b]

Проверка стопа и тейка начинается со следующей после входа свечи. Касание, включая точное равенство, учитывается, но выход фиксируется только после закрытия этой свечи.

Если свеча касается обоих уровней, засчитывается SL. Последовательность касаний внутри свечи не восстанавливается.

Метки выхода обозначают свечу события:
[list]
[*]TP лонга и SL шорта располагаются на её максимуме.
[*]SL лонга и TP шорта — на её минимуме.
[/list]

Положение метки не является ценой исполнения. Сигналы входа и выхода не смещаются на более ранние свечи.

[b]Отображение и оповещения[/b]

Верхняя опорная зона красная, нижняя бирюзовая, середина серая. Активные уровни входа, стопа и тейка — белый, красный и зелёный. Заливка риска фиолетовая, потенциальной прибыли — зелёная.

Активные уровни и заливки перестают отображаться на свече подтверждённого выхода. Метки входов и выходов ограничены общим лимитом 500: старые метки могут исчезать, хотя их исходы остаются в статистике.

Все параметры отображения включены по умолчанию. Скрытие зон, меток, окрашивания свечей, уровней или таблицы не отключает расчёты и условия оповещений. Середина диапазона включается отдельно.

Доступны четыре оповещения: LONG, SHORT, TP и SL. Они подтверждаются на закрытии свечи; оповещение о выходе сообщает о касании уровня завершённой свечой, а не о мгновенном исполнении. Нужные оповещения создаются в TradingView с частотой «Один раз при закрытии бара».

[b]Условная статистика[/b]

Таблица учитывает завершённые сетапы на загруженной истории:
[list]
[*]Закрытые сигналы — завершённые сетапы, без активного.
[*]Тейк / Стоп — количество исходов по тейку и стопу.
[*]Доля тейков — количество тейков / закрытые сигналы × 100; до первого закрытия отображается 0%.
[*]Сумма R до издержек — каждый тейк добавляет выбранный множитель, каждый стоп вычитает 1R.
[*]Статус — сначала активный «ЛОНГ»/«ШОРТ»; при их отсутствии — «Диапазон аннулирован» или «Нет сигнала».
[/list]

«Нет сигнала» означает отсутствие активного сетапа, но не гарантирует наличие сформированного опорного диапазона.

[quote]Это упрощённый расчёт исходов сигналов, а не отчёт тестера стратегий или история реальной торговли. Вход предполагается по закрытию сигнальной свечи; исходы фиксируются как −1R или множитель тейка. Комиссии, спред, проскальзывание, финансирование, ликвидность, размер позиции, плечо и исполнение при ценовых разрывах не моделируются. Сумма R не является процентной доходностью или капиталом счёта; исторические результаты не подтверждают будущую прибыльность.[/quote]

[b]Таймфреймы и поведение на истории[/b]

Используйте обычные внутридневные свечи, сформированные по времени, и историю, достаточную для накопления завершённого дня. Дневные и более высокие интервалы запрещены. Ошибка также возникает, если свеча выходит за границы соответствующей дневной сессии: её экстремумы нельзя точно разделить между днями.

Диапазон зависит от доступных свечей и настроек сессии. Пропуски данных влияют на него; он может отличаться от отдельного дневного потока котировок. Синтетические графики, например Heikin Ashi и Renko, не подходят для трактовки исходов как исполнения по реальным рыночным ценам.

Будущие дневные цены не используются. Входы и выходы требуют закрытых свечей, но формирующаяся свеча и статус аннулирования могут обновляться внутри бара. Изменение данных, загруженной истории, сессии, таймфрейма или настроек может изменить диапазоны и последующую последовательность сетапов.

[b]Особенности реализации и назначение[/b]

Диапазон предыдущего дня и свечи отторжения — известные концепции. В этой реализации объединены самостоятельное накопление дневного диапазона, процентные зоны поиска, формальные свечные фильтры, запрет входов до конца дня после пробоя границы и сопровождение неперекрывающихся сетапов.

Эти правила позволяют последовательно и наглядно изучать сетап. Значения по умолчанию — исходные параметры, а не заявленные оптимальные настройки. Индикатор не исполняет ордера и не подтверждает наличие торгового преимущества. Исходный код открыт для проверки.

[b]Настройки[/b]

Параметры распределены по группам «Диапазон предыдущего дня», «Свеча Джона Уика», «Управление сделкой» и «Отображение».
[list]
[*]«Верхняя / нижняя зона, %» — по умолчанию 25; диапазон 1–49; шаг 1.
[*]«Мин. отношение основной тени к телу» — по умолчанию 2,0; минимум 0,1; шаг 0,1.
[*]«Макс. отношение противоположной тени к телу» — по умолчанию 0,5; минимум 0; шаг 0,1.
[*]«Макс. доля тела в диапазоне свечи, %» — по умолчанию 35; диапазон 1–100; шаг 1.
[*]«Учитывать направление свечи» — включено. Подсказка уточняет: для лонга закрытие выше открытия, для шорта — ниже.
[*]«Тейк-профит, R» — по умолчанию 2,0; минимум 0,1; шаг 0,1.
[*]«Отступ стоп-лосса, тиков» — по умолчанию 1; диапазон 0–1000.
[/list]

Параметры отображения: «Показывать зоны», «Показывать линию 50%», «Показывать метки входов, тейков и стопов», «Окрашивать сигнальные свечи», «Показывать уровни входа, стопа и тейка», «Показывать условную статистику сигналов».

Подсказка статистики раскрывает те же допущения: вход по закрытию, проверка выхода со следующей свечи, подтверждение на закрытии, приоритет стопа при двойном касании, фиксированный результат в R, отсутствие комиссий, проскальзывания и моделирования гэпов, зависимость от истории и таймфрейма, один активный сигнал и возможность нескольких входов за день, сохранение активного сигнала при смене дня и аннулировании диапазона.

В настройках стиля доступны максимум и минимум предыдущего дня, границы и заливки зон лонга/шорта, середина диапазона, вход, стоп-лосс, тейк-профит, риск и потенциальная прибыль. Таблица обозначена как «Условные результаты», а комиссии и проскальзывание — «Не учтены».

Оповещения называются «Box Theory: лонг», «Box Theory: шорт», «Box Theory: тейк-профит» и «Box Theory: стоп-лосс». Их сообщения уточняют, что соответствующий сигнал или касание подтверждены на закрытии свечи.

Сообщения об ошибках требуют выбрать внутридневный таймфрейм меньше одного дня либо меньший таймфрейм, свечи которого не пересекают границы дневной сессии.

## Source Code

````pine
//@version=6
indicator("Almazov Trade: Box Theory", overlay = true, max_labels_count = 500)

if barstate.isfirst
    if not timeframe.isintraday
        runtime.error("Используйте внутридневный таймфрейм — меньше одного дня.")

string GROUP_BOX = "Диапазон предыдущего дня"
string GROUP_WICK = "Свеча Джона Уика"
string GROUP_TRADE = "Управление сделкой"
string GROUP_VIEW = "Отображение"

float zonePct = input.float(25.0, "Верхняя / нижняя зона, %", minval=1.0, maxval=49.0, step=1.0, group=GROUP_BOX, display=display.none)

float minMainWickBody = input.float(2.0, "Мин. отношение основной тени к телу", minval=0.1, step=0.1, group=GROUP_WICK, display=display.none)
float maxOppWickBody = input.float(0.5, "Макс. отношение противоположной тени к телу", minval=0.0, step=0.1, group=GROUP_WICK, display=display.none)
float maxBodyPct = input.float(35.0, "Макс. доля тела в диапазоне свечи, %", minval=1.0, maxval=100.0, step=1.0, group=GROUP_WICK, display=display.none)
bool requireDirection = input.bool(true, "Учитывать направление свечи", tooltip="Для лонга закрытие свечи должно быть выше открытия, для шорта — ниже.", group=GROUP_WICK, display=display.none)

float rr = input.float(2.0, "Тейк-профит, R", minval=0.1, step=0.1, group=GROUP_TRADE, display=display.none)
int slBufferTicks = input.int(1, "Отступ стоп-лосса, тиков", minval=0, maxval=1000, group=GROUP_TRADE, display=display.none)

bool showZones = input.bool(true, "Показывать зоны", group=GROUP_VIEW, display=display.none)
bool showMid = input.bool(true, "Показывать линию 50%", group=GROUP_VIEW, display=display.none)
bool showSignals = input.bool(true, "Показывать метки входов, тейков и стопов", group=GROUP_VIEW, display=display.none)
bool colorSignalBars = input.bool(true, "Окрашивать сигнальные свечи", group=GROUP_VIEW, display=display.none)
bool showTradeLevels = input.bool(true, "Показывать уровни входа, стопа и тейка", group=GROUP_VIEW, display=display.none)
bool showStats = input.bool(true, "Показывать условную статистику сигналов", tooltip="Упрощённый расчёт исходов сигналов на загруженной истории графика, а не отчёт тестера стратегий. Вход предполагается по цене закрытия сигнальной свечи. Проверка выходов начинается со следующей свечи, результат подтверждается на её закрытии. Если одна свеча касается и стопа, и тейка, засчитывается стоп. Результат фиксируется как -1R или выбранный множитель тейка. Комиссии, проскальзывание и исполнение при ценовых разрывах не учитываются. Результаты зависят от таймфрейма и доступной истории. Одновременно активен только один сигнал, но за день возможно несколько сигналов. Смена дня и аннулирование диапазона не закрывают активный сигнал.", group=GROUP_VIEW, display=display.none)


int dayStart = time("1D")
int dayEnd = time_close("1D")
bool newDay = timeframe.change("1D")

if time<dayStart or time_close>dayEnd
    runtime.error("Свеча текущего таймфрейма пересекает границу дневной сессии. Выберите меньший таймфрейм, свечи которого укладываются в дневную сессию.")

var float currentDayHigh = na
var float currentDayLow = na
var float prevDayHigh = na
var float prevDayLow = na
var bool fullDay = false

if barstate.isfirst
    currentDayHigh:=high
    currentDayLow:=low
    fullDay:=time==dayStart
else if newDay
    prevDayHigh:=fullDay ? currentDayHigh : na
    prevDayLow:=fullDay ? currentDayLow : na
    currentDayHigh:=high
    currentDayLow:=low
    fullDay:=true
else
    currentDayHigh:=math.max(currentDayHigh, high)
    currentDayLow:=math.min(currentDayLow, low)

float dayRange = prevDayHigh-prevDayLow
bool validBox = not na(prevDayHigh) and not na(prevDayLow) and dayRange>0.0
float mid = validBox ? (prevDayHigh+prevDayLow)*0.5 : na
float lowerZoneTop = validBox ? prevDayLow+dayRange*zonePct/100.0 : na
float upperZoneBottom = validBox ? prevDayHigh-dayRange*zonePct/100.0 : na


var bool dayInvalidated = false

if newDay
    dayInvalidated:=false

bool previousHighTaken = validBox and high>prevDayHigh
bool previousLowTaken = validBox and low<prevDayLow

if previousHighTaken or previousLowTaken
    dayInvalidated:=true


float candleRange = high-low
float body = math.abs(close-open)
float safeBody = math.max(body, syminfo.mintick)
float upperWick = high-math.max(open, close)
float lowerWick = math.min(open, close)-low
float bodyPct = candleRange>0.0 ? body/candleRange*100.0 : 100.0

bool bullishJohnWick = candleRange>0.0 and lowerWick>=safeBody*minMainWickBody and upperWick<=safeBody*maxOppWickBody and bodyPct<=maxBodyPct and (not requireDirection or close>open)
bool bearishJohnWick = candleRange>0.0 and upperWick>=safeBody*minMainWickBody and lowerWick<=safeBody*maxOppWickBody and bodyPct<=maxBodyPct and (not requireDirection or close<open)

bool inLongZone = validBox and low<=lowerZoneTop and high>=prevDayLow
bool inShortZone = validBox and high>=upperZoneBottom and low<=prevDayHigh


var bool tradeActive = false
var int tradeDir = 0
var int entryBar = na
var float entryPrice = na
var float stopPrice = na
var float takePrice = na

var int closedTrades = 0
var int wins = 0
var int losses = 0
var float totalR = 0.0

bool tradeClosedThisBar = false
bool tpHitThisBar = false
bool slHitThisBar = false


if tradeActive and bar_index>entryBar and barstate.isconfirmed
    bool hitStop = tradeDir==1 ? low<=stopPrice : high>=stopPrice
    bool hitTake = tradeDir==1 ? high>=takePrice : low<=takePrice

    if hitStop
        tradeActive:=false
        tradeClosedThisBar:=true
        slHitThisBar:=true
        closedTrades+=1
        losses+=1
        totalR-=1.0
        if showSignals
            label.new(bar_index, tradeDir==1 ? low : high, "SL", yloc=yloc.price, style=tradeDir==1 ? label.style_label_up : label.style_label_down, color=color.red, textcolor=color.white, size=size.tiny)
    else if hitTake
        tradeActive:=false
        tradeClosedThisBar:=true
        tpHitThisBar:=true
        closedTrades+=1
        wins+=1
        totalR+=rr
        if showSignals
            label.new(bar_index, tradeDir==1 ? high : low, "TP", yloc=yloc.price, style=tradeDir==1 ? label.style_label_down : label.style_label_up, color=color.green, textcolor=color.white, size=size.tiny)


float longSL = validBox ? prevDayLow-slBufferTicks*syminfo.mintick : na
float shortSL = validBox ? prevDayHigh+slBufferTicks*syminfo.mintick : na

float longRisk = validBox ? close-longSL : na
float shortRisk = validBox ? shortSL-close : na

bool longRiskValid = validBox and longRisk>syminfo.mintick
bool shortRiskValid = validBox and shortRisk>syminfo.mintick

bool longSignal = barstate.isconfirmed and not tradeActive and not tradeClosedThisBar and not dayInvalidated and inLongZone and bullishJohnWick and longRiskValid
bool shortSignal = barstate.isconfirmed and not tradeActive and not tradeClosedThisBar and not dayInvalidated and inShortZone and bearishJohnWick and shortRiskValid


if longSignal
    tradeActive:=true
    tradeDir:=1
    entryBar:=bar_index
    entryPrice:=close
    stopPrice:=longSL

    float risk = entryPrice-stopPrice
    takePrice:=entryPrice+risk*rr

    if showSignals
        label.new(bar_index, low, "LONG", style=label.style_label_up, color=color.rgb(38, 166, 154), textcolor=color.white, size=size.small)
else if shortSignal
    tradeActive:=true
    tradeDir:=-1
    entryBar:=bar_index
    entryPrice:=close
    stopPrice:=shortSL

    float risk = stopPrice-entryPrice
    takePrice:=entryPrice-risk*rr

    if showSignals
        label.new(bar_index, high, "SHORT", style=label.style_label_down, color=color.rgb(239, 83, 80), textcolor=color.white, size=size.small)


color highColor = color.rgb(239, 83, 80)
color lowColor = color.rgb(38, 166, 154)
color midColor = color.rgb(120, 123, 134)

pHigh = plot(showZones ? prevDayHigh : na, "Максимум предыдущего дня", color=highColor, linewidth=2, style=plot.style_stepline, display=display.pane)
pUpperZone = plot(showZones ? upperZoneBottom : na, "Граница зоны шорта", color=color.new(highColor, 55), linewidth=1, style=plot.style_stepline, display=display.pane)
pLow = plot(showZones ? prevDayLow : na, "Минимум предыдущего дня", color=lowColor, linewidth=2, style=plot.style_stepline, display=display.pane)
pLowerZone = plot(showZones ? lowerZoneTop : na, "Граница зоны лонга", color=color.new(lowColor, 55), linewidth=1, style=plot.style_stepline, display=display.pane)

plot(showMid ? mid : na, "Середина диапазона предыдущего дня", color=color.new(midColor, 15), linewidth=1, style=plot.style_stepline, display=display.pane)

fill(pHigh, pUpperZone, color=showZones ? color.new(highColor, 89) : na, title="Зона шорта")
fill(pLow, pLowerZone, color=showZones ? color.new(lowColor, 89) : na, title="Зона лонга")

barcolor(colorSignalBars ? longSignal ? lowColor : shortSignal ? highColor : na : na)


float activeEntryPlot = showTradeLevels and tradeActive ? entryPrice : na
float activeStopPlot = showTradeLevels and tradeActive ? stopPrice : na
float activeTakePlot = showTradeLevels and tradeActive ? takePrice : na

pEntry = plot(activeEntryPlot, "Вход", color=color.white, linewidth=2, style=plot.style_linebr, display=display.pane)
pStop = plot(activeStopPlot, "Стоп-лосс", color=color.red, linewidth=2, style=plot.style_linebr, display=display.pane)
pTake = plot(activeTakePlot, "Тейк-профит", color=color.green, linewidth=2, style=plot.style_linebr, display=display.pane)

fill(pEntry, pStop, color=showTradeLevels and tradeActive ? color.new(color.purple, 75) : na, title="Риск")
fill(pEntry, pTake, color=showTradeLevels and tradeActive ? color.new(color.green, 90) : na, title="Потенциальная прибыль")


color tableHeader = color.rgb(74, 96, 166)
color tableBg = color.rgb(64, 67, 76)
color tableLabel = color.rgb(190, 192, 199)

var table stats = table.new(position.top_right, 2, 7, bgcolor=tableBg, frame_color=color.rgb(205, 205, 205), frame_width=1, border_color=color.rgb(205, 205, 205), border_width=1)

if barstate.islast
    if showStats
        float winRate = closedTrades>0 ? wins*100.0/closedTrades : 0.0
        string status = tradeActive ? tradeDir==1 ? "ЛОНГ" : "ШОРТ" : dayInvalidated ? "Диапазон аннулирован" : "Нет сигнала"
        color statusColor = tradeActive ? tradeDir==1 ? color.lime : color.red : dayInvalidated ? color.orange : color.white
        color totalRColor = totalR>0 ? color.lime : totalR<0 ? color.red : color.white

        table.cell(stats, 0, 0, "Условные результаты", bgcolor=tableHeader, text_color=color.white, text_halign=text.align_left, text_size=size.small)
        table.cell(stats, 1, 0, timeframe.period, bgcolor=tableHeader, text_color=color.white, text_halign=text.align_right, text_size=size.small)

        table.cell(stats, 0, 1, "Закрытые сигналы", bgcolor=tableBg, text_color=tableLabel, text_halign=text.align_center, text_size=size.small)
        table.cell(stats, 1, 1, str.tostring(closedTrades), bgcolor=tableBg, text_color=color.white, text_halign=text.align_right, text_size=size.small)

        table.cell(stats, 0, 2, "Тейк / Стоп", bgcolor=tableBg, text_color=tableLabel, text_halign=text.align_center, text_size=size.small)
        table.cell(stats, 1, 2, str.tostring(wins)+" / "+str.tostring(losses), bgcolor=tableBg, text_color=color.white, text_halign=text.align_right, text_size=size.small)

        table.cell(stats, 0, 3, "Доля тейков", bgcolor=tableBg, text_color=tableLabel, text_halign=text.align_center, text_size=size.small)
        table.cell(stats, 1, 3, str.tostring(winRate, "#.0")+"%", bgcolor=tableBg, text_color=color.white, text_halign=text.align_right, text_size=size.small)

        table.cell(stats, 0, 4, "Сумма R до издержек", bgcolor=tableBg, text_color=tableLabel, text_halign=text.align_center, text_size=size.small)
        table.cell(stats, 1, 4, str.tostring(totalR, "#.##"), bgcolor=tableBg, text_color=totalRColor, text_halign=text.align_right, text_size=size.small)

        table.cell(stats, 0, 5, "Статус", bgcolor=tableBg, text_color=tableLabel, text_halign=text.align_center, text_size=size.small)
        table.cell(stats, 1, 5, status, bgcolor=tableBg, text_color=statusColor, text_halign=text.align_right, text_size=size.small)

        table.cell(stats, 0, 6, "Комиссии / проскальзывание", bgcolor=tableBg, text_color=tableLabel, text_halign=text.align_center, text_size=size.small)
        table.cell(stats, 1, 6, "Не учтены", bgcolor=tableBg, text_color=color.white, text_halign=text.align_right, text_size=size.small)
    else
        table.clear(stats, 0, 0, 1, 6)


alertcondition(longSignal, "Box Theory: лонг", "Box Theory: сигнал в лонг подтверждён на закрытии свечи")
alertcondition(shortSignal, "Box Theory: шорт", "Box Theory: сигнал в шорт подтверждён на закрытии свечи")
alertcondition(tpHitThisBar, "Box Theory: тейк-профит", "Box Theory: касание тейк-профита подтверждено на закрытии свечи")
alertcondition(slHitThisBar, "Box Theory: стоп-лосс", "Box Theory: касание стоп-лосса подтверждено на закрытии свечи")
````
