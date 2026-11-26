# Signature Pivots: Conviction & Divergence

- url: https://www.tradingview.com/script/Xxzhkinu-Signature-Pivots-Conviction-Divergence/
- type: indicator
- pine_id: PUB;e2c30acd03254af392b6ddb520d92658
- version: 1.0

## Description

[b]Signature Pivots: Conviction & Divergence[/b]

Every chart prints dozens of swings and most of them are noise. This
tool has one job: help you pick the pivots worth anchoring analysis
on. It finds confirmed swing highs and lows, filters out the minor
wiggles, stamps each survivor with a time signature, grades it by
volume conviction, and warns when a new extreme was made on hollow
volume. It draws and grades structure - it never tells you to buy or
sell.

[b]How pivots are found[/b]

A swing high is a bar whose high is the highest of N bars on either
side (N is the "Pivot strength" input; swing lows mirror it). A pivot
can therefore only confirm N bars after the fact - that is detection
lag, not repainting, and once a marker prints it stays. On top of that
sits a size filter: a new pivot must be at least "Min swing size" ATRs
away from the previous kept pivot, so a daily chart shows the swings
that matter instead of every five-bar fractal. Set it to 0 if you want
them all.

[b]The signature[/b]

This is the unusual part. Each pivot's UTC timestamp is converted,
through sidereal time at the market center you choose, into the degree
of the zodiac rising on the eastern horizon at that exact moment - the
Ascendant. That gives a number from 0 to 360 which sweeps the full
circle once every 23 hours 56 minutes. It depends only on the clock
and the location, never on price, so the same moment always maps to
the same number on every chart and timeframe. In plain terms, it tags
each pivot with where in the daily rotation cycle it formed. The old
observation being tested here is that turns tend to recur at the same
phase of that cycle.

[b]Matching[/b]

The last 24 pivots (a setting) are kept in memory. Each new pivot's
signature is compared against stored pivots of the same kind only -
highs against earlier highs, lows against earlier lows - measured
correctly around the 360 ring, so 359 and 1 are two degrees apart, not
358. If the nearest same-kind signature sits within the match
tolerance (1 degree by default), the pivot is flagged: its label
highlights with a star, a dotted line links it back to the pivot it
repeats, and an alert fires. A match is a candidate worth studying,
not proof of anything - the defaults are deliberately strict so that a
star stays rare.

[b]Conviction and divergence[/b]

Volume flow is measured with on-balance volume: each bar's volume
added on an up close, subtracted on a down close. A pivot's conviction
is simply whether OBV stood above or below its own moving average at
the pivot bar - was volume flow supporting the move that made the
swing, or fighting it. Divergence looks at consecutive extremes: a new
swing high above the previous one, with OBV lower than it was at the
previous high, prints a bearish divergence mark (price stretched,
volume flow did not follow); new lows mirror that for bullish
divergence.
Why these three live in one tool: they are three questions about the
same object. Did this pivot form at a recurring phase of the rotation
cycle? Did volume back the swing? Was the extreme hollow? Read
together on one label, they turn a plain zigzag into a graded list of
anchor candidates.

[b]Reading the chart[/b]

H and L mark confirmed swing highs and lows. The caret after the
letter is conviction at that pivot (^ above the OBV average, v below).
The number is the signature in degrees. A star and highlighted color
mean a signature match, with a dotted line back to the earlier pivot
it repeats. "Div" marks print at divergent extremes. The zigzag
connects consecutive pivots so the structure stays visible. The HUD
shows the live conviction state, the last signature, the last
high-value pivot, and running pivot and match counts - event counts,
not performance figures.

[b]Settings worth knowing[/b]

Pivot strength and Min swing size control how selective the swing
detection is. Match tolerance and Match memory control how strict a
"repeat" must be - loosening either will flag more pivots, and past a
point most of those extra stars are coincidence, which is why the
defaults are tight. The Market Center sets the geographic reference
for the signature; keep one consistent choice across your charts so
signatures stay comparable (for 24/7 crypto any consistent center
works). "Only show high-value pivots" hides everything except matches
if you want the quietest possible chart.

[b]Using it[/b]

It runs on any timeframe, with one honest caveat: the matching layer
is most alive on intraday charts. On daily bars every pivot stamps at
the same time of day, so signatures drift about a degree per day and
repeats are naturally rare and far apart - on a daily chart this tool
is mainly a swing, conviction and divergence grader. Use it as a
filter, not a trigger: when you need a swing to anchor other work on,
prefer the starred pivots, and among those prefer the ones whose
conviction agreed with the swing and that carry no divergence warning.
Alerts are provided for a high-value pivot, bullish and bearish
divergence, and each new confirmed swing.

