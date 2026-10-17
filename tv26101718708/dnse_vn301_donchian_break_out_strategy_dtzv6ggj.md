# DNSE VN301!, Donchian Break Out Strategy

- url: https://www.tradingview.com/script/DTZv6GgJ/
- type: strategy
- pine_id: PUB;d91cd5a9a2174d10af22573ba8d8e7a0
- version: 1.0

## Description

"Donchian Channel Breakout with SMA Trend Filter" is a trend-following breakout strategy designed to capture sustained price movements while filtering out low-probability signals. The Donchian Channel identifies breakouts by tracking the highest high and lowest low over a specified lookback period, generating potential entry signals when price closes outside the recent trading range. Because breakouts during sideways or low-volatility markets often fail, the strategy incorporates a Simple Moving Average (SMA) as a trend filter. 

Long signals are prioritized when the SMA is rising, while Short signals are prioritized when the SMA is falling, ensuring trades align with the prevailing market trend. By combining breakout detection with trend confirmation, the strategy aims to reduce false breakouts and improve overall signal quality.

*By default: each VN Futures contract requires VND 30,000,000 of initial margin. The strategy assumes an initial capital of VND 100,000,000, resulting in a fixed position size of 3 contracts for each trading signal.
To better reflect real-market trading conditions, the backtest incorporates a commission of VND 10,000 per contract and a minimum slippage assumption of 3 ticks on every executed trade.

[b]Settings & Strategy Configuration:[/b]
[list]
[*]Chart: recommended 15-minute timeframe
[*]Donchian Channel Period: 20
[*]SMA Period: 200
[*]Stop Loss: 10 points
[*]Take Profit: 20 points
[*]SMA Trend Filter: On / Off
[*]Use Take Profit: On / Off
[*]Time Filter: On / Off
[*]Trading Session: 09:00 – 14:30
[*]Trade Direction: Long / Short / Both
[/list]

[b]Default Script Settings:[/b]
The strategy calculates the upper and lower bands of the Donchian Channel using the selected lookback period. A breakout above the upper band may indicate buying pressure, while a breakout below the lower band may indicate selling pressure.
When the SMA(200) trend filter is enabled, the script only allows Long entries when SMA(200) is rising and only allows Short entries when SMA(200) is falling. When the SMA filter is disabled, the strategy can trade both directions based only on Donchian Channel breakout signals.

[b]Entry & Exit Conditions:[/b]
[b]Entry Long:[/b]
Close Price > Upper Donchian Channel
AND SMA(200) is rising, if the SMA filter is enabled
AND the signal appears within the selected trading session
AND Long trading is allowed by the trade direction setting

[b]Exit Long:[/b]
Stop Loss: 10 points from entry price
Take Profit: 20 points from entry price, if enabled
Opposite Donchian breakout signal
Position reversal when a valid Short signal appears
Automatic close at the end of the trading session

[b]Entry Short:[/b]
Close Price < Lower Donchian Channel
AND SMA(200) is falling, if the SMA filter is enabled
AND the signal appears within the selected trading session
AND Short trading is allowed by the trade direction setting

[b]Exit Short:[/b]
Stop Loss: 10 points from entry price
Take Profit: 20 points from entry price, if enabled
Opposite Donchian breakout signal
Position reversal when a valid Long signal appears
Automatic close at the end of the trading session

[b]Disclaimers:[/b]
Trading futures contracts carries a high degree of risk, and price movements can be highly volatile. This script is intended as a reference and research tool only. It should be used by individuals who understand futures trading, have assessed their own risk tolerance, and are knowledgeable about the strategy’s logic.
All investment decisions are the sole responsibility of the user. DNSE bears no liability for any potential losses incurred from applying this strategy in real trading. Past performance does not guarantee future results.
______________________________________________________________________

"Chiến lược Breakout Donchian Channel kết hợp bộ lọc xu hướng SMA" là một chiến lược giao dịch theo xu hướng, được thiết kế nhằm tận dụng các đợt bứt phá giá mạnh đồng thời giảm thiểu các tín hiệu nhiễu. Donchian Channel xác định các điểm breakout bằng cách theo dõi mức giá cao nhất và thấp nhất trong một khoảng thời gian xác định, từ đó tạo tín hiệu khi giá đóng cửa vượt ra khỏi vùng dao động gần nhất. Do các tín hiệu breakout trong giai đoạn thị trường đi ngang hoặc biến động thấp thường có xác suất thất bại cao, chiến lược sử dụng thêm đường trung bình động đơn giản (SMA) làm bộ lọc xu hướng. 

