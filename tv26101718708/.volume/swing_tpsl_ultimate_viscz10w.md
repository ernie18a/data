# Swing TP/SL Ultimate

- url: https://www.tradingview.com/script/VIsCz10w-Swing-TP-SL-Ultimate/
- type: indicator
- pine_id: PUB;1631d1861ac9478a9679b6f8022ec3df
- version: 1.0

## Description

[b]Swing TP/SL Ultimate[/b]
TradingView Pine Script v6 — Overlay Indicator

Short title: TP/SL▲▼  |  Version: 2.0  |  Type: Overlay Indicator


[b]Overview[/b]
Swing TP/SL Ultimate is an advanced Take Profit and Stop Loss analysis tool for TradingView. Instead of requiring you to manually set fixed TP/SL percentages, it automatically calculates statistically-derived average TP and SL distances by studying every confirmed Swing High and Swing Low in historical price data across multiple timeframes and pivot lengths.
The core idea: the market's own past behaviour tells you how far it typically moves up (TP) and down (SL) from any given point. This indicator collects hundreds of those data points, filters out outliers, and surfaces the most reliable average — displayed as both a percentage and an actual price level on your chart.

[b]Key Features[/b]
[list]
[*] Multi-length Pivot DetectionSimultaneously scans 3 configurable pivot lengths (Fast / Mid / Slow) to maximise the number of valid swing samples
[*] Multi-TimeFrame (HTF) PivotsImports pivots from a Higher TimeFrame and merges them into 
the same statistical buffer
[*] 4 Averaging MethodsSimple, EMA-Weighted, Trimmed Mean, and Blended — all computed in parallel
[*] Per-Bar ATR-Style AverageUses every bar's high−open and open−low as additional TP/SL samples for maximum data density
[*] KNN High/Low PredictionA K-Nearest Neighbours model predicts the likely High and Low over the next 5 bars using 10 market features
[*] Buy / Sell SignalsFires when price reaches a confirmed swing extreme, RSI confirms, and optional volume confirmation passes
[*] Scalable DashboardFour size presets (Tiny / Small / Medium / Large) with compact mode for minimal screen space
[*] Dual-format ValuesEvery metric is shown as both % and actual price — e.g. 2.34%  (48,250.00)
[*] Opaque Line LabelsLabels sit directly on chart lines with solid dark backgrounds so they block the line rather than overlap it
[/list]


[b]How It Works[/b]
1. Pivot Collection
A Swing High is a bar whose high is the highest of the N bars before it and the N bars after it. TradingView confirms this N bars after the fact. The indicator runs this detection three times simultaneously with different lengths:
Fast  pivot (default N=5)  — captures minor swings, many samples
Mid   pivot (default N=10) — captures medium swings
Slow  pivot (default N=21) — captures major swings, fewer but stronger signals
HTF   pivot (default N=10 on 60m) — imported from higher timeframe
Every confirmed pivot feeds into a unified rolling array buffer shared by all four sources.
2. Percentage Calculation
For each confirmed Swing High pivot:
TP% sample = (pivotHigh − confirmClose) / confirmClose × 100
For each confirmed Swing Low pivot:
SL% sample = (confirmClose − pivotLow) / confirmClose × 100
Only positive values are stored. The buffer is capped at Rolling Buffer Size entries — when full, the oldest sample is dropped (FIFO), keeping the average adaptive to the current market regime.
3. Averaging Methods
All four methods run simultaneously. You choose which one drives the final Suggested TP/SL prices:
Simple Average
The arithmetic mean of all samples in the rolling buffer. Straightforward and transparent.
EMA-Weighted Average
A running Exponential Moving Average applied to each new pivot sample as it arrives. Recent pivots are weighted more heavily than older ones, making this method more responsive to regime changes.
α = 2 / (EMA Period + 1)
emaTP = emaTP × (1 − α) + newSample × α
Trimmed Mean (default)
Sorts all buffer samples and removes the top and bottom N% before computing the mean. This eliminates the influence of extreme outlier swings (e.g. a flash crash or a parabolic spike) that would otherwise skew the average.
Default trim: 10%  →  removes top 10% and bottom 10% of samples
Blended
Averages the Trimmed Mean result with the Per-Bar ATR-style result. Combines the statistical robustness of pivot-based sampling with the high data density of per-bar measurement.
4. Per-Bar ATR-Style Sampling
In addition to pivot-based samples, every single bar contributes:
barTP% = (high − open) / open × 100   ← upside potential per bar
barSL% = (open − low)  / open × 100   ← downside risk per bar
An EMA is applied to both series. This gives the indicator a very high sample count (one per bar vs. one per pivot event) and closely mirrors the concept of Average True Range expressed directionally as a percentage.

[b]KNN Prediction[/b]
The indicator includes a K-Nearest Neighbours (KNN) machine learning model that predicts how far price is likely to move up and down over the next 5 bars.
Feature Vector (10 dimensions)
#FeatureWhat it captures0RSI (14)Momentum / overbought / oversold1Distance from EMA-50 %Trend deviation2ATR (14) as % of priceVolatility regime3Bollinger Band position %Price within range4Volume vs. 20-bar SMA %Volume spike detection5Candle body size %Bar strength6Upper wick %Rejection at highs7Lower wick %Rejection at lows8Momentum (10-bar) %Short-term trend force9Close position in 20-bar range %Range context
Algorithm

