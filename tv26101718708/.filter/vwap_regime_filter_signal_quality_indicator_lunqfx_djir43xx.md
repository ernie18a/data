# VWAP Regime Filter & Signal Quality Indicator [LunqFX]

- url: https://www.tradingview.com/script/djIr43Xx-VWAP-Regime-Filter-Signal-Quality-Indicator-LunqFX/
- type: indicator
- pine_id: PUB;fc8711c7abee4b9ea814c9521b02def6
- version: 1.0

## Description

VWAP Regime Filter & Signal Quality Indicator [LunqFX]

A complete trading framework built on volume-weighted flow analysis. 
Identifies market regimes, detects high-probability reversal entries, 
and rates each signal 1–5 stars so you know exactly how much conviction to trade with.

─────────────────────────────────────────
WHAT IT MEASURES
─────────────────────────────────────────
[image]https://www.tradingview.com/x/cxS0gCqV/[/image]

▸ VELOCITY — how fast the VWAP is moving, normalized by volatility.
  Values > +0.8 = rising momentum. Values < -0.8 = falling momentum.
  SURGE / RISING / UP / FLAT / DOWN / FALLING / CRASH shown in the panel.

▸ PRESSURE — how far price is stretched from VWAP, measured in standard 
  deviations (σ). Values near 0 = price at VWAP. Values > ±2σ = extreme 
  extension, strong mean-reversion candidate.

▸ TURBULENCE — the ratio of current velocity volatility to its 50-bar average.
  < 0.8 = calm, trending market (LAMINAR). > 1.3 = choppy, avoid entries.
  Only trade when turbulence is low.

▸ REGIME SCORE — 0–100% score summarizing overall flow quality.
  > 60% = clean conditions. < 30% = stay out.

─────────────────────────────────────────
5 MARKET PHASES
─────────────────────────────────────────

🟡 BREAKOUT     — price beyond ±2.8σ outer band. Manage open positions, 
                   do not chase. Mean reversion imminent.

🟢 EXPANSION    — velocity rising strongly. Trend is building. 
                   Do not fade the move.

🟠 CONTRACTION  — velocity falling. Energy compressing toward VWAP. 
                   Watch for fresh reversal entries.

🔵 LAMINAR FLOW — low turbulence, steady drift. Best window for entries. 
                   Signals here carry the highest quality.

🟣 CONSOLIDATION — mixed signals, no clear bias. Reduce size or wait.

─────────────────────────────────────────
HOW SIGNALS ARE GENERATED
─────────────────────────────────────────

LONG  — price crosses back above the inner lower band (−1.5σ)
        AND pressure is below −0.8σ (oversold stretch)
        AND market is in LAMINAR regime (turbulence < 0.8)

SHORT — price crosses back below the inner upper band (+1.5σ)
        AND pressure is above +0.8σ (overbought stretch)
        AND market is in LAMINAR regime

In plain terms: the indicator buys when price bounced from below the VWAP 
lower band in a calm, trending market. It shorts when price rejected from 
above the VWAP upper band in the same conditions.

A cooldown of 5 bars prevents signal clustering (adjustable).
Optional reversal candle filter (pin bar / engulfing) adds confirmation.

─────────────────────────────────────────
SIGNAL QUALITY SCORE — 1 to 5 STARS
─────────────────────────────────────────

Each signal is rated automatically. Use it to size positions:

★☆☆☆☆  1 — baseline signal, minimal confirmation
★★☆☆☆  2 — low conviction, reduce size
★★★☆☆  3 — decent setup, standard size
★★★★☆  4 — high quality, can add size
★★★★★  5 — all conditions aligned, maximum confidence

Points are awarded for:
  + Pressure beyond ±2σ (strong extension)
  + Very low turbulence (< 0.5)
  + Full 3/3 MTF alignment
  + Both extreme pressure AND very calm market simultaneously

─────────────────────────────────────────
MULTI-TIMEFRAME CONFLUENCE (MTF)
─────────────────────────────────────────

The indicator reads velocity on 3 timeframes simultaneously:
  • Current chart timeframe
  • TF 2 (default: 1H)
  • TF 3 (default: 4H)

Panel shows each TF with ▲ (bullish velocity) or ▼ (bearish velocity).

  FULL ALIGN  3/3 — all timeframes agree → highest conviction
  PARTIAL     2/3 — majority agreement → tradeable
  DIVERGED    1/3 or less → conflicting signals, skip the trade

