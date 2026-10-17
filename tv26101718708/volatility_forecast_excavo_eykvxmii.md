# Volatility Forecast [EXCAVO]

- url: https://www.tradingview.com/script/eYkvXmII-Volatility-Forecast-EXCAVO/
- type: indicator
- pine_id: PUB;1f838bd3ff944d5288e09ae75f62e119
- version: 1.0

## Description

Forward Projection of the Bollinger Envelope with Adaptive Horizon and Slope Clamp

The [i]Volatility Forecast[/i] takes the classical Bollinger Bands and
projects the basis and the bands forward by a configurable number of bars.
Slopes of the basis, standard deviation and ATR are estimated from linear
regression over a lookback window, then extrapolated through a smooth
curve into the right side of the chart. Small orange dots mark band
reclaim events on confirmed closed bars.

The forecast horizon adapts to the chart timeframe so the projection
stays meaningful at every TF, and a slope clamp prevents the bands from
ballooning into unrealistic territory after sharp regime shifts.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ HOW TO USE[/b]

[b]Step 1[/b]  →  Add the indicator. The current Bollinger Bands are
              plotted on the chart and a dashed envelope extends to the
              right with the projected basis and bands.

[b]Step 2[/b]  →  Read the projection. The projected upper and lower
              bands show the most likely volatility envelope over the
              next bars under the current trend and volatility regime.
              Wider end = expansion expected; narrower end = compression.

[b]Step 3[/b]  →  Use the reclaim dots. A small orange dot below a bar
              marks a confirmed bull band reclaim (price tagged the lower
              band and pulled back inside). A dot above a bar marks a
              bear reclaim. These are context, not entries.

[b]Step 4[/b]  →  Check the dashboard. The top right panel reads the
              projection mode, current width vs its rolling average,
              band state, and the last reclaim.

[b]Step 5[/b]  →  Combine with structure. The envelope pairs well with
              trend and structure tools. A breakout that aligns with an
              expanding projected envelope tends to continue; one against
              a contracting envelope tends to fade.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ HOW IT CALCULATES[/b]

[b]◆  Bollinger Bands[/b]
Basis is a simple moving average of the source over Length (default 20).
Standard deviation is computed over the same window. Bands are basis plus
or minus Multiplier times standard deviation (default 2.0). These are the
solid plotted lines on the chart.

[b]◆  Linear Regression Slopes[/b]
For the projection, the algorithm estimates per-bar slopes from a linear
regression of the basis, the standard deviation, and the ATR over the
Slope Lookback window (default 40). Slope is taken as the difference
between the linreg value at offset 0 and offset 1 - the per-bar drift
the regression expects to continue.

[b]◆  Slope Clamp[/b]
Each slope is then clamped to a safety bound so that the cumulative
projected displacement stays sensible. End to end, the projected basis
cannot drift more than two current band-widths, and the projected
standard deviation or ATR cannot grow more than 50% of its current value.
Sign of the slope is preserved so trend direction is intact, only the
magnitude is bounded. This keeps the projection meaningful after sharp
regime shifts.

[b]◆  Forward Projection[/b]
Three modes turn slopes into a projected envelope across the forecast
horizon:
[list]
[*][b]Linear[/b] extends basis and width on a straight line using the
   current slope at every step.
[*][b]Smooth Curve[/b] (default) eases from the current value toward a
   dynamic endpoint via a smoothstep curve so the projection has a
   natural arc instead of a hard linear extrapolation.
[*][b]Adaptive Volatility[/b] drives the projected width with ATR slope
   instead of standard-deviation slope. Useful when volatility is
   regime-dependent and the ATR captures it better than stdev.
[/list]
A projection floor at 50% ensures the envelope never collapses to a
single point on declining-volatility regimes.

[b]◆  Auto Timeframe Forecast[/b]
Forecast Bars defaults to Auto, which picks the horizon from the chart
timeframe: 40 bars on 4h and below, 20 on Daily, 10 on Weekly, 6 on
Monthly+. Manual override is available for operators who want a fixed
bar count regardless of timeframe.

