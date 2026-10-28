# SPY / SPX Intraday Pro v31 [Signals + Mentor + SVP + Confluence]

- url: https://www.tradingview.com/script/59W7SU8j-SPY-SPX-Intraday-Pro-v31-Signals-Mentor-SVP-Confluence/
- type: indicator
- pine_id: PUB;d2ddd2ac2a184941a6b59283a0d8800c
- version: 1.0

## Description

Description
Built specifically for SPY and SPX 0DTE and short-dated options trading on the 1-minute timeframe. Not a generic indicator — every layer of this system was designed around how SPY actually moves intraday.
What This IsSPY/SPX Intraday Pro is a complete intraday trading system in a single script. It combines multi-timeframe signal generation, active trade management, session volume profile, and a real-time confluence engine into one unified dashboard — so you spend less time reading indicators and more time executing clean trades.Version 31 builds on a deeply refined signal engine with four distinct entry paths, a mentor system that tracks your trade from entry to exit, and a new confluence layer that scores setup quality before you ever click buy.How It WorksThree timeframes. One decision.The script reads market structure from the top down:
15-minute — establishes the primary bias using price vs VWAP. This is your directional anchor. If 15m is BULL you're looking for calls. If 15m is BEAR you're looking for puts. Full stop.
5-minute — confirms structure using price, VWAP, and EMA9/20 alignment. A bullish 15m with a bearish 5m is a conflict — the script flags it and reduces signal quality automatically.
1-minute — the execution layer. EMA stack, VWAP relationship, candle quality, volume, and ADX all gate the final entry signal here.
All three must agree before a high-quality signal fires. When they don't, the script tells you to wait.

## Source Code

````pine
//@version=6
indicator("SPY / SPX Intraday Pro v31 [Signals + Mentor + SVP + Confluence]", overlay=true, max_bars_back=2000, max_lines_count=300, max_boxes_count=50, max_labels_count=300)

//=========================
// GROUPS
//=========================
groupTrend   = "Trend"
groupSetup   = "Signal Engine"
groupRisk    = "Risk / Trade Mgmt"
groupSession = "Session Filters"
groupVisual  = "Visuals"
groupMentor  = "Mentor"
groupSVP     = "Volume Profile (SVP)"   // NEW v30
groupConf    = "Confluence Scoring"      // NEW v31

//=========================
// INPUTS
//=========================
emaFastLen           = input.int(9,     "Fast EMA",                          group=groupTrend)
emaSlowLen           = input.int(20,    "Slow EMA",                          group=groupTrend)
atrLen               = input.int(14,    "ATR Length",                        group=groupRisk)
volLen               = input.int(50,    "Volume MA Length",                  group=groupRisk)

useVolumeFilter      = input.bool(true,  "Use Volume Confirmation",          group=groupSetup, tooltip="SPY/QQQ: normal. SPX index: no real volume — use SPY chart for volume logic or turn this off.")
volMult              = input.float(0.9,  "Min Volume vs Vol MA",             group=groupSetup, step=0.1)
useStrongVolumeBoost = input.bool(true,  "Use Volume Expansion For Strong",  group=groupSetup)
strongVolMult        = input.float(1.0,  "Strong Signal Volume Multiplier",  group=groupSetup, step=0.1)
useTrendFilter       = input.bool(true,  "Require EMA Trend Alignment",      group=groupSetup)
useReclaimSetup      = input.bool(true,  "Enable VWAP Reclaim Signals",      group=groupSetup)
usePullbackSetup     = input.bool(true,  "Enable Pullback Continuation",     group=groupSetup)
pullbackLookback     = input.int(2,      "Pullback Lookback Bars",           group=groupSetup, minval=1)
maxExtendATR         = input.float(0.7,  "Max Extension from EMA9 (ATR)",    group=groupSetup, step=0.1)
minBodyPct           = input.float(0.45, "Min Candle Body % (WATCH / resume)", group=groupSetup, step=0.05, tooltip="Used for pullback-style context. WATCH uses this threshold.")
entryMinBodyPct      = input.float(0.52, "Min body % for ENTER only",          group=groupSetup, step=0.05, tooltip="Stricter candle quality on ENTER bars (reclaim, pullback path, momentum). WATCH unchanged.")
useChopFilter        = input.bool(true,  "Avoid Near-VWAP Chop",             group=groupSetup)
chopATRMult          = input.float(0.20, "Chop Threshold ATR",               group=groupSetup, step=0.05)
vwapReclaimBars      = input.int(3,      "VWAP Reclaim Window (1m bars)",    group=groupSetup, minval=1, maxval=8, tooltip="After price crosses VWAP, reclaim setup stays valid for N bars (strict = 1). Reduces missed signals on fast 1m charts.")
useORBBreakoutSig    = input.bool(true,  "ORB Breakout / Breakdown Signals", group=groupSetup, tooltip="Adds longs on first close above ORB high (after OR locks) and shorts below ORB low, with same HTF + trigger filters as VWAP reclaim.")
useSignalRSIBlock    = input.bool(true, "Block RSI Extremes (no chase)",   group=groupSetup, tooltip="If on: blocks based on RSI extremes. You can apply it to ALL entries or only to STRONG labels.")
rsiBlockMode         = input.string("Strong only", "RSI block applies to", group=groupSetup, options=["All entries","Strong only"], tooltip="All entries = no CALLS when RSI>78 and no PUTS when RSI<22. Strong only = normal CALLS/PUTS can still print, but won't be labeled STRONG when RSI is extreme.")
regimeTrendADX       = input.int(22,     "Regime: ADX ≥ TREND",              group=groupSetup, minval=12, maxval=40)
regimeAvoidADX       = input.int(14,     "Regime: ADX < AVOID (5m mixed)",   group=groupSetup, minval=8,  maxval=25, tooltip="When ADX is below this and 5m structure is mixed, regime = AVOID (no entries / watch).")
orbRegimeTrendOnly   = input.bool(false, "ORB path only in TREND regime",    group=groupSetup, tooltip="ON = ORB ENTER only when Regime=TREND (most SPY days are RANGE → ORB never fired). OFF = ORB can ENTER in RANGE too.")
signalMinADX         = input.int(15,     "Min ADX (1m) threshold",             group=groupSetup, minval=0, maxval=30, tooltip="0 = off for that use. WATCH uses this only if 'Use Min ADX on WATCH' is on (default on). ENTER uses it only if 'Use ADX gate on ENTER' is on.")
useADXGateForEntry   = input.bool(false, "Use ADX gate on ENTER",            group=groupSetup, tooltip="OFF (default): ENTER ignores Min ADX. WATCH uses Min ADX only if 'Use Min ADX on WATCH' is on.")
useMinADXForWatch    = input.bool(true,  "Use Min ADX (1m) on WATCH",         group=groupSetup, tooltip="On (default): WATCH must clear Min ADX (1m). Off: WATCH can show with low 1m ADX (early context).")
require15mTrendForEntry = input.bool(true,  "Strict 15m trend for ENTER",    group=groupSetup, tooltip="On (default): ENTER requires 15m BULL for calls and 15m BEAR for puts. Off: long unless 15m BEAR; short unless 15m BULL (neutral 15m can still enter).")
strict1mEmaForEntry  = input.bool(true,  "Strict 1m EMA stack for ENTER",    group=groupSetup, tooltip="On (default): same as 'Require EMA Trend Alignment' for entries. Off: only need close on right side of VWAP for entry trend leg.")
requireVolumeForWatch = input.bool(false, "Require volume for WATCH only",   group=groupSetup, tooltip="Off (default): WATCH LONG/SHORT can show when volume is WEAK. ENTER signals still require volume if Use Volume Confirmation is on.")
require5mAlignForWatch = input.bool(false, "Require 5m aligned for WATCH",   group=groupSetup, tooltip="Off (default): long WATCH can show when 5m is BEAR (and short WATCH when 5m BULL) for early context. On: same 5m filter as before.")
require1mEmaStackForWatch = input.bool(false, "Require 1m EMA stack for WATCH", group=groupSetup, tooltip="Off (default): long WATCH needs 15m bull + close above VWAP; 1m EMA9>EMA20 optional. On: strict 1m bull/bear stack for WATCH.")
relaxTriggerWithORB  = input.bool(true,  "Soften 1m EMA trigger when ORB fires", group=groupSetup, tooltip="ORB break bars often fail EMA9>EMA20 on 1m; this allows ENTER when ORB breaks and close is on the right side of VWAP.")
useChopFilterForEntry = input.bool(false, "Apply chop filter to ENTER",      group=groupSetup, tooltip="Off (default): near-VWAP chop filter still affects WATCH but not ENTER — pumps/dumps through VWAP can register.")
requireVolumeForEntry = input.bool(true,  "Require volume on ENTER",          group=groupSetup, tooltip="On (default): ENTER needs volume ≥ Min Volume vs Vol MA when Use Volume Confirmation is on. Off: weak-volume ENTER allowed. SPX: turn off volume confirmation or disable this. Only one stricter default is on by default (this one).")
ignore5mStructureForEntry = input.bool(false, "Ignore 5m BULL/BEAR block on ENTER", group=groupSetup, tooltip="Off (default): block long ENTER when 5m is BEAR and short ENTER when 5m is BULL. On: ENTER may ignore 5m structure (more signals, more counter-5m entries).")
useMomentumEntry     = input.bool(false, "Momentum ENTER (no VWAP cross / ORB)", group=groupSetup, tooltip="Off (default): ENTER only from VWAP reclaim, ORB, or pullback — no momentum-only path. On: extra ENTER when HTF aligned above/below VWAP with bull/bear candle (no cross/ORB required); noisier but catches pumps/dumps that skip reclaim/ORB.")
stopATRMult          = input.float(1.0,  "Initial Stop ATR Multiplier",      group=groupRisk, step=0.1)
signalStopPureWick   = input.bool(false, "Initial SL: pure signal-bar wick only", group=groupRisk, tooltip="OFF (default): stop = tighter of signal bar wick vs ATR distance from close (tiny wicks still get at least ATR×Initial Stop Mult). ON: stop = bar low (calls) / bar high (puts) only — no ATR floor.")
swingLookback        = input.int(4,      "Swing Lookback For Exit",          group=groupRisk, minval=2)
softExitMinBars      = input.int(3,      "Min bars before soft exit",        group=groupRisk, minval=0, maxval=30, tooltip="Soft exit = 2 of: close below entry-bar low, below EMA9, below VWAP (calls; mirrored for puts). 0 = legacy (can fire next bar). Higher values reduce whipsaw EXIT X right after ENTER; stop/swing exit still applies from bar 1.")
delayEma20TrailBars  = input.int(3,      "Delay EMA20 trail (bars)",         group=groupRisk, minval=0, maxval=20, tooltip="Prevents immediate stop-outs: for the first N bars after an ENTER, the stop will NOT ratchet up/down to EMA20. 0 = no delay (legacy behavior).")
targetATR1           = input.float(1.0,  "Target 1 ATR Fallback",            group=groupRisk, step=0.1)
targetATR2           = input.float(1.8,  "Target 2 ATR Fallback",            group=groupRisk, step=0.1)
targetATR3           = input.float(2.8,  "Target 3 ATR Fallback",            group=groupRisk, step=0.1)
confirmOnClose       = input.bool(true,  "Confirm on Bar Close",             group=groupSession)
showVWAP             = input.bool(true,  "Show VWAP",                        group=groupVisual)
showEMA20            = input.bool(true,  "Show EMA20",                       group=groupVisual)
showEMA9             = input.bool(false, "Show EMA9",                        group=groupVisual)
vwapPlotColor        = input.color(color.aqua,  "VWAP color",                  group=groupVisual)
ema9PlotColor        = input.color(color.green, "EMA9 color",                group=groupVisual)
ema20PlotColor       = input.color(color.white, "EMA20 color",                 group=groupVisual)
showSignalBg         = input.bool(false, "Show Signal Background",           group=groupVisual)
showDashboard        = input.bool(true,  "Show Dashboard",                   group=groupVisual)
dashboardSize        = input.string("normal", "Dashboard Size",              group=groupVisual, options=["small","normal","large"])
dashBgTransparency   = input.int(85, "Dashboard transparency",           group=groupVisual, minval=0, maxval=95, tooltip="Higher = more transparent (shows more chart through the tables). 0 = mostly opaque.")
dashTableBg          = color.new(color.black, dashBgTransparency)
dashTableBorder      = color.new(color.gray, math.min(95, dashBgTransparency + 6))
dashKeyTextColor     = input.color(color.white, "Dashboard key labels color", group=groupVisual, tooltip="Left-column labels (e.g., VWAP, MY TRADE, T1). Set to black for light charts, white for dark charts.")

// v30 SVP visuals
showSVPLevels        = input.bool(true,  "Show VAH / POC / VAL lines",        group=groupVisual, tooltip="Plots horizontal rays for the developing session volume profile (POC = magnet, VAH/VAL = 70% value area edges).")
svpVAHPlotColor      = input.color(color.new(color.fuchsia, 20), "VAH color", group=groupVisual)
svpPOCPlotColor      = input.color(color.new(color.yellow,  10), "POC color", group=groupVisual)
svpVALPlotColor      = input.color(color.new(color.aqua,    20), "VAL color", group=groupVisual)

orbMinutes           = input.int(15,     "Opening Range Minutes",            group=groupMentor, minval=5, maxval=30)
mentorSwingLen       = input.int(20,     "Mentor Swing Lookback",            group=groupMentor, minval=5, maxval=100)
useHalfDollarLevels  = input.bool(true,  "Use Half-Dollar Levels",           group=groupMentor)
showMentorStopT1     = input.bool(true,  "Plot mentor Stop + T1–T3 on chart",   group=groupMentor, tooltip="Horizontal rays (extend right) while MY TRADE / mentor leg is active. Uses line objects so levels stay flat when they update. Turn off to hide.")
mentorStopRayColor   = input.color(color.red,  "Mentor Stop ray color", group=groupMentor)
mentorT1RayColor     = input.color(color.lime, "Mentor T1 ray color",   group=groupMentor)
mentorT2RayColor     = input.color(color.lime, "Mentor T2 ray color",   group=groupMentor)
mentorT3RayColor     = input.color(color.lime, "Mentor T3 ray color",   group=groupMentor)
strongTrendADX       = input.float(25.0, "Strong Trend ADX",                 group=groupMentor, step=0.5)
mentorBufferBars     = input.int(5,      "Mentor Buffer Bars",               group=groupMentor, minval=1, maxval=10)
mentorHardFailATR    = input.float(0.8,  "Mentor Hard Fail ATR",             group=groupMentor, step=0.1)
mentorMinTargetATR   = input.float(0.15, "Min Target Distance ATR",          group=groupMentor, step=0.05)
mentorStopCushionATR = input.float(0.10, "Entry Stop Cushion (ATR)",         group=groupMentor, step=0.02, tooltip="Before T1: stop beyond entry by at least this ATR plus tick cushion.")
mentorMinStopTicks   = input.int(20,      "Entry Stop Min Ticks",             group=groupMentor, minval=5, maxval=200, tooltip="Minimum distance entry→stop in ticks (SPY 0.01 tick → 20 = $0.20).")
mentorTargetFloorATR = input.float(0.22, "Min T1 Distance Floor (ATR)",       group=groupMentor, step=0.02, tooltip="ATR-based floor for first target; use with Min Target $ below.")
mentorTargetMinUSD   = input.float(0.20, "Min Target Distance ($)",           group=groupMentor, step=0.05, tooltip="Absolute minimum $ from entry to T1 direction (stops 6¢ T1 when ATR is tiny on 1m).")
showMentorDebug      = input.bool(false, "Mentor Debug (BE / Trail Hit)",    group=groupMentor)
usePrev15OrbStop     = input.bool(true,  "Stop: prev 15m wick (locked at entry)", group=groupMentor, tooltip="CALLS: initial stop = prior completed 15m LOW wick (RTH) at the moment the call fires. PUTS: prior completed 15m HIGH wick. If invalid vs entry, falls back to ATR stop.")
useFib1hTargets      = input.bool(true,  "Targets: auto Fib (T1–T3)",        group=groupMentor, tooltip="ON: T1–T3 from swing range on the Fib PT timeframe (5m/10m/15m/1h, RTH). OFF: legacy ORB/level targets. Falls back if Fib invalid.")
fibPtTimeframe       = input.string("Auto", "Fib PT timeframe",               group=groupMentor, options=["Auto", "5m", "10m", "15m", "1h"], tooltip="Auto (recommended) picks by chart TF: 1m chart → 10m, 3m → 15m, 5m → 15m, 15m → 1h. Manual overrides. 1h on a 1m chart can produce absurdly wide targets (especially on SPX) — use Auto unless you know why.")
fibSwingLookback     = input.int(24,     "Fib swing window (bars)",          group=groupMentor, minval=3, maxval=200, tooltip="Bars on the selected Fib timeframe (e.g. 24×1h vs 24×15m are different clock time).")
fibMaxT1ATR          = input.float(3.0,  "Fib T1 max distance (ATR)",        group=groupMentor, step=0.5, minval=1.0, maxval=10.0, tooltip="Safety cap: if Fib target engine produces a T1 more than this × ATR from entry, reject Fib and fall back to ORB/PDH/swing levels. Prevents 50-point T1s on small intraday moves (especially on SPX where 1h swings are huge).")

