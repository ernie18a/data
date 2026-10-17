# HTF Candles [odnac]

- url: https://www.tradingview.com/script/qCOTCH0o/
- type: indicator
- pine_id: PUB;f24a0f239409416f9c575cfc00e2540c
- version: 1.0

## Description

[quote]This indicator is adapted from "ICT HTF Candles" by fadi, reworked with additional features such as Auto timeframe pairing, Session Stack, and extra customization options. Credit to the original author for the core concept.[/quote]


HTF Candles [odnac]

Displays higher-timeframe (HTF) candles on the right side of your chart, so you can read the bigger picture without switching timeframes. It also includes an optional Session Stack mode that builds the HTF candles from a session start.

━━━ Features ━━━

- Two HTF rows
Show up to two higher timeframes side by side, each with its own on/off toggle and "max candles" limit. The forming candle updates in real time.

- Auto timeframe pairing
In Auto mode the HTFs are picked from your chart timeframe:
1m → 15m / 4H
5m → 1H / 1D
15m → 4H / 1W
1H → 1D / 1M
4H → 1W
1D → 1M
Other chart timeframes use the manual pickers. You can also switch to Manual mode at any time.

- Fair Value Gaps
Detects FVGs between HTF candles and highlights them with bullish/bearish colors.

- Liquidity lines
Draws each HTF candle's high and low as lines. When price sweeps a level, its line is removed, so only untouched liquidity remains.

- Candle start time
Optional label under each candle showing when it opened, in the timezone of your choice.

- Remaining time
Shows a countdown to the close of the current HTF candle (realtime bars only).

━━━ Session Stack ━━━

When enabled, the HTF candles are stacked from the start of a custom session instead of showing a rolling last-N window.

- Session and timezone: set any session (e.g. NY 0930-1600, London 0800-1700) and the timezone it is read in.
- Resets at every session start.
- Apply to HTF 1, HTF 2, or both.
- Keep Stacking After Session End:
  OFF – the stack disappears when the session ends.
  ON – the stack keeps growing after the session ends and resets at the next session start (only the start time is used).
- Include Weekends: optional.

━━━ Notes ━━━

- An HTF is only drawn if it is higher than the chart timeframe (and divides evenly for intraday timeframes).
- With Keep Stacking ON, raise the "max candles" value so the whole stack fits (e.g. a 15m HTF can produce 96 candles in 24 hours).
- The remaining-time countdown only updates on realtime bars.
- Drawings are placed to the right of the latest bar; use "padding" and "space" settings to adjust the layout.

━━━ Settings overview ━━━

- Timeframe Pairing: Auto / Manual, HTF 1 and HTF 2 pickers
- Session Stack: session, timezone, keep stacking, weekends
- Styling: bull/bear body, border and wick colors, padding, spacing, candle width
- Label Settings: HTF label and remaining time (color, size)
- Imbalance: FVG colors
- Candle Time: show/hide, color, size, timezone
- Liquidity: color, width, line style

## Source Code

````pine
//@version=6
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Original: "ICT HTF Candles" by fadi
// Modified by odnac: Auto timeframe pairing, Session Stack, additional customization
indicator('HTF Candles [odnac]', overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_bars_back = 5000)

display_option = display.all - display.status_line

type Candle
    float o
    float c
    float h
    float l
    int o_time
    int o_idx
    int c_idx
    int h_idx
    int l_idx
    box body
    line wick_up
    line wick_down
    label timeLabel
    line high_line
    line low_line

type Imbalance
    box b
    int idx

type CandleSettings
    bool show
    string htf
    int max_display

type Settings
    color bull_body
    color bull_border
    color bull_wick
    color bear_body
    color bear_border
    color bear_wick
    int offset
    int buffer
    int htf_buffer
    int width
    bool fvg_show
    color fvg_bull_color
    color fvg_bear_color
    bool htf_label_show
    color htf_label_color
    string htf_label_size
    bool htf_timer_show
    color htf_timer_color
    string htf_timer_size
    bool show_candle_time
    color cand_time_color
    string cand_time_size
    string selectedTz
    bool liq_show
    color liq_color
    int liq_width
    string liq_style

