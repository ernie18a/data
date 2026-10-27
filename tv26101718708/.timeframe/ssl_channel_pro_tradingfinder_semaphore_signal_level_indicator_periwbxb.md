# SSL Channel Pro [TradingFinder] Semaphore Signal Level Indicator

- url: https://www.tradingview.com/script/PERIWBXb-SSL-Channel-Pro-TradingFinder-Semaphore-Signal-Level-Indicator/
- type: indicator
- pine_id: PUB;dba5560037714335bcf843dade80c1af
- version: 1.0

## Description

🔵[b]Introduction[/b]

Trend identification is one of the most common challenges in technical analysis. Many traders use moving average channels and SSL-based systems to understand market direction, but a simple trend flip does not always represent a meaningful market transition. Price can cross a channel during consolidation, low-momentum conditions, or temporary volatility without creating a sustainable move.

This indicator builds on the classic SSL Channel concept by combining trend direction with additional market context. Instead of treating every SSL transition as a trading opportunity, it evaluates momentum, trend strength, volatility conditions, and market participation to identify stronger trend changes. The result is a cleaner approach to reading bullish and bearish transitions while reducing attention on weaker market movements.

[image]https://www.tradingview.com/x/VfLz7zup/[/image]

The core system uses High and Low based moving average calculations to define the active SSL state, then adds confirmation layers using tools such as RSI, ADX/DMI, ATR-based channel analysis, and optional Higher Timeframe confirmation. These components work together to provide a broader view of whether the current environment supports a potential trend continuation or a meaningful reversal.

A dynamic scoring model from 0 to 100 provides additional context for confirmed signals. This score is not a prediction of market outcome or a win-rate measurement; it represents the internal alignment between different market factors at the moment a signal appears. The A+ to D grading system helps traders quickly understand the relative quality of each setup and decide which signals match their own trading approach.


🔵[b]How to Use[/b]

The indicator is built around a simple workflow: first identify the current SSL trend state, then evaluate the quality of the market conditions before considering a signal. The SSL channel acts as the directional framework, showing whether the current market environment is dominated by buyers or sellers. Additional confirmation layers help separate meaningful trend transitions from temporary price movements that occur during weak or unstable conditions.

The most important concept is the difference between an SSL trend flip and a confirmed signal. A trend flip only shows that the market direction has changed according to the SSL calculation. A confirmed BUY or SELL signal requires additional agreement between momentum, trend strength, volatility conditions, and optional Higher Timeframe context. This allows traders to use the indicator either as a clean trend-following tool or as a confirmation layer alongside their own trading strategy.

🟣[b]Bullish Trend & BUY Signals[/b]

A bullish condition begins when the closing price moves above the upper SSL boundary, which is calculated from the High-based moving average. After this transition, the SSL state changes to bullish and the active SSL line moves to the lower channel boundary. The bullish state represents an environment where buyers have gained control of the current trend structure.

While the bullish SSL state remains active, traders can use the channel as a visual guide for identifying trend continuation opportunities, pullbacks, and potential long setups. The bullish color transition provides an immediate overview of market direction, but it should not be interpreted as an automatic entry signal. The indicator intentionally separates trend direction from signal generation because many market transitions happen during consolidation or low-quality conditions.

[image]https://www.tradingview.com/x/cMkA8E7U/[/image]

A confirmed BUY signal appears only when the bullish SSL transition is supported by additional market factors. The system evaluates momentum through RSI, trend strength through ADX and DMI, and market activity through the relationship between channel width and ATR. If the market does not have enough strength, expansion, or directional agreement, the SSL may turn bullish without producing a BUY label.

Each confirmed BUY signal receives a Quality Score between 0 and 100. This score measures how strongly different internal factors are aligned at the moment of the signal, including transition quality, momentum strength, trend quality, market regime, participation, and contextual confirmation. The score is not a prediction of future performance and does not represent a probability of winning a trade. Instead, it helps traders compare different setups and understand the relative quality of each signal.

