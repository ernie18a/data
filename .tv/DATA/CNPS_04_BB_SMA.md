<!-- tradingview-pine-id: PUB;2b9d25a3e9724de1b2798d4103962902 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# CNPS 04 BB SMA

Source: https://www.tradingview.com/script/gqnCcy2v/

## Description

"Bollinger Bands Breakout with SMA Trend Filter" is a volatility-based trend-following strategy designed to capture strong directional price movements when price breaks beyond its recent volatility range. The strategy uses Bollinger Bands with a default SMA(20) basis and 2.0 standard deviations to identify bullish breakouts above the upper band and bearish breakouts below the lower band.

To improve signal quality, the strategy combines Bollinger Band breakouts with a mandatory SMA(200) trend filter, allowing Long trades only when the SMA is rising and Short trades only when it is falling. By combining volatility expansion with broader trend confirmation, the strategy seeks to reduce counter-trend and false breakout signals while participating in stronger intraday movements. It also includes configurable stop loss, take profit, trading session, trade direction, and automatic end-of-session position closure for disciplined risk management. 

Strategy settings and configuration:
Chart timeframe: recommended 5-minute chart
Position size: 3 contracts
Bollinger Bands length: 20
Bollinger Bands multiplier: 2.0
SMA length: 200
Stop loss: 10 points
Take profit: 20 points
SMA trend filter: always enabled
Take profit: On / Off
Time filter: On / Off
Trading session: 09:00 – 14:30
Trade direction: Long / Short / Both

Default script settings:
The strategy calculates Bollinger Bands using the SMA(20) of the closing price. The upper and lower bands are created by adding or subtracting two standard deviations around the middle line.
When the closing price breaks above the upper Bollinger Band, buying pressure may be taking control. When the closing price breaks below the lower Bollinger Band, selling pressure may be taking control.
SMA(200) is used as the main trend filter. When SMA(200) is rising, the script only allows Long trades. When SMA(200) is falling, the script only allows Short trades.
In CNPS 04, the SMA(200) filter is always enabled. This helps the bot filter out breakout signals that go against the longer-term trend.
Users can add the built-in Bollinger Bands indicator on TradingView with Length 20 and Multiplier 2.0 to visually monitor the signal on the price chart.

Entry and exit rules:
Long entry:
Closing price > upper Bollinger Band
AND SMA(200) is rising
AND the signal appears during the trading session
AND trade direction allows Long entries
Long exit:
Stop loss: 10 points from entry price
Take profit: 20 points from entry price, if enabled
Opposite breakout signal appears
Reversal when a valid Short signal appears
Automatic position close at the end of the trading session

Short entry:
Closing price < lower Bollinger Band
AND SMA(200) is falling
AND the signal appears during the trading session
AND trade direction allows Short entries
Short exit:
Stop loss: 10 points from entry price
Take profit: 20 points from entry price, if enabled
Opposite breakout signal appears
Reversal when a valid Long signal appears
Automatic position close at the end of the trading session

Risk disclaimer:
Futures trading involves a high level of risk and prices can move sharply. This script is provided for reference, research, and backtesting purposes only. Users should fully understand derivatives trading, their own risk tolerance, and the strategy logic before applying it to live trading.
All investment decisions are the responsibility of the user. phaisinh.online is not responsible for any losses arising from the use of this strategy in real trading. Past performance does not guarantee future results.
_________________________________________________________________

"Bollinger Bands Breakout với Bộ lọc Xu hướng SMA" là một chiến lược giao dịch theo xu hướng dựa trên biến động, được thiết kế nhằm nắm bắt các chuyển động giá mạnh theo một hướng khi giá phá vỡ khỏi vùng biến động gần nhất. Chiến lược sử dụng Bollinger Bands với đường cơ sở mặc định là SMA(20) và 2,0 độ lệch chuẩn để xác định tín hiệu bứt phá tăng khi giá vượt lên trên dải trên và tín hiệu bứt phá giảm khi giá xuống dưới dải dưới.

Để nâng cao chất lượng tín hiệu, chiến lược kết hợp tín hiệu bứt phá Bollinger Bands với bộ lọc xu hướng SMA(200) bắt buộc, chỉ cho phép giao dịch Long khi SMA đang dốc lên và giao dịch Short khi SMA đang dốc xuống. Bằng cách kết hợp sự mở rộng của biến động với xác nhận xu hướng tổng thể, chiến lược hướng tới việc giảm thiểu các tín hiệu giao dịch ngược xu hướng và các tín hiệu phá vỡ giả, đồng thời tận dụng các chuyển động intraday mạnh hơn. Chiến lược cũng bao gồm các tùy chọn Stop Loss, Take Profit, khung thời gian giao dịch, hướng giao dịch và cơ chế tự động đóng vị thế khi kết thúc phiên, nhằm đảm bảo quản trị rủi ro một cách chặt chẽ và có kỷ luật.

