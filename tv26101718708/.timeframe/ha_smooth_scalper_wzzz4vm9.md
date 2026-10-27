# Ha Smooth Scalper

- url: https://www.tradingview.com/script/WzZZ4VM9-Ha-Smooth-Scalper/
- type: indicator
- pine_id: PUB;351ae762e07a4a239eaf9c8103c62f6b
- version: 1.0

## Description

ha smooth scalper is a trend, structure and multi-timeframe scalping tool built around smoothed heikin-ashi price action.

the indicator combines a double-smoothed heikin-ashi engine with confirmed market structure, protected swing levels, multi-timeframe direction, an independent higher-timeframe confirmator and configurable entry filters.

its main purpose is to reduce short-term candle noise while preventing every small heikin-ashi color change from being interpreted as a genuine trend reversal.

the system can maintain the current bullish or bearish state until real market structure is broken, while the multi-timeframe engine measures whether the surrounding timeframes support the same direction.

### ha smooth engine

the core of the indicator is a double-smoothed heikin-ashi calculation.

raw open, high, low and close values are first smoothed before the heikin-ashi calculation is performed. the resulting heikin-ashi values are then smoothed again.

this creates a cleaner representation of directional movement than standard candles.

**pre-smooth length**

controls the first ema smoothing applied to the original ohlc data.

lower values make the engine react faster to price changes.

higher values remove more short-term noise but make the calculation slower to react.

**post-smooth length**

controls the second smoothing stage applied after the heikin-ashi values have been calculated.

increasing this setting creates a smoother directional structure.

reducing it produces a more responsive heikin-ashi engine.

**slow baseline length**

controls the slower ema calculated from the smoothed heikin-ashi close.

the fast and slow baselines are used to visualize trend behavior and to determine slope direction for trend-pullback signals.

### real structure trend lock

the structure lock is designed to prevent the indicator from changing trend direction because of a simple short-term heikin-ashi color flip.

when enabled, the active bullish or bearish state remains locked until a protected market structure level is genuinely broken.

during a bullish structure, the system protects confirmed swing lows.

during a bearish structure, it protects confirmed swing highs.

the trend changes only when price breaks the relevant protected structure according to the selected confirmation method.

**enable real structure trend lock**

activates this structural trend logic.

when disabled, trend direction follows the raw smoothed heikin-ashi direction instead.

**structure pivot strength**

controls how many bars are required to confirm structural swing highs and lows.

lower values create a more responsive structure model with more frequent pivots.

higher values focus on larger and more established swings.

**structure source**

two sources are available:

**raw price**

uses the actual chart highs and lows to identify market structure.

**smoothed ha**

uses the smoothed heikin-ashi highs and lows.

raw price provides a more direct representation of actual traded price structure, while smoothed ha produces a cleaner structural interpretation.

### structure break confirmation

a protected structure can be broken using either a candle close or a wick.

**close**

requires price to close beyond the protected level.

this is the more conservative option because an intrabar wick alone cannot change the structural trend.

**wick**

allows a high or low penetration to confirm the structure break.

this reacts faster but is more sensitive to temporary liquidity sweeps and wick excursions.

### structure break buffer

**structure break buffer × atr** adds an atr-based distance beyond the protected swing before a structure break is accepted.

with a bullish trend, the protected low is adjusted downward by the selected atr buffer.

with a bearish trend, the protected high is adjusted upward.

a larger buffer requires a deeper structural violation.

a smaller buffer makes the lock more sensitive.

this can be useful for filtering small penetrations around obvious swing levels.

### protected structure level

**show protected structure level** displays the price currently controlling the structural trend.

in a bullish structure, this is the protected low.

in a bearish structure, this is the protected high.

this line provides a direct visual reference for the level that must be violated before the structural direction can change.

### structure break labels

**show structure break labels** displays a label when the structural state flips from bearish to bullish or bullish to bearish.

**structure label size** controls the size of these labels.

available sizes are tiny, small and normal.

