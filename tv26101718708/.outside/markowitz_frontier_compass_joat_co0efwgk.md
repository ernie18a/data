# Markowitz Frontier Compass [JOAT]

- url: https://www.tradingview.com/script/co0eFwGK-Markowitz-Frontier-Compass-JOAT/
- type: indicator
- pine_id: PUB;b5647a93978c40c2869c09f2000a9446
- version: 1.0

## Description

[b]Markowitz Frontier Compass [JOAT][/b]

[b]Introduction[/b]

Markowitz Frontier Compass compares the chart symbol against a peer basket using inverse-volatility weights, correlation drag, diversification benefit, factor scores, and active risk budget.

This open-source indicator is designed as a context tool, not a standalone trading system. It focuses on explaining the current market state with restrained visuals and confirmed-bar logic where signals are used.

[image]https://www.tradingview.com/x/H93WMHDB/[/image]

[b]Core Concepts[/b]

[b]1. Inverse-Volatility Basket[/b]

Each peer receives an inverse-volatility weight to form a portfolio-context benchmark.

[b]2. Correlation Drag[/b]

Average pairwise correlation reduces diversification value when assets move together.

[b]3. Factor Composite[/b]

Quality, momentum, low-volatility, and carry-style behavior are combined.

[b]4. Risk Budget[/b]

Institutional grade, entropy, concentration, and factor state become active or defensive budget context.

[pine]
frontierScore = efficiency + diversification - correlationDrag - concentration
[/pine]

[b]Features[/b]

[list]
[*]Peer basket context
[*]Inverse-volatility weighting
[*]Correlation drag and diversification benefit
[*]Factor composite and allocation entropy
[*]Risk-on, defense, and factor-prime states
[/list]

[b]Input Parameters[/b]

[list]
[*]Peer symbols
[*]Return window and smoothing
[*]Risk-free annual percent
[*]Correlation stress and concentration gates
[*]Display toggles and HUD position
[/list]


[b]How to Use This Script[/b]

Use MFC as cross-asset context. Risk-on or factor-prime states suggest constructive basket behavior; defense states warn of stress.

[b]Limitations[/b]

[list]
[*]The script uses historical OHLCV data and cannot know future prices.
[*]Signals and states can be late during fast reversals because confirmed-bar logic is used to reduce repainting.
[*]Model outputs should be interpreted with market context, risk controls, and independent analysis.
[*]No visual state should be treated as a certain trade outcome.
[/list]

[b]Originality Statement[/b]

MFC is original in combining portfolio theory, factor scoring, entropy, and risk-budget logic in one open-source study.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any financial instrument. All calculations are derived from historical market data and may produce inaccurate readings in some market conditions. No indicator can predict future market behavior. Use proper risk management and independent judgment.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Markowitz Frontier Compass [JOAT]", shorttitle="MFC [JOAT]", overlay=false, max_bars_back=900, max_lines_count=120, max_labels_count=80)


string gUniverse = "Universe"
string gModel = "Model"
string gRisk = "Risk Gates"
string gVisual = "Visual System"
string peer1 = input.symbol("SPY", "Peer 1", group=gUniverse)
string peer2 = input.symbol("QQQ", "Peer 2", group=gUniverse)
string peer3 = input.symbol("TLT", "Peer 3", group=gUniverse)
string peer4 = input.symbol("GLD", "Peer 4", group=gUniverse)
bool usePeers = input.bool(true, "Use peer basket", group=gUniverse)
int retLen = input.int(63, "Return window", minval=20, maxval=260, group=gModel)
int smoothLen = input.int(8, "Signal smoothing", minval=1, maxval=50, group=gModel)
float riskFreeAnnual = input.float(4.5, "Risk-free annual percent", minval=0, maxval=20, step=0.1, group=gModel)
float corrStress = input.float(0.72, "Correlation stress", minval=0.20, maxval=0.98, step=0.01, group=gRisk)
float minEfficiency = input.float(0.20, "Efficiency gate", minval=-2, maxval=3, step=0.05, group=gRisk)
float maxRiskShare = input.float(0.45, "Concentration warning", minval=0.10, maxval=0.95, step=0.05, group=gRisk)
bool paintBars = input.bool(true, "Paint chart bars", group=gVisual)
bool showFrontier = input.bool(true, "Show frontier band", group=gVisual)
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

