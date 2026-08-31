<!-- tradingview-pine-id: PUB;7b7a114da87c4a90b9e01d47e85dc620 -->
<!-- tradingviewscripts-format: 1 -->
# CNPS 03 SMA 34/89 Dual Slope

Source: https://www.tradingview.com/script/VFP7QkqV/

## Description

"SMA 34/89 Dual Slope Trend Following" is a trend-following strategy designed to capture sustained directional price movements by identifying alignment between short-term and medium-term trend momentum. The strategy uses SMA(34) and SMA(89), generating Long signals when both moving averages are rising and Short signals when both are falling.

By requiring both SMA slopes to confirm the same direction, the strategy seeks to filter out weaker signals and avoid trades when short- and medium-term trends are not aligned. An optional SMA(200) trend filter provides an additional layer of broader trend confirmation. The strategy also includes configurable stop loss, take profit, trading session filters, and automatic end-of-session position closure for disciplined risk management.

Strategy settings and configuration:
Chart timeframe: recommended 2-minute chart
Position size: 3 contracts
Fast SMA length: 34
Slow SMA length: 89
SMA trend filter: disabled by default
Trend filter SMA length: 200
Stop loss: 10 points
Take profit: 20 points
Take profit: On / Off
Time filter: On / Off
Trading session: 09:00 – 14:30
Trade direction: Long / Short / Both
Signal arrows: disabled by default

Default script settings:
The strategy uses two main SMA lines: SMA(34) and SMA(89). SMA(34) reflects the short-term trend. SMA(89) represents the medium-term trend.
Unlike a traditional SMA crossover strategy, CNPS 03 does not wait for the two SMA lines to cross. Instead, the bot evaluates the slope of each SMA line to identify trend direction.
When SMA(34) is rising and SMA(89) is also rising, the bot confirms an uptrend. When SMA(34) is falling and SMA(89) is also falling, the bot confirms a downtrend.
The SMA(200) trend filter is disabled by default. This is because SMA(89) already acts as a medium-term trend component in the strategy. Users can still enable SMA(200) if they want a stricter trend filter.
When the SMA(200) trend filter is enabled, the script only allows Long trades when SMA(200) is rising and only allows Short trades when SMA(200) is falling.

Entry and exit rules:
Long entry:
SMA(34) is rising
AND SMA(89) is rising
AND SMA(200) is rising, if the SMA trend filter is enabled
AND the signal appears during the trading session
AND trade direction allows Long entries
Long exit:
Stop loss: 10 points from entry price
Take profit: 20 points from entry price, if enabled
Reversal when a valid Short signal appears
Close position when the SMA trend filter turns downward, if the SMA trend filter is enabled
Automatic position close at the end of the trading session

Short entry:
SMA(34) is falling
AND SMA(89) is falling
AND SMA(200) is falling, if the SMA trend filter is enabled
AND the signal appears during the trading session
AND trade direction allows Short entries
Short exit:
Stop loss: 10 points from entry price
Take profit: 20 points from entry price, if enabled
Reversal when a valid Long signal appears
Close position when the SMA trend filter turns upward, if the SMA trend filter is enabled
Automatic position close at the end of the trading session

Strategy logic:
CNPS 03 is suitable for market phases with clear trend direction. When both the fast SMA and the slow SMA are pointing in the same direction, the bot prioritizes trading in that direction.
This design allows the bot to react earlier than a traditional SMA crossover strategy. However, during sideways market conditions, the SMA slopes may change frequently. Users should test the strategy carefully before applying it to live trading.
Time filter:
The default trading session is 09:00 – 14:30, designed to avoid two abnormal volatility periods.
ATO 08:45 – 09:00 is the opening auction period. Price can gap strongly and technical signals may be noisy.
ATC and negotiated trading 14:30 – 15:00 is the closing auction period. Price can move sharply or reverse quickly.
Users can adjust the start time and end time in the bot settings.

Risk disclaimer:
Futures trading involves a high level of risk and prices can move sharply. This script is provided for reference, research, and backtesting purposes only. Users should fully understand derivatives trading, their own risk tolerance, and the strategy logic before applying it to live trading.
All investment decisions are the responsibility of the user. phaisinh.online is not responsible for any losses arising from the use of this strategy in real trading. Past performance does not guarantee future results.
__________________________________________________________

