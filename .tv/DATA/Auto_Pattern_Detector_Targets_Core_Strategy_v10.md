<!-- tradingview-pine-id: PUB;2b4471cb684945ec848f9a83c3b2765b -->
<!-- tradingviewscripts-format: 1 -->
# Auto Pattern Detector Targets - Core Strategy v1.0

Source: https://www.tradingview.com/script/6QxmcfIk/

## Description

Pivot Lookback Right: 10, 23
● Các mô hình được phát hiện
Đỉnh đôi: Mô hình đảo chiều giảm giá bao gồm hai đỉnh liên tiếp ở gần cùng mức giá, báo hiệu sự cạn kiệt xu hướng tiềm năng.
Đáy đôi: Mô hình đảo chiều tăng giá với hai đáy liên tiếp ở các mức tương tự, cho thấy sự chuyển dịch tiềm năng từ áp lực bán sang áp lực mua.
Đỉnh ba: Mô hình đảo chiều giảm giá được đánh dấu bằng ba đỉnh riêng biệt ở mức kháng cự tương tự, phản ánh sự thất bại liên tục trong việc phá vỡ mức cao hơn.
Đáy ba: Mô hình đảo chiều tăng giá được đặc trưng bởi ba đáy liên tiếp ở mức hỗ trợ tương tự, cho thấy sự tích lũy mạnh mẽ.
Đầu và Vai: Mô hình đảo chiều giảm giá cổ điển với một đỉnh trung tâm cao hơn được bao quanh bởi hai đỉnh thấp hơn, thể hiện sự mất đà tăng.
Đầu và Vai ngược: Mô hình đảo chiều tăng giá bao gồm một đáy trung tâm thấp hơn được bao quanh bởi hai đáy cao hơn, cho thấy sự chuyển dịch sang xu hướng tăng.
Cờ tăng giá: Mô hình tiếp diễn ngắn hạn được hình thành bởi sự tăng giá mạnh mẽ tiếp theo là sự tích lũy hẹp, dốc xuống.
Cờ giảm giá (Bearish Flag): Mô hình tiếp diễn xảy ra trong xu hướng giảm, trong đó sự giảm mạnh được theo sau bởi một giai đoạn tích lũy hẹp, dốc lên.
Cờ hiệu tăng giá (Bullish Pennant): Mô hình tiếp diễn được xác định bởi sự tăng mạnh, tiếp theo là giai đoạn tích lũy hình tam giác hội tụ đối xứng. Cờ hiệu
giảm giá (Bearish Pennant): Mô hình tiếp diễn có đặc điểm là sự giảm mạnh, tiếp theo là sự hình thành hình tam giác hội tụ trước khi tiếp tục giảm.
Nêm tăng (Rising Wedge): Mô hình đảo chiều hoặc tiếp diễn, trong đó giá tích lũy giữa các đường xu hướng hội tụ dốc lên, thường báo hiệu sự suy yếu tiềm tàng.
Nêm giảm (Falling Wedge): Mô hình được hình thành bởi các đường xu hướng hội tụ dốc xuống, thường là tiền thân của một sự đột phá tăng giá.
Tam giác (Triangle): Giai đoạn tích lũy, trong đó giá thu hẹp giữa các đường xu hướng hội tụ, cho thấy sự đột phá sắp xảy ra (Tăng dần, Giảm dần hoặc Đối xứng).
Hình chữ nhật (Rectangle): Phạm vi giao dịch, trong đó giá di chuyển theo chiều ngang giữa các mức hỗ trợ và kháng cự song song, cho thấy sự lưỡng lự trước khi đột phá.
Cốc và tay cầm (Cup and Handle): Mô hình tiếp diễn tăng giá giống như một chiếc cốc, tiếp theo là sự giảm giá nhẹ, cho thấy tiềm năng cho một đợt tăng giá mới.
Mô hình Cốc và Tay cầm ngược: Một mô hình tiếp diễn giảm giá được hình thành bởi một chiếc cốc và tay cầm ngược, báo hiệu áp lực giảm giá.
## Chiến lược Mục tiêu Mô hình Tự động — bởi Code2trade
Chiến lược **Auto Pattern Detector Targets** tự động quét thị trường để tìm **16 mô hình biểu đồ kinh điển**, bao gồm Đỉnh & Đáy đôi, Đỉnh & Đáy ba, Vai & Đầu, Vai & Đầu ngược, Cờ, Cờ hiệu, Nêm, Tam giác, Hình chữ nhật, Cốc & Tay cầm, và nhiều hơn nữa.

