# Next Bar UP/DOWN Probability Predictor (With Prices)

- url: https://www.tradingview.com/script/HbeSNnJX/
- type: indicator
- pine_id: PUB;7d91484d34474853b7f267e786ed53fb
- version: 1.0

## Description

📊 AI Trend Predictor Trading Strategy
1. Trend Following Setup (Bullish Continuations)
Entry Condition:
Next Bar UP probability is 80% or higher.
EMA 1, EMA 2, and EMA 3 are in perfect bullish alignment (EMA 5 > EMA 10 > EMA 20).
Execution: Open a Long / Buy position at the open of the next bar.
Target Price: Use the EMA(5) Predict price displayed in the table as your initial take-profit target.
2. Trend Following Setup (Bearish Continuations)
Entry Condition:
Next Bar DOWN probability is 80% or higher.
EMA 1, EMA 2, and EMA 3 are in perfect bearish alignment (EMA 5 < EMA 10 < EMA 20).
Execution: Open a Short / Sell position at the open of the next bar.
Target Price: Use the EMA(5) Predict price displayed in the table as your initial take-profit target.
3. Risk Management & Filters (Crucial)
The 50% No-Trade Zone: If the probabilities are fluctuating between 40% and 60%, the market is in a sideways squeeze. Do not enter any trades during this choppy phase.
Stop Loss (SL): Place your stop loss right below the current EMA 20 for Long positions, or right above the current EMA 20 for Short positions.
Invalidation: If the next bar closes opposite to the predicted direction and the probability immediately drops below 50%, exit the trade to minimize losses.

## Source Code

````pine
//@version=5
indicator("Next Bar UP/DOWN Probability Predictor (With Prices)", overlay=true, max_labels_count=20)

// --- 입력 변수 설정 ---
len1 = input.int(5, title="EMA 1 Length")
len2 = input.int(10, title="EMA 2 Length")
len3 = input.int(20, title="EMA 3 Length")

// --- 기본 지수이동평균(EMA) 계산 ---
ema1 = ta.ema(close, len1)
ema2 = ta.ema(close, len2)
ema3 = ta.ema(close, len3)

// --- 선형 회귀 기반 다음 캔들(1바 뒤) 예측 함수 ---
predict_next(src, len) =>
    ta.linreg(src, len, 0) + ta.change(ta.linreg(src, len, 0))

// --- 테이블(표) UI 생성 설정 (우측 상단 배치, 행을 6개로 확장) ---
var table prob_table = table.new(position = position.top_right, columns = 1, rows = 6, bgcolor = color.new(color.black, 20), border_width = 1, border_color = color.gray)

// 차트의 가장 마지막 캔들에서만 실행
if barstate.islast
    // 1. 다음 캔들의 예측 가격 계산
    p1 = predict_next(ema1, len1)
    p2 = predict_next(ema2, len2)
    p3 = predict_next(ema3, len3)
    
    // 2. 현재 가격 대비 상승 방향성 점수화
    score1 = p1 > ema1 ? 40 : 0
    score2 = p2 > ema2 ? 30 : 0
    score3 = p3 > ema3 ? 30 : 0
    
    // 3. 종합 상승 확률 계산 (0% ~ 100%)
    up_probability = score1 + score2 + score3
    
    // 4. 시장 추세 강도 보정 (이평선 정배열/역배열 보너스 점수 반영)
    if ema1 > ema2 and ema2 > ema3
        up_probability := math.min(up_probability + 10, 100) 
    if ema1 < ema2 and ema2 < ema3
        up_probability := math.max(up_probability - 10, 0)  
        
    // 5. 하락 확률 자동 연산
    down_probability = 100 - up_probability
        
    // 6. 텍스트 포맷 설정 (확률 및 가격 데이터)
    up_text = "🔺 Next Bar UP: " + str.tostring(up_probability) + "%"
    down_text = "🔻 Next Bar DOWN: " + str.tostring(down_probability) + "%"
    
    // 현재 자산의 호가 단위를 반영하여 소수점 자릿수 자동 맞춤 포맷 생성
    price_format = syminfo.mintick < 0.1 ? "#.##" : "#"
    if syminfo.mintick < 0.01
        price_format := "#.####"
        
    p1_text = "🔹 EMA(" + str.tostring(len1) + ") Predict: " + str.tostring(p1, price_format)
    p2_text = "🔹 EMA(" + str.tostring(len2) + ") Predict: " + str.tostring(p2, price_format)
    p3_text = "🔹 EMA(" + str.tostring(len3) + ") Predict: " + str.tostring(p3, price_format)

    // --- 표 데이터 출력 ---
    // [행 0] 타이틀 영역
    table.cell(prob_table, 0, 0, "📊 AI Trend Predictor", text_color=color.yellow, bgcolor=color.black, text_size=size.small)
    
    // [행 1] 상승 확률 영역 (녹색 배경)
    table.cell(prob_table, 0, 1, up_text, text_color=color.white, bgcolor=color.new(color.green, 40), text_size=size.large)
    
    // [행 2] 하락 확률 영역 (적색 배경)
    table.cell(prob_table, 0, 2, down_text, text_color=color.white, bgcolor=color.new(color.red, 40), text_size=size.large)
    
    // [행 3~5] 각 이평선별 다음 캔들 예측 가격 숫자 표기 (회색 배경)
    table.cell(prob_table, 0, 3, p1_text, text_color=color.white, bgcolor=color.new(color.gray, 60), text_size=size.small)
    table.cell(prob_table, 0, 4, p2_text, text_color=color.white, bgcolor=color.new(color.gray, 60), text_size=size.small)
    table.cell(prob_table, 0, 5, p3_text, text_color=color.white, bgcolor=color.new(color.gray, 60), text_size=size.small)
````
