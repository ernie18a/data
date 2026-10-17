# Aegis Pure Trendline Matrix [wjdtks255]

- url: https://www.tradingview.com/script/PkmWLbKa/
- type: indicator
- pine_id: PUB;95e3a09888f744ea8444fbf48d9ebfad
- version: 1.0

## Description

Aegis Pure Trendline Matrix [wjdtks255]

■ OVERVIEW
The Aegis Pure Trendline Matrix is an automated geometric charting engine designed to project high-precision support and resistance trendlines. By utilizing algorithmic pivot mechanics, this script identifies true structural market anchors, draws real-time diagonal barriers, and dynamically truncates them the exact moment a breakout or breakdown is confirmed by price action.

■ KEY FEATURES

Algorithmic Pivot Anchoring: Eliminates human drawing bias by calculating mathematically optimized swing highs and swing lows to anchor diagonal lines.

Dynamic Breakout Truncation: Automatically stops extending a trendline immediately when the price breaks above resistance or below support, showcasing clean, historical breakout nodes.

Performance Optimization Matrix: Built-in array memory management that limits active drawings, preventing chart lag and maintaining fluid refresh rates.

■ 개요 (Korean)
Aegis Pure Trendline Matrix는 정밀한 지지와 저항 빗각 추세선을 실시간으로 자동 생성하는 기하학적 차트 엔진입니다. 알고리즘 기반의 피벗 메커니즘을 통해 시장의 구조적 변곡점을 감지하며, 가격이 선을 돌파하거나 이탈하는 즉시 연장을 자동으로 종료하여 돌파 시점을 명확하게 시각화합니다.

■ 핵심 기능

알고리즘 기반 피벗 앵커링: 주관적인 작도 편향을 완전히 배제하고, 수학적으로 검증된 스윙 하이/로우를 계산하여 정확한 추세선을 연결합니다.

동적 돌파 마감 로직: 저항선 상방 돌파 또는 지지선 하방 이탈이 마감 봉 기준으로 확정되는 순간 선의 연장을 차단하여 깔끔한 타점을 보여줍니다.

차트 최적화 매트릭스: 배열(Array) 구조의 빌트인 메모리 관리 시스템을 탑재하여 불필요한 과거 선들을 정리하고 차트 렉을 방지합니다.

■ Credits & Acknowledgments
This charting script utilizes standard open-source pivot detection algorithms. Sincere gratitude goes to the global TradingView developer community for pioneering automated drawing scripts and memory optimization techniques using arrays.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © wjdtks255

//@version=6
indicator("Aegis Pure Trendline Matrix [wjdtks255]", overlay=true, max_lines_count=100)

// =========================================================================
// 1. Input Settings
// =========================================================================
lookback        = input.int(20, "Pivot Lookback (Drawing Precision)", minval=2)
line_color_up   = input.color(color.new(#00FF00, 30), "Ascending Trendline (Support)")
line_color_down = input.color(color.new(#FF0000, 30), "Descending Trendline (Resistance)")

// =========================================================================
// 2. Pivot Point Detection
// =========================================================================
ph = ta.pivothigh(high, lookback, lookback)
pl = ta.pivotlow(low, lookback, lookback)

// =========================================================================
// 3. Variable & Array Management for Chart Optimization
// =========================================================================
var float last_ph_price = na
var int last_ph_index = na
var float last_pl_price = na
var int last_pl_index = na

var line current_upper_line = na
var line current_lower_line = na

// Arrays to handle memory allocation and prevent chart lag
var line[] upper_lines_array = array.new_line()
var line[] lower_lines_array = array.new_line()

// =========================================================================
// 4. Descending Trendline (Resistance) & Breakout Discontinuation Logic
// =========================================================================
if not na(ph)
    if not na(last_ph_price) and ph < last_ph_price
        // Discontinue the extension of the previous line before creating a new one
        if not na(current_upper_line)
            line.set_extend(current_upper_line, extend.none)
        
        // Generate Descending Resistance Line
        current_upper_line := line.new(last_ph_index, last_ph_price, bar_index[lookback], ph, color=line_color_down, width=2, extend=extend.right)
        array.push(upper_lines_array, current_upper_line)
        
        // Memory Management: Automatically purge oldest lines to maintain performance
        if array.size(upper_lines_array) > 15
            line.delete(array.shift(upper_lines_array))

    last_ph_price := ph
    last_ph_index := bar_index[lookback]

// Terminate line extension instantly when the current price breaks out above the resistance line
if not na(current_upper_line) and ta.crossover(close, line.get_price(current_upper_line, bar_index))
    line.set_extend(current_upper_line, extend.none)
    current_upper_line := na

// =========================================================================
// 5. Ascending Trendline (Support) & Breakdown Discontinuation Logic
// =========================================================================
if not na(pl)
    if not na(last_pl_price) and pl > last_pl_price
        // Discontinue the extension of the previous line before creating a new one
        if not na(current_lower_line)
            line.set_extend(current_lower_line, extend.none)
            
        // Generate Ascending Support Line
        current_lower_line := line.new(last_pl_index, last_pl_price, bar_index[lookback], pl, color=line_color_up, width=2, extend=extend.right)
        array.push(lower_lines_array, current_lower_line)
        
        // Memory Management: Automatically purge oldest lines to maintain performance
        if array.size(lower_lines_array) > 15
            line.delete(array.shift(lower_lines_array))

    last_pl_price := pl
    last_pl_index := bar_index[lookback]

// Terminate line extension instantly when the current price breaks down below the support line
if not na(current_lower_line) and ta.crossunder(close, line.get_price(current_lower_line, bar_index))
    line.set_extend(current_lower_line, extend.none)
    current_lower_line := na
````
