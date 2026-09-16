<!-- tradingview-pine-id: PUB;155b04886e104e028655c898667385aa -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# VIX 3D Term Structure

Source: https://www.tradingview.com/script/iiGlchUQ-VIX-3D-Term-Structure-MantisAlgo/

## Description

VIX 3D Term Structure

VIX 3D Term Structure maps the live CBOE implied-volatility curve across six constant-maturity horizons: VIX1D, VIX9D, VIX, VIX3M, VIX6M, and VIX1Y.

TERM = Constant-maturity horizon from 1D to 1Y
TIME = Each tenor’s evolution over the latest nine trading days, from current to oldest
IV = Annualized implied-volatility level in VIX points

The indicator can be used on any chart symbol as a broad U.S. equity volatility context tool.
[image]https://www.tradingview.com/x/l0SRPn8i/[/image]
🌐 3D SURFACE
The lower pane displays the current VIX term structure with nine trading days of historical depth. Surface colors compare each tenor with its own selected daily average:
- 21 trading days — one month
- 63 trading days — one quarter (default)
- 126 trading days — six months
- 252 trading days — one year
[image]https://www.tradingview.com/x/fkoitEBT/[/image]
Cooler colors indicate values below the selected average, while warmer colors indicate values above it. Camera rotation changes only the viewing angle and does not affect calculations.

📈 HISTORY RIBBON
The six VIX tenors are also plotted as 2D history on the active chart timeframe. Each line’s color reflects that tenor’s relative level versus its selected daily average.

📊 DASHBOARD
Curve Shape classifies the current back-minus-front term spread:
- 🟢 CONTANGO — the back tenor is more than 0.35 volatility points above the front tenor
- 🟠 FLAT — the back-minus-front spread is between −0.35 and +0.35 VIX points
- 🔴 BACKWARDATION — the front tenor is more than 0.35 volatility points above the back tenor

The dashboard also reports the six tenor values, Term Spread, 20-day annualized S&P 500 realized volatility, and the Implied–Realized Vol Spread calculated as 30-day VIX minus trailing SPX Realized Vol (20D).

Vol Level uses the median relative level of VIX9D, VIX, and VIX3M:
- 🟢 LOW VOL — 0.90 or lower
- 🟠 MID VOL — between 0.90 and 1.08
- 🔴 HIGH VOL — 1.08 or higher

⚙️ SETTINGS
Heat average length controls the historical baseline used for surface colors and Vol Level:
- 21 trading days — most responsive; useful for short-term volatility shifts, but more sensitive to noise
- 63 trading days — balanced short-to-medium-term baseline and the default
- 126 trading days — broader regime comparison with less sensitivity to temporary spikes
- 252 trading days — long-term annual context; slowest to react to recent regime changes

Changing this setting does not change the live tenor values or Curve Shape. It changes only how current volatility is classified relative to its historical baseline.

View rotates the 3D surface. Custom angle is applied only when Custom is selected. Dashboard selects the dashboard position on the price chart.

🧭 HOW TO USE
Use Curve Shape to read the front-to-back slope of the VIX term structure and the surface to track how each tenor has changed over the latest nine trading days.

Colors show whether each tenor is above or below its selected historical average. The surface provides volatility context rather than a directional price target.

🔔 ALERTS
Alerts fire when Curve Shape newly becomes BACKWARDATION or CONTANGO.

⚠️ DISCLAIMER
This indicator is provided for informational and educational purposes only and does not constitute financial or investment advice. VIX term structure describes option-implied volatility conditions and is not a direct directional signal for the charted asset. Historical conditions do not guarantee future results. All trading and investment decisions remain the sole responsibility of the user.

---

## Source Code

````pine
// © 2026 MantisAlgo
// All rights reserved.
//@version=6
indicator("VIX 3D Term Structure", shorttitle="VIX 3D", overlay=false, max_polylines_count=100, max_labels_count=50, max_lines_count=100)

// -----------------------------------------------------------------------------
// VIX 3D Term Structure
// Official CBOE VIX tenors as a pane-native 3D surface plus a chart-timeframe
// ribbon. The HUD sits on the price chart.
//
// Contango = far tenor above near tenor.
// Backwardation = near tenor above far tenor.
// FLAT = the back-minus-front spread is within ±0.35 VIX points.
// -----------------------------------------------------------------------------

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 01 — Inputs
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpSurface = "Surface"
grpCamera = "Camera"
grpHud = "HUD"

bool vtsShow1d = true
bool vtsShowFill = true
bool vtsShowAxes = true
bool vtsShowLabels = true
bool vtsShowRibbon = true
vtsHeatLookback = input.int(63, "Heat average length", options=[21, 63, 126, 252], tooltip="Daily sessions used as each tenor's heat-color baseline: 21 = 1 month, 63 = 1 quarter, 126 = 6 months, 252 = 1 year.", group=grpSurface)

vtsCamera = input.string("Back-left", "View", options=["Near-right", "Back-left", "Straight-up", "Side-right", "Side-left", "Top-down", "Top-reverse", "Custom"], tooltip="Choose the surface rotation. Side is a full side view; Top looks down on the term×time plane.", group=grpCamera)
vtsCustomAngle = input.float(-60.0, "Custom angle (°)", minval=-90.0, maxval=90.0, step=5.0, tooltip="Left-right rotation when View is Custom. -90° is full left side; +90° is full right side.", group=grpCamera)

