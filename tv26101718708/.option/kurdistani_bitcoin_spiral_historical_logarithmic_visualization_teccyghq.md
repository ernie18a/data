# Kurdistani Bitcoin Spiral - Historical Logarithmic Visualization

- url: https://www.tradingview.com/script/tECCygHQ-Kurdistani-Bitcoin-Spiral-Historical-Logarithmic-Visualization/
- type: indicator
- pine_id: PUB;814c1e47aeb94f6c99b32b5f286a1346
- version: 1.0

## Description

Kurdistani Bitcoin Spiral — Live Historical Logarithmic Visualization

Overview

Bitcoin Spiral is an interactive visualization of Bitcoin's complete historical price evolution, displayed as a logarithmic spiral.

Each calendar year corresponds to one full revolution around the center, while the distance from the center represents price on a logarithmic (log10) scale. This allows more than sixteen years of Bitcoin history to be explored within a single, compact chart.

Although logarithmic spiral representations of Bitcoin have appeared as static illustrations for years, this indicator brings the concept to TradingView as a fully interactive Pine Script implementation with live updates, configurable visualization layers, and efficient rendering.

This indicator is intended for historical exploration, education, and visual analysis. It is **not** a forecasting model, does **not** predict future prices, and does **not** generate buy or sell signals.

---

Features

• Complete Bitcoin history from the 2009 Genesis Block through the present in a single spiral.

• Historical Halving events displayed as ring-and-dot markers.

• Major cycle bottoms highlighted with diamond markers.

• Historical All-Time Highs shown as comet-style trails that illustrate each rally into its peak.

• Live **Now** marker using `request.security()` with a user-selectable data source (default: Bitstamp:BTCUSD).

• Optional real-time continuation connecting the curated historical backbone to the latest market price.

• Current calendar year highlighted with an eased radial gradient wedge.

• Logarithmic price grid from **$1** to **$1M**.

• Eight year spokes with four emphasized calendar axes.

• Fully configurable colors, visibility, density, line widths, glow effects, and background.

• Compact legend matching the actual marker shapes used on the chart.

---

How It Works

The indicator is generated from a manually curated historical backbone consisting of approximately one hundred reference keyframes.

Each keyframe stores an approximate historical time and price.

For any intermediate date, price is calculated using logarithmic interpolation between the two nearest keyframes. The lookup uses binary search over the sorted keyframe table, providing efficient O(log n) performance.

Each *(time, price)* pair is converted into polar coordinates:

* **Angle** represents the position within the calendar year.
* **Radius** represents the logarithm of price.

The resulting coordinates are transformed into TradingView chart coordinates using `polyline.new()`, `line.new()`, and `label.new()`.

When the historical backbone ends, an optional live continuation extends the visualization using the latest available daily close from the selected market symbol.

For performance reasons, the historical visualization is rendered only once. During realtime updates, only the live marker, live continuation, and (if applicable) a new live ATH marker are updated.

---

Curated Data vs Live Data

### Curated Historical Data

The following elements are manually maintained and remain fixed until the script is updated:

* Historical spiral
* Halving markers
* Major cycle bottoms
* Historical ATH markers
* ATH run-up trails

These elements are derived from the embedded historical keyframe dataset.

### Live Data

Only the following components update with incoming market data:

* Live "Now" marker
* Optional live continuation
* Live ATH marker (when price exceeds the latest curated ATH)

No historical data is modified or overwritten.

---

Reading the Spiral

The spiral is designed to emphasize Bitcoin's long-term structure rather than day-to-day price fluctuations.

* Angle indicates where a point falls within its calendar year.
* Radius represents price on a logarithmic scale.
* Equal radial spacing represents equal percentage changes rather than equal dollar changes.
* The highlighted wedge identifies the current calendar year.
* ATH comet trails visualize the acceleration leading into historical market peaks.

The chart is intended to help explore long-term market structure, historical cycles, and price evolution—not to predict future market behavior.

---

Engineering Notes

Version 5 focuses primarily on architecture, performance, and maintainability.

Key improvements include:

* Binary-search price lookup replacing linear scans.
* Unified marker rendering through a single reusable function.
* Centralized logarithmic radius mapping.
* Improved eased radial gradient for the current-year wedge.
* More maintainable rendering architecture for both static and live objects.

The historical dataset currently remains embedded inside the script.

The preferred long-term architecture is to publish the dataset as a separate Pine Library and import it into the indicator. The current implementation is already organized so that such a migration would require changes only within the data section.

---

Current Pine Script Limitations

Some visual behaviors are limited by the current Pine Script rendering engine rather than by the indicator itself.

These include:

* Perfect zoom-independent circular geometry is not possible because the horizontal axis is based on bar indices while the vertical axis represents price values.

* Pine Script does not provide access to viewport dimensions, zoom level, or aspect ratio, preventing automatic geometric correction.

* No visible-range API exists for dynamic label placement or clipping.

* Objects using `xloc.bar_index` cannot be positioned more than approximately 500 bars into the future, limiting outward label placement.

These are platform limitations rather than implementation limitations.

---

Future Development

Possible future improvements include:

* Migrating the historical dataset into a dedicated Pine Library.

* Extending the curated historical backbone as Bitcoin continues to evolve.

* Automatic cycle-bottom detection if a reliable forward-looking methodology becomes available.

