# Andean Oscillator Pro

- url: https://www.tradingview.com/script/6qo3i3Ke-Andean-Oscillator-Pro/
- type: indicator
- pine_id: PUB;4c9767f0aaae45f693dda4c9986c7f90
- version: 2.0

## Description

Full credit to alexgrover for the Andean Oscillator, which this is built on.
Original script: https://www.tradingview.com/script/x9qYvBYN-Andean-Oscillator/
Original writeup: alpaca.markets/learn/andean-oscillator-a-new-technical-indicator-based-on-an-online-algorithm-for-trend-analysis/

WHAT THE ORIGINAL MEASURES

The oscillator tracks two exponential envelopes, one on price and one on price
squared. Differencing them recovers a standard deviation for each direction of
travel. The bull component grows as price pulls away above its lower envelope. The
bear component grows as price pulls away below its upper envelope. Whichever is
larger tells you which side is doing the work, and how hard.

The important thing to understand about this family of readings is that it is a
measure of distance already travelled. It cannot be large until a move has already
happened. That shapes everything about how you use it.

WHAT THIS VERSION ADDS

Adaptive envelope decay. The original decays its envelopes at a fixed rate set by one
length input. This version computes an efficiency ratio over a lookback and slides the
decay rate between a fast bound and a slow bound. In a clean directional move the
envelope forgets old extremes quickly, so the reading responds sooner. In chop it
slows back down to roughly the original behaviour. ER Power controls how much trend
quality it demands before speeding up.

Normalization. The raw components come out in price units, which means a threshold you
find on one symbol is meaningless on another. Percent mode expresses them as a share of
price. ATR mode expresses them in volatility units. Either way your settings travel.

Energy gate. The original compares the components to their own moving average, which
costs you several bars of lag. This version ranks the larger component as a percentile
of its own recent history instead. There is no smoothing involved, so it reacts the
moment expansion starts, and the number means the same thing on every instrument. A
gate of 90 means you only act on readings in the top tenth of what this market
normally produces.

Deadband with hysteresis. Entry requires the spread between the two components to
clear a percentile band. Exit only requires the spread to change sign. That asymmetry
is what lets the faster envelope run without producing constant flips around the zero
line.

Trade management on the chart. When bias flips, the script marks the entry and places
a stop at a multiple of ATR, both drawn on the price chart. Once price has moved a set
distance in your favour the stop jumps to just past your cost, then a chandelier trail
arms and ratchets in one direction only. It never loosens. The trade ends at that stop
or on an opposite signal, which closes and reverses. Stop colour tells you the state
at a glance. Red is the initial stop, orange means breakeven is locked, blue means the
trail is running.

Everything else. Optional squeeze filter requiring a quiet stretch before the gate
opens, the envelopes drawn on the price chart, bias shown three ways so you can read
direction without looking at numbers, and a single alert carrying entry, stop and
energy.

HOW TO READ IT

Green bars, green background, LONG label means the bull component leads and the gate
was open when it flipped. Red is the reverse. Grey bars mean no position. The two
faint black lines in the pane are the deadband, so you can see how far the spread has
to travel before a flip qualifies. Fill intensity between the components tracks
energy, so a washed out fill means the market is quiet by its own standards even if
the components have crossed.

Orange dots along the bottom mark bars where the gate is open but no bias has been
established yet. Think of those as armed and waiting.

SETTINGS

Energy Gate is the one that matters. It sets how selective the entries are, and
nothing else in the script changes behaviour as much. Raise it for fewer and larger
setups, lower it for more frequent ones. Expect a high gate to feel quiet. That is the
setting working.

Stop, breakeven and trail distances are all measured in ATR rather than in R, and that
is deliberate. Denominating protection distance in R ties how far you wait before
protecting profit to how far you are willing to be wrong, and those two should move
independently.

Defaults are set for 15 minute crypto. Presets are included for 5 minute and 1 hour.

Published open source under CC BY-NC-SA 4.0, same license as the original.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MonkeyPhone
//
// Based on "Andean Oscillator" by alexgrover
// https://www.tradingview.com/script/x9qYvBYN-Andean-Oscillator/
// Original post: alpaca.markets/learn/andean-oscillator-a-new-technical-indicator-based-on-an-online-algorithm-for-trend-analysis/

