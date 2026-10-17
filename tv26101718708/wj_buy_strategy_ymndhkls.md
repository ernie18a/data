# WJ BUY Strategy

- url: https://www.tradingview.com/script/yMnDhKLs-WJ-BUY-Strategy/
- type: strategy
- pine_id: PUB;46973815dfbd4020b1632a0cc234b977
- version: 7.0

## Description

[b][Strategy Concept][/b]
The[b] WJ BUY Strategy[/b] is an advanced, dual-engine systematic trading system designed to safely navigate extreme market volatility. It combines deep mean-reversion tactics (Strategy B) with disciplined trend-following accumulation (Strategy A). Instead of relying on a single entry, this hybrid system identifies extreme "exhaustion points" to establish a core position at the bottom, and then strategically scales in (pyramids) only when the upward trend is mathematically confirmed.

[b][Technical Indicators Used][/b]
This strategy aggregates insights from three different dimensions of market analysis to form a holistic "WJ Score":
-Volatility Analysis (Bollinger Bands): Identifies price extremes and potential reversal zones when the asset deviates significantly from its mean.
-Trend Context (Multiple Moving Averages): Analyzes the long-term structural health using 120, 240, and 400-period MAs to determine the depth of the correction.
-Momentum Analysis (Relative Strength Index): Uses granular RSI tiers (<=25, 30, 35, 40) to detect severe oversold conditions that are often invisible on the price chart alone.

[b][Objective & Methodology][/b]
The core objective of the WJ Strategy A+B Hybrid is Risk-Adjusted Accumulation and Capital Preservation. It operates through a dynamic multi-phase process:
-Phase 1: Detection (Scoring): The system continuously calculates the WJ Score. A score >=3.0 triggers the deep-reversion "B-Mode", while a score >=2.0 triggers the trend-continuation "A-Mode".
-Phase 2: Stabilization: To avoid "falling knives," the strategy requires the score to drop and stabilize for a set number of days.
-Phase 3: Dynamic Execution: Entries are only executed when the price reclaims the short-term 10-day Moving Average, with dynamic safety filters applied based on recent price action.

[b][Major System Upgrades: The Hybrid Evolution][/b]
This updated version introduces several proprietary risk-management mechanisms:
-Smart Trend Confirmation (Price Filter): Strategy A (scaling-in) is strictly permitted only if the current price is higher than the core Strategy B entry. This prevents averaging down in a prolonged bear market and ensures capital is only added to confirmed uptrends.
-Time-Based Cooldown (Whipsaw Protection): Implements a strict 14-day lock period after a Strategy B entry. This prevents premature accumulation during choppy, sideways market recoveries.
-Dynamic Anti-Falling-Knife Filter (MA Holding): The entry requirement dynamically adapts based on the sequence of trades. If the system is forced to average down (current price < last buy price), it demands 2 to 3 consecutive days of holding above the 10-day MA to confirm a solid floor. If buying in an uptrend, a standard 1-day breakout is sufficient.

[b][Key Features][/b]
-Dual-Engine Logic: Seamlessly transitions between catching market crashes and riding the subsequent recovery waves.
-Dynamic Scoring: Removes emotional bias by relying on an objective, unified data-driven threshold.
-High-Volatility Optimization: Specifically tuned for high-beta environments. It excels at capturing rapid price reversals where standard models are too slow to react.

[b][Summary][/b]
The new [b]WJ BUY Strategy(A+B Hybrid)[/b] is ideal for quantitative investors looking to systematically accumulate high-quality, volatile assets (such as US Technology, Biotechnology, or small-cap indices) during sharp pullbacks. By strictly controlling when and how to scale in, it maximizes upside potential while rigorously defending against prolonged downtrends.

