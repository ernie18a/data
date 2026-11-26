# Gatev Relative Value Arbiter [JOAT]

- url: https://www.tradingview.com/script/oRTxtDNt-Gatev-Relative-Value-Arbiter-JOAT/
- type: indicator
- pine_id: PUB;905060f672f442279c72d49800fb3753
- version: 1.0

## Description

[b]Gatev Relative Value Arbiter [JOAT][/b]

[b]Introduction[/b]

Gatev Relative Value Arbiter studies relative value between the chart symbol and a selected peer using beta spread, z-score, stationarity, Kalman residuals, and OU speed.

This open-source indicator is designed as a context tool, not a standalone trading system. It focuses on explaining the current market state with restrained visuals and confirmed-bar logic where signals are used.

[image]https://www.tradingview.com/x/CwzXOsJB/[/image]

[b]Core Concepts[/b]

[b]1. Rolling Beta Spread[/b]

The chart log price is modeled against the peer log price with rolling beta and alpha.

[b]2. Spread Z-Score[/b]

Residual spread is normalized to identify cheap and rich dislocations.

[b]3. Kalman Residual[/b]

A recursive residual estimate adapts to changing pair behavior.

[b]4. Stationarity and OU Speed[/b]

Correlation, beta drift, skew, kurtosis, and OU-style speed grade pair quality.

[pine]
spread = logChart - (alpha + beta * logPeer)
[/pine]

[b]Features[/b]

[list]
[*]Peer relative-value model
[*]Rolling beta and spread z-score
[*]Kalman residual z-score
[*]Stationarity and cointegration energy proxies
[*]Cheap, rich, prime, broken, and fair-value states
[/list]

[b]Input Parameters[/b]

[list]
[*]Peer symbol
[*]Rolling beta and z-score lengths
[*]Entry and exit z thresholds
[*]Minimum correlation
[*]Cooldown and display toggles
[/list]


[b]How to Use This Script[/b]

Choose a logically related peer. Cheap and rich states are most meaningful when pair validity and stationarity remain acceptable.

[b]Limitations[/b]

[list]
[*]The script uses historical OHLCV data and cannot know future prices.
[*]Signals and states can be late during fast reversals because confirmed-bar logic is used to reduce repainting.
[*]Model outputs should be interpreted with market context, risk controls, and independent analysis.
[*]No visual state should be treated as a certain trade outcome.
[/list]

[b]Originality Statement[/b]

GRA is original in combining rolling beta arbitrage logic, Kalman residuals, OU speed, and stationarity grading.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any financial instrument. All calculations are derived from historical market data and may produce inaccurate readings in some market conditions. No indicator can predict future market behavior. Use proper risk management and independent judgment.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Gatev Relative Value Arbiter [JOAT]", shorttitle="GRA [JOAT]", overlay=false, max_bars_back=1200, max_lines_count=160, max_labels_count=100)


string gPair = "Pair"
string gModel = "Model"
string gSignal = "Signal Gates"
string gVisual = "Visual System"
string peer = input.symbol("SPY", "Peer symbol", group=gPair)
int betaLen = input.int(120, "Rolling beta length", minval=30, maxval=500, group=gModel)
int zLen = input.int(80, "Spread z-score length", minval=20, maxval=300, group=gModel)
float entryZ = input.float(2.0, "Dislocation z", minval=0.5, maxval=5, step=0.1, group=gSignal)
float exitZ = input.float(0.35, "Reversion z", minval=0.05, maxval=2, step=0.05, group=gSignal)
float minCorr = input.float(0.55, "Minimum pair correlation", minval=0, maxval=0.99, step=0.01, group=gSignal)
int cooldown = input.int(10, "Signal cooldown", minval=1, maxval=100, group=gSignal)
bool paintBars = input.bool(true, "Paint bars", group=gVisual)
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