vtsPanel = input.string("top_right", "Panel", options=["top_right", "top_left", "bottom_right", "bottom_left"], tooltip="Choose where the display-only HUD sits on the price chart.", group=grpHud)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 02 — Constants and display settings
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
int VTS_DEPTH = 9
// 3D Y is VIX units in this pane, not the chart price. That keeps the surface
// visible on NVDA, BTC, USDKRW, or any other symbol. Compact right pocket:
// large span/gap makes TradingView auto-fit hundreds of future bars.
int VTS_SPAN = 112
int VTS_DEPTH_RUN = 30
int VTS_GAP = 36
int VTS_NAME_OFF = 14

color VTS_GO = #00B96B
color VTS_CAUTION = #FFA028
color VTS_STOP = #F23645
color VTS_INK = #E8ECF4
color VTS_MUTED = #5E6680
color VTS_SURFACE = #0A0A0A
color VTS_RAISED = #1A1A1A

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 05 — Runtime orchestration
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Daily context: close[k] inside request.security("D") is k sessions back, even on a 1h chart.
// The configurable heat baseline rides in the same tuple so each maturity
// point remains one security call, not two.
[d1d0, d1d1, d1d2, d1d3, d1d4, d1d5, d1d6, d1d7, d1d8, d1d9, avg1d] = request.security("CBOE:VIX1D", "D", [close, close[1], close[2], close[3], close[4], close[5], close[6], close[7], close[8], close[9], ta.sma(close, vtsHeatLookback)], lookahead=barmerge.lookahead_off)
[d9d0, d9d1, d9d2, d9d3, d9d4, d9d5, d9d6, d9d7, d9d8, d9d9, avg9d] = request.security("CBOE:VIX9D", "D", [close, close[1], close[2], close[3], close[4], close[5], close[6], close[7], close[8], close[9], ta.sma(close, vtsHeatLookback)], lookahead=barmerge.lookahead_off)
[d300, d301, d302, d303, d304, d305, d306, d307, d308, d309, avg30] = request.security("CBOE:VIX", "D", [close, close[1], close[2], close[3], close[4], close[5], close[6], close[7], close[8], close[9], ta.sma(close, vtsHeatLookback)], lookahead=barmerge.lookahead_off)
[d3m0, d3m1, d3m2, d3m3, d3m4, d3m5, d3m6, d3m7, d3m8, d3m9, avg3m] = request.security("CBOE:VIX3M", "D", [close, close[1], close[2], close[3], close[4], close[5], close[6], close[7], close[8], close[9], ta.sma(close, vtsHeatLookback)], lookahead=barmerge.lookahead_off)
[d6m0, d6m1, d6m2, d6m3, d6m4, d6m5, d6m6, d6m7, d6m8, d6m9, avg6m] = request.security("CBOE:VIX6M", "D", [close, close[1], close[2], close[3], close[4], close[5], close[6], close[7], close[8], close[9], ta.sma(close, vtsHeatLookback)], lookahead=barmerge.lookahead_off)
[d1y0, d1y1, d1y2, d1y3, d1y4, d1y5, d1y6, d1y7, d1y8, d1y9, avg1y] = request.security("CBOE:VIX1Y", "D", [close, close[1], close[2], close[3], close[4], close[5], close[6], close[7], close[8], close[9], ta.sma(close, vtsHeatLookback)], lookahead=barmerge.lookahead_off)
// HUD only. SPX close-to-close RV20; does not color the surface.
float rv20 = request.security("SP:SPX", "D", ta.stdev(math.log(close / close[1]), 20) * math.sqrt(252) * 100, lookahead=barmerge.lookahead_off)

r1d = request.security("CBOE:VIX1D", timeframe.period, close, lookahead=barmerge.lookahead_off)
r9d = request.security("CBOE:VIX9D", timeframe.period, close, lookahead=barmerge.lookahead_off)
r30 = request.security("CBOE:VIX", timeframe.period, close, lookahead=barmerge.lookahead_off)
r3m = request.security("CBOE:VIX3M", timeframe.period, close, lookahead=barmerge.lookahead_off)
r6m = request.security("CBOE:VIX6M", timeframe.period, close, lookahead=barmerge.lookahead_off)
r1y = request.security("CBOE:VIX1Y", timeframe.period, close, lookahead=barmerge.lookahead_off)

vtsKnotOk(float v) =>
    not na(v) and v > 0.0

vtsTermU(float days) =>
    math.max(days, 0.0) / 365.0

vtsPick(int lag, float v0, float v1, float v2, float v3, float v4, float v5, float v6, float v7, float v8, float v9) =>
    lag <= 0 ? v0 : lag == 1 ? v1 : lag == 2 ? v2 : lag == 3 ? v3 : lag == 4 ? v4 : lag == 5 ? v5 : lag == 6 ? v6 : lag == 7 ? v7 : lag == 8 ? v8 : v9

vts1dAt(int lag) =>
    vtsPick(lag, d1d0, d1d1, d1d2, d1d3, d1d4, d1d5, d1d6, d1d7, d1d8, d1d9)

vts9dAt(int lag) =>
    vtsPick(lag, d9d0, d9d1, d9d2, d9d3, d9d4, d9d5, d9d6, d9d7, d9d8, d9d9)

vts30At(int lag) =>
    vtsPick(lag, d300, d301, d302, d303, d304, d305, d306, d307, d308, d309)