For every bar in the training window (up to 200 bars back, sampled every 2 bars for performance), compute the Euclidean distance between the current bar's feature vector and that historical bar's feature vector.
Select the K nearest historical bars (default K=5).
For each neighbour, look up what actually happened over the next 5 bars: how high did price go, how low did it go.
Weight each neighbour by inverse distance — closer matches contribute more.
The weighted average of future highs and lows becomes the KNN prediction.

The result is plotted as a dotted forward line on the chart and shown in the dashboard.

[b]Buy / Sell Signals[/b]
Signals fire only when all conditions are simultaneously true.
Buy Signal (▲ BUY — green label below bar)
ConditionLogicNear Swing Lowclose ≤ lastSwingLow × (1 + avgSL% × 0.5)RSI OversoldRSI ≤ Oversold threshold (default 35)Bullish candleclose > openVolume (optional)volume > 20-bar SMA × 1.2
Sell Signal (▼ SELL — red label above bar)
ConditionLogicNear Swing Highclose ≥ lastSwingHigh × (1 − avgTP% × 0.5)RSI OverboughtRSI ≥ Overbought threshold (default 65)Bearish candleclose < openVolume (optional)volume > 20-bar SMA × 1.2

Note: Signals are contextual alerts, not a complete trading system. Always combine with your own analysis and risk management.


[b]Dashboard[/b]
The on-chart table updates on every bar. Its size, position, and content depth are all configurable.
Size Presets
SizeTextRows shownTinytinyCore only (compact)SmallsmallCore + method breakdownMediumnormalCore + breakdown + range statsLargelargeFull: all above + KNN + signal state + HTF status
Dashboard Sections
Always visible
RowLabelDescriptionTitle⬡ TP / SL ULTIMATEActive method + sample countsLive▲ To Swing HIGH% and price distance to last pivot highLive▼ To Swing LOW% and price distance to last pivot lowAvg★ Avg TP (Final)Final averaged TP as % and suggested priceAvg★ Avg SL (Final)Final averaged SL as % and suggested priceAvg⚖ R:R RatioavgTP ÷ avgSL — green ≥2.0, yellow ≥1.0, red <1.0
Small and above
RowLabelDescriptionBreakdownSimple / EMA-Weighted / Trimmed / Per-BarTP% / SL% for each method side by side
Medium and above
RowLabelDescriptionRangeAvg High %Mean upside from all pivot samplesRangeMax / Min High %Best and worst upside seen in bufferRangeAvg Low %Mean downside from all pivot samplesRangeMax Low %Worst downside seen in buffer
Large only
RowLabelDescriptionKNNKNN Pred High +%Predicted upside over next 5 bars (% + price)KNNKNN Pred Low −%Predicted downside over next 5 bars (% + price)SignalRSICurrent RSI value, colour-codedSignalVolume vs SMACurrent volume as % of 20-bar SMASignalActive SignalBUY / SELL / WaitingInfoHTF PivotsWhether HTF pivot collection is active

Chart Visuals
ElementColourDescriptionDashed green lineGreenLast confirmed Swing High levelDashed red lineRedLast confirmed Swing Low levelSolid teal lineTealAvg TP suggested priceSolid orange lineOrangeAvg SL suggested priceDotted purple linePurpleKNN predicted High (forward projection)Dotted fuchsia lineFuchsiaKNN predicted Low (forward projection)▼ triangle above barRedConfirmed pivot high marker▲ triangle below barLimeConfirmed pivot low markerBUY labelLimeBuy signal — all conditions metSELL labelRedSell signal — all conditions met
All lines carry opaque labels (solid dark background matching the line colour) placed directly on the line so the text is legible without the line running through it.

[b]Input Reference[/b]
📐 Pivot Detection
InputDefaultRangeDescriptionPivot Length 1 – Fast52–50Left/right bars to confirm a fast swingPivot Length 2 – Mid102–100Left/right bars for mid-grade swingPivot Length 3 – Slow212–200Left/right bars for slow/major swingRolling Buffer Size15020–500Max samples kept per side (TP / SL)Outlier Trim %100–40% of extremes removed from trimmed meanEMA Weight Period142–100Smoothing for EMA-weighted averagePer-Bar EMA Length20010–1000EMA length for per-bar ATR-style average
🌐 Multi-TimeFrame
InputDefaultDescriptionEnable HTF PivotsOnAdds higher-timeframe pivots to the bufferHigher TimeFrame60 (1H)Source timeframe for HTF pivotsHTF Pivot Length10Pivot detection length on the higher timeframe
🤖 KNN Prediction
InputDefaultRangeDescriptionEnable KNNOn—Toggle the KNN engine on/offK Neighbours53–15Number of nearest matches to useKNN Training Window10030–200How many bars back to search
📊 Averaging
InputDefaultOptionsDescriptionPrimary Pivot MethodTrimmed MeanSimple / EMA Weighted / Trimmed Mean / BlendedWhich pivot average drives the final outputSample SourceBlendedPivot Only / Per-Bar Only / BlendedWhat data feeds the final TP/SL
🎯 Signals
InputDefaultDescriptionShow Buy/Sell SignalsOnMaster toggle for signal markersRSI Length14Period for RSI calculationRSI Oversold – Buy35RSI threshold to confirm a buyRSI Overbought – Sell65RSI threshold to confirm a sellVolume ConfirmationOnRequire volume > 1.2× SMA to trigger
🖥 Dashboard
InputDefaultOptionsDescriptionPositionTop RightTop/Bottom × Left/RightCorner placement of the tableDashboard SizeMediumTiny / Small / Medium / LargeControls text size and row countUltra-Compact ModeOff—Shows only title + 6 core rows
🎨 Visuals
InputDefaultDescriptionShow Pivot Level LinesOnDashed lines at last Swing High / LowShow Avg TP/SL LinesOnSolid lines at suggested TP and SL pricesShow KNN Predicted LinesOnDotted forward lines from KNN modelShow Pivot MarkersOnTriangles at confirmed pivot barsShow Line LabelsOnOpaque labels on all chart lines

