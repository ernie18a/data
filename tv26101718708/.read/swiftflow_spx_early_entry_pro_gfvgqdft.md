# SwiftFlow SPX Early Entry PRO

- url: https://www.tradingview.com/script/GfvgQDfT/
- type: indicator
- pine_id: PUB;9a8f2d1942fc4f398ce5b35528cd211d
- version: 1.0

## Description

تحليل يومي لمؤشر S&P 500 باستخدام مؤشر SwiftFlow SPX Early Entry PRO . يعتمد المؤشر على تحليل الزخم والاتجاه لتحديد فرص CALL و PUT بدقة عالية. هذا التحليل لأغراض تعليمية فقط وليس توصية مالية.

## Source Code

````pine
//@version=6
indicator("SwiftFlow SPX Early Entry PRO", overlay=true, max_bars_back=500)

// ===== الإعدادات =====
cci_len    = input.int(20, "CCI Length")
adx_len    = input.int(14, "ADX Length")
adx_thresh = input.float(20, "ADX Threshold")
bb_len     = input.int(20, "BB Length")
bb_mult    = input.float(1.8, "BB Multiplier")
obv_ma_len = input.int(14, "OBV MA Length")
min_score  = input.int(3, "الحد الأدنى للإشارة", minval=2, maxval=5)
reset_bars = input.int(8, "إعادة التشغيل بعد عدد الشموع")

// ===== Order Flow =====
candle_mid = (high + low) / 2

orderflow_bull = close > candle_mid
orderflow_bear = close < candle_mid

// ===== Bollinger Bands =====
[bb_mid, bb_up, bb_dn] = ta.bb(close, bb_len, bb_mult)

bb_bull = close > bb_mid
bb_bear = close < bb_mid

// ===== CCI =====
cci_val = ta.cci(close, cci_len)

cci_bull = cci_val > 80
cci_bear = cci_val < -80

// ===== OBV =====
obv_val = ta.obv
obv_ma = ta.sma(obv_val, obv_ma_len)

obv_bull = obv_val > obv_ma
obv_bear = obv_val < obv_ma

// ===== ADX =====
[di_plus, di_minus, adx_val] = ta.dmi(adx_len, adx_len)

adx_ok = adx_val >= adx_thresh

trend_up = di_plus > di_minus
trend_dn = di_minus > di_plus

// ===== EMA =====
ema21 = ta.ema(close, 21)
ema9  = ta.ema(close, 9)

ema_bull = close > ema21
ema_bear = close < ema21

fast_bull = ema9 > ema21
fast_bear = ema9 < ema21

// ===== السكور =====
buy_score = (orderflow_bull ? 1 : 0) + (bb_bull ? 1 : 0) + (cci_bull ? 1 : 0) + (obv_bull ? 1 : 0) + (trend_up ? 1 : 0)

sell_score = (orderflow_bear ? 1 : 0) + (bb_bear ? 1 : 0) + (cci_bear ? 1 : 0) + (obv_bear ? 1 : 0) + (trend_dn ? 1 : 0)

// ===== الإشارات =====
buy_signal = buy_score >= min_score and adx_ok and ema_bull and fast_bull

sell_signal = sell_score >= min_score and adx_ok and ema_bear and fast_bear

// ===== منع التكرار =====
var int last_signal = 0
var int bars_since_sig = 0

if last_signal != 0
    bars_since_sig += 1

if bars_since_sig >= reset_bars
    last_signal := 0
    bars_since_sig := 0

no_repeat_buy = buy_signal and last_signal != 1
no_repeat_sell = sell_signal and last_signal != -1

if no_repeat_buy
    last_signal := 1
    bars_since_sig := 0

if no_repeat_sell
    last_signal := -1
    bars_since_sig := 0

// ===== الخلفية =====
bgcolor(no_repeat_buy ? color.new(color.green, 85) : na)
bgcolor(no_repeat_sell ? color.new(color.red, 85) : na)

// ===== الأسهم =====
plotshape(no_repeat_buy,
     title="CALL",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.lime,
     size=size.large)

plotshape(no_repeat_sell,
     title="PUT",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.large)

// ===== الحروف =====
plotchar(no_repeat_buy,
     title="CALL Label",
     char="C",
     location=location.belowbar,
     color=color.white)

plotchar(no_repeat_sell,
     title="PUT Label",
     char="P",
     location=location.abovebar,
     color=color.white)

// ===== المتوسطات =====
plot(ema21, "EMA 21", color=color.orange, linewidth=2)
plot(ema9, "EMA 9", color=color.yellow, linewidth=1)

plot(bb_up, "BB Upper", color=color.new(color.purple, 80))
plot(bb_dn, "BB Lower", color=color.new(color.purple, 80))
plot(bb_mid, "BB Mid", color=color.new(color.gray, 85))

// ===== التنبيهات =====
alertcondition(
     no_repeat_buy,
     title="SwiftFlow BUY CALL",
     message='{"direction":"CALL","price":"{{close}}"}')

alertcondition(
     no_repeat_sell,
     title="SwiftFlow BUY PUT",
     message='{"direction":"PUT","price":"{{close}}"}')
````