type CandleSet
    array<Candle> candles
    array<Imbalance> imbalances
    CandleSettings settings
    label tfNameTop
    label tfTimerTop

type Helper
    string name = 'Helper'

Settings settings = Settings.new()

var CandleSettings SettingsHTF1 = CandleSettings.new()
var CandleSettings SettingsHTF2 = CandleSettings.new()

var array<Candle> candles_1 = array.new<Candle>(0)
var array<Candle> candles_2 = array.new<Candle>(0)

var array<Imbalance> imbalances_1 = array.new<Imbalance>()
var array<Imbalance> imbalances_2 = array.new<Imbalance>()

var CandleSet htf1 = CandleSet.new()
htf1.settings := SettingsHTF1
htf1.candles := candles_1
htf1.imbalances := imbalances_1

var CandleSet htf2 = CandleSet.new()
htf2.settings := SettingsHTF2
htf2.candles := candles_2
htf2.imbalances := imbalances_2

//+------------------------------------------------------------------------------------------------------------+//
//+--- Settings                                                                                             ---+//
//+------------------------------------------------------------------------------------------------------------+//

string group_style              = "Styling  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
string group_label              = "Label Settings  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
string group_imbalance          = "Imbalance  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
string group_time               = "Candle Time  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
string group_liquidity          = "Liquidity  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
string group_auto               = "Timeframe Pairing  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
string group_stack              = "Session Stack  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

// --- Auto/Manual mode toggle -------------------------------------------------
string tf_mode = input.string('Auto', 'HTF Mode', options = ['Auto', 'Manual'], group = group_auto,
     tooltip = 'Auto: HTF1/HTF2 are chosen automatically based on the current chart timeframe.\n' +
                '1m → 15m / 4H\n5m → 1H / 1D\n15m → 4H / 1W\n1H → 1D / 1M\n' +
                '4H → 1W only (HTF2 off)\n1D → 1M only (HTF2 off)\n' +
                'Any other chart timeframe falls back to the Manual pickers below.\n' +
                'Manual: always use the timeframe pickers below.')

htf1_show_input                 = input.bool(true, 'HTF 1      ', inline = 'htf1')
htf_1                           = input.timeframe('240', '', inline = 'htf1', display = display_option)
htf1.settings.max_display       := input.int(16, '', inline = 'htf1', display = display_option)

htf2_show_input                 = input.bool(true, 'HTF 2      ', inline = 'htf2')
htf_2                           = input.timeframe('1W', '', inline = 'htf2', display = display_option)
htf2.settings.max_display       := input.int(3, '', inline = 'htf2', display = display_option)

// --- Resolve HTF1 / HTF2 from the chart's current timeframe when Auto is selected ---
chartSec          = timeframe.in_seconds(timeframe.period)
auto_htf1         = htf_1
auto_htf2         = htf_2
auto_htf2_enabled = true

if chartSec == 60           // chart = 1m
    auto_htf1 := '15'
    auto_htf2 := '240'
else if chartSec == 300      // chart = 5m
    auto_htf1 := '60'
    auto_htf2 := '1D'
else if chartSec == 900      // chart = 15m
    auto_htf1 := '240'
    auto_htf2 := '1W'
else if chartSec == 3600     // chart = 1H
    auto_htf1 := '1D'
    auto_htf2 := '1M'
else if chartSec == 14400    // chart = 4H -> HTF1 only, Weekly
    auto_htf1 := '1W'
    auto_htf2_enabled := false
else if chartSec == 86400    // chart = 1D -> HTF1 only, Monthly
    auto_htf1 := '1M'
    auto_htf2_enabled := false
else
    auto_htf1 := htf_1       // unmapped chart TF -> fall back to manual pickers
    auto_htf2 := htf_2
    auto_htf2_enabled := htf2_show_input

htf1.settings.htf  := tf_mode == 'Auto' ? auto_htf1 : htf_1
htf2.settings.htf  := tf_mode == 'Auto' ? auto_htf2 : htf_2
htf1.settings.show := htf1_show_input
htf2.settings.show := tf_mode == 'Auto' ? (htf2_show_input and auto_htf2_enabled) : htf2_show_input

