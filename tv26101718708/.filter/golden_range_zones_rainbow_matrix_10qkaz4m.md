# Golden Range Zones | Rainbow Matrix

- url: https://www.tradingview.com/script/10QKAz4m-Golden-Range-Zones-Rainbow-Matrix/
- type: indicator
- pine_id: PUB;d83174c437bb46b99dc7808292dec831
- version: 1.0

## Description

GENERAL OVERVIEW
Golden Range Zones is a nested prior-range projection tool. At every reset boundary it freezes the just-closed period's high and low as the inner Band lines, then scans backward to find the nearest earlier extremes that price has NOT yet broken — the outer Oscillation lines. The gap between each Band and its Oscillation is filled with a golden Fibonacci zone, giving an immediate map of where price has prior structural precedent above and below the current range.

The goal is to answer one question at a glance: where are the levels that actually matter right now, and how much room is there before price reaches them? Instead of a single prior-day high/low pair, you get a nested structure — the recent range bracketed by the closest unbroken historic extremes — with the space between them measured in Fibonacci proportion. Every line is derived from real completed-period extremes, not approximated from the current bar.

The indicator works on crypto and futures (24h session reset) and on stocks (custom trading-hours window with timezone), computes the range from in-session data only, and never repaints its frozen levels.

WHAT IS THE THEORY BEHIND THIS INDICATOR?