// v30 SVP engine inputs
useSVP               = input.bool(true, "Enable Session Volume Profile", group=groupSVP, tooltip="Computes VAH/POC/VAL from RTH session volume. Used by mentor BIAS, target engine, and optional chart lines.")
svpBins              = input.int(60, "SVP bins (price resolution)", group=groupSVP, minval=20, maxval=120, tooltip="More bins = tighter price granularity, higher compute. 60 bins across a 2%-of-open range on SPY ≈ 20c resolution.")
svpRangePct          = input.float(2.0, "SVP range from open (%)", group=groupSVP, step=0.5, minval=1.0, maxval=5.0, tooltip="Pre-allocated profile range centered on today's open. 2%% on SPY ≈ ±$14. Volume outside the range lands in edge bins (rare on normal days).")
svpValueAreaPct      = input.float(70.0, "Value area % (VAH/VAL)", group=groupSVP, step=1.0, minval=50.0, maxval=90.0, tooltip="Standard = 70 (matches TradingView and market profile convention). Do not change unless you know why.")
svpNearATR           = input.float(0.5, "Level proximity threshold (ATR)", group=groupSVP, step=0.1, minval=0.1, maxval=2.0, tooltip="Used by mentor BIAS to detect when entry is INTO or FROM a level (VAH/POC/VAL). Smaller = stricter 'near' definition.")
svpMinBarsForValid   = input.int(30, "Min RTH minutes before SVP valid", group=groupSVP, minval=10, maxval=120, tooltip="Early-session POC is unstable; mentor/targets ignore SVP until this many MINUTES of RTH data have elapsed since 9:30 ET. Works consistently across 1m/3m/5m/15m charts. Default 30 = ~10:00 ET.")
svpUseForTargets     = input.bool(true, "Use VAH/POC/VAL in target engine", group=groupSVP, tooltip="Adds VAH/POC/VAL as target candidates in the mentor (alongside ORB/PDH/PDL/swings). Often produces more realistic T1/T2 than round numbers.")
svpUseForBias        = input.bool(true, "Use VAH/POC/VAL in mentor BIAS", group=groupSVP, tooltip="Extends BIAS field with 'CALL INTO VAH', 'CALL FROM VAL', 'PUT INTO POC', etc. Overrides ORB/PDH/DH notes when SVP level is closer.")

// v31 Confluence scoring inputs
useConfluenceGate    = input.bool(true,  "Gate ENTER by confluence score", group=groupConf, tooltip="ON (default): ENTER signals must clear the min score to fire. OFF: legacy v30 behavior — every raw ENTER fires. BOUNCE/REJECT paths are never gated by score (they have their own strict filters).")
scoreFireMin         = input.float(5.0,  "Min score to fire (CALLS/PUTS)", group=groupConf, step=0.5, minval=0.0, maxval=10.0, tooltip="Entries below this are blocked. 5.0 on a 10-point scale keeps roughly the better half of setups. Raise to 6 for fewer/cleaner signals; lower to 4 for more signals.")
scoreStrongMin       = input.float(7.0,  "Min score for STRONG label",    group=groupConf, step=0.5, minval=0.0, maxval=10.0, tooltip="ENTER at or above this shows as STRONG CALLS / STRONG PUTS on the chart. Below = regular CALLS / PUTS. 7 = top ~25% of setups.")
showConfluenceDebug  = input.bool(false, "Show live score on dashboard",   group=groupConf, tooltip="Adds a QUALITY row to the top dashboard showing current CALL/PUT score live (before any entry fires). Helpful while learning how the score reacts to market conditions.")
// Weight tuning (advanced — keep defaults unless you know why you're changing them)
wtHTF15m             = input.float(2.0,  "Weight: 15m HTF aligned",       group=groupConf, step=0.5, minval=0.0, maxval=3.0)
wt5mStruct           = input.float(1.5,  "Weight: 5m structure aligned",  group=groupConf, step=0.5, minval=0.0, maxval=3.0)
wtVolStrong          = input.float(1.5,  "Weight: Volume ≥ Strong mult",  group=groupConf, step=0.5, minval=0.0, maxval=3.0)
wtADXStrong          = input.float(1.0,  "Weight: ADX ≥ 20",              group=groupConf, step=0.5, minval=0.0, maxval=3.0)
wtRSISweet           = input.float(1.0,  "Weight: RSI in sweet spot",     group=groupConf, step=0.5, minval=0.0, maxval=3.0, tooltip="Calls: 40–68. Puts: 32–60. Excludes weak and overextended RSI readings.")
wtEMA20Side          = input.float(0.5,  "Weight: Close past EMA20",      group=groupConf, step=0.5, minval=0.0, maxval=2.0)
wtSVPLocGood         = input.float(2.0,  "Weight: SVP 'FROM' level (bonus)", group=groupConf, step=0.5, minval=0.0, maxval=3.0, tooltip="Calls: entry near VAL (support). Puts: entry near VAH (resistance). Best-case location.")
wtSVPLocBad          = input.float(2.0,  "Weight: SVP 'INTO' level (penalty)", group=groupConf, step=0.5, minval=0.0, maxval=3.0, tooltip="Calls: wall (VAH) or magnet (POC) just above. Puts: wall (VAL) or magnet (POC) just below. Subtracted from score.")
wtPathQuality        = input.float(1.0,  "Weight: Path is RECLAIM/ORB",   group=groupConf, step=0.5, minval=0.0, maxval=2.0, tooltip="Highest-quality paths get full weight. PULLBACK = half. MOMENTUM/BOUNCE = 0.")
wtSessionTiming      = input.float(0.5,  "Weight: Session timing",        group=groupConf, step=0.5, minval=0.0, maxval=2.0, tooltip="+0.5 during PRIME (9:35–11:00). -0.5 during LUNCH or POWER HOUR.")
wtDirectionalVol     = input.float(0.5,  "Weight: Directional volume",    group=groupConf, step=0.5, minval=0.0, maxval=2.0, tooltip="Big up bar on calls / big down bar on puts (volume > 1.5× MA + price in direction).")

//=========================
// MENTOR LEG FROM CHART (no manual input): last CALLS/PUTS ENTER → label uses signal bar close (mintick string, not whole-dollar round)
//=========================
var float mentorEntryLocked = na
var int   autoMentorState   = 0     // 0 = none, 1 = call, -1 = put (chart-driven)
var float autoStrikeStored  = na    // signal bar close (underlying reference price)

//=========================
// CORE VALUES
//=========================
vwapVal      = ta.vwap(hlc3)
ema9         = ta.ema(close, emaFastLen)
ema20        = ta.ema(close, emaSlowLen)
atrVal       = ta.atr(atrLen)
volMA        = ta.sma(volume, volLen)
confirmedBar = not confirmOnClose or barstate.isconfirmed

candleRange  = high - low
candleBody   = math.abs(close - open)
bodyPct      = candleRange > 0 ? candleBody / candleRange : 0.0

aboveVWAP    = close > vwapVal
belowVWAP    = close < vwapVal
bullTrend    = ema9 > ema20
bearTrend    = ema9 < ema20

volOk        = not useVolumeFilter      or volume >= volMA * volMult
strongVolOk  = not useStrongVolumeBoost or volume >= volMA * strongVolMult
nearVWAP     = math.abs(close - vwapVal) <= atrVal * chopATRMult
chopBlocked  = useChopFilter and nearVWAP

rsiVal       = ta.rsi(close, 14)
[diPlus, diMinus, adxVal] = ta.dmi(14, 14)
adxState     = adxVal < 15 ? "Chop" : adxVal < 25 ? "Moderate" : adxVal < 40 ? "Strong" : "Very Strong"
rsiState     = rsiVal >= 70 ? "Overbought" : rsiVal <= 30 ? "Oversold" : rsiVal > 50 ? "Bullish" : "Bearish"
dashTextSize = dashboardSize == "small" ? size.small : dashboardSize == "normal" ? size.normal : size.large

volumeState  = strongVolOk ? "STRONG" : volOk ? "NORMAL" : "WEAK"
volumeColor  = strongVolOk ? color.lime : volOk ? color.green : color.orange
volVsMaRatio = na(volMA) or volMA <= 0 ? na : volume / volMA
volumeDashStr = na(volVsMaRatio) ? volumeState : str.tostring(math.round(volVsMaRatio * 100) / 100) + "× · " + volumeState

//=========================
// SESSION
//=========================
currHourET      = hour(time, "America/New_York")
currMinET       = minute(time, "America/New_York")
currDayET       = dayofmonth(time, "America/New_York")
currMonthET     = month(time, "America/New_York")
currYearET      = year(time, "America/New_York")
inLunch         = (currHourET == 11 and currMinET >= 30) or currHourET == 12
// Build RTH session boundary using the *ET calendar date* (not the chart’s local date),
// otherwise TDH/TDL can fail to reset correctly on some timezone / replay combinations.
sessionOpen     = timestamp("America/New_York", currYearET, currMonthET, currDayET, 9, 30, 0)
minutesFromOpen = math.floor((time - sessionOpen) / 60000)
isMarketHours   = time >= sessionOpen and time <= sessionOpen + 390 * 60 * 1000
// No intraday time windows block signals (open / lunch / cutoff removed). ORB still uses isMarketHours above.
sessionAllowed  = true

newETDay = currDayET != currDayET[1] or currMonthET != currMonthET[1] or currYearET != currYearET[1]

isPrimeWindow   = currHourET >= 9 and currHourET < 11 and not (currHourET == 9 and currMinET < 35)
isLunchWindow   = inLunch
isAfternoon     = currHourET >= 13 and (currHourET < 14 or (currHourET == 14 and currMinET < 30))
isPowerHour     = currHourET >= 14 and currHourET < 16

timeWarning =
     isPowerHour   ? "LAST HOUR RTH (ET 15:00–16:00) — EXIT FAST" :
     isLunchWindow ? "LUNCH (ET 11:30–13:00) — TIGHTEN UP" :
     isAfternoon   ? "AFTERNOON (ET) — MODERATE"   :
     isPrimeWindow ? "PRIME (ET open–11:00)"            :
     "OFF HOURS / PREPOST (ET)"

timeWarningColor =
     isPowerHour   ? color.orange :
     isLunchWindow ? color.yellow :
     isAfternoon   ? color.yellow :
     isPrimeWindow ? color.lime   :
     color.gray

etMinPadded = currMinET < 10 ? "0" + str.tostring(currMinET) : str.tostring(currMinET)
sessionClockET = str.tostring(currHourET) + ":" + etMinPadded + " ET"
sessionLineMentor = timeWarning + " · " + sessionClockET

//=========================
// OPENING RANGE + DAY LEVELS
//=========================
var float orbHigh   = na
var float orbLow    = na
var bool  orbLocked = false

if newETDay
    orbHigh   := na
    orbLow    := na
    orbLocked := false

inORBWindow = isMarketHours and minutesFromOpen >= 0 and minutesFromOpen < orbMinutes

if inORBWindow
    orbHigh := na(orbHigh) ? high : math.max(orbHigh, high)
    orbLow  := na(orbLow)  ? low  : math.min(orbLow,  low)

if not orbLocked and not inORBWindow and minutesFromOpen >= orbMinutes
    orbLocked := true

orbMid = not na(orbHigh) and not na(orbLow) ? (orbHigh + orbLow) / 2.0 : na

// Evaluate every bar (Pine: ta.cross* must not sit inside lazy `and` chains only)
orbCrossUp = ta.crossover(close, orbHigh)
orbCrossDn = ta.crossunder(close, orbLow)
orbBreakLong  = useORBBreakoutSig and orbLocked and not na(orbHigh) and isMarketHours and orbCrossUp
orbBreakShort = useORBBreakoutSig and orbLocked and not na(orbLow)  and isMarketHours and orbCrossDn

// Use regular-session (RTH) daily bars so PDH/PDL match what traders see on RTH charts,
// regardless of the user's local timezone or whether extended hours are enabled on the intraday chart.
rthTicker = ticker.new(syminfo.prefix, syminfo.ticker, session.regular)
prevHigh  = request.security(rthTicker, "D", high[1],  lookahead=barmerge.lookahead_off)
prevLow   = request.security(rthTicker, "D", low[1],   lookahead=barmerge.lookahead_off)
prevClose = request.security(rthTicker, "D", close[1], lookahead=barmerge.lookahead_off)
// NOTE: With lookahead_off on daily TF, this returns the *previous completed* daily bar's open (i.e. yesterday's),
// not today's open. Used only as a reference level in the target engine; do NOT use for SVP anchor (SVP uses 1m `open` at 9:30 ET).
prevDayOpen = request.security(rthTicker, "D", open,     lookahead=barmerge.lookahead_off)

var float dayHigh = na
var float dayLow  = na
var int   dayStartMs = na
// newRTHSession: first 1m bar of today's RTH session. Uses ET day change as a secondary trigger so the flag
// still fires on RTH-only charts (where bars jump 15:59 → 9:30 with no ETH bars in between and `not isMarketHours[1]` stays false).
newRTHSession = isMarketHours and (not isMarketHours[1] or currDayET != currDayET[1])
// Reset on every new ET day so TDH/TDL don't get "stuck" when the chart loads mid-session
// (common when switching to higher timeframes with fewer loaded bars).
if newETDay
    dayStartMs := sessionOpen
    dayHigh := na
    dayLow  := na
if newRTHSession
    dayStartMs := sessionOpen
    dayHigh := high
    dayLow  := low
else if isMarketHours
    if na(dayStartMs)
        dayStartMs := sessionOpen
    dayHigh := na(dayHigh) ? high : math.max(dayHigh, high)
    dayLow  := na(dayLow)  ? low  : math.min(dayLow,  low)

recentSwingHigh = ta.highest(high, mentorSwingLen)
recentSwingLow  = ta.lowest(low,   mentorSwingLen)

//=========================
// v30 SESSION VOLUME PROFILE (SVP) — POC / VAH / VAL
// Pre-allocated range around today's open, fixed bin width.
// Each RTH 1m bar adds its volume to the bin containing hlc3.
// POC = max-volume bin. VAH/VAL = edges of bins accumulating (svpValueAreaPct)% of total session volume, expanded outward from POC.
// Reset on new ET day. Mentor + target engine only read POC/VAH/VAL after svpMinBarsForValid bars of RTH data.
//=========================
var float[] svpVolumes   = array.new_float(svpBins, 0.0)
var float   svpRangeTop  = na
var float   svpRangeBot  = na
var float   svpBinSize   = na
var int     svpBarCount  = 0
var float   pocPrice     = na
var float   vahPrice     = na
var float   valPrice     = na

// Reset profile on the first 1m bar of each RTH session (at 9:30 ET `open` IS today's actual RTH open — no `request.security` stale-daily-bar issues).
// Fallback: if chart loads mid-session and SVP was never initialized, anchor on the midpoint of the day's observed RTH range so
// today's prices land somewhere inside the pre-allocated bin window instead of clipping to one edge.
needsSvpInit = useSVP and (newRTHSession or (isMarketHours and na(svpBinSize)))
if needsSvpInit
    for i = 0 to svpBins - 1
        array.set(svpVolumes, i, 0.0)
    float anchor = close
    if newRTHSession
        anchor := open
    else if not na(dayHigh) and not na(dayLow)
        anchor := (dayHigh + dayLow) / 2.0
    svpRangeTop := anchor * (1.0 + svpRangePct / 100.0)
    svpRangeBot := anchor * (1.0 - svpRangePct / 100.0)
    svpBinSize  := (svpRangeTop - svpRangeBot) / svpBins
    svpBarCount := 0
    pocPrice    := na
    vahPrice    := na
    valPrice    := na

// Also clear at end of RTH so tomorrow's new session re-triggers cleanly even if ETH bars kept svpBinSize non-na.
if not isMarketHours and isMarketHours[1]
    svpBinSize := na

// Accumulate this bar's volume into the bin containing hlc3 (only inside RTH, only when SVP enabled).
if useSVP and isMarketHours and not na(svpBinSize) and svpBinSize > 0
    float tp  = hlc3
    int   idx = int(math.floor((tp - svpRangeBot) / svpBinSize))
    idx := math.max(0, math.min(svpBins - 1, idx))
    array.set(svpVolumes, idx, array.get(svpVolumes, idx) + volume)
    svpBarCount += 1

// Recompute POC / VAH / VAL each RTH bar after enough data has accumulated.
// v31: Validity is now *time-based* (minutes from RTH open) rather than bar-based, so it behaves sensibly on 3m/5m/15m charts
// as well as 1m. Default 30 min ≈ 10:00 ET. Old `svpMinBarsForValid` input is reinterpreted as "minutes of RTH data required."
svpMinutesValid = svpMinBarsForValid  // reuse the existing input; treat its value as minutes now
svpValid = useSVP and isMarketHours and minutesFromOpen >= svpMinutesValid and not na(svpBinSize) and svpBinSize > 0 and svpBarCount > 0

