# DNSE VN301!, Keltner Break Out Strategy

- url: https://www.tradingview.com/script/8dUGzpds/
- type: strategy
- pine_id: PUB;8f978bc1bb9841cfa455421f809c63a7
- version: 1.0

## Description

"Keltner Channel Breakout with SMA Trend Filter" is a trend-following breakout strategy designed to capture strong directional price movements after volatility expansions. The strategy uses the Keltner Channel, constructed from an EMA(20) and ATR(10), to identify bullish breakouts when price closes above the upper channel and bearish breakouts when price closes below the lower channel.

To improve signal quality, the strategy incorporates an optional SMA(200) trend filter, allowing Long trades only when the SMA is rising and Short trades only when it is falling. By combining volatility-based breakout detection with long-term trend confirmation, the strategy seeks to reduce false signals during ranging markets while participating in sustained intraday trends. It also includes configurable stop loss, take profit, trading session filters, and automatic end-of-day position closure for disciplined risk management.

[b]Strategy settings and configuration:[/b]
Chart timeframe: recommended 1-minute chart
Position size: 3 contracts
Keltner EMA length: 20
ATR length: 10
ATR multiplier: 2.0
SMA length: 200
Stop loss: 10 points
Take profit: 20 points
SMA trend filter: On / Off
Take profit: On / Off
Time filter: On / Off
Trading session: 09:00 – 14:30
Trade direction: Long / Short / Both

[b]Default script settings:[/b]
The strategy calculates the Keltner Channel using EMA(20) and ATR(10). The upper band is calculated by adding ATR multiplied by 2.0 to EMA(20). The lower band is calculated by subtracting ATR multiplied by 2.0 from EMA(20).
When the closing price breaks above the upper Keltner band, buying pressure may be taking control. When the closing price breaks below the lower Keltner band, selling pressure may be taking control.
When the SMA(200) trend filter is enabled, the script only allows Long trades when SMA(200) is rising and only allows Short trades when SMA(200) is falling. When the SMA filter is disabled, the strategy can trade both directions based only on Keltner Channel breakout signals.

[b]Entry and exit rules:[/b]
Long entry:
Closing price > Upper Keltner Channel band
AND SMA(200) is rising, if the SMA filter is enabled
AND the signal appears during the trading session
AND trade direction allows Long entries
Long exit:
Stop loss: 10 points from entry price
Take profit: 20 points from entry price, if enabled
Opposite breakout signal appears
Reversal when a valid Short signal appears
Automatic position close at the end of the trading session
Short entry:
Closing price < Lower Keltner Channel band
AND SMA(200) is falling, if the SMA filter is enabled
AND the signal appears during the trading session
AND trade direction allows Short entries
Short exit:
Stop loss: 10 points from entry price
Take profit: 20 points from entry price, if enabled
Opposite breakout signal appears
Reversal when a valid Long signal appears
Automatic position close at the end of the trading session

[b]Risk disclaimer:[/b]
Futures trading involves a high level of risk and prices can move sharply. This script is provided for reference, research, and backtesting purposes only. Users should fully understand derivatives trading, their own risk tolerance, and the strategy logic before applying it to live trading.
All investment decisions are the responsibility of the user. phaisinh.online is not responsible for any losses arising from the use of this strategy in real trading. Past performance does not guarantee future results.
_____________________________________________________________________

"Keltner Channel Breakout với Bộ lọc Xu hướng SMA" là chiến lược giao dịch theo xu hướng (trend-following) được thiết kế để nắm bắt các nhịp biến động mạnh của giá sau khi thị trường mở rộng biên độ dao động. Chiến lược sử dụng Keltner Channel, được xây dựng từ EMA(20) và ATR(10), để xác định tín hiệu bứt phá tăng khi giá đóng cửa vượt lên trên dải trên và tín hiệu bứt phá giảm khi giá đóng cửa xuống dưới dải dưới của kênh.

Để nâng cao chất lượng tín hiệu, chiến lược tích hợp bộ lọc xu hướng SMA(200) (có thể bật/tắt), chỉ cho phép mở vị thế Long khi SMA đang hướng lên và vị thế Short khi SMA đang hướng xuống. Bằng cách kết hợp tín hiệu breakout dựa trên biến động với xác nhận xu hướng dài hạn, chiến lược hướng tới việc giảm các tín hiệu nhiễu trong giai đoạn thị trường đi ngang, đồng thời tận dụng hiệu quả các xu hướng mạnh trong giao dịch trong ngày. Ngoài ra, chiến lược còn hỗ trợ các tính năng quản trị rủi ro như Stop Loss, Take Profit, bộ lọc thời gian giao dịch và tự động đóng vị thế trước khi kết thúc phiên để tránh rủi ro qua đêm.