//@version=6
indicator('Andean Oscillator Pro', shorttitle='Andean Pro', precision=3)

// ---------------- signal inputs ----------------
gS       = 'Signal'
fastL    = input.int(8, 'Fast Length', minval=2, group=gS)
slowL    = input.int(60, 'Slow Length', minval=2, group=gS)
erLen    = input.int(20, 'Efficiency Lookback', minval=2, group=gS)
erPow    = input.float(0.7, 'ER Power', minval=0.5, maxval=3.0, step=0.1, group=gS)
sigLen   = input.int(9, 'Signal Length', minval=1, group=gS)
normMode = input.string('Percent', 'Normalize', options=['Percent', 'ATR', 'Raw'], group=gS)
atrLen   = input.int(14, 'ATR Length', minval=1, group=gS)
engLen   = input.int(100, 'Energy Lookback', minval=20, group=gS)
gateThr  = input.float(90, 'Energy Gate', minval=0, maxval=100, step=5, group=gS)
useSqz   = input.bool(false, 'Require Prior Squeeze', group=gS)
sqzLook  = input.int(20, 'Squeeze Lookback', minval=2, group=gS)
sqzThr   = input.float(30, 'Squeeze Threshold', minval=0, maxval=100, step=5, group=gS)
bandPct  = input.float(20, 'Deadband Percentile', minval=0, maxval=90, step=5, group=gS)
minAtrP  = input.float(0.03, 'Min ATR % Of Price', minval=0.0, step=0.01, group=gS)

// ---------------- trade inputs ----------------
gT       = 'Trade Management'
preset   = input.string('15 Minute', 'ATR Preset', options=['5 Minute', '15 Minute', '1 Hour', 'Custom'], group=gT)
trigUnit = input.string('ATR', 'Trigger Unit', options=['ATR', 'R'], group=gT)
cStop    = input.float(3.0, 'Custom Stop x ATR', minval=0.2, step=0.1, group=gT)
cBE      = input.float(6.0, 'Custom Breakeven Trigger', minval=0.2, step=0.1, group=gT)
cTrail   = input.float(9.0, 'Custom Trail Trigger', minval=0.2, step=0.1, group=gT)
chanMult = input.float(2.0, 'Chandelier x ATR', minval=0.2, step=0.1, group=gT)
feeSide  = input.float(0.02, 'Fee + Slip Per Side %', minval=0.0, step=0.01, group=gT)
consEx   = input.bool(true, 'Instant-Trigger Exit', group=gT, tooltip='When the ratcheted stop lands beyond the bar close, placing it would trigger immediately and fill at the close rather than at the level. This books that. The ordinary stop test already uses the previous bar\'s level, which is the one actually resting on the exchange, and needs no adjustment.')
showTrade = input.bool(true, 'Show Stop / Entry Lines', group=gT)

// ---------------- display inputs ----------------
gD       = 'Display'
showHist = input.bool(true, 'Spread Histogram', group=gD)
showBg   = input.bool(true, 'Bias Background', group=gD)
showBars = input.bool(true, 'Color Price Bars', group=gD)
showEnv  = input.bool(true, 'Envelopes On Chart', group=gD)

// ---------------- adaptive alpha ----------------
C = close
O = open
fastA = 2.0 / (fastL + 1)
slowA = 2.0 / (slowL + 1)
er    = math.abs(C - C[erLen]) / math.max(math.sum(math.abs(nz(ta.change(C))), erLen), syminfo.mintick)
alpha = slowA + math.pow(math.min(nz(er), 1.0), erPow) * (fastA - slowA)

// ---------------- envelopes ----------------
var up1 = 0., var up2 = 0.
var dn1 = 0., var dn2 = 0.
up1 := nz(math.max(C, O, up1[1] - (up1[1] - C) * alpha), C)
up2 := nz(math.max(C * C, O * O, up2[1] - (up2[1] - C * C) * alpha), C * C)
dn1 := nz(math.min(C, O, dn1[1] + (C - dn1[1]) * alpha), C)
dn2 := nz(math.min(C * C, O * O, dn2[1] + (C * C - dn2[1]) * alpha), C * C)

bullRaw = math.sqrt(math.max(dn2 - dn1 * dn1, 0))
bearRaw = math.sqrt(math.max(up2 - up1 * up1, 0))

