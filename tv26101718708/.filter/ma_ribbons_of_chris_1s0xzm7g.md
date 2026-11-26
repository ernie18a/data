# MA Ribbons of Chris

- url: https://www.tradingview.com/script/1S0Xzm7G/
- type: indicator
- pine_id: PUB;cfe3199825aa4337a740d6fed0f66b77
- version: 1.0

## Description

### Overview
**Multi-Type Moving Average Ribbon** provides a versatile ribbon system that goes beyond standard moving averages by introducing customized volume-weighted filters and a bounded rolling exponential weighting mechanism.

---

### Key Features & Available MA Types (8 Types)
Each of the 4 moving average lines can be independently customized by length, source, display color, and calculation model:

1. **Classic Averages:** SMA, EMA, SMMA (RMA), WMA
2. **Standard Volume-Weighted:** VWMA
3. **Hybrid Volume Averages:**
   * **VWEMA:** EMA-based volume-weighted average
   * **VWWMA:** WMA-based volume-weighted average
4. **VW_Rolling.EMA (Signature Feature):**
   * Standard EMA has an infinite memory effect where ancient price data retains a fractional weight indefinitely.
   * `VW_Rolling.EMA` calculates exponential decay strictly restricted within the designated N-bar rolling window.
   * It eliminates extreme historical tail drag while prioritizing recent aggressive volume, providing a sharp and responsive volume-weighted dynamic level.

---

### How to Use
* **Trend & Filter:** Overlay standard SMA/EMA alongside `VW_Rolling.EMA` to spot divergence between price movement and real volume participation (detecting low-volume fakeouts).
* **Dynamic S/R:** Use shorter periods (20/50) for trailing momentum and longer periods (100/200) for structural support/resistance.

## Source Code

````pine
//@version=6
indicator("Moving Average Ribbon", shorttitle = "MA Ribbon", overlay = true, timeframe = "", timeframe_gaps = true)

// VWEMA 계산 함수 (EMA 기반 거래량 가중)
vwema(source, length) =>
    ta.ema(source * volume, length) / ta.ema(volume, length)

// VWWMA 계산 함수 (WMA 기반 거래량 가중: WMA + VWMA 조합)
vwwma(source, length) =>
    ta.wma(source * volume, length) / ta.wma(volume, length)

// 💡 [신규 추가] 딱 N일(예: 200일) 창문 안에서만 지수 가중치를 부여하는 롤링 EMA 함수
rolling_ema(src, length) =>
    alpha = 2.0 / (length + 1.0)  // 지수 이동평균 가중치 감쇄율(알파값)
    sum_val = 0.0                 // (가격*거래량*가중치)의 합을 담을 상자
    sum_weight = 0.0              // 순수 가중치들의 합을 담을 상자
    for i = 0 to length - 1       // 오늘(0)부터 N-1일 전까지만 딱 잘라서 반복 연산!
        w = math.pow(1.0 - alpha, i) // 과거로 갈수록 지수적으로 감소하는 가중치 계산
        sum_val += src[i] * w      // 값에 가중치를 곱해 차곡차곡 적재
        sum_weight += w            // 가중치 총합 적재
    sum_val / sum_weight           // 정규화된 N일 한정 지수 가중평균 산출

// 💡 [신규 추가] N일 한정 지수 가중 거래량 이동평균 (VW_Rolling.EMA)
vw_rolling_ema(source, length) =>
    rolling_ema(source * volume, length) / rolling_ema(volume, length)

ma(source, length, MAtype) =>
    switch MAtype
        "SMA"        => ta.sma(source,  length) 
        "EMA"        => ta.ema(source,  length) 
        "SMMA (RMA)" => ta.rma(source,  length) 
        "WMA"        => ta.wma(source,  length) 
        "VWMA"       => ta.vwma(source, length) 
        "VWEMA"      => vwema(source,   length) 
        "VWWMA"      => vwwma(source,   length)  // VWWMA (WMA + VWMA 조합) 추가
        "VW_Rolling.EMA" => vw_rolling_ema(source, length)  // 💡 [신규] N일 한정 롤링 지수가중 VWEMA 매핑
        => na

show_ma1   = input(true,         "MA //1", inline = "MA //1", display = display.none)
ma1_type   = input.string("SMA", "",      inline = "MA //1", active = show_ma1, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA", "VWEMA", "VWWMA", "VW_Rolling.EMA"])
ma1_source = input(close,        "",      inline = "MA //1", active = show_ma1, display = display.none)
ma1_length = input.int(20,       "",      inline = "MA //1", active = show_ma1, minval  = 1)
ma1_color  = input(#f6c309,    "",      inline = "MA //1", active = show_ma1, display = display.none)

show_ma2   = input(true,         "MA //2", inline = "MA //2", display = display.none)
ma2_type   = input.string("SMA", "",      inline = "MA //2", active = show_ma2, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA", "VWEMA", "VWWMA", "VW_Rolling.EMA"])
ma2_source = input(close,        "",      inline = "MA //2", active = show_ma2, display = display.none)
ma2_length = input.int(50,       "",      inline = "MA //2", active = show_ma2, minval  = 1)
ma2_color  = input(#fb9800,    "",      inline = "MA //2", active = show_ma2, display = display.none)

show_ma3   = input(true,         "MA //3", inline = "MA //3", display = display.none)
ma3_type   = input.string("SMA", "",      inline = "MA //3", active = show_ma3, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA", "VWEMA", "VWWMA", "VW_Rolling.EMA"])
ma3_source = input(close,        "",      inline = "MA //3", active = show_ma3, display = display.none)
ma3_length = input.int(100,      "",      inline = "MA //3", active = show_ma3, minval  = 1)
ma3_color  = input(#fb6500,    "",      inline = "MA //3", active = show_ma3, display = display.none)

show_ma4   = input(true,         "MA //4", inline = "MA //4", display = display.none)
ma4_type   = input.string("SMA", "",      inline = "MA //4", active = show_ma4, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA", "VWEMA", "VWWMA", "VW_Rolling.EMA"])
ma4_source = input(close,        "",      inline = "MA //4", active = show_ma4, display = display.none)
ma4_length = input.int(200,      "",      inline = "MA //4", active = show_ma4, minval  = 1)
ma4_color  = input(#f60c0c,    "",      inline = "MA //4", active = show_ma4, display = display.none)

ma1 = show_ma1 ? ma(ma1_source, ma1_length, ma1_type) : na
ma2 = show_ma2 ? ma(ma2_source, ma2_length, ma2_type) : na
ma3 = show_ma3 ? ma(ma3_source, ma3_length, ma3_type) : na
ma4 = show_ma4 ? ma(ma4_source, ma4_length, ma4_type) : na

plot(ma1, "MA //1", ma1_color, display = show_ma1 ? display.all : display.none)
plot(ma2, "MA //2", ma2_color, display = show_ma2 ? display.all : display.none)
plot(ma3, "MA //3", ma3_color, display = show_ma3 ? display.all : display.none)
plot(ma4, "MA //4", ma4_color, display = show_ma4 ? display.all : display.none)
````
