# Ha Smooth Scalper

- url: https://www.tradingview.com/script/QWzxjRCZ-Ha-Smooth-Scalper/
- type: indicator
- pine_id: PUB;2c66ca1961f848bfa3e29555728c13de
- version: 1.0

## Description

ha smooth scalper

ha smooth scalper is a trend-following and scalping tool built around smoothed heikin-ashi logic, real structure trend locking, multi-timeframe confirmation, higher-timeframe filtering, protected structure levels, clean candle coloring, and a compact professional dashboard.

the goal of this indicator is to help traders stay with the real trend instead of reacting to every small candle color change.

in a strong bullish slope, the tool can keep the chart bullish until a real protected swing low is broken.
in a strong bearish slope, the tool can keep the chart bearish until a real protected swing high is broken.

this makes the trend view cleaner and helps reduce false flips during strong directional moves.

main concept

most candle-based systems change color too quickly.

a single weak red candle inside a strong bullish trend should not always mean the trend is bearish.
a single weak green candle inside a strong bearish trend should not always mean the trend is bullish.

ha smooth scalper solves this by combining:

smoothed heikin-ashi calculation
real structure lock
protected swing highs and swing lows
multi-timeframe agreement
extra higher-timeframe confirmation
trend cloud
optional smooth candle mode
professional dashboard

how the trend works

the indicator first builds smoothed heikin-ashi candles from the chart data.

then it uses a structure lock system to decide if the market is really bullish or bearish.

bullish trend

the market stays bullish while price respects the protected swing low.

small bearish candles inside the bullish slope do not automatically flip the trend.

the trend changes to bearish only when the protected support structure is broken.

bearish trend

the market stays bearish while price respects the protected swing high.

small bullish candles inside the bearish slope do not automatically flip the trend.

the trend changes to bullish only when the protected resistance structure is broken.

protected structure level

the protected structure line shows the key level that must break before the trend can truly change.

in a bullish trend, this level is usually below price.
in a bearish trend, this level is usually above price.

for beginners, this is one of the most important parts of the tool.

if the market is bullish and price stays above the protected structure, the bullish trend remains valid.
if the market is bearish and price stays below the protected structure, the bearish trend remains valid.

smooth lock candle mode

smooth lock candle mode is designed to keep chart colors aligned with the real structure trend.

when enabled:

bullish structure keeps candles bullish
bearish structure keeps candles bearish
minor counter-trend candles are ignored
color changes only happen after real structure breaks

this mode is useful for traders who want a cleaner trend view and fewer emotional exits.

multi-timeframe confirmation

the indicator includes six selectable timeframes.

each timeframe can be enabled or disabled.

the panel shows whether each selected timeframe is bullish or bearish.

the minimum timeframe agreement setting controls how many selected timeframes must agree before a signal is accepted.

example:

if six timeframes are enabled and the minimum agreement is set to three, at least three selected timeframes must agree with the signal direction.

higher values create fewer but cleaner signals.
lower values create more signals but with more risk of noise.

extra htf confirmator

the extra higher-timeframe confirmator is an additional filter designed to reduce weak buy and sell signals.

it can confirm direction using:

ema slope plus price
or heikin-ashi direction

when enabled, long signals require bullish higher-timeframe confirmation.
short signals require bearish higher-timeframe confirmation.

this is useful because many losing trades happen when lower-timeframe signals go against the larger trend.

signal logic

long signal

a long signal can appear when:

the structure flips bullish
enough selected timeframes agree
the extra htf confirmator agrees
the trend mode allows long entries
the impulse filter confirms body expansion

short signal

a short signal can appear when:

the structure flips bearish
enough selected timeframes agree
the extra htf confirmator agrees
the trend mode allows short entries
the impulse filter confirms body expansion

full confluence star

a star appears when all selected timeframes agree with the signal direction.

this is a stronger confluence condition, but it should still be used with proper risk management.

dashboard

the dashboard is designed to give a fast view of the market.

it shows:

chart trend
six timeframe directions
multi-timeframe agreement
extra htf confirmation
structure lock status
protected structure price
smooth lock candle state
last signal

the panel uses a clean grey professional style and can be moved around the chart.

how to use the indicator

step 1: check the chart trend

start with the first dashboard row.

if the chart trend is bullish, focus mainly on long setups.
if the chart trend is bearish, focus mainly on short setups.

beginners should avoid trading directly against the displayed structure trend.

step 2: check the protected level

look at the protected structure level.

in a bullish trend, this is the important level below price.
if price stays above it, the bullish structure remains valid.

in a bearish trend, this is the important level above price.
if price stays below it, the bearish structure remains valid.

step 3: check timeframe agreement

look at the six timeframe rows.

cleaner long conditions usually appear when most selected timeframes are bullish.
cleaner short conditions usually appear when most selected timeframes are bearish.

step 4: check the htf confirmator

