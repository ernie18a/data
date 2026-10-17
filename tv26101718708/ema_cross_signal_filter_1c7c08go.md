# EMA Cross Signal FILTER

- url: https://www.tradingview.com/script/1C7c08GO-EMA-Cross-Signal-FILTER/
- type: indicator
- pine_id: PUB;95160aa9cce14795bc6c8281e682e49e
- version: 1.0

## Description

- Close cross EMA6, EMA10 - >Buy/Sell Signal
- Filter: EMA10 follow EMA30.
Work for GOLD 30M, SILVER 30M

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © thangvq_okysaigon
//@version=6
indicator(title="EMA Cross Signal [6/10/30]", shorttitle="EMA Cross", overlay=true)

// ═══════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════
ema6_len   = input.int(6,  title="EMA 6",  minval=1, group="EMA Settings")
ema10_len  = input.int(10, title="EMA 10", minval=1, group="EMA Settings")
ema30_len  = input.int(30, title="EMA 30", minval=1, group="EMA Settings")

show_ema6  = input.bool(true,  title="Show EMA 6",  group="Display")
show_ema10 = input.bool(true,  title="Show EMA 10", group="Display")
show_ema30 = input.bool(true,  title="Show EMA 30", group="Display")

show_normal_signals = input.bool(true, title="Show Normal Signals (cross EMA6 & EMA10)",        group="Signal Filter")
show_strong_signals = input.bool(true, title="Show Strong Signals (cross EMA6, EMA10 & EMA30)", group="Signal Filter")

// ═══════════════════════════════════════════════════════════════
//  EMA CALCULATIONS
// ═══════════════════════════════════════════════════════════════
ema6  = ta.ema(close, ema6_len)
ema10 = ta.ema(close, ema10_len)
ema30 = ta.ema(close, ema30_len)

// ═══════════════════════════════════════════════════════════════
//  BỘ LỌC NHIỄU: EMA10 cross EMA30 (giữ trạng thái bằng var)
//  - Khi EMA10 cắt lên EMA30  → trend = BUY  zone, chỉ lấy tín hiệu BUY
//  - Khi EMA10 cắt xuống EMA30 → trend = SELL zone, chỉ lấy tín hiệu SELL
//  - Chưa có cross nào → không phát tín hiệu
// ═══════════════════════════════════════════════════════════════
ema10_cross_above_ema30 = ta.crossover (ema10, ema30)   // Golden cross
ema10_cross_below_ema30 = ta.crossunder(ema10, ema30)   // Death  cross

// Biến lưu trạng thái: 1 = bullish zone, -1 = bearish zone, 0 = chưa xác định
var int trend_zone = 0
if ema10_cross_above_ema30
    trend_zone := 1
else if ema10_cross_below_ema30
    trend_zone := -1

bullish_zone = trend_zone ==  1   // EMA10 đã cắt lên  EMA30 và chưa bị đảo
bearish_zone = trend_zone == -1   // EMA10 đã cắt xuống EMA30 và chưa bị đảo

// ═══════════════════════════════════════════════════════════════
//  SIGNAL LOGIC
// ═══════════════════════════════════════════════════════════════

// --- Giá nến đóng cửa vượt qua EMA (crossover = từ dưới lên)
price_cross_above_ema6  = ta.crossover(close, ema6)
price_cross_above_ema10 = ta.crossover(close, ema10)
price_cross_above_ema30 = ta.crossover(close, ema30)

// --- Giá nến đóng cửa xuống dưới EMA (crossunder = từ trên xuống)
price_cross_below_ema6  = ta.crossunder(close, ema6)
price_cross_below_ema10 = ta.crossunder(close, ema10)
price_cross_below_ema30 = ta.crossunder(close, ema30)

// --- Giá đang nằm trên / dưới EMA
above_ema6  = close > ema6
above_ema10 = close > ema10
above_ema30 = close > ema30

below_ema6  = close < ema6
below_ema10 = close < ema10
below_ema30 = close < ema30

// ════════════════════════════════════════════════════════════════
//  BUY / SELL SIGNALS — đều phải qua bộ lọc trend_zone
// ════════════════════════════════════════════════════════════════

// Normal Buy: đang trong bullish zone + close cắt lên EMA6 hoặc EMA10
buy_normal_cond  = bullish_zone
                 and (price_cross_above_ema6 or price_cross_above_ema10)
                 and above_ema6 and above_ema10
                 and not (above_ema30 and price_cross_above_ema30)

// Strong Buy: đang trong bullish zone + close cắt lên & trên cả 3 EMA
buy_strong_cond  = bullish_zone
                 and (price_cross_above_ema6 or price_cross_above_ema10 or price_cross_above_ema30)
                 and above_ema6 and above_ema10 and above_ema30