[b]
What is original here[/b]

Swing detection, OBV and divergence are standard public techniques.
The original work is the signature layer - the rising-degree
computation runs entirely on the chart from the timestamp, with no
external data - together with the ring-correct same-kind matching and
its pivot-to-pivot links, and the fusion of the three readings into a
single graded label. Written from scratch in Pine v6; no open-source
code was reused.

[b]
Honest notes[/b]

Pivots confirm late by construction. Some matches will always be
coincidence; the tolerance and memory settings exist to keep that in
check, and a star is an invitation to look closer, nothing more.
Different market centers give different signature numbers, so keep
yours consistent. Educational study tool; the HUD counts events, not
wins; no performance claims; not financial advice.

## Source Code

````pine
//@version=6
// Signature Pivots: Conviction & Divergence
//
// Marks confirmed swing highs/lows and stamps each one with a "signature" - a
// deterministic 0..360 value derived from the pivot's UTC timestamp and a fixed
// geographic reference via sidereal time, so the same clock-moment always maps to
// the same number. When a new pivot's signature repeats an earlier one (their
// angles land within tolerance) it is flagged high-value and linked back to its
// match - those repeats mark points that recur at the same phase of a slow time
// cycle, the pivots worth anchoring on. Each pivot is also graded by volume-flow
// conviction (OBV vs its average), and price/volume divergence is flagged.
//
// Educational use only: the markers are not buy/sell signals and nothing here is
// financial advice. Pivots confirm a few bars after the pivot bar, so they don't
// repaint once printed; divergence can still shift on the live bar.
indicator("Signature Pivots: Conviction & Divergence", overlay=true, max_labels_count=500, max_lines_count=500)
// theme
c_primary = #8BE04A
c_match   = #FF5CA8
c_panel   = #12140F
c_edge    = #2C3620
c_label   = #8A9678
c_value   = #EAF3E0
// input groups
grp_dash = "Display"
grp_piv  = "Pivots"
grp_sig  = "Signature"
grp_obv  = "Conviction"
grp_mkt  = "Market"
grp_col  = "Colors"
// display / HUD
show_dash = input.bool(true, "Show HUD", group=grp_dash)
dash_size = input.string("Small", "HUD text size", options=["Tiny", "Small", "Normal"], group=grp_dash)
dash_pos  = input.string("Bottom Left", "HUD position", options=["Bottom Right", "Bottom Left", "Top Right", "Top Left"], group=grp_dash)
// pivot detection
piv_len     = input.int(8, "Pivot strength (L/R bars)", minval=1, group=grp_piv, tooltip="Bars required on each side to confirm a swing. Higher = fewer, more significant pivots. Confirms after the fact (non-repainting once printed).")
min_atr     = input.float(2.0, "Min swing size (ATR multiples)", minval=0.0, step=0.25, group=grp_piv, tooltip="Only keep a pivot if it sits at least this many ATR-14 away from the previous kept pivot - filters minor wiggles so only meaningful swings are labeled, matched and graded. 0 = keep every fractal.")
show_zz     = input.bool(true, "Connect pivots (ZigZag)", group=grp_piv)
show_conv   = input.bool(true, "Show conviction on pivots", group=grp_piv)
show_px_lbl = input.bool(false, "Show pivot price in label", group=grp_piv)
// signature + matching
show_sig  = input.bool(true, "Tag pivots with signature", group=grp_sig)
match_on  = input.bool(true, "Highlight signature matches", group=grp_sig)
match_tol = input.float(1.0, "Signature match tolerance", minval=0.1, group=grp_sig, tooltip="How close two pivot signatures must be to count as a match (degrees on the 360 ring). Smaller = stricter and rarer. Loose tolerances with a deep memory will flag most pivots by coincidence.")
match_mem = input.int(24, "Match memory (pivots)", minval=4, maxval=120, group=grp_sig, tooltip="How many recent pivots are kept for matching. Deeper memory = more chance matches; keep it shallow so a star stays meaningful.")
only_matches = input.bool(false, "Only show high-value pivots (matches)", group=grp_sig, tooltip="Hide ordinary swings - show only pivots whose signature matches an earlier one, plus their link.")
// volume conviction
use_obv_div = input.bool(true, "Show divergence signals", group=grp_obv)
obv_len     = input.int(20, "Conviction smoothing", minval=1, group=grp_obv)
// market center - sets the reference the signature is measured from
loc_preset = input.string("New York (NYSE)", "Market Center", options=["New York (NYSE)", "Chicago (CME)", "London (LSE)", "Frankfurt (FSE)", "Zurich (SIX)", "Tokyo (TSE)", "Hong Kong (HKEX)", "Sydney (ASX)", "Custom"], group=grp_mkt, tooltip="The geographic reference the signature is measured from. Keep it consistent so signatures stay comparable across charts.")
custom_lat = input.float(40.7128, "Custom center (lat)",  group=grp_mkt)
custom_lon = input.float(-74.0060, "Custom center (lon)", group=grp_mkt)
f_lat() =>
    loc_preset == "Chicago (CME)" ? 41.8781 : loc_preset == "London (LSE)" ? 51.5074 : loc_preset == "Frankfurt (FSE)" ? 50.1109 : loc_preset == "Zurich (SIX)" ? 47.3769 : loc_preset == "Tokyo (TSE)" ? 35.6762 : loc_preset == "Hong Kong (HKEX)" ? 22.3193 : loc_preset == "Sydney (ASX)" ? -33.8688 : loc_preset == "Custom" ? custom_lat : 40.7128
