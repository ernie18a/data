# tttt

- url: https://www.tradingview.com/script/eAJGcQqn-tttt/
- type: indicator
- pine_id: PUB;d3f162a8fdd643d4a436c8068bb45280
- version: 1.0

## Description

this is a test indicator 
for testing only and goog good good good goood good good good good good good good

## Source Code

````pine
//@version=5
indicator("極速框", overlay=true, max_lines_count=500, max_labels_count=500)

// =====================================
// === 自定義顏色設定面板 ===
// =====================================
grp_colors   = "自訂線條與訊號顏色"
col_fib_0    = input.color(color.gray, title="0 軸顏色", group=grp_colors)
col_fib_1    = input.color(color.gray, title="1 軸顏色", group=grp_colors)
col_fib_38   = input.color(color.red, title="3.8 軸顏色", group=grp_colors)
col_long_58  = input.color(color.green, title="多方 5.8 軸與訊號顏色", group=grp_colors)
col_short_58 = input.color(color.green, title="空方 5.8 軸與訊號顏色", group=grp_colors)

// === 定義前一根 K 棒的實體高低點 ===
body_high_prev = math.max(open[1], close[1])
body_low_prev  = math.min(open[1], close[1])

// === 定義黑吞與紅吞 ===
bearish_swallow = close < body_low_prev
bullish_swallow = close > body_high_prev

// =====================================
// === 多方狀態與變數 (Long) ===
// =====================================
var int long_state = 0
var float long_target = na

var int long_start_idx = na
var float long_fib_0 = na
var float long_fib_1 = na
var float long_fib_38 = na

// --- 多方：最新進行中的動態線段與標籤 ---
var line active_l0 = na, var line active_l1 = na, var line active_l38 = na, var line active_l58 = na
var label active_lb0 = na, var label active_lb1 = na, var label active_lb38 = na, var label active_lb58 = na

// 1. 如果出現黑吞，重置狀態開始偵測前高突破
if bearish_swallow
    long_state := 1
    long_target := na
    // 遇到黑吞代表上一波多方失敗，刪除進行中的動態線
    line.delete(active_l0), line.delete(active_l1), line.delete(active_l38), line.delete(active_l58)
    label.delete(active_lb0), label.delete(active_lb1), label.delete(active_lb38), label.delete(active_lb58)

// 2. 狀態 1：偵測是否碰到前一根 K 棒的最高點 (且當前不能有黑吞產生)
if long_state == 1 and not bearish_swallow
    if high >= high[1]
        long_start_idx := bar_index[1]
        long_fib_0 := low[1]
        long_fib_1 := high[1]
        dist = long_fib_1 - long_fib_0
        
        // 使用 round_to_mintick 將數值貼齊商品最小跳動點
        long_fib_38 := math.round_to_mintick(long_fib_0 + 3.8 * dist)
        long_target := math.round_to_mintick(long_fib_0 + 5.8 * dist)
        long_state := 2
        
        // 突破當下，建立一組進行中的動態線段
        line.delete(active_l0), line.delete(active_l1), line.delete(active_l38), line.delete(active_l58)
        label.delete(active_lb0), label.delete(active_lb1), label.delete(active_lb38), label.delete(active_lb58)
        
        active_l0 := line.new(long_start_idx, long_fib_0, bar_index, long_fib_0, color=col_fib_0, style=line.style_dashed)
        active_l1 := line.new(long_start_idx, long_fib_1, bar_index, long_fib_1, color=col_fib_1, style=line.style_dashed)
        active_l38 := line.new(long_start_idx, long_fib_38, bar_index, long_fib_38, color=col_fib_38, style=line.style_solid, width = 2)
        active_l58 := line.new(long_start_idx, long_target, bar_index, long_target, color=col_long_58, style=line.style_solid, width=2)
        
        // 使用 format.mintick 讓文字顯示符合圖表小數點
        active_lb0 := label.new(bar_index, long_fib_0, "0", style=label.style_label_left, color=color.new(color.white, 100), textcolor=col_fib_0, size=size.small)
        active_lb1 := label.new(bar_index, long_fib_1, "1", style=label.style_label_left, color=color.new(color.white, 100), textcolor=col_fib_1, size=size.small)
        active_lb38 := label.new(bar_index, long_fib_38, "SL:("+str.tostring(long_fib_38, format.mintick)+")", style=label.style_label_left, color=color.new(color.white, 100), textcolor=col_fib_38, size=size.small)
        active_lb58 := label.new(bar_index, long_target, "E:("+str.tostring(long_target, format.mintick)+")", style=label.style_label_left, color=color.new(color.white, 100), textcolor=col_long_58, size=size.small)