Cài đặt & cấu hình chiến lược:
Biểu đồ: khuyến nghị khung 5 phút
Khối lượng giao dịch: 3 hợp đồng
Chu kỳ Bollinger Bands: 20
Hệ số nhân Bollinger Bands: 2.0
Chu kỳ SMA: 200
Cắt lỗ: 10 điểm
Chốt lời: 20 điểm
Bộ lọc xu hướng SMA: luôn bật
Dùng chốt lời: Bật / Tắt
Bộ lọc giờ: Bật / Tắt
Khung giờ giao dịch: 09:00 – 14:30
Chiều giao dịch: Mua / Bán / Cả hai

Cài đặt mặc định của script:
Chiến lược tính toán Bollinger Bands dựa trên đường SMA(20) của giá đóng cửa. Dải trên và dải dưới được tạo bằng cách cộng hoặc trừ hai độ lệch chuẩn quanh đường giữa.
Khi giá đóng cửa vượt lên trên dải trên Bollinger Bands, lực mua có thể đang chiếm ưu thế. Khi giá đóng cửa phá xuống dưới dải dưới Bollinger Bands, lực bán có thể đang chiếm ưu thế.
SMA(200) được dùng làm bộ lọc xu hướng chính. Khi SMA(200) dốc lên, script chỉ cho phép lệnh Mua. Khi SMA(200) dốc xuống, script chỉ cho phép lệnh Bán.
Trong CNPS 04, bộ lọc SMA(200) luôn bật. Điều này giúp bot loại bỏ bớt các tín hiệu breakout đi ngược xu hướng dài hạn.
Người dùng có thể thêm chỉ báo Bollinger Bands có sẵn trên TradingView với tham số Length 20 và Multiplier 2.0 để quan sát tín hiệu trực quan trên biểu đồ giá.

Điều kiện vào và thoát lệnh:
Vào lệnh Mua:
Giá đóng cửa > dải trên Bollinger Bands
VÀ SMA(200) dốc lên
VÀ tín hiệu xuất hiện trong khung giờ giao dịch
VÀ chiều giao dịch cho phép lệnh Mua
Thoát lệnh Mua:
Cắt lỗ: 10 điểm từ giá vào lệnh
Chốt lời: 20 điểm từ giá vào lệnh, nếu bật
Có tín hiệu breakout ngược chiều
Đảo chiều khi xuất hiện tín hiệu Bán hợp lệ
Tự động đóng lệnh khi hết khung giờ giao dịch

Vào lệnh Bán:
Giá đóng cửa < dải dưới Bollinger Bands
VÀ SMA(200) dốc xuống
VÀ tín hiệu xuất hiện trong khung giờ giao dịch
VÀ chiều giao dịch cho phép lệnh Bán
Thoát lệnh Bán:
Cắt lỗ: 10 điểm từ giá vào lệnh
Chốt lời: 20 điểm từ giá vào lệnh, nếu bật
Có tín hiệu breakout ngược chiều
Đảo chiều khi xuất hiện tín hiệu Mua hợp lệ
Tự động đóng lệnh khi hết khung giờ giao dịch

Tuyên bố rủi ro:
Giao dịch hợp đồng tương lai có mức độ rủi ro cao và giá có thể biến động mạnh. Script này chỉ phục vụ mục đích tham khảo, nghiên cứu và kiểm thử. Người dùng cần hiểu rõ giao dịch phái sinh, khẩu vị rủi ro cá nhân và logic của chiến lược trước khi áp dụng vào giao dịch thực tế.
Mọi quyết định đầu tư thuộc trách nhiệm của người dùng. phaisinh.online không chịu trách nhiệm cho bất kỳ khoản lỗ nào phát sinh từ việc sử dụng chiến lược này trong giao dịch thực tế. Hiệu quả trong quá khứ không đảm bảo kết quả trong tương lai.

---

## Source Code

````pine
// ╔══════════════════════════════════════════════════════════════╗
// ║        CNPS Universal Bot Template — Pine Script v6          ║
// ║  Instrument: VN30! | BB SMA Trend Following                  ║
// ║  Version: CNPS 04 BB SMA                                     ║
// ║  Recommended timeframe: M1 | Slippage = 3                    ║ 
// ╚══════════════════════════════════════════════════════════════╝
//*The cost to open a position in futures trading is roughly VND 30,000,000 per contract.
//For VN Future Trading, the commission value is set at VND 10,000 per contract traded. Tax is not yet included.

