# Nexus Sentiment & Risk Matrix [Pineify]

- url: https://www.tradingview.com/script/RbhXCF0u-Nexus-Sentiment-Risk-Matrix-Pineify/
- type: indicator
- pine_id: PUB;07c439bcb6594d6bbbd6695563921e1d
- version: 1.0

## Description

[b]Nexus Sentiment and Chandelier Risk Matrix [Pineify][/b]

Nexus Sentiment and Chandelier Risk Matrix blends a three-oscillator momentum score with a Chandelier-style ATR risk state. RSI, smoothed Stochastic, and normalized CCI form one 0-100 sentiment line; BUY/SELL markers appear only when that line agrees with a fresh risk flip.

[b]Key Features[/b]

[list]
[*]Composite sentiment from RSI, Stochastic, and CCI.

[*]Chandelier risk direction used as a signal filter.

[*]Gradient fills around the 50 equilibrium level.

[*]Alerts for bullish and bearish alignment events.
[/list]

[b]How It Works[/b]

[list=1]
[*]The script calculates [i]RSI[/i], 3-bar smoothed [i]Stochastic[/i], and [i]CCI[/i] with one oscillator length.

[*]CCI is clipped around +100/-100 and remapped to 0-100 so it can be averaged with the other oscillators.

[*]The average becomes the sentiment line. Above 50 suggests bullish pressure; below 50 suggests bearish pressure.

[*]The risk layer uses ATR and recent extremes to maintain a persistent direction.

[*]A BUY needs an upward risk flip above 50. A SELL needs a downward flip below 50.
[/list]

[b]How the Components Work Together[/b]

The oscillator stack gives context but does not trigger trades alone. RSI tracks relative strength, Stochastic checks close location inside the recent range, and CCI adds a deviation-from-mean view.

The Chandelier layer adds volatility-aware confirmation. Instead of reacting to every move through 50, the script waits for an ATR threshold break. This may filter weak bounces, but it can enter late on sharp reversals.

[b]Trading Ideas and Insights[/b]

[list]
[*]A BUY after a pullback may indicate risk shifting back up above 50.

[*]A SELL below 50 can warn that bearish pressure and ATR risk are aligned.

[*]If price makes a new high while sentiment fades, consider waiting for stronger follow-through.
[/list]

[b]Unique Aspects[/b]

[list]
[*]Three different momentum tools are normalized into one readable sentiment line.

[*]Signals are event-based, so markers do not repeat while the same condition remains active.
[/list]

[b]How to Use[/b]

[list=1]
[*]Add the indicator and watch the line around 50.

[*]Read green zones as bullish pressure and red zones as bearish pressure.

[*]Treat markers as confluence events, then confirm with structure, volume, or higher timeframe.

[*]Use the built-in alert conditions for notifications.
[/list]

[b]Customization[/b]

[list]
[*][b]Oscillator Length[/b] (default: 14) - Higher values smooth the line; lower values react faster.

[*][b]ATR Length[/b] (default: 22) - Sets the volatility lookback.

[*][b]ATR Multiplier[/b] (default: 3.0) - Larger values reduce flips but add lag; smaller values can whipsaw.
[/list]

[b]Conclusion[/b]

This is a compact sentiment-and-risk panel for traders who want oscillator context filtered through ATR direction. Signals may help identify regime changes, but they still need price-action and risk checks.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Pineify

//======================================================================//
//                    ____  _            _  __                          //
//                   |  _ \(_)_ __   ___(_)/ _|_   _                    //
//                   | |_) | | '_ \ / _ \ | |_| | | |                   //
//                   |  __/| | | | |  __/ |  _| |_| |                   //
//                   |_|   |_|_| |_|\___|_|_|  \__, |                   //
//                                             |___/                    //
//======================================================================//
//
//
// Nexus Sentiment & Risk Matrix [Pineify]
// ---------------------------------------
// This indicator blends three bounded sentiment readings with a Chandelier-style
// ATR risk model. The oscillator shows whether momentum pressure is above or
// below equilibrium, while signals only appear when the risk model flips in the
// same direction as the sentiment regime.
//
// Key concepts:
//   1. Composite sentiment - RSI, Stochastic, and normalized CCI are averaged
//      into one 0-100 momentum score.
//   2. Risk direction - ATR bands around recent extremes define risk-on and
//      risk-off flips.
//   3. Alignment signals - entries require both a risk-state change and
//      sentiment confirmation.

//@version=6
indicator("Nexus Sentiment & Risk Matrix [Pineify]", shorttitle="Nexus S&R [Pineify]", overlay=false)

//---------------------------------------------------------------------------------------------------------------------}
// INPUT SETTINGS
//---------------------------------------------------------------------------------------------------------------------{
grpSent = "Sentiment Settings"
len = input.int(14, "Oscillator Length", minval=1, group=grpSent, tooltip="Shared lookback for RSI, Stochastic, and CCI. Higher values smooth the sentiment score; lower values make it react faster.")

