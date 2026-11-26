# Confluence FVG Finder | ProjectSyndicate

- url: https://www.tradingview.com/script/wevLOpTE-Confluence-FVG-Finder-ProjectSyndicate/
- type: indicator
- pine_id: PUB;5c26d147650e457cbd16dbe628220b70
- version: 1.0

## Description

[b]Confluence FVG Finder automatically identifies and validates high-probability, non-repainting Fair Value Gaps. It filters for structural quality using an ATR-based imbalance filter, normalizes all zone heights for consistency, and embeds a live multi-timeframe confluence engine inside every zone to provide a quantifiable, data-driven edge.[/b]

🧠 Live Multi-Timeframe Engine — This is not a single-timeframe tool. Every FVG zone displayed on the chart is the result of a live, proximity-based confluence engine scanning three independent higher timeframes (default H1, H2, H4) simultaneously. Each label shows exactly how many timeframes confirmed the zone, its composite strength rating (0–10), the session it formed in, its age, and its exact pip height, giving you an instant structural edge.
🎯 Imbalance-Validated FVGs — The engine doesn't just mark any three-candle gap. It validates each Fair Value Gap on the higher timeframes by requiring the gap to exceed a user-defined multiple of ATR, filtering out insignificant micro-gaps and focusing only on imbalances that reflect true market-moving intent before they are even considered for merging.
🎨 ATR-Normalized Zones — Eliminates visual noise from inconsistent gap sizes. This feature forces every merged FVG zone to a uniform, ATR-based height (e.g., 0.75x ATR). This provides a clean, consistent chart and allows for a more objective analysis of price interaction with zones of equal visual weight, preventing oversized gaps from distorting the chart.
📊 Proximity-Based Merging — Timeframes rarely align perfectly to the pip. The confluence engine uses an intelligent ATR-based proximity tolerance to detect when Fair Value Gaps from different timeframes are clustered in the same price territory. It then mathematically merges them into a single, high-probability "Confluence Zone," ensuring you don't miss valid setups due to minor price discrepancies across timeframes.

✅ Chart-Timeframe Independent — The engine's credibility comes from its architectural stability. Each timeframe is detected entirely inside its own data context and every zone is anchored to the timestamp it formed on, so — unlike standard MTF indicators that repaint or shift zones depending on the chart you are viewing — the merged zones are mathematically identical whether you view them on a 5-minute, 15-minute, or 1-hour chart.
🔧 Fully Customizable — Control every aspect of the engine, including the 3 target timeframes (default H1 / H2 / H4), the Minimum Timeframe Confluence threshold (e.g., require 3 out of 3 TFs), the Proximity Tolerance multiplier, the Minimum Strength Filter, the per-timeframe strength bonus, the mitigation mode (Touch / Full Fill / 50% Fill), and the colors/visibility of Bullish and Bearish zones.
🔬 Why this algo is unique: Standard FVG indicators are subjective — often just shading every three-candle gap on the current timeframe with no proof of higher-timeframe alignment. The Confluence FVG Engine transforms this into an objective, multi-dimensional instrument. It doesn't just show you a gap; it proves the imbalance is backed by aligned intent across multiple timeframes, merging them into a single, undeniable area of interest on the exact chart you are viewing.

🌐 Apply to Gold (XAUUSD), Indices (US30, NAS100), Forex Majors, and Crypto. With the default H1 / H2 / H4 structure, execute from any timeframe at or below H1 (1m–1h) while the engine tracks the H1, H2, and H4 imbalances. The engine is designed for assets that exhibit clear impulsive moves and respect deep supply/demand dynamics.
🗂️ How to use this? The most critical metrics are the Timeframe Confluence Count and the Strength Rating. A zone confirmed by 3 timeframes with a Strength of 8.0+ indicates a massive structural edge. Consider only taking trades from these high-confluence zones that align with the prevailing higher-timeframe trend. The embedded label also shows the exact "pips away" distance, allowing for precise limit order placement. Note: Timeframe 1 is the anchor — keep your chart at or below it (H1 by default) so zones render exactly; an on-chart warning appears if your chart timeframe is set higher.

