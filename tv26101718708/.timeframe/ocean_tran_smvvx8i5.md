# ocean tran

- url: https://www.tradingview.com/script/SMvvX8i5/
- type: indicator
- pine_id: PUB;7c45c3d796e44eff920c685b88da2f94
- version: 1.0

## Description

Chỉ báo tín hiệu gồm các tín hiệu sau 
MA200
Pivot point 
RSI 
TRENDLINE
SELL KHI : GIÁ DƯỚI MA200 SO SÁNH VỚI PIVOT POINT VÀ RSI 
TỚI TRENDLINE QUAN SÁT

## Source Code

````pine
//@version=5
indicator("H1 Strategy Dashboard: MA200-Pivot-POC-RSI", overlay=true)

// --- 0. KIỂM TRA KHUNG THỜI GIAN H1 ---
isH1 = timeframe.isintraday and timeframe.multiplier == 60
if not isH1
    runtime.error("Chỉ báo này chỉ hoạt động trên khung H1. Vui lòng chuyển biểu đồ sang 1H!")

// --- 1. MA200 (MÀU ĐỎ) ---
ma200 = ta.ema(close, 200)
plot(isH1 ? ma200 : na, color=color.red, linewidth=3, title="MA 200 Đỏ")

// --- 2. PIVOT POINT ĐIỂM P (MÀU VÀNG) ---
[hD, lD, cD] = request.security(syminfo.tickerid, "D", [high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)
pivotP = (hD + lD + cD) / 3
plot(isH1 ? pivotP : na, "Điểm P Vàng", color=color.yellow, style=plot.style_linebr, linewidth=2)

// --- 3. NỐI CÁC ĐÁY H1 (MÀU XANH AQUA) ---
lb = 10, rb = 10
plPrice = ta.pivotlow(low, lb, rb)
var line bottomTrend = na

if not na(plPrice) and isH1
    int   p_idx   = 0
    float p_price = 0.0
    for i = 1 to 100
        if not na(plPrice[i])
            p_idx   := bar_index[i + lb]
            p_price := low[i + lb]
            break
    if p_price > 0
        line.delete(bottomTrend)
        bottomTrend := line.new(p_idx, p_price, bar_index[lb], low[lb], color=color.aqua, width=2, extend=extend.right)

// --- 4. TÍNH TOÁN RSI & POC (POINT OF CONTROL) ---
rsiVal = ta.rsi(close, 14)

// POC: Mức giá có khối lượng giao dịch cao nhất trong 24 nến H1
highestVol = ta.highest(volume, 24)
pocPrice = ta.valuewhen(volume == highestVol, close, 0)

// Vẽ chấm cam nhỏ tại POC để nhận diện vùng giá trị
plot(isH1 ? pocPrice : na, "POC Dot", color=color.new(color.orange, 50), style=plot.style_circles)

// --- 5. BẢNG GIÁ TRỊ (DASHBOARD) ---
var table board = table.new(position.top_right, 2, 4, bgcolor=color.new(color.black, 30), border_width=1, border_color=color.gray)

if barstate.islast and isH1
    // Header
    table.cell(board, 0, 0, "THÔNG SỐ H1", text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray, 50))
    table.cell(board, 1, 0, "GIÁ TRỊ", text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray, 50))
    
    // Hàng Điểm P (Pivot)
    table.cell(board, 0, 1, "Điểm P (Pivot)", text_color=color.yellow, text_halign=text.align_left)
    table.cell(board, 1, 1, str.tostring(pivotP, "#.##"), text_color=color.yellow)
    
    // Hàng RSI
    table.cell(board, 0, 2, "Chỉ số RSI", text_color=color.white, text_halign=text.align_left)
    table.cell(board, 1, 2, str.tostring(rsiVal, "#.##"), bgcolor=rsiVal > 70 ? color.new(color.red, 30) : rsiVal < 30 ? color.new(color.green, 30) : na, text_color=color.white)
    
    // Hàng POC
    table.cell(board, 0, 3, "Điểm POC", text_color=color.orange, text_halign=text.align_left)
    table.cell(board, 1, 3, str.tostring(pocPrice, "#.##"), text_color=color.orange)
````
