# Tawfiq_Hamidah - SAR

- url: https://www.tradingview.com/script/0xc9cEXN/
- type: indicator
- pine_id: PUB;7d6c1ec2ea384a0799ebdffaaebf88bd
- version: 6.0

## Description

https://www.tradingview.com/x/XiqYKFsp/
The advanced SAR indicator accurately provides trend reversal signals, calculates liquidity, and includes other indicators.

مؤشر مطور ذكي SAR يعطي اشارات تحول الاتجاه بطريقة صحيحة حساب السيولة وغيرها من المؤشرات

## Source Code

````pine
//@version=5
indicator("Tawfiq_Hamidah & SAR + trend ", overlay=true, max_boxes_count=500)

// --- 1. إعدادات مؤشر SAR (دوائر ملونة) ---
psar = ta.sar(0.02, 0.02, 0.2)
// تحديد اللون: أخضر إذا كان تحت السعر (صعود) وأحمر إذا كان فوق السعر (هبوط)
sar_color = psar < close ? color.green : color.red
// رسم SAR كدوائر (Circles) بدلاً من علامات X
plot(psar, "SAR Dots", style=plot.style_circles, color=sar_color, linewidth=2)

// --- 2. إعدادات مؤشر SuperTrend ---
[st_value, st_direction] = ta.supertrend(3, 10)
plot(st_value, "SuperTrend", color = st_direction == -1 ? color.new(color.green, 50) : color.new(color.red, 50), linewidth=2)

// --- 3. منطق إشارة الشراء (BUY) ---
// تقاطع SAR صاعد + السوبر ترند أخضر
buy_signal = ta.crossover(close, psar) and (st_direction == -1)

// --- 4. الرسم على الشارت ---
plotshape(buy_signal, title="BUY", style=shape.labelup, location=location.belowbar, color=color.new(color.green, 0), text="BUY", textcolor=color.black, size=size.small)

// --- 5. الجدول الرقمي للمتابعة ---
rv = ta.rsi(close, 14)
e200 = ta.ema(close, 200)
var table dash = table.new(position.top_right, 2, 4, bgcolor=color.new(color.black, 20), border_width=1)
if barstate.islast
    table.cell(dash, 0, 0, "المؤشر", text_color=color.white, bgcolor=color.gray)
    table.cell(dash, 1, 0, "الحالة", text_color=color.white, bgcolor=color.gray)
    
    table.cell(dash, 0, 1, "Trend Status", text_color=color.white)
    table.cell(dash, 1, 1, st_direction == -1 ? "BULLISH" : "BEARISH", bgcolor=st_direction == -1 ? color.green : color.red)

    table.cell(dash, 0, 2, "RSI Value", text_color=color.white)
    table.cell(dash, 1, 2, str.tostring(math.round(rv, 1)), bgcolor=rv > 50 ? color.green : color.orange)

    table.cell(dash, 0, 3, "Above EMA 200", text_color=color.white)
    table.cell(dash, 1, 3, close > e200 ? "YES" : "NO", bgcolor=close > e200 ? color.green : color.red)

mtf_val = input.timeframe('', 'Resolution', inline="config", group="Algorithm Config")
source = input.source(close, inline="config", group="Algorithm Config")
length = input.int(100, minval=1, inline="config1", group="Algorithm Config")
dev = input(2.0, 'Deviation', inline="config1", group="Algorithm Config")
offset = input.int(0, minval=0, inline="config2", group="Algorithm Config")
smoothing = input.int(1, minval=1, inline="config2", group="Algorithm Config")


line_thick = input.int(4, 'S&R Size', minval=1, maxval=4, inline="levels", group="Display Config")
show_last = input.bool(true, "Hide Old Signals", group="Display Config")
p = input.color(color.lime, "Up", inline="colors", group="Display Config")
q = input.color(color.red, "Down", inline="colors", group="Display Config")
displacement = input.bool(false, "Show Displacement")
goto = input.time(timestamp("20 Jul 2050 00:00 +0300"), "End Of Calculating")

data(x) =>
    ta.sma(request.security(syminfo.tickerid, mtf_val != '' ? mtf_val : timeframe.period, x), smoothing)

linreg = data(ta.linreg(source, length, offset))
linreg_p = data(ta.linreg(source, length, offset + 1))
plot(linreg, 'Regression Line', linreg > linreg[1] ? p : q, editable=true)

x = bar_index
slope = linreg - linreg_p
intercept = linreg - x * slope
deviationSum = 0.0
for i = 0 to length - 1 by 1
    deviationSum += math.pow(source[i] - (slope * (x - i) + intercept), 2)
    deviationSum
deviation = math.sqrt(deviationSum / length)
x1 = x - length
x2 = x
y1 = slope * (x - length) + intercept
y2 = linreg

var line b = na
var line dp = na
var line dm = na

updating = goto >= time

if updating
    b := line.new(x1, y1, x2, y2, xloc.bar_index, extend.right, color.aqua, width=line_thick)
    if not displacement
        line.delete(b[1])
    dp := line.new(x1, deviation * dev + y1, x2, deviation * dev + y2, xloc.bar_index, extend.right, q, width=line_thick)
    if not displacement
        line.delete(dp[1])
    dm := line.new(x1, -deviation * dev + y1, x2, -deviation * dev + y2, xloc.bar_index, extend.right, p, width=line_thick)
    if not displacement
        line.delete(dm[1])

dm_current = -deviation * dev + y2
dp_current = deviation * dev + y2
buy = ta.crossunder(close, dm_current)
sell = ta.crossover(close, dp_current)
alertcondition(buy, 'Buy Lin Reg', 'Crossing On the Lower Regression Channel')
alertcondition(sell, 'Sell Lin Reg', 'Crossing On the Higher Regression Channel')

plotshape(buy, 'BUY', shape.labelup, location.belowbar, color.new(color.lime, 0), text='BUY', textcolor=color.new(color.black, 0), show_last=not show_last? 99999999 : length)
plotshape(sell, 'SELL', shape.labeldown, location.abovebar, color.new(color.red, 0), text='SELL', textcolor=color.new(color.white, 0), show_last=not show_last ? 99999999 : length)
````