if svpValid
    float maxVol   = 0.0
    int   pocIdx   = 0
    float totalVol = 0.0
    for i = 0 to svpBins - 1
        float v = array.get(svpVolumes, i)
        totalVol += v
        if v > maxVol
            maxVol := v
            pocIdx := i

    if totalVol > 0
        pocPrice := svpRangeBot + (pocIdx + 0.5) * svpBinSize

        // Expand value area outward from POC until cumulative >= (svpValueAreaPct)% of total.
        float target = totalVol * (svpValueAreaPct / 100.0)
        float cum    = maxVol
        int   upIdx  = pocIdx + 1
        int   dnIdx  = pocIdx - 1
        int   lastUp = pocIdx
        int   lastDn = pocIdx
        int   safety = svpBins * 2

        while cum < target and (upIdx < svpBins or dnIdx >= 0) and safety > 0
            float vUp = upIdx < svpBins ? array.get(svpVolumes, upIdx) : -1.0
            float vDn = dnIdx >= 0      ? array.get(svpVolumes, dnIdx) : -1.0
            if vUp >= vDn and upIdx < svpBins
                cum    += vUp
                lastUp := upIdx
                upIdx  += 1
            else if dnIdx >= 0
                cum    += vDn
                lastDn := dnIdx
                dnIdx  -= 1
            safety -= 1

        // VAH = top edge of highest included bin; VAL = bottom edge of lowest included bin.
        vahPrice := svpRangeBot + (lastUp + 1) * svpBinSize
        valPrice := svpRangeBot + lastDn       * svpBinSize

// After RTH close, levels stay at their session-final values until the next new ET day resets them (matches TradingView's locked SVP).

//=========================
// 15m TREND
//=========================
close15   = request.security(syminfo.tickerid, "15", close,         lookahead=barmerge.lookahead_off)
vwap15    = request.security(syminfo.tickerid, "15", ta.vwap(hlc3), lookahead=barmerge.lookahead_off)
trendBull = close15 > vwap15
trendBear = close15 < vwap15

// Prior *completed* 15m bar (RTH) — combined with ORB for mentor initial stop
prev15Low  = request.security(rthTicker, "15", low[1],  lookahead=barmerge.lookahead_off)
prev15High = request.security(rthTicker, "15", high[1], lookahead=barmerge.lookahead_off)
prev15Close = request.security(rthTicker, "15", close[1], lookahead=barmerge.lookahead_off)
prev15Close2 = request.security(rthTicker, "15", close[2], lookahead=barmerge.lookahead_off)

// Swing from 5m/10m/15m/1h OHLC (toggle); Pine needs const TF per security() call, so we pull each and select.
[fib5High, fib5Low]   = request.security(rthTicker, "5",  [ta.highest(high, fibSwingLookback), ta.lowest(low, fibSwingLookback)], lookahead=barmerge.lookahead_off)
[fib10High, fib10Low] = request.security(rthTicker, "10", [ta.highest(high, fibSwingLookback), ta.lowest(low, fibSwingLookback)], lookahead=barmerge.lookahead_off)
[fib15High, fib15Low] = request.security(rthTicker, "15", [ta.highest(high, fibSwingLookback), ta.lowest(low, fibSwingLookback)], lookahead=barmerge.lookahead_off)
[fib60High, fib60Low] = request.security(rthTicker, "60", [ta.highest(high, fibSwingLookback), ta.lowest(low, fibSwingLookback)], lookahead=barmerge.lookahead_off)
// v31: resolve "Auto" Fib timeframe based on current chart TF. Keeps swing range proportional to chart — prevents 1h swings (50+ pts on SPX) being used as Fib base on a 1m chart.
int chartMin = timeframe.in_seconds(timeframe.period) / 60
string fibTfResolved = fibPtTimeframe
if fibPtTimeframe == "Auto"
    if chartMin <= 1
        fibTfResolved := "10m"
    else if chartMin <= 3
        fibTfResolved := "15m"
    else if chartMin <= 5
        fibTfResolved := "15m"
    else
        fibTfResolved := "1h"

fibSwingHigh =
     fibTfResolved == "5m"  ? fib5High  :
     fibTfResolved == "10m" ? fib10High :
     fibTfResolved == "15m" ? fib15High :
     fib60High
fibSwingLow =
     fibTfResolved == "5m"  ? fib5Low  :
     fibTfResolved == "10m" ? fib10Low :
     fibTfResolved == "15m" ? fib15Low :
     fib60Low
fibSwingRange = not na(fibSwingHigh) and not na(fibSwingLow) ? fibSwingHigh - fibSwingLow : float(na)

//=========================
// 5m STRUCTURE
//=========================
close5         = request.security(syminfo.tickerid, "5", close,                     lookahead=barmerge.lookahead_off)
vwap5          = request.security(syminfo.tickerid, "5", ta.vwap(hlc3),             lookahead=barmerge.lookahead_off)
ema95          = request.security(syminfo.tickerid, "5", ta.ema(close, emaFastLen), lookahead=barmerge.lookahead_off)
ema205         = request.security(syminfo.tickerid, "5", ta.ema(close, emaSlowLen), lookahead=barmerge.lookahead_off)
structureBull  = close5 > vwap5 and ema95 > ema205
structureBear  = close5 < vwap5 and ema95 < ema205
structureMixed = not structureBull and not structureBear

//=========================
// v2: REGIME + BIAS + GATES (single source for mentor + dashboard)
//=========================
regimeAvoidIntraday = sessionAllowed and adxVal < regimeAvoidADX and structureMixed
regimeIsTrend       = sessionAllowed and not regimeAvoidIntraday and adxVal >= regimeTrendADX and (structureBull or structureBear)
regimeIsRange       = sessionAllowed and not regimeAvoidIntraday and not regimeIsTrend
regimeStr           = not sessionAllowed ? "AVOID" : regimeAvoidIntraday ? "AVOID" : regimeIsTrend ? "TREND" : "RANGE"
regimeColorDash     = regimeStr == "AVOID" ? color.red : regimeStr == "TREND" ? color.lime : color.yellow
signalSessionOk     = sessionAllowed and not regimeAvoidIntraday

bias15Str      = trendBull ? "15m BULL" : trendBear ? "15m BEAR" : "15m NEU"
bias5Str       = structureBull ? "5m BULL" : structureBear ? "5m BEAR" : "5m MIX"
biasAlignedLong  = trendBull and structureBull
biasAlignedShort = trendBear and structureBear
biasConflict     = (trendBull and structureBear) or (trendBear and structureBull)
biasAlignStr     = biasAlignedLong ? "ALN LONG" : biasAlignedShort ? "ALN SHORT" : biasConflict ? "CONFLICT" : "MIXED"

//=========================
// SETUP BUILDING BLOCKS
//=========================
trendLongOk  = not useTrendFilter or bullTrend
trendShortOk = not useTrendFilter or bearTrend

strongBullCandle = close > open and close > close[1] and bodyPct >= minBodyPct
strongBearCandle = close < open and close < close[1] and bodyPct >= minBodyPct
entryBodyLong    = close > open and close > close[1] and bodyPct >= entryMinBodyPct
entryBodyShort   = close < open and close < close[1] and bodyPct >= entryMinBodyPct

crossUpVWAP   = ta.crossover(close,  vwapVal)
crossDownVWAP = ta.crossunder(close, vwapVal)
barsSinceVwapUp = ta.barssince(crossUpVWAP)
barsSinceVwapDn = ta.barssince(crossDownVWAP)
reclaimLong   = aboveVWAP and close > ema9 and nz(barsSinceVwapUp, 999) < vwapReclaimBars
rejectShort   = belowVWAP and close < ema9 and nz(barsSinceVwapDn, 999) < vwapReclaimBars

pullbackTouchLong  = low  <= ema9 or low  <= ema20 or low  <= vwapVal
pullbackTouchShort = high >= ema9 or high >= ema20 or high >= vwapVal
recentPullbackLong  = ta.barssince(pullbackTouchLong)  <= pullbackLookback
recentPullbackShort = ta.barssince(pullbackTouchShort) <= pullbackLookback

notExtendedLong  = close <= ema9 + atrVal * maxExtendATR
notExtendedShort = close >= ema9 - atrVal * maxExtendATR

resumeLongCore  = aboveVWAP and recentPullbackLong  and notExtendedLong  and close > ema9
resumeShortCore = belowVWAP and recentPullbackShort and notExtendedShort and close < ema9
resumeLong      = resumeLongCore  and strongBullCandle
resumeShort     = resumeShortCore and strongBearCandle
resumeLongEnter = resumeLongCore  and entryBodyLong
resumeShortEnter = resumeShortCore and entryBodyShort

triggerLong  = close > ema9 and ema9 > ema20 and close > vwapVal
triggerShort = close < ema9 and ema9 < ema20 and close < vwapVal

rsiOkForLong_Strong  = not useSignalRSIBlock or rsiVal <= 78
rsiOkForShort_Strong = not useSignalRSIBlock or rsiVal >= 22
rsiOkForLong_Entry   = not useSignalRSIBlock or rsiBlockMode == "Strong only" or rsiVal <= 78
rsiOkForShort_Entry  = not useSignalRSIBlock or rsiBlockMode == "Strong only" or rsiVal >= 22

trigger_ok_long  = triggerLong
trigger_ok_short = triggerShort
vol_ok           = volOk
chop_ok          = not chopBlocked
volGateWatch     = requireVolumeForWatch ? vol_ok : true
// ENTRY volume behavior:
// - When useVolumeFilter + requireVolumeForEntry are both on: ENTER needs volume ≥ volMA * volMult.
// - STRONG label still requires strongVolOk separately (volume ≥ volMA * strongVolMult) via the confluence score.
volGateEntry     = requireVolumeForEntry ? vol_ok : true
chopGateEntry    = useChopFilterForEntry ? chop_ok : true
long5mEntryOk    = ignore5mStructureForEntry ? true : not structureBear
short5mEntryOk   = ignore5mStructureForEntry ? true : not structureBull
// ORB bars rarely satisfy full EMA stack on the same 1m bar
entryTriggerLong  = trigger_ok_long  or (relaxTriggerWithORB and orbBreakLong  and close > vwapVal)
entryTriggerShort = trigger_ok_short or (relaxTriggerWithORB and orbBreakShort and close < vwapVal)
// Entry-only HTF / 1m bias (WATCH unchanged)
entryTrendBull15  = require15mTrendForEntry ? trendBull : not trendBear
entryTrendBear15  = require15mTrendForEntry ? trendBear : not trendBull
entryTrendLong1m  = strict1mEmaForEntry ? trendLongOk : (not useTrendFilter or bullTrend or close > vwapVal)
entryTrendShort1m = strict1mEmaForEntry ? trendShortOk : (not useTrendFilter or bearTrend or close < vwapVal)
adxGateEntry      = useADXGateForEntry and signalMinADX > 0 ? adxVal >= signalMinADX : true

pathTagFromSetup(st) =>
    switch st
        "VWAP_RECLAIM" => "RECLAIM"
        "ORB_BREAK"    => "ORB"
        "PULLBACK"     => "PULLBACK"
        "MOMENTUM"     => "MOMENTUM"
        "BOUNCE"       => "BOUNCE"
        "REJECTION"    => "REJECT"
        "LONG_CONTEXT" => "LONG"
        "SHORT_CONTEXT"=> "SHORT"
        => "--"

//=========================
// v31 CONFLUENCE SCORING ENGINE
// Computes 0-10 quality score for CALLS and PUTS every bar from current market state.
// Used to (a) gate ENTER signals below scoreFireMin, and (b) decide STRONG vs normal label.
// BOUNCE and REJECT paths bypass the gate (they already have their own strict filters).
//
// Scoring rubric (mirrors between calls/puts):
//   HTF 15m aligned           +2.0
//   5m structure aligned      +1.5
//   Volume ≥ Strong mult      +1.5
//   ADX ≥ 20                  +1.0
//   RSI in sweet spot         +1.0   (calls 40–68, puts 32–60)
//   Close past EMA20          +0.5
//   SVP FROM level (support)  +2.0   (calls near VAL, puts near VAH)
//   SVP INTO level (wall)     -2.0   (calls near VAH or POC above, puts near VAL or POC below)
//   Path = RECLAIM or ORB     +1.0   (PULLBACK = +0.5, else 0)
//   Session timing            +0.5 prime, -0.5 lunch/power
//   Directional volume        +0.5   (volForCall / volForPut)
// Max typical = ~10. Capped at 10 for display. Can go negative on bad setups.
//=========================
// Near-level proximity reused from SVP config
float confSvpNearDist = atrVal * svpNearATR
bool  confSvpCtx      = svpValid and not na(confSvpNearDist)

// Calls: FROM VAL (good), INTO VAH / INTO POC (bad)
bool confCallFromVal = confSvpCtx and not na(valPrice) and close > valPrice and (close - valPrice) <= confSvpNearDist
bool confCallIntoVah = confSvpCtx and not na(vahPrice) and vahPrice > close and (vahPrice - close) <= confSvpNearDist
bool confCallIntoPoc = confSvpCtx and not na(pocPrice) and pocPrice > close and (pocPrice - close) <= confSvpNearDist
// Puts: FROM VAH (good), INTO VAL / INTO POC (bad)
bool confPutFromVah  = confSvpCtx and not na(vahPrice) and close < vahPrice and (vahPrice - close) <= confSvpNearDist
bool confPutIntoVal  = confSvpCtx and not na(valPrice) and valPrice < close and (close - valPrice) <= confSvpNearDist
bool confPutIntoPoc  = confSvpCtx and not na(pocPrice) and pocPrice < close and (close - pocPrice) <= confSvpNearDist

// Derived: path bonus (live — considers which path the bar currently qualifies for, before filtering)
bool confPathHighLong  = (useReclaimSetup and reclaimLong) or (orbBreakLong and (not orbRegimeTrendOnly or regimeIsTrend))
bool confPathMidLong   = usePullbackSetup and resumeLong
bool confPathHighShort = (useReclaimSetup and rejectShort) or (orbBreakShort and (not orbRegimeTrendOnly or regimeIsTrend))
bool confPathMidShort  = usePullbackSetup and resumeShort

// Timing penalty/bonus (prime window already defined above)
bool sessionPenaltyWindow = isLunchWindow or isPowerHour

// Path bonuses (computed first so the score assignment stays on a single line — Pine v6 doesn't support multi-line nested ternaries inside +=).
float callPathBonus = confPathHighLong ? wtPathQuality : confPathMidLong ? wtPathQuality * 0.5 : 0.0
float putPathBonus  = confPathHighShort ? wtPathQuality : confPathMidShort ? wtPathQuality * 0.5 : 0.0

// CALL score
float callScoreRaw = 0.0
callScoreRaw += trendBull                         ? wtHTF15m         : 0.0
callScoreRaw += structureBull                     ? wt5mStruct       : 0.0
callScoreRaw += strongVolOk                       ? wtVolStrong      : 0.0
callScoreRaw += adxVal >= 20                      ? wtADXStrong      : 0.0
callScoreRaw += rsiVal >= 40 and rsiVal <= 68     ? wtRSISweet       : 0.0
callScoreRaw += close > ema20                     ? wtEMA20Side      : 0.0
callScoreRaw += confCallFromVal                   ? wtSVPLocGood     : 0.0
callScoreRaw -= (confCallIntoVah or confCallIntoPoc) ? wtSVPLocBad   : 0.0
callScoreRaw += callPathBonus
callScoreRaw += isPrimeWindow                     ? wtSessionTiming  : 0.0
callScoreRaw -= sessionPenaltyWindow              ? wtSessionTiming  : 0.0
callScoreRaw += (volume > volMA * 1.5 and close > close[1]) ? wtDirectionalVol : 0.0
callConfluenceScore = math.min(10.0, math.max(-5.0, callScoreRaw))

// PUT score (mirrored)
float putScoreRaw = 0.0
putScoreRaw += trendBear                          ? wtHTF15m         : 0.0
putScoreRaw += structureBear                      ? wt5mStruct       : 0.0
putScoreRaw += strongVolOk                        ? wtVolStrong      : 0.0
putScoreRaw += adxVal >= 20                       ? wtADXStrong      : 0.0
putScoreRaw += rsiVal >= 32 and rsiVal <= 60      ? wtRSISweet       : 0.0
putScoreRaw += close < ema20                      ? wtEMA20Side      : 0.0
putScoreRaw += confPutFromVah                     ? wtSVPLocGood     : 0.0
putScoreRaw -= (confPutIntoVal or confPutIntoPoc) ? wtSVPLocBad      : 0.0
putScoreRaw += putPathBonus
putScoreRaw += isPrimeWindow                      ? wtSessionTiming  : 0.0
putScoreRaw -= sessionPenaltyWindow               ? wtSessionTiming  : 0.0
putScoreRaw += (volume > volMA * 1.5 and close < close[1]) ? wtDirectionalVol : 0.0
putConfluenceScore = math.min(10.0, math.max(-5.0, putScoreRaw))