[b]Recommended Settings by Use Case[/b]
Scalping (1m – 5m charts)
Pivot Length 1: 3   Pivot Length 2: 5   Pivot Length 3: 10
HTF Timeframe: 15
Buffer Size: 100    EMA Period: 7    Per-Bar EMA: 50
Primary: EMA Weighted   Source: Blended
RSI Oversold: 30   RSI Overbought: 70
Swing Trading (1H – 4H charts)
Pivot Length 1: 5   Pivot Length 2: 10   Pivot Length 3: 21
HTF Timeframe: D
Buffer Size: 150    EMA Period: 14   Per-Bar EMA: 200
Primary: Trimmed Mean   Source: Blended
RSI Oversold: 35   RSI Overbought: 65
Position Trading (Daily – Weekly charts)
Pivot Length 1: 10  Pivot Length 2: 20  Pivot Length 3: 50
HTF Timeframe: W
Buffer Size: 200    EMA Period: 21   Per-Bar EMA: 500
Primary: Simple   Source: Pivot Only
RSI Oversold: 40   RSI Overbought: 60


[b]Technical Notes[/b]

Pine Script version: v6
Type: indicator() with overlay=true
Max lines: 20  |  Max labels: 50
MTF data: Uses barmerge.lookahead_off to prevent future-leak
KNN performance: Samples every 2nd bar in the training window; hard-capped at 200 bars to stay within Pine's execution time limits
Global scope rule: All plotshape() calls and var mutations are placed at the global scope as required by Pine Script v6


[b]Changelog[/b]
VersionDateChanges1.0InitialBasic pivot avg + dashboard2.0CurrentKNN engine, MTF pivots, 4 avg methods, buy/sell signals, 4 dashboard sizes, opaque line labels, full Pine v6 scope compliance

Built for TradingView Pine Script v6. For educational and analytical purposes only — not financial advice.

## Source Code

````pine
// ╔══════════════════════════════════════════════════════════════╗
// ║   Swing TP/SL Ultimate  –  v2.0  (Pine Script v6)          ║
// ║   Overlay Indicator                                          ║
// ║                                                              ║
// ║  • Multi-length pivots (3 lengths) + HTF pivots             ║
// ║  • Simple / EMA-weighted / Trimmed Mean / Blended avg       ║
// ║  • Per-bar ATR-style avg (max sample count)                 ║
// ║  • KNN High/Low prediction (inverse-distance weighted)      ║
// ║  • Buy @ bottom / Sell @ top signals + RSI + Volume         ║
// ║  • Dashboard size: Tiny / Small / Medium / Large            ║
// ║  • Every value: % AND actual price                          ║
// ╚══════════════════════════════════════════════════════════════╝
// Patrickz (Peerasn Buranasanti)
//@version=6
indicator("Swing TP/SL Ultimate", "TP/SL▲▼", overlay=true,
     max_lines_count=20, max_labels_count=50)

// ═══════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════
gPIV = "📐 Pivot Detection"
gMTF = "🌐 Multi-TimeFrame"
gKNN = "🤖 KNN Prediction"
gAVG = "📊 Averaging"
gSIG = "🎯 Signals"
gDSH = "🖥  Dashboard"
gVIS = "🎨 Visuals"

// Pivot
i_pL1    = input.int  (5,    "Pivot Length 1 – Fast",    minval=2, maxval=50,   group=gPIV)
i_pL2    = input.int  (10,   "Pivot Length 2 – Mid",     minval=2, maxval=100,  group=gPIV)
i_pL3    = input.int  (21,   "Pivot Length 3 – Slow",    minval=2, maxval=200,  group=gPIV)
i_bufSz  = input.int  (150,  "Rolling Buffer Size",      minval=20,maxval=500,  group=gPIV,
     tooltip="Max pivot samples kept. Oldest drops off when full — keeps avg regime-adaptive.")
i_trim   = input.float(10,   "Outlier Trim %",           minval=0, maxval=40, step=5, group=gPIV,
     tooltip="Remove top+bottom N% of samples before trimmed mean. 0 = off.")
i_emaP   = input.int  (14,   "EMA Weight Period",        minval=2, maxval=100,  group=gPIV)
i_barLen = input.int  (200,  "Per-Bar EMA Length",       minval=10,maxval=1000, group=gPIV)