vts3mAt(int lag) =>
    vtsPick(lag, d3m0, d3m1, d3m2, d3m3, d3m4, d3m5, d3m6, d3m7, d3m8, d3m9)

vts6mAt(int lag) =>
    vtsPick(lag, d6m0, d6m1, d6m2, d6m3, d6m4, d6m5, d6m6, d6m7, d6m8, d6m9)

vts1yAt(int lag) =>
    vtsPick(lag, d1y0, d1y1, d1y2, d1y3, d1y4, d1y5, d1y6, d1y7, d1y8, d1y9)

vtsAvgDays(float days) =>
    days <= 5.0 ? nz(avg1d, avg9d) : days <= 15.0 ? nz(avg9d, avg30) : days <= 50.0 ? nz(avg30, avg3m) : days <= 120.0 ? nz(avg3m, avg6m) : days <= 250.0 ? nz(avg6m, avg1y) : nz(avg1y, avg6m)

vtsHeat(float v, float avg) =>
    vtsKnotOk(v) and vtsKnotOk(avg) ? v / avg : 1.0

vtsPaint(float heat, int transp) =>
    float h = math.max(0.0, heat)
    color raw = h <= 0.90 ? VTS_GO : h < 1.08 ? color.from_gradient(h, 0.90, 1.08, VTS_GO, VTS_CAUTION) : color.from_gradient(math.min(h, 1.35), 1.08, 1.35, VTS_CAUTION, VTS_STOP)
    color.new(raw, transp)

f_fmt(float value, string format) =>
    na(value) ? "—" : str.tostring(value, format)

vtsFrontNow = vtsShow1d and vtsKnotOk(d1d0) ? d1d0 : d9d0
vtsBackNow = vtsKnotOk(d1y0) ? d1y0 : d6m0
bool vtsSpreadOk = vtsKnotOk(vtsFrontNow) and vtsKnotOk(vtsBackNow)
float vtsSpread = vtsSpreadOk ? vtsBackNow - vtsFrontNow : na
bool vtsBackRich = vtsSpreadOk and vtsSpread > 0.35
bool vtsFrontRich = vtsSpreadOk and vtsSpread < -0.35
string vtsShape = not vtsSpreadOk ? "NO DATA" : vtsFrontRich ? "BACKWARDATION" : vtsBackRich ? "CONTANGO" : "FLAT"
color vtsShapeCol = not vtsSpreadOk ? VTS_MUTED : vtsFrontRich ? VTS_STOP : vtsBackRich ? VTS_GO : VTS_CAUTION
bool vtsVRPOk = vtsKnotOk(d300) and not na(rv20)
float vtsVRP = vtsVRPOk ? d300 - rv20 : na
float vtsH1 = vtsHeat(d1d0, avg1d)
float vtsH9 = vtsHeat(d9d0, avg9d)
float vtsH30 = vtsHeat(d300, avg30)
float vtsH3 = vtsHeat(d3m0, avg3m)
float vtsH6 = vtsHeat(d6m0, avg6m)
float vtsHY = vtsHeat(d1y0, avg1y)
// Core curve level: the median Heat of 9D, 30D, and 3M. This prevents a
// one-day event spike from classifying the entire volatility curve by itself.
bool vtsCoreHeatOk = vtsKnotOk(d9d0) and vtsKnotOk(avg9d) and vtsKnotOk(d300) and vtsKnotOk(avg30) and vtsKnotOk(d3m0) and vtsKnotOk(avg3m)
float vtsCoreHeat = vtsCoreHeatOk ? vtsH9 + vtsH30 + vtsH3 - math.min(vtsH9, math.min(vtsH30, vtsH3)) - math.max(vtsH9, math.max(vtsH30, vtsH3)) : na
string vtsHeatState = not vtsCoreHeatOk ? "NO DATA" : vtsCoreHeat >= 1.08 ? "HIGH VOL" : vtsCoreHeat <= 0.90 ? "LOW VOL" : "MID VOL"
color vtsHeatCol = vtsCoreHeatOk ? vtsPaint(vtsCoreHeat, 0) : VTS_MUTED
color vtsStateCol = not vtsCoreHeatOk ? VTS_MUTED : vtsHeatState == "HIGH VOL" ? VTS_STOP : vtsHeatState == "LOW VOL" ? VTS_GO : VTS_CAUTION
float rH1 = vtsHeat(r1d, avg1d)
float rH9 = vtsHeat(r9d, avg9d)
float rH30 = vtsHeat(r30, avg30)
float rH3 = vtsHeat(r3m, avg3m)
float rH6 = vtsHeat(r6m, avg6m)
float rHY = vtsHeat(r1y, avg1y)
color rC1 = vtsKnotOk(r1d) ? vtsPaint(rH1, 0) : VTS_MUTED
color rC9 = vtsKnotOk(r9d) ? vtsPaint(rH9, 0) : VTS_MUTED
color rC30 = vtsKnotOk(r30) ? vtsPaint(rH30, 0) : VTS_MUTED
color rC3 = vtsKnotOk(r3m) ? vtsPaint(rH3, 0) : VTS_MUTED
color rC6 = vtsKnotOk(r6m) ? vtsPaint(rH6, 0) : VTS_MUTED
color rCY = vtsKnotOk(r1y) ? vtsPaint(rHY, 0) : VTS_MUTED

