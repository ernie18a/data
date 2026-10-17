# Almazov Trade: SMT Monitor

- url: https://www.tradingview.com/script/EQdixAnY-almazov-trade-smt-monitor/
- type: indicator
- pine_id: PUB;1cb8d9d0cdbb491fa46be2262447372e
- version: 1.0

## Description

[b]Almazov Trade: SMT Monitor[/b]

An open-source multi-symbol swing-level monitor. It tracks confirmed swing highs and lows, identifies when price moves strictly beyond those levels, and compares the current states and percentage distances of selected instruments in one table. The chart also displays the current symbol's active and most recently swept swing levels.

[b]Customizable table size and coin list[/b]

[b]You can change the table size and add coins directly in the indicator settings.[/b]

[list]
[*][b]Table → Text size:[/b] select Tiny, Small, Normal or Large (default: Normal). Font size is selected separately; table row heights adapt to the chart pane. Table → Language switches RU/EN (default: EN).
[*][b]Coins: main / Coins: extra:[/b] enable or disable any of 16 preset coins or replace their TradingView tickers. Fourteen presets are initially enabled; AAVE and FLOKI are off.
[*][b]Свои инструменты / Custom symbols:[/b] add up to 10 symbols: choose a ticker [b]and tick the checkbox next to that slot's number[/b] (1–10), then apply the settings. Selecting a ticker alone does not enable its row (e.g., select BYBIT:UNIUSDT.P in slot 1 and tick “1”). The chart symbol is added automatically and duplicate base assets are omitted from comparison rows.
[/list]

Despite its name, the script does not automatically detect classical Smart Money Technique (SMT) divergence: it does not pair extrema across instruments by time or issue cross-market divergence signals. Instead, it provides structured information for manual comparison.

[b]Symbols and data[/b]

The current chart symbol is always included. There are 16 presets: BTC, ETH, SOL, XRP, BNB, DOGE, SUI, HYPE, LINK, PEPE, ADA, AAVE, NEAR, AVAX, TRUMP and FLOKI. [b]Fourteen are enabled by default[/b]; AAVE, FLOKI and all ten custom slots are disabled. Presets now use [b]USDT perpetual futures[/b] from Binance, except HYPE (Bybit); each ticker can be changed. PEPE and FLOKI use 1000-token contracts (BINANCE:1000PEPEUSDT.P and BINANCE:1000FLOKIUSDT.P), displayed as PEPE and FLOKI. This choice affects defaults only: spot and other markets can be selected manually. The chart instrument is taken directly from the open chart, so open a futures chart to compare futures consistently. Previously saved indicator settings may retain spot tickers; change them manually or reset to the new defaults. A blank custom-symbol field resolves to the chart symbol; it does not select a new asset.

Enabled comparisons use request.security() on the chart's timeframe, with lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off, and invalid-symbol handling. Swing calculations are independent for each symbol. No higher-timeframe confirmation or correlation filter is used. The table excludes duplicate base assets (including the chart symbol), keeping the first eligible entry in settings order; XBT is treated as BTC, 1000PEPE as PEPE and 1000FLOKI as FLOKI. Duplicate slots may still use data requests.

[b]Confirmed swings and swept levels[/b]

A Swing High is the highest High, and a Swing Low the lowest Low, in a configurable window of 2 × d + 1 candles. High and Low use independent widths, default d = 2 (range 1–60). Equal neighboring extremes are permitted. A pivot becomes available only after the required right-side candles have closed; the implementation registers it on the following bar and anchors its line to the original pivot candle.

For each instrument, two monotonic stacks retain unswept highs and lows. A newly confirmed High replaces earlier stack entries at or below its price; a new Low replaces entries at or above its price. The stack's last element is the nearest retained level in that direction. Replacement by a newer pivot is not treated as a sweep.

A High is swept when the current bar's High is [b]strictly above[/b] the level; a Low is swept when its Low is [b]strictly below[/b] the level. Equality does not qualify. Neither a closing-price break nor a return into the previous range is required. One candle can sweep several levels or both sides. In each direction, the script remembers the most extreme level swept on that bar.

The last swept High/Low remains recorded until a newly confirmed swing on the same side resets it or another sweep on that side replaces it. Thus, a check mark in the table can refer to a previous bar, not necessarily the current one.

[b]Table: states and distances[/b]

The table is vertically centered on the right and occupies approximately 86% of the chart pane height, leaving about 7% above and below. Row heights adapt to the chart size and number of displayed symbols; headings, separators and the explanatory block use separate proportions. Font size is selected independently (Tiny, Small, Normal or Large), without automatic reduction, so many rows may crowd a small chart. The upper Swing High and lower Swing Low sections are separated visually. The chart symbol is pinned first and highlighted in both; other symbols are ranked independently for each side.

[list]
[*]○ — an unswept level is available; the main Δ shows the unsigned distance to that level.
[*]✓ — a swept level is retained; Δ shows the signed position of price relative to that swept level.
[*]— — current data are available but neither relevant level is available.
[*]! — data are unavailable or not aligned with the chart's current bar.
[/list]

The percentages are based on [b]each symbol's own current close[/b]:

