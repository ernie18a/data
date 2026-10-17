# Linda Raschke Scalping - Box Signal

- url: https://www.tradingview.com/script/MRWtng3L-Linda-Raschke-Scalping-Box-Signal/
- type: indicator
- pine_id: PUB;24d17aaff6504b81b05ee60886cf9dba
- version: 1.0

## Description

Strategy Description (Short & Sharp)
Linda Raschke Scalping is a mean-reversion scalping strategy that combines EMA 20 cross with MACD zero-line crossover, waiting for confirmation from the second event within a maximum of 5 bars.

Core Logic:
Setup: Price crosses EMA 20 (with bullish/bearish candle) OR MACD crosses zero line

Entry: Second event must occur within 5 bars to confirm the signal

Direction: Both price and MACD must align in the same direction

Filters Applied:
MACD Noise Filter – Ignores tiny crossovers below a minimum threshold to avoid whipsaws

Time Filter – Limits trading to specific sessions (e.g., high-liquidity hours)

Best Suited For:
Instruments: Liquid forex pairs (EUR/USD, GBP/USD, USD/JPY), index futures (ES, NQ)

Timeframes: 1-min to 5-min charts (true scalping)

Session: High-volume periods (London open, NY open, London-NY overlap)

Signal Types:
🟢 LONG: Price crosses above EMA 20 → wait for MACD above zero | OR MACD crosses above zero → wait for price above EMA 20

🔴 SHORT: Price crosses below EMA 20 → wait for MACD below zero | OR MACD crosses below zero → wait for price below EMA 20

Key Advantage:
Reduces false signals by requiring dual confirmation from both momentum (MACD) and trend (EMA), plus noise filtering for choppy markets.

## Source Code

````pine
//@version=5
indicator("Linda Raschke Scalping - Box Signal", overlay=true, max_boxes_count=500)

// ========== BỘ LỌC THỜI GIAN ==========
useTimeFilter = input.bool(true, "Sử dụng bộ lọc thời gian", group="⏰ Bộ lọc thời gian")
startHour = input.int(0, "Giờ bắt đầu", minval=0, maxval=23, group="⏰ Bộ lọc thời gian")
startMinute = input.int(0, "Phút bắt đầu", minval=0, maxval=59, group="⏰ Bộ lọc thời gian")
endHour = input.int(23, "Giờ kết thúc", minval=0, maxval=23, group="⏰ Bộ lọc thời gian")
endMinute = input.int(59, "Phút kết thúc", minval=0, maxval=59, group="⏰ Bộ lọc thời gian")

// Kiểm tra thời gian giao dịch
inTimeWindow = true
if useTimeFilter
    currentTime = timestamp(year, month, dayofmonth, hour, minute)
    startTime = timestamp(year, month, dayofmonth, startHour, startMinute)
    endTime = timestamp(year, month, dayofmonth, endHour, endMinute)
    inTimeWindow := currentTime >= startTime and currentTime <= endTime

// ========== THAM SỐ CHIẾN LƯỢC ==========
emaLength = input.int(20, "EMA Length", group="📊 Chỉ báo")
macdFastLength = input.int(12, "MACD Fast", group="📊 Chỉ báo")
macdSlowLength = input.int(26, "MACD Slow", group="📊 Chỉ báo")
macdSignalLength = input.int(9, "MACD Signal", group="📊 Chỉ báo")
maxBarsToWait = input.int(5, "Số nến tối đa chờ sự kiện còn lại", group="📊 Chỉ báo")

// Bộ lọc MACD để tránh nhiễu
useMacdFilter = input.bool(false, "Sử dụng bộ lọc MACD", group="🔧 Bộ lọc")
minMacdValue = input.float(0.00001, "MACD tối thiểu (tránh nhiễu)", group="🔧 Bộ lọc", step=0.00001)

// ========== TÍNH TOÁN CHỈ BÁO ==========
ema20 = ta.ema(close, emaLength)
[macdLine, signalLine, histLine] = ta.macd(close, macdFastLength, macdSlowLength, macdSignalLength)

// ========== VẼ CHỈ BÁO ==========
plot(ema20, "EMA 20", color=color.yellow, linewidth=2)

// ========== THEO DÕI SỰ KIỆN ==========

// Sự kiện 1: Giá cắt EMA từ dưới lên (nến xanh)
priceCrossUpEma = ta.crossover(close, ema20) and close > open

// Sự kiện 2: Giá cắt EMA từ trên xuống (nến đỏ)  
priceCrossDownEma = ta.crossunder(close, ema20) and close < open

// ========== MACD 4 MÀU - PHÁT HIỆN ĐẢO CHIỀU ==========
// Tính MACD hiện tại và trước đó
[currMacd, _, _] = ta.macd(close, macdFastLength, macdSlowLength, macdSignalLength)
[prevMacd, _, _] = ta.macd(close[1], macdFastLength, macdSlowLength, macdSignalLength)

