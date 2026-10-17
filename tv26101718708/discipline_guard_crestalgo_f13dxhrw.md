# Discipline Guard [CrestAlgo]

- url: https://www.tradingview.com/script/F13DXHrW-Discipline-Guard-CrestAlgo/
- type: indicator
- pine_id: PUB;1a64aa919f404b5aa5151022feec84c2
- version: 1.0

## Description

Discipline Guard [CrestAlgo]

🔍 What This Indicator Does

Every trader has sessions they should avoid. The post-lunch chop. The pre-market noise. The late-night revenge trade window. You know these windows exist because your journal proves it. The problem is remembering in the moment.
Discipline Guard is a behavioral guardrail that visually obscures the chart during user-defined time windows where you have identified that you tend to underperform. It serves as a pattern-interrupt: a deliberate visual barrier between you and a trade you should not be taking.
This is not a signal indicator. It does not tell you what to trade. It tells you when to stop.

🛑 How It Works — The Four Stages

The indicator uses a progressive warning system so you are never caught off guard mid-position:
Stage 1 — Early Warning (15 minutes before window)
A subtle amber tint appears on the chart background. This is your cue to begin winding down any open positions and stop scanning for new setups.
Stage 2 — Approaching (5 minutes before window)
The amber tint deepens and a warning label appears above the current bar showing the window name. Final warning before the blackout begins.
Stage 3 — Active Block (during the window)
The chart is covered with a configurable-opacity dark overlay and a centered message. The default reads "NO-TRADE ZONE — SCHEDULED PAUSE" but you can customize it to anything. This is the core of the indicator — making it psychologically harder to enter a trade during your known bad window.
Stage 4 — Recovery (5 minutes after window ends)
The overlay fades gradually back to a clean chart. This gives you a moment to recalibrate before re-engaging.
The progressive ramp can be toggled off if you prefer an instant blackout with no lead-in.

🌍 Per-Window Timezone Support

