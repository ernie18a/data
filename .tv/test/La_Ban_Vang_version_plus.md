<!-- tradingview-pine-id: PUB;a081e2f9b22940ca803afb1bc527101a -->
<!-- tradingviewscripts-format: 1 -->
# La Bàn Vàng version plus

Source: https://www.tradingview.com/script/nHzFEbaT/

## Description

La Bàn Vàng version plus bản nâng cấp tín hiệu BUY SELL Vàng

---

## Source Code

````pine
//@version=6
indicator("La Bàn Vàng version plus", overlay=true)

// --- THÔNG SỐ CÀI ĐẶT ---
len1 = input.int(100, title="Độ dài BB 100")
len2 = input.int(300, title="Độ dài BB 300")
mult = input.float(2.0, title="Độ lệch chuẩn (StdDev)")

// Thông số Stochastic (10, 6, 6)
kPeriod = input.int(10, title="Stoch %K Length")
slowing = input.int(6, title="Stoch %K Smoothing")

// Ngưỡng chạm
oversoldLevel = input.float(15, title="Ngưỡng Mua (Stoch <= 15)")
overboughtLevel = input.float(85, title="Ngưỡng Bán (Stoch >= 85)")

// --- TÍNH TOÁN BOLLINGER BANDS ---
// BB 100
[basis100, upper100, lower100] = ta.bb(close, len1, mult)
// BB 300
[basis300, upper300, lower300] = ta.bb(close, len2, mult)

// --- TÍNH TOÁN STOCHASTIC ---
stochK = ta.stoch(close, high, low, kPeriod)
smoothedK = ta.sma(stochK, slowing)

// --- ĐIỀU KIỆN TÍN HIỆU ---
// BUY: Stoch chạm ngưỡng dưới VÀ xu hướng BB100 nằm TRÊN BB300
// (Sử dụng dải dưới lower100 > lower300 để xác định vị trí Long)
buyCondition = smoothedK <= oversoldLevel and lower100 > lower300

// SELL: Stoch chạm ngưỡng trên VÀ xu hướng BB100 nằm DƯỚI BB300
// (Sử dụng dải trên upper100 < upper300 để xác định vị trí Short)
sellCondition = smoothedK >= overboughtLevel and upper100 < upper300

// --- HIỂN THỊ LÊN BIỂU ĐỒ ---
// Vẽ mũi tên tín hiệu (chỉ hiện mũi tên đầu tiên khi chạm vùng ngưỡng)
plotshape(buyCondition and not buyCondition[1], title="BUY Signal", style=shape.triangleup, location=location.belowbar, color=color.rgb(255, 0, 0), size=size.small, text="SELL")
plotshape(sellCondition and not sellCondition[1], title="SELL Signal", style=shape.triangledown, location=location.abovebar, color=color.rgb(106, 255, 0), size=size.small, text="BUY")

// Vẽ các dải Bollinger Bands để bạn quan sát
// BB 100 (Màu xanh)
plot(upper100, color=color.new(color.blue, 50), title="Upper 100")
plot(lower100, color=color.new(color.blue, 50), title="Lower 100")

// BB 300 (Màu đỏ)
plot(upper300, color=color.new(color.red, 50), title="Upper 300")
plot(lower300, color=color.new(color.red, 50), title="Lower 300")
````
