# Institutional Volatility Structure Engine

- url: https://www.tradingview.com/script/89wTWVvl-Institutional-Volatility-Structure-Engine/
- type: indicator
- pine_id: PUB;1961f6014bd24608ac310b9346343ef0
- version: 1.0

## Description

What is This Indicator?

This is a professional-grade volatility term structure analyzer designed to show how institutional traders view market fear across different time horizons.
Instead of just looking at the regular VIX, this indicator tracks:

• VIX1D (1-day implied vol)
• VIX9D (9-day)
• VIX (30-day)
• VIX3M (3-month)
• VIX6M (6-month)
• VVIX (Volatility of Volatility)

It analyzes the shape of the volatility curve and classifies the market into clear regimes, helping you understand whether the market is calm, stressed, coiled, or about to explode.

🎨 Main Visual Elements
1. Colored Lines (Term Structure)

Red: VIX1D (shortest term fear)
Orange: VIX9D
White: VIX (standard)
Aqua: VIX3M
Blue: VIX6M
Fuchsia: VVIX (how volatile volatility itself is)

2. Value Labels (New Feature)

Real-time price labels on the right side of each line so you can instantly see current values without checking the scale.

3. Background Heatmap

Red = Full Backwardation (Extreme fear/stress)
Orange = Front-End Inversion (Short-term trouble brewing)
Green = Compression Regime (Market is calm but coiled → high probability of volatility expansion)
Teal/Blue = Healthy Contango (Normal bull market behavior)
Purple = Volatility Expansion
Gray/Yellow = Transition

4. Curve Oscillator (Area Plot)

Red = Medium-term fear building
Green = Fear easing

5. Compression Score (Yellow Line)

Low = Terms are very close together (coiled spring)
High = Volatility is spreading out


📊 Dashboard Table (Top Right)
Gives you an instant professional summary:

Current values of all VIX terms
Z-Scores (how extreme current levels are)
Front Ratio (VIX1D ÷ VIX)
Breadth (how many terms are rising together)
Regime status
Percentile rankings


🔍 How to Use It Profitably (Practical Guide)
1. Regime Trading (Highest Edge)

Green Background (Compression) → Best environment for buying volatility (long VIX futures, UVXY, VXX, or long options). The market is quiet but tension is building.
Red/Orange Background → High caution or short volatility setups after the event passes (volatility crush).
Purple (Expansion) → Volatility is already expanding — trend days or big moves likely.

2. Key Signals to Watch

Front Shock (VIX1D >> VIX): Sudden short-term panic.
VVIX Explosion: Volatility of volatility spiking → dangerous for short vol strategies.
Vol Crush: All front terms falling fast → good for premium selling.
Trend Day Warning: Front inversion + rising curve oscillator → expect strong directional move.

3. Best Timeframes

Daily: Best for understanding overall regime
4H / 1H: Excellent for tactical entries and exits
Weekly: Great for long-term portfolio hedging decisions


⚙️ Key Inputs Explained

Show Value Labels on Lines: Toggle the numbers that appear next to each line.
Compression Threshold: Lower = more sensitive to "coiled" markets.
Z-Score Lookback: How many bars used for statistical extremes (50 is good default).
Alert toggles: Enable only the alerts you care about.


💡 Pro Tips for New Users

Start Simple: First just watch the background color and the regime label.
Combine with Price Action: Green background + bullish candlestick pattern = strong setup.
Use Alerts: Set alerts for regime changes and front shocks so you don’t have to stare at the chart.
Context Matters: This indicator is extremely powerful around earnings seasons, FOMC meetings, and major news events.
Low VIX Environment (<15): Even small inversions become very meaningful.


🎯 Ideal Use Cases

• Options Traders: Know when to sell premium vs buy volatility
• Day Traders: Spot potential trend days early
• Swing Traders: Identify high-probability volatility expansion setups
• Portfolio Managers: Decide when to add tail-risk hedges


Bottom Line:
This indicator turns complex institutional volatility data into clear, actionable regimes. The background color is your main "mood of the market" indicator.

## Source Code

