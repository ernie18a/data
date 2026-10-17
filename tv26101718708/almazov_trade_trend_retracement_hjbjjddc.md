# Almazov Trade: Trend Retracement

- url: https://www.tradingview.com/script/HjBjjddC-almazov-trade-trend-retracement/
- type: indicator
- pine_id: PUB;bf692c5c189446f3845c6ffcfea7688c
- version: 1.0

## Description

[b]Almazov Trade: Trend Retracement[/b]

Almazov Trade: Trend Retracement is an open-source indicator for identifying potential trend-continuation setups after a 50% retracement of a confirmed structural impulse.

It combines a swing-based trend model, an impulse midpoint, and a local Market Structure Break (MSB) into a sequential signal process. Hypothetical stop-loss and take-profit prices are based on price structure, and a minimum reward-to-risk filter determines whether a confirmed break qualifies as an entry. The indicator tracks one hypothetical position at a time; it does not place orders.

[b]Market structure and impulse[/b]

The indicator evaluates confirmed swing highs and swing lows on the current chart timeframe. A swing high or low requires the configured number of bars on both sides. A pivot is available only after the necessary right-side bars have closed; its original candle is not treated as a signal available in advance.

The structural engine maintains a bullish, bearish, or unestablished trend state, updating its reference swings and detecting invalidation when price breaches the relevant structural extreme. In an established bullish state, the reference impulse runs from the selected structural low to the subsequent high; in a bearish state, from the selected high to the subsequent low. An invalid or unestablished structure does not provide a new entry setup.

The impulse midpoint is:

[pine]
float fib50 = (impulse_high + impulse_low) / 2
[/pine]

The midpoint is recalculated when a different qualifying structural impulse is selected. The indicator does not request a higher-timeframe series or use request.security().

[b]Retracement and MSB confirmation[/b]

[list=1]
[*]Identify the direction of the confirmed structure and its latest qualifying impulse.
[*]Wait for a later candle to reach the impulse midpoint: for a bullish setup, low <= 50%; for a bearish setup, high >= 50%. An intrabar wick touch is sufficient, but the event is processed at candle close.
[*]After that touch, look for a confirmed local pivot formed after the impulse extreme: a swing high below the impulse high for LONG, or a swing low above the impulse low for SHORT. This pivot may have formed before the 50% touch; it becomes an MSB candidate only when confirmed and evaluated during the waiting state.
[*]For LONG, a later candle must close above the active MSB swing high while the previous close was at or below that level. For SHORT, a later candle must close below the active MSB swing low while the previous close was at or above it. Wick-only breaks do not qualify.
[*]Calculate the structural stop, impulse-based target, and prospective reward-to-risk ratio. Show an entry only if the risk and reward are positive and the ratio meets the selected minimum.
[/list]

An MSB cannot produce an entry on the first 50%-touch candle. If a newer qualifying local pivot is confirmed before entry, the pending MSB threshold is updated. The script displays the active threshold rather than every detected swing.

[b]Structural stop, target, and RR[/b]

For a hypothetical LONG, the stop is placed below the lowest low recorded from the 50%-touch candle through the MSB-entry candle; the target is placed just below the original impulse high. For a hypothetical SHORT, the stop is above the highest high over that same waiting period; the target is just above the original impulse low.

[list]
[*]LONG SL = lowest low since midpoint touch - SL buffer in minimum price ticks.
[*]LONG TP = reference impulse high - TP buffer in minimum price ticks.
[*]SHORT SL = highest high since midpoint touch + SL buffer in minimum price ticks.
[*]SHORT TP = reference impulse low + TP buffer in minimum price ticks.
[*]RR = absolute target-to-entry distance / absolute entry-to-stop distance.
[/list]

The hypothetical entry is the MSB candle's closing price. Both buffers default to one minimum price tick. The minimum RR defaults to 1.0; it is a filter, not a fixed profit target or a claim of optimality. If the break fails the risk/reward validation, an orange RR rejection marker is displayed and that impulse is considered used. The script does not keep retrying the same impulse indefinitely.

[b]Setup invalidation and position handling[/b]

Before entry, a pending setup is canceled if the detected trend no longer agrees with its direction or if price moves beyond the opposite boundary of the reference impulse (below its low for LONG, above its high for SHORT). An updated qualifying structural impulse can establish a new setup.