if the extra htf confirmator is enabled, wait for it to agree with the trade direction.

bullish htf confirmation supports long setups.
bearish htf confirmation supports short setups.

step 5: wait for a signal

a long signal marks a bullish structure transition with confirmation.
a short signal marks a bearish structure transition with confirmation.

do not trade every signal blindly.
always check trend context, support and resistance, volatility, session timing, and risk placement.

beginner long example

1. chart trend is bullish
2. smooth lock candle mode shows bullish structure
3. most selected timeframes are bullish
4. extra htf confirmator is bullish
5. price holds above the protected structure level
6. a long signal appears
7. stop loss can be planned below the protected level or below a recent swing low
8. target can be based on resistance, previous high, or a fixed risk/reward plan

beginner short example

1. chart trend is bearish
2. smooth lock candle mode shows bearish structure
3. most selected timeframes are bearish
4. extra htf confirmator is bearish
5. price holds below the protected structure level
6. a short signal appears
7. stop loss can be planned above the protected level or above a recent swing high
8. target can be based on support, previous low, or a fixed risk/reward plan

important settings

pre-smooth length

controls the first smoothing applied to price before the heikin-ashi calculation.

lower values react faster.
higher values are smoother.

post-smooth length

controls smoothing after the heikin-ashi calculation.

higher values reduce noise and false movement.
lower values make the tool more reactive.

slow baseline length

controls the slow baseline used for trend context and pullback logic.

structure pivot strength

controls how strong a swing high or swing low must be before it can become a protected structure level.

lower values react faster.
higher values create stronger but slower structure levels.

structure break confirmation

close mode requires candle close beyond the protected level.
wick mode reacts faster but can be noisier.

structure break buffer

adds an atr buffer beyond the protected level before the structure is considered broken.

higher buffer creates fewer trend flips.
lower buffer creates faster flips.

minimum timeframes agreeing

controls how many enabled timeframes must agree before a signal is allowed.

higher values are stricter.
lower values are more aggressive.

extra htf confirmator

adds a higher-timeframe direction filter to help avoid weak lower-timeframe signals.

smooth lock candle mode

keeps the visible candle color aligned with the structure trend until a real structure break happens.

best beginner settings

for cleaner trend reading:

enable real structure trend lock: on
structure source: raw price
structure break confirmation: close
smooth lock candle mode: on
extra htf confirmator: on
use confirmed mtf candles: on
minimum timeframes agreeing: 3 or higher
glow baseline: off
confluence background tint: off

for faster scalping:

structure pivot strength: 6 to 8
minimum timeframes agreeing: 2 to 3
extra htf confirmator: on
smooth lock candle mode: on

for safer trend following:

structure pivot strength: 10 to 14
minimum timeframes agreeing: 4 to 6
extra htf confirmator: on
structure break buffer: higher value

alerts

the indicator includes alerts for:

long scalp
short scalp
full bull
full bear
structure bull break
structure bear break

for cleaner alerts, use once per bar close.

risk management

this tool helps identify trend direction and filtered signals, but risk management is still required.

before entering a trade, define:

entry
stop loss
target
position size
invalidated condition

a good signal without risk management can still become a bad trade.

final note

ha smooth scalper is designed to make trend direction cleaner, reduce false color flips, and help traders focus on higher-quality conditions using structure, smoothing, multi-timeframe alignment, and higher-timeframe confirmation.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha_Wizard

//@version=6
indicator("HA SMOOTH SCALPER", "HA SCALP", overlay=true, max_bars_back=5000, max_labels_count=500)

// ─── PALETTE ─────────────────────────────────────────────────────────────────
color C_BULL = #00FFD1
color C_BEAR = #FF3B5C
color C_GOLD = #FFD23F
color C_BG   = #0A0E14
color C_TXT  = #C9D1D9
color C_DIM  = #5B677A
color C_G0   = #0F1115
color C_G1   = #171A20
color C_G2   = #20242C
color C_G3   = #2B313B
color C_G4   = #7C8796

// ═════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═════════════════════════════════════════════════════════════════════════════
g1       = "① HA SMOOTH ENGINE"
preLen   = input.int(6, "Pre-Smooth Length (OHLC)", minval=1, group=g1)
postLen  = input.int(8, "Post-Smooth Length (HA)", minval=1, group=g1)
slowLen  = input.int(21, "Slow Baseline Length", minval=1, group=g1)

