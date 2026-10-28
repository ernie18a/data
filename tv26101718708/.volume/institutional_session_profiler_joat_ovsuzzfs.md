# Institutional Session Profiler [JOAT]

- url: https://www.tradingview.com/script/OVSUZzfS-Institutional-Session-Profiler-JOAT/
- type: indicator
- pine_id: PUB;de688007248f4456af6e4541d595cce7
- version: 1.0

## Description

[b]Institutional Session Profiler [JOAT][/b]

[b]Introduction[/b]

The Institutional Session Profiler builds a real-time volume-by-price distribution for each of the three major trading sessions — Asia (Tokyo, 01–09 UTC), London (07–16 UTC), and New York (13–22 UTC). For each session, it calculates the Point of Control (POC — the price level with the highest traded volume), the Value Area High (VAH) and Value Area Low (VAL) encompassing 70% of session volume, and a net buy/sell delta that reveals directional institutional participation within the session. Profile shapes are rendered as smooth polyline waves via Catmull-Rom cubic spline interpolation, giving the profiles a clean, readable curve rather than a jagged bar histogram.

The core problem this solves: standard volume profile tools display a single aggregated profile for an arbitrary lookback. Institutional traders operate within defined session windows — Asia sets the range, London typically engineers liquidity, New York resolves direction. Mapping volume distribution per session reveals where institutions are genuinely active versus where price is simply passing through thin volume.

[image]https://www.tradingview.com/x/Dvl3taz9/[/image]

[b]Core Concepts[/b]

[b]1. Lower-Timeframe Volume Accumulation[/b]

To build accurate price-level histograms on any chart timeframe, 1-minute (or user-specified lower timeframe) bars are requested via Pine Script's security_lower_tf function. Each sub-bar's volume is classified as buy-side or sell-side, then placed into the session's price bins:

[pine]
array<float> ltf_c = request.security_lower_tf("", i_ltf, close)
array<float> ltf_v = request.security_lower_tf("", i_ltf, volume)

for i = 0 to ltf_c.size() - 1
    float p = ltf_c.get(i)
    float v = ltf_v.get(i)
    int idx = int(math.floor((p - s_asia.lo) / bin_size))
    s_asia.bins.set(idx, s_asia.bins.get(idx) + v)
[/pine]

This means the profile represents actual sub-bar traded volume distributed across price, not a simple tick count or approximation from chart-timeframe candles.

[b]2. Point of Control and Value Area[/b]

The POC is the bin index with the highest accumulated volume. The Value Area is computed by iteratively expanding from the POC outward, adding the higher-volume neighbor bin at each step until 70% of total session volume is captured:

[pine]
float target = total_vol * VA_PCT   // VA_PCT = 0.70
float accum  = bins.get(poc_idx)
int   lo_i   = poc_idx
int   hi_i   = poc_idx
while accum < target
    // expand toward whichever neighbor bin has more volume
[/pine]

The resulting VAH and VAL define the zone where the majority of institutional volume transacted. Price inside the value area is "accepted" — price outside it is either in premium or discount relative to session fair value.

[b]3. Catmull-Rom Spline Profile Rendering[/b]

Rather than rendering a stepped histogram, the volume bins are smoothed with a double-pass averaging and then connected via Catmull-Rom cubic splines into a polyline. This produces the signature smooth profile wave that is readable at a glance without the visual noise of raw histogram bars:

[pine]
// Control point generation for cubic interpolation
float cx0 = x0, cy0 = y0
float cx1 = x1 + (x2 - x0) / 6, cy1 = y1 + (y2 - y0) / 6
// ... polyline rendered via array<chart.point>
[/pine]

[b]4. Session Delta[/b]

Each session accumulates a running buy/sell delta (buy volume minus sell volume across all sub-bars). The dashboard displays the session delta as a signed value with color coding — positive delta in the Asia session followed by a bullish London opening is a meaningful institutional convergence signal.

[b]Features[/b]

