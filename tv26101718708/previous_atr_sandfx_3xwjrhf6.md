# Previous ATR SandFx

- url: https://www.tradingview.com/script/3XWJrHf6-Previous-ATR-SandFx/
- type: indicator
- pine_id: PUB;645979dc4dd04dd48c90bc485365e4c9
- version: 1.0

## Description

📊 Previous ATR Clean Indicator

Previous ATR Clean is a simple indicator designed to monitor market volatility changes by comparing the current candle ATR (Current ATR) with the previous candle ATR (Previous ATR). ATR (Average True Range) measures the size of price movement, not the direction of the trend. This indicator helps traders identify whether the market is experiencing volatility expansion (increasing movement) or volatility contraction (decreasing movement).

Current ATR shows the current market volatility condition. Previous ATR shows the volatility from the previous candle as a comparison. Delta ATR represents the difference between them:

Delta = Current ATR - Previous ATR

If Delta is positive (+), it means ATR is increasing → candle range is expanding → the market is gaining energy and momentum. This condition often appears during breakouts or when a trend starts developing.

If Delta is negative (-), it means ATR is decreasing → candle range is shrinking → the market is losing energy or entering a consolidation phase.

This indicator can be used to:
✅ Identify whether the market is active or slow
✅ Measure breakout strength
✅ Avoid entries during low volatility conditions
✅ Adjust stop loss and target distance based on market conditions

Example:

Current ATR: 3.50
Previous ATR: 2.80
Delta: +0.70

Meaning: volatility is increasing and the market is expanding.

Current ATR: 2.50
Previous ATR: 3.20
Delta: -0.70

Meaning: volatility is decreasing and the market is slowing down.

ATR does not provide buy or sell signals. It helps traders understand market energy and volatility conditions. Combine it with other analysis tools such as market structure, support & resistance, volume, or trend direction for better trading decisions.

Trade with volatility, not against it. 📈

## Source Code

````pine
//@version=6
indicator("Previous ATR SandFx", overlay=true)


// ===== INPUT =====

length = input.int(14, "Length", minval=1)

smoothing = input.string(
     "RMA",
     "Smoothing",
     options=["RMA","SMA","EMA","WMA"])


tf = input.timeframe(
     "",
     "Custom Timeframe")


positionOpt = input.string(
     "Top Right",
     "Text Position",
     options=[
     "Top Left",
     "Top Center",
     "Top Right",
     "Middle Left",
     "Middle Center",
     "Middle Right",
     "Bottom Left",
     "Bottom Center",
     "Bottom Right"
     ])


// ===== POSITION =====

pos =
     positionOpt == "Top Left" ? position.top_left :
     positionOpt == "Top Center" ? position.top_center :
     positionOpt == "Top Right" ? position.top_right :
     positionOpt == "Middle Left" ? position.middle_left :
     positionOpt == "Middle Center" ? position.middle_center :
     positionOpt == "Middle Right" ? position.middle_right :
     positionOpt == "Bottom Left" ? position.bottom_left :
     positionOpt == "Bottom Center" ? position.bottom_center :
     position.bottom_right



// ===== MA FUNCTION =====

ma_function(source, length)=>

    switch smoothing
        "RMA" => ta.rma(source,length)
        "SMA" => ta.sma(source,length)
        "EMA" => ta.ema(source,length)
        => ta.wma(source,length)



// ===== ATR =====

atr_calc() =>
    ma_function(ta.tr(true),length)



// ===== ATR CURRENT =====

atr_now =
     tf == "" ?
     atr_calc() :
     request.security(
      syminfo.tickerid,
      tf,
      atr_calc())


// previous candle

atr_prev = atr_now[1]


delta = atr_now - atr_prev



tfLabel =
     tf == "" ?
     timeframe.period :
     tf



// ===== TEXT =====

atrText =
 "ATR ("+tfLabel+")\n\n" +
 "Current  : " +
 str.tostring(
  atr_now,
  format.mintick) +

 "\nPrevious : " +
 str.tostring(
  atr_prev,
  format.mintick) +

 "\nDelta    : " +
 str.tostring(
  delta,
  format.mintick)



// ===== TABLE OFFSET =====

var table atrTable =
 table.new(
  pos,
  1,
  3)



// ===== UPDATE =====

if barstate.islast


    // spacing supaya turun
    table.cell(
     atrTable,
     0,
     0,
     "",
     bgcolor=color.new(color.black,100))


    table.cell(
     atrTable,
     0,
     1,
     "",
     bgcolor=color.new(color.black,100))


    table.cell(
     atrTable,
     0,
     2,
     atrText,
     text_color=color.white,
     bgcolor=color.new(color.black,100),
     text_size=size.normal)
````