//=========================
// SIGNALS
// — HTF: 15m vs VWAP15; 5m: price vs VWAP5 + EMA9/20
// — 1m trigger: EMA stack + close vs VWAP
// — Entry: VWAP reclaim within N bars OR ORB break (if enabled), OR pullback continuation
// — Volume + chop + ADX + session + regime gate; Strong = extra volume
// — v2: one signalCode per bar (ENTER_* > WATCH_* > NO_TRADE)
//=========================
longReclaimPath = useReclaimSetup and reclaimLong
longORBPath     = orbBreakLong and (not orbRegimeTrendOnly or regimeIsTrend)
shortReclaimPath = useReclaimSetup and rejectShort
shortORBPath     = orbBreakShort and (not orbRegimeTrendOnly or regimeIsTrend)

// Third path: HTF + VWAP side + 1m bull/bear stack (no VWAP *cross* window, no ORB — avoids EMA9>EMA20 full trigger)
momBodyLong      = bodyPct >= entryMinBodyPct
momBodyShort     = bodyPct >= entryMinBodyPct
momTriggerLong   = aboveVWAP and bullTrend and close > ema9
momTriggerShort  = belowVWAP and bearTrend and close < ema9
rawMomentumLong  = useMomentumEntry and signalSessionOk and confirmedBar and volGateEntry and chopGateEntry and entryTrendBull15 and momTriggerLong and long5mEntryOk and adxGateEntry and rsiOkForLong_Entry and close > open and close > close[1] and momBodyLong
rawMomentumShort = useMomentumEntry and signalSessionOk and confirmedBar and volGateEntry and chopGateEntry and entryTrendBear15 and momTriggerShort and short5mEntryOk and adxGateEntry and rsiOkForShort_Entry and close < open and close < close[1] and momBodyShort

callReclaimCore = signalSessionOk and confirmedBar and volGateEntry and chopGateEntry and entryTrendBull15 and entryTrendLong1m and entryTriggerLong and (longReclaimPath or longORBPath) and long5mEntryOk and adxGateEntry and rsiOkForLong_Entry and entryBodyLong
putRejectCore   = signalSessionOk and confirmedBar and volGateEntry and chopGateEntry and entryTrendBear15 and entryTrendShort1m and entryTriggerShort and (shortReclaimPath or shortORBPath) and short5mEntryOk and adxGateEntry and rsiOkForShort_Entry and entryBodyShort

callReclaimBase = callReclaimCore
putRejectBase   = putRejectCore
callPullbackBase = signalSessionOk and confirmedBar and volGateEntry and chopGateEntry and entryTrendBull15 and entryTrendLong1m and entryTriggerLong and usePullbackSetup and resumeLongEnter and long5mEntryOk and adxGateEntry and rsiOkForLong_Entry
putPullbackBase  = signalSessionOk and confirmedBar and volGateEntry and chopGateEntry and entryTrendBear15 and entryTrendShort1m and entryTriggerShort and usePullbackSetup and resumeShortEnter and short5mEntryOk and adxGateEntry and rsiOkForShort_Entry

callMomentumBase = rawMomentumLong
putMomentumBase  = rawMomentumShort

// Counter-VWAP only when dislocation vs VWAP is finite (ATR-scaled; no input). Bounce: vwap−close; rejection: close−vwap. Caps “miles from VWAP” 0DTE traps.
bounceMaxAtrFromVwap = 2.0
bounceVwapDistOkLong  = (vwapVal - close) <= atrVal * bounceMaxAtrFromVwap
bounceVwapDistOkShort = (close - vwapVal) <= atrVal * bounceMaxAtrFromVwap
// High ADX = relentless trend; counter-VWAP 0DTE bounces/rejections get faded — block entries (separate from watch min-ADX).
bounceADXOk     = adxVal < 32
rejectionADXOk  = bounceADXOk

// Counter-VWAP: oversold bounce under VWAP / overbought rejection above VWAP (strong volume + structure filter; lowest setup priority)
bounceCallCondition   = belowVWAP and bounceVwapDistOkLong and bounceADXOk and rsiVal < 38 and rsiVal > rsiVal[3] and ema9 > ema9[3] and low > low[2] and close > open and bodyPct >= entryMinBodyPct and volume >= volMA * strongVolMult and not structureBear and signalSessionOk and confirmedBar
rejectionPutCondition = aboveVWAP and bounceVwapDistOkShort and rejectionADXOk and rsiVal > 62 and rsiVal < rsiVal[3] and ema9 < ema9[3] and high < high[2] and close < open and bodyPct >= entryMinBodyPct and volume >= volMA * strongVolMult and not structureBull and signalSessionOk and confirmedBar
callBounceBase    = bounceCallCondition
putRejectionBase  = rejectionPutCondition

enterLongRaw  = callReclaimBase or callPullbackBase or callMomentumBase or callBounceBase
enterShortRaw = putRejectBase or putPullbackBase or putMomentumBase or putRejectionBase
setupTypeLong = not enterLongRaw ? "NONE" : callPullbackBase ? "PULLBACK" : callReclaimCore ? (longORBPath and not longReclaimPath ? "ORB_BREAK" : "VWAP_RECLAIM") : rawMomentumLong ? "MOMENTUM" : callBounceBase ? "BOUNCE" : "NONE"
setupTypeShort = not enterShortRaw ? "NONE" : putPullbackBase ? "PULLBACK" : putRejectCore ? (shortORBPath and not shortReclaimPath ? "ORB_BREAK" : "VWAP_RECLAIM") : rawMomentumShort ? "MOMENTUM" : putRejectionBase ? "REJECTION" : "NONE"

enterPathTagLong  = pathTagFromSetup(setupTypeLong)
enterPathTagShort = pathTagFromSetup(setupTypeShort)

// Dashboard: which story fits WATCH (paths can be true without full entry gates)
setupWatchLong =
     usePullbackSetup and resumeLong ? "PULLBACK" :
     useReclaimSetup and reclaimLong ? "VWAP_RECLAIM" :
     (orbBreakLong and (not orbRegimeTrendOnly or regimeIsTrend)) ? "ORB_BREAK" :
     "LONG_CONTEXT"
setupWatchShort =
     usePullbackSetup and resumeShort ? "PULLBACK" :
     useReclaimSetup and rejectShort ? "VWAP_RECLAIM" :
     (orbBreakShort and (not orbRegimeTrendOnly or regimeIsTrend)) ? "ORB_BREAK" :
     "SHORT_CONTEXT"

// One directional enter per bar (tie-break: +DI vs -DI)
// v31: add confluence gate — non-BOUNCE calls blocked below scoreFireMin; non-REJECT puts blocked below scoreFireMin.
callScoreOk  = not useConfluenceGate or setupTypeLong  == "BOUNCE"    or callConfluenceScore >= scoreFireMin
putScoreOk   = not useConfluenceGate or setupTypeShort == "REJECTION" or putConfluenceScore  >= scoreFireMin
enterLongFinal  = volGateEntry and enterLongRaw  and callScoreOk and (not enterShortRaw or diPlus > diMinus)
enterShortFinal = volGateEntry and enterShortRaw and putScoreOk  and (not enterLongRaw  or diPlus < diMinus)

// v31: STRONG label = confluence score ≥ scoreStrongMin for main paths. BOUNCE/REJECT keep legacy strong-volume check.
isStrongCallSig = setupTypeLong  == "BOUNCE"    ? (strongVolOk and rsiOkForLong_Strong)  : (callConfluenceScore >= scoreStrongMin and rsiOkForLong_Strong)
isStrongPutSig  = setupTypeShort == "REJECTION" ? (strongVolOk and rsiOkForShort_Strong) : (putConfluenceScore  >= scoreStrongMin and rsiOkForShort_Strong)
plotStrongCall = enterLongFinal  and isStrongCallSig
plotResumeCall = enterLongFinal  and not plotStrongCall
plotStrongPut  = enterShortFinal and isStrongPutSig
plotResumePut  = enterShortFinal and not plotStrongPut

adxGateWatchCond = useMinADXForWatch and signalMinADX > 0 ? adxVal >= signalMinADX : true
watchLong5mOk    = require5mAlignForWatch ? not structureBear : true
watchShort5mOk   = require5mAlignForWatch ? not structureBull : true
watchLong1mOk    = require1mEmaStackForWatch ? bullTrend : true
watchShort1mOk   = require1mEmaStackForWatch ? bearTrend : true
watchLongRaw     = signalSessionOk and trendBull and aboveVWAP and watchLong1mOk and volGateWatch and chop_ok and watchLong5mOk and adxGateWatchCond and not enterLongFinal and not enterShortFinal
watchShortRaw    = signalSessionOk and trendBear and belowVWAP and watchShort1mOk and volGateWatch and chop_ok and watchShort5mOk and adxGateWatchCond and not enterLongFinal and not enterShortFinal
watchBoth     = watchLongRaw and watchShortRaw
watchLongOnly = watchLongRaw and (not watchShortRaw or (watchBoth and (biasAlignedLong or (not biasAlignedShort and diPlus >= diMinus))))
watchShortOnly = watchShortRaw and not watchLongOnly

// Early SIGNAL row: counter-VWAP setup forming (looser than full entry — no volume/body/HL; same VWAP distance + ADX cap as entries).
bounceWatchLong     = signalSessionOk and belowVWAP and bounceVwapDistOkLong and bounceADXOk and rsiVal < 42 and rsiVal > rsiVal[3] and ema9 > ema9[3] and not enterLongFinal and not enterShortFinal
rejectionWatchShort = signalSessionOk and aboveVWAP and bounceVwapDistOkShort and rejectionADXOk and rsiVal > 58 and rsiVal < rsiVal[3] and ema9 < ema9[3] and not enterLongFinal and not enterShortFinal

readyCall = watchLongOnly
readyPut = watchShortOnly
tfConflict = biasConflict

// 0=NO_TRADE 1=WATCH_LONG 2=WATCH_SHORT 3=ENTER_LONG 4=ENTER_SHORT
signalCode = signalSessionOk ? (enterLongFinal ? 3 : enterShortFinal ? 4 : watchLongOnly ? 1 : watchShortOnly ? 2 : 0) : 0

var string lastSetupStr = "--"
if newETDay
    lastSetupStr := "--"
if signalCode == 3 and setupTypeLong != "NONE"
    lastSetupStr := setupTypeLong
if signalCode == 4 and setupTypeShort != "NONE"
    lastSetupStr := setupTypeShort

// ENTER = direction + path (read with chart markers); WATCH = context path; else last entry path
setupTypeStr =
     signalCode == 3 ? (plotStrongCall ? "CALL+ · " : "CALL · ") + enterPathTagLong :
     signalCode == 4 ? (plotStrongPut ? "PUT+ · " : "PUT · ") + enterPathTagShort :
     signalCode == 1 ? (pathTagFromSetup(setupWatchLong) + " · WATCH") :
     signalCode == 2 ? (pathTagFromSetup(setupWatchShort) + " · WATCH") :
     lastSetupStr != "--" ? ("LAST: " + pathTagFromSetup(lastSetupStr)) :
     "--"

var string lastEnterStr = "--"
if newETDay
    lastEnterStr := "--"
if signalCode == 3
    lastEnterStr := (plotStrongCall ? "ENTER · CALLS+ · " : "ENTER · CALLS · ") + enterPathTagLong
else if signalCode == 4
    lastEnterStr := (plotStrongPut ? "ENTER · PUTS+ · " : "ENTER · PUTS · ") + enterPathTagShort

var string lastEnterPathTag = "--"
if newETDay
    lastEnterPathTag := "--"
if enterLongFinal
    lastEnterPathTag := enterPathTagLong
if enterShortFinal
    lastEnterPathTag := enterPathTagShort

enterPathDashColor = enterLongFinal ? color.lime : enterShortFinal ? color.red : lastEnterPathTag == "--" ? color.gray : color.silver

//=========================
// EXIT CONDITIONS (signal-based trades)
//=========================
var bool   tradeActive    = false
var int    tradeDir       = 0
var string tradeEntryType = "NONE"
var float  tradeEntry     = na
var float  tradeStop      = na
var bool   tradeTrimHit   = false
var bool   tradeExited    = false
var float  exitLine       = na
var float  signalHigh     = na
var float  signalLow      = na
var string tradeState     = "NONE"
var int    signalTradeStartBar = na
var string signalTradePathTag = "--"

newLongSignal  = plotStrongCall or plotResumeCall
newShortSignal = plotStrongPut  or plotResumePut

if newLongSignal
    tradeActive    := true
    tradeDir       := 1
    signalTradePathTag := enterPathTagLong
    tradeEntryType := (plotStrongCall ? "Strong Calls · " : "Calls · ") + enterPathTagLong
    tradeEntry     := close
    // Initial SL: wick low; optional ATR floor unless signalStopPureWick.
    tradeStop      := signalStopPureWick ? low : math.min(low, close - atrVal * stopATRMult)
    tradeTrimHit   := false
    tradeExited    := false
    exitLine       := na
    signalHigh     := high
    signalLow      := low
    signalTradeStartBar := bar_index

if newShortSignal
    tradeActive    := true
    tradeDir       := -1
    signalTradePathTag := enterPathTagShort
    tradeEntryType := (plotStrongPut ? "Strong Puts · " : "Puts · ") + enterPathTagShort
    tradeEntry     := close
    tradeStop      := signalStopPureWick ? high : math.max(high, close + atrVal * stopATRMult)
    tradeTrimHit   := false
    tradeExited    := false
    exitLine       := na
    signalHigh     := high
    signalLow      := low
    signalTradeStartBar := bar_index

if newETDay
    autoMentorState  := 0
    autoStrikeStored := na
if newLongSignal
    autoMentorState  := 1
    autoStrikeStored := close
if newShortSignal
    autoMentorState  := -1
    autoStrikeStored := close

signalFailLong  = tradeActive and tradeDir == 1  and not na(signalLow)  and close < signalLow
signalFailShort = tradeActive and tradeDir == -1 and not na(signalHigh) and close > signalHigh
emaFailLong     = tradeActive and tradeDir == 1  and close < ema9
emaFailShort    = tradeActive and tradeDir == -1 and close > ema9
// BOUNCE / REJECT entries start on the "wrong" side of VWAP by design — do not count that as soft-exit failure from bar 1.
vwapFailLong    = tradeActive and tradeDir == 1  and close < vwapVal and signalTradePathTag != "BOUNCE"
vwapFailShort   = tradeActive and tradeDir == -1 and close > vwapVal and signalTradePathTag != "REJECT"

exitCountLong  = (signalFailLong  ? 1 : 0) + (emaFailLong  ? 1 : 0) + (vwapFailLong  ? 1 : 0)
exitCountShort = (signalFailShort ? 1 : 0) + (emaFailShort ? 1 : 0) + (vwapFailShort ? 1 : 0)
exitNowLong    = exitCountLong  >= 2
exitNowShort   = exitCountShort >= 2
barsInSignalTrade = tradeActive and not na(signalTradeStartBar) ? bar_index - signalTradeStartBar : 0
// BOUNCE/REJECT: VWAP leg already excluded above; give soft exit longer to breathe (2× min bars vs normal path).
softExitBarsNeededLong  = signalTradePathTag == "BOUNCE"  ? softExitMinBars * 2 : softExitMinBars
softExitBarsNeededShort = signalTradePathTag == "REJECT" ? softExitMinBars * 2 : softExitMinBars
exitSoftLong   = exitNowLong  and (softExitMinBars <= 0 or barsInSignalTrade >= softExitBarsNeededLong)
exitSoftShort  = exitNowShort and (softExitMinBars <= 0 or barsInSignalTrade >= softExitBarsNeededShort)

// Evaluate every bar (Pine: ta.lowest/highest for exit logic must not be conditional-only)
swingLowExit  = ta.lowest(low,  swingLookback)
swingHighExit = ta.highest(high, swingLookback)

actualExitLong  = confirmedBar and tradeActive and tradeDir == 1  and (close <= math.max(tradeStop, swingLowExit) or exitSoftLong)
actualExitShort = confirmedBar and tradeActive and tradeDir == -1 and (close >= math.min(tradeStop, swingHighExit) or exitSoftShort)

// Chart: same X style; distinguish EXIT source (if multiple true same bar, STOP > SWING > SOFT)
exitStopLong   = confirmedBar and tradeActive and tradeDir == 1  and not na(tradeStop)     and close <= tradeStop
exitSwingLong  = confirmedBar and tradeActive and tradeDir == 1  and not na(swingLowExit)  and close <= swingLowExit and not exitStopLong
exitSoftVisLong = confirmedBar and tradeActive and tradeDir == 1 and exitSoftLong and not exitStopLong and not exitSwingLong

exitStopShort   = confirmedBar and tradeActive and tradeDir == -1 and not na(tradeStop)     and close >= tradeStop
exitSwingShort  = confirmedBar and tradeActive and tradeDir == -1 and not na(swingHighExit) and close >= swingHighExit and not exitStopShort
exitSoftVisShort = confirmedBar and tradeActive and tradeDir == -1 and exitSoftShort and not exitStopShort and not exitSwingShort

// Live STOP markers (retract intrabar if price recovers).
// These are for visuals only; actual trade exits remain `confirmedBar`-based above.
exitStopLongLive  = tradeActive and tradeDir == 1  and not na(tradeStop) and close <= tradeStop
exitStopShortLive = tradeActive and tradeDir == -1 and not na(tradeStop) and close >= tradeStop

