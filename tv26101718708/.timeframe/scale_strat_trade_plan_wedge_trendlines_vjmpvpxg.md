# SCALE Strat Trade Plan (+ Wedge Trendlines)

- url: https://www.tradingview.com/script/VjMpvPxG-SCALE-Strat-Trade-Plan-Wedge-Trendlines/
- type: indicator
- pine_id: PUB;9025d0164fea43abbcd2552b53c6f65c
- version: 1.0

## Description

A discretionary decision-support overlay that combines "The Strat" reversal logic with a 5-point S.C.A.L.E confluence score, draws a clean, ready-to-read trade plan — entry, stop, and a 3-step target ladder — and overlays auto-drawn wedge trendlines and the structure that matters.**

It does not predict the market or promise results. It *organizes* what's already on your chart — reversals, levels, momentum, trendlines, and a scored setup — so you can make faster, more consistent discretionary decisions.


 What it shows

🎯 The trade plan**
When a qualifying reversal forms, the indicator draws a complete plan:
- **Entry** — above the bullish reversal bar (Call) or below the bearish one (Put)
- **Stop** — at the structure low/high, but **capped at 0.75 × ATR** so risk stays defined
- **Targets** — a **TP1 / TP2 / TP3 ladder** at 2× / 3× / 4× ATR, each labeled with its % move
- **Shaded reward / risk zones** from entry to TP3 and entry to stop

The plan **locks** once set, so it stays steady through a continuation instead of jumping to every little pullback, and **hides itself** once price closes past its stop or runs far beyond target — no stale plans cluttering the chart.

📊 The S.C.A.L.E score (0–5)**
Every setup is scored on five factors:
- **S** — at a Support/Resistance level
- **C** — a reversal Candle (engulfing / hammer / shooter / doji)
- **A** — Alignment (daily/weekly/monthly) or a Strat reversal
- **L** — Liquidity event (swept swing / break of structure / fair-value gap)
- **E** — daily 5/9 EMA confirmation

A live score reads out in the corner box, and you can require a minimum score before a full plan is drawn.

📐 Auto wedge trendlines**
Two self-updating trendlines connect recent pivot highs (upper) and pivot lows (lower) and extend to the right — so converging wedges, rising/falling channels, and breakout/breakdown lines are drawn for you. Fully adjustable pivot length and which pivots to connect, and they can be toggled off entirely.

🧱 Structure, drawn for you**
- Pivot levels (R2 / R1 / Pivot / S1 / S2) from a configurable anchor timeframe
- Swing highs/lows (auto-tagged Higher High, Lower Low, etc.)
- Previous-week high/low, most-recent liquidity sweep
- Major Fibonacci pullbacks (50% and 61.8% golden)
- Nearest Support / Resistance labels
- "The Strat" bar typing — **1** (inside) / **3** (outside) numbers and **Rev** flags on 2-2 / 2-1-2 / 3-1-2 reversals

🧭 The read-out box (bottom-right)**
`ATR | SC (live score) | Now (live trend) | Mom %`
- **SC** — the current SCALE score, color-graded
- **Now** — the live trend bias on your chart timeframe
- **Mom %** — share of 15m / 1H / 4H / D / W / M timeframes pointing up (green = full continuity, yellow = mixed, red = full down)

🎯 Sniper panel (Dir | 3m | 5m | 15m)**
A compact multi-timeframe panel showing intraday direction, so a lower-timeframe entry can be checked against the higher ones at a glance.

---

How to use it

1. **Add it to any chart and timeframe.** It's built for intraday (3m / 5m / 15m) but works on any resolution — the plan, pivots, and trendlines auto-scale.
2. **Read the box.** `SC` climbing toward your threshold, `Now` for trend direction, `Mom %` for higher-timeframe agreement.
3. **Use the wedge lines for context.** Watch how price behaves at the upper/lower trendline — a reversal off a line, or a clean break of one, is often where the best setups appear.
4. **Wait for a plan to print.** When a reversal qualifies, the Call/Put entry, stop, and TP ladder appear. The label shows the SCALE score and the location (at support / resistance / breakout).
5. **Confirm with the Sniper panel.** For an intraday entry, glance at whether 5m and 15m agree with the direction.
6. **Manage with the ladder.** A common approach: trim at TP1, move stop to entry, let a runner go to TP2 / TP3 — your call.
7. **Tune the filters to your style** (below) — wide open to learn the patterns, or tight for only high-confluence setups.



Key inputs

- **SCALE threshold** — minimum score to draw a full plan (0 = every reversal, higher = selective). Sub-threshold setups can show as lighter **"watch"** flags.
- **Min reversal bar size (× ATR)** — ignores tiny pullback wiggles so the entry isn't re-drawn on every micro-move.
- **Lock entry until it resolves** — keeps one plan steady through a continuation.
- **Noise / fakeout filter** — require a clean directional bar + above-average volume.
- **Level-align entries** — only long at support / short at resistance.
- **Require 3m + 5m + 15m alignment** — top-down confirmation.
- **Block new entries after 3pm ET** — avoids late-day setups with no room before the close.
- **Trendlines (Wedge Maker)** — show/hide, pivot length, which pivots to connect, source, colors, width.
- **Pivot anchor timeframe, ATR length, TP multipliers, stop cap** — fully adjustable.