* Additional structural refinements as Pine Script evolves.

---

Usage

Every visual layer can be enabled or disabled independently, including:

* Grid
* Year spokes
* Current-year wedge
* ATH markers
* Bottom markers
* Halvings
* Legend
* Background
* Glow effects

Colors, line widths, density, and the live data source are fully configurable.

---

Disclaimer

This indicator visualizes Bitcoin's historical price evolution using a logarithmic spiral coordinate system.

It is intended solely for visualization, historical exploration, and educational purposes.

It does **not** predict future prices, does **not** imply future cycle repetition, and should **not** be used as the sole basis for investment or trading decisions.

Past market behavior, including historical cycle geometry, is **not** indicative of future results.

## Source Code

````pine
//@version=6
// =====================================================================
// Bitcoin Spiral (OSCILLATOR VERSION) -- v5: engineering pass on v4
//
// WHAT CHANGED FROM v4 (this round is architecture/code-quality, not
// visuals -- the one visual tweak is the wedge easing, item 6):
//
//   1) f_price() now binary-searches the sorted kfT table instead of
//      scanning it linearly. With ~2600 spiral points each doing a
//      lookup against a 106-entry table, this was the hottest function
//      in the script; it's now O(log n) instead of O(n).
//   2) LOG_MIN/LOG_MAX/R_MIN/R_MAX were duplicated inside both
//      f_radius() and f_gridRadius(). They're now single globals, and
//      both functions call a shared f_logToRadius() helper.
//   3) Added f_pointMarker(): one routine that either creates a new
//      label (pass `existing = na`) or moves/restyles an existing one
//      in place (pass a real label reference). Static drawing and live
//      updates used to be two different "rendering languages" -- static
//      ATH/Bottom used bare label.new(), live Now/ATH used their own
//      set_xy/set_color/set_size chains. Everything (static ATH trail,
//      static Bottom, static Halving's ring+dot via f_ringDot, live Now
//      ring+triangle, live new-ATH marker) now goes through this one
//      function.
//   4) The historical backbone (kfT/kfP/ATH/Bottom/Halving arrays) is
//      still embedded in this file -- see the comment directly above
//      the data block for why the real fix (a separately published
//      Pine library, imported with `import`) can't be done from here,
//      and what was done instead to keep the door open for it.
//   5) f_ringDot is now built on top of f_pointMarker rather than its
//      own pair of label.new() calls.
//   6) Wedge gradient bands now use eased spacing (packed tighter near
//      center, spread out toward the edge) instead of equal 10% steps,
//      since gradient smoothness is perceived logarithmically, not
//      linearly.
//   7) (v5 patch) Current-year wedge edge label (e.g. "2026") is now
//      shifted 35 bar-index units to the right so it doesn't overlap
//      the wedge edge / next-year label. Only this label's x is
//      changed; the next-year label (e2) is untouched.
//
// EXPLICITLY NOT DONE:
//   - The historical dataset was not moved out of this file. Doing that
//     properly means publishing a companion Pine library under your own
//     TradingView account and importing it -- see the note above the
//     data block. Restructuring the arrays in-place (e.g. one array of
//     structs instead of five parallel arrays) was also skipped: Pine
//     v6 doesn't have user-defined types available at this indicator's
//     complexity budget without a bigger rewrite, and parallel arrays
//     indexed consistently (which they are) don't actually cause bugs,
//     just some readability cost.
//   - No hover-triggered radial highlight (Pine has no hover execution).
//   - Angle is still calendar-based, no aspect-ratio auto-correction,
//     wedge-edge labels still horizontal, coordinate system is still
//     bar-index based (not a normalized/viewport-relative system, which
//     Pine doesn't expose enough viewport data to build properly) --
//     all real Pine limitations carried over from v2/v3/v4.
//
// KNOWN PINE SCRIPT LIMITATIONS (short summary -- full explanation is in
// the publication description, not repeated here):
//   - Pine has no viewport/zoom/pixel-size API, so a perfectly circular
//     spiral independent of chart zoom/aspect ratio is not achievable;
//     the horizontal axis is bar-based while the vertical axis is
//     value-based.
//   - There is no dynamic, visible-range-aware clipping or label
//     placement, since Pine cannot query which part of the chart is
//     currently on screen.
//   - This indicator visualizes historical Bitcoin price evolution in a
//     logarithmic spiral coordinate system for visualization, historical
//     exploration and educational purposes -- it does not forecast
//     future prices.
// =====================================================================
indicator("Kurdistani Bitcoin Spiral - Historical Logarithmic Visualization", shorttitle="Kurdistani Bitcoin Spiral", overlay = false,
     max_lines_count = 500, max_labels_count = 500,
     max_polylines_count = 40, max_boxes_count = 50)

// ---------------------------- INPUTS --------------------------------
grpData    = "Live Data"
i_useLive     = input.bool(true, "Extend past backbone with live data", group = grpData)
i_liveSymbol  = input.symbol("Bitstamp:BTCUSD", "Live BTC source", group = grpData)
i_showLiveExt = input.bool(true, "Show dashed live-extension line", group = grpData)