[pine]
Untaken: 100 * abs(level - close) / close
Taken:   100 * (close - sweptLevel) / close
Next:    100 * abs(nextLevel - close) / close
[/pine]

In ✓ mode, a positive Δ means price is above the swept level and a negative Δ means below it; this sign is [i]not[/i] a buy/sell direction. The Next Swing column appears only when a swept level is recorded and another unswept level remains. Values are displayed to two decimals. Hover tooltips show price, level and calculation context.

Ranking is context-dependent. If the chart symbol has a retained sweep on that side, instruments with retained sweeps are listed before unswept instruments; ranking then prioritizes distances to active remaining swing levels. Otherwise, unswept instruments appear first and are ranked by distance to the nearest active level; swept instruments follow, ranked by absolute distance to their swept levels. Unavailable data appear last, and ties preserve the original input order. Sorting uses unrounded values.

[b]Chart levels and alerts[/b]

Only the current chart symbol receives lines. The nearest unswept Swing High (red by default) and Swing Low (green) use solid lines. The last retained swept levels use lighter dashed lines and labels marked “снят” / “taken”. Lines extend right from the original pivot timestamps. At most four levels are shown; older levels are updated or replaced rather than archived.

Three alerts are provided for [b]the chart symbol only[/b]: Swing High taken, Swing Low taken, and Any swing taken. Comparisons in the table do not have their own alert conditions. A sweep can be detected during a developing candle; alerts are not inherently restricted to candle close. Choose the TradingView alert frequency according to the desired behavior.

[b]Limitations and implementation[/b]

Use standard time-based charts; synthetic and tick-based charts are rejected. Data are considered current only when the remote symbol's bar-open time matches the current chart bar and a positive close is available. This does not guarantee synchronized quote updates within the bar. Prices, sweep states, percentages and row rankings can change before the current candle closes.

The comparison list is not synchronized by historical pivot or sweep time. Two ✓ statuses may refer to events on different candles. Some instruments or exchanges may have unavailable, missing or differently timed bars. Request, memory and execution limits of Pine Script also apply; the swing stacks have an explicit collection-size guard. Historical results depend on available chart data and settings.

[quote]This is an informational comparison tool, not an automatic SMT-divergence detector, trade-entry system, backtest or promise of predictive performance. No entries, stops, take-profits, broker orders or cross-symbol divergence alerts are generated.[/quote]

[b]Implementation and settings[/b]

Confirmed swings and price-level sweeps are established concepts. This implementation combines independent monotonic level stacks for multiple symbols, persistent swept-level states, dynamically sorted distance tables, freshness checks, and a small set of continuously updated chart levels for the current instrument.

The interface supports RU/EN table text (default: EN) and four table-font sizes (Tiny, Small, Normal, Large; default: Normal). Default swing widths are 2 bars on each side. Swing High is red and Swing Low green by default. Input values are hidden from the chart status line.

[i]Russian interface translations[/i]

[list]
[*]«Swing high: баров слева и справа» / «Swing low: баров слева и справа» — Swing High / Swing Low: bars on each side.
[*]«Язык» — Language (default EN); «Размер текста» — Text size (default Normal); «Свои инструменты» — Custom symbols; «Тикер» — Symbol. A custom symbol must also be enabled with the checkbox for its numbered slot.
[*]«Монета» — Coin; «След. свинг» — Next Swing; «снят» — taken / swept; «Цена» — Price. Contract names 1000PEPE and 1000FLOKI are shown as PEPE and FLOKI.
[*]«○ До следующего свинга» — ○ To next swing; «✓ От уровня снятия» — ✓ From swept level.
[*]«Нет доступного уровня или актуальных данных» — No available level or current data.
[*]«Положение цены относительно снятого: + выше, − ниже» — Position relative to swept level: positive above, negative below.
[*]«Расстояние до ближайшего неснятого свинга» — Distance to the nearest unswept swing; «Расстояние до следующего неснятого свинга в стеке» — Distance to the next unswept swing in the stack.
[*]«Используйте обычный временной график» — Use a standard time-based chart; «Стек превысил лимит коллекции Pine» — Swing stack exceeds Pine collection limit.
[/list]

[b]РУССКАЯ ВЕРСИЯ[/b]

[b]Almazov Trade: SMT Monitor[/b]

Индикатор с открытым кодом для сравнения состояния структурных Swing High и Swing Low на нескольких инструментах. Он показывает ближайшие неснятые уровни, фиксирует снятие свингов и рассчитывает процентные расстояния в таблице. На самом графике рисуются уровни только текущего инструмента.

[b]Размер таблицы и добавление монет[/b]

[b]В настройках индикатора можно менять размер таблицы и самостоятельно добавлять монеты для сравнения.[/b]

[list]
[*][b]Table → «Размер текста / Text size»:[/b] четыре варианта: Tiny, Small, Normal и Large (по умолчанию Normal). Высота строк автоматически подстраивается под график, а размер шрифта выбирается отдельно. «Язык / Language» переключает RU/EN (по умолчанию EN).
[*][b]Coins: main / Coins: extra:[/b] 16 готовых монет; [b]14 включены по умолчанию[/b], AAVE и FLOKI выключены. Можно менять галочки и тикеры.
[*][b]«Свои инструменты / Custom symbols»:[/b] 10 дополнительных слотов. [b]Выберите тикер, затем обязательно поставьте галочку слева от номера слота (1–10) и примените настройки.[/b] Сам выбор тикера строку не добавляет (например, для UNI выберите BYBIT:UNIUSDT.P в слоте 1 и включите галочку «1»). Текущий инструмент включён автоматически; повторы одной базовой монеты скрываются.
[/list]

