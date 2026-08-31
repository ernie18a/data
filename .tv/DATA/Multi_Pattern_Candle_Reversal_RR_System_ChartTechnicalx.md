<!-- tradingview-pine-id: PUB;9d9ab39692cd43cb8537ffcc0092da19 -->
<!-- tradingviewscripts-format: 1 -->
# Multi Pattern Candle Reversal RR System [ChartTechnicalx]

Source: https://www.tradingview.com/script/xDkya0eG-Multi-Pattern-Candle-Reversal-RR-System-ChartTechnicalx/

## Description

A multi-pattern reversal/breakout scanner with automatic risk:reward boxes, forward trade tracking, and a live win-rate table.

This tool scans price action for four distinct setups — small-candle rejections, engulfing reversals, compression breakouts, and pole-and-flag structures — and, when one fires, plots the entry, stop-loss, and take-profit as boxes projected forward on the chart. Every signal is tracked bar-by-bar against its SL/TP so you get an honest, non-repainting record of how each pattern actually performed, summarized in an on-chart results table (win / loss / close-to-cost / win rate).

No repainting: every signal and every trade outcome is calculated only on confirmed (closed) bars.

How it works

The indicator looks for four independent pattern types. Any of them can trigger a long or short signal; you can enable/disable each one separately.

1. Small Candle Pattern

[image]https://www.tradingview.com/x/7pDLBPds/[/image]

A small-bodied rejection candle at a fresh swing low/high, followed by a small-bodied confirmation candle in the same direction.

Small Body Max (x ATR) – caps how big candle 1 and candle 2's bodies can be, relative to ATR, to still count as "small."
Min Wick / Body Ratio (Candle 1) – how long candle 1's rejection wick must be relative to its own body.
Both candles must occur at a fresh low (longs) or high (shorts) versus the Pivot Lookback Bars.
2. Engulfing Pattern

[image]https://www.tradingview.com/x/5Xxttkei/[/image]

A classic bullish/bearish engulfing candle occurring at a fresh swing low/high, with three optional confirmation filters:

Require Engulf Size Ratio – candle 2's body must be at least N× candle 1's body.
Require Volume Spike – candle 2's volume must exceed its average by a set multiple.
Require Strong Close – candle 2 must close within the top/bottom X% of its own high-low range (rules out engulfing candles with long opposing wicks/indecisive closes).

3. Compression Breakout Pattern

[image]https://www.tradingview.com/x/KTUEeiQO/[/image]

Catches violent expansion candles breaking out of a tight multi-bar base — the move the other two patterns miss because there's no small candle or engulfing shape involved, just a coil followed by a release.

Base Lookback (bars) – how many bars immediately before the signal candle are checked for a tight base.
Max Base Range (x ATR) – how tight that base's high-low range must be.
Min Breakout Candle Body (x ATR) – how large the signal candle's body must be to count as a genuine expansion rather than noise.

4. Flag Pattern

[image]https://www.tradingview.com/x/d1z2TTGH/[/image]

Pole + flag structures: a sharp impulse candle, a tight consolidation right after it, then a decisive breakout of that consolidation.

Min Pole Candle Body (x ATR) – how large the impulse candle must be.
Pole Search Window (bars before flag) – instead of requiring the pole to sit on one exact bar, the indicator scans this many bars before the flag and uses whichever one has the biggest body. This makes detection far more reliable on real charts, where the impulse candle rarely lands on a perfectly fixed offset.
Flag Consolidation Bars – how many tight bars make up the flag.
Max Flag Range (x ATR) – how tight the consolidation must be.
Min Breakout Candle Body (x ATR) – how decisive the breakout candle must be.
Only Signal Reversal vs Pole – when ON, only fires when the breakout direction is opposite the pole (spike up → tight pullback → breaks down, or vice versa — an exhaustion/blow-off structure). When OFF (default), it also catches same-direction continuation flags.
Show Flag Consolidation Zones (debug) – draws every detected pole+flag setup on the chart, even ones that never break out, so you can visually see why a flag you spotted by eye didn't fire (range too wide, breakout candle too small, etc).
Chop / Range Filter

Reversal and breakout patterns are far less reliable inside dead, sideways chop. This section filters signals by market condition:

Require Trending Market (ADX) – blocks signals unless ADX is above your threshold.
Min ADX to Allow Signal – the ADX floor (20–25 is the common baseline for "trending").
Override: Allow if ADX Rising – ADX is a lagging indicator, so a brand-new trend's first few bars often still show low ADX. If ADX has been climbing over the lookback window, the signal is allowed through anyway.
Override: Allow on Volatility Breakout – if the signal candle's own range is a large expansion versus ATR, that's independent evidence of a trend starting, so the signal is allowed even if the ADX checks fail.
Enable Signal Cooldown – enforces a minimum number of bars between signals, preventing clustered, overlapping signals during choppy stretches.
Require Range Expansion (ATR vs ATR-MA) – optional extra filter that blocks signals when current volatility (ATR) is below its own moving average, i.e., the market is quiet/contracting.
Trade Settings
Reward : Risk Ratio – sets the take-profit distance as a multiple of the stop-loss distance for every signal.
Box Forward Extension (bars) – how far forward the entry/SL/TP boxes are drawn.
Enable CTC (Close-To-Cost) Outcome – if price runs in your favor far enough (see below) before hitting stop-loss, the trade is logged as CTC instead of a full loss, reflecting a realistic breakeven-plus stop management approach rather than assuming you'd sit through a full round-trip back to your original stop.
CTC Threshold (min R reached before SL) – the minimum favorable excursion, in R multiples, required before a stop-out counts as CTC instead of a loss.
Table Settings
Show Trade Results Table – toggles the on-chart performance table.
Max Trades Shown – how many recent trades are listed.
Table Position – corner placement.

