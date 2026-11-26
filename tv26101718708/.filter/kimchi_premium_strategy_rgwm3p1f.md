# Kimchi Premium Strategy

- url: https://www.tradingview.com/script/rgwM3P1f/
- type: strategy
- pine_id: PUB;7c98391f07ee43c191b1191eff823bd1
- version: 1.0

## Description

This strategy is based on the Korea Premium, also known as the “Kimchi Premium,” which indicates how expensive or cheap the price of Bitcoin in Korean Won on a Bitcoin exchange in South Korea is relative to the price of Bitcoin being traded in USD or Tether. Inverse Kimchi Premium RSI was newly defined to create a strategy with Kimchi Premium. Assuming that the larger the kimchi premium, the greater the individual's purchasing power. In this case, if the Inverse Kimchi Premium RSI falls and closes the candle below the bear level, a short is triggered. Long is the opposite.

This strategy defaults to a combination of the traditional RSI and the Inverse Kimchi Premium RSI. If the user wishes to unlock the Inverse Kimchi Premium RSI combination and only use it as a traditional RSI strategy, the following settings can be used.

Use Combination of Inverse Kimchi Premium RSI: Uncheck
Resolution: Chart (4hr Candle)
Source: Close
Length of RSI: 14
Bull Level: 74
Bear Level: 25
__________________________________________________________________________________
김치프리미엄(김프) 전략은 달러 혹은 테더로 거래되고 있는 비트코인 가격 대비 한국에 있는 비트코인 거래소의 비트코인 원화 가격이 얼마나 비싸고 싼 지를 나타내는 코리아 프리미엄, 일명 "김치 프리미엄" 지표를 기반으로 만들어졌습니다. 김치 프리미엄을 가지고 전략을 만들기위해 Inverse Kimchi Premium RSI를 새롭게 정의하였습니다. 김치 프리미엄이 커질수록 개인의 매수세가 커진다고 가정하고, 이 경우 Inverse Kimchi Premium RSI이 하락하여 Bear Level 아래에서 캔들 마감을 하면 Short을 트리거 합니다. Long은 그 반대입니다.

이 전략은 전통적인 RSI와 Inverse Kimchi Premium RSI을 조합하여 기본값을 설정하였습니다. 유저가 원한다면 Inverse Kimchi Premium RSI의 조합을 해제하고 전통적인 RSI 전략으로만 사용하려면 아래 다음의 설정값을 사용할 수 있습니다.

Use Combination of Inverse Kimchi Premium RSI: 체크 해제
Resolution: Chart (4hr Candle)
Source: Close
Length of RSI: 14
Bull Level: 74
Bear Level: 25

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © chanu_lev10k

//@version=5
strategy("Kimchi Premium Strategy", overlay=false)

// Inputs
sym_krw = input.symbol(title='Select BTCKRW Market', defval='BITHUMB:BTCKRW')
sym_usd = input.symbol(title='Select BTCUSD Market', defval='BITSTAMP:BTCUSD')
res = input.timeframe(title='Resolution', defval='')
src = input.source(title='Source', defval=close)
len1 = input.int(defval=4, title='Length of RSI')
len2 = input.int(defval=12, title='Length of Inverse Kimchi Premium RSI')
isikp = input.bool(title='Use Combination of Inverse Kimchi Premium RSI ?', defval=true)
bullLevel = input.float(title='Bull Level', defval=63, step=1.0, maxval=100, minval=0)
bearLevel = input.float(title='Bear Level', defval=28, step=1.0, maxval=100, minval=0)
highlightBreakouts = input(title='Highlight Bull/Bear Breakouts ?', defval=true)

// Inverse Kimichi Premium RSI Definition
up = ta.rma(math.max(ta.change(src), 0), len1)
down = ta.rma(-math.min(ta.change(src), 0), len1)
rsi = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))
usdkrw = request.security('FX_IDC:USDKRW', res, src)
btckrw = request.security(sym_krw, res, src)
btcusd = request.security(sym_usd, res, src)
btcusd_to_krw = btcusd * usdkrw
ikp = (btcusd_to_krw / btckrw - 1) * 100
ikp_f(res, len1, len2) =>
    n = rsi
    t = (rsi + ta.rsi(ikp, len2))/2
    isikp ? t : n
tot_rsi = ikp_f(res, len1, len2)

// Plot
rcColor = tot_rsi > bullLevel ? #0ebb23 : tot_rsi < bearLevel ? #ff0000 : #f4b77d
maxBand = hline(100, title='Max Level', linestyle=hline.style_dotted, color=color.white)
hline(0, title='Zero Level', linestyle=hline.style_dotted)
minBand = hline(0, title='Min Level', linestyle=hline.style_dotted, color=color.white)
bullBand = hline(bullLevel, title='Bull Level', linestyle=hline.style_dotted)
bearBand = hline(bearLevel, title='Bear Level', linestyle=hline.style_dotted)
fill(bullBand, bearBand, color=color.new(color.purple, 95))
bullFillColor = tot_rsi > bullLevel and highlightBreakouts ? color.green : na
bearFillColor = tot_rsi < bearLevel and highlightBreakouts ? color.red : na
fill(maxBand, bullBand, color=color.new(bullFillColor, 80))
fill(minBand, bearBand, color=color.new(bearFillColor, 80))
plot(tot_rsi, title='Total RSI', linewidth=2, color=rcColor)
plot(rsi, title='RSI', linewidth=1, color=color.new(color.purple, 0))
plot(ta.rsi(ikp, len2), title='Inverse Kimchi Premium RSI', linewidth=1, color=color.new(color.blue, 0))

// Long Short conditions
longCondition = ta.crossover(tot_rsi, bullLevel)
if longCondition
    strategy.entry('Long', strategy.long)
shortCondition = ta.crossunder(tot_rsi, bearLevel)
if shortCondition
    strategy.entry('Short', strategy.short)
````