The signal grade system converts this score into simple categories from A+ to D. Higher grades indicate stronger alignment between the measured factors, while lower grades indicate weaker conditions. Traders can use these grades according to their own approach, for example focusing on higher-grade signals when they prefer stricter filtering or considering lower-grade signals when they prefer earlier market participation.

[image]https://www.tradingview.com/x/i6BBMhaG/[/image]

When Higher Timeframe Confirmation is enabled, a BUY signal also requires the SSL direction on the selected higher timeframe to support the bullish direction. This allows traders to combine lower timeframe entries with broader market context and avoid signals that move against the larger trend environment.


🟣[b]Bearish Trend & SELL Signals[/b]

A bearish condition begins when the closing price moves below the lower SSL boundary, which is calculated from the Low-based moving average. After this transition, the SSL state changes to bearish and the active SSL line moves to the upper channel boundary. This indicates that selling pressure has become dominant according to the SSL trend calculation.

During a bearish SSL state, traders can use the indicator to analyze downward trends, bearish pullbacks, and potential continuation scenarios. The bearish channel visualization provides a clear view of the current market direction, but a simple color change is not considered a complete trading signal. The system requires additional confirmation to avoid reacting to weak moves, short-term volatility, or false trend transitions.

[image]https://www.tradingview.com/x/zOLFusM3/[/image]

A confirmed SELL signal is generated when the bearish SSL transition is supported by stronger market evidence. The indicator evaluates whether bearish momentum is present through RSI, whether sellers have sufficient directional strength through ADX and DMI, and whether the current market environment has enough volatility and expansion through ATR-based channel analysis.

Similar to BUY signals, every confirmed SELL setup receives a Quality Score from 0 to 100. The score combines multiple internal measurements to show the level of agreement between trend transition, momentum, trend strength, market regime, participation, and optional context confirmation. A high score means that more factors are aligned according to the indicator model, but it should never be interpreted as a guaranteed outcome or a standalone trading decision.

The A+ to D grading system provides a faster way to interpret the signal quality. Stronger grades represent greater internal alignment, while lower grades indicate that fewer conditions are supporting the move. Traders can combine this information with their own analysis, risk management rules, and market structure evaluation.

[image]https://www.tradingview.com/x/wCOljaUM/[/image]

With Higher Timeframe Confirmation enabled, SELL signals are filtered by the broader trend direction. A short signal is only confirmed when the higher timeframe SSL state also supports bearish conditions, helping traders analyze opportunities with additional market context.


🔵[b]Settings[/b]

[i]MA Type[/i]: Defines the moving average method used to calculate the SSL channel.
[list]
[*][i]SMA[/i]: Smoother and slower response. 
[*][i]EMA[/i]: Faster response to recent price changes; recommended default. 
[*][i]WMA[/i]: Gives more weight to recent prices. 
[*][i]HMA[/i]: Fast and smooth, more sensitive to trend changes. 
[*][i]RMA[/i]: Smoother behavior with less short-term noise. 
[*][i]VWMA[/i]: Uses volume-weighted calculations when volume data is available. 
[/list]

[i]SSL Length[/i]: Controls the sensitivity of the SSL channel. Lower values create faster reactions with more trend changes, while higher values create a smoother channel with fewer signals.

[i]Signal Quality[/i]: defines the strictness of the signal confirmation engine. It adjusts the internal requirements for trend strength, channel conditions, and minimum signal score.

[list]
[*]Responsive is designed for users who prefer earlier reactions and more frequent signals. It allows more trend transitions to qualify, but may include more market noise.
[*]Balanced provides a balance between signal frequency and confirmation strength. This is the recommended default setting for most users.
[*]Selective focuses on stronger market conditions and higher-quality setups. It requires stricter confirmation, resulting in fewer but more filtered signals.
[/list]

[i]Show Signals[/i]: controls the visibility of confirmed BUY and SELL markers on the chart. When enabled, each signal displays its direction, quality grade, and score value. When disabled, the chart remains cleaner while the internal signal logic and alerts continue to work normally.

