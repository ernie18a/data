# crt juan 2027

- url: https://www.tradingview.com/script/cISELU55/
- type: indicator
- pine_id: PUB;2942b7192959405d8d4d0ede5cefb243
- version: 1.0

## Description

//VARS
var int bullSignalIndex = 0
var int bearSignalIndex = 0

var line bullLine = na
var line bearLine = na

var line highLine = na
var line lowLine = na

## Source Code

````pine
//@version=5
indicator("CRT-Trader v7.2.1.C", overlay = true, max_bars_back = 500, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500)

tz_incr = input.int(-4, 'UTC (+/-)'  , group = '')
use_exchange = input(false, 'Use Exchange Timezone'  , group = '')
showSwing = input.bool(true,title="SWING", inline="s_1", group = '')
swingClr = input.color(color.new(color.purple, 0), title='', inline="s_1", group = '')
bool show90M = input.bool(true, "90M CRT", inline = "90m", group = "")
string NinetyMStyle = input.string("Dashed", options = ["Solid", "Dashed", "Dotted"], title = "Estilo", inline = "90m", group = "")
color NinetyMColor = input.color(color.new(color.red, 0), title = "Color", inline = "90m", group = "")
bool show90MEQ = input.bool(false, "Mostrar EQ", inline = "90m_eq", group = "")
bool alert90M = input.bool(true, "Alertas", inline = "90m_alert", group = "")
bool show6H = input.bool(true, "6H CRT", inline = "6h", group = "")
string SixHStyle = input.string("Dashed", options = ["Solid", "Dashed", "Dotted"], title = "Estilo", inline = "6h", group = "")
color SixHColor = input.color(color.new(color.blue, 0), title = "Color", inline = "6h", group = "")
bool show6HEQ = input.bool(false, "Mostrar EQ", inline = "6h_eq", group = "")
bool alert6H = input.bool(true, "Alertas", inline = "6h_alert", group = "")

show_indicatorVelasHTF = input(true, 'Velas HTF', group = '')

////////////////////////////////////////////////////////

//-------------------- ICT Velas HTF  ------------------

////////////////////////////////////////////////////////

type Candle
	float o
	float c
	float h
	float l
	int o_idx
	int c_idx
	int h_idx
	int l_idx
    string dow
	box body
	line wick_up
	line wick_down
    label dow_label

type Trace
	line o
	line c
	line h
	line l
	label o_l
	label c_l
	label h_l
	label l_l

type Imbalance
	box b
	int idx

type CandleSettings
	bool show
	string htf
	int max_display

type Settings
	int max_sets
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
	bool use_custom_daily
    string custom_daily
    bool daily_name
	bool trace_show
	color trace_o_color
	string trace_o_style
	int trace_o_size
	color trace_c_color
	string trace_c_style
	int trace_c_size
	color trace_h_color
	string trace_h_style
	int trace_h_size
	color trace_l_color
	string trace_l_style
	int trace_l_size
	string trace_anchor
	bool label_show
	color label_color
	string label_size
    string label_position
    string label_alignment
	bool fvg_show
	color fvg_color
	bool vi_show
	color vi_color
	bool htf_label_show
	color htf_label_color
	string htf_label_size
	bool htf_timer_show
	color htf_timer_color
	string htf_timer_size
    color dow_color
    string dow_size

type CandleSet
	array<Candle> candles
	array<Imbalance> imbalances
	CandleSettings settings
	label tfNameTop
    label tfNameBottom
	label tfTimerTop
    label tfTimerBottom

type Helper
	string name = 'Helper'

Settings settings = Settings.new()

var CandleSettings SettingsHTF3 = CandleSettings.new()
var CandleSettings SettingsHTF4 = CandleSettings.new()
var CandleSettings SettingsHTF5 = CandleSettings.new()
var CandleSettings SettingsHTF6 = CandleSettings.new()
var CandleSettings SettingsHTF7 = CandleSettings.new()
var CandleSettings SettingsHTF8 = CandleSettings.new()
var CandleSettings SettingsHTF9 = CandleSettings.new()

var array<Candle> candles_3 = array.new<Candle>(0)
var array<Candle> candles_4 = array.new<Candle>(0)
var array<Candle> candles_5 = array.new<Candle>(0)
var array<Candle> candles_6 = array.new<Candle>(0)
var array<Candle> candles_7 = array.new<Candle>(0)
var array<Candle> candles_8 = array.new<Candle>(0)
var array<Candle> candles_9 = array.new<Candle>(0)

var array<Imbalance> imbalances_3 = array.new<Imbalance>()
var array<Imbalance> imbalances_4 = array.new<Imbalance>()
var array<Imbalance> imbalances_5 = array.new<Imbalance>()
var array<Imbalance> imbalances_6 = array.new<Imbalance>()
var array<Imbalance> imbalances_7 = array.new<Imbalance>()
var array<Imbalance> imbalances_8 = array.new<Imbalance>()
var array<Imbalance> imbalances_9 = array.new<Imbalance>()

var CandleSet htf3 = CandleSet.new()
htf3.settings := SettingsHTF3
htf3.candles := candles_3
htf3.imbalances := imbalances_3

var CandleSet htf4 = CandleSet.new()
htf4.settings := SettingsHTF4
htf4.candles := candles_4
htf4.imbalances := imbalances_4

var CandleSet htf5 = CandleSet.new()
htf5.settings := SettingsHTF5
htf5.candles := candles_5
htf5.imbalances := imbalances_5

var CandleSet htf6 = CandleSet.new()
htf6.settings := SettingsHTF6
htf6.candles := candles_6
htf6.imbalances := imbalances_6

var CandleSet htf7 = CandleSet.new()
htf7.settings := SettingsHTF7
htf7.candles := candles_7
htf7.imbalances := imbalances_7

var CandleSet htf8 = CandleSet.new()
htf8.settings := SettingsHTF8
htf8.candles := candles_8
htf8.imbalances := imbalances_8

var CandleSet htf9 = CandleSet.new()
htf9.settings := SettingsHTF9
htf9.candles := candles_9
htf9.imbalances := imbalances_9

//+------------------------------------------------------------------------------------------------------------+//
//+--- Settings                                                                                             ---+//
//+------------------------------------------------------------------------------------------------------------+//

string group_style              = "Styling  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
string group_label              = "Label Settings  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
string group_imbalance          = "Imbalance  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
string group_trace              = "Trace  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"


htf3.settings.show              := input.bool(true, 'HTF 3      ', inline = 'htf3')
htf_3                           = input.timeframe('90', '', inline = 'htf3')
htf3.settings.htf := htf_3
htf3.settings.max_display       := input.int(6, '', inline = 'htf3')

htf4.settings.show              := input.bool(true, 'HTF 4      ', inline = 'htf4')
htf_4                           = input.timeframe('360', '', inline = 'htf4')
htf4.settings.htf               := htf_4
htf4.settings.max_display       := input.int(6, '', inline = 'htf4')

htf5.settings.show              := input.bool(false, 'HTF 5      ', inline = 'htf5')
htf_5                           = input.timeframe('480', '', inline = 'htf5')
htf5.settings.htf := htf_5
htf5.settings.max_display       := input.int(6, '', inline = 'htf5')

htf6.settings.show              := input.bool(false, 'HTF 6      ', inline = 'htf6')
htf_6                           = input.timeframe('720', '', inline = 'htf6')
htf6.settings.htf               := htf_6
htf6.settings.max_display       := input.int(6, '', inline = 'htf6')

htf7.settings.show              := input.bool(false, 'HTF7      ', inline = 'htf7')
htf_7                           = input.timeframe('1D', '', inline = 'htf7')
htf7.settings.htf               := htf_7
htf7.settings.max_display       := input.int(1, '', inline = 'htf7')

htf8.settings.show              := input.bool(false, 'HTF 8      ', inline = 'htf8')
htf_8                           = input.timeframe('1W', '', inline = 'htf8')
htf8.settings.htf               := htf_8
htf8.settings.max_display       := input.int(1, '', inline = 'htf8')

htf9.settings.show              := input.bool(false, 'HTF 9      ', inline = 'htf9')
htf_9                           = input.timeframe('1M', '', inline = 'htf9')
htf9.settings.htf               := htf_9
htf9.settings.max_display       := input.int(1, '', inline = 'htf9')