Each filter is independent — start loose to learn the patterns, then tighten the ones that fit how you trade.

---

Alerts

- **Call / Put entry** — a qualifying setup formed
- **Watch setup** — a lower-score setup is forming
- **TP1 hit / TP3 hit / Stop hit** — manage the open plan

---

Credits

The wedge-trendline module is adapted from **"Wedge Maker Pro – Day Trade Edition" by veryfid**, integrated here with permission/attribution under TradingView's house rules. All credit for that component goes to the original author.


 Notes

- This is a **discretionary tool**, not an automated strategy or signal service. It highlights and scores setups; **you** decide whether to act.
- No indicator guarantees profit. Use proper risk management and your own analysis.
- Best used on liquid instruments where structure is clean.
- Not financial advice. For educational and decision-support purposes only.

## Source Code

````pine
//@version=6
// =====================================================================
//  SCALE Strat Trade Plan
//  Mirrors the Strat / options-entry chart style (Call/Put Entry, Target,
//  option-contract line, named structure levels, Strat 1/3 numbers, TF grid)
//  BUT gates every entry with the S.C.A.L.E score:
//    S support/resistance | C reversal candle | A alignment or signal
//    L swept level / FVG  | E daily 5/9 EMA confirmation
//  Long (calls) at support, short (puts) at resistance. Omits the dense
//  options-chain & Black-Scholes panels to stay readable.
// =====================================================================
indicator("SCALE Strat Trade Plan", shorttitle="SCALE STRAT", overlay=true, max_lines_count=120, max_labels_count=400, max_boxes_count=60, max_bars_back=5000)

// ---------------- Inputs ----------------
gSc = "SCALE entry filter"
requireRev  = input.bool(true, "Also require a Strat reversal (2-2/3-1-2)", group=gSc)
scoreThresh = input.int(2, "  full-plan threshold (0-5)", minval=0, maxval=5, group=gSc)
showWatch   = input.bool(true, "Flag lower 'watch' setups below threshold", group=gSc)
watchThresh = input.int(3, "  watch from this score up to threshold", minval=0, maxval=5, group=gSc)
useLevelGate = input.bool(false, "Level-align entries (long@support / short@resistance)", group=gSc)
noLateEntry  = input.bool(false, "Block new entries after 3pm ET (validated: skips no-room-before-close losers)", group=gSc)
minRevATR    = input.float(0.5, "Min reversal bar size (x ATR) - cuts micro-reversals", step=0.1, minval=0, group=gSc)
showScore   = input.bool(true, "Show ATR / score box", group=gSc)
nearPct     = input.float(0.5, "  'at level' proximity %", step=0.1, group=gSc) / 100.0
emaFast     = input.int(5, "EMA fast (daily)", group=gSc)
emaSlow     = input.int(9, "EMA slow (daily)", group=gSc)

gN = "Noise / fakeout filter"
useNoise  = input.bool(false, "Filter noisy / fakeout bars", group=gN)
maxAtrPct = input.float(6.0, "  skip if ATR > % of price", step=0.5, group=gN) / 100.0
useVol    = input.bool(true, "  require above-avg volume", group=gN)

gS = "Strat candles"
showStrat = input.bool(true, "Number 1 / 3 bars", group=gS)
nBars     = input.int(25, "  on last N bars", minval=5, maxval=120, group=gS)
showRev   = input.bool(true, "Flag reversals", group=gS)

gL = "Structure levels"
showSwing = input.bool(true, "Swing High / Low", group=gL)
swingLen  = input.int(10, "  swing strength", minval=2, group=gL)
showPW    = input.bool(true, "Prev-week High / Low", group=gL)
showSweep = input.bool(true, "Liquidity sweep", group=gL)

gR = "Support / Resistance (pivots)"
showSR = input.bool(true, "Show pivot S/R", group=gR)
srTF   = input.timeframe("D", "Pivot anchor timeframe", group=gR)

gPB = "Pullbacks & nearest R/S"
showFib    = input.bool(true, "Fib pullback levels (of active swing)", group=gPB)
showNearSR = input.bool(true, "Label nearest Support / Resistance", group=gPB)

gP = "Trade plan"
showPlan = input.bool(true, "Entry + Target + TP/SL", group=gP)
showTPViz= input.bool(true, "Shade entry -> TP / SL zones", group=gP)
hideStale = input.bool(true, "Hide a plan once price closes past its stop", group=gP)
lockEntry = input.bool(true, "Lock entry until it resolves (don't re-anchor on every pullback)", group=gP)
atrLen   = input.int(14, "ATR length", group=gP)
tp1x = input.float(2.0, "TP1 / Target x ATR", step=0.5, group=gP)
tp2x = input.float(3.0, "TP2 x ATR", step=0.5, group=gP)
tp3x = input.float(4.0, "TP3 x ATR", step=0.5, group=gP)
stopBuf    = input.float(0.1,  "Stop buffer (x ATR; smaller = tighter)", step=0.05, group=gP)
stopCapATR = input.float(0.75, "Max stop distance (x ATR; caps risk -> R:R)", step=0.25, group=gP)
contractTxt = input.string("", "Option-contract note (e.g. 80c 6/12)", group=gP)

