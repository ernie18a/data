# Aegis The Alchemist Quantum [wjdtks255]

- url: https://www.tradingview.com/script/gFDJ3T0g/
- type: indicator
- pine_id: PUB;24b3f2fc1f6e4e62845629c6f1fdd921
- version: 2.0

## Description

Aegis The Alchemist Quantum: Trend-Momentum Hybrid [wjdtks255]
■ OVERVIEW
The Aegis The Alchemist Quantum is a premium multi-functional analysis tool that synthesizes trend direction with momentum exhaustion filters. It features a real-time data dashboard and a high-conviction signal engine to provide traders with a comprehensive view of market conditions at a single glance.

■ STRATEGIC ARCHITECTURE

Quantum Rail (HMA Trend Engine): Uses a specialized Hull Moving Average (HMA) to define the primary trend bias. The "Rail" changes color (Yellow/Purple) dynamically to visualize bullish or bearish dominance.

Momentum Crossover Logic: By smoothing RSI with an EMA, the script captures precise entry points when momentum breaks the 50-level, but only in the direction of the Quantum Rail’s trend.

Real-Time Analytics Dashboard: A sophisticated UI that tracks Exchange data, Trend bias, Day Range, and Relative Power (RSI distance from mean) in real-time.

■ KEY FEATURES

Dual-Language Support: Fully customizable UI in both English and Korean.

Adaptive Signals: 'L' (Long) and 'S' (Short) labels are placed strategically based on confluence between trend and momentum.

Power Index: A unique calculation showing the intensity of the current move as a percentage.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © wjdtks255

//@version=6
// Aegis Premium Dashboard Series: The Alchemist Quantum
// Powered by wjdtks255
indicator("Aegis The Alchemist Quantum [wjdtks255]", overlay=true, max_lines_count=500, max_labels_count=500)