Prior high/low levels are among the most watched references in trading — but most tools draw only the single most recent pair (yesterday's high and low) and stop there. That tells you the edges of the last range. It does not tell you what lies beyond those edges: the next level up that price failed to break, or the next level down that has held historically.

Price does not react in a vacuum at the edge of yesterday's range. When it breaks above the recent high, the relevant question becomes "what is the nearest overhead level that has actually rejected price before?" — because that unbroken prior extreme is where the next reaction is statistically more likely. Golden Range Zones formalizes this: it brackets the recent range with the nearest UNBROKEN prior extremes on each side, found by scanning completed periods backward until it locates the first one whose high exceeded (or low undercut) the current range.

The space between the recent edge (Band) and the nearest unbroken extreme (Oscillation) is then divided in Fibonacci proportion — the zone where price travels between "left the recent range" and "reached the next historic wall." Reading that space as a graded golden zone, rather than two bare lines, turns the gap into a structured probability map: the deeper price pushes into the zone, the closer it sits to the level that has rejected it before.

Where no prior breaching extreme exists — price at an all-time high or low, a young asset, a very high reset period — the tool does not go blank. It projects a conservative Oscillation from the Band by 25% of the period range and flags it distinctly, so the structure is always present even at historic extremes.

GOLDEN RANGE ZONES FEATURES

The indicator includes these main components:

◇ Nested Prior-Range Engine (Band + backward-scan Oscillation)
◇ Golden Fibonacci Zones (dual-sided, mirrored)
◇ Extreme-Event Fallback Projection
◇ Black Swan Extension (liquidation-sweep zone)
◇ Session / Custom Trading-Hours Anchoring
◇ Zone-Size % Read-out
◇ Multilingual interface (5 languages) and full visual customization

NESTED PRIOR-RANGE ENGINE

🔹 What It Does
Freezes four static horizontal lines at each reset. The Band lines are the just-closed period's high and low (the inner pair). The Oscillation lines are the nearest prior period extremes that lie beyond that range (the outer pair).

🔹 Method
At each reset, the just-closed period's high and low are pushed to a rolling history of completed-period extremes and frozen as the Band lines. The engine then scans that history backward from the most recent period: the first earlier period whose high exceeds the Band high becomes the Oscillation high; the first whose low undercuts the Band low becomes the Oscillation low. The two sides resolve independently and can sit at very different look-back distances — the overhead wall might be four periods back while the floor below is two hundred periods back. Because both sides are bracketed by real extremes that the recent range did not breach, the structure is always ordered: Oscillation high ≥ Band high ≥ Band low ≥ Oscillation low.

🔹 No-Repaint
Every value comes from closed periods. Once frozen at the reset, the lines do not repaint for the duration of the period.

GOLDEN FIBONACCI ZONES

🔹 What It Does
The gap between each Band (inner) and its Oscillation (outer) is filled with a rainbow Fibonacci zone — the area where price travels from the recent range edge toward the nearest unbroken historic level.

🔹 Method
On each side the axis runs from the Band (ratio 0) to the Oscillation (ratio 1.0). The zone is divided into bands whose widths follow a Fibonacci 1:1:2:3:5:8 distribution, so the sub-bands grow as they approach the outer extreme — the area nearest the historic wall is the widest, where reaction is most likely. The palette runs aqua at the inner edge through to red at the outer edge, mirrored on the upper and lower sides. The space between the two Band lines stays clean, keeping the current trading range visually uncluttered.

EXTREME-EVENT FALLBACK

🔹 What It Does
When the backward scan finds no prior period that breached the Band on a side — price at a historic extreme, a young instrument, or a very high reset period — the Oscillation on that side is projected rather than left blank.

🔹 Method
The orphan side's Oscillation is placed at 25% of the period range beyond the Band, and the line is rendered with a distinct purple accent so it reads clearly as a conservative projection, not a historic level. Only the side without a real prior breach uses the fallback; the other side keeps its true extreme. The tool therefore always presents a complete structure, even in uncharted price territory.

BLACK SWAN EXTENSION

🔹 What It Does
An optional zone projected beyond the Oscillation — the area where price often wicks past a level to sweep liquidity before reacting.

🔹 Why It Matters
Levels are rarely respected to the tick. Price frequently overshoots a key extreme, triggering stops and liquidating leveraged positions, then reverses. The Black Swan extension marks that overshoot band explicitly, so an aggressive wick beyond the Oscillation reads as a potential liquidation sweep rather than a clean breakout.

SESSION / CUSTOM TRADING-HOURS ANCHORING

🔹 What It Does
The reset that defines each period can follow the instrument's native session (ideal for 24h crypto and futures) or a custom trading-hours window in a chosen timezone (ideal for stocks).

🔹 Method
In Session mode the period resets on the symbol's session boundary at the chosen reset timeframe (default Daily). In Custom Hours mode you set an open–close window and a timezone; the running high and low then accumulate from in-session bars only, discarding after-hours movement, and the period rolls over at the window open. This makes the Band represent the true regular-session range for stocks, not a figure distorted by thin extended-hours activity.

ZONE-SIZE % READ-OUT

🔹 What It Does
Three dashed vertical markers, drawn a configurable number of candles past the block, each span one zone and report its size as a percentage of current price.

🔹 The Three Zones
◇ Sell zone (green): Oscillation high → Band high — the room above the recent range.
◇ Neutral zone (gray): Band high → Band low — the recent range itself.
◇ Buy zone (red): Band low → Oscillation low — the room below the recent range.
Reading each zone as a % of price lets you size targets and risk against the structural levels directly.

HOW TO USE

This indicator is not a signal generator. It is a structural map: it shows the recent range, the nearest unbroken extremes that bracket it, and the graded space between them.

🔹 Setup
Set the chart timeframe below the reset period (for example a 15m chart with a Daily reset). For 24h markets leave Reset Mode on Session. For stocks, switch to Custom Hours and set the regular-session window and timezone. If the chart timeframe is at or above the reset period, the projection hides and a guard note appears.

🔹 Reading the Structure
◇ The two Band lines are the just-closed period's range — the immediate edges.
◇ The two Oscillation lines are the nearest prior levels the range has not broken — the next structural walls.
◇ The golden zone between each Band and Oscillation is where price has prior reaction precedent; the Fibonacci-weighted bands widen toward the outer wall.

🔹 Tactical Reading
◇ Price holding inside the Bands — trading within the recent range; no structural test yet.
◇ Price entering a golden zone — travelling toward the nearest unbroken extreme; the deeper it pushes, the closer the historic level.
◇ Price wicking into the Black Swan extension — possible liquidity sweep beyond the level; watch for rejection.
◇ A purple-accented Oscillation — no real prior breach on that side; the level is a conservative projection, treat with lower confidence.

INPUTS EXPLAINED

🔹 System Language
Display language for the panel and labels. Options: English (default), Português, Español, Русский, 中文 (Chinese).

🔹 Reset Period / Reset Mode
The period boundary that defines each range. Session (auto) for 24h markets; Custom Hours (with trading window + timezone) for stocks.

🔹 Lines
Visibility and width for the Band and Oscillation strokes.

🔹 Rainbow Style
Golden-zone visibility and transparency.

🔹 Black Swan / Aqua
The outer liquidation-sweep extension and the inner breathing-room line.

🔹 Extreme Event
Enables the 25%-range fallback projection when no prior breach exists.

🔹 Zone % Lines
The three zone-size verticals and their candle offset from the block.

🔹 Info Panel
Visibility, position, and font size.

IMPORTANT NOTES

Golden Range Zones works on any chart timeframe below the reset period. It is built for instruments with reliable price data across many periods, since the backward scan may look back far to find an unbroken extreme — on very short history the fallback projection covers the gap. In Custom Hours mode the range reflects in-session bars only.

The frozen levels do not repaint within a period; they recompute at the next reset, like an anchored tool. The Fibonacci 1:1:2:3:5:8 zone distribution is part of the canonical Rainbow Matrix design grammar, shared across the portfolio for consistent readability.

Pine Script v6. Open-source under Mozilla Public License 2.0.

UNIQUENESS

Golden Range Zones is unique in how it brackets the recent range. Most prior-range tools draw a single high/low pair; this one finds the nearest UNBROKEN prior extremes on each side via a backward scan through completed-period history, producing a nested structure rather than two bare lines. The space between the recent edge and the nearest unbroken extreme is then divided in Fibonacci 1:1:2:3:5:8 proportion, so the graded zone widens toward the historic wall where reaction is most likely — turning the gap into a structured probability map rather than empty space between two lines. An extreme-event fallback keeps the structure intact at all-time highs and lows by projecting a conservative level instead of going blank, and a Black Swan extension models the liquidation-sweep overshoot beyond each extreme. Session or custom trading-hours anchoring lets the same engine serve 24h crypto and regular-session stocks correctly, computing the range from in-session bars only. The combination of backward-scan nested ranges, Fibonacci-weighted golden zones, conservative fallback projection, and session-aware anchoring produces a structural read of prior-range context that single-pair high/low tools cannot provide.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © rainbowmatrix
//
// ════════════════════════════════════════════════════════════════════════════════
// GOLDEN RANGE ZONES — NESTED PRIOR-RANGE FIB PROJECTION
//
// At every reset boundary, Golden Range Zones freezes four static horizontal
// lines and two mirrored golden Fibonacci zones. The Band lines are the just-
// closed period's high / low (the inner pair). The Oscillation lines are the
// nearest prior period-level extremes that lie BEYOND that range (the outer
// pair) — found by scanning completed periods backward. A rainbow Fibonacci
// zone fills the gap between Band (inner) and Oscillation (outer) on each side;
// the middle stays clean. Where no prior breaching extreme exists, an extreme-
// event fallback projects the Oscillation from the Band by 25% of the period
// range on that side.
//
// METHOD:
//   1. RESET CADENCE — like an anchored VWAP, recomputes at each period
//      boundary and holds static until the next reset. Two modes: Session
//      (auto) uses the instrument's session boundary (ideal for 24h crypto /
//      futures); Custom Hours uses a configurable trading window + timezone
//      (ideal for stocks), computing the range from in-session bars only.
//   2. BAND LINES — high and low of the just-closed period (inner pair).
//   3. OSCILLATION LINES — scan completed periods backward from the just-closed
//      one: Oscillation Hi = high of the first earlier period whose high
//      exceeds Band Hi; Oscillation Lo = low of the first whose low is below
//      Band Lo. The two sides resolve independently and can sit at very
//      different look-back distances.
//   4. FALLBACK — if no earlier period breached on a side, project the
//      Oscillation from the Band by 25% of the period range on that side only,
//      flagged with a purple accent so the level reads as projected, not
//      historic.
//   5. GOLDEN ZONES — between Band (ratio 0, inner) and Oscillation (ratio 1.0,
//      outer), rendered as a rainbow with Fibonacci-distributed band widths
//      (1:1:2:3:5:8): aqua, blue, teal, green, yellow, orange, red from the
//      inner edge outward. Mirrored top and bottom; the area between Band Hi
//      and Band Lo stays clean.
//   6. AQUA BREATHING LINE — a thin aqua line set one block-width OUTSIDE the
//      Band (between price and the zone), marking the breathing room before
//      price enters the rainbow.
//   7. BLACK SWAN — an optional purple line + zone BEYOND the Oscillation, the
//      typical liquidation-sweep area where price often wicks past a level
//      before reacting.
//   8. ZONE % LINES — three dashed verticals drawn a configurable number of
//      candles past the block, each spanning its zone (sell = Osc Hi→Band Hi,
//      neutral = Band Hi→Band Lo, buy = Band Lo→Osc Lo) with a label showing
//      the zone size as a percentage of current price.
//   9. NO-REPAINT — all source data is from closed periods; frozen levels do
//      not repaint within the period.
//
// ORIGINALITY:
//   Prior-day high/low is the most cloned script type on TradingView. Golden
//   Range Zones differs on several mechanics at once:
//   (1) NESTED-RANGE structure — the recent range bracketed by the nearest
//       UNBROKEN prior extremes via a backward scan, not a single high/low;
//   (2) golden Fibonacci zones BETWEEN the nested levels, dual-sided, mirrored;
//   (3) a Black Swan extension modeling the liquidation sweep beyond the level;
//   (4) an extreme-event fallback so the tool never goes blank at a historic
//       extreme;
//   (5) per-period reset with selectable session or custom trading-hours
//       anchoring, fully static, no repaint.
//
// HOW TO USE:
//   - Set the chart timeframe below the reset period. If the chart timeframe is
//     at or above it, the projection hides and the panel shows a guard note.
//   - For 24h markets, leave Reset Mode on Session (auto). For stocks, switch
//     to Custom Hours and set the trading window + timezone.
//   - The Band lines are the just-closed period's range (inner). The
//     Oscillation lines are the nearest prior unbroken extremes (outer). The
//     golden zone between them is where price has prior reaction precedent.
//   - A purple-accented Oscillation line means no real prior breach existed on
//     that side — the level is a conservative projection.
//   - The Black Swan band beyond the Oscillation marks the typical liquidation-
//     sweep zone.
//   - The three zone-% verticals report each zone's size relative to price.
//
// INPUTS EXPLAINED:
//   - System Language: panel/label language (EN/PT/ES/RU/ZH).
//   - Reset Period / Reset Mode: period boundary; Session (auto) or Custom
//     Hours (with trading window + timezone).
//   - Lines: visibility + width for Band and Oscillation strokes.
//   - Rainbow Style: golden-zone visibility + transparency.
//   - Black Swan / Aqua: outer extension + inner breathing line.
//   - Extreme Event: the 25%-range fallback projection.
//   - Zone % Lines: the three zone-size verticals + their candle offset.
//   - Info Panel: visibility, position, font size.
// ════════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Golden Range Zones | Rainbow Matrix", overlay=true,
     max_bars_back=2000, max_boxes_count=100, max_lines_count=100, max_labels_count=20)