grpRisk = "Risk (Chandelier) Settings"
atrLen = input.int(22, "ATR Length", minval=1, group=grpRisk, tooltip="Lookback used for ATR and recent high/low anchors in the Chandelier risk model. Longer values make risk flips slower.")
atrMult = input.float(3.0, "ATR Multiplier", minval=0.1, step=0.1, group=grpRisk, tooltip="Distance of the Chandelier levels from recent extremes. Higher values reduce whipsaws but delay risk-state changes.")

//---------------------------------------------------------------------------------------------------------------------}
// CALCULATIONS
//---------------------------------------------------------------------------------------------------------------------{
// RSI contributes mean-reversion pressure, while Stochastic emphasizes close location
// inside the recent range. Using both helps avoid relying on one oscillator's bias.
rsiVal = ta.rsi(close, len)

// The 3-bar smoothing keeps Stochastic from dominating the composite during single-bar spikes.
stochVal = ta.sma(ta.stoch(close, high, low, len), 3)

// CCI is clipped to its common +/-100 decision zone and remapped to 0-100 so it can be
// averaged with the bounded RSI and Stochastic series without changing their scale.
cciRaw = ta.cci(close, len)
cciNorm = cciRaw > 100 ? 100 : cciRaw < -100 ? 0 : (cciRaw + 100) / 2

// The composite score treats agreement across the three oscillators as a stronger
// sentiment reading than any single component on its own.
sentiment = math.avg(rsiVal, stochVal, cciNorm)

// The Chandelier model places volatility-adjusted thresholds around recent extremes.
// A close through the opposite threshold marks a risk-state flip rather than a simple
// oscillator crossover. [Source: Chandelier Exit concept]
atrValue = ta.atr(atrLen)
highestHigh = ta.highest(high, atrLen)
lowestLow = ta.lowest(low, atrLen)

chandLong = highestHigh - atrValue * atrMult
chandShort = lowestLow + atrValue * atrMult

// Risk direction is persistent between flips, which reduces noise from bars that sit
// between the long and short Chandelier levels.
var int riskDir = 1
riskDir := close > nz(chandShort, high) ? 1 : close < nz(chandLong, low) ? -1 : riskDir

//---------------------------------------------------------------------------------------------------------------------}
// PLOTTING & AESTHETICS
//---------------------------------------------------------------------------------------------------------------------{
bullColor = #089981
bearColor = #f23645
neutralColor = #787b86

// Coloring the line by its 0-100 position makes the panel readable at a glance:
// deep red near sentiment lows, green near sentiment highs, and muted near balance.
sentColor = color.from_gradient(sentiment, 0, 100, bearColor, bullColor)

pMid = plot(50, title="Equilibrium Level", color=color.new(neutralColor, 50), style=plot.style_line)
pSent = plot(sentiment, title="Nexus Sentiment", color=sentColor, linewidth=2)

// The fills emphasize whether the composite is above or below the 50 equilibrium line
// without adding extra signal rules.
fill(pSent, pMid, top_value=math.max(sentiment, 50), bottom_value=50, 
     top_color=color.new(bullColor, 70), bottom_color=color.new(bullColor, 90), 
     title="Bullish Zone")

fill(pMid, pSent, top_value=50, bottom_value=math.min(sentiment, 50), 
     top_color=color.new(bearColor, 90), bottom_color=color.new(bearColor, 70), 
     title="Bearish Zone")

//---------------------------------------------------------------------------------------------------------------------}
// SIGNALS
//---------------------------------------------------------------------------------------------------------------------{
// A signal requires a fresh Chandelier risk flip plus sentiment on the same side of
// equilibrium. This avoids firing on oscillator movement alone, but it can still lag
// during fast reversals because the ATR state must change first.
buySignal = ta.change(riskDir) > 0 and sentiment > 50
sellSignal = ta.change(riskDir) < 0 and sentiment < 50

plotshape(buySignal, title="Risk On / Buy", text="BUY", style=shape.triangleup, 
     location=location.bottom, color=bullColor, textcolor=bullColor, size=size.small)

plotshape(sellSignal, title="Risk Off / Sell", text="SELL", style=shape.triangledown, 
     location=location.top, color=bearColor, textcolor=bearColor, size=size.small)

alertcondition(buySignal, title="Nexus Buy Signal", 
     message="Risk-On: Bullish Sentiment & Risk metrics aligned.")
alertcondition(sellSignal, title="Nexus Sell Signal", 
     message="Risk-Off: Bearish Sentiment & Risk metrics aligned.")
//---------------------------------------------------------------------------------------------------------------------}
````
