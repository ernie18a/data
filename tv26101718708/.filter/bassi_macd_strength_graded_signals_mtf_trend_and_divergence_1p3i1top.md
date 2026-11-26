# Bassi MACD Strength - Graded Signals, MTF Trend and Divergence

- url: https://www.tradingview.com/script/1p3i1TOp-Bassi-MACD-Strength-Graded-Signals-MTF-Trend-and-Divergence/
- type: indicator
- pine_id: PUB;4933b26f2b3d43a783732365a363e4cb
- version: 1.0

## Description

[b]OVERVIEW[/b]
Bassi MACD Strength is a MACD that tells you how much each crossover is worth. Every signal-line cross is graded STRONG or WEAK. The grade comes from a 0–100% strength score and from how many higher timeframes agree with the cross. A one-line ACTION recommendation and a built-in backtest go with it. The backtest splits results by grade, so you can check whether the grading works on your symbol.

[b]HOW IT WORKS[/b]

[b]1) Auto-fit MACD[/b]
The MACD lengths adjust to your timeframe and asset class:
[list]
[*]Charts of 20 minutes or less: 8/17/9 (crypto 8/21/5)
[*]Up to 2 hours: 12/26/9
[*]Higher timeframes: 19/39/9 (crypto 12/26/9)
[/list]
Turn "Auto-fit" off to use your own lengths.

[b]2) Colour-coded crosses[/b]
[list]
[*]Green circle: bullish cross below zero (fresh, early)
[*]Red circle: bearish cross above zero (fresh, early)
[*]Orange circle: a late cross on the wrong side of zero
[*]Diamond + "▲ 72% | 4/5" label: a STRONG signal (strength % and how many timeframes agree)
[/list]

[b]3) Strength score (0–100%)[/b]
Six components are each normalised against their own recent history (z-score, then logistic scaling):
[list]
[*]Momentum (smoothed ROC)
[*]MACD slope
[*]Histogram acceleration
[*]Relative volume
[*]Trend position (price vs EMA50/EMA200 in ATR units)
[*]Freshness (how stretched MACD already is)
[/list]
You can change the weight of each component in the settings.

[b]4) Multi-timeframe grading[/b]
Each cross is checked against the trend on 15m, 1h, 4h, 1D and 1W. A cross is STRONG when at least N of the 5 agree with it (default 3). There are three trend methods:
[list]
[*]Price vs EMA50 (responsive, the default)
[*]EMA 50/200 (structural)
[*]MACD vs Signal (pure momentum)
[/list]

[b]5) Exhaustion and reversal[/b]
[list]
[*]⚑ EXT: a cross while MACD is stretched beyond X standard deviations from zero. This often marks exhaustion.
[*]R triangles: regular divergence (possible reversal)
[*]H triangles: hidden divergence (possible trend continuation)
[*]✓ REV: an extreme cross confirmed by a regular divergence. This is the highest-priority setup.
[/list]

[b]6) MACD trend line[/b]
A linear-regression line on MACD, with a dotted projection forward. The line itself moves smoothly, but its colour (aqua = rising, orange = falling) uses a faster window so it keeps pace with the histogram.

[b]DASHBOARD[/b]
[list]
[*]The score for each component, plus the OVERALL strength
[*]ACTION, in this priority order: ✓ REV › ⚑ EXHAUSTION › ENTER (strong/weak) › EXIT/TIGHTEN (histogram fading) › CHOP (low ADX, no trade) › CONTINUATION › WAIT
[*]Trend by timeframe: trend and MACD direction on 15m / 1h / 4h / 1D / 1W. Orange with • means the row is flipping on the live bar. ● marks your chart's timeframe.
[*]TF Align and MACD Align totals
[*]Regime (ADX plus the higher-timeframe EMA trend)
[*]Backtest: win rate and expectancy in R, for STRONG and WEAK signals separately, plus average MFE/MAE
[*]Relative volume, distance of MACD from zero, and active divergences
[/list]

[b]BUILT-IN BACKTEST[/b]
Each filtered signal opens a virtual trade with an ATR target (default 1.5×) and an ATR stop (default 1.0×). Target and stop are checked against the bar's high and low. If both are hit in the same bar, the stop counts first, so the stats lean pessimistic. The trade can also close early when histogram momentum fades, or when an opposite signal appears. These are simplified statistics, not a strategy-tester report: there are no fees, no slippage and no position sizing.

[b]FILTERS (optional)[/b]
[list]
[*]Higher-timeframe EMA50/200 trend
[*]ADX trend strength (DI direction must agree)
[*]Cooldown between signals
[*]Zero-line filter
[/list]
The circles always show. The filters only control which signals count as "filtered" for grading and the backtest.

[b]ALERTS[/b]
[list]
[*]Green / red / any circle
[*]Circles with all timeframes aligned (15m/1h/4h/1D)
[*]MACD trend newly aligned bullish or bearish on all timeframes
[*]Regular and hidden divergence (bullish and bearish)
[*]Confirmed reversal, top and bottom
[/list]

[b]REPAINTING[/b]
Signals, grading, alerts and the backtest use confirmed (closed-bar) higher-timeframe values, so they do not repaint.
The divergence marker is drawn back on the pivot bar, but it only appears after the right-side lookback bars (default 5) have closed.
By default the dashboard's trend-by-timeframe rows show the LIVE, developing bar, so they match what you see on the chart. Those rows can change until the bar closes. Turn off "Dashboard shows LIVE trend" to show closed-bar values only.

[b]HOW TO USE[/b]
[list]
[*]Work with STRONG signals that match the dashboard's ACTION line.
[*]Skip entries when ACTION says CHOP.
[*]Treat ⚑ EXH as a signal to take profit, not to enter.
[*]Before trusting the grading on a symbol, check the backtest block. STRONG should show better expectancy than WEAK.
[*]Once you trust it, turn on "Hide WEAK circles" for a cleaner chart.
[/list]

[b]DISCLAIMER[/b]
This indicator is for education and analysis only. It is not financial advice. Past results, including the built-in backtest, do not guarantee future performance.

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════
//  Bassi MACD Strength — Graded Signals, Multi-TF Trend & Divergence
//  This source code is subject to the terms of the
//  Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// ════════════════════════════════════════════════════════════════
indicator("Bassi MACD Strength — Graded Signals, Multi-TF Trend & Divergence", "BassiMACD", overlay = false, max_labels_count = 500, max_lines_count = 500)

// ════════════ MACD INPUTS ════════════
sourceInput  = input.source(close, "Source")
autoFitInput = input.bool(true, "Auto-fit MACD lengths")
fastLenInput = input.int(12, "Fast length (manual)",   1)
slowLenInput = input.int(26, "Slow length (manual)",   1)
sigLenInput  = input.int(9,  "Signal length (manual)", 1)
oscTypeInput = input.string("EMA", "Oscillator MA type", ["EMA", "SMA"], display = display.none)
sigTypeInput = input.string("EMA", "Signal MA type",     ["EMA", "SMA"], display = display.none)
zeroFiltInput = input.bool(false, "Zero-line filter")