Only one hypothetical position is active at a time. On a qualified MSB, its entry, SL, and TP are fixed. While it remains active, additional entries are ignored. A new trade search requires a different qualifying impulse; no partial exits, trailing stops, or automatic breakeven moves are implemented.

[b]Exit confirmation and label positioning[/b]

Stop and target checks begin on the candle after the hypothetical entry. Touching either level, including equality, is sufficient, but the outcome is recorded at candle close. When the same candle reaches both SL and TP, SL takes priority because the script cannot determine the intrabar sequence from OHLC values alone.

[list]
[*]LONG SL and SHORT TP labels appear at the event candle's low, pointing upward.
[*]LONG TP and SHORT SL labels appear at the event candle's high, pointing downward.
[/list]

Exit labels mark the candle on which the event was confirmed, not the assumed execution price. There is no modeling of partial fills, gaps, spread, commissions, slippage, funding, or position sizing.

[b]Chart display and alerts[/b]

[list]
[*]Grey line: 50% of the selected structural impulse while a setup is being prepared.
[*]Small orange dot: the first confirmed 50%-touch event.
[*]Green MSB level and "MSB ↑" tag: the pending bullish close-above threshold.
[*]Red MSB level and "MSB ↓" tag: the pending bearish close-below threshold.
[*]Orange RR cross: an MSB that failed the pre-entry risk/reward checks.
[*]LONG / SHORT labels: accepted hypothetical entries.
[*]During an active position, blue / red / green lines: entry / SL / TP, respectively.
[*]Top-right status table: detected trend and the current preparation, MSB-waiting, used-impulse, or active-position state.
[/list]

The same red and green colors are used for pending MSB thresholds before entry and for SL/TP levels during an active position. Input and plot values are hidden from the chart's status line, while their on-chart display remains available. Display switches change visibility, not signal calculations.

Five alert conditions are provided: Long, Short, Take Profit, Stop Loss, and "50% достигнуты" (50% reached). Events are evaluated on confirmed candles. For alert delivery aligned with the displayed signals, select "Once Per Bar Close" in TradingView.

[b]Timeframes and historical limitations[/b]

The indicator uses only bars of the current chart timeframe. Its output depends on available OHLC history, the symbol's price increments, the selected swing widths, and the chart timeframe. Standard time-based candles are recommended; synthetic charts such as Heikin Ashi and Renko can make price-based entries and exits misleading.

Confirmed pivots require later candles to establish them, so their associated thresholds cannot be known on the pivot candle itself. Signals are generated only on confirmed bars; they are not retroactively shifted to earlier candles. A new dataset, timeframe, settings, or available history may change which structural impulse and subsequent signals are reconstructed.

The implementation stores confirmed candles in an expanding Pine array. Extremely long loaded histories may reach Pine's collection-size or execution limits. The tool is not a broker execution engine and is not a TradingView strategy backtest.

[b]Implementation and purpose[/b]

Swing structure, midpoint retracements, and MSB confirmations are established concepts. This implementation links a directional swing-state engine to a staged 50%-touch and confirmed local-break process, structural risk placement, an impulse-extreme target, a pre-entry RR gate, and non-overlapping hypothetical position tracking. The combination is intended to make the conditions leading up to a possible entry visible and inspectable without drawing every swing.

[quote]This is an open-source analytical indicator, not an automated trading strategy or evidence of a profitable trading system. Its entry and exit events are hypothetical. Transaction costs, execution uncertainty, and market liquidity are not modeled; historical examples do not establish future performance.[/quote]

[b]Interface translations and settings[/b]

The interface contains Russian labels. English equivalents and default settings are provided below.

[i]Calculation inputs[/i]
[list]
[*]"Swing high: баров слева и справа" — Swing high: bars on each side. Default 2; range 1–60.
[*]"Swing low: баров слева и справа" — Swing low: bars on each side. Default 2; range 1–60.
[*]"Минимальный RR" — Minimum RR. Default 1.0; minimum 0.1; step 0.1.
[*]"Отступ SL (тики)" — Stop-loss buffer (ticks). Default 1; minimum 0.
[*]"Отступ TP (тики)" — Take-profit buffer (ticks). Default 1; minimum 0.
[*]"Long" / "Short" — Entry-label colors; green / red by default.
[/list]

[i]Display inputs[/i]
[list]
[*]"Показывать уровень 50%" — Show 50% midpoint; enabled by default.
[*]"Показывать SL и TP" — Show trade levels (entry, SL, and TP); enabled by default.
[*]"Показывать ориентиры входа" — Show entry guidance; enabled by default.
[*]"Показывать этап ожидания" — Show waiting-stage status table; enabled by default.
[/list]