// NOTE: Limiting historical markers requires deleting drawing objects.
// plotshape() can't "erase old ones" because it is evaluated per-bar historically.

if not tradeActive
    tradeState := "NONE"
    exitLine   := na
else
    if tradeDir == 1
        tradeTrimHit := tradeTrimHit or high >= tradeEntry + atrVal
        // Delay EMA20 ratchet so entry pullback doesn't instantly stop out
        if delayEma20TrailBars <= 0 or barsInSignalTrade >= delayEma20TrailBars
            tradeStop := math.max(tradeStop, ema20)
        exitLine     := math.max(tradeStop, swingLowExit)
        if confirmedBar and (close <= exitLine or exitSoftLong)
            tradeExited := true
        tradeState := tradeExited ? "EXIT CALL" : tradeTrimHit ? "TRIM CALL" : "HOLD CALL"
    if tradeDir == -1
        tradeTrimHit := tradeTrimHit or low <= tradeEntry - atrVal
        if delayEma20TrailBars <= 0 or barsInSignalTrade >= delayEma20TrailBars
            tradeStop := math.min(tradeStop, ema20)
        exitLine     := math.min(tradeStop, swingHighExit)
        if confirmedBar and (close >= exitLine or exitSoftShort)
            tradeExited := true
        tradeState := tradeExited ? "EXIT PUT" : tradeTrimHit ? "TRIM PUT" : "HOLD PUT"

if tradeExited and not newLongSignal and not newShortSignal
    tradeActive := false

// Mentor follows the same signal trade as chart EXIT X — clear dashboard/stop when that trade exits
if actualExitLong and autoMentorState == 1
    autoMentorState  := 0
    autoStrikeStored := na
if actualExitShort and autoMentorState == -1
    autoMentorState  := 0
    autoStrikeStored := na

effTradeInput = autoMentorState != 0 and not na(autoStrikeStored) ? str.tostring(autoStrikeStored, format.mintick) + (autoMentorState == 1 ? "C" : "P") : ""

mentorActive = str.length(effTradeInput) > 1
isCall       = mentorActive and (str.endswith(effTradeInput, "C") or str.endswith(effTradeInput, "c"))
isPut        = mentorActive and (str.endswith(effTradeInput, "P") or str.endswith(effTradeInput, "p"))
mentorDir    = isCall ? 1 : isPut ? -1 : 0
priceStr     = mentorActive ? str.substring(effTradeInput, 0, str.length(effTradeInput) - 1) : "0"
tradeNumParsed = mentorActive ? str.tonumber(priceStr) : float(na)
strikeOnlyMode = mentorActive and not na(tradeNumParsed) and not str.contains(priceStr, ".")
optionStrike = strikeOnlyMode ? tradeNumParsed : float(na)
strikeActive = strikeOnlyMode and not na(optionStrike) and optionStrike > 0

// Live STOP EXIT flash on the current bar (SWING/SOFT exits drawn via labels in LAST 10 MARKERS section).
plotshape(barstate.islast and exitStopLongLive,  title="STOP EXIT (calls)", style=shape.xcross, location=location.abovebar, color=color.red,  text="STOP EXIT", textcolor=chart.fg_color, size=size.small)
plotshape(barstate.islast and exitStopShortLive, title="STOP EXIT (puts)",  style=shape.xcross, location=location.belowbar, color=color.lime, text="STOP EXIT", textcolor=chart.fg_color, size=size.small)

//=========================
// MENTOR HELPERS
//=========================
roundUp1(x)      => math.ceil(x)
roundDown1(x)    => math.floor(x)
roundUpHalf(x)   => math.ceil(x   * 2.0) / 2.0
roundDownHalf(x) => math.floor(x  * 2.0) / 2.0

approxExists(float[] arr, float level, float tol) =>
    bool found = false
    int sz = array.size(arr)
    if sz > 0
        for i = 0 to sz - 1
            found := found or math.abs(array.get(arr, i) - level) <= tol
    found

pushUnique(float[] arr, float level, float tol) =>
    if not na(level) and not na(tol)
        if array.size(arr) == 0 or not approxExists(arr, level, tol)
            array.push(arr, level)

sortAsc(float[] arr) =>
    sz = array.size(arr)
    if sz > 1
        for i = 0 to sz - 2
            for j = i + 1 to sz - 1
                if array.get(arr, j) < array.get(arr, i)
                    tmp = array.get(arr, i)
                    array.set(arr, i, array.get(arr, j))
                    array.set(arr, j, tmp)

sortDesc(float[] arr) =>
    sz = array.size(arr)
    if sz > 1
        for i = 0 to sz - 2
            for j = i + 1 to sz - 1
                if array.get(arr, j) > array.get(arr, i)
                    tmp = array.get(arr, i)
                    array.set(arr, i, array.get(arr, j))
                    array.set(arr, j, tmp)

//=========================
// MENTOR STATE
//=========================
var string lastEffTradeInput  = ""
var float  mTrailingStop      = na
var float  mT1                = na
var float  mT2                = na
var float  mT3                = na
var bool   mTrimDone          = false
var int    mentorEntryBar     = na
var int    mentorLineAnchorMs = na  // RTH time at mentor entry — horizontal SL/T1 lines (plot() would slope when levels change)
var line   mentorSLPlotLine   = na
var line   mentorT1PlotLine   = na
var line   mentorT2PlotLine   = na
var line   mentorT3PlotLine   = na
var float  mentorInitStopLocked = na
var float  mentorStructStop     = na
var int    mentorBarsHeld     = 0
var string mentorBiasNote     = "NONE"

newMentorTrade = mentorActive and effTradeInput != lastEffTradeInput

if not mentorActive
    mentorEntryLocked    := na
    mTrailingStop      := na
    mT1                := na
    mT2                := na
    mT3                := na
    mTrimDone          := false
    mentorEntryBar     := na
    mentorLineAnchorMs := na
    mentorInitStopLocked := na
    mentorStructStop     := na
    mentorBarsHeld     := 0
    mentorBiasNote     := "NONE"

if newMentorTrade and mentorActive and mentorDir != 0 and (strikeOnlyMode or not na(tradeNumParsed))
    mentorEntryLocked := strikeOnlyMode ? close : tradeNumParsed
    mTrailingStop      := na
    mT1                := na
    mT2                := na
    mT3                := na
    mTrimDone          := false
    mentorEntryBar     := bar_index
    mentorLineAnchorMs := time
    // Initial SL locked at entry: previous completed 15m candle WICK (RTH). If on wrong side, fall back to ATR stop.
    mentorInitStopLocked := float(na)
    if mentorDir == 1 and not na(prev15Low) and prev15Low < mentorEntryLocked
        mentorInitStopLocked := prev15Low
    else if mentorDir == -1 and not na(prev15High) and prev15High > mentorEntryLocked
        mentorInitStopLocked := prev15High
    mentorStructStop := mentorInitStopLocked
    mentorBarsHeld     := 0
    mentorBiasNote     := "NONE"

lastEffTradeInput := effTradeInput

mentorEntry = mentorActive ? mentorEntryLocked : float(na)

// Trailing structural stop from 15m wicks:
// - CALLS: when a new 15m candle completes and closes higher than the prior 15m close, move stop up to that candle's LOW wick.
// - PUTS:  when a new 15m candle completes and closes lower than the prior 15m close, move stop down to that candle's HIGH wick.
// Always ratchets in the profitable direction, and only if the wick remains on the correct side of entry.
new15mCompleted = not na(prev15Close) and (prev15Close != prev15Close[1])
if mentorActive and usePrev15OrbStop and not na(mentorEntry) and mentorDir != 0 and not newMentorTrade and new15mCompleted
    if mentorDir == 1
        bool bull15 = not na(prev15Close) and not na(prev15Close2) and prev15Close > prev15Close2
        if bull15 and not na(prev15Low) and prev15Low < mentorEntry
            mentorStructStop := na(mentorStructStop) ? prev15Low : math.max(mentorStructStop, prev15Low)
    else if mentorDir == -1
        bool bear15 = not na(prev15Close) and not na(prev15Close2) and prev15Close < prev15Close2
        if bear15 and not na(prev15High) and prev15High > mentorEntry
            mentorStructStop := na(mentorStructStop) ? prev15High : math.min(mentorStructStop, prev15High)

if mentorActive and not na(mentorEntryBar)
    mentorBarsHeld := bar_index - mentorEntryBar

//=========================
// MENTOR TARGET ENGINE
//=========================
levelTol      = math.max(syminfo.mintick * 3, 0.03)
minTargetDist = math.max(levelTol, atrVal * mentorMinTargetATR, atrVal * mentorTargetFloorATR, mentorTargetMinUSD)
entryStopCushion = math.max(syminfo.mintick * mentorMinStopTicks, atrVal * mentorStopCushionATR)
inMentorBuffer   = mentorActive and not na(mentorEntryBar) and mentorBarsHeld < mentorBufferBars

fibRangeOk = useFib1hTargets and not na(fibSwingRange) and fibSwingRange > math.max(levelTol * 2, syminfo.mintick * 5)

if mentorActive and not na(mentorEntry) and mentorDir != 0
    bool usedFibTgts = false
    if fibRangeOk
        if mentorDir == 1
            float[] fibUp = array.new_float()
            pushUnique(fibUp, fibSwingHigh + fibSwingRange * 0.382, levelTol)
            pushUnique(fibUp, fibSwingHigh + fibSwingRange * 0.618, levelTol)
            pushUnique(fibUp, fibSwingHigh + fibSwingRange * 1.000, levelTol)
            float[] fibFilt = array.new_float()
            for i = 0 to array.size(fibUp) - 1
                fu = array.get(fibUp, i)
                if fu > mentorEntry + minTargetDist
                    array.push(fibFilt, fu)
            sortAsc(fibFilt)
            if array.size(fibFilt) >= 1
                float fibT1Candidate = array.get(fibFilt, 0)
                float fibT1Distance  = fibT1Candidate - mentorEntry
                // Reject Fib targets if T1 is too far away — falls through to level-based engine below.
                if fibT1Distance <= atrVal * fibMaxT1ATR
                    usedFibTgts := true
                    mT1 := fibT1Candidate
                    mT2 := array.size(fibFilt) >= 2 ? array.get(fibFilt, 1) : mentorEntry + atrVal * targetATR2
                    mT3 := array.size(fibFilt) >= 3 ? array.get(fibFilt, 2) : mentorEntry + atrVal * targetATR3
        else if mentorDir == -1
            float[] fibDn = array.new_float()
            pushUnique(fibDn, fibSwingLow - fibSwingRange * 0.382, levelTol)
            pushUnique(fibDn, fibSwingLow - fibSwingRange * 0.618, levelTol)
            pushUnique(fibDn, fibSwingLow - fibSwingRange * 1.000, levelTol)
            float[] fibFiltS = array.new_float()
            for i = 0 to array.size(fibDn) - 1
                fd = array.get(fibDn, i)
                if fd < mentorEntry - minTargetDist
                    array.push(fibFiltS, fd)
            sortDesc(fibFiltS)
            if array.size(fibFiltS) >= 1
                float fibT1CandidateS = array.get(fibFiltS, 0)
                float fibT1DistanceS  = mentorEntry - fibT1CandidateS
                if fibT1DistanceS <= atrVal * fibMaxT1ATR
                    usedFibTgts := true
                    mT1 := fibT1CandidateS
                    mT2 := array.size(fibFiltS) >= 2 ? array.get(fibFiltS, 1) : mentorEntry - atrVal * targetATR2
                    mT3 := array.size(fibFiltS) >= 3 ? array.get(fibFiltS, 2) : mentorEntry - atrVal * targetATR3

    if not usedFibTgts
        float[] allLevels = array.new_float()

        pushUnique(allLevels, orbHigh,         levelTol)
        pushUnique(allLevels, orbLow,          levelTol)
        pushUnique(allLevels, orbMid,          levelTol)
        pushUnique(allLevels, prevHigh,        levelTol)
        pushUnique(allLevels, prevLow,         levelTol)
        pushUnique(allLevels, prevClose,       levelTol)
        pushUnique(allLevels, prevDayOpen,     levelTol)
        pushUnique(allLevels, dayHigh,         levelTol)
        pushUnique(allLevels, dayLow,          levelTol)
        pushUnique(allLevels, recentSwingHigh, levelTol)
        pushUnique(allLevels, recentSwingLow,  levelTol)
        pushUnique(allLevels, vwapVal,         levelTol)
        pushUnique(allLevels, ema9,            levelTol)
        pushUnique(allLevels, ema20,           levelTol)
        // v30: SVP levels — POC is the magnet, VAH/VAL the 70% zone edges. Guarded by svpUseForTargets + svpValid so early-session (unstable) values don't pollute targets.
        if svpUseForTargets and svpValid
            pushUnique(allLevels, pocPrice, levelTol)
            pushUnique(allLevels, vahPrice, levelTol)
            pushUnique(allLevels, valPrice, levelTol)
        if strikeActive
            if mentorDir == 1 and optionStrike > mentorEntry + minTargetDist
                pushUnique(allLevels, optionStrike, levelTol)
            if mentorDir == -1 and optionStrike < mentorEntry - minTargetDist
                pushUnique(allLevels, optionStrike, levelTol)

        r1 = float(roundUp1(mentorEntry))
        r2 = float(roundDown1(mentorEntry))
        for i = 0 to 4
            pushUnique(allLevels, r1 + i, levelTol)
            pushUnique(allLevels, r2 - i, levelTol)

        if useHalfDollarLevels
            rH1 = roundUpHalf(mentorEntry)
            rH2 = roundDownHalf(mentorEntry)
            for i = 0 to 3
                pushUnique(allLevels, rH1 + i * 0.5, levelTol)
                pushUnique(allLevels, rH2 - i * 0.5, levelTol)

        float[] filtered = array.new_float()

        if mentorDir == 1
            for i = 0 to array.size(allLevels) - 1
                lvl = array.get(allLevels, i)
                if lvl > mentorEntry + minTargetDist
                    array.push(filtered, lvl)
            sortAsc(filtered)
            mT1 := array.size(filtered) >= 1 ? array.get(filtered, 0) : mentorEntry + atrVal * targetATR1
            mT2 := array.size(filtered) >= 2 ? array.get(filtered, 1) : mentorEntry + atrVal * targetATR2
            mT3 := array.size(filtered) >= 3 ? array.get(filtered, 2) : mentorEntry + atrVal * targetATR3

        if mentorDir == -1
            for i = 0 to array.size(allLevels) - 1
                lvl = array.get(allLevels, i)
                if lvl < mentorEntry - minTargetDist
                    array.push(filtered, lvl)
            sortDesc(filtered)
            mT1 := array.size(filtered) >= 1 ? array.get(filtered, 0) : mentorEntry - atrVal * targetATR1
            mT2 := array.size(filtered) >= 2 ? array.get(filtered, 1) : mentorEntry - atrVal * targetATR2
            mT3 := array.size(filtered) >= 3 ? array.get(filtered, 2) : mentorEntry - atrVal * targetATR3

    // v30: BIAS now SVP-aware. Priority order (long mirror for calls, flipped for puts):
    //  1. Entry INTO VAH  (wall right above)     — bad spot for calls
    //  2. Entry INTO POC  (magnet above entry)   — magnet pulls against calls
    //  3. Entry FROM VAL  (near support)         — good spot for calls
    //  4. Existing ORB/PDH/DH warnings           — fallback
    //  5. OPEN SPACE                             — nothing immediate
    float svpNearDist = atrVal * svpNearATR
    bool svpCtx = svpUseForBias and svpValid and not na(svpNearDist)

    bool callIntoVah  = svpCtx and mentorDir == 1  and not na(vahPrice) and vahPrice > mentorEntry and (vahPrice - mentorEntry) <= svpNearDist
    bool callIntoPoc  = svpCtx and mentorDir == 1  and not na(pocPrice) and pocPrice > mentorEntry and (pocPrice - mentorEntry) <= svpNearDist
    bool callFromVal  = svpCtx and mentorDir == 1  and not na(valPrice) and mentorEntry > valPrice and (mentorEntry - valPrice) <= svpNearDist
    bool putIntoVal   = svpCtx and mentorDir == -1 and not na(valPrice) and valPrice < mentorEntry and (mentorEntry - valPrice) <= svpNearDist
    bool putIntoPoc   = svpCtx and mentorDir == -1 and not na(pocPrice) and pocPrice < mentorEntry and (mentorEntry - pocPrice) <= svpNearDist
    bool putFromVah   = svpCtx and mentorDir == -1 and not na(vahPrice) and vahPrice > mentorEntry and (vahPrice - mentorEntry) <= svpNearDist

    mentorBiasNote :=
         callIntoVah ? "CALL INTO VAH RES"     :
         putIntoVal  ? "PUT INTO VAL SUP"      :
         callIntoPoc ? "CALL INTO POC MAGNET"  :
         putIntoPoc  ? "PUT INTO POC MAGNET"   :
         callFromVal ? "CALL FROM VAL SUPPORT" :
         putFromVah  ? "PUT FROM VAH RES"      :
         mentorDir == 1  and not na(orbHigh)  and mentorEntry < orbHigh  ? "CALL INTO ORB RES"   :
         mentorDir == -1 and not na(orbLow)   and mentorEntry > orbLow   ? "PUT INTO ORB SUP"    :
         mentorDir == 1  and not na(prevHigh) and close < prevHigh        ? "CALL BELOW PDH"      :
         mentorDir == -1 and not na(prevLow)  and close > prevLow         ? "PUT ABOVE PDL"       :
         mentorDir == 1  and not na(dayHigh)  and close < dayHigh         ? "CALL BELOW DAY HIGH" :
         mentorDir == -1 and not na(dayLow)   and close > dayLow          ? "PUT ABOVE DAY LOW"   :
         "OPEN SPACE"

    trimTouchLong  = confirmOnClose ? close >= mT1 : high >= mT1
    trimTouchShort = confirmOnClose ? close <= mT1 : low  <= mT1
    if not inMentorBuffer
        if mentorDir == 1  and not na(mT1) and trimTouchLong
            mTrimDone := true
        if mentorDir == -1 and not na(mT1) and trimTouchShort
            mTrimDone := true
