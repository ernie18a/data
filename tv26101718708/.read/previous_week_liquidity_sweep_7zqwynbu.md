# Previous Week Liquidity Sweep 

- url: https://www.tradingview.com/script/7ZQwyNBu-Previous-Week-Liquidity-Sweep/
- type: indicator
- pine_id: PUB;ca0ab690bd2f49028b530f1bdb029220
- version: 3.0

## Description

PW Liquidity Sweep (Multi-TF)
Concept:
This indicator identifies Liquidity Sweeps (Stop Hunts) occurring at the Previous Week High (PWH) and Previous Week Low (PWL). These levels are major liquidity pools where "Smart Money" often traps retail traders before reversing the price.

How it works:

Previous Week Levels: Automatically fetches and plots the High (Red) and Low (Green) from the last week.

Bullish Sweep (Green Triangle): Triggered when the price dips below the PWL but manages to close back above it. This suggests a "Bear Trap" or a cleanup of Sell-side liquidity.

Bearish Sweep (Red Triangle): Triggered when the price breaks above the PWH but closes back below it. This suggests a "Bull Trap" or a cleanup of Buy-side liquidity.

How to Use:

Entry: Look for the triangle signals when the price reacts to the dashed lines.

Context: Works best on Intraday timeframes (M15 to H1) for precise entries.

Confirmation: Most effective when these "sweeps" occur at key support/resistance zones or moving averages (like SMA 100/200).

Risk Management: Place your Stop Loss (SL) just beyond the "wick" (high/low) of the sweep candle.

## Source Code

````pine
//@version=6
indicator('Custom TF Liquidity Sweep', overlay = true, max_lines_count = 500)

// --- 1. Cài đặt Khung thời gian (MỚI) ---
htf = input.timeframe("W", title="Khung thời gian tham chiếu (HTF)")

// --- 2. Lấy dữ liệu Đỉnh/Đáy của Khung thời gian trước ---
[prevH, prevL] = request.security(syminfo.tickerid, htf, [high[1], low[1]], lookahead = barmerge.lookahead_on)

// --- 3. Vẽ đường High / Low cho khung hiện tại ---
var line htfH_line = na
var line htfL_line = na

// Cập nhật đường kẻ mỗi khi bắt đầu một cây nến mới của khung thời gian lớn (HTF)
if bool(ta.change(time(htf)))
    htfH_line := line.new(bar_index, prevH, bar_index + 1, prevH, color = color.red, style = line.style_dashed, width = 1)
    htfL_line := line.new(bar_index, prevL, bar_index + 1, prevL, color = color.green, style = line.style_dashed, width = 1)
else
    if not na(htfH_line)
        line.set_x2(htfH_line, bar_index)
        line.set_x2(htfL_line, bar_index)

// --- 4. Logic phát hiện Sweep Liquidity ---
// Lọc điều kiện: Chỉ nên xét Sweep khi khung đồ thị hiện tại (Chart TF) nhỏ hơn hoặc bằng khung tham chiếu (HTF)
valid_tf = timeframe.in_seconds(timeframe.period) <= timeframe.in_seconds(htf)

// Bullish Sweep: Giá thấp nhất dưới prevL VÀ Giá đóng cửa của khung thời gian hiện tại nằm trên prevL
bullish_sweep = valid_tf and low < prevL and close > prevL

// Bearish Sweep: Giá cao nhất trên prevH VÀ Giá đóng cửa của khung thời gian hiện tại nằm dưới prevH
bearish_sweep = valid_tf and high > prevH and close < prevH

// --- 5. Đánh dấu tín hiệu lên biểu đồ ---
plotshape(bullish_sweep, title = 'Bullish Sweep', style = shape.triangleup, location = location.belowbar, color = color.green, size = size.tiny)
plotshape(bearish_sweep, title = 'Bearish Sweep', style = shape.triangledown, location = location.abovebar, color = color.red, size = size.tiny)

// --- 6. Tín hiệu Cảnh báo ---
alertcondition(bullish_sweep, title = 'Bullish HTF Sweep', message = 'Mã {{ticker}} vừa quét ĐÁY khung tham chiếu trước và đóng cửa rút chân (Khung {{interval}})!')
alertcondition(bearish_sweep, title = 'Bearish HTF Sweep', message = 'Mã {{ticker}} vừa quét ĐỈNH khung tham chiếu trước và bị bán ngược (Khung {{interval}})!')
````
