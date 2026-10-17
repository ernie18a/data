# DNSE VN301!, BB - RSI Break Out Strategy

- url: https://www.tradingview.com/script/8JPlyqNo/
- type: strategy
- pine_id: PUB;00f9cd7335904e40912e5947d364643f
- version: 1.0

## Description

"Bollinger Bands RSI Trend Following" is a volatility-based trend-following strategy designed to capture strong directional price movements by combining Bollinger Band breakouts with RSI momentum confirmation. The strategy uses Bollinger Bands with a default SMA(20) basis and 2.0 standard deviations to identify bullish breakouts above the upper band and bearish breakouts below the lower band, while RSI(14) confirms momentum direction relative to its neutral level of 50.

To improve signal quality, the strategy incorporates an optional SMA(200) trend filter, allowing Long trades only when the SMA is rising and Short trades only when it is falling. By combining volatility breakouts, momentum confirmation, and broader trend direction, the strategy seeks to filter out weaker signals and reduce counter-trend entries. It also includes configurable stop loss, take profit, trading session, trade direction, and automatic end-of-session position closure for disciplined risk management.

[b]Strategy settings and configuration:[/b]
Chart timeframe: recommended 5-minute chart
Position size: 3 contracts
Bollinger Bands length: 20
Bollinger Bands multiplier: 2.0
RSI length: 14
RSI neutral level: 50
SMA length: 200
Stop loss: 10 points
Take profit: 20 points
SMA trend filter: On / Off
Take profit: On / Off
Time filter: On / Off
Trading session: 09:00 – 14:30
Trade direction: Long / Short / Both

[b]Default script settings:[/b]
The strategy calculates Bollinger Bands using the SMA(20) of the closing price. The upper and lower bands are created by adding or subtracting two standard deviations around the middle line.
When the closing price breaks above the upper Bollinger Band, the market may be breaking out to the upside. When the closing price breaks below the lower Bollinger Band, selling pressure may be taking control.
RSI(14) is used to confirm the momentum behind the breakout signal. When RSI is above 50, bullish momentum may be taking control. When RSI is below 50, bearish momentum may be taking control.
When the SMA(200) trend filter is enabled, the script only allows Long trades when SMA(200) is rising and only allows Short trades when SMA(200) is falling. When the SMA filter is disabled, the strategy can trade both directions based only on Bollinger Bands breakout signals combined with RSI confirmation.
This design is intentional. Bollinger Bands confirm that price has moved outside its normal volatility range. RSI confirms momentum in the same direction. SMA(200) helps filter the larger trend and reduce counter-trend signals.
Users can add the built-in Bollinger Bands indicator with Length 20 and Multiplier 2.0, along with RSI length 14, on TradingView to visually monitor the signal.

[b]Entry and exit rules:
[/b]Long entry:
Closing price > upper Bollinger Band
AND RSI(14) > 50
AND SMA(200) is rising, if the SMA filter is enabled
AND the signal appears during the trading session
AND trade direction allows Long entries
Long exit:
Stop loss: 10 points from entry price
Take profit: 20 points from entry price, if enabled
Opposite breakout signal appears with RSI reversal
Reversal when a valid Short signal appears
Automatic position close at the end of the trading session

Short entry:
Closing price < lower Bollinger Band
AND RSI(14) < 50
AND SMA(200) is falling, if the SMA filter is enabled
AND the signal appears during the trading session
AND trade direction allows Short entries
Short exit:
Stop loss: 10 points from entry price
Take profit: 20 points from entry price, if enabled
Opposite breakout signal appears with RSI reversal
Reversal when a valid Long signal appears
Automatic position close at the end of the trading session

[b]Risk disclaimer:[/b]
Futures trading involves a high level of risk and prices can move sharply. This script is provided for reference, research, and backtesting purposes only. Users should fully understand derivatives trading, their own risk tolerance, and the strategy logic before applying it to live trading.
All investment decisions are the responsibility of the user. phaisinh.online is not responsible for any losses arising from the use of this strategy in real trading. Past performance does not guarantee future results.
____________________________________________________________

"Bollinger Bands RSI Trend Following" là một chiến lược giao dịch theo xu hướng dựa trên biến động, được thiết kế nhằm nắm bắt các chuyển động giá mạnh theo một hướng bằng cách kết hợp tín hiệu bứt phá từ Bollinger Bands với xác nhận động lượng từ RSI. Chiến lược sử dụng Bollinger Bands với đường cơ sở mặc định là SMA(20) và 2,0 độ lệch chuẩn để xác định tín hiệu bứt phá tăng khi giá đóng cửa vượt lên trên dải trên và tín hiệu bứt phá giảm khi giá đóng cửa xuống dưới dải dưới. Trong khi đó, RSI(14) xác nhận hướng động lượng dựa trên mức trung tính 50.