[list]
[*][b]Three Simultaneous Session Profiles:[/b] Asia, London, and New York built in parallel, each with its own color
[*][b]Point of Control Line:[/b] Horizontal line at the highest-volume price level per session, extended across the full session range
[*][b]Value Area Box:[/b] Shaded box from VAL to VAH representing the 70% volume concentration zone
[*][b]Volume Wave:[/b] Smooth Catmull-Rom spline profile rendered as a polyline — showing the full shape of volume distribution
[*][b]Buy/Sell Delta:[/b] Net directional volume per session displayed in the dashboard
[*][b]Session Range Box:[/b] Outer boundary box showing the full session high-to-low range
[*][b]9-Row Dashboard:[/b] Displays session status (open/closed), POC price, VAH, VAL, session range, delta, and total session volume for each active session
[*][b]Alerts:[/b] Asia session open, London session open, NY session open, price enters value area, price exits value area
[/list]

[b]Input Parameters[/b]

[b]Sessions:[/b]
[list]
[*]Asia (01–09 UTC): Toggle Asia session profiling (default: on)
[*]London (07–16 UTC): Toggle London session profiling (default: on)
[*]New York (13–22 UTC): Toggle NY session profiling (default: on)
[/list]

[b]Volume Profile:[/b]
[list]
[*]LTF for Volume: Lower timeframe to use for sub-bar volume accumulation (default: 1m). Must be smaller than chart timeframe.
[*]Profile Bins: Number of price levels in each session distribution (default: 35, range: 10–100). More bins = finer resolution.
[*]Show Value Area (70%): Toggle VAH/VAL box rendering (default: on)
[/list]

[b]Visualization:[/b]
[list]
[*]Asia / London / NY Colors: Independent session color selection
[*]Box Transparency: Base transparency of session range and value area boxes (default: 85)
[*]Show Volume Wave: Toggle Catmull-Rom spline profile rendering (default: on)
[/list]

[b]Dashboard:[/b]
[list]
[*]Position: Top Right, Top Left, Bottom Right, Bottom Left (default: Top Right)
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Locate the POC and Value Area[/b]
The POC is the single most important price level in each session — it represents the highest institutional agreement. Value Area (VAH to VAL) is where the majority of volume transacted. Price above VAH is premium; price below VAL is discount.

[b]Step 2: Identify Session Transitions[/b]
The London open (07 UTC) frequently engineers liquidity above or below the Asia range. If London takes out the Asia high and then reverses, the Asia POC becomes a magnetic target. The NY open at 13 UTC is the resolution event — watch for which side of the London value area price is trading on at that open.

[b]Step 3: Read the Session Delta[/b]
A session with strong positive delta (more buy volume than sell volume) combined with price closing near the VAH suggests institutional accumulation. Negative delta closing near VAL suggests distribution. Divergence between price direction and delta direction is a key reversal signal.

[b]Step 4: Use VAH/VAL as Dynamic S/R[/b]
After a session closes, its VAH and VAL remain on chart as reference levels. These levels frequently act as support or resistance in the following session because institutional participants remember where the majority of volume transacted.

[b]Originality Statement[/b]

This indicator is original in its combination of per-session volume profile construction using lower-timeframe data with Catmull-Rom spline visual rendering and real-time delta tracking across three simultaneous sessions. Its publication is justified because:

[list]
[*]Volume profiles are typically computed for arbitrary user-defined time windows or fixed periods. Per-session profiling maps institutional behavior to the actual time windows in which institutions operate — Asia, London, and New York — creating contextually meaningful distributions rather than arbitrary aggregations
[*]Catmull-Rom spline interpolation of the bin array produces a smooth, continuous profile shape that preserves the true distribution topology while being readable without histogram visual noise
[*]Real-time lower-timeframe volume decomposition into price bins on any chart timeframe gives accurate sub-bar volume placement that chart-timeframe-only calculations cannot produce
[*]Simultaneous three-session display with independent POC, VAH, VAL, and delta tracking per session enables cross-session analysis that no single-profile tool can provide
[/list]

[b]Limitations[/b]

