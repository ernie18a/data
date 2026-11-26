# Oracle Flux Oscillator

- url: https://www.tradingview.com/script/mUlI6Xj4-Oracle-Flux-Oscillator/
- type: indicator
- pine_id: PUB;04f9b4e324e2444f88011ee9be9f0111
- version: 4.0

## Description

Oracle Flux Oscillator is the companion oscillator for the Oracle Flux indicator.

It features:
• Enhanced Flux Wave (momentum oscillator with improved responsiveness)
• Integrated internal VWAP for pinch & rollover detection
• Money Flow area with clear green/red visualization
• Exhaustion / reversal dots
• Overbought/Oversold zones with divergence detection

Key Features:
- Clean filled Money Flow with premium styling
- Rollover & pinch signals for early reversal detection
- Works seamlessly with the main Oracle Flux indicator
- Optimized for Heikin Ashi charts on 15m – 4H timeframes

Use this oscillator to confirm momentum shifts and spot high-probability reversal zones.

## Source Code

````pine
//@version=6
// ============================================================================
//  ORACLE FLUX - OSCILLATOR  (companion pane)
//  Flux Wave - Money Flow - Flux Fair Value - divergence diamonds <> - WHEN engine
//  Master regular/hidden divergence detection - original Flux stack
// ============================================================================
indicator("Oracle Flux - Oscillator", shorttitle="FLUX OSC", overlay=false, max_lines_count=500, max_labels_count=500, max_bars_back=5000)

// ================================= INPUTS ===================================

// -- Scalp Mode ---------------------------------------------------------------
scalpMode     = false