// ========================================================================================================
// SYSTEM LANGUAGE
// ========================================================================================================
g_lang = "GLOBAL SETTINGS"
language = input.string("English", "System Language",
     options=["English", "Português", "Español", "Русский", "中文 (Chinese)"],
     group=g_lang,
     tooltip="Select the display language for all on-screen labels and the info panel.")
string _l = language == "Português" ? "PT" : language == "Español" ? "ES" : language == "Русский" ? "RU" : language == "中文 (Chinese)" ? "ZH" : "EN"

// ── Multilingual strings (per §3.11) ──
var string s_reset_tf  = _l=="PT"?"TF RESET"    :_l=="ES"?"TF RESET"     :_l=="RU"?"ТФ СБРОСА"   :_l=="ZH"?"重置周期" :"RESET TF"
var string s_elapsed   = _l=="PT"?"DECORRIDO"   :_l=="ES"?"TRANSCURRIDO" :_l=="RU"?"ПРОШЛО"      :_l=="ZH"?"已用"    :"ELAPSED"
var string s_band_hi   = _l=="PT"?"FAIXA MÁX"   :_l=="ES"?"BANDA MÁX"    :_l=="RU"?"ПОЛОСА В"    :_l=="ZH"?"区间高"   :"BAND HI"
var string s_band_lo   = _l=="PT"?"FAIXA MÍN"   :_l=="ES"?"BANDA MÍN"    :_l=="RU"?"ПОЛОСА Н"    :_l=="ZH"?"区间低"   :"BAND LO"
var string s_osc_hi    = _l=="PT"?"OSC. MÁX"    :_l=="ES"?"OSC. MÁX"     :_l=="RU"?"КОЛЕБ. В"    :_l=="ZH"?"振荡高"   :"OSC HI"
var string s_osc_lo    = _l=="PT"?"OSC. MÍN"    :_l=="ES"?"OSC. MÍN"     :_l=="RU"?"КОЛЕБ. Н"    :_l=="ZH"?"振荡低"   :"OSC LO"
var string s_guard_msg = _l=="PT"?"⚠️ TF do gráfico ≥ Reset — defina o gráfico abaixo do Reset" :_l=="ES"?"⚠️ TF del gráfico ≥ Reset — usa un gráfico por debajo del Reset" :_l=="RU"?"⚠️ ТФ графика ≥ Reset — установите график ниже Reset" :_l=="ZH"?"⚠️ 图表周期 ≥ 重置周期 — 请将图表周期设置在重置周期以下" :"⚠️ chart TF ≥ reset — set chart below reset"

// ========================================================================================================
// INPUTS
// ========================================================================================================
g_reset = "RESET PERIOD"
reset_mode = input.string("Session (auto)", "Reset Mode",
     options=["Session (auto)", "Custom Hours"],
     group=g_reset,
     tooltip="Session (auto) = boundary of the symbol's native session as defined by Reset Period below (ideal for crypto/futures 24h). Custom Hours = trading window with explicit open/close times in a chosen timezone (ideal for stocks). When Custom Hours is selected, the running high/low only accumulates DURING the window, and the period rolls over at the window open.")
