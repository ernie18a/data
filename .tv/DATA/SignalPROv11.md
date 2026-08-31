<!-- tradingview-pine-id: PUB;8083259c15c147a6b95e27da69571d21 -->
<!-- tradingviewscripts-format: 1 -->
# SignalPROv11

Source: https://www.tradingview.com/script/JDMqrlpU-SignalPROv11/

## Description

SignalPROv11 is an signal indicator based on the principles of RSI range analysis developed by Rick.

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
- TP level

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

The indicator combines RSI range analysis with trend confirmation:

- Bullish conditions are identified when price is in an uptrend and RSI remains within a defined bullish range.

- Bearish conditions are identified when price is in a downtrend and RSI remains within a defined bearish range.

- Signals are generated when a confirmed regime transition occurs.

This indicator can be used for:

- Intraday trading
- Swing trading
- Trend-following strategies
- Market regime analysis

Best results are generally achieved when combined with proper risk management and additional market analysis.

Disclaimer

This indicator is a technical analysis tool and should not be considered financial advice. Trading involves risk, and users should always perform their own analysis before making trading decisions.

© SignalPROv11

---

## Source Code

````pine
//@version=6
indicator(
     "SignalPROv11",
     overlay=true,
     max_labels_count=500,
     max_lines_count=500,
     max_boxes_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CONSTANTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const int DEFAULT_HISTORY_START = 1767225600000  // 2026-01-01 00:00 UTC
const int DEFAULT_HISTORY_END   = 4102444740000  // 2099-12-31 23:59 UTC

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GROUPS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var string GRP_CORE  = "⚙️ Core Settings"
var string GRP_FILT  = "🕯️ Filters"
var string GRP_TRADE = "📐 Trade Tools"
var string GRP_VIS   = "🎨 Visuals"
var string GRP_ALERT = "🔔 Alerts"
var string GRP_DASH  = "📊 Dashboard"
var string GRP_COL   = "🌈 Colors"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CORE SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

i_rsiLen =
     input.int(
          14,
          "RSI Length",
          minval=1,
          group=GRP_CORE)

i_rsiSrc =
     input.source(
          close,
          "RSI Source",
          group=GRP_CORE)

i_trendLen =
     input.int(
          50,
          "Fast Trend EMA Length",
          minval=1,
          group=GRP_CORE)

i_slowTrendLen =
     input.int(
          200,
          "Slow Trend EMA Length",
          minval=2,
          group=GRP_CORE)

i_trendSrc =
     input.source(
          close,
          "Trend Source",
          group=GRP_CORE)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FILTERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

i_bullLo =
     input.int(
          50,
          "Bull RSI Low",
          minval=0,
          maxval=100,
          group=GRP_FILT)

i_bullHi =
     input.int(
          70,
          "Bull RSI High",
          minval=0,
          maxval=100,
          group=GRP_FILT)

i_bearLo =
     input.int(
          30,
          "Bear RSI Low",
          minval=0,
          maxval=100,
          group=GRP_FILT)

i_bearHi =
     input.int(
          50,
          "Bear RSI High",
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
          true,
          "Use HTF Confirmation",
          group=GRP_FILT)

i_htfTF =
     input.timeframe(
          "15",
          "HTF Timeframe",
          group=GRP_FILT)

i_useAdx =
     input.bool(
          true,
          "Use ADX Filter",
          group=GRP_FILT)

i_adxLen =
     input.int(
          14,
          "ADX Length",
          minval=1,
          group=GRP_FILT)

i_adxMin =
     input.float(
          20.0,
          "ADX Minimum",
          minval=0,
          maxval=100,
          step=0.5,
          group=GRP_FILT)

i_useCandleVolFilter =
     input.bool(
          true,
          "Filter Volatile Signal Candles",
          group=GRP_FILT)

i_maxSignalCandleAtr =
     input.float(
          1.2,
          "Maximum Signal Candle Size (ATR)",
          minval=0.1,
          step=0.1,
          group=GRP_FILT)

i_minBarsBetween =
     input.int(
          3,
          "Minimum Bars Between Signals",
          minval=0,
          group=GRP_FILT)

i_useSession =
     input.bool(
          false,
          "Use Session Filter",
          group=GRP_FILT)

i_session =
     input.session(
          "0700-2000",
          "Trading Session",
          group=GRP_FILT)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRADE SETTINGS — ONLY TP3
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

i_atrLen =
     input.int(
          14,
          "ATR Length",
          minval=1,
          group=GRP_TRADE)

i_slMult =
     input.float(
          1.2,
          "SL ATR Mult",
          minval=0.1,
          step=0.1,
          group=GRP_TRADE)

i_tp3Mult =
     input.float(
          2.4,
          "TP3 ATR Mult",
          minval=0.1,
          step=0.1,
          group=GRP_TRADE)

i_lineExtBars =
     input.int(
          50,
          "Level Line Extend Bars",
          minval=1,
          group=GRP_TRADE)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VISUAL SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

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
          "Show All Trades",
          group=GRP_VIS)