else
    mT1 := na
    mT2 := na
    mT3 := na

//=========================
// MENTOR TRAILING STOP
//=========================
mentorStopMult = adxVal >= 30 ? 1.25 : adxVal >= 20 ? 1.0 : 0.75

atrStopLong  = mentorEntry - atrVal * stopATRMult * mentorStopMult
atrStopShort = mentorEntry + atrVal * stopATRMult * mentorStopMult
// Initial mentor SL uses prev completed 15m wick (see mentorInitStopLocked); trails on subsequent 15m wicks when enabled.
structStopLong  = usePrev15OrbStop and not na(mentorStructStop) and mentorDir == 1  ? mentorStructStop : float(na)
structStopShort = usePrev15OrbStop and not na(mentorStructStop) and mentorDir == -1 ? mentorStructStop : float(na)

mentorBaseStop =
     not mentorActive or na(mentorEntry) ? float(na) :
     mentorDir == 1  ? (not na(structStopLong)  ? structStopLong  : atrStopLong) :
     mentorDir == -1 ? (not na(structStopShort) ? structStopShort : atrStopShort) :
     float(na)

beTouchLong =
     na(mT1) ? false :
     confirmOnClose ? close >= mT1 :
     high >= mT1

beTouchShort =
     na(mT1) ? false :
     confirmOnClose ? close <= mT1 :
     low <= mT1

breakEvenArmed =
     mentorDir == 1  ? not na(mT1) and beTouchLong and mentorBarsHeld >= 1 :
     mentorDir == -1 ? not na(mT1) and beTouchShort and mentorBarsHeld >= 1 :
     false

if mentorActive and mentorDir == 1 and not na(mentorBaseStop)
    if na(mTrailingStop) or newMentorTrade
        mTrailingStop := mentorBaseStop
    else if breakEvenArmed
        float callTrailCandidate = math.min(ema20, close - atrVal * 0.2)
        mTrailingStop := math.max(math.max(mTrailingStop, mentorEntry), callTrailCandidate)
    else
        mTrailingStop := math.max(mTrailingStop, mentorBaseStop)

    if not breakEvenArmed
        mTrailingStop := math.min(mTrailingStop, mentorEntry - entryStopCushion)

if mentorActive and mentorDir == -1 and not na(mentorBaseStop)
    if na(mTrailingStop) or newMentorTrade
        mTrailingStop := mentorBaseStop
    else if breakEvenArmed
        float putTrailCandidate = math.max(ema20, close + atrVal * 0.2)
        float putStopFloor = mentorEntry + syminfo.mintick
        float putTrailCapped = math.max(putStopFloor, putTrailCandidate)
        mTrailingStop := math.min(mTrailingStop, putTrailCapped)
    else
        mTrailingStop := math.min(mTrailingStop, mentorBaseStop)

    if not breakEvenArmed
        mTrailingStop := math.max(mTrailingStop, mentorEntry + entryStopCushion)

if not mentorActive
    mTrailingStop := na

// #region agent log (chart debug booleans — verify in Replay / dashboard)
callTrailStopHit = mentorActive and mentorDir == 1  and not na(mTrailingStop) and close <= mTrailingStop and mentorBarsHeld >= mentorBufferBars
putTrailStopHit  = mentorActive and mentorDir == -1 and not na(mTrailingStop) and close >= mTrailingStop and mentorBarsHeld >= mentorBufferBars
// #endregion

stopForDisplay =
     not mentorActive or na(mentorEntry) or mentorDir == 0 ? float(na) :
     inMentorBuffer and not breakEvenArmed and not na(mentorBaseStop) ? mentorBaseStop :
     mTrailingStop

//=========================
// MENTOR CONDITION SCORES
//=========================
callSupportScore =
     (trendBull                                              ? 1 : 0) +
     (structureBull                                          ? 1 : 0) +
     (aboveVWAP                                              ? 1 : 0) +
     (close > ema20                                          ? 1 : 0) +
     (rsiVal < 40                                            ? 1 : 0) +
     (volOk                                                  ? 1 : 0) +
     (adxVal >= 15                                           ? 1 : 0) +
     (not na(orbLow) and close >= orbLow                     ? 1 : 0)

callOppositionScore =
     (trendBear                                              ? 1 : 0) +
     (structureBear                                          ? 1 : 0) +
     (belowVWAP                                              ? 1 : 0) +
     (close < ema20                                          ? 1 : 0) +
     (rsiVal > 65                                            ? 1 : 0) +
     (not volOk                                              ? 1 : 0) +
     (isPowerHour                                            ? 1 : 0) +
     (isLunchWindow                                          ? 1 : 0)

putSupportScore =
     (trendBear                                              ? 1 : 0) +
     (structureBear                                          ? 1 : 0) +
     (belowVWAP                                              ? 1 : 0) +
     (close < ema20                                          ? 1 : 0) +
     (rsiVal > 60                                            ? 1 : 0) +
     (volOk                                                  ? 1 : 0) +
     (adxVal >= 15                                           ? 1 : 0) +
     (not na(orbHigh) and close <= orbHigh                   ? 1 : 0)

putOppositionScore =
     (trendBull                                              ? 1 : 0) +
     (structureBull                                          ? 1 : 0) +
     (aboveVWAP                                              ? 1 : 0) +
     (close > ema20                                          ? 1 : 0) +
     (rsiVal < 35                                            ? 1 : 0) +
     (not volOk                                              ? 1 : 0) +
     (isPowerHour                                            ? 1 : 0) +
     (isLunchWindow                                          ? 1 : 0)

drawdownATR =
     mentorDir == 1  and not na(mentorEntry) ? math.max(0.0, (mentorEntry - close) / atrVal) :
     mentorDir == -1 and not na(mentorEntry) ? math.max(0.0, (close - mentorEntry) / atrVal) :
     0.0

profitATR =
     mentorDir == 1  and not na(mentorEntry) ? math.max(0.0, (close - mentorEntry) / atrVal) :
     mentorDir == -1 and not na(mentorEntry) ? math.max(0.0, (mentorEntry - close) / atrVal) :
     0.0

volSurge       = volume > volMA * 1.5
volDrying      = volume < volMA * 0.5
volAgainstCall = volSurge and close < close[1]
volAgainstPut  = volSurge and close > close[1]
volForCall     = volSurge and close > close[1]
volForPut      = volSurge and close < close[1]

higherHigh = high > high[1] and high[1] > high[2]
lowerLow   = low  < low[1]  and low[1]  < low[2]
lowerHigh  = high < high[1]
higherLow  = low  > low[1]

rsiBullDiv = close < close[3] and rsiVal > rsiVal[3]
rsiBearDiv = close > close[3] and rsiVal < rsiVal[3]

adxFalling = adxVal < adxVal[3]
adxRising  = adxVal > adxVal[3]

mentorOrbBreakLong  = not na(orbHigh) and close > orbHigh and close[1] <= orbHigh
mentorOrbBreakShort = not na(orbLow)  and close < orbLow  and close[1] >= orbLow
orbFailLong   = not na(orbHigh) and close < orbHigh and high > orbHigh
orbFailShort  = not na(orbLow)  and close > orbLow  and low  < orbLow

aboveT1 = mentorDir == 1  and not na(mT1) and close >= mT1
aboveT2 = mentorDir == 1  and not na(mT2) and close >= mT2
aboveT3 = mentorDir == 1  and not na(mT3) and close >= mT3
belowT1 = mentorDir == -1 and not na(mT1) and close <= mT1
belowT2 = mentorDir == -1 and not na(mT2) and close <= mT2
belowT3 = mentorDir == -1 and not na(mT3) and close <= mT3

nearT1Long  = mentorDir == 1  and not na(mT1) and mT1 - close        <= atrVal * 0.3
nearT1Short = mentorDir == -1 and not na(mT1) and close - mT1        <= atrVal * 0.3
nearT2Long  = mentorDir == 1  and not na(mT2) and mT2 - close        <= atrVal * 0.3
nearT2Short = mentorDir == -1 and not na(mT2) and close - mT2        <= atrVal * 0.3
nearStopL   = mentorDir == 1  and not na(mTrailingStop) and close - mTrailingStop  <= atrVal * 0.2
nearStopS   = mentorDir == -1 and not na(mTrailingStop) and mTrailingStop - close  <= atrVal * 0.2

//=========================
// MENTOR ADVICE ENGINE
//=========================
mentorAdvice      = "NO ACTIVE TRADE — WAIT FOR CALLS/PUTS ENTER ON CHART"
mentorAdviceColor = color.gray

if mentorActive and not na(mentorEntry) and mentorDir != 0

    // ── BUFFER PERIOD ──
    if mentorBarsHeld < mentorBufferBars

        if mentorDir == 1
            if close > mentorEntry and aboveVWAP and (structureBull or trendBull)
                mentorAdvice      := "NEW CALL — GOOD START"
                mentorAdviceColor := color.lime
            else if close < mentorEntry and belowVWAP and structureBear
                mentorAdvice      := "NEW CALL — WEAK START, WATCH REACTION"
                mentorAdviceColor := color.yellow
            else
                mentorAdvice      := "NEW CALL — WATCH REACTION"
                mentorAdviceColor := color.yellow

        else if mentorDir == -1
            if close < mentorEntry and belowVWAP and (structureBear or trendBear)
                mentorAdvice      := "NEW PUT — GOOD START"
                mentorAdviceColor := color.red
            else if close > mentorEntry and aboveVWAP and structureBull
                mentorAdvice      := "NEW PUT — WEAK START, WATCH REACTION"
                mentorAdviceColor := color.yellow
            else
                mentorAdvice      := "NEW PUT — WATCH REACTION"
                mentorAdviceColor := color.yellow

    // ── ACTIVE MANAGEMENT ──
    else

        if mentorDir == 1

            if callTrailStopHit
                mentorAdvice      := "TRAIL STOP HIT — EXIT ALL NOW"
                mentorAdviceColor := color.red

            else if drawdownATR >= mentorHardFailATR and structureBear and volAgainstCall
                mentorAdvice      := "CONFIRMED FAILURE — STRUCTURE + VOLUME AGAINST, EXIT"
                mentorAdviceColor := color.red

            else if orbFailLong and not aboveT1
                mentorAdvice      := "ORB FAILED TO HOLD — EXIT CALLS FAST"
                mentorAdviceColor := color.red

            else if not trendBull and structureBear and belowVWAP and aboveT1
                mentorAdvice      := "TREND REVERSAL CONFIRMED — EXIT ALL CALLS"
                mentorAdviceColor := color.red

            else if volAgainstCall and lowerHigh and aboveT1
                mentorAdvice      := "HEAVY SELL VOLUME + LOWER HIGH — EXIT"
                mentorAdviceColor := color.red

            else if rsiVal >= 78
                mentorAdvice      := "RSI EXTREME (" + str.tostring(math.round(rsiVal, 0)) + ") — EXIT NOW"
                mentorAdviceColor := color.red

            else if aboveT3
                mentorAdvice      := "T3 HIT — TAKE FULL PROFIT, EXCELLENT TRADE"
                mentorAdviceColor := color.lime

            else if aboveT2 and (rsiVal >= 70 or rsiBearDiv or isPowerHour)
                mentorAdvice      := "T2 HIT + EXHAUSTION SIGNS — EXIT ALL HERE"
                mentorAdviceColor := color.lime

            else if aboveT2 and not mTrimDone
                mentorAdvice      := "T2 HIT — TAKE 50-75%, TRAIL REST TO T1"
                mentorAdviceColor := color.lime

            else if aboveT2
                mentorAdvice      := "ABOVE T2 — TRAIL STOP, AIM FOR T3"
                mentorAdviceColor := color.lime

            else if nearT2Long
                mentorAdvice      := "NEAR T2 (" + str.tostring(math.round(mT2, 2)) + ") — PLAN YOUR EXIT NOW"
                mentorAdviceColor := color.lime

            else if aboveT1 and (rsiVal >= 68 or isLunchWindow)
                mentorAdvice      := "ABOVE T1 + " + (rsiVal >= 68 ? "RSI HIGH" : "LUNCH") + " — TAKE PROFITS NOW"
                mentorAdviceColor := color.yellow

            else if aboveT1 and not mTrimDone
                mentorAdvice      := "T1 HIT — TAKE PARTIAL + MOVE STOP TO ENTRY"
                mentorAdviceColor := color.lime

            else if aboveT1
                mentorAdvice      := "ABOVE T1 — TRAILING STOP ACTIVE, HOLD FOR T2"
                mentorAdviceColor := color.lime

            else if nearT1Long
                mentorAdvice      := "APPROACHING T1 (" + str.tostring(math.round(mT1, 2)) + ") — GET READY TO TRIM"
                mentorAdviceColor := color.lime

            else if mentorOrbBreakLong and adxRising and volForCall
                mentorAdvice      := "ORB BREAKOUT CONFIRMED — LET IT RUN TO T1"
                mentorAdviceColor := color.lime

            else if nearStopL
                mentorAdvice      := "NEAR STOP (" + str.tostring(math.round(mTrailingStop, 2)) + ") — FINGER ON EXIT"
                mentorAdviceColor := color.red

            else if rsiBearDiv and profitATR > 0.3
                mentorAdvice      := "RSI DIVERGING — HIDDEN WEAKNESS, TIGHTEN STOP"
                mentorAdviceColor := color.orange

            else if (volDrying or adxFalling) and profitATR > 0.2
                mentorAdvice      := "MOMENTUM FADING — TRAIL NOW " + str.tostring(math.round(mTrailingStop, 2)) + " · TIGHTEN TOWARD ~" + str.tostring(math.round(close - atrVal * 0.3, 2))
                mentorAdviceColor := color.orange

            else if structureMixed
                mentorAdvice      := "5M MIXED — REDUCE SIZE, WATCH VWAP"
                mentorAdviceColor := color.yellow

            else if isPowerHour and profitATR > 0
                mentorAdvice      := "POWER HOUR — LOCK IN PROFIT, DO NOT HOLD LONG"
                mentorAdviceColor := color.orange

            else if isLunchWindow
                mentorAdvice      := "LUNCH ZONE — TRIM AND TIGHTEN, NO NEW RISK"
                mentorAdviceColor := color.yellow

            else if mentorBiasNote != "OPEN SPACE" and mentorBiasNote != "NONE"
                mentorAdvice      := mentorBiasNote + " — WATCH REACTION AT THIS LEVEL"
                mentorAdviceColor := color.orange

            else if callSupportScore >= 6 and adxRising and volForCall
                mentorAdvice      := "STRONG MOMENTUM — LET IT RUN, TREND ACCELERATING"
                mentorAdviceColor := color.lime

            else if higherHigh and higherLow and structureBull
                mentorAdvice      := "HOLD — STRUCTURE PERFECT, HIGHER HIGHS FORMING"
                mentorAdviceColor := color.lime

            else if rsiBullDiv
                mentorAdvice      := "HOLD — RSI BULL DIVERGENCE (HIDDEN STRENGTH)"
                mentorAdviceColor := color.lime

            else if callSupportScore >= 4
                mentorAdvice      := "HOLD — CONDITIONS SUPPORT CALLS (" + str.tostring(callSupportScore) + "/8)"
                mentorAdviceColor := color.lime

            else
                mentorAdvice      := "HOLD — MONITORING, STOP AT " + str.tostring(math.round(mTrailingStop, 2))
                mentorAdviceColor := color.lime

        if mentorDir == -1

            if putTrailStopHit
                mentorAdvice      := "TRAIL STOP HIT — EXIT ALL NOW"
                mentorAdviceColor := color.lime

            else if drawdownATR >= mentorHardFailATR and structureBull and volAgainstPut
                mentorAdvice      := "CONFIRMED FAILURE — STRUCTURE + VOLUME AGAINST, EXIT"
                mentorAdviceColor := color.lime

            else if orbFailShort and not belowT1
                mentorAdvice      := "ORB FAILED TO HOLD — EXIT PUTS FAST"
                mentorAdviceColor := color.lime

            else if not trendBear and structureBull and aboveVWAP and belowT1
                mentorAdvice      := "TREND REVERSAL CONFIRMED — EXIT ALL PUTS"
                mentorAdviceColor := color.lime

            else if volAgainstPut and higherLow and belowT1
                mentorAdvice      := "HEAVY BUY VOLUME + HIGHER LOW — EXIT"
                mentorAdviceColor := color.lime

            else if rsiVal <= 22
                mentorAdvice      := "RSI EXTREME (" + str.tostring(math.round(rsiVal, 0)) + ") — EXIT NOW"
                mentorAdviceColor := color.lime

            else if belowT3
                mentorAdvice      := "T3 HIT — TAKE FULL PROFIT, EXCELLENT TRADE"
                mentorAdviceColor := color.red

            else if belowT2 and (rsiVal <= 30 or rsiBullDiv or isPowerHour)
                mentorAdvice      := "T2 HIT + EXHAUSTION SIGNS — EXIT ALL HERE"
                mentorAdviceColor := color.red

            else if belowT2 and not mTrimDone
                mentorAdvice      := "T2 HIT — TAKE 50-75%, TRAIL REST TO T1"
                mentorAdviceColor := color.red

            else if belowT2
                mentorAdvice      := "BELOW T2 — TRAIL STOP, AIM FOR T3"
                mentorAdviceColor := color.red

            else if nearT2Short
                mentorAdvice      := "NEAR T2 (" + str.tostring(math.round(mT2, 2)) + ") — PLAN YOUR EXIT NOW"
                mentorAdviceColor := color.red

            else if belowT1 and (rsiVal <= 32 or isLunchWindow)
                mentorAdvice      := "BELOW T1 + " + (rsiVal <= 32 ? "RSI LOW" : "LUNCH") + " — TAKE PROFITS NOW"
                mentorAdviceColor := color.yellow

            else if belowT1 and not mTrimDone
                mentorAdvice      := "T1 HIT — TAKE PARTIAL + MOVE STOP TO ENTRY"
                mentorAdviceColor := color.red

            else if belowT1
                mentorAdvice      := "BELOW T1 — TRAILING STOP ACTIVE, HOLD FOR T2"
                mentorAdviceColor := color.red

            else if nearT1Short
                mentorAdvice      := "APPROACHING T1 (" + str.tostring(math.round(mT1, 2)) + ") — GET READY TO TRIM"
                mentorAdviceColor := color.red

            else if mentorOrbBreakShort and adxRising and volForPut
                mentorAdvice      := "ORB BREAKDOWN CONFIRMED — LET IT RUN TO T1"
                mentorAdviceColor := color.red

            else if nearStopS
                mentorAdvice      := "NEAR STOP (" + str.tostring(math.round(mTrailingStop, 2)) + ") — FINGER ON EXIT"
                mentorAdviceColor := color.lime

            else if rsiBullDiv and profitATR > 0.3
                mentorAdvice      := "RSI DIVERGING — HIDDEN STRENGTH, TIGHTEN STOP"
                mentorAdviceColor := color.orange

            else if (volDrying or adxFalling) and profitATR > 0.2
                mentorAdvice      := "MOMENTUM FADING — TRAIL NOW " + str.tostring(math.round(mTrailingStop, 2)) + " · TIGHTEN TOWARD ~" + str.tostring(math.round(close + atrVal * 0.3, 2))
                mentorAdviceColor := color.orange

            else if structureMixed
                mentorAdvice      := "5M MIXED — REDUCE SIZE, WATCH VWAP"
                mentorAdviceColor := color.yellow

            else if isPowerHour and profitATR > 0
                mentorAdvice      := "POWER HOUR — LOCK IN PROFIT, DO NOT HOLD LONG"
                mentorAdviceColor := color.orange

            else if isLunchWindow
                mentorAdvice      := "LUNCH ZONE — TRIM AND TIGHTEN, NO NEW RISK"
                mentorAdviceColor := color.yellow

            else if mentorBiasNote != "OPEN SPACE" and mentorBiasNote != "NONE"
                mentorAdvice      := mentorBiasNote + " — WATCH REACTION AT THIS LEVEL"
                mentorAdviceColor := color.orange

            else if putSupportScore >= 6 and adxRising and volForPut
                mentorAdvice      := "STRONG MOMENTUM — LET IT RUN, TREND ACCELERATING"
                mentorAdviceColor := color.red

            else if lowerHigh and lowerLow and structureBear
                mentorAdvice      := "HOLD — STRUCTURE PERFECT, LOWER LOWS FORMING"
                mentorAdviceColor := color.red

            else if rsiBearDiv
                mentorAdvice      := "HOLD — RSI BEAR DIVERGENCE (HIDDEN WEAKNESS)"
                mentorAdviceColor := color.red

            else if putSupportScore >= 4
                mentorAdvice      := "HOLD — CONDITIONS SUPPORT PUTS (" + str.tostring(putSupportScore) + "/8)"
                mentorAdviceColor := color.red

            else
                mentorAdvice      := "HOLD — MONITORING, STOP AT " + str.tostring(math.round(mTrailingStop, 2))
                mentorAdviceColor := color.red