````pine
//@version=6
indicator("Institutional Volatility Structure Engine [v6]", overlay=false, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

// ─── INPUTS ──────────────────────────────────────────────────────────────────
showHeatmap     = input.bool(true,  "Show Regime Heatmap",          group="Display")
showTable       = input.bool(true,  "Show Dashboard Table",         group="Display")
showOscillator  = input.bool(true,  "Show Curve Oscillator",        group="Display")
showCompression = input.bool(true,  "Show Compression Score",       group="Display")
showVVIX        = input.bool(true,  "Show VVIX (normalised)",       group="Display")
showSpreads     = input.bool(false, "Show Individual Spread Lines", group="Display")

zLen              = input.int(50,    "Z-Score Lookback",         minval=10, maxval=252, group="Parameters")
compressionThresh = input.float(4.0, "Compression Threshold",    step=0.1,              group="Parameters")
expansionMult     = input.float(2.0, "Expansion Multiplier",     step=0.1,              group="Parameters")
shockRatioThresh  = input.float(1.15,"Front Shock Threshold",    step=0.01,             group="Parameters")
vvixExpThresh     = input.float(5.0, "VVIX Explosion Threshold", step=0.5,              group="Parameters")
volCrushLen       = input.int(3,     "Vol Crush Lookback",       minval=2, maxval=10,   group="Parameters")

enableAlerts = input.bool(true, "Enable All Alerts",        group="Alerts")
alertShock   = input.bool(true, "Alert: Front Vol Shock",   group="Alerts")
alertInv     = input.bool(true, "Alert: Front Inversion",   group="Alerts")
alertVVIX    = input.bool(true, "Alert: VVIX Explosion",    group="Alerts")
alertCrush   = input.bool(true, "Alert: Vol Crush",         group="Alerts")
alertTrend   = input.bool(true, "Alert: Trend Day Warning", group="Alerts")
alertRegime  = input.bool(true, "Alert: Regime Shift",      group="Alerts")

// ─── DATA FEEDS ──────────────────────────────────────────────────────────────
// FIX: ignore_invalid_symbol is not a valid named param in Pine v6 — removed.
// na() null guards below handle any missing feeds gracefully.
_vix1d = request.security("CBOE:VIX1D", timeframe.period, close)
_vix9d = request.security("CBOE:VIX9D", timeframe.period, close)
_vix   = request.security("CBOE:VIX",   timeframe.period, close)
_vix3m = request.security("CBOE:VIX3M", timeframe.period, close)
_vix6m = request.security("CBOE:VIX6M", timeframe.period, close)
_vvix  = request.security("CBOE:VVIX",  timeframe.period, close)

vix   = na(_vix)   ? nz(close, 20.0) : _vix
vvix  = na(_vvix)  ? vix * 5.5       : _vvix
vix3m = na(_vix3m) ? vix * 1.08      : _vix3m
vix6m = na(_vix6m) ? vix * 1.15      : _vix6m
vix1d = na(_vix1d) ? vix * 0.90      : _vix1d
vix9d = na(_vix9d) ? vix * 0.97      : _vix9d

usingProxy = na(_vix1d) or na(_vix9d) or na(_vix3m) or na(_vix6m)
vvix_norm  = vix * (vvix / 100.0)

// ─── TERM STRUCTURE METRICS ──────────────────────────────────────────────────
frontSpread     = vix1d - vix9d
weeklySpread    = vix9d - vix
swingSpread     = vix   - vix3m
macroSpread     = vix3m - vix6m
curveOscillator = (weeklySpread + swingSpread) / 2.0
termSlope       = (vix6m - vix1d) / 4.0
frontShockRatio = vix1d / math.max(vix, 0.01)
cs1 = math.abs(vix1d - vix9d)
cs2 = math.abs(vix9d - vix)
cs3 = math.abs(vix   - vix3m)
cs4 = math.abs(vix3m - vix6m) * 0.5
compressionScore = cs1 + cs2 + cs3 + cs4

// ─── STATISTICAL MEASURES ────────────────────────────────────────────────────
zscore(src, len) =>
    mean = ta.sma(src, len)
    dev  = ta.stdev(src, len)
    dev != 0.0 ? (src - mean) / dev : 0.0

zVix1d = zscore(vix1d, zLen)
zVVIX  = zscore(vvix,  zLen)

pctRank(src, len) =>
    float cnt = 0.0
    for i = 1 to len
        if src[i] < src
            cnt += 1.0
    math.round(cnt / len * 100.0)

vixPctRank  = pctRank(vix,  zLen)
vvixPctRank = pctRank(vvix, zLen)

// ─── REGIME CLASSIFICATION ───────────────────────────────────────────────────
fullBackwardation = vix1d > vix9d and vix9d > vix and vix > vix3m and vix3m > vix6m
frontInversion    = vix1d > vix9d and vix9d > vix and not fullBackwardation
partialInversion  = vix1d > vix9d and not frontInversion and not fullBackwardation
strongContango    = vix1d < vix9d and vix9d < vix and vix < vix3m and vix3m < vix6m
healthyContango   = termSlope > 0 and not strongContango and not frontInversion and not fullBackwardation
compressionRegime = compressionScore < compressionThresh and not fullBackwardation and not frontInversion
expansionRegime   = compressionScore > compressionThresh * expansionMult

regimeText = if fullBackwardation
    "FULL BACKWARDATION"
else if frontInversion
    "FRONT INVERSION"
else if partialInversion
    "PARTIAL INVERSION"
else if compressionRegime
    "COMPRESSION"
else if expansionRegime
    "VOL EXPANSION"
else if strongContango
    "STRONG CONTANGO"
else if healthyContango
    "HEALTHY CONTANGO"
else
    "TRANSITION"

regimeColor = if fullBackwardation
    color.red
else if frontInversion
    color.orange
else if partialInversion
    color.yellow
else if compressionRegime
    color.lime
else if expansionRegime
    color.purple
else if strongContango
    color.teal
else if healthyContango
    color.blue
else
    color.gray

var string prevRegime = ""
regimeChanged = regimeText != prevRegime
if regimeChanged
    prevRegime := regimeText

b1 = ta.change(vix1d) > 0 ? 1 : 0
b2 = ta.change(vix9d) > 0 ? 1 : 0
b3 = ta.change(vix)   > 0 ? 1 : 0
b4 = ta.change(vix3m) > 0 ? 1 : 0
b5 = ta.change(vix6m) > 0 ? 1 : 0
breadthUp = b1 + b2 + b3 + b4 + b5

// ─── ALERT CONDITIONS ────────────────────────────────────────────────────────
frontShock      = frontShockRatio > shockRatioThresh
vvixExplosion   = ta.change(vvix) > vvixExpThresh
volCrush        = ta.falling(vix1d, volCrushLen) and ta.falling(vix9d, volCrushLen) and ta.falling(vix, volCrushLen)
trendDayWarning = frontInversion and curveOscillator > 0

// ─── BACKGROUND HEATMAP ──────────────────────────────────────────────────────
bgRaw = if fullBackwardation
    color.new(color.red,    78)
else if frontInversion
    color.new(color.orange, 80)
else if partialInversion
    color.new(color.yellow, 88)
else if expansionRegime
    color.new(color.purple, 82)
else if compressionRegime
    color.new(color.green,  85)
else if strongContango
    color.new(color.teal,   85)
else if healthyContango
    color.new(color.blue,   90)
else
    color.new(color.gray,   92)

bgcolor(showHeatmap ? bgRaw : na, title="Regime Heatmap")

// ─── PLOTS ───────────────────────────────────────────────────────────────────
p1d = plot(vix1d, title="VIX1D (0-day)",   linewidth=2, color=color.new(color.red,    0))
p30 = plot(vix,   title="VIX   (30-day)",  linewidth=2, color=color.new(color.white,  0))
plot(vix9d, title="VIX9D (9-day)",   linewidth=2, color=color.new(color.orange, 0))
plot(vix3m, title="VIX3M (93-day)",  linewidth=2, color=color.new(color.aqua,   0))
plot(vix6m, title="VIX6M (6-month)", linewidth=2, color=color.new(color.blue,   0))
plot(showVVIX ? vvix_norm : na, title="VVIX norm", linewidth=1, color=color.new(color.fuchsia, 0))
fill(p1d, p30, color=vix1d > vix ? color.new(color.red, 88) : color.new(color.green, 92), title="Front Stress Fill")
plot(showSpreads ? frontSpread  : na, title="Front Spread",  color=color.new(color.red,    40), linewidth=1)
plot(showSpreads ? weeklySpread : na, title="Weekly Spread", color=color.new(color.orange, 40), linewidth=1)
plot(showSpreads ? swingSpread  : na, title="Swing Spread",  color=color.new(color.aqua,   40), linewidth=1)
plot(showOscillator  ? curveOscillator  : na, title="Curve Oscillator",  linewidth=2, style=plot.style_area, color=curveOscillator > 0 ? color.new(color.red, 40) : color.new(color.green, 40))
plot(showCompression ? compressionScore : na, title="Compression Score", linewidth=2, color=color.new(color.yellow, 0))
hline(compressionThresh, "Comp Threshold", color=color.new(color.yellow, 55), linestyle=hline.style_dashed)
hline(0, "Zero", color=color.new(color.gray, 55), linestyle=hline.style_dotted)

// ─── REGIME LABEL ────────────────────────────────────────────────────────────
var label regimeLabel = na
if barstate.islast
    label.delete(regimeLabel)
    topNode = math.max(math.max(vix1d, vix9d), math.max(vix, math.max(vix3m, vix6m)))
    labelY  = topNode * 1.05
    regimeLabel := label.new(bar_index, labelY, regimeText, style=label.style_label_down, color=regimeColor, textcolor=color.white, size=size.large, textalign=text.align_center)

// ─── DASHBOARD TABLE ─────────────────────────────────────────────────────────
// FIX: No blank lines inside if blocks — Pine v6 ends the block at blank lines.
// Pre-compute string values that need expressions to keep array.from() clean.
frontInvStr  = frontInversion ? "YES" : fullBackwardation ? "FULL BACK" : "NO"
dataFeedStr  = usingProxy ? "PROXY ACTIVE" : "LIVE CBOE"
breadthStr   = str.tostring(breadthUp) + "/5"
vixPctStr    = str.tostring(vixPctRank)  + "%"
vvixPctStr   = str.tostring(vvixPctRank) + "%"

var table dashboard = table.new(position.top_right, 2, 19, bgcolor=color.new(color.black, 68), border_width=1, border_color=color.new(color.gray, 55))

if barstate.islast and showTable
    // -- header --
    hBg = color.new(color.blue, 55)
    table.cell(dashboard, 0, 0, "METRIC", bgcolor=hBg, text_color=color.white, text_size=size.small)
    table.cell(dashboard, 1, 0, "VALUE",  bgcolor=hBg, text_color=color.white, text_size=size.small)
    // -- label column --
    lbls = array.from("VIX1D", "VIX9D", "VIX", "VIX3M", "VIX6M", "VVIX (raw)", "VVIX norm", "Curve Osc", "Comp Score", "Front Ratio", "Breadth Up", "Z VIX1D", "Z VVIX", "VIX %ile", "VVIX %ile", "Front Inv", "Regime", "Data Feed")
    // -- value column --
    vals = array.from(
         str.tostring(vix1d,            "#.##"),
         str.tostring(vix9d,            "#.##"),
         str.tostring(vix,              "#.##"),
         str.tostring(vix3m,            "#.##"),
         str.tostring(vix6m,            "#.##"),
         str.tostring(vvix,             "#.##"),
         str.tostring(vvix_norm,        "#.##"),
         str.tostring(curveOscillator,  "#.##"),
         str.tostring(compressionScore, "#.##"),
         str.tostring(frontShockRatio,  "#.##"),
         breadthStr, str.tostring(zVix1d, "#.##"),
         str.tostring(zVVIX, "#.##"),
         vixPctStr, vvixPctStr,
         frontInvStr, regimeText, dataFeedStr)
    // -- render rows --
    for i = 0 to array.size(lbls) - 1
        row   = i + 1
        lbl   = array.get(lbls, i)
        val   = array.get(vals, i)
        rowBg = color.new(color.black, i % 2 == 0 ? 72 : 82)
        vc = color.white
        if lbl == "Data Feed" and usingProxy
            vc := color.orange
        else if lbl == "Regime" and fullBackwardation
            vc := color.red
        else if lbl == "Regime" and frontInversion
            vc := color.orange
        else if lbl == "Regime" and partialInversion
            vc := color.yellow
        else if lbl == "Regime" and compressionRegime
            vc := color.lime
        else if lbl == "Regime" and expansionRegime
            vc := color.purple
        else if lbl == "Regime" and strongContango
            vc := color.teal
        else if lbl == "Regime" and healthyContango
            vc := color.blue
        else if lbl == "Front Inv" and (frontInversion or fullBackwardation)
            vc := color.red
        else if lbl == "Curve Osc" and curveOscillator > 0
            vc := color.new(color.red, 20)
        else if lbl == "Curve Osc" and curveOscillator < 0
            vc := color.new(color.lime, 20)
        else if lbl == "Comp Score" and compressionScore < compressionThresh
            vc := color.lime
        else if lbl == "Comp Score" and compressionScore > compressionThresh * expansionMult
            vc := color.red
        else if lbl == "Front Ratio" and frontShockRatio > shockRatioThresh
            vc := color.orange
        else if lbl == "Breadth Up" and breadthUp >= 4
            vc := color.red
        else if lbl == "Breadth Up" and breadthUp <= 1
            vc := color.lime
        else if lbl == "Z VIX1D" and zVix1d > 2.0
            vc := color.red
        else if lbl == "Z VIX1D" and zVix1d < -2.0
            vc := color.lime
        else if lbl == "Z VVIX" and zVVIX > 2.0
            vc := color.fuchsia
        else if lbl == "VIX %ile" and vixPctRank > 80
            vc := color.red
        else if lbl == "VIX %ile" and vixPctRank < 20
            vc := color.lime
        else if lbl == "VVIX %ile" and vvixPctRank > 80
            vc := color.fuchsia
        table.cell(dashboard, 0, row, lbl, text_color=color.new(color.gray, 20), bgcolor=rowBg, text_size=size.small)
        table.cell(dashboard, 1, row, val, text_color=vc, bgcolor=rowBg, text_size=size.small)

// ─── ALERTS ──────────────────────────────────────────────────────────────────
if enableAlerts
    if alertShock and frontShock
        alert("FRONT VOL SHOCK | VIX1D/VIX=" + str.tostring(frontShockRatio, "#.##") + " | VIX1D=" + str.tostring(vix1d, "#.##") + " | VIX=" + str.tostring(vix, "#.##"), alert.freq_once_per_bar)
    if alertInv and frontInversion
        alert("FRONT-END INVERSION | VIX1D=" + str.tostring(vix1d, "#.##") + " > VIX9D=" + str.tostring(vix9d, "#.##") + " > VIX=" + str.tostring(vix, "#.##"), alert.freq_once_per_bar)
    if alertVVIX and vvixExplosion
        alert("VVIX EXPLOSION | +" + str.tostring(ta.change(vvix), "#.##") + " pts | VVIX=" + str.tostring(vvix, "#.##"), alert.freq_once_per_bar)
    if alertCrush and volCrush
        alert("VOL CRUSH | All front terms falling " + str.tostring(volCrushLen) + " bars | VIX=" + str.tostring(vix, "#.##"), alert.freq_once_per_bar)
    if alertTrend and trendDayWarning
        alert("TREND DAY WARNING | Inversion + Curve Osc=" + str.tostring(curveOscillator, "#.##"), alert.freq_once_per_bar)
    if alertRegime and regimeChanged and not barstate.isfirst
        alert("REGIME SHIFT -> " + regimeText + " | Comp=" + str.tostring(compressionScore, "#.##"), alert.freq_once_per_bar)
````
