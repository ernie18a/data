# Goldbach Time algopathing

- url: https://www.tradingview.com/script/lKl5sQBa-Goldbach-Time-algopathing/
- type: indicator
- pine_id: PUB;6b946c701a684368b9c2156ee095bc10
- version: 1.0

## Description

Created by Tactile trader to identify calculations of swings for gbt

## Source Code

````pine
//@version=6
indicator("Goldbach Time – algopathing", overlay=true, max_labels_count=500, max_lines_count=500)

// ---------- SETTINGS ----------
groupTZ = "Goldbach Time"
selected_tz = input.string(
     "America/New_York", "Timezone",
     options=["America/New_York","Asia/Kolkata","Europe/Stockholm","Europe/Zurich","Europe/Warsaw","Exchange"],
     group=groupTZ)
label_size = input.string("small", "Text size (historical numbers)", options=["tiny","small","normal","large"], group=groupTZ)

// Visibility GB/CE
groupSets = "Sets and colors"
show_gb_set = input.bool(true, "Show Goldbach (GB)", group=groupSets)
show_ce_set = input.bool(true, "Show CE", group=groupSets)
gb_color = input.color(color.rgb(33, 8, 124), "GB color", group=groupSets)
ce_color = input.color(color.rgb(254, 102, 7), "CE color", group=groupSets)

// Offsets and stacking
groupSpacing = "Offset and stack"
stack_spacing = input.float(0.10, "Spacing between numbers (price units)", step=0.01, group=groupSpacing)
offset_units = input.string("ticks", "Unit of extra offset", options=["ticks","price"], group=groupSpacing)
top_extra = input.float(10.0, "Extra offset ABOVE candle", step=0.1, group=groupSpacing)
bot_extra = input.float(10.0, "Extra offset BELOW candle", step=0.1, group=groupSpacing)

// Number filters
groupFilters = "Number filters"
only_csv = input.string("", "Only these numbers (CSV)", inline="csv", group=groupFilters)
exclude_csv = input.string("", "Exclude numbers (CSV)", inline="csv", group=groupFilters)

// Sources
groupSources = "Calculation sources"
use_sum  = input.bool(true,  "Use sum (hr+min ±1)", group=groupSources)
use_diff = input.bool(true,  "Use difference (|hr-min| ±1)", group=groupSources)
use_min  = input.bool(true,  "Use minute (min ±1)", group=groupSources)

// Swings
groupSwing = "Swings"
plot_swings    = input.bool(true, "Dots on swings", group=groupSwing)
use_swing_only = input.bool(true, "Calculate only on confirmed swings (pivot [2])", group=groupSwing)

// Path
groupPath = "Path"
show_path        = input.bool(true, "Zig-zag on detected GB/CE points", group=groupPath)
path_color       = input.color(color.new(color.yellow, 20), "Path color", group=groupPath)
buffer_reset     = input.int(200, "Clear buffer every N bars (0=off)", group=groupPath)
show_path_points = input.bool(false, "Debug: show path points", group=groupPath)
// NEW inputs (styl i grubość linii)
path_width       = input.int(2, "Path width", minval=1, maxval=5, group=groupPath)
path_style_opt   = input.string("Dotted", "Path style", options=["Solid","Dashed","Dotted"], group=groupPath)

// Realtime
groupRT = "Realtime (right-side text)"
show_seq_rt   = input.bool(true, "Show sequence index (right of current candle)", group=groupRT)
show_rt_list  = input.bool(true, "Show numbers forming for current candle", group=groupRT)
show_rt_count = input.bool(true, "Append total count in brackets", group=groupRT)
calc_mode     = input.string("All", "Current-candle method", options=["All","Sum","Diff","Minute"], group=groupRT)
rt_text_size  = input.string("normal", "Realtime text size", options=["tiny","small","normal","large"], group=groupRT)
rt_y_mode     = input.string("Above", "Vertical anchor", options=["Above","Below","Close"], group=groupRT)
rt_y_extra    = input.float(10.0, "Vertical extra offset", step=0.1, group=groupRT)
rt_x_bars     = input.float(1.0, "Horizontal offset in bars (to the right)", step=0.1, group=groupRT)

// ---------- GB/CE SETS ----------
var int[] GB_NUMBERS = array.from(0, 3, 11, 17, 29, 41, 47, 50, 53, 59, 71, 83, 89, 97, 100)
var int[] CE_NUMBERS = array.from(7, 14, 23, 35, 44, 56, 77)

// ---------- HELPERS ----------
tz() =>
    selected_tz == "Exchange" ? syminfo.timezone : selected_tz

isSwingHigh() =>
    high[4] < high[2] and high[3] < high[2] and high[2] > high[1] and high[2] > high
isSwingLow() =>
    low[4] > low[2] and low[3] > low[2] and low[2] < low[1] and low[2] < low