[i]Chart text and plots[/i]
[list]
[*]"Уровень подтверждения MSB" — MSB confirmation level.
[*]"Касание 50%" — 50% touch.
[*]"MSB: недостаточный RR" — MSB: insufficient RR / invalid proposed trade levels.
[*]"Fibonacci 50%" / "Entry" / "Stop Loss" / "Take Profit" — Midpoint / hypothetical entry / stop / target.
[*]"Тренд: не определён" / "Тренд: ↑" / "Тренд: ↓" — Trend: unestablished / bullish / bearish.
[*]"Ждём 50%" — Waiting for 50%.
[*]"50% достигнуты · ждём свинг" — 50% reached; waiting for a confirmed swing.
[*]"Ждём пробой MSB" — Waiting for MSB break.
[*]"Сделка открыта" / "Импульс использован" / "Ждём импульс" — Position active / impulse used / waiting for impulse.
[/list]

[i]Alerts[/i]
[list]
[*]"Long" / "Short" — Accepted LONG / SHORT entries.
[*]"Take Profit" / "Stop Loss" — Confirmed hypothetical TP / SL touches.
[*]"50% достигнуты" — 50% reached; waiting for MSB.
[/list]

[b]РУССКАЯ ВЕРСИЯ[/b]

[b]Almazov Trade: Trend Retracement[/b]

Almazov Trade: Trend Retracement — индикатор с открытым исходным кодом для поиска возможного продолжения тренда после отката на 50% последнего подтверждённого структурного импульса.

Он объединяет определение тренда по свингам, середину импульса и локальный пробой рыночной структуры (MSB). Условные стоп и тейк рассчитываются по ценовым экстремумам, а фильтр RR позволяет исключать входы с недостаточным соотношением потенциальной прибыли к риску. Индикатор сопровождает не более одной условной сделки одновременно и не выставляет ордера.

[b]Структура рынка и импульс[/b]

Направление определяется по подтверждённым Swing High и Swing Low на текущем таймфрейме графика. Для подтверждения свинга требуется заданное число свечей слева и справа. Такой экстремум становится известен только после закрытия необходимого числа свечей справа, а не в момент образования самого экстремума.

Алгоритм сопровождает восходящую, нисходящую либо ещё не определённую структуру. Он обновляет опорные свинги и отслеживает нарушение структурных экстремумов. При восходящей структуре импульс задаётся опорным минимумом и последующим максимумом, при нисходящей — максимумом и последующим минимумом. Если структура не определена, новый сетап не формируется.

Середина импульса рассчитывается как (максимум импульса + минимум импульса) / 2. При выборе нового подтверждённого импульса уровень пересчитывается. Данные старших таймфреймов через request.security() не используются.

[b]Откат 50% и подтверждение MSB[/b]

[list=1]
[*]Определяется направление структуры и последний подходящий импульс.
[*]Ожидается касание 50% более поздней свечой: для лонга достаточно low <= середины импульса, для шорта — high >= середины. Достаточно тени, событие учитывается на закрытии свечи.
[*]После касания выбирается подтверждённый локальный свинг, возникший позже конечного экстремума импульса: Swing High ниже максимума импульса для лонга или Swing Low выше минимума импульса для шорта. Сам свинг мог сформироваться до касания 50%, но учитывается как кандидат MSB только после подтверждения.
[*]Для лонга свеча должна закрыться выше уровня MSB, причём предыдущее закрытие находилось на нём или ниже. Для шорта необходимо закрытие ниже MSB при предыдущем закрытии на уровне или выше. Прокола тенью недостаточно.
[*]Рассчитываются стоп, тейк и RR. Вход допускается только при положительных риске и потенциальной прибыли и выполнении минимального RR.
[/list]

Вход на первой свече касания 50% запрещён. Если до входа сформировался новый подходящий локальный свинг, ожидаемый уровень MSB обновляется. Индикатор показывает актуальный уровень подтверждения, а не все найденные свинги.

[b]Структурный стоп, тейк и RR[/b]

Для лонга стоп ставится ниже минимального Low, зафиксированного с момента касания 50% до свечи входа включительно. Тейк располагается немного ниже максимума исходного импульса. Для шорта стоп ставится выше максимального High на том же участке, а тейк — немного выше минимума импульса.

