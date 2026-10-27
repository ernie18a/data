# No-lose trading targets (Based on MFI) By Mustafa ÖZVER

- url: https://www.tradingview.com/script/JBTGDpDI/
- type: indicator
- pine_id: PUB;19ef8c6ff2cb4e90bcdf454b5b18263b
- version: 2.0

## Description

This code shows expected reaction target prices after sudden moving based on MFI . Red area means the price is on overbought area, green area means the price is on oversold area. If you see red area under price, you can make short option to next to the horizontal beginning price of red area. If you see green area over price, you can make long option to next to the horizontal beginning price of green area.

When this code works
- The green area starts where mfi value is on oversold
- The red area starts where mfi value is on overbought

Of course, this code may be failed, do not forget the target may never come. But hopefully price will cross over the target.
And you (as developers) can develop this code by using anything instead of mfi to get up-down target prices.

But only this values can not guarantee good results for trading. BE CAREFUL

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Mustafaozver

//@version=5
indicator('No-lose trading targets (Based on MFI) By Mustafa ÖZVER', 'NLTT_MFI', overlay=true)
ref = input(hlc3)

var line U_AREA_LINE = na
var line D_AREA_LINE = na
counter_succ = 0
counter_fail = 0
counter_succ := nz(counter_succ[1],0)
counter_fail := nz(counter_fail[1],0)

BUY__AREA = 0
SELL_AREA = 0

// mfi
FPrice = ta.wma(ref, 3)
FVolume = ta.wma(volume, 3)
len = input(17, 'Length')
limit = input(10, 'Limit')

// filteren price and volume calculation
change = ta.change(FPrice) * (FVolume > 0 ? FVolume : 1)
gain = change >= 0 ? change : 0.0
loss = change < 0 ? -1 * change : 0.0
avgGain = ta.rma(gain, len)
avgLoss = ta.rma(loss, len)
rs = avgGain / avgLoss
rsi = 100 - 100 / (1 + rs)

//rsi = mfi(ref)

higherpoint = ta.highest(high, len * 2)
lowerpoint = ta.lowest(low, len * 2)
Rational = (FPrice - lowerpoint) / (higherpoint - lowerpoint)

BUY__SIGNAL = rsi < limit and ta.change(rsi) > 0 and Rational < 0.4 ? 1 : 0
SELL_SIGNAL = rsi > 100 - limit and ta.change(rsi) > 0 and Rational > 0.6 ? 1 : 0

U_AREA_ = math.min(ohlc4, hlc3, hl2)//, open, close)
D_AREA_ = math.max(ohlc4, hlc3, hl2)//, open, close)

U_AREA = U_AREA_
D_AREA = D_AREA_

maxLine = high
minLine = low

BUY__AREA := nz(BUY__SIGNAL[1], 0) == 1 ? 1 : nz(BUY__AREA[1], 0) == 1 ? 1 : 0
SELL_AREA := nz(SELL_SIGNAL[1], 0) == 1 ? 1 : nz(SELL_AREA[1], 0) == 1 ? 1 : 0

U_AREA := SELL_AREA == 1 ? nz(U_AREA[1], U_AREA_) : U_AREA_
D_AREA := BUY__AREA == 1 ? nz(D_AREA[1], D_AREA_) : D_AREA_

maxLine := SELL_AREA == 1 ? math.max(nz(maxLine[1], 0), high) : high
minLine := BUY__AREA == 1 ? math.min(nz(minLine[1], 0), low) : low

