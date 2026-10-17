# MNQ Trend Bias PRO v2

- url: https://www.tradingview.com/script/mpQ1Ga0H-MNQ-Trend-Bias-PRO-v2/
- type: indicator
- pine_id: PUB;a0a61de8d4e445c6b72f7cb3b23a69aa
- version: 1.0

## Description

# MNQ Trend Bias PRO v2

**MNQ Trend Bias PRO v2** is a multi-timeframe trend-bias and trade-signal indicator designed primarily for **Micro E-mini Nasdaq-100 (MNQ)** intraday trading.

The indicator combines a higher-timeframe trend filter with lower-timeframe execution conditions to identify bullish, bearish, and neutral market environments.

## Trend Bias

By default, trend direction is calculated from the **15-minute timeframe** using:

- 20 EMA position and slope
- Session VWAP position and slope
- Price relative to both EMA and VWAP

A **green background** represents bullish bias, a **red background** represents bearish bias, and a **grey background** represents a neutral or unconfirmed environment.

When the higher-timeframe bias changes:

**Green → BUY signal**  
**Red → SELL signal**

These signals indicate a change in calculated trend bias. They are not a guarantee that price will continue in that direction.

## Breakout Signals

The indicator looks for momentum breakouts that agree with the higher-timeframe trend.

A breakout requires price to:

- Align with the higher-timeframe bias
- Break the recent high/low
- Remain on the correct side of the 20 EMA
- Remain on the correct side of VWAP
- Close with directional momentum
- Pass the VWAP-extension filter

Signals are displayed as **BRK BUY** and **BRK SELL**.

## Pullback Signals

The pullback system waits for price to move against the current trend and subsequently reclaim the 20 EMA.

For bullish setups, price must first close below the EMA and then reclaim it while bullish higher-timeframe conditions remain active.

The opposite conditions apply to bearish setups.

Signals are displayed as **PB BUY** and **PB SELL**.

## VWAP Extension Filter

The indicator measures the distance between price and VWAP relative to ATR.

The default maximum extension is **1.5 ATR from VWAP**. Signals that occur when price is excessively extended can therefore be filtered.

## Dashboard

The dashboard displays:

- Current higher-timeframe bias
- VWAP distance in ATR
- Current market condition
- Directional focus

## Default Settings

**Trend Bias Timeframe:** 15 minutes  
**EMA Length:** 20  
**ATR Length:** 14  
**Breakout Lookback:** 6 bars  
**Maximum VWAP Extension:** 1.5 ATR

## Alerts

Alerts are available for:

- Trend turns green — BUY
- Trend turns red — SELL
- Breakout BUY
- Breakout SELL
- Pullback BUY
- Pullback SELL

# ⚠️ IMPORTANT RISK WARNING

**TRADE AT YOUR OWN RISK.**

Futures trading involves substantial risk and can result in significant financial losses. This indicator does **not** guarantee profitable trades, accurate signals, or future performance.

BUY and SELL signals are generated mechanically from the conditions programmed into the indicator. They should **not** be interpreted as financial advice or as a recommendation to enter any particular trade.

False signals, rapid trend changes, slippage, volatility, gaps, execution delays, and unexpected market events can all result in losses.

Always:

- Use appropriate risk management.
- Determine your own stop-loss and position size.
- Test the indicator thoroughly before risking real capital.
- Never risk money you cannot afford to lose.
- Verify that the indicator suits your own trading approach and risk tolerance.

Past or backtested performance does not guarantee future results.

**You are solely responsible for your own trading decisions, trades, profits, and losses.**

This indicator is provided for **educational and informational purposes only** and does not constitute financial or investment advice.

**By using this indicator, you acknowledge that you trade entirely at your own risk.**

## Source Code

