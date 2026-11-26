# Volume-Price Effort Signals

- url: https://www.tradingview.com/script/Lin0FJu4/
- type: indicator
- pine_id: PUB;9c87524f841e402ea8f4ecbe4c65f00c
- version: 1.0

## Description

量价关系

## Source Code

````pine
//@version=6
indicator("Volume-Price Effort Signals", overlay = true, max_labels_count = 500)
// ---------- Inputs ----------
groupBase = "Base"
volLen = input.int(20, "Volume SMA length", minval = 5, group = groupBase)
trendLen = input.int(60, "Trend lookback", minval = 20, group = groupBase)
keyLen = input.int(120, "Key position lookback", minval = 20, group = groupBase)
seqWindow = input.int(5, "Sequence window", minval = 1, maxval = 20, group = groupBase)
groupThresholds = "Thresholds"
highVol = input.float(1.8, "High volume multiple", minval = 1.0, step = 0.1, group = groupThresholds)
lowVol = input.float(0.8, "Low volume multiple", minval = 0.1, step = 0.1, group = groupThresholds)
smallMove = input.float(2.0, "Small move %", minval = 0.1, step = 0.1, group = groupThresholds)
largeMove = input.float(3.0, "Large move %", minval = 0.1, step = 0.1, group = groupThresholds)
nearExtreme = input.float(0.12, "Near 120-bar extreme", minval = 0.01, maxval = 0.5, step = 0.01, group = groupThresholds)
closePosBull = input.float(0.65, "Bull close position", minval = 0.5, maxval = 1.0, step = 0.05, group = groupThresholds)
closePosBear = input.float(0.35, "Bear close position", minval = 0.0, maxval = 0.5, step = 0.05, group = groupThresholds)
confirmMove = input.float(2.0, "Sequence confirm move %", minval = 0.1, step = 0.1, group = groupThresholds)
groupDisplay = "Display"
showBull = input.bool(true, "Show bullish signals", group = groupDisplay)
showBear = input.bool(true, "Show bearish signals", group = groupDisplay)
showSeq = input.bool(true, "Show sequence signals", group = groupDisplay)
// ---------- Core measures ----------
volMA = ta.sma(volume, volLen)
volRatio = volMA > 0 ? volume / volMA : na
retPct = close[1] != 0 ? (close / close[1] - 1.0) * 100.0 : na
barRange = high - low
closePos = barRange > 0 ? (close - low) / barRange : 0.5
lowN = ta.lowest(low, keyLen)
highN = ta.highest(high, keyLen)
nearLow = lowN > 0 ? close <= lowN * (1 + nearExtreme) : false
nearHigh = highN > 0 ? close >= highN * (1 - nearExtreme) : false
downTrend = close < close[trendLen]
upTrend = close > close[trendLen]
// ---------- Bullish signals ----------
// 1. High volume, little downside progress: selling effort is absorbed.
stoppingVolume = volRatio >= highVol and retPct >= -smallMove and retPct <= 0 and closePos >= closePosBull
// 2. Large upside move on light volume: price rises with little effort.
lowEffortRally = volRatio <= lowVol and retPct >= largeMove and closePos >= closePosBull
// 3. Supply exhaustion: volume dries up near a long-term low while downside stalls.
volFalling3 = volume < volume[1] and volume[1] < volume[2]
supplyExhaustion = downTrend and nearLow and volRatio <= lowVol and volFalling3 and retPct > -1.0 and closePos >= 0.6
// 4. Bullish sequence: prior absorption, then upward confirmation within a few bars.
barsSinceStopping = ta.barssince(stoppingVolume)
recentStopping = barsSinceStopping >= 1 and barsSinceStopping <= seqWindow
bullishConfirm = retPct >= confirmMove and close > high[1] and closePos >= closePosBull
bullishSequence = recentStopping and bullishConfirm and (nearLow or downTrend)
// ---------- Bearish signals ----------
// 5. High volume, little upside progress: buying effort is absorbed.
upthrust = volRatio >= highVol and retPct <= smallMove and retPct >= 0 and closePos <= closePosBear
// 6. Large downside move on light volume: price falls with little effort.
lowEffortDrop = volRatio <= lowVol and retPct <= -largeMove and closePos <= closePosBear
// 7. Weak rebound: price rebounds on light volume inside an existing downtrend.
weakRebound = downTrend and retPct >= largeMove and volRatio <= lowVol
// 8. Bearish sequence: prior buying failure, then downside confirmation within a few bars.
barsSinceUpthrust = ta.barssince(upthrust)
recentUpthrust = barsSinceUpthrust >= 1 and barsSinceUpthrust <= seqWindow
bearishConfirm = retPct <= -confirmMove and close < low[1] and closePos <= closePosBear
bearishSequence = recentUpthrust and bearishConfirm and (nearHigh or upTrend)
// ---------- Display priority ----------
// Keep one bullish and one bearish mark at most on the same bar.
showBullSeq = bullishSequence
showStopping = stoppingVolume and not showBullSeq
showLowEffortRally = lowEffortRally and not showBullSeq and not showStopping
showSupplyExhaustion = supplyExhaustion and not showBullSeq and not showStopping and not showLowEffortRally
showBearSeq = bearishSequence
showUpthrust = upthrust and not showBearSeq
showLowEffortDrop = lowEffortDrop and not showBearSeq and not showUpthrust
showWeakRebound = weakRebound and not showBearSeq and not showUpthrust and not showLowEffortDrop
// ---------- Plot ----------
plotshape(showBull and showStopping, title = "Stopping Volume", style = shape.circle, location = location.belowbar, color = color.rgb(28, 120, 55), size = size.tiny, text = "承接", textcolor = color.white)
plotshape(showBull and showLowEffortRally, title = "Low Effort Rally", style = shape.triangleup, location = location.belowbar, color = color.rgb(39, 174, 96), size = size.tiny, text = "轻涨", textcolor = color.white)
plotshape(showBull and showSupplyExhaustion, title = "Supply Exhaustion", style = shape.square, location = location.belowbar, color = color.rgb(113, 191, 86), size = size.tiny, text = "缩跌", textcolor = color.black)
plotshape(showBull and showSeq and showBullSeq, title = "Bullish Sequence", style = shape.labelup, location = location.belowbar, color = color.rgb(0, 150, 64), size = size.small, text = "反转", textcolor = color.white)
plotshape(showBear and showUpthrust, title = "Upthrust", style = shape.circle, location = location.abovebar, color = color.rgb(170, 25, 35), size = size.tiny, text = "滞涨", textcolor = color.white)
plotshape(showBear and showLowEffortDrop, title = "Low Effort Drop", style = shape.triangledown, location = location.abovebar, color = color.rgb(220, 53, 69), size = size.tiny, text = "轻跌", textcolor = color.white)
plotshape(showBear and showWeakRebound, title = "Weak Rebound", style = shape.square, location = location.abovebar, color = color.rgb(235, 95, 95), size = size.tiny, text = "弱反", textcolor = color.white)
plotshape(showBear and showSeq and showBearSeq, title = "Bearish Sequence", style = shape.labeldown, location = location.abovebar, color = color.rgb(200, 0, 35), size = size.small, text = "转弱", textcolor = color.white)
// ---------- Alerts ----------
alertcondition(stoppingVolume, "Stopping Volume", "Stopping Volume")
alertcondition(lowEffortRally, "Low Effort Rally", "Low Effort Rally")
alertcondition(supplyExhaustion, "Supply Exhaustion", "Supply Exhaustion")
alertcondition(bullishSequence, "Bullish Sequence", "Bullish Sequence")
alertcondition(upthrust, "Upthrust", "Upthrust")
alertcondition(lowEffortDrop, "Low Effort Drop", "Low Effort Drop")
alertcondition(weakRebound, "Weak Rebound", "Weak Rebound")
alertcondition(bearishSequence, "Bearish Sequence", "Bearish Sequence")
````