Each window has its own timezone selector with 14 options covering all major trading sessions:
America/New_York (default), America/Chicago, America/Los_Angeles, Europe/London, Europe/Amsterdam, Europe/Frankfurt, Asia/Tokyo, Asia/Hong_Kong, Asia/Singapore, Asia/Shanghai, Asia/Dubai, Australia/Sydney, UTC, and Chart (uses the symbol's exchange timezone).
This means you can configure one window for the NY lunch chop in Eastern time and another for the London close in GMT on the same chart. Each window resolves its own day-of-week and time-of-day independently.

⚙️ Configuration

Up to 5 independent no-trade windows can be configured. Each window has:

Enable/Disable toggle
Custom label (e.g., "Post-Lunch Slump", "Pre-FOMC", "Revenge Trade Zone")
Timezone selector (14 options)
Day-of-week checkboxes (Mon through Sun)
Start and end time in 24-hour HHMM-HHMM format

Visual settings (global):

Blackout color (default: near-black #0A0A0A)
Blackout opacity (40-95%, default 70%)
Warning tint color (default: amber)
Warning symbol (🛑 🚫 ⛔ ❌ 🔒 ⚠️)
Custom blackout message text
Message font size (Small / Medium / Large / Huge)
Progressive ramp toggle (on/off)

Historical display:

Show Historical Windows toggle (off by default — keeps your chart clean)
Realtime Range (how many bars back from current to shade, default 48)

🔔 Alerts
Two alert conditions are available:

Window approaching (fires when Stage 2 begins, 5 minutes before the blackout)
Window active (fires when Stage 3 begins)

To set an alert: right-click the indicator name on your chart → "Add alert on Discipline Guard."

🕐 Timeframe Compatibility

This indicator works on all timeframes and all markets (futures, stocks, forex, crypto, commodities, indices).
For the full four-stage progressive warning to render correctly, use on timeframes of 15 minutes or less. On higher timeframes (1H, 4H, Daily), the warning stages may collapse onto a single bar since each bar spans more time than the 15-minute lead-in window. The blackout itself works correctly on all timeframes.
Practical guidance:

1m to 5m: Full progressive ramp renders smoothly. Ideal for day traders and scalpers.
15m: Warning stages may render on only 1 bar each. Still functional.
1H and above: Use with progressive ramp disabled (instant blackout mode). The blackout still activates at the correct time.

📐 Default Configuration

Window 1 is enabled out of the box:

Label: "NY Post-Lunch Slump"
Timezone: America/New_York
Time: 13:00 – 13:30 ET
Days: Monday through Friday

This targets the well-known low-volume, choppy lunch period in US equity index futures trading. Adjust or disable it to match your own trading journal findings.
Windows 2-5 are pre-configured with common session labels (NY Pre-Open, London Lunch, Tokyo Fix, Custom) but disabled by default. Enable and adjust them to fit your own discipline rules.

⚠️ Limitations

This indicator enforces time-based discipline rules. It does not analyze price action, volume, or any market data beyond the current bar's timestamp.
The timing logic is derived from bar timestamps, not a separate wall clock. On inactive symbols where bars do not print continuously, the warning stages may not appear if no bar falls within the warning window.
Windows that cross midnight in their configured timezone (e.g., 23:30 to 00:30) require both days to be enabled in the day-of-week settings. Each day is evaluated independently.
The blackout is a visual overlay only. It does not prevent order execution or interact with your broker in any way. You can still place trades during a blackout if you choose to. The decision is always yours.

⚖️ Disclaimer

This indicator is a behavioral visualization tool for educational and informational purposes only. It does not constitute financial, investment, or trading advice. It does not generate trade signals, recommendations, or any form of market analysis.
No representation is made that using this tool will improve trading performance, reduce losses, or produce any specific result. Trading discipline is a personal responsibility. This tool provides a visual reminder; it does not guarantee behavioral change.
Trading futures, options, and other financial instruments involves substantial risk of loss and is not appropriate for all investors. Past performance is not indicative of future results.

## Source Code

````pine
// This source code is licensed under the MIT License.
// © CrestAlgo 2026

//@version=5
indicator("Discipline Guard [CrestAlgo]", "Discipline Guard [CrestAlgo]", overlay = true, max_labels_count = 50)

// =============================================================================
// DISCIPLINE GUARD
// A behavioral guardrail indicator that visually obscures the chart during
// user-defined time windows where the trader has identified low-performance
// sessions. The intent is to serve as a visual pattern-interrupt during known
// low-focus periods.
//
// How it works:
//   Each window has four stages:
//     1. Early warning  — subtle background tint, 15 min before window starts
//     2. Approaching    — deeper tint + icon, 5 min before window starts
//     3. Active block   — full configurable-opacity blackout with message
//     4. Recovery       — overlay fades out during the 5 min after window ends
//
//   Each window can be configured with its own timezone, so one chart can
//   enforce separate windows for London, New York, Tokyo, or any other session.
//
// Known limitations:
//   - For full progressive-ramp fidelity, use on timeframes ≤ 5 minutes.
//     On higher timeframes, stages may collapse onto the same bar.
//   - Pine Script cannot upload custom images; warning uses emoji + custom text.
//   - Timing is derived from bar time, not wall-clock time.
//   - Windows that cross midnight in their local timezone require the following
//     day to also be enabled; each day is evaluated independently.
// =============================================================================


// =============================================================================
// INPUTS
// =============================================================================

// --- Global visual settings ---
grp_vis = "Visual Settings"
blackout_color    = input.color(color.new(#0A0A0A, 0), "Blackout Color", group = grp_vis)
blackout_opacity  = input.int(70, "Blackout Opacity (%)", minval = 40, maxval = 95, group = grp_vis,
     tooltip = "Opacity of the full blackout during active windows.")
warning_color     = input.color(color.new(#F59E0B, 0), "Warning Tint Color", group = grp_vis,
     tooltip = "Color used for the early and approaching stages.")
progressive_ramp  = input.bool(true, "Progressive Ramp-Up", group = grp_vis,
     tooltip = "When enabled, shows subtle 15-min and 5-min pre-warnings. When disabled, goes straight to blackout.")
message_text      = input.string("NO-TRADE ZONE — SCHEDULED PAUSE", "Blackout Message", group = grp_vis,
     tooltip = "Shown in the center of the chart during active blackout windows.")
message_size      = input.string("Large", "Message Font Size",
     options = ["Small", "Medium", "Large", "Huge"], group = grp_vis)
warning_emoji     = input.string("🛑", "Warning Symbol",
     options = ["🛑", "🚫", "⛔", "❌", "🔒", "⚠️"], group = grp_vis)

// --- Alerts ---
grp_alert = "Alerts"
audio_alert = input.bool(false, "Alert 5 Minutes Before Window", group = grp_alert,
     tooltip = "Fires an alert() event five minutes before each active window begins. Create a TradingView alert on this indicator to receive sound/push notifications.")

// --- Historical display ---
grp_hist = "Historical Display"
show_history = input.bool(false, "Show Historical Windows", group = grp_hist,
     tooltip = "When disabled (default), only the current and upcoming windows are shaded — your chart history stays clean. Enable to see past windows too, useful for reviewing sessions.")
history_bars = input.int(48, "Realtime Range (bars)", minval = 5, maxval = 500, group = grp_hist,
     tooltip = "When 'Show Historical Windows' is off, only shade bars within this many bars of the current bar. Typical values: 48 bars (4h on 5m chart, a full session), 96 bars (8h on 5m chart).")

// Resolve a timezone label to the actual tz string passed into Pine time functions
f_resolve_tz(string tz_label) =>
    tz_label == "Chart" ? syminfo.timezone : tz_label


// =============================================================================
// WINDOW CONFIGURATION (up to 5 windows, each with its own timezone)
// =============================================================================

// Defaults are tuned for the NY-session futures trader, which is CrestAlgo's
// target audience. Window 1 is the post-lunch slump (NY time), enabled by default.

// WINDOW 1 ------------------------------------------------------------------
grp_w1 = "Window 1"
w1_on   = input.bool(true, "Enabled", group = grp_w1)
w1_lbl  = input.string("NY Post-Lunch Slump", "Label", group = grp_w1)
w1_tz   = input.string("America/New_York", "Timezone", options = 
     ["America/New_York", "Chart", "UTC", "Europe/London", "Europe/Amsterdam",
      "Europe/Frankfurt", "Asia/Tokyo", "Asia/Hong_Kong", "Asia/Singapore",
      "Asia/Shanghai", "Asia/Dubai", "Australia/Sydney", "America/Chicago",
      "America/Los_Angeles"], group = grp_w1)
w1_mo   = input.bool(true,  "Mon", inline = "w1d", group = grp_w1)
w1_tu   = input.bool(true,  "Tue", inline = "w1d", group = grp_w1)
w1_we   = input.bool(true,  "Wed", inline = "w1d", group = grp_w1)
w1_th   = input.bool(true,  "Thu", inline = "w1d", group = grp_w1)
w1_fr   = input.bool(true,  "Fri", inline = "w1d", group = grp_w1)
w1_sa   = input.bool(false, "Sat", inline = "w1d", group = grp_w1)
w1_su   = input.bool(false, "Sun", inline = "w1d", group = grp_w1)
w1_start = input.session("1300-1330", "Start-End (HHMM-HHMM)", group = grp_w1,
     tooltip = "24-hour format in the window's configured timezone.")

// WINDOW 2 ------------------------------------------------------------------
grp_w2 = "Window 2"
w2_on   = input.bool(false, "Enabled", group = grp_w2)
w2_lbl  = input.string("NY Pre-Open Chop", "Label", group = grp_w2)
w2_tz   = input.string("America/New_York", "Timezone", options = 
     ["America/New_York", "Chart", "UTC", "Europe/London", "Europe/Amsterdam",
      "Europe/Frankfurt", "Asia/Tokyo", "Asia/Hong_Kong", "Asia/Singapore",
      "Asia/Shanghai", "Asia/Dubai", "Australia/Sydney", "America/Chicago",
      "America/Los_Angeles"], group = grp_w2)
w2_mo   = input.bool(true,  "Mon", inline = "w2d", group = grp_w2)
w2_tu   = input.bool(true,  "Tue", inline = "w2d", group = grp_w2)
w2_we   = input.bool(true,  "Wed", inline = "w2d", group = grp_w2)
w2_th   = input.bool(true,  "Thu", inline = "w2d", group = grp_w2)
w2_fr   = input.bool(true,  "Fri", inline = "w2d", group = grp_w2)
w2_sa   = input.bool(false, "Sat", inline = "w2d", group = grp_w2)
w2_su   = input.bool(false, "Sun", inline = "w2d", group = grp_w2)
w2_start = input.session("0900-0930", "Start-End (HHMM-HHMM)", group = grp_w2)

// WINDOW 3 ------------------------------------------------------------------
grp_w3 = "Window 3"
w3_on   = input.bool(false, "Enabled", group = grp_w3)
w3_lbl  = input.string("London Lunch", "Label", group = grp_w3)
w3_tz   = input.string("Europe/London", "Timezone", options = 
     ["America/New_York", "Chart", "UTC", "Europe/London", "Europe/Amsterdam",
      "Europe/Frankfurt", "Asia/Tokyo", "Asia/Hong_Kong", "Asia/Singapore",
      "Asia/Shanghai", "Asia/Dubai", "Australia/Sydney", "America/Chicago",
      "America/Los_Angeles"], group = grp_w3)
w3_mo   = input.bool(true,  "Mon", inline = "w3d", group = grp_w3)
w3_tu   = input.bool(true,  "Tue", inline = "w3d", group = grp_w3)
w3_we   = input.bool(true,  "Wed", inline = "w3d", group = grp_w3)
w3_th   = input.bool(true,  "Thu", inline = "w3d", group = grp_w3)
w3_fr   = input.bool(true,  "Fri", inline = "w3d", group = grp_w3)
w3_sa   = input.bool(false, "Sat", inline = "w3d", group = grp_w3)
w3_su   = input.bool(false, "Sun", inline = "w3d", group = grp_w3)
w3_start = input.session("1200-1300", "Start-End (HHMM-HHMM)", group = grp_w3)

// WINDOW 4 ------------------------------------------------------------------
grp_w4 = "Window 4"
w4_on   = input.bool(false, "Enabled", group = grp_w4)
w4_lbl  = input.string("Tokyo Fix", "Label", group = grp_w4)
w4_tz   = input.string("Asia/Tokyo", "Timezone", options = 
     ["America/New_York", "Chart", "UTC", "Europe/London", "Europe/Amsterdam",
      "Europe/Frankfurt", "Asia/Tokyo", "Asia/Hong_Kong", "Asia/Singapore",
      "Asia/Shanghai", "Asia/Dubai", "Australia/Sydney", "America/Chicago",
      "America/Los_Angeles"], group = grp_w4)
w4_mo   = input.bool(true,  "Mon", inline = "w4d", group = grp_w4)
w4_tu   = input.bool(true,  "Tue", inline = "w4d", group = grp_w4)
w4_we   = input.bool(true,  "Wed", inline = "w4d", group = grp_w4)
w4_th   = input.bool(true,  "Thu", inline = "w4d", group = grp_w4)
w4_fr   = input.bool(true,  "Fri", inline = "w4d", group = grp_w4)
w4_sa   = input.bool(false, "Sat", inline = "w4d", group = grp_w4)
w4_su   = input.bool(false, "Sun", inline = "w4d", group = grp_w4)
w4_start = input.session("0000-0000", "Start-End (HHMM-HHMM)", group = grp_w4)

// WINDOW 5 ------------------------------------------------------------------
grp_w5 = "Window 5"
w5_on   = input.bool(false, "Enabled", group = grp_w5)
w5_lbl  = input.string("Custom Window", "Label", group = grp_w5)
w5_tz   = input.string("America/New_York", "Timezone", options = 
     ["America/New_York", "Chart", "UTC", "Europe/London", "Europe/Amsterdam",
      "Europe/Frankfurt", "Asia/Tokyo", "Asia/Hong_Kong", "Asia/Singapore",
      "Asia/Shanghai", "Asia/Dubai", "Australia/Sydney", "America/Chicago",
      "America/Los_Angeles"], group = grp_w5)
w5_mo   = input.bool(true,  "Mon", inline = "w5d", group = grp_w5)
w5_tu   = input.bool(true,  "Tue", inline = "w5d", group = grp_w5)
w5_we   = input.bool(true,  "Wed", inline = "w5d", group = grp_w5)
w5_th   = input.bool(true,  "Thu", inline = "w5d", group = grp_w5)
w5_fr   = input.bool(true,  "Fri", inline = "w5d", group = grp_w5)
w5_sa   = input.bool(false, "Sat", inline = "w5d", group = grp_w5)
w5_su   = input.bool(false, "Sun", inline = "w5d", group = grp_w5)
w5_start = input.session("0000-0000", "Start-End (HHMM-HHMM)", group = grp_w5)


// =============================================================================
// CALCULATIONS
// =============================================================================

// Pine's dayofweek() returns 1=Sun ... 7=Sat.
// We normalize so Monday=0 ... Sunday=6 for intuitive weekday arithmetic.
f_norm_dow(int dow) =>
    dow == 1 ? 6 : dow - 2


// -----------------------------------------------------------------------------
// Parse a session string like "HHMM-HHMM" into [start_min, end_min, zero_len]
// where start_min / end_min are minutes since midnight (0..1440).
// zero_len = true when the window has zero duration (treated as disabled).
// -----------------------------------------------------------------------------
f_parse_session(string session_str) =>
    valid = str.length(session_str) == 9 and str.contains(session_str, "-")
    start_h = valid ? math.floor(str.tonumber(str.substring(session_str, 0, 2))) : 0
    start_m = valid ? math.floor(str.tonumber(str.substring(session_str, 2, 4))) : 0
    end_h   = valid ? math.floor(str.tonumber(str.substring(session_str, 5, 7))) : 0
    end_m   = valid ? math.floor(str.tonumber(str.substring(session_str, 7, 9))) : 0
    start_min = start_h * 60 + start_m
    end_min   = end_h * 60 + end_m
    zero = start_min == end_min
    [start_min, end_min, zero]


// -----------------------------------------------------------------------------
// Evaluate a window in its own timezone. Returns [stage, progress]:
//   0 = inactive
//   1 = early warning  (T-15 to T-5 min)
//   2 = approaching    (T-5 to T-0 min)
//   3 = active block   (during the window)
//   4 = recovery       (T-end to T-end+5 min)
// progress is 0.0..1.0 within the current stage.
//
// Each window receives its own tz string so NY, London, Tokyo windows can
// coexist and each will resolve day-of-week and time-of-day in its own locale.
// -----------------------------------------------------------------------------
f_evaluate_window(bool enabled, string tz_label,
     bool mo, bool tu, bool we, bool th, bool fr, bool sa, bool su,
     string session_str) =>

    [start_min, end_min, zero_len] = f_parse_session(session_str)

    tz = f_resolve_tz(tz_label)

    // Time components in the window's own timezone
    local_dow  = dayofweek(time, tz)
    local_hour = hour(time, tz)
    local_min  = minute(time, tz)
    norm_dow   = f_norm_dow(local_dow)

    if not enabled or zero_len
        [0, 0.0]
    else
        // Is today (in the window's tz) one of the enabled days?
        day_active = (norm_dow == 0 and mo) or (norm_dow == 1 and tu) or (norm_dow == 2 and we) or (norm_dow == 3 and th) or (norm_dow == 4 and fr) or (norm_dow == 5 and sa) or (norm_dow == 6 and su)

        if not day_active
            [0, 0.0]
        else
            minute_of_day = local_hour * 60 + local_min
            overnight = end_min < start_min
            eff_end = overnight ? 1440 : end_min

            mins_to_start = start_min - minute_of_day
            mins_since_end = minute_of_day - eff_end

            int stage = 0
            float progress = 0.0

            if minute_of_day >= start_min and minute_of_day < eff_end
                stage := 3
                total = eff_end - start_min
                progress := total > 0 ? (minute_of_day - start_min) / total : 0.0
            else if progressive_ramp and mins_to_start > 0 and mins_to_start <= 5
                stage := 2
                progress := (5 - mins_to_start) / 5.0
            else if progressive_ramp and mins_to_start > 5 and mins_to_start <= 15
                stage := 1
                progress := (15 - mins_to_start) / 10.0
            else if mins_since_end >= 0 and mins_since_end < 5
                stage := 4
                progress := mins_since_end / 5.0
            else
                stage := 0
                progress := 0.0

            [stage, progress]


// Evaluate all five windows (each in its own timezone)
[s1, p1] = f_evaluate_window(w1_on, w1_tz, w1_mo, w1_tu, w1_we, w1_th, w1_fr, w1_sa, w1_su, w1_start)
[s2, p2] = f_evaluate_window(w2_on, w2_tz, w2_mo, w2_tu, w2_we, w2_th, w2_fr, w2_sa, w2_su, w2_start)
[s3, p3] = f_evaluate_window(w3_on, w3_tz, w3_mo, w3_tu, w3_we, w3_th, w3_fr, w3_sa, w3_su, w3_start)
[s4, p4] = f_evaluate_window(w4_on, w4_tz, w4_mo, w4_tu, w4_we, w4_th, w4_fr, w4_sa, w4_su, w4_start)
[s5, p5] = f_evaluate_window(w5_on, w5_tz, w5_mo, w5_tu, w5_we, w5_th, w5_fr, w5_sa, w5_su, w5_start)

// Most severe stage wins (stage 3 > stage 2 > stage 1 > stage 4 > stage 0).
int active_stage = math.max(math.max(math.max(s1, s2), math.max(s3, s4)), s5)

// Pick the matching window's progress and label
float active_progress = 0.0
active_progress := active_stage == s1 and s1 > 0 ? p1 : active_progress
active_progress := active_stage == s2 and s2 > 0 ? p2 : active_progress
active_progress := active_stage == s3 and s3 > 0 ? p3 : active_progress
active_progress := active_stage == s4 and s4 > 0 ? p4 : active_progress
active_progress := active_stage == s5 and s5 > 0 ? p5 : active_progress

active_label = active_stage == s1 and s1 > 0 ? w1_lbl : active_stage == s2 and s2 > 0 ? w2_lbl : active_stage == s3 and s3 > 0 ? w3_lbl : active_stage == s4 and s4 > 0 ? w4_lbl : active_stage == s5 and s5 > 0 ? w5_lbl : ""


// =============================================================================
// VISUAL OUTPUT
// =============================================================================

// Pine's color.new(c, transparency) takes transparency 0..100 where 0=opaque, 100=invisible.
// Our reasoning uses opacity 0..100 where 100=fully visible. Conversion: transparency = 100 - opacity.

// Determine if we should render the background on this bar. By default the
// indicator only paints recent bars so historical windows don't clutter the
// chart. Users can enable "Show Historical Windows" to shade everything.
in_render_range = show_history or (bar_index > last_bar_index - history_bars)

var color bg = na
bg := na

if in_render_range
    if active_stage == 1
        // Stage 1: 2% → 5% opacity amber tint
        opacity_pct = 2 + active_progress * 3
        transparency = 100 - math.round(opacity_pct)
        bg := color.new(warning_color, transparency)
    else if active_stage == 2
        // Stage 2: 5% → 15% opacity amber tint
        opacity_pct = 5 + active_progress * 10
        transparency = 100 - math.round(opacity_pct)
        bg := color.new(warning_color, transparency)
    else if active_stage == 3
        // Stage 3: full blackout at configured opacity
        transparency = 100 - blackout_opacity
        bg := color.new(blackout_color, transparency)
    else if active_stage == 4
        // Stage 4: fade from configured opacity → 0 over 5-min recovery
        opacity_pct = blackout_opacity * (1.0 - active_progress)
        transparency = 100 - math.round(opacity_pct)
        bg := color.new(blackout_color, transparency)

bgcolor(bg, title = "Discipline Guard Background")


// -----------------------------------------------------------------------------
// Labels: icon above bar for stage 2, centered message for stage 3.
// Drawn only on the latest bar to avoid history clutter.
// -----------------------------------------------------------------------------

msg_size_const = message_size == "Small" ? size.small : message_size == "Medium" ? size.normal : message_size == "Large" ? size.large : size.huge

var label live_label = na

if not na(live_label)
    label.delete(live_label)
    live_label := na

if barstate.islast
    if active_stage == 2
        live_label := label.new(
             x = bar_index, y = high,
             text = warning_emoji + "  " + active_label,
             style = label.style_label_down,
             color = color.new(warning_color, 30),
             textcolor = color.white,
             size = size.normal,
             yloc = yloc.abovebar)
    else if active_stage == 3
        mid_price = (high + low) / 2
        live_label := label.new(
             x = bar_index, y = mid_price,
             text = warning_emoji + "  " + message_text + "\n" + active_label,
             style = label.style_label_center,
             color = color.new(blackout_color, 20),
             textcolor = color.white,
             size = msg_size_const,
             yloc = yloc.price,
             textalign = text.align_center)


// =============================================================================
// ALERTS
// =============================================================================

prev_stage = nz(active_stage[1], 0)

if audio_alert and active_stage == 2 and prev_stage != 2
    alert("Discipline Guard: " + active_label + " window begins in 5 minutes.", alert.freq_once_per_bar)

if active_stage == 3 and prev_stage != 3
    alert("Discipline Guard: " + active_label + " window is now ACTIVE. Pause trading.", alert.freq_once_per_bar)
````