[b]Cài đặt & cấu hình chiến lược:[/b]
Biểu đồ: khuyến nghị khung 1 phút
Khối lượng giao dịch: 3 hợp đồng
Chu kỳ EMA Keltner: 20
Chu kỳ ATR: 10
Hệ số nhân ATR: 2.0
Chu kỳ SMA: 200
Cắt lỗ: 10 điểm
Chốt lời: 20 điểm
Bộ lọc xu hướng SMA: Bật / Tắt
Dùng chốt lời: Bật / Tắt
Bộ lọc giờ: Bật / Tắt
Khung giờ giao dịch: 09:00 – 14:30
Chiều giao dịch: Mua / Bán / Cả hai

[b]Cài đặt mặc định của script:[/b]
Chiến lược tính toán Keltner Channel dựa trên đường EMA(20) và độ biến động ATR(10). Dải trên được tính bằng EMA(20) cộng ATR nhân hệ số 2.0. Dải dưới được tính bằng EMA(20) trừ ATR nhân hệ số 2.0.
Khi giá đóng cửa vượt lên trên dải trên Keltner, lực mua có thể đang chiếm ưu thế. Khi giá đóng cửa phá xuống dưới dải dưới Keltner, lực bán có thể đang chiếm ưu thế.
Khi bật bộ lọc xu hướng SMA(200), script chỉ cho phép lệnh Mua khi SMA(200) dốc lên và chỉ cho phép lệnh Bán khi SMA(200) dốc xuống. Khi tắt bộ lọc SMA, chiến lược có thể giao dịch cả hai chiều chỉ dựa trên tín hiệu breakout của Keltner Channel.

[b]Điều kiện vào và thoát lệnh:[/b]
Vào lệnh Mua:
Giá đóng cửa > Dải trên Keltner Channel
VÀ SMA(200) dốc lên, nếu bật bộ lọc SMA
VÀ tín hiệu xuất hiện trong khung giờ giao dịch
VÀ chiều giao dịch cho phép lệnh Mua
Thoát lệnh Mua:
Cắt lỗ: 10 điểm từ giá vào lệnh
Chốt lời: 20 điểm từ giá vào lệnh, nếu bật
Có tín hiệu breakout ngược chiều
Đảo chiều khi xuất hiện tín hiệu Bán hợp lệ
Tự động đóng lệnh khi hết khung giờ giao dịch

Vào lệnh Bán:
Giá đóng cửa < Dải dưới Keltner Channel
VÀ SMA(200) dốc xuống, nếu bật bộ lọc SMA
VÀ tín hiệu xuất hiện trong khung giờ giao dịch
VÀ chiều giao dịch cho phép lệnh Bán
Thoát lệnh Bán:
Cắt lỗ: 10 điểm từ giá vào lệnh
Chốt lời: 20 điểm từ giá vào lệnh, nếu bật
Có tín hiệu breakout ngược chiều
Đảo chiều khi xuất hiện tín hiệu Mua hợp lệ
Tự động đóng lệnh khi hết khung giờ giao dịch

[b]Tuyên bố rủi ro:[/b]
Giao dịch hợp đồng tương lai có mức độ rủi ro cao và giá có thể biến động mạnh. Script này chỉ phục vụ mục đích tham khảo, nghiên cứu và kiểm thử. Người dùng cần hiểu rõ giao dịch phái sinh, khẩu vị rủi ro cá nhân và logic của chiến lược trước khi áp dụng vào giao dịch thực tế.
Mọi quyết định đầu tư thuộc trách nhiệm của người dùng. phaisinh.online không chịu trách nhiệm cho bất kỳ khoản lỗ nào phát sinh từ việc sử dụng chiến lược này trong giao dịch thực tế. Hiệu quả trong quá khứ không đảm bảo kết quả trong tương lai.

## Source Code

````pine
// ╔══════════════════════════════════════════════════════════════╗
// ║        PSOL Universal Bot Template — Pine Script v6          ║
// ║  Instrument: VN30! | Keltner Breakout                       ║
// ║  Version: PSOL 02 Keltner Breakout                          ║
// ║  Recommended timeframe: M1 | Slippage = 3                   ║
// ╚══════════════════════════════════════════════════════════════╝
//*The cost to open a position in futures trading is roughly VND 30,000,000 per contract.
//For VN Future Trading, the commission value is set at VND 10,000 per contract traded. Tax is not yet included.