vtsHi = math.max(nz(d1d0), math.max(nz(d9d0), math.max(nz(d300), math.max(nz(d3m0), math.max(nz(d6m0), nz(d1y0))))))
vtsLoRaw = math.min(nz(d9d0, 1e6), math.min(nz(d300, 1e6), math.min(nz(d3m0, 1e6), math.min(nz(d6m0, 1e6), nz(d1y0, 1e6)))))
vtsLo = math.min(nz(d1d0, vtsLoRaw), vtsLoRaw)
rHi = math.max(nz(r1d), math.max(nz(r9d), math.max(nz(r30), math.max(nz(r3m), math.max(nz(r6m), nz(r1y))))))
rLoRaw = math.min(nz(r9d, 1e6), math.min(nz(r30, 1e6), math.min(nz(r3m, 1e6), math.min(nz(r6m, 1e6), nz(r1y, 1e6)))))
rLo = math.min(nz(r1d, rLoRaw), rLoRaw)
paneHi = rHi
paneLo = rLo
float vtsLiftEst = math.max((nz(vtsHi) - nz(vtsLo, nz(vtsHi))) * 0.11, 0.85)
float paneScaleHi = math.max(nz(paneHi), nz(vtsHi) + VTS_DEPTH * vtsLiftEst)
float paneScaleLo = math.min(nz(paneLo, nz(vtsLo)), nz(vtsLo, nz(vtsHi)))

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 06 — Rendering and drawing lifecycle
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(ta.highest(paneScaleHi, 2) * 1.08, "VIX 3D scale high", display=display.none)
plot(ta.lowest(paneScaleLo, 2) * 0.96, "VIX 3D scale low", display=display.none)
plot(vtsShowRibbon and vtsShow1d ? r1d : na, "1D", color=rC1, linewidth=1)
plot(vtsShowRibbon ? r9d : na, "9D", color=rC9, linewidth=1)
plot(vtsShowRibbon ? r30 : na, "30D", color=rC30, linewidth=2)
plot(vtsShowRibbon ? r3m : na, "3M", color=rC3, linewidth=1)
plot(vtsShowRibbon ? r6m : na, "6M", color=rC6, linewidth=1)
plot(vtsShowRibbon ? r1y : na, "1Y", color=rCY, linewidth=2)

var array<polyline> vtsPolys = array.new<polyline>()
var array<label> vtsLabs = array.new<label>()
var line vtsJoin = na
var table vtsHud = table.new(position.top_right, 2, 12, bgcolor=color.new(VTS_SURFACE, 8), frame_color=color.new(VTS_CAUTION, 35), frame_width=1, border_color=color.new(VTS_MUTED, 55), border_width=1, force_overlay=true)
if barstate.isfirst
    table.merge_cells(vtsHud, 0, 0, 1, 0)
var bool vtsDrawn = false
var label vtsName1d = na
var label vtsName9d = na
var label vtsName30 = na
var label vtsName3m = na
var label vtsName6m = na
var label vtsName1y = na
// The surface is a fixed 2.5D projection. The settings choose the direction
// of the time-depth axis and can foreshorten the term axis toward a full side view.
// polyline.new stays in this last-bar block — never inside a UDF (TV GC).
vtsCameraAngle(string preset, float customAngle) =>
    preset == "Near-right" ? 30.0 : preset == "Back-left" ? -60.0 : preset == "Straight-up" ? 0.0 : preset == "Side-right" ? 90.0 : preset == "Side-left" ? -90.0 : preset == "Top-down" or preset == "Top-reverse" ? 0.0 : customAngle

vtsProjX(float u, float lagF, int origin, int span, int depthRun, float depthX) =>
    float zN = lagF / VTS_DEPTH
    // Turn the term axis with the depth axis. At 0° the curve faces front;
    // at larger absolute angles the term axis foreshortens toward a side view.
    float termScale = math.max(math.sqrt(math.max(1.0 - depthX * depthX, 0.0)), 0.12)
    int(math.round(origin + u * span * termScale + zN * depthRun * depthX))

vtsProjY(float val, float lagF, float lift, float depthY, int cameraMode, float topBase) =>
    cameraMode == 1 ? topBase + lagF * lift * 1.25 : cameraMode == -1 ? topBase + (VTS_DEPTH - lagF) * lift * 1.25 : val + lagF * lift * depthY

