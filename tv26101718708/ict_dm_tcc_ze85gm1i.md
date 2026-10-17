# ICT (DM)- TCC

- url: https://www.tradingview.com/script/ZE85GM1i/
- type: indicator
- pine_id: PUB;4364f399af0141318186e5567e050b49
- version: 1.0

## Description

Chỉ báo DM ict của Thợ Chây Coin. Đây là chỉ báo về DM của các cây nến tăng giảm

## Source Code

````pine
//@version=5
indicator("ICT Death Mark (DM) Shadowless - Thợ Chây Coin", overlay=true)

// --- ĐỊNH NGHĨA DM ---
isBullishDM = (close > open) and (open == low)  // Nến xanh không râu dưới
isBearishDM = (close < open) and (open == high) // Nến đỏ không râu trên

// --- QUẢN LÝ TRẠNG THÁI KHAI THÁC ---
// Lưu trữ bar_index và giá Open của các cây DM đang "Fresh"
var int[] bullIndexes = array.new_int()
var float[] bullPrices = array.new_float()

var int[] bearIndexes = array.new_int()
var float[] bearPrices = array.new_float()

// Khi xuất hiện DM mới, nạp vào mảng
if isBullishDM
    array.push(bullIndexes, bar_index)
    array.push(bullPrices, open)

if isBearishDM
    array.push(bearIndexes, bar_index)
    array.push(bearPrices, open)

// Kiểm tra và loại bỏ những cây DM đã bị giá chạm vào (Mitigated)
if array.size(bullIndexes) > 0
    for i = array.size(bullIndexes) - 1 to 0
        p = array.get(bullPrices, i)
        idx = array.get(bullIndexes, i)
        if bar_index > idx and low <= p
            array.remove(bullIndexes, i)
            array.remove(bullPrices, i)

if array.size(bearIndexes) > 0
    for i = array.size(bearIndexes) - 1 to 0
        p = array.get(bearPrices, i)
        idx = array.get(bearIndexes, i)
        if bar_index > idx and high >= p
            array.remove(bearIndexes, i)
            array.remove(bearPrices, i)

// --- TÔ MÀU NẾN ---
// Kiểm tra xem bar_index hiện tại có nằm trong danh sách "Fresh" hay không
is_fresh_dm() =>
    bool bull = false
    bool bear = false
    if array.size(bullIndexes) > 0
        for i = 0 to array.size(bullIndexes) - 1
            if array.get(bullIndexes, i) == bar_index
                bull := true
                break
    if array.size(bearIndexes) > 0
        for i = 0 to array.size(bearIndexes) - 1
            if array.get(bearIndexes, i) == bar_index
                bear := true
                break
    [bull, bear]

[isBull, isBear] = is_fresh_dm()

// Tô màu nến: Xanh cho Bullish DM, Đỏ cho Bearish DM
barcolor(isBull ? color.green : isBear ? color.red : na)
````