logRet(float src) =>
    math.log(math.max(src, syminfo.mintick) / math.max(src[1], syminfo.mintick))

annualizeVol(float dailyVol) =>
    dailyVol * math.sqrt(252.0)

annualizeRet(float dailyRet) =>
    dailyRet * 252.0

weightFromVol(float vol, float invSum) =>
    safeDiv(safeDiv(1.0, math.max(vol, 0.000001)), invSum)

formatPct(float x) =>
    str.tostring(x * 100.0, "#.##") + "%"

float c0 = close
float c1 = usePeers ? request.security(peer1, timeframe.period, close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off) : close
float c2 = usePeers ? request.security(peer2, timeframe.period, close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off) : close
float c3 = usePeers ? request.security(peer3, timeframe.period, close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off) : close
float c4 = usePeers ? request.security(peer4, timeframe.period, close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off) : close

float r0 = logRet(c0)
float r1 = logRet(c1)
float r2 = logRet(c2)
float r3 = logRet(c3)
float r4 = logRet(c4)

float mu0 = ta.sma(r0, retLen)
float mu1 = ta.sma(r1, retLen)
float mu2 = ta.sma(r2, retLen)
float mu3 = ta.sma(r3, retLen)
float mu4 = ta.sma(r4, retLen)

float v0 = ta.stdev(r0, retLen)
float v1 = ta.stdev(r1, retLen)
float v2 = ta.stdev(r2, retLen)
float v3 = ta.stdev(r3, retLen)
float v4 = ta.stdev(r4, retLen)

float invSum = safeDiv(1, v0) + safeDiv(1, v1) + safeDiv(1, v2) + safeDiv(1, v3) + safeDiv(1, v4)
float w0 = weightFromVol(v0, invSum)
float w1 = weightFromVol(v1, invSum)
float w2 = weightFromVol(v2, invSum)
float w3 = weightFromVol(v3, invSum)
float w4 = weightFromVol(v4, invSum)

float pr = w0 * r0 + w1 * r1 + w2 * r2 + w3 * r3 + w4 * r4
float pmu = w0 * mu0 + w1 * mu1 + w2 * mu2 + w3 * mu3 + w4 * mu4
float pvolReal = ta.stdev(pr, retLen)
float weightedStandaloneVol = w0 * v0 + w1 * v1 + w2 * v2 + w3 * v3 + w4 * v4

float corr01 = ta.correlation(r0, r1, retLen)
float corr02 = ta.correlation(r0, r2, retLen)
float corr03 = ta.correlation(r0, r3, retLen)
float corr04 = ta.correlation(r0, r4, retLen)
float corr12 = ta.correlation(r1, r2, retLen)
float corr13 = ta.correlation(r1, r3, retLen)
float corr14 = ta.correlation(r1, r4, retLen)
float corr23 = ta.correlation(r2, r3, retLen)
float corr24 = ta.correlation(r2, r4, retLen)
float corr34 = ta.correlation(r3, r4, retLen)
float avgCorr = (corr01 + corr02 + corr03 + corr04 + corr12 + corr13 + corr14 + corr23 + corr24 + corr34) / 10.0
float corrClean = na(avgCorr) ? 0.0 : avgCorr

float annReturn = annualizeRet(pmu)
float annVol = annualizeVol(pvolReal)
float rfDaily = riskFreeAnnual / 100.0 / 252.0
float excessAnnual = annualizeRet(pmu - rfDaily)
float sharpeProxy = safeDiv(excessAnnual, annVol)
float divBenefit = safeDiv(weightedStandaloneVol - pvolReal, weightedStandaloneVol)
float corrDrag = clamp((corrClean - 0.15) / math.max(corrStress - 0.15, 0.01), 0, 1)
float concentration = math.max(math.max(w0, w1), math.max(math.max(w2, w3), w4))
float concentrationPenalty = clamp((concentration - 0.20) / math.max(maxRiskShare - 0.20, 0.01), 0, 1)
float efficiencyRaw = sharpeProxy + divBenefit * 1.25 - corrDrag * 0.75 - concentrationPenalty * 0.65
float efficiency = ta.ema(efficiencyRaw, smoothLen)
float frontierScore = clamp(50 + efficiency * 22 + divBenefit * 20 - corrDrag * 18, 0, 100)

