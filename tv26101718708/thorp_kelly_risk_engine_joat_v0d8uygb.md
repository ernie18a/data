# Thorp Kelly Risk Engine [JOAT]

- url: https://www.tradingview.com/script/v0d8uYGB-Thorp-Kelly-Risk-Engine-JOAT/
- type: indicator
- pine_id: PUB;8242fcda7b2e45be8cbfd10c14ba986f
- version: 1.0

## Description

[b]Thorp Kelly Risk Engine [JOAT][/b]

[b]Introduction[/b]

Thorp Kelly Risk Engine is a risk-quality study that tracks virtual outcomes, Kelly estimates, Bayesian shrinkage, drawdown pressure, survival score, and deployment state.

This open-source indicator is designed as a context tool, not a standalone trading system. It focuses on explaining the current market state with restrained visuals and confirmed-bar logic where signals are used.

[image]https://www.tradingview.com/x/ENNOyiHq/[/image]

[b]Core Concepts[/b]

[b]1. Virtual Outcome Tracker[/b]

Trend setups create virtual reward/risk outcomes measured in ATR units.

[b]2. Kelly Estimate[/b]

Win rate and payoff ratio produce full and fractional Kelly-style estimates.

[b]3. Bayesian Shrinkage[/b]

A prior win rate reduces overconfidence when sample size is small.

[b]4. Survival and Desk Score[/b]

Drawdown, volatility, signal density, convexity, and uncertainty combine into risk state.

[pine]
kelly = (payoff * winRate - lossRate) / payoff
[/pine]

[b]Features[/b]

[list]
[*]Virtual outcome sampling
[*]Fractional and Bayesian Kelly estimates
[*]Drawdown throttle and volatility brake
[*]Ruin-adjusted Kelly
[*]Prime, defense, and lockdown states
[/list]

[b]Input Parameters[/b]

[list]
[*]Trend, RSI, and ATR lengths
[*]Reward and risk ATR
[*]Kelly fraction and max allocation
[*]Minimum sample and drawdown brake
[*]Display toggles and HUD position
[/list]


[b]How to Use This Script[/b]

Use TKR as risk context. Prime states suggest healthier virtual samples; defensive and lockdown states warn that model risk is elevated.

[b]Limitations[/b]

[list]
[*]The script uses historical OHLCV data and cannot know future prices.
[*]Signals and states can be late during fast reversals because confirmed-bar logic is used to reduce repainting.
[*]Model outputs should be interpreted with market context, risk controls, and independent analysis.
[*]No visual state should be treated as a certain trade outcome.
[/list]

[b]Originality Statement[/b]

TKR is original in combining Kelly math, Bayesian shrinkage, drawdown throttling, survival scoring, and uncertainty cones.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any financial instrument. All calculations are derived from historical market data and may produce inaccurate readings in some market conditions. No indicator can predict future market behavior. Use proper risk management and independent judgment.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Thorp Kelly Risk Engine [JOAT]", shorttitle="TKR [JOAT]", overlay=false, max_bars_back=1000, max_lines_count=120, max_labels_count=80)


string gSignal = "Signal Model"
string gKelly = "Kelly Engine"
string gRisk = "Risk Controls"
string gVisual = "Visual System"
int fastLen = input.int(21, "Fast trend length", minval=2, maxval=100, group=gSignal)
int slowLen = input.int(55, "Slow trend length", minval=5, maxval=250, group=gSignal)
int rsiLen = input.int(14, "RSI length", minval=2, maxval=50, group=gSignal)
int atrLen = input.int(14, "ATR length", minval=5, maxval=100, group=gSignal)
float rewardAtr = input.float(2.0, "Virtual reward ATR", minval=0.5, maxval=10, step=0.1, group=gKelly)
float riskAtr = input.float(1.0, "Virtual risk ATR", minval=0.25, maxval=5, step=0.1, group=gKelly)
float kellyFraction = input.float(0.25, "Fractional Kelly", minval=0.05, maxval=1, step=0.05, group=gKelly)
float maxKelly = input.float(0.12, "Max displayed allocation", minval=0.01, maxval=0.50, step=0.01, group=gRisk)
int minTrades = input.int(20, "Minimum sample", minval=5, maxval=200, group=gRisk)
float drawdownBrake = input.float(0.08, "Drawdown brake", minval=0.01, maxval=0.50, step=0.01, group=gRisk)
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