[b]Важно:[/b] индикатор не определяет классическую SMT-дивергенцию автоматически. Он не сопоставляет экстремумы разных монет по времени и не выдаёт сигналы расхождения. Монитор предоставляет данные для самостоятельного сравнения.

[b]Монеты и таймфрейм[/b]

Доступны 16 предустановленных монет (BTC, ETH, SOL, XRP, BNB, DOGE, SUI, HYPE, LINK, PEPE, ADA, AAVE, NEAR, AVAX, TRUMP, FLOKI) и 10 дополнительных слотов. По умолчанию включены все, кроме AAVE и FLOKI. [b]Предустановленные тикеры теперь — бессрочные USDT-фьючерсы Binance; для HYPE — Bybit.[/b] PEPE и FLOKI используют контракты 1000PEPEUSDT.P и 1000FLOKIUSDT.P, но в таблице подписываются PEPE и FLOKI. Выбор спота вручную не запрещён. Текущий инструмент берётся с открытого графика, поэтому для сравнения фьючерсов откройте фьючерсный график. В старых сохранённых настройках могут остаться спотовые тикеры — измените их вручную или сбросьте настройки индикатора. Пустое поле пользовательского тикера означает инструмент графика, а не новую монету.

Текущий инструмент всегда присутствует в таблице. Остальные загружаются через request.security() на таймфрейме графика и обрабатываются независимо. Повторы одной базовой монеты исключаются, остаётся первый по порядку настроек. В проверке дублей XBT приравнивается к BTC, 1000PEPE — к PEPE, а 1000FLOKI — к FLOKI.

[b]Свинг и снятие уровня[/b]

Swing High/Low — экстремум окна из 2 × d + 1 свечей. Для максимума и минимума ширина настраивается отдельно: от 1 до 60 свечей с каждой стороны, по умолчанию 2. Свинг подтверждается только после формирования правой части окна; линия привязана к исходной свече экстремума.

Для каждого инструмента поддерживаются стеки ещё не снятых High и Low. Ближайший уровень — последний элемент соответствующего стека. Новый подтверждённый свинг может заменить более слабые или равные уровни, не формируя события снятия.

[list]
[*]High считается снятым, когда High свечи строго выше уровня.
[*]Low считается снятым, когда Low свечи строго ниже уровня.
[*]Точное касание не считается снятием. Закрытие за уровнем и возврат обратно не требуются.
[*]При снятии нескольких уровней сохраняется крайний. Снятый уровень остаётся в памяти до нового подтверждённого свинга той же стороны либо следующего снятия этой стороны.
[/list]

[b]Таблица и расчёт процентов[/b]

Таблица расположена справа по центру и занимает примерно 86% высоты графика, оставляя около 7% сверху и снизу. Высота строк подстраивается под окно и количество монет; заголовки, разделители и пояснения имеют отдельные пропорции. Шрифт регулируется независимо (Tiny, Small, Normal, Large), без автоматического уменьшения, поэтому на маленьком графике при большом числе строк текст может не помещаться. Верхняя секция — Swing High, нижняя — Swing Low. Текущий инструмент закреплён первой строкой; остальные монеты сортируются независимо в обеих секциях.

[list]
[*]○ — доступен неснятый свинг; Δ показывает расстояние до него: 100 × |уровень − close| / close.
[*]✓ — сохранён снятый свинг; Δ показывает 100 × (close − снятый уровень) / close. Плюс означает цену выше уровня, минус — ниже.
[*]«След. свинг» — расстояние до следующего неснятого уровня, если после снятия он существует.
[*]— — доступных уровней нет; ! — данные отсутствуют или не совпадают по времени бара.
[/list]

Значения нормируются на Close соответствующей монеты, выводятся с двумя знаками после запятой. Знак Δ не является торговым сигналом. Если на графике сохранено снятие нужной стороны, приоритет в сортировке получают монеты со снятыми уровнями; иначе — без снятия. Затем учитываются расстояния до активных или снятых уровней. Неактуальные строки опускаются вниз.

[b]Уровни и уведомления[/b]

На основном графике сплошными линиями показаны ближайшие неснятые Swing High (красный) и Swing Low (зелёный). Пунктиром — последние сохранённые снятые уровни с подписью «снят». Линии начинаются от свечей экстремумов и продолжаются вправо. Старые линии заменяются, отдельный архив не ведётся.

Доступны три алерта [b]только для текущего инструмента[/b]: снятие Swing High, снятие Swing Low и снятие любого из них. Они могут срабатывать при формировании текущей свечи; частота определяется настройкой уведомления. Снятия других монет не создают отдельных алертов.

[b]Ограничения и особенности[/b]