i_showLevels =
     input.bool(
          true,
          "Show Trade Levels",
          group=GRP_VIS)

i_historyStart =
     input.time(
          DEFAULT_HISTORY_START,
          "Trade History Start Date",
          group=GRP_VIS)

i_historyEnd =
     input.time(
          DEFAULT_HISTORY_END,
          "Trade History End Date",
          group=GRP_VIS)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERT SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

i_mt5Symbol =
     input.string(
          "XAUUSD",
          "MT5 Symbol",
          group=GRP_ALERT)

i_username =
     input.string(
          "Rick3112",
          "Username",
          group=GRP_ALERT)

i_apiKey =
     input.string(
          "",
          "API Key",
          group=GRP_ALERT)

i_accountType =
     input.string(
          "demo",
          "Account Type",
          options=["demo", "live"],
          group=GRP_ALERT)

i_riskPercentage =
     input.float(
          0.5,
          "Risk Percentage",
          minval=0.1,
          maxval=10,
          step=0.1,
          group=GRP_ALERT)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

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

c_bullCandle =
     input.color(
          color.new(#26a69a, 0),
          "Bull Candle",
          group=GRP_COL)

c_bearCandle =
     input.color(
          color.new(#ef5350, 0),
          "Bear Candle",
          group=GRP_COL)

c_neutral =
     input.color(
          color.new(#787b86, 0),
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
          color.new(#26a69a, 0),
          "TP3 Line",
          group=GRP_COL)

c_risk =
     input.color(
          color.new(#ef5350, 80),
          "Risk Zone",
          group=GRP_COL)

c_reward =
     input.color(
          color.new(#26a69a, 85),
          "Reward Zone",
          group=GRP_COL)

c_dashBg =
     input.color(
          color.new(#0a0f1a, 10),
          "Dashboard Background",
          group=GRP_COL)

c_dashHeader =
     input.color(
          color.new(#14b5cb, 20),
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

trendFast =
     ta.ema(
          i_trendSrc,
          i_trendLen)

trendSlow =
     ta.ema(
          i_trendSrc,
          i_slowTrendLen)

isUptrend =
     i_trendSrc > trendFast and
     trendFast > trendSlow

isDowntrend =
     i_trendSrc < trendFast and
     trendFast < trendSlow

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
// CONFIRMED HTF FILTER — NO LOOKAHEAD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_htfRegime() =>

    _rsi =
         ta.rsi(
              close,
              i_rsiLen)

    _fast =
         ta.ema(
              close,
              i_trendLen)

    _slow =
         ta.ema(
              close,
              i_slowTrendLen)

    _long =
         close > _fast and
         _fast > _slow and
         _rsi >= i_bullLo and
         _rsi <= i_bullHi

    _short =
         close < _fast and
         _fast < _slow and
         _rsi >= i_bearLo and
         _rsi <= i_bearHi

    _long ? 1 :
     _short ? -1 :
     0

htfState =
     request.security(
          syminfo.tickerid,
          i_htfTF,
          f_htfRegime()[1],
          lookahead=barmerge.lookahead_off)

htfLongOK =
     not i_useHtf or
     htfState == 1

htfShortOK =
     not i_useHtf or
     htfState == -1

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ADX + VOLATILITY + DATE FILTERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[plusDI, minusDI, adxVal] =
     ta.dmi(
          i_adxLen,
          i_adxLen)

adxLongOK =
     not i_useAdx or
     (adxVal >= i_adxMin and plusDI > minusDI)

adxShortOK =
     not i_useAdx or
     (adxVal >= i_adxMin and minusDI > plusDI)

atrVal =
     ta.atr(
          i_atrLen)

signalCandleRange =
     high - low

signalCandleOK =
     not i_useCandleVolFilter or
     signalCandleRange <= atrVal * i_maxSignalCandleAtr

historyEndInclusive =
     i_historyEnd + 86399999

dateOK =
     time >= i_historyStart and
     time <= historyEndInclusive

sessionOK =
     not i_useSession or
     not na(time(timeframe.period, i_session))

var int lastSignalBar = na

cooldownOK =
     na(lastSignalBar) or
     bar_index - lastSignalBar >= i_minBarsBetween

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DIRECT SIGNALS — LABEL AND ALERT SAME CANDLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

longSignal =
     regimeState == 1 and
     previousState != 1 and
     htfLongOK and
     adxLongOK and
     signalCandleOK and
     dateOK and
     sessionOK and
     cooldownOK and
     barstate.isconfirmed

shortSignal =
     regimeState == -1 and
     previousState != -1 and
     htfShortOK and
     adxShortOK and
     signalCandleOK and
     dateOK and
     sessionOK and
     cooldownOK and
     barstate.isconfirmed

validLong =
     longSignal

validShort =
     shortSignal

if validLong or validShort
    lastSignalBar := bar_index

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ENTRY / SL / TP3
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

entryPrice =
     close

slLong =
     entryPrice -
     atrVal * i_slMult

tp3Long =
     entryPrice +
     atrVal * i_tp3Mult

slShort =
     entryPrice +
     atrVal * i_slMult

tp3Short =
     entryPrice -
     atrVal * i_tp3Mult

rrValue =
     i_slMult > 0 ?
     i_tp3Mult / i_slMult :
     0.0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRADE STORAGE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var label[] labels =
     array.new_label()

var line[] entryLines =
     array.new_line()

var line[] slLines =
     array.new_line()

var line[] tp3Lines =
     array.new_line()

var linefill[] riskZones =
     array.new_linefill()

var linefill[] rewardZones =
     array.new_linefill()

var float[] storedSL =
     array.new_float()

var float[] storedTP3 =
     array.new_float()

var int[] storedDirection =
     array.new_int()

var int[] storedEntryBar =
     array.new_int()

var bool[] activeTrade =
     array.new_bool()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VISUAL CLEANUP
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_clearVisuals() =>

    if array.size(labels) > 0
        for x = 0 to array.size(labels) - 1
            label.delete(array.get(labels, x))

    if array.size(entryLines) > 0
        for x = 0 to array.size(entryLines) - 1
            line.delete(array.get(entryLines, x))

    if array.size(slLines) > 0
        for x = 0 to array.size(slLines) - 1
            line.delete(array.get(slLines, x))

    if array.size(tp3Lines) > 0
        for x = 0 to array.size(tp3Lines) - 1
            line.delete(array.get(tp3Lines, x))

    array.clear(labels)
    array.clear(entryLines)
    array.clear(slLines)
    array.clear(tp3Lines)
    array.clear(riskZones)
    array.clear(rewardZones)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CREATE TRADE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_createTrade(
     bool longTrade,
     float entry,
     float sl,
     float tp3) =>

    label signalLabel = na
    line eLine = na
    line slLine = na
    line tp3Line = na
    linefill risk = na
    linefill reward = na

    if i_showSignals

        signalLabel :=
             longTrade ?
             label.new(
                  bar_index,
                  low,
                  "BUY",
                  style=label.style_label_up,
                  yloc=yloc.belowbar,
                  color=c_buy,
                  textcolor=color.white) :
             label.new(
                  bar_index,
                  high,
                  "SELL",
                  style=label.style_label_down,
                  yloc=yloc.abovebar,
                  color=c_sell,
                  textcolor=color.white)

    if i_showLevels

        eLine :=
             line.new(
                  bar_index,
                  entry,
                  bar_index + i_lineExtBars,
                  entry,
                  color=c_entry,
                  style=line.style_dashed)

        slLine :=
             line.new(
                  bar_index,
                  sl,
                  bar_index + i_lineExtBars,
                  sl,
                  color=c_sl,
                  width=2)

        tp3Line :=
             line.new(
                  bar_index,
                  tp3,
                  bar_index + i_lineExtBars,
                  tp3,
                  color=c_tp,
                  style=line.style_dashed,
                  width=2)

        risk :=
             linefill.new(
                  slLine,
                  eLine,
                  c_risk)

        reward :=
             linefill.new(
                  eLine,
                  tp3Line,
                  c_reward)

    if not na(signalLabel)
        array.push(labels, signalLabel)

    if not na(eLine)
        array.push(entryLines, eLine)

    if not na(slLine)
        array.push(slLines, slLine)

    if not na(tp3Line)
        array.push(tp3Lines, tp3Line)

    if not na(risk)
        array.push(riskZones, risk)

    if not na(reward)
        array.push(rewardZones, reward)

    array.push(storedSL, sl)
    array.push(storedTP3, tp3)
    array.push(storedDirection, longTrade ? 1 : -1)
    array.push(storedEntryBar, bar_index)
    array.push(activeTrade, true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CREATE NEW TRADES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if validLong or validShort

    if not i_showAllTrades
        f_clearVisuals()

    if validLong
        f_createTrade(
             true,
             entryPrice,
             slLong,
             tp3Long)

    if validShort
        f_createTrade(
             false,
             entryPrice,
             slShort,
             tp3Short)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RESULT CALCULATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var int wins = 0
var int losses = 0
var int ambiguousTrades = 0
var float netR = 0.0
var float grossWinR = 0.0
var float grossLossR = 0.0

if array.size(activeTrade) > 0

    for i = 0 to array.size(activeTrade) - 1

        if array.get(activeTrade, i)

            entryBar =
                 array.get(
                      storedEntryBar,
                      i)

            // Do not evaluate SL/TP on the entry candle itself.
            if bar_index > entryBar

                direction =
                     array.get(
                          storedDirection,
                          i)

                sl =
                     array.get(
                          storedSL,
                          i)

                target =
                     array.get(
                          storedTP3,
                          i)

                hitSL =
                     direction == 1 ?
                     low <= sl :
                     high >= sl

                hitTP =
                     direction == 1 ?
                     high >= target :
                     low <= target

                // If SL and TP are both inside one candle, the intrabar order
                // cannot be determined from OHLC data. Count separately.
                if hitSL and hitTP

                    ambiguousTrades += 1

                    array.set(
                         activeTrade,
                         i,
                         false)

                else if hitSL

                    losses += 1
                    netR -= 1.0
                    grossLossR += 1.0

                    array.set(
                         activeTrade,
                         i,
                         false)

                else if hitTP

                    wins += 1
                    netR += rrValue
                    grossWinR += rrValue

                    array.set(
                         activeTrade,
                         i,
                         false)

closedTrades =
     wins + losses

resolvedTrades =
     wins + losses + ambiguousTrades

allSignals =
     array.size(activeTrade)

openTrades =
     allSignals - resolvedTrades

winRate =
     closedTrades > 0 ?
     wins / closedTrades * 100 :
     0.0

profitFactor =
     grossLossR > 0 ?
     grossWinR / grossLossR :
     na

expectancyR =
     closedTrades > 0 ?
     netR / closedTrades :
     0.0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS — TP3 ONLY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string longMessage =
     '{' +
     '"username":"' + i_username + '",' +
     '"api_key":"' + i_apiKey + '",' +
     '"broker":"metatrader",' +
     '"account_type":"' + i_accountType + '",' +
     '"symbol":"' + i_mt5Symbol + '",' +
     '"action":"buy",' +
     '"risk_percentage":"' + str.tostring(i_riskPercentage) + '",' +
     '"entry_price":"' + str.tostring(entryPrice, format.mintick) + '",' +
     '"stop_loss":"' + str.tostring(slLong, format.mintick) + '",' +
     '"take_profit":"' + str.tostring(tp3Long, format.mintick) + '"' +
     '}'

string shortMessage =
     '{' +
     '"username":"' + i_username + '",' +
     '"api_key":"' + i_apiKey + '",' +
     '"broker":"metatrader",' +
     '"account_type":"' + i_accountType + '",' +
     '"symbol":"' + i_mt5Symbol + '",' +
     '"action":"sell",' +
     '"risk_percentage":"' + str.tostring(i_riskPercentage) + '",' +
     '"entry_price":"' + str.tostring(entryPrice, format.mintick) + '",' +
     '"stop_loss":"' + str.tostring(slShort, format.mintick) + '",' +
     '"take_profit":"' + str.tostring(tp3Short, format.mintick) + '"' +
     '}'

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
     "SignalPROv11 BUY Signal")

alertcondition(
     validShort,
     "SELL Signal",
     "SignalPROv11 SELL Signal")

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
     color=i_showCandles ? candleColor : na,
     wickcolor=i_showCandles ? candleColor : na,
     bordercolor=i_showCandles ? candleColor : na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var table dashboard =
     table.new(
          i_dashPos,
          2,
          16,
          border_width=1)

if barstate.islast

    if i_showDash

        table.cell(
             dashboard,
             0,
             0,
             "SIGNALPRO v11",
             bgcolor=c_dashHeader,
             text_color=c_text)

        table.cell(
             dashboard,
             1,
             0,
             "TP3 ONLY",
             bgcolor=c_dashHeader,
             text_color=c_text)

        table.cell(dashboard, 0, 1, "Symbol", bgcolor=c_dashBg, text_color=c_text)
        table.cell(dashboard, 1, 1, syminfo.ticker, bgcolor=c_dashBg, text_color=c_text)

        table.cell(dashboard, 0, 2, "Timeframe", bgcolor=c_dashBg, text_color=c_text)
        table.cell(dashboard, 1, 2, timeframe.period, bgcolor=c_dashBg, text_color=c_text)

        table.cell(dashboard, 0, 3, "Market", bgcolor=c_dashBg, text_color=c_text)
        table.cell(
             dashboard,
             1,
             3,
             bullRegime ? "BULLISH" : bearRegime ? "BEARISH" : "NEUTRAL",
             bgcolor=c_dashBg,
             text_color=c_text)

        table.cell(dashboard, 0, 4, "RSI / ADX", bgcolor=c_dashBg, text_color=c_text)
        table.cell(
             dashboard,
             1,
             4,
             str.tostring(rsiVal, "#.##") + " / " + str.tostring(adxVal, "#.##"),
             bgcolor=c_dashBg,
             text_color=c_text)

        table.cell(dashboard, 0, 5, "Signals", bgcolor=c_dashBg, text_color=c_text)
        table.cell(dashboard, 1, 5, str.tostring(allSignals), bgcolor=c_dashBg, text_color=c_text)

        table.cell(dashboard, 0, 6, "Wins", bgcolor=c_dashBg, text_color=c_text)
        table.cell(dashboard, 1, 6, str.tostring(wins), bgcolor=c_dashBg, text_color=color.green)

        table.cell(dashboard, 0, 7, "Losses", bgcolor=c_dashBg, text_color=c_text)
        table.cell(dashboard, 1, 7, str.tostring(losses), bgcolor=c_dashBg, text_color=color.red)

        table.cell(dashboard, 0, 8, "Ambiguous", bgcolor=c_dashBg, text_color=c_text)
        table.cell(
             dashboard,
             1,
             8,
             str.tostring(ambiguousTrades),
             bgcolor=c_dashBg,
             text_color=color.orange)

        table.cell(dashboard, 0, 9, "Open Trades", bgcolor=c_dashBg, text_color=c_text)
        table.cell(dashboard, 1, 9, str.tostring(openTrades), bgcolor=c_dashBg, text_color=c_text)

        table.cell(dashboard, 0, 10, "Winrate", bgcolor=c_dashBg, text_color=c_text)
        table.cell(
             dashboard,
             1,
             10,
             str.tostring(winRate, "#.##") + "%",
             bgcolor=c_dashBg,
             text_color=winRate >= 50 ? color.green : color.orange)

        table.cell(dashboard, 0, 11, "RR TP3/SL", bgcolor=c_dashBg, text_color=c_text)
        table.cell(
             dashboard,
             1,
             11,
             "1 : " + str.tostring(rrValue, "#.##"),
             bgcolor=c_dashBg,
             text_color=c_text)

        table.cell(dashboard, 0, 12, "Profit Factor", bgcolor=c_dashBg, text_color=c_text)
        table.cell(
             dashboard,
             1,
             12,
             na(profitFactor) ? "N/A" : str.tostring(profitFactor, "#.##"),
             bgcolor=c_dashBg,
             text_color=not na(profitFactor) and profitFactor >= 1 ? color.green : color.orange)

        table.cell(dashboard, 0, 13, "Expectancy", bgcolor=c_dashBg, text_color=c_text)
        table.cell(
             dashboard,
             1,
             13,
             str.tostring(expectancyR, "#.##") + " R",
             bgcolor=c_dashBg,
             text_color=expectancyR > 0 ? color.green : color.orange)

        table.cell(dashboard, 0, 14, "History Start", bgcolor=c_dashBg, text_color=c_text)
        table.cell(
             dashboard,
             1,
             14,
             str.format_time(i_historyStart, "yyyy-MM-dd"),
             bgcolor=c_dashBg,
             text_color=c_text)

        table.cell(dashboard, 0, 15, "History End", bgcolor=c_dashBg, text_color=c_text)
        table.cell(
             dashboard,
             1,
             15,
             str.format_time(i_historyEnd, "yyyy-MM-dd"),
             bgcolor=c_dashBg,
             text_color=c_text)

    else

        table.clear(
             dashboard,
             0,
             0,
             1,
             15)
````