// ════════════ SIGNAL FILTERS ════════════
useFilters   = input.bool(true,  "Enable signal filters", group="Filters",
     tooltip = "Master switch for the big-ring filtered signals + backtest. The circles themselves always show.")
requireHTF   = input.bool(true,  "Require higher-timeframe trend", group="Filters")
htfInput     = input.timeframe("", "Higher timeframe (blank = auto)", group="Filters")
useADX       = input.bool(true,  "Require ADX trend regime", group="Filters")
diLen        = input.int(14, "DMI length",    minval=1, group="Filters")
adxSmooth    = input.int(14, "ADX smoothing", minval=1, group="Filters")
adxThr       = input.float(23, "Min ADX (trend strength)", step=1, group="Filters")
cooldownBars = input.int(12, "Cooldown (bars between signals)", minval=0, group="Filters")

// ════════════ MULTI-TF TREND ════════════
trendMethod  = input.string("Price vs EMA50", "Trend method (per TF)",
     ["EMA 50/200", "Price vs EMA50", "MACD vs Signal"], group="Multi-TF Trend",
     tooltip = "EMA 50/200 = slow structural trend (can stay DOWN for days into a strong rally). Price vs EMA50 = responsive, matches what you see on the chart. MACD vs Signal = fastest, pure momentum.")
htfLiveTable = input.bool(true, "Dashboard shows LIVE (developing) trend", group="Multi-TF Trend",
     tooltip = "ON: table rows update in real time and match the chart. Signals, grading and alerts ALWAYS use the confirmed closed-bar value, so nothing repaints.")
dashTiny     = input.bool(true, "Compact dashboard (tiny text)", group="Multi-TF Trend",
     tooltip = "Smaller font -> much narrower table. Turn off for the larger version.")

// ════════════ STRONG / WEAK GRADING ════════════
mtfMin       = input.int(3, "Min higher-TF agreement for STRONG (of 5)", minval=1, maxval=5, group="Grading",
     tooltip = "A circle is STRONG if at least this many of the 15m/1h/4h/1D/1W trends agree with its direction. 3 = lenient, 4-5 = strict/rare.")
requireFresh = input.bool(false, "STRONG must be a fresh cross (right side of zero)", group="Grading")
requireRegimeStrong = input.bool(false, "STRONG must also pass ADX regime", group="Grading")
hideWeak     = input.bool(false, "Hide WEAK circles", group="Grading",
     tooltip = "Turn on once you trust the grading: only strong, trend-aligned circles will be drawn.")
showStar     = input.bool(true, "Mark STRONG signals with a star", group="Grading")

// ════════════ EXTREME / EXHAUSTION CROSSES ════════════
detectExtreme = input.bool(true, "Flag extreme (far-from-zero) crosses", group="Extreme Crosses",
     tooltip = "Crosses that happen while MACD is stretched far from zero often mark momentum exhaustion / reversals. Tagged with a ⚑ flag.")
extremeZ      = input.float(1.8, "Distance threshold (std-devs of MACD from zero)", step=0.1, minval=0.5, group="Extreme Crosses")

// ════════════ MOMENTUM / VOLUME INPUTS ════════════
autoMomentumFit = input.bool(true, "Auto-fit Momentum params", group="Strength Eval")
rocLenInput    = input.int(14, "Momentum ROC Length (manual)", minval=1, group="Strength Eval")
smoothLen      = input.int(3,  "Momentum Smoothing (manual)",  minval=1, group="Strength Eval")
rocThreshInput = input.float(2.0, "Strong Momentum % (manual)", step=0.1, group="Strength Eval")
autoVolFit     = input.bool(true, "Auto-fit Volume sensitivity", group="Strength Eval")
volLength      = input.int(20,  "Volume SMA Length", minval=1, group="Strength Eval")
rvolThreshInput = input.float(1.15, "Rel Volume Threshold (manual)", step=0.05, group="Strength Eval")
emaFastLen   = input.int(50,  "Fast EMA (trend)",  group="Strength Eval")
emaSlowLen   = input.int(200, "Slow EMA (trend)",  group="Strength Eval")
zLook        = input.int(120, "Normalization lookback", minval=20, group="Strength Eval")
scoreSens    = input.float(1.0, "Score sensitivity (k)", step=0.1, minval=0.2, maxval=3.0, group="Strength Eval")

// ════════════ TREND LINE INPUTS ════════════
trendLen = input.int(20, "MACD trend-line length", minval=2, group="MACD Trend Line")
colorLen = input.int(4,  "Colour reaction speed (bars)", minval=1, maxval=50, group="MACD Trend Line",
     tooltip = "The line's PATH stays smooth (uses length above), but its COLOUR flips using this much shorter window — so aqua/orange changes almost as fast as the histogram's green/red. Lower = faster colour flips (1-2 can flicker), higher = slower.")
projLen  = input.int(8,  "Projection length (bars)", minval=1, group="MACD Trend Line")
showProj = input.bool(true, "Show forward projection", group="MACD Trend Line")

// ════════════ STRENGTH WEIGHTING ════════════
wMomentum = input.float(0.12, "Weight: Momentum",      step=0.01, minval=0, maxval=1, group="Strength Weighting")
wSlope    = input.float(0.20, "Weight: MACD slope",    step=0.01, minval=0, maxval=1, group="Strength Weighting")
wAccel    = input.float(0.20, "Weight: Hist accel",    step=0.01, minval=0, maxval=1, group="Strength Weighting")
wVolume   = input.float(0.13, "Weight: Volume RVOL",   step=0.01, minval=0, maxval=1, group="Strength Weighting")
wTrend    = input.float(0.15, "Weight: Trend confirm", step=0.01, minval=0, maxval=1, group="Strength Weighting")
wFresh    = input.float(0.20, "Weight: Freshness",     step=0.01, minval=0, maxval=1, group="Strength Weighting")

// ════════════ DIVERGENCE INPUTS ════════════
useDiv     = input.bool(true, "Detect MACD divergence", group="Divergence")
divLbL     = input.int(5, "Pivot lookback left",  minval=1, group="Divergence")
divLbR     = input.int(5, "Pivot lookback right", minval=1, group="Divergence",
     tooltip = "Divergence confirms divLbR bars after the pivot (standard pivot method).")
divValid   = input.int(8, "Bars a divergence stays valid", minval=1, group="Divergence")
useHiddenDiv = input.bool(true, "Detect hidden divergence (trend continuation)", group="Divergence",
     tooltip = "Hidden bullish = higher low in price + lower low in MACD (continuation of an uptrend). Hidden bearish = lower high in price + higher high in MACD (continuation of a downtrend).")