[i]Enable HTF Confirmation[/i]: adds Higher Timeframe confirmation to the signal process. When enabled, BUY signals require the higher timeframe SSL direction to be bullish, while SELL signals require bearish alignment. This can help filter signals against the broader trend but may reduce the number of available signals.

[i]Higher Timeframe[/i]: defines the timeframe used for confirmation. The selected timeframe must always be higher than the current chart timeframe. For example, a 5-minute chart can use 15-minute, 30-minute, or 1-hour confirmation, while a 1-hour chart can use 4-hour or daily confirmation. Equal or lower timeframes will not provide valid higher timeframe confirmation.

🔵[b]Conclusion[/b]

SSL Channel Pro combines the simplicity of the classic SSL Channel concept with additional layers of market analysis to provide a clearer view of trend direction and transition quality. By combining SSL structure, momentum evaluation, trend strength analysis, volatility conditions, participation, and optional Higher Timeframe confirmation, the indicator helps traders distinguish between simple market movement and more meaningful trend changes.

The indicator is designed to support structured decision-making rather than replace a complete trading methodology. The Quality Score and Grade system provide additional context for evaluating signal conditions, while traders should continue to apply their own market analysis, risk management, and trading rules. Used correctly, SSL Channel Pro can serve as a flexible trend analysis tool, confirmation layer, or signal filter across different markets and timeframes.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradingFinder
//@version=6

indicator("SSL Channel Pro [TradingFinder] Semaphore Signal Level Indicator", shorttitle="SSL Pro", overlay=true, max_labels_count=500)


maType = input.string("EMA", "MA Type", options=["SMA", "EMA", "WMA", "HMA", "RMA", "VWMA"], group= "SSL Setting")
sslLength = input.int(10, "SSL Length", minval=1, group="SSL Setting")

signalProfile = input.string("Balanced", "Signal Quality", options=["Responsive", "Balanced", "Selective"], group= "Signal Setting", tooltip="Responsive shows more signals. Balanced is recommended. Selective keeps only stronger setups.")
useHTF = input.bool(false, "Enable HTF Confirmation", group= "Signal Setting", inline="htf")
htfTimeframe = input.timeframe("60", "Higher Timeframe", group= "Signal Setting", inline="htf")
showSignals = input.bool(true, "Show Signals", group= "Signal Setting")


MA(float source, int length, string type) =>
    switch type
        "SMA"  => ta.sma(source, length)
        "EMA"  => ta.ema(source, length)
        "WMA"  => ta.wma(source, length)
        "HMA"  => ta.hma(source, length)
        "RMA"  => ta.rma(source, length)
        "VWMA" => ta.vwma(source, length)
        => ta.ema(source, length)


highMA = MA(high, sslLength, maType)
lowMA = MA(low, sslLength, maType)

var int sslState = 1
sslState := close > highMA ? 1 : close < lowMA ? -1 : nz(sslState[1], 1)

sslLine = sslState == 1 ? lowMA : highMA
flipUp = barstate.isconfirmed and sslState == 1 and sslState[1] == -1
flipDown = barstate.isconfirmed and sslState == -1 and sslState[1] == 1

rsiValue = ta.rsi(close, 14)
[plusDI, minusDI, adxValue] = ta.dmi(14, 14)
volumeMA = ta.sma(volume, 20)
atrValue = ta.atr(14)
channelWidth = math.abs(highMA - lowMA)
normalizedWidth = atrValue > 0.0 ? channelWidth / atrValue : 0.0

buyRSI = rsiValue > 50
sellRSI = rsiValue < 50
buyADX = adxValue > (signalProfile == "Responsive" ? 18.0 : signalProfile == "Selective" ? 25.0 : 20.0) and plusDI > minusDI
sellADX = adxValue > (signalProfile == "Responsive" ? 18.0 : signalProfile == "Selective" ? 25.0 : 20.0) and minusDI > plusDI
channelStrong = normalizedWidth >= (signalProfile == "Responsive" ? 0.14 : signalProfile == "Selective" ? 0.28 : 0.20)

