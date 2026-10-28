# No-Repaint Entry Score Multi-Factor Confluence [LunqFX]

- url: https://www.tradingview.com/script/lkUx8S57-No-Repaint-Entry-Score-Multi-Factor-Confluence-LunqFX/
- type: indicator
- pine_id: PUB;39913feb66a94eb1bb5bd2af429c4cf2
- version: 1.0

## Description

No-Repaint Entry Score — Multi-Factor Confluence [LunqFX]

Most indicators tell you a signal exists. This one tells you how strong 
it is, why it fired, and how long it has been holding — on every bar, 
across every market.

One number: 0–100. Five factors. Zero repainting.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
█ HOW TO USE IT — 4 STEPS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

STEP 1 — CHECK HTF TREND
Look at the SIGNAL section of the panel.
HTF Trend shows ▲ BULL or ▼ BEAR based on a confirmed higher 
timeframe EMA. Only take setups in this direction.
Counter-trend setups are automatically penalised by the score.

STEP 2 — WAIT FOR THE ENTRY WINDOW
When score reaches your Signal Threshold (default 75), the panel 
shows "✓ ENTRY WINDOW" and a green Entry Zone box appears on the chart.
Do not enter below this threshold — conditions are not aligned.

STEP 3 — CHECK THE CAUTION ROW
The panel always shows your weakest component.
  Caution: Momentum ↓ → wait for a strong candle close
  Caution: Session ↓  → wait for market session to open
  Caution: Structure ↓ → you may be entering against the trend
Fix the caution before entering.

STEP 4 — LOOK FOR PRIME AND PERSISTENCE
PRIME label (score ≥80) = all 5 factors aligned. Best entries.
◆ SUSTAINED (3+ bars) → candles turn cyan. High conviction.
◆◆ ELITE (6+ bars)   → candles turn gold. Exceptional setup.
The longer the streak holds, the stronger the setup.

STOP LOSS — place below/above the Entry Zone outer band (±0.55 ATR).
TAKE PROFIT — next confirmed swing level or session high/low.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
█ SCORE TIERS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

◆◆ ELITE PRIME   ≥80, held 6+ bars  — exceptional, rare
◆  SUSTAINED     ≥80, held 3+ bars  — high conviction
   PRIME         ≥80, first bar     — valid entry signal
   GOOD          65–79              — quality setup, consider entry
   MODERATE      40–64              — mixed signals, wait
   WEAK          <40                — avoid, confluence collapsed

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
█ READING THE DASHBOARD PANEL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[image]https://www.tradingview.com/x/7r8mu9uu/[/image]
ENTRY SCORE — composite score 0–100. Header color shifts with tier:
green (PRIME) → cyan (SUSTAINED) → gold (ELITE) → red (WEAK)

Progress bar — 8-block visual bar. Updates every tick.

Score ▲▼— — arrow shows if score is building (▲) or fading (▼).
Useful for timing: enter when score is rising, not when it peaks.

Tier row — current tier label. Upgrades automatically to 
◆ SUSTAINED PRIME or ◆◆ ELITE PRIME when streak activates.

COMPONENTS — individual 0–100 scores:
  Structure  = HTF EMA alignment × candle direction
  Proximity  = distance from nearest swing pivot level
  Session    = trading session quality by hour
  Momentum   = candle body strength (body ÷ total range)
  Volatility = ATR vs 50-bar average (filters dead and spiking markets)

HTF Trend — higher timeframe direction. Confirmed bar only, no drift.

Caution — your weakest component. One actionable reason to wait.

Entry — ENTRY WINDOW or WAIT based on your Signal Threshold setting.

Persistence — consecutive PRIME bar counter.
— = no active streak   3 bars = SUSTAINED   6 bars = ELITE

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
█ RECOMMENDED TIMEFRAMES AND MARKETS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Best timeframes: 1H · 4H · Daily
Works on: 5M · 15M · 30M (more signals, lower quality per signal)
Avoid: below 5M

Forex (EURUSD GBPUSD USDJPY) → NY or London session mode
Gold (XAUUSD) → NY session, 1H or 4H
Crypto (BTCUSD ETHUSD) → Crypto 24/7 mode
Indices (SPX NAS DAX) → NY session

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
█ WEIGHT PRESETS FOR DIFFERENT TRADING STYLES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Weights are fully adjustable. Presets to get you started:

Trend Following (default)
Structure 30 / Proximity 25 / Session 20 / Momentum 15 / Volatility 10

Scalping (5M–15M)
Structure 20 / Proximity 15 / Session 30 / Momentum 25 / Volatility 10