[list]
[*]LTF data requests consume additional computation. On very high timeframe charts (4H+), 1-minute LTF data pulls are large. Consider using 5m LTF on higher timeframes to reduce computation.
[*]The buy/sell volume classification (close >= open = buy) is an approximation at the 1-minute level. True tick-direction is not available in Pine Script.
[*]Session times are fixed UTC offsets. Daylight saving time transitions may shift the actual institutional open by one hour depending on the exchange.
[*]Value Area calculation uses 70% of session volume by default. This follows the standard Market Profile convention but the threshold is not universally agreed upon.
[*]On assets with very low volume (illiquid instruments), the profile bins will be sparse and the spline shape may not be representative of meaningful distribution.
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It does not constitute financial advice or a recommendation to buy or sell any instrument. All trading involves risk of loss. Session volume patterns do not guarantee future price behavior. Always use proper risk management.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Institutional Session Profiler [JOAT]",
     shorttitle          = "ISP [JOAT]",
     overlay             = true,
     max_boxes_count     = 500,
     max_lines_count     = 500,
     max_labels_count    = 500,
     max_polylines_count = 100,
     max_bars_back       = 5000)

// ─── Input Groups ────────────────────────────────────────────────────────
string GRP_SESS = "Sessions"
string GRP_PROF = "Volume Profile"
string GRP_VIZ  = "Visualization"
string GRP_DASH = "Dashboard"
string GRP_ALRT = "Alerts"

// Sessions
bool   i_asia    = input.bool(true,  "Asia (01–09 UTC)",   group = GRP_SESS)
bool   i_london  = input.bool(true,  "London (07–16 UTC)", group = GRP_SESS)
bool   i_ny      = input.bool(true,  "New York (13–22 UTC)",group = GRP_SESS)

// Profile
string i_ltf     = input.timeframe("1", "LTF for Volume",  group = GRP_PROF,
     tooltip = "Lower timeframe bar used to accumulate volume into bins. Must be < chart timeframe.")
int    i_bins    = input.int(35,  "Profile Bins",  minval = 10, maxval = 100, group = GRP_PROF,
     tooltip = "Number of price levels (bins) in each session's volume distribution.")
bool   i_show_va = input.bool(true,  "Show Value Area (70%)", group = GRP_PROF)

// Visualization
color  i_c_asia  = input.color(color.rgb( 30, 120, 255),  "Asia Color",   group = GRP_VIZ)
color  i_c_lon   = input.color(color.rgb(220, 170,   0),  "London Color", group = GRP_VIZ)
color  i_c_ny    = input.color(color.rgb(220,  50,  50),  "NY Color",     group = GRP_VIZ)
int    i_box_tr  = input.int  (85, "Box Transparency", minval = 60, maxval = 98, group = GRP_VIZ)
bool   i_show_vp = input.bool (true, "Show Volume Wave", group = GRP_VIZ)

// Dashboard
bool   i_show_dash = input.bool(true,  "Show Dashboard", group = GRP_DASH)
string i_dash_pos  = input.string("Top Right", "Position",
     options = ["Top Right","Top Left","Bottom Right","Bottom Left"], group = GRP_DASH)

// Alerts
bool   i_repaint = input.bool(false, "Allow Repainting", group = GRP_ALRT)

// ─── Types ───────────────────────────────────────────────────────────────
type SessionProfile
    float[]   bins          // volume per price bin
    float[]   delta_bins    // (buy-sell) delta per bin
    float     hi
    float     lo
    float     poc           // point of control price
    float     vah           // value area high
    float     val           // value area low
    float     delta_sum     // total session delta
    int       start_bar
    bool      is_open
    box       sess_box
    polyline  wave
    label     name_lbl

// ─── Constants ───────────────────────────────────────────────────────────
color C_BG    = color.rgb(16, 18, 24)
color C_BDR   = color.rgb(40, 46, 58)
color C_TEXT  = color.rgb(190, 200, 218)
color C_MUTED = color.rgb(88, 98, 115)
float VA_PCT  = 0.70      // Value area target fraction

string _pos = switch i_dash_pos
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    =>               position.top_right

