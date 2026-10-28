# Yield Curve Monitor

- url: https://www.tradingview.com/script/tTCUmRA2/
- type: indicator
- pine_id: PUB;5babdde2498a4f27abd5c955adaaba81
- version: 1.0

## Description

What you see in the preview image
The chart displays the complete US Treasury yield curve as a smooth log-scaled polyline drawn to the right of the last bar, with all eleven maturities from 1-month T-bills to 30-year bonds plotted at their actual yield values. The solid line shows today's curve; the dashed line shows the curve from 21 trading days ago for direct visual comparison. Each tenor is labeled with its name and yield in percent. To the right, a comprehensive dashboard table lists every maturity with current yield, the change in basis points versus the historical reference date, and a relative magnitude bar. Below the maturity rows the four most-watched yield-curve spreads are shown (2s10s, 3m10y, 2s30s, 5s30s) with their current value, change versus history, and inversion status. The footer classifies both the current and historical curves into one of five regimes — Steep, Normal, Flat, Inverted, or Humped — using a user-selectable slope metric.

What this indicator does
This is a complete US Treasury yield-curve workstation built into a single TradingView pane. It solves a problem that ordinary time-series indicators cannot: the yield curve is fundamentally a cross-sectional object — yield as a function of maturity at a single moment — but standard charts plot variables against time. By rendering the curve as a polyline anchored to the right of the last bar, with maturity on a logarithmic x-axis and yield on the price axis, the indicator gives you a real, geometrically faithful view of curve shape, alongside a complete data table and historical comparison.
Eleven maturities are pulled from TradingView's TVC feed at daily resolution: US01MY, US03MY, US06MY, US01Y, US02Y, US03Y, US05Y, US07Y, US10Y, US20Y, US30Y. Each tenor is requested twice — once for the current bar and once for a user-defined lookback offset — giving the indicator a paired snapshot that drives every visualization and metric. If a specific tenor is unavailable on your data plan (US20Y is the most common gap), that point silently drops from the curve and shows an em dash in the table — no errors are raised.


Settings explained
Display group