````pine
//@version=6
indicator("MNQ Trend Bias PRO v2", overlay=true, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
biasTF = input.timeframe("15", "Trend Bias Timeframe")
emaLen = input.int(20, "EMA Length", minval=1)
atrLen = input.int(14, "ATR Length", minval=1)

breakoutLookback = input.int(6, "Breakout Lookback", minval=2)

maxExtensionATR = input.float(
     1.5,
     "Maximum VWAP Extension (ATR)",
     step=0.1)

showEMA = input.bool(true, "Show 20 EMA")
showVWAP = input.bool(true, "Show VWAP")
showBackground = input.bool(true, "Show Bias Background")
showDashboard = input.bool(true, "Show Dashboard")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 15M BIAS ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
trendEngine() =>
    emaHTF = ta.ema(close, emaLen)
    vwHTF = ta.vwap(hlc3)

    emaUp = emaHTF > emaHTF[1]
    emaDown = emaHTF < emaHTF[1]

    vwUp = vwHTF > vwHTF[1]
    vwDown = vwHTF < vwHTF[1]

    bullish =
         close > emaHTF and
         close > vwHTF and
         emaUp and
         vwUp

    bearish =
         close < emaHTF and
         close < vwHTF and
         emaDown and
         vwDown

    bias =
         bullish ? 1 :
         bearish ? -1 :
         0

    [bias, emaHTF, vwHTF]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// REQUEST 15M DATA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[htfBias, htfEMA, htfVWAP] =
     request.security(
         syminfo.tickerid,
         biasTF,
         trendEngine(),
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BIAS STATES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
longBias = htfBias == 1
shortBias = htfBias == -1
neutralBias = htfBias == 0

// Detect when bias FIRST changes green/red
newLongBias =
     longBias and
     htfBias[1] != 1

newShortBias =
     shortBias and
     htfBias[1] != -1

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 5M EXECUTION DATA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ema = ta.ema(close, emaLen)
vw = ta.vwap(hlc3)
atr = ta.atr(atrLen)

bullCandle = close > open
bearCandle = close < open

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VWAP EXTENSION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
distanceVWAP = math.abs(close - vw)

extensionATR =
     atr > 0 ?
     distanceVWAP / atr :
     0.0

extended =
     extensionATR > maxExtensionATR

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 5M BREAKOUT LEVELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
recentHigh =
     ta.highest(high, breakoutLookback)[1]

recentLow =
     ta.lowest(low, breakoutLookback)[1]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BREAKOUT ENTRY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bullBreakout =
     longBias and
     close > recentHigh and
     close > ema and
     close > vw and
     bullCandle and
     not extended

bearBreakout =
     shortBias and
     close < recentLow and
     close < ema and
     close < vw and
     bearCandle and
     not extended

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ONE BREAKOUT PER BIAS CYCLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var bool longBreakoutTaken = false
var bool shortBreakoutTaken = false

if newLongBias
    longBreakoutTaken := false

if newShortBias
    shortBreakoutTaken := false

if not longBias
    longBreakoutTaken := false

if not shortBias
    shortBreakoutTaken := false

breakoutLong =
     bullBreakout and
     not longBreakoutTaken

breakoutShort =
     bearBreakout and
     not shortBreakoutTaken

if breakoutLong
    longBreakoutTaken := true

if breakoutShort
    shortBreakoutTaken := true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PULLBACK STATE MACHINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var bool longPullbackArmed = false
var bool shortPullbackArmed = false

// Arm long after genuine pullback below EMA
if longBias and close < ema
    longPullbackArmed := true

// Arm short after genuine rally above EMA
if shortBias and close > ema
    shortPullbackArmed := true

// Cancel if bias disappears
if not longBias
    longPullbackArmed := false

if not shortBias
    shortPullbackArmed := false

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMA RECLAIM
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
longReclaim =
     longPullbackArmed and
     longBias and
     close > ema and
     close[1] <= ema[1] and
     close > vw and
     bullCandle and
     not extended

shortReclaim =
     shortPullbackArmed and
     shortBias and
     close < ema and
     close[1] >= ema[1] and
     close < vw and
     bearCandle and
     not extended

pullbackLong = longReclaim
pullbackShort = shortReclaim

// Require a new pullback after signal
if pullbackLong
    longPullbackArmed := false

if pullbackShort
    shortPullbackArmed := false

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DON'T PRINT TWO ENTRY TYPES SAME BAR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
finalBreakoutLong =
     breakoutLong

finalBreakoutShort =
     breakoutShort

finalPullbackLong =
     pullbackLong and
     not breakoutLong

finalPullbackShort =
     pullbackShort and
     not breakoutShort

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(
     showEMA ? ema : na,
     "5M 20 EMA",
     color=color.orange,
     linewidth=2)

plot(
     showVWAP ? vw : na,
     "Session VWAP",
     color=color.blue,
     linewidth=2)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BACKGROUND
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
biasColor =
     longBias ?
     color.new(color.green, 92) :
     shortBias ?
     color.new(color.red, 92) :
     color.new(color.gray, 96)

bgcolor(
     showBackground ?
     biasColor :
     na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TREND FLIP BUY / SELL SIGNALS
//
// GREEN bias begins = BUY
// RED bias begins   = SELL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plotshape(
     newLongBias,
     title="Trend Green BUY",
     style=shape.labelup,
     location=location.belowbar,
     color=color.lime,
     text="BUY",
     textcolor=color.black,
     size=size.normal)

plotshape(
     newShortBias,
     title="Trend Red SELL",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="SELL",
     textcolor=color.white,
     size=size.normal)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BREAKOUT SIGNALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plotshape(
     finalBreakoutLong,
     title="Breakout Buy",
     style=shape.labelup,
     location=location.belowbar,
     color=color.lime,
     text="BRK\nBUY",
     textcolor=color.black,
     size=size.small)

plotshape(
     finalBreakoutShort,
     title="Breakout Sell",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="BRK\nSELL",
     textcolor=color.white,
     size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PULLBACK SIGNALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plotshape(
     finalPullbackLong,
     title="Pullback Buy",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     text="PB\nBUY",
     textcolor=color.white,
     size=size.small)

plotshape(
     finalPullbackShort,
     title="Pullback Sell",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.maroon,
     text="PB\nSELL",
     textcolor=color.white,
     size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table dash =
     table.new(
         position.top_right,
         2,
         5,
         border_width=1)

if barstate.islast and showDashboard

    biasText =
         longBias ?
         "LONGS ONLY" :
         shortBias ?
         "SHORTS ONLY" :
         "NO TRADE"

    dashboardBiasColor =
         longBias ?
         color.green :
         shortBias ?
         color.red :
         color.gray

    conditionText =
         extended ?
         "EXTENDED" :
         "READY"

    conditionColor =
         extended ?
         color.orange :
         color.green

    actionText =
         neutralBias ?
         "WAIT" :
         extended ?
         "WAIT FOR PULLBACK" :
         longBias ?
         "LOOK FOR LONG" :
         "LOOK FOR SHORT"

    table.cell(
         dash, 0, 0,
         "MNQ TREND",
         bgcolor=color.black,
         text_color=color.white)

    table.cell(
         dash, 1, 0,
         biasTF,
         bgcolor=color.black,
         text_color=color.white)

    table.cell(
         dash, 0, 1,
         "Bias")

    table.cell(
         dash, 1, 1,
         biasText,
         bgcolor=dashboardBiasColor,
         text_color=color.white)

    table.cell(
         dash, 0, 2,
         "VWAP Distance")

    table.cell(
         dash, 1, 2,
         str.tostring(extensionATR, "#.##") + " ATR")

    table.cell(
         dash, 0, 3,
         "Condition")

    table.cell(
         dash, 1, 3,
         conditionText,
         bgcolor=conditionColor,
         text_color=color.white)

    table.cell(
         dash, 0, 4,
         "Action")

    table.cell(
         dash, 1, 4,
         actionText)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Trend flip alerts
alertcondition(
     newLongBias,
     "Trend Green BUY",
     "MNQ Trend turned GREEN - BUY")

alertcondition(
     newShortBias,
     "Trend Red SELL",
     "MNQ Trend turned RED - SELL")

// Breakout alerts
alertcondition(
     finalBreakoutLong,
     "Breakout BUY",
     "MNQ Breakout BUY")

alertcondition(
     finalBreakoutShort,
     "Breakout SELL",
     "MNQ Breakout SELL")

// Pullback alerts
alertcondition(
     finalPullbackLong,
     "Pullback BUY",
     "MNQ Pullback BUY")

alertcondition(
     finalPullbackShort,
     "Pullback SELL",
     "MNQ Pullback SELL")
````
