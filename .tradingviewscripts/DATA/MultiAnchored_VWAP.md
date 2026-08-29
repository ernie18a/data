<!-- tradingview-pine-id: PUB;29561044d3be465c8826189e415dc870 -->
<!-- tradingviewscripts-format: 1 -->
# Multi-Anchored VWAP

Source: https://www.tradingview.com/script/AiubPvRX-Multi-Anchored-VWAP/

## Description

Multi-Anchored VWAPMulti-Anchored VWAP — High/Low Pair + 5 Slots

This indicator plots a daily High/Low VWAP pair anchored to a configurable time-of-day, plus up to 5 additional fully-configurable anchored VWAPs — each with optional standard deviation bands.

Primary High/Low VWAP pair

At a configurable time each day (default 06:00 New York time), two VWAPs are anchored simultaneously:

- One seeded from the anchor bar's high
- One seeded from the anchor bar's low

Both lines originate exactly at the anchor bar's high and low, then run forward using your chosen source (default hlc3) until they re-anchor the next day. This gives you a clean volume-weighted "envelope" from a key session time — useful for tracking how price behaves relative to overnight or pre-market reference levels.

5 extra anchored VWAP slots

Each slot can be independently enabled and set to one of two modes:

- Recurring — re-anchors daily at a chosen time-of-day. Examples: RTH open (09:30 ET), RTH close (16:00 ET), midnight reset, London open (08:00 London), Asia open (09:00 Tokyo).
- One-shot — anchors once at a specific date/time and runs forward indefinitely. Use for earnings reactions, FOMC announcements, swing highs/lows, or breakout pivots.

Each slot has its own source, color, line width, and optional std-dev bands with a configurable multiplier.

Timezone support

New York, Chicago, Los Angeles, London, Berlin, Tokyo, Hong Kong, Sydney, and UTC — each anchor can use its own timezone, so you can mix session anchors across markets on one chart.

How to use

1. Add the indicator to your chart.
2. Open Settings — inputs are grouped per anchor.
3. Set the primary anchor time window as a 1-minute session string matching your anchor time (e.g. 0600-0601 for 6:00 AM). The first bar entering the window fires the anchor.
4. Enable extra slots as needed and pick Recurring or One-shot mode.

Notes

- VWAP requires volume data — on symbols without volume (some indices/FX feeds), the lines will be unreliable.
- Anchored VWAPs do not repaint historical values once an anchor has fired; the current bar updates tick-by-tick until close, as expected.
- Std-dev bands use Pine's built-in ta.vwap() band output (volume-weighted standard deviation of source values).
- If a one-shot timestamp is earlier than available history, the anchor fires on the earliest available bar.

---

## Source Code

````pine
//@version=6
// =============================================================================
// Multi-Anchored VWAP (High/Low Pair + 5 Configurable Anchors)
//
// Primary anchor: at a configurable time-of-day (default 06:00 ET) two VWAPs
// are anchored — one from the anchor bar's HIGH, one from its LOW. Both reset
// each day at the same time.
//
// Plus 5 extra slots. Each can be:
//   - Recurring: re-anchors daily at a chosen time-of-day, or
//   - One-shot:  anchors once at a chosen date/time, runs forward indefinitely.
//
// Every VWAP supports optional standard deviation bands.
// =============================================================================
indicator("Multi-Anchored VWAP", shorttitle = "MA-VWAP", overlay = true, max_lines_count = 500, max_labels_count = 500)

// -----------------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------------

// Detect the first bar that enters a session window in the given timezone.
// Pine's time(timeframe, session, tz) returns the bar's start time when the
// bar falls inside the session, otherwise na. The first bar where it switches
// from na -> non-na is the anchor.
f_session_start(session_str, tz) =>
    in_now  = not na(time(timeframe.period, session_str, tz))
    in_prev = not na(time(timeframe.period, session_str, tz)[1])
    in_now and not in_prev

// Detect the bar where a specific UTC timestamp falls (one-shot).
f_one_shot(anchor_time) =>
    time >= anchor_time and (na(time[1]) or time[1] < anchor_time)