gLock = "② STRUCTURE LOCK"
useStructureLock = input.bool(true, "Enable Real Structure Trend Lock", group=gLock, tooltip="When enabled, trend color only changes after a real structure break.")
structureLen = input.int(8, "Structure Pivot Strength", minval=2, maxval=100, group=gLock)
structureSource = input.string("Raw Price", "Structure Source", options=["Raw Price", "Smoothed HA"], group=gLock)
breakMode = input.string("Close", "Structure Break Confirmation", options=["Close", "Wick"], group=gLock)
breakBufferAtr = input.float(0.05, "Structure Break Buffer (×ATR)", minval=0.0, maxval=5.0, step=0.01, group=gLock)
showStructureLevels = input.bool(true, "Show Protected Structure Level", group=gLock)
showStructureBreakLabels = input.bool(true, "Show Structure Break Labels", group=gLock)
structureLabelSize = input.string("Tiny", "Structure Label Size", options=["Tiny", "Small", "Normal"], group=gLock)

gCheat = "③ CHEAT SMOOTH CANDLES"
cheatOn = input.bool(true, "Enable Cheat Smooth Candle Mode", group=gCheat, tooltip="When enabled, candles keep bull color during a real bullish slope until bearish structure breaks. Same logic for bearish trends.")
cheatColorBars = input.bool(true, "Color Real Chart Candles", group=gCheat)
cheatPlotCandles = input.bool(false, "Plot Cheat Smooth Candles", group=gCheat)
cheatSmoothLen = input.int(5, "Cheat Candle Extra Smooth", minval=1, maxval=100, group=gCheat)
cheatUseStructureColor = input.bool(true, "Use Structure Direction For Candle Color", group=gCheat)

g2       = "④ SCALP SIGNAL"
sigMode  = input.string("Trend Pullback", "Entry Mode", options=["Reversal", "Trend Pullback"], group=g2)
needConf = input.int(3, "Min Timeframes Agreeing (0-6)", minval=0, maxval=6, group=g2)
impulse  = input.bool(true, "Impulse Filter (expanding body)", group=g2)

g3       = "⑤ MTF CONFLUENCE"
useTf1   = input.bool(true, "TF 1 Enabled", inline="t1", group=g3)
tf1      = input.timeframe("5", "", inline="t1", group=g3)
useTf2   = input.bool(true, "TF 2 Enabled", inline="t2", group=g3)
tf2      = input.timeframe("15", "", inline="t2", group=g3)
useTf3   = input.bool(true, "TF 3 Enabled", inline="t3", group=g3)
tf3      = input.timeframe("60", "", inline="t3", group=g3)
useTf4   = input.bool(true, "TF 4 Enabled", inline="t4", group=g3)
tf4      = input.timeframe("240", "", inline="t4", group=g3)
useTf5   = input.bool(true, "TF 5 Enabled", inline="t5", group=g3)
tf5      = input.timeframe("D", "", inline="t5", group=g3)
useTf6   = input.bool(true, "TF 6 Enabled", inline="t6", group=g3)
tf6      = input.timeframe("W", "", inline="t6", group=g3)
confirmedMtf = input.bool(true, "Use Confirmed MTF Candles", group=g3)

gHtf = "⑥ EXTRA HTF CONFIRMATOR"
useExtraHtf = input.bool(true, "Enable Extra HTF Confirmator", group=gHtf, tooltip="Blocks buy/sell signals when the selected higher timeframe does not agree.")
extraHtfTf = input.timeframe("240", "Confirmator Timeframe", group=gHtf)
extraHtfLen = input.int(100, "Confirmator EMA Length", minval=2, group=gHtf)
extraHtfMode = input.string("EMA Slope + Price", "Confirmator Mode", options=["EMA Slope + Price", "HA Direction"], group=gHtf)
extraHtfConfirmed = input.bool(true, "Use Confirmed HTF Candle", group=gHtf)

g4       = "⑦ VISUALS"
cloudOn    = input.bool(true, "Trend Cloud", group=g4)
gradientOn = input.bool(true, "Gradient Fill", group=g4)
glowOn     = input.bool(false, "Glow Baseline", group=g4)
haCandles  = input.bool(false, "Plot Smoothed HA Candles", group=g4)
bgTint     = input.bool(false, "Confluence Background Tint", group=g4)
baselineW  = input.int(2, "Baseline Width", minval=1, maxval=5, group=g4)
showSignals = input.bool(true, "Show Buy / Sell Signals", group=g4)
showStars = input.bool(true, "Show Full Confluence Stars", group=g4)

g5       = "⑧ PRO DASHBOARD"
showDash = input.bool(true, "Show Dashboard", group=g5)
dashPos  = input.string("Top Right", "Panel Position", options=["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Center", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], group=g5)
dashSize = input.string("Tiny", "Panel Text Size", options=["Tiny", "Small", "Normal"], group=g5)
dashEmoji = input.bool(true, "Panel Emojis", group=g5)

// ═════════════════════════════════════════════════════════════════════════════
// HELPERS
// ═════════════════════════════════════════════════════════════════════════════
f_size(_s) =>
    _s == "Tiny" ? size.tiny : _s == "Normal" ? size.normal : size.small