session_window = input.session("1030-1715", "Trading Hours",
     group=g_reset,
     tooltip="Trading hours window for Custom Hours mode, format HHMM-HHMM (24h). Default 1030-1715 = B3 (Brazilian stock exchange) regular session. Ignored when Reset Mode = Session (auto).")
session_tz = input.string("America/Sao_Paulo", "Timezone",
     group=g_reset,
     tooltip="Timezone applied to the Trading Hours window so the schedule stays consistent regardless of the chart's or user's local timezone. Use IANA names (America/Sao_Paulo, America/New_York, Europe/London, etc.). Ignored when Reset Mode = Session (auto).")
reset_tf = input.timeframe("D", "Reset Period",
     group=g_reset,
     tooltip="The period boundary that triggers a reset in Session (auto) mode. Default D (Daily). Other useful settings: W (weekly), 240 (4H). In Custom Hours mode this input is ignored — the period is implicitly the trading-day window. Chart TF must be strictly lower than the effective period — otherwise the projection hides and a guard note is shown.")

g_fib = "FIBONACCI"
show_blackswan  = input.bool(true, "Show Black Swan Line",
     group=g_fib,
     tooltip="Render the purple reference line beyond the Oscillation level on each side — the typical liquidation-sweep zone where price often wicks past a level before reacting.")
show_inner_swan = input.bool(true, "Show Inner Swan Line",
     group=g_fib,
     tooltip="Render the aqua reference line in the breathing zone OUTSIDE the rainbow block, 5 % of the gap inward from the Band on each side (between price and the rainbow base). Marks the boundary where price is approaching the rainbow zone.")

g_lines = "LINES"
show_band_lines = input.bool(true, "Show Band Lines",
     group=g_lines,
     tooltip="Solid horizontal lines at the just-closed period's absolute high and low — the inner pair of the nested structure.")
show_osc_lines  = input.bool(true, "Show Oscillation Lines",
     group=g_lines,
     tooltip="Solid horizontal lines at the nearest prior period extremes that bracket the Band — the outer pair. When no real prior breach exists on a side, the line renders in purple to flag that it is a projection (extreme-event fallback), not a historic level.")
line_width      = input.int(1, "Line Width",
     minval=1, maxval=4, step=1,
     group=g_lines,
     tooltip="Stroke width for the structural lines (Band + Oscillation). Default 1 keeps the lines as a thin reference; raise to 2–4 for heavier emphasis.")

g_style = "RAINBOW STYLE"
show_zones           = input.bool(true, "Show Golden Zones",
     group=g_style,
     tooltip="Render the 6 borderless rainbow zones between Band and Oscillation on each side — blue → teal → green → yellow → orange → red, with Fibonacci 1:1:2:3:5:8 sub-band widths. Turn off to see only the reference lines.")
rainbow_transparency = input.int(88, "Rainbow Transparency",
     minval=0, maxval=95, step=1,
     group=g_style,
     tooltip="Base transparency of the rainbow zones. 0 = solid, 95 = nearly invisible. Default 88 keeps the rainbow as a faint backdrop without occluding price action.")

g_fallback = "EXTREME EVENT"
enable_fallback = input.bool(true, "Enable Fallback Projection",
     group=g_fallback,
     tooltip="When the backward scan finds no prior period that breached the Band on a side (historic extreme, young asset, very high reset TF), project the Oscillation from the Band by 25 % of the period range on that side only. The projected line + zone are flagged with the Black Swan purple accent so you know the level is conservative, not historic. Turn off to leave the orphan side blank.")

g_hud = "INFO PANEL"
show_panel  = input.bool(true, "Show Info Panel",
     group=g_hud,
     tooltip="Floating panel summarizing the live state: reset TF in use, % of period elapsed, and the four level prices.")
panel_pos   = input.string("Top Right", "Panel Position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"],
     group=g_hud,
     tooltip="Anchor corner for the info panel — renders fixed regardless of zoom or scroll.")
i_text_size = input.string("Small", "Font Size",
     options=["Tiny", "Small", "Normal", "Large"],
     group=g_hud,
     tooltip="Font size for the info panel.")
font_size = i_text_size == "Tiny" ? size.tiny : i_text_size == "Small" ? size.small : i_text_size == "Normal" ? size.normal : size.large

show_zone_pct = input.bool(true, "Show Zone % Labels",
     group=g_hud,
     tooltip="Render 3 dashed vertical lines past the end of the rainbow block, each spanning its zone (SELL = osc_hi → band_hi, NEUTRAL = band_hi → band_lo, BUY = band_lo → osc_lo). A label to the right of each vertical shows the zone size as a % of current price. Useful for sizing trades against the structural levels.")
vert_offset   = input.int(3, "Zone % Lines Offset (candles)",
     minval=1, maxval=50, step=1,
     group=g_hud,
     tooltip="Number of candles past the end of the rainbow block where the 3 zone % verticals are drawn. Default 3 keeps them close to the projection; raise to push them further to the right.")

// ========================================================================================================
// RESET PIPELINE — BOUNDARY DETECTION + CHART-TF GUARD + SESSION WINDOW
// ========================================================================================================
// Two reset modes — unified through `period_rollover` + `should_accumulate`:
//
//   Session (auto): timeframe.change(reset_tf) drives the period; running
//                   high/low accumulates every bar (24/7-friendly — crypto,
//                   futures). reset_sec = timeframe.in_seconds(reset_tf).
//
//   Custom Hours:   the period is a daily trading window (session_window in
//                   session_tz). in_session = true while price is inside the
//                   window. period_rollover fires on the out→in transition
//                   (session open). should_accumulate = in_session, so the
//                   running extremes IGNORE after-hours bars. The implicit
//                   period is one day; reset_sec is pinned to 86400 s so the
//                   guard + HUD elapsed remain meaningful regardless of
//                   reset_tf.
//
// Chart TF must be strictly lower than reset_sec (one chart bar covering the
// whole period would resolve nothing) — otherwise the projection hides and
// the info panel surfaces s_guard_msg.
//
// Previous-bar tracking for in_session uses `var bool` + a bootstrap flag —
// Pine v6's nz() and na() don't accept series bool. On chart bar 0 the
// history_bootstrapped flag is false so the transition test reads false even
// if in_session is true (chart loaded mid-window). We wait for a real
// out→in edge before counting it as a period start. The first_reset_seen
// warm-up (Phase 4) then discards the first partial session as before.
int chart_tf_sec = timeframe.in_seconds(timeframe.period)
int reset_sec    = reset_mode == "Custom Hours" ? 86400 : timeframe.in_seconds(reset_tf)
bool tf_guard    = chart_tf_sec >= reset_sec