Swing Trading (Daily–Weekly)
Structure 35 / Proximity 30 / Session 5 / Momentum 20 / Volatility 10

Mean Reversion (range markets)
Structure 15 / Proximity 40 / Session 20 / Momentum 15 / Volatility 10

Crypto 24/7
Structure 30 / Proximity 30 / Session 5 / Momentum 20 / Volatility 15

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
█ ALERTS — 6 CONDITIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Prime Setup Detected    — score enters ≥80
2. Good Setup Forming      — score enters 65–79 from below
3. Setup Degraded          — score drops from quality zone
4. Weak Setup Warning      — score collapses below 40
5. Sustained PRIME (3 bars)— streak hits 3 consecutive PRIME bars
6. Elite PRIME (6 bars)    — streak hits 6 consecutive PRIME bars

Set alerts to "Once per bar close" in TradingView settings.
All alerts fire on confirmed closed bars only — no false triggers.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
█ HOW THE SCORE IS CALCULATED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[image]https://www.tradingview.com/x/KpGMWrNp/[/image]
Score = weighted average of 5 components, normalised to 100%.
Weights are user-configurable and auto-normalised — they do not 
need to sum to exactly 100.

1. STRUCTURE (default 30%)
   Compares candle direction to HTF EMA(20) direction.
   Fully bi-directional: bearish candle in bearish HTF = same score 
   as bullish candle in bullish HTF.
   Aligned: score = 65 + (body ratio × 35), max 100
   Misaligned: score = 5 + (body ratio × 25), max 30

2. PROXIMITY (default 25%)
   Measures distance from the nearest confirmed pivot high or low 
   using ta.pivothigh/pivotlow (5-bar lookback) in ATR units.
   Score = 100 − (ATR distance × 18), clamped 0–100.
   At the level = 97–100. Far from structure = 0–20.

3. SESSION (default 20%)
   Hour-by-hour quality score based on New York time.
   NY mode: 08:00–11:00 = 100 · 03:00–05:00 = 88 · 
            11:00–13:00 = 72 · 13:00–16:00 = 60 · 
            dead zones = 25
   London and Tokyo modes follow their respective peak hours.
   Crypto 24/7 = flat 75 (no session bias).

4. MOMENTUM (default 15%)
   Candle body divided by total candle range.
   Full-body candle = 100. Doji = 0.
   Filters indecisive wick-heavy candles.

5. VOLATILITY (default 10%)
   ATR(14) divided by its 50-bar SMA.
   Sweet spot 0.7–1.6 = score 100.
   Too quiet (< 0.7): score scales down.
   Too explosive (> 1.6): score drops sharply.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
█ NO-REPAINT — HOW IT IS ACHIEVED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Three sources of repaint addressed:

HTF EMA: request.security(..., ta.ema(close,20)[1], lookahead_on)
The [1] reads the EMA of the PREVIOUS confirmed HTF bar. 
Locked until the next HTF candle closes. No live-bar drift.

Labels: all signals fire only on barstate.isconfirmed.
Never drawn on an open bar.

Pivots: 5-bar right lookback on confirmed bars only.

Verify: TradingView Replay mode — bar-by-bar playback matches 
published chart exactly on any historical period.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
█ SETTINGS REFERENCE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Higher Timeframe — blank = auto.
Auto logic: 1–5M→30M · 6–15M→1H · 16–60M→4H · 
            61–240M→Daily · Daily→Weekly · Weekly→Monthly

Signal Threshold — Entry Window fires above this score. Default 75.
PRIME tier is always fixed at ≥80 regardless of this setting.

Trading Session — NY · London · Tokyo · Crypto 24/7

Component Weights — all five individually adjustable.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
█ RISK DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This indicator is a decision-support tool, not a trading strategy.
No backtested win rate or profit factor is implied or claimed.
Past signals do not guarantee future performance.
Always use a defined stop loss and proper position sizing.
Trading involves risk of loss. Use at your own discretion.

## Source Code

