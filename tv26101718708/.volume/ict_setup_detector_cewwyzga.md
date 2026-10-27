# ICT Setup Detector

- url: https://www.tradingview.com/script/cEWwyzGA-ICT-Setup-Detector/
- type: indicator
- pine_id: PUB;bf2fb5b97cd24a91972a2427896664e9
- version: 1.0

## Description

ICT SETUP DETECTOR (ICT-SD)
A mechanical, bias-gated ICT setup scanner for NQ and ES futures intraday
(built and tuned on the 1-minute chart). It marks liquidity, draws the key
daily/session levels, grades directional bias across three timeframes, and
arms four ICT trade setups with fixed targets, stops, and alerts.

This is an INDICATOR, not a strategy — it places no orders. It draws on the
chart and fires alert() messages so you can act (or forward them to a bot).

------------------------------------------------------------
WHAT IT DRAWS
------------------------------------------------------------
LEVELS
- PDH / PDL — previous day high & low
- Overnight H / L — 18:00 to 09:30 ET range
- Midnight Open (00:00 ET) and RTH Open (09:30 ET)
- ORG — Opening Range Gap zone (prior RTH close to today's RTH open)
- Prior Week H / L

BIAS ENGINE (top-right table)
- Reads three timeframes (default 4H / 1H / 15m) plus the ORG gap state
- Modes: Structure (pivot HH/HL), Momentum (EMA 20 vs 50 + close), or Hybrid
- Produces a gate: "Longs OK", "Shorts OK", or "NO TRADE"
- When the gate is on, setups only arm in the permitted direction

KILLZONES (shaded)
- London 03:00-04:00, NY AM 10:00-11:00, NY PM 14:00-15:00 (NY time, DST-aware)

LIQUIDITY SWEEPS
- BSL/SSL grabs of PDH/PDL/ON H/L (breach within N bars + close back through)
- Red "BSL" / green "SSL" triangles

TRADE SETUPS (each has arm -> entry -> exit with TP / SL / time-stop)
- Silver Bullet — sweep, then FVG + displacement inside a killzone
- OTE — 62-79% fib retrace of a swept leg
- OB+FVG — order-block 50% mitigation behind a displacement FVG
- Sweep Reversal (SR) — simple sweep-and-fade scalp (yellow SR-L / SR-S)

15-MINUTE FVG IDENTIFIER
- 3-bar Fair Value Gaps from the 15m timeframe, drawn on your chart
- Non-repainting (only confirmed/closed 15m candles create a box)
- Teal = bullish gap, red = bearish gap, with a dashed CE (mid) line
- Boxes extend right until price fully fills the gap, then freeze/grey

------------------------------------------------------------
HOW TO USE
------------------------------------------------------------
1. Add to an NQ or ES chart on the 1-minute timeframe (point sizing is
   auto-detected from the ticker; other symbols fall back to NQ values).
2. Check the bias table (top-right) for the current gate state before acting.
3. Wait for a setup flag/label to arm in the gate-allowed direction. Each
   setup shows its FVG/zone box, dashed entry (CE), dotted stop, dotted TP.
4. Targets default to +20 pts (NQ) / +15 pts (ES). Setups auto-skip when the
   required stop is wider than the configured max.
5. To get notified: create an alert on this indicator and choose the
   "Any alert() function call" condition. Enable the alert types you want
   in the Alerts group (armed / entry / exit / bias-flip / new 15m FVG).

------------------------------------------------------------
KEY SETTINGS
------------------------------------------------------------
- Bias gate on/off, and Bias mode (Structure / Momentum / Hybrid)
- Enable/disable each setup individually
- Displacement filter: x ATR(20) and optional volume-spike requirement
- Sweep breach window (how many bars a wick may lead the close-back)
- Targets and "skip if stop >" caps (per NQ / ES)
- Killzone session times, colors, and visualization toggles
- 15m FVG: timeframe, min gap size, CE line, extend-until-mitigated,
  remove-vs-grey on fill, max active gaps, and per-direction colors

TUNING
- Too few signals: set Bias mode to Momentum, turn the bias gate off, or
  lower the displacement volume multiplier toward 1.0
- Too many signals: raise Displacement x ATR to ~2.0, raise the volume
  multiplier to 1.5-2.0, or raise the minimum FVG size

------------------------------------------------------------
NOTES
------------------------------------------------------------
- Designed for NQ/ES on the 1m chart; other symbols/timeframes are untested.
- Live intrabar markers (especially Sweep Reversal) can update until the bar
  closes; all alerts fire on bar close, so alerts are stable.
- Educational tool. Not financial advice. Test before trading live.
```

Want me to:
- **Trim it to a short version** (a few lines) for the tooltip/one-liner, or
- **Save it to a file** in the repo (e.g. `pine/ICT-SD-description.txt`) alongside the source?

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © srt298

//@version=6
// ICT Setup Detector — Phase 2: Bias Engine + Levels
// Spec: specs/ICT_INDICATOR_SPEC.md
//
// Phase 1: Levels (PDH/PDL, ON H/L, MO, RTH O, ORG, PWH/PWL).
// Phase 2: Bias engine (Daily/1H/15m structure + ORG state) with mode-aware gate.

indicator("ICT Setup Detector", "ICT-SD", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// =====================================================
// INPUTS
// =====================================================

g_bias = "Bias"
BIAS_GATE_ENABLED = input.bool(true, "Enable bias gate (off = setups arm both directions)", group=g_bias)
SHOW_BIAS_LABEL = input.bool(true, "Show bias label", group=g_bias)
BIAS_MODE = input.string("Hybrid", "Bias mode", options=["Structure", "Momentum", "Hybrid"], tooltip="Structure = pivot-based HH/HL (slow, strict). Momentum = EMA(20) vs EMA(50) + close (fast, intraday-friendly). Hybrid = Structure on High TF, Momentum on Mid+Low TFs.", group=g_bias)
BIAS_TF_HIGH = input.timeframe("240", "High TF", group=g_bias)
BIAS_TF_HIGH_PIVOT_BARS = input.int(3, "  High TF pivot bars (L/R)", minval=1, group=g_bias)
BIAS_TF_MID = input.timeframe("60", "Mid TF", group=g_bias)
BIAS_TF_MID_PIVOT_BARS = input.int(3, "  Mid TF pivot bars (L/R)", minval=1, group=g_bias)
BIAS_TF_LOW = input.timeframe("15", "Low TF", group=g_bias)
BIAS_TF_LOW_PIVOT_BARS = input.int(2, "  Low TF pivot bars (L/R)", minval=1, group=g_bias)
BIAS_MOM_FAST = input.int(20, "  Momentum fast EMA", minval=2, group=g_bias)
BIAS_MOM_SLOW = input.int(50, "  Momentum slow EMA", minval=3, group=g_bias)
REQUIRE_ORG = input.bool(true, "Require ORG alignment", group=g_bias)

g_setups = "Setups"
ENABLE_SB = input.bool(true, "Enable Silver Bullet", group=g_setups)
ENABLE_OTE = input.bool(true, "Enable OTE", group=g_setups)
ENABLE_OB_FVG = input.bool(true, "Enable OB+FVG mitigation", group=g_setups)
MIN_FVG_NQ = input.float(4.0, "Min FVG size NQ (pts)", minval=0.25, group=g_setups)
MIN_FVG_ES = input.float(1.5, "Min FVG size ES (pts)", minval=0.25, group=g_setups)
DISPLACEMENT_ATR = input.float(1.5, "Displacement x ATR(20)", minval=0.5, group=g_setups)
USE_VOLUME_DISPLACEMENT = input.bool(true, "Require high-volume displacement (TFO-style)", group=g_setups)
DISPLACEMENT_VOLUME_MULT = input.float(1.3, "  Displacement volume mult (vs SMA20)", minval=1.0, group=g_setups)
SWEEP_LOOKBACK = input.int(30, "Sweep lookback bars", minval=5, group=g_setups)
SWEEP_BREACH_BARS = input.int(3, "Sweep breach window (bars wick can lead close-back)", minval=1, maxval=10, group=g_setups, tooltip="A sweep fires when a tracked level was breached within the last N bars AND price closes back through it. N=1 means strict same-bar wick+close-through. N=3 means the level can be poked on bar -2/-1/0 and we still count it when this bar closes back through.")
ENABLE_SR = input.bool(true, "Enable Sweep Reversal (simple sweep+fade)", group=g_setups)
SR_MAX_STOP_NQ = input.float(12.0, "  SR max stop NQ (pts)", minval=2.0, group=g_setups)
SR_MAX_STOP_ES = input.float(4.0, "  SR max stop ES (pts)", minval=1.0, group=g_setups)
SR_REQUIRE_KZ = input.bool(false, "  SR require killzone window", group=g_setups)

g_levels = "Levels"
SHOW_PDH_PDL = input.bool(true, "PDH / PDL", group=g_levels)
SHOW_ON_HL = input.bool(true, "Overnight H / L", group=g_levels)
SHOW_MIDNIGHT_OPEN = input.bool(true, "Midnight Open", group=g_levels)
SHOW_RTH_OPEN = input.bool(true, "RTH Open", group=g_levels)
SHOW_ORG = input.bool(true, "ORG zone", group=g_levels)
SHOW_PWH_PWL = input.bool(true, "Prior Week H / L", group=g_levels)
SHOW_1H_FVG = input.bool(true, "1H FVGs (today) [Phase 4]", group=g_levels)
SHOW_1M_FVG = input.bool(false, "1m FVGs (today) [Phase 4]", group=g_levels)

g_colors = "Colors"
COL_PDH = input.color(color.new(#FF1744, 30), "PDH", group=g_colors)
COL_PDL = input.color(color.new(#00E676, 30), "PDL", group=g_colors)
COL_ON  = input.color(color.new(#AB47BC, 40), "Overnight H/L", group=g_colors)
COL_MO  = input.color(color.new(#FF9100, 30), "Midnight Open", group=g_colors)
COL_RTH = input.color(color.new(#2979FF, 30), "RTH Open", group=g_colors)
COL_ORG = input.color(color.new(#FFEB3B, 80), "ORG zone fill", group=g_colors)
COL_PWH = input.color(color.new(#880E4F, 50), "Prior Week H", group=g_colors)
COL_PWL = input.color(color.new(#004D40, 50), "Prior Week L", group=g_colors)

g_targets = "Targets"
TP_NQ = input.float(20.0, "TP NQ (pts)", minval=1.0, group=g_targets)
TP_ES = input.float(15.0, "TP ES (pts)", minval=0.5, group=g_targets)
SKIP_STOP_NQ = input.float(25.0, "Skip if stop > NQ pts", minval=5.0, group=g_targets)
SKIP_STOP_ES = input.float(8.0, "Skip if stop > ES pts", minval=1.0, group=g_targets)
TIME_STOP_BARS = input.int(10, "Time-stop bars (1m)", minval=1, group=g_targets)

g_kz = "Killzones (NY)"
SB_LONDON_SESSION = input.session("0300-0400", "London SB", group=g_kz)
SB_NY_AM_SESSION  = input.session("1000-1100", "NY AM SB", group=g_kz)
SB_NY_PM_SESSION  = input.session("1400-1500", "NY PM SB", group=g_kz)

g_alerts = "Alerts"
ALERT_FORM = input.bool(true, "Setup-armed alerts", group=g_alerts)
ALERT_ENTRY = input.bool(true, "Entry-trigger alerts", group=g_alerts)
ALERT_EXIT = input.bool(true, "TP/SL/Time-stop alerts", group=g_alerts)
ALERT_BIAS_FLIP = input.bool(false, "Bias-flip alerts", group=g_alerts)

g_viz = "Visualization"
VIZ_MODE = input.string("show armed", "Mode", options=["alert-only", "show armed", "show all"], group=g_viz)
SHOW_KILLZONE_BANDS = input.bool(true, "Killzone shading", group=g_viz)
SHOW_SWEEP_MARKERS = input.bool(true, "Sweep markers (BSL/SSL triangles)", group=g_viz)
SHOW_BIAS_BG = input.bool(true, "Tint bar background by gate state", group=g_viz)

// =====================================================
// HELPERS
// =====================================================
TZ = "America/New_York"
nyHour = hour(time, TZ)
nyMin = minute(time, TZ)
nyMinutes = nyHour * 60 + nyMin
isNewDayNY = ta.change(dayofmonth(time, TZ)) != 0

isNQ = str.contains(syminfo.ticker, "NQ")
isES = str.contains(syminfo.ticker, "ES")

rightBar = bar_index + 50

// =====================================================
// LEVEL: Previous Day H / L
// =====================================================
[pdhRaw, pdlRaw] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead=barmerge.lookahead_off)

var line  pdhLine  = na
var line  pdlLine  = na
var label pdhLabel = na
var label pdlLabel = na

if SHOW_PDH_PDL and not na(pdhRaw)
    if na(pdhLine)
        pdhLine  := line.new(bar_index, pdhRaw, rightBar, pdhRaw, color=COL_PDH, width=1)
        pdhLabel := label.new(rightBar, pdhRaw, "", style=label.style_label_left, color=color.new(color.black, 100), textcolor=COL_PDH, size=size.small)
    line.set_xy1(pdhLine, bar_index - 200, pdhRaw)
    line.set_xy2(pdhLine, rightBar, pdhRaw)
    label.set_xy(pdhLabel, rightBar, pdhRaw)
    label.set_text(pdhLabel, "PDH " + str.tostring(pdhRaw, format.mintick))

if SHOW_PDH_PDL and not na(pdlRaw)
    if na(pdlLine)
        pdlLine  := line.new(bar_index, pdlRaw, rightBar, pdlRaw, color=COL_PDL, width=1)
        pdlLabel := label.new(rightBar, pdlRaw, "", style=label.style_label_left, color=color.new(color.black, 100), textcolor=COL_PDL, size=size.small)
    line.set_xy1(pdlLine, bar_index - 200, pdlRaw)
    line.set_xy2(pdlLine, rightBar, pdlRaw)
    label.set_xy(pdlLabel, rightBar, pdlRaw)
    label.set_text(pdlLabel, "PDL " + str.tostring(pdlRaw, format.mintick))

// =====================================================
// LEVEL: Overnight H / L (18:00 ET -> 09:30 ET)
// =====================================================
isOnStart = (nyMinutes >= 18 * 60) and (nyMinutes[1] < 18 * 60 or na(nyMinutes[1]))
isOnEnd   = (nyMinutes >= 9 * 60 + 30) and (nyMinutes[1] < 9 * 60 + 30 or na(nyMinutes[1]))

var float onHigh      = na
var float onLow       = na
var int   onStartBar  = na
var bool  inOvernight = false

if isOnStart
    inOvernight := true
    onHigh := high
    onLow  := low
    onStartBar := bar_index
if isOnEnd
    inOvernight := false
if inOvernight and not isOnStart
    onHigh := math.max(nz(onHigh, high), high)
    onLow  := math.min(nz(onLow,  low),  low)

var line  onHighLine  = na
var line  onLowLine   = na
var label onHighLabel = na
var label onLowLabel  = na

if SHOW_ON_HL and not na(onHigh)
    if na(onHighLine)
        onHighLine  := line.new(nz(onStartBar, bar_index), onHigh, rightBar, onHigh, color=COL_ON, width=1, style=line.style_dashed)
        onLowLine   := line.new(nz(onStartBar, bar_index), onLow,  rightBar, onLow,  color=COL_ON, width=1, style=line.style_dashed)
        onHighLabel := label.new(rightBar, onHigh, "", style=label.style_label_left, color=color.new(color.black, 100), textcolor=COL_ON, size=size.small)
        onLowLabel  := label.new(rightBar, onLow,  "", style=label.style_label_left, color=color.new(color.black, 100), textcolor=COL_ON, size=size.small)
    line.set_xy1(onHighLine, nz(onStartBar, bar_index - 200), onHigh)
    line.set_xy2(onHighLine, rightBar, onHigh)
    line.set_xy1(onLowLine,  nz(onStartBar, bar_index - 200), onLow)
    line.set_xy2(onLowLine,  rightBar, onLow)
    label.set_xy(onHighLabel, rightBar, onHigh)
    label.set_xy(onLowLabel,  rightBar, onLow)
    label.set_text(onHighLabel, "ON H " + str.tostring(onHigh, format.mintick))
    label.set_text(onLowLabel,  "ON L " + str.tostring(onLow,  format.mintick))

// =====================================================
// LEVEL: Midnight Open (00:00 ET)
// =====================================================
var float midnightOpen          = na
var int   midnightBar           = na
var bool  midnightCapturedToday = false

if isNewDayNY
    midnightCapturedToday := false
if not midnightCapturedToday
    midnightOpen := open
    midnightBar  := bar_index
    midnightCapturedToday := true

var line  moLine  = na
var label moLabel = na

if SHOW_MIDNIGHT_OPEN and not na(midnightOpen)
    if na(moLine)
        moLine  := line.new(midnightBar, midnightOpen, rightBar, midnightOpen, color=COL_MO, width=1, style=line.style_dotted)
        moLabel := label.new(rightBar, midnightOpen, "", style=label.style_label_left, color=color.new(color.black, 100), textcolor=COL_MO, size=size.small)
    line.set_xy1(moLine, midnightBar, midnightOpen)
    line.set_xy2(moLine, rightBar, midnightOpen)
    label.set_xy(moLabel, rightBar, midnightOpen)
    label.set_text(moLabel, "MO " + str.tostring(midnightOpen, format.mintick))

// =====================================================
// LEVEL: RTH Open (09:30 ET)
// =====================================================
var float rthOpen              = na
var int   rthOpenBar           = na
var bool  rthOpenCapturedToday = false

if isNewDayNY
    rthOpenCapturedToday := false
if not rthOpenCapturedToday and nyMinutes >= 9 * 60 + 30
    rthOpen := open
    rthOpenBar := bar_index
    rthOpenCapturedToday := true

var line  rthLine  = na
var label rthLabel = na

if SHOW_RTH_OPEN and not na(rthOpen)
    if na(rthLine)
        rthLine  := line.new(rthOpenBar, rthOpen, rightBar, rthOpen, color=COL_RTH, width=1)
        rthLabel := label.new(rightBar, rthOpen, "", style=label.style_label_left, color=color.new(color.black, 100), textcolor=COL_RTH, size=size.small)
    line.set_xy1(rthLine, rthOpenBar, rthOpen)
    line.set_xy2(rthLine, rightBar, rthOpen)
    label.set_xy(rthLabel, rightBar, rthOpen)
    label.set_text(rthLabel, "RTH O " + str.tostring(rthOpen, format.mintick))

// =====================================================
// LEVEL: ORG zone (prior RTH close 16:00 ET -> today's RTH open 09:30 ET)
// =====================================================
var float priorRthClose         = na
var bool  rthCloseCapturedToday = false

if isNewDayNY
    rthCloseCapturedToday := false
if not rthCloseCapturedToday and nyMinutes >= 16 * 60
    priorRthClose := close[1]
    rthCloseCapturedToday := true

var box   orgBox   = na
var label orgLabel = na

orgValid = SHOW_ORG and not na(priorRthClose) and not na(rthOpen)
if orgValid
    orgTop = math.max(priorRthClose, rthOpen)
    orgBot = math.min(priorRthClose, rthOpen)
    if na(orgBox)
        orgBox   := box.new(rthOpenBar - 30, orgTop, rightBar, orgBot, bgcolor=COL_ORG, border_color=color.new(#FFEB3B, 30), border_width=1)
        orgLabel := label.new(rightBar, (orgTop + orgBot) / 2, "", style=label.style_label_left, color=color.new(color.black, 100), textcolor=color.new(#FFEB3B, 0), size=size.small)
    box.set_lefttop(orgBox, rthOpenBar - 30, orgTop)
    box.set_rightbottom(orgBox, rightBar, orgBot)
    label.set_xy(orgLabel, rightBar, (orgTop + orgBot) / 2)
    label.set_text(orgLabel, "ORG " + str.tostring(orgBot, format.mintick) + "-" + str.tostring(orgTop, format.mintick))

// =====================================================
// LEVEL: Prior Week H / L
// =====================================================
[pwhRaw, pwlRaw] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead=barmerge.lookahead_off)

var line  pwhLine  = na
var line  pwlLine  = na
var label pwhLabel = na
var label pwlLabel = na

if SHOW_PWH_PWL and not na(pwhRaw)
    if na(pwhLine)
        pwhLine  := line.new(bar_index, pwhRaw, rightBar, pwhRaw, color=COL_PWH, width=1, style=line.style_dotted)
        pwhLabel := label.new(rightBar, pwhRaw, "", style=label.style_label_left, color=color.new(color.black, 100), textcolor=COL_PWH, size=size.tiny)
    line.set_xy1(pwhLine, bar_index - 500, pwhRaw)
    line.set_xy2(pwhLine, rightBar, pwhRaw)
    label.set_xy(pwhLabel, rightBar, pwhRaw)
    label.set_text(pwhLabel, "PWH " + str.tostring(pwhRaw, format.mintick))

if SHOW_PWH_PWL and not na(pwlRaw)
    if na(pwlLine)
        pwlLine  := line.new(bar_index, pwlRaw, rightBar, pwlRaw, color=COL_PWL, width=1, style=line.style_dotted)
        pwlLabel := label.new(rightBar, pwlRaw, "", style=label.style_label_left, color=color.new(color.black, 100), textcolor=COL_PWL, size=size.tiny)
    line.set_xy1(pwlLine, bar_index - 500, pwlRaw)
    line.set_xy2(pwlLine, rightBar, pwlRaw)
    label.set_xy(pwlLabel, rightBar, pwlRaw)
    label.set_text(pwlLabel, "PWL " + str.tostring(pwlRaw, format.mintick))

// =====================================================
// PHASE 2: BIAS ENGINE
// =====================================================

// --- HTF pivot detection (computed at higher TF context, user-configurable TFs) ---
[htPH, htPL] = request.security(syminfo.tickerid, BIAS_TF_HIGH,
     [ta.pivothigh(high, BIAS_TF_HIGH_PIVOT_BARS, BIAS_TF_HIGH_PIVOT_BARS),
      ta.pivotlow(low, BIAS_TF_HIGH_PIVOT_BARS, BIAS_TF_HIGH_PIVOT_BARS)],
     lookahead=barmerge.lookahead_off)

[mtPH, mtPL] = request.security(syminfo.tickerid, BIAS_TF_MID,
     [ta.pivothigh(high, BIAS_TF_MID_PIVOT_BARS, BIAS_TF_MID_PIVOT_BARS),
      ta.pivotlow(low, BIAS_TF_MID_PIVOT_BARS, BIAS_TF_MID_PIVOT_BARS)],
     lookahead=barmerge.lookahead_off)

[ltPH, ltPL] = request.security(syminfo.tickerid, BIAS_TF_LOW,
     [ta.pivothigh(high, BIAS_TF_LOW_PIVOT_BARS, BIAS_TF_LOW_PIVOT_BARS),
      ta.pivotlow(low, BIAS_TF_LOW_PIVOT_BARS, BIAS_TF_LOW_PIVOT_BARS)],
     lookahead=barmerge.lookahead_off)

// --- Track last two pivots per TF (to compare HH/HL/LH/LL) ---
var float htPH1 = na, var float htPH2 = na, var float htPL1 = na, var float htPL2 = na
var float mtPH1 = na, var float mtPH2 = na, var float mtPL1 = na, var float mtPL2 = na
var float ltPH1 = na, var float ltPH2 = na, var float ltPL1 = na, var float ltPL2 = na

if not na(htPH)
    htPH2 := htPH1
    htPH1 := htPH
if not na(htPL)
    htPL2 := htPL1
    htPL1 := htPL
if not na(mtPH)
    mtPH2 := mtPH1
    mtPH1 := mtPH
if not na(mtPL)
    mtPL2 := mtPL1
    mtPL1 := mtPL
if not na(ltPH)
    ltPH2 := ltPH1
    ltPH1 := ltPH
if not na(ltPL)
    ltPL2 := ltPL1
    ltPL1 := ltPL

// --- Classify structure: 1=Bull, -1=Bear, 0=Neutral ---
classifyBias(float ph1, float ph2, float pl1, float pl2) =>
    haveAll = not na(ph1) and not na(ph2) and not na(pl1) and not na(pl2)
    bull = haveAll and ph1 > ph2 and pl1 > pl2
    bear = haveAll and ph1 < ph2 and pl1 < pl2
    bull ? 1 : bear ? -1 : 0

htStructBias = classifyBias(htPH1, htPH2, htPL1, htPL2)
mtStructBias = classifyBias(mtPH1, mtPH2, mtPL1, mtPL2)
ltStructBias = classifyBias(ltPH1, ltPH2, ltPL1, ltPL2)

// --- Momentum classifier (fast, EMA-based) ---
// Bull: fast EMA > slow EMA AND close > fast EMA
// Bear: fast EMA < slow EMA AND close < fast EMA
// Neutral: otherwise (close is between EMAs, or EMAs crossing)
[htEmaF, htEmaS, htClose] = request.security(syminfo.tickerid, BIAS_TF_HIGH,
     [ta.ema(close, BIAS_MOM_FAST), ta.ema(close, BIAS_MOM_SLOW), close],
     lookahead=barmerge.lookahead_off)
[mtEmaF, mtEmaS, mtClose] = request.security(syminfo.tickerid, BIAS_TF_MID,
     [ta.ema(close, BIAS_MOM_FAST), ta.ema(close, BIAS_MOM_SLOW), close],
     lookahead=barmerge.lookahead_off)
[ltEmaF, ltEmaS, ltClose] = request.security(syminfo.tickerid, BIAS_TF_LOW,
     [ta.ema(close, BIAS_MOM_FAST), ta.ema(close, BIAS_MOM_SLOW), close],
     lookahead=barmerge.lookahead_off)

momBias(float emaF, float emaS, float c) =>
    have = not na(emaF) and not na(emaS) and not na(c)
    bull = have and emaF > emaS and c > emaF
    bear = have and emaF < emaS and c < emaF
    bull ? 1 : bear ? -1 : 0

htMomBias = momBias(htEmaF, htEmaS, htClose)
mtMomBias = momBias(mtEmaF, mtEmaS, mtClose)
ltMomBias = momBias(ltEmaF, ltEmaS, ltClose)

// --- Select bias source per TF based on BIAS_MODE ---
// Hybrid: HTF=Structure (slow, reliable for trend regime), Mid+Low=Momentum (fast for intraday)
highTfBias = BIAS_MODE == "Momentum" ? htMomBias : htStructBias
midTfBias  = BIAS_MODE == "Structure" ? mtStructBias : mtMomBias
lowTfBias  = BIAS_MODE == "Structure" ? ltStructBias : ltMomBias

// --- ORG state machine: 1=Bull, -1=Bear, 0=Neutral ---
var int  orgState  = 0
var bool orgLocked = false
var bool orgFilled = false

if isNewDayNY
    orgState  := 0
    orgLocked := false
    orgFilled := false

inFirstHourRth = nyMinutes >= 9 * 60 + 30 and nyMinutes < 10 * 60
afterFirstHour = nyMinutes >= 10 * 60

if inFirstHourRth and not orgLocked and not na(priorRthClose) and not na(rthOpen)
    gapSize = rthOpen - priorRthClose
    if gapSize > 0 and low <= priorRthClose
        orgFilled := true
    if gapSize < 0 and high >= priorRthClose
        orgFilled := true

if afterFirstHour and not orgLocked and not na(priorRthClose) and not na(rthOpen)
    gapSize = rthOpen - priorRthClose
    orgState  := orgFilled ? 0 : (gapSize > 0 ? 1 : gapSize < 0 ? -1 : 0)
    orgLocked := true

// --- Gate logic: all 3 TFs must not oppose direction; at least one must confirm ---
hasAnyBull = highTfBias == 1 or midTfBias == 1 or lowTfBias == 1
hasAnyBear = highTfBias == -1 or midTfBias == -1 or lowTfBias == -1

longsConditional  = hasAnyBull and highTfBias != -1 and midTfBias != -1 and lowTfBias != -1 and (not REQUIRE_ORG or orgState != -1)
shortsConditional = hasAnyBear and highTfBias != 1  and midTfBias != 1  and lowTfBias != 1  and (not REQUIRE_ORG or orgState != 1)

longsAllowed  = BIAS_GATE_ENABLED ? longsConditional  : true
shortsAllowed = BIAS_GATE_ENABLED ? shortsConditional : true

// --- Bias label rendering (top-right table) ---
biasStr(int b) => b == 1 ? "Bull" : b == -1 ? "Bear" : "Neutral"
tfLabel(string tf) => tf == "D" ? "D" : tf == "W" ? "W" : tf == "M" ? "M" : tf

gateStr = not BIAS_GATE_ENABLED ? "GATE OFF" : longsAllowed ? "Longs OK" : shortsAllowed ? "Shorts OK" : "NO TRADE"

biasText = tfLabel(BIAS_TF_HIGH) + ": " + biasStr(highTfBias) + " | " + tfLabel(BIAS_TF_MID) + ": " + biasStr(midTfBias) + " | " + tfLabel(BIAS_TF_LOW) + ": " + biasStr(lowTfBias) + " | ORG: " + biasStr(orgState) + " -> " + gateStr

biasColor = not BIAS_GATE_ENABLED ? color.new(color.purple, 30) : longsAllowed ? color.new(color.green, 25) : shortsAllowed ? color.new(color.red, 25) : color.new(color.gray, 50)

var table biasTable = table.new(position.top_right, 1, 1, bgcolor=color.new(color.black, 80), border_width=1, border_color=color.new(color.gray, 50))

if SHOW_BIAS_LABEL and barstate.islast
    table.cell(biasTable, 0, 0, biasText, text_color=color.white, bgcolor=biasColor, text_size=size.normal)

// --- Bar background tint (for backtest visibility) ---
// Renders per-bar so you can audit historical gate state on the chart.
bgEnabled = SHOW_BIAS_BG and BIAS_GATE_ENABLED
bgTint = longsAllowed ? color.new(color.green, 85) : shortsAllowed ? color.new(color.red, 85) : color.new(color.gray, 95)
bgcolor(bgEnabled ? bgTint : na, title="Bias gate background")

// --- Bias-flip alert ---
gateNow = longsAllowed ? 1 : shortsAllowed ? -1 : 0
if ALERT_BIAS_FLIP and not na(gateNow[1]) and gateNow != gateNow[1]
    alert("Bias flipped -> " + biasText, alert.freq_once_per_bar_close)

// =====================================================
// PHASE 3: KILLZONES + SWEEP DETECTION
// =====================================================

// --- Killzone time windows (NY tz, auto-DST via input.session) ---
inLondonSB = not na(time(timeframe.period, SB_LONDON_SESSION, TZ))
inNyAmSB   = not na(time(timeframe.period, SB_NY_AM_SESSION,  TZ))
inNyPmSB   = not na(time(timeframe.period, SB_NY_PM_SESSION,  TZ))
inAnyKillzone = inLondonSB or inNyAmSB or inNyPmSB

currentKzName = inLondonSB ? "London SB" : inNyAmSB ? "NY AM SB" : inNyPmSB ? "NY PM SB" : ""

// --- Killzone background shading ---
kzBgColor = inLondonSB ? color.new(#9C27B0, 88) : inNyAmSB ? color.new(#03A9F4, 86) : inNyPmSB ? color.new(#FF9800, 88) : na
bgcolor(SHOW_KILLZONE_BANDS ? kzBgColor : na, title="Killzone band")

// --- Sweep helpers ---
// A sweep fires when:
//   (a) the level was breached (high > level for BSL, low < level for SSL)
//       on ANY of the last SWEEP_BREACH_BARS bars (default 3), AND
//   (b) THIS bar closes back through the level (close < level for BSL grab,
//       close > level for SSL grab).
// Latching flags (onHSweptFlag etc.) prevent re-firing on the same level
// until the session boundary resets them.
breachedRecentlyUp(float level, int n) =>
    bool result = false
    if not na(level)
        for i = 0 to n - 1
            if high[i] > level
                result := true
    result
breachedRecentlyDown(float level, int n) =>
    bool result = false
    if not na(level)
        for i = 0 to n - 1
            if low[i] < level
                result := true
    result
sweepUpStrict(float level) =>
    not na(level) and breachedRecentlyUp(level, SWEEP_BREACH_BARS) and close < level
sweepDownStrict(float level) =>
    not na(level) and breachedRecentlyDown(level, SWEEP_BREACH_BARS) and close > level

var bool onHSweptFlag = false
var bool onLSweptFlag = false
var bool pdhSweptFlag = false
var bool pdlSweptFlag = false

if isOnStart
    onHSweptFlag := false
    onLSweptFlag := false
if isNewDayNY
    pdhSweptFlag := false
    pdlSweptFlag := false

canSweep = not inOvernight

sweptOnH = canSweep and not onHSweptFlag and sweepUpStrict(onHigh)
sweptOnL = canSweep and not onLSweptFlag and sweepDownStrict(onLow)
sweptPdh = canSweep and not pdhSweptFlag and sweepUpStrict(pdhRaw)
sweptPdl = canSweep and not pdlSweptFlag and sweepDownStrict(pdlRaw)

if sweptOnH
    onHSweptFlag := true
if sweptOnL
    onLSweptFlag := true
if sweptPdh
    pdhSweptFlag := true
if sweptPdl
    pdlSweptFlag := true

bslSweptNow = sweptOnH or sweptPdh
sslSweptNow = sweptOnL or sweptPdl

// --- Sweep state tracking (consumed by Phase 4 setups) ---
var int    lastSweepBar   = na
var int    lastSweepDir   = 0
var float  lastSweepLevel = na
var string lastSweepName  = ""

if bslSweptNow
    lastSweepBar   := bar_index
    lastSweepDir   := 1
    lastSweepLevel := sweptOnH ? onHigh : pdhRaw
    lastSweepName  := sweptOnH ? "ON H" : "PDH"
if sslSweptNow
    lastSweepBar   := bar_index
    lastSweepDir   := -1
    lastSweepLevel := sweptOnL ? onLow : pdlRaw
    lastSweepName  := sweptOnL ? "ON L" : "PDL"

barsSinceLastSweep = na(lastSweepBar) ? na : bar_index - lastSweepBar
recentSweep = not na(barsSinceLastSweep) and barsSinceLastSweep <= SWEEP_LOOKBACK
recentSweepDir = recentSweep ? lastSweepDir : 0

// --- Sweep markers ---
plotshape(SHOW_SWEEP_MARKERS and bslSweptNow, "BSL Swept", style=shape.triangledown, location=location.abovebar, color=color.new(#FF1744, 0), size=size.small, text="BSL", textcolor=color.new(#FF1744, 0))
plotshape(SHOW_SWEEP_MARKERS and sslSweptNow, "SSL Swept", style=shape.triangleup, location=location.belowbar, color=color.new(#00E676, 0), size=size.small, text="SSL", textcolor=color.new(#00E676, 0))

// =====================================================
// PHASE 4: SILVER BULLET DETECTION
// =====================================================

// --- ATR + displacement threshold ---
atr20 = ta.atr(20)
displacementThreshold = atr20 * DISPLACEMENT_ATR

// --- 3-bar FVG detection ---
bullFvgFormed = low > high[2]
bearFvgFormed = high < low[2]

bullFvgUpper = low
bullFvgLower = high[2]
bullFvgSize  = bullFvgUpper - bullFvgLower
bullFvgCE    = (bullFvgUpper + bullFvgLower) / 2

bearFvgUpper = low[2]
bearFvgLower = high
bearFvgSize  = bearFvgUpper - bearFvgLower
bearFvgCE    = (bearFvgUpper + bearFvgLower) / 2

minFvgSize = isNQ ? MIN_FVG_NQ : isES ? MIN_FVG_ES : MIN_FVG_NQ

// --- Displacement check (middle bar = bar -1) ---
disp1 = math.abs(close[1] - open[1])
avgVol20 = ta.sma(volume, 20)
volSpike1 = volume[1] >= avgVol20[1] * DISPLACEMENT_VOLUME_MULT
volPass = not USE_VOLUME_DISPLACEMENT or volSpike1
isDisplacementUp   = close[1] > open[1] and disp1 >= displacementThreshold and volPass
isDisplacementDown = close[1] < open[1] and disp1 >= displacementThreshold and volPass

// --- Stop / TP calc ---
stopBuffer = isNQ ? 2.0 : isES ? 0.75 : 2.0
tpDist     = isNQ ? TP_NQ : isES ? TP_ES : TP_NQ
maxStop    = isNQ ? SKIP_STOP_NQ : isES ? SKIP_STOP_ES : SKIP_STOP_NQ

bullStopRaw  = low[1]  - stopBuffer
bearStopRaw  = high[1] + stopBuffer
bullTPCalc   = bullFvgCE + tpDist
bearTPCalc   = bearFvgCE - tpDist
bullStopDist = bullFvgCE - bullStopRaw
bearStopDist = bearStopRaw - bearFvgCE

bullStopOk = bullStopDist > 0 and bullStopDist <= maxStop
bearStopOk = bearStopDist > 0 and bearStopDist <= maxStop

// --- Arm conditions (all gates must pass) ---
sbBullCanArm = ENABLE_SB and inAnyKillzone and bullFvgFormed and bullFvgSize >= minFvgSize and isDisplacementUp   and recentSweep and recentSweepDir == -1 and longsAllowed  and bullStopOk
sbBearCanArm = ENABLE_SB and inAnyKillzone and bearFvgFormed and bearFvgSize >= minFvgSize and isDisplacementDown and recentSweep and recentSweepDir ==  1 and shortsAllowed and bearStopOk

// =====================================================
// SB-Bull state machine
// =====================================================
var int    sbBullArmedBar = na
var float  sbBullCE       = na
var float  sbBullStop     = na
var float  sbBullTP       = na
var float  sbBullFvgHigh  = na
var float  sbBullFvgLow   = na
var string sbBullKz       = ""
var int    sbBullEntryBar = na
var float  sbBullEntry    = na

sbBullActive  = not na(sbBullArmedBar) and na(sbBullEntryBar) and (bar_index - sbBullArmedBar) <= 10
sbBullInPos   = not na(sbBullEntryBar)
sbBullExpired = not na(sbBullArmedBar) and na(sbBullEntryBar) and (bar_index - sbBullArmedBar) > 10

sbBullArmedNow = false
if sbBullCanArm and na(sbBullArmedBar)
    sbBullArmedBar := bar_index
    sbBullCE       := bullFvgCE
    sbBullStop     := bullStopRaw
    sbBullTP       := bullTPCalc
    sbBullFvgHigh  := bullFvgUpper
    sbBullFvgLow   := bullFvgLower
    sbBullKz       := currentKzName
    sbBullArmedNow := true

sbBullEntryNow = false
if sbBullActive and low <= sbBullCE and na(sbBullEntryBar)
    sbBullEntryBar := bar_index
    sbBullEntry    := sbBullCE
    sbBullEntryNow := true

if sbBullActive and not sbBullEntryNow and low <= sbBullStop
    sbBullArmedBar := na

if sbBullExpired
    sbBullArmedBar := na

sbBullTpHit    = sbBullInPos and high >= sbBullTP
sbBullSlHit    = sbBullInPos and low  <= sbBullStop
sbBullTimeStop = sbBullInPos and (bar_index - sbBullEntryBar) >= TIME_STOP_BARS
sbBullExitNow  = sbBullTpHit or sbBullSlHit or sbBullTimeStop
sbBullExitReason = sbBullTpHit ? "TP" : sbBullSlHit ? "SL" : sbBullTimeStop ? "TIME" : ""

if sbBullExitNow
    sbBullArmedBar := na
    sbBullEntryBar := na

// =====================================================
// SB-Bear state machine
// =====================================================
var int    sbBearArmedBar = na
var float  sbBearCE       = na
var float  sbBearStop     = na
var float  sbBearTP       = na
var float  sbBearFvgHigh  = na
var float  sbBearFvgLow   = na
var string sbBearKz       = ""
var int    sbBearEntryBar = na
var float  sbBearEntry    = na

sbBearActive  = not na(sbBearArmedBar) and na(sbBearEntryBar) and (bar_index - sbBearArmedBar) <= 10
sbBearInPos   = not na(sbBearEntryBar)
sbBearExpired = not na(sbBearArmedBar) and na(sbBearEntryBar) and (bar_index - sbBearArmedBar) > 10

sbBearArmedNow = false
if sbBearCanArm and na(sbBearArmedBar)
    sbBearArmedBar := bar_index
    sbBearCE       := bearFvgCE
    sbBearStop     := bearStopRaw
    sbBearTP       := bearTPCalc
    sbBearFvgHigh  := bearFvgUpper
    sbBearFvgLow   := bearFvgLower
    sbBearKz       := currentKzName
    sbBearArmedNow := true

sbBearEntryNow = false
if sbBearActive and high >= sbBearCE and na(sbBearEntryBar)
    sbBearEntryBar := bar_index
    sbBearEntry    := sbBearCE
    sbBearEntryNow := true

if sbBearActive and not sbBearEntryNow and high >= sbBearStop
    sbBearArmedBar := na

if sbBearExpired
    sbBearArmedBar := na

sbBearTpHit    = sbBearInPos and low  <= sbBearTP
sbBearSlHit    = sbBearInPos and high >= sbBearStop
sbBearTimeStop = sbBearInPos and (bar_index - sbBearEntryBar) >= TIME_STOP_BARS
sbBearExitNow  = sbBearTpHit or sbBearSlHit or sbBearTimeStop
sbBearExitReason = sbBearTpHit ? "TP" : sbBearSlHit ? "SL" : sbBearTimeStop ? "TIME" : ""

if sbBearExitNow
    sbBearArmedBar := na
    sbBearEntryBar := na

// =====================================================
// SB visualization
// =====================================================
if sbBullArmedNow
    box.new(bar_index - 2, sbBullFvgHigh, bar_index + 10, sbBullFvgLow, bgcolor=color.new(#00E676, 85), border_color=color.new(#00E676, 30), border_width=1)
    line.new(bar_index, sbBullCE, bar_index + 10, sbBullCE, color=color.new(#00E676, 0), width=1, style=line.style_dashed)
    line.new(bar_index, sbBullStop, bar_index + 10, sbBullStop, color=color.new(color.red, 30), width=1, style=line.style_dotted)
    line.new(bar_index, sbBullTP, bar_index + 10, sbBullTP, color=color.new(color.green, 30), width=1, style=line.style_dotted)

if sbBearArmedNow
    box.new(bar_index - 2, sbBearFvgHigh, bar_index + 10, sbBearFvgLow, bgcolor=color.new(#FF1744, 85), border_color=color.new(#FF1744, 30), border_width=1)
    line.new(bar_index, sbBearCE, bar_index + 10, sbBearCE, color=color.new(#FF1744, 0), width=1, style=line.style_dashed)
    line.new(bar_index, sbBearStop, bar_index + 10, sbBearStop, color=color.new(color.red, 30), width=1, style=line.style_dotted)
    line.new(bar_index, sbBearTP, bar_index + 10, sbBearTP, color=color.new(color.green, 30), width=1, style=line.style_dotted)

plotshape(sbBullArmedNow, "SB-Bull Armed", style=shape.flag, location=location.belowbar, color=color.new(#00E676, 0), size=size.tiny, text="SB", textcolor=color.new(#00E676, 0))
plotshape(sbBearArmedNow, "SB-Bear Armed", style=shape.flag, location=location.abovebar, color=color.new(#FF1744, 0), size=size.tiny, text="SB", textcolor=color.new(#FF1744, 0))

plotshape(sbBullEntryNow, "SB-Bull Entry", style=shape.labelup,   location=location.belowbar, color=color.new(#00E676, 0), size=size.small, text="L", textcolor=color.white)
plotshape(sbBearEntryNow, "SB-Bear Entry", style=shape.labeldown, location=location.abovebar, color=color.new(#FF1744, 0), size=size.small, text="S", textcolor=color.white)

sbBullExitColor = sbBullTpHit ? color.new(color.green, 0) : sbBullSlHit ? color.new(color.red, 0) : color.new(color.yellow, 0)
sbBearExitColor = sbBearTpHit ? color.new(color.green, 0) : sbBearSlHit ? color.new(color.red, 0) : color.new(color.yellow, 0)

plotshape(sbBullExitNow, "SB-Bull Exit", style=shape.xcross, location=location.belowbar, color=sbBullExitColor, size=size.tiny)
plotshape(sbBearExitNow, "SB-Bear Exit", style=shape.xcross, location=location.abovebar, color=sbBearExitColor, size=size.tiny)

// =====================================================
// SB alerts
// =====================================================
if ALERT_FORM and sbBullArmedNow
    alert(syminfo.ticker + " SB-Bull ARMED | " + sbBullKz + " | FVG " + str.tostring(sbBullFvgLow, format.mintick) + "-" + str.tostring(sbBullFvgHigh, format.mintick) + " | CE " + str.tostring(sbBullCE, format.mintick) + " | Stop " + str.tostring(sbBullStop, format.mintick) + " | TP " + str.tostring(sbBullTP, format.mintick), alert.freq_once_per_bar_close)

if ALERT_FORM and sbBearArmedNow
    alert(syminfo.ticker + " SB-Bear ARMED | " + sbBearKz + " | FVG " + str.tostring(sbBearFvgLow, format.mintick) + "-" + str.tostring(sbBearFvgHigh, format.mintick) + " | CE " + str.tostring(sbBearCE, format.mintick) + " | Stop " + str.tostring(sbBearStop, format.mintick) + " | TP " + str.tostring(sbBearTP, format.mintick), alert.freq_once_per_bar_close)

if ALERT_ENTRY and sbBullEntryNow
    alert(syminfo.ticker + " SB-Bull ENTRY @ " + str.tostring(sbBullEntry, format.mintick) + " | Stop " + str.tostring(sbBullStop, format.mintick) + " (-" + str.tostring(sbBullEntry - sbBullStop, "#.##") + "pt) | TP " + str.tostring(sbBullTP, format.mintick) + " (+" + str.tostring(tpDist, "#.##") + "pt)", alert.freq_once_per_bar_close)

if ALERT_ENTRY and sbBearEntryNow
    alert(syminfo.ticker + " SB-Bear ENTRY @ " + str.tostring(sbBearEntry, format.mintick) + " | Stop " + str.tostring(sbBearStop, format.mintick) + " (-" + str.tostring(sbBearStop - sbBearEntry, "#.##") + "pt) | TP " + str.tostring(sbBearTP, format.mintick) + " (+" + str.tostring(tpDist, "#.##") + "pt)", alert.freq_once_per_bar_close)

if ALERT_EXIT and sbBullExitNow
    alert(syminfo.ticker + " SB-Bull EXIT (" + sbBullExitReason + ")", alert.freq_once_per_bar_close)

if ALERT_EXIT and sbBearExitNow
    alert(syminfo.ticker + " SB-Bear EXIT (" + sbBearExitReason + ")", alert.freq_once_per_bar_close)

// =====================================================
// PHASE 5: OTE (Optimal Trade Entry)
// =====================================================
// Detects qualifying swing leg (after a sweep), draws 62-79% fib retrace zone,
// triggers entry on first bullish/bearish bar inside zone.

otePvtLeft  = 3
otePvtRight = 3
otePvtH = ta.pivothigh(high, otePvtLeft, otePvtRight)
otePvtL = ta.pivotlow(low,  otePvtLeft, otePvtRight)

var float lastPvtH    = na
var int   lastPvtHBar = na
var float lastPvtL    = na
var int   lastPvtLBar = na

if not na(otePvtH)
    lastPvtH := otePvtH
    lastPvtHBar := bar_index - otePvtRight
if not na(otePvtL)
    lastPvtL := otePvtL
    lastPvtLBar := bar_index - otePvtRight

// OTE allows slightly wider stop (per spec)
oteMaxStop = isNQ ? 30.0 : isES ? 10.0 : 30.0

// Bull leg formed when new pivot high confirmed, prior pivot low exists, SSL recently swept
oteBullLegFormed = not na(otePvtH) and not na(lastPvtL) and recentSweepDir == -1
oteBullLegHi = oteBullLegFormed ? otePvtH : na
oteBullLegLo = oteBullLegFormed ? lastPvtL : na
oteBullRange = oteBullLegHi - oteBullLegLo
oteBullZH    = oteBullLegHi - oteBullRange * 0.62  // upper bound (62%)
oteBullZL    = oteBullLegHi - oteBullRange * 0.79  // lower bound (79%)
oteBullZ705  = oteBullLegHi - oteBullRange * 0.705 // sweet spot
oteBullStpRaw = oteBullLegLo - stopBuffer
oteBullTpRaw  = oteBullZ705 + tpDist
oteBullStpDist = oteBullZ705 - oteBullStpRaw
oteBullStpOk   = oteBullStpDist > 0 and oteBullStpDist <= oteMaxStop

oteBearLegFormed = not na(otePvtL) and not na(lastPvtH) and recentSweepDir == 1
oteBearLegHi = oteBearLegFormed ? lastPvtH : na
oteBearLegLo = oteBearLegFormed ? otePvtL : na
oteBearRange = oteBearLegHi - oteBearLegLo
oteBearZL    = oteBearLegLo + oteBearRange * 0.62  // lower bound (62%)
oteBearZH    = oteBearLegLo + oteBearRange * 0.79  // upper bound (79%)
oteBearZ705  = oteBearLegLo + oteBearRange * 0.705
oteBearStpRaw = oteBearLegHi + stopBuffer
oteBearTpRaw  = oteBearZ705 - tpDist
oteBearStpDist = oteBearStpRaw - oteBearZ705
oteBearStpOk   = oteBearStpDist > 0 and oteBearStpDist <= oteMaxStop

oteBullCanArm = ENABLE_OTE and oteBullLegFormed and longsAllowed  and oteBullStpOk
oteBearCanArm = ENABLE_OTE and oteBearLegFormed and shortsAllowed and oteBearStpOk

// OTE-Bull state machine
var int   oteBullArmedBar = na
var float oteBullCE       = na
var float oteBullStop     = na
var float oteBullTP       = na
var float oteBullZHv      = na
var float oteBullZLv      = na
var int   oteBullEntryBar = na
var float oteBullEntry    = na

oteBullActive  = not na(oteBullArmedBar) and na(oteBullEntryBar) and (bar_index - oteBullArmedBar) <= 30
oteBullInPos   = not na(oteBullEntryBar)
oteBullExpired = not na(oteBullArmedBar) and na(oteBullEntryBar) and (bar_index - oteBullArmedBar) > 30

oteBullArmedNow = false
if oteBullCanArm and na(oteBullArmedBar)
    oteBullArmedBar := bar_index
    oteBullCE       := oteBullZ705
    oteBullStop     := oteBullStpRaw
    oteBullTP       := oteBullTpRaw
    oteBullZHv      := oteBullZH
    oteBullZLv      := oteBullZL
    oteBullArmedNow := true

oteBullEntryNow = false
if oteBullActive and low <= oteBullZHv and close >= oteBullZLv and close > open and na(oteBullEntryBar)
    oteBullEntryBar := bar_index
    oteBullEntry    := close
    oteBullEntryNow := true

if oteBullActive and not oteBullEntryNow and low <= oteBullStop
    oteBullArmedBar := na
if oteBullExpired
    oteBullArmedBar := na

oteBullTpHit    = oteBullInPos and high >= oteBullTP
oteBullSlHit    = oteBullInPos and low  <= oteBullStop
oteBullTimeStop = oteBullInPos and (bar_index - oteBullEntryBar) >= TIME_STOP_BARS
oteBullExitNow  = oteBullTpHit or oteBullSlHit or oteBullTimeStop
oteBullExitReason = oteBullTpHit ? "TP" : oteBullSlHit ? "SL" : oteBullTimeStop ? "TIME" : ""

if oteBullExitNow
    oteBullArmedBar := na
    oteBullEntryBar := na

// OTE-Bear state machine
var int   oteBearArmedBar = na
var float oteBearCE       = na
var float oteBearStop     = na
var float oteBearTP       = na
var float oteBearZHv      = na
var float oteBearZLv      = na
var int   oteBearEntryBar = na
var float oteBearEntry    = na

oteBearActive  = not na(oteBearArmedBar) and na(oteBearEntryBar) and (bar_index - oteBearArmedBar) <= 30
oteBearInPos   = not na(oteBearEntryBar)
oteBearExpired = not na(oteBearArmedBar) and na(oteBearEntryBar) and (bar_index - oteBearArmedBar) > 30

oteBearArmedNow = false
if oteBearCanArm and na(oteBearArmedBar)
    oteBearArmedBar := bar_index
    oteBearCE       := oteBearZ705
    oteBearStop     := oteBearStpRaw
    oteBearTP       := oteBearTpRaw
    oteBearZHv      := oteBearZH
    oteBearZLv      := oteBearZL
    oteBearArmedNow := true

oteBearEntryNow = false
if oteBearActive and high >= oteBearZLv and close <= oteBearZHv and close < open and na(oteBearEntryBar)
    oteBearEntryBar := bar_index
    oteBearEntry    := close
    oteBearEntryNow := true

if oteBearActive and not oteBearEntryNow and high >= oteBearStop
    oteBearArmedBar := na
if oteBearExpired
    oteBearArmedBar := na

oteBearTpHit    = oteBearInPos and low  <= oteBearTP
oteBearSlHit    = oteBearInPos and high >= oteBearStop
oteBearTimeStop = oteBearInPos and (bar_index - oteBearEntryBar) >= TIME_STOP_BARS
oteBearExitNow  = oteBearTpHit or oteBearSlHit or oteBearTimeStop
oteBearExitReason = oteBearTpHit ? "TP" : oteBearSlHit ? "SL" : oteBearTimeStop ? "TIME" : ""

if oteBearExitNow
    oteBearArmedBar := na
    oteBearEntryBar := na

// OTE viz
if oteBullArmedNow
    box.new(bar_index, oteBullZHv, bar_index + 30, oteBullZLv, bgcolor=color.new(#2196F3, 88), border_color=color.new(#2196F3, 30), border_width=1)
    line.new(bar_index, oteBullCE, bar_index + 30, oteBullCE, color=color.new(#2196F3, 0), width=1, style=line.style_dashed)
    line.new(bar_index, oteBullStop, bar_index + 30, oteBullStop, color=color.new(color.red, 30), width=1, style=line.style_dotted)
    line.new(bar_index, oteBullTP, bar_index + 30, oteBullTP, color=color.new(color.green, 30), width=1, style=line.style_dotted)

if oteBearArmedNow
    box.new(bar_index, oteBearZHv, bar_index + 30, oteBearZLv, bgcolor=color.new(#FF9800, 88), border_color=color.new(#FF9800, 30), border_width=1)
    line.new(bar_index, oteBearCE, bar_index + 30, oteBearCE, color=color.new(#FF9800, 0), width=1, style=line.style_dashed)
    line.new(bar_index, oteBearStop, bar_index + 30, oteBearStop, color=color.new(color.red, 30), width=1, style=line.style_dotted)
    line.new(bar_index, oteBearTP, bar_index + 30, oteBearTP, color=color.new(color.green, 30), width=1, style=line.style_dotted)

plotshape(oteBullArmedNow, "OTE-Bull Armed", style=shape.flag, location=location.belowbar, color=color.new(#2196F3, 0), size=size.tiny, text="OTE", textcolor=color.new(#2196F3, 0))
plotshape(oteBearArmedNow, "OTE-Bear Armed", style=shape.flag, location=location.abovebar, color=color.new(#FF9800, 0), size=size.tiny, text="OTE", textcolor=color.new(#FF9800, 0))

plotshape(oteBullEntryNow, "OTE-Bull Entry", style=shape.labelup,   location=location.belowbar, color=color.new(#2196F3, 0), size=size.small, text="L", textcolor=color.white)
plotshape(oteBearEntryNow, "OTE-Bear Entry", style=shape.labeldown, location=location.abovebar, color=color.new(#FF9800, 0), size=size.small, text="S", textcolor=color.white)

oteBullExitColor = oteBullTpHit ? color.new(color.green, 0) : oteBullSlHit ? color.new(color.red, 0) : color.new(color.yellow, 0)
oteBearExitColor = oteBearTpHit ? color.new(color.green, 0) : oteBearSlHit ? color.new(color.red, 0) : color.new(color.yellow, 0)

plotshape(oteBullExitNow, "OTE-Bull Exit", style=shape.xcross, location=location.belowbar, color=oteBullExitColor, size=size.tiny)
plotshape(oteBearExitNow, "OTE-Bear Exit", style=shape.xcross, location=location.abovebar, color=oteBearExitColor, size=size.tiny)

// OTE alerts
if ALERT_FORM and oteBullArmedNow
    alert(syminfo.ticker + " OTE-Bull ARMED | Zone " + str.tostring(oteBullZLv, format.mintick) + "-" + str.tostring(oteBullZHv, format.mintick) + " | CE " + str.tostring(oteBullCE, format.mintick) + " | Stop " + str.tostring(oteBullStop, format.mintick) + " | TP " + str.tostring(oteBullTP, format.mintick), alert.freq_once_per_bar_close)
if ALERT_FORM and oteBearArmedNow
    alert(syminfo.ticker + " OTE-Bear ARMED | Zone " + str.tostring(oteBearZLv, format.mintick) + "-" + str.tostring(oteBearZHv, format.mintick) + " | CE " + str.tostring(oteBearCE, format.mintick) + " | Stop " + str.tostring(oteBearStop, format.mintick) + " | TP " + str.tostring(oteBearTP, format.mintick), alert.freq_once_per_bar_close)
if ALERT_ENTRY and oteBullEntryNow
    alert(syminfo.ticker + " OTE-Bull ENTRY @ " + str.tostring(oteBullEntry, format.mintick) + " | Stop " + str.tostring(oteBullStop, format.mintick) + " | TP " + str.tostring(oteBullTP, format.mintick), alert.freq_once_per_bar_close)
if ALERT_ENTRY and oteBearEntryNow
    alert(syminfo.ticker + " OTE-Bear ENTRY @ " + str.tostring(oteBearEntry, format.mintick) + " | Stop " + str.tostring(oteBearStop, format.mintick) + " | TP " + str.tostring(oteBearTP, format.mintick), alert.freq_once_per_bar_close)
if ALERT_EXIT and oteBullExitNow
    alert(syminfo.ticker + " OTE-Bull EXIT (" + oteBullExitReason + ")", alert.freq_once_per_bar_close)
if ALERT_EXIT and oteBearExitNow
    alert(syminfo.ticker + " OTE-Bear EXIT (" + oteBearExitReason + ")", alert.freq_once_per_bar_close)

// =====================================================
// PHASE 6: OB+FVG MITIGATION
// =====================================================
// OB = last opposing candle before a displacement that creates a 3-bar FVG.
// Setup armed when FVG forms with valid OB. Entry on touch of OB midpoint (50%).

// For bull OB+FVG: bar -1 is up displacement, bar -2 is OB candidate (must be down close)
obBullValid = bullFvgFormed and isDisplacementUp and close[2] < open[2]
obBullTop   = obBullValid ? open[2] : na      // OB body top (down candle, open > close)
obBullBot   = obBullValid ? close[2] : na     // OB body bottom
obBullLow   = obBullValid ? low[2] : na       // OB extreme (for stop)
obBull50    = obBullValid ? (obBullTop + obBullBot) / 2 : na
obBullStpRaw = obBullValid ? obBullLow - stopBuffer : na
obBullTpRaw  = obBullValid ? obBull50 + tpDist : na
obBullStpDist = obBull50 - obBullStpRaw
obBullStpOk   = obBullStpDist > 0 and obBullStpDist <= maxStop

// FVG must remain at least 50% unfilled — at moment of formation it's 100% unfilled
// (later we just check that current bar didn't close past CE)

obBearValid = bearFvgFormed and isDisplacementDown and close[2] > open[2]
obBearTop   = obBearValid ? close[2] : na     // OB body top (up candle, close > open)
obBearBot   = obBearValid ? open[2] : na      // OB body bottom
obBearHigh  = obBearValid ? high[2] : na      // OB extreme
obBear50    = obBearValid ? (obBearTop + obBearBot) / 2 : na
obBearStpRaw = obBearValid ? obBearHigh + stopBuffer : na
obBearTpRaw  = obBearValid ? obBear50 - tpDist : na
obBearStpDist = obBearStpRaw - obBear50
obBearStpOk   = obBearStpDist > 0 and obBearStpDist <= maxStop

obBullCanArm = ENABLE_OB_FVG and obBullValid and longsAllowed  and obBullStpOk
obBearCanArm = ENABLE_OB_FVG and obBearValid and shortsAllowed and obBearStpOk

// OB-Bull state machine
var int   obBullArmedBar = na
var float obBullCE       = na
var float obBullStop     = na
var float obBullTP       = na
var float obBullObTop    = na
var float obBullObBot    = na
var int   obBullEntryBar = na
var float obBullEntry    = na

obBullActive  = not na(obBullArmedBar) and na(obBullEntryBar) and (bar_index - obBullArmedBar) <= 20
obBullInPos   = not na(obBullEntryBar)
obBullExpired = not na(obBullArmedBar) and na(obBullEntryBar) and (bar_index - obBullArmedBar) > 20

obBullArmedNow = false
if obBullCanArm and na(obBullArmedBar)
    obBullArmedBar := bar_index
    obBullCE       := obBull50
    obBullStop     := obBullStpRaw
    obBullTP       := obBullTpRaw
    obBullObTop    := obBullTop
    obBullObBot    := obBullBot
    obBullArmedNow := true

obBullEntryNow = false
if obBullActive and low <= obBullCE and na(obBullEntryBar)
    obBullEntryBar := bar_index
    obBullEntry    := obBullCE
    obBullEntryNow := true

if obBullActive and not obBullEntryNow and low <= obBullStop
    obBullArmedBar := na
if obBullExpired
    obBullArmedBar := na

obBullTpHit    = obBullInPos and high >= obBullTP
obBullSlHit    = obBullInPos and low  <= obBullStop
obBullTimeStop = obBullInPos and (bar_index - obBullEntryBar) >= TIME_STOP_BARS
obBullExitNow  = obBullTpHit or obBullSlHit or obBullTimeStop
obBullExitReason = obBullTpHit ? "TP" : obBullSlHit ? "SL" : obBullTimeStop ? "TIME" : ""

if obBullExitNow
    obBullArmedBar := na
    obBullEntryBar := na

// OB-Bear state machine
var int   obBearArmedBar = na
var float obBearCE       = na
var float obBearStop     = na
var float obBearTP       = na
var float obBearObTop    = na
var float obBearObBot    = na
var int   obBearEntryBar = na
var float obBearEntry    = na

obBearActive  = not na(obBearArmedBar) and na(obBearEntryBar) and (bar_index - obBearArmedBar) <= 20
obBearInPos   = not na(obBearEntryBar)
obBearExpired = not na(obBearArmedBar) and na(obBearEntryBar) and (bar_index - obBearArmedBar) > 20

obBearArmedNow = false
if obBearCanArm and na(obBearArmedBar)
    obBearArmedBar := bar_index
    obBearCE       := obBear50
    obBearStop     := obBearStpRaw
    obBearTP       := obBearTpRaw
    obBearObTop    := obBearTop
    obBearObBot    := obBearBot
    obBearArmedNow := true

obBearEntryNow = false
if obBearActive and high >= obBearCE and na(obBearEntryBar)
    obBearEntryBar := bar_index
    obBearEntry    := obBearCE
    obBearEntryNow := true

if obBearActive and not obBearEntryNow and high >= obBearStop
    obBearArmedBar := na
if obBearExpired
    obBearArmedBar := na

obBearTpHit    = obBearInPos and low  <= obBearTP
obBearSlHit    = obBearInPos and high >= obBearStop
obBearTimeStop = obBearInPos and (bar_index - obBearEntryBar) >= TIME_STOP_BARS
obBearExitNow  = obBearTpHit or obBearSlHit or obBearTimeStop
obBearExitReason = obBearTpHit ? "TP" : obBearSlHit ? "SL" : obBearTimeStop ? "TIME" : ""

if obBearExitNow
    obBearArmedBar := na
    obBearEntryBar := na

// OB viz (OB body shaded)
if obBullArmedNow
    box.new(bar_index - 2, obBullObTop, bar_index + 20, obBullObBot, bgcolor=color.new(#9C27B0, 85), border_color=color.new(#9C27B0, 30), border_width=1)
    line.new(bar_index, obBullCE, bar_index + 20, obBullCE, color=color.new(#9C27B0, 0), width=1, style=line.style_dashed)
    line.new(bar_index, obBullStop, bar_index + 20, obBullStop, color=color.new(color.red, 30), width=1, style=line.style_dotted)
    line.new(bar_index, obBullTP, bar_index + 20, obBullTP, color=color.new(color.green, 30), width=1, style=line.style_dotted)

if obBearArmedNow
    box.new(bar_index - 2, obBearObTop, bar_index + 20, obBearObBot, bgcolor=color.new(#E91E63, 85), border_color=color.new(#E91E63, 30), border_width=1)
    line.new(bar_index, obBearCE, bar_index + 20, obBearCE, color=color.new(#E91E63, 0), width=1, style=line.style_dashed)
    line.new(bar_index, obBearStop, bar_index + 20, obBearStop, color=color.new(color.red, 30), width=1, style=line.style_dotted)
    line.new(bar_index, obBearTP, bar_index + 20, obBearTP, color=color.new(color.green, 30), width=1, style=line.style_dotted)

plotshape(obBullArmedNow, "OB-Bull Armed", style=shape.flag, location=location.belowbar, color=color.new(#9C27B0, 0), size=size.tiny, text="OB", textcolor=color.new(#9C27B0, 0))
plotshape(obBearArmedNow, "OB-Bear Armed", style=shape.flag, location=location.abovebar, color=color.new(#E91E63, 0), size=size.tiny, text="OB", textcolor=color.new(#E91E63, 0))

plotshape(obBullEntryNow, "OB-Bull Entry", style=shape.labelup,   location=location.belowbar, color=color.new(#9C27B0, 0), size=size.small, text="L", textcolor=color.white)
plotshape(obBearEntryNow, "OB-Bear Entry", style=shape.labeldown, location=location.abovebar, color=color.new(#E91E63, 0), size=size.small, text="S", textcolor=color.white)

obBullExitColor = obBullTpHit ? color.new(color.green, 0) : obBullSlHit ? color.new(color.red, 0) : color.new(color.yellow, 0)
obBearExitColor = obBearTpHit ? color.new(color.green, 0) : obBearSlHit ? color.new(color.red, 0) : color.new(color.yellow, 0)

plotshape(obBullExitNow, "OB-Bull Exit", style=shape.xcross, location=location.belowbar, color=obBullExitColor, size=size.tiny)
plotshape(obBearExitNow, "OB-Bear Exit", style=shape.xcross, location=location.abovebar, color=obBearExitColor, size=size.tiny)

if ALERT_FORM and obBullArmedNow
    alert(syminfo.ticker + " OB-Bull ARMED | OB " + str.tostring(obBullObBot, format.mintick) + "-" + str.tostring(obBullObTop, format.mintick) + " | CE " + str.tostring(obBullCE, format.mintick) + " | Stop " + str.tostring(obBullStop, format.mintick) + " | TP " + str.tostring(obBullTP, format.mintick), alert.freq_once_per_bar_close)
if ALERT_FORM and obBearArmedNow
    alert(syminfo.ticker + " OB-Bear ARMED | OB " + str.tostring(obBearObBot, format.mintick) + "-" + str.tostring(obBearObTop, format.mintick) + " | CE " + str.tostring(obBearCE, format.mintick) + " | Stop " + str.tostring(obBearStop, format.mintick) + " | TP " + str.tostring(obBearTP, format.mintick), alert.freq_once_per_bar_close)
if ALERT_ENTRY and obBullEntryNow
    alert(syminfo.ticker + " OB-Bull ENTRY @ " + str.tostring(obBullEntry, format.mintick) + " | Stop " + str.tostring(obBullStop, format.mintick) + " | TP " + str.tostring(obBullTP, format.mintick), alert.freq_once_per_bar_close)
if ALERT_ENTRY and obBearEntryNow
    alert(syminfo.ticker + " OB-Bear ENTRY @ " + str.tostring(obBearEntry, format.mintick) + " | Stop " + str.tostring(obBearStop, format.mintick) + " | TP " + str.tostring(obBearTP, format.mintick), alert.freq_once_per_bar_close)
if ALERT_EXIT and obBullExitNow
    alert(syminfo.ticker + " OB-Bull EXIT (" + obBullExitReason + ")", alert.freq_once_per_bar_close)
if ALERT_EXIT and obBearExitNow
    alert(syminfo.ticker + " OB-Bear EXIT (" + obBearExitReason + ")", alert.freq_once_per_bar_close)

// =====================================================
// PHASE 7: SWEEP REVERSAL (SR)
// =====================================================
// Bread-and-butter scalp: a tracked level (PDH/PDL/ON H/ON L) was just swept
// (uses the same latched sweep detection as the other setups). Take a position
// in the reversal direction at the close of the sweep bar.
//
// No FVG required. No displacement candle required. No killzone required
// (toggle SR_REQUIRE_KZ to opt in). Bias gate still respected when enabled.
//
// Stop: 2pt buffer beyond the sweep bar's extreme.
// TP: +20 NQ pts / +15 ES pts (same as other setups).
// Skip: if stop > SR_MAX_STOP_NQ (default 12pt) — keeps it tight.

srMaxStop = isNQ ? SR_MAX_STOP_NQ : isES ? SR_MAX_STOP_ES : SR_MAX_STOP_NQ
srKzOk = not SR_REQUIRE_KZ or inAnyKillzone

// SR-Bull: SSL just got swept → take long at close
srBullStpRaw = sslSweptNow ? low - stopBuffer : na
srBullTpRaw  = sslSweptNow ? close + tpDist : na
srBullStpDist = sslSweptNow ? close - srBullStpRaw : na
srBullStpOk = not na(srBullStpDist) and srBullStpDist > 0 and srBullStpDist <= srMaxStop
srBullCanArm = ENABLE_SR and sslSweptNow and srKzOk and longsAllowed and srBullStpOk

// SR-Bear: BSL just got swept → take short at close
srBearStpRaw = bslSweptNow ? high + stopBuffer : na
srBearTpRaw  = bslSweptNow ? close - tpDist : na
srBearStpDist = bslSweptNow ? srBearStpRaw - close : na
srBearStpOk = not na(srBearStpDist) and srBearStpDist > 0 and srBearStpDist <= srMaxStop
srBearCanArm = ENABLE_SR and bslSweptNow and srKzOk and shortsAllowed and srBearStpOk

// SR-Bull state
var float srBullEntry    = na
var float srBullStop     = na
var float srBullTP       = na
var int   srBullEntryBar = na
var string srBullSweepName = ""

srBullEntryNow = false
if srBullCanArm and na(srBullEntryBar)
    srBullEntry      := close
    srBullStop       := srBullStpRaw
    srBullTP         := srBullTpRaw
    srBullEntryBar   := bar_index
    srBullSweepName  := lastSweepName
    srBullEntryNow   := true

srBullInPos    = not na(srBullEntryBar)
srBullTpHit    = srBullInPos and high >= srBullTP
srBullSlHit    = srBullInPos and low  <= srBullStop
srBullTimeStop = srBullInPos and (bar_index - srBullEntryBar) >= TIME_STOP_BARS
srBullExitNow  = srBullTpHit or srBullSlHit or srBullTimeStop
srBullExitReason = srBullTpHit ? "TP" : srBullSlHit ? "SL" : srBullTimeStop ? "TIME" : ""

if srBullExitNow
    srBullEntryBar := na

// SR-Bear state
var float srBearEntry    = na
var float srBearStop     = na
var float srBearTP       = na
var int   srBearEntryBar = na
var string srBearSweepName = ""

srBearEntryNow = false
if srBearCanArm and na(srBearEntryBar)
    srBearEntry     := close
    srBearStop      := srBearStpRaw
    srBearTP        := srBearTpRaw
    srBearEntryBar  := bar_index
    srBearSweepName := lastSweepName
    srBearEntryNow  := true

srBearInPos    = not na(srBearEntryBar)
srBearTpHit    = srBearInPos and low  <= srBearTP
srBearSlHit    = srBearInPos and high >= srBearStop
srBearTimeStop = srBearInPos and (bar_index - srBearEntryBar) >= TIME_STOP_BARS
srBearExitNow  = srBearTpHit or srBearSlHit or srBearTimeStop
srBearExitReason = srBearTpHit ? "TP" : srBearSlHit ? "SL" : srBearTimeStop ? "TIME" : ""

if srBearExitNow
    srBearEntryBar := na

// SR viz
plotshape(srBullEntryNow, "SR-Bull Entry", style=shape.labelup,   location=location.belowbar, color=color.new(#FFEB3B, 0), size=size.small, text="SR-L", textcolor=color.black)
plotshape(srBearEntryNow, "SR-Bear Entry", style=shape.labeldown, location=location.abovebar, color=color.new(#FFEB3B, 0), size=size.small, text="SR-S", textcolor=color.black)

if srBullEntryNow
    line.new(bar_index, srBullStop, bar_index + 15, srBullStop, color=color.new(color.red, 30), width=1, style=line.style_dotted)
    line.new(bar_index, srBullTP, bar_index + 15, srBullTP, color=color.new(color.green, 30), width=1, style=line.style_dotted)
if srBearEntryNow
    line.new(bar_index, srBearStop, bar_index + 15, srBearStop, color=color.new(color.red, 30), width=1, style=line.style_dotted)
    line.new(bar_index, srBearTP, bar_index + 15, srBearTP, color=color.new(color.green, 30), width=1, style=line.style_dotted)

srBullExitColor = srBullTpHit ? color.new(color.green, 0) : srBullSlHit ? color.new(color.red, 0) : color.new(color.yellow, 0)
srBearExitColor = srBearTpHit ? color.new(color.green, 0) : srBearSlHit ? color.new(color.red, 0) : color.new(color.yellow, 0)
plotshape(srBullExitNow, "SR-Bull Exit", style=shape.xcross, location=location.belowbar, color=srBullExitColor, size=size.tiny)
plotshape(srBearExitNow, "SR-Bear Exit", style=shape.xcross, location=location.abovebar, color=srBearExitColor, size=size.tiny)

// SR alerts (entry-only since there's no separate "armed" phase)
if ALERT_ENTRY and srBullEntryNow
    alert(syminfo.ticker + " SR-Bull ENTRY @ " + str.tostring(srBullEntry, format.mintick) + " | Sweep: " + srBullSweepName + " | Stop " + str.tostring(srBullStop, format.mintick) + " (-" + str.tostring(srBullEntry - srBullStop, "#.##") + "pt) | TP " + str.tostring(srBullTP, format.mintick) + " (+" + str.tostring(tpDist, "#.##") + "pt)", alert.freq_once_per_bar_close)
if ALERT_ENTRY and srBearEntryNow
    alert(syminfo.ticker + " SR-Bear ENTRY @ " + str.tostring(srBearEntry, format.mintick) + " | Sweep: " + srBearSweepName + " | Stop " + str.tostring(srBearStop, format.mintick) + " (-" + str.tostring(srBearStop - srBearEntry, "#.##") + "pt) | TP " + str.tostring(srBearTP, format.mintick) + " (+" + str.tostring(tpDist, "#.##") + "pt)", alert.freq_once_per_bar_close)
if ALERT_EXIT and srBullExitNow
    alert(syminfo.ticker + " SR-Bull EXIT (" + srBullExitReason + ")", alert.freq_once_per_bar_close)
if ALERT_EXIT and srBearExitNow
    alert(syminfo.ticker + " SR-Bear EXIT (" + srBearExitReason + ")", alert.freq_once_per_bar_close)

// =====================================================
// PHASE 8: 15-MINUTE FVG IDENTIFIER
// =====================================================
// Detects 3-bar Fair Value Gaps on a higher timeframe (default 15m) and projects
// them onto the current chart. NON-REPAINTING: detection uses only CLOSED HTF bars
// (the gap's 3rd candle must be fully closed before a box is drawn — inside the
// security call the FVG is measured on bars [1]/[3], never the live HTF bar).
// Boxes extend right until price mitigates (fully fills) the gap, then freeze/grey.

g_fvg15 = "15m FVG"
SHOW_FVG15     = input.bool(true,  "Show 15m FVGs", group=g_fvg15)
FVG15_TF       = input.timeframe("15", "  FVG timeframe", group=g_fvg15)
FVG15_MIN_PTS  = input.float(0.0,  "  Min gap size (pts, 0 = off)", minval=0.0, group=g_fvg15)
FVG15_SHOW_CE  = input.bool(true,  "  Show CE (consequent encroachment)", group=g_fvg15)
FVG15_EXTEND   = input.bool(true,  "  Extend until mitigated", group=g_fvg15)
FVG15_HIDE_MIT = input.bool(false, "  Remove box when mitigated (else grey it)", group=g_fvg15)
FVG15_MAX      = input.int(20, "  Max active FVGs", minval=1, maxval=100, group=g_fvg15)
ALERT_FVG15    = input.bool(false, "  Alert on new 15m FVG", group=g_fvg15)
COL_FVG15_BULL = input.color(color.new(#26A69A, 78), "  Bull FVG", group=g_fvg15)
COL_FVG15_BEAR = input.color(color.new(#EF5350, 78), "  Bear FVG", group=g_fvg15)

// Detect a 3-bar FVG on the HTF using only closed bars (bar[1] = last closed = 3rd candle)
fvg15Detect() =>
    bBull   = low[1] > high[3]
    bBear   = high[1] < low[3]
    bullTop = low[1]
    bullBot = high[3]
    bearTop = low[3]
    bearBot = high[1]
    [bBull, bBear, bullTop, bullBot, bearTop, bearBot]

[fvg15Bull, fvg15Bear, f15BullTop, f15BullBot, f15BearTop, f15BearBot] = request.security(syminfo.tickerid, FVG15_TF, fvg15Detect(), lookahead=barmerge.lookahead_off)

newHtf15 = ta.change(time(FVG15_TF)) != 0

bull15Ok = fvg15Bull and (FVG15_MIN_PTS <= 0 or (f15BullTop - f15BullBot) >= FVG15_MIN_PTS)
bear15Ok = fvg15Bear and (FVG15_MIN_PTS <= 0 or (f15BearTop - f15BearBot) >= FVG15_MIN_PTS)

var array<box>   fvg15Boxes = array.new<box>()
var array<line>  fvg15CE    = array.new<line>()
var array<int>   fvg15Dir   = array.new<int>()
var array<float> fvg15Top   = array.new<float>()
var array<float> fvg15Bot   = array.new<float>()

fvg15NewBull = false
fvg15NewBear = false

if SHOW_FVG15 and newHtf15 and (bull15Ok or bear15Ok)
    isBull = bull15Ok
    fTop = isBull ? f15BullTop : f15BearTop
    fBot = isBull ? f15BullBot : f15BearBot
    col  = isBull ? COL_FVG15_BULL : COL_FVG15_BEAR
    bx = box.new(bar_index - 1, fTop, bar_index + 10, fBot, bgcolor=col, border_color=color.new(col, 30), border_width=1)
    line ceLine = na
    if FVG15_SHOW_CE
        ceP = (fTop + fBot) / 2
        ceLine := line.new(bar_index - 1, ceP, bar_index + 10, ceP, color=color.new(col, 0), width=1, style=line.style_dashed)
    array.push(fvg15Boxes, bx)
    array.push(fvg15CE, ceLine)
    array.push(fvg15Dir, isBull ? 1 : -1)
    array.push(fvg15Top, fTop)
    array.push(fvg15Bot, fBot)
    fvg15NewBull := isBull
    fvg15NewBear := not isBull
    if array.size(fvg15Boxes) > FVG15_MAX
        box.delete(array.shift(fvg15Boxes))
        line oldCe = array.shift(fvg15CE)
        if not na(oldCe)
            line.delete(oldCe)
        array.shift(fvg15Dir)
        array.shift(fvg15Top)
        array.shift(fvg15Bot)

// Maintain active FVGs: extend right + detect mitigation (full fill), iterate descending for safe removal
if SHOW_FVG15 and array.size(fvg15Boxes) > 0
    for i = array.size(fvg15Boxes) - 1 to 0
        bx = array.get(fvg15Boxes, i)
        d  = array.get(fvg15Dir, i)
        t  = array.get(fvg15Top, i)
        b  = array.get(fvg15Bot, i)
        ce = array.get(fvg15CE, i)
        mitigated = d == 1 ? low <= b : high >= t
        if not mitigated and FVG15_EXTEND
            box.set_right(bx, bar_index + 10)
            if not na(ce)
                line.set_x2(ce, bar_index + 10)
        if mitigated
            if FVG15_HIDE_MIT
                box.delete(bx)
                if not na(ce)
                    line.delete(ce)
            else
                box.set_right(bx, bar_index)
                box.set_bgcolor(bx, color.new(color.gray, 90))
                box.set_border_color(bx, color.new(color.gray, 65))
                if not na(ce)
                    line.set_x2(ce, bar_index)
                    line.set_color(ce, color.new(color.gray, 55))
            array.remove(fvg15Boxes, i)
            array.remove(fvg15CE, i)
            array.remove(fvg15Dir, i)
            array.remove(fvg15Top, i)
            array.remove(fvg15Bot, i)

if ALERT_FVG15 and fvg15NewBull
    alert(syminfo.ticker + " 15m Bull FVG " + str.tostring(f15BullBot, format.mintick) + "-" + str.tostring(f15BullTop, format.mintick), alert.freq_once_per_bar_close)
if ALERT_FVG15 and fvg15NewBear
    alert(syminfo.ticker + " 15m Bear FVG " + str.tostring(f15BearBot, format.mintick) + "-" + str.tostring(f15BearTop, format.mintick), alert.freq_once_per_bar_close)

plot(na, "_keepalive", display=display.none)
````