//=========================
// PLOTS
//=========================
// display: chart + Data Window only — no colored tags on the right price scale (VWAP also drawn as line + label below)
plot(showVWAP  ? vwapVal : na, "VWAP Price", color=color.new(vwapPlotColor, 100), linewidth=1, display=display.pane + display.data_window)

var line vwapFlatLine = na
if showVWAP
    int leftBars = 500
    if na(vwapFlatLine)
        vwapFlatLine := line.new(math.max(bar_index - leftBars, 0), vwapVal, bar_index, vwapVal, extend=extend.right, color=vwapPlotColor, width=2, style=line.style_solid)
    else
        line.set_xy1(vwapFlatLine, math.max(bar_index - leftBars, 0), vwapVal)
        line.set_xy2(vwapFlatLine, bar_index, vwapVal)
        line.set_extend(vwapFlatLine, extend.right)
        line.set_color(vwapFlatLine, vwapPlotColor)
        line.set_width(vwapFlatLine, 2)
else
    if not na(vwapFlatLine)
        line.delete(vwapFlatLine)
        vwapFlatLine := na

var label vwapTextLabel = na
if showVWAP
    if na(vwapTextLabel)
        vwapTextLabel := label.new(math.max(bar_index - 20, 0), vwapVal, "──── VWAP ────", style=label.style_none, textcolor=vwapPlotColor, size=size.small)
    else
        label.set_xy(vwapTextLabel, math.max(bar_index - 20, 0), vwapVal)
        label.set_text(vwapTextLabel, "──── VWAP ────")
        label.set_textcolor(vwapTextLabel, vwapPlotColor)
else
    if not na(vwapTextLabel)
        label.delete(vwapTextLabel)
        vwapTextLabel := na

plot(showEMA9  ? ema9  : na, "EMA9",  color=ema9PlotColor, linewidth=1, display=display.pane + display.data_window)
plot(showEMA20 ? ema20 : na, "EMA20", color=ema20PlotColor, linewidth=2, display=display.pane + display.data_window)

// v30: VAH / POC / VAL horizontal rays (line objects — flat when levels shift, unlike plot()).
var line svpVAHLine = na
var line svpPOCLine = na
var line svpVALLine = na
var label svpVAHLabel = na
var label svpPOCLabel = na
var label svpVALLabel = na

svpShow = showSVPLevels and useSVP and svpValid
if svpShow
    int leftBarsSVP = 400
    if not na(vahPrice)
        if na(svpVAHLine)
            svpVAHLine := line.new(math.max(bar_index - leftBarsSVP, 0), vahPrice, bar_index, vahPrice, extend=extend.right, color=svpVAHPlotColor, width=2, style=line.style_dashed)
        else
            line.set_xy1(svpVAHLine, math.max(bar_index - leftBarsSVP, 0), vahPrice)
            line.set_xy2(svpVAHLine, bar_index, vahPrice)
            line.set_extend(svpVAHLine, extend.right)
            line.set_color(svpVAHLine, svpVAHPlotColor)
        if na(svpVAHLabel)
            svpVAHLabel := label.new(math.max(bar_index - 15, 0), vahPrice, "── VAH ──", style=label.style_none, textcolor=svpVAHPlotColor, size=size.small)
        else
            label.set_xy(svpVAHLabel, math.max(bar_index - 15, 0), vahPrice)
            label.set_textcolor(svpVAHLabel, svpVAHPlotColor)
    if not na(pocPrice)
        if na(svpPOCLine)
            svpPOCLine := line.new(math.max(bar_index - leftBarsSVP, 0), pocPrice, bar_index, pocPrice, extend=extend.right, color=svpPOCPlotColor, width=3, style=line.style_solid)
        else
            line.set_xy1(svpPOCLine, math.max(bar_index - leftBarsSVP, 0), pocPrice)
            line.set_xy2(svpPOCLine, bar_index, pocPrice)
            line.set_extend(svpPOCLine, extend.right)
            line.set_color(svpPOCLine, svpPOCPlotColor)
        if na(svpPOCLabel)
            svpPOCLabel := label.new(math.max(bar_index - 15, 0), pocPrice, "── POC ──", style=label.style_none, textcolor=svpPOCPlotColor, size=size.small)
        else
            label.set_xy(svpPOCLabel, math.max(bar_index - 15, 0), pocPrice)
            label.set_textcolor(svpPOCLabel, svpPOCPlotColor)
    if not na(valPrice)
        if na(svpVALLine)
            svpVALLine := line.new(math.max(bar_index - leftBarsSVP, 0), valPrice, bar_index, valPrice, extend=extend.right, color=svpVALPlotColor, width=2, style=line.style_dashed)
        else
            line.set_xy1(svpVALLine, math.max(bar_index - leftBarsSVP, 0), valPrice)
            line.set_xy2(svpVALLine, bar_index, valPrice)
            line.set_extend(svpVALLine, extend.right)
            line.set_color(svpVALLine, svpVALPlotColor)
        if na(svpVALLabel)
            svpVALLabel := label.new(math.max(bar_index - 15, 0), valPrice, "── VAL ──", style=label.style_none, textcolor=svpVALPlotColor, size=size.small)
        else
            label.set_xy(svpVALLabel, math.max(bar_index - 15, 0), valPrice)
            label.set_textcolor(svpVALLabel, svpVALPlotColor)
else
    if not na(svpVAHLine)
        line.delete(svpVAHLine)
        svpVAHLine := na
    if not na(svpPOCLine)
        line.delete(svpPOCLine)
        svpPOCLine := na
    if not na(svpVALLine)
        line.delete(svpVALLine)
        svpVALLine := na
    if not na(svpVAHLabel)
        label.delete(svpVAHLabel)
        svpVAHLabel := na
    if not na(svpPOCLabel)
        label.delete(svpPOCLabel)
        svpPOCLabel := na
    if not na(svpVALLabel)
        label.delete(svpVALLabel)
        svpVALLabel := na

// (Entry markers now drawn via labels in the LAST 10 MARKERS section — no plotshape needed.)

plot(tradeActive and tradeDir == 1  ? signalLow  : na, "Call Invalidation", color=color.new(color.red,   20), linewidth=2, style=plot.style_linebr, display=display.pane + display.data_window)
plot(tradeActive and tradeDir == -1 ? signalHigh : na, "Put Invalidation",  color=color.new(color.green, 20), linewidth=2, style=plot.style_linebr, display=display.pane + display.data_window)

bgcolor(na)

//=========================
// LAST 10 MARKERS (labels)
//=========================
pushLastNPair(label[] labArr, line[] lnArr, label l, line ln, int maxN) =>
    array.unshift(labArr, l)
    array.unshift(lnArr,  ln)
    if array.size(labArr) > maxN
        oldL = array.pop(labArr)
        if not na(oldL)
            label.delete(oldL)
        oldLn = array.pop(lnArr)
        if not na(oldLn)
            line.delete(oldLn)

entryMarksMax = 10
exitMarksMax  = 10

var label[] entryMarks = array.new_label()
var line[]  entryMarkLines = array.new_line()
var label[] exitMarks = array.new_label()
var line[]  exitMarkLines = array.new_line()

// "Ray" height so text stays readable; rayGap keeps a visible air gap so the line does not sit on the wick/body.
markOffset = math.max(atrVal * 0.6, candleRange * 1.2, syminfo.mintick * 25)
rayGap = math.max(syminfo.mintick * 4, atrVal * 0.08, candleRange * 0.12)

// Entry markers
if plotStrongCall or plotResumeCall
    scoreNum = math.round(callConfluenceScore * 10) / 10
    scoreTxt = " (" + str.tostring(scoreNum) + ")"
    txt = (plotStrongCall ? "▲\nSTRONG CALLS" : "▲\nCALLS") + scoreTxt
    txtClr = plotStrongCall ? color.new(color.green, 0) : color.new(color.lime, 0)
    yTip = low - rayGap
    yTxt = low - markOffset
    lnCol = color.new(txtClr, 35)
    ln = line.new(bar_index, yTip, bar_index, yTxt, xloc=xloc.bar_index, extend=extend.none, color=lnCol, width=2, style=line.style_solid)
    l = label.new(bar_index, yTxt, txt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=txtClr, color=color.new(color.black, 100), size=size.small)
    pushLastNPair(entryMarks, entryMarkLines, l, ln, entryMarksMax)

if plotStrongPut or plotResumePut
    scoreNum = math.round(putConfluenceScore * 10) / 10
    scoreTxt = " (" + str.tostring(scoreNum) + ")"
    txt = (plotStrongPut ? "▼\nSTRONG PUTS" : "▼\nPUTS") + scoreTxt
    txtClr = plotStrongPut ? color.new(color.red, 0) : color.new(color.maroon, 0)
    yTip = high + rayGap
    yTxt = high + markOffset
    lnCol = color.new(txtClr, 35)
    ln = line.new(bar_index, yTip, bar_index, yTxt, xloc=xloc.bar_index, extend=extend.none, color=lnCol, width=2, style=line.style_solid)
    l = label.new(bar_index, yTxt, txt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=txtClr, color=color.new(color.black, 100), size=size.small)
    pushLastNPair(entryMarks, entryMarkLines, l, ln, entryMarksMax)

// Exit markers
if exitStopLong or exitSwingLong or exitSoftVisLong
    // Exit labels for confirmed exits (STOP/SWING/SOFT). Live STOP flash is handled separately on the last bar.
    txt = exitStopLong ? "✕\nSTOP EXIT" : exitSwingLong ? "✕\nSWING EXIT" : "✕\nSOFT EXIT"
    txtClr = color.new(color.red, 0)
    yTip = high + rayGap
    yTxt = high + markOffset
    lnCol = color.new(txtClr, 35)
    ln = line.new(bar_index, yTip, bar_index, yTxt, xloc=xloc.bar_index, extend=extend.none, color=lnCol, width=2, style=line.style_solid)
    l = label.new(bar_index, yTxt, txt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=txtClr, color=color.new(color.black, 100), size=size.small)
    pushLastNPair(exitMarks, exitMarkLines, l, ln, exitMarksMax)

if exitStopShort or exitSwingShort or exitSoftVisShort
    txt = exitStopShort ? "✕\nSTOP EXIT" : exitSwingShort ? "✕\nSWING EXIT" : "✕\nSOFT EXIT"
    txtClr = color.new(color.lime, 0)
    yTip = low - rayGap
    yTxt = low - markOffset
    lnCol = color.new(txtClr, 35)
    ln = line.new(bar_index, yTip, bar_index, yTxt, xloc=xloc.bar_index, extend=extend.none, color=lnCol, width=2, style=line.style_solid)
    l = label.new(bar_index, yTxt, txt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=txtClr, color=color.new(color.black, 100), size=size.small)
    pushLastNPair(exitMarks, exitMarkLines, l, ln, exitMarksMax)

