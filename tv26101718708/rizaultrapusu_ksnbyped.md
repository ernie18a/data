# RizA_Ultra_Pusu

- url: https://www.tradingview.com/script/kSnBypED/
- type: indicator
- pine_id: PUB;d537f8160a254586a741c96e91569c02
- version: 1.0

## Description

RizA_Ultra_Pusu: The Ultimate SMC & Trend Intelligence Terminal
RizA_Ultra_Pusu is a comprehensive trading solution designed for traders who follow Smart Money Concepts (SMC), Institutional Order Flow, and Multi-Timeframe Trend Analysis. It consolidates essential high-tier tools into a single, optimized script to clean up your charts while providing deep market insights.

🔑 Key Modules
1. Smart Order Blocks (OB) & Breakers
The script identifies high-probability supply and demand zones where institutional movement originates.

Dynamic Tracking: Automatically draws Bullish and Bearish OBs.

Mitigation Logic: Zones extend until hit by price.

Breaker Blocks: If an OB is violated with momentum, it instantly transforms into a Breaker Block (S/R Flip), signaling a potential trend continuation or reversal.

2. Liquidity Swings with Intrabar Precision
Finding pivots is easy, but finding meaningful liquidity is hard.

Volume Metrics: Displays the accumulated volume at swing highs and lows.

Precision Mode: Uses lower timeframe data to pinpoint exactly where the "money" is sitting (Wick Extremity vs. Full Range).

Crossovers: Visual alerts when liquidity is "swept" or "cleared."

3. Multi-Timeframe (MTF) Trend Ribbon
Don't get lost in the noise of a single timeframe.

Normal & MTF SMAs: Tracks trends from higher timeframes (e.g., 5m, 30m) directly on your current chart.

Trend Clouds: Beautifully shaded ribbons (Bullish Green / Bearish Red) that help you stay on the right side of the market trend.

4. Killzone & Session Terminal
In trading, Time is as important as Price.

Major Sessions: Automatically highlights Asia, London, NY AM, and NY PM sessions.

Session Highs/Lows: Tracks the most important levels of the day.

Countdown Timer: A sleek on-chart dashboard showing the exact time remaining until the next session open/close.

📈 How to Trade with RizA_Ultra_Pusu
The Setup: Look for price to sweep a Liquidity Swing level (dashed line) during a major Killzone (e.g., London Open).

The Confirmation: Wait for a Market Structure Shift and the formation of a new Order Block.

The Filter: Ensure the MTF Trend Ribbon aligns with your trade direction for a higher probability of success.

⚙️ Professional Settings
Drawing Limit: Keep your chart clean by limiting the number of historical session boxes.

Custom GMT Offset: Compatible with all global markets (Forex, Crypto, BIST, NAS100).

Volume Filtering: Filter out insignificant pivots by setting a minimum volume threshold.

⚠️ Disclaimer: This tool is designed for decision support and technical analysis. It is not a financial advice "signal" bot. Always apply strict risk management.

## Source Code

````pine
//@version=6
indicator("RizA_Ultra_Pusu", "RizA_Ultra_Pusu", true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500, max_bars_back = 3000)

// ============================================
// YARDIMCI FONKSIYONLAR
// ============================================
get_line_type(_style) =>
    result = switch _style
        "Solid" => line.style_solid
        "Dotted" => line.style_dotted
        "Dashed" => line.style_dashed
        => line.style_solid
    result

get_size(x) =>
    result = switch x
        "Auto" => size.auto
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        "Large" => size.large
        "Huge" => size.huge
        => size.normal
    result

get_table_position(pos_str) =>
    switch pos_str
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        "Top Right" => position.top_right
        "Top Left" => position.top_left
        => position.bottom_right

// ============================================
// GIRIS AYARLARI - ULTRA (SMA & Liquidity)
// ============================================

// === NORMAL SMA AYARLARI ===
normalGroup = "Normal SMA Ayarlari"
bool showNormal = input.bool(false, "Normal SMA Goster", group=normalGroup)
bool showSmaShort = input.bool(true, "SMA Kisa Goster", group=normalGroup, inline="normaltick")
bool showSmaLong = input.bool(true, "SMA Uzun Goster", group=normalGroup, inline="normaltick")
int smaShortLen = input.int(20, "SMA Kisa", group=normalGroup, inline="normalsma")
int smaLongLen = input.int(50, "SMA Uzun", group=normalGroup, inline="normalsma")

// === MTF1 AYARLARI (5 Dakika) ===
mtf1Group = "MTF1 Ayarlari - 5 Dakika"
string mtf1_tf = input.timeframe("1", "MTF1 Zaman Dilimi", group=mtf1Group)
bool showMtf1Short = input.bool(true, "MTF1 SMA Kisa Goster", group=mtf1Group, inline="mtf1tick")
bool showMtf1Long = input.bool(true, "MTF1 SMA Uzun Goster", group=mtf1Group, inline="mtf1tick")
int mtf1_short = input.int(13, "MTF1 SMA Kisa", group=mtf1Group, inline="mtf1")
int mtf1_long = input.int(200, "MTF1 SMA Uzun", group=mtf1Group, inline="mtf1")

// === MTF2 AYARLARI (30 Dakika) ===
mtf2Group = "MTF2 Ayarlari - 30 Dakika"
string mtf2_tf = input.timeframe("15", "MTF2 Zaman Dilimi", group=mtf2Group)
bool showMtf2Short = input.bool(true, "MTF2 SMA Kisa Goster", group=mtf2Group, inline="mtf2tick")
bool showMtf2Long = input.bool(true, "MTF2 SMA Uzun Goster", group=mtf2Group, inline="mtf2tick")
int mtf2_short = input.int(8, "MTF2 SMA Kisa", group=mtf2Group, inline="mtf2")
int mtf2_long = input.int(18, "MTF2 SMA Uzun", group=mtf2Group, inline="mtf2")

// === SMA DOLGU RENKLERI ===
smaGroup = "SMA Dolgu Renkleri"
color fill_bullish_color = input.color(color.rgb(18, 75, 45), "Yukselis Dolgu Rengi", group=smaGroup, inline="fill_colors")
color fill_bearish_color = input.color(color.rgb(117, 12, 12), "Dusus Dolgu Rengi", group=smaGroup, inline="fill_colors")
int fill_transparency = input.int(95, "Dolgu Saydamligi", minval=0, maxval=100, group=smaGroup)

