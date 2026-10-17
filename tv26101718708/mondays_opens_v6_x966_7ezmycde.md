# Mondays | Opens V6 X966 

- url: https://www.tradingview.com/script/7EzmYcDe/
- type: indicator
- pine_id: PUB;3be7940d90844f008f4bff607c1d8935
- version: 1.0

## Description

Mondays | Opens V6 X966

OVERVIEW
This indicator maps the Monday range and uses it as a weekly reference frame. It then tracks how price interacts with that range for the rest of the week, together with the week's highest-volume bar.

CREDITS
This is a Pine Script v6 rebuild and extension of "Mondays | Opens" by Jo-Pippin, published under the Mozilla Public License 2.0. All credit for the original concept goes to the original author. This version is open-source under the same license.

WHAT'S NEW IN THIS VERSION
- Full Pine Script v6 migration and repair.
- Sweep and Acceptance markers evaluated on confirmed bar close.
- Weekly max-volume bar tracking with lower-timeframe price refinement.
- Pre-anchor Order Block with a mitigation lifecycle.
- Confirmed-close alerts with duplicate suppression.
- Safer behavior across symbols, sessions and timeframes.

COMPONENTS
1. Monday High / Low
   Monday's range is extended across the rest of the week, with price labels.

2. Monday Opening Range (OR)
   The range of the first Monday session bar(s) (00:00-00:05, exchange time), shaded for the week. The "OR Mid" label shows its midpoint.

3. Fibonacci 0.382 / 0.618
   Measured from the Monday High down to the Monday Low. The zone between them is highlighted as the equilibrium area.

4. Sweep & Acceptance (evaluated after Monday, on confirmed bar close)
   - Sweep (x): the bar trades beyond the Monday High/Low but closes back inside the range.
   - Acceptance (triangle): the bar closes beyond the Monday High/Low.
   - Optional latch: shows only the first event until price closes back inside the range.

5. Week Max-Volume Bar
   The highest-volume chart bar of the current week, highlighted and labeled by weekday group: Early (Mon-Tue), Mid (Wed), Late (Thu-Fri) or Weekend (Sat-Sun).

6. LTF Max-Volume Price
   The close of the lower-timeframe intrabar with the highest volume inside the week's max-volume bar. An optional zone is sized in ticks.
   Note: this is NOT a Volume Profile POC.

7. Order Block (OB)
   Defined here as the high/low range of the N bars immediately preceding the week's max-volume bar.
   It is marked "MIT" (mitigated) after a close beyond its opposite side: below the low for a bullish anchor bar, above the high for a bearish one.

8. Optional extras
   Day names, day separators, weekly open markers, and weekly/daily summary candles drawn to the right of price.

ALERTS
Monday High/Low Sweep, Bull/Bear Acceptance, Weekly Max Vol Shifted, Price Crossed LTF Max-Vol Price, and OB Mitigated.
All alerts are evaluated on confirmed bar close. Recreate existing alerts after changing any settings.

TIMEFRAMES
By default the indicator runs on 3-15 minute charts. Disable "Limit Indicator to 3-15m Charts" to also use 2m and higher timeframes. 1m, seconds and tick charts are not supported for drawings and signals.

LIMITATIONS & NOTES
- Days and sessions follow the exchange timezone of the symbol.
- Sweep/Acceptance markers do not repaint once the bar closes. The Monday range, the max-volume anchor and the OB still develop in real time until their defining bars are complete.
- Lower-timeframe data depends on availability and on your plan's intrabar limit. Where no intrabar data exists (including on 1m charts), the LTF Max-Volume Price falls back to the chart bar's close.
- On non-standard charts (Heikin Ashi, Renko, etc.), all calculations use synthetic prices. Standard candles are recommended.
- On symbols whose week starts on Sunday (e.g. FX), the Sunday session before Monday is hidden.

This script is a charting and analysis tool. It does not provide trade signals with any measured performance, and it is not financial advice.

---

نبذة مختصرة
مؤشر يرسم نطاق يوم الاثنين (القمة والقاع ونطاق الافتتاح ومستويات فيبوناتشي 0.382 و0.618) ويمدّه على بقية الأسبوع.
يرصد المؤشر بعد يوم الاثنين حالتين عند إغلاق الشمعة: السحب (Sweep)، وهو اختراق حدود النطاق ثم الإغلاق داخله، والقبول (Acceptance)، وهو الإغلاق خارج النطاق.
يحدد المؤشر أيضاً أعلى شمعة حجماً في الأسبوع، وسعر أعلى حجم على الفريم الأدنى داخلها، وكتلة الأوامر (OB) التي تسبقها مع تتبّع إبطالها.
هذه نسخة Pine v6 مطوّرة عن مؤشر Jo-Pippin الأصلي، ومنشورة مفتوحة المصدر بترخيص MPL 2.0. المؤشر أداة تحليل وليس نصيحة مالية.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jo-Pippin — original "Mondays | Opens"
// Modifications: Pine v6 repair & X966 Lean v2.0.2 upgrade by baselalanze — distributed under the same MPL 2.0 license

//@version=6
// X966-Version: 2.0.2
indicator(title = "Mondays | Opens V6 (X966 Upgraded)", shorttitle = "Mondays | Opens V6", overlay = true)

// ==========================================
// 1. مدخلات الإعدادات والخيارات (Settings)
// ==========================================
grp_monday  = "Monday & Session Settings"
grp_dynamic = "Monday Range Dynamics (Sweep & Acceptance)"
grp_volume  = "Volume, Max-Vol Price & OB Lifecycle"
grp_colors  = "Color Palette & Styling"

