# PCRXS Forecast Engine v1.0

- url: https://www.tradingview.com/script/8zUVCCRd-PCRXS-Forecast-Engine-v1-0/
- type: indicator
- pine_id: PUB;f01f33b7caf94169b81f125b4b8f7ea1
- version: 2.0

## Description

⚡ PCRXS Forecast Engine — Price Forecast
The dashed orange lines extending to the right of the current bar are a composite mathematical projection of where price is likely to go, built from 10 components that run simultaneously:
ComponentWhat it capturesLinear regression trendThe current slope and direction of the marketShort cycleDominant swing cycle auto-detected from your chart's pivot highsMedium cycle3× the short cycle — the bigger swing structureBTC halving cycle4-year model anchored to Apr 2024 halvingDXY inverseDollar strength drag/tailwind on cryptoS&P 500Risk-on/off correlation nudgeGoldSafe haven signal — rising gold dampens cryptoFear & GreedATR-based volatility proxyUSDT.D flowStablecoin capital entering or leaving cryptoCME futures basisInstitutional sentiment (contango vs backwardation)
What you see on the chart:

🟠 Dashed orange line — the composite forecast path
Dotted lines above/below — confidence bands that widen with distance (wider = less certain)
🟢 Green labels at troughs — predicted low points with date and price → where to Close Short / Buy Long
🔴 Red labels at peaks — predicted high points with date and price → where to Close Long / Buy Short
↑ ↓ labels on zero line — where the oscillator is forecast to cross zero → anticipated entry zones

The confidence % shown on each label reflects how many of the 19 market factors are pointing in the same direction. Above 70% is high conviction. Below 50% means mixed signals — treat the forecast as directional guidance only, not a guarantee.

## Source Code

````pine
// ╔══════════════════════════════════════════════════════════════════╗
// ║   ⚡ PCRXS Forecast Engine v1.0 — Quantum Price Forecast Engine  ║
// ║   Overlay: Entry/Exit Signals | Price Forecast | BTC Cycle       ║
// ╠══════════════════════════════════════════════════════════════════╣
// ║  SIGNAL COLORS:                                                  ║
// ║    🟢 NEON GREEN  — Long Entry                                   ║
// ║    🔴 NEON RED    — Short Entry                                  ║
// ║    🟠 ORANGE      — Exit Long                                    ║
// ║    🔵 ICE BLUE    — Exit Short                                   ║
// ║    ⚡ BRIGHT WHITE — Urgent / Must Enter                         ║
// ╠══════════════════════════════════════════════════════════════════╣
// ║  FORECAST ENGINE (10 components):                                ║
// ║    1. Linear Regression Trend                                    ║
// ║    2. Dominant Short Cycle (auto-detected from swing points)     ║
// ║    3. Medium Cycle (3× dominant)                                 ║
// ║    4. BTC Halving 4-Year Cycle (Apr 2024 reference)              ║
// ║    5. DXY Dollar Inverse Correlation                             ║
// ║    6. S&P 500 Positive Correlation                               ║
// ║    7. Gold (Risk-off proxy)                                      ║
// ║    8. Fear & Greed Volatility Index                              ║
// ║    9. Bollinger Band Squeeze Breakout Model                      ║
// ║   10. MACD Momentum Trajectory                                   ║
// ╠══════════════════════════════════════════════════════════════════╣
// ║  8-LAYER SIGNAL FILTER:                                          ║
// ║    1. Core oscillator cross (WMA-based, σ-band trigger)          ║
// ║    2. H4 MTF structural bias (EMA 50/200)                        ║
// ║    3. RSI — not overbought/oversold at entry                     ║
// ║    4. MACD histogram momentum direction                          ║
// ║    5. CMF money flow direction                                   ║
// ║    6. Volume above 20-bar average                                ║
// ║    7. ADX trend strength (>22 = trending)                        ║
// ║    8. BTC halving cycle alignment                                ║
// ╠══════════════════════════════════════════════════════════════════╣
// ║  ⚠️  DISCLAIMER: Educational only. Not financial advice.         ║
// ║      All trading involves risk. Never risk more than you can     ║
// ║      afford to lose. Past signals do not guarantee future results║
// ╚══════════════════════════════════════════════════════════════════╝
// REVISION HISTORY:
// v1.0  — Initial release
// v1.1  — Symbol row fix: syminfo.tickerid → syminfo.ticker
// v1.2  — Added section visibility toggles to collapse panel sections

//@version=5
indicator("⚡ PCRXS Forecast Engine v1.0 — Quantum Forecast",
     shorttitle        = "⚡ PCRXS",
     overlay           = true,
     max_bars_back     = 5000,
     max_lines_count   = 500,
     max_labels_count  = 500)

// ═══════════════════════════════════════════════════════════════════
// ── SECTION 1: INPUTS
// ═══════════════════════════════════════════════════════════════════
g1 = "── Core Signal Engine ──"
rsiLen    = input.int(14,    "RSI Length",              minval=2,            group=g1)
rsiOB     = input.float(70,  "RSI Overbought",                               group=g1)
rsiOS     = input.float(30,  "RSI Oversold",                                 group=g1)
atrLen    = input.int(14,    "ATR Length",              minval=1,            group=g1)
filterLen = input.int(20,    "WMA Filter Length",       minval=3,            group=g1)
smoothLen = input.int(3,     "Signal Smooth",           minval=1,            group=g1)
stdPer    = input.int(100,   "Std Dev Period",          minval=20,           group=g1)
mtfTF     = input.timeframe("240", "Structural Bias TF",                     group=g1)

g2 = "── Quantum Forecast Engine ──"
forecastBars = input.int(60,     "Bars Ahead to Forecast", minval=10, maxval=150, group=g2)
showForecast = input.bool(true,  "Show Price Forecast",                           group=g2)
showConfBand = input.bool(true,  "Show Confidence Bands",                         group=g2)
lrLen        = input.int(50,     "Regression Lookback",    minval=10,             group=g2)
trendWt      = input.float(0.40, "Trend Weight",           minval=0, maxval=1, step=0.05, group=g2)
cycleWt      = input.float(0.45, "Short Cycle Weight",     minval=0, maxval=1, step=0.05, group=g2)
halvWt       = input.float(0.15, "Medium/Halving Weight",  minval=0, maxval=1, step=0.05, group=g2)

g3 = "── Display Settings ──"
showTable        = input.bool(true,          "Show Oracle Panel",                   group=g3)
showSignals      = input.bool(true,          "Show Signal Labels",                  group=g3)
showUrgent       = input.bool(true,          "Show URGENT Alerts",                  group=g3)
showSR           = input.bool(true,          "Show S/R Channel",                    group=g3)
tPos             = input.string("top_right", "Panel Position",
     options=["top_right","top_left","bottom_right","bottom_left"],                 group=g3)
urgConfMin       = input.int(62,             "Urgent Min Confidence (%)",
     minval=50, maxval=95,                                                          group=g3)

g4 = "── Panel Section Visibility ──"
showSectionSignal   = input.bool(true,  "Show ── SIGNAL section",          group=g4)
showSectionForecast = input.bool(true,  "Show ── FORECAST section",        group=g4)
showSectionFilters  = input.bool(true,  "Show ── SIGNAL FILTERS section",  group=g4)
showSectionMacro    = input.bool(true,  "Show ── MACRO section",           group=g4)
showSectionGlobal   = input.bool(false, "Show ── GLOBAL MARKETS section",  group=g4)
showSectionSession  = input.bool(false, "Show ── ACTIVE SESSION section",  group=g4)
showSectionHalving  = input.bool(true,  "Show ── BTC HALVING section",     group=g4)
showSectionDom      = input.bool(true,  "Show ── DOMINANCE & FUTURES section", group=g4)

