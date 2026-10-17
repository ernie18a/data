# Volume [Upgraded J Lubin] v2

- url: https://www.tradingview.com/script/2DQCd9Cc-Volume-Upgraded-J-Lubin-v2/
- type: indicator
- pine_id: PUB;2243edd33b34488885579b73abc153c7
- version: 1.0

## Description

Volume indicator upgraded. if there is any issue let me know in the comments. look forward to make more code help upgrades to this volume bar tool. thank you

## Source Code

````pine
//@version=6
indicator("Colored Volume Bars [LazyBear] v6", shorttitle="CVOLB v6", format=format.volume, precision=0)

// ===== GENERAL SETTINGS =====
g_gen     = "General Settings"
lookback  = input.int(10, "Lookback Length", minval=1, maxval=500, group=g_gen, tooltip="Bars back used to compare current price/volume against prior price/volume.")
barTransp = input.int(15, "Bar Transparency", minval=0, maxval=100, group=g_gen, tooltip="0 = solid, 100 = invisible.")

// ===== BAR STYLE & EFFECTS =====
g_bars           = "Bar Style & Effects"
barStyle         = input.string("Columns", "Bar Style", options=["Columns", "Histogram", "Area", "Line", "Stepline"], group=g_bars)
barWidth         = input.int(2, "Bar / Line Width", minval=1, maxval=10, group=g_bars)
heatmapEnabled   = input.bool(true, "Volume Heatmap (intensity by relative volume)", group=g_bars, tooltip="Modulates bar transparency by relative volume vs recent average.")
heatmapPeriod    = input.int(20, "Heatmap Reference Period", minval=2, maxval=500, group=g_bars)
highlightExtreme = input.bool(true, "Highlight Extreme Volume Bars", group=g_bars)
extremeMult      = input.float(2.0, "Extreme Volume Multiplier (x avg)", minval=1.0, maxval=10.0, step=0.1, group=g_bars, tooltip="A bar is flagged 'extreme' when volume > average x this multiplier. Also drives Strong Bull/Bear in ColorBoost theme.")
extremeColor     = input.color(#ffeb3b, "Extreme Volume Color", group=g_bars, tooltip="Used for the recolored bar AND for the marker.")
useExtremeMarker = input.bool(false, "Use Marker Instead of Recoloring", group=g_bars)
markerShape      = input.string("Triangle Down", "Marker Shape", options=["Triangle Down", "Arrow Down", "Circle", "X-Cross"], group=g_bars)
markerSize       = input.string("Small", "Marker Size", options=["Small", "Normal", "Large"], group=g_bars)

// ===== MOVING AVERAGE SETTINGS =====
g_ma     = "Moving Average Settings"
showMA   = input.bool(false, "Show Volume MA", group=g_ma)
lengthMA = input.int(20, "MA Length", minval=1, maxval=1000, group=g_ma)
maType   = input.string("SMA", "MA Type", options=["SMA", "EMA", "RMA", "WMA", "TEMA"], group=g_ma)
maColor  = input.color(#ffb74d, "MA Color", group=g_ma)
maWidth  = input.int(2, "MA Line Width", minval=1, maxval=5, group=g_ma)

// ===== VISUAL THEME =====
g_theme = "Visual Theme"
theme   = input.string("Modern Professional", "Theme", options=["Classic LazyBear", "Futuristic Neon", "Modern Professional", "Minimal Clean", "ColorBoost", "Custom"], group=g_theme)

custStrongBull = input.color(#00c853, "Custom: Strong Bull (Surge)",           group=g_theme)
custBull       = input.color(#26a69a, "Custom: Bull (Price Up + Vol Up)",      group=g_theme)
custWeakBull   = input.color(#80cbc4, "Custom: Weak Bull (Price Up + Vol Dn)", group=g_theme)
custNeut       = input.color(#9e9e9e, "Custom: Neutral",                       group=g_theme)
custWeakBear   = input.color(#ef9a9a, "Custom: Weak Bear (Price Dn + Vol Dn)", group=g_theme)
custBear       = input.color(#ef5350, "Custom: Bear (Price Dn + Vol Up)",      group=g_theme)
custStrongBear = input.color(#b71c1c, "Custom: Strong Bear (Surge)",           group=g_theme)

[cStrongBull, cBull, cWeakBull, cNeut, cWeakBear, cBear, cStrongBear] = switch theme
    "Classic LazyBear"    => [color.green, color.green, color.blue,    color.gray, color.orange, color.red,    color.red]
    "Futuristic Neon"     => [#00ff9c,     #00ff9c,     #00e1ff,       #6c6c6c,    #ff7a00,      #ff2bd6,      #ff2bd6]
    "Modern Professional" => [#26a69a,     #26a69a,     #80cbc4,       #b0bec5,    #ef9a9a,      #ef5350,      #ef5350]
    "Minimal Clean"       => [#2e7d32,     #2e7d32,     #a5d6a7,       #cfd8dc,    #ef9a9a,      #c62828,      #c62828]
    "ColorBoost"          => [#00c853,     #43a047,     #a5d6a7,       #90a4ae,    #ef9a9a,      #e53935,      #b71c1c]
    => [custStrongBull, custBull, custWeakBull, custNeut, custWeakBear, custBear, custStrongBear]

// ===== CORE LOGIC =====
p1 = close[lookback]
v1 = volume[lookback]

priceUp = close > p1
priceDn = close < p1
volUp   = volume > v1
volDn   = volume < v1

// ===== HEATMAP & STRONG/EXTREME DETECTION =====
heatRef         = ta.sma(volume, heatmapPeriod)
volRatio        = nz(volume / heatRef, 1.0)
volRatioClamped = math.max(0.2, math.min(volRatio, 3.0))
heatmapTransp   = 85.0 - ((volRatioClamped - 0.2) / 2.8) * 85.0

volIsHigh = not na(heatRef) and volume > heatRef * extremeMult
isExtreme = highlightExtreme and volIsHigh

baseColor = priceUp and volUp and volIsHigh ? cStrongBull : priceUp and volUp ? cBull : priceUp and volDn ? cWeakBull : priceDn and volUp and volIsHigh ? cStrongBear : priceDn and volUp ? cBear : priceDn and volDn ? cWeakBear : cNeut

extremeRecolor  = isExtreme and not useExtremeMarker
extremeShowMark = isExtreme and useExtremeMarker

finalBaseColor = extremeRecolor ? extremeColor : baseColor
finalTransp    = extremeRecolor ? float(barTransp) : (heatmapEnabled ? heatmapTransp : float(barTransp))
barCol         = color.new(finalBaseColor, finalTransp)

// ===== VOLUME MOVING AVERAGE =====
sma_v  = ta.sma(volume, lengthMA)
ema_v  = ta.ema(volume, lengthMA)
rma_v  = ta.rma(volume, lengthMA)
wma_v  = ta.wma(volume, lengthMA)
ema1   = ema_v
ema2   = ta.ema(ema1, lengthMA)
ema3   = ta.ema(ema2, lengthMA)
tema_v = 3 * (ema1 - ema2) + ema3

maVal = switch maType
    "SMA"  => sma_v
    "EMA"  => ema_v
    "RMA"  => rma_v
    "WMA"  => wma_v
    "TEMA" => tema_v
    => sma_v

// ===== PLOTS =====
plot(barStyle == "Columns"   ? volume : na, title="Volume (Columns)",   style=plot.style_columns,   color=barCol, linewidth=barWidth)
plot(barStyle == "Histogram" ? volume : na, title="Volume (Histogram)", style=plot.style_histogram, color=barCol, linewidth=barWidth)
plot(barStyle == "Area"      ? volume : na, title="Volume (Area)",      style=plot.style_area,      color=barCol, linewidth=barWidth)
plot(barStyle == "Line"      ? volume : na, title="Volume (Line)",      style=plot.style_line,      color=barCol, linewidth=barWidth)
plot(barStyle == "Stepline"  ? volume : na, title="Volume (Stepline)",  style=plot.style_stepline,  color=barCol, linewidth=barWidth)

plot(showMA ? maVal : na, title="Volume MA", color=maColor, linewidth=maWidth)

// ===== EXTREME VOLUME MARKER =====
// 4 shapes x 3 sizes = 12 plotshape calls. Only the matched combo renders. editable=false hides from Style tab.
plotshape(extremeShowMark and markerShape == "Triangle Down" and markerSize == "Small",  title="M TriDn Small",  style=shape.triangledown, location=location.abovebar, color=extremeColor, size=size.small,  editable=false)
plotshape(extremeShowMark and markerShape == "Triangle Down" and markerSize == "Normal", title="M TriDn Normal", style=shape.triangledown, location=location.abovebar, color=extremeColor, size=size.normal, editable=false)
plotshape(extremeShowMark and markerShape == "Triangle Down" and markerSize == "Large",  title="M TriDn Large",  style=shape.triangledown, location=location.abovebar, color=extremeColor, size=size.large,  editable=false)

plotshape(extremeShowMark and markerShape == "Arrow Down" and markerSize == "Small",  title="M ArrDn Small",  style=shape.arrowdown, location=location.abovebar, color=extremeColor, size=size.small,  editable=false)
plotshape(extremeShowMark and markerShape == "Arrow Down" and markerSize == "Normal", title="M ArrDn Normal", style=shape.arrowdown, location=location.abovebar, color=extremeColor, size=size.normal, editable=false)
plotshape(extremeShowMark and markerShape == "Arrow Down" and markerSize == "Large",  title="M ArrDn Large",  style=shape.arrowdown, location=location.abovebar, color=extremeColor, size=size.large,  editable=false)

plotshape(extremeShowMark and markerShape == "Circle" and markerSize == "Small",  title="M Circ Small",  style=shape.circle, location=location.abovebar, color=extremeColor, size=size.small,  editable=false)
plotshape(extremeShowMark and markerShape == "Circle" and markerSize == "Normal", title="M Circ Normal", style=shape.circle, location=location.abovebar, color=extremeColor, size=size.normal, editable=false)
plotshape(extremeShowMark and markerShape == "Circle" and markerSize == "Large",  title="M Circ Large",  style=shape.circle, location=location.abovebar, color=extremeColor, size=size.large,  editable=false)

plotshape(extremeShowMark and markerShape == "X-Cross" and markerSize == "Small",  title="M X Small",  style=shape.xcross, location=location.abovebar, color=extremeColor, size=size.small,  editable=false)
plotshape(extremeShowMark and markerShape == "X-Cross" and markerSize == "Normal", title="M X Normal", style=shape.xcross, location=location.abovebar, color=extremeColor, size=size.normal, editable=false)
plotshape(extremeShowMark and markerShape == "X-Cross" and markerSize == "Large",  title="M X Large",  style=shape.xcross, location=location.abovebar, color=extremeColor, size=size.large,  editable=false)

// ===== ALERTS =====
bullConfirm = priceUp and volUp
bearConfirm = priceDn and volUp
volExpand   = volUp
volContract = volDn
strongBull  = priceUp and volUp and volIsHigh
strongBear  = priceDn and volUp and volIsHigh

alertcondition(bullConfirm, title="Bullish Confirmation (Price Up + Volume Up)",   message="CVOLB: Bullish confirmation - price and volume both up vs lookback.")
alertcondition(bearConfirm, title="Bearish Confirmation (Price Down + Volume Up)", message="CVOLB: Bearish confirmation - price down, volume up vs lookback.")
alertcondition(volExpand,   title="Volume Expansion",   message="CVOLB: Volume expanding vs lookback bar.")
alertcondition(volContract, title="Volume Contraction", message="CVOLB: Volume contracting vs lookback bar.")
alertcondition(volIsHigh,   title="Extreme Volume Spike",       message="CVOLB: Extreme volume spike detected.")
alertcondition(strongBull,  title="Strong Bull (Volume Surge)", message="CVOLB: Strong bull - price up with surge volume.")
alertcondition(strongBear,  title="Strong Bear (Volume Surge)", message="CVOLB: Strong bear - price down with surge volume.")
````
