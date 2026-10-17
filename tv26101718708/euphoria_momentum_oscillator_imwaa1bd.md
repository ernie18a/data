# Euphoria Momentum Oscillator

- url: https://www.tradingview.com/script/imwAa1bD-Euphoria-Momentum-Oscillator/
- type: indicator
- pine_id: PUB;ab54e7f986f44903bfe29347f3953095
- version: 5.0

## Description

📊 Euphoria Momentum Oscillator

🧾 Brief Description

A momentum oscillator that combines WaveTrend-style smoothing, adaptive overbought/oversold zones, and signal-line pivot detection to visualize momentum expansion, exhaustion, and reversals.

📖 Full Description
🔍 Overview

The Euphoria Momentum Oscillator is a smooth momentum tracking tool designed to help you understand market emotion cycles inside price action.

Instead of only showing overbought/oversold levels, it builds a continuous momentum wave that highlights:

📈 Momentum expansion
📉 Momentum exhaustion
🔄 Potential reversal zones
⚖️ Trend pressure shifts

It is built for context, not prediction, helping traders read structure inside momentum behavior.

⚙️ Core Engine

At its core, the indicator:

Builds a smoothed momentum wave from price deviation
Applies dual-layer smoothing to reduce noise
Scales movement using an amplitude multiplier for adaptability

👉 Result: a clean oscillator that reacts smoothly to market cycles.

📡 Signal Logic

A hidden signal line is used to detect momentum turning points.

This helps identify:

🔴 Peak momentum exhaustion (possible reversal down)
🟢 Trough momentum exhaustion (possible reversal up)
⚡ Transition phases between expansion & contraction

These signals are only shown when structure confirms a shift — not raw noise.

🌡️ Market Zones

The oscillator uses dynamic sentiment zones:

🔴 Overbought zone (Euphoria region)
→ Momentum may be extended or overheating
🟢 Oversold zone (Fear region)
→ Momentum may be oversold or exhausted

👉 These zones are contextual, not direct buy/sell signals.

🎯 Visual Language
🟢 Rising line = increasing bullish momentum
🔴 Falling line = increasing bearish momentum
🌈 Gradient zones = intensity of emotional pressure
🟡 Yellow dots = entry into extreme zone
🔴 / 🟢 dots = confirmed momentum pivot points
📊 Dashboard

A built-in dashboard shows:

📌 Sentiment state (Fear / Neutral / Euphoria)
📊 Current oscillator value
📉 Trend bias vs 50 EMA

This helps quickly understand market context at a glance.

🔔 Alerts

You can set alerts for:

🚨 Entering Euphoria zone (overbought pressure)
🚨 Entering Fear zone (oversold pressure)
📉 Momentum peak formation
📈 Momentum trough formation

All alerts are triggered only after structural confirmation.

⚙️ Inputs

Customize:

Channel length (momentum sensitivity)
Smoothing strength
Signal line speed
Amplitude scaling
Overbought / oversold thresholds
Visual vertical lines toggle
🧠 How to Use

Best used for:

📈 Momentum tracking
🔄 Reversal context spotting
📊 Trend continuation vs exhaustion analysis
🧩 Multi-timeframe confirmation setups

👉 Works best when combined with:

Price structure
Support/resistance
Trend indicators
⚠️ Limitations

This is a context tool, not a prediction system.

Momentum extremes can persist in strong trends
Signals should not be used alone
Confirmation from price action is recommended
💡 Originality

This indicator is not a standard oscillator.

It introduces:

🌊 WaveTrend-inspired momentum engine
🧠 Dual smoothing architecture
📡 Signal-line pivot detection
🌡️ Adaptive sentiment zones
📊 Structured dashboard context layer

👉 The goal is to transform raw momentum into readable market emotion cycles, not just overbought/oversold signals.

## Source Code

