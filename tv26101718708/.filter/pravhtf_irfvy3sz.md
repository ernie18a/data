# Prav_HTF

- url: https://www.tradingview.com/script/IRfvY3sZ-Prav-HTF/
- type: indicator
- pine_id: PUB;dcce4a7c92b14928865a12f474443dc4
- version: 1.0

## Description

This indicator is a live Higher Timeframe (HTF) candle projection tool for TradingView designed mainly for 5-minute traders.

It displays:

completed HTF candles
the currently forming live HTF candle
on the right side of the chart

without changing your main chart timeframe

## Source Code

````pine
//@version=5
indicator("Prav_HTF", overlay=true,
     max_boxes_count=500,
     max_lines_count=500)

// =====================================================
// SHOW ONLY ON 5M
// =====================================================
is5M =
     timeframe.period == "5"

// =====================================================
// SETTINGS
// =====================================================
htf =
     input.timeframe("60", "Higher Timeframe")

bullColor =
     input.color(
          color.new(color.green, 10),
          "Bull Candle")

bearColor =
     input.color(
          color.new(color.black, 0),
          "Bear Candle")

wickColor =
     input.color(
          color.gray,
          "Wick Color")

spacing =
     input.int(5, "Spacing")

bodyWidth =
     input.int(2, "Body Width")

rightOffset =
     input.int(8, "Right Offset")

candlesToShow =
     input.int(
          4,
          "Completed Candles",
          minval=1,
          maxval=10)

// =====================================================
// HTF DATA
// =====================================================
o =
     request.security(
          syminfo.tickerid,
          htf,
          open)

h =
     request.security(
          syminfo.tickerid,
          htf,
          high)

l =
     request.security(
          syminfo.tickerid,
          htf,
          low)

c =
     request.security(
          syminfo.tickerid,
          htf,
          close)

htfTime =
     request.security(
          syminfo.tickerid,
          htf,
          time)

// Detect new HTF candle
newHTF =
     ta.change(htfTime)

// =====================================================
// STORAGE ARRAYS
// =====================================================
var float[] opens =
     array.new_float()

var float[] highs =
     array.new_float()

var float[] lows =
     array.new_float()

var float[] closes =
     array.new_float()

// =====================================================
// SAVE COMPLETED HTF CANDLES
// =====================================================
if newHTF

    array.push(opens, o[1])
    array.push(highs, h[1])
    array.push(lows, l[1])
    array.push(closes, c[1])

// Keep only latest candles
if array.size(opens) > candlesToShow

    array.shift(opens)
    array.shift(highs)
    array.shift(lows)
    array.shift(closes)

// =====================================================
// DRAWING STORAGE
// =====================================================
var box[] candleBodies =
     array.new_box()

var line[] candleWicks =
     array.new_line()

// =====================================================
// DRAW
// =====================================================
if barstate.islast and is5M

    // Delete old drawings
    for b in candleBodies
        box.delete(b)

    for lnn in candleWicks
        line.delete(lnn)

    array.clear(candleBodies)
    array.clear(candleWicks)

    // =================================================
    // DRAW COMPLETED CANDLES
    // =================================================
    total =
         array.size(opens)

    for i = 0 to total - 1

        oo =
             array.get(opens, i)

        hh =
             array.get(highs, i)

        ll =
             array.get(lows, i)

        cc =
             array.get(closes, i)

        x =
             bar_index +
             rightOffset +
             (i * spacing)

        candleColor =
             cc >= oo
             ? bullColor
             : bearColor

        // =============================================
        // UPPER WICK
        // =============================================
        upperWick =
             line.new(
                  x1=x,
                  y1=hh,
                  x2=x,
                  y2=math.max(oo, cc),
                  color=wickColor,
                  width=1)

        array.push(
             candleWicks,
             upperWick)

        // =============================================
        // LOWER WICK
        // =============================================
        lowerWick =
             line.new(
                  x1=x,
                  y1=ll,
                  x2=x,
                  y2=math.min(oo, cc),
                  color=wickColor,
                  width=1)

        array.push(
             candleWicks,
             lowerWick)

        // =============================================
        // BODY
        // =============================================
        body =
             box.new(
                  left=x - bodyWidth,
                  right=x + bodyWidth,
                  top=math.max(oo, cc),
                  bottom=math.min(oo, cc),
                  bgcolor=candleColor,
                  border_color=color.black)

        array.push(
             candleBodies,
             body)

    // =================================================
    // LIVE CURRENT HTF CANDLE
    // =================================================
    liveX =
         bar_index +
         rightOffset +
         (total * spacing)

    liveColor =
         c >= o
         ? bullColor
         : bearColor

    // =============================================
    // LIVE UPPER WICK
    // =============================================
    liveUpperWick =
         line.new(
              x1=liveX,
              y1=h,
              x2=liveX,
              y2=math.max(o, c),
              color=wickColor,
              width=1)

    array.push(
         candleWicks,
         liveUpperWick)

    // =============================================
    // LIVE LOWER WICK
    // =============================================
    liveLowerWick =
         line.new(
              x1=liveX,
              y1=l,
              x2=liveX,
              y2=math.min(o, c),
              color=wickColor,
              width=1)

    array.push(
         candleWicks,
         liveLowerWick)

    // =============================================
    // LIVE BODY
    // =============================================
    liveBody =
         box.new(
              left=liveX - bodyWidth,
              right=liveX + bodyWidth,
              top=math.max(o, c),
              bottom=math.min(o, c),
              bgcolor=liveColor,
              border_color=color.black)

    array.push(
         candleBodies,
         liveBody)
````