// ════════════ BACKTEST INPUTS ════════════
winR      = input.float(1.5, "Target (ATR multiple)", step=0.1, minval=0.1, group="Backtest")
lossR     = input.float(1.0, "Stop (ATR multiple)",   step=0.1, minval=0.1, group="Backtest")
useHistExit = input.bool(true, "Exit when histogram fades", group="Backtest",
     tooltip = "Closes the (back)trade when MACD-histogram momentum weakens for N bars instead of waiting for the opposite cross.")
fadeBars  = input.int(3, "Histogram fade bars", minval=1, group="Backtest")
showFade  = input.bool(true, "Show live histogram-fade exit marker", group="Backtest")

// ════════════ AUTO-FIT MACD ════════════
tfMin    = timeframe.in_seconds() / 60
isCrypto = syminfo.type == "crypto"

autoFast = tfMin <= 20 ? 8                  : tfMin <= 120 ? 12 : isCrypto ? 12 : 19
autoSlow = tfMin <= 20 ? (isCrypto ? 21:17) : tfMin <= 120 ? 26 : isCrypto ? 26 : 39
autoSig  = tfMin <= 20 ? (isCrypto ? 5 : 9) : 9
fastLen = autoFitInput ? autoFast : fastLenInput
slowLen = autoFitInput ? autoSlow : slowLenInput
sigLen  = autoFitInput ? autoSig  : sigLenInput

// ════════════ AUTO-FIT MOMENTUM / VOLUME ════════════
int   autoRocLen = tfMin <= 20 ? (isCrypto ? 10 : 12) : tfMin <= 120 ? (isCrypto ? 12 : 14) : (isCrypto ? 14 : 20)
int   rocLength  = autoMomentumFit ? autoRocLen : rocLenInput
float autoRvolThresh = tfMin <= 20 ? 1.10 : tfMin <= 120 ? 1.15 : 1.20
float rvolThresh = autoVolFit ? autoRvolThresh : rvolThreshInput

// ════════════ HELPERS ════════════
ma(float source, simple int length, simple string maType) =>
    switch maType
        "EMA" => ta.ema(source, length)
        "SMA" => ta.sma(source, length)

z(float src, simple int len) =>
    s = ta.stdev(src, len)
    s == 0 or na(s) ? 0.0 : src / s

logistic(float x) =>
    xx = math.max(math.min(x * scoreSens, 12), -12)
    100.0 / (1.0 + math.exp(-xx))

// ════════════ MACD ════════════
maFast = ma(sourceInput, fastLen, oscTypeInput)
maSlow = ma(sourceInput, slowLen, oscTypeInput)
macd   = maFast - maSlow
signal = ma(macd, sigLen, sigTypeInput)
hist   = macd - signal
hColor = hist >= 0 ? hist > hist[1] ? #26a69a : #b2dfdb : hist > hist[1] ? #ffcdd2 : #ff5252

