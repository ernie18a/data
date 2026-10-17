# Momentum Trend Strength (MTS)

- url: https://www.tradingview.com/script/pyE0b0pW/
- type: indicator
- pine_id: PUB;d189b531acf946d1b115b10cf145b6e7
- version: 1.0

## Description

Trading Methodology
1. Zero-Line (0) Crossover Trading (Core Trend Following)
This is the most standard method to capture trend reversals based on the zero-line.
Buy (Long): Enter when the MTS line crosses above the zero-line from below (signals the start of an uptrend).
Sell (Short): Enter when the MTS line crosses below the zero-line from above (signals the start of a downtrend).
2. Histogram Color Change Trading (Short-Term Entries & Profit-Taking)
This method utilizes color changes driven by the indicator's slope (comparing the current value to the previous value).
Entry Points:
When the indicator turns from light green (stalled upward momentum) back to dark green (accelerating upward momentum) above the zero-line, buy the pullback.
Exit (Take-Profit) Points:
For long positions: Exit when the color changes from dark green to light green (fading upward momentum).
For short positions: Exit when the color changes from dark red to orange (fading downward momentum).
3. Detecting Divergence (Trend Reversal)
This captures powerful reversal entries when price and indicator movements move in opposite directions.
Bullish Divergence (Buy): Occurs when the price makes a lower low, but the MTS indicator makes a higher low (indicates selling pressure is exhausted, prepare to buy).
Bearish Divergence (Sell): Occurs when the price makes a higher high, but the MTS indicator makes a lower high (indicates buying pressure is exhausted, prepare to sell).
4. Improving Win Rate via Filtering (Recommended)
Since MTS is a momentum-based indicator, it can generate frequent false signals (whipsaws) in sideways markets. To prevent this, adding a 200 EMA (Exponential Moving Average) to your chart is highly recommended.
When the price is above the 200 EMA, only take zero-line upside breakthroughs (Long entries).
When the price is below the 200 EMA, only take zero-line downside breakthroughs (Short entries).

## Source Code

````pine
//@version=5
indicator("Momentum Trend Strength (MTS) Custom", overlay=false, precision=2)

// --- 설정값 입력 ---
len = input.int(14, "Momentum Length", minval=1)
smoothLen = input.int(9, "Smoothing Length", minval=1)
src = input.source(close, "Source")

// --- MTS 계산 로직 ---
// 1. 가격 변화량(Momentum) 계산
mom = src - src[len]

// 2. 부드러운 흐름을 위해 이동평균 적용 (Smoothing)
mtsValue = ta.ema(mom, smoothLen)

// --- 시각화 (컬러 설정) ---
// 강한 상승(진한 녹색), 약한 상승(연한 녹색), 강한 하락(진한 빨강), 약한 하락(연한 빨강)
col = mtsValue > 0 ? (mtsValue > mtsValue[1] ? color.green : color.lime) : 
      (mtsValue < mtsValue[1] ? color.red : color.orange)

// --- 출력 ---
plot(mtsValue, "MTS Line", color=col, linewidth=2, style=plot.style_histogram)
hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dashed)

// 과매수/과매도 참고선 (필요 시 조절)
plot(mtsValue, "MTS Line Plot", color=col, linewidth=1)
````
