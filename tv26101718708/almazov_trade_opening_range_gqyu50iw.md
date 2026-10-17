# Almazov Trade: Opening Range

- url: https://www.tradingview.com/script/GQyU50iW-almazov-trade-opening-range/
- type: indicator
- pine_id: PUB;444ccf37b84b48b0b9c3a0ebc91c1482
- version: 1.0

## Description

[b]Almazov Trade: Opening Range[/b]

Almazov Trade: Opening Range is an open-source indicator for the first confirmed close outside the 09:30–10:00 New York opening range. It builds the range from chart candles, displays hypothetical entry/SL/TP levels, and counts completed outcomes without placing orders.

[b]Range and supported timeframes[/b]

The reference window is 09:30–10:00, Monday–Friday, in America/New_York time (including daylight-saving changes). Its high and low are accumulated from current-chart OHLC bars, without request.security(). A usable range requires correctly aligned, consecutive candles covering the full window, ending at 10:00. Missing data invalidate the range; incompatible alignment or candle duration can trigger a runtime error.

Supported timeframes: [b]1, 2, 3, 5, 6, 10, 15 and 30 minutes[/b], provided actual bar boundaries match the session. Other intervals and non-standard charts (including Heikin Ashi and Renko) are rejected.

[b]Signal and risk rules[/b]

[list=1]
[*]Once a valid range is complete, LONG requires a candle to close strictly above its high; SHORT requires a close strictly below its low. A wick break or equality is insufficient.
[*]Only the first qualifying closing breakout per range is considered, even if no trade can open. Entry requires no active position, no exit on the same bar, and positive risk.
[*]Hypothetical entry = breakout candle close. LONG SL = its low; SHORT SL = its high. Risk = absolute entry-to-SL distance (1R).
[*]LONG TP = entry + risk × RR; SHORT TP = entry − risk × RR. Default RR is 3.0. Levels remain fixed; only one position is tracked, potentially across sessions.
[*]SL/TP checks start on the bar after entry and are confirmed at bar close. Touching both on one candle counts as SL because their intrabar sequence is unknown. No trailing, partial or end-of-day exits are implemented.
[/list]

[b]Display and outcome markers[/b]

The blue opening-range box and high/low lines show the reference period. LONG/SHORT labels appear below/above entry candles; optional entry dots and candle highlighting assist visual inspection. An active trade uses a light entry line, red SL/risk area and green TP/reward area. Historical drawings are subject to TradingView's object limits.

Exit markers identify the [i]event candle, not the execution price[/i]: LONG SL and SHORT TP appear at its [b]low[/b] (label pointing up); LONG TP and SHORT SL at its [b]high[/b] (label pointing down). The underlying SL and TP prices do not change.

[b]Statistics and alerts[/b]

The upper-right table reports completed hypothetical trades: closed trades, TP count, SL count, TP rate (TP / closed × 100%), and gross Total R. Each TP adds the selected RR; each SL subtracts 1R. The active trade is excluded. Four alerts are available: LONG, SHORT, TP and SL. Use “Once Per Bar Close”.

[quote]This is not a Strategy Tester report or actual execution history. Fees, spread, slippage, funding, leverage, liquidity, position sizing and gap fills are not modeled. Total R is not account return; historical outcomes do not imply future profitability. Results depend on available history, timeframe and session settings.[/quote]

[b]Implementation and settings[/b]

Opening-range breakouts are an established concept. This implementation combines complete-bar validation on eight timeframes, first-close-breakout-only selection, breakout-candle risk, fixed RR targets, one-position tracking and a compact R-based outcome table. Default values are not claimed optimal. The script uses confirmed closes for signals; live range drawings can develop intrabar.

The interface contains Russian labels; their English equivalents are listed here:

[list]
[*][i]Opening Range:[/i] «Цвет диапазона» = Range color (blue); «Прозрачность диапазона» = Range transparency (88, 0–100); «Толщина рамки» = Border width (2, 1–4); «Толщина уровней» = Level width (2, 1–4); «Подпись Opening Range» = Show caption (on).
[*][i]Сигнал = Signal:[/i] «Цвет LONG» / «Цвет SHORT» = Long / Short color (green/red); «Подсвечивать пробойную свечу» = Highlight breakout candle (on); «Показывать LONG / SHORT» = Show entry labels (on); «Показывать точку входа» = Show entry dot (on).
[*][i]Сделка = Trade:[/i] «Risk / Reward» = RR multiple (3.0; min 0.1); «Показывать сетку сделки» = Show trade grid (on); «Цвет зоны риска» = Risk color (red); «Цвет зоны прибыли» = Reward color (green); «Цвет Entry» = Entry-line color (light grey); «Прозрачность зон» = Zone transparency (78, 0–100).
[*][i]Table:[/i] «СТАТИСТИКА» / «РЕЗУЛЬТАТ» = Statistics / Result; «Закрытые сделки» = Closed trades; «Тейк-профиты» / «Стоп-лоссы» = TP / SL count; «Доля тейков» = TP rate; «Сумма R» = Total R.
[*][i]Alerts:[/i] «первый пробой NY Opening Range» = first NY range breakout; «Take Profit достигнут» / «Stop Loss достигнут» = TP / SL reached.
[*][i]Errors:[/i] «Неподходящий таймфрейм» = Unsupported timeframe; «Выберите обычный график» = Use standard OHLC chart; «Свечи графика не совпадают с началом Opening Range» = Bars do not align with 09:30 NY; «Свеча пересекает границу Opening Range ... или имеет неверную длительность» = Bar crosses window boundary or has incorrect duration.
[/list]

[b]РУССКАЯ ВЕРСИЯ[/b]

[b]Almazov Trade: Opening Range[/b]

Индикатор с открытым кодом для поиска [b]первого подтверждённого пробоя[/b] диапазона 09:30–10:00 по Нью-Йорку. Самостоятельно строит диапазон из свечей графика, показывает условные вход, стоп и тейк и ведёт статистику завершённых сигналов.

[b]Диапазон и сигналы[/b]

Работает на стандартных графиках [b]1, 2, 3, 5, 6, 10, 15 и 30 минут[/b], если свечи точно укладываются в интервал 09:30–10:00 America/New_York. Учитывается переход на летнее время. Неполный диапазон не используется; несовместимый таймфрейм, синтетический график или неправильные границы свечей могут вызвать ошибку.

[list=1]
[*]После завершения диапазона LONG возникает при закрытии строго выше его High, SHORT — строго ниже Low. Прокол тенью не считается.
[*]Используется только первый пробой диапазона, даже если вход был невозможен. Одновременно сопровождается не более одной условной сделки.
[*]Entry — Close пробойной свечи; SL лонга — её Low, SL шорта — её High. TP = Entry ± риск × RR (по умолчанию 3,0). Уровни фиксируются.
[*]Со следующей свечи проверяются касания SL/TP; результат подтверждается на закрытии. Если свеча затронула оба уровня, засчитывается SL. Переноса стопа, частичных и принудительных дневных выходов нет.
[/list]

[b]Метки и статистика[/b]

Синий прямоугольник и линии показывают границы диапазона. Светлая линия — Entry, красная зона — риск/SL, зелёная — потенциальная прибыль/TP. LONG подписан под свечой входа, SHORT — над ней. Метки выхода размещаются [b]на экстремумах свечи события[/b]: LONG SL и SHORT TP — на Low (label up); LONG TP и SHORT SL — на High (label down). Место метки не является ценой исполнения.

Таблица справа показывает закрытые сделки, число TP и SL, долю тейков и сумму R: тейк добавляет заданный RR, стоп вычитает 1R. Доступны четыре алерта: LONG, SHORT, TP, SL, с подтверждением на закрытии бара.