Используйте обычные временные графики. Данные внешней монеты считаются актуальными, если время открытия её свечи совпадает с текущей свечой графика и доступна цена Close. Это не гарантирует синхронного обновления котировок внутри свечи. Таблица и состояния могут меняться в реальном времени.

Снятия у разных монет не сопоставляются по времени: две галочки ✓ могут относиться к разным историческим событиям. Пропуски котировок, ограничения запросов TradingView и доступная история влияют на результаты. Индикатор не открывает сделки и не рассчитывает SL/TP.

[quote]Это аналитический монитор, а не автоматический детектор SMT-дивергенций или торговая стратегия. Отображаемые уровни и расстояния не гарантируют будущего движения цены.[/quote]

[b]Настройки[/b]

Группы Swings, Table, Chart, Coins: main, Coins: extra и «Свои инструменты / Custom symbols» позволяют изменить ширину свингов, язык таблицы (EN по умолчанию), размер (Normal по умолчанию), цвета уровней и список монет. Чтобы добавить монету, недостаточно выбрать тикер: [b]нужно включить галочку соответствующего слота[/b]. Значения параметров скрыты из строки статуса. Переводы русских подписей, подсказок и сообщений об ошибках приведены выше.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Algorithms_ATS


//@version=6
indicator("Almazov Trade: SMT Monitor", overlay=true, dynamic_requests=true, max_bars_back=125, max_lines_count=10, max_labels_count=10)

int D_swing_high = input.int(2, "Swing high: баров слева и справа / Bars each side", minval=1, maxval=60, display=display.none, group="Swings")
int D_swing_low = input.int(2, "Swing low: баров слева и справа / Bars each side", minval=1, maxval=60, display=display.none, group="Swings")
string lang = input.string("EN", "Язык / Language", options=["RU", "EN"], display=display.none, group="Table")
string text_size = input.string(size.normal, "Размер текста / Text size", options=[size.tiny, size.small, size.normal, size.large], display=display.none, group="Table")

int table_font = text_size==size.tiny ? 8 : text_size==size.small ? 10 : text_size==size.normal ? 14 : 20
int current_font = table_font+2
int secondary_font = math.max(6, table_font-2)
color high_color = input.color(color.rgb(205, 73, 88), "Swing High", display=display.none, group="Chart")
color low_color = input.color(color.rgb(26, 149, 112), "Swing Low", display=display.none, group="Chart")