─────────────────────────────────────────
HOW TO TRADE — STEP BY STEP
─────────────────────────────────────────

1. Check REGIME first.
   → If TURBULENT or Regime Score < 30% — do not enter. Wait.
   → If LAMINAR or Score > 60% — proceed.

2. Check MTF FLOW BIAS.
   → FULL ALIGN (3/3) = strong directional conviction.
   → PARTIAL (2/3) = ok to trade, smaller size.
   → DIVERGED = skip.

3. Wait for a signal label (▲ LONG or ▼ SHORT) on the chart.
   → More stars = higher conviction = larger position size.

4. Entry: at the signal candle close (or next open).

5. Stop loss: beyond the outer band (±2.8σ).
   → Long: stop below the outer lower band (−2.8σ).
   → Short: stop above the outer upper band (+2.8σ).

6. Take profit: use NEXT TARGET in the panel.
   → Shows the next VWAP band level and the % distance to it.
   → Long target: inner top band → outer top band.
   → Short target: inner bottom band → outer bottom band.

7. If phase switches to TURBULENT — tighten stop or exit.

─────────────────────────────────────────
PANEL GUIDE
─────────────────────────────────────────
[image]https://www.tradingview.com/x/NBGzAjwB/[/image]

  PHASE       — current market phase + pressure reading + regime score
  REGIME      — LAMINAR / MIXED / TURBULENT + progress bar
  VELOCITY    — trend word + normalized value
  PRESSURE    — distance from VWAP in σ + bar
  TURBULENCE  — market noise level + bar
  FLOW BIAS   — MTF alignment status
  [TF arrows] — per-timeframe direction (▲ bull, ▼ bear)
  SIGNAL      — last signal direction + bars ago
  QUALITY     — star rating of last signal
  NEXT TGT    — nearest VWAP band + % distance

─────────────────────────────────────────
ALERTS (11 total)
─────────────────────────────────────────

  • Long Signal
  • Short Signal
  • High Quality Long (4-5★)
  • High Quality Short (4-5★)
  • Regime: Laminar Flow (Trading Window Open)
  • Regime: Turbulent (Avoid Trading)
  • Phase: Breakout
  • Phase: Expansion
  • Phase: Contraction
  • Full MTF Alignment (3/3)
  • Pressure Extreme (>2σ)

Recommended setup: enable "Regime: Laminar Flow" and "High Quality Long/Short" 
alerts to get notified only when market conditions are optimal.

─────────────────────────────────────────
SETTINGS
─────────────────────────────────────────

  VWAP Window      — lookback for VWAP calculation (default 50)
  Inner Band σ     — inner band distance, signals trigger here (default 1.5)
  Outer Band σ     — outer band distance, stop loss reference (default 2.8)
  Show Signals     — toggle signal labels on/off
  Cooldown (bars)  — minimum bars between signals (default 5)
  Reversal Filter  — require pin bar or engulfing candle (default ON)
  Show Panel       — toggle info panel
  TF 2 / TF 3     — second and third timeframes for MTF confluence

─────────────────────────────────────────
CREDITS
─────────────────────────────────────────

Built on the same VWAP flow engine as Plasma Flow [LunqFX] by the same author.
This indicator extends that framework with a dedicated signal quality scoring 
system and enhanced multi-timeframe confluence layer.

© LunqFX

## Source Code

````pine
// © LunqFX
// VWAP Regime Filter & Signal Quality Indicator [LunqFX]
// Built on the same engine as Plasma Flow [LunqFX]
//@version=6
indicator("VWAP Regime Filter & Signal Quality Indicator [LunqFX]", shorttitle="PF·LFX", overlay=true,
          max_labels_count=400, max_lines_count=100)

// ══════════════════════════════════════════════════════════════════════════════
//  INPUTS
// ══════════════════════════════════════════════════════════════════════════════
grpC = "Core"
vwLen   = input.int(50,    "VWAP Window",          minval=10, maxval=500, group=grpC)
stdM1   = input.float(1.5, "Inner Band sigma",      minval=0.5, step=0.1,  group=grpC)
stdM2   = input.float(2.8, "Outer Band sigma",      minval=1.0, step=0.1,  group=grpC)