// 3. 狀態 2：等待價格觸碰 5.8 軸
long_signal = false
if long_state == 2 and not bearish_swallow
    // 讓進行中的動態線段與標籤跟隨當前 K 棒向右延伸
    line.set_x2(active_l0, bar_index)
    line.set_x2(active_l1, bar_index)
    line.set_x2(active_l38, bar_index)
    line.set_x2(active_l58, bar_index)
    label.set_x(active_lb0, bar_index)
    label.set_x(active_lb1, bar_index)
    label.set_x(active_lb38, bar_index)
    label.set_x(active_lb58, bar_index)

    if high >= long_target
        long_signal := true
        
        // === 成功觸達目標！畫出永久歷史線段 ===
        line.new(long_start_idx, long_fib_0, bar_index, long_fib_0, color=col_fib_0, style=line.style_dashed)
        line.new(long_start_idx, long_fib_1, bar_index, long_fib_1, color=col_fib_1, style=line.style_dashed)
        line.new(long_start_idx, long_fib_38, bar_index, long_fib_38, color=col_fib_38, style=line.style_solid, width = 2)
        line.new(long_start_idx, long_target, bar_index, long_target, color=col_long_58, style=line.style_solid, width=2)
        
        label.new(bar_index, long_fib_0, "0", style=label.style_label_left, color=color.new(color.white, 100), textcolor=col_fib_0, size=size.small)
        label.new(bar_index, long_fib_1, "1", style=label.style_label_left, color=color.new(color.white, 100), textcolor=col_fib_1, size=size.small)
        label.new(bar_index, long_fib_38, "SL:("+str.tostring(long_fib_38, format.mintick)+")", style=label.style_label_left, color=color.new(color.white, 100), textcolor=col_fib_38, size=size.small)
        label.new(bar_index, long_target, "E:("+str.tostring(long_target, format.mintick)+")", style=label.style_label_left, color=color.new(color.white, 100), textcolor=col_long_58, size=size.small)

        // 清除動態線段
        line.delete(active_l0), line.delete(active_l1), line.delete(active_l38), line.delete(active_l58)
        label.delete(active_lb0), label.delete(active_lb1), label.delete(active_lb38), label.delete(active_lb58)

        long_state := 0  
        long_target := na


// =====================================
// === 空方狀態與變數 (Short) ===
// =====================================
var int short_state = 0
var float short_target = na

var int short_start_idx = na
var float short_fib_0 = na
var float short_fib_1 = na
var float short_fib_38 = na

// --- 空方：最新進行中的動態線段與標籤 ---
var line active_s0 = na, var line active_s1 = na, var line active_s38 = na, var line active_s58 = na
var label active_sb0 = na, var label active_sb1 = na, var label active_sb38 = na, var label active_sb58 = na

// 1. 如果出現紅吞，重置狀態開始偵測前低跌破
if bullish_swallow
    short_state := 1
    short_target := na
    // 遇到紅吞代表上一波空方失敗，刪除進行中的動態線
    line.delete(active_s0), line.delete(active_s1), line.delete(active_s38), line.delete(active_s58)
    label.delete(active_sb0), label.delete(active_sb1), label.delete(active_sb38), label.delete(active_sb58)