gG = "Timeframe continuity grid"
showGrid = input.bool(true, "Show TF grid (top-right)", group=gG)
showMom  = input.bool(true, "  add momentum row (9/21 EMA)", group=gG)

gSn = "Sniper confirmation (3 / 5 / 15m)"
useSniperConf = input.bool(false, "Require 3m+5m+15m alignment to enter (off = advisory panel only)", group=gSn)
showSniper    = input.bool(true, "Show 3/5/15m confirmation panel", group=gSn)

// ---------------- Core series ----------------
atr = ta.atr(atrLen)

// Strat bar typing
isInside  = high <= high[1] and low >= low[1]
isOutside = high > high[1] and low < low[1]
is2up = high > high[1] and low >= low[1]
is2dn = low < low[1] and high <= high[1]

// Candle patterns
body = math.abs(close - open)
rng  = math.max(high - low, syminfo.mintick)
upW  = high - math.max(close, open)
dnW  = math.min(close, open) - low
isDoji    = body <= rng * 0.1
isHammer  = dnW >= body * 2.0 and upW <= body
isShooter = upW >= body * 2.0 and dnW <= body
bullEngulf = close > open and close[1] < open[1] and close >= open[1] and open <= close[1]
bearEngulf = close < open and close[1] > open[1] and close <= open[1] and open >= close[1]

// Strat reversals
revUp = (is2up and is2dn[1]) or (is2up and isInside[1] and is2dn[2]) or (is2up and isInside[1] and isOutside[2])
revDn = (is2dn and is2up[1]) or (is2dn and isInside[1] and is2up[2]) or (is2dn and isInside[1] and isOutside[2])

// Strat numbers + reversal flags (recent bars only)
recent = bar_index > last_bar_index - nBars
if showStrat and recent
    if isInside
        label.new(bar_index, high, "1", yloc=yloc.abovebar, style=label.style_none, textcolor=color.new(color.gray,0), size=size.normal)
    else if isOutside
        label.new(bar_index, high, "3", yloc=yloc.abovebar, style=label.style_none, textcolor=color.new(color.white,0), size=size.normal)
if showRev and recent
    if revUp
        label.new(bar_index, low, "Rev", yloc=yloc.belowbar, style=label.style_label_up, color=color.new(color.green,20), textcolor=color.white, size=size.tiny)
    else if revDn
        label.new(bar_index, high, "Rev", yloc=yloc.abovebar, style=label.style_label_down, color=color.new(color.red,20), textcolor=color.white, size=size.tiny)

// ---------------- Swings / structure ----------------
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low,  swingLen, swingLen)
var float swH = na
var string swHtxt = na
var float swL = na
var string swLtxt = na
var int swHbar = na
var int swLbar = na
if not na(ph)
    swHtxt := na(swH) ? "Swing High" : (ph < swH ? "Lower High" : "Higher High")
    swH := ph
    swHbar := bar_index - swingLen
if not na(pl)
    swLtxt := na(swL) ? "Swing Low" : (pl > swL ? "Higher Low" : "Lower Low")
    swL := pl
    swLbar := bar_index - swingLen

sweptLow  = not na(swL) and low  < swL and close > swL
sweptHigh = not na(swH) and high > swH and close < swH
bullBOS   = not na(swH) and close > swH and close[1] <= swH
bearBOS   = not na(swL) and close < swL and close[1] >= swL

var float sweepLvl = na
if sweptLow
    sweepLvl := swL
if sweptHigh
    sweepLvl := swH

// Prev-week H/L
pwh = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_on)
pwl = request.security(syminfo.tickerid, "W", low[1],  lookahead=barmerge.lookahead_on)

// Pivot S/R from prior anchor-TF period
srH = request.security(syminfo.tickerid, srTF, high[1],  lookahead=barmerge.lookahead_on)
srL = request.security(syminfo.tickerid, srTF, low[1],   lookahead=barmerge.lookahead_on)
srC = request.security(syminfo.tickerid, srTF, close[1], lookahead=barmerge.lookahead_on)
pivot = (srH + srL + srC) / 3.0
r1 = 2.0 * pivot - srL
s1 = 2.0 * pivot - srH
r2 = pivot + (srH - srL)
s2 = pivot - (srH - srL)

// ---------------- SCALE inputs: daily EMA (E) + FVG (L) + alignment (A) ----------------
dEmaSlow = request.security(syminfo.tickerid, "D", ta.ema(close, emaSlow))
dXup = request.security(syminfo.tickerid, "D", ta.barssince(ta.crossover(ta.ema(close, emaFast), ta.ema(close, emaSlow))))
dXdn = request.security(syminfo.tickerid, "D", ta.barssince(ta.crossunder(ta.ema(close, emaFast), ta.ema(close, emaSlow))))
E_long  = (not na(dXup) and dXup <= 3) or (close > dEmaSlow and low  <= dEmaSlow * (1.0 + nearPct))
E_short = (not na(dXdn) and dXdn <= 3) or (close < dEmaSlow and high >= dEmaSlow * (1.0 - nearPct))

bullFVG = low > high[2]
bearFVG = high < low[2]
var float fvgTop = na
var float fvgBot = na
var float bfvgTop = na
var float bfvgBot = na
if bullFVG
    fvgTop := low
    fvgBot := high[2]