bool in_session  = reset_mode == "Custom Hours" ? not na(time(timeframe.period, session_window, session_tz)) : true

var bool in_session_prev      = false
var bool history_bootstrapped = false
bool transition_in = in_session and history_bootstrapped and not in_session_prev
bool period_rollover   = reset_mode == "Custom Hours" ? transition_in : timeframe.change(reset_tf)
bool should_accumulate = reset_mode == "Custom Hours" ? in_session : true
// Update previous-bar tracking AFTER the transition test (for next bar).
in_session_prev      := in_session
history_bootstrapped := true

// ========================================================================================================
// HISTORY TRACKING + BAND FREEZE (§4.53 — per-period extremes)
// ========================================================================================================
// Two append-only arrays of completed-period extremes (hist_hi / hist_lo) feed
// Phase 5's backward scan. Each rollover pushes the just-closed period's high
// and low and freezes the Band lines from those same values. Capped at 500
// periods to bound memory; if the asset has hundreds of contiguous periods
// without a breach on a side, Phase 5's scan exhausts the cap and falls back
// to the §5 25%-range projection (which is exactly the orphan-side intent).
//
// The LAST entry of each history array is always the CURRENT Band period;
// Phase 5's backward scan starts from size-2 to find STRICTLY PRIOR periods.
//
// First-rollover warm-up: the pre-chart fragment is discarded (no push, no
// band freeze) so the Band is never built from incomplete data.
var array<float> hist_hi = array.new<float>()
var array<float> hist_lo = array.new<float>()
int HIST_CAP = 500

var float running_hi       = na
var float running_lo       = na
var float band_hi          = na    // frozen high of just-closed period (inner pair, upper)
var float band_lo          = na    // frozen low  of just-closed period (inner pair, lower)
var int   reset_start_time = na    // time (ms) of current period's first bar
var bool  first_reset_seen = false

if not tf_guard
    if period_rollover
        if first_reset_seen
            // (a) Push the just-closed period's extremes into the history
            //     arrays. The last entry will always be the current Band period.
            array.push(hist_hi, running_hi)
            array.push(hist_lo, running_lo)
            // (b) Cap the history (drop oldest when over the cap).
            if array.size(hist_hi) > HIST_CAP
                array.shift(hist_hi)
                array.shift(hist_lo)
            // (c) Freeze Band lines from the same running values.
            band_hi := running_hi
            band_lo := running_lo
        first_reset_seen := true
        // (d) Restart running tracking + record period start time for HUD.
        running_hi       := high
        running_lo       := low
        reset_start_time := time
    else if should_accumulate
        // Accumulate within the current period (na-safe init on chart bar 0).
        // In Custom Hours mode, after-hours bars are skipped (should_accumulate=false).
        running_hi := na(running_hi) ? high : math.max(running_hi, high)
        running_lo := na(running_lo) ? low  : math.min(running_lo, low)

// ========================================================================================================
// BACKWARD SCAN + EXTREME-EVENT FALLBACK (§4 + §5)
// ========================================================================================================
// At each rollover (after warm-up), scan hist_hi backward starting from
// size-2 (the period strictly before the Band) for the first entry whose
// high > Band Hi → Oscillation Hi. Mirror for Oscillation Lo (first entry
// < Band Lo). The two sides are INDEPENDENT and can resolve at very different
// look-back distances (e.g. Hi 4 periods back, Lo 200 periods back).
//
// If no breach is found on a side and enable_fallback is on, project the
// Oscillation from the Band by 25 % of the period range on that side only.
// The orphan_* flag tells Phase 7 to flag the side with the Black Swan purple
// accent so the user knows the level is conservative, not historic.
//
// If fallback is off AND no breach found → osc_* stays na → render skips
// that side's Oscillation line + golden zone.
var float osc_hi    = na
var float osc_lo    = na
var bool  orphan_hi = false
var bool  orphan_lo = false

if not tf_guard and period_rollover and first_reset_seen and array.size(hist_hi) >= 1
    int n = array.size(hist_hi)

    // (1) Upper scan — first prior period with high > band_hi.
    //     Pine v6 auto-steps backward when start > end (no explicit `by -1`
    //     allowed: the step must be positive). Guard n >= 2 prevents start=-1.
    float new_osc_hi = na
    if n >= 2
        for i = n - 2 to 0
            float h = array.get(hist_hi, i)
            if h > band_hi
                new_osc_hi := h
                break

    // (2) Lower scan — first prior period with low < band_lo.
    float new_osc_lo = na
    if n >= 2
        for i = n - 2 to 0
            float l = array.get(hist_lo, i)
            if l < band_lo
                new_osc_lo := l
                break

    // (3) Apply fallback per side (only when no real breach was found).
    float period_range = band_hi - band_lo
    float fb_unit      = 0.25 * period_range
    if na(new_osc_hi) and enable_fallback and period_range > 0
        new_osc_hi := band_hi + fb_unit
        orphan_hi := true
    else
        orphan_hi := false

    if na(new_osc_lo) and enable_fallback and period_range > 0
        new_osc_lo := band_lo - fb_unit
        orphan_lo := true
    else
        orphan_lo := false

    osc_hi := new_osc_hi
    osc_lo := new_osc_lo

// ========================================================================================================
// FIB ENGINE — PER-SIDE LEVEL PRICES (§6 + §7)
// ========================================================================================================
// Per side, the physical unit U spans Band (ratio 0) → Oscillation (ratio 1.0).
// All cuts are anchored at the Band line and applied directly on U — six
// borderless sub-bands with Fibonacci 1:1:2:3:5:8 width distribution at cuts
// 0.05 / 0.10 / 0.20 / 0.35 / 0.60 / 1.0 (cumulative percentages of U).
//
// Reference lines projected from this axis:
//   • Aqua line   at 5 % OUTSIDE the Band (in the clean middle, between price and
//                 the rainbow base — "breathing zone" marker, not part of the gap).
//   • Purple line at 20 % beyond Osc   (Black Swan, half of the red block's 40 % width).
//
// All values become na when band_*/osc_* are na (warm-up / insufficient
// history / orphan-side with fallback disabled).
float u_unit = osc_hi - band_hi   // upper physical unit (positive outward)
float d_unit = band_lo - osc_lo   // lower physical unit (positive downward)

