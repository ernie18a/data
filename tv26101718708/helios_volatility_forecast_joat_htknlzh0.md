# Helios Volatility Forecast [JOAT]

- url: https://www.tradingview.com/script/HtKnlZh0-Helios-Volatility-Forecast-JOAT/
- type: indicator
- pine_id: PUB;34cb159f69494f3eb7c53bf6568a0215
- version: 1.0

## Description

[b]Helios Volatility Forecast [JOAT][/b]

Helios Volatility Forecast is a Yang-Zhang volatility estimator with regime classification, a volatility cone (historical percentile bands), an HMA-smoothed forecast line, and a position-size suggestion. Volatility is classified into four regimes (LOW / NORMAL / ELEVATED / EXTREME) by percentile rank against its own history. Cross-pane elements paint a soft regime tint and a position-multiplier suggestion onto the price chart.

[image]https://www.tradingview.com/x/gsCilglr/[/image]

[b]What makes it different[/b]
[list]
[*] Most volatility indicators use a simple close-to-close standard deviation, which discards intraday range information and ignores overnight gaps. The Yang-Zhang estimator combines four components — overnight close-to-open variance, intraday open-to-close variance, and a Rogers-Satchell range term — into a single estimator that is more accurate than close-to-close for instruments that gap.
[*] A 4-band volatility cone (5th, 25th, 50th, 75th, 95th percentile of the past 100 bars) is plotted around the current volatility, with gradient fills bracketing tails and the interquartile range.
[*] A 4-regime classifier (LOW / NORMAL / ELEVATED / EXTREME by percentile thresholds at 25, 65, 90) drives a cross-pane tint on the price chart and a numeric position-size multiplier suggestion. The suggestion scales inversely with realized vol — wider sizes in low-vol regimes, halved sizes in extreme-vol regimes.
[*] An HMA forecast line projects the smoothed vol trajectory ahead. Forecast-crossing-realized alerts fire when expansion or contraction is imminent.
[/list]

[b]How it works[/b]
[list=1]
[*] Yang-Zhang formula combines overnight return, intraday return, and Rogers-Satchell range term, weighted by k = 0.34 / (1.34 + (len + 1) / (len - 1)).
[*] Percentile rank of sigma_yz over a 100-bar history equals vol_pct.
[*] Regime classification: LOW below 25, NORMAL 25 to 65, ELEVATED 65 to 90, EXTREME above 90.
[*] HMA of sigma_yz equals the forecast. Forecast direction equals the sign of (forecast minus current).
[*] Position-size multiplier equals clamp(1.5 minus vol_pct / 100, 0.3, 1.5).
[*] Vol-of-vol (stdev of recent realized vol) feeds a regime stickiness indicator.
[/list]

[b]Reading the chart[/b]
[list]
[*] [b]In-pane[/b]: regime-tinted volatility line (vivid mint for LOW, neutral white for NORMAL, amber for ELEVATED, vivid red for EXTREME), HMA forecast line with direction-color flow, five vol-cone percentile lines.
[*] [b]Cross-pane[/b]: soft regime tint background on the price chart, plus a Size x0.50 EXTREME vol label updating each bar.
[*] A vol-of-vol panel as a sub-strip at the top of the pane.
[*] Five right-edge cone percentile labels (p5 / p25 / p50 / p75 / p95).
[*] A current-vol percentile rank label.
[*] Regime change timeline labels on the price chart at each regime transition.
[*] Cross-pane vol-cone touch markers when vol crosses p95 (breakout) or p5 (contraction).
[*] A regime stickiness indicator (how long the regime has been in its current state).
[*] Forward expected-range lines on the price chart (close plus or minus forecast times ATR scalar).
[/list]

[b]Signals[/b]
[list]
[*] Regime up / down (any percentile-bucket transition)
[*] Extreme vol entry
[*] Low vol entry
[*] Vol breakout (sigma crosses above p95 of its own history)
[*] Vol contract (sigma crosses below p5)
[*] Vol Z-shock up / down (when vol z-score exceeds plus or minus 2)
[*] Forecast cross up / down (forecast vs realized)
[/list]
All gated on barstate.isconfirmed or barstate.ishistory. No future references. No lookahead_on.

[b]Inputs[/b]
[list]
[*] [b]Volatility[/b]: Yang-Zhang window, regime percentile lookback, forecast HMA length.
[*] [b]Visual[/b]: bullish (low vol) color, bearish (extreme vol) color, elevated (amber) color, cone toggle, forecast toggle, cross-pane candles toggle, regime pulse toggle.
[*] [b]Dashboard[/b]: position, size.
[/list]

[b]How traders use this[/b]
[list]
[*] [b]Position sizing[/b]: scale entries inversely with the regime. Full size in LOW, default in NORMAL, half in ELEVATED, third in EXTREME. The multiplier label provides the suggested factor.
[*] [b]Volatility breakouts[/b]: vol crossing above p95 historically precedes large directional moves. Tighten trailing stops or reduce holding time.
[*] [b]Volatility contraction[/b]: vol crossing below p5 historically precedes range / chop. Reduce directional bias. Consider mean-reversion strategies.
[*] [b]Regime-aware stops[/b]: in ELEVATED or EXTREME regimes, ATR-based stops should be wider. In LOW regimes, tighter. The pos-mult label codifies this implicitly.
[/list]

[b]Limitations[/b]
[list]
[*] Yang-Zhang assumes log-normal returns and lognormality breaks down during fat-tail events (it under-estimates vol in true crash regimes).
[*] Percentile classification needs sufficient history. The default 100-bar lookback can be lengthened for stable instruments.
[*] The position-size multiplier is a heuristic, not a portfolio-management recommendation. Combine with your own risk-management framework.
[*] The HMA forecast lags slightly behind real-time changes. Treat as smoothed trend, not pinpoint prediction.
[/list]

[b]Compatibility[/b]
Pine Script v6 open-source indicator (pane plus cross-pane). Any symbol, any timeframe. Cross-pane elements use force_overlay=true. No request.security calls.

[b]Defaults[/b]
20-bar Yang-Zhang window, 100-bar regime lookback, 5-bar HMA forecast, mint / red / amber palette, top-right medium dashboard.