var array< bool > show_coin = array.new<bool>(0)
var array< string > symbols = array.new<string>(0)
if barstate.isfirst
    show_coin.push(input.bool(true, "BTC", inline="BTC", group="Coins: main", display=display.none))
    symbols.push(input.symbol("BINANCE:BTCUSDT.P", "", inline="BTC", group="Coins: main", display=display.none))
    show_coin.push(input.bool(true, "ETH", inline="ETH", group="Coins: main", display=display.none))
    symbols.push(input.symbol("BINANCE:ETHUSDT.P", "", inline="ETH", group="Coins: main", display=display.none))
    show_coin.push(input.bool(true, "SOL", inline="SOL", group="Coins: main", display=display.none))
    symbols.push(input.symbol("BINANCE:SOLUSDT.P", "", inline="SOL", group="Coins: main", display=display.none))
    show_coin.push(input.bool(true, "XRP", inline="XRP", group="Coins: main", display=display.none))
    symbols.push(input.symbol("BINANCE:XRPUSDT.P", "", inline="XRP", group="Coins: main", display=display.none))
    show_coin.push(input.bool(true, "BNB", inline="BNB", group="Coins: main", display=display.none))
    symbols.push(input.symbol("BINANCE:BNBUSDT.P", "", inline="BNB", group="Coins: main", display=display.none))
    show_coin.push(input.bool(true, "DOGE", inline="DOGE", group="Coins: extra", display=display.none))
    symbols.push(input.symbol("BINANCE:DOGEUSDT.P", "", inline="DOGE", group="Coins: extra", display=display.none))
    show_coin.push(input.bool(true, "SUI", inline="SUI", group="Coins: extra", display=display.none))
    symbols.push(input.symbol("BINANCE:SUIUSDT.P", "", inline="SUI", group="Coins: extra", display=display.none))
    show_coin.push(input.bool(true, "HYPE", inline="HYPE", group="Coins: extra", display=display.none))
    symbols.push(input.symbol("BYBIT:HYPEUSDT.P", "", inline="HYPE", group="Coins: extra", display=display.none))
    show_coin.push(input.bool(true, "LINK", inline="LINK", group="Coins: extra", display=display.none))
    symbols.push(input.symbol("BINANCE:LINKUSDT.P", "", inline="LINK", group="Coins: extra", display=display.none))
    show_coin.push(input.bool(true, "PEPE", inline="PEPE", group="Coins: extra", display=display.none))
    symbols.push(input.symbol("BINANCE:1000PEPEUSDT.P", "", inline="PEPE", group="Coins: extra", display=display.none))
    show_coin.push(input.bool(true, "ADA", inline="ADA", group="Coins: extra", display=display.none))
    symbols.push(input.symbol("BINANCE:ADAUSDT.P", "", inline="ADA", group="Coins: extra", display=display.none))
    show_coin.push(input.bool(false, "AAVE", inline="AAVE", group="Coins: extra", display=display.none))
    symbols.push(input.symbol("BINANCE:AAVEUSDT.P", "", inline="AAVE", group="Coins: extra", display=display.none))
    show_coin.push(input.bool(true, "NEAR", inline="NEAR", group="Coins: extra", display=display.none))
    symbols.push(input.symbol("BINANCE:NEARUSDT.P", "", inline="NEAR", group="Coins: extra", display=display.none))
    show_coin.push(input.bool(true, "AVAX", inline="AVAX", group="Coins: extra", display=display.none))
    symbols.push(input.symbol("BINANCE:AVAXUSDT.P", "", inline="AVAX", group="Coins: extra", display=display.none))
    show_coin.push(input.bool(true, "TRUMP", inline="TRUMP", group="Coins: extra", display=display.none))
    symbols.push(input.symbol("BINANCE:TRUMPUSDT.P", "", inline="TRUMP", group="Coins: extra", display=display.none))
    show_coin.push(input.bool(false, "FLOKI", inline="FLOKI", group="Coins: extra", display=display.none))
    symbols.push(input.symbol("BINANCE:1000FLOKIUSDT.P", "", inline="FLOKI", group="Coins: extra", display=display.none))

    show_coin.push(input.bool(false, "1", inline="custom_1", group="Свои инструменты / Custom symbols", display=display.none))
    symbols.push(input.symbol("", "Тикер / Symbol", inline="custom_1", group="Свои инструменты / Custom symbols", display=display.none))
    show_coin.push(input.bool(false, "2", inline="custom_2", group="Свои инструменты / Custom symbols", display=display.none))
    symbols.push(input.symbol("", "Тикер / Symbol", inline="custom_2", group="Свои инструменты / Custom symbols", display=display.none))
    show_coin.push(input.bool(false, "3", inline="custom_3", group="Свои инструменты / Custom symbols", display=display.none))
    symbols.push(input.symbol("", "Тикер / Symbol", inline="custom_3", group="Свои инструменты / Custom symbols", display=display.none))
    show_coin.push(input.bool(false, "4", inline="custom_4", group="Свои инструменты / Custom symbols", display=display.none))
    symbols.push(input.symbol("", "Тикер / Symbol", inline="custom_4", group="Свои инструменты / Custom symbols", display=display.none))
    show_coin.push(input.bool(false, "5", inline="custom_5", group="Свои инструменты / Custom symbols", display=display.none))
    symbols.push(input.symbol("", "Тикер / Symbol", inline="custom_5", group="Свои инструменты / Custom symbols", display=display.none))
    show_coin.push(input.bool(false, "6", inline="custom_6", group="Свои инструменты / Custom symbols", display=display.none))
    symbols.push(input.symbol("", "Тикер / Symbol", inline="custom_6", group="Свои инструменты / Custom symbols", display=display.none))
    show_coin.push(input.bool(false, "7", inline="custom_7", group="Свои инструменты / Custom symbols", display=display.none))
    symbols.push(input.symbol("", "Тикер / Symbol", inline="custom_7", group="Свои инструменты / Custom symbols", display=display.none))
    show_coin.push(input.bool(false, "8", inline="custom_8", group="Свои инструменты / Custom symbols", display=display.none))
    symbols.push(input.symbol("", "Тикер / Symbol", inline="custom_8", group="Свои инструменты / Custom symbols", display=display.none))
    show_coin.push(input.bool(false, "9", inline="custom_9", group="Свои инструменты / Custom symbols", display=display.none))
    symbols.push(input.symbol("", "Тикер / Symbol", inline="custom_9", group="Свои инструменты / Custom symbols", display=display.none))
    show_coin.push(input.bool(false, "10", inline="custom_10", group="Свои инструменты / Custom symbols", display=display.none))
    symbols.push(input.symbol("", "Тикер / Symbol", inline="custom_10", group="Свои инструменты / Custom symbols", display=display.none))

type mypair
    float q
    int tm

type mydata
    float hg
    float lw
    float last_high
    float last_low
    float cl
    int tm
    string base

type levelview
    line ln
    label lb

is_swing_high(int d)=>
    float mx = ta.highest(high, 2*d+1)
    not na(high[2*d+1]) and high[d+1]==mx[1]

is_swing_low(int d)=>
    float mn = ta.lowest(low, 2*d+1)
    not na(low[2*d+1]) and low[d+1]==mn[1]

push_swing(array< mypair > stack, float q, int tm, bool high_side)=>
    while stack.size()>0
        bool replace_top = high_side ? stack.last().q<=q : stack.last().q>=q
        if replace_top
            stack.pop()
        else
            break
    if stack.size()>=100000
        runtime.error("Swing stack exceeds Pine collection limit. / Стек превысил лимит коллекции Pine.")
    stack.push(mypair.new(q, tm))

pop_swept(array< mypair > stack, float price, bool high_side)=>
    float taken_q = na
    int taken_tm = na
    while stack.size()>0
        bool swept = high_side ? price>stack.last().q : price<stack.last().q
        if swept
            mypair last = stack.pop()
            taken_q:=last.q
            taken_tm:=last.tm
        else
            break
    [taken_q, taken_tm]

