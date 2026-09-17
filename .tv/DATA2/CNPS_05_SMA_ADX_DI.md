<!-- tradingview-pine-id: PUB;f58278f3a8224452a7364896689a1fcd -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# CNPS 05 SMA ADX DI

Source: https://www.tradingview.com/script/ToaH6cKJ/

## Description

"SMA ADX DI Trend Following" is a trend-following strategy designed to identify and capture directional price movements by combining SMA slope analysis with ADX trend-strength confirmation and DI directional signals. The strategy uses SMA(89) to determine the primary trend direction, while ADX(14) confirms that the market has sufficient trend strength and DI identifies whether bullish or bearish pressure is dominant.

By requiring agreement between trend direction, trend strength, and directional momentum, the strategy seeks to filter out weak or unclear market conditions while participating in stronger intraday trends. An optional SMA(200) trend filter provides additional broader-trend confirmation. The strategy also includes configurable stop loss, take profit, trading session filters, signal confirmation settings, and automatic end-of-session position closure for disciplined risk management. 

Strategy settings and configuration:
Chart timeframe: recommended 15-minute chart
Position size: 3 contracts
Signal SMA length: 89
SMA slope lookback: 5
ADX length: 14
ADX threshold: 20
DI filter: On / Off
New signal only: On / Off
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
The strategy uses a signal SMA with a length of 89 to identify the main market direction. Instead of comparing the current SMA with only the previous candle, the bot uses a slope lookback of 5.
This means the bot compares the current SMA with the SMA value from 5 candles ago. If the current SMA is higher than the SMA from 5 candles ago, the SMA is considered rising. If the current SMA is lower than the SMA from 5 candles ago, the SMA is considered falling.
This method helps reduce noise on the 1-minute timeframe. The bot does not enter a trade just because the SMA moves slightly within one candle.
ADX(14) is used to confirm trend strength. When ADX is above 20, the market is considered to have enough trend strength for trading signals to be considered.
DI is used to confirm trend direction. When +DI is above -DI, buying pressure is dominant. When -DI is above +DI, selling pressure is dominant.
When the DI filter is enabled, the bot only allows Long trades when +DI > -DI. It only allows Short trades when -DI > +DI.
The “New signal only” option helps reduce repeated entries in the same signal state. When this option is enabled, the bot only enters when a new Long or Short state appears.
The SMA(200) trend filter is disabled by default. Users can enable this filter if they want stricter alignment with the larger trend.
When the SMA(200) trend filter is enabled, the script only allows Long trades when SMA(200) is rising and only allows Short trades when SMA(200) is falling.

Entry and exit rules:
Long entry:
Signal SMA is rising based on the 5-candle lookback
AND ADX(14) > 20
AND +DI > -DI, if the DI filter is enabled
AND SMA(200) is rising, if the SMA trend filter is enabled
AND a new Long state has just appeared, if new signal only mode is enabled
AND the signal appears during the trading session
AND trade direction allows Long entries
Long exit:
Stop loss: 10 points from entry price
Take profit: 20 points from entry price, if enabled
Signal SMA turns downward
Reversal when a valid Short signal appears
Automatic position close at the end of the trading session
Short entry:
Signal SMA is falling based on the 5-candle lookback
AND ADX(14) > 20
AND -DI > +DI, if the DI filter is enabled
AND SMA(200) is falling, if the SMA trend filter is enabled
AND a new Short state has just appeared, if new signal only mode is enabled
AND the signal appears during the trading session
AND trade direction allows Short entries

Short exit:
Stop loss: 10 points from entry price
Take profit: 20 points from entry price, if enabled
Signal SMA turns upward
Reversal when a valid Long signal appears
Automatic position close at the end of the trading session

Strategy logic:
CNPS 05 is suitable for market phases with clear trend direction. The signal SMA identifies the main direction. ADX filters for markets with enough trend strength. DI confirms whether buying or selling pressure is dominant.
This structure helps reduce noise in sideways conditions. The bot does not rely only on SMA slope. It also requires enough trend strength and directional confirmation from DI.
Time filter:
The default trading session is 09:00 – 14:30, designed to avoid two abnormal volatility periods.
ATO 08:45 – 09:00 is the opening auction period. Price can gap strongly and technical signals may be noisy.
ATC and negotiated trading 14:30 – 15:00 is the closing auction period. Price can move sharply or reverse quickly.
Users can adjust the start time and end time in the bot settings.