fmtPct(float x) =>
    str.tostring(x * 100.0, "#.##") + "%"

float emaFast = ta.ema(close, fastLen)
float emaSlow = ta.ema(close, slowLen)
float atr = ta.atr(atrLen)
float rsi = ta.rsi(close, rsiLen)
float trendImpulse = safeDiv(emaFast - emaSlow, atr)
float velocity = safeDiv(close - close[5], atr)
bool longSetup = barstate.isconfirmed and emaFast > emaSlow and rsi > 52 and trendImpulse > 0.15 and velocity > 0
bool shortSetup = barstate.isconfirmed and emaFast < emaSlow and rsi < 48 and trendImpulse < -0.15 and velocity < 0
bool longSignal = longSetup and not longSetup[1]
bool shortSignal = shortSetup and not shortSetup[1]

var bool vtActive = false
var int vtDir = 0
var float vtEntry = na
var float vtTarget = na
var float vtStop = na
var int vtEntryBar = na
var int wins = 0
var int losses = 0
var float grossWin = 0.0
var float grossLoss = 0.0
var float equityCurve = 1.0
var float equityHigh = 1.0
var float lastOutcomeR = 0.0

if not vtActive and (longSignal or shortSignal)
    vtActive := true
    vtDir := longSignal ? 1 : -1
    vtEntry := close
    vtTarget := close + vtDir * atr * rewardAtr
    vtStop := close - vtDir * atr * riskAtr
    vtEntryBar := bar_index

if vtActive and vtDir == 1
    bool hitTarget = high >= vtTarget
    bool hitStop = low <= vtStop
    if hitTarget or hitStop
        if hitTarget and not hitStop
            wins += 1
            grossWin += rewardAtr
            lastOutcomeR := rewardAtr
            equityCurve *= 1.0 + 0.01 * rewardAtr
        else
            losses += 1
            grossLoss += riskAtr
            lastOutcomeR := -riskAtr
            equityCurve *= 1.0 - 0.01 * riskAtr
        vtActive := false

if vtActive and vtDir == -1
    bool hitTarget = low <= vtTarget
    bool hitStop = high >= vtStop
    if hitTarget or hitStop
        if hitTarget and not hitStop
            wins += 1
            grossWin += rewardAtr
            lastOutcomeR := rewardAtr
            equityCurve *= 1.0 + 0.01 * rewardAtr
        else
            losses += 1
            grossLoss += riskAtr
            lastOutcomeR := -riskAtr
            equityCurve *= 1.0 - 0.01 * riskAtr
        vtActive := false

equityHigh := math.max(equityHigh, equityCurve)
int trades = wins + losses
float winRateRaw = trades > 0 ? wins / trades : 0.50
float avgWin = wins > 0 ? grossWin / wins : rewardAtr
float avgLoss = losses > 0 ? grossLoss / losses : riskAtr
float payoff = safeDiv(avgWin, avgLoss)
float q = 1.0 - winRateRaw
float fullKellyRaw = payoff > 0 ? (payoff * winRateRaw - q) / payoff : 0.0
float reliability = clamp((trades - minTrades) / math.max(minTrades * 2.0, 1), 0, 1)
float realizedVol = ta.stdev(math.log(close / close[1]), 40) * math.sqrt(252)
float volBrake = clamp(1.0 - realizedVol, 0.25, 1.0)
float drawdown = safeDiv(equityHigh - equityCurve, equityHigh)
float ddThrottle = drawdown > drawdownBrake ? clamp(1.0 - safeDiv(drawdown - drawdownBrake, drawdownBrake * 2.0), 0.10, 1.0) : 1.0
float fractionalKelly = clamp(fullKellyRaw * kellyFraction * reliability * volBrake * ddThrottle, 0, maxKelly)
float edgeScore = clamp(50 + fullKellyRaw * 160 + (winRateRaw - 0.5) * 80 + (payoff - 1.0) * 18 - drawdown * 220, 0, 100)
float edgeSmooth = ta.ema(edgeScore, 5)

