# Oracle Flux

- url: https://www.tradingview.com/script/mQP80cUC-Oracle-Flux/
- type: indicator
- pine_id: PUB;e6ecfd8dab2945ababe756ff9c5ce4c0
- version: 4.0

## Description

Oracle Flux is a premium multi-factor confluence indicator designed for crypto leverage traders.

It combines:
• Flux Wave Oscillator (enhanced momentum with pinch/rollover detection)
• Multiple Anchored VWAPs (Daily, Previous Day, Weekly)
• Dynamic Fibonacci Retracements from recent swings
• Heikin Ashi trend filtering
• High-conviction signal engine with Oracle Scoring

Key Features:
- Clear STRONG BUY / STRONG SELL signals based on multi-timeframe confluence
- Visual Flux Wave oscillator with exhaustion dots
- Automatic recent swing Fibs (0.5, 0.618, 0.65, 0.786)
- Premium dark neon design optimized for 1H and higher timeframes
- Manual "Add Flux Tools" support in On-Chain Oracle AI app

Best used as a confirmation tool alongside price action and volume analysis.

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════════
//  ORACLE FLUX  —  Premium multi-engine confluence overlay
//  Flux Wave · Anchored VWAP · Oracle Analysis · HA · WHERE / permission layer
//  Pair with Oracle Flux — Oscillator (WHEN · ◆ diamonds). Original Flux stack.
// ════════════════════════════════════════════════════════════════════════════
indicator("Oracle Flux", shorttitle="ORACLEFLUX", overlay=true, max_lines_count=500, max_labels_count=500, max_bars_back=5000)