// ---------------- normalize + state ----------------
atrRaw = nz(ta.atr(atrLen))
atrNow = math.max(atrRaw, minAtrP / 100 * C, syminfo.mintick)
okBar  = atrRaw >= minAtrP / 100 * C and high > low

div    = normMode == 'ATR' ? atrNow : normMode == 'Percent' ? math.max(C, syminfo.mintick) / 100.0 : 1.0
bull   = bullRaw / div
bear   = bearRaw / div
amp    = math.max(bull, bear)
signal = ta.ema(amp, sigLen)
spread = bull - bear
energy = nz(ta.percentrank(amp, engLen))
band   = nz(ta.percentile_linear_interpolation(math.abs(spread), engLen, bandPct))
hot    = energy > gateThr
quiet  = ta.lowest(energy, sqzLook) < sqzThr
live   = hot and (not useSqz or quiet)

var int bias = 0
bias := live and spread > band ? 1 : live and spread < -band ? -1 : bias[1] == 1 and spread > 0 ? 1 : bias[1] == -1 and spread < 0 ? -1 : 0
flipUp = bias == 1 and bias[1] != 1 and okBar
flipDn = bias == -1 and bias[1] != -1 and okBar

// ---------------- trade management ----------------
stopMult = preset == '5 Minute' ? 3.0 : preset == '15 Minute' ? 3.0 : preset == '1 Hour' ? 1.5 : cStop
beTrig   = preset == '5 Minute' ? 6.0 : preset == '15 Minute' ? 6.0 : preset == '1 Hour' ? 6.0 : cBE
trTrig   = preset == '5 Minute' ? 9.0 : preset == '15 Minute' ? 9.0 : preset == '1 Hour' ? 9.0 : cTrail

var int   pos    = 0
var float entryP = na
var float stopP  = na
var float riskU  = na
var float mfeP   = 0.
var float peak   = na
var bool  beOn   = false
var bool  trOn   = false

stopHit = not na(stopP) and ((pos == 1 and low <= stopP) or (pos == -1 and high >= stopP))
enterL  = flipUp and pos != 1
enterS  = flipDn and pos != -1
justIn  = enterL or enterS
posNew  = enterL ? 1 : enterS ? -1 : stopHit ? 0 : pos
stopMk  = stopHit and not justIn ? stopP : na

entryP := justIn ? C : posNew == 0 ? na : entryP
riskU  := justIn ? atrNow * stopMult : posNew == 0 ? na : riskU
peak   := justIn ? (enterL ? high : low) : posNew == 0 ? na : posNew == 1 ? math.max(nz(peak, high), high) : math.min(nz(peak, low), low)
mfeP   := justIn ? 0. : posNew == 0 ? 0. : math.max(nz(mfeP), posNew == 1 ? high - entryP : entryP - low)
unitPx  = trigUnit == 'R' ? math.max(nz(riskU, atrNow), syminfo.mintick) : atrNow
mfeU    = mfeP / unitPx
beOn   := justIn ? false : posNew == 0 ? false : beOn or mfeU >= beTrig
trOn   := justIn ? false : posNew == 0 ? false : trOn or mfeU >= trTrig

cush   = 2 * nz(entryP) * feeSide / 100 + 0.1 * nz(riskU)
beLvl  = posNew == 1 ? entryP + cush : entryP - cush
initSt = posNew == 1 ? entryP - riskU : entryP + riskU
trLvl  = posNew == 1 ? peak - chanMult * atrNow : peak + chanMult * atrNow

// The stop that could fire DURING this bar is the one carried in from the last
// bar, and stopHit above already tests exactly that. A level computed from this
// bar's own extreme did not exist while the bar was forming, so it cannot fire
// inside it. What can happen is that the ratcheted level lands beyond the close:
// placing that stop triggers it at once, and the fill is the close, not the
// level. That is adverse, and consHit books it at the close.
stopRat = posNew == 0 ? na : justIn ? initSt : posNew == 1 ? math.max(nz(stopP, initSt), beOn ? beLvl : initSt, trOn ? trLvl : initSt) : math.min(nz(stopP, initSt), beOn ? beLvl : initSt, trOn ? trLvl : initSt)
consHit = consEx and posNew != 0 and not justIn and not na(stopRat) and ((posNew == 1 and close < stopRat) or (posNew == -1 and close > stopRat))
consMk  = consHit ? close : na
stopP  := consHit ? na : stopRat
pos    := consHit ? 0 : posNew

