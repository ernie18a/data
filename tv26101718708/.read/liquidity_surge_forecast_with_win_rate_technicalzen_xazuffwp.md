# Liquidity Surge Forecast with Win Rate [TechnicalZen]

- url: https://www.tradingview.com/script/XAZuffwP-Liquidity-Surge-Forecast-with-Win-Rate-TechnicalZen/
- type: indicator
- pine_id: PUB;ad67a29bb19942f1ae4554d7fec343e3
- version: 2.0

## Description

Publishing this v2 with Proven performance dashboard for scalpers. 

[b]What This Is[/b]

A 3D liquidity-and-momentum visualization with a built-in, MFE-verified win-rate dashboard.

Two independent systems — [b]Money Flow[/b] (MFI-driven) and [b]Price Current[/b] (Hull-VWMA or signed-ADX) — render as layered terrains inside a bounded 3D box. When both systems agree on direction, a whale surfaces: 🐳 bullish, 🐋 bearish. Every whale is tracked. Every outcome is scored. The dashboard prints the running win rate on your chart, on your instrument, on your timeframe. Live.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Built On [url=https://www.tradingview.com/script/hWgzX0S9-Money-Flow-Dynamics-Forecaster-3D-TechnicalZen/]Money Flow Dynamics Forecaster 3D[/url][/b]

This is the next iteration. Same solid confluence-detection engine, rebuilt rendering, and a performance dashboard on top for visual proof of how the system is doing.

Improvements over v1:

[list]
[*][b]Win-rate dashboard with ATR-scaled MFE[/b] — every 🐳 / 🐋 signal is now tracked and scored. Each signal resolves when the next one fires, judged by directional close [i]or[/i] MFE ≥ 0.5 × ATR. No more hand-waving about "does this actually work."
[*][b]Seamless carpet terrain[/b] — layered strips share color between fill and outline. No visible seams; the terrain reads as one continuous surface.
[*][b]Dotted wave contours[/b] — each HMA layer traces as a dotted line along its depth, like isobars on a topographic map. Wave shape is visible at a glance.
[*][b]Depth fog gradient[/b] — far Z layers tint toward atmospheric navy-violet. Real 3D depth perception without extra wireframe.
[*][b]Dotted wireframe, emphasized horizon[/b] — box edges and grids are dotted (quieter), while the Y=0 tide line is kept solid and bold as the one structural anchor that should stand out.
[*][b]Unified ADX-mode terrain[/b] — ADX mode now renders a proper 12-layer terrain (v1 fell back to a single-ribbon). Both oscillator modes share identical visual grammar.
[*][b]Cleaner defaults[/b] — Yaw −20°, Pitch 15°, axis markers off, back-wall grid off, mesh columns removed. Less visual noise out of the box.
[*][b]Bug fixes[/b] — ring-buffer wrap when [i]Slope Lookback[/i] > [i]Time Span[/i]; ADX-mode second-signal for the emoji confluence check; dead inputs cleaned up.
[/list]

If you're coming from v1, interpretation is identical — same riders, same whales, same color semantics. The new dashboard simply gives you a way to measure how often confluence actually pays off.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]The Win-Rate Dashboard — Proof, Not Claims[/b]

Most indicators [i]claim[/i] a success rate. This one [b]measures[/b] it.

Every 🐳 / 🐋 signal is recorded at its first bar of entry and held pending — until the [b]next[/b] signal fires. At that moment the indicator judges the previous signal by [b]two criteria[/b]:

[list]
[*][b]Directional close[/b] — did price close favorable at the next signal's bar? (bull: close > entry. bear: close < entry.)
[*][b]MFE ≥ ATR threshold[/b] — did the favorable excursion between the two signals reach [b]0.5 × ATR[/b] (at the entry bar)? ATR multiplier is tunable.
[/list]

[b]Either criterion qualifies as a win.[/b] Direction alone is a win. MFE alone is a win. No fixed evaluation window — signals are judged against reality when the regime actually changes.

The threshold is [b]volatility-relative[/b]: quiet instruments need small moves, volatile ones need larger moves. Always calibrated to the instrument, never arbitrary.

The dashboard shows:

[list]
[*]Total bull and bear signals fired (resolved ones only — the most recent signal is pending until the next)
[*]How many won
[*]Rolling win rate, traffic-lit — green ≥ 60%, yellow 40–60%, red < 40%
[*]Your ATR multiplier, printed right on the table
[/list]

[b]Why next-signal evaluation?[/b] Because fixed bar counts are arbitrary. A regime lasts as long as it lasts. When the next whale flips, the previous whale's journey is over — and that's the fair moment to judge it. Entry quality and regime persistence are both captured naturally.

The result: [b]you don't trust marketing, you trust your own data[/b]. Every number is computed from your chart, right now, with your settings. Change the ATR multiplier, change the timeframe — the dashboard updates. This is how an indicator should prove itself.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]The Signal[/b]

Confluence requires agreement between two fundamentally different witnesses:

[list]
[*][b]Money Flow[/b] — volume-weighted momentum (MFI). 20 Hull-smoothed layers (HMA 3 → HMA 60). Detects accumulation or distribution [i]before[/i] price has to move.
[*][b]Price Current[/b] — volume-weighted directional pressure (Hull-VWMA 2-bar slope, or signed-ADX HMAs). 12 layers. Detects committed displacement of price.
[/list]

Money Flow leads. Price Current confirms. When both middle-layer slopes point the same way, a whale fires. That is the signal worth trading — not a crossover, not a threshold break, but two independent systems aligning.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]What You See[/b]

[list]
[*][b]Layered dotted waves[/b] — each HMA smoothing horizon, stitched into a 3D carpet. Depth fog tints far layers into atmospheric haze for real 3D perception.
[*][b]Forecast terrain[/b] — each layer slope-extrapolated with exponential decay into the future half of the box.
[*]🏄‍♂ [b]Surfer[/b] — rides the Money Flow leading edge (the impulse).
[*]⛵ [b]Sailboat[/b] — rides the Price Current leading edge (the trend).
[*]🐳 / 🐋 [b]Whale[/b] — surfaces at the forecast edge when both slopes agree. Confluence confirmed.
[*][b]Dashboard[/b] — running win rate, always visible.
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]How to Use[/b]