````pine
//@version=6
indicator("Euphoria Momentum Oscillator", shorttitle="Euphoria Indicator 10", overlay=false, max_lines_count=500, max_labels_count=500)

// =========================================================================
// 1. SETTINGS
// =========================================================================
grp_core = "Core Settings (Engine)"
n1 = input.int(2, "Channel Length", group=grp_core, tooltip="Standard momentum channel length.")
n2 = input.int(21, "Smoothness (Average Length)", group=grp_core, tooltip="Increased to 15 to act as a shock absorber. This prevents false mid-trend peaks from piercing the threshold.")
sig_len = input.int(2, "Signal Line Length", group=grp_core, tooltip="The invisible signal line used to perfectly time the Red/Green pivot dots without noise.")
src = input.source(hlc3, "Source Data", group=grp_core)

// Custom multiplier to scale the oscillator for different timeframes
amp_mult = input.float(2.2, "Amplitude Multiplier", step=0.05, group=grp_core, tooltip="Stretches the indicator up and down so it properly tags the 60/-60 zones.")

grp_zones = "Zone Thresholds"
ob_level = input.int(55, "Overbought Zone (Red)", group=grp_zones)
os_level = input.int(-55, "Oversold Zone (Green)", group=grp_zones)

grp_vis = "Visual Toggles"
show_vlines = input.bool(true, "Show Vertical Lines", group=grp_vis)

grp_structure = "Market Structure"
show_structure_banners = input.bool(true, "Show HH / HL / LH / LL Banners", group=grp_structure)
major_structure_offset = input.float(12.0, "HH / LL Banner Offset", minval=0.0, step=0.5, group=grp_structure)
minor_structure_offset = input.float(6.0, "HL / LH Banner Offset", minval=0.0, step=0.5, group=grp_structure)

// Electric Blue (#7DF9FF) used for fear-zone entry markers
electric_blue = color.rgb(125, 185, 220)

// Market-structure colors
hh_color = color.rgb(0, 170, 9)
hl_color = color.rgb(179, 232, 181)
lh_color = color.rgb(255, 183, 0)
ll_color = color.rgb(251, 17, 0)

// =========================================================================
// 2. MATH ENGINE (Smooth WaveTrend + Hidden Signal Line)
// =========================================================================
esa = ta.ema(src, n1)
d = ta.ema(math.abs(src - esa), n1)
ci = (src - esa) / (0.015 * d)

// The main smooth line, scaled by the Amplitude Multiplier
euphoria_score = ta.ema(ci, n2) * amp_mult

// The invisible signal line for trigger timing
signal_line = ta.sma(euphoria_score, sig_len)

// =========================================================================
// 3. VISUALS: OSCILLATOR LINE
// =========================================================================
is_rising = euphoria_score >= euphoria_score[1]
trend_change = not na(euphoria_score[2]) and is_rising != is_rising[1]
osc_color = is_rising ? color.lime : color.red
plot(euphoria_score, title="Euphoria Score", color=osc_color, linewidth=2)

// =========================================================================
// 4. ZONES & INVERTED GRADIENT FILLS
// =========================================================================
// Faint, solid zero line
hline(0, "Zero Line", color=color.new(color.gray, 85), linestyle=hline.style_solid)

// Horizontal Lines for Red Gradient
h_r1 = hline(ob_level, "OB Base", color=color.new(color.red, 50), linestyle=hline.style_solid)
h_r2 = hline(ob_level + 10, "OB 1", color=color.new(color.red, 100), linestyle=hline.style_solid)
h_r3 = hline(ob_level + 20, "OB 2", color=color.new(color.red, 100), linestyle=hline.style_solid)
h_r4 = hline(ob_level + 30, "OB 3", color=color.new(color.red, 100), linestyle=hline.style_solid)
h_r5 = hline(100, "OB Max", color=color.new(color.red, 100), linestyle=hline.style_solid)

