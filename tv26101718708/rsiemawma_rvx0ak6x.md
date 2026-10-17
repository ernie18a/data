# RSI+EMA+WMA

- url: https://www.tradingview.com/script/Rvx0Ak6x/
- type: indicator
- pine_id: PUB;65e0b298588f47efa80231de74f230ad
- version: 1.0

## Description

📊 RSI Custom EMA 9 & WMA 45 + Extreme Zones

RSI Custom EMA 9 & WMA 45 + Extreme Zones là một chỉ báo động lượng nâng cao, kết hợp giữa RSI truyền thống, đường trung bình động trên RSI (EMA & WMA) và vùng cực trị (Extreme Zones) để giúp trader xác định:

Xu hướng động lượng
Điểm đảo chiều tiềm năng
Phân kỳ (Divergence)
Vùng quá mua / quá bán mở rộng
⚙️ Thành phần chính
1. RSI (Relative Strength Index)
Sử dụng công thức chuẩn của Wilder (RMA-based)
Phản ánh sức mạnh và tốc độ của biến động giá
Các mức quan trọng:
70 → Quá mua
30 → Quá bán
50 → Cân bằng xu hướng
2. EMA 9 trên RSI (Signal Line)
Đường EMA nhanh giúp:
Phát hiện thay đổi momentum sớm
Xác định tín hiệu đảo chiều ngắn hạn
Hoạt động như “trigger line”
3. WMA 45 trên RSI (Trend Line)
Đường WMA chậm hơn, mượt hơn
Dùng để:
Xác định xu hướng chính của RSI
Lọc nhiễu tín hiệu từ EMA
4. Extreme Zones (80 / 20)
Mở rộng vùng quá mua/quá bán:
80–100 → Overbought mạnh
0–20 → Oversold mạnh
Tính năng:
Highlight vùng nền (background zones)
Vạch dọc (vertical highlight) khi RSI chạm vùng cực trị
Màu sắc có thể tùy chỉnh

👉 Đây là vùng thường xuất hiện:

Buying Climax / Upthrust
Selling Climax / Spring
5. Divergence Detection (Phân kỳ)
Tự động phát hiện:
Bullish Divergence
Bearish Divergence
Sử dụng pivot xác nhận (không repaint)
Điều kiện:
Bullish:
Giá tạo Lower Low
RSI tạo Higher Low
Bearish:
Giá tạo Higher High
RSI tạo Lower High
🎯 Cách sử dụng
Xác định xu hướng
RSI > WMA 45 → xu hướng tăng
RSI < WMA 45 → xu hướng giảm
Tín hiệu vào lệnh
BUY Setup
RSI ≤ 20 (Extreme Oversold)
Xuất hiện Bullish Divergence
EMA 9 cắt lên WMA 45
SELL Setup
RSI ≥ 80 (Extreme Overbought)
Xuất hiện Bearish Divergence
EMA 9 cắt xuống WMA 45
Xác nhận nâng cao

Chỉ báo hoạt động hiệu quả hơn khi kết hợp với:

Price Action
Supply / Demand Zones
Volume Analysis (VSA, Wyckoff)
⚡ Điểm nổi bật

✔ RSI chuẩn (Wilder) – độ chính xác cao
✔ Kết hợp EMA + WMA → vừa nhanh vừa ổn định
✔ Extreme Zones giúp phát hiện vùng “quá đà” của thị trường
✔ Divergence không repaint
✔ Tùy chỉnh màu sắc linh hoạt
✔ Phù hợp với scalping, intraday và swing

⚠️ Lưu ý
Không nên sử dụng RSI Extreme như tín hiệu vào lệnh độc lập
Nên kết hợp với cấu trúc thị trường và thanh khoản
Divergence mạnh hơn khi xuất hiện tại vùng 80 / 20
🧠 Tóm tắt tư duy hệ thống

Chỉ báo này hoạt động theo mô hình:

Momentum (RSI) + Trend Filter (WMA) + Signal (EMA) + Exhaustion (Extreme Zones) + Reversal (Divergence)

## Source Code

````pine
//@version=6
indicator(title="RSI+EMA+WMA", shorttitle="RSI+EMA+WMA", format=format.price, precision=2)

// ==========================================
// 1. CÀI ĐẶT RSI (GIỮ NGUYÊN LOGIC GỐC)
// ==========================================
rsiGroup = "RSI Settings"
rsiLengthInput = input.int(14, minval=1, title="RSI Length", group=rsiGroup)
rsiSourceInput = input.source(close, "Source", group=rsiGroup)
calculateDivergence = input.bool(false, title="Calculate Divergence", group=rsiGroup)

change = ta.change(rsiSourceInput)
up = ta.rma(math.max(change, 0), rsiLengthInput)
down = ta.rma(-math.min(change, 0), rsiLengthInput)
rsi = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))

// ==========================================
// 2. CÀI ĐẶT EMA (Mặc định 9)
// ==========================================
groupEMA = "Cài đặt EMA"
emaLen   = input.int(9, title="Chiều dài EMA", minval=1, group=groupEMA)
emaColor = input.color(color.blue, title="Màu EMA", group=groupEMA)
emaWidth = input.int(1, title="Độ dày EMA", minval=1, maxval=10, group=groupEMA)