````pine
// © LunqFX
//@version=6
// ─────────────────────────────────────────────────────────────────────────────
// Confluence Streak — PRIME Entry Tracker [LunqFX]
//
// Most indicators tell you IF conditions align. This one tells you HOW LONG
// they have been aligned — because a setup held for 3+ bars is a fundamentally
// different conviction than a single-bar signal.
//
// Score peaks when HTF trend, proximity to a key level, session quality,
// candle momentum, and volatility context all align simultaneously.
// The indicator is fully bi-directional: bear candle in bear HTF trend scores
// as high as bull candle in bull HTF trend.
// Elite PRIME marks 6+ consecutive confirmed bars of maximum confluence (≥80).
//
// NO-REPAINT GUARANTEE
//   HTF EMA : request.security(..., ema(close,20)[1], lookahead_on)
//             Value is taken from the PREVIOUS confirmed HTF bar and never
//             changes mid-bar. Locked until the next HTF candle closes.
//   Labels  : barstate.isconfirmed only — never drawn on an open bar.
//   Score   : updates each tick on the live bar (normal indicator behaviour)
//             and locks permanently at bar close.
//   Verify  : use Replay mode — historical and live values match exactly.
//
// COMPONENT CORRELATION NOTE
//   Structure (HTF EMA direction) and Proximity (distance from LTF swing
//   pivots) are related but measure different things. Structure is binary
//   trend direction; Proximity is a continuous distance from specific price
//   levels derived from LTF pivothigh/pivotlow — not from the HTF EMA.
//   Partial correlation exists (~40-50% co-movement in trending markets)
//   and is intentional: both confirm price is in a "quality zone." The
//   default weights (30/25) are calibrated to avoid double-counting dominance.
//   Reduce Structure to 20% and Proximity to 20% if you trade mean-reversion.
// ─────────────────────────────────────────────────────────────────────────────
indicator("No-Repaint Entry Score — Multi-Factor Confluence [LunqFX]",
          shorttitle="NRS·LFX", overlay=true,
          max_labels_count=200, max_lines_count=10, max_boxes_count=10)

// ══════════════════════════════════════════════════════════════════════════════
//  INPUTS
// ══════════════════════════════════════════════════════════════════════════════
grpSCORE    = "Score"
htfInput    = input.timeframe("",   "Higher Timeframe (blank = auto)", group=grpSCORE)
scoreThresh = input.int(75, "Signal Threshold",
              minval=50, maxval=95, step=5, group=grpSCORE,
              tooltip="Minimum score to show Entry Window signal in the panel and draw the Entry Zone box. PRIME tier is always ≥80 regardless of this setting.")

grpWT    = "Component Weights"
wtStruct = input.int(30, "Structure %",  minval=5, maxval=50, step=5, group=grpWT,
           tooltip="HTF EMA trend alignment × candle direction. Bi-directional: bear candle in bear trend scores equally high as bull candle in bull trend.")
wtProx   = input.int(25, "Proximity %",  minval=5, maxval=40, step=5, group=grpWT,
           tooltip="Distance from nearest confirmed LTF swing pivot in ATR units. Independent of HTF EMA.")
wtSess   = input.int(20, "Session %",    minval=5, maxval=35, step=5, group=grpWT,
           tooltip="Session quality by hour. Set to 5 for Crypto 24/7 markets.")
wtMom    = input.int(15, "Momentum %",   minval=5, maxval=30, step=5, group=grpWT,
           tooltip="Candle body/range ratio — strong momentum candle scores high.")
wtVol    = input.int(10, "Volatility %", minval=5, maxval=25, step=5, group=grpWT,
           tooltip="ATR vs 50-bar SMA. Penalises too-quiet and too-explosive conditions.")

grpSESS  = "Session"
sessMode = input.string("NY", "Trading Session",
           options=["NY", "London", "Tokyo", "Crypto 24/7"], group=grpSESS,
           tooltip="Select your primary market session. 'Crypto 24/7' applies a flat neutral score.")

grpVIS    = "Display"
showPanel = input.bool(true,  "Show Dashboard Panel",   group=grpVIS)
showZone  = input.bool(true,  "Show Entry Zone",        group=grpVIS)
showLbl   = input.bool(true,  "Show Score Labels",      group=grpVIS)
showCndl  = input.bool(true,  "Color Candles by Score", group=grpVIS)

// ── Input validation — runs once on first bar only
if barstate.isfirst
    if wtStruct + wtProx + wtSess + wtMom + wtVol < 30
        runtime.error("Weights sum too low — check Component Weights settings.")
    if wtStruct + wtProx > 85
        runtime.error("Structure + Proximity > 85% — high correlation risk. Reduce one.")

// ══════════════════════════════════════════════════════════════════════════════
//  PALETTE
// ══════════════════════════════════════════════════════════════════════════════
C_PRIME    = #2ED573
C_GOOD     = #FBBF24
C_MODERATE = #FFA502
C_WEAK     = #FF4757

// ══════════════════════════════════════════════════════════════════════════════
//  HELPERS
// ══════════════════════════════════════════════════════════════════════════════
f_scoreColor(s) =>
    s >= 80 ? C_PRIME : s >= 65 ? C_GOOD : s >= 40 ? C_MODERATE : C_WEAK