[b]◆  Band Reclaim Markers[/b]
A bull reclaim fires when the prior bar's low touched the lower band,
the current bar's low has pulled back above the lower band, and the
close sits below the basis. A bear reclaim is symmetric on the upper
band. Cooldown of Length bars prevents same-direction stacking. The
optional Trend MA filter keeps bull marks only above the MA and bear
marks only below. By default markers fire only on confirmed closed bars
(no repaint); Real-time Markers can be enabled if intra-bar feedback is
preferred.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ WHAT MAKES IT DIFFERENT[/b]

[b]◆  Adaptive Horizon[/b]
The forecast horizon scales with the chart timeframe. The projection
shows a comparable arc on intraday, daily, weekly and monthly without
manual tuning per chart.

[b]◆  Slope Clamp Safety Net[/b]
Linear-regression slopes can overshoot after sharp moves or on long
horizons. The clamp caps the cumulative displacement so the projection
cannot grow into unrealistic ranges, regardless of the underlying slope.

[b]◆  Three Projection Modes[/b]
Linear, Smooth Curve and Adaptive Volatility cover the common shapes a
volatility envelope can take. Smooth Curve uses smoothstep easing for
a natural arc; Adaptive Volatility ignores stdev drift and tracks ATR
instead.

[b]◆  Confirmed Reclaim Markers[/b]
Small orange dots above or below the bar mark band reclaim events. They
fire on confirmed closed bars by default (no repaint), with an optional
real-time mode for operators who prefer intra-bar feedback. A trend-MA
filter keeps the bias clean.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ DASHBOARD[/b]

Real-time panel with the current state read:
[list]
[*][b]Mode[/b] - Linear / Smooth Curve / Adaptive Volatility
[*][b]Width vs Avg[/b] - current band width relative to its rolling average
[*][b]Band State[/b] - where price sits in the bands (Above Upper / Below Lower / Upper Half / Lower Half)
[*][b]Last Marker[/b] - direction and bars since the last band reclaim
[/list]

Legend table explains every on-chart element. Both panels toggle in the
Dashboard settings.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ SETTINGS[/b]

[b]Bollinger Bands[/b]
[list]
[*][b]Source[/b] - close (price series used for basis and stdev)
[*][b]Length[/b] - 20 (lookback for basis and stdev)
[*][b]Multiplier[/b] - 2.0 (band width in stdev units)
[*][b]Basis / Band / Fill Colors[/b] - default palette
[/list]

[b]Forecast Envelope[/b]
[list]
[*][b]Forecast Bars Mode[/b] - Auto (adapts to chart TF) or Manual
[*][b]Forecast Bars (Manual)[/b] - 40 (used when Mode = Manual)
[*][b]Slope Lookback[/b] - 40 (linreg window for slope estimation)
[*][b]Mode[/b] - Smooth Curve (Linear / Smooth Curve / Adaptive Volatility)
[*][b]Projection Style / Width / Colors[/b] - dashed, default palette
[*][b]Fill Projection[/b] - ON
[/list]