// Mentor SL + T1: horizontal lines (line objects). plot() would connect bar-to-bar and slope when stop/T1 change.
mentorSLCol = mentorStopRayColor
mentorT1Col = mentorT1RayColor
mentorT2Col = mentorT2RayColor
mentorT3Col = mentorT3RayColor
if showMentorStopT1 and mentorActive and not na(mentorLineAnchorMs)
    if not na(stopForDisplay)
        if na(mentorSLPlotLine)
            mentorSLPlotLine := line.new(mentorLineAnchorMs, stopForDisplay, time, stopForDisplay, xloc=xloc.bar_time, extend=extend.right, color=mentorSLCol, width=3, style=line.style_solid)
        else
            line.set_xy1(mentorSLPlotLine, mentorLineAnchorMs, stopForDisplay)
            line.set_xy2(mentorSLPlotLine, time, stopForDisplay)
            line.set_extend(mentorSLPlotLine, extend.right)
            line.set_color(mentorSLPlotLine, mentorSLCol)
            line.set_width(mentorSLPlotLine, 3)
    else if not na(mentorSLPlotLine)
        line.delete(mentorSLPlotLine)
        mentorSLPlotLine := na
    if not na(mT1)
        if na(mentorT1PlotLine)
            mentorT1PlotLine := line.new(mentorLineAnchorMs, mT1, time, mT1, xloc=xloc.bar_time, extend=extend.right, color=mentorT1Col, width=3, style=line.style_solid)
        else
            line.set_xy1(mentorT1PlotLine, mentorLineAnchorMs, mT1)
            line.set_xy2(mentorT1PlotLine, time, mT1)
            line.set_extend(mentorT1PlotLine, extend.right)
            line.set_color(mentorT1PlotLine, mentorT1Col)
            line.set_width(mentorT1PlotLine, 3)
    else if not na(mentorT1PlotLine)
        line.delete(mentorT1PlotLine)
        mentorT1PlotLine := na
    if not na(mT2)
        if na(mentorT2PlotLine)
            mentorT2PlotLine := line.new(mentorLineAnchorMs, mT2, time, mT2, xloc=xloc.bar_time, extend=extend.right, color=mentorT2Col, width=3, style=line.style_solid)
        else
            line.set_xy1(mentorT2PlotLine, mentorLineAnchorMs, mT2)
            line.set_xy2(mentorT2PlotLine, time, mT2)
            line.set_extend(mentorT2PlotLine, extend.right)
            line.set_color(mentorT2PlotLine, mentorT2Col)
            line.set_width(mentorT2PlotLine, 3)
    else if not na(mentorT2PlotLine)
        line.delete(mentorT2PlotLine)
        mentorT2PlotLine := na
    if not na(mT3)
        if na(mentorT3PlotLine)
            mentorT3PlotLine := line.new(mentorLineAnchorMs, mT3, time, mT3, xloc=xloc.bar_time, extend=extend.right, color=mentorT3Col, width=3, style=line.style_solid)
        else
            line.set_xy1(mentorT3PlotLine, mentorLineAnchorMs, mT3)
            line.set_xy2(mentorT3PlotLine, time, mT3)
            line.set_extend(mentorT3PlotLine, extend.right)
            line.set_color(mentorT3PlotLine, mentorT3Col)
            line.set_width(mentorT3PlotLine, 3)
    else if not na(mentorT3PlotLine)
        line.delete(mentorT3PlotLine)
        mentorT3PlotLine := na
else
    if not na(mentorSLPlotLine)
        line.delete(mentorSLPlotLine)
        mentorSLPlotLine := na
    if not na(mentorT1PlotLine)
        line.delete(mentorT1PlotLine)
        mentorT1PlotLine := na
    if not na(mentorT2PlotLine)
        line.delete(mentorT2PlotLine)
        mentorT2PlotLine := na
    if not na(mentorT3PlotLine)
        line.delete(mentorT3PlotLine)
        mentorT3PlotLine := na

// ORB H/L: mentor dashboard only (ORB H/L row) — not drawn on chart.

//=========================
// TOP DASHBOARD
//=========================
var table dashTop = table.new(position.top_right, 2, 13, bgcolor=dashTableBg, border_color=dashTableBorder, border_width=1)
fcTop(col, row, txt, clr) => table.cell(dashTop, col, row, txt, text_color=clr, text_size=dashTextSize)

trendText      = trendBull     ? "BULL"    : trendBear     ? "BEAR"    : "NEUTRAL"
trendColor     = trendBull     ? color.lime : trendBear    ? color.red  : color.gray
structureText  = structureBull ? "BULL"    : structureBear ? "BEAR"    : "MIXED"
structureColor = structureBull ? color.lime : structureBear ? color.red : color.gray

// SIGNAL row = trade lifecycle (matches chart exits), then entry bar BUY, then context WATCH — not a duplicate "last alert" ticker.
hasEnterPlot = plotStrongCall or plotResumeCall or plotStrongPut or plotResumePut
actionEnterThisBar = hasEnterPlot ? (plotStrongCall and setupTypeLong == "BOUNCE" ? "BOUNCE CALLS — BUY NOW" : plotResumeCall and setupTypeLong == "BOUNCE" ? "BOUNCE CALLS" : plotStrongPut and setupTypeShort == "REJECTION" ? "REJECTION PUTS — BUY NOW" : plotResumePut and setupTypeShort == "REJECTION" ? "REJECTION PUTS" : plotStrongCall ? "STRONG CALLS — BUY NOW" : plotResumeCall ? "BUY CALLS NOW" : plotStrongPut ? "STRONG PUTS — BUY NOW" : "BUY PUTS NOW") : ""
actionEnterColorThisBar = hasEnterPlot ? (plotStrongCall and setupTypeLong == "BOUNCE" ? color.yellow : plotResumeCall and setupTypeLong == "BOUNCE" ? color.yellow : plotStrongPut and setupTypeShort == "REJECTION" ? color.purple : plotResumePut and setupTypeShort == "REJECTION" ? color.purple : plotStrongCall ? color.lime : plotResumeCall ? color.green : plotStrongPut ? color.red : color.maroon) : color.gray

actionStr = actualExitLong ? "SELL CALLS" : actualExitShort ? "SELL PUTS" : hasEnterPlot ? actionEnterThisBar : tradeActive and tradeDir == 1 ? (tradeState == "TRIM CALL" ? "TRIM CALLS" : "HOLD CALLS") : tradeActive and tradeDir == -1 ? (tradeState == "TRIM PUT" ? "TRIM PUTS" : "HOLD PUTS") : bounceWatchLong ? "WATCHING BOUNCE CALLS" : rejectionWatchShort ? "WATCHING REJECTION PUTS" : watchLongOnly ? "WATCHING FOR CALLS" : watchShortOnly ? "WATCHING FOR PUTS" : regimeStr == "AVOID" ? "DON'T TRADE" : "NOTHING YET"
actionColor = actualExitLong ? color.red : actualExitShort ? color.lime : hasEnterPlot ? actionEnterColorThisBar : tradeActive and tradeDir == 1 ? (tradeState == "TRIM CALL" ? color.yellow : color.green) : tradeActive and tradeDir == -1 ? (tradeState == "TRIM PUT" ? color.yellow : color.maroon) : bounceWatchLong ? color.yellow : rejectionWatchShort ? color.purple : watchLongOnly ? color.aqua : watchShortOnly ? color.orange : regimeStr == "AVOID" ? color.orange : color.gray

if showDashboard
    fcTop(0, 0,  "CONDITION",      dashKeyTextColor)
    fcTop(1, 0,  "STATUS",         dashKeyTextColor)
    fcTop(0, 1,  "Trend (15m)",    dashKeyTextColor)
    fcTop(1, 1,  trendText,        trendColor)
    fcTop(0, 2,  "Structure (5m)", dashKeyTextColor)
    fcTop(1, 2,  structureText,    structureColor)
    fcTop(0, 3,  "VWAP",           dashKeyTextColor)
    fcTop(1, 3,  str.tostring(math.round(vwapVal, 2)) + " (" + (aboveVWAP ? "ABOVE" : "BELOW") + ")", aboveVWAP ? color.lime : color.red)
    fcTop(0, 4,  "Volume",         dashKeyTextColor)
    fcTop(1, 4,  volumeDashStr,    volumeColor)
    fcTop(0, 5,  "ADX",            dashKeyTextColor)
    fcTop(1, 5,  str.tostring(math.round(adxVal, 1)) + " (" + adxState + ")", adxVal < 15 ? color.gray : adxVal < 25 ? color.yellow : adxVal < 40 ? color.lime : color.green)
    fcTop(0, 6,  "Regime",         dashKeyTextColor)
    fcTop(1, 6,
         regimeStr == "TREND" ? "TRADE" : regimeStr == "RANGE" ? "NEUTRAL" : regimeStr == "AVOID" ? "DON'T TRADE" : regimeStr,
         regimeColorDash)
    fcTop(0, 7,  "Bias (15m·5m)",  dashKeyTextColor)
    fcTop(1, 7,
         biasAlignedLong ? "GOOD FOR CALLS" : biasAlignedShort ? "GOOD FOR PUTS" : biasConflict ? "DON'T TRADE" : "MIXED",
         biasAlignedLong ? color.lime : biasAlignedShort ? color.red : biasConflict ? color.orange : color.gray)
    fcTop(0, 8,  "SIGNAL",    dashKeyTextColor)
    fcTop(1, 8,  actionStr,   actionColor)
    fcTop(0, 9,  "RSI",            dashKeyTextColor)
    fcTop(1, 9,  str.tostring(math.round(rsiVal, 1)) + " (" + rsiState + ")", rsiVal > 50 ? color.lime : color.red)
    // v31 confluence score row — shows whichever direction is currently stronger.
    if showConfluenceDebug
        dominantSide  = callConfluenceScore >= putConfluenceScore ? "CALL" : "PUT"
        dominantScore = callConfluenceScore >= putConfluenceScore ? callConfluenceScore : putConfluenceScore
        qualityColor  = dominantScore >= scoreStrongMin ? (dominantSide == "CALL" ? color.lime : color.red) :
                         dominantScore >= scoreFireMin   ? (dominantSide == "CALL" ? color.green : color.maroon) :
                         color.gray
        qualityLabel  = (dominantScore >= scoreStrongMin ? "STRONG " : dominantScore >= scoreFireMin ? "OK " : "WEAK ") + dominantSide + " " + str.tostring(math.round(dominantScore * 10) / 10) + "/10"
        fcTop(0, 10, "QUALITY",     dashKeyTextColor)
        fcTop(1, 10, qualityLabel,  qualityColor)

//=========================
// MENTOR DASHBOARD
//=========================
// v30: 17 rows normally (SESSION ends at row 16 after adding 3 SVP rows), +2 when Mentor Debug on.
mentorTableRows = showMentorDebug ? 19 : 17
var table dashMentor = table.new(position.bottom_right, 2, mentorTableRows, bgcolor=dashTableBg, border_color=dashTableBorder, border_width=1)
fcM(col, row, txt, clr) =>
    table.cell(dashMentor, col, row, txt, text_color=clr, text_size=dashTextSize, text_halign=col == 0 ? text.align_right : text.align_left, text_valign=text.align_top)

mentorStrikeLbl(f) =>
    float r = math.round(f, 2)
    r == math.round(r, 0) ? str.tostring(int(r)) : str.tostring(r)
mentorLegChr = isCall ? "C" : isPut ? "P" : "?"
mentorUnderlyingLbl = str.tostring(math.round(mentorEntry, 2))
// Whole strike: "681C @ 679.34". Decimal underlying lock: "679.31 CALL" (no separate option strike box).
mEntryDisp = not mentorActive or na(mentorEntry) or mentorLegChr == "?" ? "--" : strikeOnlyMode ? mentorStrikeLbl(optionStrike) + mentorLegChr + " @ " + mentorUnderlyingLbl : mentorUnderlyingLbl + (isCall ? " CALL" : " PUT")
mStopDisp  = na(stopForDisplay) ? "--" : str.tostring(math.round(stopForDisplay, 2)) + (inMentorBuffer and not breakEvenArmed ? " (init)" : "")
mT1Disp    = na(mT1) ? "--" : str.tostring(math.round(mT1, 2))
mT2Disp    = na(mT2) ? "--" : str.tostring(math.round(mT2, 2))
mT3Disp    = na(mT3) ? "--" : str.tostring(math.round(mT3, 2))
mRiskDisp  = not mentorActive or na(mentorEntry) or na(stopForDisplay) ? "--" : "$" + str.tostring(math.round(math.abs(mentorEntry - stopForDisplay), 2))
mPnLRaw    = not mentorActive or na(mentorEntry) ? 0.0 : mentorDir == 1 ? close - mentorEntry : mentorEntry - close
mPnLDisp   = not mentorActive or na(mentorEntry) ? "--" : (mPnLRaw >= 0 ? "+" : "") + "$" + str.tostring(math.round(math.abs(mPnLRaw), 2))
mPnLColor  = not mentorActive or na(mentorEntry) ? color.gray : mPnLRaw >= 0 ? color.lime : color.red
mDirColor  = mentorDir == 1 ? color.lime : mentorDir == -1 ? color.red : color.gray
orbDisp    = na(orbHigh) or na(orbLow) ? "--" : str.tostring(math.round(orbHigh, 2)) + " / " + str.tostring(math.round(orbLow, 2))
pdDisp     = na(prevHigh) or na(prevLow) ? "--" : str.tostring(math.round(prevHigh, 2)) + " / " + str.tostring(math.round(prevLow, 2))
tdDisp     = na(dayHigh) or na(dayLow) ? "--" : str.tostring(math.round(dayHigh, 2)) + " / " + str.tostring(math.round(dayLow, 2))
// v30 SVP display
vahDisp    = not svpValid or na(vahPrice) ? "--" : str.tostring(math.round(vahPrice, 2))
pocDisp    = not svpValid or na(pocPrice) ? "--" : str.tostring(math.round(pocPrice, 2))
valDisp    = not svpValid or na(valPrice) ? "--" : str.tostring(math.round(valPrice, 2))
biasColor  = mentorBiasNote == "OPEN SPACE" ? color.lime : mentorBiasNote == "NONE" ? color.gray : color.orange
scoreDisp  = not mentorActive ? "--" : mentorDir == 1 ? str.tostring(callSupportScore) + " for / " + str.tostring(callOppositionScore) + " against" : str.tostring(putSupportScore) + " for / " + str.tostring(putOppositionScore) + " against"
scoreColor = not mentorActive ? color.gray : mentorDir == 1 ? (callSupportScore > callOppositionScore ? color.lime : color.red) : (putSupportScore > putOppositionScore ? color.lime : color.red)

if showDashboard
    fcM(0, 0,  "MENTOR",     dashKeyTextColor)
    fcM(1, 0,  mentorAdvice, mentorAdviceColor)
    fcM(0, 1,  "MY TRADE",   dashKeyTextColor)
    fcM(1, 1,  mEntryDisp,   mDirColor)
    fcM(0, 2,  "P&L",        dashKeyTextColor)
    fcM(1, 2,  mPnLDisp,     mPnLColor)
    fcM(0, 3,  "STOP",       dashKeyTextColor)
    fcM(1, 3,  mStopDisp,    color.yellow)
    fcM(0, 4,  "T1",         dashKeyTextColor)
    fcM(1, 4,  mT1Disp,      color.lime)
    fcM(0, 5,  "T2",         dashKeyTextColor)
    fcM(1, 5,  mT2Disp,      color.lime)
    fcM(0, 6,  "T3",         dashKeyTextColor)
    fcM(1, 6,  mT3Disp,      adxVal >= strongTrendADX ? color.lime : color.gray)
    fcM(0, 7,  "RISK/SHARE", dashKeyTextColor)
    fcM(1, 7,  mRiskDisp,    color.yellow)
    fcM(0, 8,  "SCORE",      dashKeyTextColor)
    fcM(1, 8,  scoreDisp,    scoreColor)
    fcM(0, 9,  "BIAS",       dashKeyTextColor)
    fcM(1, 9,  mentorBiasNote, biasColor)
    fcM(0, 10, "ORB H/L",    dashKeyTextColor)
    fcM(1, 10, orbDisp,      color.orange)
    fcM(0, 11, "PDH/PDL",    dashKeyTextColor)
    fcM(1, 11, pdDisp,       color.fuchsia)
    fcM(0, 12, "TDH/TDL",    dashKeyTextColor)
    fcM(1, 12, tdDisp,       color.aqua)
    // v30 SVP rows
    fcM(0, 13, "VAH",        dashKeyTextColor)
    fcM(1, 13, vahDisp,      svpVAHPlotColor)
    fcM(0, 14, "POC",        dashKeyTextColor)
    fcM(1, 14, pocDisp,      svpPOCPlotColor)
    fcM(0, 15, "VAL",        dashKeyTextColor)
    fcM(1, 15, valDisp,      svpVALPlotColor)
    fcM(0, 16, "SESSION",    dashKeyTextColor)
    fcM(1, 16, sessionLineMentor,  timeWarningColor)
    if showMentorDebug
        fcM(0, 17, "DBG BE", dashKeyTextColor)
        fcM(1, 17, str.tostring(breakEvenArmed), breakEvenArmed ? color.orange : color.gray)
        fcM(0, 18, "DBG HIT", dashKeyTextColor)
        fcM(1, 18, str.tostring(putTrailStopHit or callTrailStopHit), (putTrailStopHit or callTrailStopHit) ? color.red : color.gray)

//=========================
// ALERTS
//=========================
alertcondition(plotStrongCall and setupTypeLong != "BOUNCE", "Strong Calls", "Strong Calls fired")
alertcondition(plotResumeCall and setupTypeLong != "BOUNCE", "Calls",        "Calls fired")
alertcondition(plotStrongPut and setupTypeShort != "REJECTION",  "Strong Puts",  "Strong Puts fired")
alertcondition(plotResumePut and setupTypeShort != "REJECTION",  "Puts",         "Puts fired")
alertcondition(plotStrongCall and setupTypeLong == "BOUNCE", "Bounce Calls Strong", "Strong Bounce Calls fired — counter VWAP")
alertcondition(plotResumeCall and setupTypeLong == "BOUNCE", "Bounce Calls", "Bounce Calls fired — counter VWAP")
alertcondition(plotStrongPut and setupTypeShort == "REJECTION", "Rejection Puts Strong", "Strong Rejection Puts fired — counter VWAP")
alertcondition(plotResumePut and setupTypeShort == "REJECTION", "Rejection Puts", "Rejection Puts fired — counter VWAP")
alertcondition(tfConflict,     "TF CONFLICT",  "Timeframe conflict — wait for alignment")
````