### cheat smooth candle mode

cheat smooth candle mode is a visual trend-lock system.

instead of allowing every short-term candle fluctuation to change chart color, candles can remain bullish while the active direction remains bullish and bearish while the active direction remains bearish.

when structure direction is selected as the color source, the candle color can remain locked until the real structure engine changes direction.

**enable cheat smooth candle mode**

activates the feature.

**color real chart candles**

applies the active cheat direction directly to the original chart candles.

**plot cheat smooth candles**

draws a separate set of additionally smoothed candles.

**cheat candle extra smooth**

controls the extra ema smoothing applied to these candles.

larger values create cleaner and slower candles.

smaller values remain closer to the underlying smoothed heikin-ashi movement.

**use structure direction for candle color**

when enabled, candle color follows the structure-locked direction.

when disabled, color follows the raw smoothed heikin-ashi direction.

this distinction is important when using the indicator to remain visually aligned with the larger active structure during small countertrend movements.

### scalp signal engine

the indicator contains two entry modes:

**reversal**

allows a signal when the active direction flips and the other enabled confirmation requirements are satisfied.

**trend pullback**

adds the slow baseline slope as an additional trend filter.

for a long signal in trend-pullback mode, the slow baseline must be rising.

for a short signal, the slow baseline must be falling.

this makes trend-pullback mode more selective about taking directional changes against the current baseline slope.

### impulse filter

**impulse filter** requires the current smoothed heikin-ashi candle body to be larger than the previous body.

the filter is intended to require increasing candle displacement when a signal occurs.

when disabled, this expanding-body requirement is removed.

### multi-timeframe confluence

ha smooth scalper can evaluate up to six independent timeframes.

each timeframe can be individually enabled or disabled.

the default configuration includes:

5 minute

15 minute

1 hour

4 hour

daily

weekly

each timeframe is evaluated using the same smoothed heikin-ashi directional engine.

the dashboard then displays whether each enabled timeframe is bullish or bearish.

### minimum timeframes agreeing

**min timeframes agreeing** defines how many enabled timeframes must agree with the signal direction.

the value can range from 0 to 6.

for example, if six timeframes are enabled and the minimum is set to three, at least three must be bullish for a qualifying long signal or bearish for a qualifying short signal.

the effective requirement automatically adapts to the number of enabled timeframes.

this means that disabling timeframes does not leave an impossible confirmation requirement.

setting the value to zero removes the minimum agreement requirement.

### confirmed mtf candles

**use confirmed mtf candles** determines whether multi-timeframe direction is based on confirmed higher-timeframe information or the currently developing higher-timeframe candle.

confirmed mode uses the previous confirmed directional state from each requested timeframe.

this is useful when stable multi-timeframe confirmation is preferred over faster intrabar changes.

live mode reacts more quickly but can change while the higher-timeframe candle is still developing.

### extra htf confirmator

the indicator includes a separate higher-timeframe confirmation layer in addition to the six-timeframe confluence system.

when enabled, this confirmator can block a long or short signal if its selected higher timeframe does not agree with the proposed direction.

**confirmator timeframe**

selects the timeframe used for this additional filter.

**confirmator ema length**

sets the ema period when the ema-based confirmation method is selected.

### confirmator modes

two methods are available:

**ema slope + price**

a bullish confirmation requires price to be above the higher-timeframe ema while the ema is flat-to-rising.

a bearish confirmation requires price below the ema while the ema is flat-to-falling.

if neither condition is satisfied, the confirmator remains neutral and does not approve either direction.

**ha direction**

uses the smoothed heikin-ashi direction from the selected higher timeframe instead.

### confirmed htf candle

**use confirmed htf candle** determines whether the extra higher-timeframe confirmator uses confirmed information or the current developing higher-timeframe state.

confirmed mode is more stable.

live mode is more responsive but can change before the higher-timeframe candle closes.

### how a long signal is built

a long signal begins when the active direction changes from bearish to bullish.

the signal must then pass the enabled filters.