f_pos(_p) =>
    _p == "Top Right" ? position.top_right :
     _p == "Top Center" ? position.top_center :
     _p == "Top Left" ? position.top_left :
     _p == "Middle Right" ? position.middle_right :
     _p == "Middle Center" ? position.middle_center :
     _p == "Middle Left" ? position.middle_left :
     _p == "Bottom Right" ? position.bottom_right :
     _p == "Bottom Center" ? position.bottom_center :
     position.bottom_left

// ═════════════════════════════════════════════════════════════════════════════
// SMOOTHED HEIKIN-ASHI ENGINE
// ═════════════════════════════════════════════════════════════════════════════
f_haSmooth(len1, len2) =>
    float o1 = ta.ema(open, len1)
    float h1 = ta.ema(high, len1)
    float l1 = ta.ema(low, len1)
    float c1 = ta.ema(close, len1)
    float haC = (o1 + h1 + l1 + c1) / 4.0
    float haO = na
    haO := na(haO[1]) ? (o1 + c1) / 2.0 : (haO[1] + haC[1]) / 2.0
    float haH = math.max(h1, math.max(haO, haC))
    float haL = math.min(l1, math.min(haO, haC))
    float o2 = ta.ema(haO, len2)
    float c2 = ta.ema(haC, len2)
    float h2 = ta.ema(haH, len2)
    float l2 = ta.ema(haL, len2)
    [o2, h2, l2, c2]

f_haDirOnly(len1, len2) =>
    [o2_, h2_, l2_, c2_] = f_haSmooth(len1, len2)
    c2_ >= o2_ ? 1 : -1

f_haDirConfirmed(len1, len2) =>
    int d = f_haDirOnly(len1, len2)
    nz(d[1], d)

f_emaHtfDir(_len) =>
    float e = ta.ema(close, _len)
    close > e and e >= e[1] ? 1 : close < e and e <= e[1] ? -1 : 0

f_emaHtfDirConfirmed(_len) =>
    int d = f_emaHtfDir(_len)
    nz(d[1], d)

// ═════════════════════════════════════════════════════════════════════════════
// EVALUATE — CHART TF
// ═════════════════════════════════════════════════════════════════════════════
[o2, h2, l2, c2] = f_haSmooth(preLen, postLen)

int rawDir = c2 >= o2 ? 1 : -1
float baseFast = c2
float baseSlow = ta.ema(c2, slowLen)
float atr14 = ta.atr(14)

// ═════════════════════════════════════════════════════════════════════════════
// MTF CONFLUENCE — 6 TIMEFRAMES
// ═════════════════════════════════════════════════════════════════════════════
int dir1Live = request.security(syminfo.tickerid, tf1, f_haDirOnly(preLen, postLen), lookahead=barmerge.lookahead_off)
int dir2Live = request.security(syminfo.tickerid, tf2, f_haDirOnly(preLen, postLen), lookahead=barmerge.lookahead_off)
int dir3Live = request.security(syminfo.tickerid, tf3, f_haDirOnly(preLen, postLen), lookahead=barmerge.lookahead_off)
int dir4Live = request.security(syminfo.tickerid, tf4, f_haDirOnly(preLen, postLen), lookahead=barmerge.lookahead_off)
int dir5Live = request.security(syminfo.tickerid, tf5, f_haDirOnly(preLen, postLen), lookahead=barmerge.lookahead_off)
int dir6Live = request.security(syminfo.tickerid, tf6, f_haDirOnly(preLen, postLen), lookahead=barmerge.lookahead_off)

int dir1Conf = request.security(syminfo.tickerid, tf1, f_haDirConfirmed(preLen, postLen), lookahead=barmerge.lookahead_off)
int dir2Conf = request.security(syminfo.tickerid, tf2, f_haDirConfirmed(preLen, postLen), lookahead=barmerge.lookahead_off)
int dir3Conf = request.security(syminfo.tickerid, tf3, f_haDirConfirmed(preLen, postLen), lookahead=barmerge.lookahead_off)
int dir4Conf = request.security(syminfo.tickerid, tf4, f_haDirConfirmed(preLen, postLen), lookahead=barmerge.lookahead_off)
int dir5Conf = request.security(syminfo.tickerid, tf5, f_haDirConfirmed(preLen, postLen), lookahead=barmerge.lookahead_off)
int dir6Conf = request.security(syminfo.tickerid, tf6, f_haDirConfirmed(preLen, postLen), lookahead=barmerge.lookahead_off)

int dir1raw = confirmedMtf ? dir1Conf : dir1Live
int dir2raw = confirmedMtf ? dir2Conf : dir2Live
int dir3raw = confirmedMtf ? dir3Conf : dir3Live
int dir4raw = confirmedMtf ? dir4Conf : dir4Live
int dir5raw = confirmedMtf ? dir5Conf : dir5Live
int dir6raw = confirmedMtf ? dir6Conf : dir6Live