[list]
[*]SL лонга = минимум после касания 50% − отступ SL в тиках.
[*]TP лонга = максимум исходного импульса − отступ TP в тиках.
[*]SL шорта = максимум после касания 50% + отступ SL в тиках.
[*]TP шорта = минимум исходного импульса + отступ TP в тиках.
[*]RR = расстояние от входа до тейка / расстояние от входа до стопа, по абсолютной величине.
[/list]

Условная цена входа — закрытие свечи MSB. Оба отступа по умолчанию равны одному минимальному тику инструмента. Минимальный RR по умолчанию — 1,0. Это фильтр, а не фиксированный тейк или оптимизированный параметр. При невалидном расположении уровней либо недостаточном RR появляется оранжевая отметка RR, а импульс считается использованным без повторных попыток входа по нему.

[b]Отмена сетапа и сопровождение[/b]

До входа поиск отменяется при смене направления структуры либо при пробое противоположного экстремума исходного импульса: ниже минимума для лонга или выше максимума для шорта. Новый подходящий импульс может сформировать новый сетап.

Одновременно сопровождается одна условная позиция. После подтверждения входа цена входа, стоп и тейк фиксируются; дополнительные входы игнорируются. Для следующего сетапа необходим другой подтверждённый импульс. Частичных выходов, трейлинг-стопа и автоматического переноса в безубыток нет.

[b]Подтверждение выхода и положение меток[/b]

Касание стопа и тейка проверяется со свечи, следующей за входом, а результат фиксируется при закрытии свечи события. Точное касание также учитывается. Если одна свеча затронула оба уровня, приоритет отдаётся SL, поскольку порядок движения цены внутри свечи по OHLC не восстанавливается.

[list]
[*]SL лонга и TP шорта располагаются на Low свечи, метка направлена вверх.
[*]TP лонга и SL шорта располагаются на High свечи, метка направлена вниз.
[/list]

Положение подписи обозначает свечу события, а не цену исполнения. Комиссии, спред, проскальзывание, финансирование, размер позиции и исполнение при гэпах не моделируются.

[b]Отображение и уведомления[/b]

[list]
[*]Серая линия — уровень 50% текущего опорного импульса.
[*]Маленькая оранжевая точка — первое зафиксированное касание 50%.
[*]Зелёная линия и «MSB ↑» — уровень ожидаемого бычьего MSB.
[*]Красная линия и «MSB ↓» — уровень ожидаемого медвежьего MSB.
[*]Оранжевый крестик RR — подтверждённый MSB, не прошедший фильтр допустимой сделки.
[*]LONG / SHORT — метки принятых условных входов.
[*]После входа синий / красный / зелёный уровни обозначают Entry / SL / TP.
[*]Таблица справа сверху показывает тренд и текущую стадию поиска или сопровождения сделки.
[/list]

Зелёный и красный цвета до входа используются для уровней MSB, а во время сделки — для TP и SL. Значения входных параметров и графических серий скрыты из строки статуса TradingView, но линии на графике остаются доступными. Переключатели отображения не отключают расчёты.

Доступны пять типов уведомлений: Long, Short, Take Profit, Stop Loss и «50% достигнуты». События проверяются на закрытии свечи. Чтобы уведомления соответствовали подтверждённым событиям, при создании алерта выбирайте «Один раз при закрытии бара».

[b]Таймфреймы и ограничения исторического анализа[/b]

Расчёт ведётся исключительно по свечам текущего таймфрейма. Результат зависит от загруженной истории OHLC, минимального тика инструмента, ширины свингов и выбранного периода графика. Рекомендуются стандартные свечи, формируемые по времени. Синтетические графики Heikin Ashi, Renko и подобные могут создавать неверное представление о возможном исполнении сделок.

Подтверждение свинга запаздывает на необходимое количество свечей справа. Порог MSB недоступен в момент формирования исходной вершины или впадины. Сигналы отмечаются только после закрытия подтверждающей свечи и не переносятся на более ранние свечи. При смене истории, сессии, таймфрейма или параметров последовательность восстановленных сигналов может измениться.

В реализации сохраняются подтверждённые свечи в растущем массиве Pine. На очень длинной загруженной истории возможны ограничения размера массива и времени выполнения. Индикатор не моделирует брокерское исполнение и не является отчётом Strategy Tester.

[b]Особенности реализации и назначение[/b]

