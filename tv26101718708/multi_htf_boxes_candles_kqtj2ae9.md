# Multi HTF Boxes & Candles

- url: https://www.tradingview.com/script/KqTJ2aE9/
- type: indicator
- pine_id: PUB;ed859bbba1714709a401d2568181020f
- version: 3.0

## Description

Multi HTF Boxes & Candles

سكريبت مخصص لعرض عدة أطر زمنية عليا (HTF) مباشرة على الشارت الحالي، مع إمكانية تخصيص كل إطار زمني بشكل مستقل.

المميزات:
عرض أكثر من HTF بنفس الوقت (مثل 1H و 4H).
رسم HTF Boxes بشكل مباشر على الشارت.
عرض شموع HTF المصغرة على يمين الشارت.
تخصيص كامل لكل HTF بشكل مستقل:
الألوان الصاعدة والهابطة.
لون الـ Midline.
لون حدود الشموع.
نمط الخط (Solid / Dotted / Dashed).
سماكة الحدود.
إظهار أو إخفاء الـ Boxes.
إظهار أو إخفاء شموع HTF.
التحكم بمسافة ظهور الشموع (Start from ahead).
الاستخدام:

يفيد في:

تحليل السيولة والسيكل السعري.
متابعة هيكل السوق متعدد الأطر الزمنية.
تحديد مناطق HTF المهمة بسهولة.
دمج الـ HTF مع التداول اللحظي أو السوينگ.
ملاحظات:
السكريبت يعمل على جميع الأسواق والأطر الزمنية.
يفضل استخدامه مع شاشات واسعة عند تفعيل عدة HTFs.
تم تصميمه ليكون خفيف وسريع بدون جداول أو تنبيهات إضافية.

## Source Code

````pine
//@version=5
indicator("Multi HTF Boxes & Candles - Full", overlay=true, max_boxes_count=500)

//==============================
// HTF 1 Settings
//==============================
show_htf1 = input.bool(true, "Show HTF 1", group="HTF 1", inline="h1")
htf1      = input.timeframe("60", "HTF 1", group="HTF 1", inline="h1")

show_boxes1  = input.bool(true, "Show HTF 1 boxes", group="HTF 1 Style")
width_box1   = input.int(1, "HTF 1 Border Width", minval=1, maxval=5, group="HTF 1 Style")
style_box1   = input.string(line.style_dotted, "HTF 1 Style", options=[line.style_solid, line.style_dotted, line.style_dashed], group="HTF 1 Style")
show_candle1 = input.bool(true, "Show HTF 1 Candle", group="HTF 1 Style")
dx1          = input.int(2, "HTF 1 Start from ahead", group="HTF 1 Style")

bull_box1  = input.color(color.teal, "Bull Box Color", group="HTF 1 Box Colors")
bear_box1  = input.color(color.red, "Bear Box Color", group="HTF 1 Box Colors")
range_box1 = input.color(color.navy, "Range Box Color", group="HTF 1 Box Colors")
mid1       = input.color(color.navy, "Midline Color", group="HTF 1 Box Colors")

bull_candle1  = input.color(color.teal, "Bull Candle Color", group="HTF 1 Candle Colors")
bear_candle1  = input.color(color.red, "Bear Candle Color", group="HTF 1 Candle Colors")
range_candle1 = input.color(color.navy, "Range Candle Color", group="HTF 1 Candle Colors")
border1       = input.color(color.black, "Candle Border Color", group="HTF 1 Candle Colors")

//==============================
// HTF 2 Settings
//==============================
show_htf2 = input.bool(true, "Show HTF 2", group="HTF 2", inline="h2")
htf2      = input.timeframe("240", "HTF 2", group="HTF 2", inline="h2")

show_boxes2  = input.bool(true, "Show HTF 2 boxes", group="HTF 2 Style")
width_box2   = input.int(2, "HTF 2 Border Width", minval=1, maxval=5, group="HTF 2 Style")
style_box2   = input.string(line.style_solid, "HTF 2 Style", options=[line.style_solid, line.style_dotted, line.style_dashed], group="HTF 2 Style")
show_candle2 = input.bool(true, "Show HTF 2 Candle", group="HTF 2 Style")
dx2          = input.int(17, "HTF 2 Start from ahead", group="HTF 2 Style")

bull_box2  = input.color(color.green, "Bull Box Color", group="HTF 2 Box Colors")
bear_box2  = input.color(color.orange, "Bear Box Color", group="HTF 2 Box Colors")
range_box2 = input.color(color.blue, "Range Box Color", group="HTF 2 Box Colors")
mid2       = input.color(color.gray, "Midline Color", group="HTF 2 Box Colors")

bull_candle2  = input.color(color.green, "Bull Candle Color", group="HTF 2 Candle Colors")
bear_candle2  = input.color(color.orange, "Bear Candle Color", group="HTF 2 Candle Colors")
range_candle2 = input.color(color.blue, "Range Candle Color", group="HTF 2 Candle Colors")
border2       = input.color(color.black, "Candle Border Color", group="HTF 2 Candle Colors")

//==============================
// Functions
//==============================
f_text(string _tf) =>
    _n = str.tonumber(_tf)
    _text = not na(_n) and _n < 60 ? _tf + "m" :
         not na(_n) and _n >= 60 ? "h" + str.tostring(math.floor(_n / 60)) : _tf
    _text := _tf == "1D" ? "D" : _tf == "1W" ? "W" : _tf == "1M" ? "M" : _text
    _text

get_color(_o, _c, _bull, _bear, _range) =>
    _c > _o ? _bull : _c < _o ? _bear : _range

f_tfcon(_htf) =>
    timeframe.in_seconds(_htf) >= timeframe.in_seconds(timeframe.period)

