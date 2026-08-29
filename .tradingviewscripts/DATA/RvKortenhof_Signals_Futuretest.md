<!-- tradingview-pine-id: PUB;84d953cd74b245aead4d8cd8aa4c35a6 -->
<!-- tradingviewscripts-format: 1 -->
# RvKortenhof - Signals + Futuretest

Source: https://www.tradingview.com/script/nDheqnFF-RvKortenhof-Signals-Futuretest/

## Description

RvKortenhof

RvKortenhof is a market regime and signal indicator based on the principles of RSI range analysis developed by Rick.

Historical Trade Tracking & Backtesting
When the indicator is applied to the chart, all new signals from that moment forward are automatically tracked and remain visible. This allows traders to review future setups, analyze trade performance, and perform a realistic visual backtest without displaying previous historical signals from before the indicator was activated.

Unlike traditional RSI overbought and oversold interpretations, this indicator focuses on identifying bullish and bearish RSI ranges combined with trend direction to detect stronger market conditions and potential trading opportunities.

Key Features

✅ RSI
Identifies bullish and bearish market regimes by analyzing RSI behavior within configurable ranges.

✅ Trend Confirmation
Uses a moving average trend filter to determine whether market conditions support bullish or bearish setups.

✅ Signal Generation
Provides BUY and SELL signals when a new market regime is confirmed, helping traders identify potential entry opportunities.

✅ Multi-Timeframe Confirmation
Optional higher timeframe confirmation can be enabled to improve signal quality and align trades with broader market direction.

✅ Market Condition Filter
Optional ADX-based filtering helps avoid weaker market conditions with insufficient momentum.

✅ Risk Management Tools
Automatically displays:

- Entry level
- Stop Loss level
- TP1, TP2 & TP3

with configurable ATR-based risk/reward calculations.

✅ Trade Visualization
When enabled, every new signal can remain visible on the chart with complete trade structure, including risk and reward zones.

✅ Performance Dashboard
The integrated dashboard provides important market information including:

- Current market regime
- RSI value
- Trend direction
- ATR value
- Number of tracked trades
- Wins and losses
- Win rate
- How It Works

The indicator combines RSI range analysis with trend confirmation:

Bullish conditions are identified when price is in an uptrend and RSI remains within a defined bullish range.
Bearish conditions are identified when price is in a downtrend and RSI remains within a defined bearish range.
Signals are generated when a confirmed regime transition occurs.

The goal is to help traders recognize market structure changes and avoid relying solely on traditional RSI extremes.

Recommended Usage

This indicator can be used for:

- Intraday trading
- Swing trading
- Trend-following strategies
- Market regime analysis

Best results are generally achieved when combined with proper risk management and additional market analysis.

Disclaimer

This indicator is a technical analysis tool and should not be considered financial advice. Trading involves risk, and users should always perform their own analysis before making trading decisions.

© RvKortenhof

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// © MarkitTick

//@version=6
indicator(
     "RvKortenhof - Signals + Futuretest",
     overlay=true,
     max_labels_count=500,
     max_lines_count=500,
     max_boxes_count=500)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


// CORE SETTINGS

var string GRP_CORE = "⚙️ Core Settings"

i_rsiLen =
     input.int(
          14,
          "RSI Length",
          minval=1,
          group=GRP_CORE)


i_rsiSrc =
     input.source(
          close,
          "Source",
          group=GRP_CORE)


i_trendLen =
     input.int(
          50,
          "Trend MA Length",
          minval=1,
          group=GRP_CORE)


i_trendSrc =
     input.source(
          close,
          "Trend Source",
          group=GRP_CORE)



// FILTERS

var string GRP_FILT = "🕯️ Filters"


i_bullLo =
     input.int(
          40,
          "Bull Range Low",
          minval=0,
          maxval=100,
          group=GRP_FILT)


i_bullHi =
     input.int(
          80,
          "Bull Range High",
          minval=0,
          maxval=100,
          group=GRP_FILT)