if bearFVG
    bfvgTop := low[2]
    bfvgBot := high
inBullFVG = not na(fvgBot)  and close <= fvgTop  and close >= fvgBot
inBearFVG = not na(bfvgBot) and close <= bfvgTop and close >= bfvgBot

u15  = request.security(syminfo.tickerid, "15",  close > open)
u60  = request.security(syminfo.tickerid, "60",  close > open)
u240 = request.security(syminfo.tickerid, "240", close > open)
uD   = request.security(syminfo.tickerid, "D",   close > open)
uW   = request.security(syminfo.tickerid, "W",   close > open)
uM   = request.security(syminfo.tickerid, "M",   close > open)
alignUp = uD and uW and uM
alignDn = (not uD) and (not uW) and (not uM)

// Timeframe-continuity MOMENTUM (9 EMA > 21 EMA per timeframe)
f_mom(simple string tf) => request.security(syminfo.tickerid, tf, ta.ema(close, 9) > ta.ema(close, 21))
m15 = f_mom("15")
m60 = f_mom("60")
m240 = f_mom("240")
mD  = f_mom("D")
mW  = f_mom("W")
mM  = f_mom("M")
momUpAll = m15 and m60 and m240 and mD and mW and mM
momDnAll = (not m15) and (not m60) and (not m240) and (not mD) and (not mW) and (not mM)
momUpCount = (m15 ? 1 : 0) + (m60 ? 1 : 0) + (m240 ? 1 : 0) + (mD ? 1 : 0) + (mW ? 1 : 0) + (mM ? 1 : 0)
momPct = momUpCount / 6.0 * 100.0   // % of the 6 timeframes with upward momentum

// Sniper confirmation (TOP-DOWN): 5m + 15m define the tradeable DIRECTION; the chart-TF (3m/5m) reversal is the trigger.
// m3 is shown for reference but is NOT required to align — so the 3m entry can still catch the turn, with the higher TFs backing it.
// Trend per TF = momentum up (9>21) OR price already back above the 21 EMA — flips to the live direction without the slow-cross lag.
f_trend(simple string tf) => request.security(syminfo.tickerid, tf, ta.ema(close, 9) > ta.ema(close, 21) or close > ta.ema(close, 21))
st3  = f_trend("3")
st5  = f_trend("5")
st15 = f_trend("15")
// Validated (12-name 5m basket): the 15m-responsive filter is the edge driver; adding 5m HURTS it. Dir follows 15m only.
confLong  = st15
confShort = not st15

// ---------------- SCALE score (long & short) ----------------
f_near(float[] arr, float px) =>
    bool hit = false
    for i = 0 to array.size(arr) - 1
        v = array.get(arr, i)
        if not na(v) and math.abs(px - v) <= px * nearPct
            hit := true
    hit
f_above(float[] arr, float ref) =>
    float best = na
    for i = 0 to array.size(arr) - 1
        v = array.get(arr, i)
        if not na(v) and v > ref
            best := na(best) ? v : math.min(best, v)
    best
f_below(float[] arr, float ref) =>
    float best = na
    for i = 0 to array.size(arr) - 1
        v = array.get(arr, i)
        if not na(v) and v < ref
            best := na(best) ? v : math.max(best, v)
    best
supLevels = array.from(s1, s2, swL, pwl, pivot)
resLevels = array.from(r1, r2, swH, pwh, pivot)
nearSup = f_near(supLevels, close)
nearRes = f_near(resLevels, close)

longScore  = ((nearSup or nearRes) ? 1 : 0) + ((isDoji or isHammer or bullEngulf) ? 1 : 0) + ((alignUp or revUp or isHammer) ? 1 : 0) + ((sweptLow or bullBOS or inBullFVG) ? 1 : 0) + (E_long ? 1 : 0)
shortScore = ((nearSup or nearRes) ? 1 : 0) + ((isDoji or isShooter or bearEngulf) ? 1 : 0) + ((alignDn or revDn or isShooter) ? 1 : 0) + ((sweptHigh or bearBOS or inBearFVG) ? 1 : 0) + (E_short ? 1 : 0)

// ---------------- SCALE-gated entries (frozen at trigger; long & short tracked separately) ----------------
// Noise / fakeout filter — sane volatility, real volume, clean directional bar (closes strong, not a wicky trap)
brange = math.max(high - low, syminfo.mintick)
atrOk  = atr / close <= maxAtrPct
volOk  = not useVol or volume > ta.sma(volume, 20)
cleanLong  = close > open and (high - close) <= brange * 0.4 and (close - open) >= brange * 0.3
cleanShort = close < open and (close - low)  <= brange * 0.4 and (open - close) >= brange * 0.3
noiseOkLong  = not useNoise or (atrOk and volOk and cleanLong)
noiseOkShort = not useNoise or (atrOk and volOk and cleanShort)

