# Adaptive Equilibrium Deviation Oscillator

- url: https://www.tradingview.com/script/kvboqCOU-Adaptive-Equilibrium-Deviation-Oscillator/
- type: indicator
- pine_id: PUB;f27632d1073541fab33b02a785c2579d
- version: 2.0

## Description

Adaptive Equilibrium Deviation Oscillator (AEDO)

What it is

AEDO is a mean-reversion oscillator. It plots one core reading — the standardized distance between price and its own adaptive equilibrium — and then surrounds that reading with context filters whose only job is to stop the two ways mean-reversion entries usually fail. It is symbol- and timeframe-agnostic: the price source and the optional reference symbols are all selectable in Settings, so it can be applied to any market.

What it plots

The oscillator line: how far price sits from its adaptive equilibrium (an EMA or linear-regression fair value), expressed in standardized units. Zero = at equilibrium; positive = stretched above; negative = stretched below.
Adaptive bands: the threshold beyond which the stretch is treated as "extreme." The bands widen and narrow with volatility, so an extreme reading means the same thing in quiet and busy conditions.
Signal markers: a triangle when the oscillator turns back across a band (a reversion attempt); a small circle for the same event in a less favorable regime.

Divergence lines/labels between the oscillator and price.

A dashboard showing the script name, symbol and timeframe, plus the live equilibrium, volatility state, regime, higher-timeframe bias, confluence grade and a reference fade stop/target.

Why these components are combined (mashup justification)

This is not a collection of independent indicators stacked together. Every part is subordinate to one idea — measure the deviation from equilibrium, and only act on it when the surrounding context supports reversion. Mean-reversion fails in exactly two situations, and each component addresses one of them:

Fading a genuine trend. A stretched oscillator in a strong directional move is a trap, not an opportunity. The ADX regime gate and the higher-timeframe trend filter prevent counter-trend fades, so the oscillator's extremes are only acted on when the market is actually ranging and the bias agrees.
Mistaking a normal pullback for an extreme. A fixed band misreads volatility. The volatility-adaptive bands rescale the "extreme" threshold using either this instrument's own ATR relative to its average, or an optional external volatility index — so the deviation reading keeps a consistent statistical meaning as conditions change. The robust (median/MAD) standardization does the same on the deviation series itself, resisting fat-tailed spikes.

The remaining parts refine confidence in that single reading rather than generating separate signals:

Divergence between price and the oscillator, and a 0–N confluence grade, require independent agreement before a signal is graded as strong.
An optional secondary-symbol spread check (e.g. a future vs. its underlying, or two correlated assets) adds a structural sanity filter; it is off by default and contributes nothing on single-asset charts.
Confirmation filters (confirm-on-close, clearance beyond the band, optional session-open skip) make signals non-repainting and reduce noise.
The calibration tracker logs each signal on past bars and, after a fixed horizon, records whether price actually followed through by a chosen ATR amount — reporting a historical hit-rate with a Wilson 95% confidence interval, binned by confluence grade.

Together they form one decision: price is far from equilibrium → is the context one where reversion is plausible → how much independent agreement is there → how has this exact condition resolved historically. Remove any one piece and the remaining system is measurably more exposed to one of the two failure modes above.
What is original here

The oscillator is built around an adaptive equilibrium with statistically standardized deviation and volatility-scaled bands, rather than a fixed-scale momentum formula.
The confluence grade uses a dynamic denominator, so enabling/disabling the optional spread filter doesn't artificially inflate the grade.
The built-in calibration tracker with Wilson confidence intervals is descriptive transparency: it lets you check, per confluence tier, how the flagged condition resolved on past data before trusting it — a measurement layer most oscillators don't include.

How to use it

Add it to any chart and timeframe. Leave the price source at close to start.
Reversion entries: look for the oscillator turning back across a band (a marker prints). Treat triangles (favorable regime) as higher-quality than circles.
Confluence: the dashboard shows the long/short grade; raise Min confluence to allow signal to filter to only higher-agreement setups.
Volatility: keep "Instrument (self)" for any standalone asset, or switch to "External symbol" and enter a volatility index for your market.
Secondary spread (optional): enable it and enter a related symbol only if a cross-symbol structure check is meaningful for your instrument.
Validate before trusting it: open the Calibration Tracker group, enable Show calibration panel, set Min confluence to 0, and let it accumulate signals. Read the per-tier hit-rates and confidence intervals on your own symbol/timeframe before relying on any signal. A wide or near-50% interval means the condition has no measured reliability on that market.

Settings overview

Price source · equilibrium type & length · standardization mode & window · band levels · volatility source (self/external) & band multipliers · optional secondary-symbol spread · ADX regime & higher-TF trend gate · confirmation filters · confluence & multi-timeframe agreement · divergence · calibration horizon & follow-through · visuals.
Notes / limitations

Mean-reversion logic suits ranging conditions; the gates reduce but do not eliminate trend risk.
Signals confirm on bar close and do not repaint; external-symbol requests use no look-ahead.
After load, the oscillator needs its standardization window (default 200 bars) to warm up; the dashboard "Data" row shows readiness.

Disclaimer

This script is provided for educational and informational purposes only. It is not financial, investment, or trading advice, and it is not a recommendation to buy or sell any instrument. The calibration figures are descriptive statistics of past bars and do not predict future results. Trading involves substantial risk of loss. Test thoroughly and use your own judgment; you are solely responsible for your decisions.