plotchar(plot_swings and isSwingLow(),  "Swing Low",  "•", location.belowbar, color=color.new(color.green, 0), offset=-2, size=size.tiny)
plotchar(plot_swings and isSwingHigh(), "Swing High", "•", location.abovebar, color=color.new(color.red, 0),   offset=-2, size=size.tiny)

// Buffers
var int   recent_limit = 12
var int[] zz_bars      = array.new_int()
var float[] zz_prices  = array.new_float()

var string[] label_keys = array.new_string()
var int label_buffer_len = 50

var label seq_lbl     = na
var label rt_nums_lbl = na
var int   seq_counter = 0

parseCsvToIntArray(_csv) =>
    int[] out = array.new_int()
    if str.length(_csv) > 0
        string[] parts = str.split(_csv, ",")
        for i = 0 to array.size(parts) - 1
            string raw = array.get(parts, i)
            string noSpaces = str.replace(raw, " ", "")
            float n = str.tonumber(noSpaces)
            if not na(n)
                array.push(out, int(math.round(n)))
    out

var int[] only_list = array.new_int()
var int[] exclude_list = array.new_int()
if barstate.isfirst
    only_list    := parseCsvToIntArray(only_csv)
    exclude_list := parseCsvToIntArray(exclude_csv)

passesValueFilters(v) =>
    bool onlyMode  = array.size(only_list) > 0
    bool inOnly    = onlyMode ? array.includes(only_list, v) : true
    bool inExclude = array.includes(exclude_list, v)
    inOnly and not inExclude

toUnits(_val) =>
    offset_units == "ticks" ? _val * syminfo.mintick : _val

getExtraOffset(_isHigh) =>
    float base = _isHigh ? top_extra : bot_extra
    offset_units == "ticks" ? base * syminfo.mintick : base

drawLabelIfUnique(_val, _col, _size, _isHigh, _bar, _price, _stackNo) =>
    float magnitude = math.log10(math.abs(_price) + 1)
    float effective = stack_spacing * math.pow(10, math.floor(magnitude - 2))
    float delta     = _stackNo * effective + getExtraOffset(_isHigh)
    float y         = _isHigh ? (_price + delta) : (_price - delta)
    string key = str.tostring(_bar) + "|" + str.tostring(_val)
    bool can = not array.includes(label_keys, key)
    if can
        label.new(x=_bar, y=y, text=str.tostring(_val), style=label.style_label_center,
                  xloc=xloc.bar_index, yloc=yloc.price,
                  color=color.new(color.white, 100), textcolor=_col, size=_size)
        array.push(label_keys, key)
        if array.size(label_keys) > label_buffer_len
            array.shift(label_keys)

recordPoint(_bar, _price) =>
    if not na(_bar) and not na(_price)
        array.push(zz_bars, _bar)
        array.push(zz_prices, _price)
        if show_path_points
            label.new(x=_bar, y=_price, text="•", style=label.style_label_center,
                      xloc=xloc.bar_index, yloc=yloc.price,
                      textcolor=color.new(color.yellow, 0), color=color.new(color.white, 100), size=size.tiny)
        if array.size(zz_bars) > recent_limit
            array.shift(zz_bars)
            array.shift(zz_prices)

// Map stylu linii z inputu
path_style = path_style_opt == "Solid" ? line.style_solid :
     path_style_opt == "Dashed" ? line.style_dashed : line.style_dotted

drawPath() =>
    if show_path and array.size(zz_bars) >= 2
        for i = 0 to array.size(zz_bars) - 2
            int x1 = array.get(zz_bars, i)
            float y1 = array.get(zz_prices, i)
            int x2 = array.get(zz_bars, i+1)
            float y2 = array.get(zz_prices, i+1)
            if not na(x1) and not na(y1) and not na(x2) and not na(y2)
                line.new(x1, y1, x2, y2, xloc=xloc.bar_index, color=path_color, width=path_width, style=path_style)

// ---------- MAIN GB TIME LOGIC ----------
procGB(_isHigh, _isLow) =>
    int b = na
    float p = na
    if _isHigh
        b := bar_index - 2
        p := high[2]
    if _isLow
        b := bar_index - 2
        p := low[2]
    int hr = hour(time[2], tz())
    int mn = minute(time[2], tz())
    float[] valsf = array.new_float()
    if use_sum
        int sum = hr + mn
        array.push(valsf, sum - 1.0)
        array.push(valsf, sum * 1.0)
        array.push(valsf, sum + 1.0)
    if use_diff
        int diff = math.abs(hr - mn)
        array.push(valsf, diff - 1.0)
        array.push(valsf, diff * 1.0)
        array.push(valsf, diff + 1.0)
    if use_min
        array.push(valsf, mn - 1.0)
        array.push(valsf, mn * 1.0)
        array.push(valsf, mn + 1.0)
    int stackNo = 0
    for j = 0 to array.size(valsf) - 1
        int v = int(math.round(array.get(valsf, j)))
        bool isGB = show_gb_set and array.includes(GB_NUMBERS, v)
        bool isCE = show_ce_set and array.includes(CE_NUMBERS, v)
        bool allowed = (isGB or isCE) and passesValueFilters(v)
        if allowed
            color col = isGB ? gb_color : ce_color
            drawLabelIfUnique(v, col, label_size, _isHigh, b, p, stackNo)
            stackNo += 1
    bool found = stackNo > 0
    if found
        recordPoint(b, p)
    found