// MTF
i_mtfOn  = input.bool      (true,  "Enable HTF Pivots",   group=gMTF)
i_mtfTF  = input.timeframe ("60",  "Higher TimeFrame",    group=gMTF)
i_mtfL   = input.int       (10,    "HTF Pivot Length",    minval=2, maxval=50,  group=gMTF)

// KNN
i_knnOn  = input.bool(true,  "Enable KNN Prediction",    group=gKNN)
i_k      = input.int (5,     "K Neighbours",             minval=3, maxval=15,  group=gKNN)
i_knnLen = input.int (100,   "KNN Training Window",      minval=30,maxval=200, group=gKNN,
     tooltip="Bars back to search for nearest neighbours. Capped at 200 for performance.")

// Averaging
i_primary = input.string("Trimmed Mean", "Primary Pivot Method",
     options=["Simple","EMA Weighted","Trimmed Mean","Blended"], group=gAVG)
i_method  = input.string("Blended", "Sample Source",
     options=["Pivot Only","Per-Bar Only","Blended"], group=gAVG)

// Signals
i_sigOn   = input.bool (true, "Show Buy/Sell Signals",   group=gSIG)
i_rsiLen  = input.int  (14,   "RSI Length",              minval=2, maxval=50,  group=gSIG)
i_rsiOS   = input.int  (35,   "RSI Oversold – Buy",      minval=5, maxval=50,  group=gSIG)
i_rsiOB   = input.int  (65,   "RSI Overbought – Sell",   minval=50,maxval=95,  group=gSIG)
i_volConf = input.bool (true,  "Volume Confirmation",    group=gSIG)

// Dashboard
i_dPos   = input.string("Top Right", "Position",
     options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=gDSH)
i_dSz    = input.string("Medium", "Dashboard Size",
     options=["Tiny","Small","Medium","Large"], group=gDSH,
     tooltip="Controls text size and how many rows are displayed.")
i_compact = input.bool(false, "Ultra-Compact Mode", group=gDSH)

// Visuals
i_showPivLines  = input.bool(true,  "Show Pivot Level Lines",      group=gVIS)
i_showSugLines  = input.bool(true,  "Show Avg TP/SL Lines",        group=gVIS)
i_showKNNLines  = input.bool(true,  "Show KNN Predicted Lines",    group=gVIS)
i_showMarkers   = input.bool(true,  "Show Pivot Markers on Chart", group=gVIS)
i_showLabels    = input.bool(true,  "Show Line Labels",            group=gVIS)

// ═══════════════════════════════════════════════════════════════
// SIZE HELPERS
// ═══════════════════════════════════════════════════════════════
tsBody() =>
    switch i_dSz
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Medium" => size.normal
        "Large"  => size.large
        => size.normal

tsSub() =>
    switch i_dSz
        "Tiny"   => size.tiny
        "Small"  => size.tiny
        "Medium" => size.small
        "Large"  => size.normal
        => size.small

showFull() => i_dSz == "Large" or i_dSz == "Medium"

// ═══════════════════════════════════════════════════════════════
// UTILITY FUNCTIONS
// ═══════════════════════════════════════════════════════════════
f2(v)              => str.tostring(v, "#.##") + "%"
fp(v)              => str.tostring(v, format.mintick)
fBoth(pct, price)  => f2(pct) + "  (" + fp(price) + ")"

pushBuf(float[] buf, float val, int mx) =>
    array.push(buf, val)
    if array.size(buf) > mx
        array.shift(buf)

trimMean(float[] buf, float pct) =>
    sz = array.size(buf)
    result = 0.0
    if sz < 4
        result := sz > 0 ? array.avg(buf) : 0.0
    else
        s   = array.copy(buf)
        array.sort(s)
        cut = math.max(1, math.round(sz * pct / 100.0))
        tot = 0.0
        cnt = 0
        for i = cut to sz - cut - 1
            tot += array.get(s, i)
            cnt += 1
        result := cnt > 0 ? tot / cnt : array.avg(buf)
    result

deleteLine(line l) =>
    if not na(l)
        line.delete(l)

deleteLabel(label l) =>
    if not na(l)
        label.delete(l)

// ═══════════════════════════════════════════════════════════════
// PIVOTS  –  3 local lengths
// ═══════════════════════════════════════════════════════════════
pH1 = ta.pivothigh(high, i_pL1, i_pL1)
pL1 = ta.pivotlow (low,  i_pL1, i_pL1)
pH2 = ta.pivothigh(high, i_pL2, i_pL2)
pL2 = ta.pivotlow (low,  i_pL2, i_pL2)
pH3 = ta.pivothigh(high, i_pL3, i_pL3)
pL3 = ta.pivotlow (low,  i_pL3, i_pL3)

// ═══════════════════════════════════════════════════════════════
// MULTI-TIMEFRAME
// ═══════════════════════════════════════════════════════════════
htfHigh = request.security(syminfo.tickerid, i_mtfTF, high,
     lookahead=barmerge.lookahead_off)
htfLow  = request.security(syminfo.tickerid, i_mtfTF, low,
     lookahead=barmerge.lookahead_off)
