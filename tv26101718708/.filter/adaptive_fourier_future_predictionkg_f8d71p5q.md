# Adaptive Fourier Future Prediction[KG]

- url: https://www.tradingview.com/script/f8d71p5Q-Adaptive-Fourier-Future-Prediction-KG/
- type: indicator
- pine_id: PUB;d45be6f2d5b14b6ab0ed46007847dc9f
- version: 1.0

## Description

Adaptive Fourier Future Prediction [KG] is a cycle-analysis  designed for the lower pane and main chart. It combines adaptive Fourier analysis, harmonic reconstruction, damped trend projection, volatility-based uncertainty bands, signal confirmation, and trade-level mapping. The lower pane shows a Fourier oscillator, signal line, momentum, stability, confidence, and BUY/SELL markers. The main chart displays a future projection path, projection channel, projected cycle tops and bottoms, projected BUY/SELL levels, and suggested Entry, Stop Loss, T1, T2, and T3 zones.

The indicator does not use lookahead or future data. Historical signals are fixed at bar close. Only the live future projection is redrawn while the last bar is developing. This is a probabilistic cycle projection, not an exact price prediction.

What Is Fourier Analysis?-----

Fourier analysis is a mathematical method that breaks a complex signal into simpler repeating waves. In financial markets, price can be viewed as a mixture of cycles with different lengths, strengths, and phases. The Fourier transform estimates how much of each cycle is present in recent price action.

This indicator applies that idea adaptively. It scans multiple lookback windows, ranks the strongest frequency components, identifies the dominant cycle, and reconstructs a smoothed cyclic model from several harmonics. It then projects that model forward while accounting for trend, damping, volatility, and model error. Because markets are noisy and constantly changing, the result is a probability-based path rather than a guaranteed future price.

How the Indicator Works:-

The engine evaluates several cycle windows, from shorter to longer, and selects the window that currently offers the best balance of energy, amplitude, stability, phase consistency, and directional agreement. It also compares results across windows to measure agreement. A red-noise compensation option helps prevent low-frequency trend components from dominating the cycle ranking.

The selected cycle is broken into harmonics, and the strongest components are used to reconstruct the cyclic part of price. A damped trend component is added, and a projection channel is created using ATR, reconstruction error, forecast error, cycle stability, and forecast quality. The indicator then estimates the next projected top and bottom of the dominant cycle, along with potential BUY and SELL levels.

Confidence is calculated from cycle stability, forecast direction, amplitude, phase, projection quality, ZLEMA confirmation, volume, support/resistance room, and optional higher-timeframe confirmation. The on-screen information panel summarizes the dominant cycle, selected window, phase, stability, forecast direction, forecast quality, confidence, market regime, and volume ratio.

How to Trade:-

Use confirmed bar closes for signals. The indicator is designed to avoid intrabar signal changes.

For a BUY signal, look for the forecast direction to be up, phase to be bullish or near a trough, cycle stability to be acceptable, confidence to be above the chosen threshold, price to be supported by the ZLEMA filter, volume to be supportive, and enough room to resistance. Strong BUY signals require higher confidence and higher stability. Optional higher-timeframe confirmation can be enabled to block signals that disagree with larger cycles.

For a SELL signal, the opposite conditions apply: forecast direction down, bearish phase or near a peak, acceptable stability, sufficient confidence, price below the ZLEMA filter, supportive volume, and enough room to support. Strong SELL signals require higher confidence and stability.

The Fourier oscillator and signal line show the current cycle position. Momentum columns help gauge whether cycle pressure is rising or fading. The projected top and bottom labels show where the dominant cycle is expected to peak or trough. The projected BUY and SELL levels are cycle-based areas, not guaranteed turning points.

When a signal appears, the main chart plots suggested trade levels: Entry, Stop Loss, Target 1, Target 2, and Target 3. These levels combine ATR-based targets, the Fourier projection path, projected cycle extremes, and nearby support or resistance. Stop loss is checked before targets in the trade-monitoring logic. Targets can be used for scaling out, and trades expire after the selected number of bars.

Avoid forcing trades in uncertain regimes, weak cycles, low stability, or when price is overly extended from the ZLEMA. Use the confidence score, stability score, market regime, and higher-timeframe agreement as filters. Always apply independent risk management.

Timeframe and Markets:-

The indicator can be used on any timeframe, but it performs best on liquid markets with enough historical data for cycle analysis. Intraday traders may prefer 5-minute to 15-minute charts on active instruments. Swing traders may prefer 1-hour, 4-hour, or daily charts, where cycles tend to be more stable and less noisy.

Very low timeframes can produce more false cycle readings due to noise and spread. When using higher-timeframe confirmation, select higher timeframes above the chart timeframe. The indicator needs sufficient bars to calculate its Fourier windows reliably, so extremely short histories or illiquid symbols may reduce quality.

Alerts:-

The script includes alert conditions for BUY, SELL, STRONG BUY, STRONG SELL, Target 1 hit, Target 2 hit, Target 3 hit, Stop Loss hit, and high-confidence threshold crossings. These alerts are intended to support review and trade management, not to replace personal judgment.

Disclaimer:-

This indicator is for educational and research purposes only. It is not financial, investment, or trading advice. It does not guarantee profits and does not predict exact future prices. All projections are probabilistic and can fail, especially during news events, low-liquidity periods, or sudden regime changes. Past performance is not indicative of future results.

## Source Code

````pine
//@version=6
// =====================================================================================
//  ADAPTIVE FOURIER FUTURE PREDICTION ENGINE 
//  - Lower pane : Fourier oscillator, signal line, momentum, phase, stability,
//                 confidence, BUY / SELL markers, dashboard
//  - Main chart : future path, projection channel, projected top/bottom, BUY/SELL levels,
//                 Entry / SL / T1 / T2 / T3 and zones 
//  - No lookahead, no future data. Signals are fixed at bar close 
//    Only the live future projection is re-drawn while the last bar develops.
//  - This is a probabilistic cycle projection, NOT an exact price prediction.
// =====================================================================================
indicator("Adaptive Fourier Future Prediction[KG]", overlay=false, max_lines_count=500, max_labels_count=100, max_boxes_count=100, max_polylines_count=20)

// ============================== INPUTS ===============================================
G1 = "1. Fourier Engine"
G2 = "2. Forecast Projection"
G3 = "3. Signals and Confirmation"
G4 = "4. Trade Levels"
G5 = "5. Multi-Timeframe"
G6 = "6. Display and Alerts"

useW32   = input.bool(true, "Window 32",  group=G1, inline="w1")
useW48   = input.bool(true, "Window 48",  group=G1, inline="w1")
useW64   = input.bool(true, "Window 64",  group=G1, inline="w2")
useW96   = input.bool(true, "Window 96",  group=G1, inline="w2")
useW128  = input.bool(true, "Window 128", group=G1, inline="w3")
useW192  = input.bool(true, "Window 192", group=G1, inline="w3")
harmonics = input.int(5, "Harmonics (1-10)", minval=1, maxval=10, group=G1, tooltip="Number of strongest spectral components used in the reconstruction. Keep low to avoid overfitting.")
maxBins   = input.int(20, "Max DFT bins per window", minval=6, maxval=48, group=G1, tooltip="Limits the number of frequency bins evaluated per window (performance).")
minPer    = input.int(6, "Min cycle length (bars)", minval=4, maxval=16, group=G1)
whiten    = input.float(1.0, "Red-noise compensation", minval=0.0, maxval=2.0, step=0.1, group=G1, tooltip="Price spectra are dominated by low frequencies. Higher value favours shorter cycles when ranking bins.")
minHarm   = input.float(0.15, "Min harmonic power vs strongest", minval=0.02, maxval=0.8, step=0.01, group=G1)
calcStep  = input.int(3, "DFT recalculation step (bars)", minval=1, maxval=10, group=G1, tooltip="The DFT is refreshed every N bars (and on every tick of the last bar). Between refreshes the stored harmonics are advanced in phase.")
histBars  = input.int(3000, "History bars to process", minval=300, maxval=20000, group=G1)

