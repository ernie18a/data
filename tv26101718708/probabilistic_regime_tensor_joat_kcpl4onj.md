# Probabilistic Regime Tensor [JOAT]

- url: https://www.tradingview.com/script/kcPL4oNj-Probabilistic-Regime-Tensor-JOAT/
- type: indicator
- pine_id: PUB;3e965a7ff209408282b596bf7715a91c
- version: 1.0

## Description

[b]Probabilistic Regime Tensor [JOAT][/b]

[b]Introduction[/b]

Probabilistic Regime Tensor classifies market state into Trend, Mean Reversion, or Shock using logistic transforms of statistical inputs.

This open-source indicator is designed as a context tool, not a standalone trading system. It focuses on explaining the current market state with restrained visuals and confirmed-bar logic where signals are used.

[image]https://www.tradingview.com/x/sJzjksUe/[/image]

[b]Core Concepts[/b]

[b]1. Trend Probability[/b]

Regression slope, variance ratio, and normalized return behavior feed the trend model.

[b]2. Mean-Reversion Probability[/b]

Contracting variance ratio, weak slope, and autocorrelation behavior feed the reversion model.

[b]3. Shock Probability[/b]

Volatility rank and fast/slow return divergence feed the shock model.

[b]4. Probability Entropy[/b]

The three probabilities are normalized and entropy shows whether the classifier is decisive or uncertain.

[pine]
pTrend = logistic(trendInput) / probabilitySum
[/pine]

[b]Features[/b]

[list]
[*]Three-state probability model
[*]Trend, mean, and shock probabilities
[*]Dominant confidence and entropy
[*]Sparse regime labels
[*]Movable quant HUD
[/list]

[b]Input Parameters[/b]

[list]
[*]Statistical and fast windows
[*]Dominant probability gate
[*]Cooldown
[*]Candle and HUD toggles
[*]HUD position selector
[/list]


[b]How to Use This Script[/b]

Use PRT to decide which style of analysis is more appropriate: continuation, mean reversion, or volatility caution.

[b]Limitations[/b]

[list]
[*]The script uses historical OHLCV data and cannot know future prices.
[*]Signals and states can be late during fast reversals because confirmed-bar logic is used to reduce repainting.
[*]Model outputs should be interpreted with market context, risk controls, and independent analysis.
[*]No visual state should be treated as a certain trade outcome.
[/list]

[b]Originality Statement[/b]

PRT is original in using normalized logistic probabilities and entropy to classify market regime.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any financial instrument. All calculations are derived from historical market data and may produce inaccurate readings in some market conditions. No indicator can predict future market behavior. Use proper risk management and independent judgment.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Probabilistic Regime Tensor [JOAT]", shorttitle="PRT [JOAT]", overlay=false, max_bars_back=900, max_lines_count=80, max_labels_count=80)

// Probabilistic Regime Tensor [JOAT]
// A compact classifier for trend, mean-reversion, and shock regimes using logistic transforms of statistical factors.
// It is not a prediction oracle; it is a probability-style state meter for deciding which type of model deserves trust.