"SMA 34/89 Dual Slope Trend Following" là một chiến lược giao dịch theo xu hướng, được thiết kế nhằm nắm bắt các chuyển động giá có xu hướng kéo dài bằng cách xác định sự đồng thuận giữa xu hướng ngắn hạn và trung hạn. Chiến lược sử dụng SMA(34) và SMA(89), tạo tín hiệu Long khi cả hai đường trung bình động đều dốc lên và tín hiệu Short khi cả hai đều dốc xuống.

Bằng cách yêu cầu độ dốc của cả hai đường SMA xác nhận cùng một hướng, chiến lược hướng tới việc lọc các tín hiệu yếu và hạn chế giao dịch khi xu hướng ngắn hạn và trung hạn chưa đồng thuận. Bộ lọc xu hướng SMA(200) tùy chọn cung cấp thêm một lớp xác nhận xu hướng tổng thể. Chiến lược cũng bao gồm các tùy chọn Stop Loss, Take Profit, bộ lọc khung thời gian giao dịch và cơ chế tự động đóng vị thế khi kết thúc phiên, nhằm đảm bảo quản trị rủi ro một cách chặt chẽ và có kỷ luật.

Cài đặt & cấu hình chiến lược:
Biểu đồ: khuyến nghị khung 2 phút
Khối lượng giao dịch: 3 hợp đồng
Chu kỳ SMA nhanh: 34
Chu kỳ SMA chậm: 89
Bộ lọc xu hướng SMA: Tắt mặc định
Chu kỳ SMA bộ lọc: 200
Cắt lỗ: 10 điểm
Chốt lời: 20 điểm
Dùng chốt lời: Bật / Tắt
Bộ lọc giờ: Bật / Tắt
Khung giờ giao dịch: 09:00 – 14:30
Chiều giao dịch: Mua / Bán / Cả hai
Hiện mũi tên tín hiệu: Tắt mặc định

Cài đặt mặc định của script:
Chiến lược sử dụng hai đường SMA chính là SMA(34) và SMA(89). SMA(34) phản ánh xu hướng ngắn hạn. SMA(89) đại diện cho xu hướng trung hạn.
Khác với chiến lược giao cắt SMA thông thường, CNPS 03 không chờ hai đường SMA cắt nhau. Bot đánh giá độ dốc của từng đường SMA để xác định xu hướng.
Khi SMA(34) dốc lên và SMA(89) cũng dốc lên, bot xác nhận xu hướng tăng. Khi SMA(34) dốc xuống và SMA(89) cũng dốc xuống, bot xác nhận xu hướng giảm.
Bộ lọc xu hướng SMA(200) được để tắt mặc định. Lý do là SMA(89) đã đóng vai trò lọc xu hướng trung hạn trong chiến lược. Người dùng vẫn có thể bật thêm SMA(200) nếu muốn lọc xu hướng chặt hơn.
Khi bật bộ lọc SMA(200), script chỉ cho phép lệnh Mua khi SMA(200) dốc lên và chỉ cho phép lệnh Bán khi SMA(200) dốc xuống.

Điều kiện vào và thoát lệnh:
Vào lệnh Mua:
SMA(34) dốc lên
VÀ SMA(89) dốc lên
VÀ SMA(200) dốc lên, nếu bật bộ lọc xu hướng SMA
VÀ tín hiệu xuất hiện trong khung giờ giao dịch
VÀ chiều giao dịch cho phép lệnh Mua
Thoát lệnh Mua:
Cắt lỗ: 10 điểm từ giá vào lệnh
Chốt lời: 20 điểm từ giá vào lệnh, nếu bật
Đảo chiều khi xuất hiện tín hiệu Bán hợp lệ
Đóng lệnh khi SMA bộ lọc đảo chiều xuống, nếu bật bộ lọc xu hướng SMA
Tự động đóng lệnh khi hết khung giờ giao dịch

Vào lệnh Bán:
SMA(34) dốc xuống
VÀ SMA(89) dốc xuống
VÀ SMA(200) dốc xuống, nếu bật bộ lọc xu hướng SMA
VÀ tín hiệu xuất hiện trong khung giờ giao dịch
VÀ chiều giao dịch cho phép lệnh Bán
Thoát lệnh Bán:
Cắt lỗ: 10 điểm từ giá vào lệnh
Chốt lời: 20 điểm từ giá vào lệnh, nếu bật
Đảo chiều khi xuất hiện tín hiệu Mua hợp lệ
Đóng lệnh khi SMA bộ lọc đảo chiều lên, nếu bật bộ lọc xu hướng SMA
Tự động đóng lệnh khi hết khung giờ giao dịch