i_bearLo =
     input.int(
          20,
          "Bear Range Low",
          minval=0,
          maxval=100,
          group=GRP_FILT)


i_bearHi =
     input.int(
          60,
          "Bear Range High",
          minval=0,
          maxval=100,
          group=GRP_FILT)


i_confirmBars =
     input.int(
          2,
          "Regime Confirm Bars",
          minval=1,
          group=GRP_FILT)


i_useHtf =
     input.bool(
          false,
          "Use HTF Confirmation",
          group=GRP_FILT)


i_htfTF =
     input.timeframe(
          "240",
          "HTF Timeframe",
          group=GRP_FILT)


i_useAdx =
     input.bool(
          false,
          "Use Chop Filter",
          group=GRP_FILT)


i_adxLen =
     input.int(
          14,
          "ADX Length",
          minval=1,
          group=GRP_FILT)


i_adxMin =
     input.int(
          20,
          "ADX Min Strength",
          minval=0,
          maxval=100,
          group=GRP_FILT)



// TRADE SETTINGS

var string GRP_TRADE = "📐 Trade Tools"


i_atrLen =
     input.int(
          14,
          "ATR Length",
          minval=1,
          group=GRP_TRADE)


i_slMult =
     input.float(
          1.5,
          "SL ATR Mult",
          minval=0.1,
          step=0.1,
          group=GRP_TRADE)


i_tp1Mult =
     input.float(
          1.0,
          "TP1 ATR Mult",
          minval=0.1,
          step=0.1,
          group=GRP_TRADE)


i_tp2Mult =
     input.float(
          2.0,
          "TP2 ATR Mult",
          minval=0.1,
          step=0.1,
          group=GRP_TRADE)


i_tp3Mult =
     input.float(
          3.0,
          "TP3 ATR Mult",
          minval=0.1,
          step=0.1,
          group=GRP_TRADE)

i_enableTP1 =
     input.bool(
          true,
          "Show TP1",
          group=GRP_TRADE)


i_enableTP2 =
     input.bool(
          true,
          "Show TP2",
          group=GRP_TRADE)

i_lineExtBars =
     input.int(
          50,
          "Level Line Extend Bars",
          minval=1,
          group=GRP_TRADE)



// VISUAL SETTINGS

var string GRP_VIS = "🎨 Visuals"


i_showCandles =
     input.bool(
          true,
          "Color Candles",
          group=GRP_VIS)


i_showSignals =
     input.bool(
          true,
          "Show Buy/Sell Signals",
          group=GRP_VIS)


i_showAllTrades =
     input.bool(
          true,
          "Show all trades",
          group=GRP_VIS)


i_showLevels =
     input.bool(
          true,
          "Show Trade Levels",
          group=GRP_VIS)


i_historyStart =
     input.time(
          timestamp("2026-01-01"),
          "Trade History Start Date",
          group=GRP_VIS)


i_winTarget =
     input.string(
          "TP3",
          "Winrate Calculation Target",
          options=[
              "TP1",
              "TP2",
              "TP3"],
          group=GRP_VIS)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERT SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var string GRP_ALERT = "🔔 Alerts"


i_actionLong =
     input.string(
          "long",
          "↑ Long Action",
          group=GRP_ALERT)


i_actionShort =
     input.string(
          "short",
          "↓ Short Action",
          group=GRP_ALERT)


i_actionCloseLong =
     input.string(
          "closelong",
          "✕ Close Long Action",
          group=GRP_ALERT)


i_actionCloseShort =
     input.string(
          "closeshort",
          "✕ Close Short Action",
          group=GRP_ALERT)



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


var string GRP_DASH = "📊 Dashboard"


i_showDash =
     input.bool(
          true,
          "Show Dashboard",
          group=GRP_DASH)