Risk disclaimer:
Futures trading involves a high level of risk and prices can move sharply. This script is provided for reference, research, and backtesting purposes only. Users should fully understand derivatives trading, their own risk tolerance, and the strategy logic before applying it to live trading.
All investment decisions are the responsibility of the user. phaisinh.online is not responsible for any losses arising from the use of this strategy in real trading. Past performance does not guarantee future results.
______________________________________________________________

"SMA ADX DI Trend Following" là một chiến lược giao dịch theo xu hướng, được thiết kế nhằm xác định và nắm bắt các chuyển động giá theo xu hướng bằng cách kết hợp phân tích độ dốc SMA với xác nhận sức mạnh xu hướng từ ADX và tín hiệu định hướng từ DI. Chiến lược sử dụng SMA(89) để xác định hướng xu hướng chính, trong khi ADX(14) xác nhận thị trường đang có đủ sức mạnh xu hướng và DI xác định bên mua hay bên bán đang chiếm ưu thế.

Bằng cách yêu cầu sự đồng thuận giữa hướng xu hướng, sức mạnh xu hướng và động lượng định hướng, chiến lược hướng tới việc lọc các điều kiện thị trường yếu hoặc không rõ xu hướng, đồng thời tham gia vào các xu hướng intraday mạnh hơn. Bộ lọc xu hướng SMA(200) tùy chọn cung cấp thêm xác nhận về xu hướng tổng thể. Chiến lược cũng bao gồm các tùy chọn Stop Loss, Take Profit, bộ lọc khung thời gian giao dịch, cài đặt xác nhận tín hiệu và cơ chế tự động đóng vị thế khi kết thúc phiên, nhằm đảm bảo quản trị rủi ro một cách chặt chẽ và có kỷ luật.

Cài đặt & cấu hình chiến lược:
Biểu đồ: khuyến nghị khung 15 phút
Khối lượng giao dịch: 3 hợp đồng
Chu kỳ SMA tín hiệu: 89
SMA slope lookback: 5
Chu kỳ ADX: 14
Ngưỡng ADX: 20
Bộ lọc DI: Bật / Tắt
Chỉ vào khi tín hiệu mới: Bật / Tắt
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
Chiến lược sử dụng SMA tín hiệu chu kỳ 89 để xác định hướng chính của thị trường. Thay vì so sánh SMA hiện tại với đúng một nến trước, bot sử dụng SMA slope lookback 5.
Điều này có nghĩa là bot so sánh SMA hiện tại với SMA của 5 nến trước. Nếu SMA hiện tại cao hơn SMA của 5 nến trước, SMA được xem là đang dốc lên. Nếu SMA hiện tại thấp hơn SMA của 5 nến trước, SMA được xem là đang dốc xuống.
Cách tính này giúp giảm nhiễu trên khung 1 phút. Bot không vào lệnh chỉ vì SMA nhích nhẹ trong một nến ngắn.
ADX(14) được dùng để xác nhận sức mạnh xu hướng. Khi ADX lớn hơn 20, thị trường được xem là có đủ lực xu hướng để xét tín hiệu giao dịch.
DI được dùng để xác nhận hướng xu hướng. Khi +DI lớn hơn -DI, lực tăng đang chiếm ưu thế. Khi -DI lớn hơn +DI, lực giảm đang chiếm ưu thế.
Khi bật bộ lọc DI, bot chỉ cho phép lệnh Mua khi +DI > -DI. Bot chỉ cho phép lệnh Bán khi -DI > +DI.
Tùy chọn “Chỉ vào khi tín hiệu mới” giúp hạn chế vào lại liên tục trong cùng một trạng thái. Khi bật tùy chọn này, bot chỉ vào lệnh khi trạng thái Long hoặc Short vừa mới xuất hiện.
Bộ lọc SMA(200) được để tắt mặc định. Người dùng có thể bật bộ lọc này nếu muốn giao dịch chặt hơn theo xu hướng lớn.
Khi bật bộ lọc SMA(200), script chỉ cho phép lệnh Mua khi SMA(200) dốc lên và chỉ cho phép lệnh Bán khi SMA(200) dốc xuống.

