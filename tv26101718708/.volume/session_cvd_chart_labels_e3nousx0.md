# Session CVD - Chart Labels

- url: https://www.tradingview.com/script/E3noUsx0-Session-CVD-Chart-Labels/
- type: indicator
- pine_id: PUB;b870b822ac254474958fd2abf3b9c1ca
- version: 2.0

## Description

[b]Session CVD Chart Labels[/b] is the companion overlay to [b]Session CVD Divergence[/b]. It draws divergence lines between the price pivots directly on the main chart, with labels at each signal.

[b]ADD BOTH SCRIPTS TO YOUR CHART[/b]

This script does nothing useful on its own. It is designed to be used alongside [b]Session CVD Divergence[/b], which handles the CVD calculation and displays the divergence lines in a separate pane.
[url=https://www.tradingview.com/script/efgrb3ja-Session-CVD-Divergence/]https://www.tradingview.com/script/efgrb3ja-Session-CVD-Divergence/[/url]

[list]
[*][b]Session CVD Divergence[/b] — add to a new pane. CVD lines per session plus divergence lines between CVD pivots.
[*][b]Session CVD — Chart Labels[/b] (this script) — add as an overlay. Divergence lines between price pivots plus labels on the main chart.
[/list]

Keep the settings (session times, pivot length, colors) identical between both scripts.

[b]WHAT THIS SCRIPT DRAWS[/b]

When a divergence is detected, a line is drawn on the price chart connecting the two price pivots that form the signal. A label appears at the second pivot identifying the type:
[list]
[*][b]BD[/b] — Regular Bullish Divergence (solid green line)
[*][b]BrD[/b] — Regular Bearish Divergence (solid red line)
[*][b]hBD[/b] — Hidden Bullish Divergence (dashed dark green line)
[*][b]hBrD[/b] — Hidden Bearish Divergence (dashed orange line)
[/list]

Solid lines for reversal signals. Dashed lines for continuation signals.

[b]SETTINGS[/b]
[list]
[*][b]Session Boundaries[/b] — UTC hours for Asian (00 to 08), London (08 to 16), and NY (13 to 21) sessions.
[*][b]Pivot Detection Bars[/b] — sensitivity of the pivot detection. Lower = more signals, higher = only major confirmed pivots.
[*][b]Regular / Hidden divergence[/b] — toggle each type independently.
[*][b]Colors[/b] — all four signal types individually customizable.
[/list]

[b]RECOMMENDED TIMEFRAME[/b]

[b]15m to 4H[/b], matching the main Session CVD Divergence script.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © cliteka-cell

//@version=6
indicator("Session CVD — Chart Labels", shorttitle="SCD Labels", overlay=true,
          max_lines_count=500, max_labels_count=500)

// ── Companion to "Session CVD Divergence" ───────────────────────────────────
// Runs the same session CVD and divergence logic but draws labels on the
// main price chart instead of the indicator pane. Add both scripts to your
// chart — this one places the signal labels at the actual price pivot,
// the other shows the CVD lines and divergence lines in a separate pane.

// ── Settings (must match the main script) ────────────────────────────────────
var g_s = "Session Boundaries (UTC hours)"
asia_start = input.int(0,  "Asian open",   minval=0, maxval=23, group=g_s)
asia_end   = input.int(8,  "Asian close",  minval=0, maxval=23, group=g_s)
lon_start  = input.int(8,  "London open",  minval=0, maxval=23, group=g_s)
lon_end    = input.int(16, "London close", minval=0, maxval=23, group=g_s)
ny_start   = input.int(13, "NY open",      minval=0, maxval=23, group=g_s)
ny_end     = input.int(21, "NY close",     minval=0, maxval=23, group=g_s)

var g_d = "Display"
show_div    = input.bool(true, "Regular divergence labels",  group=g_d)
show_hidden = input.bool(true, "Hidden divergence labels",   group=g_d)
piv_len     = input.int (3,    "Pivot detection bars", minval=2, maxval=10, group=g_d)
c_bull      = input.color(color.new(color.lime, 0), "Regular bull",  group=g_d)
c_bear      = input.color(color.new(color.red,  0), "Regular bear",  group=g_d)
c_hbull     = input.color(color.new(#1a7a1a,   0), "Hidden bull",   group=g_d)
c_hbear     = input.color(color.new(#ff8800,   0), "Hidden bear",   group=g_d)

// ── Session membership ────────────────────────────────────────────────────────
int utc_h = hour(time, "UTC")

bool in_asia = utc_h >= asia_start and utc_h < asia_end
bool in_lon  = utc_h >= lon_start  and utc_h < lon_end
bool in_ny   = utc_h >= ny_start   and utc_h < ny_end

int sess_id = in_asia ? 1 : in_lon ? 2 : in_ny ? 3 : 0

// ── Volume delta ──────────────────────────────────────────────────────────────
float delta = high != low ? volume * (2.0 * (close - low) / (high - low) - 1.0) : 0.0

// ── Session CVD ───────────────────────────────────────────────────────────────
var float cvd_asia = 0.0
var float cvd_lon  = 0.0
var float cvd_ny   = 0.0

if not in_asia[1] and in_asia
    cvd_asia := 0.0
if not in_lon[1] and in_lon
    cvd_lon := 0.0
if not in_ny[1] and in_ny
    cvd_ny := 0.0

if in_asia
    cvd_asia += delta
if in_lon
    cvd_lon += delta
if in_ny
    cvd_ny += delta

float cvd_active = in_asia ? cvd_asia : in_lon ? cvd_lon : in_ny ? cvd_ny : na

// ── Pivot detection ───────────────────────────────────────────────────────────
float ph = ta.pivothigh(cvd_active, piv_len, piv_len)
float pl = ta.pivotlow (cvd_active, piv_len, piv_len)

// ── Divergence detection → labels on the price chart ─────────────────────────
var int   last_ph_bar   = na
var float last_ph_cvd   = na
var float last_ph_price = na
var int   last_ph_sess  = na

var int   last_pl_bar   = na
var float last_pl_cvd   = na
var float last_pl_price = na
var int   last_pl_sess  = na

if (show_div or show_hidden) and not na(ph)
    int   ph_bar    = bar_index - piv_len
    float ph_price  = high[piv_len]
    int   ph_sess   = sess_id[piv_len]

    if not na(last_ph_bar) and ph_sess == last_ph_sess
        // Regular bear: price HH, CVD LH
        if show_div and ph_price > last_ph_price and ph < last_ph_cvd
            line.new(last_ph_bar, last_ph_price, ph_bar, ph_price,
                     xloc=xloc.bar_index, color=c_bear, width=2, style=line.style_solid)
            label.new(ph_bar, ph_price, "BrD",
                      xloc=xloc.bar_index, style=label.style_label_down,
                      color=c_bear, textcolor=color.white, size=size.small)
        // Hidden bear: price LH, CVD HH
        else if show_hidden and ph_price < last_ph_price and ph > last_ph_cvd
            line.new(last_ph_bar, last_ph_price, ph_bar, ph_price,
                     xloc=xloc.bar_index, color=c_hbear, width=2, style=line.style_dashed)
            label.new(ph_bar, ph_price, "hBrD",
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
        // Regular bull: price LL, CVD HL
        if show_div and pl_price < last_pl_price and pl > last_pl_cvd
            line.new(last_pl_bar, last_pl_price, pl_bar, pl_price,
                     xloc=xloc.bar_index, color=c_bull, width=2, style=line.style_solid)
            label.new(pl_bar, pl_price, "BD",
                      xloc=xloc.bar_index, style=label.style_label_up,
                      color=c_bull, textcolor=color.white, size=size.small)
        // Hidden bull: price HL, CVD LL
        else if show_hidden and pl_price > last_pl_price and pl < last_pl_cvd
            line.new(last_pl_bar, last_pl_price, pl_bar, pl_price,
                     xloc=xloc.bar_index, color=c_hbull, width=2, style=line.style_dashed)
            label.new(pl_bar, pl_price, "hBD",
                      xloc=xloc.bar_index, style=label.style_label_up,
                      color=c_hbull, textcolor=color.white, size=size.small)

    last_pl_bar   := pl_bar
    last_pl_cvd   := pl
    last_pl_price := pl_price
    last_pl_sess  := pl_sess
````