[quote]Статистика условная, не является отчётом Strategy Tester. Комиссии, спред, проскальзывание, ликвидность, гэпы и размер позиции не моделируются. Сумма R — не доходность счёта; история не гарантирует будущих результатов.[/quote]

[b]Особенности и настройки[/b]

Opening Range Breakout — известная концепция. Здесь реализованы проверка полноты диапазона на восьми ТФ, вход только по первому закрытию за границей, стоп по пробойной свече, фиксированный RR, одна активная сделка и таблица результатов. Это аналитический индикатор, а не торговый робот. Настройки разделены на «Opening Range», «Сигнал» и «Сделка»: оформление диапазона, отображение сигналов, RR (3,0), цвета и прозрачность сетки. Полный перевод элементов интерфейса и сообщений об ошибках приведён в английской части выше.

## Source Code

````pine
//@version=6
indicator("Almazov Trade: Opening Range", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

color range_color = input.color(color.rgb(41, 121, 255), "Цвет диапазона", group = "Opening Range", display = display.none)
int fill_transparency = input.int(88, "Прозрачность диапазона", minval = 0, maxval = 100, group = "Opening Range", display = display.none)
int border_width = input.int(2, "Толщина рамки", minval = 1, maxval = 4, group = "Opening Range", display = display.none)
int level_width = input.int(2, "Толщина уровней", minval = 1, maxval = 4, group = "Opening Range", display = display.none)
bool show_range_caption = input.bool(true, "Подпись Opening Range", group = "Opening Range", display = display.none)

color long_color = input.color(color.rgb(0, 200, 120), "Цвет LONG", group = "Сигнал", display = display.none)
color short_color = input.color(color.rgb(230, 70, 70), "Цвет SHORT", group = "Сигнал", display = display.none)
bool highlight_breakout = input.bool(true, "Подсвечивать пробойную свечу", group = "Сигнал", display = display.none)
bool show_signal_labels = input.bool(true, "Показывать LONG / SHORT", group = "Сигнал", display = display.none)
bool show_breakout_marker = input.bool(true, "Показывать точку входа", group = "Сигнал", display = display.none)

float rr = input.float(3.0, "Risk / Reward", minval = 0.1, step = 0.1, group = "Сделка", display = display.none)
bool show_trade_grid = input.bool(true, "Показывать сетку сделки", group = "Сделка", display = display.none)
color risk_color = input.color(color.rgb(220, 65, 85), "Цвет зоны риска", group = "Сделка", display = display.none)
color reward_color = input.color(color.rgb(0, 160, 120), "Цвет зоны прибыли", group = "Сделка", display = display.none)
color entry_color = input.color(color.rgb(230, 230, 230), "Цвет Entry", group = "Сделка", display = display.none)
int zone_transparency = input.int(78, "Прозрачность зон", minval = 0, maxval = 100, group = "Сделка", display = display.none)

string NY_TIMEZONE = "America/New_York"
string OR_SESSION = "0930-1000:23456"

int timeframe_minutes = timeframe.multiplier
bool valid_timeframe = timeframe.isminutes and timeframe_minutes <= 30 and 30 % timeframe_minutes == 0

if barstate.isfirst
    if not valid_timeframe
        runtime.error("Неподходящий таймфрейм. Используйте 1, 2, 3, 5, 6, 10, 15 или 30 минут для диапазона 09:30–10:00 (Нью-Йорк).")
    if not chart.is_standard
        runtime.error("Выберите обычный график со стандартными ценами OHLC. Heikin Ashi, Renko и другие синтетические графики не поддерживаются.")

bool in_opening_range = not na(time(timeframe.period, OR_SESSION, NY_TIMEZONE))
bool range_starts = in_opening_range and not in_opening_range[1]
bool range_ends = not in_opening_range and in_opening_range[1]

int range_start_time = timestamp(NY_TIMEZONE, year(time, NY_TIMEZONE), month(time, NY_TIMEZONE), dayofmonth(time, NY_TIMEZONE), 9, 30)
int range_end_time = timestamp(NY_TIMEZONE, year(time, NY_TIMEZONE), month(time, NY_TIMEZONE), dayofmonth(time, NY_TIMEZONE), 10, 0)
int bar_duration_ms = timeframe_minutes * 60000
int required_range_bars = 30 / timeframe_minutes

var float range_high = na
var float range_low = na
var bool range_ready = false
var bool range_complete = false
var int range_bar_count = 0
var bool first_breakout_used = false

var box current_range_box = na
var line current_high_line = na
var line current_low_line = na
var label current_caption = na

var bool trade_active = false
var int trade_direction = 0
var float trade_entry = na
var float trade_stop = na
var float trade_target = na

var box active_risk_box = na
var box active_reward_box = na
var line active_stop_line = na
var line active_entry_line = na
var line active_target_line = na

var int closed_trades = 0
var int winning_trades = 0
var int losing_trades = 0
var float total_r = 0.0

var table stats_table = table.new(position.top_right, 2, 6, bgcolor = color.new(color.black, 15), frame_color = color.new(color.white, 70), frame_width = 1, border_color = color.new(color.white, 85), border_width = 1)

bool long_entry_signal = false
bool short_entry_signal = false
bool stop_loss_exit = false
bool take_profit_exit = false
bool trade_closed_this_bar = false

if range_starts
    if time != range_start_time and bar_index > 0
        runtime.error("Свечи графика не совпадают с началом Opening Range в 09:30 по Нью-Йорку. Выберите другой таймфрейм или инструмент с корректной сессией.")

    if not na(current_high_line)
        line.set_extend(current_high_line, extend.none)
        line.set_x2(current_high_line, bar_index)
        current_high_line := na
    if not na(current_low_line)
        line.set_extend(current_low_line, extend.none)
        line.set_x2(current_low_line, bar_index)
        current_low_line := na
    if not na(current_caption)
        label.delete(current_caption)
        current_caption := na

    range_high := na
    range_low := na
    range_ready := false
    range_complete := time == range_start_time
    range_bar_count := 0
    first_breakout_used := false

    if range_complete
        current_range_box := box.new(left = bar_index, top = high, right = bar_index + 1, bottom = low, xloc = xloc.bar_index, border_color = range_color, border_width = border_width, bgcolor = color.new(range_color, fill_transparency))

if in_opening_range and range_complete
    if na(time_close) or time_close - time != bar_duration_ms or time_close > range_end_time
        runtime.error("Свеча пересекает границу Opening Range 09:30–10:00 или имеет неверную длительность. Выберите совместимый таймфрейм и стандартный график.")

    range_complete := range_bar_count == 0 or time == time_close[1]

    if range_complete
        range_bar_count += 1
        range_high := na(range_high) ? high : math.max(range_high, high)
        range_low := na(range_low) ? low : math.min(range_low, low)

        if not na(current_range_box)
            box.set_right(current_range_box, bar_index + 1)
            box.set_top(current_range_box, range_high)
            box.set_bottom(current_range_box, range_low)

if range_ends
    range_ready := range_complete and range_bar_count == required_range_bars and time_close[1] == timestamp(NY_TIMEZONE, year(time[1], NY_TIMEZONE), month(time[1], NY_TIMEZONE), dayofmonth(time[1], NY_TIMEZONE), 10, 0)

    if range_ready
        current_high_line := line.new(x1 = bar_index, y1 = range_high, x2 = bar_index + 1, y2 = range_high, xloc = xloc.bar_index, extend = extend.right, color = range_color, width = level_width)
        current_low_line := line.new(x1 = bar_index, y1 = range_low, x2 = bar_index + 1, y2 = range_low, xloc = xloc.bar_index, extend = extend.right, color = range_color, width = level_width)

        if show_range_caption
            float caption_price = range_high + (range_high - range_low) * 0.05
            current_caption := label.new(x = bar_index - 3, y = caption_price, text = "NY OPENING RANGE\n09:30–10:00", xloc = xloc.bar_index, style = label.style_label_down, color = range_color, textcolor = color.white, size = size.tiny)

    else if not na(current_range_box)
        box.delete(current_range_box)

    current_range_box := na

if trade_active and show_trade_grid
    int active_right = bar_index + 1
    if not na(active_risk_box)
        box.set_right(active_risk_box, active_right)
    if not na(active_reward_box)
        box.set_right(active_reward_box, active_right)
    if not na(active_stop_line)
        line.set_x2(active_stop_line, active_right)
    if not na(active_entry_line)
        line.set_x2(active_entry_line, active_right)
    if not na(active_target_line)
        line.set_x2(active_target_line, active_right)

if trade_active and barstate.isconfirmed
    bool stop_hit = trade_direction == 1 ? low <= trade_stop : high >= trade_stop
    bool target_hit = trade_direction == 1 ? high >= trade_target : low <= trade_target

    if stop_hit or target_hit
        stop_loss_exit := stop_hit
        take_profit_exit := not stop_hit and target_hit
        trade_closed_this_bar := true
        closed_trades += 1

        if stop_hit
            losing_trades += 1
            total_r -= 1.0
        else
            winning_trades += 1
            total_r += rr

        bool label_below = trade_direction == 1 ? stop_hit : not stop_hit
        label.new(x = bar_index, y = label_below ? low : high, text = stop_hit ? "SL" : "TP", xloc = xloc.bar_index, style = label_below ? label.style_label_up : label.style_label_down, color = stop_hit ? risk_color : reward_color, textcolor = color.white, size = size.small)

        trade_active := false
        trade_direction := 0

if trade_closed_this_bar
    if show_trade_grid
        int exit_right = bar_index + 1
        if not na(active_risk_box)
            box.set_right(active_risk_box, exit_right)
        if not na(active_reward_box)
            box.set_right(active_reward_box, exit_right)
        if not na(active_stop_line)
            line.set_x2(active_stop_line, exit_right)
        if not na(active_entry_line)
            line.set_x2(active_entry_line, exit_right)
        if not na(active_target_line)
            line.set_x2(active_target_line, exit_right)

    active_risk_box := na
    active_reward_box := na
    active_stop_line := na
    active_entry_line := na
    active_target_line := na
    trade_entry := na
    trade_stop := na
    trade_target := na

bool first_long_breakout = false
bool first_short_breakout = false
bool can_detect_breakout = range_ready and not in_opening_range and not first_breakout_used and barstate.isconfirmed

if can_detect_breakout
    if close > range_high
        first_breakout_used := true
        first_long_breakout := true
    else if close < range_low
        first_breakout_used := true
        first_short_breakout := true

bool can_open_trade = not trade_active and not trade_closed_this_bar

if can_open_trade and (first_long_breakout or first_short_breakout)
    int entry_direction = first_long_breakout ? 1 : -1
    float risk = entry_direction == 1 ? close - low : high - close

    if risk > 0
        long_entry_signal := entry_direction == 1
        short_entry_signal := entry_direction == -1
        trade_active := true
        trade_direction := entry_direction
        trade_entry := close
        trade_stop := entry_direction == 1 ? low : high
        trade_target := trade_entry + entry_direction * risk * rr

        if show_signal_labels
            label.new(x = bar_index, y = entry_direction == 1 ? low : high, text = entry_direction == 1 ? "LONG" : "SHORT", xloc = xloc.bar_index, style = entry_direction == 1 ? label.style_label_up : label.style_label_down, color = entry_direction == 1 ? long_color : short_color, textcolor = color.white, size = size.small)

        if show_trade_grid
            int trade_right = bar_index + 1
            float risk_top = math.max(trade_entry, trade_stop)
            float risk_bottom = math.min(trade_entry, trade_stop)
            float reward_top = math.max(trade_entry, trade_target)
            float reward_bottom = math.min(trade_entry, trade_target)

            active_risk_box := box.new(left = bar_index, top = risk_top, right = trade_right, bottom = risk_bottom, xloc = xloc.bar_index, border_color = color.new(risk_color, 100), border_width = 1, bgcolor = color.new(risk_color, zone_transparency))
            active_reward_box := box.new(left = bar_index, top = reward_top, right = trade_right, bottom = reward_bottom, xloc = xloc.bar_index, border_color = color.new(reward_color, 100), border_width = 1, bgcolor = color.new(reward_color, zone_transparency))
            active_stop_line := line.new(x1 = bar_index, y1 = trade_stop, x2 = trade_right, y2 = trade_stop, xloc = xloc.bar_index, color = risk_color, width = 1)
            active_entry_line := line.new(x1 = bar_index, y1 = trade_entry, x2 = trade_right, y2 = trade_entry, xloc = xloc.bar_index, color = entry_color, width = 2)
            active_target_line := line.new(x1 = bar_index, y1 = trade_target, x2 = trade_right, y2 = trade_target, xloc = xloc.bar_index, color = reward_color, width = 1)

color breakout_bar_color = long_entry_signal ? long_color : short_entry_signal ? short_color : na
barcolor(highlight_breakout ? breakout_bar_color : na)

plotshape(show_breakout_marker and long_entry_signal ? close : na, title = "LONG Entry", style = shape.circle, location = location.absolute, color = long_color, size = size.tiny, display = display.pane)
plotshape(show_breakout_marker and short_entry_signal ? close : na, title = "SHORT Entry", style = shape.circle, location = location.absolute, color = short_color, size = size.tiny, display = display.pane)

float win_rate = closed_trades > 0 ? winning_trades * 100.0 / closed_trades : 0.0

if barstate.islast
    color header_bg = color.rgb(35, 40, 50)
    color cell_bg = color.rgb(22, 26, 34)

    table.cell(stats_table, 0, 0, "СТАТИСТИКА", text_color = color.white, bgcolor = header_bg, text_size = size.small)
    table.cell(stats_table, 1, 0, "РЕЗУЛЬТАТ", text_color = color.white, bgcolor = header_bg, text_size = size.small)

    table.cell(stats_table, 0, 1, "Закрытые сделки", text_color = color.white, bgcolor = cell_bg)
    table.cell(stats_table, 1, 1, str.tostring(closed_trades), text_color = color.white, bgcolor = cell_bg)

    table.cell(stats_table, 0, 2, "Тейк-профиты", text_color = color.white, bgcolor = cell_bg)
    table.cell(stats_table, 1, 2, str.tostring(winning_trades), text_color = reward_color, bgcolor = cell_bg)

    table.cell(stats_table, 0, 3, "Стоп-лоссы", text_color = color.white, bgcolor = cell_bg)
    table.cell(stats_table, 1, 3, str.tostring(losing_trades), text_color = risk_color, bgcolor = cell_bg)

    table.cell(stats_table, 0, 4, "Доля тейков", text_color = color.white, bgcolor = cell_bg)
    table.cell(stats_table, 1, 4, str.tostring(win_rate, "#.##") + "%", text_color = color.white, bgcolor = cell_bg)

    table.cell(stats_table, 0, 5, "Сумма R", text_color = color.white, bgcolor = cell_bg)
    table.cell(stats_table, 1, 5, str.tostring(total_r, "#.##") + "R", text_color = total_r >= 0 ? reward_color : risk_color, bgcolor = cell_bg)

alertcondition(long_entry_signal, title = "Almazov Trade LONG", message = "Almazov Trade: первый пробой NY Opening Range — LONG.")
alertcondition(short_entry_signal, title = "Almazov Trade SHORT", message = "Almazov Trade: первый пробой NY Opening Range — SHORT.")
alertcondition(take_profit_exit, title = "Almazov Trade TP", message = "Almazov Trade: Take Profit достигнут.")
alertcondition(stop_loss_exit, title = "Almazov Trade SL", message = "Almazov Trade: Stop Loss достигнут.")
````