Khi một tín hiệu phá vỡ hợp lệ được xác nhận bằng cách sử dụng các bộ lọc tích hợp của chiến lược, một thiết lập giao dịch hoàn chỉnh sẽ được tạo ra với các mức **Vào lệnh**, **Cắt lỗ** và **Chốt lời** được xác định trước dựa trên mức độ di chuyển được đo lường của mô hình được phát hiện.

### Cách thức hoạt động

* Liên tục phát hiện các mô hình biểu đồ có xác suất cao bằng cách sử dụng các điểm xoay.
* Chờ tín hiệu phá vỡ được xác nhận trước khi tạo tín hiệu.
* Tự động tính toán Điểm vào lệnh, Cắt lỗ và Mục tiêu.
* Mở vị thế Mua cho các tín hiệu phá vỡ tăng giá và vị thế Bán cho các tín hiệu phá vỡ giảm giá.
* Sử dụng mức Cắt lỗ dựa trên mô hình ban đầu và Mục tiêu được đo lường từ chỉ báo.
* Tùy chọn thoát khỏi vị thế hiện có khi xuất hiện tín hiệu ngược chiều.

### Logic giao dịch mặc định

* **Vào lệnh:** Lệnh thị trường sau khi tín hiệu phá vỡ được xác nhận.
* **Cắt lỗ:** Mức vô hiệu hóa mô hình.
* **Chốt lời:** Mục tiêu di chuyển được tính toán từ mô hình đã phát hiện.
* **Quy mô vị thế:** Số lượng cố định (mặc định là 1 hợp đồng).
* **Gia tăng vị thế:** Đã tắt.

### Các tính năng chính

* Nhận diện mô hình hoàn toàn tự động.
* Thực hiện giao dịch khách quan, dựa trên quy tắc.
* Loại bỏ việc vẽ mô hình chủ quan.
* Hỗ trợ cả giao dịch Mua và Bán.
* Được xây dựng trực tiếp từ logic chỉ báo gốc mà không thay đổi quy trình tạo tín hiệu.

### Tuyên bố miễn trừ trách nhiệm rủi ro

Chiến lược này chỉ dành cho mục đích giáo dục và nghiên cứu. Kết quả kiểm thử ngược trong quá khứ không đảm bảo hiệu suất trong tương lai. Luôn luôn tự mình kiểm thử và áp dụng quản lý rủi ro thích hợp trước khi sử dụng chiến lược trên thị trường thực tế.

---

## Source Code

````pine
//@version=6
strategy(
     "Auto Pattern Detector Targets - Core Strategy v1.0",
     overlay = true,
     pyramiding = 0,
     initial_capital = 100000,
     commission_type = strategy.commission.percent,
     commission_value = 0.002,
     slippage = 1,
     process_orders_on_close = false
)

//====================================================
// INPUTS
//====================================================

groupPattern = "PATTERN ENGINE"

pivotLeft  = input.int(10, "Pivot Left", minval = 2, group = groupPattern)
pivotRight = input.int(10, "Pivot Right", minval = 2, group = groupPattern)

levelTolerance = input.float(
     0.30,
     "Level Tolerance %",
     minval = 0.05,
     step = 0.05,
     group = groupPattern)

minPatternATR = input.float(
     1.0,
     "Minimum Pattern Size ATR",
     minval = 0.1,
     step = 0.1,
     group = groupPattern)

groupTrade = "TRADE"

rr = input.float(
     2.0,
     "Target R:R",
     minval = 0.5,
     step = 0.25,
     group = groupTrade)

oneTradePerDay = input.bool(
     true,
     "Maximum 1 trade/day",
     group = groupTrade)

useSession = input.bool(
     true,
     "Use Session Filter",
     group = groupTrade)

sessionInput = input.session(
     "1400-2200",
     "Trading Session",
     group = groupTrade)

groupFilter = "FILTERS"