Logic chiến lược:
CNPS 03 phù hợp với các giai đoạn thị trường có xu hướng rõ ràng. Khi cả SMA nhanh và SMA chậm cùng nghiêng về một hướng, bot ưu tiên giao dịch theo hướng đó.
Thiết kế này giúp bot phản ứng sớm hơn so với chiến lược chờ giao cắt SMA truyền thống. Tuy nhiên, trong giai đoạn thị trường đi ngang, hai đường SMA có thể đổi độ dốc liên tục. Vì vậy, người dùng nên kiểm thử kỹ trước khi sử dụng thực tế.
Bộ lọc giờ:
Mặc định 09:00 – 14:30, nhằm tránh hai vùng biến động bất thường.
ATO 08:45 – 09:00 là giai đoạn khớp lệnh mở cửa. Giá thường có thể gap mạnh và tín hiệu kỹ thuật dễ bị nhiễu.
ATC và giao dịch thỏa thuận 14:30 – 15:00 là giai đoạn khớp lệnh đóng cửa. Giá có thể biến động mạnh hoặc đảo chiều nhanh.
Người dùng có thể điều chỉnh giờ bắt đầu và giờ kết thúc trong phần cài đặt bot.

Tuyên bố rủi ro:
Giao dịch hợp đồng tương lai có mức độ rủi ro cao và giá có thể biến động mạnh. Script này chỉ phục vụ mục đích tham khảo, nghiên cứu và kiểm thử. Người dùng cần hiểu rõ giao dịch phái sinh, khẩu vị rủi ro cá nhân và logic của chiến lược trước khi áp dụng vào giao dịch thực tế.
Mọi quyết định đầu tư thuộc trách nhiệm của người dùng. phaisinh.online không chịu trách nhiệm cho bất kỳ khoản lỗ nào phát sinh từ việc sử dụng chiến lược này trong giao dịch thực tế. Hiệu quả trong quá khứ không đảm bảo kết quả trong tương lai.

---

## Source Code

````pine
// ╔══════════════════════════════════════════════════════════════╗
// ║        CNPS Universal Bot Template — Pine Script v6          ║
// ║  Instrument: VN30! | SMA Dual Slope Trend Following          ║
// ║  Version: CNPS 03 SMA 34/89 Dual Slope                       ║
// ║  Recommended timeframe: M2 | Slippage = 3                    ║
// ╚══════════════════════════════════════════════════════════════╝
//*The cost to open a position in futures trading is roughly VND 30,000,000 per contract.
//For VN Future Trading, the commission value is set at VND 10,000 per contract traded. Tax is not yet included.

//@version=6
strategy(
     title       = "CNPS 03 SMA 34/89 Dual Slope",
     shorttitle  = "CNPS 03",
     overlay     = true,
     initial_capital    = 100000000,
     default_qty_type   = strategy.fixed,
     default_qty_value  = 3,
     margin_long        = 0,
     margin_short       = 0,
     slippage           = 3,
     commission_type    = strategy.commission.cash_per_contract,
     commission_value   = 10000,
     fill_orders_on_standard_ohlc = true
 )


// ════════════════════════════════════════════════════════════════
// SECTION 1: INPUTS
// ════════════════════════════════════════════════════════════════

// ── Indicator settings ──────────────────────────────────────────
smaFastLen = input.int(
     34,
     title="Fast SMA Length",
     minval=1,
     group="Indicator Settings"
 )

smaSlowLen = input.int(
     89,
     title="Slow SMA Length",
     minval=1,
     group="Indicator Settings"
 )

// ── SMA trend filter ────────────────────────────────────────────
// This strategy already uses fast and slow SMA slopes as the main signal.
// The additional SMA trend filter is disabled by default to avoid overlap.
useTrendFilter = input.bool(
     false,
     title="Use SMA Trend Filter?",
     group="Trend Filter"
 )

smaLen = input.int(
     200,
     title="SMA Length",
     minval=1,
     group="Trend Filter"
 )

// ── Trade direction ─────────────────────────────────────────────
tradeDir = input.string(
     "Both",
     title="Trade Direction",
     options=["Long", "Short", "Both"],
     group="Trade Direction"
 )

// ── Stop loss / Take profit ─────────────────────────────────────
slPoints = input.float(
     10.0,
     title="Stop Loss Points",
     minval=0.1,
     step=0.5,
     group="Stop Loss / Take Profit"
 )

