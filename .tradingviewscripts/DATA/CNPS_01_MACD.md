<!-- tradingview-pine-id: PUB;96c99820fefa4f328d2d78645aaee124 -->
<!-- tradingviewscripts-format: 1 -->
# CNPS 01 MACD

Source: https://www.tradingview.com/script/Jn7Vfu33/

## Description

"MACD Trend Following with SMA Trend Filter" is a momentum-based trend-following strategy designed to capture directional market moves as momentum begins to strengthen. The strategy uses the MACD indicator, with its standard parameters of Fast EMA(12), Slow EMA(26), and Signal EMA(9), to identify bullish signals when the MACD line crosses above the signal line and bearish signals when it crosses below.

To improve signal quality, the strategy incorporates an optional SMA(200) trend filter, allowing Long trades only when the SMA is rising and Short trades only when it is falling. By combining MACD momentum crossovers with long-term trend confirmation, the strategy seeks to reduce false signals during sideways market conditions while participating in sustained intraday trends. It also includes configurable stop loss, take profit, trading session filters, and automatic end-of-day position closure for disciplined risk management.

Strategy settings and configuration:
Chart timeframe: recommended 5-minute chart
Position size: 3 contracts
MACD fast length: 12
MACD slow length: 26
MACD signal length: 9
SMA length: 200
Stop loss: 10 points
Take profit: 30 points
SMA trend filter: On / Off
Take profit: On / Off
Time filter: On / Off
Trading session: 09:00 – 14:30
Trade direction: Long / Short / Both

Default script settings:
The strategy uses MACD(12,26,9). The MACD line is calculated from the difference between EMA(12) and EMA(26). The Signal line is the EMA(9) of the MACD line.
When MACD crosses above the Signal line, bullish momentum may be taking control. When MACD crosses below the Signal line, bearish momentum may be taking control.
When the SMA(200) trend filter is enabled, the script only allows Long trades when SMA(200) is rising and only allows Short trades when SMA(200) is falling. When the SMA filter is disabled, the strategy can trade both directions based only on MACD crossover signals.
Users can add the built-in MACD indicator on TradingView with settings 12, 26, 9 and source close to visually monitor the signal below the price chart.

Entry and exit rules:
Long entry:
MACD(12,26,9) crosses above the Signal line
AND SMA(200) is rising, if the SMA filter is enabled
AND the signal appears during the trading session
AND trade direction allows Long entries
Long exit:
Stop loss: 10 points from entry price
Take profit: 30 points from entry price, if enabled
MACD crosses below the Signal line
Reversal when a valid Short signal appears
Automatic position close at the end of the trading session

Short entry:
MACD(12,26,9) crosses below the Signal line
AND SMA(200) is falling, if the SMA filter is enabled
AND the signal appears during the trading session
AND trade direction allows Short entries
Short exit:
Stop loss: 10 points from entry price
Take profit: 30 points from entry price, if enabled
MACD crosses above the Signal line
Reversal when a valid Long signal appears
Automatic position close at the end of the trading session

Risk disclaimer:
Futures trading involves a high level of risk and prices can move sharply. This script is provided for reference, research, and backtesting purposes only. Users should fully understand derivatives trading, their own risk tolerance, and the strategy logic before applying it to live trading.
All investment decisions are the responsibility of the user. phaisinh.online is not responsible for any losses arising from the use of this strategy in real trading. Past performance does not guarantee future results.

___________________________________________________________________

"MACD Trend Following với Bộ lọc Xu hướng SMA" là một chiến lược giao dịch theo xu hướng dựa trên động lượng, được thiết kế nhằm nắm bắt các biến động giá theo một hướng khi động lượng thị trường bắt đầu gia tăng. Chiến lược sử dụng chỉ báo MACD với các tham số tiêu chuẩn gồm Fast EMA(12), Slow EMA(26) và Signal EMA(9) để xác định tín hiệu mua khi đường MACD cắt lên trên đường tín hiệu, và tín hiệu bán khi đường MACD cắt xuống dưới đường tín hiệu.

Để nâng cao chất lượng tín hiệu, chiến lược tích hợp bộ lọc xu hướng SMA(200) (có thể bật hoặc tắt), chỉ cho phép mở vị thế Long khi SMA đang dốc lên và vị thế Short khi SMA đang dốc xuống. Bằng cách kết hợp tín hiệu giao cắt động lượng của MACD với xác nhận xu hướng dài hạn, chiến lược hướng tới việc giảm thiểu các tín hiệu nhiễu trong giai đoạn thị trường đi ngang, đồng thời tận dụng các xu hướng intraday kéo dài. Ngoài ra, chiến lược còn bao gồm các tùy chọn Stop Loss, Take Profit, bộ lọc khung thời gian giao dịch, và cơ chế tự động đóng toàn bộ vị thế khi kết thúc phiên, nhằm đảm bảo quản trị rủi ro một cách chặt chẽ và có kỷ luật.

Cài đặt & cấu hình chiến lược:
Biểu đồ: khuyến nghị khung 5 phút
Khối lượng giao dịch: 3 hợp đồng
Chu kỳ nhanh MACD: 12
Chu kỳ chậm MACD: 26
Chu kỳ tín hiệu MACD: 9
Chu kỳ SMA: 200
Cắt lỗ: 10 điểm
Chốt lời: 30 điểm
Bộ lọc xu hướng SMA: Bật / Tắt
Dùng chốt lời: Bật / Tắt
Bộ lọc giờ: Bật / Tắt
Khung giờ giao dịch: 09:00 – 14:30
Chiều giao dịch: Mua / Bán / Cả hai