// Upper axis (price grows upward; Band Hi → 6 fib cuts → Osc → Purple Black Swan).
float u_band   = band_hi
float u_05     = band_hi + 0.05 * u_unit
float u_10     = band_hi + 0.10 * u_unit
float u_20     = band_hi + 0.20 * u_unit
float u_35     = band_hi + 0.35 * u_unit
float u_60     = band_hi + 0.60 * u_unit
float u_osc    = osc_hi
float u_aqua   = band_hi - 0.05 * u_unit         // 5 % OUTSIDE Band (in the clean middle)
float u_purple = osc_hi + 0.20 * u_unit          // 20 % beyond Osc — Black Swan line

// Lower axis (price grows downward; Band Lo → 6 fib cuts → Osc → Purple Black Swan).
float d_band   = band_lo
float d_05     = band_lo - 0.05 * d_unit
float d_10     = band_lo - 0.10 * d_unit
float d_20     = band_lo - 0.20 * d_unit
float d_35     = band_lo - 0.35 * d_unit
float d_60     = band_lo - 0.60 * d_unit
float d_osc    = osc_lo
float d_aqua   = band_lo + 0.05 * d_unit         // 5 % OUTSIDE Band (in the clean middle)
float d_purple = osc_lo - 0.20 * d_unit

// ========================================================================================================
// RENDER — LINES + GOLDEN ZONES + BLACK SWAN EXTENSION  (§7 — delete+recreate per realtime frame)
// ========================================================================================================
// All visuals exist only at the realtime edge under barstate.islast. The frame
// spans the CURRENT reset period: x-left = reset_start_time, x-right = end of
// the period. At each rollover the frame jumps forward; within a period it
// stays static.
//
// Per side (mirrored top/bottom):
//   • Band line          — blue, width 2 (§3.4 c_dn_3)
//   • 6 rainbow zones    — borderless, Fibonacci 1:1:2:3:5:8 distribution:
//                            blue → teal → green → yellow → orange → red
//                            (band → 0.05 → 0.10 → 0.20 → 0.35 → 0.60 → osc)
//   • Aqua line          — thin dashed at 5 % OUTSIDE the Band (clean-middle side),
//                          marks the breathing zone between price and rainbow base.
//   • Oscillation line   — red, width=line_width (PURPLE c_up_4 if orphan / fallback)
//   • Purple line        — thin dashed at 20 % of U beyond Osc (Black Swan zone).
//
// Aqua and Purple render dashed at width 1 + fixed transparency 40 — discreet
// reference markers.
//
// Zone % verticals (gated by show_zone_pct, drawn at the end of the render
// block): 3 dashed vertical lines 3 candles past the END of the rainbow block
// (t_right + 3 candles, in bar_time), with a label to the RIGHT of each
// vertical (label.style_label_left, arrow tip on the line) showing the zone
// size as a % of current close — SELL=green (osc_hi→band_hi), NEUTRAL=gray
// (band_hi→band_lo), BUY=red (band_lo→osc_lo).
//
// Lines are drawn AFTER all boxes so they sit on top. The middle (between Band
// Hi and Band Lo) is INTENTIONALLY unfilled.
var line ln_band_hi          = na
var line ln_band_lo          = na
var line ln_osc_hi           = na
var line ln_osc_lo           = na
var line ln_aqua_hi          = na    // aqua reference line, breathing zone outside Band Hi
var line ln_aqua_lo          = na    // aqua reference line, breathing zone outside Band Lo
var line ln_purple_hi        = na    // Black Swan reference line beyond Osc Hi
var line ln_purple_lo        = na    // Black Swan reference line beyond Osc Lo
var line ln_vert_sell        = na    // green vertical osc_hi → band_hi (SELL zone size)
var line ln_vert_neutral     = na    // gray  vertical band_hi → band_lo (NEUTRAL middle)
var line ln_vert_buy         = na    // red   vertical band_lo → osc_lo (BUY zone size)
var label lb_pct_sell        = na
var label lb_pct_neutral     = na
var label lb_pct_buy         = na
var box  bx_u_sub1           = na
var box  bx_u_sub2           = na
var box  bx_u_sub3           = na
var box  bx_u_sub4           = na
var box  bx_u_sub5           = na
var box  bx_u_sub6           = na
var box  bx_d_sub1           = na
var box  bx_d_sub2           = na
var box  bx_d_sub3           = na
var box  bx_d_sub4           = na
var box  bx_d_sub5           = na
var box  bx_d_sub6           = na

// §3.4 canonical palette (NEVER change without explicit operator override).
color c_up_1   = color.yellow   // rainbow sub-band 4
color c_up_2   = color.orange   // rainbow sub-band 5
color c_up_3   = color.red      // rainbow sub-band 6, Oscillation line
color c_up_4   = color.purple   // Black Swan line, orphan-flag Osc accent
color c_dn_1   = color.green    // rainbow sub-band 3
color c_dn_2   = color.teal     // rainbow sub-band 2
color c_dn_3   = color.blue     // rainbow sub-band 1, Band lines
color c_dn_4   = color.aqua     // aqua reference line
color c_neutral = color.gray    // HUD chrome
color c_black   = color.black   // HUD background