bool riskOn = barstate.isconfirmed and efficiency >= minEfficiency and corrClean < corrStress and concentration <= maxRiskShare
bool riskOff = barstate.isconfirmed and (efficiency < minEfficiency or corrClean >= corrStress or concentration > maxRiskShare)
bool newRiskOn = riskOn and not riskOn[1]
bool newRiskOff = riskOff and not riskOff[1]

float frontierMid = ta.ema(frontierScore, smoothLen)
float frontierUpper = frontierMid + clamp(divBenefit * 35, 5, 30)
float frontierLower = frontierMid - clamp(corrDrag * 35 + concentrationPenalty * 20, 5, 35)
color theme = frontierScore >= 60 ? C_BULL : frontierScore <= 40 ? C_BEAR : C_BLUE

plot(showFrontier ? frontierUpper : na, "MFC efficient upper rail", color=color.new(theme, 65))
plot(showFrontier ? frontierLower : na, "MFC efficient lower rail", color=color.new(theme, 65))
pMid = plot(frontierMid, "MFC frontier score", color=color.new(theme, 5), linewidth=2)
hline(70, "MFC institutional efficiency", color=color.new(C_BULL, 70))
hline(50, "MFC neutral", color=color.new(C_MUTED, 70))
hline(30, "MFC risk compression", color=color.new(C_BEAR, 70))
plot(efficiency * 20 + 50, "MFC efficiency oscillator", color=color.new(C_TEXT, 35))
plot(corrDrag * 100, "MFC correlation drag", color=color.new(C_BEAR, 45), style=plot.style_columns)
plot(divBenefit * 100, "MFC diversification benefit", color=color.new(C_BULL, 45), style=plot.style_area)
plotshape(newRiskOn, "MFC risk-on transition", shape.labelup, location.bottom, color=color.new(C_BULL, 8), text="Risk On", textcolor=C_BG, size=size.tiny)
plotshape(newRiskOff, "MFC risk-off transition", shape.labeldown, location.top, color=color.new(C_BEAR, 8), text="Risk Off", textcolor=C_TEXT, size=size.tiny)
barcolor(paintBars ? riskOn ? color.new(C_BULL, 72) : riskOff ? color.new(C_BEAR, 72) : na : na)

alertcondition(newRiskOn, "MFC Risk On [JOAT]", "Markowitz Frontier Compass risk-on transition")
alertcondition(newRiskOff, "MFC Risk Off [JOAT]", "Markowitz Frontier Compass risk-off transition")


float chartMomentum = ta.ema(r0, 8) * 252.0
float peerMomentum = (ta.ema(r1, 8) + ta.ema(r2, 8) + ta.ema(r3, 8) + ta.ema(r4, 8)) * 63.0
float momentumSpread = chartMomentum - peerMomentum
float marginalVol0 = safeDiv(w0 * v0, pvolReal)
float marginalVol1 = safeDiv(w1 * v1, pvolReal)
float marginalVol2 = safeDiv(w2 * v2, pvolReal)
float marginalVol3 = safeDiv(w3 * v3, pvolReal)
float marginalVol4 = safeDiv(w4 * v4, pvolReal)
float riskShareMax = math.max(math.max(marginalVol0, marginalVol1), math.max(math.max(marginalVol2, marginalVol3), marginalVol4))
float eigenRiskProxy = clamp((riskShareMax - 0.25) / 0.50, 0, 1)
float capitalTemperature = clamp(frontierScore * 0.55 + (1.0 - corrDrag) * 25 + divBenefit * 30 - eigenRiskProxy * 20, 0, 100)
float allocationPressure = clamp(capitalTemperature / 100.0, 0.0, 1.0)
float shockAbsorber = clamp((1.0 - corrDrag) * (1.0 - eigenRiskProxy) * math.max(divBenefit, 0), 0, 1)
float activeRiskBudget = clamp(allocationPressure * (0.35 + shockAbsorber) - concentrationPenalty * 0.20, 0, 1)
float defensiveBudget = clamp((1.0 - activeRiskBudget) * (corrDrag + concentrationPenalty + eigenRiskProxy) / 3.0, 0, 1)
float frontierVelocity = frontierScore - frontierScore[5]
float frontierAcceleration = frontierVelocity - frontierVelocity[5]
bool recoveryImpulse = capitalTemperature > 55 and frontierVelocity > 0 and frontierAcceleration > 0
bool stressImpulse = capitalTemperature < 45 and frontierVelocity < 0 and corrDrag > 0.55
float breadthProxy = (w0 > 0.12 ? 1 : 0) + (w1 > 0.12 ? 1 : 0) + (w2 > 0.12 ? 1 : 0) + (w3 > 0.12 ? 1 : 0) + (w4 > 0.12 ? 1 : 0)
float breadthScore = breadthProxy / 5.0
float institutionalGrade = clamp(frontierScore * 0.45 + capitalTemperature * 0.25 + breadthScore * 20 + shockAbsorber * 25 - eigenRiskProxy * 15, 0, 100)
bool gradeA = barstate.isconfirmed and institutionalGrade >= 78 and activeRiskBudget > 0.45
bool gradeRisk = barstate.isconfirmed and (institutionalGrade <= 35 or stressImpulse)
bool gradeAEvent = gradeA and not gradeA[1]
bool gradeRiskEvent = gradeRisk and not gradeRisk[1]