Để nâng cao chất lượng tín hiệu, chiến lược tích hợp bộ lọc xu hướng SMA(200) tùy chọn, chỉ cho phép giao dịch Long khi SMA đang dốc lên và giao dịch Short khi SMA đang dốc xuống. Bằng cách kết hợp tín hiệu bứt phá theo biến động, xác nhận động lượng và hướng xu hướng tổng thể, chiến lược hướng tới việc lọc các tín hiệu yếu và giảm thiểu các lệnh giao dịch ngược xu hướng. Chiến lược cũng bao gồm các tùy chọn Stop Loss, Take Profit, khung thời gian giao dịch, hướng giao dịch và cơ chế tự động đóng toàn bộ vị thế khi kết thúc phiên, nhằm đảm bảo quản trị rủi ro một cách chặt chẽ và có kỷ luật.

[b]Cài đặt & cấu hình chiến lược:[/b]
Biểu đồ: khuyến nghị khung 5 phút
Khối lượng giao dịch: 3 hợp đồng
Chu kỳ Bollinger Bands: 20
Hệ số nhân Bollinger Bands: 2.0
Chu kỳ RSI: 14
Ngưỡng trung tính RSI: 50
Chu kỳ SMA: 200
Cắt lỗ: 10 điểm
Chốt lời: 20 điểm
Bộ lọc xu hướng SMA: Bật / Tắt
Dùng chốt lời: Bật / Tắt
Bộ lọc giờ: Bật / Tắt
Khung giờ giao dịch: 09:00 – 14:30
Chiều giao dịch: Mua / Bán / Cả hai

[b]Cài đặt mặc định của script:[/b]
Chiến lược tính toán Bollinger Bands dựa trên đường SMA(20) của giá đóng cửa. Dải trên và dải dưới được tạo bằng cách cộng hoặc trừ hai độ lệch chuẩn quanh đường giữa.
Khi giá đóng cửa vượt lên trên dải trên Bollinger Bands, thị trường có thể đang bứt phá theo chiều tăng. Khi giá đóng cửa xuyên xuống dưới dải dưới Bollinger Bands, áp lực bán có thể đang chiếm ưu thế.
RSI(14) được dùng để xác nhận động lượng của tín hiệu breakout. Khi RSI nằm trên 50, động lượng tăng có thể đang chiếm ưu thế. Khi RSI nằm dưới 50, động lượng giảm có thể đang chiếm ưu thế.
Khi bật bộ lọc xu hướng SMA(200), script chỉ cho phép lệnh Mua khi SMA(200) dốc lên và chỉ cho phép lệnh Bán khi SMA(200) dốc xuống. Khi tắt bộ lọc SMA, chiến lược có thể giao dịch cả hai chiều chỉ dựa trên tín hiệu Bollinger Bands kết hợp RSI.
Thiết kế này có chủ đích. Bollinger Bands xác nhận giá đã thoát khỏi vùng biến động thông thường. RSI xác nhận động lượng cùng chiều. SMA(200) giúp lọc xu hướng lớn để hạn chế các tín hiệu ngược chiều.
Người dùng có thể thêm chỉ báo Bollinger Bands với Length 20, Multiplier 2.0 và RSI chu kỳ 14 trên TradingView để quan sát tín hiệu trực quan.

[b]Điều kiện vào và thoát lệnh:[/b]
Vào lệnh Mua:
Giá đóng cửa > dải trên Bollinger Bands
VÀ RSI(14) > 50
VÀ SMA(200) dốc lên, nếu bật bộ lọc SMA
VÀ tín hiệu xuất hiện trong khung giờ giao dịch
VÀ chiều giao dịch cho phép lệnh Mua
Thoát lệnh Mua:
Cắt lỗ: 10 điểm từ giá vào lệnh
Chốt lời: 20 điểm từ giá vào lệnh, nếu bật
Có tín hiệu breakout ngược chiều kết hợp RSI đảo chiều
Đảo chiều khi xuất hiện tín hiệu Bán hợp lệ
Tự động đóng lệnh khi hết khung giờ giao dịch

Vào lệnh Bán:
Giá đóng cửa < dải dưới Bollinger Bands
VÀ RSI(14) < 50
VÀ SMA(200) dốc xuống, nếu bật bộ lọc SMA
VÀ tín hiệu xuất hiện trong khung giờ giao dịch
VÀ chiều giao dịch cho phép lệnh Bán
Thoát lệnh Bán:
Cắt lỗ: 10 điểm từ giá vào lệnh
Chốt lời: 20 điểm từ giá vào lệnh, nếu bật
Có tín hiệu breakout ngược chiều kết hợp RSI đảo chiều
Đảo chiều khi xuất hiện tín hiệu Mua hợp lệ
Tự động đóng lệnh khi hết khung giờ giao dịch

