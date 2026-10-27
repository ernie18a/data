# BLUF_Regime_Signal

- url: https://www.tradingview.com/script/96Y3Gj6P-BLUF-Regime-Signal/
- type: indicator
- pine_id: PUB;7ee11c7e6c32438f997ec951aa39136e
- version: 7.0

## Description

This is an extension of bluf_regime_overlay that includes built in alerts. designed by isaacbdavis for active traders. See blufterminal.com for free options levels daily.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
// © BLUF Terminal
//
// BLUF Regime Signal v3 — BigBeluga-Style Regime Flip + Volume-Free Confluence
// ----------------------------------------------------------------------------
// v3.2 (2026-05-13 PM3) — Defaults tuned from live GLD 5m calibration before
//   TradingView republish: flipAtrMult4 4.0 → 5.0 (kills single-push whipsaws
//   while keeping reversal capture); htfMode "Off" → "Aligned" (keeps signals
//   trending with daily HMA). Old Signal Lab data favored Reversal mode but
//   that was the v2 volume-gated regime — re-evaluate on v3 captures.
//
// v3.1 (2026-05-13 PM2) — Flip math rewritten from pivot+ATR to close-based
//   supertrend after first chart looked like a forest. Pivot formula whipsawed
//   when 8×ATR exceeded the 10-bar range (bands crossed). Supertrend keeps
//   bands always on the correct side of close by construction. Also:
//   showShifts default flipped to false — underlying TREND detection still
//   runs for Algo Lab capture, but the chart labels are off (Bull/Bear flips
//   are the visual signal now). Pine v6 + linewidth-const fixes shipped here.
//
// v3.0 (2026-05-13) — Signal-accuracy pivot. Volume gating REMOVED.
//   Inspired by BigBeluga's "Liquidity-Anchored Trailing Stop" — his clean
//   Bull/Bear flips beat our volume-confirmed tiered chips on GLD 5m
//   side-by-side. Isaac's call: "no more volume rules. our ultimate goal
//   is good signals." Rule saved to memory (feedback_bluf_signal_no_volume_gating.md).
//
// What's new vs v2.1:
//   • NEW Bull/Bear Flip layer — BigBeluga-style persistent regime state.
//     Four ratcheting ATR trailing stops (ts1-ts4) from pivot-extreme +/-
//     ATR×mult. flipState (BULL/BEAR) only changes when close breaches ts4
//     in the opposing direction. Flips are RARE by design — the visual
//     cleanness comes from state persistence, not stricter confluence.
//   • Bull/Bear label on flip bar, stamped with confluence quality:
//       Bull ★ 5/5  (PRIME flip)  |  Bull ● 4/5  (STRONG flip)
//   • Volume GATING removed from shifts, flips, PRIME tier, alerts.
//   • Confluence score → 5 components (was 6). Volume component dropped.
//   • PRIME boost qualifier → MACD accel only (volRatio≥2.5 OR macdAccel
//     reduces to: macdAccel). 5/5 + macdAccel = PRIME; 5/5 alone = STRONG.
//   • Volume profile heatmap + HVN badges KEPT — they are structure/viz,
//     not gates. BigBeluga's whole framework rests on HVNs.
//   • Path C optimizer capture fires on every shift candidate regardless
//     of volume; MC-side post-hoc filtering is where volume can re-enter.
//
// What v2 features carry through:
//   • Auto-detect Trader Profile from chart timeframe
//   • HMA cloud as primary trend visual
//   • Inline level badges with icons (ANCHOR ⚓, FLIP ⚡, MAX PAIN ★, walls ▲▼)
//   • HTF Mode (Off / Aligned / Reversal)
//   • Same-direction lockout, cooldown bars
//   • PRIME Hit Rate Tracker (now 5-component grading)
//
// Confluence checks (each scores 1, 0-5 total):
//   1. Efficiency Ratio ≥ trendPct (regime is/just became TREND)
//   2. HMA cloud direction aligned with shift direction
//   3. RSI thrust beyond bull/bear threshold (default 55/45)
//   4. MACD histogram positive AND accelerating (mirrored for bears)
//   5. Close on the correct side of session VWAP
//
// Tiers:  PRIME = 5/5 + macdAccel ★  |  STRONG = 4/5 or 5/5 no boost ●  |  WEAK = 3/5 ○
//
// Flip tier (Bull/Bear label):  same scoring, applied to the flip-direction
//   confluence at the bar of the flip. A flip with 5/5 + accel = ★, etc.
//
// NOTE: TradingView will reset old inputs to defaults on first reload after
// upgrade — check Volume Multiplier (now unused), HTF Mode, and the new
// Bull/Bear Flip group.

//@version=6
indicator("BLUF Regime Signal v3", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500, max_bars_back=500)

// ============================================================================
// TRADER PROFILE — AUTO-DETECT FROM CHART TIMEFRAME
// ============================================================================

profileMode    = input.string("Auto (from TF)", "Trader Profile", options=["Auto (from TF)", "Day", "Swing/Weekly"], group="Trader Profile", tooltip="Auto picks based on chart timeframe: ≤30m → Day, ≥1h → Swing/Weekly. Day uses faster HMAs and looser ER thresholds.")

tfSec        = timeframe.in_seconds(timeframe.period)
isDayProfile = profileMode == "Day" or (profileMode == "Auto (from TF)" and tfSec <= 1800)
profileText  = isDayProfile ? "DAY" : "SWING"

// ============================================================================
// INPUTS
// ============================================================================

// Mode
autoMode       = input.bool(true, "Auto-Calculate Levels", tooltip="When ON, levels are calculated from price/volume. When OFF, use manual inputs below.", group="Mode")

// Manual Key Levels
manAnchor      = input.float(0.0, "Manual Anchor",   group="Manual Levels", tooltip="Set to 0 to disable")
manFlip        = input.float(0.0, "Manual Flip",     group="Manual Levels", tooltip="Set to 0 to disable")
manMaxPain     = input.float(0.0, "Manual Max Pain", group="Manual Levels", tooltip="Set to 0 to disable")
manCallWall    = input.float(0.0, "Manual Call Wall",group="Manual Levels", tooltip="Set to 0 to disable")
manPutWall     = input.float(0.0, "Manual Put Wall", group="Manual Levels", tooltip="Set to 0 to disable")

// ATR
atrLength      = input.int(14, "ATR Period", minval=1, group="ATR Settings")
emBandMult     = input.float(1.0, "Expected Move Multiplier", minval=0.1, step=0.1, group="ATR Settings")

// VWAP
showVwap       = input.bool(true, "Show VWAP", group="VWAP")
vwapSource     = input.source(hlc3, "VWAP Source", group="VWAP")

// Volume Profile (now rendered as inline heatmap)
showVP         = input.bool(true, "Show Volume Heatmap", group="Volume Profile")
vpLength       = input.int(80, "Lookback (bars)", minval=10, maxval=300, group="Volume Profile")
vpRows         = input.int(28, "Rows", minval=8, maxval=60, group="Volume Profile")
vpWidth        = input.int(40, "Heatmap Depth (bars)", minval=10, maxval=120, group="Volume Profile", tooltip="How far the heatmap shelves extend left into the chart")
vpOpacity      = input.int(70, "Heatmap Opacity", minval=20, maxval=95, group="Volume Profile", tooltip="Higher = more transparent. 70 keeps candles readable.")
showVPLabels   = input.bool(true, "Show Level Badges", group="Volume Profile", tooltip="Inline pill labels at the right edge for each key level")

// HMA Cloud
showCloud      = input.bool(true, "Show HMA Cloud", group="HMA Cloud")
hmaFastInput   = input.int(0, "HMA Fast (0=auto)", minval=0, group="HMA Cloud", tooltip="0 uses profile default (Day=9, Swing=21)")
hmaSlowInput   = input.int(0, "HMA Slow (0=auto)", minval=0, group="HMA Cloud", tooltip="0 uses profile default (Day=21, Swing=55)")
cloudOpacity   = input.int(60, "Cloud Opacity (TREND)", minval=0, maxval=95, group="HMA Cloud", tooltip="Lower = more solid. CAUTION fades by +20, RANGE fades by +32 on top of this.")

hmaFastLen = hmaFastInput > 0 ? hmaFastInput : (isDayProfile ? 9  : 21)
hmaSlowLen = hmaSlowInput > 0 ? hmaSlowInput : (isDayProfile ? 21 : 55)

// Regime Detection — ER thresholds
useProfileER   = input.bool(true, "Use Profile ER Defaults", group="Regime Detection", tooltip="ON: thresholds match profile (Day looser, Swing tighter). OFF: use overrides below.")
rangePctIn     = input.float(0.30, "Range Enter (override)", minval=0.05, maxval=1.0, step=0.05, group="Regime Detection")
rangeExitIn    = input.float(0.40, "Range Exit (override)",  minval=0.05, maxval=1.0, step=0.05, group="Regime Detection")
trendPctIn     = input.float(0.60, "Trend Enter (override)", minval=0.10, maxval=1.0, step=0.05, group="Regime Detection")
trendExitIn    = input.float(0.50, "Trend Exit (override)",  minval=0.05, maxval=1.0, step=0.05, group="Regime Detection")
erLookback     = input.int(14, "ER Lookback", minval=2, group="Regime Detection")