settings.max_sets               := input.int(10, 'Limit to next HTFs only', minval = 1, maxval = 10)
settings.use_custom_daily       := input.bool(false, 'Custom daily candle open     ', inline='customdaily')
settings.custom_daily           := input.string('Midnight', '', options=['Midnight', '8:30', '9:30'], inline='customdaily')
settings.bull_body              := input.color(#089981, 'Body  ', inline = 'body', group=group_style)
settings.bear_body              := input.color(color.new(color.black, 0), '', inline = 'body', group=group_style)
settings.bull_border            := input.color(color.new(color.black, 100), 'Borders', inline = 'borders', group=group_style)
settings.bear_border            := input.color(color.new(color.black, 100), '', inline = 'borders', group=group_style)
settings.bull_wick              := input.color(color.new(color.black, 0), 'Wick  ', inline = 'wick', group=group_style)
settings.bear_wick              := input.color(color.new(color.black, 0), '', inline = 'wick', group=group_style)

settings.offset                 := input.int(30, 'padding from current candles', minval = 1, group=group_style)
settings.buffer                 := input.int(1, 'space between candles', minval = 1, maxval = 4, group=group_style)
settings.htf_buffer             := input.int(10, 'space between Higher Timeframes', minval = 1, maxval = 10, group=group_style)
settings.width                  := input.int(1, 'Candle Width', minval = 1, maxval = 4, group=group_style) * 2

settings.htf_label_show         := input.bool(true, 'HTF Label           ', group=group_label, inline = 'HTFlabel')
settings.htf_label_color        := input.color(color.new(color.black, 0), '', group=group_label, inline = 'HTFlabel')
settings.htf_label_size         := input.string(size.large, '', [size.tiny, size.small, size.normal, size.large, size.huge], group=group_label, inline = 'HTFlabel')

settings.label_position         := input.string("Both", 'Label Positions', options=['Both', 'Top', 'Bottom'], group=group_label)
settings.label_alignment        := input.string("Align", "Label Alignment", options=['Align', 'Follow Candles'], group=group_label)

settings.htf_timer_show         := input.bool(true, 'Remaining time      ', inline = 'timer', group=group_label)
settings.htf_timer_color        := input.color(color.new(color.black, 0), '', inline = 'timer', group=group_label)
settings.htf_timer_size         := input.string(size.small, '', [size.tiny, size.small, size.normal, size.large, size.huge], group=group_label, inline = 'timer')

settings.daily_name             := input.bool(false, 'Day of week         ', group=group_label, inline = 'dow')
settings.dow_color              := input.color(color.black , '', group=group_label, inline = 'dow')
settings.dow_size               := input.string(size.small, '', [size.tiny, size.small, size.normal, size.large, size.huge], group=group_label, inline = 'dow')

settings.fvg_show               := input.bool(true, 'Fair Value Gap   ', group = group_imbalance, inline = 'fvg')
settings.fvg_color              := input.color(color.new(color.olive, 60), '', inline = 'fvg', group = group_imbalance)

settings.vi_show                := input.bool(false, 'Volume Imbalance', group = group_imbalance, inline = 'vi')
settings.vi_color               := input.color(color.new(color.red, 50), '', inline = 'vi', group = group_imbalance)

settings.trace_show             := input.bool(false, 'Trace lines', group = group_trace)
settings.trace_o_color          := input.color(color.new(color.gray, 50), 'Open    ', inline = '1', group = group_trace)
settings.trace_o_style          := input.string('····', '', options = ['⎯⎯⎯', '----', '····'], inline = '1', group = group_trace)
settings.trace_o_size           := input.int(1, '', options = [1, 2, 3, 4], inline = '1', group = group_trace)
settings.trace_c_color          := input.color(color.new(color.gray, 50), 'Close    ', inline = '2', group = group_trace)
settings.trace_c_style          := input.string('····', '', options = ['⎯⎯⎯', '----', '····'], inline = '2', group = group_trace)
settings.trace_c_size           := input.int(1, '', options = [1, 2, 3, 4], inline = '2', group = group_trace)
settings.trace_h_color          := input.color(color.new(color.gray, 50), 'High     ', inline = '3', group = group_trace)
settings.trace_h_style          := input.string('····', '', options = ['⎯⎯⎯', '----', '····'], inline = '3', group = group_trace)
settings.trace_h_size           := input.int(1, '', options = [1, 2, 3, 4], inline = '3', group = group_trace)
settings.trace_l_color          := input.color(color.new(color.gray, 50), 'Low     ', inline = '4', group = group_trace)
settings.trace_l_style          := input.string('····', '', options = ['⎯⎯⎯', '----', '····'], inline = '4', group = group_trace)
settings.trace_l_size           := input.int(1, '', options = [1, 2, 3, 4], inline = '4', group = group_trace)
settings.trace_anchor           := input.string('First Timeframe', 'Anchor to', options = ['First Timeframe', 'Last Timeframe'], group = group_trace)

settings.label_show             := input.bool(true, 'Price Label           ', inline = 'label')
settings.label_color            := input.color(color.new(color.black, 0), '', inline = 'label')
settings.label_size             := input.string(size.small, '', [size.tiny, size.small, size.normal, size.large, size.huge], inline = 'label')

//+------------------------------------------------------------------------------------------------------------+//
//+--- Variables                                                                                            ---+//
//+------------------------------------------------------------------------------------------------------------+//

Helper helper = Helper.new()
var Trace trace = Trace.new()
color color_transparent = #ffffff00

//+------------------------------------------------------------------------------------------------------------+//
//+--- Internal Functions                                                                                   ---+//
//+------------------------------------------------------------------------------------------------------------+//

method LineStyle(Helper helper, string style) =>
    helper.name := style
    out = switch style
        '----' => line.style_dashed
        '····' => line.style_dotted
        => line.style_solid
    out

method DayofWeek(Helper helper, int index) =>
    helper.name := 'DOW'
    switch
        index == 1 => 'M'
        index == 2 => 'T'
        index == 3 => 'W'
        index == 4 => 'T'
        index == 5 => 'F'
        index == 6 => 'S'
        index == 7 => 'S'
        na(index) => ''

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
    enabled := enabled + (htf3.settings.show ? 1 : 0)
    enabled := enabled + (htf4.settings.show ? 1 : 0)
    enabled := enabled + (htf5.settings.show ? 1 : 0)
    enabled := enabled + (htf6.settings.show ? 1 : 0)
    enabled := enabled + (htf7.settings.show ? 1 : 0)
    enabled := enabled + (htf8.settings.show ? 1 : 0)
    enabled := enabled + (htf9.settings.show ? 1 : 0)
    int last = math.min(enabled, settings.max_sets)

    last

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

    if htf3.settings.show and helper.ValidTimeframe(htf3.settings.htf) and cnt < last
        h := helper.CandleSetHigh(htf3.candles, h)
        cnt := cnt + 1
    if htf4.settings.show and helper.ValidTimeframe(htf4.settings.htf) and cnt < last
        h := helper.CandleSetHigh(htf4.candles, h)
        cnt := cnt + 1
    if htf5.settings.show and helper.ValidTimeframe(htf5.settings.htf) and cnt < last
        h := helper.CandleSetHigh(htf5.candles, h)
        cnt := cnt + 1
    if htf6.settings.show and helper.ValidTimeframe(htf6.settings.htf) and cnt < last
        h := helper.CandleSetHigh(htf6.candles, h)
        cnt := cnt + 1
    if htf7.settings.show and helper.ValidTimeframe(htf7.settings.htf) and cnt < last
        h := helper.CandleSetHigh(htf7.candles, h)
        cnt := cnt + 1
    if htf8.settings.show and helper.ValidTimeframe(htf8.settings.htf) and cnt < last
        h := helper.CandleSetHigh(htf8.candles, h)
        cnt := cnt + 1
    if htf9.settings.show and helper.ValidTimeframe(htf9.settings.htf) and cnt < last
        h := helper.CandleSetHigh(htf9.candles, h)
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

    if htf3.settings.show and helper.ValidTimeframe(htf3.settings.htf) and cnt < last
        l := helper.CandleSetLow(htf3.candles, l)
        cnt := cnt + 1
    if htf4.settings.show and helper.ValidTimeframe(htf4.settings.htf) and cnt < last
        l := helper.CandleSetLow(htf4.candles, l)
        cnt := cnt + 1
    if htf5.settings.show and helper.ValidTimeframe(htf5.settings.htf) and cnt < last
        l := helper.CandleSetLow(htf5.candles, l)
        cnt := cnt + 1
    if htf6.settings.show and helper.ValidTimeframe(htf6.settings.htf) and cnt < last
        l := helper.CandleSetLow(htf6.candles, l)
        cnt := cnt + 1
    if htf7.settings.show and helper.ValidTimeframe(htf7.settings.htf) and cnt < last
        l := helper.CandleSetLow(htf7.candles, l)
        cnt := cnt + 1
    if htf8.settings.show and helper.ValidTimeframe(htf8.settings.htf) and cnt < last
        l := helper.CandleSetLow(htf8.candles, l)
        cnt := cnt + 1
    if htf9.settings.show and helper.ValidTimeframe(htf9.settings.htf) and cnt < last
        l := helper.CandleSetLow(htf9.candles, l)
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

        if not na(candleSet.tfTimerBottom)
            candleSet.tfTimerBottom.set_text(tmr)
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

            if settings.daily_name and candleSet.settings.htf == '1D'
                if not na(candle.dow_label)
                    candle.dow_label.set_y(candle.h)
                    candle.dow_label.set_x(bar_index + settings.width / 2 + t_buffer)
                    candle.dow_label.set_text(candle.dow)
                else
                    candle.dow_label := label.new(bar_index + settings.width / 2 + t_buffer, candle.h, candle.dow, color = color_transparent, textcolor = settings.dow_color, style = label.style_label_down, size = settings.dow_size)

    top = 0.0
    bottom = 0.0

    if settings.label_alignment == 'Align'
        top := helper.CandlesHigh(candleSet.candles)
        bottom := helper.CandlesLow(candleSet.candles, top)
    if settings.label_alignment == 'Follow Candles'
        top := helper.CandleSetHigh(candleSet.candles, 0)
        bottom := helper.CandleSetLow(candleSet.candles, top)

    left = bar_index + offset + (settings.width + settings.buffer) * (size - 1) / 2

    if settings.htf_label_show
        string lblt = helper.HTFName(candleSet.settings.htf)
        string lbll = lblt
        if settings.htf_timer_show
            lblt := lblt + '\n'
            lbll := '\n' + lbll

        string tmr = '(' + helper.RemainingTime(candleSet.settings.htf) + ')'
        if settings.label_position == 'Both' or settings.label_position == 'Top'
            
            if not na(candleSet.tfNameTop)
                candleSet.tfNameTop.set_xy(left, top)
            else
                candleSet.tfNameTop := label.new(left, top, lblt, color = color_transparent, textcolor = settings.htf_label_color, style = label.style_label_down, size = settings.htf_label_size)

            if not na(candleSet.tfTimerTop)
                candleSet.tfTimerTop.set_xy(left, top)
            else
                candleSet.tfTimerTop := label.new(left, top, tmr, color = color_transparent, textcolor = settings.htf_timer_color, style = label.style_label_down, size = settings.htf_timer_size)

        if settings.label_position == 'Both' or settings.label_position == 'Bottom'
            if not na(candleSet.tfNameBottom)
                candleSet.tfNameBottom.set_xy(left, bottom)
            else
                candleSet.tfNameBottom := label.new(left, bottom, lbll, color = color_transparent, textcolor = settings.htf_label_color, style = label.style_label_up, size = settings.htf_label_size)

            if not na(candleSet.tfTimerBottom)
                candleSet.tfTimerBottom.set_xy(left, bottom)
            else
                candleSet.tfTimerBottom := label.new(left, bottom, tmr, color = color_transparent, textcolor = settings.htf_timer_color, style = label.style_label_up, size = settings.htf_timer_size)

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
                    imb.b := box.new(box.get_left(candle2.body), candle2.h, box.get_right(candle1.body), candle1.l, bgcolor = settings.fvg_color, border_color = color_transparent, xloc = xloc.bar_index)
                    candleSet.imbalances.push(imb)
                if candle1.h < candle2.l and math.max(candle1.o, candle1.c) < math.min(candle2.o, candle2.c)
                    Imbalance imb = Imbalance.new()
                    imb.b := box.new(box.get_right(candle1.body), candle1.h, box.get_left(candle2.body), candle2.l, bgcolor = settings.fvg_color, border_color = color_transparent)
                    candleSet.imbalances.push(imb)
                box temp = box.copy(candle3.body)
                box.delete(candle3.body)
                candle3.body := temp
                candle3.body

        if candleSet.candles.size() > 2 and settings.vi_show
            for i = 0 to candleSet.candles.size() - 2 by 1
                candle1 = candleSet.candles.get(i)
                candle2 = candleSet.candles.get(i + 1)
                if candle1.l < candle2.h and math.min(candle1.o, candle1.c) > math.max(candle2.o, candle2.c)
                    Imbalance imb = Imbalance.new()
                    imb.b := box.new(box.get_left(candle2.body), math.min(candle1.o, candle1.c), box.get_right(candle1.body), math.max(candle2.o, candle2.c), bgcolor = settings.vi_color, border_color = color_transparent)
                    candleSet.imbalances.push(imb)
                if candle1.h > candle2.l and math.max(candle1.o, candle1.c) < math.min(candle2.o, candle2.c)
                    Imbalance imb = Imbalance.new()
                    imb.b := box.new(box.get_right(candle1.body), math.min(candle2.o, candle2.c), box.get_left(candle2.body), math.max(candle1.o, candle1.c), bgcolor = settings.vi_color, border_color = color_transparent)
                    candleSet.imbalances.push(imb)
    candleSet

method Monitor(CandleSet candleSet) =>
    HTFBarTime = time(candleSet.settings.htf)
    isNewHTFCandle = ta.change(HTFBarTime) > 0

    if settings.use_custom_daily
        int _830 = 0
        if isNewHTFCandle
            _830 := timestamp("America/New_York", year(time), month(time), dayofmonth(time), 0, 0) + 30600000
        if candleSet.settings.htf == '1D'
            if settings.custom_daily == 'Midnight'
                isNewHTFCandle := dayofweek(time, 'America/New_York') != dayofweek(time - (time - time[1]), 'America/New_York')
            if settings.custom_daily == '8:30'    
                // Get 8:30 AM New York time for today 
                isNewHTFCandle := not na(time(timeframe.period, "0830-0831:123456", 'America/New_York')) and na(time(timeframe.period, "0830-0831:123456", 'America/New_York')[1])
            if settings.custom_daily == '9:30'    
                // Get 9:30 AM New York time for today 
                isNewHTFCandle := not na(time(timeframe.period, "0930-0931:123456", 'America/New_York')) and na(time(timeframe.period, "0930-0931:123456", 'America/New_York')[1])
    if isNewHTFCandle
        Candle candle = Candle.new()
        candle.o := open
        candle.c := close
        candle.h := high
        candle.l := low
        candle.o_idx := bar_index
        candle.c_idx := bar_index
        candle.h_idx := bar_index
        candle.l_idx := bar_index
        candle.dow := helper.DayofWeek(dayofweek(time_tradingday, "America/New_York"))

        bull = candle.c > candle.o

        candle.body := box.new(bar_index, math.max(candle.o, candle.c), bar_index + 2, math.min(candle.o, candle.c), bull ? settings.bull_border : settings.bear_border, 1, bgcolor = bull ? settings.bull_body : settings.bear_body)
        candle.wick_up := line.new(bar_index + 1, candle.h, bar_index, math.max(candle.o, candle.c), color = bull ? settings.bull_wick : settings.bear_wick)
        candle.wick_down := line.new(bar_index + 1, math.min(candle.o, candle.c), bar_index, candle.l, color = bull ? settings.bull_wick : settings.bear_wick)

        candleSet.candles.unshift(candle)

        if candleSet.candles.size() > candleSet.settings.max_display
            Candle delCandle = array.pop(candleSet.candles)
            box.delete(delCandle.body)
            line.delete(delCandle.wick_up)
            line.delete(delCandle.wick_down)

    candleSet

method Update(CandleSet candleSet, int offset, bool showTrace) =>
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

        if barstate.isrealtime or barstate.islast
            candleSet.Reorder(offset)
            if settings.trace_show and showTrace
                if bar_index - candle.o_idx < 5000
                    if na(trace.o)
                        trace.o := line.new(candle.o_idx, candle.o, box.get_left(candle.body), candle.o, xloc = xloc.bar_index, color = settings.trace_o_color, style = helper.LineStyle(settings.trace_o_style), width = settings.trace_o_size)
                        trace.o
                    else
                        line.set_xy1(trace.o, candle.o_idx, candle.o)
                        line.set_xy2(trace.o, box.get_left(candle.body), candle.o)

                    if settings.label_show
                        if na(trace.o_l)
                            trace.o_l := label.new(box.get_right(candle.body), candle.o, str.tostring(candle.o), textalign = text.align_center, style = label.style_label_left, size = settings.label_size, color = color_transparent, textcolor = settings.label_color)
                            trace.o_l
                        else
                            label.set_xy(trace.o_l, box.get_right(candle.body), candle.o)
                            label.set_text(trace.o_l, str.tostring(candle.o))

                if bar_index - candle.c_idx < 5000
                    if na(trace.c)
                        trace.c := line.new(candle.c_idx, candle.c, box.get_left(candle.body), candle.c, xloc = xloc.bar_index, color = settings.trace_c_color, style = helper.LineStyle(settings.trace_c_style), width = settings.trace_c_size)
                        trace.c
                    else
                        line.set_xy1(trace.c, candle.c_idx, candle.c)
                        line.set_xy2(trace.c, box.get_left(candle.body), candle.c)

                    if settings.label_show
                        if na(trace.c_l)
                            trace.c_l := label.new(box.get_right(candle.body), candle.c, str.tostring(candle.c), textalign = text.align_center, style = label.style_label_left, size = settings.label_size, color = color_transparent, textcolor = settings.label_color)
                            trace.c_l
                        else
                            label.set_xy(trace.c_l, box.get_right(candle.body), candle.c)
                            label.set_text(trace.c_l, str.tostring(candle.c))

                if bar_index - candle.h_idx < 5000
                    if na(trace.h)
                        trace.h := line.new(candle.h_idx, candle.h, line.get_x1(candle.wick_up), candle.h, xloc = xloc.bar_index, color = settings.trace_h_color, style = helper.LineStyle(settings.trace_h_style), width = settings.trace_h_size)
                        trace.h
                    else
                        line.set_xy1(trace.h, candle.h_idx, candle.h)
                        line.set_xy2(trace.h, line.get_x1(candle.wick_up), candle.h)

                    if settings.label_show
                        if na(trace.h_l)
                            trace.h_l := label.new(box.get_right(candle.body), candle.h, str.tostring(candle.h), textalign = text.align_center, style = label.style_label_left, size = settings.label_size, color = color_transparent, textcolor = settings.label_color)
                            trace.h_l
                        else
                            label.set_xy(trace.h_l, box.get_right(candle.body), candle.h)
                            label.set_text(trace.h_l, str.tostring(candle.h))

                if bar_index - candle.l_idx < 5000
                    if na(trace.l)
                        trace.l := line.new(candle.l_idx, candle.l, line.get_x1(candle.wick_down), candle.l, xloc = xloc.bar_index, color = settings.trace_l_color, style = helper.LineStyle(settings.trace_l_style), width = settings.trace_l_size)
                        trace.l
                    else
                        line.set_xy1(trace.l, candle.l_idx, candle.l)
                        line.set_xy2(trace.l, line.get_x1(candle.wick_down), candle.l)

                    if settings.label_show
                        if na(trace.l_l)
                            trace.l_l := label.new(box.get_right(candle.body), candle.l, str.tostring(candle.l), textalign = text.align_center, style = label.style_label_left, size = settings.label_size, color = color_transparent, textcolor = settings.label_color)
                            trace.l_l
                        else
                            label.set_xy(trace.l_l, box.get_right(candle.body), candle.l)
                            label.set_text(trace.l_l, str.tostring(candle.l))
    candleSet


int cnt = 0
int last = helper.HTFEnabled()

int offset = settings.offset
if show_indicatorVelasHTF
    if htf3.settings.show and helper.ValidTimeframe(htf3.settings.htf) and cnt < last
        bool showTrace = false
        if settings.trace_anchor == 'First Timeframe' and cnt == 0
            showTrace := true
            showTrace
        if settings.trace_anchor == 'Last Timeframe' and cnt == last - 1
            showTrace := true
            showTrace
        htf3.UpdateTime(offset)
        htf3.Monitor().Update(offset, showTrace).FindImbalance()
        cnt := cnt + 1
        offset := offset + (cnt > 0 ? htf3.candles.size() * settings.width + (htf3.candles.size() > 0 ? (htf3.candles.size() - 1) * settings.buffer : 0) + settings.htf_buffer : 0)
        offset
    if htf4.settings.show and helper.ValidTimeframe(htf4.settings.htf) and cnt < last
        bool showTrace = false
        if settings.trace_anchor == 'First Timeframe' and cnt == 0
            showTrace := true
            showTrace
        if settings.trace_anchor == 'Last Timeframe' and cnt == last - 1
            showTrace := true
            showTrace
        htf4.UpdateTime(offset)
        htf4.Monitor().Update(offset, showTrace).FindImbalance()
        cnt := cnt + 1
        offset := offset + (cnt > 0 ? htf4.candles.size() * settings.width + (htf4.candles.size() > 0 ? (htf4.candles.size() - 1) * settings.buffer : 0) + settings.htf_buffer : 0)
        offset
    if htf5.settings.show and helper.ValidTimeframe(htf5.settings.htf) and cnt < last
        bool showTrace = false
        if settings.trace_anchor == 'First Timeframe' and cnt == 0
            showTrace := true
            showTrace
        if settings.trace_anchor == 'Last Timeframe' and cnt == last - 1
            showTrace := true
            showTrace
        htf5.UpdateTime(offset)
        htf5.Monitor().Update(offset, showTrace).FindImbalance()
        cnt := cnt + 1
        offset := offset + (cnt > 0 ? htf5.candles.size() * settings.width + (htf5.candles.size() > 0 ? (htf5.candles.size() - 1) * settings.buffer : 0) + settings.htf_buffer : 0)
        offset
    if htf6.settings.show and helper.ValidTimeframe(htf6.settings.htf) and cnt < last
        bool showTrace = false
        if settings.trace_anchor == 'First Timeframe' and cnt == 0
            showTrace := true
            showTrace
        if settings.trace_anchor == 'Last Timeframe'
            showTrace := true
            showTrace
        htf6.UpdateTime(offset)
        htf6.Monitor().Update(offset, showTrace).FindImbalance()
        cnt := cnt + 1
        offset := offset + (cnt > 0 ? htf6.candles.size() * settings.width + (htf5.candles.size() > 0 ? (htf5.candles.size() - 1) * settings.buffer : 0) + settings.htf_buffer : 0)
        offset
    if htf7.settings.show and helper.ValidTimeframe(htf7.settings.htf) and cnt < last
        bool showTrace = false
        if settings.trace_anchor == 'First Timeframe' and cnt == 0
            showTrace := true
            showTrace
        if settings.trace_anchor == 'Last Timeframe' and cnt == last - 1
            showTrace := true
            showTrace
        htf7.UpdateTime(offset)
        htf7.Monitor().Update(offset, showTrace).FindImbalance()
        cnt := cnt + 1
        offset := offset + (cnt > 0 ? htf7.candles.size() * settings.width + (htf7.candles.size() > 0 ? (htf7.candles.size() - 1) * settings.buffer : 0) + settings.htf_buffer : 0)
        offset
    if htf8.settings.show and helper.ValidTimeframe(htf8.settings.htf) and cnt < last
        bool showTrace = false
        if settings.trace_anchor == 'First Timeframe' and cnt == 0
            showTrace := true
            showTrace
        if settings.trace_anchor == 'Last Timeframe' and cnt == last - 1
            showTrace := true
            showTrace
        htf8.UpdateTime(offset)
        htf8.Monitor().Update(offset, showTrace).FindImbalance()
        cnt := cnt + 1
        offset := offset + (cnt > 0 ? htf8.candles.size() * settings.width + (htf8.candles.size() > 0 ? (htf8.candles.size() - 1) * settings.buffer : 0) + settings.htf_buffer : 0)
        offset
    if htf9.settings.show and helper.ValidTimeframe(htf9.settings.htf) and cnt < last
        bool showTrace = false
        if settings.trace_anchor == 'First Timeframe' and cnt == 0
            showTrace := true
            showTrace
        if settings.trace_anchor == 'Last Timeframe' and cnt == last - 1
            showTrace := true
            showTrace
        htf9.UpdateTime(offset)
        htf9.Monitor().Update(offset, showTrace).FindImbalance()
        cnt := cnt + 1
        offset := offset + (cnt > 0 ? htf9.candles.size() * settings.width + (htf9.candles.size() > 0 ? (htf9.candles.size() - 1) * settings.buffer : 0) + settings.htf_buffer : 0)
        offset

//////////////////////////////////////////////////////

//-------------- ------//FVG-BPR/---- -------------//

//////////////////////////////////////////////////////



bullfvg = input.color(defval=color.new(color.teal,25), title='Bull FVG')
bearfvg = input.color(defval=color.new(color.maroon,25), title='Bear FVG')
style = input.string(line.style_solid, 'Line Style', options=[line.style_solid, line.style_dotted, line.style_dashed])
width = input.int(1, 'Line Width', minval=0)
lookback = input.int(defval=50, title='Bars to look back')
mit = input.string(defval="full fill high/low", title = "Mitigation Type", options = ["full fill high/low","full fill open/close","half fill high/low","half fill open/close","no mitigation"], tooltip="Defines when an FVG will be mitigated and not used/displayed. This can be when full or half filled, by a high/low value or open/close value. When using no mitigation the nearest FVG will be shown always.")
gap = input.float(defval = 0.0, minval = 0.0, title = "Minimum Price Gap of FVGs", tooltip = "When the price gap for an FVG is less than this, it will not be used in the nearest selection", step=0.1)
bprs = input.bool(defval=true, title='Show when nearest FVGs create a BPR ▼', tooltip="BPR refers to balanced price range, and an overlapped bull/bear FVG pair.")

//Convert a given string resolution into seconds
ResolutionToSec(res)=>
    mins = res == "1S" ? 17 : 
           res == "5S" ? 83 : 
           res == "10S" ? 167 : 
           res == "15S" ? 250 : 
           res == "30S" ? 500 : 
           res == "1" ? 1000 :
           res == "3" ? 3000 :
           res == "5" ? 5000 :
           res == "10" ? 10000 :
           res == "15" ? 15000 :
           res == "30" ? 30000 :
           res == "45" ? 45000 :
           res == "60" ? 60000 :
           res == "120" ? 120000 :
           res == "180" ? 180000 :
           res == "240" ? 240000 :
           res == "D" or res == "1D" ? 1440000 :
           res == "W" or res == "1W" ? 10080000 :
           res == "M" or res == "1M" ? 43200000 :
           res == "" ? int(str.tonumber(timeframe.period))*1000 : int(str.tonumber(res))*1000
    ms = mins * 60 

bar = ResolutionToSec(timeframe.period) 

//addition = ResolutionToSec(timeframe == "" ? timeframe.period : timeframe)

var n = 0
var m = 0
var bullmit = false
var bearmit = false
var float bullhigh = na
var float bearlow = na
var float prevnearbull = high
var float prevnearbear = high
var line bullhighline = na
var line bearhighline = na
var line bulllowline = na
var line bearlowline = na
var label bearbpr = na
var label bullbpr = na

var bullfvghight = array.new_int()
var bullfvglowt= array.new_int()
var bearfvghight = array.new_int()
var bearfvglowt = array.new_int()

var bullfvghighttemp = array.new_int()
var bullfvglowttemp= array.new_int()
var bearfvghighttemp = array.new_int()
var bearfvglowttemp = array.new_int()
//array.copy
var bullfvghigh = array.new_float()
var bullfvglow = array.new_float()
var bearfvghigh = array.new_float()
var bearfvglow = array.new_float()

var bullfvghightemp = array.new_float()
var bullfvglowtemp = array.new_float()
var bearfvghightemp = array.new_float()
var bearfvglowtemp = array.new_float()
   
nearest(prev, curr, target) =>
    if (math.abs(prev-target) < math.abs(curr-target))
        prev
    else    
        curr

arrayadd(n, arr1, arr2) =>
    array.push(arr2, array.get(arr1, n))

if (high[2] < low and (math.abs(high[2] - low) / high[2]) * 100 > gap)
    array.push(bullfvghigh, high[2])
    array.push(bullfvglow, low)
    array.push(bullfvghight, time[2])
    array.push(bullfvglowt, time)
    
if (array.size((bullfvglow)) > 0)
    
    for x = array.size((bullfvglow))-1 to 0
        
        if (mit == "full fill high/low")
            if (not(low <= array.get(bullfvghigh, x)) and array.get(bullfvghight, x) >= time - lookback*(bar+2))
                arrayadd(x, bullfvghigh, bullfvghightemp)
                arrayadd(x, bullfvghight, bullfvghighttemp)
                arrayadd(x, bullfvglow, bullfvglowtemp)
                arrayadd(x, bullfvglowt, bullfvglowttemp)
        if (mit == "half fill high/low")
            if (not(low <= array.get(bullfvglow, x)-(array.get(bullfvglow, x)-array.get(bullfvghigh, x))/2) and array.get(bullfvghight, x) >= time - lookback*(bar+2))
                arrayadd(x, bullfvghigh, bullfvghightemp)
                arrayadd(x, bullfvghight, bullfvghighttemp)
                arrayadd(x, bullfvglow, bullfvglowtemp)
                arrayadd(x, bullfvglowt, bullfvglowttemp)
        if (mit == "full fill open/close")
            if ((close<open ? close : open) >= array.get(bullfvghigh, x) and array.get(bullfvghight, x) >= time - lookback*(bar+2))
                arrayadd(x, bullfvghigh, bullfvghightemp)
                arrayadd(x, bullfvghight, bullfvghighttemp)
                arrayadd(x, bullfvglow, bullfvglowtemp)
                arrayadd(x, bullfvglowt, bullfvglowttemp)
        if (mit == "half fill open/close")
            if ((close<open ? close : open) >= array.get(bullfvglow, x)-(array.get(bullfvglow, x)-array.get(bullfvghigh, x))/2) and array.get(bullfvghight, x) >= time - lookback*(bar+2)
                arrayadd(x, bullfvghigh, bullfvghightemp)
                arrayadd(x, bullfvghight, bullfvghighttemp)
                arrayadd(x, bullfvglow, bullfvglowtemp)
                arrayadd(x, bullfvglowt, bullfvglowttemp)
        if (mit == "no mitigation")
            if (array.get(bullfvghight, x) >= time - lookback*(bar+2))
                arrayadd(x, bullfvghigh, bullfvghightemp)
                arrayadd(x, bullfvghight, bullfvghighttemp)
                arrayadd(x, bullfvglow, bullfvglowtemp)
                arrayadd(x, bullfvglowt, bullfvglowttemp)

bullfvghigh := array.copy(bullfvghightemp)
bullfvghight := array.copy(bullfvghighttemp)
bullfvglow := array.copy(bullfvglowtemp)
bullfvglowt := array.copy(bullfvglowttemp)
array.clear(bullfvghightemp)
array.clear(bullfvghighttemp)
array.clear(bullfvglowtemp)
array.clear(bullfvglowttemp)


if (low[2] > high and (math.abs(high - low[2]) / high) * 100 > gap)
    array.push(bearfvghigh, high)
    array.push(bearfvglow, low[2])
    array.push(bearfvghight, time)
    array.push(bearfvglowt, time[2])
    
if (array.size((bearfvglow)) > 0)
    
    for x = array.size((bearfvglow))-1 to 0
    
        if (mit == "full fill high/low")
            if (not(high >= array.get(bearfvglow, x)) and array.get(bearfvglowt, x) >= time - lookback*(bar+2))
                arrayadd(x, bearfvghigh, bearfvghightemp)
                arrayadd(x, bearfvghight, bearfvghighttemp)
                arrayadd(x, bearfvglow, bearfvglowtemp)
                arrayadd(x, bearfvglowt, bearfvglowttemp)
        if (mit == "half fill high/low")
            if (not(high >= array.get(bearfvglow, x)-(array.get(bearfvglow, x)-array.get(bearfvghigh, x))/2) and array.get(bearfvglowt, x) >= time - lookback*(bar+2))
                arrayadd(x, bearfvghigh, bearfvghightemp)
                arrayadd(x, bearfvghight, bearfvghighttemp)
                arrayadd(x, bearfvglow, bearfvglowtemp)
                arrayadd(x, bearfvglowt, bearfvglowttemp)
        if (mit == "full fill open/close")
            if ((close>open ? close : open) < array.get(bearfvglow, x) and array.get(bearfvglowt, x) >= time - lookback*(bar+2))
                arrayadd(x, bearfvghigh, bearfvghightemp)
                arrayadd(x, bearfvghight, bearfvghighttemp)
                arrayadd(x, bearfvglow, bearfvglowtemp)
                arrayadd(x, bearfvglowt, bearfvglowttemp)
        if (mit == "half fill open/close")
            if ((close>open ? close : open) < array.get(bearfvglow, x)-(array.get(bearfvglow, x)-array.get(bearfvghigh, x))/2 and array.get(bearfvglowt, x) >= time - lookback*(bar+2))
                arrayadd(x, bearfvghigh, bearfvghightemp)
                arrayadd(x, bearfvghight, bearfvghighttemp)
                arrayadd(x, bearfvglow, bearfvglowtemp)
                arrayadd(x, bearfvglowt, bearfvglowttemp)
        if (mit == "no mitigation")
            if (array.get(bearfvglowt, x) >= time - lookback*(bar+2))
                arrayadd(x, bearfvghigh, bearfvghightemp)
                arrayadd(x, bearfvghight, bearfvghighttemp)
                arrayadd(x, bearfvglow, bearfvglowtemp)
                arrayadd(x, bearfvglowt, bearfvglowttemp)

bearfvghigh := array.copy(bearfvghightemp)
bearfvghight := array.copy(bearfvghighttemp)
bearfvglow := array.copy(bearfvglowtemp)
bearfvglowt := array.copy(bearfvglowttemp)
array.clear(bearfvghightemp)
array.clear(bearfvghighttemp)
array.clear(bearfvglowtemp)
array.clear(bearfvglowttemp)



var bullhighlinearr = array.new_line()
var bulllowlinearr = array.new_line()
var bearhighlinearr = array.new_line()
var bearlowlinearr = array.new_line()



if (bar_index == last_bar_index)

    if (array.size(bullfvghigh) > 0)
        n:=0
        prevnearbull := high
        for x = array.size((bullfvghigh))-1 to 0
            if (math.abs(close-(array.get(bullfvglow, x)-(array.get(bullfvglow, x)-array.get(bullfvghigh, x))/2)) < prevnearbull)
                prevnearbull := math.abs(close-(array.get(bullfvglow, x)-(array.get(bullfvglow, x)-array.get(bullfvghigh, x))/2))
                n := x
                    
        bullhighline := line.new(x1=array.get(bullfvghight, n), y1=array.get(bullfvghigh, n), x2=time+(bar*2), y2 = array.get(bullfvghigh, n),  xloc=xloc.bar_time, color = bullfvg, style=style, width=width)
        bulllowline := line.new(x1=array.get(bullfvglowt, n), y1=array.get(bullfvglow, n), x2=time+(bar*2), y2 = array.get(bullfvglow, n),  xloc=xloc.bar_time, color = bullfvg, style=style, width=width)
        
        line.set_x2(bullhighline, time+(bar*2))
        line.set_x2(bulllowline, time+(bar*2))
        array.push(bullhighlinearr, bullhighline)
        array.push(bulllowlinearr, bulllowline)

    if (array.size(bullhighlinearr) > 1)
        delline1 = array.remove(bullhighlinearr, 0) 
        line.delete(delline1)
        delline2 = array.remove(bulllowlinearr, 0) 
        line.delete(delline2)

     
    if (array.size(bearfvghigh) > 0)
        m:=0
        prevnearbear := high
        for x = array.size((bearfvghigh))-1 to 0
            if (math.abs(close-(array.get(bearfvglow, x)-(array.get(bearfvglow, x)-array.get(bearfvghigh, x))/2)) < prevnearbear)
                prevnearbear := math.abs(close-(array.get(bearfvglow, x)-(array.get(bearfvglow, x)-array.get(bearfvghigh, x))/2))
                m := x
                
        bearhighline := line.new(x1=array.get(bearfvghight, m), y1=array.get(bearfvghigh, m), x2=time+(bar*2), y2 = array.get(bearfvghigh, m),  xloc=xloc.bar_time, color = bearfvg, style=style, width=width)
        bearlowline := line.new(x1=array.get(bearfvglowt, m), y1=array.get(bearfvglow, m), x2=time+(bar*2), y2 = array.get(bearfvglow, m),  xloc=xloc.bar_time, color = bearfvg, style=style, width=width)
        
        line.set_x2(bearhighline, time+(bar*2))
        line.set_x2(bearlowline, time+(bar*2))
        array.push(bearhighlinearr, bearhighline)
        array.push(bearlowlinearr, bearlowline)

    if (array.size(bearhighlinearr) > 1)
        delline3 = array.remove(bearhighlinearr, 0) 
        line.delete(delline3)
        delline4 = array.remove(bearlowlinearr, 0) 
        line.delete(delline4)

    label.delete(bearbpr)
    label.delete(bullbpr)
    
    if (array.size(bulllowlinearr) > 0 and array.size(bearlowlinearr) > 0)
        if (line.get_y1(array.get(bulllowlinearr, 0)) < line.get_y1(array.get(bearlowlinearr, 0)) and line.get_y1(array.get(bullhighlinearr, 0)) > line.get_y1(array.get(bearhighlinearr, 0)) and bprs)
            bearbpr := label.new(x=time, y=high, text=str.tostring("▼"), xloc=xloc.bar_time, color=color.white, style=label.style_none, textcolor=bearfvg, size=size.normal, textalign=text.align_right)
    
        if (line.get_y1(array.get(bearlowlinearr, 0)) < line.get_y1(array.get(bulllowlinearr, 0)) and line.get_y1(array.get(bearhighlinearr, 0)) > line.get_y1(array.get(bullhighlinearr, 0)) and bprs)
            bearbpr := label.new(x=time, y=high, text=str.tostring("▼"), xloc=xloc.bar_time, color=color.white, style=label.style_none, textcolor=bullfvg, size=size.normal, textalign=text.align_right)

// debug label.new(x=time, y=high, text=str.tostring(prevnearbear), xloc=xloc.bar_time, color=color.white, style=label.style_none, textcolor=color.green, size=size.normal, textalign=text.align_right)


/////////////////////////////////////////////////////////

//-------------------- Ts+CRT 6H v7,2 -------------------

/////////////////////////////////////////////////////////

//CRT HIGH and LOW
//************************************************************
type MajorHighLow
    float H = na
    float L = na
    float pH = na // Previous High
    float pL = na // Previous Low
    int pHTime = na
    int pLTime = na
    int pStart = na
    string tf = "" // Keep 'tf' for reDraw labels

    line highLine = na
    line lowLine = na
    line eqLine = na
    label highLabel = na
    label lowLabel = na
    label eqLabel = na

//************************************************************
type TimeLine
    string Tf
    int Hour
    int Min
    string Text
    line Line = na
    label Label = na
    int Offset = 5

//************************************************************

isInSession(string sessionTime, string sessionTimeZone = "UTC-4") =>
    not na(time(timeframe.period, sessionTime, sessionTimeZone))

//************************************************************

newLine(int x1 = na, float y1 = na, int x2 = na, float y2 = na, color color, string style = line.style_solid, int width = 1, int max = 3, string xloc = xloc.bar_time) =>
    line = line.new(x1, y1, x2, y2, color = color, style = style, width = width, xloc = xloc)
    line

// ************************************************************

newLabel(int x = na, float y = na, string txt = "", color color, string style = label.style_label_left, string size = size.normal, int max = 3, string xloc = xloc.bar_time) =>
    label = label.new(x, y, txt, textcolor = color, style = style, size = size, color = color.new(color.white, 100), xloc = xloc)
    label

//************************************************************
// --- shiftOverlappingLabels (sin 'return') ---
shiftOverlappingLabels(label[] tfRangeLabels) =>
    arr_size = array.size(tfRangeLabels)
    if arr_size > 1
        max_idx = arr_size - 1
        for i = 0 to max_idx - 1
            currentLabel = array.get(tfRangeLabels, i)
            if na(currentLabel)
                continue
            currentPrice = label.get_y(currentLabel)
            if na(currentPrice)
                continue
            currentText = label.get_text(currentLabel)
            for j = i + 1 to max_idx
                nextLabel = array.get(tfRangeLabels, j)
                if na(nextLabel)
                    continue
                nextPrice = label.get_y(nextLabel)
                if na(nextPrice)
                    continue
                if math.abs(nextPrice - currentPrice) < syminfo.mintick * 25
                    nextText = label.get_text(nextLabel)
                    if not na(currentText) and not na(nextText) and currentText != nextText
                        label.set_y(nextLabel, nextPrice + syminfo.mintick * 25)


//************************************************************

method calculate(TimeLine this) =>
    var float price = 0
    var bool isStart = false
    var int offset = timeframe.in_seconds(timeframe.period) * 1000
    isTargetTime = hour(time, "America/New_York") == this.Hour and minute(time, "America/New_York") == this.Min
    inDay = isInSession("0000-2300", "America/New_York") and timeframe.isintraday
    bool isNewUpdate = timeframe.change(this.Tf)
    if isNewUpdate
        if not na(this.Line)
            this.Line.set_xy1(na, na)
            this.Line.set_xy2(na, na)
        if not na(this.Label)
            this.Label.set_text("")
            this.Label.set_xy(na, na)
        isStart := false
        price := 0
    if isTargetTime and not isStart and not na(this.Line) and not na(this.Label)
        price := open
        this.Line.set_xy1(time, price)
        int endX = time + (offset * this.Offset)
        this.Line.set_xy2(endX, price)
        this.Label.set_text(this.Text)
        this.Label.set_xy(endX, price)
        isStart := true
    else if inDay and barstate.isconfirmed and not na(this.Line) and not na(this.Label) and isStart
        int endX = time + (offset * this.Offset)
        int labelX = time + (offset * this.Offset)
        this.Line.set_xy2(endX, price)
        this.Label.set_xy(labelX, price)
    this


//************************************************************

method reDraw(MajorHighLow this, bool showEQ = true) =>
    var int offset = timeframe.in_seconds(timeframe.period) * 1000
    int endX = time + (offset * 5)
    int endX2 = time + (offset * 5)

    string tfSuffix = ""
    if this.tf == "15"
        tfSuffix := "15M"
    else if this.tf == "90"
        tfSuffix := "90M"
    else if this.tf == "360"
        tfSuffix := "6H"

    if not na(this.pH) and not na(this.highLine) and not na(this.highLabel)
        line.set_xy1(this.highLine, this.pHTime, this.pH)
        line.set_xy2(this.highLine, endX, this.pH)
        label.set_xy(this.highLabel, endX2, this.pH)
        label.set_text(this.highLabel, "CRH " + tfSuffix)

    if not na(this.pL) and not na(this.lowLine) and not na(this.lowLabel)
        line.set_xy1(this.lowLine, this.pLTime, this.pL)
        line.set_xy2(this.lowLine, endX, this.pL)
        label.set_xy(this.lowLabel, endX2, this.pL)
        label.set_text(this.lowLabel, "CRL " + tfSuffix)

    if showEQ and not na(this.pH) and not na(this.pL) and not na(this.eqLine) and not na(this.eqLabel)
        eqPrice = (math.abs(this.pH - this.pL) / 2) + this.pL
        eqTime = na(this.pLTime) ? this.pHTime : na(this.pHTime) ? this.pLTime : math.min(this.pHTime, this.pLTime)
        if not na(eqTime)
            line.set_xy1(this.eqLine, eqTime, eqPrice)
            line.set_xy2(this.eqLine, endX, eqPrice)
            label.set_xy(this.eqLabel, endX2, eqPrice)
            label.set_text(this.eqLabel, "EQ " + tfSuffix)
    else if not na(this.eqLine) and not na(this.eqLabel)
        line.set_xy1(this.eqLine, na, na)
        line.set_xy2(this.eqLine, na, na)
        label.set_xy(this.eqLabel, na, na)
        label.set_text(this.eqLabel, "")


//************************************************************
method calculate(MajorHighLow this, string i_tf, bool draw = true, bool showEQ = false) =>
    var float prevHigh = na
    var float prevLow = na
    var int prevHighTime = na
    var int prevLowTime = na

    // Request data from the previous bar of the higher timeframe
    [sec_high_prev, sec_low_prev, sec_time_prev] = request.security(syminfo.tickerid, i_tf, [high[1], low[1], time[1]], lookahead=barmerge.lookahead_on)

    // Only update internal values if the requested security data is valid (not na)
    if not na(sec_high_prev)
        prevHigh := sec_high_prev
        prevHighTime := sec_time_prev
    if not na(sec_low_prev)
        prevLow := sec_low_prev
        prevLowTime := sec_time_prev

    // Assign potentially na values from bar 0, or valid values later
    this.pH := prevHigh
    this.pL := prevLow
    this.pHTime := prevHighTime
    this.pLTime := prevLowTime

    if draw
        // Redraw will handle na values appropriately
        this.reDraw(showEQ)
    this


//************************************************************

// --- Helper function to get line style ---
getStyle(string styleName) =>
    style = line.style_solid // Default
    if styleName == "Dashed"
        style := line.style_dashed
    else if styleName == "Dotted"
        style := line.style_dotted
    style

//************************************************************
// Inputs

// --- 6H ---

// --- 90M ---



//************************************************************
// Global Declarations & Initializations

int currentTFminutes = timeframe.in_seconds(timeframe.period) / 60
label[] levelLabels = array.new<label>()


var MajorHighLow previous6HHighLows = na
var MajorHighLow previous90MHighLows = na


//************************************************************
// Conditional Initialization, Calculation & Drawing

// ----- 90M -----
if (show90M or alert90M) and currentTFminutes < 90
    if na(previous90MHighLows)
        style = getStyle(NinetyMStyle)
        previous90MHighLows := MajorHighLow.new(tf = "90",
             highLine = show90M ? newLine(color = NinetyMColor, style = style) : na,
             lowLine  = show90M ? newLine(color = NinetyMColor, style = style) : na,
             highLabel= show90M ? newLabel(color = NinetyMColor) : na,
             lowLabel = show90M ? newLabel(color = NinetyMColor) : na,
             eqLine   = show90M and show90MEQ ? newLine(color = NinetyMColor, style = line.style_dotted) : na,
             eqLabel  = show90M and show90MEQ ? newLabel(color = NinetyMColor) : na )
    if not na(previous90MHighLows)
        previous90MHighLows.calculate("90", draw = show90M, showEQ = show90MEQ)
        if show90M
            if not na(previous90MHighLows.highLabel)
                levelLabels.push(previous90MHighLows.highLabel)
            if not na(previous90MHighLows.lowLabel)
                levelLabels.push(previous90MHighLows.lowLabel)
            if show90MEQ and not na(previous90MHighLows.eqLabel)
                levelLabels.push(previous90MHighLows.eqLabel)

// ----- 6H -----
if (show6H or alert6H) and currentTFminutes < 360
    if na(previous6HHighLows)
        style = getStyle(SixHStyle)
        previous6HHighLows := MajorHighLow.new(tf = "360",
             highLine = show6H ? newLine(color = SixHColor, style = style) : na,
             lowLine  = show6H ? newLine(color = SixHColor, style = style) : na,
             highLabel= show6H ? newLabel(color = SixHColor) : na,
             lowLabel = show6H ? newLabel(color = SixHColor) : na,
             eqLine   = show6H and show6HEQ ? newLine(color = SixHColor, style = line.style_dotted) : na,
             eqLabel  = show6H and show6HEQ ? newLabel(color = SixHColor) : na )
    if not na(previous6HHighLows)
        previous6HHighLows.calculate("360", draw = show6H, showEQ = show6HEQ)
        if show6H
            if not na(previous6HHighLows.highLabel)
                levelLabels.push(previous6HHighLows.highLabel)
            if not na(previous6HHighLows.lowLabel)
                levelLabels.push(previous6HHighLows.lowLabel)
            if show6HEQ and not na(previous6HHighLows.eqLabel)
                levelLabels.push(previous6HHighLows.eqLabel)

//************************************************************
// Label Shifting (Global Scope)

if array.size(levelLabels) > 1
    shiftOverlappingLabels(levelLabels)

//************************************************************
// Alert Conditions (Global Scope - CORREGIDO CON VARIABLES TEMPORALES)

// --- 90M Alerts ---
pH90M = not na(previous90MHighLows) ? previous90MHighLows.pH : na
pL90M = not na(previous90MHighLows) ? previous90MHighLows.pL : na
alertcondition(alert90M and not na(pH90M) and ta.crossunder(close, pH90M), title="CRH 90M Roto Arriba", message="CRH 90M nivel previo alto cruzado hacia arriba.")
alertcondition(alert90M and not na(pL90M) and ta.crossunder(close, pL90M), title="CRL 90M Roto Abajo", message="CRL 90M nivel previo bajo cruzado hacia abajo.")

// --- 6H Alerts ---
pH6H = not na(previous6HHighLows) ? previous6HHighLows.pH : na
pL6H = not na(previous6HHighLows) ? previous6HHighLows.pL : na
alertcondition(alert6H and not na(pH6H) and ta.crossunder(close, pH6H), title="CRH 6H Roto Arriba", message="CRH 6H nivel previo alto cruzado hacia arriba.")
alertcondition(alert6H and not na(pL6H) and ta.crossunder(close, pL6H), title="CRL 6H Roto Abajo", message="CRL 6H nivel previo bajo cruzado hacia abajo.")


/////////////////////////////////////////////////////

//-------------------- WATERMARK--------------------

////////////////////////////////////////////////////

//text inputs
title = input.string("C R T - T r a d e r", "Tittle", group = "=========WATERMARK=========")
subtitle = input.string("TS • CRT • FX", "Subtitle", group = "=========WATERMARK=========")
//symbol info
symInfoCheck = input.bool(title="Show Symbol Info", defval=false, group = "watermark position")
symInfo = syminfo.ticker  + " | " + timeframe.period + (timeframe.isminutes ? "M" : na)
date = str.format("{0}/{1}/{2}", dayofmonth(time_close), month(time_close), year(time_close))
//text positioning
textVPosition = input.string("bottom", "Vertical Position", options = ["top", "middle", "bottom"], group = "watermark position")
textHPosition = input.string("right", "Horizontal Position", options = ["left", "center", "right"], group = "watermark position")
//symbol info positioning
symVPosition = input.string("bottom", "Vertical Position", options = ["top", "middle", "bottom"], group = "symbol position")
symHPosition = input.string("center", "Horizontal Position", options = ["left", "center", "right"], group = "symbol position")
//cell size
cellWidthPercent = input.float(0, "Cell Width (%)", minval = 0, maxval = 100, tooltip = "The width of the cell as a % of the indicator's visual space. Optional. By default, auto-adjusts the width based on the text inside the cell. Value 0 has the same effect.", group = "cell size")
cellHeightPercent = input.float(0, "Cell Height (%)", minval = 0, maxval = 100, tooltip = "The height of the cell as a % of the indicator's visual space. Optional. By default, auto-adjusts the height based on the text inside of the cell. Value 0 has the same effect.", group = "cell size")
//title settings
c_title = input(color.new(color.black, 35), "Title Color", group = "title settings")
s_title = input.string("huge", "Title Size", options = ["tiny", "small", "normal", "large", "huge", "auto"], group = "title settings")
a_title = input.string("center","Title Alignment", options = ["center","left", "right"], group = "title settings")
//subtitle settings
c_subtitle = input(color.new(color.black, 35), "Subtitle Color", group = "subtitle settings")
s_subtitle = input.string("large", "Subtitle Size", options = ["tiny", "small", "normal", "large", "huge", "auto"], group = "subtitle settings")
a_subtitle = input.string("center","Subtitle Alignment", options = ["center","left", "right"], group = "subtitle settings")

//symbol settings
c_symInfo = input(color.new(color.black, 35), "Subtitle Color", group = "symbol settings")
s_symInfo = input.string("normal", "Subtitle Size", options = ["tiny", "small", "normal", "large", "huge", "auto"], group = "symbol settings")
a_symInfo = input.string("center","Subtitle Alignment", options = ["center","left", "right"], group = "symbol settings")
c_bg = input(color.new(color.blue, 100), "Background", group = "background")

//text watermark creation
var table textWatermark = table.new(textVPosition + "_" + textHPosition, 1, 3)
table.cell(textWatermark, 0, 0, title, width = cellWidthPercent, height = cellHeightPercent, text_color = c_title, text_halign = a_title, text_size = s_title, bgcolor = c_bg)
table.cell(textWatermark, 0, 1, subtitle, width = cellWidthPercent, height = cellHeightPercent, text_color = c_subtitle, text_halign = a_subtitle, text_size= s_subtitle, bgcolor = c_bg)
//symbol info watermark creation
var table symWatermark = table.new(symVPosition + "_" + symHPosition, 5, 5)
if symInfoCheck
    table.cell(symWatermark, 0, 1, symInfo, width = cellWidthPercent, height = cellHeightPercent, text_color = c_symInfo, text_halign = a_symInfo, text_size = s_symInfo, bgcolor = c_bg)
    table.cell(symWatermark, 0, 0, date, width = cellWidthPercent, height = cellHeightPercent, text_color = c_symInfo, text_halign = a_symInfo, text_size = s_symInfo, bgcolor = c_bg)

/////////////////////////////////////////////////////////////////////////////

//-------------------- ＳＷＥＥＰ ｉｎｓｔｉｔｕｔｉｏｎａｌ -------------------

////////////////////////////////////////////////////////////////////////////

section7_title = input.string(title="ＳＷＥＥＰ ｉｎｓｔｉｔｕｔｉｏｎａｌ", defval="")

//INPUTS
cooldownPeriod = input.int(10,title="Cooldown Period", minval=0, group = "Settings") 

lbLeft = 20
lbRight = 20

bullWidth = input.int(1, title='Line Width:', group='Bullish Sweep')
bullStyle = input.string('Dashed', title='Line Style:', options=['Solid', 'Dotted', 'Dashed'], group='Bullish Sweep')
bullColor = input.color(color.new(color.teal, 0), title='Bullish Color:', group='Bullish Sweep')

bearWidth = input.int(1, title='Line Width:', group='Bearish Sweep')
bearStyle = input.string('Dashed', title='Line Style:', options=['Solid', 'Dotted', 'Dashed'], group='Bearish Sweep')
bearColor = input.color(color.new(color.maroon, 0), title='Bearish Color:', group='Bearish Sweep')

//FUNCTIONS
lineStyle(s) =>
    if s == 'Solid'
        line.style_solid
    else if s == 'Dotted'
        line.style_dotted
    else
        line.style_dashed

//VARS
var int bullSignalIndex = 0
var int bearSignalIndex = 0

var line bullLine = na
var line bearLine = na

var line highLine = na
var line lowLine = na

var label swingHighLbl = na
var label swingLowLbl = na
var label swingHighLblTxt = na
var label swingLowLblTxt = na

var float swingLowVal = na
var float swingHighVal = na

//CALCULATIONS
pLow = ta.pivotlow(low, lbLeft, lbRight)
pHigh = ta.pivothigh(high, lbLeft, lbRight)

pLowVal = ta.valuewhen(not na(pLow), low[lbRight], 0) 
pHighVal = ta.valuewhen(not na(pHigh), high[lbRight], 0)

prevLowIndex = ta.valuewhen(not na(pLow), bar_index[lbRight], 0)
prevHighIndex = ta.valuewhen(not na(pHigh), bar_index[lbRight], 0)

lp = ta.lowest(low, lbLeft)
hp = ta.highest(high, lbLeft)

highestClose = ta.highest(close, lbLeft)
lowestClose = ta.lowest(close, lbLeft)

bullishSFP = low < pLowVal and close > pLowVal and open > pLowVal and low == lp and lowestClose >= pLowVal
bearishSFP = high > pHighVal and close < pHighVal and open < pHighVal and high == hp and highestClose <= pHighVal

bullCond = bullishSFP[3] and (close > pLowVal) and  (close[1] > pLowVal[1]) and (close[2] > pLowVal[2]) and bar_index >= bullSignalIndex + cooldownPeriod
bearCond = bearishSFP[3] and (close < pHighVal) and  (close[1] < pHighVal[1]) and (close[2] < pHighVal[2]) and bar_index >= bearSignalIndex + cooldownPeriod

//Check Swing H/L Stopper
var int swingLowCounter = 0
var int swingHighCounter = 0
var bool isSwingLowCheck = false
var bool isSwingHighCheck = false
var bool stopPrintingLow = false
var bool stopPrintingHigh = false

if high < swingLowVal and isSwingLowCheck
    swingLowCounter := swingLowCounter+1

if low > swingHighVal and isSwingHighCheck
    swingHighCounter := swingHighCounter+1

if ta.crossunder(close, swingLowVal) and isSwingLowCheck == false
    isSwingLowCheck := true
    swingLowCounter := 1

if ta.crossover(close, swingHighVal) and isSwingHighCheck == false
    isSwingHighCheck := true
    swingHighCounter := 1

if swingLowCounter == 5 and isSwingLowCheck
    stopPrintingLow := true
    isSwingLowCheck := false
    line.set_x2(lowLine,bar_index[4])

if swingHighCounter == 5 and isSwingHighCheck
    stopPrintingHigh := true
    isSwingHighCheck := false
    line.set_x2(highLine,bar_index[4])

//Draw sweep lines
if bullCond
    bullSignalIndex := bar_index
    bullLine := line.new(prevLowIndex, pLowVal, bar_index-3, pLowVal, color=bullColor, width=bullWidth, style=lineStyle(bullStyle))

if bearCond
    bearSignalIndex := bar_index
    bearLine := line.new(prevHighIndex, pHighVal, bar_index-3, pHighVal, color=bearColor, width=bearWidth, style=lineStyle(bearStyle))

var swingHighArr = array.new_label(0)
var swingHighTextArr = array.new_label(0)

var swingLowArr = array.new_label(0)
var swingLowTextArr = array.new_label(0)

if array.size(swingHighArr) >= 3
    label.delete(array.shift(swingHighArr))
    label.delete(array.shift(swingHighTextArr))
   
if array.size(swingLowArr) >= 3
    label.delete(array.shift(swingLowArr))
    label.delete(array.shift(swingLowTextArr))

//Draw range lines
if showSwing
    if stopPrintingHigh == false 
        line.set_x2(highLine,bar_index+5)
    if stopPrintingLow == false
        line.set_x2(lowLine,bar_index+5)

if showSwing and not na(pHigh) and bearishSFP[lbRight] == false
    stopPrintingHigh := false
    swingHighVal := high[lbRight]
    line.delete(highLine)
    highLine := line.new(bar_index[lbRight], high[lbRight], bar_index+10, high[lbRight], color = swingClr, width = 2)

    swingHighLbl := label.new(bar_index[lbRight], high[lbRight], text="", yloc=yloc.abovebar, color = swingClr, textcolor = swingClr, style = label.style_triangledown, size = size.auto)
    swingHighLblTxt := label.new(bar_index[lbRight], high[lbRight], text="Swing\nH", yloc=yloc.abovebar, color = swingClr, textcolor = swingClr, style = label.style_none, size = size.small)
    array.push(swingHighArr, swingHighLbl)
    array.push(swingHighTextArr, swingHighLblTxt)

if showSwing and not na(pLow) and bullishSFP[lbRight] == false
    stopPrintingLow := false
    swingLowVal := low[lbRight]
    line.delete(lowLine)
    lowLine := line.new(bar_index[lbRight], low[lbRight], bar_index+10, low[lbRight], color = swingClr, width = 2)

    swingLowLbl := label.new(bar_index[lbRight], low[lbRight], text="", yloc=yloc.belowbar, color = swingClr, textcolor = swingClr, style = label.style_triangleup, size = size.auto)
    swingLowLblTxt := label.new(bar_index[lbRight], low[lbRight], text="Swing\nL", yloc=yloc.belowbar, color = swingClr, textcolor = swingClr, style = label.style_none, size = size.small)
    array.push(swingLowArr, swingLowLbl)
    array.push(swingLowTextArr, swingLowLblTxt) 

//PLOTS
plotshape(bullCond, text='Sweep', color=bullColor, textcolor=bullColor, location=location.belowbar, offset = -1)
plotshape(bearCond, text='Sweep', color=bearColor, textcolor=bearColor, location=location.abovebar, offset = -1) 

//ALERTS
alertcondition(bullishSFP, title='Bullish Sweep', message='{{ticker}} Bullish Sweep, Price:{{close}}')
alertcondition(bearishSFP, title='Bearish Sweep', message='{{ticker}} Bearish Sweep, Price:{{close}}')
````
