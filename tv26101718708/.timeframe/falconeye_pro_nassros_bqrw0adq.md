# FalconEye Pro- NASSROS

- url: https://www.tradingview.com/script/bQrw0AdQ/
- type: indicator
- pine_id: PUB;5e87271b009c4674902d2906846bce78
- version: 1.0

## Description

مؤشر للمساعدة في تحديد الاتجاه وتأكيد الصفقات المؤشر للتجربة ولا يمكن الاعتماد عليه كلياً .

## Source Code

````pine
//@version=5
indicator(" اشارات دخول وخروج - NASSROS", overlay=true, max_lines_count=500)

// ==========================================
// 1. إشارات الشراء والبيع (الزخم والسيولة)
// ==========================================
emaFast = ta.ema(close, 9)
emaSlow = ta.ema(close, 21)
buySignal = ta.crossover(emaFast, emaSlow)
sellSignal = ta.crossunder(emaFast, emaSlow)

plotshape(buySignal, title="إشارة شراء", style=shape.labelup, location=location.belowbar, color=color.green, text="دخول / شراء", textcolor=color.white, size=size.small)
plotshape(sellSignal, title="إشارة بيع", style=shape.labeldown, location=location.abovebar, color=color.red, text="خروج / بيع", textcolor=color.white, size=size.small)

// ==========================================
// 2. خطوط الدعم والمقاومة التلقائية
// ==========================================
var line supLine = na
var line resLine = na

// حساب القمم والقيعان خلال 20 شمعة
highPivot = ta.pivothigh(high, 20, 20)
lowPivot = ta.pivotlow(low, 20, 20)

if not na(highPivot)
    line.delete(resLine)
    resLine := line.new(bar_index[20], highPivot, bar_index, highPivot, color=color.purple, width=2, style=line.style_solid)

if not na(lowPivot)
    line.delete(supLine)
    supLine := line.new(bar_index[20], lowPivot, bar_index, lowPivot, color=color.orange, width=2, style=line.style_solid)

// ==========================================
// 3. لوحة البيانات الجانبية (Dashboard)
// ==========================================
var table dashTable = table.new(position = position.top_right, columns = 2, rows = 5, bgcolor = color.new(color.black, 20), border_width = 1, border_color = color.gray)

// دالة لمعرفة اتجاه السعر في إطار زمني معين
getTrend(res) =>
    o = request.security(syminfo.tickerid, res, open)
    c = request.security(syminfo.tickerid, res, close)
    c >= o ? "صاعد" : "هابط"

if barstate.islast
    // العناوين رئيسية
    table.cell(dashTable, 0, 0, "الإطار الزمني", text_color=color.yellow, text_size=size.small)
    table.cell(dashTable, 1, 0, "الاتجاه العام", text_color=color.yellow, text_size=size.small)
    
    // إطار 5 دقائق
    t_5m = getTrend("5")
    table.cell(dashTable, 0, 1, "5 دقائق", text_color=color.white, text_size=size.small)
    table.cell(dashTable, 1, 1, t_5m, bgcolor = t_5m == "صاعد" ? color.green : color.red, text_color=color.white, text_size=size.small)
    
    // إطار 1 ساعة
    t_1h = getTrend("60")
    table.cell(dashTable, 0, 2, "ساعة واحدة", text_color=color.white, text_size=size.small)
    table.cell(dashTable, 1, 2, t_1h, bgcolor = t_1h == "صاعد" ? color.green : color.red, text_color=color.white, text_size=size.small)
    
    // إطار 4 ساعات
    t_4h = getTrend("240")
    table.cell(dashTable, 0, 3, "4 ساعات", text_color=color.white, text_size=size.small)
    table.cell(dashTable, 1, 3, t_4h, bgcolor = t_4h == "صاعد" ? color.green : color.red, text_color=color.white, text_size=size.small)

    // إطار يومي
    t_1d = getTrend("D")
    table.cell(dashTable, 0, 4, "يومي", text_color=color.white, text_size=size.small)
    table.cell(dashTable, 1, 4, t_1d, bgcolor = t_1d == "صاعد" ? color.green : color.red, text_color=color.white, text_size=size.small)
````
