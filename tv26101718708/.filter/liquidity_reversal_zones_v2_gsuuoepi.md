# Liquidity Reversal Zones v2

- url: https://www.tradingview.com/script/gsuuoEPi-Liquidity-Reversal-Zones-v2/
- type: indicator
- pine_id: PUB;e0f2ae2c49994b6096443d8ce7eeb6a4
- version: 7.0

## Description

Liquidity Reversal Zones [Composite Score] v2

Liquidity Reversal Zones is a composite reversal indicator designed to identify potential long and short reversal areas after liquidity sweeps, market overextension, and order-flow exhaustion.

The indicator builds one adaptive score from multiple market factors, including:

- Liquidity sweeps of prior highs/lows, pivot levels, rolling extremes, equal highs/lows, and round numbers
- Overbought/oversold valuation using Z-score, RSI, Stochastic, Bollinger %B, MFI, and flow pressure
- CVD, OBV, volume intensity, relative volume, and absorption
- Bullish/bearish divergence from CVD, RSI, and OBV
- Aggregated crypto Open Interest with price/OI quadrant logic
- VWAP, Anchored VWAP, volume profile POC/VAH/VAL, and level retest memory
- Higher-timeframe bias, volatility regime, ADX trend filter, and chop filter
- Optional funding-rate context for crypto markets

Positive conditions create LONG reversal zones when price sweeps liquidity below key levels and shows oversold/reversal evidence. Negative conditions create SHORT reversal zones when price sweeps liquidity above key levels and shows overbought/reversal evidence.

The indicator can display:
- Composite score as columns or histogram
- Adaptive or fixed strong/medium thresholds
- Reversal zones directly on the chart
- Zone labels with probability, RR, and capitulation flags
- Target projection and zone POC
- Dashboard with strength, confluence, volume, Open Interest, sweep direction, context, and historical hit-rate

Zones are managed through a lifecycle: Active, Tested, Confirmed, or Mitigated. Nearby zones can be merged automatically.

Alerts are included for long/short zones, strong zones, CVD divergences, and capitulation conditions.

This tool is intended for analytical and educational use. It should be combined with market structure, risk management, and the trader’s own confirmation process.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Composite Liquidity-Reversal-Zone Score — v3 (analytical)
// Synthesizes: OBV+MA, Flow Control Oscillator, Universal Z-Score Valuation, Cumulative Volume Delta,
// Open Interest Suite (Aggregated, COIN), Parkinson Range Oscillator, OBV Traffic Lights, MFI, VVI.
//
// score = Direction(extremity + flow + divergence + sweep + rejection + HTF + funding + basis)
//         × EventGate(sweep + rejection + absorption + wyckoff)
//         × VolumeIntensity × OI-Quadrant × Regime × Context × Chop
// + adaptive thresholds, N-of-M confluence gate, semantic liquidity levels,
// and an analytical zone state life cycle (Active/Tested/Confirmed/Mitigated) with pooling.
// v3 add-ons: true intrabar delta from lower TF, multi-bar reclaim window for sweep, weekly/monthly H/L +
// POC of the previous day as sweep levels, confluence with Order Block & FVG, σ-bands VWAP, Wyckoff spring/upthrust,
// absorption refinement according to Amihud, spot-perp basis shift, context-aware zone confidence,
// and only closed HTF bars mode.
// Positive account = LONG reversal zone (oversold / liquidity taken from below). Negative = SHORT zone.

// v3.18: Open Interest in a common unit Quoted in: COIN for aggregation, delta, Z-score and N-bar trend.
// Independent Context + Flow + Events + OI + HTF; Buy/Sell only enters Flow, weak/contradictory activity fades to 0.
// The concept of Buy/Sell volume is adapted from Volume Delta [hapharmonic] (MPL-2.0).
// v3.19: merge branches - all audit fixes (pools lifecycle, event queues, snapshot in Strict,
// event queues) + v3.18 widgets (Table / Buy/Sell bar) in one file.
//@version=6
indicator("Liquidity Reversal Zones [Composite Score] v3.19", "LRZ Score 3.19", overlay = false,
     max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500, max_bars_back = 500, precision = 2, dynamic_requests = true)

// ============================================================================
// 1. INPUTS
// ============================================================================
gDisp = "Display"
displayStyle = input.string("Columns", "Panel style", options = ["Area", "Columns", "Histogram"], group = gDisp, tooltip = "The visual style of the score oscillator on the bottom panel. Area — filling with a line; Columns — columns; Histogram — a histogram. Affects only the appearance, does not change the logic.")
showSignal   = input.bool(true,  "Signal line", inline="d1", group = gDisp, tooltip = "Show the smoothed (EMA) score line on top of the oscillator - helps to see the direction and fading of the momentum.")
displayWidget = input.string("Table", "Right info widget", options = ["Off", "Table", "Buy/Sell Bar"], group = gDisp,
     tooltip = "Table shows the detailed dashboard. Buy/Sell Bar shows a compact Composite Bias: Sell fills upward from the center and Buy fills downward. Off hides the right-side widget.")
showDash        = displayWidget == "Table"
showPressureBar = displayWidget == "Buy/Sell Bar"
showZones    = input.bool(true,  "Reversal zones on the chart", group = gDisp, tooltip = "Draw reversal zones with boxes. Disabling only hides the boxes — analytics, alerts and webhooks continue to work.")
showThreshZones = input.bool(true, "Thresholds as shaded bands", inline="d4", group = gDisp, tooltip = "Show MEDIUM/STRONG levels as shaded overbought/oversold bars instead of thin lines.")
showStateBG  = input.bool(true,  "Panel State Background", inline="d4", group = gDisp, tooltip = "Subtle panel-background highlighting by market state: capitulation accent and a directional tint in STRONG zones.")
extendBars   = input.int(10, "Zone Extension (bars)", minval = 1, group = gDisp, tooltip = "How far the zone box extends to the right. Higher values draw longer zones and do not affect the logic.")