is_sweep_bar(int taken_tm, int current_tm)=>
    not na(taken_tm) and taken_tm==current_tm

get_values()=>
    var array< mypair > swinghigh = array.new<mypair>(0)
    var array< mypair > swinglow = array.new<mypair>(0)
    var float last_high = na
    var int last_high_tm = na
    var int last_high_taken_tm = na
    var float last_low = na
    var int last_low_tm = na
    var int last_low_taken_tm = na
    bool sw_high = is_swing_high(D_swing_high)
    bool sw_low = is_swing_low(D_swing_low)
    if sw_high
        last_high:=na
        last_high_tm:=na
        last_high_taken_tm:=na
        push_swing(swinghigh, high[D_swing_high+1], time[D_swing_high+1], true)
    if sw_low
        last_low:=na
        last_low_tm:=na
        last_low_taken_tm:=na
        push_swing(swinglow, low[D_swing_low+1], time[D_swing_low+1], false)
    [taken_high, taken_high_tm] = pop_swept(swinghigh, high, true)
    [taken_low, taken_low_tm] = pop_swept(swinglow, low, false)
    if not na(taken_high)
        last_high:=taken_high
        last_high_tm:=taken_high_tm
        last_high_taken_tm:=time
    if not na(taken_low)
        last_low:=taken_low
        last_low_tm:=taken_low_tm
        last_low_taken_tm:=time

    float hg = swinghigh.size()>0 ? swinghigh.last().q : na
    int high_tm = swinghigh.size()>0 ? swinghigh.last().tm : na
    float lw = swinglow.size()>0 ? swinglow.last().q : na
    int low_tm = swinglow.size()>0 ? swinglow.last().tm : na
    [hg, high_tm, lw, low_tm, last_high, last_high_tm, last_high_taken_tm, last_low, last_low_tm, last_low_taken_tm, close, time, syminfo.basecurrency]

get_remote_values()=>
    [hg, high_tm, lw, low_tm, last_high, last_high_tm, last_high_taken_tm, last_low, last_low_tm, last_low_taken_tm, cl, tm, base] = get_values()
    [hg, lw, last_high, last_low, cl, tm, base]

set_data(mydata data, float hg, float lw, float last_high, float last_low, float cl, int tm, string base)=>
    data.hg:=hg
    data.lw:=lw
    data.last_high:=last_high
    data.last_low:=last_low
    data.cl:=cl
    data.tm:=tm
    data.base:=base

distance_pct(float q, float cl)=>
    float ans = na
    if not na(q) and not na(cl) and cl>0
        ans:=100*math.abs(q-cl)/cl
    ans

format_pct(float value, bool signed_value)=>
    string ans = "—"
    if not na(value)
        float rounded = math.round(value*100)/100
        rounded:=rounded==0 ? 0.0 : rounded
        ans:=(signed_value and rounded>0 ? "+" : "")+str.tostring(rounded, "0.00")

    ans

signed_pct(float q, float cl)=>
    not na(q) and not na(cl) and cl>0 ? 100*(cl-q)/cl : na

format_price(float value)=>
    na(value) ? "—" : str.tostring(value, "0.############")

get_coin_key(string base, string symbol)=>
    string ans = ticker.standard(symbol)
    if not na(base) and base!=""
        ans:=str.upper(base)
        if ans=="XBT"
            ans:="BTC"
        if ans=="1000PEPE"
            ans:="PEPE"
        if ans=="1000FLOKI"
            ans:="FLOKI"
    ans

get_name(string base, string symbol)=>
    string ans = get_coin_key(base, symbol)
    if na(base) or base==""
        array< string > parts = str.split(symbol, ":")
        ans:=parts.get(parts.size()-1)
    ans

update_level(levelview view, float q, int tm, bool high_side, bool taken)=>
    if na(q) or na(tm)
        line.delete(view.ln)
        label.delete(view.lb)
        view.ln:=na
        view.lb:=na
    else
        color col = high_side ? high_color : low_color
        string txt = high_side ? "Swing High" : "Swing Low"
        if taken
            txt+=lang=="RU" ? " · снят" : " · taken"
        if na(view.ln)
            view.ln:=line.new(x1=tm, y1=q, x2=time, y2=q, xloc=xloc.bar_time, extend=extend.right, width=2)
        line.set_xy1(view.ln, tm, q)
        line.set_xy2(view.ln, time, q)
        line.set_color(view.ln, color.new(col, taken ? 35 : 0))
        line.set_style(view.ln, taken ? line.style_dashed : line.style_solid)
        if na(view.lb)
            view.lb:=label.new(x=tm, y=q, text=txt, xloc=xloc.bar_time, yloc=yloc.price, size=size.small)
        label.set_xy(view.lb, tm, q)
        label.set_text(view.lb, txt)
        label.set_style(view.lb, high_side ? label.style_label_down : label.style_label_up)
        label.set_color(view.lb, color.new(col, taken ? 85 : 10))
        label.set_textcolor(view.lb, taken ? col : color.white)
        label.set_tooltip(view.lb, txt+"\n"+format_price(q))
    view