⚙️ IMPORTANT NOTICE: This indicator is a professional-grade tool designed to identify structural confluence. It should NOT be used as a standalone signal for entering trades blindly. Always use it in conjunction with your own trading strategy, price action analysis, and strict risk management to confirm trade setups.

## Source Code

````pine
//@version=6
indicator("Confluence FVG Finder", overlay=true, max_boxes_count=500, max_labels_count=500)

use_normalized_zones = input.bool(true,  "Normalize All Zone Heights",   group="Universal Zone Settings")
zone_height_method   = input.string("ATR Based", "Zone Height Method",   group="Universal Zone Settings", options=["ATR Based","Fixed Percentage"])
zone_height_atr_mult = input.float(0.75, "Zone Height (ATR Multiplier)", group="Universal Zone Settings", minval=0.1, maxval=3.0,  step=0.05)
zone_height_percent  = input.float(0.3,  "Zone Height (% of Price)",     group="Universal Zone Settings", minval=0.05, maxval=2.0, step=0.05)

showBullishFVG = input.bool(true, "Show Bullish FVG", group="FVG Detection")
showBearishFVG = input.bool(true, "Show Bearish FVG", group="FVG Detection")
max_zones      = input.int(8, "Max Zones Per Side", minval=1, maxval=50, group="FVG Detection")

tf1                = input.timeframe("60",  "Timeframe 1 (anchor / lowest)", group="Multi-Timeframe Confluence")
tf2                = input.timeframe("120", "Timeframe 2",                   group="Multi-Timeframe Confluence")
tf3                = input.timeframe("240", "Timeframe 3",                   group="Multi-Timeframe Confluence")
min_confluence     = input.int(2, "Minimum Timeframe Confluence", group="Multi-Timeframe Confluence", minval=2, maxval=3)
proximity_atr_mult = input.float(5.0, "Proximity Tolerance (x ATR)", group="Multi-Timeframe Confluence", minval=0.5, maxval=10.0, step=0.5)

enable_strength_rating = input.bool(true, "Enable Strength Rating", group="Strength Rating")
min_strength_filter    = input.float(3.0, "Minimum Strength Filter", group="Strength Rating", minval=0.0, maxval=10.0, step=0.5)
confluence_bonus       = input.float(0.5, "Strength Bonus Per Extra Timeframe", group="Strength Rating", minval=0.0, maxval=2.0, step=0.1)

bullishFVGColor    = input.color(color.new(color.green, 85), "Bullish FVG Color",  group="FVG Styling")
bearishFVGColor    = input.color(color.new(color.red,   85), "Bearish FVG Color",  group="FVG Styling")
bullishBorderColor = input.color(color.new(color.green, 30), "Bullish Border",     group="FVG Styling")
bearishBorderColor = input.color(color.new(color.red,   30), "Bearish Border",     group="FVG Styling")
fvgBorderWidth     = input.int(2, "Border Width", minval=1, maxval=5, group="FVG Styling")
showLabels         = input.bool(true, "Show Direction Labels", group="FVG Styling")

show_info      = input.bool(true, "Show Extended Info Labels", group="Extended Info Labels")
info_text_size = input.string("Large", "Info Text Size", group="Extended Info Labels", options=["Tiny","Small","Normal","Large","Huge"])

mitigationType    = input.string("50% Fill", "Mitigation Type", group="Mitigation Settings", options=["Touch","Full Fill","50% Fill"])
showMitigatedFVG  = input.bool(false, "Show Mitigated FVG", group="Mitigation Settings")
mitigatedFVGColor = input.color(color.new(color.gray, 90), "Mitigated FVG Color", group="Mitigation Settings")

minGapSize    = input.float(0.0, "Minimum Gap Size (0 = No Filter)", group="Filter Settings", minval=0.0, step=0.1)
useATRFilter  = input.bool(true, "Use ATR Filter", group="Filter Settings")
atrMultiplier = input.float(0.5, "Minimum Gap Size (ATR Multiplier)", group="Filter Settings", minval=0.1, step=0.1)
atrLength     = input.int(14, "ATR Length", group="Filter Settings", minval=1)

get_text_size() =>
    switch info_text_size
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.large