int enabledCnt = (useTf1 ? 1 : 0) + (useTf2 ? 1 : 0) + (useTf3 ? 1 : 0) + (useTf4 ? 1 : 0) + (useTf5 ? 1 : 0) + (useTf6 ? 1 : 0)
int needConfEff = math.min(needConf, enabledCnt)

int agreeBull = (useTf1 and dir1raw == 1 ? 1 : 0) + (useTf2 and dir2raw == 1 ? 1 : 0) + (useTf3 and dir3raw == 1 ? 1 : 0) + (useTf4 and dir4raw == 1 ? 1 : 0) + (useTf5 and dir5raw == 1 ? 1 : 0) + (useTf6 and dir6raw == 1 ? 1 : 0)
int agreeBear = (useTf1 and dir1raw == -1 ? 1 : 0) + (useTf2 and dir2raw == -1 ? 1 : 0) + (useTf3 and dir3raw == -1 ? 1 : 0) + (useTf4 and dir4raw == -1 ? 1 : 0) + (useTf5 and dir5raw == -1 ? 1 : 0) + (useTf6 and dir6raw == -1 ? 1 : 0)

// ═════════════════════════════════════════════════════════════════════════════
// EXTRA HTF CONFIRMATOR
// ═════════════════════════════════════════════════════════════════════════════
int extraEmaLive = request.security(syminfo.tickerid, extraHtfTf, f_emaHtfDir(extraHtfLen), lookahead=barmerge.lookahead_off)
int extraEmaConf = request.security(syminfo.tickerid, extraHtfTf, f_emaHtfDirConfirmed(extraHtfLen), lookahead=barmerge.lookahead_off)
int extraHaLive = request.security(syminfo.tickerid, extraHtfTf, f_haDirOnly(preLen, postLen), lookahead=barmerge.lookahead_off)
int extraHaConf = request.security(syminfo.tickerid, extraHtfTf, f_haDirConfirmed(preLen, postLen), lookahead=barmerge.lookahead_off)

int extraEmaDir = extraHtfConfirmed ? extraEmaConf : extraEmaLive
int extraHaDir = extraHtfConfirmed ? extraHaConf : extraHaLive
int extraHtfDir = extraHtfMode == "HA Direction" ? extraHaDir : extraEmaDir

bool extraLongOk = not useExtraHtf or extraHtfDir == 1
bool extraShortOk = not useExtraHtf or extraHtfDir == -1

// ═════════════════════════════════════════════════════════════════════════════
// REAL STRUCTURE LOCK
// ═════════════════════════════════════════════════════════════════════════════
float structHigh = structureSource == "Raw Price" ? high : h2
float structLow  = structureSource == "Raw Price" ? low : l2

float ph = ta.pivothigh(structHigh, structureLen, structureLen)
float pl = ta.pivotlow(structLow, structureLen, structureLen)

var float lastSwingHigh = na
var int lastSwingHighBar = na
var float lastSwingLow = na
var int lastSwingLowBar = na

if not na(ph)
    lastSwingHigh := ph
    lastSwingHighBar := bar_index - structureLen

if not na(pl)
    lastSwingLow := pl
    lastSwingLowBar := bar_index - structureLen

var int structDir = na
var float protectedHigh = na
var int protectedHighBar = na
var float protectedLow = na
var int protectedLowBar = na

if na(structDir)
    structDir := rawDir

if structDir == 1 and not na(pl)
    protectedLow := pl
    protectedLowBar := bar_index - structureLen

if structDir == -1 and not na(ph)
    protectedHigh := ph
    protectedHighBar := bar_index - structureLen

if structDir == 1 and na(protectedLow) and not na(lastSwingLow)
    protectedLow := lastSwingLow
    protectedLowBar := lastSwingLowBar

if structDir == -1 and na(protectedHigh) and not na(lastSwingHigh)
    protectedHigh := lastSwingHigh
    protectedHighBar := lastSwingHighBar

float bullBreakLevel = not na(protectedLow) ? protectedLow - breakBufferAtr * atr14 : na
float bearBreakLevel = not na(protectedHigh) ? protectedHigh + breakBufferAtr * atr14 : na

bool bullStructureBroken = not na(bullBreakLevel) and (breakMode == "Close" ? close < bullBreakLevel : low < bullBreakLevel)
bool bearStructureBroken = not na(bearBreakLevel) and (breakMode == "Close" ? close > bearBreakLevel : high > bearBreakLevel)

bool structureFlipBear = false
bool structureFlipBull = false

if useStructureLock
    if structDir == 1 and bullStructureBroken
        structDir := -1
        structureFlipBear := true
        protectedHigh := lastSwingHigh
        protectedHighBar := lastSwingHighBar
        protectedLow := na
        protectedLowBar := na

    if structDir == -1 and bearStructureBroken
        structDir := 1
        structureFlipBull := true
        protectedLow := lastSwingLow
        protectedLowBar := lastSwingLowBar
        protectedHigh := na
        protectedHighBar := na