rangePct  = useProfileER ? (isDayProfile ? 0.25 : 0.30) : rangePctIn
rangeExit = useProfileER ? (isDayProfile ? 0.35 : 0.40) : rangeExitIn
trendPct  = useProfileER ? (isDayProfile ? 0.55 : 0.60) : trendPctIn
trendExit = useProfileER ? (isDayProfile ? 0.45 : 0.50) : trendExitIn

// Regime Shift signals (volume gate REMOVED in v3 — see header)
// Default OFF in v3.1: without volume gating, chips fire on most TREND bars
// and visually clash with the Bull/Bear flip layer. Underlying shift detection
// + optimizer capture still run — only the on-chart labels are hidden.
// Turn ON if you want diagnostic chip view alongside the flips.
showShifts     = input.bool(false, "Show Regime Shift Signals", group="Regime Shift Signals", tooltip="Default OFF in v3.1. Underlying TREND/RANGE detection still fires for Algo Lab + Signal Lab capture — this toggle only controls the on-chart labels. Re-enable for diagnostic overlay; consider also raising 'Minimum Tier to Show' to PRIME so only top-tier chips draw.")
volLength      = input.int(20, "Volume MA Length (heatmap/diag only)", minval=1, group="Regime Shift Signals", tooltip="Used by volume heatmap and logged in optimizer capture payload. NOT a gate — v3 removed all volume gates.")
volMultIn      = input.float(1.5, "Volume Multiplier (DEPRECATED in v3)", minval=1.0, step=0.1, group="Regime Shift Signals", tooltip="No longer gates shift firing. Retained as input to preserve saved chart layouts and to log in capture payload for post-hoc Signal Lab analysis.")
cooldownIn     = input.int(8, "Signal Cooldown (override)", minval=0, group="Regime Shift Signals")

volMult      = useProfileER ? (isDayProfile ? 1.8 : 2.0) : volMultIn
cooldownBars = useProfileER ? (isDayProfile ? 5  : 12 ) : cooldownIn

// Same-direction lockout — prevents back-to-back same-side TREND signals during chop
sameDirLockoutIn = input.int(0, "Same-Direction Lockout (override, 0=auto)", minval=0, group="Regime Shift Signals", tooltip="Min bars between consecutive same-direction TREND signals. 0 = profile default (Day=25, Swing=20).")
sameDirLockout   = sameDirLockoutIn > 0 ? sameDirLockoutIn : (isDayProfile ? 25 : 20)

// HTF Filter
htfTimeframe   = input.timeframe("D", "HTF Timeframe", group="HTF Filter", tooltip="Higher-timeframe trend reference. 'D' = daily, '240' = 4h, 'W' = weekly. Compared to current close to determine HTF bull/bear.")
htfHmaLen      = input.int(21, "HTF HMA Length", minval=2, group="HTF Filter")
htfMode        = input.string("Aligned", "HTF Mode", options=["Off", "Aligned", "Reversal"], group="HTF Filter", tooltip="Off: no HTF gate. Aligned (default v3.2): TREND↑ requires HTF=BULL, TREND↓ requires HTF=BEAR — keeps flips/shifts trending with the daily HMA. Reversal: shift direction must OPPOSE HTF — mean-reversion edge surfaced in v2 Signal Lab data (n=11 hit 100%/+2.63R at h2 vs aligned n=18 at 44%/-0.07R); that data was from the volume-gated v2 regime and may not carry to v3 supertrend flips — re-evaluate against fresh captures.")

// Confluence / Tier
showOnlyPrime  = input.bool(false, "Show ONLY Prime Signals", group="Confluence", tooltip="ON: hide STRONG and WEAK tiers — only PRIME (5/5 + MACD accel) labels appear")
minTierToShow  = input.string("WEAK", "Minimum Tier to Show", options=["PRIME", "STRONG", "WEAK"], group="Confluence")
rsiLength      = input.int(14, "RSI Length", minval=2, group="Confluence")
rsiBullThrust  = input.float(55, "RSI Bull Thrust", minval=50, maxval=70, step=1, group="Confluence")
rsiBearThrust  = input.float(45, "RSI Bear Thrust", minval=30, maxval=50, step=1, group="Confluence")
macdFast       = input.int(12, "MACD Fast", minval=2, group="Confluence")
macdSlow       = input.int(26, "MACD Slow", minval=2, group="Confluence")
macdSig        = input.int( 9, "MACD Signal", minval=2, group="Confluence")

// Bull/Bear Flip Layer — BigBeluga-style supertrend (v3 NEW, rewritten v3.1)
// Math: close-based supertrend. bullStop = close − ATR×mult, ratchets UP.
// bearStop = close + ATR×mult, ratchets DOWN. Flip when close breaches ts4.
// The first attempt used pivotLo/Hi-based formulas which whipsawed because
// the bands crossed on low-volatility bars (8×ATR > 10-bar range). Supertrend
// guarantees the bands are always on the correct side of close.
showFlip          = input.bool(true,  "Show Bull/Bear Flip Layer",         group="Bull/Bear Flip", tooltip="BigBeluga-style persistent regime state. Flips on close vs outermost ratcheting ATR band. Independent of TREND chips — slower and cleaner.")
flipPivotLookback = input.int(10,     "Flip Pivot Lookback (DEPRECATED)",  minval=2,  maxval=200, group="Bull/Bear Flip", tooltip="No longer used after v3.1 supertrend rewrite. Retained as input to preserve saved chart layouts.")
flipAtrMult1      = input.float(1.0,  "Flip Stop 1 ATR Mult (tightest)",   minval=0.1, step=0.1, group="Bull/Bear Flip")
flipAtrMult2      = input.float(2.0,  "Flip Stop 2 ATR Mult",              minval=0.1, step=0.1, group="Bull/Bear Flip")
flipAtrMult3      = input.float(3.0,  "Flip Stop 3 ATR Mult",              minval=0.1, step=0.1, group="Bull/Bear Flip")
flipAtrMult4      = input.float(5.0,  "Flip Stop 4 ATR Mult (flip trigger)", minval=0.1, step=0.1, group="Bull/Bear Flip", tooltip="Close beyond this band in the opposite direction triggers a state flip. Higher = fewer/slower flips. Default 5.0 (v3.2) — calibrated against live GLD 5m to balance flip frequency vs reversal capture. Try 6 for even sparser flips, 4 for tighter.")
flipShowAllStops  = input.bool(false, "Show All 4 Stops (heatmap look)",   group="Bull/Bear Flip", tooltip="OFF: only the active outermost stop (ts4) is plotted as a stair-step line. ON: all four bands fade between price and ts4 for the full BigBeluga heatmap visual.")
flipHvnConfluence = input.bool(true,  "Highlight HVN-Anchored Stops",      group="Bull/Bear Flip", tooltip="When the active stop sits within 0.2×ATR of a high-volume node from the volume profile, thicken the line and color it gold (the 'Hard Anchor' state).")
flipShowLabels    = input.bool(true,  "Show Bull/Bear Flip Labels",        group="Bull/Bear Flip")

// Trade Plan freshness filters
showTradePlan          = input.bool(true,  "Show Trade Plan Row",                group="Trade Plan")
tradePlanStaleBarsIn   = input.int(0,      "Stale After N Bars (override, 0=auto)", minval=0, group="Trade Plan", tooltip="Trade plan goes 'stale' when last shift is older than this many bars. 0 = profile default (Day=30, Swing=60). Forces a fresh trigger before the plan row paints again.")
tradePlanFlipThreshold = input.int(20,     "Confluence Flip Threshold",          minval=10, maxval=50, group="Trade Plan", tooltip="If opposing-direction confluence score beats current bias by this many points, plan flips to '— regime flipped' regardless of staleness. Catches mid-move regime reversals.")
tradePlanStaleBars     = tradePlanStaleBarsIn > 0 ? tradePlanStaleBarsIn : (isDayProfile ? 30 : 60)

// Hit Rate Tracker — Path A (in-Pine, single-chart)
showHitRate    = input.bool(true, "Show PRIME Hit Rate Row", group="Hit Rate Tracker", tooltip="Tracks every PRIME ★ signal at three horizons (auto-sized to your profile). Hit = price moved in signal direction by horizon. R-multiple uses 1×ATR at fire as the 1R denominator (matches Trade Plan auto-stop). Stats reset on chart reload.")
hxHorizonMode  = input.string("Auto (from profile)", "Grading Horizons", options=["Auto (from profile)", "Day (5 / 10 / 20 bars)", "Swing (50 / 100 / 200 bars)"], group="Hit Rate Tracker", tooltip="Auto matches the trader profile that's already driving HMA lengths and ER thresholds. Day = bar-level grading for intraday/0DTE. Swing = day-level grading for weekly+ horizons.")
maxTrackedSig  = input.int(200,   "Max Tracked Signals",     minval=20, maxval=500, group="Hit Rate Tracker", tooltip="Cap on the in-memory queue of ungraded signals. Older entries drop off after grading at the longest horizon.")

// Optimizer Capture — Path C (MC webhook)
captureAllShifts = input.bool(false, "Capture All Shifts (webhook)", group="Optimizer Capture", tooltip="When ON, fires alert() with full-state JSON on EVERY shift candidate that passes volume + cooldown gates (tier/lockout/HTF/VWAP-side are logged, not enforced). Configure ONE TradingView alert with 'Any alert() function call' as the condition; webhook URL → MC /api/bluf-signal/capture endpoint. Default OFF — only enable for data-collection runs.")