useTP = input.bool(
     true,
     title="Use Take Profit?",
     group="Stop Loss / Take Profit"
 )

tpPoints = input.float(
     20.0,
     title="Take Profit Points",
     minval=0.1,
     step=0.5,
     group="Stop Loss / Take Profit"
 )

// ── Time filter ─────────────────────────────────────────────────
useTimeFilter = input.bool(
     true,
     title="Use Time Filter?",
     group="Time Filter"
 )

startHour = input.int(
     9,
     title="Start Hour",
     minval=0,
     maxval=23,
     group="Time Filter"
 )

startMinute = input.int(
     0,
     title="Start Minute",
     minval=0,
     maxval=59,
     group="Time Filter"
 )

endHour = input.int(
     14,
     title="End Hour",
     minval=0,
     maxval=23,
     group="Time Filter"
 )

endMinute = input.int(
     30,
     title="End Minute",
     minval=0,
     maxval=59,
     group="Time Filter"
 )

// ── Display settings ────────────────────────────────────────────
showSignalShapes = input.bool(
     false,
     title="Show Signal Arrows?",
     group="Display"
 )


// ════════════════════════════════════════════════════════════════
// SECTION 2: INDICATORS
// ════════════════════════════════════════════════════════════════

// ── SMA trend filter ────────────────────────────────────────────
smaTrend = ta.sma(close, smaLen)

isBull = smaTrend >= smaTrend[1]
isBear = smaTrend < smaTrend[1]

// ── Main trend indicators ───────────────────────────────────────
smaFast = ta.sma(close, smaFastLen)
smaSlow = ta.sma(close, smaSlowLen)

// Slope direction for each SMA.
fastRising = smaFast >= smaFast[1]
fastFalling = smaFast < smaFast[1]

slowRising = smaSlow >= smaSlow[1]
slowFalling = smaSlow < smaSlow[1]


// ════════════════════════════════════════════════════════════════
// SECTION 3: STRATEGY RATIONALE
// ════════════════════════════════════════════════════════════════

// This strategy uses two Simple Moving Averages to identify trend direction.
// The fast SMA reacts more quickly to recent price movement,
// while the slow SMA represents a broader and more stable trend structure.
//
// Instead of using only a crossover,
// this strategy focuses on the slope direction of both SMA lines.
// When both the fast SMA and slow SMA are rising,
// it suggests that short-term and medium-term trend direction are aligned upward.
//
// When both the fast SMA and slow SMA are falling,
// it suggests that short-term and medium-term trend direction are aligned downward.
//
// This dual-slope approach is designed to reduce weak signals
// that may appear when only one moving average changes direction.
// It requires both moving averages to confirm the same trend direction
// before a trade signal is generated.
//
// An additional SMA trend filter is also available.
// However, it is disabled by default because the main signal
// already uses two SMA slopes to confirm trend direction.
// When enabled, the extra SMA filter can be used as a broader trend confirmation layer.


// ════════════════════════════════════════════════════════════════
// SECTION 4: SIGNAL LOGIC
// ════════════════════════════════════════════════════════════════

// Signals are confirmed at candle close.
// Orders are executed on the next candle open.
//
// Long signal:
// The fast SMA is rising and the slow SMA is rising.
//
// Short signal:
// The fast SMA is falling and the slow SMA is falling.
rawLong = fastRising and slowRising
rawShort = fastFalling and slowFalling

// ── Apply SMA trend filter ──────────────────────────────────────
// When the SMA filter is enabled,
// Long trades require a rising SMA,
// and Short trades require a falling SMA.
longSignal = rawLong and (useTrendFilter ? isBull : true)
shortSignal = rawShort and (useTrendFilter ? isBear : true)

// ── Apply trade direction ───────────────────────────────────────
canLongDir = tradeDir == "Long" or tradeDir == "Both"
canShortDir = tradeDir == "Short" or tradeDir == "Both"


// ════════════════════════════════════════════════════════════════
// SECTION 5: TIME FILTER
// ════════════════════════════════════════════════════════════════

sessionStart = startHour * 60 + startMinute
sessionEnd = endHour * 60 + endMinute
currentMinutes = hour(time) * 60 + minute(time)

inSession = useTimeFilter
     ? currentMinutes >= sessionStart and currentMinutes < sessionEnd
     : true

// Detect the first candle outside the trading session.
sessionJustEnded = useTimeFilter and not inSession and inSession[1]


// ════════════════════════════════════════════════════════════════
// SECTION 6: ENTRY / EXIT / REVERSE
// ════════════════════════════════════════════════════════════════