color table_bg = color.rgb(248, 250, 253)
color header_bg = color.rgb(225, 234, 247)
color border_col = color.rgb(213, 223, 236)
color table_fg = color.rgb(40, 55, 77)
color muted_fg = color.rgb(100, 114, 134)
color current_bg = color.rgb(229, 240, 253)

is_fresh(mydata data)=>
    not na(data.tm) and data.tm==time and not na(data.cl) and data.cl>0

get_active(mydata data, bool high_side)=>
    high_side ? data.hg : data.lw

get_taken(mydata data, bool high_side)=>
    high_side ? data.last_high : data.last_low

comes_before(mydata a, mydata b, bool high_side, bool chart_taken)=>
    bool af = is_fresh(a)
    bool bf = is_fresh(b)
    bool at = not na(get_taken(a, high_side))
    bool bt = not na(get_taken(b, high_side))
    float ad = distance_pct(at and not chart_taken ? get_taken(a, high_side) : get_active(a, high_side), a.cl)
    float bd = distance_pct(bt and not chart_taken ? get_taken(b, high_side) : get_active(b, high_side), b.cl)
    bool ans = false
    if af!=bf
        ans:=af
    else if af
        if at!=bt
            ans:=chart_taken ? at : not at
        else if na(ad)!=na(bd)
            ans:=not na(ad)
        else if not na(ad) and not na(bd)
            ans:=ad<bd
    ans

sort_side(array< int > ids, array< int > source, array< mydata > data, bool high_side, bool chart_taken)=>
    ids.clear()
    if source.size()>0
        for int i=0 to source.size()-1
            int id = source.get(i)
            int pos = ids.size()
            while pos>0
                if comes_before(data.get(id), data.get(ids.get(pos-1)), high_side, chart_taken)
                    pos-=1
                else
                    break
            ids.insert(pos, id)
    ids

set_side_row(table tbl, int col, int row, string symbol, mydata data, bool high_side, bool current)=>
    bool fresh = is_fresh(data)
    float q = get_active(data, high_side)
    float taken_q = get_taken(data, high_side)
    bool taken = fresh and not na(taken_q)
    color side_col = high_side ? high_color : low_color
    color bg = current ? current_bg : (row%2==0 ? color.white : table_bg)
    string name = (current ? "● " : "")+get_name(data.base, symbol)
    string state = not fresh ? "!" : taken ? "✓" : na(q) ? "—" : "○"
    float primary = fresh ? (taken ? signed_pct(taken_q, data.cl) : distance_pct(q, data.cl)) : na
    string next_value = taken and not na(q) ? format_pct(distance_pct(q, data.cl), false) : ""
    string tip = symbol+"\n"+(lang=="RU" ? "Цена: " : "Price: ")+format_price(data.cl)
    string primary_tip = lang=="RU" ? "Нет доступного уровня или актуальных данных." : "No level or current data."
    if fresh and (taken or not na(q))
        primary_tip:=taken ? (lang=="RU" ? "Положение цены относительно снятого: + выше, − ниже.\n" : "Price relative to the taken level: + above, − below.\n") : (lang=="RU" ? "Расстояние до ближайшего неснятого свинга.\n" : "Distance to the nearest untaken swing.\n")
        primary_tip+=format_price(taken ? taken_q : q)+"\n"+(taken ? "(close − level) / close × 100" : "|level − close| / close × 100")
    string next_tip = lang=="RU" ? "Расстояние до следующего неснятого свинга в стеке." : "Distance to the next untaken swing in the stack."
    table.cell(tbl, col, row, name, text_color=table_fg, bgcolor=bg, text_size=table_font, text_halign=text.align_left, tooltip=tip)
    table.cell(tbl, col+1, row, state, text_color=fresh ? side_col : muted_fg, bgcolor=bg, text_size=table_font, tooltip=primary_tip)
    table.cell(tbl, col+2, row, format_pct(primary, taken), text_color=fresh ? table_fg : muted_fg, bgcolor=bg, text_size=current ? current_font : table_font, text_halign=text.align_right, text_font_family=font.family_monospace, tooltip=primary_tip)
    table.cell(tbl, col+3, row, next_value, text_color=muted_fg, bgcolor=bg, text_size=secondary_font, text_halign=text.align_right, text_font_family=font.family_monospace, tooltip=next_tip)

if barstate.isfirst
    if not chart.is_standard or timeframe.isticks
        runtime.error("Используйте обычный временной график. / Use a standard time-based chart.")

[hg, high_tm, lw, low_tm, last_high, last_high_tm, last_high_taken_tm, last_low, last_low_tm, last_low_taken_tm, cl, tm, base] = get_values()
bool high_event = is_sweep_bar(last_high_taken_tm, time)
bool low_event = is_sweep_bar(last_low_taken_tm, time)
alertcondition(high_event, "Swing High taken", "{{ticker}} · {{interval}}: Swing High taken / Снят Swing High")
alertcondition(low_event, "Swing Low taken", "{{ticker}} · {{interval}}: Swing Low taken / Снят Swing Low")
alertcondition(high_event or low_event, "Any swing taken", "{{ticker}} · {{interval}}: Swing taken / Снят свинг")