Khi đường SMA đang dốc lên, chiến lược ưu tiên các tín hiệu Long; ngược lại, khi SMA dốc xuống, chiến lược ưu tiên các tín hiệu Short, giúp các lệnh giao dịch đi cùng xu hướng chính của thị trường. Bằng cách kết hợp tín hiệu breakout với xác nhận xu hướng, chiến lược hướng tới việc giảm các tín hiệu phá vỡ giả và nâng cao chất lượng giao dịch.

*Theo mặc định, mỗi hợp đồng VN Futures yêu cầu ký quỹ ban đầu là 30.000.000 VNĐ. Chiến lược giả định vốn ban đầu là 100.000.000 VNĐ, tương ứng với quy mô vị thế cố định là 3 hợp đồng cho mỗi tín hiệu giao dịch được tạo ra.
Để phản ánh sát hơn điều kiện giao dịch thực tế, kết quả kiểm định (backtest) được giả định với phí giao dịch là 10.000 VNĐ cho mỗi hợp đồng và độ trượt giá (slippage) tối thiểu là 3 bước giá (ticks) đối với mỗi lệnh được khớp.

[b]Cài đặt & cấu hình chiến lược:[/b]
[list]
[*]Biểu đồ: khuyến nghị khung 15 phút
[*]Chu kỳ Donchian Channel: 20
[*]Chu kỳ SMA: 200
[*]Cắt lỗ: 10 điểm
[*]Chốt lời: 20 điểm
[*]Bộ lọc xu hướng SMA: Bật / Tắt
[*]Dùng chốt lời: Bật / Tắt
[*]Bộ lọc giờ: Bật / Tắt
[*]Khung giờ giao dịch: 09:00 – 14:30
[*]Chiều giao dịch: Mua / Bán / Cả hai
[/list]

Cài đặt mặc định của script:
Chiến lược tính toán biên trên và biên dưới của Donchian Channel dựa trên chu kỳ được chọn. Khi giá phá lên biên trên, lực mua có thể đang chiếm ưu thế. Khi giá phá xuống biên dưới, lực bán có thể đang chiếm ưu thế.
Khi bật bộ lọc xu hướng SMA(200), script chỉ cho phép lệnh Mua khi SMA(200) dốc lên và chỉ cho phép lệnh Bán khi SMA(200) dốc xuống. Khi tắt bộ lọc SMA, chiến lược có thể giao dịch cả hai chiều chỉ dựa trên tín hiệu breakout của Donchian Channel.

[b]Điều kiện vào và thoát lệnh:[/b]
[b]Vào lệnh Mua:[/b]
Giá đóng cửa > Biên trên Donchian Channel
VÀ SMA(200) dốc lên, nếu bật bộ lọc SMA
VÀ tín hiệu xuất hiện trong khung giờ giao dịch
VÀ chiều giao dịch cho phép lệnh Mua
[b]Thoát lệnh Mua:[/b]
Cắt lỗ: 10 điểm từ giá vào lệnh
Chốt lời: 20 điểm từ giá vào lệnh, nếu bật
Có tín hiệu breakout ngược chiều
Đảo chiều khi xuất hiện tín hiệu Bán hợp lệ
Tự động đóng lệnh khi hết khung giờ giao dịch

[b]Vào lệnh Bán:[/b]
Giá đóng cửa < Biên dưới Donchian Channel
VÀ SMA(200) dốc xuống, nếu bật bộ lọc SMA
VÀ tín hiệu xuất hiện trong khung giờ giao dịch
VÀ chiều giao dịch cho phép lệnh Bán
[b]Thoát lệnh Bán:[/b]
Cắt lỗ: 10 điểm từ giá vào lệnh
Chốt lời: 20 điểm từ giá vào lệnh, nếu bật
Có tín hiệu breakout ngược chiều
Đảo chiều khi xuất hiện tín hiệu Mua hợp lệ
Tự động đóng lệnh khi hết khung giờ giao dịch