depending on the configuration, this can include:

a bullish structural flip

the required number of bullish mtf directions

bullish approval from the extra htf confirmator

a rising slow baseline in trend-pullback mode

an expanding smoothed candle body when the impulse filter is enabled

only when the required conditions agree does the indicator generate the long signal.

### how a short signal is built

a short signal follows the opposite process.

the active direction must change from bullish to bearish.

the required number of enabled timeframes must support the bearish direction.

the extra htf confirmator must approve the bearish side when enabled.

trend-pullback mode requires a falling slow baseline.

the impulse filter can additionally require expanding candle displacement.

### full confluence stars

a gold star represents stronger timeframe alignment than a normal signal.

a bullish star requires a valid long signal while every enabled mtf direction is bullish.

a bearish star requires a valid short signal while every enabled mtf direction is bearish.

this makes the star a visual marker for complete agreement across all selected mtf filters at the moment of the signal.

it does not guarantee that the trade will continue in that direction.

### trend cloud

**trend cloud** displays the area between the fast smoothed heikin-ashi baseline and the slower baseline.

the cloud automatically follows the active bullish or bearish direction.

**gradient fill**

changes the visual density of the cloud and creates a stronger gradient between its boundaries.

the cloud can be used as a quick visual reference for trend direction, baseline separation and changes in directional structure.

### glow baseline

**glow baseline** adds several transparent layers around the fast baseline.

this option is purely visual and can make the active directional baseline easier to identify.

**baseline width** controls the width of the primary fast baseline.

### smoothed ha candles

**plot smoothed ha candles** displays the main double-smoothed heikin-ashi candles directly on the price chart.

this is separate from cheat smooth candles.

the standard smoothed ha candles represent the underlying ha engine, while cheat candles add another smoothing stage and can use the locked structure direction for their color.

### confluence background tint

**confluence background tint** adds a subtle background color based on the active trend direction.

the strength of the tint changes according to the number of timeframes agreeing with the current direction.

this provides a fast visual representation of mtf alignment without requiring constant attention to the dashboard.

### buy and sell signals

**show buy / sell signals** controls the long and short markers displayed on the chart.

bullish signals are shown below price.

bearish signals are shown above price.

disabling this option hides the markers without changing the underlying signal calculations.

### pro dashboard

the dashboard provides a compact summary of the entire system.

it displays:

current chart direction

tf 1 direction

tf 2 direction

tf 3 direction

tf 4 direction

tf 5 direction

tf 6 direction

current mtf agreement count

minimum mtf agreement required

extra htf confirmator direction

current trend-lock method

current protected structure price

cheat candle lock direction

last generated signal

each disabled timeframe is clearly marked as off.

### dashboard position

the dashboard can be placed in nine locations:

top right

top center

top left

middle right

middle center

middle left

bottom right

bottom center

bottom left

### dashboard appearance

**panel text size** provides tiny, small and normal display modes.

**panel emojis** enables or removes the dashboard icons.

**show dashboard** completely enables or disables the panel.

### alerts

the indicator includes dedicated alerts for:

long scalp signals

short scalp signals

full bullish confluence

full bearish confluence

bullish structure breaks

bearish structure breaks

this allows the system to be monitored without requiring every chart to remain continuously visible.

### quick start

start with the default settings and observe the main chart direction.

green represents the active bullish state.

red represents the active bearish state.

with structure lock enabled, do not interpret every temporary countertrend candle as a trend reversal.

instead, watch the protected structure level.

during a bullish structure, the protected low represents the level controlling the current bullish state.

during a bearish structure, the protected high controls the bearish state.

a valid break of this level can flip the structural direction.

next, check the dashboard.

look at how many of the enabled timeframes agree with the current chart direction.

for example, if the dashboard shows four bullish timeframes out of six and the minimum requirement is three, the mtf filter currently satisfies the bullish agreement requirement.

then check the extra htf confirmator.

if it points in the opposite direction, new signals on the conflicting side can be blocked.