Структурные свинги, откат 50% и MSB — известные элементы технического анализа. В данной реализации они объединены в последовательный алгоритм: определение направления по структуре, касание середины импульса, подтверждение локального свинга, пробой закрытием, структурный стоп, тейк у экстремума импульса и проверка RR. Дополнительное сопровождение одной условной позиции и отображение только актуальных ориентиров помогают изучать формирование сигнала без отображения каждого свинга на графике.

[quote]Это аналитический индикатор с открытым кодом, а не автоматическая торговая стратегия или доказательство прибыльности. Входы и выходы условные. Торговые издержки, неопределённость исполнения и ликвидность не учитываются; история сигналов не гарантирует аналогичных результатов в будущем.[/quote]

[b]Настройки[/b]

[i]Расчёт[/i]
[list]
[*]«Swing high: баров слева и справа» — по умолчанию 2; диапазон 1–60.
[*]«Swing low: баров слева и справа» — по умолчанию 2; диапазон 1–60.
[*]«Минимальный RR» — по умолчанию 1,0; минимум 0,1; шаг 0,1.
[*]«Отступ SL (тики)» — по умолчанию 1; минимум 0.
[*]«Отступ TP (тики)» — по умолчанию 1; минимум 0.
[*]Цвета Long / Short — зелёный / красный по умолчанию.
[/list]

[i]Отображение[/i]
[list]
[*]«Показывать уровень 50%» — включено по умолчанию.
[*]«Показывать SL и TP» — показывает также линию Entry; включено по умолчанию.
[*]«Показывать ориентиры входа» — включено по умолчанию.
[*]«Показывать этап ожидания» — включено по умолчанию.
[/list]

В стиле доступны серии «Fibonacci 50%», «Уровень подтверждения MSB», «Касание 50%», «MSB: недостаточный RR», «Entry», «Stop Loss», «Take Profit». В таблице используются статусы «Тренд: не определён», «Тренд: ↑», «Тренд: ↓», «Ждём 50%», «50% достигнуты · ждём свинг», «Ждём пробой MSB», «Сделка открыта», «Импульс использован» и «Ждём импульс». Их английские эквиваленты приведены выше.

## Source Code

````pine
//@version=6
indicator("Almazov Trade: Trend Retracement", overlay = true, max_labels_count = 500)

int D_swing_high = input.int(2, "Swing high: баров слева и справа", minval = 1, maxval = 60, display = display.none)
int D_swing_low = input.int(2, "Swing low: баров слева и справа", minval = 1, maxval = 60, display = display.none)
float min_rr = input.float(1, "Минимальный RR", minval = 0.1, step = 0.1, display = display.none)
int sl_offset = input.int(1, "Отступ SL (тики)", minval = 0, display = display.none)
int tp_offset = input.int(1, "Отступ TP (тики)", minval = 0, display = display.none)
bool show_fib = input.bool(true, "Показывать уровень 50%", display = display.none)
bool show_levels = input.bool(true, "Показывать SL и TP", display = display.none)
bool show_guide = input.bool(true, "Показывать ориентиры входа", display = display.none)
bool show_status = input.bool(true, "Показывать этап ожидания", display = display.none)
color up_trend = input.color(color.green, "Long", display = display.none)
color down_trend = input.color(color.red, "Short", display = display.none)

type mypair
    float q
    int bar_id
    int sup_id

type mybar
    float hg
    float lw
    int high_id
    int low_id

var array<mybar> bars = array.new<mybar>(0)
var int sz_bars = 0
int dh = D_swing_high + 1
int dl = D_swing_low + 1

is_swing_high(int pos) =>
    bool ans = true
    if pos - D_swing_high < 0 or pos + D_swing_high >= sz_bars
        ans := false
    else
        float H = bars.get(pos).hg
        for int i = pos - D_swing_high to pos + D_swing_high
            if bars.get(i).hg > H and i != pos
                ans := false
    ans

is_swing_low(int pos) =>
    bool ans = true
    if pos - D_swing_low < 0 or pos + D_swing_low >= sz_bars
        ans := false
    else
        float L = bars.get(pos).lw
        for int i = pos - D_swing_low to pos + D_swing_low
            if bars.get(i).lw < L and i != pos
                ans := false
    ans

get_min(int l, int r) =>
    float ans = 1e20
    if l <= r
        for int i = l to r
            ans := math.min(ans, bars.get(i).lw)
    ans

get_max(int l, int r) =>
    float ans = -1e20
    if l <= r
        for int i = l to r
            ans := math.max(ans, bars.get(i).hg)
    ans