// -- Flux Wave ----------------------------------------------------------------
gOSC          = "1) Flux Wave"
fwChanLen     = input.int(9,      "Channel Length",   minval=2, group=gOSC)
fwAvgLen      = input.int(12,     "Average Length",   minval=2, group=gOSC)
fwSigLen      = input.int(3,      "Signal Smoothing", minval=1, group=gOSC)
fwSrc         = input.source(hlc3,"Source",                     group=gOSC)
fwOB          = input.int(60,     "Overbought Level",           group=gOSC)
fwOB2         = input.int(80,     "Extreme Overbought",         group=gOSC)
fwOS          = input.int(-60,    "Oversold Level",             group=gOSC)
fwOS2         = input.int(-80,    "Extreme Oversold",           group=gOSC)
oFwMom        = input.float(1.0,  "Weight - Flux Wave momentum", minval=0, step=0.1, group=gOSC)
oFwVwap       = input.float(0.8,  "Weight - VWAP momentum",      minval=0, step=0.1, group=gOSC)
oFwMf         = input.float(0.6,  "Weight - Money-Flow momentum",minval=0, step=0.1, group=gOSC)
showCrosses   = input.bool(false, "Show cross dots",            group=gOSC, tooltip="OFF by default for a cleaner premium look.")
showComps     = input.bool(false, "Show component momentum lines", group=gOSC)
showAccel     = input.bool(false, "Show momentum acceleration", group=gOSC, tooltip="Faint acceleration trace - advanced Flux Wave edge.")
showFairValue = input.bool(true,  "Show Flux Fair Value",       group=gOSC, tooltip="Mid-pane fair-value line - stays near zero like a timing VWAP. Not overlay anchored VWAPs.")
fvSmoothLen   = input.int(4,      "Fair Value smooth",          minval=1, maxval=12, group=gOSC, tooltip="Higher = smoother mid-line (MCB-style readability).")
fvScale       = input.float(14.0,  "Fair Value amplitude",       minval=6, maxval=30, step=0.5, group=gOSC, tooltip="Keeps FV in the mid-pane (+/-20-40). Lower = tighter to zero.")
colFairValue  = input.color(#FFFFFF, "Fair Value color",         group=gOSC, tooltip="White mid-line - matches your custom Flux look.")

// -- Money Flow ---------------------------------------------------------------
gMF           = "2) Money Flow"
mfEnable      = input.bool(true,  "Show Money Flow filled area",  group=gMF)
mfSmooth      = input.int(3,      "Money Flow Smoothing", minval=1, group=gMF)
mfAreaSmooth  = input.int(4,      "Area extra smooth (EMA)", minval=1, group=gMF, tooltip="Extra pass for a smoother, premium Money Flow fill.")
mfMult        = input.float(12.0, "Money Flow Scale", step=0.5,  group=gMF, tooltip="Higher = taller MF cloud (screenshot default).")
mfOpacity     = input.int(62,     "Money Flow fill opacity %", minval=25, maxval=85, group=gMF, tooltip="Higher = denser forest/maroon cloud like your custom theme.")
mfShowEdge    = input.bool(true,  "Show Money Flow edge line", group=gMF, tooltip="Bright lime/red outline on the MF wave.")

// -- Divergence ---------------------------------------------------------------
divEnable     = true
divPivLeft    = 4
divPivRight   = 2
divLookback   = 100
divDrawLine   = true
divShowLabels = false
divOnlyMajor  = false
divHidden     = true
divMasterMode = true

// -- Divergence Diamonds - premium WHEN triggers ------------------------------
gDIA          = "<> Divergence Diamonds"
diaPivLeft    = input.int(4,      "Price pivot left",       minval=2, maxval=12, group=gDIA)
diaPivRight   = input.int(2,      "Price pivot right",      minval=1, maxval=8,  group=gDIA, tooltip="2nd-leg confirm speed.")
diaMinSwingBars = input.int(6,    "Min bars between legs",  minval=3, maxval=30, group=gDIA)
diaLookback   = input.int(100,    "Max pivot lookback",     minval=20, maxval=200, group=gDIA)
diaFwMinSep   = input.float(4.0,  "Min wave separation",      minval=1, step=0.5, group=gDIA, tooltip="Higher = clearer divergence between legs.")
diaZonePad    = input.int(58,     "OS/OB zone pad",         minval=10, maxval=80, group=gDIA)
diaCooldown   = input.int(10,     "Diamond cooldown (bars)", minval=0, maxval=40, group=gDIA, tooltip="Higher = fewer <> clusters.")
diaMinScore   = input.int(58,     "Min conviction score",   minval=35, maxval=90, group=gDIA, tooltip="Divergence diamond score 0-100.")
diaEliteScore = input.int(74,     "Elite score", minval=50, maxval=95, group=gDIA, tooltip="A-grade divergence diamond - hot green buy / hot red sell.")
diaUseHidden  = input.bool(false, "Hidden divergence diamonds", group=gDIA, tooltip="OFF = regular reversal diamonds only (recommended). ON adds continuation <>.")
diaRequireRegular = input.bool(true, "Require regular divergence", group=gDIA, tooltip="ON = <> must be price vs wave regular divergence (master mode).")
diaFractalPrimary = input.bool(true,  "Primary fractal confirm",    group=gDIA, tooltip="Dual-line agreement - primary + signal Flux Wave.")
diaUseVwapMom = input.bool(true,  "Flux spread momentum",   group=gDIA, tooltip="Primary-signal spread reversal at extremes.")
diaUseFluxMf  = input.bool(true,  "Flux MF pulse",          group=gDIA, tooltip="Body/volume pulse for diamond conviction.")
diaUseFairValue = input.bool(true, "<> score: Fair Value agree", group=gDIA, tooltip="ON = +6 conviction when Flux Fair Value hooks with the divergence (bull: FV rising/trough - bear: FV falling/peak).")
diaDrawLines  = input.bool(true,  "Draw A->B divergence lines", group=gDIA)
diaRequireMf  = input.bool(false, "Hard-require MF gate",   group=gDIA, tooltip="OFF = score-based MF (recommended). ON = strict MF gate.")
diaRequireCross = input.bool(false, "Hard-require wave cross", group=gDIA, tooltip="OFF = score-based cross (recommended). ON = strict cross gate.")
diaRegimeFilter = input.bool(true,  "Regime-honest diamonds", group=gDIA, tooltip="ON: CHOP = elite <> only. RANGE = higher score (master dual/extreme can pass). TREND = normal.")
diaLegEnable  = input.bool(true,  "Leg engine (true A->B legs)", group=gDIA, tooltip="Finds leg A among all recent swings - skips micro pivots between the two major legs.")
diaLegWaveWin = input.int(3,      "Leg wave peak window",   minval=0, maxval=8, group=gDIA, tooltip="Bars before the price pivot to search for the wave peak (wave often tops before price).")
diaLegMinAtr  = input.float(0.25, "Leg min price HH/LL (ATR)", minval=0.0, step=0.05, group=gDIA, tooltip="Leg B must exceed leg A price by this many ATR.")
diaLegZonePct = input.float(0.5,  "Leg A zone (share of OB/OS)", minval=0.0, maxval=1.0, step=0.05, group=gDIA, tooltip="Leg A wave must reach this share of OB (bear) / OS (bull). 0.5 = 30 with OB 60.")
diaLegWaveTol = input.float(0.0,  "Leg wave tolerance",     step=0.5, group=gDIA, tooltip="0 = leg B wave equal or lower than leg A. Negative = allow B slightly higher (looser). Positive = stricter.")
diaLegBypass  = input.bool(true,  "Major legs bypass CHOP/cooldown", group=gDIA, tooltip="Leg A in OB/OS + price HH/LL prints even in CHOP or right after another <>.")

// -- TOP / BOTTOM signals - swing reversal calls on the price chart -----------
gTB           = "<> TOP / BOTTOM Signals"
tbEnable      = input.bool(true,  "Enable TOP / BOTTOM signals", group=gTB, tooltip="Arms on a divergence diamond (or blow-off exhaustion) at a major swing - fires when momentum and structure break.")
tbSwingLen    = input.int(48,     "Major swing lookback (bars)", minval=10, maxval=300, group=gTB, tooltip="Armed high/low must be the extreme of this many bars. 48 on 1H = 2 days.")
tbConfirmBars = input.int(8,      "Confirm window (bars)", minval=1, maxval=30, group=gTB, tooltip="Bars after arming to get the momentum + structure break.")
tbBreakBars   = input.int(3,      "Structure break bars", minval=1, maxval=10, group=gTB, tooltip="TOP needs a close below the lowest low of this many prior bars (BOTTOM mirrors).")
tbExhaust     = input.bool(true,  "Blow-off exhaustion arms", group=gTB, tooltip="Also arm without a diamond when the wave hits OB++/OS++ at a Fib rejection or liquidity sweep with Money Flow flipped.")
tbDivArms     = input.bool(true,  "Regular divergence arms", group=gTB, tooltip="Also arm on a regular price-vs-wave divergence at the swing extreme even when no diamond printed (B grade).")
tbLockAtr     = input.float(4.0,  "Re-arm after move (ATR)", minval=0.5, step=0.5, group=gTB, tooltip="After a TOP, a lower high can arm again once price has fallen this many ATR from the top (BOTTOM mirrors).")
tbOnPrice     = input.bool(true,  "Show on price chart", group=gTB, tooltip="Paint TOP / BOTTOM labels on the candles (force overlay).")
tbOnPane      = input.bool(true,  "Show in oscillator pane", group=gTB)

// -- Visuals ------------------------------------------------------------------
gVIS          = "4) Visuals"
visAreaFill   = input.bool(true,  "Smooth Flux Wave area fill",              group=gVIS)
visSmoothWave = input.bool(true,  "Premium smooth Wave display",      group=gVIS, tooltip="Smoothes the plotted Wave only - crosses, diamonds, and sync still use the sharp engine.")
visSmoothLen  = input.int(2,      "Display smooth length", minval=1, maxval=5, group=gVIS)
visBands      = input.bool(true,  "Show OB/OS band fills",            group=gVIS)
visConfluence = input.bool(true,  "Confluence zone tint",             group=gVIS, tooltip="Very subtle background when all three engines align.")
visDivGlow    = input.bool(true,  "Divergence highlight tint",        group=gVIS, tooltip="Subtle pane wash when regular divergence fires in extreme zones.")
showStrongDiamonds = input.bool(true,  "Show divergence diamonds", group=gVIS, tooltip="<> = divergence WHEN trigger. Overlay = permission stamp.")
dashEnable    = input.bool(true,  "Show mini dashboard",              group=gVIS)
dashPos       = input.string("Top Right", "Dashboard position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=gVIS)

// -- Theme Colors (your custom defaults - sampled from TV swatches) ------------
gCOL          = "4) Theme Colors"
colBull       = input.color(#00FF06, "Bullish",              group=gCOL, tooltip="Pure neon green.")
colBear       = input.color(#F70000, "Bearish",              group=gCOL, tooltip="Pure red.")
colFwPrimary  = input.color(#00FF06, "Flux Wave primary line",   group=gCOL, tooltip="Neon green primary Wave.")
colFwSignal   = input.color(#0017FF, "Flux Wave signal line", group=gCOL, tooltip="Electric blue signal line.")
colMfBull     = input.color(#056309, "Money Flow bull fill", group=gCOL, tooltip="Dark forest green inflow cloud.")
colMfBear     = input.color(#570D10, "Money Flow bear fill", group=gCOL, tooltip="Dark maroon outflow cloud.")
colStrongBuy  = input.color(#111217, "STRONG buy accent",    group=gCOL)
colStrongSell = input.color(#111217, "STRONG sell accent",   group=gCOL)
colEliteBuy   = input.color(#39FF14, "Elite bull divergence", group=gCOL, tooltip="Hot neon green elite bull.")
colEliteSell  = input.color(#FF0000, "Elite bear divergence", group=gCOL, tooltip="Hot red elite bear.")
colDiaBuy     = input.color(#00FF06, "Bull divergence",       group=gCOL, tooltip="Neon green bull.")
colDiaSell    = input.color(#F70000, "Bear divergence",       group=gCOL, tooltip="Pure red bear.")
colGold       = input.color(#FBB806, "Gold accent",          group=gCOL, tooltip="Amber gold - dashboard.")
colPurple     = input.color(#9F6CFB, "Purple accent",        group=gCOL, tooltip="Component legs & chop glow.")
colChopWash   = input.color(#111217, "Chop zone wash",       group=gCOL)
colChopGlow   = input.color(#9F6CFB, "Chop zone glow",       group=gCOL)
colPanel      = input.color(#0A0F1A, "Dashboard panel",      group=gCOL)
colSubtle     = input.color(#5B6B85, "Muted text",           group=gCOL)

// -- 1H Sniper + signal sync (mirrors Oracle Flux overlay exactly) -------------
gPROF         = "5) Signal Sync (Oracle Flux)"
use1HProfile  = input.bool(true, "Auto-optimize for chart TF", group=gPROF, tooltip="Balanced 1H profile - syncs STRONG timing with main Oracle Flux overlay.")
haOn          = true
haMinRun      = 3
haMinBody     = 0.45
haWickMax     = 0.15
haReqStrong   = false
sigEnable     = input.bool(true,  "Enable signal sync", group=gPROF)
sigStructLen  = input.int(12,     "Structure pivot len", minval=2, group=gPROF)
sigEMAlen     = input.int(50,     "Trend EMA", minval=1, group=gPROF)
sigUseTrend   = input.bool(true,  "Require trend alignment", group=gPROF)
sigUseVWAP    = input.bool(true,  "Require VWAP confluence", group=gPROF)
sigOracleStrong= input.int(78,    "STRONG min Oracle score", minval=50, maxval=95, group=gPROF, tooltip="Default 78 - 1H profile uses 80.")
sigOracleNormal= input.int(58,    "Normal min Oracle score", minval=40, maxval=85, group=gPROF, tooltip="Cooldown sync only - match main Oracle Flux.")
sigPillarMin  = input.int(10,     "Min score per pillar", minval=5, maxval=22, group=gPROF, tooltip="1H profile uses 10 with Osc+HA mandatory.")
showStrong    = input.bool(true,  "Mirror main: Show STRONG", group=gPROF, tooltip="Must match main Oracle Flux 'Show Strong signals'.")
showNormal    = input.bool(false, "Mirror main: Normal signals", group=gPROF, tooltip="Cooldown sync only - match main Oracle Flux 'Show Normal signals'.")
sigStrongMF   = input.bool(true,  "STRONG: money-flow agree", group=gPROF)
sigStrongOsc  = input.bool(true,  "STRONG: Flux Wave agree", group=gPROF)
sigReqDailyVWAP= input.bool(true,  "STRONG: Daily VWAP align", group=gPROF)
sigCooldown   = input.int(24,     "Min bars between STRONG signals", minval=0, group=gPROF, tooltip="Default 24 - 1H profile uses 24.")
sigFibRev     = input.bool(true,  "Fib+Wave+MF reversal STRONG", group=gPROF)
vwapEnable    = input.bool(true,  "Use anchored VWAPs in sync", group=gPROF)
vwapSrc       = input.source(hlc3,"VWAP Source", group=gPROF)
vwapTouchPct  = input.float(0.15, "VWAP bounce tolerance (%)", step=0.01, minval=0, group=gPROF)
vShowDaily    = input.bool(true,  "Daily VWAP", group=gPROF)
vShowPDaily   = input.bool(true,  "Prev Day VWAP", group=gPROF)
vShowWtd      = input.bool(true,  "WTD VWAP", group=gPROF)
vShowPWtd     = input.bool(true,  "Prev Week VWAP", group=gPROF)
vShow5SMA     = input.bool(true,  "5-Day VWAP", group=gPROF)

// -- Chop Filter (synced with Oracle Flux) ------------------------------------
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

// -- Flux Read export (app / webhook - additive, does not change signals) -----
gREAD         = "7) Flux Read Export"
fluxReadEnable = input.bool(false, "Enable Flux Read JSON alerts", group=gREAD, tooltip="OFF by default. When ON, emits one compact JSON alert per bar close for webhooks / future OCO app sync. Does not change any signal logic.")
fluidTfProfile = input.bool(false, "Fluid TF profile (experimental)", group=gREAD, tooltip="OFF = keep classic LTF/1H/HTF buckets. ON = continuous TF scaling (needs Auto-optimize ON). Leave OFF unless you are A/B testing.")
regimeGateStrong = input.bool(true, "Regime gate STRONG", group=gREAD, tooltip="ON (Flux default): CHOP blocks STRONG; RANGE = reverse STRONG only; TREND = all. Pair with regime-honest diamonds.")

// -- Resolved theme (from inputs above) ---------------------------------------
color C_BULL       = colBull
color C_BEAR       = colBear
color C_BULL_DIM   = color.new(colBull, 60)
color C_BEAR_DIM   = color.new(colBear, 60)
color C_ACCENT     = colFwPrimary
color C_FW_SIGNAL  = colFwSignal
color C_PURPLE     = colPurple
color C_GOLD       = colGold
color C_MF_BULL    = color.new(colMfBull, 40)
color C_MF_BEAR    = color.new(colMfBear, 40)
color C_STRONG_BUY  = colStrongBuy
color C_STRONG_SELL = colStrongSell
color C_ELITE_BUY   = colEliteBuy
color C_ELITE_SELL  = colEliteSell
color C_DIA_BUY     = colDiaBuy
color C_DIA_SELL    = colDiaSell
color C_FAIR_VALUE  = colFairValue
color C_TEXT       = color.new(#DCE7F5, 0)
color C_SUBTLE     = colSubtle
color C_PANEL      = color.new(colPanel, 6)
color C_NEUTRAL    = color.new(#566379, 0)
color C_CHOP_SLATE = color.new(#121620, 0)
color C_CHOP_MIST  = color.new(#161922, 0)
color C_CHOP_PURPLE = colChopWash
color C_CHOP_GLOW  = colChopGlow

// ============================= HELPER FUNCTIONS =============================
f_dashPos(_s) => _s == "Top Left" ? position.top_left : _s == "Bottom Right" ? position.bottom_right : _s == "Bottom Left" ? position.bottom_left : position.top_right

f_chopBar(_p) =>
    int n = int(math.min(10, math.max(0, math.round(_p / 10.0))))
    n >= 10 ? "##########" : n >= 9 ? "#########-" : n >= 8 ? "########--" : n >= 7 ? "#######---" : n >= 6 ? "######----" : n >= 5 ? "#####-----" : n >= 4 ? "####------" : n >= 3 ? "###-------" : n >= 2 ? "##--------" : n >= 1 ? "#---------" : "----------"

f_chopMeterClr(_p) =>
    _p >= 65 ? color.new(C_BEAR, 8) : _p >= 40 ? color.new(C_BEAR, 32) : color.new(C_SUBTLE, 0)

f_chopTagTxtClr(_p) =>
    _p >= 65 ? color.new(C_BEAR, 20) : color.new(C_CHOP_GLOW, 26)

f_jsonStr(string s) =>
    '"' + str.replace_all(str.replace_all(s, "\\", "/"), '"', "'") + '"'

f_jsonBool(bool b) =>
    b ? "true" : "false"

// Flux Wave v2 - adaptive volatility scaling - relative-volume MF - acceleration
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

// Flux Fair Value - independent mid-pane timing line (not glued to Flux Wave)
// ATR-normalized distance from rolling VWMA + light volume-body pressure, double-smoothed, clamped mid-range.
f_fluxFairValue(_src, _len, _smooth, _amp) =>
    float vwRaw = ta.vwma(_src, _len)
    float vwMid = na(vwRaw) ? ta.sma(_src, _len) : vwRaw
    float atrN  = math.max(ta.atr(14), syminfo.mintick)
    float dist  = (_src - vwMid) / atrN
    float vol   = nz(volume)
    float volA  = ta.sma(vol, _len)
    float volR  = volA > 0 ? math.min(vol / volA, 2.0) : 1.0
    float rng   = math.max(high - low, syminfo.mintick)
    float bodyP = (close - open) / rng
    float press = bodyP * volR
    float raw   = dist * _amp + press * (_amp * 0.45)
    float sm1   = ta.ema(raw, _smooth)
    float sm2   = ta.ema(sm1, _smooth)
    math.max(-55.0, math.min(55.0, sm2))

// ======================= GOLDILOCKS 1H PROFILE (sweet spot) ===================
int tfSec = timeframe.in_seconds()
int tfMin = tfSec > 0 ? tfSec / 60 : 60
bool tfIs1H  = tfMin == 60
bool tfIsLTF = tfMin > 0 and tfMin < 60
bool tfIsHTF = tfMin > 60
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
int bucketDivPivL      = use1HProfile and tfIs1H ? diaPivLeft : divPivLeft
int bucketDivPivR      = use1HProfile and tfIs1H ? math.max(divPivRight, diaPivRight) : divPivRight
bool bucketSoftDailyVwap = use1HProfile and tfIs1H
int  bucketZoneBuyMax  = use1HProfile and tfIs1H ? 45 : 60
int  bucketZoneSellMin = use1HProfile and tfIs1H ? -45 : -60
int bucketFibLegLook   = use1HProfile ? (tfIs1H ? 220 : tfIsLTF ? 120 : tfIsHTF ? 300 : 180) : 180
int bucketRevOracleGap = use1HProfile and tfIs1H ? 4 : 5
int bucketDivPersist   = use1HProfile ? (tfIs1H ? 10 : tfIsLTF ? 8 : 8) : 8
float bucketDivOSPct   = use1HProfile and tfIs1H ? 0.88 : 1.0
int bucketRevCdBars    = use1HProfile ? (tfIs1H ? 12 : tfIsLTF ? 8 : 14) : 12

// Fluid continuous profile - anchors: ~5m -> 60m -> 240m
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
int fluidDivPivL      = int(math.round(divPivLeft + (diaPivLeft - divPivLeft) * fluidNear1H))
int fluidDivPivR      = int(math.round(divPivRight + (math.max(divPivRight, diaPivRight) - divPivRight) * fluidNear1H))
bool fluidSoftDailyVwap = use1HProfile and tfMin >= 45 and tfMin <= 90
int  fluidZoneBuyMax  = int(math.round(60.0 - 15.0 * fluidNear1H))
int  fluidZoneSellMin = int(math.round(-60.0 + 15.0 * fluidNear1H))
int fluidFibLegLook   = tfMin <= 60 ? int(math.round(120.0 + 100.0 * fluidTLo)) : int(math.round(220.0 + 80.0 * fluidTHi))
int fluidRevOracleGap = int(math.round(5.0 - 1.0 * fluidNear1H))
int fluidDivPersist   = tfMin <= 60 ? int(math.round(8.0 + 2.0 * fluidTLo)) : 8
float fluidDivOSPct   = 1.0 - 0.12 * fluidNear1H
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
int profFibLegLook   = useFluidProf ? fluidFibLegLook : bucketFibLegLook
int profRevOracleGap = useFluidProf ? fluidRevOracleGap : bucketRevOracleGap
int profDivPersist   = useFluidProf ? fluidDivPersist : bucketDivPersist
float profDivOSPct   = useFluidProf ? fluidDivOSPct : bucketDivOSPct
int profRevCdBars    = useFluidProf ? fluidRevCdBars : bucketRevCdBars

// -- Scalp Mode layer (1H and below only) --
int effOracleStrong = scalpActive ? (tfIs1H ? 74 : 72) : profOracleStrong
int effOracleNormal = profOracleNormal
int effPillarMin    = scalpActive ? 9 : profPillarMin
int effPillarMinNorm= profPillarMinNorm
bool effShowNormal  = showNormal and not scalpActive
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
int effFibLegLook   = scalpActive ? (tfIs1H ? 120 : 80) : profFibLegLook
int effRevOracleGap = scalpActive ? 7 : profRevOracleGap
int effFwChanLen    = scalpActive ? 7 : fwChanLen
int effFwAvgLen     = scalpActive ? 9 : fwAvgLen
int effFwSigLen     = scalpActive ? 2 : fwSigLen
int effMfSmooth     = scalpActive ? 2 : mfSmooth
int effMfAreaSmooth = scalpActive ? 2 : mfAreaSmooth
int effMfBodyLen    = scalpActive ? 9 : 14
bool effDivOnlyMajor = scalpActive ? false : divOnlyMajor
float effChopFwMinSpread = scalpActive ? 6.5 : chopFwMinSpread
int   effFvLen        = scalpActive ? 14 : 21
int   effFvSmooth     = scalpActive ? math.max(3, fvSmoothLen - 1) : fvSmoothLen
float effFvAmp        = scalpActive ? fvScale * 1.1 : fvScale
int   effIVwapLen     = effFvLen
int   effIVwapSmooth  = effFvSmooth
float effIVwapScale   = effFvAmp
int   effFvPlotSmooth = scalpActive ? 2 : 3
int   effDivPersist     = scalpActive ? 8 : profDivPersist
float effDivOSPct       = scalpActive ? 0.88 : profDivOSPct
float effDivDotOSPct    = scalpActive ? 0.90 : (use1HProfile and tfIs1H ? 0.88 : 0.92)
int   effRevCdBars      = scalpActive ? 5 : profRevCdBars
float effDotMinFwSep    = scalpActive ? 2.5 : (use1HProfile and tfIs1H ? 4.0 : 5.0)
int   effDivMinPivBars  = scalpActive ? 5 : (use1HProfile and tfIs1H ? diaMinSwingBars : 10)
int   effDiaPivL        = scalpActive ? 3 : diaPivLeft
int   effDiaPivR        = scalpActive ? 2 : diaPivRight
int   effDiaLookback    = scalpActive ? 60 : diaLookback
float effDiaFwMin       = scalpActive ? 2.5 : diaFwMinSep
int   effDiaZonePad     = scalpActive ? 40 : diaZonePad
int   effDiaCooldown    = scalpActive ? 6 : diaCooldown
int   effDiaMinScore    = scalpActive ? math.max(52, diaMinScore - 4) : diaMinScore
int   effDiaEliteScore  = scalpActive ? math.max(68, diaEliteScore - 4) : diaEliteScore
int   effDiaRangeBump   = 8
bool  effDiaHidden      = diaUseHidden and divHidden

// =========================== HEIKIN ASHI ENGINE ============================
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

f_fibPrice(_bullLeg, _hi, _lo, _ratio) =>
    _bullLeg ? _hi - _ratio * (_hi - _lo) : _lo + _ratio * (_hi - _lo)

f_fibFromHigh(_hi, _lo, _ratio) => _hi - _ratio * (_hi - _lo)

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

// =========================== FLUX WAVE CALC ================================
float fwSrcUsed = haOn ? haSrc : fwSrc
[fwPrimary, fwSignal, oscMom, oscVwap, oscMf, fwAccel] = f_fluxWave(fwSrcUsed, effFwChanLen, effFwAvgLen, effFwSigLen, oFwMom, oFwVwap, oFwMf)

bool fwCrossUp = ta.crossover(fwPrimary, fwSignal)
bool fwCrossDn = ta.crossunder(fwPrimary, fwSignal)
bool fwBull    = fwPrimary > fwSignal
bool fwBear    = fwPrimary < fwSignal
bool fwInOB    = fwSignal >= fwOB
bool fwInOS    = fwSignal <= fwOS
bool fwRising  = fwPrimary > fwPrimary[1]
bool fwFalling = fwPrimary < fwPrimary[1]
bool oscAllBull = oscMom > 0 and oscVwap > 0 and oscMf > 0
bool oscAllBear = oscMom < 0 and oscVwap < 0 and oscMf < 0

// Internal confluence score (0-100) - finalized after divergence block below
int engBull = (oscMom > 0 ? 1 : 0) + (oscVwap > 0 ? 1 : 0) + (oscMf > 0 ? 1 : 0)
int engBear = 3 - engBull
int oscScore = 0

// Money Flow - smooth series for premium filled area (green above / red below zero)
float mfRaw = ta.sma(oscMf, effMfSmooth) * (mfMult / 8.0)
float mfEma = ta.ema(mfRaw, effMfAreaSmooth)
float mf    = mfEnable ? mfEma : na
float mfPos = mfEnable and not na(mf) and mf >= 0 ? mf : na
float mfNeg = mfEnable and not na(mf) and mf < 0 ? mf : na
// Transparency: input opacity% -> Pine transparency (0=solid, 100=invisible)
int   mfBaseTrans = 100 - mfOpacity
int   mfFillTrans = mfEnable and not na(mf) ? int(math.max(mfBaseTrans - 8, math.min(mfBaseTrans + 12, mfBaseTrans + 6 - math.min(10, math.abs(mf) * 0.28)))) : mfBaseTrans
color mfBullFill  = color.new(colMfBull, mfFillTrans)
color mfBearFill  = color.new(colMfBear, mfFillTrans)
// Bright lime/red edge (not the dark fill) - matches screenshot outline
color mfBullEdge  = color.new(colBull, 15)
color mfBearEdge  = color.new(colBear, 15)

// ============= FLUX FAIR VALUE (pane mid-line) ===============================
// Independent of Flux Wave amplitude - hugs zero like a timing VWAP (+/-55 clamp).
// Confirm <> / zero-cross bias. Not overlay Daily/WTD VWAP.
float fluxFairValue = f_fluxFairValue(fwSrcUsed, effFvLen, effFvSmooth, effFvAmp)
float iVwap = fluxFairValue
bool  fvRising  = fluxFairValue > fluxFairValue[1]
bool  fvFalling = fluxFairValue < fluxFairValue[1]
bool  fvBullBias = fluxFairValue > 0
bool  fvBearBias = fluxFairValue < 0
bool  fvCrossUp  = ta.crossover(fluxFairValue, 0)
bool  fvCrossDn  = ta.crossunder(fluxFairValue, 0)
bool  wavePeak      = fwPrimary < fwPrimary[1] and fwPrimary[1] >= fwPrimary[2]
bool  waveTrough    = fwPrimary > fwPrimary[1] and fwPrimary[1] <= fwPrimary[2]
bool  ivPeak        = fluxFairValue < fluxFairValue[1] and fluxFairValue[1] >= fluxFairValue[2]
bool  ivTrough      = fluxFairValue > fluxFairValue[1] and fluxFairValue[1] <= fluxFairValue[2]
bool  sharpBearRoll = wavePeak and ivPeak and fwFalling and fwPrimary[1] >= fwOB * 0.50
bool  sharpBullRoll = waveTrough and ivTrough and fwRising and fwPrimary[1] <= fwOS * 0.50

// -- Divergence scaffolds (used by <> engine only) -----------------------------
// Primary-signal spread - body/volume pulse mapped to Flux style
float fluxWaveSpread  = fwPrimary - fwSignal
bool  fluxSpreadUp  = fluxWaveSpread > fluxWaveSpread[1]
bool  fluxSpreadDn  = fluxWaveSpread < fluxWaveSpread[1]
int   fluxMfiLen    = math.max(20, effMfBodyLen * 4)
float fluxMfiPulse  = ta.sma((close - open) / math.max(high - low, syminfo.mintick) * 120.0, fluxMfiLen)
bool  fluxMfiBull   = fluxMfiPulse > 0
bool  fluxMfiBear   = fluxMfiPulse < 0
bool  fluxMfiShiftB = fluxMfiBull and not fluxMfiBull[1]
bool  fluxMfiShiftS = fluxMfiBear and not fluxMfiBear[1]

// ========================== DIVERGENCE DETECTION ===========================
// Master regular divergence: ATR price filter - wave separation - dual-line confirm
var float lastPivLowSig  = na
var float lastPivLowPr  = na
var int   lastPivLowBar = na
var float lastPivHiSig   = na
var float lastPivHiPr   = na
var int   lastPivHiBar  = na
var float lastPivLowFast = na
var float lastPivLowPr1 = na
var int   lastPivLowBar1 = na
var float lastPivHiFast  = na
var float lastPivHiPr1  = na
var int   lastPivHiBar1 = na

bool bullDiv = false
bool bearDiv = false
bool bullDivFast = false
bool bearDivFast = false
bool hiddenBullDiv = false
bool hiddenBearDiv = false

float pvLowSig = ta.pivotlow(fwSignal, effDivPivL, effDivPivR)
float pvHiSig  = ta.pivothigh(fwSignal, effDivPivL, effDivPivR)
float pvLowFast = ta.pivotlow(fwPrimary, effDivPivL, effDivPivR)
float pvHiFast  = ta.pivothigh(fwPrimary, effDivPivL, effDivPivR)
int   pvBar   = bar_index - effDivPivR
float pvLowPr = low[effDivPivR]
float pvHiPr  = high[effDivPivR]
float divMinPrMove = ta.atr(14) * (divMasterMode ? (scalpActive ? 0.28 : 0.38) : (scalpActive ? 0.20 : 0.28))
float divMinWaveSep = divMasterMode ? effDotMinFwSep * 1.15 : effDotMinFwSep

if divEnable and not na(pvLowSig)
    float effDivOSLvl = fwOS * effDivOSPct
    int   pivSpanL    = pvBar - lastPivLowBar
    bool  pivSpaced   = not na(lastPivLowBar) and pivSpanL >= effDivMinPivBars
    bool  qualified   = not effDivOnlyMajor or (pvLowSig <= effDivOSLvl)
    if not na(lastPivLowSig) and qualified and pivSpaced and pivSpanL <= divLookback
        float waveSep = pvLowSig - lastPivLowSig
        float prSep = lastPivLowPr - pvLowPr
        // Regular bull: price lower low - wave higher low
        if pvLowPr < lastPivLowPr and waveSep >= divMinWaveSep and prSep >= divMinPrMove
            bullDiv := true
            if divDrawLine
                line.new(lastPivLowBar, lastPivLowSig, pvBar, pvLowSig, color=color.new(C_DIA_BUY, 20), width=2, style=line.style_solid)
            if divShowLabels
                label.new(pvBar, pvLowSig, "DIV^", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=C_DIA_BUY, size=size.tiny)
    if divHidden and not na(lastPivLowSig) and pivSpaced and pivSpanL <= divLookback
        bool qualHidBull = not effDivOnlyMajor or (pvLowSig > effDivOSLvl and pvLowSig < fwOB)
        if qualHidBull and pvLowPr > lastPivLowPr and pvLowSig < lastPivLowSig and (pvLowSig - lastPivLowSig) <= -divMinWaveSep and (pvLowPr - lastPivLowPr) >= divMinPrMove * (divMasterMode ? 0.65 : 0.5)
            hiddenBullDiv := true
            if divDrawLine
                line.new(lastPivLowBar, lastPivLowSig, pvBar, pvLowSig, color=color.new(colFwSignal, 35), width=1, style=line.style_dashed)
    lastPivLowSig  := pvLowSig
    lastPivLowPr  := pvLowPr
    lastPivLowBar := pvBar

if divEnable and not na(pvHiSig)
    bool qualifiedB = not effDivOnlyMajor or (pvHiSig >= fwOB)
    int  pivSpanH   = pvBar - lastPivHiBar
    bool pivSpacedH = not na(lastPivHiBar) and pivSpanH >= effDivMinPivBars
    if not na(lastPivHiSig) and qualifiedB and pivSpacedH and pivSpanH <= divLookback
        float waveSepB = lastPivHiSig - pvHiSig
        float prSepB = pvHiPr - lastPivHiPr
        // Regular bear: price higher high - wave lower high
        if pvHiPr > lastPivHiPr and waveSepB >= divMinWaveSep and prSepB >= divMinPrMove
            bearDiv := true
            if divDrawLine
                line.new(lastPivHiBar, lastPivHiSig, pvBar, pvHiSig, color=color.new(C_DIA_SELL, 20), width=2, style=line.style_solid)
            if divShowLabels
                label.new(pvBar, pvHiSig, "DIVv", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=C_DIA_SELL, size=size.tiny)
    if divHidden and not na(lastPivHiSig) and pivSpacedH and pivSpanH <= divLookback
        bool qualHidBear = not effDivOnlyMajor or (pvHiSig < fwOB and pvHiSig > fwOS)
        if qualHidBear and pvHiPr < lastPivHiPr and pvHiSig > lastPivHiSig and (pvHiSig - lastPivHiSig) >= divMinWaveSep and (lastPivHiPr - pvHiPr) >= divMinPrMove * (divMasterMode ? 0.65 : 0.5)
            hiddenBearDiv := true
            if divDrawLine
                line.new(lastPivHiBar, lastPivHiSig, pvBar, pvHiSig, color=color.new(colBear, 35), width=1, style=line.style_dashed)
    lastPivHiSig  := pvHiSig
    lastPivHiPr  := pvHiPr
    lastPivHiBar  := pvBar

// Primary fast-line - dual-line agreement for master-quality divergence
if divEnable and not na(pvLowFast)
    float effDivOSLvl1 = fwOS * effDivDotOSPct
    int   pivSpan1     = pvBar - lastPivLowBar1
    bool  pivSpaced1   = not na(lastPivLowBar1) and pivSpan1 >= effDivMinPivBars
    bool  qual1        = not effDivOnlyMajor or (pvLowFast <= effDivOSLvl1)
    float fastSepMin   = divMasterMode ? effDotMinFwSep * 0.95 : effDotMinFwSep * 0.80
    float fastPrMin    = divMasterMode ? divMinPrMove * 0.85 : divMinPrMove * 0.75
    if not na(lastPivLowFast) and qual1 and pivSpaced1 and pivSpan1 <= divLookback
        if pvLowPr < lastPivLowPr1 and pvLowFast > lastPivLowFast and (pvLowFast - lastPivLowFast) >= fastSepMin and (lastPivLowPr1 - pvLowPr) >= fastPrMin
            bullDivFast := true
    lastPivLowFast  := pvLowFast
    lastPivLowPr1  := pvLowPr
    lastPivLowBar1 := pvBar

if divEnable and not na(pvHiFast)
    bool qual1B = not effDivOnlyMajor or (pvHiFast >= fwOB * 0.92)
    int  pivSpan1B = pvBar - lastPivHiBar1
    bool pivSpaced1B = not na(lastPivHiBar1) and pivSpan1B >= effDivMinPivBars
    float fastSepMinB = divMasterMode ? effDotMinFwSep * 0.95 : effDotMinFwSep * 0.80
    float fastPrMinB  = divMasterMode ? divMinPrMove * 0.85 : divMinPrMove * 0.75
    if not na(lastPivHiFast) and qual1B and pivSpaced1B and pivSpan1B <= divLookback
        if pvHiPr > lastPivHiPr1 and pvHiFast < lastPivHiFast and (lastPivHiFast - pvHiFast) >= fastSepMinB and (pvHiPr - lastPivHiPr1) >= fastPrMinB
            bearDivFast := true
    lastPivHiFast  := pvHiFast
    lastPivHiPr1  := pvHiPr
    lastPivHiBar1 := pvBar

var int lastBullDivBar = na
var int lastBearDivBar = na
bool bullDivReg    = bullDiv or bullDivFast
bool bearDivReg    = bearDiv or bearDivFast
// Elite div - primary + signal agree (or signal-line div at deep extreme) - swing path merged below
bool bullDivDualBase = bullDiv and (bullDivFast or bullDivFast[1] or bullDivFast[2]) or (bullDiv and pvLowSig <= fwOS2)
bool bearDivDualBase = bearDiv and (bearDivFast or bearDivFast[1] or bearDivFast[2]) or (bearDiv and pvHiSig >= fwOB2)

// -- Diamond pivot divergence - price pivots + Flux Wave at pivot bar --
var float diaLastLoSig  = na
var float diaLastLoPr  = na
var int   diaLastLoBar = na
var float diaPrev2LoSig = na
var float diaPrev2LoPr = na
var int   diaPrev2LoBar = na
var float diaLastHiSig  = na
var float diaLastHiPr  = na
var int   diaLastHiBar = na
var float diaPrev2HiSig = na
var float diaPrev2HiPr = na
var int   diaPrev2HiBar = na
// Price-confirmed swings - Flux Wave sampled at the same pivot bar as price
float diaPrLow = ta.pivotlow(low, effDiaPivL, effDiaPivR)
float diaPrHi  = ta.pivothigh(high, effDiaPivL, effDiaPivR)
float diaSigAtLow = fwSignal[effDiaPivR]
float diaSigAtHi  = fwSignal[effDiaPivR]
int   diaPvBar   = bar_index - effDiaPivR
float diaPvLowPr = low[effDiaPivR]
float diaPvHiPr  = high[effDiaPivR]
float diaMinPr   = ta.atr(14) * (divMasterMode ? (scalpActive ? 0.22 : 0.28) : (scalpActive ? 0.14 : 0.18))
float swingTrendEma = ta.ema(close, sigEMAlen)
bool  swingTrendUp  = close > swingTrendEma
bool  swingTrendDn  = close < swingTrendEma
bool bullDivSwing = false
bool bearDivSwing = false
bool hiddenSwingBull = false
bool hiddenSwingBear = false
var int   diaPlotBarBuy  = na
var float diaPlotValBuy   = na
var int   diaPlotBarSell = na
var float diaPlotValSell  = na
var int   diaLegABarBuy  = na
var float diaLegAValBuy   = na
var int   diaLegABarSell = na
var float diaLegAValSell  = na
// Compare new pivot vs last swing AND one swing back (skips micro pivots between major legs)
f_diaTryBull(_pVal, _pPr, _pBar, _cVal, _cPr, _cBar) =>
    bool ok = false
    int span = na(_pBar) ? 9999 : _cBar - _pBar
    float wMin = divMasterMode ? effDiaFwMin * 0.90 : effDiaFwMin * 0.70
    float pMin = divMasterMode ? diaMinPr * 0.85 : diaMinPr * 0.65
    if not na(_pVal) and span >= effDivMinPivBars and span <= effDiaLookback
        float waveSep = _cVal - _pVal
        float prSep = _pPr - _cPr
        bool loQual = waveSep >= wMin and prSep >= pMin
        if _cPr < _pPr and loQual
            ok := true
    ok

f_diaTryBear(_pVal, _pPr, _pBar, _cVal, _cPr, _cBar) =>
    bool ok = false
    int span = na(_pBar) ? 9999 : _cBar - _pBar
    float wMin = divMasterMode ? effDiaFwMin * 0.90 : effDiaFwMin * 0.70
    float pMin = divMasterMode ? diaMinPr * 0.85 : diaMinPr * 0.65
    if not na(_pVal) and span >= effDivMinPivBars and span <= effDiaLookback
        float waveSep = _pVal - _cVal
        float prSep = _cPr - _pPr
        bool hiQual = waveSep >= wMin and prSep >= pMin
        if _cPr > _pPr and hiQual
            ok := true
    ok

// Leg engine - true leg A = strongest wave swing within lookback that leg B out-prices with a weaker wave
var array<float> legHiPr  = array.new<float>()
var array<float> legHiW   = array.new<float>()
var array<int>   legHiBar = array.new<int>()
var array<float> legLoPr  = array.new<float>()
var array<float> legLoW   = array.new<float>()
var array<int>   legLoBar = array.new<int>()
float legWaveHi = ta.highest(fwSignal, effDiaPivR + 1 + diaLegWaveWin)
float legWaveLo = ta.lowest(fwSignal, effDiaPivR + 1 + diaLegWaveWin)
float legAtr    = ta.atr(14)
bool  bearDivLeg   = false
bool  bullDivLeg   = false
bool  bearLegMajor = false
bool  bullLegMajor = false
int   legABarS = na
float legAValS = na
int   legABarB = na
float legAValB = na

if divEnable and diaLegEnable and not na(diaPrHi)
    int n = array.size(legHiPr)
    float runMax = na
    float bestW  = na
    if n > 0
        for i = n - 1 to 0
            int   aBar = array.get(legHiBar, i)
            float aPr  = array.get(legHiPr, i)
            float aW   = array.get(legHiW, i)
            int   sp   = diaPvBar - aBar
            bool  ok   = sp >= effDivMinPivBars and sp <= effDiaLookback and (na(runMax) or diaPvHiPr >= runMax) and diaPvHiPr - aPr >= legAtr * diaLegMinAtr and aW >= fwOB * diaLegZonePct and legWaveHi <= aW - diaLegWaveTol
            if ok and (na(bestW) or aW > bestW)
                bestW    := aW
                legABarS := aBar
                legAValS := aW
            runMax := na(runMax) ? aPr : math.max(runMax, aPr)
    if not na(bestW) and legWaveHi > 0
        bearDivLeg   := true
        bearLegMajor := bestW >= fwOB
    array.push(legHiPr, diaPvHiPr)
    array.push(legHiW, legWaveHi)
    array.push(legHiBar, diaPvBar)
    if array.size(legHiPr) > 16
        array.shift(legHiPr)
        array.shift(legHiW)
        array.shift(legHiBar)

if divEnable and diaLegEnable and not na(diaPrLow)
    int n = array.size(legLoPr)
    float runMin = na
    float bestW  = na
    if n > 0
        for i = n - 1 to 0
            int   aBar = array.get(legLoBar, i)
            float aPr  = array.get(legLoPr, i)
            float aW   = array.get(legLoW, i)
            int   sp   = diaPvBar - aBar
            bool  ok   = sp >= effDivMinPivBars and sp <= effDiaLookback and (na(runMin) or diaPvLowPr <= runMin) and aPr - diaPvLowPr >= legAtr * diaLegMinAtr and aW <= fwOS * diaLegZonePct and legWaveLo >= aW + diaLegWaveTol
            if ok and (na(bestW) or aW < bestW)
                bestW    := aW
                legABarB := aBar
                legAValB := aW
            runMin := na(runMin) ? aPr : math.min(runMin, aPr)
    if not na(bestW) and legWaveLo < 0
        bullDivLeg   := true
        bullLegMajor := bestW <= fwOS
    array.push(legLoPr, diaPvLowPr)
    array.push(legLoW, legWaveLo)
    array.push(legLoBar, diaPvBar)
    if array.size(legLoPr) > 16
        array.shift(legLoPr)
        array.shift(legLoW)
        array.shift(legLoBar)

if divEnable and not na(diaPrLow)
    float prevLoSig  = diaLastLoSig
    int   prevLoBar = diaLastLoBar
    float prevLoPr  = diaLastLoPr
    bool bull1 = f_diaTryBull(prevLoSig, prevLoPr, prevLoBar, diaSigAtLow, diaPvLowPr, diaPvBar)
    bool bull2 = not bull1 and f_diaTryBull(diaPrev2LoSig, diaPrev2LoPr, diaPrev2LoBar, diaSigAtLow, diaPvLowPr, diaPvBar)
    if bullDivLeg
        bullDivSwing := true
        diaPlotBarBuy := diaPvBar
        diaPlotValBuy  := legWaveLo
        diaLegABarBuy := legABarB
        diaLegAValBuy  := legAValB
    else if bull1 or bull2
        float legAVal  = bull1 ? prevLoSig : diaPrev2LoSig
        int   legABar = bull1 ? prevLoBar : diaPrev2LoBar
        bullDivSwing := true
        diaPlotBarBuy := diaPvBar
        diaPlotValBuy  := diaSigAtLow
        diaLegABarBuy := legABar
        diaLegAValBuy  := legAVal
    else if effDiaHidden and swingTrendUp and not na(prevLoSig)
        float waveSepLo = diaSigAtLow - prevLoSig
        if diaPvLowPr > prevLoPr and waveSepLo <= -effDiaFwMin * 0.75 and (diaPvLowPr - prevLoPr) >= diaMinPr * 0.45
            hiddenSwingBull := true
            diaPlotBarBuy := diaPvBar
            diaPlotValBuy  := diaSigAtLow
            diaLegABarBuy := prevLoBar
            diaLegAValBuy  := prevLoSig
    diaPrev2LoSig  := diaLastLoSig
    diaPrev2LoPr  := diaLastLoPr
    diaPrev2LoBar := diaLastLoBar
    diaLastLoSig  := diaSigAtLow
    diaLastLoPr  := diaPvLowPr
    diaLastLoBar := diaPvBar
if divEnable and not na(diaPrHi)
    float prevHiSig  = diaLastHiSig
    int   prevHiBar = diaLastHiBar
    float prevHiPr  = diaLastHiPr
    bool bear1 = f_diaTryBear(prevHiSig, prevHiPr, prevHiBar, diaSigAtHi, diaPvHiPr, diaPvBar)
    bool bear2 = not bear1 and f_diaTryBear(diaPrev2HiSig, diaPrev2HiPr, diaPrev2HiBar, diaSigAtHi, diaPvHiPr, diaPvBar)
    if bearDivLeg
        bearDivSwing := true
        diaPlotBarSell := diaPvBar
        diaPlotValSell  := legWaveHi
        diaLegABarSell := legABarS
        diaLegAValSell  := legAValS
    else if bear1 or bear2
        float legAVal  = bear1 ? prevHiSig : diaPrev2HiSig
        int   legABar = bear1 ? prevHiBar : diaPrev2HiBar
        bearDivSwing := true
        diaPlotBarSell := diaPvBar
        diaPlotValSell  := diaSigAtHi
        diaLegABarSell := legABar
        diaLegAValSell  := legAVal
    else if effDiaHidden and swingTrendDn and not na(prevHiSig)
        if diaPvHiPr < prevHiPr and (diaSigAtHi - prevHiSig) >= effDiaFwMin * 0.75 and (prevHiPr - diaPvHiPr) >= diaMinPr * 0.45
            hiddenSwingBear := true
            diaPlotBarSell := diaPvBar
            diaPlotValSell  := diaSigAtHi
            diaLegABarSell := prevHiBar
            diaLegAValSell  := prevHiSig
    diaPrev2HiSig  := diaLastHiSig
    diaPrev2HiPr  := diaLastHiPr
    diaPrev2HiBar := diaLastHiBar
    diaLastHiSig  := diaSigAtHi
    diaLastHiPr  := diaPvHiPr
    diaLastHiBar := diaPvBar
var int lastSwingBullBar = na
var int lastSwingBearBar = na
if bullDivSwing or hiddenSwingBull
    lastSwingBullBar := bar_index
if bearDivSwing or hiddenSwingBear
    lastSwingBearBar := bar_index
bool bullDivSwingRecent = not na(lastSwingBullBar) and bar_index - lastSwingBullBar <= effDivPersist
bool bearDivSwingRecent = not na(lastSwingBearBar) and bar_index - lastSwingBearBar <= effDivPersist
bool bullDivDual   = bullDivDualBase or bullDivSwing
bool bearDivDual   = bearDivDualBase or bearDivSwing
if bullDiv or bullDivFast or bullDivSwing or hiddenBullDiv or hiddenSwingBull
    lastBullDivBar := bar_index
if bearDiv or bearDivFast or bearDivSwing or hiddenBearDiv or hiddenSwingBear
    lastBearDivBar := bar_index
bool bullDivRecent = not na(lastBullDivBar) and bar_index - lastBullDivBar <= effDivPersist
bool bearDivRecent = not na(lastBearDivBar) and bar_index - lastBearDivBar <= effDivPersist
// Strong reversal div - regular (LL+HL / HH+LH), swing fast-path, or hidden continuation
bool bullDivStrong = bullDivDual or bullDivSwing or hiddenBullDiv or hiddenSwingBull or (bullDiv and (bullDivFast or fwSignal[effDivPivR] <= fwOS))
bool bearDivStrong = bearDivDual or bearDivSwing or hiddenBearDiv or hiddenSwingBear or (bearDiv and (bearDivFast or fwSignal[effDivPivR] >= fwOB))
bool bullDivClear = bullDivStrong or (bullDivReg and (fwInOS or fwSignal <= fwOS2 or bullDivRecent))
bool bearDivClear = bearDivStrong or (bearDivReg and (fwInOB or fwSignal >= fwOB2 or bearDivRecent))
bool bullDivActive = bullDivStrong or bullDivRecent or bullDivSwingRecent or hiddenBullDiv
bool bearDivActive = bearDivStrong or bearDivRecent or bearDivSwingRecent or hiddenBearDiv

// Weighted confluence score - extreme zone + div + engines
oscScore := math.min(100, (fwBull ? 12 : fwBear ? 12 : 0) + (oscAllBull ? 22 : oscAllBear ? 22 : engBull * 6) + (bullDivActive ? 14 : bearDivActive ? 14 : 0) + (bullDivDual or bearDivDual ? 8 : 0) + (fwSignal <= fwOS2 or fwSignal >= fwOB2 ? 12 : fwInOS or fwInOB ? 8 : 0) + (fwCrossUp or fwCrossDn ? 8 : 0) + (fwRising and fwBull ? 6 : fwFalling and fwBear ? 6 : 0))

if divEnable and divShowLabels and (bullDiv or bullDivFast)
    label.new(pvBar, pvLowSig, "*", yloc=yloc.price, style=label.style_label_up, color=color.new(colPanel, 20), textcolor=C_DIA_BUY, size=size.tiny)
if divEnable and divShowLabels and (bearDiv or bearDivFast)
    label.new(pvBar, pvHiSig, "*", yloc=yloc.price, style=label.style_label_down, color=color.new(colPanel, 20), textcolor=C_DIA_SELL, size=size.tiny)

// ======================= ANCHORED VWAPs (signal sync - no drawing) ===========
bool isNewDay  = timeframe.change("D")
bool isNewWeek = timeframe.change("W")
var float cumPV = 0.0
var float cumV  = 0.0
float basePV = cumPV
float baseV  = cumV
cumPV += vwapSrc * volume
cumV  += volume
f_avwap(_basePV, _baseV) => (cumV - _baseV) > 0 ? (cumPV - _basePV) / (cumV - _baseV) : na

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

float dailyVWAP = f_avwap(dBasePV,  dBaseV)
float pdayVWAP  = f_avwap(pdBasePV, pdBaseV)
float weekVWAP  = f_avwap(wBasePV,  wBaseV)
float pweekVWAP = f_avwap(pwBasePV, pwBaseV)
float vwap5     = na(b5PV) ? na : f_avwap(b5PV, b5V)

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

float tol = vwapEnable and not na(nearestVWAP) ? nearestVWAP * (vwapTouchPct / 100.0) : na
bool vwapTestUp = vwapEnable and not na(nearestVWAP) and (low <= nearestVWAP + tol) and (close > nearestVWAP)
bool vwapTestDn = vwapEnable and not na(nearestVWAP) and (high >= nearestVWAP - tol) and (close < nearestVWAP)
bool aboveDaily = vwapEnable and not na(dailyVWAP) and close > dailyVWAP
bool belowDaily = vwapEnable and not na(dailyVWAP) and close < dailyVWAP
bool abovePday  = vwapEnable and not na(pdayVWAP)  and close > pdayVWAP
bool belowPday  = vwapEnable and not na(pdayVWAP)  and close < pdayVWAP
bool vwapKeyBuy  = not sigReqDailyVWAP or (effSoftDailyVwap ? (aboveDaily or (vwapTestUp and priceAboveAV) or (priceAboveAV and abovePday)) : (aboveDaily and (abovePday or priceAboveAV or vwapTestUp)))
bool vwapKeySell = not sigReqDailyVWAP or (effSoftDailyVwap ? (belowDaily or (vwapTestDn and priceBelowAV) or (priceBelowAV and belowPday)) : (belowDaily and (belowPday or priceBelowAV or vwapTestDn)))

// ======================= MARKET STRUCTURE + ORACLE ANALYSIS =================
float trendSrc = haOn ? haClose : close
float trendEMA = ta.ema(trendSrc, sigEMAlen)
bool  trendUp  = trendSrc > trendEMA
bool  trendDn  = trendSrc < trendEMA

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
float sigRes618 = na
float sigRes65  = na
float sigRes786 = na
float sigSup618 = na
float sigSup65  = na
float sigSup786 = na
if not na(msLowBar)
    int bLoB = msLowBar
    [bHi, bHiB] = f_findLegHigh(math.max(0, bLoB - effFibLegLook), bLoB)
    [bLo, _bLo2] = f_findLegLow(bHiB, bLoB)
    if not na(bHi) and not na(bLo) and bHi > bLo
        sigRes618 := f_fibPrice(false, bHi, bLo, 0.618)
        sigRes65  := f_fibPrice(false, bHi, bLo, 0.65)
        sigRes786 := f_fibPrice(false, bHi, bLo, 0.786)
if not na(msHighBar)
    int bHiB = msHighBar
    [bLo, bLoB] = f_findLegLow(math.max(0, bHiB - effFibLegLook), bHiB)
    [bHi, _bHi2] = f_findLegHigh(bLoB, bHiB)
    if not na(bHi) and not na(bLo) and bHi > bLo
        sigSup618 := f_fibPrice(true, bHi, bLo, 0.618)
        sigSup65  := f_fibPrice(true, bHi, bLo, 0.65)
        sigSup786 := f_fibPrice(true, bHi, bLo, 0.786)
float sigDn786 = na
float sigDn65  = na
if not na(msLowBar)
    int bLoB3 = msLowBar
    [bHi3, bHiB3] = f_findLegHigh(math.max(0, bLoB3 - effFibLegLook), bLoB3)
    [bLo3, _bLoB4] = f_findLegLow(bHiB3, bLoB3)
    if not na(bHi3) and not na(bLo3) and bHi3 > bLo3
        sigDn786 := f_fibFromHigh(bHi3, bLo3, 0.786)
        sigDn65  := f_fibFromHigh(bHi3, bLo3, 0.65)
bool structBull = not na(msHigh) and close > msHigh
bool structBear = not na(msLow)  and close < msLow
bool liqSweepBull = not na(msLow)  and low  < msLow  and close > msLow
bool liqSweepBear = not na(msHigh) and high > msHigh and close < msHigh

float mfBody    = (high - low) != 0 ? ((close - open) / (high - low)) * volume : 0.0
float mfBodyAvg = ta.sma(mfBody, effMfBodyLen)
float mfVolAvg  = ta.sma(volume, 14)
float mfNorm    = mfVolAvg != 0 ? mfBodyAvg / mfVolAvg * 100 : 0.0
bool  mfIn      = mfNorm >= 0
bool  mfOut     = mfNorm < 0

var int lastSigBar = na
var int lastSigDir = na
int barsSinceSig = na(lastSigBar) ? 9999 : bar_index - lastSigBar
bool haGateBuy  = haTrendBuy and haThrustBuy
bool haGateSell = haTrendSell and haThrustSell
int  barsSinceCrossUp = ta.barssince(fwCrossUp)
int  barsSinceCrossDn = ta.barssince(fwCrossDn)
int  barsSinceOS = ta.barssince(fwSignal <= fwOS)
int  barsSinceOB = ta.barssince(fwSignal >= fwOB)
bool fwRecentCrossUp = effFwTrigBars > 0 and barsSinceCrossUp <= effFwTrigBars
bool fwRecentCrossDn = effFwTrigBars > 0 and barsSinceCrossDn <= effFwTrigBars
bool fluxMomBuy  = (fwCrossUp and (fwInOS or barsSinceOS <= effOscZoneBars)) or bullDivActive or hiddenBullDiv
bool fluxMomSell = (fwCrossDn and (fwInOB or barsSinceOB <= effOscZoneBars)) or bearDiv or hiddenBearDiv
bool fwTrigBuy  = fluxMomBuy or (effFwTrigBars > 0 and fwRecentCrossUp and fwBull and fwRising and fwSignal <= effZoneBuyMax)
bool fwTrigSell = fluxMomSell or (effFwTrigBars > 0 and fwRecentCrossDn and fwBear and fwFalling and fwSignal >= effZoneSellMin)
bool momOkBuy   = fluxMomBuy or (effFwTrigBars > 0 and fwRecentCrossUp and fwBull and fwRising)
bool momOkSell  = fluxMomSell or (effFwTrigBars > 0 and fwRecentCrossDn and fwBear and fwFalling)
int engBullCnt = (oscMom > 0 ? 1 : 0) + (oscVwap > 0 ? 1 : 0) + (oscMf > 0 ? 1 : 0)
int engBearCnt = (oscMom < 0 ? 1 : 0) + (oscVwap < 0 ? 1 : 0) + (oscMf < 0 ? 1 : 0)
float sigFibTol = math.max(close, syminfo.mintick) * (vwapTouchPct / 100.0)
bool fibRejRes65  = not na(sigRes65)  and high >= sigRes65  - sigFibTol and low <= sigRes65  + sigFibTol and close < sigRes65
bool fibRejRes618 = not na(sigRes618) and high >= sigRes618 - sigFibTol and low <= sigRes618 + sigFibTol and close < sigRes618
bool fibRejRes786 = not na(sigRes786) and high >= sigRes786 - sigFibTol and low <= sigRes786 + sigFibTol and close < sigRes786
bool fibRejSup65  = not na(sigSup65)  and low <= sigSup65  + sigFibTol and high >= sigSup65  - sigFibTol and close > sigSup65
bool fibRejSup618 = not na(sigSup618) and low <= sigSup618 + sigFibTol and high >= sigSup618 - sigFibTol and close > sigSup618
bool fibRejSup786 = not na(sigSup786) and low <= sigSup786 + sigFibTol and high >= sigSup786 - sigFibTol and close > sigSup786
bool fibTouchDn786 = not na(sigDn786) and low <= sigDn786 + sigFibTol and high >= sigDn786 - sigFibTol
bool fibTouchDn65  = not na(sigDn65)  and low <= sigDn65  + sigFibTol and high >= sigDn65  - sigFibTol
bool fibRejDn786   = fibTouchDn786 and close > sigDn786
bool fibRejDn65    = fibTouchDn65  and close > sigDn65
bool fibKeyRejSell = fibRejRes65 or fibRejRes618 or fibRejRes786
bool fibKeyRejBuy  = fibRejSup65 or fibRejSup618 or fibRejSup786 or fibRejDn786 or fibRejDn65
bool fibSupDeep    = fibRejDn786 or fibRejDn65 or fibRejSup786 or fibRejSup65
bool fibMajorBuy   = fibRejDn786 or fibRejSup786 or fibRejSup618
bool fibMajorSell  = fibRejRes618 or fibRejRes786 or fibRejRes65
bool fibTouchRes618 = not na(sigRes618) and high >= sigRes618 - sigFibTol and low <= sigRes618 + sigFibTol
bool fibTouchRes786 = not na(sigRes786) and high >= sigRes786 - sigFibTol and low <= sigRes786 + sigFibTol
bool fibTouchSup618 = not na(sigSup618) and low <= sigSup618 + sigFibTol and high >= sigSup618 - sigFibTol
bool fibTouchSup786 = not na(sigSup786) and low <= sigSup786 + sigFibTol and high >= sigSup786 - sigFibTol
bool fibTouchMajorBuy  = fibMajorBuy or fibTouchDn786 or fibTouchSup786 or fibTouchSup618
bool fibTouchMajorSell = fibMajorSell or fibTouchRes618 or fibTouchRes786
bool fibNearStructLow  = not na(msLow)  and low <= msLow + sigFibTol * 2 and close >= msLow
bool fibNearStructHigh = not na(msHigh) and high >= msHigh - sigFibTol * 2 and close <= msHigh
bool mfShiftBear = mfOut and (mfIn[1] or mfIn[2])
bool mfShiftBull = mfIn and (mfOut[1] or mfOut[2])
bool mfShiftStrongBull = mfShiftBull and mf > mf[1] and oscMf > oscMf[1] and oscMf[1] <= 0
bool mfShiftStrongBear = mfShiftBear and mf < mf[1] and oscMf < oscMf[1] and oscMf[1] >= 0
bool bullDivElite   = bullDiv and (fwInOS or fwSignal <= fwOS2)
bool bearDivElite   = bearDiv and (fwInOB or fwSignal >= fwOB2)
int engBearPrev = (oscMom[1] > 0 ? 1 : 0) + (oscVwap[1] > 0 ? 1 : 0) + (oscMf[1] > 0 ? 1 : 0)
int engBullPrev = (oscMom[1] < 0 ? 1 : 0) + (oscVwap[1] < 0 ? 1 : 0) + (oscMf[1] < 0 ? 1 : 0)
bool waveRollBear = engBearCnt >= 2 and fwBear and fwFalling and (fwCrossDn or engBearCnt > engBearPrev or fwPrimary < fwPrimary[2])
bool waveRollBull = engBullCnt >= 2 and fwBull and fwRising and (fwCrossUp or engBullCnt > engBullPrev or fwPrimary > fwPrimary[2])
bool revTripleSell = sigFibRev and fibMajorSell and waveRollBear and mfShiftBear and (bearDivElite or bearDiv or hiddenBearDiv or fwInOB)
bool revTripleBuy  = sigFibRev and fibMajorBuy and waveRollBull and mfShiftBull and (bullDivElite or bullDivActive or fwInOS)
bool revConfluenceBuy = fibSupDeep and bullDivActive and waveRollBull and mfShiftBull and fibMajorBuy
int fibBonOscSell = fibKeyRejSell ? (waveRollBear ? 6 : 3) + (revTripleSell ? 4 : 0) : 0
int fibBonOscBuy  = fibKeyRejBuy  ? (waveRollBull ? 6 : 3) + (revTripleBuy  ? 4 : 0) : 0
int fibBonStrSell = mfShiftBear and fibKeyRejSell ? 5 : 0
int fibBonStrBuy  = (mfShiftBull or mfIn) and fibSupDeep ? 5 : mfShiftBull and fibKeyRejBuy ? 5 : 0
int revBuyBon     = revConfluenceBuy ? (fibRejDn786 or fibRejSup786 ? 6 : 4) + (bullDiv ? 4 : bullDivRecent ? 2 : 0) + (waveRollBull ? 3 : 0) + (mfShiftBull ? 3 : 0) : 0
bool legVWAPbull = not sigUseVWAP or priceAboveAV or vwapTestUp
bool legVWAPbear = not sigUseVWAP or priceBelowAV or vwapTestDn
bool legTrendUp  = not sigUseTrend or trendUp
bool legTrendDn  = not sigUseTrend or trendDn

int pOscBuy  = (fwBull ? 6 : 0) + (oscAllBull ? 8 : 0) + ((fwCrossUp or bullDivActive or hiddenBullDiv) ? 6 : 0) + (not fwInOB ? 5 : 0) + (fwRising and fwBull ? 3 : 0) + (hiddenBullDiv ? 4 : 0)
int pVwapBuy = (priceAboveAV ? 8 : 0) + (vwapTestUp ? 6 : 0) + (aboveDaily ? 6 : 0) + (abovePday ? 5 : 0)
int pHaBuy   = not haOn ? 14 : (haBull ? 8 : 0) + (haRun >= effHaMinRun ? 7 : 0) + (haBodyR >= haMinBody ? 5 : 0) + (haWickRejBuy ? 5 : 0) + (haStrongBull ? 3 : 0)
int pStrBuy  = (trendUp ? 7 : 0) + (structBull ? 8 : 0) + (liqSweepBull ? 5 : 0) + (mfIn ? 5 : 0)
int oracleBuy = pOscBuy + pVwapBuy + pHaBuy + pStrBuy + fibBonOscBuy + fibBonStrBuy + revBuyBon

int pOscSell  = (fwBear ? 6 : 0) + (oscAllBear ? 8 : 0) + ((fwCrossDn or bearDiv or hiddenBearDiv) ? 6 : 0) + (not fwInOS ? 5 : 0) + (fwFalling and fwBear ? 3 : 0) + (hiddenBearDiv ? 4 : 0)
int pVwapSell = (priceBelowAV ? 8 : 0) + (vwapTestDn ? 6 : 0) + (belowDaily ? 6 : 0) + (belowPday ? 5 : 0)
int pHaSell   = not haOn ? 14 : (haBear ? 8 : 0) + (haRun <= -effHaMinRun ? 7 : 0) + (haBodyR >= haMinBody ? 5 : 0) + (haWickRejSell ? 5 : 0) + (haStrongBear ? 3 : 0)
int pStrSell  = (trendDn ? 7 : 0) + (structBear ? 8 : 0) + (liqSweepBear ? 5 : 0) + (mfOut ? 5 : 0)
int oracleSell = pOscSell + pVwapSell + pHaSell + pStrSell + fibBonOscSell + fibBonStrSell

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

// -- Chop filter: ADX regime + BB squeeze + HA body + Flux Wave momentum --
[_, _, adxVal] = ta.dmi(chopAdxLen, chopAdxLen)
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
bool regimeAllowsStrongStd = not regimeGateStrong or chopAdxTrend
bool regimeAllowsStrongRev = not regimeGateStrong or not chopModeHard

// -- Scalp confluence gate (Flux Wave + MF + VWAP + pillar depth) --
bool scalpFwMfBuy   = fwBull and mfIn and (fwRising or fwCrossUp or waveRollBull)
bool scalpFwMfSell  = fwBear and mfOut and (fwFalling or fwCrossDn or waveRollBear)
bool scalpVwapBuy   = not effScalpStrictVwap or not sigUseVWAP or priceAboveAV or vwapTestUp
bool scalpVwapSell  = not effScalpStrictVwap or not sigUseVWAP or priceBelowAV or vwapTestDn
bool scalpWaveBuy   = not scalpActive or waveRollBull or fwCrossUp or (engBullCnt >= 2 and fwRising)
bool scalpWaveSell  = not scalpActive or waveRollBear or fwCrossDn or (engBearCnt >= 2 and fwFalling)
bool scalpConfluenceBuy  = not scalpActive or (scalpFwMfBuy and scalpVwapBuy and scalpWaveBuy and pillBuyCnt >= effPillarsNeed and pVwapBuy >= effPillarMin and pOscBuy >= effPillarMin and not (chopAdxBlock and chopBbSqueeze))
bool scalpConfluenceSell = not scalpActive or (scalpFwMfSell and scalpVwapSell and scalpWaveSell and pillSellCnt >= effPillarsNeed and pVwapSell >= effPillarMin and pOscSell >= effPillarMin and not (chopAdxBlock and chopBbSqueeze))

bool exhaustSignBuy  = revTripleBuy or (waveRollBull and mfShiftBull and fibMajorBuy)
bool exhaustSignSell = revTripleSell or (waveRollBear and mfShiftBear and fibMajorSell)
bool eliteStrongBuyRev = revTripleBuy and engBullCnt >= 2 and waveRollBull and mfShiftBull
bool eliteStrongSellRev = revTripleSell and engBearCnt >= 2 and waveRollBear and mfShiftBear
bool eliteStrongBuy  = scalpActive ? (exhaustSignBuy and engBullCnt >= 2 and mfShiftBull) : (eliteStrongBuyRev or (engBullCnt >= 3 and pVwapBuy >= effPillarMin and pStrBuy >= effPillarMin))
bool eliteStrongSell = scalpActive ? (exhaustSignSell and engBearCnt >= 2 and mfShiftBear) : (eliteStrongSellRev or (engBearCnt >= 3 and pVwapSell >= effPillarMin and pStrSell >= effPillarMin))
bool vwapKeyBuyEff   = vwapKeyBuy or (revTripleBuy and (vwapTestUp or liqSweepBull))
bool vwapKeySellEff  = vwapKeySell or (revTripleSell and (vwapTestDn or liqSweepBear))
bool legTrendUpEff   = legTrendUp or (revTripleBuy and (liqSweepBull or waveRollBull))
bool legTrendDnEff   = legTrendDn or (revTripleSell and (liqSweepBear or waveRollBear))
bool godPillarsBuy   = pillBuyCnt >= effPillarsNeed and pOscBuy >= effPillarMin and pHaBuy >= effPillarMin and pVwapBuy >= effPillarMin and pStrBuy >= effPillarMin
bool godPillarsSell  = pillSellCnt >= effPillarsNeed and pOscSell >= effPillarMin and pHaSell >= effPillarMin and pVwapSell >= effPillarMin and pStrSell >= effPillarMin
bool godEngineBuy    = engBullCnt >= 2 and (oscAllBull or waveRollBull or revTripleBuy)
bool godEngineSell   = engBearCnt >= 2 and (oscAllBear or waveRollBear or revTripleSell)

// ======= FLUX SYNC - Chart context + oscillator pane momentum ===============
// Identical to Oracle_Flux.pine - diamonds mirror main chart STRONG BUY/SELL on the same bar.
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
bool strongBuyRev  = sigEnable and revTripleBuy and haGateBuy and mfShiftBull and oscOkBuy and chopOkStrong and godPillarsBuy and pillBuyCnt >= 3 and oracleBuy >= effRevOracleBuy and bullDivActive and fluxSyncBuy and regimeAllowsStrongRev
bool strongSellRev = sigEnable and revTripleSell and haGateSell and mfShiftBear and oscOkSell and chopOkStrong and godPillarsSell and pillSellCnt >= 3 and oracleSell >= effRevOracleSell and (bearDivElite or bearDiv or fwInOB) and fluxSyncSell and regimeAllowsStrongRev
bool strongBuy  = strongBuyStd or strongBuyRev
bool strongSell = strongSellStd or strongSellRev

// Normal signals - cooldown sync only (must match main Oracle Flux; not plotted)
int normBuyCnt  = (pOscBuy >= effPillarMinNorm ? 1 : 0) + (pVwapBuy >= effPillarMinNorm ? 1 : 0) + (pHaBuy >= effPillarMinNorm ? 1 : 0) + (pStrBuy >= effPillarMinNorm ? 1 : 0)
int normSellCnt = (pOscSell >= effPillarMinNorm ? 1 : 0) + (pVwapSell >= effPillarMinNorm ? 1 : 0) + (pHaSell >= effPillarMinNorm ? 1 : 0) + (pStrSell >= effPillarMinNorm ? 1 : 0)
bool normalBuy  = sigEnable and haGateBuy and momOkBuy and fwBull and legVWAPbull and legTrendUp and mfOkBuy and chopOkNormal and normBuyCnt >= 3 and pHaBuy >= effPillarMinNorm and (oracleBuy >= effOracleNormal) and (oracleBuy < effStrongOracleBuy) and zoneOkBuy and not strongBuy
bool normalSell = sigEnable and haGateSell and momOkSell and fwBear and legVWAPbear and legTrendDn and mfOkSell and chopOkNormal and normSellCnt >= 3 and pHaSell >= effPillarMinNorm and (oracleSell >= effOracleNormal) and (oracleSell < effStrongOracleSell) and zoneOkSell and not strongSell

bool oppRevBuyCd  = lastSigDir == -1 and revTripleBuy
int  effCdNow     = oppRevBuyCd ? effRevCdBars : effCooldown
bool cooldownOK   = na(lastSigBar) or barsSinceSig >= effCdNow

// Identical fire + cooldown chain as Oracle_Flux.pine overlay
bool fireStrongBuy  = showStrong and strongBuy  and cooldownOK
bool fireStrongSell = showStrong and strongSell and cooldownOK
bool fireNormalBuy  = effShowNormal and normalBuy  and not strongBuy  and cooldownOK
bool fireNormalSell = effShowNormal and normalSell and not strongSell and cooldownOK
bool anyBuy  = fireStrongBuy  or fireNormalBuy
bool anySell = fireStrongSell or fireNormalSell

if anyBuy or anySell
    lastSigBar := bar_index
    lastSigDir := anyBuy ? 1 : -1

// ======= DIVERGENCE DIAMOND ENGINE ===========================================
// Regular A->B divergence - dual-line confirm - price pivots - conviction score

f_fluxFrTop(_src) =>
    _src[4] < _src[2] and _src[3] < _src[2] and _src[2] > _src[1] and _src[2] > _src[0]

f_fluxFrBot(_src) =>
    _src[4] > _src[2] and _src[3] > _src[2] and _src[2] < _src[1] and _src[2] < _src[0]

float fluxDivOS1 = fwOS + 5.0
float fluxDivOB1 = fwOB - 15.0
float fluxDivOS2 = fwOS + 20.0
float fluxDivOB2 = fwOB - 45.0

bool  fluxFrTop2 = f_fluxFrTop(fwSignal)
bool  fluxFrBot2 = f_fluxFrBot(fwSignal)
bool  fluxFrTop1 = diaFractalPrimary and f_fluxFrTop(fwPrimary)
bool  fluxFrBot1 = diaFractalPrimary and f_fluxFrBot(fwPrimary)
float fluxSigP    = fwSignal[2]
float fluxHiP    = high[2]
float fluxLoP    = low[2]
int   fluxBarP   = bar_index - 2

float fluxPrevTopSig  = ta.valuewhen(fluxFrTop2, fluxSigP, 1)
float fluxPrevTopPr  = ta.valuewhen(fluxFrTop2, fluxHiP, 1)
int   fluxPrevTopBar = int(ta.valuewhen(fluxFrTop2, fluxBarP, 1))
float fluxPrevBotSig  = ta.valuewhen(fluxFrBot2, fluxSigP, 1)
float fluxPrevBotPr  = ta.valuewhen(fluxFrBot2, fluxLoP, 1)
int   fluxPrevBotBar = int(ta.valuewhen(fluxFrBot2, fluxBarP, 1))

// Textbook fractal regular div: leg A in OS/OB - leg B price extreme - wave disagreement
bool fluxBear1 = divEnable and fluxFrTop2 and not na(fluxPrevTopSig) and fluxPrevTopSig >= fluxDivOB1 and fluxHiP > fluxPrevTopPr and fluxSigP < fluxPrevTopSig and (fluxPrevTopSig - fluxSigP) >= (divMasterMode ? effDiaFwMin * 0.85 : 0.0)
bool fluxBull1 = divEnable and fluxFrBot2 and not na(fluxPrevBotSig) and fluxPrevBotSig <= fluxDivOS1 and fluxLoP < fluxPrevBotPr and fluxSigP > fluxPrevBotSig and (fluxSigP - fluxPrevBotSig) >= (divMasterMode ? effDiaFwMin * 0.85 : 0.0)
bool fluxBear2 = divEnable and fluxFrTop2 and not na(fluxPrevTopSig) and fluxPrevTopSig >= fluxDivOB2 and fluxPrevTopSig < fluxDivOB1 and fluxHiP > fluxPrevTopPr and fluxSigP < fluxPrevTopSig
bool fluxBull2 = divEnable and fluxFrBot2 and not na(fluxPrevBotSig) and fluxPrevBotSig <= fluxDivOS2 and fluxPrevBotSig > fluxDivOS1 and fluxLoP < fluxPrevBotPr and fluxSigP > fluxPrevBotSig
bool fluxBearH = divEnable and effDiaHidden and fluxFrTop2 and swingTrendDn and not na(fluxPrevTopSig) and fluxHiP < fluxPrevTopPr and fluxSigP > fluxPrevTopSig
bool fluxBullH = divEnable and effDiaHidden and fluxFrBot2 and swingTrendUp and not na(fluxPrevBotSig) and fluxLoP > fluxPrevBotPr and fluxSigP < fluxPrevBotSig

// Flux Wave cross exhaustion in OS/OB
bool fluxInOS  = fwSignal <= fwOS or fwSignal[1] <= fwOS or fwSignal[2] <= fwOS or fluxSigP <= fwOS + effDiaZonePad or fluxPrevBotSig <= fwOS + effDiaZonePad
bool fluxInOB  = fwSignal >= fwOB or fwSignal[1] >= fwOB or fwSignal[2] >= fwOB or fluxSigP >= fwOB - effDiaZonePad or fluxPrevTopSig >= fwOB - effDiaZonePad
int  fluxXLook = math.max(effDiaPivR + 2, 8)
bool fluxCrossB = fwCrossUp or fwCrossUp[1] or fwCrossUp[2] or (fwBull and barsSinceCrossUp <= fluxXLook)
bool fluxCrossS = fwCrossDn or fwCrossDn[1] or fwCrossDn[2] or (fwBear and barsSinceCrossDn <= fluxXLook)
bool fluxOrientB = fwSignal - fwPrimary <= 0 or fwSignal[2] - fwPrimary[2] <= 0
bool fluxOrientS = fwSignal - fwPrimary >= 0 or fwSignal[2] - fwPrimary[2] >= 0

// Flux MF area + oscMf shift
bool fluxMfOkB = mfShiftBull or mfIn or fluxMfiShiftB or (diaUseFluxMf and fluxMfiBull) or (fluxInOS and oscMf > oscMf[1]) or (not na(mf) and mf >= mf[1] and fluxInOS)
bool fluxMfOkS = mfShiftBear or mfOut or fluxMfiShiftS or (diaUseFluxMf and fluxMfiBear) or (fluxInOB and oscMf < oscMf[1]) or (not na(mf) and mf <= mf[1] and fluxInOB)

// Primary-signal spread reversal at extremes
bool fluxVwapB = diaUseVwapMom and fluxInOS and (fluxSpreadUp or fluxWaveSpread > fluxWaveSpread[2])
bool fluxVwapS = diaUseVwapMom and fluxInOB and (fluxSpreadDn or fluxWaveSpread < fluxWaveSpread[2])

// Flux Fair Value agree - mid-line hook / zero bias with divergence
bool fvAgreeBuy  = diaUseFairValue and (ivTrough or fvCrossUp or (fvRising and (fluxInOS or fluxFairValue < 8.0)) or (fvBullBias and fvRising and fluxFairValue > fluxFairValue[2]))
bool fvAgreeSell = diaUseFairValue and (ivPeak or fvCrossDn or (fvFalling and (fluxInOB or fluxFairValue > -8.0)) or (fvBearBias and fvFalling and fluxFairValue < fluxFairValue[2]))

// Regular divergence sources only (fast-alone / hidden-alone do not print <> by default)
bool regularBullDiv = bullDivSwing or bullDiv or fluxBull1 or fluxBull2
bool regularBearDiv = bearDivSwing or bearDiv or fluxBear1 or fluxBear2
bool rawDivB = regularBullDiv or (effDiaHidden and (fluxBullH or hiddenSwingBull or hiddenBullDiv))
bool rawDivS = regularBearDiv or (effDiaHidden and (fluxBearH or hiddenSwingBear or hiddenBearDiv))

// Master confirm - dual-line, price+wave, or deep extreme textbook structure
bool divConfirmBuy  = not diaRequireRegular or bullDivLeg or (bullDivDual or (bullDiv and bullDivSwing) or (bullDivSwing and fluxInOS) or (fluxBull1 and (fluxMfOkB or fluxCrossB or bullDivFast)) or (bullDiv and (bullDivFast or fluxInOS or fluxMfOkB)) or (not regularBullDiv and effDiaHidden and (hiddenBullDiv or hiddenSwingBull) and fluxMfOkB))
bool divConfirmSell = not diaRequireRegular or bearDivLeg or (bearDivDual or (bearDiv and bearDivSwing) or (bearDivSwing and fluxInOB) or (fluxBear1 and (fluxMfOkS or fluxCrossS or bearDivFast)) or (bearDiv and (bearDivFast or fluxInOB or fluxMfOkS)) or (not regularBearDiv and effDiaHidden and (hiddenBearDiv or hiddenSwingBear) and fluxMfOkS))

// -- Divergence diamond conviction score (0-100) --
int diaScoreBuy  = 0
int diaScoreSell = 0
if rawDivB
    // Core structure - textbook regular divergence weighted highest
    diaScoreBuy += fluxBull1 ? 38 : (bullDivSwing and bullDiv) ? 40 : bullDivSwing ? 34 : bullDiv ? 30 : fluxBull2 ? 24 : (fluxBullH or hiddenSwingBull or hiddenBullDiv) ? 16 : 0
    diaScoreBuy += bullDivDual ? 14 : bullDivFast ? 7 : 0
    diaScoreBuy += fluxCrossB and fluxOrientB ? 14 : fluxCrossB ? 8 : 0
    diaScoreBuy += fluxMfOkB and mfShiftBull ? 14 : fluxMfOkB ? 8 : 0
    diaScoreBuy += fluxVwapB ? 6 : 0
    diaScoreBuy += fvAgreeBuy ? 6 : 0
    diaScoreBuy += fluxFrBot1 ? 6 : 0
    diaScoreBuy += fluxSigP <= fwOS2 or fluxPrevBotSig <= fwOS2 or (not na(pvLowSig) and pvLowSig <= fwOS2) ? 16 : fluxInOS ? 8 : 0
    diaScoreBuy += waveRollBull ? 6 : 0
    diaScoreBuy += bullLegMajor ? 10 : bullDivLeg ? 5 : 0
if rawDivS
    diaScoreSell += fluxBear1 ? 38 : (bearDivSwing and bearDiv) ? 40 : bearDivSwing ? 34 : bearDiv ? 30 : fluxBear2 ? 24 : (fluxBearH or hiddenSwingBear or hiddenBearDiv) ? 16 : 0
    diaScoreSell += bearDivDual ? 14 : bearDivFast ? 7 : 0
    diaScoreSell += fluxCrossS and fluxOrientS ? 14 : fluxCrossS ? 8 : 0
    diaScoreSell += fluxMfOkS and mfShiftBear ? 14 : fluxMfOkS ? 8 : 0
    diaScoreSell += fluxVwapS ? 6 : 0
    diaScoreSell += fvAgreeSell ? 6 : 0
    diaScoreSell += fluxFrTop1 ? 6 : 0
    diaScoreSell += fluxSigP >= fwOB2 or fluxPrevTopSig >= fwOB2 or (not na(pvHiSig) and pvHiSig >= fwOB2) ? 16 : fluxInOB ? 8 : 0
    diaScoreSell += waveRollBear ? 6 : 0
    diaScoreSell += bearLegMajor ? 10 : bearDivLeg ? 5 : 0

bool divPivotBuy  = divEnable and rawDivB and divConfirmBuy and diaScoreBuy >= effDiaMinScore and (not diaRequireCross or (fluxCrossB and fluxOrientB and fluxInOS)) and (not diaRequireMf or fluxMfOkB)
bool divPivotSell = divEnable and rawDivS and divConfirmSell and diaScoreSell >= effDiaMinScore and (not diaRequireCross or (fluxCrossS and fluxOrientS and fluxInOB)) and (not diaRequireMf or fluxMfOkS)
bool revDiamondBuy  = divPivotBuy
bool revDiamondSell = divPivotSell
bool diamondEliteBuy  = divPivotBuy  and diaScoreBuy  >= effDiaEliteScore
bool diamondEliteSell = divPivotSell and diaScoreSell >= effDiaEliteScore
// Master dual/extreme regular div can pass RANGE bump; CHOP still elite-only
bool diaMasterBuy  = regularBullDiv and (bullDivDual or fluxBull1 or (bullDivSwing and bullDiv)) and (fluxInOS or diaScoreBuy >= effDiaEliteScore - 4)
bool diaMasterSell = regularBearDiv and (bearDivDual or fluxBear1 or (bearDivSwing and bearDiv)) and (fluxInOB or diaScoreSell >= effDiaEliteScore - 4)
bool legBypassBuy  = diaLegBypass and bullLegMajor
bool legBypassSell = diaLegBypass and bearLegMajor
bool diaRegimeOkBuy  = not diaRegimeFilter or legBypassBuy or (chopModeHard ? diamondEliteBuy : chopModeActive ? (diamondEliteBuy or diaMasterBuy or diaScoreBuy >= effDiaMinScore + effDiaRangeBump) : true)
bool diaRegimeOkSell = not diaRegimeFilter or legBypassSell or (chopModeHard ? diamondEliteSell : chopModeActive ? (diamondEliteSell or diaMasterSell or diaScoreSell >= effDiaMinScore + effDiaRangeBump) : true)

// Plot anchor - best source: price pivot > signal fractal (offset -2)
var int   fluxDiaBarB  = na
var float fluxDiaValB   = na
var int   fluxDiaBarS  = na
var float fluxDiaValS   = na
var int   fluxDiaLegB  = na
var float fluxDiaLegValB = na
var int   fluxDiaLegS  = na
var float fluxDiaLegValS = na
if divPivotBuy
    bool useSwing = bullDivSwing and not na(diaPlotBarBuy)
    bool usePv    = (bullDiv or bullDivFast) and not useSwing
    fluxDiaBarB   := useSwing ? diaPlotBarBuy : usePv ? pvBar : fluxBarP
    fluxDiaValB    := useSwing ? diaPlotValBuy  : usePv ? nz(pvLowSig, fluxSigP) : fluxSigP
    fluxDiaLegB   := useSwing ? diaLegABarBuy : usePv ? lastPivLowBar : fluxPrevBotBar
    fluxDiaLegValB := useSwing ? diaLegAValBuy  : usePv ? lastPivLowSig  : fluxPrevBotSig
if divPivotSell
    bool useSwingS = bearDivSwing and not na(diaPlotBarSell)
    bool usePvS    = (bearDiv or bearDivFast) and not useSwingS
    fluxDiaBarS   := useSwingS ? diaPlotBarSell : usePvS ? pvBar : fluxBarP
    fluxDiaValS    := useSwingS ? diaPlotValSell  : usePvS ? nz(pvHiSig, fluxSigP) : fluxSigP
    fluxDiaLegS   := useSwingS ? diaLegABarSell : usePvS ? lastPivHiBar : fluxPrevTopBar
    fluxDiaLegValS := useSwingS ? diaLegAValSell  : usePvS ? lastPivHiSig  : fluxPrevTopSig

var int lastDiaBuyBar  = na
var int lastDiaSellBar = na
bool diaCdBuyOk        = legBypassBuy or na(lastDiaBuyBar) or bar_index - lastDiaBuyBar >= effDiaCooldown
bool diaCdSellOk       = legBypassSell or na(lastDiaSellBar) or bar_index - lastDiaSellBar >= effDiaCooldown
bool diamondStrongBuy  = showStrongDiamonds and revDiamondBuy and diaCdBuyOk and diaRegimeOkBuy and not revDiamondBuy[1]
bool diamondStrongSell = showStrongDiamonds and revDiamondSell and diaCdSellOk and diaRegimeOkSell and not revDiamondSell[1]
if diamondStrongBuy
    lastDiaBuyBar := bar_index
if diamondStrongSell
    lastDiaSellBar := bar_index

// ======= TOP / BOTTOM ENGINE =================================================
// Arm: diamond (or blow-off) at the major swing extreme. Fire: wave + engines turn AND price breaks structure.
// One TOP per swing - a lower high cannot re-arm until a BOTTOM fires (and vice versa).
var float tbTopLvl  = na
var int   tbTopBar  = na
var int   tbTopArm  = na
var bool  tbTopA    = false
var float tbTopLock = na
var float tbBotLvl  = na
var int   tbBotBar  = na
var int   tbBotArm  = na
var bool  tbBotA    = false
var float tbBotLock = na
int   tbWin      = effDiaPivR + 4
float tbRecentHi = ta.highest(high, tbWin)
float tbRecentLo = ta.lowest(low, tbWin)
int   tbHiOff    = ta.highestbars(high, tbWin)
int   tbLoOff    = ta.lowestbars(low, tbWin)
float tbSwingHi  = ta.highest(high, tbSwingLen)
float tbSwingLo  = ta.lowest(low, tbSwingLen)
float tbAtr      = ta.atr(14)
bool  tbLocSell  = ta.highest(fibKeyRejSell or liqSweepBear or vwapTestDn ? 1 : 0, tbWin) > 0
bool  tbLocBuy   = ta.highest(fibKeyRejBuy or liqSweepBull or vwapTestUp ? 1 : 0, tbWin) > 0
bool  tbExhTop   = tbExhaust and ta.highest(fwSignal, tbWin) >= fwOB2 and (fibMajorSell or liqSweepBear) and mfOut
bool  tbExhBot   = tbExhaust and ta.lowest(fwSignal, tbWin) <= fwOS2 and (fibMajorBuy or liqSweepBull) and mfIn

// Invalidate - price ran through the armed extreme, or the window expired
if not na(tbTopArm) and (high > tbTopLvl + tbAtr * 0.10 or bar_index - tbTopArm > tbConfirmBars)
    tbTopArm := na
if not na(tbBotArm) and (low < tbBotLvl - tbAtr * 0.10 or bar_index - tbBotArm > tbConfirmBars)
    tbBotArm := na

// Release the one-per-swing lock once price has travelled far enough away from the called extreme
if not na(tbTopLock) and tbTopLock - low >= tbAtr * tbLockAtr
    tbTopLock := na
if not na(tbBotLock) and high - tbBotLock >= tbAtr * tbLockAtr
    tbBotLock := na

bool tbDivTop = tbDivArms and (bearDiv or bearDivSwing or bearDivLeg)
bool tbDivBot = tbDivArms and (bullDiv or bullDivSwing or bullDivLeg)
bool tbArmTop = tbEnable and (diamondStrongSell or tbExhTop or tbDivTop) and tbRecentHi >= tbSwingHi and (na(tbTopLock) or tbRecentHi > tbTopLock)
bool tbArmBot = tbEnable and (diamondStrongBuy or tbExhBot or tbDivBot) and tbRecentLo <= tbSwingLo and (na(tbBotLock) or tbRecentLo < tbBotLock)
if tbArmTop
    bool gradeA = diamondEliteSell or bearLegMajor or (diamondStrongSell and tbLocSell)
    tbTopA   := na(tbTopArm) ? gradeA : (tbTopA or gradeA)
    tbTopLvl := tbRecentHi
    tbTopBar := bar_index + tbHiOff
    tbTopArm := bar_index
if tbArmBot
    bool gradeA = diamondEliteBuy or bullLegMajor or (diamondStrongBuy and tbLocBuy)
    tbBotA   := na(tbBotArm) ? gradeA : (tbBotA or gradeA)
    tbBotLvl := tbRecentLo
    tbBotBar := bar_index + tbLoOff
    tbBotArm := bar_index

bool tbTopMom   = fwBear and engBearCnt >= 2 and (fwCrossDn or fwFalling)
bool tbBotMom   = fwBull and engBullCnt >= 2 and (fwCrossUp or fwRising)
bool tbTopBreak = close < ta.lowest(low, tbBreakBars)[1]
bool tbBotBreak = close > ta.highest(high, tbBreakBars)[1]
bool tbTopFire  = not na(tbTopArm) and tbTopMom and tbTopBreak
bool tbBotFire  = not na(tbBotArm) and tbBotMom and tbBotBreak
bool tbTopFireA = tbTopFire and tbTopA
bool tbBotFireA = tbBotFire and tbBotA
int   tbTopFireBar = tbTopBar
float tbTopFireLvl = tbTopLvl
int   tbBotFireBar = tbBotBar
float tbBotFireLvl = tbBotLvl
if tbTopFire
    tbTopLock := tbTopLvl
    tbBotLock := na
    tbTopArm  := na
if tbBotFire
    tbBotLock := tbBotLvl
    tbTopLock := na
    tbBotArm  := na
bool tbTopArmed = not na(tbTopArm)
bool tbBotArmed = not na(tbBotArm)

// ============================= PLOTTING =====================================

// Premium chop zone visuals (display only)
int chopStrengthPct = chopEnable and chopModeActive ? int(math.min(100, math.max(0, (chopAdxStrong - adxVal) / chopAdxStrong * 65.0 + (chopAdxBlock ? 28.0 : chopAdxMild ? 12.0 : 0.0) + (chopBbSqueeze ? 14.0 : 0.0)))) : chopEnable ? int(math.max(0, (chopAdxStrong - adxVal) / chopAdxStrong * 25.0)) : 0
string chopLblTxt   = chopModeHard ? "CHOP" : "RANGE"
string chopMeterBar = f_chopBar(chopStrengthPct)
bool chopShow       = visChopBg and chopModeActive
int chopBaseTrans   = chopModeHard ? 94 : chopBbSqueeze ? 95 : 96
bgcolor(chopShow ? color.new(C_CHOP_SLATE, chopBaseTrans) : na, title="Chop zone")
bgcolor(visDivGlow and divEnable and bullDivActive ? color.new(C_BULL, 97) : visDivGlow and divEnable and bearDivActive ? color.new(C_BEAR, 97) : na, title="Div highlight")
bgcolor(fwSignal >= fwOB2 ? color.new(C_BEAR, 94) : fwSignal <= fwOS2 ? color.new(C_BULL, 94) : visConfluence and oscAllBull and fwInOS ? color.new(C_BULL, 96) : visConfluence and oscAllBear and fwInOB ? color.new(C_BEAR, 96) : na, title="Zone tint")

var table chopTag = na
if barstate.islast
    if not na(chopTag)
        table.delete(chopTag)
    bool showFloatTag = visChopLabel and chopModeActive and (not dashEnable or dashPos != "Top Right")
    if showFloatTag
        color tagBg = color.new(colPanel, 82)
        chopTag := table.new(position.top_right, 1, 1, bgcolor=tagBg, border_color=color.new(C_CHOP_GLOW, 88), border_width=1, frame_color=color.new(C_CHOP_GLOW, 93), frame_width=1)
        table.cell(chopTag, 0, 0, chopLblTxt, text_color=f_chopTagTxtClr(chopStrengthPct), text_size=size.tiny, text_halign=text.align_center, bgcolor=tagBg)

// OB/OS reference levels
pZero = hline(0,    "Zero",            color=color.new(C_SUBTLE, 55), linestyle=hline.style_dotted)
pZeroFill = plot(0, color=color.new(C_SUBTLE, 100), linewidth=1, title="Zero MF anchor")
pOB   = hline(fwOB,  "OB",      color=color.new(C_BEAR, 68),   linestyle=hline.style_dashed)
pOB2  = hline(fwOB2, "OB++",    color=color.new(C_BEAR, 82),   linestyle=hline.style_dotted)
pOS   = hline(fwOS,  "OS",      color=color.new(C_BULL, 68),   linestyle=hline.style_dashed)
pOS2  = hline(fwOS2, "OS++",    color=color.new(C_BULL, 82),   linestyle=hline.style_dotted)
fill(pOB, pOB2, color=visBands ? color.new(C_BEAR, 94) : na)
fill(pOS, pOS2, color=visBands ? color.new(C_BULL, 94) : na)

// -- Money Flow: forest/maroon cloud + bright lime/red edge --
pMFUp = plot(mfEnable ? mfPos : na, color=mfEnable and mfShowEdge ? mfBullEdge : color.new(colMfBull, 100), linewidth=2, title="MF Up")
pMFDn = plot(mfEnable ? mfNeg : na, color=mfEnable and mfShowEdge ? mfBearEdge : color.new(colMfBear, 100), linewidth=2, title="MF Dn")
fill(pZeroFill, pMFUp, color=mfEnable ? mfBullFill : na, title="Money Flow Bull Area")
fill(pZeroFill, pMFDn, color=mfEnable ? mfBearFill : na, title="Money Flow Bear Area")

// -- Flux Wave lines - display may be smoothed; engine stays sharp --
float fwPlotPrimary = visSmoothWave ? ta.ema(fwPrimary, visSmoothLen) : fwPrimary
float fwPlotSignal  = visSmoothWave ? ta.ema(fwSignal, visSmoothLen) : fwSignal
pFwPrimary = plot(fwPlotPrimary, "Flux Wave Primary", color=C_ACCENT, linewidth=2)
pFwSignal  = plot(fwPlotSignal, "Flux Wave Signal", color=C_FW_SIGNAL, linewidth=2)
fill(pFwPrimary, pFwSignal, color=visAreaFill ? (fwPlotPrimary >= fwPlotSignal ? color.new(C_BULL, 92) : color.new(C_BEAR, 92)) : na)

// Flux Fair Value - white mid-line (your custom look)
float fvPlot = showFairValue ? ta.ema(fluxFairValue, effFvPlotSmooth) : na
plot(fvPlot, "Flux Fair Value", color=color.new(C_FAIR_VALUE, 0), linewidth=2)

// -- Divergence Diamonds - one solid neon diamond per confirmed regular divergence (no halo / shadow layer) --
color diaNeonBuy    = diamondEliteBuy  ? C_ELITE_BUY  : C_DIA_BUY
color diaNeonSell   = diamondEliteSell ? C_ELITE_SELL : C_DIA_SELL
if diamondStrongBuy and not na(fluxDiaBarB)
    label.new(fluxDiaBarB, fluxDiaValB, "◆", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=diaNeonBuy, size=size.large)
if diamondStrongSell and not na(fluxDiaBarS)
    label.new(fluxDiaBarS, fluxDiaValS, "◆", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=diaNeonSell, size=size.large)
if diamondStrongBuy and diaDrawLines and not na(fluxDiaLegB)
    line.new(fluxDiaLegB, fluxDiaLegValB, fluxDiaBarB, fluxDiaValB, color=color.new(diaNeonBuy, 25), width=diamondEliteBuy ? 3 : 2, style=line.style_solid)
if diamondStrongSell and diaDrawLines and not na(fluxDiaLegS)
    line.new(fluxDiaLegS, fluxDiaLegValS, fluxDiaBarS, fluxDiaValS, color=color.new(diaNeonSell, 25), width=diamondEliteSell ? 3 : 2, style=line.style_solid)

// -- TOP / BOTTOM - stamped on the swing candle (price chart) + pane marker --
if tbOnPrice and tbTopFire
    label.new(tbTopFireBar, tbTopFireLvl, "TOP", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down, color=tbTopFireA ? C_BEAR : color.new(C_BEAR, 35), textcolor=color.white, size=tbTopFireA ? size.normal : size.small, force_overlay=true)
if tbOnPrice and tbBotFire
    label.new(tbBotFireBar, tbBotFireLvl, "BOTTOM", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=tbBotFireA ? C_BULL : color.new(C_BULL, 35), textcolor=color.black, size=tbBotFireA ? size.normal : size.small, force_overlay=true)
plotshape(tbOnPane and tbTopFire, "TOP", shape.triangledown, location.top, color=C_BEAR, size=size.tiny)
plotshape(tbOnPane and tbBotFire, "BOTTOM", shape.triangleup, location.bottom, color=C_BULL, size=size.tiny)

// ============================= FLUX READ STATE ================================
// Shared dashboard + JSON export (display-only; no signal logic changes)
string fluxBiasTx = fwPrimary >= fwSignal ? "Bullish" : "Bearish"
color  fluxBiasClr = fwPrimary >= fwSignal ? C_BULL : C_BEAR
string fluxZoneTx = fwInOB ? "Overbought" : fwInOS ? "Oversold" : "Neutral"
color  fluxZoneClr = fwInOB ? C_BEAR : fwInOS ? C_BULL : C_NEUTRAL
string fluxMfTx = not mfEnable or na(mf) ? "-" : mf >= 0 ? "Inflow" : "Outflow"
color  fluxMfClr = not mfEnable or na(mf) ? C_SUBTLE : mf >= 0 ? C_BULL : C_BEAR
string fluxDvTx = hiddenBullDiv or hiddenSwingBull ? "H.Bull" : hiddenBearDiv or hiddenSwingBear ? "H.Bear" : bullDivSwing or bullDivSwingRecent ? "Bull-Swing" : bearDivSwing or bearDivSwingRecent ? "Bear-Swing" : bullDivDual ? "Bull-Elite" : bearDivDual ? "Bear-Elite" : bullDiv or bullDivFast ? "Bullish" : bearDiv or bearDivFast ? "Bearish" : bullDivRecent ? "Bull-Recent" : bearDivRecent ? "Bear-Recent" : "None"
color  fluxDvClr = bullDivClear or hiddenBullDiv or bullDivRecent or bullDivSwingRecent ? C_DIA_BUY : bearDivClear or hiddenBearDiv or bearDivRecent or bearDivSwingRecent ? C_DIA_SELL : C_NEUTRAL
string fluxEngTx = oscAllBull ? "3/3 ^" : oscAllBear ? "3/3 v" : engBull >= 2 ? str.tostring(engBull) + "/3 ^" : str.tostring(3 - engBull) + "/3 v"
color  fluxEngClr = oscAllBull ? C_BULL : oscAllBear ? C_BEAR : C_NEUTRAL
string fluxConvTx = diamondStrongBuy ? (diamondEliteBuy ? "DIV_ELITE_BTM" : "DIV_BTM") + " " + str.tostring(diaScoreBuy) : diamondStrongSell ? (diamondEliteSell ? "DIV_ELITE_TOP" : "DIV_TOP") + " " + str.tostring(diaScoreSell) : fireStrongBuy or fireStrongSell ? "PERMISSION" : revDiamondBuy or revDiamondSell ? "Div " + str.tostring(math.max(diaScoreBuy, diaScoreSell)) : fluxSyncBuy or fluxSyncSell ? "SYNCED" : chopModeHard ? "SKIP" : bullDivSwingRecent or bearDivSwingRecent ? "WATCH" : oscScore >= 55 ? "SOLID" : "IDLE"
color  fluxConvClr = diamondEliteBuy ? C_ELITE_BUY : diamondEliteSell ? C_ELITE_SELL : diamondStrongBuy ? C_DIA_BUY : diamondStrongSell ? C_DIA_SELL : fireStrongBuy or fireStrongSell ? C_GOLD : revDiamondBuy or revDiamondSell ? C_ACCENT : fluxSyncBuy or fluxSyncSell ? C_BULL : (bullDivDual or bearDivDual) ? C_ACCENT : oscScore >= 55 ? C_ACCENT : C_SUBTLE
string fluxRegime = chopModeHard ? "CHOP" : chopAdxTrend ? "TREND" : chopModeActive ? "RANGE" : "TRANSITION"
string fluxWaveState = fwCrossUp ? "bull_cross" : fwCrossDn ? "bear_cross" : fwBull ? "bull" : fwBear ? "bear" : "neutral"
string fluxDiamondTx = diamondStrongBuy ? (diamondEliteBuy ? "div_bull_elite" : "div_bull") : diamondStrongSell ? (diamondEliteSell ? "div_bear_elite" : "div_bear") : revDiamondBuy ? "div_bull_watch" : revDiamondSell ? "div_bear_watch" : "none"
string fluxTopBottom = tbTopFire ? (tbTopFireA ? "top_a" : "top") : tbBotFire ? (tbBotFireA ? "bottom_a" : "bottom") : tbTopArmed ? "top_armed" : tbBotArmed ? "bottom_armed" : "none"
string fluxSetupState = tbTopFire or tbBotFire or diamondStrongBuy or diamondStrongSell ? "TRIGGER" : fireStrongBuy or fireStrongSell ? "TAKE" : revDiamondBuy or revDiamondSell ? "WATCH" : fluxSyncBuy or fluxSyncSell ? "SYNCED" : bullDivSwingRecent or bearDivSwingRecent ? "WATCH" : chopModeHard ? "SKIP" : "IDLE"
string fluxEngExport = oscAllBull ? "3/3" : oscAllBear ? "0/3" : str.tostring(engBull) + "/3"
string fluxMfExport = not mfEnable or na(mf) ? "none" : mf >= 0 ? "Inflow" : "Outflow"
string fluxDvExport = fluxDvTx == "None" ? "none" : fluxDvTx
string fluxReadJson = "{\"v\":1,\"layer\":\"oscillator\",\"sym\":" + f_jsonStr(syminfo.ticker) + ",\"tf\":" + f_jsonStr(timeframe.period) + ",\"ts\":" + str.tostring(time) + ",\"regime\":" + f_jsonStr(fluxRegime) + ",\"setup_state\":" + f_jsonStr(fluxSetupState) + ",\"oracle_score\":" + str.tostring(oscScore) + ",\"conviction_label\":" + f_jsonStr(fluxConvTx) + ",\"money_flow\":" + f_jsonStr(fluxMfExport) + ",\"engines\":" + f_jsonStr(fluxEngExport) + ",\"oscillator_zone\":" + f_jsonStr(fluxZoneTx) + ",\"flux_wave\":" + str.tostring(fwSignal, "#.##") + ",\"wave_state\":" + f_jsonStr(fluxWaveState) + ",\"diamond\":" + f_jsonStr(fluxDiamondTx) + ",\"top_bottom\":" + f_jsonStr(fluxTopBottom) + ",\"divergence\":" + f_jsonStr(fluxDvExport) + ",\"direction_bias\":" + f_jsonStr(fluxBiasTx) + ",\"chop_strength\":" + str.tostring(chopStrengthPct) + ",\"strong_buy\":" + f_jsonBool(fireStrongBuy) + ",\"strong_sell\":" + f_jsonBool(fireStrongSell) + ",\"fair_value\":" + str.tostring(fluxFairValue, "#.##") + ",\"fv_agree_buy\":" + f_jsonBool(fvAgreeBuy) + ",\"fv_agree_sell\":" + f_jsonBool(fvAgreeSell) + ",\"fluid_tf\":" + f_jsonBool(useFluidProf) + ",\"regime_gate\":" + f_jsonBool(regimeGateStrong) + "}"

// =============================== DASHBOARD ==================================
var table dash = na
if dashEnable and barstate.islast
    table.delete(dash)
    dash := table.new(f_dashPos(dashPos), 2, 7, bgcolor=C_PANEL, border_color=color.new(colSubtle, 70), border_width=1, frame_color=color.new(C_GOLD, 65), frame_width=1)

    string dir  = fluxBiasTx
    color  dirC = fluxBiasClr
    string zone = fluxZoneTx
    color  zoneC= fluxZoneClr
    string mfTx = fluxMfTx
    color  mfC  = fluxMfClr
    string dvTx = fluxDvTx
    color  dvC  = fluxDvClr
    string engTx = fluxEngTx
    color  engC  = fluxEngClr
    string convTx = diamondStrongBuy ? (diamondEliteBuy ? "DIV ELITE " : "DIV BTM ") + str.tostring(diaScoreBuy) : diamondStrongSell ? (diamondEliteSell ? "DIV ELITE " : "DIV TOP ") + str.tostring(diaScoreSell) : fireStrongBuy or fireStrongSell ? "PERMISSION" : revDiamondBuy or revDiamondSell ? "Div-" + str.tostring(math.max(diaScoreBuy, diaScoreSell)) : fluxSyncBuy or fluxSyncSell ? "SYNCED" : chopModeHard ? "SKIP" : bullDivSwingRecent or bearDivSwingRecent ? "WATCH" : oscScore >= 55 ? "SOLID" : "-"
    color  convC  = fluxConvClr

    string hdrRight = scalpActive ? "SCALP MODE ACTIVE" : chopModeActive and visChopLabel ? chopLblTxt + " - " + dir : dir
    // Bias color stays green/red - never purple (chop glow is for CHOP meter only)
    color  hdrClr   = scalpActive ? C_DIA_BUY : dirC
    color  momClr   = oscScore >= 70 ? C_DIA_BUY : oscScore >= 45 ? C_GOLD : C_SUBTLE
    table.cell(dash, 0, 0, "FLUX DIV - WHEN", text_color=C_GOLD, text_size=size.small, bgcolor=color.new(colPanel, 0))
    table.cell(dash, 1, 0, hdrRight,          text_color=hdrClr,     text_size=size.small, bgcolor=color.new(colPanel, 0))
    table.cell(dash, 0, 1, "Engines",    text_color=C_SUBTLE, text_size=size.small)
    table.cell(dash, 1, 1, engTx,        text_color=engC,     text_size=size.small)
    table.cell(dash, 0, 2, "Zone",       text_color=C_SUBTLE, text_size=size.small)
    table.cell(dash, 1, 2, zone,         text_color=zoneC,    text_size=size.small)
    table.cell(dash, 0, 3, "Momentum",   text_color=C_SUBTLE, text_size=size.small)
    table.cell(dash, 1, 3, str.tostring(oscScore) + "/100", text_color=momClr, text_size=size.small)
    table.cell(dash, 0, 4, "Money Flow", text_color=C_SUBTLE, text_size=size.small)
    table.cell(dash, 1, 4, mfTx,         text_color=mfC,      text_size=size.small)
    table.cell(dash, 0, 5, "Divergence", text_color=C_SUBTLE, text_size=size.small)
    table.cell(dash, 1, 5, dvTx,         text_color=dvC,      text_size=size.small)
    string chopMeterTx = chopEnable and visChopMeter ? (chopModeActive ? str.tostring(chopStrengthPct) + "%  " + chopMeterBar : "Clear - " + str.tostring(chopStrengthPct) + "%") : "-"
    color  chopMeterClr = f_chopMeterClr(chopStrengthPct)
    color  chopRowBg    = chopModeActive and visChopMeter ? color.new(chopStrengthPct >= 65 ? C_BEAR : C_CHOP_PURPLE, chopStrengthPct >= 65 ? 93 : 95) : color.new(C_PANEL, 0)
    table.cell(dash, 0, 6, "Chop Strength", text_color=C_SUBTLE, text_size=size.small, bgcolor=chopRowBg)
    table.cell(dash, 1, 6, chopMeterTx,     text_color=chopMeterClr, text_size=size.small, bgcolor=chopRowBg)

// ================================ ALERTS ====================================
if fluxReadEnable and barstate.isconfirmed
    alert(fluxReadJson, alert.freq_once_per_bar_close)

alertcondition(fluxSyncBuy,     title="Flux Sync Buy",  message="Oracle Flux OSC: Chart+Oscillator SYNC BUY on {{ticker}} ({{interval}})")
alertcondition(fluxSyncSell,    title="Flux Sync Sell", message="Oracle Flux OSC: Chart+Oscillator SYNC SELL on {{ticker}} ({{interval}})")
alertcondition(tbTopFire,  title="Flux TOP",       message="Oracle Flux OSC: TOP confirmed on {{ticker}} ({{interval}})")
alertcondition(tbBotFire,  title="Flux BOTTOM",    message="Oracle Flux OSC: BOTTOM confirmed on {{ticker}} ({{interval}})")
alertcondition(tbTopFireA, title="Flux TOP A",     message="Oracle Flux OSC: A-grade TOP on {{ticker}} ({{interval}})")
alertcondition(tbBotFireA, title="Flux BOTTOM A",  message="Oracle Flux OSC: A-grade BOTTOM on {{ticker}} ({{interval}})")
alertcondition(diamondStrongBuy,  title="Bull Divergence Diamond",  message="Oracle Flux OSC: Bullish divergence diamond on {{ticker}} ({{interval}})")
alertcondition(diamondStrongSell, title="Bear Divergence Diamond", message="Oracle Flux OSC: Bearish divergence diamond on {{ticker}} ({{interval}})")
alertcondition(diamondEliteBuy,  title="Elite Bull Divergence <>",  message="Oracle Flux OSC: Elite bullish divergence diamond on {{ticker}} ({{interval}})")
alertcondition(diamondEliteSell, title="Elite Bear Divergence <>", message="Oracle Flux OSC: Elite bearish divergence diamond on {{ticker}} ({{interval}})")
alertcondition(bullDiv,   title="Bullish Divergence",   message="Oracle Flux OSC: Bullish divergence on {{ticker}} ({{interval}})")
alertcondition(bearDiv,   title="Bearish Divergence",   message="Oracle Flux OSC: Bearish divergence on {{ticker}} ({{interval}})")
alertcondition(hiddenBullDiv, title="Hidden Bull Divergence", message="Oracle Flux OSC: Hidden bullish divergence on {{ticker}} ({{interval}})")
alertcondition(hiddenBearDiv, title="Hidden Bear Divergence", message="Oracle Flux OSC: Hidden bearish divergence on {{ticker}} ({{interval}})")
alertcondition(bullDivDual, title="Dual-Line Bull Divergence", message="Oracle Flux OSC: Dual-line bullish divergence on {{ticker}} ({{interval}})")
alertcondition(bearDivDual, title="Dual-Line Bear Divergence", message="Oracle Flux OSC: Dual-line bearish divergence on {{ticker}} ({{interval}})")
alertcondition(fwCrossUp, title="Flux Wave Cross Up",   message="Oracle Flux OSC: Flux Wave bullish cross on {{ticker}} ({{interval}})")
alertcondition(fwCrossDn, title="Flux Wave Cross Down", message="Oracle Flux OSC: Flux Wave bearish cross on {{ticker}} ({{interval}})")
alertcondition(oscAllBull, title="Engines Bull", message="Oracle Flux OSC: All 3 engines bullish on {{ticker}} ({{interval}})")
alertcondition(oscAllBear, title="Engines Bear", message="Oracle Flux OSC: All 3 engines bearish on {{ticker}} ({{interval}})")
````