The table logs every signal with its pattern type, direction, entry/SL/TP, result (WIN/LOSS/CTC), and the maximum R multiple reached — plus running totals and a win rate that excludes CTC trades from both the win and loss counts (since they're neither).

Suggested starting settings

These are reasonable defaults to start from — always forward-test and adjust for your instrument, timeframe, and volatility profile before trading live:

Setting	Suggested value	Why
ATR Length	14	Standard volatility baseline
Pivot Lookback Bars	5–8	Confirms a genuine fresh swing point without being too strict
Small Body Max (x ATR)	0.4–0.6	Keep tight so "small" candles stay meaningfully small
Engulf Size Ratio	1.3–1.5x	Filters out marginal engulfing candles
Require Volume Spike	On, 1.2x+	Volume confirmation reduces false engulfs significantly
Compression Base Range	1.0–1.5x ATR	Tighter = higher quality but fewer signals
Flag Pole Body	1.3–1.8x ATR	Should clearly stand out from surrounding candles
Flag Range	1.0–1.3x ATR	A true flag should be visibly tight vs. the pole
ADX Threshold	20–25	20 is looser/more signals, 25 is stricter/higher quality
Reward:Risk	2:1 to 3:1	Balances win rate against payout; lower R:R needs a higher win rate to be profitable
Signal Cooldown	8–15 bars	Prevents signal clustering in choppy conditions

On lower timeframes (1m–5m) and noisy instruments (gold, indices), lean toward tighter compression/flag ranges and a higher ADX floor to cut down on false breakouts. On higher timeframes (1H+), the default settings tend to hold up well as-is.

Notes
This indicator does not repaint: signals and their outcomes are only finalized on confirmed, closed bars.
The trade results table reflects this indicator's rule-based SL/TP simulation, not a full backtest with fees, slippage, or position sizing — treat it as a pattern-quality gauge, not a P&L guarantee.
This is a tool for identifying and evaluating patterns, not financial advice. Always manage your own risk.

---

## Source Code

````pine
//@version=6
indicator("Multi Pattern Candle Reversal RR System [ChartTechnicalx]", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ============================================================================
// INPUTS
// ============================================================================
grpPattern    = "Pattern Settings"
atrLen        = input.int(14, "ATR Length", group=grpPattern)
pivotLookback = input.int(29, "Pivot Lookback Bars", minval=1, group=grpPattern,
     tooltip="Number of bars before candle 1 used to confirm lower low / higher high")

grpSmall      = "Small Candle Pattern"
enableSmall   = input.bool(true, "Enable Small Candle Pattern", group=grpSmall)
smallBodyMult = input.float(0.4, "Small Body Max (x ATR)", step=0.1, minval=0.05, group=grpSmall,
     tooltip="Candle body must be <= ATR * this value to be considered 'small'")
wickRatio     = input.float(0.6, "Min Wick / Body Ratio (Candle 1)", step=0.1, minval=0.0, group=grpSmall,
     tooltip="Candle 1's rejection wick must be at least this fraction of its body")

grpEngulf     = "Engulfing Pattern"
enableEngulf  = input.bool(false, "Enable Engulfing Pattern", group=grpEngulf,
     tooltip="Bullish engulfing at a lower low, or bearish engulfing at a higher high")
useEngulfSize   = input.bool(false, "Require Engulf Size Ratio", group=grpEngulf)
engulfSizeMult  = input.float(2, "Candle 2 Body >= Candle 1 Body x", step=0.1, minval=1.0, group=grpEngulf)
useEngulfVolume = input.bool(false, "Require Volume Spike", group=grpEngulf)
volLen          = input.int(15, "Volume Average Length", minval=1, group=grpEngulf)
volMult         = input.float(1.5, "Candle 2 Volume >= Avg Volume x", step=0.1, minval=1.0, group=grpEngulf)
useStrongClose  = input.bool(false, "Require Strong Close", group=grpEngulf)
strongCloseFrac = input.float(0.25, "Close Within Top/Bottom % of Range", step=0.05, minval=0.05, maxval=0.5, group=grpEngulf,
     tooltip="0.25 = candle 2 must close in the top/bottom 25% of its own high-low range")

grpBreakout    = "Compression Breakout Pattern"
enableBreakout = input.bool(false, "Enable Compression Breakout Pattern", group=grpBreakout,
     tooltip="Catches violent expansion candles that break out of a tight multi-bar base — the shape the Small/Engulf patterns can't see")
compressionBars      = input.int(4, "Base Lookback (bars, before signal candle)", minval=3, group=grpBreakout,
     tooltip="Number of bars, immediately prior to the signal candle, checked for a tight base/range")
compressionRangeMult = input.float(2, "Max Base Range (x ATR)", step=0.1, minval=0.5, group=grpBreakout,
     tooltip="The high-low range across the base lookback must be <= ATR * this to count as 'compressed'")
breakoutBodyMult     = input.float(1.5, "Min Breakout Candle Body (x ATR)", step=0.1, minval=0.5, group=grpBreakout,
     tooltip="Signal candle's body must be >= ATR * this to count as a real expansion, not more noise")

// --- NEW: accuracy filters for the breakout pattern ---
breakoutBufferMult = input.float(0.15, "Breakout Buffer Beyond Base (x ATR)", step=0.05, minval=0.0, group=grpBreakout,
     tooltip="Close must clear the base edge by ATR * this amount, not just by a tick. Filters marginal 'barely poked through' breaks.")
useBreakoutVolume = input.bool(true, "Require Volume Spike", group=grpBreakout,
     tooltip="Real breakouts tend to come with participation. Blocks low-volume 'quiet' breaks that are more likely to fail.")
breakoutVolLen  = input.int(24, "Volume Average Length", minval=1, group=grpBreakout)
breakoutVolMult = input.float(1.8, "Candle Volume >= Avg Volume x", step=0.1, minval=1.0, group=grpBreakout)
useBreakoutStrongClose = input.bool(true, "Require Strong Close", group=grpBreakout,
     tooltip="Breakout candle must close near its own high (long)/low (short), not spike through the base and close back inside it.")
breakoutStrongCloseFrac = input.float(0.5, "Close Within Top/Bottom % of Range", step=0.05, minval=0.05, maxval=0.5, group=grpBreakout)
useBreakoutFreshRange = input.bool(true, "Require Fresh Range Break", group=grpBreakout,
     tooltip="Requires the breakout to also clear a WIDER lookback high/low, not just the tiny local base. Stops signals firing on a small base sitting mid-range inside a much larger consolidation — the most common false-breakout trap.")
breakoutFreshLookback = input.int(21, "Fresh Range Lookback (bars)", minval=1, group=grpBreakout)
useBreakoutFollowThrough = input.bool(true, "Require Follow-Through Bar", group=grpBreakout,
     tooltip="Delays the signal by one bar: after a breakout candle passes all the filters above, price must still close beyond the broken base level on the very next bar before the signal actually fires. Filters snap-back fakeouts (breakout candle closes past the base, then price reverses right back inside it) at the cost of a one-bar-later entry.")

grpFlag        = "Flag Pattern"
enableFlag     = input.bool(true, "Enable Flag Pattern", group=grpFlag,
     tooltip="Catches pole + flag structures: a sharp impulse candle, a tight multi-bar consolidation right after it, then a decisive breakout of that consolidation — the shape the other patterns can't see")
poleBodyMult   = input.float(2, "Min Pole Candle Body (x ATR)", step=0.1, minval=0.5, group=grpFlag,
     tooltip="The impulse candle before the consolidation must have a body at least this many ATRs to count as a real pole")
poleSearchBars = input.int(14, "Pole Search Window (bars before flag)", minval=1, group=grpFlag,
     tooltip="Instead of requiring the pole to sit at one exact bar, scan this many bars immediately before the flag consolidation and use whichever one has the biggest body as the pole. Fixes missed flags where the impulse candle doesn't land on the exact expected offset.")
flagBars       = input.int(25, "Flag Consolidation Bars", minval=2, group=grpFlag,
     tooltip="Number of tight-range bars checked immediately after the pole candle")
flagRangeMult  = input.float(5, "Max Flag Range (x ATR)", step=0.1, minval=0.3, group=grpFlag,
     tooltip="The high-low range across the flag consolidation bars must be <= ATR * this to count as tight")
flagBreakoutBodyMult = input.float(1.0, "Min Breakout Candle Body (x ATR)", step=0.1, minval=0.3, group=grpFlag,
     tooltip="Signal candle's body must be >= ATR * this to count as a decisive breakout of the flag")
requireFlagReversal = input.bool(true, "Only Signal Reversal vs Pole", group=grpFlag,
     tooltip="If enabled, only fires when the breakout direction is opposite the pole (spike up -> tight pullback -> breaks down, or vice versa) — matches an exhaustion/blow-off top or bottom. Leave off to also catch same-direction continuation flags.")
showFlagZones = input.bool(false, "Show Flag Consolidation Zones (debug)", group=grpFlag,
     tooltip="Draws a box around every detected pole+tight-consolidation setup, even ones that never break out. Useful for visually checking why a flag you can see on the chart isn't firing a signal (too wide, breakout candle too small, etc).")

grpSoldiers = "3 Soldiers / 3 Crows Pattern"
enableSoldiers = input.bool(true, "Enable 3 White Soldiers / 3 Black Crows", group=grpSoldiers,
     tooltip="Three consecutive strong-bodied same-direction candles, each closing further than the last — classic exhaustion/reversal pattern")
soldiersBodyMult = input.float(0.6, "Min Body Size Each Candle (x ATR)", step=0.1, minval=0.1, group=grpSoldiers,
     tooltip="Each of the 3 candles must have a body >= ATR * this value")
useSoldiersStrongClose = input.bool(true, "Require Strong Close Each Candle", group=grpSoldiers,
     tooltip="Each candle must close near its high (soldiers) / low (crows), i.e. a small wick on the trend side, for all 3 candles")
soldiersCloseStrengthFrac = input.float(0.3, "Close Within Top/Bottom % of Range", step=0.05, minval=0.05, maxval=0.5, group=grpSoldiers)
requireOpenWithinPriorBody = input.bool(true, "Require Open Within Prior Candle Body", group=grpSoldiers,
     tooltip="Classic textbook definition: each candle must open inside (or at the edge of) the previous candle's real body, i.e. no gap away from the sequence")
requireSoldiersProgress = input.bool(false, "Require Min Close Progress (x ATR)", group=grpSoldiers,
     tooltip="Each candle's close must extend beyond the previous candle's close by at least ATR * the value below, not just by a tick")
soldiersProgressMult = input.float(0.1, "Min Close Progress (x ATR)", step=0.05, minval=0.0, group=grpSoldiers)

// --- NEW: Chop / Range Filter ---
grpChop        = "Chop / Range Filter"
useAdxFilter   = input.bool(true, "Require Trending Market (ADX)", group=grpChop,
     tooltip="Blocks signals when ADX shows the market is flat/ranging (like tight consolidation legs)")
adxLen         = input.int(14, "ADX Length", minval=1, group=grpChop)
adxSmoothing   = input.int(14, "ADX Smoothing", minval=1, group=grpChop)
adxThreshold   = input.float(20.0, "Min ADX to Allow Signal", step=1.0, group=grpChop,
     tooltip="Higher = stricter (only strong trends). 20-25 is a common floor for 'trending'.")

useAdxRisingOverride = input.bool(true, "Override: Allow if ADX Rising", group=grpChop,
     tooltip="ADX is lagging, so a fresh trend's first bars often have low ADX. If ADX is climbing over the lookback window, allow the signal even below the threshold.")
adxRisingLookback     = input.int(20, "ADX Rising Lookback (bars)", minval=1, group=grpChop)

useBreakoutOverride = input.bool(false, "Override: Allow on Volatility Breakout", group=grpChop,
     tooltip="If the signal candle's range is a large expansion vs ATR, that itself is trend-start evidence — allow the signal even if ADX/rising checks fail.")
breakoutRangeMult   = input.float(1.5, "Breakout Candle Range (x ATR)", step=0.1, minval=1.0, group=grpChop)

useCooldown    = input.bool(true, "Enable Signal Cooldown", group=grpChop,
     tooltip="Prevents multiple overlapping signals from firing back-to-back during choppy clusters")
cooldownBars   = input.int(10, "Min Bars Between Signals", minval=1, group=grpChop)

useRangeFilter = input.bool(true, "Require Range Expansion (ATR vs ATR-MA)", group=grpChop,
     tooltip="Optional extra filter: blocks signals when current ATR is below its own moving average, i.e. volatility is contracting/quiet chop")
atrMaLen       = input.int(62, "ATR Moving Average Length", minval=1, group=grpChop)

grpTrade  = "Trade Settings"
rrRatio   = input.float(5.0, "Reward : Risk Ratio", step=0.5, minval=0.5, group=grpTrade)
boxBars   = input.int(30, "Box Forward Extension (bars)", minval=5, group=grpTrade)

useAutoPip    = input.bool(true, "Auto-Detect Pip Size", group=grpTrade,
     tooltip="Estimates pip size from syminfo.mintick — treats 5-digit FX and 3-digit JPY-pair quoting as fractional-pip (pip = 10 x mintick). Turn off to set the pip size manually below.")
manualPipSize = input.float(0.0001, "Manual Pip Size", step=0.00001, minval=0.00000001, group=grpTrade,
     tooltip="Used only when Auto-Detect Pip Size is off. E.g. 0.0001 for most FX pairs, 0.01 for JPY pairs, 1 for indices/stocks.")

useCTC       = input.bool(true, "Enable CTC (Close-To-Cost) Outcome", group=grpTrade,
     tooltip="If price reaches the R threshold below before hitting SL, classify the trade as CTC instead of a full LOSS — assumes you'd move SL to breakeven+ once that level is reached")
ctcThreshold = input.float(1.0, "CTC Threshold (min R reached before SL)", step=0.5, minval=0.1, group=grpTrade)

grpTable  = "Table Settings"
showTable = input.bool(true, "Show Trade Results Table", group=grpTable)
maxRows   = input.int(15, "Max Trades Shown", minval=1, maxval=40, group=grpTable)
tablePos  = input.string("Top Right", "Table Position",
     options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group=grpTable)

// ============================================================================
// PATTERN DETECTION
// ============================================================================
atrVal = ta.atr(atrLen)

body1 = math.abs(close[1] - open[1])
body2 = math.abs(close    - open)

isGreen1 = close[1] > open[1]
isGreen2 = close    > open
isRed1   = close[1] < open[1]
isRed2   = close    < open

isSmall1 = body1 <= atrVal * smallBodyMult
isSmall2 = body2 <= atrVal * smallBodyMult

lowerWick1 = math.min(open[1], close[1]) - low[1]
upperWick1 = high[1] - math.max(open[1], close[1])

hasLowerWick1 = lowerWick1 > 0 and lowerWick1 >= body1 * wickRatio
hasUpperWick1 = upperWick1 > 0 and upperWick1 >= body1 * wickRatio

// candle 1 must be a fresh lower low / higher high vs the lookback range before it
isLowerLow   = low[1]  < ta.lowest(low[2],  pivotLookback)
isHigherHigh = high[1] > ta.highest(high[2], pivotLookback)

longSmall  = enableSmall and isGreen1 and isGreen2 and isSmall1 and isSmall2 and hasLowerWick1 and isLowerLow
shortSmall = enableSmall and isRed1   and isRed2   and isSmall1 and isSmall2 and hasUpperWick1 and isHigherHigh

// ============================================================================
// ENGULFING PATTERN (green engulfs prior red at a bottom / red engulfs prior green at a top)
// ============================================================================
bullishEngulfBody = isRed1 and isGreen2 and open <= close[1] and close >= open[1]
bearishEngulfBody = isGreen1 and isRed2 and open >= close[1] and close <= open[1]

engulfLowRef  = math.min(low[1], low)
engulfHighRef = math.max(high[1], high)
isLowerLowE   = engulfLowRef  < ta.lowest(low[2],  pivotLookback)
isHigherHighE = engulfHighRef > ta.highest(high[2], pivotLookback)

// --- extra confirmations ---
avgVol         = ta.sma(volume, volLen)
sizeOk         = not useEngulfSize   or body2 >= body1 * engulfSizeMult
volumeOk       = not useEngulfVolume or volume >= avgVol * volMult
range2         = high - low
strongCloseUp   = range2 > 0 and (high - close) <= range2 * strongCloseFrac
strongCloseDown = range2 > 0 and (close - low)  <= range2 * strongCloseFrac
strongCloseOk_L = not useStrongClose or strongCloseUp
strongCloseOk_S = not useStrongClose or strongCloseDown

longEngulf  = enableEngulf and bullishEngulfBody and isLowerLowE  and sizeOk and volumeOk and strongCloseOk_L
shortEngulf = enableEngulf and bearishEngulfBody and isHigherHighE and sizeOk and volumeOk and strongCloseOk_S

// ============================================================================
// COMPRESSION BREAKOUT PATTERN (tight multi-bar base -> violent expansion candle)
// ============================================================================
// base range measured over the N bars BEFORE the signal candle (excludes current bar)
baseHigh   = ta.highest(high[1], compressionBars)
baseLow    = ta.lowest(low[1],   compressionBars)
baseRange  = baseHigh - baseLow
isCompressed = baseRange <= atrVal * compressionRangeMult

isExpansionCandle = body2 >= atrVal * breakoutBodyMult

// --- NEW: buffer beyond the base edge, so a close that only barely ticks past
// the boundary (and could easily be inside spread/noise) doesn't count ---
clearsBaseHighBuffer = close > baseHigh + atrVal * breakoutBufferMult
clearsBaseLowBuffer  = close < baseLow  - atrVal * breakoutBufferMult

// --- NEW: volume confirmation ---
avgVolBreakout   = ta.sma(volume, breakoutVolLen)
breakoutVolumeOk = not useBreakoutVolume or volume >= avgVolBreakout * breakoutVolMult

// --- NEW: strong close requirement (reuses candle 2's own high-low range) ---
breakoutStrongCloseOk_L = not useBreakoutStrongClose or (range2 > 0 and (high - close) <= range2 * breakoutStrongCloseFrac)
breakoutStrongCloseOk_S = not useBreakoutStrongClose or (range2 > 0 and (close - low)  <= range2 * breakoutStrongCloseFrac)

// --- NEW: fresh range filter — the breakout must also clear a WIDER lookback
// extreme, not just the tiny local base. Without this, a small tight base
// sitting mid-range inside a much bigger consolidation can "break out" of
// itself while doing nothing meaningful on the higher timeframe structure. ---
freshBreakHigh = close > ta.highest(high[1], breakoutFreshLookback)
freshBreakLow  = close < ta.lowest(low[1],  breakoutFreshLookback)
breakoutFreshOk_L = not useBreakoutFreshRange or freshBreakHigh
breakoutFreshOk_S = not useBreakoutFreshRange or freshBreakLow

longBreakout  = enableBreakout and isCompressed and isExpansionCandle and isGreen2 and
     clearsBaseHighBuffer and breakoutVolumeOk and breakoutStrongCloseOk_L and breakoutFreshOk_L
shortBreakout = enableBreakout and isCompressed and isExpansionCandle and isRed2 and
     clearsBaseLowBuffer  and breakoutVolumeOk and breakoutStrongCloseOk_S and breakoutFreshOk_S

// ============================================================================
// FLAG PATTERN (impulse pole candle -> tight multi-bar consolidation -> decisive breakout)
// ============================================================================
// --- Pole: scan a window of bars immediately before the flag consolidation and pick
// whichever bar has the biggest body. This replaces requiring the pole to land on one
// exact offset, which was silently killing valid flags (long AND short alike) whenever
// the impulse candle didn't happen to sit at bar [flagBars+1] exactly. ---
float poleBodyMax   = 0.0
bool  poleColorIsUp = false

for j = flagBars + 1 to flagBars + poleSearchBars
    pb = math.abs(close[j] - open[j])
    if pb > poleBodyMax
        poleBodyMax   := pb
        poleColorIsUp := close[j] > open[j]

poleIsBig   = poleBodyMax >= atrVal * poleBodyMult
poleIsGreen = poleIsBig and poleColorIsUp
poleIsRed   = poleIsBig and not poleColorIsUp

// flag = the N bars immediately after the pole and immediately before the signal candle (excludes both)
flagHigh  = ta.highest(high[1], flagBars)
flagLow   = ta.lowest(low[1],   flagBars)
flagRange = flagHigh - flagLow
flagIsTight = flagRange <= atrVal * flagRangeMult

isFlagBreakoutBody = body2 >= atrVal * flagBreakoutBodyMult

reversalOk_L = not requireFlagReversal or poleIsRed
reversalOk_S = not requireFlagReversal or poleIsGreen

// Base setup (pole + tight flag), independent of breakout direction/color — used both to
// gate the two directional signals below AND to draw debug zones for setups that never
// actually break out, so you can see why a flag you can spot by eye didn't fire.
flagSetup = enableFlag and poleIsBig and flagIsTight

longFlag  = flagSetup and isFlagBreakoutBody and isGreen2 and close > flagHigh and reversalOk_L
shortFlag = flagSetup and isFlagBreakoutBody and isRed2   and close < flagLow  and reversalOk_S

// --- Debug visualization: draw every detected pole+flag setup, whether or not it breaks out ---
if showFlagZones and barstate.isconfirmed and flagSetup
    zoneLeft  = bar_index - flagBars
    zoneRight = bar_index - 1
    box.new(left=zoneLeft, top=flagHigh, right=zoneRight, bottom=flagLow,
         border_color=color.new(color.blue, 30), bgcolor=color.new(color.blue, 90),
         border_width=1, extend=extend.none)
    label.new(zoneLeft, flagHigh, poleIsGreen ? "Pole+Flag (up)" : "Pole+Flag (down)",
         style=label.style_label_down, color=color.new(color.blue, 60), textcolor=color.white,
         size=size.tiny)

// ============================================================================
// THREE WHITE SOLDIERS / THREE BLACK CROWS
// (3 consecutive strong-bodied same-direction candles, each closing further than the last)
// ============================================================================
body3  = math.abs(close[2] - open[2])
range1 = high[1] - low[1]
range3 = high[2] - low[2]

isGreen3 = close[2] > open[2]
isRed3   = close[2] < open[2]

soldiersBodyOk = body3 >= atrVal * soldiersBodyMult and body1 >= atrVal * soldiersBodyMult and body2 >= atrVal * soldiersBodyMult

closesRising  = close[2] < close[1] and close[1] < close
closesFalling = close[2] > close[1] and close[1] > close

progressOk_L = not requireSoldiersProgress or (close[1] - close[2] >= atrVal * soldiersProgressMult and close - close[1] >= atrVal * soldiersProgressMult)
progressOk_S = not requireSoldiersProgress or (close[2] - close[1] >= atrVal * soldiersProgressMult and close[1] - close >= atrVal * soldiersProgressMult)

// strong close (soldiers): each candle closes near its own high, i.e. small upper wick
strongClose3_L = range3 > 0 and (high[2] - close[2]) <= range3 * soldiersCloseStrengthFrac
strongClose1_L = range1 > 0 and (high[1] - close[1]) <= range1 * soldiersCloseStrengthFrac
strongClose2_L = range2 > 0 and (high    - close)    <= range2 * soldiersCloseStrengthFrac
strongCloseOk_SoldiersL = not useSoldiersStrongClose or (strongClose3_L and strongClose1_L and strongClose2_L)

// strong close (crows): each candle closes near its own low, i.e. small lower wick
strongClose3_S = range3 > 0 and (close[2] - low[2]) <= range3 * soldiersCloseStrengthFrac
strongClose1_S = range1 > 0 and (close[1] - low[1]) <= range1 * soldiersCloseStrengthFrac
strongClose2_S = range2 > 0 and (close    - low)    <= range2 * soldiersCloseStrengthFrac
strongCloseOk_CrowsS = not useSoldiersStrongClose or (strongClose3_S and strongClose1_S and strongClose2_S)

// each candle opens inside (or at the edge of) the prior candle's real body
opensWithinBody1 = open[1] >= math.min(open[2], close[2]) and open[1] <= math.max(open[2], close[2])
opensWithinBody2 = open    >= math.min(open[1], close[1]) and open    <= math.max(open[1], close[1])
opensOk = not requireOpenWithinPriorBody or (opensWithinBody1 and opensWithinBody2)

// swing constraint, consistent with the other 4 patterns: the 3-candle span must mark
// a fresh low (soldiers, reversal off a bottom) or fresh high (crows, reversal off a top)
soldiersLowRef  = math.min(low[2],  math.min(low[1],  low))
soldiersHighRef = math.max(high[2], math.max(high[1], high))
isLowerLowSoldiers  = soldiersLowRef  < ta.lowest(low[3],  pivotLookback)
isHigherHighSoldiers = soldiersHighRef > ta.highest(high[3], pivotLookback)

longSoldiers = enableSoldiers and isGreen3 and isGreen1 and isGreen2 and soldiersBodyOk and closesRising and
     progressOk_L and strongCloseOk_SoldiersL and opensOk and isLowerLowSoldiers

shortCrows = enableSoldiers and isRed3 and isRed1 and isRed2 and soldiersBodyOk and closesFalling and
     progressOk_S and strongCloseOk_CrowsS and opensOk and isHigherHighSoldiers

longRaw  = longSmall  or longEngulf  or longBreakout  or longFlag  or longSoldiers
shortRaw = shortSmall or shortEngulf or shortBreakout or shortFlag or shortCrows

// ============================================================================
// CHOP / RANGE FILTER
// ============================================================================
// -- ADX trend strength --
[diPlus, diMinus, adxVal] = ta.dmi(adxLen, adxSmoothing)

adxAboveThreshold = adxVal >= adxThreshold
adxRising         = useAdxRisingOverride and adxVal > adxVal[adxRisingLookback]
isBreakoutCandle  = useBreakoutOverride and (high - low) >= atrVal * breakoutRangeMult

adxOk = not useAdxFilter or adxAboveThreshold or adxRising or isBreakoutCandle

// -- ATR expansion (volatility) filter --
atrMa = ta.sma(atrVal, atrMaLen)
rangeOk = not useRangeFilter or atrVal >= atrMa

// -- signal cooldown (bars since last accepted signal, either direction) --
var int barsSinceLastSignal = 999999
cooldownOk = not useCooldown or barsSinceLastSignal >= cooldownBars

longSignal  = longRaw  and adxOk and rangeOk and cooldownOk
shortSignal = shortRaw and adxOk and rangeOk and cooldownOk

if barstate.isconfirmed
    if longSignal or shortSignal
        barsSinceLastSignal := 0
    else
        barsSinceLastSignal += 1

// --- Pip size used for the Pips Gained/Lost stats below ---
autoPipSize = (syminfo.mintick == 0.00001 or syminfo.mintick == 0.001) ? syminfo.mintick * 10 : syminfo.mintick
pipSize     = useAutoPip ? autoPipSize : manualPipSize

// ============================================================================
// TRADE TRACKING (persists across full chart history)
// ============================================================================
var array<float> tEntry     = array.new<float>()
var array<float> tSL        = array.new<float>()
var array<float> tTP        = array.new<float>()
var array<float> tRiskAmt   = array.new<float>()  // |entry - SL|, used to convert price moves to R multiples
var array<float> tMaxR      = array.new<float>()  // highest favorable excursion reached, in R multiples
var array<float> tPips      = array.new<float>()  // realized pips gained (+) or lost (-) once the trade resolves; 0 while open
var array<int>   tDir       = array.new<int>()   // 1 = long, -1 = short
var array<int>   tStatus    = array.new<int>()   // 0 open, 1 win, 2 loss, 3 CTC (close-to-cost)
var array<string> tPattern  = array.new<string>() // "Small", "Engulf", "Breakout", "Flag", "3Soldiers", or "3Crows"
var array<int>   tEntryBar  = array.new<int>()    // bar_index the trade was opened on — used to skip same-bar resolution
var array<box>   tRewardBox = array.new<box>()
var array<box>   tRiskBox   = array.new<box>()
var array<line>  tEntryLine = array.new<line>()

longColor  = color.new(color.lime, 0)
shortColor = color.new(color.red, 0)
rewardCol  = color.new(color.teal, 80)
riskCol    = color.new(color.maroon, 80)

// --- Create a new trade only on a confirmed (closed) bar to avoid repainting ---
if barstate.isconfirmed and (longSignal or shortSignal)
    dir    = longSignal ? 1 : -1
    entryP = close
    // small-candle / engulfing patterns use the 2-candle extreme as SL;
    // breakout pattern uses the far edge of the base it broke out of;
    // flag pattern uses the far edge of the flag consolidation it broke out of;
    // 3 soldiers/crows pattern uses the extreme of all 3 candles in the sequence
    isSmallTrigger    = dir == 1 ? longSmall    : shortSmall
    isBreakoutTrigger = dir == 1 ? longBreakout : shortBreakout
    isFlagTrigger     = dir == 1 ? longFlag     : shortFlag
    isSoldiersTrigger = dir == 1 ? longSoldiers : shortCrows
    patName = isSmallTrigger ? "Small" : isBreakoutTrigger ? "Breakout" : isFlagTrigger ? "Flag" :
         isSoldiersTrigger ? (dir == 1 ? "3Soldiers" : "3Crows") : "Engulf"
    slP = isBreakoutTrigger ? (dir == 1 ? baseLow : baseHigh) :
         isFlagTrigger ? (dir == 1 ? flagLow : flagHigh) :
         isSoldiersTrigger ? (dir == 1 ? soldiersLowRef : soldiersHighRef) :
         (dir == 1 ? math.min(low[1], low) : math.max(high[1], high))
    riskOk = dir == 1 ? (slP < entryP) : (slP > entryP)

    if riskOk
        riskAmt = math.abs(entryP - slP)
        tpP     = dir == 1 ? entryP + riskAmt * rrRatio : entryP - riskAmt * rrRatio

        array.push(tEntry, entryP)
        array.push(tSL, slP)
        array.push(tTP, tpP)
        array.push(tRiskAmt, riskAmt)
        array.push(tMaxR, 0.0)
        array.push(tPips, 0.0)
        array.push(tDir, dir)
        array.push(tStatus, 0)
        array.push(tPattern, patName)
        array.push(tEntryBar, bar_index)

        rb = box.new(left=bar_index, top=dir == 1 ? tpP : entryP, right=bar_index + boxBars,
             bottom=dir == 1 ? entryP : tpP, border_color=rewardCol, bgcolor=rewardCol)
        kb = box.new(left=bar_index, top=dir == 1 ? entryP : slP, right=bar_index + boxBars,
             bottom=dir == 1 ? slP : entryP, border_color=riskCol, bgcolor=riskCol)
        array.push(tRewardBox, rb)
        array.push(tRiskBox, kb)

        el = line.new(x1=bar_index, y1=entryP, x2=bar_index + boxBars, y2=entryP,
             color=dir == 1 ? longColor : shortColor, width=1, style=line.style_dashed)
        array.push(tEntryLine, el)

        label.new(bar_index, entryP,
             (dir == 1 ? "LONG" : "SHORT") + " (" + patName + ")" +
             "\nEntry: " + str.tostring(entryP, format.mintick) +
             "\nSL: "    + str.tostring(slP, format.mintick) +
             "\nTP: "    + str.tostring(tpP, format.mintick) +
             "\nR:R 1:"  + str.tostring(rrRatio, "#.##"),
             style=dir == 1 ? label.style_label_up : label.style_label_down,
             color=dir == 1 ? longColor : shortColor, textcolor=color.white, size=size.small)

// --- Resolve open trades bar by bar (SL checked before TP for conservative results) ---
if array.size(tStatus) > 0
    for i = 0 to array.size(tStatus) - 1
        if array.get(tStatus, i) == 0 and bar_index > array.get(tEntryBar, i)
            dir     = array.get(tDir, i)
            en      = array.get(tEntry, i)
            sl      = array.get(tSL, i)
            tp      = array.get(tTP, i)
            riskAmt = array.get(tRiskAmt, i)

            // update the highest R multiple reached so far, using this bar's favorable extreme
            if riskAmt > 0
                favExtreme = dir == 1 ? high : low
                curR = dir == 1 ? (favExtreme - en) / riskAmt : (en - favExtreme) / riskAmt
                if curR > array.get(tMaxR, i)
                    array.set(tMaxR, i, curR)

            hitSL = dir == 1 ? low <= sl : high >= sl
            hitTP = dir == 1 ? high >= tp : low <= tp

            if hitSL
                // if price already ran far enough in our favor, classify as CTC (breakeven-managed) rather than a full loss
                reachedCTC = useCTC and array.get(tMaxR, i) >= ctcThreshold
                array.set(tStatus, i, reachedCTC ? 3 : 2)
                // CTC assumes the stop was moved to breakeven, so realized pips = 0; a full loss realizes the full risk in pips
                array.set(tPips, i, reachedCTC ? 0.0 : -(riskAmt / pipSize))
                box.set_right(array.get(tRewardBox, i), bar_index)
                box.set_right(array.get(tRiskBox, i), bar_index)
                line.set_x2(array.get(tEntryLine, i), bar_index)
            else if hitTP
                array.set(tStatus, i, 1)
                array.set(tPips, i, (riskAmt * rrRatio) / pipSize)
                box.set_right(array.get(tRewardBox, i), bar_index)
                box.set_right(array.get(tRiskBox, i), bar_index)
                line.set_x2(array.get(tEntryLine, i), bar_index)

// ============================================================================
// RESULTS TABLE
// ============================================================================
var table resultsTable = table.new(
     tablePos == "Top Right" ? position.top_right : tablePos == "Bottom Right" ? position.bottom_right :
     tablePos == "Top Left" ? position.top_left : position.bottom_left,
     9, maxRows + 2, border_width=1)

if showTable and barstate.islast
    table.cell(resultsTable, 0, 0, "#",       bgcolor=color.gray, text_color=color.white)
    table.cell(resultsTable, 1, 0, "Pattern", bgcolor=color.gray, text_color=color.white)
    table.cell(resultsTable, 2, 0, "Type",    bgcolor=color.gray, text_color=color.white)
    table.cell(resultsTable, 3, 0, "Entry",   bgcolor=color.gray, text_color=color.white)
    table.cell(resultsTable, 4, 0, "SL",      bgcolor=color.gray, text_color=color.white)
    table.cell(resultsTable, 5, 0, "TP",      bgcolor=color.gray, text_color=color.white)
    table.cell(resultsTable, 6, 0, "Result",  bgcolor=color.gray, text_color=color.white)
    table.cell(resultsTable, 7, 0, "Max R",   bgcolor=color.gray, text_color=color.white)
    table.cell(resultsTable, 8, 0, "Pips",    bgcolor=color.gray, text_color=color.white)

    total  = array.size(tStatus)
    wins   = 0
    losses = 0
    ctc    = 0
    pipsGained = 0.0
    pipsLost   = 0.0
    if total > 0
        for i = 0 to total - 1
            st = array.get(tStatus, i)
            pv = array.get(tPips, i)
            if st == 1
                wins += 1
                pipsGained += pv
            else if st == 2
                losses += 1
                pipsLost += -pv
            else if st == 3
                ctc += 1

    startIdx  = math.max(0, total - maxRows)
    rowOffset = 1
    if total > 0
        for i = total - 1 to startIdx
            st    = array.get(tStatus, i)
            dir   = array.get(tDir, i)
            en    = array.get(tEntry, i)
            sl    = array.get(tSL, i)
            tp    = array.get(tTP, i)
            pat   = array.get(tPattern, i)
            maxR  = array.get(tMaxR, i)
            resTxt = st == 1 ? "WIN" : st == 2 ? "LOSS" : st == 3 ? "CTC" : "OPEN"
            resCol = st == 1 ? color.new(color.green, 70) : st == 2 ? color.new(color.red, 70) : st == 3 ? color.new(color.orange, 70) : color.new(color.gray, 70)
            // show how far the trade actually ran in R multiples, not just the final win/loss outcome
            rTxt = st == 2 ? "-1 (0:" + str.tostring(maxR, "#.##") + ")" : "1:" + str.tostring(maxR, "#.##")
            pipsV   = array.get(tPips, i)
            pipsTxt = st == 0 ? "-" : (pipsV >= 0 ? "+" : "") + str.tostring(pipsV, "#.#")
            pipsCol = st == 1 ? color.new(color.teal, 0) : st == 2 ? color.new(color.red, 0) : st == 3 ? color.new(color.orange, 0) : color.white
            rowN   = total - i

            table.cell(resultsTable, 0, rowOffset, str.tostring(rowN), text_color=color.white, text_size = size.small,bgcolor = color.new(color.gray,60))
            table.cell(resultsTable, 1, rowOffset, pat, text_color=color.white, text_size = size.small,bgcolor = color.new(color.gray,60))
            table.cell(resultsTable, 2, rowOffset, dir == 1 ? "LONG" : "SHORT", text_color=dir == 1 ? color.lime : color.red)
            table.cell(resultsTable, 3, rowOffset, str.tostring(en, format.mintick), text_color=color.white, text_size = size.small,bgcolor = color.new(color.gray,60))
            table.cell(resultsTable, 4, rowOffset, str.tostring(sl, format.mintick), text_color=color.white, text_size = size.small,bgcolor = color.new(color.gray,60))
            table.cell(resultsTable, 5, rowOffset, str.tostring(tp, format.mintick), text_color=color.white, text_size = size.small,bgcolor = color.new(color.gray,60))
            table.cell(resultsTable, 6, rowOffset, resTxt, bgcolor=resCol, text_color=color.white)
            table.cell(resultsTable, 7, rowOffset, rTxt, text_color=maxR >= 1.0 ? color.new(color.teal, 0) : color.white, text_size = size.small,bgcolor = color.new(color.gray,60))
            table.cell(resultsTable, 8, rowOffset, pipsTxt, text_color=pipsCol, text_size = size.small,bgcolor = color.new(color.gray,60))
            rowOffset += 1

    // win rate excludes CTC trades from both the win and loss counts, since they're neither a full win nor a full loss
    winRate = (wins + losses) > 0 ? (wins / (wins + losses)) * 100 : 0.0
    netPips = pipsGained - pipsLost
    table.cell(resultsTable, 0, maxRows + 1, "Total:" + str.tostring(total), bgcolor=color.new(color.blue, 70), text_color=color.white)
    table.cell(resultsTable, 1, maxRows + 1, "W:" + str.tostring(wins),      bgcolor=color.new(color.blue, 70), text_color=color.white)
    table.cell(resultsTable, 2, maxRows + 1, "L:" + str.tostring(losses),   bgcolor=color.new(color.blue, 70), text_color=color.white)
    table.cell(resultsTable, 3, maxRows + 1, "CTC:" + str.tostring(ctc),    bgcolor=color.new(color.orange, 70), text_color=color.white)
    table.cell(resultsTable, 4, maxRows + 1, "WR:",                         bgcolor=color.new(color.blue, 70), text_color=color.white)
    table.cell(resultsTable, 5, maxRows + 1, str.tostring(winRate, "#.#") + "%", bgcolor=color.new(color.blue, 70), text_color=color.white)
    table.cell(resultsTable, 6, maxRows + 1, "Pips+:" + str.tostring(pipsGained, "#.#"), bgcolor=color.new(color.teal, 70), text_color=color.white)
    table.cell(resultsTable, 7, maxRows + 1, "Pips-:" + str.tostring(pipsLost, "#.#"),   bgcolor=color.new(color.red, 70), text_color=color.white)
    table.cell(resultsTable, 8, maxRows + 1, "Net:" + str.tostring(netPips, "#.#"),      bgcolor=netPips >= 0 ? color.new(color.teal, 70) : color.new(color.red, 70), text_color=color.white)

// ============================================================================
// SIGNAL MARKERS & ALERTS
// ============================================================================
plotshape(barstate.isconfirmed and longSignal, title="Long Signal", style=shape.triangleup,
     location=location.belowbar, color=longColor, size=size.tiny)
plotshape(barstate.isconfirmed and shortSignal, title="Short Signal", style=shape.triangledown,
     location=location.abovebar, color=shortColor, size=size.tiny)

alertcondition(longSignal, title="Long Entry", message="Small Candle Long Entry Signal")
alertcondition(shortSignal, title="Short Entry", message="Small Candle Short Entry Signal")
````