[list=1]
[*]Load with defaults. Switch chart to Volume Candles.
[*]Check the dashboard — what is your current win rate on this instrument / timeframe?
[*]Tune [b]Win Threshold (× ATR)[/b] to match how strict you want the measurement to be — 0.3×ATR = loose, 0.5×ATR = balanced (default), 1.0×ATR = strict.
[*]Watch for 🐳 or 🐋. They are rare by design.
[*]On a whale, align with the direction. On no whale, stand aside. Let the dashboard keep scoring.
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Best Paired With [url=https://www.tradingview.com/script/ejlOagzv-Smart-Candle-Structures-TechnicalZen/]Smart Candle Structures [TechnicalZen][/url][/b]

This indicator tells you [b]whether and when[/b] to trust the flow. Smart Candle Structures tells you [b]where[/b] to act — order blocks, fair-value gaps, liquidity sweeps, BOS / CHoCH zones.

Together: the right place, at the right moment, with a measurable win rate behind it.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Key Settings[/b]

[list]
[*][b]Time Span[/b] — past bars rendered and forecast horizon (default 15)
[*][b]Momentum Source[/b] — MFI (default) or RSI
[*][b]Oscillator Type[/b] — Hull-VWMA (default) or signed-ADX
[*][b]Slope Lookback[/b] — bars used to compute the slope that fires whales (default 4)
[*][b]ATR Length[/b] — lookback for volatility scaling the win threshold (default 14)
[*][b]Win Threshold (× ATR)[/b] — minimum favorable excursion between signals, as a multiple of ATR at the entry bar (default 0.5 × ATR)
[*][b]Depth Fog Strength[/b] — atmospheric depth gradient on far layers (default 0.55)
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Disclaimer[/b]

This is a visualization and analytical tool, not financial advice or a signal service. The dashboard measures what [i]has happened[/i] on your chart; it does not predict what will. Markets are reflexive. Past performance does not guarantee future results. Trade with your own risk management. Every trade can lose.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[i]Confluence you can measure.[/i]
— TechnicalZen

## Source Code

````pine
// Liquidity Surge Forecast with Win Rate [TechnicalZen]
// "Confluence you can measure."
//
// Aesthetic:
//   SEAMLESS carpet — terrain strips share color between fill and outline; no visible seams.
//   DOTTED wireframe — box, X=0 plane, and grids rendered dotted so structure reads but stays quiet.
//   DEPTH FOG — each strip's color tints toward an atmospheric navy-violet as Z increases,
//               giving real 3D depth perception without extra objects.
//
// Two layered terrains inside a bounded 3D box:
//   MOMENTUM TERRAIN    — 20 HMA layers of MFI (or RSI). Yellow/green/red, fog-tinted.
//   PRICE CURRENT CARPET — 12 layers: VWMA 2-bar slope OR signed-ADX HMAs (per oscType). Cyan / light-blue / maroon, fog-tinted.
//
// Deltas vs v1:
//   - All wireframe lines → dotted style
//   - Terrain polylines: line_color == fill_color → seamless surface
//   - New f_depthTint blends base color into a depth fog color by Z position
//   - Mesh dotted columns on terrain REMOVED (they broke the carpet)
//   - A–I reference points REMOVED (cleaner plane)
//   - Y=0 horizon: thicker, solid (the one element that *should* stand out as "sea level")
//
// Invisible plot(±50) anchors pin the pane's Y range so the box stays a constant size.

//@version=6
indicator("Liquidity Surge Forecast with Win Rate [TechnicalZen] ", "Liquidity Surge Forecast", overlay = false, max_polylines_count = 100, max_lines_count = 300, max_labels_count = 20, calc_bars_count = 1000)

//---------------------------------------------------------------------------------------------------------------------}
int    timeSpan    = input.int(15, "Time Span (bars each side of 0)", minval = 5, maxval = 100, tooltip = "Number of past bars to render. Around 15 reads cleanly — higher values pile the strips on top of each other.")
string momentumSrc = input.string("MFI", "Momentum Source", options = ["MFI", "RSI"], tooltip = "MFI = Money Flow Index (volume-weighted momentum). RSI = Relative Strength Index (pure price momentum).")
int    rsiLen      = input.int(14, "Momentum Length", minval = 2)
float yAmp     = input.float(2.0, "Rib Amplification", minval = 0.5, maxval = 5.0, step = 0.1, tooltip = "Stretches momentum ribs vertically. MFI/RSI rarely hits 0/100, so the raw centered value (x-50)*2 usually stays in ±40. Bumping amp makes moderate swings fill more of the ±100 axis. Clamped to ±100.")

float yawDeg   = input.float(-20, "Yaw (°)",            group = "Camera", minval = -180, maxval = 180, tooltip = "Viewer presets: 0°=back/mid, 90°=right, 180°=front, -90°=left.")
float pitchDeg = input.float(15,  "Pitch (°)",          group = "Camera", minval = 1,   maxval = 89, tooltip = "Eye-level at ~5°. Top-down (above Y=100) at ~89°. Intermediate values tilt between.")
float sTime    = input.float(1.2, "Scale X (Time, bars per unit)", group = "Camera", step = 0.1, minval = 0.1)
float sAlt     = input.float(0.4, "Scale Y (Vertical)",            group = "Camera", step = 0.1, minval = 0.1, tooltip = "Fixed scale for Y axis. Keeps box size constant regardless of volatility.")
float sDepth   = input.float(0.4, "Scale Z (Depth)",               group = "Camera", step = 0.1, minval = 0.1, tooltip = "Fixed scale for Z axis.")
int   offsetX  = input.int(0,     "Offset X",           group = "Camera")
float offsetY  = input.float(0,   "Offset Y",           group = "Camera")

string oscType    = input.string("Hull-VWMA", "Oscillator Type", options = ["Hull-VWMA", "ADX"], group = "Oscillator")
int    vwmaLen    = input.int(30, "VWMA Length",     group = "Oscillator", minval = 2)
float  oscScale   = input.float(500.0, "Hull-VWMA Scale", group = "Oscillator", minval = 1.0, step = 10.0, tooltip = "Slope is a tiny % change — multiplier pushes it into the ±100 box range. Raise if signal looks flat.")
int    adxLen     = input.int(14,  "ADX Length (DMI period)", group = "Oscillator", minval = 2)
bool   showOsc    = input.bool(true, "Show Oscillator Carpet", group = "Oscillator", tooltip = "Renders the 12-layer carpet (Hull-VWMA slopes or signed-ADX HMAs, depending on Oscillator Type).")
color  oscBullCol = input.color(#00BCD4, "Bull Color (osc > 0)", group = "Oscillator", tooltip = "Cyan family — extreme positive oscillator.")
color  oscBearCol = input.color(#800000, "Bear Color (osc < 0)", group = "Oscillator", tooltip = "Maroon family — extreme negative oscillator.")
color  oscNeutCol = input.color(#87CEEB, "Neutral Tint (mag ≈ 0)", group = "Oscillator", tooltip = "Light blue — weak signals blend toward this color.")

bool  showAxisLabels = input.bool(false, "Show Axis Markers",            group = "Display", tooltip = "Labels at -100, 0, +100 on Y and Z axes.")
bool  showEmoji      = input.bool(true, "Show Emoji Markers",            group = "Display", tooltip = "🏄‍♂ at momentum leading edge, ⛵ at oscillator leading edge. 🐳 (bull) or 🐋 (bear) at forecast leading edge when both middle-layer slopes agree.")

bool  showForecast     = input.bool(true,  "Show Slope Forecast",        group = "Forecast", tooltip = "Extrapolates each layer forward using its current slope, with exponential decay. Projects a ghost terrain into the future half of the box.")
int   forecastSlopeLen = input.int(4,      "Slope Lookback (bars)",      group = "Forecast", minval = 2, maxval = 50, tooltip = "How many past bars to compute the slope from. Shorter = more reactive, longer = smoother. Capped internally to Time Span to fit the ring buffer.")
float forecastDecay    = input.float(0.92, "Forecast Decay per Bar",     group = "Forecast", minval = 0.5, maxval = 1.0, step = 0.01, tooltip = "Each future bar the slope contribution multiplies by this factor. 1.0 = pure linear extrapolation, 0.9 = strong fade, 0.95 = gentle fade.")

bool   showDashboard = input.bool(true,   "Show Win-Rate Dashboard", group = "Dashboard", tooltip = "Tracks 🐳 / 🐋 confluence signals. Each signal is evaluated when the NEXT signal fires. Win = directional close-favorable OR Maximum Favorable Excursion between signals ≥ threshold (either qualifies).")
string dashPos       = input.string("Bottom Right", "Dashboard Position", options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group = "Dashboard")
int    atrLen        = input.int(14,      "ATR Length",                group = "Dashboard", minval = 2, maxval = 100, tooltip = "Lookback for ATR used to scale the win threshold. 14 = classic Wilder ATR.")
float  atrMult       = input.float(0.5,   "Win Threshold (× ATR)",     group = "Dashboard", minval = 0.1, maxval = 5.0, step = 0.1, tooltip = "If MFE between two successive signals reaches this multiple of ATR at the first signal's bar, that qualifies as a win — even if the directional close check fails.")
color  dashTextCol   = input.color(color.new(color.white, 10), "Dashboard Text",       group = "Dashboard")
color  dashBgCol     = input.color(color.new(color.black, 30), "Dashboard Background", group = "Dashboard")

bool  showFloorGrid = input.bool(true,  "Y=0 Floor Grid (dotted)",   group = "Wireframe", tooltip = "Dotted grid lines on the water surface (Y=0).")
bool  showBackGrid  = input.bool(false, "Back Wall Grid (dotted)",   group = "Wireframe", tooltip = "Dotted grid lines on the far Z wall (past side).")
bool  showSideGrid  = input.bool(false, "Side Wall Grid (dotted)",  group = "Wireframe", tooltip = "Dotted grid lines on the left X wall.")
int   gridStep      = input.int(25, "Grid Spacing",                 group = "Wireframe", minval = 10, maxval = 50)

color boxColor    = input.color(color.new(color.gray, 70),  "Box Wireframe (dotted)",   group = "Style")
color nowPlaneCol = input.color(color.new(color.white, 70), "X=0 Plane (dotted)",       group = "Style")
color yZeroEdge   = input.color(color.new(#64B5F6, 40),     "Y=0 Horizon (solid)",      group = "Style", tooltip = "The bright horizontal outline at the water surface — the one structural element that *should* read loudly.")
color axisLabelCol= input.color(color.new(color.white, 30), "Axis Markers",             group = "Style")
color gridColor   = input.color(color.new(color.white, 85), "Wireframe Grid (dotted)",  group = "Style")
color fogColor    = input.color(#1A1A2E,                    "Depth Fog Color",          group = "Style", tooltip = "Strip colors tint toward this as Z increases (far layers fade into atmospheric haze). Dark navy-violet reads well on both light and dark TradingView themes.")
float fogStrength = input.float(0.55, "Depth Fog Strength", group = "Style", minval = 0.0, maxval = 1.0, step = 0.05, tooltip = "How strongly far layers blend into fog color. 0 = no fog, 1 = far layers fully fogged. 0.55 = balanced atmosphere.")

//---------------------------------------------------------------------------------------------------------------------}
type Camera
    int anchorX
    float anchorY
    float cYaw
    float sYaw
    float cPit
    float sPit
    float sT
    float sA
    float sD

method project(Camera this, float x, float y, float z) =>
    float xs = x * this.sT
    float ys = y * this.sA
    float zs = z * this.sD
    float screenX = xs * this.cYaw - zs * this.sYaw
    float screenY = ys * this.cPit + (xs * this.sYaw + zs * this.cYaw) * this.sPit
    chart.point.from_index(this.anchorX + int(screenX), this.anchorY + screenY)


//---------------------------------------------------------------------------------------------------------------------}
float rsiRaw = momentumSrc == "MFI" ? ta.mfi(hlc3, rsiLen) : ta.rsi(close, rsiLen)

// ---- MOMENTUM TERRAIN (20 depth layers, HMA lengths from 3 → 60) ----
float _rH0  = ta.hma(rsiRaw, 3)
float _rH1  = ta.hma(rsiRaw, 4)
float _rH2  = ta.hma(rsiRaw, 5)
float _rH3  = ta.hma(rsiRaw, 6)
float _rH4  = ta.hma(rsiRaw, 8)
float _rH5  = ta.hma(rsiRaw, 10)
float _rH6  = ta.hma(rsiRaw, 12)
float _rH7  = ta.hma(rsiRaw, 14)
float _rH8  = ta.hma(rsiRaw, 17)
float _rH9  = ta.hma(rsiRaw, 20)
float _rH10 = ta.hma(rsiRaw, 23)
float _rH11 = ta.hma(rsiRaw, 26)
float _rH12 = ta.hma(rsiRaw, 30)
float _rH13 = ta.hma(rsiRaw, 34)
float _rH14 = ta.hma(rsiRaw, 38)
float _rH15 = ta.hma(rsiRaw, 42)
float _rH16 = ta.hma(rsiRaw, 46)
float _rH17 = ta.hma(rsiRaw, 50)
float _rH18 = ta.hma(rsiRaw, 55)
float _rH19 = ta.hma(rsiRaw, 60)

f_rsiCenter(float r) =>
    float raw = na(r) ? 50.0 : r
    math.max(-100.0, math.min(100.0, (raw - 50.0) * 2.0 * yAmp))

// Ring buffer must hold max(timeSpan+1, forecastSlopeLen+1) slots
int _bufSize = math.max(timeSpan + 1, forecastSlopeLen + 1)

var matrix<float> rsiTerrain = matrix.new<float>(20, _bufSize, 0.0)
int _rsiColIdx = bar_index % _bufSize
rsiTerrain.set(0,  _rsiColIdx, f_rsiCenter(_rH0))
rsiTerrain.set(1,  _rsiColIdx, f_rsiCenter(_rH1))
rsiTerrain.set(2,  _rsiColIdx, f_rsiCenter(_rH2))
rsiTerrain.set(3,  _rsiColIdx, f_rsiCenter(_rH3))
rsiTerrain.set(4,  _rsiColIdx, f_rsiCenter(_rH4))
rsiTerrain.set(5,  _rsiColIdx, f_rsiCenter(_rH5))
rsiTerrain.set(6,  _rsiColIdx, f_rsiCenter(_rH6))
rsiTerrain.set(7,  _rsiColIdx, f_rsiCenter(_rH7))
rsiTerrain.set(8,  _rsiColIdx, f_rsiCenter(_rH8))
rsiTerrain.set(9,  _rsiColIdx, f_rsiCenter(_rH9))
rsiTerrain.set(10, _rsiColIdx, f_rsiCenter(_rH10))
rsiTerrain.set(11, _rsiColIdx, f_rsiCenter(_rH11))
rsiTerrain.set(12, _rsiColIdx, f_rsiCenter(_rH12))
rsiTerrain.set(13, _rsiColIdx, f_rsiCenter(_rH13))
rsiTerrain.set(14, _rsiColIdx, f_rsiCenter(_rH14))
rsiTerrain.set(15, _rsiColIdx, f_rsiCenter(_rH15))
rsiTerrain.set(16, _rsiColIdx, f_rsiCenter(_rH16))
rsiTerrain.set(17, _rsiColIdx, f_rsiCenter(_rH17))
rsiTerrain.set(18, _rsiColIdx, f_rsiCenter(_rH18))
rsiTerrain.set(19, _rsiColIdx, f_rsiCenter(_rH19))

// Momentum gradient: yellow @ 0 → green @ +50/+100 ; yellow @ 0 → red @ -50/-100
f_rsiColor(float v) =>
    v >= 50.0 ? #00E676 : v <= -50.0 ? #FF5252 : v >= 0.0 ? color.from_gradient(v / 50.0, 0, 1, #FFEB3B, #00E676) : color.from_gradient((-v) / 50.0, 0, 1, #FFEB3B, #FF5252)

// ADX (signed via DI direction)
[_pdi, _mdi, adxRaw] = ta.dmi(adxLen, adxLen)
float adxDir    = _pdi >= _mdi ? 1.0 : -1.0
float adxSigned = adxRaw * adxDir

// ---- ADX TERRAIN (12 HMA layers of signed ADX) — fills the carpet when oscType = "ADX" ----
float _aH0  = ta.hma(adxSigned, 3)
float _aH1  = ta.hma(adxSigned, 5)
float _aH2  = ta.hma(adxSigned, 7)
float _aH3  = ta.hma(adxSigned, 10)
float _aH4  = ta.hma(adxSigned, 14)
float _aH5  = ta.hma(adxSigned, 19)
float _aH6  = ta.hma(adxSigned, 25)
float _aH7  = ta.hma(adxSigned, 32)
float _aH8  = ta.hma(adxSigned, 40)
float _aH9  = ta.hma(adxSigned, 49)
float _aH10 = ta.hma(adxSigned, 59)
float _aH11 = ta.hma(adxSigned, 70)

// ---- Hull-VWMA TERRAIN (12 depth layers) ----
float vwmaSrc = ta.vwma(close, vwmaLen)

float _hma0  = ta.hma(vwmaSrc, 3)
float _hma1  = ta.hma(vwmaSrc, 5)
float _hma2  = ta.hma(vwmaSrc, 7)
float _hma3  = ta.hma(vwmaSrc, 10)
float _hma4  = ta.hma(vwmaSrc, 14)
float _hma5  = ta.hma(vwmaSrc, 19)
float _hma6  = ta.hma(vwmaSrc, 25)
float _hma7  = ta.hma(vwmaSrc, 32)
float _hma8  = ta.hma(vwmaSrc, 40)
float _hma9  = ta.hma(vwmaSrc, 49)
float _hma10 = ta.hma(vwmaSrc, 59)
float _hma11 = ta.hma(vwmaSrc, 70)

f_slope(float hmaNow, float hmaPrev) =>
    float raw = not na(hmaPrev) and hmaPrev != 0.0 ? (hmaNow - hmaPrev) / hmaPrev * 100.0 * oscScale : 0.0
    math.max(-100.0, math.min(100.0, raw))

f_clampAdx(float v) => math.max(-100.0, math.min(100.0, nz(v)))

// Depth fog: blend base color toward fogColor based on Z position.
// Z = -100 (near) → 0 fog.  Z = +100 (far) → fogStrength fog.
f_depthTint(color base, float zPos) =>
    float depthFactor = (zPos + 100.0) / 200.0
    color.from_gradient(depthFactor * fogStrength, 0.0, 1.0, base, fogColor)

float osc0  = f_slope(_hma0,  _hma0[2])
float osc1  = f_slope(_hma1,  _hma1[2])
float osc2  = f_slope(_hma2,  _hma2[2])
float osc3  = f_slope(_hma3,  _hma3[2])
float osc4  = f_slope(_hma4,  _hma4[2])
float osc5  = f_slope(_hma5,  _hma5[2])
float osc6  = f_slope(_hma6,  _hma6[2])
float osc7  = f_slope(_hma7,  _hma7[2])
float osc8  = f_slope(_hma8,  _hma8[2])
float osc9  = f_slope(_hma9,  _hma9[2])
float osc10 = f_slope(_hma10, _hma10[2])
float osc11 = f_slope(_hma11, _hma11[2])

var matrix<float> ampTerrain = matrix.new<float>(12, _bufSize, 0.0)
int _colIdx = bar_index % _bufSize
bool _isVwma = oscType == "Hull-VWMA"
ampTerrain.set(0,  _colIdx, _isVwma ? osc0  : f_clampAdx(_aH0))
ampTerrain.set(1,  _colIdx, _isVwma ? osc1  : f_clampAdx(_aH1))
ampTerrain.set(2,  _colIdx, _isVwma ? osc2  : f_clampAdx(_aH2))
ampTerrain.set(3,  _colIdx, _isVwma ? osc3  : f_clampAdx(_aH3))
ampTerrain.set(4,  _colIdx, _isVwma ? osc4  : f_clampAdx(_aH4))
ampTerrain.set(5,  _colIdx, _isVwma ? osc5  : f_clampAdx(_aH5))
ampTerrain.set(6,  _colIdx, _isVwma ? osc6  : f_clampAdx(_aH6))
ampTerrain.set(7,  _colIdx, _isVwma ? osc7  : f_clampAdx(_aH7))
ampTerrain.set(8,  _colIdx, _isVwma ? osc8  : f_clampAdx(_aH8))
ampTerrain.set(9,  _colIdx, _isVwma ? osc9  : f_clampAdx(_aH9))
ampTerrain.set(10, _colIdx, _isVwma ? osc10 : f_clampAdx(_aH10))
ampTerrain.set(11, _colIdx, _isVwma ? osc11 : f_clampAdx(_aH11))

// Invisible anchors force the pane to always span a fixed Y range — box size stays constant.
plot( 50, color = color.new(color.black, 100), display = display.all, title = "pane anchor top")
plot(-50, color = color.new(color.black, 100), display = display.all, title = "pane anchor bottom")

// ---- Win-rate signal tracking (per-bar, matches emoji confluence logic) ----
// Middle-layer momentum (index 9 → HMA 20) and oscillator (index 5 → HMA 19) slopes.
float _dashRsiMid     = f_rsiCenter(_rH9)
float _dashRsiMidPast = f_rsiCenter(_rH9[forecastSlopeLen])
float _dashRsiSlope   = (_dashRsiMid - _dashRsiMidPast) / forecastSlopeLen

float _dashOscMid     = _isVwma ? osc5                      : f_clampAdx(_aH5)
float _dashOscMidPast = _isVwma ? osc5[forecastSlopeLen]    : f_clampAdx(_aH5[forecastSlopeLen])
float _dashOscSlope   = (_dashOscMid - _dashOscMidPast) / forecastSlopeLen

bool _dashBullConf = _dashRsiSlope > 0 and _dashOscSlope > 0
bool _dashBearConf = _dashRsiSlope < 0 and _dashOscSlope < 0

// Entry = first bar of a new confluence state (transition from non-confluence).
// Bool historical refs return na on bar 0; `not na` propagates na which reads as false in bool context → no first-bar false trigger.
bool _dashBullEntry = _dashBullConf and not _dashBullConf[1]
bool _dashBearEntry = _dashBearConf and not _dashBearConf[1]

// ATR used for volatility-scaled win threshold
float _atrSeries = ta.atr(atrLen)

// ---- Next-signal evaluation model ----
// Each signal (bull or bear) is held pending until the NEXT signal fires (either direction).
// At that moment we judge the previous signal:
//   direction-win = closed favorable vs its entry
//   MFE-win       = running extreme-favorable move between signals ≥ atrMult × ATR at entry bar
//   either qualifies → win
// The most recent signal is unresolved until a new one arrives.

var int   _prevSigDir    = 0      // 0 = none, 1 = bull, -1 = bear
var float _prevSigEntry  = na
var float _prevSigATR    = na
var float _runMaxSince   = na     // running max high since prev signal (inclusive)
var float _runMinSince   = na     // running min low since prev signal (inclusive)

var int dashBullSignals = 0
var int dashBearSignals = 0
var int dashBullWins    = 0
var int dashBearWins    = 0

// 1) Update running extrema while a signal is pending (must happen every bar, not only on new signals)
if _prevSigDir != 0
    _runMaxSince := math.max(nz(_runMaxSince, high), high)
    _runMinSince := math.min(nz(_runMinSince, low),  low)

// 2) On a new signal: resolve the previous one (if any), then start tracking the new one
bool _newSig = _dashBullEntry or _dashBearEntry
if _newSig
    if _prevSigDir != 0
        bool  _dirWon = _prevSigDir == 1 ? close > _prevSigEntry : close < _prevSigEntry
        float _mfe    = _prevSigDir == 1 ? _runMaxSince - _prevSigEntry : _prevSigEntry - _runMinSince
        bool  _mfeWon = _prevSigATR > 0 and _mfe >= atrMult * _prevSigATR
        bool  _won    = _dirWon or _mfeWon
        if _prevSigDir == 1
            dashBullSignals := dashBullSignals + 1
            if _won
                dashBullWins := dashBullWins + 1
        else
            dashBearSignals := dashBearSignals + 1
            if _won
                dashBearWins := dashBearWins + 1
    // Start tracking the new signal (reset running extrema to this bar's high/low)
    _prevSigDir   := _dashBullEntry ? 1 : -1
    _prevSigEntry := close
    _prevSigATR   := _atrSeries
    _runMaxSince  := high
    _runMinSince  := low

if barstate.islast
    for p in polyline.all
        p.delete()
    for ln in line.all
        ln.delete()
    for lbl in label.all
        lbl.delete()

    float _yawRad = yawDeg * math.pi / 180
    float _pitRad = pitchDeg * math.pi / 180

    float _cYaw = math.cos(_yawRad)
    float _sYaw = math.sin(_yawRad)
    float _cPit = math.cos(_pitRad)
    float _sPit = math.sin(_pitRad)

    Camera cam = Camera.new(
         anchorX = bar_index + offsetX,
         anchorY = 0.0 + offsetY,
         cYaw    = _cYaw,
         sYaw    = _sYaw,
         cPit    = _cPit,
         sPit    = _sPit,
         sT      = sTime,
         sA      = sAlt,
         sD      = sDepth
     )

    float T  = timeSpan
    int   Ti = timeSpan

    // ---- Box wireframe — 12 edges, DOTTED ----
    line.new(cam.project(-T, -100, -100), cam.project( T, -100, -100), color = boxColor, style = line.style_dotted)
    line.new(cam.project( T, -100, -100), cam.project( T, -100,  100), color = boxColor, style = line.style_dotted)
    line.new(cam.project( T, -100,  100), cam.project(-T, -100,  100), color = boxColor, style = line.style_dotted)
    line.new(cam.project(-T, -100,  100), cam.project(-T, -100, -100), color = boxColor, style = line.style_dotted)
    line.new(cam.project(-T,  100, -100), cam.project( T,  100, -100), color = boxColor, style = line.style_dotted)
    line.new(cam.project( T,  100, -100), cam.project( T,  100,  100), color = boxColor, style = line.style_dotted)
    line.new(cam.project( T,  100,  100), cam.project(-T,  100,  100), color = boxColor, style = line.style_dotted)
    line.new(cam.project(-T,  100,  100), cam.project(-T,  100, -100), color = boxColor, style = line.style_dotted)
    line.new(cam.project(-T, -100, -100), cam.project(-T,  100, -100), color = boxColor, style = line.style_dotted)
    line.new(cam.project( T, -100, -100), cam.project( T,  100, -100), color = boxColor, style = line.style_dotted)
    line.new(cam.project( T, -100,  100), cam.project( T,  100,  100), color = boxColor, style = line.style_dotted)
    line.new(cam.project(-T, -100,  100), cam.project(-T,  100,  100), color = boxColor, style = line.style_dotted)

    // ---- X=0 plane (past/future divider), DOTTED ----
    line.new(cam.project(0, -100, -100), cam.project(0,  100, -100), color = nowPlaneCol, style = line.style_dotted)
    line.new(cam.project(0,  100, -100), cam.project(0,  100,  100), color = nowPlaneCol, style = line.style_dotted)
    line.new(cam.project(0,  100,  100), cam.project(0, -100,  100), color = nowPlaneCol, style = line.style_dotted)
    line.new(cam.project(0, -100,  100), cam.project(0, -100, -100), color = nowPlaneCol, style = line.style_dotted)

    // ---- Y=0 horizon — SOLID, bolder (the tide line) ----
    array<chart.point> yZero = array.new<chart.point>()
    yZero.push(cam.project(-T, 0, -100))
    yZero.push(cam.project( T, 0, -100))
    yZero.push(cam.project( T, 0,  100))
    yZero.push(cam.project(-T, 0,  100))
    polyline.new(yZero, closed = true, fill_color = color.new(#000000, 100), line_color = yZeroEdge, line_width = 2)

    // ---- Dotted wireframe grids ----
    if showFloorGrid
        for gz = -100 to 100 by gridStep
            line.new(cam.project(-T, 0, gz), cam.project(T, 0, gz), color = gridColor, style = line.style_dotted)
        for gx = -Ti to Ti by gridStep
            line.new(cam.project(gx, 0, -100), cam.project(gx, 0, 100), color = gridColor, style = line.style_dotted)
    if showBackGrid
        for gy = -100 to 100 by gridStep
            line.new(cam.project(-T, gy, 100), cam.project(T, gy, 100), color = gridColor, style = line.style_dotted)
        for gx = -Ti to Ti by gridStep
            line.new(cam.project(gx, -100, 100), cam.project(gx, 100, 100), color = gridColor, style = line.style_dotted)
    if showSideGrid
        for gy = -100 to 100 by gridStep
            line.new(cam.project(-T, gy, -100), cam.project(-T, gy, 100), color = gridColor, style = line.style_dotted)
        for gz = -100 to 100 by gridStep
            line.new(cam.project(-T, -100, gz), cam.project(-T, 100, gz), color = gridColor, style = line.style_dotted)

    // ---- MOMENTUM TERRAIN: 20 depth layers, 19 seamless fog-tinted strips ----
    int rsiHead   = bar_index % _bufSize
    int rsiOldest = (rsiHead - (timeSpan - 1) + _bufSize * 10) % _bufSize
    float zStepR  = 200.0 / 19.0
    for d = 0 to 18
        array<chart.point> terrR = array.new<chart.point>()
        float zd1 = -100.0 + d       * zStepR
        float zd2 = -100.0 + (d + 1) * zStepR
        float midZ = (zd1 + zd2) / 2.0
        for tt = 0 to timeSpan - 1
            int hxi = (rsiOldest + tt) % _bufSize
            terrR.push(cam.project(tt - timeSpan, rsiTerrain.get(d, hxi), zd1))
        for tt = timeSpan - 1 to 0
            int hxi = (rsiOldest + tt) % _bufSize
            terrR.push(cam.project(tt - timeSpan, rsiTerrain.get(d + 1, hxi), zd2))
        int midT  = timeSpan / 2
        int midHx = (rsiOldest + midT) % _bufSize
        float avgR = (rsiTerrain.get(d, midHx) + rsiTerrain.get(d + 1, midHx)) / 2.0
        color rCol    = f_rsiColor(avgR)
        color rColFog = f_depthTint(rCol, midZ)
        color rFillC  = color.new(rColFog, 72)                 // fill (carpet)
        color rLineC  = color.new(rColFog, 50)                 // brighter outline for dotted wave lines
        polyline.new(terrR, closed = true, fill_color = rFillC, line_color = rLineC, line_width = 1, line_style = line.style_dotted)

    // ---- Oscillator carpet (past): 12 layers, 11 seamless fog-tinted strips ----
    if showOsc
        int head   = bar_index % _bufSize
        int oldest = (head - (timeSpan - 1) + _bufSize * 10) % _bufSize
        float zStep = 200.0 / 11.0
        for d = 0 to 10
            array<chart.point> terr = array.new<chart.point>()
            float zd1 = -100.0 + d       * zStep
            float zd2 = -100.0 + (d + 1) * zStep
            float midZ = (zd1 + zd2) / 2.0
            for tt = 0 to timeSpan - 1
                int hxi = (oldest + tt) % _bufSize
                float amp = ampTerrain.get(d, hxi)
                terr.push(cam.project(tt - timeSpan, amp, zd1))
            for tt = timeSpan - 1 to 0
                int hxi = (oldest + tt) % _bufSize
                float amp = ampTerrain.get(d + 1, hxi)
                terr.push(cam.project(tt - timeSpan, amp, zd2))
            int midT = timeSpan / 2
            int midHx = (oldest + midT) % _bufSize
            float midAmpD   = ampTerrain.get(d, midHx)
            float midAmpD1  = ampTerrain.get(d + 1, midHx)
            float avgAmp    = (midAmpD + midAmpD1) / 2.0
            float magAmp    = (math.abs(midAmpD) + math.abs(midAmpD1)) / 2.0
            color sideCol   = avgAmp >= 0 ? oscBullCol : oscBearCol
            color baseCol   = color.from_gradient(math.min(1.0, magAmp / 50.0), 0, 1, oscNeutCol, sideCol)
            color baseFog   = f_depthTint(baseCol, midZ)
            int   stripA    = int(math.max(60.0, 88.0 - magAmp * 0.3))   // strong=60, weak=88
            int   lineA     = int(math.max(38.0, stripA - 22))            // brighter outline for dotted wave lines
            color stripFill = color.new(baseFog, stripA)
            color stripLine = color.new(baseFog, lineA)
            polyline.new(terr, closed = true, fill_color = stripFill, line_color = stripLine, line_width = 1, line_style = line.style_dotted)

    // ---- Axis markers: -100, 0, +100 on Y and Z ----
    if showAxisLabels
        chart.point yPlus  = cam.project(-T,  100, 100)
        chart.point yZeroL = cam.project(-T,    0, 100)
        chart.point yMinus = cam.project(-T, -100, 100)
        label.new(yPlus.index,  yPlus.price,  "Y +100", color = #00000000, textcolor = axisLabelCol, style = label.style_label_right, size = size.tiny)
        label.new(yZeroL.index, yZeroL.price, "Y 0",    color = #00000000, textcolor = axisLabelCol, style = label.style_label_right, size = size.tiny)
        label.new(yMinus.index, yMinus.price, "Y -100", color = #00000000, textcolor = axisLabelCol, style = label.style_label_right, size = size.tiny)
        chart.point zPlus  = cam.project(-T, -100,  100)
        chart.point zZeroZ = cam.project(-T, -100,    0)
        chart.point zMinus = cam.project(-T, -100, -100)
        label.new(zPlus.index,  zPlus.price,  "Z +100", color = #00000000, textcolor = axisLabelCol, style = label.style_label_left, size = size.tiny)
        label.new(zZeroZ.index, zZeroZ.price, "Z 0",    color = #00000000, textcolor = axisLabelCol, style = label.style_label_left, size = size.tiny)
        label.new(zMinus.index, zMinus.price, "Z -100", color = #00000000, textcolor = axisLabelCol, style = label.style_label_left, size = size.tiny)

    // ---- FORECAST TERRAIN: slope-extrapolate each HMA layer into the future half ----
    int   _fcCurrIdx  = bar_index % _bufSize
    int   _fcSlopeLen = math.min(forecastSlopeLen, timeSpan)
    int   _fcPastIdx  = (_fcCurrIdx - _fcSlopeLen + _bufSize * 10) % _bufSize

    if showForecast
        // Momentum forecast (19 seamless fog-tinted strips)
        for d = 0 to 18
            float _currD  = rsiTerrain.get(d,     _fcCurrIdx)
            float _pastD  = rsiTerrain.get(d,     _fcPastIdx)
            float _currD1 = rsiTerrain.get(d + 1, _fcCurrIdx)
            float _pastD1 = rsiTerrain.get(d + 1, _fcPastIdx)
            float _slopeD  = (_currD  - _pastD)  / _fcSlopeLen
            float _slopeD1 = (_currD1 - _pastD1) / _fcSlopeLen
            float zd1 = -100.0 + d       * zStepR
            float zd2 = -100.0 + (d + 1) * zStepR
            float midZ = (zd1 + zd2) / 2.0
            array<chart.point> fcR = array.new<chart.point>()
            for ft = 0 to timeSpan
                float vd = math.max(-100.0, math.min(100.0, _currD + _slopeD * ft * math.pow(forecastDecay, ft)))
                fcR.push(cam.project(ft, vd, zd1))
            for ft = timeSpan to 0
                float vd = math.max(-100.0, math.min(100.0, _currD1 + _slopeD1 * ft * math.pow(forecastDecay, ft)))
                fcR.push(cam.project(ft, vd, zd2))
            color rcC      = f_rsiColor((_currD + _currD1) / 2.0)
            color rcCFog   = f_depthTint(rcC, midZ)
            color fcR_Fill = color.new(rcCFog, 85)             // ghostlier fill
            color fcR_Line = color.new(rcCFog, 65)             // brighter dotted outline
            polyline.new(fcR, closed = true, fill_color = fcR_Fill, line_color = fcR_Line, line_width = 1, line_style = line.style_dotted)

        // Oscillator forecast (11 seamless fog-tinted strips)
        float zStepV = 200.0 / 11.0
        for d = 0 to 10
            float _currD  = ampTerrain.get(d,     _fcCurrIdx)
            float _pastD  = ampTerrain.get(d,     _fcPastIdx)
            float _currD1 = ampTerrain.get(d + 1, _fcCurrIdx)
            float _pastD1 = ampTerrain.get(d + 1, _fcPastIdx)
            float _slopeD  = (_currD  - _pastD)  / _fcSlopeLen
            float _slopeD1 = (_currD1 - _pastD1) / _fcSlopeLen
            float zd1 = -100.0 + d       * zStepV
            float zd2 = -100.0 + (d + 1) * zStepV
            float midZ = (zd1 + zd2) / 2.0
            array<chart.point> fcV = array.new<chart.point>()
            for ft = 0 to timeSpan
                float vd = math.max(-100.0, math.min(100.0, _currD + _slopeD * ft * math.pow(forecastDecay, ft)))
                fcV.push(cam.project(ft, vd, zd1))
            for ft = timeSpan to 0
                float vd = math.max(-100.0, math.min(100.0, _currD1 + _slopeD1 * ft * math.pow(forecastDecay, ft)))
                fcV.push(cam.project(ft, vd, zd2))
            float _avgMag = (math.abs(_currD) + math.abs(_currD1)) / 2.0
            float _avgV   = (_currD + _currD1) / 2.0
            color _sideC  = _avgV >= 0 ? oscBullCol : oscBearCol
            color _baseC   = color.from_gradient(math.min(1.0, _avgMag / 50.0), 0, 1, oscNeutCol, _sideC)
            color _baseF   = f_depthTint(_baseC, midZ)
            color fcV_Fill = color.new(_baseF, 88)             // ghostliest fill
            color fcV_Line = color.new(_baseF, 70)             // brighter dotted outline
            polyline.new(fcV, closed = true, fill_color = fcV_Fill, line_color = fcV_Line, line_width = 1, line_style = line.style_dotted)

    // ---- Emoji markers (riders + whales) ----
    if showEmoji
        float _rsiMid    = rsiTerrain.get(9, _fcCurrIdx)
        float _rsiPast   = rsiTerrain.get(9, _fcPastIdx)
        float _rsiSlope  = (_rsiMid - _rsiPast) / _fcSlopeLen

        float _secondMid   = ampTerrain.get(5, _fcCurrIdx)
        float _secondPast  = ampTerrain.get(5, _fcPastIdx)
        float _secondSlope = (_secondMid - _secondPast) / _fcSlopeLen

        chart.point _rsiPt = cam.project(0, _rsiMid, 0)
        label.new(_rsiPt.index, _rsiPt.price, "🏄‍♂", color = #00000000, textcolor = color.white, style = label.style_label_center, size = size.large)

        chart.point _vwmaPt = cam.project(0, _secondMid, 0)
        label.new(_vwmaPt.index, _vwmaPt.price, "⛵", color = #00000000, textcolor = color.white, style = label.style_label_center, size = size.large)

        bool _bullConfluence = _rsiSlope > 0 and _secondSlope > 0
        bool _bearConfluence = _rsiSlope < 0 and _secondSlope < 0
        if _bullConfluence or _bearConfluence
            string _whaleEmoji = _bullConfluence ? "🐳" : "🐋"
            float  _rsiEndY    = math.max(-100.0, math.min(100.0, _rsiMid + _rsiSlope * timeSpan * math.pow(forecastDecay, timeSpan)))
            chart.point _fcPt = cam.project(timeSpan, _rsiEndY, 0)
            label.new(_fcPt.index, _fcPt.price, _whaleEmoji, color = #00000000, textcolor = color.white, style = label.style_label_center, size = size.huge)

    // ---- Win-rate dashboard ----
    // ---- Win-rate dashboard ----
    if showDashboard
        string _posStr = dashPos == "Top Right"     ? position.top_right     :
                         dashPos == "Top Left"      ? position.top_left      :
                         dashPos == "Middle Right"  ? position.middle_right  :
                         dashPos == "Middle Left"   ? position.middle_left   :
                         dashPos == "Bottom Left"   ? position.bottom_left   :
                                                      position.bottom_right
        var table dashTbl = table.new(_posStr, 3, 6, border_color = color.new(color.gray, 50), border_width = 1, frame_color = color.new(color.gray, 30), frame_width = 1)

        float _bullRate = dashBullSignals > 0 ? float(dashBullWins) / float(dashBullSignals) * 100.0 : 0.0
        float _bearRate = dashBearSignals > 0 ? float(dashBearWins) / float(dashBearSignals) * 100.0 : 0.0
        color _bullRateCol = _bullRate >= 60 ? #00E676 : _bullRate >= 40 ? #FFEB3B : #FF5252
        color _bearRateCol = _bearRate >= 60 ? #00E676 : _bearRate >= 40 ? #FFEB3B : #FF5252

        // Row 0 — header (merged across all 3 cols)
        dashTbl.cell(0, 0, "MFD Confluence · Win Rate", text_color = dashTextCol, bgcolor = color.new(color.black, 10), text_size = size.small, text_halign = text.align_center)
        dashTbl.merge_cells(0, 0, 2, 0)

        // Row 1 — column headers
        dashTbl.cell(0, 1, "", bgcolor = color.new(color.black, 50))
        dashTbl.cell(1, 1, "🐳 Bull", text_color = oscBullCol, bgcolor = color.new(color.black, 40), text_size = size.small, text_halign = text.align_center)
        dashTbl.cell(2, 1, "🐋 Bear", text_color = oscBearCol, bgcolor = color.new(color.black, 40), text_size = size.small, text_halign = text.align_center)

        // Row 2 — total signals
        dashTbl.cell(0, 2, "Signals", text_color = dashTextCol, bgcolor = dashBgCol, text_size = size.tiny, text_halign = text.align_left)
        dashTbl.cell(1, 2, str.tostring(dashBullSignals), text_color = dashTextCol, bgcolor = dashBgCol, text_size = size.small, text_halign = text.align_center)
        dashTbl.cell(2, 2, str.tostring(dashBearSignals), text_color = dashTextCol, bgcolor = dashBgCol, text_size = size.small, text_halign = text.align_center)

        // Row 3 — wins
        dashTbl.cell(0, 3, "Wins", text_color = dashTextCol, bgcolor = dashBgCol, text_size = size.tiny, text_halign = text.align_left)
        dashTbl.cell(1, 3, str.tostring(dashBullWins), text_color = dashTextCol, bgcolor = dashBgCol, text_size = size.small, text_halign = text.align_center)
        dashTbl.cell(2, 3, str.tostring(dashBearWins), text_color = dashTextCol, bgcolor = dashBgCol, text_size = size.small, text_halign = text.align_center)

        // Row 4 — win rate (colored by threshold)
        dashTbl.cell(0, 4, "Win Rate", text_color = dashTextCol, bgcolor = dashBgCol, text_size = size.tiny, text_halign = text.align_left)
        dashTbl.cell(1, 4, dashBullSignals > 0 ? str.tostring(_bullRate, "#.#") + "%" : "—", text_color = _bullRateCol, bgcolor = dashBgCol, text_size = size.small, text_halign = text.align_center)
        dashTbl.cell(2, 4, dashBearSignals > 0 ? str.tostring(_bearRate, "#.#") + "%" : "—", text_color = _bearRateCol, bgcolor = dashBgCol, text_size = size.small, text_halign = text.align_center)

        // Row 5 — config footer (merged) 
        dashTbl.cell(0, 5, "Next-signal eval · Dir or MFE ≥ " + str.tostring(atrMult, "#.##") + "×ATR(" + str.tostring(atrLen) + ")", text_color = color.new(dashTextCol, 50), bgcolor = color.new(color.black, 20), text_size = size.tiny, text_halign = text.align_center)
        dashTbl.merge_cells(0, 5, 2, 5)

//---------------------------------------------------------------------------------------------------------------------}
````