bool vtsRefreshSurface = barstate.islast and (not vtsDrawn or barstate.isnew or barstate.isconfirmed)
if vtsRefreshSurface
    while array.size(vtsPolys) > 0
        polyline.delete(array.pop(vtsPolys))
    while array.size(vtsLabs) > 0
        label.delete(array.pop(vtsLabs))
    if not na(vtsJoin)
        line.delete(vtsJoin)
        vtsJoin := na

    float yPeak = nz(vtsHi)
    float yFloor = nz(vtsLo, yPeak)
    for lagScan = 0 to VTS_DEPTH
        float s1 = vts1dAt(lagScan)
        float s9 = vts9dAt(lagScan)
        float s30 = vts30At(lagScan)
        float s3 = vts3mAt(lagScan)
        float s6 = vts6mAt(lagScan)
        float sY = vts1yAt(lagScan)
        float scanHi = math.max(nz(s1), math.max(nz(s9), math.max(nz(s30), math.max(nz(s3), math.max(nz(s6), nz(sY))))))
        float scanLo = math.min(nz(s9, scanHi), math.min(nz(s30, scanHi), math.min(nz(s3, scanHi), math.min(nz(s6, scanHi), nz(sY, scanHi)))))
        scanLo := math.min(nz(s1, scanLo), scanLo)
        yPeak := math.max(yPeak, scanHi)
        yFloor := math.min(yFloor, scanLo)
    float lift = math.max((yPeak - yFloor) * 0.11, 0.85)

    // One enlarged camera uses 45 fill faces + 1 live curve + 3 axes.
    int camLast = 0
    for cam = 0 to camLast
        int origin = bar_index + VTS_GAP
        int span = VTS_SPAN
        int dRun = VTS_DEPTH_RUN
        string cameraPreset = vtsCamera
        float customAngle = vtsCustomAngle
        float cameraAngle = vtsCameraAngle(cameraPreset, customAngle)
        bool topView = cameraPreset == "Top-down" or cameraPreset == "Top-reverse"
        int cameraMode = cameraPreset == "Top-reverse" ? -1 : topView ? 1 : 0
        float depthX = topView ? 0.0 : math.sin(cameraAngle * 0.0174532925199433)
        float depthY = topView ? 0.0 : math.cos(cameraAngle * 0.0174532925199433)
        if vtsShowFill
            for lag = VTS_DEPTH to 1
                int fade = int(math.min(62, 32 + lag * 3))
                for rib = 0 to 4
                    float dA = rib == 0 ? 1.0 : rib == 1 ? 9.0 : rib == 2 ? 30.0 : rib == 3 ? 93.0 : 184.0
                    float dB = rib == 0 ? 9.0 : rib == 1 ? 30.0 : rib == 2 ? 93.0 : rib == 3 ? 184.0 : 365.0
                    float aFar = rib == 0 ? vts1dAt(lag) : rib == 1 ? vts9dAt(lag) : rib == 2 ? vts30At(lag) : rib == 3 ? vts3mAt(lag) : vts6mAt(lag)
                    float bFar = rib == 0 ? vts9dAt(lag) : rib == 1 ? vts30At(lag) : rib == 2 ? vts3mAt(lag) : rib == 3 ? vts6mAt(lag) : vts1yAt(lag)
                    float aNear = rib == 0 ? vts1dAt(lag - 1) : rib == 1 ? vts9dAt(lag - 1) : rib == 2 ? vts30At(lag - 1) : rib == 3 ? vts3mAt(lag - 1) : vts6mAt(lag - 1)
                    float bNear = rib == 0 ? vts9dAt(lag - 1) : rib == 1 ? vts30At(lag - 1) : rib == 2 ? vts3mAt(lag - 1) : rib == 3 ? vts6mAt(lag - 1) : vts1yAt(lag - 1)
                    if vtsKnotOk(aFar) and vtsKnotOk(bFar) and vtsKnotOk(aNear) and vtsKnotOk(bNear)
                        float avgA = vtsAvgDays(dA)
                        float avgB = vtsAvgDays(dB)
                        float heatQ = (vtsHeat(aFar, avgA) + vtsHeat(bFar, avgB) + vtsHeat(aNear, avgA) + vtsHeat(bNear, avgB)) / 4.0
                        color fillC = vtsPaint(heatQ, fade)
                        color edgeC = vtsPaint(heatQ, math.min(fade + 28, 82))
                        int xAf = vtsProjX(vtsTermU(dA), lag, origin, span, dRun, depthX)
                        int xBf = vtsProjX(vtsTermU(dB), lag, origin, span, dRun, depthX)
                        int xBn = vtsProjX(vtsTermU(dB), lag - 1, origin, span, dRun, depthX)
                        int xAn = vtsProjX(vtsTermU(dA), lag - 1, origin, span, dRun, depthX)
                        float yAf = vtsProjY(aFar, lag, lift, depthY, cameraMode, yFloor)
                        float yBf = vtsProjY(bFar, lag, lift, depthY, cameraMode, yFloor)
                        float yBn = vtsProjY(bNear, lag - 1, lift, depthY, cameraMode, yFloor)
                        float yAn = vtsProjY(aNear, lag - 1, lift, depthY, cameraMode, yFloor)
                        array<chart.point> quad = array.new<chart.point>()
                        if depthX < 0.0
                            array.push(quad, chart.point.from_index(xAn, yAn))
                            array.push(quad, chart.point.from_index(xBn, yBn))
                            array.push(quad, chart.point.from_index(xBf, yBf))
                            array.push(quad, chart.point.from_index(xAf, yAf))
                        else
                            array.push(quad, chart.point.from_index(xAf, yAf))
                            array.push(quad, chart.point.from_index(xBf, yBf))
                            array.push(quad, chart.point.from_index(xBn, yBn))
                            array.push(quad, chart.point.from_index(xAn, yAn))
                        array.push(vtsPolys, polyline.new(quad, closed=true, xloc=xloc.bar_index, fill_color=fillC, line_color=edgeC, line_width=1, force_overlay=false))

        array<chart.point> nowSeg = array.new<chart.point>()
        if vtsShow1d and vtsKnotOk(d1d0)
            array.push(nowSeg, chart.point.from_index(vtsProjX(vtsTermU(1.0), 0, origin, span, dRun, depthX), vtsProjY(d1d0, 0, lift, depthY, cameraMode, yFloor)))
        if vtsKnotOk(d9d0)
            array.push(nowSeg, chart.point.from_index(vtsProjX(vtsTermU(9.0), 0, origin, span, dRun, depthX), vtsProjY(d9d0, 0, lift, depthY, cameraMode, yFloor)))
        if vtsKnotOk(d300)
            array.push(nowSeg, chart.point.from_index(vtsProjX(vtsTermU(30.0), 0, origin, span, dRun, depthX), vtsProjY(d300, 0, lift, depthY, cameraMode, yFloor)))
        if vtsKnotOk(d3m0)
            array.push(nowSeg, chart.point.from_index(vtsProjX(vtsTermU(93.0), 0, origin, span, dRun, depthX), vtsProjY(d3m0, 0, lift, depthY, cameraMode, yFloor)))
        if vtsKnotOk(d6m0)
            array.push(nowSeg, chart.point.from_index(vtsProjX(vtsTermU(184.0), 0, origin, span, dRun, depthX), vtsProjY(d6m0, 0, lift, depthY, cameraMode, yFloor)))
        if vtsKnotOk(d1y0)
            array.push(nowSeg, chart.point.from_index(vtsProjX(vtsTermU(365.0), 0, origin, span, dRun, depthX), vtsProjY(d1y0, 0, lift, depthY, cameraMode, yFloor)))
        if array.size(nowSeg) >= 2
            array.push(vtsPolys, polyline.new(nowSeg, curved=false, closed=false, xloc=xloc.bar_index, line_color=vtsHeatCol, line_width=3, force_overlay=false))

        if vtsShowLabels
            if vtsShow1d and vtsKnotOk(d1d0)
                array.push(vtsLabs, label.new(vtsProjX(vtsTermU(1.0), 0, origin, span, dRun, depthX), vtsProjY(d1d0, 0, lift, depthY, cameraMode, yFloor), "1D  " + str.tostring(d1d0, "#.00"), style=label.style_label_down, color=color.new(VTS_SURFACE, 0), textcolor=vtsPaint(vtsH1, 0), size=size.small, force_overlay=false))
            if vtsKnotOk(d9d0)
                array.push(vtsLabs, label.new(vtsProjX(vtsTermU(9.0), 0, origin, span, dRun, depthX), vtsProjY(d9d0, 0, lift, depthY, cameraMode, yFloor), "9D  " + str.tostring(d9d0, "#.00"), style=label.style_label_up, color=color.new(VTS_SURFACE, 0), textcolor=vtsPaint(vtsH9, 0), size=size.small, force_overlay=false))
            if vtsKnotOk(d300)
                array.push(vtsLabs, label.new(vtsProjX(vtsTermU(30.0), 0, origin, span, dRun, depthX), vtsProjY(d300, 0, lift, depthY, cameraMode, yFloor), "30D  " + str.tostring(d300, "#.00"), style=label.style_label_down, color=color.new(VTS_SURFACE, 0), textcolor=vtsPaint(vtsH30, 0), size=size.small, force_overlay=false))
            if vtsKnotOk(d3m0)
                array.push(vtsLabs, label.new(vtsProjX(vtsTermU(93.0), 0, origin, span, dRun, depthX), vtsProjY(d3m0, 0, lift, depthY, cameraMode, yFloor), "3M  " + str.tostring(d3m0, "#.00"), style=label.style_label_up, color=color.new(VTS_SURFACE, 0), textcolor=vtsPaint(vtsH3, 0), size=size.small, force_overlay=false))
            if vtsKnotOk(d6m0)
                array.push(vtsLabs, label.new(vtsProjX(vtsTermU(184.0), 0, origin, span, dRun, depthX), vtsProjY(d6m0, 0, lift, depthY, cameraMode, yFloor), "6M  " + str.tostring(d6m0, "#.00"), style=label.style_label_down, color=color.new(VTS_SURFACE, 0), textcolor=vtsPaint(vtsH6, 0), size=size.small, force_overlay=false))
            if vtsKnotOk(d1y0)
                array.push(vtsLabs, label.new(vtsProjX(vtsTermU(365.0), 0, origin, span, dRun, depthX), vtsProjY(d1y0, 0, lift, depthY, cameraMode, yFloor), "1Y  " + str.tostring(d1y0, "#.00"), style=label.style_label_up, color=color.new(VTS_SURFACE, 0), textcolor=vtsPaint(vtsHY, 0), size=size.small, force_overlay=false))
        if vtsShowAxes
            color ax = color.new(VTS_CAUTION, 0)
            array<chart.point> axIV = array.new<chart.point>()
            array.push(axIV, chart.point.from_index(vtsProjX(0.0, 0.0, origin, span, dRun, depthX), vtsProjY(yFloor, 0.0, lift, depthY, cameraMode, yFloor)))
            array.push(axIV, chart.point.from_index(vtsProjX(0.0, 0.0, origin, span, dRun, depthX), vtsProjY(yPeak, 0.0, lift, depthY, cameraMode, yFloor)))
            array.push(vtsPolys, polyline.new(axIV, closed=false, xloc=xloc.bar_index, line_color=ax, line_width=2, force_overlay=false))
            array<chart.point> axTerm = array.new<chart.point>()
            array.push(axTerm, chart.point.from_index(vtsProjX(0.0, 0.0, origin, span, dRun, depthX), vtsProjY(yFloor, 0.0, lift, depthY, cameraMode, yFloor)))
            array.push(axTerm, chart.point.from_index(vtsProjX(1.0, 0.0, origin, span, dRun, depthX), vtsProjY(yFloor, 0.0, lift, depthY, cameraMode, yFloor)))
            array.push(vtsPolys, polyline.new(axTerm, closed=false, xloc=xloc.bar_index, line_color=ax, line_width=2, force_overlay=false))
            array<chart.point> axTime = array.new<chart.point>()
            array.push(axTime, chart.point.from_index(vtsProjX(0.0, 0.0, origin, span, dRun, depthX), vtsProjY(yFloor, 0.0, lift, depthY, cameraMode, yFloor)))
            array.push(axTime, chart.point.from_index(vtsProjX(0.0, VTS_DEPTH, origin, span, dRun, depthX), vtsProjY(yFloor, VTS_DEPTH, lift, depthY, cameraMode, yFloor)))
            array.push(vtsPolys, polyline.new(axTime, closed=false, xloc=xloc.bar_index, line_color=ax, line_width=2, force_overlay=false))
            array.push(vtsLabs, label.new(vtsProjX(0.0, 0.0, origin, span, dRun, depthX), vtsProjY(yPeak, 0.0, lift, depthY, cameraMode, yFloor), "IV", style=label.style_label_left, color=color.new(VTS_CAUTION, 25), textcolor=VTS_INK, size=size.small, force_overlay=false))
            array.push(vtsLabs, label.new(vtsProjX(1.0, 0.0, origin, span, dRun, depthX), vtsProjY(yFloor, 0.0, lift, depthY, cameraMode, yFloor), "TERM → 1Y", style=label.style_label_lower_right, color=color.new(VTS_CAUTION, 25), textcolor=VTS_INK, size=size.small, force_overlay=false))
            array.push(vtsLabs, label.new(vtsProjX(0.0, VTS_DEPTH, origin, span, dRun, depthX), vtsProjY(yFloor, VTS_DEPTH, lift, depthY, cameraMode, yFloor), "TIME  (Older)", style=label.style_label_right, color=color.new(VTS_CAUTION, 25), textcolor=VTS_INK, size=size.small, force_overlay=false))
    vtsJoin := line.new(bar_index, paneLo, bar_index, paneHi, xloc=xloc.bar_index, extend=extend.none, color=color.new(VTS_CAUTION, 25), width=1, style=line.style_dashed, force_overlay=false)
    vtsDrawn := true