// Drawn while a position is open AND on the bar that closes it, so the line runs
// into its own exit marker instead of stopping a bar short.
stopDraw = pos != 0 ? stopP : consHit ? consMk : not na(stopMk) ? stopMk : na

// ---------------- colors ----------------
cBull = #089981
cBear = #f23645
cSig  = #ff9800
cTrl  = #2962ff
hCol  = spread > 0 and hot ? color.new(cBull, 20) : spread > 0 ? color.new(cBull, 78) : hot ? color.new(cBear, 20) : color.new(cBear, 78)
fCol  = spread > 0 ? color.from_gradient(energy, 0, 100, color.new(cBull, 93), color.new(cBull, 55)) : color.from_gradient(energy, 0, 100, color.new(cBear, 93), color.new(cBear, 55))
sCol  = trOn ? cTrl : beOn ? cSig : cBear

// ---------------- oscillator plots ----------------
plot(showHist ? spread : na, 'Spread', hCol, 1, plot.style_columns)
pB = plot(bull, 'Bullish', bias == 1 ? cBull : color.new(cBull, 50), 2)
pR = plot(bear, 'Bearish', bias == -1 ? cBear : color.new(cBear, 50), 2)
plot(signal, 'Signal', color.new(cSig, 35), 1)
plot(showHist ? band : na, 'Deadband +', color.new(color.black, 70), 1)
plot(showHist ? -band : na, 'Deadband -', color.new(color.black, 70), 1)
fill(pB, pR, fCol, 'Bias Fill')
hline(0, 'Zero', color.new(color.black, 55))
plotshape(live and bias == 0, title='Armed', style=shape.circle, location=location.bottom, color=color.new(cSig, 30), size=size.tiny)

bgcolor(showBg and bias == 1 ? color.new(cBull, 88) : showBg and bias == -1 ? color.new(cBear, 88) : na, title='Bias BG')
barcolor(not showBars ? na : bias == 1 ? cBull : bias == -1 ? cBear : color.new(color.gray, 35), title='Bias Bars')

// ---------------- chart plots ----------------
plot(showEnv ? up1 : na, 'Upper Envelope', color.new(cBear, 25), 1, force_overlay=true)
plot(showEnv ? dn1 : na, 'Lower Envelope', color.new(cBull, 25), 1, force_overlay=true)
plot(showTrade ? stopDraw : na, 'Stop', sCol, 2, plot.style_linebr, force_overlay=true)
plot(showTrade and pos != 0 ? entryP : na, 'Entry', color.new(color.black, 40), 1, plot.style_linebr, force_overlay=true)
plotshape(showTrade ? stopMk : na, title='Stop Out', style=shape.xcross, location=location.absolute, color=color.new(color.black, 10), size=size.tiny, force_overlay=true)
plotshape(showTrade ? consMk : na, title='Instant-Trigger Exit', style=shape.diamond, location=location.absolute, color=color.new(cTrl, 10), size=size.tiny, force_overlay=true)

plotshape(flipUp, title='Long Flip', style=shape.labelup, location=location.bottom, color=cBull, text='LONG', textcolor=color.black, size=size.tiny)
plotshape(flipDn, title='Short Flip', style=shape.labeldown, location=location.top, color=cBear, text='SHORT', textcolor=color.black, size=size.tiny)

// ---------------- alerts ----------------
if enterL or enterS
    alert('ANDEAN ' + (enterL ? 'LONG' : 'SHORT') + ' ' + syminfo.ticker + ' ' + timeframe.period + ' | entry ' + str.tostring(entryP, format.mintick) + ' | stop ' + str.tostring(stopP, format.mintick) + ' | energy ' + str.tostring(energy, '#'), alert.freq_once_per_bar_close)

    if (stopHit and not justIn) or consHit
        alert('ANDEAN EXIT ' + syminfo.ticker + ' ' + timeframe.period + ' | ' + (consHit ? 'instant trigger at close ' : 'stop hit ') + str.tostring(consHit ? consMk : stopMk, format.mintick) + (trOn ? ' (trail)' : beOn ? ' (breakeven)' : ' (initial)'), alert.freq_once_per_bar_close)
````
