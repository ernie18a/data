# Masterflow

- url: https://www.tradingview.com/script/xB74CpLi-Masterflow/
- type: indicator
- pine_id: PUB;aa62ca586f884e0da68092f8cb8889ae
- version: 2.0

## Description

### MasterFlow — Smart Market Structure & Higher Timeframe Framework

**MasterFlow** is an all-in-one trading framework designed to help traders align with higher timeframe bias, identify key support and resistance levels, and understand market structure without cluttering the chart.

Built around trend, opening prices, and dynamic support/resistance concepts, MasterFlow combines multiple institutional-style tools into a single indicator.

### Features

🔹 **EMA Trend Band**

* 21 EMA and 48 EMA dynamic trend band
* Automatically colors candles based on their position relative to the EMA band
* Quickly identifies bullish, bearish, and neutral market conditions
* Adjustable timeframe visibility and custom color settings

🔹 **PO3 Opening Lines**

* Automatically plots higher timeframe opening prices on lower timeframes
* Includes vertical session markers and opening price levels
* Helps traders identify important Power of Three (PO3) reference points
* Auto-adjusts based on the current chart timeframe

🔹 **4H Support & Resistance Engine**

* Projects support and resistance from the previous three completed 4-hour candles
* Tracks both candle open and close levels
* Automatically updates when levels flip from support to resistance (or vice versa)
* Removes invalidated levels after confirmed breaks
* Designed specifically for intraday traders using lower timeframes

🔹 **15M Self Support & Resistance**

* Displays support and resistance derived from the most recent 15-minute candles
* Ideal for 1-minute execution traders
* Dynamic level flipping and invalidation logic
* Provides short-term intraday structure references

🔹 **Daily, Weekly & Monthly Opening Prices**

* Displays current and historical:

  * Daily Open
  * Weekly Open
  * Monthly Open
* Fully customizable colors, styles, and visibility
* Excellent for identifying key institutional reference levels

### Best Used For

✅ Futures Trading
✅ Forex/ Crypto Trading
✅ Indices (NQ, ES, DAX, etc.)
✅ Intraday Trading
✅ Market Structure Analysis
✅ Higher Timeframe Bias Identification

### Why MasterFlow?

Instead of loading multiple indicators to determine trend, support/resistance, session levels, and higher timeframe opens, MasterFlow brings everything together into one streamlined workflow.

The goal is simple:

**Trade with the higher timeframe, execute with precision, and keep your chart clean.**

*For educational purposes only. Not financial advice.*

## Source Code

````pine
//@version=6

indicator('Masterflow TDFY FX', overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_bars_back = 5000)

//////////////////////////////////////////////////////////////////

// ================= MASTER FLOW SETTINGS =======================

//////////////////////////////////////////////////////////////////

ema21Length = input.int(21, "EMA 21 Length", minval=1, group="Master Flow")

ema48Length = input.int(48, "EMA 48 Length", minval=1, group="Master Flow")

bandOpacity = input.int(85, "EMA Band Opacity (%)", minval=0, maxval=100, group="Master Flow")

bandTF      = input.string("15m & Below", "Show Band On Timeframes",
                 options=["1m Only", "3m & Below", "5m & Below", "15m & Below", "1H & Below", "4H & Below", "Always"],
                 group="Master Flow")

//////////////////////////////////////////////////////////////////

// ================= MASTER FLOW - EMA BAND =====================

//////////////////////////////////////////////////////////////////

ema21 = ta.ema(close, ema21Length)

ema48 = ta.ema(close, ema48Length)

aboveBand = close > ema21 and close > ema48

belowBand = close < ema21 and close < ema48

bandColor = aboveBand ? color.green : belowBand ? color.red : color.gray

bandMaxSec =
     bandTF == "1m Only"     ? 60      :
     bandTF == "3m & Below"  ? 180     :
     bandTF == "5m & Below"  ? 300     :
     bandTF == "15m & Below" ? 900     :
     bandTF == "1H & Below"  ? 3600    :
     bandTF == "4H & Below"  ? 14400   : 99999999

showBand       = timeframe.in_seconds(timeframe.period) <= bandMaxSec

bandFinalColor = color.new(bandColor, showBand ? 100 - bandOpacity : 100)

p1 = plot(ema21, display=display.none)

p2 = plot(ema48, display=display.none)

fill(p1, p2, color=showBand ? bandFinalColor : na)