refLine = plot(ref, color=#00000000, display=display.none, offset=1)
D_Line = plot(D_AREA, color=BUY__AREA == 1 ? #00FF00A0 : #00000000, linewidth=2, offset=2)
U_Line = plot(U_AREA, color=SELL_AREA == 1 ? #FF0000A0 : #00000000, linewidth=2, offset=2)

fibo_0236 = 0.23606797749979
fibo_0381 = 0.38196601125011
fibo_0500 = 0.5
fibo_0618 = 0.61803398874990
fibo_0763 = 0.76393202250021
fibo_1618 = 1.61803398874990

SelllineforBuying = fibo_0763 * (D_AREA - minLine) + minLine
BuylineforSelling = fibo_0236 * (maxLine - U_AREA) + U_AREA

//if (U_AREA < close)
//    line.set_x2(U_AREA_LINE,bar_index)

//if (D_AREA > close)
//    line.set_x2(D_AREA_LINE,bar_index)

if BUY__SIGNAL == 1 or nz(BuylineforSelling[1], low) > low or ta.barssince(SELL_AREA == 1) > 20
    SELL_AREA := 0
    counter_fail := counter_fail + 1

if SELL_SIGNAL == 1 or nz(SelllineforBuying[1], high) < high or ta.barssince(BUY__AREA == 1) > 20
    BUY__AREA := 0
    counter_fail := counter_fail + 1

if SELL_AREA == 0 and SELL_SIGNAL == 1
    U_AREA_LINE := line.new(bar_index, U_AREA, bar_index + 10, U_AREA, xloc.bar_index, extend.none, #FF0000A0, line.style_solid, 3)
    U_AREA_LINE

if BUY__AREA == 0 and BUY__SIGNAL == 1
    D_AREA_LINE := line.new(bar_index, D_AREA, bar_index + 10, D_AREA, xloc.bar_index, extend.none, #00FF00A0, line.style_solid, 3)
    D_AREA_LINE

//fill(D_Line, refLine, color=BUY__AREA==1?#00FF0020:#00000000)
//fill(U_Line, refLine, color=SELL_AREA==1?#FF000020:#00000000)

// draw fibonacci
max_ = BUY__AREA == 1 ? D_AREA : SELL_AREA == 1 ? maxLine : ref
min_ = SELL_AREA == 1 ? U_AREA : BUY__AREA == 1 ? minLine : ref

tolerance = input(0.003)
verify_Revision = ta.change(max_ + min_) == 0 and max_ / min_ > tolerance + 1
verify_Draw = (BUY__AREA == 1 or SELL_AREA == 1) and verify_Revision

Target_line_slope = 1.0 + tolerance
HMCiOH = math.min(86400000 / ta.change(time), 50)

fibo_0000_line = plot(min_, color=BUY__AREA == 1 and verify_Revision ? #FFFFFF80 : #00000000, linewidth=2, editable=false, display=display.none)
fibo_1000_line = plot(max_, color=SELL_AREA == 1 and verify_Revision ? #FFFFFF80 : #00000000, linewidth=2, editable=false, display=display.none)

fibo_1618_line1 = plot((max_ - min_) * fibo_1618 + min_, color=verify_Draw ? #FF000050 : #00000000, linewidth=2, editable=false, display=display.none)
fibo_1618_line2 = plot(-(max_ - min_) * fibo_1618 + min_, color=verify_Draw ? #00FF0050 : #00000000, linewidth=2, editable=false, display=display.none)

fibo_0236_line = plot((max_ - min_) * fibo_0236 + min_, color=verify_Draw ? #FFFFFF50 : #00000000, linewidth=1, editable=false, display=display.none)
fibo_0381_line = plot((max_ - min_) * fibo_0381 + min_, color=verify_Draw ? #00FF0080 : #00000000, linewidth=1, editable=false, display=display.none)
fibo_0500_line = plot((max_ - min_) * fibo_0500 + min_, color=verify_Draw ? #FFFFFF50 : #00000000, linewidth=1, editable=false, display=display.none)
fibo_0618_line = plot((max_ - min_) * fibo_0618 + min_, color=verify_Draw ? #FF000080 : #00000000, linewidth=1, editable=false, display=display.none)
fibo_0763_line = plot((max_ - min_) * fibo_0763 + min_, color=verify_Draw ? #FFFFFF50 : #00000000, linewidth=1, editable=false, display=display.none)

fill(fibo_0236_line, fibo_0381_line, color=verify_Draw == 1 ? #00FF0020 : #00000000)
fill(fibo_0763_line, fibo_0618_line, color=verify_Draw == 1 ? #FF000020 : #00000000)

//min_Line = plot(SelllineforBuying,color=BUY__AREA==1?#FF000080:#00000000,linewidth=2)
//max_Line = plot(BuylineforSelling,color=SELL_AREA==1?#00FF0080:#00000000,linewidth=2)

plotshape(BUY__SIGNAL == 1 and BUY__AREA == 0, style=shape.triangledown, location=location.abovebar, color=#00FF00FF, size=size.auto)
plotshape(SELL_SIGNAL == 1 and SELL_AREA == 0, style=shape.triangleup, location=location.belowbar, color=#FF0000FF, size=size.auto)

// Report
var label lbl = na
label.delete(lbl)
if verify_Draw
    var string reports = ''
    reports += (BUY__AREA == 1 ? 'LONG' : '')
    reports += (SELL_AREA == 1 ? 'SHORT' : '')
    reports += '\n SETUP => % ' + str.tostring(math.round((max_ - min_) * 0.5 / close * 10000) / 100)
    lbl := label.new(x=barstate.islast ? time : na, y=max_, text=reports, xloc=xloc.bar_time, color=#2020AA, textcolor=#FFFFFF)
    reports := ''
    reports

alertcondition(condition=verify_Draw, title='Trading Setup from NLTTa_MFI', message='Trading setup action from NLTTa based on MFI')
````
