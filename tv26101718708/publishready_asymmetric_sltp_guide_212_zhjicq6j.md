# Publish-Ready Asymmetric SL/TP Guide (212)

- url: https://www.tradingview.com/script/ZHjIcQ6j/
- type: indicator
- pine_id: PUB;00af2035f37547ba9b7b74585a680107
- version: 1.0

## Description

📌 Overview
In a fast-paced scalping or day trading environment, every second counts. You don't have the luxury to manually draw risk-reward boxes or calculate target prices in your head.

This indicator is an Asymmetric SL/TP Guide Band built on the latest Pine Script v6 engine. It instantly visualizes your predefined take-profit and stop-loss point levels based on the real-time current price.

💡 Key Features & Asymmetric Layout
Unlike conventional symmetric bands, this script introduces a unique Asymmetric Layout designed to optimize the trader's field of view:

📈 TP - Right Extension (Future): The Take-Profit lines extend to the right (future space). This allows you to intuitively measure the distance to your target using the empty space on the right side of the chart.

📉 SL - Left Extension (Past): The Stop-Loss lines extend to the left (past space). This enables you to instantly compare your risk levels with recent candle wicks, support levels, or order blocks in real-time.

🏷️ Dynamic Price Labels: It doesn't just show points (e.g., +50pt); it continuously calculates and displays the exact execution price inside the labels according to price fluctuations.

⚙️ Fully Customizable Inputs
Target Points: Configurable TP2, TP1, SL1, and SL2 levels.

Layout Settings: Adjust the extension lengths (in bars) for both TP and SL independently.

Theme Aesthetics: Change colors to perfectly match your chart setup (Dark/Light mode).

## Source Code

````pine
//@version=6
indicator("Publish-Ready Asymmetric SL/TP Guide (v6)", overlay=true, max_labels_count=20, max_lines_count=20)

// =========================================================================
// 1. INPUT SETTINGS (설정 창에서 모든 수치 조절 가능하도록 그룹화)
// =========================================================================
var string G_TARGETS = "1. 목표 포인트 설정 (Target Points)"
tp2_val = input.int(100, title="익절 대형 (TP2 Points)", group=G_TARGETS, minval=1)
tp1_val = input.int(50,  title="익절 소형 (TP1 Points)", group=G_TARGETS, minval=1)
sl1_val = input.int(25,  title="손절 소형 (SL1 Points)", group=G_TARGETS, minval=1)
sl2_val = input.int(50,  title="손절 대형 (SL2 Points)", group=G_TARGETS, minval=1)

var string G_VISUALS = "2. 라인 및 라벨 레이아웃 (Layout)"
tp_length   = input.int(45, title="익절 미래 연장 길이 (TP Right Length)", group=G_VISUALS, minval=0)
sl_length   = input.int(45, title="손절 과거 연장 길이 (SL Left Length)", group=G_VISUALS, minval=0)
label_space = input.int(3,  title="라벨 자석 여백 (Label Space)", group=G_VISUALS, minval=0)

var string G_COLORS = "3. 디자인 및 색상 (Theme)"
tp_color = input.color(color.green, title="익절 라인 색상 (TP Color)", group=G_COLORS)
sl_color = input.color(color.red,   title="손절 라인 색상 (SL Color)")

// =========================================================================
// 2. 실시간 오브젝트 핸들링 변수 선언
// =========================================================================
var line l_tp2 = na, var line l_tp1 = na, var line l_sl1 = na, var line l_sl2 = na
var label lbl_tp2 = na, var label lbl_tp1 = na, var label lbl_sl1 = na, var label lbl_sl2 = na

// =========================================================================
// 3. 메인 드로잉 로직 (v6 실시간 렌더링 가비지 컬렉션 적용)
// =========================================================================
if barstate.islast
    // 퍼블리싱 스크립트 필수: 캔들 움직일 때 잔상 제거 및 메모리 클린
    line.delete(l_tp2), line.delete(l_tp1), line.delete(l_sl1), line.delete(l_sl2)
    label.delete(lbl_tp2), label.delete(lbl_tp1), label.delete(lbl_sl1), label.delete(lbl_sl2)
    
    float cp = close // 현재가 기준 레벨 체킹
    int current_idx = bar_index
    
    // Y축 가격 좌표 계산
    float tp2_y = cp + tp2_val
    float tp1_y = cp + tp1_val
    float sl1_y = cp - sl1_val
    float sl2_y = cp - sl2_val
    
    // [익절 라인] 현재가 위치에서 '오른쪽(미래)'으로 연장
    int tp_end_idx = current_idx + tp_length
    l_tp2 := line.new(x1=current_idx, y1=tp2_y, x2=tp_end_idx, y2=tp2_y, color=tp_color, width=2)
    l_tp1 := line.new(x1=current_idx, y1=tp1_y, x2=tp_end_idx, y2=tp1_y, color=tp_color, width=1, style=line.style_dashed)
    
    // [손절 라인] 현재가 위치에서 '왼쪽(과거)'으로 연장
    int sl_end_idx = current_idx - sl_length
    l_sl1 := line.new(x1=current_idx, y1=sl1_y, x2=sl_end_idx, y2=sl1_y, color=sl_color, width=1, style=line.style_dashed)
    l_sl2 := line.new(x1=current_idx, y1=sl2_y, x2=sl_end_idx, y2=sl2_y, color=sl_color, width=2)
    
    // [라벨 출력] 방향에 맞는 텍스트 정렬 스타일(style) 지정
    // 익절 라벨: 우측 끝에 붙고 글자는 왼쪽 정렬
    lbl_tp2 := label.new(x=tp_end_idx + label_space, y=tp2_y, text="TP2 +" + str.tostring(tp2_val) + "pt (" + str.tostring(tp2_y, "#.#") + ")", color=color.new(tp_color, 100), textcolor=tp_color, style=label.style_label_left)
    lbl_tp1 := label.new(x=tp_end_idx + label_space, y=tp1_y, text="TP1 +" + str.tostring(tp1_val) + "pt (" + str.tostring(tp1_y, "#.#") + ")", color=color.new(tp_color, 100), textcolor=tp_color, style=label.style_label_left)
    
    // 손절 라벨: 좌측 끝에 붙고 글자는 오른쪽 정렬
    lbl_sl1 := label.new(x=sl_end_idx - label_space, y=sl1_y, text="(" + str.tostring(sl1_y, "#.#") + ") -" + str.tostring(sl1_val) + "pt SL1", color=color.new(sl_color, 100), textcolor=sl_color, style=label.style_label_right)
    lbl_sl2 := label.new(x=sl_end_idx - label_space, y=sl2_y, text="(" + str.tostring(sl2_y, "#.#") + ") -" + str.tostring(sl2_val) + "pt SL2", color=color.new(sl_color, 100), textcolor=sl_color, style=label.style_label_right)
````
