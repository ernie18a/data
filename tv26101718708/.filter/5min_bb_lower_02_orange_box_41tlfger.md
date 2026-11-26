# 5min BB Lower 0.2% Orange Box

- url: https://www.tradingview.com/script/41TlFgER/
- type: indicator
- pine_id: PUB;7a15668b7df943fabf940c46a9de30f7
- version: 1.0

## Description

로우어 라오어

## Source Code

````pine
//@version=5
indicator("5min BB Lower 0.2% Orange Box", overlay=true)

// 1. 설정값 입력
length = input.int(190, title="BB 길이")
mult = input.float(2.25, title="표준편차")
src = close 

// 2. 5분봉 데이터 가져오기 (VWMA 기반 계산)
basis_5m = request.security(syminfo.tickerid, "5", ta.vwma(src, length))
dev_5m = request.security(syminfo.tickerid, "5", ta.stdev(src, length))
lower_5m = basis_5m - (mult * dev_5m)

// 3. 하단선 기준 ±0.2% 범위 계산 (요청사항 반영)
box_top = lower_5m * 1.002
box_bottom = lower_5m * 0.998

// 4. 차트 전체 가로 박스 생성 (오렌지색 적용)
var box fullBox = na

if barstate.islast
    box.delete(fullBox)
    fullBox := box.new(left=bar_index, top=box_top, right=bar_index, bottom=box_bottom, 
                     border_color=color.new(color.orange, 40), 
                     bgcolor=color.new(color.orange, 85),
                     extend=extend.both)
````