f_lon() =>
    loc_preset == "Chicago (CME)" ? -87.6298 : loc_preset == "London (LSE)" ? -0.1278 : loc_preset == "Frankfurt (FSE)" ? 8.6821 : loc_preset == "Zurich (SIX)" ? 8.5417 : loc_preset == "Tokyo (TSE)" ? 139.6503 : loc_preset == "Hong Kong (HKEX)" ? 114.1694 : loc_preset == "Sydney (ASX)" ? 151.2093 : loc_preset == "Custom" ? custom_lon : -74.0060
float asc_lat = f_lat()
float asc_lon = f_lon()
// pivot colours
c_hi = input.color(#FF5CA8, "Swing high", group=grp_col)
c_lo = input.color(#8BE04A, "Swing low",  group=grp_col)
c_zz = input.color(#5F8A3C, "ZigZag",      group=grp_col)
// Signature math. The signature is a 0..360 value computed from a pivot's timestamp
// and the chosen market center - deterministic, so the same moment always maps to
// the same number. atan2 is hand-rolled because Pine has no math.atan2.
f_st(t) =>
    y = year(t, "UTC"), m = month(t, "UTC"), d = dayofmonth(t, "UTC")
    h = hour(t, "UTC") + minute(t, "UTC")/60.0 + second(t, "UTC")/3600.0
    if m <= 2
        y := y - 1, m := m + 12
    jd = math.floor(365.25*(y+4716)) + math.floor(30.6001*(m+1)) + d + 2 - math.floor(y/100) + math.floor(math.floor(y/100)/4) - 1524.5 + h/24.0
    (280.46061837 + 360.98564736629*(jd-2451545.0)) % 360
f_atan2(float yv, float xv) =>
    float r = 0.0
    if xv > 0
        r := math.atan(yv / xv)
    else if xv < 0 and yv >= 0
        r := math.atan(yv / xv) + math.pi
    else if xv < 0 and yv < 0
        r := math.atan(yv / xv) - math.pi
    else if xv == 0 and yv > 0
        r := math.pi / 2
    else if xv == 0 and yv < 0
        r := -math.pi / 2
    r
f_signature(t, float lat, float lon) =>
    float d2r = math.pi / 180.0
    float st  = f_st(t)
    float lst = (st + lon) % 360.0
    float k   = 23.4392911 * d2r
    float a   = lst * d2r
    float p   = lat * d2r
    float sg  = f_atan2(math.cos(a), -(math.sin(a)*math.cos(k) + math.tan(p)*math.sin(k)))
    (sg / d2r % 360.0 + 360.0) % 360.0
// shortest gap between two signatures (they wrap at 360)
f_ang(float a, float b) =>
    float d = ((a - b) % 360.0 + 360.0) % 360.0
    d > 180.0 ? 360.0 - d : d
// conviction = where volume flow sits relative to its own average
float obv_calc   = ta.obv
float obv_smooth = ta.ema(obv_calc, obv_len)
bool  obv_bullish = obv_calc > obv_smooth
// remember recent pivots so we can look for repeating signatures
var float[] sig_v = array.new<float>()
var int[]   sig_b = array.new<int>()
var float[] sig_p = array.new<float>()
var int[]   sig_k = array.new<int>()   // pivot kind: 1 = high, -1 = low
// nearest earlier SAME-KIND pivot within tolerance (by signature), else -1
f_match_idx(float s, int kind) =>
    int   best  = -1
    float bestd = match_tol + 1.0
    if array.size(sig_v) > 0
        for i = 0 to array.size(sig_v) - 1
            if array.get(sig_k, i) == kind
                float d = f_ang(s, array.get(sig_v, i))
                if d <= match_tol and d < bestd
                    bestd := d
                    best  := i
    best
var float last_px    = na
var int   last_bx    = na
var int   piv_count  = 0
var int   match_count = 0
var float last_sig   = na
var float last_anchor_px = na
var int   last_anchor_t  = na
bool matched_now = false
float atr14 = ta.atr(14)
float ph = ta.pivothigh(piv_len, piv_len)
float pl = ta.pivotlow(piv_len, piv_len)
f_big(float px) =>
    min_atr == 0.0 or na(last_px) or math.abs(px - last_px) >= min_atr * nz(atr14[piv_len])
bool is_ph = not na(ph) and f_big(ph)
bool is_pl = not na(pl) and f_big(pl)
// swing high
if is_ph
    int   bx  = bar_index[piv_len]
    float sig = f_signature(time[piv_len], asc_lat, asc_lon)
    bool  conv_up = obv_calc[piv_len] > obv_smooth[piv_len]
    int   midx = f_match_idx(sig, 1)
    bool  matched = match_on and midx >= 0
    piv_count := piv_count + 1
    last_sig  := sig
    if matched
        match_count := match_count + 1
        matched_now := true
        last_anchor_px := ph
        last_anchor_t  := time[piv_len]
        line.new(array.get(sig_b, midx), array.get(sig_p, midx), bx, ph, xloc=xloc.bar_index, color=color.new(c_match, 20), width=1, style=line.style_dotted)
    if matched or not only_matches
        string txt = "H" + (show_conv ? (conv_up ? " ^" : " v") : "") + (show_sig ? " - " + str.tostring(math.round(sig)) : "") + (matched ? " *" : "") + (show_px_lbl or matched ? "\n" + str.tostring(ph, format.mintick) : "")
        label.new(bx, ph, txt, xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down, color=matched ? color.new(c_match, 10) : color.new(c_hi, 20), textcolor=color.white, size=size.small)
    if show_zz and not only_matches and not na(last_bx)
        line.new(last_bx, last_px, bx, ph, xloc=xloc.bar_index, color=color.new(c_zz, 30), width=1)
    array.push(sig_v, sig)
    array.push(sig_b, bx)
    array.push(sig_p, ph)
    array.push(sig_k, 1)
    if array.size(sig_v) > match_mem
        array.shift(sig_v)
        array.shift(sig_b)
        array.shift(sig_p)
        array.shift(sig_k)
    last_bx := bx
    last_px := ph
// swing low
if is_pl
    int   bx  = bar_index[piv_len]
    float sig = f_signature(time[piv_len], asc_lat, asc_lon)
    bool  conv_up = obv_calc[piv_len] > obv_smooth[piv_len]
    int   midx = f_match_idx(sig, -1)
    bool  matched = match_on and midx >= 0
    piv_count := piv_count + 1
    last_sig  := sig
    if matched
        match_count := match_count + 1
        matched_now := true
        last_anchor_px := pl
        last_anchor_t  := time[piv_len]
        line.new(array.get(sig_b, midx), array.get(sig_p, midx), bx, pl, xloc=xloc.bar_index, color=color.new(c_match, 20), width=1, style=line.style_dotted)
    if matched or not only_matches
        string txt = "L" + (show_conv ? (conv_up ? " ^" : " v") : "") + (show_sig ? " - " + str.tostring(math.round(sig)) : "") + (matched ? " *" : "") + (show_px_lbl or matched ? "\n" + str.tostring(pl, format.mintick) : "")
        label.new(bx, pl, txt, xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=matched ? color.new(c_match, 10) : color.new(c_lo, 20), textcolor=color.white, size=size.small)
    if show_zz and not only_matches and not na(last_bx)
        line.new(last_bx, last_px, bx, pl, xloc=xloc.bar_index, color=color.new(c_zz, 30), width=1)
    array.push(sig_v, sig)
    array.push(sig_b, bx)
    array.push(sig_p, pl)
    array.push(sig_k, -1)
    if array.size(sig_v) > match_mem
        array.shift(sig_v)
        array.shift(sig_b)
        array.shift(sig_p)
        array.shift(sig_k)
    last_bx := bx
    last_px := pl
// divergence: price makes a new extreme but volume flow doesn't confirm
float prev_ph_price = ta.valuewhen(is_ph, ph, 1)
float prev_ph_obv   = ta.valuewhen(is_ph, obv_calc[piv_len], 1)
float prev_pl_price = ta.valuewhen(is_pl, pl, 1)
float prev_pl_obv   = ta.valuewhen(is_pl, obv_calc[piv_len], 1)
bool bear_div = is_ph and (ph > prev_ph_price) and (obv_calc[piv_len] < prev_ph_obv)
bool bull_div = is_pl and (pl < prev_pl_price) and (obv_calc[piv_len] > prev_pl_obv)
if use_obv_div and bear_div
    label.new(bar_index[piv_len], high[piv_len], "v Div", xloc=xloc.bar_index, yloc=yloc.abovebar, color=color(na), textcolor=c_hi, style=label.style_none, size=size.small)
if use_obv_div and bull_div
    label.new(bar_index[piv_len], low[piv_len],  "Div ^", xloc=xloc.bar_index, yloc=yloc.belowbar, color=color(na), textcolor=c_lo, style=label.style_none, size=size.small)
alertcondition(matched_now, "Signature Pivots: high-value pivot", "New high-value pivot (signature match) on {{ticker}} @ {{close}}")
alertcondition(bull_div, "Signature Pivots: bullish divergence", "Bullish divergence on {{ticker}} @ {{close}}")
alertcondition(bear_div, "Signature Pivots: bearish divergence", "Bearish divergence on {{ticker}} @ {{close}}")
alertcondition(is_ph,    "Signature Pivots: new swing high", "Swing high confirmed on {{ticker}}")
alertcondition(is_pl,    "Signature Pivots: new swing low",  "Swing low confirmed on {{ticker}}")
// HUD
if show_dash and barstate.islast
    string dpos = dash_pos == "Bottom Right" ? position.bottom_right : dash_pos == "Top Right" ? position.top_right : dash_pos == "Top Left" ? position.top_left : position.bottom_left
    string tsz  = dash_size == "Tiny" ? size.tiny : dash_size == "Normal" ? size.normal : size.small
    color  obv_col = obv_bullish ? c_lo : c_hi
    string al = text.align_left
    string ar = text.align_right
    var table tb = table.new(dpos, 2, 6, bgcolor=c_panel, frame_color=c_edge, frame_width=1, border_color=c_edge, border_width=1)
    table.cell(tb, 0, 0, " Signature",    text_color=c_panel, bgcolor=c_primary, text_size=tsz, text_halign=al)
    table.cell(tb, 1, 0, "Pivots ",       text_color=c_panel, bgcolor=c_primary, text_size=tsz, text_halign=ar)
    table.cell(tb, 0, 1, " Conviction",   text_color=c_label, text_size=tsz, text_halign=al)
    table.cell(tb, 1, 1, (obv_bullish ? "* Bullish" : "* Bearish") + " ", text_color=obv_col, text_size=tsz, text_halign=ar)
    table.cell(tb, 0, 2, " Last signature", text_color=c_label, text_size=tsz, text_halign=al)
    table.cell(tb, 1, 2, (na(last_sig) ? "-" : str.tostring(math.round(last_sig))) + " ", text_color=c_value, text_size=tsz, text_halign=ar)
    table.cell(tb, 0, 3, " Last anchor",  text_color=c_label, text_size=tsz, text_halign=al)
    table.cell(tb, 1, 3, (na(last_anchor_px) ? "-" : str.tostring(last_anchor_px, format.mintick) + "  " + str.format_time(last_anchor_t, "MMM-dd HH:mm", syminfo.timezone)) + " ", text_color=c_match, text_size=tsz, text_halign=ar)
    table.cell(tb, 0, 4, " Matches",      text_color=c_label, text_size=tsz, text_halign=al)
    table.cell(tb, 1, 4, str.tostring(match_count) + " ", text_color=c_match, text_size=tsz, text_halign=ar)
    table.cell(tb, 0, 5, " Pivots",       text_color=c_label, text_size=tsz, text_halign=al)
    table.cell(tb, 1, 5, str.tostring(piv_count) + " ", text_color=c_value, text_size=tsz, text_halign=ar)
````