hline(0, "Zero", #787b8680)
plot(hist, "Histogram", hColor, style = plot.style_columns)
plot(macd, "MACD", #2962ff)
plot(signal, "Signal line", #ff6d00)

// ════════════ MACD TREND LINE + PROJECTION ════════════
macdLR     = ta.linreg(macd, trendLen, 0)
macdLRprev = ta.linreg(macd, trendLen, 1)
lrSlope    = macdLR - macdLRprev                       // smooth path slope (projection)

// Colour uses a much FASTER slope so it flips in sync with the
// histogram's green/red instead of lagging behind the smooth path.
fastSlope  = ta.linreg(macd, colorLen, 0) - ta.linreg(macd, colorLen, 1)
lrColor    = fastSlope >= 0 ? color.aqua : color.orange
plot(macdLR, "MACD Trend", lrColor, linewidth = 2)

var line projLine = na
if barstate.islast and showProj
    line.delete(projLine)
    projLine := line.new(bar_index, macdLR, bar_index + projLen, macdLR + lrSlope * projLen,
         color = lrColor, style = line.style_dotted, width = 2)

// ════════════ HTF TREND + ADX (filters) ════════════
autoHtf = tfMin <= 5 ? "60" : tfMin <= 60 ? "240" : tfMin <= 240 ? "D" : "W"
htfRes  = htfInput == "" ? autoHtf : htfInput

htfFast = request.security(syminfo.tickerid, htfRes, ta.ema(close, emaFastLen)[1], lookahead = barmerge.lookahead_off)
htfSlow = request.security(syminfo.tickerid, htfRes, ta.ema(close, emaSlowLen)[1], lookahead = barmerge.lookahead_off)

[diPlus, diMinus, adxVal] = ta.dmi(diLen, adxSmooth)

reqHTF = useFilters and requireHTF
reqADX = useFilters and useADX
cd     = useFilters ? cooldownBars : 0

htfBull   = not reqHTF or htfFast > htfSlow
htfBear   = not reqHTF or htfFast < htfSlow
regimeOK  = not reqADX or adxVal >= adxThr
diBull    = not reqADX or diPlus >  diMinus
diBear    = not reqADX or diMinus > diPlus

// ════════════ MULTI-TIMEFRAME TREND (15m / 1h / 4h / 1D / 1W) ════════════
// Returns [live, confirmed]:
//   live      = trend of the CURRENT (developing) higher-TF bar -> matches the chart
//   confirmed = trend of the last CLOSED higher-TF bar          -> non-repainting
trendPack() =>
    fEma = ta.ema(close, emaFastLen)
    sEma = ta.ema(close, emaSlowLen)
    [mLine, sLine, _h] = ta.macd(close, fastLen, slowLen, sigLen)
    t = trendMethod == "EMA 50/200"     ? (fEma > sEma  ? 1 : -1) :
         trendMethod == "Price vs EMA50" ? (close > fEma ? 1 : -1) :
         (mLine > sLine ? 1 : -1)
    m = mLine > sLine ? 1 : -1          // MACD direction on that TF
    [t, m, t[1], m[1]]

trendOf(simple string tf) =>
    request.security(syminfo.tickerid, tf, trendPack(), lookahead = barmerge.lookahead_off)

// Local (chart-TF) trend: zero security lag when a row equals the chart TF
[locLive, locMacdLive, locConf, locMacdConf] = trendPack()
chartSec = timeframe.in_seconds()

[s15Live,  s15MLive,  s15Conf,  s15MConf ] = trendOf("15")
[s60Live,  s60MLive,  s60Conf,  s60MConf ] = trendOf("60")
[s240Live, s240MLive, s240Conf, s240MConf] = trendOf("240")
[sDLive,   sDMLive,   sDConf,   sDMConf  ] = trendOf("D")
[sWLive,   sWMLive,   sWConf,   sWMConf  ] = trendOf("W")

// If a row IS the chart timeframe, use the locally computed trend (no lag)
is15  = timeframe.in_seconds("15")  == chartSec
is60  = timeframe.in_seconds("60")  == chartSec
is240 = timeframe.in_seconds("240") == chartSec
isD   = timeframe.in_seconds("D")   == chartSec
isW   = timeframe.in_seconds("W")   == chartSec

t15Live  = is15  ? locLive : s15Live
t60Live  = is60  ? locLive : s60Live
t240Live = is240 ? locLive : s240Live
tDLive   = isD   ? locLive : sDLive
tWLive   = isW   ? locLive : sWLive

t15  = is15  ? locConf : s15Conf
t60  = is60  ? locConf : s60Conf
t240 = is240 ? locConf : s240Conf
tD   = isD   ? locConf : sDConf
tW   = isW   ? locConf : sWConf

// MACD direction per TF (live + confirmed)
m15Live  = is15  ? locMacdLive : s15MLive
m60Live  = is60  ? locMacdLive : s60MLive
m240Live = is240 ? locMacdLive : s240MLive
mDLive   = isD   ? locMacdLive : sDMLive
mWLive   = isW   ? locMacdLive : sWMLive

m15C  = is15  ? locMacdConf : s15MConf
m60C  = is60  ? locMacdConf : s60MConf
m240C = is240 ? locMacdConf : s240MConf
mDC   = isD   ? locMacdConf : sDMConf
mWC   = isW   ? locMacdConf : sWMConf

// CONFIRMED sums -> used by signals / grading / alerts (non-repainting)
mtfSum = t15 + t60 + t240 + tD + tW          // -5 (all down) .. +5 (all up)

// DISPLAYED values -> what the dashboard shows
d15  = htfLiveTable ? t15Live  : t15
d60  = htfLiveTable ? t60Live  : t60
d240 = htfLiveTable ? t240Live : t240
dD   = htfLiveTable ? tDLive   : tD
dW   = htfLiveTable ? tWLive   : tW
mtfSumView = d15 + d60 + d240 + dD + dW

dm15  = htfLiveTable ? m15Live  : m15C
dm60  = htfLiveTable ? m60Live  : m60C
dm240 = htfLiveTable ? m240Live : m240C
dmD   = htfLiveTable ? mDLive   : mDC
dmW   = htfLiveTable ? mWLive   : mWC
macdSumView = dm15 + dm60 + dm240 + dmD + dmW

agreeWith(int d) =>
    (t15 == d ? 1 : 0) + (t60 == d ? 1 : 0) + (t240 == d ? 1 : 0) + (tD == d ? 1 : 0) + (tW == d ? 1 : 0)

// ════════════ COOLDOWN ════════════
var int lastSigBar = na
cooldownOK = na(lastSigBar) or (bar_index - lastSigBar) >= cd

// ════════════ RAW CROSSES + FILTERED SIGNALS ════════════
rawUp = ta.crossover(macd, signal)
rawDn = ta.crossunder(macd, signal)

showUp   = rawUp and regimeOK and htfBull and diBull and cooldownOK and (not zeroFiltInput or macd < 0)
showDown = rawDn and regimeOK and htfBear and diBear and cooldownOK and (not zeroFiltInput or macd > 0)
if showUp or showDown
    lastSigBar := bar_index

// ════════════ SCORE INPUTS ════════════
rawRoc = ta.roc(close, rocLength)
momo   = ta.ema(rawRoc, smoothLen)
avgVol = ta.sma(volume, volLength)
rvol   = na(avgVol) or avgVol == 0 ? 1.0 : volume / avgVol
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
atr     = ta.atr(14)

macdSlope = macd - macd[3]
histAcc   = hist - hist[1]
trendRaw  = atr == 0 ? 0.0 : (close - emaFast) / atr + (emaFast - emaSlow) / atr

zSlope = z(macdSlope, zLook)
zHist  = z(histAcc,  zLook)
zMomo  = z(momo,     zLook)
zTrend = z(trendRaw, zLook)
zVol   = z(rvol - 1.0, zLook)
zSat   = z(macd, zLook)

biasScore = zSlope + zHist + zMomo + 0.5 * zTrend
float dir = showUp ? 1.0 : showDown ? -1.0 : (biasScore >= 0 ? 1.0 : -1.0)

sMomo  = logistic(zMomo  * dir)
sSlope = logistic(zSlope * dir)
sHist  = logistic(zHist  * dir)
sTrend = logistic(zTrend * dir)
sVol   = logistic(zVol)
sFresh = logistic(-(zSat * dir))        // high when early, low when extended

totW = wMomentum + wSlope + wAccel + wVolume + wTrend + wFresh
strength = totW == 0 ? 0.0 :
     (sMomo * wMomentum + sSlope * wSlope + sHist * wAccel +
      sVol * wVolume + sTrend * wTrend + sFresh * wFresh) / totW

// ════════════════════════════════════════════════════════════════
//  CIRCLE GRADING  (zero-line colours + strong/weak)
// ════════════════════════════════════════════════════════════════
rawDir = rawUp ? 1 : rawDn ? -1 : 0
freshRaw = (rawUp and macd < 0) or (rawDn and macd > 0)
mtfAgreeRaw = rawDir == 0 ? 0 : agreeWith(rawDir)
strongCircle = (rawUp or rawDn) and mtfAgreeRaw >= mtfMin and (not requireFresh or freshRaw) and (not requireRegimeStrong or regimeOK)

upCol = signal < 0 ? color.new(#26a69a, 0) : color.new(color.orange, 0)   // green if fresh, orange if late
dnCol = signal > 0 ? color.new(#ff5252, 0) : color.new(color.orange, 0)   // red   if fresh, orange if late

drawUp = rawUp and (not hideWeak or strongCircle)
drawDn = rawDn and (not hideWeak or strongCircle)

plotshape(drawUp ? signal : na, "Bullish circle", shape.circle, location.absolute, upCol, size = size.small)
plotshape(drawDn ? signal : na, "Bearish circle", shape.circle, location.absolute, dnCol, size = size.small)

// ───── EXTREME / EXHAUSTION crosses (far from zero line) ─────
crossDist  = math.abs(zSat)
extremeUp  = detectExtreme and rawUp and zSat <= -extremeZ
extremeDn  = detectExtreme and rawDn and zSat >=  extremeZ
extremeX   = extremeUp or extremeDn

plotshape(showStar and strongCircle and not extremeX ? signal : na, "Strong signal",
     shape.diamond, location.absolute,
     rawUp ? color.new(#00e676, 0) : color.new(#ff1744, 0), size = size.tiny)

plotshape(extremeUp ? signal : na, "Extreme bottom cross", shape.flag, location.absolute, color.new(#00e676, 0), size = size.small)
plotshape(extremeDn ? signal : na, "Extreme top cross",    shape.flag, location.absolute, color.new(#ff1744, 0), size = size.small)
if extremeUp
    label.new(bar_index, signal, "⚑ EXT " + str.tostring(crossDist, "0.0") + "σ",
         color = na, textcolor = #00e676, style = label.style_label_up, size = size.tiny)
if extremeDn
    label.new(bar_index, signal, "⚑ EXT " + str.tostring(crossDist, "0.0") + "σ",
         color = na, textcolor = #ff1744, style = label.style_label_down, size = size.tiny)

// ════════════════════════════════════════════════════════════════
//  MACD DIVERGENCE  (regular + hidden, pivot-based on the MACD line)
// ════════════════════════════════════════════════════════════════
plRaw   = ta.pivotlow(macd, divLbL, divLbR)
phRaw   = ta.pivothigh(macd, divLbL, divLbR)
plFound = useDiv and not na(plRaw)
phFound = useDiv and not na(phRaw)

oscLcur  = macd[divLbR]
oscLprev = ta.valuewhen(plFound, macd[divLbR], 1)
lowCur   = low[divLbR]
lowPrev  = ta.valuewhen(plFound, low[divLbR], 1)
bullDiv  = plFound and oscLcur > oscLprev and lowCur < lowPrev

oscHcur  = macd[divLbR]
oscHprev = ta.valuewhen(phFound, macd[divLbR], 1)
highCur  = high[divLbR]
highPrev = ta.valuewhen(phFound, high[divLbR], 1)
bearDiv  = phFound and oscHcur < oscHprev and highCur > highPrev

var int lastBullDiv = na
var int lastBearDiv = na
if bullDiv
    lastBullDiv := bar_index
if bearDiv
    lastBearDiv := bar_index
bullDivActive = not na(lastBullDiv) and (bar_index - lastBullDiv) <= divValid
bearDivActive = not na(lastBearDiv) and (bar_index - lastBearDiv) <= divValid

plotshape(bullDiv ? macd[divLbR] : na, "Bull divergence", shape.triangleup,   location.absolute, color.new(#00e676, 0), size = size.tiny, offset = -divLbR, text = "R", textcolor = color.new(#00e676, 0))
plotshape(bearDiv ? macd[divLbR] : na, "Bear divergence", shape.triangledown, location.absolute, color.new(#ff1744, 0), size = size.tiny, offset = -divLbR, text = "R", textcolor = color.new(#ff1744, 0))

// ── Connecting line between the two pivot points (visualizes the divergence directly) ──
curPivotBar   = bar_index - divLbR
prevPivotBarL = ta.valuewhen(plFound, bar_index - divLbR, 1)
prevPivotBarH = ta.valuewhen(phFound, bar_index - divLbR, 1)

if bullDiv and not na(prevPivotBarL)
    line.new(int(prevPivotBarL), oscLprev, int(curPivotBar), oscLcur,
         color = color.new(#00e676, 0), style = line.style_solid, width = 2)
if bearDiv and not na(prevPivotBarH)
    line.new(int(prevPivotBarH), oscHprev, int(curPivotBar), oscHcur,
         color = color.new(#ff1744, 0), style = line.style_solid, width = 2)

// ───── Hidden divergence (trend-continuation signal) ─────
// Hidden bullish: price prints a HIGHER low while MACD prints a LOWER low
//                 -> pullback within an uptrend, trend likely continues up.
// Hidden bearish: price prints a LOWER high while MACD prints a HIGHER high
//                 -> pullback within a downtrend, trend likely continues down.
hiddenBullDiv = useHiddenDiv and plFound and oscLcur < oscLprev and lowCur > lowPrev
hiddenBearDiv = useHiddenDiv and phFound and oscHcur > oscHprev and highCur < highPrev

var int lastHiddenBullDiv = na
var int lastHiddenBearDiv = na
if hiddenBullDiv
    lastHiddenBullDiv := bar_index
if hiddenBearDiv
    lastHiddenBearDiv := bar_index
hiddenBullDivActive = not na(lastHiddenBullDiv) and (bar_index - lastHiddenBullDiv) <= divValid
hiddenBearDivActive = not na(lastHiddenBearDiv) and (bar_index - lastHiddenBearDiv) <= divValid

plotshape(hiddenBullDiv ? macd[divLbR] : na, "Hidden bull divergence", shape.triangleup,   location.absolute, color.new(#00e676, 55), size = size.tiny, offset = -divLbR, text = "H", textcolor = color.new(#00e676, 0))
plotshape(hiddenBearDiv ? macd[divLbR] : na, "Hidden bear divergence", shape.triangledown, location.absolute, color.new(#ff1744, 55), size = size.tiny, offset = -divLbR, text = "H", textcolor = color.new(#ff1744, 0))

// Connecting line for hidden divergence too — dashed + more transparent
// so it reads as "continuation" rather than the solid regular-divergence line.
if hiddenBullDiv and not na(prevPivotBarL)
    line.new(int(prevPivotBarL), oscLprev, int(curPivotBar), oscLcur,
         color = color.new(#00e676, 55), style = line.style_dashed, width = 1)
if hiddenBearDiv and not na(prevPivotBarH)
    line.new(int(prevPivotBarH), oscHprev, int(curPivotBar), oscHcur,
         color = color.new(#ff1744, 55), style = line.style_dashed, width = 1)

confirmedBottom = extremeUp and bullDivActive
confirmedTop    = extremeDn and bearDivActive
if confirmedBottom
    label.new(bar_index, signal, "✓ REV", color = color.new(#00e676, 20), textcolor = color.white, style = label.style_label_up, size = size.small)
if confirmedTop
    label.new(bar_index, signal, "✓ REV", color = color.new(#ff1744, 20), textcolor = color.white, style = label.style_label_down, size = size.small)

if strongCircle and rawUp
    label.new(bar_index, signal, "▲ " + str.tostring(strength, "#0") + "% | " + str.tostring(mtfAgreeRaw) + "/5",
         color = na, textcolor = #26a69a, style = label.style_label_up, size = size.tiny)
if strongCircle and rawDn
    label.new(bar_index, signal, "▼ " + str.tostring(strength, "#0") + "% | " + str.tostring(mtfAgreeRaw) + "/5",
         color = na, textcolor = #ff5252, style = label.style_label_down, size = size.tiny)

// ════════════════════════════════════════════════════════════════
//  RECOMMENDATION ENGINE — one plain-language action line.
//  Priority (highest wins):
//    ✓ REVERSAL  >  ⚑ EXHAUSTION  >  fresh ENTER (strong/weak)
//    >  EXIT (momentum fade)  >  CHOPPY no-trade  >  CONTINUATION  >  WAIT
// ════════════════════════════════════════════════════════════════
recWindow = input.int(3, "Recommendation: bars a signal stays actionable", minval=1, maxval=10, group="Recommendation")

var int   lastCircBar  = na
var int   lastCircDir  = 0
var bool  lastCircStrg = false
var float lastCircPct  = na
if rawUp or rawDn
    lastCircBar  := bar_index
    lastCircDir  := rawUp ? 1 : -1
    lastCircStrg := strongCircle
    lastCircPct  := strength

var int lastRevBar = na
var int lastRevDir = 0
if confirmedBottom or confirmedTop
    lastRevBar := bar_index
    lastRevDir := confirmedBottom ? 1 : -1

var int lastExtBar = na
var int lastExtDir = 0
if extremeX
    lastExtBar := bar_index
    lastExtDir := extremeUp ? 1 : -1

var int fadeRun = 0
fadeRun := (hist - hist[1]) * dir < 0 ? fadeRun + 1 : 0

circAge = na(lastCircBar) ? 99999 : bar_index - lastCircBar
revAge  = na(lastRevBar)  ? 99999 : bar_index - lastRevBar
extAge  = na(lastExtBar)  ? 99999 : bar_index - lastExtBar

chop        = adxVal < adxThr
alignDir    = mtfSumView > 0 ? 1 : mtfSumView < 0 ? -1 : 0
bothAligned = math.abs(mtfSumView) >= mtfMin and math.abs(macdSumView) >= mtfMin and alignDir != 0 and (macdSumView > 0 ? 1 : -1) == alignDir

string recTxt = "WAIT — no edge"
color  recBg  = color.new(color.gray, 45)

// 6. continuation (trend stack intact, no fresh signal)
if bothAligned and not chop
    recTxt := "CONT " + (alignDir > 0 ? "▲ hold LONG" : "▼ hold SHORT")
    recBg  := color.new(alignDir > 0 ? color.teal : color.maroon, 20)

// 5. chop filter
if chop
    recTxt := "CHOP — NO TRADE (" + str.tostring(adxVal, "#0") + "<" + str.tostring(adxThr, "#0") + ")"
    recBg  := color.new(color.gray, 10)

// 4. exit — histogram momentum fading against current bias
if fadeRun >= fadeBars
    recTxt := "EXIT/TIGHTEN — fade " + str.tostring(fadeRun)
    recBg  := color.new(color.orange, 15)

// 3. fresh circle inside the entry window
if circAge <= recWindow
    dirTxt = lastCircDir > 0 ? "LONG ▲" : "SHORT ▼"
    pctTxt = str.tostring(lastCircPct, "#0") + "%"
    if lastCircStrg and not chop
        recTxt := "ENTER " + dirTxt + " STRONG " + pctTxt
        recBg  := color.new(lastCircDir > 0 ? color.green : color.red, 5)
    else if lastCircStrg and chop
        recTxt := "STRONG " + dirTxt + " +CHOP ⚠ " + pctTxt
        recBg  := color.new(color.orange, 20)
    else if not chop
        recTxt := dirTxt + " WEAK " + pctTxt + " small"
        recBg  := color.new(lastCircDir > 0 ? color.green : color.red, 55)
    else
        recTxt := "WEAK+CHOP — NO TRADE"
        recBg  := color.new(color.gray, 10)

// 2. exhaustion flag (no divergence confirmation yet)
if extAge <= recWindow and revAge > recWindow
    recTxt := "⚑ EXH " + (lastExtDir > 0 ? "▲ bottom?" : "▼ top?") + " — TP"
    recBg  := color.new(color.fuchsia, 25)

// 1. confirmed reversal (extreme cross + divergence)
if revAge <= recWindow
    recTxt := "✓ REV — " + (lastRevDir > 0 ? "LONG ▲ " : "SHORT ▼ ") + str.tostring(strength, "#0") + "%"
    recBg  := color.new(lastRevDir > 0 ? color.green : color.red, 0)

bgcolor(color.new(dir > 0 ? color.green : color.red, math.max(80, 100 - strength / 5)))

// ════════════════════════════════════════════════════════════════
//  TRADEABLE BACKTEST — ATR bracket, intrabar high/low fills
//  Target/stop and MFE/MAE use HIGH/LOW, stop checked FIRST
//  (pessimistic when both hit in one bar) -> realistic stats.
// ════════════════════════════════════════════════════════════════
sigDir       = showUp ? 1 : showDown ? -1 : 0
freshSig     = (showUp and macd < 0) or (showDown and macd > 0)
filteredStrong = (showUp or showDown) and (sigDir == 0 ? false : agreeWith(sigDir) >= mtfMin) and (not requireFresh or freshSig) and (not requireRegimeStrong or regimeOK)

newSig = showUp or showDown

var bool  inTrade  = false
var bool  resolved = false
var float tEntry = na
var float tDir   = na
var float tATR   = na
var bool  tStrong = false
var float tMFE   = na
var float tMAE   = na

var int   nS = 0
var int   wS = 0
var float mfeS = 0.0
var float maeS = 0.0
var int   nW = 0
var int   wW = 0
var float mfeW = 0.0
var float maeW = 0.0
var int   fadeCount = 0

favNow = inTrade ? (close - tEntry) * tDir : na            // close-based (fade exit)
favMax = inTrade ? (tDir > 0 ? high - tEntry : tEntry - low)  : na  // best intrabar excursion
favMin = inTrade ? (tDir > 0 ? low  - tEntry : tEntry - high) : na  // worst intrabar excursion
if inTrade
    tMFE := math.max(tMFE, favMax)
    tMAE := math.min(tMAE, favMin)
    favMom = (hist - hist[1]) * tDir
    fadeCount := favMom < 0 ? fadeCount + 1 : 0

bool  doRecord = false
bool  recWin   = false
bool  fadeExit = false
if inTrade and not resolved
    if favMin <= -lossR * tATR          // stop first = pessimistic
        doRecord := true
        recWin   := false
        resolved := true
    else if favMax >= winR * tATR
        doRecord := true
        recWin   := true
        resolved := true
if useHistExit and inTrade and not resolved and fadeCount >= fadeBars
    doRecord := true
    recWin   := favNow > 0
    resolved := true
    fadeExit := true
if newSig and inTrade and not resolved
    doRecord := true
    recWin   := favNow > 0
    resolved := true

if doRecord
    rMFE = tATR > 0 ? tMFE / tATR : 0.0
    rMAE = tATR > 0 ? tMAE / tATR : 0.0
    if tStrong
        nS   += 1
        wS   += recWin ? 1 : 0
        mfeS += rMFE
        maeS += rMAE
    else
        nW   += 1
        wW   += recWin ? 1 : 0
        mfeW += rMFE
        maeW += rMAE

if newSig
    inTrade  := true
    resolved := false
    tEntry   := close
    tDir     := showUp ? 1.0 : -1.0
    tATR     := atr
    tStrong  := filteredStrong
    tMFE     := 0.0
    tMAE     := 0.0
    fadeCount := 0

plotshape(showFade and fadeExit ? 0 : na, "Hist-fade exit", shape.xcross, location.absolute, color.new(color.yellow, 0), size = size.tiny, text = "exit")

wrS   = nS > 0 ? wS * 1.0 / nS : na
wrW   = nW > 0 ? wW * 1.0 / nW : na
winSp = na(wrS) ? na : wrS * 100.0
winWp = na(wrW) ? na : wrW * 100.0
expS  = na(wrS) ? na : wrS * winR - (1.0 - wrS) * lossR
expW  = na(wrW) ? na : wrW * winR - (1.0 - wrW) * lossR
mfeSa = nS > 0 ? mfeS / nS : na
maeSa = nS > 0 ? maeS / nS : na

// ════════════ DIAGNOSTICS TABLE ════════════
var table diag = table.new(position.top_right, 2, 28, border_width = 1)
tSize = dashTiny ? size.tiny : size.small

f_row(int r, string lbl, string val, color bg) =>
    table.cell(diag, 0, r, lbl, text_color = color.white, bgcolor = color.new(color.gray, 50), text_size = tSize)
    table.cell(diag, 1, r, val, text_color = color.white, bgcolor = bg, text_size = tSize)

f_comp(int r, string lbl, float v) =>
    f_row(r, lbl, str.tostring(v, "#0") + "%", v > 50 ? color.new(color.green, 35) : color.new(color.red, 35))

// Each TF row shows Trend + MACD direction on that TF,
//       orange when the trend is flipping intrabar, ● = chart TF
f_tf(int r, string lbl, int dShow, int dConf, int mShow, bool isChartTF) =>
    flip = dShow != dConf
    txt  = (dShow > 0 ? "▲ UP" : "▼ DN") + (flip ? "•" : "") + "|M" + (mShow > 0 ? "▲" : "▼")
    bg   = flip ? color.new(color.orange, 25) : dShow > 0 ? color.new(color.green, 25) : color.new(color.red, 25)
    table.cell(diag, 0, r, lbl + (isChartTF ? " ●" : ""), text_color = color.white,
         bgcolor = color.new(color.gray, isChartTF ? 20 : 50), text_size = tSize)
    table.cell(diag, 1, r, txt, text_color = color.white, bgcolor = bg, text_size = tSize)

methodShort = trendMethod == "EMA 50/200" ? "EMA50/200" : trendMethod == "Price vs EMA50" ? "P>EMA50" : "MACD"

if barstate.islast
    table.cell(diag, 0, 0, "Component", text_color = color.white, bgcolor = color.new(color.gray, 20), text_size = tSize)
    table.cell(diag, 1, 0, "Score",     text_color = color.white, bgcolor = color.new(color.gray, 20), text_size = tSize)
    f_comp(1, "Momentum",   sMomo)
    f_comp(2, "MACD Slope", sSlope)
    f_comp(3, "Hist Accel", sHist)
    f_comp(4, "Volume",     sVol)
    f_comp(5, "Trend",      sTrend)
    f_comp(6, "Freshness",  sFresh)

    sColor = strength > 70 ? color.new(color.green, 0) : strength > 40 ? color.new(color.orange, 0) : color.new(color.red, 0)
    table.cell(diag, 0, 7, "OVERALL", text_color = color.white, bgcolor = color.new(color.blue, 20), text_size = tSize)
    table.cell(diag, 1, 7, str.tostring(strength, "#0") + "%", text_color = color.white, bgcolor = sColor, text_halign = text.align_center, text_size = tSize)

    table.cell(diag, 0, 8, "Predicted", text_color = color.white, bgcolor = color.new(color.blue, 20), text_size = tSize)
    table.cell(diag, 1, 8, (dir > 0 ? "▲ LONG" : "▼ SHORT") + " (" + (fastSlope >= 0 ? "rise" : "fall") + ")",
         text_color = color.white, bgcolor = dir > 0 ? color.new(color.green, 20) : color.new(color.red, 20), text_halign = text.align_center, text_size = tSize)

    // ── ACTION recommendation ──
    table.cell(diag, 0, 9, "ACTION", text_color = color.white, bgcolor = color.new(color.blue, 0), text_size = tSize)
    table.cell(diag, 1, 9, recTxt, text_color = color.white, bgcolor = recBg, text_halign = text.align_center, text_size = tSize)

    // ── Multi-timeframe trend block:  Trend | MACD per TF ──
    table.cell(diag, 0, 10, "TREND BY TF", text_color = color.white, bgcolor = color.new(color.gray, 20), text_size = tSize)
    table.cell(diag, 1, 10, methodShort + "|M" + (htfLiveTable ? " live" : " closed"), text_color = color.white, bgcolor = color.new(color.gray, 20), text_size = tSize)
    f_tf(11, "15m", d15,  t15,  dm15,  is15)
    f_tf(12, "1h",  d60,  t60,  dm60,  is60)
    f_tf(13, "4h",  d240, t240, dm240, is240)
    f_tf(14, "1D",  dD,   tD,   dmD,   isD)
    f_tf(15, "1W",  dW,   tW,   dmW,   isW)
    f_row(16, "TF Align", str.tostring(math.abs(mtfSumView)) + "/5 " + (mtfSumView > 0 ? "▲" : mtfSumView < 0 ? "▼" : "—"),
         math.abs(mtfSumView) >= mtfMin ? color.new(color.green, 25) : color.new(color.orange, 35))
    f_row(17, "MACD Align", str.tostring(math.abs(macdSumView)) + "/5 " + (macdSumView > 0 ? "▲" : macdSumView < 0 ? "▼" : "—"),
         math.abs(macdSumView) >= mtfMin ? color.new(color.green, 25) : color.new(color.orange, 35))

    // ── MACD trend direction on the chart TF (line vs signal + slope) ──
    // uses fastSlope so the row always matches the trend-line colour
    macdBull = macd > signal
    lrUp     = fastSlope >= 0
    f_row(18, "MACD Trend",
         (macdBull ? "▲ BULL" : "▼ BEAR") + "|" + (lrUp ? "▲ rise" : "▼ fall"),
         macdBull and lrUp ? color.new(color.green, 25) : not macdBull and not lrUp ? color.new(color.red, 25) : color.new(color.orange, 25))

    f_row(19, "Regime",
         "ADX " + str.tostring(adxVal, "#0") + (adxVal >= adxThr ? "✓" : "✗") + "|HTF" + (htfFast > htfSlow ? "▲" : "▼"),
         adxVal >= adxThr ? color.new(color.green, 35) : color.new(color.red, 35))

    // ── Backtest block ──
    table.cell(diag, 0, 20, "BACKTEST", text_color = color.white, bgcolor = color.new(color.gray, 20), text_size = tSize)
    table.cell(diag, 1, 20, "win%|expR", text_color = color.white, bgcolor = color.new(color.gray, 20), text_size = tSize)

    f_row(21, "Strong (n=" + str.tostring(nS) + ")",
         (na(winSp) ? "-" : str.tostring(winSp, "#0") + "%") + "|" + (na(expS) ? "-" : str.tostring(expS, "0.00") + "R"),
         na(expS) ? color.new(color.gray, 50) : expS > 0 ? color.new(color.green, 25) : color.new(color.red, 25))

    f_row(22, "Weak (n=" + str.tostring(nW) + ")",
         (na(winWp) ? "-" : str.tostring(winWp, "#0") + "%") + "|" + (na(expW) ? "-" : str.tostring(expW, "0.00") + "R"),
         na(expW) ? color.new(color.gray, 50) : expW > 0 ? color.new(color.green, 25) : color.new(color.red, 25))

    f_row(23, "MFE/MAE",
         (na(mfeSa) ? "-" : str.tostring(mfeSa, "0.0") + "R") + "/" + (na(maeSa) ? "-" : str.tostring(maeSa, "0.0") + "R"),
         color.new(color.gray, 50))

    f_row(24, "Raw RVOL", str.tostring(rvol, "#.##") + "x", color.new(color.gray, 50))

    f_row(25, "Dist from 0",
         str.tostring(crossDist, "0.0") + "σ" + (crossDist >= extremeZ ? " ⚑ EXTREME" : ""),
         crossDist >= extremeZ ? color.new(color.fuchsia, 20) : color.new(color.gray, 50))

    divTxt = bullDivActive ? "▲ BULL" : bearDivActive ? "▼ BEAR" : "none"
    f_row(26, "Divergence", divTxt,
         bullDivActive ? color.new(color.green, 25) : bearDivActive ? color.new(color.red, 25) : color.new(color.gray, 50))

    hiddenDivTxt = hiddenBullDivActive ? "▲ BULL" : hiddenBearDivActive ? "▼ BEAR" : "none"
    f_row(27, "Hidden Div", hiddenDivTxt,
         hiddenBullDivActive ? color.new(color.green, 25) : hiddenBearDivActive ? color.new(color.red, 25) : color.new(color.gray, 50))

// ════════════════════════════════════════════════════════════════
//  ALERTS (all based on CONFIRMED trends -> non-repainting)
// ════════════════════════════════════════════════════════════════
greenCircle = drawUp and signal < 0      // bullish cross below zero  -> green
redCircle   = drawDn and signal > 0      // bearish cross above zero  -> red
anyCircle   = drawUp or drawDn           // any circle (incl. orange late signals)

alertcondition(greenCircle, "Green circle (fresh long)",
     "{{ticker}} {{interval}} GREEN circle — fresh long (MACD bullish cross below zero)")
alertcondition(redCircle,   "Red circle (fresh short)",
     "{{ticker}} {{interval}} RED circle — fresh short (MACD bearish cross above zero)")
alertcondition(anyCircle,   "Combined circle (any)",
     "{{ticker}} {{interval}} MACD circle — bullish or bearish cross (green / red / orange)")

// ── Same three, but ONLY when all timeframes agree (1W EXCLUDED) ──
mtfSum4 = t15 + t60 + t240 + tD                     // 15m/1h/4h/1D only (no 1W)
greenCircleAllTF = greenCircle and mtfSum4 ==  4    // green + every TF up
redCircleAllTF   = redCircle   and mtfSum4 == -4    // red   + every TF down
anyCircleAllTF   = (drawUp and mtfSum4 == 4) or (drawDn and mtfSum4 == -4)

alertcondition(greenCircleAllTF, "Green circle — ALL TF aligned",
     "{{ticker}} {{interval}} GREEN circle — fresh long, ALL TF aligned UP (15m/1h/4h/1D)")
alertcondition(redCircleAllTF,   "Red circle — ALL TF aligned",
     "{{ticker}} {{interval}} RED circle — fresh short, ALL TF aligned DOWN (15m/1h/4h/1D)")
alertcondition(anyCircleAllTF,   "Combined circle — ALL TF aligned",
     "{{ticker}} {{interval}} MACD circle with ALL TF aligned (15m/1h/4h/1D)")

// ── MACD trend alignment: 15m + 1h + 4h + 1D all pointing the same way ──
// Uses CONFIRMED (closed-bar) MACD direction -> non-repainting.
// Fires on the TRANSITION into alignment (not every bar while aligned).
macdSum4     = m15C + m60C + m240C + mDC        // -4 .. +4 (1W excluded)
macdAllBull  = macdSum4 ==  4
macdAllBear  = macdSum4 == -4
macdBullFire = macdAllBull and not macdAllBull[1]   // just became fully bullish
macdBearFire = macdAllBear and not macdAllBear[1]   // just became fully bearish

alertcondition(macdBullFire, "MACD aligned BULLISH — 15m/1h/4h/1D",
     "{{ticker}} {{interval}} MACD trend just aligned BULLISH on ALL TFs (15m/1h/4h/1D)")
alertcondition(macdBearFire, "MACD aligned BEARISH — 15m/1h/4h/1D",
     "{{ticker}} {{interval}} MACD trend just aligned BEARISH on ALL TFs (15m/1h/4h/1D)")
alertcondition(macdBullFire or macdBearFire, "MACD aligned — combined (bull or bear)",
     "{{ticker}} {{interval}} MACD trend just aligned on ALL TFs (15m/1h/4h/1D) — check dashboard for direction")

// ── MACD divergence alerts (regular + hidden) ──
alertcondition(bullDiv, "Bullish divergence (regular)",
     "{{ticker}} {{interval}} Regular bullish MACD divergence detected (price lower low, MACD higher low) — possible reversal up")
alertcondition(bearDiv, "Bearish divergence (regular)",
     "{{ticker}} {{interval}} Regular bearish MACD divergence detected (price higher high, MACD lower high) — possible reversal down")
alertcondition(hiddenBullDiv, "Bullish divergence (hidden)",
     "{{ticker}} {{interval}} Hidden bullish MACD divergence detected (price higher low, MACD lower low) — likely uptrend continuation")
alertcondition(hiddenBearDiv, "Bearish divergence (hidden)",
     "{{ticker}} {{interval}} Hidden bearish MACD divergence detected (price lower high, MACD higher high) — likely downtrend continuation")
alertcondition(bullDiv or hiddenBullDiv, "Any bullish divergence",
     "{{ticker}} {{interval}} Bullish MACD divergence detected (regular or hidden)")
alertcondition(bearDiv or hiddenBearDiv, "Any bearish divergence",
     "{{ticker}} {{interval}} Bearish MACD divergence detected (regular or hidden)")
alertcondition(confirmedBottom, "Confirmed reversal — bottom",
     "{{ticker}} {{interval}} ✓ REV bottom — extreme oversold cross confirmed by regular bullish divergence")
alertcondition(confirmedTop, "Confirmed reversal — top",
     "{{ticker}} {{interval}} ✓ REV top — extreme overbought cross confirmed by regular bearish divergence")
````