[b]Disclaimer[/b]
[i]Trading involves significant risk. The WJ Strategy A+B Hybrid and its associated indicators are provided for educational and informational purposes only. They do not constitute financial, investment, or trading advice. Past performance is not indicative of future results. Volatile market conditions carry a higher risk of capital loss. Always perform your own due diligence and consult with a professional financial advisor before making any investment decisions.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © YUNUYUN

//@version=6
strategy("WJ BUY Strategy", overlay=true, initial_capital=5000000, default_qty_type=strategy.cash, default_qty_value=100000, pyramiding=50, process_orders_on_close=true, calc_on_every_tick=true)

// ==========================================
// 1. 입력 설정
// ==========================================
// 볼린저밴드
bb_len   = input.int(40, title="BB 길이")
bb_mult  = input.float(2.0, title="BB 표준편차")

// 이동평균선 (60일선부터 720일선까지 확장)
ma_len1  = input.int(60, title="MA 1 (60일)")
ma_len2  = input.int(120, title="MA 2 (120일)")
ma_len3  = input.int(240, title="MA 3 (240일)")
ma_len4  = input.int(480, title="MA 4 (480일)")
ma_len5  = input.int(720, title="MA 5 (720일)")

// RSI
rsi_len  = input.int(14, title="RSI 길이")

// 전략 파라미터
confirm_days = input.int(2, title="B전략 하강 유지 기간(일)", minval=1)
entry_ma_len = input.int(10, title="진입 기준 이평선(일)", minval=1)

// 백테스트 기간
start_year  = input.int(2021, title="시작 연도")
start_month = input.int(1, title="시작 월")
start_day   = input.int(1, title="시작 일")

start_time = timestamp(start_year, start_month, start_day, 0, 0)
in_date_range = time >= start_time


// ==========================================
// 2. WJ index 지표 계산 (연속형)
// ==========================================
[bb_basis, _, bb_lower] = ta.bb(close, bb_len, bb_mult)
ma60  = ta.sma(close, ma_len1)
ma120 = ta.sma(close, ma_len2)
ma240 = ta.sma(close, ma_len3)
ma480 = ta.sma(close, ma_len4)
ma720 = ta.sma(close, ma_len5)
ma500 = ta.sma(close, 500) // 500일선 기준
rsi_val = ta.rsi(close, rsi_len)

// 1) 볼린저밴드 점수 (연속형)
score_bb_raw = (bb_basis - close) / (bb_basis - bb_lower)
score_bb = math.max(0, score_bb_raw)

// 2) 이동평균선 점수 (역순 체크 및 선형 보간법)
score_ma_raw = 0.0

if close <= ma720
    score_ma_raw := 2.5
else if close <= ma480
    denom = ma480 - ma720
    ratio = denom != 0 ? (ma480 - close) / denom : 1.0
    score_ma_raw := 1.8 + (0.7 * ratio)
else if close <= ma240
    denom = ma240 - ma480
    ratio = denom != 0 ? (ma240 - close) / denom : 1.0
    score_ma_raw := 1.2 + (0.6 * ratio)
else if close <= ma120
    denom = ma120 - ma240
    ratio = denom != 0 ? (ma120 - close) / denom : 1.0
    score_ma_raw := 0.6 + (0.6 * ratio)
else if close < ma60
    denom = ma60 - ma120
    ratio = denom != 0 ? (ma60 - close) / denom : 1.0
    score_ma_raw := 0.0 + (0.6 * ratio)
else
    score_ma_raw := 0.0

score_ma = math.min(2.5, score_ma_raw)

// 3) RSI 점수 (연속형)
score_rsi_raw = rsi_val >= 45 ? 0.0 : (45 - rsi_val) * 0.1
score_rsi = score_rsi_raw
entry_ma = ta.sma(close, entry_ma_len)


// ==========================================
// 3. 전략 로직 (동적 점수 할당 및 통합 버전)
// ==========================================

// 상태 변수
var int monitor_mode = 0  
var int days_maintained = 0       

// 기록 및 스냅샷 변수
var int last_buy_time = na
var float last_buy_price1 = na   
var float last_buy_price2 = na   
var float waterfall_limit_price = na  