calc_pips(price_diff) =>
    is_gold   = str.contains(syminfo.ticker, "XAU") or str.contains(syminfo.ticker, "GOLD")
    pip_value = is_gold ? 0.01 : syminfo.mintick * 10
    math.round(price_diff / pip_value)

get_session(bar_time) =>
    t = hour(bar_time, "GMT") * 60 + minute(bar_time, "GMT")
    string s = "Other"
    if t >= 480 and t < 1020
        s := "London"
    else if t >= 780 and t < 1320
        s := "NY"
    else if t >= 0 and t < 540
        s := "Asian"
    s

session_int(s) =>
    s == "London" ? 1 : s == "NY" ? 2 : s == "Asian" ? 3 : 0

session_str(i) =>
    i == 1 ? "London" : i == 2 ? "NY" : i == 3 ? "Asian" : "Other"

calculate_fvg_strength(gap_size, atr_value) =>
    if not enable_strength_rating
        5.0
    else
        gap_score = 0.0
        if atr_value > 0
            gap_ratio = gap_size / atr_value
            if gap_ratio >= 1.5
                gap_score := 8.0
            else if gap_ratio >= 1.0
                gap_score := 6.0
            else if gap_ratio >= 0.75
                gap_score := 4.5
            else if gap_ratio >= 0.5
                gap_score := 3.0
            else
                gap_score := 1.5
        else
            gap_score := 3.0
        math.min(math.max(gap_score, 0.0), 10.0)

normalize_zone(original_top, original_bottom, atr_val, price_val) =>
    if use_normalized_zones
        target_height = zone_height_method == "ATR Based" ? atr_val * zone_height_atr_mult : price_val * (zone_height_percent / 100.0)
        original_mid  = (original_top + original_bottom) / 2.0
        [original_mid + target_height / 2.0, original_mid - target_height / 2.0]
    else
        [original_top, original_bottom]

detect_tf_bull() =>
    var float a_top  = na
    var float a_bot  = na
    var float a_str  = 0.0
    var int   a_ses  = 0
    var int   a_time = na
    atrv = ta.atr(atrLength)[1]
    if low[1] > high[3]
        gtop = low[1]
        gbot = high[3]
        gap  = gtop - gbot
        minGap = useATRFilter ? atrv * atrMultiplier : minGapSize
        if gap >= minGap
            a_top  := gtop
            a_bot  := gbot
            a_str  := calculate_fvg_strength(gap, atrv)
            a_ses  := session_int(get_session(time[1]))
            a_time := time[1]
    if not na(a_bot) and close[1] < a_bot
        a_top  := na
        a_bot  := na
        a_str  := 0.0
        a_ses  := 0
        a_time := na
    [a_top, a_bot, a_str, a_ses, a_time]

detect_tf_bear() =>
    var float a_top  = na
    var float a_bot  = na
    var float a_str  = 0.0
    var int   a_ses  = 0
    var int   a_time = na
    atrv = ta.atr(atrLength)[1]
    if high[1] < low[3]
        gtop = low[3]
        gbot = high[1]
        gap  = gtop - gbot
        minGap = useATRFilter ? atrv * atrMultiplier : minGapSize
        if gap >= minGap
            a_top  := gtop
            a_bot  := gbot
            a_str  := calculate_fvg_strength(gap, atrv)
            a_ses  := session_int(get_session(time[1]))
            a_time := time[1]
    if not na(a_top) and close[1] > a_top
        a_top  := na
        a_bot  := na
        a_str  := 0.0
        a_ses  := 0
        a_time := na
    [a_top, a_bot, a_str, a_ses, a_time]

[bt1, bb1, bs1, be1, bx1] = request.security(syminfo.tickerid, tf1, detect_tf_bull(), lookahead=barmerge.lookahead_off)
[bt2, bb2, bs2, be2, bx2] = request.security(syminfo.tickerid, tf2, detect_tf_bull(), lookahead=barmerge.lookahead_off)
[bt3, bb3, bs3, be3, bx3] = request.security(syminfo.tickerid, tf3, detect_tf_bull(), lookahead=barmerge.lookahead_off)