float marketRet = (r1 + r2 + r3 + r4) / 4.0
float marketVol = ta.stdev(marketRet, retLen)
float betaToBasket = safeDiv(ta.correlation(r0, marketRet, retLen) * v0, marketVol)
float idioRet = r0 - betaToBasket * marketRet
float idioVol = ta.stdev(idioRet, retLen)
float qualityFactor = clamp(50 + safeDiv(ta.ema(idioRet, 21), math.max(idioVol, 0.000001)) * 18 - corrDrag * 14, 0, 100)
float momentumFactor = clamp(50 + safeDiv(ta.ema(close - close[21], 8), math.max(ta.atr(14), syminfo.mintick)) * 12 + momentumSpread * 45, 0, 100)
float lowVolFactor = clamp(100 - safeDiv(v0, math.max(weightedStandaloneVol, 0.000001)) * 35 - eigenRiskProxy * 25, 0, 100)
float carryFactor = clamp(50 + sharpeProxy * 16 + annReturn * 35 - annVol * 28, 0, 100)
float factorComposite = clamp(qualityFactor * 0.28 + momentumFactor * 0.28 + lowVolFactor * 0.22 + carryFactor * 0.22, 0, 100)
float factorDispersion = ta.stdev(factorComposite, retLen)
float factorUpper = factorComposite + clamp(factorDispersion, 4, 18)
float factorLower = factorComposite - clamp(factorDispersion, 4, 18)
float riskParityDrift = math.abs(w0 - 0.20) + math.abs(w1 - 0.20) + math.abs(w2 - 0.20) + math.abs(w3 - 0.20) + math.abs(w4 - 0.20)
float allocationEntropy = clamp(100 - riskParityDrift * 80, 0, 100)
float factorRegime = clamp(factorComposite * 0.40 + institutionalGrade * 0.35 + allocationEntropy * 0.25, 0, 100)
bool factorPrime = barstate.isconfirmed and factorRegime >= 76 and qualityFactor > 58 and momentumFactor > 58 and corrDrag < 0.62
bool factorDefense = barstate.isconfirmed and (factorRegime <= 36 or lowVolFactor < 30 or allocationEntropy < 35)
bool factorPrimeEvent = factorPrime and not factorPrime[1]
bool factorDefenseEvent = factorDefense and not factorDefense[1]