else
    structureFlipBull := rawDir == 1 and rawDir[1] == -1
    structureFlipBear := rawDir == -1 and rawDir[1] == 1
    structDir := rawDir

int dir = useStructureLock ? structDir : rawDir

// ═════════════════════════════════════════════════════════════════════════════
// CHEAT SMOOTH CANDLE MODE
// ═════════════════════════════════════════════════════════════════════════════
float chO = ta.ema(o2, cheatSmoothLen)
float chH = ta.ema(h2, cheatSmoothLen)
float chL = ta.ema(l2, cheatSmoothLen)
float chC = ta.ema(c2, cheatSmoothLen)

int cheatColorDir = cheatUseStructureColor ? dir : rawDir
color cheatCol = cheatColorDir == 1 ? C_BULL : C_BEAR

barcolor(cheatOn and cheatColorBars ? cheatCol : na, title="Cheat Candle Color")

plotcandle(cheatOn and cheatPlotCandles ? chO : na, cheatOn and cheatPlotCandles ? chH : na, cheatOn and cheatPlotCandles ? chL : na, cheatOn and cheatPlotCandles ? chC : na, "Cheat Smooth Candles", color=color.new(cheatCol, 15), wickcolor=color.new(cheatCol, 45), bordercolor=color.new(cheatCol, 0))

// ═════════════════════════════════════════════════════════════════════════════
// SIGNALS
// ═════════════════════════════════════════════════════════════════════════════
bool flipBull = dir == 1 and dir[1] == -1
bool flipBear = dir == -1 and dir[1] == 1

bool slopeUp = baseSlow > baseSlow[1]
bool slopeDn = baseSlow < baseSlow[1]

float body = math.abs(c2 - o2)
bool impUp = not impulse or body > body[1]

bool trendOKL = sigMode == "Reversal" or slopeUp
bool trendOKS = sigMode == "Reversal" or slopeDn

bool mtfLongOk = enabledCnt == 0 or agreeBull >= needConfEff
bool mtfShortOk = enabledCnt == 0 or agreeBear >= needConfEff

bool longSig = flipBull and mtfLongOk and extraLongOk and trendOKL and impUp
bool shortSig = flipBear and mtfShortOk and extraShortOk and trendOKS and impUp

bool fullBull = longSig and agreeBull == enabledCnt and enabledCnt > 0
bool fullBear = shortSig and agreeBear == enabledCnt and enabledCnt > 0

// ═════════════════════════════════════════════════════════════════════════════
// VISUALS
// ═════════════════════════════════════════════════════════════════════════════
color trendCol = cheatOn ? cheatCol : dir == 1 ? C_BULL : C_BEAR
float cloudTop = math.max(baseFast, baseSlow)
float cloudBot = math.min(baseFast, baseSlow)

pTop = plot(cloudOn ? cloudTop : na, "cloudTop", display=display.none, editable=false)
pBot = plot(cloudOn ? cloudBot : na, "cloudBot", display=display.none, editable=false)
fill(pTop, pBot, top_value=cloudTop, bottom_value=cloudBot, top_color=color.new(trendCol, gradientOn ? 40 : 78), bottom_color=color.new(trendCol, gradientOn ? 92 : 82), title="Trend Cloud")

plot(glowOn ? baseFast : na, "Glow 3", color.new(trendCol, 88), baselineW + 9, editable=false)
plot(glowOn ? baseFast : na, "Glow 2", color.new(trendCol, 74), baselineW + 5, editable=false)
plot(glowOn ? baseFast : na, "Glow 1", color.new(trendCol, 58), baselineW + 2, editable=false)
plot(baseFast, "Fast Baseline", trendCol, baselineW)
plot(baseSlow, "Slow Baseline", color.new(trendCol, 35), 1)

plotcandle(haCandles ? o2 : na, haCandles ? h2 : na, haCandles ? l2 : na, haCandles ? c2 : na, "HA Smooth", color=color.new(trendCol, 20), wickcolor=color.new(trendCol, 50), bordercolor=color.new(trendCol, 0))

int agreeDir = dir == 1 ? agreeBull : agreeBear
bgcolor(bgTint ? color.new(trendCol, 97 - agreeDir * 4) : na, title="Confluence Tint")

plotshape(showSignals and longSig, "Long Scalp", shape.triangleup, location.belowbar, color.new(C_BULL, 0), size=size.small)
plotchar(showSignals and longSig, "Long Mark", "▲", location.belowbar, color.new(C_BULL, 0), size=size.tiny)

plotshape(showSignals and shortSig, "Short Scalp", shape.triangledown, location.abovebar, color.new(C_BEAR, 0), size=size.small)
plotchar(showSignals and shortSig, "Short Mark", "▼", location.abovebar, color.new(C_BEAR, 0), size=size.tiny)