[rt1, rb1, rs1, re1, rx1] = request.security(syminfo.tickerid, tf1, detect_tf_bear(), lookahead=barmerge.lookahead_off)
[rt2, rb2, rs2, re2, rx2] = request.security(syminfo.tickerid, tf2, detect_tf_bear(), lookahead=barmerge.lookahead_off)
[rt3, rb3, rs3, re3, rx3] = request.security(syminfo.tickerid, tf3, detect_tf_bear(), lookahead=barmerge.lookahead_off)

[ref_atr, ref_close, ref_high, ref_low] = request.security(syminfo.tickerid, tf1, [ta.atr(atrLength)[1], close[1], high[1], low[1]], lookahead=barmerge.lookahead_off)

tf1_secs = timeframe.in_seconds(tf1)

zones_confluent(top_a, bot_a, top_b, bot_b, atr_val) =>
    valid = not na(top_a) and not na(bot_a) and not na(top_b) and not na(bot_b)
    result = false
    if valid
        mid_a     = (top_a + bot_a) / 2.0
        mid_b     = (top_b + bot_b) / 2.0
        tolerance = atr_val * proximity_atr_mult
        result := math.abs(mid_a - mid_b) <= tolerance
    result

type FVGZone
    box    b
    label  l
    label  info_label
    float  top
    float  bot
    bool   bullish
    string session
    int    form_time
    float  strength
    int    confluence_count

var array<FVGZone> bull_zones = array.new<FVGZone>()
var array<FVGZone> bear_zones = array.new<FVGZone>()
var int last_bull_time = na
var int last_bear_time = na

is_fvg_mitigated(z) =>
    mid = (z.top + z.bot) / 2.0
    z.bullish ? (mitigationType == "Touch" ? ref_low <= z.top : mitigationType == "Full Fill" ? ref_low <= z.bot : ref_low <= mid) : (mitigationType == "Touch" ? ref_high >= z.bot : mitigationType == "Full Fill" ? ref_high >= z.top : ref_high >= mid)

clean_zones(zones) =>
    if array.size(zones) > 0
        for i = array.size(zones) - 1 to 0
            if i < array.size(zones)
                z = array.get(zones, i)
                if is_fvg_mitigated(z)
                    if showMitigatedFVG
                        box.set_bgcolor(z.b, mitigatedFVGColor)
                        box.set_extend(z.b, extend.none)
                    else
                        box.delete(z.b)
                        array.remove(zones, i)
                        if not na(z.l)
                            label.delete(z.l)
                        if not na(z.info_label)
                            label.delete(z.info_label)

limit_size(zones, max_size) =>
    while array.size(zones) > max_size
        old = array.shift(zones)
        box.delete(old.b)
        if not na(old.l)
            label.delete(old.l)
        if not na(old.info_label)
            label.delete(old.info_label)

update_boxes(zones) =>
    if array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            z = array.get(zones, i)
            if show_info and not na(z.info_label)
                age_bars      = na(z.form_time) ? 0 : int((time - z.form_time) / (tf1_secs * 1000))
                pips          = calc_pips(z.top - z.bot)
                distance_pips = calc_pips(math.abs(close - (z.top + z.bot) / 2.0))
                zone_type     = z.bullish ? "Merged Bullish FVG" : "Merged Bearish FVG"
                info_text     = zone_type + " ||| " + str.tostring(z.confluence_count) + " timeframes ||| Strength: " + str.tostring(math.round(z.strength * 10) / 10) + "/10 ||| " + z.session + " ||| Age: " + str.tostring(age_bars) + " bars ||| " + str.tostring(pips) + " pips ||| " + str.tostring(distance_pips) + " pips away"
                label.set_text(z.info_label, info_text)
                label.set_xy(z.info_label, time, (z.top + z.bot) / 2.0)
                label.set_style(z.info_label, label.style_label_left)
                label.set_textalign(z.info_label, text.align_left)

bool bull_new_zone = false
bool bear_new_zone = false