grpS = "Signals"
showSig = input.bool(true, "Show Signals",          group=grpS)
sigCool = input.int(5,     "Cooldown (bars)",        group=grpS)
useFltr = input.bool(true, "Reversal Candle Filter", group=grpS)
showPnl = input.bool(true, "Show Panel",             group=grpS)

grpT = "Multi-Timeframe"
tf2 = input.timeframe("60",  "TF 2", group=grpT)
tf3 = input.timeframe("240", "TF 3", group=grpT)

// ══════════════════════════════════════════════════════════════════════════════
//  CHART PALETTE
// ══════════════════════════════════════════════════════════════════════════════
C_CYAN   = #00D4FF
C_MINT   = #00FFA3
C_VIOLET = #7B2FFF
C_ORANGE = #FF6B35
C_RED    = #FF2055
C_BLUE   = #0088FF
C_GOLD   = #FFD700
C_DIM    = #556677
C_PANEL  = #060810

// ══════════════════════════════════════════════════════════════════════════════
//  CORE MATH
// ══════════════════════════════════════════════════════════════════════════════
src = hlc3

vwNum = math.sum(src * volume, vwLen)
vwDen = math.sum(volume, vwLen)
vwap  = vwDen > 0.0 ? vwNum / vwDen : src

vwStd = math.sqrt(math.sum(volume * math.pow(src - vwap, 2), vwLen) /
                  math.max(vwDen, 1.0))

b1T = vwap + vwStd * stdM1
b1B = vwap - vwStd * stdM1
b2T = vwap + vwStd * stdM2
b2B = vwap - vwStd * stdM2

velRaw   = ta.roc(vwap, 3)
vel      = ta.ema(velRaw / math.max(vwStd, syminfo.mintick), 8)

turbRaw  = ta.stdev(vel, 20)
turbAvg  = ta.sma(turbRaw, 50)
turbIdx  = turbAvg > 0.0 ? turbRaw / turbAvg : 1.0

press    = vwStd > 0.0 ? (src - vwap) / vwStd : 0.0
pressEma = ta.ema(press, 5)

regScore = math.max(0.0, math.min(100.0, (1.5 - turbIdx) / 1.5 * 100.0))

isLaminar   = turbIdx < 0.8
isTurbulent = turbIdx > 1.3
isBreakout  = math.abs(pressEma) > 2.0
isExpand    = vel > 0.3
isContract  = vel < -0.3

phase    = isBreakout ? "BREAKOUT"     :
           isExpand   ? "EXPANSION"    :
           isContract ? "CONTRACTION"  :
           isLaminar  ? "LAMINAR FLOW" : "CONSOLIDATION"

phaseCol = isBreakout ? C_GOLD   :
           isExpand   ? C_MINT   :
           isContract ? C_ORANGE :
           isLaminar  ? C_CYAN   : C_VIOLET

// ══════════════════════════════════════════════════════════════════════════════
//  MULTI-TIMEFRAME CONFLUENCE
// ══════════════════════════════════════════════════════════════════════════════
f_tfVel(tf) =>
    _vw  = math.sum(hlc3 * volume, 50) / math.max(math.sum(volume, 50), 1.0)
    _std = math.max(math.sqrt(math.sum(volume * math.pow(hlc3 - _vw, 2), 50) /
                              math.max(math.sum(volume, 50), 1.0)), syminfo.mintick)
    _vel = ta.ema(ta.roc(_vw, 3) / _std, 8)
    request.security(syminfo.tickerid, tf, _vel, lookahead=barmerge.lookahead_off)

vel2 = f_tfVel(tf2)
vel3 = f_tfVel(tf3)

bull1 = vel  > 0.15
bull2 = vel2 > 0.10
bull3 = vel3 > 0.05

alignCount = (bull1 ? 1 : 0) + (bull2 ? 1 : 0) + (bull3 ? 1 : 0)
bearCount  = ((not bull1) ? 1 : 0) + ((not bull2) ? 1 : 0) + ((not bull3) ? 1 : 0)
isBullBias = alignCount >= bearCount
bestAlign  = math.max(alignCount, bearCount)

// ══════════════════════════════════════════════════════════════════════════════
//  SIGNALS
// ══════════════════════════════════════════════════════════════════════════════
atr14    = ta.atr(14)
entLong  = ta.crossover(src,  b1B) and pressEma < -0.8 and isLaminar
entShort = ta.crossunder(src, b1T) and pressEma >  0.8 and isLaminar