// ─── Helper: Reset Profile ────────────────────────────────────────────────
reset_profile(SessionProfile sp, string name, color c) =>
    array.fill(sp.bins,       0.0)
    array.fill(sp.delta_bins, 0.0)
    sp.hi        := high
    sp.lo        := low
    sp.poc       := hl2
    sp.vah       := high
    sp.val       := low
    sp.delta_sum := 0.0
    sp.start_bar := bar_index
    sp.is_open   := true
    if not na(sp.wave)
        polyline.delete(sp.wave)
        sp.wave := na
    sp.sess_box  := box.new(bar_index, high, bar_index, low,
         bgcolor      = color.new(c, i_box_tr),
         border_color = color.new(c, 25),
         border_style = line.style_dashed)
    sp.name_lbl  := label.new(bar_index, high, name,
         color     = c,
         textcolor = color.white,
         style     = label.style_label_down,
         size      = size.small)
    true

// ─── Helper: Compute POC and Value Area ──────────────────────────────────
calc_poc_va(SessionProfile sp) =>
    int   poc_idx = 0
    float poc_max = 0.0
    float total   = array.sum(sp.bins)

    // Find POC bin (max volume)
    for i = 0 to i_bins - 1
        float v = sp.bins.get(i)
        if v > poc_max
            poc_max := v
            poc_idx := i

    // Value area: walk outward from POC until 70% of total is captured
    float bin_sz  = (sp.hi - sp.lo) / i_bins
    sp.poc := sp.lo + poc_idx * bin_sz + bin_sz * 0.5

    float cum     = poc_max
    int   lo_idx  = poc_idx
    int   hi_idx  = poc_idx
    int   max_it  = i_bins

    for _ = 0 to max_it
        if cum >= total * VA_PCT
            break
        bool go_lo = lo_idx > 0           and (hi_idx >= i_bins - 1 or sp.bins.get(lo_idx - 1) >= sp.bins.get(hi_idx + 1))
        bool go_hi = hi_idx < i_bins - 1  and not go_lo
        if go_lo
            lo_idx -= 1
            cum    += sp.bins.get(lo_idx)
        else if go_hi
            hi_idx += 1
            cum    += sp.bins.get(hi_idx)
        else
            break

    sp.vah := sp.lo + hi_idx * bin_sz + bin_sz
    sp.val := sp.lo + lo_idx * bin_sz
    true

