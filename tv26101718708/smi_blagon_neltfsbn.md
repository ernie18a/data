# SMI BLAGON

- url: https://www.tradingview.com/script/nELTfsBn/
- type: indicator
- pine_id: PUB;e319246e0aa0410ba7af5ff3a2751891
- version: 1.0

## Description

thu cho vui giai tri mot chut thoi ae dung quan tam lam gi nhe

## Source Code

````pine
//@version=5
// @author LazyBear 
// Tên chỉ báo: SMI BLAGON
indicator(shorttitle = "SMI_BLAGON", title="SMI BLAGON", overlay=false)

length = input.int(20, title="BB Length")
mult = input.float(2.0, title="BB MultFactor")
lengthKC = input.int(20, title="KC Length")
multKC = input.float(1.5, title="KC MultFactor")

useTrueRange = input.bool(true, title="Use TrueRange (KC)")

// 1. Tính toán Bollinger Bands
source = close
basis = ta.sma(source, length)
dev = mult * ta.stdev(source, length)
upperBB = basis + dev
lowerBB = basis - dev

// 2. Tính toán Keltner Channels
ma = ta.sma(source, lengthKC)
range_val = useTrueRange ? ta.tr : (high - low)
rangema = ta.sma(range_val, lengthKC)
upperKC = ma + rangema * multKC
lowerKC = ma - rangema * multKC

// 3. Xác định trạng thái Squeeze (Nén/Bùng nổ)
sqzOn  = (lowerBB > lowerKC) and (upperBB < upperKC)
sqzOff = (lowerBB < lowerKC) and (upperBB > upperKC)
noSqz  = (sqzOn == false) and (sqzOff == false)

// 4. Tính toán giá trị Momentum (Sửa lỗi triệt để bằng math)
highest_high = ta.highest(high, lengthKC)
lowest_low = ta.lowest(low, lengthKC)
mid_line = math.avg(highest_high, lowest_low)
avg_val = math.avg(mid_line, ta.sma(close, lengthKC))
val = ta.linreg(source - avg_val, lengthKC, 0)

// 5. Thiết lập màu sắc
bcolor = val > 0 ? (val > nz(val[1]) ? color.rgb(0,255, 0): color.rgb(255, 130,0)) : (val < nz(val[1]) ? color.rgb(255, 0, 0) : color.rgb(0, 255, 255))
scolor = noSqz ? color.blue : (sqzOn ? color.black : color.gray)

// 6. Vẽ biểu đồ
plot(val, color=bcolor, style=plot.style_histogram, linewidth=4)
plot(0, color=scolor, style=plot.style_cross, linewidth=2)

// 7. Thông báo (Alerts)
alert_sqzOff = sqzOff and sqzOn[1]
alertcondition(alert_sqzOff, title="SMI BLAGON: Bùng nổ biến động", message="Cảnh báo: Tín hiệu Squeeze Off xuất hiện. Biến động giá sắp bùng nổ!")
````