fnd_sw_low(int l, int r, int from_bar, int to_bar) =>
    mypair res = mypair.new(-1, -1, -1)
    if l <= r
        for int i = l to r
            if bars.get(i).low_id > from_bar and bars.get(i).low_id < to_bar and (res.q == -1 or res.q > bars.get(i).lw) and is_swing_low(i)
                res := mypair.new(bars.get(i).lw, bars.get(i).low_id, i)
    res

fnd_sw_high(int l, int r, int from_bar, int to_bar) =>
    mypair res = mypair.new(-1, -1, -1)
    if l <= r
        for int i = l to r
            if bars.get(i).high_id > from_bar and bars.get(i).high_id < to_bar and (res.q == -1 or res.q < bars.get(i).hg) and is_swing_high(i)
                res := mypair.new(bars.get(i).hg, bars.get(i).high_id, i)
    res

var mypair now_low = mypair.new(-1, -1, -1)
var mypair now_high = mypair.new(-1, -1, -1)
var int first_build = -2
var int started = -1
var int type_of_trend = 0

var int setup_state = 0
var int setup_direction = 0
var int setup_impulse_id = -1
var float impulse_high = na
var float impulse_low = na
var float fib50 = na
var float pullback_extreme = na
var float msb_level = na
var int touch_bar = -1
var int msb_pivot_id = -1
var label msb_tag = na
var table status_table = table.new(position.top_right, 1, 2, border_width = 1)

var int position = 0
var float active_entry = na
var float active_sl = na
var float active_tp = na
var int entry_bar = -1

bool long_signal = false
bool short_signal = false
bool tp_signal = false
bool sl_signal = false
bool touch_signal = false
bool rr_rejected = false