i_dashPos =
     input.string(
          position.top_right,
          "Dashboard Position",
          options=[
              position.top_right,
              position.top_left,
              position.bottom_right,
              position.bottom_left],
          group=GRP_DASH)





//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COLORS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


var string GRP_COL = "🌈 Colors"


c_bullCandle =
     input.color(
          color.new(#26a69a,0),
          "Bull Candle",
          group=GRP_COL)


c_bearCandle =
     input.color(
          color.new(#ef5350,0),
          "Bear Candle",
          group=GRP_COL)


c_neutral =
     input.color(
          color.new(#787b86,0),
          "Neutral Candle",
          group=GRP_COL)


c_buy =
     input.color(
          #2196f3,
          "Buy Signal",
          group=GRP_COL)


c_sell =
     input.color(
          #ff9800,
          "Sell Signal",
          group=GRP_COL)


c_sl =
     input.color(
          #ef5350,
          "SL Line",
          group=GRP_COL)


c_entry =
     input.color(
          #2196f3,
          "Entry Line",
          group=GRP_COL)


c_tp =
     input.color(
          color.new(#26a69a,0),
          "TP Lines",
          group=GRP_COL)


c_risk =
     input.color(
          color.new(#ef5350,80),
          "Risk Zone",
          group=GRP_COL)


c_reward =
     input.color(
          color.new(#26a69a,85),
          "Reward Zone",
          group=GRP_COL)


c_dashBg =
     input.color(
          color.new(#0a0f1a,10),
          "Dashboard Background",
          group=GRP_COL)


c_dashHeader =
     input.color(
          color.new(#14b5cb,20),
          "Dashboard Header",
          group=GRP_COL)


c_text =
     input.color(
          color.white,
          "Dashboard Text",
          group=GRP_COL)





//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CORE CALCULATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


rsiVal =
     ta.rsi(
          i_rsiSrc,
          i_rsiLen)



trendMA =
     ta.sma(
          i_trendSrc,
          i_trendLen)



isUptrend =
     i_trendSrc > trendMA



isDowntrend =
     i_trendSrc < trendMA




bullRange =
     rsiVal >= i_bullLo and
     rsiVal <= i_bullHi



bearRange =
     rsiVal >= i_bearLo and
     rsiVal <= i_bearHi




bullRaw =
     isUptrend and
     bullRange



bearRaw =
     isDowntrend and
     bearRange




var int bullCount = 0
var int bearCount = 0



bullCount :=
     bullRaw ?
     bullCount + 1 :
     0



bearCount :=
     bearRaw ?
     bearCount + 1 :
     0




bullRegime =
     bullRaw and
     bullCount >= i_confirmBars



bearRegime =
     bearRaw and
     bearCount >= i_confirmBars




regimeState =
     bullRegime ? 1 :
     bearRegime ? -1 :
     0



previousState =
     regimeState[1]





//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HTF CONFIRMATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


f_htfRegime() =>

    _rsi =
         ta.rsi(
              i_rsiSrc,
              i_rsiLen)

    _ma =
         ta.sma(
              i_trendSrc,
              i_trendLen)


    _up =
         i_trendSrc > _ma


    _down =
         i_trendSrc < _ma


    _up and
     _rsi >= i_bullLo and
     _rsi <= i_bullHi ? 1 :

     _down and
     _rsi >= i_bearLo and
     _rsi <= i_bearHi ? -1 :

     0



htfState =
     request.security(
          syminfo.tickerid,
          i_htfTF,
          f_htfRegime()[1],
          lookahead=barmerge.lookahead_on)



htfLongOK =
     not i_useHtf or
     htfState == 1



htfShortOK =
     not i_useHtf or
     htfState == -1





//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ADX FILTER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


[_p,_m,adxVal] =
     ta.dmi(
          i_adxLen,
          i_adxLen)



adxOK =
     not i_useAdx or
     adxVal >= i_adxMin





//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


longSignal =

     regimeState == 1 and
     previousState != 1 and
     htfLongOK and
     adxOK



shortSignal =

     regimeState == -1 and
     previousState != -1 and
     htfShortOK and
     adxOK




validLong =

     longSignal and
     barstate.isconfirmed and
     time >= i_historyStart



validShort =

     shortSignal and
     barstate.isconfirmed and
     time >= i_historyStart
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ATR TRADE LEVELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


atrVal =
     ta.atr(
          i_atrLen)



entryPrice =
     close[1]



// LONG LEVELS

slLong =
     entryPrice -
     atrVal * i_slMult


tp1Long =
     entryPrice +
     atrVal * i_tp1Mult


tp2Long =
     entryPrice +
     atrVal * i_tp2Mult


tp3Long =
     entryPrice +
     atrVal * i_tp3Mult




// SHORT LEVELS


slShort =
     entryPrice +
     atrVal * i_slMult


tp1Short =
     entryPrice -
     atrVal * i_tp1Mult


tp2Short =
     entryPrice -
     atrVal * i_tp2Mult


tp3Short =
     entryPrice -
     atrVal * i_tp3Mult





//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRADE STORAGE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


var label[] labels =
     array.new_label()


var line[] entryLines =
     array.new_line()


var line[] slLines =
     array.new_line()


var line[] tp1Lines =
     array.new_line()


var line[] tp2Lines =
     array.new_line()


var line[] tp3Lines =
     array.new_line()


var linefill[] riskZones =
     array.new_linefill()


var linefill[] rewardZones =
     array.new_linefill()



var float[] storedSL =
     array.new_float()


var float[] storedTP1 =
     array.new_float()


var float[] storedTP2 =
     array.new_float()


var float[] storedTP3 =
     array.new_float()


var int[] storedDirection =
     array.new_int()


var bool[] activeTrade =
     array.new_bool()





//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CREATE TRADE FUNCTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


f_createTrade(

     bool longTrade,
     float entry,
     float sl,
     float tp1,
     float tp2,
     float tp3) =>



    label signalLabel =

         longTrade ?

         label.new(
              bar_index,
              low,
              "BUY",
              style=label.style_label_up,
              yloc=yloc.belowbar,
              color=c_buy,
              textcolor=color.white)

         :

         label.new(
              bar_index,
              high,
              "SELL",
              style=label.style_label_down,
              yloc=yloc.abovebar,
              color=c_sell,
              textcolor=color.white)





    line eLine =

         line.new(
              bar_index,
              entry,
              bar_index + i_lineExtBars,
              entry,
              color=c_entry,
              style=line.style_dashed)



    line slLine =

         line.new(
              bar_index,
              sl,
              bar_index + i_lineExtBars,
              sl,
              color=c_sl,
              width=2)



    line tp1Line =


         i_enableTP1 ?

         line.new(
              bar_index,
              tp1,
              bar_index + i_lineExtBars,
              tp1,
              color=c_tp,
              style=line.style_dashed) :

         na



    line tp2Line =

         i_enableTP2 ?

         line.new(
              bar_index,
              tp2,
              bar_index + i_lineExtBars,
              tp2,
              color=c_tp,
              style=line.style_dashed) :

         na



    line tp3Line =

         line.new(
              bar_index,
              tp3,
              bar_index + i_lineExtBars,
              tp3,
              color=c_tp,
              style=line.style_dashed)





    linefill risk =

         linefill.new(
              slLine,
              eLine,
              c_risk)



    linefill reward =

         linefill.new(
              eLine,
              tp3Line,
              c_reward)





    array.push(
         labels,
         signalLabel)


    array.push(
         entryLines,
         eLine)


    array.push(
         slLines,
         slLine)


    array.push(
         tp1Lines,
         tp1Line)


    array.push(
         tp2Lines,
         tp2Line)


    array.push(
         tp3Lines,
         tp3Line)



    array.push(
         riskZones,
         risk)


    array.push(
         rewardZones,
         reward)



    array.push(
         storedSL,
         sl)


    array.push(
         storedTP1,
         tp1)


    array.push(
         storedTP2,
         tp2)


    array.push(
         storedTP3,
         tp3)



    array.push(
         storedDirection,
         longTrade ? 1 : -1)


    array.push(
         activeTrade,
         true)






//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CREATE NEW TRADES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


if validLong or validShort


    if not i_showAllTrades

        for x = 0 to array.size(labels)-1
            label.delete(
                 array.get(labels,x))


        array.clear(labels)



    if validLong

        f_createTrade(
             true,
             entryPrice,
             slLong,
             tp1Long,
             tp2Long,
             tp3Long)



    if validShort

        f_createTrade(
             false,
             entryPrice,
             slShort,
             tp1Short,
             tp2Short,
             tp3Short)






//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// WINRATE CALCULATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


var int wins = 0
var int losses = 0




if array.size(activeTrade) > 0


    for i = 0 to array.size(activeTrade)-1


        if array.get(activeTrade,i)


            direction =
                 array.get(
                      storedDirection,
                      i)



            sl =
                 array.get(
                      storedSL,
                      i)



            target =

                 i_winTarget == "TP1" ?

                 array.get(storedTP1,i) :

                 i_winTarget == "TP2" ?

                 array.get(storedTP2,i) :

                 array.get(storedTP3,i)





            hitSL =

                 direction == 1 ?

                 low <= sl :

                 high >= sl




            hitTP =

                 direction == 1 ?

                 high >= target :

                 low <= target





            if hitSL

                losses += 1

                array.set(
                     activeTrade,
                     i,
                     false)



            else if hitTP

                wins += 1

                array.set(
                     activeTrade,
                     i,
                     false)




totalTrades =
     wins + losses



winRate =

     totalTrades > 0 ?

     wins / totalTrades * 100 :

     0
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


string longMessage =

     '{"action":"' +
     i_actionLong +

     '","ticker":"' +
     syminfo.tickerid +

     '","tf":"' +
     timeframe.period +

     '","direction":"long"' +

     ',"entry":"' +
     str.tostring(entryPrice,format.mintick) +

     '","sl":"' +
     str.tostring(slLong,format.mintick) +

     '","tp1":"' +
     str.tostring(tp1Long,format.mintick) +

     '","tp2":"' +
     str.tostring(tp2Long,format.mintick) +

     '","tp3":"' +
     str.tostring(tp3Long,format.mintick) +

     '"}'



string shortMessage =

     '{"action":"' +
     i_actionShort +

     '","ticker":"' +
     syminfo.tickerid +

     '","tf":"' +
     timeframe.period +

     '","direction":"short"' +

     ',"entry":"' +
     str.tostring(entryPrice,format.mintick) +

     '","sl":"' +
     str.tostring(slShort,format.mintick) +

     '","tp1":"' +
     str.tostring(tp1Short,format.mintick) +

     '","tp2":"' +
     str.tostring(tp2Short,format.mintick) +

     '","tp3":"' +
     str.tostring(tp3Short,format.mintick) +

     '"}'





if validLong

    alert(
         longMessage,
         alert.freq_once_per_bar_close)



if validShort

    alert(
         shortMessage,
         alert.freq_once_per_bar_close)





alertcondition(
     validLong,
     "BUY Signal",
     "RvKortenhof BUY Signal")



alertcondition(
     validShort,
     "SELL Signal",
     "RvKortenhof SELL Signal")





//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CANDLE VISUALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


candleColor =

     bullRegime ?

     c_bullCandle :

     bearRegime ?

     c_bearCandle :

     c_neutral



plotcandle(

     open,
     high,
     low,
     close,

     title="Heatmap Candles",

     color=
          i_showCandles ?
          candleColor :
          na,

     wickcolor=
          i_showCandles ?
          candleColor :
          na,

     bordercolor=
          i_showCandles ?
          candleColor :
          na)





//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


var table dashboard =

     table.new(
          i_dashPos,
          2,
          12,
          border_width=1)





if i_showDash


    table.cell(
         dashboard,
         0,
         0,
         "RVKORTENHOF STATISTICS",
         bgcolor=c_dashHeader,
         text_color=c_text)



    table.cell(
         dashboard,
         1,
         0,
         "",
         bgcolor=c_dashHeader)





    table.cell(
         dashboard,
         0,
         1,
         "Market",
         bgcolor=c_dashBg,
         text_color=c_text)



    table.cell(
         dashboard,
         1,
         1,

         bullRegime ?
         "BULLISH" :

         bearRegime ?
         "BEARISH" :

         "NEUTRAL",

         bgcolor=c_dashBg,
         text_color=c_text)





    table.cell(
         dashboard,
         0,
         2,
         "RSI",
         bgcolor=c_dashBg,
         text_color=c_text)



    table.cell(
         dashboard,
         1,
         2,
         str.tostring(rsiVal,"#.##"),
         bgcolor=c_dashBg,
         text_color=c_text)





    table.cell(
         dashboard,
         0,
         3,
         "ATR",
         bgcolor=c_dashBg,
         text_color=c_text)



    table.cell(
         dashboard,
         1,
         3,
         str.tostring(atrVal,format.mintick),
         bgcolor=c_dashBg,
         text_color=c_text)





    table.cell(
         dashboard,
         0,
         4,
         "Trades",
         bgcolor=c_dashBg,
         text_color=c_text)



    table.cell(
         dashboard,
         1,
         4,
         str.tostring(totalTrades),
         bgcolor=c_dashBg,
         text_color=c_text)





    table.cell(
         dashboard,
         0,
         5,
         "Wins",
         bgcolor=c_dashBg,
         text_color=c_text)



    table.cell(
         dashboard,
         1,
         5,
         str.tostring(wins),
         bgcolor=c_dashBg,
         text_color=color.green)





    table.cell(
         dashboard,
         0,
         6,
         "Losses",
         bgcolor=c_dashBg,
         text_color=c_text)



    table.cell(
         dashboard,
         1,
         6,
         str.tostring(losses),
         bgcolor=c_dashBg,
         text_color=color.red)





    table.cell(
         dashboard,
         0,
         7,
         "Winrate",
         bgcolor=c_dashBg,
         text_color=c_text)



    table.cell(
         dashboard,
         1,
         7,

         str.tostring(
              winRate,
              "#.##") + "%",

         bgcolor=c_dashBg,
         text_color=color.green)





    table.cell(
         dashboard,
         0,
         8,
         "Winrate Target",
         bgcolor=c_dashBg,
         text_color=c_text)



    table.cell(
         dashboard,
         1,
         8,
         i_winTarget,
         bgcolor=c_dashBg,
         text_color=c_text)





    table.cell(
         dashboard,
         0,
         9,
         "RR TP3/SL",
         bgcolor=c_dashBg,
         text_color=c_text)



    table.cell(
         dashboard,
         1,
         9,

         "1 : " +
         str.tostring(
              i_tp3Mult / i_slMult,
              "#.##"),

         bgcolor=c_dashBg,
         text_color=c_text)





    table.cell(
         dashboard,
         0,
         10,
         "History Start",
         bgcolor=c_dashBg,
         text_color=c_text)



    table.cell(
         dashboard,
         1,
         10,

         str.format_time(
              i_historyStart,
              "yyyy-MM-dd"),

         bgcolor=c_dashBg,
         text_color=c_text)





    table.cell(
         dashboard,
         0,
         11,
         "Show All Trades",
         bgcolor=c_dashBg,
         text_color=c_text)



    table.cell(
         dashboard,
         1,
         11,

         i_showAllTrades ?
         "ON" :
         "OFF",

         bgcolor=c_dashBg,
         text_color=c_text)
````
