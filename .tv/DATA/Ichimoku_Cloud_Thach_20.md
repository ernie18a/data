<!-- tradingview-pine-id: PUB;47b727e0d1ec4eaaa10763a992d7ca90 -->
<!-- tradingviewscripts-format: 1 -->
# Ichimoku Cloud Thach 2.0

Source: https://www.tradingview.com/script/OafI0wke/

## Description

Tôi đã phát triển chỉ báo Ichimoku Cloud Thach 2.0 dựa trên Ichimoku Cloud. Chỉ báo này giúp chúng ta tránh được hành động mua ở đỉnh bán ở đáy, bạn sẽ dễ dàng nhìn ra vùng Hỗ trợ - Kháng cự ngắn và dài hạn, không bỏ qua xu hướng tăng giá nào. 

Nếu thấy giá nằm trên mây =>  Xu hướng đảo chiều Tăng ( Volume > MA20  thì xác xuất xu hướng tăng rất cao.)
Nếu giá nằm dưới mây => Xu hướng đảo chiều Giảm

Các đường màu cam và màu tím chính là điểm cân bằng, điểm cân bằng càng phẳng (ngang) thì hỗ trợ hoặc kháng cự càng mạnh, giá đi xa đường cân bằng này thì thường có xu hướng bị kéo về đường cân bằng, giá chạm tại các đường cân bằng này thường bậc ngược lại. Nếu giá vượt qua cá đường cân bằng này thì thường hình thành xu hướng Tăng hoặc Giảm mạnh.

Đường Donchain cho ta biết giá cao nhất và thấp nhất trong 20 phiên.

Mặc dù chỉ báo tôi tạo ra có thể hoạt động độc lập nhưng bạn có thể kết hợp với một vài chỉ báo khác để lọc nhiễu như:
+ Volume
+ MFI 
+ RSI 
+ MACD
.....

---

## Source Code

````pine
//@version=6
indicator(title="Ichimoku Cloud Thach 2.0", shorttitle="Ichimoku Thach 2.0", overlay=true)

// ===== Ichimoku chính =====

conversionPeriods = input.int(9, minval=1, title="Conversion Line Length")
basePeriods = input.int(17, minval=1, title="Base Line Length")
laggingSpan2Periods = input.int(26, minval=1, title="Leading Span B Length")
displacement = input.int(26, minval=1, title="Lagging Span")

// ===== Đường 65 / 129 =====

conversionPeriods65 = input.int(65, minval=1, title="Line 65")
basePeriods129 = input.int(129, minval=1, title="Line 129")

// ===== Mây phụ =====

conversionPeriods1 = input.int(9, minval=1, title="Line 3")
basePeriods1 = input.int(9, minval=1, title="Line 4")
laggingSpan2Periods1 = input.int(17, minval=1, title="Leading Span Length")
displacement1 = input.int(1, minval=1, title="Lagging Span")

// ===== Hàm Donchian =====

donchian(len) =>
    math.avg(ta.lowest(len), ta.highest(len))

// ===== Ichimoku chính =====

conversionLine = donchian(conversionPeriods)
baseLine = donchian(basePeriods)

leadLine1 = math.avg(conversionLine, baseLine)
leadLine2 = donchian(laggingSpan2Periods)

// ===== Đường 65 / 129 =====

conversionLine65 = donchian(conversionPeriods65)
baseLine129 = donchian(basePeriods129)

// ===== Mây phụ =====

conversionLine1 = donchian(conversionPeriods1)
baseLine1 = donchian(basePeriods1)

leadLine3 = math.avg(conversionLine1, baseLine1)
leadLine4 = donchian(laggingSpan2Periods1)

// ===== Vẽ Ichimoku chính =====

plot(conversionLine, color=color.rgb(41, 98, 255, 60), title="Conversion Line Length")
plot(baseLine, color=color.rgb(242, 54, 69, 60), title="Base Line Length")

plot(conversionLine65, color=color.rgb(245, 124, 0), title="Line 65")
plot(baseLine129, color=color.rgb(156, 39, 176, 0), title="Line 129")

plot(close, offset=-displacement + 1, color=color.rgb(76, 175, 80, 70), title="Lagging Span")

p1 = plot(leadLine1, offset=displacement - 1, color=color.rgb(76, 175, 80, 60), title="Span A")
p2 = plot(leadLine2, offset=displacement - 1, color=color.rgb(242, 54, 69, 60), title="Span B")

fill(p1,p2,title="Cloud Fill",color=leadLine1 > leadLine2? color.rgb(76, 175, 80, 80): color.rgb(242, 54, 69, 80))

// ===== Mây phụ =====

p3 = plot(leadLine3,offset=displacement1 - 1,color=color.new(color.blue, 100),display=display.none)
p4 = plot(leadLine4,offset=displacement1 - 1,color=color.new(color.gray, 100),display=display.none)

fill(p3,p4,title="Cloud Fill 2",color=leadLine3 > leadLine4? color.rgb(49, 121, 245,80): color.rgb(128, 128, 128,80))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CÁC MỐC NẾN
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

int candle199 = 199
int candle128 = 128
int candle64 = 64
int candle25 = 25
int candle16 = 16
int candle8 = 8

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MÀU SẮC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

color color199 = input.color(color.rgb(29, 210, 104, 80), "Màu nến 200")
color color128 = input.color(color.rgb(215, 15, 185, 80), "Màu nến 129")
color color64 = input.color(color.rgb(255, 170, 59, 80), "Màu nến 65")
color color25 = input.color(color.rgb(128, 128, 128, 80), "Màu nến 26")
color color16 = input.color(color.rgb(247, 86, 86, 80), "Màu nến 17")
color color8 = input.color(color.rgb(114, 193, 232, 80), "Màu nến 9")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// XÁC ĐỊNH VỊ TRÍ CÁC NẾN
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bool is199 = bar_index == last_bar_index - candle199
bool is128 = bar_index == last_bar_index - candle128
bool is64 = bar_index == last_bar_index - candle64
bool is25 = bar_index == last_bar_index - candle25
bool is16 = bar_index == last_bar_index - candle16
bool is8 = bar_index == last_bar_index - candle8

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VẼ ĐƯỜNG THẲNG ĐỨNG
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if is199
    line.new(bar_index, low, bar_index, high, xloc=xloc.bar_index, extend=extend.both, color=color199, width=3)

if is128
    line.new(bar_index, low, bar_index, high, xloc=xloc.bar_index, extend=extend.both, color=color128, width=3)

if is64
    line.new(bar_index, low, bar_index, high, xloc=xloc.bar_index, extend=extend.both, color=color64, width=3)

if is25
    line.new(bar_index, low, bar_index, high, xloc=xloc.bar_index, extend=extend.both, color=color25, width=3)

if is16
    line.new(bar_index, low, bar_index, high, xloc=xloc.bar_index, extend=extend.both, color=color16, width=3)

if is8
    line.new(bar_index, low, bar_index, high, xloc=xloc.bar_index, extend=extend.both, color=color8, width=3)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DONCHIAN CHANNELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

length = input.int(20, minval=1, title="High/Low")
offset = input.int(0, "Offset")

lower = ta.lowest(length)
upper = ta.highest(length)

u = plot(upper, "Upper", color=color.rgb(188, 205, 251, 20), offset=offset)
l = plot(lower, "Lower", color=color.rgb(188, 205, 251, 20), offset=offset)

fill(u, l, color=color.rgb(33, 150, 243, 95), title="Background")
````
