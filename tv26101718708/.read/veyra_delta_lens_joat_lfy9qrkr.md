# Veyra Delta Lens [JOAT]

- url: https://www.tradingview.com/script/LFy9qRkR-Veyra-Delta-Lens-JOAT/
- type: indicator
- pine_id: PUB;2791cb7f1c7240cfaaf0caa910a6c082
- version: 1.0

## Description

[b]Veyra Delta Lens [JOAT][/b]

[b]Introduction[/b]

Veyra Delta Lens estimates delta pressure from OHLCV data and converts it into auction pressure, CVD z-score, participation entropy, absorption, and pressure-shift events.

This open-source indicator is designed as a context tool, not a standalone trading system. It focuses on explaining the current market state with restrained visuals and confirmed-bar logic where signals are used.

[image]https://www.tradingview.com/x/uegune81/[/image]

[b]Core Concepts[/b]

[b]1. Signed Volume Pressure[/b]

Candle close location and body impact estimate directional volume pressure.

[b]2. CVD Normalization[/b]

Cumulative pressure is normalized so current pressure can be compared with recent history.

[b]3. Participation Entropy[/b]

Volume concentration and close location distinguish balanced absorption from directional release.

[b]4. Pressure Envelope[/b]

An auction mean and delta rails display pressure on the price chart.

[pine]
delta = signedVolume * 0.65 + impactVolume * 0.35
[/pine]

[b]Features[/b]

[list]
[*]Estimated signed volume pressure
[*]CVD z-score and impulse scoring
[*]Absorption and divergence context
[*]Auction mean and pressure rails
[*]Sparse VX+ and VX- labels
[/list]

[b]Input Parameters[/b]

[list]
[*]Delta smoothing and impulse memory
[*]CVD normalization window
[*]Participation entropy window
[*]Event score and cooldown
[*]Rails, trace, and candle toggles
[/list]


[b]How to Use This Script[/b]

Use VX+ and VX- labels as confirmed pressure shifts. Gold circles show absorption or divergence conditions aligned with the current regime.

[b]Limitations[/b]

[list]
[*]The script uses historical OHLCV data and cannot know future prices.
[*]Signals and states can be late during fast reversals because confirmed-bar logic is used to reduce repainting.
[*]Model outputs should be interpreted with market context, risk controls, and independent analysis.
[*]No visual state should be treated as a certain trade outcome.
[/list]

[b]Originality Statement[/b]

Veyra is original in combining estimated delta, CVD normalization, entropy, auction rails, absorption, and divergence in one restrained overlay.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any financial instrument. All calculations are derived from historical market data and may produce inaccurate readings in some market conditions. No indicator can predict future market behavior. Use proper risk management and independent judgment.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Veyra Delta Lens [JOAT]", shorttitle="VDL [JOAT]", overlay=true, max_labels_count=70, max_lines_count=80, max_boxes_count=10)

string gCore = "Core"
string gSignal = "Signal Engine"
string gVisual = "Visual System"
int deltaLen = input.int(8, "Delta smoothing", minval=1, maxval=50, group=gCore)
int impulseLen = input.int(21, "Impulse memory", minval=5, maxval=100, group=gCore)
int cvdLen = input.int(55, "CVD normalization", minval=20, maxval=200, group=gCore)
int entropyLen = input.int(34, "Participation entropy", minval=10, maxval=120, group=gCore)
float eventScore = input.float(74.0, "Event score", minval=55.0, maxval=95.0, step=1.0, group=gSignal)
int cooldownBars = input.int(14, "Event cooldown", minval=1, maxval=120, group=gSignal)
bool paintBars = input.bool(true, "Paint candles", group=gVisual)
bool showRails = input.bool(true, "Show delta rails", group=gVisual)
bool showTrace = input.bool(true, "Show pressure trace", group=gVisual)