// Entry = a CLEAN, high-SCALE trigger (matches the scanner). Reversal mode (default): a Strat reversal that
// scores >= threshold. Score mode (requireRev off): the score crossing up into threshold. Both need a clean bar.
longEvent  = requireRev ? revUp : (longScore  >= scoreThresh and longScore[1]  < scoreThresh)
shortEvent = requireRev ? revDn : (shortScore >= scoreThresh and shortScore[1] < scoreThresh)
// Level-aligned entry gate: long only at support or a clean breakout (not pinned under resistance);
// short only at resistance or a clean breakdown (not sitting on support) — blocks shorting INTO support, etc.
longLevelOk  = not useLevelGate or nearSup or (bullBOS and not nearRes)
shortLevelOk = not useLevelGate or nearRes or (bearBOS and not nearSup)
notLate = not noLateEntry or hour(time, "America/New_York") < 15
bigRev = (high - low) >= minRevATR * atr   // reversal bar must be at least this big -> drops tiny pullback wiggles
longTrig  = longEvent  and longScore  >= scoreThresh and noiseOkLong  and longLevelOk  and (not useSniperConf or confLong)  and notLate and bigRev
shortTrig = shortEvent and shortScore >= scoreThresh and noiseOkShort and shortLevelOk and (not useSniperConf or confShort) and notLate and bigRev
alertcondition(longTrig,  "SCALE Strat: Call entry", "Call (long) setup - SCALE-confirmed Strat reversal")
alertcondition(shortTrig, "SCALE Strat: Put entry",  "Put (short) setup - SCALE-confirmed Strat reversal")

// 'Watch' setups: a reversal scoring in [watchThresh, threshold) — flagged on the chart so you can decide or wait for 4/5+
longWatch  = longEvent  and longScore  >= watchThresh and longScore  < scoreThresh and noiseOkLong  and longLevelOk
shortWatch = shortEvent and shortScore >= watchThresh and shortScore < scoreThresh and noiseOkShort and shortLevelOk
if showWatch and recent and longWatch
    label.new(bar_index, low,  "Watch C " + str.tostring(longScore)  + "/5", yloc=yloc.belowbar, style=label.style_label_up,   color=color.new(color.green,45), textcolor=color.white, size=size.tiny)
if showWatch and recent and shortWatch
    label.new(bar_index, high, "Watch P " + str.tostring(shortScore) + "/5", yloc=yloc.abovebar, style=label.style_label_down, color=color.new(color.red,45),   textcolor=color.white, size=size.tiny)
alertcondition(longWatch or shortWatch, "SCALE Strat: Watch setup", "A watch-level setup (below full threshold) formed - your call, or wait for a higher SCALE")

// LONG plan — values LOCK when the trigger fires; stays drawn until a new long trigger replaces it
var float Lentry = na
var int   Lbar   = na
var float Lscore = na
var float Lstop  = na
var float Ltp1   = na
var float Ltp2   = na
var float Ltp3   = na
var bool  Llocked = false
if longTrig and (not lockEntry or not Llocked)
    Lentry := high
    Lbar   := bar_index
    Lscore := longScore
    Lstop  := math.max(low - stopBuf * atr, high - stopCapATR * atr)   // structure low, but risk capped at stopCapATR x ATR
    Ltp1   := high + tp1x * atr
    Ltp2   := high + tp2x * atr
    Ltp3   := high + tp3x * atr
    Llocked := true
// release the lock once the long plan resolves (stopped or ran past target) so a fresh setup can re-anchor
if Llocked and (na(Lentry) or close <= Lstop or (close - Lentry) > (tp3x + 1) * atr)
    Llocked := false

// SHORT plan — frozen; stays drawn until a new short trigger replaces it
var float Sentry = na
var int   Sbar   = na
var float Sscore = na
var float Sstop  = na
var float Stp1   = na
var float Stp2   = na
var float Stp3   = na
var bool  Slocked = false
if shortTrig and (not lockEntry or not Slocked)
    Sentry := low
    Sbar   := bar_index
    Sscore := shortScore
    Sstop  := math.min(high + stopBuf * atr, low + stopCapATR * atr)   // structure high, but risk capped at stopCapATR x ATR
    Stp1   := low - tp1x * atr
    Stp2   := low - tp2x * atr
    Stp3   := low - tp3x * atr
    Slocked := true
// release the lock once the short plan resolves (stopped or ran past target)
if Slocked and (na(Sentry) or close >= Sstop or (Sentry - close) > (tp3x + 1) * atr)
    Slocked := false

var int   lastSide  = 0
var float lastScore = na
if longTrig
    lastSide := 1
    lastScore := longScore
if shortTrig
    lastSide := -1
    lastScore := shortScore
f_favL(float p) => na(Lentry) or Lentry == 0 ? 0.0 : (p - Lentry) / Lentry * 100.0
f_favS(float p) => na(Sentry) or Sentry == 0 ? 0.0 : (Sentry - p) / Sentry * 100.0

// Exit alerts — price first touches the active plan's Target or Stop (notify only; does NOT clear the drawing)
longTPhit  = not na(Ltp1)  and high >= Ltp1  and high[1] < Ltp1
longSLhit  = not na(Lstop) and low  <= Lstop and low[1]  > Lstop
shortTPhit = not na(Stp1)  and low  <= Stp1  and low[1]  > Stp1
shortSLhit = not na(Sstop) and high >= Sstop and high[1] < Sstop
alertcondition(longTPhit or shortTPhit, "SCALE Strat: Target hit", "Target reached on the active SCALE Strat trade")
alertcondition(longSLhit or shortSLhit, "SCALE Strat: Stop hit",   "Stop reached on the active SCALE Strat trade")