if barstate.isconfirmed
    bars.push(mybar.new(high, low, bar_index, bar_index))
    sz_bars += 1

    bool sw_low = is_swing_low(sz_bars - dl)
    bool sw_high = is_swing_high(sz_bars - dh)

    if first_build != 0
        if sw_low and now_low.q == -1
            now_low := mypair.new(bars.get(sz_bars - dl).lw, bars.get(sz_bars - dl).low_id, sz_bars - dl)
            first_build += 1
        if sw_high and now_high.q == -1
            now_high := mypair.new(bars.get(sz_bars - dh).hg, bars.get(sz_bars - dh).high_id, sz_bars - dh)
            first_build += 1

    if started == -1
        if now_low.q != -1 and now_low.q > get_min(now_low.sup_id, sz_bars - 1)
            now_low := fnd_sw_low(now_low.sup_id + 1, sz_bars - dl, -1, bar_index + 1)
            if now_low.q != -1 and now_low.q > get_min(now_low.sup_id, sz_bars - 1)
                now_low := mypair.new(-1, -1, -1)
        if now_high.q != -1 and now_high.q < get_max(now_high.sup_id, sz_bars - 1)
            now_high := fnd_sw_high(now_high.sup_id + 1, sz_bars - dh, -1, bar_index + 1)
            if now_high.q != -1 and now_high.q < get_max(now_high.sup_id, sz_bars - 1)
                now_high := mypair.new(-1, -1, -1)
        first_build := (now_low.q == -1 ? -1 : 0) + (now_high.q == -1 ? -1 : 0)

    if started == 1
        if type_of_trend == 1
            if sw_high and bars.get(sz_bars - dh).hg > now_high.q
                mypair new_low = fnd_sw_low(now_high.sup_id, math.min(sz_bars - dl, sz_bars - dh), now_high.bar_id, bars.get(sz_bars - dh).high_id)
                mypair new_high = mypair.new(bars.get(sz_bars - dh).hg, bars.get(sz_bars - dh).high_id, sz_bars - dh)
                if new_low.q != -1 and new_low.q <= get_min(new_low.sup_id, sz_bars - 1) and new_low.bar_id > now_high.bar_id and new_low.q < now_high.q
                    now_high := new_high
                    now_low := new_low
                else
                    now_high := new_high
            if low < now_low.q
                now_low := mypair.new(-1, -1, -1)
                first_build := -1
                started := -1
                type_of_trend := 0
        else
            if sw_low and bars.get(sz_bars - dl).lw < now_low.q
                mypair new_high = fnd_sw_high(now_low.sup_id, math.min(sz_bars - dh, sz_bars - dl), now_low.bar_id, bars.get(sz_bars - dl).low_id)
                mypair new_low = mypair.new(bars.get(sz_bars - dl).lw, bars.get(sz_bars - dl).low_id, sz_bars - dl)
                if new_high.q != -1 and new_high.q >= get_max(new_high.sup_id, sz_bars - 1) and new_high.bar_id > now_low.bar_id and new_high.q > now_low.q
                    now_low := new_low
                    now_high := new_high
                else
                    now_low := new_low
            if high > now_high.q
                now_high := mypair.new(-1, -1, -1)
                first_build := -1
                started := -1
                type_of_trend := 1

    if started == -1 and first_build == 0
        started := 1
        type_of_trend := now_low.bar_id < now_high.bar_id ? 1 : 0

    int trend = started == 1 ? (type_of_trend == 1 ? 1 : -1) : 0
    bool valid_long_impulse = trend == 1 and now_low.q != -1 and now_high.q != -1 and now_low.bar_id < now_high.bar_id
    bool valid_short_impulse = trend == -1 and now_low.q != -1 and now_high.q != -1 and now_high.bar_id < now_low.bar_id
    int new_impulse_id = valid_long_impulse ? now_high.bar_id : valid_short_impulse ? now_low.bar_id : -1

    if position == 0 and new_impulse_id != -1 and (new_impulse_id != setup_impulse_id or trend != setup_direction)
        setup_impulse_id := new_impulse_id
        setup_direction := trend
        impulse_high := now_high.q
        impulse_low := now_low.q
        fib50 := (impulse_high + impulse_low) / 2
        pullback_extreme := na
        msb_level := na
        touch_bar := -1
        msb_pivot_id := -1
        if not na(msb_tag)
            label.delete(msb_tag)
            msb_tag := na
        setup_state := 1

    if setup_state == 1 or setup_state == 2
        if trend != setup_direction or (setup_direction == 1 and low < impulse_low) or (setup_direction == -1 and high > impulse_high)
            setup_state := 0
            if not na(msb_tag)
                label.delete(msb_tag)
                msb_tag := na
        else
            if setup_state == 1 and bar_index > setup_impulse_id and (setup_direction == 1 ? low <= fib50 : high >= fib50)
                setup_state := 2
                touch_bar := bar_index
                pullback_extreme := setup_direction == 1 ? low : high
                touch_signal := true

            if setup_state == 2
                pullback_extreme := setup_direction == 1 ? math.min(pullback_extreme, low) : math.max(pullback_extreme, high)
                if setup_direction == 1 and sw_high
                    int candidate_id = bars.get(sz_bars - dh).high_id
                    float candidate = bars.get(sz_bars - dh).hg
                    if candidate_id > setup_impulse_id and candidate < impulse_high and candidate_id != msb_pivot_id
                        msb_level := candidate
                        msb_pivot_id := candidate_id
                        if not na(msb_tag)
                            label.delete(msb_tag)
                        if show_guide
                            msb_tag := label.new(bar_index, msb_level, "MSB ↑", color = color.new(color.green, 82), textcolor = color.green, style = label.style_label_left, size = size.tiny)
                if setup_direction == -1 and sw_low
                    int candidate_id = bars.get(sz_bars - dl).low_id
                    float candidate = bars.get(sz_bars - dl).lw
                    if candidate_id > setup_impulse_id and candidate > impulse_low and candidate_id != msb_pivot_id
                        msb_level := candidate
                        msb_pivot_id := candidate_id
                        if not na(msb_tag)
                            label.delete(msb_tag)
                        if show_guide
                            msb_tag := label.new(bar_index, msb_level, "MSB ↓", color = color.new(color.red, 82), textcolor = color.red, style = label.style_label_left, size = size.tiny)

                bool msb_long = setup_direction == 1 and bar_index > touch_bar and not na(msb_level) and close > msb_level and close[1] <= msb_level
                bool msb_short = setup_direction == -1 and bar_index > touch_bar and not na(msb_level) and close < msb_level and close[1] >= msb_level

                if position == 0 and (msb_long or msb_short)
                    float candidate_entry = close
                    float candidate_sl = setup_direction == 1 ? pullback_extreme - sl_offset * syminfo.mintick : pullback_extreme + sl_offset * syminfo.mintick
                    float candidate_tp = setup_direction == 1 ? impulse_high - tp_offset * syminfo.mintick : impulse_low + tp_offset * syminfo.mintick
                    float risk = math.abs(candidate_entry - candidate_sl)
                    float reward = setup_direction == 1 ? candidate_tp - candidate_entry : candidate_entry - candidate_tp
                    if risk > 0 and reward > 0 and reward / risk >= min_rr
                        position := setup_direction
                        active_entry := candidate_entry
                        active_sl := candidate_sl
                        active_tp := candidate_tp
                        entry_bar := bar_index
                        long_signal := position == 1
                        short_signal := position == -1
                        label.new(bar_index, position == 1 ? low : high, position == 1 ? "LONG" : "SHORT", color = position == 1 ? up_trend : down_trend, textcolor = color.white, style = position == 1 ? label.style_label_up : label.style_label_down)
                    else
                        rr_rejected := true
                    setup_state := 3
                    if not na(msb_tag)
                        label.delete(msb_tag)
                        msb_tag := na

    if position != 0 and bar_index > entry_bar
        bool hit_sl = position == 1 ? low <= active_sl : high >= active_sl
        bool hit_tp = position == 1 ? high >= active_tp : low <= active_tp
        if hit_sl or hit_tp
            sl_signal := hit_sl
            tp_signal := not hit_sl and hit_tp
            bool label_below_bar = position == 1 ? hit_sl : not hit_sl
            float exit_label_y = label_below_bar ? low : high
            label.new(bar_index, exit_label_y, hit_sl ? "SL" : "TP", color = hit_sl ? color.red : color.green, textcolor = color.white, style = label_below_bar ? label.style_label_up : label.style_label_down)
            position := 0
            active_entry := na
            active_sl := na
            active_tp := na
            entry_bar := -1

