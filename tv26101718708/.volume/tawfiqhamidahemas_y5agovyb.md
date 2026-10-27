# TAWFIQ_HAMIDAH_EMAS 

- url: https://www.tradingview.com/script/y5AgOvyb/
- type: indicator
- pine_id: PUB;05fc8878aa814fafb55eb973710a2a4c
- version: 2.0

## Description

https://www.tradingview.com/x/NRfbyuow/
The indicator works when the 5, 9, 13, 21, and 200 EMAs are rearranged and a breakout point is reached, along with supporting indicators (ADX, RSI, Stochastic, and Anoor). It provides buy and sell signals, in addition to a box that shows the stock's status, including news, trend, and momentum.
يعمل المؤشر عند رجوع ترتيب المتوسطات 5 + 9+13+21+200 EMAs و نقطة انفجار السهم مع اضافة مؤشرات داعمة ADX) RSI, Stoch, Anoor) يعطي اشارة الشراء والبيع با ضافة الى صندوق يعطيك حالة السهم من اخبار و الاتجاه والزخم

## Source Code

````pine
//@version=5
indicator("TAWFIQ_HAMIDAH_TG_V2", shorttitle="TAWFIQ_V2", overlay=true)

// --- 1. الألوان والثوابت ---
c_green = #4caf50, c_red = #f44336, c_white = #ffffff, c_gray = #9e9e9e

// --- 2. المتوسطات (The Wave) ---
ema5   = ta.ema(close, 5)
ema9   = ta.ema(close, 9)
ema13  = ta.ema(close, 13)
ema21  = ta.ema(close, 21)
ema200 = ta.ema(close, 200)

plot(ema5, "EMA 5", color=c_red)
plot(ema9, "EMA 9", color=c_green)
plot(ema13, "EMA 13", color=color.rgb(35, 135, 216))
plot(ema21, "EMA 21", color=color.yellow)
plot(ema200, "EMA 200", color=c_white, linewidth=2)

// --- 3. السيولة والفلاتر ---
v_mfi = ta.mfi(close, 14)
mfi_ok = v_mfi > 50
[_, _, v_adx] = ta.dmi(14, 14)
v_rsi = ta.rsi(close, 14)
k = ta.stoch(close, high, low, 14)
ac = (ta.sma(hl2, 5) - ta.sma(hl2, 34)) - ta.sma(ta.sma(hl2, 5) - ta.sma(hl2, 34), 5)
v_atr = ta.atr(14)

// --- 4. فلتر "الارتفاع المفرط" (الابتعاد عن المتوسط) ---
// نحسب المسافة بين السعر ومتوسط 21. إذا زادت عن 2% (أو 1.5 ضعف الـ ATR) نعتبرها خطرة
dist_from_ema = (close - ema21) / ema21
too_high = dist_from_ema > 0.02 // منع الشراء إذا ارتفع السعر أكثر من 2% عن المتوسط
too_low  = dist_from_ema < -0.02 // منع البيع إذا انخفض السعر أكثر من 2% عن المتوسط

// --- 5. منطق الإشارات المطور ---
ema_stack_bull = ema5 > ema9 and ema9 > ema13 and ema13 > ema21
ema_stack_bear = ema5 < ema9 and ema9 < ema13 and ema13 < ema21

// شرط الشراء: تقاطع + فوق 200 + سيولة + ليس مرتفعاً جداً
buy_sig  = ta.crossover(ema5, ema9) and close > ema200 and ema_stack_bull and mfi_ok and ac > ac[1] and not too_high
// شرط البيع: تقاطع + تحت 200 + ضعف سيولة + ليس منخفضاً جداً
sell_sig = ta.crossunder(ema5, ema9) and close < ema200 and ema_stack_bear and not mfi_ok and ac < ac[1] and not too_low

plotshape(buy_sig, "BUY", shape.labelup, location.belowbar, c_green, size=size.small, text="BUY", textcolor=c_white)
plotshape(sell_sig, "SELL", shape.labeldown, location.abovebar, c_red, size=size.small, text="SELL", textcolor=c_white)

// --- 6. الجدول المعلوماتي المحدث ---
var table board = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 20), border_width=1, border_color=c_gray)
if barstate.islast
    table.cell(board, 0, 0, "Money Flow (MFI)", text_color=c_white)
    table.cell(board, 1, 0, str.tostring(math.round(v_mfi)), text_color=(mfi_ok ? c_green : c_red))
    table.cell(board, 0, 1, "ADX Power", text_color=c_white)
    table.cell(board, 1, 1, str.tostring(math.round(v_adx)), text_color=(v_adx > 25 ? c_green : c_red))
    table.cell(board, 0, 2, "Entry Risk", text_color=c_white)
    table.cell(board, 1, 2, too_high or too_low ? "HIGH (Stay Out)" : "LOW (Safe)", text_color=(too_high or too_low ? c_red : c_green))
    table.cell(board, 0, 3, "RSI %", text_color=c_white)
    table.cell(board, 1, 3, str.tostring(math.round(v_rsi)), text_color=(v_rsi > 50 ? c_green : c_red))
    table.cell(board, 0, 4, "Wave Order", text_color=c_white)
    table.cell(board, 1, 4, (ema_stack_bull or ema_stack_bear ? "READY" : "WAIT"), text_color=(ema_stack_bull or ema_stack_bear ? c_green : color.orange))
````