[b]Reclaim Markers[/b]
[list]
[*][b]Show Markers[/b] - ON
[*][b]Real-time Markers[/b] - OFF (no repaint by default; closed bars only)
[*][b]Filter by Trend MA[/b] - ON
[*][b]Trend MA Type[/b] - SMA (SMA / EMA / WMA / HMA)
[*][b]Trend MA Length[/b] - 100
[*][b]Marker Color[/b] - orange (#FF8C00)
[*][b]Show Trend MA[/b] - OFF
[/list]

[b]Dashboard[/b]
[list]
[*][b]Show Dashboard[/b] - ON
[*][b]Dashboard Position[/b] - Top Right
[*][b]Show Legend[/b] - ON
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ ALERTS[/b]

Two directional alertconditions are exposed:
[list]
[*][b]Bull Band Reclaim[/b] - fires on a confirmed bull reclaim event
[*][b]Bear Band Reclaim[/b] - fires on a confirmed bear reclaim event
[/list]

Set the alert condition to "Once Per Bar Close" for clean, non-repainting
delivery. Trend-MA filter and cooldown apply to alerts the same way they
apply to the on-chart markers.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Best regards,
EXCAVO

[quote]
[b]Disclaimer[/b]
Trading involves significant risk. This indicator is a technical analysis
tool and does not constitute financial advice, investment recommendations,
or a guarantee of future results. Past indicator behavior does not
guarantee future performance. Always use proper risk management and your
own judgment.
[/quote]

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// (c) EXCAVO
//
// Volatility Forecast [EXCAVO]
// -----------------------------------------------------------------------------
// Bollinger Bands with a forward projection of the envelope. The
// projection extrapolates basis and width using linear-regression slopes
// over a configurable lookback. Three modes: linear straight-line
// extension, smoothstep-eased curve toward a dynamic endpoint, or an
// ATR-driven adaptive width.
//
// Educational tool for visualising where volatility might extend over
// the next N bars. The projection is context, not a price prediction.
//
// Optional band-reclaim markers fire on the rejection pattern: the prior
// bar touched the band, the current bar reclaims back inside, and the
// close sits in the matching half of the range. An optional trend MA
// filter keeps markers in agreement with the broader bias.
//
//@version=6
indicator("Volatility Forecast [EXCAVO]", "EXCAVO Volatility Forecast",
     overlay          = true,
     max_lines_count  = 500,
     max_labels_count = 500,
     max_boxes_count  = 500)

//-----------------------------------------------------------------------------}
// Inputs
//-----------------------------------------------------------------------------{
string GRP_BB    = "Bollinger Bands"
string GRP_FCAST = "Forecast Envelope"
string GRP_MARK  = "Reclaim Markers"
string GRP_DASH  = "Dashboard"

// --- Bollinger Bands ---
float  i_src        = input.source(close, "Source",          group = GRP_BB,
     tooltip = "Price series used to compute the Bollinger basis and width.")
int    i_length     = input.int   (20, "Length",             minval = 2, maxval = 200, group = GRP_BB,
     tooltip = "Bollinger lookback. Higher = smoother bands, fewer band touches.")
float  i_mult       = input.float (2.0, "Multiplier",        minval = 0.5, maxval = 5.0, step = 0.1, group = GRP_BB,
     tooltip = "Band width in standard-deviation units. Standard value is 2.0.")
color  i_bbBasisCol = input.color (color.rgb(255, 140, 0),   "Basis Color", group = GRP_BB)
color  i_bbBandCol  = input.color (color.rgb(0, 60, 180),    "Band Color",  group = GRP_BB)
color  i_bbFillCol  = input.color (color.new(color.rgb(0, 60, 180), 92), "Fill Color", group = GRP_BB)

// --- Forecast Envelope ---
string i_projMode   = input.string("Auto", "Forecast Bars Mode",
     options = ["Auto", "Manual"], group = GRP_FCAST,
     tooltip = "Auto: forecast horizon adapts to the chart timeframe so the projection stays meaningful at every TF (40 bars on 4h and below, 20 on Daily, 10 on Weekly, 6 on Monthly+). Manual: use exactly the bar count below regardless of TF.")
int    i_projManual = input.int   (40, "Forecast Bars (Manual)", minval = 5, maxval = 100, group = GRP_FCAST,
     tooltip = "Used only when Forecast Bars Mode = Manual. Auto mode ignores this value.")
int    i_trendLen   = input.int   (40, "Slope Lookback",     minval = 10, maxval = 200, group = GRP_FCAST,
     tooltip = "Length used to estimate basis and width slopes via linear regression. Higher = smoother, slower trend.")
string i_mode       = input.string("Smooth Curve", "Mode",
     options = ["Linear", "Smooth Curve", "Adaptive Volatility"], group = GRP_FCAST,
     tooltip = "Linear extends basis and width on a straight line. Smooth Curve eases toward a dynamic endpoint via a smoothstep curve. Adaptive Volatility drives the width with ATR slope instead of standard-deviation slope.")
string i_projStyle  = input.string("Dashed", "Projection Style",
     options = ["Solid", "Dashed", "Dotted"], group = GRP_FCAST)
int    i_projWidth  = input.int   (2, "Projection Width", minval = 1, maxval = 5, group = GRP_FCAST)
color  i_projBasisCol = input.color(color.new(color.rgb(255, 140, 0), 25), "Projected Basis", group = GRP_FCAST)
color  i_projBandCol  = input.color(color.new(color.rgb(0, 60, 180), 25),  "Projected Bands", group = GRP_FCAST)
color  i_projFillCol  = input.color(color.new(color.rgb(0, 60, 180), 94),  "Projected Fill",  group = GRP_FCAST)
bool   i_projFill     = input.bool (true, "Fill Projection", group = GRP_FCAST)

// --- Reclaim Markers ---
bool   i_showMarkers = input.bool (true, "Show Markers", group = GRP_MARK,
     tooltip = "Show band-reclaim markers when a bar touches a band and the close pulls back inside.")
bool   i_realtime    = input.bool (false, "Real-time Markers", group = GRP_MARK,
     tooltip = "ON: a marker can appear on the still-forming bar and may disappear if price moves back before the bar closes (repaint). OFF (default): markers fire only on confirmed closed bars. No repaint.")
bool   i_filterByMa  = input.bool (true, "Filter by Trend MA", group = GRP_MARK,
     tooltip = "When ON, bull markers fire only above the trend MA and bear markers only below it.")
string i_maType  = input.string("SMA", "Trend MA Type", options = ["SMA", "EMA", "WMA", "HMA"], group = GRP_MARK)
int    i_maLen   = input.int  (100, "Trend MA Length", minval = 5, maxval = 500, group = GRP_MARK)
color  i_markerCol = input.color(color.rgb(255, 140, 0), "Marker Color", group = GRP_MARK,
     tooltip = "Color for both bull and bear band-reclaim markers. Orange (#FF8C00) by default. Same colour for both directions keeps the dots visually 'contextual' (a reclaim happened here) rather than reading as buy/sell.")
bool   i_showMa  = input.bool (false, "Show Trend MA", group = GRP_MARK)
color  i_maCol   = input.color(color.rgb(80, 80, 100), "Trend MA Color", group = GRP_MARK)

// --- Dashboard ---
bool   i_showDash = input.bool (true, "Show Dashboard", group = GRP_DASH,
     tooltip = "Toggle the real-time dashboard panel that summarises current width, projected width and the last marker.")
string i_dashPos  = input.string("Top Right", "Dashboard Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GRP_DASH,
     tooltip = "Where the dashboard panel docks on the chart.")
bool   i_showLgnd = input.bool (true, "Show Legend", group = GRP_DASH,
     tooltip = "Toggle the legend panel that explains every on-chart element.")

//-----------------------------------------------------------------------------}
// Constants
//-----------------------------------------------------------------------------{
color C_NEUTRAL     = color.rgb(80, 80, 100)
color C_DASH_BG     = color.rgb(50, 53, 60)
color C_DASH_BORDER = color.rgb(80, 85, 95)
color C_DASH_BULL   = color.rgb(80, 140, 255)
color C_DASH_BEAR   = color.rgb(240, 70, 70)
color C_DASH_ACCENT = color.rgb(255, 170, 50)

//-----------------------------------------------------------------------------}
// Computed inputs
//-----------------------------------------------------------------------------{
// Forecast horizon adapts to the chart timeframe so the projection stays
// meaningful regardless of TF. Without this, a 40-bar projection on a
// weekly chart extrapolates ~10 months of trend forward - bands balloon
// into unrealistic ranges. On intraday TFs (≤ 4h) 40 bars stays a
// reasonable horizon; on Daily we cut to 20 (~1 month), on Weekly to
// 10 (~2.5 months), on Monthly+ to 6.
int _tfSec = timeframe.in_seconds()
int autoBars =
     _tfSec <= 14400  ? 40 :    // ≤ 4h
     _tfSec <= 86400  ? 20 :    // 1D
     _tfSec <= 604800 ? 10 :    // 1W
     6                          // 1M+
int i_projBars = i_projMode == "Auto" ? autoBars : i_projManual

//-----------------------------------------------------------------------------}
// Helpers
//-----------------------------------------------------------------------------{
f_lineStyle(string s) =>
    switch s
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

f_dashPos(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

f_pickMa(series float src, simple int len, string kind) =>
    smaV = ta.sma(src, len)
    emaV = ta.ema(src, len)
    wmaV = ta.wma(src, len)
    hmaV = ta.hma(src, len)
    switch kind
        "SMA" => smaV
        "EMA" => emaV
        "WMA" => wmaV
        "HMA" => hmaV
        => smaV

// Smoothstep easing (standard cubic Hermite, in the public domain).
f_smoothStep(float t) =>
    c = math.max(0.0, math.min(1.0, t))
    c * c * (3.0 - 2.0 * c)

//-----------------------------------------------------------------------------}
// Bollinger Bands (current)
//-----------------------------------------------------------------------------{
float bbBasis = ta.sma(i_src, i_length)
float bbDev   = ta.stdev(i_src, i_length)
float bbWidth = i_mult * bbDev
float bbUpper = bbBasis + bbWidth
float bbLower = bbBasis - bbWidth

// display = display.pane keeps the lines visible on the chart but hides
// the right-edge price-scale tag so the scale stays clean.
plot(bbBasis, "Basis", color = i_bbBasisCol, linewidth = 2, display = display.pane)
pU = plot(bbUpper, "Upper", color = i_bbBandCol, linewidth = 1, display = display.pane)
pL = plot(bbLower, "Lower", color = i_bbBandCol, linewidth = 1, display = display.pane)
fill(pU, pL, color = i_bbFillCol)

//-----------------------------------------------------------------------------}
// Slopes for the forecast
//-----------------------------------------------------------------------------{
float atrVal = ta.atr(14)

float slopeBasis = ta.linreg(bbBasis, i_trendLen, 0) - ta.linreg(bbBasis, i_trendLen, 1)
float slopeDev   = ta.linreg(bbDev,   i_trendLen, 0) - ta.linreg(bbDev,   i_trendLen, 1)
float slopeAtr   = ta.linreg(atrVal,  i_trendLen, 0) - ta.linreg(atrVal,  i_trendLen, 1)

// Slope clamp - safety net against runaway extrapolation on high TFs
// or after sharp regime shifts. Caps the per-bar displacement so the
// total move across the projection cannot exceed sensible multiples of
// the current envelope:
//   - basis: at most 2x current band-width displacement end-to-end
//   - stdev / ATR: at most 50% growth end-to-end (bands can't blow up)
// Sign of the slope is preserved so direction information remains.
float _maxBasisDisp = bbWidth * 2.0
float _maxSlopeBase = i_projBars > 0 ? _maxBasisDisp / float(i_projBars) : 0.0
slopeBasis := math.sign(slopeBasis) * math.min(math.abs(slopeBasis), _maxSlopeBase)

float _maxDevDelta = bbDev * 0.5
float _maxSlopeDev = i_projBars > 0 ? _maxDevDelta / float(i_projBars) : 0.0
slopeDev := math.sign(slopeDev) * math.min(math.abs(slopeDev), _maxSlopeDev)

float _maxAtrDelta = atrVal * 0.5
float _maxSlopeAtr = i_projBars > 0 ? _maxAtrDelta / float(i_projBars) : 0.0
slopeAtr := math.sign(slopeAtr) * math.min(math.abs(slopeAtr), _maxSlopeAtr)

// Projection floor: never collapse the envelope below 50% of current
// width. Without this floor a negative dev slope can drive devEnd to
// 0, and the projected bands meet at a single point at the right edge.
const float MIN_DEV_FRAC = 0.5

float basisEnd   = bbBasis + slopeBasis * i_projBars
float devEnd     = math.max(bbDev * MIN_DEV_FRAC, bbDev + slopeDev * i_projBars)
float ratioEnd   = bbDev > 0 ? devEnd / bbDev : 1.0
float multEndRaw = i_mult * (1.0 + (ratioEnd - 1.0))
float multEnd    = math.max(i_mult, math.min(5.0, multEndRaw))

f_basisAt(int step) =>
    t = float(step) / float(i_projBars)
    float out = 0.0
    if i_mode == "Linear"
        out := bbBasis + slopeBasis * float(step)
    else
        out := bbBasis + (basisEnd - bbBasis) * f_smoothStep(t)
    out

f_multAt(int step) =>
    t = float(step) / float(i_projBars)
    val = i_mult + (multEnd - i_mult) * f_smoothStep(t)
    math.max(i_mult, math.min(5.0, val))

f_halfWidthAt(int step) =>
    t = float(step) / float(i_projBars)
    float w = 0.0
    if i_mode == "Adaptive Volatility"
        atrEnd = math.max(atrVal * MIN_DEV_FRAC, atrVal + slopeAtr * i_projBars)
        atrF   = math.max(atrVal * MIN_DEV_FRAC, atrVal + (atrEnd - atrVal) * f_smoothStep(t))
        w := atrF * 2.0
    else if i_mode == "Smooth Curve"
        devF = math.max(bbDev * MIN_DEV_FRAC, bbDev + (devEnd - bbDev) * f_smoothStep(t))
        w := devF * f_multAt(step)
    else
        devTrend = math.max(bbDev * MIN_DEV_FRAC, bbDev + slopeDev * float(step))
        w := devTrend * f_multAt(step)
    w

//-----------------------------------------------------------------------------}
// Line storage (rebuilt on last bar)
//-----------------------------------------------------------------------------{
// Pattern A line-anchoring per feedback-pine-line-drawing-anchoring memory.
// Lines and linefills are PRE-ALLOCATED ONCE in normal bar flow (not gated
// by barstate.islast). On every barstate.islast tick we UPDATE existing
// line objects in place via line.set_xy1 / line.set_xy2 / line.set_color
// instead of deleting and recreating. Stable object identity stops the
// rendering churn that caused lines to visually drift on scroll in the
// delete-and-recreate version (B2 banned pattern).
//
// MAX_PROJ_BARS must be >= input.int maxval for i_projBars.
const int MAX_PROJ_BARS = 100

var array<line>     projBasisLines = array.new<line>()
var array<line>     projUpperLines = array.new<line>()
var array<line>     projLowerLines = array.new<line>()
var array<linefill> projFills      = array.new<linefill>()

// One-time allocation on the very first script bar. The lines start with
// fully transparent color so they are invisible until barstate.islast
// gives them real coordinates and visible colors.
color C_HIDDEN = color.new(color.white, 100)
if barstate.isfirst
    for i = 0 to MAX_PROJ_BARS - 1
        array.push(projBasisLines, line.new(0, 0.0, 0, 0.0, color = C_HIDDEN))
        array.push(projUpperLines, line.new(0, 0.0, 0, 0.0, color = C_HIDDEN))
        array.push(projLowerLines, line.new(0, 0.0, 0, 0.0, color = C_HIDDEN))
        array.push(projFills, linefill.new(
             array.get(projUpperLines, i),
             array.get(projLowerLines, i),
             color = C_HIDDEN))

//-----------------------------------------------------------------------------}
// Update projection lines on the last bar (Pattern A in-place updates)
//-----------------------------------------------------------------------------{
if barstate.islast
    projLn      = f_lineStyle(i_projStyle)
    projFillCol = i_projFill ? i_projFillCol : C_HIDDEN

    int   px0 = bar_index
    float b0  = bbBasis
    float u0  = bbUpper
    float l0  = bbLower

    // Envelope: update the first i_projBars lines, hide the rest.
    for i = 0 to MAX_PROJ_BARS - 1
        line lnB = array.get(projBasisLines, i)
        line lnU = array.get(projUpperLines, i)
        line lnL = array.get(projLowerLines, i)
        linefill lf = array.get(projFills, i)
        if i < i_projBars
            int   step = i + 1
            int   x1   = bar_index + step
            float bUse = f_basisAt(step)
            float wUse = f_halfWidthAt(step)
            float uUse = bUse + wUse
            float lUse = bUse - wUse

            line.set_xy1(lnB, px0, b0)
            line.set_xy2(lnB, x1, bUse)
            line.set_color(lnB, i_projBasisCol)
            line.set_style(lnB, projLn)
            line.set_width(lnB, i_projWidth)

            line.set_xy1(lnU, px0, u0)
            line.set_xy2(lnU, x1, uUse)
            line.set_color(lnU, i_projBandCol)
            line.set_style(lnU, projLn)
            line.set_width(lnU, i_projWidth)

            line.set_xy1(lnL, px0, l0)
            line.set_xy2(lnL, x1, lUse)
            line.set_color(lnL, i_projBandCol)
            line.set_style(lnL, projLn)
            line.set_width(lnL, i_projWidth)

            linefill.set_color(lf, projFillCol)

            px0 := x1
            b0  := bUse
            u0  := uUse
            l0  := lUse
        else
            // Hide unused slots
            line.set_color(lnB, C_HIDDEN)
            line.set_color(lnU, C_HIDDEN)
            line.set_color(lnL, C_HIDDEN)
            linefill.set_color(lf, C_HIDDEN)

//-----------------------------------------------------------------------------}
// Reclaim Markers (band-touch reclaim pattern)
//-----------------------------------------------------------------------------{
// Bear: prior bar's high touched the upper band; current bar's high
// pulled back below the upper band; close still in the upper half.
// Bull: symmetric on the lower band.
// Optional trend-MA filter (only fire if direction agrees with the MA).
//
// Repaint guard: default OFF means a marker only fires once the bar
// is confirmed closed (barstate.isconfirmed). With Real-time Markers
// ON the marker can appear inside a still-forming bar but may then
// disappear if price moves back before the bar closes.

float trendMa = f_pickMa(close, i_maLen, i_maType)

bool _evalOk   = i_realtime or barstate.isconfirmed
bool bearTouch = _evalOk and high[1] >= bbUpper[1] and high < bbUpper and close > bbBasis
bool bullTouch = _evalOk and low[1]  <= bbLower[1] and low  > bbLower and close < bbBasis

if i_filterByMa
    bearTouch := bearTouch and close < trendMa
    bullTouch := bullTouch and close > trendMa

// Cooldown: prevent same-direction back-to-back markers within Length bars
var int _lastBullBar = -9999
var int _lastBearBar = -9999
bool bullOk = bullTouch and (bar_index - _lastBullBar) >= i_length
bool bearOk = bearTouch and (bar_index - _lastBearBar) >= i_length

if bullOk
    _lastBullBar := bar_index
if bearOk
    _lastBearBar := bar_index

// Small orange circles instead of directional label-up/down bubbles.
// These are CONTEXTUAL markers ("a band-reclaim happened here"), not
// directional entries. plotshape auto-positions the dot above/below
// the bar via location.abovebar / location.belowbar, so no manual ATR
// offset is needed (the previous ATR-EMA offset trick is no longer
// required).
plotshape(i_showMarkers and bullOk, "Bull Reclaim",
     location = location.belowbar, style = shape.circle,
     color = i_markerCol, size = size.small)
plotshape(i_showMarkers and bearOk, "Bear Reclaim",
     location = location.abovebar, style = shape.circle,
     color = i_markerCol, size = size.small)

plot(i_showMa ? trendMa : na, "Trend MA", color = i_maCol, linewidth = 1)

//-----------------------------------------------------------------------------}
// Dashboard state
//-----------------------------------------------------------------------------{
var int _lastMarkBar = na
var int _lastMarkDir = 0
if bullOk
    _lastMarkBar := bar_index
    _lastMarkDir := 1
if bearOk
    _lastMarkBar := bar_index
    _lastMarkDir := -1

//-----------------------------------------------------------------------------}
// Dashboard
//-----------------------------------------------------------------------------{
if barstate.islast and i_showDash
    var table dash = table.new(f_dashPos(i_dashPos), 2, 6,
         bgcolor      = C_DASH_BG,
         border_color = C_DASH_BORDER,
         border_width = 2,
         frame_color  = C_DASH_BORDER,
         frame_width  = 2)

    table.cell(dash, 0, 0, "EXCAVO",
         text_color = C_DASH_BULL, text_size = size.normal, text_halign = text.align_left)
    table.cell(dash, 1, 0, "Vol Forecast",
         text_color = color.white, text_size = size.normal, text_halign = text.align_right)

    // Mode
    table.cell(dash, 0, 1, "Mode",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 1, i_mode,
         text_color = C_DASH_BULL, text_size = size.small, text_halign = text.align_right)

    // Width vs rolling average
    float bbWidthAvg = ta.sma(bbWidth, 100)
    string widthTxt = bbWidthAvg > 0 ?
         str.tostring(math.round(bbWidth / bbWidthAvg * 100.0)) + "%" : "--"
    color  widthClr = bbWidthAvg > 0 ?
         (bbWidth > bbWidthAvg ? C_DASH_ACCENT : C_DASH_BULL) : C_NEUTRAL
    table.cell(dash, 0, 2, "Width vs Avg",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 2, widthTxt,
         text_color = widthClr, text_size = size.small, text_halign = text.align_right)

    // Band state
    string stateTxt = close > bbUpper ? "Above Upper" :
                      close < bbLower ? "Below Lower" :
                      close > bbBasis ? "Upper Half"  : "Lower Half"
    color  stateClr = close > bbUpper ? C_DASH_BULL :
                      close < bbLower ? C_DASH_BEAR :
                      close > bbBasis ? C_DASH_BULL : C_DASH_BEAR
    table.cell(dash, 0, 3, "Band State",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 3, stateTxt,
         text_color = stateClr, text_size = size.small, text_halign = text.align_right)

    // Last marker
    string lastTxt = na(_lastMarkBar) ? "--" :
         (_lastMarkDir == 1 ? "▲ " : "▼ ") + str.tostring(bar_index - _lastMarkBar) + "b ago"
    color  lastClr = _lastMarkDir ==  1 ? C_DASH_BULL :
                     _lastMarkDir == -1 ? C_DASH_BEAR : C_NEUTRAL
    table.cell(dash, 0, 4, "Last Marker",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 4, lastTxt,
         text_color = lastClr, text_size = size.small, text_halign = text.align_right)

    // Spacer
    table.cell(dash, 0, 5, "", text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(dash, 1, 5, "", text_size = size.small, bgcolor = C_DASH_BG)

//-----------------------------------------------------------------------------}
// Legend
//-----------------------------------------------------------------------------{
if barstate.islast and i_showLgnd
    var table leg = table.new(position.bottom_left, 2, 6,
         bgcolor      = C_DASH_BG,
         border_color = C_DASH_BORDER,
         border_width = 1,
         frame_color  = C_DASH_BORDER,
         frame_width  = 1)
    table.cell(leg, 0, 0, "LEGEND",
         text_color = C_DASH_BULL, text_size = size.normal,
         text_halign = text.align_center, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 0, "", text_size = size.small, bgcolor = C_DASH_BG)
    table.merge_cells(leg, 0, 0, 1, 0)

    // Row 1 - Basis (orange solid line)
    table.cell(leg, 0, 1, "━", text_color = i_bbBasisCol, text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 1, "Basis - moving average (equilibrium)",
         text_color = color.white, text_size = size.small, bgcolor = C_DASH_BG)

    // Row 2 - Bollinger bands (blue solid lines)
    table.cell(leg, 0, 2, "━", text_color = i_bbBandCol, text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 2, "Bands - current volatility envelope",
         text_color = color.white, text_size = size.small, bgcolor = C_DASH_BG)

    // Row 3 - Forward projection (dashed lines to the right)
    table.cell(leg, 0, 3, "┅", text_color = i_bbBandCol, text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 3, "Projection - forecast for next N bars",
         text_color = color.white, text_size = size.small, bgcolor = C_DASH_BG)

    // Row 4 - Reclaim markers (single row, both directions)
    table.cell(leg, 0, 4, "●", text_color = i_markerCol, text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 4, "Band reclaim (above bar = bear / below = bull)",
         text_color = color.white, text_size = size.small, bgcolor = C_DASH_BG)

    // Spacer
    table.cell(leg, 0, 5, "", text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 5, "", text_size = size.small, bgcolor = C_DASH_BG)

//-----------------------------------------------------------------------------}
// Alerts
//-----------------------------------------------------------------------------{
alertcondition(bullOk, title = "Bull Band Reclaim",
     message = "EXCAVO Volatility Forecast: bull band reclaim on {{ticker}} ({{interval}})")
alertcondition(bearOk, title = "Bear Band Reclaim",
     message = "EXCAVO Volatility Forecast: bear band reclaim on {{ticker}} ({{interval}})")
````