useEMA = input.bool(
     false,
     "Use EMA200 Filter",
     group = groupFilter)

emaLength = input.int(
     200,
     "EMA Length",
     group = groupFilter)

useATR = input.bool(
     true,
     "Use ATR Pattern Filter",
     group = groupFilter)

atrLength = input.int(
     14,
     "ATR Length",
     group = groupFilter)

groupPatternType = "PATTERNS"

useDoubleTop = input.bool(true, "Double Top", group = groupPatternType)
useDoubleBottom = input.bool(true, "Double Bottom", group = groupPatternType)

useTripleTop = input.bool(true, "Triple Top", group = groupPatternType)
useTripleBottom = input.bool(true, "Triple Bottom", group = groupPatternType)

useTriangle = input.bool(true, "Triangle", group = groupPatternType)
useRectangle = input.bool(true, "Rectangle", group = groupPatternType)

useWedge = input.bool(true, "Wedge", group = groupPatternType)


//====================================================
// CORE DATA
//====================================================

atr = ta.atr(atrLength)
ema = ta.ema(close, emaLength)

ph = ta.pivothigh(high, pivotLeft, pivotRight)
pl = ta.pivotlow(low, pivotLeft, pivotRight)


//====================================================
// STORE CONFIRMED PIVOTS
//====================================================

var float[] highPrices = array.new_float()
var int[]   highBars   = array.new_int()

var float[] lowPrices  = array.new_float()
var int[]   lowBars    = array.new_int()


if not na(ph)
    array.unshift(highPrices, ph)
    array.unshift(highBars, bar_index - pivotRight)

    if array.size(highPrices) > 20
        array.pop(highPrices)
        array.pop(highBars)


if not na(pl)
    array.unshift(lowPrices, pl)
    array.unshift(lowBars, bar_index - pivotRight)

    if array.size(lowPrices) > 20
        array.pop(lowPrices)
        array.pop(lowBars)


//====================================================
// HELPERS
//====================================================

f_near(float a, float b, float tolerance) =>
    math.abs(a - b) / ((a + b) / 2.0) * 100.0 <= tolerance


f_line(float p1, int b1, float p2, int b2, int b) =>
    b2 == b1 ? p2 : p1 + (p2 - p1) * (b - b1) / (b2 - b1)


//====================================================
// PIVOT AVAILABILITY
//====================================================

haveHH = array.size(highPrices) >= 2
haveHH3 = array.size(highPrices) >= 3

haveLL = array.size(lowPrices) >= 2
haveLL3 = array.size(lowPrices) >= 3


h1 = haveHH ? array.get(highPrices, 0) : na
h2 = haveHH ? array.get(highPrices, 1) : na
h3 = haveHH3 ? array.get(highPrices, 2) : na

hb1 = haveHH ? array.get(highBars, 0) : na
hb2 = haveHH ? array.get(highBars, 1) : na
hb3 = haveHH3 ? array.get(highBars, 2) : na


l1 = haveLL ? array.get(lowPrices, 0) : na
l2 = haveLL ? array.get(lowPrices, 1) : na
l3 = haveLL3 ? array.get(lowPrices, 2) : na

lb1 = haveLL ? array.get(lowBars, 0) : na
lb2 = haveLL ? array.get(lowBars, 1) : na
lb3 = haveLL3 ? array.get(lowBars, 2) : na


//====================================================
// DOUBLE TOP
//====================================================

doubleTop =
     useDoubleTop and
     haveHH and
     f_near(h1, h2, levelTolerance) and
     l1 < math.min(h1, h2)


// neckline = most recent confirmed low
doubleTopNeck = doubleTop ? l1 : na

doubleTopBreak =
     doubleTop and
     close < doubleTopNeck and
     close[1] >= doubleTopNeck


doubleTopTarget =
     doubleTop ? doubleTopNeck - math.abs(h1 - doubleTopNeck) : na


//====================================================
// DOUBLE BOTTOM
//====================================================

doubleBottom =
     useDoubleBottom and
     haveLL and
     f_near(l1, l2, levelTolerance) and
     h1 > math.max(l1, l2)

doubleBottomNeck = doubleBottom ? h1 : na

