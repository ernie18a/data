# Adaptive Stochastic  Calibrated, Regime-Aware & Embedded-Trend

- url: https://www.tradingview.com/script/LwKDmRdV-Adaptive-Stochastic-Calibrated-Regime-Aware-Embedded-Trend/
- type: indicator
- pine_id: PUB;bf8998d619a046c981314c42b53c2128
- version: 2.0

## Description

# STOCH ARC — TradingView Publication Description

> Copy the section between the lines into TradingView's "Description" box when you
> publish. It is written to satisfy the house-rules that caused the previous
> rejection: it states **why** the components are combined and **how they work
> together**, explains **what it does / how / how to use / why it is original**,
> and ends with the required disclaimer. A publishing checklist (clean chart +
> visible symbol/timeframe/name) is at the very bottom — that part is for YOU, do
> not paste it.

---

## Adaptive Stochastic — Calibrated, Regime-Aware & Embedded-Trend (STOCH ARC)

### What it is
A Stochastic oscillator rebuilt so that "overbought/oversold" means something for
the instrument you are actually trading, and so that it stops fading trends. A
classic Stochastic has two well-known failures: the 80/20 levels are arbitrary for
any given symbol, and in a real trend the oscillator **embeds** (pins at an
extreme) and keeps going — so mechanically fading every extreme walks straight
into the move. STOCH ARC addresses both, then wraps a regime filter, a
trend-trail, multi-timeframe agreement and a transparent conviction score around
the result so one panel answers a single question: **fade this extreme, ride the
trend, or stand aside.**

It runs on **any symbol, asset class, timeframe and market** — equities, indices,
futures, FX, crypto, commodities. The raw data source and every external feed are
user-selectable (details under *Settings*), and nothing is hard-coded to a
particular market.

### Why these components are combined (mashup rationale)
This is not a pile of indicators stacked for show. A raw Stochastic only tells you
"price sits high or low inside its recent range" — which is ambiguous between a
range (fade it) and a trend (it embeds and continues). Each layer removes one
specific weakness of the layer before it and feeds the next:

1. **Calibrated OB/OS** — instead of fixed 80/20, the overbought/oversold lines are
   rolling percentiles of the oscillator's *own* recent distribution. "Extreme" now
   means statistically rare **for this symbol on this timeframe**, which is what
   makes the levels portable across markets.
2. **Embedded-trend detector** — counts how long the oscillator stays beyond a
   calibrated band. A pinned oscillator is the signature of a trend, not a
   reversal, so when it is embedded the fade signals are suppressed. This is the
   piece that stops the classic "fade into a trend" mistake.
3. **Low-lag digital smoothing + optional Inverse Fisher Transform** — de-noise the
   %K/%D so the calibration and the crosses react to real turns rather than tick
   noise. (The Inverse Fisher option is off by default because it deliberately
   saturates the oscillator, which flattens the calibrated percentiles.)
4. **Regime engine** — an efficiency-ratio / trend-strength / volatility-cluster
   classifier labels the market Trend / Range / Volatile and decides *which* of the
   two playbooks is live: fade extremes in a range, ride pullbacks in a trend.
5. **Adaptive Trend Trail** — an adaptive moving average wrapped in a
   volatility-scaled trailing band, computed **on the oscillator**. It supplies the
   oscillator's own trend direction and the continuation (ride) trigger, and its
   band width auto-scales with oscillator volatility so it behaves consistently
   across assets.
6. **Multi-timeframe agreement + conviction score with hard vetoes** — higher
   timeframes must not contradict the signal, and a weighted score (stretch,
   embedment, trend-trail alignment, MTF, optional feeds) is gated by hard vetoes
   (e.g. a volatility-index spike or an opposing higher timeframe). The output is a
   single verdict instead of a wall of separate readings.

Each block consumes the output of the previous one; remove any single layer and a
specific, nameable failure of the plain Stochastic comes back. That is the
justification for combining them.

### What it plots
- **Lower pane:** the smoothed %K / %D, the calibrated overbought/oversold bands
  (shaded), the adaptive trend-trail line, a midline and faint 80/20 references,
  embedded-zone shading, and signal/divergence markers on the oscillator.
- **On the price chart:** "context bands" — the oscillator's range projected back
  onto price (rolling high/low are %K 100/0, and the calibrated OB/OS levels mapped
  to price via `low + level% × range`), so you can see at a glance how stretched
  price is. Fade/continuation markers, divergence lines, and a compact dashboard
  with the live numbers (%K/%D, calibrated zone, stretch, trend-trail, embedded
  state, empirical reversal stats, MTF bias, dominant cycle, suggested size and any
  active veto) round it out.

### How it is original
- The overbought/oversold thresholds are **self-calibrating percentiles of the
  symbol's own oscillator distribution**, not fixed 80/20.
- It **explicitly detects embedment** and flips from fading to riding, instead of
  fading every extreme.
- It carries an **empirical reversal-probability tracker** that reports, from this
  symbol's own history, how often a calibrated extreme actually reversed — so the
  zones are accountable rather than assumed.
- The whole thing resolves to **one regime-aware verdict with hard vetoes**, rather
  than leaving you to reconcile several separate sub-indicators by eye.

### How to use it
1. Add it to any chart and timeframe. Read the **VERDICT / MODE** rows on the
   dashboard first.
2. In a **Range** regime, the engine looks to **fade** calibrated extremes
   (oscillator beyond the OB/OS band while not embedded), confirmed by a %K/%D cross
   and/or divergence.
3. In a **Trend** regime, it looks to **ride** — a trend-trail cross or a shallow
   pullback in the trend direction; fades are suppressed while the oscillator is
   embedded.
4. Treat the conviction score and any active **VETO** as a filter: low conviction or
   an active veto means stand aside. The suggested size is an ATR-based reference for
   journaling, not an order.
5. Use the alerts (fade/ride, %K/%D cross, trend-trail cross, divergence) to be
   notified instead of watching.

### Settings (use on any asset / market)
- **Raw data source** — `close`, `hl2`, `hlc3`, `ohlc4`, or point it at **another
  indicator's plot**. This is what makes the script work on any instrument or as a
  smoother/filter on top of your own series.
- **Stochastic source** — Price (classic Stochastic) or RSI (StochRSI).
- **Smoother** — Low-lag / 2-pole / SMA, with an optional roofing pre-filter and an
  optional Inverse Fisher Transform.
- **Calibration** — overbought/oversold percentiles and the lookback used to learn
  the symbol's distribution.
- **Regime / trend-trail / conviction weights** — all exposed if you want to tune.
- **Optional feeds (blank = off):** a *volatility-index symbol* (for a spike veto)
  and a *cross-asset symbol* (for confluence). Both are blank by default so the
  script is fully self-contained on any market; fill them only if you want them.

### Notes
- It is a **study / indicator**, not a strategy, and it places no orders.
- Signals are evaluated on bar close by default to avoid intrabar repainting of the
  alerts; higher-timeframe reads use confirmed values.

---

### Disclaimer
This script is provided for educational and informational purposes only. It is a
technical-analysis study, not financial, investment, or trading advice, and not a
recommendation or solicitation to buy or sell any instrument. No indicator can
predict markets; past behaviour and any historical statistics shown do not
guarantee future results. Trading involves substantial risk of loss. You are
solely responsible for your own decisions — do your own research and consider
consulting a licensed financial professional before trading. The author accepts no
liability for any loss arising from use of this script.

## Source Code

````pine
// =============================================================================
// Adaptive Stochastic — Calibrated, Regime-Aware & Embedded-Trend  Pine Script v6
// shorttitle: STOCH ARC
// -----------------------------------------------------------------------------
// UPDATE — HONESTY & CALIBRATION
//   [CAL-1] New "Signal-edge" table: every resolved LONG/SHORT trigger is scored
//           forward over a horizon and bucketed by the conviction tier it carried
//           (S/A/B), showing win-rate, a 95% Wilson lower bound and the matched base
//           rate. This finally PROVES (or disproves) what the 0-100 conviction
//           asserts — that higher conviction wins more often here. Non-repainting:
//           scored only after the horizon elapses, on closed bars.
//   [CAL-2] New optional "Evidence-weighted conviction" (default OFF): the acted
//           conviction is scaled by how reliably its tier has actually performed —
//           bounded 0.6-1.2x, only once a tier has enough resolved signals. The table
//           always buckets by the CLASSIC tier, so the loop can never feed on itself.
//   [CAL-3] The existing OB/OS reversion "edge stat" now shows a MATCHED BASE RATE
//           and a Wilson lower bound, so a reversion rate is judged against chance,
//           not shown in a vacuum.
//   Non-repaint discipline, the regime/embed/trail engines and every signal rule are
//   unchanged; the calibration reads a bar late, so there is no same-bar feedback.
// -----------------------------------------------------------------------------
// BUILD UPDATE — ROBUSTNESS, SPEED & TREND-READABLE VISUALS (from a full audit)
//   [FIX-1] The OB/OS reversion "edge stat" used integer division (obRev/obEv), so
//           the displayed reversion rate collapsed to 0% or 100%. Now a true
//           fractional rate, and the CAL-3 Wilson lower bound is actually rendered
//           beside it (it was described but never shown).
//   [FIX-2] The calibration window is capped to the history buffer, so it can no
//           longer be set past max_bars_back and throw a runtime offset error.
//   [SPEED] Every default-OFF heavy path (roofing pre-filter, composite Stochastic,
//           Inverse Fisher, variance-ratio, SNR) now computes only when its feature
//           is on, and the smoother selection evaluates just the chosen filter
//           instead of all three — several ta.*/loop evaluations per bar removed
//           with no change to any output. A dead percentile-SMA chain was deleted.
//   [VIS]   Embedded-zone shading now reads as the TREND it marks (uptrend teal,
//           downtrend red — previously inverted); signal-marker opacity scales with
//           conviction so strong signals stand out; and an optional %K-vs-midline
//           momentum fill (default OFF) gives a continuous at-a-glance momentum read.
//   [TIDY]  Dashboard action reads LONG/SHORT (was BUY/SELL) to stay unambiguously a
//           study, not advice. No default numbers or signal logic changed.
// -----------------------------------------------------------------------------
// Most Stochastic tools plot %K/%D with fixed 80/20 lines and a fixed length,
// then fade every extreme. That fails twice: 80/20 are arbitrary for the
// instrument, and in a real trend the Stochastic "embeds" (pins at an extreme)
// so fading it walks straight into the move. STOCH ARC fixes both. It calibrates
// the overbought/oversold levels to the symbol's OWN distribution, detects when
// the oscillator is embedded (a trend, not a reversal), tracks oscillator trend
// with a volatility-adaptive trailing-trend filter, and lets a regime engine
// decide whether to FADE an extreme or RIDE the trend. Works on ANY symbol /
// timeframe / market; the raw data source and all optional feeds are
// user-selectable.
//
// WHY THESE PIECES ARE COMBINED (mashup rationale):
//   A raw Stochastic only says "price sits high/low in its recent range." Alone
//   that is ambiguous between a range (fade it) and a trend (it embeds and keeps
//   going). Each layer here removes a specific weakness and feeds the next:
//   CALIBRATED OB/OS make "extreme" mean statistically rare for THIS symbol; the
//   EMBEDDED detector recognises a pinned oscillator as a trend and suppresses
//   fades; low-lag digital smoothing and an optional Inverse Fisher Transform
//   de-noise and sharpen the turns; a REGIME engine switches between fading and
//   riding; an ADAPTIVE TREND-TRAIL line (an adaptive moving average wrapped in a
//   volatility-scaled trailing band) supplies the oscillator's trend and the
//   continuation signal; MTF + a CONVICTION score with hard vetoes fold it all
//   into one decision. None is decorative.
//
// This is a study/indicator, not a strategy and not financial advice.
// =============================================================================