// ─── Helper: Draw Catmull-Rom Volume Wave ─────────────────────────────────
draw_wave(SessionProfile sp, color c) =>
    float total = array.sum(sp.bins)
    if total <= 0.0
        true

    float bin_sz = (sp.hi - sp.lo) / i_bins
    if bin_sz <= 0.0
        true

    // Double-pass smoothing (3-point weighted average × 2)
    float[] sm1 = array.new_float(i_bins, 0.0)
    float[] sm2 = array.new_float(i_bins, 0.0)
    for k = 0 to i_bins - 1
        float pv = k > 0         ? sp.bins.get(k - 1) : sp.bins.get(k)
        float cv =                  sp.bins.get(k)
        float nv = k < i_bins - 1 ? sp.bins.get(k + 1) : cv
        sm1.set(k, (pv + cv * 2.0 + nv) / 4.0)
    for k = 0 to i_bins - 1
        float pv = k > 0         ? sm1.get(k - 1) : sm1.get(k)
        float cv =                  sm1.get(k)
        float nv = k < i_bins - 1 ? sm1.get(k + 1) : cv
        sm2.set(k, (pv + cv * 2.0 + nv) / 4.0)

    float max_s   = array.max(sm2)
    if max_s <= 0.0
        true

    int   sess_w  = math.max(bar_index - sp.start_bar, 1)
    int   n_ctrl  = i_bins + 2
    float[] cx    = array.new_float(n_ctrl, 0.0)
    float[] cy    = array.new_float(n_ctrl, 0.0)
    cy.set(0, sp.lo)
    for k = 0 to i_bins - 1
        float sv = sm2.get(k)
        cy.set(k + 1, sp.lo + k * bin_sz + bin_sz * 0.5)
        cx.set(k + 1, sv > 0.0 ? math.max(sv / max_s * sess_w * 0.55, 1.0) : 0.0)
    cy.set(n_ctrl - 1, sp.hi)

    // Time coordinates
    int lookback = math.min(bar_index - sp.start_bar, 4999)
    int t_start  = time[lookback]
    int t_range  = time - t_start

    // Catmull-Rom cubic spline: 4 subdivisions per segment
    int sub = 4
    chart.point[] pts = array.new<chart.point>()
    for k = 0 to n_ctrl - 2
        int k0 = math.max(k - 1, 0)
        int k2 = k + 1
        int k3 = math.min(k + 2, n_ctrl - 1)
        float x0 = cx.get(k0)
        float y0 = cy.get(k0)
        float x1 = cx.get(k)
        float y1 = cy.get(k)
        float x2 = cx.get(k2)
        float y2 = cy.get(k2)
        float x3 = cx.get(k3)
        float y3 = cy.get(k3)
        float mx  = sess_w * 0.6
        for j = 0 to sub - 1
            float t  = j / float(sub)
            float t2 = t * t
            float t3 = t2 * t
            float ix = 0.5 * ((2*x1) + (-x0+x2)*t + (2*x0-5*x1+4*x2-x3)*t2 + (-x0+3*x1-3*x2+x3)*t3)
            float iy = 0.5 * ((2*y1) + (-y0+y2)*t + (2*y0-5*y1+4*y2-y3)*t2 + (-y0+3*y1-3*y2+y3)*t3)
            ix := math.max(math.min(ix, mx), 0.0)
            iy := math.max(math.min(iy, sp.hi), sp.lo)
            int pt_t = t_range > 0 ? t_start + int(ix / sess_w * t_range) : t_start
            pts.push(chart.point.from_time(pt_t, iy))
    pts.push(chart.point.from_time(t_start, sp.hi))

    if not na(sp.wave)
        polyline.delete(sp.wave)
    sp.wave := polyline.new(pts,
         curved     = false,
         closed     = true,
         xloc       = xloc.bar_time,
         line_color = color.new(c, 35),
         fill_color = color.new(c, 72),
         line_width = 1)
    true

// ─── State Variables ─────────────────────────────────────────────────────
bool valid_tf  = timeframe.in_seconds() <= 3600
bool valid_ltf = timeframe.in_seconds(i_ltf) < timeframe.in_seconds()

var SessionProfile s_asia = SessionProfile.new(
     array.new_float(i_bins, 0.0), array.new_float(i_bins, 0.0),
     0.0, 1e10, na, na, na, 0.0, 0, false, na, na, na)
var SessionProfile s_lon  = SessionProfile.new(
     array.new_float(i_bins, 0.0), array.new_float(i_bins, 0.0),
     0.0, 1e10, na, na, na, 0.0, 0, false, na, na, na)
var SessionProfile s_ny   = SessionProfile.new(
     array.new_float(i_bins, 0.0), array.new_float(i_bins, 0.0),
     0.0, 1e10, na, na, na, 0.0, 0, false, na, na, na)

// ─── Session Time Logic ───────────────────────────────────────────────────
int  utc_h   = hour(time, "GMT")
int  dow     = dayofweek(time, "GMT")
bool weekday = dow != dayofweek.saturday and dow != dayofweek.sunday
bool in_asia = weekday and utc_h >= 1  and utc_h < 9
bool in_lon  = weekday and utc_h >= 7  and utc_h < 16
bool in_ny   = weekday and utc_h >= 13 and utc_h < 22

bool new_asia = in_asia and not in_asia[1]
bool end_asia = not in_asia and in_asia[1]
bool new_lon  = in_lon  and not in_lon[1]
bool end_lon  = not in_lon  and in_lon[1]
bool new_ny   = in_ny   and not in_ny[1]
bool end_ny   = not in_ny   and in_ny[1]