grpShow = "Show / Hide"
i_showATH     = input.bool(true, "Show ATH markers",      group = grpShow)
i_showBottom  = input.bool(true, "Show Bottom markers",   group = grpShow)
i_showHalving = input.bool(true, "Show Halving markers",  group = grpShow)
i_showGrid    = input.bool(true, "Show grid circles",     group = grpShow)
i_showSpokes  = input.bool(true, "Show year spokes",      group = grpShow)
i_showWedge   = input.bool(true, "Show current-year wedge", group = grpShow)
i_showLegend  = input.bool(true, "Show legend",           group = grpShow)
i_showNow     = input.bool(true, "Show Now marker",       group = grpShow)
i_showCenter  = input.bool(true, "Show genesis center mark", group = grpShow)

grpTheme = "Theme"
i_lightBg  = input.bool(true, "Fill pane background (bgcolor)", group = grpTheme)
i_bgColor  = input.color(#07111B, "Background color", group = grpTheme)

grpStyle = "Style"
i_colSpiral    = input.color(#F5A83C, "Spiral color",     group = grpStyle)
i_colHighlight = input.color(#FFE9A8, "Spiral highlight color (top layer)", group = grpStyle)
i_colATH       = input.color(#2E5BFF, "ATH color",        group = grpStyle)
i_colBottom    = input.color(#DC143C, "Bottom color",     group = grpStyle)
i_colHalving   = input.color(#79C58F, "Halving color",    group = grpStyle)
i_colNow       = input.color(#F7931A, "Now color",        group = grpStyle)
i_colGrid      = input.color(color.new(color.gray, 86),   "Grid color", group = grpStyle)
i_colAxis      = input.color(color.new(color.black, 65),  "Axis/spoke color", group = grpStyle)
i_colText      = input.color(color.new(color.black, 15),  "Label text color", group = grpStyle)
i_lineWidth    = input.int(2, "Spiral line width", minval = 1, maxval = 10, group = grpStyle)
i_spiralGlow   = input.bool(true, "Soft glow under spiral (3-layer trick)", group = grpStyle)

grpPerf = "Performance"
i_density      = input.int(150, "Spiral points per year (higher = smoother, slower)", minval = 30, maxval = 400, group = grpPerf)
i_athTrailStep = input.int(24, "ATH run-up dots per peak", minval = 4, maxval = 48, group = grpPerf)

// ---------------------- keyframe price history (curated backbone) ----
// NOTE on "separate data from rendering": the actual correct fix for
// this in Pine is to move kfT/kfP/athPeak*/bt*/hv* into a separate Pine
// Script *library* (a script published with `library()` instead of
// `indicator()`, exposing exported arrays/functions) and `import` it
// here by its published path (e.g. `import yourhandle/BTCSpiralData/1
// as data`). That's the real "extend to 2027 without editing source"
// answer, and it's how the Pine ecosystem is meant to solve this.
// It isn't done in this file because publishing a library requires the
// script to live under your own TradingView account -- that's not
// something that can be done from here. The arrays stay inline below,
// but every read still goes through f_price()/array.get() rather than
// being hardcoded elsewhere, so swapping this block for a `data.`
// import later only touches this section.
//
// Historical keyframes below (kfT/kfP and the ATH/Bottom/Halving
// arrays) are manually curated reference points used as anchors for
// smooth logarithmic interpolation between them (see f_price()). They
// are not downloaded or fetched automatically from TradingView or any
// live feed -- only the "Now" marker and the live-extension segment
// (see the Live Data section further down) use request.security().
var float[] kfT = array.from(
 2009.00,2009.83,2010.00,2010.40,2010.70,2010.92,2011.10,2011.40,2011.50,2011.75,
 2011.92,2012.30,2012.60,2012.91,2013.00,2013.25,2013.33,2013.50,2013.83,2013.93,
 2014.10,2014.30,2014.60,2014.92,2015.04,2015.30,2015.60,2015.92,2016.30,2016.52,
 2016.75,2016.92,2017.20,2017.40,2017.60,2017.75,2017.85,2017.92,2017.96,2018.05,
 2018.20,2018.40,2018.60,2018.83,2018.95,2019.10,2019.30,2019.50,2019.55,2019.75,
 2019.92,2020.10,2020.20,2020.35,2020.60,2020.75,2020.85,2020.95,2021.00,2021.15,
 2021.28,2021.40,2021.50,2021.55,2021.75,2021.85,2021.87,2022.00,2022.15,2022.30,
 2022.45,2022.55,2022.70,2022.83,2022.87,2023.00,2023.20,2023.40,2023.60,2023.80,
 2023.95,2024.03,2024.20,2024.22,2024.30,2024.50,2024.60,2024.75,2024.85,2024.95,
 2024.97,2025.05,2025.15,2025.30,2025.40,2025.50,2025.60,2025.76,2025.85,2025.92,
 2026.00,2026.10,2026.20,2026.30,2026.40,2026.52)

var float[] kfP = array.from(
 0.0008,0.0008,0.003,0.0025,0.05,0.30,1.0,30.0,17.0,5.0,
 2.0,5.0,8.0,12.0,13.0,230.0,70.0,110.0,900.0,1150.0,
 800.0,450.0,600.0,320.0,170.0,240.0,230.0,430.0,420.0,650.0,
 600.0,750.0,1000.0,1800.0,2800.0,4300.0,7000.0,17000.0,19700.0,13500.0,
 8000.0,8300.0,6500.0,6300.0,3200.0,3600.0,5000.0,10500.0,13000.0,8000.0,
 7200.0,8600.0,3800.0,9000.0,9200.0,10800.0,13800.0,19000.0,29000.0,48000.0,
 64000.0,57000.0,35000.0,29000.0,47000.0,61000.0,69000.0,46000.0,42000.0,39000.0,
 30000.0,17600.0,20000.0,19000.0,15600.0,16500.0,23000.0,28000.0,26000.0,34000.0,
 42000.0,46000.0,52000.0,73000.0,64000.0,61000.0,58000.0,63000.0,68000.0,100000.0,
 108000.0,95000.0,97000.0,84000.0,94000.0,122000.0,115000.0,126210.0,100000.0,87000.0,
 92000.0,80000.0,76000.0,68000.0,64000.0,63000.0)

// curated ATH / Bottom / Halving keyframes (top-level so both the
// one-time static block AND the per-tick live block can read them)
var float[] athPeakT  = array.from(2013.93, 2017.96, 2021.87, 2024.97, 2025.76)
var float[] athPeakP  = array.from(1150.0, 19700.0, 69000.0, 108000.0, 126210.0)
var float[] athStartT = array.from(2013.83, 2017.85, 2021.78, 2024.90, 2025.66)
var string[] athLbl   = array.from("ATH - Dec 2013 (~$1,150)","ATH - Dec 17 2017 (~$19,700)",
     "ATH - Nov 2021 (~$69,000)","ATH - Dec 2024 (~$108,000)","ATH - Oct 6 2025 (~$126,210)")

var float[] btT   = array.from(2011.92, 2015.04, 2018.95, 2022.87)
var float[] btP   = array.from(2.0, 170.0, 3200.0, 15600.0)
var string[] btLbl = array.from("Bottom - Nov 2011 (~$2)","Bottom - Jan 2015 (~$170)",
     "Bottom - Dec 2018 (~$3,200)","Bottom - Nov 2022 FTX (~$15,600)")

var float[] hvT   = array.from(2012.91, 2016.52, 2020.35, 2024.30)
var float[] hvP   = array.from(12.0, 650.0, 9000.0, 64000.0)
var string[] hvLbl = array.from("Halving #1 - Nov 2012","Halving #2 - Jul 2016",
     "Halving #3 - May 2020","Halving #4 - Apr 2024")

var float[] decLogs = array.from(0.0,1.0,2.0,3.0,4.0,5.0,6.0)
var string[] decLbl = array.from("$1","$10","$100","$1000","$10k","$100k","$1M")
var string[] axisLbl = array.from("2009, '13, '17, '21, '25","2010, '14, '18, '22, '26",
     "2011, '15, '19, '23, '27","2012, '16, '20, '24, '28")

// interpolation & polar math. kfT is sorted ascending, so f_price uses
// binary search (O(log n)) instead of a linear scan -- with ~2600
// spiral points each doing a lookup against a 106-entry table, the old
// linear version was the hottest function in the script by a wide
// margin.
f_price(float t) =>
    n = array.size(kfT)
    float result = na
    if t <= array.get(kfT, 0)
        result := array.get(kfP, 0)
    else if t >= array.get(kfT, n - 1)
        result := array.get(kfP, n - 1)
    else
        int lo = 0
        int hi = n - 1
        while hi - lo > 1
            mid = math.floor((lo + hi) / 2.0)
            if array.get(kfT, int(mid)) <= t
                lo := int(mid)
            else
                hi := int(mid)
        float t0 = array.get(kfT, lo)
        float t1 = array.get(kfT, hi)
        float p0 = array.get(kfP, lo)
        float p1 = array.get(kfP, hi)
        float f  = (t - t0) / (t1 - t0)
        float l0 = math.log10(p0)
        float l1 = math.log10(p1)
        result := math.pow(10.0, l0 + (l1 - l0) * f)
    result

// angle is deliberately still calendar-based -- see header note on why
// block-height would misalign the (calendar-year) grid, not fix it.
f_angle(float t) =>
    cyc = ((t - 2009.0) % 4.0 + 4.0) % 4.0
    (cyc / 4.0) * 2.0 * math.pi

// centralized instead of repeated inside both f_radius and f_gridRadius
// -- one place to tune the log-price-to-pixel-radius mapping.
float LOG_MIN = -3.1
float LOG_MAX = 6.15
float R_MIN   = 18.0
float R_MAX   = 400.0

f_logToRadius(float l) =>
    R_MIN + (l - LOG_MIN) / (LOG_MAX - LOG_MIN) * (R_MAX - R_MIN)

f_radius(float p) =>
    l = math.max(LOG_MIN, math.min(LOG_MAX, math.log10(p)))
    f_logToRadius(l)

f_gridRadius(float decLog) =>
    f_logToRadius(decLog)

f_xy(float t, float p, int cIdx, float cY) =>
    a = f_angle(t)
    r = f_radius(p)
    idx = cIdx + int(math.round(r * math.sin(a)))
    yv  = cY + r * math.cos(a)
    [idx, yv]

// clamps a bar-index OFFSET (not an absolute index) so centerIdx + offset can
// never land more than 490 bars into the future -- xloc.bar_index objects
// error out past +500, so this keeps a small safety margin.
f_clampOff(float off) =>
    math.max(-490.0, math.min(490.0, off))

// The one routine all markers go through, static or live. Pass `na` for
// `existing` to create a new label (what the one-time static block
// does); pass a real label reference to move/restyle it in place
// instead of creating a new object (what the live-update block does).
// This directly replaces the old split where static ATH/Bottom used
// bare label.new() while live Now/ATH used their own set_xy/set_color
// calls -- one shape, one place that draws it.
f_pointMarker(label existing, int x, float y, string mStyle, color mColor, string mSize, string tt) =>
    label lbl = na
    if na(existing)
        lbl := label.new(x, y, "", xloc = xloc.bar_index, style = mStyle,
             color = mColor, size = mSize, tooltip = tt)
    else
        label.set_xy(existing, x, y)
        label.set_style(existing, mStyle)
        label.set_color(existing, mColor)
        label.set_size(existing, mSize)
        label.set_tooltip(existing, tt)
        lbl := existing
    lbl

// Ring + inner dot marker, drawn as two stacked f_pointMarker calls --
// currently used by Halving (one-time, so always created fresh).
f_ringDot(int x, float y, string ringStyle, color ringCol, string tt) =>
    f_pointMarker(na, x, y, ringStyle, color.new(ringCol, 55), size.normal, tt)
    f_pointMarker(na, x, y, label.style_circle, ringCol, size.tiny, tt)

// R_OUTER (outer ring / spokes / wedge radius) evaluates to ~435 with the
// constants below (f_gridRadius(7.0)), which is BIGGER than the old fixed
// anchor of +-400. That means the anchor was never actually the limiting
// factor -- the drawn content itself set the pane scale with no margin,
// which is the real cause of the "spiral fills the whole pane, no white
// space" look. Anchor is now derived from the true outer radius + margin.
float R_OUTER_calc = f_gridRadius(7.0)
// The farthest thing actually drawn is the wedge edge year label at
// R_OUTER*1.20; 1.28 leaves just enough margin for that label's own
// text width without the ~45% of dead space the old 1.45 left behind.
float ANCHOR_RANGE = R_OUTER_calc * 1.28

// ---- invisible anchor plots: lock the pane's auto-scale to the
// spiral's own coordinate space (fixed at 0) regardless of symbol, with
// deliberate margin so the spiral doesn't touch the pane edges ----
plot(0.0, title = "Spiral Center Anchor", color = na, editable = false)
plot(ANCHOR_RANGE, title = "Spiral Range Top", color = na, editable = false, display = display.none)
plot(-ANCHOR_RANGE, title = "Spiral Range Bottom", color = na, editable = false, display = display.none)
bgcolor(i_lightBg ? i_bgColor : na, title = "Pane background")

const float START        = 2009.00
const float BACKBONE_END = 2026.52   // where the curated backbone stops

// ---------------------- live data (top-level, unconditional call) ----
// Live prices extend only the final segment of the visualization (the
// "Now" marker and the dashed/dotted live-extension line). The curated
// historical backbone above (kfT/kfP, ATH/Bottom/Halving) remains
// unchanged and is never overwritten by live data.
float liveClose        = request.security(i_liveSymbol, "D", close, lookahead = barmerge.lookahead_off)
float liveTimeCloseRaw = request.security(i_liveSymbol, "D", time_close, lookahead = barmerge.lookahead_off)
// request.security() returns time_close as "series float", but
// year()/month()/dayofmonth() require "series int" -- cast explicitly.
// int() of an na float propagates to na int, so no ternary needed.
int liveTimeClose = int(liveTimeCloseRaw)

bool useLiveNow = i_useLive and not na(liveClose) and not na(liveTimeClose)

float backboneLastT = array.get(kfT, array.size(kfT) - 1)
float backboneLastP = array.get(kfP, array.size(kfP) - 1)

// dynamic "now" -- replaces the old hardcoded END = 2026.52
float nowYear  = useLiveNow ? (year(liveTimeClose) + (month(liveTimeClose) - 1) / 12.0 + (dayofmonth(liveTimeClose) - 1) / 365.0) : backboneLastT
float nowPrice = useLiveNow ? liveClose : backboneLastP

// ---------------------- ONE-TIME static drawing -----------------------
var bool drawn      = false
var int   g_centerIdx = na
var float g_centerY   = 0.0
var float[] g_gridR   = array.new<float>()

if barstate.islast and not drawn
    g_centerIdx := bar_index
    g_centerY   := 0.0
    centerIdx = g_centerIdx
    centerY   = g_centerY

    R_OUTER = f_gridRadius(7.0)

    // current-year wedge -- full calendar year containing 'nowYear'.
    // Pine has no gradient fill, so the "faint near center, more solid at
    // the edge" look from the reference is faked with 4 stacked annular
    // bands at increasing opacity (decreasing transparency) outward.
    if i_showWedge
        yearStart = math.floor(nowYear)
        // Eased spacing instead of linear 10/20/30...100 -- the eye
        // perceives a gradient's smoothness logarithmically, so bands
        // are packed tighter near the center and spread out toward the
        // edge, which reads as smoother than equal steps do.
        var float[] bandFrac  = array.from(0.02, 0.05, 0.09, 0.15, 0.23, 0.34, 0.48, 0.65, 0.84, 1.00)
        var int[]   bandTrans = array.from(98, 97, 96, 95, 94, 93, 92, 91, 90, 89)
        float rPrev = 0.0
        for bIdx = 0 to array.size(bandFrac) - 1
            rBandOuter = R_OUTER * array.get(bandFrac, bIdx)
            bandColor  = color.new(i_colNow, array.get(bandTrans, bIdx))
            array<chart.point> bandPts = array.new<chart.point>()
            for k = 0 to 24
                tt = yearStart + 1.0 * (k / 24.0)
                aB = f_angle(tt)
                bx = centerIdx + int(math.round(rBandOuter * math.sin(aB)))
                byy = centerY + rBandOuter * math.cos(aB)
                array.push(bandPts, chart.point.from_index(bx, byy))
            for k = 0 to 24
                tt2 = yearStart + 1.0 * ((24 - k) / 24.0)
                aB2 = f_angle(tt2)
                bx2 = centerIdx + int(math.round(rPrev * math.sin(aB2)))
                by2 = centerY + rPrev * math.cos(aB2)
                array.push(bandPts, chart.point.from_index(bx2, by2))
            polyline.new(bandPts, xloc = xloc.bar_index, closed = true, curved = false,
                 line_color = bandColor, line_width = 1, fill_color = bandColor)
            rPrev := rBandOuter
        // ---- (v5 patch, item 7) ----
        // Only e1x (the current-year label, e.g. "2026") is shifted 35
        // bar-index units to the right. e2x (next-year label, e.g.
        // "2027") is left completely unchanged.
        aE1 = f_angle(yearStart)
        rE  = R_OUTER * 1.20
        e1x = centerIdx + int(math.round(f_clampOff(rE * math.sin(aE1) + 35)))
        e1y = centerY + rE * math.cos(aE1)
        label.new(e1x, e1y, str.tostring(int(yearStart)), xloc = xloc.bar_index,
             style = label.style_none, textcolor = i_colNow, size = size.normal,
             textalign = text.align_center)
        aE2 = f_angle(yearStart + 1.0)
        e2x = centerIdx + int(math.round(f_clampOff(rE * math.sin(aE2))))
        e2y = centerY + rE * math.cos(aE2)
        label.new(e2x, e2y, str.tostring(int(yearStart) + 1), xloc = xloc.bar_index,
             style = label.style_none, textcolor = i_colNow, size = size.normal,
             textalign = text.align_center)

    // grid circles ($1..$1M, equally spaced -- linear in log10).
    // Every OTHER ring ($1, $100, $10k, $1M -- the "decade" rings) is
    // drawn at width 2 so the grid reads as layered depth instead of a
    // flat mesh; the in-between rings stay width 1.
    if i_showGrid
        for dIdx = 0 to array.size(decLogs) - 1
            r = f_gridRadius(array.get(decLogs, dIdx))
            isMainRing = dIdx % 2 == 0
            circPts = array.new<chart.point>()
            for k = 0 to 72
                ang = k * 2.0 * math.pi / 72.0
                cxk = centerIdx + int(math.round(r * math.sin(ang)))
                cyk = centerY + r * math.cos(ang)
                array.push(circPts, chart.point.from_index(cxk, cyk))
            polyline.new(circPts, xloc = xloc.bar_index, closed = true, curved = false,
                 line_color = i_colGrid, line_width = isMainRing ? 2 : 1)
            array.push(g_gridR, r)

    if i_showGrid
        // Price labels pinned to ONE fixed x, just outside the outer
        // ring, rather than next to each ring at that ring's own radius
        // -- the old version had each label drift to a different height
        // because it inherited a bit of that ring's own curvature. This
        // reads as a proper vertical axis instead of a scattered column.
        priceAxisX = centerIdx + int(math.round(R_OUTER)) + 20
        for dIdx = 0 to array.size(decLogs) - 1
            r = array.get(g_gridR, dIdx)
            label.new(priceAxisX, centerY - r, array.get(decLbl, dIdx), xloc = xloc.bar_index,
                 style = label.style_none, textcolor = i_colText, size = size.tiny,
                 textalign = text.align_left)

        // outer boundary -- one full decade past $1M, same spacing as every other ring
        outerPts = array.new<chart.point>()
        for k = 0 to 72
            ang = k * 2.0 * math.pi / 72.0
            cxk = centerIdx + int(math.round(R_OUTER * math.sin(ang)))
            cyk = centerY + R_OUTER * math.cos(ang)
            array.push(outerPts, chart.point.from_index(cxk, cyk))
        polyline.new(outerPts, xloc = xloc.bar_index, closed = true, curved = false,
             line_color = i_colAxis, line_width = 2)

    // 8 spokes, 4 bold axes with year labels (bumped to size.large --
    // size.normal was unreadable on 4K)
    if i_showSpokes
        for s = 0 to 7
            ang = s * math.pi / 4.0
            ex = centerIdx + int(math.round(R_OUTER * math.sin(ang)))
            ey = centerY + R_OUTER * math.cos(ang)
            isAxis = s % 2 == 0
            line.new(x1 = centerIdx, y1 = centerY, x2 = ex, y2 = ey, xloc = xloc.bar_index,
                 color = isAxis ? i_colAxis : i_colGrid, width = isAxis ? 2 : 1)
            if isAxis
                lx = centerIdx + int(math.round(f_clampOff(R_OUTER * 1.15 * math.sin(ang))))
                ly = centerY + R_OUTER * 1.15 * math.cos(ang)
                // Faux-bold: Pine text has no weight property, so a second
                // copy offset by 1 bar-index behind the first fakes a
                // heavier stroke. Also brighter than before (was getting
                // lost against the ring/grid lines).
                label.new(lx + 1, ly, array.get(axisLbl, s / 2), xloc = xloc.bar_index,
                     style = label.style_none, textcolor = i_colText, size = size.large,
                     textalign = text.align_center)
                label.new(lx, ly, array.get(axisLbl, s / 2), xloc = xloc.bar_index,
                     style = label.style_none, textcolor = i_colText, size = size.large,
                     textalign = text.align_center)

    // halvings -- outer ring (larger, translucent) + inner dot (small,
    // solid), drawn as two stacked labels instead of one flat circle.
    if i_showHalving
        for i = 0 to array.size(hvT) - 1
            [x, y] = f_xy(array.get(hvT, i), array.get(hvP, i), centerIdx, centerY)
            f_ringDot(x, y, label.style_square, i_colHalving, array.get(hvLbl, i))

    // bottoms -- diamond shape distinguishes them from ATH/halving at a
    // glance, not just by color. Still curated (see header note on why
    // live bottom detection is unreliable).
    if i_showBottom
        for i = 0 to array.size(btT) - 1
            [x, y] = f_xy(array.get(btT, i), array.get(btP, i), centerIdx, centerY)
            f_pointMarker(na, x, y, label.style_diamond, i_colBottom, size.small, array.get(btLbl, i))

    // ATH clusters: run-up trail + peak dot. Trail dots now grow in size
    // along the run-up (tiny -> small -> normal -> large at the peak)
    // instead of being uniform, so the trail reads as motion toward the
    // peak rather than a static row of dots.
    if i_showATH
        for i = 0 to array.size(athPeakT) - 1
            pk = array.get(athPeakT, i)
            st = array.get(athStartT, i)
            for k = 0 to i_athTrailStep
                tt = st + (pk - st) * (k / i_athTrailStep)
                pp = f_price(tt)
                isPeak = k == i_athTrailStep
                frac = k / i_athTrailStep
                // Comet-tail fan: trail dots sat exactly on the spiral
                // line before, so they visually merged with it and with
                // each other. A small outward radial offset (0 at the
                // peak, growing toward it) separates the trail from the
                // spiral without moving the peak dot itself off its
                // true point.
                a = f_angle(tt)
                r = f_radius(pp) + (isPeak ? 0.0 : frac * 8.0)
                x = centerIdx + int(math.round(r * math.sin(a)))
                y = centerY + r * math.cos(a)
                trailSize = frac < 0.33 ? size.tiny : frac < 0.66 ? size.tiny : size.small
                f_pointMarker(na, x, y, label.style_circle,
                     isPeak ? i_colATH : color.new(i_colATH, 70),
                     isPeak ? size.normal : trailSize,
                     isPeak ? array.get(athLbl, i) : "new all-time high")

    // spiral polyline -- curated backbone range only (START..BACKBONE_END).
    // No fabricated path beyond this: see the live extension line below
    // for what happens after the backbone ends. Now 3 layers instead of
    // 2: a wide translucent glow, the normal opaque line, and a thin
    // brighter highlight on top -- the highlight is what sells the
    // "glossy/dimensional" look the glow alone couldn't.
    if true
        pts = array.new<chart.point>()
        STEP = 1.0 / i_density
        n = int(math.round((BACKBONE_END - START) / STEP))
        for i = 0 to n
            t = START + i * STEP
            [x, y] = f_xy(t, f_price(t), centerIdx, centerY)
            array.push(pts, chart.point.from_index(x, y))
        if i_spiralGlow
            polyline.new(pts, xloc = xloc.bar_index, closed = false, curved = true,
                 line_color = color.new(i_colSpiral, 65), line_width = i_lineWidth + 3)
        polyline.new(pts, xloc = xloc.bar_index, closed = false, curved = true,
             line_color = i_colSpiral, line_width = i_lineWidth)
        if i_spiralGlow
            polyline.new(pts, xloc = xloc.bar_index, closed = false, curved = true,
                 line_color = color.new(i_colHighlight, 55), line_width = math.max(1, i_lineWidth - 2))

    // genesis center mark -- a tiny "₿ 2009" tag at the spiral's dead
    // center so it isn't just an empty point.
    if i_showCenter
        label.new(centerIdx, centerY, "₿ 2009", xloc = xloc.bar_index,
             style = label.style_none, textcolor = i_colAxis, size = size.small,
             textalign = text.align_center)

    drawn := true

// ---------------------- LIVE updates (move objects, don't recreate) ---
var float g_liveATH_price = na
var float g_liveATH_tYear = na
var label nowLabel      = na
var label nowRingLabel  = na
var line  liveExtLine   = na
var line  liveExtGlow   = na
var label liveATHLabel  = na

if barstate.islast and drawn
    if na(g_liveATH_price)
        g_liveATH_price := array.get(athPeakP, array.size(athPeakP) - 1)
        g_liveATH_tYear  := array.get(athPeakT, array.size(athPeakT) - 1)
    if useLiveNow and nowPrice > g_liveATH_price
        g_liveATH_price := nowPrice
        g_liveATH_tYear  := nowYear
    bool isNewLiveATH = useLiveNow and g_liveATH_price > array.get(athPeakP, array.size(athPeakP) - 1)

    [nx, ny] = f_xy(nowYear, nowPrice, g_centerIdx, g_centerY)

    // Now marker: ring (translucent, larger) + triangle-up (solid,
    // smaller) on top -- distinct shape from ATH/Bottom/Halving.
    // "Pulse": Pine can't animate between bars, but this toggle flips
    // roughly every 1.5s of real time, and since the script re-executes
    // on every incoming realtime tick, the marker size changes each
    // time that happens -- close enough to a pulse to read as "live"
    // without claiming a guaranteed animation clock.
    bool pulseOn = math.floor(timenow / 1500) % 2 == 0
    if i_showNow
        ringSize = pulseOn ? size.normal : size.large
        dotSize  = pulseOn ? size.small : size.normal
        nowTooltip = "Now - " + (useLiveNow ? "live" : "backbone (live data unavailable)") +
             " - ~$" + str.tostring(nowPrice, "#")
        nowRingLabel := f_pointMarker(nowRingLabel, nx, ny, label.style_circle,
             color.new(i_colNow, 55), ringSize, "")
        nowLabel := f_pointMarker(nowLabel, nx, ny, label.style_triangleup,
             i_colNow, dotSize, nowTooltip)

    if i_showLiveExt and useLiveNow
        [lx0, ly0] = f_xy(backboneLastT, backboneLastP, g_centerIdx, g_centerY)
        // Subdued on purpose: dotted (tighter spacing than dashed) +
        // thinner + more transparent, so it reads as "projected
        // continuation" rather than another confident spiral segment.
        if na(liveExtGlow)
            liveExtGlow := line.new(lx0, ly0, nx, ny, xloc = xloc.bar_index,
                 color = color.new(i_colNow, 90), width = 3, style = line.style_solid)
        else
            line.set_xy1(liveExtGlow, lx0, ly0)
            line.set_xy2(liveExtGlow, nx, ny)
        if na(liveExtLine)
            liveExtLine := line.new(lx0, ly0, nx, ny, xloc = xloc.bar_index,
                 color = color.new(i_colNow, 70), width = 1, style = line.style_dotted)
        else
            line.set_xy1(liveExtLine, lx0, ly0)
            line.set_xy2(liveExtLine, nx, ny)

    if i_showATH and isNewLiveATH
        [ax, ay] = f_xy(g_liveATH_tYear, g_liveATH_price, g_centerIdx, g_centerY)
        liveATHLabel := f_pointMarker(liveATHLabel, ax, ay, label.style_circle, i_colATH, size.small,
             "New ATH (live) - ~$" + str.tostring(g_liveATH_price, "#"))

// ---------------------- legend table ------------------------------
// 6 rows instead of 5: row 0 is a merged header ("Bitcoin Spiral"),
// rows 1-5 are the entries as before.
var table legend = table.new(position.top_left, 2, 6, border_width = 0)
if barstate.islast and i_showLegend
    table.cell(legend, 0, 0, "Bitcoin Spiral", text_color = color.new(color.black, 10),
         bgcolor = color.new(color.white, 100), text_size = size.small, text_halign = text.align_left)
    table.cell(legend, 1, 0, "", bgcolor = color.new(color.white, 100))
    table.merge_cells(legend, 0, 0, 1, 0)

    // Glyphs match the actual marker shapes on the chart (circle,
    // diamond, ring+dot, triangle) instead of generic color swatches --
    // so the legend and the chart read as the same visual language.
    table.cell(legend, 0, 1, "━━", text_color = i_colSpiral, bgcolor = color.new(color.white, 100), text_size = size.normal, text_halign = text.align_center)
    table.cell(legend, 1, 1, "Bitcoin", text_color = #62729fd9, bgcolor = color.new(color.white, 100), text_size = size.small, text_halign = text.align_left)
    table.cell(legend, 0, 2, "●", text_color = i_colATH, bgcolor = color.new(color.white, 100), text_size = size.normal, text_halign = text.align_center)
    table.cell(legend, 1, 2, "ATH's", text_color = #62729fd9, bgcolor = color.new(color.white, 100), text_size = size.small, text_halign = text.align_left)
    table.cell(legend, 0, 3, "◆", text_color = i_colBottom, bgcolor = color.new(color.white, 100), text_size = size.normal, text_halign = text.align_center)
    table.cell(legend, 1, 3, "Bottoms", text_color = #62729fd9, bgcolor = color.new(color.white, 100), text_size = size.small, text_halign = text.align_left)
    table.cell(legend, 0, 4, "◉", text_color = i_colHalving, bgcolor = color.new(color.white, 100), text_size = size.normal, text_halign = text.align_center)
    table.cell(legend, 1, 4, "Halvings", text_color = #62729fd9, bgcolor = color.new(color.white, 100), text_size = size.small, text_halign = text.align_left)
    table.cell(legend, 0, 5, "▲", text_color = i_colNow, bgcolor = color.rgb(98, 114, 159, 85), text_size = size.normal, text_halign = text.align_center)
    table.cell(legend, 1, 5, "Now" + (useLiveNow ? " (live)" : ""), text_color = #62729fd9, bgcolor = color.new(color.white, 100), text_size = size.small, text_halign = text.align_left)
````