Điều kiện vào và thoát lệnh:
Vào lệnh Mua:
SMA tín hiệu dốc lên theo lookback 5
VÀ ADX(14) > 20
VÀ +DI > -DI, nếu bật bộ lọc DI
VÀ SMA(200) dốc lên, nếu bật bộ lọc xu hướng SMA
VÀ trạng thái Mua vừa mới xuất hiện, nếu bật chế độ chỉ vào tín hiệu mới
VÀ tín hiệu xuất hiện trong khung giờ giao dịch
VÀ chiều giao dịch cho phép lệnh Mua
Thoát lệnh Mua:
Cắt lỗ: 10 điểm từ giá vào lệnh
Chốt lời: 20 điểm từ giá vào lệnh, nếu bật
SMA tín hiệu đảo chiều xuống
Đảo chiều khi xuất hiện tín hiệu Bán hợp lệ
Tự động đóng lệnh khi hết khung giờ giao dịch

Vào lệnh Bán:
SMA tín hiệu dốc xuống theo lookback 5
VÀ ADX(14) > 20
VÀ -DI > +DI, nếu bật bộ lọc DI
VÀ SMA(200) dốc xuống, nếu bật bộ lọc xu hướng SMA
VÀ trạng thái Bán vừa mới xuất hiện, nếu bật chế độ chỉ vào tín hiệu mới
VÀ tín hiệu xuất hiện trong khung giờ giao dịch
VÀ chiều giao dịch cho phép lệnh Bán
Thoát lệnh Bán:
Cắt lỗ: 10 điểm từ giá vào lệnh
Chốt lời: 20 điểm từ giá vào lệnh, nếu bật
SMA tín hiệu đảo chiều lên
Đảo chiều khi xuất hiện tín hiệu Mua hợp lệ
Tự động đóng lệnh khi hết khung giờ giao dịch

Logic chiến lược:
CNPS 05 phù hợp với các giai đoạn thị trường có xu hướng rõ ràng. SMA tín hiệu giúp xác định hướng di chuyển chính. ADX giúp lọc những giai đoạn thị trường có lực. DI giúp xác nhận lực đang nghiêng về bên Mua hay bên Bán.
Cấu trúc này giúp bot hạn chế tín hiệu nhiễu trong vùng sideway. Bot không chỉ nhìn độ dốc SMA, mà còn yêu cầu thị trường có đủ sức mạnh xu hướng và có xác nhận hướng từ DI.
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
// ║  Instrument: VN30! | SMA ADX DI Trend Following              ║
// ║  Version: CNPS 05 SMA ADX DI                                 ║
// ║  Recommended timeframe: M15 | Slippage = 3                    ║
// ╚══════════════════════════════════════════════════════════════╝
//*The cost to open a position in futures trading is roughly VND 30,000,000 per contract.
//For VN Future Trading, the commission value is set at VND 10,000 per contract traded. Tax is not yet included.