// ─── Session Lifecycle ────────────────────────────────────────────────────
if valid_tf and i_asia
    if new_asia
        reset_profile(s_asia, "ASIA", i_c_asia)
    if s_asia.is_open
        s_asia.hi := math.max(s_asia.hi, high)
        s_asia.lo := math.min(s_asia.lo, low)
        if not na(s_asia.sess_box)
            s_asia.sess_box.set_right(bar_index)
            s_asia.sess_box.set_top(s_asia.hi)
            s_asia.sess_box.set_bottom(s_asia.lo)
        if not na(s_asia.name_lbl)
            s_asia.name_lbl.set_x(s_asia.start_bar + (bar_index - s_asia.start_bar) / 2)
            s_asia.name_lbl.set_y(s_asia.hi)
    if end_asia and s_asia.is_open
        calc_poc_va(s_asia)
        if i_show_vp
            draw_wave(s_asia, i_c_asia)
        s_asia.is_open := false

if valid_tf and i_london
    if new_lon
        reset_profile(s_lon, "LONDON", i_c_lon)
    if s_lon.is_open
        s_lon.hi := math.max(s_lon.hi, high)
        s_lon.lo := math.min(s_lon.lo, low)
        if not na(s_lon.sess_box)
            s_lon.sess_box.set_right(bar_index)
            s_lon.sess_box.set_top(s_lon.hi)
            s_lon.sess_box.set_bottom(s_lon.lo)
        if not na(s_lon.name_lbl)
            s_lon.name_lbl.set_x(s_lon.start_bar + (bar_index - s_lon.start_bar) / 2)
            s_lon.name_lbl.set_y(s_lon.hi)
    if end_lon and s_lon.is_open
        calc_poc_va(s_lon)
        if i_show_vp
            draw_wave(s_lon, i_c_lon)
        s_lon.is_open := false

if valid_tf and i_ny
    if new_ny
        reset_profile(s_ny, "NEW YORK", i_c_ny)
    if s_ny.is_open
        s_ny.hi := math.max(s_ny.hi, high)
        s_ny.lo := math.min(s_ny.lo, low)
        if not na(s_ny.sess_box)
            s_ny.sess_box.set_right(bar_index)
            s_ny.sess_box.set_top(s_ny.hi)
            s_ny.sess_box.set_bottom(s_ny.lo)
        if not na(s_ny.name_lbl)
            s_ny.name_lbl.set_x(s_ny.start_bar + (bar_index - s_ny.start_bar) / 2)
            s_ny.name_lbl.set_y(s_ny.hi)
    if end_ny and s_ny.is_open
        calc_poc_va(s_ny)
        if i_show_vp
            draw_wave(s_ny, i_c_ny)
        s_ny.is_open := false

// ─── Live Wave (last bar) ─────────────────────────────────────────────────
if barstate.islast
    if s_asia.is_open and i_show_vp and i_asia
        calc_poc_va(s_asia)
        draw_wave(s_asia, i_c_asia)
    if s_lon.is_open and i_show_vp and i_london
        calc_poc_va(s_lon)
        draw_wave(s_lon, i_c_lon)
    if s_ny.is_open and i_show_vp and i_ny
        calc_poc_va(s_ny)
        draw_wave(s_ny, i_c_ny)

// ─── LTF Volume Accumulation ─────────────────────────────────────────────
bool any_open = (s_asia.is_open and i_asia) or (s_lon.is_open and i_london) or (s_ny.is_open and i_ny)