when a buy or sell marker appears, the indicator has detected a directional flip that also satisfies the active signal filters.

a gold star means the signal occurred while every enabled mtf direction agreed with it.

### a simple scalping workflow

use a lower chart timeframe for execution while keeping several larger timeframes enabled for context.

keep structure lock enabled to reduce unnecessary directional changes.

use **close** confirmation when you want structure to survive temporary wick sweeps.

use **trend pullback** mode when you want signals to agree with the slow baseline slope.

set the minimum mtf agreement according to how selective you want the signal engine to be.

use the extra htf confirmator as a final directional filter.

when a signal appears, check:

the protected structure

the current chart direction

mtf agreement

extra htf direction

baseline slope

whether full confluence is present

then use your own entry, invalidation and risk-management rules before taking a position.

### faster configuration

for a more responsive setup:

reduce pre-smooth length

reduce post-smooth length

reduce structure pivot strength

reduce the structure break buffer

use live mtf candles

use live extra htf confirmation

reduce the minimum number of agreeing timeframes

these changes increase responsiveness but can also increase sensitivity to market noise.

### more selective configuration

for a slower and more filtered setup:

increase pre-smooth and post-smooth lengths

increase structure pivot strength

use close-based structure confirmation

increase the atr structure buffer moderately

enable confirmed mtf candles

enable confirmed htf candles

increase the minimum timeframe agreement

keep the extra htf confirmator enabled

use trend-pullback mode

keep the impulse filter enabled

this configuration requires more conditions to agree before signals are accepted.

### understanding structure lock

structure lock is one of the central features of the indicator.

standard trend systems can rapidly alternate between bullish and bearish states during sideways movement.

this script can instead separate short-term heikin-ashi movement from actual structural invalidation.

a bullish state can therefore remain bullish during a temporary bearish pullback as long as the protected bullish structure has not been broken.

the same principle applies to bearish structure.

this is also why cheat candle coloring can remain consistently bullish or bearish through smaller countertrend movements.

### using raw price vs smoothed ha structure

**raw price** is useful when the protected levels should correspond directly to actual market highs and lows.

**smoothed ha** removes part of the underlying price noise before structural pivots are detected.

raw price generally produces levels that are easier to compare with conventional support, resistance and swing analysis.

smoothed ha can create a cleaner structural model when the underlying chart is particularly noisy.

### using close vs wick confirmation

**close** confirmation can be useful when the market frequently trades through obvious swing levels before recovering.

a wick through the protected level does not immediately change the trend.

**wick** confirmation reacts as soon as the structural boundary is exceeded.

it can therefore detect changes sooner, but it is also more vulnerable to liquidity sweeps and temporary price spikes.

### how ha smooth scalper can help

ha smooth scalper can help with:

reducing short-term candle noise

maintaining a cleaner visual trend state

separating temporary heikin-ashi flips from structural trend changes

tracking protected swing highs and lows

identifying confirmed bullish and bearish structure breaks

comparing direction across as many as six configurable timeframes

requiring a minimum level of mtf agreement before signals

filtering entries with an independent higher-timeframe trend condition

distinguishing live higher-timeframe information from confirmed higher-timeframe states

finding directional flips with optional momentum expansion

filtering trend-pullback entries using baseline slope

highlighting complete multi-timeframe alignment

keeping chart candle colors aligned with the active structural direction

monitoring the entire setup through a compact dashboard

creating alerts for signals, full confluence and structure changes

the indicator can be particularly useful on lower timeframes where raw candle direction changes frequently and a trader wants to preserve broader structural context.

it can also help separate three different pieces of information that are often mixed together: immediate smoothed price direction, actual protected market structure and higher-timeframe directional agreement.

ha smooth scalper should be used as a market structure and confirmation framework rather than as an automatic trading system. a long or short marker indicates that the conditions configured inside the indicator have aligned; it does not define position size, stop placement, profit targets or the probability that the next trade will be profitable.

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