bool expandRisk = barstate.isconfirmed and fractionalKelly > nz(fractionalKelly[1]) and fractionalKelly > maxKelly * 0.25 and edgeSmooth > 60
bool contractRisk = barstate.isconfirmed and (fractionalKelly < nz(fractionalKelly[1]) and edgeSmooth < 50 or drawdown > drawdownBrake)
bool expandEvent = expandRisk and not expandRisk[1]
bool contractEvent = contractRisk and not contractRisk[1]

color theme = edgeSmooth >= 65 ? C_BULL : edgeSmooth <= 40 ? C_BEAR : C_BLUE
plot(edgeSmooth, "TKR edge score", color=color.new(theme, 5), linewidth=2)
plot(fractionalKelly * 100, "TKR fractional Kelly percent", color=color.new(C_GOLD, 10), linewidth=2)
plot(fullKellyRaw * 100, "TKR full Kelly estimate", color=color.new(C_TEXT, 55))
plot(drawdown * 100, "TKR model drawdown", color=color.new(C_BEAR, 25), style=plot.style_area)
hline(70, "TKR strong edge", color=color.new(C_BULL, 75))
hline(50, "TKR neutral edge", color=color.new(C_MUTED, 75))
hline(30, "TKR risk contraction", color=color.new(C_BEAR, 75))
plotshape(expandEvent, "TKR risk expansion", shape.labelup, location.bottom, color=color.new(C_BULL, 8), text="Expand", textcolor=C_BG, size=size.tiny)
plotshape(contractEvent, "TKR risk contraction", shape.labeldown, location.top, color=color.new(C_BEAR, 8), text="Cut", textcolor=C_TEXT, size=size.tiny)
barcolor(paintBars ? expandRisk ? color.new(C_BULL, 72) : contractRisk ? color.new(C_BEAR, 72) : na : na)

alertcondition(expandEvent, "TKR Risk Expansion [JOAT]", "Thorp Kelly Risk Engine expanding risk allowance")
alertcondition(contractEvent, "TKR Risk Contraction [JOAT]", "Thorp Kelly Risk Engine cutting risk allowance")


float priorWinRate = 0.50
float shrinkStrength = 18.0
float bayesWinRate = safeDiv(wins + priorWinRate * shrinkStrength, trades + shrinkStrength)
float bayesLossRate = 1.0 - bayesWinRate
float bayesKelly = payoff > 0 ? (payoff * bayesWinRate - bayesLossRate) / payoff : 0.0
float bayesFractional = clamp(bayesKelly * kellyFraction * volBrake * ddThrottle, 0, maxKelly)
float edgeDecay = ta.ema(lastOutcomeR, 12)
float realizedEdgeR = trades > 0 ? safeDiv(grossWin - grossLoss, trades) : 0.0
float signalDensity = safeDiv(math.sum(longSignal or shortSignal ? 1.0 : 0.0, 100), 100.0)
float crowdingBrake = clamp(1.0 - signalDensity * 1.5, 0.25, 1.0)
float ruinPressure = clamp(drawdown / math.max(drawdownBrake, 0.001), 0, 3)
float survivalScore = clamp(100 - ruinPressure * 28 - realizedVol * 45 + reliability * 20 + edgeDecay * 8, 0, 100)
float deploymentScore = clamp(edgeSmooth * 0.45 + survivalScore * 0.35 + bayesFractional / math.max(maxKelly, 0.001) * 20, 0, 100)
float riskThrottle = clamp(bayesFractional / math.max(maxKelly, 0.001) * crowdingBrake * ddThrottle, 0, 1)
int capitalMode = deploymentScore >= 72 ? 3 : deploymentScore >= 55 ? 2 : deploymentScore >= 38 ? 1 : 0
float winStdErr = math.sqrt(math.max(bayesWinRate * (1.0 - bayesWinRate), 0.0) / math.max(trades + shrinkStrength, 1.0))
float lowerProb = clamp(bayesWinRate - 1.65 * winStdErr, 0.01, 0.99)
float upperProb = clamp(bayesWinRate + 1.65 * winStdErr, 0.01, 0.99)
float lowerKelly = payoff > 0 ? (payoff * lowerProb - (1.0 - lowerProb)) / payoff : 0.0
float upperKelly = payoff > 0 ? (payoff * upperProb - (1.0 - upperProb)) / payoff : 0.0
float kellyConeWidth = clamp((upperKelly - lowerKelly) * 100.0, 0, 100)
float conservativeKelly = clamp(lowerKelly * kellyFraction * volBrake * ddThrottle * crowdingBrake, 0, maxKelly)
var int winStreak = 0
var int lossStreak = 0
if lastOutcomeR > 0 and lastOutcomeR[1] <= 0
    winStreak := 1
    lossStreak := 0