emaVal = ta.ema(rsi, emaLen)
plot(emaVal, title="EMA trên RSI", color=emaColor, linewidth=emaWidth)

// ==========================================
// 3. CÀI ĐẶT WMA (Mặc định 45)
// ==========================================
groupWMA = "Cài đặt WMA"
wmaLen   = input.int(45, title="Chiều dài WMA", minval=1, group=groupWMA)
wmaColor = input.color(color.black, title="Màu WMA", group=groupWMA)
wmaWidth = input.int(2, title="Độ dày WMA", minval=1, maxval=10, group=groupWMA)

wmaVal = ta.wma(rsi, wmaLen)
plot(wmaVal, title="WMA trên RSI", color=wmaColor, linewidth=wmaWidth)

// ==========================================
// 4. ĐỒ HỌA RSI & VÙNG QUÁ MUA/BÁN GỐC
// ==========================================
rsiPlot = plot(rsi, "RSI Line", color=#7E57C2, linewidth=2)
rsiUpperBand = hline(70, "RSI Upper Band", color=#787B86)
midline = hline(50, "RSI Middle Band", color=color.new(#787B86, 50))
rsiLowerBand = hline(30, "RSI Lower Band", color=#787B86)
fill(rsiUpperBand, rsiLowerBand, color=color.rgb(126, 87, 194, 90), title="RSI Background Fill")

midLinePlot = plot(50, color = na, editable = false, display = display.none)
fill(rsiPlot, midLinePlot, 100, 70, top_color = color.new(color.green, 0), bottom_color = color.new(color.green, 100), title = "Overbought Gradient")
fill(rsiPlot, midLinePlot, 30, 0, top_color = color.new(color.red, 100), bottom_color = color.new(color.red, 0), title = "Oversold Gradient")

// ==========================================
// 5. LOGIC PHÂN KỲ (DIVERGENCE) GỐC
// ==========================================
lookbackRight = 5
lookbackLeft = 5
rsiLBR = rsi[lookbackRight]

_inRange(bool cond) =>
    bars = ta.barssince(cond)
    5 <= bars and bars <= 60

plFound = false
phFound = false
bullCond = false
bearCond = false

if calculateDivergence
    plFound := not na(ta.pivotlow(rsi, lookbackLeft, lookbackRight))    
    rsiHL = rsiLBR > ta.valuewhen(plFound, rsiLBR, 1) and _inRange(plFound[1])
    priceLL = low[lookbackRight] < ta.valuewhen(plFound, low[lookbackRight], 1)
    bullCond := priceLL and rsiHL and plFound

    phFound := not na(ta.pivothigh(rsi, lookbackLeft, lookbackRight))
    rsiLH = rsiLBR < ta.valuewhen(phFound, rsiLBR, 1) and _inRange(phFound[1])
    priceHH = high[lookbackRight] > ta.valuewhen(phFound, high[lookbackRight], 1)
    bearCond := priceHH and rsiLH and phFound

plotshape(bullCond ? rsiLBR : na, offset = -lookbackRight, title = "Bullish Label", text = " Bull ", style = shape.labelup, location = location.absolute, color = color.green, textcolor = color.white)
plotshape(bearCond ? rsiLBR : na, offset = -lookbackRight, title = "Bearish Label", text = " Bear ", style = shape.labeldown, location = location.absolute, color = color.red, textcolor = color.white)

// ==========================================
// 6. RSI EXTREME (80 / 20) - BỔ SUNG
// ==========================================
groupExtreme = "RSI Extreme Zones"

// bật/tắt
showExtremeLines = input.bool(true, "Hiển thị vạch RSI 80/20", group=groupExtreme)

// màu
colorAbove80 = input.color(color.green, "Màu RSI >= 80", group=groupExtreme)
colorBelow20 = input.color(color.red, "Màu RSI <= 20", group=groupExtreme)

// điều kiện
rsiAbove80 = rsi >= 80
rsiBelow20 = rsi <= 20

// vạch dọc (highlight nền)
bgcolor(showExtremeLines and rsiAbove80 ? color.new(colorAbove80, 85) : na)
bgcolor(showExtremeLines and rsiBelow20 ? color.new(colorBelow20, 85) : na)

// ==========================================
// 7. VÙNG 80-100 & 0-20 - BỔ SUNG
// ==========================================
showExtremeZones = input.bool(true, "Hiển thị vùng RSI 80-100 / 0-20", group=groupExtreme)

zone80Color = input.color(color.new(color.green, 85), "Vùng 80-100", group=groupExtreme)
zone20Color = input.color(color.new(color.red, 85), "Vùng 0-20", group=groupExtreme)

// đường mức
rsi80 = hline(80, "RSI 80", color=color.new(color.gray, 70))
rsi100 = hline(100, "RSI 100", color=color.new(color.gray, 100))

rsi20 = hline(20, "RSI 20", color=color.new(color.gray, 70))
rsi0 = hline(0, "RSI 0", color=color.new(color.gray, 100))

// fill vùng
fill(rsi80, rsi100, color = showExtremeZones ? zone80Color : na, title="Zone 80-100")
fill(rsi0, rsi20, color = showExtremeZones ? zone20Color : na, title="Zone 0-20")
````
