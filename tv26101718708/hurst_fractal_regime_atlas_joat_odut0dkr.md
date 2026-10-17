# Hurst Fractal Regime Atlas [JOAT]

- url: https://www.tradingview.com/script/oDuT0dKr-Hurst-Fractal-Regime-Atlas-JOAT/
- type: indicator
- pine_id: PUB;4d30b86232c244408644e227feca9b56
- version: 1.0

## Description

[b]Hurst Fractal Regime Atlas [JOAT][/b]

[b]Introduction[/b]

Hurst Fractal Regime Atlas estimates persistence and mean-reversion regimes using Hurst approximation, fractal dimension, variance ratio, phase coherence, and tension.

This open-source indicator is designed as a context tool, not a standalone trading system. It focuses on explaining the current market state with restrained visuals and confirmed-bar logic where signals are used.

[image]https://www.tradingview.com/x/UsK3jgqa/[/image]

[b]Core Concepts[/b]

[b]1. Hurst Approximation[/b]

Rescaled-range behavior estimates whether price is persistent, random-like, or mean-reverting.

[b]2. Fractal Dimension[/b]

The Hurst estimate is converted into a roughness measure using dimension logic.

[b]3. Multi-Horizon Coherence[/b]

Micro, meso, and macro Hurst readings are compared for agreement.

[b]4. Adaptive Rails[/b]

ATR, volatility cluster, and Hurst distance expand or contract the fractal field.

[pine]
fractalDimension = 2.0 - hurstBlend
[/pine]

[b]Features[/b]

[list]
[*]Hurst and fractal dimension estimates
[*]Persistence, reversion, and mixed regimes
[*]Coherence and tension scoring
[*]Adaptive fractal rails
[*]Breakout, mean, fade, and unstable events
[/list]

[b]Input Parameters[/b]

[list]
[*]Fractal and short horizon windows
[*]ATR length
[*]Persistence and mean-reversion gates
[*]Cooldown
[*]Rails, candles, and HUD toggles
[/list]


[b]How to Use This Script[/b]

Use the HUD regime first. Persistence supports continuation interpretation; reversion supports fading extremes; high tension warns of disagreement.

[b]Limitations[/b]

[list]
[*]The script uses historical OHLCV data and cannot know future prices.
[*]Signals and states can be late during fast reversals because confirmed-bar logic is used to reduce repainting.
[*]Model outputs should be interpreted with market context, risk controls, and independent analysis.
[*]No visual state should be treated as a certain trade outcome.
[/list]

[b]Originality Statement[/b]

HFA is original in combining Hurst approximation, variance ratio, coherence, tension, and adaptive rails.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any financial instrument. All calculations are derived from historical market data and may produce inaccurate readings in some market conditions. No indicator can predict future market behavior. Use proper risk management and independent judgment.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Hurst Fractal Regime Atlas [JOAT]", shorttitle="HFA [JOAT]", overlay=true, max_bars_back=1000, max_lines_count=160, max_labels_count=100, max_boxes_count=60)