plot(show_fib and (setup_state == 1 or setup_state == 2) ? fib50 : na, "Fibonacci 50%", color = color.gray, linewidth = 2, style = plot.style_linebr, display = display.pane)
plot(show_guide and setup_state == 2 ? msb_level : na, "Уровень подтверждения MSB", color = setup_direction == 1 ? color.green : color.red, linewidth = 2, style = plot.style_linebr, display = display.pane)
plotshape(show_guide and touch_signal ? fib50 : na, title = "Касание 50%", style = shape.circle, location = location.absolute, color = color.orange, size = size.tiny, display = display.pane)
plotshape(show_guide and rr_rejected ? close : na, title = "MSB: недостаточный RR", style = shape.xcross, location = location.absolute, color = color.orange, size = size.small, text = "RR", display = display.pane)
plot(show_levels and position != 0 ? active_entry : na, "Entry", color = color.blue, style = plot.style_linebr, display = display.pane)
plot(show_levels and position != 0 ? active_sl : na, "Stop Loss", color = color.red, linewidth = 2, style = plot.style_linebr, display = display.pane)
plot(show_levels and position != 0 ? active_tp : na, "Take Profit", color = color.green, linewidth = 2, style = plot.style_linebr, display = display.pane)

if barstate.islast
    string trend_text = started != 1 ? "Тренд: не определён" : type_of_trend == 1 ? "Тренд: ↑" : "Тренд: ↓"
    string next_text = position != 0 ? "Сделка открыта" : setup_state == 1 ? "Ждём 50%" : setup_state == 2 and na(msb_level) ? "50% достигнуты · ждём свинг" : setup_state == 2 ? "Ждём пробой MSB" : setup_state == 3 ? "Импульс использован" : "Ждём импульс"
    color state_color = position != 0 ? color.blue : setup_state == 2 ? color.orange : color.gray
    table.cell(status_table, 0, 0, show_status ? trend_text : "", text_color = color.white, bgcolor = show_status ? color.new(color.black, 20) : color.new(color.black, 100), text_size = size.small)
    table.cell(status_table, 0, 1, show_status ? next_text : "", text_color = color.white, bgcolor = show_status ? color.new(state_color, 25) : color.new(color.black, 100), text_size = size.small)
    if not na(msb_tag) and setup_state == 2
        label.set_x(msb_tag, bar_index + 1)

alertcondition(long_signal, "Long", "Almazov Trade: Trend Retracement — LONG")
alertcondition(short_signal, "Short", "Almazov Trade: Trend Retracement — SHORT")
alertcondition(tp_signal, "Take Profit", "Almazov Trade: Trend Retracement — TP")
alertcondition(sl_signal, "Stop Loss", "Almazov Trade: Trend Retracement — SL")
alertcondition(touch_signal, "50% достигнуты", "Almazov Trade: Trend Retracement — ожидаем MSB")
````
