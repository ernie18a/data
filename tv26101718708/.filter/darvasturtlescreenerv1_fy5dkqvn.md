# Darvas_Turtle_Screener_V1

- url: https://www.tradingview.com/script/Fy5dKqvn/
- type: indicator
- pine_id: PUB;d1a706a6d8414a74afa0bf708d3480fb
- version: 1.0

## Description

박스권 돌파확인

## Source Code

````pine
//+------------------------------------------------------------------+
//| 전략명: Darvas Box Turtle Hybrid Screener                         |
//| 제작: 거북 (터틀트레이딩 마스터)                                    |
//| 대상: 데이빗의 1억 달성 프로젝트                                     |
//+------------------------------------------------------------------+
//@version=5
indicator("Darvas_Turtle_Screener_V1", overlay=true)

// 1. 다비스 박스 설정
box_length = input.int(100, "박스 산출 기간", minval=10)
high_price = ta.highest(high, box_length)
var float box_top = na
var float box_bot = na
var bool in_box = false

if high[3] > high[2] and high[3] > high[1] and high[3] > high[0]
    box_top := high[3]
    in_box := true

if in_box and low[2] < low[1] and low[2] < low[0]
    box_bot := low[2]
    in_box := false

// 2. 터틀 필터 (거래량 및 변동성)
avg_vol = ta.sma(volume, 20)
vol_spike = volume > avg_vol * 1.5 // 평균 거래량 대비 150% 이상
n_val = ta.atr(20) // 터틀의 N값

// 3. 돌파 신호 정의
// 조건: 현재가가 박스 상단을 돌파 + 거래량 동반 + 20일 신고가
darvas_breakout = ta.crossover(close, box_top) and vol_spike and close == ta.highest(close, 20)

// 4. 스크리너 출력용 데이터 (0 또는 1)
// 이 값이 1일 때 스크리너에서 종목을 추출함
plot(darvas_breakout ? 1 : 0, "Signal", display=display.none)

// 차트 시각화 (검증용)
plot(box_top, "Box Top", color=color.new(color.red, 0), style=plot.style_stepline)
plot(box_bot, "Box Bottom", color=color.new(color.green, 0), style=plot.style_stepline)
plotshape(darvas_breakout, title="Breakout", location=location.belowbar, color=color.yellow, style=shape.labelup, text="DARVAS")
````