## Source Code

````pine
//@version=6
// ═════════════════════════════════════════════════════════════════════════════
//  Adaptive Equilibrium Deviation Oscillator (AEDO)
//
//  WHAT IT MEASURES
//  A single mean-reversion reading: the standardized distance between price and
//  its own adaptive equilibrium (an EMA or linear-regression fair value). When
//  price stretches far from equilibrium and then turns back, the oscillator
//  crosses a band and a reversion signal is flagged.
//
//  WHY THE PARTS BELONG TO ONE SYSTEM (not a bag of indicators)
//  Mean-reversion entries fail in two specific ways: (a) you fade a genuine
//  trend, and (b) you treat a normal pullback as an extreme. Every component
//  here exists to defend the same core deviation reading against those two
//  failures, and nothing fires on its own:
//   • Equilibrium + standardized deviation  → the core reading.
//   • Volatility-adaptive bands              → keeps "extreme" honest as
//                                              volatility expands/contracts.
//   • Regime gate (ADX) + higher-TF trend    → blocks fades against a trend.
//   • Optional secondary-symbol spread        → structural sanity check.
//   • Divergence + confluence grade           → require agreement before acting.
//   • Confirmation filters                    → non-repainting, no session noise.
//   • Calibration tracker                     → measures, on PAST data, how often
//                                              the flagged condition was followed
//                                              by movement in its direction.
//
//  Works on any symbol and any timeframe. Price source and the (optional)
//  external volatility / secondary symbols are all user-selectable in settings.
//
//  Educational tool. Not financial advice. Past behavior does not predict
//  future results. See the publication description for full usage notes.
// ═════════════════════════════════════════════════════════════════════════════
indicator("Adaptive Equilibrium Deviation Oscillator", shorttitle="AEDO", overlay=false, precision=2,
     max_lines_count=200, max_labels_count=300)

// ─────────────────────────────── Inputs ─────────────────────────────────────
// Core: equilibrium + deviation
gO = "Core — Equilibrium / Deviation"
srcInput     = input.source(close, "Price source", group=gO,
     tooltip="The series the equilibrium and deviation are built from. Default close; you may use hl2, hlc3, etc.")
eqLen = input.int(50,  "Equilibrium length", minval=5, group=gO,
     tooltip="Lookback of the adaptive fair value the oscillator measures distance from.")
useLinReg    = input.bool(true,"Linear-regression equilibrium (else EMA)", group=gO)
atrLen       = input.int(14,  "ATR length (deviation scale)", minval=2, group=gO)
oscMode      = input.string("Robust Z (median/MAD)", "Standardization",
     options=["Raw (ATR units)","Z-Score","Robust Z (median/MAD)"], group=gO,
     tooltip="Raw = deviation in ATR units. Z-Score / Robust standardize it over a rolling window so the bands carry consistent statistical meaning across symbols. Robust (median/MAD) resists fat-tail spikes.")
statLen      = input.int(200, "Standardization window", minval=20, group=gO)
clampVal     = input.float(8.0,"Winsorize raw deviation (± ATR)", minval=1.0, group=gO)

// Bands
gB = "Bands"
bandRaw   = input.float(1.5, "Signal band — Raw mode", group=gB)
bandSig   = input.float(2.0, "Signal band — Z / Robust (σ)", group=gB)
extMult   = input.float(1.6, "Extreme guide = signal ×", minval=1.0, group=gB)

// Volatility-adaptive bands (universal: self ATR, or optional external symbol)
gVOL = "Volatility-Adaptive Bands"
volMode    = input.string("External symbol", "Volatility source",
     options=["Instrument (self)","External symbol"], group=gVOL,
     tooltip="Instrument: bands breathe with THIS symbol's ATR relative to its own average — works on any asset. External: supply a volatility index (e.g. an implied-volatility index for your market) whose level vs its average scales the bands. Default is set for NSE; clear the symbol or switch to Instrument for any other market.")
volSym     = input.symbol("NSE:INDIAVIX", "External volatility symbol (optional)", group=gVOL)
volLen     = input.int(20, "Volatility average length", minval=2, group=gVOL)
bandMinMult= input.float(0.6,"Min band multiplier", minval=0.1, group=gVOL)
bandMaxMult= input.float(2.5,"Max band multiplier", minval=1.0, group=gVOL)

// Optional secondary-symbol spread (e.g. future vs underlying, or two related assets)
gSP = "Secondary-Symbol Spread (optional)"
useSpread   = input.bool(true, "Use a secondary-symbol spread filter", group=gSP,
     tooltip="Compares this symbol to a related one (e.g. a future vs its cash index, or two correlated assets). The % spread acts as a structural 'healthy regime' check feeding the regime shading and confluence grade. Default is set for NSE (future vs spot); turn off or change the symbol for other markets / single-asset use.")
spreadSym    = input.symbol("NSE:NIFTY", "Secondary symbol", group=gSP)
spreadThresh = input.float(0.0, "Healthy spread threshold (%)", step=0.05, group=gSP)

// Trend / regime gate
gR = "Trend / Regime Gate"
useRegime  = input.bool(true, "Suppress fades in strong trends (ADX)", group=gR)
adxLen     = input.int(14, "ADX length", minval=1, group=gR)
adxSmooth  = input.int(14, "ADX smoothing", minval=1, group=gR)
adxThresh  = input.float(25.0, "ADX trend threshold", minval=0, group=gR)
shadeRange = input.bool(true, "Shade ranging background", group=gR)
useHtf     = input.bool(true, "Fade only with the higher-TF trend", group=gR)
htfTf      = input.timeframe("60", "HTF timeframe", group=gR)
htfEmaLen  = input.int(50, "HTF EMA length", minval=1, group=gR)