// -----------------------------------------------------------------------------
// Inputs — Primary (High/Low Pair)
// -----------------------------------------------------------------------------
g_primary = "Primary Anchor (High/Low Pair)"
p_show         = input.bool(true,  "Show primary VWAPs",                 group = g_primary)
p_session      = input.session("0600-0601", "Anchor time window",        group = g_primary, tooltip = "First bar entering this window resets both VWAPs. Default 06:00–06:01 = 6 AM bar.")
p_tz           = input.string("America/New_York", "Timezone",            group = g_primary, options = ["America/New_York", "America/Chicago", "America/Los_Angeles", "Europe/London", "Europe/Berlin", "Asia/Tokyo", "Asia/Hong_Kong", "Australia/Sydney", "UTC"])
p_source       = input.source(hlc3, "Source (after anchor bar)",         group = g_primary)
p_show_bands   = input.bool(true,  "Show std-dev bands",                 group = g_primary)
p_stdev_mult   = input.float(1.0,  "Std-dev multiplier", minval = 0.0, step = 0.5, group = g_primary)
p_high_color   = input.color(color.new(#ef5350, 0), "High-anchored color", group = g_primary)
p_low_color    = input.color(color.new(#26a69a, 0), "Low-anchored color",  group = g_primary)
p_line_width   = input.int(2, "Line width", minval = 1, maxval = 4,      group = g_primary)

is_primary_anchor = f_session_start(p_session, p_tz)

// On the anchor bar, seed the VWAP with high (resp. low); on every other bar
// use the configured source. The VWAP's first sample is therefore exactly the
// anchor bar's high / low price.
src_high = is_primary_anchor ? high : p_source
src_low  = is_primary_anchor ? low  : p_source

[vwap_ph, ph_up, ph_dn] = ta.vwap(src_high, is_primary_anchor, p_stdev_mult)
[vwap_pl, pl_up, pl_dn] = ta.vwap(src_low,  is_primary_anchor, p_stdev_mult)

plot(p_show ? vwap_ph : na, "Primary High VWAP", color = p_high_color, linewidth = p_line_width)
plot(p_show ? vwap_pl : na, "Primary Low VWAP",  color = p_low_color,  linewidth = p_line_width)
plot(p_show and p_show_bands ? ph_up : na, "Primary High +Band", color = color.new(p_high_color, 55))
plot(p_show and p_show_bands ? ph_dn : na, "Primary High -Band", color = color.new(p_high_color, 55))
plot(p_show and p_show_bands ? pl_up : na, "Primary Low +Band",  color = color.new(p_low_color, 55))
plot(p_show and p_show_bands ? pl_dn : na, "Primary Low -Band",  color = color.new(p_low_color, 55))

// -----------------------------------------------------------------------------
// Inputs — Extra Anchored VWAPs (5 slots)
// -----------------------------------------------------------------------------
// Each slot:
//   - Enabled toggle
//   - Mode: Recurring (daily time-of-day) or One-shot (specific date/time)
//   - Recurring inputs: session window + timezone
//   - One-shot input:   absolute timestamp
//   - Source, std-dev bands toggle, std-dev multiplier, color, width
// -----------------------------------------------------------------------------

MODE_RECUR  = "Recurring (time-of-day)"
MODE_ONESHOT = "One-shot (date/time)"

f_extra_anchor(mode, session_str, tz, anchor_time) =>
    mode == MODE_RECUR ? f_session_start(session_str, tz) : f_one_shot(anchor_time)

// --- Slot 1 ---
g1 = "Extra VWAP 1"
e1_on       = input.bool(false, "Enabled", group = g1)
e1_mode     = input.string(MODE_RECUR, "Mode", options = [MODE_RECUR, MODE_ONESHOT], group = g1)
e1_session  = input.session("0930-0931", "Recurring time window", group = g1)
e1_tz       = input.string("America/New_York", "Timezone", group = g1, options = ["America/New_York", "America/Chicago", "America/Los_Angeles", "Europe/London", "Europe/Berlin", "Asia/Tokyo", "Asia/Hong_Kong", "Australia/Sydney", "UTC"])
e1_time     = input.time(timestamp("2026-01-01 09:30 -0500"), "One-shot date/time", group = g1)
e1_source   = input.source(hlc3, "Source", group = g1)
e1_bands_on = input.bool(true, "Show std-dev bands", group = g1)
e1_mult     = input.float(1.0, "Std-dev multiplier", minval = 0.0, step = 0.5, group = g1)
e1_color    = input.color(color.new(#2962ff, 0), "Color", group = g1)
e1_width    = input.int(2, "Line width", minval = 1, maxval = 4, group = g1)

e1_anchor = f_extra_anchor(e1_mode, e1_session, e1_tz, e1_time)
[e1_v, e1_u, e1_d] = ta.vwap(e1_source, e1_anchor, e1_mult)
plot(e1_on ? e1_v : na, "Extra 1 VWAP",  color = e1_color, linewidth = e1_width)
plot(e1_on and e1_bands_on ? e1_u : na,  "Extra 1 +Band", color = color.new(e1_color, 55))
plot(e1_on and e1_bands_on ? e1_d : na,  "Extra 1 -Band", color = color.new(e1_color, 55))

// --- Slot 2 ---
g2 = "Extra VWAP 2"
e2_on       = input.bool(false, "Enabled", group = g2)
e2_mode     = input.string(MODE_RECUR, "Mode", options = [MODE_RECUR, MODE_ONESHOT], group = g2)
e2_session  = input.session("1600-1601", "Recurring time window", group = g2)
e2_tz       = input.string("America/New_York", "Timezone", group = g2, options = ["America/New_York", "America/Chicago", "America/Los_Angeles", "Europe/London", "Europe/Berlin", "Asia/Tokyo", "Asia/Hong_Kong", "Australia/Sydney", "UTC"])
e2_time     = input.time(timestamp("2026-01-01 09:30 -0500"), "One-shot date/time", group = g2)
e2_source   = input.source(hlc3, "Source", group = g2)
e2_bands_on = input.bool(true, "Show std-dev bands", group = g2)
e2_mult     = input.float(1.0, "Std-dev multiplier", minval = 0.0, step = 0.5, group = g2)
e2_color    = input.color(color.new(#ff9800, 0), "Color", group = g2)
e2_width    = input.int(2, "Line width", minval = 1, maxval = 4, group = g2)

e2_anchor = f_extra_anchor(e2_mode, e2_session, e2_tz, e2_time)
[e2_v, e2_u, e2_d] = ta.vwap(e2_source, e2_anchor, e2_mult)
plot(e2_on ? e2_v : na, "Extra 2 VWAP",  color = e2_color, linewidth = e2_width)
plot(e2_on and e2_bands_on ? e2_u : na,  "Extra 2 +Band", color = color.new(e2_color, 55))
plot(e2_on and e2_bands_on ? e2_d : na,  "Extra 2 -Band", color = color.new(e2_color, 55))

// --- Slot 3 ---
g3 = "Extra VWAP 3"
e3_on       = input.bool(false, "Enabled", group = g3)
e3_mode     = input.string(MODE_RECUR, "Mode", options = [MODE_RECUR, MODE_ONESHOT], group = g3)
e3_session  = input.session("0000-0001", "Recurring time window", group = g3)
e3_tz       = input.string("America/New_York", "Timezone", group = g3, options = ["America/New_York", "America/Chicago", "America/Los_Angeles", "Europe/London", "Europe/Berlin", "Asia/Tokyo", "Asia/Hong_Kong", "Australia/Sydney", "UTC"])
e3_time     = input.time(timestamp("2026-01-01 09:30 -0500"), "One-shot date/time", group = g3)
e3_source   = input.source(hlc3, "Source", group = g3)
e3_bands_on = input.bool(true, "Show std-dev bands", group = g3)
e3_mult     = input.float(1.0, "Std-dev multiplier", minval = 0.0, step = 0.5, group = g3)
e3_color    = input.color(color.new(#ab47bc, 0), "Color", group = g3)
e3_width    = input.int(2, "Line width", minval = 1, maxval = 4, group = g3)

e3_anchor = f_extra_anchor(e3_mode, e3_session, e3_tz, e3_time)
[e3_v, e3_u, e3_d] = ta.vwap(e3_source, e3_anchor, e3_mult)
plot(e3_on ? e3_v : na, "Extra 3 VWAP",  color = e3_color, linewidth = e3_width)
plot(e3_on and e3_bands_on ? e3_u : na,  "Extra 3 +Band", color = color.new(e3_color, 55))
plot(e3_on and e3_bands_on ? e3_d : na,  "Extra 3 -Band", color = color.new(e3_color, 55))

// --- Slot 4 ---
g4 = "Extra VWAP 4"
e4_on       = input.bool(false, "Enabled", group = g4)
e4_mode     = input.string(MODE_ONESHOT, "Mode", options = [MODE_RECUR, MODE_ONESHOT], group = g4)
e4_session  = input.session("0930-0931", "Recurring time window", group = g4)
e4_tz       = input.string("America/New_York", "Timezone", group = g4, options = ["America/New_York", "America/Chicago", "America/Los_Angeles", "Europe/London", "Europe/Berlin", "Asia/Tokyo", "Asia/Hong_Kong", "Australia/Sydney", "UTC"])
e4_time     = input.time(timestamp("2026-01-01 09:30 -0500"), "One-shot date/time", group = g4)
e4_source   = input.source(hlc3, "Source", group = g4)
e4_bands_on = input.bool(true, "Show std-dev bands", group = g4)
e4_mult     = input.float(1.0, "Std-dev multiplier", minval = 0.0, step = 0.5, group = g4)
e4_color    = input.color(color.new(#fdd835, 0), "Color", group = g4)
e4_width    = input.int(2, "Line width", minval = 1, maxval = 4, group = g4)

e4_anchor = f_extra_anchor(e4_mode, e4_session, e4_tz, e4_time)
[e4_v, e4_u, e4_d] = ta.vwap(e4_source, e4_anchor, e4_mult)
plot(e4_on ? e4_v : na, "Extra 4 VWAP",  color = e4_color, linewidth = e4_width)
plot(e4_on and e4_bands_on ? e4_u : na,  "Extra 4 +Band", color = color.new(e4_color, 55))
plot(e4_on and e4_bands_on ? e4_d : na,  "Extra 4 -Band", color = color.new(e4_color, 55))

// --- Slot 5 ---
g5 = "Extra VWAP 5"
e5_on       = input.bool(false, "Enabled", group = g5)
e5_mode     = input.string(MODE_ONESHOT, "Mode", options = [MODE_RECUR, MODE_ONESHOT], group = g5)
e5_session  = input.session("0930-0931", "Recurring time window", group = g5)
e5_tz       = input.string("America/New_York", "Timezone", group = g5, options = ["America/New_York", "America/Chicago", "America/Los_Angeles", "Europe/London", "Europe/Berlin", "Asia/Tokyo", "Asia/Hong_Kong", "Australia/Sydney", "UTC"])
e5_time     = input.time(timestamp("2026-01-01 09:30 -0500"), "One-shot date/time", group = g5)
e5_source   = input.source(hlc3, "Source", group = g5)
e5_bands_on = input.bool(true, "Show std-dev bands", group = g5)
e5_mult     = input.float(1.0, "Std-dev multiplier", minval = 0.0, step = 0.5, group = g5)
e5_color    = input.color(color.new(#78909c, 0), "Color", group = g5)
e5_width    = input.int(2, "Line width", minval = 1, maxval = 4, group = g5)

e5_anchor = f_extra_anchor(e5_mode, e5_session, e5_tz, e5_time)
[e5_v, e5_u, e5_d] = ta.vwap(e5_source, e5_anchor, e5_mult)
plot(e5_on ? e5_v : na, "Extra 5 VWAP",  color = e5_color, linewidth = e5_width)
plot(e5_on and e5_bands_on ? e5_u : na,  "Extra 5 +Band", color = color.new(e5_color, 55))
plot(e5_on and e5_bands_on ? e5_d : na,  "Extra 5 -Band", color = color.new(e5_color, 55))
````
