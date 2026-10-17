# RX: Dual RSI Fusion 14/50 Compression Framework

- url: https://www.tradingview.com/script/DaJWPoeG/
- type: indicator
- pine_id: PUB;d6fa777aded4460f8954bfc2dcfbbf28
- version: 11.0

## Description

## RX: Dual RSI Fusion 14/50 Compression Framework

Is an advanced momentum framework designed to identify potential market exhaustion, compression phases, and high-probability reversal conditions by combining two Relative Strength Index structures into a single analytical model.

Unlike traditional RSI indicators that rely on a single momentum source, this framework integrates both a fast RSI (14-period by default) and a slow RSI (50-period by default) to provide a multi-layer view of market behavior.

### Core Concepts

• **Fast RSI (14):** Captures immediate momentum shifts, short-term exhaustion, and early divergence signals.

• **Slow RSI (50):** Represents the underlying market structure and helps identify broader momentum regimes.

• **Dynamic Compression Engine:** Measures the convergence between moving averages applied to the fast RSI, highlighting periods where momentum becomes increasingly compressed and potentially preparing for expansion.

• **Exhaustion Detection:** The indicator is specifically designed to monitor the sequence of events frequently observed near market turning points, including divergence development, momentum contraction, and structural breakout.

### Features

✔ Dual RSI architecture (Fast + Slow)

✔ Configurable moving averages applied directly to RSI values

✔ Compression detection between fast RSI moving averages

✔ Divergence memory engine with customizable validity period

✔ Momentum Delta histogram (Fast RSI - Slow RSI)

✔ Structural breakout detection from RSI compression zones

✔ Background state visualization for market context

✔ Alert conditions for potential exhaustion breakouts

### Interpretation

The framework is based on the premise that important market reversals are rarely caused by a single event. Instead, reversals often emerge from a succession of conditions:

1. Momentum divergence appears.
2. RSI structure begins to compress.
3. Market enters an exhaustion phase.
4. Fast momentum escapes the compression structure.
5. Expansion begins.

The indicator seeks to visualize this process and provide objective confirmation of potential exhaustion scenarios.

### Notes

This tool should not be interpreted as a standalone buy or sell system. It is intended to be used as a market structure and momentum exhaustion framework, ideally combined with price action, liquidity analysis, volume, or higher timeframe context.

Developed as part of the SXA analytical ecosystem by @Peter_n_n

## Source Code

````pine
//@version=6
//by @Peter_n_n
//RSI divergence: multi-level body-close (adapted from @fikira/@Socrate)
//              + hidden divergences (from @RSU Fast)
//              + delerror invalidation (from @RSU Fast)
//MACD divergence: adapted from @RSU "Divergence Macd+RSI Fast"
indicator("RX: Dual RSI Fusion 14/50 Compression Framework",
     shorttitle="RX", overlay=false, max_bars_back=2000)

//====================================================================
// INPUT ENGINE
//====================================================================

groupRSI = "RSI Engine"
fastLen  = input.int(14, "Fast RSI Length", minval=1, group=groupRSI)
slowLen  = input.int(50, "Slow RSI Length", minval=1, group=groupRSI)
src      = input.source(close, "Source",    group=groupRSI)

groupDisplay = "Display"
showFastRSI      = input.bool(true,  "Show Fast RSI",                 group=groupDisplay)
showSlowRSI      = input.bool(false,  "Show Slow RSI",                 group=groupDisplay)
showDelta        = input.bool(false,  "Show Delta",                    group=groupDisplay)
showBg           = input.bool(false,  "Show Background",               group=groupDisplay)
showDivChart     = input.bool(false,  "Color price bars on divergence", group=groupDisplay)
showMACDCross    = input.bool(true,  "MACD Cross on price bars",       group=groupDisplay)
showMACDHist     = input.bool(false, "Show MACD Histogram in panel",   group=groupDisplay)
showMACDLines    = input.bool(true, "Show MACD Lines in panel",       group=groupDisplay)
showFusedMACD = input.bool(false, "Show Fused MACD/Signal Lines",
     tooltip="Línea MACD y Signal fusionadas con el Delta (RSI14-RSI50).\nUsa 'Delta Weight' en MACD Engine para ajustar la mezcla.",
     group=groupDisplay)
showFusionHist   = input.bool(true, "Show Fusion Histogram",          group=groupDisplay)
showDivLines     = input.bool(false,  "Show Divergence Lines in panel", group=groupDisplay)
showSignalLabels = input.bool(false, "Show Signal Labels (T)",          group=groupDisplay)
showTable        = input.bool(false, "Show Debug Table",                group=groupDisplay)

// Fast RSI
groupFast    = "Geometry Engine • Fast RSI"
fastAEnabled = input.bool(true, "Enable Primary MA",       group=groupFast)
fastASignal  = input.bool(true, "Participates in Signals", group=groupFast)
fastAVisible = input.bool(true, "Visible",                 group=groupFast)
fastAType    = input.string("EMA", "Primary MA Type",   options=["SMA","EMA","Hull"], group=groupFast)
fastALength  = input.int(14, "Primary MA Length",  group=groupFast)
fastBEnabled = input.bool(true, "Enable Secondary MA",     group=groupFast)
fastBSignal  = input.bool(true, "Participates in Signals", group=groupFast)
fastBVisible = input.bool(false, "Visible",                 group=groupFast)
fastBType    = input.string("EMA", "Secondary MA Type", options=["SMA","EMA","Hull"], group=groupFast)
fastBLength  = input.int(50, "Secondary MA Length", group=groupFast)

// Slow RSI
groupSlow    = "Geometry Engine • Slow RSI"
slowAEnabled = input.bool(true, "Enable Primary MA",       group=groupSlow)
slowASignal  = input.bool(true, "Participates in Signals", group=groupSlow)
slowAVisible = input.bool(false, "Visible",                 group=groupSlow)
slowAType    = input.string("EMA", "Primary MA Type",   options=["SMA","EMA","Hull"], group=groupSlow)
slowALength  = input.int(14, "Primary MA Length",  group=groupSlow)
slowBEnabled = input.bool(true, "Enable Secondary MA",     group=groupSlow)
slowBSignal  = input.bool(true, "Participates in Signals", group=groupSlow)
slowBVisible = input.bool(true, "Visible",                 group=groupSlow)
slowBType    = input.string("EMA", "Secondary MA Type", options=["SMA","EMA","Hull"], group=groupSlow)
slowBLength  = input.int(50, "Secondary MA Length", group=groupSlow)