// Confirmation filters
gC = "Confirmation Filters"
confirmClose = input.bool(true, "Confirm signals on bar close (non-repainting)", group=gC)
flipPersist  = input.bool(true, "Require clearance past the band", group=gC)
flipBuffer   = input.float(0.3, "  clearance beyond band (osc units)", minval=0.0, step=0.1, group=gC)
useSessSkip  = input.bool(true, "Skip first N bars of session (intraday)", group=gC)
sessSkipBars = input.int(3, "  bars to skip", minval=0, maxval=20, group=gC)

// Confluence + MTF
gCF = "Confluence Grade + MTF"
confDivBars  = input.int(15, "Recent-divergence window (bars)", minval=1, group=gCF)
minConfluence= input.int(0, "Min confluence to allow signal (0 = off)", minval=0, maxval=5, group=gCF)
useMtf       = input.bool(true, "Fold 3×/5×/15× agreement into conviction", group=gCF)
mtfEmaLen    = input.int(50, "MTF trend EMA length", minval=1, group=gCF)
mtfBonus     = input.float(0.10, "Conviction bonus when all 3 agree", minval=0.0, maxval=0.3, step=0.05, group=gCF)
mtfMinAgree  = input.int(0, "Min HTF agreement to allow signal (0 = off)", minval=0, maxval=3, group=gCF)

// Divergence
gD = "Divergence"
useDiv      = input.bool(true,  "Detect divergence", group=gD)
showReg     = input.bool(true,  "Regular", inline="dv", group=gD)
showHid     = input.bool(false, "Hidden",  inline="dv", group=gD)
pivL        = input.int(6, "Pivot left",  minval=1, group=gD)
pivR        = input.int(6, "Pivot right", minval=1, group=gD)
minPiv      = input.int(5,  "Min bars between pivots", minval=1, group=gD)
maxPiv      = input.int(60, "Max bars between pivots", minval=5, group=gD)
minGap      = input.float(0.2, "Min osc gap for divergence", minval=0, step=0.1, group=gD)
divCooldown = input.int(10, "Label cooldown (bars)", minval=0, group=gD)

// Calibration
gCAL = "Calibration Tracker (past-only · descriptive)"
calEnable   = input.bool(true, "Log & evaluate signals", group=gCAL)
calShowPanel= input.bool(false,"Show calibration panel", group=gCAL)
calPanelPos = input.string("bottom_right","Panel position",
     options=["top_left","top_right","bottom_left","bottom_right","middle_right"], group=gCAL)
calHorizon  = input.int(10, "Evaluation horizon (bars)", minval=3, maxval=100, group=gCAL)
calMoveATR  = input.float(0.5,"Min follow-through (× ATR) for a hit", minval=0.1, maxval=3.0, step=0.1, group=gCAL)