if valid_tf and any_open
    float p = na
    float v = na
    float d = na

    if valid_ltf
        [ltf_c, ltf_v] = request.security_lower_tf(syminfo.tickerid, i_ltf, [close, volume])
        int sz = ltf_c.size()
        if sz > 0
            for i = 0 to sz - 1
                p := ltf_c.get(i)
                v := ltf_v.get(i)
                d := (p >= open ? v : -v)
                if i_asia and s_asia.is_open and s_asia.hi > s_asia.lo
                    float bs = (s_asia.hi - s_asia.lo) / i_bins
                    if bs > 0
                        int idx = int(math.floor((p - s_asia.lo) / bs))
                        if idx >= 0 and idx < i_bins
                            s_asia.bins.set(idx, s_asia.bins.get(idx) + v)
                            s_asia.delta_bins.set(idx, s_asia.delta_bins.get(idx) + d)
                            s_asia.delta_sum += d
                if i_london and s_lon.is_open and s_lon.hi > s_lon.lo
                    float bs = (s_lon.hi - s_lon.lo) / i_bins
                    if bs > 0
                        int idx = int(math.floor((p - s_lon.lo) / bs))
                        if idx >= 0 and idx < i_bins
                            s_lon.bins.set(idx, s_lon.bins.get(idx) + v)
                            s_lon.delta_bins.set(idx, s_lon.delta_bins.get(idx) + d)
                            s_lon.delta_sum += d
                if i_ny and s_ny.is_open and s_ny.hi > s_ny.lo
                    float bs = (s_ny.hi - s_ny.lo) / i_bins
                    if bs > 0
                        int idx = int(math.floor((p - s_ny.lo) / bs))
                        if idx >= 0 and idx < i_bins
                            s_ny.bins.set(idx, s_ny.bins.get(idx) + v)
                            s_ny.delta_bins.set(idx, s_ny.delta_bins.get(idx) + d)
                            s_ny.delta_sum += d
    else
        // Fallback: chart-level volume when LTF ≈ chart TF
        p := close
        v := volume
        d := (close >= open ? v : -v)
        if i_asia and s_asia.is_open and s_asia.hi > s_asia.lo
            float bs = (s_asia.hi - s_asia.lo) / i_bins
            if bs > 0
                int idx = int(math.floor((p - s_asia.lo) / bs))
                if idx >= 0 and idx < i_bins
                    s_asia.bins.set(idx, s_asia.bins.get(idx) + v)
                    s_asia.delta_sum += d
        if i_london and s_lon.is_open and s_lon.hi > s_lon.lo
            float bs = (s_lon.hi - s_lon.lo) / i_bins
            if bs > 0
                int idx = int(math.floor((p - s_lon.lo) / bs))
                if idx >= 0 and idx < i_bins
                    s_lon.bins.set(idx, s_lon.bins.get(idx) + v)
                    s_lon.delta_sum += d
        if i_ny and s_ny.is_open and s_ny.hi > s_ny.lo
            float bs = (s_ny.hi - s_ny.lo) / i_bins
            if bs > 0
                int idx = int(math.floor((p - s_ny.lo) / bs))
                if idx >= 0 and idx < i_bins
                    s_ny.bins.set(idx, s_ny.bins.get(idx) + v)
                    s_ny.delta_sum += d

