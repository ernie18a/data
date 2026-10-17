# FX Blagon

- url: https://www.tradingview.com/script/ha4I5oFB/
- type: indicator
- pine_id: PUB;20cf6c2f668c4532974f462edeb37dc6
- version: 1.0

## Description

Thu nghiem mot ti cho vui thoi ae dung quan tam nhe

## Source Code

````pine
//@version=5
// @author LazyBear
// @credits Constance Brown
// Tên đã đổi thành Oscillator Blagon
indicator(title = "Oscillator Blagon", shorttitle="OSC_BLAGON", overlay=false)

// --- INPUTS ---
length = input.int(14, title="RSI Length")
p      = input.int(9, title="SMA length")
ema1   = input.int(5, title="EMA1 length")
ema2   = input.int(3, title="EMA2 length")

// --- CALCULATIONS ---
// Tính toán RSI sau đó làm mượt bằng 2 lần EMA
rsi_val = ta.rsi(close, length)
s1      = ta.ema(ta.ema(rsi_val, ema1), ema2)

// Giá trị Oscillator (Chênh lệch giữa s1 và SMA của chính nó)
s2      = s1 - ta.sma(s1, p)

// --- COLOR LOGIC ---
// Lime: Đang tăng (Mạnh dần hoặc bớt yếu)
// Red:  Đang giảm (Yếu dần hoặc bớt mạnh)
c_color = s2 >= 0 ? (s2 > nz(s2[1]) ? color.rgb(0, 255, 0) : color.rgb(255, 0, 0)) : (s2 < nz(s2[1]) ? color.rgb(255, 3, 3) : color.rgb(10, 255, 5))

// --- PLOTTING ---
plot(s2, title="Oscillator Histogram", style=plot.style_histogram, color=c_color, linewidth=2)
plot(0,  title="Zero Line", color=color.new(color.gray, 50))

// --- PHẦN THÊM MỚI: THÔNG BÁO (ALERTS) ---

// 1. Tín hiệu khi Oscillator cắt lên đường 0 (Xu hướng tăng hình thành)
alert_cross_up = ta.crossover(s2, 0)
alertcondition(alert_cross_up, title="OSC Blagon: Cắt lên 0", message="Tín hiệu TĂNG: Oscillator Blagon đã cắt lên trên đường 0 tại {{ticker}}")

// 2. Tín hiệu khi Oscillator cắt xuống đường 0 (Xu hướng giảm hình thành)
alert_cross_down = ta.crossunder(s2, 0)
alertcondition(alert_cross_down, title="OSC Blagon: Cắt xuống 0", message="Tín hiệu GIẢM: Oscillator Blagon đã cắt xuống dưới đường 0 tại {{ticker}}")

// 3. Tín hiệu khi màu sắc thay đổi (Thay đổi xung lượng)
alert_color_change = (c_color != c_color[1])
alertcondition(alert_color_change, title="OSC Blagon: Đổi màu", message="Cảnh báo: Xung lượng trên Oscillator Blagon vừa thay đổi màu sắc tại {{ticker}}")
````