htfPH   = i_mtfOn ? ta.pivothigh(htfHigh, i_mtfL, i_mtfL) : float(na)
htfPL   = i_mtfOn ? ta.pivotlow (htfLow,  i_mtfL, i_mtfL) : float(na)

// ═══════════════════════════════════════════════════════════════
// ROLLING BUFFERS  +  EMA accumulators  (global scope only)
// ═══════════════════════════════════════════════════════════════
var float[] tpBuf = array.new_float(0)
var float[] slBuf = array.new_float(0)
var float   lastH = na
var float   lastL = na
var float   emaTP = na
var float   emaSL = na

alpha = 2.0 / (i_emaP + 1)

// Collect HIGH pivots
for _h in array.from(pH1, pH2, pH3, htfPH)
    if not na(_h) and _h > 0.0
        _pct = (_h - close) / close * 100.0
        if _pct > 0.0
            pushBuf(tpBuf, _pct, i_bufSz)
            emaTP := na(emaTP) ? _pct : emaTP * (1.0 - alpha) + _pct * alpha
            lastH := _h

// Collect LOW pivots
for _l in array.from(pL1, pL2, pL3, htfPL)
    if not na(_l) and _l > 0.0
        _pct = (close - _l) / close * 100.0
        if _pct > 0.0
            pushBuf(slBuf, _pct, i_bufSz)
            emaSL := na(emaSL) ? _pct : emaSL * (1.0 - alpha) + _pct * alpha
            lastL := _l

// ═══════════════════════════════════════════════════════════════
// AVERAGES
// ═══════════════════════════════════════════════════════════════
simTP = array.size(tpBuf) > 0 ? array.avg(tpBuf) : 0.0
simSL = array.size(slBuf) > 0 ? array.avg(slBuf) : 0.0

ewTP  = na(emaTP) ? 0.0 : emaTP
ewSL  = na(emaSL) ? 0.0 : emaSL

trTP  = trimMean(tpBuf, i_trim)
trSL  = trimMean(slBuf, i_trim)

barTP_raw = (high - open) / open * 100.0
barSL_raw = (open - low)  / open * 100.0
pbTP  = ta.ema(barTP_raw, i_barLen)
pbSL  = ta.ema(barSL_raw, i_barLen)

blTP  = (trTP + pbTP) / 2.0
blSL  = (trSL + pbSL) / 2.0

pivPrimTP = switch i_primary
    "Simple"       => simTP
    "EMA Weighted" => ewTP
    "Trimmed Mean" => trTP
    "Blended"      => blTP
    => trTP

pivPrimSL = switch i_primary
    "Simple"       => simSL
    "EMA Weighted" => ewSL
    "Trimmed Mean" => trSL
    "Blended"      => blSL
    => trSL

finalTP = switch i_method
    "Pivot Only"   => pivPrimTP
    "Per-Bar Only" => pbTP
    "Blended"      => blTP
    => blTP

finalSL = switch i_method
    "Pivot Only"   => pivPrimSL
    "Per-Bar Only" => pbSL
    "Blended"      => blSL
    => blSL

maxTP = array.size(tpBuf) > 0 ? array.max(tpBuf) : 0.0
minTP = array.size(tpBuf) > 0 ? array.min(tpBuf) : 0.0
maxSL = array.size(slBuf) > 0 ? array.max(slBuf) : 0.0
minSL = array.size(slBuf) > 0 ? array.min(slBuf) : 0.0

rrRatio    = finalSL > 0.0 ? finalTP / finalSL : 0.0
liveTP_pct = not na(lastH) ? (lastH - close) / close * 100.0 : 0.0
liveSL_pct = not na(lastL) ? (close - lastL) / close * 100.0 : 0.0
sugTP      = close * (1.0 + finalTP / 100.0)
sugSL      = close * (1.0 - finalSL / 100.0)

// ═══════════════════════════════════════════════════════════════
// KNN HIGH/LOW PREDICTION
// ═══════════════════════════════════════════════════════════════
rsi14    = ta.rsi(close, 14)
ema50    = ta.ema(close, 50)
atr14    = ta.atr(14)
[bbU, bbM, bbL] = ta.bb(close, 20, 2.0)
volSma   = ta.sma(volume, 20)

feat0  = rsi14
feat1  = (close - ema50) / ema50 * 100.0
feat2  = atr14 / close * 100.0
feat3  = (close - bbL) / math.max(bbU - bbL, 0.0001) * 100.0
feat4  = volume / math.max(volSma, 1.0) * 100.0
feat5  = math.abs(close - open) / open * 100.0
feat6  = (high - math.max(close, open)) / open * 100.0
feat7  = (math.min(close, open) - low)  / open * 100.0
feat8  = ta.mom(close, 10) / close * 100.0
feat9  = (close - ta.lowest(low, 20)) /
         math.max(ta.highest(high, 20) - ta.lowest(low, 20), 0.0001) * 100.0

var float knnPredH = na
var float knnPredL = na