// Live trend bias on the CHART timeframe (this drives the "Now" cell so the box tracks current price, not a stale trigger)
emaFastC = ta.ema(close, emaFast)
emaSlowC = ta.ema(close, emaSlow)
biasUp = emaFastC > emaSlowC and close > emaSlowC
biasDn = emaFastC < emaSlowC and close < emaSlowC

// ---------------- Draw levels + plan on the last bar ----------------
var line[]  Llines  = array.new_line()
var label[] Llabels = array.new_label()
var box[]   Lboxes  = array.new_box()
f_level(float price, string txt, color col, bool dashed) =>
    if not na(price)
        array.push(Llines,  line.new(bar_index - 1, price, bar_index, price, color=col, style=dashed ? line.style_dashed : line.style_solid, extend=extend.right))
        array.push(Llabels, label.new(bar_index + 2, price, txt, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(col,20), textcolor=color.white, size=size.small))

if barstate.islast
    while array.size(Llines) > 0
        line.delete(array.pop(Llines))
    while array.size(Llabels) > 0
        label.delete(array.pop(Llabels))
    while array.size(Lboxes) > 0
        box.delete(array.pop(Lboxes))
    if showSR
        f_level(r2, "R2 " + str.tostring(r2, format.mintick), color.red, false)
        f_level(r1, "R1 " + str.tostring(r1, format.mintick), color.red, false)
        f_level(pivot, "Pivot " + str.tostring(pivot, format.mintick), color.gray, true)
        f_level(s1, "S1 " + str.tostring(s1, format.mintick), color.green, false)
        f_level(s2, "S2 " + str.tostring(s2, format.mintick), color.green, false)
    if showSwing
        f_level(swH, (na(swHtxt) ? "Swing High" : swHtxt) + " " + str.tostring(swH, format.mintick), color.gray, false)
        f_level(swL, (na(swLtxt) ? "Swing Low"  : swLtxt) + " " + str.tostring(swL, format.mintick), color.gray, false)
    if showPW
        f_level(pwh, "PWH " + str.tostring(pwh, format.mintick), color.blue, false)
        f_level(pwl, "PWL " + str.tostring(pwl, format.mintick), color.blue, false)
    if showSweep and not na(sweepLvl)
        f_level(sweepLvl, "Liq Sweep " + str.tostring(sweepLvl, format.mintick), color.orange, true)
    if showFib and not na(swH) and not na(swL) and (swH - swL) > 0
        rngF = swH - swL
        upLeg = not na(swHbar) and not na(swLbar) and swHbar >= swLbar
        b500 = upLeg ? swH - rngF * 0.5   : swL + rngF * 0.5
        b618 = upLeg ? swH - rngF * 0.618 : swL + rngF * 0.618
        f_level(b500, "Pullback 50% " + str.tostring(b500, format.mintick), color.olive, true)
        f_level(b618, "Pullback 62% (golden) " + str.tostring(b618, format.mintick), color.olive, true)
    if showNearSR
        nR = f_above(array.from(r1, r2, swH, pwh), close)
        nS = f_below(array.from(s1, s2, swL, pwl), close)
        f_level(nR, "Resistance " + str.tostring(nR, format.mintick), color.new(color.red,0), false)
        f_level(nS, "Support " + str.tostring(nS, format.mintick), color.new(color.green,0), false)
    if showPlan and not na(Lentry) and (not hideStale or ((na(Lstop) or close > Lstop) and (close - Lentry) <= (tp3x + 1) * atr))
        if showTPViz and not na(Ltp3)
            array.push(Lboxes, box.new(math.max(Lbar, bar_index - 300),math.max(Lentry, Ltp3), bar_index + 5, math.min(Lentry, Ltp3), border_color=color.new(color.green,80), bgcolor=color.new(color.green,90)))
            if not na(Lstop)
                array.push(Lboxes, box.new(math.max(Lbar, bar_index - 300),math.max(Lentry, Lstop), bar_index + 5, math.min(Lentry, Lstop), border_color=color.new(color.red,80), bgcolor=color.new(color.red,90)))
        f_level(Lentry, "Call Entry Above " + str.tostring(Lentry, format.mintick) + "  (SCALE " + str.tostring(Lscore) + "/5)", color.green, false)
        if contractTxt != ""
            f_level(Lentry, contractTxt, color.green, false)
        f_level(Lstop, "SL " + str.tostring(Lstop, format.mintick) + " (" + str.tostring(f_favL(Lstop), "#.#") + "%)", color.red, false)
        f_level(Ltp1, "Target " + str.tostring(Ltp1, format.mintick) + " (+" + str.tostring(f_favL(Ltp1), "#.#") + "%)", color.aqua, true)
        f_level(Ltp2, "TP2 " + str.tostring(Ltp2, format.mintick) + " (+" + str.tostring(f_favL(Ltp2), "#.#") + "%)", color.green, true)
        f_level(Ltp3, "TP3 " + str.tostring(Ltp3, format.mintick) + " (+" + str.tostring(f_favL(Ltp3), "#.#") + "%)", color.green, true)
    if showPlan and not na(Sentry) and (not hideStale or ((na(Sstop) or close < Sstop) and (Sentry - close) <= (tp3x + 1) * atr))
        if showTPViz and not na(Stp3)
            array.push(Lboxes, box.new(math.max(Sbar, bar_index - 300),math.max(Sentry, Stp3), bar_index + 5, math.min(Sentry, Stp3), border_color=color.new(color.green,80), bgcolor=color.new(color.green,90)))
            if not na(Sstop)
                array.push(Lboxes, box.new(math.max(Sbar, bar_index - 300),math.max(Sentry, Sstop), bar_index + 5, math.min(Sentry, Sstop), border_color=color.new(color.red,80), bgcolor=color.new(color.red,90)))
        f_level(Sentry, "Put Entry Below " + str.tostring(Sentry, format.mintick) + "  (SCALE " + str.tostring(Sscore) + "/5)", color.red, false)
        if contractTxt != ""
            f_level(Sentry, contractTxt, color.red, false)
        f_level(Sstop, "SL " + str.tostring(Sstop, format.mintick) + " (" + str.tostring(f_favS(Sstop), "#.#") + "%)", color.red, false)
        f_level(Stp1, "Target " + str.tostring(Stp1, format.mintick) + " (+" + str.tostring(f_favS(Stp1), "#.#") + "%)", color.aqua, true)
        f_level(Stp2, "TP2 " + str.tostring(Stp2, format.mintick) + " (+" + str.tostring(f_favS(Stp2), "#.#") + "%)", color.green, true)
        f_level(Stp3, "TP3 " + str.tostring(Stp3, format.mintick) + " (+" + str.tostring(f_favS(Stp3), "#.#") + "%)", color.green, true)