fill(h_r1, h_r2, color=color.new(color.red, 60))
fill(h_r2, h_r3, color=color.new(color.red, 75))
fill(h_r3, h_r4, color=color.new(color.red, 85))
fill(h_r4, h_r5, color=color.new(color.red, 95))

// Horizontal Lines for Green Gradient
h_g1 = hline(os_level, "OS Base", color=color.new(color.lime, 70), linestyle=hline.style_solid)
h_g2 = hline(os_level - 10, "OS 1", color=color.new(color.lime, 100), linestyle=hline.style_solid)
h_g3 = hline(os_level - 20, "OS 2", color=color.new(color.lime, 100), linestyle=hline.style_solid)
h_g4 = hline(os_level - 30, "OS 3", color=color.new(color.lime, 100), linestyle=hline.style_solid)
h_g5 = hline(-100, "OS Max", color=color.new(color.lime, 100), linestyle=hline.style_solid)

fill(h_g1, h_g2, color=color.new(color.green, 60))
fill(h_g2, h_g3, color=color.new(color.green, 75))
fill(h_g3, h_g4, color=color.new(color.green, 85))
fill(h_g4, h_g5, color=color.new(color.green, 95))

// =========================================================================
// 5. ZONE ENTRIES, MAX PEAKS & TROUGHS (Signal Line Triggers)
// =========================================================================
// Entry markers fire on the first cross into each extreme zone
enter_ob = ta.crossover(euphoria_score, ob_level)
enter_os = ta.crossunder(euphoria_score, os_level)

is_peak = ta.crossunder(euphoria_score, signal_line) and euphoria_score[1] >= ob_level
is_trough = ta.crossover(euphoria_score, signal_line) and euphoria_score[1] <= os_level

if enter_ob and show_vlines
    line.new(bar_index, euphoria_score, bar_index, 0, color=color.new(color.yellow, 10), width=1, extend=extend.both)

if enter_os and show_vlines
    line.new(bar_index, euphoria_score, bar_index, 0, color=color.new(electric_blue, 10), width=1, extend=extend.both)

if is_peak and show_vlines
    line.new(bar_index - 1, euphoria_score[1], bar_index - 1, 0, color=color.new(color.red, 10), width=1, extend=extend.both)

if is_trough and show_vlines
    line.new(bar_index - 1, euphoria_score[1], bar_index - 1, 0, color=color.new(color.lime, 10), width=1, extend=extend.both)

// Plot entry and pivot dots
plot(enter_ob ? euphoria_score : na, title="Greed Entry Dot", style=plot.style_circles, color=color.yellow, linewidth=3)
plot(enter_os ? euphoria_score : na, title="Fear Entry Dot", style=plot.style_circles, color=electric_blue, linewidth=3)
plot(is_peak ? euphoria_score[1] : na, title="Peak Dot", style=plot.style_circles, color=color.red, linewidth=3, offset=-1)
plot(is_trough ? euphoria_score[1] : na, title="Trough Dot", style=plot.style_circles, color=color.lime, linewidth=3, offset=-1)

// Show the confirmed direction change on the preceding pivot bar; intentionally no vertical line.
// The alert still fires on the current confirmation bar to avoid repainting.
plot(trend_change ? euphoria_score[1] : na, title="Trend Change Dot", style=plot.style_circles, color=color.purple, linewidth=2, offset=-1)

// =========================================================================
// 6. SWITCH-BASED MARKET STRUCTURE
//
// A rising-to-falling switch confirms a high on the preceding bar.
// A falling-to-rising switch confirms a low on the preceding bar.
// Highs are compared only with prior highs; lows only with prior lows.
// =========================================================================
high_switch = trend_change and not is_rising
low_switch = trend_change and is_rising

switch_high_value = euphoria_score[1]
switch_low_value = euphoria_score[1]

previous_switch_high = ta.valuewhen(high_switch, switch_high_value, 1)
previous_switch_low = ta.valuewhen(low_switch, switch_low_value, 1)

