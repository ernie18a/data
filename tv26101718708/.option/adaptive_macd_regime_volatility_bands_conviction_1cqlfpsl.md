# Adaptive MACD    Regime, Volatility Bands & Conviction

- url: https://www.tradingview.com/script/1CqlfPsL-Adaptive-MACD-Regime-Volatility-Bands-Conviction/
- type: indicator
- pine_id: PUB;dd3713b96fcf499e9c3a34e69dc0d3ba
- version: 1.0

## Description

# Adaptive MACD — Regime, Volatility Bands & Conviction

## What this is

This is a single, self-contained momentum framework built around **one normalized MACD core**. Instead of plotting a raw MACD and leaving you to judge it, the script surrounds that core with the context a momentum reading needs to be usable: a market-regime filter, an adaptive length stage, a multi-timeframe agreement check, a volatility band, and a conviction score that combines them into one number. It runs on **any symbol and any timeframe** — the price source and every optional reference feed are selectable in Settings.

It is a study/indicator (not a strategy). It does not place orders and does not claim any performance.

---

## Why these components are combined (mashup rationale)

A plain MACD only answers "is momentum up or down right now." On its own it has two well-known weaknesses: it whipsaws during sideways markets, and its fixed 12/26/9 lengths are arbitrary for any given symbol or timeframe. Each module below exists to fix a specific one of those weaknesses, and they are deliberately chained so the output of one informs the next:

1. **Normalized MACD core (L1)** — the MACD histogram is converted to a rolling **z-score**, so a reading of "+2" means the same thing on a low-priced FX pair, a high-priced index, or a 1-minute vs daily chart. Raw MACD values are not comparable across instruments; the z-score is. This is what makes the rest of the framework symbol-agnostic.

2. **Regime filter (L2)** — efficiency ratio + ADX + a volatility-clustering measure classify the market as **Trend / Range / Volatile**. This is used to decide whether a momentum signal should be trusted: MACD crosses are reliable in trends and noisy in ranges, so the regime gates and reweights the core signal rather than treating every cross equally.

3. **Adaptive length stage (L3)** — a dominant-cycle estimate (Ehlers homodyne) retunes the fast/slow/signal lengths toward the market's measured rhythm, instead of a static 12/26/9. You can switch this to a volatility-driven mode or fall back to fixed lengths. This directly addresses the "arbitrary lengths" weakness.

4. **Multi-timeframe confluence (MTF)** — the same MACD logic is evaluated on four higher timeframes, confirmed on bar close so it does not repaint. A single-timeframe cross is weak; agreement across timeframes is the filter.

5. **Volatility band + fade (L4)** — a volume-weighted standard-deviation band around price flags stretched conditions and band-rejection ("fade") setups, used as a mean-reversion counterweight to the trend logic.

6. **Conviction + vetoes (CON)** — all of the above are blended into a single **0–100 conviction score** with hard vetoes (e.g. counter-regime, timeframe disagreement, volatility spike). This is the part that turns several separate readings into one decision so you are not eyeballing five panels.

7. **Risk framework (RISK)** — once there is a signal, it derives an ATR stop, R-multiple targets, and a position-size suggestion from your account equity and risk %. This is shown as thin Entry / Stop / TP1 / TP2 lines on price.

In short: **L1 makes momentum comparable, L2 decides if it can be trusted, L3 tunes it, MTF confirms it, L4 adds a reversion check, CON scores it, and RISK frames it.** None of the layers is decorative — remove any one and the others lose context.

---

## How to use it

1. Add it to any chart and timeframe. It plots in its own lower pane; the trade levels and dashboard overlay on price.
2. Read the **dashboard header**: it shows the current action (BUY / SELL / HOLD / WAIT / FLAT) and the entry/stop.
3. Check **VERDICT + conviction**: a higher score with no active vetoes is a stronger context. Vetoes are listed explicitly so you can see *why* something is blocked.
4. Use **REGIME** to set expectations — trend-following signals make more sense in a Trend regime; the Stretch/Fade rows matter more in Range.
5. The **Entry / Stop / TP1 / TP2 lines** on price show the framework's risk levels for the current signal only; previous trade lines are removed automatically.
6. Optional feeds (reference symbol, volatility index, open interest, cross-asset) are **blank by default** — add your own symbols if you want those confluence inputs, or leave them off. The script degrades gracefully and tells you in the FEEDS row which are live.

---

## Settings worth knowing

- **Price source** — the series the whole engine runs on. Defaults to close; works on any market.
- **Optional reference feeds** — all blank by default and entirely optional, so the script is not tied to any one market or exchange. Enter symbols relevant to your instrument if you want them.
- **Adaptive length driver** — Homodyne (cycle-adaptive), Volatility, or Fixed.
- **Risk & sizing** — account equity, risk %, ATR stop multiple, and value-per-move; the size output is a suggestion only.
- **Dashboard theme** — Auto/Dark/Light; Auto flips colors to stay readable on white or black backgrounds.
- **Name / symbol / timeframe label** — kept on by default so the chart always identifies what is plotted.

---

## What makes it original

It is not a wrapper around a built-in MACD. The core is rebuilt to accept a *series* length (so it can be retuned every bar), normalized to a cross-asset z-score, gated by an explicitly classified regime, and merged with multi-timeframe state into a single weighted conviction score with named vetoes. The volatility-band fade logic and the dominant-cycle length adaptation are integrated into that same score rather than shown as separate, disconnected studies.

---

## Notes and limitations

- Confirm-on-close is on by default to avoid repainting; intrabar values can still update until the bar closes.
- The optional "Call/Put strike" row is a convenience hint derived from price and your strike interval only — **no options-chain data is read and no option P&L is implied.**
- Higher-timeframe and reference-feed requests depend on your data subscription; if a feed is unavailable the script disables the dependent input and continues.

---

## Disclaimer

This script is provided for educational and informational purposes only. It is a technical study, not investment, financial, or trading advice, and not a solicitation to buy or sell any instrument. It does not guarantee any result. Markets involve risk, including loss of capital. Indicator signals, levels, and the position-size suggestion are illustrative and must not be relied on as the basis for any trade. Always do your own research and consider consulting a licensed financial professional before trading. The author accepts no liability for any loss arising from use of this script. Past behavior of any indicator is not indicative of future results.

## Source Code

````pine
// =============================================================================
// Adaptive MACD — Regime, Volatility Bands & Conviction          Pine Script v6
// shorttitle: MACD ARC
// -----------------------------------------------------------------------------
// A normalized, regime-aware, multi-timeframe MACD framework that works on ANY
// symbol and ANY timeframe. The price source and all optional reference feeds
// are user-selectable in Settings, so the script is not tied to one market.
//
// WHY THESE PIECES ARE COMBINED (mashup rationale):
//   A raw MACD answers only "is momentum up or down". On its own it whipsaws in
//   ranges and lags in trends. This framework wraps one normalized MACD core in
//   the context it needs to be tradable: a REGIME filter decides whether the
//   MACD reading should be trusted (trend vs range vs volatile), an ADAPTIVE
//   length stage retunes the MACD to the market's measured dominant cycle so it
//   is not stuck on fixed 12/26/9, a multi-timeframe layer checks the same MACD
//   logic agrees on higher timeframes, and a CONVICTION score blends those
//   agreements into a single 0-100 number with hard vetoes. Each component
//   feeds the next; none is decorative.
//
// MODULE STACK
//   L1   Signal core        : adaptive + (optional) volume-weighted MACD,
//                             normalized to a rolling z-score (comparable across
//                             assets/timeframes)
//   L2   Regime             : efficiency ratio + ADX + volatility clustering ->
//                             Trend / Range / Volatile label
//   L3   Adaptive lengths    : Ehlers homodyne dominant-cycle estimate retunes
//                             fast/slow/signal lengths (or Volatility / Fixed)
//   L4   Signal generation   : z-cross, exhaustion bands, scored divergence,
//                             volatility-band rejection (fade)
//   MTF  Confluence          : the same MACD state on 4 higher timeframes,
//                             confirm-on-close (no repaint)
//   CON  Conviction + veto   : weighted 0-100 score, tiers, hard vetoes
//   RISK Position framework   : ATR stop, R-multiple targets, % -risk sizing
//   OPT  Option strike (OFF) : optional Call/Put strike + delta-band hint
//   VIS  Dashboard + pane plots + price-side trade levels
//
// NOTE: OPT is a SUGGESTION layer only. Pine cannot read an options chain or
// backtest option P&L; strikes are derived from price and the strike interval.
// This is a study/indicator, not a strategy and not financial advice.
// =============================================================================