// ---------------- Timeframe trend grid ----------------
f_dirCol(bool up) => up ? color.new(color.green,0) : color.new(color.red,0)
var table grid = table.new(position.top_right, 7, 3, border_width=1)
if showGrid and barstate.islast
    table.cell(grid, 0, 0, "TF",  text_color=color.gray,  text_size=size.tiny, bgcolor=color.new(color.gray,45))
    table.cell(grid, 1, 0, "15m", text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.gray,30))
    table.cell(grid, 2, 0, "1H",  text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.gray,30))
    table.cell(grid, 3, 0, "4H",  text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.gray,30))
    table.cell(grid, 4, 0, "D",   text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.gray,30))
    table.cell(grid, 5, 0, "W",   text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.gray,30))
    table.cell(grid, 6, 0, "M",   text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.gray,30))
    table.cell(grid, 0, 1, "Dir", text_color=color.gray, text_size=size.tiny, bgcolor=color.new(color.gray,45))
    table.cell(grid, 1, 1, "", bgcolor=f_dirCol(u15))
    table.cell(grid, 2, 1, "", bgcolor=f_dirCol(u60))
    table.cell(grid, 3, 1, "", bgcolor=f_dirCol(u240))
    table.cell(grid, 4, 1, "", bgcolor=f_dirCol(uD))
    table.cell(grid, 5, 1, "", bgcolor=f_dirCol(uW))
    table.cell(grid, 6, 1, "", bgcolor=f_dirCol(uM))
    if showMom
        table.cell(grid, 0, 2, "Mom", text_color=color.gray, text_size=size.tiny, bgcolor=color.new(color.gray,45))
        table.cell(grid, 1, 2, "", bgcolor=f_dirCol(m15))
        table.cell(grid, 2, 2, "", bgcolor=f_dirCol(m60))
        table.cell(grid, 3, 2, "", bgcolor=f_dirCol(m240))
        table.cell(grid, 4, 2, "", bgcolor=f_dirCol(mD))
        table.cell(grid, 5, 2, "", bgcolor=f_dirCol(mW))
        table.cell(grid, 6, 2, "", bgcolor=f_dirCol(mM))

// ---------------- ATR / SCALE score box ----------------
// "Last" = the most recent triggered setup (can be old / can have failed). "Now" = the LIVE chart-TF trend,
// so the box tracks current price instead of clinging to a stale trigger (that was the "still says short" bug).
var table sbox = table.new(position.bottom_right, 4, 1, border_width=1)
if showScore and barstate.islast
    liveScore = biasUp ? longScore : biasDn ? shortScore : math.max(longScore, shortScore)
    scBg = liveScore >= scoreThresh ? color.new(color.green,0) : liveScore >= watchThresh ? color.new(color.yellow,0) : color.new(color.gray,20)
    scTx = (liveScore >= watchThresh and liveScore < scoreThresh) ? color.black : color.white
    nowTxt = biasUp ? "Now LONG" : biasDn ? "Now SHORT" : "Now -"
    nowBg  = biasUp ? color.new(color.green,0) : biasDn ? color.new(color.red,0) : color.new(color.gray,20)
    ftfc = "Mom " + str.tostring(momPct, "#") + "%"
    ftfcBg = momUpAll ? color.new(color.green,0) : momDnAll ? color.new(color.red,0) : color.new(color.yellow,0)
    ftfcTx = (momUpAll or momDnAll) ? color.white : color.black
    table.cell(sbox, 0, 0, "ATR " + str.tostring(atr, format.mintick), text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray,20))
    table.cell(sbox, 1, 0, "SC " + str.tostring(liveScore) + "/5", text_color=scTx, text_size=size.small, bgcolor=scBg)
    table.cell(sbox, 2, 0, nowTxt, text_color=color.white, text_size=size.small, bgcolor=nowBg)
    table.cell(sbox, 3, 0, ftfc, text_color=ftfcTx, text_size=size.small, bgcolor=ftfcBg)

