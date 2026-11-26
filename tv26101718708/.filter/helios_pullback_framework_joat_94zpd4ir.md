# Helios Pullback Framework [JOAT]

- url: https://www.tradingview.com/script/94zPd4Ir-Helios-Pullback-Framework-JOAT/
- type: indicator
- pine_id: PUB;aeffbcfb833e4a3689447a4157778e69
- version: 1.0

## Description

[b]Helios Pullback Framework [JOAT][/b]

[b]Introduction[/b]

Helios Pullback Framework evaluates pullback quality using ALMA trend stack, regression trajectory, pullback depth, wick recovery, liquidity capture, compression, and HTF bias.

This open-source indicator is designed as a context tool, not a standalone trading system. It focuses on explaining the current market state with restrained visuals and confirmed-bar logic where signals are used.

[image]https://www.tradingview.com/x/nGGdFURn/[/image]

[b]Core Concepts[/b]

[b]1. ALMA Trend Stack[/b]

Fast and slow ALMA lines define execution and institutional spines.

[b]2. Regression Trajectory[/b]

A regression envelope provides dynamic path context rather than static zones.

[b]3. Pullback Quality[/b]

Pullback depth, wick recovery, phase impulse, and stretch are scored.

[b]4. Liquidity Capture[/b]

Confirmed sweeps of recent highs or lows contribute only when aligned with bias.

[pine]
score = bias + pullDepth + wickRecovery + sweep + compression + htf
[/pine]

[b]Features[/b]

[list]
[*]ALMA trend stack
[*]Regression trajectory envelope
[*]Pullback depth and wick recovery scoring
[*]Liquidity capture markers
[*]Sparse P+ and P- labels
[/list]

[b]Input Parameters[/b]

[list]
[*]ALMA lengths
[*]Volatility and trajectory length
[*]HTF and optional session gate
[*]Signal score, cooldown, and max stretch
[*]Display toggles
[/list]


[b]How to Use This Script[/b]

Use P+ and P- labels as pullback-quality events inside an existing bias. Gold circles mark liquidity capture without full confirmation.

[b]Limitations[/b]

[list]
[*]The script uses historical OHLCV data and cannot know future prices.
[*]Signals and states can be late during fast reversals because confirmed-bar logic is used to reduce repainting.
[*]Model outputs should be interpreted with market context, risk controls, and independent analysis.
[*]No visual state should be treated as a certain trade outcome.
[/list]

[b]Originality Statement[/b]

Helios is original in replacing supply/demand boxes with a cleaner model that scores pullback elasticity, trajectory, and liquidity capture.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any financial instrument. All calculations are derived from historical market data and may produce inaccurate readings in some market conditions. No indicator can predict future market behavior. Use proper risk management and independent judgment.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Helios Pullback Framework [JOAT]", shorttitle="HPF [JOAT]", overlay=true, max_lines_count=120, max_labels_count=80, max_boxes_count=20)

string gCore = "Core"
string gContext = "Context"
string gSignal = "Signal Engine"
string gVisual = "Visual System"
int almaFastLen = input.int(34, "Execution ALMA", minval=8, maxval=120, group=gCore)
int almaSlowLen = input.int(89, "Institutional ALMA", minval=21, maxval=260, group=gCore)
int atrLen = input.int(14, "Volatility length", minval=5, maxval=100, group=gCore)
int regLen = input.int(80, "Trajectory length", minval=30, maxval=240, group=gCore)
int phaseLen = input.int(14, "Momentum phase length", minval=5, maxval=60, group=gCore)
string htf = input.timeframe("240", "Bias timeframe", group=gContext)
bool useHtf = input.bool(true, "Use HTF bias", group=gContext)
bool useSession = input.bool(false, "Use session gate", group=gContext)
string tradeSession = input.session("0300-1700:23456", "Session", group=gContext)
float minScore = input.float(72.0, "Signal score", minval=50.0, maxval=95.0, step=1.0, group=gSignal)
int cooldownBars = input.int(12, "Signal cooldown", minval=1, maxval=100, group=gSignal)
float maxStretchAtr = input.float(2.2, "Maximum entry stretch ATR", minval=0.5, maxval=5.0, step=0.1, group=gSignal)
bool paintBars = input.bool(true, "Paint candles", group=gVisual)
bool showBands = input.bool(true, "Show impulse corridor", group=gVisual)
bool showPhase = input.bool(true, "Show pullback trajectory", group=gVisual)