string gModel = "Tensor Model"
string gSignal = "Signal Gates"
string gVisual = "Visual System"
int len = input.int(100, "Statistical window", minval=40, maxval=360, group=gModel)
int shortLen = input.int(21, "Fast window", minval=8, maxval=80, group=gModel)
float probGate = input.float(0.64, "Dominant probability", minval=0.50, maxval=0.90, step=0.01, group=gSignal)
int cooldown = input.int(10, "Signal cooldown", minval=1, maxval=100, group=gSignal)
bool paintBars = input.bool(true, "Paint bars", group=gVisual)
bool showDashboard = input.bool(true, "Show quant HUD", group=gVisual)
string hudLoc = input.string("Top Right", "HUD position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=gVisual)

color C_BULL = #00ffd5
color C_BEAR = #ff2af4
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

logistic(float x) =>
    1.0 / (1.0 + math.exp(-x))

float logRet = math.log(close / close[1])
float retFast = ta.ema(logRet, shortLen)
float retSlow = ta.ema(logRet, len)
float vol = ta.stdev(logRet, len)
float atr = ta.atr(14)
float slope = safeDiv(ta.linreg(close, len, 0) - ta.linreg(close, len, 1), math.max(atr, syminfo.mintick))
float varianceRatio = safeDiv(ta.variance(math.log(close / close[5]), len), 5.0 * ta.variance(logRet, len))
float autocorr = ta.correlation(logRet, logRet[1], len)
float volRank = safeDiv(vol - ta.lowest(vol, len), math.max(ta.highest(vol, len) - ta.lowest(vol, len), 0.000001))
float trendInput = slope * 2.6 + (varianceRatio - 1.0) * 1.4 + retFast / math.max(vol, 0.000001) * 0.25
float revertInput = (1.0 - varianceRatio) * 1.8 - autocorr * 1.2 - math.abs(slope) * 1.1
float shockInput = (volRank - 0.55) * 3.2 + math.abs(retFast - retSlow) / math.max(vol, 0.000001) * 0.20
float pTrendRaw = logistic(trendInput)
float pRevertRaw = logistic(revertInput)
float pShockRaw = logistic(shockInput)
float norm = math.max(pTrendRaw + pRevertRaw + pShockRaw, 0.000001)
float pTrend = pTrendRaw / norm
float pRevert = pRevertRaw / norm
float pShock = pShockRaw / norm
float confidence = math.max(math.max(pTrend, pRevert), pShock)
float entropy = clamp(-(pTrend * math.log(math.max(pTrend, 0.000001)) + pRevert * math.log(math.max(pRevert, 0.000001)) + pShock * math.log(math.max(pShock, 0.000001))) / math.log(3.0), 0, 1)
int regime = pTrend == confidence ? 1 : pRevert == confidence ? -1 : 2
color theme = regime == 1 ? C_BULL : regime == -1 ? C_BLUE : C_BEAR

var int lastSignal = na
bool cooled = na(lastSignal) or bar_index - lastSignal >= cooldown
bool trendEvent = barstate.isconfirmed and cooled and regime == 1 and confidence >= probGate and not (regime[1] == 1 and confidence[1] >= probGate)
bool revertEvent = barstate.isconfirmed and cooled and regime == -1 and confidence >= probGate and not (regime[1] == -1 and confidence[1] >= probGate)
bool shockEvent = barstate.isconfirmed and cooled and regime == 2 and confidence >= probGate and not (regime[1] == 2 and confidence[1] >= probGate)
if trendEvent or revertEvent or shockEvent
    lastSignal := bar_index

plot(pTrend * 100, "PRT trend probability", color=color.new(C_BULL, 5), linewidth=2)
plot(pRevert * 100, "PRT reversion probability", color=color.new(C_BLUE, 5), linewidth=2)
plot(pShock * 100, "PRT shock probability", color=color.new(C_BEAR, 5), linewidth=2)
plot(confidence * 100, "PRT dominant confidence", color=color.new(C_GOLD, 20), linewidth=2)
plot(entropy * 100, "PRT regime entropy", color=color.new(C_MUTED, 55), style=plot.style_area)
hline(probGate * 100, "PRT probability gate", color=color.new(C_TEXT, 72))
hline(50, "PRT neutral", color=color.new(C_MUTED, 80))
plotshape(trendEvent, "PRT trend regime", shape.labelup, location.bottom, color=color.new(C_BULL, 6), text="Trend", textcolor=C_BG, size=size.tiny)
plotshape(revertEvent, "PRT reversion regime", shape.labelup, location.bottom, color=color.new(C_BLUE, 6), text="Mean", textcolor=C_TEXT, size=size.tiny)
plotshape(shockEvent, "PRT shock regime", shape.labeldown, location.top, color=color.new(C_BEAR, 6), text="Shock", textcolor=C_TEXT, size=size.tiny)
barcolor(paintBars ? regime == 1 ? color.new(C_BULL, 74) : regime == -1 ? color.new(C_BLUE, 78) : color.new(C_BEAR, 74) : na)

var table hud = na
if showDashboard and barstate.islast
    if na(hud)
        hud := table.new(hudPos, 2, 7, bgcolor=color.new(C_BG, 8), border_color=color.new(C_TEXT, 82), border_width=1, frame_color=color.new(theme, 65), frame_width=1)
    table.cell(hud, 0, 0, "REGIME", text_color=C_TEXT, bgcolor=color.new(theme, 68), text_size=size.small)
    table.cell(hud, 1, 0, "PRT", text_color=C_TEXT, bgcolor=color.new(theme, 68), text_size=size.small)
    table.cell(hud, 0, 1, "State", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 1, regime == 1 ? "Trend" : regime == -1 ? "Mean" : "Shock", text_color=theme, text_size=size.small)
    table.cell(hud, 0, 2, "Trend", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 2, str.tostring(pTrend * 100, "#.0"), text_color=C_BULL, text_size=size.small)
    table.cell(hud, 0, 3, "Mean", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 3, str.tostring(pRevert * 100, "#.0"), text_color=C_BLUE, text_size=size.small)
    table.cell(hud, 0, 4, "Shock", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 4, str.tostring(pShock * 100, "#.0"), text_color=C_BEAR, text_size=size.small)
    table.cell(hud, 0, 5, "Confidence", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 5, str.tostring(confidence * 100, "#.0"), text_color=confidence >= probGate ? C_GOLD : C_MUTED, text_size=size.small)
    table.cell(hud, 0, 6, "Entropy", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 6, str.tostring(entropy * 100, "#.0"), text_color=entropy <= 0.58 ? C_BULL : C_GOLD, text_size=size.small)

alertcondition(trendEvent, "PRT Trend Regime [JOAT]", "Probabilistic Regime Tensor trend regime")
alertcondition(revertEvent, "PRT Mean-Reversion Regime [JOAT]", "Probabilistic Regime Tensor mean-reversion regime")
alertcondition(shockEvent, "PRT Shock Regime [JOAT]", "Probabilistic Regime Tensor shock regime")
````