// ---------------- Sniper confirmation panel: 3m / 5m / 15m alignment ----------------
// All three green = confirmed long context, all red = confirmed short; a SCALE entry in that direction is the sniper entry.
var table snipT = table.new(position.middle_right, 4, 2, border_width=1)
if showSniper and barstate.islast
    snStat = confLong ? "LONG" : confShort ? "SHORT" : "WAIT"
    snBg   = confLong ? color.new(color.green,0) : confShort ? color.new(color.red,0) : color.new(color.gray,20)
    hdrBg = color.rgb(40, 44, 52)
    table.cell(snipT, 0, 0, "Dir",  text_color=color.white, text_size=size.small, bgcolor=hdrBg)
    table.cell(snipT, 1, 0, "3m t", text_color=color.white, text_size=size.small, bgcolor=hdrBg)
    table.cell(snipT, 2, 0, "5m",   text_color=color.white, text_size=size.small, bgcolor=hdrBg)
    table.cell(snipT, 3, 0, "15m",  text_color=color.white, text_size=size.small, bgcolor=hdrBg)
    table.cell(snipT, 0, 1, snStat, text_color=color.white, text_size=size.small, bgcolor=snBg)
    table.cell(snipT, 1, 1, st3  ? "UP" : "DN", text_color=color.white, text_size=size.small, bgcolor=st3  ? color.new(color.green,0) : color.new(color.red,0))
    table.cell(snipT, 2, 1, st5  ? "UP" : "DN", text_color=color.white, text_size=size.small, bgcolor=st5  ? color.new(color.green,0) : color.new(color.red,0))
    table.cell(snipT, 3, 1, st15 ? "UP" : "DN", text_color=color.white, text_size=size.small, bgcolor=st15 ? color.new(color.green,0) : color.new(color.red,0))

// =====================================================================
//  Trendlines — "Wedge Maker Pro" (integrated; original (c) veryfid)
//  Auto-draws upper (pivot-high) and lower (pivot-low) wedge lines.
// =====================================================================
gTL = "Trendlines (Wedge Maker)"
showTrend = input.bool(true, "Show wedge trendlines", group=gTL)
tlLenU   = input.int(10, "Upper pivot length", minval=2, group=gTL, tooltip="Lower = more frequent / tighter wedges; higher = macro trends.")
tlAStart = input.int(1, "Upper: start from pivot #", minval=0, group=gTL, tooltip="0 = most recent pivot, 1 = previous, etc.")
tlAEnd   = input.int(0, "Upper: end at pivot #", minval=0, group=gTL)
tlLenL   = input.int(10, "Lower pivot length", minval=2, group=gTL)
tlBStart = input.int(1, "Lower: start from pivot #", minval=0, group=gTL)
tlBEnd   = input.int(0, "Lower: end at pivot #", minval=0, group=gTL)
tlCsrc   = input.bool(false, "Use custom source instead of High/Low?", group=gTL)
tlSrc    = input.source(close, "Custom source", group=gTL)
tlUpCol  = input.color(color.red, "Upper line color", group=gTL)
tlDnCol  = input.color(color.green, "Lower line color", group=gTL)
tlWidth  = input.int(2, "Line width", minval=1, maxval=4, group=gTL)

tlHi = tlCsrc ? tlSrc : high
tlLo = tlCsrc ? tlSrc : low
tlUpPiv = ta.pivothigh(tlHi, tlLenU, tlLenU)
tlDnPiv = ta.pivotlow(tlLo, tlLenL, tlLenL)
tlA1i = ta.valuewhen(not na(tlUpPiv), bar_index, tlAStart)
tlA1v = ta.valuewhen(not na(tlUpPiv), tlHi[tlLenU], tlAStart)
tlA2i = ta.valuewhen(not na(tlUpPiv), bar_index, tlAEnd)
tlA2v = ta.valuewhen(not na(tlUpPiv), tlHi[tlLenU], tlAEnd)
tlB1i = ta.valuewhen(not na(tlDnPiv), bar_index, tlBStart)
tlB1v = ta.valuewhen(not na(tlDnPiv), tlLo[tlLenL], tlBStart)
tlB2i = ta.valuewhen(not na(tlDnPiv), bar_index, tlBEnd)
tlB2v = ta.valuewhen(not na(tlDnPiv), tlLo[tlLenL], tlBEnd)

var line tlUpper = na
var line tlLower = na
if showTrend
    if not na(tlA1v) and not na(tlA2v)
        line.delete(tlUpper)
        tlUpper := line.new(tlA1i - tlLenU, tlA1v, tlA2i - tlLenU, tlA2v, extend=extend.right, color=tlUpCol, width=tlWidth)
    if not na(tlB1v) and not na(tlB2v)
        line.delete(tlLower)
        tlLower := line.new(tlB1i - tlLenL, tlB1v, tlB2i - tlLenL, tlB2v, extend=extend.right, color=tlDnCol, width=tlWidth)
else
    line.delete(tlUpper)
    line.delete(tlLower)
````
