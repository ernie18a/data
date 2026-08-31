<!-- tradingview-pine-id: PUB;c1647e8b203b4788bee90b9d4c200865 -->
<!-- tradingviewscripts-format: 1 -->
# CNPS 02 Bollinger Bands

Source: https://www.tradingview.com/script/uOaILfJT/

## Description

"Bollinger Bands Breakout with SMA Trend Filter" is a volatility breakout strategy designed to capture strong directional price movements when price breaks outside its recent trading range. The strategy uses Bollinger Bands, constructed from an SMA(20) and two standard deviations, to identify bullish breakouts when price closes above the upper band and bearish breakouts when price closes below the lower band.

To improve signal quality, the strategy incorporates an optional SMA(200) trend filter, allowing Long trades only when the SMA is rising and Short trades only when it is falling. By combining volatility-based breakout signals with long-term trend confirmation, the strategy seeks to reduce false breakouts during ranging markets while participating in sustained intraday trends. It also includes configurable stop loss, take profit, trading session filters, automatic end-of-day position closure, and trend reversal exits for disciplined risk management.

Strategy settings and configuration:
Chart timeframe: recommended 5-minute chart
Position size: 3 contracts
Bollinger Bands length: 20
Bollinger Bands multiplier: 2.0
SMA length: 200
Stop loss: 10 points
Take profit: disabled
SMA trend filter: On / Off
Take profit: On / Off
Time filter: On / Off
Trading session: 09:00 – 14:30
Trade direction: Long / Short / Both

Default script settings:
The strategy calculates Bollinger Bands using the SMA(20) of the closing price. The upper and lower bands are created by adding or subtracting two standard deviations around the middle line.
When volatility increases, the Bollinger Bands expand. When the market is quiet or moving sideways, the bands contract.
When the closing price breaks above the upper Bollinger Band, buying pressure may be taking control. When the closing price breaks below the lower Bollinger Band, selling pressure may be taking control.
When the SMA(200) trend filter is enabled, the script only allows Long trades when SMA(200) is rising and only allows Short trades when SMA(200) is falling. When the SMA filter is disabled, the strategy can trade both directions based only on Bollinger Bands breakout signals.
Users can add the built-in Bollinger Bands indicator on TradingView with Length 20 and Multiplier 2.0 to visually monitor the signal on the price chart.

Entry and exit rules:
Long entry:
Closing price > upper Bollinger Band
AND SMA(200) is rising, if the SMA filter is enabled
AND the signal appears during the trading session
AND trade direction allows Long entries
Long exit:
Stop loss: 10 points from entry price
Take profit: disabled by default
Closing price touches or breaks below the lower Bollinger Band
SMA(200) turns downward, if the SMA filter is enabled
Reversal when a valid Short signal appears
Automatic position close at the end of the trading session

Short entry:
Closing price < lower Bollinger Band
AND SMA(200) is falling, if the SMA filter is enabled
AND the signal appears during the trading session
AND trade direction allows Short entries
Short exit:
Stop loss: 10 points from entry price
Take profit: disabled by default
Closing price touches or breaks above the upper Bollinger Band
SMA(200) turns upward, if the SMA filter is enabled
Reversal when a valid Long signal appears
Automatic position close at the end of the trading session

Risk disclaimer:
Futures trading involves a high level of risk and prices can move sharply. This script is provided for reference, research, and backtesting purposes only. Users should fully understand derivatives trading, their own risk tolerance, and the strategy logic before applying it to live trading.
All investment decisions are the responsibility of the user. phaisinh.online is not responsible for any losses arising from the use of this strategy in real trading. Past performance does not guarantee future results.
____________________________________________________________________

"Bollinger Bands Breakout với Bộ lọc Xu hướng SMA" là một chiến lược giao dịch theo xu hướng dựa trên sự bứt phá của biến động giá, được thiết kế nhằm nắm bắt các chuyển động mạnh theo một hướng khi giá vượt ra khỏi vùng dao động gần nhất. Chiến lược sử dụng Bollinger Bands, được xây dựng từ SMA(20) và 2 độ lệch chuẩn, để xác định tín hiệu mua khi giá đóng cửa vượt lên trên dải trên và tín hiệu bán khi giá đóng cửa xuống dưới dải dưới.