// =========================================================================
// 1. Inputs Configuration (설정 - 테이블 언어 직관성 업그레이드 완벽 반영)
// =========================================================================
group_ui    = "Dashboard Visual Settings (대시보드 UI 설정)"
// 형님의 의견을 반영하여 'System Language'에서 'Dashboard Language'로 직관성 극대화
lang_opt    = input.string("English", "Dashboard Language (대시보드 언어)", options=["English", "Korean"], group=group_ui)
v_pos       = input.string("Middle", "Vertical Layout Position (수직 배치 위치)", options=["Top", "Middle", "Bottom"], group=group_ui)
h_pos       = input.string("Right",  "Horizontal Layout Position (수평 배치 위치)", options=["Left", "Center", "Right"], group=group_ui)
db_sz       = input.string("Normal", "Dashboard Display Size (대시보드 표시 크기)", options=["Small", "Normal", "Large"], group=group_ui)
up_c        = input.color(#F0B90B, "Bullish Trend Rail Color (상승 추세 레일 색상)", group=group_ui)
dn_c        = input.color(#9C27B0, "Bearish Trend Rail Color (하락 추세 레일 색상)", group=group_ui)

group_logic = "Core Technical Logic Settings (핵심 연산 알고리즘 설정)"
rsi_l       = input.int(14, "RSI Momentum Period (RSI 모멘텀 주기)", minval=1, group=group_logic)
hma_l       = input.int(60, "Hull MA Trend Period (HMA 추세 필터 주기)", minval=1, group=group_logic)

// =========================================================================
// 2. Core Mathematical Calculations (기술적 지표 연산)
// =========================================================================
src   = close
hma_v = ta.hma(src, hma_l)
is_up = hma_v > hma_v[1]

rsi_v = ta.rsi(src, rsi_l)
rsi_m = ta.ema(rsi_v, 5)

// 모멘텀 돌파 및 추세 정렬 매트릭스 조건문
l_sig = ta.crossover(rsi_m, 50) and is_up
s_sig = ta.crossunder(rsi_m, 50) and not is_up

// =========================================================================
// 3. Premium Visual Plotting (메인 레일 및 시그널 쉐이프 출력)
// =========================================================================
// Dynamic Trend Follow Quantum Rail
plot(hma_v, "Quantum Energy Rail", color=is_up ? up_c : dn_c, linewidth=3)

// 파인스크립트 v6 규격 매개변수 지정형 고가시성 레이블 출력
plotshape(l_sig, title="Long Entry Signal", style=shape.labelup, location=location.belowbar, color=up_c, size=size.small, text="L", textcolor=color.black)
plotshape(s_sig, title="Short Entry Signal", style=shape.labeldown, location=location.abovebar, color=dn_c, size=size.small, text="S", textcolor=color.white)

// =========================================================================
// 4. Quantum Live Dashboard UI Matrix (실시간 연금술 대시보드 빌드)
// =========================================================================
f_pos_set(_v, _h) =>
    _v == "Top" ? (_h == "Left" ? position.top_left : _h == "Center" ? position.top_center : position.top_right) :
     _v == "Middle" ? (_h == "Left" ? position.middle_left : _h == "Center" ? position.middle_center : position.middle_right) :
     (_h == "Left" ? position.bottom_left : _h == "Center" ? position.bottom_center : position.bottom_right)

f_size_set(_s) =>
    _s == "Small" ? size.small : _s == "Large" ? size.large : size.normal

var table dash = table.new(f_pos_set(v_pos, h_pos), 2, 8, bgcolor=color.new(color.black, 40), border_width=1, border_color=color.new(color.gray, 70))

if barstate.islast
    ko = lang_opt == "Korean"
    s  = f_size_set(db_sz)
    
    // Grid 1. Exchange Info
    table.cell(dash, 0, 0, ko ? "거래소" : "Exchange", text_color=color.gray, text_size=s)
    table.cell(dash, 1, 0, syminfo.prefix, text_color=color.white, text_size=s)

    // Grid 2. Real-time Price
    table.cell(dash, 0, 1, ko ? "현재가" : "Price", text_color=color.gray, text_size=s)
    table.cell(dash, 1, 1, str.tostring(close, format.mintick), text_color=color.yellow, text_size=s)

    // Grid 3. Macro Trend Direction
    table.cell(dash, 0, 2, ko ? "추세" : "Trend", text_color=color.white, text_size=s)
    table.cell(dash, 1, 2, is_up ? (ko ? "상승" : "BULL") : (ko ? "하락" : "BEAR"), text_color=is_up ? up_c : dn_c, text_size=s)
    
    // Grid 4. High-Low Day Range (일일 변동성 폭 연산)
    d_h = request.security(syminfo.tickerid, "D", high), d_l = request.security(syminfo.tickerid, "D", low)
    d_rng = ((d_h - d_l) / math.max(d_l, 1)) * 100 
    table.cell(dash, 0, 3, ko ? "일일 변동" : "Day Range", text_color=color.gray, text_size=s)
    table.cell(dash, 1, 3, str.tostring(d_rng, "#.##") + "%", text_color=color.white, text_size=s)
    
    // Grid 5. Today Return % (당일 주가 변동률)
    d_o = request.security(syminfo.tickerid, "D", open)
    d_chg = ((close - d_o) / math.max(d_o, 1)) * 100
    table.cell(dash, 0, 4, ko ? "오늘 수익" : "Today %", text_color=color.gray, text_size=s)
    table.cell(dash, 1, 4, str.tostring(d_chg, "#.##") + "%", text_color=d_chg >= 0 ? color.lime : color.red, text_size=s)

    // Grid 6. Relative Momentum Power
    pwr = math.abs(rsi_v - 50) * 2
    table.cell(dash, 0, 5, ko ? "강도" : "Power", text_color=color.white, text_size=s)
    table.cell(dash, 1, 5, str.tostring(pwr, "0") + "%", text_color=color.yellow, text_size=s)

    // Grid 7. Raw RSI Value
    table.cell(dash, 0, 6, "RSI", text_color=color.gray, text_size=s)
    table.cell(dash, 1, 6, str.tostring(rsi_v, "#.##"), text_color=color.white, text_size=s)

    // Grid 8. Dynamic Execution Signal Status
    sig_t = l_sig ? (ko ? "매수" : "BUY") : s_sig ? (ko ? "매도" : "SELL") : (ko ? "대기" : "WAIT")
    table.cell(dash, 0, 7, ko ? "신호" : "Signal", text_color=color.black, bgcolor=color.gray, text_size=s)
    table.cell(dash, 1, 7, sig_t, text_color=color.black, bgcolor=l_sig ? up_c : s_sig ? dn_c : color.gray, text_size=s)

// =========================================================================
// 5. Algorithmic Webhook & Real-time Execution Alerts (얼럿 시스템 탑재)
// =========================================================================
alertcondition(l_sig, title="Alchemist Quantum BUY", message="[The Alchemist] Quantum BUY Signal Triggered! Trend & Momentum Aligned. Price: {{close}}")
alertcondition(s_sig, title="Alchemist Quantum SELL", message="[The Alchemist] Quantum SELL Signal Triggered! Trend & Momentum Collapsed. Price: {{close}}")
````