hh_event = high_switch and not na(previous_switch_high) and switch_high_value > previous_switch_high
lh_event = high_switch and not na(previous_switch_high) and switch_high_value <= previous_switch_high
hl_event = low_switch and not na(previous_switch_low) and switch_low_value >= previous_switch_low
ll_event = low_switch and not na(previous_switch_low) and switch_low_value < previous_switch_low

// Anchor every banner to its own oscillator pivot. HH/LL use the larger offset
// so extreme-zone dots remain visible; LH/HL use the smaller offset.
hh_banner_y = switch_high_value + major_structure_offset
lh_banner_y = switch_high_value + minor_structure_offset
hl_banner_y = switch_low_value - minor_structure_offset
ll_banner_y = switch_low_value - major_structure_offset

// Extreme-zone relevance:
// - HH may be preserved in Greed or the middle zone, but not in Fear.
// - LL may be preserved in Fear or the middle zone, but not in Greed.
// An excluded extreme is still displayed live until the next structure pivot.
hh_can_be_preserved = switch_high_value > os_level
ll_can_be_preserved = switch_low_value < ob_level

// Seasons alternate from HH -> LL, then LL -> HH.
//
// Every newly confirmed pivot appears immediately. The active season keeps:
// - its highest HH boundary,
// - its lowest LL boundary,
// - its latest HL,
// - its latest LH.
//
// A non-dominant HH/LL remains visible as a live candidate until the next
// structure pivot. It is then deleted if it did not become the meaningful
// seasonal boundary. An HH in Fear or an LL in Greed follows the same live-only
// behavior even when it is the numerical extreme of the season.
var string structure_season = na  // "down" = HH to LL, "up" = LL to HH
var label season_hh_label = na
var label season_hl_label = na
var label season_lh_label = na
var label season_ll_label = na
var label transient_extreme_label = na
var float season_hh_value = na
var float season_ll_value = na

bool displayed_hh_event = false
bool displayed_hl_event = false
bool displayed_lh_event = false
bool displayed_ll_event = false

new_structure_event = hh_event or hl_event or lh_event or ll_event

// A losing HH/LL candidate is guaranteed one full structure interval of live
// visibility. Remove it only when the next pivot arrives.
if new_structure_event and not na(transient_extreme_label)
    label.delete(transient_extreme_label)
    transient_extreme_label := na

// The first HH or LL establishes the alternating season state.
if na(structure_season)
    if hh_event
        displayed_hh_event := true
        structure_season := "down"
        season_hh_value := hh_can_be_preserved ? switch_high_value : na
        if show_structure_banners
            new_hh_label = label.new(
                 bar_index - 1,
                 hh_banner_y,
                 "HH",
                 style=label.style_label_down,
                 color=hh_color,
                 textcolor=color.white,
                 size=size.tiny)
            if hh_can_be_preserved
                season_hh_label := new_hh_label
            else
                transient_extreme_label := new_hh_label

    else if ll_event
        displayed_ll_event := true
        structure_season := "up"
        season_ll_value := ll_can_be_preserved ? switch_low_value : na
        if show_structure_banners
            new_ll_label = label.new(
                 bar_index - 1,
                 ll_banner_y,
                 "LL",
                 style=label.style_label_up,
                 color=ll_color,
                 textcolor=color.white,
                 size=size.tiny)
            if ll_can_be_preserved
                season_ll_label := new_ll_label
            else
                transient_extreme_label := new_ll_label