rng   = high - low
body  = math.abs(close - open)
bWick = math.min(close, open) - low
tWick = high - math.max(close, open)
pinB  = bWick > body * 2.0 and bWick > rng * 0.5
pinBr = tWick > body * 2.0 and tWick > rng * 0.5
engB  = close > open and close[1] < open[1] and close > open[1] and open <= close[1]
engBr = close < open and close[1] > open[1] and close < open[1] and open >= close[1]
patB  = pinB  or engB  or pinB[1]  or engB[1]
patBr = pinBr or engBr or pinBr[1] or engBr[1]

var int  lastSigIdx = na
sigRdy  = na(lastSigIdx) or bar_index - lastSigIdx >= sigCool
goLong  = showSig and entLong  and sigRdy and (not useFltr or patB)
goShort = showSig and entShort and sigRdy and (not useFltr or patBr)

if goLong or goShort
    lastSigIdx := bar_index

var bool lastWasLong = false
if goLong
    lastWasLong := true
if goShort
    lastWasLong := false

// ── Quality score
var int q = 1
q := 1
if math.abs(pressEma) > 2.0
    q := q + 1
if turbIdx < 0.5
    q := q + 1
if bestAlign == 3
    q := q + 1
if turbIdx < 0.4 and math.abs(pressEma) > 1.8
    q := q + 1
q := math.min(5, q)

var int lastQual = 1
if goLong or goShort
    lastQual := q

// ══════════════════════════════════════════════════════════════════════════════
//  HELPERS
// ══════════════════════════════════════════════════════════════════════════════
f_sigma(v) =>
    s = str.tostring(math.abs(v), "#.##") + "σ"
    v >= 0.0 ? "+" + s : "-" + s

f_ago(idx) =>
    d = bar_index - idx
    d == 0 ? "now" : str.tostring(d) + "b ago"

f_velWord(v) =>
    v > 2.0 ? "SURGE" : v > 0.8 ? "RISING" : v > 0.2 ? "UP" : v > -0.2 ? "FLAT" : v > -0.8 ? "DOWN" : v > -2.0 ? "FALLING" : "CRASH"

f_bar(pct, w) =>
    n = math.round(math.max(0.0, math.min(100.0, pct)) / 100.0 * w)
    str.repeat("▰", n) + str.repeat("▱", w - n)

f_dot(isBull) =>
    isBull ? "●" : "○"

// ══════════════════════════════════════════════════════════════════════════════
//  CHART VISUALS
// ══════════════════════════════════════════════════════════════════════════════
vwapCol = color.from_gradient(math.max(-3.0, math.min(3.0, vel * 5.0)) * 100.0 / 3.0 + 100.0,
                               0, 200, C_ORANGE, C_MINT)

pClamp  = math.max(-1.0, math.min(1.0, pressEma))
fillTop = color.from_gradient(pClamp * 100.0 + 100.0, 0, 200,
                               color.new(C_MINT, 88), color.new(C_ORANGE, 80))
fillBot = color.from_gradient(pClamp * 100.0 + 100.0, 0, 200,
                               color.new(C_BLUE, 80), color.new(C_RED, 88))

pB2T = plot(b2T,  "Outer Top", color=color.new(C_RED,    65), linewidth=1)
pB1T = plot(b1T,  "Band Top",  color=color.new(C_ORANGE, 15), linewidth=2)
pVWP = plot(vwap, "VWAP",      color=vwapCol,                 linewidth=2)
pB1B = plot(b1B,  "Band Bot",  color=color.new(C_BLUE,   15), linewidth=2)
pB2B = plot(b2B,  "Outer Bot", color=color.new(C_VIOLET, 65), linewidth=1)

fill(pB2T, pB1T, color=color.new(C_RED,    95))
fill(pB1T, pVWP, fillTop)
fill(pVWP, pB1B, fillBot)
fill(pB1B, pB2B, color=color.new(C_VIOLET, 95))

barcolor(color.from_gradient(pClamp * 100.0 + 100.0, 0, 200,
                              color.new(C_BLUE, 25), color.new(C_ORANGE, 25)))

