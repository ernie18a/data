# Market Structure Break & Order Block - Improved By SPARTAN

- url: https://www.tradingview.com/script/qpDhxsTR-Market-Structure-Break-Order-Block-Improved-By-SPARTAN/
- type: indicator
- pine_id: PUB;513e4a4bcce7469793d634b079a14507
- version: 1.0

## Description

This indicator combines market structure break detection with Order Block and Breaker Block zone mapping into a single, cohesive tool. It is built on the open-source MSB-OB concept by EmreKb (Mozilla Public License 2.0, https://www.tradingview.com/v/DkE7UniD/) and has been substantially rewritten with a focus on accuracy, practicality, and removing several logical flaws present in similar tools.


HOW IT WORKS

Market structure is identified through a zigzag algorithm that tracks swing highs and lows over a user-defined lookback period. A bullish Market Structure Break (MSB) is confirmed when price takes out the previous significant swing high by a minimum threshold expressed as a fraction of the prior swing range — the Fib Factor setting. A bearish MSB requires the equivalent to the downside. All structure breaks are confirmed only on bar close to prevent repainting.

Once a structure break is confirmed, the indicator identifies the relevant Order Block: the last candle of the opposite colour in the swing that preceded the break. For a bullish MSB, this is the last bearish candle in the prior downswing. For a bearish MSB, it is the last bullish candle in the prior upswing. This candle's high-to-low range is drawn as a zone and tracked going forward.

Breaker Blocks are also identified: these are zones from a prior swing that price has since broken through and is now returning to, flipping the original supply or demand area to the opposite role. The indicator distinguishes between Breaker Blocks (full structural flip) and Mitigation Blocks (partial), and labels them accordingly.


ZONE MANAGEMENT

Each zone is tracked individually. The indicator monitors whether price closes inside, outside, or through each zone every bar. Zones are removed from the chart when price closes beyond them, keeping the chart clean and relevant.

A cap on the maximum number of active zones per zone type can be set by the user. When the cap is reached, the oldest zone is removed automatically. This prevents the indicator from silently hitting TradingView's hard object limits on long charts or active markets.

The zone extension mode can be set to either dynamic (zones stretch to the right until broken) or fixed-length (zones extend a set number of bars and stop).


ZONE QUALITY FEATURES

Each zone is scored at creation using the ratio of the forming candle's body size to the 14-period ATR. Zones are classified as Strong, Moderate, or Weak based on user-adjustable thresholds. Stronger candles produce more opaque zone fills so higher-quality zones are visually prominent without cluttering the chart.

Zones formed on above-average volume (relative to the 20-bar simple moving average) are flagged with a Vol+ tag. High-volume Order Blocks tend to represent periods of significant institutional activity and are generally more likely to hold on a return.

Each zone displays a tap count that tracks how many times price has entered it. The count increments only on an outside-to-inside transition based on closing price, not on every bar that price happens to spend inside the zone. A zone that has never been entered is marked as pristine. First touches of untested zones are generally the highest-probability setups.

When price wicks into a zone — including cases where the wick passes entirely through the zone — but the bar closes on the correct side, the zone border switches to dashed. This signals that the zone has been tested without being invalidated, which is a meaningful distinction from a zone that has never been touched.

A dashed CE line (Consequent Encroachment) is drawn at the exact midpoint of each zone. This is the 50% level of the Order Block range, which is commonly used as a precise entry reference within the zone.

When an Order Block and a Breaker Block of the same direction overlap, a compact confluence marker is placed at the left edge of the Order Block zone. Overlapping supply or demand areas are generally considered stronger than isolated ones. The marker fires only once per zone pair regardless of how long both zones remain active.


FAILED MSB DETECTION

When a structure break occurs and price reverses within a configurable number of bars, the indicator can flag this as a Failed MSB. To reduce false positives, the reversal must also exceed a minimum magnitude expressed as a fraction of the prior swing range. A reversal that retraces less than this threshold — which may just be normal noise after the break — is ignored. Failed MSBs are a common setup for counter-trend moves and fakeout entries.


HIGHER TIMEFRAME REFERENCE

An optional higher timeframe reference line can be enabled. This draws a horizontal line at the midpoint of the most recent bar on the selected higher timeframe. The line is extended across the chart and can be used as a broad directional bias reference. The line is redrawn only when the higher timeframe midpoint changes, not on every bar, avoiding unnecessary flickering on live charts.


ALERTS

Alert conditions are available for: any MSB, bullish MSB only, bearish MSB only, Failed MSB, and individual zone entries (Bu-OB, Be-OB, Bu-BB, Be-BB). Zone entry alerts fire once per bar close on first touch only.


SETTINGS OVERVIEW

Core Settings: zigzag length, fib factor threshold, label text size, broken zone deletion toggle.
Block Display: separate toggles for Order Blocks and Breaker Blocks, fixed vs dynamic extension, block length in bars, max active zones per type.
OB Strength: strength label toggle, volume flag toggle, adjustable strong and weak body/ATR thresholds.
Zone Tap Counter: toggle for pristine and tap count display.
Mitigation Visuals: toggle for dashed border on wick-tested zones.
CE Level: toggle and color for the 50% midpoint line.
Confluence: toggle, color, text color, and size for the confluence marker.
MSB Labels: toggle for MSB labels, Failed MSB toggle, lookback bars, and minimum reversal percentage.
Multi-Timeframe: HTF level toggle, timeframe selection, line style, color, width, and bars back.
Colors: fully customizable fill, border, and text colors for each of the four zone types.


NOTES

This script is published open-source under the Mozilla Public License 2.0. It is a derivative of EmreKb's original MSB-OB indicator and credit is given accordingly. The original concept has been significantly reworked at the logic level: zone deletion direction for Breaker Blocks has been corrected, tap counting has been rebuilt to track transitions rather than bar presence, the Failed MSB filter now requires a magnitude condition alongside the bar count, confluence labeling is guarded against duplicate firing, and higher timeframe line rendering no longer redraws unnecessarily every bar.

This script is intended as an analytical tool and does not constitute financial advice. Past zone reactions do not guarantee future behaviour.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SpartanH47
//@version=6
indicator("Market Structure Break & Order Block - By SPARTAN", "MSB-OB·SR", overlay=true,
     max_lines_count=500, max_bars_back=4900, max_boxes_count=500, max_labels_count=500)

// ─── GROUP LABELS ─────────────────────────────────────────────────────────────
grp_main  = "⚙ Core Settings"
grp_box   = "📦 Block Display"
grp_mtf   = "🔭 Multi-Timeframe"
grp_ob    = "🟢 Bu-OB Colors"
grp_beob  = "🔴 Be-OB Colors"
grp_bubb  = "🟢 Bu-BB / Bu-MB Colors"
grp_bebb  = "🔴 Be-BB / Be-MB Colors"
grp_str   = "📊 OB Strength & Scoring"
grp_tap   = "👆 Zone Tap Counter"
grp_mit   = "🔵 Mitigation Visuals"
grp_ce    = "〰 CE (50%) Level"
grp_conf  = "⚡ Confluence"
grp_msb   = "💡 MSB Labels"

// ─── CORE SETTINGS ────────────────────────────────────────────────────────────
zigzag_len = input.int(9, "ZigZag Length", minval=2, group=grp_main,
     tooltip="Number of bars used to detect swing highs and lows. Higher = fewer but more significant pivots.")

show_zigzag = input.bool(false, "Show ZigZag", group=grp_main,
     tooltip="Toggle the dashed zigzag lines that connect swing highs and lows.")

fib_factor = input.float(0.33, "Fib Factor", minval=0, maxval=1, step=0.01, group=grp_main,
     tooltip="Minimum move size (as fraction of swing range) required to confirm a Market Structure Break.")

text_size = input.string(size.tiny, "Label Text Size",
     [size.tiny, size.small, size.normal, size.large, size.huge], group=grp_main,
     tooltip="Controls the font size of all text labels on Order Block and Breaker Block zones.")

delete_boxes = input.bool(true, "Delete Broken Zones", group=grp_main,
     tooltip="When enabled, zones are automatically removed once price closes beyond them.")

// ─── BLOCK DISPLAY ────────────────────────────────────────────────────────────
show_ob = input.bool(true, "Show Order Blocks (OB)", group=grp_box,
     tooltip="Toggle all Order Block zones on or off. Order Blocks are the last opposing candle before a Market Structure Break.")

show_bb = input.bool(false, "Show Breaker Blocks (BB / MB)", group=grp_box,
     tooltip="Toggle all Breaker Block and Mitigation Block zones on or off. Breaker Blocks are former Order Blocks that price has broken through and returned to.")

fixed_length_on = input.bool(true, "Fixed Block Length", group=grp_box,
     tooltip="When ON, blocks extend a fixed number of bars to the right instead of stretching until mitigated.")

box_bar_len = input.int(80, "Block Length (bars)", minval=5, maxval=500, group=grp_box,
     tooltip="Number of bars each zone extends to the right. Only active when 'Fixed Block Length' is ON.")

max_zones = input.int(10, "Max Active Zones Per Type", minval=1, maxval=20, group=grp_box,
     tooltip="Maximum number of active zones kept per type (Bu-OB, Be-OB, Bu-BB, Be-BB). Oldest zones are removed first when the cap is hit.")

// ─── MULTI-TIMEFRAME ──────────────────────────────────────────────────────────
show_htf = input.bool(false, "Show HTF Structure Level", group=grp_mtf,
     tooltip="Draws a horizontal line at the midpoint of the last Higher Timeframe bar's range.")

htf_tf = input.timeframe("D", "Higher Timeframe", group=grp_mtf,
     tooltip="The timeframe used to calculate the HTF structure level.")

htf_line_color = input.color(color.new(color.yellow, 30), "HTF Line Color", group=grp_mtf)
htf_line_width = input.int(1, "HTF Line Width", minval=1, maxval=4, group=grp_mtf)
htf_line_style = input.string("Dotted", "HTF Line Style", ["Solid", "Dashed", "Dotted"], group=grp_mtf)
htf_lookback   = input.int(200, "HTF Line — Bars Back", minval=10, maxval=500, group=grp_mtf,
     tooltip="How far left (in current chart bars) the HTF line extends.")

// ─── OB STRENGTH ──────────────────────────────────────────────────────────────
show_strength = input.bool(true, "Show Strength Label", group=grp_str,
     tooltip="Displays a strength rating (●●● Strong / ●●○ Moderate / ●○○ Weak) inside each zone.")

vol_filter = input.bool(true, "Flag Volume-Weighted OBs", group=grp_str,
     tooltip="Adds a ↑Vol tag to Order Blocks formed on above-average volume (20-bar SMA).")

strong_thresh = input.float(0.70, "Strong OB: min body/ATR", minval=0.1, maxval=2.0, step=0.05, group=grp_str,
     tooltip="Body-to-ATR ratio above which a zone is classified as Strong.")

weak_thresh = input.float(0.30, "Weak OB: max body/ATR", minval=0.0, maxval=1.0, step=0.05, group=grp_str,
     tooltip="Body-to-ATR ratio below which a zone is classified as Weak.")

// ─── ZONE TAP COUNTER ─────────────────────────────────────────────────────────
show_taps = input.bool(false, "Show Tap Count", group=grp_tap,
     tooltip="Tracks how many times price has ENTERED each zone (outside to inside transition only, not bars spent inside). A star = pristine (never touched). Shown as [1x], [2x] etc.")

// ─── MITIGATION VISUALS ───────────────────────────────────────────────────────
show_mitigation = input.bool(true, "Show Partial Mitigation (Dashed Border)", group=grp_mit,
     tooltip="When price wicks into or through a zone but does not close beyond it, the border switches to dashed. Zone is tested but still valid.")

// ─── CE (50%) LEVEL ───────────────────────────────────────────────────────────
show_ce = input.bool(true, "Show CE (50%) Level", group=grp_ce,
     tooltip="Draws a dashed midpoint line (Consequent Encroachment) inside each zone at the exact 50% level. The level Smart Money traders watch for reaction.")

ce_color = input.color(color.new(color.white, 40), "CE Line Color", group=grp_ce)

// ─── CONFLUENCE ───────────────────────────────────────────────────────────────
show_confluence = input.bool(false, "Show Confluence Marker", group=grp_conf,
     tooltip="When an Order Block and a Breaker Block overlap, a compact marker is placed at the left edge of the OB zone to highlight the confluence. Fires only once per zone pair.")

conf_color  = input.color(color.new(color.yellow, 0), "Marker Color", group=grp_conf, inline="conf")
conf_tcolor = input.color(color.new(color.black,  0), "Text Color",   group=grp_conf, inline="conf")
conf_size   = input.string(size.small, "Marker Size",
     [size.tiny, size.small, size.normal, size.large], group=grp_conf,
     tooltip="Size of the confluence marker label.")

// ─── MSB LABELS ───────────────────────────────────────────────────────────────
show_msb_label = input.bool(true, "Show MSB Labels", group=grp_msb,
     tooltip="Displays a bullish or bearish MSB label at each confirmed Market Structure Break.")

show_failed_msb = input.bool(false, "Show Failed MSB Labels", group=grp_msb,
     tooltip="Labels a Failed MSB when price breaks structure but quickly reverses with enough magnitude.")

failed_msb_bars = input.int(5, "Failed MSB Look-Back (bars)", minval=1, maxval=20, group=grp_msb,
     tooltip="How many bars after an MSB price is allowed to reverse before the break is considered failed.")

failed_msb_min_pct = input.float(0.30, "Failed MSB Min Reversal (%)", minval=0.05, maxval=1.0, step=0.05, group=grp_msb,
     tooltip="Minimum reversal size as a fraction of the prior swing range to qualify as a Failed MSB. Guards against trivial pullbacks being mislabeled.")

// ─── COLORS ───────────────────────────────────────────────────────────────────
bu_ob_border_color = input.color(color.green,                 "Fill   Border   Text", group=grp_ob,   inline="buob")
bu_ob_color        = input.color(color.new(color.green,  70), "",                     group=grp_ob,   inline="buob")
bu_ob_text_color   = input.color(color.green,                 "",                     group=grp_ob,   inline="buob")

be_ob_border_color = input.color(color.red,                   "Fill   Border   Text", group=grp_beob, inline="beob")
be_ob_color        = input.color(color.new(color.red,    70), "",                     group=grp_beob, inline="beob")
be_ob_text_color   = input.color(color.red,                   "",                     group=grp_beob, inline="beob")

bu_bb_border_color = input.color(color.teal,                  "Fill   Border   Text", group=grp_bubb, inline="bubb")
bu_bb_color        = input.color(color.new(color.teal,   70), "",                     group=grp_bubb, inline="bubb")
bu_bb_text_color   = input.color(color.teal,                  "",                     group=grp_bubb, inline="bubb")

be_bb_border_color = input.color(color.orange,                "Fill   Border   Text", group=grp_bebb, inline="bebb")
be_bb_color        = input.color(color.new(color.orange, 70), "",                     group=grp_bebb, inline="bebb")
be_bb_text_color   = input.color(color.orange,                "",                     group=grp_bebb, inline="bebb")

// ─── USER-DEFINED TYPE ────────────────────────────────────────────────────────
type ZoneInfo
    box    bx
    line   ce_line
    int    taps
    bool   inside_prev       // was the close inside this zone last bar?
    bool   wick_tested       // has a wick touched or blown through this zone?
    bool   vol_weighted
    float  strength_ratio
    string label_str
    int    created_bar
    bool   confluence_labeled

// ─── ARRAYS ───────────────────────────────────────────────────────────────────
var array<float>    high_points_arr = array.new<float>(0)
var array<int>      high_index_arr  = array.new<int>(0)
var array<float>    low_points_arr  = array.new<float>(0)
var array<int>      low_index_arr   = array.new<int>(0)

var array<ZoneInfo> bu_ob_zones = array.new<ZoneInfo>(0)
var array<ZoneInfo> be_ob_zones = array.new<ZoneInfo>(0)
var array<ZoneInfo> bu_bb_zones = array.new<ZoneInfo>(0)
var array<ZoneInfo> be_bb_zones = array.new<ZoneInfo>(0)

// ─── BOX RIGHT EDGE ───────────────────────────────────────────────────────────
tf_secs = timeframe.in_seconds()
dyn_ext = tf_secs <= 60 ? 30 : tf_secs <= 300 ? 20 : tf_secs <= 900 ? 15 : tf_secs <= 3600 ? 12 : tf_secs <= 14400 ? 10 : 8

f_right_edge(int created_at) =>
    fixed_length_on ? created_at + box_bar_len : bar_index + dyn_ext

// ─── ATR & VOLUME ─────────────────────────────────────────────────────────────
atr14   = ta.atr(14)
avg_vol = ta.sma(volume, 20)

// ─── HTF REQUEST ─────────────────────────────────────────────────────────────
[htf_h, htf_l] = request.security(syminfo.tickerid, htf_tf, [high, low])
htf_mid         = math.avg(htf_h, htf_l)

// ─── HELPERS ──────────────────────────────────────────────────────────────────
MAX_BACK = 4898

f_safe_offset(int offset) =>
    math.min(offset, MAX_BACK)

f_ob_strength(int offset) =>
    s    = f_safe_offset(offset)
    body = math.abs(open[s] - close[s])
    atr14 != 0.0 ? body / atr14 : 0.0

f_strength_label(float ratio) =>
    ratio >= strong_thresh ? "Strong" : ratio >= weak_thresh ? "Moderate" : "Weak"

f_strength_alpha(float ratio) =>
    int a = ratio >= strong_thresh ? 50 : ratio >= weak_thresh ? 65 : 80
    a

f_vol_weighted(int offset) =>
    s = f_safe_offset(offset)
    vol_filter and volume[s] > avg_vol

f_tap_suffix(int taps) =>
    show_taps ? (taps == 0 ? " [P]" : " [" + str.tostring(taps) + "x]") : ""

f_confluence(float top1, float bot1, float top2, float bot2) =>
    not (bot1 > top2 or bot2 > top1)

f_htf_style() =>
    htf_line_style == "Solid" ? line.style_solid : htf_line_style == "Dashed" ? line.style_dashed : line.style_dotted

// ─── ZONE CAP ────────────────────────────────────────────────────────────────
f_cap_zones(array<ZoneInfo> zones) =>
    while array.size(zones) > max_zones
        z = array.shift(zones)
        box.delete(z.bx)
        if not na(z.ce_line)
            line.delete(z.ce_line)

// ─── CE LINE ─────────────────────────────────────────────────────────────────
f_make_ce_line(float top, float bot, int left, int right) =>
    mid = math.avg(top, bot)
    show_ce ? line.new(left, mid, right, mid,
         color=ce_color, style=line.style_dashed, width=1) : line(na)

// ─── ZIGZAG ───────────────────────────────────────────────────────────────────
to_up   = high >= ta.highest(zigzag_len)
to_down = low  <= ta.lowest(zigzag_len)

var int trend = 1
trend := trend == 1 and to_down ? -1 : trend == -1 and to_up ? 1 : trend

last_trend_up_since   = ta.barssince(to_up[1])
low_val               = ta.lowest(nz(last_trend_up_since > 0 ? last_trend_up_since : 1, 1))
low_index             = bar_index - ta.barssince(low_val == low)

last_trend_down_since = ta.barssince(to_down[1])
high_val              = ta.highest(nz(last_trend_down_since > 0 ? last_trend_down_since : 1, 1))
high_index            = bar_index - ta.barssince(high_val == high)

trend_changed = ta.change(trend) != 0

if trend_changed
    if trend == 1
        array.push(low_points_arr,  low_val)
        array.push(low_index_arr,   low_index)
    if trend == -1
        array.push(high_points_arr, high_val)
        array.push(high_index_arr,  high_index)

// ─── SWING ACCESSORS ──────────────────────────────────────────────────────────
f_get_high(int ind) =>
    sz = array.size(high_points_arr)
    i  = sz - 1 - ind
    [i >= 0 ? array.get(high_points_arr, i) : float(na),
     i >= 0 ? array.get(high_index_arr,  i) : int(na)]

f_get_low(int ind) =>
    sz = array.size(low_points_arr)
    i  = sz - 1 - ind
    [i >= 0 ? array.get(low_points_arr, i) : float(na),
     i >= 0 ? array.get(low_index_arr,  i) : int(na)]

[h0, h0i] = f_get_high(0)
[h1, h1i] = f_get_high(1)
[l0, l0i] = f_get_low(0)
[l1, l1i] = f_get_low(1)

// ─── ZIGZAG LINES ─────────────────────────────────────────────────────────────
if trend_changed and show_zigzag
    if trend == 1 and not na(h0i) and not na(l0i)
        line.new(h0i, h0, l0i, l0, color=color.gray, style=line.style_dashed)
    if trend == -1 and not na(l0i) and not na(h0i)
        line.new(l0i, l0, h0i, h0, color=color.gray, style=line.style_dashed)

// ─── MARKET STRUCTURE ────────────────────────────────────────────────────────
var int market = 1

last_l0 = ta.valuewhen(ta.change(market) != 0, l0, 0)
last_h0 = ta.valuewhen(ta.change(market) != 0, h0, 0)

if barstate.isconfirmed
    bool same_pivot = last_l0 == l0 or last_h0 == h0
    bool cond_bull  = not same_pivot and market == -1 and h0 > h1 and h0 > h1 + math.abs(h1 - l0) * fib_factor
    bool cond_bear  = not same_pivot and market == 1  and l0 < l1 and l0 < l1 - math.abs(h0 - l1) * fib_factor
    market         := cond_bull ? 1 : cond_bear ? -1 : market

market_changed = ta.change(market) != 0

// ─── FAILED MSB ───────────────────────────────────────────────────────────────
var int   msb_bar        = na
var int   msb_direction  = 0
var float msb_level      = na
var float msb_swing_size = na

if market_changed
    msb_bar        := bar_index
    msb_direction  := market
    msb_level      := market == 1 ? h1 : l1
    msb_swing_size := market == 1 ? math.abs(h1 - l0) : math.abs(h0 - l1)

bool failed_msb = false
if show_failed_msb and not na(msb_bar)
    bars_since   = bar_index - msb_bar
    min_reversal = nz(msb_swing_size, 0.0) * failed_msb_min_pct
    if bars_since <= failed_msb_bars and bars_since > 0
        if msb_direction == 1 and close < msb_level and (msb_level - close) >= min_reversal
            failed_msb := true
            msb_bar     := na
        if msb_direction == -1 and close > msb_level and (close - msb_level) >= min_reversal
            failed_msb := true
            msb_bar     := na

if failed_msb
    label.new(bar_index, msb_direction == 1 ? low : high,
         "X Failed MSB",
         color     = color.new(color.purple, 20),
         style     = msb_direction == 1 ? label.style_label_up : label.style_label_down,
         textcolor = color.white,
         size      = size.small)

// ─── OB SEARCH ───────────────────────────────────────────────────────────────
var int bu_ob_bi = na
var int be_ob_bi = na
var int bu_bb_bi = na
var int be_bb_bi = na

bu_ob_bi := na
be_ob_bi := na
bu_bb_bi := na
be_bb_bi := na

if not na(h1i) and not na(l0i) and h1i <= l0i
    for i = h1i to l0i
        offset = bar_index - i
        if offset >= 0 and offset < MAX_BACK
            if open[offset] > close[offset]
                bu_ob_bi := bar_index[offset]

if not na(l1i) and not na(h0i) and l1i <= h0i
    for i = l1i to h0i
        offset = bar_index - i
        if offset >= 0 and offset < MAX_BACK
            if open[offset] < close[offset]
                be_ob_bi := bar_index[offset]

if not na(l1i) and not na(h1i) and (l1i - zigzag_len) <= h1i
    for i = l1i - zigzag_len to h1i
        offset = bar_index - i
        if offset >= 0 and offset < MAX_BACK
            if open[offset] < close[offset]
                bu_bb_bi := bar_index[offset]

if not na(h1i) and not na(l1i) and (h1i - zigzag_len) <= l1i
    for i = h1i - zigzag_len to l1i
        offset = bar_index - i
        if offset >= 0 and offset < MAX_BACK
            if open[offset] > close[offset]
                be_bb_bi := bar_index[offset]

// ─── MSB + ZONE CREATION ─────────────────────────────────────────────────────
// IMPORTANT: inside_prev is initialised to reflect whether price is ALREADY
// inside the zone at creation time. Without this, the very first management
// bar would always fire a tap for any zone that forms while price is nearby.

if market_changed and barstate.isconfirmed
    if market == 1
        if show_msb_label and not na(h1i) and not na(l0i)
            line.new(h1i, h1, h0i, h1, color=color.green, width=2)
            label.new(int(math.avg(h1i, l0i)), h1, "MSB+",
                 color=color.new(color.black, 100), style=label.style_label_down,
                 textcolor=color.green, size=size.small)

        if show_ob and not na(bu_ob_bi)
            s          = f_safe_offset(bar_index - bu_ob_bi)
            ratio      = f_ob_strength(bar_index - bu_ob_bi)
            is_vol     = f_vol_weighted(bar_index - bu_ob_bi)
            lbl_txt    = "Bu-OB  " + (show_strength ? f_strength_label(ratio) : "") + (is_vol ? "  Vol+" : "")
            r_edge     = f_right_edge(bu_ob_bi)
            zone_top   = high[s]
            zone_bot   = low[s]
            already_in = close >= zone_bot and close <= zone_top
            bx         = box.new(bu_ob_bi, zone_top, r_edge, zone_bot,
                 bgcolor      = color.new(color.green, f_strength_alpha(ratio)),
                 border_color = bu_ob_border_color,
                 text         = lbl_txt + f_tap_suffix(0),
                 text_color   = bu_ob_text_color,
                 text_halign  = text.align_right,
                 text_size    = text_size)
            ce = f_make_ce_line(zone_top, zone_bot, bu_ob_bi, r_edge)
            array.push(bu_ob_zones, ZoneInfo.new(bx, ce, 0, already_in, false, is_vol, ratio, lbl_txt, bu_ob_bi, false))
            f_cap_zones(bu_ob_zones)

        if show_bb and not na(bu_bb_bi)
            s          = f_safe_offset(bar_index - bu_bb_bi)
            ratio      = f_ob_strength(bar_index - bu_bb_bi)
            is_vol     = f_vol_weighted(bar_index - bu_bb_bi)
            lbl_txt    = (l0 < l1 ? "Bu-BB" : "Bu-MB") + "  " + (show_strength ? f_strength_label(ratio) : "") + (is_vol ? "  Vol+" : "")
            r_edge     = f_right_edge(bu_bb_bi)
            zone_top   = high[s]
            zone_bot   = low[s]
            already_in = close >= zone_bot and close <= zone_top
            bx         = box.new(bu_bb_bi, zone_top, r_edge, zone_bot,
                 bgcolor      = color.new(color.teal, f_strength_alpha(ratio)),
                 border_color = bu_bb_border_color,
                 text         = lbl_txt + f_tap_suffix(0),
                 text_color   = bu_bb_text_color,
                 text_halign  = text.align_right,
                 text_size    = text_size)
            ce = f_make_ce_line(zone_top, zone_bot, bu_bb_bi, r_edge)
            array.push(bu_bb_zones, ZoneInfo.new(bx, ce, 0, already_in, false, is_vol, ratio, lbl_txt, bu_bb_bi, false))
            f_cap_zones(bu_bb_zones)

    if market == -1
        if show_msb_label and not na(l1i) and not na(h0i)
            line.new(l1i, l1, l0i, l1, color=color.red, width=2)
            label.new(int(math.avg(l1i, h0i)), l1, "MSB-",
                 color=color.new(color.black, 100), style=label.style_label_up,
                 textcolor=color.red, size=size.small)

        if show_ob and not na(be_ob_bi)
            s          = f_safe_offset(bar_index - be_ob_bi)
            ratio      = f_ob_strength(bar_index - be_ob_bi)
            is_vol     = f_vol_weighted(bar_index - be_ob_bi)
            lbl_txt    = "Be-OB  " + (show_strength ? f_strength_label(ratio) : "") + (is_vol ? "  Vol+" : "")
            r_edge     = f_right_edge(be_ob_bi)
            zone_top   = high[s]
            zone_bot   = low[s]
            already_in = close >= zone_bot and close <= zone_top
            bx         = box.new(be_ob_bi, zone_top, r_edge, zone_bot,
                 bgcolor      = color.new(color.red, f_strength_alpha(ratio)),
                 border_color = be_ob_border_color,
                 text         = lbl_txt + f_tap_suffix(0),
                 text_color   = be_ob_text_color,
                 text_halign  = text.align_right,
                 text_size    = text_size)
            ce = f_make_ce_line(zone_top, zone_bot, be_ob_bi, r_edge)
            array.push(be_ob_zones, ZoneInfo.new(bx, ce, 0, already_in, false, is_vol, ratio, lbl_txt, be_ob_bi, false))
            f_cap_zones(be_ob_zones)

        if show_bb and not na(be_bb_bi)
            s          = f_safe_offset(bar_index - be_bb_bi)
            ratio      = f_ob_strength(bar_index - be_bb_bi)
            is_vol     = f_vol_weighted(bar_index - be_bb_bi)
            lbl_txt    = (h0 > h1 ? "Be-BB" : "Be-MB") + "  " + (show_strength ? f_strength_label(ratio) : "") + (is_vol ? "  Vol+" : "")
            r_edge     = f_right_edge(be_bb_bi)
            zone_top   = high[s]
            zone_bot   = low[s]
            already_in = close >= zone_bot and close <= zone_top
            bx         = box.new(be_bb_bi, zone_top, r_edge, zone_bot,
                 bgcolor      = color.new(color.orange, f_strength_alpha(ratio)),
                 border_color = be_bb_border_color,
                 text         = lbl_txt + f_tap_suffix(0),
                 text_color   = be_bb_text_color,
                 text_halign  = text.align_right,
                 text_size    = text_size)
            ce = f_make_ce_line(zone_top, zone_bot, be_bb_bi, r_edge)
            array.push(be_bb_zones, ZoneInfo.new(bx, ce, 0, already_in, false, is_vol, ratio, lbl_txt, be_bb_bi, false))
            f_cap_zones(be_bb_zones)

// ─── ZONE MANAGEMENT ─────────────────────────────────────────────────────────
// TAP COUNT:
//   A tap increments only on an outside->inside transition (close-based).
//   inside_prev was initialised at zone creation to avoid false first-bar taps.
//
// WICK DETECTION (two cases per zone direction):
//   Case A — wick enters zone, close is outside zone:
//            low in [btm, top] for bull zones (close > top)
//            high in [btm, top] for bear zones (close < btm)
//   Case B — wick blows completely THROUGH the zone, close still on correct side:
//            low < btm but close >= btm for bull zones
//            high > top but close <= top for bear zones
//   Both cases set wick_tested and apply dashed border without incrementing taps.

f_update_ce_right(ZoneInfo z, int r) =>
    if show_ce and not na(z.ce_line)
        line.set_x2(z.ce_line, r)

f_delete_zone(ZoneInfo z) =>
    if delete_boxes
        box.delete(z.bx)
    if not na(z.ce_line)
        line.delete(z.ce_line)

// ── Bullish OB ──
if array.size(bu_ob_zones) > 0
    for i = array.size(bu_ob_zones) - 1 to 0
        z   = array.get(bu_ob_zones, i)
        btm = box.get_bottom(z.bx)
        top = box.get_top(z.bx)

        if close < btm
            f_delete_zone(z)
            array.remove(bu_ob_zones, i)
        else
            price_inside = close >= btm and close <= top
            wick_in_zone = low >= btm and low <= top and close > top   // wick dips in, close above
            wick_thru    = low < btm and close >= btm                  // wick blows through, close holds above btm

            if price_inside and not z.inside_prev
                if z.taps == 0
                    alert("Bu-OB zone entered", alert.freq_once_per_bar_close)
                z.taps := z.taps + 1
                box.set_text(z.bx, z.label_str + f_tap_suffix(z.taps))

            if (wick_in_zone or wick_thru) and not z.wick_tested
                z.wick_tested := true
                if show_mitigation
                    box.set_border_style(z.bx, line.style_dashed)

            z.inside_prev := price_inside

            if not fixed_length_on
                r = bar_index + dyn_ext
                box.set_right(z.bx, r)
                f_update_ce_right(z, r)

// ── Bearish OB ──
if array.size(be_ob_zones) > 0
    for i = array.size(be_ob_zones) - 1 to 0
        z   = array.get(be_ob_zones, i)
        top = box.get_top(z.bx)
        btm = box.get_bottom(z.bx)

        if close > top
            f_delete_zone(z)
            array.remove(be_ob_zones, i)
        else
            price_inside = close >= btm and close <= top
            wick_in_zone = high >= btm and high <= top and close < btm  // wick pokes in from below, close below
            wick_thru    = high > top and close <= top                  // wick blows through from below, close holds below top

            if price_inside and not z.inside_prev
                if z.taps == 0
                    alert("Be-OB zone entered", alert.freq_once_per_bar_close)
                z.taps := z.taps + 1
                box.set_text(z.bx, z.label_str + f_tap_suffix(z.taps))

            if (wick_in_zone or wick_thru) and not z.wick_tested
                z.wick_tested := true
                if show_mitigation
                    box.set_border_style(z.bx, line.style_dashed)

            z.inside_prev := price_inside

            if not fixed_length_on
                r = bar_index + dyn_ext
                box.set_right(z.bx, r)
                f_update_ce_right(z, r)

// ── Bullish BB ──
// A Bu-BB sits ABOVE current price at creation (price broke up through it and
// is returning from below). It is only invalidated when price closes ABOVE the
// top of the zone without holding — i.e. blows through it to the upside again.
// Deleting on close < btm (the OB rule) was wrong: that condition is true from
// the moment the zone is created, so it was deleted immediately every time.
if array.size(bu_bb_zones) > 0
    for i = array.size(bu_bb_zones) - 1 to 0
        z   = array.get(bu_bb_zones, i)
        btm = box.get_bottom(z.bx)
        top = box.get_top(z.bx)

        if close > top
            // Price closed above the zone — BB is consumed / broken
            f_delete_zone(z)
            array.remove(bu_bb_zones, i)
        else
            price_inside = close >= btm and close <= top
            // Wick case A: wick pokes up into zone from below, close still below zone
            wick_in_zone = high >= btm and high <= top and close < btm
            // Wick case B: wick blows completely through zone from below, close holds below top
            wick_thru    = high > top and close <= top

            if price_inside and not z.inside_prev
                if z.taps == 0
                    alert("Bu-BB zone entered", alert.freq_once_per_bar_close)
                z.taps := z.taps + 1
                box.set_text(z.bx, z.label_str + f_tap_suffix(z.taps))

            if (wick_in_zone or wick_thru) and not z.wick_tested
                z.wick_tested := true
                if show_mitigation
                    box.set_border_style(z.bx, line.style_dashed)

            z.inside_prev := price_inside

            if not fixed_length_on
                r = bar_index + dyn_ext
                box.set_right(z.bx, r)
                f_update_ce_right(z, r)

// ── Bearish BB ──
// A Be-BB sits BELOW current price at creation (price broke down through it and
// is returning from above). It is invalidated when price closes BELOW the
// bottom — blowing through it to the downside again.
// Deleting on close > top was wrong for the same reason as above.
if array.size(be_bb_zones) > 0
    for i = array.size(be_bb_zones) - 1 to 0
        z   = array.get(be_bb_zones, i)
        top = box.get_top(z.bx)
        btm = box.get_bottom(z.bx)

        if close < btm
            // Price closed below the zone — BB is consumed / broken
            f_delete_zone(z)
            array.remove(be_bb_zones, i)
        else
            price_inside = close >= btm and close <= top
            // Wick case A: wick dips down into zone from above, close still above zone
            wick_in_zone = low >= btm and low <= top and close > top
            // Wick case B: wick blows completely through zone from above, close holds above btm
            wick_thru    = low < btm and close >= btm

            if price_inside and not z.inside_prev
                if z.taps == 0
                    alert("Be-BB zone entered", alert.freq_once_per_bar_close)
                z.taps := z.taps + 1
                box.set_text(z.bx, z.label_str + f_tap_suffix(z.taps))

            if (wick_in_zone or wick_thru) and not z.wick_tested
                z.wick_tested := true
                if show_mitigation
                    box.set_border_style(z.bx, line.style_dashed)

            z.inside_prev := price_inside

            if not fixed_length_on
                r = bar_index + dyn_ext
                box.set_right(z.bx, r)
                f_update_ce_right(z, r)

// ─── CONFLUENCE DETECTION ────────────────────────────────────────────────────
// Marker is a compact label pinned to the LEFT edge of the OB box at its
// midpoint. "CF+" for bullish, "CF-" for bearish. One label per zone pair.

if show_confluence and barstate.isconfirmed
    if array.size(bu_ob_zones) > 0 and array.size(bu_bb_zones) > 0
        for ob in bu_ob_zones
            if not ob.confluence_labeled
                for bb in bu_bb_zones
                    if f_confluence(box.get_top(ob.bx), box.get_bottom(ob.bx),
                                    box.get_top(bb.bx), box.get_bottom(bb.bx))
                        ob.confluence_labeled := true
                        label.new(
                             box.get_left(ob.bx),
                             math.avg(box.get_bottom(ob.bx), box.get_top(ob.bx)),
                             "CF+",
                             color     = conf_color,
                             textcolor = conf_tcolor,
                             style     = label.style_label_right,
                             size      = conf_size)
                        break

    if array.size(be_ob_zones) > 0 and array.size(be_bb_zones) > 0
        for ob in be_ob_zones
            if not ob.confluence_labeled
                for bb in be_bb_zones
                    if f_confluence(box.get_top(ob.bx), box.get_bottom(ob.bx),
                                    box.get_top(bb.bx), box.get_bottom(bb.bx))
                        ob.confluence_labeled := true
                        label.new(
                             box.get_left(ob.bx),
                             math.avg(box.get_bottom(ob.bx), box.get_top(ob.bx)),
                             "CF-",
                             color     = conf_color,
                             textcolor = conf_tcolor,
                             style     = label.style_label_right,
                             size      = conf_size)
                        break

// ─── HTF STRUCTURE LINE ───────────────────────────────────────────────────────
var line  htf_line     = na
var float htf_mid_prev = na

if show_htf
    if htf_mid != htf_mid_prev or na(htf_line)
        line.delete(htf_line)
        htf_line := line.new(bar_index - htf_lookback, htf_mid, bar_index + dyn_ext, htf_mid,
             color=htf_line_color, style=f_htf_style(), width=htf_line_width)
        htf_mid_prev := htf_mid
    else if not na(htf_line)
        line.set_x2(htf_line, bar_index + dyn_ext)

// ─── ALERT CONDITIONS ─────────────────────────────────────────────────────────
alertcondition(market_changed,                  "MSB Signal",  "Market Structure Break detected")
alertcondition(market_changed and market == 1,  "Bullish MSB", "Bullish MSB — potential long setup")
alertcondition(market_changed and market == -1, "Bearish MSB", "Bearish MSB — potential short setup")
alertcondition(failed_msb,                      "Failed MSB",  "MSB failed — potential reversal")
````