// Normal Sell: đang trong bearish zone + close cắt xuống EMA6 hoặc EMA10
sell_normal_cond = bearish_zone
                 and (price_cross_below_ema6 or price_cross_below_ema10)
                 and below_ema6 and below_ema10
                 and not (below_ema30 and price_cross_below_ema30)

// Strong Sell: đang trong bearish zone + close cắt xuống & dưới cả 3 EMA
sell_strong_cond = bearish_zone
                 and (price_cross_below_ema6 or price_cross_below_ema10 or price_cross_below_ema30)
                 and below_ema6 and below_ema10 and below_ema30

// ═══════════════════════════════════════════════════════════════
//  PLOT EMA LINES
// ═══════════════════════════════════════════════════════════════
plot(show_ema6  ? ema6  : na, title="EMA 6",  color=color.new(color.yellow, 0), linewidth=1)
plot(show_ema10 ? ema10 : na, title="EMA 10", color=color.new(color.orange, 0), linewidth=1)
plot(show_ema30 ? ema30 : na, title="EMA 30", color=color.new(color.red,    0), linewidth=2)

// Đánh dấu thời điểm EMA10 cắt EMA30 (bộ lọc trend)
plotshape(ema10_cross_above_ema30,
     title    = "EMA10 Golden Cross",
     location = location.belowbar,
     style    = shape.diamond,
     size     = size.small,
     color    = color.new(color.aqua, 0),
     text     = "G",
     textcolor= color.new(color.aqua, 0))

plotshape(ema10_cross_below_ema30,
     title    = "EMA10 Death Cross",
     location = location.abovebar,
     style    = shape.diamond,
     size     = size.small,
     color    = color.new(color.fuchsia, 0),
     text     = "D",
     textcolor= color.new(color.fuchsia, 0))

// ═══════════════════════════════════════════════════════════════
//  PLOT SIGNALS
// ═══════════════════════════════════════════════════════════════

// Normal BUY — mũi tên lên xanh lá
plotshape(show_normal_signals and buy_normal_cond,
     title    = "Buy Normal",
     location = location.belowbar,
     style    = shape.arrowup,
     size     = size.normal,
     color    = color.new(color.lime, 0),
     text     = "BUY",
     textcolor= color.new(color.lime, 0))

// Strong BUY — mũi tên lên xanh đậm, to hơn
plotshape(show_strong_signals and buy_strong_cond,
     title    = "Buy Strong",
     location = location.belowbar,
     style    = shape.arrowup,
     size     = size.large,
     color    = color.new(color.green, 0),
     text     = "BUY ★",
     textcolor= color.new(color.green, 0))

// Normal SELL — mũi tên xuống đỏ
plotshape(show_normal_signals and sell_normal_cond,
     title    = "Sell Normal",
     location = location.abovebar,
     style    = shape.arrowdown,
     size     = size.normal,
     color    = color.new(color.red, 0),
     text     = "SELL",
     textcolor= color.new(color.red, 0))

// Strong SELL — mũi tên xuống đỏ đậm, to hơn
plotshape(show_strong_signals and sell_strong_cond,
     title    = "Sell Strong",
     location = location.abovebar,
     style    = shape.arrowdown,
     size     = size.large,
     color    = color.new(color.maroon, 0),
     text     = "SELL ★",
     textcolor= color.new(color.maroon, 0))

// ═══════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════
alertcondition(ema10_cross_above_ema30, title="[Filter] Golden Cross EMA10/30",  message="✅ EMA10 cắt lên EMA30 — BUY zone kích hoạt")
alertcondition(ema10_cross_below_ema30, title="[Filter] Death Cross EMA10/30",   message="⛔ EMA10 cắt xuống EMA30 — SELL zone kích hoạt")
alertcondition(buy_normal_cond,         title="[Normal] BUY Signal",             message="📈 BUY — Giá cắt lên EMA6 & EMA10 (trong BUY zone)")
alertcondition(buy_strong_cond,         title="[STRONG] BUY Signal",             message="🚀 BUY MẠNH — Giá cắt lên EMA6, EMA10 & EMA30 (trong BUY zone)")
alertcondition(sell_normal_cond,        title="[Normal] SELL Signal",            message="📉 SELL — Giá cắt xuống EMA6 & EMA10 (trong SELL zone)")
alertcondition(sell_strong_cond,        title="[STRONG] SELL Signal",            message="🔻 SELL MẠNH — Giá cắt xuống EMA6, EMA10 & EMA30 (trong SELL zone)")

//@version=6
plot(close)
````