plot(capitalTemperature, "MFC capital temperature", color=color.new(C_GOLD, 20), linewidth=2)
plot(activeRiskBudget * 100, "MFC active risk budget", color=color.new(C_BULL, 25), style=plot.style_area)
plot(defensiveBudget * 100, "MFC defensive risk budget", color=color.new(C_BEAR, 58), style=plot.style_area)
plot(institutionalGrade, "MFC institutional grade", color=color.new(theme, 12), linewidth=2)
plot(eigenRiskProxy * 100, "MFC eigen-risk concentration", color=color.new(C_BEAR, 35), style=plot.style_columns)
plot(factorComposite, "MFC factor composite", color=color.new(C_BLUE, 6), linewidth=2)
plot(factorUpper, "MFC factor upper band", color=color.new(C_BLUE, 70))
plot(factorLower, "MFC factor lower band", color=color.new(C_BLUE, 70))
plot(qualityFactor, "MFC quality factor", color=color.new(C_BULL, 42))
plot(momentumFactor, "MFC momentum factor", color=color.new(C_GOLD, 42))
plot(lowVolFactor, "MFC low-vol factor", color=color.new(C_MUTED, 48))
plot(allocationEntropy, "MFC allocation entropy", color=color.new(C_TEXT, 55))
plotshape(gradeAEvent, "MFC grade A allocation", shape.labelup, location.bottom, color=color.new(C_BULL, 6), text="Grade A", textcolor=C_BG, size=size.tiny)
plotshape(gradeRiskEvent, "MFC institutional risk warning", shape.labeldown, location.top, color=color.new(C_BEAR, 6), text="Risk", textcolor=C_TEXT, size=size.tiny)
plotshape(factorPrimeEvent, "MFC factor prime", shape.labelup, location.bottom, color=color.new(C_BLUE, 5), text="Factor", textcolor=C_TEXT, size=size.tiny)
plotshape(factorDefenseEvent, "MFC factor defense", shape.labeldown, location.top, color=color.new(C_GOLD, 5), text="Defend", textcolor=C_BG, size=size.tiny)

var table hud = na
if showDashboard and barstate.islast
    if na(hud)
        hud := table.new(hudPos, 2, 8, bgcolor=color.new(C_BG, 8), border_color=color.new(C_TEXT, 82), border_width=1, frame_color=color.new(theme, 65), frame_width=1)
    table.cell(hud, 0, 0, "MARKOWITZ", text_color=C_TEXT, bgcolor=color.new(theme, 68), text_size=size.small)
    table.cell(hud, 1, 0, "MFC", text_color=C_TEXT, bgcolor=color.new(theme, 68), text_size=size.small)
    table.cell(hud, 0, 1, "Regime", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 1, factorPrime ? "Factor Prime" : factorDefense ? "Defense" : riskOn ? "Risk On" : riskOff ? "Risk Off" : "Neutral", text_color=factorPrime or riskOn ? C_BULL : factorDefense or riskOff ? C_BEAR : C_BLUE, text_size=size.small)
    table.cell(hud, 0, 2, "Frontier", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 2, str.tostring(frontierScore, "#.0"), text_color=theme, text_size=size.small)
    table.cell(hud, 0, 3, "Grade", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 3, str.tostring(institutionalGrade, "#.0"), text_color=institutionalGrade >= 65 ? C_BULL : institutionalGrade <= 40 ? C_BEAR : C_GOLD, text_size=size.small)
    table.cell(hud, 0, 4, "Factor", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 4, str.tostring(factorComposite, "#.0"), text_color=factorComposite >= 60 ? C_BULL : factorComposite <= 40 ? C_BEAR : C_BLUE, text_size=size.small)
    table.cell(hud, 0, 5, "Corr Drag", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 5, str.tostring(corrDrag * 100.0, "#.0"), text_color=corrDrag < 0.45 ? C_BULL : corrDrag > 0.72 ? C_BEAR : C_GOLD, text_size=size.small)
    table.cell(hud, 0, 6, "Entropy", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 6, str.tostring(allocationEntropy, "#.0"), text_color=allocationEntropy >= 65 ? C_BULL : allocationEntropy <= 35 ? C_BEAR : C_GOLD, text_size=size.small)
    table.cell(hud, 0, 7, "Budget", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 7, str.tostring(activeRiskBudget * 100.0, "#.0") + "%", text_color=activeRiskBudget >= 0.45 ? C_BULL : defensiveBudget > 0.35 ? C_BEAR : C_MUTED, text_size=size.small)

alertcondition(gradeAEvent, "MFC Grade A [JOAT]", "Markowitz Frontier Compass grade A allocation state")
alertcondition(gradeRiskEvent, "MFC Risk Warning [JOAT]", "Markowitz Frontier Compass institutional risk warning")
alertcondition(factorPrimeEvent, "MFC Factor Prime [JOAT]", "Markowitz Frontier Compass factor prime state")
alertcondition(factorDefenseEvent, "MFC Factor Defense [JOAT]", "Markowitz Frontier Compass factor defense state")
````