plotchar(showStars and fullBull, "Full Bull", "★", location.belowbar, color.new(C_GOLD, 0), size=size.tiny)
plotchar(showStars and fullBear, "Full Bear", "★", location.abovebar, color.new(C_GOLD, 0), size=size.tiny)

float protectedLine = dir == 1 ? protectedLow : protectedHigh
plot(showStructureLevels ? protectedLine : na, "Protected Structure", dir == 1 ? color.new(C_BULL, 25) : color.new(C_BEAR, 25), 1, plot.style_linebr)

if showStructureBreakLabels and structureFlipBull
    label.new(bar_index, low, "structure break ▲", style=label.style_label_up, color=color.new(C_BULL, 70), textcolor=C_BULL, size=f_size(structureLabelSize))

if showStructureBreakLabels and structureFlipBear
    label.new(bar_index, high, "structure break ▼", style=label.style_label_down, color=color.new(C_BEAR, 70), textcolor=C_BEAR, size=f_size(structureLabelSize))

// ═════════════════════════════════════════════════════════════════════════════
// DASHBOARD
// ═════════════════════════════════════════════════════════════════════════════
f_tfCell(bool en, int d, string tf) =>
    string txt = not en ? "off" : d == 1 ? "▲ " + tf : d == -1 ? "▼ " + tf : "— " + tf
    color col = not en ? C_DIM : d == 1 ? C_BULL : d == -1 ? C_BEAR : C_DIM
    [txt, col]

var string lastSig = "—"
var color lastCol = C_DIM

if longSig
    lastSig := "▲ LONG"
    lastCol := C_BULL

if shortSig
    lastSig := "▼ SHORT"
    lastCol := C_BEAR

var table dash = na
var string dashKey = ""

string curDashKey = dashPos + "|" + dashSize + "|" + str.tostring(dashEmoji)
posSel = f_pos(dashPos)
szc = f_size(dashSize)