// === MTF DOLGU RENKLERI ===
mtfColorGroup = "MTF Dolgu Renkleri"
color mtf_fill_bullish_color = input.color(color.rgb(16, 138, 79), "MTF Yukselis Dolgu Rengi", group=mtfColorGroup, inline="mtf_fill_colors")
color mtf_fill_bearish_color = input.color(color.rgb(85, 7, 49), "MTF Dusus Dolgu Rengi", group=mtfColorGroup, inline="mtf_fill_colors")
int mtf_fill_transparency = input.int(95, "MTF Dolgu Saydamligi", minval=0, maxval=100, group=mtfColorGroup)

// === LIQUIDITY SWINGS AYARLARI ===
liqGroup = "Liquidity Swings"
int pivotLength = input.int(30, "Pivot Lookback", group=liqGroup)
string swingArea = input.string("Wick Extremity", "Swing Area", options=["Wick Extremity", "Full Range"], group=liqGroup)
bool intraPrecision = input.bool(true, "Intrabar Precision", inline="intrabar", group=liqGroup)
string intrabarTf = input.timeframe("1", "", inline="intrabar", group=liqGroup)
string filterOptions = input.string("Count", "Filter Areas By", options=["Count", "Volume"], inline="filter", group=liqGroup)
float filterValue = input.float(0, "", inline="filter", group=liqGroup)

liqStyleGroup = "Liquidity Swings - Stil"
bool showSwingHigh = input.bool(true, "Swing High", inline="top", group=liqStyleGroup)
color topCss = input.color(color.red, "", inline="top", group=liqStyleGroup)
color topAreaCss = input.color(color.new(color.red, 50), "Area", inline="top", group=liqStyleGroup)

bool showSwingLow = input.bool(true, "Swing Low", inline="btm", group=liqStyleGroup)
color btmCss = input.color(color.teal, "", inline="btm", group=liqStyleGroup)
color btmAreaCss = input.color(color.new(color.teal, 50), "Area", inline="btm", group=liqStyleGroup)

string labelSize = input.string("Tiny", "Labels Size", options=["Tiny", "Small", "Normal"], group=liqStyleGroup)

// === SMA TABLO AYARLARI ===
tableGroup = "Tablo Ayarlari"
string tablePos = input.string("Sag Ust", "Tablo Konumu", options=["Sag Ust", "Sag Alt", "Sol Ust", "Sol Alt", "Orta Ust", "Orta Alt"], group=tableGroup)
string tableSize = input.string("Normal", "Yazi Boyutu", options=["Tiny", "Small", "Normal", "Large"], group=tableGroup)

// ============================================
// GIRIS AYARLARI - PUSU (OB, Killzone, Timer)
// ============================================

// === GENEL AYARLAR ===
var g_SETTINGS      = "Pusu - Genel Ayarlar"
max_days            = input.int(3, "Session Drawing Limit", 1, tooltip = "Only this many drawings will be kept on the chart", group = g_SETTINGS)
tf_limit            = input.timeframe("30", "Timeframe Limit", tooltip = "Drawings will not appear on timeframes greater than or equal to this", group = g_SETTINGS)
gmt_tz              = input.string("America/New_York", "Timezone", options = ["America/New_York","GMT-12","GMT-11","GMT-10","GMT-9","GMT-8","GMT-7","GMT-6","GMT-5","GMT-4","GMT-3","GMT-2","GMT-1","GMT+0","GMT+1","GMT+2","GMT+3","GMT+4","GMT+5","GMT+6","GMT+7","GMT+8","GMT+9","GMT+10","GMT+11","GMT+12","GMT+13","GMT+14"], tooltip = "Note GMT is not adjusted to reflect Daylight Saving Time changes", group = g_SETTINGS)
lbl_size            = get_size(input.string("Normal", "Label Size", options = ["Auto", "Tiny", "Small", "Normal", "Large", "Huge"], tooltip = "The size of all labels", group = g_SETTINGS))
txt_color           = input.color(color.rgb(22, 22, 1), "Text Color", tooltip = "The color of all label and table text", group = g_SETTINGS)
use_cutoff          = input.bool(false, "Drawing Cutoff Time", inline = "CO", tooltip = "When enabled, all pivots and open price lines will stop extending at this time", group = g_SETTINGS)
cutoff              = input.session("1800-1801", "", inline = "CO", group = g_SETTINGS)