baseH     = input.int(20, "Forecast horizon (bars)", minval=5, maxval=100, group=G2)
trendW    = input.float(0.5, "Trend component weight", minval=0.0, maxval=1.5, step=0.05, group=G2)
trendDamp = input.float(0.90, "Trend damping per bar", minval=0.5, maxval=0.99, step=0.01, group=G2)
devMult   = input.float(1.0, "Channel width multiplier", minval=0.3, maxval=3.0, step=0.1, group=G2)
qH        = input.int(5, "Forecast-quality horizon (bars)", minval=2, maxval=20, group=G2)
fqLen     = input.int(60, "Forecast-quality averaging (bars)", minval=20, maxval=300, group=G2)
atrLen    = input.int(14, "ATR length", minval=2, maxval=100, group=G2)
dirThr    = input.float(0.25, "Forecast direction dead-zone", minval=0.0, maxval=2.0, step=0.05, group=G2)
showFc    = input.bool(true, "Show future forecast path (main chart)", group=G2)
showCh    = input.bool(true, "Show upper/lower projection", group=G2)
showPT    = input.bool(true, "Show projected top / bottom", group=G2)

minStab    = input.float(40.0, "Minimum cycle stability for signals", minval=0.0, maxval=100.0, group=G3)
strongStab = input.float(60.0, "Minimum stability for STRONG signals", minval=0.0, maxval=100.0, group=G3)
allowWeak  = input.bool(false, "Allow signals on weak cycles", group=G3)
buyThr     = input.float(70.0, "BUY / SELL confidence threshold", minval=40.0, maxval=100.0, group=G3)
strongThr  = input.float(85.0, "STRONG confidence threshold", minval=50.0, maxval=100.0, group=G3)
confAlertThr = input.float(80.0, "Confidence alert threshold", minval=40.0, maxval=100.0, group=G3)
useZL      = input.bool(true, "Use ZLEMA confirmation", group=G3, inline="zl")
zlLen      = input.int(34, "Length", minval=2, maxval=200, group=G3, inline="zl")
extATR     = input.float(3.0, "Max extension from ZLEMA (ATR)", minval=0.5, maxval=10.0, step=0.1, group=G3)
volLen     = input.int(20, "Volume SMA length", minval=2, maxval=200, group=G3)
volStrong  = input.float(1.5, "Strong volume ratio", minval=1.0, maxval=5.0, step=0.1, group=G3)
volWeak    = input.float(0.8, "Weak volume ratio", minval=0.1, maxval=1.5, step=0.1, group=G3)
volStrict  = input.bool(false, "Strict volume (require bullish/bearish volume)", group=G3)
srLen      = input.int(10, "Support/Resistance pivot length", minval=3, maxval=50, group=G3)
cooldown   = input.int(5, "Min bars between signals", minval=0, maxval=100, group=G3)

slMult     = input.float(1.5, "Stop Loss ATR multiplier", minval=0.3, maxval=10.0, step=0.1, group=G4)
t1Mult     = input.float(1.5, "Target 1 ATR multiplier", minval=0.3, maxval=20.0, step=0.1, group=G4)
t2Mult     = input.float(2.5, "Target 2 ATR multiplier", minval=0.3, maxval=30.0, step=0.1, group=G4)
t3Mult     = input.float(4.0, "Target 3 ATR multiplier", minval=0.3, maxval=40.0, step=0.1, group=G4)
fcWeight   = input.float(0.5, "Forecast weight in targets (0 = pure ATR)", minval=0.0, maxval=1.0, step=0.05, group=G4)
entryZone  = input.float(0.25, "Entry zone half-height (ATR)", minval=0.05, maxval=2.0, step=0.05, group=G4)
tradeMaxBars = input.int(80, "Trade expiry (bars)", minval=5, maxval=500, group=G4)
showBoxes  = input.bool(true, "Draw entry / risk / reward zones", group=G4)

useMTF     = input.bool(false, "Use higher-timeframe Fourier confirmation", group=G5)
htf1       = input.timeframe("60", "Higher TF 1", group=G5)
htf2       = input.timeframe("240", "Higher TF 2", group=G5)
mtfRequire = input.bool(false, "Block signals that disagree with higher TFs", group=G5)