float peerClose = request.security(peer, timeframe.period, close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
float x = math.log(math.max(close, syminfo.mintick))
float y = math.log(math.max(peerClose, syminfo.mintick))
float rx = x - x[1]
float ry = y - y[1]
float corr = ta.correlation(rx, ry, betaLen)
float beta = safeDiv(ta.correlation(rx, ry, betaLen) * ta.stdev(rx, betaLen), ta.stdev(ry, betaLen))
float alpha = ta.sma(x, betaLen) - beta * ta.sma(y, betaLen)
float spread = x - (alpha + beta * y)
float spreadMean = ta.sma(spread, zLen)
float spreadDev = ta.stdev(spread, zLen)
float z = safeDiv(spread - spreadMean, spreadDev)
float distance = math.abs(z)
float distanceSmooth = ta.ema(distance, 5)
float spreadVelocity = z - z[1]
float halfLifeProxy = safeDiv(math.log(2.0), math.max(math.abs(ta.correlation(spread, spread[1], zLen)), 0.01))
float quality = clamp(50 + corr * 35 - math.abs(beta - 1.0) * 10 - math.min(halfLifeProxy, 20) * 0.6, 0, 100)

bool pairValid = corr >= minCorr and spreadDev > 0
bool chartRich = pairValid and z >= entryZ
bool chartCheap = pairValid and z <= -entryZ
bool reverting = pairValid and math.abs(z) <= exitZ
var int lastSignal = na
bool cooled = na(lastSignal) or bar_index - lastSignal >= cooldown
bool shortChartEvent = barstate.isconfirmed and cooled and chartRich and spreadVelocity < 0
bool longChartEvent = barstate.isconfirmed and cooled and chartCheap and spreadVelocity > 0
bool neutralEvent = barstate.isconfirmed and reverting and not reverting[1]
if shortChartEvent or longChartEvent
    lastSignal := bar_index

color theme = chartCheap ? C_BULL : chartRich ? C_BEAR : pairValid ? C_BLUE : C_MUTED
plot(z, "GRA spread z-score", color=color.new(theme, 5), linewidth=2)
plot(ta.ema(z, 8), "GRA smoothed spread", color=color.new(C_TEXT, 50))
hline(entryZ, "GRA rich threshold", color=color.new(C_BEAR, 65))
hline(-entryZ, "GRA cheap threshold", color=color.new(C_BULL, 65))
hline(0, "GRA fair value", color=color.new(C_MUTED, 65))
plot(corr * 3, "GRA pair correlation scaled", color=color.new(C_GOLD, 30), style=plot.style_area)
plot(distanceSmooth, "GRA dislocation energy", color=color.new(theme, 45), style=plot.style_columns)
plotshape(longChartEvent, "GRA long chart leg", shape.labelup, location.bottom, color=color.new(C_BULL, 8), text="Cheap", textcolor=C_BG, size=size.tiny)
plotshape(shortChartEvent, "GRA short chart leg", shape.labeldown, location.top, color=color.new(C_BEAR, 8), text="Rich", textcolor=C_TEXT, size=size.tiny)
plotshape(neutralEvent, "GRA fair value reset", shape.circle, location.bottom, color=color.new(C_GOLD, 10), size=size.tiny)
barcolor(paintBars ? chartCheap ? color.new(C_BULL, 72) : chartRich ? color.new(C_BEAR, 72) : pairValid ? color.new(C_BLUE, 85) : na : na)

alertcondition(longChartEvent, "GRA Chart Cheap [JOAT]", "Gatev Relative Value Arbiter chart leg cheap versus peer")
alertcondition(shortChartEvent, "GRA Chart Rich [JOAT]", "Gatev Relative Value Arbiter chart leg rich versus peer")


float betaDrift = math.abs(beta - beta[20])
float corrDrift = corr - corr[20]
var float kSpread = na
var float kVar = 1.0
float processNoise = 0.012 + math.abs(spreadVelocity) * 0.02
float measurementNoise = math.max(spreadDev * spreadDev, 0.000001)
float kPred = nz(kSpread, spread)
float kPredVar = kVar + processNoise
float kGain = safeDiv(kPredVar, kPredVar + measurementNoise)
kSpread := kPred + kGain * (spread - kPred)
kVar := (1.0 - kGain) * kPredVar
float kResidual = spread - kSpread
float kZ = safeDiv(kResidual, math.sqrt(math.max(kVar, 0.000001)))
float ouSlope = ta.linreg(spread - spread[1], zLen, 0)
float ouLevel = ta.linreg(spread, zLen, 0)
float ouSpeed = clamp(-safeDiv(ouSlope, math.max(math.abs(ouLevel), 0.000001)) * 100, -100, 100)
float spreadSkew = safeDiv(ta.sma(math.pow(spread - spreadMean, 3), zLen), math.pow(spreadDev, 3))
float spreadKurt = safeDiv(ta.sma(math.pow(spread - spreadMean, 4), zLen), math.pow(spreadDev, 4))
float stationarityProxy = clamp(100 - math.abs(betaDrift) * 45 - math.max(0, -corrDrift) * 55 - math.abs(spreadSkew) * 6 - math.max(spreadKurt - 3, 0) * 4, 0, 100)
float reversionVelocity = -spreadVelocity * math.sign(z)
float reversionPressure = clamp(reversionVelocity * 35 + (distance - entryZ) * 18 + stationarityProxy * 0.35 + math.max(ouSpeed, 0) * 0.12, 0, 100)
float breakdownPressure = clamp((minCorr - corr) * 120 + betaDrift * 30 + math.max(spreadKurt - 5, 0) * 8, 0, 100)
float carryProxy = ta.ema(rx - beta * ry, 20) * 252
float cointegrationEnergy = clamp(stationarityProxy * 0.35 + corr * 35 + math.max(ouSpeed, 0) * 0.25 + (100 - math.abs(kZ) * 8) * 0.20, 0, 100)
float arbGrade = clamp(quality * 0.30 + stationarityProxy * 0.25 + reversionPressure * 0.18 + cointegrationEnergy * 0.22 - breakdownPressure * 0.25, 0, 100)
bool arbPrime = barstate.isconfirmed and arbGrade >= 72 and pairValid and distance >= entryZ
bool arbBroken = barstate.isconfirmed and (breakdownPressure >= 65 or corr < minCorr * 0.75)
bool arbPrimeEvent = arbPrime and not arbPrime[1]
bool arbBrokenEvent = arbBroken and not arbBroken[1]
bool fairValueEvent = neutralEvent and arbGrade > 45
bool kalmanCheap = barstate.isconfirmed and pairValid and kZ < -entryZ and reversionPressure > 58
bool kalmanRich = barstate.isconfirmed and pairValid and kZ > entryZ and reversionPressure > 58
bool kalmanCheapEvent = kalmanCheap and not kalmanCheap[1]
bool kalmanRichEvent = kalmanRich and not kalmanRich[1]

plot(stationarityProxy, "GRA stationarity proxy", color=color.new(C_BLUE, 20), linewidth=2)
plot(reversionPressure, "GRA reversion pressure", color=color.new(C_BULL, 30), style=plot.style_area)
plot(breakdownPressure, "GRA breakdown pressure", color=color.new(C_BEAR, 45), style=plot.style_columns)
plot(arbGrade, "GRA arb grade", color=color.new(theme, 10), linewidth=2)
plot(carryProxy * 10 + 50, "GRA residual carry scaled", color=color.new(C_GOLD, 45))
plot(kZ, "GRA Kalman residual z", color=color.new(kZ >= 0 ? C_BEAR : C_BULL, 12), linewidth=2)
plot(cointegrationEnergy, "GRA cointegration energy", color=color.new(C_BLUE, 25), style=plot.style_area)
plot(ouSpeed + 50, "GRA OU speed scaled", color=color.new(C_TEXT, 55))
plotshape(arbPrimeEvent, "GRA prime dislocation", shape.labelup, location.bottom, color=color.new(C_BULL, 6), text="Prime", textcolor=C_BG, size=size.tiny)
plotshape(arbBrokenEvent, "GRA pair breakdown", shape.labeldown, location.top, color=color.new(C_BEAR, 6), text="Broken", textcolor=C_TEXT, size=size.tiny)
plotshape(fairValueEvent, "GRA fair value recovery", shape.circle, location.bottom, color=color.new(C_GOLD, 5), size=size.small)
plotshape(kalmanCheapEvent, "GRA Kalman cheap", shape.labelup, location.bottom, color=color.new(C_BLUE, 5), text="K Cheap", textcolor=C_TEXT, size=size.tiny)
plotshape(kalmanRichEvent, "GRA Kalman rich", shape.labeldown, location.top, color=color.new(C_BLUE, 5), text="K Rich", textcolor=C_TEXT, size=size.tiny)

var table hud = na
if showDashboard and barstate.islast
    if na(hud)
        hud := table.new(hudPos, 2, 8, bgcolor=color.new(C_BG, 8), border_color=color.new(C_TEXT, 82), border_width=1, frame_color=color.new(theme, 65), frame_width=1)
    table.cell(hud, 0, 0, "GATEV", text_color=C_TEXT, bgcolor=color.new(theme, 68), text_size=size.small)
    table.cell(hud, 1, 0, "GRA", text_color=C_TEXT, bgcolor=color.new(theme, 68), text_size=size.small)
    table.cell(hud, 0, 1, "Pair", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 1, pairValid ? "Valid" : "Broken", text_color=pairValid ? C_BULL : C_BEAR, text_size=size.small)
    table.cell(hud, 0, 2, "Spread Z", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 2, str.tostring(z, "#.00"), text_color=z <= -entryZ ? C_BULL : z >= entryZ ? C_BEAR : C_BLUE, text_size=size.small)
    table.cell(hud, 0, 3, "Kalman Z", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 3, str.tostring(kZ, "#.00"), text_color=kZ <= -entryZ ? C_BULL : kZ >= entryZ ? C_BEAR : C_GOLD, text_size=size.small)
    table.cell(hud, 0, 4, "Corr", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 4, str.tostring(corr, "#.00"), text_color=corr >= minCorr ? C_BULL : C_BEAR, text_size=size.small)
    table.cell(hud, 0, 5, "OU Speed", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 5, str.tostring(ouSpeed, "#.0"), text_color=ouSpeed > 0 ? C_BULL : C_BEAR, text_size=size.small)
    table.cell(hud, 0, 6, "Arb Grade", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 6, str.tostring(arbGrade, "#.0"), text_color=arbGrade >= 65 ? C_BULL : arbGrade <= 40 ? C_BEAR : C_GOLD, text_size=size.small)
    table.cell(hud, 0, 7, "State", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 7, arbPrime ? "Prime" : arbBroken ? "Broken" : reverting ? "Mean" : chartCheap ? "Cheap" : chartRich ? "Rich" : "Watch", text_color=arbPrime or chartCheap ? C_BULL : arbBroken or chartRich ? C_BEAR : C_GOLD, text_size=size.small)

alertcondition(arbPrimeEvent, "GRA Prime Dislocation [JOAT]", "Gatev Relative Value Arbiter prime relative-value dislocation")
alertcondition(arbBrokenEvent, "GRA Pair Breakdown [JOAT]", "Gatev Relative Value Arbiter pair breakdown warning")
alertcondition(fairValueEvent, "GRA Fair Value Recovery [JOAT]", "Gatev Relative Value Arbiter fair-value recovery")
alertcondition(kalmanCheapEvent, "GRA Kalman Cheap [JOAT]", "Gatev Relative Value Arbiter Kalman cheap dislocation")
alertcondition(kalmanRichEvent, "GRA Kalman Rich [JOAT]", "Gatev Relative Value Arbiter Kalman rich dislocation")
````