do_now = use_swing_only ? (isSwingHigh() or isSwingLow()) : true
if do_now
    bool h = isSwingHigh()
    bool l = isSwingLow()
    if h or l
        bool got = procGB(h, l)
        if got
            seq_counter += 1

if buffer_reset > 0 and bar_index % buffer_reset == 0
    array.clear(zz_bars)
    array.clear(zz_prices)
    array.clear(label_keys)
    seq_counter := 0

if barstate.islast
    drawPath()

rt_y_anchor() =>
    rt_y_mode == "Above" ? high : rt_y_mode == "Below" ? low : close

rt_y_value() =>
    float base = rt_y_anchor()
    float extra = toUnits(rt_y_extra) * (rt_y_mode == "Above" ? 1 : rt_y_mode == "Below" ? -1 : 0)
    base + extra

rt_x_value() =>
    bar_index + int(math.round(rt_x_bars))

if show_seq_rt and barstate.islast
    int cur_idx = math.max(array.size(zz_bars), seq_counter)
    int   x_seq = rt_x_value()
    float y_seq = rt_y_value()
    string txt_seq = str.tostring(cur_idx)
    if na(seq_lbl)
        seq_lbl := label.new(x=x_seq, y=y_seq, text=txt_seq,
                             xloc=xloc.bar_index, yloc=yloc.price,
                             color=color.new(color.white, 100),
                             textcolor=color.new(color.black, 0),
                             style=label.style_label_left, size=rt_text_size)
    else
        label.set_x(seq_lbl, x_seq)
        label.set_y(seq_lbl, y_seq)
        label.set_text(seq_lbl, txt_seq)
        label.set_color(seq_lbl, color.new(color.white, 100))
        label.set_textcolor(seq_lbl, color.new(color.black, 0))
        label.set_style(seq_lbl, label.style_label_left)
        label.set_size(seq_lbl, rt_text_size)

buildCurrentVals(_hr, _mn) =>
    float[] out = array.new_float()
    bool wantSum = calc_mode == "All" or calc_mode == "Sum"
    bool wantDif = calc_mode == "All" or calc_mode == "Diff"
    bool wantMin = calc_mode == "All" or calc_mode == "Minute"
    if wantSum
        int s = _hr + _mn
        array.push(out, s - 1.0), array.push(out, s * 1.0), array.push(out, s + 1.0)
    if wantDif
        int d = math.abs(_hr - _mn)
        array.push(out, d - 1.0), array.push(out, d * 1.0), array.push(out, d + 1.0)
    if wantMin
        array.push(out, _mn - 1.0), array.push(out, _mn * 1.0), array.push(out, _mn + 1.0)
    out

if show_rt_list and barstate.islast
    int hr_now = hour(time, tz())
    int mn_now = minute(time, tz())
    float[] curVals = buildCurrentVals(hr_now, mn_now)
    string items = ""
    int matches = 0
    for j = 0 to array.size(curVals) - 1
        int v = int(math.round(array.get(curVals, j)))
        bool isGB = show_gb_set and array.includes(GB_NUMBERS, v)
        bool isCE = show_ce_set and array.includes(CE_NUMBERS, v)
        bool allowed = (isGB or isCE) and passesValueFilters(v)
        if allowed
            string token = str.tostring(v) + (isGB ? "GB" : "CE")
            bool already = str.contains("," + items + ",", "," + token + ",")
            if not already
                items := items + (items == "" ? "" : ", ") + token
                matches += 1
    string txt_rt = items == "" ? "—" : items
    if show_rt_count
        txt_rt := txt_rt + " [" + str.tostring(matches) + "]"
    int   x_nums = rt_x_value()
    float y_nums = rt_y_value()
    if na(rt_nums_lbl)
        rt_nums_lbl := label.new(x=x_nums, y=y_nums, text=txt_rt,
                                 xloc=xloc.bar_index, yloc=yloc.price,
                                 color=color.new(color.white, 100),
                                 textcolor=color.new(color.black, 0),
                                 style=label.style_label_left,
                                 size=rt_text_size)
    else
        label.set_x(rt_nums_lbl, x_nums)
        label.set_y(rt_nums_lbl, y_nums)
        label.set_text(rt_nums_lbl, txt_rt)
        label.set_color(rt_nums_lbl, color.new(color.white, 100))
        label.set_textcolor(rt_nums_lbl, color.new(color.black, 0))
        label.set_style(rt_nums_lbl, label.style_label_left)
        label.set_size(rt_nums_lbl, rt_text_size)
````