// Sự kiện 3: MACD cắt từ âm lên dương (cắt qua 0)
macdCrossUp = ta.crossover(currMacd, 0)
macdCrossUpFiltered = macdCrossUp and (not useMacdFilter or math.abs(currMacd) >= minMacdValue)

// Sự kiện 4: MACD cắt từ dương xuống âm (cắt qua 0)
macdCrossDown = ta.crossunder(currMacd, 0)
macdCrossDownFiltered = macdCrossDown and (not useMacdFilter or math.abs(currMacd) >= minMacdValue)

// ========== TRẠNG THÁI CHỜ ĐỢI ==========
// Trạng thái: đang chờ MACD sau khi giá cắt EMA
var int waitingForMacdUpSince = na
var int waitingForMacdDownSince = na

// Trạng thái: đang chờ giá cắt EMA sau khi MACD đảo chiều
var int waitingForPriceUpSince = na
var int waitingForPriceDownSince = na

// ========== LOGIC TÍNH TÍN HIỆU LONG ==========
var bool longSignal = false
longSignal := false

// Trường hợp 1: Giá cắt lên EMA trước → chờ MACD cắt lên
if priceCrossUpEma
    waitingForMacdUpSince := bar_index
    waitingForPriceUpSince := na  // Hủy trạng thái chờ cũ

// Đếm số nến đã chờ
if not na(waitingForMacdUpSince)
    barsWaited = bar_index - waitingForMacdUpSince
    if barsWaited > maxBarsToWait
        waitingForMacdUpSince := na  // Quá thời gian chờ
    else if macdCrossUpFiltered
        longSignal := true  // Tín hiệu LONG!
        waitingForMacdUpSince := na

// Trường hợp 2: MACD cắt lên trước → chờ giá cắt lên EMA
if macdCrossUpFiltered
    waitingForPriceUpSince := bar_index
    waitingForMacdUpSince := na  // Hủy trạng thái chờ cũ

// Đếm số nến đã chờ
if not na(waitingForPriceUpSince)
    barsWaited = bar_index - waitingForPriceUpSince
    if barsWaited > maxBarsToWait
        waitingForPriceUpSince := na  // Quá thời gian chờ
    else if priceCrossUpEma
        longSignal := true  // Tín hiệu LONG!
        waitingForPriceUpSince := na

// ========== LOGIC TÍNH TÍN HIỆU SHORT ==========
var bool shortSignal = false
shortSignal := false

// Trường hợp 1: Giá cắt xuống EMA trước → chờ MACD cắt xuống
if priceCrossDownEma
    waitingForMacdDownSince := bar_index
    waitingForPriceDownSince := na  // Hủy trạng thái chờ cũ

// Đếm số nến đã chờ
if not na(waitingForMacdDownSince)
    barsWaited = bar_index - waitingForMacdDownSince
    if barsWaited > maxBarsToWait
        waitingForMacdDownSince := na  // Quá thời gian chờ
    else if macdCrossDownFiltered
        shortSignal := true  // Tín hiệu SHORT!
        waitingForMacdDownSince := na

// Trường hợp 2: MACD cắt xuống trước → chờ giá cắt xuống EMA
if macdCrossDownFiltered
    waitingForPriceDownSince := bar_index
    waitingForMacdDownSince := na  // Hủy trạng thái chờ cũ

// Đếm số nến đã chờ
if not na(waitingForPriceDownSince)
    barsWaited = bar_index - waitingForPriceDownSince
    if barsWaited > maxBarsToWait
        waitingForPriceDownSince := na  // Quá thời gian chờ
    else if priceCrossDownEma
        shortSignal := true  // Tín hiệu SHORT!
        waitingForPriceDownSince := na

// Áp dụng bộ lọc thời gian
longSignal := longSignal and inTimeWindow
shortSignal := shortSignal and inTimeWindow

// ========== VẼ BOX KHI CÓ TÍN HIỆU ==========
var box[] longBoxes = array.new<box>()
var box[] shortBoxes = array.new<box>()

if longSignal
    // Vẽ box xanh lá
    boxTop = high
    boxBottom = low
    newBox = box.new(left=bar_index, top=boxTop, right=bar_index + 1, bottom=boxBottom, 
                     border_color=color.new(color.lime, 0), bgcolor=color.new(color.lime, 80), 
                     border_width=2, text="LONG", text_color=color.lime, text_size=size.small)
    array.push(longBoxes, newBox)
    
    // Label
    label.new(bar_index, low, "🟢 LONG", style=label.style_label_up, 
              color=color.new(color.lime, 20), textcolor=color.black, size=size.normal)