Để nâng cao chất lượng tín hiệu, chiến lược tích hợp bộ lọc xu hướng SMA(200) (có thể bật hoặc tắt), chỉ cho phép mở vị thế Long khi SMA đang dốc lên và vị thế Short khi SMA đang dốc xuống. Bằng cách kết hợp tín hiệu bứt phá theo biến động của Bollinger Bands với xác nhận xu hướng dài hạn, chiến lược hướng tới việc giảm thiểu các tín hiệu phá vỡ giả trong giai đoạn thị trường đi ngang, đồng thời tận dụng các xu hướng intraday kéo dài. Ngoài ra, chiến lược còn bao gồm các tùy chọn Stop Loss, Take Profit, bộ lọc khung thời gian giao dịch, cơ chế tự động đóng toàn bộ vị thế khi kết thúc phiên, cùng với điều kiện thoát lệnh khi xu hướng SMA đảo chiều, nhằm đảm bảo quản trị rủi ro một cách chặt chẽ và có kỷ luật.

Cài đặt & cấu hình chiến lược:
Biểu đồ: khuyến nghị khung 5 phút
Khối lượng giao dịch: 3 hợp đồng
Chu kỳ Bollinger Bands: 20
Hệ số nhân Bollinger Bands: 2.0
Chu kỳ SMA: 200
Cắt lỗ: 10 điểm
Chốt lời: tắt
Bộ lọc xu hướng SMA: Bật / Tắt
Dùng chốt lời: Bật / Tắt
Bộ lọc giờ: Bật / Tắt
Khung giờ giao dịch: 09:00 – 14:30
Chiều giao dịch: Mua / Bán / Cả hai

Cài đặt mặc định của script:
Chiến lược tính toán Bollinger Bands dựa trên đường SMA(20) của giá đóng cửa. Dải trên và dải dưới được tạo bằng cách cộng hoặc trừ hai độ lệch chuẩn quanh đường giữa.
Khi biến động tăng mạnh, hai dải Bollinger Bands sẽ mở rộng. Khi thị trường đi ngang hoặc biến động thấp, hai dải sẽ co hẹp lại.
Khi giá đóng cửa vượt lên trên dải trên Bollinger Bands, lực mua có thể đang chiếm ưu thế. Khi giá đóng cửa phá xuống dưới dải dưới Bollinger Bands, lực bán có thể đang chiếm ưu thế.
Khi bật bộ lọc xu hướng SMA(200), script chỉ cho phép lệnh Mua khi SMA(200) dốc lên và chỉ cho phép lệnh Bán khi SMA(200) dốc xuống. Khi tắt bộ lọc SMA, chiến lược có thể giao dịch cả hai chiều chỉ dựa trên tín hiệu breakout của Bollinger Bands.
Người dùng có thể thêm chỉ báo Bollinger Bands có sẵn trên TradingView với tham số Length 20 và Multiplier 2.0 để quan sát tín hiệu trực quan trên biểu đồ giá.

Điều kiện vào và thoát lệnh:
Vào lệnh Mua:
Giá đóng cửa > dải trên Bollinger Bands
VÀ SMA(200) dốc lên, nếu bật bộ lọc SMA
VÀ tín hiệu xuất hiện trong khung giờ giao dịch
VÀ chiều giao dịch cho phép lệnh Mua
Thoát lệnh Mua:
Cắt lỗ: 10 điểm từ giá vào lệnh
Chốt lời: không dùng theo mặc định
Giá đóng cửa chạm hoặc phá xuống dải dưới Bollinger Bands
SMA(200) đảo chiều xuống, nếu bật bộ lọc SMA
Đảo chiều khi xuất hiện tín hiệu Bán hợp lệ
Tự động đóng lệnh khi hết khung giờ giao dịch