if i_knnOn and bar_index > i_knnLen + 5
    float[] dists   = array.new_float(0)
    float[] futureH = array.new_float(0)
    float[] futureL = array.new_float(0)

    lookback = math.min(i_knnLen, 200)
    for s = 5 to lookback by 2
        d0 = math.pow(feat0 - feat0[s], 2)
        d1 = math.pow(feat1 - feat1[s], 2)
        d2 = math.pow(feat2 - feat2[s], 2)
        d3 = math.pow(feat3 - feat3[s], 2)
        d4 = math.pow(feat4 - feat4[s], 2)
        d5 = math.pow(feat5 - feat5[s], 2)
        d6 = math.pow(feat6 - feat6[s], 2)
        d7 = math.pow(feat7 - feat7[s], 2)
        d8 = math.pow(feat8 - feat8[s], 2)
        d9 = math.pow(feat9 - feat9[s], 2)
        dist = math.sqrt(d0+d1+d2+d3+d4+d5+d6+d7+d8+d9)

        fH = (ta.highest(high, 5)[s - 4] - close[s]) / close[s] * 100.0
        fL = (close[s] - ta.lowest(low, 5)[s - 4])   / close[s] * 100.0
        array.push(dists,   dist)
        array.push(futureH, fH)
        array.push(futureL, fL)

    kUse = math.min(i_k, array.size(dists))
    sumH = 0.0
    sumL = 0.0
    wSum = 0.0
    for _i = 0 to kUse - 1
        minIdx = 0
        minVal = array.get(dists, 0)
        for j = 1 to array.size(dists) - 1
            if array.get(dists, j) < minVal
                minVal := array.get(dists, j)
                minIdx := j
        w     = 1.0 / math.max(minVal, 0.0001)
        sumH += array.get(futureH, minIdx) * w
        sumL += array.get(futureL, minIdx) * w
        wSum += w
        array.remove(dists,   minIdx)
        array.remove(futureH, minIdx)
        array.remove(futureL, minIdx)

    if wSum > 0.0
        knnPredH := sumH / wSum
        knnPredL := sumL / wSum

knnPredHPrice = i_knnOn and not na(knnPredH) ?
     close * (1.0 + knnPredH / 100.0) : float(na)
knnPredLPrice = i_knnOn and not na(knnPredL) ?
     close * (1.0 - knnPredL / 100.0) : float(na)

// ═══════════════════════════════════════════════════════════════
// BUY / SELL SIGNALS
// ═══════════════════════════════════════════════════════════════
rsi      = ta.rsi(close, i_rsiLen)
volAbove = volume > volSma * 1.2
volOk    = i_volConf ? volAbove : true

nearLow      = not na(lastL) and close <= lastL * (1.0 + finalSL / 100.0 * 0.5)
rsiOS        = rsi <= i_rsiOS
bullCandle   = close > open
buySignal    = i_sigOn and nearLow and rsiOS and bullCandle and volOk

nearHigh     = not na(lastH) and close >= lastH * (1.0 - finalTP / 100.0 * 0.5)
rsiOB        = rsi >= i_rsiOB
bearCandle   = close < open
sellSignal   = i_sigOn and nearHigh and rsiOB and bearCandle and volOk

// ═══════════════════════════════════════════════════════════════
// PLOTS  –  must be in global scope (Pine v6 rule)
// ═══════════════════════════════════════════════════════════════
// Pivot markers — condition pre-computed so plotshape stays global
anyPivH = i_showMarkers and (not na(pH1) or not na(pH2) or not na(pH3) or not na(htfPH))
anyPivL = i_showMarkers and (not na(pL1) or not na(pL2) or not na(pL3) or not na(htfPL))

plotshape(anyPivH, "Piv H", shape.triangledown, location.abovebar,
     color.new(color.red,  10), size=size.tiny, offset=-i_pL1)
plotshape(anyPivL, "Piv L", shape.triangleup,   location.belowbar,
     color.new(color.lime, 10), size=size.tiny, offset=-i_pL1)

// Signal labels
plotshape(buySignal,  "BUY",  shape.labelup,   location.belowbar,
     color.new(color.lime, 0), textcolor=color.black, text="BUY",  size=size.small)
plotshape(sellSignal, "SELL", shape.labeldown, location.abovebar,
     color.new(color.red,  0), textcolor=color.white, text="SELL", size=size.small)

// ═══════════════════════════════════════════════════════════════
// LINES + LABELS  (barstate.islast only)
// ═══════════════════════════════════════════════════════════════
var line  lSwH  = na
var line  lSwL  = na
var line  lSuTP = na
var line  lSuSL = na
var line  lKH   = na
var line  lKL   = na
var label lbH   = na
var label lbL   = na
var label lbTP  = na
var label lbSL  = na
var label lbKH  = na
var label lbKL  = na