Cài đặt mặc định của script:
Chiến lược sử dụng MACD(12,26,9), trong đó đường MACD được tính từ chênh lệch giữa EMA(12) và EMA(26). Đường Signal là EMA(9) của chính đường MACD.
Khi MACD cắt lên đường Signal, động lượng tăng có thể đang chiếm ưu thế. Khi MACD cắt xuống đường Signal, động lượng giảm có thể đang chiếm ưu thế.
Khi bật bộ lọc xu hướng SMA(200), script chỉ cho phép lệnh Mua khi SMA(200) dốc lên và chỉ cho phép lệnh Bán khi SMA(200) dốc xuống. Khi tắt bộ lọc SMA, chiến lược có thể giao dịch cả hai chiều chỉ dựa trên tín hiệu giao cắt MACD.
Người dùng có thể thêm chỉ báo MACD có sẵn trên TradingView với tham số 12, 26, 9 và nguồn close để quan sát tín hiệu trực quan bên dưới biểu đồ giá.

Điều kiện vào và thoát lệnh:
Vào lệnh Mua:
MACD(12,26,9) cắt lên đường Signal
VÀ SMA(200) dốc lên, nếu bật bộ lọc SMA
VÀ tín hiệu xuất hiện trong khung giờ giao dịch
VÀ chiều giao dịch cho phép lệnh Mua
Thoát lệnh Mua:
Cắt lỗ: 10 điểm từ giá vào lệnh
Chốt lời: 30 điểm từ giá vào lệnh, nếu bật
MACD cắt xuống đường Signal
Đảo chiều khi xuất hiện tín hiệu Bán hợp lệ
Tự động đóng lệnh khi hết khung giờ giao dịch

Vào lệnh Bán:
MACD(12,26,9) cắt xuống đường Signal
VÀ SMA(200) dốc xuống, nếu bật bộ lọc SMA
VÀ tín hiệu xuất hiện trong khung giờ giao dịch
VÀ chiều giao dịch cho phép lệnh Bán
Thoát lệnh Bán:
Cắt lỗ: 10 điểm từ giá vào lệnh
Chốt lời: 30 điểm từ giá vào lệnh, nếu bật
MACD cắt lên đường Signal
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
// ║  Instrument: VN30! | MACD Trend Following                    ║
// ║  Version: CNPS 01 MACD                                       ║ 
// ║  Recommended timeframe: M5 | Slippage = 3                    ║
// ╚══════════════════════════════════════════════════════════════╝
//*The cost to open a position in futures trading is roughly VND 30,000,000 per contract.
//For VN Future Trading, the commission value is set at VND 10,000 per contract traded. Tax is not yet included.

//@version=6
strategy(
     title       = "CNPS 01 MACD",
     shorttitle  = "CNPS 01",
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

// ── MACD settings ───────────────────────────────────────────────
macdFast = input.int(
     12,
     title="Fast Length",
     minval=1,
     group="MACD Settings"
 )

macdSlow = input.int(
     26,
     title="Slow Length",
     minval=1,
     group="MACD Settings"
 )

macdSignal = input.int(
     9,
     title="Signal Length",
     minval=1,
     group="MACD Settings"
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
     30.0,
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

// ── MACD ────────────────────────────────────────────────────────
[macdLine, signalLine, hist] = ta.macd(
     close,
     macdFast,
     macdSlow,
     macdSignal
 )


// ════════════════════════════════════════════════════════════════
// SECTION 3: STRATEGY RATIONALE
// ════════════════════════════════════════════════════════════════

// MACD is used to detect momentum shifts in the market.
// It compares a fast moving average with a slow moving average,
// then uses the signal line to identify potential changes in direction.
//
// When the MACD line crosses above the signal line,
// it may indicate that bullish momentum is starting to strengthen.
// When the MACD line crosses below the signal line,
// it may indicate that bearish momentum is starting to strengthen.
//
// However, MACD crossover signals can become noisy
// when the market is sideways or when price moves in a narrow range.
// In those conditions, MACD may produce frequent signals
// without a strong trend behind them.
//
// For that reason, this strategy combines MACD with an SMA trend filter.
// MACD identifies the momentum shift.
// The SMA filter checks whether the broader trend supports that signal.
//
// If the SMA is rising, the strategy gives priority to Long signals.
// If the SMA is falling, the strategy gives priority to Short signals.
// This combination is designed to reduce counter-trend entries
// and improve the overall quality of trend-following signals.


// ════════════════════════════════════════════════════════════════
// SECTION 4: SIGNAL LOGIC
// ════════════════════════════════════════════════════════════════

// Signals are confirmed at candle close.
// Orders are executed on the next candle open.
//
// Long signal:
// The MACD line crosses above the signal line.
//
// Short signal:
// The MACD line crosses below the signal line.
rawLong = ta.crossover(macdLine, signalLine)
rawShort = ta.crossunder(macdLine, signalLine)

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
// Natural reversal is handled by strategy.entry.
// A new opposite entry closes the existing position automatically.
if canLong
    strategy.entry("Long", strategy.long)

if canShort
    strategy.entry("Short", strategy.short)

// ── Stop loss / take profit exits ───────────────────────────────
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

// ── MACD note ───────────────────────────────────────────────────
// MACD is an oscillator, so it is not plotted on the price chart.
// Users can add the built-in MACD indicator manually if needed.
// Default MACD parameters: Fast=12, Slow=26, Signal=9, Source=close.

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