if barstate.islast
    if vtsShowRibbon and vtsShow1d and vtsKnotOk(r1d)
        if na(vtsName1d)
            vtsName1d := label.new(bar_index - VTS_NAME_OFF, r1d, "1D", xloc=xloc.bar_index, style=label.style_label_left, color=color.new(VTS_SURFACE, 15), textcolor=rC1, size=size.small, force_overlay=false)
        else
            label.set_xy(vtsName1d, bar_index - VTS_NAME_OFF, r1d)
            label.set_text(vtsName1d, "1D")
            label.set_textcolor(vtsName1d, rC1)
    else if not na(vtsName1d)
        label.set_text(vtsName1d, "")
    if vtsShowRibbon and vtsKnotOk(r9d)
        if na(vtsName9d)
            vtsName9d := label.new(bar_index - VTS_NAME_OFF, r9d, "9D", xloc=xloc.bar_index, style=label.style_label_left, color=color.new(VTS_SURFACE, 15), textcolor=rC9, size=size.small, force_overlay=false)
        else
            label.set_xy(vtsName9d, bar_index - VTS_NAME_OFF, r9d)
            label.set_text(vtsName9d, "9D")
            label.set_textcolor(vtsName9d, rC9)
    else if not na(vtsName9d)
        label.set_text(vtsName9d, "")
    if vtsShowRibbon and vtsKnotOk(r30)
        if na(vtsName30)
            vtsName30 := label.new(bar_index - VTS_NAME_OFF, r30, "30D", xloc=xloc.bar_index, style=label.style_label_left, color=color.new(VTS_SURFACE, 15), textcolor=rC30, size=size.small, force_overlay=false)
        else
            label.set_xy(vtsName30, bar_index - VTS_NAME_OFF, r30)
            label.set_text(vtsName30, "30D")
            label.set_textcolor(vtsName30, rC30)
    else if not na(vtsName30)
        label.set_text(vtsName30, "")
    if vtsShowRibbon and vtsKnotOk(r3m)
        if na(vtsName3m)
            vtsName3m := label.new(bar_index - VTS_NAME_OFF, r3m, "3M", xloc=xloc.bar_index, style=label.style_label_left, color=color.new(VTS_SURFACE, 15), textcolor=rC3, size=size.small, force_overlay=false)
        else
            label.set_xy(vtsName3m, bar_index - VTS_NAME_OFF, r3m)
            label.set_text(vtsName3m, "3M")
            label.set_textcolor(vtsName3m, rC3)
    else if not na(vtsName3m)
        label.set_text(vtsName3m, "")
    if vtsShowRibbon and vtsKnotOk(r6m)
        if na(vtsName6m)
            vtsName6m := label.new(bar_index - VTS_NAME_OFF, r6m, "6M", xloc=xloc.bar_index, style=label.style_label_left, color=color.new(VTS_SURFACE, 15), textcolor=rC6, size=size.small, force_overlay=false)
        else
            label.set_xy(vtsName6m, bar_index - VTS_NAME_OFF, r6m)
            label.set_text(vtsName6m, "6M")
            label.set_textcolor(vtsName6m, rC6)
    else if not na(vtsName6m)
        label.set_text(vtsName6m, "")
    if vtsShowRibbon and vtsKnotOk(r1y)
        if na(vtsName1y)
            vtsName1y := label.new(bar_index - VTS_NAME_OFF, r1y, "1Y", xloc=xloc.bar_index, style=label.style_label_left, color=color.new(VTS_SURFACE, 15), textcolor=rCY, size=size.small, force_overlay=false)
        else
            label.set_xy(vtsName1y, bar_index - VTS_NAME_OFF, r1y)
            label.set_text(vtsName1y, "1Y")
            label.set_textcolor(vtsName1y, rCY)
    else if not na(vtsName1y)
        label.set_text(vtsName1y, "")
    vtsPos = vtsPanel == "top_left" ? position.top_left : vtsPanel == "bottom_right" ? position.bottom_right : vtsPanel == "bottom_left" ? position.bottom_left : position.top_right
    table.set_position(vtsHud, vtsPos)
    string vtsFrontLabel = vtsShow1d and vtsKnotOk(d1d0) ? "1D" : "9D"
    string vtsBackLabel = vtsKnotOk(d1y0) ? "1Y" : "6M"
    string vtsTermSpreadLabel = "Term Spread (" + vtsBackLabel + " − " + vtsFrontLabel + ")"
    string vtsLevelText = vtsCoreHeatOk ? vtsHeatState + "  " + str.tostring((vtsCoreHeat - 1.0) * 100.0, "+#.#;-#.#") + "%" : "NO DATA"
    table.cell(vtsHud, 0, 0, "VIX 3D", text_color=VTS_CAUTION, text_size=size.small, bgcolor=VTS_RAISED, text_halign=text.align_center)
    table.cell(vtsHud, 0, 1, "Curve Shape", text_color=VTS_INK, text_size=size.small)
    table.cell(vtsHud, 1, 1, vtsShape, text_color=vtsShapeCol, text_size=size.small)
    table.cell(vtsHud, 0, 2, "1D", text_color=VTS_INK, text_size=size.small)
    table.cell(vtsHud, 1, 2, vtsShow1d ? f_fmt(r1d, "#.00") : "off", text_color=vtsShow1d ? rC1 : VTS_MUTED, text_size=size.small)
    table.cell(vtsHud, 0, 3, "9D", text_color=VTS_INK, text_size=size.small)
    table.cell(vtsHud, 1, 3, f_fmt(r9d, "#.00"), text_color=rC9, text_size=size.small)
    table.cell(vtsHud, 0, 4, "30D", text_color=VTS_INK, text_size=size.small)
    table.cell(vtsHud, 1, 4, f_fmt(r30, "#.00"), text_color=rC30, text_size=size.small)
    table.cell(vtsHud, 0, 5, "3M", text_color=VTS_INK, text_size=size.small)
    table.cell(vtsHud, 1, 5, f_fmt(r3m, "#.00"), text_color=rC3, text_size=size.small)
    table.cell(vtsHud, 0, 6, "6M", text_color=VTS_INK, text_size=size.small)
    table.cell(vtsHud, 1, 6, f_fmt(r6m, "#.00"), text_color=rC6, text_size=size.small)
    table.cell(vtsHud, 0, 7, "1Y", text_color=VTS_INK, text_size=size.small)
    table.cell(vtsHud, 1, 7, f_fmt(r1y, "#.00"), text_color=rCY, text_size=size.small)
    table.cell(vtsHud, 0, 8, "Realized Vol (20D)", text_color=VTS_INK, text_size=size.small)
    table.cell(vtsHud, 1, 8, not na(rv20) ? str.tostring(rv20, "0.00") : "-", text_color=na(rv20) ? VTS_MUTED : rv20 >= 0 ? VTS_GO : VTS_STOP, text_size=size.small)
    table.cell(vtsHud, 0, 9, "Implied–Realized Vol Spread", text_color=VTS_INK, text_size=size.small)
    table.cell(vtsHud, 1, 9, vtsVRPOk ? str.tostring(vtsVRP, "+0.00;-0.00") : "-", text_color=not vtsVRPOk ? VTS_MUTED : vtsVRP >= 0 ? VTS_GO : VTS_STOP, text_size=size.small)
    table.cell(vtsHud, 0, 10, vtsTermSpreadLabel, text_color=VTS_INK, text_size=size.small)
    table.cell(vtsHud, 1, 10, vtsSpreadOk ? str.tostring(vtsSpread, "+0.00;-0.00") : "-", text_color=not vtsSpreadOk ? VTS_MUTED : vtsSpread >= 0 ? VTS_GO : VTS_STOP, text_size=size.small)
    table.cell(vtsHud, 0, 11, "Vol Level", text_color=VTS_INK, text_size=size.small)
    table.cell(vtsHud, 1, 11, vtsLevelText, text_color=vtsStateCol, text_size=size.small)

alertcondition(barstate.isconfirmed and vtsFrontRich and not vtsFrontRich[1], "Shape BACKWARDATION", "Front of the curve moved above the back")
alertcondition(barstate.isconfirmed and vtsBackRich and not vtsBackRich[1], "Shape CONTANGO", "Back of the curve moved above the front")
````