if barstate.islast
    if showDash
        if na(dash) or dashKey != curDashKey
            if not na(dash)
                table.delete(dash)
            dash := table.new(posSel, 2, 14, bgcolor=color.new(C_G0, 4), border_color=color.new(C_G4, 45), border_width=1, frame_color=color.new(C_G4, 35), frame_width=1)
            dashKey := curDashKey

        string eChart = dashEmoji ? "📈 " : ""
        string eTf = dashEmoji ? "📡 " : ""
        string eConf = dashEmoji ? "🧭 " : ""
        string eLock = dashEmoji ? "🛡 " : ""
        string eProt = dashEmoji ? "🔒 " : ""
        string eSig = dashEmoji ? "🔔 " : ""
        string eMode = dashEmoji ? "🧠 " : ""

        table.cell(dash, 0, 0, "HA SMOOTH SCALP", text_color=C_TXT, bgcolor=C_G3, text_size=szc, text_halign=text.align_center)
        table.cell(dash, 1, 0, "PRO", text_color=C_TXT, bgcolor=C_G3, text_size=szc, text_halign=text.align_center)

        table.cell(dash, 0, 1, eChart + "CHART " + str.upper(timeframe.period), text_color=C_TXT, bgcolor=C_G1, text_size=szc, text_halign=text.align_left)
        table.cell(dash, 1, 1, dir == 1 ? "▲ BULL" : "▼ BEAR", text_color=trendCol, bgcolor=C_G1, text_size=szc, text_halign=text.align_right)

        [t1txt, t1col] = f_tfCell(useTf1, dir1raw, str.upper(tf1))
        table.cell(dash, 0, 2, eTf + "TF 1", text_color=C_TXT, bgcolor=C_G2, text_size=szc, text_halign=text.align_left)
        table.cell(dash, 1, 2, t1txt, text_color=t1col, bgcolor=C_G2, text_size=szc, text_halign=text.align_right)

        [t2txt, t2col] = f_tfCell(useTf2, dir2raw, str.upper(tf2))
        table.cell(dash, 0, 3, eTf + "TF 2", text_color=C_TXT, bgcolor=C_G1, text_size=szc, text_halign=text.align_left)
        table.cell(dash, 1, 3, t2txt, text_color=t2col, bgcolor=C_G1, text_size=szc, text_halign=text.align_right)

        [t3txt, t3col] = f_tfCell(useTf3, dir3raw, str.upper(tf3))
        table.cell(dash, 0, 4, eTf + "TF 3", text_color=C_TXT, bgcolor=C_G2, text_size=szc, text_halign=text.align_left)
        table.cell(dash, 1, 4, t3txt, text_color=t3col, bgcolor=C_G2, text_size=szc, text_halign=text.align_right)

        [t4txt, t4col] = f_tfCell(useTf4, dir4raw, str.upper(tf4))
        table.cell(dash, 0, 5, eTf + "TF 4", text_color=C_TXT, bgcolor=C_G1, text_size=szc, text_halign=text.align_left)
        table.cell(dash, 1, 5, t4txt, text_color=t4col, bgcolor=C_G1, text_size=szc, text_halign=text.align_right)

        [t5txt, t5col] = f_tfCell(useTf5, dir5raw, str.upper(tf5))
        table.cell(dash, 0, 6, eTf + "TF 5", text_color=C_TXT, bgcolor=C_G2, text_size=szc, text_halign=text.align_left)
        table.cell(dash, 1, 6, t5txt, text_color=t5col, bgcolor=C_G2, text_size=szc, text_halign=text.align_right)

        [t6txt, t6col] = f_tfCell(useTf6, dir6raw, str.upper(tf6))
        table.cell(dash, 0, 7, eTf + "TF 6", text_color=C_TXT, bgcolor=C_G1, text_size=szc, text_halign=text.align_left)
        table.cell(dash, 1, 7, t6txt, text_color=t6col, bgcolor=C_G1, text_size=szc, text_halign=text.align_right)

        int agShow = dir == 1 ? agreeBull : agreeBear
        color agCol = enabledCnt > 0 and agShow >= needConfEff ? C_GOLD : agShow > 0 ? C_TXT : C_DIM
        table.cell(dash, 0, 8, eConf + "MTF AGREE", text_color=C_TXT, bgcolor=C_G2, text_size=szc, text_halign=text.align_left)
        table.cell(dash, 1, 8, str.tostring(agShow) + " / " + str.tostring(enabledCnt) + " min " + str.tostring(needConfEff), text_color=agCol, bgcolor=C_G2, text_size=szc, text_halign=text.align_right)

        string extraTxt = not useExtraHtf ? "off" : extraHtfDir == 1 ? "▲ " + str.upper(extraHtfTf) : extraHtfDir == -1 ? "▼ " + str.upper(extraHtfTf) : "— " + str.upper(extraHtfTf)
        color extraCol = not useExtraHtf ? C_DIM : extraHtfDir == 1 ? C_BULL : extraHtfDir == -1 ? C_BEAR : C_DIM
        table.cell(dash, 0, 9, eConf + "HTF CONF", text_color=C_TXT, bgcolor=C_G1, text_size=szc, text_halign=text.align_left)
        table.cell(dash, 1, 9, extraTxt, text_color=extraCol, bgcolor=C_G1, text_size=szc, text_halign=text.align_right)

        table.cell(dash, 0, 10, eLock + "LOCK", text_color=C_TXT, bgcolor=C_G2, text_size=szc, text_halign=text.align_left)
        table.cell(dash, 1, 10, useStructureLock ? "structure" : "ha flip", text_color=useStructureLock ? C_GOLD : C_DIM, bgcolor=C_G2, text_size=szc, text_halign=text.align_right)

        table.cell(dash, 0, 11, eProt + "PROTECTED", text_color=C_TXT, bgcolor=C_G1, text_size=szc, text_halign=text.align_left)
        table.cell(dash, 1, 11, na(protectedLine) ? "—" : str.tostring(protectedLine, format.mintick), text_color=trendCol, bgcolor=C_G1, text_size=szc, text_halign=text.align_right)

        table.cell(dash, 0, 12, eMode + "CHEAT", text_color=C_TXT, bgcolor=C_G2, text_size=szc, text_halign=text.align_left)
        table.cell(dash, 1, 12, cheatOn ? cheatColorDir == 1 ? "🟢 bull lock" : "🔴 bear lock" : "off", text_color=cheatOn ? cheatCol : C_DIM, bgcolor=C_G2, text_size=szc, text_halign=text.align_right)

        table.cell(dash, 0, 13, eSig + "LAST SIG", text_color=C_TXT, bgcolor=C_G1, text_size=szc, text_halign=text.align_left)
        table.cell(dash, 1, 13, lastSig, text_color=lastCol, bgcolor=C_G1, text_size=szc, text_halign=text.align_right)

    else
        if not na(dash)
            table.delete(dash)
            dash := na
            dashKey := ""

// ═════════════════════════════════════════════════════════════════════════════
// ALERTS
// ═════════════════════════════════════════════════════════════════════════════
alertcondition(longSig, "Long Scalp", "HA SCALP: long entry MTF and HTF confirmed")
alertcondition(shortSig, "Short Scalp", "HA SCALP: short entry MTF and HTF confirmed")
alertcondition(fullBull, "Full Bull", "HA SCALP: long all selected timeframes aligned")
alertcondition(fullBear, "Full Bear", "HA SCALP: short all selected timeframes aligned")
alertcondition(structureFlipBull, "Structure Bull Break", "HA SCALP: bullish structure break")
alertcondition(structureFlipBear, "Structure Bear Break", "HA SCALP: bearish structure break")
````