// خيارات العرض والنصوص
inp_text_size       = input.string("Small", options = ["Tiny", "Small", "Normal"], title = "Text Size", group = grp_monday)
textSize            = inp_text_size == "Tiny" ? size.tiny : inp_text_size == "Small" ? size.small : size.normal

inp_line_style      = input.string("Dotted", options = ["Dotted", "Solid", "Dashed"], title = "Day Divider Line Style", group = grp_monday)
line_st             = inp_line_style == "Solid" ? line.style_solid : inp_line_style == "Dotted" ? line.style_dotted : line.style_dashed

inp_line_style_poc  = input.string("Solid", options = ["Dotted", "Solid", "Dashed"], title = "Max-Vol Price Line Style", group = grp_monday)
line_st_poc         = inp_line_style_poc == "Solid" ? line.style_solid : inp_line_style_poc == "Dotted" ? line.style_dotted : line.style_dashed

inp_line_style_fib  = input.string("Dashed", options = ["Dotted", "Solid", "Dashed"], title = "Fib Line Style", group = grp_monday)
line_st_fib         = inp_line_style_fib == "Solid" ? line.style_solid : inp_line_style_fib == "Dotted" ? line.style_dotted : line.style_dashed
fib_width           = input.int(1, "Fib Line Width", minval = 1, maxval = 4, group = grp_monday)

show_openingR       = input.string("Entire Week", options = ["Only on Monday", "Entire Week", "None", "Tue-Sun"], title = "Show Monday Opening Range on", group = grp_monday)
show_monday_HL      = input.string("Entire Week", options = ["Entire Week", "Only on Monday"], title = "Show Monday HL on", group = grp_monday)
dont_show_monday_HL = show_monday_HL != "Only on Monday"

show_mpoc           = input.bool(true,  "Show LTF Max-Volume Price Line", tooltip = "Close price of the lower-timeframe intrabar with the highest volume inside the week's max-volume chart bar. This is NOT a Volume Profile POC. On 1m charts (no lower timeframe used) it falls back to the chart bar close.", group = grp_monday)
show_mpoc_zone      = input.bool(true,  "Show LTF Max-Volume Price Zone", group = grp_monday)
show_breaks         = input.bool(true,  "Show Breaks Between Days", group = grp_monday)
show_day_labels     = input.bool(true,  "Show Day Names Labels", group = grp_monday)
show_or_labels      = input.bool(true,  "Show Opening Range Mid Label", group = grp_monday)
show_fibs           = input.bool(true,  "Show 0.618 and 0.382 Fibs", group = grp_monday)
show_fib_zone       = input.bool(true,  "Highlight 0.382 - 0.618 Equilibrium Zone", group = grp_monday)
show_fib_labels     = input.bool(true,  "Show Fib Price Labels", group = grp_monday)
show_price          = input.bool(true,  "Show Monday HL Price Labels", group = grp_monday)
show_weekly_candle  = input.bool(false, "Show Weekly Candle On the Right", group = grp_monday)
show_daily_candle   = input.bool(false, "Show Daily Candle On the Right", group = grp_monday)
i_open              = input.bool(true,  "Plot Weekly Open Marker", group = grp_monday)
limit_tf            = input.bool(true,  "Limit Indicator to 3-15m Charts", tooltip = "ON (original behavior): everything is drawn and signals/alerts are evaluated only on 3 to 15 minute charts. OFF: also enables 2m and higher timeframes. 1m, seconds and tick charts are never supported.", group = grp_monday)

// مدخلات ديناميكية النطاق وشارات الميكرو
show_sweep_acc      = input.bool(true,  "Show Sweep & Acceptance Markers", group = grp_dynamic)
latch_signals       = input.bool(true,  "Latch First Breakout Only (Anti-Clustering)", tooltip = "Prevents stacked duplicates on consecutive candles until price re-enters Monday range", group = grp_dynamic)

// مدخلات الحجم وكتلة الطلب
show_vol_candle     = input.bool(true,  "Highlight Max Volume Candle", group = grp_volume)
show_vol_class      = input.bool(true,  "Label Max-Volume Bar Timing (Day of Week)", group = grp_volume)
show_breaker        = input.bool(true,  "Show Order Block (OB)", tooltip = "OB here = the high/low range of the N bars immediately preceding the week's max-volume bar. Mitigated = a close beyond the opposite side (below the low for a bullish anchor bar, above the high for a bearish one).", group = grp_volume)
show_ob_text        = input.bool(true,  "Show Center OB Text Label", group = grp_volume)
extend_breaker      = input.bool(true,  "Track OB Lifecycle (Extend to Retest/Mitigation)", group = grp_volume)
poc_zone_ticks      = input.int(100,    "Max-Vol Zone Half-Width (Ticks)", minval = 1, maxval = 1000000, tooltip = "Half-width in symbol ticks (syminfo.mintick). 100 ticks = ±10.0 on a 0.1-tick symbol.", group = grp_volume)
breaker_back        = input.int(3,      "OB Candles Back to Include", minval = 1, maxval = 130, group = grp_volume)
weekly_ext          = input.int(50,     "Offset Weekly Candle to the Right (bars)", minval = 1, maxval = 250, group = grp_volume)
daily_ext           = input.int(30,     "Offset Daily Candle Beyond Weekly (bars)", minval = 1, maxval = 240, group = grp_volume)
wick_width          = input.int(1,      "Volume Wick Width", minval = 1, maxval = 30, group = grp_volume)
body_width          = input.int(2,      "Volume Body Width", minval = 1, maxval = 30, group = grp_volume)