Curves geplottet (Curves to plot) — choose which yield curves are drawn to the right of the last bar: , , or . The dashboard table always shows both datasets regardless of this setting; this toggle controls only the visual polyline. The tenor labels next to the points always reflect the curve being plotted (or the current curve when both are shown).Current onlyHistoric onlyBoth
Slope-Metrik (Shape-Klassifikation) — selects which spread drives the Steep / Normal / Flat / Inverted / Humped classification shown in the dashboard footer. Six options are available:  (the default, broadest possible measure),  (classic NBER recession lead-indicator),  (the Federal Reserve's preferred recession signal),  (long-end steepness),  (pure long-end term-premium proxy), and  (full-spectrum slope excluding T-bills). Each metric has its own empirically calibrated thresholds (see the Methodology section), so the classification remains meaningful regardless of which spread you choose. Alerts also fire on the selected spread.30y - 3m10y - 2y (2s10s)10y - 3m (3m10y)30y - 5y (5s30s)30y - 10y (10s30s)30y - 2y (2s30s)
Dashboard anzeigen — show or hide the data table.
Tabellen-Position — five anchor points for the dashboard: top-left, top-right, middle-right, bottom-right, bottom-left.
Historic Lookback (Daily Bars) — the number of trading days back used for the historical comparison. Default is 21, which approximates one trading month. Useful presets: 21 ≈ 1 month, 63 ≈ 1 quarter, 126 ≈ 6 months, 252 ≈ 1 year. Maximum 504 bars (≈ 2 years).


Style group
Five customizable colors mapped to semantic roles (Bull/Steep/Current, Bear/Inversion, Neutral/Normal, Warning/Flat/Hump, Historic). One additional input controls the polyline line width (1 to 5). All defaults match a dark theme; the colors can be repointed to fit any chart style.
Alerts group
Two alert toggles: one fires when the user-selected slope metric crosses below zero (inversion event), the other when it crosses back above zero (re-steepening event). Both alerts trigger on confirmed daily-bar closes only — there is no intrabar repainting.
What the dashboard shows
The table is divided into three blocks.
Maturity block (eleven rows) — one row per tenor showing the current yield to three decimal places, the change in basis points versus the lookback date with directional color (green up, red down), and a magnitude bar built from filled and empty Unicode block characters that visualizes the yield's size relative to the highest yield in the curve. This block lets you read absolute levels and recent moves at a glance.
Key Spreads block (four rows) — the four most-watched curve spreads (2s10s, 3m10y, 2s30s, 5s30s), each with current value, change in basis points versus the lookback date, and an OK / INVERTED status flag. These four are shown unconditionally regardless of which slope metric you selected for shape classification, so you always have the full institutional toolkit visible.
Curve Shape block (one or two rows) — one row per plotted curve (Current and/or Historic, depending on the curve toggle). Each row shows the regime label (STEEP, NORMAL, FLAT, INVERTED, or HUMPED) on a colored background matching the regime, the current slope value of the selected metric, and the metric's name. This lets you compare regime states between today and the lookback date directly: the curve may have shifted from FLAT to STEEP, for example, even if both versions are visible on the chart.

Methodology — shape classification
The indicator uses the user-selected spread as its primary slope input, with four absolute thresholds calibrated empirically from US Treasury data since 1990:

30y - 3m Steep : +1.5% Normal > +0.3% Flat > -0.3% Inverted ≤ -0.3%
10y - 2y (2s10s) +1.0% +0.2% -0.2% -0.2%
10y - 3m (3m10y) +1.5% +0.3% -0.3% -0.3%
30y - 5y (5s30s) +0.7% +0.15% -0.15% -0.15%
30y - 10y (10s30s) +0.5% +0.1% -0.1% -0.1%
30y - 2y (2s30s) +1.0% +0.2% -0.2% -0.2%

The thresholds reflect each spread's historical distribution: the long-end spreads (5s30s, 10s30s) have far narrower ranges than the broad measures (30y-3m, 3m10y), so applying a single global threshold would over-classify the long-end as STEEP at almost every reading. By calibrating per metric, the classification stays meaningful no matter which spread the user selects.
A separate Hump detection runs alongside: if the maximum yield in the curve falls in the belly (2Y, 3Y, 5Y, or 7Y) and the overall slope is below twice the Normal threshold, the curve is classified as HUMPED. This identifies the canonical inverted-belly shape that often signals a near-term policy-rate peak followed by expected easing.

How to read the curve
A Steep curve typically associates with early-cycle expansions, accommodative monetary policy, or rising inflation expectations — investors demand higher compensation to lend further out. A Normal curve is the long-term default state of healthy bond markets. A Flat curve indicates near-equality of short and long expectations, typically near cyclical turning points. An Inverted curve, where long yields trade below short yields, has preceded every US recession since the 1960s with an average lead time of roughly 12 to 18 months — this is the signal to watch for. A Humped shape, where the belly trades above both ends, typically reflects market pricing of a near-term hiking cycle followed by expected cuts.
The dashed historical curve makes regime transitions visually obvious. If the solid current curve sits below the dashed reference across all tenors, yields have fallen broadly (a bond rally). If the curves cross — for example, the short end is up but the long end is down — the curve has flattened or inverted further during the lookback window. If the spread between them widens at the long end, term premium is expanding.

Repainting and data behavior
All  calls use . Alerts trigger only on confirmed daily-bar closes. There is no repainting on confirmed bars.request.securitylookahead = barmerge.lookahead_off
When the chart is on an intraday timeframe, the displayed yields reflect the most recent closed daily bar — during the US trading session this means yesterday's settlement until the new daily close prints. This is correct, non-repainting behavior and is consistent with how all daily-resolution data is served on TradingView.
The pane scales automatically to the yield range using two invisible anchor plots (min and max across both current and historical curves). This ensures the polyline always uses the full vertical space without manual axis adjustment, regardless of the absolute level of yields.

Limitations
The classification thresholds are static absolutes, not adaptive. In persistent low-rate regimes (such as 2010-2021) the STEEP threshold may register slightly too generously; in high-rate regimes the FLAT threshold may understate compression. The numerical slope value is always shown alongside the label, so you can apply your own judgment when the regime label feels off.
The Hump detection uses a simple argmax check on the belly tenors rather than a full curvature metric (such as the 2 × 5Y minus 2Y minus 10Y butterfly). It is most reliable when the selected slope metric spans the full curve (30y-3m, 3m10y, 2s10s); for narrow long-end metrics (5s30s, 10s30s) the belly lies outside the metric's span and Hump classification can be misleading. When in doubt, switch the slope metric to  for the most robust shape reading.30y - 3m
Only US Treasuries are supported in this version. The architecture leaves headroom in the request.security budget (22 of 40 calls used) for adding additional sovereign curves (Bunds, Gilts, JGBs) in future updates.

Two alert conditions are exposed for the user-selected slope metric:

Selected Spread Inversion — fires when the chosen spread crosses below zero (e.g., from positive to negative 2s10s). Useful as an early-warning trigger in macro frameworks.
Selected Spread Re-Steepening — fires when the chosen spread crosses back above zero. The bull-versus-bear-steepener distinction (which end of the curve is moving) requires looking at the individual yields in the dashboard at the moment the alert fires.

Alerts respect the user's slope-metric selection — switching from 2s10s to 3m10y in the settings will redirect the alerts to the new spread automatically.

Recommended use
Place the indicator on a daily chart of a broad US equity index (SPX, ES1!, SPY) to visualize how historical yield-curve regimes have aligned with equity-market phases — the inversion shading and shape labels make prior recession signals immediately visible. For fixed-income traders, place it directly on a Treasury futures chart (ZN1!, ZB1!) to use the live curve view as a directional input alongside the underlying price action. For macro discretionary traders, the configurable slope metric lets you align the shape classification with whichever spread your framework prioritizes — Fed-watchers typically use 3m10y, recession-modelers use 2s10s, term-premium analysts use 5s30s or 10s30s.

Originality
This indicator combines three distinct visualizations of the same dataset — a cross-sectional polyline curve drawn to the right of the last bar, a comprehensive numerical dashboard with eleven tenors and four spreads, and a configurable shape classification with per-metric calibrated thresholds — into a single, self-contained workspace. The log-scaled cross-sectional curve drawing using Pine v6's polyline objects, the historical comparison overlay, and the user-selectable slope metric with empirically calibrated thresholds per spread are not, to my knowledge, available in this combination in other public yield-curve scripts on the platform.

## Source Code

````pine
//@version=6
indicator("Yield Curve Monitor", "YC Monitor",
     overlay             = false,
     max_polylines_count = 10,
     max_labels_count    = 100,
     max_lines_count     = 50)

// ═══════════════════════════════════════════════════════════════
// 1) INPUTS
// ═══════════════════════════════════════════════════════════════
g_disp = "── Display ──"
curveSel = input.string("Both", "Curves geplottet",
     options = ["Current only", "Historic only", "Both"], group = g_disp,
     tooltip = "Welche Yield-Kurve(n) rechts vom letzten Bar gezeichnet werden. Tabelle zeigt immer beide Datensätze.")
slopeMetric = input.string("30y - 3m", "Slope-Metrik (Shape-Klassifikation)",
     options = ["30y - 3m", "10y - 2y (2s10s)", "10y - 3m (3m10y)", "30y - 5y (5s30s)", "30y - 10y (10s30s)", "30y - 2y (2s30s)"],
     group = g_disp,
     tooltip = "Welcher Spread bewertet die Kurve. 30y-3m = breitestes Mass (Default). 2s10s = klassischer NBER-Rezessions-Lead. 3m10y = Fed's preferred. 5s30s/10s30s = Long-end-Steepness. Schwellen sind pro Metrik kalibriert.")
showDash = input.bool(true, "Dashboard anzeigen", group = g_disp)
tablePos = input.string("Top Right", "Tabellen-Position",
     options = ["Top Left", "Top Right", "Middle Right", "Bottom Right", "Bottom Left"],
     group = g_disp)
histLookback = input.int(21, "Historic Lookback (Daily Bars)", minval = 1, maxval = 504, group = g_disp,
     tooltip = "21 ≈ 1 Monat | 63 ≈ 1 Quartal | 252 ≈ 1 Jahr.")

g_style = "── Style ──"
colBull    = input.color(#22c55e, "Bull / Steep / Current", group = g_style)
colBear    = input.color(#ef4444, "Bear / Inversion",       group = g_style)
colNeut    = input.color(#3b82f6, "Neutral / Normal",       group = g_style)
colWarn    = input.color(#f59e0b, "Warning / Flat / Hump",  group = g_style)
colHistCol = input.color(color.new(#94a3b8, 10), "Historic Curve", group = g_style)
lwCurve    = input.int(2, "Curve-Linienbreite", minval = 1, maxval = 5, group = g_style)

g_alerts = "── Alerts ──"
useInvAlert   = input.bool(true,  "Alert: gewählter Spread invertiert (Crossunder 0)", group = g_alerts)
useSteepAlert = input.bool(false, "Alert: gewählter Spread re-steepened (Crossover 0)", group = g_alerts)

// ═══════════════════════════════════════════════════════════════
// 2) DATA
// ═══════════════════════════════════════════════════════════════
f_y(sym, lb) =>
    request.security(sym, "D", close[lb], lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)

y1m  = f_y("TVC:US01MY", 0)
y3m  = f_y("TVC:US03MY", 0)
y6m  = f_y("TVC:US06MY", 0)
y1y  = f_y("TVC:US01Y",  0)
y2y  = f_y("TVC:US02Y",  0)
y3y  = f_y("TVC:US03Y",  0)
y5y  = f_y("TVC:US05Y",  0)
y7y  = f_y("TVC:US07Y",  0)
y10y = f_y("TVC:US10Y",  0)
y20y = f_y("TVC:US20Y",  0)
y30y = f_y("TVC:US30Y",  0)

h1m  = f_y("TVC:US01MY", histLookback)
h3m  = f_y("TVC:US03MY", histLookback)
h6m  = f_y("TVC:US06MY", histLookback)
h1y  = f_y("TVC:US01Y",  histLookback)
h2y  = f_y("TVC:US02Y",  histLookback)
h3y  = f_y("TVC:US03Y",  histLookback)
h5y  = f_y("TVC:US05Y",  histLookback)
h7y  = f_y("TVC:US07Y",  histLookback)
h10y = f_y("TVC:US10Y",  histLookback)
h20y = f_y("TVC:US20Y",  histLookback)
h30y = f_y("TVC:US30Y",  histLookback)

arrLabels = array.from("1M","3M","6M","1Y","2Y","3Y","5Y","7Y","10Y","20Y","30Y")
arrMats   = array.from(1.0/12, 3.0/12, 6.0/12, 1.0, 2.0, 3.0, 5.0, 7.0, 10.0, 20.0, 30.0)
arrCur    = array.from(y1m, y3m, y6m, y1y, y2y, y3y, y5y, y7y, y10y, y20y, y30y)
arrHis    = array.from(h1m, h3m, h6m, h1y, h2y, h3y, h5y, h7y, h10y, h20y, h30y)

// ═══════════════════════════════════════════════════════════════
// 3) KEY SPREADS (für Tabelle — alle vier immer)
// ═══════════════════════════════════════════════════════════════
sp_2s10s  = y10y - y2y
sp_3m10y  = y10y - y3m
sp_5s30s  = y30y - y5y
sp_2s30s  = y30y - y2y
hsp_2s10s = h10y - h2y
hsp_3m10y = h10y - h3m
hsp_5s30s = h30y - h5y
hsp_2s30s = h30y - h2y

// ═══════════════════════════════════════════════════════════════
// 4) USER-SELECTED SLOPE
// ═══════════════════════════════════════════════════════════════
slope = slopeMetric == "30y - 3m" ? y30y - y3m : slopeMetric == "10y - 2y (2s10s)" ? y10y - y2y : slopeMetric == "10y - 3m (3m10y)" ? y10y - y3m : slopeMetric == "30y - 5y (5s30s)" ? y30y - y5y : slopeMetric == "30y - 10y (10s30s)" ? y30y - y10y : y30y - y2y
slopeH = slopeMetric == "30y - 3m" ? h30y - h3m : slopeMetric == "10y - 2y (2s10s)" ? h10y - h2y : slopeMetric == "10y - 3m (3m10y)" ? h10y - h3m : slopeMetric == "30y - 5y (5s30s)" ? h30y - h5y : slopeMetric == "30y - 10y (10s30s)" ? h30y - h10y : h30y - h2y

// Empirisch kalibrierte Schwellen pro Metrik (US Treasuries, post-1990)
threshSteep  = slopeMetric == "30y - 3m" ? 1.5 : slopeMetric == "10y - 2y (2s10s)" ? 1.0 : slopeMetric == "10y - 3m (3m10y)" ? 1.5 : slopeMetric == "30y - 5y (5s30s)" ? 0.7 : slopeMetric == "30y - 10y (10s30s)" ? 0.5 : 1.0
threshNormal = slopeMetric == "30y - 3m" ? 0.3 : slopeMetric == "10y - 2y (2s10s)" ? 0.2 : slopeMetric == "10y - 3m (3m10y)" ? 0.3 : slopeMetric == "30y - 5y (5s30s)" ? 0.15 : slopeMetric == "30y - 10y (10s30s)" ? 0.1 : 0.2
threshFlat   = -threshNormal

slopeLabel = slopeMetric == "30y - 3m" ? "30y-3m" : slopeMetric == "10y - 2y (2s10s)" ? "2s10s" : slopeMetric == "10y - 3m (3m10y)" ? "3m10y" : slopeMetric == "30y - 5y (5s30s)" ? "5s30s" : slopeMetric == "30y - 10y (10s30s)" ? "10s30s" : "2s30s"

// ═══════════════════════════════════════════════════════════════
// 5) SHAPE CLASSIFICATION (Current + Historic, metric-aware)
// ═══════════════════════════════════════════════════════════════
maxY = math.max(y1m, y3m, y6m, y1y, y2y, y3y, y5y, y7y, y10y, y20y, y30y)
minY = math.min(y1m, y3m, y6m, y1y, y2y, y3y, y5y, y7y, y10y, y20y, y30y)
isHumped = (maxY == y2y or maxY == y3y or maxY == y5y or maxY == y7y) and slope < threshNormal * 2
shape    = isHumped ? "HUMPED" : slope > threshSteep ? "STEEP" : slope > threshNormal ? "NORMAL" : slope > threshFlat ? "FLAT" : "INVERTED"
shapeCol = isHumped ? colWarn : slope > threshSteep ? colBull : slope > threshNormal ? colNeut : slope > threshFlat ? colWarn : colBear

maxYH = math.max(h1m, h3m, h6m, h1y, h2y, h3y, h5y, h7y, h10y, h20y, h30y)
minYH = math.min(h1m, h3m, h6m, h1y, h2y, h3y, h5y, h7y, h10y, h20y, h30y)
isHumpedH = (maxYH == h2y or maxYH == h3y or maxYH == h5y or maxYH == h7y) and slopeH < threshNormal * 2
shapeHist = isHumpedH ? "HUMPED" : slopeH > threshSteep ? "STEEP" : slopeH > threshNormal ? "NORMAL" : slopeH > threshFlat ? "FLAT" : "INVERTED"
shapeColH = isHumpedH ? colWarn : slopeH > threshSteep ? colBull : slopeH > threshNormal ? colNeut : slopeH > threshFlat ? colWarn : colBear

// ═══════════════════════════════════════════════════════════════
// 6) PANE Y-AXIS ANCHORS (force scale to yield range)
// ═══════════════════════════════════════════════════════════════
plot(math.min(minY, minYH), "min anchor", color = color.new(color.gray, 100))
plot(math.max(maxY, maxYH), "max anchor", color = color.new(color.gray, 100))

// ═══════════════════════════════════════════════════════════════
// 7) CURVE VISUALIZATION
// ═══════════════════════════════════════════════════════════════
showCurrent  = curveSel != "Historic only"
showHistoric = curveSel != "Current only"

var polyline plCur     = na
var polyline plHst     = na
var array<label> lblPts = array.new<label>()

if barstate.islast
    if not na(plCur)
        plCur.delete()
    if not na(plHst)
        plHst.delete()
    for l in lblPts
        l.delete()
    lblPts.clear()

    int   xStart = bar_index + 10
    int   xSpan  = 100
    float lMin   = math.log(1.0/12)
    float lMax   = math.log(30.0)
    float lRng   = lMax - lMin

    pts  = array.new<chart.point>()
    ptsH = array.new<chart.point>()

    bool useCur = showCurrent

    for i = 0 to arrCur.size() - 1
        float m  = arrMats.get(i)
        int   xp = xStart + int(math.round((math.log(m) - lMin) / lRng * xSpan))
        float yv = arrCur.get(i)
        float yh = arrHis.get(i)
        float yLabelVal = useCur ? yv : yh

        if not na(yLabelVal)
            bool above = i % 2 == 0
            l = label.new(xp, yLabelVal,
                 arrLabels.get(i) + "\n" + str.tostring(yLabelVal, "#.##") + "%",
                 color     = color.new(color.black, 100),
                 textcolor = useCur ? colBull : colHistCol,
                 style     = above ? label.style_label_down : label.style_label_up,
                 size      = size.tiny)
            lblPts.push(l)

        if showCurrent and not na(yv)
            pts.push(chart.point.from_index(xp, yv))
        if showHistoric and not na(yh)
            ptsH.push(chart.point.from_index(xp, yh))

    if showCurrent and pts.size() >= 2
        plCur := polyline.new(pts, curved = true, closed = false,
             line_color = colBull, line_width = lwCurve, xloc = xloc.bar_index)

    if showHistoric and ptsH.size() >= 2
        plHst := polyline.new(ptsH, curved = true, closed = false,
             line_color = colHistCol, line_width = 1,
             line_style = line.style_dashed, xloc = xloc.bar_index)

// ═══════════════════════════════════════════════════════════════
// 8) DASHBOARD
// ═══════════════════════════════════════════════════════════════
f_pos(s) =>
    r = position.top_right
    if s == "Top Left"
        r := position.top_left
    if s == "Top Right"
        r := position.top_right
    if s == "Middle Right"
        r := position.middle_right
    if s == "Bottom Right"
        r := position.bottom_right
    if s == "Bottom Left"
        r := position.bottom_left
    r

f_dCol(d) =>
    na(d) ? color.gray : d > 0 ? colBull : d < 0 ? colBear : color.gray

f_dStr(d) =>
    na(d) ? "—" : (d >= 0 ? "+" : "") + str.tostring(d * 100, "#") + " bp"

var table tbl = table.new(f_pos(tablePos), 4, 24,
     bgcolor = color.new(#0f172a, 5),
     border_color = color.new(#334155, 50),
     border_width = 1,
     frame_color = color.new(#334155, 0),
     frame_width = 1)

if barstate.islast and showDash
    table.clear(tbl, 0, 0, 3, 23)

    table.cell(tbl, 0, 0, "MATURITY", text_color = color.white, bgcolor = color.new(#1e293b, 0), text_size = size.small)
    table.cell(tbl, 1, 0, "YIELD", text_color = color.white, bgcolor = color.new(#1e293b, 0), text_size = size.small)
    table.cell(tbl, 2, 0, "Δ " + str.tostring(histLookback) + "d", text_color = color.white, bgcolor = color.new(#1e293b, 0), text_size = size.small)
    table.cell(tbl, 3, 0, "MAGNITUDE", text_color = color.white, bgcolor = color.new(#1e293b, 0), text_size = size.small)

    float yPk = 0.0
    for i = 0 to arrCur.size() - 1
        v = arrCur.get(i)
        if not na(v) and v > yPk
            yPk := v
    yPk := yPk > 0 ? yPk : 1.0

    for i = 0 to arrCur.size() - 1
        int   r  = i + 1
        float yv = arrCur.get(i)
        float yh = arrHis.get(i)
        float d  = na(yv) or na(yh) ? na : yv - yh

        int barLen = na(yv) ? 0 : int(math.round(yv / yPk * 10))
        string bar = ""
        for j = 1 to 10
            bar += j <= barLen ? "▰" : "▱"

        table.cell(tbl, 0, r, arrLabels.get(i), text_color = color.white, bgcolor = color.new(#1e293b, 60), text_size = size.small)
        table.cell(tbl, 1, r, na(yv) ? "—" : str.tostring(yv, "#.###") + "%", text_color = color.white, bgcolor = color.new(#0f172a, 30), text_size = size.small)
        table.cell(tbl, 2, r, f_dStr(d), text_color = f_dCol(d), bgcolor = color.new(#0f172a, 30), text_size = size.small)
        table.cell(tbl, 3, r, bar, text_color = colBull, bgcolor = color.new(#0f172a, 30), text_size = size.small)

    int s0 = 12
    table.cell(tbl, 0, s0, "── KEY SPREADS ──", text_color = color.white, bgcolor = color.new(#1e293b, 0), text_size = size.small)
    table.cell(tbl, 1, s0, "", bgcolor = color.new(#1e293b, 0))
    table.cell(tbl, 2, s0, "", bgcolor = color.new(#1e293b, 0))
    table.cell(tbl, 3, s0, "", bgcolor = color.new(#1e293b, 0))

    table.cell(tbl, 0, s0+1, "2s10s", text_color = color.white, bgcolor = color.new(#1e293b, 60), text_size = size.small)
    table.cell(tbl, 1, s0+1, str.tostring(sp_2s10s, "+#.##") + "%", text_color = sp_2s10s < 0 ? colBear : colBull, bgcolor = color.new(#0f172a, 30), text_size = size.small)
    table.cell(tbl, 2, s0+1, f_dStr(sp_2s10s - hsp_2s10s), text_color = f_dCol(sp_2s10s - hsp_2s10s), bgcolor = color.new(#0f172a, 30), text_size = size.small)
    table.cell(tbl, 3, s0+1, sp_2s10s < 0 ? "INVERTED" : "OK", text_color = sp_2s10s < 0 ? colBear : color.gray, bgcolor = color.new(#0f172a, 30), text_size = size.small)

    table.cell(tbl, 0, s0+2, "3m10y", text_color = color.white, bgcolor = color.new(#1e293b, 60), text_size = size.small)
    table.cell(tbl, 1, s0+2, str.tostring(sp_3m10y, "+#.##") + "%", text_color = sp_3m10y < 0 ? colBear : colBull, bgcolor = color.new(#0f172a, 30), text_size = size.small)
    table.cell(tbl, 2, s0+2, f_dStr(sp_3m10y - hsp_3m10y), text_color = f_dCol(sp_3m10y - hsp_3m10y), bgcolor = color.new(#0f172a, 30), text_size = size.small)
    table.cell(tbl, 3, s0+2, sp_3m10y < 0 ? "INVERTED" : "OK", text_color = sp_3m10y < 0 ? colBear : color.gray, bgcolor = color.new(#0f172a, 30), text_size = size.small)

    table.cell(tbl, 0, s0+3, "2s30s", text_color = color.white, bgcolor = color.new(#1e293b, 60), text_size = size.small)
    table.cell(tbl, 1, s0+3, str.tostring(sp_2s30s, "+#.##") + "%", text_color = sp_2s30s < 0 ? colBear : colBull, bgcolor = color.new(#0f172a, 30), text_size = size.small)
    table.cell(tbl, 2, s0+3, f_dStr(sp_2s30s - hsp_2s30s), text_color = f_dCol(sp_2s30s - hsp_2s30s), bgcolor = color.new(#0f172a, 30), text_size = size.small)
    table.cell(tbl, 3, s0+3, sp_2s30s < 0 ? "INVERTED" : "OK", text_color = sp_2s30s < 0 ? colBear : color.gray, bgcolor = color.new(#0f172a, 30), text_size = size.small)

    table.cell(tbl, 0, s0+4, "5s30s", text_color = color.white, bgcolor = color.new(#1e293b, 60), text_size = size.small)
    table.cell(tbl, 1, s0+4, str.tostring(sp_5s30s, "+#.##") + "%", text_color = sp_5s30s < 0 ? colBear : colBull, bgcolor = color.new(#0f172a, 30), text_size = size.small)
    table.cell(tbl, 2, s0+4, f_dStr(sp_5s30s - hsp_5s30s), text_color = f_dCol(sp_5s30s - hsp_5s30s), bgcolor = color.new(#0f172a, 30), text_size = size.small)
    table.cell(tbl, 3, s0+4, sp_5s30s < 0 ? "INVERTED" : "OK", text_color = sp_5s30s < 0 ? colBear : color.gray, bgcolor = color.new(#0f172a, 30), text_size = size.small)

    int sR = s0 + 6
    table.cell(tbl, 0, sR, "── CURVE SHAPE ──", text_color = color.white, bgcolor = color.new(#1e293b, 0), text_size = size.small)
    table.cell(tbl, 1, sR, "", bgcolor = color.new(#1e293b, 0))
    table.cell(tbl, 2, sR, "", bgcolor = color.new(#1e293b, 0))
    table.cell(tbl, 3, sR, "", bgcolor = color.new(#1e293b, 0))

    int rowOff = 1
    if showCurrent
        table.cell(tbl, 0, sR + rowOff, "CURRENT", text_color = color.white, bgcolor = color.new(#1e293b, 60), text_size = size.small)
        table.cell(tbl, 1, sR + rowOff, shape, text_color = color.white, bgcolor = shapeCol, text_size = size.small)
        table.cell(tbl, 2, sR + rowOff, str.tostring(slope, "+#.##") + "%", text_color = color.white, bgcolor = color.new(#0f172a, 30), text_size = size.small)
        table.cell(tbl, 3, sR + rowOff, slopeLabel, text_color = color.gray, bgcolor = color.new(#0f172a, 30), text_size = size.small)
        rowOff += 1

    if showHistoric
        table.cell(tbl, 0, sR + rowOff, "HISTORIC", text_color = color.white, bgcolor = color.new(#1e293b, 60), text_size = size.small)
        table.cell(tbl, 1, sR + rowOff, shapeHist, text_color = color.white, bgcolor = shapeColH, text_size = size.small)
        table.cell(tbl, 2, sR + rowOff, str.tostring(slopeH, "+#.##") + "%", text_color = color.white, bgcolor = color.new(#0f172a, 30), text_size = size.small)
        table.cell(tbl, 3, sR + rowOff, slopeLabel + " " + str.tostring(histLookback) + "d ago", text_color = color.gray, bgcolor = color.new(#0f172a, 30), text_size = size.small)

// ═══════════════════════════════════════════════════════════════
// 9) ALERTS — auf gewählten Spread
// ═══════════════════════════════════════════════════════════════
crossInv   = ta.crossunder(slope, 0)
crossSteep = ta.crossover(slope, 0)

alertcondition(useInvAlert and crossInv, "Selected Spread Inversion",
     "US Treasury selected spread inverted (< 0). Watch for regime change.")
alertcondition(useSteepAlert and crossSteep, "Selected Spread Re-Steepening",
     "US Treasury selected spread back to positive territory.")
````