else if lastOutcomeR > 0 and lastOutcomeR[1] > 0
    winStreak += 1
else if lastOutcomeR < 0 and lastOutcomeR[1] >= 0
    lossStreak := 1
    winStreak := 0
else if lastOutcomeR < 0 and lastOutcomeR[1] < 0
    lossStreak += 1
float streakPressure = clamp(lossStreak * 12 - winStreak * 4, 0, 100)
float ruinAdjustedKelly = clamp(conservativeKelly * (1.0 - streakPressure / 140.0) * (1.0 - clamp(ruinPressure / 3.0, 0, 0.85)), 0, maxKelly)
float convexityScore = clamp((payoff - 1.0) * 24 + (upperKelly - math.max(lowerKelly, 0)) * 80 + edgeDecay * 8, 0, 100)
float deskScore = clamp(deploymentScore * 0.35 + survivalScore * 0.25 + convexityScore * 0.25 + (100 - kellyConeWidth) * 0.15, 0, 100)
bool tierPrime = barstate.isconfirmed and capitalMode == 3 and riskThrottle > 0.45
bool tierNeutral = barstate.isconfirmed and capitalMode == 2
bool tierDefensive = barstate.isconfirmed and capitalMode <= 1
bool primeEvent = tierPrime and not tierPrime[1]
bool defensiveEvent = tierDefensive and not tierDefensive[1]
bool deskPrime = barstate.isconfirmed and deskScore >= 74 and ruinAdjustedKelly > maxKelly * 0.20
bool deskLockdown = barstate.isconfirmed and (deskScore <= 34 or streakPressure > 55)
bool deskPrimeEvent = deskPrime and not deskPrime[1]
bool deskLockdownEvent = deskLockdown and not deskLockdown[1]