if barstate.isconfirmed

    if showBullishFVG
        float m_top  = na
        float m_bot  = na
        float m_str  = 0.0
        int   m_ses  = 0
        int   m_cnt  = 0
        int   m_time = na

        if not na(bt1)
            m_top := bt1
            m_bot := bb1
            m_str := bs1
            m_ses := be1
            m_cnt := 1
            m_time := bx1

        if not na(bt2)
            if na(m_top)
                m_top := bt2
                m_bot := bb2
                m_str := bs2
                m_ses := be2
                m_cnt := 1
                m_time := bx2
            else if zones_confluent(m_top, m_bot, bt2, bb2, ref_atr)
                m_top := math.max(m_top, bt2)
                m_bot := math.min(m_bot, bb2)
                m_str := math.max(m_str, bs2)
                m_cnt += 1
                m_time := math.max(m_time, bx2)

        if not na(bt3)
            if na(m_top)
                m_top := bt3
                m_bot := bb3
                m_str := bs3
                m_ses := be3
                m_cnt := 1
                m_time := bx3
            else if zones_confluent(m_top, m_bot, bt3, bb3, ref_atr)
                m_top := math.max(m_top, bt3)
                m_bot := math.min(m_bot, bb3)
                m_str := math.max(m_str, bs3)
                m_cnt += 1
                m_time := math.max(m_time, bx3)

        merged_strength = math.min(m_str + math.max(m_cnt - 1, 0) * confluence_bonus, 10.0)

        if m_cnt >= min_confluence and not na(m_top) and merged_strength >= min_strength_filter and (na(last_bull_time) or m_time > last_bull_time)
            bool already_exists = false
            if array.size(bull_zones) > 0
                for k = 0 to array.size(bull_zones) - 1
                    existing = array.get(bull_zones, k)
                    if math.abs((existing.top + existing.bot) / 2.0 - (m_top + m_bot) / 2.0) < ref_atr * 0.5
                        already_exists := true

            if not already_exists
                fvg_session = session_str(m_ses)
                [norm_top, norm_bot] = normalize_zone(m_top, m_bot, ref_atr, ref_close)
                right_t = math.max(m_time, time)

                b = box.new(m_time, norm_top, right_t, norm_bot, xloc=xloc.bar_time, border_color=bullishBorderColor, bgcolor=bullishFVGColor, border_width=fvgBorderWidth, extend=extend.right)

                label l = na
                if showLabels
                    l := label.new(m_time, norm_bot, "Bull FVG", xloc=xloc.bar_time, color=color.new(color.green, 20), textcolor=color.white, style=label.style_label_up, size=size.small)

                label info_l = na
                if show_info
                    pips          = calc_pips(norm_top - norm_bot)
                    distance_pips = calc_pips(math.abs(close - (norm_top + norm_bot) / 2.0))
                    info_text     = "Merged Bullish FVG ||| " + str.tostring(m_cnt) + " timeframes ||| Strength: " + str.tostring(math.round(merged_strength * 10) / 10) + "/10 ||| " + fvg_session + " ||| Age: 0 bars ||| " + str.tostring(pips) + " pips ||| " + str.tostring(distance_pips) + " pips away"
                    info_l := label.new(time, (norm_top + norm_bot) / 2.0, info_text, xloc=xloc.bar_time, color=color.new(color.green, 100), textcolor=color.new(color.green, 0), style=label.style_label_left, size=get_text_size(), textalign=text.align_left)

                array.push(bull_zones, FVGZone.new(b=b, l=l, info_label=info_l, top=norm_top, bot=norm_bot, bullish=true, session=fvg_session, form_time=m_time, strength=merged_strength, confluence_count=m_cnt))
                last_bull_time := m_time
                bull_new_zone := true

    if showBearishFVG
        float m_top  = na
        float m_bot  = na
        float m_str  = 0.0
        int   m_ses  = 0
        int   m_cnt  = 0
        int   m_time = na

        if not na(rt1)
            m_top := rt1
            m_bot := rb1
            m_str := rs1
            m_ses := re1
            m_cnt := 1
            m_time := rx1

        if not na(rt2)
            if na(m_top)
                m_top := rt2
                m_bot := rb2
                m_str := rs2
                m_ses := re2
                m_cnt := 1
                m_time := rx2
            else if zones_confluent(m_top, m_bot, rt2, rb2, ref_atr)
                m_top := math.max(m_top, rt2)
                m_bot := math.min(m_bot, rb2)
                m_str := math.max(m_str, rs2)
                m_cnt += 1
                m_time := math.max(m_time, rx2)

        if not na(rt3)
            if na(m_top)
                m_top := rt3
                m_bot := rb3
                m_str := rs3
                m_ses := re3
                m_cnt := 1
                m_time := rx3
            else if zones_confluent(m_top, m_bot, rt3, rb3, ref_atr)
                m_top := math.max(m_top, rt3)
                m_bot := math.min(m_bot, rb3)
                m_str := math.max(m_str, rs3)
                m_cnt += 1
                m_time := math.max(m_time, rx3)

        merged_strength = math.min(m_str + math.max(m_cnt - 1, 0) * confluence_bonus, 10.0)

        if m_cnt >= min_confluence and not na(m_top) and merged_strength >= min_strength_filter and (na(last_bear_time) or m_time > last_bear_time)
            bool already_exists = false
            if array.size(bear_zones) > 0
                for k = 0 to array.size(bear_zones) - 1
                    existing = array.get(bear_zones, k)
                    if math.abs((existing.top + existing.bot) / 2.0 - (m_top + m_bot) / 2.0) < ref_atr * 0.5
                        already_exists := true

            if not already_exists
                fvg_session = session_str(m_ses)
                [norm_top, norm_bot] = normalize_zone(m_top, m_bot, ref_atr, ref_close)
                right_t = math.max(m_time, time)

                b = box.new(m_time, norm_top, right_t, norm_bot, xloc=xloc.bar_time, border_color=bearishBorderColor, bgcolor=bearishFVGColor, border_width=fvgBorderWidth, extend=extend.right)

                label l = na
                if showLabels
                    l := label.new(m_time, norm_top, "Bear FVG", xloc=xloc.bar_time, color=color.new(color.red, 20), textcolor=color.white, style=label.style_label_down, size=size.small)

                label info_l = na
                if show_info
                    pips          = calc_pips(norm_top - norm_bot)
                    distance_pips = calc_pips(math.abs(close - (norm_top + norm_bot) / 2.0))
                    info_text     = "Merged Bearish FVG ||| " + str.tostring(m_cnt) + " timeframes ||| Strength: " + str.tostring(math.round(merged_strength * 10) / 10) + "/10 ||| " + fvg_session + " ||| Age: 0 bars ||| " + str.tostring(pips) + " pips ||| " + str.tostring(distance_pips) + " pips away"
                    info_l := label.new(time, (norm_top + norm_bot) / 2.0, info_text, xloc=xloc.bar_time, color=color.new(color.red, 100), textcolor=color.new(color.red, 0), style=label.style_label_left, size=get_text_size(), textalign=text.align_left)

                array.push(bear_zones, FVGZone.new(b=b, l=l, info_label=info_l, top=norm_top, bot=norm_bot, bullish=false, session=fvg_session, form_time=m_time, strength=merged_strength, confluence_count=m_cnt))
                last_bear_time := m_time
                bear_new_zone := true

clean_zones(bull_zones)
clean_zones(bear_zones)
limit_size(bull_zones, max_zones)
limit_size(bear_zones, max_zones)
update_boxes(bull_zones)
update_boxes(bear_zones)

var label warn_lbl = na
min_in_secs = math.min(timeframe.in_seconds(tf1), math.min(timeframe.in_seconds(tf2), timeframe.in_seconds(tf3)))
if barstate.islast
    if timeframe.in_seconds() > min_in_secs
        if na(warn_lbl)
            warn_lbl := label.new(bar_index, high, "Chart TF is higher than an input TF — lower the chart to <= TF1 for exact zones", color=color.new(color.orange, 10), textcolor=color.black, style=label.style_label_down, size=size.normal)
        label.set_xy(warn_lbl, bar_index, high)
    else if not na(warn_lbl)
        label.delete(warn_lbl)
        warn_lbl := na

alertcondition(bull_new_zone, title="Confluence Bullish FVG", message="New multi-timeframe confluence Bullish FVG detected")
alertcondition(bear_new_zone, title="Confluence Bearish FVG", message="New multi-timeframe confluence Bearish FVG detected")
````