var mydata chart_data = mydata.new()
var levelview high_view = levelview.new()
var levelview low_view = levelview.new()
var levelview taken_high_view = levelview.new()
var levelview taken_low_view = levelview.new()
if barstate.islast
    set_data(chart_data, hg, lw, last_high, last_low, cl, tm, base)
    update_level(high_view, hg, high_tm, true, false)
    update_level(low_view, lw, low_tm, false, false)
    update_level(taken_high_view, last_high, last_high_tm, true, true)
    update_level(taken_low_view, last_low, last_low_tm, false, true)

var array< mydata > row_data = array.new<mydata>(0)
var array< int > selected = array.new<int>(0)
var array< string > seen = array.new<string>(0)
if barstate.isfirst
    for int i=0 to symbols.size()-1
        row_data.push(mydata.new())
if barstate.islast
    selected.clear()
    seen.clear()
    seen.push(get_coin_key(syminfo.basecurrency, syminfo.tickerid))

for int i=0 to symbols.size()-1
    if show_coin.get(i)
        string symbol = symbols.get(i)
        [rhg, rlw, rlast_high, rlast_low, rcl, rtm, rbase] = request.security(symbol, timeframe.period, get_remote_values(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
        if barstate.islast
            mydata data = row_data.get(i)
            set_data(data, rhg, rlw, rlast_high, rlast_low, rcl, rtm, rbase)
            string key = get_coin_key(rbase, symbol)
            bool duplicate = seen.includes(key) or ticker.standard(symbol)==ticker.standard(syminfo.tickerid)
            if not duplicate
                seen.push(key)
                selected.push(i)

var array< int > high_order = array.new<int>(0)
var array< int > low_order = array.new<int>(0)
var table tbl = na
var int table_rows = 0
if barstate.islast
    sort_side(high_order, selected, row_data, true, not na(last_high))
    sort_side(low_order, selected, row_data, false, not na(last_low))
    int section_rows = selected.size()+3
    int rows = 2*section_rows+3
    if na(tbl) or table_rows!=rows
        table.delete(tbl)
        tbl:=table.new(position.middle_right, 4, rows, bgcolor=table_bg, frame_color=border_col, frame_width=1, border_color=border_col, border_width=0)
        table_rows:=rows
        table.merge_cells(tbl, 0, 0, 3, 0)
        table.merge_cells(tbl, 0, section_rows, 3, section_rows)
        table.merge_cells(tbl, 0, section_rows+1, 3, section_rows+1)
        table.merge_cells(tbl, 0, rows-2, 3, rows-2)
        table.merge_cells(tbl, 0, rows-1, 3, rows-1)
    table.cell(tbl, 0, section_rows, "", height=0.7, bgcolor=border_col)
    for int side=0 to 1
        int col = 0
        int offset = side*(section_rows+1)
        bool high_side = side==0
        color side_col = high_side ? high_color : low_color
        color side_bg = high_side ? color.rgb(251, 236, 239) : color.rgb(231, 245, 239)
        string title = (high_side ? "SWING HIGH" : "SWING LOW")+" · %"
        table.cell(tbl, col, offset, title, text_color=side_col, bgcolor=side_bg, text_size=table_font)
        table.cell(tbl, col, offset+1, lang=="RU" ? "Монета" : "Coin", text_color=muted_fg, bgcolor=header_bg, text_size=secondary_font, text_halign=text.align_left)
        table.cell(tbl, col+1, offset+1, "", bgcolor=header_bg)
        table.cell(tbl, col+2, offset+1, "Δ", text_color=table_fg, bgcolor=header_bg, text_size=secondary_font, text_halign=text.align_right)
        table.cell(tbl, col+3, offset+1, lang=="RU" ? "След. свинг" : "Next Swing", text_color=muted_fg, bgcolor=header_bg, text_size=secondary_font, text_halign=text.align_right)
        set_side_row(tbl, col, offset+2, syminfo.tickerid, chart_data, high_side, true)
        array< int > order = high_side ? high_order : low_order
        if order.size()>0
            for int j=0 to order.size()-1
                int id = order.get(j)
                set_side_row(tbl, col, offset+j+3, symbols.get(id), row_data.get(id), high_side, false)
    table.cell(tbl, 0, rows-2, "", height=0.4, bgcolor=border_col)
    string note = lang=="RU" ? "○ До следующего свинга\n✓ От уровня снятия" : "○ To next swing\n✓ From swept level"
    table.cell(tbl, 0, rows-1, note, text_color=table_fg, bgcolor=header_bg, text_size=secondary_font, text_halign=text.align_left)
    float total_weight = 2*(selected.size()+2.90)+2.00
    for int row=0 to rows-1
        bool separator = row==section_rows or row==rows-2
        bool footer = row==rows-1
        bool title_row = row==0 or row==section_rows+1
        bool header_row = row==1 or row==section_rows+2
        bool current_row = row==2 or row==section_rows+3
        float weight = separator ? 0.15 : footer ? 1.70 : title_row ? 1.00 : header_row ? 0.75 : current_row ? 1.15 : 1.00
        float row_height = 86.0*weight/total_weight
        int last_col = separator or footer or title_row ? 0 : 3
        for int col=0 to last_col
            table.cell_set_height(tbl, col, row, row_height)
````