// ==========================================
// 2. باليتة الألوان وتنسيق النصوص (Palette)
// ==========================================
mon_lines_col       = input.color(#38bdf8, "Monday High/Low Lines", group = grp_colors)
mon_text_col        = input.color(#f8fafc, "Monday Labels Text", group = grp_colors)
opening_r_col       = input.color(color.new(#38bdf8, 90), "Opening Range Background", group = grp_colors)
break_line_col      = input.color(color.new(#64748b, 55), "Day Separator Line", group = grp_colors)
day_label_col       = input.color(#94a3b8, "Day Names Color", group = grp_colors)
fib_color           = input.color(#e879f9, "Monday Fib Levels Color", group = grp_colors)
fib_zone_bg         = input.color(color.new(#e879f9, 92), "Equilibrium Zone Fill", group = grp_colors)
i_open_c            = input.color(#38bdf8, "Weekly Open Marker", group = grp_colors)
candle_c            = input.color(#fbbf24, "Max Volume Candle Highlight", group = grp_colors)
w_candle_c          = input.color(#94a3b8, "Side Candle Structure", group = grp_colors)
w_text_col          = input.color(#e2e8f0, "Side Candle Text", group = grp_colors)

mainpoc_c           = input.color(#f97316, "Max-Vol Price Line Color", group = grp_colors)
poc_label_col       = input.color(#fb923c, "Max-Vol Price Text Color", group = grp_colors)
poc_zone_line_col   = input.color(color.new(#f97316, 50), "Max-Vol Zone Borders", group = grp_colors)
poc_zone_bg         = input.color(color.new(#f97316, 88), "Max-Vol Zone Background", group = grp_colors)
breaker_c           = input.color(color.new(#818cf8, 20), "OB Border Color", group = grp_colors)
breaker_bg          = input.color(color.new(#818cf8, 85), "OB Background Fill", group = grp_colors)
breaker_mit_bg      = input.color(color.new(#818cf8, 95), "OB Mitigated Fill", group = grp_colors)
label_chip_bg       = input.color(color.new(#0f172a, 40), "Price Labels Background Chip", group = grp_colors)

sweep_col           = input.color(#f59e0b, "Sweep Marker Color", group = grp_colors)
accept_bull_col     = input.color(#10b981, "Bullish Acceptance Color", group = grp_colors)
accept_bear_col     = input.color(#ef4444, "Bearish Acceptance Color", group = grp_colors)

color transparent   = color.new(color.white, 100)

// ==========================================
// 3. الحسابات الزمنية وتحديد الأيام
// ==========================================
sunday_bar    = ta.barssince(dayofweek == dayofweek.sunday)
monday_bar    = ta.barssince(dayofweek == dayofweek.monday)
tuesday_bar   = ta.barssince(dayofweek == dayofweek.tuesday)
wednesday_bar = ta.barssince(dayofweek == dayofweek.wednesday)
thursday_bar  = ta.barssince(dayofweek == dayofweek.thursday)
friday_bar    = ta.barssince(dayofweek == dayofweek.friday)
saturday_bar  = ta.barssince(dayofweek == dayofweek.saturday)

bool is_target_ltf = timeframe.isminutes and (timeframe.multiplier >= 3 and timeframe.multiplier <= 15)
// نطاق الفريمات الموحّد لكل الرسومات والإشارات والتنبيهات
// 1m/ثواني/تيك مستبعدة: أسبوع كامل منها يتجاوز حد رسم 10,000 بار للخلف
bool tf_ok = is_target_ltf or (not limit_tf and not timeframe.isticks and timeframe.in_seconds() >= 120)

new_day_bar  = ta.change(time("D")) != 0
new_week_bar = ta.change(time("W")) != 0

var int countDw = 0
countDw := new_week_bar ? 1 : new_day_bar ? countDw + 1 : countDw

// تتبع الشموع الأسبوعية واليومية اللحظية
var float wo = na
var float wh = na
var float wl = na
var float wc = na
if new_week_bar
    wo := open
    wh := high
    wl := low
    wc := close
else
    wh := math.max(nz(wh, high), high)
    wl := math.min(nz(wl, low), low)
    wc := close

var float day_open = na
var float dh       = na
var float dl       = na
var float dc       = na
if new_day_bar
    day_open := open
    dh       := high
    dl       := low
    dc       := close
else
    dh := math.max(nz(dh, high), high)
    dl := math.min(nz(dl, low), low)
    dc := close

// نطاق الشموع السابقة لكل بار — يُلتقط لحظة تغيّر المرساة بدل الرجوع العميق للتاريخ
float pre_anchor_high = ta.highest(high, breaker_back)[1]
float pre_anchor_low  = ta.lowest(low, breaker_back)[1]

// تتبع ذروة الحجم الأسبوعية بكفاءة O(1) بدون حلقات
var float max_w_vol       = 0.0
var int   max_w_vol_bar   = na
var int   max_w_vol_day   = na
var float max_w_vol_open  = na
var float max_w_vol_high  = na
var float max_w_vol_low   = na
var float max_w_vol_close = na
var float anchor_poc      = na
var float breaker_high    = na
var float breaker_low     = na

bool anchor_changed = false
if new_week_bar
    max_w_vol       := nz(volume)
    max_w_vol_bar   := bar_index
    max_w_vol_day   := dayofweek
    max_w_vol_open  := open
    max_w_vol_high  := high
    max_w_vol_low   := low
    max_w_vol_close := close
    breaker_high    := pre_anchor_high
    breaker_low     := pre_anchor_low
    anchor_changed  := true
else if nz(volume) > max_w_vol
    max_w_vol       := nz(volume)
    max_w_vol_bar   := bar_index
    max_w_vol_day   := dayofweek
    max_w_vol_open  := open
    max_w_vol_high  := high
    max_w_vol_low   := low
    max_w_vol_close := close
    breaker_high    := pre_anchor_high
    breaker_low     := pre_anchor_low
    anchor_changed  := true

int vol_idx = not na(max_w_vol_bar) ? (bar_index - max_w_vol_bar) : 0

// ==========================================
// 4. حدود ومستويات نطاق يوم الاثنين
// ==========================================
var float H = 0.0
var float L = 0.0

H := new_day_bar or high > H ? high : H
L := new_day_bar or low < L  ? low  : L

color bcolor = tf_ok and dayofweek == dayofweek.monday ? mon_lines_col : transparent
plot(H, title = "Monday Step High", style = plot.style_stepline, linewidth = 1, color = bcolor)
plot(L, title = "Monday Step Low",  style = plot.style_stepline, linewidth = 1, color = bcolor)

var float monday_high = na
var float monday_low  = na

if new_week_bar
    monday_high := na
    monday_low  := na

if dayofweek == dayofweek.monday
    if new_day_bar or na(monday_high)
        monday_high := high
        monday_low  := low
    else
        monday_high := math.max(monday_high, high)
        monday_low  := math.min(monday_low, low)

// الأحد قبل الاثنين (بداية أسبوع الفوركس) يُخفى؛ الأحد بعد الاثنين (نهاية أسبوع الكريبتو) يبقى ظاهراً
bool week_ready = not (dayofweek == dayofweek.sunday and na(monday_high))

// ==========================================
// 5. Opening Range (أول جلسة 00:00-00:05 يوم الاثنين)
// ==========================================
getIB(string session_times) =>
    bool in_session = not na(time(timeframe.period, session_times))
    var float ib_h = na
    var float ib_l = na
    if in_session
        if not in_session[1] or na(ib_h)
            ib_h := high
            ib_l := low
        else
            ib_h := math.max(high, ib_h)
            ib_l := math.min(low, ib_l)
    [in_session, ib_h, ib_l]

[in_day_session, ib_high, ib_low] = getIB("0000-0005:2")

bool show_mday_or_active = show_openingR == "Tue-Sun" ? (dayofweek != dayofweek.monday) : show_openingR == "Only on Monday" ? (dayofweek == dayofweek.monday) : show_openingR == "Entire Week"

color ib_fill_col = show_mday_or_active ? opening_r_col : transparent
p_ib_h = plot(show_mday_or_active and tf_ok ? ib_high : na, title = "OR High Line", color = transparent, linewidth = 1, style = plot.style_stepline)
p_ib_l = plot(show_mday_or_active and tf_ok ? ib_low  : na, title = "OR Low Line",  color = transparent, linewidth = 1, style = plot.style_stepline)
fill(p_ib_h, p_ib_l, color = ib_fill_col, title = "OR Range Background")

only_show_monday_label_if_after_sunday       = monday_bar    < sunday_bar
only_show_tuesday_label_if_after_monday      = tuesday_bar   < monday_bar
only_show_wednesday_label_if_after_tuesday   = wednesday_bar < monday_bar
only_show_thursday_label_if_after_wednesday  = thursday_bar  < monday_bar
only_show_friday_label_if_after_thursday     = friday_bar    < monday_bar

int shift_days_to_middle = timeframe.period == "3"  ? 240 :
                           timeframe.period == "4"  ? 177 :
                           timeframe.period == "5"  ? 144 :
                           timeframe.period == "6"  ? 117 :
                           timeframe.period == "7"  ? 101 :
                           timeframe.period == "8"  ? 87  :
                           timeframe.period == "10" ? 72  :
                           timeframe.period == "15" ? 48  :
                           timeframe.isminutes      ? int(math.round(43200.0 / timeframe.in_seconds())) : 0

move_mon = dayofweek == dayofweek.monday    ? 0 : shift_days_to_middle
move_tue = dayofweek == dayofweek.tuesday   ? 0 : shift_days_to_middle
move_wed = dayofweek == dayofweek.wednesday ? 0 : shift_days_to_middle
move_thu = dayofweek == dayofweek.thursday  ? 0 : shift_days_to_middle
move_fri = dayofweek == dayofweek.friday    ? 0 : shift_days_to_middle

hide_line_tuesday   = dayofweek != dayofweek.tuesday
hide_line_wednesday = dayofweek != dayofweek.wednesday
hide_line_thursday  = dayofweek != dayofweek.thursday
hide_line_friday    = dayofweek != dayofweek.friday

// حسابات الفيبوناتشي
monday_mid_price = monday_high - monday_low
six_one_eight    = monday_high - 0.618 * monday_mid_price
three_eight_two  = monday_high - 0.382 * monday_mid_price

// ==========================================
// 6. سعر أعلى حجم على الفريم الأدنى (LTF Max-Volume Price)
// ==========================================
float current_tf_min = timeframe.in_seconds(timeframe.period) / 60
string dyn_tf = current_tf_min <= 30 ? "1" : current_tf_min <= 180 ? "5" : current_tf_min <= 480 ? "15" : current_tf_min <= 1440 ? "60" : current_tf_min <= 4320 ? "120" : "240"
// الطلب يُنفَّذ فقط عندما يكون dyn_tf أدنى فعلياً من فريم الشارت
bool ltf_ok = not timeframe.isticks and timeframe.in_seconds() > 60

float bar_poc_price = close
if ltf_ok
    [ltfSrc, ltfVolume] = request.security_lower_tf(syminfo.tickerid, dyn_tf, [close, nz(volume)])
    int ltf_n = array.size(ltfVolume)
    if ltf_n > 0 and array.size(ltfSrc) == ltf_n
        float ltf_max_vol = array.max(ltfVolume)
        int   ltf_max_idx = array.indexof(ltfVolume, ltf_max_vol)
        if ltf_max_idx >= 0
            float ltf_px = array.get(ltfSrc, ltf_max_idx)
            if not na(ltf_px)
                bar_poc_price := ltf_px

// يتحدّث فقط مع تغيّر مرساة الحجم نفسها (لا عند التساوي) — متزامن مع الشمعة والـ OB
if anchor_changed and not na(bar_poc_price)
    anchor_poc := bar_poc_price

// ==========================================
// 7. نصوص وفواصل الأيام
// ==========================================
var label lbl_mon = na
var label lbl_tue = na
var label lbl_wed = na
var label lbl_thu = na
var label lbl_fri = na

if tf_ok and show_day_labels and week_ready and not na(monday_low) and not na(monday_bar)
    label.delete(lbl_mon)
    lbl_mon := label.new(math.max(0, bar_index - (monday_bar + move_mon)), monday_low, text = "MONDAY", color = transparent, textcolor = day_label_col, size = textSize, style = label.style_label_up)

if tf_ok and show_day_labels and only_show_tuesday_label_if_after_monday and week_ready and not na(monday_low) and not na(tuesday_bar)
    label.delete(lbl_tue)
    lbl_tue := label.new(math.max(0, bar_index - (tuesday_bar + move_tue)), monday_low, text = "TUESDAY", color = transparent, textcolor = day_label_col, size = textSize, style = label.style_label_up)

if tf_ok and show_day_labels and only_show_wednesday_label_if_after_tuesday and week_ready and not na(monday_low) and not na(wednesday_bar)
    label.delete(lbl_wed)
    lbl_wed := label.new(math.max(0, bar_index - (wednesday_bar + move_wed)), monday_low, text = "WEDNESDAY", color = transparent, textcolor = day_label_col, size = textSize, style = label.style_label_up)

if tf_ok and show_day_labels and only_show_thursday_label_if_after_wednesday and week_ready and not na(monday_low) and not na(thursday_bar)
    label.delete(lbl_thu)
    lbl_thu := label.new(math.max(0, bar_index - (thursday_bar + move_thu)), monday_low, text = "THURSDAY", color = transparent, textcolor = day_label_col, size = textSize, style = label.style_label_up)

if tf_ok and show_day_labels and only_show_friday_label_if_after_thursday and week_ready and not na(monday_low) and not na(friday_bar)
    label.delete(lbl_fri)
    lbl_fri := label.new(math.max(0, bar_index - (friday_bar + move_fri)), monday_low, text = "FRIDAY", color = transparent, textcolor = day_label_col, size = textSize, style = label.style_label_up)

var line div_tue = na
var line div_wed = na
var line div_thu = na
var line div_fri = na

if tf_ok and show_breaks and only_show_tuesday_label_if_after_monday and hide_line_tuesday and week_ready and not na(monday_low) and not na(monday_high) and not na(tuesday_bar)
    line.delete(div_tue)
    div_tue := line.new(bar_index - tuesday_bar, monday_low, bar_index - tuesday_bar, monday_high, color = break_line_col, width = 1, style = line_st)

if tf_ok and show_breaks and only_show_wednesday_label_if_after_tuesday and hide_line_wednesday and week_ready and not na(monday_low) and not na(monday_high) and not na(wednesday_bar)
    line.delete(div_wed)
    div_wed := line.new(bar_index - wednesday_bar, monday_low, bar_index - wednesday_bar, monday_high, color = break_line_col, width = 1, style = line_st)

if tf_ok and show_breaks and only_show_thursday_label_if_after_wednesday and hide_line_thursday and week_ready and not na(monday_low) and not na(monday_high) and not na(thursday_bar)
    line.delete(div_thu)
    div_thu := line.new(bar_index - thursday_bar, monday_low, bar_index - thursday_bar, monday_high, color = break_line_col, width = 1, style = line_st)

if tf_ok and show_breaks and only_show_friday_label_if_after_thursday and hide_line_friday and week_ready and not na(monday_low) and not na(monday_high) and not na(friday_bar)
    line.delete(div_fri)
    div_fri := line.new(bar_index - friday_bar, monday_low, bar_index - friday_bar, monday_high, color = break_line_col, width = 1, style = line_st)

// ==========================================
// 8. مستويات وتظليل الفيبوناتشي (Equilibrium Zone)
// ==========================================
int or_pos = dayofweek == dayofweek.monday ? monday_bar : dayofweek == dayofweek.tuesday ? tuesday_bar : dayofweek == dayofweek.wednesday ? wednesday_bar : dayofweek == dayofweek.thursday ? thursday_bar : friday_bar

var line     fib_618_line = na
var line     fib_382_line = na
var linefill fib_fill     = na
var label    lbl_fib_618  = na
var label    lbl_fib_382  = na

bool can_show_fibs = tf_ok and show_fibs and (only_show_tuesday_label_if_after_monday or dayofweek != dayofweek.monday) and week_ready and not na(monday_bar) and not na(six_one_eight) and not na(three_eight_two)

if can_show_fibs
    line.delete(fib_618_line)
    line.delete(fib_382_line)
    linefill.delete(fib_fill)
    label.delete(lbl_fib_618)
    label.delete(lbl_fib_382)

    fib_618_line := line.new(bar_index - monday_bar, six_one_eight, bar_index, six_one_eight, color = fib_color, width = fib_width, style = line_st_fib)
    fib_382_line := line.new(bar_index - monday_bar, three_eight_two, bar_index, three_eight_two, color = fib_color, width = fib_width, style = line_st_fib)

    if show_fib_zone
        fib_fill := linefill.new(fib_618_line, fib_382_line, color = fib_zone_bg)

    if show_fib_labels and not na(or_pos)
        lbl_fib_618 := label.new(bar_index - or_pos, six_one_eight, text = "0.618 | " + str.tostring(six_one_eight, format.mintick), color = label_chip_bg, textcolor = fib_color, size = textSize, style = label.style_label_left)
        lbl_fib_382 := label.new(bar_index - or_pos, three_eight_two, text = "0.382 | " + str.tostring(three_eight_two, format.mintick), color = label_chip_bg, textcolor = fib_color, size = textSize, style = label.style_label_left)
else
    line.delete(fib_618_line)
    line.delete(fib_382_line)
    linefill.delete(fib_fill)
    label.delete(lbl_fib_618)
    label.delete(lbl_fib_382)

// ==========================================
// 9. نصوص ومستويات نطاق الاثنين (HL & OR)
// ==========================================
var label lbl_or    = na
var label lbl_mon_h = na
var label lbl_mon_l = na

if tf_ok and show_mday_or_active and show_or_labels and only_show_monday_label_if_after_sunday and week_ready and not na(or_pos) and not na(ib_high) and not na(ib_low)
    label.delete(lbl_or)
    float or_mid = (ib_high + ib_low) / 2
    lbl_or := label.new(bar_index - or_pos, or_mid, text = "OR Mid | " + str.tostring(or_mid, format.mintick), color = label_chip_bg, textcolor = mon_text_col, size = textSize, style = label.style_label_left)

if tf_ok and dont_show_monday_HL and only_show_monday_label_if_after_sunday and week_ready and show_price and not na(or_pos) and not na(monday_high) and not na(monday_low)
    label.delete(lbl_mon_h)
    label.delete(lbl_mon_l)
    lbl_mon_h := label.new(bar_index - or_pos, monday_high, text = "H | " + str.tostring(monday_high, format.mintick), color = label_chip_bg, textcolor = mon_lines_col, size = textSize, style = label.style_label_left)
    lbl_mon_l := label.new(bar_index - or_pos, monday_low,  text = "L | " + str.tostring(monday_low,  format.mintick), color = label_chip_bg, textcolor = mon_lines_col, size = textSize, style = label.style_label_left)

var line mon_h_line = na
var line mon_l_line = na

if tf_ok and dont_show_monday_HL and only_show_tuesday_label_if_after_monday and week_ready and not na(monday_bar) and not na(monday_high) and not na(monday_low)
    line.delete(mon_h_line)
    line.delete(mon_l_line)
    mon_h_line := line.new(bar_index - monday_bar, monday_high, bar_index, monday_high, color = mon_lines_col, width = 1, style = line.style_solid)
    mon_l_line := line.new(bar_index - monday_bar, monday_low,  bar_index, monday_low,  color = mon_lines_col, width = 1, style = line.style_solid)

// ==========================================
// 10. كاشف ديناميكية النطاق (Micro-Glyphs & First-Event Latch)
// ==========================================
bool in_post_monday = tf_ok and (dayofweek != dayofweek.monday) and not na(monday_high) and not na(monday_low)

var bool upper_accepted = false
var bool lower_accepted = false
var bool high_swept     = false
var bool low_swept      = false

if new_week_bar
    upper_accepted := false
    lower_accepted := false
    high_swept     := false
    low_swept      := false

// عودة السعر داخل نطاق الاثنين تعيد ضبط القفل
if not na(monday_high) and not na(monday_low)
    if close <= monday_high and close >= monday_low
        upper_accepted := false
        lower_accepted := false
    if high < monday_high
        high_swept := false
    if low > monday_low
        low_swept := false

// شروط الاكتشاف المؤكدة عند إغلاق الشمعة
bool raw_upper_sweep = in_post_monday and (high > monday_high) and (close <= monday_high) and barstate.isconfirmed
bool raw_lower_sweep = in_post_monday and (low < monday_low)   and (close >= monday_low)  and barstate.isconfirmed

bool raw_upper_accept = in_post_monday and (close > monday_high) and barstate.isconfirmed
bool raw_lower_accept = in_post_monday and (close < monday_low)  and barstate.isconfirmed

// الإشارات المفلترة بواسطة القفل
bool upper_sweep_sig  = raw_upper_sweep  and (not latch_signals or not high_swept)
bool lower_sweep_sig  = raw_lower_sweep  and (not latch_signals or not low_swept)
bool upper_accept_sig = raw_upper_accept and (not latch_signals or not upper_accepted)
bool lower_accept_sig = raw_lower_accept and (not latch_signals or not lower_accepted)

// تحديث حالة القفل
if upper_sweep_sig
    high_swept := true
if lower_sweep_sig
    low_swept := true
if upper_accept_sig
    upper_accepted := true
if lower_accept_sig
    lower_accepted := true

plotshape(show_sweep_acc and upper_sweep_sig, title = "High Liquidity Sweep", style = shape.xcross,      location = location.abovebar, color = sweep_col,       size = size.tiny)
plotshape(show_sweep_acc and lower_sweep_sig, title = "Low Liquidity Sweep",  style = shape.xcross,      location = location.belowbar, color = sweep_col,       size = size.tiny)

plotshape(show_sweep_acc and upper_accept_sig, title = "Bullish Acceptance", style = shape.triangleup,   location = location.belowbar, color = accept_bull_col, size = size.tiny)
plotshape(show_sweep_acc and lower_accept_sig, title = "Bearish Acceptance", style = shape.triangledown, location = location.abovebar, color = accept_bear_col, size = size.tiny)

// ==========================================
// 11. تمييز شمعة الحجم وتصنيف يومها
// ==========================================
var line  candle_body    = na
var line  candle_wick    = na
var label lbl_vol_timing = na

string vol_timing_desc = switch max_w_vol_day
    dayofweek.monday    => "Early (Mon-Tue)"
    dayofweek.tuesday   => "Early (Mon-Tue)"
    dayofweek.wednesday => "Mid (Wed)"
    dayofweek.thursday  => "Late (Thu-Fri)"
    dayofweek.friday    => "Late (Thu-Fri)"
    dayofweek.saturday  => "Weekend (Sat-Sun)"
    dayofweek.sunday    => "Weekend (Sat-Sun)"
    => "n/a"

if tf_ok and show_vol_candle and not na(max_w_vol_open)
    line.delete(candle_body)
    line.delete(candle_wick)
    label.delete(lbl_vol_timing)

    candle_body := line.new(bar_index - vol_idx, max_w_vol_open, bar_index - vol_idx, max_w_vol_close, color = candle_c, width = body_width)
    candle_wick := line.new(bar_index - vol_idx, max_w_vol_high, bar_index - vol_idx, max_w_vol_low,   color = candle_c, width = wick_width)

    if show_vol_class
        lbl_vol_timing := label.new(bar_index - vol_idx, max_w_vol_high, text = "Week Max Vol: " + vol_timing_desc, color = label_chip_bg, textcolor = candle_c, size = textSize, style = label.style_label_down)

// ==========================================
// 12. الشموع الجانبية (Weekly & Daily Side Candles)
// ==========================================
var line  w_candle_wick  = na
var line  w_candle_close = na
var line  w_candle_open  = na
var label w_close_lbl    = na
var label w_high_lbl     = na
var label w_low_lbl      = na
var label w_open_lbl     = na

if tf_ok and show_weekly_candle and not na(wh) and not na(wl)
    line.delete(w_candle_wick)
    line.delete(w_candle_close)
    line.delete(w_candle_open)
    label.delete(w_close_lbl)
    label.delete(w_high_lbl)
    label.delete(w_low_lbl)
    label.delete(w_open_lbl)

    int w_x = bar_index + weekly_ext
    w_candle_wick  := line.new(w_x, wh, w_x, wl, color = w_candle_c, width = 1)
    w_candle_close := line.new(w_x, wc, w_x + 3, wc, color = w_candle_c, width = 1)
    w_candle_open  := line.new(w_x - 3, wo, w_x, wo, color = w_candle_c, width = 1)

    w_close_lbl := label.new(w_x + 3, wc, text = "wc " + str.tostring(wc, format.mintick), color = transparent, textcolor = w_text_col, size = textSize, style = label.style_label_left)
    w_high_lbl  := label.new(w_x,     wh, text = "wh " + str.tostring(wh, format.mintick), color = transparent, textcolor = w_text_col, size = textSize, style = label.style_label_down)
    w_low_lbl   := label.new(w_x,     wl, text = "wl " + str.tostring(wl, format.mintick), color = transparent, textcolor = w_text_col, size = textSize, style = label.style_label_up)
    w_open_lbl  := label.new(w_x - 3, wo, text = "wo " + str.tostring(wo, format.mintick), color = transparent, textcolor = w_text_col, size = textSize, style = label.style_label_right)

var line  d_candle_wick  = na
var line  d_candle_close = na
var line  d_candle_open  = na
var label d_close_lbl    = na
var label d_high_lbl     = na
var label d_low_lbl      = na
var label d_open_lbl     = na

if tf_ok and show_daily_candle and not na(dh) and not na(dl)
    line.delete(d_candle_wick)
    line.delete(d_candle_close)
    line.delete(d_candle_open)
    label.delete(d_close_lbl)
    label.delete(d_high_lbl)
    label.delete(d_low_lbl)
    label.delete(d_open_lbl)

    // أقصى إزاحة مستقبلية: 250 + 240 + 3 = 493 بار (< حد 500)
    int d_x = bar_index + weekly_ext + daily_ext
    d_candle_wick  := line.new(d_x, dh, d_x, dl, color = w_candle_c, width = 1)
    d_candle_close := line.new(d_x, dc, d_x + 3, dc, color = w_candle_c, width = 1)
    d_candle_open  := line.new(d_x - 3, day_open, d_x, day_open, color = w_candle_c, width = 1)

    d_close_lbl := label.new(d_x + 3, dc, text = "dc " + str.tostring(dc, format.mintick), color = transparent, textcolor = w_text_col, size = textSize, style = label.style_label_left)
    d_high_lbl  := label.new(d_x,     dh, text = "dh " + str.tostring(dh, format.mintick), color = transparent, textcolor = w_text_col, size = textSize, style = label.style_label_down)
    d_low_lbl   := label.new(d_x,     dl, text = "dl " + str.tostring(dl, format.mintick), color = transparent, textcolor = w_text_col, size = textSize, style = label.style_label_up)
    d_open_lbl  := label.new(d_x - 3, day_open, text = "do " + str.tostring(day_open, format.mintick), color = transparent, textcolor = w_text_col, size = textSize, style = label.style_label_right)

// ==========================================
// 13. خط ومنطقة سعر أعلى حجم (LTF Max-Volume Price)
// ==========================================
var line     ltf_poc           = na
var label    ltf_poc_label     = na
var line     poc_zone_top      = na
var line     poc_zone_bottom   = na
var linefill linefill_poc_zone = na

float active_poc     = not na(anchor_poc) ? anchor_poc : bar_poc_price
float poc_half_width = poc_zone_ticks * syminfo.mintick

if tf_ok and show_mpoc and not na(active_poc)
    line.delete(ltf_poc)
    label.delete(ltf_poc_label)
    ltf_poc       := line.new(bar_index - vol_idx, active_poc, bar_index, active_poc, color = mainpoc_c, width = 1, style = line_st_poc)
    ltf_poc_label := label.new(bar_index - vol_idx, active_poc, text = "LTF Max-Vol: " + str.tostring(active_poc, format.mintick), color = label_chip_bg, style = label.style_label_right, textcolor = poc_label_col, size = textSize)

if tf_ok and show_mpoc_zone and not na(active_poc)
    line.delete(poc_zone_top)
    line.delete(poc_zone_bottom)
    linefill.delete(linefill_poc_zone)
    poc_zone_top      := line.new(bar_index - vol_idx, active_poc + poc_half_width, bar_index, active_poc + poc_half_width, color = poc_zone_line_col, width = 1, style = line_st_poc)
    poc_zone_bottom   := line.new(bar_index - vol_idx, active_poc - poc_half_width, bar_index, active_poc - poc_half_width, color = poc_zone_line_col, width = 1, style = line_st_poc)
    linefill_poc_zone := linefill.new(poc_zone_top, poc_zone_bottom, color = poc_zone_bg)

// ==========================================
// 14. دورة حياة كتلة الطلب (OB Lifecycle & Center Text)
// ==========================================
var box  ob_box          = na
var bool ob_is_mitigated = false
var int  ob_mit_bar      = na

if anchor_changed
    ob_is_mitigated := false
    ob_mit_bar      := na

// فحص الكسر والإبطال (Mitigation) — يبدأ من البار التالي للمرساة
bool is_bull_anchor = max_w_vol_close >= max_w_vol_open
if not ob_is_mitigated and not na(breaker_high) and not na(breaker_low) and vol_idx > 0
    if is_bull_anchor and close < breaker_low
        ob_is_mitigated := true
        ob_mit_bar      := bar_index
    else if not is_bull_anchor and close > breaker_high
        ob_is_mitigated := true
        ob_mit_bar      := bar_index

if tf_ok and show_breaker and not na(breaker_high) and not na(breaker_low)
    box.delete(ob_box)
    int    box_left      = bar_index - (vol_idx + breaker_back)
    int    box_right     = extend_breaker ? (ob_is_mitigated ? nz(ob_mit_bar, bar_index) : bar_index) : (bar_index - vol_idx)
    color  current_bg    = ob_is_mitigated ? breaker_mit_bg : breaker_bg
    string current_style = ob_is_mitigated ? line.style_dashed : line.style_solid
    string ob_center_text = show_ob_text ? (ob_is_mitigated ? "OB [MIT]" : "OB") : ""
    color  ob_text_color  = color.new(breaker_c, 0)

    ob_box := box.new(
         left = box_left,
         top = breaker_high,
         right = box_right,
         bottom = breaker_low,
         border_color = breaker_c,
         border_style = current_style,
         border_width = 1,
         bgcolor = current_bg,
         text = ob_center_text,
         text_size = size.small,
         text_color = ob_text_color,
         text_halign = text.align_center,
         text_valign = text.align_center)

// نقاط الافتتاح الأسبوعي
plotchar(tf_ok and new_day_bar and i_open ? wo : na, title = "Open Dot", char = "•", location = location.absolute, color = i_open_c, offset = 0, size = size.tiny)
plotchar(tf_ok and new_day_bar and i_open ? wo : na, title = "Open W Tag", char = "ʷ", location = location.abovebar, color = i_open_c, offset = 0, size = size.tiny)

// ==========================================
// 15. التنبيهات — كلها مؤكدة عند إغلاق الشمعة
// ==========================================
// انتقال المرساة داخل الأسبوع فقط (لا يُطلق مع بداية كل أسبوع)
bool vol_anchor_shift = tf_ok and anchor_changed and not new_week_bar and barstate.isconfirmed
// عبور حقيقي للسعر فقط — يُستبعد البار الذي قفز فيه المستوى نفسه
bool poc_cross        = ta.cross(close, active_poc) and active_poc == active_poc[1] and tf_ok and barstate.isconfirmed
bool ob_mit_event     = tf_ok and ob_is_mitigated and not ob_is_mitigated[1] and barstate.isconfirmed

alertcondition(vol_anchor_shift, title = "Weekly Max Vol Shifted",          message = "Weekly max-volume anchor shifted to a new bar.")
alertcondition(poc_cross,        title = "Price Crossed LTF Max-Vol Price", message = "Price closed across the LTF Max-Volume Price level.")
alertcondition(upper_sweep_sig,  title = "Monday High Sweep",               message = "Liquidity Sweep detected above Monday High.")
alertcondition(lower_sweep_sig,  title = "Monday Low Sweep",                message = "Liquidity Sweep detected below Monday Low.")
alertcondition(upper_accept_sig, title = "Monday Bull Acceptance",          message = "Bullish Acceptance: confirmed close above Monday High.")
alertcondition(lower_accept_sig, title = "Monday Bear Acceptance",          message = "Bearish Acceptance: confirmed close below Monday Low.")
alertcondition(ob_mit_event,     title = "OB Mitigated",                    message = "Anchor Order Block mitigated (confirmed close beyond it).")
````