sigLen     = input.int(4, "Fourier signal smoothing", minval=1, maxval=30, group=G6)
showMom    = input.bool(true, "Pane: Fourier momentum", group=G6)
showSigPane = input.bool(true, "Pane: BUY / SELL markers", group=G6)
showZL     = input.bool(false, "Main chart: plot ZLEMA", group=G6)
showDash   = input.bool(true, "Show dashboard", group=G6)
dashPosS   = input.string("Top Right", "Dashboard position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=G6)
cFc    = input.color(#00E5FF, "Forecast path", group=G6)
cBand  = input.color(#7C8CFF, "Projection bands", group=G6)
cGood  = input.color(#00C853, "Bullish / reward", group=G6)
cBad   = input.color(#FF1744, "Bearish / risk", group=G6)
cEntry = input.color(#2962FF, "Entry", group=G6)

dashPos = dashPosS == "Top Left" ? position.top_left : dashPosS == "Bottom Left" ? position.bottom_left : dashPosS == "Bottom Right" ? position.bottom_right : position.top_right
color cDashBg = #000000e0

// ============================== PERSISTENT STATE =====================================
SPN = 64

var array<int>   WIN    = array.from(32, 48, 64, 96, 128, 192)
var array<float> ybuf   = array.new_float(192, 0.0)
var array<float> specRe = array.new_float(6 * SPN, 0.0)
var array<float> specIm = array.new_float(6 * SPN, 0.0)
var array<float> scBuf  = array.new_float(SPN, -1.0)

// per-window results of the latest calculation
var array<float> wOn   = array.new_float(6, 0.0)
var array<float> wPer  = array.new_float(6, 0.0)
var array<float> wAmp  = array.new_float(6, 0.0)
var array<float> wTh   = array.new_float(6, 0.0)
var array<float> wOm   = array.new_float(6, 0.0)
var array<float> wEn   = array.new_float(6, 0.0)
var array<float> wHar  = array.new_float(6, 0.0)
var array<float> wBias = array.new_float(6, 0.0)
var array<float> wTr   = array.new_float(6, 0.0)
var array<float> wVar  = array.new_float(6, 0.0)
var array<float> wStab = array.new_float(6, 0.0)
var array<float> nCF   = array.new_float(6, 0.0)
var array<float> nCP   = array.new_float(6, 0.0)
var array<float> nCA   = array.new_float(6, 0.0)
var array<float> nCE   = array.new_float(6, 0.0)

// committed (bar-close) state used for consistency scores
var array<float> pPer = array.new_float(6, na)
var array<float> pTh  = array.new_float(6, na)
var array<float> pBar = array.new_float(6, na)
var array<float> pAmp = array.new_float(6, na)
var array<float> pEn  = array.new_float(6, na)
var array<float> kF   = array.new_float(6, na)
var array<float> kP   = array.new_float(6, na)
var array<float> kA   = array.new_float(6, na)
var array<float> kE   = array.new_float(6, na)

// harmonic model 
var array<float> cRe = array.new_float(10, 0.0)
var array<float> cIm = array.new_float(10, 0.0)
var array<float> cOm = array.new_float(10, 0.0)
var int   cCnt    = 0
var int   cBar    = 0
var float tSlope  = 0.0
var float domPer  = 20.0
var float domAmp  = 0.0
var float domTh0  = 0.0
var float domOm   = 0.1
var float domEn   = 0.0
var float domHar  = 0.0
var float ampTot  = 0.0
var float recErr  = 0.0
var float fitR    = 0.0
var float stabV   = 0.0
var int   selW    = -1
var int   prevSel = -1

// forecast path buffers (index = bars ahead)
var array<float> fcLg = array.new_float(101, 0.0)
var array<float> fcP  = array.new_float(101, 0.0)
var array<float> fcU  = array.new_float(101, 0.0)
var array<float> fcL  = array.new_float(101, 0.0)

// support / resistance pivots
var array<float> srArr = array.new_float(0)

// drawing handles
var array<line>  fcLn = array.new<line>()
var array<label> fcLb = array.new<label>()
var array<line>  tLn  = array.new<line>()
var array<label> tLb  = array.new<label>()
var array<box>   tBx  = array.new<box>()
var polyline pPath = na
var polyline pUp   = na
var polyline pLo   = na
var polyline pBand = na

// trade + signal state
var int   sigSt = 0
var int   tDir = 0
var float tEntry = na
var float tSL = na
var float tT1 = na
var float tT2 = na
var float tT3 = na
var int   tBar = 0
var bool  tH1 = false
var bool  tH2 = false
var bool  tH3 = false
var int   lastSigBar = -1000

var table dash = showDash ? table.new(dashPos, 2, 15, bgcolor=cDashBg, border_width=1, border_color=color.new(color.gray, 70)) : na

// ============================== HELPER FUNCTIONS =====================================
f_wrap(float x) =>
    x - 2.0 * math.pi * math.floor((x + math.pi) / (2.0 * math.pi))

f_pos(float x) =>
    x - 2.0 * math.pi * math.floor(x / (2.0 * math.pi))

f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

f_atan2(float y, float x) =>
    float r = 0.0
    if x > 0.0
        r := math.atan(y / x)
    else if x < 0.0
        r := y >= 0.0 ? math.atan(y / x) + math.pi : math.atan(y / x) - math.pi
    else
        r := y > 0.0 ? math.pi / 2.0 : y < 0.0 ? -math.pi / 2.0 : 0.0
    r

f_pow(int w, int k) =>
    float rr = array.get(specRe, w * SPN + k)
    float ii = array.get(specIm, w * SPN + k)
    rr * rr + ii * ii

f_mag(int w, int k) =>
    math.sqrt(f_pow(w, k))

// cyclic component (log-price units) at 'dd' bars after the model bar
f_cyc(float dd) =>
    float sres = 0.0
    if cCnt > 0
        for i = 0 to cCnt - 1
            float om = array.get(cOm, i)
            sres += array.get(cRe, i) * math.cos(om * dd) - array.get(cIm, i) * math.sin(om * dd)
    sres

// damped trend contribution after h bars (log-price units)
f_trend(float h) =>
    tSlope * trendW * trendDamp * (1.0 - math.pow(trendDamp, h)) / (1.0 - trendDamp)

// projection deviation (log-price units)
f_dev(float h, float atrL_, float ampT, float rec, float hErr, float stab_, float fq_) =>
    float sf = 1.8 - 1.0 * stab_ / 100.0
    float qf = 1.5 - 0.8 * fq_ / 100.0
    float e1 = atrL_ * atrL_ * h * 0.5
    float e2 = math.pow(0.3 * ampT, 2)
    float e3 = 0.5 * rec * rec
    float e4 = hErr * hErr * h / qH
    devMult * sf * qf * math.sqrt(e1 + e2 + e3 + e4)

// builds the forecast arrays; returns first meaningful projected top / bottom (bars ahead, -1 if none)
f_scan(int hh, float c0, float cyc0, float dd0, float atrL_, float ampT, float rec, float hErr, float stab_, float fq_) =>
    array.set(fcLg, 0, 0.0)
    array.set(fcP, 0, c0)
    array.set(fcU, 0, c0)
    array.set(fcL, 0, c0)
    for h = 1 to hh
        float lg = f_cyc(dd0 + h) - cyc0 + f_trend(h)
        float dv = f_dev(h, atrL_, ampT, rec, hErr, stab_, fq_)
        array.set(fcLg, h, lg)
        array.set(fcP, h, c0 * math.exp(lg))
        array.set(fcU, h, c0 * math.exp(lg + dv))
        array.set(fcL, h, c0 * math.exp(lg - dv))
    int tH = -1
    int bH = -1
    float runMin = 0.0
    float runMax = 0.0
    float sigT = 0.5 * atrL_
    for h = 1 to hh - 1
        float l0 = array.get(fcLg, h - 1)
        float l1 = array.get(fcLg, h)
        float l2 = array.get(fcLg, h + 1)
        runMin := math.min(runMin, l1)
        runMax := math.max(runMax, l1)
        if tH < 0 and l1 > l0 and l1 >= l2 and l1 - runMin >= sigT
            tH := h
        if bH < 0 and l1 < l0 and l1 <= l2 and runMax - l1 >= sigT
            bH := h
    [tH, bH]

f_clearLines(array<line> arr) =>
    int n = array.size(arr)
    if n > 0
        for i = 0 to n - 1
            line.delete(array.get(arr, i))
        array.clear(arr)
    true

f_clearLabels(array<label> arr) =>
    int n = array.size(arr)
    if n > 0
        for i = 0 to n - 1
            label.delete(array.get(arr, i))
        array.clear(arr)
    true

f_clearTrade() =>
    f_clearLines(tLn)
    f_clearLabels(tLb)
    int n = array.size(tBx)
    if n > 0
        for i = 0 to n - 1
            box.delete(array.get(tBx, i))
        array.clear(tBx)
    true

f_setTradeX(int xe) =>
    int n1 = array.size(tLn)
    if n1 > 0
        for i = 0 to n1 - 1
            line.set_x2(array.get(tLn, i), xe)
    int n2 = array.size(tBx)
    if n2 > 0
        for i = 0 to n2 - 1
            box.set_right(array.get(tBx, i), xe)
    int n3 = array.size(tLb)
    if n3 > 0
        for i = 0 to n3 - 1
            label.set_x(array.get(tLb, i), xe)
    true

f_drawTrade(int dT, float e, float sl, float t1, float t2, float t3, float a, int x1) =>
    f_clearTrade()
    int x2 = x1 + 3
    if showBoxes
        array.push(tBx, box.new(x1, math.max(e, sl), x2, math.min(e, sl), xloc=xloc.bar_index, border_color=color.new(color.gray, 100), bgcolor=color.new(cBad, 86), force_overlay=true))
        array.push(tBx, box.new(x1, math.max(e, t3), x2, math.min(e, t3), xloc=xloc.bar_index, border_color=color.new(color.gray, 100), bgcolor=color.new(cGood, 90), force_overlay=true))
        array.push(tBx, box.new(x1, e + entryZone * a, x2, e - entryZone * a, xloc=xloc.bar_index, border_color=color.new(color.gray, 100), bgcolor=color.new(cEntry, 72), force_overlay=true))
    array.push(tLn, line.new(x1, e, x2, e, xloc=xloc.bar_index, color=cEntry, width=2, force_overlay=true))
    array.push(tLn, line.new(x1, sl, x2, sl, xloc=xloc.bar_index, color=cBad, width=2, force_overlay=true))
    array.push(tLn, line.new(x1, t1, x2, t1, xloc=xloc.bar_index, color=color.new(cGood, 10), width=1, force_overlay=true))
    array.push(tLn, line.new(x1, t2, x2, t2, xloc=xloc.bar_index, color=color.new(cGood, 10), width=1, force_overlay=true))
    array.push(tLn, line.new(x1, t3, x2, t3, xloc=xloc.bar_index, color=cGood, width=2, force_overlay=true))
    string pf = dT == 1 ? "BUY " : "SELL "
    array.push(tLb, label.new(x2, e, pf + "ENTRY " + str.tostring(e, format.mintick), xloc=xloc.bar_index, yloc=yloc.price, color=color.new(cEntry, 10), style=label.style_label_left, textcolor=color.white, size=size.tiny, force_overlay=true))
    array.push(tLb, label.new(x2, sl, "STOP LOSS " + str.tostring(sl, format.mintick), xloc=xloc.bar_index, yloc=yloc.price, color=color.new(cBad, 10), style=label.style_label_left, textcolor=color.white, size=size.tiny, force_overlay=true))
    array.push(tLb, label.new(x2, t1, "TARGET 1 " + str.tostring(t1, format.mintick), xloc=xloc.bar_index, yloc=yloc.price, color=color.new(cGood, 25), style=label.style_label_left, textcolor=color.white, size=size.tiny, force_overlay=true))
    array.push(tLb, label.new(x2, t2, "TARGET 2 " + str.tostring(t2, format.mintick), xloc=xloc.bar_index, yloc=yloc.price, color=color.new(cGood, 25), style=label.style_label_left, textcolor=color.white, size=size.tiny, force_overlay=true))
    array.push(tLb, label.new(x2, t3, "TARGET 3 " + str.tostring(t3, format.mintick), xloc=xloc.bar_index, yloc=yloc.price, color=color.new(cGood, 10), style=label.style_label_left, textcolor=color.white, size=size.tiny, force_overlay=true))
    true

// higher-timeframe Fourier direction (sliding single-bin DFT, static lengths, no dynamic history)
f_htfBin(float y, int n, int k, float lead) =>
    float w = 2.0 * math.pi * k / n
    float t = bar_index
    float sc = math.sum(y * math.cos(w * t), n)
    float ss = math.sum(y * math.sin(w * t), n)
    (2.0 / n) * (sc * (math.cos(w * (t + lead)) - math.cos(w * t)) + ss * (math.sin(w * (t + lead)) - math.sin(w * t)))

f_htfDir() =>
    float l = math.log(close)
    float y = l - ta.ema(l, 32)
    float mv = f_htfBin(y, 64, 3, 3.0) + f_htfBin(y, 64, 4, 3.0) + f_htfBin(y, 64, 5, 3.0) + f_htfBin(y, 64, 6, 3.0) + f_htfBin(y, 64, 7, 3.0) + f_htfBin(y, 64, 8, 3.0)
    float thr = 0.05 * nz(ta.atr(14) / close)
    mv > thr ? 1 : mv < -thr ? -1 : 0

f_dTxt(int d) =>
    d == 1 ? "UP" : d == -1 ? "DOWN" : "FLAT"

f_cell(int r, string a, string b, color c) =>
    table.cell(dash, 0, r, a, text_color=color.new(color.white, 25), text_halign=text.align_left, text_size=size.small, bgcolor=cDashBg)
    table.cell(dash, 1, r, b, text_color=c, text_halign=text.align_right, text_size=size.small, bgcolor=cDashBg)
    true

// ============================== BASE SERIES ==========================================
float lp = math.log(close)
max_bars_back(lp, 256)
float atrV = ta.atr(atrLen)
float atrL = atrV / close
int zlLag = math.floor((zlLen - 1) / 2)
float zl = ta.ema(close + (close - close[zlLag]), zlLen)

// ============================== ADAPTIVE FOURIER ENGINE ==============================
bool inRange = bar_index >= 200 and bar_index >= last_bar_index - histBars
bool calcNow = inRange and (bar_index % calcStep == 0 or barstate.islast or cCnt == 0)

if calcNow
    array<bool> wen = array.from(useW32, useW48, useW64, useW96, useW128, useW192)
    if not array.includes(wen, true)
        array.set(wen, 2, true)
    int nOn = 0
    for w = 0 to 5
        array.set(wOn, w, 0.0)
        if array.get(wen, w)
            int N = array.get(WIN, w)
            // 1) detrend (least-squares linear detrend of log price)
            float sy = 0.0
            float sxy = 0.0
            for n = 0 to N - 1
                float v = lp[N - 1 - n]
                array.set(ybuf, n, v)
                sy += v
                sxy += n * v
            float sx = N * (N - 1) / 2.0
            float sxx = (N - 1) * N * (2 * N - 1) / 6.0
            float bSl = (N * sxy - sx * sy) / (N * sxx - sx * sx)
            float aIc = (sy - bSl * sx) / N
            float vs = 0.0
            for n = 0 to N - 1
                float yv = array.get(ybuf, n) - (aIc + bSl * n)
                array.set(ybuf, n, yv)
                vs += yv * yv
            float varr = vs / N
            // 2) DFT over bins 2..kHi (X[k] = sum y[n] * exp(-j*2*pi*k*n/N))
            int kHi = math.min(math.floor(N / minPer), 1 + maxBins)
            float totP = 0.0
            float bestSc = -1.0
            int kd = 2
            for k = 2 to kHi
                float om = 2.0 * math.pi * k / N
                float cw = math.cos(om)
                float sw = math.sin(om)
                float c = 1.0
                float s = 0.0
                float re = 0.0
                float im = 0.0
                for n = 0 to N - 1
                    float yy = array.get(ybuf, n)
                    re += yy * c
                    im -= yy * s
                    float c2 = c * cw - s * sw
                    s := s * cw + c * sw
                    c := c2
                array.set(specRe, w * SPN + k, re)
                array.set(specIm, w * SPN + k, im)
                float p = re * re + im * im
                totP += p
                float scr = p * math.pow(k, whiten)
                if scr > bestSc
                    bestSc := scr
                    kd := k
            // 3) dominant component of this window
            float reD = array.get(specRe, w * SPN + kd)
            float imD = array.get(specIm, w * SPN + kd)
            float pD = reD * reD + imD * imD
            float ampD = 2.0 * math.sqrt(pD) / N
            float omD = 2.0 * math.pi * kd / N
            float thD = f_wrap(f_atan2(imD, reD) + omD * (N - 1))
            float kRef = kd
            if kd > 2 and kd < kHi
                float m0 = math.sqrt(pD)
                float mm = f_mag(w, kd - 1)
                float mp = f_mag(w, kd + 1)
                float dn = mm - 2.0 * m0 + mp
                if dn < 0.0
                    kRef := kd + f_clamp(0.5 * (mm - mp) / dn, -0.5, 0.5)
            float perD = N / kRef
            float p2 = 2 * kd <= kHi ? f_pow(w, 2 * kd) : 0.0
            float p3 = 3 * kd <= kHi ? f_pow(w, 3 * kd) : 0.0
            float enR = totP > 0.0 ? pD / totP : 0.0
            float harR = totP > 0.0 ? (pD + p2 + p3) / totP : 0.0
            // 4) consistency (frequency, phase, amplitude, spectral energy) vs last confirmed state
            float pP = array.get(pPer, w)
            float pT = array.get(pTh, w)
            float pB = array.get(pBar, w)
            float pA = array.get(pAmp, w)
            float pE = array.get(pEn, w)
            float iF = na(pP) ? 0.5 : math.max(0.0, 1.0 - math.abs(perD - pP) / (0.35 * pP))
            float iP = 0.5
            if not na(pT) and not na(pP)
                float expTh = pT + 2.0 * math.pi * (bar_index - pB) / pP
                iP := math.max(0.0, 1.0 - 2.0 * math.abs(f_wrap(thD - expTh)) / math.pi)
            float iA = na(pA) ? 0.5 : math.min(ampD, pA) / math.max(math.max(ampD, pA), 1e-12)
            float iE = na(pE) ? 0.5 : math.min(enR, pE) / math.max(math.max(enR, pE), 1e-12)
            float oF = array.get(kF, w)
            float oP = array.get(kP, w)
            float oA = array.get(kA, w)
            float oE = array.get(kE, w)
            float nF = na(oF) ? iF : 0.7 * oF + 0.3 * iF
            float nP = na(oP) ? iP : 0.7 * oP + 0.3 * iP
            float nA = na(oA) ? iA : 0.7 * oA + 0.3 * iA
            float nE = na(oE) ? iE : 0.7 * oE + 0.3 * iE
            array.set(wOn, w, 1.0)
            array.set(wPer, w, perD)
            array.set(wAmp, w, ampD)
            array.set(wTh, w, thD)
            array.set(wOm, w, omD)
            array.set(wEn, w, enR)
            array.set(wHar, w, harR)
            array.set(wBias, w, -math.sin(thD))
            array.set(wTr, w, bSl)
            array.set(wVar, w, varr)
            array.set(nCF, w, nF)
            array.set(nCP, w, nP)
            array.set(nCA, w, nA)
            array.set(nCE, w, nE)
            array.set(wStab, w, 100.0 * (0.30 * nF + 0.25 * nP + 0.20 * nA + 0.25 * nE))
            nOn += 1

    if nOn > 0
        // 5) rank candidate cycles: energy, amplitude, stability, phase consistency, directional consistency
        float maxEn = 1e-12
        float maxAm = 1e-12
        float cons = 0.0
        for w = 0 to 5
            if array.get(wOn, w) > 0.5
                maxEn := math.max(maxEn, array.get(wEn, w))
                maxAm := math.max(maxAm, array.get(wAmp, w))
                cons += array.get(wBias, w) * array.get(wEn, w)
        int bw = -1
        float bscore = -1.0
        for w = 0 to 5
            if array.get(wOn, w) > 0.5
                float dc = 0.5 + 0.5 * array.get(wBias, w) * math.sign(cons)
                float rk = 0.25 * array.get(wEn, w) / maxEn + 0.20 * array.get(wAmp, w) / maxAm + 0.25 * array.get(wStab, w) / 100.0 + 0.15 * array.get(nCP, w) + 0.15 * dc + (w == prevSel ? 0.05 : 0.0)
                if rk > bscore
                    bscore := rk
                    bw := w
        int Ns = array.get(WIN, bw)
        float perS = array.get(wPer, bw)
        // multi-window agreement 
        float agNum = 0.0
        float agDen = 0.0
        for w = 0 to 5
            if array.get(wOn, w) > 0.5
                float ew = array.get(wEn, w)
                agDen += ew
                if math.abs(array.get(wPer, w) - perS) / perS <= 0.30
                    agNum += ew
        float agree = nOn > 1 and agDen > 0.0 ? agNum / agDen : 0.5
        float stabNew = 100.0 * (0.25 * array.get(nCF, bw) + 0.20 * array.get(nCP, bw) + 0.15 * array.get(nCA, bw) + 0.15 * array.get(nCE, bw) + 0.25 * agree)
        // 6) multi-harmonic reconstruction from the strongest bins of the selected window
        int kHs = math.min(math.floor(Ns / minPer), 1 + maxBins)
        for k = 2 to kHs
            array.set(scBuf, k, f_pow(bw, k) * math.pow(k, whiten))
        int cnt = 0
        float firstS = 0.0
        float sumAmp = 0.0
        float capVar = 0.0
        for r = 1 to harmonics
            float bs = -1.0
            int bk = -1
            for k = 2 to kHs
                float v2 = array.get(scBuf, k)
                if v2 > bs
                    bs := v2
                    bk := k
            if bk < 0 or bs <= 0.0
                break
            if r == 1
                firstS := bs
            if bs < minHarm * firstS
                break
            array.set(scBuf, bk, -1.0)
            float omK = 2.0 * math.pi * bk / Ns
            float reK = array.get(specRe, bw * SPN + bk)
            float imK = array.get(specIm, bw * SPN + bk)
            float tpr = math.pow(0.9, r - 1)
            float amK = 2.0 / Ns * tpr
            float ph0 = omK * (Ns - 1)
            float crr = reK * math.cos(ph0) - imK * math.sin(ph0)
            float cii = reK * math.sin(ph0) + imK * math.cos(ph0)
            array.set(cRe, cnt, amK * crr)
            array.set(cIm, cnt, amK * cii)
            array.set(cOm, cnt, omK)
            float aK = 2.0 * math.sqrt(reK * reK + imK * imK) / Ns * tpr
            sumAmp += aK
            capVar += aK * aK / 2.0
            cnt += 1
        float vSel = array.get(wVar, bw)
        cCnt := cnt
        cBar := bar_index
        tSlope := array.get(wTr, bw)
        domPer := perS
        domAmp := array.get(wAmp, bw)
        domTh0 := array.get(wTh, bw)
        domOm := array.get(wOm, bw)
        domEn := array.get(wEn, bw)
        domHar := array.get(wHar, bw)
        ampTot := math.max(sumAmp, 1e-9)
        recErr := math.sqrt(math.max(0.0, vSel - capVar))
        fitR := vSel > 0.0 ? f_clamp(capVar / vSel, 0.0, 1.0) : 0.0
        stabV := f_clamp(stabNew, 0.0, 100.0)
        selW := bw
        // commit consistency state only on confirmed bars 
        if barstate.isconfirmed
            prevSel := bw
            for w = 0 to 5
                if array.get(wOn, w) > 0.5
                    array.set(pPer, w, array.get(wPer, w))
                    array.set(pTh, w, array.get(wTh, w))
                    array.set(pBar, w, bar_index)
                    array.set(pAmp, w, array.get(wAmp, w))
                    array.set(pEn, w, array.get(wEn, w))
                    array.set(kF, w, array.get(nCF, w))
                    array.set(kP, w, array.get(nCP, w))
                    array.set(kA, w, array.get(nCA, w))
                    array.set(kE, w, array.get(nCE, w))

// ============================== PER-BAR MODEL OUTPUTS ================================
bool hasModel = cCnt > 0
float dd = hasModel ? bar_index - cBar : 0.0
float cycNow = hasModel ? f_cyc(dd) : na
float Ls = math.max(2.0, math.round(domPer / 6.0))
float fcMove = hasModel ? f_cyc(dd + Ls) - cycNow + f_trend(Ls) : na
float fcZ = hasModel ? fcMove / (atrL * math.sqrt(Ls)) : na
int fcDir = hasModel ? (fcZ > dirThr ? 1 : fcZ < -dirThr ? -1 : 0) : 0
float oscN = hasModel ? f_clamp(100.0 * cycNow / math.max(ampTot, 1e-9), -100.0, 100.0) : na
float fSig = ta.ema(nz(oscN), sigLen)
float fMom = oscN - oscN[3]
float fSlope = hasModel ? 100.0 * fcMove / Ls : na
float thNow = hasModel ? f_wrap(domTh0 + domOm * dd) : 0.0
float phDeg = f_pos(thNow) * 180.0 / math.pi
float sinT = math.sin(thNow)
float cosT = math.cos(thNow)
bool nearTr = cosT < -0.8
bool nearPk = cosT > 0.8
bool phBull = nearTr or (not nearPk and -sinT > 0.1)
bool phBear = nearPk or (not nearTr and -sinT < -0.1)
float ampRel = hasModel ? domAmp / (atrL * math.sqrt(math.max(domPer, 4.0) / 2.0)) : 0.0

// ---- forecast quality: previous forecast vs actual subsequent price ----
float predQ = hasModel ? lp + f_cyc(dd + qH) - cycNow + f_trend(qH) : na
float predOld = predQ[qH]
float scaleQ = nz(atrL, 0.001) * math.sqrt(qH)
float eAbs = na(predOld) ? na : math.abs(lp - predOld)
float eUse = na(eAbs) ? scaleQ : eAbs
float hitV = na(predOld) ? 0.5 : (math.sign(predOld - lp[qH]) == math.sign(lp - lp[qH]) ? 1.0 : 0.0)
float histErr = nz(ta.sma(eUse, fqLen), scaleQ)
float errN = nz(ta.sma(eUse / scaleQ, fqLen), 1.0)
float dirAcc = nz(ta.sma(hitV, fqLen), 0.5)
float fqS = 100.0 * (0.5 * f_clamp((dirAcc - 0.35) / 0.45, 0.0, 1.0) + 0.5 * f_clamp(1.0 - (errN - 0.5) / 2.0, 0.0, 1.0))
float pqS = 0.6 * fqS + 0.4 * 100.0 * fitR

// ---- adaptive forecast horizon ----
int effH0 = stabV >= 80.0 ? baseH : stabV >= 60.0 ? math.round(baseH * 0.75) : stabV >= 40.0 ? math.round(baseH * 0.5) : math.round(baseH * 0.2)
int effH = math.min(100, math.max(3, effH0))

// ---- volume confirmation ----
float vSma = ta.sma(volume, volLen)
bool hasVol = not na(vSma) and vSma > 0.0
float vRatio = hasVol ? volume / vSma : 1.0
bool vBull = close > open
bool vBear = close < open
bool vStr = vRatio >= volStrong
bool vMid = vRatio >= volWeak
int vCls = not hasVol ? 0 : vBull and vStr ? 2 : vBull and vMid ? 1 : vBear and vStr ? -2 : vBear and vMid ? -1 : 0

// ---- support / resistance from confirmed pivots ----
float phv = ta.pivothigh(high, srLen, srLen)
float plv = ta.pivotlow(low, srLen, srLen)
if barstate.isconfirmed
    if not na(phv)
        array.push(srArr, phv)
        if array.size(srArr) > 14
            array.shift(srArr)
    if not na(plv)
        array.push(srArr, plv)
        if array.size(srArr) > 14
            array.shift(srArr)
float resP = na
float supP = na
int srN = array.size(srArr)
if srN > 0
    for i = 0 to srN - 1
        float lv = array.get(srArr, i)
        if lv > close and (na(resP) or lv < resP)
            resP := lv
        else if lv < close and (na(supP) or lv > supP)
            supP := lv
float roomUp = na(resP) ? 4.0 : (resP - close) / atrV
float roomDn = na(supP) ? 2.0 : (close - supP) / atrV

// ---- higher-timeframe Fourier direction (confirmed HTF bar only, lookahead_off) ----
string tf1u = useMTF ? htf1 : timeframe.period
string tf2u = useMTF ? htf2 : timeframe.period
int hd1 = request.security(syminfo.tickerid, tf1u, f_htfDir()[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
int hd2 = request.security(syminfo.tickerid, tf2u, f_htfDir()[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
bool ok1 = useMTF and timeframe.in_seconds(htf1) > timeframe.in_seconds(timeframe.period)
bool ok2 = useMTF and timeframe.in_seconds(htf2) > timeframe.in_seconds(timeframe.period)
int d1 = ok1 ? nz(hd1) : 0
int d2 = ok2 ? nz(hd2) : 0
int nM = (ok1 ? 1 : 0) + (ok2 ? 1 : 0)
float mtfSumL = (ok1 ? (d1 == 1 ? 1.0 : d1 == 0 ? 0.5 : 0.0) : 0.0) + (ok2 ? (d2 == 1 ? 1.0 : d2 == 0 ? 0.5 : 0.0) : 0.0)
float mtfSumS = (ok1 ? (d1 == -1 ? 1.0 : d1 == 0 ? 0.5 : 0.0) : 0.0) + (ok2 ? (d2 == -1 ? 1.0 : d2 == 0 ? 0.5 : 0.0) : 0.0)
float mtfL = nM == 0 ? 1.0 : mtfSumL / nM
float mtfS = nM == 0 ? 1.0 : mtfSumS / nM
bool mtfOkL = not mtfRequire or mtfL >= 0.5
bool mtfOkS = not mtfRequire or mtfS >= 0.5

// ---- confidence (0-100): stability 20, direction 15, amplitude 15, phase 10, projection quality 10, ZLEMA 10, volume 10, S/R 10 ----
float zMove = hasModel ? fcMove / (atrL * math.sqrt(Ls)) : 0.0
float dirL = f_clamp(50.0 + 25.0 * zMove, 0.0, 100.0)
float dirS = f_clamp(50.0 - 25.0 * zMove, 0.0, 100.0)
float ampS = hasModel ? f_clamp(40.0 * ampRel, 0.0, 100.0) : 0.0
float phLg = f_clamp(50.0 - 50.0 * sinT, 0.0, 100.0)
phLg := nearTr ? math.max(phLg, 85.0) : nearPk ? math.min(phLg, 15.0) : phLg
float phSh = f_clamp(50.0 + 50.0 * sinT, 0.0, 100.0)
phSh := nearPk ? math.max(phSh, 85.0) : nearTr ? math.min(phSh, 15.0) : phSh
float zlLg = not useZL ? 50.0 : (close > zl ? 50.0 : 0.0) + (zl > zl[1] ? 30.0 : 0.0) + (math.abs(close - zl) < 2.0 * atrV ? 20.0 : 0.0)
float zlSh = not useZL ? 50.0 : (close < zl ? 50.0 : 0.0) + (zl < zl[1] ? 30.0 : 0.0) + (math.abs(close - zl) < 2.0 * atrV ? 20.0 : 0.0)
float vLg = not hasVol ? 50.0 : f_clamp(50.0 + 25.0 * vCls, 0.0, 100.0)
float vSh = not hasVol ? 50.0 : f_clamp(50.0 - 25.0 * vCls, 0.0, 100.0)
float srLg = 100.0 * (0.6 * math.min(roomUp / 3.0, 1.0) + 0.4 * (1.0 - math.min(roomDn / 3.0, 1.0)))
float srSh = 100.0 * (0.6 * math.min(roomDn / 3.0, 1.0) + 0.4 * (1.0 - math.min(roomUp / 3.0, 1.0)))
float stabMul = stabV >= minStab ? 1.0 : 0.6 + 0.4 * stabV / math.max(minStab, 1.0)
float confL = hasModel ? math.min(100.0, (0.20 * stabV + 0.15 * dirL + 0.15 * ampS + 0.10 * phLg + 0.10 * pqS + 0.10 * zlLg + 0.10 * vLg + 0.10 * srLg) * stabMul * (0.85 + 0.15 * mtfL)) : 0.0
float confS = hasModel ? math.min(100.0, (0.20 * stabV + 0.15 * dirS + 0.15 * ampS + 0.10 * phSh + 0.10 * pqS + 0.10 * zlSh + 0.10 * vSh + 0.10 * srSh) * stabMul * (0.85 + 0.15 * mtfS)) : 0.0
int side = fcDir != 0 ? fcDir : (confL >= confS ? 1 : -1)
float confDisp = side == 1 ? confL : confS

// ---- market regime ----
float zlS3 = nz((zl - zl[3]) / atrV)
float hh20 = nz(ta.highest(high, 20)[1], high)
float ll20 = nz(ta.lowest(low, 20)[1], low)
bool structUp = close > hh20
bool structDn = close < ll20
string regime = "UNCERTAIN"
if hasModel
    if stabV < 30.0
        regime := "UNCERTAIN"
    else if ampRel < 2.5 and (zlS3 > 0.5 or structUp) and close > zl
        regime := "TRENDING UP"
    else if ampRel < 2.5 and (zlS3 < -0.5 or structDn) and close < zl
        regime := "TRENDING DOWN"
    else if stabV >= 50.0 and ampRel >= 1.2
        regime := fcDir > 0 ? "CYCLIC UP" : fcDir < 0 ? "CYCLIC DOWN" : "RANGE"
    else if math.abs(zlS3) < 0.35
        regime := "RANGE"

// ---- next projected top / bottom of the dominant cycle (analytic) and BUY / SELL levels ----
float hTop = hasModel ? f_pos(-thNow) / domOm : 999.0
float hBot = hasModel ? f_pos(math.pi - thNow) / domOm : 999.0
float bLv = na
float sLv = na
if hasModel and hBot >= 1.0 and hBot <= effH
    bLv := close * math.exp(f_cyc(dd + hBot) - cycNow + f_trend(hBot))
    if not na(supP) and math.abs(bLv - supP) <= 0.75 * atrV
        bLv := (bLv + supP) / 2.0
    if bLv >= close
        bLv := na
if hasModel and hTop >= 1.0 and hTop <= effH
    sLv := close * math.exp(f_cyc(dd + hTop) - cycNow + f_trend(hTop))
    if not na(resP) and math.abs(sLv - resP) <= 0.75 * atrV
        sLv := (sLv + resP) / 2.0
    if sLv <= close
        sLv := na

// ============================== SIGNAL ENGINE (bar-close only) =======================
bool extL = close - zl > extATR * atrV
bool extS = zl - close > extATR * atrV
bool nearTop = hasModel and cycNow > 0.85 * ampTot
bool nearBot = hasModel and cycNow < -0.85 * ampTot
bool zlBullOK = not useZL or close > zl
bool zlBearOK = not useZL or close < zl
bool volBullOK = not hasVol or vCls >= (volStrict ? 1 : 0)
bool volBearOK = not hasVol or vCls <= (volStrict ? -1 : 0)
bool stabGate = allowWeak or stabV >= minStab
bool setupL = hasModel and fcDir == 1 and fcMove > 0 and phBull and stabGate and zlBullOK and volBullOK and not extL and not nearTop and mtfOkL
bool setupS = hasModel and fcDir == -1 and fcMove < 0 and phBear and stabGate and zlBearOK and volBearOK and not extS and not nearBot and mtfOkS
int sigRaw = 0
if setupL and confL >= buyThr
    sigRaw := confL >= strongThr and stabV >= strongStab ? 2 : 1
else if setupS and confS >= buyThr
    sigRaw := confS >= strongThr and stabV >= strongStab ? -2 : -1

int sigPrev = sigSt
bool newBuy = barstate.isconfirmed and sigRaw >= 1 and sigPrev < 1
bool newSell = barstate.isconfirmed and sigRaw <= -1 and sigPrev > -1

// ---- trade monitoring on confirmed bars (stop loss checked first, conservative) ----
bool slEvt = false
bool tgEvt = false
int tgNo = 0
if barstate.isconfirmed and tDir != 0 and bar_index > tBar
    if tDir == 1
        if low <= tSL
            slEvt := true
            tDir := 0
            f_setTradeX(bar_index)
        else
            if not tH1 and high >= tT1
                tH1 := true
                tgEvt := true
                tgNo := 1
            if not tH2 and high >= tT2
                tH1 := true
                tH2 := true
                tgEvt := true
                tgNo := 2
            if not tH3 and high >= tT3
                tH1 := true
                tH2 := true
                tH3 := true
                tgEvt := true
                tgNo := 3
            if tH3
                tDir := 0
                f_setTradeX(bar_index)
    else
        if high >= tSL
            slEvt := true
            tDir := 0
            f_setTradeX(bar_index)
        else
            if not tH1 and low <= tT1
                tH1 := true
                tgEvt := true
                tgNo := 1
            if not tH2 and low <= tT2
                tH1 := true
                tH2 := true
                tgEvt := true
                tgNo := 2
            if not tH3 and low <= tT3
                tH1 := true
                tH2 := true
                tH3 := true
                tgEvt := true
                tgNo := 3
            if tH3
                tDir := 0
                f_setTradeX(bar_index)
    if tDir != 0 and bar_index - tBar > tradeMaxBars
        tDir := 0
        f_setTradeX(bar_index)

bool buyEvt = newBuy and bar_index - lastSigBar >= cooldown and tDir != 1
bool sellEvt = newSell and bar_index - lastSigBar >= cooldown and tDir != -1
if barstate.isconfirmed
    sigSt := sigRaw

// ---- trade levels: ATR + Fourier path + projected cycle top/bottom + support/resistance ----
if buyEvt or sellEvt
    int dT = buyEvt ? 1 : -1
    float e = close
    float a = atrV
    [tHi, bHi] = f_scan(effH, close, cycNow, dd, atrL, ampTot, recErr, histErr, stabV, fqS)
    float tpP = tHi > 0 ? array.get(fcP, tHi) : na
    float btP = bHi > 0 ? array.get(fcP, bHi) : na
    float fRef = dT == 1 ? tpP : btP
    float aT1 = e + dT * a * t1Mult
    float aT2 = e + dT * a * t2Mult
    float aT3 = e + dT * a * t3Mult
    bool fOk = not na(fRef) and dT * (fRef - e) > 0.6 * a
    float fT3 = fOk ? fRef : aT3
    float fT1 = e + 0.4 * (fT3 - e)
    float fT2 = e + 0.7 * (fT3 - e)
    float wF = fcWeight * f_clamp(stabV / 80.0, 0.3, 1.0)
    float n1 = (1.0 - wF) * aT1 + wF * fT1
    float n2 = (1.0 - wF) * aT2 + wF * fT2
    float n3 = fOk ? fT3 : aT3
    n3 := dT == 1 ? math.min(n3, e + 2.0 * t3Mult * a) : math.max(n3, e - 2.0 * t3Mult * a)
    float rs = dT == 1 ? resP : supP
    if not na(rs)
        if dT * (rs - e) > 0.5 * a
            if dT * (n1 - rs) > 0.0
                n1 := rs - dT * 0.1 * a
            if dT * (n2 - rs) > 0.0
                n2 := rs - dT * 0.1 * a
    n2 := dT == 1 ? math.max(n2, n1 + 0.25 * a) : math.min(n2, n1 - 0.25 * a)
    n3 := dT == 1 ? math.max(n3, n2 + 0.25 * a) : math.min(n3, n2 - 0.25 * a)
    float slB = e - dT * a * slMult
    float sb = dT == 1 ? supP : resP
    float slF = slB
    if not na(sb)
        if dT * (e - sb) > 0.3 * a and dT * (sb - slB) > 0.0
            slF := sb - dT * 0.2 * a
    slF := dT == 1 ? math.max(slF, e - 1.6 * slMult * a) : math.min(slF, e + 1.6 * slMult * a)
    tDir := dT
    tEntry := e
    tSL := slF
    tT1 := n1
    tT2 := n2
    tT3 := n3
    tBar := bar_index
    tH1 := false
    tH2 := false
    tH3 := false
    lastSigBar := bar_index
    f_drawTrade(dT, e, slF, n1, n2, n3, a, bar_index)

// ============================== LIVE FUTURE PROJECTION (main chart) ==================
if barstate.islast
    if not na(pPath)
        polyline.delete(pPath)
        pPath := na
    if not na(pUp)
        polyline.delete(pUp)
        pUp := na
    if not na(pLo)
        polyline.delete(pLo)
        pLo := na
    if not na(pBand)
        polyline.delete(pBand)
        pBand := na
    f_clearLines(fcLn)
    f_clearLabels(fcLb)

    // keep an active trade drawn up to the current bar
    if tDir != 0
        f_setTradeX(bar_index + 3)

    if hasModel and showFc
        [tH, bH] = f_scan(effH, close, cycNow, dd, atrL, ampTot, recErr, histErr, stabV, fqS)
        array<chart.point> ptsP = array.new<chart.point>()
        array<chart.point> ptsU = array.new<chart.point>()
        array<chart.point> ptsL = array.new<chart.point>()
        array<chart.point> ptsB = array.new<chart.point>()
        for h = 0 to effH
            array.push(ptsP, chart.point.from_index(bar_index + h, array.get(fcP, h)))
            array.push(ptsU, chart.point.from_index(bar_index + h, array.get(fcU, h)))
            array.push(ptsL, chart.point.from_index(bar_index + h, array.get(fcL, h)))
            array.push(ptsB, chart.point.from_index(bar_index + h, array.get(fcU, h)))
        for h = effH to 0
            array.push(ptsB, chart.point.from_index(bar_index + h, array.get(fcL, h)))
        if showCh
            pBand := polyline.new(ptsB, curved=false, closed=true, xloc=xloc.bar_index, line_color=color.new(cBand, 100), fill_color=color.new(cBand, 86), force_overlay=true)
            pUp := polyline.new(ptsU, curved=false, closed=false, xloc=xloc.bar_index, line_color=color.new(cBand, 20), line_style=line.style_dashed, line_width=1, force_overlay=true)
            pLo := polyline.new(ptsL, curved=false, closed=false, xloc=xloc.bar_index, line_color=color.new(cBand, 20), line_style=line.style_dashed, line_width=1, force_overlay=true)
        pPath := polyline.new(ptsP, curved=false, closed=false, xloc=xloc.bar_index, line_color=cFc, line_width=2, force_overlay=true)

        if showPT
            if tH > 0
                array.push(fcLb, label.new(bar_index + tH, array.get(fcP, tH), "TOP +" + str.tostring(tH) + "b", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(cBad, 20), style=label.style_label_down, textcolor=color.white, size=size.tiny, force_overlay=true))
            if bH > 0
                array.push(fcLb, label.new(bar_index + bH, array.get(fcP, bH), "BOTTOM +" + str.tostring(bH) + "b", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(cGood, 20), style=label.style_label_up, textcolor=color.white, size=size.tiny, force_overlay=true))

        // projected BUY / SELL levels of the dominant cycle
        if not na(bLv)
            int xb = bar_index + math.round(hBot)
            array.push(fcLn, line.new(bar_index, bLv, xb, bLv, xloc=xloc.bar_index, color=color.new(cGood, 10), style=line.style_dotted, width=1, force_overlay=true))
            array.push(fcLb, label.new(xb, bLv, "BUY LEVEL " + str.tostring(bLv, format.mintick), xloc=xloc.bar_index, yloc=yloc.price, color=color.new(cGood, 40), style=label.style_label_left, textcolor=color.white, size=size.tiny, force_overlay=true))
        if not na(sLv)
            int xs = bar_index + math.round(hTop)
            array.push(fcLn, line.new(bar_index, sLv, xs, sLv, xloc=xloc.bar_index, color=color.new(cBad, 10), style=line.style_dotted, width=1, force_overlay=true))
            array.push(fcLb, label.new(xs, sLv, "SELL LEVEL " + str.tostring(sLv, format.mintick), xloc=xloc.bar_index, yloc=yloc.price, color=color.new(cBad, 40), style=label.style_label_left, textcolor=color.white, size=size.tiny, force_overlay=true))

// ============================== PLOTS (lower pane) ===================================
hline(100, "Upper", color=color.new(color.gray, 70), linestyle=hline.style_dotted)
hline(50, "Mid", color=color.new(color.gray, 85), linestyle=hline.style_dotted)
hline(0, "Zero", color=color.new(color.gray, 40), linestyle=hline.style_dashed)
hline(-100, "Lower", color=color.new(color.gray, 70), linestyle=hline.style_dotted)

pZero = plot(0, "zero_ref", color=na, editable=false)
pOsc  = plot(oscN, "Fourier oscillator", color=cFc, linewidth=2)
plot(fSig, "Fourier signal", color=color.new(color.orange, 0), linewidth=1)
fill(pOsc, pZero, color=oscN > 0 ? color.new(cGood, 82) : color.new(cBad, 82), title="Oscillator fill")
plot(showMom ? fMom : na, "Fourier momentum", style=plot.style_columns, color=fMom >= 0 ? color.new(cGood, 60) : color.new(cBad, 60))

plotshape(showSigPane and buyEvt, "Pane BUY", style=shape.triangleup, location=location.bottom, color=cGood, size=size.tiny)
plotshape(showSigPane and sellEvt, "Pane SELL", style=shape.triangledown, location=location.top, color=cBad, size=size.tiny)

// ============================== PLOTS (main chart overlay) ===========================
plot(showZL ? zl : na, "ZLEMA", color=color.new(color.orange, 0), linewidth=1, force_overlay=true)

plotshape(buyEvt and sigRaw == 1, "BUY", style=shape.labelup, location=location.belowbar, color=cGood, text="BUY", textcolor=color.white, size=size.small, force_overlay=true)
plotshape(buyEvt and sigRaw == 2, "STRONG BUY", style=shape.labelup, location=location.belowbar, color=color.new(cGood, 0), text="STRONG BUY", textcolor=color.white, size=size.small, force_overlay=true)
plotshape(sellEvt and sigRaw == -1, "SELL", style=shape.labeldown, location=location.abovebar, color=cBad, text="SELL", textcolor=color.white, size=size.small, force_overlay=true)
plotshape(sellEvt and sigRaw == -2, "STRONG SELL", style=shape.labeldown, location=location.abovebar, color=color.new(cBad, 0), text="STRONG SELL", textcolor=color.white, size=size.small, force_overlay=true)

plotshape(tgEvt and tgNo == 1, "Target 1 hit", style=shape.diamond, location=location.abovebar, color=cGood, text="T1", textcolor=color.white, size=size.tiny, force_overlay=true)
plotshape(tgEvt and tgNo == 2, "Target 2 hit", style=shape.diamond, location=location.abovebar, color=cGood, text="T2", textcolor=color.white, size=size.tiny, force_overlay=true)
plotshape(tgEvt and tgNo == 3, "Target 3 hit", style=shape.diamond, location=location.abovebar, color=cGood, text="T3", textcolor=color.white, size=size.tiny, force_overlay=true)
plotshape(slEvt, "Stop loss hit", style=shape.xcross, location=location.belowbar, color=cBad, text="SL", textcolor=color.white, size=size.tiny, force_overlay=true)

// ============================== DASHBOARD ============================================
if showDash and barstate.islast
    string dirTxt = fcDir > 0 ? "UP" : fcDir < 0 ? "DOWN" : "FLAT"
    color dirCol = fcDir > 0 ? cGood : fcDir < 0 ? cBad : color.gray
    string sigTxt = sigRaw == 2 ? "STRONG BUY" : sigRaw == 1 ? "BUY" : sigRaw == -1 ? "SELL" : sigRaw == -2 ? "STRONG SELL" : "NONE"
    color sigCol = sigRaw > 0 ? cGood : sigRaw < 0 ? cBad : color.gray
    color stabCol = stabV >= strongStab ? cGood : stabV >= minStab ? color.yellow : cBad
    string phTxt = hasModel ? str.tostring(phDeg, "#") + " deg " + (nearTr ? "(TROUGH)" : nearPk ? "(PEAK)" : phBull ? "(RISING)" : "(FALLING)") : "-"
    string trTxt = tDir == 1 ? "LONG @ " + str.tostring(tEntry, format.mintick) : tDir == -1 ? "SHORT @ " + str.tostring(tEntry, format.mintick) : "NONE"
    string tgTxt = tDir != 0 ? (tH3 ? "T3" : tH2 ? "T2" : tH1 ? "T1" : "waiting") : "-"
    string nxtTxt = hasModel ? "T +" + str.tostring(hTop, "#") + "b / B +" + str.tostring(hBot, "#") + "b" : "-"
    string mtfTxt = not useMTF ? "OFF" : nM == 0 ? "N/A (pick higher TFs)" : (ok1 ? f_dTxt(d1) : "-") + " / " + (ok2 ? f_dTxt(d2) : "-")

    table.cell(dash, 0, 0, "ADAPTIVE FOURIER ", text_color=color.white, text_size=size.normal, bgcolor=color.new(cEntry, 30))
    table.cell(dash, 1, 0, "", bgcolor=color.new(cEntry, 30))
    table.merge_cells(dash, 0, 0, 1, 0)
    f_cell(1, "Dominant cycle", hasModel ? str.tostring(domPer, "#.0") + " bars" : "-", color.white)
    f_cell(2, "Window used", selW >= 0 ? str.tostring(array.get(WIN, selW)) : "-", color.white)
    f_cell(3, "Cycle phase", phTxt, color.white)
    f_cell(4, "Cycle stability", str.tostring(stabV, "#") + " %", stabCol)
    f_cell(5, "Forecast direction", dirTxt, dirCol)
    f_cell(6, "Forecast quality", str.tostring(pqS, "#") + " %", pqS >= 60 ? cGood : pqS >= 40 ? color.yellow : cBad)
    f_cell(7, "Confidence", (side == 1 ? "LONG " : "SHORT ") + str.tostring(confDisp, "#") + " %", side == 1 ? cGood : cBad)
    f_cell(8, "Regime", regime, color.white)
    f_cell(9, "Volume ratio", hasVol ? str.tostring(vRatio, "#.00") + "x" : "n/a", vRatio >= volStrong ? cGood : vRatio < volWeak ? cBad : color.white)
    
// ============================== ALERTS ===============================================
alertcondition(buyEvt, "BUY signal", "Adaptive Fourier : BUY signal")
alertcondition(sellEvt, "SELL signal", "Adaptive Fourier : SELL signal")
alertcondition(buyEvt and sigRaw == 2, "STRONG BUY signal", "Adaptive Fourier : STRONG BUY signal")
alertcondition(sellEvt and sigRaw == -2, "STRONG SELL signal", "Adaptive Fourier : STRONG SELL signal")
alertcondition(tgEvt and tgNo == 1, "Target 1 hit", "Adaptive Fourier : Target 1 hit")
alertcondition(tgEvt and tgNo == 2, "Target 2 hit", "Adaptive Fourier : Target 2 hit")
alertcondition(tgEvt and tgNo == 3, "Target 3 hit", "Adaptive Fourier : Target 3 hit")
alertcondition(slEvt, "Stop loss hit", "Adaptive Fourier : Stop loss hit")
alertcondition(ta.crossover(confDisp, confAlertThr), "High confidence", "Adaptive Fourier : confidence crossed the alert threshold")
````