//@version=6
indicator("Adaptive MACD — Regime, Volatility Bands & Conviction", shorttitle="MACD ARC", overlay=false,
     max_lines_count=100, max_labels_count=200, precision=2)

// =============================================================================
// HELPERS  (UDFs may only use their args + built-ins, never globals)
// =============================================================================
f_clamp(x, lo, hi) => math.max(lo, math.min(hi, x))

// Adaptive EMA that accepts a SERIES length (built-in ta.ema needs simple int).
f_aema(src, len) =>
    a = 2.0 / (math.max(len, 1) + 1)
    var float e = na
    e := na(e[1]) ? src : e[1] + a * (src - e[1])
    e

// Robust fixed-length MACD direction, safe inside request.security.
f_mtfsign() =>
    f = ta.ema(close, 12)
    s = ta.ema(close, 26)
    m = f - s
    g = ta.ema(m, 9)
    math.sign(m - g)

f_fetch(sym) => request.security(sym, timeframe.period, close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
f_pos(s)     => s=="top_left"?position.top_left : s=="bottom_right"?position.bottom_right : s=="bottom_left"?position.bottom_left : position.top_right
chk(b)       => b ? "✓" : "✗"
sgn(x)       => x>=0 ? "+" : ""

// =============================================================================
// INPUTS
// =============================================================================
gCore   = "L1 · Core"
src_in  = input.source(close, "Price source", group=gCore, tooltip="The series the whole engine runs on. Works on any symbol/market. Use close for most cases; hl2/hlc3/ohlc4 to smooth, or another indicator's plot to run this on top of it.")
useVW   = input.bool  (true,  "Volume-weight source (VWMA pre-filter)", group=gCore)
vwLen   = input.int   (10,    "  VWMA length", minval=2, maxval=50, group=gCore)
normLen = input.int   (100,   "Z-score normalization window", minval=20, maxval=500, group=gCore)

gCyc    = "L3 · Adaptive Construction"
cycMode = input.string("Homodyne", "Length driver", options=["Homodyne","Volatility","Fixed"], group=gCyc)
fastMin = input.int   (6,    "Fast length min", minval=2, maxval=30, group=gCyc)
fastMax = input.int   (16,   "Fast length max", minval=4, maxval=60, group=gCyc)
slowRat = input.float (2.16, "Slow/Fast ratio", minval=1.2, maxval=4.0, step=0.01, group=gCyc)
sigRat  = input.float (0.75, "Signal/Fast ratio", minval=0.3, maxval=2.0, step=0.05, group=gCyc)
fastFix = input.int   (12,   "Fixed fast", minval=2, group=gCyc)
slowFix = input.int   (26,   "Fixed slow", minval=4, group=gCyc)
sigFix  = input.int   (9,    "Fixed signal", minval=2, group=gCyc)

gReg    = "L2 · Regime"
erLen   = input.int   (14,   "Efficiency-ratio length", minval=4, maxval=50, group=gReg)
adxLen  = input.int   (14,   "ADX length", minval=4, maxval=50, group=gReg)
adxTrd  = input.float (20.0, "ADX trend threshold", minval=10, maxval=40, group=gReg)
erTrd   = input.float (0.35, "ER trend threshold", minval=0.1, maxval=0.9, step=0.01, group=gReg)
hawkK   = input.float (0.20, "Hawkes decay k", minval=0.02, maxval=0.9, step=0.01, group=gReg)
hawkThr = input.float (1.5,  "Vol-cluster z threshold", minval=0.5, maxval=4.0, step=0.1, group=gReg)
regMaLn = input.int   (50,   "Regime trend MA", minval=10, maxval=200, group=gReg)

gSig    = "L4 · Signals"
exhaustZ= input.float (2.0,  "Exhaustion band (sigma)", minval=1.0, maxval=4.0, step=0.1, group=gSig)
pvL     = input.int   (5,    "Divergence pivot left",  minval=2, maxval=20, group=gSig)
pvR     = input.int   (3,    "Divergence pivot right", minval=1, maxval=10, group=gSig)

gSqz    = "Squeeze (TTM-style) + Pane"
showSqz = input.bool  (true, "Squeeze bands in lower pane", group=gSqz)
sqLen   = input.int   (20,   "  Squeeze length", minval=5, maxval=100, group=gSqz)
sqBBm   = input.float (2.0,  "  Bollinger mult", minval=1.0, maxval=4.0, step=0.1, group=gSqz)
sqKCm   = input.float (1.5,  "  Keltner mult",   minval=1.0, maxval=4.0, step=0.1, group=gSqz)
sqExtPct= input.int   (20,   "  Extreme threshold (BB-width %ile)", minval=1, maxval=50, group=gSqz)
sqzRel  = input.int   (8,    "  Release window (bars)", minval=1, maxval=30, group=gSqz)
showExtZ= input.bool  (true, "Shade extreme zones in lower pane", group=gSqz)

gMtf    = "MTF · Confluence"
useMtf  = input.bool  (true, "Enable MTF ribbon", group=gMtf)
tf1     = input.timeframe("3",  "TF 1", group=gMtf)
tf2     = input.timeframe("5",  "TF 2", group=gMtf)
tf3     = input.timeframe("15", "TF 3", group=gMtf)
tf4     = input.timeframe("60", "TF 4", group=gMtf)
minAlign= input.int   (3,    "Min TF agreement (else veto)", minval=1, maxval=4, group=gMtf)
useHtfGate=input.bool (true, "Higher-TF bias gate (block counter-trend)", group=gMtf)
htfTf   = input.timeframe("60", "  Higher timeframe", group=gMtf)
confirmClose=input.bool(true,"Confirm signals on bar close (no repaint)", group=gMtf)

gData   = "Optional Reference Feeds (all optional, degrade gracefully)"
spotSym = input.symbol("NSE:NIFTY",    "Reference / underlying symbol", group=gData, tooltip="A related symbol used for a 'basis' read (e.g. the cash index behind a future, or any correlated instrument). Default is NSE:NIFTY — change it to suit your market, or blank = off.")
vixSym  = input.symbol("NSE:INDIAVIX", "Volatility-index symbol", group=gData, tooltip="A volatility-index symbol for your market. Default is NSE:INDIAVIX (pairs with the Nifty default). Used as a spike filter. Change to your market's VIX, or blank = off.")
oiSym   = input.string("",  "Open-interest symbol", group=gData, tooltip="Optional. An open-interest series for the traded instrument, if your data provider exposes one. Blank = off.")
xaSym   = input.string("TVC:DXY",  "Cross-asset symbol", group=gData, tooltip="A second instrument used as momentum confluence. Default TVC:DXY (US Dollar Index) — broadly inverse to Nifty, so pair it with sign -1. Change to suit your market (e.g. FX_IDC:USDINR, SP:SPX), or blank = off. If it reads invalid in the FEEDS row, try another provider prefix (e.g. CAPITALCOM:DXY).")
xaSign  = input.int   (-1,   "Cross-asset correlation sign", options=[1,-1], group=gData)
ltfRes  = input.timeframe("1", "Intrabar resolution (CVD)", group=gData)
basisLen= input.int   (50,   "Basis z window", minval=10, maxval=200, group=gData)
vixLen  = input.int   (50,   "VIX z window", minval=10, maxval=200, group=gData)
xaLen   = input.int   (10,   "Cross-asset momentum lookback", minval=2, maxval=50, group=gData)
vixSpk  = input.float (1.5,  "VIX spike z (veto entries)", minval=0.5, maxval=4.0, step=0.1, group=gData)

gCon    = "CON · Conviction"
minConv = input.int   (45,   "Min conviction to act", minval=0, maxval=100, group=gCon)
wCore   = input.float (30,   "Weight: core MACD", group=gCon)
wMtf    = input.float (20,   "Weight: MTF", group=gCon)
wCvd    = input.float (12,   "Weight: CVD", group=gCon)
wOi     = input.float (14,   "Weight: OI", group=gCon)
wBasis  = input.float (8,    "Weight: basis", group=gCon)
wReg    = input.float (10,   "Weight: regime", group=gCon)
wXa     = input.float (6,    "Weight: cross-asset", group=gCon)
wFade   = input.float (8,    "Weight: band fade", group=gCon)

gExec   = "Risk & Position Sizing"
atrLen  = input.int   (14,   "ATR length", minval=4, maxval=50, group=gExec)
stopMult= input.float (1.5,  "Stop = ATR x", minval=0.5, maxval=5.0, step=0.1, group=gExec)
equity  = input.float (1000000, "Account equity", group=gExec, tooltip="Your account size in the instrument's currency. Only used to suggest a position size; change to your own value.")
riskPct = input.float (1.0,  "Risk % per trade", minval=0.1, maxval=10, step=0.1, group=gExec)
ptValue = input.float (1.0,  "Value per 1.0 price move (per contract)", minval=0.01, group=gExec, tooltip="Currency value of a 1.0 move in price for one unit/contract/share. Stocks = 1. Futures = the contract point value. Used only for size suggestion.")

gOpt    = "Option Strike Hint (default OFF)"
useOpt  = input.bool  (false, "Suggest a Call/Put strike", group=gOpt, tooltip="Optional convenience only: rounds price to the nearest strike and labels a Call (long bias) or Put (short bias). No options-chain data is used.")
optHorz = input.string("Session", "Horizon", options=["Scalp","Swing","Session"], group=gOpt)
strikeInt=input.float (50.0, "Strike interval", minval=0.5, group=gOpt, tooltip="Strike spacing for your instrument's option chain.")

gVis    = "VIS · Display"
showTbl = input.bool  (true, "Show dashboard", group=gVis)
compactTbl=input.bool (true, "Compact dashboard (off = full 24-row)", group=gVis)
tblTheme= input.string("Auto", "Dashboard theme", options=["Auto","Dark","Light"], group=gVis, tooltip="Auto detects the chart background and flips text/panel colors so the table stays readable on white or black charts.")
showId  = input.bool  (true, "Show name / symbol / timeframe label", group=gVis, tooltip="Prints the script name, current symbol and timeframe on the chart so it is always clear what is plotted.")
tblPos  = input.string("top_right", "Dashboard position", options=["top_right","top_left","bottom_right","bottom_left"], group=gVis)
showRibbon=input.bool (true, "Volatility band on PRICE (vol-weighted σ)", group=gVis)
ribLen  = input.int   (34,   "  Band window (bars)", minval=8, maxval=300, group=gVis)
ribK1   = input.float (1.0,  "  Inner band (σ)", minval=0.5, maxval=3.0, step=0.1, group=gVis)
ribK2   = input.float (2.0,  "  Outer band (σ)", minval=1.0, maxval=4.0, step=0.1, group=gVis)
showFade= input.bool  (true, "Fade signal at outer band (range only)", group=gVis)
fillOsc = input.bool  (true, "Filled oscillator (off = histogram)", group=gVis)
showDiv = input.bool  (true, "Divergence as lines (price + pane)", group=gVis)
divKeep = input.int   (6,    "  divergence lines to keep on chart", minval=1, maxval=30, group=gVis)
showCards = input.bool(false,"Live trade-card label (detail is in the table)", group=gVis)
showExits = input.bool(true, "Exit markers (target / stop)", group=gVis)
sigOnPrice= input.bool(true, "Entry signals on PRICE chart", group=gVis)
lvlOnPrice= input.bool(true, "Active Entry/SL/TP lines on PRICE", group=gVis)
lvlOffset = input.int (12,   "  Trade-line extend (bars right)", minval=2, maxval=80, group=gVis)
bgOnPrice = input.bool(false,"Tint PRICE background by regime", group=gVis)
paneCross = input.bool(false,"Show every cross in PANE (noisy)", group=gVis)

// =============================================================================
// L3 — ADAPTIVE CONSTRUCTION (Ehlers Homodyne dominant cycle)
// Output is hard-clamped, so a poor cycle estimate yields a bounded length,
// never a crash. Switch to Volatility/Fixed via input if you prefer.
// =============================================================================
hl2src = (high + low) / 2.0
var float Period = 12.0
Smooth = (4*hl2src + 3*hl2src[1] + 2*hl2src[2] + hl2src[3]) / 10.0
adj  = (0.075*Period + 0.54)
Detr = (0.0962*Smooth + 0.5769*nz(Smooth[2]) - 0.5769*nz(Smooth[4]) - 0.0962*nz(Smooth[6])) * adj
Q1   = (0.0962*Detr + 0.5769*nz(Detr[2]) - 0.5769*nz(Detr[4]) - 0.0962*nz(Detr[6])) * adj
I1   = nz(Detr[3])
jI   = (0.0962*I1 + 0.5769*nz(I1[2]) - 0.5769*nz(I1[4]) - 0.0962*nz(I1[6])) * adj
jQ   = (0.0962*Q1 + 0.5769*nz(Q1[2]) - 0.5769*nz(Q1[4]) - 0.0962*nz(Q1[6])) * adj
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

// Efficiency ratio (also reused by L2)
erChg = math.abs(src_in - src_in[erLen])
erVol = math.sum(math.abs(src_in - src_in[1]), erLen)
er    = erVol == 0 ? 0.0 : erChg / erVol

// Derive MACD lengths per mode
float fastLen = na
float slowLen = na
float sigLen  = na
if cycMode == "Fixed"
    fastLen := fastFix
    slowLen := slowFix
    sigLen  := sigFix
else if cycMode == "Volatility"
    fastLen := math.round(fastMax - (fastMax - fastMin) * er)
    slowLen := math.round(fastLen * slowRat)
    sigLen  := math.round(fastLen * sigRat)
else
    fastLen := f_clamp(math.round(domCycle * 0.5), fastMin, fastMax)
    slowLen := math.round(fastLen * slowRat)
    sigLen  := math.max(2, math.round(fastLen * sigRat))

// =============================================================================
// L1 — SIGNAL COMPUTATION
// =============================================================================
volLive = not na(volume) and not na(volume[1])
vwNum   = math.sum(src_in * volume, vwLen)
vwDen   = math.max(math.sum(volume, vwLen), 1e-9)
vwSrc   = (useVW and volLive) ? (vwNum / vwDen) : src_in

macdLine   = f_aema(vwSrc, fastLen) - f_aema(vwSrc, slowLen)
signalLine = f_aema(macdLine, sigLen)
hist       = macdLine - signalLine

hMean = ta.sma(hist, normLen)
hStd  = ta.stdev(hist, normLen)
zHist = hStd == 0 ? 0.0 : (hist - hMean) / hStd
mMean = ta.sma(macdLine, normLen)
mStd  = ta.stdev(macdLine, normLen)
zMacd = mStd == 0 ? 0.0 : (macdLine - mMean) / mStd

// CVD via intrabar lower-tf delta, with chart-bar fallback
ltfArr = request.security_lower_tf(syminfo.tickerid, ltfRes, (close >= open ? 1.0 : -1.0) * nz(volume))
ltfOk  = array.size(ltfArr) > 0
barDelta = ltfOk ? array.sum(ltfArr) : (close >= open ? 1.0 : -1.0) * nz(volume)
cvd      = ta.cum(barDelta)
cvdSlope = cvd - nz(cvd[5], cvd)
cvdSign  = math.sign(cvdSlope)
cvdLive  = volLive
cvdConfirm = (cvdSign == math.sign(zHist)) and zHist != 0

// =============================================================================
// L2 — REGIME
// =============================================================================
[diP, diM, adx] = ta.dmi(adxLen, adxLen)
logRet = math.abs(nz(ta.change(math.log(close))))
var float hawkes = 0.0
hawkes := hawkes * math.exp(-hawkK) + logRet
hMeanH = ta.sma(hawkes, normLen)
hStdH  = ta.stdev(hawkes, normLen)
hawkesZ = hStdH == 0 ? 0.0 : (hawkes - hMeanH) / hStdH
volCluster = hawkesZ > hawkThr

trendMa  = ta.ema(close, regMaLn)
bull     = close > trendMa
trending = adx > adxTrd and er > erTrd
regimePct = math.round(f_clamp((adx/40.0)*50 + er*50, 0, 100))
string regime = volCluster and not trending ? "Volatile" : trending ? (bull ? "Trend Bull" : "Trend Bear") : "Range"
regColor = regime == "Trend Bull" ? color.teal : regime == "Trend Bear" ? color.red : regime == "Volatile" ? color.orange : color.gray
phase = trending ? (bull ? "MARKUP" : "MARKDOWN") : (close > trendMa ? "DISTRIB" : "ACCUM")

// =============================================================================
// L4 — SIGNAL GENERATION
// =============================================================================
crossUp = ta.crossover(macdLine, signalLine)
crossDn = ta.crossunder(macdLine, signalLine)
var int lastCrossDir = 0
if crossUp
    lastCrossDir := 1
if crossDn
    lastCrossDir := -1
barsCross = nz(ta.barssince(crossUp or crossDn), 0)

exhaustLong  = ta.crossover(zHist, exhaustZ * -1)
exhaustShort = ta.crossunder(zHist, exhaustZ)
zeroUp = ta.crossover(macdLine, 0)
zeroDn = ta.crossunder(macdLine, 0)

// Divergence (regular) with quality score
ph = ta.pivothigh(high, pvL, pvR)
pl = ta.pivotlow(low, pvL, pvR)
var float lastPH  = na
var float prevPH  = na
var float lastPHo = na
var float prevPHo = na
var int   lastPHx = na
var int   prevPHx = na
var float lastPL  = na
var float prevPL  = na
var float lastPLo = na
var float prevPLo = na
var int   lastPLx = na
var int   prevPLx = na
if not na(ph)
    prevPH  := lastPH
    lastPH  := ph
    prevPHo := lastPHo
    lastPHo := nz(zHist[pvR])
    prevPHx := lastPHx
    lastPHx := bar_index - pvR
if not na(pl)
    prevPL  := lastPL
    lastPL  := pl
    prevPLo := lastPLo
    lastPLo := nz(zHist[pvR])
    prevPLx := lastPLx
    lastPLx := bar_index - pvR
bearDiv = not na(prevPH) and lastPH > prevPH and lastPHo < prevPHo
bullDiv = not na(prevPL) and lastPL < prevPL and lastPLo > prevPLo
float divScore = 0.0
if bearDiv or bullDiv
    mag = math.abs(nz(bearDiv ? (lastPHo-prevPHo) : (lastPLo-prevPLo)))
    divScore := f_clamp(40 + mag*20 + (cvdConfirm?20:0) + (math.abs(zHist)>1.5?15:0), 0, 100)
divDir = bullDiv ? 1 : bearDiv ? -1 : 0

// =============================================================================
// L4b — VOLUME-WEIGHTED σ BAND + FADE (mean-reversion at extremes)
// Rolling volume-weighted mean ± σ. Index/no-volume falls back to unweighted.
// =============================================================================
rvVol   = (na(volume) or volume <= 0) ? 1.0 : volume
rvW     = math.sum(rvVol, ribLen)
rvPV    = math.sum(src_in * rvVol, ribLen)
rvP2    = math.sum(src_in * src_in * rvVol, ribLen)
ribMean = rvW > 0 ? rvPV / rvW : na
ribVar  = rvW > 0 ? (rvP2 / rvW - ribMean * ribMean) : 0.0
ribSD   = math.sqrt(math.max(nz(ribVar), 0.0))
ribUp1  = ribMean + ribSD * ribK1
ribDn1  = ribMean - ribSD * ribK1
ribUp2  = ribMean + ribSD * ribK2
ribDn2  = ribMean - ribSD * ribK2
zBand   = (not na(ribSD) and ribSD > 0) ? (close - ribMean) / ribSD : 0.0
// Signal confirmation: when on, signals only commit on a closed bar (no repaint)
barConfirmed = not confirmClose or barstate.isconfirmed
// Outer-band tag then close back inside = rejection. Only fade OUT of trend.
upRej   = high >= ribUp2 and close < ribUp2
dnRej   = low  <= ribDn2 and close > ribDn2
fadeDown = showFade and upRej and regime != "Trend Bull" and barConfirmed
fadeUp   = showFade and dnRej and regime != "Trend Bear" and barConfirmed
var int fadeBar = na
var int fadeDir = 0
if fadeUp
    fadeBar := bar_index
    fadeDir := 1
if fadeDown
    fadeBar := bar_index
    fadeDir := -1
fadeActive = not na(fadeBar) and (bar_index - fadeBar) <= 5
fadeScore  = fadeActive ? fadeDir : 0

// =============================================================================
// L4c — SQUEEZE (TTM-style: Bollinger Bands inside Keltner = compression)
// =============================================================================
sqBasis   = ta.sma(close, sqLen)
sqDev     = sqBBm * ta.stdev(close, sqLen)
sqKcMid   = ta.ema(close, sqLen)
sqKcRange = sqKCm * ta.atr(sqLen)
sqBbU     = sqBasis + sqDev
sqBbL     = sqBasis - sqDev
sqInKC    = sqBbL > (sqKcMid - sqKcRange) and sqBbU < (sqKcMid + sqKcRange)
sqWidth   = sqBasis != 0 ? (sqBbU - sqBbL) / sqBasis : 0.0
sqRank    = ta.percentrank(sqWidth, 100)            // low rank = genuinely pinched
sqzOn     = sqInKC and sqRank <= sqExtPct           // EXTREME squeeze only
sqzFired  = sqzOn[1] and not sqzOn
var int sqzFireBar = na
if sqzFired
    sqzFireBar := bar_index
sqzPostFire = not na(sqzFireBar) and (bar_index - sqzFireBar) <= sqzRel and not sqzOn

// =============================================================================
// MTF — CONFLUENCE
// =============================================================================
mtf1 = useMtf ? nz(request.security(syminfo.tickerid, tf1, f_mtfsign(), lookahead=barmerge.lookahead_off)) : 0
mtf2 = useMtf ? nz(request.security(syminfo.tickerid, tf2, f_mtfsign(), lookahead=barmerge.lookahead_off)) : 0
mtf3 = useMtf ? nz(request.security(syminfo.tickerid, tf3, f_mtfsign(), lookahead=barmerge.lookahead_off)) : 0
mtf4 = useMtf ? nz(request.security(syminfo.tickerid, tf4, f_mtfsign(), lookahead=barmerge.lookahead_off)) : 0
mtfBull = (mtf1>0?1:0)+(mtf2>0?1:0)+(mtf3>0?1:0)+(mtf4>0?1:0)
mtfBear = (mtf1<0?1:0)+(mtf2<0?1:0)+(mtf3<0?1:0)+(mtf4<0?1:0)
mtfNet  = (mtfBull - mtfBear) / 4.0
htfBias = useHtfGate ? nz(request.security(syminfo.tickerid, htfTf, f_mtfsign(), lookahead=barmerge.lookahead_off)) : 0

// =============================================================================
// OPTIONAL DATA FEEDS (all graceful via ignore_invalid_symbol)
// =============================================================================
spot = f_fetch(spotSym)
vix  = f_fetch(vixSym)
oiSymUse = str.length(oiSym) > 0 ? oiSym : syminfo.tickerid
oiRaw = request.security(oiSymUse, timeframe.period, close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
oi = str.length(oiSym) > 0 ? oiRaw : na
xaSymUse = str.length(xaSym) > 0 ? xaSym : syminfo.tickerid
xaRaw = request.security(xaSymUse, timeframe.period, close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
xa = str.length(xaSym) > 0 ? xaRaw : na

spotLive = not na(spot) and spot != 0
vixLive  = not na(vix)
oiLive   = not na(oi) and not na(oi[1])
xaLive   = not na(xa) and not na(xa[xaLen])

float basisPct = na
float basisZ   = 0.0
if spotLive
    basis = close - spot
    basisPct := basis / spot * 100.0
    bMean = ta.sma(basis, basisLen)
    bStd  = ta.stdev(basis, basisLen)
    basisZ := bStd == 0 ? 0.0 : (basis - bMean) / bStd

float vixZ = 0.0
if vixLive
    vMean = ta.sma(vix, vixLen)
    vStd  = ta.stdev(vix, vixLen)
    vixZ := vStd == 0 ? 0.0 : (vix - vMean) / vStd
vixSpike = vixLive and vixZ > vixSpk

string oiTxt = "n/a"
float  oiScore = 0.0
bool longBuildup  = false
bool shortBuildup = false
bool longUnwind   = false
bool shortCover   = false
if oiLive
    dOI = oi - oi[1]
    dP  = close - close[1]
    longBuildup  := dP>0 and dOI>0
    shortBuildup := dP<0 and dOI>0
    longUnwind   := dP<0 and dOI<0
    shortCover   := dP>0 and dOI<0
    oiTxt := longBuildup?"Long buildup" : shortBuildup?"Short buildup" : longUnwind?"Long unwind" : shortCover?"Short cover" : "flat"
    oiScore := longBuildup?1.0 : shortCover?0.4 : shortBuildup?-1.0 : longUnwind?-0.4 : 0.0

float xaScore = 0.0
if xaLive
    xaScore := math.sign(xa - xa[xaLen]) * xaSign

// =============================================================================
// CON — CONVICTION + VETO (dynamic reweighting over LIVE components)
// =============================================================================
coreScore = f_clamp(zHist/2.0, -1, 1)
float wsum = 0.0
float wtot = 0.0
wsum := wsum + coreScore * wCore
wtot := wtot + wCore
if useMtf
    wsum := wsum + mtfNet * wMtf
    wtot := wtot + wMtf
if cvdLive
    wsum := wsum + cvdSign * wCvd
    wtot := wtot + wCvd
if oiLive
    wsum := wsum + oiScore * wOi
    wtot := wtot + wOi
if spotLive
    wsum := wsum + f_clamp(basisZ/2.0, -1, 1) * wBasis
    wtot := wtot + wBasis
regScore = regime=="Trend Bull"?0.6 : regime=="Trend Bear"?-0.6 : 0.0
wsum := wsum + regScore * wReg
wtot := wtot + wReg
if xaLive
    wsum := wsum + xaScore * wXa
    wtot := wtot + wXa
if showFade and fadeActive
    wsum := wsum + fadeScore * wFade
    wtot := wtot + wFade

combined = wtot > 0 ? wsum/wtot : 0.0
dir = combined > 0 ? 1 : combined < 0 ? -1 : 0
convRaw = math.round(math.abs(combined) * 100)
conv = vixSpike ? math.round(convRaw * 0.6) : convRaw
string tier = conv>=75?"S" : conv>=60?"A" : conv>=45?"B" : "-"

alignInDir = dir>0 ? mtfBull : dir<0 ? mtfBear : 0
vRegime = (dir>0 and regime=="Trend Bear") or (dir<0 and regime=="Trend Bull")
vMtf    = useMtf and dir!=0 and alignInDir < minAlign
vCvd    = cvdLive and dir!=0 and (math.sign(cvdSlope) == -dir)
vOi     = oiLive and ((dir>0 and shortBuildup) or (dir<0 and longBuildup))
vVix    = vixSpike
vZ      = math.abs(zHist) < 0.5
vHtf    = useHtfGate and dir!=0 and ((dir>0 and htfBias<0) or (dir<0 and htfBias>0))
anyVeto = vRegime or vMtf or vCvd or vOi or vVix or vZ or vHtf

string vetoTxt = ""
vetoTxt := vetoTxt + (vRegime?"regime ":"")
vetoTxt := vetoTxt + (vMtf?"mtf ":"")
vetoTxt := vetoTxt + (vCvd?"cvd ":"")
vetoTxt := vetoTxt + (vOi?"oi ":"")
vetoTxt := vetoTxt + (vVix?"vix ":"")
vetoTxt := vetoTxt + (vZ?"flat-z ":"")
vetoTxt := vetoTxt + (vHtf?"htf ":"")
vetoTxt := vetoTxt == "" ? "none" : vetoTxt

string verdict = conv < minConv or dir==0 ? "FLAT" : anyVeto ? "VETO" : dir>0 ? "LONG" : "SHORT"

// =============================================================================
// RISK & POSITION FRAMEWORK  (ATR stop, R-targets, %-risk size suggestion)
// =============================================================================
atr = ta.atr(atrLen)
stopDist = atr * stopMult
var int posDir = 0
var float entryPx = na
var float stopPx  = na
var float t1 = na
var float t2 = na
longTrig  = verdict=="LONG"  and posDir<=0 and barConfirmed
shortTrig = verdict=="SHORT" and posDir>=0 and barConfirmed
if longTrig
    posDir  := 1
    entryPx := close
    stopPx  := close - stopDist
    t1      := close + stopDist
    t2      := close + 2*stopDist
if shortTrig
    posDir  := -1
    entryPx := close
    stopPx  := close + stopDist
    t1      := close - stopDist
    t2      := close - 2*stopDist
bool exitLong  = false
bool exitShort = false
bool exitWin   = false
if posDir == 1
    if high>=t1 and stopPx<entryPx
        stopPx := entryPx
    if high>=t2
        exitLong := true
        exitWin  := true
        posDir   := 0
    else if low<=stopPx
        exitLong := true
        exitWin  := stopPx >= entryPx
        posDir   := 0
if posDir == -1
    if low<=t1 and stopPx>entryPx
        stopPx := entryPx
    if low<=t2
        exitShort := true
        exitWin   := true
        posDir    := 0
    else if high>=stopPx
        exitShort := true
        exitWin   := stopPx <= entryPx
        posDir    := 0
inTrade = posDir != 0
riskCap = equity * riskPct / 100.0
perLot  = stopDist * ptValue
lots = perLot > 0 ? math.floor(riskCap / perLot) : 0

// Price / stop strings reused by alerts, trade labels and the dashboard
mt = str.tostring(close,  format.mintick)
ms = str.tostring(stopPx, format.mintick)

// =============================================================================
// OPT — OPTIONS SUGGESTION (default OFF) — suggestion only, no chain access
// =============================================================================
string optTxt = "off"
if useOpt and (verdict=="LONG" or verdict=="SHORT")
    isCE = verdict=="LONG"
    dBand = optHorz=="Scalp" ? "0.55-0.65 ATM" : optHorz=="Swing" ? "0.45-0.55" : "0.35-0.45 OTM"
    atmStrike = math.round(close / strikeInt) * strikeInt
    offset = optHorz=="Session" ? strikeInt : 0.0
    sugStrike = isCE ? atmStrike + offset : atmStrike - offset
    optTxt := (isCE?"CALL ":"PUT ") + str.tostring(sugStrike, "#.##") + " d" + dBand

// =============================================================================
// VIS — LOWER PANE  (analytics layer: what you read)
// =============================================================================
zAreaCol = zHist >= 0 ? color.new(color.teal, 38) : color.new(color.red, 38)
zColCol  = zHist >= 0 ? (zHist >= zHist[1] ? color.new(color.teal,0) : color.new(color.teal,55)) : (zHist <= zHist[1] ? color.new(color.red,0) : color.new(color.red,55))
plot(fillOsc     ? zHist : na, "Z-Hist (area)", color=zAreaCol, style=plot.style_area)
plot(not fillOsc ? zHist : na, "Z-Hist (cols)", color=zColCol,  style=plot.style_columns)
plot(zMacd, "Z-MACD", color=color.new(color.aqua,0), linewidth=2)
// extreme-zone shading (red above +σ band, green below -σ band)
pExT = plot(exhaustZ,      "Exh+", color=color.new(color.red,70))
pExB = plot(exhaustZ * -1, "Exh-", color=color.new(color.teal,70))
pCapT = plot(showExtZ ? 4.0  : na, "cap+", color=na)
pCapB = plot(showExtZ ? -4.0 : na, "cap-", color=na)
fill(pExT, pCapT, color=showExtZ ? color.new(color.red,  88) : na)
fill(pExB, pCapB, color=showExtZ ? color.new(color.teal, 88) : na)
hline(0, "Zero", color=color.new(color.gray,55))
// squeeze (extreme only): red dots on TOP while genuinely pinched (squeeze ON),
// green dots on BOTTOM through the release window right after it fires.
plotshape(showSqz and sqzOn,       "Squeeze ON",    shape.circle, location.top,    color.new(color.red,0),  size=size.tiny)
plotshape(showSqz and sqzPostFire, "Squeeze fired", shape.circle, location.bottom, color.new(color.lime,0), size=size.tiny)
plotshape(paneCross and crossUp, "Bull cross", shape.triangleup,   location.bottom, color.new(color.teal,0), size=size.tiny)
plotshape(paneCross and crossDn, "Bear cross", shape.triangledown, location.top,    color.new(color.red,0),  size=size.tiny)

// =============================================================================
// VIS — PRICE: volatility band (vol-weighted σ) with reversion-heat fill
// midline color = bias; fill = how stretched (red top / green bottom, denser out)
// =============================================================================
ribBull = regime == "Trend Bull" or (regime != "Trend Bear" and zHist >= 0)
ribLine = ribBull ? color.teal : color.rgb(236, 64, 122)
pMid = plot(showRibbon ? ribMean : na, "Band mid", color=color.new(ribLine,20), linewidth=2, force_overlay=true)
pU1c = plot(showRibbon ? ribUp1  : na, "+1 sigma", color=color.new(color.red,78),  force_overlay=true)
pU2c = plot(showRibbon ? ribUp2  : na, "+2 sigma", color=color.new(color.red,60),  force_overlay=true)
pD1c = plot(showRibbon ? ribDn1  : na, "-1 sigma", color=color.new(color.teal,78), force_overlay=true)
pD2c = plot(showRibbon ? ribDn2  : na, "-2 sigma", color=color.new(color.teal,60), force_overlay=true)
fill(pMid, pU1c, color=color.new(color.red, 92))
fill(pU1c, pU2c, color=color.new(color.red, 82))
fill(pMid, pD1c, color=color.new(color.teal, 92))
fill(pD1c, pD2c, color=color.new(color.teal, 82))

// =============================================================================
// VIS — PRICE: entries, exits (what you trade)
// =============================================================================
strongLong  = longTrig  and conv>=60
weakLong    = longTrig  and conv<60
strongShort = shortTrig and conv>=60
weakShort   = shortTrig and conv<60
plotshape(sigOnPrice and strongLong,  "LONG+",  shape.triangleup,   location.belowbar, color.new(color.teal,0),  size=size.small, force_overlay=true)
plotshape(sigOnPrice and weakLong,    "LONG",   shape.triangleup,   location.belowbar, color.new(color.teal,45), size=size.tiny,  force_overlay=true)
plotshape(sigOnPrice and strongShort, "SHORT+", shape.triangledown, location.abovebar, color.new(color.red,0),   size=size.small, force_overlay=true)
plotshape(sigOnPrice and weakShort,   "SHORT",  shape.triangledown, location.abovebar, color.new(color.red,45),  size=size.tiny,  force_overlay=true)
plotshape(showExits and (exitLong  and exitWin),     "TP long",  shape.xcross, location.abovebar, color.new(color.green,0),  size=size.tiny, force_overlay=true)
plotshape(showExits and (exitLong  and not exitWin), "SL long",  shape.xcross, location.belowbar, color.new(color.maroon,0), size=size.tiny, force_overlay=true)
plotshape(showExits and (exitShort and exitWin),     "TP short", shape.xcross, location.belowbar, color.new(color.green,0),  size=size.tiny, force_overlay=true)
plotshape(showExits and (exitShort and not exitWin), "SL short", shape.xcross, location.abovebar, color.new(color.maroon,0), size=size.tiny, force_overlay=true)
bgcolor(bgOnPrice ? color.new(regColor, 90) : na, force_overlay=true)

// Active trade — thin Entry / SL / TP1 / TP2 lines + right-side labels.
// Only the CURRENT trade is shown: a new entry deletes the previous trade's
// lines & labels; while flat the last trade's lines stay frozen until replaced.
var line  meEntry = na
var line  meSL    = na
var line  meT1    = na
var line  meT2    = na
var label leEntry = na
var label leSL    = na
var label leT1    = na
var label leT2    = na
drawTrade = lvlOnPrice and (longTrig or shortTrig)
if drawTrade
    line.delete(meEntry)
    line.delete(meSL)
    line.delete(meT1)
    line.delete(meT2)
    label.delete(leEntry)
    label.delete(leSL)
    label.delete(leT1)
    label.delete(leT2)
    int xr = bar_index + lvlOffset
    meEntry := line.new(bar_index, entryPx, xr, entryPx, xloc.bar_index, color=color.new(color.gray,0),   width=1, style=line.style_solid,  force_overlay=true)
    meSL    := line.new(bar_index, stopPx,  xr, stopPx,  xloc.bar_index, color=color.new(color.red,0),    width=1, style=line.style_solid,  force_overlay=true)
    meT1    := line.new(bar_index, t1,      xr, t1,      xloc.bar_index, color=color.new(color.teal,0),   width=1, style=line.style_dashed, force_overlay=true)
    meT2    := line.new(bar_index, t2,      xr, t2,      xloc.bar_index, color=color.new(color.green,0),  width=1, style=line.style_dashed, force_overlay=true)
    leEntry := label.new(xr, entryPx, "ENTRY " + str.tostring(entryPx, format.mintick), xloc.bar_index, style=label.style_label_left, color=color.new(color.gray,25),  textcolor=color.white, size=size.tiny, force_overlay=true)
    leSL    := label.new(xr, stopPx,  "SL " + str.tostring(stopPx, format.mintick),     xloc.bar_index, style=label.style_label_left, color=color.new(color.red,15),   textcolor=color.white, size=size.tiny, force_overlay=true)
    leT1    := label.new(xr, t1,      "TP1 " + str.tostring(t1, format.mintick),        xloc.bar_index, style=label.style_label_left, color=color.new(color.teal,15),  textcolor=color.white, size=size.tiny, force_overlay=true)
    leT2    := label.new(xr, t2,      "TP2 " + str.tostring(t2, format.mintick),        xloc.bar_index, style=label.style_label_left, color=color.new(color.green,15), textcolor=color.white, size=size.tiny, force_overlay=true)
if lvlOnPrice and inTrade and not drawTrade and not na(meEntry)
    int xr = bar_index + lvlOffset
    line.set_x2(meEntry, xr)
    line.set_x2(meSL, xr)
    line.set_x2(meT1, xr)
    line.set_x2(meT2, xr)
    line.set_y1(meSL, stopPx)
    line.set_y2(meSL, stopPx)
    label.set_x(leEntry, xr)
    label.set_x(leSL, xr)
    label.set_x(leT1, xr)
    label.set_x(leT2, xr)
    label.set_y(leSL, stopPx)
    label.set_text(leSL, "SL " + str.tostring(stopPx, format.mintick))

// Single live trade card (current trade only — moves to the latest entry)
var label tradeCard = na
if showCards and (longTrig or shortTrig)
    if not na(tradeCard)
        label.delete(tradeCard)
    bool isL = longTrig
    tradeCard := label.new(bar_index, isL?low:high, (isL?"BUY ":"SELL ")+mt+"\nSL "+ms+"  T "+str.tostring(t2,format.mintick)+"\n"+str.tostring(lots)+" units · "+tier, style=isL?label.style_label_up:label.style_label_down, color=isL?color.new(color.teal,8):color.new(color.red,8), textcolor=color.white, size=size.small, force_overlay=true)

// =============================================================================
// VIS — DIVERGENCE LINES  (PRICE CHART ONLY — keeps last N)
// =============================================================================
var array<line>  divPx = array.new<line>()
var array<label> divLb = array.new<label>()
if showDiv and bearDiv and not na(ph) and not na(prevPHx)
    array.push(divPx, line.new(prevPHx, prevPH, lastPHx, lastPH, xloc.bar_index, color=color.new(color.fuchsia,0), width=2, force_overlay=true))
    array.push(divLb, label.new(lastPHx, lastPH, "Bear div", style=label.style_label_down, color=color.new(color.fuchsia,12), textcolor=color.white, size=size.tiny, force_overlay=true))
if showDiv and bullDiv and not na(pl) and not na(prevPLx)
    array.push(divPx, line.new(prevPLx, prevPL, lastPLx, lastPL, xloc.bar_index, color=color.new(color.lime,0), width=2, force_overlay=true))
    array.push(divLb, label.new(lastPLx, lastPL, "Bull div", style=label.style_label_up, color=color.new(color.lime,12), textcolor=color.black, size=size.tiny, force_overlay=true))
while array.size(divPx) > divKeep
    line.delete(array.shift(divPx))
    label.delete(array.shift(divLb))

// Fade markers: outer-band rejection in a non-trend regime (capped FIFO)
var array<label> fadeLb = array.new<label>()
if showFade and fadeDown
    array.push(fadeLb, label.new(bar_index, high, "Fade v", style=label.style_label_down, color=color.new(color.red,8),  textcolor=color.white, size=size.tiny, force_overlay=true))
if showFade and fadeUp
    array.push(fadeLb, label.new(bar_index, low,  "Fade ^", style=label.style_label_up,   color=color.new(color.teal,8), textcolor=color.white, size=size.tiny, force_overlay=true))
while array.size(fadeLb) > divKeep
    label.delete(array.shift(fadeLb))

// =============================================================================
// ALERTS (full instruction, fires on bar close)
// =============================================================================
if longTrig
    alert("MACD ARC BUY " + syminfo.ticker + " @ " + mt + "  SL " + ms + "  T " + str.tostring(t2, format.mintick) + "  | conv " + str.tostring(conv) + " (" + tier + ")", alert.freq_once_per_bar_close)
if shortTrig
    alert("MACD ARC SELL " + syminfo.ticker + " @ " + mt + "  SL " + ms + "  T " + str.tostring(t2, format.mintick) + "  | conv " + str.tostring(conv) + " (" + tier + ")", alert.freq_once_per_bar_close)
alertcondition(longTrig,  "MACD ARC Long",  "MACD ARC LONG verdict")
alertcondition(shortTrig, "MACD ARC Short", "MACD ARC SHORT verdict")

// =============================================================================
// VIS — DASHBOARD (compact by default; action folded into a colored header row)
// =============================================================================
var table dash = table.new(f_pos(tblPos), 2, 26, frame_width=1, border_width=1, force_overlay=true)
setrow(tbl, r, lbl, val, vc, lc, bg) =>
    table.cell(tbl, 0, r, lbl, text_color=lc, text_size=size.tiny,  text_halign=text.align_left,  bgcolor=bg)
    table.cell(tbl, 1, r, val, text_color=vc, text_size=size.small, text_halign=text.align_right, bgcolor=bg)
setrowbg(tbl, r, lbl, val, vbg, lc, bg, vtxt) =>
    table.cell(tbl, 0, r, lbl, text_color=lc,   text_size=size.tiny,  text_halign=text.align_left,  bgcolor=bg)
    table.cell(tbl, 1, r, val, text_color=vtxt, text_size=size.small, text_halign=text.align_right, bgcolor=vbg)

if showTbl and barstate.islast
    // ---- adaptive theme: flips panel/text for white or black charts (last-bar only) ----
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
    // ---- table-only strings/colors (here so they don't recompute every bar) ----
    verdColor = verdict=="LONG"?cBull : verdict=="SHORT"?cBear : verdict=="VETO"?cWarn : cMute
    regColT   = regime=="Trend Bull"?cBull : regime=="Trend Bear"?cBear : regime=="Volatile"?cWarn : cMute
    actCol    = longTrig?color.new(cBull,0) : shortTrig?color.new(cBear,0) : posDir==1?color.new(cBull,15) : posDir==-1?color.new(cBear,15) : verdict=="VETO"?color.new(cWarn,0) : color.new(#5b6472,0)
    actShort  = longTrig?"BUY" : shortTrig?"SELL" : posDir==1?"HOLD L" : posDir==-1?"HOLD S" : verdict=="VETO"?"WAIT" : "FLAT"
    actDetail = (longTrig or shortTrig) ? (mt+" SL "+ms) : inTrade ? ("trail "+ms) : verdict=="VETO" ? vetoTxt : "no edge"
    stretchTxt = (na(ribSD) or ribSD==0) ? "n/a" : sgn(zBand)+str.tostring(zBand,"0.0")+"s"+(fadeActive?(fadeDir>0?" Fade^":" Fadev"):"")
    stretchCol = math.abs(zBand)>=ribK2 ? cWarn : math.abs(zBand)>=ribK1 ? cInfo : tVal
    // ---- header (colored action cell; white text reads on light or dark) ----
    table.cell(dash, 0, 0, " > "+actShort+" ", text_color=color.white, text_size=size.small, text_halign=text.align_left,  bgcolor=actCol)
    table.cell(dash, 1, 0, actDetail+" ",      text_color=color.white, text_size=size.small, text_halign=text.align_right, bgcolor=actCol)
    if compactTbl
        setrow(dash, 1,  "VERDICT",  verdict+" · "+str.tostring(conv)+" ("+tier+")", verdColor, tLbl, tBg)
        setrowbg(dash, 2, "ENTRY",   inTrade?str.tostring(entryPx,format.mintick):"-", color.new(cMute,55), tLbl, tBg, tVal)
        setrowbg(dash, 3, "STOP",    inTrade?str.tostring(stopPx,format.mintick):"-", color.new(cBear,25), tLbl, tBg, tVal)
        setrowbg(dash, 4, "TARGET",  inTrade?(str.tostring(t1,format.mintick)+" / "+str.tostring(t2,format.mintick)):"-", color.new(cBull,28), tLbl, tBg, tVal)
        setrow(dash, 5,  "SIZE",     str.tostring(lots)+" units ("+str.tostring(riskPct,"0.0")+"%)", tVal, tLbl, tBg)
        setrow(dash, 6,  "REGIME",   regime+" "+str.tostring(regimePct)+"% "+phase, regColT, tLbl, tBg)
        setrow(dash, 7,  "BIAS",     (useMtf?("MTF "+str.tostring(dir>0?mtfBull:dir<0?mtfBear:math.max(mtfBull,mtfBear))+"/4 "+chk(alignInDir>=minAlign)):"off")+(useHtfGate?(" HTF"+(htfBias>0?"^":htfBias<0?"v":"-")):""), useMtf?(alignInDir>=minAlign?cBull:cWarn):cMute, tLbl, tBg)
        setrow(dash, 8,  "MOMENTUM", sgn(zHist)+str.tostring(zHist,"0.00")+(zHist>=zHist[1]?" ^":" v")+" · "+(lastCrossDir>0?"Bull":lastCrossDir<0?"Bear":"-")+str.tostring(barsCross)+"b", zHist>=0?cBull:cBear, tLbl, tBg)
        setrow(dash, 9,  "STRETCH",  stretchTxt, stretchCol, tLbl, tBg)
        setrow(dash, 10, "DIVERG",   divDir==0?"none":(divDir>0?"bull ":"bear ")+"("+str.tostring(math.round(divScore))+")", divDir>0?cBull:divDir<0?cBear:cMute, tLbl, tBg)
        setrow(dash, 11, "FLOW",     (cvdLive?("CVD "+chk(cvdConfirm)):"CVD n/a")+" · "+(oiLive?oiTxt:"OI n/a"), cvdLive?(cvdConfirm?cBull:cBear):cMute, tLbl, tBg)
        setrow(dash, 12, "CONTEXT",  (spotLive?("bas "+sgn(basisPct)+str.tostring(basisPct,"0.00")+"%"):"bas n/a")+(vixLive?(" VIXz"+sgn(vixZ)+str.tostring(vixZ,"0.0")):""), vixSpike?cWarn:tVal, tLbl, tBg)
        setrow(dash, 13, "VETO",     vetoTxt, vetoTxt=="none"?cMute:cWarn, tLbl, tBg)
        setrow(dash, 14, "FEEDS",    "spot"+chk(spotLive)+" vix"+chk(vixLive)+" oi"+chk(oiLive)+" ltf"+chk(ltfOk), tVal, tLbl, tBg)
    else
        setrow(dash, 1,  "REGIME",   regime + "  " + str.tostring(regimePct) + "%", regColT, tLbl, tBg)
        setrow(dash, 2,  "SCALE",    timeframe.period + "  cyc " + str.tostring(math.round(domCycle)), tVal, tLbl, tBg)
        setrow(dash, 3,  "PHASE",    phase, tVal, tLbl, tBg)
        setrow(dash, 4,  "Z-HIST",   sgn(zHist)+str.tostring(zHist,"0.00") + (zHist>=zHist[1]?" ^":" v"), zHist>=0?cBull:cBear, tLbl, tBg)
        setrow(dash, 5,  "CROSS",    (lastCrossDir>0?"Bull":lastCrossDir<0?"Bear":"none") + " " + str.tostring(barsCross) + "b", lastCrossDir>0?cBull:cBear, tLbl, tBg)
        setrow(dash, 6,  "DIVERG",   divDir==0?"none":(divDir>0?"bull ":"bear ")+"("+str.tostring(math.round(divScore))+")", divDir>0?cBull:divDir<0?cBear:cMute, tLbl, tBg)
        setrow(dash, 7,  "CVD",      cvdLive?(cvdConfirm?"confirming "+chk(true):"divergent "+chk(false)):"n/a", cvdLive?(cvdConfirm?cBull:cBear):cMute, tLbl, tBg)
        setrow(dash, 8,  "OI",       oiTxt + (oiLive?(oiScore>0?" "+chk(true):" "+chk(false)):""), oiLive?(oiScore>0?cBull:cBear):cMute, tLbl, tBg)
        setrow(dash, 9,  "BASIS",    spotLive?(sgn(basisPct)+str.tostring(basisPct,"0.00")+"% Z"+sgn(basisZ)+str.tostring(basisZ,"0.0")):"n/a", spotLive?tVal:cMute, tLbl, tBg)
        setrow(dash, 10, "VIX",      vixLive?("Z"+sgn(vixZ)+str.tostring(vixZ,"0.0")+(vixSpike?" !":"")):"n/a", vixSpike?cWarn:vixLive?tVal:cMute, tLbl, tBg)
        setrow(dash, 11, "MTF",      useMtf?(str.tostring(dir>0?mtfBull:dir<0?mtfBear:math.max(mtfBull,mtfBear))+"/4 "+chk(alignInDir>=minAlign)):"off", useMtf?(alignInDir>=minAlign?cBull:cWarn):cMute, tLbl, tBg)
        setrow(dash, 12, "------",   "------", cMute, tLbl, tBg)
        setrow(dash, 13, "CONVICTION", str.tostring(conv) + " / 100  (" + tier + ")", conv>=60?cBull:conv>=45?cInfo:cMute, tLbl, tBg)
        setrow(dash, 14, "VERDICT",  verdict, verdColor, tLbl, tBg)
        setrow(dash, 15, "VETOES",   vetoTxt, vetoTxt=="none"?cMute:cWarn, tLbl, tBg)
        setrow(dash, 16, "SIZE",     str.tostring(lots)+" units ("+str.tostring(riskPct,"0.0")+"%)", tVal, tLbl, tBg)
        setrow(dash, 17, "ENTRY",    inTrade?str.tostring(entryPx,"#.##"):"-", tVal, tLbl, tBg)
        setrow(dash, 18, "STOP",     inTrade?str.tostring(stopPx,"#.##"):"-", cBear, tLbl, tBg)
        setrow(dash, 19, "T1 / T2",  inTrade?str.tostring(t1,"#.##")+" / "+str.tostring(t2,"#.##"):"-", cBull, tLbl, tBg)
        setrow(dash, 20, "OPT",      useOpt?optTxt:"off", useOpt?cInfo:cMute, tLbl, tBg)
        setrow(dash, 21, "------",   "------", cMute, tLbl, tBg)
        setrow(dash, 22, "HEALTH",   "vol"+chk(volLive)+" ltf"+chk(ltfOk)+" cyc"+chk(not na(domCycle)), tVal, tLbl, tBg)
        setrow(dash, 23, "FEEDS",    "spot"+chk(spotLive)+" vix"+chk(vixLive)+" oi"+chk(oiLive)+" xa"+chk(xaLive), tVal, tLbl, tBg)
        setrow(dash, 24, "STRETCH",  stretchTxt, stretchCol, tLbl, tBg)

// =============================================================================
// IDENTITY — script name + symbol + timeframe always visible on the chart
// =============================================================================
var table idTbl = table.new(position.bottom_center, 1, 1, force_overlay=true)
if showId and barstate.islast
    idTxt = "Adaptive MACD ARC   ·   " + syminfo.ticker + "   ·   " + timeframe.period
    table.cell(idTbl, 0, 0, idTxt, text_color=color.new(#8a929e, 20), text_size=size.small, text_halign=text.align_center, bgcolor=color.new(color.gray, 100))
````
