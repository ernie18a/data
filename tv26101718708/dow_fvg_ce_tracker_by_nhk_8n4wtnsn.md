# DOW + FVG CE Tracker by NHK

- url: https://www.tradingview.com/script/8n4wTnSN-DOW-FVG-CE-Tracker-by-NHK/
- type: indicator
- pine_id: PUB;743272d0a5814aca8f0ae44558ef748d
- version: 1.0

## Description

This Pine Script is a specialized technical analysis tool designed to track and visualize FVG (Fair Value Gaps)—specifically focusing on their Consequent Encroachment (CE), which is the 50% midpoint of the gap.It is built for traders who use Price Action or ICT concepts to identify where the market is likely to "retrace" or "fill" before continuing its move.1. Market Structure Context (DOW Theory)The script doesn't just look for any FVG; it operates within the context of market structure.Trend Tracking: It uses a lookback period (defaulting to 5 candles) to identify the highest highs and lowest lows.Market Structure Shift (MSS): When the price crosses these key points, it signals a potential change in trend. To keep your chart clean, the script resets the active FVG tracking when a significant break in structure occurs.2. Smart FVG DetectionBullish FVG (Green): Occurs when the Low of the current candle is higher than the High of the candle from two bars ago.Bearish FVG (Red): Occurs when the High of the current candle is lower than the Low of the candle from two bars ago.The CE Line: The script automatically calculates the exact 50% midpoint of each gap, as this is often where institutional orders are triggered.3. Dynamic "Elastic" Box ExtensionThe standout feature of this version is how the boxes behave:The Goal: The boxes extend from the moment they are born until they are "mitigated" or "touched."Until the Triangle: As soon as the price retraces and touches the CE (midpoint) of an FVG, a Triangle Label (green for up, red for down) is plotted.Precision Termination: The box continues to grow bar-by-bar until that triangle appears. At the exact moment of the touch, the box stops extending, providing a clear visual history of which gaps were filled and how long it took.4. Simplified VisualsNo Clutter: All step-counting numbers and complex multi-color schemes have been removed at your request.Color Coding: * Green Boxes/Triangles: Indicate bullish support zones and successful retracements.Red Boxes/Triangles: Indicate bearish resistance zones and successful retracements.High Visibility: The boxes are set with low opacity (85% transparency) to ensure you can still see the price action (candlesticks) clearly through them.Technical SummaryFeatureImplementationLogicPine Script V5Drawing LimitUp to 500 boxes and 500 lines simultaneouslyTriggerCE (50%) Midpoint touchExtensionReal-time bar_index updates until mitigationStructureIntegrated DOW Theory (High/Low tracking)

## Source Code

````pine
// @version=5
indicator("DOW + FVG CE Tracker (Extend to Next Triangle)", overlay=true, max_boxes_count=500, max_lines_count=500)

// --- 파라미터 ---
lookback = input.int(5, "DOW 구조 확인 기간")
fvg_threshold = input.float(0.0, "FVG 최소 크기", minval=0)

// --- 배열 및 박스 관리 변수 ---
var box last_bull_box = na
var line last_bull_line = na
var box last_bear_box = na
var line last_bear_line = na

var float[] active_bull_ce = array.new_float(0)
var float[] active_bear_ce = array.new_float(0)
var box[] active_bull_boxes = array.new_box(0)
var line[] active_bull_lines = array.new_line(0)
var box[] active_bear_boxes = array.new_box(0)
var line[] active_bear_lines = array.new_line(0)

// --- MSS 감지 (리셋 로직 생략 - 박스 지속성을 위해) ---
hi = ta.highest(high, lookback)
lo = ta.lowest(low, lookback)
var float ph1 = na
var float pl1 = na
if ta.change(hi)
    ph1 := hi[1]
if ta.change(lo)
    pl1 := lo[1]

// --- FVG 생성 및 관리 등록 ---
is_bullish_fvg = low[0] > high[2] and (low[0] - high[2]) > fvg_threshold
is_bearish_fvg = high[0] < low[2] and (low[2] - high[0]) > fvg_threshold

if is_bullish_fvg
    ce_val = high[2] + (low[0] - high[2]) / 2
    array.push(active_bull_ce, ce_val)
    b = box.new(left=bar_index - 2, top=low[0], right=bar_index, bottom=high[2], bgcolor=color.new(color.green, 85), border_color=color.new(color.green, 60))
    l = line.new(x1=bar_index - 2, y1=ce_val, x2=bar_index, y2=ce_val, color=color.new(color.green, 50))
    array.push(active_bull_boxes, b)
    array.push(active_bull_lines, l)

if is_bearish_fvg
    ce_val = low[2] - (low[2] - high[0]) / 2
    array.push(active_bear_ce, ce_val)
    b = box.new(left=bar_index - 2, top=low[2], right=bar_index, bottom=high[0], bgcolor=color.new(color.red, 85), border_color=color.new(color.red, 60))
    l = line.new(x1=bar_index - 2, y1=ce_val, x2=bar_index, y2=ce_val, color=color.new(color.red, 50))
    array.push(active_bear_boxes, b)
    array.push(active_bear_lines, l)

// --- [핵심] 모든 활성화된 박스를 매 캔들 실시간 연장 ---
if array.size(active_bull_boxes) > 0
    for i = 0 to array.size(active_bull_boxes) - 1
        box.set_right(array.get(active_bull_boxes, i), bar_index)
        line.set_x2(array.get(active_bull_lines, i), bar_index)

if array.size(active_bear_boxes) > 0
    for i = 0 to array.size(active_bear_boxes) - 1
        box.set_right(array.get(active_bear_boxes, i), bar_index)
        line.set_x2(array.get(active_bear_lines, i), bar_index)

// --- 터치 감지 및 "다음 세모 시점"에 박스 고정 ---
// 1. 상승 터치 (초록 세모)
if array.size(active_bull_ce) > 0
    for i = array.size(active_bull_ce) - 1 to 0
        if low <= array.get(active_bull_ce, i)
            // 세모 표시
            label.new(bar_index, low, text="", yloc=yloc.belowbar, color=color.green, style=label.style_triangleup, size=size.small)
            
            // 터치한 이 박스는 현재 봉(세모 봉)에서 연장을 멈춤
            box.set_right(array.get(active_bull_boxes, i), bar_index)
            line.set_x2(array.get(active_bull_lines, i), bar_index)
            
            // 관리 배열에서 제거하여 다음 봉부터는 연장되지 않게 함
            array.remove(active_bull_ce, i)
            array.remove(active_bull_boxes, i)
            array.remove(active_bull_lines, i)

// 2. 하락 터치 (빨간 세모)
if array.size(active_bear_ce) > 0
    for i = array.size(active_bear_ce) - 1 to 0
        if high >= array.get(active_bear_ce, i)
            // 세모 표시
            label.new(bar_index, high, text="", yloc=yloc.abovebar, color=color.red, style=label.style_triangledown, size=size.small)
            
            // 터치한 이 박스는 현재 봉(세모 봉)에서 연장을 멈춤
            box.set_right(array.get(active_bear_boxes, i), bar_index)
            line.set_x2(array.get(active_bear_lines, i), bar_index)
            
            // 관리 배열에서 제거
            array.remove(active_bear_ce, i)
            array.remove(active_bear_boxes, i)
            array.remove(active_bear_lines, i)
````
