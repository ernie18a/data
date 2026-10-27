# Aegis HMA Sentinel [wjdtks255]

- url: https://www.tradingview.com/script/WR4lI96h/
- type: indicator
- pine_id: PUB;d5434fea1b7141938a2eac47d884c7c1
- version: 2.0

## Description

Aegis HMA Sentinel [wjdtks255]: Multi-Filter Trend Execution System

■ OVERVIEW
Aegis HMA Sentinel is a comprehensive trend-following execution framework designed for traders who demand statistical confirmation before entry. By synthesizing Hull Moving Average (HMA) with a Multi-Layer Filtering Engine, it identifies high-conviction breakout opportunities while managing risk through an integrated position-sizing calculator.

■ STRATEGIC ARCHITECTURE

Dual-Trend Synchronization: Combines current timeframe HMA with an optimized HTF (Higher Timeframe) filter to ensure trades are only executed in the direction of the dominant market tide.

The "White Line" Guardian: A long-term baseline that acts as a structural filter, preventing "Long" entries in bearish cycles and "Short" entries in bullish cycles.

Multi-Dimensional Filters:

Volume Filter: Detects institutional participation (1.5x average).

Candle Momentum Filter: Validates the strength of the breakout bar’s body.

Live Analytics Dashboard: A real-time performance tracker displaying Win Rate, Cumulative PnL, Total R/R, and Recommended Position Size based on your account equity.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © wjdtks255

//@version=6
// Aegis Premium Trend Series: HMA Sentinel
// Powered by wjdtks255
indicator("Aegis HMA Sentinel [wjdtks255]", overlay=true, precision=2, max_labels_count=500)

// =========================================================================
// 1. Settings & Localization (글로벌 셋업 및 인풋 그룹화)
// =========================================================================
group_gen   = "Global System Settings (일반 시스템 설정)"
i_lang      = input.string("English", "System Language (시스템 언어)", options=["English", "Korean"], group=group_gen)
ko          = i_lang == "Korean"

group_logic = "Core Filter & Logic Settings (핵심 필터 및 로직 설정)"
sensitivity = input.int(15, "HMA Sensitivity (HMA 민감도)", group=group_logic)
i_whiteLen  = input.int(100, "White Line Length (화이트 라인 주기)", group=group_logic)
tpMult      = input.float(2.0, "TP Multiplier (익절 타겟 배수)", group=group_logic)
slOffset    = input.float(1.2, "SL Multiplier (손절 버퍼 배수)", group=group_logic)
i_htfTime   = input.timeframe("60", "HTF Timeframe (상위 타임프레임)", group=group_logic)

i_useVol    = input.bool(true, "Use Volume Filter (거래량 필터)", group=group_logic)
i_useCandle = input.bool(true, "Use Candle Pattern (장대봉 몸통 필터)", group=group_logic)
i_useWhite  = input.bool(true, "Use White Line Filter (화이트 라인 필터)", group=group_logic)

group_disp  = "Display Line Options (차트 작도 표시 옵션)"
i_showEntry = input.bool(true, "Show Entry Price (진입가 표시)", group=group_disp)
i_showTP    = input.bool(true, "Show TP Line Price (익절가 표시)", group=group_disp)
i_showSL    = input.bool(true, "Show SL Line Price (손절가 표시)", group=group_disp)

group_stats = "Dashboard Statistics Settings (통계 대시보드 설정)"
i_statsLookback = input.int(20, "Stats History Lookback (통계 거래 횟수)", group=group_stats)
i_tablePos      = input.string("Top Right", "Dashboard Position (대시보드 위치)", options=["Top Right", "Top Left", "Top Center", "Bottom Right", "Bottom Left", "Bottom Center"], group=group_stats)
i_tableSize     = input.string("Small", "Dashboard Display Size (대시보드 크기)", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=group_stats)

group_style = "Visual Custom Style Settings (라인 디자인 설정)"
tpColor     = input.color(color.aqua, "TP Target Line Color (익절선 색상)", group=group_style)
slColor     = input.color(color.yellow, "SL Target Line Color (손절선 색상)", group=group_style)
whiteColor  = input.color(color.white, "White Trend Line Color (화이트선 색상)", group=group_style)
i_lineWidth = input.int(3, "Target Line Width (선 두께)", group=group_style)
i_lineStyle = input.string("Solid", "Target Line Style (선 모양)", options=["Solid", "Dotted", "Dashed"], group=group_style)
i_labelBg   = input.color(color.new(color.black, 30), "Price Label Background", group=group_style)
i_labelText = input.color(color.white, "Price Label Text Color", group=group_style)
i_labelSize = input.string("Normal", "Price Label Font Size", options=["Small", "Normal", "Large", "Huge"], group=group_style)