doubleBottomBreak =
     doubleBottom and
     close > doubleBottomNeck and
     close[1] <= doubleBottomNeck


doubleBottomTarget =
     doubleBottom ? doubleBottomNeck + math.abs(doubleBottomNeck - l1) : na


//====================================================
// TRIPLE TOP
//====================================================

tripleTop =
     useTripleTop and
     haveHH3 and
     f_near(h1, h2, levelTolerance) and
     f_near(h2, h3, levelTolerance)

tripleTopNeck =
     tripleTop ? math.min(l1, l2) : na

tripleTopBreak =
     tripleTop and
     close < tripleTopNeck and
     close[1] >= tripleTopNeck

tripleTopTarget =
     tripleTop ? tripleTopNeck - math.abs(h1 - tripleTopNeck) : na


//====================================================
// TRIPLE BOTTOM
//====================================================

tripleBottom =
     useTripleBottom and
     haveLL3 and
     f_near(l1, l2, levelTolerance) and
     f_near(l2, l3, levelTolerance)

tripleBottomNeck =
     tripleBottom ? math.max(h1, h2) : na

tripleBottomBreak =
     tripleBottom and
     close > tripleBottomNeck and
     close[1] <= tripleBottomNeck

tripleBottomTarget =
     tripleBottom ? tripleBottomNeck + math.abs(tripleBottomNeck - l1) : na


//====================================================
// TRIANGLE
//====================================================

descendingHighs =
     haveHH and
     h1 < h2

ascendingLows =
     haveLL and
     l1 > l2

triangle =
     useTriangle and
     descendingHighs and
     ascendingLows


upperTriangle =
     triangle ? f_line(h2, hb2, h1, hb1, bar_index) : na

lowerTriangle =
     triangle ? f_line(l2, lb2, l1, lb1, bar_index) : na


triangleBullBreak =
     triangle and
     close > upperTriangle and
     close[1] <= upperTriangle

triangleBearBreak =
     triangle and
     close < lowerTriangle and
     close[1] >= lowerTriangle


triangleHeight =
     triangle ? math.abs(h1 - l1) : na


triangleBullTarget =
     triangleBullBreak ? close + triangleHeight : na

triangleBearTarget =
     triangleBearBreak ? close - triangleHeight : na


//====================================================
// RECTANGLE
//====================================================

rectangle =
     useRectangle and
     haveHH and
     haveLL and
     f_near(h1, h2, levelTolerance) and
     f_near(l1, l2, levelTolerance)


rectHigh =
     rectangle ? math.max(h1, h2) : na

rectLow =
     rectangle ? math.min(l1, l2) : na


rectangleBullBreak =
     rectangle and
     close > rectHigh and
     close[1] <= rectHigh

rectangleBearBreak =
     rectangle and
     close < rectLow and
     close[1] >= rectLow


rectangleHeight =
     rectangle ? rectHigh - rectLow : na


rectangleBullTarget =
     rectangleBullBreak ? close + rectangleHeight : na

rectangleBearTarget =
     rectangleBearBreak ? close - rectangleHeight : na


//====================================================
// WEDGE
//====================================================

risingWedge =
     useWedge and
     descendingHighs == false and
     ascendingLows and
     haveHH and
     haveLL and
     h1 > h2


fallingWedge =
     useWedge and
     descendingHighs and
     haveLL and
     l1 < l2


risingWedgeBreak =
     risingWedge and
     close < lowerTriangle and
     close[1] >= lowerTriangle


fallingWedgeBreak =
     fallingWedge and
     close > upperTriangle and
     close[1] <= upperTriangle


//====================================================
// SELECT SIGNAL
//====================================================

bool longSignal = false
bool shortSignal = false

float selectedSL = na
float selectedTP = na

string selectedPattern = ""


// DOUBLE BOTTOM
if doubleBottomBreak
    longSignal := true
    selectedSL := l1
    selectedTP := doubleBottomTarget
    selectedPattern := "Double Bottom"


// TRIPLE BOTTOM
if tripleBottomBreak and not longSignal
    longSignal := true
    selectedSL := l1
    selectedTP := tripleBottomTarget
    selectedPattern := "Triple Bottom"