if barstate.islast
    // ── Pivot level lines ──────────────────────────────────
    if i_showPivLines
        deleteLine(lSwH)
        deleteLine(lSwL)
        if not na(lastH)
            lSwH := line.new(bar_index - 80, lastH, bar_index, lastH,
                 extend=extend.right,
                 color=color.new(color.green, 20), width=2, style=line.style_dashed)
            if i_showLabels
                deleteLabel(lbH)
                lbH := label.new(bar_index, lastH,
                     " Swing H: " + fp(lastH) + " ",
                     color=color.new(#0a1a0a, 0), textcolor=color.new(color.green, 0),
                     style=label.style_label_left, size=size.small)
        if not na(lastL)
            lSwL := line.new(bar_index - 80, lastL, bar_index, lastL,
                 extend=extend.right,
                 color=color.new(color.red, 20), width=2, style=line.style_dashed)
            if i_showLabels
                deleteLabel(lbL)
                lbL := label.new(bar_index, lastL,
                     " Swing L: " + fp(lastL) + " ",
                     color=color.new(#1a0a0a, 0), textcolor=color.new(color.red, 0),
                     style=label.style_label_left, size=size.small)

    // ── Avg TP/SL lines ────────────────────────────────────
    if i_showSugLines
        deleteLine(lSuTP)
        deleteLine(lSuSL)
        lSuTP := line.new(bar_index - 30, sugTP, bar_index, sugTP,
             extend=extend.right, color=color.new(color.teal, 10), width=2)
        lSuSL := line.new(bar_index - 30, sugSL, bar_index, sugSL,
             extend=extend.right, color=color.new(color.orange, 10), width=2)
        if i_showLabels
            deleteLabel(lbTP)
            deleteLabel(lbSL)
            lbTP := label.new(bar_index, sugTP,
                 " Avg TP: " + fp(sugTP) + "  +" + f2(finalTP) + " ",
                 color=color.new(#051818, 0), textcolor=color.new(color.teal, 0),
                 style=label.style_label_left, size=size.small)
            lbSL := label.new(bar_index, sugSL,
                 " Avg SL: " + fp(sugSL) + "  -" + f2(finalSL) + " ",
                 color=color.new(#181005, 0), textcolor=color.new(color.orange, 0),
                 style=label.style_label_left, size=size.small)

    // ── KNN lines ──────────────────────────────────────────
    if i_showKNNLines and i_knnOn
        deleteLine(lKH)
        deleteLine(lKL)
        if not na(knnPredHPrice)
            lKH := line.new(bar_index, close, bar_index + 10, knnPredHPrice,
                 color=color.new(color.purple, 10), width=2, style=line.style_dotted)
            if i_showLabels
                deleteLabel(lbKH)
                lbKH := label.new(bar_index + 10, knnPredHPrice,
                     " KNN H: " + fp(knnPredHPrice) + "  +" + f2(math.max(knnPredH, 0.0)) + " ",
                     color=color.new(#100a18, 0), textcolor=color.new(color.purple, 0),
                     style=label.style_label_left, size=size.small)
        if not na(knnPredLPrice)
            lKL := line.new(bar_index, close, bar_index + 10, knnPredLPrice,
                 color=color.new(color.fuchsia, 10), width=2, style=line.style_dotted)
            if i_showLabels
                deleteLabel(lbKL)
                lbKL := label.new(bar_index + 10, knnPredLPrice,
                     " KNN L: " + fp(knnPredLPrice) + "  -" + f2(math.max(knnPredL, 0.0)) + " ",
                     color=color.new(#180a12, 0), textcolor=color.new(color.fuchsia, 0),
                     style=label.style_label_left, size=size.small)

// ═══════════════════════════════════════════════════════════════
// DASHBOARD
// ═══════════════════════════════════════════════════════════════
tPos = switch i_dPos
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right

totalRows = i_compact ? 10 : showFull() ? 28 : 20

var table T = table.new(tPos, 2, totalRows,
     bgcolor      = color.new(#080810,  5),
     border_color = color.new(#222240, 45),
     border_width = 1,
     frame_color  = color.new(#4040a0, 55),
     frame_width  = 1)

// Palette
cBg0 = color.new(#10102a,  5)
cBg1 = color.new(#0c1030, 12)
cBg2 = color.new(#081828, 18)
cSep = color.new(#181830, 10)
cW   = color.white
cDim = color.new(color.silver, 25)
cG   = color.new(#00e676,  0)
cGd  = color.new(#00c853, 20)
cR   = color.new(#ff5252,  0)
cRd  = color.new(#d50000, 20)
cY   = color.new(#ffeb3b,  5)
cT   = color.new(#00bcd4,  5)
cO   = color.new(#ff9800,  5)
cPu  = color.new(#ce93d8,  5)
cFu  = color.new(#f48fb1,  5)

TS  = tsBody()
TSS = tsSub()

// Inline cell helpers (no global-var mutation — just calls)
tc(col, row, txt, tc2, bg) =>
    table.cell(T, col, row, txt, text_color=tc2, bgcolor=bg,
         text_size=TS, text_halign=text.align_left)

tcR(col, row, txt, tc2, bg) =>
    table.cell(T, col, row, txt, text_color=tc2, bgcolor=bg,
         text_size=TS, text_halign=text.align_right)

tcC(col, row, txt, tc2, bg, sz) =>
    table.cell(T, col, row, txt, text_color=tc2, bgcolor=bg,
         text_size=sz, text_halign=text.align_center)

mergeFull(row) =>
    table.merge_cells(T, 0, row, 1, row)

rowSep(row) =>
    tcC(0, row, "", cDim, cSep, TSS)
    mergeFull(row)

rowHdr(row, txt) =>
    tcC(0, row, txt, cDim, cSep, TSS)
    mergeFull(row)

rowLV(row, lbl, val, vc) =>
    tc (0, row, lbl, cDim, cBg1)
    tcR(1, row, val, vc,   cBg2)

if barstate.islast
    // ── 0: Title ────────────────────────────────────────────
    tcC(0, 0, "⬡  TP / SL  ULTIMATE", cW, cBg0, TS)
    mergeFull(0)

    // ── 1: Info bar ─────────────────────────────────────────
    nTP = array.size(tpBuf)
    nSL = array.size(slBuf)
    tcC(0, 1,
         i_primary + " | " + i_method + " | " +
         str.tostring(nTP) + "/" + str.tostring(nSL) + " pts",
         cDim, cSep, TSS)
    mergeFull(1)

    // ── 2: Live section header ───────────────────────────────
    rowHdr(2, "─  LIVE  DISTANCES  ─")

    // ── 3: Live to Swing High ───────────────────────────────
    rowLV(3, "▲ To Swing HIGH",
         fBoth(liveTP_pct, not na(lastH) ? lastH : close),
         liveTP_pct > 0.0 ? cG : cR)

    // ── 4: Live to Swing Low ────────────────────────────────
    rowLV(4, "▼ To Swing LOW",
         fBoth(liveSL_pct, not na(lastL) ? lastL : close),
         liveSL_pct > 0.0 ? cR : cG)

    // ── 5: Avg TP/SL header ──────────────────────────────────
    rowHdr(5, "─  AUTO  AVG  TP / SL  ─")

    // ── 6: Final avg TP ─────────────────────────────────────
    rowLV(6, "★ Avg TP  (Final)", fBoth(finalTP, sugTP), cT)

    // ── 7: Final avg SL ─────────────────────────────────────
    rowLV(7, "★ Avg SL  (Final)", fBoth(finalSL, sugSL), cO)

    // ── 8: R:R ──────────────────────────────────────────────
    rrCol = rrRatio >= 2.0 ? cG : rrRatio >= 1.0 ? cY : cR
    rowLV(8, "⚖  R:R Ratio",
         str.tostring(rrRatio, "#.##") + " : 1", rrCol)

    if not i_compact
        // ── 9: Method breakdown header ───────────────────────
        rowHdr(9, "─  METHOD  BREAKDOWN  ─")

        rowLV(10, "Simple Avg TP / SL",
             f2(simTP) + " / " + f2(simSL), cT)
        rowLV(11, "EMA-Weighted TP / SL",
             f2(ewTP) + " / " + f2(ewSL), cT)
        rowLV(12, "Trimmed (" + str.tostring(math.round(i_trim)) + "%) TP / SL",
             f2(trTP) + " / " + f2(trSL), cT)
        rowLV(13, "Per-Bar (ATR) TP / SL",
             f2(pbTP) + " / " + f2(pbSL), cPu)

        // ── 14: Range stats header ────────────────────────────
        rowHdr(14, "─  HIGH / LOW  RANGE  STATS  ─")

        rowLV(15, "Avg High %  (pivot buf)",
             fBoth(simTP, close * (1.0 + simTP / 100.0)), cG)
        rowLV(16, "Max High %  seen",
             fBoth(maxTP, close * (1.0 + maxTP / 100.0)), cGd)
        rowLV(17, "Min High %  seen",
             fBoth(minTP, close * (1.0 + minTP / 100.0)), cGd)
        rowLV(18, "Avg Low %   (pivot buf)",
             fBoth(simSL, close * (1.0 - simSL / 100.0)), cR)
        rowLV(19, "Max Low %   seen",
             fBoth(maxSL, close * (1.0 - maxSL / 100.0)), cRd)

        if showFull()
            // ── 20: KNN header ────────────────────────────────
            rowHdr(20, "─  KNN  PREDICTION  (next 5 bars)  ─")

            kHstr = i_knnOn and not na(knnPredH) ?
                 fBoth(knnPredH, knnPredHPrice) : "disabled"
            kLstr = i_knnOn and not na(knnPredL) ?
                 fBoth(knnPredL, knnPredLPrice) : "disabled"

            rowLV(21, "KNN Pred High +%", kHstr, cPu)
            rowLV(22, "KNN Pred Low  -%", kLstr, cFu)

            // ── 23: Signal header ─────────────────────────────
            rowHdr(23, "─  SIGNAL  STATE  ─")

            rsiCol = rsi <= i_rsiOS ? cG : rsi >= i_rsiOB ? cR : cY
            rowLV(24, "RSI (" + str.tostring(i_rsiLen) + ")",
                 str.tostring(rsi, "#.##"), rsiCol)

            volPct = volume / math.max(volSma, 1.0) * 100.0
            rowLV(25, "Volume vs SMA",
                 str.tostring(volPct, "#") + "%",
                 volPct > 120.0 ? cG : cDim)

            sigTxt = buySignal  ? "▲ BUY  SIGNAL" :
                     sellSignal ? "▼ SELL SIGNAL" : "— Waiting —"
            sigCol = buySignal  ? cG : sellSignal ? cR : cDim
            rowLV(26, "Active Signal", sigTxt, sigCol)

            rowLV(27, "HTF (" + i_mtfTF + ") Pivots",
                 i_mtfOn ? "✔ active" : "✘ off",
                 i_mtfOn ? cG : cDim)
````