buyConfirmations = buyRSI and buyADX and channelStrong
sellConfirmations = sellRSI and sellADX and channelStrong

clamp(float value, float minimum, float maximum) =>
    math.min(math.max(value, minimum), maximum)

scale01(float value, float minimum, float maximum) =>
    maximum > minimum ? clamp((value - minimum) / (maximum - minimum), 0.0, 1.0) : 0.0

grade(int score) =>
    score >= 90 ? "A+" : score >= 80 ? "A" : score >= 70 ? "B" : score >= 60 ? "C" : "D"



candleRange = math.max(high - low, syminfo.mintick)
bodyRatio = math.abs(close - open) / candleRange
buyCloseLocation = clamp((close - low) / candleRange, 0.0, 1.0)
sellCloseLocation = clamp((high - close) / candleRange, 0.0, 1.0)
buyBreakoutDistance = atrValue > 0.0 ? math.max(close - highMA, 0.0) / atrValue : 0.0
sellBreakoutDistance = atrValue > 0.0 ? math.max(lowMA - close, 0.0) / atrValue : 0.0

buyTransitionScore = flipUp ? 12.0 + scale01(buyBreakoutDistance, 0.0, 0.40) * 6.0 + bodyRatio * 4.0 + buyCloseLocation * 3.0 : 0.0
sellTransitionScore = flipDown ? 12.0 + scale01(sellBreakoutDistance, 0.0, 0.40) * 6.0 + bodyRatio * 4.0 + sellCloseLocation * 3.0 : 0.0

buyRsiDelta = rsiValue - 50
sellRsiDelta = 50 - rsiValue
buyMomentumScore = scale01(buyRsiDelta, -10.0, 15.0) * 16.0 + (rsiValue > rsiValue[1] ? 4.0 : 0.0)
sellMomentumScore = scale01(sellRsiDelta, -10.0, 15.0) * 16.0 + (rsiValue < rsiValue[1] ? 4.0 : 0.0)

diTotal = math.max(plusDI + minusDI, 0.0001)
buyDiDominance = clamp((plusDI - minusDI) / diTotal, 0.0, 1.0)
sellDiDominance = clamp((minusDI - plusDI) / diTotal, 0.0, 1.0)
buyTrendScore = plusDI > minusDI ? 6.0 + scale01(adxValue, signalProfile == "Responsive" ? 18.0 : signalProfile == "Selective" ? 25.0 : 20.0, signalProfile == "Responsive" ? 18.0 : signalProfile == "Selective" ? 25.0 : 20.0 + 25.0) * 8.0 + buyDiDominance * 4.0 + (adxValue > adxValue[1] ? 2.0 : 0.0) : 0.0
sellTrendScore = minusDI > plusDI ? 6.0 + scale01(adxValue, signalProfile == "Responsive" ? 18.0 : signalProfile == "Selective" ? 25.0 : 20.0, signalProfile == "Responsive" ? 18.0 : signalProfile == "Selective" ? 25.0 : 20.0 + 25.0) * 8.0 + sellDiDominance * 4.0 + (adxValue > adxValue[1] ? 2.0 : 0.0) : 0.0

weakRegimeScore = signalProfile == "Responsive" ? 0.14 : signalProfile == "Selective" ? 0.28 : 0.20 > 0.0 ? scale01(normalizedWidth, 0.0, signalProfile == "Responsive" ? 0.14 : signalProfile == "Selective" ? 0.28 : 0.20) * 8.0 : 8.0
strongRegimeScore = 8.0 + scale01(normalizedWidth, signalProfile == "Responsive" ? 0.14 : signalProfile == "Selective" ? 0.28 : 0.20, signalProfile == "Responsive" ? 0.14 : signalProfile == "Selective" ? 0.28 : 0.20 + math.max(signalProfile == "Responsive" ? 0.14 : signalProfile == "Selective" ? 0.28 : 0.20 * 1.5, 0.25)) * 4.0 + (normalizedWidth > normalizedWidth[1] ? 3.0 : 0.0)
regimeScore = channelStrong ? strongRegimeScore : weakRegimeScore