//@version=6
strategy(
     title       = "CNPS 04 BB SMA",
     shorttitle  = "CNPS 04",
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

// ── Bollinger Bands settings ────────────────────────────────────
bbLen = input.int(
     20,
     title="BB Length",
     minval=1,
     group="Bollinger Bands"
 )

bbMult = input.float(
     2.0,
     title="BB Multiplier",
     minval=0.1,
     step=0.1,
     group="Bollinger Bands"
 )

// ── SMA trend filter ────────────────────────────────────────────
// The SMA trend filter is always enabled in this strategy.
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

// ── Fixed SMA trend filter ──────────────────────────────────────
smaTrend = ta.sma(close, smaLen)

isBull = smaTrend >= smaTrend[1]
isBear = smaTrend < smaTrend[1]

// ── Bollinger Bands ─────────────────────────────────────────────
bbBasis = ta.sma(close, bbLen)
bbDev   = bbMult * ta.stdev(close, bbLen)

bbUpper = bbBasis + bbDev
bbLower = bbBasis - bbDev


// ════════════════════════════════════════════════════════════════
// SECTION 3: STRATEGY RATIONALE
// ════════════════════════════════════════════════════════════════

// Bollinger Bands are used to identify volatility-based price expansion.
// The basis line represents the moving average,
// while the upper and lower bands expand or contract based on market volatility.
//
// In this strategy, the signal is based on a confirmed crossover
// above the upper Bollinger Band or a confirmed crossunder
// below the lower Bollinger Band.
//
// A crossover above the upper band may indicate that buying pressure
// is strong enough to push price beyond its recent volatility range.
// A crossunder below the lower band may indicate that selling pressure
// is strong enough to push price below its recent volatility range.
//
// However, Bollinger Band breakout signals can become noisy
// when the market is sideways or when price briefly expands
// outside the band without broader trend support.
//
// For that reason, this strategy combines Bollinger Bands
// with a fixed SMA trend filter.
// Bollinger Bands identify the breakout trigger.
// The SMA filter checks whether the broader trend supports that breakout.
//
// If the SMA is rising, the strategy allows Long signals.
// If the SMA is falling, the strategy allows Short signals.
// This combination is designed to reduce counter-trend entries
// and improve the overall quality of volatility breakout signals.


// ════════════════════════════════════════════════════════════════
// SECTION 4: SIGNAL LOGIC
// ════════════════════════════════════════════════════════════════

// Signals are confirmed at candle close.
// Orders are executed on the next candle open.
//
// Long signal:
// Price crosses above the upper Bollinger Band.
//
// Short signal:
// Price crosses below the lower Bollinger Band.
rawLong = ta.crossover(close, bbUpper)
rawShort = ta.crossunder(close, bbLower)

// ── Apply fixed SMA trend filter ────────────────────────────────
// Long trades require a rising SMA.
// Short trades require a falling SMA.
longSignal = rawLong and isBull
shortSignal = rawShort and isBear

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

// ── Close positions when the SMA trend reverses ─────────────────
smaFlipBear = isBear and isBull[1]
smaFlipBull = isBull and isBear[1]

if smaFlipBear and strategy.position_size > 0
    strategy.close(
         "Long",
         comment="SMA Reversal"
     )

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

// ── Entries ─────────────────────────────────────────────────────
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

// ── Fixed SMA trend filter plot ─────────────────────────────────
plot(
     smaTrend,
     title="SMA Trend Filter",
     color=isBull ? color.new(color.green, 40) : color.new(color.red, 40),
     linewidth=1
 )

// ── Bollinger Bands plots ───────────────────────────────────────
plot(
     bbBasis,
     title="BB Basis",
     color=color.new(color.blue, 50),
     linewidth=1
 )

plot(
     bbUpper,
     title="BB Upper Band",
     color=color.new(color.orange, 30),
     linewidth=1
 )

plot(
     bbLower,
     title="BB Lower Band",
     color=color.new(color.orange, 30),
     linewidth=1
 )

// ── Bollinger Bands fill ────────────────────────────────────────
bbUpperPlot = plot(
     bbUpper,
     display=display.none
 )

bbLowerPlot = plot(
     bbLower,
     display=display.none
 )

fill(
     bbUpperPlot,
     bbLowerPlot,
     color=color.new(color.blue, 93),
     title="BB Area"
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