Vào lệnh Bán:
Giá đóng cửa < dải dưới Bollinger Bands
VÀ SMA(200) dốc xuống, nếu bật bộ lọc SMA
VÀ tín hiệu xuất hiện trong khung giờ giao dịch
VÀ chiều giao dịch cho phép lệnh Bán
Thoát lệnh Bán:
Cắt lỗ: 10 điểm từ giá vào lệnh
Chốt lời: không dùng theo mặc định
Giá đóng cửa chạm hoặc phá lên dải trên Bollinger Bands
SMA(200) đảo chiều lên, nếu bật bộ lọc SMA
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
// ║  Instrument: VN30! | Bollinger Bands Breakout                ║
// ║  Version: CNPS 02 Bollinger Bands                            ║
// ║  Recommended timeframe: M5 | Slippage = 3                    ║
// ╚══════════════════════════════════════════════════════════════╝
//*The cost to open a position in futures trading is roughly VND 30,000,000 per contract.
//For VN Future Trading, the commission value is set at VND 10,000 per contract traded. Tax is not yet included.

//@version=6
strategy(
     title       = "CNPS 02 Bollinger Bands",
     shorttitle  = "CNPS 02",
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
bbLen = input.int(
     20,
     title="Bollinger Bands Length",
     minval=1,
     group="Indicator Settings"
 )

bbMult = input.float(
     2.0,
     title="Multiplier",
     minval=0.1,
     step=0.1,
     group="Indicator Settings"
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
     false,
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
[bbMiddle, bbUpper, bbLower] = ta.bb(
     close,
     bbLen,
     bbMult
 )


// ════════════════════════════════════════════════════════════════
// SECTION 3: STRATEGY RATIONALE
// ════════════════════════════════════════════════════════════════

// Bollinger Bands are used to identify volatility-based price expansion.
// The middle line represents the moving average,
// while the upper and lower bands expand or contract based on market volatility.
//
// When price closes above the upper Bollinger Band,
// it may indicate that buying pressure is strong enough
// to push price outside its recent volatility range.
//
// When price closes below the lower Bollinger Band,
// it may indicate that selling pressure is strong enough
// to push price below its recent volatility range.
//
// However, Bollinger Band breakout signals can be noisy
// when the market is moving sideways or when volatility expands briefly.
// Price may break outside the band and then quickly return inside the range.
//
// For that reason, this strategy combines Bollinger Bands
// with an SMA trend filter.
// Bollinger Bands identify the breakout condition.
// The SMA filter checks whether the broader trend supports that breakout.
//
// If the SMA is rising, the strategy gives priority to Long signals.
// If the SMA is falling, the strategy gives priority to Short signals.
// This combination is designed to reduce counter-trend entries
// and improve the overall quality of volatility breakout signals.


// ════════════════════════════════════════════════════════════════
// SECTION 4: SIGNAL LOGIC
// ════════════════════════════════════════════════════════════════

// Signals are confirmed at candle close.
// Orders are executed on the next candle open.
//
// Long signal:
// Price closes above the upper Bollinger Band.
//
// Short signal:
// Price closes below the lower Bollinger Band.
rawLong = close > bbUpper
rawShort = close < bbLower

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

// ── Detect SMA trend reversals ──────────────────────────────────
smaFlipBear = useTrendFilter and isBear and isBull[1]
smaFlipBull = useTrendFilter and isBull and isBear[1]

// ── Close Long position when SMA trend turns bearish ────────────
if smaFlipBear and strategy.position_size > 0
    strategy.close(
         "Long",
         comment="SMA Reversal"
     )

// ── Close Short position when SMA trend turns bullish ───────────
if smaFlipBull and strategy.position_size < 0
    strategy.close(
         "Short",
         comment="SMA Reversal"
     )

// ── Close all positions after the trading session ends ──────────
if sessionJustEnded and strategy.position_size != 0
    strategy.close_all(comment="Session End")

// ── Natural exit when price reaches the opposite Bollinger Band ─
if strategy.position_size > 0 and close < bbLower
    strategy.close(
         "Long",
         comment="Lower BB Break"
     )

if strategy.position_size < 0 and close > bbUpper
    strategy.close(
         "Short",
         comment="Upper BB Break"
     )

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

// ── Bollinger Bands plots ───────────────────────────────────────
plot(
     bbUpper,
     title="BB Upper Band",
     color=color.new(color.blue, 30),
     linewidth=1
 )

plot(
     bbMiddle,
     title="BB Middle Line",
     color=color.new(color.blue, 60),
     linewidth=1
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
     editable=false,
     display=display.none
 )

bbLowerPlot = plot(
     bbLower,
     editable=false,
     display=display.none
 )

fill(
     bbUpperPlot,
     bbLowerPlot,
     color=color.new(color.blue, 92),
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
