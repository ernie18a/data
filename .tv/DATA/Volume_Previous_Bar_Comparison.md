<!-- tradingview-pine-id: PUB;3c8e20c84c174240a47c135dd9d25511 -->
<!-- tradingviewscripts-format: 1 -->
# Volume (Previous Bar Comparison)

Source: https://www.tradingview.com/script/Sn1RtTHZ/

## Description

볼륨-거래량 컬럼 표시시 국내 HTS처림 직전거래 대비 늘었는지 줄었는지 색깔로 나타냄

---

## Source Code

````pine
//@version=6
indicator("Volume (Previous Bar Comparison)", overlay=false)

// 직전 거래량 대비 증감 조건
isGrow = volume > volume[1]

// 색상 지정 (증가: 초록/청색, 감소: 빨강)
volColor = isGrow ? color.rgb(38, 166, 154) : color.rgb(239, 83, 80)

// 거래량 막대 출력
plot(volume, title="Volume", style=plot.style_columns, color=volColor)
````