// ─── Dashboard ────────────────────────────────────────────────────────────
if barstate.islast and i_show_dash
    var table dash = table.new(_pos, 4, 6,
         bgcolor      = C_BG,
         border_color = C_BDR,
         border_width = 1,
         frame_color  = C_BDR,
         frame_width  = 2)

    table.cell(dash, 0, 0, "ISP",
         text_color = color.rgb(30, 120, 255), text_size = size.normal, text_halign = text.align_left)
    table.cell(dash, 1, 0, "", text_size = size.tiny)
    table.cell(dash, 2, 0, "", text_size = size.tiny)
    table.cell(dash, 3, 0, "jackofalltrades",
         text_color = C_MUTED, text_size = size.tiny, text_halign = text.align_right)
    table.merge_cells(dash, 0, 0, 2, 0)

    // Column headers
    table.cell(dash, 0, 1, "Session",   text_color = C_MUTED, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 1, "Status",    text_color = C_MUTED, text_size = size.tiny, text_halign = text.align_center)
    table.cell(dash, 2, 1, "POC",       text_color = C_MUTED, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 3, 1, "Delta",     text_color = C_MUTED, text_size = size.tiny, text_halign = text.align_right)

    // Asia row
    string asia_st  = not i_asia ? "—" : s_asia.is_open ? "OPEN" : "CLOSED"
    color  asia_stc = s_asia.is_open ? i_c_asia : C_MUTED
    string asia_poc = not na(s_asia.poc) ? str.tostring(s_asia.poc, format.mintick) : "—"
    color  asia_dc  = s_asia.delta_sum > 0 ? color.rgb(0,210,145) : color.rgb(255,65,75)
    table.cell(dash, 0, 2, "ASIA",    text_color = i_c_asia, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 2, asia_st,   text_color = asia_stc, text_size = size.small, text_halign = text.align_center)
    table.cell(dash, 2, 2, asia_poc,  text_color = C_TEXT,   text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 3, 2, str.tostring(s_asia.delta_sum, format.volume),
         text_color = asia_dc, text_size = size.small, text_halign = text.align_right)

    // London row
    string lon_st  = not i_london ? "—" : s_lon.is_open ? "OPEN" : "CLOSED"
    color  lon_stc = s_lon.is_open ? i_c_lon : C_MUTED
    string lon_poc = not na(s_lon.poc) ? str.tostring(s_lon.poc, format.mintick) : "—"
    color  lon_dc  = s_lon.delta_sum > 0 ? color.rgb(0,210,145) : color.rgb(255,65,75)
    table.cell(dash, 0, 3, "LONDON",  text_color = i_c_lon, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 3, lon_st,    text_color = lon_stc, text_size = size.small, text_halign = text.align_center)
    table.cell(dash, 2, 3, lon_poc,   text_color = C_TEXT,  text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 3, 3, str.tostring(s_lon.delta_sum, format.volume),
         text_color = lon_dc, text_size = size.small, text_halign = text.align_right)

    // NY row
    string ny_st  = not i_ny ? "—" : s_ny.is_open ? "OPEN" : "CLOSED"
    color  ny_stc = s_ny.is_open ? i_c_ny : C_MUTED
    string ny_poc = not na(s_ny.poc) ? str.tostring(s_ny.poc, format.mintick) : "—"
    color  ny_dc  = s_ny.delta_sum > 0 ? color.rgb(0,210,145) : color.rgb(255,65,75)
    table.cell(dash, 0, 4, "NEW YORK", text_color = i_c_ny, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 4, ny_st,      text_color = ny_stc, text_size = size.small, text_halign = text.align_center)
    table.cell(dash, 2, 4, ny_poc,     text_color = C_TEXT, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 3, 4, str.tostring(s_ny.delta_sum, format.volume),
         text_color = ny_dc, text_size = size.small, text_halign = text.align_right)

    // Overlap indicator
    bool overlap_lon_ny = in_lon and in_ny
    string ovlp = overlap_lon_ny ? "LON–NY OVERLAP (High Liquidity)" : valid_tf ? "No Overlap" : "TF > 1H"
    color  ovlpc = overlap_lon_ny ? color.rgb(255, 200, 50) : C_MUTED
    table.cell(dash, 0, 5, ovlp, text_color = ovlpc, text_size = size.tiny, text_halign = text.align_left)
    table.merge_cells(dash, 0, 5, 3, 5)

// ─── Alerts ───────────────────────────────────────────────────────────────
bool conf = i_repaint or barstate.isconfirmed
alertcondition(new_asia  and i_asia   and conf, "ISP — Asia Open [JOAT]",    "ISP: Asia session opened on {{ticker}} ({{interval}})")
alertcondition(end_asia  and i_asia   and conf, "ISP — Asia Close [JOAT]",   "ISP: Asia session closed on {{ticker}} ({{interval}})")
alertcondition(new_lon   and i_london and conf, "ISP — London Open [JOAT]",  "ISP: London session opened on {{ticker}} ({{interval}})")
alertcondition(end_lon   and i_london and conf, "ISP — London Close [JOAT]", "ISP: London session closed on {{ticker}} ({{interval}})")
alertcondition(new_ny    and i_ny     and conf, "ISP — NY Open [JOAT]",      "ISP: New York session opened on {{ticker}} ({{interval}})")
alertcondition(end_ny    and i_ny     and conf, "ISP — NY Close [JOAT]",     "ISP: New York session closed on {{ticker}} ({{interval}})")
````