relativeVolume = not na(volume) and not na(volumeMA) and volumeMA > 0.0 ? volume / volumeMA : na
participationScore = na(relativeVolume) ? 5.0 : scale01(relativeVolume, 0.70, 1.70) * 10.0

buyOpposingWick = (high - math.max(open, close)) / candleRange
sellOpposingWick = (math.min(open, close) - low) / candleRange
sslExtension = atrValue > 0.0 ? math.abs(close - sslLine) / atrValue : 0.0
buyRiskPenalty = buyOpposingWick * 4.0 + scale01(sslExtension, 1.75, 3.50) * 6.0
sellRiskPenalty = sellOpposingWick * 4.0 + scale01(sslExtension, 1.75, 3.50) * 6.0


sslState(int length, string type) =>
    highMA = MA(high, length, type)
    lowMA = MA(low, length, type)
    var int state = 1
    state := close > highMA ? 1 : close < lowMA ? -1 : nz(state[1], 1)
    state

htfValid = timeframe.in_seconds(htfTimeframe) > timeframe.in_seconds()

int htfState = request.security(syminfo.tickerid, htfTimeframe, sslState(sslLength, maType)[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
buyHTFConfirmed = not useHTF or (htfValid and htfState == 1)
sellHTFConfirmed = not useHTF or (htfValid and htfState == -1)

buyLocalContext = (sslLine > sslLine[1] ? 5.0 : 0.0) + scale01(atrValue > 0.0 ? math.max(close - sslLine, 0.0) / atrValue : 0.0, 0.0, 1.0) * 5.0
sellLocalContext = (sslLine < sslLine[1] ? 5.0 : 0.0) + scale01(atrValue > 0.0 ? math.max(sslLine - close, 0.0) / atrValue : 0.0, 0.0, 1.0) * 5.0
buyContextScore = useHTF ? (htfValid and htfState == 1 ? 10.0 : 0.0) : buyLocalContext
sellContextScore = useHTF ? (htfValid and htfState == -1 ? 10.0 : 0.0) : sellLocalContext

buyRawScore = buyTransitionScore + buyMomentumScore + buyTrendScore + regimeScore + participationScore + buyContextScore - buyRiskPenalty
sellRawScore = sellTransitionScore + sellMomentumScore + sellTrendScore + regimeScore + participationScore + sellContextScore - sellRiskPenalty
buyScore = int(math.round(clamp(buyRawScore, 0.0, 100.0)))
sellScore = int(math.round(clamp(sellRawScore, 0.0, 100.0)))
bullishLiveRaw = buyMomentumScore + buyTrendScore + regimeScore + participationScore + buyContextScore - buyRiskPenalty
bearishLiveRaw = sellMomentumScore + sellTrendScore + regimeScore + participationScore + sellContextScore - sellRiskPenalty
currentQuality = int(math.round(clamp((sslState == 1 ? bullishLiveRaw : bearishLiveRaw) / 75.0 * 100.0, 0.0, 100.0)))


buySignal = flipUp and buyConfirmations and buyHTFConfirmed and buyScore >= (signalProfile == "Responsive" ? 65 : signalProfile == "Selective" ? 80 : 70)
sellSignal = flipDown and sellConfirmations and sellHTFConfirmed and sellScore >= (signalProfile == "Responsive" ? 65 : signalProfile == "Selective" ? 80 : 70)

htfAligned = useHTF and htfValid and sslState == htfState
newHTFAlignment = barstate.isconfirmed and htfAligned and not htfAligned[1]
trendWeakening = barstate.isconfirmed and (ta.crossunder(normalizedWidth, (signalProfile == "Responsive" ? 0.14 : signalProfile == "Selective" ? 0.28 : 0.20)) or ta.crossunder(adxValue, (signalProfile == "Responsive" ? 18.0 : signalProfile == "Selective" ? 25.0 : 20.0)))


//Plot
stateColor = sslState == 1 ? #00D5FF : #FF477E
boundaryColor = color.from_gradient(math.min(normalizedWidth, 1.0), 0.0, 1.0, color.new(#765CF6, 58), color.new(stateColor, 12))
strongTransparency = math.max(82 - 18, 0)
softTransparency = math.min(82 + 14, 100)
gradientTop = sslState == -1 ? color.new(#FF477E, strongTransparency) : color.new(#765CF6, softTransparency)
gradientBottom = sslState == 1 ? color.new(#00D5FF, strongTransparency) : color.new(#765CF6, softTransparency)
trendTransition = not na(sslState[1]) and sslState != sslState[1]
visualSSL = trendTransition ? na : sslLine
visualHighMA = trendTransition ? na : highMA
visualLowMA = trendTransition ? na : lowMA

plot(visualSSL, "SSL Line", color=stateColor, linewidth=2, style=plot.style_linebr)
plot(visualHighMA , "High Boundary Glow", color=color.new(boundaryColor, 88), linewidth=5, style=plot.style_linebr)
plot(visualLowMA , "Low Boundary Glow", color=color.new(boundaryColor, 88), linewidth=5, style=plot.style_linebr)
highPlot = plot(visualHighMA , "High MA", color=color.new(boundaryColor, 12), linewidth=1, style=plot.style_linebr)
lowPlot = plot(visualLowMA , "Low MA", color=color.new(boundaryColor, 12), linewidth=1, style=plot.style_linebr)

fill(highPlot, lowPlot, visualHighMA, visualLowMA, gradientTop , gradientBottom , title="SSL Native Gradient")

buyMarkerY = low - atrValue * 1.05
sellMarkerY = high + atrValue * 1.05
buyLabelY = low - atrValue * (1.05 + 0.25)
sellLabelY = high + atrValue * (1.05 + 0.25)

plotshape(showSignals and buySignal ? buyMarkerY : na, title="BUY Marker", style=shape.triangleup, location=location.absolute, color=#00D5FF, size=size.small)
plotshape(showSignals and sellSignal ? sellMarkerY : na, title="SELL Marker", style=shape.triangledown, location=location.absolute, color=#FF477E, size=size.small)

if showSignals and buySignal
    label.new(bar_index, buyLabelY, "BUY  •  " + grade(buyScore) + "  •  " + str.tostring(buyScore) + "%", yloc=yloc.price, style=label.style_label_up, color=color.new(#00D5FF, 8), textcolor=#06131A, size=size.small)

if showSignals and sellSignal
    label.new(bar_index, sellLabelY, "SELL  •  " + grade(sellScore) + "  •  " + str.tostring(sellScore) + "%", yloc=yloc.price, style=label.style_label_down, color=color.new(#FF477E, 8), textcolor=color.white, size=size.small)


alertcondition(flipUp, "SSL Trend Flip Up", "{{ticker}} | {{interval}} | SSL Trend Flip Up | Confidence: {{plot(\"Trend Confidence\")}}%")
alertcondition(flipDown, "SSL Trend Flip Down", "{{ticker}} | {{interval}} | SSL Trend Flip Down | Confidence: {{plot(\"Trend Confidence\")}}%")
alertcondition(buySignal, "Confirmed BUY Signal", "{{ticker}} | {{interval}} | Confirmed BUY | Confidence: {{plot(\"Buy Score\")}}%")
alertcondition(sellSignal, "Confirmed SELL Signal", "{{ticker}} | {{interval}} | Confirmed SELL | Confidence: {{plot(\"Sell Score\")}}%")
alertcondition(newHTFAlignment, "HTF Alignment", "{{ticker}} | {{interval}} | HTF Alignment | Confidence: {{plot(\"Trend Confidence\")}}%")
alertcondition(trendWeakening, "Trend Weakening", "{{ticker}} | {{interval}} | Trend Weakening | Confidence: {{plot(\"Trend Confidence\")}}%")
````