// [부활] 편의성 그룹 및 이전 기록 숨기기 스위치 형님 요청 반영 완료
group_conv  = "Convenience Settings (편의성 설정)"
i_hidePast  = input.bool(false, "Hide Past Records (이전 기록 숨기기)", group=group_conv)

// 스타일 핸들러 함수
get_shape(s) => s == "Dotted" ? line.style_dotted : s == "Dashed" ? line.style_dashed : line.style_solid
get_size(s)  => s == "Small" ? size.small : s == "Large" ? size.large : s == "Huge" ? size.huge : size.normal
get_table_pos(p) => p == "Top Right" ? position.top_right : p == "Top Left" ? position.top_left : p == "Top Center" ? position.top_center : p == "Bottom Right" ? position.bottom_right : p == "Bottom Left" ? position.bottom_left : position.bottom_center
get_table_size(s) => s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : s == "Large" ? size.large : size.huge

// =========================================================================
// 2. Core Logic Math & Filters (추세 및 조건 연산)
// =========================================================================
hma       = ta.hma(close, sensitivity)
whiteLine = ta.hma(close, i_whiteLen)
isTrendUp = close > hma

[htfClose, htfHma] = request.security(syminfo.tickerid, i_htfTime, [close, ta.hma(close, sensitivity)])
isHTFUp = htfClose > htfHma

volFilter        = not i_useVol or (volume > ta.sma(volume, 10) * 1.5)
candleFilter     = not i_useCandle or (math.abs(close - open) > ta.sma(math.abs(close[1] - open[1]), 10))
whiteFilterLong  = not i_useWhite or (close > whiteLine)
whiteFilterShort = not i_useWhite or (close < whiteLine)

atr = ta.atr(14)
longSignal  = isTrendUp and ta.crossover(close, ta.highest(high, 5)[1]) and volFilter and candleFilter and whiteFilterLong
shortSignal = not isTrendUp and ta.crossunder(close, ta.lowest(low, 5)[1]) and volFilter and candleFilter and whiteFilterShort

var int lastSignal = 0
actualLong  = longSignal and lastSignal != 1
actualShort = shortSignal and lastSignal != -1

// =========================================================================
// 3. Statistics Handling Array Matrix (배열 선언)
// =========================================================================
var float[] winLossArray = array.new_float(0)
var float[] rrArray      = array.new_float(0)
var int[] durationArray   = array.new_int(0)
var float totalProfitLoss = 0.0

// =========================================================================
// 4. Execution Visualization & Variable Optimization (과거 기록 온/오프 엔진)
// =========================================================================
// 과거 기록 숨기기 기능 추적을 위해 싱글톤 작도 포인터 보존
var line singleSL = na, var line singleTP = na
var label singlePrice = na, var label singleSig = na, var label singleHitSL = na

// 실시간 상태 업데이트용 포인터 변수 (매 바마다 인스턴스 추적)
var line activeSL = na, var line activeTP = na
var label activePrice = na
var float entryP = na, var float targetP = na, var float stopP = na
var int entryTime = na
var bool isActive = false

if actualLong or actualShort
    // '이전 기록 숨기기'가 켜져 있으면 바로 직전 작도물들 강제 소거
    if i_hidePast
        line.delete(singleSL), line.delete(singleTP)
        label.delete(singlePrice), label.delete(singleSig), label.delete(singleHitSL)

    lastSignal := actualLong ? 1 : -1
    isActive   := true
    entryP     := close
    entryTime  := bar_index
    targetP    := actualLong ? close + (atr * tpMult) : close - (atr * tpMult)
    stopP      := actualLong ? low - (atr * slOffset) : high + (atr * slOffset)
    
    string p_info = ""
    if i_showEntry
        p_info := p_info + (ko ? "진입: " : "Entry: ") + str.tostring(entryP, "#.#") + "\n"
    if i_showTP
        p_info := p_info + (ko ? "익절: " : "TP: ") + str.tostring(targetP, "#.#") + "\n"
    if i_showSL
        p_info := p_info + (ko ? "손절: " : "SL: ") + str.tostring(stopP, "#.#")

    // 새로운 라인/레이블 객체 생성 (var를 쓰지 않아 i_hidePast가 꺼져있을 땐 과거 선이 보존됨)
    lbl_sig = label.new(bar_index, actualLong ? low : high, (actualLong ? "🚀 LONG" : "💀 SHORT"), color=actualLong ? color.green : color.red, style=actualLong ? label.style_label_up : label.style_label_down, textcolor=color.white, size=get_size(i_labelSize))
    ln_sl   = line.new(bar_index, stopP, bar_index + 1, stopP, color=slColor, width=i_lineWidth, style=get_shape(i_lineStyle))
    ln_tp   = line.new(bar_index, targetP, bar_index + 1, targetP, color=tpColor, width=i_lineWidth, style=get_shape(i_lineStyle))
    lbl_prc = label.new(bar_index, targetP, p_info, color=i_labelBg, textcolor=i_labelText, style=label.style_label_left, size=get_size(i_labelSize))

    // 상태 추적 포인터에 대입
    activeSL := ln_sl, activeTP := ln_tp, activePrice := lbl_prc
    
    // 숨기기용 포인터 홀더에 백업
    singleSL := ln_sl, singleTP := ln_tp, singlePrice := lbl_prc, singleSig := lbl_sig