if barstate.islast and not tf_guard and not na(band_hi) and not na(band_lo)
    // (1) wipe previous frame
    line.delete(ln_band_hi)
    line.delete(ln_band_lo)
    line.delete(ln_osc_hi)
    line.delete(ln_osc_lo)
    line.delete(ln_aqua_hi)
    line.delete(ln_aqua_lo)
    line.delete(ln_purple_hi)
    line.delete(ln_purple_lo)
    line.delete(ln_vert_sell)
    line.delete(ln_vert_neutral)
    line.delete(ln_vert_buy)
    label.delete(lb_pct_sell)
    label.delete(lb_pct_neutral)
    label.delete(lb_pct_buy)
    box.delete(bx_u_sub1)
    box.delete(bx_u_sub2)
    box.delete(bx_u_sub3)
    box.delete(bx_u_sub4)
    box.delete(bx_u_sub5)
    box.delete(bx_u_sub6)
    box.delete(bx_d_sub1)
    box.delete(bx_d_sub2)
    box.delete(bx_d_sub3)
    box.delete(bx_d_sub4)
    box.delete(bx_d_sub5)
    box.delete(bx_d_sub6)

    // (2) frame x-bounds (timestamps in ms)
    int t_left  = reset_start_time
    int t_right = reset_start_time + reset_sec * 1000

    // (3) transparency
    int t_zone = rainbow_transparency

    // (4) Band lines (always — independent of Oscillation state)
    if show_band_lines
        ln_band_hi := line.new(t_left, u_band, t_right, u_band, xloc=xloc.bar_time, color=c_dn_3, width=line_width, style=line.style_solid)
        ln_band_lo := line.new(t_left, d_band, t_right, d_band, xloc=xloc.bar_time, color=c_dn_3, width=line_width, style=line.style_solid)

    // (5) UPPER SIDE — zones + lines only when Osc resolved (real or fallback)
    if not na(osc_hi)
        if show_zones
            // 6 borderless sub-bands at Fibonacci 1:1:2:3:5:8 cumulative cuts (0.05/0.10/0.20/0.35/0.60/1.0)
            bx_u_sub1 := box.new(t_left, u_05,  t_right, u_band, xloc=xloc.bar_time, bgcolor=color.new(c_dn_3, t_zone), border_color=color.new(c_dn_3, t_zone), border_width=0)
            bx_u_sub2 := box.new(t_left, u_10,  t_right, u_05,   xloc=xloc.bar_time, bgcolor=color.new(c_dn_2, t_zone), border_color=color.new(c_dn_2, t_zone), border_width=0)
            bx_u_sub3 := box.new(t_left, u_20,  t_right, u_10,   xloc=xloc.bar_time, bgcolor=color.new(c_dn_1, t_zone), border_color=color.new(c_dn_1, t_zone), border_width=0)
            bx_u_sub4 := box.new(t_left, u_35,  t_right, u_20,   xloc=xloc.bar_time, bgcolor=color.new(c_up_1, t_zone), border_color=color.new(c_up_1, t_zone), border_width=0)
            bx_u_sub5 := box.new(t_left, u_60,  t_right, u_35,   xloc=xloc.bar_time, bgcolor=color.new(c_up_2, t_zone), border_color=color.new(c_up_2, t_zone), border_width=0)
            bx_u_sub6 := box.new(t_left, u_osc, t_right, u_60,   xloc=xloc.bar_time, bgcolor=color.new(c_up_3, t_zone), border_color=color.new(c_up_3, t_zone), border_width=0)
        // lines drawn AFTER boxes (on top)
        if show_osc_lines
            ln_osc_hi := line.new(t_left, u_osc, t_right, u_osc, xloc=xloc.bar_time, color=orphan_hi ? c_up_4 : c_up_3, width=line_width, style=line.style_solid)
        // aqua + purple reference lines — thin dashed, fixed transparency 40
        if show_inner_swan
            ln_aqua_hi   := line.new(t_left, u_aqua,   t_right, u_aqua,   xloc=xloc.bar_time, color=color.new(c_dn_4, 40), width=1, style=line.style_dashed)
        if show_blackswan
            ln_purple_hi := line.new(t_left, u_purple, t_right, u_purple, xloc=xloc.bar_time, color=color.new(c_up_4, 40), width=1, style=line.style_dashed)

    // (6) LOWER SIDE — mirror upper
    if not na(osc_lo)
        if show_zones
            // 6 borderless sub-bands mirrored downward
            bx_d_sub1 := box.new(t_left, d_band, t_right, d_05,  xloc=xloc.bar_time, bgcolor=color.new(c_dn_3, t_zone), border_color=color.new(c_dn_3, t_zone), border_width=0)
            bx_d_sub2 := box.new(t_left, d_05,   t_right, d_10,  xloc=xloc.bar_time, bgcolor=color.new(c_dn_2, t_zone), border_color=color.new(c_dn_2, t_zone), border_width=0)
            bx_d_sub3 := box.new(t_left, d_10,   t_right, d_20,  xloc=xloc.bar_time, bgcolor=color.new(c_dn_1, t_zone), border_color=color.new(c_dn_1, t_zone), border_width=0)
            bx_d_sub4 := box.new(t_left, d_20,   t_right, d_35,  xloc=xloc.bar_time, bgcolor=color.new(c_up_1, t_zone), border_color=color.new(c_up_1, t_zone), border_width=0)
            bx_d_sub5 := box.new(t_left, d_35,   t_right, d_60,  xloc=xloc.bar_time, bgcolor=color.new(c_up_2, t_zone), border_color=color.new(c_up_2, t_zone), border_width=0)
            bx_d_sub6 := box.new(t_left, d_60,   t_right, d_osc, xloc=xloc.bar_time, bgcolor=color.new(c_up_3, t_zone), border_color=color.new(c_up_3, t_zone), border_width=0)
        if show_osc_lines
            ln_osc_lo := line.new(t_left, d_osc, t_right, d_osc, xloc=xloc.bar_time, color=orphan_lo ? c_up_4 : c_up_3, width=line_width, style=line.style_solid)
        if show_inner_swan
            ln_aqua_lo   := line.new(t_left, d_aqua,   t_right, d_aqua,   xloc=xloc.bar_time, color=color.new(c_dn_4, 40), width=1, style=line.style_dashed)
        if show_blackswan
            ln_purple_lo := line.new(t_left, d_purple, t_right, d_purple, xloc=xloc.bar_time, color=color.new(c_up_4, 40), width=1, style=line.style_dashed)

    // (7) Zone % verticals + midpoint labels — 3 dashed verticals vert_offset
    //     candles past the END of the rainbow block (not the live bar), each
    //     spanning its zone. Label sits to the RIGHT of the vertical
    //     (label.style_label_left arrow tip on the line, text extends right).
    //     SELL=green (osc_hi→band_hi), NEUTRAL=gray (band_hi→band_lo), BUY=red
    //     (band_lo→osc_lo). Each renders independently when its level pair is
    //     non-na.
    if show_zone_pct and close > 0
        int t_vert = t_right + vert_offset * timeframe.in_seconds(timeframe.period) * 1000
        if not na(osc_hi) and not na(band_hi)
            ln_vert_sell := line.new(t_vert, osc_hi, t_vert, band_hi, xloc=xloc.bar_time, color=c_dn_1, width=1, style=line.style_dashed)
            float y_mid_sell = (osc_hi + band_hi) / 2.0
            float pct_sell   = (osc_hi - band_hi) / close * 100
            lb_pct_sell := label.new(x=t_vert, y=y_mid_sell, text=str.tostring(pct_sell, "#.##") + "%", xloc=xloc.bar_time, color=color.new(color.black, 100), textcolor=c_dn_1, style=label.style_label_left, size=size.small)
        if not na(band_hi) and not na(band_lo)
            ln_vert_neutral := line.new(t_vert, band_hi, t_vert, band_lo, xloc=xloc.bar_time, color=c_neutral, width=1, style=line.style_dashed)
            float y_mid_neutral = (band_hi + band_lo) / 2.0
            float pct_neutral   = (band_hi - band_lo) / close * 100
            lb_pct_neutral := label.new(x=t_vert, y=y_mid_neutral, text=str.tostring(pct_neutral, "#.##") + "%", xloc=xloc.bar_time, color=color.new(color.black, 100), textcolor=c_neutral, style=label.style_label_left, size=size.small)
        if not na(band_lo) and not na(osc_lo)
            ln_vert_buy := line.new(t_vert, band_lo, t_vert, osc_lo, xloc=xloc.bar_time, color=c_up_3, width=1, style=line.style_dashed)
            float y_mid_buy = (band_lo + osc_lo) / 2.0
            float pct_buy   = (band_lo - osc_lo) / close * 100
            lb_pct_buy := label.new(x=t_vert, y=y_mid_buy, text=str.tostring(pct_buy, "#.##") + "%", xloc=xloc.bar_time, color=color.new(color.black, 100), textcolor=c_up_3, style=label.style_label_left, size=size.small)