f_live_htf(_htf) =>
    var float o0 = open
    var float h0 = high
    var float l0 = low
    var float c0 = close
    var int   t0 = time

    var float o1 = open
    var float h1 = high
    var float l1 = low
    var float c1 = close
    var int   t1 = time

    var float o2 = open
    var float h2 = high
    var float l2 = low
    var float c2 = close

    var float o3 = open
    var float h3 = high
    var float l3 = low
    var float c3 = close

    var float o4 = open
    var float h4 = high
    var float l4 = low
    var float c4 = close

    var float o5 = open
    var float h5 = high
    var float l5 = low
    var float c5 = close

    if timeframe.change(_htf)
        o5 := o4
        h5 := h4
        l5 := l4
        c5 := c4

        o4 := o3
        h4 := h3
        l4 := l3
        c4 := c3

        o3 := o2
        h3 := h2
        l3 := l2
        c3 := c2

        o2 := o1
        h2 := h1
        l2 := l1
        c2 := c1

        o1 := o0
        h1 := h0
        l1 := l0
        c1 := c0
        t1 := t0

        o0 := open
        h0 := high
        l0 := low
        t0 := time

    h0 := math.max(h0, high)
    l0 := math.min(l0, low)
    c0 := close

    [o0, h0, l0, c0, t0,
     o1, h1, l1, c1, t1,
     o2, h2, l2, c2,
     o3, h3, l3, c3,
     o4, h4, l4, c4,
     o5, h5, l5, c5]

//==============================
// Draw Candle
//==============================
draw_candle(_x, _o, _h, _l, _c, _tf, _bull_candle, _bear_candle, _range_candle, _border) =>
    b = box.new(_x, _c, _x + 2, _o,
         bgcolor=get_color(_o, _c, _bull_candle, _bear_candle, _range_candle),
         border_color=_border,
         text=f_text(_tf),
         text_size=size.tiny,
         text_color=color.white)

    u = box.new(_x + 1, _h, _x + 1, math.max(_o, _c), border_color=_border)
    d = box.new(_x + 1, _l, _x + 1, math.min(_o, _c), border_color=_border)

    box.delete(b[1])
    box.delete(u[1])
    box.delete(d[1])

//==============================
// Draw Function
//==============================
draw_htf(_show, _htf,
          _bull_box, _bear_box, _range_box, _mid,
          _bull_candle, _bear_candle, _range_candle, _border,
          _show_boxes, _width_box, _style_box,
          _show_candle, _dx, _count) =>

    [o0, h0, l0, c0, t0,
     o1, h1, l1, c1, t1,
     o2, h2, l2, c2,
     o3, h3, l3, c3,
     o4, h4, l4, c4,
     o5, h5, l5, c5] = f_live_htf(_htf)

    dtx = timeframe.in_seconds(_htf) * 1000

    // Boxes
    if _show and _show_boxes and f_tfcon(_htf) and timeframe.period != _htf

        if timeframe.change(_htf)
            old_color = get_color(o1, c1, _bull_box, _bear_box, _range_box)

            box.new(
                 left=t1,
                 top=h1,
                 right=t0,
                 bottom=l1,
                 xloc=xloc.bar_time,
                 border_width=_width_box,
                 border_style=_style_box,
                 bgcolor=color.rgb(255,255,255,100),
                 border_color=old_color)

            mid_box = box.new(
                 left=t1,
                 top=(h1 + l1) / 2,
                 right=t0 + dtx,
                 bottom=(h1 + l1) / 2,
                 xloc=xloc.bar_time,
                 border_width=_width_box,
                 border_style=line.style_dotted,
                 bgcolor=color.rgb(255,255,255,100),
                 border_color=_mid)

            box.delete(mid_box[1])

        live_color = get_color(o0, c0, _bull_box, _bear_box, _range_box)

        live_box = box.new(
             left=t0,
             top=h0,
             right=time + 1,
             bottom=l0,
             xloc=xloc.bar_time,
             border_width=_width_box,
             border_style=_style_box,
             bgcolor=color.rgb(255,255,255,100),
             border_color=live_color)

        box.delete(live_box[1])

    // Candles
    if _show and _show_candle and barstate.islast

        x = bar_index + _dx

        if _count >= 6
            draw_candle(x - 6, o5, h5, l5, c5, _htf, _bull_candle, _bear_candle, _range_candle, _border)

        if _count >= 5
            draw_candle(x - 3, o4, h4, l4, c4, _htf, _bull_candle, _bear_candle, _range_candle, _border)

        if _count >= 4
            draw_candle(x, o3, h3, l3, c3, _htf, _bull_candle, _bear_candle, _range_candle, _border)

        if _count >= 3
            draw_candle(x + 3, o2, h2, l2, c2, _htf, _bull_candle, _bear_candle, _range_candle, _border)

        if _count >= 2
            draw_candle(x + 6, o1, h1, l1, c1, _htf, _bull_candle, _bear_candle, _range_candle, _border)

        if _count >= 1
            draw_candle(x + 9, o0, h0, l0, c0, _htf, _bull_candle, _bear_candle, _range_candle, _border)

//==============================
// Draw HTFs
//==============================
draw_htf(show_htf1, htf1,
          bull_box1, bear_box1, range_box1, mid1,
          bull_candle1, bear_candle1, range_candle1, border1,
          show_boxes1, width_box1, style_box1,
          show_candle1, dx1, 6)

draw_htf(show_htf2, htf2,
          bull_box2, bear_box2, range_box2, mid2,
          bull_candle2, bear_candle2, range_candle2, border2,
          show_boxes2, width_box2, style_box2,
          show_candle2, dx2, 6)
````
