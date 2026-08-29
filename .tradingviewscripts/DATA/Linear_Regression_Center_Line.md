<!-- tradingview-pine-id: PUB;23f29eea947c477ab151c7ee698d8367 -->
<!-- tradingviewscripts-format: 1 -->
# Linear Regression Center Line

Source: https://www.tradingview.com/script/VA7tm52V/

## Description

선형회귀 추세선

---

## Source Code

````pine
//@version=6
indicator(
     "Linear Regression Center Line",
     shorttitle = "LinReg Center",
     overlay = true
)

// =====================================================
// 설정값
// =====================================================

length = input.int(
     1000,
     title = "Regression Length",
     minval = 2
)

source = input.source(
     close,
     title = "Source"
)

lineWidth = input.int(
     2,
     title = "Line Width",
     minval = 1,
     maxval = 5
)


// =====================================================
// 선형회귀 중심선
// =====================================================

// 최근 length개의 가격에 가장 잘 맞는 회귀직선을 계산한 뒤,
// 그 직선의 현재 캔들 위치 값을 반환합니다.
regressionCenter = ta.linreg(
     source,
     length,
     0
)


// =====================================================
// 중심선 표시
// =====================================================

plot(
     regressionCenter,
     title = "Linear Regression Center",
     color = color.orange,
     linewidth = lineWidth
)
````