// --- Session Stack - 2nd group in the settings panel ---------------------------
bool stack_enable = input.bool(false, 'Enable Session Stacking', group = group_stack,
     tooltip = 'ON: HTF candles are stacked from the session start. The stack is reset at every session start.\nOFF: original behavior (rolling last N candles).')
bool stack_htf1   = input.bool(true, 'Apply to HTF 1', inline = 'stack_apply', group = group_stack)
bool stack_htf2   = input.bool(true, 'Apply to HTF 2', inline = 'stack_apply', group = group_stack)
string stack_session = input.session('0930-1600', 'Session', group = group_stack,
     tooltip = 'Stack start/end time, interpreted in the Session Timezone below.\nThe stack starts at the first bar of this session.\nWhen "Keep Stacking After Session End" is ON, only the start time is used.\nExamples: NY 0930-1600 (America/New_York), London 0800-1700 (Europe/London)')
string stack_tz = input.string('America/New_York', 'Session Timezone', options = ['America/New_York', 'Europe/London', 'UTC-10', 'UTC-9', 'UTC-8', 'UTC-7', 'UTC-6', 'UTC-5', 'UTC-4', 'UTC-3', 'UTC-2', 'UTC-1', 'UTC+0', 'UTC+1', 'UTC+2', 'UTC+3', 'UTC+4', 'UTC+5', 'UTC+6', 'UTC+7', 'UTC+8', 'UTC+9', 'UTC+10', 'UTC+11', 'UTC+12', 'UTC+13'], group = group_stack, display = display_option)
bool stack_keep = input.bool(false, 'Keep Stacking After Session End', group = group_stack,
     tooltip = 'OFF: the stack disappears when the session ends.\nON: the stack keeps growing after the session ends and resets at the next session start (only the session start time is used).\nTip: raise the "max candles" value of the HTF rows above so the whole stack fits.')
bool stack_weekend   = input.bool(false, 'Include Weekends', group = group_stack,
     tooltip = 'Only used when Session Stacking is ON. OFF: Saturday/Sunday are treated as outside the session.')