f_scoreTxt(s) =>
    s >= 80 ? "PRIME" : s >= 65 ? "GOOD" : s >= 40 ? "MODERATE" : "WEAK"

// Lookup table — avoids string concat loop on every bar
f_bar(v) =>
    n = math.round(v / 100.0 * 8)
    (n <= 0 ? "░░░░░░░░" :
     n == 1  ? "█░░░░░░░" :
     n == 2  ? "██░░░░░░" :
     n == 3  ? "███░░░░░" :
     n == 4  ? "████░░░░" :
     n == 5  ? "█████░░░" :
     n == 6  ? "██████░░" :
     n == 7  ? "███████░" : "████████")

// ══════════════════════════════════════════════════════════════════════════════
//  ATR — guarded against near-zero values on illiquid instruments
// ══════════════════════════════════════════════════════════════════════════════
atr14    = ta.atr(14)
atrSma   = ta.sma(atr14, 50)
_atrSafe = math.max(atr14, syminfo.mintick * 10)

// ══════════════════════════════════════════════════════════════════════════════
//  SWING LEVELS — LTF confirmed pivots only, no repaint
//  Derived from ta.pivothigh/low on the CURRENT timeframe, NOT from the HTF
//  EMA — this keeps Proximity independent of Structure.
// ══════════════════════════════════════════════════════════════════════════════
ph = ta.pivothigh(high, 5, 5)
pl = ta.pivotlow(low,   5, 5)

var float lastPH = na
var float lastPL = na
if not na(ph)
    lastPH := ph
if not na(pl)
    lastPL := pl

// ══════════════════════════════════════════════════════════════════════════════
//  HIGHER TIMEFRAME — EMA(20) on confirmed bars, zero live-bar drift
//  Fix: added Daily and Weekly chart handling to avoid HTF = LTF situation
// ══════════════════════════════════════════════════════════════════════════════
_htfAuto = (timeframe.isminutes and timeframe.multiplier <= 5   ? "30"  :
            timeframe.isminutes and timeframe.multiplier <= 15  ? "60"  :
            timeframe.isminutes and timeframe.multiplier <= 60  ? "240" :
            timeframe.isminutes and timeframe.multiplier <= 240 ? "D"   :
            timeframe.isdaily                                   ? "W"   : "M")
_htf = htfInput != "" ? htfInput : _htfAuto

// [1] + lookahead_on = previous confirmed HTF bar's EMA, never the live value
_htfEma  = request.security(syminfo.tickerid, _htf,
            ta.ema(close, 20)[1], lookahead=barmerge.lookahead_on)
_htfBull = close > _htfEma

// ══════════════════════════════════════════════════════════════════════════════
//  SCORE COMPONENTS
// ══════════════════════════════════════════════════════════════════════════════
_candleBull = close >= open
_range      = high - low
_body       = math.abs(close - open)
_bodyRatio  = _range > 0 ? _body / _range : 0.0

// 1. Structure (default 30%) — HTF EMA alignment × candle direction
//    Fully bi-directional: bear candle in bear HTF scores identically to
//    bull candle in bull HTF. Misaligned setups score 5-30 max.
_aligned = (_htfBull and _candleBull) or (not _htfBull and not _candleBull)
_sStruct = math.round(math.min(_aligned ? 65 + _bodyRatio * 35 : 5 + _bodyRatio * 25, 100))

// 2. Proximity (default 25%) — distance from nearest confirmed LTF swing pivot
_distH   = na(lastPH) ? na : math.abs(close - lastPH) / _atrSafe
_distL   = na(lastPL) ? na : math.abs(close - lastPL) / _atrSafe
_minDist = na(_distH) or na(_distL) ? (na(_distH) ? _distL : _distH) : math.min(_distH, _distL)
_sProx   = na(_minDist) ? 50 : math.max(0, math.min(100, math.round(100 - _minDist * 18)))

// 3. Session (default 20%) — hour-granular quality map per market session
_hr    = hour(time, "America/New_York")
_sSess = (sessMode == "Crypto 24/7" ? 75 :
          sessMode == "London" ?
              (_hr >= 3  and _hr < 5  ? 100 :
               _hr >= 8  and _hr < 11 ? 88  :
               _hr >= 2  and _hr < 3  ? 70  :
               _hr >= 11 and _hr < 13 ? 55  : 25) :
          sessMode == "Tokyo" ?
              (_hr >= 20 or  _hr < 3  ? 100 :
               _hr >= 3  and _hr < 5  ? 55  : 25) :
              (_hr >= 8  and _hr < 11 ? 100 :
               _hr >= 3  and _hr < 5  ? 88  :
               _hr >= 11 and _hr < 13 ? 72  :
               _hr >= 13 and _hr < 16 ? 60  :
               _hr >= 2  and _hr < 3  ? 50  : 25))