// HH -> LL season.
else if structure_season == "down"
    if hh_event
        displayed_hh_event := true

        if hh_can_be_preserved and (na(season_hh_value) or switch_high_value > season_hh_value)
            if show_structure_banners and not na(season_hh_label)
                label.delete(season_hh_label)

            season_hh_value := switch_high_value

            if show_structure_banners
                season_hh_label := label.new(
                     bar_index - 1,
                     hh_banner_y,
                     "HH",
                     style=label.style_label_down,
                     color=hh_color,
                     textcolor=color.white,
                     size=size.tiny)
        else if show_structure_banners
            // A lower HH, or any HH inside Fear, is live-only.
            transient_extreme_label := label.new(
                 bar_index - 1,
                 hh_banner_y,
                 "HH",
                 style=label.style_label_down,
                 color=hh_color,
                 textcolor=color.white,
                 size=size.tiny)

    else if ll_event
        displayed_ll_event := true

        // The LL completes this season and becomes the live boundary of the
        // following LL -> HH season. A Greed-zone LL remains live-only.
        if show_structure_banners
            new_ll_label = label.new(
                 bar_index - 1,
                 ll_banner_y,
                 "LL",
                 style=label.style_label_up,
                 color=ll_color,
                 textcolor=color.white,
                 size=size.tiny)
            if ll_can_be_preserved
                season_ll_label := new_ll_label
            else
                transient_extreme_label := new_ll_label

        structure_season := "up"
        season_ll_value := ll_can_be_preserved ? switch_low_value : na
        season_hh_value := na
        season_hh_label := na
        season_hl_label := na
        season_lh_label := na

    else if hl_event
        displayed_hl_event := true

        if show_structure_banners and not na(season_hl_label)
            label.delete(season_hl_label)

        if show_structure_banners
            season_hl_label := label.new(
                 bar_index - 1,
                 hl_banner_y,
                 "HL",
                 style=label.style_label_up,
                 color=hl_color,
                 textcolor=color.black,
                 size=size.tiny)

    else if lh_event
        displayed_lh_event := true

        if show_structure_banners and not na(season_lh_label)
            label.delete(season_lh_label)

        if show_structure_banners
            season_lh_label := label.new(
                 bar_index - 1,
                 lh_banner_y,
                 "LH",
                 style=label.style_label_down,
                 color=lh_color,
                 textcolor=color.black,
                 size=size.tiny)

// LL -> HH season.
else if structure_season == "up"
    if ll_event
        displayed_ll_event := true

        if ll_can_be_preserved and (na(season_ll_value) or switch_low_value < season_ll_value)
            if show_structure_banners and not na(season_ll_label)
                label.delete(season_ll_label)

            season_ll_value := switch_low_value

            if show_structure_banners
                season_ll_label := label.new(
                     bar_index - 1,
                     ll_banner_y,
                     "LL",
                     style=label.style_label_up,
                     color=ll_color,
                     textcolor=color.white,
                     size=size.tiny)
        else if show_structure_banners
            // A higher LL, or any LL inside Greed, is live-only.
            transient_extreme_label := label.new(
                 bar_index - 1,
                 ll_banner_y,
                 "LL",
                 style=label.style_label_up,
                 color=ll_color,
                 textcolor=color.white,
                 size=size.tiny)

    else if hh_event
        displayed_hh_event := true

        // The HH completes this season and becomes the live boundary of the
        // following HH -> LL season. A Fear-zone HH remains live-only.
        if show_structure_banners
            new_hh_label = label.new(
                 bar_index - 1,
                 hh_banner_y,
                 "HH",
                 style=label.style_label_down,
                 color=hh_color,
                 textcolor=color.white,
                 size=size.tiny)
            if hh_can_be_preserved
                season_hh_label := new_hh_label
            else
                transient_extreme_label := new_hh_label

        structure_season := "down"
        season_hh_value := hh_can_be_preserved ? switch_high_value : na
        season_ll_value := na
        season_ll_label := na
        season_hl_label := na
        season_lh_label := na

    else if hl_event
        displayed_hl_event := true

        if show_structure_banners and not na(season_hl_label)
            label.delete(season_hl_label)

        if show_structure_banners
            season_hl_label := label.new(
                 bar_index - 1,
                 hl_banner_y,
                 "HL",
                 style=label.style_label_up,
                 color=hl_color,
                 textcolor=color.black,
                 size=size.tiny)

    else if lh_event
        displayed_lh_event := true

        if show_structure_banners and not na(season_lh_label)
            label.delete(season_lh_label)

        if show_structure_banners
            season_lh_label := label.new(
                 bar_index - 1,
                 lh_banner_y,
                 "LH",
                 style=label.style_label_down,
                 color=lh_color,
                 textcolor=color.black,
                 size=size.tiny)