settings.bull_body              := input.color(color.new(#089981, 10), 'Body  ', inline = 'body', group=group_style)
settings.bear_body              := input.color(color.new(#f23645, 10), '', inline = 'body', group=group_style)
settings.bull_border            := input.color(color.new(#089981, 10), 'Borders', inline = 'borders', group=group_style)
settings.bear_border            := input.color(color.new(#f23645, 10), '', inline = 'borders', group=group_style)
settings.bull_wick              := input.color(color.new(#089981, 10), 'Wick  ', inline = 'wick', group=group_style)
settings.bear_wick              := input.color(color.new(#f23645, 10), '', inline = 'wick', group=group_style)

settings.offset                 := input.int(20, 'padding from current candles', minval = 1, group=group_style, display = display_option)
settings.buffer                 := input.int(1, 'space between candles', minval = 1, maxval = 4, group=group_style, display = display_option)
settings.htf_buffer             := input.int(20, 'space between Higher Timeframes', minval = 1, maxval = 50, group=group_style, display = display_option)
settings.width                  := input.int(1, 'Candle Width', minval = 1, maxval = 4, group=group_style, display = display_option) * 2

settings.htf_label_show         := input.bool(true, 'HTF Label           ', group=group_label, inline = 'HTFlabel')
settings.htf_label_color        := input.color(color.new(color.white, 20), '', group=group_label, inline = 'HTFlabel')
settings.htf_label_size         := input.string(size.large, '', [size.tiny, size.small, size.normal, size.large, size.huge], group=group_label, inline = 'HTFlabel', display = display_option)

settings.htf_timer_show         := input.bool(true, 'Remaining time      ', inline = 'timer', group=group_label)
settings.htf_timer_color        := input.color(color.new(color.white, 0), '', inline = 'timer', group=group_label)
settings.htf_timer_size         := input.string(size.normal, '', [size.tiny, size.small, size.normal, size.large, size.huge], group=group_label, inline = 'timer', display = display_option)

settings.fvg_show               := input.bool(true, 'Fair Value Gap   ', group = group_imbalance, inline = 'fvg')
settings.fvg_bull_color         := input.color(color.new(#089981, 75), '', inline = 'fvg', group = group_imbalance)
settings.fvg_bear_color         := input.color(color.new(#f23645, 75), '', inline = 'fvg', group = group_imbalance)

settings.show_candle_time       := input.bool(true, 'Show Candle Start Time   ', inline = 'candtime', group = group_time)
settings.cand_time_color        := input.color(color.gray, '', inline = 'candtime', group = group_time)
settings.cand_time_size         := input.string(size.small, '', [size.tiny, size.small, size.normal, size.large, size.huge], inline = 'candtime', group = group_time, display = display_option)
settings.selectedTz             := input.string('America/New_York', 'Timezone', options = ['America/New_York', 'Europe/London', 'UTC-10', 'UTC-9', 'UTC-8', 'UTC-7', 'UTC-6', 'UTC-5', 'UTC-4', 'UTC-3', 'UTC-2', 'UTC-1', 'UTC+0', 'UTC+1', 'UTC+2', 'UTC+3', 'UTC+4', 'UTC+5', 'UTC+6', 'UTC+7', 'UTC+8', 'UTC+9', 'UTC+10', 'UTC+11', 'UTC+12', 'UTC+13'], group = group_time, display = display_option)

settings.liq_show               := input.bool(true, 'Liquidity Lines   ', inline = 'liq', group = group_liquidity)
settings.liq_color              := input.color(color.yellow, '', inline = 'liq', group = group_liquidity)
settings.liq_width              := input.int(1, '', minval = 1, maxval = 4, inline = 'liq', group = group_liquidity, display = display_option)
settings.liq_style              := input.string('Solid', 'Line Style', options = ['Solid', 'Dashed', 'Dotted'], group = group_liquidity, display = display_option)

//+------------------------------------------------------------------------------------------------------------+//
//+--- Variables                                                                                            ---+//
//+------------------------------------------------------------------------------------------------------------+//

Helper helper = Helper.new()
color color_transparent = #ffffff00

//+------------------------------------------------------------------------------------------------------------+//
//+--- Internal Functions                                                                                   ---+//
//+------------------------------------------------------------------------------------------------------------+//

method Pad2(Helper helper, int n) =>
    helper.name := 'Pad2'
    n < 10 ? '0' + str.tostring(n) : str.tostring(n)

method FormatTime(Helper helper, int t, string tzChoice) =>
    helper.name := tzChoice
    int h = na
    int m = na
    if tzChoice == 'America/New_York' or tzChoice == 'Europe/London'
        h := hour(t, tzChoice)
        m := minute(t, tzChoice)
    else
        offsetVal = str.tonumber(str.replace(tzChoice, 'UTC', ''))
        offsetMs  = int(offsetVal * 60 * 60 * 1000)
        adjTime   = t + offsetMs
        h := hour(adjTime, 'UTC')
        m := minute(adjTime, 'UTC')
    helper.Pad2(h) + ':' + helper.Pad2(m)

method GetLineStyle(Helper helper, string styleStr) =>
    helper.name := styleStr
    out = switch styleStr
        'Solid' => line.style_solid
        'Dashed' => line.style_dashed
        => line.style_dotted
    out

method ValidTimeframe(Helper helper, string HTF) =>
    helper.name := HTF
    if timeframe.in_seconds(HTF) >= timeframe.in_seconds('D') and timeframe.in_seconds(HTF) > timeframe.in_seconds()
        true
    else
        n1 = timeframe.in_seconds()
        n2 = timeframe.in_seconds(HTF)
        n3 = n1 % n2
        n1 < n2 and math.round(n2 / n1) == n2 / n1


method RemainingTime(Helper helper, string HTF) =>
    helper.name := HTF
    if barstate.isrealtime
        timeRemaining = (time_close(HTF) - timenow) / 1000
        days = math.floor(timeRemaining / 86400)
        hours = math.floor((timeRemaining - days * 86400) / 3600)
        minutes = math.floor((timeRemaining - days * 86400 - hours * 3600) / 60)
        seconds = math.floor(timeRemaining - days * 86400 - hours * 3600 - minutes * 60)

        r = str.tostring(seconds, '00')
        if minutes > 0 or hours > 0 or days > 0
            r := str.tostring(minutes, '00') + ':' + r
            r
        if hours > 0 or days > 0
            r := str.tostring(hours, '00') + ':' + r
            r
        if days > 0
            r := str.tostring(days) + 'D ' + r
            r
        r
    else
        'n/a'

method HTFName(Helper helper, string HTF) =>
    helper.name := 'HTFName'
    formatted = HTF

    seconds = timeframe.in_seconds(HTF)
    if seconds < 60
        formatted := str.tostring(seconds) + 's'
        formatted
    else if seconds / 60 < 60
        formatted := str.tostring(seconds / 60) + 'm'
        formatted
    else if seconds / 60 / 60 < 24
        formatted := str.tostring(seconds / 60 / 60) + 'H'
        formatted
    formatted

method HTFEnabled(Helper helper) =>
    helper.name := 'HTFEnabled'
    int enabled = 0
    enabled := enabled + (htf1.settings.show ? 1 : 0)
    enabled := enabled + (htf2.settings.show ? 1 : 0)

    enabled

method CandleSetHigh(Helper helper, array<Candle> candles, float h) =>
    helper.name := 'CandlesSetHigh'
    float _h = h
    if array.size(candles) > 0
        for i = 0 to array.size(candles) - 1 by 1
            Candle c = array.get(candles, i)
            if c.h > _h
                _h := c.h
                _h
    _h

method CandleSetLow(Helper helper, array<Candle> candles, float l) =>
    helper.name := 'CandlesSetLow'
    float _l = l
    if array.size(candles) > 0
        for i = 0 to array.size(candles) - 1 by 1
            Candle c = array.get(candles, i)
            if c.l < _l
                _l := c.l
                _l
    _l

method CandlesHigh(Helper helper, array<Candle> candles) =>
    helper.name := 'CandlesHigh'
    h = 0.0
    int cnt = 0
    int last = helper.HTFEnabled()

    if htf1.settings.show and helper.ValidTimeframe(htf1.settings.htf)
        h := helper.CandleSetHigh(htf1.candles, h)
        cnt := cnt + 1
    if htf2.settings.show and helper.ValidTimeframe(htf2.settings.htf) and cnt < last
        h := helper.CandleSetHigh(htf2.candles, h)
        cnt := cnt + 1

    if array.size(candles) > 0
        for i = 0 to array.size(candles) - 1 by 1
            Candle c = array.get(candles, i)
            if c.h > h
                h := c.h
    h

method CandlesLow(Helper helper, array<Candle> candles, float h) =>
    helper.name := 'CandlesLow'
    l = h
    int cnt = 0
    int last = helper.HTFEnabled()

    if htf1.settings.show and helper.ValidTimeframe(htf1.settings.htf)
        l := helper.CandleSetLow(htf1.candles, l)
        cnt := cnt + 1
    if htf2.settings.show and helper.ValidTimeframe(htf2.settings.htf) and cnt < last
        l := helper.CandleSetLow(htf2.candles, l)
        cnt := cnt + 1

    if array.size(candles) > 0
        for i = 0 to array.size(candles) - 1 by 1
            Candle c = array.get(candles, i)
            if c.l < l
                l := c.l
    l

method UpdateTime(CandleSet candleSet, int offset) =>
    if settings.htf_timer_show and (barstate.isrealtime or barstate.islast)
        string tmr = '(' + helper.RemainingTime(candleSet.settings.htf) + ')'

        if not na(candleSet.tfTimerTop)
            candleSet.tfTimerTop.set_text(tmr)
    candleSet

// Removes every drawing of this set (used when a session stack resets)
method ClearAll(CandleSet candleSet) =>
    if candleSet.candles.size() > 0
        for i = 0 to candleSet.candles.size() - 1 by 1
            Candle c = candleSet.candles.get(i)
            box.delete(c.body)
            line.delete(c.wick_up)
            line.delete(c.wick_down)
            label.delete(c.timeLabel)
            line.delete(c.high_line)
            line.delete(c.low_line)
        candleSet.candles.clear()
    if candleSet.imbalances.size() > 0
        for i = 0 to candleSet.imbalances.size() - 1 by 1
            Imbalance imb = candleSet.imbalances.get(i)
            box.delete(imb.b)
        candleSet.imbalances.clear()
    label.delete(candleSet.tfNameTop)
    label.delete(candleSet.tfTimerTop)
    candleSet.tfNameTop := na
    candleSet.tfTimerTop := na
    candleSet

method Reorder(CandleSet candleSet, int offset) =>
    size = candleSet.candles.size()

    if size > 0
        for i = size - 1 to 0 by 1
            Candle candle = candleSet.candles.get(i)
            t_buffer = offset + (settings.width + settings.buffer) * (size - i - 1)
            box.set_left(candle.body, bar_index + t_buffer)
            box.set_right(candle.body, bar_index + settings.width + t_buffer)
            line.set_x1(candle.wick_up, bar_index + settings.width / 2 + t_buffer)
            line.set_x2(candle.wick_up, bar_index + settings.width / 2 + t_buffer)
            line.set_x1(candle.wick_down, bar_index + settings.width / 2 + t_buffer)
            line.set_x2(candle.wick_down, bar_index + settings.width / 2 + t_buffer)

            candleX = bar_index + settings.width / 2 + t_buffer

            if not na(candle.timeLabel)
                label.set_x(candle.timeLabel, candleX)
                label.set_y(candle.timeLabel, candle.l)

            nextX = candleX + settings.width + settings.buffer

            if not na(candle.high_line)
                line.set_x1(candle.high_line, candleX)
                line.set_x2(candle.high_line, nextX)
                line.set_y1(candle.high_line, candle.h)
                line.set_y2(candle.high_line, candle.h)

            if not na(candle.low_line)
                line.set_x1(candle.low_line, candleX)
                line.set_x2(candle.low_line, nextX)
                line.set_y1(candle.low_line, candle.l)
                line.set_y2(candle.low_line, candle.l)

    top = helper.CandlesHigh(candleSet.candles)
    bottom = helper.CandlesLow(candleSet.candles, top)

    left = bar_index + offset + (settings.width + settings.buffer) * (size - 1) / 2

    if settings.htf_label_show
        string lblt = helper.HTFName(candleSet.settings.htf)
        if settings.htf_timer_show
            lblt := lblt + '\n'

        string tmr = '(' + helper.RemainingTime(candleSet.settings.htf) + ')'

        if not na(candleSet.tfNameTop)
            candleSet.tfNameTop.set_xy(left, top)
        else
            candleSet.tfNameTop := label.new(left, top, lblt, color = color_transparent, textcolor = settings.htf_label_color, style = label.style_label_down, size = settings.htf_label_size)
        if settings.htf_timer_show
            if not na(candleSet.tfTimerTop)
                candleSet.tfTimerTop.set_xy(left, top)
            else
                candleSet.tfTimerTop := label.new(left, top, tmr, color = color_transparent, textcolor = settings.htf_timer_color, style = label.style_label_down, size = settings.htf_timer_size)

    candleSet

method FindImbalance(CandleSet candleSet) =>
    if barstate.isrealtime or barstate.islast
        if candleSet.imbalances.size() > 0
            for i = candleSet.imbalances.size() - 1 to 0 by 1
                Imbalance del = candleSet.imbalances.get(i)
                box.delete(del.b)
                candleSet.imbalances.pop()

        if candleSet.candles.size() > 3 and settings.fvg_show
            for i = 0 to candleSet.candles.size() - 3 by 1
                candle1 = candleSet.candles.get(i)
                candle2 = candleSet.candles.get(i + 2)
                candle3 = candleSet.candles.get(i + 1)

                if candle1.l > candle2.h and math.min(candle1.o, candle1.c) > math.max(candle2.o, candle2.c)
                    Imbalance imb = Imbalance.new()
                    imb.b := box.new(box.get_left(candle2.body), candle2.h, box.get_right(candle1.body), candle1.l, bgcolor = settings.fvg_bull_color, border_color = color_transparent, xloc = xloc.bar_index)
                    candleSet.imbalances.push(imb)
                if candle1.h < candle2.l and math.max(candle1.o, candle1.c) < math.min(candle2.o, candle2.c)
                    Imbalance imb = Imbalance.new()
                    imb.b := box.new(box.get_right(candle1.body), candle1.h, box.get_left(candle2.body), candle2.l, bgcolor = settings.fvg_bear_color, border_color = color_transparent)
                    candleSet.imbalances.push(imb)
                box temp = box.copy(candle3.body)
                box.delete(candle3.body)
                candle3.body := temp
                candle3.body
    candleSet

method CheckLiquiditySweeps(CandleSet candleSet) =>
    size = candleSet.candles.size()
    if settings.liq_show and size > 1
        for i = 1 to size - 1 by 1
            Candle c = candleSet.candles.get(i)
            if not na(c.high_line) and high >= c.h
                line.delete(c.high_line)
                c.high_line := na
            if not na(c.low_line) and low <= c.l
                line.delete(c.low_line)
                c.low_line := na
    candleSet

// "new HTF candle" is computed on every bar at global scope and passed in
method Monitor(CandleSet candleSet, bool isNewHTFCandle) =>
    if isNewHTFCandle
        Candle candle = Candle.new()
        candle.o := open
        candle.c := close
        candle.h := high
        candle.l := low
        candle.o_time := time
        candle.o_idx := bar_index
        candle.c_idx := bar_index
        candle.h_idx := bar_index
        candle.l_idx := bar_index
        bull = candle.c > candle.o

        candle.body := box.new(bar_index, math.max(candle.o, candle.c), bar_index + 2, math.min(candle.o, candle.c), bull ? settings.bull_border : settings.bear_border, 1, bgcolor = bull ? settings.bull_body : settings.bear_body)
        candle.wick_up := line.new(bar_index + 1, candle.h, bar_index, math.max(candle.o, candle.c), color = bull ? settings.bull_wick : settings.bear_wick)
        candle.wick_down := line.new(bar_index + 1, math.min(candle.o, candle.c), bar_index, candle.l, color = bull ? settings.bull_wick : settings.bear_wick)

        if settings.show_candle_time
            timeStr = helper.FormatTime(candle.o_time, settings.selectedTz)
            candle.timeLabel := label.new(x = bar_index, y = candle.l, text = timeStr, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_up, color = color_transparent, textcolor = settings.cand_time_color, size = settings.cand_time_size)

        if settings.liq_show
            lStyle = helper.GetLineStyle(settings.liq_style)
            candle.high_line := line.new(bar_index, candle.h, bar_index + 1, candle.h, color = settings.liq_color, width = settings.liq_width, style = lStyle)
            candle.low_line := line.new(bar_index, candle.l, bar_index + 1, candle.l, color = settings.liq_color, width = settings.liq_width, style = lStyle)

        candleSet.candles.unshift(candle)

        if candleSet.candles.size() > candleSet.settings.max_display
            Candle delCandle = array.pop(candleSet.candles)
            box.delete(delCandle.body)
            line.delete(delCandle.wick_up)
            line.delete(delCandle.wick_down)
            if not na(delCandle.timeLabel)
                label.delete(delCandle.timeLabel)
            if not na(delCandle.high_line)
                line.delete(delCandle.high_line)
            if not na(delCandle.low_line)
                line.delete(delCandle.low_line)

    candleSet

method Update(CandleSet candleSet, int offset) =>
    if candleSet.candles.size() > 0
        Candle candle = candleSet.candles.first()
        candle.h_idx := high > candle.h ? bar_index : candle.h_idx
        candle.h := high > candle.h ? high : candle.h
        candle.l_idx := low < candle.l ? bar_index : candle.l_idx
        candle.l := low < candle.l ? low : candle.l
        candle.c := close
        candle.c_idx := bar_index

        bull = candle.c > candle.o

        box.set_top(candle.body, candle.o)
        box.set_bottom(candle.body, candle.c)
        box.set_bgcolor(candle.body, bull ? settings.bull_body : settings.bear_body)
        box.set_border_color(candle.body, bull ? settings.bull_border : settings.bear_border)
        line.set_color(candle.wick_up, bull ? settings.bull_wick : settings.bear_wick)
        line.set_color(candle.wick_down, bull ? settings.bull_wick : settings.bear_wick)
        line.set_y1(candle.wick_up, candle.h)
        line.set_y2(candle.wick_up, math.max(candle.o, candle.c))
        line.set_y1(candle.wick_down, candle.l)
        line.set_y2(candle.wick_down, math.min(candle.o, candle.c))

        if not na(candle.timeLabel)
            label.set_y(candle.timeLabel, candle.l)

        if barstate.isrealtime or barstate.islast
            candleSet.Reorder(offset)
    candleSet

//+------------------------------------------------------------------------------------------------------------+//
//+--- Session Stack state - evaluated on every bar                                                         ---+//
//+------------------------------------------------------------------------------------------------------------+//

stackTime      = time(timeframe.period, stack_session, stack_tz)
stackDow       = dayofweek(time, stack_tz)
stackWeekendOK = stack_weekend or not (stackDow == dayofweek.saturday or stackDow == dayofweek.sunday)
inStackSess    = not na(stackTime) and stackWeekendOK
stackStart     = inStackSess and not inStackSess[1]
stackEnd       = inStackSess[1] and not inStackSess

// Keep Stacking: nothing is drawn before the first session start
var bool stackArmed = false
if stackStart
    stackArmed := true

bool stackLive = inStackSess or (stack_keep and stackArmed)

bool htf1_stack = stack_enable and stack_htf1
bool htf2_stack = stack_enable and stack_htf2

// New-HTF-candle detection (ta.change must run on every bar, so it lives at global scope)
bool htf1_chg = ta.change(time(htf1.settings.htf, 'america/New_York')) > 0
bool htf2_chg = ta.change(time(htf2.settings.htf, 'america/New_York')) > 0

// In stack mode the first bar of the session always opens a fresh candle
bool htf1_new = htf1_chg or (htf1_stack and stackStart)
bool htf2_new = htf2_chg or (htf2_stack and stackStart)

//+------------------------------------------------------------------------------------------------------------+//
//+--- Main                                                                                                 ---+//
//+------------------------------------------------------------------------------------------------------------+//

int cnt = 0
int last = helper.HTFEnabled()

int offset = settings.offset
if htf1.settings.show and helper.ValidTimeframe(htf1.settings.htf)
    htf1.UpdateTime(offset)
    if htf1_stack
        if stackStart or (stackEnd and not stack_keep)
            htf1.ClearAll()
        if stackLive
            htf1.Monitor(htf1_new).Update(offset).FindImbalance().CheckLiquiditySweeps()
    else
        htf1.Monitor(htf1_new).Update(offset).FindImbalance().CheckLiquiditySweeps()
    cnt := cnt + 1
    offset := offset + (cnt > 0 ? htf1.candles.size() * settings.width + (htf1.candles.size() > 0 ? (htf1.candles.size() - 1) * settings.buffer : 0) + settings.htf_buffer : 0)
    offset
if htf2.settings.show and helper.ValidTimeframe(htf2.settings.htf) and cnt < last
    htf2.UpdateTime(offset)
    if htf2_stack
        if stackStart or (stackEnd and not stack_keep)
            htf2.ClearAll()
        if stackLive
            htf2.Monitor(htf2_new).Update(offset).FindImbalance().CheckLiquiditySweeps()
    else
        htf2.Monitor(htf2_new).Update(offset).FindImbalance().CheckLiquiditySweeps()
````