if isActive
    line.set_x2(activeSL, bar_index), line.set_x2(activeTP, bar_index)
    label.set_x(activePrice, bar_index + 1)
    
    hitTP = (lastSignal == 1 and high >= targetP) or (lastSignal == -1 and low <= targetP)
    hitSL = (lastSignal == 1 and low <= stopP) or (lastSignal == -1 and high >= stopP)
    
    if hitSL
        lbl_hsl = label.new(bar_index, stopP, "💀 SL", color=color.orange, style=label.style_label_center, textcolor=color.white, size=get_size(i_labelSize))
        if i_hidePast
            singleHitSL := lbl_hsl

    if hitTP or hitSL
        isActive := false
        float rr_val = math.abs(targetP - entryP) / math.max(0.000001, math.abs(entryP - stopP))
        totalProfitLoss := totalProfitLoss + (hitTP ? 100.0 * rr_val : -100.0)
        array.push(winLossArray, hitTP ? 1.0 : 0.0)
        array.push(durationArray, bar_index - entryTime)
        array.push(rrArray, hitTP ? rr_val : -1.0)
        
        if array.size(winLossArray) > i_statsLookback
            array.shift(winLossArray), array.shift(rrArray), array.shift(durationArray)

// =========================================================================
// 5. Statistics Dashboard Grid Matrix (대시보드 출력부)
// =========================================================================
var table statsTable = table.new(get_table_pos(i_tablePos), 2, 5, bgcolor=color.new(color.black, 10), border_width=1, border_color=color.gray)

if barstate.islast
    float winRate = array.size(winLossArray) > 0 ? (array.sum(winLossArray) / array.size(winLossArray)) * 100 : 0
    float totalRR = array.size(rrArray) > 0 ? array.sum(rrArray) : 0
    float avgDur  = array.size(durationArray) > 0 ? array.sum(durationArray) / array.size(durationArray) : 0
    t_size = get_table_size(i_tableSize)
    
    table.cell(statsTable, 0, 0, ko ? "승률" : "Win Rate", text_color=color.white, text_size=t_size)
    table.cell(statsTable, 1, 0, str.tostring(winRate, "0.0") + "%", text_color=winRate >= 50 ? color.green : color.red, text_size=t_size)
    table.cell(statsTable, 0, 1, ko ? "누적 수익" : "Total PnL", text_color=color.white, text_size=t_size)
    table.cell(statsTable, 1, 1, "$" + str.tostring(totalProfitLoss, "0.00"), text_color=totalProfitLoss >= 0 ? color.aqua : color.orange, text_size=t_size)
    table.cell(statsTable, 0, 2, ko ? "총 수익비" : "Total R:R", text_color=color.white, text_size=t_size)
    table.cell(statsTable, 1, 2, str.tostring(totalRR, "0.00"), text_color=totalRR >= 0 ? color.aqua : color.orange, text_size=t_size)
    table.cell(statsTable, 0, 3, (ko ? "상위 추세" : "HTF Trend") + " (" + i_htfTime + ")", text_color=color.white, text_size=t_size)
    table.cell(statsTable, 1, 3, isHTFUp ? "UP ⬆️" : "DOWN ⬇️", text_color=isHTFUp ? color.green : color.red, text_size=t_size)
    table.cell(statsTable, 0, 4, ko ? "평균 소요(봉)" : "Avg Duration", text_color=color.white, text_size=t_size)
    table.cell(statsTable, 1, 4, str.tostring(avgDur, "0.0"), text_color=color.yellow, text_size=t_size)

// =========================================================================
// 6. Visual Candlestick & Rail Plotting (렌더링)
// =========================================================================
barcolor(isTrendUp ? #00ff08 : #ff0055)
plot(hma, "HMA Sentinel Rail", color=isTrendUp ? color.new(#00ff08, 80) : color.new(#ff0055, 80), linewidth=2)
plot(whiteLine, "White Filter Line", color=color.new(whiteColor, 20), linewidth=2)

// =========================================================================
// 7. Automation Real-time Execution Alerts (얼럿 시스템)
// =========================================================================
alertcondition(actualLong, title="HMA Sentinel LONG Entry", message="[HMA Sentinel] Bullish Signal Confirmed! Entering LONG Position. Price: {{close}}")
alertcondition(actualShort, title="HMA Sentinel SHORT Entry", message="[HMA Sentinel] Bearish Signal Confirmed! Entering SHORT Position. Price: {{close}}")
````
