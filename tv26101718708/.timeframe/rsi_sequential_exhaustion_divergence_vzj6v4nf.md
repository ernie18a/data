# RSI Sequential Exhaustion & Divergence

- url: https://www.tradingview.com/script/VZJ6v4NF-RSI-Sequential-Exhaustion-Divergence/
- type: indicator
- pine_id: PUB;05f2e85597ab4b5692f59a33607a1ace
- version: 3.0

## Description

**RSI Sequential Exhaustion & Divergence — Multi-Factor Oscillator**

**What it is**

A single RSI-based reversal oscillator for spotting momentum exhaustion, then filtering and grading those signals so only the better-supported ones stand out. It is one integrated tool, not a pile of separate indicators sharing a pane.

**What it plots**

- The RSI line with a glow/gradient style coloured by momentum side, plus overbought/oversold/midline levels and an optional zone fill.
- Sequential Exhaustion signal arrows (▲/▼) at qualifying turns.
- Regular and hidden price–RSI divergence as lines and small labels, de-cluttered so the pane stays readable.
- A compact 5-row dashboard: Signal (direction · conviction % · age), RSI state, Confluence score, Context (trend/range + volatility state), and a Data-health read.
- An optional calibration panel and a set of hidden data-window outputs (EXP_*) for chaining into other scripts.

**Why these components are combined (and how they work together)**

Each part is here to fix a specific weakness of the part before it, so the result is one filtered, graded signal:

1. A bare RSI overbought/oversold reading whipsaws, and naive divergence over-fires. So the script uses two *structured* exhaustion cues instead: **Sequential Exhaustion** (the RSI makes three consecutive deeper pushes into an extreme zone and the fourth bar turns back out — a defined trigger, not just "RSI is low"), and a **divergence engine** that adds an independent reversal cue and is de-cluttered with a cooldown plus a minimum-gap filter.
2. Both cues are counter-trend by nature, and counter-trend entries fail in two situations: strong directional trends, and volatility cascades. To handle the first, an **HTF trend-bias filter** and an **ADX regime filter** suppress signals when a higher timeframe or strong ADX says the trend is intact. To handle the second, a **volatility-cluster filter** (a self-exciting intensity built from returns) proportionally raises the bar for new signals exactly when clustering makes mean-reversion most dangerous — and because it is price-only, it also works on volume-less symbols.
3. To tell which surviving signals are worth more, a **Confluence grade (0–5)** fuses five reasonably-independent reads of the same bar (HTF bias, ranging regime, a recent divergence, volume, and the RSI momentum turn). **Multi-timeframe agreement (3×/5×/15×)** is deliberately kept *separate* and applied as a conviction *multiplier* rather than blended into the score, because it is the one genuinely independent check — full agreement boosts conviction, contradiction damps it.
4. To stay honest about whether any of this is working on your symbol, a **calibration tracker** logs every signal and, after a fixed horizon, records whether price actually followed through (a move of at least X·ATR in the signal's direction), reporting a measured *past* hit-rate by grade tier with a Wilson 95% confidence interval. A **data-integrity read** (bar range, HTF-feed freshness, volume reliability) surfaces an OK / DEGRADED / CRITICAL status so the tool never silently scores on bad data.

**What is original here**

The individual techniques — RSI, divergence, ADX, ATR, volume reads, self-exciting intensity, Wilson intervals — are publicly documented. The original work is the integration: a structured RSI-exhaustion trigger gated by a proportional volatility-cluster filter, graded by a confluence score that is scaled by independent higher-timeframe agreement, and continuously audited by a built-in self-calibration tracker that reports honest past follow-through by tier. Components were chosen so each covers a distinct weakness; redundant filters were left out to keep one clear signal.

**How to use**

1. Add it to a chart. Defaults suit intraday index/futures; direction works on any symbol, while the volume confluence factor needs real traded volume.
2. Take signals in the direction the context filters allow. Prefer a higher conviction % and stronger higher-timeframe agreement; treat low-grade cues as noise (raise "Min confluence to allow signal" to suppress them).
3. Respect the volatility-cluster warning — it marks regimes where mean-reversion is most likely to fail.
4. Use the optional calibration panel as a sanity check on the tool's own past signals, never as a forward prediction.
5. Spot vs futures: a cash/spot index has no real volume. "Volume Mode" auto-detects this, and you can borrow a traded-volume series from a related futures contract; the "Data" row shows the active mode.

**Notes**

All signals and divergence confirm on closed pivots and do not repaint. Divergence labels appear "Pivot Right" bars after the turn, which is inherent to honest pivot detection.

**Disclaimer**

For education and information only. This is not financial, investment, or trading advice and guarantees no outcome. Signals describe current and past conditions; they do not predict the future. The calibration figures describe past behaviour only — they are not a backtest or a probability of future results. Volume-based readings depend on the data feed and are unreliable on instruments without real volume. Trading carries substantial risk of loss; you are solely responsible for your own decisions and risk management. Consider consulting a licensed professional.

## Source Code

````pine
//@version=6
// ═════════════════════════════════════════════════════════════════════════════
//  RSI Sequential Exhaustion & Divergence  —  Multi-Factor Oscillator
// ─────────────────────────────────────────────────────────────────────────────
//  WHAT IT DOES
//  A single RSI-based reversal oscillator. It looks for two independent signs of
//  momentum exhaustion, then filters and grades them so only the better-supported
//  ones are emphasised:
//    • Sequential Exhaustion — the RSI makes three consecutive deeper pushes into
//      an extreme zone and the fourth bar turns back out of it (a structured
//      exhaustion trigger, not just "RSI is low").
//    • Divergence — pivot-based regular and hidden divergence between price and
//      the RSI, de-cluttered with a cooldown and a minimum-gap filter.
//
//  WHY THESE PIECES ARE COMBINED (how the parts work together)
//  Each component exists to fix a specific weakness of the one before it, so the
//  output is one filtered, graded signal rather than several indicators stacked
//  on a chart:
//    1. Bare RSI overbought/oversold whipsaws, and naive divergence over-fires.
//       The Sequential Exhaustion pattern turns the RSI's extreme behaviour into
//       a defined trigger; the divergence engine adds a second, independent
//       reversal cue and is de-cluttered so it stays readable.
//    2. Both cues are counter-trend (mean-reversion) and fail in two situations:
//       strong directional trends, and volatility cascades. So:
//         – HTF trend bias + ADX regime filter suppress counter-trend entries
//           when a higher timeframe / strong ADX says the trend is intact.
//         – A volatility-cluster filter (self-exciting intensity on returns)
//           proportionally raises the bar for new signals exactly when clustering
//           makes mean-reversion most dangerous. Price-only, so it also works on
//           volume-less symbols.
//    3. Knowing which surviving signals are worth more:
//         – A 0–5 Confluence grade fuses five reasonably-orthogonal reads of the
//           same bar (HTF bias, ranging regime, a recent divergence, volume, RSI
//           momentum turn).
//         – Multi-timeframe agreement (3×/5×/15×) is kept SEPARATE and folded in
//           as a conviction multiplier — it is the one genuinely independent
//           check, so it scales conviction rather than being blended as another
//           correlated input.
//    4. Honesty about whether any of this is working on your symbol:
//         – A built-in Calibration tracker logs every signal and, after a fixed
//           horizon, records whether price actually followed through (≥X·ATR in
//           the signal's direction), reporting a measured PAST hit-rate by grade
//           tier with a 95% confidence interval (score method).
//         – A data-integrity read (bar range / HTF-feed freshness / volume
//           reliability) surfaces an OK·DEGRADED·CRITICAL status so the tool never
//           silently scores on bad data.
//
//  WHAT IS ORIGINAL
//  The individual techniques (RSI, divergence, ADX, ATR, volume-versus-average
//  comparison, self-exciting volatility intensity, binomial-proportion confidence
//  intervals) are publicly documented. The integration is the original part: a
//  structured RSI-exhaustion trigger gated by a proportional volatility-cluster
//  filter, graded by a confluence score that is scaled by independent
//  higher-timeframe agreement, and continuously audited by a self-calibration
//  tracker that reports honest past follow-through by tier. Redundant filters were
//  deliberately left out to keep one clear signal.
//
//  HOW TO USE
//    1. Add to a chart. The "Source (raw data)" input in the Data & Source group
//       lets you pick the price series the whole tool is built from, so it adapts
//       to any asset or market (stocks, futures, forex, crypto, indices). Defaults
//       suit intraday index/futures; direction works on any symbol — the volume
//       factor needs real traded volume.
//    2. Trade in the direction the context filters allow; prefer signals with a
//       higher conviction % and higher-timeframe agreement; treat low-grade cues
//       as noise (raise "Min confluence to allow signal" to suppress them).
//    3. Respect the volatility-cluster warning — it marks regimes where mean-
//       reversion is most likely to fail.
//    4. Use the Calibration panel as a sanity check on the tool's own past
//       signals, never as a forward prediction.
//    5. SPOT vs FUTURES: a cash/spot index has no real volume. Volume Mode auto-
//       detects this; you can also borrow a traded-volume series from a related
//       futures contract. The dashboard "Data" row shows the active mode.
//
//  All signals/divergence confirm on closed pivots (non-repainting). Divergence
//  labels print "Pivot Right" bars after the turn — inherent to honest pivots.
//
//  DISCLAIMER
//  For education and information only. This is not financial, investment or
//  trading advice and guarantees no outcome. Signals describe current and past
//  conditions; they do not predict the future. The Calibration figures are
//  descriptive of past behaviour only and are not a backtest or a probability of
//  future results. Volume-based readings depend on the data feed and are
//  unreliable on instruments without real volume. Trading carries substantial
//  risk of loss. You are solely responsible for your own decisions and risk
//  management; consider consulting a licensed professional.
// ═════════════════════════════════════════════════════════════════════════════
indicator("RSI Sequential Exhaustion & Divergence", "RSI SeqEx",
     overlay          = false,
     max_lines_count  = 100,
     max_labels_count = 200)

// ─────────────────────────────── Inputs ─────────────────────────────────────
// Raw data source: the single price series every calculation is built from.
// Change it to adapt the tool to any asset or market.
gDATA = "Data & Source"
rsiSource = input.source(close, "Source (raw data)", group = gDATA,
     tooltip = "The price series the entire tool is built from. Change it to adapt the indicator to any asset or market — e.g. close, hl2, hlc3, ohlc4, or the output of another indicator. Works on stocks, futures, forex, crypto and indices. Price-structure pivots (used by the divergence engine) always use the chart's real highs/lows. The volume confluence factor additionally needs real traded volume; see Volume Mode for volume-less symbols.")

gRSI = "RSI"
rsiLength = input.int(8,      "RSI Length",       minval = 1,               group = gRSI)
osLevel   = input.float(20.0, "Oversold Level",   minval = 0, maxval = 100, group = gRSI)
obLevel   = input.float(80.0, "Overbought Level", minval = 0, maxval = 100, group = gRSI)

gSIG = "Sequential Exhaustion Signals"
showSignals = input.bool(true, "Show Sequential Exhaustion Signals", group = gSIG,
     tooltip = "Fires when the RSI makes three consecutive deeper moves into an extreme zone and the fourth bar confirms a turn back out of it.")

gDIV = "Divergence"
useDiv      = input.bool(true,  "Detect Divergence",       group = gDIV)
showReg     = input.bool(true,  "Regular", inline = "dv",  group = gDIV)
showHid     = input.bool(false, "Hidden",  inline = "dv",  group = gDIV)
pivL        = input.int(6,  "Pivot Left",  minval = 1,     group = gDIV)
pivR        = input.int(6,  "Pivot Right", minval = 1,     group = gDIV)
minPiv      = input.int(5,  "Min Bars Between Pivots", minval = 1, group = gDIV)
maxPiv      = input.int(60, "Max Bars Between Pivots", minval = 5, group = gDIV)
minRsiGap   = input.float(2.0, "Min RSI Gap for Divergence", minval = 0, step = 0.5, group = gDIV,
     tooltip = "Ignores trivial divergences: the RSI pivot must differ from the prior pivot by at least this many points. Raise it to thin out signals.")
divCooldown = input.int(10, "Label Cooldown (bars)", minval = 0, group = gDIV,
     tooltip = "Minimum bars between same-direction divergence labels. The biggest declutter lever — raise it if the pane is still busy.")

gHTF = "Higher-Timeframe Trend Bias"
useHtf    = input.bool(false, "Filter Signals by HTF Trend", group = gHTF)
htfTf     = input.timeframe("240", "HTF Timeframe",          group = gHTF)
htfEmaLen = input.int(50, "HTF EMA Length", minval = 1,      group = gHTF)

gREG = "Trend-Strength Regime Filter"
useRegime    = input.bool(false, "Suppress Signals in Strong Trends", group = gREG)
adxLength    = input.int(14, "ADX Length",    minval = 1, group = gREG)
adxSmoothing = input.int(14, "ADX Smoothing", minval = 1, group = gREG)
adxThreshold = input.float(25.0, "ADX Trend Threshold", minval = 0, group = gREG)
shadeRange   = input.bool(true, "Shade Ranging Background", group = gREG)

gSES = "Intraday Session Warmup"
useSessionSkip  = input.bool(false, "Skip First N Bars of Session", group = gSES,
     tooltip = "Overnight gaps inflate the first few bars. On intraday charts this skips signals at the open. Ignored on daily+.")
sessionSkipBars = input.int(3, "Bars to Skip", minval = 0, maxval = 20, group = gSES)

// Volume mode + borrow-volume ─────────────────────────────────────────────────
gVMODE = "Volume Mode"
assetMode = input.string("Auto-detect", "Volume on this symbol",
     options = ["Auto-detect", "Real volume", "No volume (price-based)"], group = gVMODE,
     tooltip = "The volume confluence factor uses traded volume. Some symbols (cash/spot indices) publish no real volume. On Auto-detect the indicator senses this and treats the volume factor as inactive so nothing breaks. Force a mode only if Auto gets it wrong.")
volSym = input.symbol("", "Borrow volume from another symbol", group = gVMODE,
     tooltip = "Leave blank to use the chart symbol. To get real volume on a symbol that has none, enter a related instrument that does (for example: chart a spot index, borrow volume from its index-futures contract). Price and the oscillator stay on your chart symbol; only the volume series is borrowed.")

// Volatility-Cluster filter ───────────────────────────────────────────────────
gVOL = "Volatility-Cluster Filter"
useVolFilter = input.bool(false, "Raise signal bar during vol clusters", group = gVOL,
     tooltip = "Self-exciting volatility detector. When recent large moves cluster, mean-reversion entries get run over — so this proportionally raises the confluence required for a new signal. Price-only; works on volume-less symbols.")
vcShockSig = input.float(2.0, "Shock threshold (× σ of returns)", minval = 1.0, maxval = 4.0, step = 0.1, group = gVOL)
vcAlpha    = input.float(0.5, "Excitation (α)", minval = 0.1, maxval = 0.9, step = 0.05, group = gVOL,
     tooltip = "How much each shock raises intensity.")
vcBeta     = input.float(0.2, "Decay (β)", minval = 0.05, maxval = 0.5, step = 0.05, group = gVOL,
     tooltip = "How fast intensity fades each bar. Smaller = longer memory.")
vcWarnMult = input.float(3.0, "Warning threshold (× baseline)", minval = 1.5, maxval = 5.0, step = 0.1, group = gVOL)
vcMaxLift  = input.float(2.0, "Max confluence-bar lift", minval = 0.0, maxval = 4.0, step = 0.5, group = gVOL,
     tooltip = "At peak clustering, this many extra confluence points are required. 0 = badge only, no suppression.")
vcLiftSpan = input.float(2.0, "Lift-scaling span (× baseline)", minval = 0.5, maxval = 5.0, step = 0.5, group = gVOL)
showVolShade   = input.bool(true, "Shade background during vol warning", group = gVOL)

// Confluence grade ────────────────────────────────────────────────────────────
gCONF = "Confluence Grade"
confDivBars   = input.int(15, "Recent-divergence window (bars)", minval = 1, group = gCONF,
     tooltip = "A same-direction divergence within this many bars counts as one confluence point.")
minConfluence = input.int(0, "Min confluence to allow signal (0 = off)", minval = 0, maxval = 5, group = gCONF,
     tooltip = "Signals firing below this 0–5 score are suppressed. 0 keeps all signals (prior behaviour). The vol-cluster filter adds to this requirement dynamically.")

// Multi-timeframe confirmation ────────────────────────────────────────────────
gMTF = "Multi-Timeframe Confirmation"
useMtf      = input.bool(false, "Fold 3×/5×/15× agreement into conviction", group = gMTF,
     tooltip = "An INDEPENDENT trend read on 3×, 5× and 15× the chart timeframe. Kept separate from the confluence score and applied as a conviction multiplier: full agreement boosts, contradiction damps. Optionally also gates the signal.")
mtfEmaLen   = input.int(50, "HTF trend EMA length", minval = 1, group = gMTF)
mtfBonus    = input.float(0.10, "Conviction bonus when all 3 agree", minval = 0.0, maxval = 0.3, step = 0.05, group = gMTF)
mtfMinAgree = input.int(0, "Min HTF agreement to allow signal (0 = off)", minval = 0, maxval = 3, group = gMTF,
     tooltip = "Require at least this many of the three higher timeframes to agree with the signal direction. 0 = no gate (multiplier still affects displayed conviction).")

// Calibration tracker ─────────────────────────────────────────────────────────
gCAL = "Calibration Tracker (past-only · descriptive)"
calEnable  = input.bool(true, "Log & evaluate signals (background)", group = gCAL,
     tooltip = "Logs each signal at firing and scores it after the horizon. Lightweight — leave on even if the panel is hidden; it populates the EXP_* hit-rate exports.")
calShowPanel = input.bool(false, "Show calibration panel on chart", group = gCAL,
     tooltip = "Off by default. Reports measured past hit-rate by confluence tier with a 95% confidence interval (score method). NOT a backtest, NOT a forward prediction — a sanity check on the tool's own signals.")
calPanelPos = input.string("bottom_right", "Calibration panel position",
     options = ["top_left","top_right","bottom_left","bottom_right","middle_right"], group = gCAL)
calHorizon = input.int(10, "Evaluation horizon (bars)", minval = 3, maxval = 100, group = gCAL)
calMoveATR = input.float(0.5, "Min follow-through (× ATR) to count a hit", minval = 0.1, maxval = 3.0, step = 0.1, group = gCAL,
     tooltip = "Move required in the signal's direction within the horizon to count as 'respected'. For a long: price up ≥ this × ATR; for a short: price down.")
atrLen     = input.int(14, "ATR length (calibration + levels)", minval = 1, group = gCAL)

gVIS = "Visuals"
oscStyle  = input.string("Glow", "Oscillator Style", options = ["Glow", "Plain"], group = gVIS)
fillMid   = input.bool(true, "Fill RSI to Midline", group = gVIS)
showExtreme = input.bool(false, "Show 90/10 Extreme Lines", group = gVIS)
colBull   = input.color(#2ebd85, "Bull / Oversold color",   group = gVIS)
colBear   = input.color(#f6465d, "Bear / Overbought color", group = gVIS)

gDASH = "Dashboard & Alerts"
showDash = input.bool(true, "Show Dashboard", group = gDASH)
dashPos  = input.string("top_right", "Dashboard Position",
     options = ["top_left","top_right","bottom_left","bottom_right","middle_right"], group = gDASH)
showHealth = input.bool(true, "Show data-health row", group = gDASH)
dashTheme = input.string("Auto (match chart)", "Dashboard theme",
     options = ["Auto (match chart)", "Dark", "Light"], group = gDASH,
     tooltip = "Auto reads the chart background brightness and keeps both the dashboard and the calibration panel legible on any theme (light, dark or colored). Dark/Light force a palette regardless of the chart. Cells are fully opaque so the panels never wash out.")
useAlert = input.bool(false, "Fire dynamic alert() messages (webhooks)", group = gDASH)

// ─────────────────────────────── Helpers ────────────────────────────────────
f_pos(s) =>
    s == "top_left" ? position.top_left : s == "top_right" ? position.top_right : s == "bottom_left" ? position.bottom_left : s == "bottom_right" ? position.bottom_right : position.middle_right

f_clamp01(x) =>
    math.max(0.0, math.min(1.0, x))

// Score-based 95% confidence interval for a binomial proportion → [lo, hi] in
// [0,1]; [na,na] if N<5.
f_propCI(int hits, int total) =>
    float lo = na
    float hi = na
    if total >= 5
        float p   = hits / float(total)
        float z   = 1.96
        float den = 1.0 + z * z / total
        float cen = (p + z * z / (2.0 * total)) / den
        float halfw = z * math.sqrt(p * (1.0 - p) / total + z * z / (4.0 * total * total)) / den
        lo := math.max(0.0, cen - halfw)
        hi := math.min(1.0, cen + halfw)
    [lo, hi]

// Confluence score (0..5) → tier bin: 0 = Low (≤2), 1 = Mid (3), 2 = High (≥4)
f_calBin(int conf) =>
    conf >= 4 ? 2 : conf >= 3 ? 1 : 0

// HTF directional bias + a 50-bar change-count (feed-staleness probe), one call.
f_htf() =>
    b = close > ta.ema(close, htfEmaLen) ? 1 : -1
    int cnt = 0
    for i = 1 to 50
        if not na(close[i]) and not na(close[i - 1]) and close[i] != close[i - 1]
            cnt := cnt + 1
    [b, cnt]

// Nearest standard timeframe for a minute-count (MTF multiples).
f_tf(mins) =>
    mins <= 1.5 ? "1" : mins <= 2.5 ? "2" : mins <= 4 ? "3" : mins <= 7.5 ? "5" : mins <= 12.5 ? "10" : mins <= 22.5 ? "15" : mins <= 37.5 ? "30" : mins <= 52.5 ? "45" : mins <= 90 ? "60" : mins <= 150 ? "120" : mins <= 210 ? "180" : mins <= 300 ? "240" : mins <= 540 ? "360" : mins <= 1080 ? "720" : "D"

// Independent higher-TF trend read used by the MTF confirmation.
f_mbias() =>
    close > ta.ema(close, mtfEmaLen) ? 1 : -1

// Agreement (0..3) → conviction multiplier.
f_mtfMult(int agree) =>
    agree == 3 ? 1.0 + mtfBonus : agree == 2 ? 1.0 : agree == 1 ? 0.8 : 0.6

// ─────────────────────────────── Core ───────────────────────────────────────
rsi    = ta.rsi(rsiSource, rsiLength)
atrVal = ta.atr(atrLen)

[htfBias, htfChg] = request.security(syminfo.tickerid, htfTf, f_htf(), lookahead = barmerge.lookahead_off)

[diPlus, diMinus, adxValue] = ta.dmi(adxLength, adxSmoothing)
trending = adxValue >= adxThreshold
ranging  = not trending

// Intraday session warmup
isIntraday   = timeframe.in_seconds() < 86400
dailyChange  = ta.change(time("D"))
newSession   = useSessionSkip and isIntraday and dailyChange != 0
var int barsIntoSession = 9999
barsIntoSession := newSession ? 1 : barsIntoSession + 1
sessionOK = not useSessionSkip or not isIntraday or barsIntoSession > sessionSkipBars

// ───────────────────── Volume mode + borrow-volume ─────────────────────────
// Resolve the effective traded-volume series. It may be borrowed from a related
// symbol (request.security runs unconditionally for series consistency). Then
// decide whether volume is usable at all, from an explicit mode or auto-detect.
symType   = syminfo.type
isIdx     = symType == "index" or symType == "economic"
useAltSym = volSym != "" and volSym != syminfo.tickerid
volId     = useAltSym ? volSym : syminfo.tickerid
vEff      = useAltSym ? request.security(volId, timeframe.period, volume, lookahead = barmerge.lookahead_off) : volume

volExists = not na(vEff) and vEff > 0
var int volSeen = 0
var int volTot  = 0
if barstate.isconfirmed
    volTot  := volTot + 1
    volSeen := volSeen + (volExists ? 1 : 0)
volRatio = volTot > 0 ? volSeen / float(volTot) : 1.0
autoVol  = volRatio >= 0.80 and (not isIdx or useAltSym)
useVol   = assetMode == "Auto-detect" ? autoVol : assetMode == "Real volume" ? true : false

// ───────────────────── Data-integrity layer ────────────────────────────
// What this tool actually depends on: usable price (critical), warmup, an HTF
// feed when the HTF filter is on, and volume ONLY when a confluence gate that
// consumes the volume factor is active. We refuse to overstate criticality.
barRangeValid = high > low and not na(high) and not na(low)

warmReq  = math.max(rsiLength + 5, pivL + pivR + 1)
warmedUp = bar_index >= warmReq

htfStale   = useHtf and bar_index >= 50 and htfChg == 0
volMatters = minConfluence > 0 or useVolFilter
volHealthBad = volMatters and useVol and volRatio < 0.80   // expected volume, but feed thin

int healthCode = 0
if not barRangeValid
    healthCode := 2
else if htfStale or not warmedUp or volHealthBad
    healthCode := 1

healthTxt = healthCode == 0 ? "OK" : healthCode == 1 ? "DEGRADED" : "CRITICAL"
healthDetail = (barRangeValid ? "Price ✓ " : "Price ✗ ") + (warmedUp ? "Warm ✓ " : "Warm ✗ ") + (not useHtf ? "HTF off " : htfStale ? "HTF ✗ " : "HTF ✓ ") + (not volMatters ? "Vol n/a " : useVol ? (volRatio < 0.80 ? "Vol ✗ " : "Vol ✓") : "Vol off")

// ───────────────── Volatility-cluster filter (self-exciting intensity) ─────────────────
vcRet   = math.log(close / math.max(nz(close[1], close), 0.0001))
vcRv    = ta.stdev(vcRet, 20)
vcShock = not na(vcRv) and vcRv > 0 and math.abs(vcRet) > vcShockSig * vcRv
vcBase  = ta.sma(vcShock ? 1.0 : 0.0, 100)
var float vcIntensity = 0.0
if barstate.isconfirmed
    vcIntensity := vcIntensity * math.exp(-vcBeta) + (vcShock ? vcAlpha : 0.0)
vcRatio   = vcBase > 0 ? vcIntensity / vcBase : 0.0
vcWarning = useVolFilter and vcRatio > vcWarnMult

float vcLift = 0.0
if vcWarning and vcLiftSpan > 0
    vcLift := vcMaxLift * math.min(1.0, (vcRatio - vcWarnMult) / vcLiftSpan)
vcLiftFrac = vcMaxLift > 0 ? vcLift / vcMaxLift : math.min(1.0, (vcRatio - vcWarnMult) / math.max(vcLiftSpan, 0.5))
int vcSeverity = 0
if vcWarning
    vcSeverity := vcLiftFrac >= 0.66 ? 3 : vcLiftFrac >= 0.33 ? 2 : 1
vcBadge = vcSeverity == 0 ? "calm" : vcSeverity == 1 ? "vol+" : vcSeverity == 2 ? "vol++" : "vol+++"

// ──────────────── Multi-timeframe confirmation (multiplier) ─────────────
// Three trend reads on 3×/5×/15× the chart TF. Independent of the confluence
// score; folded in as a conviction multiplier (and an optional gate).
tfSec = timeframe.in_seconds()
tf3x  = f_tf(tfSec * 3  / 60)
tf5x  = f_tf(tfSec * 5  / 60)
tf15x = f_tf(tfSec * 15 / 60)
m3  = request.security(syminfo.tickerid, tf3x,  f_mbias(), lookahead = barmerge.lookahead_off)
m5  = request.security(syminfo.tickerid, tf5x,  f_mbias(), lookahead = barmerge.lookahead_off)
m15 = request.security(syminfo.tickerid, tf15x, f_mbias(), lookahead = barmerge.lookahead_off)
mtfBullN      = (m3 > 0 ? 1 : 0) + (m5 > 0 ? 1 : 0) + (m15 > 0 ? 1 : 0)
mtfAgreeLong  = mtfBullN
mtfAgreeShort = 3 - mtfBullN
mtfMultLong   = useMtf ? f_mtfMult(mtfAgreeLong)  : 1.0
mtfMultShort  = useMtf ? f_mtfMult(mtfAgreeShort) : 1.0

// ───────────── Context gating + Sequential Exhaustion raw pattern ────────────
longContextOK  = (not useHtf or htfBias > 0) and (not useRegime or ranging) and sessionOK
shortContextOK = (not useHtf or htfBias < 0) and (not useRegime or ranging) and sessionOK

descending = rsi < rsi[1] and rsi[1] < rsi[2] and rsi[2] < rsi[3]
ascending  = rsi > rsi[1] and rsi[1] > rsi[2] and rsi[2] > rsi[3]
longRaw  = descending and rsi[3] < osLevel and rsi[4] > osLevel
shortRaw = ascending  and rsi[3] > obLevel and rsi[4] < obLevel

// ─────────────── Divergence (de-cluttered: var pivots + cooldown) ────────────
ph = ta.pivothigh(rsi, pivL, pivR)
pl = ta.pivotlow(rsi, pivL, pivR)
phFound = not na(ph)
plFound = not na(pl)

var float pLosc = na
var float pLprice = na
var int   pLbar = na
var float pHosc = na
var float pHprice = na
var int   pHbar = na
var int   lastBullBar = -100000
var int   lastBearBar = -100000

bullReg = false
bullHid = false
bearReg = false
bearHid = false

if plFound
    oVal = rsi[pivR]
    pVal = low[pivR]
    bIdx = bar_index - pivR
    gap  = bIdx - nz(pLbar, bIdx)
    if useDiv and not na(pLosc) and gap >= minPiv and gap <= maxPiv
        bullReg := showReg and (oVal > pLosc + minRsiGap) and pVal < pLprice  // price LL, RSI HL
        bullHid := showHid and (oVal < pLosc - minRsiGap) and pVal > pLprice  // price HL, RSI LL
        if (bullReg or bullHid) and (bIdx - lastBullBar) >= divCooldown
            c = bullReg ? colBull : color.new(colBull, 45)
            line.new(pLbar, pLosc, bIdx, oVal, color = c, width = 2)
            label.new(bIdx, oVal, bullReg ? "Bull" : "H-Bull", yloc = yloc.price,
                 style = label.style_label_up, color = color.new(c, 78), textcolor = c, size = size.tiny)
            lastBullBar := bIdx
    pLosc := oVal
    pLprice := pVal
    pLbar := bIdx

if phFound
    oVal = rsi[pivR]
    pVal = high[pivR]
    bIdx = bar_index - pivR
    gap  = bIdx - nz(pHbar, bIdx)
    if useDiv and not na(pHosc) and gap >= minPiv and gap <= maxPiv
        bearReg := showReg and (oVal < pHosc - minRsiGap) and pVal > pHprice  // price HH, RSI LH
        bearHid := showHid and (oVal > pHosc + minRsiGap) and pVal < pHprice  // price LH, RSI HH
        if (bearReg or bearHid) and (bIdx - lastBearBar) >= divCooldown
            c = bearReg ? colBear : color.new(colBear, 45)
            line.new(pHbar, pHosc, bIdx, oVal, color = c, width = 2)
            label.new(bIdx, oVal, bearReg ? "Bear" : "H-Bear", yloc = yloc.price,
                 style = label.style_label_down, color = color.new(c, 78), textcolor = c, size = size.tiny)
            lastBearBar := bIdx
    pHosc := oVal
    pHprice := pVal
    pHbar := bIdx

// ───────────────────── Confluence grade (0..5) ─────────────────────────
// Five reasonably-orthogonal reads of the SAME bar. Not fully independent (HTF
// bias and regime can co-move), so treat the score as a coarse grade. Volume
// factor is inert when volume is unusable (counts 0).
volSMA     = ta.sma(vEff, 20)
volConfirm = useVol and not na(volSMA) and vEff > volSMA

longConf  = (htfBias > 0 ? 1 : 0) + (ranging ? 1 : 0) + ((bar_index - lastBullBar) <= confDivBars ? 1 : 0) + (volConfirm ? 1 : 0) + (rsi > rsi[1] ? 1 : 0)
shortConf = (htfBias < 0 ? 1 : 0) + (ranging ? 1 : 0) + ((bar_index - lastBearBar) <= confDivBars ? 1 : 0) + (volConfirm ? 1 : 0) + (rsi < rsi[1] ? 1 : 0)

// Conviction % = chart-TF confluence scaled by independent MTF agreement
longConvPct  = f_clamp01(longConf  / 5.0 * mtfMultLong)  * 100.0
shortConvPct = f_clamp01(shortConf / 5.0 * mtfMultShort) * 100.0

// Effective bar = static min + (proportional vol-cluster lift, when filter on)
effMinConf = minConfluence + (useVolFilter ? int(math.round(vcLift)) : 0)
mtfOkLong  = not useMtf or mtfAgreeLong  >= mtfMinAgree
mtfOkShort = not useMtf or mtfAgreeShort >= mtfMinAgree

longValid  = longRaw  and longContextOK  and longConf  >= effMinConf and mtfOkLong
shortValid = shortRaw and shortContextOK and shortConf >= effMinConf and mtfOkShort

longSignal  = showSignals and longValid
shortSignal = showSignals and shortValid

// ─────────────────────────────── Visuals ────────────────────────────────────
// PLOT BUDGET: ceiling is 64 outputs. Visible plots ≈ 7; EXP_ block ≈ 10;
// signals & divergence are LABELS/LINES (zero plot-slot cost); hline() also
// costs nothing. Comfortable headroom remains.
momUp     = rsi >= 50
baseCol   = momUp ? colBull : colBear
intensity = math.min(math.abs(rsi - 50) / 50.0, 1.0)
isGlow    = oscStyle == "Glow"

// Background: ranging regime, and (priority) vol-cluster warning shade
volBg = useVolFilter and showVolShade and vcWarning ? color.new(colBear, 90 - vcSeverity * 6) : na
regBg = useRegime and shadeRange and ranging ? color.new(color.gray, 92) : na
bgcolor(not na(volBg) ? volBg : regBg, title = "Regime / vol-cluster shade")

// Fill RSI to the 50 midline
pRsiFill = plot(fillMid ? rsi : na, "RSI (fill ref)", color = na, display = display.none)
pMidFill = plot(fillMid ? 50  : na, "Mid (fill ref)", color = na, display = display.none)
fill(pRsiFill, pMidFill, color = fillMid ? color.new(baseCol, int(math.round(94 - intensity * 22))) : na, title = "Momentum fill")

// Glow: stacked translucent lines under a crisp line
plot(isGlow ? rsi : na, "Glow outer", color = color.new(baseCol, 86), linewidth = 8, display = display.pane)
plot(isGlow ? rsi : na, "Glow inner", color = color.new(baseCol, 66), linewidth = 4, display = display.pane)
plot(rsi, "RSI", color = color.new(baseCol, 0), linewidth = 2, display = display.pane)

// Levels (hlines — no plot-slot cost)
hOB  = hline(obLevel, "Overbought", color = color.new(colBear, 35), linestyle = hline.style_dashed)
hMid = hline(50,      "Midline",    color = color.new(color.gray, 55), linestyle = hline.style_dotted)
hOS  = hline(osLevel, "Oversold",   color = color.new(colBull, 35), linestyle = hline.style_dashed)
fill(hOB, hOS, color = color.new(color.gray, 95), title = "Zone fill")
hline(showExtreme ? 90 : na, "Extreme High", color = color.new(colBear, 60), linestyle = hline.style_dotted)
hline(showExtreme ? 10 : na, "Extreme Low",  color = color.new(colBull, 60), linestyle = hline.style_dotted)

// Signal shapes
plotshape(longSignal,  "Long Signal",  shape.triangleup,   location.bottom, color.new(colBull, 0), size = size.tiny)
plotshape(shortSignal, "Short Signal", shape.triangledown, location.top,    color.new(colBear, 0), size = size.tiny)

// ─────────────────── Last-signal / last-divergence tracking ─────────────────
var int lastSigDir = 0
var int lastSigBar = na
var int lastSigConf = 0
var float lastSigConv = 0.0
if longValid
    lastSigDir := 1
    lastSigBar := bar_index
    lastSigConf := longConf
    lastSigConv := longConvPct
if shortValid
    lastSigDir := -1
    lastSigBar := bar_index
    lastSigConf := shortConf
    lastSigConv := shortConvPct

var string lastDivTxt = "—"
var int    lastDivBar = na
if bullReg
    lastDivTxt := "Bull"
    lastDivBar := bar_index - pivR
else if bearReg
    lastDivTxt := "Bear"
    lastDivBar := bar_index - pivR
else if bullHid
    lastDivTxt := "H-Bull"
    lastDivBar := bar_index - pivR
else if bearHid
    lastDivTxt := "H-Bear"
    lastDivBar := bar_index - pivR

// ─────────────────── Calibration tracker (score-interval CI) ───────────────────
var int[]   calTotal   = array.new_int(3, 0)
var int[]   calHit     = array.new_int(3, 0)
var int[]   pendBar    = array.new_int(0)
var float[] pendPrice  = array.new_float(0)
var float[] pendAtr    = array.new_float(0)
var int[]   pendDir    = array.new_int(0)
var int[]   pendBin    = array.new_int(0)

if calEnable and barstate.isconfirmed
    if longValid or shortValid
        array.push(pendBar,   bar_index)
        array.push(pendPrice, close)
        array.push(pendAtr,   atrVal)
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
            array.remove(pendBar,   idx)
            array.remove(pendPrice, idx)
            array.remove(pendAtr,   idx)
            array.remove(pendDir,   idx)
            array.remove(pendBin,   idx)
        else
            idx := idx + 1
    while array.size(pendBar) > 200
        array.shift(pendBar)
        array.shift(pendPrice)
        array.shift(pendAtr)
        array.shift(pendDir)
        array.shift(pendBin)

calTotAll = array.get(calTotal, 0) + array.get(calTotal, 1) + array.get(calTotal, 2)
calHitAll = array.get(calHit, 0) + array.get(calHit, 1) + array.get(calHit, 2)
calRateAll = calTotAll > 0 ? calHitAll / float(calTotAll) : na

// ─────────────────────────────── Dashboard ──────────────────────────────────
// 5 key rows only: Signal, RSI, Confluence, Context (regime + vol), Data.
// Deeper diagnostics live in the optional Calibration panel and the EXP_* outputs.
var table dash = table.new(f_pos(dashPos), 2, 6, frame_width = 1, border_width = 1)

// ── Theme-adaptive palette (shared by both panels) ─────────────────────────
// "Auto" reads the chart background brightness (luma) and flips between a dark
// and a light scheme so text always has contrast. All cell colors are fully
// OPAQUE so the panels never wash out against light or colored backgrounds.
_uiBg    = chart.bg_color
_uiLuma  = na(_uiBg) ? 0.0 : color.r(_uiBg) * 0.299 + color.g(_uiBg) * 0.587 + color.b(_uiBg) * 0.114
uiDark   = dashTheme == "Dark" ? true : dashTheme == "Light" ? false : (na(_uiBg) or _uiLuma < 140)

cHdr    = uiDark ? color.rgb(13, 27, 42)   : color.rgb(222, 230, 241)   // header background
cSub    = uiDark ? color.rgb(22, 27, 34)   : color.rgb(233, 237, 242)   // row background
cTxt    = uiDark ? color.rgb(226, 232, 240): color.rgb(20, 26, 38)      // primary text
cDim    = uiDark ? color.rgb(139, 148, 158): color.rgb(92, 100, 112)    // dim / label text
uiFrame = uiDark ? color.rgb(42, 52, 88)   : color.rgb(196, 204, 212)   // frame
uiBord  = uiDark ? color.rgb(26, 34, 56)   : color.rgb(210, 216, 224)   // grid
uiPanel = uiDark ? color.rgb(10, 14, 26)   : color.rgb(244, 246, 248)   // table background
uiAcc   = uiDark ? color.rgb(179, 157, 219): color.rgb(94, 53, 177)     // calibration accent
// Signal colors deepened in light mode so they stay readable on pale cells.
uiBull  = uiDark ? colBull : color.rgb(22, 151, 106)
uiBear  = uiDark ? colBear : color.rgb(210, 45, 68)
uiWarn  = uiDark ? color.rgb(227, 179, 65) : color.rgb(176, 120, 0)

if showDash and barstate.islast
    table.set_bgcolor(dash, uiPanel)
    table.set_frame_color(dash, uiFrame)
    table.set_border_color(dash, uiBord)
    table.cell(dash, 0, 0, "◆ RSI Seq-Exh", text_color = cTxt, bgcolor = cHdr, text_size = size.small)
    table.merge_cells(dash, 0, 0, 1, 0)

    // 1 — Signal (direction · conviction % · bars since). Conviction already folds
    //     in the independent higher-timeframe agreement multiplier.
    sigTxt = lastSigDir == 0 ? "—" : (lastSigDir > 0 ? "▲ Long" : "▼ Short") + " " + str.tostring(lastSigConv, "0") + "% (" + str.tostring(bar_index - lastSigBar) + "b)"
    sigCol = lastSigDir > 0 ? uiBull : lastSigDir < 0 ? uiBear : cDim
    table.cell(dash, 0, 1, "Signal", text_color = cDim, text_size = size.tiny, bgcolor = cSub)
    table.cell(dash, 1, 1, sigTxt, text_color = sigCol, text_size = size.tiny, text_halign = text.align_right)

    // 2 — RSI value + state
    rsiState = rsi >= obLevel ? "Overbought" : rsi <= osLevel ? "Oversold" : "Neutral"
    rsiCol   = rsi >= obLevel ? uiBear : rsi <= osLevel ? uiBull : cDim
    table.cell(dash, 0, 2, "RSI", text_color = cDim, text_size = size.tiny, bgcolor = cSub)
    table.cell(dash, 1, 2, str.tostring(rsi, "0.0") + " · " + rsiState, text_color = rsiCol, text_size = size.tiny, text_halign = text.align_right)

    // 3 — Confluence (long / short, with the effective minimum if a gate is set)
    confTxt = "L " + str.tostring(longConf) + " / S " + str.tostring(shortConf) + (effMinConf > 0 ? "  (≥" + str.tostring(effMinConf) + ")" : "")
    table.cell(dash, 0, 3, "Confluence /5", text_color = cDim, text_size = size.tiny, bgcolor = cSub)
    table.cell(dash, 1, 3, confTxt, text_color = cTxt, text_size = size.tiny, text_halign = text.align_right)

    // 4 — Context: trend/range regime + volatility-cluster state (mean-reversion safety)
    ctxTxt = (trending ? "Trend " : "Range ") + str.tostring(adxValue, "0") + (useVolFilter ? " · " + vcBadge : "")
    ctxCol = (useVolFilter and vcSeverity >= 2) ? uiBear : trending ? uiBear : (useVolFilter and vcSeverity == 1) ? uiWarn : uiBull
    table.cell(dash, 0, 4, "Context", text_color = cDim, text_size = size.tiny, bgcolor = cSub)
    table.cell(dash, 1, 4, ctxTxt, text_color = ctxCol, text_size = size.tiny, text_halign = text.align_right)

    // 5 — Data health (hover for the per-source breakdown)
    dataVal = warmedUp ? (healthTxt + (useVol ? "" : " · price-only")) : "Warming " + str.tostring(bar_index) + "/" + str.tostring(warmReq)
    table.cell(dash, 0, 5, "Data", text_color = cDim, text_size = size.tiny, bgcolor = cSub, tooltip = healthDetail)
    table.cell(dash, 1, 5, dataVal, text_color = warmedUp ? (healthCode == 0 ? uiBull : healthCode == 1 ? uiWarn : uiBear) : uiWarn, text_size = size.tiny, text_halign = text.align_right, tooltip = healthDetail)


// ───────────────── Optional calibration panel (off by default) ──────────
if calEnable and calShowPanel and barstate.islast
    var table calT = table.new(f_pos(calPanelPos), 4, 6, frame_width = 1, border_width = 1)
    table.set_bgcolor(calT, uiPanel)
    table.set_frame_color(calT, uiAcc)
    table.set_border_color(calT, uiBord)
    cH = cHdr
    cR = cSub

    table.cell(calT, 0, 0, "Calibration (past)", text_color = uiAcc, bgcolor = cH, text_size = size.tiny, text_halign = text.align_left,
         tooltip = "Descriptive only. Logs each signal at firing; checks after " + str.tostring(calHorizon) + " bars whether price moved ≥ " + str.tostring(calMoveATR) + "×ATR in the signal direction. NOT a backtest or prediction.")
    table.cell(calT, 1, 0, "N",        text_color = uiAcc, bgcolor = cH, text_size = size.tiny, text_halign = text.align_center)
    table.cell(calT, 2, 0, "Hit",      text_color = uiAcc, bgcolor = cH, text_size = size.tiny, text_halign = text.align_center)
    table.cell(calT, 3, 0, "95% CI",   text_color = uiAcc, bgcolor = cH, text_size = size.tiny, text_halign = text.align_right)

    int t0 = array.get(calTotal, 0)
    int t1 = array.get(calTotal, 1)
    int t2 = array.get(calTotal, 2)
    int h0 = array.get(calHit, 0)
    int h1 = array.get(calHit, 1)
    int h2 = array.get(calHit, 2)

    string[] rowLab = array.from("Low (≤2)", "Mid (3)", "High (≥4)", "All")
    int[]    rowTot = array.from(t0, t1, t2, t0 + t1 + t2)
    int[]    rowHit = array.from(h0, h1, h2, h0 + h1 + h2)

    for r = 0 to 3
        int rt = array.get(rowTot, r)
        int rh = array.get(rowHit, r)
        float rate = rt > 0 ? rh * 100.0 / rt : na
        [lo, hi] = f_propCI(rh, rt)
        string rateTxt = rt == 0 ? "—" : rt < 5 ? "warming" : str.tostring(rate, "0") + "%"
        string ciTxt   = na(lo) ? "—" : str.tostring(math.round(lo * 100)) + "–" + str.tostring(math.round(hi * 100)) + "%"
        color  rateCol = rt < 5 ? cDim : rate >= 60 ? uiBull : rate >= 50 ? uiWarn : uiBear
        table.cell(calT, 0, r + 1, rowLab.get(r), text_color = cTxt, bgcolor = cR, text_size = size.tiny, text_halign = text.align_left)
        table.cell(calT, 1, r + 1, str.tostring(rt), text_color = cTxt, bgcolor = cR, text_size = size.tiny, text_halign = text.align_center)
        table.cell(calT, 2, r + 1, rateTxt, text_color = rateCol, bgcolor = cR, text_size = size.tiny, text_halign = text.align_center)
        table.cell(calT, 3, r + 1, ciTxt, text_color = cTxt, bgcolor = cR, text_size = size.tiny, text_halign = text.align_right)

    int pendN = array.size(pendBar)
    table.cell(calT, 0, 5, pendN > 0 ? str.tostring(pendN) + " pending · past data only" : "past data only — no forward guarantee",
         text_color = cDim, bgcolor = cH, text_size = size.tiny, text_halign = text.align_left)
    table.cell(calT, 1, 5, "", bgcolor = cH)
    table.cell(calT, 2, 5, "", bgcolor = cH)
    table.cell(calT, 3, 5, "", bgcolor = cH)
    table.merge_cells(calT, 0, 5, 3, 5)

// ─────────────────────────────── Alerts ─────────────────────────────────────
alertcondition(longSignal,  "Sequential Exhaustion - Long",  "RSI Sequential Exhaustion long signal")
alertcondition(shortSignal, "Sequential Exhaustion - Short", "RSI Sequential Exhaustion short signal")
alertcondition(bullReg,     "Regular Bullish Divergence",    "Regular bullish RSI divergence")
alertcondition(bearReg,     "Regular Bearish Divergence",    "Regular bearish RSI divergence")
alertcondition(bullHid,     "Hidden Bullish Divergence",     "Hidden bullish RSI divergence")
alertcondition(bearHid,     "Hidden Bearish Divergence",     "Hidden bearish RSI divergence")
alertcondition(vcWarning and not vcWarning[1], "Vol Cluster Warning", "Volatility clustering — mean-reversion risk elevated")

if useAlert and barstate.isconfirmed
    if longSignal
        alert("RSI SeqEx LONG | " + syminfo.ticker + " | " + timeframe.period + " | RSI=" + str.tostring(rsi, "0.0") + " | conf " + str.tostring(longConf) + "/5 | conv " + str.tostring(longConvPct, "0") + "%", alert.freq_once_per_bar_close)
    if shortSignal
        alert("RSI SeqEx SHORT | " + syminfo.ticker + " | " + timeframe.period + " | RSI=" + str.tostring(rsi, "0.0") + " | conf " + str.tostring(shortConf) + "/5 | conv " + str.tostring(shortConvPct, "0") + "%", alert.freq_once_per_bar_close)
    if bullReg or bearReg
        alert("RSI DIVERGENCE " + (bullReg ? "BULL" : "BEAR") + " | " + syminfo.ticker + " | " + timeframe.period, alert.freq_once_per_bar_close)

// ─────────────────── EXP_* exports (data-window only) ───────────────────
// Stable names for downstream chaining via input.source().
plot(rsi,                                   "EXP_RSI",        color = color.new(color.gray, 100), display = display.data_window)
plot(longValid ? 1 : shortValid ? -1 : 0,  "EXP_SIGNAL_DIR", color = color.new(color.gray, 100), display = display.data_window)
plot(longValid ? longConf : shortValid ? shortConf : math.max(longConf, shortConf), "EXP_CONFLUENCE", color = color.new(color.gray, 100), display = display.data_window)
plot(longValid ? longConvPct : shortValid ? shortConvPct : math.max(longConvPct, shortConvPct), "EXP_CONVICTION", color = color.new(color.gray, 100), display = display.data_window)
plot(bullReg or bullHid ? 1 : bearReg or bearHid ? -1 : 0, "EXP_DIVERGENCE", color = color.new(color.gray, 100), display = display.data_window)
plot(mtfBullN,                              "EXP_MTF_BULLS",  color = color.new(color.gray, 100), display = display.data_window)
plot(healthCode,                            "EXP_HEALTH",     color = color.new(color.gray, 100), display = display.data_window)
plot(vcRatio,                               "EXP_VOL_RATIO",  color = color.new(color.gray, 100), display = display.data_window)
plot(htfBias,                               "EXP_HTF_BIAS",   color = color.new(color.gray, 100), display = display.data_window)
plot(nz(calRateAll, -1),                    "EXP_HIT_RATE",   color = color.new(color.gray, 100), display = display.data_window)
````