color C_BULL = #00ffd5
color C_BEAR = #ff00f2
color C_GOLD = #ffb300
color C_CYAN = #00d9ff
color C_BLUE = #4f7cff
color C_VIOLET = #b14cff
color C_TEXT = #f3f8ff
color C_MUTED = #718096
color C_BG = #060812

clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

zscore(float src, int len) =>
    float basis = ta.sma(src, len)
    float dev = ta.stdev(src, len)
    dev == 0.0 ? 0.0 : (src - basis) / dev

float rng = math.max(high - low, syminfo.mintick)
float body = close - open
float closeLocation = ((close - low) - (high - close)) / rng
float signedVolume = closeLocation * nz(volume, 0)
float impactVolume = body / rng * nz(volume, 0)
float rawDelta = signedVolume * 0.65 + impactVolume * 0.35
float delta = ta.ema(rawDelta, deltaLen)
float deltaImpulse = ta.ema(delta - delta[1], 5)
float cvd = ta.cum(delta)
float cvdZ = zscore(cvd, cvdLen)
float impulseZ = zscore(delta, impulseLen)
float volumeZ = zscore(nz(volume, 0), entropyLen)
float rangeZ = zscore(rng, entropyLen)
float vwap = ta.vwap(hlc3)
float center = ta.alma(close, 34, 0.86, 6.0)
float slowCenter = ta.alma(close, 89, 0.78, 6.0)
float atr = ta.atr(14)

float participation = math.abs(delta) / math.max(ta.sma(math.abs(delta), entropyLen), 1.0)
float participationEntropy = clamp(1.0 - math.abs(closeLocation) * 0.55 + clamp(volumeZ, -2.0, 2.0) * 0.08, 0.0, 1.0)
float absorptionRatio = math.abs(delta) / math.max(nz(volume, 0), 1.0)
bool bullishAbsorption = barstate.isconfirmed and volumeZ > 1.1 and absorptionRatio < 0.18 and close > open and low < low[1]
bool bearishAbsorption = barstate.isconfirmed and volumeZ > 1.1 and absorptionRatio < 0.18 and close < open and high > high[1]
bool vacuumUp = barstate.isconfirmed and impulseZ > 1.15 and rangeZ > 0.65 and close > center and deltaImpulse > 0
bool vacuumDown = barstate.isconfirmed and impulseZ < -1.15 and rangeZ > 0.65 and close < center and deltaImpulse < 0

float priceVelocity = ta.ema(close - close[1], 6) / math.max(atr, syminfo.mintick)
float deltaVelocity = ta.ema(delta - delta[1], 6) / math.max(ta.sma(math.abs(delta), impulseLen), 1.0)
float disagreement = priceVelocity - deltaVelocity
float disagreementZ = zscore(disagreement, 55)
bool positiveDivergence = barstate.isconfirmed and disagreementZ < -1.25 and close > close[1] and cvdZ > cvdZ[1]
bool negativeDivergence = barstate.isconfirmed and disagreementZ > 1.25 and close < close[1] and cvdZ < cvdZ[1]

float bullScore = clamp((center > slowCenter ? 18 : 0) + (close > vwap ? 12 : 0) + clamp((impulseZ + 1.5) * 9, 0, 24) + clamp((cvdZ + 1.2) * 7, 0, 20) + (vacuumUp ? 14 : 0) + (bullishAbsorption ? 10 : 0) + (positiveDivergence ? 8 : 0) + clamp(participation * 4, 0, 8), 0, 100)
float bearScore = clamp((center < slowCenter ? 18 : 0) + (close < vwap ? 12 : 0) + clamp((-impulseZ + 1.5) * 9, 0, 24) + clamp((-cvdZ + 1.2) * 7, 0, 20) + (vacuumDown ? 14 : 0) + (bearishAbsorption ? 10 : 0) + (negativeDivergence ? 8 : 0) + clamp(participation * 4, 0, 8), 0, 100)