// Price Trend Filter
groupTrend    = "Price Trend Filter"
usePriceTrend = input.bool(true, "Enable Price Trend Filter", group=groupTrend)
trendEMALen   = input.int(13, "Trend EMA Length",          minval=1, group=groupTrend)
emaSlopeBars  = input.int(8,  "EMA Slope Lookback (bars)", minval=1, group=groupTrend)

// MACD Engine
groupMACD  = "MACD Engine"
macdFast   = input.int(12, "Fast Length",   minval=1, group=groupMACD)
macdSlow   = input.int(26, "Slow Length",   minval=1, group=groupMACD)
macdSignal = input.int(9,  "Signal Length", minval=1, group=groupMACD)
fusedWeight = input.float(0.5, "Delta Weight in Fused MACD", minval=0, maxval=1, step=0.05,
     tooltip="0 = MACD puro (precio) | 1 = Delta puro (RSI14-RSI50) | 0.5 = mezcla balanceada",
     group=groupMACD)
fusedSignalLen = input.int(9, "Fused Signal Length", minval=1, group=groupMACD)

// Signal Engine
groupEngine = "Signal Engine"

// RSI Divergence — rango independiente al MACD
lbLDiv = input.int(1, "Div Pivot Left Bars",  minval=1, group=groupEngine,
     tooltip="1 recomendado para M1 — confirmación rápida.")
lbRDiv = input.int(1, "Div Pivot Right Bars", minval=1, group=groupEngine)
divMarginStr = input.string("0", "Divergence Margin",
     options=["0","0.236","0.382","0.5","0.618","0.786","1"],
     tooltip="0 = estricto. 0.5 = pivots intermedios toleran la mitad del rango.",
     group=groupEngine)
// RSI range: mayores de 3, menores de 120
rsiRangeLow  = input.int(5, "RSI Div Range Min (bars)", minval=1,   maxval=119, group=groupEngine,
     tooltip="Mínimo de barras entre pivots RSI. Baja a 5-8 para capturar más en M1.")
rsiRangeHigh = input.int(60, "RSI Div Range Max (bars)", minval=4,   maxval=120, group=groupEngine)
// MACD range: independiente, 8-60 periodos
macdRangeLow  = input.int(8,  "MACD Div Range Min (bars)", minval=3,  maxval=59,  group=groupEngine,
     tooltip="Rango mínimo para divergencias MACD. Independiente del rango RSI.")
macdRangeHigh = input.int(60, "MACD Div Range Max (bars)", minval=4,  maxval=120, group=groupEngine)

divValidity = input.int(15, "Div Memory (bars after detect)", minval=1, maxval=100, group=groupEngine)
showHidden  = input.bool(true, "Show Hidden Divergences",
     tooltip="Hidden bull: precio HL, RSI LL → continuación alcista\nHidden bear: precio LH, RSI HH → continuación bajista",
     group=groupEngine)
delError    = input.bool(true, "Delete Error Divergences",
     tooltip="Elimina la línea si el RSI invalida la señal en 3 barras. (@RSU Fast)",
     group=groupEngine)

compressionFactor = input.float(0.73, "Compression Sensitivity",   minval=0.10, maxval=2.0, step=0.05, group=groupEngine)
compressionMode   = input.string("Ambas", "Compression Mode",      options=["Nivel","Contracción","Ambas"],  group=groupEngine)
contractionBars   = input.int(14, "Contraction Lookback (bars)",   minval=1, group=groupEngine)
useDivFilter      = input.bool(true, "Divergence Filter",           group=groupEngine)

alertDiv    = input.bool(true,  "Alert: Divergence (r/m)",      group=groupEngine)
alertFusion = input.bool(true,  "Alert: Fusion Histogram cross", group=groupEngine)
alertDelta  = input.bool(false, "Alert: Delta Cross",            group=groupEngine)
alertMACDX  = input.bool(false, "Alert: MACD Cross (diff/dea)", group=groupEngine)

//====================================================================
// FUNCTIONS
//====================================================================

hma(src, length) =>
    ta.wma(2 * ta.wma(src, math.round(length/2)) - ta.wma(src, length),
           math.round(math.sqrt(length)))

maEngine(src, enabled, maType, length) =>
    float result = na
    if enabled
        if maType == "EMA"
            result := ta.ema(src, length)
        else if maType == "Hull"
            result := hma(src, length)
        else
            result := ta.sma(src, length)
    result

getSlopeColor(ma) =>
    slope = ma - ma[5]
    color res = color.gray
    if slope > 0
        res := slope > slope[1] ? color.lime : color.aqua
    else
        res := slope < slope[1] ? color.red : color.orange
    res

// Divergence line/circle quality based on pivot distance
divLineW(dist) =>
    dist <= 8 ? 3 : dist <= 15 ? 4 : dist <= 30 ? 6 : dist <= 60 ? 7 : 8

divCircleSize(dist) =>
    dist <= 8 ? size.tiny : dist <= 15 ? size.small : dist <= 30 ? size.small : dist <= 60 ? size.normal : size.large

// MACD divergence functions — with range filter built in
findMACDTopBl(len, diffV, deaV, rLow, rHigh) =>
    top    = not na(ta.pivothigh(diffV, len, len))
    topc   = 0
    topc  := top ? len : nz(topc[1]) + 1
    newtop = not na(ta.pivothigh(diffV, len, 0))
    topBL_z = newtop[1] and not newtop and high[1] > high[topc] and diffV[1] < diffV[topc] and diffV[topc] > deaV[topc] and diffV[topc] > 0
    topBL_h = newtop[1] and not newtop and high[1] < high[topc] and diffV[1] > diffV[topc] and diffV[topc] > deaV[topc] and diffV[topc] > 0
    inRng   = topc >= rLow and topc <= rHigh
    (topBL_z or topBL_h) and inRng

findMACDBotBl(len, diffV, deaV, rLow, rHigh) =>
    bot    = not na(ta.pivotlow(diffV, len, len))
    botc   = 0
    botc  := bot ? len : nz(botc[1]) + 1
    newbot = not na(ta.pivotlow(diffV, len, 0))
    BotBL_z = newbot[1] and not newbot and low[1] < low[botc]  and diffV[1] > diffV[botc] and diffV[botc] < deaV[botc] and diffV[botc] < 0
    BotBL_h = newbot[1] and not newbot and low[1] > low[botc]  and diffV[1] < diffV[botc] and diffV[botc] < deaV[botc] and diffV[botc] < 0
    inRng   = botc >= rLow and botc <= rHigh
    (BotBL_z or BotBL_h) and inRng