// ─────────────────────────────────────────────────────────────────────────────
//  THEME / PALETTE  —  OCO "On-Chain Oracle AI" dark neon (cyber premium)
//  Deep navy-black canvas · neon cyan · electric blue · subtle purple accents.
// ─────────────────────────────────────────────────────────────────────────────
var color C_PANEL    = color.new(#0A0F1A, 6)   // deep navy-black panel
var color C_PANEL2   = color.new(#10182A, 6)   // alternating row tint
var color C_TEXT     = color.new(#DCE7F5, 0)   // cool white
var color C_SUBTLE   = color.new(#5B6B85, 0)   // muted slate-blue
var color C_BULL     = color.new(#00FF9C, 0)   // neon green
var color C_BEAR     = color.new(#FF5C7A, 0)   // neon rose
var color C_BULL_DIM = color.new(#00FF9C, 60)
var color C_BEAR_DIM = color.new(#FF5C7A, 60)
var color C_ACCENT   = color.new(#00D4A8, 0)   // mint accent
var color C_PURPLE   = color.new(#A06BFF, 0)   // subtle purple accent
var color C_GOLD     = color.new(#FFB800, 0)   // amber gold (FV / VWAP family)
var color C_NEUTRAL  = color.new(#566379, 0)
var color C_GRID     = color.new(#1C2940, 0)   // subtle borders
var color C_CHOP_SLATE  = color.new(#121620, 0)   // dark gray chop base
var color C_CHOP_MIST   = color.new(#161922, 0)   // mid purple-gray gradient
var color C_CHOP_PURPLE = color.new(#1A1528, 0)   // dark purple wash
var color C_CHOP_GLOW   = color.new(#A06BFF, 0)   // purple neon accent
var color C_FIB_786     = color.new(#00FF9C, 0)   // neon green — deepest retracement
var color C_FIB_65      = color.new(#FFB800, 0)   // amber gold — key level
var color C_FIB_GRN     = color.new(#00D4A8, 0)   // mint — 0.5 & 0.618

// ═════════════════════════════════ INPUTS ═══════════════════════════════════

// ── Dashboard group ──────────────────────────────────────────────────────────
gDASH         = "① Dashboard"
dashEnable    = input.bool(true,  "Show dashboard",                   group=gDASH)
dashPos       = input.string("Top Right", "Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=gDASH)
dashSize      = input.string("Normal", "Text size", options=["Tiny","Small","Normal","Large"], group=gDASH)

// ── Scalp Mode ───────────────────────────────────────────────────────────────
scalpMode     = false

// ── 1H Sniper Profile ────────────────────────────────────────────────────────
gPROF         = "② 1H Sniper Profile"
use1HProfile  = input.bool(true, "Auto-optimize for chart timeframe", group=gPROF, tooltip="Balanced 1H sweet spot — selective STRONG signals with quality Normal tier when enabled.")

// ── Oscillator group ─────────────────────────────────────────────────────────
gOSC          = "③ Flux Wave Oscillator"
oscEnable     = input.bool(true,  "Enable Flux Wave engine",          group=gOSC)
fwChanLen     = input.int(9,      "Channel Length",         minval=2, group=gOSC)
fwAvgLen      = input.int(12,     "Average Length",         minval=2, group=gOSC)
fwSigLen      = input.int(3,      "Signal Smoothing",       minval=1, group=gOSC)
fwSrc         = input.source(hlc3,"Source",                           group=gOSC)
fwOB          = input.int(60,     "Overbought Level",                 group=gOSC)
fwOS          = input.int(-60,    "Oversold Level",                   group=gOSC)
fwOB2         = input.int(80,     "Extreme Overbought",               group=gOSC)
fwOS2         = input.int(-80,    "Extreme Oversold",                 group=gOSC)
// Composite weights — blend three momentum engines into one Flux Wave
oFwMom        = input.float(1.0,  "Weight · Flux Wave momentum", minval=0, step=0.1, group=gOSC, tooltip="Price vs adaptive EMA channel momentum.")
oFwVwap       = input.float(0.8,  "Weight · VWAP momentum",      minval=0, step=0.1, group=gOSC, tooltip="Price displacement from a rolling volume-weighted mean.")
oFwMf         = input.float(0.6,  "Weight · Money-Flow momentum",minval=0, step=0.1, group=gOSC, tooltip="Volume-weighted candle pressure (improved money flow).")
showFwGlow    = input.bool(false, "Show Flux Wave as overlay-scaled glow", group=gOSC, tooltip="Subtle on-chart hint of momentum. The full oscillator is best viewed via the dashboard / signals on an overlay indicator.")

// ── Heikin Ashi (OCO-style trend read) ───────────────────────────────────────
haOn          = true
haMinRun      = 3
haMinBody     = 0.45
haWickMax     = 0.15
haReqStrong   = false

// ── Divergence group ─────────────────────────────────────────────────────────
divEnable     = true
divPivLeft    = 5
divPivRight   = 5
divLookback   = 60
divShowLabels = false
divOnlyMajor  = true
divHidden     = true

// ── VWAP group ───────────────────────────────────────────────────────────────
gVWAP         = "④ Anchored VWAPs"
vwapEnable    = input.bool(true,  "Enable anchored VWAPs",            group=gVWAP)
vwapSrc       = input.source(hlc3,"VWAP Source",                      group=gVWAP)
vwapShowLabels= input.bool(false, "Show labels  name (±%)",           group=gVWAP, tooltip="OFF by default for a cleaner premium chart.")
vwapLineWidth = input.int(1,      "Line width", minval=1, maxval=3,   group=gVWAP)
vwapTouchPct  = input.float(0.15, "Bounce tolerance (%)", step=0.01, minval=0, group=gVWAP, tooltip="How close price must be to the nearest VWAP to count as a bounce/test.")
// per-level toggles (each is a true anchored VWAP from its own anchor bar)
vShowDaily    = input.bool(true,  "Daily VWAP (session open)",  group=gVWAP)
vShowPDaily   = input.bool(true,  "Prev Day VWAP",              group=gVWAP)
vShowWtd      = input.bool(true,  "Week-to-Date VWAP",          group=gVWAP)
vShowPWtd     = input.bool(true,  "Prev Week VWAP",             group=gVWAP)
vShow5SMA     = input.bool(true,  "5-Day VWAP",                 group=gVWAP, tooltip="VWAP anchored at the session open 5 days ago.")

// ── Signals group ────────────────────────────────────────────────────────────
gSIG          = "⑤ Oracle Analysis (Signals)"
sigEnable     = input.bool(true,  "Enable Buy/Sell signals",          group=gSIG)
sigStructLen  = input.int(12,     "Market Structure pivot len", minval=2, group=gSIG)
sigEMAlen     = input.int(50,     "Trend Filter EMA",       minval=1, group=gSIG)
sigUseTrend   = input.bool(true,  "Require trend filter alignment",   group=gSIG)
sigUseVWAP    = input.bool(true,  "Require VWAP confluence",          group=gSIG)
sigOracleStrong= input.int(78,     "STRONG: min Oracle score (/100)", minval=50, maxval=95, group=gSIG, tooltip="Default 78 — 1H profile uses 80. God-tier selectivity.")
sigOracleNormal= input.int(55,     "Normal: min Oracle score (/100)", minval=40, maxval=80, group=gSIG, tooltip="1H profile uses 56.")
sigPillarMin  = input.int(10,     "Min score per pillar (/25)", minval=5, maxval=22, group=gSIG, tooltip="1H profile uses 10 with Osc+HA mandatory.")
sigStrongMF   = input.bool(true,  "STRONG: require money-flow agree", group=gSIG)
sigStrongOsc  = input.bool(true,  "STRONG: require Flux Wave agreement", group=gSIG)
sigReqDailyVWAP= input.bool(true,  "STRONG: require Daily VWAP align", group=gSIG, tooltip="STRONG longs need price above Daily VWAP (shorts below).")
sigCooldown   = input.int(24,     "Min bars between signals", minval=0, group=gSIG, tooltip="Default 24 bars — 1H profile uses 24.")
showNormal    = input.bool(false, "Show Normal signals",              group=gSIG, tooltip="OFF by default — STRONG signals only on chart.")
showStrong    = input.bool(true,  "Show Strong signals",              group=gSIG, tooltip="Permission stamps on price — pair with oscillator ◆ for WHEN.")
sigFibRev     = input.bool(true,  "Fib+Wave+MF reversal STRONG",      group=gSIG, tooltip="STRONG when 0.618/0.786 Fib rejection + 2+ wave rollover + fresh MF shift align.")
sigSwingRev   = input.bool(true,  "Swing TOP/BOTTOM reversal STRONG", group=gSIG, tooltip="FLUX BUY at a major swing low (FLUX SELL at a high) when divergence or OS++/OB++ exhaustion arms and the wave turns with a structure break. Skips the VWAP/trend pillars that cannot pass at a reversal.")
sigSwingLen   = input.int(48,     "Swing: major lookback (bars)", minval=10, maxval=300, group=gSIG, tooltip="Armed low/high must be the extreme of this many bars. 48 on 1H = 2 days.")
sigSwingConf  = input.int(3,      "Swing: confirm window (bars)", minval=1, maxval=30, group=gSIG)
sigSwingBreak = input.int(4,      "Swing: structure break bars", minval=1, maxval=10, group=gSIG, tooltip="BUY needs a close above the highest close (or high) of this many prior bars (SELL mirrors).")
sigSwingBrkClose = input.bool(true, "Swing: break vs prior closes", group=gSIG, tooltip="ON: break = close beyond the prior closes (robust to wick / feed differences). OFF: break = close beyond the prior highs / lows.")
sigSwingLock  = input.float(4.0,  "Swing: re-arm after move (ATR)", minval=0.5, step=0.5, group=gSIG, tooltip="After a swing BUY, a higher low can only re-arm once price has rallied this many ATR (SELL mirrors). A new lower low always can.")
sigSwingLegLen = input.int(60,    "Swing: divergence leg lookback (bars)", minval=10, maxval=400, group=gSIG, tooltip="The deepest wave trough (peak) is searched over this many bars — longer than the major lookback so a double bottom (top) still sees the first, deeper wave extreme.")
sigSwingDivGap = input.float(5.0, "Swing: leg divergence min gap", minval=1, step=1, group=gSIG, tooltip="The recent wave trough must sit at least this far above the leg's deepest trough (peaks mirror).")
sigSwingDivDepth = input.float(0.75, "Swing: leg extreme depth (× OS/OB)", minval=0.3, maxval=1.5, step=0.05, group=gSIG, tooltip="The leg's deepest trough must reach Oversold × this (0.75 → −45 with OS −60). Peaks mirror with Overbought.")
sigSwingTol   = input.float(0.25, "Swing: double-bottom tolerance (ATR)", minval=0, step=0.05, group=gSIG, tooltip="The armed low may sit up to this many ATR above the major-lookback low, so a slightly higher second bottom still arms (tops mirror).")
sigSwingUpBlk = input.bool(true,  "Swing: block SELL in up-thrust", group=gSIG, tooltip="Skips swing SELLs while price is above a rising Trend EMA with ADX ≥ the minimum below and +DI > −DI — stops sells right before breakout legs.")
sigSwingUpAdx = input.float(20,   "Swing: up-thrust min ADX", minval=5, maxval=50, step=1, group=gSIG)
sigOppGuard   = input.bool(true,  "Opposite-signal guard", group=gSIG, tooltip="After a FLUX BUY, block any FLUX SELL for the bars below unless price closes below the BUY bar's low (SELL → BUY mirrors with the SELL bar's high).")
sigOppGuardBars = input.int(28,   "Opposite-signal guard (bars)", minval=1, maxval=200, group=gSIG)

// ── Chop Filter (ADX + squeeze + momentum) ───────────────────────────────────
chopEnable    = true
chopAdxLen    = 14
chopAdxStrong = 24.0
chopAdxWeak   = 20.0
chopMildScoreBonus = 6
chopBbLen     = 20
chopBbMult    = 2.0
chopBbSqueezePct = 0.88
chopUseBB     = true
chopHaBodyMin = 0.50
chopUseHaBody = true
chopFwMinSpread  = 9.5
chopUseFwSpread  = true
visChopBg     = true
visChopGlow   = true
visChopLabel  = true
visChopMeter  = true

// ── Exits (after STRONG signals — mirrors strategy v3) ───────────────────────
gEXIT         = "⑥ Exits"
showExits     = input.bool(false, "Show EXIT LONG / EXIT SHORT labels", group=gEXIT)
exitStrongOpp = input.bool(true,  "Exit on opposite STRONG signal",   group=gEXIT)
exitMinBars   = input.int(16,     "Min bars before manual exit",      minval=1, maxval=50, group=gEXIT)
exitOppMinBars= input.int(20,     "Opposite STRONG: min bars",        minval=4, maxval=60, group=gEXIT)
exitTrailStartR= input.float(1.35,"Trail activates after (R)",       step=0.05, minval=0.5, group=gEXIT)
exitHA        = input.bool(false, "Exit on HA reversal",              group=gEXIT, tooltip="OFF by default — reduces 1H whipsaw exits.")
exitHaFlipRun = input.int(4,      "HA flip: min opposite candles",  minval=2, maxval=8, group=gEXIT)
exitHaMinBody = input.float(0.40, "HA exit: min reversal body",     step=0.05, minval=0.2, maxval=0.8, group=gEXIT)
exitATRtrail  = input.bool(true,  "ATR trailing stop",              group=gEXIT)
exitTrailMult = input.float(3.0,  "ATR trail multiplier", step=0.1, minval=1.0, group=gEXIT)
exitSwing     = input.bool(true,  "Swing low/high trail",           group=gEXIT)
exitSwingLen  = input.int(22,     "Swing trail lookback", minval=5, maxval=50, group=gEXIT)
exitSwingBuf  = input.float(0.30, "Swing trail ATR buffer", step=0.05, minval=0.05, group=gEXIT)
exitAtrLen    = input.int(14,     "Exit ATR length", minval=1, group=gEXIT)
exitSlMult    = input.float(1.4,  "R reference: SL ATR mult",       step=0.1, minval=0.1, group=gEXIT)

// ── Visuals group ────────────────────────────────────────────────────────────
gVIS          = "⑦ Visuals"
visCleanChart = input.bool(true,  "Clean chart mode",                 group=gVIS, tooltip="Premium minimal look — hides trail lines and extra noise.")
visShowTrails = input.bool(false, "Show trailing stop lines",         group=gVIS)
visBarColor   = input.bool(true,  "Color bars by confluence state",   group=gVIS)
visGlowFills  = input.bool(true,  "Smooth premium fills",             group=gVIS)
visSignalText = input.bool(true,  "Show STRONG text labels",          group=gVIS, tooltip="OFF = clean markers (Flux permission stamp). ON = STRONG BUY/SELL text.")
visStrongGlow = input.bool(false, "STRONG signal glow halo",          group=gVIS, tooltip="OFF by default for a cleaner chart.")

// ── Fibonacci retracements (recent swing leg) ─────────────────────────────────
gFIB          = "⑧ Fibonacci Retracements"
showRecentFibs= input.bool(true,  "Show Recent Fibs",                 group=gFIB, tooltip="Support: lowest low → highest high in leg window. Resistance: highest high → lowest low. Levels: 0.5 · 0.618 · 0.65 · 0.786.")
fibShowLabels = input.bool(true,  "Show ratio labels",              group=gFIB, tooltip="Labels each Fib line with its level (0.5 · 0.618 · 0.65 · 0.786) on the line itself.")
fibExtend     = input.int(5,      "Extend lines (bars)", minval=0, maxval=24, group=gFIB)
fibLegLookback= input.int(180,    "Swing leg lookback (bars)", minval=20, maxval=500, group=gFIB, tooltip="Full leg scan — support: lowest low → highest high in window. Resistance: highest high → lowest low.")

// ── Alerts group ─────────────────────────────────────────────────────────────
gALR          = "⑨ Alerts"
alrEnable     = input.bool(true,  "Master alerts toggle",             group=gALR)
alrCombined   = input.bool(true,  "Combined confluence alert",        group=gALR, tooltip="Fires one rich alert that lists exactly which confluence legs triggered (e.g. 'Strong Buy + Flux Wave oversold cross + VWAP support + money inflow').")
alrFreq       = input.string("Once Per Bar Close", "Combined alert frequency", options=["Once Per Bar Close","Once Per Bar"], group=gALR)

// ── Flux Read export (app / webhook — additive, does not change signals) ─────
gREAD          = "⑩ Flux Read Export"
fluxReadEnable = input.bool(false, "Enable Flux Read JSON alerts", group=gREAD, tooltip="OFF by default. When ON, emits one compact JSON alert per bar close for webhooks / future OCO app sync. Does not change any signal logic.")
fluidTfProfile = input.bool(false, "Fluid TF profile (experimental)", group=gREAD, tooltip="OFF = keep classic LTF/1H/HTF buckets. ON = continuous TF scaling (needs Auto-optimize ON). Leave OFF unless you are A/B testing.")
regimeGateStrong = input.bool(true, "Regime gate STRONG", group=gREAD, tooltip="ON (Flux default): CHOP blocks STRONG; RANGE = reverse STRONG only; TREND = all. Diamonds stay on the oscillator.")

// ═══════════════════════ GOLDILOCKS 1H PROFILE (sweet spot) ═══════════════════
int tfSec    = timeframe.in_seconds()
int tfMin    = tfSec > 0 ? tfSec / 60 : 60
bool tfIs1H  = tfMin == 60
bool tfIsLTF = tfMin > 0 and tfMin < 60
bool tfIsHTF = tfMin > 60
// Scalp Mode applies only on 1H and below — 4H+ behavior is unchanged when toggle is ON.
bool scalpActive = scalpMode and not tfIsHTF

// Classic bucket profile (exact prior behavior when fluid OFF)
int bucketOracleStrong = use1HProfile ? (tfIs1H ? 80 : tfIsLTF ? 70 : tfIsHTF ? 78 : sigOracleStrong) : sigOracleStrong
int bucketOracleNormal = use1HProfile ? (tfIs1H ? 58 : tfIsLTF ? 52 : 58) : sigOracleNormal
int bucketPillarMin    = use1HProfile ? (tfIs1H ? 12 : tfIsLTF ? 10 : 12) : sigPillarMin
int bucketPillarMinNorm= use1HProfile ? (tfIs1H ? 10 : tfIsLTF ? 8 : 10) : math.max(sigPillarMin - 1, 5)
int bucketHaMinRun     = use1HProfile ? (tfIs1H ? 4 : tfIsLTF ? 3 : 4) : haMinRun
int bucketCooldown     = use1HProfile ? (tfIs1H ? 24 : tfIsLTF ? 12 : 18) : sigCooldown
int bucketStructLen    = use1HProfile ? (tfIs1H ? 12 : tfIsLTF ? 8 : 16) : sigStructLen
int bucketFwTrigBars   = use1HProfile and tfIs1H ? 5 : 0
int bucketOscZoneBars  = use1HProfile and tfIs1H ? 5 : 3
int bucketDivPivL      = use1HProfile and tfIs1H ? 5 : divPivLeft
int bucketDivPivR      = use1HProfile and tfIs1H ? 5 : divPivRight
bool bucketSoftDailyVwap = use1HProfile and tfIs1H
int  bucketZoneBuyMax  = use1HProfile and tfIs1H ? 45 : 60
int  bucketZoneSellMin = use1HProfile and tfIs1H ? -45 : -60
float bucketTrailStartR= use1HProfile ? (tfIs1H ? 1.55 : tfIsLTF ? 1.2 : 1.6) : exitTrailStartR
int bucketExitMinBars  = use1HProfile ? (tfIs1H ? 18 : tfIsLTF ? 12 : 22) : exitMinBars
int bucketExitOppMin   = use1HProfile ? (tfIs1H ? 22 : tfIsLTF ? 16 : 26) : exitOppMinBars
float bucketTrailMult  = use1HProfile ? (tfIs1H ? 3.35 : tfIsLTF ? 3.0 : 3.45) : exitTrailMult
int bucketSwingLen     = use1HProfile ? (tfIs1H ? 20 : tfIsLTF ? 18 : 24) : exitSwingLen
int bucketFibLegLook   = use1HProfile ? (tfIs1H ? 220 : tfIsLTF ? 120 : tfIsHTF ? 300 : fibLegLookback) : fibLegLookback
int bucketRevOracleGap = use1HProfile and tfIs1H ? 4 : 5
int bucketDivPersist   = use1HProfile ? (tfIs1H ? 10 : tfIsLTF ? 8 : 8) : 8
float bucketDivOSPct   = use1HProfile and tfIs1H ? 0.85 : 1.0
int bucketRevCdBars    = use1HProfile ? (tfIs1H ? 12 : tfIsLTF ? 8 : 14) : 12

// Fluid continuous profile — anchors: ~5m (LTF) → 60m (1H) → 240m (HTF); OFF keeps buckets
float fluidTLo = tfMin <= 60 ? math.min(1.0, math.max(0.0, (tfMin - 5.0) / 55.0)) : 1.0
float fluidTHi = tfMin <= 60 ? 0.0 : math.min(1.0, math.max(0.0, (tfMin - 60.0) / 180.0))
float fluidNear1H = math.max(0.0, 1.0 - math.abs(tfMin - 60.0) / 60.0)
int fluidOracleStrong = tfMin <= 60 ? int(math.round(70.0 + 10.0 * fluidTLo)) : int(math.round(80.0 - 2.0 * fluidTHi))
int fluidOracleNormal = tfMin <= 60 ? int(math.round(52.0 + 6.0 * fluidTLo)) : 58
int fluidPillarMin    = tfMin <= 60 ? int(math.round(10.0 + 2.0 * fluidTLo)) : 12
int fluidPillarMinNorm= tfMin <= 60 ? int(math.round(8.0 + 2.0 * fluidTLo)) : 10
int fluidHaMinRun     = tfMin <= 60 ? int(math.round(3.0 + 1.0 * fluidTLo)) : 4
int fluidCooldown     = tfMin <= 60 ? int(math.round(12.0 + 12.0 * fluidTLo)) : int(math.round(24.0 - 6.0 * fluidTHi))
int fluidStructLen    = tfMin <= 60 ? int(math.round(8.0 + 4.0 * fluidTLo)) : int(math.round(12.0 + 4.0 * fluidTHi))
int fluidFwTrigBars   = int(math.round(5.0 * fluidNear1H))
int fluidOscZoneBars  = int(math.round(3.0 + 2.0 * fluidNear1H))
int fluidDivPivL      = int(math.round(divPivLeft + (5 - divPivLeft) * fluidNear1H))
int fluidDivPivR      = int(math.round(divPivRight + (5 - divPivRight) * fluidNear1H))
bool fluidSoftDailyVwap = use1HProfile and tfMin >= 45 and tfMin <= 90
int  fluidZoneBuyMax  = int(math.round(60.0 - 15.0 * fluidNear1H))
int  fluidZoneSellMin = int(math.round(-60.0 + 15.0 * fluidNear1H))
float fluidTrailStartR= tfMin <= 60 ? (1.2 + 0.35 * fluidTLo) : (1.55 + 0.05 * fluidTHi)
int fluidExitMinBars  = tfMin <= 60 ? int(math.round(12.0 + 6.0 * fluidTLo)) : int(math.round(18.0 + 4.0 * fluidTHi))
int fluidExitOppMin   = tfMin <= 60 ? int(math.round(16.0 + 6.0 * fluidTLo)) : int(math.round(22.0 + 4.0 * fluidTHi))
float fluidTrailMult  = tfMin <= 60 ? (3.0 + 0.35 * fluidTLo) : (3.35 + 0.10 * fluidTHi)
int fluidSwingLen     = tfMin <= 60 ? int(math.round(18.0 + 2.0 * fluidTLo)) : int(math.round(20.0 + 4.0 * fluidTHi))
int fluidFibLegLook   = tfMin <= 60 ? int(math.round(120.0 + 100.0 * fluidTLo)) : int(math.round(220.0 + 80.0 * fluidTHi))
int fluidRevOracleGap = int(math.round(5.0 - 1.0 * fluidNear1H))
int fluidDivPersist   = tfMin <= 60 ? int(math.round(8.0 + 2.0 * fluidTLo)) : 8
float fluidDivOSPct   = 1.0 - 0.15 * fluidNear1H
int fluidRevCdBars    = tfMin <= 60 ? int(math.round(8.0 + 4.0 * fluidTLo)) : int(math.round(12.0 + 2.0 * fluidTHi))

bool useFluidProf = use1HProfile and fluidTfProfile
int profOracleStrong = useFluidProf ? fluidOracleStrong : bucketOracleStrong
int profOracleNormal = useFluidProf ? fluidOracleNormal : bucketOracleNormal
int profPillarMin    = useFluidProf ? fluidPillarMin : bucketPillarMin
int profPillarMinNorm= useFluidProf ? fluidPillarMinNorm : bucketPillarMinNorm
int profPillarsNeed  = 4
int profHaMinRun     = useFluidProf ? fluidHaMinRun : bucketHaMinRun
int profCooldown     = useFluidProf ? fluidCooldown : bucketCooldown
int profStructLen    = useFluidProf ? fluidStructLen : bucketStructLen
int profFwTrigBars   = useFluidProf ? fluidFwTrigBars : bucketFwTrigBars
int profOscZoneBars  = useFluidProf ? fluidOscZoneBars : bucketOscZoneBars
int profDivPivL      = useFluidProf ? fluidDivPivL : bucketDivPivL
int profDivPivR      = useFluidProf ? fluidDivPivR : bucketDivPivR
bool profSoftDailyVwap = useFluidProf ? fluidSoftDailyVwap : bucketSoftDailyVwap
int  profZoneBuyMax  = useFluidProf ? fluidZoneBuyMax : bucketZoneBuyMax
int  profZoneSellMin = useFluidProf ? fluidZoneSellMin : bucketZoneSellMin
float profTrailStartR= useFluidProf ? fluidTrailStartR : bucketTrailStartR
int profExitMinBars  = useFluidProf ? fluidExitMinBars : bucketExitMinBars
int profExitOppMin   = useFluidProf ? fluidExitOppMin : bucketExitOppMin
float profTrailMult  = useFluidProf ? fluidTrailMult : bucketTrailMult
int profSwingLen     = useFluidProf ? fluidSwingLen : bucketSwingLen
int profFibLegLook   = useFluidProf ? fluidFibLegLook : bucketFibLegLook
int profRevOracleGap = useFluidProf ? fluidRevOracleGap : bucketRevOracleGap
int profDivPersist   = useFluidProf ? fluidDivPersist : bucketDivPersist
float profDivOSPct   = useFluidProf ? fluidDivOSPct : bucketDivOSPct
int profRevCdBars    = useFluidProf ? fluidRevCdBars : bucketRevCdBars

// ── Scalp Mode layer (1H and below only — overrides prof* when active) ──
// Quality-first scalp: higher Oracle bar, 3 pillars, stricter Flux Wave+MF+VWAP confluence, anti-cluster cooldown.
int effOracleStrong = scalpActive ? (tfIs1H ? 74 : 72) : profOracleStrong
int effOracleNormal = profOracleNormal
int effPillarMin    = scalpActive ? 9 : profPillarMin
int effPillarMinNorm= profPillarMinNorm
int effPillarsNeed  = scalpActive ? 3 : profPillarsNeed
int effHaMinRun     = scalpActive ? 3 : profHaMinRun
int effCooldown     = scalpActive ? (tfIs1H ? 16 : 10) : profCooldown
int effStructLen    = scalpActive ? (tfIs1H ? 8 : 6) : profStructLen
int effFwTrigBars   = scalpActive ? (tfIs1H ? 6 : 4) : profFwTrigBars
int effOscZoneBars   = scalpActive ? (tfIs1H ? 7 : 5) : profOscZoneBars
int effDivPivL      = scalpActive ? 3 : profDivPivL
int effDivPivR      = scalpActive ? 3 : profDivPivR
bool effReqThrust   = haReqStrong
bool effReqStruct   = false
bool effSoftDailyVwap = scalpActive or profSoftDailyVwap
bool effScalpStrictVwap = scalpActive
int  effZoneBuyMax  = scalpActive ? 48 : profZoneBuyMax
int  effZoneSellMin = scalpActive ? -48 : profZoneSellMin
float effTrailStartR= scalpActive ? (tfIs1H ? 1.1 : 0.95) : profTrailStartR
int effExitMinBars  = scalpActive ? (tfIs1H ? 10 : 8) : profExitMinBars
int effExitOppMin   = scalpActive ? (tfIs1H ? 14 : 10) : profExitOppMin
float effTrailMult  = scalpActive ? (tfIs1H ? 2.75 : 2.55) : profTrailMult
int effSwingLen     = scalpActive ? (tfIs1H ? 14 : 12) : profSwingLen
int effFibLegLook   = scalpActive ? (tfIs1H ? 120 : 80) : profFibLegLook
int effRevOracleGap = scalpActive ? 7 : profRevOracleGap
int effFwChanLen    = scalpActive ? 7 : fwChanLen
int effFwAvgLen     = scalpActive ? 9 : fwAvgLen
int effFwSigLen     = scalpActive ? 2 : fwSigLen
int effMfBodyLen    = scalpActive ? 9 : 14
bool effDivOnlyMajor = scalpActive ? false : divOnlyMajor
bool effExitHA      = exitHA or scalpActive
int effExitHaFlipRun = scalpActive ? 3 : exitHaFlipRun
float effExitHaMinBody = scalpActive ? 0.35 : exitHaMinBody
float effExitHaMinR = scalpActive ? 0.5 : 0.75
bool effShowNormal  = showNormal and not scalpActive
float effChopFwMinSpread = scalpActive ? 6.5 : chopFwMinSpread
int   effIVwapLen     = scalpActive ? 6 : 11
int   effIVwapSmooth  = scalpActive ? 2 : 4
float effIVwapScale   = scalpActive ? 50.0 : 44.0
float effPinchPct     = scalpActive ? 0.34 : 0.38
float effSharpRoll    = scalpActive ? 3.0 : 4.5
int   effDivPersist   = scalpActive ? 10 : profDivPersist
float effDivOSPct     = scalpActive ? 0.70 : profDivOSPct
int   effRevCdBars    = scalpActive ? 5 : profRevCdBars

// ═════════════════════════════ HELPER FUNCTIONS ═════════════════════════════

// Generic clamp
f_clamp(_v, _lo, _hi) => math.max(_lo, math.min(_hi, _v))

// Map chop strength 0–100 for display only (derived from ADX + squeeze — no signal impact)
f_chopBar(_p) =>
    int n = int(math.min(10, math.max(0, math.round(_p / 10.0))))
    n >= 10 ? "██████████" : n >= 9 ? "█████████░" : n >= 8 ? "████████░░" : n >= 7 ? "███████░░░" : n >= 6 ? "██████░░░░" : n >= 5 ? "█████░░░░░" : n >= 4 ? "████░░░░░░" : n >= 3 ? "███░░░░░░░" : n >= 2 ? "██░░░░░░░░" : n >= 1 ? "█░░░░░░░░░" : "░░░░░░░░░░"

// Chop meter colors — red = high chop, slate-gray = low (display only)
f_chopMeterClr(_p) =>
    _p >= 65 ? color.new(C_BEAR, 8) : _p >= 40 ? color.new(C_BEAR, 32) : color.new(C_SUBTLE, 0)

f_chopTagTxtClr(_p) =>
    _p >= 65 ? color.new(C_BEAR, 20) : color.new(C_CHOP_GLOW, 26)

// Map dashboard size string -> size const
f_txtSize(_s) => _s == "Tiny" ? size.tiny : _s == "Small" ? size.small : _s == "Large" ? size.large : size.normal

// Map dashboard position string -> position const
f_dashPos(_s) => _s == "Top Left" ? position.top_left : _s == "Bottom Right" ? position.bottom_right : _s == "Bottom Left" ? position.bottom_left : position.top_right

f_jsonStr(string s) =>
    '"' + str.replace_all(str.replace_all(s, "\\", "/"), '"', "'") + '"'

f_jsonBool(bool b) =>
    b ? "true" : "false"

// ═══════════════════════════ ① FLUX WAVE ENGINE ════════════════════════════
// Composite momentum oscillator — three independently-normalized engines blended:
//   1) Flux Wave   — price vs adaptive EMA channel
//   2) VWAP        — price displacement from a rolling volume-weighted mean
//   3) Money-Flow  — volume-weighted candle pressure
// Each leg is scaled to the same ~±100 range (CI normalization), EMA-smoothed,
// then weight-blended → primary (fast) and signal lines. Outputs keep the
// primary/signal contract so every downstream feature (crosses, OB/OS, divergence,
// signals, dashboard) works unchanged — with cleaner, higher-conviction data.

f_fluxWave(_src, _chan, _avg, _sig, _wMom, _wVwap, _wMf) =>
    float vol    = nz(volume)
    float volAvg = ta.sma(vol, _chan)
    float volR   = volAvg > 0 ? vol / volAvg : 1.0
    float esa    = ta.ema(_src, _chan)
    float devW   = ta.ema(math.abs(_src - esa), _chan)
    float atrPct = ta.atr(14) / math.max(_src, syminfo.mintick)
    float adapt  = 0.015 * (1.0 + atrPct * 0.15)
    float ciW    = devW == 0 ? 0.0 : (_src - esa) / (adapt * devW)
    float vwmRaw = ta.vwma(_src, _chan)
    float vwmSma = ta.sma(_src, _chan)
    float vwm    = na(vwmRaw) ? vwmSma : vwmRaw
    float devV   = ta.ema(math.abs(_src - vwm), _chan)
    float ciV    = devV == 0 ? 0.0 : (_src - vwm) / (adapt * devV)
    float rng    = high - low
    float body   = rng != 0 ? (close - open) / rng : 0.0
    float mfr    = body * vol * math.min(math.sqrt(volR), 2.0)
    float devM   = ta.ema(math.abs(mfr), _chan)
    float ciM    = devM == 0 ? 0.0 : (mfr / (adapt * devM)) * 0.75
    float tW     = ta.ema(ciW, _avg)
    float tV     = ta.ema(ciV, _avg)
    float tM     = ta.ema(ciM, _avg)
    float acc    = ta.ema(ciW - ciW[1], math.max(2, _sig))
    float wsum   = _wMom + _wVwap + _wMf
    float blend  = wsum == 0 ? 0.0 : (_wMom * tW + _wVwap * tV + _wMf * tM) / wsum
    float raw    = blend + acc * 0.22
    float w1     = math.max(-160.0, math.min(160.0, raw))
    float w2     = ta.sma(w1, _sig)
    [w1, w2, tW, tV, tM, acc]

// Fast internal VWAP oscillator (compute-only, no chart clutter)
f_internalVwapOsc(_src, _len, _smooth, _accel, _scale) =>
    float vwRaw = ta.vwma(_src, _len)
    float vwSma = ta.sma(_src, _len)
    float vwMid = na(vwRaw) ? vwSma : vwRaw
    float vwDev = ta.ema(math.abs(_src - vwMid), _len)
    float atrP  = ta.atr(14) / math.max(_src, syminfo.mintick)
    float adpt  = 0.017 * (1.0 + atrP * 0.13)
    float ci    = vwDev == 0 ? 0.0 : (_src - vwMid) / (adpt * vwDev)
    float core  = ta.ema(ta.ema(ci, _len), _smooth)
    float line  = math.max(-160.0, math.min(160.0, core * _scale + _accel * 7.0))
    line

// Always compute (cheap, avoids tuple-ternary limitation); usage is gated by oscEnable.

// ═══════════════════════════ HEIKIN ASHI ENGINE ════════════════════════════
float haClose = (open + high + low + close) / 4.0
var float haOpen = na
haOpen := na(haOpen[1]) ? (open + close) / 2.0 : (haOpen[1] + haClose[1]) / 2.0
float haHigh = math.max(high, math.max(haOpen, haClose))
float haLow  = math.min(low,  math.min(haOpen, haClose))
float haSrc  = (haHigh + haLow + haClose) / 3.0
bool  haBull = haClose > haOpen
bool  haBear = haClose < haOpen
float haRange = haHigh - haLow
float haBodyR = haRange > 0 ? math.abs(haClose - haOpen) / haRange : 0.0
float haLoWick = haBull ? haOpen - haLow : haClose - haLow
float haHiWick = haBear ? haHigh - haOpen : haHigh - haClose
bool  haStrongBull = haBull and haRange > 0 and haLoWick <= haRange * 0.08
bool  haStrongBear = haBear and haRange > 0 and haHiWick <= haRange * 0.08
bool  haWickRejBuy  = haBull and haRange > 0 and haLoWick <= haRange * haWickMax
bool  haWickRejSell = haBear and haRange > 0 and haHiWick <= haRange * haWickMax
var int haRun = 0
haRun := haBull ? (haRun >= 0 ? haRun + 1 : 1) : haBear ? (haRun <= 0 ? haRun - 1 : -1) : 0
// HA primary gate — structure must agree before any signal is considered
bool haTrendBuy  = not haOn or (haBull and haRun >= effHaMinRun and haBodyR >= haMinBody and haWickRejBuy)
bool haTrendSell = not haOn or (haBear and haRun <= -effHaMinRun and haBodyR >= haMinBody and haWickRejSell)
bool haThrustBuy  = not effReqThrust or haStrongBull
bool haThrustSell = not effReqThrust or haStrongBear

f_obHoldBull(_lb) =>
    bool hold = false
    if haOn and haBull
        for i = 1 to _lb
            if haClose[i] < haOpen[i]
                hold := close > haOpen[i]
                break
    hold

f_obHoldBear(_lb) =>
    bool hold = false
    if haOn and haBear
        for i = 1 to _lb
            if haClose[i] > haOpen[i]
                hold := close < haOpen[i]
                break
    hold

float fwSrcUsed = haOn ? haSrc : fwSrc
[fwPrimary, fwSignal, oscMom, oscVwap, oscMf, fwAccel] = f_fluxWave(fwSrcUsed, effFwChanLen, effFwAvgLen, effFwSigLen, oFwMom, oFwVwap, oFwMf)

// Internal VWAP + pinch scaffold — harmonizes STRONG timing with oscillator dots (no plot)
float iVwap = f_internalVwapOsc(fwSrcUsed, effIVwapLen, effIVwapSmooth, fwAccel, effIVwapScale)
float ivSpread    = math.abs(fwPrimary - iVwap)
float ivSpreadSma = ta.sma(ivSpread, scalpActive ? 8 : 14)
float ivSpreadLo  = ta.lowest(ivSpread, scalpActive ? 4 : 7)
bool  ivPinched   = ivSpread <= ivSpreadSma * effPinchPct and ivSpread <= ivSpreadLo * 1.10
bool  wavePeak    = fwPrimary < fwPrimary[1] and fwPrimary[1] >= fwPrimary[2]
bool  ivPeak      = iVwap < iVwap[1] and iVwap[1] >= iVwap[2]
bool  waveTrough  = fwPrimary > fwPrimary[1] and fwPrimary[1] <= fwPrimary[2]
bool  ivTrough    = iVwap > iVwap[1] and iVwap[1] <= iVwap[2]
bool  zoneBearExh = fwPrimary[1] >= (scalpActive ? 24.0 : fwOB * 0.58) or iVwap[1] >= (scalpActive ? 20.0 : fwOB * 0.54)
bool  zoneBullExh = fwPrimary[1] <= (scalpActive ? -24.0 : fwOS * 0.58) or iVwap[1] <= (scalpActive ? -20.0 : fwOS * 0.54)
float rollMagBear = fwPrimary[1] - fwPrimary
float rollMagBull = fwPrimary - fwPrimary[1]
bool  sharpBearRoll = wavePeak and ivPeak and rollMagBear >= effSharpRoll
bool  sharpBullRoll = waveTrough and ivTrough and rollMagBull >= effSharpRoll
bool  pinchExhaustBuy  = ivPinched and sharpBullRoll and zoneBullExh
bool  pinchExhaustSell = ivPinched and sharpBearRoll and zoneBearExh
bool  pinchAlignBuy    = pinchExhaustBuy or pinchExhaustBuy[1] or pinchExhaustBuy[2]
bool  pinchAlignSell   = pinchExhaustSell or pinchExhaustSell[1] or pinchExhaustSell[2]

// Component agreement → all three momentum engines pointing the same way.
// This is the Flux Wave's edge over single-source oscillators.
bool oscAllBull = oscEnable and oscMom > 0 and oscVwap > 0 and oscMf > 0
bool oscAllBear = oscEnable and oscMom < 0 and oscVwap < 0 and oscMf < 0

// ta.* calls hoisted to global scope so v6 lazy (short-circuit) and/or never skips them.
bool fwCU = ta.crossover(fwPrimary, fwSignal)
bool fwCD = ta.crossunder(fwPrimary, fwSignal)

bool fwCrossUp   = oscEnable and fwCU
bool fwCrossDn   = oscEnable and fwCD
bool fwBull      = oscEnable and fwPrimary > fwSignal
bool fwBear      = oscEnable and fwPrimary < fwSignal
bool fwInOS      = oscEnable and fwSignal <= fwOS
bool fwInOB      = oscEnable and fwSignal >= fwOB

// momentum strength 0..1 (distance of signal line from zero, normalized)
float fwStrength = oscEnable ? f_clamp(math.abs(fwSignal) / 100.0, 0, 1) : 0.0

// ══════════════════════════ ② DIVERGENCE DETECTION ═════════════════════════
// Pivot-based regular divergence between price & Flux Wave signal line.

var float lastPivLowSig  = na
var float lastPivLowPr  = na
var int   lastPivLowBar = na
var float lastPivHiSig   = na
var float lastPivHiPr   = na
var int   lastPivHiBar  = na

bool bullDiv = false
bool bearDiv = false
bool hiddenBullDiv = false
bool hiddenBearDiv = false

// Flux Wave pivots (confirmed divPivRight bars ago) — hoisted to global scope for v6.
float pvLowSig = ta.pivotlow(fwSignal, effDivPivL, effDivPivR)
float pvHiSig  = ta.pivothigh(fwSignal, effDivPivL, effDivPivR)
int   pvBar   = bar_index - effDivPivR
float pvLowPr = low[effDivPivR]
float pvHiPr  = high[effDivPivR]

if divEnable and oscEnable
    float effDivOSLvl = fwOS * effDivOSPct
    // ── Bullish divergence: price lower low, Flux Wave higher low ──
    if not na(pvLowSig)
        bool qualified = not effDivOnlyMajor or (pvLowSig <= effDivOSLvl)
        if not na(lastPivLowSig) and qualified and (pvBar - lastPivLowBar) <= divLookback
            if pvLowPr < lastPivLowPr and pvLowSig > lastPivLowSig
                bullDiv := true
        if divHidden and not na(lastPivLowSig) and (pvBar - lastPivLowBar) <= divLookback
            bool qualHidBull = not effDivOnlyMajor or (pvLowSig > effDivOSLvl and pvLowSig < fwOB)
            if qualHidBull and pvLowPr > lastPivLowPr and pvLowSig < lastPivLowSig
                hiddenBullDiv := true
        lastPivLowSig  := pvLowSig
        lastPivLowPr  := pvLowPr
        lastPivLowBar := pvBar

    // ── Bearish divergence: price higher high, Flux Wave lower high (keeps strict OB) ──
    if not na(pvHiSig)
        bool qualifiedB = not effDivOnlyMajor or (pvHiSig >= fwOB)
        if not na(lastPivHiSig) and qualifiedB and (pvBar - lastPivHiBar) <= divLookback
            if pvHiPr > lastPivHiPr and pvHiSig < lastPivHiSig
                bearDiv := true
        if divHidden and not na(lastPivHiSig) and (pvBar - lastPivHiBar) <= divLookback
            bool qualHidBear = not effDivOnlyMajor or (pvHiSig < fwOB and pvHiSig > fwOS)
            if qualHidBear and pvHiPr < lastPivHiPr and pvHiSig > lastPivHiSig
                hiddenBearDiv := true
        lastPivHiSig  := pvHiSig
        lastPivHiPr  := pvHiPr
        lastPivHiBar := pvBar

// Persist div flags — dashboard + reversal gates stay active after pivot confirm
var int lastBullDivBar = na
var int lastBearDivBar = na
if bullDiv
    lastBullDivBar := bar_index
if bearDiv
    lastBearDivBar := bar_index
bool bullDivRecent = not na(lastBullDivBar) and bar_index - lastBullDivBar <= effDivPersist
bool bearDivRecent = not na(lastBearDivBar) and bar_index - lastBearDivBar <= effDivPersist
bool bullDivActive = bullDiv or bullDivRecent
bool bearDivActive = bearDiv or bearDivRecent

// Divergence labels — minimal premium chips (hidden in clean chart mode)
bool showDivLbl = divShowLabels and not visCleanChart
if divEnable and showDivLbl and bullDiv
    label.new(bar_index - effDivPivR, low[effDivPivR], "◆ Div", yloc=yloc.belowbar,
              style=label.style_label_up, color=color.new(#0A0F1A, 15), textcolor=C_BULL, size=size.tiny)
if divEnable and showDivLbl and bearDiv
    label.new(bar_index - effDivPivR, high[effDivPivR], "◆ Div", yloc=yloc.abovebar,
              style=label.style_label_down, color=color.new(#0A0F1A, 15), textcolor=C_BEAR, size=size.tiny)
if divEnable and divHidden and showDivLbl and hiddenBullDiv
    label.new(bar_index - effDivPivR, low[effDivPivR], "◆ H", yloc=yloc.belowbar,
              style=label.style_label_up, color=color.new(#0A0F1A, 15), textcolor=color.new(#38E8A8, 0), size=size.tiny)
if divEnable and divHidden and showDivLbl and hiddenBearDiv
    label.new(bar_index - effDivPivR, high[effDivPivR], "◆ H", yloc=yloc.abovebar,
              style=label.style_label_down, color=color.new(#0A0F1A, 15), textcolor=color.new(#FF5C8A, 0), size=size.tiny)

// ═══════════════════════ ③ ANCHORED VWAPs ══════════════════════════════════
// Each level is a TRUE anchored VWAP: it accumulates price·volume from its own
// anchor bar to the live bar. We keep chart-wide cumulative sums and, for every
// anchor, store the cumulative totals captured just BEFORE the anchor bar — so
// any anchored VWAP = (cumPV - basePV) / (cumV - baseV). Anchors:
//   daily  → session open        wtd  → week open
//   pday   → previous session    pwk  → previous week open
//   5day   → session open 5 days ago

// Level palette — cohesive OCO neon spectrum (mostly cool, distinct per level)
var color CL_DAILY  = color.new(#00E8B0, 0)    // daily    (mint — links to neon Wave)
var color CL_PDAILY = color.new(#FFB800, 0)    // prev day (amber — links to Fair Value)
var color CL_WTD    = color.new(#FF9A1F, 0)    // wtd      (soft orange)
var color CL_PWTD   = color.new(#A78BFA, 0)    // prev wk  (soft purple)
var color CL_5SMA   = color.new(#7A8799, 0)    // 5-day    (slate)

// Period rollover flags
bool isNewDay  = timeframe.change("D")
bool isNewWeek = timeframe.change("W")

// Chart-wide cumulative sums; capture the pre-bar totals for anchor maths
var float cumPV = 0.0
var float cumV  = 0.0
float basePV = cumPV
float baseV  = cumV
cumPV += vwapSrc * volume
cumV  += volume

// Anchored VWAP from stored base totals
f_avwap(_basePV, _baseV) => (cumV - _baseV) > 0 ? (cumPV - _basePV) / (cumV - _baseV) : na

// ── Daily + Previous-day anchor bases ──
var float dBasePV = na
var float dBaseV  = na
var int   dBar    = na
var float pdBasePV = na
var float pdBaseV  = na
var int   pdBar    = na
if na(dBar) or isNewDay
    if not na(dBar)
        pdBasePV := dBasePV
        pdBaseV  := dBaseV
        pdBar    := dBar
    dBasePV := basePV
    dBaseV  := baseV
    dBar    := bar_index

// ── Weekly + Previous-week anchor bases ──
var float wBasePV = na
var float wBaseV  = na
var int   wBar    = na
var float pwBasePV = na
var float pwBaseV  = na
var int   pwBar    = na
if na(wBar) or isNewWeek
    if not na(wBar)
        pwBasePV := wBasePV
        pwBaseV  := wBaseV
        pwBar    := wBar
    wBasePV := basePV
    wBaseV  := baseV
    wBar    := bar_index

// ── 5-day anchor: keep a rolling buffer of recent session-open bases ──
var array<float> dOpenPV  = array.new<float>()
var array<float> dOpenV   = array.new<float>()
var array<int>   dOpenBar = array.new<int>()
if na(dBar[1]) or isNewDay
    array.push(dOpenPV, basePV)
    array.push(dOpenV,  baseV)
    array.push(dOpenBar, bar_index)
    if array.size(dOpenPV) > 7
        array.shift(dOpenPV)
        array.shift(dOpenV)
        array.shift(dOpenBar)
int   idx5 = array.size(dOpenPV) >= 6 ? array.size(dOpenPV) - 6 : 0
float b5PV = array.size(dOpenPV) > 0 ? array.get(dOpenPV, idx5) : na
float b5V  = array.size(dOpenV)  > 0 ? array.get(dOpenV,  idx5) : na
int   b5Bar= array.size(dOpenBar)> 0 ? array.get(dOpenBar, idx5) : na

// Resolve each anchored VWAP value
float dailyVWAP = f_avwap(dBasePV,  dBaseV)
float pdayVWAP  = f_avwap(pdBasePV, pdBaseV)
float weekVWAP  = f_avwap(wBasePV,  wBaseV)
float pweekVWAP = f_avwap(pwBasePV, pwBaseV)
float vwap5     = na(b5PV) ? na : f_avwap(b5PV, b5V)

// Nearest VWAP to price → feeds the signal confluence
float nearestVWAP  = na
float nearestDist  = na
bool  priceAboveAV = false
bool  priceBelowAV = false
if vwapEnable
    array<float> cand = array.new<float>()
    if vShowDaily  and not na(dailyVWAP)
        array.push(cand, dailyVWAP)
    if vShowWtd    and not na(weekVWAP)
        array.push(cand, weekVWAP)
    if vShowPDaily and not na(pdayVWAP)
        array.push(cand, pdayVWAP)
    if vShowPWtd   and not na(pweekVWAP)
        array.push(cand, pweekVWAP)
    if vShow5SMA   and not na(vwap5)
        array.push(cand, vwap5)
    for v in cand
        float d = math.abs(close - v)
        if na(nearestDist) or d < nearestDist
            nearestDist := d
            nearestVWAP := v
    if not na(nearestVWAP)
        priceAboveAV := close > nearestVWAP
        priceBelowAV := close < nearestVWAP

// ── Drawing: clean anchored line (anchor bar → live) + dot + name (±%) label ──
var array<line>  vLines  = array.new<line>()
var array<label> vLabels = array.new<label>()

f_drawAV(_show, _val, _anchor, _name, _col) =>
    if _show and not na(_val) and not na(_anchor)
        // soft neon glow behind the crisp line
        line glow = line.new(_anchor, _val, bar_index + 2, _val, xloc=xloc.bar_index, color=color.new(_col, 80), width=vwapLineWidth + 2, style=line.style_solid)
        array.push(vLines, glow)
        line ln = line.new(_anchor, _val, bar_index + 2, _val, xloc=xloc.bar_index, color=color.new(_col, 12), width=vwapLineWidth, style=line.style_solid)
        array.push(vLines, ln)
        if vwapShowLabels
            float pct = close != 0 ? (_val - close) / close * 100.0 : 0.0
            string sgn = pct >= 0 ? "+" : ""
            label lb = label.new(bar_index + 3, _val, _name + "  " + sgn + str.tostring(pct, "#.##") + "%", xloc=xloc.bar_index, style=label.style_label_left, color=color.new(#0A0F1A, 35), textcolor=_col, size=size.normal)
            array.push(vLabels, lb)

if vwapEnable and barstate.islast
    for ln in vLines
        line.delete(ln)
    for lb in vLabels
        label.delete(lb)
    array.clear(vLines)
    array.clear(vLabels)
    f_drawAV(vShowDaily,  dailyVWAP, dBar,   "daily",     CL_DAILY)
    f_drawAV(vShowPDaily, pdayVWAP,  pdBar,  "prev day",  CL_PDAILY)
    f_drawAV(vShowWtd,    weekVWAP,  wBar,   "wtd",       CL_WTD)
    f_drawAV(vShowPWtd,   pweekVWAP, pwBar,  "prev wk",   CL_PWTD)
    f_drawAV(vShow5SMA,   vwap5,     b5Bar,  "5day",      CL_5SMA)

// ── Fibonacci retracements — ONLY 0.5 · 0.618 · 0.65 · 0.786 ─────────────────
var array<line>  fibLines  = array.new<line>()
var array<label> fibLabels = array.new<label>()

f_fibPrice(_bullLeg, _hi, _lo, _ratio) =>
    _bullLeg ? _hi - _ratio * (_hi - _lo) : _lo + _ratio * (_hi - _lo)

// TV-style down-leg level (0.786 / 0.65 near swing low on bear moves)
f_fibFromHigh(_hi, _lo, _ratio) => _hi - _ratio * (_hi - _lo)

// Lowest low / highest high inside a bar_index window (inclusive) — capped to max_bars_back
f_findLegLow(_startBar, _endBar) =>
    float v = na
    int bOut = na
    if not na(_startBar) and not na(_endBar)
        int histMin = math.max(0, bar_index - 4999)
        int s = math.max(histMin, _startBar)
        int e = math.min(_endBar, bar_index)
        if e >= s
            for b = s to e
                int ago = bar_index - b
                float lv = low[ago]
                if na(v) or lv < v
                    v := lv
                    bOut := b
    [v, bOut]

f_findLegHigh(_startBar, _endBar) =>
    float v = na
    int bOut = na
    if not na(_startBar) and not na(_endBar)
        int histMin = math.max(0, bar_index - 4999)
        int s = math.max(histMin, _startBar)
        int e = math.min(_endBar, bar_index)
        if e >= s
            for b = s to e
                int ago = bar_index - b
                float hv = high[ago]
                if na(v) or hv > v
                    v := hv
                    bOut := b
    [v, bOut]

f_drawFibLevel(_show, _x1, _x2, _lblX, _y, _txt, _col) =>
    if _show and not na(_y) and not na(_x1) and not na(_x2)
        line glow = line.new(_x1, _y, _x2, _y, xloc=xloc.bar_index, color=color.new(_col, 90), width=2, style=line.style_solid)
        array.push(fibLines, glow)
        line ln = line.new(_x1, _y, _x2, _y, xloc=xloc.bar_index, color=color.new(_col, 28), width=1, style=line.style_solid)
        array.push(fibLines, ln)
        if fibShowLabels and not na(_lblX)
            label lb = label.new(_lblX, _y, _txt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(#0A0F1A, 18), textcolor=_col, size=size.normal)
            array.push(fibLabels, lb)

f_drawFibSet(_bullLeg, _xAnchor, _hi, _lo, _lblFrac) =>
    int x2   = bar_index + fibExtend
    int span = math.max(x2 - _xAnchor, 1)
    int lblX = _xAnchor + int(span * _lblFrac)
    f_drawFibLevel(true, _xAnchor, x2, lblX, f_fibPrice(_bullLeg, _hi, _lo, 0.5),   "0.5",   C_FIB_GRN)
    f_drawFibLevel(true, _xAnchor, x2, lblX, f_fibPrice(_bullLeg, _hi, _lo, 0.618), "0.618", C_FIB_GRN)
    f_drawFibLevel(true, _xAnchor, x2, lblX, f_fibPrice(_bullLeg, _hi, _lo, 0.65),  "0.65",  C_FIB_65)
    f_drawFibLevel(true, _xAnchor, x2, lblX, f_fibPrice(_bullLeg, _hi, _lo, 0.786), "0.786", C_FIB_786)

// VWAP bounce detection: price tested the nearest VWAP within tolerance & reclaimed
float tol = vwapEnable and not na(nearestVWAP) ? nearestVWAP * (vwapTouchPct / 100.0) : na
bool vwapTestUp = vwapEnable and not na(nearestVWAP) and (low <= nearestVWAP + tol) and (close > nearestVWAP)
bool vwapTestDn = vwapEnable and not na(nearestVWAP) and (high >= nearestVWAP - tol) and (close < nearestVWAP)

bool aboveDaily = vwapEnable and not na(dailyVWAP) and close > dailyVWAP
bool belowDaily = vwapEnable and not na(dailyVWAP) and close < dailyVWAP
bool abovePday  = vwapEnable and not na(pdayVWAP)  and close > pdayVWAP
bool belowPday  = vwapEnable and not na(pdayVWAP)  and close < pdayVWAP
bool vwapKeyBuy  = not sigReqDailyVWAP or (effSoftDailyVwap ? (aboveDaily or (vwapTestUp and priceAboveAV) or (priceAboveAV and abovePday)) : (aboveDaily and (abovePday or priceAboveAV or vwapTestUp)))
bool vwapKeySell = not sigReqDailyVWAP or (effSoftDailyVwap ? (belowDaily or (vwapTestDn and priceBelowAV) or (priceBelowAV and belowPday)) : (belowDaily and (belowPday or priceBelowAV or vwapTestDn)))

// ═══════════════════════ ④ MARKET STRUCTURE & TREND ════════════════════════
float trendSrc = haOn ? haClose : close
float trendEMA = ta.ema(trendSrc, sigEMAlen)
bool  trendUp  = trendSrc > trendEMA
bool  trendDn  = trendSrc < trendEMA

// Simple BOS / structure via recent confirmed pivots
var float msHigh = na
var float msLow  = na
var int   msHighBar = na
var int   msLowBar  = na
float msPH = ta.pivothigh(high, effStructLen, effStructLen)
float msPL = ta.pivotlow(low,  effStructLen, effStructLen)
if not na(msPH)
    msHigh := msPH
    msHighBar := bar_index - effStructLen
if not na(msPL)
    msLow  := msPL
    msLowBar := bar_index - effStructLen

// ── Locked Fib legs — freeze on pivot confirm (manual-style low→high / high→low) ──
var float supFibHi = na
var int   supFibHiBar = na
var float supFibLo = na
var int   supFibLoBar = na
var bool  supFibOk = false
var float resFibHi = na
var int   resFibHiBar = na
var float resFibLo = na
var int   resFibLoBar = na
var bool  resFibOk = false

if not na(msPH)
    int hiB = bar_index - effStructLen
    int loWin = math.max(0, hiB - effFibLegLook)
    [tLo, tLoB] = f_findLegLow(loWin, hiB)
    if not na(tLo) and not na(tLoB)
        [tHi, tHiB] = f_findLegHigh(tLoB, hiB)
        if not na(tHi) and not na(tHiB) and tHi > tLo and tHiB > tLoB
            supFibLo    := tLo
            supFibLoBar := tLoB
            supFibHi    := tHi
            supFibHiBar := tHiB
            supFibOk    := true

if not na(msPL)
    int loB = bar_index - effStructLen
    int hiWin = math.max(0, loB - effFibLegLook)
    [tHi, tHiB] = f_findLegHigh(hiWin, loB)
    if not na(tHi) and not na(tHiB)
        [tLo, tLoB] = f_findLegLow(tHiB, loB)
        if not na(tLo) and not na(tLoB) and tHi > tLo and loB > tHiB
            resFibHi    := tHi
            resFibHiBar := tHiB
            resFibLo    := tLo
            resFibLoBar := tLoB
            resFibOk    := true

// ── Signal fib prices (0.5 · 0.618 · 0.65 · 0.786 — confluence engine) ──
float sigRes618 = resFibOk ? f_fibPrice(false, resFibHi, resFibLo, 0.618) : na
float sigRes65  = resFibOk ? f_fibPrice(false, resFibHi, resFibLo, 0.65)  : na
float sigRes786 = resFibOk ? f_fibPrice(false, resFibHi, resFibLo, 0.786) : na
float sigRes50  = resFibOk ? f_fibPrice(false, resFibHi, resFibLo, 0.5)   : na
float sigSup618 = supFibOk ? f_fibPrice(true,  supFibHi, supFibLo, 0.618) : na
float sigSup65  = supFibOk ? f_fibPrice(true,  supFibHi, supFibLo, 0.65)  : na
float sigSup786 = supFibOk ? f_fibPrice(true,  supFibHi, supFibLo, 0.786) : na
float sigSup50  = supFibOk ? f_fibPrice(true,  supFibHi, supFibLo, 0.5)   : na
if na(sigRes786) and not na(msLowBar)
    int bLoB = msLowBar
    [bHi, bHiB] = f_findLegHigh(math.max(0, bLoB - effFibLegLook), bLoB)
    [bLo, _bLoB2] = f_findLegLow(bHiB, bLoB)
    if not na(bHi) and not na(bLo) and bHi > bLo
        sigRes50  := f_fibPrice(false, bHi, bLo, 0.5)
        sigRes618 := f_fibPrice(false, bHi, bLo, 0.618)
        sigRes65  := f_fibPrice(false, bHi, bLo, 0.65)
        sigRes786 := f_fibPrice(false, bHi, bLo, 0.786)
if na(sigSup786) and not na(msHighBar)
    int bHiB = msHighBar
    [bLo, bLoB] = f_findLegLow(math.max(0, bHiB - effFibLegLook), bHiB)
    [bHi, _bHiB2] = f_findLegHigh(bLoB, bHiB)
    if not na(bHi) and not na(bLo) and bHi > bLo
        sigSup50  := f_fibPrice(true, bHi, bLo, 0.5)
        sigSup618 := f_fibPrice(true, bHi, bLo, 0.618)
        sigSup65  := f_fibPrice(true, bHi, bLo, 0.65)
        sigSup786 := f_fibPrice(true, bHi, bLo, 0.786)

// ── Down-leg support Fibs (TV-style: 0.786 / 0.65 near swing low) ──
float sigDn786 = na
float sigDn65  = na
float sigDn618 = na
if resFibOk
    sigDn786 := f_fibFromHigh(resFibHi, resFibLo, 0.786)
    sigDn65  := f_fibFromHigh(resFibHi, resFibLo, 0.65)
    sigDn618 := f_fibFromHigh(resFibHi, resFibLo, 0.618)
if na(sigDn786) and not na(msLowBar)
    int bLoB2 = msLowBar
    [bHi2, bHiB2] = f_findLegHigh(math.max(0, bLoB2 - effFibLegLook), bLoB2)
    [bLo2, _bLoB3] = f_findLegLow(bHiB2, bLoB2)
    if not na(bHi2) and not na(bLo2) and bHi2 > bLo2
        sigDn786 := f_fibFromHigh(bHi2, bLo2, 0.786)
        sigDn65  := f_fibFromHigh(bHi2, bLo2, 0.65)
        sigDn618 := f_fibFromHigh(bHi2, bLo2, 0.618)

bool structBull = not na(msHigh) and close > msHigh    // break of structure up
bool structBear = not na(msLow)  and close < msLow     // break of structure down
bool liqSweepBull = not na(msLow)  and low  < msLow  and close > msLow
bool liqSweepBear = not na(msHigh) and high > msHigh and close < msHigh

// Volume money-flow read (volume-weighted candle-body momentum) — used by the
// stricter Strong confluence and the dashboard / combined alert.
float mfBody    = (high - low) != 0 ? ((close - open) / (high - low)) * volume : 0.0
float mfBodyAvg = ta.sma(mfBody, effMfBodyLen)
float mfVolAvg  = ta.sma(volume, 14)
float mfNorm    = mfVolAvg != 0 ? mfBodyAvg / mfVolAvg * 100 : 0.0
bool  mfIn      = mfNorm >= 0
bool  mfOut     = mfNorm < 0

// Flux Wave momentum direction (rising/falling) as an extra confirmation leg

// ════════════════════════ ⑤ ORACLE ANALYSIS (OCO-style scoring) ════════════
// Four pillars (0–25 each → 0–100 total), like the OCO app's multi-factor AI read:
//   Oscillator · Anchored VWAP · Heikin Ashi · Market Structure
// STRONG = high total score + every pillar above minimum + core trigger.
// Normal = decent score but below STRONG bar (OFF by default).

var int lastSigBar = na
var int lastSigDir = na
int barsSinceSig = na(lastSigBar) ? 9999 : bar_index - lastSigBar

// Core trigger — HA gate + optional thrust filter
bool haGateBuy  = haTrendBuy and haThrustBuy
bool haGateSell = haTrendSell and haThrustSell

bool fwRising = fwPrimary > fwPrimary[1]
bool fwFalling = fwPrimary < fwPrimary[1]
int  barsSinceCrossUp = ta.barssince(fwCrossUp)
int  barsSinceCrossDn = ta.barssince(fwCrossDn)
int  barsSinceOS = ta.barssince(fwSignal <= fwOS)
int  barsSinceOB = ta.barssince(fwSignal >= fwOB)
bool fwRecentCrossUp = effFwTrigBars > 0 and barsSinceCrossUp <= effFwTrigBars
bool fwRecentCrossDn = effFwTrigBars > 0 and barsSinceCrossDn <= effFwTrigBars
// Flux Wave momentum shift — cross in OB/OS zone or major divergence (regular + hidden)
bool fluxMomBuy  = (fwCrossUp and (fwInOS or barsSinceOS <= effOscZoneBars)) or bullDivActive or hiddenBullDiv
bool fluxMomSell = (fwCrossDn and (fwInOB or barsSinceOB <= effOscZoneBars)) or bearDiv or hiddenBearDiv
bool fwTrigBuy  = fluxMomBuy or (effFwTrigBars > 0 and fwRecentCrossUp and fwBull and fwRising and fwSignal <= effZoneBuyMax)
bool fwTrigSell = fluxMomSell or (effFwTrigBars > 0 and fwRecentCrossDn and fwBear and fwFalling and fwSignal >= effZoneSellMin)
bool momOkBuy   = fluxMomBuy or (effFwTrigBars > 0 and fwRecentCrossUp and fwBull and fwRising)
bool momOkSell  = fluxMomSell or (effFwTrigBars > 0 and fwRecentCrossDn and fwBear and fwFalling)
int engBullCnt = (oscMom > 0 ? 1 : 0) + (oscVwap > 0 ? 1 : 0) + (oscMf > 0 ? 1 : 0)
int engBearCnt = (oscMom < 0 ? 1 : 0) + (oscVwap < 0 ? 1 : 0) + (oscMf < 0 ? 1 : 0)

// ── Fib rejection · wave rollover · MF shift (reversal confluence) ──
float sigFibTol = math.max(close, syminfo.mintick) * (vwapTouchPct / 100.0)
bool fibTouchRes65  = not na(sigRes65)  and high >= sigRes65  - sigFibTol and low <= sigRes65  + sigFibTol
bool fibTouchRes618 = not na(sigRes618) and high >= sigRes618 - sigFibTol and low <= sigRes618 + sigFibTol
bool fibTouchRes786 = not na(sigRes786) and high >= sigRes786 - sigFibTol and low <= sigRes786 + sigFibTol
bool fibRejRes65    = fibTouchRes65  and close < sigRes65
bool fibRejRes618   = fibTouchRes618 and close < sigRes618
bool fibRejRes786   = fibTouchRes786 and close < sigRes786
bool fibTouchSup65  = not na(sigSup65)  and low <= sigSup65  + sigFibTol and high >= sigSup65  - sigFibTol
bool fibTouchSup618 = not na(sigSup618) and low <= sigSup618 + sigFibTol and high >= sigSup618 - sigFibTol
bool fibTouchSup786 = not na(sigSup786) and low <= sigSup786 + sigFibTol and high >= sigSup786 - sigFibTol
bool fibRejSup65    = fibTouchSup65  and close > sigSup65
bool fibRejSup618   = fibTouchSup618 and close > sigSup618
bool fibRejSup786   = fibTouchSup786 and close > sigSup786
// Down-leg support bounces (symmetric to resistance rejections on bear moves)
bool fibTouchDn786  = not na(sigDn786) and low <= sigDn786 + sigFibTol and high >= sigDn786 - sigFibTol
bool fibTouchDn65   = not na(sigDn65)  and low <= sigDn65  + sigFibTol and high >= sigDn65  - sigFibTol
bool fibRejDn786    = fibTouchDn786 and close > sigDn786
bool fibRejDn65     = fibTouchDn65  and close > sigDn65
bool fibKeyRejSell  = fibRejRes65 or fibRejRes618 or fibRejRes786
bool fibKeyRejBuy   = fibRejSup65 or fibRejSup618 or fibRejSup786 or fibRejDn786 or fibRejDn65
bool fibSupDeep     = fibRejDn786 or fibRejDn65 or fibRejSup786 or fibRejSup65
// Major Fib keys for god-tier dots + reversal STRONG (0.618 / 0.786 only)
bool fibMajorBuy    = fibRejDn786 or fibRejSup786 or fibRejSup618
bool fibMajorSell   = fibRejRes618 or fibRejRes786 or fibRejRes65
bool fibTouchMajorBuy  = fibMajorBuy or fibTouchDn786 or fibTouchSup786 or fibTouchSup618
bool fibTouchMajorSell = fibMajorSell or fibTouchRes618 or fibTouchRes786
bool fibNearStructLow  = not na(msLow)  and low <= msLow + sigFibTol * 2 and close >= msLow
bool fibNearStructHigh = not na(msHigh) and high >= msHigh - sigFibTol * 2 and close <= msHigh
bool mfShiftBear    = mfOut and (mfIn[1] or mfIn[2])
bool mfShiftBull    = mfIn and (mfOut[1] or mfOut[2])
bool mfShiftStrongBull = mfShiftBull and mfNorm > mfNorm[1] and oscMf > oscMf[1] and oscMf[1] <= 0
bool mfShiftStrongBear = mfShiftBear and mfNorm < mfNorm[1] and oscMf < oscMf[1] and oscMf[1] >= 0
bool bullDivElite   = bullDiv and (fwInOS or fwSignal <= fwOS2)
bool bearDivElite   = bearDiv and (fwInOB or fwSignal >= fwOB2)
int engBearPrev = (oscMom[1] > 0 ? 1 : 0) + (oscVwap[1] > 0 ? 1 : 0) + (oscMf[1] > 0 ? 1 : 0)
int engBullPrev = (oscMom[1] < 0 ? 1 : 0) + (oscVwap[1] < 0 ? 1 : 0) + (oscMf[1] < 0 ? 1 : 0)
bool waveRollBear   = engBearCnt >= 2 and fwBear and fwFalling and (fwCrossDn or engBearCnt > engBearPrev or fwPrimary < fwPrimary[2])
bool waveRollBull   = engBullCnt >= 2 and fwBull and fwRising and (fwCrossUp or engBullCnt > engBullPrev or fwPrimary > fwPrimary[2])
bool revTripleSell  = sigFibRev and fibMajorSell and waveRollBear and mfShiftBear and (bearDivElite or bearDiv or hiddenBearDiv or fwInOB)
bool revTripleBuy   = sigFibRev and fibMajorBuy and waveRollBull and mfShiftBull and (bullDivElite or bullDivActive or fwInOS)
// Confluence score helper only — NOT a standalone STRONG path (prevents loose reversal fires)
bool revConfluenceBuy = fibSupDeep and bullDivActive and waveRollBull and mfShiftBull and fibMajorBuy
int fibBonOscSell   = fibKeyRejSell ? (waveRollBear ? 6 : 3) + (revTripleSell ? 4 : 0) : 0
int fibBonOscBuy    = fibKeyRejBuy  ? (waveRollBull ? 6 : 3) + (revTripleBuy  ? 4 : 0) : 0
int fibBonStrSell   = mfShiftBear and fibKeyRejSell ? 5 : 0
int fibBonStrBuy    = (mfShiftBull or mfIn) and fibSupDeep ? 5 : mfShiftBull and fibKeyRejBuy ? 5 : 0
int revBuyBon       = revConfluenceBuy ? (fibRejDn786 or fibRejSup786 ? 6 : 4) + (bullDiv ? 4 : bullDivRecent ? 2 : 0) + (waveRollBull ? 3 : 0) + (mfShiftBull ? 3 : 0) : 0

bool legFwbull = fwTrigBuy and haGateBuy
bool legFwbear = fwTrigSell and haGateSell
bool legVWAPbull = not sigUseVWAP or priceAboveAV or vwapTestUp
bool legVWAPbear = not sigUseVWAP or priceBelowAV or vwapTestDn
bool legTrendUp  = not sigUseTrend or trendUp
bool legTrendDn  = not sigUseTrend or trendDn

// ── Pillar scores (buy direction) — OCO AI-style multi-factor read ──
int pOscBuy  = (fwBull ? 6 : 0) + (oscAllBull ? 8 : 0) + ((fwCrossUp or bullDivActive or hiddenBullDiv) ? 6 : 0) + (not fwInOB ? 5 : 0) + (fwRising and fwBull ? 3 : 0) + (hiddenBullDiv ? 4 : 0)
int pVwapBuy = (priceAboveAV ? 8 : 0) + (vwapTestUp ? 6 : 0) + (aboveDaily ? 6 : 0) + (abovePday ? 5 : 0)
int pHaBuy   = not haOn ? 14 : (haBull ? 8 : 0) + (haRun >= effHaMinRun ? 7 : 0) + (haBodyR >= haMinBody ? 5 : 0) + (haWickRejBuy ? 5 : 0) + (haStrongBull ? 3 : 0)
int pStrBuy  = (trendUp ? 7 : 0) + (structBull ? 8 : 0) + (liqSweepBull ? 5 : 0) + (mfIn ? 5 : 0)
int oracleBuy = pOscBuy + pVwapBuy + pHaBuy + pStrBuy + fibBonOscBuy + fibBonStrBuy + revBuyBon

// ── Pillar scores (sell direction) ──
int pOscSell  = (fwBear ? 6 : 0) + (oscAllBear ? 8 : 0) + ((fwCrossDn or bearDiv or hiddenBearDiv) ? 6 : 0) + (not fwInOS ? 5 : 0) + (fwFalling and fwBear ? 3 : 0) + (hiddenBearDiv ? 4 : 0)
int pVwapSell = (priceBelowAV ? 8 : 0) + (vwapTestDn ? 6 : 0) + (belowDaily ? 6 : 0) + (belowPday ? 5 : 0)
int pHaSell   = not haOn ? 14 : (haBear ? 8 : 0) + (haRun <= -effHaMinRun ? 7 : 0) + (haBodyR >= haMinBody ? 5 : 0) + (haWickRejSell ? 5 : 0) + (haStrongBear ? 3 : 0)
int pStrSell  = (trendDn ? 7 : 0) + (structBear ? 8 : 0) + (liqSweepBear ? 5 : 0) + (mfOut ? 5 : 0)
int oracleSell = pOscSell + pVwapSell + pHaSell + pStrSell + fibBonOscSell + fibBonStrSell

// Directional Oracle score (whichever side is stronger)
int oracleScore = oracleBuy >= oracleSell ? oracleBuy : oracleSell
bool biasBuy    = oracleBuy >= oracleSell

// STRONG gates — all pillars must contribute + optional MF/Osc hard filters
int pillBuyCnt  = (pOscBuy >= effPillarMin ? 1 : 0) + (pVwapBuy >= effPillarMin ? 1 : 0) + (pHaBuy >= effPillarMin ? 1 : 0) + (pStrBuy >= effPillarMin ? 1 : 0)
int pillSellCnt = (pOscSell >= effPillarMin ? 1 : 0) + (pVwapSell >= effPillarMin ? 1 : 0) + (pHaSell >= effPillarMin ? 1 : 0) + (pStrSell >= effPillarMin ? 1 : 0)
bool pillarsBuyOk  = pillBuyCnt >= effPillarsNeed and pOscBuy >= effPillarMin and pHaBuy >= effPillarMin
bool pillarsSellOk = pillSellCnt >= effPillarsNeed and pOscSell >= effPillarMin and pHaSell >= effPillarMin
bool mfOkBuy  = not sigStrongMF or mfIn
bool mfOkSell = not sigStrongMF or mfOut
bool oscOkBuy  = not sigStrongOsc or oscAllBull or (engBullCnt >= 3) or (revTripleBuy and engBullCnt >= 2 and waveRollBull)
bool oscOkSell = not sigStrongOsc or oscAllBear or (engBearCnt >= 3) or (revTripleSell and engBearCnt >= 2 and waveRollBear)

bool obHoldBull = f_obHoldBull(12) and haRun >= effHaMinRun
bool obHoldBear = f_obHoldBear(12) and haRun <= -effHaMinRun
bool structConvBuy  = structBull or liqSweepBull or obHoldBull
bool structConvSell = structBear or liqSweepBear or obHoldBear
bool structOkBuy    = not effReqStruct or structConvBuy
bool structOkSell   = not effReqStruct or structConvSell

bool zoneOkBuy  = fwSignal <= effZoneBuyMax and not fwInOB
bool zoneOkSell = fwSignal >= effZoneSellMin and not fwInOS

// ── Chop filter: ADX regime + BB squeeze + HA body + Flux Wave momentum ──
[diPlus, diMinus, adxVal] = ta.dmi(chopAdxLen, chopAdxLen)
float chopBbBasis = ta.sma(close, chopBbLen)
float chopBbDev   = chopBbMult * ta.stdev(close, chopBbLen)
float chopBbWidth = chopBbBasis > 0 ? (2.0 * chopBbDev / chopBbBasis) * 100.0 : 0.0
float chopBbWidthAvg = ta.sma(chopBbWidth, chopBbLen)
bool chopBbSqueeze = chopUseBB and chopBbWidthAvg > 0 and chopBbWidth < chopBbWidthAvg * chopBbSqueezePct
float chopFwSpread = math.abs(fwPrimary - fwSignal)
bool chopAdxTrend = adxVal >= chopAdxStrong
bool chopAdxMild  = adxVal >= chopAdxWeak and adxVal < chopAdxStrong
bool chopAdxBlock = adxVal < chopAdxWeak
int chopOracleBump = chopEnable ? (chopAdxMild ? chopMildScoreBonus : 0) + (chopBbSqueeze ? 3 : 0) : 0
int effStrongOracleBuy  = effOracleStrong + chopOracleBump
int effStrongOracleSell = effOracleStrong + chopOracleBump
bool chopHaOk = not chopEnable or not chopUseHaBody or haBodyR >= (chopAdxTrend ? haMinBody : chopHaBodyMin)
bool chopFwOk = not chopEnable or not chopUseFwSpread or chopFwSpread >= (chopAdxTrend ? effChopFwMinSpread * 0.5 : effChopFwMinSpread)
bool chopOkStrong = not chopEnable or (not chopAdxBlock and not chopBbSqueeze and chopHaOk and chopFwOk and chopAdxTrend)
bool chopOkNormal = not chopEnable or not chopAdxBlock
bool chopModeActive = chopEnable and (chopAdxBlock or chopAdxMild or chopBbSqueeze)
bool chopModeHard   = chopEnable and chopAdxBlock
string chopRegimeTxt = chopAdxBlock ? "Choppy" : chopAdxMild ? (chopBbSqueeze ? "Squeeze" : "Mild") : chopBbSqueeze ? "Squeeze" : "Trending"
// Regime gate (experimental, default OFF): CHOP blocks STRONG; RANGE = reverse-only; TREND = all
bool regimeAllowsStrongStd = not regimeGateStrong or chopAdxTrend
bool regimeAllowsStrongRev = not regimeGateStrong or not chopModeHard

// ── Scalp confluence gate (Flux Wave + MF + VWAP + pillar depth — anti-whipsaw) ──
bool scalpFwMfBuy   = fwBull and mfIn and (fwRising or fwCrossUp or waveRollBull)
bool scalpFwMfSell  = fwBear and mfOut and (fwFalling or fwCrossDn or waveRollBear)
bool scalpVwapBuy   = not effScalpStrictVwap or not sigUseVWAP or priceAboveAV or vwapTestUp
bool scalpVwapSell  = not effScalpStrictVwap or not sigUseVWAP or priceBelowAV or vwapTestDn
bool scalpWaveBuy   = not scalpActive or waveRollBull or fwCrossUp or (engBullCnt >= 2 and fwRising)
bool scalpWaveSell  = not scalpActive or waveRollBear or fwCrossDn or (engBearCnt >= 2 and fwFalling)
bool scalpConfluenceBuy  = not scalpActive or (scalpFwMfBuy and scalpVwapBuy and scalpWaveBuy and pillBuyCnt >= effPillarsNeed and pVwapBuy >= effPillarMin and pOscBuy >= effPillarMin and not (chopAdxBlock and chopBbSqueeze))
bool scalpConfluenceSell = not scalpActive or (scalpFwMfSell and scalpVwapSell and scalpWaveSell and pillSellCnt >= effPillarsNeed and pVwapSell >= effPillarMin and pOscSell >= effPillarMin and not (chopAdxBlock and chopBbSqueeze))

// Elite STRONG gates — god-tier multi-factor confluence; sell symmetric and strict
bool exhaustSignBuy  = revTripleBuy or (waveRollBull and mfShiftBull and fibMajorBuy)
bool exhaustSignSell = revTripleSell or (waveRollBear and mfShiftBear and fibMajorSell)
bool eliteStrongBuyRev = revTripleBuy and engBullCnt >= 2 and waveRollBull and mfShiftBull
bool eliteStrongSellRev = revTripleSell and engBearCnt >= 2 and waveRollBear and mfShiftBear
bool eliteStrongBuy  = scalpActive ? (exhaustSignBuy and engBullCnt >= 2 and mfShiftBull) : (eliteStrongBuyRev or (engBullCnt >= 3 and pVwapBuy >= effPillarMin and pStrBuy >= effPillarMin))
bool eliteStrongSell = scalpActive ? (exhaustSignSell and engBearCnt >= 2 and mfShiftBear) : (eliteStrongSellRev or (engBearCnt >= 3 and pVwapSell >= effPillarMin and pStrSell >= effPillarMin))
bool vwapKeyBuyEff   = vwapKeyBuy or (revTripleBuy and (vwapTestUp or liqSweepBull))
bool vwapKeySellEff = vwapKeySell or (revTripleSell and (vwapTestDn or liqSweepBear))
bool legTrendUpEff   = legTrendUp or (revTripleBuy and (liqSweepBull or waveRollBull))
bool legTrendDnEff   = legTrendDn or (revTripleSell and (liqSweepBear or waveRollBear))
// All four pillars + 2+ engines + wave/MF alignment for trend STRONG
bool godPillarsBuy   = pillBuyCnt >= effPillarsNeed and pOscBuy >= effPillarMin and pHaBuy >= effPillarMin and pVwapBuy >= effPillarMin and pStrBuy >= effPillarMin
bool godPillarsSell  = pillSellCnt >= effPillarsNeed and pOscSell >= effPillarMin and pHaSell >= effPillarMin and pVwapSell >= effPillarMin and pStrSell >= effPillarMin
bool godEngineBuy    = engBullCnt >= 2 and (oscAllBull or waveRollBull or revTripleBuy)
bool godEngineSell   = engBearCnt >= 2 and (oscAllBear or waveRollBear or revTripleSell)

// ═══════ FLUX SYNC — Chart context + oscillator pane momentum ═══════════════
// Both scripts use identical logic so overlay STRONG labels and oscillator dots confirm each other.
bool fluxPaneMomBuy  = (fwInOS or barsSinceOS <= effOscZoneBars + 2 or fwSignal <= fwOS2) and (waveRollBull or fwCrossUp or fluxMomBuy) and mfShiftStrongBull and engBullCnt >= 2
bool fluxPaneMomSell = (fwInOB or barsSinceOB <= effOscZoneBars + 2 or fwSignal >= fwOB2) and (waveRollBear or fwCrossDn or fluxMomSell) and mfShiftStrongBear and engBearCnt >= 2
bool fluxChartCtxBuy  = structConvBuy or fibTouchMajorBuy or liqSweepBull or revTripleBuy or (priceAboveAV and haGateBuy)
bool fluxChartCtxSell = structConvSell or fibTouchMajorSell or liqSweepBear or revTripleSell or (priceBelowAV and haGateSell)
bool fluxSyncBuy   = (fluxPaneMomBuy and fluxChartCtxBuy) or revTripleBuy
bool fluxSyncSell  = (fluxPaneMomSell and fluxChartCtxSell) or revTripleSell
bool fluxSyncOkBuy  = fluxSyncBuy or (oracleBuy >= effStrongOracleBuy + 4 and engBullCnt >= 3 and oscAllBull and chopOkStrong and waveRollBull)
bool fluxSyncOkSell = fluxSyncSell or (oracleSell >= effStrongOracleSell + 4 and engBearCnt >= 3 and oscAllBear and chopOkStrong and waveRollBear)

bool strongBuyStd  = sigEnable and haGateBuy and momOkBuy and fwTrigBuy and legVWAPbull and legTrendUpEff and vwapKeyBuyEff and godPillarsBuy and godEngineBuy and mfOkBuy and oscOkBuy and zoneOkBuy and chopOkStrong and scalpConfluenceBuy and eliteStrongBuy and fluxSyncOkBuy and (oracleBuy >= effStrongOracleBuy) and regimeAllowsStrongStd
bool strongSellStd = sigEnable and haGateSell and momOkSell and fwTrigSell and legVWAPbear and legTrendDnEff and vwapKeySellEff and godPillarsSell and godEngineSell and mfOkSell and oscOkSell and zoneOkSell and chopOkStrong and scalpConfluenceSell and eliteStrongSell and fluxSyncOkSell and (oracleSell >= effStrongOracleSell) and regimeAllowsStrongStd
int effRevOracleBuy  = math.max(62, effStrongOracleBuy - effRevOracleGap)
int effRevOracleSell = math.max(62, effStrongOracleSell - effRevOracleGap)
// Reversal STRONG — revTriple only (full Fib+Wave+MF); no loose confluence bypass
bool strongBuyRev  = sigEnable and revTripleBuy and haGateBuy and mfShiftBull and oscOkBuy and chopOkStrong and godPillarsBuy and pillBuyCnt >= 3 and oracleBuy >= effRevOracleBuy and bullDivActive and fluxSyncBuy and regimeAllowsStrongRev
bool strongSellRev = sigEnable and revTripleSell and haGateSell and mfShiftBear and oscOkSell and chopOkStrong and godPillarsSell and pillSellCnt >= 3 and oracleSell >= effRevOracleSell and (bearDivElite or bearDiv or fwInOB) and fluxSyncSell and regimeAllowsStrongRev
// ═══════ SWING TOP / BOTTOM reversal STRONG ═════════════════════════════════
// Arm: divergence or OS++/OB++ exhaustion at the major swing extreme.
// Fire: wave + engines turn, money flow improving, and price breaks the last few bars.
var float swBotLvl  = na
var int   swBotArm  = na
var float swBotLock = na
var float swTopLvl  = na
var int   swTopArm  = na
var float swTopLock = na
int   swWin      = effDivPivR + 4
float swRecentLo = ta.lowest(low, swWin)
float swRecentHi = ta.highest(high, swWin)
float swAtr      = ta.atr(14)
bool  swAtLow    = swRecentLo <= ta.lowest(low, sigSwingLen) + swAtr * sigSwingTol
bool  swAtHigh   = swRecentHi >= ta.highest(high, sigSwingLen) - swAtr * sigSwingTol
bool  swCtxBuy   = ta.highest(fibMajorBuy or liqSweepBull or vwapTestUp ? 1 : 0, swWin) > 0
bool  swCtxSell  = ta.highest(fibMajorSell or liqSweepBear or vwapTestDn ? 1 : 0, swWin) > 0
bool  swExhBot   = ta.lowest(fwSignal, swWin) <= fwOS2 and swCtxBuy
bool  swExhTop   = ta.highest(fwSignal, swWin) >= fwOB2 and swCtxSell
float swWaveLoNow  = ta.lowest(fwSignal, swWin)
float swWaveHiNow  = ta.highest(fwSignal, swWin)
float swWaveLoLeg  = ta.lowest(fwSignal, sigSwingLegLen)
float swWaveHiLeg  = ta.highest(fwSignal, sigSwingLegLen)
bool  swLegDivBot  = swWaveLoLeg <= fwOS * sigSwingDivDepth and swWaveLoNow >= swWaveLoLeg + sigSwingDivGap
bool  swLegDivTop  = swWaveHiLeg >= fwOB * sigSwingDivDepth and swWaveHiNow <= swWaveHiLeg - sigSwingDivGap
bool  swDivBot   = swLegDivBot or (bullDivActive and not na(lastBullDivBar) and bar_index - lastBullDivBar <= swWin)
bool  swDivTop   = swLegDivTop or (bearDivActive and not na(lastBearDivBar) and bar_index - lastBearDivBar <= swWin)

if not na(swBotArm) and (low < swBotLvl - swAtr * 0.10 or bar_index - swBotArm > sigSwingConf)
    swBotArm := na
if not na(swTopArm) and (high > swTopLvl + swAtr * 0.10 or bar_index - swTopArm > sigSwingConf)
    swTopArm := na
if not na(swBotLock) and high - swBotLock >= swAtr * sigSwingLock
    swBotLock := na
if not na(swTopLock) and swTopLock - low >= swAtr * sigSwingLock
    swTopLock := na

if sigSwingRev and (swDivBot or swExhBot) and swAtLow and (na(swBotLock) or swRecentLo < swBotLock)
    swBotLvl := swRecentLo
    swBotArm := bar_index
if sigSwingRev and (swDivTop or swExhTop) and swAtHigh and (na(swTopLock) or swRecentHi > swTopLock)
    swTopLvl := swRecentHi
    swTopArm := bar_index

bool swBotMom = fwBull and engBullCnt >= 2 and (fwCrossUp or fwRising) and (mfIn or mfNorm > mfNorm[3])
bool swTopMom = fwBear and engBearCnt >= 2 and (fwCrossDn or fwFalling) and (mfOut or mfNorm < mfNorm[3])
float swHiC     = ta.highest(close, sigSwingBreak)
float swHiH     = ta.highest(high, sigSwingBreak)
float swLoC     = ta.lowest(close, sigSwingBreak)
float swLoL     = ta.lowest(low, sigSwingBreak)
float swBrkUp   = sigSwingBrkClose ? swHiC[1] : swHiH[1]
float swBrkDn   = sigSwingBrkClose ? swLoC[1] : swLoL[1]
bool strongBuySwing  = sigEnable and not na(swBotArm) and swBotMom and close > swBrkUp
bool swUpThrust      = sigSwingUpBlk and close > trendEMA and trendEMA > trendEMA[5] and adxVal >= sigSwingUpAdx and diPlus > diMinus
bool strongSellSwing = sigEnable and not na(swTopArm) and swTopMom and close < swBrkDn and not swUpThrust
if strongBuySwing
    swBotLock := swBotLvl
    swTopLock := na
    swBotArm  := na
if strongSellSwing
    swTopLock := swTopLvl
    swBotLock := na
    swTopArm  := na

bool strongBuy  = strongBuyStd or strongBuyRev or strongBuySwing
bool strongSell = strongSellStd or strongSellRev or strongSellSwing

int normBuyCnt  = (pOscBuy >= effPillarMinNorm ? 1 : 0) + (pVwapBuy >= effPillarMinNorm ? 1 : 0) + (pHaBuy >= effPillarMinNorm ? 1 : 0) + (pStrBuy >= effPillarMinNorm ? 1 : 0)
int normSellCnt = (pOscSell >= effPillarMinNorm ? 1 : 0) + (pVwapSell >= effPillarMinNorm ? 1 : 0) + (pHaSell >= effPillarMinNorm ? 1 : 0) + (pStrSell >= effPillarMinNorm ? 1 : 0)
bool normalBuy  = sigEnable and haGateBuy and momOkBuy and fwBull and legVWAPbull and legTrendUp and mfOkBuy and chopOkNormal and normBuyCnt >= 3 and pHaBuy >= effPillarMinNorm and (oracleBuy >= effOracleNormal) and (oracleBuy < effStrongOracleBuy) and zoneOkBuy and not strongBuy
bool normalSell = sigEnable and haGateSell and momOkSell and fwBear and legVWAPbear and legTrendDn and mfOkSell and chopOkNormal and normSellCnt >= 3 and pHaSell >= effPillarMinNorm and (oracleSell >= effOracleNormal) and (oracleSell < effStrongOracleSell) and zoneOkSell and not strongSell

// Dynamic cooldown — shorter after opposite-direction reversal setup (sell → support buy)
bool oppRevBuyCd  = lastSigDir == -1 and revTripleBuy
int  effCdNow     = oppRevBuyCd ? effRevCdBars : effCooldown
bool cooldownOK   = na(lastSigBar) or barsSinceSig >= effCdNow

// Resolve precedence (strong overrides normal) + cooldown throttle
// Opposite-signal guard — no flip-flop right after a call unless its bar is invalidated
var int   oppBuyBar   = na
var float oppBuyLow   = na
var int   oppSellBar  = na
var float oppSellHigh = na
bool oppBlockSell = sigOppGuard and nz(lastSigDir) == 1 and not na(oppBuyBar) and bar_index - oppBuyBar <= sigOppGuardBars and close >= oppBuyLow
bool oppBlockBuy  = sigOppGuard and nz(lastSigDir) == -1 and not na(oppSellBar) and bar_index - oppSellBar <= sigOppGuardBars and close <= oppSellHigh
bool fireStrongBuy  = showStrong and strongBuy  and (cooldownOK or (strongBuySwing and nz(lastSigDir) != 1)) and not oppBlockBuy
bool fireStrongSell = showStrong and strongSell and (cooldownOK or (strongSellSwing and nz(lastSigDir) != -1)) and not oppBlockSell
bool fireNormalBuy  = effShowNormal and normalBuy  and not strongBuy  and cooldownOK
bool fireNormalSell = effShowNormal and normalSell and not strongSell and cooldownOK

bool anyBuy  = fireStrongBuy  or fireNormalBuy
bool anySell = fireStrongSell or fireNormalSell

if anyBuy or anySell
    lastSigBar := bar_index
    lastSigDir := anyBuy ? 1 : -1
if fireStrongBuy
    oppBuyBar := bar_index
    oppBuyLow := low
if fireStrongSell
    oppSellBar  := bar_index
    oppSellHigh := high

// ═══════════════════════ EXIT ENGINE (after STRONG signals) ════════════════
// Virtual position tracker — unified trail + HA + opposite STRONG exits.
var int   sigPos       = 0
var float sigEntryPx   = na
var float sigRDist     = na
var float sigStop      = na
var int   sigEntryBar  = na
var bool  sigTrailOn   = false
var float sigTrailL    = na
var float sigTrailS    = na
var float sigSwingL    = na
var float sigSwingS    = na
float sigAtr = ta.atr(exitAtrLen)
int   sigBarsIn = na(sigEntryBar) ? 0 : bar_index - sigEntryBar
float sigUnrealRL = sigPos == 1 and sigRDist > 0 ? (close - sigEntryPx) / sigRDist : 0.0
float sigUnrealRS = sigPos == (-1) and sigRDist > 0 ? (sigEntryPx - close) / sigRDist : 0.0

if fireStrongBuy
    sigPos := 1
    sigEntryPx := close
    sigRDist := sigAtr * exitSlMult
    sigEntryBar := bar_index
    sigTrailOn := false
    sigStop := close - sigRDist
    sigTrailL := na
    sigSwingL := na
else if fireStrongSell
    sigPos := -1
    sigEntryPx := close
    sigRDist := sigAtr * exitSlMult
    sigEntryBar := bar_index
    sigTrailOn := false
    sigStop := close + sigRDist
    sigTrailS := na
    sigSwingS := na

// Breakeven after 1R · partial lock at 2R (let winners run with protection)
if sigPos == 1 and sigUnrealRL >= 1.0
    sigStop := math.max(sigStop, sigEntryPx)
if sigPos == (-1) and sigUnrealRS >= 1.0
    sigStop := math.min(sigStop, sigEntryPx)
if sigPos == 1 and sigRDist > 0 and sigUnrealRL >= 2.0
    sigStop := math.max(sigStop, sigEntryPx + sigRDist * 0.5)
if sigPos == (-1) and sigRDist > 0 and sigUnrealRS >= 2.0
    sigStop := math.min(sigStop, sigEntryPx - sigRDist * 0.5)

float sigSwingLowRef  = ta.lowest(low, effSwingLen)
float sigSwingHighRef = ta.highest(high, effSwingLen)

if sigPos == 1
    if sigUnrealRL >= effTrailStartR
        sigTrailOn := true
    if sigTrailOn
        if exitATRtrail
            float atrCand = high - sigAtr * effTrailMult
            sigTrailL := na(sigTrailL) ? atrCand : math.max(sigTrailL, atrCand)
            sigStop := math.max(sigStop, sigTrailL)
        if exitSwing
            float swCand = sigSwingLowRef - sigAtr * exitSwingBuf
            sigSwingL := na(sigSwingL) ? swCand : math.max(sigSwingL, swCand)
            sigStop := math.max(sigStop, sigSwingL)

if sigPos == (-1)
    if sigUnrealRS >= effTrailStartR
        sigTrailOn := true
    if sigTrailOn
        if exitATRtrail
            float atrCand = low + sigAtr * effTrailMult
            sigTrailS := na(sigTrailS) ? atrCand : math.min(sigTrailS, atrCand)
            sigStop := math.min(sigStop, sigTrailS)
        if exitSwing
            float swCand = sigSwingHighRef + sigAtr * exitSwingBuf
            sigSwingS := na(sigSwingS) ? swCand : math.min(sigSwingS, swCand)
            sigStop := math.min(sigStop, sigSwingS)

bool sigGraceOK = sigBarsIn >= effExitMinBars
bool sigOppGraceOK = sigBarsIn >= effExitOppMin
bool sigHaRevLong  = haOn and haBear and haRun <= -effExitHaFlipRun and haBodyR >= effExitHaMinBody
bool sigHaRevShort = haOn and haBull and haRun >= effExitHaFlipRun and haBodyR >= effExitHaMinBody

bool sigExitLongManual = false
bool sigExitShortManual = false
bool sigExitLongStop = false
bool sigExitShortStop = false

if sigPos == 1 and sigGraceOK
    if exitStrongOpp and sigOppGraceOK and fireStrongSell and sigHaRevLong
        sigExitLongManual := true
    else if effExitHA and sigHaRevLong and (sigTrailOn or sigUnrealRL >= effExitHaMinR)
        sigExitLongManual := true

if sigPos == (-1) and sigGraceOK
    if exitStrongOpp and sigOppGraceOK and fireStrongBuy and sigHaRevShort
        sigExitShortManual := true
    else if effExitHA and sigHaRevShort and (sigTrailOn or sigUnrealRS >= effExitHaMinR)
        sigExitShortManual := true

if sigPos == 1 and not na(sigStop) and low <= sigStop and (na(sigStop[1]) or low[1] > sigStop[1])
    sigExitLongStop := true
if sigPos == (-1) and not na(sigStop) and high >= sigStop and (na(sigStop[1]) or high[1] < sigStop[1])
    sigExitShortStop := true

bool sigExitLong  = sigExitLongManual
bool sigExitShort = sigExitShortManual
bool sigClosedLong  = sigExitLongManual or sigExitLongStop
bool sigClosedShort = sigExitShortManual or sigExitShortStop

if sigClosedLong
    sigPos := 0
    sigEntryPx := na
    sigRDist := na
    sigStop := na
    sigEntryBar := na
    sigTrailOn := false
    sigTrailL := na
    sigSwingL := na
if sigClosedShort
    sigPos := 0
    sigEntryPx := na
    sigRDist := na
    sigStop := na
    sigEntryBar := na
    sigTrailOn := false
    sigTrailS := na
    sigSwingS := na

// ═════════════════════════════ PLOTTING ═════════════════════════════════════

// ── Fibonacci retracements (drawn after swing anchors are known) ──────────────
if showRecentFibs and barstate.islast
    for ln in fibLines
        line.delete(ln)
    for lb in fibLabels
        label.delete(lb)
    array.clear(fibLines)
    array.clear(fibLabels)
    // Live bootstrap on chart load (before next pivot fires)
    float drawSupHi = supFibHi
    int   drawSupHiB = supFibHiBar
    float drawSupLo = supFibLo
    int   drawSupLoB = supFibLoBar
    bool  drawSupOk = supFibOk
    if not drawSupOk and not na(msHighBar)
        int hiB = msHighBar
        [bLo, bLoB] = f_findLegLow(math.max(0, hiB - effFibLegLook), hiB)
        [bHi, bHiB] = f_findLegHigh(bLoB, hiB)
        if not na(bLo) and not na(bHi) and bHi > bLo and bHiB > bLoB
            drawSupHi := bHi
            drawSupHiB := bHiB
            drawSupLo := bLo
            drawSupLoB := bLoB
            drawSupOk := true
    float drawResHi = resFibHi
    int   drawResHiB = resFibHiBar
    float drawResLo = resFibLo
    int   drawResLoB = resFibLoBar
    bool  drawResOk = resFibOk
    if not drawResOk and not na(msLowBar)
        int loB = msLowBar
        [bHi, bHiB] = f_findLegHigh(math.max(0, loB - effFibLegLook), loB)
        [bLo, bLoB] = f_findLegLow(bHiB, loB)
        if not na(bHi) and not na(bLo) and bHi > bLo and loB > bHiB
            drawResHi := bHi
            drawResHiB := bHiB
            drawResLo := bLo
            drawResLoB := bLoB
            drawResOk := true
    // Support — locked up leg: lowest low → highest high (pullback zones)
    if drawSupOk and drawSupHi > drawSupLo and drawSupHiB > drawSupLoB
        f_drawFibSet(true, drawSupLoB, drawSupHi, drawSupLo, 0.82)
    // Resistance — locked down leg: highest high → lowest low (bounce zones)
    if drawResOk and drawResHi > drawResLo and drawResLoB > drawResHiB
        f_drawFibSet(false, drawResHiB, drawResHi, drawResLo, 0.68)

// ── Premium chop zone visuals (display only — zero signal impact) ──
int chopStrengthPct = chopEnable and chopModeActive ? int(math.min(100, math.max(0, (chopAdxStrong - adxVal) / chopAdxStrong * 65.0 + (chopAdxBlock ? 28.0 : chopAdxMild ? 12.0 : 0.0) + (chopBbSqueeze ? 14.0 : 0.0)))) : chopEnable ? int(math.max(0, (chopAdxStrong - adxVal) / chopAdxStrong * 25.0)) : 0
string chopLblTxt   = chopModeHard ? "CHOP" : "RANGE"
string chopMeterBar = f_chopBar(chopStrengthPct)
bool chopShow       = visChopBg and chopModeActive
bool chopInnerGlow  = visChopGlow and chopShow and bar_index % 20 < 10
bool chopEdgeShim   = visChopGlow and chopShow and (bar_index % 32 == 0 or bar_index % 32 == 31)
int chopBaseTrans   = chopModeHard ? 94 : chopBbSqueeze ? 95 : 96
int chopMistTrans   = chopModeHard ? 95 : 96
int chopVeilTrans   = chopModeHard ? 96 : 97
bgcolor(chopShow ? color.new(C_CHOP_SLATE, chopBaseTrans) : na, title="Chop slate base")
bgcolor(chopShow ? color.new(C_CHOP_MIST, chopMistTrans) : na, title="Chop mist gradient")
bgcolor(chopShow ? color.new(C_CHOP_PURPLE, chopVeilTrans) : na, title="Chop purple veil")
bgcolor(chopInnerGlow ? color.new(C_CHOP_GLOW, 99) : na, title="Chop inner glow")
bgcolor(chopEdgeShim ? color.new(C_CHOP_GLOW, 98) : na, title="Chop edge border")

var table chopTag = na
if barstate.islast
    if not na(chopTag)
        table.delete(chopTag)
    bool showFloatTag = visChopLabel and chopModeActive and (not dashEnable or dashPos != "Top Right")
    if showFloatTag
        color tagBg = color.new(#141820, 82)
        chopTag := table.new(position.top_right, 1, 1, bgcolor=tagBg, border_color=color.new(C_CHOP_GLOW, 88), border_width=1, frame_color=color.new(C_CHOP_GLOW, 93), frame_width=1)
        table.cell(chopTag, 0, 0, chopLblTxt, text_color=f_chopTagTxtClr(chopStrengthPct), text_size=size.tiny, text_halign=text.align_center, bgcolor=tagBg)

// Trend EMA (subtle purple ribbon)
plot(sigEnable and sigUseTrend ? trendEMA : na, "Trend EMA", color=color.new(C_PURPLE, 62), linewidth=1)

// Signal markers — Strong = clean labelled tag, Normal = small clean triangle.
// text= must be a const string, so the visSignalText toggle gates via condition.
// Premium STRONG markers with optional gold-cyan halo
plotshape(fireStrongBuy and visStrongGlow,  title="Strong Buy Halo",  style=shape.circle, location=location.belowbar, color=color.new(C_GOLD, 78), size=size.small)
plotshape(fireStrongSell and visStrongGlow, title="Strong Sell Halo", style=shape.circle, location=location.abovebar, color=color.new(C_GOLD, 78), size=size.small)
plotshape(fireStrongBuy and visSignalText,       title="Strong Buy (text)",  style=shape.labelup,   location=location.belowbar, color=C_BULL, textcolor=color.new(#031014, 0), text="FLUX BUY",  size=size.small)
plotshape(fireStrongBuy and not visSignalText,   title="Strong Buy",         style=shape.labelup,   location=location.belowbar, color=C_BULL, textcolor=color.new(#031014, 0), size=size.tiny)
plotshape(fireStrongSell and visSignalText,      title="Strong Sell (text)", style=shape.labeldown, location=location.abovebar, color=C_BEAR, textcolor=color.white, text="FLUX SELL", size=size.small)
plotshape(fireStrongSell and not visSignalText,  title="Strong Sell",        style=shape.labeldown, location=location.abovebar, color=C_BEAR, textcolor=color.white, size=size.tiny)

// Clean exit labels — elegant slate-gold accent
plotshape(showExits and sigExitLong,  title="Exit Long",  style=shape.labeldown, location=location.abovebar, color=color.new(#1A2235, 0), textcolor=C_GOLD, text="EXIT LONG",  size=size.tiny)
plotshape(showExits and sigExitShort, title="Exit Short", style=shape.labelup,   location=location.belowbar, color=color.new(#1A2235, 0), textcolor=C_GOLD, text="EXIT SHORT", size=size.tiny)

// Trailing stop hints (optional — off in clean chart mode)
bool showTrailVis = visShowTrails and not visCleanChart
plot(showTrailVis and sigPos == 1 and exitATRtrail ? sigTrailL : na, "Sig ATR Trail L", color=color.new(C_ACCENT, 55), style=plot.style_linebr, linewidth=1)
plot(showTrailVis and sigPos == (-1) and exitATRtrail ? sigTrailS : na, "Sig ATR Trail S", color=color.new(C_ACCENT, 55), style=plot.style_linebr, linewidth=1)
plot(showTrailVis and sigPos == 1 and exitSwing ? sigSwingL : na, "Sig Swing L", color=color.new(C_PURPLE, 60), style=plot.style_linebr, linewidth=1)
plot(showTrailVis and sigPos == (-1) and exitSwing ? sigSwingS : na, "Sig Swing S", color=color.new(C_PURPLE, 60), style=plot.style_linebr, linewidth=1)

// Optional Flux Wave momentum glow on price (very subtle premium hint)
plot(showFwGlow and oscEnable ? trendEMA : na, "Flux Wave Glow", color=color.new(fwBull ? C_BULL : C_BEAR, 80), linewidth=3)

// Bar coloring by confluence state
color barCol = na
if visBarColor
    if strongBuy
        barCol := C_BULL
    else if strongSell
        barCol := C_BEAR
    else if fwBull and priceAboveAV
        barCol := C_BULL_DIM
    else if fwBear and priceBelowAV
        barCol := C_BEAR_DIM
barcolor(visBarColor ? barCol : na)

// ═════════════════════════════ FLUX READ STATE ════════════════════════════════
// Shared dashboard + JSON export (display-only; no signal logic changes)
int    fluxOracleScore = biasBuy ? oracleBuy : oracleSell
bool   fluxSetupReady = (biasBuy and oracleBuy >= effStrongOracleBuy - 4) or (not biasBuy and oracleSell >= effStrongOracleSell - 4)
string fluxEngTx = oscAllBull ? "3/3 ▲" : oscAllBear ? "3/3 ▼" : str.tostring(engBullCnt) + "/3"
color  fluxEngClr = oscAllBull ? C_BULL : oscAllBear ? C_BEAR : C_NEUTRAL
string fluxVwapTx = not vwapEnable or na(nearestVWAP) ? "—" : priceAboveAV ? "Above" : "Below"
color  fluxVwapClr = not vwapEnable or na(nearestVWAP) ? C_SUBTLE : priceAboveAV ? C_BULL : C_BEAR
string fluxTrendTx = haOn ? (haBull ? "HA Bull x" + str.tostring(haRun) : haBear ? "HA Bear x" + str.tostring(math.abs(haRun)) : "HA Neutral") : trendUp ? "Up" : "Down"
color  fluxTrendClr = haOn ? (haBull ? C_BULL : haBear ? C_BEAR : C_NEUTRAL) : trendUp ? C_BULL : C_BEAR
string fluxStructTx = structBull ? "BOS ↑" : structBear ? "BOS ↓" : "Range"
color  fluxStructClr = structBull ? C_BULL : structBear ? C_BEAR : C_NEUTRAL
string fluxMfTx = mfIn ? "Inflow" : "Outflow"
color  fluxMfClr = mfIn ? C_BULL : C_BEAR
string fluxSigTx = fireStrongBuy ? "FLUX BUY" : fireStrongSell ? "FLUX SELL" : fireNormalBuy ? "Buy" : fireNormalSell ? "Sell" : "Idle"
color  fluxSigClr = fireStrongBuy or fireNormalBuy ? C_BULL : fireStrongSell or fireNormalSell ? C_BEAR : C_NEUTRAL
string fluxTierTx = fireStrongBuy or fireStrongSell ? "PERMISSION" : fluxSyncBuy or fluxSyncSell ? "SYNCED" : fluxSetupReady ? "SETUP" : fluxOracleScore >= effOracleNormal ? "SOLID" : fluxOracleScore >= 35 ? "WATCH" : "—"
color  fluxTierClr = fireStrongBuy or fireStrongSell ? C_GOLD : fluxSyncBuy or fluxSyncSell ? C_BULL : fluxSetupReady ? C_ACCENT : fluxOracleScore >= effOracleNormal ? C_ACCENT : C_SUBTLE
string fluxRegime = chopModeHard ? "CHOP" : chopAdxTrend ? "TREND" : chopModeActive ? "RANGE" : "TRANSITION"
string fluxWaveState = fwCrossUp ? "bull_cross" : fwCrossDn ? "bear_cross" : fwBull ? "bull" : fwBear ? "bear" : "neutral"
string fluxOscZoneTx = fwInOB ? "Overbought" : fwInOS ? "Oversold" : "Neutral"
string fluxDvTx = hiddenBullDiv ? "H.Bull" : hiddenBearDiv ? "H.Bear" : bullDiv ? "Bullish" : bearDiv ? "Bearish" : bullDivRecent ? "Bull·Recent" : bearDivRecent ? "Bear·Recent" : "None"
string fluxNearestFib = fibRejRes786 ? "0.786_res" : fibRejRes618 ? "0.618_res" : fibRejRes65 ? "0.65_res" : fibRejSup786 ? "0.786_sup" : fibRejSup618 ? "0.618_sup" : fibRejSup65 ? "0.65_sup" : fibRejDn786 ? "0.786_dn" : fibRejDn65 ? "0.65_dn" : "none"
string fluxSetupState = fireStrongBuy or fireStrongSell ? "TAKE" : fluxSyncBuy or fluxSyncSell ? "SYNCED" : fluxSetupReady ? "WATCH" : chopModeHard ? "SKIP" : "IDLE"
string fluxEngExport = oscAllBull ? "3/3" : oscAllBear ? "0/3" : str.tostring(engBullCnt) + "/3"
string fluxVwapExport = fluxVwapTx == "—" ? "none" : fluxVwapTx
string fluxDvExport = fluxDvTx == "None" ? "none" : fluxDvTx
string fluxReadJson = "{\"v\":1,\"layer\":\"overlay\",\"sym\":" + f_jsonStr(syminfo.ticker) + ",\"tf\":" + f_jsonStr(timeframe.period) + ",\"ts\":" + str.tostring(time) + ",\"regime\":" + f_jsonStr(fluxRegime) + ",\"setup_state\":" + f_jsonStr(fluxSetupState) + ",\"oracle_score\":" + str.tostring(fluxOracleScore) + ",\"conviction_label\":" + f_jsonStr(fluxTierTx) + ",\"money_flow\":" + f_jsonStr(fluxMfTx) + ",\"engines\":" + f_jsonStr(fluxEngExport) + ",\"vwap_bias\":" + f_jsonStr(fluxVwapExport) + ",\"nearest_fib\":" + f_jsonStr(fluxNearestFib) + ",\"oscillator_zone\":" + f_jsonStr(fluxOscZoneTx) + ",\"flux_wave\":" + str.tostring(fwSignal, "#.##") + ",\"wave_state\":" + f_jsonStr(fluxWaveState) + ",\"divergence\":" + f_jsonStr(fluxDvExport) + ",\"structure\":" + f_jsonStr(fluxStructTx) + ",\"trend\":" + f_jsonStr(fluxTrendTx) + ",\"chop_strength\":" + str.tostring(chopStrengthPct) + ",\"strong_buy\":" + f_jsonBool(fireStrongBuy) + ",\"strong_sell\":" + f_jsonBool(fireStrongSell) + ",\"fluid_tf\":" + f_jsonBool(useFluidProf) + ",\"regime_gate\":" + f_jsonBool(regimeGateStrong) + "}"

// ═══════════════════════════════ DASHBOARD ══════════════════════════════════
// Clean two-column status panel: merged header, subtle row tints, minimal borders.
var table dash = na
if dashEnable and barstate.islast
    table.delete(dash)
    dash := table.new(f_dashPos(dashPos), 2, 10, bgcolor=C_PANEL, border_color=color.new(C_GRID, 30), border_width=1, frame_color=color.new(C_GOLD, 65), frame_width=1)

    txt = f_txtSize(dashSize)
    color rowA = color.new(C_PANEL, 0)
    color rowB = color.new(C_PANEL2, 0)

    // Header — premium gold-cyan accent + integrated chop tag when top-right
    string hdrRight = scalpActive ? "SCALP MODE ACTIVE" : chopModeActive and visChopLabel ? chopLblTxt + " · " + syminfo.ticker : syminfo.ticker
    color  hdrClr   = scalpActive ? C_BULL : chopModeActive and visChopLabel ? f_chopTagTxtClr(chopStrengthPct) : C_TEXT
    table.cell(dash, 0, 0, "◆ FLUX · WHERE", text_color=C_GOLD, text_size=txt, bgcolor=color.new(#0A0F1A, 0), text_halign=text.align_left)
    table.cell(dash, 1, 0, hdrRight + " ", text_color=hdrClr, text_size=txt, bgcolor=color.new(#0A0F1A, 0), text_halign=text.align_right)

    // Flux Wave triple-engine agreement
    string engTx   = fluxEngTx
    color  engClr  = fluxEngClr
    table.cell(dash, 0, 1, " Engines", text_color=C_SUBTLE, text_size=txt, bgcolor=rowA, text_halign=text.align_left)
    table.cell(dash, 1, 1, engTx + " ", text_color=engClr, text_size=txt, bgcolor=rowA, text_halign=text.align_right)

    // vs VWAP
    string vwTxt = fluxVwapTx
    color  vwClr = fluxVwapClr
    table.cell(dash, 0, 2, " vs VWAP", text_color=C_SUBTLE, text_size=txt, bgcolor=rowB, text_halign=text.align_left)
    table.cell(dash, 1, 2, vwTxt + " ", text_color=vwClr, text_size=txt, bgcolor=rowB, text_halign=text.align_right)

    // Trend / Heikin Ashi
    string trTxt = fluxTrendTx
    color  trClr = fluxTrendClr
    table.cell(dash, 0, 3, " Trend", text_color=C_SUBTLE, text_size=txt, bgcolor=rowA, text_halign=text.align_left)
    table.cell(dash, 1, 3, trTxt + " ", text_color=trClr, text_size=txt, bgcolor=rowA, text_halign=text.align_right)

    // Structure
    string stTxt = fluxStructTx
    color  stClr = fluxStructClr
    table.cell(dash, 0, 4, " Structure", text_color=C_SUBTLE, text_size=txt, bgcolor=rowB, text_halign=text.align_left)
    table.cell(dash, 1, 4, stTxt + " ", text_color=stClr, text_size=txt, bgcolor=rowB, text_halign=text.align_right)

    // Money Flow
    string mfTxt = fluxMfTx
    color  mfClr = fluxMfClr
    table.cell(dash, 0, 5, " Money Flow", text_color=C_SUBTLE, text_size=txt, bgcolor=rowA, text_halign=text.align_left)
    table.cell(dash, 1, 5, mfTxt + " ", text_color=mfClr, text_size=txt, bgcolor=rowA, text_halign=text.align_right)

    // Oracle Analysis score (OCO-style /100)
    int    orcVal = fluxOracleScore
    color  orcClr = orcVal >= effStrongOracleBuy ? (biasBuy ? C_BULL : C_BEAR) : orcVal >= effOracleNormal ? C_ACCENT : C_SUBTLE
    table.cell(dash, 0, 6, " Oracle Score", text_color=C_SUBTLE, text_size=txt, bgcolor=rowB, text_halign=text.align_left)
    table.cell(dash, 1, 6, str.tostring(orcVal) + "/100 ", text_color=orcClr, text_size=txt, bgcolor=rowB, text_halign=text.align_right)

    // Signal (highlighted)
    string sgTxt = fluxSigTx
    color  sgClr = fluxSigClr
    table.cell(dash, 0, 7, " Permission", text_color=C_TEXT, text_size=txt, bgcolor=color.new(sgClr, 80), text_halign=text.align_left)
    table.cell(dash, 1, 7, sgTxt + " ", text_color=sgClr, text_size=txt, bgcolor=color.new(sgClr, 80), text_halign=text.align_right)

    // Conviction tier — STRONG when fired; SYNCED when chart+osc legs align (setup building)
    string tierTxt = fluxTierTx
    color  tierClr = fluxTierClr
    table.cell(dash, 0, 8, " Conviction", text_color=C_SUBTLE, text_size=txt, bgcolor=rowA, text_halign=text.align_left)
    table.cell(dash, 1, 8, tierTxt + " ", text_color=tierClr, text_size=txt, bgcolor=rowA, text_halign=text.align_right)

    // Chop strength meter (display only — red = high chop, gray = low)
    string chopMeterTx = chopEnable and visChopMeter ? (chopModeActive ? str.tostring(chopStrengthPct) + "%  " + chopMeterBar : "Clear · " + str.tostring(chopStrengthPct) + "%") : "—"
    color  chopMeterClr = f_chopMeterClr(chopStrengthPct)
    color  chopRowBg    = chopModeActive and visChopMeter ? color.new(chopStrengthPct >= 65 ? C_BEAR : C_CHOP_PURPLE, chopStrengthPct >= 65 ? 93 : 95) : rowB
    table.cell(dash, 0, 9, " Chop Strength", text_color=C_SUBTLE, text_size=txt, bgcolor=chopRowBg, text_halign=text.align_left)
    table.cell(dash, 1, 9, chopMeterTx + " ", text_color=chopMeterClr, text_size=txt, bgcolor=chopRowBg, text_halign=text.align_right)

// ════════════════════════════════ ALERTS ════════════════════════════════════
if fluxReadEnable and barstate.isconfirmed
    alert(fluxReadJson, alert.freq_once_per_bar_close)

alertcondition(anyBuy,         title="Any Buy",      message="Oracle Flux: BUY signal on {{ticker}} ({{interval}}) @ {{close}}")
alertcondition(anySell,        title="Any Sell",     message="Oracle Flux: SELL signal on {{ticker}} ({{interval}}) @ {{close}}")
alertcondition(fluxSyncBuy,     title="Flux Sync Buy",  message="Oracle Flux: Chart+Oscillator SYNC BUY on {{ticker}} ({{interval}}) @ {{close}}")
alertcondition(fluxSyncSell,    title="Flux Sync Sell", message="Oracle Flux: Chart+Oscillator SYNC SELL on {{ticker}} ({{interval}}) @ {{close}}")
alertcondition(fireStrongBuy,  title="Strong Buy",   message="Oracle Flux: STRONG BUY on {{ticker}} ({{interval}}) @ {{close}}")
alertcondition(fireStrongSell, title="Strong Sell",  message="Oracle Flux: STRONG SELL on {{ticker}} ({{interval}}) @ {{close}}")
alertcondition(fireNormalBuy,  title="Normal Buy",   message="Oracle Flux: Buy on {{ticker}} ({{interval}}) @ {{close}}")
alertcondition(fireNormalSell, title="Normal Sell",  message="Oracle Flux: Sell on {{ticker}} ({{interval}}) @ {{close}}")
alertcondition(bullDiv,        title="Bullish Div",  message="Oracle Flux: Bullish divergence on {{ticker}} ({{interval}})")
alertcondition(bearDiv,        title="Bearish Div",  message="Oracle Flux: Bearish divergence on {{ticker}} ({{interval}})")
alertcondition(hiddenBullDiv,  title="Hidden Bull Div", message="Oracle Flux: Hidden bullish divergence on {{ticker}} ({{interval}})")
alertcondition(hiddenBearDiv,  title="Hidden Bear Div", message="Oracle Flux: Hidden bearish divergence on {{ticker}} ({{interval}})")

// Master alert (single fire for any major event when master toggle on)
bool masterEvent = alrEnable and (anyBuy or anySell or bullDiv or bearDiv)
alertcondition(masterEvent,    title="Master Alert", message="Oracle Flux: Event on {{ticker}} ({{interval}}) @ {{close}}")

// ── Combined confluence alert (dynamic message listing the active legs) ──
if alrEnable and alrCombined and (anyBuy or anySell)
    bool isBuy  = anyBuy
    string head = (fireStrongBuy or fireStrongSell ? "STRONG " : "") + (isBuy ? "BUY" : "SELL")
    string legs = ""
    if isBuy
        legs := legs + (fwCrossUp ? " + Flux Wave bull cross" : "")
        legs := legs + (fwInOS    ? " + Flux Wave oversold"   : "")
        legs := legs + (bullDiv   ? " + bullish div"   : "")
        legs := legs + (hiddenBullDiv ? " + hidden bull div" : "")
        legs := legs + (priceAboveAV and not vwapTestUp ? " + above VWAP" : "")
        legs := legs + (vwapTestUp ? " + VWAP bounce"  : "")
        legs := legs + (structBull ? " + BOS up"       : "")
        legs := legs + (sigUseTrend and trendUp ? " + trend up" : "")
        legs := legs + (mfIn       ? " + money inflow" : "")
    else
        legs := legs + (fwCrossDn ? " + Flux Wave bear cross" : "")
        legs := legs + (fwInOB    ? " + Flux Wave overbought" : "")
        legs := legs + (bearDiv   ? " + bearish div"   : "")
        legs := legs + (hiddenBearDiv ? " + hidden bear div" : "")
        legs := legs + (priceBelowAV and not vwapTestDn ? " + below VWAP" : "")
        legs := legs + (vwapTestDn ? " + VWAP rejection" : "")
        legs := legs + (structBear ? " + BOS down"     : "")
        legs := legs + (sigUseTrend and trendDn ? " + trend down" : "")
        legs := legs + (mfOut      ? " + money outflow" : "")
    string msg = "Oracle Flux: " + head + legs + " on " + syminfo.ticker + " (" + timeframe.period + ") @ " + str.tostring(close, format.mintick)
    alert(msg, alrFreq == "Once Per Bar" ? alert.freq_once_per_bar : alert.freq_once_per_bar_close)
````
