# PCRXS Forecast Engine Oscillator and Forecast

- url: https://www.tradingview.com/script/ezyGSIUz-PCRXS-Forecast-Engine-Oscillator-and-Forecast/
- type: indicator
- pine_id: PUB;f715792ff3904b218a632d1e89bb6bcd
- version: 3.0

## Description

A lower-panel companion indicator that runs below your price chart. While the main overlay shows signals on the candles, this oscillator shows you the momentum engine underneath — and where it's heading next.

What you see:
🟠 Orange line — the main oscillator (WMA-based momentum)
🔴 Red line — smoothed signal line
Dashed bands — σ1, σ2, σ3 standard deviation zones (the wider the band, the stronger the move)
Dashed forecast lines extend to the right showing the predicted oscillator path forward, with:

▲ ▼ labels at predicted peaks and troughs with dates
↑ ↓ labels where the oscillator is forecast to cross zero — these are your anticipated entry zones


Signals:

🟢 Green triangle = Long entry
🔴 Red triangle = Short entry
🟠 × Orange = Exit long
🔵 × Blue = Exit short
⚡ Flash = Urgent high-confidence entry

The background glows the same colors as the price chart so both panels always tell the same story at a glance.
Mini panel shows: current action, confidence %, oscillator vs σ1, cycle period, forecast direction, all filter states, BTC halving phase, and live dominance readings (BTC.D, USDT.D, CME basis).

## Source Code

````pine
// ╔══════════════════════════════════════════════════════════════════╗
// ║   ⚡ PCRXS Forecast Engine — Oscillator + Forecast Panel                 ║
// ║   Companion to PCRXS Forecast Engine v1.0 (overlay)                     ║
// ╠══════════════════════════════════════════════════════════════════╣
// ║  Replicates and improves on the HSH_FM oscillator shown in the  ║
// ║  ELCARO reference chart. Add this as a LOWER PANEL below price.  ║
// ╠══════════════════════════════════════════════════════════════════╣
// ║  WHAT YOU SEE:                                                   ║
// ║    🟠 Orange line     — Main WMA oscillator                      ║
// ║    🔴 Red line        — Smoothed signal line                     ║
// ║    ── Dashed bands    — σ1, σ2, σ3 standard deviation zones      ║
// ║    ⚡ Forecast dashes  — Projected oscillator path forward        ║
// ║    🟢 Green shape     — Long entry signal                        ║
// ║    🔴 Red shape       — Short entry signal                       ║
// ║    🟠 × Orange        — Exit long                                ║
// ║    🔵 × Blue          — Exit short                               ║
// ╠══════════════════════════════════════════════════════════════════╣
// ║  FORECAST MODEL:                                                 ║
// ║    • Detects dominant oscillator cycle via swing-point analysis  ║
// ║    • Projects sinusoidal oscillator wave forward N bars          ║
// ║    • Confidence bands widen with forecast distance               ║
// ║    • Direction matches the overlay ORACLE signal                 ║
// ╠══════════════════════════════════════════════════════════════════╣
// ║  ⚠️  DISCLAIMER: Educational only. Not financial advice.         ║
// ╚══════════════════════════════════════════════════════════════════╝

//@version=5
indicator("⚡ PCRXS Forecast Engine — Oscillator + Forecast",
     shorttitle        = "⚡ PCRXS OSC",
     overlay           = false,
     max_bars_back     = 5000,
     max_lines_count   = 500,
     max_labels_count  = 500)

// ═══════════════════════════════════════════════════════════════════
// ── INPUTS (Mirror ORACLE v1 settings exactly for consistent signals)
// ═══════════════════════════════════════════════════════════════════
g1 = "── Oscillator ──"
rsiLen    = input.int(14,    "RSI Length",        group=g1)
rsiOB     = input.float(70,  "RSI Overbought",    group=g1)
rsiOS     = input.float(30,  "RSI Oversold",      group=g1)
filterLen = input.int(20,    "WMA Filter Length", group=g1)
smoothLen = input.int(3,     "Signal Smooth",     group=g1)
stdPer    = input.int(100,   "Std Dev Period",    group=g1)
mtfTF     = input.timeframe("240", "Bias Timeframe", group=g1)

g2 = "── Forecast ──"
forecastBars = input.int(60,    "Bars Ahead",       minval=10, maxval=150, group=g2)
showForecast = input.bool(true, "Show Oscillator Forecast (dashed)", group=g2)
showConfBand = input.bool(true, "Show Forecast Bands", group=g2)

g3 = "── Display ──"
showTable   = input.bool(true,  "Show Mini Panel",     group=g3)
showShapes  = input.bool(true,  "Show Signal Markers", group=g3)
tPos        = input.string("top_right", "Panel Position", options=["top_right","top_left","bottom_right","bottom_left"], group=g3)
urgConfMin  = input.int(62,     "Urgent Confidence Threshold", group=g3)