if shortSignal
    // Vẽ box đỏ
    boxTop = high
    boxBottom = low
    newBox = box.new(left=bar_index, top=boxTop, right=bar_index + 1, bottom=boxBottom, 
                     border_color=color.new(color.red, 0), bgcolor=color.new(color.red, 80), 
                     border_width=2, text="SHORT", text_color=color.red, text_size=size.small)
    array.push(shortBoxes, newBox)
    
    // Label
    label.new(bar_index, high, "🔴 SHORT", style=label.style_label_down, 
              color=color.new(color.red, 20), textcolor=color.white, size=size.normal)

// ========== HIỂN THỊ TRẠNG THÁI ==========
var table infoTable = table.new(position.top_right, 2, 6, border_width=1)

if barstate.islast
    table.clear(infoTable, 0, 0, 1, 5)
    
    // Header
    table.cell(infoTable, 0, 0, "📊 TRẠNG THÁI", text_color=color.white, bgcolor=color.blue)
    table.cell(infoTable, 1, 0, "", text_color=color.white, bgcolor=color.blue)
    
    // Trạng thái chờ LONG
    waitingLongText = "Không"
    waitingLongColor = color.gray
    if not na(waitingForMacdUpSince)
        barsWaited = bar_index - waitingForMacdUpSince
        waitingLongText := "Chờ MACD↑ (" + str.tostring(barsWaited) + "/" + str.tostring(maxBarsToWait) + ")"
        waitingLongColor := color.green
    else if not na(waitingForPriceUpSince)
        barsWaited = bar_index - waitingForPriceUpSince
        waitingLongText := "Chờ Giá↑EMA (" + str.tostring(barsWaited) + "/" + str.tostring(maxBarsToWait) + ")"
        waitingLongColor := color.green
    
    table.cell(infoTable, 0, 1, "Chờ LONG", text_color=color.white, bgcolor=color.gray)
    table.cell(infoTable, 1, 1, waitingLongText, text_color=color.white, bgcolor=waitingLongColor)
    
    // Trạng thái chờ SHORT
    waitingShortText = "Không"
    waitingShortColor = color.gray
    if not na(waitingForMacdDownSince)
        barsWaited = bar_index - waitingForMacdDownSince
        waitingShortText := "Chờ MACD↓ (" + str.tostring(barsWaited) + "/" + str.tostring(maxBarsToWait) + ")"
        waitingShortColor := color.red
    else if not na(waitingForPriceDownSince)
        barsWaited = bar_index - waitingForPriceDownSince
        waitingShortText := "Chờ Giá↓EMA (" + str.tostring(barsWaited) + "/" + str.tostring(maxBarsToWait) + ")"
        waitingShortColor := color.red
    
    table.cell(infoTable, 0, 2, "Chờ SHORT", text_color=color.white, bgcolor=color.gray)
    table.cell(infoTable, 1, 2, waitingShortText, text_color=color.white, bgcolor=waitingShortColor)
    
    // Separator
    table.cell(infoTable, 0, 3, "────────", text_color=color.gray, bgcolor=color.black)
    table.cell(infoTable, 1, 3, "────────", text_color=color.gray, bgcolor=color.black)
    
    // MACD hiện tại với màu 4C
    macd4CColor = color.gray
    macd4CText = ""
    
    if currMacd > 0
        if currMacd > prevMacd
            macd4CColor := color.new(color.lime, 0)
            macd4CText := "↑ Lime"
        else
            macd4CColor := color.new(color.green, 0)
            macd4CText := "→ Green"
    else
        if currMacd < prevMacd
            macd4CColor := color.new(color.maroon, 0)
            macd4CText := "↓ Maroon"
        else
            macd4CColor := color.new(color.red, 0)
            macd4CText := "→ Red"
    
    table.cell(infoTable, 0, 4, "MACD 4C", text_color=color.white, bgcolor=color.gray)
    table.cell(infoTable, 1, 4, str.tostring(currMacd, "#.#####") + " " + macd4CText, text_color=color.white, bgcolor=macd4CColor)
    
    // Vị trí giá so với EMA
    priceVsEma = close > ema20 ? "Trên EMA" : close < ema20 ? "Dưới EMA" : "Tại EMA"
    priceColor = close > ema20 ? color.green : close < ema20 ? color.red : color.yellow
    table.cell(infoTable, 0, 5, "Giá vs EMA", text_color=color.white, bgcolor=color.gray)
    table.cell(infoTable, 1, 5, priceVsEma, text_color=color.white, bgcolor=priceColor)

// ========== CẢNH BÁO ==========
alertcondition(longSignal, "LONG Signal", "🟢 Tín hiệu LONG - Linda Raschke")
alertcondition(shortSignal, "SHORT Signal", "🔴 Tín hiệu SHORT - Linda Raschke")

// Tô màu nền ngoài giờ giao dịch
bgcolor(useTimeFilter and not inTimeWindow ? color.new(color.gray, 90) : na, title="Ngoài giờ giao dịch")
````