// Visuals
gVI = "Visuals"
oscStyle  = input.string("Glow", "Oscillator style", options=["Glow","Plain"], group=gVI)
fillMid   = input.bool(true, "Fill oscillator to zero line", group=gVI)
showVolBg = input.bool(true, "Volatility-severity background gradient", group=gVI)
colBull   = input.color(#2ebd85, "Bull / oversold color", group=gVI)
colBear   = input.color(#f6465d, "Bear / overbought color", group=gVI)
showDash  = input.bool(true, "Show dashboard", group=gVI)
dashPos   = input.string("top_right","Dashboard position",
     options=["top_left","top_right","bottom_left","bottom_right","middle_right"], group=gVI)
dashTheme = input.string("Auto (match chart)", "Dashboard theme",
     options=["Auto (match chart)","Dark","Light"], group=gVI,
     tooltip="Auto reads the chart background brightness and keeps the dashboard and calibration panel legible on any theme (light, dark or colored). Dark/Light force a palette regardless of the chart. Cells are fully opaque so the panels never wash out.")
showRisk  = input.bool(true, "Show ATR stop/target row", group=gVI)
atrMult   = input.float(2.0, "Stop = ATR ×", minval=0.1, step=0.1, group=gVI)
rMult     = input.float(2.0, "Target = R ×", minval=0.1, step=0.1, group=gVI)

// ─────────────────────────────── Helpers ────────────────────────────────────
f_pos(s) => s=="top_left"?position.top_left : s=="top_right"?position.top_right : s=="bottom_left"?position.bottom_left : s=="bottom_right"?position.bottom_right : position.middle_right
f_clamp01(x) => math.max(0.0, math.min(1.0, x))
// Wilson 95% CI → [lo,hi]; [na,na] for N<5.
f_wilson(int hits, int total) =>
    float lo = na, float hi = na
    if total >= 5
        float p=hits/float(total), float z=1.96, float den=1.0+z*z/total
        float cen=(p+z*z/(2.0*total))/den
        float hw=z*math.sqrt(p*(1.0-p)/total + z*z/(4.0*total*total))/den
        lo := math.max(0.0, cen-hw)
        hi := math.min(1.0, cen+hw)
    [lo, hi]
f_calBin(int conf) => conf >= 4 ? 2 : conf >= 3 ? 1 : 0
f_tf(mins) => mins<=1.5?"1":mins<=2.5?"2":mins<=4?"3":mins<=7.5?"5":mins<=12.5?"10":mins<=22.5?"15":mins<=37.5?"30":mins<=52.5?"45":mins<=90?"60":mins<=150?"120":mins<=210?"180":mins<=300?"240":mins<=540?"360":mins<=1080?"720":"D"
f_mtfMult(int agree) => agree==3 ? 1.0+mtfBonus : agree==2 ? 1.0 : agree==1 ? 0.8 : 0.6

// ─────────────────────────────── Data ───────────────────────────────────────
float atr = ta.atr(atrLen)

// Core equilibrium + standardized deviation
float fair = useLinReg ? ta.linreg(srcInput, eqLen, 0) : ta.ema(srcInput, eqLen)
float rawDev  = atr > 0 ? (srcInput - fair) / atr : 0.0
float rawDevC = math.max(-clampVal, math.min(clampVal, rawDev))   // winsorized

bool modeRaw = oscMode == "Raw (ATR units)"
bool modeRob = oscMode == "Robust Z (median/MAD)"
bool useStat = not modeRaw

float zMean = ta.sma(rawDevC, statLen)
float zSd   = ta.stdev(rawDevC, statLen)
float zDev  = (not na(zSd) and zSd != 0) ? (rawDevC - zMean) / zSd : 0.0

float med = ta.percentile_linear_interpolation(rawDevC, statLen, 50)
float mad = ta.percentile_linear_interpolation(math.abs(rawDevC - med), statLen, 50)
float robDev = (not na(mad) and mad != 0) ? 0.6745 * (rawDevC - med) / mad : 0.0

float osc = modeRaw ? rawDevC : modeRob ? robDev : zDev

int  warmReq  = math.max(useStat ? statLen : atrLen, eqLen + 1)
bool warmedUp = bar_index >= warmReq

// ───────────────── Volatility-adaptive bands (self or external) ───────────────
bool useExtVol = volMode == "External symbol" and str.length(volSym) > 0
float extVol   = request.security(useExtVol ? volSym : syminfo.tickerid, timeframe.period, close, lookahead=barmerge.lookahead_off)
float volLevel = useExtVol ? extVol : atr
float volAvg   = ta.sma(volLevel, volLen)
float volRatio = (not na(volAvg) and volAvg > 0) ? volLevel / volAvg : 1.0
float volFactor= math.max(bandMinMult, math.min(bandMaxMult, volRatio))
bool  volCalm  = volRatio <= 1.0

float baseLevel = modeRaw ? bandRaw : bandSig
float upperBand = baseLevel * volFactor
float lowerBand = -upperBand
float extUp     = upperBand * extMult
float extDn     = lowerBand * extMult

// ───────────────── Optional secondary-symbol spread ──────────────────────────
bool  spreadActive = useSpread and str.length(spreadSym) > 0
float secClose     = request.security(spreadActive ? spreadSym : syminfo.tickerid, timeframe.period, close, lookahead=barmerge.lookahead_off)
float spreadPct    = (spreadActive and not na(secClose) and secClose > 0) ? (close/secClose - 1.0) * 100.0 : na
bool  spreadHealthy= not spreadActive or (not na(spreadPct) and spreadPct >= spreadThresh)

// ───────────────── Regime + HTF trend gate ───────────────────────────────────
[diP, diM, adxVal] = ta.dmi(adxLen, adxSmooth)
bool trending = adxVal >= adxThresh
bool ranging  = not trending

int htfBias = request.security(syminfo.tickerid, htfTf,
     close > ta.ema(close, htfEmaLen) ? 1 : -1, lookahead=barmerge.lookahead_off)

// Session warmup skip
bool isIntraday = timeframe.in_seconds() < 86400
bool newSession = useSessSkip and isIntraday and ta.change(time("D")) != 0
var int barsIntoSession = 9999
barsIntoSession := newSession ? 1 : barsIntoSession + 1
bool sessionOK = not useSessSkip or not isIntraday or barsIntoSession > sessSkipBars

// ───────────────── MTF agreement (multiplier + optional gate) ─────────────────
f_mbias() => close > ta.ema(close, mtfEmaLen) ? 1 : -1
int tfSec = timeframe.in_seconds()
int m3  = request.security(syminfo.tickerid, f_tf(tfSec*3 /60), f_mbias(), lookahead=barmerge.lookahead_off)
int m5  = request.security(syminfo.tickerid, f_tf(tfSec*5 /60), f_mbias(), lookahead=barmerge.lookahead_off)
int m15 = request.security(syminfo.tickerid, f_tf(tfSec*15/60), f_mbias(), lookahead=barmerge.lookahead_off)
int mtfBullN      = (m3>0?1:0) + (m5>0?1:0) + (m15>0?1:0)
int mtfAgreeLong  = mtfBullN
int mtfAgreeShort = 3 - mtfBullN
float mtfMultLong  = useMtf ? f_mtfMult(mtfAgreeLong)  : 1.0
float mtfMultShort = useMtf ? f_mtfMult(mtfAgreeShort) : 1.0

// Volatility / spread regime
bool calm = volCalm and spreadHealthy

// ───────────────── Divergence (confirmed pivots, decluttered) ─────────────────
float ph = ta.pivothigh(osc, pivL, pivR)
float pl = ta.pivotlow(osc, pivL, pivR)
var float pLosc=na, var float pLpr=na, var int pLbar=na
var float pHosc=na, var float pHpr=na, var int pHbar=na
var int lastBullDiv = -100000
var int lastBearDiv = -100000
bool bullReg=false, bool bullHid=false, bool bearReg=false, bool bearHid=false

if not na(pl)
    float oV = osc[pivR]
    float pV = low[pivR]
    int   bI = bar_index - pivR
    int   gap = bI - nz(pLbar, bI)
    if useDiv and not na(pLosc) and gap >= minPiv and gap <= maxPiv
        bullReg := showReg and (oV > pLosc + minGap) and pV < pLpr   // price LL, osc HL
        bullHid := showHid and (oV < pLosc - minGap) and pV > pLpr   // price HL, osc LL
        if (bullReg or bullHid) and (bI - lastBullDiv) >= divCooldown
            color c = bullReg ? colBull : color.new(colBull, 45)
            line.new(pLbar, pLosc, bI, oV, color=c, width=2)
            label.new(bI, oV, bullReg ? "Bull" : "H-Bull", yloc=yloc.price, style=label.style_label_up, color=color.new(c,78), textcolor=c, size=size.tiny)
            lastBullDiv := bI
    pLosc := oV, pLpr := pV, pLbar := bI

if not na(ph)
    float oV = osc[pivR]
    float pV = high[pivR]
    int   bI = bar_index - pivR
    int   gap = bI - nz(pHbar, bI)
    if useDiv and not na(pHosc) and gap >= minPiv and gap <= maxPiv
        bearReg := showReg and (oV < pHosc - minGap) and pV > pHpr   // price HH, osc LH
        bearHid := showHid and (oV > pHosc + minGap) and pV < pHpr   // price LH, osc HH
        if (bearReg or bearHid) and (bI - lastBearDiv) >= divCooldown
            color c = bearReg ? colBear : color.new(colBear, 45)
            line.new(pHbar, pHosc, bI, oV, color=c, width=2)
            label.new(bI, oV, bearReg ? "Bear" : "H-Bear", yloc=yloc.price, style=label.style_label_down, color=color.new(c,78), textcolor=c, size=size.tiny)
            lastBearDiv := bI
    pHosc := oV, pHpr := pV, pHbar := bI

// ───────────────── Confluence grade ──────────────────────────────────────────
// Spread only contributes when actively enabled, so single-asset use isn't padded.
bool recentBull = (bar_index - lastBullDiv) <= confDivBars
bool recentBear = (bar_index - lastBearDiv) <= confDivBars
int  spreadPts  = (spreadActive and spreadHealthy) ? 1 : 0
int  maxConf    = 4 + (spreadActive ? 1 : 0)
int  longConf   = (htfBias>0?1:0) + (ranging?1:0) + (recentBull?1:0) + (volCalm?1:0) + spreadPts
int  shortConf  = (htfBias<0?1:0) + (ranging?1:0) + (recentBear?1:0) + (volCalm?1:0) + spreadPts
float longConvPct  = f_clamp01(longConf  / float(maxConf) * mtfMultLong)  * 100.0
float shortConvPct = f_clamp01(shortConf / float(maxConf) * mtfMultShort) * 100.0

// ───────────────── Signal construction + gates ───────────────────────────────
bool buyRaw  = ta.crossover(osc, lowerBand)     // snapping back up out of oversold
bool sellRaw = ta.crossunder(osc, upperBand)    // snapping back down out of overbought
bool clearedUp = not flipPersist or (osc >= lowerBand + flipBuffer)
bool clearedDn = not flipPersist or (osc <= upperBand - flipBuffer)
bool sigConfirm = not confirmClose or barstate.isconfirmed

bool longCtx  = (not useHtf or htfBias>0) and (not useRegime or ranging) and sessionOK
bool shortCtx = (not useHtf or htfBias<0) and (not useRegime or ranging) and sessionOK
bool mtfOkLong  = not useMtf or mtfAgreeLong  >= mtfMinAgree
bool mtfOkShort = not useMtf or mtfAgreeShort >= mtfMinAgree

bool longValid  = buyRaw  and clearedUp and longCtx  and warmedUp and sigConfirm and longConf  >= minConfluence and mtfOkLong
bool shortValid = sellRaw and clearedDn and shortCtx and warmedUp and sigConfirm and shortConf >= minConfluence and mtfOkShort

// ───────────────── Visuals — oscillator ──────────────────────────────────────
color baseCol   = osc >= 0 ? colBear : colBull
float intensity = math.min(math.abs(osc) / math.max(extUp, 0.0001), 1.0)
bool  isGlow    = oscStyle == "Glow"

// volatility-severity background gradient (calm → stressed); spread stress nudges it up
float stress = f_clamp01((volRatio - 0.9) / 0.6) + (spreadHealthy ? 0.0 : 0.25)
stress := f_clamp01(stress)
color volBg = color.from_gradient(stress, 0.0, 1.0, color.new(colBull, 92), color.new(colBear, 88))
color regBg = (useRegime and shadeRange and ranging) ? color.new(color.gray, 93) : na
bgcolor(showVolBg ? volBg : regBg, title="Regime / volatility background")

// midline fill (opacity scales with how stretched price is)
pOsc = plot(fillMid ? osc : na, "osc (fill ref)", color=na, display=display.none)
pMid = plot(fillMid ? 0   : na, "mid (fill ref)", color=na, display=display.none)
fill(pOsc, pMid, color = fillMid ? color.new(baseCol, int(math.round(93 - intensity*30))) : na, title="Deviation fill")

// glow + crisp line
plot(isGlow ? osc : na, "Glow outer", color=color.new(baseCol,86), linewidth=8, display=display.pane)
plot(isGlow ? osc : na, "Glow inner", color=color.new(baseCol,66), linewidth=4, display=display.pane)
plot(osc, "AEDO", color=color.new(baseCol,0), linewidth=2, display=display.pane)

// bands + guides
plot(upperBand, "Upper band", color=color.new(colBear,40), style=plot.style_stepline)
plot(lowerBand, "Lower band", color=color.new(colBull,40), style=plot.style_stepline)
plot(extUp, "Extreme +", color=color.new(colBear,70), display=display.pane)
plot(extDn, "Extreme -", color=color.new(colBull,70), display=display.pane)
hline(0, "Equilibrium", color=color.new(color.gray,50), linestyle=hline.style_dotted)

// signal markers — strong (calm regime) vs weak
plotshape(longValid  and calm,      "Strong Buy",  shape.triangleup,   location.bottom, color.new(colBull,0),  size=size.small)
plotshape(longValid  and not calm,  "Weak Buy",    shape.circle,       location.bottom, color.new(colBull,55), size=size.tiny)
plotshape(shortValid and calm,      "Strong Sell", shape.triangledown, location.top,    color.new(colBear,0),  size=size.small)
plotshape(shortValid and not calm,  "Weak Sell",   shape.circle,       location.top,    color.new(colBear,55), size=size.tiny)

// ───────────────── Calibration tracker (Wilson CI, past-only) ─────────────────
var int[]   calTotal  = array.new_int(3, 0)
var int[]   calHit     = array.new_int(3, 0)
var int[]   pendBar    = array.new_int(0)
var float[] pendPrice  = array.new_float(0)
var float[] pendAtr     = array.new_float(0)
var int[]   pendDir     = array.new_int(0)
var int[]   pendBin     = array.new_int(0)

if calEnable and barstate.isconfirmed
    if longValid or shortValid
        array.push(pendBar,   bar_index)
        array.push(pendPrice, close)
        array.push(pendAtr,   atr)
        array.push(pendDir,   longValid ? 1 : -1)
        array.push(pendBin,   f_calBin(longValid ? longConf : shortConf))
    int idx = 0
    while idx < array.size(pendBar)
        if bar_index - array.get(pendBar, idx) >= calHorizon
            float p0 = array.get(pendPrice, idx)
            float a0 = array.get(pendAtr, idx)
            int   dr = array.get(pendDir, idx)
            int   bn = array.get(pendBin, idx)
            float mv = close - p0
            bool  hit = dr == 1 ? mv >= calMoveATR * a0 : mv <= -calMoveATR * a0
            array.set(calTotal, bn, array.get(calTotal, bn) + 1)
            if hit
                array.set(calHit, bn, array.get(calHit, bn) + 1)
            array.remove(pendBar, idx)
            array.remove(pendPrice, idx)
            array.remove(pendAtr, idx)
            array.remove(pendDir, idx)
            array.remove(pendBin, idx)
        else
            idx += 1
    while array.size(pendBar) > 200
        array.shift(pendBar), array.shift(pendPrice), array.shift(pendAtr), array.shift(pendDir), array.shift(pendBin)

int   calTotAll = array.get(calTotal,0)+array.get(calTotal,1)+array.get(calTotal,2)
int   calHitAll = array.get(calHit,0)+array.get(calHit,1)+array.get(calHit,2)
float calRateAll = calTotAll > 0 ? calHitAll/float(calTotAll) : na

// ───────────────── Last-signal tracking + risk context ───────────────────────
var int lastDir=0, var int lastBar=na, var float lastConv=0.0, var int lastConf=0
if longValid
    lastDir:=1, lastBar:=bar_index, lastConv:=longConvPct, lastConf:=longConf
if shortValid
    lastDir:=-1, lastBar:=bar_index, lastConv:=shortConvPct, lastConf:=shortConf

// Reference stop/target for a prospective fade at the current oscillator sign.
int    fadeDir = osc <= lowerBand ? 1 : osc >= upperBand ? -1 : 0
float  riskDist = atrMult * atr
float  stopLvl  = fadeDir==1 ? close - riskDist : fadeDir==-1 ? close + riskDist : na
float  tgtLvl   = fadeDir!=0 ? fair : na   // mean-reversion target = equilibrium

// ───────────────── Data health ───────────────────────────────────────────────
bool feedOk = not na(close) and (not useExtVol or not na(extVol)) and (not spreadActive or not na(secClose))
string healthTxt = not feedOk ? "FEED ✗" : not warmedUp ? "WARMING" : "OK"

// ═════════════════════════════════════════════════════════════════════════════
//  THEME-ADAPTIVE PALETTE (shared by both panels)
//  "Auto" reads the chart background brightness (luma) and flips between a dark
//  and a light scheme so text always has contrast. All cell colors are fully
//  OPAQUE so the panels never wash out against light or colored backgrounds.
// ═════════════════════════════════════════════════════════════════════════════
_uiBg   = chart.bg_color
_uiLuma = na(_uiBg) ? 0.0 : color.r(_uiBg) * 0.299 + color.g(_uiBg) * 0.587 + color.b(_uiBg) * 0.114
uiDark  = dashTheme == "Dark" ? true : dashTheme == "Light" ? false : (na(_uiBg) or _uiLuma < 140)

color cHdr  = uiDark ? color.rgb(13, 27, 42)    : color.rgb(222, 230, 241)   // header background
color cSub  = uiDark ? color.rgb(22, 27, 34)    : color.rgb(233, 237, 242)   // row background
color cTxt  = uiDark ? color.rgb(226, 232, 240) : color.rgb(20, 26, 38)      // primary text
color cDim  = uiDark ? color.rgb(139, 148, 158) : color.rgb(92, 100, 112)    // dim / label text
color uiFrame = uiDark ? color.rgb(42, 52, 88)  : color.rgb(196, 204, 212)   // frame
color uiBord  = uiDark ? color.rgb(26, 34, 56)  : color.rgb(210, 216, 224)   // grid
color uiPanel = uiDark ? color.rgb(10, 14, 26)  : color.rgb(244, 246, 248)   // table background
color uiAcc   = uiDark ? color.rgb(179, 157, 219) : color.rgb(94, 53, 177)   // calibration accent
// Signal colors deepened in light mode so they stay readable on pale cells.
color uiBull = uiDark ? colBull : color.rgb(22, 151, 106)
color uiBear = uiDark ? colBear : color.rgb(210, 45, 68)
color uiWarn = uiDark ? color.rgb(227, 179, 65) : color.rgb(176, 120, 0)
color healthCol = not feedOk ? uiBear : not warmedUp ? uiWarn : uiBull

// ───────────────── Dashboard (shows script name · symbol · timeframe) ─────────
var table dash = table.new(f_pos(dashPos), 2, 10, frame_width=1, border_width=1)

if showDash and barstate.islast
    table.set_bgcolor(dash, uiPanel)
    table.set_frame_color(dash, uiFrame)
    table.set_border_color(dash, uiBord)
    table.cell(dash,0,0,"AEDO · "+syminfo.ticker+" · "+timeframe.period, text_color=cTxt, bgcolor=cHdr, text_size=size.small)
    table.merge_cells(dash,0,0,1,0)

    table.cell(dash,0,1,"Equilibrium", text_color=cDim, text_size=size.tiny, bgcolor=cSub)
    table.cell(dash,1,1,str.tostring(fair,format.mintick)+"  · dev "+str.tostring(osc,"#.##"), text_color=cTxt, text_size=size.tiny, text_halign=text.align_right)

    string sigTxt = lastDir==0 ? "—" : (lastDir>0?"▲ Long":"▼ Short")+" "+str.tostring(lastConv,"0")+"% ("+str.tostring(bar_index-lastBar)+"b)"
    color  sigCol = lastDir>0?uiBull : lastDir<0?uiBear : cDim
    table.cell(dash,0,2,"Signal", text_color=cDim, text_size=size.tiny, bgcolor=cSub)
    table.cell(dash,1,2,sigTxt, text_color=sigCol, text_size=size.tiny, text_halign=text.align_right)

    table.cell(dash,0,3,"Volatility", text_color=cDim, text_size=size.tiny, bgcolor=cSub)
    table.cell(dash,1,3,str.tostring(volRatio,"0.00")+"× "+(useExtVol?"(ext)":"(self)"), text_color=volCalm?uiBull:uiBear, text_size=size.tiny, text_halign=text.align_right)

    table.cell(dash,0,4,"Spread %", text_color=cDim, text_size=size.tiny, bgcolor=cSub)
    table.cell(dash,1,4,spreadActive?str.tostring(spreadPct,"#.###"):"off", text_color=spreadActive?(spreadHealthy?uiBull:uiBear):cDim, text_size=size.tiny, text_halign=text.align_right)

    table.cell(dash,0,5,"Regime", text_color=cDim, text_size=size.tiny, bgcolor=cSub)
    table.cell(dash,1,5,(trending?"Trend ":"Range ")+str.tostring(adxVal,"0")+" · "+(calm?"CALM":"STRESSED"), text_color=calm and ranging?uiBull:uiBear, text_size=size.tiny, text_halign=text.align_right)

    table.cell(dash,0,6,"HTF / MTF", text_color=cDim, text_size=size.tiny, bgcolor=cSub)
    table.cell(dash,1,6,(htfBias>0?"▲":"▼")+" · "+str.tostring(mtfBullN)+"/3 bull", text_color=htfBias>0?uiBull:uiBear, text_size=size.tiny, text_halign=text.align_right)

    table.cell(dash,0,7,"Confluence", text_color=cDim, text_size=size.tiny, bgcolor=cSub)
    table.cell(dash,1,7,"L "+str.tostring(longConf)+" / S "+str.tostring(shortConf)+" /"+str.tostring(maxConf)+(minConfluence>0?" (≥"+str.tostring(minConfluence)+")":""), text_color=cTxt, text_size=size.tiny, text_halign=text.align_right)

    if showRisk
        string rTxt = fadeDir==0 ? "—" : "stop "+str.tostring(stopLvl,format.mintick)+" · →eq "+str.tostring(tgtLvl,format.mintick)
        table.cell(dash,0,8,"Risk (fade)", text_color=cDim, text_size=size.tiny, bgcolor=cSub)
        table.cell(dash,1,8,rTxt, text_color=cTxt, text_size=size.tiny, text_halign=text.align_right)

    table.cell(dash,0,9,"Data", text_color=cDim, text_size=size.tiny, bgcolor=cSub)
    table.cell(dash,1,9,warmedUp?healthTxt:("Warming "+str.tostring(bar_index)+"/"+str.tostring(warmReq)), text_color=healthCol, text_size=size.tiny, text_halign=text.align_right)

// ───────────────── Calibration panel (off by default) ────────────────────────
if calEnable and calShowPanel and barstate.islast
    var table calT = table.new(f_pos(calPanelPos), 4, 6, frame_width=1, border_width=1)
    table.set_bgcolor(calT, uiPanel)
    table.set_frame_color(calT, uiAcc)
    table.set_border_color(calT, uiBord)
    color cH = cHdr, color cR = cSub
    table.cell(calT,0,0,"Calibration (past)", text_color=uiAcc, bgcolor=cH, text_size=size.tiny, text_halign=text.align_left,
         tooltip="Descriptive only. Logs each signal at firing; after "+str.tostring(calHorizon)+" bars checks whether price moved ≥ "+str.tostring(calMoveATR)+"×ATR in the signal direction. This is a historical hit-rate of the flagged condition, NOT a backtest, prediction, or guarantee.")
    table.cell(calT,1,0,"N", text_color=uiAcc, bgcolor=cH, text_size=size.tiny, text_halign=text.align_center)
    table.cell(calT,2,0,"Hit", text_color=uiAcc, bgcolor=cH, text_size=size.tiny, text_halign=text.align_center)
    table.cell(calT,3,0,"95% CI", text_color=uiAcc, bgcolor=cH, text_size=size.tiny, text_halign=text.align_right)
    string[] rowLab = array.from("Low (≤2)","Mid (3)","High (≥4)","All")
    int[] rowTot = array.from(array.get(calTotal,0),array.get(calTotal,1),array.get(calTotal,2),calTotAll)
    int[] rowHit = array.from(array.get(calHit,0),array.get(calHit,1),array.get(calHit,2),calHitAll)
    for r = 0 to 3
        int rt = array.get(rowTot,r)
        int rh = array.get(rowHit,r)
        float rate = rt > 0 ? rh*100.0/rt : na
        [lo, hi] = f_wilson(rh, rt)
        string rateTxt = rt==0 ? "—" : rt<5 ? "warming" : str.tostring(rate,"0")+"%"
        string ciTxt   = na(lo) ? "—" : str.tostring(math.round(lo*100))+"–"+str.tostring(math.round(hi*100))+"%"
        color  rateCol = rt<5 ? cDim : rate>=60 ? uiBull : rate>=50 ? uiWarn : uiBear
        table.cell(calT,0,r+1,array.get(rowLab,r), text_color=cTxt, bgcolor=cR, text_size=size.tiny, text_halign=text.align_left)
        table.cell(calT,1,r+1,str.tostring(rt), text_color=cTxt, bgcolor=cR, text_size=size.tiny, text_halign=text.align_center)
        table.cell(calT,2,r+1,rateTxt, text_color=rateCol, bgcolor=cR, text_size=size.tiny, text_halign=text.align_center)
        table.cell(calT,3,r+1,ciTxt, text_color=cTxt, bgcolor=cR, text_size=size.tiny, text_halign=text.align_right)
    int pendN = array.size(pendBar)
    table.cell(calT,0,5, pendN>0 ? str.tostring(pendN)+" pending · past data only" : "past data only — no forward guarantee", text_color=cDim, bgcolor=cH, text_size=size.tiny, text_halign=text.align_left)
    table.cell(calT,1,5,"", bgcolor=cH)
    table.cell(calT,2,5,"", bgcolor=cH)
    table.cell(calT,3,5,"", bgcolor=cH)
    table.merge_cells(calT,0,5,3,5)

// ───────────────── Alerts ─────────────────────────────────────────────────────
alertcondition(longValid,  "AEDO Long",  "AEDO long (mean-reversion) signal")
alertcondition(shortValid, "AEDO Short", "AEDO short (mean-reversion) signal")
alertcondition(bullReg, "Bullish Divergence", "AEDO regular bullish divergence")
alertcondition(bearReg, "Bearish Divergence", "AEDO regular bearish divergence")

// ───────────────── Data-window exports ────────────────────────────────────────
plot(osc,                                       "EXP_OSC",        color=color.new(color.gray,100), display=display.data_window)
plot(longValid?1:shortValid?-1:0,               "EXP_SIGNAL_DIR", color=color.new(color.gray,100), display=display.data_window)
plot(longValid?longConf:shortValid?shortConf:math.max(longConf,shortConf), "EXP_CONFLUENCE", color=color.new(color.gray,100), display=display.data_window)
plot(bullReg or bullHid?1:bearReg or bearHid?-1:0, "EXP_DIVERGENCE", color=color.new(color.gray,100), display=display.data_window)
plot(adxVal,                                    "EXP_ADX",        color=color.new(color.gray,100), display=display.data_window)
plot(volRatio,                                  "EXP_VOL_RATIO",  color=color.new(color.gray,100), display=display.data_window)
plot(spreadPct,                                 "EXP_SPREAD_PCT", color=color.new(color.gray,100), display=display.data_window)
plot(mtfBullN,                                  "EXP_MTF_BULLS",  color=color.new(color.gray,100), display=display.data_window)
plot(nz(calRateAll,-1),                         "EXP_HIT_RATE",   color=color.new(color.gray,100), display=display.data_window)
````
