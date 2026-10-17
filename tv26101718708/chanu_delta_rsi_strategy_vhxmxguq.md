# Chanu Delta RSI Strategy

- url: https://www.tradingview.com/script/VhxmxGuq/
- type: strategy
- pine_id: PUB;335b99fccb064a1cbb266a133c21603a
- version: 2.0

## Description

This strategy is built on the Chanu Delta RSI , which indicates the strength of the Bitcoin market. The problem with the previous Chanu Delta Strategy was that it was simply based on the price difference between the two Bitcoin markets, so there was no universality. However, this new Chanu Delta RSI strategy solves the problem by introducing an RSI that compares the price difference trend.

When the Chanu Delta RSI hits “Bull Level” and “Bear Level” and closes the candle, long and short signals are triggered respectively. The example shown on the screen is a default setting optimized for a 4-hour candlestick strategy based on the Bybit BTCUSDT futures market. You can use it by adjusting the setting value and modifying it to suit you.

This strategy is selectable from both reference and large amplitude BTCUSD markets in order to enable fine backtesting. I recommend using BYBIT:BTCUSDT for the reference market and COINBASE:BTCUSD for the large amplitude market.

(Note) Using the "Chanu Delta RSI" to know the current indicator value in real time, it is convenient to predict the signal of the strategy.
(Note) Because the Chanu Delta RSI represents the price difference based on the Bybit BTCUSDT futures market, backtesting is possible from March 2020.
_____________________________________________________________
이 전략은 비트코인 ​​시장의 강점을 나타내는 Chanu Delta RSI를 기반으로 합니다. 기존 Chanu Delta 전략의 문제점은 단순히 두 비트코인 ​​시장의 가격차를 기준으로 하여 보편성이 없었다는 점이다. 하지만 이번 새로운 Chanu Delta RSI 전략은 가격차이 추세를 비교하는 RSI를 도입해 문제를 해결했습니다.

Chanu Delta RSI가 "Bull Level"과 "Bear Level"에 도달하고 봉마감하면 롱, 숏 신호가 각각 트리거됩니다. 화면에 보이는 예시는 Bybit BTCUSDT 선물 시장을 기반으로 한 4시간 캔들스틱 전략에 최적화된 기본 설정입니다. 설정값을 조정하여 자신에게 맞게 수정하여 사용하시면 됩니다.

이 전략은 정밀한 백테스팅을 가능하게 하기 위해 참조 및 큰 진폭 BTCUSD 시장에서 모두 선택할 수 있습니다. 참조 시장에는 BYBIT:BTCUSDT를 사용하고 큰 진폭 시장에는 COINBASE:BTCUSD를 사용하는 것이 좋습니다.

(주) "Chanu Delta RSI"를 이용하여 현재 지표 값을 실시간으로 알 수 있어 전략의 시그널을 예측하는데 편리합니다.
(주) Chanu Delta RSI는 바이비트 BTCUSDT 선물시장을 기준으로 가격차이를 나타내므로 2020년 3월부터 백테스팅이 가능합니다.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © chanu_lev10k

//@version=5
strategy(title='Chanu Delta RSI Strategy', overlay=false)

// Inputs
sym_ref = input.symbol(title='BTCUSD reference market', defval='BYBIT:BTCUSDT')
sym_amp = input.symbol(title='BTCUSD large amplitude market', defval='COINBASE:BTCUSD')
src = input.source(title='Source', defval=close)
res = input.timeframe(title='Resolution', defval='')
isnorm = input.bool(title='Use Normalization of Chanu Delta ?', defval=true, tooltip='By dividing the original Chanu Delta value by the price of the reference Bitcoin market, it allows the Chanu Delta strategy to be universally used in the long term despite Bitcoin price fluctuations.')
len = input.int(defval=4, title='Length of Chanu Delta RSI')
bullLevel = input.int(title='Bull Level', defval=63, maxval=100, minval=0)
bearLevel = input.int(title='Bear Level', defval=30, maxval=100, minval=0)
highlightBreakouts = input(title='Highlight Bull/Bear Breakouts ?', defval=true)

// Chanu Delta RSI Definition
delta_f(res, src) =>
    d = request.security(sym_amp, res, src) - request.security(sym_ref, res, src)
    n = d / request.security(sym_ref, res, src) * 100000
    isnorm ? n : d
delta = delta_f(res, src)
delta_rsi = ta.rsi(delta, len)

// Plot
rcColor = delta_rsi > bullLevel ? #0ebb23 : delta_rsi < bearLevel ? #ff0000 : #f4b77d
maxBand = hline(100, title='Max Level', linestyle=hline.style_dotted, color=color.white)
hline(0, title='Zero Level', linestyle=hline.style_dotted)
minBand = hline(0, title='Min Level', linestyle=hline.style_dotted, color=color.white)
bullBand = hline(bullLevel, title='Bull Level', linestyle=hline.style_dotted)
bearBand = hline(bearLevel, title='Bear Level', linestyle=hline.style_dotted)
fill(bullBand, bearBand, color=color.new(color.purple, 95))
bullFillColor = delta_rsi > bullLevel and highlightBreakouts ? color.green : na
bearFillColor = delta_rsi < bearLevel and highlightBreakouts ? color.red : na
fill(maxBand, bullBand, color=color.new(bullFillColor, 80))
fill(minBand, bearBand, color=color.new(bearFillColor, 80))
plot(delta_rsi, title='Chanu Delta RSI', linewidth=2, color=rcColor)

// Long Short conditions
longCondition = ta.crossover(delta_rsi, bullLevel)
if longCondition
    strategy.entry('Long', strategy.long)
shortCondition = ta.crossunder(delta_rsi, bearLevel)
if shortCondition
    strategy.entry('Short', strategy.short)
````
