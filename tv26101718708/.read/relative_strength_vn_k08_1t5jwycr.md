# Relative Strength VN K08

- url: https://www.tradingview.com/script/1t5jWYCR-Relative-Strength-VN-K08/
- type: indicator
- pine_id: PUB;dbfd2740f405414692e722c1012021d5
- version: 1.0

## Description

Relative Strength VN is a method used to measure a stock’s relative strength against the broader market or its sector, helping identify where capital flows are concentrating and which stocks are leading the trend.

## Source Code

````pine
//@version=5
indicator("Relative Strength VN", overlay=false)

// 1. Lấy dữ liệu VNINDEX để so sánh
reference = "HOSE:VNINDEX"
vnindex = request.security(reference, timeframe.period, close)

// 2. Tính toán RS
rs = close / vnindex

// 3. Tính toán các đường tín hiệu (Moving Average)
sig_long = ta.ema(rs, 49)
sig_short = ta.ema(rs, 13)

// 4. Logic đổi màu đường RS theo yêu cầu:
// - Nếu RS > MA13 và RS > MA49: Màu tím
// - Nếu RS > MA13 (nhưng không thỏa điều kiện trên): Màu xanh lá
// - Nếu RS < MA13: Màu đỏ
rsColor = (rs > sig_short and rs > sig_long) ? color.purple : (rs > sig_short ? color.green : color.red)

// 5. Vẽ các đường lên biểu đồ
plot(rs, title="RS Line", color=rsColor, linewidth=3)
plot(sig_long, title="Signal Long (49)", color=color.black, linewidth=1)
plot(sig_short, title="Signal Short (13)", color=color.new(color.gray, 50), linewidth=1) // Để màu xám nhạt cho dễ nhìn
````