//@version=6
indicator("Adaptive Stochastic — Calibrated, Regime-Aware & Embedded-Trend", shorttitle="STOCH ARC", overlay=false,
     max_lines_count=200, max_labels_count=200, max_bars_back=600, precision=2)

// =============================================================================
// HELPERS  (UDFs may only use their args + built-ins, never globals)
// =============================================================================
f_clamp(x, lo, hi) => math.max(lo, math.min(hi, x))
// Wilson score-interval lower bound (95%) — honest worst-plausible rate for w wins
// in n trials. Small samples are punished automatically. na if n=0.
f_wilsonLB(int w, int n) =>
    if n <= 0
        float(na)
    else
        p = w / float(n)
        z = 1.959964
        z2 = z * z
        (p + z2 / (2.0 * n) - z * math.sqrt(p * (1.0 - p) / n + z2 / (4.0 * n * n))) / (1.0 + z2 / n)
chk(b)  => b ? "✓" : "✗"
sgn(x)  => x >= 0 ? "+" : ""
f_pos(s) => s=="top_left"?position.top_left : s=="bottom_right"?position.bottom_right : s=="bottom_left"?position.bottom_left : position.top_right
f_fetch(sym) => request.security(sym, timeframe.period, close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

// EMA that accepts a SERIES length (ta.ema needs a simple int).
f_aema(src, len) =>
    a = 2.0 / (math.max(len, 1) + 1)
    var float e = na
    e := na(e[1]) ? src : e[1] + a * (src - e[1])
    e

// Rolling highest(hi) / lowest(lo) over a SERIES length (so adaptive length works).
f_rollhl(hi, lo, n) =>
    int nn = int(math.max(1, math.min(n, 500)))
    float hh = -1.0e20
    float ll =  1.0e20
    for i = 0 to nn - 1
        hh := math.max(hh, nz(hi[i], hi))
        ll := math.min(ll, nz(lo[i], lo))
    [hh, ll]

// Two-pole low-lag smoother.
f_ss(src, len) =>
    a1 = math.exp(-1.414 * math.pi / math.max(len, 1))
    b1 = 2.0 * a1 * math.cos(1.414 * math.pi / math.max(len, 1))
    c2 = b1
    c3 = -a1 * a1
    c1 = 1.0 - c2 - c3
    var float o = na
    o := c1 * (src + nz(src[1], src)) / 2.0 + c2 * nz(o[1], src) + c3 * nz(o[2], src)
    o

// Low-lag smoother — near-zero-lag low-pass.
f_ult(src, len) =>
    a1 = math.exp(-1.414 * math.pi / math.max(len, 1))
    b1 = 2.0 * a1 * math.cos(1.414 * math.pi / math.max(len, 1))
    c2 = b1
    c3 = -a1 * a1
    c1 = (1.0 + c2 - c3) / 4.0
    var float o = na
    o := bar_index < 4 ? src : (1.0 - c1) * src + (2.0 * c1 - c2) * nz(src[1], src) - (c1 + c3) * nz(src[2], src) + c2 * nz(o[1], src) + c3 * nz(o[2], src)
    o

// Two-pole high-pass (for the optional roofing filter).
f_hp(src, len) =>
    ang = 0.707 * 2.0 * math.pi / math.max(len, 1)
    alpha = (math.cos(ang) + math.sin(ang) - 1.0) / math.cos(ang)
    var float hp = na
    hp := bar_index < 4 ? 0.0 : math.pow(1.0 - alpha/2.0, 2) * (src - 2.0*nz(src[1],src) + nz(src[2],src)) + 2.0*(1.0-alpha)*nz(hp[1],0.0) - math.pow(1.0-alpha,2)*nz(hp[2],0.0)
    hp

// CMO-scaled adaptive moving average — the MA inside the trend-trail filter.
f_vidya(src, len) =>
    int nn = int(math.max(2, math.min(len, 200)))
    float up = 0.0
    float dn = 0.0
    for i = 0 to nn - 1
        d = nz(src[i], src) - nz(src[i+1], src[i])
        if d > 0
            up += d
        else
            dn += -d
    cmo = (up + dn) == 0.0 ? 0.0 : math.abs((up - dn) / (up + dn))
    al = 2.0 / (nn + 1)
    var float v = na
    v := na(v[1]) ? src : al * cmo * src + (1.0 - al * cmo) * nz(v[1], src)
    v

// =============================================================================
// INPUTS
// =============================================================================
gCore   = "Core · Source & Engine"
src_in  = input.source(close, "Raw data source", group=gCore, tooltip="The raw series the engine runs on. Pick close / hl2 / hlc3 / ohlc4 or point it at ANOTHER indicator's plot. Works on any symbol, asset class or market.")
stochSrc= input.string("Price", "Stochastic source", options=["Price","RSI (StochRSI)"], group=gCore, tooltip="Price = classic Stochastic. RSI = StochRSI (Stochastic of RSI), more sensitive.")
rsiLen  = input.int   (14, "  RSI length (StochRSI)", minval=2, maxval=100, group=gCore)
stochLen= input.int   (14, "Stochastic length", minval=2, maxval=200, group=gCore)
useAdaptLen=input.bool (false, "Adaptive length (dominant cycle)", group=gCore, tooltip="Retune the lookback to the market's measured half-cycle instead of a fixed value.")
adaptMin= input.int   (8,  "  Adaptive min", minval=4, maxval=100, group=gCore)
adaptMax= input.int   (40, "  Adaptive max", minval=8, maxval=200, group=gCore)
adaptMlt= input.float (0.5,"  Adaptive cycle x", minval=0.25, maxval=2.0, step=0.05, group=gCore)

gSm     = "Smoothing · DSP"
smoothMode=input.string("Low-lag", "%K / %D smoother", options=["Low-lag","2-pole","SMA"], group=gSm, tooltip="Low-lag = near-zero-lag digital low-pass. 2-pole = classic two-pole smoother. SMA = simple moving average.")
smoothK = input.int   (3, "%K smoothing", minval=1, maxval=50, group=gSm)
smoothD = input.int   (3, "%D smoothing", minval=1, maxval=50, group=gSm)
useIFT  = input.bool  (false, "Inverse Fisher Transform (sharpen turns)", group=gSm, tooltip="Sharpens turns by pushing %K toward the rails. NOTE: it saturates the oscillator, which flattens the calibrated OB/OS percentiles — leave OFF if you rely on the calibrated zones (headline feature).")
useRoof = input.bool  (false, "Roofing pre-filter", group=gSm, tooltip="High-pass + smoother applied to the source before the Stochastic, removing very slow drift.")
roofHP  = input.int   (48, "  Roofing high-pass period", minval=10, maxval=200, group=gSm)
roofSS  = input.int   (10, "  Roofing smooth period", minval=2, maxval=50, group=gSm)
useComp = input.bool  (false, "Composite multi-length (robust)", group=gSm, tooltip="Average Stochastics across several lengths so the output is not hostage to one lookback.")

gOB     = "Calibrated OB / OS"
calLen  = input.int   (250, "Calibration window", minval=50, maxval=500, group=gOB, tooltip="Window used to learn this symbol's own overbought/oversold percentiles. Capped at 500 to stay within the history buffer (max_bars_back=600); 250–500 is ample for a stable percentile.")
obPct   = input.float (85, "Overbought percentile", minval=55, maxval=99, step=1, group=gOB)
osPct   = input.float (15, "Oversold percentile", minval=1, maxval=45, step=1, group=gOB)
showFixed=input.bool  (true, "Show faint 80 / 20 reference", group=gOB)
revLook = input.int   (10, "Reversal lookahead (edge stat)", minval=2, maxval=50, group=gOB)

gEmb    = "Embedded Trend Engine"
embedBars=input.int   (5, "Embedded streak (bars beyond band)", minval=2, maxval=30, group=gEmb, tooltip="Consecutive bars %K stays beyond the OB/OS band before it is treated as an embedded TREND (fades suppressed).")

gSig    = "Signals · Divergence"
pvL     = input.int (5, "Divergence pivot left", minval=2, maxval=20, group=gSig)
pvR     = input.int (3, "Divergence pivot right", minval=1, maxval=10, group=gSig)

gReg    = "Regime"
erLen   = input.int   (14,   "Efficiency-ratio length", minval=4, maxval=50, group=gReg)
adxLen  = input.int   (14,   "ADX length", minval=4, maxval=50, group=gReg)
adxTrd  = input.float (20.0, "ADX trend threshold", minval=10, maxval=40, group=gReg)
erTrd   = input.float (0.35, "ER trend threshold", minval=0.1, maxval=0.9, step=0.01, group=gReg)
clustDecay   = input.float (0.20, "Volatility-cluster decay", minval=0.02, maxval=0.9, step=0.01, group=gReg, tooltip="Decay of the self-exciting volatility-cluster intensity. Lower = longer memory.")
clustThr = input.float (1.5,  "Vol-cluster z threshold", minval=0.5, maxval=4.0, step=0.1, group=gReg)
regMaLn = input.int   (50,   "Regime trend MA", minval=10, maxval=200, group=gReg)
normLen = input.int   (100,  "Normalization window", minval=20, maxval=500, group=gReg)
useVR   = input.bool  (false, "Variance-ratio mean-reversion test", group=gReg, tooltip="Statistical check: <1 = mean-reverting (favors fades), >1 = trending (favors rides).")
vrLen   = input.int   (20,   "  Variance-ratio window", minval=5, maxval=100, group=gReg)
useSNR  = input.bool  (false, "Signal-to-noise chop gate", group=gReg, tooltip="Suppress signals when the cycle swing is small relative to noise (dead/choppy market).")
snrMin  = input.float (1.0,  "  Min SNR to act", minval=0.2, maxval=5.0, step=0.1, group=gReg)

gOtt    = "Adaptive Trend Trail"
useOtt  = input.bool  (true, "Enable adaptive trend-trail line", group=gOtt)
ottLen  = input.int   (5,    "Trail length (adaptive MA)", minval=2, maxval=100, group=gOtt)
ottPct  = input.float (0.8,  "Trail band percent", minval=0.1, maxval=10.0, step=0.1, group=gOtt)
ottAdapt= input.bool  (true, "Volatility-adaptive trail percent", group=gOtt, tooltip="Scale the trail band with recent %K volatility so it behaves consistently across assets and markets.")

gCyc    = "Cycle-Phase Gate"
usePhase= input.bool  (true, "Cycle-phase gate (act near trough/peak)", group=gCyc, tooltip="Only take fades/turns when the measured dominant cycle is near a trough (longs) or peak (shorts).")

gMtf    = "MTF · Confluence"
useMtf  = input.bool  (true, "Enable MTF zone agreement", group=gMtf)
tf1     = input.timeframe("5",  "TF 1", group=gMtf)
tf2     = input.timeframe("15", "TF 2", group=gMtf)
tf3     = input.timeframe("60", "TF 3", group=gMtf)
tf4     = input.timeframe("240","TF 4", group=gMtf)
minAlign= input.int   (3,    "Min TF agreement (else veto)", minval=1, maxval=4, group=gMtf)
htfTf   = input.timeframe("D", "Higher timeframe (gate)", group=gMtf)
useHtfGate=input.bool (true, "Higher-TF bias gate (block counter-trend rides)", group=gMtf)
confirmClose=input.bool(true,"Confirm signals on bar close (no repaint)", group=gMtf)

gCon    = "Conviction"
minConv = input.int   (50,   "Min conviction to act", minval=0, maxval=100, group=gCon)
wStretch= input.float (26,   "Weight: calibrated stretch", group=gCon)
wReg    = input.float (16,   "Weight: regime fit", group=gCon)
wEmb    = input.float (14,   "Weight: embedment / trend-trail", group=gCon)
wMtf    = input.float (16,   "Weight: MTF agreement", group=gCon)
wDiv    = input.float (12,   "Weight: divergence", group=gCon)
wVol    = input.float (8,    "Weight: volume / CVD", group=gCon)
wXa     = input.float (8,    "Weight: cross-asset", group=gCon)

gCal    = "Honesty & Calibration"
cal_show    = input.bool(true, "Show signal-edge table", group=gCal, tooltip="Forward-resolved hit-rate of the LONG/SHORT signals bucketed by conviction tier (S/A/B), with a 95% Wilson lower bound vs the matched base rate. Answers whether higher-conviction signals actually win more often on THIS symbol/timeframe. Non-repainting: each signal is scored only after its horizon fully elapses on closed bars.")
cal_horizon = input.int(10, "  Forward horizon (bars)", minval=1, maxval=200, group=gCal, tooltip="How many bars ahead each signal is scored. Counted only once this many bars have fully elapsed, so the stats never use future data.")
cal_min     = input.int(8,  "  Min resolved signals per tier", minval=3, maxval=100, group=gCal, tooltip="A tier is only reported (and only eligible to influence evidence weighting) once it has this many resolved signals.")
cal_pos     = input.string("bottom_right", "  Table position", options=["top_right","top_left","bottom_right","bottom_left"], group=gCal)
evidence_on = input.bool(false, "Evidence-weighted conviction", group=gCal, tooltip="OFF (default): the classic hand-set weights, unchanged. ON: the acted conviction is scaled by how reliably its tier has actually performed here — above-base tiers keep/boost, below-base tiers are discounted — bounded 0.6-1.2x and only once a tier has enough resolved signals. The table always buckets by the CLASSIC tier, so the loop can never feed on itself.")
ev_gain     = input.float(1.5, "  Evidence sensitivity", minval=0.5, maxval=3.0, step=0.1, group=gCal, tooltip="How strongly the measured tier edge scales conviction in Evidence-weighted mode.")

gRisk   = "Risk Context (dashboard / alerts)"
atrLen  = input.int   (14,   "ATR length", minval=4, maxval=50, group=gRisk)
atrMult = input.float (1.5,  "ATR stop x (context only)", minval=0.5, maxval=5.0, step=0.1, group=gRisk)
equity  = input.float (1000000, "Account equity", group=gRisk, tooltip="Account size in the instrument's currency; only used to suggest a size.")
riskPct = input.float (1.0,  "Risk % per trade", minval=0.1, maxval=10, step=0.1, group=gRisk)
ptValue = input.float (1.0,  "Value per 1.0 price move (per contract)", minval=0.01, group=gRisk)

gData   = "Optional Reference Feeds (degrade gracefully)"
ltfRes  = input.timeframe("1", "Intrabar resolution (CVD)", group=gData)
vixSym  = input.symbol("", "Volatility-index symbol (optional)", group=gData, tooltip="Optional. Enter your market's volatility index for a spike veto. Blank = off.")
vixLen  = input.int   (50, "  VIX z window", minval=10, maxval=200, group=gData)
vixSpk  = input.float (1.5,"  VIX spike z (veto fades)", minval=0.5, maxval=4.0, step=0.1, group=gData)
xaSym   = input.string("", "Cross-asset symbol (optional)", group=gData, tooltip="Optional. Correlated/inverse instrument for confluence. Set the sign below. Blank = off.")
xaSign  = input.int   (1,  "  Cross-asset correlation sign", options=[1,-1], group=gData)
xaLen   = input.int   (10, "  Cross-asset momentum lookback", minval=2, maxval=50, group=gData)

gVis    = "VIS · Display"
showK   = input.bool  (true, "Plot %K", group=gVis)
showD   = input.bool  (true, "Plot %D", group=gVis)
showOttLine=input.bool(true, "Plot trend-trail line", group=gVis)
showBandsFill=input.bool(true,"Fill dynamic OB/OS bands", group=gVis)
showEmbZone=input.bool(true, "Shade embedded zones", group=gVis)
showMomFill=input.bool(false,"Momentum fill (%K vs midline)", group=gVis, tooltip="Optional: fills between %K and the 50 midline — teal when %K is above 50 (bullish momentum), red below (bearish), deeper as %K stretches from the midline. A continuous at-a-glance momentum read; OFF by default to keep the pane clean.")
convMarker =input.bool(true, "Scale marker opacity by conviction", group=gVis, tooltip="When ON (default), signal triangles/diamonds are drawn more solid the higher the conviction score, so a strong (S-tier) signal visually stands out from a weak one. OFF = every marker fully opaque.")
showSignals=input.bool(true, "Fade / continuation markers on PRICE", group=gVis)
showDivLines=input.bool(true,"Divergence as lines on price", group=gVis)
divKeep = input.int   (6, "  Divergence lines to keep on chart", minval=1, maxval=30, group=gVis)
showPxBands=input.bool(true, "Price context bands (project stoch range)", group=gVis, tooltip="Draws the oscillator range on price: rolling high/low = %K 100/0, and the calibrated OB/OS levels mapped to price (low + level%·range). Shows at a glance how stretched price is.")
pxBandFill=input.bool(true, "  Fill extreme zones (price bands)", group=gVis)
showTbl = input.bool  (true, "Show dashboard", group=gVis)
compactTbl=input.bool (true, "Compact dashboard (off = full)", group=gVis)
showLegend=input.bool (false,"Show legend in dashboard", group=gVis)
tblPos  = input.string("top_right", "Dashboard position", options=["top_right","top_left","bottom_right","bottom_left"], group=gVis)
tblTheme= input.string("Auto", "Dashboard theme", options=["Auto","Dark","Light"], group=gVis)
showId  = input.bool  (true, "Show name / symbol / timeframe label", group=gVis)

// =============================================================================
// L1b — DOMINANT CYCLE (homodyne discriminator) + cycle phase
// =============================================================================
hl2src = (high + low) / 2.0
var float Period = 12.0
Smooth = (4*hl2src + 3*hl2src[1] + 2*hl2src[2] + hl2src[3]) / 10.0
adjc = (0.075*Period + 0.54)
Detr = (0.0962*Smooth + 0.5769*nz(Smooth[2]) - 0.5769*nz(Smooth[4]) - 0.0962*nz(Smooth[6])) * adjc
Q1   = (0.0962*Detr + 0.5769*nz(Detr[2]) - 0.5769*nz(Detr[4]) - 0.0962*nz(Detr[6])) * adjc
I1   = nz(Detr[3])
jI   = (0.0962*I1 + 0.5769*nz(I1[2]) - 0.5769*nz(I1[4]) - 0.0962*nz(I1[6])) * adjc
jQ   = (0.0962*Q1 + 0.5769*nz(Q1[2]) - 0.5769*nz(Q1[4]) - 0.0962*nz(Q1[6])) * adjc
var float I2 = 0.0
var float Q2 = 0.0
I2 := 0.2*(I1 - jQ) + 0.8*nz(I2[1])
Q2 := 0.2*(Q1 + jI) + 0.8*nz(Q2[1])
var float Re = 0.0
var float Im = 0.0
Re := 0.2*(I2*nz(I2[1]) + Q2*nz(Q2[1])) + 0.8*nz(Re[1])
Im := 0.2*(I2*nz(Q2[1]) - Q2*nz(I2[1])) + 0.8*nz(Im[1])
float pNew = Period
if Im != 0 and Re != 0
    pNew := 2.0 * math.pi / math.abs(math.atan(Im / Re))
pNew := f_clamp(pNew, 0.67*Period, 1.5*Period)
pNew := f_clamp(pNew, 6.0, 50.0)
Period := 0.2*pNew + 0.8*Period
domCycle = Period
// Cycle-phase proxy: detrended price below/above 0 and turning = trough/peak
cycRising = Detr >= nz(Detr[1], Detr)
phaseLongOK  = not usePhase or (Detr <= 0 and cycRising)
phaseShortOK = not usePhase or (Detr >= 0 and not cycRising)

// =============================================================================
// L1 — STOCHASTIC ENGINE (source, optional roofing, smoothing, IFT, composite)
// =============================================================================
volNz = nz(volume, 0.0)
volLive = ta.cum(volNz) > 0
atr = ta.atr(atrLen)

rsiSeries = ta.rsi(src_in, rsiLen)
baseRaw = stochSrc == "Price" ? src_in : rsiSeries
roofed  = f_ss(f_hp(baseRaw, roofHP), roofSS)
baseSrc = useRoof ? roofed : baseRaw
usePLR  = stochSrc == "Price" and not useRoof
hiSrc = usePLR ? high : baseSrc
loSrc = usePLR ? low  : baseSrc
valSrc = usePLR ? src_in : baseSrc

int lenUse = useAdaptLen ? int(f_clamp(math.round(domCycle * adaptMlt), adaptMin, adaptMax)) : stochLen
[hh, ll] = f_rollhl(hiSrc, loSrc, lenUse)
rawK = (hh - ll) == 0 ? 50.0 : (valSrc - ll) / (hh - ll) * 100.0
// composite multi-length — the two extra rolling-hilo scans only run when the
// composite mode is enabled (default OFF), saving ~35 loop iterations per bar.
float kA = na
float kB = na
if useComp
    [hA, lA] = f_rollhl(hiSrc, loSrc, int(math.max(2, lenUse*0.5)))
    [hB, lB] = f_rollhl(hiSrc, loSrc, int(lenUse*2))
    kA := (hA - lA) == 0 ? 50.0 : (valSrc - lA)/(hA - lA)*100.0
    kB := (hB - lB) == 0 ? 50.0 : (valSrc - lB)/(hB - lB)*100.0
rawKuse = useComp ? (kA + rawK + kB) / 3.0 : rawK

// smoothing (compute all, select; built-in ta.* must be called every bar for
// consistency, so they stay out of any conditional)
smaK = ta.sma(rawKuse, smoothK)
ssK  = f_ss(rawKuse, smoothK)
ultK = f_ult(rawKuse, smoothK)
kS = smoothMode == "SMA" ? smaK : smoothMode == "2-pole" ? ssK : ultK
smaD = ta.sma(kS, smoothD)
ssD  = f_ss(kS, smoothD)
ultD = f_ult(kS, smoothD)
dS = smoothMode == "SMA" ? smaD : smoothMode == "2-pole" ? ssD : ultD

// Inverse Fisher Transform (sharpen), rescaled back to 0..100 — only when enabled
// (default OFF), so the two exponentials are not computed every bar for nothing.
float kVal = kS
float dVal = dS
if useIFT
    float ek = math.exp(2.0 * (0.1*(kS-50.0)))
    float ed = math.exp(2.0 * (0.1*(dS-50.0)))
    kVal := ((ek - 1.0)/(ek + 1.0) + 1.0)*50.0
    dVal := ((ed - 1.0)/(ed + 1.0) + 1.0)*50.0

// =============================================================================
// L2 — CALIBRATED OB / OS  (dynamic percentile bands + edge stats)
// =============================================================================
obLvl = ta.percentile_linear_interpolation(kVal, calLen, obPct)
osLvl = ta.percentile_linear_interpolation(kVal, calLen, osPct)
stretch = kVal >= obLvl ? (kVal - obLvl)/math.max(100.0 - obLvl, 1.0)*100.0 : kVal <= osLvl ? -((osLvl - kVal)/math.max(osLvl, 1.0)*100.0) : 0.0
var int obEv = 0
var int obRev = 0
var int osEv = 0
var int osRev = 0
var int baseRevN = 0    // unconditional reversion base rate (any bar)
var int baseObB  = 0    // any bar that reached ≤50 within revLook
var int baseOsB  = 0    // any bar that reached ≥50 within revLook
// ta.lowest/ta.highest hoisted OUT of the confirmed-bar block so these built-ins
// are evaluated every bar (no "call on every bar" warning, no window desync); the
// booleans are only consumed on confirmed bars below.
float revLoK = ta.lowest(kVal, revLook)
float revHiK = ta.highest(kVal, revLook)
if barstate.isconfirmed and bar_index > revLook + 5
    baseRevN += 1
    revToLo = revLoK <= 50.0
    revToHi = revHiK >= 50.0
    if revToLo
        baseObB += 1
    if revToHi
        baseOsB += 1
    if kVal[revLook] >= obLvl[revLook]
        obEv += 1
        if revToLo
            obRev += 1
    if kVal[revLook] <= osLvl[revLook]
        osEv += 1
        if revToHi
            osRev += 1
// float() casts force fractional division — obRev/obEv etc. are int counters, and
// int/int would truncate the reversion rate to 0% or 100%.
pObRev  = obEv > 0 ? obRev / float(obEv) * 100.0 : na
pOsRev  = osEv > 0 ? osRev / float(osEv) * 100.0 : na
pObBase = baseRevN > 0 ? baseObB / float(baseRevN) * 100.0 : na    // matched base rate (shown next to the reversion rate)
pOsBase = baseRevN > 0 ? baseOsB / float(baseRevN) * 100.0 : na
// 95% Wilson lower bounds that back the reversion rates (small samples punished).
pObLB   = f_wilsonLB(obRev, obEv) * 100.0
pOsLB   = f_wilsonLB(osRev, osEv) * 100.0

// =============================================================================
// L2b — EMBEDDED TREND ENGINE
// =============================================================================
var int embUp = 0
var int embDn = 0
embUp := kVal >= obLvl ? embUp + 1 : 0
embDn := kVal <= osLvl ? embDn + 1 : 0
embeddedUp = embUp >= embedBars
embeddedDn = embDn >= embedBars
embedded = embeddedUp or embeddedDn
embDir = embeddedUp ? 1 : embeddedDn ? -1 : 0

// =============================================================================
// L3 — REGIME (+ variance-ratio, SNR/chop gate)
// =============================================================================
[diP, diM, adx] = ta.dmi(adxLen, adxLen)
logRet = math.abs(nz(ta.change(math.log(close))))
var float clustI = 0.0
clustI := clustI * math.exp(-clustDecay) + logRet
hMeanH = ta.sma(clustI, normLen)
hStdH  = ta.stdev(clustI, normLen)
clustZ = hStdH == 0 ? 0.0 : (clustI - hMeanH) / hStdH
volCluster = clustZ > clustThr
erChg = math.abs(src_in - src_in[erLen])
erVol = math.sum(math.abs(src_in - src_in[1]), erLen)
er = erVol == 0 ? 0.0 : erChg / erVol
trendMa = ta.ema(close, regMaLn)
bull = close > trendMa
trending = adx > adxTrd and er > erTrd
regimePct = math.round(f_clamp((adx/40.0)*50 + er*50, 0, 100))
string regime = volCluster and not trending ? "Volatile" : trending ? (bull ? "Trend Bull" : "Trend Bear") : "Range"
regColor = regime == "Trend Bull" ? color.teal : regime == "Trend Bear" ? color.red : regime == "Volatile" ? color.orange : color.gray
mktPhase = trending ? (bull ? "MARKUP" : "MARKDOWN") : (close > trendMa ? "DISTRIB" : "ACCUM")
isRange = regime == "Range"
isTrend = trending
// variance ratio (mean-reversion vs trending). ta.* are incremental built-ins kept
// unconditional (calling them inside `if` warns and can desync their history).
ret1 = nz(ta.change(math.log(close)))
retK = math.log(close) - math.log(nz(close[vrLen], close))
var1 = ta.variance(ret1, normLen)
varK = ta.variance(retK, normLen)
vr = var1 > 0 ? varK / (vrLen * var1) : 1.0
vrMeanRev = vr < 1.0
// SNR / chop proxy: cycle swing vs noise
detrSD = ta.stdev(Detr, normLen)
snrVal = atr > 0 ? detrSD / atr : 0.0
snrOK = not useSNR or snrVal >= snrMin

// =============================================================================
// L3b — ADAPTIVE TREND TRAIL  (adaptive MA + volatility-scaled trailing band on %K)
// =============================================================================
kSD50 = ta.stdev(kVal, 50)
ottPctUse = ottAdapt ? f_clamp(ottPct * (kSD50 / 15.0), 0.1, 8.0) : ottPct
mavg = f_vidya(kVal, ottLen)
fark = mavg * ottPctUse * 0.01
var float longStop = 0.0
lsPrev = nz(longStop[1], mavg)
longStop := mavg - fark
longStop := mavg > lsPrev ? math.max(longStop, lsPrev) : longStop
var float shortStop = 0.0
ssPrev = nz(shortStop[1], mavg)
shortStop := mavg + fark
shortStop := mavg < ssPrev ? math.min(shortStop, ssPrev) : shortStop
var int ottDir = 1
ottDir := ottDir == -1 and mavg > ssPrev ? 1 : ottDir == 1 and mavg < lsPrev ? -1 : ottDir
mtLine = ottDir == 1 ? longStop : shortStop
ottRaw = mavg > mtLine ? mtLine*(200.0 + ottPctUse)/200.0 : mtLine*(200.0 - ottPctUse)/200.0
ottLine = nz(ottRaw[2], ottRaw)
ottBull = mavg > ottLine
ottCrossUp = ta.crossover(mavg, ottLine)
ottCrossDn = ta.crossunder(mavg, ottLine)

// =============================================================================
// FEEDS — CVD (intrabar) + optional volatility index + cross-asset
// =============================================================================
ltfArr = request.security_lower_tf(syminfo.tickerid, ltfRes, (close >= open ? 1.0 : -1.0) * volNz)
ltfOk  = array.size(ltfArr) > 0
barDelta = ltfOk ? array.sum(ltfArr) : (close >= open ? 1.0 : -1.0) * volNz
cvd = ta.cum(barDelta)
cvdSlope = cvd - nz(cvd[5], cvd)
cvdSign = math.sign(cvdSlope)

vix = f_fetch(vixSym)
vixLive = not na(vix)
vixMean = ta.sma(vix, vixLen)
vixSD   = ta.stdev(vix, vixLen)
vixZ = (vixLive and vixSD > 0) ? (vix - vixMean) / vixSD : 0.0
vixSpike = vixLive and vixZ >= vixSpk
xaSymUse = str.length(xaSym) > 0 ? xaSym : syminfo.tickerid
xaRaw = request.security(xaSymUse, timeframe.period, close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
xa = str.length(xaSym) > 0 ? xaRaw : na
xaLive = not na(xa)
xaMom = xaLive ? math.sign(xa - nz(xa[xaLen], xa)) * xaSign : 0

// =============================================================================
// MTF — zone agreement (fixed 14/3 stochastic per TF, no repaint)
// =============================================================================
f_mtfk() =>
    h = ta.highest(high, 14)
    l = ta.lowest(low, 14)
    k = (h - l) == 0 ? 50.0 : (close - l)/(h - l)*100.0
    ks = ta.sma(k, 3)
    math.sign(ks - 50.0)
mtf1 = useMtf ? nz(request.security(syminfo.tickerid, tf1, f_mtfk(), lookahead=barmerge.lookahead_off)) : 0
mtf2 = useMtf ? nz(request.security(syminfo.tickerid, tf2, f_mtfk(), lookahead=barmerge.lookahead_off)) : 0
mtf3 = useMtf ? nz(request.security(syminfo.tickerid, tf3, f_mtfk(), lookahead=barmerge.lookahead_off)) : 0
mtf4 = useMtf ? nz(request.security(syminfo.tickerid, tf4, f_mtfk(), lookahead=barmerge.lookahead_off)) : 0
mtfBull = (mtf1>0?1:0)+(mtf2>0?1:0)+(mtf3>0?1:0)+(mtf4>0?1:0)
mtfBear = (mtf1<0?1:0)+(mtf2<0?1:0)+(mtf3<0?1:0)+(mtf4<0?1:0)
htfSign = nz(request.security(syminfo.tickerid, htfTf, f_mtfk(), lookahead=barmerge.lookahead_off))

// =============================================================================
// L4 — SIGNALS  (regime auto-switch: fade calibrated extremes / ride trend)
// =============================================================================
barConfirmed = confirmClose ? barstate.isconfirmed : true
volSma20 = ta.sma(volNz, 20)
volThrust = volLive ? volNz > volSma20 * 1.2 : true

kxUp = ta.crossover(kVal, dVal)
kxDn = ta.crossunder(kVal, dVal)

fadeShort = isRange and not embeddedUp and kVal[1] >= obLvl[1] and kxDn and phaseShortOK and snrOK and barConfirmed
fadeLong  = isRange and not embeddedDn and kVal[1] <= osLvl[1] and kxUp and phaseLongOK and snrOK and barConfirmed
rideLong  = isTrend and bull       and (ottCrossUp or (ottBull and kxUp and kVal < 50.0)) and snrOK and barConfirmed
rideShort = isTrend and (not bull)  and (ottCrossDn or ((not ottBull) and kxDn and kVal > 50.0)) and snrOK and barConfirmed
if useHtfGate
    rideLong  := rideLong  and htfSign >= 0
    rideShort := rideShort and htfSign <= 0

// Divergence on %K pivots vs price (regular = reversal, hidden = continuation)
ph = ta.pivothigh(kVal, pvL, pvR)
pl = ta.pivotlow(kVal, pvL, pvR)
var float lpH = na
var float ppH = na
var float lpHp = na
var float ppHp = na
var int   lpHx = na
var int   ppHx = na
if not na(ph)
    ppH := lpH
    ppHp := lpHp
    ppHx := lpHx
    lpH := ph
    lpHp := high[pvR]
    lpHx := bar_index - pvR
var float lpL = na
var float ppL = na
var float lpLp = na
var float ppLp = na
var int   lpLx = na
var int   ppLx = na
if not na(pl)
    ppL := lpL
    ppLp := lpLp
    ppLx := lpLx
    lpL := pl
    lpLp := low[pvR]
    lpLx := bar_index - pvR
bearDiv = (not na(ppH)) and not na(ph) and lpHp > ppHp and lpH < ppH
bullDiv = (not na(ppL)) and not na(pl) and lpLp < ppLp and lpL > ppL
hidBear = (not na(ppH)) and not na(ph) and lpHp < ppHp and lpH > ppH
hidBull = (not na(ppL)) and not na(pl) and lpLp > ppLp and lpL < ppL
divDir = bullDiv ? 1 : bearDiv ? -1 : 0
hidDir = hidBull ? 1 : hidBear ? -1 : 0

// =============================================================================
// CON — DUAL CONVICTION (fade vs continuation) + hard vetoes
// =============================================================================
// Signal-edge calibration state (forward-resolved; feeds the table + optional
// evidence weighting; read a bar late so no same-bar feedback).
var int[]   cN    = array.new<int>(3, 0)     // resolved signals per tier  0=S 1=A 2=B
var int[]   cWin  = array.new<int>(3, 0)     // wins (moved the predicted way)
var float[] cBase = array.new<float>(3, 0)   // Σ matched base prob (for vs-base)
var int     baseAllN = 0
var int     baseUpN  = 0

longSig  = fadeLong or rideLong
shortSig = fadeShort or rideShort
if longSig and shortSig
    shortSig := false
dir = longSig ? 1 : shortSig ? -1 : 0
isFadeSig = fadeLong or fadeShort
isRideSig = rideLong or rideShort

embStrength = f_clamp(math.max(embUp, embDn) / (embedBars * 2.0), 0, 1)
sStretch = isFadeSig ? f_clamp(math.abs(stretch)/100.0, 0, 1) : (ottBull == (dir>0) ? f_clamp(0.5 + embStrength*0.5, 0, 1) : 0.3)
sReg = isFadeSig ? (isRange ? 1.0 : 0.3) : (isTrend ? 1.0 : 0.3)
sEmb = isFadeSig ? (embedded ? 0.2 : 1.0) : ((embDir==dir and embedded) ? 1.0 : (ottBull==(dir>0) ? 0.7 : 0.4))
mtfAgree = dir>0 ? mtfBull : dir<0 ? mtfBear : 0
mtfBalance = 1.0 - math.abs(mtfBull - mtfBear)/4.0
sMtf = isFadeSig ? mtfBalance : (useMtf ? mtfAgree/4.0 : 0.5)
sDiv = isFadeSig ? (divDir==dir and dir!=0 ? 1.0 : 0.4) : (hidDir==dir and dir!=0 ? 1.0 : 0.5)
sVol = volThrust ? 1.0 : 0.4
sXa = (xaLive and xaMom==dir and dir!=0) ? 1.0 : (xaLive ? 0.4 : 0.5)
if useVR and dir!=0
    sReg := isFadeSig ? (vrMeanRev ? math.min(1.0, sReg+0.2) : sReg*0.7) : (vrMeanRev ? sReg*0.8 : math.min(1.0, sReg+0.2))

wSum = wStretch+wReg+wEmb+wMtf+wDiv+wVol+wXa
rawConv = wStretch*sStretch + wReg*sReg + wEmb*sEmb + wMtf*sMtf + wDiv*sDiv + wVol*sVol + wXa*sXa
conv = dir==0 ? 0 : math.round(f_clamp(wSum>0 ? rawConv/wSum*100.0 : 0, 0, 100))
// classic tier — the FIXED yardstick the calibration always buckets by, so the
// optional evidence weighting below can never feed on its own output.
string tierBase = conv>=75?"S" : conv>=60?"A" : conv>=45?"B" : "-"
int _tb = tierBase=="S"?0 : tierBase=="A"?1 : tierBase=="B"?2 : -1
float relFactor = 1.0
if evidence_on and _tb >= 0
    int _n = array.get(cN, _tb)                                     // safe: _tb ≥ 0 confirmed
    if _n >= cal_min
        float _hr = array.get(cWin,_tb) / float(_n)                 // measured hit-rate
        float _mb = array.get(cBase,_tb) / float(_n)                // matched base rate
        relFactor := f_clamp(1.0 + ev_gain * (_hr - _mb), 0.6, 1.2)
if evidence_on
    conv := int(f_clamp(math.round(conv * relFactor), 0, 100))      // acted conviction
tier = conv>=75?"S" : conv>=60?"A" : conv>=45?"B" : "-"

vVix = vixSpike and isFadeSig
vMtf = useMtf and dir!=0 and isRideSig and ((dir>0 and mtfBull<minAlign) or (dir<0 and mtfBear<minAlign))
vHtf = useHtfGate and isRideSig and ((dir>0 and htfSign<0) or (dir<0 and htfSign>0))
vXa  = xaLive and dir!=0 and isRideSig and xaMom!=0 and xaMom!=dir
vSnr = not snrOK and dir!=0
vetoes = vVix or vMtf or vHtf or vXa or vSnr
vetoTxt = vVix?"VIX spike" : vMtf?"MTF weak" : vHtf?"HTF gate" : vXa?"cross-asset" : vSnr?"chop/SNR" : "none"

act = dir!=0 and conv>=minConv and not vetoes
verdict = not act ? (dir!=0 and vetoes ? "VETO" : "FLAT") : dir>0 ? "LONG" : "SHORT"
longTrig  = act and dir>0
shortTrig = act and dir<0

// ── Signal-edge calibration: resolve each LONG/SHORT trigger cal_horizon bars later
//    (non-repaint). Scored only after the full forward window elapses, on confirmed
//    bars, bucketed by the CLASSIC tier at the signal bar. A long wins on an up-move,
//    a short on a down-move; the matched base rate accumulates the unconditional odds.
if barstate.isconfirmed and not na(close[cal_horizon])
    float _fwd = close - close[cal_horizon]
    baseAllN += 1
    if _fwd > 0
        baseUpN += 1
    float _up = baseAllN > 0 ? baseUpN / float(baseAllN) : 0.5
    float _dn = 1.0 - _up
    string _tp = tierBase[cal_horizon]
    int _ti = _tp=="S"?0 : _tp=="A"?1 : _tp=="B"?2 : -1
    if _ti >= 0 and longTrig[cal_horizon]
        array.set(cN,   _ti, array.get(cN,_ti) + 1)
        if _fwd > 0
            array.set(cWin, _ti, array.get(cWin,_ti) + 1)
        array.set(cBase, _ti, array.get(cBase,_ti) + _up)
    if _ti >= 0 and shortTrig[cal_horizon]
        array.set(cN,   _ti, array.get(cN,_ti) + 1)
        if _fwd < 0
            array.set(cWin, _ti, array.get(cWin,_ti) + 1)
        array.set(cBase, _ti, array.get(cBase,_ti) + _dn)
sigModeTxt = isFadeSig ? "Fade" : isRideSig ? "Ride" : "—"

// =============================================================================
// RISK CONTEXT  (ATR stop + size suggestion for dashboard / alerts; no lines)
// =============================================================================
stopDist = atr * atrMult
riskCap = equity * riskPct / 100.0
perUnit = stopDist * ptValue
qty = perUnit > 0 ? math.floor(riskCap / perUnit) : 0
mt = str.tostring(close, format.mintick)
stopPx = dir>0 ? close - stopDist : dir<0 ? close + stopDist : na
ms = str.tostring(nz(stopPx, close), format.mintick)

// =============================================================================
// VIS — LOWER PANE
// =============================================================================
// Conviction → marker opacity: a strong signal is drawn solid, a weak one faint,
// so signal STRENGTH reads at a glance without adding any plots. Bounded so even
// the weakest acted signal stays visible.
int sigTransp = convMarker ? int(f_clamp(72.0 - conv * 0.66, 6, 68)) : 0
color cFadeL = color.new(color.lime,   sigTransp)
color cFadeS = color.new(color.red,    sigTransp)
color cRideL = color.new(color.teal,   sigTransp)
color cRideS = color.new(color.maroon, sigTransp)
kColor = kVal>=obLvl ? color.new(#ff5252,0) : kVal<=osLvl ? color.new(#26c6da,0) : color.new(#90a4ae,0)
plot(showK ? kVal : na, "%K", color=kColor, linewidth=2)
plot(showD ? dVal : na, "%D", color=color.new(color.orange,0))
plot(showOttLine and useOtt ? ottLine : na, "Trend Trail", color=ottBull ? color.new(color.teal,0) : color.new(color.red,0), linewidth=2)
pOB = plot(obLvl, "OB (calibrated)", color=color.new(color.red,45))
pOS = plot(osLvl, "OS (calibrated)", color=color.new(color.teal,45))
pTop = plot(100.0, "top", color=na, display=display.none)
pBot = plot(0.0,   "bot", color=na, display=display.none)
fill(pOB, pTop, color=showBandsFill ? color.new(color.red,  65) : na)
fill(pOS, pBot, color=showBandsFill ? color.new(color.teal, 65) : na)
plot(showFixed ? 80.0 : na, "80 ref", color=color.new(color.gray,80))
plot(showFixed ? 20.0 : na, "20 ref", color=color.new(color.gray,80))
hline(50.0, "Mid", color=color.new(color.gray,55))
// Momentum fill: %K vs the 50 midline — teal above (bullish momentum), red below,
// deeper as it stretches. Off by default. Hidden anchor plots feed the fill only.
pMomK = plot(showMomFill ? kVal : na, "mom k",   color=na, display=display.none, editable=false)
pMom50= plot(showMomFill ? 50.0 : na, "mom mid", color=na, display=display.none, editable=false)
momT  = int(f_clamp(92.0 - math.abs(kVal - 50.0) * 0.9, 60, 92))
fill(pMomK, pMom50, color = (not showMomFill or na(kVal)) ? na : (kVal >= 50.0 ? color.new(color.teal, momT) : color.new(color.red, momT)), title="Momentum fill")
// Embedded-zone shade now reads as the TREND direction it marks: an embedded
// UPtrend tints teal (bullish), an embedded DOWNtrend tints red (bearish).
bgcolor(showEmbZone and embeddedUp ? color.new(color.teal,90) : showEmbZone and embeddedDn ? color.new(color.red,90) : na)
plotshape(fadeLong,  "Fade L pane", shape.triangleup,   location.bottom, cFadeL,  size=size.tiny)
plotshape(fadeShort, "Fade S pane", shape.triangledown, location.top,    cFadeS,  size=size.tiny)
plotshape(rideLong,  "Ride L pane", shape.diamond,      location.bottom, cRideL,  size=size.tiny)
plotshape(rideShort, "Ride S pane", shape.diamond,      location.top,    cRideS,  size=size.tiny)
plotshape(bullDiv,   "Bull div",    shape.circle,       location.bottom, color.new(color.lime,0),  size=size.tiny)
plotshape(bearDiv,   "Bear div",    shape.circle,       location.top,    color.new(color.fuchsia,0),size=size.tiny)
plotshape(hidBull,   "Hidden bull", shape.cross,        location.bottom, color.new(color.green,0), size=size.tiny)
plotshape(hidBear,   "Hidden bear", shape.cross,        location.top,    color.new(color.purple,0),size=size.tiny)

// =============================================================================
// VIS — PRICE CONTEXT BANDS  (project the stochastic range onto price)
// Rolling high/low over the length = %K 100 / 0; calibrated OB/OS map to interior
// price levels, so price's position shows how stretched it is in its own range.
// =============================================================================
rngHL = hh - ll
pxOB  = ll + obLvl/100.0 * rngHL
pxOS  = ll + osLvl/100.0 * rngHL
pxMid = ll + 0.5 * rngHL
phHi  = plot(showPxBands ? hh    : na, "Px range high", color=color.new(color.red,55),  force_overlay=true)
phOB  = plot(showPxBands ? pxOB  : na, "Px OB",         color=color.new(color.red,20),  force_overlay=true)
phMid = plot(showPxBands ? pxMid : na, "Px mid",        color=color.new(color.gray,45), force_overlay=true)
phOS  = plot(showPxBands ? pxOS  : na, "Px OS",         color=color.new(color.teal,20), force_overlay=true)
phLo  = plot(showPxBands ? ll    : na, "Px range low",  color=color.new(color.teal,55), force_overlay=true)
fill(phHi, phOB, color=pxBandFill ? color.new(color.red,  68) : na)
fill(phOS, phLo, color=pxBandFill ? color.new(color.teal, 68) : na)

// =============================================================================
// VIS — PRICE markers + optional divergence lines
// =============================================================================
plotshape(showSignals and fadeLong,  "Fade long",  shape.triangleup,   location.belowbar, cFadeL, size=size.small, force_overlay=true)
plotshape(showSignals and fadeShort, "Fade short", shape.triangledown, location.abovebar, cFadeS, size=size.small, force_overlay=true)
plotshape(showSignals and rideLong,  "Ride long",  shape.diamond,      location.belowbar, cRideL, size=size.tiny,  force_overlay=true)
plotshape(showSignals and rideShort, "Ride short", shape.diamond,      location.abovebar, cRideS, size=size.tiny,  force_overlay=true)

var array<line>  divPx = array.new<line>()
var array<label> divLb = array.new<label>()
if showDivLines and (bearDiv or hidBear) and not na(ppHx)
    col = bearDiv ? color.fuchsia : color.purple
    array.push(divPx, line.new(ppHx, ppHp, lpHx, lpHp, xloc.bar_index, color=color.new(col,0), width=2, force_overlay=true))
    array.push(divLb, label.new(lpHx, lpHp, bearDiv ? "Bear div" : "Hidden bear", style=label.style_label_down, color=color.new(col,12), textcolor=color.white, size=size.tiny, force_overlay=true))
if showDivLines and (bullDiv or hidBull) and not na(ppLx)
    col2 = bullDiv ? color.lime : color.green
    array.push(divPx, line.new(ppLx, ppLp, lpLx, lpLp, xloc.bar_index, color=color.new(col2,0), width=2, force_overlay=true))
    array.push(divLb, label.new(lpLx, lpLp, bullDiv ? "Bull div" : "Hidden bull", style=label.style_label_up, color=color.new(col2,12), textcolor=color.black, size=size.tiny, force_overlay=true))
while array.size(divPx) > divKeep
    line.delete(array.shift(divPx))
    label.delete(array.shift(divLb))

// =============================================================================
// ALERTS
// =============================================================================
if longTrig
    alert("STOCH ARC " + sigModeTxt + " LONG " + syminfo.ticker + " @ " + mt + "  SLctx " + ms + "  | conv " + str.tostring(conv) + " (" + tier + ")", alert.freq_once_per_bar_close)
if shortTrig
    alert("STOCH ARC " + sigModeTxt + " SHORT " + syminfo.ticker + " @ " + mt + "  SLctx " + ms + "  | conv " + str.tostring(conv) + " (" + tier + ")", alert.freq_once_per_bar_close)
alertcondition(longTrig,  "STOCH ARC Long",  "STOCH ARC long verdict")
alertcondition(shortTrig, "STOCH ARC Short", "STOCH ARC short verdict")
alertcondition(ottCrossUp,   "Trend-trail cross up",   "Adaptive trend-trail bullish cross")
alertcondition(ottCrossDn,   "Trend-trail cross down", "Adaptive trend-trail bearish cross")

// =============================================================================
// VIS — DASHBOARD (adaptive light/dark, compact by default)
// =============================================================================
var table dash = table.new(f_pos(tblPos), 2, 40, frame_width=1, border_width=1, force_overlay=true)
setrow(tbl, r, lbl, val, vc, lc, bg) =>
    table.cell(tbl, 0, r, lbl, text_color=lc, text_size=size.tiny,  text_halign=text.align_left,  bgcolor=bg)
    table.cell(tbl, 1, r, val, text_color=vc, text_size=size.small, text_halign=text.align_right, bgcolor=bg)

if showTbl and barstate.islast
    tIsDark = tblTheme=="Dark" ? true : tblTheme=="Light" ? false : color.r(chart.bg_color) < 128
    tBg   = tIsDark ? color.new(#0b0f17, 6) : color.new(#ffffff, 4)
    tBord = tIsDark ? color.new(#3a4250, 0) : color.new(#c2c8d0, 0)
    tLbl  = tIsDark ? #9aa3b2 : #515a67
    tVal  = tIsDark ? #f2f4f8 : #10151d
    cBull = tIsDark ? #2dd4bf : #0e9e76
    cBear = tIsDark ? #ff6b6b : #d32f2f
    cWarn = tIsDark ? #ffa94d : #b56a00
    cInfo = tIsDark ? #ffd43b : #9a7400
    cMute = tIsDark ? #6b7480 : #98a0ab
    table.set_frame_color(dash, tBord)
    table.set_border_color(dash, tBord)
    verdColor = verdict=="LONG"?cBull : verdict=="SHORT"?cBear : verdict=="VETO"?cWarn : cMute
    regColT   = regime=="Trend Bull"?cBull : regime=="Trend Bear"?cBear : regime=="Volatile"?cWarn : cMute
    actCol    = longTrig?color.new(cBull,0) : shortTrig?color.new(cBear,0) : verdict=="VETO"?color.new(cWarn,0) : color.new(#5b6472,0)
    zoneCol   = kVal>=obLvl?cBear : kVal<=osLvl?cBull : tVal
    ottCol    = useOtt?(ottBull?cBull:cBear):cMute
    embCol    = embedded?cWarn:cMute
    actShort  = longTrig?"LONG" : shortTrig?"SHORT" : verdict=="VETO"?"WAIT" : "FLAT"
    actDetail = (longTrig or shortTrig) ? (sigModeTxt+" · conv "+str.tostring(conv)+" "+tier) : verdict=="VETO" ? vetoTxt : "no edge"
    kdTxt     = str.tostring(kVal,"0.0")+" / "+str.tostring(dVal,"0.0")
    zoneTxt   = kVal>=obLvl?("OB "+str.tostring(obLvl,"0")) : kVal<=osLvl?("OS "+str.tostring(osLvl,"0")) : ("mid ["+str.tostring(osLvl,"0")+"-"+str.tostring(obLvl,"0")+"]")
    stretchTxt= sgn(stretch)+str.tostring(stretch,"0")+"%"
    ottTxt    = useOtt?((ottBull?"bull ":"bear ")+str.tostring(ottLine,"0.0")) : "off"
    embTxt    = embeddedUp?("UP "+str.tostring(embUp)+"b") : embeddedDn?("DN "+str.tostring(embDn)+"b") : "no"
    edgeTxt   = "rev "+(na(pObRev)?"-":str.tostring(math.round(pObRev)))+"/"+(na(pOsRev)?"-":str.tostring(math.round(pOsRev)))+" (LB "+(na(pObLB)?"-":str.tostring(math.round(pObLB)))+"/"+(na(pOsLB)?"-":str.tostring(math.round(pOsLB)))+") vs base "+(na(pObBase)?"-":str.tostring(math.round(pObBase)))+"/"+(na(pOsBase)?"-":str.tostring(math.round(pOsBase)))
    biasTxt   = (useMtf?("MTF "+str.tostring(dir>0?mtfBull:dir<0?mtfBear:math.max(mtfBull,mtfBear))+"/4"):"off")+"  HTF"+(htfSign>0?"^":htfSign<0?"v":"-")
    cycTxt    = "cyc "+str.tostring(math.round(domCycle))+(cycRising?" ^":" v")
    engTxt    = (stochSrc=="Price"?"Stoch":"StochRSI")+" "+str.tostring(lenUse)+" · "+(smoothMode=="2-pole"?"2P":smoothMode=="SMA"?"SMA":"LL")+(useIFT?" IFT":"")
    divTxt    = divDir!=0?(divDir>0?"bull":"bear") : hidDir!=0?(hidDir>0?"hidden bull":"hidden bear") : "none"
    table.cell(dash, 0, 0, " > "+actShort+" ", text_color=color.white, text_size=size.small, text_halign=text.align_left,  bgcolor=actCol)
    table.cell(dash, 1, 0, actDetail+" ",      text_color=color.white, text_size=size.small, text_halign=text.align_right, bgcolor=actCol)
    if compactTbl
        setrow(dash, 1,  "VERDICT",  verdict+" · "+str.tostring(conv)+" ("+tier+")", verdColor, tLbl, tBg)
        setrow(dash, 2,  "MODE",     sigModeTxt, isFadeSig?cInfo:isRideSig?cBull:cMute, tLbl, tBg)
        setrow(dash, 3,  "REGIME",   regime+" "+str.tostring(regimePct)+"% "+mktPhase, regColT, tLbl, tBg)
        setrow(dash, 4,  "%K / %D",  kdTxt, zoneCol, tLbl, tBg)
        setrow(dash, 5,  "ZONE",     zoneTxt, zoneCol, tLbl, tBg)
        setrow(dash, 6,  "STRETCH",  stretchTxt, math.abs(stretch)>0?cWarn:tVal, tLbl, tBg)
        setrow(dash, 7,  "TREND TRAIL",ottTxt, ottCol, tLbl, tBg)
        setrow(dash, 8,  "EMBEDDED", embTxt, embCol, tLbl, tBg)
        setrow(dash, 9,  "EDGE",     edgeTxt, tVal, tLbl, tBg)
        setrow(dash, 10, "BIAS",     biasTxt, ((dir>0 and mtfBull>=minAlign) or (dir<0 and mtfBear>=minAlign))?cBull:cMute, tLbl, tBg)
        setrow(dash, 11, "CYCLE",    cycTxt, tVal, tLbl, tBg)
        setrow(dash, 12, "SIZE",     str.tostring(qty)+" units ("+str.tostring(riskPct,"0.0")+"%)", tVal, tLbl, tBg)
        setrow(dash, 13, "VETO",     vetoTxt, vetoTxt=="none"?cMute:cWarn, tLbl, tBg)
        if showLegend
            setrow(dash, 14, "— LEGEND —", "", cMute, cMute, tBg)
            setrow(dash, 15, "FADE",     "fade calibrated extreme (range)", cMute, tLbl, tBg)
            setrow(dash, 16, "RIDE",     "ride trend / trail (continuation)", cMute, tLbl, tBg)
            setrow(dash, 17, "ZONE",     "OB/OS = symbol's own percentiles", cMute, tLbl, tBg)
            setrow(dash, 18, "TREND TRAIL","adaptive trailing-trend line on the oscillator", cMute, tLbl, tBg)
            setrow(dash, 19, "EMBEDDED", "pinned at extreme = trend, no fade", cMute, tLbl, tBg)
            setrow(dash, 20, "EDGE",     "past reversal odds · time-in-zone", cMute, tLbl, tBg)
            setrow(dash, 21, "CONV",     "setup quality 0-100 (S/A/B)", cMute, tLbl, tBg)
            setrow(dash, 22, "VETO",     "trade blocked + reason", cMute, tLbl, tBg)
    else
        setrow(dash, 1,  "REGIME",   regime+" "+str.tostring(regimePct)+"% "+mktPhase, regColT, tLbl, tBg)
        setrow(dash, 2,  "ENGINE",   engTxt, tVal, tLbl, tBg)
        setrow(dash, 3,  "%K / %D",  kdTxt, zoneCol, tLbl, tBg)
        setrow(dash, 4,  "ZONE",     zoneTxt, zoneCol, tLbl, tBg)
        setrow(dash, 5,  "STRETCH",  stretchTxt, math.abs(stretch)>0?cWarn:tVal, tLbl, tBg)
        setrow(dash, 6,  "TREND TRAIL",ottTxt, ottCol, tLbl, tBg)
        setrow(dash, 7,  "EMBEDDED", embTxt, embCol, tLbl, tBg)
        setrow(dash, 8,  "EDGE",     edgeTxt, tVal, tLbl, tBg)
        setrow(dash, 9,  "DIVERG",   divTxt, divDir>0?cBull:divDir<0?cBear:hidDir>0?cBull:hidDir<0?cBear:cMute, tLbl, tBg)
        setrow(dash, 10, "CYCLE",    cycTxt, tVal, tLbl, tBg)
        setrow(dash, 11, "MTF",      useMtf?(str.tostring(mtfBull)+"/"+str.tostring(mtfBear)+" of 4"):"off", useMtf?tVal:cMute, tLbl, tBg)
        setrow(dash, 12, "HTF",      htfSign>0?"bull":htfSign<0?"bear":"flat", htfSign>0?cBull:htfSign<0?cBear:cMute, tLbl, tBg)
        setrow(dash, 13, "CVD",      cvdSign>0?"up":cvdSign<0?"dn":"flat", cvdSign>0?cBull:cvdSign<0?cBear:cMute, tLbl, tBg)
        setrow(dash, 14, "VIX",      vixLive?("z"+sgn(vixZ)+str.tostring(vixZ,"0.0")+(vixSpike?" !":"")):"n/a", vixSpike?cWarn:vixLive?tVal:cMute, tLbl, tBg)
        setrow(dash, 15, "CROSS-AST",xaLive?(xaMom>0?"aligned":xaMom<0?"against":"flat"):"n/a", xaLive?(xaMom>0?cBull:xaMom<0?cBear:cMute):cMute, tLbl, tBg)
        setrow(dash, 16, "VAR-RATIO",useVR?(str.tostring(vr,"0.00")+(vrMeanRev?" MR":" TR")):"off", useVR?(vrMeanRev?cBull:cWarn):cMute, tLbl, tBg)
        setrow(dash, 17, "SNR",      useSNR?str.tostring(snrVal,"0.00"):"off", useSNR?(snrOK?cBull:cWarn):cMute, tLbl, tBg)
        setrow(dash, 18, "------",   "------", cMute, tLbl, tBg)
        setrow(dash, 19, "MODE",     sigModeTxt, isFadeSig?cInfo:isRideSig?cBull:cMute, tLbl, tBg)
        setrow(dash, 20, "CONVICTION", str.tostring(conv)+" / 100 ("+tier+")", conv>=60?cBull:conv>=45?cInfo:cMute, tLbl, tBg)
        setrow(dash, 21, "VERDICT",  verdict, verdColor, tLbl, tBg)
        setrow(dash, 22, "VETO",     vetoTxt, vetoTxt=="none"?cMute:cWarn, tLbl, tBg)
        setrow(dash, 23, "SIZE",     str.tostring(qty)+" units ("+str.tostring(riskPct,"0.0")+"%)", tVal, tLbl, tBg)
        if showLegend
            setrow(dash, 24, "— LEGEND —", "", cMute, cMute, tBg)
            setrow(dash, 25, "FADE",     "fade calibrated extreme in a range", cMute, tLbl, tBg)
            setrow(dash, 26, "RIDE",     "ride trend / trail cross (continuation)", cMute, tLbl, tBg)
            setrow(dash, 27, "ZONE",     "OB/OS = this symbol's own percentiles", cMute, tLbl, tBg)
            setrow(dash, 28, "TREND TRAIL","adaptive trailing-trend filter on the oscillator", cMute, tLbl, tBg)
            setrow(dash, 29, "EMBEDDED", "pinned at extreme = trend, fades off", cMute, tLbl, tBg)
            setrow(dash, 30, "EDGE",     "past reversal odds · time-in-zone %", cMute, tLbl, tBg)
            setrow(dash, 31, "VAR-RATIO","<1 mean-revert (MR), >1 trend (TR)", cMute, tLbl, tBg)
            setrow(dash, 32, "CONV",     "setup quality 0-100 · S/A/B tier", cMute, tLbl, tBg)
            setrow(dash, 33, "VETO",     "trade blocked + reason", cMute, tLbl, tBg)

// =============================================================================
// IDENTITY
// =============================================================================
var table idTbl = table.new(position.bottom_center, 1, 1, force_overlay=true)
if showId and barstate.islast
    table.cell(idTbl, 0, 0, "STOCH ARC · Adaptive Stochastic   ·   " + syminfo.ticker + "  " + timeframe.period, text_color=color.new(#8a929e, 20), text_size=size.small, text_halign=text.align_center, bgcolor=color.new(color.gray, 100))

// =============================================================================
// SIGNAL-EDGE CALIBRATION TABLE  (forward-resolved honesty check; last bar only)
// =============================================================================
// Does a higher-conviction signal actually win more often here? Each resolved
// LONG/SHORT trigger is scored by whether price moved its way over the horizon,
// bucketed by the CLASSIC tier it carried, with a 95% Wilson lower bound vs the
// matched base rate. Green vs-base = the tier genuinely beats chance; red = not.
var table calTbl = na
if cal_show and barstate.islast
    if not na(calTbl)
        table.delete(calTbl)
    calTbl := table.new(f_pos(cal_pos), 5, 5, border_width=1, border_color=color.new(color.gray,60), force_overlay=true)
    cHdr = color.new(#2962ff, 0)
    cBg  = color.new(color.black, 12)
    cTx  = color.white
    cDm  = color.new(#9aa0a6, 0)
    table.cell(calTbl, 0, 0, "SIGNAL EDGE", text_color=cTx, bgcolor=cHdr, text_size=size.tiny, text_halign=text.align_left)
    table.cell(calTbl, 1, 0, "N",       text_color=cTx, bgcolor=cHdr, text_size=size.tiny)
    table.cell(calTbl, 2, 0, "win",     text_color=cTx, bgcolor=cHdr, text_size=size.tiny)
    table.cell(calTbl, 3, 0, "Wilson↓", text_color=cTx, bgcolor=cHdr, text_size=size.tiny)
    table.cell(calTbl, 4, 0, "vs base", text_color=cTx, bgcolor=cHdr, text_size=size.tiny)
    float _bup = baseAllN > 0 ? baseUpN / float(baseAllN) * 100.0 : na
    table.cell(calTbl, 0, 1, "base up/dn", text_color=cDm, bgcolor=cBg, text_size=size.tiny, text_halign=text.align_left)
    table.cell(calTbl, 1, 1, str.tostring(baseAllN), text_color=cDm, bgcolor=cBg, text_size=size.tiny)
    table.cell(calTbl, 2, 1, na(_bup) ? "—" : str.tostring(_bup,"#")+"/"+str.tostring(100.0-_bup,"#")+"%", text_color=cDm, bgcolor=cBg, text_size=size.tiny)
    table.cell(calTbl, 3, 1, "", text_color=cDm, bgcolor=cBg, text_size=size.tiny)
    table.cell(calTbl, 4, 1, "", text_color=cDm, bgcolor=cBg, text_size=size.tiny)
    calNames = array.from("S", "A", "B")
    for ti = 0 to 2
        int nS = array.get(cN, ti)
        int rw = ti + 2
        bool enough = nS >= cal_min
        table.cell(calTbl, 0, rw, array.get(calNames, ti) + " tier", text_color=enough?cTx:cDm, bgcolor=cBg, text_size=size.tiny, text_halign=text.align_left)
        if enough
            float _hit = array.get(cWin,ti) / float(nS) * 100.0
            float _wl  = f_wilsonLB(array.get(cWin,ti), nS) * 100.0
            float _mb  = array.get(cBase,ti) / nS * 100.0
            float _edg = _wl - _mb
            color _ec  = _edg > 0 ? color.new(#26a69a,15) : color.new(#ef5350,15)
            table.cell(calTbl, 1, rw, str.tostring(nS), text_color=cDm, bgcolor=cBg, text_size=size.tiny)
            table.cell(calTbl, 2, rw, str.tostring(_hit,"#")+"%", text_color=cTx, bgcolor=cBg, text_size=size.tiny)
            table.cell(calTbl, 3, rw, str.tostring(_wl,"#")+"%",  text_color=cTx, bgcolor=cBg, text_size=size.tiny)
            table.cell(calTbl, 4, rw, (_edg>0?"+":"")+str.tostring(_edg,"#"), text_color=cTx, bgcolor=_ec, text_size=size.tiny)
        else
            table.cell(calTbl, 1, rw, str.tostring(nS), text_color=cDm, bgcolor=cBg, text_size=size.tiny)
            table.cell(calTbl, 2, rw, "—", text_color=cDm, bgcolor=cBg, text_size=size.tiny)
            table.cell(calTbl, 3, rw, "—", text_color=cDm, bgcolor=cBg, text_size=size.tiny)
            table.cell(calTbl, 4, rw, "—", text_color=cDm, bgcolor=cBg, text_size=size.tiny)
````