// 2. 狀態 1：偵測是否碰到前一根 K 棒的最低點 (且當前不能有紅吞產生)
if short_state == 1 and not bullish_swallow
    if low <= low[1]
        short_start_idx := bar_index[1]
        short_fib_0 := high[1]
        short_fib_1 := low[1]
        dist = short_fib_0 - short_fib_1
        
        // 使用 round_to_mintick 將數值貼齊商品最小跳動點
        short_fib_38 := math.round_to_mintick(short_fib_0 - 3.8 * dist)
        short_target := math.round_to_mintick(short_fib_0 - 5.8 * dist)
        short_state := 2
        
        // 跌破當下，建立一組進行中的動態線段
        line.delete(active_s0), line.delete(active_s1), line.delete(active_s38), line.delete(active_s58)
        label.delete(active_sb0), label.delete(active_sb1), label.delete(active_sb38), label.delete(active_sb58)
        
        active_s0 := line.new(short_start_idx, short_fib_0, bar_index, short_fib_0, color=col_fib_0, style=line.style_dashed)
        active_s1 := line.new(short_start_idx, short_fib_1, bar_index, short_fib_1, color=col_fib_1, style=line.style_dashed)
        active_s38 := line.new(short_start_idx, short_fib_38, bar_index, short_fib_38, color=col_fib_38, style=line.style_solid, width = 2)
        active_s58 := line.new(short_start_idx, short_target, bar_index, short_target, color=col_short_58, style=line.style_solid, width=2)
        
        // 使用 format.mintick 讓文字顯示符合圖表小數點
        active_sb0 := label.new(bar_index, short_fib_0, "0", style=label.style_label_left, color=color.new(color.white, 100), textcolor=col_fib_0, size=size.small)
        active_sb1 := label.new(bar_index, short_fib_1, "1", style=label.style_label_left, color=color.new(color.white, 100), textcolor=col_fib_1, size=size.small)
        active_sb38 := label.new(bar_index, short_fib_38, "SL:("+str.tostring(short_fib_38, format.mintick)+")", style=label.style_label_left, color=color.new(color.white, 100), textcolor=col_fib_38, size=size.small)
        active_sb58 := label.new(bar_index, short_target, "E:("+str.tostring(short_target, format.mintick)+")", style=label.style_label_left, color=color.new(color.white, 100), textcolor=col_short_58, size=size.small)

// 3. 狀態 2：等待價格觸碰 5.8 軸
short_signal = false
if short_state == 2 and not bullish_swallow
    // 讓進行中的動態線段與標籤跟隨當前 K 棒向右延伸
    line.set_x2(active_s0, bar_index)
    line.set_x2(active_s1, bar_index)
    line.set_x2(active_s38, bar_index)
    line.set_x2(active_s58, bar_index)
    label.set_x(active_sb0, bar_index)
    label.set_x(active_sb1, bar_index)
    label.set_x(active_sb38, bar_index)
    label.set_x(active_sb58, bar_index)

    if low <= short_target
        short_signal := true
        
        // === 成功觸達目標！畫出永久歷史線段 ===
        line.new(short_start_idx, short_fib_0, bar_index, short_fib_0, color=col_fib_0, style=line.style_dashed)
        line.new(short_start_idx, short_fib_1, bar_index, short_fib_1, color=col_fib_1, style=line.style_dashed)
        line.new(short_start_idx, short_fib_38, bar_index, short_fib_38, color=col_fib_38, style=line.style_solid, width = 2)
        line.new(short_start_idx, short_target, bar_index, short_target, color=col_short_58, style=line.style_solid, width=2)
        
        label.new(bar_index, short_fib_0, "0", style=label.style_label_left, color=color.new(color.white, 100), textcolor=col_fib_0, size=size.small)
        label.new(bar_index, short_fib_1, "1", style=label.style_label_left, color=color.new(color.white, 100), textcolor=col_fib_1, size=size.small)
        label.new(bar_index, short_fib_38, "SL:("+str.tostring(short_fib_38, format.mintick)+")", style=label.style_label_left, color=color.new(color.white, 100), textcolor=col_fib_38, size=size.small)
        label.new(bar_index, short_target, "E:("+str.tostring(short_target, format.mintick)+")", style=label.style_label_left, color=color.new(color.white, 100), textcolor=col_short_58, size=size.small)

        // 清除動態線段
        line.delete(active_s0), line.delete(active_s1), line.delete(active_s38), line.delete(active_s58)
        label.delete(active_sb0), label.delete(active_sb1), label.delete(active_sb38), label.delete(active_sb58)

        short_state := 0  
        short_target := na

// === 繪製訊號圖示 ===
plotshape(long_signal, style=shape.triangleup, location=location.belowbar, color=col_long_58, size=size.tiny, text="多", textcolor=col_long_58)
plotshape(short_signal, style=shape.triangledown, location=location.abovebar, color=color.red, size=size.tiny, text="空", textcolor=color.red)
````