// 500일선 관련 추적 변수
var bool last_buy_under1 = false
var bool last_buy_under2 = false
var bool deep_underwater_mode = false
var int bars_above_500 = 0 // 연속 회복 일수 카운터

varip float daily_buy_price1 = na
varip float daily_buy_price2 = na
varip float daily_waterfall_limit = na
varip int daily_buy_time = na
varip bool intrabar_buy_locked = false

// 매일 첫 봉에서 500일선 위 체류 여부 확인 및 변수 스냅샷
if barstate.isnew
    daily_buy_price1 := last_buy_price1
    daily_buy_price2 := last_buy_price2
    daily_waterfall_limit := waterfall_limit_price
    daily_buy_time := last_buy_time
    intrabar_buy_locked := false 
    
    // 500일선이 존재하고(not na), 그 위에 40거래일 연속 상회 체크
    if not na(ma500[1]) and close[1] >= ma500[1]
        bars_above_500 += 1
    else
        bars_above_500 := 0

// 해제 조건 2: 500일선 위 40일 연속 체류 시 심해 모드 해제
if bars_above_500 >= 40
    last_buy_under1 := false
    last_buy_under2 := false
    deep_underwater_mode := false
    if monitor_mode == 3
        monitor_mode := 0

// 심해 모드 판단 (매수 체결 2회 연속 500일선 미만)
if last_buy_under1 and last_buy_under2
    deep_underwater_mode := true

// 모드에 따른 점수 산출
// 심해 모드(C 모드)에서는 MA 점수 제외(BB+RSI), 기준점 2.1
float final_score = deep_underwater_mode ? math.round(score_bb + score_rsi, 2) : math.round(score_bb + score_ma + score_rsi, 2)
float threshold_A = 3.3
float threshold_B = 4.5
float threshold_C = 2.1

