# 7timesvolume

- url: https://www.tradingview.com/script/QijoyJv9/
- type: indicator
- pine_id: PUB;e3678afa0fde4afe9d6b13e768ead1b5
- version: 1.0

## Description

거래량 7배 폭증 검색기 (최근 4일 한정)

## Source Code

````pine
//@version=6
indicator("거래량 7배 폭증 검색기 (최근 4일 한정)", overlay=true)

// --- [ 설정 ] ---
multiplier = 7.0

// --- [ 로직 계산 ] ---
// 1. 핵심 조건: 해당 봉의 거래량이 '직전일(1봉 전)' 거래량의 7배 이상인지 체크
isConditionMet = volume >= volume[1] * multiplier

// 2. 시간 범위 제한: 현재 봉이 마지막(최신) 봉으로부터 3봉 이내인지 확인 (총 4개 봉)
// last_bar_index와 현재 bar_index를 비교하여 범위를 한정합니다.
isWithin4Days = (last_bar_index - bar_index) <= 3

// 3. 최종 표시 조건: 조건이 맞으면서 + 동시에 최근 4일 이내일 때만!
displayCondition = isConditionMet and isWithin4Days

// --- [ 시각화 ] ---
// 최근 4일 이내에 조건이 만족된 '그날'만 밝은 연두색 배경 표시
bgcolor(displayCondition ? color.new(color.lime, 60) : na)

// 최신 봉 상단에 안내 레이블 표시
if barstate.islast
    // 최근 4일 내에 한 번이라도 터졌는지 확인용
    hasRecentSpike = ta.barssince(isConditionMet) <= 3
    
    if hasRecentSpike
        var label statusLabel = na
        label.delete(statusLabel)
        
        daysAgo = ta.barssince(isConditionMet)
        labelStr = "🚀 최근 4일 내 폭증 감지\n" + 
                   (daysAgo == 0 ? "오늘 직전일 대비 7배↑" : str.tostring(daysAgo) + "일 전 7배↑")
            
        statusLabel := label.new(bar_index, high, labelStr, 
             color=color.rgb(76, 175, 80), 
             textcolor=color.white, 
             style=label.style_label_down,
             yloc=yloc.abovebar)

// --- [ 알람 및 스캐너용 출력 ] ---
plot(isWithin4Days and isConditionMet ? 1 : 0, "ScanValue", display=display.none)
````