[b]Credits[/b]
[list]
[*] Yang-Zhang estimator from D. Yang and Q. Zhang, [i]Drift-Independent Volatility Estimation Based on High, Low, Open, and Close Prices[/i], Journal of Business (2000).
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
// ════════════════════════════════════════════════════════════════════
//   JOAT — Helios Volatility Forecast [JOAT]
//   Author : Jack Of All Trades (@JackOfAllTrades)
//   Stack  : Pine Script v6, pane (overlay=false)
// ════════════════════════════════════════════════════════════════════
//
//   CONCEPT
//   -------
//   Institutional-grade volatility intelligence engine that surfaces
//   four orthogonal volatility primitives in a single pane:
//
//     1. Yang-Zhang volatility — minimum-variance OHLC estimator that
//        decomposes total realised volatility into the overnight gap
//        variance, the open-to-close variance, and the Rogers-Satchell
//        intraday component. Strictly dominates Parkinson, Garman-Klass
//        and close-to-close estimators in the presence of jumps and
//        drift, and converges with substantially fewer observations.
//
//     2. Percentile regime classifier — current Yang-Zhang vol is rank-
//        normalised against a rolling window producing a 4-tier regime
//        (LOW / NORMAL / ELEVATED / EXTREME) with hard boundaries at
//        the 25th / 65th / 90th percentile.
//
//     3. Vol cone — five percentile lines (5/25/50/75/95) are plotted
//        as a horizontal "cone" describing the empirical distribution
//        of realised vol over the lookback. Tail fills tint vivid;
//        the interquartile band fills neutral.
//
//     4. HMA-smoothed forecast — a short Hull moving average projects
//        the immediate vol trajectory. Direction is reported as
//        EXPANDING / CONTRACTING / STABLE in the dashboard.
//
//   A position-size multiplier is derived inversely from the percentile
//   rank so traders can scale exposure with the regime: vol low =
//   bigger size, vol extreme = smaller size, clamped to [0.3, 1.5].
//
//   VISUAL
//   ------
//   Regime-tinted volatility line, gradient-filled cone bands, dotted
//   percentile rails, HMA-circle forecast line, regime-transition
//   bgcolor pulses, cross-pane iridescent candle recolour and a 13-row
//   institutional dashboard with regime-tinted cells. Cross-pane
//   regime timeline, vol breach markers, position-size suggestion and
//   expected next-bar range are projected onto the price chart via
//   force_overlay so traders see the vol context without switching
//   panes.
//
// ════════════════════════════════════════════════════════════════════
indicator("Helios Volatility Forecast [JOAT]", "HVF [JOAT]", overlay=false, explicit_plot_zorder=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ════════════════════════════════════════════════════════════════════
// INPUTS
// ════════════════════════════════════════════════════════════════════
g_vol    = "Volatility"
g_vis    = "Visual"
g_xpane  = "Cross-Pane Overlays"
g_dash   = "Dashboard"

vol_len         = input.int(20,  "Yang-Zhang Window",          minval=5,                    group=g_vol,  tooltip="Lookback window for variance/SMA components of the Yang-Zhang estimator. Larger values smooth the realised-vol series at the cost of responsiveness.")
regime_lookback = input.int(100, "Regime Percentile Lookback", minval=20, maxval=500,       group=g_vol,  tooltip="Rolling sample size used to percentile-rank realised volatility and to draw the empirical vol cone (p5/p25/p50/p75/p95).")
forecast_len    = input.int(5,   "Forecast HMA Length",        minval=2,  maxval=50,        group=g_vol,  tooltip="Hull moving average length applied to the Yang-Zhang vol series. The HMA's low lag makes it a clean short-horizon vol forecast.")
expectedRangeMult = input.float(1.5, "Expected Range ATR Factor", minval=0.25, maxval=5.0, step=0.25, group=g_vol, tooltip="Multiplier applied to ATR scaled by the forecast/realised vol ratio when projecting the next-bar expected hi/lo range on the price chart.")

bullColor       = input.color(#00ffbb, "Bullish (Low Vol)",   inline="cBull",               group=g_vis,  tooltip="Primary low-vol / bullish color — JOAT brand mint. Tints the LOW regime, lower-tail cone fill, low-entry pulses and the position-multiplier upside.")
bearColor       = input.color(#ff1100, "Bearish (Extreme Vol)", inline="cBull",             group=g_vis,  tooltip="Primary extreme-vol / bearish color — JOAT brand red. Tints the EXTREME regime, upper-tail cone fill, extreme-entry pulses and the position-multiplier downside.")
elevatedColor   = input.color(#ffb347, "Elevated Vol Color",                                 group=g_vis,  tooltip="Amber tone applied to the ELEVATED regime, between the 65th and 90th percentile.")
showCone        = input.bool(true,  "Show Volatility Cone",                                  group=g_vis,  tooltip="Toggle the five-line vol cone (5/25/50/75/95 percentiles) and its gradient tail fills.")
showForecast    = input.bool(true,  "Show Forecast Line",                                    group=g_vis,  tooltip="Toggle the HMA forecast circle series projected through current vol.")
showVolOfVolStrip = input.bool(true, "Show Vol-of-Vol Strip",                                 group=g_vis,  tooltip="Toggle the small histogram strip above the p95 line that visualises vol-of-vol (regime instability).")
showConeEdgeLabels = input.bool(true, "Show Cone Edge Labels",                               group=g_vis,  tooltip="Toggle the right-edge percentile labels (p5/p25/p50/p75/p95) inside the pane.")
showNowLabel    = input.bool(true,  "Show 'Now' Percentile Label",                           group=g_vis,  tooltip="Toggle the right-edge label showing current vol value and its percentile rank position.")
showStickiness  = input.bool(true,  "Show Regime Stickiness Bar",                            group=g_vis,  tooltip="Toggle the small horizontal bar at the right edge of the pane that visualises how long the current regime has persisted.")
showForecastEdge = input.bool(true, "Show Forecast Edge Label",                              group=g_vis,  tooltip="Toggle the right-edge label that summarises whether the HMA forecast is EXPANDING or CONTRACTING vs current vol.")
showPulse       = input.bool(true,  "Regime Transition Pulse",                               group=g_vis,  tooltip="Toggle the brief bgcolor pulse that fires whenever the regime first enters EXTREME or LOW.")

showCandles         = input.bool(true,  "Cross-Pane Iridescent Candles",                     group=g_xpane, tooltip="Recolour the chart candles by current vol regime — LOW=mint, NORMAL=neutral, ELEVATED=amber, EXTREME=red. Plotted on the price chart via force_overlay.")
showRegimeTimeline  = input.bool(true,  "Cross-Pane Regime Timeline",                        group=g_xpane, tooltip="Drop persistent labels on the price chart at each regime transition. Capped FIFO at 15 labels.")
showRegimeBgcolor   = input.bool(true,  "Cross-Pane Regime BGcolor Tint",                    group=g_xpane, tooltip="Subtle background tint on the price chart sustained by current regime — instant vol context without switching panes.")
showPosSizeLabel    = input.bool(true,  "Cross-Pane Position-Size Suggestion",               group=g_xpane, tooltip="Persistent label on the price chart suggesting a position-size multiplier derived from the current vol regime.")
showVolEvents       = input.bool(true,  "Cross-Pane Vol Cone Touch Markers",                 group=g_xpane, tooltip="Persistent labels on the price chart at every cone breakout (vol > p95) and contraction (vol < p5). Capped FIFO at 15 labels.")
showExpectedRange   = input.bool(true,  "Cross-Pane Expected Next-Bar Range",                group=g_xpane, tooltip="Two short horizontal lines projected right of the current bar on the price chart, representing the forecast-implied next-bar hi/lo range.")

showDash        = input.bool(true, "Show Dashboard",                                         group=g_dash, tooltip="Toggle the institutional dashboard panel.")
dashPos         = input.string("top_right", "Dashboard Position",
     options=["top_right","top_center","top_left","middle_right","middle_center","middle_left","bottom_right","bottom_center","bottom_left"],
     group=g_dash, tooltip="Anchor the dashboard to any of the 9 chart positions.")
dashSize        = input.string("Medium", "Dashboard Size",
     options=["Tiny","Small","Medium","Large"],
     group=g_dash, tooltip="Cell text size for the dashboard.")

// ════════════════════════════════════════════════════════════════════
// HELPERS
// ════════════════════════════════════════════════════════════════════

// Map dashboard position string to native enum
posFromString(string s) =>
    s == "top_left"      ? position.top_left      :
     s == "top_center"   ? position.top_center    :
     s == "top_right"    ? position.top_right     :
     s == "middle_left"  ? position.middle_left   :
     s == "middle_center"? position.middle_center :
     s == "middle_right" ? position.middle_right  :
     s == "bottom_left"  ? position.bottom_left   :
     s == "bottom_center"? position.bottom_center :
     position.bottom_right

// Map dashboard size string to native enum
sizeFromString(string s) =>
    s == "Tiny"   ? size.tiny    :
     s == "Small" ? size.small   :
     s == "Large" ? size.large   :
     size.normal

// Transparency derived from absolute magnitude — louder fills when vol is far from baseline
alphaForVal(float v) =>
    t = 90 - math.floor(math.min(85.0, math.abs(v) * 1.2))
    math.max(5, math.min(95, t))

// Regime tier color — vivid for the active band, normal kept neutral
regimeColor(int r) =>
    r == 1 ? bullColor :
     r == 3 ? elevatedColor :
     r == 4 ? bearColor :
     chart.fg_color

// Dashboard regime cell tint — heavier alpha so the dashboard reads at a glance
regimeCellBg(int r) =>
    r == 1 ? color.new(bullColor,     30) :
     r == 3 ? color.new(elevatedColor, 30) :
     r == 4 ? color.new(bearColor,     30) :
     color.new(chart.fg_color,         70)

// Forecast-direction cell tint
forecastCellBg(string d) =>
    d == "EXPANDING"   ? color.new(bearColor, 50) :
     d == "CONTRACTING" ? color.new(bullColor, 50) :
     color.new(chart.fg_color, 70)

// Position-multiplier cell tint — gradient between bear (small mult) and bull (large mult)
posMultCellBg(float m) =>
    m >= 1.2 ? color.new(bullColor,     40) :
     m >= 0.9 ? color.new(chart.fg_color, 70) :
     m >= 0.6 ? color.new(elevatedColor, 40) :
     color.new(bearColor,                40)

// Z-score cell tint — louder fill as |z| grows
zCellBg(float z) =>
    z >=  2.0 ? color.new(bearColor,     35) :
     z >=  1.0 ? color.new(elevatedColor, 45) :
     z <= -2.0 ? color.new(bullColor,     35) :
     z <= -1.0 ? color.new(bullColor,     55) :
     color.new(chart.fg_color,            70)

// Cone-position cell tint — heat-mapped 0..1
conePosCellBg(float c) =>
    c >= 0.90 ? color.new(bearColor,     35) :
     c >= 0.65 ? color.new(elevatedColor, 45) :
     c <= 0.10 ? color.new(bullColor,     35) :
     c <= 0.35 ? color.new(bullColor,     55) :
     color.new(chart.fg_color,            70)

// Vol-of-vol cell tint — relative to its own median-ish midpoint
volOfVolCellBg(float vv, float ref) =>
    vv >= ref * 1.5 ? color.new(elevatedColor, 45) :
     vv <= ref * 0.5 ? color.new(bullColor,     55) :
     color.new(chart.fg_color,                  70)

// Convert an integer regime tier to a printable label
regimeLabel(int r) =>
    r == 1 ? "LOW" : r == 2 ? "NORMAL" : r == 3 ? "ELEVATED" : "EXTREME"

// FIFO trim helper — keep a typed label array bounded
fifoTrimLabels(array<label> arr, int cap) =>
    while array.size(arr) > cap
        old = array.shift(arr)
        if not na(old)
            label.delete(old)

// ════════════════════════════════════════════════════════════════════
// CORE — YANG-ZHANG VOLATILITY
// ════════════════════════════════════════════════════════════════════
confirmedBar = barstate.isconfirmed or barstate.ishistory

// --- Log return decomposition ---
// Overnight gap (close[1] -> open). nz fallback prevents na on the first bar.
log_oc = math.log(open / nz(close[1], open))
// Intraday open-to-close drift
log_co = math.log(close / open)
// Rogers-Satchell intraday components
log_hc = math.log(high  / close)
log_ho = math.log(high  / open)
log_lc = math.log(low   / close)
log_lo = math.log(low   / open)

// --- Variance / mean components over the Yang-Zhang window ---
var_oc = ta.variance(log_oc, vol_len)
var_co = ta.variance(log_co, vol_len)
rs     = ta.sma(log_hc * log_ho + log_lc * log_lo, vol_len)

// Yang-Zhang k coefficient — minimises the estimator variance.
// math.max guard prevents division-by-zero in the tail of the lookback.
k       = 0.34 / (1.34 + (vol_len + 1.0) / math.max(vol_len - 1.0, 1.0))

// Periodic Yang-Zhang volatility (per-bar). Clamp negative under floating
// point noise so the sqrt never returns na.
sigma_yz_periodic = math.sqrt(math.max(var_oc + k * var_co + (1.0 - k) * rs, 0.0))

// Percentage display — multiply by 100 so the pane reads in clean "%".
sigma_yz_pct = sigma_yz_periodic * 100.0

// ════════════════════════════════════════════════════════════════════
// CORE — REGIME CLASSIFICATION & VOL CONE
// ════════════════════════════════════════════════════════════════════

// Percentile rank of current vol vs the rolling distribution.
vol_pct = ta.percentrank(sigma_yz_pct, regime_lookback)

// Four-tier classifier with hard cutoffs at p25 / p65 / p90.
regime_int = vol_pct < 25.0 ? 1 : vol_pct < 65.0 ? 2 : vol_pct < 90.0 ? 3 : 4
regime = regimeLabel(regime_int)

// Persistent counter — bars spent in the active regime, resets on transitions.
var int barsInRegime = 0
barsInRegime := regime_int == nz(regime_int[1], regime_int) ? barsInRegime + 1 : 1

// --- Empirical vol cone (5 percentile lines) ---
p5  = ta.percentile_linear_interpolation(sigma_yz_pct, regime_lookback, 5)
p25 = ta.percentile_linear_interpolation(sigma_yz_pct, regime_lookback, 25)
p50 = ta.percentile_linear_interpolation(sigma_yz_pct, regime_lookback, 50)
p75 = ta.percentile_linear_interpolation(sigma_yz_pct, regime_lookback, 75)
p95 = ta.percentile_linear_interpolation(sigma_yz_pct, regime_lookback, 95)

// ════════════════════════════════════════════════════════════════════
// CORE — FORECAST & POSITION-SIZE MULTIPLIER
// ════════════════════════════════════════════════════════════════════

// Hull moving average of the vol series — low-lag short-horizon forecast.
forecast       = ta.hma(sigma_yz_pct, forecast_len)
forecast_delta = forecast - sigma_yz_pct

// Forecast direction with a small dead-zone so micro-flicker reads as STABLE.
deadZone = math.max(0.0001, sigma_yz_pct * 0.005)
forecast_direction = forecast_delta > deadZone ? "EXPANDING" : forecast_delta < -deadZone ? "CONTRACTING" : "STABLE"

// Position-size multiplier — inversely linear in vol percentile.
// vol_pct =  10 -> 1.40   |   vol_pct =  50 -> 1.00   |   vol_pct =  90 -> 0.60
// Clamped to [0.3, 1.5] for sanity at the distribution tails.
pos_mult = math.max(0.3, math.min(1.5, 1.5 - vol_pct / 100.0))

// ════════════════════════════════════════════════════════════════════
// CORE — VOL-OF-VOL & DISTRIBUTION DIAGNOSTICS
// ════════════════════════════════════════════════════════════════════

// Vol-of-vol — stdev of the realised vol series itself. Useful as a
// stability gauge: low vol-of-vol means the regime is "sticky", high
// vol-of-vol means the surface is choppy and forecasts are noisy.
vol_of_vol = ta.stdev(sigma_yz_pct, regime_lookback)

// Vol z-score against the lookback mean — fast view on whether
// realised vol is statistically extreme relative to its own history.
vol_mean = ta.sma(sigma_yz_pct, regime_lookback)
vol_z    = vol_of_vol > 0.0 ? (sigma_yz_pct - vol_mean) / vol_of_vol : 0.0

// ATR-derived vol benchmark (percentage of price) — gives the dashboard
// a familiar reference point for traders accustomed to ATR-based sizing.
atrLen     = math.max(2, math.min(50, vol_len))
atrAbs     = ta.atr(atrLen)
atr_pct    = close != 0.0 ? (atrAbs / close) * 100.0 : 0.0
// Ratio Yang-Zhang vs ATR — > 1 means YZ sees more variance than ATR
// would imply (gap / Rogers-Satchell components are contributing).
yz_atr_ratio = atr_pct > 0.0 ? sigma_yz_pct / atr_pct : 0.0

// Cone position 0..1 — where in the empirical cone the current vol sits
// (clamped). Used as an auxiliary readout in the dashboard.
coneRange     = math.max(p95 - p5, 0.0001)
cone_position = math.max(0.0, math.min(1.0, (sigma_yz_pct - p5) / coneRange))

// ════════════════════════════════════════════════════════════════════
// SIGNAL ENGINE — confirmed-bar gated
// ════════════════════════════════════════════════════════════════════

prevRegimeInt = nz(regime_int[1], regime_int)
prevRegime    = regimeLabel(prevRegimeInt)

regime_up         = (regime_int  > prevRegimeInt)                            and confirmedBar
regime_down       = (regime_int  < prevRegimeInt)                            and confirmedBar
extreme_entry     = (regime      == "EXTREME") and (prevRegime != "EXTREME") and confirmedBar
low_entry         = (regime      == "LOW")     and (prevRegime != "LOW")     and confirmedBar
vol_breakout      = (sigma_yz_pct > p95)       and (nz(sigma_yz_pct[1]) <= nz(p95[1])) and confirmedBar
vol_contract      = (sigma_yz_pct < p5)        and (nz(sigma_yz_pct[1]) >= nz(p5[1]))  and confirmedBar

// Z-score thresholds — sigma-based vol shocks, complement to percentile cone.
vol_zshock_up     = (vol_z >  2.0) and (nz(vol_z[1]) <=  2.0) and confirmedBar
vol_zshock_down   = (vol_z < -2.0) and (nz(vol_z[1]) >= -2.0) and confirmedBar
// Forecast crossover — Hull MA crossing realised vol, leading indication
// that the short-horizon vol regime is about to flip direction.
forecast_cross_up   = ta.crossover(forecast,  sigma_yz_pct)  and confirmedBar
forecast_cross_down = ta.crossunder(forecast, sigma_yz_pct)  and confirmedBar

// Any-regime-transition union — used by the timeline label engine.
regime_transition = (regime_up or regime_down) and confirmedBar

// ════════════════════════════════════════════════════════════════════
// VISUALS — PANE
// ════════════════════════════════════════════════════════════════════
noneColor = color.new(color.white, 100)

// --- Main vol plot, regime-tinted ---
volPlotColor = regime_int == 1 ? color.new(bullColor, 0) : regime_int == 3 ? color.new(elevatedColor, 0) : regime_int == 4 ? color.new(bearColor, 0) : color.new(chart.fg_color, 30)

pVol = plot(sigma_yz_pct, "Yang-Zhang Vol %", color=volPlotColor, linewidth=3)

// --- Forecast line — gradient-coloured by forecast_delta magnitude ---
// color.from_gradient on |forecast_delta| with a soft saturation cap so
// micro deltas read neutral and pronounced deltas read vivid.
forecastDeltaCap = math.max(0.01, sigma_yz_pct * 0.20)
forecastDeltaClamped = math.max(-forecastDeltaCap, math.min(forecastDeltaCap, forecast_delta))
forecastColor = color.from_gradient(forecastDeltaClamped, -forecastDeltaCap, forecastDeltaCap,
     color.new(bullColor, 10), color.new(bearColor, 10))
// Override to a neutral tone when the dead-zone says STABLE so it doesn't false-paint
forecastColorFinal = forecast_direction == "STABLE" ? color.new(chart.fg_color, 30) : forecastColor
plot(showForecast ? forecast : na, "Forecast (HMA)", color=forecastColorFinal, linewidth=2, style=plot.style_circles)

// --- Cone lines ---
pP5  = plot(showCone ? p5  : na, "p5  Vol Percentile",  color=color.new(bullColor,     60), linewidth=1, style=plot.style_line)
pP25 = plot(showCone ? p25 : na, "p25 Vol Percentile",  color=color.new(chart.fg_color, 50), linewidth=1, style=plot.style_line)
pP50 = plot(showCone ? p50 : na, "p50 Vol Percentile",  color=color.new(chart.fg_color, 40), linewidth=1, style=plot.style_line)
pP75 = plot(showCone ? p75 : na, "p75 Vol Percentile",  color=color.new(chart.fg_color, 50), linewidth=1, style=plot.style_line)
pP95 = plot(showCone ? p95 : na, "p95 Vol Percentile",  color=color.new(bearColor,     60), linewidth=1, style=plot.style_line)

// --- Cone gradient fills ---
// Interquartile (p25..p75): neutral fg-color tint
fill(pP25, pP75, color=showCone ? color.new(chart.fg_color, 88) : na, title="Cone IQR Fill")
// Lower tail (p5..p25): bullish tint
fill(pP5,  pP25, color=showCone ? color.new(bullColor,      92) : na, title="Cone Lower Tail Fill")
// Upper tail (p75..p95): bearish tint
fill(pP75, pP95, color=showCone ? color.new(bearColor,      92) : na, title="Cone Upper Tail Fill")

// Vol-vs-cone breach fills — louder when vol is outside the cone proper.
// vol-above-p95: extreme high fill (vivid bear)
fill(pVol, pP95, color=showCone and sigma_yz_pct > p95 ? color.new(bearColor, 70) : na, title="Vol > p95 Fill")
// vol-below-p5: extreme low fill (vivid bull)
fill(pVol, pP5,  color=showCone and sigma_yz_pct < p5  ? color.new(bullColor, 70) : na, title="Vol < p5 Fill")

// --- Subtle dotted threshold rails at p25 / p50 / p75 ---
// hline cannot consume runtime values, so anchor a constant 0 line and
// overlay percentile reference markers via plot with circle style.
plot(showCone ? p25 : na, "p25 Rail", color=color.new(chart.fg_color, 60), linewidth=1, style=plot.style_circles, display=display.pane)
plot(showCone ? p50 : na, "p50 Rail", color=color.new(chart.fg_color, 55), linewidth=1, style=plot.style_circles, display=display.pane)
plot(showCone ? p75 : na, "p75 Rail", color=color.new(chart.fg_color, 60), linewidth=1, style=plot.style_circles, display=display.pane)

// --- Vol-of-vol top sub-strip (F) ---
// Scale vov so it visually sits as a small bar histogram above p95.
// We display vov as a "vov_top" series anchored at p95 + offset.
volOfVolRefLong = ta.sma(vol_of_vol, math.max(50, regime_lookback))
vovScale = volOfVolRefLong > 0.0 ? (p95 * 0.20) / volOfVolRefLong : 0.0
vovStripOffset = math.max(p95 * 0.05, 0.05)
vovStripBase   = p95 + vovStripOffset
vovStripTop    = vovStripBase + vol_of_vol * vovScale

vovStripColor = vol_of_vol >= volOfVolRefLong * 1.5 ? color.new(bearColor, 40) : vol_of_vol >= volOfVolRefLong * 1.0 ? color.new(elevatedColor, 50) : vol_of_vol <= volOfVolRefLong * 0.5 ? color.new(bullColor, 55) : color.new(chart.fg_color, 60)
plot(showVolOfVolStrip ? vovStripTop  : na, "Vol-of-Vol Strip Top",  color=vovStripColor, linewidth=2, style=plot.style_histogram, histbase=0.0)
plot(showVolOfVolStrip ? vovStripBase : na, "Vol-of-Vol Strip Base", color=color.new(chart.fg_color, 70), linewidth=1, style=plot.style_line)

// --- Regime-transition bgcolor pulses (2-3 bar fade) ---
// A pulse is drawn this bar and the next two using a simple count-down counter.
var int pulseExtreme = 0
var int pulseLow     = 0
pulseExtreme := extreme_entry ? 3 : math.max(0, pulseExtreme - 1)
pulseLow     := low_entry     ? 3 : math.max(0, pulseLow     - 1)

bgPulseColor = showPulse and pulseExtreme > 0 ? color.new(bearColor, 75 + (3 - pulseExtreme) * 5) : showPulse and pulseLow > 0 ? color.new(bullColor, 75 + (3 - pulseLow) * 5) : na
bgcolor(bgPulseColor, title="Regime Transition Pulse")

// --- Cross-pane iridescent candle recolour on the price chart ---
candleCol = regime_int == 1 ? color.new(bullColor, 20) : regime_int == 3 ? color.new(elevatedColor, 20) : regime_int == 4 ? color.new(bearColor, 20) : color.new(chart.fg_color, 60)
plotcandle(showCandles ? open : na, showCandles ? high : na, showCandles ? low : na, showCandles ? close : na,
     title       = "Iridescent Regime Candles",
     color       = candleCol,
     wickcolor   = candleCol,
     bordercolor = candleCol,
     force_overlay = true)

// ════════════════════════════════════════════════════════════════════
// CROSS-PANE (B) — REGIME BGCOLOR TINT ON PRICE CHART
// ════════════════════════════════════════════════════════════════════
// Sustained subtle tint for the current regime — read at a glance.
regimeBgPriceColor = regime_int == 1 ? color.new(bullColor, 96) : regime_int == 3 ? color.new(elevatedColor, 95) : regime_int == 4 ? color.new(bearColor, 90) : na
bgcolor(showRegimeBgcolor ? regimeBgPriceColor : na, title="Cross-Pane Regime Tint", force_overlay=true)

// ════════════════════════════════════════════════════════════════════
// CROSS-PANE (A) — REGIME TIMELINE LABELS
// ════════════════════════════════════════════════════════════════════
var array<label> regimeTimeline = array.new<label>()
if showRegimeTimeline and confirmedBar and (extreme_entry or low_entry or regime_up or regime_down)
    timelineText = "VOL " + regime + " " + str.tostring(sigma_yz_pct, "0.0") + "%"
    timelineBg   = color.new(regimeColor(regime_int), 25)
    timelineY    = regime_int >= 3 ? high * 1.005 : low * 0.995
    timelineSty  = regime_int >= 3 ? label.style_label_down : label.style_label_up
    lbl = label.new(bar_index, timelineY, timelineText,
         xloc          = xloc.bar_index,
         yloc          = yloc.price,
         style         = timelineSty,
         color         = timelineBg,
         textcolor     = color.white,
         size          = size.small,
         textalign     = text.align_left,
         force_overlay = true)
    array.push(regimeTimeline, lbl)
    fifoTrimLabels(regimeTimeline, 15)

// ════════════════════════════════════════════════════════════════════
// CROSS-PANE (G) — VOL CONE TOUCH MARKERS (BREAKOUT / CONTRACTION)
// ════════════════════════════════════════════════════════════════════
var array<label> volEventLabels = array.new<label>()
if showVolEvents and confirmedBar and vol_breakout
    breakText = "Vol breakout " + str.tostring(sigma_yz_pct, "0.0") + "%"
    lbl = label.new(bar_index, high * 1.010, breakText,
         xloc          = xloc.bar_index,
         yloc          = yloc.price,
         style         = label.style_label_down,
         color         = color.new(bearColor, 20),
         textcolor     = color.white,
         size          = size.small,
         textalign     = text.align_left,
         force_overlay = true)
    array.push(volEventLabels, lbl)
    fifoTrimLabels(volEventLabels, 15)

if showVolEvents and confirmedBar and vol_contract
    contractText = "Vol contract " + str.tostring(sigma_yz_pct, "0.0") + "%"
    lbl = label.new(bar_index, low * 0.990, contractText,
         xloc          = xloc.bar_index,
         yloc          = yloc.price,
         style         = label.style_label_up,
         color         = color.new(bullColor, 20),
         textcolor     = color.white,
         size          = size.small,
         textalign     = text.align_left,
         force_overlay = true)
    array.push(volEventLabels, lbl)
    fifoTrimLabels(volEventLabels, 15)

// ════════════════════════════════════════════════════════════════════
// CROSS-PANE (D) — POSITION-SIZE SUGGESTION LABEL
// ════════════════════════════════════════════════════════════════════
var label posSizeLabel = na
if barstate.islast and showPosSizeLabel
    if not na(posSizeLabel)
        label.delete(posSizeLabel)
    posSizeText = "Size x" + str.tostring(pos_mult, "0.00") + "  " + regime + " vol"
    posSizeBg   = color.new(regimeColor(regime_int), 15)
    posSizeLabel := label.new(bar_index + 30, high * 1.05, posSizeText,
         xloc          = xloc.bar_index,
         yloc          = yloc.price,
         style         = label.style_label_left,
         color         = posSizeBg,
         textcolor     = color.white,
         size          = size.normal,
         textalign     = text.align_left,
         force_overlay = true)

// ════════════════════════════════════════════════════════════════════
// CROSS-PANE (J) — EXPECTED NEXT-BAR HI / LO RANGE
// ════════════════════════════════════════════════════════════════════
// Forecast normalised vs realised vol gives a forward-looking range
// scaling factor. Multiplied by ATR and the user multiplier.
forecastNorm = sigma_yz_pct > 0.0 ? forecast / sigma_yz_pct : 1.0
expectedHalfRange = atrAbs * forecastNorm * expectedRangeMult
expectedHi = close + expectedHalfRange
expectedLo = close - expectedHalfRange

var line  expHiLine  = na
var line  expLoLine  = na
var label expHiLabel = na
var label expLoLabel = na
if barstate.islast and showExpectedRange
    if not na(expHiLine)
        line.delete(expHiLine)
    if not na(expLoLine)
        line.delete(expLoLine)
    if not na(expHiLabel)
        label.delete(expHiLabel)
    if not na(expLoLabel)
        label.delete(expLoLabel)
    expHiLine := line.new(bar_index + 1, expectedHi, bar_index + 10, expectedHi,
         xloc          = xloc.bar_index,
         color         = color.new(bearColor, 30),
         style         = line.style_dashed,
         width         = 2,
         force_overlay = true)
    expLoLine := line.new(bar_index + 1, expectedLo, bar_index + 10, expectedLo,
         xloc          = xloc.bar_index,
         color         = color.new(bullColor, 30),
         style         = line.style_dashed,
         width         = 2,
         force_overlay = true)
    expHiLabel := label.new(bar_index + 10, expectedHi,
         "Expected hi " + str.tostring(expectedHi, format.mintick),
         xloc          = xloc.bar_index,
         yloc          = yloc.price,
         style         = label.style_label_left,
         color         = color.new(bearColor, 30),
         textcolor     = color.white,
         size          = size.small,
         textalign     = text.align_left,
         force_overlay = true)
    expLoLabel := label.new(bar_index + 10, expectedLo,
         "Expected lo " + str.tostring(expectedLo, format.mintick),
         xloc          = xloc.bar_index,
         yloc          = yloc.price,
         style         = label.style_label_left,
         color         = color.new(bullColor, 30),
         textcolor     = color.white,
         size          = size.small,
         textalign     = text.align_left,
         force_overlay = true)

// ════════════════════════════════════════════════════════════════════
// PANE (C) — RIGHT-EDGE CONE LEVEL LABELS
// ════════════════════════════════════════════════════════════════════
var label coneLblP5  = na
var label coneLblP25 = na
var label coneLblP50 = na
var label coneLblP75 = na
var label coneLblP95 = na

makeConeLabel(label prior, float y, string txt, color bg) =>
    if not na(prior)
        label.delete(prior)
    label.new(bar_index + 5, y, txt,
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         style     = label.style_label_left,
         color     = bg,
         textcolor = color.white,
         size      = size.small,
         textalign = text.align_left)

if barstate.islast and showConeEdgeLabels and showCone
    coneLblP95 := makeConeLabel(coneLblP95, p95, "p95 " + str.tostring(p95, "0.00") + "%", color.new(bearColor,     30))
    coneLblP75 := makeConeLabel(coneLblP75, p75, "p75 " + str.tostring(p75, "0.00") + "%", color.new(bearColor,     60))
    coneLblP50 := makeConeLabel(coneLblP50, p50, "p50 " + str.tostring(p50, "0.00") + "%", color.new(chart.fg_color, 50))
    coneLblP25 := makeConeLabel(coneLblP25, p25, "p25 " + str.tostring(p25, "0.00") + "%", color.new(bullColor,     60))
    coneLblP5  := makeConeLabel(coneLblP5,  p5,  "p5 "  + str.tostring(p5,  "0.00") + "%", color.new(bullColor,     30))

// ════════════════════════════════════════════════════════════════════
// PANE (H) — "NOW" PERCENTILE LABEL
// ════════════════════════════════════════════════════════════════════
var label nowLabel = na
if barstate.islast and showNowLabel
    if not na(nowLabel)
        label.delete(nowLabel)
    nowText = "Now " + str.tostring(sigma_yz_pct, "0.00") + "% (pct " + str.tostring(vol_pct, "0") + " / " + regime + ")"
    nowLabel := label.new(bar_index + 5, sigma_yz_pct, nowText,
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         style     = label.style_label_left,
         color     = color.new(regimeColor(regime_int), 20),
         textcolor = color.white,
         size      = size.small,
         textalign = text.align_left)

// ════════════════════════════════════════════════════════════════════
// PANE (E) — FORECAST EDGE LABEL
// ════════════════════════════════════════════════════════════════════
var label forecastEdgeLabel = na
if barstate.islast and showForecastEdge and showForecast
    if not na(forecastEdgeLabel)
        label.delete(forecastEdgeLabel)
    fEdgeText = "Forecast " + forecast_direction + " " + str.tostring(forecast, "0.00") + "%"
    fEdgeBg   = forecast_direction == "EXPANDING" ? color.new(bearColor, 25) : forecast_direction == "CONTRACTING" ? color.new(bullColor, 25) : color.new(chart.fg_color, 40)
    fEdgeY = forecast + math.max(0.02, math.abs(forecast - sigma_yz_pct) * 0.5)
    forecastEdgeLabel := label.new(bar_index + 5, fEdgeY, fEdgeText,
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         style     = label.style_label_left,
         color     = fEdgeBg,
         textcolor = color.white,
         size      = size.small,
         textalign = text.align_left)

// ════════════════════════════════════════════════════════════════════
// PANE (I) — REGIME STICKINESS BAR (right edge)
// ════════════════════════════════════════════════════════════════════
// A short horizontal line at right edge whose length is proportional to
// barsInRegime — quick visual cue for how persistent the current regime
// has been. Capped at a max bar length so it never overruns the pane.
stickinessCap     = math.max(20, regime_lookback / 2)
stickinessNorm    = math.min(1.0, barsInRegime * 1.0 / math.max(stickinessCap, 1))
stickinessBars    = math.round(stickinessNorm * 20)

var line stickinessLine = na
var label stickinessLabel = na
if barstate.islast and showStickiness
    if not na(stickinessLine)
        line.delete(stickinessLine)
    if not na(stickinessLabel)
        label.delete(stickinessLabel)
    stickinessY = sigma_yz_pct
    stickinessColor = color.new(regimeColor(regime_int), 100 - math.floor(stickinessNorm * 70) - 10)
    stickinessLine := line.new(bar_index + 2, stickinessY, bar_index + 2 + math.max(1, stickinessBars), stickinessY,
         xloc  = xloc.bar_index,
         color = stickinessColor,
         style = line.style_solid,
         width = 4)
    stickinessLabel := label.new(bar_index + 2 + math.max(1, stickinessBars) + 1, stickinessY,
         str.tostring(barsInRegime) + " bars",
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         style     = label.style_label_left,
         color     = color.new(regimeColor(regime_int), 50),
         textcolor = color.white,
         size      = size.tiny,
         textalign = text.align_left)

// ════════════════════════════════════════════════════════════════════
// DASHBOARD
// ════════════════════════════════════════════════════════════════════

var table dash = table.new(position.top_right, 2, 13,
     bgcolor      = #111118,
     border_color = #252535,
     border_width = 1,
     frame_color  = #252535,
     frame_width  = 1)

// Tracking value for vol-of-vol cell tint — long SMA gives a stable reference.
volOfVolRef = ta.sma(vol_of_vol, math.max(50, regime_lookback))

if barstate.islast and showDash
    dash := table.new(posFromString(dashPos), 2, 13,
         bgcolor      = #111118,
         border_color = #252535,
         border_width = 1,
         frame_color  = #252535,
         frame_width  = 1)
    table.clear(dash, 0, 0, 1, 12)
    txtSize = sizeFromString(dashSize)

    headerBg = color.new(regimeColor(regime_int), 35)

    // Row 0 — Header
    table.cell(dash, 0, 0, "Helios Volatility Forecast [JOAT]", text_color=color.white, bgcolor=headerBg, text_size=txtSize)
    table.cell(dash, 1, 0, "",                                  text_color=color.white, bgcolor=headerBg, text_size=txtSize)
    table.merge_cells(dash, 0, 0, 1, 0)

    // Row 1 — Yang-Zhang Vol
    table.cell(dash, 0, 1, "Yang-Zhang Vol",                            text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 1, str.tostring(sigma_yz_pct, "0.00") + "%",    text_color=color.white,    bgcolor=#1a1a26, text_size=txtSize)

    // Row 2 — Vol Percentile
    table.cell(dash, 0, 2, "Vol Percentile",                            text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 2, str.tostring(vol_pct, "0.0") + "%",          text_color=color.white,    bgcolor=#1a1a26, text_size=txtSize)

    // Row 3 — Regime
    table.cell(dash, 0, 3, "Regime",                                    text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 3, regime,                                      text_color=color.white,    bgcolor=regimeCellBg(regime_int), text_size=txtSize)

    // Row 4 — Forecast (HMA-N)
    table.cell(dash, 0, 4, "Forecast (HMA-" + str.tostring(forecast_len) + ")", text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 4, str.tostring(forecast, "0.00") + "%",                text_color=color.white,    bgcolor=#1a1a26, text_size=txtSize)

    // Row 5 — Forecast Direction
    table.cell(dash, 0, 5, "Forecast Direction",                        text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 5, forecast_direction,                          text_color=color.white,    bgcolor=forecastCellBg(forecast_direction), text_size=txtSize)

    // Row 6 — Position Multiplier
    table.cell(dash, 0, 6, "Position Multiplier",                       text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 6, "x" + str.tostring(pos_mult, "0.00"),        text_color=color.white,    bgcolor=posMultCellBg(pos_mult), text_size=txtSize)

    // Row 7 — p5 / p95
    table.cell(dash, 0, 7, "p5  / p95",                                                                              text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 7, str.tostring(p5, "0.00") + " / " + str.tostring(p95, "0.00"),                             text_color=color.white,    bgcolor=#1a1a26, text_size=txtSize)

    // Row 8 — Vol Z-Score (sigma units vs lookback mean)
    table.cell(dash, 0, 8, "Vol Z-Score",                                   text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 8, str.tostring(vol_z, "0.00") + " sd",             text_color=color.white,    bgcolor=zCellBg(vol_z), text_size=txtSize)

    // Row 9 — Vol-of-Vol (regime stability)
    table.cell(dash, 0, 9, "Vol-of-Vol",                                    text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 9, str.tostring(vol_of_vol, "0.00"),                text_color=color.white,    bgcolor=volOfVolCellBg(vol_of_vol, volOfVolRef), text_size=txtSize)

    // Row 10 — YZ vs ATR ratio (cross-check vs price-distance vol benchmark)
    table.cell(dash, 0, 10, "YZ / ATR Ratio",                               text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 10, str.tostring(yz_atr_ratio, "0.00") + "  (" + str.tostring(atr_pct, "0.00") + "% atr)", text_color=color.white, bgcolor=#1a1a26, text_size=txtSize)

    // Row 11 — Bars in Regime & cone position
    table.cell(dash, 0, 11, "Bars in Regime",                               text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 11, str.tostring(barsInRegime) + " (cone " + str.tostring(cone_position * 100.0, "0") + "%)",
         text_color=color.white,    bgcolor=conePosCellBg(cone_position), text_size=txtSize)

    // Row 12 — Watermark
    table.cell(dash, 0, 12, "@JackOfAllTrades", text_color=color.new(#9090b0, 60), bgcolor=#111118, text_size=txtSize)
    table.cell(dash, 1, 12, "",                 text_color=color.new(#9090b0, 60), bgcolor=#111118, text_size=txtSize)
    table.merge_cells(dash, 0, 12, 1, 12)

// ════════════════════════════════════════════════════════════════════
// ALERTS
// ════════════════════════════════════════════════════════════════════
alertcondition(regime_up,      title="HVF Regime Up",         message="Helios Volatility Forecast [JOAT] — Vol regime escalated")
alertcondition(regime_down,    title="HVF Regime Down",       message="Helios Volatility Forecast [JOAT] — Vol regime de-escalated")
alertcondition(extreme_entry,  title="HVF Extreme Vol Entry", message="Helios Volatility Forecast [JOAT] — Volatility entered EXTREME regime")
alertcondition(low_entry,      title="HVF Low Vol Entry",     message="Helios Volatility Forecast [JOAT] — Volatility entered LOW regime")
alertcondition(vol_breakout,   title="HVF Vol Breakout",      message="Helios Volatility Forecast [JOAT] — Volatility crossed above 95th percentile cone")
alertcondition(vol_contract,   title="HVF Vol Contract",      message="Helios Volatility Forecast [JOAT] — Volatility crossed below 5th percentile cone")
alertcondition(vol_zshock_up,     title="HVF Vol Z-Shock Up",     message="Helios Volatility Forecast [JOAT] — Realised vol crossed above +2 sigma z-score")
alertcondition(vol_zshock_down,   title="HVF Vol Z-Shock Down",   message="Helios Volatility Forecast [JOAT] — Realised vol crossed below -2 sigma z-score")
alertcondition(forecast_cross_up,   title="HVF Forecast Cross Up",   message="Helios Volatility Forecast [JOAT] — HMA forecast crossed above realised vol (expansion likely)")
alertcondition(forecast_cross_down, title="HVF Forecast Cross Down", message="Helios Volatility Forecast [JOAT] — HMA forecast crossed below realised vol (contraction likely)")
````