if in_date_range
    // 감시 진입 기준 분기 처리 (심해 모드 vs 일반 모드)
    if deep_underwater_mode
        // 심해 모드에서는 C전략만 가동
        if final_score >= threshold_C
            monitor_mode := 3
            days_maintained := 0
    else
        // 일반 모드에서는 A, B전략 가동
        if final_score >= threshold_B
            monitor_mode := 2
            days_maintained := 0
        else if final_score[1] < threshold_A and final_score >= threshold_A and monitor_mode != 2
            monitor_mode := 1
            days_maintained := 0
    
    // 감시 활성화 여부
    bool is_A_active = (not deep_underwater_mode and monitor_mode == 1 and final_score < threshold_A)
    bool is_B_active = (not deep_underwater_mode and monitor_mode == 2 and final_score < threshold_B)
    bool is_C_active = (deep_underwater_mode and monitor_mode == 3 and final_score < threshold_C)
    
    if is_A_active or is_B_active or is_C_active
        // 모니터링 유지 로직: 0.4 초과 상승 시에만 카운트 리셋
        if final_score > (final_score[1] + 0.4)
            days_maintained := 0
        else
            days_maintained += 1

        // A전략과 C전략은 즉시 만족(true), B전략은 confirm_days 대기
        bool cond_days = (monitor_mode == 1 or monitor_mode == 3) ? true : (days_maintained >= confirm_days)
        
        // 10일선 진입 조건 (물타기 시 2연속 상회)
        bool has_history = not na(daily_buy_price1)
        bool is_lower_price = has_history and (close < daily_buy_price1)
        
        bool cond_ma = (close >= entry_ma)
        if is_lower_price
            cond_ma := cond_ma and (close[1] >= entry_ma[1])
        
        // 최종 진입 실행
        if cond_days and cond_ma
            bool is_two_weeks_passed = na(last_buy_time) or (time - last_buy_time >= 14 * 86400000)
            bool is_a_blocked = not na(daily_waterfall_limit) and (close < daily_waterfall_limit)
            
            // ================== A 전략 ==================
            if monitor_mode == 1
                if is_two_weeks_passed and not is_a_blocked
                    strategy.entry("A", strategy.long)
                    label.new(bar_index, na, text="A\n" + str.tostring(close, "#.00"), yloc=yloc.belowbar, style=label.style_none, textcolor=color.orange, size=size.normal)
                    
                    if not na(daily_buy_price2) and not na(daily_buy_price1) and (daily_buy_price2 > daily_buy_price1) and (daily_buy_price1 > close)
                        waterfall_limit_price := close 
                    else
                        waterfall_limit_price := na
                        
                    last_buy_price2 := last_buy_price1
                    last_buy_price1 := close 
                    last_buy_time := time
                    
                    // 500일선이 없거나(상장 초기), 500일선 이상이면 초기화
                    if na(ma500) or close >= ma500
                        last_buy_under1 := false
                        last_buy_under2 := false
                        deep_underwater_mode := false
                    else
                        last_buy_under2 := last_buy_under1
                        last_buy_under1 := true
                    
                    monitor_mode := 0 
                    
                    if not intrabar_buy_locked
                        alert("WJ BUY A", alert.freq_once_per_bar)
                        intrabar_buy_locked := true 
                else
                    monitor_mode := 0 

            // ================== B 전략 ==================
            else if monitor_mode == 2
                strategy.entry("B", strategy.long)
                // [수정됨] B 텍스트 색상 변경
                label.new(bar_index, na, text="B\n" + str.tostring(close, "#.00"), yloc=yloc.belowbar, style=label.style_none, textcolor=color.rgb(157, 132, 223), size=size.normal)
                
                if not na(daily_buy_price2) and not na(daily_buy_price1) and (daily_buy_price2 > daily_buy_price1) and (daily_buy_price1 > close)
                    waterfall_limit_price := close 
                else
                    waterfall_limit_price := na

                last_buy_price2 := last_buy_price1
                last_buy_price1 := close 
                last_buy_time := time
                
                // 500일선이 없거나(상장 초기), 500일선 이상이면 초기화
                if na(ma500) or close >= ma500
                    last_buy_under1 := false
                    last_buy_under2 := false
                    deep_underwater_mode := false
                else
                    last_buy_under2 := last_buy_under1
                    last_buy_under1 := true
                
                monitor_mode := 0
                
                if not intrabar_buy_locked
                    alert("WJ BUY B", alert.freq_once_per_bar)
                    intrabar_buy_locked := true 

            // ================== C 전략 (심해 모드 전용) ==================
            else if monitor_mode == 3
                strategy.entry("C", strategy.long)
                // [수정됨] C 텍스트 색상 변경
                label.new(bar_index, na, text="C\n" + str.tostring(close, "#.00"), yloc=yloc.belowbar, style=label.style_none, textcolor=color.rgb(240, 133, 155), size=size.normal)
                
                if not na(daily_buy_price2) and not na(daily_buy_price1) and (daily_buy_price2 > daily_buy_price1) and (daily_buy_price1 > close)
                    waterfall_limit_price := close 
                else
                    waterfall_limit_price := na

                last_buy_price2 := last_buy_price1
                last_buy_price1 := close 
                last_buy_time := time
                
                // 500일선이 없거나(상장 초기), 500일선 이상이면 초기화
                if na(ma500) or close >= ma500
                    last_buy_under1 := false
                    last_buy_under2 := false
                    deep_underwater_mode := false
                else
                    last_buy_under2 := last_buy_under1
                    last_buy_under1 := true
                
                monitor_mode := 0
                
                if not intrabar_buy_locked
                    alert("WJ BUY C", alert.freq_once_per_bar)
                    intrabar_buy_locked := true 

// ==========================================
// 4. 최종 청산
// ==========================================
if barstate.islastconfirmedhistory
    strategy.close_all(comment=" ")
````