// === ORDER BLOCKS ===
var g_OB            = "Order Blocks"
showOB              = input.bool(true, "Show Order Blocks", group = g_OB)
ob_length           = input.int(3, "Swing Lookback", group = g_OB, minval = 3, tooltip = "Dusuk deger = Daha erken OB tespiti")
showBull            = input.int(10, "Show Last Bullish OB", group = g_OB, minval = 0)
showBear            = input.int(10, "Show Last Bearish OB", group = g_OB, minval = 0)
useBody             = input.bool(true, "Use Candle Body", group = g_OB)
bullCss             = input.color(color.new(#061b3a, 0), "Bullish OB", group = g_OB, inline = "bullcss")
bullBrkCss          = input.color(color.new(#4785f9, 85), "Bullish Break", group = g_OB, inline = "bullcss")
bearCss             = input.color(color.new(#FF3131, 0), "Bearish OB", group = g_OB, inline = "bearcss")
bearBrkCss          = input.color(color.new(#f9ff57, 85), "Bearish Break", group = g_OB, inline = "bearcss")
showOBLabels        = input.bool(false, "Show Historical Polarity Changes", group = g_OB)

// === SESSION ALARMLARI & TIMER ===
var g_ALERTS        = "Session Alarms & Timer"
session_alerts      = input.bool(true, "Enable Session Alerts", group = g_ALERTS)
show_countdown      = input.bool(true, "Show Countdown Timer", group = g_ALERTS)
countdown_pos       = input.string("Bottom Right", "Countdown Position", options = ["Bottom Right", "Bottom Left", "Top Right", "Top Left"], group = g_ALERTS)
countdown_text_size = input.string("Large", "Panel Yazi Boyutu", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = g_ALERTS)
countdown_bg_color  = input.color(color.new(color.blue, 50), "Panel Arka Plan Rengi", group = g_ALERTS)
countdown_text_color = input.color(color.white, "Baslik Yazi Rengi", group = g_ALERTS)
countdown_time_color = input.color(color.yellow, "Sayac Yazi Rengi", group = g_ALERTS)

// === KILLZONES ===
var g_KZ            = "Killzones"
show_kz             = input.bool(true, "Show Killzone Boxes", inline = "KZ", group = g_KZ)
show_kz_text        = input.bool(true, "Display Text", inline = "KZ", group = g_KZ)

use_asia            = input.bool(true, "", inline = "ASIA", group = g_KZ)
as_txt              = input.string("Asia", "", inline = "ASIA", group = g_KZ)
asia                = input.session("2000-0000", "", inline = "ASIA", group = g_KZ)
as_color            = input.color(color.blue, "", inline = "ASIA", group = g_KZ)

use_london          = input.bool(true, "", inline = "LONDON", group = g_KZ)
lo_txt              = input.string("London", "", inline = "LONDON", group = g_KZ)
london              = input.session("0200-0500", "", inline = "LONDON", group = g_KZ)
lo_color            = input.color(color.red, "", inline = "LONDON", group = g_KZ)

use_nyam            = input.bool(true, "", inline = "NYAM", group = g_KZ)
na_txt              = input.string("NY AM", "", inline = "NYAM", group = g_KZ)
nyam                = input.session("0930-1100", "", inline = "NYAM", group = g_KZ)
na_color            = input.color(#089981, "", inline = "NYAM", group = g_KZ)

use_nylu            = input.bool(true, "", inline = "NYLU", group = g_KZ)
nl_txt              = input.string("NY Lunch", "", inline = "NYLU", group = g_KZ)
nylu                = input.session("1200-1300", "", inline = "NYLU", group = g_KZ)
nl_color            = input.color(color.yellow, "", inline = "NYLU", group = g_KZ)

use_nypm            = input.bool(true, "", inline = "NYPM", group = g_KZ)
np_txt              = input.string("NY PM", "", inline = "NYPM", group = g_KZ)
nypm                = input.session("1330-1600", "", inline = "NYPM", group = g_KZ)
np_color            = input.color(color.purple, "", inline = "NYPM", group = g_KZ)

box_transparency    = input.int(100, "Box Transparency", 0, 100, group = g_KZ)
text_transparency   = input.int(100, "Text Transparency", 0, 100, group = g_KZ)

// === KILLZONE PIVOTLARI ===
var g_LABELS        = "Killzone Pivots"
show_pivots         = input.bool(true, "Show Pivots", inline = "PV", group = g_LABELS)
use_alerts          = input.bool(true, "Alert Broken Pivots", inline = "PV", tooltip = "The desired killzones must be enabled", group = g_LABELS)
show_midpoints      = input.bool(false, "Show Pivot Midpoints", inline = "mp", group = g_LABELS)
stop_midpoints      = input.bool(true, "Stop Once Mitigated", inline = "mp", group = g_LABELS)
show_labels         = input.bool(true, "Show Pivot Labels", inline = "LB", tooltip = "Show labels denoting each killzone high and low", group = g_LABELS)
label_price         = input.bool(false, "Display Price", inline = "LB", group = g_LABELS)
label_right         = input.bool(false, "Right Side", inline = "LB", group = g_LABELS)
ext_pivots          = input.string("Until Mitigated", "Extend Pivots", options = ["Until Mitigated", "Past Mitigation"], group = g_LABELS)
ext_which           = input.string("Most Recent", "From Which Sessions", options = ["Most Recent", "All"], group = g_LABELS)

ash_str             = input.string("AS.H", "Killzone 1 Labels", inline = "L_AS", group = g_LABELS)
asl_str             = input.string("AS.L", "", inline = "L_AS", group = g_LABELS)
loh_str             = input.string("LO.H", "Killzone 2 Labels", inline = "L_LO", group = g_LABELS)
lol_str             = input.string("LO.L", "", inline = "L_LO", group = g_LABELS)
nah_str             = input.string("NYAM.H", "Killzone 3 Labels", inline = "L_NA", group = g_LABELS)
nal_str             = input.string("NYAM.L", "", inline = "L_NA", group = g_LABELS)
nlh_str             = input.string("NYL.H", "Killzone 4 Labels", inline = "L_NL", group = g_LABELS)
nll_str             = input.string("NYL.L", "", inline = "L_NL", group = g_LABELS)
nph_str             = input.string("NYPM.H", "Killzone 5 Labels", inline = "L_NP", group = g_LABELS)
npl_str             = input.string("NYPM.L", "", inline = "L_NP", group = g_LABELS)

kzp_style           = get_line_type(input.string(defval = "Solid", title = "Pivot Style", options = ["Solid", "Dotted", "Dashed"], inline = "KZP", group = g_LABELS))
kzp_width           = input.int(1, "", inline = "KZP", group = g_LABELS)
kzm_style           = get_line_type(input.string(defval = "Dotted", title = "Midpoint Style", options = ["Solid", "Dotted", "Dashed"], inline = "KZM", group = g_LABELS))
kzm_width           = input.int(1, "", inline = "KZM", group = g_LABELS)

// ============================================
// TIP TANIMLARI
// ============================================

type ob
    float   top       = na
    float   btm       = na
    int     loc       = bar_index
    bool    breaker   = false
    int     break_loc = na

type swing
    float y = na
    int   x = na
    bool  crossed = false

type bx_ln_lb
    box   bx
    line  ln
    label lb

type kz
    string _title
    box[] _box
    line[] _hi_line
    line[] _md_line
    line[] _lo_line
    label[] _hi_label
    label[] _lo_label
    bool[] _hi_valid
    bool[] _md_valid
    bool[] _lo_valid

// ============================================
// DEGISKEN TANIMLARI
// ============================================

var as_kz = kz.new(as_txt, array.new_box(), array.new_line(), array.new_line(), array.new_line(), array.new_label(), array.new_label(), array.new_bool(), array.new_bool(), array.new_bool())
var lo_kz = kz.new(lo_txt, array.new_box(), array.new_line(), array.new_line(), array.new_line(), array.new_label(), array.new_label(), array.new_bool(), array.new_bool(), array.new_bool())
var na_kz = kz.new(na_txt, array.new_box(), array.new_line(), array.new_line(), array.new_line(), array.new_label(), array.new_label(), array.new_bool(), array.new_bool(), array.new_bool())
var nl_kz = kz.new(nl_txt, array.new_box(), array.new_line(), array.new_line(), array.new_line(), array.new_label(), array.new_label(), array.new_bool(), array.new_bool(), array.new_bool())
var np_kz = kz.new(np_txt, array.new_box(), array.new_line(), array.new_line(), array.new_line(), array.new_label(), array.new_label(), array.new_bool(), array.new_bool(), array.new_bool())

t_as = not na(time("", asia, gmt_tz))
t_lo = not na(time("", london, gmt_tz))
t_na = not na(time("", nyam, gmt_tz))
t_nl = not na(time("", nylu, gmt_tz))
t_np = not na(time("", nypm, gmt_tz))
t_co = not na(time("", cutoff, gmt_tz))

var transparent = #ffffff00
var ext_current = ext_which == "Most Recent"
var ext_past = ext_pivots == "Past Mitigation"

current_hour_tz = hour(time, gmt_tz)
current_min_tz = minute(time, gmt_tz)

realtime_hour_tz = hour(timenow, gmt_tz)
realtime_min_tz = minute(timenow, gmt_tz)

n           = bar_index
tf_msec     = timeframe.in_seconds(timeframe.period) * 1000
ob_max      = useBody ? math.max(close, open) : high
ob_min      = useBody ? math.min(close, open) : low
mx          = math.max(close, open)
mn          = math.min(close, open)
per_vi_ob   = last_bar_index - bar_index <= 500

var ob[] bullish_ob = array.new<ob>()
var ob[] bearish_ob = array.new<ob>()
var bx_ln_lb[] a_bx_ln_lb = array.new<bx_ln_lb>()

blBrkConf = 0
brBrkConf = 0

// ============================================
// NORMAL SMA HESAPLAMA
// ============================================
smaShort = ta.sma(close, smaShortLen)
smaLong = ta.sma(close, smaLongLen)
bullish = smaShort > smaLong
bearish = smaShort < smaLong
color currentTrendColor = bullish ? fill_bullish_color : bearish ? fill_bearish_color : color.gray

bool showNormalShort = showNormal and showSmaShort
bool showNormalLong = showNormal and showSmaLong

plot_smaShort = plot(showNormalShort ? smaShort : na, title="SMA Kisa", color=currentTrendColor, linewidth=2)
plot_smaLong = plot(showNormalLong ? smaLong : na, title="SMA Uzun", color=currentTrendColor, linewidth=2)
areaColor = bullish ? color.new(fill_bullish_color, fill_transparency) : bearish ? color.new(fill_bearish_color, fill_transparency) : na
fill(plot_smaShort, plot_smaLong, color=(showNormalShort and showNormalLong) ? areaColor : na, title="SMA Alani")

// ============================================
// MTF1 SMA HESAPLAMA (5 Dakika)
// ============================================
mtf1SmaShort = request.security(syminfo.tickerid, mtf1_tf, ta.sma(close, mtf1_short), barmerge.gaps_off, barmerge.lookahead_on)
mtf1SmaLong = request.security(syminfo.tickerid, mtf1_tf, ta.sma(close, mtf1_long), barmerge.gaps_off, barmerge.lookahead_on)
mtf1Bullish = mtf1SmaShort > mtf1SmaLong
mtf1Bearish = mtf1SmaShort < mtf1SmaLong
color mtf1TrendColor = mtf1Bullish ? mtf_fill_bullish_color : mtf1Bearish ? mtf_fill_bearish_color : color.gray

plot_mtf1SmaShort = plot(showMtf1Short ? mtf1SmaShort : na, title="MTF1 SMA Kisa", color=mtf1TrendColor, linewidth=1)
plot_mtf1SmaLong = plot(showMtf1Long ? mtf1SmaLong : na, title="MTF1 SMA Uzun", color=mtf1TrendColor, linewidth=1)
mtf1AreaColor = mtf1Bullish ? color.new(mtf_fill_bullish_color, mtf_fill_transparency) : mtf1Bearish ? color.new(mtf_fill_bearish_color, mtf_fill_transparency) : na
fill(plot_mtf1SmaShort, plot_mtf1SmaLong, color=(showMtf1Short and showMtf1Long) ? mtf1AreaColor : na, title="MTF1 SMA Alani")

// ============================================
// MTF2 SMA HESAPLAMA (30 Dakika)
// ============================================
mtf2SmaShort = request.security(syminfo.tickerid, mtf2_tf, ta.sma(close, mtf2_short), barmerge.gaps_off, barmerge.lookahead_on)
mtf2SmaLong = request.security(syminfo.tickerid, mtf2_tf, ta.sma(close, mtf2_long), barmerge.gaps_off, barmerge.lookahead_on)
mtf2Bullish = mtf2SmaShort > mtf2SmaLong
mtf2Bearish = mtf2SmaShort < mtf2SmaLong
color mtf2TrendColor = mtf2Bullish ? mtf_fill_bullish_color : mtf2Bearish ? mtf_fill_bearish_color : color.gray

plot_mtf2SmaShort = plot(showMtf2Short ? mtf2SmaShort : na, title="MTF2 SMA Kisa", color=mtf2TrendColor, linewidth=1)
plot_mtf2SmaLong = plot(showMtf2Long ? mtf2SmaLong : na, title="MTF2 SMA Uzun", color=mtf2TrendColor, linewidth=1)
mtf2AreaColor = mtf2Bullish ? color.new(mtf_fill_bullish_color, mtf_fill_transparency) : mtf2Bearish ? color.new(mtf_fill_bearish_color, mtf_fill_transparency) : na
fill(plot_mtf2SmaShort, plot_mtf2SmaLong, color=(showMtf2Short and showMtf2Long) ? mtf2AreaColor : na, title="MTF2 SMA Alani")

// ============================================
// LIQUIDITY SWINGS
// ============================================
get_data() => [high, low, volume]
[h, l, v] = request.security_lower_tf(syminfo.tickerid, intrabarTf, get_data())

get_counts(condition, top, btm) =>
    var count = 0
    var vol = 0.
    if condition
        count := 0
        vol := 0.
    else
        if intraPrecision
            if n > pivotLength
                if array.size(v[pivotLength]) > 0
                    for [index, element] in v[pivotLength]
                        vol += array.get(l[pivotLength], index) < top and array.get(h[pivotLength], index) > btm ? element : 0
        else
            vol += low[pivotLength] < top and high[pivotLength] > btm ? volume[pivotLength] : 0
        count += low[pivotLength] < top and high[pivotLength] > btm ? 1 : 0
    [count, vol]

set_label(count, vol, x, y, css, lbl_style) =>
    var label lbl = na
    label_size_val = switch labelSize
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
    target = switch filterOptions
        "Count" => count
        "Volume" => vol
    if ta.crossover(target, filterValue)
        lbl := label.new(x, y, str.tostring(vol, format.volume), style=lbl_style, size=label_size_val, color=#00000000, textcolor=css)
    if target > filterValue
        label.set_text(lbl, str.tostring(vol, format.volume))

set_level(condition, crossed, value, count, vol, css) =>
    var line lvl = na
    target = switch filterOptions
        "Count" => count
        "Volume" => vol
    if condition
        if target[1] < filterValue[1]
            line.delete(lvl[1])
        else if not crossed[1]
            line.set_x2(lvl, n - pivotLength)
        lvl := line.new(n - pivotLength, value, n, value, color=na)
    if not crossed[1]
        line.set_x2(lvl, n + 3)
    if crossed and not crossed[1]
        line.set_x2(lvl, n)
        line.set_style(lvl, line.style_dashed)
    if target > filterValue
        line.set_color(lvl, css)

set_zone(condition, x, top, btm, count, vol, css) =>
    var box bx = na
    target = switch filterOptions
        "Count" => count
        "Volume" => vol
    if ta.crossover(target, filterValue)
        bx := box.new(x, top, x + count, btm, border_color=na, bgcolor=css)
    if target > filterValue
        box.set_right(bx, x + count)

// === PIVOT HIGH ===
var float ph_top = na
var float ph_btm = na
var bool ph_crossed = false
var int ph_x1 = 0
var box ph_bx = box.new(na, na, na, na, bgcolor=color.new(topAreaCss, 80), border_color=na)

ph = ta.pivothigh(pivotLength, pivotLength)
bool ph_found = not na(ph)
[ph_count, ph_vol] = get_counts(ph_found, ph_top, ph_btm)

if ph_found and showSwingHigh
    ph_top := high[pivotLength]
    ph_btm := switch swingArea
        "Wick Extremity" => math.max(close[pivotLength], open[pivotLength])
        "Full Range" => low[pivotLength]
    ph_x1 := n - pivotLength
    ph_crossed := false
    box.set_lefttop(ph_bx, ph_x1, ph_top)
    box.set_rightbottom(ph_bx, ph_x1, ph_btm)
else
    ph_crossed := close > ph_top ? true : ph_crossed
    if ph_crossed
        box.set_right(ph_bx, ph_x1)
    else
        box.set_right(ph_bx, n + 3)

if showSwingHigh
    set_zone(ph_found, ph_x1, ph_top, ph_btm, ph_count, ph_vol, topAreaCss)
    set_level(ph_found, ph_crossed, ph_top, ph_count, ph_vol, topCss)
    set_label(ph_count, ph_vol, ph_x1, ph_top, topCss, label.style_label_down)

// === PIVOT LOW ===
var float pl_top = na
var float pl_btm = na
var bool pl_crossed = false
var int pl_x1 = 0
var box pl_bx = box.new(na, na, na, na, bgcolor=color.new(btmAreaCss, 80), border_color=na)

pl = ta.pivotlow(pivotLength, pivotLength)
bool pl_found = not na(pl)
[pl_count, pl_vol] = get_counts(pl_found, pl_top, pl_btm)

if pl_found and showSwingLow
    pl_top := switch swingArea
        "Wick Extremity" => math.min(close[pivotLength], open[pivotLength])
        "Full Range" => high[pivotLength]
    pl_btm := low[pivotLength]
    pl_x1 := n - pivotLength
    pl_crossed := false
    box.set_lefttop(pl_bx, pl_x1, pl_top)
    box.set_rightbottom(pl_bx, pl_x1, pl_btm)
else
    pl_crossed := close < pl_btm ? true : pl_crossed
    if pl_crossed
        box.set_right(pl_bx, pl_x1)
    else
        box.set_right(pl_bx, n + 3)

if showSwingLow
    set_zone(pl_found, pl_x1, pl_top, pl_btm, pl_count, pl_vol, btmAreaCss)
    set_level(pl_found, pl_crossed, pl_btm, pl_count, pl_vol, btmCss)
    set_label(pl_count, pl_vol, pl_x1, pl_btm, btmCss, label.style_label_up)

// ============================================
// PUSU - METOTLAR VE FONKSIYONLAR
// ============================================

method notransp(color css) => color.rgb(color.r(css), color.g(css), color.b(css))

method display(ob id, css, break_css, str_type)=>
    if showOB
        if id.breaker
            a_bx_ln_lb.unshift(bx_ln_lb.new(box.new(id.loc, id.top, timenow + (tf_msec * 10), id.btm, na, bgcolor = break_css, extend = extend.none, xloc = xloc.bar_time), line(na), label(na)))
        else
            y  = str_type == "bl" ? id.btm : id.top
            s  = str_type == "bl" ? label.style_label_up : label.style_label_down
            a_bx_ln_lb.unshift(bx_ln_lb.new(box(na), line.new(id.loc, y, id.loc + (tf_msec * 10), y, xloc = xloc.bar_time, color=css, width=2), label.new(id.loc + (tf_msec * 10), y, text = str_type == "bl" ? "+OB" : "-OB", xloc = xloc.bar_time, style = s, color = color(na), textcolor=css, size = size.small)))

ob_swings(len) =>
    var os = 0
    var swing top = swing.new(na, na)
    var swing btm = swing.new(na, na)
    upper = ta.highest(len)
    lower = ta.lowest(len)
    os := high[len] > upper ? 0 : low[len] < lower ? 1 : os
    if os == 0 and os[1] != 0
        top := swing.new(high[len], bar_index[len])
    if os == 1 and os[1] != 1
        btm := swing.new(low[len], bar_index[len])
    [top, btm]

get_box_color(color c) =>
    result = color.new(c, box_transparency)
    result

get_text_color(color c) =>
    result = color.new(c, text_transparency)
    result

get_next_session() =>
    current_total = realtime_hour_tz * 60 + realtime_min_tz
    next_event = "Waiting..."
    next_time = 1440

    if use_asia
        asia_start = 20 * 60
        asia_end = 24 * 60
        if current_total >= asia_start or current_total < 0
            time_diff = asia_end - current_total
            if time_diff < 0
                time_diff := 1440 + time_diff
            if time_diff < next_time and time_diff > 0
                next_time := time_diff
                next_event := "ASIA CLOSE"
        else
            time_diff = asia_start - current_total
            if time_diff < 0
                time_diff := 1440 + time_diff
            if time_diff < next_time
                next_time := time_diff
                next_event := "ASIA OPEN"

    if use_london
        london_start = 2 * 60
        london_end = 5 * 60
        if current_total >= london_start and current_total < london_end
            time_diff = london_end - current_total
            if time_diff < next_time and time_diff > 0
                next_time := time_diff
                next_event := "LONDON CLOSE"
        else
            time_diff = london_start - current_total
            if time_diff < 0
                time_diff := 1440 + time_diff
            if time_diff < next_time
                next_time := time_diff
                next_event := "LONDON OPEN"

    if use_nyam
        nyam_start = 9 * 60 + 30
        nyam_end = 11 * 60
        if current_total >= nyam_start and current_total < nyam_end
            time_diff = nyam_end - current_total
            if time_diff < next_time and time_diff > 0
                next_time := time_diff
                next_event := "NY AM CLOSE"
        else
            time_diff = nyam_start - current_total
            if time_diff < 0
                time_diff := 1440 + time_diff
            if time_diff < next_time
                next_time := time_diff
                next_event := "NY AM OPEN"

    if use_nylu
        nylu_start = 12 * 60
        nylu_end = 13 * 60
        if current_total >= nylu_start and current_total < nylu_end
            time_diff = nylu_end - current_total
            if time_diff < next_time and time_diff > 0
                next_time := time_diff
                next_event := "NY LUNCH CLOSE"
        else
            time_diff = nylu_start - current_total
            if time_diff < 0
                time_diff := 1440 + time_diff
            if time_diff < next_time
                next_time := time_diff
                next_event := "NY LUNCH OPEN"

    if use_nypm
        nypm_start = 13 * 60 + 30
        nypm_end = 16 * 60
        if current_total >= nypm_start and current_total < nypm_end
            time_diff = nypm_end - current_total
            if time_diff < next_time and time_diff > 0
                next_time := time_diff
                next_event := "NY PM CLOSE"
        else
            time_diff = nypm_start - current_total
            if time_diff < 0
                time_diff := 1440 + time_diff
            if time_diff < next_time
                next_time := time_diff
                next_event := "NY PM OPEN"

    hours_left = math.floor(next_time / 60)
    mins_left = next_time % 60
    time_str = str.format("{0,number,00}:{1,number,00}", hours_left, mins_left)
    [next_event, time_str]

create_session_box(condition, prev_condition, session_name, session_color) =>
    if condition and not prev_condition and session_alerts
        alert("SESSION OPENING: " + session_name, alert.freq_once_per_bar)
    if not condition and prev_condition and session_alerts
        alert("SESSION CLOSING: " + session_name, alert.freq_once_per_bar)

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
        k._lo_label.pop().delete()

update_price_string(label L, float P) =>
    S = L.get_text()
    pre = str.substring(S, 0, str.pos(S, " "))
    str.trim(pre)
    L.set_text(str.format("{0} ({1})", pre, P))

adjust_in_kz(kz kz_obj, bool t) =>
    if t
        kz_obj._box.get(0).set_right(time)
        kz_obj._box.get(0).set_top(math.max(kz_obj._box.get(0).get_top(), high))
        kz_obj._box.get(0).set_bottom(math.min(kz_obj._box.get(0).get_bottom(), low))
        if show_pivots and kz_obj._hi_line.size() > 0
            kz_obj._hi_line.get(0).set_x2(time)
            if high > kz_obj._hi_line.get(0).get_y1()
                kz_obj._hi_line.get(0).set_xy1(time, high)
                kz_obj._hi_line.get(0).set_xy2(time, high)
            kz_obj._lo_line.get(0).set_x2(time)
            if low < kz_obj._lo_line.get(0).get_y1()
                kz_obj._lo_line.get(0).set_xy1(time, low)
                kz_obj._lo_line.get(0).set_xy2(time, low)
            if show_midpoints
                kz_obj._md_line.get(0).set_x2(time)
                kz_obj._md_line.get(0).set_xy1(time, math.avg(kz_obj._hi_line.get(0).get_y2(), kz_obj._lo_line.get(0).get_y2()))
                kz_obj._md_line.get(0).set_xy2(time, math.avg(kz_obj._hi_line.get(0).get_y2(), kz_obj._lo_line.get(0).get_y2()))
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

adjust_out_kz(kz kz_obj, bool t) =>
    if kz_obj._box.size() > 0 and show_pivots
        for i = 0 to kz_obj._box.size() - 1
            if not ext_current or (ext_current and i == 0)
                if ext_past ? true : (kz_obj._hi_valid.get(i) == true)
                    kz_obj._hi_line.get(i).set_x2(time)
                    if show_labels and label_right
                        kz_obj._hi_label.get(i).set_x(time)
                if high > kz_obj._hi_line.get(i).get_y1() and kz_obj._hi_valid.get(i) == true
                    if use_alerts and i == 0
                        alert("Broke " + kz_obj._title + " High", alert.freq_once_per_bar)
                    kz_obj._hi_valid.set(i, false)
                    if show_labels and label_right
                        kz_obj._hi_label.get(0).set_style(label.style_label_down)
                else if (use_cutoff ? t_co : false)
                    kz_obj._hi_valid.set(i, false)
                if ext_past ? true : (kz_obj._lo_valid.get(i) == true)
                    kz_obj._lo_line.get(i).set_x2(time)
                    if show_labels and label_right
                        kz_obj._lo_label.get(i).set_x(time)
                if low < kz_obj._lo_line.get(i).get_y1() and kz_obj._lo_valid.get(i) == true
                    if use_alerts and i == 0
                        alert("Broke " + kz_obj._title + " Low", alert.freq_once_per_bar)
                    kz_obj._lo_valid.set(i, false)
                    if show_labels and label_right
                        kz_obj._lo_label.get(0).set_style(label.style_label_up)
                else if (use_cutoff ? t_co : false)
                    kz_obj._lo_valid.set(i, false)
                if show_midpoints and not t
                    if stop_midpoints ? (kz_obj._md_valid.get(i) == true) : true
                        kz_obj._md_line.get(i).set_x2(time)
                        if kz_obj._md_valid.get(i) == true and low <= kz_obj._md_line.get(i).get_y1() and high >= kz_obj._md_line.get(i).get_y1()
                            kz_obj._md_valid.set(i, false)
            else
                break

manage_kz(kz kz_obj, bool use, bool t, color c, string box_txt, string hi_txt, string lo_txt) =>
    if timeframe.in_seconds("") <= timeframe.in_seconds(tf_limit) and use
        if t and not t[1]
            _c = get_box_color(c)
            _t = get_text_color(c)
            kz_obj._box.unshift(box.new(time, high, time, low, xloc = xloc.bar_time, border_color = show_kz ? _c : na, bgcolor = show_kz ? _c : na, text = (show_kz and show_kz_text) ? box_txt : na, text_color = _t))
            if show_pivots
                kz_obj._hi_line.unshift(line.new(time, high, time, high, xloc = xloc.bar_time, style = kzp_style, color = c, width = kzp_width))
                kz_obj._lo_line.unshift(line.new(time, low, time, low, xloc = xloc.bar_time, style = kzp_style, color = c, width = kzp_width))
                if show_midpoints
                    kz_obj._md_line.unshift(line.new(time, math.avg(high, low), time, math.avg(high, low), xloc = xloc.bar_time, style = kzm_style, color = c, width = kzm_width))
                    array.unshift(kz_obj._md_valid, true)
                array.unshift(kz_obj._hi_valid, true)
                array.unshift(kz_obj._lo_valid, true)
                if show_labels
                    _hi_txt = label_price ? str.format("{0} ({1})", hi_txt, high) : hi_txt
                    _lo_txt = label_price ? str.format("{0} ({1})", lo_txt, low)  : lo_txt
                    if label_right
                        kz_obj._hi_label.unshift(label.new(time, high, _hi_txt, xloc = xloc.bar_time, color = transparent, textcolor = txt_color, style = label.style_label_left, size = lbl_size))
                        kz_obj._lo_label.unshift(label.new(time, low,  _lo_txt, xloc = xloc.bar_time, color = transparent, textcolor = txt_color, style = label.style_label_left, size = lbl_size))
                    else
                        kz_obj._hi_label.unshift(label.new(time, high, _hi_txt, xloc = xloc.bar_time, color = transparent, textcolor = txt_color, style = label.style_label_down, size = lbl_size))
                        kz_obj._lo_label.unshift(label.new(time, low,  _lo_txt, xloc = xloc.bar_time, color = transparent, textcolor = txt_color, style = label.style_label_up, size = lbl_size))
            del_kz(kz_obj)
        adjust_in_kz(kz_obj, t)
        adjust_out_kz(kz_obj, t)

// ============================================
// SESSION & KILLZONE YONETIMI
// ============================================

create_session_box(use_asia and t_as, use_asia and t_as[1], as_txt, as_color)
create_session_box(use_london and t_lo, use_london and t_lo[1], lo_txt, lo_color)
create_session_box(use_nyam and t_na, use_nyam and t_na[1], na_txt, na_color)
create_session_box(use_nylu and t_nl, use_nylu and t_nl[1], nl_txt, nl_color)
create_session_box(use_nypm and t_np, use_nypm and t_np[1], np_txt, np_color)

manage_kz(as_kz, use_asia, t_as, as_color, as_txt, ash_str, asl_str)
manage_kz(lo_kz, use_london, t_lo, lo_color, lo_txt, loh_str, lol_str)
manage_kz(na_kz, use_nyam, t_na, na_color, na_txt, nah_str, nal_str)
manage_kz(nl_kz, use_nylu, t_nl, nl_color, nl_txt, nlh_str, nll_str)
manage_kz(np_kz, use_nypm, t_np, np_color, np_txt, nph_str, npl_str)

// ============================================
// ORDER BLOCKS MANTIGI
// ============================================

[ob_top_swing, ob_btm_swing] = ob_swings(ob_length)

if showOB and per_vi_ob
    if close > ob_top_swing.y and not ob_top_swing.crossed
        ob_top_swing.crossed := true
        minima = ob_max[1]
        maxima = ob_min[1]
        loc = time[1]
        for i = 1 to (n - ob_top_swing.x) - 1
            minima := math.min(ob_min[i], minima)
            maxima := minima == ob_min[i] ? ob_max[i] : maxima
            loc := minima == ob_min[i] ? time[i] : loc
        bullish_ob.unshift(ob.new(maxima, minima, loc))

    if bullish_ob.size() > 0
        for i = bullish_ob.size() - 1 to 0
            element = bullish_ob.get(i)
            if not element.breaker
                if math.min(close, open) < element.btm
                    element.breaker := true
                    element.break_loc := time
            else
                if close > element.top
                    bullish_ob.remove(i)
                else if i < showBull and ob_top_swing.y < element.top and ob_top_swing.y > element.btm
                    blBrkConf := 1

    if blBrkConf > blBrkConf[1] and showOBLabels
        label.new(ob_top_swing.x, ob_top_swing.y, "v", color = na, textcolor = bearCss.notransp(), style = label.style_label_down, size = size.tiny)

if showOB and per_vi_ob
    if close < ob_btm_swing.y and not ob_btm_swing.crossed
        ob_btm_swing.crossed := true
        minima = ob_min[1]
        maxima = ob_max[1]
        loc = time[1]
        for i = 1 to (n - ob_btm_swing.x) - 1
            maxima := math.max(ob_max[i], maxima)
            minima := maxima == ob_max[i] ? ob_min[i] : minima
            loc := maxima == ob_max[i] ? time[i] : loc
        bearish_ob.unshift(ob.new(maxima, minima, loc))

    if bearish_ob.size() > 0
        for i = bearish_ob.size() - 1 to 0
            element = bearish_ob.get(i)
            if not element.breaker
                if math.max(close, open) > element.top
                    element.breaker := true
                    element.break_loc := time
            else
                if close < element.btm
                    bearish_ob.remove(i)
                else if i < showBear and ob_btm_swing.y > element.btm and ob_btm_swing.y < element.top
                    brBrkConf := 1

    if brBrkConf > brBrkConf[1] and showOBLabels
        label.new(ob_btm_swing.x, ob_btm_swing.y, "^", color = na, textcolor = bullCss.notransp(), style = label.style_label_up, size = size.tiny)

if barstate.islast and showOB
    if a_bx_ln_lb.size() > 0
        for i = a_bx_ln_lb.size() - 1 to 0
            item = a_bx_ln_lb.remove(i)
            item.bx.delete()
            item.ln.delete()
            item.lb.delete()
    if showBull > 0
        blSz = bullish_ob.size()
        if blSz > 0
            for i = 0 to math.min(showBull, bullish_ob.size()) - 1
                get_ob = bullish_ob.get(i)
                get_ob.display(bullCss, bullBrkCss, "bl")
    if showBear > 0
        brSz = bearish_ob.size()
        if brSz > 0
            for i = 0 to math.min(showBear, bearish_ob.size()) - 1
                get_ob = bearish_ob.get(i)
                get_ob.display(bearCss, bearBrkCss, "br")

// ============================================
// SMA TREND TABLOSU
// ============================================
getTimeframeName(string tf) =>
    string name = tf
    if tf == "M"
        name := "Aylik"
    else if tf == "W"
        name := "Haftalik"
    else if tf == "D"
        name := "Gunluk"
    else if tf == "240"
        name := "4S"
    else if tf == "60"
        name := "1S"
    else if tf == "30"
        name := "30D"
    else if tf == "15"
        name := "15D"
    else if tf == "10"
        name := "10D"
    else if tf == "5"
        name := "5D"
    else if tf == "1"
        name := "1D"
    name

txtSize = switch tableSize
    "Tiny" => size.tiny
    "Small" => size.small
    "Normal" => size.normal
    "Large" => size.large
    => size.normal

int tableRows = showNormal ? 4 : 3

var table trendTable = table.new(tablePos == "Sag Ust" ? position.top_right : tablePos == "Sag Alt" ? position.bottom_right : tablePos == "Sol Ust" ? position.top_left : tablePos == "Sol Alt" ? position.bottom_left : tablePos == "Orta Ust" ? position.top_center : position.bottom_center, columns=3, rows=tableRows, bgcolor=color.new(color.black, 70), border_width=1)

if barstate.islast
    table.cell(trendTable, 0, 0, "Zaman", text_color=color.white, text_size=txtSize, bgcolor=color.new(color.gray, 50))
    table.cell(trendTable, 1, 0, "SMA", text_color=color.white, text_size=txtSize, bgcolor=color.new(color.gray, 50))
    table.cell(trendTable, 2, 0, "Trend", text_color=color.white, text_size=txtSize, bgcolor=color.new(color.gray, 50))

    if showNormal
        table.cell(trendTable, 0, 1, getTimeframeName(timeframe.period), text_color=color.white, text_size=txtSize)
        table.cell(trendTable, 1, 1, str.tostring(smaShortLen) + "/" + str.tostring(smaLongLen), text_color=color.white, text_size=txtSize)
        table.cell(trendTable, 2, 1, bullish ? "BUY" : "SELL", text_color=color.white, text_size=txtSize, bgcolor=color.new(currentTrendColor, 30))
        table.cell(trendTable, 0, 2, "MTF1:" + getTimeframeName(mtf1_tf), text_color=color.yellow, text_size=txtSize)
        table.cell(trendTable, 1, 2, str.tostring(mtf1_short) + "/" + str.tostring(mtf1_long), text_color=color.yellow, text_size=txtSize)
        table.cell(trendTable, 2, 2, mtf1Bullish ? "BUY" : "SELL", text_color=color.white, text_size=txtSize, bgcolor=color.new(mtf1TrendColor, 30))
        table.cell(trendTable, 0, 3, "MTF2:" + getTimeframeName(mtf2_tf), text_color=color.orange, text_size=txtSize)
        table.cell(trendTable, 1, 3, str.tostring(mtf2_short) + "/" + str.tostring(mtf2_long), text_color=color.orange, text_size=txtSize)
        table.cell(trendTable, 2, 3, mtf2Bullish ? "BUY" : "SELL", text_color=color.white, text_size=txtSize, bgcolor=color.new(mtf2TrendColor, 30))
    else
        table.cell(trendTable, 0, 1, "MTF1:" + getTimeframeName(mtf1_tf), text_color=color.yellow, text_size=txtSize)
        table.cell(trendTable, 1, 1, str.tostring(mtf1_short) + "/" + str.tostring(mtf1_long), text_color=color.yellow, text_size=txtSize)
        table.cell(trendTable, 2, 1, mtf1Bullish ? "BUY" : "SELL", text_color=color.white, text_size=txtSize, bgcolor=color.new(mtf1TrendColor, 30))
        table.cell(trendTable, 0, 2, "MTF2:" + getTimeframeName(mtf2_tf), text_color=color.orange, text_size=txtSize)
        table.cell(trendTable, 1, 2, str.tostring(mtf2_short) + "/" + str.tostring(mtf2_long), text_color=color.orange, text_size=txtSize)
        table.cell(trendTable, 2, 2, mtf2Bullish ? "BUY" : "SELL", text_color=color.white, text_size=txtSize, bgcolor=color.new(mtf2TrendColor, 30))

// ============================================
// COUNTDOWN TIMER
// ============================================
if show_countdown
    var table countdown_table = table.new(get_table_position(countdown_pos), 1, 2, bgcolor=color.new(color.black, 50), border_width=0, frame_width=1, frame_color=color.gray)
    [next_event, time_left] = get_next_session()

    panel_size = switch countdown_text_size
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        "Large" => size.large
        "Huge" => size.huge
        => size.small

    table.cell(countdown_table, 0, 0, next_event, text_color=countdown_text_color, bgcolor=countdown_bg_color, text_size=panel_size)
    table.cell(countdown_table, 0, 1, time_left, text_color=countdown_time_color, bgcolor=color.new(color.black, 50), text_size=panel_size, text_halign=text.align_center)

// ============================================
// OB ALARMLARI
// ============================================
is_new_bull_ob = bullish_ob.size() > 0 and barstate.isconfirmed
if is_new_bull_ob and ta.change(bullish_ob.size()) > 0
    alert("Yeni Boga (Sari/Mavi) OB Olustu! Fiyat: " + str.tostring(close), alert.freq_once_per_bar)

is_new_bear_ob = bearish_ob.size() > 0 and barstate.isconfirmed
if is_new_bear_ob and ta.change(bearish_ob.size()) > 0
    alert("Yeni Ayi (Sari/Kirmizi) OB Olustu! Fiyat: " + str.tostring(close), alert.freq_once_per_bar)
````