[b]Tuyên bố rủi ro:[/b]
Giao dịch hợp đồng tương lai có mức độ rủi ro cao và giá có thể biến động mạnh. Script này chỉ phục vụ mục đích tham khảo, nghiên cứu và kiểm thử. Người dùng cần hiểu rõ giao dịch phái sinh, khẩu vị rủi ro cá nhân và logic của chiến lược trước khi áp dụng vào giao dịch thực tế.
Mọi quyết định đầu tư thuộc trách nhiệm của người dùng. DNSE không chịu trách nhiệm cho bất kỳ khoản lỗ nào phát sinh từ việc sử dụng chiến lược này trong giao dịch thực tế. Hiệu quả trong quá khứ không đảm bảo kết quả trong tương lai.

## Source Code

````pine
// ╔══════════════════════════════════════════════════════════════╗
// ║        PSOL Universal Bot Template — Pine Script v6          ║
// ║  Instrument: VN30! | Donchian Channel                        ║
// ║  Version: PSOL 01 DC                                         ║
// ║  Recommended timeframe: M5 | Slippage = 3                    ║
// ╚══════════════════════════════════════════════════════════════╝

//@version=6
strategy(
     title       = "PSOL 01 DC",
     shorttitle  = "PSOL 01",
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

// ── Donchian Channel settings ───────────────────────────────────
dcLen = input.int(
     20,
     title="Donchian Channel Length",
     minval=1,
     group="Donchian Channel"
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

// ── Donchian Channel ────────────────────────────────────────────
// The upper and lower bands are calculated from the highest high
// and lowest low over the selected lookback period.
// The [1] offset uses the previous candle value to avoid look-ahead bias.
dcUpper = ta.highest(high, dcLen)[1]
dcLower = ta.lowest(low, dcLen)[1]
dcMid   = math.avg(dcUpper, dcLower)


// ════════════════════════════════════════════════════════════════
// SECTION 3: STRATEGY RATIONALE
// ════════════════════════════════════════════════════════════════

// The Donchian Channel is used to identify price breakout zones.
// It defines the recent trading range by tracking the highest high
// and the lowest low over a selected lookback period.
//
// When price closes above the upper Donchian band,
// it means price has broken above the recent highest range.
// This can indicate stronger buying pressure and potential upside continuation.
//
// When price closes below the lower Donchian band,
// it means price has broken below the recent lowest range.
// This can indicate stronger selling pressure and potential downside continuation.
//
// However, breakout signals can be noisy when the market is sideways,
// compressed, or moving inside a narrow range.
// A breakout against the larger trend may fail quickly.
//
// For that reason, this strategy combines the Donchian Channel
// with an SMA trend filter.
// The Donchian Channel identifies the breakout.
// The SMA filter checks whether the broader trend supports that breakout.
//
// If the SMA is rising, the strategy gives priority to Long signals.
// If the SMA is falling, the strategy gives priority to Short signals.
// This combination is designed to reduce counter-trend trades
// and improve the quality of breakout signals.


// ════════════════════════════════════════════════════════════════
// SECTION 4: SIGNAL LOGIC
// ════════════════════════════════════════════════════════════════

// Signals are confirmed at candle close.
// Orders are executed on the next candle.
//
// Long signal:
// Price closes above the upper Donchian band.
//
// Short signal:
// Price closes below the lower Donchian band.
rawLong  = close > dcUpper
rawShort = close < dcLower

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

// ── Donchian Channel plots ──────────────────────────────────────
plot(
     dcUpper,
     title="Donchian Upper Band",
     color=color.new(color.blue, 20),
     linewidth=1
 )

plot(
     dcLower,
     title="Donchian Lower Band",
     color=color.new(color.blue, 20),
     linewidth=1
 )

plot(
     dcMid,
     title="Donchian Middle Line",
     color=color.new(color.blue, 60),
     linewidth=1,
     style=plot.style_circles
 )

// ── Donchian Channel fill ───────────────────────────────────────
dcUpperPlot = plot(dcUpper, display=display.none)
dcLowerPlot = plot(dcLower, display=display.none)

fill(
     dcUpperPlot,
     dcLowerPlot,
     color=color.new(color.blue, 92),
     title="Donchian Channel Area"
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