// ========================================================================================================
// HUD INFO PANEL  (§8 — info panel group)
// ========================================================================================================
// Floating table: reset TF, % of period elapsed, and the four level prices in
// top-down chart order (OSC HI > BAND HI > BAND LO > OSC LO). Orphan side
// Oscillation prices render in purple (c_up_4) to flag the fallback projection,
// matching the line color flag in render. Guard fallback collapses to a single
// warning row with s_guard_msg.
var table hud = na

if barstate.islast and show_panel
    if na(hud)
        hud := table.new(
             panel_pos == "Top Left"      ? position.top_left :
             panel_pos == "Bottom Right"  ? position.bottom_right :
             panel_pos == "Bottom Left"   ? position.bottom_left :
                                            position.top_right,
             columns=2, rows=7, border_width=1, frame_color=color.new(c_neutral, 50), frame_width=1)
    table.clear(hud, 0, 0, 1, 6)

    color c_row_bg = color.new(c_black, 70)
    color c_hdr_bg = color.new(c_up_4, 30)

    if tf_guard
        table.cell(hud, 0, 0, s_guard_msg, text_color=color.new(c_up_3, 0), bgcolor=color.new(c_neutral, 85), text_size=font_size)
        table.merge_cells(hud, 0, 0, 1, 0)
    else
        // Header (merged) — ASCII brand cell
        table.cell(hud, 0, 0, "GOLDEN RANGE", text_color=color.white, bgcolor=c_hdr_bg, text_size=font_size)
        table.cell(hud, 1, 0, "",          bgcolor=c_hdr_bg)
        table.merge_cells(hud, 0, 0, 1, 0)

        // Reset TF
        table.cell(hud, 0, 1, s_reset_tf, text_color=color.white, bgcolor=c_row_bg, text_size=font_size)
        table.cell(hud, 1, 1, reset_tf,   text_color=color.white, bgcolor=c_row_bg, text_size=font_size)

        // % elapsed (clamped 0..100; time in ms, reset_sec in s)
        float elapsed_pct = reset_sec > 0 and not na(reset_start_time) ? math.min(100.0, math.max(0.0, (time - reset_start_time) / (reset_sec * 1000.0) * 100.0)) : 0.0
        table.cell(hud, 0, 2, s_elapsed,                              text_color=color.white, bgcolor=c_row_bg, text_size=font_size)
        table.cell(hud, 1, 2, str.tostring(elapsed_pct, "#.0") + "%", text_color=color.white, bgcolor=c_row_bg, text_size=font_size)

        // OSC HI (outermost upper — purple if orphan, else red)
        table.cell(hud, 0, 3, s_osc_hi, text_color=color.white, bgcolor=c_row_bg, text_size=font_size)
        table.cell(hud, 1, 3, na(osc_hi) ? "—" : str.tostring(osc_hi, format.mintick), text_color=color.new(orphan_hi ? c_up_4 : c_up_3, 0), bgcolor=c_row_bg, text_size=font_size)

        // BAND HI (inner upper — blue)
        table.cell(hud, 0, 4, s_band_hi, text_color=color.white, bgcolor=c_row_bg, text_size=font_size)
        table.cell(hud, 1, 4, na(band_hi) ? "—" : str.tostring(band_hi, format.mintick), text_color=color.new(c_dn_3, 0), bgcolor=c_row_bg, text_size=font_size)

        // BAND LO (inner lower — blue)
        table.cell(hud, 0, 5, s_band_lo, text_color=color.white, bgcolor=c_row_bg, text_size=font_size)
        table.cell(hud, 1, 5, na(band_lo) ? "—" : str.tostring(band_lo, format.mintick), text_color=color.new(c_dn_3, 0), bgcolor=c_row_bg, text_size=font_size)

        // OSC LO (outermost lower — purple if orphan, else red)
        table.cell(hud, 0, 6, s_osc_lo, text_color=color.white, bgcolor=c_row_bg, text_size=font_size)
        table.cell(hud, 1, 6, na(osc_lo) ? "—" : str.tostring(osc_lo, format.mintick), text_color=color.new(orphan_lo ? c_up_4 : c_up_3, 0), bgcolor=c_row_bg, text_size=font_size)
````