//////////////////////////////////////////////////////////////////

// ================= MASTER FLOW - BAR COLORS ===================

//////////////////////////////////////////////////////////////////

barcolor(showBand ? (
     aboveBand ? (close > open ? color.rgb(49, 236, 146) : color.new(#095f35, 60)) :
     belowBand ? (close > open ? color.new(color.red, 60) : color.red) :
     color.new(color.gray, 60)
     ) : na)

//////////////////////////////////////////////////////////////////

// ================= ICT KILLZONES ==============================

//////////////////////////////////////////////////////////////////

var g_SETTINGS = "Sessions - Settings"

max_days = input.int(3, "Session Drawing Limit", 1, tooltip = "Only this many drawings will be kept on the chart, for each selected drawing type", group = g_SETTINGS)

tf_limit = input.timeframe("30", "Timeframe Limit", tooltip = "Drawings will not appear on timeframes greater than or equal to this", group = g_SETTINGS)

gmt_tz = input.string('America/New_York', "Timezone", options = ['America/New_York','GMT-12','GMT-11','GMT-10','GMT-9','GMT-8','GMT-7','GMT-6','GMT-5','GMT-4','GMT-3','GMT-2','GMT-1','GMT+0','GMT+1','GMT+2','GMT+3','GMT+4','GMT+5','GMT+6','GMT+7','GMT+8','GMT+9','GMT+10','GMT+11','GMT+12','GMT+13','GMT+14'], group = g_SETTINGS)

lbl_size_sess = input.string('Normal', "Label Size", options = ['Auto', 'Tiny', 'Small', 'Normal', 'Large', 'Huge'], group = g_SETTINGS)

txt_color = input.color(color.black, "Text Color", group = g_SETTINGS)

use_cutoff = input.bool(false, "Drawing Cutoff Time", inline = "CO", group = g_SETTINGS)

cutoff = input.session("1800-1801", "", inline = "CO", group = g_SETTINGS)

var g_KZ = "Sessions - Killzones"

show_kz = input.bool(true, "Show Killzone Boxes", inline = "KZ", group = g_KZ)

show_kz_text = input.bool(true, "Display Text", inline = "KZ", group = g_KZ)

use_asia = input.bool(true, "", inline = "ASIA", group = g_KZ)

as_txt = input.string("Asia", "", inline = "ASIA", group = g_KZ)

asia = input.session("2000-0000", "", inline = "ASIA", group = g_KZ)

as_color = input.color(color.blue, "", inline = "ASIA", group = g_KZ)

use_london = input.bool(true, "", inline = "LONDON", group = g_KZ)

lo_txt = input.string("London", "", inline = "LONDON", group = g_KZ)

london = input.session("0200-0500", "", inline = "LONDON", group = g_KZ)

lo_color = input.color(color.red, "", inline = "LONDON", group = g_KZ)

use_nyam = input.bool(true, "", inline = "NYAM", group = g_KZ)

na_txt = input.string("NY AM", "", inline = "NYAM", group = g_KZ)

nyam = input.session("0930-1100", "", inline = "NYAM", group = g_KZ)

na_color = input.color(#089981, "", inline = "NYAM", group = g_KZ)

use_nylu = input.bool(true, "", inline = "NYLU", group = g_KZ)

nl_txt = input.string("NY Lunch", "", inline = "NYLU", group = g_KZ)

nylu = input.session("1200-1300", "", inline = "NYLU", group = g_KZ)

nl_color = input.color(color.yellow, "", inline = "NYLU", group = g_KZ)

use_nypm = input.bool(true, "", inline = "NYPM", group = g_KZ)

np_txt = input.string("NY PM", "", inline = "NYPM", group = g_KZ)

nypm = input.session("1330-1600", "", inline = "NYPM", group = g_KZ)

np_color = input.color(color.purple, "", inline = "NYPM", group = g_KZ)

box_transparency = input.int(70, "Box Transparency", 0, 100, group = g_KZ)

text_transparency = input.int(50, "Text Transparency", 0, 100, group = g_KZ)

var g_LABELS = "Sessions - Killzone Pivots"

show_pivots = input.bool(true, "Show Pivots", inline = "PV", group = g_LABELS)

use_alerts = input.bool(true, "Alert Broken Pivots", inline = "PV", group = g_LABELS)

show_midpoints = input.bool(false, "Show Pivot Midpoints", inline = "mp", group = g_LABELS)

stop_midpoints = input.bool(true, "Stop Once Mitigated", inline = "mp", group = g_LABELS)

show_labels = input.bool(true, "Show Pivot Labels", inline = "LB", group = g_LABELS)

label_price = input.bool(false, "Display Price", inline = "LB", group = g_LABELS)

label_right = input.bool(false, "Right Side", inline = "LB", group = g_LABELS)

ext_pivots = input.string("Until Mitigated", "Extend Pivots...", options = ['Until Mitigated', 'Past Mitigation'], group = g_LABELS)

ext_which = input.string("Most Recent", "...From Which Sessions", options = ['Most Recent', 'All'], group = g_LABELS)

ash_str = input.string("AS.H", "Killzone 1 Labels", inline = "L_AS", group = g_LABELS)

asl_str = input.string("AS.L", "", inline = "L_AS", group = g_LABELS)

loh_str = input.string("LO.H", "Killzone 2 Labels", inline = "L_LO", group = g_LABELS)

lol_str = input.string("LO.L", "", inline = "L_LO", group = g_LABELS)

nah_str = input.string("NYAM.H", "Killzone 3 Labels", inline = "L_NA", group = g_LABELS)

nal_str = input.string("NYAM.L", "", inline = "L_NA", group = g_LABELS)

nlh_str = input.string("NYL.H", "Killzone 4 Labels", inline = "L_NL", group = g_LABELS)

nll_str = input.string("NYL.L", "", inline = "L_NL", group = g_LABELS)

nph_str = input.string("NYPM.H", "Killzone 5 Labels", inline = "L_NP", group = g_LABELS)

npl_str = input.string("NYPM.L", "", inline = "L_NP", group = g_LABELS)

kzp_style_inp = input.string('Solid', "Pivot Style", options = ['Solid', 'Dotted', 'Dashed'], inline = "KZP", group = g_LABELS)

kzp_width = input.int(1, "", inline = "KZP", group = g_LABELS)

kzm_style_inp = input.string('Dotted', "Midpoint Style", options = ['Solid', 'Dotted', 'Dashed'], inline = "KZM", group = g_LABELS)

kzm_width = input.int(1, "", inline = "KZM", group = g_LABELS)

var g_RNG = "Sessions - Killzone Range"

show_range = input.bool(false, "Show Killzone Range", group = g_RNG)

show_range_avg = input.bool(true, "Show Average", group = g_RNG)

range_avg = input.int(5, "Average Length", 0, group = g_RNG)

range_pos_inp = input.string('Top Right', "Table Position", options = ['Bottom Center', 'Bottom Left', 'Bottom Right', 'Middle Center', 'Middle Left', 'Middle Right', 'Top Center', 'Top Left', 'Top Right'], group = g_RNG)

range_size_inp = input.string('Normal', "Table Size", options = ['Auto', 'Tiny', 'Small', 'Normal', 'Large', 'Huge'], group = g_RNG)

//////////////////////////////////////////////////////////////////

// ================= SESSION TYPES ==============================

//////////////////////////////////////////////////////////////////

type kz

    string _title

    array<box> _box

    array<line> _hi_line

    array<line> _md_line

    array<line> _lo_line

    array<label> _hi_label

    array<label> _lo_label

    array<bool> _hi_valid

    array<bool> _md_valid

    array<bool> _lo_valid

    array<float> _range_store

    float _range_current

type kz_helper

    kz _kz

    string session

    color c

    string box_txt

    string hi_txt

    string lo_txt

//////////////////////////////////////////////////////////////////

// ================= SESSION HELPER FUNCTIONS ===================

//////////////////////////////////////////////////////////////////

get_line_type_sess(string _style) =>

    switch _style

        "Solid" => line.style_solid

        "Dotted" => line.style_dotted

        "Dashed" => line.style_dashed

get_size_sess(string x) =>

    switch x

        "Auto" => size.auto

        "Tiny" => size.tiny

        "Small" => size.small

        "Normal" => size.normal

        "Large" => size.large

        "Huge" => size.huge

get_table_pos_sess(string pos) =>

    switch pos

        "Bottom Center" => position.bottom_center

        "Bottom Left" => position.bottom_left

        "Bottom Right" => position.bottom_right

        "Middle Center" => position.middle_center

        "Middle Left" => position.middle_left

        "Middle Right" => position.middle_right

        "Top Center" => position.top_center

        "Top Left" => position.top_left

        "Top Right" => position.top_right

get_box_color(color c) => color.new(c, box_transparency)

get_text_color(color c) => color.new(c, text_transparency)

//////////////////////////////////////////////////////////////////

// ================= SESSION VARIABLES ==========================

//////////////////////////////////////////////////////////////////

var tf_limit_is_equal_or_more_chart_tf = timeframe.in_seconds('') <= timeframe.in_seconds(tf_limit)

t_co = not na(time("", cutoff, gmt_tz))

var sess_transparent = #ffffff00

var ext_current = ext_which == 'Most Recent'

var ext_past = ext_pivots == 'Past Mitigation'

//////////////////////////////////////////////////////////////////

// ================= INITIALIZE KILLZONES =========================

//////////////////////////////////////////////////////////////////

initKZ() =>

    array<kz_helper> res = array.new<kz_helper>()

    if use_asia

        res.push(kz_helper.new(
             kz.new(as_txt, array.new_box(), array.new_line(), array.new_line(), array.new_line(), array.new_label(), array.new_label(), array.new_bool(), array.new_bool(), array.new_bool(), array.new_float()),
             asia, as_color, as_txt, ash_str, asl_str))

    if use_london

        res.push(kz_helper.new(
             kz.new(lo_txt, array.new_box(), array.new_line(), array.new_line(), array.new_line(), array.new_label(), array.new_label(), array.new_bool(), array.new_bool(), array.new_bool(), array.new_float()),
             london, lo_color, lo_txt, loh_str, lol_str))

    if use_nyam

        res.push(kz_helper.new(
             kz.new(na_txt, array.new_box(), array.new_line(), array.new_line(), array.new_line(), array.new_label(), array.new_label(), array.new_bool(), array.new_bool(), array.new_bool(), array.new_float()),
             nyam, na_color, na_txt, nah_str, nal_str))

    if use_nylu

        res.push(kz_helper.new(
             kz.new(nl_txt, array.new_box(), array.new_line(), array.new_line(), array.new_line(), array.new_label(), array.new_label(), array.new_bool(), array.new_bool(), array.new_bool(), array.new_float()),
             nylu, nl_color, nl_txt, nlh_str, nll_str))

    if use_nypm

        res.push(kz_helper.new(
             kz.new(np_txt, array.new_box(), array.new_line(), array.new_line(), array.new_line(), array.new_label(), array.new_label(), array.new_bool(), array.new_bool(), array.new_bool(), array.new_float()),
             nypm, np_color, np_txt, nph_str, npl_str))

    res

var array<kz_helper> _kz = initKZ()

del_kz(kz k) =>

    if k._box.size() > max_days

        k._box.pop().delete()

    if k._hi_line.size() > max_days

        k._hi_line.pop().delete()

        k._lo_line.pop().delete()

        k._hi_valid.pop()

        k._lo_valid.pop()

        if show_midpoints

            k._md_line.pop().delete()

            k._md_valid.pop()

    if k._hi_label.size() > max_days

        k._hi_label.pop().delete()

        k._lo_label.pop()

update_price_string(label L, float P) =>

    S = L.get_text()

    pre = str.substring(S, 0, str.pos(S, " "))

    str.trim(pre)

    L.set_text(str.format("{0} ({1})", pre, P))

adjust_in_kz(kz kz_obj, bool t) =>

    if t

        kzBox0 = kz_obj._box.get(0)

        kzBox0.set_right(time)

        newTop = math.max(kzBox0.get_top(), high)

        kzBox0.set_top(newTop)

        newBottom = math.min(kzBox0.get_bottom(), low)

        kzBox0.set_bottom(newBottom)

        kz_obj._range_current := newTop - newBottom

        if show_pivots and kz_obj._hi_line.size() > 0

            kzHiLine0 = kz_obj._hi_line.get(0)

            kzHiLine0.set_x2(time)

            if high > kzHiLine0.get_y1()

                kzHiLine0.set_xy1(time, high)

                kzHiLine0.set_xy2(time, high)

            kzLoLine0 = kz_obj._lo_line.get(0)

            kzLoLine0.set_x2(time)

            if low < kzLoLine0.get_y1()

                kzLoLine0.set_xy1(time, low)

                kzLoLine0.set_xy2(time, low)

            if show_midpoints

                kzMidLine0 = kz_obj._md_line.get(0)

                kzMidLine0.set_x2(time)

                kzMidLine0.set_xy1(time, math.avg(kzHiLine0.get_y2(), kzLoLine0.get_y2()))

                kzMidLine0.set_xy2(time, math.avg(kzHiLine0.get_y2(), kzLoLine0.get_y2()))

        if show_labels and kz_obj._hi_label.size() > 0

            if label_right

                kz_obj._hi_label.get(0).set_x(time)

                kz_obj._lo_label.get(0).set_x(time)

            if high > kz_obj._hi_label.get(0).get_y()

                kz_obj._hi_label.get(0).set_xy(time, high)

                if label_price

                    update_price_string(kz_obj._hi_label.get(0), high)

            if low < kz_obj._lo_label.get(0).get_y()

                kz_obj._lo_label.get(0).set_xy(time, low)

                if label_price

                    update_price_string(kz_obj._lo_label.get(0), low)

adjust_out_kz(kz kz_obj, bool t, bool t_prev) =>

    boxCount = kz_obj._box.size()

    if not t and boxCount > 0

        if t_prev

            array.unshift(kz_obj._range_store, kz_obj._range_current)

            if kz_obj._range_store.size() > range_avg

                kz_obj._range_store.pop()

    if show_pivots and boxCount > 0

        for i = 0 to boxCount - 1

            if not ext_current or i == 0

                kzHiValid = kz_obj._hi_valid.get(i)

                if ext_past or kzHiValid

                    kz_obj._hi_line.get(i).set_x2(time)

                    if show_labels and label_right

                        kz_obj._hi_label.get(i).set_x(time)

                if kzHiValid and high > kz_obj._hi_line.get(i).get_y1()

                    if use_alerts and i == 0

                        alert('Broke ' + kz_obj._title + ' High', alert.freq_once_per_bar)

                    kz_obj._hi_valid.set(i, false)

                    if show_labels and label_right

                        kz_obj._hi_label.get(i).set_style(label.style_label_down)

                else if use_cutoff ? t_co : false

                    kz_obj._hi_valid.set(i, false)

                kzLoValid = kz_obj._lo_valid.get(i)

                if ext_past or kzLoValid

                    kz_obj._lo_line.get(i).set_x2(time)

                    if show_labels and label_right

                        kz_obj._lo_label.get(i).set_x(time)

                if kzLoValid and low < kz_obj._lo_line.get(i).get_y1()

                    if use_alerts and i == 0

                        alert("Broke " + kz_obj._title + " Low", alert.freq_once_per_bar)

                    kz_obj._lo_valid.set(i, false)

                    if show_labels and label_right

                        kz_obj._lo_label.get(i).set_style(label.style_label_up)

                else if use_cutoff ? t_co : false

                    kz_obj._lo_valid.set(i, false)

                if show_midpoints and not t

                    if stop_midpoints ? kz_obj._md_valid.get(i) : true

                        kz_obj._md_line.get(i).set_x2(time)

                        if kz_obj._md_valid.get(i) and low <= kz_obj._md_line.get(i).get_y1() and high >= kz_obj._md_line.get(i).get_y1()

                            kz_obj._md_valid.set(i, false)

            else

                break

method manage_kz(kz_helper this) =>

    kz_obj = this._kz

    c = this.c

    box_txt = this.box_txt

    hi_txt = this.hi_txt

    lo_txt = this.lo_txt

    if tf_limit_is_equal_or_more_chart_tf

        t = not na(time("", this.session, gmt_tz))

        t_prev = not na(time("", this.session, gmt_tz, bars_back=1))

        if t and not t_prev

            _c = get_box_color(c)

            _t = get_text_color(c)

            kz_obj._box.unshift(box.new(time, high, time, low,
                 xloc=xloc.bar_time,
                 border_color=show_kz ? _c : na,
                 bgcolor=show_kz ? _c : na,
                 text=show_kz and show_kz_text ? box_txt : na,
                 text_color=_t))

            if show_pivots

                kz_obj._hi_line.unshift(line.new(time, high, time, high,
                     xloc=xloc.bar_time,
                     style=get_line_type_sess(kzp_style_inp),
                     color=c,
                     width=kzp_width))

                kz_obj._lo_line.unshift(line.new(time, low, time, low,
                     xloc=xloc.bar_time,
                     style=get_line_type_sess(kzp_style_inp),
                     color=c,
                     width=kzp_width))

                if show_midpoints

                    kz_obj._md_line.unshift(line.new(time, math.avg(high, low), time, math.avg(high, low),
                         xloc=xloc.bar_time,
                         style=get_line_type_sess(kzm_style_inp),
                         color=c,
                         width=kzm_width))

                    array.unshift(kz_obj._md_valid, true)

                array.unshift(kz_obj._hi_valid, true)

                array.unshift(kz_obj._lo_valid, true)

                if show_labels

                    _hi_txt = label_price ? str.format('{0} ({1})', hi_txt, high) : hi_txt

                    _lo_txt = label_price ? str.format('{0} ({1})', lo_txt, low) : lo_txt

                    if label_right

                        kz_obj._hi_label.unshift(label.new(time, high, _hi_txt,
                             xloc=xloc.bar_time,
                             color=sess_transparent,
                             textcolor=txt_color,
                             style=label.style_label_left,
                             size=get_size_sess(lbl_size_sess)))

                        kz_obj._lo_label.unshift(label.new(time, low, _lo_txt,
                             xloc=xloc.bar_time,
                             color=sess_transparent,
                             textcolor=txt_color,
                             style=label.style_label_left,
                             size=get_size_sess(lbl_size_sess)))

                    else

                        kz_obj._hi_label.unshift(label.new(time, high, _hi_txt,
                             xloc=xloc.bar_time,
                             color=sess_transparent,
                             textcolor=txt_color,
                             style=label.style_label_down,
                             size=get_size_sess(lbl_size_sess)))

                        kz_obj._lo_label.unshift(label.new(time, low, _lo_txt,
                             xloc=xloc.bar_time,
                             color=sess_transparent,
                             textcolor=txt_color,
                             style=label.style_label_up,
                             size=get_size_sess(lbl_size_sess)))

            del_kz(kz_obj)

        adjust_in_kz(kz_obj, t)

        adjust_out_kz(kz_obj, t, t_prev)

//////////////////////////////////////////////////////////////////

// ================= KILLZONE EXECUTION ==========================

//////////////////////////////////////////////////////////////////

for [_, value] in _kz

    manage_kz(value)

get_min_days_stored() =>

    store = array.new_int()

    for [_, value] in _kz

        int tmpStoreSize = value._kz._range_store.size()

        if tmpStoreSize > 0

            store.push(tmpStoreSize)

    store.min()

method set_table(table tbl, kz kz_obj, int row, string txt, bool t, color col) =>

    table.cell(tbl, 0, row, txt,
         text_size=get_size_sess(range_size_inp),
         bgcolor=get_box_color(col),
         text_color=txt_color)

    table.cell(tbl, 1, row, str.tostring(kz_obj._range_current),
         text_size=get_size_sess(range_size_inp),
         bgcolor=t ? get_box_color(col) : na,
         text_color=txt_color)

    if show_range_avg

        table.cell(tbl, 2, row, str.tostring(kz_obj._range_store.avg()),
             text_size=get_size_sess(range_size_inp),
             text_color=txt_color)

if show_range and barstate.islast

    var tbl = table.new(get_table_pos_sess(range_pos_inp), 10, 10,
         chart.bg_color, chart.fg_color, 2, chart.fg_color, 1)

    table.cell(tbl, 0, 0, "Killzone",
         text_size=get_size_sess(range_size_inp),
         text_color=txt_color)

    table.cell(tbl, 1, 0, "Range",
         text_size=get_size_sess(range_size_inp),
         text_color=txt_color)

    if show_range_avg

        table.cell(tbl, 2, 0,
             "Avg (" + str.tostring(get_min_days_stored()) + ")",
             text_size=get_size_sess(range_size_inp),
             text_color=txt_color)

    for [index, value] in _kz

        set_table(tbl, value._kz, index + 1, value.box_txt,
             not na(time("", value.session, gmt_tz)), value.c)

//////////////////////////////////////////////////////////////////

// ================= DAY / WEEK / MONTH OPEN LINES ==============

//////////////////////////////////////////////////////////////////

var string grp_dwm = "D/W/M Opening Prices ━━━━━━━━━━━━━━━━━━━━━━━━━"

show_d_open = input.bool(true, "Show Daily Open", group = grp_dwm)

d_open_color = input.color(color.blue, "Daily Color", group = grp_dwm)

show_w_open = input.bool(true, "Show Weekly Open", group = grp_dwm)

w_open_color = input.color(#089981, "Weekly Color", group = grp_dwm)

show_m_open = input.bool(true, "Show Monthly Open", group = grp_dwm)

m_open_color = input.color(color.red, "Monthly Color", group = grp_dwm)

dwm_line_style = input.string("Solid", "Line Style",
     options = ["Solid", "Dotted", "Dashed"], group = grp_dwm)

dwm_line_width = input.int(1, "Line Width", minval = 1, maxval = 4, group = grp_dwm)

dwm_max_lines = input.int(3, "Max Lines to Show", minval = 1, maxval = 10, group = grp_dwm)

f_dwm_style(string s) =>

    switch s

        "Dotted" => line.style_dotted

        "Dashed" => line.style_dashed

        => line.style_solid

var transparent_color = #ffffff00

// --- Daily Open ---

var line[] d_open_lines = array.new_line()

var label[] d_open_labels = array.new_label()

d_open_val = request.security(syminfo.tickerid, "D", open, lookahead = barmerge.lookahead_on)

d_open_t = request.security(syminfo.tickerid, "D", time, lookahead = barmerge.lookahead_on)

new_day = ta.change(d_open_t) != 0

if show_d_open

    if d_open_lines.size() > 0

        d_open_lines.get(0).set_x2(time)

        d_open_labels.get(0).set_x(time)

    if new_day

        d_open_lines.unshift(line.new(time, d_open_val, time, d_open_val,
             xloc = xloc.bar_time,
             style = f_dwm_style(dwm_line_style),
             width = dwm_line_width,
             color = d_open_color))

        d_open_labels.unshift(label.new(time, d_open_val, "D Open",
             xloc = xloc.bar_time,
             style = label.style_label_left,
             color = transparent_color,
             textcolor = d_open_color,
             size = size.small))

        if d_open_lines.size() > dwm_max_lines

            d_open_lines.pop().delete()

            d_open_labels.pop().delete()

// --- Weekly Open ---

var line[] w_open_lines = array.new_line()

var label[] w_open_labels = array.new_label()

w_open_val = request.security(syminfo.tickerid, "W", open, lookahead = barmerge.lookahead_on)

w_open_t = request.security(syminfo.tickerid, "W", time, lookahead = barmerge.lookahead_on)

new_week = ta.change(w_open_t) != 0

if show_w_open

    if w_open_lines.size() > 0

        w_open_lines.get(0).set_x2(time)

        w_open_labels.get(0).set_x(time)

    if new_week

        w_open_lines.unshift(line.new(time, w_open_val, time, w_open_val,
             xloc = xloc.bar_time,
             style = f_dwm_style(dwm_line_style),
             width = dwm_line_width,
             color = w_open_color))

        w_open_labels.unshift(label.new(time, w_open_val, "W Open",
             xloc = xloc.bar_time,
             style = label.style_label_left,
             color = transparent_color,
             textcolor = w_open_color,
             size = size.small))

        if w_open_lines.size() > dwm_max_lines

            w_open_lines.pop().delete()

            w_open_labels.pop().delete()

// --- Monthly Open ---

var line[] m_open_lines = array.new_line()

var label[] m_open_labels = array.new_label()

m_open_val = request.security(syminfo.tickerid, "M", open, lookahead = barmerge.lookahead_on)

m_open_t = request.security(syminfo.tickerid, "M", time, lookahead = barmerge.lookahead_on)

new_month = ta.change(m_open_t) != 0

if show_m_open

    if m_open_lines.size() > 0

        m_open_lines.get(0).set_x2(time)

        m_open_labels.get(0).set_x(time)

    if new_month

        m_open_lines.unshift(line.new(time, m_open_val, time, m_open_val,
             xloc = xloc.bar_time,
             style = f_dwm_style(dwm_line_style),
             width = dwm_line_width,
             color = m_open_color))

        m_open_labels.unshift(label.new(time, m_open_val, "M Open",
             xloc = xloc.bar_time,
             style = label.style_label_left,
             color = transparent_color,
             textcolor = m_open_color,
             size = size.small))

        if m_open_lines.size() > dwm_max_lines

            m_open_lines.pop().delete()

            m_open_labels.pop().delete()
````