// =========================================================================
// 7. MINI DASHBOARD
// =========================================================================
var table dashboard = table.new(position.top_right, 2, 3)

// The 50 EMA must be calculated continuously outside the barstate block
trend_ema = ta.ema(close, 50)

if barstate.islast
    sentiment_txt = euphoria_score >= ob_level ? "Very Greedy" : euphoria_score <= os_level ? "Very Fearful" : "Neutral"
    sentiment_col = euphoria_score >= ob_level ? color.red : euphoria_score <= os_level ? color.lime : color.gray
    trend_txt = close > trend_ema ? "Bullish" : "Bearish"
    trend_col = close > trend_ema ? color.lime : color.red
    val_col = euphoria_score > 0 ? color.lime : color.red

    table.cell(dashboard, 0, 0, "Sentiment:", text_color=color.white, text_halign=text.align_left, text_size=size.tiny)
    table.cell(dashboard, 1, 0, sentiment_txt, text_color=sentiment_col, text_halign=text.align_right, text_size=size.tiny)
    table.cell(dashboard, 0, 1, "Value:", text_color=color.white, text_halign=text.align_left, text_size=size.tiny)
    table.cell(dashboard, 1, 1, str.tostring(euphoria_score, "#.#"), text_color=val_col, text_halign=text.align_right, text_size=size.tiny)
    table.cell(dashboard, 0, 2, "Trend:", text_color=color.white, text_halign=text.align_left, text_size=size.tiny)
    table.cell(dashboard, 1, 2, trend_txt, text_color=trend_col, text_halign=text.align_right, text_size=size.tiny)

// =========================================================================
// 8. ALERTS
// =========================================================================
alertcondition(enter_ob, title="Entered VERY GREEDY Zone", message="EI crossed ABOVE the Euphoria threshold! Extreme Greed.")
alertcondition(enter_os, title="Entered VERY FEARFUL Zone", message="EI crossed BELOW the Fear threshold! Extreme Fear.")
alertcondition(is_peak, title="Peak Euphoria Reached (Sell Signal)", message="EI printed a Red Dot in the Euphoria zone. Upward momentum has broken.")
alertcondition(is_trough, title="Peak Fear Reached (Buy Signal)", message="EI printed a Green Dot in the Fear zone. Downward momentum has broken.")
alertcondition(trend_change, title="Changing Trend Alert", message="EI changed direction: the oscillator switched between rising and falling momentum.")

alertcondition(displayed_hh_event, title="Euphoria Season Higher High", message="Euphoria oscillator confirmed a live seasonal Higher High (HH) on {{ticker}} - {{interval}}.")
alertcondition(displayed_hl_event, title="Euphoria Season Higher Low", message="Euphoria oscillator confirmed a live seasonal Higher Low (HL) on {{ticker}} - {{interval}}.")
alertcondition(displayed_lh_event, title="Euphoria Season Lower High", message="Euphoria oscillator confirmed a live seasonal Lower High (LH) on {{ticker}} - {{interval}}.")
alertcondition(displayed_ll_event, title="Euphoria Season Lower Low", message="Euphoria oscillator confirmed a live seasonal Lower Low (LL) on {{ticker}} - {{interval}}.")

// May our God bless you in your investments.
// Proverbs 20:15: "Gold there is, and rubies in abundance,
// but lips that speak knowledge are a rare jewel."
````