string gModel = "Fractal Model"
string gSignal = "Signal Gates"
string gVisual = "Visual System"
int len = input.int(120, "Fractal window", minval=40, maxval=400, group=gModel)
int shortLen = input.int(34, "Short horizon", minval=10, maxval=120, group=gModel)
int atrLen = input.int(14, "ATR length", minval=5, maxval=100, group=gModel)
float trendGate = input.float(0.56, "Persistence gate", minval=0.50, maxval=0.80, step=0.01, group=gSignal)
float meanGate = input.float(0.44, "Mean reversion gate", minval=0.20, maxval=0.50, step=0.01, group=gSignal)
int cooldown = input.int(12, "Signal cooldown", minval=1, maxval=80, group=gSignal)
bool showRails = input.bool(true, "Show fractal rails", group=gVisual)
bool paintBars = input.bool(true, "Paint candles", group=gVisual)
bool showDashboard = input.bool(true, "Show quant HUD", group=gVisual)
string hudLoc = input.string("Top Right", "HUD position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=gVisual)

color C_BULL = #00ffd5
color C_BEAR = #ff00f2
color C_GOLD = #ffb300
color C_BLUE = #4f7cff
color C_BG = #080a12
color C_TEXT = #ffffff
color C_MUTED = #607d8b
hudPos = hudLoc == "Top Left" ? position.top_left : hudLoc == "Bottom Right" ? position.bottom_right : hudLoc == "Bottom Left" ? position.bottom_left : position.top_right

clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

safeDiv(float n, float d) =>
    d == 0.0 ? 0.0 : n / d

hurstApprox(int n) =>
    float mean = ta.sma(close, n)
    float cum = 0.0
    float maxCum = -100000000.0
    float minCum = 100000000.0
    for i = 0 to n - 1
        cum += close[i] - mean
        maxCum := math.max(maxCum, cum)
        minCum := math.min(minCum, cum)
    float rsRange = maxCum - minCum
    float st = ta.stdev(close, n)
    float rs = safeDiv(rsRange, st)
    clamp(safeDiv(math.log(math.max(rs, 1.000001)), math.log(n)), 0, 1)

float hurstLong = bar_index >= len ? hurstApprox(len) : na
float hurstShort = bar_index >= shortLen ? hurstApprox(shortLen) : na
float hBlend = ta.ema((hurstLong * 0.70 + hurstShort * 0.30), 5)
float fractalDimension = 2.0 - hBlend
float ret1 = math.log(close / close[1])
float ret5 = math.log(close / close[5])
float varianceRatio = safeDiv(ta.variance(ret5, len), 5.0 * ta.variance(ret1, len))
float atr = ta.atr(atrLen)
float volCluster = safeDiv(ta.stdev(atr, len), math.max(ta.sma(atr, len), syminfo.mintick))
float trendStrength = safeDiv(math.abs(ta.ema(close, 21) - ta.ema(close, 89)), atr)
float entropyProxy = clamp(1.0 - math.abs(hBlend - 0.5) * 2.0, 0, 1)

int regime = hBlend > trendGate and varianceRatio > 1 ? 1 : hBlend < meanGate and varianceRatio < 1 ? -1 : 0
color theme = regime == 1 ? C_BULL : regime == -1 ? C_BEAR : C_BLUE
float spine = ta.ema(close, 34)
float railWidth = atr * (1.0 + math.abs(hBlend - 0.5) * 3.0 + volCluster)
float upperRail = spine + railWidth
float lowerRail = spine - railWidth
float innerUpper = spine + railWidth * 0.382
float innerLower = spine - railWidth * 0.382

bool trendLongRaw = barstate.isconfirmed and regime == 1 and close > upperRail[1] and trendStrength > 0.55
bool trendShortRaw = barstate.isconfirmed and regime == 1 and close < lowerRail[1] and trendStrength > 0.55
bool meanLongRaw = barstate.isconfirmed and regime == -1 and low < lowerRail and close > innerLower
bool meanShortRaw = barstate.isconfirmed and regime == -1 and high > upperRail and close < innerUpper

var int lastSignal = na
bool cooled = na(lastSignal) or bar_index - lastSignal >= cooldown
bool longSignal = cooled and (trendLongRaw or meanLongRaw)
bool shortSignal = cooled and (trendShortRaw or meanShortRaw)
if longSignal or shortSignal
    lastSignal := bar_index

pUpper = plot(showRails ? upperRail : na, "HFA upper fractal rail", color=color.new(theme, 65))
pLower = plot(showRails ? lowerRail : na, "HFA lower fractal rail", color=color.new(theme, 65))
pInnerU = plot(showRails ? innerUpper : na, "HFA inner upper", color=color.new(theme, 82))
pInnerL = plot(showRails ? innerLower : na, "HFA inner lower", color=color.new(theme, 82))
plot(showRails ? spine : na, "HFA horizon spine", color=color.new(theme, 5), linewidth=2)
fill(pUpper, pLower, color=color.new(theme, 92), title="HFA fractal field")
fill(pInnerU, pInnerL, color=color.new(theme, 88), title="HFA equilibrium band")
plotshape(longSignal and regime == 1, "HFA long persistence event", shape.labelup, location.belowbar, color=color.new(C_BULL, 8), text="Persist", textcolor=C_BG, size=size.tiny)
plotshape(longSignal and regime == -1, "HFA long reversion event", shape.labelup, location.belowbar, color=color.new(C_BULL, 8), text="Revert", textcolor=C_BG, size=size.tiny)
plotshape(shortSignal and regime == 1, "HFA short persistence event", shape.labeldown, location.abovebar, color=color.new(C_BEAR, 8), text="Persist", textcolor=C_TEXT, size=size.tiny)
plotshape(shortSignal and regime == -1, "HFA short reversion event", shape.labeldown, location.abovebar, color=color.new(C_BEAR, 8), text="Revert", textcolor=C_TEXT, size=size.tiny)
barcolor(paintBars ? regime == 1 ? color.new(C_BULL, 72) : regime == -1 ? color.new(C_BEAR, 72) : color.new(C_BLUE, 82) : na)

alertcondition(longSignal, "HFA Long Event [JOAT]", "Hurst Fractal Regime Atlas long event")
alertcondition(shortSignal, "HFA Short Event [JOAT]", "Hurst Fractal Regime Atlas short event")


float hSlope = hBlend - hBlend[5]
float hAccel = hSlope - hSlope[5]
float hMicro = bar_index >= shortLen ? hurstApprox(shortLen) : na
float hMeso = bar_index >= 72 ? hurstApprox(72) : na
float hMacro = bar_index >= len ? hurstApprox(len) : na
float multiFractalSpread = math.max(math.max(hMicro, hMeso), hMacro) - math.min(math.min(hMicro, hMeso), hMacro)
float hStack = (hMicro > 0.5 ? 1 : -1) + (hMeso > 0.5 ? 1 : -1) + (hMacro > 0.5 ? 1 : -1)
float clusterRank = safeDiv(volCluster - ta.lowest(volCluster, len), math.max(ta.highest(volCluster, len) - ta.lowest(volCluster, len), 0.000001))
float phaseCoherence = clamp(100 - multiFractalSpread * 180 + math.abs(hStack) * 10, 0, 100)
float fractalTension = clamp(multiFractalSpread * 240 + clusterRank * 35 + entropyProxy * 20, 0, 100)
float cyclePressure = safeDiv(ta.ema(close - spine, 8), math.max(railWidth, syminfo.mintick))
float cycleScore = clamp(50 + cyclePressure * 45 + hStack * 8 - fractalTension * 0.20, 0, 100)
float roughness = clamp(fractalDimension - 1.0, 0, 1)
float persistencePower = clamp((hBlend - 0.50) / math.max(trendGate - 0.50, 0.01), 0, 2)
float reversionPower = clamp((0.50 - hBlend) / math.max(0.50 - meanGate, 0.01), 0, 2)
float phaseStability = clamp(100 - entropyProxy * 40 - clusterRank * 25 + math.abs(hBlend - 0.5) * 70, 0, 100)
float breakoutPermission = clamp(persistencePower * 35 + trendStrength * 24 + (varianceRatio > 1 ? 18 : 0) + (hSlope > 0 ? 10 : 0), 0, 100)
float reversionPermission = clamp(reversionPower * 35 + (varianceRatio < 1 ? 20 : 0) + (clusterRank < 0.55 ? 16 : 0) + (hSlope < 0 ? 10 : 0), 0, 100)
float atlasGrade = clamp(math.max(breakoutPermission, reversionPermission) * 0.55 + phaseStability * 0.30 + (100 - clusterRank * 100) * 0.15, 0, 100)
bool breakoutTier = barstate.isconfirmed and breakoutPermission >= 72 and phaseStability >= 55
bool reversionTier = barstate.isconfirmed and reversionPermission >= 72 and clusterRank < 0.70
bool unstableTier = barstate.isconfirmed and (phaseStability < 35 or clusterRank > 0.82)
bool breakoutTierEvent = breakoutTier and not breakoutTier[1]
bool reversionTierEvent = reversionTier and not reversionTier[1]
bool unstableTierEvent = unstableTier and not unstableTier[1]
bool coherenceBreakout = barstate.isconfirmed and phaseCoherence > 68 and hStack == 3 and cycleScore > 62
bool coherenceFade = barstate.isconfirmed and phaseCoherence > 58 and hStack <= -1 and (cycleScore < 35 or cycleScore > 65)
bool tensionWarning = barstate.isconfirmed and fractalTension > 72
bool coherenceBreakoutEvent = coherenceBreakout and not coherenceBreakout[1]
bool coherenceFadeEvent = coherenceFade and not coherenceFade[1]
bool tensionWarningEvent = tensionWarning and not tensionWarning[1]

plot(showRails ? spine + atr * persistencePower : na, "HFA persistence pressure rail", color=color.new(C_BULL, 76))
plot(showRails ? spine - atr * reversionPower : na, "HFA reversion pressure rail", color=color.new(C_BEAR, 76))
plot(showRails ? spine + railWidth * cyclePressure : na, "HFA cycle pressure trace", color=color.new(C_GOLD, 35), linewidth=2)
plot(atlasGrade, "HFA atlas grade hidden", color=color.new(theme, 100), display=display.none)
plot(phaseCoherence, "HFA phase coherence hidden", color=color.new(C_BLUE, 100), display=display.none)
plot(fractalTension, "HFA fractal tension hidden", color=color.new(C_BEAR, 100), display=display.none)
plotshape(breakoutTierEvent, "HFA breakout tier", shape.labelup, location.belowbar, color=color.new(C_BULL, 6), text="Breakout", textcolor=C_BG, size=size.tiny)
plotshape(reversionTierEvent, "HFA reversion tier", shape.labelup, location.belowbar, color=color.new(C_GOLD, 8), text="Mean", textcolor=C_BG, size=size.tiny)
plotshape(unstableTierEvent, "HFA unstable tier", shape.labeldown, location.abovebar, color=color.new(C_BEAR, 6), text="Unstable", textcolor=C_TEXT, size=size.tiny)
plotshape(coherenceBreakoutEvent, "HFA coherent persistence", shape.labelup, location.belowbar, color=color.new(C_BLUE, 5), text="Coherent", textcolor=C_TEXT, size=size.tiny)
plotshape(coherenceFadeEvent, "HFA coherent fade", shape.labeldown, location.abovebar, color=color.new(C_GOLD, 5), text="Fade", textcolor=C_BG, size=size.tiny)
plotshape(tensionWarningEvent, "HFA fractal tension", shape.circle, location.abovebar, color=color.new(C_BEAR, 5), size=size.tiny)

var table hud = na
if showDashboard and barstate.islast
    if na(hud)
        hud := table.new(hudPos, 2, 8, bgcolor=color.new(C_BG, 8), border_color=color.new(C_TEXT, 82), border_width=1, frame_color=color.new(theme, 65), frame_width=1)
    table.cell(hud, 0, 0, "HURST", text_color=C_TEXT, bgcolor=color.new(theme, 68), text_size=size.small)
    table.cell(hud, 1, 0, "HFA", text_color=C_TEXT, bgcolor=color.new(theme, 68), text_size=size.small)
    table.cell(hud, 0, 1, "Regime", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 1, regime == 1 ? "Persistence" : regime == -1 ? "Reversion" : "Mixed", text_color=regime == 1 ? C_BULL : regime == -1 ? C_BEAR : C_BLUE, text_size=size.small)
    table.cell(hud, 0, 2, "H Blend", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 2, str.tostring(hBlend, "#.000"), text_color=theme, text_size=size.small)
    table.cell(hud, 0, 3, "Dimension", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 3, str.tostring(fractalDimension, "#.000"), text_color=fractalDimension <= 1.45 ? C_BULL : fractalDimension >= 1.58 ? C_BEAR : C_GOLD, text_size=size.small)
    table.cell(hud, 0, 4, "Coherence", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 4, str.tostring(phaseCoherence, "#.0"), text_color=phaseCoherence >= 65 ? C_BULL : phaseCoherence <= 40 ? C_BEAR : C_BLUE, text_size=size.small)
    table.cell(hud, 0, 5, "Tension", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 5, str.tostring(fractalTension, "#.0"), text_color=fractalTension <= 40 ? C_BULL : fractalTension >= 70 ? C_BEAR : C_GOLD, text_size=size.small)
    table.cell(hud, 0, 6, "Atlas", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 6, str.tostring(atlasGrade, "#.0"), text_color=atlasGrade >= 65 ? C_BULL : atlasGrade <= 40 ? C_BEAR : C_GOLD, text_size=size.small)
    table.cell(hud, 0, 7, "Cycle", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 7, str.tostring(cycleScore, "#.0"), text_color=cycleScore >= 60 ? C_BULL : cycleScore <= 40 ? C_BEAR : C_MUTED, text_size=size.small)

alertcondition(breakoutTierEvent, "HFA Breakout Tier [JOAT]", "Hurst Fractal Regime Atlas breakout tier")
alertcondition(reversionTierEvent, "HFA Mean Reversion Tier [JOAT]", "Hurst Fractal Regime Atlas mean reversion tier")
alertcondition(unstableTierEvent, "HFA Unstable Tier [JOAT]", "Hurst Fractal Regime Atlas unstable regime")
alertcondition(coherenceBreakoutEvent, "HFA Coherent Persistence [JOAT]", "Hurst Fractal Regime Atlas coherent persistence")
alertcondition(coherenceFadeEvent, "HFA Coherent Fade [JOAT]", "Hurst Fractal Regime Atlas coherent fade")
alertcondition(tensionWarningEvent, "HFA Fractal Tension [JOAT]", "Hurst Fractal Regime Atlas fractal tension")
````