// ═══════════════════════════════════════════════════════════════════
// ── DATA REQUESTS
// ═══════════════════════════════════════════════════════════════════
h4Close  = request.security(syminfo.tickerid, mtfTF, close,
           barmerge.gaps_off, barmerge.lookahead_off)
h4Ema50  = request.security(syminfo.tickerid, mtfTF, ta.ema(close, 50),
           barmerge.gaps_off, barmerge.lookahead_off)
h4Ema200 = request.security(syminfo.tickerid, mtfTF, ta.ema(close, 200),
           barmerge.gaps_off, barmerge.lookahead_off)

dxy  = request.security("TVC:DXY",  timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
spx  = request.security("SP:SPX",   timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)

// Dominance & Futures (same 3 leading indicators as ORACLE v1 overlay)
btcDom  = request.security("CRYPTOCAP:BTC.D",  timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
usdtDom = request.security("CRYPTOCAP:USDT.D", timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
btcFut  = request.security("CME:BTC1!",         timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)

// ═══════════════════════════════════════════════════════════════════
// ── TECHNICAL INDICATORS
// ═══════════════════════════════════════════════════════════════════
h4Bull    = h4Close > h4Ema50 and h4Ema50 > h4Ema200
h4Bear    = h4Close < h4Ema50 and h4Ema50 < h4Ema200

rsi       = ta.rsi(close, rsiLen)
atr       = ta.atr(14)
atrAvg    = ta.sma(atr, 42)
volAvg    = ta.sma(volume, 20)

macd      = ta.ema(close, 12) - ta.ema(close, 26)
macdSig   = ta.ema(macd, 9)
macdHist  = macd - macdSig
macdBull  = macdHist > 0 and macdHist > macdHist[1]
macdBear  = macdHist < 0 and macdHist < macdHist[1]

mfMult    = ((close - low) - (high - close)) / math.max(high - low, 1e-10)
cmf       = ta.sma(mfMult * volume, 20) / math.max(ta.sma(volume, 20), 1e-10)

[diP, diM, adx] = ta.dmi(14, 14)
trending  = adx > 22

dxyEma    = ta.ema(dxy, 20)
spxEma    = ta.ema(spx, 20)
dxyBull   = dxy > dxyEma
spxBull   = spx > spxEma

// BTC Dominance
btcDomEma20  = ta.ema(btcDom, 20)
btcDomRise   = btcDom > btcDomEma20
btcDomFall   = btcDom < btcDomEma20
btcDomMom    = btcDom > 0.001 ? (btcDom - btcDom[10]) / btcDom[10] * 100 : 0.0
altSeasonZone= btcDom < 54.0
symBase      = str.upper(syminfo.basecurrency)
isBTC        = symBase == "BTC"
btcDomBullish= isBTC ? btcDomRise : btcDomFall

// USDT Dominance
usdtDomEma20 = ta.ema(usdtDom, 20)
usdtDomRise  = usdtDom > usdtDomEma20
usdtDomFall  = usdtDom < usdtDomEma20
usdtMom      = usdtDom > 0.001 ? (usdtDom - usdtDom[5]) / usdtDom[5] * 100 : 0.0
usdtActFall  = usdtDom < usdtDom[3]
usdtActRise  = usdtDom > usdtDom[3]
usdtNearHigh = usdtDom > ta.highest(usdtDom, 50) * 0.85
dryPowder    = usdtNearHigh and usdtActFall
usdtBullish  = usdtDomFall
usdtBearish  = usdtDomRise

// CME Futures
btcFutValid  = not na(btcFut) and btcFut > 1.0
futBasis     = btcFutValid ? (btcFut - close) / close * 100 : 0.0
inContango   = futBasis > 0.10
inBackward   = futBasis < -0.10
overLevLong  = futBasis > 0.80
futBullish   = inContango and not overLevLong
futBearish   = inBackward or overLevLong

// BTC Halving cycle value (same formula as overlay)
halving4Ms     = int(1713571200000)
halvingPeriodMs= int(126230400000)
msSinceHalv    = math.max(timenow - halving4Ms, 0)
halvPhaseRad   = 2.0 * math.pi * float(msSinceHalv) / float(halvingPeriodMs)
halvCycleVal   = math.cos(halvPhaseRad - math.pi * 0.25)
halvMonths     = float(msSinceHalv) / 2592000000.0

// ═══════════════════════════════════════════════════════════════════
// ── CORE WMA OSCILLATOR
// ═══════════════════════════════════════════════════════════════════
wmaFn(src, len) =>
    num = 0.0
    den = 0.0
    for i = 0 to len - 1
        w    = float(len - i)
        num  += src[i] * w
        den  += w
    num / den

// ── CORE OSCILLATOR (Fast WMA minus Slow WMA — classic dual-MA momentum)
// fastLine = WMA(close, smoothLen=3)  tracks price closely
// slowLine = WMA(close, filterLen=20) lags significantly
// osc = fast - slow → meaningful waves at every timeframe
fastLine = wmaFn(close, smoothLen)
slowLine = wmaFn(close, filterLen)
rawOsc   = fastLine - slowLine

// ATR normalisation — scales to ±100-300 range on any asset/timeframe
atrVal   = ta.atr(14)
osc      = atrVal > 0 ? rawOsc / atrVal * 100 : rawOsc

oscStd   = ta.stdev(osc, stdPer)
s1       = oscStd * 1.0
s2       = oscStd * 2.0
s3       = oscStd * 3.0

// Normalised % of σ1 (for table display)
oscNorm  = oscStd > 0 ? osc / oscStd * 100 : 0

// ═══════════════════════════════════════════════════════════════════
// ── CYCLE DETECTION (swing points on PRICE, applied to OSC forecast)
// ═══════════════════════════════════════════════════════════════════
swingH = ta.pivothigh(high, 5, 5)
swingL = ta.pivotlow(low,   5, 5)

var int   ph1      = 0
var int   ph2      = 0
var int   ph3      = 0
var float domCycle = 20.0
var float phPrice  = close
var float plPrice  = close

if not na(swingH)
    ph3     := ph2
    ph2     := ph1
    ph1     := bar_index
    phPrice := swingH
if not na(swingL)
    plPrice := swingL

if ph3 > 0 and ph2 > 0 and ph1 > 0
    p1       = float(ph1 - ph2)
    p2       = float(ph2 - ph3)
    domCycle := (p1 + p2) * 0.5

domCycle := math.max(math.min(domCycle, 150), 5)

barsSincePH  = float(bar_index - ph1)
currentPhase = 2.0 * math.pi * barsSincePH / domCycle

// Oscillator amplitude — use recent oscillator std dev as amplitude proxy
oscAmp = ta.stdev(osc, int(math.max(domCycle, 5)))

// ═══════════════════════════════════════════════════════════════════
// ── SIGNALS (identical logic to ORACLE v1 overlay)
// ═══════════════════════════════════════════════════════════════════
longFilters  = h4Bull and rsi < rsiOB and macdHist >= macdHist[1] and cmf > -0.05 and volume > volAvg * 0.80 and halvCycleVal > -0.70
shortFilters = h4Bear and rsi > rsiOS and macdHist <= macdHist[1] and cmf < 0.05 and volume > volAvg * 0.80 and halvCycleVal < 0.70

longSig      = ta.crossover(osc,  -s1) and longFilters
shortSig     = ta.crossunder(osc,  s1) and shortFilters
exitLong     = ta.crossunder(osc, 0) or (rsi > rsiOB and ta.crossunder(rsi, rsiOB) and h4Bear)
exitShort    = ta.crossover(osc,  0) or (rsi < rsiOS and ta.crossover(rsi, rsiOS) and h4Bull)

// Confidence (now 10-factor mirror of overlay)
lrNow        = ta.linreg(close, 50, 0)
lrPrev       = ta.linreg(close, 50, 1)
trendBull    = lrNow > lrPrev
agreeLong    = (trendBull ? 1 : 0) + (h4Bull ? 1 : 0) + (spxBull ? 1 : 0) + (not dxyBull ? 1 : 0) + (macdBull ? 1 : 0) + (cmf > 0 ? 1 : 0) + (halvCycleVal > 0 ? 1 : 0) + (btcDomBullish ? 1 : 0) + (usdtBullish ? 1 : 0) + (futBullish ? 1 : 0)
agreeShort   = ((not trendBull) ? 1 : 0) + (h4Bear ? 1 : 0) + (dxyBull ? 1 : 0) + ((not spxBull) ? 1 : 0) + (macdBear ? 1 : 0) + (cmf < 0 ? 1 : 0) + (halvCycleVal < 0 ? 1 : 0) + ((not btcDomBullish) ? 1 : 0) + (usdtBearish ? 1 : 0) + (futBearish ? 1 : 0)
dirScore     = trendBull ? agreeLong : agreeShort
confBonus    = (trending ? 0.10 : 0.0) + (volume > volAvg * 1.3 ? 0.08 : 0.0) + (dryPowder ? 0.07 : 0.0)
confidence   = int(math.min(math.round((float(dirScore) / 10.0 + confBonus) * 100), 95))

urgentLong   = longSig  and confidence >= urgConfMin and trending and volume > volAvg * 1.4
urgentShort  = shortSig and confidence >= urgConfMin and trending and volume > volAvg * 1.4

// ═══════════════════════════════════════════════════════════════════
// ── OSCILLATOR FORECAST FUNCTION
// ═══════════════════════════════════════════════════════════════════
// Projects the oscillator forward as a sine wave based on:
//   1. Detected dominant cycle (from swing point analysis)
//   2. Current oscillator phase (where we are in the cycle)
//   3. BTC halving cycle modulation (long-term bias)
//   4. Macro nudge (DXY + SPX directional bias)
//
// Formula:
//   OSC_forecast(t) = A·sin(2π·t/T + φ) + halvMod + macroNudge(t)
//
// Where:
//   A = oscillator amplitude (recent std dev)
//   T = dominant cycle period (bars)
//   φ = current phase (adjusted to connect smoothly to last osc value)
//   t = bars ahead

oscForecast(barsAhead) =>
    t         = float(barsAhead)
    // Phase offset to ensure smooth continuation from current osc value
    phaseAdj  = currentPhase + math.pi
    futPhase  = phaseAdj + 2.0 * math.pi * t / domCycle

    // Core sine cycle
    coreWave  = oscAmp * math.sin(futPhase)

    // Medium cycle (3× dominant) — adds secondary wave
    medPhase  = phaseAdj / 3.0 + 2.0 * math.pi * t / (domCycle * 3.0)
    medWave   = oscAmp * 0.35 * math.sin(medPhase)

    // Halving modulation — shifts mean of oscillator up or down
    halvMod   = oscAmp * halvCycleVal * 0.20

    // Macro directional nudge
    macroDir  = (spxBull and not dxyBull) ? 1.0 : (dxyBull and not spxBull) ? -1.0 : 0.0
    macroNudge= macroDir * oscAmp * 0.08

    // NEW: USDT.D nudge (capital flow signal)
    usdtOscNudge = usdtActFall ? math.abs(usdtMom) * oscAmp * 0.0030 * t : usdtActRise ? -math.abs(usdtMom) * oscAmp * 0.0020 * t : 0.0

    // NEW: BTC.D nudge (capital rotation signal)
    btcDomOscNudge = btcDomBullish ? math.abs(btcDomMom) * oscAmp * 0.0015 * t : -math.abs(btcDomMom) * oscAmp * 0.0010 * t

    // NEW: Futures basis nudge (institutional sentiment)
    futOscNudge = inContango and not overLevLong ? futBasis * oscAmp * 0.005 : inBackward ? -math.abs(futBasis) * oscAmp * 0.005 : 0.0

    // Composite
    coreWave + medWave + halvMod + macroNudge + usdtOscNudge + btcDomOscNudge + futOscNudge

// Band width for forecast — widens with distance and uncertainty
fcastBand(barsAhead) =>
    s1 * 0.35 * (1.0 + float(barsAhead) / float(forecastBars) * 1.5) * (1.15 - float(confidence) / 130.0)

// ═══════════════════════════════════════════════════════════════════
// ── OSCILLATOR PLOT (HSH_FM Style)
// ═══════════════════════════════════════════════════════════════════

// Background fill between σ bands (subtle)
s1UpP = plot( s1, "σ1 Upper", color=color.new(color.red,   55), linewidth=1, style=plot.style_line)
s1DnP = plot(-s1, "σ1 Lower", color=color.new(color.red,   55), linewidth=1, style=plot.style_line)
s2UpP = plot( s2, "σ2 Upper", color=color.new(#FF6600, 55), linewidth=1, style=plot.style_line)
s2DnP = plot(-s2, "σ2 Lower", color=color.new(#FF6600, 55), linewidth=1, style=plot.style_line)
s3UpP = plot( s3, "σ3 Upper", color=color.new(color.maroon, 50), linewidth=1, style=plot.style_line)
s3DnP = plot(-s3, "σ3 Lower", color=color.new(color.maroon, 50), linewidth=1, style=plot.style_line)

fill(s1UpP, s1DnP, color=color.new(color.white,  97))
fill(s2UpP, s2DnP, color=color.new(#FF6600, 97))
fill(s3UpP, s3DnP, color=color.new(color.red,    96))

// Zero line
hline(0, "Zero", color=color.new(color.white, 50), linestyle=hline.style_dashed, linewidth=1)

// Normalized signal line (smooth of osc — NOT raw price WMA)
// sigLine was WMA of close (~$77k) which breaks the y-axis scale
// oscSig is a smooth of the normalized osc — stays in ±100-300 range
oscSig   = ta.ema(osc, smoothLen)
plot(oscSig, "Signal Line", color=color.new(color.red, 20), linewidth=1)

// Main oscillator line (orange, thick) — like HSH_FM
oscColor = osc >= 0 ? color.new(#FF9900, 0) : color.new(#FF5500, 20)
plot(osc, "Oscillator", color=oscColor, linewidth=2)

// ═══════════════════════════════════════════════════════════════════
// ── SIGNAL MARKERS ON OSCILLATOR PANEL
// ═══════════════════════════════════════════════════════════════════
// ─── SIGNAL INSTRUCTION BANNERS ──────────────────────────────────────────────
// Each label shows exactly what to do: entry size, action, and why.
// plotshape for the small chart markers (global scope required)
plotshape(showShapes and longSig,   "▲ LONG",      style=shape.triangleup,   location=location.bottom, color=color.new(#39FF14, 0), size=size.small)
plotshape(showShapes and shortSig,  "▼ SHORT",     style=shape.triangledown, location=location.top,    color=color.new(#FF073A, 0), size=size.small)
plotshape(showShapes and exitLong,  "✕ EXIT LONG", style=shape.xcross,       location=location.top,    color=color.new(#FF6600, 0), size=size.tiny)
plotshape(showShapes and exitShort, "✕ EXIT SHORT",style=shape.xcross,       location=location.bottom, color=color.new(#00CFFF, 0), size=size.tiny)

// ── Detailed instruction labels — shown on every signal bar ──────────────────
if urgentLong
    label.new(bar_index, -s2 * 1.3,
         "⚡ URGENT — BUY LONG NOW\n" +
         "► Enter 1% of balance\n" +
         "► Add 1% if price dips\n" +
         "► Add 2% on deeper dip\n" +
         "► TP1: close 25% in green\n" +
         "► TP2: close 25% higher\n" +
         "► Hold 50% as runner\n" +
         "Conf: " + str.tostring(confidence) + "%",
         color=color.new(#00FF00, 0), textcolor=color.black,
         style=label.style_label_up, size=size.small)

if urgentShort
    label.new(bar_index, s2 * 1.3,
         "⚡ URGENT — SELL SHORT NOW\n" +
         "► Enter 1% of balance\n" +
         "► Add 1% if price rises\n" +
         "► Add 2% on further rise\n" +
         "► TP1: close 25% in green\n" +
         "► TP2: close 25% lower\n" +
         "► Hold 50% as runner\n" +
         "Conf: " + str.tostring(confidence) + "%",
         color=color.new(#FF0000, 0), textcolor=color.white,
         style=label.style_label_down, size=size.small)

if longSig and not urgentLong
    label.new(bar_index, -s1 * 1.3,
         "▲ OPEN LONG\n" +
         "► Enter 1% — first bullet\n" +
         "► Scale in on weakness\n" +
         "► No stop-loss — average\n" +
         "► Take 25% at TP1 & TP2\n" +
         "Conf: " + str.tostring(confidence) + "%",
         color=color.new(#39FF14, 0), textcolor=color.black,
         style=label.style_label_up, size=size.small)

if shortSig and not urgentShort
    label.new(bar_index, s1 * 1.3,
         "▼ OPEN SHORT\n" +
         "► Enter 1% — first bullet\n" +
         "► Scale in on strength\n" +
         "► No stop-loss — average\n" +
         "► Take 25% at TP1 & TP2\n" +
         "Conf: " + str.tostring(confidence) + "%",
         color=color.new(#FF073A, 0), textcolor=color.white,
         style=label.style_label_down, size=size.small)

if exitLong and not shortSig
    label.new(bar_index, s1 * 1.1,
         "✕ CLOSE LONG\n" +
         "► Osc crossed zero — exit\n" +
         "► Close remaining 50%\n" +
         "► Wait for next signal",
         color=color.new(#FF6600, 0), textcolor=color.white,
         style=label.style_label_down, size=size.small)

if exitShort and not longSig
    label.new(bar_index, -s1 * 1.1,
         "✕ CLOSE SHORT\n" +
         "► Osc crossed zero — exit\n" +
         "► Close remaining 50%\n" +
         "► Wait for next signal",
         color=color.new(#00CFFF, 0), textcolor=color.black,
         style=label.style_label_up, size=size.small)

// ═══════════════════════════════════════════════════════════════════
// ── BACKGROUND COLORING (matches ORACLE v1 overlay)
// ═══════════════════════════════════════════════════════════════════
bgcolor(
     urgentLong  ? color.new(#00FF00, 82) : urgentShort ? color.new(#FF0000, 82) : longSig     ? color.new(#39FF14, 90) : shortSig    ? color.new(#FF073A, 90) : exitLong    ? color.new(#FF6600, 92) : exitShort   ? color.new(#00CFFF, 92) : na,
     title="Signal Background")

// ═══════════════════════════════════════════════════════════════════
// ── DRAW OSCILLATOR FORECAST (dashed, like HSH_FM)
// ═══════════════════════════════════════════════════════════════════
var line[] fcastLines  = array.new_line()
var line[] fcastUpBand = array.new_line()
var line[] fcastDnBand = array.new_line()
var label[] fcastLbls  = array.new_label()

if showForecast and barstate.islast
    // Cleanup old objects
    for l in fcastLines
        line.delete(l)
    for l in fcastUpBand
        line.delete(l)
    for l in fcastDnBand
        line.delete(l)
    for lb in fcastLbls
        label.delete(lb)
    array.clear(fcastLines)
    array.clear(fcastUpBand)
    array.clear(fcastDnBand)
    array.clear(fcastLbls)

    // Draw vertical separator at current bar
    array.push(fcastLbls, label.new(
         bar_index, s3 * 0.95, "NOW",
         color=color.new(color.white, 60), textcolor=color.new(color.white, 30),
         style=label.style_none, size=size.tiny))

    // Draw dashed oscillator forecast segments
    step = 2
    for i = 0 to forecastBars - step by step
        ov0 = oscForecast(i)
        ov1 = oscForecast(i + step)

        // Colour: positive forecast = orange, negative = red-orange, like HSH_FM dashes
        fCol = ov1 >= 0 ? color.new(#FF9900, 25) : color.new(#FF4400, 30)

        // Main dashed line
        array.push(fcastLines, line.new(
             x1    = bar_index + i,
             y1    = ov0,
             x2    = bar_index + i + step,
             y2    = ov1,
             color = fCol,
             style = line.style_dashed,
             width = 2))

        // Confidence bands
        if showConfBand
            bw0 = fcastBand(i)
            bw1 = fcastBand(i + step)
            array.push(fcastUpBand, line.new(
                 x1 = bar_index + i, y1 = ov0 + bw0,
                 x2 = bar_index + i + step, y2 = ov1 + bw1,
                 color = color.new(#FF9900, 78), style = line.style_dotted, width = 1))
            array.push(fcastDnBand, line.new(
                 x1 = bar_index + i, y1 = ov0 - bw0,
                 x2 = bar_index + i + step, y2 = ov1 - bw1,
                 color = color.new(#FF9900, 78), style = line.style_dotted, width = 1))

    // Key turning points on oscillator forecast
    lblCount = 0
    for i = step to forecastBars - step by step
        if lblCount >= 6
            break
        ov_prev = oscForecast(i - step)
        ov_curr = oscForecast(i)
        ov_next = oscForecast(math.min(i + step, forecastBars))

        if ov_curr > ov_prev and ov_curr > ov_next and ov_curr > s1 * 0.4
            // Peak in oscillator forecast
            futMs = time + i * timeframe.in_seconds(timeframe.period) * 1000
            dStr  = str.format_time(futMs, "MMM dd", syminfo.timezone)
            array.push(fcastLbls, label.new(
                 x         = bar_index + i,
                 y         = ov_curr + s1 * 0.6,
                 text      = "▲\n" + dStr,
                 color     = color.new(#39FF14, 30),
                 textcolor = color.white,
                 style     = label.style_label_down,
                 size      = size.tiny))
            lblCount += 1

        if ov_curr < ov_prev and ov_curr < ov_next and ov_curr < -s1 * 0.4
            // Trough in oscillator forecast
            futMs = time + i * timeframe.in_seconds(timeframe.period) * 1000
            dStr  = str.format_time(futMs, "MMM dd", syminfo.timezone)
            array.push(fcastLbls, label.new(
                 x         = bar_index + i,
                 y         = ov_curr - s1 * 0.6,
                 text      = "▼\n" + dStr,
                 color     = color.new(#FF073A, 30),
                 textcolor = color.white,
                 style     = label.style_label_up,
                 size      = size.tiny))
            lblCount += 1

    // Zero-crossing in forecast — potential entry zone markers
    for i = step to forecastBars - step by step
        ov_prev = oscForecast(i - step)
        ov_curr = oscForecast(i)
        // Upward zero cross in forecast = anticipated long entry
        if ov_prev < 0 and ov_curr >= 0
            futMs = time + i * timeframe.in_seconds(timeframe.period) * 1000
            dStr  = str.format_time(futMs, "MMM dd", syminfo.timezone)
            array.push(fcastLbls, label.new(
                 x         = bar_index + i,
                 y         = 0,
                 text      = "↑ " + dStr,
                 color     = color.new(#39FF14, 50),
                 textcolor = color.white,
                 style     = label.style_label_left,
                 size      = size.tiny))
        // Downward zero cross = anticipated short entry
        if ov_prev > 0 and ov_curr <= 0
            futMs = time + i * timeframe.in_seconds(timeframe.period) * 1000
            dStr  = str.format_time(futMs, "MMM dd", syminfo.timezone)
            array.push(fcastLbls, label.new(
                 x         = bar_index + i,
                 y         = 0,
                 text      = "↓ " + dStr,
                 color     = color.new(#FF073A, 50),
                 textcolor = color.white,
                 style     = label.style_label_left,
                 size      = size.tiny))

// ═══════════════════════════════════════════════════════════════════
// ── MINI INFO PANEL (compact, for oscillator pane)
// ═══════════════════════════════════════════════════════════════════
if showTable and barstate.islast
    tPosV = tPos == "top_right"    ? position.top_right    : tPos == "top_left"     ? position.top_left     : tPos == "bottom_right" ? position.bottom_right : position.bottom_left

    t = table.new(tPosV, 2, 22,
         bgcolor      = color.new(#0a0a12, 8),
         border_color = color.new(color.gray, 60),
         border_width = 1,
         frame_color  = color.gray, frame_width = 1)

    // Title
    table.cell(t, 0, 0, "⚡ PCRXS OSC", text_color=color.white, text_size=size.small, bgcolor=color.new(#0d1b2a, 0), text_halign=text.align_center)
    table.merge_cells(t, 0, 0, 1, 0)

    // Signal
    sigTxt = urgentLong  ? "⚡ URGENT ▲ LONG"  : urgentShort ? "⚡ URGENT ▼ SHORT" : longSig     ? "▲ LONG"           : shortSig    ? "▼ SHORT"          : exitLong    ? "✕ EXIT LONG"      : exitShort   ? "✕ EXIT SHORT"     : "◈ WATCHING"
    sigC   = urgentLong or longSig  ? color.lime   : urgentShort or shortSig ? color.red   : exitLong ? color.orange : exitShort ? color.blue : color.gray

    table.cell(t, 0, 1, "SIGNAL", text_color=color.silver, text_size=size.tiny)
    table.cell(t, 1, 1, sigTxt, text_color=sigC, text_size=size.tiny, text_halign=text.align_right)

    table.cell(t, 0, 2, "Confidence", text_color=color.silver, text_size=size.tiny)
    table.cell(t, 1, 2, str.tostring(confidence) + "%", text_color=confidence >= 70 ? color.lime : confidence >= 50 ? color.orange : color.red, text_size=size.tiny, text_halign=text.align_right)

    // Oscillator value (% of σ1)
    table.cell(t, 0, 3, "Osc / σ1", text_color=color.silver, text_size=size.tiny)
    table.cell(t, 1, 3, str.tostring(math.round(oscNorm)) + "%", text_color=oscNorm > 100 ? color.orange : oscNorm < -100 ? color.blue : color.white, text_size=size.tiny, text_halign=text.align_right)

    // Cycle
    table.cell(t, 0, 4, "Detected Cycle", text_color=color.silver, text_size=size.tiny)
    table.cell(t, 1, 4, str.tostring(math.round(domCycle)) + " bars", text_color=color.yellow, text_size=size.tiny, text_halign=text.align_right)

    table.cell(t, 0, 5, "Phase", text_color=color.silver, text_size=size.tiny)
    table.cell(t, 1, 5, math.sin(currentPhase + math.pi) > 0 ? "↑ Rising" : "↓ Falling", text_color=math.sin(currentPhase + math.pi) > 0 ? color.lime : color.red, text_size=size.tiny, text_halign=text.align_right)

    // Forecast summary
    table.cell(t, 0, 6, "── Forecast ──", text_color=color.white, text_size=size.tiny, bgcolor=color.new(#1a2a3a, 20), text_halign=text.align_center)
    table.merge_cells(t, 0, 6, 1, 6)

    fv30 = oscForecast(math.min(30, forecastBars))
    fv60 = oscForecast(math.min(60, forecastBars))
    table.cell(t, 0, 7, "+30 bars OSC",  text_color=color.silver, text_size=size.tiny)
    table.cell(t, 1, 7, str.tostring(math.round(fv30, 1)) + (fv30 > 0 ? " ▲" : " ▼"), text_color=fv30 > 0 ? color.lime : color.red, text_size=size.tiny, text_halign=text.align_right)
    table.cell(t, 0, 8, "+60 bars OSC", text_color=color.silver, text_size=size.tiny)
    table.cell(t, 1, 8, str.tostring(math.round(fv60, 1)) + (fv60 > 0 ? " ▲" : " ▼"), text_color=fv60 > 0 ? color.lime : color.red, text_size=size.tiny, text_halign=text.align_right)

    // Filters
    table.cell(t, 0, 9, "── Filters ──", text_color=color.white, text_size=size.tiny, bgcolor=color.new(#1a2a3a, 20), text_halign=text.align_center)
    table.merge_cells(t, 0, 9, 1, 9)

    table.cell(t, 0, 10, "H4 Bias", text_color=color.silver, text_size=size.tiny)
    table.cell(t, 1, 10, h4Bull ? "🟢 BULL" : h4Bear ? "🔴 BEAR" : "⚪ NEUT", text_color=h4Bull ? color.lime : h4Bear ? color.red : color.gray, text_size=size.tiny, text_halign=text.align_right)

    table.cell(t, 0, 11, "RSI", text_color=color.silver, text_size=size.tiny)
    table.cell(t, 1, 11, str.tostring(math.round(rsi, 1)), text_color=rsi > rsiOB ? color.red : rsi < rsiOS ? color.orange : color.lime, text_size=size.tiny, text_halign=text.align_right)

    table.cell(t, 0, 12, "ADX", text_color=color.silver, text_size=size.tiny)
    table.cell(t, 1, 12, str.tostring(math.round(adx, 1)) + (trending ? " 🔥" : " 💤"), text_color=trending ? color.lime : color.gray, text_size=size.tiny, text_halign=text.align_right)

    table.cell(t, 0, 13, "CMF", text_color=color.silver, text_size=size.tiny)
    table.cell(t, 1, 13, str.tostring(math.round(cmf * 1000) / 1000), text_color=cmf > 0 ? color.lime : color.red, text_size=size.tiny, text_halign=text.align_right)

    // BTC Cycle
    table.cell(t, 0, 14, "── BTC Cycle ──", text_color=color.white, text_size=size.tiny, bgcolor=color.new(#1a2a3a, 20), text_halign=text.align_center)
    table.merge_cells(t, 0, 14, 1, 14)

    halvPhaseStr =
         halvMonths < 6  ? "Accumulation" : halvMonths < 12 ? "Early Bull"   : halvMonths < 18 ? "🔥 Bull Run"  : halvMonths < 24 ? "⚠️ Distribution" : halvMonths < 36 ? "🐻 Bear"      : "Bottom Zone"
    halvPhaseCol =
         halvMonths < 12 ? color.lime   : halvMonths < 18 ? #00FF88     : halvMonths < 24 ? color.yellow : halvMonths < 36 ? color.red    : color.orange

    table.cell(t, 0, 15, "Phase", text_color=color.silver, text_size=size.tiny)
    table.cell(t, 1, 15, halvPhaseStr, text_color=halvPhaseCol, text_size=size.tiny, text_halign=text.align_right)

    table.cell(t, 0, 16, "Cycle Strength", text_color=color.silver, text_size=size.tiny)
    table.cell(t, 1, 16, str.tostring(math.round(halvCycleVal * 100)) + "%", text_color=halvCycleVal > 0.3 ? color.lime : halvCycleVal < -0.3 ? color.red : color.yellow, text_size=size.tiny, text_halign=text.align_right)

    // Dominance snapshot
    table.cell(t, 0, 17, "── Dominance ──", text_color=color.white, text_size=size.tiny, bgcolor=color.new(#1a2a3a, 20), text_halign=text.align_center)
    table.merge_cells(t, 0, 17, 1, 17)

    table.cell(t, 0, 18, "BTC.D", text_color=color.silver, text_size=size.tiny)
    table.cell(t, 1, 18, str.tostring(math.round(btcDom, 1)) + "%  " + (btcDomRise ? "▲" : "▼"), text_color=btcDomBullish ? color.lime : color.red, text_size=size.tiny, text_halign=text.align_right)

    table.cell(t, 0, 19, "USDT.D", text_color=color.silver, text_size=size.tiny)
    table.cell(t, 1, 19, str.tostring(math.round(usdtDom, 2)) + "%  " + (dryPowder ? "⚡DRY POWDER" : usdtActFall ? "↓ Deploying" : usdtActRise ? "↑ Leaving" : "→"), text_color=dryPowder ? color.yellow : usdtBullish ? color.lime : color.red, text_size=size.tiny, text_halign=text.align_right)

    table.cell(t, 0, 20, "CME Basis", text_color=color.silver, text_size=size.tiny)
    table.cell(t, 1, 20, btcFutValid ? str.tostring(math.round(futBasis, 3)) + "%" + (overLevLong ? " ⚠️OVR" : inContango ? " CONT" : inBackward ? " BACK" : "") : "N/A", text_color=overLevLong ? color.orange : futBullish ? color.lime : futBearish ? color.red : color.gray, text_size=size.tiny, text_halign=text.align_right)

    // Urgent banner
    if urgentLong or urgentShort
        table.cell(t, 0, 21, urgentLong ? "⚡ URGENT ▲ LONG ⚡" : "⚡ URGENT ▼ SHORT ⚡", text_color  = urgentLong ? color.black : color.white, text_size   = size.small, bgcolor     = urgentLong ? color.new(#00FF00, 0) : color.new(#FF0000, 0), text_halign = text.align_center)
        table.merge_cells(t, 0, 21, 1, 21)

// ═══════════════════════════════════════════════════════════════════
// ── ALERTS (mirrors overlay script)
// ═══════════════════════════════════════════════════════════════════
alertcondition(urgentLong,  "⚡ URGENT LONG",  "PCRXS OSC ⚡ URGENT LONG | {{ticker}} {{interval}} | Price: {{close}}")
alertcondition(urgentShort, "⚡ URGENT SHORT", "PCRXS OSC ⚡ URGENT SHORT | {{ticker}} {{interval}} | Price: {{close}}")
alertcondition(longSig,     "▲ LONG Signal",   "PCRXS OSC ▲ LONG | {{ticker}} {{interval}} | Price: {{close}}")
alertcondition(shortSig,    "▼ SHORT Signal",  "PCRXS OSC ▼ SHORT | {{ticker}} {{interval}} | Price: {{close}}")
alertcondition(exitLong,    "✕ EXIT Long",     "PCRXS OSC ✕ EXIT LONG | {{ticker}} {{interval}} | Price: {{close}}")
alertcondition(exitShort,   "✕ EXIT Short",    "PCRXS OSC ✕ EXIT SHORT | {{ticker}} {{interval}} | Price: {{close}}")
````
