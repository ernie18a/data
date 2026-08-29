<!-- tradingview-pine-id: PUB;i5srGX3FvYvYllkJmZBzd40M1PweXurf -->
<!-- tradingviewscripts-format: 1 -->
# Bayesian BBSMA Oscillator

Source: https://www.tradingview.com/script/8lXcviYm-Bayesian-BBSMA-Oscillator/

## Description

Sometime ago (very long ago), one of my tinkering project was to do a spam or ham classification type app to filter news I'd wanna read. So I built myself a Naive Bayes Classifier to feed me my relevant articles. It worked great, I can cut through the noise.

The hassle was I needed to manually train it to understand what I wanna read. I trained it using 50 articles and to my surprise, it's enough.

Complexity Theory

I've been reading a book called The Road to Ruin by Jim Rickards. He described how he got to his conclusion of how the stock market works by using Complexity Theory. Bill Williams would agree. Jim tells us that by using just enough data, we calculate the probability of an event to occur. We can't say for sure when but we know it's coming. This was my light bulb moment.

While Jim talks much about Bayesian Inference in which a probability of an event can always be updated as more evidence comes to light, I had my eyes set on binary probabilities of when prices are going up and down.

Assumptions

These are my assumptions:

[*]Prices breaking up a Bollinger basis line will have fuel to go up even higher[/*]
[*]Prices will go down when prices have broken up a Bollinger upper band[/*]
[*]Scalping is the main method so we should use a lower period Moving Average (MA)[/*]
[*]When prices are above MA, it's likelier a correction to the downside is imminent[/*]
[*]When prices are below MA, it's likelier a correction to the upside is imminent[/*]
[*]Optimize parameters for 1 hour timeframe which will give us time to react while still having more opportunities to trade[/*]

Building Blocks

Jim Rickards started with limited data (events) while in technical trading, data are plentiful. I decided to classify 2 events which are:

[*]Next candles would be breaking up[/*]
[*]Next candles would be breaking down[/*]

Key facts:

[*]We won't know for sure when prices are going to break[/*]
[*]We won't know for sure how much the prices movements are going to be[/*]

Formulas

Breaking up:

Pr(Up|Indicator) = Pr(Indicator|Up) * Pr(Up) / Pr(Indicator|Up) * Pr(Up) + Pr(Indicator|Down) * Pr(Down)

Breaking down:

Pr(Down|Indicator) = Pr(Indicator|Down) * Pr(Down) / Pr(Indicator|Down) * Pr(Down) + Pr(Indicator|Up) * Pr(Up)

Reading The Oscillator

[*]Green is the probability of prices breaking up[/*]
[*]Red is the probability of prices breaking down[/*]
[*]When either green or red is flatlining ceiling, immediately on the next candle when the probability decreases go short or long based on which direction you're observing - Strong Signal[/*]
[*]When either green or red is flatlining ceiling, take no action while it's ceiled[/*]
[*]Usually when either green or red is flatlining bottom, the next candle when the probability increases, immediately take a short long position based on the direction you're observing - Weak Signal[/*]
[*]When either green or red is flatlining bottom, take no action while it's bottomed[/*]

Alerts

Use Once per Bar option when generating alerts.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © tista

//@version=4
study("Bayesian BBSMA Oscillator", shorttitle="BayesBbSmaOsc")

bbSmaPeriod = input(20, title="BB SMA Period")
bbStdDevMult = input(2.5, title="BB Standard Deviation", maxval=50.0)

bbBasis = sma(close, bbSmaPeriod)
bbStdDev = bbStdDevMult * stdev(close, bbSmaPeriod)

bbUpper = bbBasis + bbStdDev
bbLower = bbBasis - bbStdDev

// AO
aoFast = input(5, "AO Fast EMA Length")
aoSlow = input(34, "AO Slow EMA Length")
ao = sma(hl2, aoFast) - sma(hl2, aoSlow)
colorAo = change(ao) > 0 ? color.green : color.red

// AC
acFast = input(5, "AC Fast SMA Length")
acSlow = input(34, "AC Slow SMA Length")
xSMA1_hl2 = sma(hl2, acFast)
xSMA2_hl2 = sma(hl2, acSlow)
xSMA1_SMA2 = xSMA1_hl2 - xSMA2_hl2
xSMA_hl2 = sma(xSMA1_SMA2, acFast)
ac =  xSMA1_SMA2 - xSMA_hl2
cClr = ac > ac[1] ? color.blue : color.red

acAo = (ac + ao) / 2

maAcAoPeriod = input(13, "AC AO MA Period")
showMaAcAo = input(false, "Show AC AO MA?")
maAcAo = vwma(acAo, maAcAoPeriod)

// Combine AC & AO
acIsBlue = ac > ac[1]
acIsRed = not (ac > ac[1])
aoIsGreen = change(ao) > 0
aoIsRed = not (change(ao) > 0)
acAoIsBullish = acIsBlue and aoIsGreen
acAoIsBearish = acIsRed and acIsRed
acAoColorIndex = acAoIsBullish ? 1 : acAoIsBearish ? -1 : 0

// Alligator
smma(src, length) =>
    smma = 0.0
    smma := na(smma[1]) ? sma(src, length) : (smma[1] * (length - 1) + src) / length
lipsLength  = input(title="🐲 Lips Length", defval=5)
teethLength = input(title="🐲 Teeth Length", defval=8)
jawLength   = input(title="🐲 Jaw Length", defval=13)
lipsOffset  = input(title="🐲 Lips Offset", defval=3)
teethOffset = input(title="🐲 Teeth Offset", defval=5)
jawOffset   = input(title="🐲 Jaw Offset", defval=8)
lips        = smma(hl2, lipsLength)
teeth       = smma(hl2, teethLength)
jaw         = smma(hl2, jawLength)

// SMA
smaPeriod = input(20, title="SMA Period")
smaValues = sma(close, smaPeriod)


// Bayesian Theorem Starts
bayesPeriod = input(20, title="Bayesian Lookback Period")

// Next candles are breaking Down
probBbUpperUpSeq = close > bbUpper ? 1 : 0
probBbUpperUp = sum(probBbUpperUpSeq, bayesPeriod) / bayesPeriod
probBbUpperDownSeq = close < bbUpper ? 1 : 0
probBbUpperDown = sum(probBbUpperDownSeq, bayesPeriod) / bayesPeriod

probUpBbUpper = probBbUpperUp / (probBbUpperUp + probBbUpperDown)

probBbBasisUpSeq = close > bbBasis ? 1 : 0
probBbBasisUp = sum(probBbBasisUpSeq, bayesPeriod) / bayesPeriod
probBbBasisDownSeq = close < bbBasis ? 1 : 0
probBbBasisDown = sum(probBbBasisDownSeq, bayesPeriod) / bayesPeriod

probUpBbBasis = probBbBasisUp / (probBbBasisUp + probBbBasisDown)

probSmaUpSeq = close > smaValues ? 1 : 0
probSmaUp = sum(probSmaUpSeq, bayesPeriod) / bayesPeriod
probSmaDownSeq = close < smaValues ? 1 : 0
probSmaDown = sum(probSmaDownSeq, bayesPeriod) / bayesPeriod

probUpSma = probSmaUp / (probSmaUp + probSmaDown)

sigmaProbsDown = nz(probUpBbUpper * probUpBbBasis * probUpSma / probUpBbUpper * probUpBbBasis * probUpSma + ((1 - probUpBbUpper) * (1 - probUpBbBasis) * (1 - probUpSma)))

// Next candles are breaking Up
probDownBbUpper = probBbUpperDown / (probBbUpperDown + probBbUpperUp)
probDownBbBasis = probBbBasisDown / (probBbBasisDown + probBbBasisUp)
probDownSma = probSmaDown / (probSmaDown + probSmaUp)

sigmaProbsUp = nz(probDownBbUpper * probDownBbBasis * probDownSma / probDownBbUpper * probDownBbBasis * probDownSma + ( (1 - probDownBbUpper) * (1 - probDownBbBasis) * (1 - probDownSma) ))

showNextCandleDown = input(true, title="Plot Next Candles Breaking Down?")
plot(showNextCandleDown ? sigmaProbsDown * 100 : na, title="Next Candle Breaking Down Probs", transp=0, color=color.red, linewidth=2)

showNextCandleUp = input(true, title="Plot Next Candles Breaking Up?")
plot(showNextCandleUp ? sigmaProbsUp * 100 : na, title="Next Candle Breaking Up Probs", transp=0, color=color.green, linewidth=2)

probPrime = nz(sigmaProbsDown * sigmaProbsUp / sigmaProbsDown * sigmaProbsUp + ( (1 - sigmaProbsDown) * (1 - sigmaProbsUp) ))

showPrime = input(true, title="Plot Prime Probability?")
plot(showPrime ? probPrime * 100 : na, title="Prime Probability", transp=0, color=color.blue, linewidth=2)

lowerThreshold = input(15.0, title="Lower Threshold")

sideways = probPrime < lowerThreshold / 100 and sigmaProbsUp < lowerThreshold / 100 and sigmaProbsDown < lowerThreshold / 100

longUsingProbPrime = probPrime > lowerThreshold / 100 and probPrime[1] == 0
longUsingSigmaProbsUp = sigmaProbsUp < 1 and sigmaProbsUp[1] == 1

shortUsingProbPrime = probPrime == 0 and probPrime[1] > lowerThreshold / 100
shortUsingSigmaProbsDown = sigmaProbsDown < 1 and sigmaProbsDown[1] == 1

milanIsRed = acAoColorIndex == -1
milanIsGreen = acAoColorIndex == 1
pricesAreMovingAwayUpFromAlligator = close > jaw and open > jaw
pricesAreMovingAwayDownFromAlligator = close < jaw and open < jaw

useBWConfirmation = input(false, title="Use Bill Williams indicators for confirmation?")

bwConfirmationUp = useBWConfirmation ? milanIsGreen and pricesAreMovingAwayUpFromAlligator : true
bwConfirmationDown = useBWConfirmation ? milanIsRed and pricesAreMovingAwayDownFromAlligator : true

longSignal = bwConfirmationUp and (longUsingProbPrime or longUsingSigmaProbsUp)
shortSignal = bwConfirmationDown and (shortUsingProbPrime or shortUsingSigmaProbsDown)

barcolor(longSignal ? color.lime : na, title="Long Bars")
barcolor(shortSignal ? color.maroon : na, title="Short Bars")

hzl3 = hline(lowerThreshold, color=#333333, linestyle=hline.style_solid)
hzl4 = hline(0, color=#333333, linestyle=hline.style_solid)
fill(hzl3, hzl4, title="Lower Threshold", color=sideways ? color.gray : color.maroon, transp=70)

alertcondition(longSignal, title="Long!", message="Bayesian BBSMA - LONG - {{exchange}}:{{ticker}} at {{close}}")
alertcondition(shortSignal, title="Short!", message="Bayesian BBSMA - SHORT - {{exchange}}:{{ticker}} at {{close}}")
````