// TRIANGLE LONG
if triangleBullBreak and not longSignal
    longSignal := true
    selectedSL := lowerTriangle
    selectedTP := triangleBullTarget
    selectedPattern := "Triangle Bull"


// RECTANGLE LONG
if rectangleBullBreak and not longSignal
    longSignal := true
    selectedSL := rectLow
    selectedTP := rectangleBullTarget
    selectedPattern := "Rectangle Bull"


// FALLING WEDGE LONG
if fallingWedgeBreak and not longSignal
    longSignal := true
    selectedSL := l1
    selectedTP := fallingWedgeBreak ? close + triangleHeight : na
    selectedPattern := "Falling Wedge"


// DOUBLE TOP
if doubleTopBreak
    shortSignal := true
    selectedSL := h1
    selectedTP := doubleTopTarget
    selectedPattern := "Double Top"


// TRIPLE TOP
if tripleTopBreak and not shortSignal
    shortSignal := true
    selectedSL := h1
    selectedTP := tripleTopTarget
    selectedPattern := "Triple Top"


// TRIANGLE SHORT
if triangleBearBreak and not shortSignal
    shortSignal := true
    selectedSL := upperTriangle
    selectedTP := triangleBearTarget
    selectedPattern := "Triangle Bear"


// RECTANGLE SHORT
if rectangleBearBreak and not shortSignal
    shortSignal := true
    selectedSL := rectHigh
    selectedTP := rectangleBearTarget
    selectedPattern := "Rectangle Bear"


// RISING WEDGE SHORT
if risingWedgeBreak and not shortSignal
    shortSignal := true
    selectedSL := h1
    selectedTP := risingWedgeBreak ? close - triangleHeight : na
    selectedPattern := "Rising Wedge"


//====================================================
// FILTERS
//====================================================

inSession =
     not useSession or
     not na(time(timeframe.period, sessionInput))


emaLongOK =
     not useEMA or
     close > ema

emaShortOK =
     not useEMA or
     close < ema


patternSizeOK =
     not useATR or
     math.abs(h1 - l1) >= atr * minPatternATR


//====================================================
// R:R VALIDATION
//====================================================

longRisk =
     longSignal and
     not na(selectedSL) ?
     close - selectedSL : na

shortRisk =
     shortSignal and
     not na(selectedSL) ?
     selectedSL - close : na


longRR =
     longSignal and
     longRisk > 0 and
     not na(selectedTP) ?
     (selectedTP - close) / longRisk : na

shortRR =
     shortSignal and
     shortRisk > 0 and
     not na(selectedTP) ?
     (close - selectedTP) / shortRisk : na


longValid =
     longSignal and
     inSession and
     emaLongOK and
     patternSizeOK and
     longRR >= rr


shortValid =
     shortSignal and
     inSession and
     emaShortOK and
     patternSizeOK and
     shortRR >= rr


//====================================================
// ONE TRADE PER DAY
//====================================================

var int tradesToday = 0

newDay = ta.change(time("D")) != 0

if newDay
    tradesToday := 0


canTradeToday =
     not oneTradePerDay or
     tradesToday == 0


//====================================================
// EXECUTION
//====================================================

if longValid and canTradeToday and strategy.position_size == 0

    strategy.entry(
         "LONG",
         strategy.long)

    strategy.exit(
         "LONG EXIT",
         "LONG",
         stop = selectedSL,
         limit = selectedTP)

    tradesToday += 1


if shortValid and canTradeToday and strategy.position_size == 0

    strategy.entry(
         "SHORT",
         strategy.short)

    strategy.exit(
         "SHORT EXIT",
         "SHORT",
         stop = selectedSL,
         limit = selectedTP)

    tradesToday += 1


//====================================================
// VISUALS
//====================================================

plot(
     ema,
     "EMA",
     color = color.orange,
     linewidth = 1)

plotshape(
     longValid and canTradeToday,
     title = "Long Signal",
     style = shape.triangleup,
     location = location.belowbar,
     color = color.lime,
     size = size.tiny,
     text = "BUY")

plotshape(
     shortValid and canTradeToday,
     title = "Short Signal",
     style = shape.triangledown,
     location = location.abovebar,
     color = color.red,
     size = size.tiny,
     text = "SELL")
````