color C_BULL = #00ffe1
color C_BEAR = #ff25f6
color C_GOLD = #ffbf00
color C_BLUE = #3f7cff
color C_VIOLET = #9b5cff
color C_TEXT = #eef6ff
color C_MUTED = #718096
color C_BG = #060812

clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

zscore(float src, int len) =>
    float basis = ta.sma(src, len)
    float dev = ta.stdev(src, len)
    dev == 0.0 ? 0.0 : (src - basis) / dev

float atr = ta.atr(atrLen)
float fast = ta.alma(close, almaFastLen, 0.85, 6.0)
float slow = ta.alma(close, almaSlowLen, 0.78, 6.0)
float htfFast = useHtf ? request.security(syminfo.tickerid, htf, ta.alma(close, almaFastLen, 0.85, 6.0)[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off) : fast
float htfSlow = useHtf ? request.security(syminfo.tickerid, htf, ta.alma(close, almaSlowLen, 0.78, 6.0)[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off) : slow
bool htfBull = not useHtf or htfFast > htfSlow
bool htfBear = not useHtf or htfFast < htfSlow
bool inSession = not useSession or not na(time(timeframe.period, tradeSession))

float reg = ta.linreg(close, regLen, 0)
float regPrev = ta.linreg(close, regLen, 1)
float regSlope = (reg - regPrev) / math.max(atr, syminfo.mintick)
float resid = close - reg
float residDev = ta.stdev(resid, regLen)
float channel = math.max(residDev, atr * 0.55)
float upper = reg + channel * 1.35
float lower = reg - channel * 1.35
float fastSlope = (fast - fast[5]) / math.max(atr, syminfo.mintick)
int bias = fast > slow and regSlope > 0 and htfBull ? 1 : fast < slow and regSlope < 0 and htfBear ? -1 : 0

float rsi = ta.rsi(close, phaseLen)
float rsiSignal = ta.ema(rsi, 7)
float phase = (rsi - rsiSignal) / 10.0
float phaseImpulse = ta.ema(phase - phase[1], 3)
float pullDepth = bias == 1 ? clamp((fast - low) / math.max(atr, syminfo.mintick), 0.0, 5.0) : bias == -1 ? clamp((high - fast) / math.max(atr, syminfo.mintick), 0.0, 5.0) : 0.0
float stretch = math.abs(close - fast) / math.max(atr, syminfo.mintick)
float reversionForce = bias == 1 ? clamp((close - low) / math.max(high - low, syminfo.mintick), 0.0, 1.0) : bias == -1 ? clamp((high - close) / math.max(high - low, syminfo.mintick), 0.0, 1.0) : 0.0
float volZ = zscore(nz(volume, 0), 40)
float rangeZ = zscore(high - low, 40)
float compression = clamp(1.0 - ta.stdev(close, 12) / math.max(ta.stdev(close, 48), syminfo.mintick), 0.0, 1.0)

float swingHigh = ta.pivothigh(high, 8, 8)
float swingLow = ta.pivotlow(low, 8, 8)
var float lastSweepHigh = na
var float lastSweepLow = na
if not na(swingHigh)
    lastSweepHigh := swingHigh
if not na(swingLow)
    lastSweepLow := swingLow
bool lowerSweep = barstate.isconfirmed and not na(lastSweepLow) and low < lastSweepLow and close > lastSweepLow
bool upperSweep = barstate.isconfirmed and not na(lastSweepHigh) and high > lastSweepHigh and close < lastSweepHigh

float wickBuy = (math.min(open, close) - low) / math.max(high - low, syminfo.mintick)
float wickSell = (high - math.max(open, close)) / math.max(high - low, syminfo.mintick)
bool impulseRecover = bias == 1 and close > fast and close > open and phaseImpulse > 0
bool impulseReject = bias == -1 and close < fast and close < open and phaseImpulse < 0
float longScore = clamp((bias == 1 ? 22 : 0) + (htfBull ? 14 : 0) + clamp(pullDepth / 1.4 * 16, 0, 16) + (lowerSweep ? 12 : 0) + clamp(wickBuy * 14, 0, 14) + (impulseRecover ? 11 : 0) + clamp((volZ + 1.0) * 4, 0, 10) + clamp(compression * 7, 0, 7) + clamp(fastSlope * 5, 0, 6) + clamp(reversionForce * 8, 0, 8) + (inSession ? 6 : 0), 0, 100)
float shortScore = clamp((bias == -1 ? 22 : 0) + (htfBear ? 14 : 0) + clamp(pullDepth / 1.4 * 16, 0, 16) + (upperSweep ? 12 : 0) + clamp(wickSell * 14, 0, 14) + (impulseReject ? 11 : 0) + clamp((volZ + 1.0) * 4, 0, 10) + clamp(compression * 7, 0, 7) + clamp(-fastSlope * 5, 0, 6) + clamp(reversionForce * 8, 0, 8) + (inSession ? 6 : 0), 0, 100)

var int lastSignalBar = na
bool cooled = na(lastSignalBar) or bar_index - lastSignalBar >= cooldownBars
bool longState = barstate.isconfirmed and cooled and longScore >= minScore and stretch <= maxStretchAtr and close > lower and bias == 1
bool shortState = barstate.isconfirmed and cooled and shortScore >= minScore and stretch <= maxStretchAtr and close < upper and bias == -1
bool longEvent = longState and not longState[1]
bool shortEvent = shortState and not shortState[1]
if longEvent or shortEvent
    lastSignalBar := bar_index

float railWidth = atr * (0.65 + compression * 0.35 + math.min(math.abs(regSlope), 1.5) * 0.18)
float buyRail = fast - railWidth
float sellRail = fast + railWidth
float phaseTrace = fast + clamp(phase, -2.0, 2.0) * atr * 0.22
color biasColor = bias == 1 ? C_BULL : bias == -1 ? C_BEAR : C_MUTED
color heatColor = longScore >= minScore ? C_BULL : shortScore >= minScore ? C_BEAR : bias == 1 ? color.new(C_BULL, 40) : bias == -1 ? color.new(C_BEAR, 40) : C_MUTED

pFast = plot(showBands ? fast : na, "HPF execution spine", color=color.new(biasColor, 8), linewidth=2)
pSlow = plot(showBands ? slow : na, "HPF institutional spine", color=color.new(C_TEXT, 62), linewidth=2)
pUpper = plot(showBands ? sellRail : na, "HPF upper impulse rail", color=color.new(C_BEAR, 78))
pLower = plot(showBands ? buyRail : na, "HPF lower impulse rail", color=color.new(C_BULL, 78))
pRegUpper = plot(showBands ? upper : na, "HPF trajectory ceiling", color=color.new(C_VIOLET, 86))
pRegLower = plot(showBands ? lower : na, "HPF trajectory floor", color=color.new(C_BLUE, 86))
fill(pFast, pSlow, color=bias == 1 ? color.new(C_BULL, 90) : bias == -1 ? color.new(C_BEAR, 90) : color.new(C_MUTED, 94), title="HPF bias cloud")
fill(pUpper, pLower, color=color.new(heatColor, 92), title="HPF impulse corridor")
fill(pRegUpper, pRegLower, color=color.new(C_VIOLET, 95), title="HPF trajectory envelope")
plot(showPhase ? phaseTrace : na, "HPF pullback phase", color=color.new(heatColor, 12), linewidth=2)
plotshape(longEvent, "HPF long impulse", shape.labelup, location.belowbar, color=color.new(C_BULL, 0), text="P+", textcolor=C_BG, size=size.tiny)
plotshape(shortEvent, "HPF short impulse", shape.labeldown, location.abovebar, color=color.new(C_BEAR, 0), text="P-", textcolor=C_TEXT, size=size.tiny)
plotshape(lowerSweep and bias == 1 and not longEvent, "HPF lower liquidity capture", shape.circle, location.belowbar, color=color.new(C_GOLD, 0), size=size.tiny)
plotshape(upperSweep and bias == -1 and not shortEvent, "HPF upper liquidity capture", shape.circle, location.abovebar, color=color.new(C_GOLD, 0), size=size.tiny)
barcolor(paintBars ? longEvent ? C_BULL : shortEvent ? C_BEAR : bias == 1 ? color.new(C_BULL, 72) : bias == -1 ? color.new(C_BEAR, 72) : na : na)

alertcondition(longEvent, "HPF Long [JOAT]", "Helios Pullback Framework long impulse")
alertcondition(shortEvent, "HPF Short [JOAT]", "Helios Pullback Framework short impulse")
````
