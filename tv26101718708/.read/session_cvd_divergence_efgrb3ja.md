# Session CVD Divergence

- url: https://www.tradingview.com/script/efgrb3ja-Session-CVD-Divergence/
- type: indicator
- pine_id: PUB;24d48e2973604c8aaf6c63b8ce2d2d35
- version: 1.0

## Description

[b]Session CVD Divergence[/b] splits Cumulative Volume Delta into three independent session streams (Asian, London, and New York) and automatically detects all four divergence types between price and order flow.

[b]TWO-SCRIPT SETUP[/b]

This indicator comes as a pair:
[list]
[*][b]Session CVD Divergence[/b] (this script) — add to a new pane. Shows the CVD lines for each session and draws divergence lines between the CVD pivots.
[*][b]Session CVD — Chart Labels[/b] — add as an overlay. Draws the same divergence lines between the price pivots on the main chart, with labels at each signal.
[/list]
Both scripts must be on the chart together for the full picture. Settings (session times, pivot length, colors) are identical between the two, keep them in sync.

Session CVD Chart Labels:
[url=https://www.tradingview.com/script/E3noUsx0-Session-CVD-Chart-Labels/]https://www.tradingview.com/script/E3noUsx0-Session-CVD-Chart-Labels/[/url]

[b]WHY SESSION-SCOPED CVD?[/b]

A standard CVD indicator runs continuously across the entire day. That means London's aggressive buying gets buried inside Asia's quiet accumulation, and by the time New York opens you're reading a blended signal with no session context.

This indicator resets CVD to zero at the open of each session. What you see is the net order flow [i]within[/i] that session only, independent of what happened before.

[b]THE FOUR DIVERGENCE TYPES[/b]

[b]Regular divergences (reversal signals, solid lines)[/b]
[list]
[*][b]BD[/b] — Bullish Divergence: price makes a lower low, CVD makes a higher low. Selling pressure is drying up.
[*][b]BrD[/b] — Bearish Divergence: price makes a higher high, CVD makes a lower high. Buying pressure is fading.
[/list]

[b]Hidden divergences (continuation signals, dashed lines)[/b]
[list]
[*][b]hBD[/b] — Hidden Bullish Divergence: price makes a higher low, CVD makes a lower low. Uptrend remains intact beneath the surface.
[*][b]hBrD[/b] — Hidden Bearish Divergence: price makes a lower high, CVD makes a higher high. Downtrend continuation despite apparent strength.
[/list]

Each signal draws a line directly between the two pivots that form the divergence: on the CVD pane between the CVD pivot values, and on the main chart between the price pivot values. Solid lines for reversals, dashed lines for continuations.

[b]SAME-SESSION CONSTRAINT[/b]

Divergence is only detected between two pivots that belong to the same session. A CVD pivot from the Asian session and a pivot from the London session are never compared, as their CVD scales are incompatible since each resets independently. This eliminates a significant source of false signals present in most divergence tools.

[b]DELTA APPROXIMATION[/b]

Each bar's volume delta is estimated using the close-position formula:

[i]delta = V x ( 2 x (C - L) / (H - L) - 1 )[/i]

A bar closing at its high contributes its full volume as buying. A bar closing at its low contributes its full volume as selling. Everything between is proportional.

[b]SETTINGS[/b]
[list]
[*][b]Session Boundaries[/b] — all session open/close times are configurable in UTC hours. Defaults: Asian 00 to 08, London 08 to 16, NY 13 to 21.
[*][b]Pivot Detection Bars[/b] — controls sensitivity. Lower = more signals. Higher = only major pivots confirmed by more bars on each side.
[*][b]Regular / Hidden divergence[/b] — each type can be toggled independently.
[*][b]Colors[/b] — all four divergence types and all three session lines are individually customizable.
[*][b]Session background[/b] — subtle shading shows which session each bar belongs to.
[/list]

[b]RECOMMENDED TIMEFRAME[/b]

[b]15m to 4H.[/b] A warning label appears if the indicator is applied to a daily or higher timeframe.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © cliteka-cell

//@version=6
indicator("Session CVD Divergence", shorttitle="SCD", overlay=false,
          max_lines_count=500, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════════════════
// WHAT IS SESSION CVD DIVERGENCE?
//
// Cumulative Volume Delta (CVD) tracks net buying vs selling volume over
// time. This indicator calculates CVD separately for each major session —
// Asian, London, NY — and resets at each session open.
//
// DIVERGENCE (the key signal):
// When price makes a new high/low but CVD makes the OPPOSITE pivot, the
// move is not confirmed by order flow. A line is drawn between the two
// CVD pivots that form the divergence, colored red (bearish) or green
// (bullish). Both pivots must belong to the same session to avoid
// cross-session scale distortion.
//
// DELTA APPROXIMATION:
//   delta = V × (2×(C−L)/(H−L) − 1)
// Close at the high → full positive volume. Close at the low → full
// negative volume. Proportional between.
//
// RECOMMENDED TIMEFRAME: 15m – 4H (intraday only)
// ═══════════════════════════════════════════════════════════════════════════

// ── Timeframe guard ───────────────────────────────────────────────────────────
is_valid = timeframe.isminutes and timeframe.multiplier < 1440
if barstate.islast and not is_valid
    label.new(bar_index, 0.0,
              "⚠️  Session CVD requires an intraday timeframe (15m – 4H).",
              xloc=xloc.bar_index, color=color.red, textcolor=color.white,
              style=label.style_label_left, size=size.normal)

// ── Settings ──────────────────────────────────────────────────────────────────
var g_s = "Session Boundaries (UTC hours)"
asia_start = input.int(0,  "Asian open",   minval=0, maxval=23, group=g_s)
asia_end   = input.int(8,  "Asian close",  minval=0, maxval=23, group=g_s)
lon_start  = input.int(8,  "London open",  minval=0, maxval=23, group=g_s)
lon_end    = input.int(16, "London close", minval=0, maxval=23, group=g_s)
ny_start   = input.int(13, "NY open",      minval=0, maxval=23, group=g_s)
ny_end     = input.int(21, "NY close",     minval=0, maxval=23, group=g_s)

var g_d = "Display"
show_asia = input.bool(true,  "Asian CVD",           group=g_d)
show_lon  = input.bool(true,  "London CVD",          group=g_d)
show_ny   = input.bool(true,  "NY CVD",              group=g_d)
show_bg   = input.bool(true,  "Session background",  group=g_d)
show_div    = input.bool(true,  "Regular divergence lines",    group=g_d)
show_hidden = input.bool(true,  "Hidden divergence lines",     group=g_d)
piv_len     = input.int (3,     "Pivot detection bars", minval=2, maxval=10, group=g_d)
c_asia      = input.color(#f5c842, "Asian color",      group=g_d)
c_lon       = input.color(#4488ee, "London color",     group=g_d)
c_ny        = input.color(#ee4455, "NY color",         group=g_d)
c_bull      = input.color(color.new(color.lime, 0), "Regular bull divergence",  group=g_d)
c_bear      = input.color(color.new(color.red,  0), "Regular bear divergence",  group=g_d)
c_hbull     = input.color(color.new(#1a7a1a,   0), "Hidden bull divergence",    group=g_d)
c_hbear     = input.color(color.new(#ff8800,   0), "Hidden bear divergence",    group=g_d)

// ── Session membership ────────────────────────────────────────────────────────
int utc_h = hour(time, "UTC")

bool in_asia = utc_h >= asia_start and utc_h < asia_end
bool in_lon  = utc_h >= lon_start  and utc_h < lon_end
bool in_ny   = utc_h >= ny_start   and utc_h < ny_end

// Integer session ID — used to check that both pivots share the same session
// (cross-session CVD values are not comparable since each resets to 0)
int sess_id = in_asia ? 1 : in_lon ? 2 : in_ny ? 3 : 0

// ── Volume delta per bar (close-position approximation) ───────────────────────
float delta = high != low ? volume * (2.0 * (close - low) / (high - low) - 1.0) : 0.0

// ── Session CVD (resets at session open) ──────────────────────────────────────
var float cvd_asia     = 0.0
var float cvd_lon      = 0.0
var float cvd_ny       = 0.0
var float asia_open_px = na
var float lon_open_px  = na
var float ny_open_px   = na

bool asia_opens = not in_asia[1] and in_asia
bool lon_opens  = not in_lon[1]  and in_lon
bool ny_opens   = not in_ny[1]   and in_ny

if asia_opens
    cvd_asia     := 0.0
    asia_open_px := open
if lon_opens
    cvd_lon      := 0.0
    lon_open_px  := open
if ny_opens
    cvd_ny       := 0.0
    ny_open_px   := open

if in_asia
    cvd_asia += delta
if in_lon
    cvd_lon += delta
if in_ny
    cvd_ny += delta

// Active CVD: whichever session is currently running (na between sessions)
float cvd_active = in_asia ? cvd_asia : in_lon ? cvd_lon : in_ny ? cvd_ny : na

// ── Pivot detection on the active CVD series ──────────────────────────────────
float ph = ta.pivothigh(cvd_active, piv_len, piv_len)
float pl = ta.pivotlow (cvd_active, piv_len, piv_len)

// ── Divergence: draw lines between same-session pivot pairs ───────────────────
// Stores the most recent pivot high/low within each session
var int   last_ph_bar   = na
var float last_ph_cvd   = na
var float last_ph_price = na
var int   last_ph_sess  = na

var int   last_pl_bar   = na
var float last_pl_cvd   = na
var float last_pl_price = na
var int   last_pl_sess  = na

if (show_div or show_hidden) and not na(ph)
    // The confirmed pivot is piv_len bars ago
    int   ph_bar    = bar_index - piv_len
    float ph_price  = high[piv_len]          // price high at that bar
    int   ph_sess   = sess_id[piv_len]       // session at that bar

    // Only compare when both pivots are in the same session
    if not na(last_ph_bar) and ph_sess == last_ph_sess
        // Regular bear: price HH, CVD LH — weakening at top
        if show_div and ph_price > last_ph_price and ph < last_ph_cvd
            line.new(last_ph_bar, last_ph_cvd, ph_bar, ph,
                     xloc=xloc.bar_index, color=c_bear, width=2, style=line.style_solid)
            label.new(ph_bar, ph, "BrD",
                      xloc=xloc.bar_index, style=label.style_label_down,
                      color=c_bear, textcolor=color.white, size=size.small)
        // Hidden bear: price LH, CVD HH — downtrend continuation
        else if show_hidden and ph_price < last_ph_price and ph > last_ph_cvd
            line.new(last_ph_bar, last_ph_cvd, ph_bar, ph,
                     xloc=xloc.bar_index, color=c_hbear, width=2, style=line.style_dashed)
            label.new(ph_bar, ph, "hBrD",
                      xloc=xloc.bar_index, style=label.style_label_down,
                      color=c_hbear, textcolor=color.white, size=size.small)

    last_ph_bar   := ph_bar
    last_ph_cvd   := ph
    last_ph_price := ph_price
    last_ph_sess  := ph_sess

if (show_div or show_hidden) and not na(pl)
    int   pl_bar    = bar_index - piv_len
    float pl_price  = low[piv_len]
    int   pl_sess   = sess_id[piv_len]

    if not na(last_pl_bar) and pl_sess == last_pl_sess
        // Regular bull: price LL, CVD HL — weakening at bottom
        if show_div and pl_price < last_pl_price and pl > last_pl_cvd
            line.new(last_pl_bar, last_pl_cvd, pl_bar, pl,
                     xloc=xloc.bar_index, color=c_bull, width=2, style=line.style_solid)
            label.new(pl_bar, pl, "BD",
                      xloc=xloc.bar_index, style=label.style_label_up,
                      color=c_bull, textcolor=color.white, size=size.small)
        // Hidden bull: price HL, CVD LL — uptrend continuation
        else if show_hidden and pl_price > last_pl_price and pl < last_pl_cvd
            line.new(last_pl_bar, last_pl_cvd, pl_bar, pl,
                     xloc=xloc.bar_index, color=c_hbull, width=2, style=line.style_dashed)
            label.new(pl_bar, pl, "hBD",
                      xloc=xloc.bar_index, style=label.style_label_up,
                      color=c_hbull, textcolor=color.white, size=size.small)

    last_pl_bar   := pl_bar
    last_pl_cvd   := pl
    last_pl_price := pl_price
    last_pl_sess  := pl_sess

// ── Zero reference ────────────────────────────────────────────────────────────
hline(0, "Zero", color=color.new(color.white, 55), linestyle=hline.style_dashed, linewidth=1)

// ── CVD plots ─────────────────────────────────────────────────────────────────
plot(is_valid and show_asia and in_asia ? cvd_asia : na,
     "Asian CVD",  color=c_asia, linewidth=2, style=plot.style_linebr)
plot(is_valid and show_lon  and in_lon  ? cvd_lon  : na,
     "London CVD", color=c_lon,  linewidth=2, style=plot.style_linebr)
plot(is_valid and show_ny   and in_ny   ? cvd_ny   : na,
     "NY CVD",     color=c_ny,   linewidth=2, style=plot.style_linebr)

// ── Session background shading ────────────────────────────────────────────────
bgcolor(show_bg and in_asia ? color.new(c_asia, 93) : na, title="Asia BG")
bgcolor(show_bg and in_lon  ? color.new(c_lon,  93) : na, title="London BG")
bgcolor(show_bg and in_ny   ? color.new(c_ny,   93) : na, title="NY BG")
````