//@version=6
strategy(
     title       = "CNPS 05 SMA ADX DI",
     shorttitle  = "CNPS 05",
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
smaSignalLen = input.int(
     89,
     title="Signal SMA Length",
     minval=1,
     group="Indicator Settings"
 )

smaSlopeLookback = input.int(
     5,
     title="SMA Slope Lookback",
     minval=1,
     group="Indicator Settings",
     tooltip="Number of candles used to calculate the SMA slope. Example: 5 means the current SMA is compared with the SMA from 5 candles ago."
 )

adxLen = input.int(
     14,
     title="ADX Length",
     minval=1,
     group="Indicator Settings"
 )

adxThreshold = input.float(
     20.0,
     title="ADX Threshold",
     minval=1,
     step=0.5,
     group="Indicator Settings",
     tooltip="ADX must be above this threshold for the market to be considered trending."
 )

useDIFilter = input.bool(
     true,
     title="Use DI Filter?",
     group="Indicator Settings",
     tooltip="When enabled, Long requires +DI > -DI and Short requires -DI > +DI."
 )

useNewSignalOnly = input.bool(
     true,
     title="Enter Only On New Signal?",
     group="Indicator Settings",
     tooltip="When enabled, the strategy only enters when the signal state has just appeared, reducing repeated entries in the same trend phase."
 )

// ── SMA trend filter ────────────────────────────────────────────
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

// ── Main signal SMA ─────────────────────────────────────────────
smaSignal = ta.sma(close, smaSignalLen)

// The signal SMA slope is calculated using a lookback period.
// This helps reduce one-candle noise on lower timeframes.
smaSlope = not na(smaSignal[smaSlopeLookback]) and smaSignal > smaSignal[smaSlopeLookback]
smaSlopeDn = not na(smaSignal[smaSlopeLookback]) and smaSignal < smaSignal[smaSlopeLookback]

// ── ADX / DI confirmation ───────────────────────────────────────
// ADX confirms trend strength.
// DI confirms trend direction.
[diPlus, diMinus, adxVal] = ta.dmi(adxLen, adxLen)

adxStrong = adxVal > adxThreshold

diBull = diPlus > diMinus
diBear = diMinus > diPlus


// ════════════════════════════════════════════════════════════════
// SECTION 3: STRATEGY RATIONALE
// ════════════════════════════════════════════════════════════════

// This strategy combines an SMA slope signal with ADX and DI confirmation.
// The signal SMA is used to identify the main direction of price movement.
// Instead of reacting to a one-candle change,
// the SMA slope is calculated over a selected lookback period.
//
// When the signal SMA is higher than it was several candles ago,
// it suggests that the market is developing upward pressure.
// When the signal SMA is lower than it was several candles ago,
// it suggests that the market is developing downward pressure.
//
// ADX is added to confirm trend strength.
// A market can move up or down without having enough trend strength,
// so ADX helps filter out weak or unclear conditions.
// The strategy only considers a trend valid when ADX is above the selected threshold.
//
// DI is used as an optional direction filter.
// If +DI is above -DI, bullish directional movement is stronger.
// If -DI is above +DI, bearish directional movement is stronger.
//
// For that reason, this strategy does not rely on SMA slope alone.
// The SMA slope identifies direction.
// ADX confirms that the market is trending.
// DI confirms whether bullish or bearish pressure is dominant.
//
// An additional SMA trend filter is also available.
// However, it is disabled by default because the main logic
// already uses SMA slope, ADX, and DI to confirm the signal.
// When enabled, the extra SMA filter can be used as a broader trend confirmation layer.


// ════════════════════════════════════════════════════════════════
// SECTION 4: SIGNAL LOGIC
// ════════════════════════════════════════════════════════════════

// Long state:
// Signal SMA slopes upward, ADX is strong, and DI confirms bullish direction if enabled.
longState =
     smaSlope and
     adxStrong and
     (useDIFilter ? diBull : true)

// Short state:
// Signal SMA slopes downward, ADX is strong, and DI confirms bearish direction if enabled.
shortState =
     smaSlopeDn and
     adxStrong and
     (useDIFilter ? diBear : true)

// If "Enter Only On New Signal" is enabled,
// the strategy only enters when the state changes from false to true.
rawLong =
     useNewSignalOnly
     ? longState and not longState[1]
     : longState

rawShort =
     useNewSignalOnly
     ? shortState and not shortState[1]
     : shortState

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

// ── Close positions when the signal SMA slope reverses ──────────
// This trigger fires once on the slope reversal candle.
smaFlipDn = smaSlopeDn and smaSlope[1]
smaFlipUp = smaSlope and smaSlopeDn[1]

if smaFlipDn and strategy.position_size > 0
    strategy.close(
         "Long",
         comment="SMA Slope Reversal"
     )

if smaFlipUp and strategy.position_size < 0
    strategy.close(
         "Short",
         comment="SMA Slope Reversal"
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

// ── Main signal SMA plot ────────────────────────────────────────
plot(
     smaSignal,
     title="Signal SMA",
     color=smaSlope ? color.new(color.blue, 20) : color.new(color.orange, 20),
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