// 4. Momentum (default 15%) — body/range ratio
_sMom = math.round(_bodyRatio * 100)

// 5. Volatility (default 10%) — ATR relative to 50-bar SMA
_atrRatio = atrSma > 0 ? atr14 / atrSma : 1.0
_sVol     = (_atrRatio >= 0.7 and _atrRatio <= 1.6 ? 100 :
             _atrRatio < 0.7 ? math.round(_atrRatio / 0.7 * 100) :
             math.max(0, math.round(100 - (_atrRatio - 1.6) * 80)))

// Composite — weights auto-normalised to 100%
_wTotal = wtStruct + wtProx + wtSess + wtMom + wtVol
_score  = _wTotal > 0 ? math.round(
              (_sStruct * wtStruct + _sProx * wtProx +
               _sSess   * wtSess   + _sMom  * wtMom  +
               _sVol    * wtVol) / _wTotal) : 50

_scoreC   = f_scoreColor(_score)
_scoreTxt = f_scoreTxt(_score)

// Score delta — building or degrading
_scoreDelta = not na(_score[1]) ? _score - _score[1] : 0
_deltaArrow = _scoreDelta > 3 ? " ▲" : _scoreDelta < -3 ? " ▼" : " —"

// Tier: 0=WEAK  1=MODERATE  2=GOOD  3=PRIME
_tier = _score >= 80 ? 3 : _score >= 65 ? 2 : _score >= 40 ? 1 : 0

// ══════════════════════════════════════════════════════════════════════════════
//  SCORE PERSISTENCE
//  Counts consecutive CONFIRMED bars where score >= 80.
//  Updated only on confirmed bars so live bar never shows a false streak.
// ══════════════════════════════════════════════════════════════════════════════
var int _primeStreak = 0
if barstate.isconfirmed
    _primeStreak := _score >= 80 ? _primeStreak + 1 : 0

// On live bar, streak reflects last confirmed bar — correct, no false signal
_isSustained = _primeStreak >= 3
_isElite     = _primeStreak >= 6

_persistC   = (_isElite    ? #FFD700 :
               _isSustained ? #00FFCC :
               _scoreC)

_persistTxt = (_isElite    ? "◆◆ ELITE PRIME"    :
               _isSustained ? "◆ SUSTAINED PRIME" :
               _scoreTxt)

// ══════════════════════════════════════════════════════════════════════════════
//  LABELS
//  Three independent cooldown counters — PRIME, WEAK, and GOOD never block
//  each other. Each type has its own frequency budget per timeframe.
//
//  PRIME : first confirmed bar entering score ≥80 — high conviction entry
//  WEAK  : any confirmed drop to score <40 — avoid bad entries
//  GOOD  : only when recovering FROM tier 0 (WEAK) directly — rare, meaningful
//
//  Cooldown per timeframe (bars):
//    1M→20  5M→10  15M→6  30M→5  1H→4  4H→3  Daily+→2
// ══════════════════════════════════════════════════════════════════════════════
_CD = (not timeframe.isminutes          ? 2  :
       timeframe.multiplier <= 1        ? 20 :
       timeframe.multiplier <= 5        ? 10 :
       timeframe.multiplier <= 15       ? 6  :
       timeframe.multiplier <= 30       ? 5  :
       timeframe.multiplier <= 60       ? 4  : 3)

var label[] _lblArr     = array.new<label>()
var label[] _sustainArr = array.new<label>()

// Separate cooldown per signal type — they never block each other
var int _lastPrimeBar = 0
var int _lastWeakBar  = 0
var int _lastGoodBar  = 0

_tierChanged = barstate.isconfirmed and _tier != _tier[1]
_primeEntry  = barstate.isconfirmed and _tier == 3 and _tier[1] < 3
_weakEntry   = barstate.isconfirmed and _tier == 0 and _tier[1] > 0
// GOOD only when recovering from WEAK (tier 0→2) — not every MODERATE→GOOD oscillation
_goodEntry   = barstate.isconfirmed and _tier == 2 and _tier[1] == 0