// ── Detect SMA trend filter reversals ───────────────────────────
smaFlipBear = useTrendFilter and isBear and isBull[1]
smaFlipBull = useTrendFilter and isBull and isBear[1]

// ── Close Long position when the SMA trend filter turns bearish ─
if smaFlipBear and strategy.position_size > 0
    strategy.close(
         "Long",
         comment="SMA Reversal"
     )

// ── Close Short position when the SMA trend filter turns bullish ─
if smaFlipBull and strategy.position_size < 0
    strategy.close(
         "Short",
         comment="SMA Reversal"
     )

// ── Close all positions after the trading session ends ──────────
if sessionJustEnded and strategy.position_size != 0
    strategy.close_all(comment="Session End")

// ── Entry conditions ────────────────────────────────────────────
canLong = longSignal and inSession and canLongDir
canShort = shortSignal and inSession and canShortDir

// ── Stop loss and take profit levels ────────────────────────────
longSL = strategy.position_avg_price - slPoints
longTP = strategy.position_avg_price + tpPoints

shortSL = strategy.position_avg_price + slPoints
shortTP = strategy.position_avg_price - tpPoints

// ── Entries / reversals ─────────────────────────────────────────
// When a valid Long signal appears, the strategy opens a Long position.
// When a valid Short signal appears, the strategy opens a Short position.
// If an opposite position already exists, strategy.entry handles the reversal.
if canLong
    strategy.entry("Long", strategy.long)

if canShort
    strategy.entry("Short", strategy.short)

// ── Stop loss / take profit exits ───────────────────────────────
// Stop Loss is calculated from the average entry price.
// Take Profit is used only when the Use Take Profit option is enabled.
// All positions are also closed after the trading session ends.
if strategy.position_size > 0
    strategy.exit(
         "Exit Long",
         "Long",
         stop=longSL,
         limit=useTP ? longTP : na
     )

if strategy.position_size < 0
    strategy.exit(
         "Exit Short",
         "Short",
         stop=shortSL,
         limit=useTP ? shortTP : na
     )


// ════════════════════════════════════════════════════════════════
// SECTION 7: PLOTTING
// ════════════════════════════════════════════════════════════════

// ── SMA trend filter plot ───────────────────────────────────────
plot(
     useTrendFilter ? smaTrend : na,
     title="SMA Trend Filter",
     color=isBull ? color.new(color.green, 40) : color.new(color.red, 40),
     linewidth=1
 )

// ── Fast and slow SMA plots ─────────────────────────────────────
plot(
     smaFast,
     title="Fast SMA",
     color=fastRising ? color.new(color.blue, 20) : color.new(color.orange, 20),
     linewidth=2
 )

plot(
     smaSlow,
     title="Slow SMA",
     color=slowRising ? color.new(color.teal, 20) : color.new(color.maroon, 20),
     linewidth=2
 )

// ── Stop loss / take profit plots ───────────────────────────────
isLong = strategy.position_size > 0
isShort = strategy.position_size < 0

plot(
     isLong ? longSL : na,
     title="Long Stop Loss",
     color=color.red,
     style=plot.style_linebr,
     linewidth=1
 )

plot(
     isShort ? shortSL : na,
     title="Short Stop Loss",
     color=color.red,
     style=plot.style_linebr,
     linewidth=1
 )

plot(
     isLong and useTP ? longTP : na,
     title="Long Take Profit",
     color=color.green,
     style=plot.style_linebr,
     linewidth=1
 )

plot(
     isShort and useTP ? shortTP : na,
     title="Short Take Profit",
     color=color.green,
     style=plot.style_linebr,
     linewidth=1
 )

// ── Entry signal arrows ─────────────────────────────────────────
longEntryShape = showSignalShapes and canLong and strategy.position_size <= 0
shortEntryShape = showSignalShapes and canShort and strategy.position_size >= 0

plotshape(
     longEntryShape,
     title="Long Signal",
     location=location.belowbar,
     color=color.new(color.green, 0),
     style=shape.triangleup,
     size=size.small
 )

plotshape(
     shortEntryShape,
     title="Short Signal",
     location=location.abovebar,
     color=color.new(color.red, 0),
     style=shape.triangledown,
     size=size.small
 )

// ── Background outside the trading session ──────────────────────
bgcolor(
     useTimeFilter and not inSession ? color.new(color.gray, 90) : na,
     title="Outside Trading Session"
 )
````