plot(bayesFractional * 100, "TKR Bayesian fractional Kelly", color=color.new(C_BLUE, 8), linewidth=2)
plot(ruinAdjustedKelly * 100, "TKR ruin-adjusted Kelly", color=color.new(C_BULL, 8), linewidth=2)
plot(survivalScore, "TKR survival score", color=color.new(survivalScore >= 60 ? C_BULL : C_BEAR, 25), linewidth=2)
plot(deploymentScore, "TKR deployment score", color=color.new(deploymentScore >= 60 ? C_BULL : C_GOLD, 15), linewidth=2)
plot(riskThrottle * 100, "TKR live risk throttle", color=color.new(C_GOLD, 35), style=plot.style_columns)
plot(signalDensity * 100, "TKR signal density", color=color.new(C_MUTED, 55), style=plot.style_area)
plot(kellyConeWidth, "TKR Kelly uncertainty cone", color=color.new(C_BEAR, 48), style=plot.style_columns)
plot(convexityScore, "TKR payoff convexity", color=color.new(C_BLUE, 35))
plot(deskScore, "TKR desk score", color=color.new(theme, 5), linewidth=2)
plotshape(primeEvent, "TKR prime risk tier", shape.labelup, location.bottom, color=color.new(C_BULL, 5), text="Prime", textcolor=C_BG, size=size.tiny)
plotshape(defensiveEvent, "TKR defensive risk tier", shape.labeldown, location.top, color=color.new(C_BEAR, 5), text="Defend", textcolor=C_TEXT, size=size.tiny)
plotshape(deskPrimeEvent, "TKR desk prime", shape.labelup, location.bottom, color=color.new(C_BLUE, 5), text="Desk", textcolor=C_TEXT, size=size.tiny)
plotshape(deskLockdownEvent, "TKR desk lockdown", shape.labeldown, location.top, color=color.new(C_GOLD, 5), text="Lock", textcolor=C_BG, size=size.tiny)

var table hud = na
if showDashboard and barstate.islast
    if na(hud)
        hud := table.new(hudPos, 2, 8, bgcolor=color.new(C_BG, 8), border_color=color.new(C_TEXT, 82), border_width=1, frame_color=color.new(theme, 65), frame_width=1)
    table.cell(hud, 0, 0, "THORP", text_color=C_TEXT, bgcolor=color.new(theme, 68), text_size=size.small)
    table.cell(hud, 1, 0, "TKR", text_color=C_TEXT, bgcolor=color.new(theme, 68), text_size=size.small)
    table.cell(hud, 0, 1, "Mode", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 1, deskPrime ? "Prime" : deskLockdown ? "Lockdown" : tierDefensive ? "Defense" : tierNeutral ? "Neutral" : "Deploy", text_color=deskPrime ? C_BULL : deskLockdown or tierDefensive ? C_BEAR : tierNeutral ? C_GOLD : C_BLUE, text_size=size.small)
    table.cell(hud, 0, 2, "Desk", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 2, str.tostring(deskScore, "#.0"), text_color=deskScore >= 65 ? C_BULL : deskScore <= 40 ? C_BEAR : C_BLUE, text_size=size.small)
    table.cell(hud, 0, 3, "Kelly", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 3, fmtPct(ruinAdjustedKelly), text_color=ruinAdjustedKelly > maxKelly * 0.25 ? C_BULL : C_GOLD, text_size=size.small)
    table.cell(hud, 0, 4, "Win Bayes", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 4, fmtPct(bayesWinRate), text_color=bayesWinRate >= 0.53 ? C_BULL : bayesWinRate <= 0.48 ? C_BEAR : C_MUTED, text_size=size.small)
    table.cell(hud, 0, 5, "Drawdown", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 5, fmtPct(drawdown), text_color=drawdown <= drawdownBrake ? C_BULL : C_BEAR, text_size=size.small)
    table.cell(hud, 0, 6, "Survival", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 6, str.tostring(survivalScore, "#.0"), text_color=survivalScore >= 65 ? C_BULL : survivalScore <= 40 ? C_BEAR : C_GOLD, text_size=size.small)
    table.cell(hud, 0, 7, "Sample", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 7, str.tostring(trades) + " / " + str.tostring(kellyConeWidth, "#.0"), text_color=trades >= minTrades ? C_BULL : C_MUTED, text_size=size.small)

alertcondition(primeEvent, "TKR Prime Tier [JOAT]", "Thorp Kelly Risk Engine prime deployment tier")
alertcondition(defensiveEvent, "TKR Defensive Tier [JOAT]", "Thorp Kelly Risk Engine defensive tier")
alertcondition(deskPrimeEvent, "TKR Desk Prime [JOAT]", "Thorp Kelly Risk Engine desk prime state")
alertcondition(deskLockdownEvent, "TKR Desk Lockdown [JOAT]", "Thorp Kelly Risk Engine lockdown state")
````