//====================================================================
// RSI + MACD ENGINE
//====================================================================

rsiFast = ta.rsi(src, fastLen)
rsiSlow = ta.rsi(src, slowLen)
diff    = ta.ema(close, macdFast) - ta.ema(close, macdSlow)
dea     = ta.ema(diff,  macdSignal)

macdCrossBull = ta.crossover(diff,  dea)
macdCrossBear = ta.crossunder(diff, dea)

macdHist    = diff - dea
histRange   = ta.highest(math.abs(macdHist), 50)
macdHistViz = histRange > 0 ? macdHist / histRange * 20 : 0.0

macdHistColor = macdHistViz >= 0
     ? (macdHistViz >= macdHistViz[1] ? color.new(color.green, 20) : color.rgb(200, 230, 201, 20))
     : (macdHistViz <= macdHistViz[1] ? color.new(color.red,   20) : color.rgb(252, 203, 205, 20))

diffRange = ta.highest(math.abs(diff), 50)
diffViz   = diffRange > 0 ? diff / diffRange * 20 : 0.0
deaViz    = diffRange > 0 ? dea  / diffRange * 20 : 0.0

//====================================================================
// GEOMETRY ENGINE
//====================================================================

fastPrimary   = maEngine(rsiFast, fastAEnabled, fastAType, fastALength)
fastSecondary = maEngine(rsiFast, fastBEnabled, fastBType, fastBLength)
slowPrimary   = maEngine(rsiSlow, slowAEnabled, slowAType, slowALength)
slowSecondary = maEngine(rsiSlow, slowBEnabled, slowBType, slowBLength)

//====================================================================
// DISPLAY ENGINE
//====================================================================

