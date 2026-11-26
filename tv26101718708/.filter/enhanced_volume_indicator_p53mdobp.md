# Enhanced Volume Indicator

- url: https://www.tradingview.com/script/p53MdobP-Enhanced-Volume-Indicator/
- type: indicator
- pine_id: PUB;14eb1d0dd1154d2ca8173fb026949374
- version: 1.0

## Description

My Personal Volume Indikator with following features:

HVE (Highest Volume Ever)
HVY (Highest Volume in a Year, trailing 12 Month)
Customizable MA 
Highlights Days with increased Volume 
Highlights Days with low Volume

## Source Code

````pine
//@version=6
indicator(title="Bar Volume Pro", shorttitle="BVP", format=format.volume, precision=0)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────

grp_ma = "📊 Moving Average"
ma_type      = input.string("SMA", "MA Type", options=["SMA","EMA","WMA","VWMA","HMA"], group=grp_ma)
ma_length    = input.int(50, "MA Length (Rückblick)", minval=1, group=grp_ma)
ma_tf        = input.timeframe("", "MA Timeframe (blank = chart TF)", group=grp_ma)
show_ma      = input.bool(true, "Show MA Line", group=grp_ma)
ma_width     = input.int(2, "MA Line Width", minval=1, maxval=10, group=grp_ma)

grp_hv = "🔥 High Volume Events"
show_labels  = input.bool(true, "Show HVE / HVY Labels", group=grp_hv)
show_abs_vol = input.bool(true, "Show Absolute Volume in Label", group=grp_hv)
show_pct     = input.bool(true, "Show % above MA (50) in Label", group=grp_hv)

grp_col = "🎨 Bar Colors"
color_normal_up  = input.color(color.new(color.teal,  20), "Normal Up Bar",         group=grp_col)
color_normal_dn  = input.color(color.new(color.red,   20), "Normal Down Bar",        group=grp_col)
color_low_up     = input.color(color.new(color.gray,  40), "<=50% MA Up Bar",         group=grp_col)
color_low_dn     = input.color(color.new(color.gray,  40), "<=50% MA Down Bar",       group=grp_col)
color_high_up    = input.color(color.new(color.purple, 0), "100%+ über MA Up Bar",   group=grp_col)
color_high_dn    = input.color(color.new(color.purple, 0), "100%+ über MA Down Bar", group=grp_col)
color_hvy_up     = input.color(color.new(color.orange, 0), "HVY Up Bar",             group=grp_col)
color_hvy_dn     = input.color(color.new(color.orange, 0), "HVY Down Bar",           group=grp_col)
color_hve_up     = input.color(color.new(color.yellow, 0), "HVE Up Bar",             group=grp_col)
color_hve_dn     = input.color(color.new(color.yellow, 0), "HVE Down Bar",           group=grp_col)
color_ma_line    = input.color(color.new(color.white, 20), "MA Line",                group=grp_col)

// ─────────────────────────────────────────────
// MA CALCULATION
// ─────────────────────────────────────────────

calc_ma(float src, simple int len, simple string matype) =>
    float result = switch matype
        "EMA"  => ta.ema(src, len)
        "WMA"  => ta.wma(src, len)
        "VWMA" => ta.vwma(src, len)
        "HMA"  => ta.wma(2.0 * ta.wma(src, len / 2) - ta.wma(src, len), math.round(math.sqrt(len)))
        =>        ta.sma(src, len)
    result

string tf_resolved = ma_tf == "" ? timeframe.period : ma_tf
float vol_htf = request.security(syminfo.tickerid, tf_resolved, volume, lookahead=barmerge.lookahead_off)
float ma_val  = calc_ma(vol_htf, ma_length, ma_type)

float pct_above_ma = (volume / ma_val - 1.0) * 100.0
bool  is_100_plus  = pct_above_ma >= 100.0
bool  is_low_vol   = volume <= ma_val * 0.5

// ─────────────────────────────────────────────
// HVY — Neues Hoch der letzten 12 Monate (Trailing), nur wenn >= 50% über MA
// ─────────────────────────────────────────────

// Zeitstempel von vor genau 12 Monaten
int ts_12m_ago = timestamp(year(time) - 1, month(time), dayofmonth(time), hour(time), minute(time))

// Anzahl Bars im 12-Monats-Fenster bestimmen (ohne aktuelle Bar)
int bars_12m = 1
for i = 1 to 2000
    if time[i] >= ts_12m_ago
        bars_12m := i
    else
        break

// Höchstes qualifiziertes Volumen (>= 50% über MA) im Fenster
float hvy_level = na
for j = 1 to bars_12m
    float v = volume[j]
    float m = ma_val[j]
    if not na(v) and not na(m) and v >= m * 1.5
        hvy_level := na(hvy_level) ? v : math.max(hvy_level, v)

// HVY: aktuelles Volumen schlägt das bisherige Trailing-Hoch UND >= 50% über MA
bool is_hvy = not na(hvy_level) and volume > hvy_level and pct_above_ma >= 50.0

// ─────────────────────────────────────────────
// HVE — Neues Allzeit-Volumenhoch
// ─────────────────────────────────────────────

var float hve_level = na
if na(hve_level)
    hve_level := volume[1]
else
    hve_level := math.max(hve_level, volume[1])

bool is_hve      = volume > hve_level and not na(hve_level)
bool is_hvy_only = is_hvy and not is_hve
bool is_high_vol = is_100_plus and not is_hve and not is_hvy_only

// ─────────────────────────────────────────────
// BAR COLORS
// ─────────────────────────────────────────────

color bar_color = is_hve ? (close >= close[1] ? color_hve_up : color_hve_dn) : is_hvy_only ? (close >= close[1] ? color_hvy_up : color_hvy_dn) : is_high_vol ? (close >= close[1] ? color_high_up : color_high_dn) : is_low_vol ? (close >= close[1] ? color_low_up : color_low_dn) : (close >= close[1] ? color_normal_up : color_normal_dn)

// ─────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────

plot(volume, "Volume", style=plot.style_columns, color=bar_color)
plot(show_ma ? ma_val : na, "Volume MA", color=color_ma_line, linewidth=ma_width)

// ─────────────────────────────────────────────
// LABELS
// ─────────────────────────────────────────────

vol_str(float v) =>
    string s = v >= 1e9 ? str.tostring(math.round(v / 1e9, 2)) + "B" :
               v >= 1e6 ? str.tostring(math.round(v / 1e6, 2)) + "M" :
               v >= 1e3 ? str.tostring(math.round(v / 1e3, 1)) + "K" :
                          str.tostring(math.round(v))
    s

if show_labels and (is_hve or is_hvy_only)
    string lbl_title = is_hve ? "HVE: " : "HVY: "
    string lbl_vol   = show_abs_vol ? vol_str(volume) : ""
    string lbl_pct   = show_pct ? " (+" + str.tostring(math.round(pct_above_ma, 1)) + "% Ø)" : ""
    string lbl_text  = lbl_title + lbl_vol + lbl_pct
    color  txt_color = is_hve ? color.new(color.yellow, 0) : color.new(color.white, 0)

    label.new(
         x         = bar_index,
         y         = volume,
         text      = lbl_text,
         style     = label.style_none,
         color     = color.new(color.white, 100),
         textcolor = txt_color,
         size      = size.small,
         yloc      = yloc.price)
````
