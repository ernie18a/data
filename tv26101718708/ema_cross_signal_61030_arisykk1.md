# EMA Cross Signal [6/10/30]

- url: https://www.tradingview.com/script/arIsYKk1-EMA-Cross-Signal-6-10-30/
- type: indicator
- pine_id: PUB;f788e6fea0cf4a679fcca6f3db952e74
- version: 1.0

## Description

EMA cross buy signal. Work in trending market. Sizeway loss

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
//  BUY SIGNALS
//  Normal  : Nến vừa cross trên EMA6 hoặc EMA10,
//            và đóng cửa trên cả hai EMA đó
//  Strong  : Nến vừa cross trên EMA6, EMA10 hoặc EMA30
//            và đóng cửa trên cả ba EMA
// ════════════════════════════════════════════════════════════════

// Normal Buy: close cắt lên EMA6 hoặc EMA10, và đóng cửa trên cả hai
buy_normal_cond  = (price_cross_above_ema6 or price_cross_above_ema10)
                 and above_ema6 and above_ema10
                 and not (above_ema6 and above_ema10 and above_ema30 and price_cross_above_ema30)

// Strong Buy: close cắt lên EMA30 (hoặc EMA6/10) và đóng cửa trên cả 3 EMA
buy_strong_cond  = (price_cross_above_ema6 or price_cross_above_ema10 or price_cross_above_ema30)
                 and above_ema6 and above_ema10 and above_ema30

// Normal Sell: close cắt xuống EMA6 hoặc EMA10, và đóng cửa dưới cả hai
sell_normal_cond = (price_cross_below_ema6 or price_cross_below_ema10)
                 and below_ema6 and below_ema10
                 and not (below_ema6 and below_ema10 and below_ema30 and price_cross_below_ema30)

// Strong Sell: close cắt xuống EMA30 (hoặc EMA6/10) và đóng cửa dưới cả 3 EMA
sell_strong_cond = (price_cross_below_ema6 or price_cross_below_ema10 or price_cross_below_ema30)
                 and below_ema6 and below_ema10 and below_ema30

// ═══════════════════════════════════════════════════════════════
//  PLOT EMA LINES
// ═══════════════════════════════════════════════════════════════
plot(show_ema6  ? ema6  : na, title="EMA 6",  color=color.new(color.yellow, 0), linewidth=1)
plot(show_ema10 ? ema10 : na, title="EMA 10", color=color.new(color.orange, 0), linewidth=1)
plot(show_ema30 ? ema30 : na, title="EMA 30", color=color.new(color.red,    0), linewidth=2)

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
alertcondition(buy_normal_cond,  title="[Normal] BUY Signal",   message="📈 BUY — Giá đóng cửa vượt EMA6 & EMA10")
alertcondition(buy_strong_cond,  title="[STRONG] BUY Signal",   message="🚀 BUY MẠNH — Giá đóng cửa vượt EMA6, EMA10 & EMA30")
alertcondition(sell_normal_cond, title="[Normal] SELL Signal",  message="📉 SELL — Giá đóng cửa xuống dưới EMA6 & EMA10")
alertcondition(sell_strong_cond, title="[STRONG] SELL Signal",  message="🔻 SELL MẠNH — Giá đóng cửa xuống dưới EMA6, EMA10 & EMA30")

//@version=6
plot(close)
````