gCol = "Colors"
cbSafe       = input.bool(false, "Colorblind palette (replaces Long/Short)", group = gCol, tooltip = "Enables a contrasting blue-orange palette instead of the Long/Short native colors for better visibility.")
longInp      = input.color(#00bcd4, "Long / oversold",  inline="c1", group = gCol)
shortInp     = input.color(#2fcd36, "Short / overbought", inline="c1", group = gCol)
accentInp    = input.color(#ff9800, "Accent (volume / capitulation)", group = gCol)
profInp      = input.color(#ffa726, "Profile / POC line", group = gCol)
neutralInp   = input.color(#787b86, "Neutral", inline="c2", group = gCol)
textInp      = input.color(#d1d4dc, "Text", inline="c2", group = gCol)
sigInp       = input.color(#b2b5be, "Signal line", inline="c3", group = gCol)
frameInp     = input.color(#3a3e48, "Table frame", inline="c3", group = gCol)
panelBgInp   = input.color(#0e0f14, "Table background", group = gCol)
colLong  = cbSafe ? color.rgb(33,136,255)  : longInp
colShort = cbSafe ? color.rgb(255,150,0)   : shortInp
colAccent  = accentInp
colProf    = profInp
colNeutral = neutralInp
colText    = textInp
colSig     = sigInp
colFrame   = frameInp
colPanelBg = panelBgInp

gZoneVis = "Zone Visuals"
zoneFillTr   = input.int(82, "Base Fill Transparency", minval=30, maxval=100, group=gZoneVis, tooltip="Base transparency for zone boxes. Higher-confidence zones are filled more densely. Higher values make all zones more transparent; lower values make them denser.")
borderByConf = input.bool(true, "Border Intensity by Confidence", group=gZoneVis, tooltip="Higher-confidence zones receive brighter, thicker borders so stronger analytical setups stand out.")
ageFade      = input.bool(true, "Fade Old Zones by Age", inline="zv2", group=gZoneVis, tooltip="Gradually fades older zones so newer setups remain visually prominent.")
ageFadeBars  = input.int(150, "Range (bars)", minval=20, inline="zv2", group=gZoneVis, tooltip="After how many bars the zone completely fades. ↑ — old zones remain bright longer.")
resolvedFadeBars = input.int(40, "Remove Resolved Zones After (bars)", minval=0, group=gZoneVis, tooltip="Remove confirmed or mitigated zones this many bars after they resolve. 0 keeps them until the Max Active Zones cap removes them.")



gScore = "Score & Thresholds"
threshMode   = input.string("Adaptive", "Threshold mode", options = ["Adaptive", "Fixed"], group = gScore,
     tooltip = "How STRONG/MEDIUM levels are determined. Adaptive uses upper percentiles of the score's recent distribution; Fixed uses the absolute levels below. Adaptive adjusts automatically to symbol volatility.")
prLen        = input.int(300, "Adaptive Lookback", minval = 50, group = gScore, tooltip = "Number of bars used to form the score distribution in Adaptive mode. Higher values make thresholds steadier and slower; lower values make them more responsive.")
strongPct    = input.float(85.0, "STRONG percentile", minval = 50, maxval = 99, group = gScore, tooltip = "Percentile for signal STRONG (Adaptive). ↑ — fewer, but more selective STRONG zones; ↓ — more signals.")
medPct       = input.float(65.0, "MEDIUM percentile", minval = 30, maxval = 95, group = gScore, tooltip = "Percentile for MEDIUM (Adaptive) signal. This is the basic threshold from which the setup is generally formed. ↑ - stricter; ↓ — more settings.")
strongThresh = input.float(50.0, "Fixed: STRONG Level", minval = 1, group = gScore, tooltip = "Absolute |score| level for STRONG in Fixed mode.")
medThresh    = input.float(28.0, "Fixed: MEDIUM Level", minval = 1, group = gScore, tooltip = "Absolute |score| level for MEDIUM in Fixed mode.")
minAbsFloor  = input.float(8.0, "Min. Absolute Score (Adaptive Floor)", minval = 0, group = gScore,
     tooltip = "In Adaptive mode, a zone also needs |score| above this value so quiet symbols do not produce STRONG signals on near-zero noise.")
confDead     = input.float(0.15, "Confluence Vote Deadband", minval = 0, maxval = 0.5, step = 0.05, group = gScore,
     tooltip = "A module must exceed this value to count as a confluence vote (screens out nearly neutral votes). ↑ — only expressive modules get into confluence.")
scoreScale   = input.float(90.0, "Score Sensitivity", minval = 5, step = 5, group = gScore, tooltip = "Overall score-amplitude scale. Higher values reach extremes more readily; lower values are smoother.")
sigLen       = input.int(8, "Signal Line Length", minval = 2, group = gScore, tooltip = "EMA period for the smoothed signal line. Higher values are smoother and slower.")
confirmMode  = input.string("Instant", "Confirmation mode", options = ["Instant", "Strict"], group = gScore,
     tooltip = "Instant — a signal at the closing of the event candle (more sensitive, without delay). Strict — confirmation is required with the next candle according to the saved snapshot of the setup (fewer fakes, +1 bar of delay). Strict is recommended for cleaner inputs.")
minConf      = input.int(2, "Min. confluence (N-of-M modules agree)", minval = 1, maxval = 8, group = gScore,
     tooltip = "How many independent sources have to confirm the direction. Source 8 (extremity, CVD flow/div, sweep, rejection, OI, HTF, funding, basis); the threshold is automatically limited by the number of available. ↑ - stricter, fewer and better signals.")
cooldownBars = input.int(3, "Cooldown between zones (bars)", minval = 0, group = gScore, tooltip = "Minimum bars between new zones. ↑ — fewer signal clusters in a row.")
cooldownPerDir = input.bool(true, "Cooldown by direction", group = gScore, tooltip="On: LONG signal only blocks new LONGs (opposite signal is fresh information, not spam). Off: Any signal blocks both directions.")

gSig = "Signals and Retest"
useRetest    = input.bool(true, "Retest signal (price returns to the live zone)", group = gSig, tooltip="It is triggered when the price re-enters the already formed active zone and recedes from it (wick + closing back). Often a cleaner entry than the first touch.")
retestRejFrac = input.float(0.5, "Retest rejection (wick ≥ fractions of range)", minval=0.1, maxval=0.9, step=0.05, group = gSig, tooltip = "What fraction of the candle's range should the wick be in order to count the rejection on the retest. ↑ - stricter, only expressive rejections.")
retestCooldown = input.int(5, "Retest cooldown (bars per zone)", minval=0, group = gSig, tooltip = "Minimum bars between retest signals of the same zone.")
alertEntry   = input.bool(true, "Alert: the price has entered the zone", group = gSig, tooltip="Activates on the first touch of the live zone - a practical notification if you are not watching the screen.")
alertState   = input.bool(true, "Alert: Confirmed / Mitigated zone", group = gSig, tooltip="Triggers when the analytical zone state resolves as Confirmed or Mitigated.")
minZoneAtr   = input.float(0.3, "Min. zone height (xATR)", minval=0.0, maxval=2.0, step=0.05, group = gSig, tooltip="The lower limit of the box height so that a sweep of one candle with a tiny range still gives a visible trading zone and not an invisible bar. ↑ — minimally thicker zones.")

gMod = "Modules (on/off)"
useExtremity  = input.bool(true, "Extremity / cost estimation", inline="m1", group = gMod, tooltip = "Overbought/oversold composite (RSI/%B/Stoch + MFI + CMF). Reversal direction kernel.")
useFlow       = input.bool(true, "Order Flow",            inline="m1", group = gMod, tooltip = "Order Flow: Reversal CVD/OBV/Traffic Lights. Catches fading and reversal of motion, not its direction.")
useDivergence = input.bool(true, "CVD Divergence",        inline="m2", group = gMod, tooltip = "Price divergence and CVD on pivots (regular + optionally hidden).")
useSweep      = input.bool(true, "Liquidity Sweep",       inline="m2", group = gMod, tooltip="Enabled: Liquidity sweep is REQUIRED for signal (and feeds direction/account/gate). Off: sweep is completely optional—no longer gating a trigger, direction, account, or event gate.")
useRejection  = input.bool(true, "Rejection",             inline="m3", group = gMod, tooltip = "Rejection: wick length + close position (CLV). Measures whether the market has rejected a breakout.")
useAbsorption = input.bool(true, "Absorption",            inline="m3", group = gMod, tooltip = "Absorption: high volume in small range = passive large player absorbs orders.")
useVolume     = input.bool(true, "Volume Intensity",      inline="m4", group = gMod, tooltip = "Volume intensity (RVOL + Z-score) as a multiplier of count amplitude.")
useOI         = input.bool(true, "Open Interest",         inline="m4", group = gMod, tooltip = "Aggregated Open Interest and price/OI quadrants (liquidation, squeeze, new positions).")
useRegime     = input.bool(true, "Volatility Regime",     inline="m5", group = gMod, tooltip = "Volatility mode (Parkinson) as an amplitude multiplier.")
useContext    = input.bool(true, "Context (VWAP/Session)",inline="m5", group = gMod, tooltip = "VWAP context (proximity/overstretch ~2σ) and session filter.")
useHTF        = input.bool(true, "HTF Alignment",         inline="m6", group = gMod, tooltip = "Alignment with the higher timeframe (bias/extremity) plus counter-trend penalties.")
useChop       = input.bool(true, "Chop Filter (Kaufman ER)", inline="m6", group = gMod, tooltip = "In a directionless market, the Efficiency Ratio filter blocks or penalizes signals.")

gW = "Direction weights"
wExt      = input.float(1.0, "Extremity",  minval=0, step=0.1, inline="w1", group = gW, tooltip = "Extremity module weight in direction. ↑ - pulls more towards overbought/oversold.")
wFlow     = input.float(0.4, "Flow",       minval=0, step=0.1, inline="w1", group = gW, tooltip = "Order Flow weight in the direction.")
wDiv      = input.float(0.8, "Divergence", minval=0, step=0.1, inline="w2", group = gW, tooltip = "CVD divergence weight in direction.")
wSweepDir = input.float(1.0, "Sweep",      minval=0, step=0.1, inline="w2", group = gW, tooltip = "The weight of the sweep direction is in the direction.")
wRej      = input.float(1.0, "Rejection",  minval=0, step=0.1, inline="w3", group = gW, tooltip = "Rejection module weight in the directional score.")
wHtf      = input.float(0.6, "HTF Bias",   minval=0, step=0.1, inline="w3", group = gW, tooltip = "Directional HTF offset weight (applies if no HTF Extremity is active).")

gG = "Event Gate scales"
baseFloor = input.float(0.45, "Basic threshold (visible only by extremity)", minval=0, maxval=1, step=0.05, group = gG, tooltip = "Minimum event gate level without events. ↑ — the score is visible even without sweep/rejection; ↓ - events are required for the account to come to life.")
kSweep    = input.float(0.6, "The amount of Sweep", minval=0, step=0.05, inline="g", group = gG, tooltip = "The contribution of the sweep force to the event gate. ↑ — deep sweeps greatly amplify the signal.")
kAbs      = input.float(0.3, "Absorption",      minval=0, step=0.05, inline="g", group = gG, tooltip = "Absorption contribution to the event gate.")
kRej      = input.float(0.3, "Rejection",       minval=0, step=0.05, inline="g", group = gG, tooltip = "Rejection contribution to the event gate.")

gVol = "Volume module"
volLen   = input.int(20, "Volume period", minval=5, group = gVol, tooltip = "Base for RVOL and volume Z-score. ↑ is a smoother estimate of the \"normal\" volume.")
volFloor = input.float(0.5, "The lower limit of volume intensity", minval=0, maxval=1, step=0.05, group = gVol, tooltip = "Minimum volume multiplier so that quiet bars do not nullify the amplitude.")
volAmpW  = input.float(0.7, "Volume amplitude weight", minval=0, maxval=1, step=0.05, group = gVol,
     tooltip = "How much volume weighs the final amplitude of the score. 1 = pure volIntensity (may dominate); 0 = volume is ignored in amplitude. ↓ - to balance against OI/mode/context.")

gRobust = "Robust Baselines (MAD / IQR)"
useRobust = input.bool(true, "Robust MAD/IQR normalization", group=gRobust,
     tooltip="Uses the median with MAD/IQR scale instead of mean/std-dev for volume, OI change and candle range. It prevents one outlier from distorting the baseline while preserving it as a shock event.")
robustLen = input.int(50, "Robust baseline length", minval=10, group=gRobust,
     tooltip="Lookback for the rolling median, MAD and IQR baseline. Higher values make the normal range steadier; lower values adapt faster.")
robustShockZ = input.float(3.0, "Shock threshold (robust Z)", minval=1.5, step=0.25, group=gRobust,
     tooltip="A volume/OI move beyond this robust Z-score is retained as a shock, so capitulation is not filtered out by the robust baseline.")
useAmihud = input.bool(true, "Clarification of Amihud liquidity", group = gVol,
     tooltip = "Weights takeovers per |price change|/volume relative to normal: A bar that has moved significantly LESS price per unit of volume than usual is a true takeover by a large passive player, not just silence.")

gExt = "Extremity / basis of Z-Score"
zLen   = input.int(100, "Period Z-Score", minval=10, group = gExt, tooltip = "Period for Z-score of extremity components. ↑ — a more stable, slower estimate of the extremum.")
zClip  = input.float(2.0, "Z cropping", minval=1, group = gExt, tooltip = "Z-score saturation limit so that a single outlier does not skew the composite. ↓ — earlier saturation.")
uVWAP  = input.bool(false, "VWAP",  inline="z1", group = gExt, tooltip="VWAP/Price/ROC/MACD are trend/level measures, not overbought/oversold. Disabled by default to keep the extremity base mean-reverting (RSI/%B/Stoch). Turn on only if you want a trendy slant.")
uROC   = input.bool(false, "ROC",   inline="z1", group = gExt)
uPrice = input.bool(false, "Price", inline="z1", group = gExt)
uRSI   = input.bool(true,  "RSI",   inline="z2", group = gExt)
uMACD  = input.bool(false, "MACD",  inline="z2", group = gExt)
uPCTB  = input.bool(true,  "%B",    inline="z2", group = gExt)
uSTOCH = input.bool(true,  "Stoch", inline="z3", group = gExt)
uATR   = input.bool(false, "ATR",   inline="z3", group = gExt)
uVOLZ  = input.bool(false, "VolZ",  inline="z3", group = gExt)
uSHARPE= input.bool(false, "Sharpe",inline="z4", group = gExt)
uSORT  = input.bool(false, "Sortino",inline="z4", group = gExt)
uOMEGA = input.bool(false, "Omega", inline="z4", group = gExt)
wMFI   = input.float(0.5, "MFI weight in extremity", minval=0, step=0.1, group = gExt, tooltip = "MFI contribution to the extremity composite.")
wFCO   = input.float(0.5, "FCO weight (CMF) in extremity", minval=0, step=0.1, group = gExt, tooltip = "Contribution of CMF (Flow Control) to composite extremity.")

gFlow = "Order Flow & Divergence"
cvdMode  = input.string("Periodic", "CVD mode", options=["Periodic","EMA"], group = gFlow, tooltip = "Periodic — CVD as delta sum per period (classical). EMA — exponential smoothing of delta (smoother, reacts less sharply).")
cvdLen   = input.int(21, "CVD period", minval=2, group = gFlow, tooltip = "CVD accumulation/smoothing period. ↑ — smoother CVD.")
flowSlope= input.int(3, "Flow slope length", minval=1, group = gFlow, tooltip = "A basis for estimating flow acceleration/reversal.")
obvLen   = input.int(24, "MA length for OBV", minval=2, group = gFlow, tooltip = "The sliding period for the OBV pulse.")
divN     = input.int(5, "The period of divergence pivots", minval=1, group = gFlow, tooltip = "Pivot width for looking for divergences. ↑ — rarer, more significant divergences.")
divDecay = input.float(0.9, "Divergence extinction", minval=0.5, maxval=0.99, step=0.01, group = gFlow, tooltip = "How slowly the divergence signal decays over time. ↑ (closer to 1) - lasts longer.")
useHidden= input.bool(true, "Hidden Divergence (continuation penalty)", group = gFlow, tooltip = "Consider a hidden divergence as a penalty against a reversal (a hint of a continuation of the trend).")
hiddenW  = input.float(0.3, "Penalty Hidden", minval=0, maxval=0.6, step=0.05, group = gFlow, tooltip = "The strength of the hidden divergence penalty against the signal side.")
useLTFdelta = input.bool(true, "Intrabar Delta from Lower TF", group = gFlow,
     tooltip = "Build volume delta from lower-timeframe up/down volume instead of candle geometry. This improves CVD, divergence, and delta absorption, and falls back to the geometric proxy where intrabar data is unavailable.")
ltfRes   = input.string("Auto", "Lower TF", options=["Auto","1","3","5","15","60"], group = gFlow, tooltip = "Lower timeframe for intrabar delta. Auto selects a suitable timeframe for the current chart. Smaller timeframes are more accurate but have less historical depth.")
ltfDeltaMode = input.string("Range-weighted", "Intrabar delta estimation", options=["Range-weighted","Close direction"], group = gFlow,
     tooltip="Range-weighted estimates each intrabar's volume pressure from its close inside its range. Close direction assigns all volume to up/down candles. Both are estimates, not exchange aggressor delta.")
ltfCovLen = input.int(30, "Intrabar coverage baseline", minval=5, maxval=200, group=gFlow,
     tooltip="Historical bars used to learn the usual number of lower-TF candles per chart bar. This makes coverage session-aware instead of assuming 24 hourly bars in every daily candle.")
ltfMinCoverage = input.float(0.70, "Minimum completed coverage", minval=0.10, maxval=1.00, step=0.05, group=gFlow,
     tooltip="Below this fraction of the usual intrabar sample, lower-TF delta is blended toward the proxy and the Data Quality score is reduced.")
useBuySellPressure = input.bool(true, "Buy/Sell Pressure in Order Flow", group = gFlow,
     tooltip = "Adds a smoothed Buy/Sell balance to an existing Order Flow. Does not create a separate confluence voice because it uses the same volume/delta family and should not be counted twice.")
pressureLen = input.int(5, "Buy/Sell smoothing", minval = 1, maxval = 50, group = gFlow,
     tooltip = "EMA period for Buy/Sell %. 1 — current candle; 3–8 — recommended stable balance; more - slower pressure.")
pressureInfluence = input.float(0.35, "Effect of Buy/Sell on Flow", minval = 0.0, maxval = 1.0, step = 0.05, group = gFlow,
     tooltip = "Share of Buy/Sell pressure in the Order Flow module. It is mixed with CVD/OBV-turn inside the same flow-module, not added as an independent signal.")
pressureBarLen = input.int(2, "Smoothing Composite Pressure", minval = 1, maxval = 20, group = gFlow,
     tooltip = "EMA of the final pressure in vertical bar. 2–4 — fast, but without single-bar flickering; more - calmer and slower.")

gSweep = "Sweep and liquidity levels"
sweepPivot   = input.bool(true, "Pivot swings",   inline="sw", group = gSweep, tooltip = "Use the latest pivot high/low as liquidity levels for the sweep.")
sweepRoll    = input.bool(true, "Rolling extremes",inline="sw", group = gSweep, tooltip = "Use sliding max/min as sweep levels.")
sweepSession = input.bool(true, "H/L of the previous day",  inline="sw", group = gSweep, tooltip = "Use the previous day's high/low as liquidity levels.")
pvN          = input.int(5,  "Pivot period", minval=1, group = gSweep, tooltip = "Pivot width for sweep levels. ↑ — more significant, rarer half-tones.")
rollLen      = input.int(20, "Rolling period", minval=2, group = gSweep, tooltip = "Window for sliding extremes.")
minSweepDepth= input.float(0.1, "Min. sweep depth (xATR)", minval=0, step=0.05, group = gSweep, tooltip = "Minimum level piercing in ATR to count the sweep. ↑ — only expressive withdrawals of liquidity.")
sweepWin     = input.int(3, "Reclaim window for Sweep (bars)", minval=1, maxval=10, group = gSweep,
     tooltip = "Sweep no longer has to retrace the level with the same candle: the breakout can be up to N bars ago (even with closes by the level) and the signal is triggered on the first close back across the level. 1 = classic one-candle behavior.")
wSess        = input.float(1.0, "The rank of the previous day", minval=0, step=0.1, inline="r", group = gSweep, tooltip = "The weight of the previous day's level in choosing the strongest sweep.")
wPiv         = input.float(0.8, "Pivot rank",     minval=0, step=0.1, inline="r", group = gSweep, tooltip = "Pivot-level weight.")
wRoll        = input.float(0.6, "Rolling rank",   minval=0, step=0.1, inline="r", group = gSweep, tooltip = "The weight is rolling-level.")
sweepWeek    = input.bool(true, "H/L of previous week", inline="sw2", group = gSweep, tooltip = "Use previous week's high/low.")
sweepMonth   = input.bool(true, "H/L of previous month", inline="sw2", group = gSweep, tooltip = "Use the previous month's high/low.")
sweepPOC     = input.bool(true, "POC of the previous day", inline="sw2", group = gSweep, tooltip = "Use the actual POC of the completed day (from the volume profile of the day) as the liquidity level.")
wWeek        = input.float(1.1, "Rank of the week",   minval=0, step=0.1, inline="r2", group = gSweep, tooltip = "The weight of the weekly level is usually stronger than the daily level.")
wMonth       = input.float(1.2, "Rank of the month",  minval=0, step=0.1, inline="r2", group = gSweep, tooltip = "The weight of the lunar level is the strongest of the temporal ones.")
wPOCr        = input.float(0.7, "Rank PD-POC", minval=0, step=0.1, inline="r2", group = gSweep, tooltip = "Previous day's POC weight.")
useEqual     = input.bool(true, "Amplify Equal High/Low levels", group = gSweep, tooltip = "Double (equal) high/low is a liquidity magnet; boost level rank.")
eqTol        = input.float(0.25, "Tolerance of Equality of Levels (xATR)", minval=0.05, step=0.05, group = gSweep, tooltip = "How close should two extremes be to be considered Equal. ↑ — equality is easier to calculate.")
eqBoost      = input.float(0.4, "Equal-level amplification", minval=0, maxval=1, step=0.05, group = gSweep, tooltip = "Boost power for Equal High/Low.")
useRound     = input.bool(true, "Reinforce round numbers", group = gSweep, tooltip = "Levels near round numbers attract liquidity; strengthen the rank.")
roundTol     = input.float(0.25, "Round Number Tolerance (xATR)", minval=0.05, step=0.05, group = gSweep, tooltip = "How close to a round number the level should be.")
roundBoost   = input.float(0.3, "Round number amplification", minval=0, maxval=1, step=0.05, group = gSweep, tooltip = "Boost power near round numbers.")

gZone = "Zone life cycle"
maxZones   = input.int(20, "Max. active zones", minval=1, maxval=60, group = gZone, tooltip = "Limit of simultaneous zones; the oldest are deleted beyond the limit. ↑ — more history on the chart.")
confirmAtr = input.float(1.0, "Confirmation Movement (xATR)", minval=0.1, step=0.1, group = gZone, tooltip = "How far does the price have to go towards the zone (in ATR) to mark it as Confirmed. ↑ is a stricter confirmation.")
mergeTol   = input.float(0.5, "Aggregation Tolerance (xATR)", minval=0, step=0.1, group = gZone, tooltip = "How close unidirectional zones merge into one. ↑ — more aggressive association.")

gOI = "Open Interest · Quoted in: COIN"
oiZlen    = input.int(50, "Period Z for OI-delta", minval=5, group = gOI, tooltip = "Period Z-score for normalized change in OI. ↑ — a more stable estimate.")
oiSmooth  = input.int(3, "OI/Price Quadrant Smoothing (Bars)", minval=1, group = gOI, tooltip = "Smoothing to avoid single-bar jitter in the price/OI quadrants.")
oiTrendLen = input.int(20, "Direction OI for N candles", minval=1, maxval=500, group = gOI, tooltip = "Compares the Open Interest of each available feed with its value N candles ago. The arrow in the widget shows the direction of the aggregated OI for this period.")
oiWeight  = input.float(0.25, "Impact of OI", minval=0, maxval=0.6, step=0.05, group = gOI, tooltip = "The power of the OI quadrant multiplier on the amplitude. ↑ — OI greatly strengthens/attenuates the signal.")
oiBinance  = input.bool(true, "Binance USDT.P", inline="o1", group = gOI, tooltip = "Source OI. Disabled feeds are not polled and are not included in composite/health.")
oiBinance2 = input.bool(true, "Binance USD.P",  inline="o1", group = gOI)
oiBinance3 = input.bool(true, "Binance BUSD.P", inline="o2", group = gOI)
oiBitmex   = input.bool(true, "BitMEX USD.P",   inline="o2", group = gOI)
oiBitmex2  = input.bool(true, "BitMEX USDT.P",  inline="o3", group = gOI)
oiKraken   = input.bool(true, "Kraken USD.P",   inline="o3", group = gOI)

gReg = "Regime, Context & HTF"
parkLen   = input.int(20,  "Parkinson's length", minval=5, group = gReg, tooltip = "Parkinson's Volatility Assessment Window.")
parkBase  = input.int(100, "Parkinson's base", minval=20, group = gReg, tooltip = "Base for normalization of the volatility oscillator.")
regimeW   = input.float(0.2, "The influence of the regime", minval=0, maxval=0.5, step=0.05, group = gReg, tooltip = "The power of the multiplier of the volatility mode on the amplitude. ↑ — spikes in volatility strengthen the account more.")
adxLen    = input.int(14, "ADX length", minval=1, inline="a", group = gReg, tooltip = "ADX period to determine trend strength.")
adxSmooth = input.int(14, "ADX smoothing", minval=1, inline="a", group = gReg)
adxThresh = input.float(25.0, "ADX of a strong trend", minval=1, group = gReg, tooltip = "Above this ADX, the market is considered to be in a strong trend (turns on countertrend penalties and weighting).")
trendPen  = input.float(0.2, "Penalty against the trend", minval=0, maxval=0.6, step=0.05, group = gReg, tooltip = "Penalty of the account in case of a strong trend (reversal against the trend is riskier). ↑ — stronger suppresses counter-trend signals.")
ctxW      = input.float(0.2, "Effect of VWAP Proximity", minval=0, maxval=0.5, step=0.05, group = gReg, tooltip = "VWAP context strength (magnet / overstretch) per amplitude.")
vwapSdLen = input.int(50, "VWAP σ-band length", minval=10, group = gReg,
     tooltip = "The period of the standard deviation of the price–VWAP distance. The price at ~2σ is considered overstretched (boost of the \"rubber band\" context).")
htfTf     = input.timeframe("240", "HTF Timeframe", group = gReg, tooltip = "Higher timeframe for bias/extremity. It must be strictly higher than the chart timeframe (otherwise the dashboard shows ⚠TF).")
htfConfirm = input.bool(true, "Only closed HTF bars (non-repaint)", group = gReg,
     tooltip = "Enabled by default. Uses only CLOSED bars of senior TF ([1]) for HTF bias/extremity, so values ​​don't drift inside the bar and history is stable after repaint (non-repaint), at the cost of one HTF delay. Disable for faster intrabar redraw LIVE mode.")
htfTrendPen = input.float(0.25, "Penalty against the HTF trend", minval=0, maxval=0.6, step=0.05, group = gReg, tooltip = "Penalty when the direction of the signal goes against the trend of the older TF.")
erLen     = input.int(14, "Length Efficiency Ratio", minval=2, inline="e", group = gReg, tooltip = "Kaufman ER period to detect flat.")
erThresh  = input.float(0.30, "ER threshold for flat", minval=0.05, maxval=0.9, step=0.05, inline="e", group = gReg, tooltip = "Below this ER, the market is considered a flat/top. ↑ — more conditions are interpreted as flat.")
chopPen   = input.float(0.4, "Fine for a flat", minval=0, maxval=0.9, step=0.05, group = gReg, tooltip = "Penalty account in flat. ↑ — stronger suppresses signals in a non-directional market.")
sessOn    = input.bool(false, "Session filter", inline="s", group = gReg, tooltip = "Penalize signals outside a given trading session.")
sessIn    = input.session("0000-0000", "", inline="s", group = gReg)
sessPen   = input.float(0.2, "Penalty out of session", minval=0, maxval=0.6, step=0.05, group = gReg, tooltip = "The force of the penalty outside the active session.")

gFund = "Funding Rate (optional, crypto)"
useFunding = input.bool(false, "Use Funding Rate", inline="f", group = gFund, tooltip = "Consider the funding rate as a shift in direction (overloaded longs → short bias).")
fundSym    = input.symbol("", "Funding symbol", inline="f", group = gFund,
     tooltip = "Insert your exchange's funding/premium ticker (for example *_PREMIUM or funding-feed). Empty = disabled.")
wFund      = input.float(0.4, "Funding shift weight", minval=0, step=0.1, group = gFund, tooltip = "The weight of the funding shift in the direction.")
useBasis   = input.bool(false, "Use Spot-Perp Basis", inline="b", group = gFund, tooltip = "Take into account the spot-perp basis: stretched premium = overloaded longs (short bias); discount = overloaded shorts (long bias).")
basisSpot  = input.symbol("", "Spot symbol", inline="b", group = gFund,
     tooltip = "Spot ticker of the same asset (for example, BINANCE:BTCUSDT under the perp chart). Stretched premium = overloaded longs (short bias); discount = overloaded shorts (long bias). Empty = disabled.")
wBasis     = input.float(0.3, "Basis Shear Weight", minval=0, step=0.1, group = gFund, tooltip = "Basis shift weight in the direction.")
useSqueezeStress = input.bool(true, "Squeeze-stress context", group=gFund,
     tooltip="Analytical context only: flags crowded longs/shorts when OI builds, funding or basis is stretched, and price rejects with an opposing wick. It never substitutes missing OI with volume.")
squeezeOiZ = input.float(0.75, "OI build threshold (Z)", minval=0.10, step=0.05, group=gFund)
squeezeCrowd = input.float(0.25, "Funding/Basis crowding threshold", minval=0.05, maxval=1.00, step=0.05, group=gFund,
     tooltip="Normalized magnitude required from funding or basis to call positioning crowded.")
squeezeWick = input.float(0.60, "Opposing wick (xATR)", minval=0.10, step=0.05, group=gFund,
     tooltip="Minimum rejection wick for squeeze stress. The flag is informative and does not create a trade or backtest event.")
squeezeBoost = input.float(0.20, "Squeeze-stress gate boost", minval=0.0, maxval=0.80, step=0.05, group=gFund,
     tooltip="Small, side-aligned analytical boost when a crowded-position liquidation wick appears. It is not an independent confluence vote.")

gProb = "Zone Context"
useLevelMem  = input.bool(true, "Memory respect/retest level", group = gProb, tooltip = "Taking into account how often the level was previously respected vs. broken - affects the confidence of the zone (setup-confidence).")
lvlMemLook   = input.int(250, "Level memory period", minval=50, maxval=500, group = gProb, tooltip = "How many bars are analyzed for level memory. ↑ — a longer history of respect.")
lvlTol       = input.float(0.35, "Level Touch Tolerance (xATR)", minval=0.05, step=0.05, group = gProb, tooltip = "How close to the level the touch counts.")
useOverext   = input.bool(true, "Overstretching boost", group = gProb, tooltip = "Strengthen the setups when the price is overstretched from the average + a series of unidirectional bars.")
oxMean       = input.int(20, "The length of the average overstretch", minval=5, group = gProb, tooltip = "EMA period for overstretch distance.")
oxW          = input.float(0.3, "Effect of overextension on gate", minval=0, maxval=0.8, step=0.05, group = gProb, tooltip = "The strength of the overstretch contribution to the event gate.")
useHTFlevels = input.bool(true, "Confluence with HTF levels", group = gProb, tooltip = "Amplify sweep levels matching the high/low of the senior TF.")
htfLvlTol    = input.float(0.5, "HTF Level Tolerance (xATR)", minval=0.05, step=0.05, group = gProb, tooltip = "How close to the HTF level is the match counted.")
htfLvlBoost  = input.float(0.5, "HTF level boost", minval=0, maxval=1.5, step=0.1, group = gProb, tooltip = "Boost power to match HTF level.")
useAVWAP     = input.bool(true, "Anchored VWAP levels", group = gProb, tooltip = "Use AVWAPs from recent swings as dynamic reversal magnets.")
avwapBoost   = input.float(0.3, "AVWAP level boost", minval=0, maxval=1.0, step=0.05, group = gProb, tooltip = "The boost power is near the AVWAP level.")
useProfile   = input.bool(true, "Volume Profile (VAH/VAL/POC)", group = gProb, tooltip = "Calculate the sliding volume profile (volume distributed over the range of each candle) for the VAH/VAL/POC context.")
vpLook       = input.int(120, "Profile period", minval=20, maxval=400, group = gProb, tooltip = "How many bars form a sliding profile. ↑ — wider, more stable profile.")
vpBins       = input.int(24, "Bins profile", minval=8, maxval=50, group = gProb, tooltip = "Profile resolution by price. ↑ - more accurate, but noisier.")
vpVA         = input.float(70, "Value Area %", minval=50, maxval=90, group = gProb, tooltip = "Share of the volume in the Value Area (classical 70%).")
vpEvery      = input.int(3, "Profile: Recompute Every N Bars", minval=1, maxval=20, group = gProb, tooltip = "Performance: the heavy volume profile is rebuilt every N bars (cached in between), plus always on the last bar and on day change. Higher = faster, VAH/VAL/POC refresh less often; 1 = every bar.")
usePattern   = input.bool(false, "Request a reversal candle", group = gProb, tooltip = "Request an engulfing / pin bar pattern for a signal. Stricter, fewer signals.")
useMultiDiv  = input.bool(true, "Multi-oscillator divergence", group = gProb, tooltip = "RSI + OBV independent divergence (both must match) as an additional directional voice.")
multiDivW    = input.float(0.4, "Multi-divergence weight", minval=0, maxval=1.5, step=0.1, group = gProb, tooltip = "The weight of the multi-oscillator divergence in the direction.")
useCapit     = input.bool(true, "Flag of surrender", group = gProb, tooltip = "To signal capitulation: sweep + OI drain + high volume. Highlights the area with an accent.")
capOIz       = input.float(1.0, "Z OI surrender (negative)", minval=0.2, step=0.1, group = gProb, tooltip = "How steeply does OI (in Z) have to fall to count as a capitulation. ↑ — only sharp showers OI.")

gSMC = "Order Blocks and FVG"
useOB     = input.bool(true, "Confluence with Order Block", inline="ob", group=gSMC, tooltip = "Strengthen the sweep level lying in the unmitigated Order Block.")
obBoost   = input.float(0.4, "Bust", minval=0, maxval=1.5, step=0.05, inline="ob", group=gSMC,
     tooltip = "The sweep level inside the unmitigated Order Block (the last contrarian candle before the impulse) is protected liquidity. Increases his rank.")
obImpulse = input.float(1.5, "OB pulse (xATR at 3 bars)", minval=0.5, step=0.1, group=gSMC, tooltip = "How strong must the movement be after the OB to count as a block. ↑ — only expressive OBs.")
useFVG    = input.bool(true, "Confluence with FVG", inline="fv", group=gSMC, tooltip = "Strengthen the sweep level at the edge of the unfilled Fair Value Gap.")
fvgBoost  = input.float(0.3, "Bust", minval=0, maxval=1.5, step=0.05, inline="fv", group=gSMC,
     tooltip = "A sweep level on the edge of an unfilled Fair Value Gap gets a rank boost.")
fvgDecayFill = input.bool(true, "Fade FVG confluence as filled", group=gSMC,
     tooltip="Tracks partial fills, keeps only the unfilled part of a gap and gradually reduces its confluence instead of treating a nearly filled FVG as fully intact.")
smcTol    = input.float(0.35, "Touch Tolerance (xATR)", minval=0.05, step=0.05, group=gSMC, tooltip = "How close to OB/FVG is a match counted.")
smcMax    = input.int(15, "Max. tracked OB / FVG", minval=4, maxval=40, group=gSMC, tooltip = "OB/FVG memory limit.")

gAdv = "Advanced analysis"
useRegimeWeights = input.bool(true, "Direction weights are adaptive by mode", group=gAdv, tooltip="In a strong trend: lower extremity weight (do not fight the trend), higher sweep+divergence. In flat: higher extremity.")
useHtfExt   = input.bool(true,  "Confluence with HTF Extremity", group=gAdv, tooltip = "Richer HTF direction (composite extremity instead of only RSI). Replaces simple HTF Bias when enabled.")
htfExtW     = input.float(0.6, "Weight of HTF Extremity", minval=0, maxval=1.5, step=0.1, group=gAdv, tooltip = "HTF-extremity weight in the direction.")
useClimax   = input.bool(true,  "Volume Climax / Stopping Volume", group=gAdv, tooltip = "Identify the climax volume (huge volume, extreme taken, closing back to the middle) as support for the side.")
climaxMult  = input.float(2.5, "Climax Volume (×RVOL)", minval=1.5, step=0.1, group=gAdv, tooltip = "How many times RVOL should exceed the norm for climax. ↑ — only extreme surges.")
useWyckoff  = input.bool(true,  "Wyckoff Spring / Upthrust", group=gAdv, tooltip="A tight low-efficiency consolidation box + a puncture beyond it with a close back inside is an accumulation/distribution test that is structurally stronger than a single pivot-sweep. Reinforces event gate.")
wyBoxBars   = input.int(12, "Box size (bars)", minval=5, maxval=50, group=gAdv, tooltip = "Wyckoff consolidation box width.")
wyBoxAtr    = input.float(2.2, "Max. box height (xATR)", minval=0.5, step=0.1, group=gAdv, tooltip = "Maximum box height to be considered a close consolidation. ↓ — only very tight boxes.")
wyBoost     = input.float(0.35, "Spring/UT boost in gate", minval=0, maxval=1, step=0.05, group=gAdv, tooltip = "Event gate boost force for spring/upthrust.")
useDeltaAbs = input.bool(true,  "Delta Absorption on Sweep", group=gAdv, tooltip="Price takes level but CVD delta doesn't confirm = big player absorbs.")
useBTCfilt  = input.bool(false, "Filter by BTC (for alts)", group=gAdv, tooltip = "Matching the reversal side with extremity BTC is useful for alts following bitcoin.")
btcSym      = input.symbol("BINANCE:BTCUSDT", "Reference BTC", group=gAdv)
useSession  = input.bool(false, "Weighing in on a Killzone session", group=gAdv, tooltip = "Boost event gate in a given Killzone session (active hours).")
kzSess      = input.session("0700-1600", "Killzone session", group=gAdv)
kzBoost     = input.float(0.3, "Killzone boost in gate", minval=0, maxval=1, step=0.05, group=gAdv, tooltip = "Event gate boost power in Killzone session.")
showDebug   = input.bool(false, "Debug Series in the Data Window", group=gAdv, tooltip="Outputs the raw score components (extremity, flow, sweep, gate, amp, dir) in the Data Window without cluttering the chart. Hover over a bar to see why the score has its current value.")

// ── Agent Feed: Every event goes through alert() as typed JSON. Create ONE alert in the UI
// with the condition "Any alert() function call" + your webhook URL — all events go through one channel;
// the receiving agent distinguishes them by the "event" field. ──
gFeed = "Agent Feed (webhook JSON)"
feedOn        = input.bool(true,  "Enable Agent Feed", group=gFeed, tooltip="Main switch. All messages are self-contained JSON with a shared envelope (event, ticker, tf, time, bar) for the agent to organize, deduplicate, and detect flow gaps.")
feedSignals   = input.bool(true,  "Signals (long/short/retest)", inline="f1", group=gFeed, tooltip = "Send event signals and retest.")
feedZones     = input.bool(true,  "Life cycle of zones (entry/state/HTF)", inline="f1", group=gFeed, tooltip = "Send zone entry, state change, and HTF zone events.")
feedLiquidity = input.bool(true,  "Liquidity events (sweep/capit/climax/divergence)", inline="f2", group=gFeed, tooltip = "Send raw liquidity events even without a full signal.")
feedContext   = input.bool(true,  "Context changes (OI quadrant/mode/threshold)", inline="f2", group=gFeed, tooltip = "Send OI quadrant, mode, and threshold bucket changes.")
feedSnapshot  = input.string("On State Change", "State Snapshot", options=["Every Bar","Every N Bars","On State Change","Off"], group=gFeed, tooltip="Periodic analytical telemetry (score, components, regime and zones). Every Bar is verbose; Every N Bars sends a periodic update; On State Change sends only when the analytical state changes; Off disables snapshots.")
feedSnapN     = input.int(4, "N (for Every N Bars)", minval=1, maxval=100, group=gFeed, tooltip = "Snapshot period for Every N Bars and heartbeat mode.")

gHTFz = "HTF reversal zones"
htfZonesOn = input.bool(false, "Higher-Timeframe Zones", group=gHTFz, tooltip="Identify the same reversal setup on the higher timeframe and project it as a stable zone on this chart. A return into an HTF zone is the strongest setup of this class. Off by default because it adds one request.security call.")
htfZTF     = input.timeframe("240", "HTF timeframe", group=gHTFz, tooltip = "Senior TF for HTF zones. Must be STRICTLY higher than the chart's timeframe, otherwise zones are not drawn (⚠TF).")
htfZExtAtr = input.float(0.6, "HTF zone thickness (xATR)", minval=0.1, maxval=3.0, step=0.1, group=gHTFz, tooltip = "The thickness of the HTF zone in the ATR of the HTF itself (the same on the 5m and 1h charts). ↑ — thicker zones.")
htfZMax    = input.int(6, "Max. HTF zone", minval=1, maxval=20, group=gHTFz, tooltip = "Limit of simultaneous HTF zones.")
htfZTr     = input.int(88, "Transparency of the HTF zone", minval=60, maxval=97, group=gHTFz, tooltip = "Transparency of filling HTF-zones. ↑ - more transparent.")
alertHtfEntry = input.bool(true, "Alert: the price has entered the HTF zone", group=gHTFz, tooltip = "Notification when the price enters the HTF zone.")

// ============================================================================
// 2. HELPERS & BASE
// ============================================================================
f_clamp(x, lo, hi) => math.max(lo, math.min(hi, x))
f_relu(x) => math.max(0.0, x)
f_soft(x) => x / math.sqrt(1.0 + x*x)   // smooth saturation R -> (-1,1): keeps tail discrimination instead of hard clipping
// Auxiliary calculations are placed in a separate area of the function so as not to expand the already large one
// global scope and at the same time make moderate concerted pressure highly visible.
f_activePressure(bias, evidence, activity) =>
    coherence = evidence > 0.0 ? f_clamp(math.abs(bias) / evidence, 0.0, 1.0) : 0.0
    drivenBias = f_soft(3.5 * bias)
    activityGate = (0.30 + 0.70 * math.sqrt(activity)) * (0.55 + 0.45 * coherence)
    100.0 * drivenBias * activityGate
// Hysteresis: a side enters at +/-5, but exits only after pressure returns through +/-2.
// This suppresses BUY/BAL/SELL flicker without delaying genuinely strong reversals.
f_pressureState(prev, pressure) =>
    next = prev
    if na(pressure)
        next := 0
    else if pressure >= 5.0
        next := 1
    else if pressure <= -5.0
        next := -1
    else if prev > 0 and pressure <= 2.0
        next := 0
    else if prev < 0 and pressure >= -2.0
        next := 0
    next

// Bounded extremity composite (RSI + MFI + band position); + = oversold. Security-callable for HTF/BTC confluence.
f_extProxy() =>
    r  = ta.rsi(close, 14)
    m  = ta.mfi(hlc3, 14)
    ma = ta.sma(close, 20)
    sd = ta.stdev(close, 20)
    zb = sd > 0 ? (close - ma)/sd : 0.0
    math.max(-1.0, math.min(1.0, ((50.0 - r)/50.0 + (50.0 - m)/50.0 - (zb / math.sqrt(1.0 + zb*zb))) / 3.0))
f_z(src, len) =>
    m = ta.sma(src, len)
    s = ta.stdev(src, len)
    s > 0 ? (src - m) / s : 0.0
f_zc(src, len) => f_clamp(f_z(src, len), -3.0, 3.0)   // bounded: one outlier can't skew the composite
// Robust Z: median center + MAD/IQR scale. The larger valid scale avoids an artificially
// huge score when a series is temporarily flat; it does not remove the outlier itself.
f_rz(src, len) =>
    med = ta.percentile_nearest_rank(src, len, 50)
    mad = ta.percentile_nearest_rank(math.abs(src - med), len, 50)
    q1 = ta.percentile_nearest_rank(src, len, 25)
    q3 = ta.percentile_nearest_rank(src, len, 75)
    madScale = 1.4826 * mad
    iqrScale = 0.7413 * math.max(0.0, q3 - q1)
    scale = math.max(madScale, iqrScale)
    not na(med) and not na(scale) and scale > 0 ? (src - med) / scale : 0.0
f_rzc(src, len) => f_clamp(f_rz(src, len), -3.0, 3.0)

atr  = ta.atr(14)
rng  = high - low
vwap = ta.vwap

// Item 7: timeframe guards — the HTF modules only make sense on a STRICTLY higher timeframe than the
// chart. These flags drive a dashboard/webhook warning and gate HTF-zone creation.
chartSec   = timeframe.in_seconds(timeframe.period)
htfTfValid = timeframe.in_seconds(htfTf)  > chartSec
htfZValid  = timeframe.in_seconds(htfZTF) > chartSec

// ============================================================================
// 3. VOLUME INTENSITY  (VVI + RVOL + Z)
// ============================================================================
volSma = ta.sma(volume, volLen)
rvol   = volSma > 0 ? volume / volSma : 1.0
volZClassic = f_z(volume, volLen)
volZRobust  = f_rz(volume, robustLen)
volZ   = useRobust ? volZRobust : volZClassic
volShock = useRobust and volZRobust >= robustShockZ
volIntensity = math.max(f_clamp(0.5 * f_relu(rvol - 1.0) + 0.5 * f_relu(volZ / 2.0), 0.0, 2.0), volFloor)

// Amihud illiquidity: |return| per unit volume vs its norm. A bar that moved far LESS per volume
// than usual (amiConf → 1) is being absorbed by passive size — refines the absorption module (7).
amihud   = volume > 0 ? math.abs(ta.change(close)) / volume : na
amihudMA = ta.sma(nz(amihud, 0.0), 50)
amiConf  = useAmihud and amihudMA > 0 and not na(amihud) ? f_clamp(1.0 - amihud / amihudMA, 0.0, 1.0) : 0.0

// ============================================================================
// 4. EXTREMITY / VALUATION  (Universal Z backbone + MFI + FCO)
// ============================================================================
priceZ = f_zc(close, zLen)
rocZ   = f_zc(ta.roc(close, 10), zLen)
rsiZ   = f_zc(ta.rsi(close, 14), zLen)
vwapZ  = f_zc(vwap, zLen)
[macdLine, macdSig, _] = ta.macd(close, 12, 26, 9)
macdZ  = f_zc(macdLine - macdSig, zLen)
bbBasis= ta.sma(close, 20)
bbDev  = ta.stdev(close, 20)
percentB = bbDev > 0 ? (close - (bbBasis - bbDev * 2.0)) / (bbDev * 4.0) : 0.5
pctbZ  = f_zc(percentB, zLen)
stochZ = f_zc(ta.stoch(close, high, low, 14), zLen)
atrZ   = f_zc(atr, zLen)
volzZClassic = f_zc(volume, zLen)
volzZRobust  = f_rzc(volume, robustLen)
volzZ  = useRobust ? volzZRobust : volzZClassic
ret    = ta.change(close)
sdRet  = ta.stdev(ret, zLen)
negRet = ret < 0 ? ret : na
sdNeg  = ta.stdev(negRet, zLen)
sharpeZ= f_zc(ta.sma(sdRet > 0 ? ret / sdRet : 0, zLen), zLen)
sortZ  = f_zc(ta.sma(sdNeg > 0 ? ret / sdNeg : 0, zLen), zLen)
posSum = math.sum(ret > 0 ? ret : 0, zLen)
negSum = math.sum(ret < 0 ? -ret : 0, zLen)
omegaZ = f_zc(negSum > 0 ? posSum / negSum : 0, zLen)

zTot = (uVWAP?vwapZ:0)+(uROC?rocZ:0)+(uPrice?priceZ:0)+(uRSI?rsiZ:0)+(uMACD?macdZ:0)+(uPCTB?pctbZ:0)+(uSTOCH?stochZ:0)+(uATR?atrZ:0)+(uVOLZ?volzZ:0)+(uSHARPE?sharpeZ:0)+(uSORT?sortZ:0)+(uOMEGA?omegaZ:0)
zCnt = (uVWAP?1:0)+(uROC?1:0)+(uPrice?1:0)+(uRSI?1:0)+(uMACD?1:0)+(uPCTB?1:0)+(uSTOCH?1:0)+(uATR?1:0)+(uVOLZ?1:0)+(uSHARPE?1:0)+(uSORT?1:0)+(uOMEGA?1:0)
zAvg = zCnt > 0 ? zTot / zCnt : 0.0
extZ = -f_soft(zAvg / zClip)                          // + = oversold; smooth saturation keeps extreme-tail discrimination

mfiVal = ta.mfi(hlc3, 14)
mfiExt = (50.0 - mfiVal) / 50.0
ad  = high == low ? 0.0 : ((2.0*close - high - low)/(high - low)) * volume
volSum20 = math.sum(volume, 20)
adSum20  = math.sum(ad, 20)
cmf = volSum20 > 0 ? adSum20 / volSum20 : 0.0
fcoExt = -f_clamp(cmf, -1.0, 1.0)                     // CMF only (MFI already carried by mfiExt -> no double-count)
extremity = f_clamp((extZ + wMFI*mfiExt + wFCO*fcoExt) / (1.0 + wMFI + wFCO), -1.0, 1.0)

// ============================================================================
// 5. ORDER FLOW  (CVD + OBV momentum + OBV Traffic Lights) & DIVERGENCE
// ============================================================================
buying  = rng > 0 ? volume * ((close - low)/rng) : 0.0
selling = rng > 0 ? volume * ((high - close)/rng) : 0.0
deltaProxy = buying - selling
// True intrabar delta: up-volume − down-volume summed from lower-timeframe bars. Far more accurate
// than candle geometry; falls back to the proxy where LTF data is unavailable (deep history).
f_autoLTF() =>
    timeframe.isseconds ? "1S" : timeframe.isintraday and timeframe.multiplier <= 15 ? "1" : timeframe.isintraday ? "5" : "60"
ltfTf = ltfRes == "Auto" ? f_autoLTF() : ltfRes
ltfValid = timeframe.in_seconds(ltfTf) < timeframe.in_seconds(timeframe.period)   // guard: LTF must be strictly BELOW the chart TF
[ltfOA, ltfHA, ltfLA, ltfCA, ltfVA] = request.security_lower_tf(syminfo.tickerid, ltfValid ? ltfTf : timeframe.period, [open, high, low, close, volume])
ltfN = array.size(ltfOA)
ltfNf = float(ltfN)
ltfCalendarN = ltfValid ? math.max(1.0, timeframe.in_seconds(timeframe.period) / timeframe.in_seconds(ltfTf)) : 1.0
ltfTypicalN = ta.sma(ltfNf, ltfCovLen)
// The smaller of calendar and observed counts adapts daily/weekly coverage to the instrument session.
ltfExpectedN = math.max(1.0, math.min(ltfCalendarN, nz(ltfTypicalN, ltfCalendarN)))
ltfCoverage = ltfValid and ltfN > 0 ? f_clamp(ltfNf / ltfExpectedN, 0.0, 1.0) : 0.0
ltfOK = useLTFdelta and ltfValid and ltfN > 0
ltfCoverageOK = ltfOK and (not barstate.isconfirmed or ltfCoverage >= ltfMinCoverage)
ltfQuality = ltfOK ? (barstate.isconfirmed ? ltfCoverage : 1.0) : 0.0

f_ltfPressure(_o, _h, _l, _c) =>
    float side = _c > _o ? 1.0 : _c < _o ? -1.0 : 0.0
    float r = _h - _l
    ltfDeltaMode == "Range-weighted" and r > 0 ? f_clamp(2.0 * (_c - _l) / r - 1.0, -1.0, 1.0) : side

float ltfDelta = 0.0
float ltfBuy = 0.0
float ltfSell = 0.0
if ltfOK
    for i = 0 to ltfN - 1
        float v = nz(array.get(ltfVA, i), 0.0)
        float p = f_ltfPressure(array.get(ltfOA, i), array.get(ltfHA, i), array.get(ltfLA, i), array.get(ltfCA, i))
        ltfDelta := ltfDelta + v * p
        ltfBuy := ltfBuy + v * (1.0 + p) / 2.0
        ltfSell := ltfSell + v * (1.0 - p) / 2.0
// On a completed bar, a partial intrabar sample is blended toward the geometric proxy rather than
// receiving the same confidence as a complete lower-TF reconstruction. A forming realtime bar is
// labelled separately and is not classified as a completed sample yet.
ltfBlend = ltfOK ? (barstate.isconfirmed ? (ltfCoverageOK ? 1.0 : ltfCoverage) : 1.0) : 0.0
ltfStatus = not useLTFdelta ? "off" : not ltfOK ? "Proxy" : not barstate.isconfirmed ? "Forming" : ltfCoverageOK ? "Intrabar" : "Partial"
delta = ltfOK ? ltfBlend * ltfDelta + (1.0 - ltfBlend) * deltaProxy : deltaProxy
// Buy/Sell pressure follows the same quality-aware blend as CVD, so incomplete lower-TF samples
// cannot create a stronger directional claim than the data supports.
buyVolRaw  = ltfOK ? ltfBlend * ltfBuy + (1.0 - ltfBlend) * nz(buying, 0.0) : nz(buying, 0.0)
sellVolRaw = ltfOK ? ltfBlend * ltfSell + (1.0 - ltfBlend) * nz(selling, 0.0) : nz(selling, 0.0)
buyVolSm   = ta.ema(buyVolRaw, pressureLen)
sellVolSm  = ta.ema(sellVolRaw, pressureLen)
pressureTotal = buyVolSm + sellVolSm
pressureAvailable = pressureTotal > 0
buyPct  = pressureAvailable ? 100.0 * buyVolSm / pressureTotal : 50.0
sellPct = 100.0 - buyPct
buySellPressure = pressureAvailable ? f_clamp((buyVolSm - sellVolSm) / pressureTotal, -1.0, 1.0) : 0.0
pressureSource = ltfOK ? (ltfCoverageOK ? "LTF" : "Partial") : pressureAvailable ? "Proxy" : "N/A"
cvdSum  = math.sum(delta, cvdLen)
cvdEmaV = ta.ema(delta, cvdLen)
cvdHist = cvdMode == "Periodic" ? cvdSum : cvdEmaV
cvdSlope= f_clamp(f_z(cvdHist - cvdHist[flowSlope], cvdLen)/2.0, -1.0, 1.0)
obvGap  = ta.ema(ta.obv, obvLen) - ta.sma(ta.obv, obvLen)
obvMomZ = f_clamp(f_z(obvGap, zLen)/2.0, -1.0, 1.0)
haC = (open + high + low + close)/4.0
volDirTL = haC > haC[1] ? volume : haC < haC[1] ? -volume : 0.0
var float obvTL = 0.0
obvTL := nz(obvTL[1]) + volDirTL
trafficState = obvTL > ta.ema(obvTL, 14) ? 1.0 : -1.0
// Reversal-aligned flow: the DECELERATION / TURN of the move supports a reversal,
// not its raw direction (raw CVD slope opposes the reversal exactly at the climax).
cvdTurn     = f_clamp(cvdSlope - cvdSlope[flowSlope], -1.0, 1.0)
obvTurn     = f_clamp(obvMomZ - obvMomZ[flowSlope], -1.0, 1.0)
trafficTurn = f_clamp((trafficState - trafficState[flowSlope]) / 2.0, -1.0, 1.0)
flowTurnBase = ta.ema(f_clamp(0.55*cvdTurn + 0.25*obvTurn + 0.20*trafficTurn, -1.0, 1.0), 2)
// Pressure remains within the same flow-family: it is not a new confluence voice and not a double CVD.
flowDir = useBuySellPressure and pressureAvailable ? f_clamp((flowTurnBase + pressureInfluence*buySellPressure) / (1.0 + pressureInfluence), -1.0, 1.0) : flowTurnBase

ph = ta.pivothigh(high, divN, divN)
pl = ta.pivotlow(low,  divN, divN)
pHigh0 = ta.valuewhen(not na(ph), high[divN], 0)
pHigh1 = ta.valuewhen(not na(ph), high[divN], 1)
cHigh0 = ta.valuewhen(not na(ph), cvdHist[divN], 0)
cHigh1 = ta.valuewhen(not na(ph), cvdHist[divN], 1)
pLow0  = ta.valuewhen(not na(pl), low[divN], 0)
pLow1  = ta.valuewhen(not na(pl), low[divN], 1)
cLow0  = ta.valuewhen(not na(pl), cvdHist[divN], 0)
cLow1  = ta.valuewhen(not na(pl), cvdHist[divN], 1)
bearDiv = not na(ph) and pHigh0 > pHigh1 and cHigh0 < cHigh1   // regular: price HH, CVD LH
bullDiv = not na(pl) and pLow0  < pLow1  and cLow0  > cLow1     // regular: price LL, CVD HL
hidBull = useHidden and not na(pl) and pLow0  > pLow1  and cLow0  < cLow1   // hidden: price HL, CVD LL
hidBear = useHidden and not na(ph) and pHigh0 < pHigh1 and cHigh0 > cHigh1  // hidden: price LH, CVD HH
var float divDir = 0.0
divDir := bullDiv ? 1.0 : bearDiv ? -1.0 : divDir * divDecay
var float hidDir = 0.0
hidDir := hidBull ? 1.0 : hidBear ? -1.0 : hidDir * divDecay   // + = up-continuation

// ============================================================================
// 6. SWEEP & SEMANTIC LIQUIDITY LEVELS
// ============================================================================
var float pdPOC = na   // prior-day POC — frozen from the rolling volume profile at each day change (9b)
pvtHi = ta.pivothigh(high, pvN, pvN)
pvtLo = ta.pivotlow(low,  pvN, pvN)
var float lastPH = na, var float lastPL = na, var float prevPH = na, var float prevPL = na
if not na(pvtHi)
    prevPH := lastPH
    lastPH := pvtHi
if not na(pvtLo)
    prevPL := lastPL
    lastPL := pvtLo
eqHigh = useEqual and not na(lastPH) and not na(prevPH) and math.abs(lastPH - prevPH) < eqTol*atr
eqLow  = useEqual and not na(lastPL) and not na(prevPL) and math.abs(lastPL - prevPL) < eqTol*atr

rollHi = ta.highest(high[1], rollLen)
rollLo = ta.lowest(low[1],   rollLen)
[pdh, pdl] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead = barmerge.lookahead_off)
[pwh, pwl] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead = barmerge.lookahead_off)
[pmh, pml] = request.security(syminfo.tickerid, "M", [high[1], low[1]], lookahead = barmerge.lookahead_off)

f_isRound(lev) =>
    out = false
    if useRound and not na(lev) and lev > 0 and atr > 0
        mag = math.pow(10, math.floor(math.log(lev)/math.log(10)) - 1)
        nearest = math.round(lev/mag)*mag
        out := math.abs(lev - nearest)/atr < roundTol
    out
f_levelQual(lev, isEq) =>
    1.0 + (isEq ? eqBoost : 0.0) + (f_isRound(lev) ? roundBoost : 0.0)

// Sweep as an explicit reclaim state machine (Fix #4):
//   Idle → Breached (level pierced somewhere in the last `sweepWin` bars, even on closes) →
//   Reclaimed (first close back across the level → fire ONCE) → Consumed (that level is latched
//   and cannot refire) → reset to Idle only once price digs back beyond it and rebuilds liquidity.
// Each call site (prior-day / pivot / rolling / week / month / POC) keeps its OWN `var` state,
// so distinct level sources never share a consumed latch. Fires only on confirmed closes (non-repaint).
f_swLong(lev, w, isEq) =>
    var float consumedLev = na
    lowMin = ta.lowest(low, sweepWin)
    depth  = atr > 0 and not na(lev) ? (lev - lowMin)/atr : 0.0
    breachedInWin = not na(lev) and lowMin < lev                          // pierced in window (wick OR close-through)
    sameBar       = not na(lev) and low < lev and close > lev             // classic single-candle sweep+reclaim
    reclaimClose  = breachedInWin and not na(close[1]) and close[1] <= lev and close > lev  // first close back across after older breach
    reclaim = sameBar or reclaimClose
    fresh   = na(consumedLev) or na(atr) or math.abs(lev - consumedLev) > eqTol*atr          // this exact level not already consumed
    sw = reclaim and fresh and atr > 0 and depth >= minSweepDepth
    if sw
        consumedLev := lev                                               // latch: don't refire the same level
    if not sw and not na(consumedLev) and atr > 0 and low < consumedLev - minSweepDepth*atr
        consumedLev := na                                                // price rebuilt liquidity below → level fresh again
    sw ? (0.15 + 0.85*f_clamp(depth,0,3)/3) * w * f_levelQual(lev, isEq) : 0.0
f_swShort(lev, w, isEq) =>
    var float consumedLev = na
    hiMax = ta.highest(high, sweepWin)
    depth = atr > 0 and not na(lev) ? (hiMax - lev)/atr : 0.0
    breachedInWin = not na(lev) and hiMax > lev
    sameBar       = not na(lev) and high > lev and close < lev
    reclaimClose  = breachedInWin and not na(close[1]) and close[1] >= lev and close < lev
    reclaim = sameBar or reclaimClose
    fresh   = na(consumedLev) or na(atr) or math.abs(lev - consumedLev) > eqTol*atr
    sw = reclaim and fresh and atr > 0 and depth >= minSweepDepth
    if sw
        consumedLev := lev
    if not sw and not na(consumedLev) and atr > 0 and high > consumedLev + minSweepDepth*atr
        consumedLev := na
    sw ? (0.15 + 0.85*f_clamp(depth,0,3)/3) * w * f_levelQual(lev, isEq) : 0.0

levLoSess = sweepSession ? pdl : na
levLoPiv  = sweepPivot   ? lastPL : na
levLoRoll = sweepRoll    ? rollLo : na
levLoWeek = sweepWeek    ? pwl : na
levLoMon  = sweepMonth   ? pml : na
levHiSess = sweepSession ? pdh : na
levHiPiv  = sweepPivot   ? lastPH : na
levHiRoll = sweepRoll    ? rollHi : na
levHiWeek = sweepWeek    ? pwh : na
levHiMon  = sweepMonth   ? pmh : na
levPOCd   = sweepPOC     ? pdPOC : na   // prior-day POC — sweepable from either side

sLsess = f_swLong(levLoSess, wSess, false)
sLpiv  = f_swLong(levLoPiv,  wPiv,  eqLow)
sLroll = f_swLong(levLoRoll, wRoll, false)
sLweek = f_swLong(levLoWeek, wWeek, false)
sLmon  = f_swLong(levLoMon,  wMonth, false)
sLpoc  = f_swLong(levPOCd,   wPOCr, false)
float sweepLongStr = 0.0
float bestLongLevel = na
if sLsess > sweepLongStr
    sweepLongStr := sLsess
    bestLongLevel := levLoSess
if sLpiv > sweepLongStr
    sweepLongStr := sLpiv
    bestLongLevel := levLoPiv
if sLroll > sweepLongStr
    sweepLongStr := sLroll
    bestLongLevel := levLoRoll
if sLweek > sweepLongStr
    sweepLongStr := sLweek
    bestLongLevel := levLoWeek
if sLmon > sweepLongStr
    sweepLongStr := sLmon
    bestLongLevel := levLoMon
if sLpoc > sweepLongStr
    sweepLongStr := sLpoc
    bestLongLevel := levPOCd

sSsess = f_swShort(levHiSess, wSess, false)
sSpiv  = f_swShort(levHiPiv,  wPiv,  eqHigh)
sSroll = f_swShort(levHiRoll, wRoll, false)
sSweek = f_swShort(levHiWeek, wWeek, false)
sSmon  = f_swShort(levHiMon,  wMonth, false)
sSpoc  = f_swShort(levPOCd,   wPOCr, false)
float sweepShortStr = 0.0
float bestShortLevel = na
if sSsess > sweepShortStr
    sweepShortStr := sSsess
    bestShortLevel := levHiSess
if sSpiv > sweepShortStr
    sweepShortStr := sSpiv
    bestShortLevel := levHiPiv
if sSroll > sweepShortStr
    sweepShortStr := sSroll
    bestShortLevel := levHiRoll
if sSweek > sweepShortStr
    sweepShortStr := sSweek
    bestShortLevel := levHiWeek
if sSmon > sweepShortStr
    sweepShortStr := sSmon
    bestShortLevel := levHiMon
if sSpoc > sweepShortStr
    sweepShortStr := sSpoc
    bestShortLevel := levPOCd

sweepDir = sweepLongStr > sweepShortStr and sweepLongStr > 0 ? 1 : sweepShortStr > sweepLongStr and sweepShortStr > 0 ? -1 : 0
sweepStrength = math.max(sweepLongStr, sweepShortStr)

// ============================================================================
// 7. REJECTION & ABSORPTION
// ============================================================================
clv    = rng > 0 ? ((close-low)-(high-close))/rng : 0.0
upWick = rng > 0 ? (high - math.max(open,close))/rng : 0.0
dnWick = rng > 0 ? (math.min(open,close) - low)/rng : 0.0
rejection = f_clamp(dnWick*1.5 + f_relu(clv), 0, 1) - f_clamp(upWick*1.5 + f_relu(-clv), 0, 1)
rngAtr = atr > 0 ? rng/atr : 1.0
rngRobustZ = f_rz(rng, robustLen)
rngQuiet = useRobust ? f_clamp(-rngRobustZ / 2.0, 0.0, 1.0) : f_relu(1.0 - rngAtr)
absorptionRaw = f_clamp(f_relu(rvol-1.0) * rngQuiet, 0.0, 1.0)
absorption = useAmihud ? f_clamp(absorptionRaw * (0.75 + 0.5*amiConf), 0.0, 1.0) : absorptionRaw

// ============================================================================
// 8. OPEN INTEREST  (Aggregated, COIN) + Price/OI QUADRANTS
// ============================================================================
mex = syminfo.basecurrency == "BTC" ? "XBT" : string(syminfo.basecurrency)
// Empty symbol means the chart symbol in Pine, so disabled feeds must be gated BEFORE request.security().
// Dynamic requests return [na, na] without fetching when either the OI module or that feed is disabled.
symOI1 = "BINANCE:"+string(syminfo.basecurrency)+"USDT.P_OI"
symOI2 = "BINANCE:"+string(syminfo.basecurrency)+"USD.P_OI"
symOI3 = "BINANCE:"+string(syminfo.basecurrency)+"BUSD.P_OI"
symOI4 = "BITMEX:"+mex+"USD.P_OI"
symOI5 = "BITMEX:"+mex+"USDT.P_OI"
symOI6 = "KRAKEN:"+string(syminfo.basecurrency)+"USD.P_OI"
f_oiFeed(enabled, symbol) =>
    float d = na
    float c = na
    if enabled
        [reqD, reqC] = request.security(symbol, timeframe.period, [close-close[1], close], ignore_invalid_symbol=true)
        d := reqD
        c := reqC
    [d, c]
[oid1, oic1] = f_oiFeed(useOI and oiBinance,  symOI1)
[oid2, oic2] = f_oiFeed(useOI and oiBinance2, symOI2)
[oid3, oic3] = f_oiFeed(useOI and oiBinance3, symOI3)
[oid4, oic4] = f_oiFeed(useOI and oiBitmex,   symOI4)
[oid5, oic5] = f_oiFeed(useOI and oiBitmex2,  symOI5)
[oid6, oic6] = f_oiFeed(useOI and oiKraken,   symOI6)
// Quoted in: COIN. Linear USDT/BUSD feeds are already base-denominated on the selected
// TradingView OI services. USD/inverse feeds are quote/contract notional and are converted
// with a same-base Binance USDT perpetual reference price (chart price is the fallback).
oiPxSymbol = "BINANCE:" + string(syminfo.basecurrency) + "USDT.P"
[oiPxDelta, oiPxRequested] = f_oiFeed(useOI, oiPxSymbol)
oiCoinPx = not na(oiPxRequested) and oiPxRequested > 0 ? oiPxRequested : close
f_oiToCoin(rawOi, quoteBased, px) => not na(rawOi) and px > 0 ? (quoteBased ? rawOi / px : rawOi) : na
oic1Coin = f_oiToCoin(oic1, false, oiCoinPx)  // Binance USDT.P: base COIN
oic2Coin = f_oiToCoin(oic2, true,  oiCoinPx)  // Binance USD.P: quote/inverse -> COIN
oic3Coin = f_oiToCoin(oic3, false, oiCoinPx)  // Binance BUSD.P: base COIN
oic4Coin = f_oiToCoin(oic4, true,  oiCoinPx)  // BitMEX USD.P: quote/contracts -> COIN
oic5Coin = f_oiToCoin(oic5, false, oiCoinPx)  // BitMEX USDT.P: base COIN
oic6Coin = f_oiToCoin(oic6, true,  oiCoinPx)  // Kraken USD.P: quote/contracts -> COIN
oid1Coin = oic1Coin - oic1Coin[1]
oid2Coin = oic2Coin - oic2Coin[1]
oid3Coin = oic3Coin - oic3Coin[1]
oid4Coin = oic4Coin - oic4Coin[1]
oid5Coin = oic5Coin - oic5Coin[1]
oid6Coin = oic6Coin - oic6Coin[1]
// Item 3 (OI Source Health): normalize EACH feed independently to a unit-free relative OI change
// (delta / level) so contract- and coin-denominated feeds become directly comparable — no more
// dividing by the CHART's close. Composite = mean of the AVAILABLE feeds only; missing feeds are
// EXCLUDED (not silently coerced to zero). Coverage / health are surfaced to the panel & webhook.
f_oiRel(d, c) => not na(c) and c > 0 ? d / c : na
rel1 = f_oiRel(oid1Coin, oic1Coin)
rel2 = f_oiRel(oid2Coin, oic2Coin)
rel3 = f_oiRel(oid3Coin, oic3Coin)
rel4 = f_oiRel(oid4Coin, oic4Coin)
rel5 = f_oiRel(oid5Coin, oic5Coin)
rel6 = f_oiRel(oid6Coin, oic6Coin)
oiFeedsOn    = (oiBinance?1:0)+(oiBinance2?1:0)+(oiBinance3?1:0)+(oiBitmex?1:0)+(oiBitmex2?1:0)+(oiKraken?1:0)
oiFeedsAvail = (na(rel1)?0:1)+(na(rel2)?0:1)+(na(rel3)?0:1)+(na(rel4)?0:1)+(na(rel5)?0:1)+(na(rel6)?0:1)
oiRelSum     = nz(rel1)+nz(rel2)+nz(rel3)+nz(rel4)+nz(rel5)+nz(rel6)
oiRelComp    = oiFeedsAvail > 0 ? oiRelSum / oiFeedsAvail : na
oiClose      = nz(oic1Coin)+nz(oic2Coin)+nz(oic3Coin)+nz(oic4Coin)+nz(oic5Coin)+nz(oic6Coin)  // native/converted aggregate in base COIN
oiAvailable  = useOI and oiFeedsAvail > 0
oiCoverage   = oiFeedsOn > 0 ? oiFeedsAvail / float(oiFeedsOn) : 0.0
oiHealth     = not oiAvailable ? "Unavailable" : oiCoverage >= 0.66 ? "Healthy" : "Degraded"
// OI direction over the user-selected chart-bar distance. Each venue is converted to its own
// relative N-bar change before averaging, so coin/contract-denominated levels are never summed.
f_oiTrend(c, bars) => not na(c) and not na(c[bars]) and c[bars] > 0 ? c / c[bars] - 1.0 : na
oiTr1 = f_oiTrend(oic1Coin, oiTrendLen)
oiTr2 = f_oiTrend(oic2Coin, oiTrendLen)
oiTr3 = f_oiTrend(oic3Coin, oiTrendLen)
oiTr4 = f_oiTrend(oic4Coin, oiTrendLen)
oiTr5 = f_oiTrend(oic5Coin, oiTrendLen)
oiTr6 = f_oiTrend(oic6Coin, oiTrendLen)
oiTrendFeeds = (na(oiTr1)?0:1)+(na(oiTr2)?0:1)+(na(oiTr3)?0:1)+(na(oiTr4)?0:1)+(na(oiTr5)?0:1)+(na(oiTr6)?0:1)
oiTrendRel = oiTrendFeeds > 0 ? (nz(oiTr1)+nz(oiTr2)+nz(oiTr3)+nz(oiTr4)+nz(oiTr5)+nz(oiTr6)) / oiTrendFeeds : na
oiTrendPct = not na(oiTrendRel) ? 100.0 * oiTrendRel : na
oiTrendAvailable = useOI and oiTrendFeeds > 0
oiTrendDir = not oiTrendAvailable ? 0 : oiTrendRel > 0 ? 1 : oiTrendRel < 0 ? -1 : 0
priceTrendRel = not na(close[oiTrendLen]) and close[oiTrendLen] != 0 ? close / close[oiTrendLen] - 1.0 : na
priceTrendDir = na(priceTrendRel) ? 0 : priceTrendRel > 0 ? 1 : priceTrendRel < 0 ? -1 : 0
string oiTrendContext = "Without clear direction"
if not oiTrendAvailable
    oiTrendContext := "OI N/A"
else if priceTrendDir > 0 and oiTrendDir > 0
    oiTrendContext := "Price ↑ / OI ↑"
else if priceTrendDir < 0 and oiTrendDir > 0
    oiTrendContext := "Price ↓ / OI ↑"
else if priceTrendDir > 0 and oiTrendDir < 0
    oiTrendContext := "Price ↑ / OI ↓"
else if priceTrendDir < 0 and oiTrendDir < 0
    oiTrendContext := "Price ↓ / OI ↓"
oiDeltaS = ta.sma(nz(oiRelComp, 0.0), oiSmooth)
oiZClassic = f_z(oiDeltaS, oiZlen)
oiZRobust  = f_rz(oiDeltaS, robustLen)
oiNorm = oiAvailable ? f_clamp((useRobust ? oiZRobust : oiZClassic)/2.0, -1.5, 1.5) : 0.0
oiShockDown = oiAvailable and useRobust and oiZRobust <= -robustShockZ
oiMag  = f_clamp(math.abs(oiNorm)/1.5, 0.0, 1.0)            // 0..1 strength of the OI move

// smoothed price/OI with deadbands (avoid single-bar jitter)
pMom    = close - close[oiSmooth]
pDead   = 0.1 * atr
priceUpS = pMom >  pDead
priceDnS = pMom < -pDead
oiDead  = 0.2
oiUpS   = oiNorm >  oiDead
oiDnS   = oiNorm < -oiDead

// Quadrant interpretation (boost scaled by oiMag)
// long-supportive  : price down + OI down (long liquidation / capitulation)
// long-trap        : price down + OI up   (aggressive new shorts -> continuation)
// short-supportive : price up   + OI down (short-squeeze exhaustion)
// short-trap       : price up   + OI up   (new longs -> continuation)
oiLongFactor  = oiAvailable ? ((priceDnS and oiDnS) ? 1.0+oiWeight*oiMag : (priceDnS and oiUpS) ? 1.0-oiWeight*oiMag : 1.0) : 1.0
oiShortFactor = oiAvailable ? ((priceUpS and oiDnS) ? 1.0+oiWeight*oiMag : (priceUpS and oiUpS) ? 1.0-oiWeight*oiMag : 1.0) : 1.0
oiVote = oiAvailable ? ((priceDnS and oiDnS) ? 1 : (priceUpS and oiDnS) ? -1 : 0) : 0
oiQuadName = not oiAvailable ? "N/A" : (priceDnS and oiDnS) ? "Long Liq." : (priceDnS and oiUpS) ? "New Shorts" : (priceUpS and oiDnS) ? "Short Squeeze" : (priceUpS and oiUpS) ? "New Longs" : "Neutral"

// ============================================================================
// 9. REGIME, CONTEXT, HTF, CHOP, FUNDING
// ============================================================================
logHL2  = math.pow(math.log(high/low), 2)
parkVol = math.sqrt(ta.sma(logHL2, parkLen)/(4.0*math.log(2))) * 100.0
parkMA  = ta.sma(parkVol, parkBase)
parkSD  = ta.stdev(parkVol, parkBase)
parkOsc = parkSD > 0 ? (parkVol - parkMA)/parkSD : 0.0
regimeWeight = useRegime ? f_clamp(1.0 + regimeW*f_clamp(parkOsc/2.0, -0.5, 1.0), 1.0-regimeW, 1.0+regimeW) : 1.0

[diP, diM, adxRaw] = ta.dmi(adxLen, adxSmooth)
strongTrend = adxRaw > adxThresh

distV    = atr > 0 ? math.abs(close - vwap)/atr : 5.0
// VWAP σ-bands: price position in standard deviations of its distance from VWAP.
vwapSD    = ta.stdev(close - vwap, vwapSdLen)
vwapSigma = vwapSD > 0 ? (close - vwap) / vwapSD : 0.0
// two reversal-friendly VWAP contexts: price AT the magnet (proximity) or OVERSTRETCHED beyond ~2σ
// (rubber band). They are mutually exclusive — take the stronger one, do not stack.
vwapNear    = useContext ? f_clamp(1.0 + ctxW*(1.0 - f_clamp(distV/2.0, 0, 1)), 1.0, 1.0+ctxW) : 1.0
vwapStretch = useContext ? f_clamp(1.0 + ctxW*f_clamp(math.abs(vwapSigma) - 2.0, 0.0, 1.0), 1.0, 1.0+ctxW) : 1.0
vwapMult = math.max(vwapNear, vwapStretch)
sessActive = sessOn ? not na(time(timeframe.period, sessIn)) : true
sessMult = useContext and sessOn and not sessActive ? 1.0-sessPen : 1.0
contextMult = vwapMult * sessMult

// HTF pack: with "Confirmed HTF Bars Only" every value comes from the last CLOSED HTF bar ([1]) —
// nothing drifts intrabar in realtime, at the cost of one HTF bar of lag.
// Opt: extremity proxy folded into the HTF pack — RSI/EMA/H-L + extremity in ONE request.security (was two).
f_htfPack(useConf) =>
    r = ta.rsi(close, 14)
    e = ta.ema(close, 50)
    xp = f_extProxy()
    [useConf ? r[1] : r, useConf ? close[1] : close, useConf ? e[1] : e, high[1], low[1], useConf ? xp[1] : xp]
[hRsi, hClose, hEma, htfH, htfL, hXp] = request.security(syminfo.tickerid, htfTf, f_htfPack(htfConfirm), lookahead=barmerge.lookahead_off)
htfBias = useHTF ? f_clamp((50.0 - hRsi)/50.0, -1, 1) : 0.0   // + = HTF oversold
htfUp   = useHTF and hClose > hEma
htfDown = useHTF and hClose < hEma

erChange = math.abs(close - close[erLen])
erVol = math.sum(math.abs(ta.change(close)), erLen)
er = erVol > 0 ? erChange/erVol : 0.0
choppy = useChop and er < erThresh
chopMult = choppy ? 1.0-chopPen : 1.0

fundRate = useFunding and fundSym != "" ? request.security(fundSym, timeframe.period, close, ignore_invalid_symbol=true) : na
fundAvail = not na(fundRate)
fundBias = fundAvail ? f_clamp(-f_z(fundRate, 50)/2.0, -1, 1) : 0.0   // crowded longs (high funding) -> short bias

// Spot-perp basis (optional, crypto): stretched premium = crowded longs (short bias); discount = long bias.
spotPx     = useBasis and basisSpot != "" ? request.security(basisSpot, timeframe.period, close, ignore_invalid_symbol=true) : na
basisAvail = useBasis and not na(spotPx) and spotPx > 0
basisPct   = basisAvail ? 100.0 * (close - spotPx) / spotPx : na
basisBias  = basisAvail ? f_clamp(-f_z(basisPct, 50)/2.0, -1, 1) : 0.0

// Squeeze stress is deliberately availability-aware: it needs real OI plus at least one crowding
// source (funding or basis). Missing OI is never substituted by volume. A long-side flag means a
// downside liquidation wick through crowded longs; short-side is the symmetric upside event.
crowdLong = (fundAvail and fundBias <= -squeezeCrowd) or (basisAvail and basisBias <= -squeezeCrowd)
crowdShort = (fundAvail and fundBias >= squeezeCrowd) or (basisAvail and basisBias >= squeezeCrowd)
longLiqWick = atr > 0 and (math.min(open, close) - low) >= squeezeWick * atr
shortLiqWick = atr > 0 and (high - math.max(open, close)) >= squeezeWick * atr
squeezeReady = useSqueezeStress and oiAvailable and (fundAvail or basisAvail)
longSqueezeStress = squeezeReady and oiNorm >= squeezeOiZ and crowdLong and longLiqWick
shortSqueezeStress = squeezeReady and oiNorm >= squeezeOiZ and crowdShort and shortLiqWick
squeezeStress = longSqueezeStress or shortSqueezeStress
squeezeSide = longSqueezeStress ? 1 : shortSqueezeStress ? -1 : 0

// ============================================================================
// 9b. ZONE CONTEXT & CONFIDENCE MODULES
// ============================================================================
// Over-extension: distance from mean (xATR) + consecutive momentum bars
oxMeanV = ta.ema(close, oxMean)
oxDist  = atr > 0 ? math.abs(close - oxMeanV)/atr : 0.0
var int consecUp = 0
var int consecDn = 0
consecUp := close > close[1] ? nz(consecUp[1]) + 1 : 0
consecDn := close < close[1] ? nz(consecDn[1]) + 1 : 0
consec  = math.max(consecUp, consecDn)
overext = useOverext ? f_clamp(0.5*f_clamp((oxDist-1.0)/2.0, 0, 1) + 0.5*f_clamp((consec-3)/4.0, 0, 1), 0, 1) : 0.0

// Anchored VWAP from most recent swing high / low (dynamic reversal magnets)
avwapHi = ta.vwap(hlc3, not na(pvtHi))
avwapLo = ta.vwap(hlc3, not na(pvtLo))

// Multi-oscillator divergence -> RSI + OBV only (CVD is already carried by divDir; excluding it avoids double-count)
rsiSrc = ta.rsi(close, 14)
obvSrc = ta.obv
rH0 = ta.valuewhen(not na(ph), rsiSrc[divN], 0)
rH1 = ta.valuewhen(not na(ph), rsiSrc[divN], 1)
rL0 = ta.valuewhen(not na(pl), rsiSrc[divN], 0)
rL1 = ta.valuewhen(not na(pl), rsiSrc[divN], 1)
oH0 = ta.valuewhen(not na(ph), obvSrc[divN], 0)
oH1 = ta.valuewhen(not na(ph), obvSrc[divN], 1)
oL0 = ta.valuewhen(not na(pl), obvSrc[divN], 0)
oL1 = ta.valuewhen(not na(pl), obvSrc[divN], 1)
rsiBull = not na(pl) and pLow0 < pLow1 and rL0 > rL1
rsiBear = not na(ph) and pHigh0 > pHigh1 and rH0 < rH1
obvBull = not na(pl) and pLow0 < pLow1 and oL0 > oL1
obvBear = not na(ph) and pHigh0 > pHigh1 and oH0 < oH1
bullDivCnt = (rsiBull?1:0) + (obvBull?1:0)             // both must agree (high-conviction, independent of CVD)
bearDivCnt = (rsiBear?1:0) + (obvBear?1:0)
var float multiDir = 0.0
mdRaw = bullDivCnt >= 2 ? 1.0 : bearDivCnt >= 2 ? -1.0 : 0.0
multiDir := useMultiDiv ? (mdRaw != 0.0 ? mdRaw : multiDir*divDecay) : 0.0

// Reversal candle patterns (engulfing / pin bar)
bodyR = rng > 0 ? math.abs(close - open)/rng : 0.0
bullRevCandle = (close > open and close >= high[1] and open <= close[1]) or (dnWick > 2.0*bodyR and close > (high+low)/2.0)
bearRevCandle = (close < open and close <= low[1] and open >= close[1]) or (upWick > 2.0*bodyR and close < (high+low)/2.0)

// Volume profile (rolling) -> POC / VAH / VAL
// Item 5: distribute each bar's volume across EVERY price bin its low–high range crosses (proportional
// to overlap) instead of dumping it all in one hlc3 bin — wide candles no longer create phantom nodes.
// `vol` is an array passed by reference and mutated in place. Has no ta.* → safe to call inside loops.
f_addBar(vol, lo, binSz, bins, bl, bh, bv) =>
    if not na(bl) and not na(bh) and bh >= bl and bv > 0 and binSz > 0
        float span = bh - bl
        int loI = math.max(0, math.min(bins - 1, int((bl - lo) / binSz)))
        int hiI = math.max(0, math.min(bins - 1, int((bh - lo) / binSz)))
        if hiI <= loI or span <= 0
            array.set(vol, loI, array.get(vol, loI) + bv)
        else
            for b = loI to hiI
                float binBot = lo + b * binSz
                float ov = math.min(binBot + binSz, bh) - math.max(binBot, bl)
                if ov > 0
                    array.set(vol, b, array.get(vol, b) + bv * ov / span)

// True POC of an explicit set of bars (used for the prior-day profile). Same range-distributed binning.
f_pocOf(aHi, aLo, aVo, bins) =>
    float poc = na
    int n = array.size(aVo)
    if n >= 1
        float hi = array.max(aHi)
        float lo = array.min(aLo)
        if hi > lo
            float binSz = (hi - lo) / bins
            arr = array.new<float>(bins, 0.0)
            for i = 0 to n - 1
                f_addBar(arr, lo, binSz, bins, array.get(aLo, i), array.get(aHi, i), array.get(aVo, i))
            int pocIdx = 0
            float mx = -1.0
            for b = 0 to bins - 1
                if array.get(arr, b) > mx
                    mx := array.get(arr, b)
                    pocIdx := b
            poc := lo + (pocIdx + 0.5) * binSz
    poc

// Opt: ta.highest/lowest moved OUT (must run every bar for ta state); the heavy histogram loop lives in
// f_profile(hi, lo) which now has NO ta.* — so it can be called throttled (cached between rebuilds).
f_profile(hi, lo) =>
    float poc = na
    float vah = na
    float val = na
    int look = math.min(vpLook, bar_index + 1)              // warmup guard: never index past history
    if useProfile and not na(hi) and not na(lo) and hi > lo and look >= 2
        float binSz = (hi - lo) / vpBins
        var array<float> vol = array.new<float>(vpBins, 0.0)
        for b = 0 to vpBins - 1
            array.set(vol, b, 0.0)
        for i = 0 to look - 1
            f_addBar(vol, lo, binSz, vpBins, low[i], high[i], volume[i])
        int pocIdx = 0
        float mx = -1.0
        for b = 0 to vpBins - 1
            if array.get(vol, b) > mx
                mx := array.get(vol, b)
                pocIdx := b
        poc := lo + (pocIdx + 0.5) * binSz
        float tot = array.sum(vol)
        float tgt = tot * vpVA / 100.0
        float acc = array.get(vol, pocIdx)
        int loi = pocIdx
        int hii = pocIdx
        while acc < tgt and (loi > 0 or hii < vpBins - 1)
            float below = loi > 0 ? array.get(vol, loi - 1) : -1.0
            float above = hii < vpBins - 1 ? array.get(vol, hii + 1) : -1.0
            if above >= below
                hii := hii + 1
                acc := acc + array.get(vol, hii)
            else
                loi := loi - 1
                acc := acc + array.get(vol, loi)
        val := lo + loi * binSz
        vah := lo + (hii + 1) * binSz
    [poc, vah, val]
vpHiNow = ta.highest(high, vpLook)                          // every bar (ta state) — cheap
vpLoNow = ta.lowest(low, vpLook)
var float vpPOC = na
var float vpVAH = na
var float vpVAL = na
if useProfile and (barstate.islast or na(vpPOC) or timeframe.change("D") or bar_index % vpEvery == 0)
    [pp_, vh_, vl_] = f_profile(vpHiNow, vpLoNow)
    vpPOC := pp_
    vpVAH := vh_
    vpVAL := vl_

// Item 5: TRUE prior-day POC. Accumulate ONLY the current day's bars; when a new day begins, freeze the
// POC of the day that just completed (from that day's bars alone, range-distributed) — not a rolling
// snapshot that bleeds several prior sessions.
var array<float> pdHi = array.new<float>()
var array<float> pdLo = array.new<float>()
var array<float> pdVo = array.new<float>()
if timeframe.change("D")
    if array.size(pdVo) >= 2
        pdPOC := f_pocOf(pdHi, pdLo, pdVo, vpBins)
    array.clear(pdHi)
    array.clear(pdLo)
    array.clear(pdVo)
array.push(pdHi, high)
array.push(pdLo, low)
array.push(pdVo, volume)
if array.size(pdVo) > 3000                     // safety cap for ultra-low intraday TFs (bounded memory)
    array.shift(pdHi)
    array.shift(pdLo)
    array.shift(pdVo)

// Capitulation flag: sweep + OI flush + high volume. Robust baselines reduce normal-noise bias,
// but raw robust shocks remain eligible so a genuine liquidation burst is never suppressed.
capit = useCapit and sweepStrength > 0 and oiAvailable and (oiNorm < -capOIz or oiShockDown) and (volIntensity > 1.0 or volShock)

// Proximity / edge / level-memory helpers
f_nearHTFlev(lev) => not na(lev) and atr > 0 and (math.abs(lev - htfH)/atr < htfLvlTol or math.abs(lev - htfL)/atr < htfLvlTol)
f_nearAVWAP(lev)  => not na(lev) and atr > 0 and (math.abs(lev - avwapHi)/atr < htfLvlTol or math.abs(lev - avwapLo)/atr < htfLvlTol)
f_profileEdge(sd) =>
    float out = 0.5
    if useProfile and not na(vpVAL) and not na(vpVAH) and not na(vpPOC)
        out := sd > 0 ? (close <= vpVAL ? 1.0 : close < vpPOC ? 0.55 : 0.12) : (close >= vpVAH ? 1.0 : close > vpPOC ? 0.55 : 0.12)
    out
f_levelRespect(lev, isLong, lookb) =>
    float tchW = 0.0   // recency-weighted touches
    float rspW = 0.0   // recency-weighted respects
    int   thru = 0     // bars closed decisively through the level (against reversal)
    if useLevelMem and not na(lev) and atr > 0
        for i = 1 to lookb
            w = 1.0 - (i - 1) / float(lookb)          // recent touches weigh ~1, old ~0
            extreme = isLong ? low[i] : high[i]
            near = math.abs(extreme - lev) < lvlTol*atr or (low[i] <= lev and high[i] >= lev)
            if near
                tchW := tchW + w
                respected = isLong ? close[i] > lev : close[i] < lev
                rspW := respected ? rspW + w : rspW
            through = isLong ? close[i] < lev - lvlTol*atr : close[i] > lev + lvlTol*atr
            thru := through ? thru + 1 : thru
    [tchW, rspW, lookb > 0 ? thru / float(lookb) : 0.0]

// ── Order Blocks & Fair Value Gaps (SMC confluence for sweep levels) ────────
var array<float> obTop = array.new<float>()
var array<float> obBot = array.new<float>()
var array<int>   obDir = array.new<int>()
impUp = useOB and atr > 0 and (close - close[3]) > obImpulse*atr and close > open
impDn = useOB and atr > 0 and (close[3] - close) > obImpulse*atr and close < open
if impUp or impDn
    int kOB = na
    for j = 1 to 4
        if na(kOB) and (impUp ? close[j] < open[j] : close[j] > open[j])
            kOB := j
    if not na(kOB)
        array.push(obTop, high[kOB])
        array.push(obBot, low[kOB])
        array.push(obDir, impUp ? 1 : -1)
// mitigate OBs: a bull OB dies on a close below it, a bear OB on a close above it
if array.size(obDir) > 0
    for i = array.size(obDir) - 1 to 0
        if (array.get(obDir, i) > 0 and close < array.get(obBot, i)) or (array.get(obDir, i) < 0 and close > array.get(obTop, i))
            array.remove(obTop, i)
            array.remove(obBot, i)
            array.remove(obDir, i)
while array.size(obDir) > smcMax
    array.shift(obTop)
    array.shift(obBot)
    array.shift(obDir)

var array<float> fvgTop = array.new<float>()
var array<float> fvgBot = array.new<float>()
var array<int>   fvgDir = array.new<int>()
var array<float> fvgOrigTop = array.new<float>()
var array<float> fvgOrigBot = array.new<float>()
var array<float> fvgFill = array.new<float>()

f_addFVG(float top, float bot, int d1) =>
    float t = math.max(top, bot)
    float b = math.min(top, bot)
    bool merged = false
    if array.size(fvgDir) > 0
        for i = 0 to array.size(fvgDir) - 1
            if not merged and array.get(fvgDir, i) == d1
                float eTop = array.get(fvgTop, i)
                float eBot = array.get(fvgBot, i)
                bool overlaps = not (t < eBot or b > eTop)
                if overlaps
                    float nTop = math.max(t, eTop)
                    float nBot = math.min(b, eBot)
                    float oTop = math.max(t, array.get(fvgOrigTop, i))
                    float oBot = math.min(b, array.get(fvgOrigBot, i))
                    float oRange = math.max(syminfo.mintick, oTop - oBot)
                    array.set(fvgTop, i, nTop)
                    array.set(fvgBot, i, nBot)
                    array.set(fvgOrigTop, i, oTop)
                    array.set(fvgOrigBot, i, oBot)
                    array.set(fvgFill, i, f_clamp(1.0 - (nTop - nBot) / oRange, 0.0, 1.0))
                    merged := true
    if not merged
        array.push(fvgTop, t)
        array.push(fvgBot, b)
        array.push(fvgDir, d1)
        array.push(fvgOrigTop, t)
        array.push(fvgOrigBot, b)
        array.push(fvgFill, 0.0)

f_removeFVG(int i) =>
    array.remove(fvgTop, i)
    array.remove(fvgBot, i)
    array.remove(fvgDir, i)
    array.remove(fvgOrigTop, i)
    array.remove(fvgOrigBot, i)
    array.remove(fvgFill, i)

bullFVG = useFVG and atr > 0 and low > high[2] and (low - high[2]) > 0.15*atr
bearFVG = useFVG and atr > 0 and high < low[2] and (low[2] - high) > 0.15*atr
if bullFVG
    f_addFVG(low, high[2], 1)
if bearFVG
    f_addFVG(low[2], high, -1)
// Keep only the unfilled part of every gap. Partial fills lower the confluence gradually;
// a fully traded-through gap is removed. This prevents a nearly filled FVG from acting intact.
if array.size(fvgDir) > 0
    for i = array.size(fvgDir) - 1 to 0
        float t = array.get(fvgTop, i)
        float b = array.get(fvgBot, i)
        int d1 = array.get(fvgDir, i)
        if d1 > 0 and low < t
            t := math.max(b, low)
        else if d1 < 0 and high > b
            b := math.min(t, high)
        if t <= b
            f_removeFVG(i)
        else
            float oRange = math.max(syminfo.mintick, array.get(fvgOrigTop, i) - array.get(fvgOrigBot, i))
            array.set(fvgTop, i, t)
            array.set(fvgBot, i, b)
            array.set(fvgFill, i, f_clamp(1.0 - (t - b) / oRange, 0.0, 1.0))
while array.size(fvgDir) > smcMax
    f_removeFVG(0)

f_nearOB(lev, d1) =>
    bool hit = false
    if useOB and not na(lev) and atr > 0 and array.size(obDir) > 0
        for i = 0 to array.size(obDir) - 1
            if array.get(obDir, i) == d1 and lev >= array.get(obBot, i) - smcTol*atr and lev <= array.get(obTop, i) + smcTol*atr
                hit := true
    hit
f_fvgConfluence(lev, d1) =>
    float hit = 0.0
    if useFVG and not na(lev) and atr > 0 and array.size(fvgDir) > 0
        for i = 0 to array.size(fvgDir) - 1
            if array.get(fvgDir, i) == d1 and lev >= array.get(fvgBot, i) - smcTol*atr and lev <= array.get(fvgTop, i) + smcTol*atr
                float remain = fvgDecayFill ? 1.0 - array.get(fvgFill, i) : 1.0
                hit := math.max(hit, f_clamp(remain, 0.0, 1.0))
    hit

// Continuous sweep-level quality boost (HTF + AVWAP + OB/FVG confluence) -> feeds the live score
bestLevelNow = sweepDir > 0 ? bestLongLevel : sweepDir < 0 ? bestShortLevel : na
levBoost = 1.0
levBoost := (useHTFlevels and f_nearHTFlev(bestLevelNow)) ? levBoost + htfLvlBoost : levBoost
levBoost := (useAVWAP and f_nearAVWAP(bestLevelNow)) ? levBoost + avwapBoost : levBoost
levBoost := (useOB  and f_nearOB(bestLevelNow, sweepDir))  ? levBoost + obBoost  : levBoost
levBoost := useFVG ? levBoost + fvgBoost * f_fvgConfluence(bestLevelNow, sweepDir) : levBoost
sweepStrengthAdj = sweepStrength * levBoost

// ============================================================================
// 9c. ADVANCED ANALYSIS (HTF/BTC extremity, regime weights, climax, delta-absorb,
//     liquidity map pools, killzone)
// ============================================================================
// HTF extremity composite (richer than RSI-only htfBias) + optional BTC reference
htfExt = useHtfExt ? nz(hXp) : 0.0   // Opt: reuse the combined HTF request above (no extra request.security)
btcExt = useBTCfilt ? request.security(btcSym,          timeframe.period, f_extProxy(), lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true) : na
htfDir = useHtfExt ? htfExt : htfBias                  // single HTF direction term (no RSI double-count)

// Volume climax / stopping volume (huge volume, swept extreme, closed back toward mid)
climaxLong  = useClimax and rvol >= climaxMult and low  < low[1]  and close > (high+low)/2.0
climaxShort = useClimax and rvol >= climaxMult and high > high[1] and close < (high+low)/2.0
climaxFlag  = climaxLong or climaxShort

// Wyckoff spring / upthrust: tight low-efficiency consolidation box + a poke beyond its boundary
// that closes back inside — an accumulation/distribution test, structurally stronger than a lone pivot sweep.
wyChg   = math.abs(close - close[wyBoxBars])
wyPath  = math.sum(math.abs(ta.change(close)), wyBoxBars)
wyER    = wyPath > 0 ? wyChg / wyPath : 1.0
wyBoxHi = ta.highest(high, wyBoxBars)[1]
wyBoxLo = ta.lowest(low,  wyBoxBars)[1]
isWyBox  = useWyckoff and atr > 0 and (wyBoxHi - wyBoxLo) <= wyBoxAtr*atr and wyER < 0.35
spring   = isWyBox and low  < wyBoxLo and close > wyBoxLo
upthrust = isWyBox and high > wyBoxHi and close < wyBoxHi

// Delta absorption on a sweep: price took out a level but CVD delta didn't confirm
deltaMA = ta.sma(math.abs(delta), 20)
absorbLong  = sweepDir > 0 and delta > -0.3*deltaMA
absorbShort = sweepDir < 0 and delta <  0.3*deltaMA
deltaAbsorb = useDeltaAbs and (absorbLong or absorbShort) ? f_clamp(1.0 - math.abs(delta)/(deltaMA + 1e-9), 0.0, 1.0) : 0.0

// Regime-adaptive direction weight multipliers
mExt = useRegimeWeights ? (strongTrend ? 0.7 : 1.2) : 1.0
mSwp = useRegimeWeights ? (strongTrend ? 1.3 : 1.0) : 1.0
mDiv = useRegimeWeights ? (strongTrend ? 1.3 : 1.0) : 1.0

// Killzone session gate boost
inKZ = useSession ? not na(time(timeframe.period, kzSess)) : false

// BTC alignment for alts (1 = BTC supports the reversal side, 0 = opposes)
f_btcAlign(sd) => na(btcExt) ? 0.5 : f_clamp(0.5 + 0.5*(sd > 0 ? btcExt : -btcExt), 0.0, 1.0)

// Unswept liquidity pools (resting pivot highs above / lows below) with an explicit lifecycle:
// Fresh (0) → Touched (1: price came within lvlTol but the level held) → Swept (REMOVED — the
// liquidity was consumed). Magnet strength therefore never points at liquidity that no longer
// exists, and stale re-tested levels stop inflating cluster strength.
var array<float> poolHi   = array.new<float>()
var array<int>   poolHiSt = array.new<int>()
var array<float> poolLo   = array.new<float>()
var array<int>   poolLoSt = array.new<int>()
if not na(pvtHi)
    array.push(poolHi, pvtHi)
    array.push(poolHiSt, 0)
    if array.size(poolHi) > 60
        array.shift(poolHi)
        array.shift(poolHiSt)
if not na(pvtLo)
    array.push(poolLo, pvtLo)
    array.push(poolLoSt, 0)
    if array.size(poolLo) > 60
        array.shift(poolLo)
        array.shift(poolLoSt)
// sweep / touch maintenance (confirmed bars only — no intrabar flicker)
if barstate.isconfirmed and atr > 0
    if array.size(poolHi) > 0
        for pi = array.size(poolHi) - 1 to 0
            float pp = array.get(poolHi, pi)
            if high >= pp
                array.remove(poolHi, pi)
                array.remove(poolHiSt, pi)
            else if high >= pp - lvlTol*atr
                array.set(poolHiSt, pi, 1)
    if array.size(poolLo) > 0
        for pi = array.size(poolLo) - 1 to 0
            float pp = array.get(poolLo, pi)
            if low <= pp
                array.remove(poolLo, pi)
                array.remove(poolLoSt, pi)
            else if low <= pp + lvlTol*atr
                array.set(poolLoSt, pi, 1)

// ============================================================================
// 10. SCORE ASSEMBLY
// ============================================================================
ewExt = (useExtremity ? wExt : 0.0) * mExt
ewFlow= useFlow ? wFlow : 0.0
ewDiv = (useDivergence ? wDiv : 0.0) * mDiv
ewSwp = (useSweep ? wSweepDir : 0.0) * mSwp
ewRej = useRejection ? wRej : 0.0
ewHtf = useHTF ? (useHtfExt ? htfExtW : wHtf) : 0.0   // single HTF term; richer htfExt carries its own weight
ewFun = (useFunding and fundAvail) ? wFund : 0.0
ewBas = basisAvail ? wBasis : 0.0
ewMd  = useMultiDiv ? multiDivW : 0.0
dirRaw = ewExt*extremity + ewFlow*flowDir + ewDiv*divDir + ewSwp*sweepDir + ewRej*rejection + ewHtf*htfDir + ewFun*fundBias + ewBas*basisBias + ewMd*multiDir
// active-weight normalisation: momentarily-zero modules (sweep/divergence/multidiv) must not dilute direction
activeW = ewExt + ewFlow + (math.abs(divDir)>0.05?ewDiv:0.0) + (sweepDir!=0?ewSwp:0.0) + ewRej + ewHtf + ewFun + ewBas + (math.abs(multiDir)>0.05?ewMd:0.0)
dir = activeW > 0 ? f_clamp(dirRaw/activeW, -1.0, 1.0) : 0.0

// counter-trend penalties combined as a SINGLE haircut (max, not product) so the reversals
// this tool hunts aren't triple-penalised for being counter-trend
penTrend = (useContext and strongTrend) ? trendPen : 0.0
penHtf   = (useHTF and ((dir>0 and htfDown) or (dir<0 and htfUp))) ? htfTrendPen : 0.0
penHid   = (useHidden and ((dir>0 and hidDir<-0.3) or (dir<0 and hidDir>0.3))) ? hiddenW : 0.0
dir := dir * (1.0 - math.max(penTrend, math.max(penHtf, penHid)))

// side-aware OI quadrant multiplier
oiMult = dir > 0 ? oiLongFactor : dir < 0 ? oiShortFactor : 1.0

// Fix #6: event-gate components must be SIDE-ALIGNED with the composite direction, otherwise an
// opposite-side event (e.g. a bearish rejection wick) could amplify a LONG signal via |rejection|.
gateSgn = dir > 0 ? 1 : dir < 0 ? -1 : 0
// sweep: only the sweep that agrees with the signal side contributes (sweepDir is directional)
gSweepM = (useSweep and sweepDir == gateSgn) ? sweepStrengthAdj : 0.0
// delta-absorption is aligned to its sweep side; passive-size absorption is genuinely side-neutral
gDeltaM = (useDeltaAbs and ((gateSgn > 0 and absorbLong) or (gateSgn < 0 and absorbShort))) ? deltaAbsorb : 0.0
gAbsM   = math.max(useAbsorption ? absorption : 0.0, gDeltaM)
// rejection: bullish rejection (>0) only for longs, bearish (<0) only for shorts
gRejM   = (useRejection and math.sign(rejection) == gateSgn) ? math.abs(rejection) : 0.0
gOxM    = useOverext ? oxW*overext : 0.0
// climax / Wyckoff: long climax + spring back longs; short climax + upthrust back shorts
gClimaxM = (useClimax and ((gateSgn > 0 and climaxLong) or (gateSgn < 0 and climaxShort))) ? 0.3 : 0.0
gKzM     = (useSession and inKZ) ? kzBoost : 0.0
gWyM     = (useWyckoff and ((gateSgn > 0 and spring) or (gateSgn < 0 and upthrust))) ? wyBoost : 0.0
gSqM     = squeezeSide != 0 and squeezeSide == gateSgn ? squeezeBoost : 0.0
eventGate = f_clamp(baseFloor + kSweep*gSweepM + kAbs*gAbsM + kRej*gRejM + gOxM + gClimaxM + gKzM + gWyM + gSqM, 0.0, 2.0)

// magnitude adjusters AVERAGED (not multiplied) so a stack of bounded factors can't over-disperse the score
adjFactor = (oiMult + regimeWeight + contextMult + chopMult) / 4.0
volAmp = useVolume ? (1.0 - volAmpW) + volAmpW*volIntensity : 1.0   // controllable volume leverage (rebalance vs OI/regime/context)
amp = volAmp * adjFactor
score = 100.0 * f_soft(dir * eventGate * amp * scoreScale / 100.0)  // smooth saturation: never flat-tops at ±100, keeps ranking of the most extreme
scoreSmooth = ta.ema(score, sigLen)
absScore = math.abs(score)

// ── COMPOSITE MARKET BIAS (-100..+100) ─────────────────────────────────────
// Five independent families prevent the former double-counting of final LRZ score + its inputs.
// Context 30%: reversal extremity/divergence. Flow 30%: CVD/OBV + Buy/Sell exactly once.
// Events 20%: rejection/sweep combined into one family. OI 10%. HTF 10%.
pCtxExtW = useExtremity ? 0.65 : 0.0
pCtxDivW = useDivergence ? 0.25 : 0.0
pCtxMulW = useMultiDiv ? 0.10 : 0.0
pCtxWeight = pCtxExtW + pCtxDivW + pCtxMulW
pContextComp = pCtxWeight > 0 ? f_clamp((pCtxExtW*extremity + pCtxDivW*divDir + pCtxMulW*multiDir) / pCtxWeight, -1.0, 1.0) : 0.0
pFlowComp = useFlow ? flowDir : 0.0
pEvtRejW = useRejection ? 0.50 : 0.0
pEvtSwpW = useSweep and sweepDir != 0 ? 0.50 : 0.0
pEvtWeight = pEvtRejW + pEvtSwpW
pEventComp = pEvtWeight > 0 ? f_clamp((pEvtRejW*rejection + pEvtSwpW*sweepDir*f_clamp(sweepStrengthAdj, 0.0, 1.0)) / pEvtWeight, -1.0, 1.0) : 0.0
pOiComp = useOI and oiAvailable ? oiVote * oiMag : 0.0
pHtfComp = useHTF and not na(htfDir) ? htfDir : 0.0
pWContext = pCtxWeight > 0 ? 0.30 : 0.0
pWFlow = useFlow ? 0.30 : 0.0
pWEvent = pEvtWeight > 0 ? 0.20 : 0.0
pWOi = useOI and oiAvailable ? 0.10 : 0.0
pWHtf = useHTF and not na(htfDir) ? 0.10 : 0.0
pWeight = pWContext + pWFlow + pWEvent + pWOi + pWHtf
pSignedSum = pWContext*pContextComp + pWFlow*pFlowComp + pWEvent*pEventComp + pWOi*pOiComp + pWHtf*pHtfComp
pEvidenceSum = pWContext*math.abs(pContextComp) + pWFlow*math.abs(pFlowComp) + pWEvent*math.abs(pEventComp) + pWOi*math.abs(pOiComp) + pWHtf*math.abs(pHtfComp)
pBias = pWeight > 0 ? f_clamp(pSignedSum / pWeight, -1.0, 1.0) : 0.0
pEvidence = pWeight > 0 ? f_clamp(pEvidenceSum / pWeight, 0.0, 1.0) : 0.0
pVolActivity = pressureAvailable ? f_clamp((rvol - 0.5) / 1.5, 0.0, 1.0) : 0.0
pEventActivity = f_clamp((eventGate - baseFloor) / math.max(0.25, 2.0 - baseFloor), 0.0, 1.0)
pActivity = f_clamp(0.65*pEvidence + 0.20*pVolActivity + 0.15*pEventActivity, 0.0, 1.0)
// The non-linear gain makes the moderate coherent pressure visible. Activity and coherence
// extinguish weak and contradictory components; the total still returns to a neutral 0.
marketPressureRaw = f_activePressure(pBias, pEvidence, pActivity)
marketPressure = ta.ema(marketPressureRaw, pressureBarLen)
// Adaptive full scale: rolling P80, bounded so quiet markets stay readable and volatile markets do not flat-top.
pressureScaleRaw = ta.percentile_nearest_rank(math.abs(marketPressure), 200, 80)
pressureScale = f_clamp(nz(pressureScaleRaw, 50.0), 25.0, 60.0)
var int pressureDirState = 0
pressureDirState := f_pressureState(pressureDirState, marketPressure)

// ---- Adaptive (with absolute floor) vs Fixed thresholds ----
pr = ta.percentrank(absScore, prLen)
strongOK = threshMode == "Adaptive" ? (pr >= strongPct and absScore >= minAbsFloor) : absScore >= strongThresh
medOK    = threshMode == "Adaptive" ? (pr >= medPct    and absScore >= minAbsFloor) : absScore >= medThresh
bucketName = strongOK ? "STRONG" : medOK ? "MEDIUM" : "WEAK"

// ---- Confluence count (deadbanded, CVD-deduplicated) ----
sgn = dir > 0 ? 1 : dir < 0 ? -1 : 0
voteExt   = useExtremity  and math.abs(extremity) > confDead and math.sign(extremity) == sgn
voteFlow  = useFlow       and math.abs(flowDir)   > confDead and math.sign(flowDir)   == sgn
voteDiv   = useDivergence and math.abs(divDir)    > confDead and math.sign(divDir)    == sgn
cvdVote   = voteFlow or voteDiv   // flow & divergence both come from CVD -> at most one combined vote
voteSweep = useSweep      and sweepDir == sgn
voteRej   = useRejection  and math.abs(rejection) > confDead and math.sign(rejection) == sgn
voteOI    = useOI and oiAvailable and oiVote == sgn
voteHtf   = useHTF        and math.abs(htfDir)   > confDead and math.sign(htfDir)   == sgn
voteFun   = (useFunding and fundAvail) and math.abs(fundBias) > confDead and math.sign(fundBias) == sgn
voteBas   = basisAvail and math.abs(basisBias) > confDead and math.sign(basisBias) == sgn
conf = (voteExt?1:0)+(cvdVote?1:0)+(voteSweep?1:0)+(voteRej?1:0)+(voteOI?1:0)+(voteHtf?1:0)+(voteFun?1:0)+(voteBas?1:0)
conf := sgn == 0 ? 0 : conf
// Item 6: normalize the N-of-M gate by the modules that are actually ENABLED + AVAILABLE this bar,
// so requiring e.g. 5 votes is never unsatisfiable when OI / funding / basis are simply absent.
voteSrcAvail = (useExtremity?1:0)+((useFlow or useDivergence)?1:0)+(useSweep?1:0)+(useRejection?1:0)+((useOI and oiAvailable)?1:0)+(useHTF?1:0)+((useFunding and fundAvail)?1:0)+(basisAvail?1:0)
minConfEff = math.min(minConf, math.max(1, voteSrcAvail))
confOK = conf >= minConfEff

// Item 3 (Data Availability Score): fraction of ENABLED optional feeds actually available this bar.
// 1.0 = every enabled feed present; low = the composite is leaning on missing inputs.
dqEn = (useOI?1:0)+(useFunding?1:0)+(useBasis?1:0)+((useHTF or useHtfExt)?1:0)+(useLTFdelta?1:0)+(useProfile?1:0)+(useBTCfilt?1:0)
dqAv = ((useOI and oiAvailable)?1:0)+((useFunding and fundAvail)?1:0)+((useBasis and basisAvail)?1:0)+(((useHTF or useHtfExt) and not na(hClose))?1:0)+((useLTFdelta and ltfQuality > 0)?ltfQuality:0)+((useProfile and not na(vpPOC))?1:0)+((useBTCfilt and not na(btcExt))?1:0)
dataQuality = dqEn > 0 ? dqAv / float(dqEn) : 1.0
pressureAgreement = pEvidence > 0 ? f_clamp(math.abs(pBias) / pEvidence, 0.0, 1.0) : 0.0
// Confidence is separate from displayed magnitude: good feeds alone are insufficient without evidence and agreement.
pressureConfidence = f_clamp(dataQuality * math.sqrt(pEvidence * pressureAgreement), 0.0, 1.0)

// ============================================================================
// 11. SIGNAL & CONFIRMATION
// ============================================================================
bullPat = not usePattern or bullRevCandle
bearPat = not usePattern or bearRevCandle
// Fix #5: with the Liquidity Sweep module OFF a sweep is no longer REQUIRED to trigger — it only
// drops out of direction/score/gate. With it ON, behaviour is unchanged (sweep still mandatory).
longSetup  = (not useSweep or sweepDir > 0) and dir > 0 and medOK and bullPat
shortSetup = (not useSweep or sweepDir < 0) and dir < 0 and medOK and bearPat
// ── Fix #1: full SETUP-BAR SNAPSHOT ──────────────────────────────────────────
// On every setup bar we compute the COMPLETE analytical metric set (direction, sweep level, zone bounds,
// score, ATR, zone confidence, capit & trend flags). Instant reads them
// live; Strict reads the SAME snapshot one bar later via [1], so a Strict signal is a faithful
// confirmation of that setup — never a hybrid of the setup bar and the confirmation bar.
setupSide = longSetup ? 1 : shortSetup ? -1 : 0
setupLev  = longSetup ? bestLongLevel : shortSetup ? bestShortLevel : na
setupTop  = longSetup ? (na(bestLongLevel) ? high : bestLongLevel) : shortSetup ? high : na
setupBot  = longSetup ? low : shortSetup ? (na(bestShortLevel) ? low : bestShortLevel) : na
float sZConf  = na
if setupSide != 0
    lev0 = setupLev
    [tchW, rspW, thruFrac] = f_levelRespect(lev0, setupSide > 0, lvlMemLook)
    respR   = tchW > 0.5 ? rspW / tchW : 0.55
    lvlConf = f_clamp(respR * (1.0 - f_clamp((tchW - 1.0)/12.0, 0.0, 0.35)) * (1.0 - f_clamp(thruFrac*1.5, 0.0, 0.5)), 0, 1)
    nearH = useHTFlevels and f_nearHTFlev(lev0)
    nearA = useAVWAP and f_nearAVWAP(lev0)
    pe    = f_profileEdge(setupSide)
    ba    = useBTCfilt ? f_btcAlign(setupSide) : 0.5
    nearS = (useOB and f_nearOB(lev0, setupSide)) or (useFVG and f_fvgConfluence(lev0, setupSide) > 0)
    // Item 3: availability-aware zone confidence = mean of the VALID components only. A module that is
    // OFF or whose data is missing is excluded from BOTH sum and count (no fake neutral 0.12 / 0.5);
    // a measured-absent component (e.g. level simply not near an HTF level) still counts, as a real 0.
    vHtf = useHTFlevels
    vAvw = useAVWAP
    vSmc = useOB or useFVG
    vOx  = useOverext
    vCap = useCapit and oiAvailable
    vPe  = useProfile and not na(vpPOC)
    vBa  = useBTCfilt and not na(btcExt)
    ccSum = lvlConf + (vHtf?(nearH?1.0:0.0):0.0) + (vAvw?(nearA?1.0:0.0):0.0) + (vSmc?(nearS?1.0:0.0):0.0) + (vOx?overext:0.0) + (vCap?(capit?1.0:0.0):0.0) + (vPe?pe:0.0) + (vBa?ba:0.0)
    ccCnt = 1 + (vHtf?1:0) + (vAvw?1:0) + (vSmc?1:0) + (vOx?1:0) + (vCap?1:0) + (vPe?1:0) + (vBa?1:0)
    sZConf := ccCnt > 0 ? f_clamp(ccSum / ccCnt, 0, 1) : 0.5

strictMode = confirmMode == "Strict"
confLong  = strictMode ? (longSetup[1]  and close > close[1]) : longSetup
confShort = strictMode ? (shortSetup[1] and close < close[1]) : shortSetup

var int lastSignalBar = -100000
var int lastLongBar    = -100000
var int lastShortBar   = -100000
coolL   = cooldownPerDir ? (bar_index - lastLongBar  >= cooldownBars) : (bar_index - lastSignalBar >= cooldownBars)
coolS   = cooldownPerDir ? (bar_index - lastShortBar >= cooldownBars) : (bar_index - lastSignalBar >= cooldownBars)
// Strict: confluence & chop are taken from the SETUP bar too — the confirmation bar only has to
// confirm price direction, it must not re-qualify the setup with different-bar state.
confOKEff = strictMode ? confOK[1] : confOK
choppyEff = strictMode ? choppy[1] : choppy
canFireBase = confOKEff and not (useChop and choppyEff) and barstate.isconfirmed
doLong  = confLong  and canFireBase and coolL
doShort = confShort and canFireBase and coolS

// resolve the setup snapshot for THIS signal: Strict → the setup bar one bar back; Instant → live.
snapTop   = strictMode ? setupTop[1] : setupTop
snapBot   = strictMode ? setupBot[1] : setupBot
snapScore = strictMode ? score[1]    : score
snapCapit = strictMode ? capit[1]    : capit

// Expose the latest analytical zone confidence to the dashboard and feed.
var float zConf = na
if doLong or doShort
    zConf   := strictMode ? sZConf[1]  : sZConf

// ============================================================================
// 12. ZONE LIFECYCLE (Active / Tested / Confirmed / Mitigated) + MERGE + POC
// ============================================================================
type Zone
    box   bx     = na
    int   dir    = 0
    float top    = na
    float bot    = na
    int   bornBar= 0
    int   resolvedBar = na
    bool  entered   = false
    int   enteredBar = na
    int   lastRetest = -100000
    float sc     = 0.0
    int   state  = 0
    float anchor = na
    bool  frozen = false
    float prob   = na
    bool  cap    = false
    float atr0   = na

var array<Zone> zones = array.new<Zone>()
var int lastZoneId = na    // bornBar of the zone the latest signal created/merged into (for agent correlation)

// ── zone visual helpers ─────────────────────────────────────────────
// fill transparency: denser for higher analytical confidence, fades with age
f_zFill(prob, age) =>
    int base = na(prob) ? zoneFillTr : int(f_clamp(zoneFillTr - (prob - 50.0)*0.5, 35, 97))
    int a = ageFade ? int(f_clamp(age/float(ageFadeBars)*28.0, 0, 28)) : 0
    math.min(99, base + a)

// border transparency: brighter for higher analytical confidence, fades with age
f_zBorderTr(prob, age) =>
    int base = borderByConf ? (na(prob) ? 45 : int(f_clamp(60.0 - (prob - 50.0)*0.9, 8, 70))) : 32
    int a = ageFade ? int(f_clamp(age/float(ageFadeBars)*30.0, 0, 35)) : 0
    math.min(95, base + a)

// border width scales with analytical confidence
f_zBorderW(prob) =>
    borderByConf and not na(prob) ? (prob >= 70 ? 3 : prob >= 55 ? 2 : 1) : 1

// reposition gradient slices + strength bar to current bounds (after a merge)
f_styleZone(Zone z) =>
    col = z.dir > 0 ? colLong : colShort
    int age = bar_index - z.bornBar
    int ftr = f_zFill(z.prob, age)
    int btr = f_zBorderTr(z.prob, age)
    int bw  = f_zBorderW(z.prob)
    if z.state == 1
        ftr := math.max(30, ftr - 10)
    else if z.state == 2                 // confirmed: drop fill, keep a crisp outline
        ftr := 100
        btr := math.max(6, btr - 30)
        bw  := math.max(2, bw)
    else if z.state == 3                 // mitigated: ghost it
        ftr := 100
        btr := 88
    if not na(z.bx)
        box.set_bgcolor(z.bx, ftr >= 100 ? na : color.new(col, ftr))
        box.set_border_color(z.bx, color.new(z.state == 3 ? colNeutral : col, btr))
        box.set_border_style(z.bx, z.state == 3 ? line.style_dotted : line.style_solid)
        box.set_border_width(z.bx, bw)

f_extendZone(Zone z, int r) =>
    if not na(z.bx)
        box.set_right(z.bx, r)

// try to merge a fresh signal into an existing live same-direction overlapping zone.
// returns the merged zone's id (bornBar), or na if nothing merged.
f_tryMerge(int d, float top, float bot, float sc, float prob) =>
    int mergedId = na
    if array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            Zone z = array.get(zones, i)
            if not z.frozen and z.dir == d and na(mergedId)
                overlap = not (math.min(top,bot) > z.top + mergeTol*atr or math.max(top,bot) < z.bot - mergeTol*atr)
                if overlap
                    z.top := math.max(z.top, math.max(top,bot))
                    z.bot := math.min(z.bot, math.min(top,bot))
                    z.sc  := math.max(z.sc, sc)
                    z.prob := na(z.prob) ? prob : (na(prob) ? z.prob : math.max(z.prob, prob))
                    if not na(z.bx)
                        box.set_top(z.bx, z.top)
                        box.set_bottom(z.bx, z.bot)
                    mergedId := z.bornBar
    mergedId

f_newZone(int d, float top, float bot, float sc, float anchor, float prob, bool capf) =>
    col = d > 0 ? colLong : colShort
    float t = math.max(top, bot)
    float b = math.min(top, bot)
    // enforce a minimum visible/tradable height around the anchor (11)
    float minH = minZoneAtr * atr
    if minH > 0 and (t - b) < minH
        float mid = (t + b) / 2.0
        t := mid + minH/2.0
        b := mid - minH/2.0
    int   L = bar_index - 2
    int   R = bar_index + extendBars
    int ftr = f_zFill(prob, 0)
    int btr = f_zBorderTr(prob, 0)
    int bw  = f_zBorderW(prob)
    bcol = color.new(capf ? colAccent : col, btr)
    box bx = showZones ? box.new(L, t, R, b, border_color = bcol, bgcolor = color.new(col, ftr), border_width = capf ? math.max(2, bw) : bw, force_overlay = true, xloc = xloc.bar_index) : na   // Fix #2: draw only when showing
    Zone z = Zone.new(bx = bx, dir = d, top = t, bot = b, bornBar = bar_index, sc = sc, state = 0, anchor = anchor, frozen = false, prob = prob, cap = capf, atr0 = atr)
    array.push(zones, z)
    z.bornBar

// lifecycle events surfaced from the update loop (for alerts + agent feed)
bool zEntered  = false
int  zEnteredDir = 0
int  zEnteredId  = na
float zEnteredTop = na
float zEnteredBot = na
float zEnteredProb = na
int  zEnteredAge = 0
bool zRetest   = false
int  zRetestDir = 0
int  zRetestId  = na
float zRetestProb = na
bool zConfirmed = false
bool zMitigated = false
int  zEvDir  = 0      // dir of the zone that confirmed/mitigated
int  zEvId   = na
int  zEvAge  = 0      // its lifespan in bars
float zEvTop = na
float zEvBot = na
float zEvProb = na
// Per-bar EVENT QUEUES: when several zones fire the same event on one bar, EVERY one reaches the
// feed. The scalar vars above keep only the last event (used for alertconditions & chart markers).
evEntId  = array.new<int>()
evEntDir = array.new<int>()
evEntTop = array.new<float>()
evEntBot = array.new<float>()
evEntPrb = array.new<float>()
evEntAge = array.new<int>()
evRtId   = array.new<int>()
evRtDir  = array.new<int>()
evRtPrb  = array.new<float>()
evStId   = array.new<int>()
evStDir  = array.new<int>()
evStCf   = array.new<bool>()
evStPrb  = array.new<float>()
evStAge  = array.new<int>()
evStTop  = array.new<float>()
evStBot  = array.new<float>()

// update all live zones each bar. Fix #2: the analytical lifecycle (entry/retest/confirm/mitigate,
// lastZoneId, alerts & feed) runs ALWAYS; showZones only controls whether boxes are drawn & styled.
if array.size(zones) > 0
    for i = 0 to array.size(zones) - 1
        Zone z = array.get(zones, i)
        if not z.frozen
            f_extendZone(z, bar_index + extendBars)
            bool inZoneNow = low <= z.top and high >= z.bot
            // first-touch entry (6)
            if not z.entered and inZoneNow
                z.entered := true
                z.enteredBar := bar_index
                zEntered := true
                zEnteredDir := z.dir
                zEnteredId := z.bornBar
                zEnteredTop := z.top
                zEnteredBot := z.bot
                zEnteredProb := z.prob
                zEnteredAge := bar_index - z.bornBar
                array.push(evEntId, z.bornBar)
                array.push(evEntDir, z.dir)
                array.push(evEntTop, z.top)
                array.push(evEntBot, z.bot)
                array.push(evEntPrb, z.prob)
                array.push(evEntAge, bar_index - z.bornBar)
            if z.state == 0 and inZoneNow
                z.state := 1
            // retest (5): after the zone has already been tested, price returns and rejects from it.
            // Fix #3: only from the bar AFTER first touch, so a first touch can't be entry AND retest at once.
            if useRetest and z.state >= 1 and not na(z.enteredBar) and bar_index > z.enteredBar and inZoneNow and (bar_index - z.lastRetest) >= retestCooldown
                float rtRng = high - low
                float wick = z.dir > 0 ? (math.min(open, close) - low) : (high - math.max(open, close))
                bool rejOK = rtRng > 0 and (wick / rtRng) >= retestRejFrac
                bool closeBack = z.dir > 0 ? close > z.bot : close < z.top
                if rejOK and closeBack
                    z.lastRetest := bar_index
                    zRetest := true
                    zRetestDir := z.dir
                    zRetestId := z.bornBar
                    zRetestProb := z.prob
                    array.push(evRtId, z.bornBar)
                    array.push(evRtDir, z.dir)
                    array.push(evRtPrb, z.prob)
            confAtr = na(z.atr0) ? atr : z.atr0
            if z.dir > 0
                if high >= z.anchor + confirmAtr*confAtr
                    z.state := 2
                else if close < z.bot
                    z.state := 3
            else
                if low <= z.anchor - confirmAtr*confAtr
                    z.state := 2
                else if close > z.top
                    z.state := 3
            f_styleZone(z)
            if z.state == 2 or z.state == 3
                f_extendZone(z, bar_index)   // D3: pin the resolved zone here — don't drag it to the live bar
                z.frozen := true
                z.resolvedBar := bar_index
                zEvDir := z.dir
                zEvId := z.bornBar
                zEvAge := bar_index - z.bornBar
                zEvTop := z.top
                zEvBot := z.bot
                zEvProb := z.prob
                array.push(evStId, z.bornBar)
                array.push(evStDir, z.dir)
                array.push(evStCf, z.state == 2)
                array.push(evStPrb, z.prob)
                array.push(evStAge, bar_index - z.bornBar)
                array.push(evStTop, z.top)
                array.push(evStBot, z.bot)
                if z.state == 2
                    zConfirmed := true
                else
                    zMitigated := true

// create / merge on confirmed signal — Fix #2: zone maintenance ALWAYS runs (independent of showZones);
// Fix #1: bounds / score / prob / capit all come from the setup snapshot, not the confirmation bar.
if doLong
    int mId = f_tryMerge(1, nz(snapTop, high), nz(snapBot, low), snapScore, zConf*100.0)
    if na(mId)
        lastZoneId := f_newZone(1, nz(snapTop, high), nz(snapBot, low), snapScore, close, zConf*100.0, snapCapit)
    else
        lastZoneId := mId
    lastSignalBar := bar_index
    lastLongBar := bar_index
if doShort
    int mId = f_tryMerge(-1, nz(snapTop, high), nz(snapBot, low), snapScore, zConf*100.0)
    if na(mId)
        lastZoneId := f_newZone(-1, nz(snapTop, high), nz(snapBot, low), snapScore, close, zConf*100.0, snapCapit)
    else
        lastZoneId := mId
    lastSignalBar := bar_index
    lastShortBar := bar_index

f_deleteZone(Zone z) =>
    if not na(z.bx)
        box.delete(z.bx)

// prune oldest when exceeding cap
while array.size(zones) > maxZones
    Zone old = array.shift(zones)
    f_deleteZone(old)

// F: auto-remove resolved (confirmed/mitigated) zones after a fixed span, instead of letting them
// pile up on the chart forever — keeps only the 2-4 zones that are actually still relevant.
if resolvedFadeBars > 0 and array.size(zones) > 0
    for i = array.size(zones) - 1 to 0
        Zone z = array.get(zones, i)
        if z.frozen and not na(z.resolvedBar) and (bar_index - z.resolvedBar) > resolvedFadeBars
            f_deleteZone(z)
            array.remove(zones, i)

// ── HTF reversal zones (8): sweep+rejection detected on a higher timeframe, projected here ──
// IMPORTANT: request only OHLC primitives (no nested request.security — the full engine can't be
// re-run on HTF because it already contains security calls). We recompute a self-contained
// sweep+rejection on the HTF bars. lookahead_off + latch on a new HTF bar = non-repaint.
[hHi, hLo, hCl, hOp, hPHi, hPLo, hAtr] = request.security(htfZonesOn ? syminfo.tickerid : "", htfZTF, [high, low, close, open, high[1], low[1], ta.atr(14)], lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)   // Opt: skip fetch when HTF zones off; Item 7: HTF ATR for consistent thickness
float hRange = na(hHi) ? na : math.max(hHi - hLo, syminfo.mintick)
htfLongSig  = htfZonesOn and not na(hLo) and hLo < hPLo and hCl > hPLo and (math.min(hOp, hCl) - hLo)/hRange >= 0.4
htfShortSig = htfZonesOn and not na(hHi) and hHi > hPHi and hCl < hPHi and (hHi - math.max(hOp, hCl))/hRange >= 0.4
htfNewBar = ta.change(time(htfZTF)) != 0
var array<box>   hzBox = array.new<box>()
var array<int>   hzDir = array.new<int>()
var array<float> hzTop = array.new<float>()
var array<float> hzBot = array.new<float>()
var array<bool>  hzEntered = array.new<bool>()
bool htfEnteredEvt = false
int  htfEnteredDir = 0
bool htfNewEvt = false
int  htfNewDir = 0
float htfNewTop = na
float htfNewBot = na
if htfZonesOn and htfZValid
    // create a projected zone when a HTF bar just closed with a valid sweep+rejection
    if htfNewBar and (htfLongSig or htfShortSig) and not na(hHi) and not na(hLo)
        int hd = htfLongSig ? 1 : -1
        float ext = htfZExtAtr * nz(hAtr, atr)   // Item 7: use the HTF's OWN ATR, not the chart ATR
        float ht = hd > 0 ? math.max(hPLo, hLo + ext) : hHi
        float hb = hd > 0 ? hLo : math.min(hPHi, hHi - ext)
        col = hd > 0 ? colLong : colShort
        b = box.new(bar_index - 1, ht, bar_index + extendBars, hb, border_color = color.new(col, 25), bgcolor = color.new(col, htfZTr), border_width = 2, border_style = line.style_dashed, force_overlay = true, xloc = xloc.bar_index)
        array.push(hzBox, b)
        array.push(hzDir, hd)
        array.push(hzTop, ht)
        array.push(hzBot, hb)
        array.push(hzEntered, false)
        htfNewEvt := true
        htfNewDir := hd
        htfNewTop := ht
        htfNewBot := hb
    // extend live HTF zones + detect first entry
    if array.size(hzBox) > 0
        for i = 0 to array.size(hzBox) - 1
            box.set_right(array.get(hzBox, i), bar_index + extendBars)
            if not array.get(hzEntered, i) and low <= array.get(hzTop, i) and high >= array.get(hzBot, i)
                array.set(hzEntered, i, true)
                htfEnteredEvt := true
                htfEnteredDir := array.get(hzDir, i)
    // prune oldest
    while array.size(hzBox) > htfZMax
        box.delete(array.shift(hzBox))
        array.shift(hzDir)
        array.shift(hzTop)
        array.shift(hzBot)
        array.shift(hzEntered)

// ============================================================================
// 14. PANEL PLOTTING
// ============================================================================
// Display orientation: UP = OVERBOUGHT, DOWN = OVERSOLD  (internal score: + = oversold/long)
outScore  = -score
outSmooth = -scoreSmooth
gradTop = threshMode == "Adaptive" ? 80.0 : strongThresh
sideTop = outScore >= 0
scoreCol = sideTop ? color.from_gradient(absScore, 0, gradTop, color.new(colShort,72), colShort) : color.from_gradient(absScore, 0, gradTop, color.new(colLong,72), colLong)
useArea = displayStyle == "Area"
useHist = displayStyle == "Histogram"
useCol  = displayStyle == "Columns"
// Area = faint side-tinted fill + crisp gradient line on top (quiet silhouette, loud edge)
fillCol = sideTop ? color.new(colShort, 84) : color.new(colLong, 84)
plot(useArea ? outScore : na, "Score Fill", color = fillCol,  style = plot.style_area)
plot(useArea ? outScore : na, "Score Line", color = scoreCol, style = plot.style_line, linewidth = 2)
plot(useHist ? outScore : na, "Score (Hist)", color = scoreCol, style = plot.style_histogram, linewidth = 2)
plot(useCol  ? outScore : na, "Score (Col)",  color = scoreCol, style = plot.style_columns, linewidth = 4)
plot(showSignal ? outSmooth : na, "Signal", color = color.new(colSig, 20), linewidth = 1)

// Actual trigger levels: dynamic in Adaptive (percentile of the score's own distribution, with the
// absolute floor) so the reference matches where STRONG/MEDIUM really fire; flat in Fixed mode.
pctStrong = ta.percentile_linear_interpolation(absScore, prLen, strongPct)
pctMed    = ta.percentile_linear_interpolation(absScore, prLen, medPct)
strongLvl = threshMode == "Fixed" ? strongThresh : math.max(pctStrong, minAbsFloor)
medLvl    = threshMode == "Fixed" ? medThresh    : math.max(pctMed,    minAbsFloor)

hline(0, "Zero", color.new(colNeutral, 55))

// Overbought / oversold shown as shaded bands (medium→strong), not a picket fence of lines
pOBs = plot(showThreshZones ? strongLvl  : na, "OB Strong", color.new(colShort, 90), editable=false)
pOBm = plot(showThreshZones ? medLvl     : na, "OB Medium", color.new(colShort, 90), editable=false)
pOSm = plot(showThreshZones ? -medLvl    : na, "OS Medium", color.new(colLong, 90),  editable=false)
pOSs = plot(showThreshZones ? -strongLvl : na, "OS Strong", color.new(colLong, 90),  editable=false)
fill(pOBm, pOBs, color = showThreshZones ? color.new(colShort, 86) : na, title = "Overbought Band")
fill(pOSm, pOSs, color = showThreshZones ? color.new(colLong, 86)  : na, title = "Oversold Band")

// Panel state background (periphery read of regime): capitulation accent > strong zone side > none
panelBg = capit ? color.new(colAccent, 84) : (strongOK and absScore > 0 ? color.new(score > 0 ? colLong : colShort, 91) : na)
bgcolor(showStateBG ? panelBg : na, title = "Panel State BG")

// retest marker on the price chart (small diamond at the rejecting wick)
plotshape(useRetest and zRetest and zRetestDir > 0 ? low : na,  "Retest Long",  style=shape.diamond, location=location.absolute, color=colLong,  size=size.tiny, force_overlay=true)
plotshape(useRetest and zRetest and zRetestDir < 0 ? high : na, "Retest Short", style=shape.diamond, location=location.absolute, color=colShort, size=size.tiny, force_overlay=true)

// ── Debug series (Data Window only — no chart clutter): why is the score what it is? (10) ──
plot(showDebug ? extZ      : na, "dbg extremity",  display=display.data_window)
plot(showDebug ? flowDir   : na, "dbg flow",       display=display.data_window)
plot(showDebug ? divDir    : na, "dbg divergence", display=display.data_window)
plot(showDebug ? sweepDir  : na, "dbg sweepDir",   display=display.data_window)
plot(showDebug ? sweepStrength : na, "dbg sweepStr", display=display.data_window)
plot(showDebug ? eventGate : na, "dbg eventGate",  display=display.data_window)
plot(showDebug ? amp       : na, "dbg amp",        display=display.data_window)
plot(showDebug ? dir       : na, "dbg dir",        display=display.data_window)
plot(showDebug ? conf      : na, "dbg confluence", display=display.data_window)
plot(showDebug ? rvol      : na, "dbg rvol",       display=display.data_window)
plot(showDebug ? score     : na, "dbg score",      display=display.data_window)
plot(showDebug ? vwapSigma : na, "dbg vwapSigma",  display=display.data_window)
plot(showDebug ? amiConf   : na, "dbg amihudConf", display=display.data_window)
plot(showDebug ? volZRobust : na, "dbg volRobustZ", display=display.data_window)
plot(showDebug ? oiZRobust  : na, "dbg oiRobustZ", display=display.data_window)
plot(showDebug ? rngRobustZ : na, "dbg rangeRobustZ", display=display.data_window)
plot(showDebug ? levBoost  : na, "dbg levBoost",   display=display.data_window)
plot(showDebug ? (spring ? 1 : upthrust ? -1 : 0) : na, "dbg wyckoff",  display=display.data_window)
plot(showDebug ? ltfQuality : na, "dbg ltfCoverage", display=display.data_window)
plot(showDebug ? (squeezeSide != 0 ? squeezeSide : 0) : na, "dbg squeezeStress", display=display.data_window)


// ============================================================================
// 15. DASHBOARD
// ============================================================================
// compact visual helpers
f_meter(v) =>
    int segs = 8
    int fill = int(math.round(f_clamp(v, 0, 100) / 100.0 * segs))
    string s = ""
    for i = 0 to segs - 1
        s := s + (i < fill ? "█" : "░")
    s
f_conf(n, need) =>
    int total = math.min(math.max(n, need), 8)   // 8 vote sources since v3
    string s = ""
    if total > 0
        for i = 1 to total
            s := s + (i <= n ? "●" : "○")
    s + (math.max(n, need) > 8 ? "+" : "")

if showDash and barstate.islast
    string side  = score > 0 ? "OVERSALE ↓" : score < 0 ? "OVERBUYING ↑" : "NEUTRAL"
    color  sideC = score > 0 ? colLong : score < 0 ? colShort : colNeutral

    // volume framing (priority: where big volume passed)
    string volTag = rvol >= 2.5 ? "EXTREME" : rvol >= 1.5 ? "TALL" : rvol >= 0.9 ? "MEDIUM" : "LOW"
    color  volC   = rvol >= 1.5 ? colAccent : rvol >= 0.9 ? colText : colNeutral
    string node = (not useProfile or na(vpPOC)) ? "—" : close >= vpVAH ? "above VAH" : close <= vpVAL ? "below VAL" : math.abs(close - vpPOC) <= 0.25*atr ? "on the POC" : close > vpPOC ? "the top of the VA" : "the bottom of the VA"

    // context merged: HTF bias + regime + chop
    string ctx  = "HTF " + (useHTF ? (htfUp?"▲":htfDown?"▼":"·") : "·") + " " + (htfConfirm?"CONF":"LIVE") + (htfTfValid?"":" ⚠TF") + "  ·  " + (strongTrend?"TREND":"FLAT") + (choppy?" · CHOP":"")
    color  ctxC = choppy ? colAccent : colText


    var table d = table.new(position.top_right, 2, 9, bgcolor = colPanelBg, frame_color = colFrame, frame_width = 1, border_color = color.new(colFrame,35), border_width = 1)

    // ── Banner: the verdict ──
    table.merge_cells(d, 0, 0, 1, 0)
    table.cell(d,0,0, side + "    " + bucketName, text_color=colText, bgcolor=color.new(sideC,15), text_halign=text.align_center, text_size=size.normal)

    // ── Strength (live OB/OS reading) ── visual meter + confluence dots, highlighted
    table.cell(d,0,1,"Strength", text_color=colNeutral, text_halign=text.align_left, text_size=size.small)
    table.cell(d,1,1, f_meter(absScore) + "  " + str.tostring(absScore,"#") + "   " + f_conf(conf, minConfEff), text_color=sideC, text_halign=text.align_right, text_size=size.small, bgcolor=color.new(sideC, (strongOK and confOK)?78:92))

    // ── Volume (priority) ── highlighted with accent
    table.cell(d,0,2,"Volume", text_color=colNeutral, text_halign=text.align_left, text_size=size.small)
    table.cell(d,1,2, str.tostring(rvol,"#.#")+"×  "+volTag+"  B"+str.tostring(buyPct,"#")+"/S"+str.tostring(sellPct,"#")+"  Δ"+ltfStatus+" "+str.tostring(ltfCoverage*100,"#")+"%", text_color=volC, text_halign=text.align_right, text_size=size.small, bgcolor=color.new(colAccent,90))
    table.cell(d,0,3,"Volume node", text_color=colNeutral, text_halign=text.align_left, text_size=size.small)
    table.cell(d,1,3, node, text_color=colText, text_halign=text.align_right, text_size=size.small)

    // ── Liquidity / Open Interest ──
    table.cell(d,0,4,"OI · COIN", text_color=colNeutral, text_halign=text.align_left, text_size=size.small)
    table.cell(d,1,4, oiAvailable ? (oiQuadName+"  "+str.tostring(oiFeedsAvail)+"/"+str.tostring(oiFeedsOn)+"  "+oiHealth+(squeezeStress ? (squeezeSide>0?"  SQZ-L":"  SQZ-S") : "")) : (useOI?"Not available":"off"), text_color=oiAvailable?(squeezeStress?colAccent:oiCoverage>=0.66?colText:colAccent):colNeutral, text_halign=text.align_right, text_size=size.small)

    // ── Sweep ──
    table.cell(d,0,5,"Sweep", text_color=colNeutral, text_halign=text.align_left, text_size=size.small)
    table.cell(d,1,5, sweepDir>0?("LONG  "+str.tostring(sweepStrength,"#.##")):sweepDir<0?("SHORT  "+str.tostring(sweepStrength,"#.##")):"—", text_color=sweepDir>0?colLong:sweepDir<0?colShort:colNeutral, text_halign=text.align_right, text_size=size.small)

    // ── Context (HTF · regime · chop) ──
    table.cell(d,0,6,"Context", text_color=colNeutral, text_halign=text.align_left, text_size=size.small)
    table.cell(d,1,6, ctx, text_color=ctxC, text_halign=text.align_right, text_size=size.small)

    // ── Data availability (Item 3) ──
    table.cell(d,0,7,"Data quality", text_color=colNeutral, text_halign=text.align_left, text_size=size.small)
    table.cell(d,1,7, str.tostring(dataQuality*100.0,"#")+"%  ("+str.tostring(dqAv)+"/"+str.tostring(dqEn)+")", text_color=dataQuality>=0.75?colText:dataQuality>=0.5?colAccent:colShort, text_halign=text.align_right, text_size=size.small)
    // ── thin footer key ──
    table.merge_cells(d, 0, 8, 1, 8)
    table.cell(d,0,8, "█ strength · ● confluence", text_color=color.new(colNeutral,30), text_halign=text.align_center, text_size=size.tiny)

// ── Composite Pressure bar: one direction from zero midpoint ─────────────────
// Only the winning side fills the 5 short segments from the center outwards. Top = SELL, bottom = BUY.
// The central line gives the reference 0 and the current LRZ score; footer is a compact raw volume B/S.
if showPressureBar and barstate.islast
    int pressureSteps = 5
    float pressureAbs = f_clamp(math.abs(nz(marketPressure, 0.0)), 0.0, 100.0)
    int pressureDir = pressureDirState
    // Adaptive thresholds equal approximately 5/12/22/35/50 when P80 scale is 50.
    // In quiet/volatile regimes the full scale automatically stays within 25..60.
    int pressureCells = 0
    if pressureDir != 0
        pressureCells := 1
        if pressureAbs >= pressureScale
            pressureCells := 5
        else if pressureAbs >= 0.70*pressureScale
            pressureCells := 4
        else if pressureAbs >= 0.44*pressureScale
            pressureCells := 3
        else if pressureAbs >= 0.24*pressureScale
            pressureCells := 2
    color pressureCol = pressureDir > 0 ? colLong : pressureDir < 0 ? colShort : colNeutral
    string pressureArrow = pressureDir > 0 ? "▼" : pressureDir < 0 ? "▲" : "◆"
    string pressureTitle = pressureArrow + " " + str.tostring(pressureAbs, "#") + "%"
    string lrZTxt = "0│LRZ " + (score > 0 ? "+" : "") + str.tostring(score, "#")
    string sourceCode = ltfOK ? "L" : pressureAvailable ? "P" : "–"
    string qualityMark = "●"
    color qualityCol = pressureConfidence >= 0.70 ? colLong : pressureConfidence >= 0.45 ? colAccent : colNeutral
    string rawTxt = "▼" + str.tostring(buyPct,"#") + "·▲" + str.tostring(sellPct,"#") + " " + sourceCode + qualityMark
    string oiTrendArrow = not oiTrendAvailable ? "◆" : oiTrendDir > 0 ? "▲" : oiTrendDir < 0 ? "▼" : "→"
    string oiTrendSign = oiTrendAvailable and oiTrendPct > 0 ? "+" : ""
    string oiTrendTxt = oiTrendAvailable ? "OI[C]" + oiTrendArrow + oiTrendSign + str.tostring(oiTrendPct, "#.##") + "%·" + str.tostring(oiTrendLen) : "OI[C]◆ N/A"
    color oiTrendCol = oiTrendAvailable ? colText : colNeutral
    var table pb = table.new(position.top_right, 1, 14, bgcolor = colPanelBg, frame_color = colFrame, frame_width = 1, border_color = color.new(colFrame,35), border_width = 1)
    table.cell(pb, 0, 0, pressureTitle, text_color = pressureCol, bgcolor = color.new(pressureCol, 84), text_halign = text.align_center, text_size = size.small, tooltip = "Composite Bias: independent Context, Flow, Events, OI and HTF")
    for r = 1 to pressureSteps
        bool fillUp = pressureDir < 0 and r >= pressureSteps + 1 - pressureCells
        string upBlocks = fillUp ? "████" : "░░░░"
        color upText = fillUp ? colShort : color.new(colShort, 82)
        color upBg = fillUp ? color.new(colShort, 78) : colPanelBg
        table.cell(pb, 0, r, upBlocks, text_color = upText, bgcolor = upBg, text_halign = text.align_center, text_size = size.tiny)
    table.cell(pb, 0, pressureSteps + 1, lrZTxt, text_color = colText, bgcolor = color.new(colNeutral, 78), text_halign = text.align_center, text_size = size.tiny)
    for r = 1 to pressureSteps
        bool fillDown = pressureDir > 0 and r <= pressureCells
        string dnBlocks = fillDown ? "████" : "░░░░"
        color dnText = fillDown ? colLong : color.new(colLong, 82)
        color dnBg = fillDown ? color.new(colLong, 78) : colPanelBg
        int row = pressureSteps + 1 + r
        table.cell(pb, 0, row, dnBlocks, text_color = dnText, bgcolor = dnBg, text_halign = text.align_center, text_size = size.tiny)
    table.cell(pb, 0, pressureSteps*2 + 2, rawTxt, text_color = qualityCol, bgcolor = color.new(colPanelBg, 0), text_halign = text.align_center, text_size = size.tiny, tooltip = "B/S — estimate of Buy/Sell volume; L — lower-TF, P — proxy; ● — confidence " + str.tostring(pressureConfidence*100.0, "#") + "%")
    table.cell(pb, 0, pressureSteps*2 + 3, oiTrendTxt, text_color = oiTrendCol, bgcolor = color.new(colPanelBg, 0), text_halign = text.align_center, text_size = size.tiny, tooltip = "Quoted in: COIN · " + oiTrendContext + " for " + str.tostring(oiTrendLen) + " candles; aggregated feeds: " + str.tostring(oiTrendFeeds))

// ============================================================================
// 16. ALERTS (static + structured dynamic)
// ============================================================================
alertcondition(doLong,  "Reversal zone Long",  "LRZ: LONG reversal zone")
alertcondition(doShort, "Reversal zone Short", "LRZ: SHORT reversal zone")
alertcondition(doLong  and strongOK, "Long's strong zone",  "LRZ: STRONG reversal zone long")
alertcondition(doShort and strongOK, "Short's strong zone", "LRZ: STRONG reversal zone short")
alertcondition(bullDiv, "Bullish CVD divergence", "LRZ: CVD Bullish Divergence")
alertcondition(bearDiv, "Bearish CVD divergence", "LRZ: bearish CVD divergence")
alertcondition(capit, "Capitulation", "LRZ: conditions of surrender (sweep + drain OI + volume)")
alertcondition(longSqueezeStress, "Long squeeze stress", "LRZ: crowded-long liquidation wick with OI build")
alertcondition(shortSqueezeStress, "Short squeeze stress", "LRZ: crowded-short liquidation wick with OI build")
alertcondition(spring, "Wyckoff Spring", "LRZ: Wyckoff spring (consolidation bottom sweep + reclaim)")
alertcondition(upthrust, "Wyckoff Upthrust", "LRZ: Wyckoff upthrust (consolidation top sweep + throwback)")
alertcondition(zRetest and zRetestDir > 0, "Retest Long",  "LRZ: The price retested the LONG zone and bounced back up")
alertcondition(zRetest and zRetestDir < 0, "Retest Short", "LRZ: The price retested the SHORT zone and bounced back down")
alertcondition(alertEntry and zEntered, "The price entered the zone", "LRZ: the price entered the reversal zone")
alertcondition(alertState and zConfirmed, "Zone Confirmed", "LRZ: zone confirmed by analytical follow-through")
alertcondition(alertState and zMitigated, "Mitigated zone", "LRZ: zone invalidated")
alertcondition(alertHtfEntry and htfEnteredEvt and htfEnteredDir > 0, "The price entered the Long HTF zone",  "LRZ: the price entered the LONG zone of the senior TF")
alertcondition(alertHtfEntry and htfEnteredEvt and htfEnteredDir < 0, "The price entered the Short HTF zone", "LRZ: the price entered the SHORT zone of the senior TF")

// ── UNIFIED AGENT FEED ──────────────────────────────────────────────────────
// One UI alert ("Any alert() function call" + webhook URL) carries every message below.
// Every payload is self-contained JSON sharing an envelope: event, tk, tf, t (ms), bar —
// the agent orders by t/bar, deduplicates, and gap-detects via the snapshot heartbeat.
f_jn(v, fmt) => na(v) ? "null" : str.tostring(v, fmt)          // null-safe number
f_jb(b) => b ? "true" : "false"
f_env(eventName) => '{"v":1,"event":"' + eventName + '","tk":"' + syminfo.ticker + '","tf":"' + timeframe.period + '","t":' + str.tostring(time) + ',"bar":' + str.tostring(bar_index)

// nearest unswept liquidity pool above/below + how many pivots cluster at it (magnet strength)
f_pool(isHi) =>
    float best = na
    if isHi
        if array.size(poolHi) > 0
            for k = 0 to array.size(poolHi) - 1
                p = array.get(poolHi, k)
                if p > close and (na(best) or p < best)
                    best := p
    else
        if array.size(poolLo) > 0
            for k = 0 to array.size(poolLo) - 1
                p = array.get(poolLo, k)
                if p < close and (na(best) or p > best)
                    best := p
    // freshness-weighted magnet strength in half-points: fresh pool = 2, touched = 1
    int strg = 0
    if not na(best)
        if isHi
            for k = 0 to array.size(poolHi) - 1
                if math.abs(array.get(poolHi, k) - best) <= lvlTol*atr
                    strg += array.get(poolHiSt, k) == 0 ? 2 : 1
        else
            for k = 0 to array.size(poolLo) - 1
                if math.abs(array.get(poolLo, k) - best) <= lvlTol*atr
                    strg += array.get(poolLoSt, k) == 0 ? 2 : 1
    [best, strg]

regimeStr = choppy ? "CHOP" : strongTrend ? "TREND" : "RANGE"
bucketLvl = strongOK ? 2 : medOK ? 1 : 0
sideSgn   = score > 0 ? 1 : score < 0 ? -1 : 0
vwapDistSigned = atr > 0 ? (close - vwap)/atr : na    // signed distance to VWAP in ATR
kzActive  = useSession and inKZ

// context-change trackers (updated every bar so toggling the feed on doesn't burst stale events)
var string prevOiQuad = ""
var string prevRegime = ""
var int    prevBucket = 0
var int    prevSide   = 0
bool oiQuadChg = oiAvailable and oiQuadName != prevOiQuad and prevOiQuad != ""
bool regimeChg = regimeStr != prevRegime and prevRegime != ""
bool threshChg = (bucketLvl != prevBucket or (bucketLvl > 0 and sideSgn != prevSide))
bool stateChg  = oiQuadChg or regimeChg or threshChg

if feedOn and barstate.isconfirmed
    // ── signals ──
    if feedSignals and (doLong or doShort)
        d = doLong ? 1 : -1
        lev = strictMode ? setupLev[1] : setupLev              // Fix #1: swept level from the setup snapshot
        string sigMsg = f_env("signal")
        sigMsg += ',"zid":' + f_jn(lastZoneId,"#") + ',"side":"' + (doLong ? "LONG" : "SHORT") + '","zconf":' + f_jn(zConf,"#.##")
        sigMsg += ',"score":' + str.tostring(-score,"#.#") + ',"conf":' + str.tostring(conf)
        sigMsg += ',"buyPct":' + f_jn(buyPct,"#.#") + ',"sellPct":' + f_jn(sellPct,"#.#") + ',"volumePressure":' + f_jn(buySellPressure,"#.###") + ',"marketPressure":' + f_jn(marketPressure,"#.#") + ',"pressureSrc":"' + pressureSource + '"'
        sigMsg += ',"atr":' + f_jn(atr,format.mintick) + ',"oi":"' + oiQuadName + '","oiNorm":' + f_jn(oiAvailable ? oiNorm : na,"#.##") + ',"capit":' + f_jb(capit) + ',"squeeze":' + f_jb(squeezeStress) + ',"squeezeSide":' + str.tostring(squeezeSide)
        sigMsg += ',"htfDir":' + f_jn(htfDir,"#.##") + ',"vwapDist":' + f_jn(vwapDistSigned,"#.##") + ',"kz":' + f_jb(kzActive) + ',"level":' + f_jn(lev,format.mintick) + ',"price":' + str.tostring(close,format.mintick)
        sigMsg += ',"dataQuality":' + f_jn(dataQuality,"#.##") + ',"ltf":"' + ltfStatus + '","ltfCoverage":' + f_jn(ltfCoverage,"#.##") + ',"oiHealth":"' + oiHealth + '","oiFeeds":"' + str.tostring(oiFeedsAvail) + "/" + str.tostring(oiFeedsOn) + '"'
        sigMsg += '}'
        alert(sigMsg, alert.freq_once_per_bar_close)
    if feedSignals and useRetest and array.size(evRtId) > 0
        for ei = 0 to array.size(evRtId) - 1
            alert(f_env("retest") + ',"zid":' + f_jn(array.get(evRtId, ei),"#") + ',"side":"' + (array.get(evRtDir, ei) > 0 ? "LONG" : "SHORT") + '","confidence":' + f_jn(array.get(evRtPrb, ei),"#") + ',"price":' + str.tostring(close,format.mintick) + ',"atr":' + f_jn(atr,format.mintick) + '}', alert.freq_once_per_bar_close)
    // ── zone lifecycle ──
    if feedZones and array.size(evEntId) > 0
        for ei = 0 to array.size(evEntId) - 1
            alert(f_env("zone_touch") + ',"zid":' + f_jn(array.get(evEntId, ei),"#") + ',"side":"' + (array.get(evEntDir, ei) > 0 ? "LONG" : "SHORT") + '","confidence":' + f_jn(array.get(evEntPrb, ei),"#") + ',"top":' + f_jn(array.get(evEntTop, ei),format.mintick) + ',"bot":' + f_jn(array.get(evEntBot, ei),format.mintick) + ',"ageBars":' + str.tostring(array.get(evEntAge, ei)) + ',"price":' + str.tostring(close,format.mintick) + '}', alert.freq_once_per_bar_close)
    if feedZones and array.size(evStId) > 0
        for ei = 0 to array.size(evStId) - 1
            alert(f_env("zone_state") + ',"zid":' + f_jn(array.get(evStId, ei),"#") + ',"state":"' + (array.get(evStCf, ei) ? "CONFIRMED" : "MITIGATED") + '","side":"' + (array.get(evStDir, ei) > 0 ? "LONG" : "SHORT") + '","confidence":' + f_jn(array.get(evStPrb, ei),"#") + ',"ageBars":' + str.tostring(array.get(evStAge, ei)) + ',"top":' + f_jn(array.get(evStTop, ei),format.mintick) + ',"bot":' + f_jn(array.get(evStBot, ei),format.mintick) + '}', alert.freq_once_per_bar_close)
    if feedZones and htfZonesOn and htfNewEvt
        alert(f_env("htf_zone_new") + ',"side":"' + (htfNewDir > 0 ? "LONG" : "SHORT") + '","htf":"' + htfZTF + '","top":' + f_jn(htfNewTop,format.mintick) + ',"bot":' + f_jn(htfNewBot,format.mintick) + '}', alert.freq_once_per_bar_close)
    if feedZones and htfZonesOn and htfEnteredEvt
        alert(f_env("htf_zone_entry") + ',"side":"' + (htfEnteredDir > 0 ? "LONG" : "SHORT") + '","htf":"' + htfZTF + '","price":' + str.tostring(close,format.mintick) + '}', alert.freq_once_per_bar_close)
    // ── liquidity events (raw material for the agent, even without a full signal) ──
    if feedLiquidity and sweepDir != 0
        swLev = sweepDir > 0 ? bestLongLevel : bestShortLevel
        alert(f_env("sweep") + ',"side":"' + (sweepDir > 0 ? "LOW" : "HIGH") + '","level":' + f_jn(swLev,format.mintick) + ',"strength":' + f_jn(sweepStrength,"#.##") + ',"rvol":' + f_jn(rvol,"#.##") + ',"volZ":' + f_jn(volZ,"#.##") + ',"clv":' + f_jn(clv,"#.##") + ',"absorb":' + f_jn(deltaAbsorb,"#.##") + ',"reclaim":' + f_jb(sweepDir > 0 ? close > swLev : close < swLev) + '}', alert.freq_once_per_bar_close)
    if feedLiquidity and capit
        alert(f_env("capitulation") + ',"score":' + str.tostring(-score,"#.#") + ',"rvol":' + f_jn(rvol,"#.##") + ',"oi":"' + oiQuadName + '"}', alert.freq_once_per_bar_close)
    if feedLiquidity and squeezeStress
        alert(f_env("squeeze_stress") + ',"side":"' + (squeezeSide > 0 ? "LONG_LIQ" : "SHORT_LIQ") + '","oiNorm":' + f_jn(oiNorm,"#.##") + ',"fundBias":' + f_jn(fundBias,"#.##") + ',"basisBias":' + f_jn(basisBias,"#.##") + '}', alert.freq_once_per_bar_close)
    if feedLiquidity and climaxFlag
        alert(f_env("climax") + ',"rvol":' + f_jn(rvol,"#.##") + ',"side":"' + (close > open ? "UP" : "DOWN") + '"}', alert.freq_once_per_bar_close)
    if feedLiquidity and (spring or upthrust)
        alert(f_env("wyckoff") + ',"type":"' + (spring ? "SPRING" : "UPTHRUST") + '","boxHi":' + f_jn(wyBoxHi,format.mintick) + ',"boxLo":' + f_jn(wyBoxLo,format.mintick) + ',"rvol":' + f_jn(rvol,"#.##") + '}', alert.freq_once_per_bar_close)
    if feedLiquidity and (bullDiv or bearDiv)
        alert(f_env("divergence") + ',"side":"' + (bullDiv ? "BULL" : "BEAR") + '"}', alert.freq_once_per_bar_close)
    // ── context changes ──
    if feedContext and oiQuadChg
        alert(f_env("oi_quadrant") + ',"from":"' + prevOiQuad + '","to":"' + oiQuadName + '","oiValue":' + f_jn(oiClose,"#.##") + ',"oiUnit":"COIN","oiTrendPct":' + f_jn(oiTrendPct,"#.###") + ',"oiTrendBars":' + str.tostring(oiTrendLen) + '}', alert.freq_once_per_bar_close)
    if feedContext and regimeChg
        alert(f_env("regime") + ',"from":"' + prevRegime + '","to":"' + regimeStr + '"}', alert.freq_once_per_bar_close)
    if feedContext and threshChg and (bucketLvl > 0 or prevBucket > 0)
        alert(f_env("threshold") + ',"level":"' + (bucketLvl == 2 ? "STRONG" : bucketLvl == 1 ? "MEDIUM" : "NONE") + '","side":"' + (sideSgn > 0 ? "OVERSOLD" : sideSgn < 0 ? "OVERBOUGHT" : "NEUTRAL") + '","score":' + str.tostring(-score,"#.#") + '}', alert.freq_once_per_bar_close)
    // ── state snapshot (telemetry / heartbeat) ──
    // Always snap on an event bar (so signals carry full context), on state change, on cadence,
    // and at least every feedSnapN bars as a heartbeat so the agent can detect webhook gaps.
    bool anyEvent = doLong or doShort or zRetest or zEntered or zConfirmed or zMitigated or (sweepDir != 0) or capit or squeezeStress or climaxFlag or bullDiv or bearDiv or spring or upthrust or stateChg
    var int lastSnapBar = -100000
    bool heartbeat = (bar_index - lastSnapBar) >= feedSnapN
    bool snapDue = feedSnapshot != "Off" and (feedSnapshot == "Every Bar" or (feedSnapshot == "Every N Bars" and bar_index % feedSnapN == 0) or (feedSnapshot == "On State Change" and (stateChg or anyEvent or heartbeat)))
    if snapDue
        lastSnapBar := bar_index
        int zAct = 0
        int zTest = 0
        if array.size(zones) > 0
            for zi = 0 to array.size(zones) - 1
                Zone zz = array.get(zones, zi)
                if not zz.frozen
                    if zz.state == 0
                        zAct += 1
                    else if zz.state == 1
                        zTest += 1
        string profNode = (not useProfile or na(vpPOC)) ? "NA" : close>=vpVAH ? "ABOVE_VAH" : close<=vpVAL ? "BELOW_VAL" : close>vpPOC ? "UPPER_VA" : "LOWER_VA"
        [poolAbove, poolAboveStr] = f_pool(true)
        [poolBelow, poolBelowStr] = f_pool(false)
        alert(f_env("snapshot")
             + ',"score":' + str.tostring(-score,"#.#") + ',"bucket":"' + (bucketLvl == 2 ? "STRONG" : bucketLvl == 1 ? "MEDIUM" : "NONE") + '","side":"' + (sideSgn > 0 ? "OVERSOLD" : sideSgn < 0 ? "OVERBOUGHT" : "NEUTRAL") + '"'
             + ',"comp":{"ext":' + f_jn(extZ,"#.##") + ',"flow":' + f_jn(flowDir,"#.##") + ',"buyPct":' + f_jn(buyPct,"#.#") + ',"sellPct":' + f_jn(sellPct,"#.#") + ',"volumePressure":' + f_jn(buySellPressure,"#.###") + ',"marketPressure":' + f_jn(marketPressure,"#.#") + ',"pressureSrc":"' + pressureSource + '","div":' + f_jn(divDir,"#.##") + ',"swp":' + str.tostring(sweepDir) + ',"swpS":' + f_jn(sweepStrength,"#.##") + ',"gate":' + f_jn(eventGate,"#.##") + ',"amp":' + f_jn(amp,"#.##") + '}'
             + ',"conf":' + str.tostring(conf) + ',"rvol":' + f_jn(rvol,"#.##") + ',"volZ":' + f_jn(volZ,"#.##") + ',"clv":' + f_jn(clv,"#.##") + ',"er":' + f_jn(er,"#.##") + ',"regime":"' + regimeStr + '","kz":' + f_jb(kzActive) + ',"htfDir":' + f_jn(htfDir,"#.##") + ',"htfMode":"' + (htfConfirm?"CONF":"LIVE") + '","htfTfValid":' + f_jb(htfTfValid) + ',"htfZValid":' + f_jb(htfZValid) + ',"vwapDist":' + f_jn(vwapDistSigned,"#.##") + ',"vwapSig":' + f_jn(vwapSigma,"#.##")
             + ',"oi":"' + (oiAvailable ? oiQuadName : "N/A") + '","oiValue":' + f_jn(oiAvailable ? oiClose : na,"#.##") + ',"oiUnit":"COIN","oiTrendPct":' + f_jn(oiTrendPct,"#.###") + ',"oiTrendBars":' + str.tostring(oiTrendLen) + ',"oiNorm":' + f_jn(oiAvailable ? oiNorm : na,"#.##") + ',"oiHealth":"' + oiHealth + '","oiFeeds":"' + str.tostring(oiFeedsAvail) + "/" + str.tostring(oiFeedsOn) + '","dataQuality":' + f_jn(dataQuality,"#.##") + ',"ltf":"' + ltfStatus + '","ltfCoverage":' + f_jn(ltfCoverage,"#.##") + ',"squeeze":' + f_jb(squeezeStress) + ',"squeezeSide":' + str.tostring(squeezeSide) + ',"funding":' + f_jn(useFunding ? fundRate : na,"#.#####") + ',"basis":' + f_jn(basisAvail ? basisPct : na,"#.###")
             + ',"profile":{"poc":' + f_jn(vpPOC,format.mintick) + ',"vah":' + f_jn(vpVAH,format.mintick) + ',"val":' + f_jn(vpVAL,format.mintick) + ',"node":"' + profNode + '"}'
             + ',"pools":{"above":' + f_jn(poolAbove,format.mintick) + ',"aboveStr":' + str.tostring(poolAboveStr) + ',"below":' + f_jn(poolBelow,format.mintick) + ',"belowStr":' + str.tostring(poolBelowStr) + '}'
             + ',"zones":{"active":' + str.tostring(zAct) + ',"tested":' + str.tostring(zTest) + '}'
             + ',"o":' + str.tostring(open,format.mintick) + ',"h":' + str.tostring(high,format.mintick) + ',"l":' + str.tostring(low,format.mintick) + ',"price":' + str.tostring(close,format.mintick) + ',"atr":' + f_jn(atr,format.mintick) + '}', alert.freq_once_per_bar_close)

// update trackers AFTER events are emitted (so from/to pairs are correct), every bar
prevOiQuad := oiAvailable ? oiQuadName : prevOiQuad
prevRegime := regimeStr
prevBucket := bucketLvl
prevSide   := sideSgn
````