pRSIfast = plot(showFastRSI ? rsiFast : na, "Fast RSI", color=#ffc600, linewidth=2)
pRSIslow = plot(showSlowRSI ? rsiSlow : na, "Slow RSI", color=#ffeb3b, linewidth=2)

p50 = plot(50, "Mid 50", color=color.new(color.gray, 100), display=display.none)

// Mismo para RSI Slow (más tenue para no saturar)
fill(pRSIslow, p50,
     color = rsiSlow >= 50
             ? color.new(color.green, 88)
             : color.new(color.red, 88))

// Gradiente verde: aparece solo cuando Fast RSI > 70, se desvanece hacia el 70
fill(pRSIfast, p50, 80, 65,
     top_color    = color.new(color.green, 0),
     bottom_color = color.new(color.green, 100),
     title        = "Fast RSI Overbought Gradient")

// Gradiente rojo: aparece solo cuando Fast RSI < 30, se desvanece hacia el 30
fill(pRSIfast, p50, 35, 20,
     top_color    = color.new(color.red, 100),
     bottom_color = color.new(color.red, 0),
     title        = "Fast RSI Oversold Gradient")

pFast1 = plot(fastAVisible ? fastPrimary   : na, "Fast Primary",   color=getSlopeColor(fastPrimary),   linewidth=2)
pSlow2 = plot(fastBVisible ? fastSecondary : na, "Fast Secondary", color=getSlopeColor(fastSecondary), linewidth=2)
pSlow1 = plot(slowAVisible ? slowPrimary   : na, "Slow Primary",   color=getSlopeColor(slowPrimary),   linewidth=2)
pFast2 = plot(slowBVisible ? slowSecondary : na, "Slow Secondary", color=getSlopeColor(slowSecondary), linewidth=2)

fill(pRSIfast, pFast2,
     color = rsiFast >= slowSecondary
             ? color.new(color.green, 78)
             : color.new(color.red, 78))

fill(pFast1, pFast2, color=fastPrimary > fastSecondary ? color.new(color.teal, 85) : color.new(color.red, 88))
fill(pSlow1, pSlow2, color=slowPrimary > slowSecondary ? color.new(color.teal, 85) : color.new(color.red, 88))

hline(70, "70", color=color.gray, linestyle=hline.style_dotted)
hline(50, "50", color=color.gray, linestyle=hline.style_dotted)
hline(30, "30", color=color.gray, linestyle=hline.style_dotted)

//====================================================================
// DELTA + HISTOGRAMAS
//====================================================================

delta = rsiFast - rsiSlow

// Fusion histogram
deltaRange  = ta.highest(math.abs(delta),    50)
macdHRange  = ta.highest(math.abs(macdHist), 50)
normDelta   = deltaRange > 0 ? delta    / deltaRange : 0.0
normMACDH   = macdHRange > 0 ? macdHist / macdHRange : 0.0
fusionAvg   = (normDelta + normMACDH) / 2.0
fusionBoost = 1.0 + math.abs(normDelta * normMACDH)
fusionViz   = fusionAvg * fusionBoost * 15
fusionColor  = fusionViz >= 0
     ? (fusionViz >= fusionViz[1] ? color.new(#00FFA0, 10) : color.new(#d5ffef, 10))
     : (fusionViz <= fusionViz[1] ? color.new(#FF0080, 10) : color.new(#ffd3e9, 10))

fusionCrossBull = fusionViz > 0 and fusionViz[1] <= 0
fusionCrossBear = fusionViz < 0 and fusionViz[1] >= 0

// Fused MACD Engine — línea MACD y Signal influenciadas por el Delta
fusedMACDviz   = (1 - fusedWeight) * diffViz + fusedWeight * (normDelta * 20)
fusedSignalViz = ta.ema(fusedMACDviz, fusedSignalLen)

fusedCrossBull = ta.crossover(fusedMACDviz, fusedSignalViz)
fusedCrossBear = ta.crossunder(fusedMACDviz, fusedSignalViz)

deltaColor = delta >= 0
     ? (delta >= delta[1] ? color.new(#00E5FF, 15) : color.new(#00BCD4, 55))
     : (delta <= delta[1] ? color.new(#D500F9, 15) : color.new(#E040FB, 55))

plot(showDelta      ? delta       : na, "Delta",            style=plot.style_columns, color=deltaColor)
plot(showMACDHist   ? macdHistViz : na, "MACD Histogram",   style=plot.style_columns, color=macdHistColor)
plot(showFusionHist ? fusionViz   : na, "Fusion Histogram", style=plot.style_columns, color=fusionColor)
plot(showMACDLines ? diffViz : na, "MACD Line (diff)",
     color=color.new(#00bcd4, 0), linewidth=2)
plot(showMACDLines ? deaViz  : na, "Signal Line (dea)",
     color=color.new(#ff9800, 0), linewidth=2)
plot(showFusedMACD ? fusedMACDviz   : na, "Fused MACD",   color=color.new(#FFD600, 0), linewidth=2)
plot(showFusedMACD ? fusedSignalViz : na, "Fused Signal", color=color.new(#7C4DFF, 0), linewidth=1)

//====================================================================
// PRICE TREND FILTER
//====================================================================

trendEMA   = ta.ema(close, trendEMALen)
emaUp      = trendEMA > trendEMA[emaSlopeBars]
emaDown    = trendEMA < trendEMA[emaSlopeBars]
priceTrendUp   = usePriceTrend ? (close > trendEMA and emaUp)   : true
priceTrendDown = usePriceTrend ? (close < trendEMA and emaDown) : true

//====================================================================
// RSI DIVERGENCE ENGINE — Multi-level body-close
//====================================================================

// Margin
divM = divMarginStr == "0.236" ? 0.236 :
       divMarginStr == "0.382" ? 0.382 :
       divMarginStr == "0.5"   ? 0.5   :
       divMarginStr == "0.618" ? 0.618 :
       divMarginStr == "0.786" ? 0.786 :
       divMarginStr == "1"     ? 1.0   : 0.0

// Body-close pivots (sin mechas)
nwh  = high
nwl  = low
nwh_ = high
nwl_ = low

// RSI suavizado para divergencias (EMA 2 = @RSU)
rsiD = ta.ema(rsiFast, 2)

ph_b      = ta.pivothigh(rsiD, lbLDiv, lbRDiv)
pl_b      = ta.pivotlow(rsiD,  lbLDiv, lbRDiv)
ph_b_bool = not na(ph_b)
pl_b_bool = not na(pl_b)

// Precio body en cada pivot (hasta 8 atrás)
hh0 = ta.valuewhen(ph_b_bool, nwh, 0)
hh1 = ta.valuewhen(ph_b_bool, nwh, 1)
hh2 = ta.valuewhen(ph_b_bool, nwh, 2)
hh3 = ta.valuewhen(ph_b_bool, nwh, 3)
hh4 = ta.valuewhen(ph_b_bool, nwh, 4)
hh5 = ta.valuewhen(ph_b_bool, nwh, 5)
hh6 = ta.valuewhen(ph_b_bool, nwh, 6)
hh7 = ta.valuewhen(ph_b_bool, nwh, 7)

// Wick para margin
hh1_ = ta.valuewhen(ph_b_bool, nwh_, 1)
hh2_ = ta.valuewhen(ph_b_bool, nwh_, 2)
hh3_ = ta.valuewhen(ph_b_bool, nwh_, 3)
hh4_ = ta.valuewhen(ph_b_bool, nwh_, 4)
hh5_ = ta.valuewhen(ph_b_bool, nwh_, 5)
hh6_ = ta.valuewhen(ph_b_bool, nwh_, 6)
hh7_ = ta.valuewhen(ph_b_bool, nwh_, 7)

ll0 = ta.valuewhen(pl_b_bool, nwl, 0)
ll1 = ta.valuewhen(pl_b_bool, nwl, 1)
ll2 = ta.valuewhen(pl_b_bool, nwl, 2)
ll3 = ta.valuewhen(pl_b_bool, nwl, 3)
ll4 = ta.valuewhen(pl_b_bool, nwl, 4)
ll5 = ta.valuewhen(pl_b_bool, nwl, 5)
ll6 = ta.valuewhen(pl_b_bool, nwl, 6)
ll7 = ta.valuewhen(pl_b_bool, nwl, 7)

ll1_ = ta.valuewhen(pl_b_bool, nwl_, 1)
ll2_ = ta.valuewhen(pl_b_bool, nwl_, 2)
ll3_ = ta.valuewhen(pl_b_bool, nwl_, 3)
ll4_ = ta.valuewhen(pl_b_bool, nwl_, 4)
ll5_ = ta.valuewhen(pl_b_bool, nwl_, 5)
ll6_ = ta.valuewhen(pl_b_bool, nwl_, 6)
ll7_ = ta.valuewhen(pl_b_bool, nwl_, 7)

// RSI en cada pivot
rsih0 = ta.valuewhen(ph_b_bool, rsiD, 0)
rsih1 = ta.valuewhen(ph_b_bool, rsiD, 1)
rsih2 = ta.valuewhen(ph_b_bool, rsiD, 2)
rsih3 = ta.valuewhen(ph_b_bool, rsiD, 3)
rsih4 = ta.valuewhen(ph_b_bool, rsiD, 4)
rsih5 = ta.valuewhen(ph_b_bool, rsiD, 5)
rsih6 = ta.valuewhen(ph_b_bool, rsiD, 6)
rsih7 = ta.valuewhen(ph_b_bool, rsiD, 7)

rsil0 = ta.valuewhen(pl_b_bool, rsiD, 0)
rsil1 = ta.valuewhen(pl_b_bool, rsiD, 1)
rsil2 = ta.valuewhen(pl_b_bool, rsiD, 2)
rsil3 = ta.valuewhen(pl_b_bool, rsiD, 3)
rsil4 = ta.valuewhen(pl_b_bool, rsiD, 4)
rsil5 = ta.valuewhen(pl_b_bool, rsiD, 5)
rsil6 = ta.valuewhen(pl_b_bool, rsiD, 6)
rsil7 = ta.valuewhen(pl_b_bool, rsiD, 7)

// Bar indices para distancias
bPL0 = ta.valuewhen(pl_b_bool, bar_index, 0)
bPL1 = ta.valuewhen(pl_b_bool, bar_index, 1)
bPL2 = ta.valuewhen(pl_b_bool, bar_index, 2)
bPL3 = ta.valuewhen(pl_b_bool, bar_index, 3)
bPL4 = ta.valuewhen(pl_b_bool, bar_index, 4)
bPL5 = ta.valuewhen(pl_b_bool, bar_index, 5)
bPL6 = ta.valuewhen(pl_b_bool, bar_index, 6)
bPL7 = ta.valuewhen(pl_b_bool, bar_index, 7)

bPH0 = ta.valuewhen(ph_b_bool, bar_index, 0)
bPH1 = ta.valuewhen(ph_b_bool, bar_index, 1)
bPH2 = ta.valuewhen(ph_b_bool, bar_index, 2)
bPH3 = ta.valuewhen(ph_b_bool, bar_index, 3)
bPH4 = ta.valuewhen(ph_b_bool, bar_index, 4)
bPH5 = ta.valuewhen(ph_b_bool, bar_index, 5)
bPH6 = ta.valuewhen(ph_b_bool, bar_index, 6)
bPH7 = ta.valuewhen(ph_b_bool, bar_index, 7)

// Distancias por nivel
dBull1 = bPL0 - bPL1
dBull2 = bPL0 - bPL2
dBull3 = bPL0 - bPL3
dBull4 = bPL0 - bPL4
dBull5 = bPL0 - bPL5
dBull6 = bPL0 - bPL6
dBull7 = bPL0 - bPL7

dBear1 = bPH0 - bPH1
dBear2 = bPH0 - bPH2
dBear3 = bPH0 - bPH3
dBear4 = bPH0 - bPH4
dBear5 = bPH0 - bPH5
dBear6 = bPH0 - bPH6
dBear7 = bPH0 - bPH7

// Filtro de rango RSI
inRSI(d) => d >= rsiRangeLow and d <= rsiRangeHigh

// Helpers para validación de intermedios
bI(v, ref_, base) => v > base and v > ref_ - (ref_ - base) * divM
rI(v, r0, rN)     => v > rN + (r0 - rN) / 2
bH(v, ref_, base) => v < base and v < ref_ + (base - ref_) * divM
rIB(v, r0, rN)    => v < rN - (rN - r0) / 2

//====================================================================
// REGULAR BULL — precio LL, RSI HL (hasta nivel 7 = 8 pivots)
//====================================================================

bReg1 = pl_b_bool and ll0 < ll1 and rsil0 > rsil1 and inRSI(dBull1)

bReg2 = pl_b_bool and ll0 < ll2 and
     bI(ll1, ll2_, ll0) and
     rsil0 > rsil2 and rI(rsil1, rsil0, rsil2) and
     inRSI(dBull2)

bReg3 = pl_b_bool and ll0 < ll3 and
     bI(ll1, ll3_, ll0) and bI(ll2, ll3_, ll0) and
     rsil0 > rsil3 and rI(rsil1, rsil0, rsil3) and rI(rsil2, rsil0, rsil3) and
     inRSI(dBull3)

bReg4 = pl_b_bool and ll0 < ll4 and
     bI(ll1, ll4_, ll0) and bI(ll2, ll4_, ll0) and bI(ll3, ll4_, ll0) and
     rsil0 > rsil4 and rI(rsil1, rsil0, rsil4) and rI(rsil2, rsil0, rsil4) and
     rI(rsil3, rsil0, rsil4) and
     inRSI(dBull4)

bReg5 = pl_b_bool and ll0 < ll5 and
     bI(ll1, ll5_, ll0) and bI(ll2, ll5_, ll0) and bI(ll3, ll5_, ll0) and bI(ll4, ll5_, ll0) and
     rsil0 > rsil5 and rI(rsil1, rsil0, rsil5) and rI(rsil2, rsil0, rsil5) and
     rI(rsil3, rsil0, rsil5) and rI(rsil4, rsil0, rsil5) and
     inRSI(dBull5)

bReg6 = pl_b_bool and ll0 < ll6 and
     bI(ll1, ll6_, ll0) and bI(ll2, ll6_, ll0) and bI(ll3, ll6_, ll0) and
     bI(ll4, ll6_, ll0) and bI(ll5, ll6_, ll0) and
     rsil0 > rsil6 and rI(rsil1, rsil0, rsil6) and rI(rsil2, rsil0, rsil6) and
     rI(rsil3, rsil0, rsil6) and rI(rsil4, rsil0, rsil6) and rI(rsil5, rsil0, rsil6) and
     inRSI(dBull6)

bReg7 = pl_b_bool and ll0 < ll7 and
     bI(ll1, ll7_, ll0) and bI(ll2, ll7_, ll0) and bI(ll3, ll7_, ll0) and
     bI(ll4, ll7_, ll0) and bI(ll5, ll7_, ll0) and bI(ll6, ll7_, ll0) and
     rsil0 > rsil7 and rI(rsil1, rsil0, rsil7) and rI(rsil2, rsil0, rsil7) and
     rI(rsil3, rsil0, rsil7) and rI(rsil4, rsil0, rsil7) and
     rI(rsil5, rsil0, rsil7) and rI(rsil6, rsil0, rsil7) and
     inRSI(dBull7)

bullLevel  = bReg7 ? 7 : bReg6 ? 6 : bReg5 ? 5 : bReg4 ? 4 :
             bReg3 ? 3 : bReg2 ? 2 : bReg1 ? 1 : 0
bullRegNow = bullLevel > 0

//====================================================================
// REGULAR BEAR — precio HH, RSI LH + filtro RSI>60
//====================================================================

rReg1 = ph_b_bool and hh0 > hh1 and rsih0 < rsih1 and inRSI(dBear1)

rReg2 = ph_b_bool and hh0 > hh2 and bH(hh1, hh2_, hh0) and rsih0 < rsih2 and rIB(rsih1, rsih0, rsih2) and inRSI(dBear2)

rReg3 = ph_b_bool and hh0 > hh3 and bH(hh1, hh3_, hh0) and bH(hh2, hh3_, hh0) and rsih0 < rsih3 and rIB(rsih1, rsih0, rsih3) and rIB(rsih2, rsih0, rsih3) and inRSI(dBear3)

rReg4 = ph_b_bool and hh0 > hh4 and bH(hh1, hh4_, hh0) and bH(hh2, hh4_, hh0) and bH(hh3, hh4_, hh0) and rsih0 < rsih4 and rIB(rsih1, rsih0, rsih4) and rIB(rsih2, rsih0, rsih4) and rIB(rsih3, rsih0, rsih4) and inRSI(dBear4)

rReg5 = ph_b_bool and hh0 > hh5 and bH(hh1, hh5_, hh0) and bH(hh2, hh5_, hh0) and bH(hh3, hh5_, hh0) and bH(hh4, hh5_, hh0) and rsih0 < rsih5 and rIB(rsih1, rsih0, rsih5) and rIB(rsih2, rsih0, rsih5) and rIB(rsih3, rsih0, rsih5) and rIB(rsih4, rsih0, rsih5) and inRSI(dBear5)

rReg6 = ph_b_bool and hh0 > hh6 and bH(hh1, hh6_, hh0) and bH(hh2, hh6_, hh0) and bH(hh3, hh6_, hh0) and bH(hh4, hh6_, hh0) and bH(hh5, hh6_, hh0) and rsih0 < rsih6 and rIB(rsih1, rsih0, rsih6) and rIB(rsih2, rsih0, rsih6) and rIB(rsih3, rsih0, rsih6) and rIB(rsih4, rsih0, rsih6) and rIB(rsih5, rsih0, rsih6) and inRSI(dBear6)

rReg7 = ph_b_bool and hh0 > hh7 and bH(hh1, hh7_, hh0) and bH(hh2, hh7_, hh0) and bH(hh3, hh7_, hh0) and bH(hh4, hh7_, hh0) and bH(hh5, hh7_, hh0) and bH(hh6, hh7_, hh0) and rsih0 < rsih7 and rIB(rsih1, rsih0, rsih7) and rIB(rsih2, rsih0, rsih7) and rIB(rsih3, rsih0, rsih7) and rIB(rsih4, rsih0, rsih7) and rIB(rsih5, rsih0, rsih7) and rIB(rsih6, rsih0, rsih7) and inRSI(dBear7)

bearLevel  = rReg7 ? 7 : rReg6 ? 6 : rReg5 ? 5 : rReg4 ? 4 :
             rReg3 ? 3 : rReg2 ? 2 : rReg1 ? 1 : 0
bearRegNow = bearLevel > 0

//====================================================================
// HIDDEN DIVERGENCES (@RSU Fast) — continuación de tendencia
//====================================================================

bullHidNow = pl_b_bool and ll0 > ll1 and rsil0 < rsil1 and inRSI(dBull1)
bearHidNow = ph_b_bool and hh0 < hh1 and rsih0 > rsih1 and inRSI(dBear1)

// Combinados
bullDivRSI = bullRegNow or (showHidden and bullHidNow)
bearDivRSI = bearRegNow or (showHidden and bearHidNow)

//====================================================================
// DIVERGENCE LINES + CIRCLES IN RSI PANEL
//====================================================================

var array<line>  bullRegLines = array.new<line>()
var array<label> bullRegCirc  = array.new<label>()
var array<line>  bearRegLines = array.new<line>()
var array<label> bearRegCirc  = array.new<label>()
var array<line>  bullHidLines = array.new<line>()
var array<label> bullHidCirc  = array.new<label>()
var array<line>  bearHidLines = array.new<line>()
var array<label> bearHidCirc  = array.new<label>()

MAX_OBJ = 60

if showDivLines

    if bullRegNow
        bx1 = bullLevel == 7 ? bPL7 : bullLevel == 6 ? bPL6 : bullLevel == 5 ? bPL5 : bullLevel == 4 ? bPL4 : bullLevel == 3 ? bPL3 : bullLevel == 2 ? bPL2 : bPL1
        by1 = bullLevel == 7 ? rsil7 : bullLevel == 6 ? rsil6 : bullLevel == 5 ? rsil5 : bullLevel == 4 ? rsil4 : bullLevel == 3 ? rsil3 : bullLevel == 2 ? rsil2 : rsil1
        dist = bPL0 - bx1
        col  = color.new(color.green, 20)
        if array.size(bullRegLines) >= MAX_OBJ
            line.delete(array.shift(bullRegLines))
        array.push(bullRegLines, line.new(bx1, by1, bPL0, rsil0, color=col, width=divLineW(dist), xloc=xloc.bar_index))
        if array.size(bullRegCirc) >= MAX_OBJ * 2
            label.delete(array.shift(bullRegCirc))
        array.push(bullRegCirc, label.new(bx1, by1, text="", style=label.style_circle, color=col, size=divCircleSize(dist), xloc=xloc.bar_index))
        if array.size(bullRegCirc) >= MAX_OBJ * 2
            label.delete(array.shift(bullRegCirc))
        array.push(bullRegCirc, label.new(bPL0, rsil0, text="", style=label.style_circle, color=col, size=divCircleSize(dist), xloc=xloc.bar_index))

    if bearRegNow
        bx1 = bearLevel == 7 ? bPH7 : bearLevel == 6 ? bPH6 : bearLevel == 5 ? bPH5 : bearLevel == 4 ? bPH4 : bearLevel == 3 ? bPH3 : bearLevel == 2 ? bPH2 : bPH1
        by1 = bearLevel == 7 ? rsih7 : bearLevel == 6 ? rsih6 : bearLevel == 5 ? rsih5 : bearLevel == 4 ? rsih4 : bearLevel == 3 ? rsih3 : bearLevel == 2 ? rsih2 : rsih1
        dist = bPH0 - bx1
        col  = color.new(color.red, 20)
        if array.size(bearRegLines) >= MAX_OBJ
            line.delete(array.shift(bearRegLines))
        array.push(bearRegLines, line.new(bx1, by1, bPH0, rsih0, color=col, width=divLineW(dist), xloc=xloc.bar_index))
        if array.size(bearRegCirc) >= MAX_OBJ * 2
            label.delete(array.shift(bearRegCirc))
        array.push(bearRegCirc, label.new(bx1, by1, text="", style=label.style_circle, color=col, size=divCircleSize(dist), xloc=xloc.bar_index))
        if array.size(bearRegCirc) >= MAX_OBJ * 2
            label.delete(array.shift(bearRegCirc))
        array.push(bearRegCirc, label.new(bPH0, rsih0, text="", style=label.style_circle, color=col, size=divCircleSize(dist), xloc=xloc.bar_index))

    if showHidden and bullHidNow
        dist = dBull1
        col  = color.new(color.teal, 25)
        if array.size(bullHidLines) >= MAX_OBJ
            line.delete(array.shift(bullHidLines))
        array.push(bullHidLines, line.new(bPL1, rsil1, bPL0, rsil0, color=col, width=divLineW(dist), xloc=xloc.bar_index))
        if array.size(bullHidCirc) >= MAX_OBJ * 2
            label.delete(array.shift(bullHidCirc))
        array.push(bullHidCirc, label.new(bPL1, rsil1, text="", style=label.style_circle, color=col, size=divCircleSize(dist), xloc=xloc.bar_index))
        if array.size(bullHidCirc) >= MAX_OBJ * 2
            label.delete(array.shift(bullHidCirc))
        array.push(bullHidCirc, label.new(bPL0, rsil0, text="", style=label.style_circle, color=col, size=divCircleSize(dist), xloc=xloc.bar_index))

    if showHidden and bearHidNow
        dist = dBear1
        col  = color.new(color.orange, 25)
        if array.size(bearHidLines) >= MAX_OBJ
            line.delete(array.shift(bearHidLines))
        array.push(bearHidLines, line.new(bPH1, rsih1, bPH0, rsih0, color=col, width=divLineW(dist), xloc=xloc.bar_index))
        if array.size(bearHidCirc) >= MAX_OBJ * 2
            label.delete(array.shift(bearHidCirc))
        array.push(bearHidCirc, label.new(bPH1, rsih1, text="", style=label.style_circle, color=col, size=divCircleSize(dist), xloc=xloc.bar_index))
        if array.size(bearHidCirc) >= MAX_OBJ * 2
            label.delete(array.shift(bearHidCirc))
        array.push(bearHidCirc, label.new(bPH0, rsih0, text="", style=label.style_circle, color=col, size=divCircleSize(dist), xloc=xloc.bar_index))

// delerror: elimina la última línea/círculos si RSI invalida la señal
if delError
    if (bullRegNow[1] and rsiD < rsiD[2]) or (bullRegNow[2] and rsiD < rsiD[3]) or (bullRegNow[3] and rsiD < rsiD[4])
        if array.size(bullRegLines) > 0
            line.delete(array.pop(bullRegLines))
        if array.size(bullRegCirc) >= 2
            label.delete(array.pop(bullRegCirc))
            label.delete(array.pop(bullRegCirc))
    if (bearRegNow[1] and rsiD > rsiD[2]) or (bearRegNow[2] and rsiD > rsiD[3]) or (bearRegNow[3] and rsiD > rsiD[4])
        if array.size(bearRegLines) > 0
            line.delete(array.pop(bearRegLines))
        if array.size(bearRegCirc) >= 2
            label.delete(array.pop(bearRegCirc))
            label.delete(array.pop(bearRegCirc))

//====================================================================
// MACD DIVERGENCE ENGINE — rango 8-60 independiente del RSI
//====================================================================

mt5  = findMACDTopBl(5,  diff, dea, macdRangeLow, macdRangeHigh)
mt10 = findMACDTopBl(10, diff, dea, macdRangeLow, macdRangeHigh)
mt20 = findMACDTopBl(20, diff, dea, macdRangeLow, macdRangeHigh)
mt40 = findMACDTopBl(40, diff, dea, macdRangeLow, macdRangeHigh)
mt60 = findMACDTopBl(60, diff, dea, macdRangeLow, macdRangeHigh)
bearDivMACD = mt5 or mt10 or mt20 or mt40 or mt60

mb5  = findMACDBotBl(5,  diff, dea, macdRangeLow, macdRangeHigh)
mb10 = findMACDBotBl(10, diff, dea, macdRangeLow, macdRangeHigh)
mb20 = findMACDBotBl(20, diff, dea, macdRangeLow, macdRangeHigh)
mb40 = findMACDBotBl(40, diff, dea, macdRangeLow, macdRangeHigh)
mb60 = findMACDBotBl(60, diff, dea, macdRangeLow, macdRangeHigh)
bullDivMACD = mb5 or mb10 or mb20 or mb40 or mb60

bullDivNow = bullDivRSI or bullDivMACD
bearDivNow = bearDivRSI or bearDivMACD

//====================================================================
// BARCOLOR — gráfico de precio
//====================================================================

barcolor(showMACDCross and macdCrossBull ? color.new(#00ff00, 25) : na, title="MACD Bull Cross")
barcolor(showMACDCross and macdCrossBear ? color.new(#ff0000, 20) : na, title="MACD Bear Cross")

//====================================================================
// DIVERGENCE MEMORY
//====================================================================

var int lastBullDivBar = na
var int lastBearDivBar = na
if bullDivNow
    lastBullDivBar := bar_index
if bearDivNow
    lastBearDivBar := bar_index

bullActive = not na(lastBullDivBar) and (bar_index - lastBullDivBar <= divValidity)
bearActive = not na(lastBearDivBar) and (bar_index - lastBearDivBar <= divValidity)
barsSinceBullDiv = not na(lastBullDivBar) ? bar_index - lastBullDivBar : na
barsSinceBearDiv = not na(lastBearDivBar) ? bar_index - lastBearDivBar : na

//====================================================================
// COMPRESSION — basada en DELTA
//====================================================================

deltaAbs        = math.abs(delta)
avgDelta        = ta.sma(deltaAbs, 20)
compressedLevel = deltaAbs < avgDelta * compressionFactor
compressedRate  = deltaAbs < deltaAbs[contractionBars]
compression     =
     compressionMode == "Nivel"       ? compressedLevel :
     compressionMode == "Contracción" ? compressedRate  :
     compressedLevel or compressedRate

//====================================================================
// POSITION ENGINES
//====================================================================

bool fastBullConfirmed = true
bool fastBearConfirmed = true
if fastAEnabled and fastASignal
    fastBullConfirmed := fastBullConfirmed and (rsiFast > fastPrimary)
    fastBearConfirmed := fastBearConfirmed and (rsiFast < fastPrimary)
if fastBEnabled and fastBSignal
    fastBullConfirmed := fastBullConfirmed and (rsiFast > fastSecondary)
    fastBearConfirmed := fastBearConfirmed and (rsiFast < fastSecondary)

bool bullSlowConfirmed = true
bool bearSlowConfirmed = true
if slowAEnabled and slowASignal
    bullSlowConfirmed := bullSlowConfirmed and (rsiSlow > slowPrimary)
    bearSlowConfirmed := bearSlowConfirmed and (rsiSlow < slowPrimary)
if slowBEnabled and slowBSignal
    bullSlowConfirmed := bullSlowConfirmed and (rsiSlow > slowSecondary)
    bearSlowConfirmed := bearSlowConfirmed and (rsiSlow < slowSecondary)

//====================================================================
// FINAL SIGNAL ENGINE
//====================================================================

bullState = fastBullConfirmed and bullSlowConfirmed
bearState = fastBearConfirmed and bearSlowConfirmed

divOkLong  = useDivFilter ? (bullActive or (usePriceTrend and priceTrendUp))  : true
divOkShort = useDivFilter ? (bearActive or (usePriceTrend and priceTrendDown)) : true

bullReady  = bullState and compression and priceTrendUp   and divOkLong
bearReady  = bearState and compression and priceTrendDown and divOkShort

longSignal  = bullReady and not bullReady[1]
shortSignal = bearReady and not bearReady[1]

deltaCrossBull = delta > 0 and delta[1] <= 0
deltaCrossBear = delta < 0 and delta[1] >= 0

//====================================================================
// BACKGROUND
//====================================================================

bgColor =
     compression ? color.new(color.yellow, 88) :
     bullActive  ? color.new(color.blue,   92) :
     bearActive  ? color.new(color.purple, 92) : na
bgcolor(showBg ? bgColor : na)

//====================================================================
// SIGNAL SHAPES
//====================================================================

plotshape(
     (showSignalLabels and longSignal)  ? rsiFast : na,
     title="LONG", text="T", textcolor=color.white,
     style=shape.labelup, location=location.absolute,
     color=color.rgb(76, 96, 175, 30), size=size.small)

plotshape(
     (showSignalLabels and shortSignal) ? rsiFast : na,
     title="SHORT", text="T", textcolor=color.white,
     style=shape.labeldown, location=location.absolute,
     color=color.rgb(103, 58, 183, 30), size=size.small)

//====================================================================
// DEBUG TABLE
//====================================================================

var table t = table.new(position.top_right, 2, 14, border_width=1)
if showTable and barstate.islast
    table.cell(t, 0, 0,  "Fast ↑")
    table.cell(t, 1, 0,  fastBullConfirmed?"SI":"no", text_color=fastBullConfirmed?color.lime:color.gray)
    table.cell(t, 0, 1,  "Fast ↓")
    table.cell(t, 1, 1,  fastBearConfirmed?"SI":"no", text_color=fastBearConfirmed?color.orange:color.gray)
    table.cell(t, 0, 2,  "Slow ↑")
    table.cell(t, 1, 2,  bullSlowConfirmed?"SI":"no", text_color=bullSlowConfirmed?color.lime:color.gray)
    table.cell(t, 0, 3,  "Slow ↓")
    table.cell(t, 1, 3,  bearSlowConfirmed?"SI":"no", text_color=bearSlowConfirmed?color.orange:color.gray)
    compStr = compression?(compressedLevel and compressedRate?"Niv+Contr":compressedLevel?"Nivel":"Contr"):"no"
    table.cell(t, 0, 4,  "Comprimir")
    table.cell(t, 1, 4,  compStr, text_color=compression?color.yellow:color.gray)
    tendStr = not usePriceTrend?"OFF":priceTrendUp?"↑ up+":priceTrendDown?"↓ dn-":close>trendEMA?"↑ sin slope":"↓ sin slope"
    table.cell(t, 0, 5,  "Tendencia")
    table.cell(t, 1, 5,  tendStr, text_color=not usePriceTrend?color.gray:priceTrendUp?color.lime:priceTrendDown?color.red:color.orange)
    table.cell(t, 0, 6,  "State ↑")
    table.cell(t, 1, 6,  bullState?"ACTIVO":"—", text_color=bullState?color.lime:color.gray)
    divBullStr = not useDivFilter?"OFF":bullActive?"SI-"+str.tostring(barsSinceBullDiv)+"b":(usePriceTrend and priceTrendUp)?"RELAX":"no"
    table.cell(t, 0, 7,  "Div ↑ RSI")
    table.cell(t, 1, 7,  bullRegNow?"Lv"+str.tostring(bullLevel):divBullStr,
         text_color=bullRegNow?color.lime:bullActive?color.aqua:(usePriceTrend and priceTrendUp)?color.yellow:color.gray)
    divBearStr = not useDivFilter?"OFF":bearActive?"SI-"+str.tostring(barsSinceBearDiv)+"b":(usePriceTrend and priceTrendDown)?"RELAX":"no"
    table.cell(t, 0, 8,  "Div ↓ RSI")
    table.cell(t, 1, 8,  bearRegNow?"Lv"+str.tostring(bearLevel):divBearStr,
         text_color=bearRegNow?color.red:bearActive?color.orange:(usePriceTrend and priceTrendDown)?color.yellow:color.gray)
    table.cell(t, 0, 9,  "Div Oculta")
    table.cell(t, 1, 9,  bullHidNow?"↑ Bull":bearHidNow?"↓ Bear":"—",
         text_color=bullHidNow?color.teal:bearHidNow?color.orange:color.gray)
    table.cell(t, 0, 10, "MACD Div")
    table.cell(t, 1, 10, bullDivMACD?"↑ Bull":bearDivMACD?"↓ Bear":"—",
         text_color=bullDivMACD?color.lime:bearDivMACD?color.red:color.gray)
    table.cell(t, 0, 11, "MACD Cross")
    table.cell(t, 1, 11, macdCrossBull?"↑ Bull":macdCrossBear?"↓ Bear":"—",
         text_color=macdCrossBull?color.aqua:macdCrossBear?color.orange:color.gray)
    table.cell(t, 0, 12, "Bull Ready")
    table.cell(t, 1, 12, bullReady?"LISTO":"—", text_color=bullReady?color.lime:color.gray)
    table.cell(t, 0, 13, "Delta")
    table.cell(t, 1, 13, str.tostring(delta, "#.##"), text_color=delta>=0?color.lime:color.red)

//====================================================================
// ALERTS
//====================================================================

bullTrigger = longSignal or
              (alertDiv    and (bullDivRSI or bullDivMACD)) or
              (alertFusion and fusionCrossBull) or
              (alertDelta  and deltaCrossBull)  or
              (alertMACDX  and macdCrossBull)

bearTrigger = shortSignal or
              (alertDiv    and (bearDivRSI or bearDivMACD)) or
              (alertFusion and fusionCrossBear) or
              (alertDelta  and deltaCrossBear)  or
              (alertMACDX  and macdCrossBear)

if bullTrigger
    motivo = (alertDiv and bullRegNow     ? " [Div-r L"+str.tostring(bullLevel)+"]" : "") +
             (alertDiv and bullHidNow     ? " [Div-h]"    : "") +
             (alertDiv and bullDivMACD    ? " [Div-m]"    : "") +
             (alertFusion and fusionCrossBull ? " [Fusion↑]" : "") +
             (alertDelta and deltaCrossBull   ? " [Delta+]"  : "") +
             (alertMACDX and macdCrossBull    ? " [MACD-x]"  : "")
    alert("RX ↑ LONG" + motivo, alert.freq_once_per_bar_close)

if bearTrigger
    motivo = (alertDiv and bearRegNow     ? " [Div-r L"+str.tostring(bearLevel)+"]" : "") +
             (alertDiv and bearHidNow     ? " [Div-h]"    : "") +
             (alertDiv and bearDivMACD    ? " [Div-m]"    : "") +
             (alertFusion and fusionCrossBear ? " [Fusion↓]" : "") +
             (alertDelta and deltaCrossBear   ? " [Delta-]"  : "") +
             (alertMACDX and macdCrossBear    ? " [MACD-x]"  : "")
    alert("RX ↓ SHORT" + motivo, alert.freq_once_per_bar_close)

alertcondition(longSignal,  title="RX Long",  message="RX — LONG setup")
alertcondition(shortSignal, title="RX Short", message="RX — SHORT setup")
````