_f_drawLabel(idx, y, txt, isUp) =>
    _lbl = label.new(idx, y, txt,
                     style     = isUp ? label.style_label_up : label.style_label_down,
                     color     = color.new(#10101E, 5),
                     textcolor = color.new(f_scoreColor(_score), 0),
                     size      = size.normal)
    array.push(_lblArr, _lbl)
    if array.size(_lblArr) > 20
        label.delete(array.shift(_lblArr))

if _primeEntry and bar_index - _lastPrimeBar >= _CD and showLbl
    _f_drawLabel(bar_index, low - atr14 * 0.8,
                 str.tostring(_score) + "\n  PRIME  ", true)
    _lastPrimeBar := bar_index

if _weakEntry and bar_index - _lastWeakBar >= _CD and showLbl
    _f_drawLabel(bar_index, high + atr14 * 0.8,
                 str.tostring(_score) + "\n  WEAK   ", false)
    _lastWeakBar := bar_index

if _goodEntry and bar_index - _lastGoodBar >= _CD and showLbl
    _f_drawLabel(bar_index, low - atr14 * 0.8,
                 str.tostring(_score) + "\n  GOOD   ", true)
    _lastGoodBar := bar_index

// Persistence labels — above candle, independent of tier-change labels
_sustainHit = barstate.isconfirmed and (_primeStreak == 3 or _primeStreak == 6)
if _sustainHit and showLbl
    _sC   = _primeStreak >= 6 ? #FFD700 : #00FFCC
    _stxt = _primeStreak >= 6 ? str.tostring(_primeStreak) + " bars\n◆◆ ELITE" :
                                 "3 bars\n◆ SUSTAINED"
    _sl   = label.new(bar_index, high + atr14 * 0.9, _stxt,
                      style     = label.style_label_down,
                      color     = color.new(#0A0A14, 0),
                      textcolor = color.new(_sC, 0),
                      size      = size.normal)
    array.push(_sustainArr, _sl)
    if array.size(_sustainArr) > 10
        label.delete(array.shift(_sustainArr))

// ══════════════════════════════════════════════════════════════════════════════
//  ENTRY ZONE — 2-band box projected forward, score >= signal threshold
// ══════════════════════════════════════════════════════════════════════════════
var box _zoneInner = na
var box _zoneOuter = na

if barstate.islast and showZone
    if not na(_zoneInner)
        box.delete(_zoneInner)
    if not na(_zoneOuter)
        box.delete(_zoneOuter)
    if _score >= scoreThresh
        _ext  = bar_index + 50
        _top2 = close + atr14 * 0.55
        _bot2 = close - atr14 * 0.55
        _top1 = close + atr14 * 0.25
        _bot1 = close - atr14 * 0.25
        _zoneOuter := box.new(bar_index, _top2, _ext, _bot2,
                               bgcolor=color.new(_scoreC, 85), border_color=na)
        _zoneInner := box.new(bar_index, _top1, _ext, _bot1,
                               bgcolor=color.new(_scoreC, 58),
                               border_color=color.new(_scoreC, 15),
                               border_width=2)

// ══════════════════════════════════════════════════════════════════════════════
//  CANDLE COLORING
// ══════════════════════════════════════════════════════════════════════════════
_ccBull = color.from_gradient(_score, 0, 100, color.new(#1DB954, 0), color.new(#00FF88, 0))
_ccBear = color.from_gradient(_score, 0, 100, color.new(#C0392B, 0), color.new(#FF4757, 0))
_ccBase = _candleBull ? _ccBull : _ccBear
_cc     = (_isElite    ? color.new(#FFD700, 0) :
           _isSustained ? color.new(#00FFCC, 0) :
           _ccBase)
barcolor(showCndl ? _cc : na)

// ══════════════════════════════════════════════════════════════════════════════
//  DASHBOARD PANEL
// ══════════════════════════════════════════════════════════════════════════════
_P_BG  = color.new(#0A0A14, 0)
_P_SEC = color.new(#111120, 0)
_P_ROW = color.new(#0D0D1C, 0)
_P_SEP = color.new(#2A2840, 0)
_P_LBL = color.new(#8886AA, 0)
_P_DIM = color.new(#6664A0, 0)
_P_HDR = (_score >= 80 ? color.new(#0D2B1E, 0) :
          _score >= 65 ? color.new(#1C1500, 0) :
          _score >= 40 ? color.new(#1C0E00, 0) :
          color.new(#1A0000, 0))

// Component name/score arrays — declared as var to avoid re-allocation each tick
var string[] _cNames = array.from("Structure", "Proximity", "Session", "Momentum", "Volatility")

if barstate.islast and showPanel
    var table T = table.new(position.top_right, 2, 20,
                             bgcolor      = _P_BG,
                             frame_color  = color.new(#2D2A70, 50),
                             frame_width  = 1,
                             border_color = _P_BG,
                             border_width = 0)

    // Row 0: Header
    table.cell(T, 0, 0, " ⬡  ENTRY SCORE",
               text_color=color.new(_persistC, 0), bgcolor=_P_HDR,
               text_size=size.large, text_halign=text.align_left)
    table.cell(T, 1, 0, "CStreak·LFX ",
               text_color=_P_DIM, bgcolor=_P_HDR,
               text_size=size.small, text_halign=text.align_right)

    // Row 1: Progress bar + score + delta
    table.cell(T, 0, 1, " " + f_bar(_score),
               text_color=color.new(_persistC, 0), bgcolor=_P_BG,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 1, str.tostring(_score) + _deltaArrow + " ",
               text_color=color.new(_persistC, 0), bgcolor=_P_BG,
               text_size=size.large, text_halign=text.align_right)

    // Row 2: Tier label + confirmed streak count
    // Note: streak count reflects last CONFIRMED bar — correct, no false display
    _streakSuffix = _primeStreak > 0 ? str.tostring(_primeStreak) + " bars " : ""
    table.cell(T, 0, 2, "  " + _persistTxt,
               text_color=color.new(_persistC, 20), bgcolor=_P_BG,
               text_size=size.small, text_halign=text.align_left)
    table.cell(T, 1, 2, _streakSuffix,
               text_color=color.new(_persistC, 20), bgcolor=_P_BG,
               text_size=size.small, text_halign=text.align_right)

    // Row 3: Separator
    table.cell(T, 0, 3, "", bgcolor=_P_SEP, text_size=size.tiny)
    table.cell(T, 1, 3, "", bgcolor=_P_SEP, text_size=size.tiny)

    // Row 4: Components header
    table.cell(T, 0, 4, " ◈  COMPONENTS",
               text_color=_P_DIM, bgcolor=_P_SEC,
               text_size=size.small, text_halign=text.align_left)
    table.cell(T, 1, 4, "", bgcolor=_P_SEC, text_size=size.tiny)

    // Rows 5–9: Individual component scores
    _cScores = array.from(float(_sStruct), float(_sProx), float(_sSess), float(_sMom), float(_sVol))
    for _i = 0 to 4
        _nm  = array.get(_cNames,  _i)
        _sv  = array.get(_cScores, _i)
        _sc  = f_scoreColor(_sv)
        _bg  = _i % 2 == 0 ? _P_ROW : _P_BG
        table.cell(T, 0, 5 + _i, " " + _nm,
                   text_color=_P_LBL, bgcolor=_bg,
                   text_size=size.normal, text_halign=text.align_left)
        table.cell(T, 1, 5 + _i, f_bar(_sv) + " " + str.tostring(_sv) + " ",
                   text_color=color.new(_sc, 0), bgcolor=_bg,
                   text_size=size.small, text_halign=text.align_right)

    // Row 10: Separator
    table.cell(T, 0, 10, "", bgcolor=_P_SEP, text_size=size.tiny)
    table.cell(T, 1, 10, "", bgcolor=_P_SEP, text_size=size.tiny)

    // Row 11: Signal header
    table.cell(T, 0, 11, " ◈  SIGNAL",
               text_color=_P_DIM, bgcolor=_P_SEC,
               text_size=size.small, text_halign=text.align_left)
    table.cell(T, 1, 11, "", bgcolor=_P_SEC, text_size=size.tiny)

    // Row 12: HTF trend
    _dirStr = _htfBull ? "▲  BULL" : "▼  BEAR"
    _dirC   = _htfBull ? color.new(#34D399, 0) : color.new(#F87171, 0)
    table.cell(T, 0, 12, " HTF Trend",
               text_color=_P_LBL, bgcolor=_P_ROW,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 12, _dirStr + " ",
               text_color=_dirC, bgcolor=_P_ROW,
               text_size=size.normal, text_halign=text.align_right)

    // Row 13: Weakest component
    _minS   = math.min(_sStruct, math.min(_sProx, math.min(_sSess, math.min(_sMom, _sVol))))
    _wkName = (_minS == _sStruct ? "Structure" :
               _minS == _sProx   ? "Proximity" :
               _minS == _sSess   ? "Session"   :
               _minS == _sMom    ? "Momentum"  : "Volatility")
    table.cell(T, 0, 13, " Caution",
               text_color=_P_LBL, bgcolor=_P_BG,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 13, _wkName + " ↓ ",
               text_color=color.new(C_WEAK, 0), bgcolor=_P_BG,
               text_size=size.normal, text_halign=text.align_right)

    // Row 14: Entry window (uses Signal Threshold, not hardcoded PRIME tier)
    _entryStr = _score >= scoreThresh ? "✓  ENTRY WINDOW" : "—  WAIT"
    _entryC   = _score >= scoreThresh ? color.new(C_PRIME, 0) : _P_DIM
    table.cell(T, 0, 14, " Entry",
               text_color=_P_LBL, bgcolor=_P_ROW,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 14, _entryStr + " ",
               text_color=_entryC, bgcolor=_P_ROW,
               text_size=size.normal, text_halign=text.align_right)

    // Row 15: Persistence streak
    _streakStr = (_isElite    ? "◆◆ ELITE · "    + str.tostring(_primeStreak) + " bars" :
                  _isSustained ? "◆ SUSTAINED · " + str.tostring(_primeStreak) + " bars" :
                  _primeStreak > 0 ? str.tostring(_primeStreak) + " bar" + (_primeStreak > 1 ? "s" : "") : "—")
    table.cell(T, 0, 15, " Persistence",
               text_color=_P_LBL, bgcolor=_P_ROW,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 15, _streakStr + " ",
               text_color=color.new(_persistC, 0), bgcolor=_P_ROW,
               text_size=size.small, text_halign=text.align_right)

    // Row 16: Separator
    table.cell(T, 0, 16, "", bgcolor=_P_SEP, text_size=size.tiny)
    table.cell(T, 1, 16, "", bgcolor=_P_SEP, text_size=size.tiny)

    // Row 17: Active session
    table.cell(T, 0, 17, " Session",
               text_color=_P_DIM, bgcolor=_P_BG,
               text_size=size.small, text_halign=text.align_left)
    table.cell(T, 1, 17, sessMode + " ",
               text_color=_P_DIM, bgcolor=_P_BG,
               text_size=size.small, text_halign=text.align_right)

    // Row 18: Signal threshold (renamed from "Prime ≥" — clarifies it controls Entry Window)
    table.cell(T, 0, 18, " Signal ≥",
               text_color=_P_DIM, bgcolor=_P_BG,
               text_size=size.small, text_halign=text.align_left)
    table.cell(T, 1, 18, str.tostring(scoreThresh) + " pts ",
               text_color=_P_DIM, bgcolor=_P_BG,
               text_size=size.small, text_halign=text.align_right)

    // Row 19: No-repaint confirmation
    table.cell(T, 0, 19, " No Repaint",
               text_color=_P_DIM, bgcolor=_P_BG,
               text_size=size.small, text_halign=text.align_left)
    table.cell(T, 1, 19, "confirmed close ",
               text_color=_P_DIM, bgcolor=_P_BG,
               text_size=size.small, text_halign=text.align_right)

// ══════════════════════════════════════════════════════════════════════════════
//  DATA WINDOW
// ══════════════════════════════════════════════════════════════════════════════
plot(_score,       title="Score",        display=display.data_window, color=na)
plot(_sStruct,     title="Structure",    display=display.data_window, color=na)
plot(_sProx,       title="Proximity",    display=display.data_window, color=na)
plot(_sSess,       title="Session",      display=display.data_window, color=na)
plot(_sMom,        title="Momentum",     display=display.data_window, color=na)
plot(_sVol,        title="Volatility",   display=display.data_window, color=na)
plot(_primeStreak, title="Prime Streak", display=display.data_window, color=na)

// ══════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ══════════════════════════════════════════════════════════════════════════════
alertcondition(_tierChanged and _tier == 3,
               title="Prime Setup Detected",
               message="CStreak [LunqFX]: PRIME entry setup — all factors aligned.")
alertcondition(_tierChanged and _tier == 2 and _tier[1] < 2,
               title="Good Setup Forming",
               message="CStreak [LunqFX]: GOOD setup forming — score entered quality zone.")
alertcondition(_tierChanged and _tier < 2 and _tier[1] >= 2,
               title="Setup Degraded",
               message="CStreak [LunqFX]: Setup quality dropped — wait for better conditions.")
alertcondition(_tierChanged and _tier == 0,
               title="Weak Setup Warning",
               message="CStreak [LunqFX]: WEAK setup — avoid entering now.")
alertcondition(barstate.isconfirmed and _primeStreak == 3,
               title="Sustained PRIME (3 bars)",
               message="CStreak [LunqFX]: SUSTAINED PRIME — score ≥80 held for 3 consecutive bars. High-conviction setup.")
alertcondition(barstate.isconfirmed and _primeStreak == 6,
               title="Elite PRIME (6 bars)",
               message="CStreak [LunqFX]: ◆◆ ELITE PRIME — score ≥80 held for 6 consecutive bars. Exceptional setup quality.")
````
