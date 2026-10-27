# Market Bias 30m

- url: https://www.tradingview.com/script/9Q31vDYj/
- type: indicator
- pine_id: PUB;82b425e26dfc4c7fa3eafe79ed926331
- version: 1.0

## Description

Market Bias 녹색 막대 그래프로 돌파 신호 확인

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © maziblend35

//@version=6
indicator("Market Bias 스크리너 신호", overlay=false)

// ── 설정 ─────────────────────────────────
fast_len  = input.int(20,  "단기 EMA",  group="EMA")
mid_len   = input.int(50,  "중기 EMA",  group="EMA")
trend_len = input.int(200, "추세 EMA",  group="EMA")
swing_len = input.int(5,   "스윙 기간", group="구조")
vol_mult  = input.float(1.5,"볼륨 배수",group="돌파")

// ── 계산 ─────────────────────────────────
ema20  = ta.ema(close, fast_len)
ema50  = ta.ema(close, mid_len)
ema200 = ta.ema(close, trend_len)

bias_bull = ema20 > ema50 and ema50 > ema200 and close > ema200
bias_bear = ema20 < ema50 and ema50 < ema200 and close < ema200

ph = ta.pivothigh(high, swing_len, swing_len)
var float res = na
if not na(ph)
    res := ph

avg_vol = ta.sma(volume, 20)
vol_ok  = volume > avg_vol * vol_mult

bull_break = not na(res) and close[1] <= res and close > res
           and close > open and bias_bull and vol_ok

// ── 스크리너용 출력 (숫자로 변환) ─────────
bias_val  = bias_bull ? 2 : bias_bear ? -2 : 0
break_val = bull_break ? 1 : 0

// 스크리너 필터링 기준 plot
plot(bias_val,  "바이어스점수",  color=color.gray)
plot(break_val, "상승돌파신호",  color=color.lime)

// 히스토그램으로 시각화
hline(0, "기준선", color=color.gray)
plot(bias_val, "바이어스", style=plot.style_histogram,
     color=bias_bull ? color.teal : bias_bear ? color.red : color.gray)

// 돌파 마킹
bgcolor(bull_break ? color.new(color.lime, 70) : na)
plot(close)
````