// Derive horizons from profile
useSwingHorizons = hxHorizonMode == "Swing (50 / 100 / 200 bars)" or (hxHorizonMode == "Auto (from profile)" and not isDayProfile)
hxH1 = useSwingHorizons ? 50  : 5
hxH2 = useSwingHorizons ? 100 : 10
hxH3 = useSwingHorizons ? 200 : 20

// Display
showBands      = input.bool(false, "Show Expected Move Bands", group="Display", tooltip="Off by default — HMA cloud carries the volatility envelope visually. Toggle on for explicit ATR-based EM lines.")
showBg         = input.bool(false, "Show Background Tint", group="Display", tooltip="Off by default — HMA cloud carries the regime visual")
showDashboard  = input.bool(true,  "Show Dashboard", group="Display")
dashPosition   = input.string("Top Right", "Dashboard Position", options=["Top Right", "Middle Right", "Top Left", "Bottom Right", "Bottom Left"], group="Display")

// Colors
colBlue        = input.color(#3b82f6, "Blue (VWAP/Anchor)", group="Colors")
colGreen       = input.color(#22c55e, "Green (Bull/Range/Call Wall)", group="Colors")
colRed         = input.color(#ef4444, "Red (Bear/Trend/Put Wall)", group="Colors")
colYellow      = input.color(#eab308, "Yellow (Caution)", group="Colors")
colFlip        = input.color(#a855f7, "Purple (Flip Level)", group="Colors")
colMaxPain     = input.color(#f97316, "Orange (Max Pain)", group="Colors")
colHeatLow     = input.color(#1e3a8a, "Heatmap Low", group="Colors")
colHeatHigh    = input.color(#fde047, "Heatmap High", group="Colors")
colHeatPoc     = input.color(#d946ef, "Heatmap POC", group="Colors")
colPrime       = input.color(#fde047, "Prime Tier (★)", group="Colors")

// ============================================================================
// ATR & EXPECTED MOVE
// ============================================================================
atrValue = ta.atr(atrLength)
emHigh   = close + atrValue * emBandMult
emLow    = close - atrValue * emBandMult

// ============================================================================
// VWAP CALCULATION (Session-based)
// ============================================================================
vwapValue = ta.vwap(vwapSource)

var float cumVol     = 0.0
var float cumVolSrc  = 0.0
var float cumVolSrc2 = 0.0

isNewDay = ta.change(time("D")) != 0
if isNewDay
    cumVol     := volume
    cumVolSrc  := volume * vwapSource
    cumVolSrc2 := volume * vwapSource * vwapSource
else
    cumVol     := cumVol + volume
    cumVolSrc  := cumVolSrc + volume * vwapSource
    cumVolSrc2 := cumVolSrc2 + volume * vwapSource * vwapSource

vwapCalc     = cumVol > 0 ? cumVolSrc / cumVol : close
vwapVariance = cumVol > 0 ? (cumVolSrc2 / cumVol) - (vwapCalc * vwapCalc) : 0.0
vwapStdev    = math.sqrt(math.max(vwapVariance, 0))

vwapUpper1   = vwapCalc + vwapStdev * 1.0
vwapLower1   = vwapCalc - vwapStdev * 1.0
vwapUpper2   = vwapCalc + vwapStdev * 2.0
vwapLower2   = vwapCalc - vwapStdev * 2.0

// ============================================================================
// VOLUME PROFILE — bin calculation (POC + Value Area)
// ============================================================================
vpHigh = ta.highest(high, vpLength)
vpLow  = ta.lowest(low,  vpLength)
vpStep = vpRows > 0 ? (vpHigh - vpLow) / vpRows : 1.0

pocLevel = float(na)
vahLevel = float(na)
valLevel = float(na)

var float[] vpBins = array.new_float(60, 0.0)

if barstate.islast and vpStep > 0
    for i = 0 to vpRows - 1
        array.set(vpBins, i, 0.0)

    for bk = 0 to vpLength - 1
        barH   = high[bk]
        barL   = low[bk]
        barV   = volume[bk]
        barMid = (barH + barL) / 2.0
        binIdx = math.floor((barMid - vpLow) / vpStep)
        binIdx := math.min(math.max(binIdx, 0), vpRows - 1)
        oldVal = array.get(vpBins, int(binIdx))
        array.set(vpBins, int(binIdx), oldVal + barV)

    maxVol  = 0.0
    pocBin  = 0
    totalV  = 0.0
    for i = 0 to vpRows - 1
        bv = array.get(vpBins, i)
        totalV := totalV + bv
        if bv > maxVol
            maxVol := bv
            pocBin := i

    pocLevel := vpLow + (pocBin + 0.5) * vpStep

    vaTarget = totalV * 0.7
    vaAccum  = maxVol
    upIdx    = pocBin + 1
    downIdx  = pocBin - 1
    while vaAccum < vaTarget and (upIdx < vpRows or downIdx >= 0)
        upVol   = upIdx < vpRows ? array.get(vpBins, upIdx) : 0.0
        downVol = downIdx >= 0 ? array.get(vpBins, downIdx) : 0.0
        if upVol >= downVol and upIdx < vpRows
            vaAccum := vaAccum + upVol
            upIdx   := upIdx + 1
        else if downIdx >= 0
            vaAccum := vaAccum + downVol
            downIdx := downIdx - 1
        else
            break
    vahLevel := vpLow + (math.min(upIdx, vpRows - 1) + 1) * vpStep
    valLevel := vpLow + math.max(downIdx + 1, 0) * vpStep

// ============================================================================
// DETERMINE ACTIVE LEVELS
// ============================================================================
prevClose = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)
weekHigh  = request.security(syminfo.tickerid, "W", high[1],  lookahead=barmerge.lookahead_on)
weekLow   = request.security(syminfo.tickerid, "W", low[1],   lookahead=barmerge.lookahead_on)
weekClose = request.security(syminfo.tickerid, "W", close[1], lookahead=barmerge.lookahead_on)
weekPivot = (weekHigh + weekLow + weekClose) / 3.0

autoAnchor   = vwapValue
autoFlip     = nz(pocLevel, prevClose)
autoMaxPain  = weekPivot
autoCallWall = vwapUpper2
autoPutWall  = vwapLower2

anchorLevel  = autoMode ? autoAnchor   : (manAnchor   != 0 ? manAnchor   : autoAnchor)
flipLevel    = autoMode ? autoFlip     : (manFlip     != 0 ? manFlip     : autoFlip)
maxPainLevel = autoMode ? autoMaxPain  : (manMaxPain  != 0 ? manMaxPain  : autoMaxPain)
callWallLvl  = autoMode ? autoCallWall : (manCallWall != 0 ? manCallWall : autoCallWall)
putWallLvl   = autoMode ? autoPutWall  : (manPutWall  != 0 ? manPutWall  : autoPutWall)

// ============================================================================
// HMA CLOUD
// ============================================================================
hmaFast   = ta.hma(close, hmaFastLen)
hmaSlow   = ta.hma(close, hmaSlowLen)
cloudBull = hmaFast > hmaSlow
cloudBear = hmaFast < hmaSlow

// HTF reference HMA (for filter + dashboard)
htfHmaSeries = ta.hma(close, htfHmaLen)
htfHma = request.security(syminfo.tickerid, htfTimeframe, htfHmaSeries, lookahead=barmerge.lookahead_off)
htfBull = not na(htfHma) and close > htfHma
htfBear = not na(htfHma) and close < htfHma
htfText = htfBull ? "BULL ▲" : htfBear ? "BEAR ▼" : "FLAT —"
htfClr  = htfBull ? colGreen : htfBear ? colRed : color.new(color.white, 30)

// ============================================================================
// REGIME DETECTION — Kaufman Efficiency Ratio + hysteresis
// ============================================================================
erDirection     = math.abs(close - close[erLookback])
erVolatility    = math.sum(math.abs(close - close[1]), erLookback)
efficiencyRatio = erVolatility > 0 ? erDirection / erVolatility : 0

var string regimeState = "CAUTION"
if regimeState == "RANGE"
    if efficiencyRatio >= rangeExit
        regimeState := efficiencyRatio > trendPct ? "TREND" : "CAUTION"
else if regimeState == "TREND"
    if efficiencyRatio <= trendExit
        regimeState := efficiencyRatio < rangePct ? "RANGE" : "CAUTION"
else
    if efficiencyRatio < rangePct
        regimeState := "RANGE"
    else if efficiencyRatio > trendPct
        regimeState := "TREND"

isRange   = regimeState == "RANGE"
isTrend   = regimeState == "TREND"
isCaution = regimeState == "CAUTION"

// Track bars in current TREND regime (used by Optimizer Capture payload)
var int trendEntryBar = -1
if isTrend and not isTrend[1]
    trendEntryBar := bar_index
barsInTrend = isTrend and trendEntryBar >= 0 ? bar_index - trendEntryBar : 0

regimeText  = isRange ? "RANGE" : isTrend ? "TREND" : "CAUTION"
regimeColor = isRange ? colGreen : isTrend ? colRed : colYellow

aboveFlip   = close > flipLevel
dealerText  = aboveFlip ? "LONG γ" : "SHORT γ"
dealerColor = aboveFlip ? colGreen : colRed

// ============================================================================
// CONFLUENCE INGREDIENTS (v3: 5 components, volume removed)
// ============================================================================
// volRatio is kept as a diagnostic/log-only metric — NEVER as a gate or
// PRIME qualifier. See feedback_bluf_signal_no_volume_gating.md.
volAvg       = ta.sma(volume, volLength)
volRatio     = volAvg > 0 ? volume / volAvg : 0.0

rsiVal = ta.rsi(close, rsiLength)
[macdLine, macdSignalLine, macdHist] = ta.macd(close, macdFast, macdSlow, macdSig)
// Two-bar slope: requires histogram to have been rising for at least 2 bars (not a single tick)
macdAccelUp = macdHist > 0 and macdHist > macdHist[1] and macdHist[1] > macdHist[2]
macdAccelDn = macdHist < 0 and macdHist < macdHist[1] and macdHist[1] < macdHist[2]

// Five checks per direction (v3 — volume component dropped)
upC1 = efficiencyRatio >= trendPct
upC2 = cloudBull
upC3 = rsiVal >= rsiBullThrust
upC4 = macdAccelUp
upC5 = close > vwapCalc
upCount = (upC1?1:0) + (upC2?1:0) + (upC3?1:0) + (upC4?1:0) + (upC5?1:0)

dnC1 = efficiencyRatio >= trendPct
dnC2 = cloudBear
dnC3 = rsiVal <= rsiBearThrust
dnC4 = macdAccelDn
dnC5 = close < vwapCalc
dnCount = (dnC1?1:0) + (dnC2?1:0) + (dnC3?1:0) + (dnC4?1:0) + (dnC5?1:0)

upScore = math.round(upCount * 100 / 5)
dnScore = math.round(dnCount * 100 / 5)

// PRIME requires 5/5 AND macdAccel (boost qualifier reduced from "volRatio≥2.5
// OR macdAccel" → "macdAccel" with volume gone). A 5/5 setup without accel
// falls to STRONG.
tierFromCount(c, macdAcc) =>
    primeBoost = c >= 5 and macdAcc
    primeBoost ? "PRIME" : c >= 4 ? "STRONG" : c >= 3 ? "WEAK" : "NONE"
tierRank(t) =>
    t == "PRIME" ? 3 : t == "STRONG" ? 2 : t == "WEAK" ? 1 : 0
tierBadge(t) =>
    t == "PRIME" ? "★" : t == "STRONG" ? "●" : t == "WEAK" ? "○" : ""

upTier = tierFromCount(upCount, upC4)
dnTier = tierFromCount(dnCount, dnC4)

// ============================================================================
// BULL/BEAR FLIP LAYER — BigBeluga-style supertrend (v3 NEW, v3.1 rewritten)
// ============================================================================
// Persistent BULL/BEAR state machine using close-based supertrend math.
//
// In BULL state:
//   • bullStopN = close − ATR×multN  (candidate this bar)
//   • Ratcheted UP — bullStopN := math.max(bullStopN, candidate). Stop only rises.
//   • Flip to BEAR when close < bullStop4 (the outermost ratcheted floor breaks).
// In BEAR state:
//   • bearStopN = close + ATR×multN  (candidate this bar)
//   • Ratcheted DOWN — bearStopN := math.min(bearStopN, candidate). Stop only falls.
//   • Flip to BULL when close > bearStop4 (the outermost ratcheted ceiling breaks).
//
// Why supertrend over the original pivot+ATR approach: on low-volatility bars
// where 8×ATR exceeds the 10-bar range, pivotLo+4×ATR rises above pivotHi−4×ATR,
// the stops cross, and close lands between them — flipping every bar. Supertrend
// keeps bull and bear stops always on the correct side of close by construction.
//
// flipState only changes at the flip — NOT every bar — which gives the visual
// cleanness BigBeluga's indicator is known for. Independent of TREND chips:
// chips fire on confluence + cooldown (fast layer); flips fire on band breach
// (slow layer).
//
// Confluence quality is STAMPED on the flip label but does NOT gate the flip.

// Four candidate bands per direction. ts4 (outermost) is the flip trigger;
// ts1-ts3 are visual fill bands when flipShowAllStops=true.
bullCandidate1 = close - atrValue * flipAtrMult1
bullCandidate2 = close - atrValue * flipAtrMult2
bullCandidate3 = close - atrValue * flipAtrMult3
bullCandidate4 = close - atrValue * flipAtrMult4
bearCandidate1 = close + atrValue * flipAtrMult1
bearCandidate2 = close + atrValue * flipAtrMult2
bearCandidate3 = close + atrValue * flipAtrMult3
bearCandidate4 = close + atrValue * flipAtrMult4

// State + ratcheting bands
var string flipState   = "BULL"   // boot state — first real flip will override
var float  bullStop1   = na
var float  bullStop2   = na
var float  bullStop3   = na
var float  bullStop4   = na
var float  bearStop1   = na
var float  bearStop2   = na
var float  bearStop3   = na
var float  bearStop4   = na
var int    lastFlipBar = -1
var string lastFlipTier = ""
var float  lastFlipPrice = na

// Flip detection — close vs PREVIOUS bar's outermost stop (avoids same-bar
// reset whip). On the first bar in a new state, the stops are re-armed to
// the candidate (no prior history).
isBull = flipState == "BULL"
isBear = flipState == "BEAR"

flipToBear = isBull and not na(bullStop4) and close < bullStop4
flipToBull = isBear and not na(bearStop4) and close > bearStop4

if flipToBear
    flipState     := "BEAR"
    lastFlipBar   := bar_index
    lastFlipPrice := close
    lastFlipTier  := dnTier
    // Re-arm bear bands to current candidates; bull bands cleared
    bearStop1 := bearCandidate1
    bearStop2 := bearCandidate2
    bearStop3 := bearCandidate3
    bearStop4 := bearCandidate4
    bullStop1 := na
    bullStop2 := na
    bullStop3 := na
    bullStop4 := na
else if flipToBull
    flipState     := "BULL"
    lastFlipBar   := bar_index
    lastFlipPrice := close
    lastFlipTier  := upTier
    bullStop1 := bullCandidate1
    bullStop2 := bullCandidate2
    bullStop3 := bullCandidate3
    bullStop4 := bullCandidate4
    bearStop1 := na
    bearStop2 := na
    bearStop3 := na
    bearStop4 := na
else if flipState == "BULL"
    // Ratchet bull bands UP — they only ever rise while in BULL
    bullStop1 := na(bullStop1) ? bullCandidate1 : math.max(bullStop1, bullCandidate1)
    bullStop2 := na(bullStop2) ? bullCandidate2 : math.max(bullStop2, bullCandidate2)
    bullStop3 := na(bullStop3) ? bullCandidate3 : math.max(bullStop3, bullCandidate3)
    bullStop4 := na(bullStop4) ? bullCandidate4 : math.max(bullStop4, bullCandidate4)
else  // BEAR
    // Ratchet bear bands DOWN — they only ever fall while in BEAR
    bearStop1 := na(bearStop1) ? bearCandidate1 : math.min(bearStop1, bearCandidate1)
    bearStop2 := na(bearStop2) ? bearCandidate2 : math.min(bearStop2, bearCandidate2)
    bearStop3 := na(bearStop3) ? bearCandidate3 : math.min(bearStop3, bearCandidate3)
    bearStop4 := na(bearStop4) ? bearCandidate4 : math.min(bearStop4, bearCandidate4)

// Active outermost stop (the one that drives the flip + dashboard)
activeStop = flipState == "BULL" ? bullStop4 : bearStop4

// HVN-anchor confluence — check if active stop sits inside any vpBins peak.
// "Hard Anchor" = active stop within 0.2×ATR of a local HVN peak.
// Implementation: scan vpBins on last bar (POC is already known), test for
// local maxima above 0.7× maxBinVol. Cheap — vpRows is ≤60.
isHardAnchor = false
if flipHvnConfluence and not na(activeStop) and atrValue > 0 and barstate.islast and vpStep > 0
    hvnThresh = atrValue * 0.2
    // Find max bin volume first
    maxBinV2 = 0.0
    for i = 0 to vpRows - 1
        bvX = array.get(vpBins, i)
        if bvX > maxBinV2
            maxBinV2 := bvX
    if maxBinV2 > 0
        for i = 1 to vpRows - 2
            bv   = array.get(vpBins, i)
            bvUp = array.get(vpBins, i + 1)
            bvDn = array.get(vpBins, i - 1)
            isPeak = bv > bvUp and bv > bvDn and bv >= maxBinV2 * 0.7
            if isPeak
                hvnPrice = vpLow + (i + 0.5) * vpStep
                if math.abs(hvnPrice - activeStop) <= hvnThresh
                    isHardAnchor := true

// ============================================================================
// REGIME SHIFT SIGNALS — TIER-FILTERED (v3: volume gate removed)
// ============================================================================
rawShiftToRange = isRange and not isRange[1]
rawShiftToTrend = isTrend and not isTrend[1]

var int barsSinceShift = 9999
barsSinceShift := barsSinceShift + 1
cooldownOk = barsSinceShift >= cooldownBars

minRank = tierRank(minTierToShow)
passesUp = tierRank(upTier) >= minRank and (not showOnlyPrime or upTier == "PRIME")
passesDn = tierRank(dnTier) >= minRank and (not showOnlyPrime or dnTier == "PRIME")

shiftToTrendUp_raw   = rawShiftToTrend and cooldownOk and close > vwapCalc
shiftToTrendDown_raw = rawShiftToTrend and cooldownOk and close <= vwapCalc
shiftToRange         = rawShiftToRange and cooldownOk

// Same-direction lockout — track last fire bar per direction
var int lastUpBar = -9999
var int lastDnBar = -9999
sameDirOkUp = (bar_index - lastUpBar) >= sameDirLockout
sameDirOkDn = (bar_index - lastDnBar) >= sameDirLockout

// Optional HTF gate — three modes (see v2.1 changelog)
htfOkUp = htfMode == "Off" or (htfMode == "Aligned" and htfBull) or (htfMode == "Reversal" and htfBear)
htfOkDn = htfMode == "Off" or (htfMode == "Aligned" and htfBear) or (htfMode == "Reversal" and htfBull)

shiftToTrendUp   = shiftToTrendUp_raw   and passesUp and sameDirOkUp and htfOkUp
shiftToTrendDown = shiftToTrendDown_raw and passesDn and sameDirOkDn and htfOkDn

if shiftToTrendUp
    lastUpBar := bar_index
if shiftToTrendDown
    lastDnBar := bar_index

// ============================================================================
// OPTIMIZER CAPTURE — Path C — every shift candidate (MC webhook)
// ============================================================================
// Fires once per shift candidate that passed volume + cooldown gates.
// Tier, sameDirLockout, HTF alignment, and VWAP-side are LOGGED in the payload,
// NOT enforced — that's what lets the MC optimizer post-hoc filter on each.
// Direction inferred from confluence majority (tie → up) so VWAP-side becomes
// just another logged variable instead of a hardcoded gate.
captureUp        = upCount >= dnCount
captureScore     = captureUp ? upScore : dnScore
captureTier      = captureUp ? upTier  : dnTier
captureHtfAlg    = captureUp ? htfBull : htfBear
captureVwapOk    = captureUp ? close > vwapCalc : close < vwapCalc
captureHmaAlg    = captureUp ? cloudBull : cloudBear
captureMacdAc    = captureUp ? macdAccelUp : macdAccelDn
captureFire      = captureAllShifts and rawShiftToTrend and cooldownOk

if captureFire
    htfStateStr = htfBull ? "BULL" : htfBear ? "BEAR" : "FLAT"
    dirStr      = captureUp ? "up" : "down"
    hmaStr      = captureHmaAlg ? "true" : "false"
    macdStr     = captureMacdAc ? "true" : "false"
    vwapStr     = captureVwapOk ? "true" : "false"
    htfAlgStr   = captureHtfAlg ? "true" : "false"
    p1 = '{"type":"shift_candidate","ts_ms":' + str.tostring(time)
    p2 = ',"sym":"' + syminfo.ticker + '","exchange":"' + syminfo.prefix + '"'
    p3 = ',"tf":"' + timeframe.period + '","profile":"' + profileText + '","direction":"' + dirStr + '"'
    p4 = ',"trigger_price":' + str.tostring(close, "#.####") + ',"atr":' + str.tostring(atrValue, "#.####")
    pc1 = ',"components":{"er":' + str.tostring(efficiencyRatio, "#.####") + ',"vol_ratio":' + str.tostring(volRatio, "#.##")
    pc2 = ',"hma_aligned":' + hmaStr + ',"rsi":' + str.tostring(rsiVal, "#.##")
    pc3 = ',"macd_accel":' + macdStr + ',"vwap_side_correct":' + vwapStr + '}'
    p5 = ',"score":' + str.tostring(captureScore) + ',"tier":"' + captureTier + '"'
    p6 = ',"htf_state":"' + htfStateStr + '","htf_aligned":' + htfAlgStr
    p7 = ',"lookback_bars_in_trend":' + str.tostring(barsInTrend) + ',"bars_since_last_shift":' + str.tostring(barsSinceShift) + '}'
    payload = p1 + p2 + p3 + p4 + pc1 + pc2 + pc3 + p5 + p6 + p7
    alert(payload, alert.freq_once_per_bar_close)

anyShift = shiftToTrendUp or shiftToTrendDown or shiftToRange
if anyShift
    barsSinceShift := 0

// Track last shift for the dashboard
var string lastShiftLabel    = "—"
var string lastShiftTier     = ""
var int    lastShiftBarIdx   = -1
var float  lastShiftVolRatio = 0.0

if shiftToTrendUp
    lastShiftLabel    := "TREND ↑"
    lastShiftTier     := upTier
    lastShiftBarIdx   := bar_index
    lastShiftVolRatio := volRatio
if shiftToTrendDown
    lastShiftLabel    := "TREND ↓"
    lastShiftTier     := dnTier
    lastShiftBarIdx   := bar_index
    lastShiftVolRatio := volRatio
if shiftToRange
    lastShiftLabel    := "RANGE"
    lastShiftTier     := ""
    lastShiftBarIdx   := bar_index
    lastShiftVolRatio := volRatio

// ============================================================================
// TRADE PLAN — Auto Stop / Target 1 / Target 2 (with freshness gates)
// ============================================================================
// Direction-aware levels driven by last shift direction, BUT only paints when:
//   1. A TREND shift has fired (not just RANGE / no shift)
//   2. The shift is FRESH (within tradePlanStaleBars of now)
//   3. Current confluence STILL agrees with the shift direction (no regime flip)
// Otherwise the row shows the reason it's invalidated, so the trader knows to wait.
//
// Plan formulas when valid:
//   LONG  → Stop = SPOT − 1×ATR · T1 = nearest level above (or SPOT + 1×ATR fallback) · T2 = SPOT + 2×ATR
//   SHORT → Stop = SPOT + 1×ATR · T1 = nearest level below (or SPOT − 1×ATR fallback) · T2 = SPOT − 2×ATR
// Levels considered for T1: CALL WALL, PUT WALL, MAX PAIN, ANCHOR, FLIP

biasIsLong  = lastShiftLabel == "TREND ↑"
biasIsShort = lastShiftLabel == "TREND ↓"
hasBias     = biasIsLong or biasIsShort

// Freshness — bars since last shift label was set
barsSinceLastShift = lastShiftBarIdx >= 0 ? bar_index - lastShiftBarIdx : 999999
isPlanStale        = hasBias and barsSinceLastShift > tradePlanStaleBars

// Confluence flip — opposing-direction score has overtaken current bias by threshold
isConfluenceFlipped = (biasIsLong  and dnScore > upScore + tradePlanFlipThreshold)
                   or (biasIsShort and upScore > dnScore + tradePlanFlipThreshold)

planValid = hasBias and not isPlanStale and not isConfluenceFlipped

// Nearest level above close (for long T1)
_lvlAbove1 = not na(callWallLvl)  and callWallLvl  > close ? callWallLvl  : 1.0e15
_lvlAbove2 = not na(maxPainLevel) and maxPainLevel > close ? maxPainLevel : 1.0e15
_lvlAbove3 = not na(anchorLevel)  and anchorLevel  > close ? anchorLevel  : 1.0e15
_lvlAbove4 = not na(flipLevel)    and flipLevel    > close ? flipLevel    : 1.0e15
nearestAboveClose = math.min(_lvlAbove1, math.min(_lvlAbove2, math.min(_lvlAbove3, _lvlAbove4)))
hasLevelAbove     = nearestAboveClose < 1.0e14

// Nearest level below close (for short T1)
_lvlBelow1 = not na(putWallLvl)   and putWallLvl   < close ? putWallLvl   : -1.0e15
_lvlBelow2 = not na(maxPainLevel) and maxPainLevel < close ? maxPainLevel : -1.0e15
_lvlBelow3 = not na(anchorLevel)  and anchorLevel  < close ? anchorLevel  : -1.0e15
_lvlBelow4 = not na(flipLevel)    and flipLevel    < close ? flipLevel    : -1.0e15
nearestBelowClose = math.max(_lvlBelow1, math.max(_lvlBelow2, math.max(_lvlBelow3, _lvlBelow4)))
hasLevelBelow     = nearestBelowClose > -1.0e14

// Levels only computed when plan is valid — otherwise na so dashboard knows to render reason
planStop = planValid ? (biasIsLong ? close - atrValue                                       : close + atrValue)                                       : float(na)
planT1   = planValid ? (biasIsLong ? (hasLevelAbove ? nearestAboveClose : close + atrValue) : (hasLevelBelow ? nearestBelowClose : close - atrValue)) : float(na)
planT2   = planValid ? (biasIsLong ? close + atrValue * 2.0                                 : close - atrValue * 2.0)                                 : float(na)

// Risk:reward computed from the three values
planRisk   = planValid ? (biasIsLong ? close - planStop : planStop - close) : float(na)
planReward = planValid ? (biasIsLong ? planT2  - close  : close - planT2)   : float(na)
planRR     = not na(planRisk) and planRisk > 0 ? planReward / planRisk : float(na)

// ============================================================================
// HIT RATE TRACKER — Path A (in-Pine, PRIME signals only)
// ============================================================================
// Captures every PRIME ★ shift (up or down). Grades at three horizons sized
// to the active trader profile: Day = 5/10/20 bars (intraday/0DTE relevant);
// Swing = 50/100/200 bars (~2/4/8 trading days on 1H, the right horizon for
// swing-trade theses). Hit = price moved in signal direction by horizon.
// R-multiple = move / ATR_at_fire (matches Trade Plan auto-stop denominator).
//
// Limitations (Path A):
//   • Stats reset on chart reload, settings change, or symbol switch.
//   • Single chart / single TF / single symbol.
//   • Use Path B (TV webhook → MC Algo Lab) for persistent multi-symbol grading.

var int[]   primeSigBars   = array.new<int>()
var float[] primeSigPrices = array.new<float>()
var bool[]  primeSigDirs   = array.new<bool>()    // true = TREND↑, false = TREND↓
var float[] primeSigATRs   = array.new<float>()   // ATR at fire (1R denominator)

var int   primeHitsH1   = 0
var int   primeMissesH1 = 0
var float primeRSumH1   = 0.0
var int   primeHitsH2   = 0
var int   primeMissesH2 = 0
var float primeRSumH2   = 0.0
var int   primeHitsH3   = 0
var int   primeMissesH3 = 0
var float primeRSumH3   = 0.0

// Capture on PRIME fire
primeUpFire = shiftToTrendUp   and upTier == "PRIME"
primeDnFire = shiftToTrendDown and dnTier == "PRIME"
if primeUpFire or primeDnFire
    array.push(primeSigBars,   bar_index)
    array.push(primeSigPrices, close)
    array.push(primeSigDirs,   primeUpFire)
    array.push(primeSigATRs,   atrValue)
    if array.size(primeSigBars) > maxTrackedSig
        array.shift(primeSigBars)
        array.shift(primeSigPrices)
        array.shift(primeSigDirs)
        array.shift(primeSigATRs)

// Grade signals that hit horizon exactly this bar (each signal grades 3× total)
if array.size(primeSigBars) > 0
    for i = 0 to array.size(primeSigBars) - 1
        sigBar = array.get(primeSigBars, i)
        age    = bar_index - sigBar
        if age == hxH1 or age == hxH2 or age == hxH3
            sigPrice = array.get(primeSigPrices, i)
            sigDir   = array.get(primeSigDirs, i)
            sigATR   = array.get(primeSigATRs, i)
            moved    = sigDir ? (close - sigPrice) : (sigPrice - close)
            hit      = moved > 0
            rMult    = sigATR > 0 ? moved / sigATR : 0.0
            if age == hxH1
                if hit
                    primeHitsH1 := primeHitsH1 + 1
                else
                    primeMissesH1 := primeMissesH1 + 1
                primeRSumH1 := primeRSumH1 + rMult
            else if age == hxH2
                if hit
                    primeHitsH2 := primeHitsH2 + 1
                else
                    primeMissesH2 := primeMissesH2 + 1
                primeRSumH2 := primeRSumH2 + rMult
            else
                if hit
                    primeHitsH3 := primeHitsH3 + 1
                else
                    primeMissesH3 := primeMissesH3 + 1
                primeRSumH3 := primeRSumH3 + rMult

// Drop fully-graded signals (older than longest horizon).
// Single-cond while + inner break avoids Pine v5's and-no-short-circuit-in-while quirk.
while array.size(primeSigBars) > 0
    firstBar = array.get(primeSigBars, 0)
    if (bar_index - firstBar) <= hxH3
        break
    array.shift(primeSigBars)
    array.shift(primeSigPrices)
    array.shift(primeSigDirs)
    array.shift(primeSigATRs)

// Aggregate stats for dashboard
hxTotalH1 = primeHitsH1 + primeMissesH1
hxTotalH2 = primeHitsH2 + primeMissesH2
hxTotalH3 = primeHitsH3 + primeMissesH3
hxPctH1   = hxTotalH1 > 0 ? math.round(primeHitsH1 * 100.0 / hxTotalH1) : 0
hxPctH2   = hxTotalH2 > 0 ? math.round(primeHitsH2 * 100.0 / hxTotalH2) : 0
hxPctH3   = hxTotalH3 > 0 ? math.round(primeHitsH3 * 100.0 / hxTotalH3) : 0
hxAvgRH3  = hxTotalH3 > 0 ? primeRSumH3 / hxTotalH3 : 0.0

// ============================================================================
// PLOT — VWAP, BANDS, EXPECTED MOVE
// ============================================================================
plot(showVwap  ? vwapCalc   : na, "ANCHOR (VWAP)", color=colBlue, linewidth=2)
plot(showVwap  ? vwapUpper1 : na, "VWAP +1σ",      color=color.new(colBlue, 60), linewidth=1)
plot(showVwap  ? vwapLower1 : na, "VWAP -1σ",      color=color.new(colBlue, 60), linewidth=1)

pEM_Upper = plot(showBands ? emHigh : na, "EM Upper", color=color.new(colYellow, 50), linewidth=1)
pEM_Lower = plot(showBands ? emLow  : na, "EM Lower", color=color.new(colYellow, 50), linewidth=1)
pMid      = plot(showBands ? close  : na, "Mid",      color=color.new(colYellow, 100), linewidth=1)
fill(pEM_Upper, pMid, color=color.new(colYellow, 94), title="EM Upper Fill")
fill(pMid, pEM_Lower, color=color.new(colYellow, 94), title="EM Lower Fill")

// Key level lines (extend across chart for reference)
plot(callWallLvl,  "CALL WALL", color=colGreen,   linewidth=2, style=plot.style_linebr)
plot(putWallLvl,   "PUT WALL",  color=colRed,     linewidth=2, style=plot.style_linebr)
plot(maxPainLevel, "MAX PAIN",  color=colMaxPain, linewidth=2, style=plot.style_stepline)

// Flip level — drawn as dashed line on last bar (POC only finalized then)
var line flipLine = na
if barstate.islast
    if not na(flipLine)
        line.delete(flipLine)
    if not na(flipLevel) and flipLevel > 0
        flipLine := line.new(bar_index - 1, flipLevel, bar_index, flipLevel, color=colFlip, width=2, style=line.style_dashed, extend=extend.both)

// ============================================================================
// PLOT — HMA CLOUD (replaces background tint)
// ============================================================================
// Cloud color: green when bull, red when bear, faded extra in CAUTION/RANGE
cloudBaseCol = cloudBull ? colGreen : cloudBear ? colRed : colYellow
cloudFinalOp = isTrend ? cloudOpacity : isCaution ? math.min(cloudOpacity + 20, 95) : math.min(cloudOpacity + 32, 95)
cloudFillCol = color.new(cloudBaseCol, cloudFinalOp)

pHF = plot(showCloud ? hmaFast : na, "HMA Fast", color=color.new(cloudBaseCol, math.max(cloudFinalOp - 30, 0)), linewidth=1)
pHS = plot(showCloud ? hmaSlow : na, "HMA Slow", color=color.new(cloudBaseCol, math.max(cloudFinalOp - 30, 0)), linewidth=1)
fill(pHF, pHS, color=cloudFillCol, title="HMA Cloud")

// ============================================================================
// PLOT — BULL/BEAR FLIP LAYER (v3 NEW)
// ============================================================================
// Active stop is the outermost band (ts4) — that's the flip trigger.
// HVN-anchored stop gets gold color + thicker line (the "Hard Anchor" state).
// Pine's plot() linewidth needs a compile-time constant, so we render as two
// separate plots — normal-weight when floating, thicker-weight when anchored.
// Only one is ever non-na on a given bar.
flipLineCol  = isHardAnchor ? color.rgb(253, 224, 71) : flipState == "BULL" ? colGreen : colRed
plot(showFlip and not isHardAnchor ? activeStop : na, "Flip Stop (ts4)",        color=flipLineCol, linewidth=2, style=plot.style_stepline)
plot(showFlip and isHardAnchor     ? activeStop : na, "Flip Stop (anchored)",   color=flipLineCol, linewidth=3, style=plot.style_stepline)

// Inner bands (ts1-ts3) for the BigBeluga heatmap look — only when toggled
showInners = showFlip and flipShowAllStops
pBStop1 = plot(showInners ? (flipState == "BULL" ? bullStop1 : bearStop1) : na, "Flip ts1", color=color.new(flipState == "BULL" ? colGreen : colRed, 65), linewidth=1, style=plot.style_stepline)
pBStop2 = plot(showInners ? (flipState == "BULL" ? bullStop2 : bearStop2) : na, "Flip ts2", color=color.new(flipState == "BULL" ? colGreen : colRed, 75), linewidth=1, style=plot.style_stepline)
pBStop3 = plot(showInners ? (flipState == "BULL" ? bullStop3 : bearStop3) : na, "Flip ts3", color=color.new(flipState == "BULL" ? colGreen : colRed, 85), linewidth=1, style=plot.style_stepline)

// Bull/Bear label on the flip bar — BigBeluga's signature signal.
// Stamped with confluence tier badge (★/●/○) if tier ≥ WEAK, plain otherwise.
if showFlip and flipShowLabels and flipToBull
    flipBadge = lastFlipTier == "PRIME" ? "★" : lastFlipTier == "STRONG" ? "●" : lastFlipTier == "WEAK" ? "○" : ""
    flipTxt   = flipBadge == "" ? "Bull" : "Bull " + flipBadge + " " + str.tostring(upScore)
    label.new(bar_index, low, text=flipTxt, yloc=yloc.belowbar, style=label.style_label_up, color=lastFlipTier == "PRIME" ? colPrime : colGreen, textcolor=lastFlipTier == "PRIME" ? color.black : color.white, size=size.small)

if showFlip and flipShowLabels and flipToBear
    flipBadge = lastFlipTier == "PRIME" ? "★" : lastFlipTier == "STRONG" ? "●" : lastFlipTier == "WEAK" ? "○" : ""
    flipTxt   = flipBadge == "" ? "Bear" : "Bear " + flipBadge + " " + str.tostring(dnScore)
    label.new(bar_index, high, text=flipTxt, yloc=yloc.abovebar, style=label.style_label_down, color=lastFlipTier == "PRIME" ? colPrime : colRed, textcolor=lastFlipTier == "PRIME" ? color.black : color.white, size=size.small)

// ============================================================================
// VOLUME PROFILE — INVERTED HEATMAP (boxes extending LEFT into chart)
// ============================================================================
var box[]   vpBoxes  = array.new<box>()
var label[] vpLabels = array.new<label>()

if barstate.islast
    // Clean previous run
    if array.size(vpBoxes) > 0
        for i = 0 to array.size(vpBoxes) - 1
            box.delete(array.get(vpBoxes, i))
        array.clear(vpBoxes)
    if array.size(vpLabels) > 0
        for i = 0 to array.size(vpLabels) - 1
            label.delete(array.get(vpLabels, i))
        array.clear(vpLabels)

if barstate.islast and showVP and vpStep > 0
    maxBinVol = 0.0
    for i = 0 to vpRows - 1
        bv = array.get(vpBins, i)
        if bv > maxBinVol
            maxBinVol := bv

    pocBinIdx = int(math.floor((nz(pocLevel, vpLow) - vpLow) / vpStep))
    rightX = bar_index + 1

    if maxBinVol > 0
        for i = 0 to vpRows - 1
            bv = array.get(vpBins, i)
            if bv > 0
                ratio = bv / maxBinVol
                shelfWidth = int(math.round(ratio * vpWidth))
                priceMid = vpLow + (i + 0.5) * vpStep
                rowTop   = priceMid + vpStep * 0.45
                rowBot   = priceMid - vpStep * 0.45

                // Color: gradient low→high, magenta accent on POC
                isPocBin = i == pocBinIdx
                gradCol  = color.from_gradient(ratio, 0.0, 1.0, colHeatLow, colHeatHigh)
                shelfCol = isPocBin ? color.new(colHeatPoc, math.max(vpOpacity - 15, 10)) : color.new(gradCol, vpOpacity)

                leftX = rightX - shelfWidth
                newBox = box.new(leftX, rowTop, rightX, rowBot, border_color=color.new(color.black, 100), bgcolor=shelfCol)
                array.push(vpBoxes, newBox)

// ============================================================================
// LEVEL BADGES — heatmap-style inline pills with icons
// ============================================================================
makeBadge(price, txt, bg, txtCol) =>
    valid = not na(price) and price > 0
    if valid
        lbl = label.new(bar_index + 4, price, text=txt, xloc=xloc.bar_index, yloc=yloc.price, color=bg, textcolor=txtCol, style=label.style_label_left, size=size.small)
        array.push(vpLabels, lbl)
    valid

if barstate.islast and showVPLabels
    makeBadge(anchorLevel,  "⚓ ANCHOR "  + str.tostring(anchorLevel,  "#.##"), colBlue,    color.white)
    makeBadge(flipLevel,    "⚡ FLIP "    + str.tostring(flipLevel,    "#.##"), colFlip,    color.white)
    makeBadge(maxPainLevel, "★ PAIN "    + str.tostring(maxPainLevel, "#.##"), colMaxPain, color.white)
    makeBadge(callWallLvl,  "▲ CALL "    + str.tostring(callWallLvl,  "#.##"), colGreen,   color.black)
    makeBadge(putWallLvl,   "▼ PUT "     + str.tostring(putWallLvl,   "#.##"), colRed,     color.white)
    makeBadge(close,         "● SPOT "    + str.tostring(close,         "#.##"), color.new(colBlue, 30), color.white)

// ============================================================================
// PLOT — TIERED REGIME SHIFT LABELS (dynamic text via label.new)
// ============================================================================
if showShifts and shiftToTrendUp
    // PRIME = 5/5 + accel = 100 by definition; just show the star. STRONG/WEAK keep the score.
    txt = upTier == "PRIME" ? "TREND↑ ★" : "TREND↑ " + tierBadge(upTier) + " " + str.tostring(upScore)
    sz  = upTier == "PRIME" ? size.small : size.tiny
    bgC = upTier == "PRIME" ? colPrime : colGreen
    fgC = upTier == "PRIME" ? color.black : color.white
    label.new(bar_index, low, text=txt, yloc=yloc.belowbar, style=label.style_label_up, color=bgC, textcolor=fgC, size=sz)

if showShifts and shiftToTrendDown
    txt = dnTier == "PRIME" ? "TREND↓ ★" : "TREND↓ " + tierBadge(dnTier) + " " + str.tostring(dnScore)
    sz  = dnTier == "PRIME" ? size.small : size.tiny
    bgC = dnTier == "PRIME" ? colPrime : colRed
    fgC = dnTier == "PRIME" ? color.black : color.white
    label.new(bar_index, high, text=txt, yloc=yloc.abovebar, style=label.style_label_down, color=bgC, textcolor=fgC, size=sz)

if showShifts and shiftToRange
    label.new(bar_index, high, text="RANGE", yloc=yloc.abovebar, style=label.style_label_down, color=colBlue, textcolor=color.white, size=size.tiny)

// ============================================================================
// BACKGROUND TINT (off by default)
// ============================================================================
bgColor = showBg ? color.new(regimeColor, 95) : na
bgcolor(bgColor, title="Regime Background")

// ============================================================================
// DASHBOARD
// ============================================================================
if showDashboard and barstate.islast
    tablePos = dashPosition == "Top Right" ? position.top_right : dashPosition == "Middle Right" ? position.middle_right : dashPosition == "Top Left" ? position.top_left : dashPosition == "Bottom Right" ? position.bottom_right : position.bottom_left
    var table dashTable = table.new(tablePos, 2, 18, bgcolor=color.new(#0a0a0f, 10), border_color=color.new(colBlue, 60), border_width=1, frame_color=color.new(colBlue, 40), frame_width=2)

    // 0 - Header (v3.2: BigBeluga-style flip + volume-free confluence)
    table.cell(dashTable, 0, 0, "BLUF SIGNAL v3.2", text_color=colBlue, text_size=size.small, bgcolor=color.new(colBlue, 85))
    table.cell(dashTable, 1, 0, regimeText, text_color=color.white, text_size=size.small, bgcolor=color.new(regimeColor, 40))

    // 1 - Profile
    table.cell(dashTable, 0, 1, "PROFILE", text_color=color.new(color.white, 30), text_size=size.tiny)
    table.cell(dashTable, 1, 1, profileText + "  HMA " + str.tostring(hmaFastLen) + "/" + str.tostring(hmaSlowLen), text_color=isDayProfile ? colYellow : colBlue, text_size=size.tiny)

    // 2 - Last Shift (with tier badge)
    barsAgo = lastShiftBarIdx >= 0 ? bar_index - lastShiftBarIdx : -1
    badgeStr = lastShiftTier == "" ? "" : "  " + tierBadge(lastShiftTier)
    shiftCellText = lastShiftBarIdx < 0 ? "—" : lastShiftLabel + badgeStr + "  " + str.tostring(barsAgo) + "b · " + str.tostring(lastShiftVolRatio, "#.#") + "×"
    shiftCellColor = lastShiftLabel == "TREND ↑" ? colGreen : lastShiftLabel == "TREND ↓" ? colRed : lastShiftLabel == "RANGE" ? colBlue : color.new(color.white, 50)
    table.cell(dashTable, 0, 2, "LAST SHIFT", text_color=color.new(color.white, 30), text_size=size.tiny)
    table.cell(dashTable, 1, 2, shiftCellText, text_color=shiftCellColor, text_size=size.tiny)

    // 3 - Cloud direction
    cloudTxt = cloudBull ? "BULL ▲" : cloudBear ? "BEAR ▼" : "FLAT —"
    cloudClr = cloudBull ? colGreen : cloudBear ? colRed : color.new(color.white, 30)
    table.cell(dashTable, 0, 3, "CLOUD", text_color=color.new(color.white, 30), text_size=size.tiny)
    table.cell(dashTable, 1, 3, cloudTxt, text_color=cloudClr, text_size=size.tiny)

    // 4 - HTF (higher-timeframe trend reference)
    htfLabel = "HTF " + htfTimeframe + (htfMode == "Off" ? "" : htfMode == "Aligned" ? " 🔒" : " ↺")
    table.cell(dashTable, 0, 4, htfLabel, text_color=color.new(color.white, 30), text_size=size.tiny)
    table.cell(dashTable, 1, 4, htfText, text_color=htfClr, text_size=size.tiny)

    // 5 - Confluence (UP/DN scores + tiers, live)
    confluenceTxt = "↑" + str.tostring(upScore) + tierBadge(upTier) + "  ↓" + str.tostring(dnScore) + tierBadge(dnTier)
    confluenceClr = upScore > dnScore ? colGreen : dnScore > upScore ? colRed : color.new(color.white, 50)
    table.cell(dashTable, 0, 5, "CONFLUENCE", text_color=color.new(color.white, 30), text_size=size.tiny)
    table.cell(dashTable, 1, 5, confluenceTxt, text_color=confluenceClr, text_size=size.tiny)

    // 6 - Trade Plan (auto stop / T1 / T2 / R:R, freshness-gated)
    biasArrow = biasIsLong ? "↑" : biasIsShort ? "↓" : ""
    rrStr     = not na(planRR) and planRR > 0 ? "  · " + str.tostring(planRR, "#.#") + "R" : ""
    planText  = planValid           ? biasArrow + " S " + str.tostring(planStop, "#.##") + " · T1 " + str.tostring(planT1, "#.##") + " · T2 " + str.tostring(planT2, "#.##") + rrStr
              : isPlanStale         ? "—  stale (" + str.tostring(barsSinceLastShift) + "b ago)"
              : isConfluenceFlipped ? "—  regime flipped"
              :                       "—  no bias"
    planColor = planValid           ? (biasIsLong ? colGreen : colRed)
              : isPlanStale         ? colYellow
              : isConfluenceFlipped ? colYellow
              :                       color.new(color.white, 30)
    if showTradePlan
        table.cell(dashTable, 0, 6, "TRADE PLAN", text_color=color.new(color.white, 30), text_size=size.tiny)
        table.cell(dashTable, 1, 6, planText,     text_color=planColor,                  text_size=size.tiny)

    // 7 - PRIME Hit Rate (profile-aware horizons · avg R at longest horizon)
    if showHitRate
        hxText = hxTotalH1 == 0 and hxTotalH2 == 0 and hxTotalH3 == 0 ? "—  no graded signals yet" : str.tostring(hxH1) + "b " + str.tostring(hxPctH1) + "% · " + str.tostring(hxH2) + "b " + str.tostring(hxPctH2) + "% · " + str.tostring(hxH3) + "b " + str.tostring(hxPctH3) + "% · " + str.tostring(hxAvgRH3, "+#.#;-#.#") + "R"
        hxColor = hxTotalH3 < 5 ? color.new(color.white, 30) : hxPctH3 >= 60 ? colGreen : hxPctH3 < 40 ? colRed : color.white
        hxLabel = "PRIME HX " + str.tostring(hxTotalH3) + "g"
        table.cell(dashTable, 0, 7, hxLabel, text_color=color.new(color.white, 30), text_size=size.tiny)
        table.cell(dashTable, 1, 7, hxText,  text_color=hxColor,                    text_size=size.tiny)

    // 8 - Dealer Gamma
    table.cell(dashTable, 0, 8, "DEALER", text_color=color.new(color.white, 30), text_size=size.tiny)
    table.cell(dashTable, 1, 8, dealerText, text_color=dealerColor, text_size=size.tiny)

    // 9 - Anchor
    table.cell(dashTable, 0, 9, "ANCHOR", text_color=color.new(color.white, 30), text_size=size.tiny)
    table.cell(dashTable, 1, 9, str.tostring(anchorLevel, "#.##"), text_color=colBlue, text_size=size.tiny)

    // 10 - γ Flip (dealer gamma flip price level — distinct from BULL/BEAR flip state on row 17)
    table.cell(dashTable, 0, 10, "γ FLIP", text_color=color.new(color.white, 30), text_size=size.tiny)
    table.cell(dashTable, 1, 10, str.tostring(flipLevel, "#.##"), text_color=colFlip, text_size=size.tiny)

    // 11 - Call Wall
    table.cell(dashTable, 0, 11, "CALL WALL", text_color=color.new(color.white, 30), text_size=size.tiny)
    table.cell(dashTable, 1, 11, str.tostring(callWallLvl, "#.##"), text_color=colGreen, text_size=size.tiny)

    // 12 - Put Wall
    table.cell(dashTable, 0, 12, "PUT WALL", text_color=color.new(color.white, 30), text_size=size.tiny)
    table.cell(dashTable, 1, 12, str.tostring(putWallLvl, "#.##"), text_color=colRed, text_size=size.tiny)

    // 13 - Max Pain
    table.cell(dashTable, 0, 13, "MAX PAIN", text_color=color.new(color.white, 30), text_size=size.tiny)
    table.cell(dashTable, 1, 13, str.tostring(maxPainLevel, "#.##"), text_color=colMaxPain, text_size=size.tiny)

    // 14 - ATR
    table.cell(dashTable, 0, 14, "ATR(" + str.tostring(atrLength) + ")", text_color=color.new(color.white, 30), text_size=size.tiny)
    table.cell(dashTable, 1, 14, str.tostring(atrValue, "#.##"), text_color=color.white, text_size=size.tiny)

    // 15 - ER (volume removed from display in v3 — volRatio still logged in capture payload)
    table.cell(dashTable, 0, 15, "ER", text_color=color.new(color.white, 30), text_size=size.tiny)
    table.cell(dashTable, 1, 15, str.tostring(efficiencyRatio, "#.##"), text_color=regimeColor, text_size=size.tiny)

    // 16 - Mode
    modeText = autoMode ? "AUTO" : "MANUAL"
    table.cell(dashTable, 0, 16, "MODE", text_color=color.new(color.white, 30), text_size=size.tiny)
    table.cell(dashTable, 1, 16, modeText, text_color=autoMode ? colBlue : colYellow, text_size=size.tiny)

    // 17 - FLIP MODE (BigBeluga-style BULL/BEAR state — v3 NEW)
    if showFlip
        barsSinceFlip   = lastFlipBar >= 0 ? bar_index - lastFlipBar : -1
        flipModeBadge   = lastFlipTier == "" ? "" : "  " + tierBadge(lastFlipTier)
        flipAnchorMark  = isHardAnchor ? "  ⚓" : ""
        flipModeArrow   = flipState == "BULL" ? "BULL ▲" : "BEAR ▼"
        flipModeText    = lastFlipBar < 0 ? flipModeArrow + "  (no flip yet)" : flipModeArrow + flipModeBadge + "  " + str.tostring(barsSinceFlip) + "b" + flipAnchorMark
        flipModeColor   = isHardAnchor ? color.rgb(253, 224, 71) : flipState == "BULL" ? colGreen : colRed
        table.cell(dashTable, 0, 17, "FLIP MODE", text_color=color.new(color.white, 30), text_size=size.tiny)
        table.cell(dashTable, 1, 17, flipModeText, text_color=flipModeColor, text_size=size.tiny)

// ============================================================================
// ALERTS
// ============================================================================
// Tier-aware shift alerts
primeUp   = shiftToTrendUp   and upTier == "PRIME"
primeDn   = shiftToTrendDown and dnTier == "PRIME"
strongUp  = shiftToTrendUp   and upTier == "STRONG"
strongDn  = shiftToTrendDown and dnTier == "STRONG"

alertcondition(primeUp,         "PRIME TREND ↑",            "PRIME (5/5 + accel) regime shift to TREND UP")
alertcondition(primeDn,         "PRIME TREND ↓",            "PRIME (5/5 + accel) regime shift to TREND DOWN")
alertcondition(strongUp,        "STRONG TREND ↑",           "STRONG (4/5 or 5/5 no accel) regime shift to TREND UP")
alertcondition(strongDn,        "STRONG TREND ↓",           "STRONG (4/5 or 5/5 no accel) regime shift to TREND DOWN")
alertcondition(shiftToTrendUp,  "Any TREND ↑ (filtered)",   "Tier-filtered regime shift to TREND UP")
alertcondition(shiftToTrendDown,"Any TREND ↓ (filtered)",   "Tier-filtered regime shift to TREND DOWN")
alertcondition(shiftToRange,    "Regime → RANGE",           "Regime shift to RANGE (volume gate removed in v3)")
alertcondition(anyShift,        "Any Regime Shift",         "Tier-filtered regime shift fired (TREND↑/↓ or RANGE)")

// Bull/Bear Flip alerts (v3 NEW — BigBeluga-style state flips)
alertcondition(flipToBull, "Bull Flip", "Bull Flip — flipState BEAR → BULL (close > outermost bear stop)")
alertcondition(flipToBear, "Bear Flip", "Bear Flip — flipState BULL → BEAR (close < outermost bull stop)")

// Price-vs-level crosses
alertcondition(ta.crossover(close, flipLevel),    "Price Crossed Above Flip",  "Price crossed ABOVE flip level")
alertcondition(ta.crossunder(close, flipLevel),   "Price Crossed Below Flip",  "Price crossed BELOW flip level")
alertcondition(ta.crossover(close, anchorLevel),  "Price Crossed Above Anchor","Price crossed ABOVE anchor level")
alertcondition(ta.crossunder(close, anchorLevel), "Price Crossed Below Anchor","Price crossed BELOW anchor level")
alertcondition(ta.crossover(close, callWallLvl),  "Price Broke Call Wall",     "Price broke above CALL WALL")
alertcondition(ta.crossunder(close, putWallLvl),  "Price Broke Put Wall",      "Price broke below PUT WALL")
````