[b]Tuyên bố rủi ro:[/b]
Giao dịch hợp đồng tương lai có mức độ rủi ro cao và giá có thể biến động mạnh. Script này chỉ phục vụ mục đích tham khảo, nghiên cứu và kiểm thử. Người dùng cần hiểu rõ giao dịch phái sinh, khẩu vị rủi ro cá nhân và logic của chiến lược trước khi áp dụng vào giao dịch thực tế.
Mọi quyết định đầu tư thuộc trách nhiệm của người dùng. phaisinh.online không chịu trách nhiệm cho bất kỳ khoản lỗ nào phát sinh từ việc sử dụng chiến lược này trong giao dịch thực tế. Hiệu quả trong quá khứ không đảm bảo kết quả trong tương lai.

## Source Code

````pine
// ╔══════════════════════════════════════════════════════════════╗
// ║        CNPS Universal Bot Template — Pine Script v6          ║
// ║  Instrument: VN30! | BB RSI Trend Following                  ║
// ║  Version: CNPS 06 BB RSI                                     ║
// ║  Recommended timeframe: M5 | Slippage = 3                    ║
// ╚══════════════════════════════════════════════════════════════╝
//*The cost to open a position in futures trading is roughly VND 30,000,000 per contract.
//For VN Future Trading, the commission value is set at VND 10,000 per contract traded. Tax is not yet included.

//@version=6
strategy(
     title       = "CNPS 06 BB RSI",
     shorttitle  = "CNPS 06",
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

// ── RSI settings ────────────────────────────────────────────────
rsiLen = input.int(
     14,
     title="RSI Length",
     minval=1,
     group="RSI"
 )

rsiNeutral = input.int(
     50,
     title="RSI Neutral Level",
     minval=1,
     maxval=99,
     group="RSI"
 )

// ── SMA trend filter ────────────────────────────────────────────
useTrendFilter = input.bool(
     true,
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

// ── Bollinger Bands ─────────────────────────────────────────────
bbBasis = ta.sma(close, bbLen)
bbDev   = bbMult * ta.stdev(close, bbLen)

bbUpper = bbBasis + bbDev
bbLower = bbBasis - bbDev

// ── RSI ─────────────────────────────────────────────────────────
rsiVal = ta.rsi(close, rsiLen)

rsiBullish = rsiVal > rsiNeutral
rsiBearish = rsiVal < rsiNeutral


// ════════════════════════════════════════════════════════════════
// SECTION 3: STRATEGY RATIONALE
// ════════════════════════════════════════════════════════════════

// Bollinger Bands are used to identify volatility-based price expansion.
// The basis line represents the moving average,
// while the upper and lower bands expand or contract based on market volatility.
//
// In this strategy, the signal is based on price closing beyond
// the upper Bollinger Band or the lower Bollinger Band.
//
// A close above the upper band may indicate that buying pressure
// is strong enough to push price beyond its recent volatility range.
// A close below the lower band may indicate that selling pressure
// is strong enough to push price below its recent volatility range.
//
// RSI is added as a momentum confirmation layer.
// Long signals require RSI to be above the neutral level.
// Short signals require RSI to be below the neutral level.
//
// However, Bollinger Band breakout signals can become noisy
// when the market is sideways or when price briefly expands
// outside the band without broader trend support.
//
// For that reason, this strategy combines Bollinger Bands,
// RSI confirmation, and an SMA trend filter.
// Bollinger Bands identify the breakout.
// RSI confirms momentum direction.
// The SMA filter checks whether the broader trend supports the signal.
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
// Price closes above the upper Bollinger Band
// and RSI is above the neutral level.
//
// Short signal:
// Price closes below the lower Bollinger Band
// and RSI is below the neutral level.
rawLong = close > bbUpper and rsiBullish
rawShort = close < bbLower and rsiBearish

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

// ── Bollinger Bands plots ───────────────────────────────────────
plot(
     bbUpper,
     title="BB Upper Band",
     color=color.new(color.blue, 30),
     linewidth=1
 )

plot(
     bbBasis,
     title="BB Basis",
     color=color.new(color.blue, 60),
     linewidth=1,
     style=plot.style_circles
 )

plot(
     bbLower,
     title="BB Lower Band",
     color=color.new(color.blue, 30),
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
     color=color.new(color.blue, 92),
     title="BB Background"
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