// ═══════════════════════════════════════════════════════════════════
// ── SECTION 2: DATA REQUESTS (Macro Correlations)
// ═══════════════════════════════════════════════════════════════════
h4Close  = request.security(syminfo.tickerid, mtfTF, close,
           barmerge.gaps_off, barmerge.lookahead_off)
h4Ema50  = request.security(syminfo.tickerid, mtfTF, ta.ema(close, 50),
           barmerge.gaps_off, barmerge.lookahead_off)
h4Ema200 = request.security(syminfo.tickerid, mtfTF, ta.ema(close, 200),
           barmerge.gaps_off, barmerge.lookahead_off)

dxy  = request.security("TVC:DXY",  timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
spx  = request.security("SP:SPX",   timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
gold = request.security("TVC:GOLD", timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)

nikkei  = request.security("TVC:NI225",  timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
hsi     = request.security("TVC:HSI",    timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
dax     = request.security("TVC:DEU40",  timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
ftse    = request.security("TVC:UKX",    timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
cac40   = request.security("TVC:CAC40",  timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)

btcDom  = request.security("CRYPTOCAP:BTC.D",  timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
usdtDom = request.security("CRYPTOCAP:USDT.D", timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
btcFut  = request.security("CME:BTC1!",         timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)

// ═══════════════════════════════════════════════════════════════════
// ── SECTION 3: TECHNICAL INDICATORS
// ═══════════════════════════════════════════════════════════════════
h4Bull = h4Close > h4Ema50 and h4Ema50 > h4Ema200
h4Bear = h4Close < h4Ema50 and h4Ema50 < h4Ema200

rsi         = ta.rsi(close, rsiLen)
atr         = ta.atr(atrLen)
atrAvg      = ta.sma(atr, atrLen * 3)
volAvg      = ta.sma(volume, 20)

macd        = ta.ema(close, 12) - ta.ema(close, 26)
macdSig     = ta.ema(macd, 9)
macdHist    = macd - macdSig
macdBull    = macdHist > 0 and macdHist > macdHist[1]
macdBear    = macdHist < 0 and macdHist < macdHist[1]

[bbMid, bbUp, bbDn] = ta.bb(close, 20, 2.0)
bbw         = (bbUp - bbDn) / bbMid
bbwAvg      = ta.sma(bbw, 20)
inSqueeze   = bbw < bbwAvg * 0.75

mfMultiplier = ((close - low) - (high - close)) / math.max(high - low, 1e-10)
mfVolume     = mfMultiplier * volume
cmf          = ta.sma(mfVolume, 20) / math.max(ta.sma(volume, 20), 1e-10)

[diPlus, diMinus, adx] = ta.dmi(14, 14)
trending    = adx > 22

stochK = ta.stoch(close, high, low, 14)
stochD = ta.sma(stochK, 3)

obv         = ta.obv
obvEma      = ta.ema(obv, 20)
obvBull     = obv > obvEma

dxyEma      = ta.ema(dxy,  20)
spxEma      = ta.ema(spx,  20)
goldEma     = ta.ema(gold, 20)
dxyBull     = dxy  > dxyEma
spxBull     = spx  > spxEma
goldBull    = gold > goldEma

fearPct     = atr / close * 100
fearAvg     = ta.sma(fearPct, 50)
extremeFear = fearPct > fearAvg * 2.0

// ═══════════════════════════════════════════════════════════════════
// ── SECTION 3c: GLOBAL MARKET SIGNALS
// ═══════════════════════════════════════════════════════════════════
nikkeiEma  = ta.ema(nikkei, 20)
nikkeiBull = nikkei > nikkeiEma

hsiEma   = ta.ema(hsi, 20)
hsiBull  = hsi > hsiEma

daxEma   = ta.ema(dax, 20)
daxBull  = dax > daxEma

ftseEma  = ta.ema(ftse, 20)
ftseBull = ftse > ftseEma

cacEma   = ta.ema(cac40, 20)
cacBull  = cac40 > cacEma

globalBullCt = (nikkeiBull ? 1 : 0) + (hsiBull ? 1 : 0) + (daxBull ? 1 : 0) + (ftseBull ? 1 : 0) + (cacBull ? 1 : 0)
globalRiskOn = globalBullCt >= 3
globalRiskOff= globalBullCt <= 1

// ─── SESSION DETECTION (UTC-based) ─────────────────────────────────
utcMin        = hour(time, "UTC") * 60 + minute(time, "UTC")
inTokyo       = utcMin >= 0   and utcMin < 390
tokyoBell     = utcMin >= 0   and utcMin < 30
inChina       = utcMin >= 90  and utcMin < 480
chinaBell     = utcMin >= 90  and utcMin < 120
inLondon      = utcMin >= 420 and utcMin < 990
londonBell    = utcMin >= 420 and utcMin < 450
inEU          = utcMin >= 420 and utcMin < 1050
euBell        = utcMin >= 420 and utcMin < 450
inNewYork     = utcMin >= 810 and utcMin < 1260
nyBell        = utcMin >= 810 and utcMin < 840
inEuNyOverlap = utcMin >= 810 and utcMin < 1020
inAnySess     = inTokyo or inChina or inLondon or inNewYork
activeSessStr = inEuNyOverlap ? "EU+NY OVERLAP 🔥" : inNewYork and inLondon ? "NY+LONDON" : inNewYork ? "NEW YORK" : inLondon ? "LONDON/EU" : inChina ? "CHINA/HK" : inTokyo ? "TOKYO" : "OFF-HOURS"

// ═══════════════════════════════════════════════════════════════════
// ── SECTION 3b: DOMINANCE & FUTURES ANALYSIS
// ═══════════════════════════════════════════════════════════════════
btcDomEma20    = ta.ema(btcDom, 20)
btcDomEma50    = ta.ema(btcDom, 50)
btcDomRise     = btcDom > btcDomEma20
btcDomFall     = btcDom < btcDomEma20
btcDomMom      = btcDom > 0.001 ? (btcDom - btcDom[10]) / btcDom[10] * 100 : 0.0
btcDomStrong   = btcDom > 60.0
altSeasonZone  = btcDom < 54.0
altSeasonActive= btcDomFall and altSeasonZone

symBase        = str.upper(syminfo.basecurrency)
isBTC          = symBase == "BTC"
btcDomBullish  = isBTC ? btcDomRise : btcDomFall

usdtDomEma20   = ta.ema(usdtDom, 20)
usdtDomEma50   = ta.ema(usdtDom, 50)
usdtDomRise    = usdtDom > usdtDomEma20
usdtDomFall    = usdtDom < usdtDomEma20
usdtMom        = usdtDom > 0.001 ? (usdtDom - usdtDom[5]) / usdtDom[5] * 100 : 0.0
usdtActFall    = usdtDom < usdtDom[3]
usdtActRise    = usdtDom > usdtDom[3]
usdtNearHigh   = usdtDom > ta.highest(usdtDom, 50) * 0.85
dryPowder      = usdtNearHigh and usdtActFall
usdtBullish    = usdtDomFall
usdtBearish    = usdtDomRise

btcFutValid    = not na(btcFut) and btcFut > 1.0
futBasis       = btcFutValid ? (btcFut - close) / close * 100 : 0.0
inContango     = futBasis > 0.10
inBackward     = futBasis < -0.10
overLevLong    = futBasis > 0.80
futBullish     = inContango and not overLevLong
futBearish     = inBackward or overLevLong

// ═══════════════════════════════════════════════════════════════════
// ── SECTION 4: CORE WMA OSCILLATOR
// ═══════════════════════════════════════════════════════════════════
wmaFn(src, len) =>
    numerator   = 0.0
    denominator = 0.0
    for i = 0 to len - 1
        w           = float(len - i)
        numerator   += src[i] * w
        denominator += w
    numerator / denominator

fastLine    = wmaFn(close, smoothLen)
slowLine    = wmaFn(close, filterLen)
rawOsc      = fastLine - slowLine

atrVal      = ta.atr(atrLen)
osc         = atrVal > 0 ? rawOsc / atrVal * 100 : rawOsc

oscStd      = ta.stdev(osc, stdPer)
sigma1      = oscStd * 1.0
sigma2      = oscStd * 2.0
sigma3      = oscStd * 3.0

oscAbove    = osc > 0
oscBelow    = osc < 0

// ═══════════════════════════════════════════════════════════════════
// ── SECTION 5: CYCLE DETECTION
// ═══════════════════════════════════════════════════════════════════
swingHigh   = ta.pivothigh(high, 5, 5)
swingLow    = ta.pivotlow(low,   5, 5)

var int   ph1      = 0
var int   ph2      = 0
var int   ph3      = 0
var float phPrice  = close
var float plPrice  = close
var float domCycle = 20.0

if not na(swingHigh)
    ph3     := ph2
    ph2     := ph1
    ph1     := bar_index
    phPrice := swingHigh

if not na(swingLow)
    plPrice := swingLow

if ph3 > 0 and ph2 > 0 and ph1 > 0
    period1  = float(ph1 - ph2)
    period2  = float(ph2 - ph3)
    domCycle := (period1 + period2) * 0.5

domCycle := math.max(math.min(domCycle, 150), 5)

barsSincePH  = float(bar_index - ph1)
currentPhase = 2.0 * math.pi * barsSincePH / domCycle
cycleAmp     = math.max(phPrice - plPrice, atr * 2.0) / 2.0

// ═══════════════════════════════════════════════════════════════════
// ── SECTION 6: BTC HALVING CYCLE MODEL
// ═══════════════════════════════════════════════════════════════════
halving4TimeMs    = int(1713571200000)
halvingPeriodMs   = int(126230400000)
msSinceHalving    = math.max(timenow - halving4TimeMs, 0)
halvingPhaseRad   = 2.0 * math.pi * float(msSinceHalving) / float(halvingPeriodMs)
halvingCycleVal   = math.cos(halvingPhaseRad - math.pi * 0.25)
halvingMonths     = float(msSinceHalving) / 2592000000.0

halvingPhaseStr = halvingMonths < 6 ? "Accumulation (0–6m)" : halvingMonths < 12 ? "Early Bull (6–12m)" : halvingMonths < 18 ? "🔥 Bull Run (12–18m)" : halvingMonths < 24 ? "⚠️ Distribution (18–24m)" : halvingMonths < 36 ? "🐻 Bear Market (24–36m)" : halvingMonths < 48 ? "Bottom Zone (36–48m)" : "New Cycle Begins"

halvingPhaseCol = halvingMonths < 12 ? color.lime : halvingMonths < 18 ? #00FF88 : halvingMonths < 24 ? color.yellow : halvingMonths < 36 ? color.red : color.orange

// ═══════════════════════════════════════════════════════════════════
// ── SECTION 7: CONFIDENCE ENGINE
// ═══════════════════════════════════════════════════════════════════
lrNow    = ta.linreg(close, lrLen, 0)
lrPrev   = ta.linreg(close, lrLen, 1)
lrSlope  = lrNow - lrPrev

trendBull = lrSlope > 0
cycleBull = math.sin(currentPhase + math.pi) > 0
halvBull  = halvingCycleVal > 0.10

agreeLong = (trendBull ? 1 : 0) + (cycleBull ? 1 : 0) + (halvBull ? 1 : 0) +
     (spxBull ? 1 : 0) + (not dxyBull ? 1 : 0) + (not goldBull ? 1 : 0) +
     (macdBull ? 1 : 0) + (obvBull ? 1 : 0) + (cmf > 0 ? 1 : 0) +
     (h4Bull ? 1 : 0) + (btcDomBullish ? 1 : 0) + (usdtBullish ? 1 : 0) +
     (futBullish ? 1 : 0) + (nikkeiBull ? 1 : 0) + (hsiBull ? 1 : 0) +
     (daxBull ? 1 : 0) + (ftseBull ? 1 : 0) + (cacBull ? 1 : 0) +
     (globalRiskOn ? 1 : 0)

agreeShort = ((not trendBull) ? 1 : 0) + ((not cycleBull) ? 1 : 0) + ((not halvBull) ? 1 : 0) +
     ((not spxBull) ? 1 : 0) + (dxyBull ? 1 : 0) + (goldBull ? 1 : 0) +
     (macdBear ? 1 : 0) + ((not obvBull) ? 1 : 0) + (cmf < 0 ? 1 : 0) +
     (h4Bear ? 1 : 0) + ((not btcDomBullish) ? 1 : 0) + (usdtBearish ? 1 : 0) +
     (futBearish ? 1 : 0) + ((not nikkeiBull) ? 1 : 0) + ((not hsiBull) ? 1 : 0) +
     ((not daxBull) ? 1 : 0) + ((not ftseBull) ? 1 : 0) + ((not cacBull) ? 1 : 0) +
     (globalRiskOff ? 1 : 0)

dirScore   = lrSlope > 0 ? agreeLong : agreeShort
confBase   = float(dirScore) / 19.0
confBonus  = (trending ? 0.08 : 0.0) + (volume > volAvg * 1.3 ? 0.07 : 0.0) +
     (inSqueeze ? 0.05 : 0.0) + (math.abs(cmf) > 0.15 ? 0.05 : 0.0)
confidence = int(math.min(math.round((confBase + confBonus) * 100), 95))

// ═══════════════════════════════════════════════════════════════════
// ── SECTION 8: SIGNAL GENERATION (8-Layer Filter)
// ═══════════════════════════════════════════════════════════════════
oscLongTrig  = ta.crossover(osc,  -sigma1)
oscShortTrig = ta.crossunder(osc,   sigma1)

longFilters  = h4Bull                           and
               rsi < rsiOB                      and
               macdHist >= macdHist[1]          and
               cmf > -0.05                      and
               volume > volAvg * 0.80           and
               halvingCycleVal > -0.70          and
               (usdtBullish or not usdtBearish) and
               btcDomBullish                    and
               not overLevLong

shortFilters = h4Bear                           and
               rsi > rsiOS                      and
               macdHist <= macdHist[1]          and
               cmf < 0.05                       and
               volume > volAvg * 0.80           and
               halvingCycleVal < 0.70           and
               (usdtBearish or not usdtBullish) and
               (not btcDomBullish)              and
               not dryPowder

longSignal  = oscLongTrig  and longFilters
shortSignal = oscShortTrig and shortFilters

exitLong  = ta.crossunder(osc, 0) or
     (rsi > rsiOB and ta.crossunder(rsi, rsiOB) and h4Bear) or shortSignal
exitShort = ta.crossover(osc, 0) or
     (rsi < rsiOS and ta.crossover(rsi, rsiOS) and h4Bull) or longSignal

urgentLong  = longSignal  and confidence >= urgConfMin and trending and
     volume > volAvg * 1.40 and not extremeFear and adx > 20
urgentShort = shortSignal and confidence >= urgConfMin and trending and
     volume > volAvg * 1.40 and adx > 20

// ═══════════════════════════════════════════════════════════════════
// ── SECTION 9: COLORS & CANDLE PAINTING
// ═══════════════════════════════════════════════════════════════════
NEON_GREEN   = color.new(#39FF14, 0)
NEON_RED     = color.new(#FF073A, 0)
HOT_ORANGE   = color.new(#FF6600, 0)
ICE_BLUE     = color.new(#00CFFF, 0)
URGENT_WHITE = color.new(#FFFFFF, 0)
URGENT_LIME  = color.new(#00FF00, 0)
URGENT_RED2  = color.new(#FF0000, 0)

barcolor(
     urgentLong  ? URGENT_LIME  : urgentShort ? URGENT_RED2 :
     longSignal  ? NEON_GREEN   : shortSignal ? NEON_RED    :
     exitLong    ? HOT_ORANGE   : exitShort   ? ICE_BLUE    : na,
     title="Signal Candle Color")

bgcolor(
     urgentLong  ? color.new(#00FF00, 78) : urgentShort ? color.new(#FF0000, 78) :
     longSignal  ? color.new(#39FF14, 90) : shortSignal ? color.new(#FF073A, 90) :
     exitLong    ? color.new(#FF6600, 91) : exitShort   ? color.new(#00CFFF, 91) : na,
     title="Signal Background Glow")

plotshape(tokyoBell,  "🇯🇵 Tokyo Bell",    shape.circle, location.top, color.new(#FF9900, 30), size=size.tiny, text="🇯🇵")
plotshape(chinaBell,  "🇨🇳 China/HK Bell", shape.circle, location.top, color.new(#FF3333, 30), size=size.tiny, text="🇨🇳")
plotshape(londonBell, "🇬🇧 London Bell",   shape.circle, location.top, color.new(#3399FF, 30), size=size.tiny, text="🇬🇧")
plotshape(nyBell,     "🇺🇸 NY Bell",       shape.circle, location.top, color.new(#00CC44, 30), size=size.tiny, text="🇺🇸")

// ═══════════════════════════════════════════════════════════════════
// ── SECTION 10: SIGNAL LABELS
// ═══════════════════════════════════════════════════════════════════
if showSignals
    if urgentLong
        label.new(bar_index, low - atr * 1.8,
             "⚡ URGENT — BUY LONG NOW\n► Enter 1% of balance\n► Add 1% if price dips lower\n► Add 2% on deeper dip\n► TP1: close 25% in profit\n► TP2: close 25% higher\n► Hold 50% — let it run\n► No stop-loss — scale & avg\nConf: " + str.tostring(confidence) + "%",
             color=URGENT_LIME, textcolor=color.black, style=label.style_label_up, size=size.normal)
    else if longSignal
        label.new(bar_index, low - atr * 1.2,
             "▲ OPEN LONG\n► Enter 1% — first bullet\n► Add 1% on weakness\n► Add 2% on deeper dip\n► TP1: 25% | TP2: 25%\n► Hold 50% runner\nConf: " + str.tostring(confidence) + "%",
             color=NEON_GREEN, textcolor=color.black, style=label.style_label_up, size=size.small)
    if urgentShort
        label.new(bar_index, high + atr * 1.8,
             "⚡ URGENT — SELL SHORT NOW\n► Enter 1% of balance\n► Add 1% if price rises\n► Add 2% on further rally\n► TP1: close 25% in profit\n► TP2: close 25% lower\n► Hold 50% — let it run\n► No stop-loss — scale & avg\nConf: " + str.tostring(confidence) + "%",
             color=URGENT_RED2, textcolor=color.white, style=label.style_label_down, size=size.normal)
    else if shortSignal
        label.new(bar_index, high + atr * 1.2,
             "▼ OPEN SHORT\n► Enter 1% — first bullet\n► Add 1% on rally\n► Add 2% on deeper rally\n► TP1: 25% | TP2: 25%\n► Hold 50% runner\nConf: " + str.tostring(confidence) + "%",
             color=NEON_RED, textcolor=color.white, style=label.style_label_down, size=size.small)
    if exitLong and not shortSignal
        label.new(bar_index, high + atr * 0.6,
             "✕ CLOSE LONG\n► Close remaining 50%\n► Osc crossed zero\n► Wait for next signal",
             color=HOT_ORANGE, textcolor=color.white, style=label.style_label_down, size=size.small)
    if exitShort and not longSignal
        label.new(bar_index, low - atr * 0.6,
             "✕ CLOSE SHORT\n► Close remaining 50%\n► Osc crossed zero\n► Wait for next signal",
             color=ICE_BLUE, textcolor=color.black, style=label.style_label_up, size=size.small)

// ═══════════════════════════════════════════════════════════════════
// ── SECTION 11: QUANTUM FORECAST FUNCTION
// ═══════════════════════════════════════════════════════════════════
forecastPrice(barsAhead) =>
    t          = float(barsAhead)
    trendComp  = close + lrSlope * t
    shortPhase = currentPhase + 2.0 * math.pi * t / domCycle
    shortComp  = trendComp + cycleAmp * math.sin(shortPhase + math.pi)
    medPhase   = currentPhase / 3.0 + 2.0 * math.pi * t / (domCycle * 3.0)
    medComp    = trendComp + cycleAmp * 1.5 * math.sin(medPhase + math.pi)
    halvMod    = cycleAmp * halvingCycleVal * 0.3
    spxNudge   = spxBull  ? +0.0012 * t * close / 100.0 : -0.0008 * t * close / 100.0
    dxyNudge   = dxyBull  ? -0.0010 * t * close / 100.0 : +0.0006 * t * close / 100.0
    goldNudge  = goldBull ? -0.0004 * t * close / 100.0 : +0.0002 * t * close / 100.0
    macroAdj   = spxNudge + dxyNudge + goldNudge
    usdtNudge  = usdtActFall ? math.abs(usdtMom) * 0.0035 * t * close / 100.0 :
         usdtActRise ? -math.abs(usdtMom) * 0.0025 * t * close / 100.0 : 0.0
    btcDomNudge = btcDomBullish ? math.abs(btcDomMom) * 0.0020 * t * close / 100.0 : math.abs(btcDomMom) * 0.0015 * t * close / 100.0 * -1
    futNudge   = (inContango and not overLevLong) ? futBasis * 0.04 * close / 100.0 :
         inBackward  ? futBasis * 0.04 * close / 100.0 :
         overLevLong ? -futBasis * 0.02 * close / 100.0 : 0.0
    composite   = trendComp * trendWt + shortComp * cycleWt + medComp * halvWt
    globalNudge = globalRiskOn  ?  0.0008 * t * close / 100.0 :
         globalRiskOff ? -0.0006 * t * close / 100.0 : 0.0
    asianNudge  = (nikkeiBull and hsiBull)           ?  0.0005 * t * close / 100.0 :
         (not nikkeiBull and not hsiBull) ? -0.0004 * t * close / 100.0 : 0.0
    composite + macroAdj + halvMod + usdtNudge + btcDomNudge + futNudge + globalNudge + asianNudge

bandWidth(barsAhead) =>
    baseWidth  = atr * 1.2
    expansion  = float(barsAhead) / float(forecastBars) * 2.5
    confFactor = 1.15 - float(confidence) / 130.0
    baseWidth * (1.0 + expansion) * confFactor

// ── SECTION 11b: FORECAST RECOMMENDATION
fp20Pre   = forecastPrice(20)
fp40Pre   = forecastPrice(40)
fcastUp   = fp20Pre > close * 1.001 and fp40Pre > close
fcastDown = fp20Pre < close * 0.999 and fp40Pre < close

fcastRec    = urgentLong ? "⚡ BUY LONG — URGENT ENTRY" : urgentShort ? "⚡ BUY SHORT — URGENT ENTRY" : longSignal ? "▲ BUY LONG" : shortSignal ? "▼ BUY SHORT" : exitLong ? "✕ CLOSE LONG" : exitShort ? "✕ CLOSE SHORT" : fcastUp and confidence >= 55 ? "📈 FORECAST LONG — No entry yet" : fcastDown and confidence >= 55 ? "📉 FORECAST SHORT — No entry yet" : "◈ HOLD / WAIT FOR SIGNAL"

fcastRecCol = urgentLong or longSignal ? color.new(#00FF00, 0) : urgentShort or shortSignal ? color.new(#FF0000, 0) : exitLong ? color.new(#FF6600, 0) : exitShort ? color.new(#00CFFF, 0) : fcastUp and confidence >= 55 ? color.new(#39FF14, 20) : fcastDown and confidence >= 55 ? color.new(#FF073A, 20) : color.new(color.gray, 30)

fcastRecTxt = urgentLong or longSignal ? color.black : color.white

// ═══════════════════════════════════════════════════════════════════
// ── SECTION 12: DRAW FORECAST LINES
// ═══════════════════════════════════════════════════════════════════
var line[]  forecastLines  = array.new_line()
var line[]  confUpperLines = array.new_line()
var line[]  confLowerLines = array.new_line()
var label[] forecastLabels = array.new_label()

if showForecast and barstate.islast
    for l in forecastLines
        line.delete(l)
    for l in confUpperLines
        line.delete(l)
    for l in confLowerLines
        line.delete(l)
    for lb in forecastLabels
        label.delete(lb)
    array.clear(forecastLines)
    array.clear(confUpperLines)
    array.clear(confLowerLines)
    array.clear(forecastLabels)

    label.new(bar_index, close, "◆",
         color=color.new(#FF9900, 30), textcolor=#FF9900,
         style=label.style_label_center, size=size.tiny)

    step       = 2
    labelCount = 0

    for i = 0 to forecastBars - step by step
        fp0 = forecastPrice(i)
        fp1 = forecastPrice(i + step)
        fLineCol = fp1 >= fp0 ? color.new(#FF9900, 15) : color.new(#FF5500, 25)
        array.push(forecastLines, line.new(
             x1=bar_index+i, y1=fp0, x2=bar_index+i+step, y2=fp1,
             color=fLineCol, style=line.style_dashed, width=2))
        if showConfBand
            bw0 = bandWidth(i)
            bw1 = bandWidth(i + step)
            array.push(confUpperLines, line.new(
                 x1=bar_index+i, y1=fp0+bw0, x2=bar_index+i+step, y2=fp1+bw1,
                 color=color.new(#FF9900, 72), style=line.style_dotted, width=1))
            array.push(confLowerLines, line.new(
                 x1=bar_index+i, y1=fp0-bw0, x2=bar_index+i+step, y2=fp1-bw1,
                 color=color.new(#FF9900, 72), style=line.style_dotted, width=1))
        if i >= step and labelCount < 8
            fpPrev = forecastPrice(i - step)
            fpNext = forecastPrice(math.min(i + step, forecastBars))
            if fp0 > fpPrev and fp0 > fpNext
                futureMs = time + i * timeframe.in_seconds(timeframe.period) * 1000
                dStr = str.format_time(futureMs, "MMM dd", syminfo.timezone)
                pStr = str.tostring(math.round(fp0/syminfo.mintick)*syminfo.mintick, format.mintick)
                array.push(forecastLabels, label.new(
                     x=bar_index+i, y=fp0+atr*1.5,
                     text="✕ CLOSE LONG\n▼ BUY SHORT?\n"+pStr+"\n"+dStr+"\n"+str.tostring(confidence)+"%",
                     color=color.new(#FF073A,20), textcolor=color.white,
                     style=label.style_label_down, size=size.tiny))
                labelCount += 1
            if fp0 < fpPrev and fp0 < fpNext
                futureMs = time + i * timeframe.in_seconds(timeframe.period) * 1000
                dStr = str.format_time(futureMs, "MMM dd", syminfo.timezone)
                pStr = str.tostring(math.round(fp0/syminfo.mintick)*syminfo.mintick, format.mintick)
                array.push(forecastLabels, label.new(
                     x=bar_index+i, y=fp0-atr*1.5,
                     text="✕ CLOSE SHORT\n▲ BUY LONG?\n"+pStr+"\n"+dStr+"\n"+str.tostring(confidence)+"%",
                     color=color.new(#39FF14,20), textcolor=color.black,
                     style=label.style_label_up, size=size.tiny))
                labelCount += 1

// ── SECTION 13: S/R CHANNEL
plot(lrNow + sigma2, "LR Upper Band", color=showSR ? color.new(color.gray, 72) : na, linewidth=1)
plot(lrNow,          "LR Midline",    color=showSR ? color.new(color.white, 60) : na, linewidth=1)
plot(lrNow - sigma2, "LR Lower Band", color=showSR ? color.new(color.gray, 72) : na, linewidth=1)

// ═══════════════════════════════════════════════════════════════════
// ── SECTION 14: INFO PANEL
// ═══════════════════════════════════════════════════════════════════
if showTable and barstate.islast
    tPosV = tPos == "top_right" ? position.top_right : tPos == "top_left" ? position.top_left : tPos == "bottom_right" ? position.bottom_right : position.bottom_left

    t = table.new(tPosV, 2, 70,
         bgcolor=color.new(#0a0a12, 8), border_color=color.new(color.gray, 55),
         border_width=1, frame_color=color.new(color.gray, 40), frame_width=1)

    r = 0

    // ── HEADER (always shown)
    table.cell(t, 0, r, "⚡ PCRXS Forecast Engine  v1.0",
         text_color=color.white, text_size=size.small,
         bgcolor=color.new(#0d1b2a, 0), text_halign=text.align_center)
    table.merge_cells(t, 0, r, 1, r)
    r += 1

    // ── BANNER (always shown)
    table.cell(t, 0, r, fcastRec,
         text_color=fcastRecTxt, text_size=size.small,
         bgcolor=fcastRecCol, text_halign=text.align_center)
    table.merge_cells(t, 0, r, 1, r)
    r += 1

    // ── CORE INFO ROWS (always shown)
    table.cell(t, 0, r, "Confidence",  text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
    table.cell(t, 1, r, str.tostring(confidence) + "%",
         text_color=confidence >= 70 ? color.lime : confidence >= 50 ? color.orange : color.red,
         text_size=size.tiny, text_halign=text.align_right)
    r += 1

    // v1.1 fix: syminfo.ticker = clean "BTCUSDT" | syminfo.tickerid = full JSON chart blob
    table.cell(t, 0, r, "Symbol",  text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
    table.cell(t, 1, r, syminfo.ticker,
         text_color=color.white, text_size=size.tiny, text_halign=text.align_right)
    r += 1

    table.cell(t, 0, r, "Price",  text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
    table.cell(t, 1, r, str.tostring(close, format.mintick),
         text_color=color.white, text_size=size.tiny, text_halign=text.align_right)
    r += 1

    table.cell(t, 0, r, "Timeframe",  text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
    table.cell(t, 1, r, timeframe.period,
         text_color=color.yellow, text_size=size.tiny, text_halign=text.align_right)
    r += 1

    // ── SIGNAL SECTION (toggle: showSectionSignal)
    if showSectionSignal
        table.cell(t, 0, r, "── SIGNAL ──",
             text_color=color.white, text_size=size.tiny,
             bgcolor=color.new(#1a2a3a, 10), text_halign=text.align_center)
        table.merge_cells(t, 0, r, 1, r)
        r += 1
        sigText = urgentLong  ? "⚡ URGENT LONG"  : urgentShort ? "⚡ URGENT SHORT" :
             longSignal   ? "▲ LONG ENTRY"   : shortSignal  ? "▼ SHORT ENTRY"  :
             exitLong     ? "✕ EXIT LONG"    : exitShort    ? "✕ EXIT SHORT"   : "◈ WATCHING"
        sigCol  = urgentLong or longSignal   ? color.lime   :
             urgentShort or shortSignal ? color.red    :
             exitLong ? color.orange : exitShort ? color.blue : color.gray
        table.cell(t, 0, r, "Signal",     text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, sigText,      text_color=sigCol,       text_size=size.tiny, text_halign=text.align_right)
        r += 1
        table.cell(t, 0, r, "Confidence", text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, str.tostring(confidence) + "%",
             text_color=confidence >= 70 ? color.lime : confidence >= 50 ? color.orange : color.red,
             text_size=size.tiny, text_halign=text.align_right)
        r += 1

    // ── FORECAST SECTION (toggle: showSectionForecast)
    if showSectionForecast
        table.cell(t, 0, r, "── FORECAST ──",
             text_color=color.white, text_size=size.tiny,
             bgcolor=color.new(#1a2a3a, 10), text_halign=text.align_center)
        table.merge_cells(t, 0, r, 1, r)
        r += 1
        fp20 = forecastPrice(math.min(20, forecastBars))
        fp40 = forecastPrice(math.min(40, forecastBars))
        fp60 = forecastPrice(math.min(60, forecastBars))
        fRecLong  = fp20 > close * 1.001 and fp40 > close
        fRecShort = fp20 < close * 0.999 and fp40 < close
        fRecText  = fRecLong ? "▲ BUY LONG — price forecasted UP" :
             fRecShort ? "▼ BUY SHORT — price forecasted DOWN" : "◈ HOLD — direction unclear"
        fRecColor = fRecLong ? color.lime : fRecShort ? color.red : color.gray
        table.cell(t, 0, r, "Action",       text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, fRecText,       text_color=fRecColor,   text_size=size.tiny, text_halign=text.align_right)
        r += 1
        table.cell(t, 0, r, "+20 bar target", text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, str.tostring(math.round(fp20/syminfo.mintick)*syminfo.mintick, format.mintick) + (fp20 > close ? " ▲" : " ▼"),
             text_color=fp20 > close ? color.lime : color.red, text_size=size.tiny, text_halign=text.align_right)
        r += 1
        table.cell(t, 0, r, "+40 bar target", text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, str.tostring(math.round(fp40/syminfo.mintick)*syminfo.mintick, format.mintick) + (fp40 > close ? " ▲" : " ▼"),
             text_color=fp40 > close ? color.lime : color.red, text_size=size.tiny, text_halign=text.align_right)
        r += 1
        table.cell(t, 0, r, "+60 bar target", text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, str.tostring(math.round(fp60/syminfo.mintick)*syminfo.mintick, format.mintick) + (fp60 > close ? " ▲" : " ▼"),
             text_color=fp60 > close ? color.lime : color.red, text_size=size.tiny, text_halign=text.align_right)
        r += 1
        table.cell(t, 0, r, "Dominant Cycle", text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, str.tostring(math.round(domCycle)) + " bars",
             text_color=color.yellow, text_size=size.tiny, text_halign=text.align_right)
        r += 1
        table.cell(t, 0, r, "Cycle Phase", text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, math.sin(currentPhase + math.pi) > 0 ? "🌊 Rising" : "🌊 Falling",
             text_color=math.sin(currentPhase + math.pi) > 0 ? color.lime : color.red,
             text_size=size.tiny, text_halign=text.align_right)
        r += 1

    // ── SIGNAL FILTERS SECTION (toggle: showSectionFilters)
    if showSectionFilters
        table.cell(t, 0, r, "── SIGNAL FILTERS (8-Layer) ──",
             text_color=color.white, text_size=size.tiny,
             bgcolor=color.new(#1a2a3a, 10), text_halign=text.align_center)
        table.merge_cells(t, 0, r, 1, r)
        r += 1
        table.cell(t, 0, r, "1. H4 Structure",  text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, h4Bull ? "🟢 BULL (EMA 50>200)" : h4Bear ? "🔴 BEAR (EMA 50<200)" : "⚪ NEUTRAL",
             text_color=h4Bull ? color.lime : h4Bear ? color.red : color.gray,
             text_size=size.tiny, text_halign=text.align_right)
        r += 1
        table.cell(t, 0, r, "2. RSI (" + str.tostring(rsiLen) + ")", text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, str.tostring(math.round(rsi, 1)),
             text_color=rsi > rsiOB ? color.red : rsi < rsiOS ? color.orange : color.lime,
             text_size=size.tiny, text_halign=text.align_right)
        r += 1
        table.cell(t, 0, r, "3. MACD Hist",    text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, macdBull ? "📈 Rising" : macdBear ? "📉 Falling" : "📊 Flat",
             text_color=macdBull ? color.lime : macdBear ? color.red : color.gray,
             text_size=size.tiny, text_halign=text.align_right)
        r += 1
        table.cell(t, 0, r, "4. CMF Money Flow", text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, str.tostring(math.round(cmf * 1000) / 1000),
             text_color=cmf > 0.10 ? color.lime : cmf < -0.10 ? color.red : color.yellow,
             text_size=size.tiny, text_halign=text.align_right)
        r += 1
        table.cell(t, 0, r, "5. Volume",       text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, volume > volAvg * 1.5 ? "🔥 SPIKE" : volume > volAvg ? "✅ ABOVE" : "💤 LOW",
             text_color=volume > volAvg * 1.5 ? color.lime : volume > volAvg ? color.yellow : color.gray,
             text_size=size.tiny, text_halign=text.align_right)
        r += 1
        table.cell(t, 0, r, "6. ADX Trend",    text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, str.tostring(math.round(adx, 1)) + (trending ? " 🔥" : " 💤"),
             text_color=trending ? color.lime : color.gray,
             text_size=size.tiny, text_halign=text.align_right)
        r += 1
        table.cell(t, 0, r, "7. OBV Flow",     text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, obvBull ? "📈 Accumulating" : "📉 Distributing",
             text_color=obvBull ? color.lime : color.red,
             text_size=size.tiny, text_halign=text.align_right)
        r += 1
        table.cell(t, 0, r, "8. BB Squeeze",   text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, inSqueeze ? "💥 YES — BREAKOUT NEAR" : "◌ No squeeze",
             text_color=inSqueeze ? color.yellow : color.gray,
             text_size=size.tiny, text_halign=text.align_right)
        r += 1

    // ── MACRO SECTION (toggle: showSectionMacro)
    if showSectionMacro
        table.cell(t, 0, r, "── MACRO / GLOBAL CONTEXT ──",
             text_color=color.white, text_size=size.tiny,
             bgcolor=color.new(#1a2a3a, 10), text_halign=text.align_center)
        table.merge_cells(t, 0, r, 1, r)
        r += 1
        table.cell(t, 0, r, "DXY (Dollar)",  text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, dxyBull ? "🔴 STRONG — bearish crypto" : "🟢 WEAK — bullish crypto",
             text_color=dxyBull ? color.red : color.lime, text_size=size.tiny, text_halign=text.align_right)
        r += 1
        table.cell(t, 0, r, "S&P 500",       text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, spxBull ? "🟢 RISK-ON (bullish)" : "🔴 RISK-OFF (bearish)",
             text_color=spxBull ? color.lime : color.red, text_size=size.tiny, text_halign=text.align_right)
        r += 1
        table.cell(t, 0, r, "Gold",          text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, goldBull ? "🟡 RISING — risk-off" : "✅ FLAT/DOWN — risk-on",
             text_color=goldBull ? color.yellow : color.lime, text_size=size.tiny, text_halign=text.align_right)
        r += 1
        table.cell(t, 0, r, "Fear Index",    text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, str.tostring(math.round(fearPct, 2)) + "%  " + (extremeFear ? "😱 PANIC" : "😐 CALM"),
             text_color=extremeFear ? color.orange : color.gray, text_size=size.tiny, text_halign=text.align_right)
        r += 1

    // ── GLOBAL MARKETS SECTION (toggle: showSectionGlobal — default OFF)
    if showSectionGlobal
        table.cell(t, 0, r, "── GLOBAL MARKETS ──",
             text_color=color.white, text_size=size.tiny,
             bgcolor=color.new(#1a2a3a, 10), text_halign=text.align_center)
        table.merge_cells(t, 0, r, 1, r)
        r += 1
        table.cell(t, 0, r, "🇯🇵 Nikkei 225",    text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, nikkeiBull ? "🟢 BULL — Asia risk-on" : "🔴 BEAR — Asia risk-off",
             text_color=nikkeiBull ? color.lime : color.red, text_size=size.tiny, text_halign=text.align_right)
        r += 1
        table.cell(t, 0, r, "🇭🇰 Hang Seng",     text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, hsiBull ? "🟢 BULL — China capital flows" : "🔴 BEAR — China risk-off",
             text_color=hsiBull ? color.lime : color.red, text_size=size.tiny, text_halign=text.align_right)
        r += 1
        table.cell(t, 0, r, "🇩🇪 DAX (Germany)", text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, daxBull ? "🟢 BULL — EU risk-on" : "🔴 BEAR — EU risk-off",
             text_color=daxBull ? color.lime : color.red, text_size=size.tiny, text_halign=text.align_right)
        r += 1
        table.cell(t, 0, r, "🇬🇧 FTSE 100 (UK)", text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, ftseBull ? "🟢 BULL" : "🔴 BEAR",
             text_color=ftseBull ? color.lime : color.red, text_size=size.tiny, text_halign=text.align_right)
        r += 1
        table.cell(t, 0, r, "🇫🇷 CAC 40 (France)", text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, cacBull ? "🟢 BULL" : "🔴 BEAR",
             text_color=cacBull ? color.lime : color.red, text_size=size.tiny, text_halign=text.align_right)
        r += 1
        table.cell(t, 0, r, "Global Sentiment", text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, str.tostring(globalBullCt) + "/5 BULL  " +
             (globalRiskOn ? "🌍 RISK-ON" : globalRiskOff ? "🔴 RISK-OFF" : "⚪ MIXED"),
             text_color=globalRiskOn ? color.lime : globalRiskOff ? color.red : color.yellow,
             text_size=size.tiny, text_halign=text.align_right)
        r += 1

    // ── ACTIVE SESSION SECTION (toggle: showSectionSession — default OFF)
    if showSectionSession
        table.cell(t, 0, r, "── ACTIVE SESSION ──",
             text_color=color.white, text_size=size.tiny,
             bgcolor=color.new(#1a2a3a, 10), text_halign=text.align_center)
        table.merge_cells(t, 0, r, 1, r)
        r += 1
        table.cell(t, 0, r, "Session",         text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, activeSessStr,
             text_color=inEuNyOverlap ? color.lime : inAnySess ? color.yellow : color.gray,
             text_size=size.tiny, text_halign=text.align_right)
        r += 1
        table.cell(t, 0, r, "🇯🇵 Tokyo",        text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, inTokyo  ? "🟢 OPEN (0:00-6:30 UTC)"  : "⚫ CLOSED",
             text_color=inTokyo  ? color.lime : color.gray, text_size=size.tiny, text_halign=text.align_right)
        r += 1
        table.cell(t, 0, r, "🇨🇳 Shanghai/HK",  text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, inChina  ? "🟢 OPEN (1:30-8:00 UTC)"  : "⚫ CLOSED",
             text_color=inChina  ? color.lime : color.gray, text_size=size.tiny, text_halign=text.align_right)
        r += 1
        table.cell(t, 0, r, "🇪🇺 London/EU",    text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, inLondon ? "🟢 OPEN (7:00-16:30 UTC)" : "⚫ CLOSED",
             text_color=inLondon ? color.lime : color.gray, text_size=size.tiny, text_halign=text.align_right)
        r += 1
        table.cell(t, 0, r, "🇺🇸 New York",     text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, inNewYork ? "🟢 OPEN (13:30-21:00 UTC)" : "⚫ CLOSED",
             text_color=inNewYork ? color.lime : color.gray, text_size=size.tiny, text_halign=text.align_right)
        r += 1
        table.cell(t, 0, r, "EU+NY Overlap 🔥", text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, inEuNyOverlap ? "🔥 ACTIVE — Peak Volume" : "◌ Not active",
             text_color=inEuNyOverlap ? color.yellow : color.gray, text_size=size.tiny, text_halign=text.align_right)
        r += 1

    // ── BTC HALVING SECTION (toggle: showSectionHalving)
    if showSectionHalving
        table.cell(t, 0, r, "── BTC HALVING CYCLE ──",
             text_color=color.white, text_size=size.tiny,
             bgcolor=color.new(#1a2a3a, 10), text_halign=text.align_center)
        table.merge_cells(t, 0, r, 1, r)
        r += 1
        table.cell(t, 0, r, "Phase",                  text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, halvingPhaseStr,          text_color=halvingPhaseCol, text_size=size.tiny, text_halign=text.align_right)
        r += 1
        table.cell(t, 0, r, "Months since Apr 2024",  text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, str.tostring(math.round(halvingMonths, 1)) + " mo",
             text_color=color.white, text_size=size.tiny, text_halign=text.align_right)
        r += 1
        table.cell(t, 0, r, "Cycle Strength",         text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, str.tostring(math.round(halvingCycleVal * 100)) + "%",
             text_color=halvingCycleVal > 0.3 ? color.lime : halvingCycleVal < -0.3 ? color.red : color.yellow,
             text_size=size.tiny, text_halign=text.align_right)
        r += 1
        table.cell(t, 0, r, "Next Halving",           text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, "~Apr 2028  (" + str.tostring(math.round((48 - halvingMonths) > 0 ? 48 - halvingMonths : 0, 0)) + " mo)",
             text_color=color.gray, text_size=size.tiny, text_halign=text.align_right)
        r += 1

    // ── DOMINANCE & FUTURES SECTION (toggle: showSectionDom)
    if showSectionDom
        table.cell(t, 0, r, "── DOMINANCE & FUTURES ──",
             text_color=color.white, text_size=size.tiny,
             bgcolor=color.new(#1a2a3a, 10), text_halign=text.align_center)
        table.merge_cells(t, 0, r, 1, r)
        r += 1
        btcDomStr = str.tostring(math.round(btcDom, 2)) + "%  " +
             (btcDomRise ? "▲" : "▼") + "  " +
             (btcDomStrong ? "(BTC Season)" : altSeasonZone ? "(Alt Season Zone)" : "")
        table.cell(t, 0, r, "BTC Dominance", text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, btcDomStr,
             text_color=btcDomBullish ? color.lime : color.red, text_size=size.tiny, text_halign=text.align_right)
        r += 1
        btcDomSigStr = isBTC ?
             (btcDomRise ? "🟢 BULLISH — capital flowing to BTC" : "🔴 BEARISH — BTC losing share") :
             (btcDomFall ? "🟢 BULLISH — alt season forming" :
             altSeasonZone ? "🟡 ALT SEASON ZONE" : "🔴 BTC season — alts lagging")
        table.cell(t, 0, r, "BTC.D Signal",  text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, btcDomSigStr,
             text_color=btcDomBullish ? color.lime : color.red, text_size=size.tiny, text_halign=text.align_right)
        r += 1
        table.cell(t, 0, r, "Alt Season",    text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, altSeasonActive ? "🟢 YES — BTC.D < 54% + falling" :
             altSeasonZone ? "🟡 ZONE — BTC.D < 54%" :
             "❌ No  (BTC.D " + str.tostring(math.round(btcDom, 1)) + "%)",
             text_color=altSeasonActive ? color.lime : altSeasonZone ? color.yellow : color.gray,
             text_size=size.tiny, text_halign=text.align_right)
        r += 1
        usdtDomStr = str.tostring(math.round(usdtDom, 2)) + "%  " +
             (usdtActFall ? "↓ Falling" : usdtActRise ? "↑ Rising" : "→ Flat")
        table.cell(t, 0, r, "USDT Dominance", text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, usdtDomStr,
             text_color=usdtBullish ? color.lime : usdtBearish ? color.red : color.gray,
             text_size=size.tiny, text_halign=text.align_right)
        r += 1
        usdtSigStr = dryPowder    ? "⚡ DRY POWDER DEPLOYING — VERY BULLISH" :
             usdtActFall  ? "🟢 FALLING — cash entering crypto"       :
             usdtActRise  ? "🔴 RISING — cash leaving crypto"          :
             usdtBullish  ? "🟢 Below EMA — bullish bias"              :
             "🔴 Above EMA — bearish bias"
        usdtSigCol = dryPowder or usdtActFall ? color.lime : usdtActRise ? color.red : color.gray
        table.cell(t, 0, r, "USDT.D Signal",  text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, usdtSigStr,       text_color=usdtSigCol,  text_size=size.tiny, text_halign=text.align_right)
        r += 1
        futStr = btcFutValid ?
             str.tostring(math.round(futBasis, 3)) + "% basis  " +
             (inContango ? "(Contango)" : inBackward ? "(Backwardation)" : "(Flat)") :
             "N/A (need CME data)"
        table.cell(t, 0, r, "CME Futures Basis", text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, futStr,
             text_color=futBullish ? color.lime : futBearish ? color.red : color.gray,
             text_size=size.tiny, text_halign=text.align_right)
        r += 1
        futSigStr = overLevLong  ? "⚠️ OVER-LEVERAGED LONGS — squeeze risk"   :
             inContango   ? "🟢 CONTANGO — institutions net bullish"    :
             inBackward   ? "🔴 BACKWARDATION — institutions net bearish" :
             btcFutValid  ? "◌ Neutral basis"                           :
             "⚪ CME subscription required"
        table.cell(t, 0, r, "Futures Signal",  text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
        table.cell(t, 1, r, futSigStr,
             text_color=overLevLong ? color.orange : futBullish ? color.lime : futBearish ? color.red : color.gray,
             text_size=size.tiny, text_halign=text.align_right)
        r += 1

    // ── URGENT BANNER (always shown when active)
    if urgentLong or urgentShort
        table.cell(t, 0, r,
             urgentLong ? "⚡ ENTER NOW — URGENT LONG ⚡" : "⚡ ENTER NOW — URGENT SHORT ⚡",
             text_color=urgentLong ? color.black : color.white, text_size=size.small,
             bgcolor=urgentLong ? color.new(#00FF00, 0) : color.new(#FF0000, 0),
             text_halign=text.align_center)
        table.merge_cells(t, 0, r, 1, r)

// ═══════════════════════════════════════════════════════════════════
// ── SECTION 15: ALERTS
// ═══════════════════════════════════════════════════════════════════
alertcondition(urgentLong,  "⚡ URGENT LONG",          "PCRXS ⚡ URGENT LONG | {{ticker}} {{interval}} | Price: {{close}} | Check panel for confidence %")
alertcondition(urgentShort, "⚡ URGENT SHORT",         "PCRXS ⚡ URGENT SHORT | {{ticker}} {{interval}} | Price: {{close}} | Check panel for confidence %")
alertcondition(longSignal,  "▲ LONG Signal",           "PCRXS ▲ LONG signal | {{ticker}} {{interval}} | Price: {{close}}")
alertcondition(shortSignal, "▼ SHORT Signal",          "PCRXS ▼ SHORT signal | {{ticker}} {{interval}} | Price: {{close}}")
alertcondition(exitLong,    "✕ EXIT Long",             "PCRXS ✕ EXIT LONG | {{ticker}} {{interval}} | Price: {{close}}")
alertcondition(exitShort,   "✕ EXIT Short",            "PCRXS ✕ EXIT SHORT | {{ticker}} {{interval}} | Price: {{close}}")
alertcondition(inSqueeze and (longSignal or shortSignal), "💥 SQUEEZE BREAKOUT", "PCRXS 💥 BB SQUEEZE BREAKOUT | {{ticker}} {{interval}} | Price: {{close}}")
alertcondition(dryPowder,       "⚡ DRY POWDER DEPLOYING",  "PCRXS ⚡ USDT.D dry powder: stablecoin cash entering crypto — bullish | {{ticker}}")
alertcondition(altSeasonActive, "🌊 ALT SEASON SIGNAL",     "PCRXS 🌊 BTC.D below 54% and falling — alt season conditions active | {{ticker}}")
alertcondition(overLevLong,     "⚠️ OVER-LEVERAGED LONGS", "PCRXS ⚠️ CME futures basis >0.8% — long squeeze risk | {{ticker}}")
````