//@version=6
strategy(
     title       = "PSOL 02 Keltner Breakout",
     shorttitle  = "PSOL 02",
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
//**The cost to open a position in future trading is rougly VND 30,000,000 per contract  
//*For VN Future Trading, the commision value is set at VND 10,000 per contract traded. Tax is not yet included 

// ════════════════════════════════════════════════════════════════
// SECTION 1: INPUTS
// ════════════════════════════════════════════════════════════════

// ── Keltner Channel settings ────────────────────────────────────
kcLen = input.int(
     20,
     title="EMA Length",
     minval=1,
     group="Keltner Channel"
 )

atrLen = input.int(
     10,
     title="ATR Length",
     minval=1,
     group="Keltner Channel"
 )

mult = input.float(
     2.0,
     title="Multiplier",
     minval=0.1,
     step=0.1,
     group="Keltner Channel"
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

// ── Keltner Channel ─────────────────────────────────────────────
// The middle line is an EMA of the closing price.
// The upper and lower bands are calculated using ATR and multiplier.
kcMiddle = ta.ema(close, kcLen)
kcATR    = ta.atr(atrLen)

kcUpper = kcMiddle + mult * kcATR
kcLower = kcMiddle - mult * kcATR


// ════════════════════════════════════════════════════════════════
// SECTION 3: STRATEGY RATIONALE
// ════════════════════════════════════════════════════════════════

// The Keltner Channel is used to detect volatility-based breakouts.
// Unlike a simple price range, the Keltner Channel adjusts its bands
// based on ATR, which reflects recent market volatility.
//
// When volatility expands and price closes above the upper Keltner band,
// it may indicate that buyers are pushing price beyond its normal range.
// This can be used as a potential bullish breakout signal.
//
// When price closes below the lower Keltner band,
// it may indicate that sellers are pushing price below its normal range.
// This can be used as a potential bearish breakout signal.
//
// However, volatility breakouts can still produce false signals,
// especially when the market quickly rejects the breakout
// or moves sideways after a short volatility spike.
//
// For that reason, this strategy combines the Keltner Channel
// with an SMA trend filter.
// The Keltner Channel identifies the breakout condition.
// The SMA filter checks whether the broader trend supports that breakout.
//
// If the SMA is rising, the strategy gives priority to Long signals.
// If the SMA is falling, the strategy gives priority to Short signals.
// This combination is designed to reduce counter-trend entries
// and improve the overall quality of breakout signals.


// ════════════════════════════════════════════════════════════════
// SECTION 4: SIGNAL LOGIC
// ════════════════════════════════════════════════════════════════

// Signals are confirmed at candle close.
// Orders are executed on the next candle open.
//
// Long signal:
// Price closes above the upper Keltner band.
//
// Short signal:
// Price closes below the lower Keltner band.
rawLong = close > kcUpper
rawShort = close < kcLower

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

// ── SMA trend filter plot ───────────────────────────────────────
plot(
     useTrendFilter ? smaTrend : na,
     title="SMA Trend Filter",
     color=isBull ? color.new(color.green, 40) : color.new(color.red, 40),
     linewidth=1
 )

// ── Keltner Channel plots ───────────────────────────────────────
plot(
     kcMiddle,
     title="Keltner Middle Line",
     color=color.new(color.orange, 20),
     linewidth=1
 )

plot(
     kcUpper,
     title="Keltner Upper Band",
     color=color.new(color.blue, 20),
     linewidth=1
 )

plot(
     kcLower,
     title="Keltner Lower Band",
     color=color.new(color.blue, 20),
     linewidth=1
 )

// ── Keltner Channel fill ────────────────────────────────────────
kcUpperPlot = plot(
     kcUpper,
     editable=false,
     display=display.none
 )

kcLowerPlot = plot(
     kcLower,
     editable=false,
     display=display.none
 )

fill(
     kcUpperPlot,
     kcLowerPlot,
     color=color.new(color.blue, 92),
     title="Keltner Channel Area"
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
plotshape(
     showSignalShapes and canLong,
     title="Long Signal",
     location=location.belowbar,
     color=color.new(color.green, 0),
     style=shape.triangleup,
     size=size.small
 )

plotshape(
     showSignalShapes and canShort,
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