// ── Signal labels
// Prevent label overlap: track bar_index and price of the last label
// and shift the new one down if it is too close
var int   lastLongBar   = na
var float lastLongPrice = na
var int   lastShortBar  = na
var float lastShortPrice = na

if goLong
    _baseY = b1B - atr14 * 1.2
    // If the previous LONG label is close in bars — shift this one lower
    _offsetMult = (not na(lastLongBar) and bar_index - lastLongBar < 15) ? 2.5 : 1.2
    _y = b1B - atr14 * _offsetMult
    _lTxt = "▲  LONG\n" + str.repeat("★", q) + "   " + f_sigma(pressEma)
    label.new(bar_index, _y,
              _lTxt,
              color     = color.new(#00E676, 0),
              textcolor = color.new(#021A0D, 0),
              style     = label.style_label_up,
              size      = size.normal)
    lastLongBar   := bar_index
    lastLongPrice := _y

if goShort
    _offsetMult = (not na(lastShortBar) and bar_index - lastShortBar < 15) ? 2.5 : 1.2
    _y = b1T + atr14 * _offsetMult
    _sTxt = "▼  SHORT\n" + str.repeat("★", q) + "   " + f_sigma(pressEma)
    label.new(bar_index, _y,
              _sTxt,
              color     = color.new(#FF4444, 0),
              textcolor = color.new(#1A0202, 0),
              style     = label.style_label_down,
              size      = size.normal)
    lastShortBar   := bar_index
    lastShortPrice := _y

// ══════════════════════════════════════════════════════════════════════════════
//  PANEL COLORS
// ══════════════════════════════════════════════════════════════════════════════

// Backgrounds
_bg0  = color.new(#0D1117, 0)
_bg1  = color.new(#111820, 0)
_bg2  = color.new(#151F2E, 0)
_sepC = color.new(#1E2D42, 0)
_phBg = color.new(phaseCol, 50)

// Text hierarchy
_C_LBL = color.new(#6B8CAE, 0)
_C_VAL = color.new(#D8E4F0, 0)
_C_HDR = color.new(#E8F4FF, 0)
_C_BRN = color.new(#4A6FA8, 0)

// Semantic accents
_C_BULL = color.new(#26D07C, 0)
_C_BEAR = color.new(#F05050, 0)
_C_NEUT = color.new(#4A6080, 0)
_C_GOLD = color.new(#E8B84B, 0)
_C_INFO = color.new(#5BA3D9, 0)

// Regime
_rCol  = regScore > 60 ? _C_BULL : regScore > 30 ? _C_GOLD : _C_BEAR
_rName = isLaminar ? "LAMINAR" : isTurbulent ? "TURBULENT" : "MIXED"

// Velocity
_vWord = f_velWord(vel * 3.0)
_vVal  = str.tostring(vel * 100.0, "#.0")
_vCol  = vel > 0.2 ? _C_BULL : vel < -0.2 ? _C_BEAR : _C_NEUT

// Pressure
_pAbs = math.abs(pressEma)
_pCol = _pAbs > 2.0 ? _C_BEAR : _pAbs > 1.0 ? _C_GOLD : _C_INFO
_pLbl = _pAbs > 2.0 ? "EXTREME" : _pAbs > 1.5 ? "HIGH" : _pAbs > 0.8 ? "MED" : "LOW"
_pPct = math.min(100.0, _pAbs / stdM2 * 100.0)

// Turbulence
_tCol = turbIdx < 0.8 ? _C_BULL : turbIdx > 1.3 ? _C_BEAR : _C_GOLD
_tLbl = turbIdx < 0.8 ? "CALM" : turbIdx > 1.3 ? "CHAOTIC" : "MIXED"
_tVal = str.tostring(turbIdx, "#.##")
_tPct = math.min(100.0, turbIdx / 2.0 * 100.0)

// Flow bias
_aLbl = bestAlign == 3 ? "FULL ALIGN" : bestAlign == 2 ? "PARTIAL" : "DIVERGED"
_aCol = bestAlign == 3 ? _C_GOLD : bestAlign == 2 ? _C_INFO : _C_NEUT
_tf1C = bull1 ? _C_BULL : _C_BEAR
_tf2C = bull2 ? _C_BULL : _C_BEAR
_tf3C = bull3 ? _C_BULL : _C_BEAR
_tf1T = "  " + timeframe.period + (bull1 ? "  ▲" : "  ▼")
_tf2T = tf2 + (bull2 ? "  ▲" : "  ▼")
_tf3T = tf3 + (bull3 ? "  ▲" : "  ▼") + "  "

// Signal
_sLbl = na(lastSigIdx) ? "-" : (lastWasLong ? "▲  BUY" : "▼  SELL")
_sCol = na(lastSigIdx) ? _C_NEUT : lastWasLong ? _C_BULL : _C_BEAR
_agoS = na(lastSigIdx) ? "-" : f_ago(lastSigIdx)

// Quality
_qScore = na(lastSigIdx) ? "-" : str.tostring(lastQual) + " / 5"
_qDesc  = lastQual >= 5 ? "PERFECT" : lastQual >= 4 ? "STRONG" : lastQual >= 3 ? "GOOD" : lastQual >= 2 ? "WEAK" : "POOR"
_qCol   = lastQual >= 4 ? _C_GOLD : lastQual >= 3 ? _C_INFO : _C_NEUT

// Next target
_ntLvl  = pressEma >= 0.0 ? (src < b1T ? b1T : b2T) : (src > b1B ? b1B : b2B)
_ntDist = math.abs(_ntLvl - src) / src * 100.0
_ntStr  = str.tostring(_ntDist, "#.##") + "%  "
_ntPrc  = str.tostring(_ntLvl, format.mintick)
_ntCol  = pressEma >= 0.0 ? _C_BULL : _C_BEAR

// ══════════════════════════════════════════════════════════════════════════════
//  INFO PANEL
// ══════════════════════════════════════════════════════════════════════════════
if barstate.islast and showPnl
    var table T = table.new(position.bottom_right, 3, 18,
                             bgcolor      = color.new(#0D1117, 0),
                             frame_color  = color.new(#1E2D42, 40),
                             frame_width  = 1,
                             border_color = color.new(#1A2535, 0),
                             border_width = 0)

    // ROW 0 - Header
    table.cell(T, 0, 0, "▸ PLASMA FLOW",
               text_color=_C_HDR, bgcolor=_bg0,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 0, "", bgcolor=_bg0, text_size=size.tiny)
    table.cell(T, 2, 0, "LunqFX  ",
               text_color=_C_BRN, bgcolor=_bg0,
               text_size=size.normal, text_halign=text.align_right)

    // ROW 1 - Phase
    table.cell(T, 0, 1, "▸▸ " + phase,
               text_color=color.new(#FFFFFF, 0), bgcolor=_phBg,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 1, f_sigma(pressEma),
               text_color=color.new(#FFFFFF, 20), bgcolor=_phBg,
               text_size=size.normal, text_halign=text.align_center)
    table.cell(T, 2, 1, str.tostring(math.round(regScore)) + "%  ",
               text_color=color.new(#FFFFFF, 20), bgcolor=_phBg,
               text_size=size.normal, text_halign=text.align_right)

    // ROW 2 - Separator
    table.cell(T, 0, 2, "", bgcolor=_sepC, text_size=size.tiny)
    table.cell(T, 1, 2, "", bgcolor=_sepC, text_size=size.tiny)
    table.cell(T, 2, 2, "", bgcolor=_sepC, text_size=size.tiny)

    // ROW 3 - Regime
    table.cell(T, 0, 3, "  REGIME",
               text_color=_C_LBL, bgcolor=_bg1,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 3, f_bar(regScore, 8) + " " + _rName,
               text_color=_rCol, bgcolor=_bg1,
               text_size=size.normal, text_halign=text.align_center)
    table.cell(T, 2, 3, str.tostring(math.round(regScore)) + "%  ",
               text_color=_rCol, bgcolor=_bg1,
               text_size=size.normal, text_halign=text.align_right)

    // ROW 4 - Separator
    table.cell(T, 0, 4, "", bgcolor=_sepC, text_size=size.tiny)
    table.cell(T, 1, 4, "", bgcolor=_sepC, text_size=size.tiny)
    table.cell(T, 2, 4, "", bgcolor=_sepC, text_size=size.tiny)

    // ROW 5 - Separator
    table.cell(T, 0, 5, "", bgcolor=_sepC, text_size=size.tiny)
    table.cell(T, 1, 5, "", bgcolor=_sepC, text_size=size.tiny)
    table.cell(T, 2, 5, "", bgcolor=_sepC, text_size=size.tiny)

    // ROW 6 - Velocity
    table.cell(T, 0, 6, "  VELOCITY",
               text_color=_C_LBL, bgcolor=_bg2,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 6, _vWord,
               text_color=_vCol, bgcolor=_bg2,
               text_size=size.normal, text_halign=text.align_center)
    table.cell(T, 2, 6, _vVal + "  ",
               text_color=_C_VAL, bgcolor=_bg2,
               text_size=size.normal, text_halign=text.align_right)

    // ROW 7 - Pressure
    table.cell(T, 0, 7, "  PRESSURE",
               text_color=_C_LBL, bgcolor=_bg1,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 7, f_bar(_pPct, 8) + " " + _pLbl,
               text_color=_pCol, bgcolor=_bg1,
               text_size=size.normal, text_halign=text.align_center)
    table.cell(T, 2, 7, f_sigma(pressEma) + "  ",
               text_color=_pCol, bgcolor=_bg1,
               text_size=size.normal, text_halign=text.align_right)

    // ROW 8 - Turbulence
    table.cell(T, 0, 8, "  TURBULENCE",
               text_color=_C_LBL, bgcolor=_bg2,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 8, f_bar(_tPct, 8) + " " + _tLbl,
               text_color=_tCol, bgcolor=_bg2,
               text_size=size.normal, text_halign=text.align_center)
    table.cell(T, 2, 8, _tVal + "  ",
               text_color=_C_VAL, bgcolor=_bg2,
               text_size=size.normal, text_halign=text.align_right)

    // ROW 9 - Separator
    table.cell(T, 0, 9, "", bgcolor=_sepC, text_size=size.tiny)
    table.cell(T, 1, 9, "", bgcolor=_sepC, text_size=size.tiny)
    table.cell(T, 2, 9, "", bgcolor=_sepC, text_size=size.tiny)

    // ROW 10 - Flow Bias
    table.cell(T, 0, 10, "  FLOW BIAS",
               text_color=_C_LBL, bgcolor=_bg1,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 10, f_bar(bestAlign / 3.0 * 100.0, 8),
               text_color=_aCol, bgcolor=_bg1,
               text_size=size.normal, text_halign=text.align_center)
    table.cell(T, 2, 10, _aLbl + "  ",
               text_color=_aCol, bgcolor=_bg1,
               text_size=size.normal, text_halign=text.align_right)

    // ROW 11 - TF dots
    table.cell(T, 0, 11, _tf1T,
               text_color=_tf1C, bgcolor=_bg2,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 11, _tf2T,
               text_color=_tf2C, bgcolor=_bg2,
               text_size=size.normal, text_halign=text.align_center)
    table.cell(T, 2, 11, _tf3T,
               text_color=_tf3C, bgcolor=_bg2,
               text_size=size.normal, text_halign=text.align_right)

    // ROW 12 - Alignment bar
    table.cell(T, 0, 12, "", bgcolor=_bg2, text_size=size.tiny)
    table.cell(T, 1, 12, f_bar(bestAlign / 3.0 * 100.0, 12),
               text_color=_aCol, bgcolor=_bg2,
               text_size=size.normal, text_halign=text.align_center)
    table.cell(T, 2, 12, str.tostring(bestAlign) + "/3  ",
               text_color=_aCol, bgcolor=_bg2,
               text_size=size.normal, text_halign=text.align_right)

    // ROW 13 - Separator
    table.cell(T, 0, 13, "", bgcolor=_sepC, text_size=size.tiny)
    table.cell(T, 1, 13, "", bgcolor=_sepC, text_size=size.tiny)
    table.cell(T, 2, 13, "", bgcolor=_sepC, text_size=size.tiny)

    // ROW 14 - Signal
    table.cell(T, 0, 14, "  SIGNAL",
               text_color=_C_LBL, bgcolor=_bg1,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 14, _sLbl,
               text_color=_sCol, bgcolor=_bg1,
               text_size=size.normal, text_halign=text.align_center)
    table.cell(T, 2, 14, _agoS + "  ",
               text_color=_C_VAL, bgcolor=_bg1,
               text_size=size.normal, text_halign=text.align_right)

    // ROW 15 - Quality
    table.cell(T, 0, 15, "  QUALITY",
               text_color=_C_LBL, bgcolor=_bg2,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 15, _qScore,
               text_color=_qCol, bgcolor=_bg2,
               text_size=size.normal, text_halign=text.align_center)
    table.cell(T, 2, 15, _qDesc + "  ",
               text_color=_qCol, bgcolor=_bg2,
               text_size=size.normal, text_halign=text.align_right)

    // ROW 16 - Separator
    table.cell(T, 0, 16, "", bgcolor=_sepC, text_size=size.tiny)
    table.cell(T, 1, 16, "", bgcolor=_sepC, text_size=size.tiny)
    table.cell(T, 2, 16, "", bgcolor=_sepC, text_size=size.tiny)

    // ROW 17 - Next Target
    table.cell(T, 0, 17, "  NEXT TGT",
               text_color=_C_LBL, bgcolor=_bg1,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 17, _ntPrc,
               text_color=_ntCol, bgcolor=_bg1,
               text_size=size.normal, text_halign=text.align_center)
    table.cell(T, 2, 17, _ntStr,
               text_color=_C_VAL, bgcolor=_bg1,
               text_size=size.normal, text_halign=text.align_right)

// ══════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ══════════════════════════════════════════════════════════════════════════════

// ── Entry signals ─────────────────────────────────────────────────────────────
alertcondition(goLong,
     title   = "Long Signal",
     message = "VWAP Regime Filter [LunqFX]: LONG signal — price crossed inner band with pressure confirmation. Check quality score.")

alertcondition(goShort,
     title   = "Short Signal",
     message = "VWAP Regime Filter [LunqFX]: SHORT signal — price crossed inner band with pressure confirmation. Check quality score.")

// ── High quality only (4–5★) ──────────────────────────────────────────────────
alertcondition(goLong  and q >= 4,
     title   = "High Quality Long (4-5★)",
     message = "VWAP Regime Filter [LunqFX]: HIGH QUALITY LONG (4-5★) — laminar regime, strong pressure, full MTF alignment. Higher conviction setup.")

alertcondition(goShort and q >= 4,
     title   = "High Quality Short (4-5★)",
     message = "VWAP Regime Filter [LunqFX]: HIGH QUALITY SHORT (4-5★) — laminar regime, strong pressure, full MTF alignment. Higher conviction setup.")

// ── Regime change ─────────────────────────────────────────────────────────────
alertcondition(isLaminar and not isLaminar[1],
     title   = "Regime: Laminar Flow (Trading Window Open)",
     message = "VWAP Regime Filter [LunqFX]: Market entered LAMINAR FLOW — clean trending conditions. Trading window is now open.")

alertcondition(isTurbulent and not isTurbulent[1],
     title   = "Regime: Turbulent (Avoid Trading)",
     message = "VWAP Regime Filter [LunqFX]: Market turned TURBULENT — chaotic conditions. No new entries, tighten stops.")

// ── Phase change ──────────────────────────────────────────────────────────────
alertcondition(isBreakout and not isBreakout[1],
     title   = "Phase: Breakout",
     message = "VWAP Regime Filter [LunqFX]: BREAKOUT phase — price stretched beyond 2σ. High volatility, manage open positions.")

alertcondition(isExpand and not isExpand[1],
     title   = "Phase: Expansion",
     message = "VWAP Regime Filter [LunqFX]: EXPANSION phase — momentum building. Do not fade the move.")

alertcondition(isContract and not isContract[1],
     title   = "Phase: Contraction",
     message = "VWAP Regime Filter [LunqFX]: CONTRACTION phase — energy compressing toward VWAP. Watch for mean-reversion entries.")

// ── MTF alignment ─────────────────────────────────────────────────────────────
alertcondition(bestAlign == 3 and bestAlign[1] < 3,
     title   = "Full MTF Alignment (3/3)",
     message = "VWAP Regime Filter [LunqFX]: FULL ALIGNMENT 3/3 — all timeframes agree on direction. Highest conviction window.")

// ── Pressure extremes ─────────────────────────────────────────────────────────
alertcondition(math.abs(pressEma) > 2.0 and math.abs(pressEma[1]) <= 2.0,
     title   = "Pressure Extreme (>2σ)",
     message = "VWAP Regime Filter [LunqFX]: EXTREME PRESSURE — price stretched beyond 2σ from VWAP. Strong mean-reversion candidate.")
````