var int lastEventBar = na
bool cooled = na(lastEventBar) or bar_index - lastEventBar >= cooldownBars
bool longEvent = barstate.isconfirmed and cooled and bullScore >= eventScore and bullScore > bearScore and center > slowCenter
bool shortEvent = barstate.isconfirmed and cooled and bearScore >= eventScore and bearScore > bullScore and center < slowCenter
if longEvent or shortEvent
    lastEventBar := bar_index

int regime = bullScore > bearScore + 8 ? 1 : bearScore > bullScore + 8 ? -1 : 0
float railExpansion = atr * (0.42 + clamp(participation, 0.0, 2.5) * 0.16 + clamp(math.abs(cvdZ), 0.0, 2.0) * 0.10)
float upperRail = center + railExpansion
float lowerRail = center - railExpansion
float pressureTrace = center + clamp(impulseZ + cvdZ * 0.35, -2.5, 2.5) * atr * 0.20
float entropyTrace = slowCenter + (participationEntropy - 0.5) * atr * 0.55
color regimeColor = regime == 1 ? C_BULL : regime == -1 ? C_BEAR : C_MUTED
color railColor = longEvent ? C_BULL : shortEvent ? C_BEAR : vacuumUp ? C_CYAN : vacuumDown ? C_VIOLET : regimeColor

pCenter = plot(showRails ? center : na, "VDL execution center", color=color.new(regimeColor, 6), linewidth=2)
pSlow = plot(showRails ? slowCenter : na, "VDL auction mean", color=color.new(C_TEXT, 64), linewidth=2)
pUpper = plot(showRails ? upperRail : na, "VDL upper delta rail", color=color.new(railColor, 78))
pLower = plot(showRails ? lowerRail : na, "VDL lower delta rail", color=color.new(railColor, 78))
plot(showRails ? vwap : na, "VDL volume anchor", color=color.new(C_GOLD, 65), linewidth=1)
fill(pCenter, pSlow, color=regime == 1 ? color.new(C_BULL, 90) : regime == -1 ? color.new(C_BEAR, 90) : color.new(C_MUTED, 94), title="VDL auction bias")
fill(pUpper, pLower, color=color.new(railColor, 92), title="VDL pressure envelope")
plot(showTrace ? pressureTrace : na, "VDL pressure trace", color=color.new(railColor, 10), linewidth=2)
plot(showTrace ? entropyTrace : na, "VDL participation entropy", color=color.new(C_BLUE, 38), linewidth=1)
plotshape(longEvent, "VDL bullish pressure shift", shape.labelup, location.belowbar, color=color.new(C_BULL, 0), text="VX+", textcolor=C_BG, size=size.tiny)
plotshape(shortEvent, "VDL bearish pressure shift", shape.labeldown, location.abovebar, color=color.new(C_BEAR, 0), text="VX-", textcolor=C_TEXT, size=size.tiny)
plotshape((bullishAbsorption or positiveDivergence) and regime == 1 and not longEvent, "VDL constructive absorption", shape.circle, location.belowbar, color=color.new(C_GOLD, 0), size=size.tiny)
plotshape((bearishAbsorption or negativeDivergence) and regime == -1 and not shortEvent, "VDL destructive absorption", shape.circle, location.abovebar, color=color.new(C_GOLD, 0), size=size.tiny)
barcolor(paintBars ? longEvent ? C_BULL : shortEvent ? C_BEAR : vacuumUp ? color.new(C_CYAN, 18) : vacuumDown ? color.new(C_VIOLET, 18) : regime == 1 ? color.new(C_BULL, 76) : regime == -1 ? color.new(C_BEAR, 76) : na : na)

alertcondition(longEvent, "VDL Long [JOAT]", "Veyra Delta Lens bullish pressure shift")
alertcondition(shortEvent, "VDL Short [JOAT]", "Veyra Delta Lens bearish pressure shift")
````
