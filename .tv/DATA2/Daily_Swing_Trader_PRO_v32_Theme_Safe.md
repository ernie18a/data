<!-- tradingview-pine-id: PUB;2087c13a8de54222ad9f24e217de0a49 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Daily Swing Trader PRO v3.2 - Theme Safe

Source: https://www.tradingview.com/script/oXk5vq2A-Daily-Swing-Trader-PRO-v3-2/

## Description

# Daily Swing Trader PRO

**Daily Swing Trader PRO** is a rules-based swing-trading indicator designed primarily for traders who use the **daily chart** and want a simple way to combine trend, momentum, volume, volatility, entry quality, and risk management into one TradingView script.

The indicator is built around a **trend + pullback/breakout + confirmation** approach. Instead of relying on a single indicator, it combines several commonly used technical tools to identify higher-quality swing-trading setups.

## Main Features

Daily Swing Trader PRO includes:

* 10 EMA
* 21 EMA
* 50 SMA
* 200 SMA
* SuperTrend
* RSI
* Relative Volume (RVOL)
* ATR and ATR %
* Bullish pullback detection
* Bullish breakout detection
* Bearish breakdown detection
* Bearish failed-rally detection
* BUY signals
* STRONG BUY signals
* SELL signals
* STRONG SELL signals
* Automatic entry level
* Automatic stop-loss level
* Configurable reward/risk target
* TAKE PROFIT signals
* STOP LOSS signals
* Detailed TradingView alerts
* Daily Swing dashboard
* Signal notification panel
* Automatic light/dark chart theme support

## Trading Philosophy

The indicator follows a simple principle:

**Trend first → Price action second → Volume and momentum confirmation → Risk/reward → Trade**

Indicators are used as confirmation rather than as standalone reasons to enter a trade.

The goal is to avoid weak setups, avoid chasing extended stocks, and focus on trades where multiple technical factors are aligned.

# How to Use Daily Swing Trader PRO

## Recommended Timeframe

The indicator is designed primarily for the:

**1-Day / Daily chart**

The default settings are optimized around daily-chart swing trading.

## Bullish Trend Requirements

The script looks for a bullish environment when:

* Price is above the 50 SMA
* Price is above the 200 SMA
* Price is above the 21 EMA
* 10 EMA is above the 21 EMA
* 21 EMA is rising
* SuperTrend is bullish
* RSI is above 50
* Relative volume meets the selected minimum
* ATR volatility meets the minimum requirement
* Price is not excessively extended above the 21 EMA

These conditions help reduce signals that occur during weak or sideways trends.

## BUY Signal

A **BUY** signal can occur when the bullish trend requirements are satisfied and one of the following setups appears:

### Pullback Setup

Price pulls back toward the 10 EMA or 21 EMA and then shows bullish confirmation.

Typical confirmation includes:

* Price holding the EMA support area
* Bullish daily candle
* Close above the previous day's high
* Price closing back above the 10 EMA and 21 EMA
* Adequate relative volume

This setup attempts to enter an existing trend after a controlled pullback instead of chasing price.

### Breakout Setup

A breakout setup occurs when price closes above the highest price of the selected breakout lookback period.

The indicator also requires bullish trend, momentum, volume, and volatility conditions before generating the signal.

## STRONG BUY Signal

A **STRONG BUY** requires the normal BUY conditions plus stronger confirmation.

Default requirements include:

* Bullish trend
* Valid pullback or breakout
* RSI approximately 55–70
* RVOL of at least 1.20
* Strong bullish candle close
* Price not excessively extended
* Bullish SuperTrend

STRONG BUY is intended to identify the highest-quality bullish setups produced by the system.

## SELL Signal

SELL is the bearish counterpart to BUY.

The script looks for:

* Price below the 50 SMA
* Price below the 200 SMA
* Price below the 21 EMA
* 10 EMA below the 21 EMA
* Falling 21 EMA
* Bearish SuperTrend
* RSI below 50
* Adequate relative volume and volatility

A SELL signal may occur after either a bearish breakdown or a failed rally into resistance.

For traders who only trade long positions, SELL can also be used as a warning that bullish conditions have deteriorated.

## STRONG SELL Signal

A **STRONG SELL** requires additional bearish momentum and volume confirmation.

It is designed to identify the strongest bearish setups and may be useful for traders evaluating short positions or long-put option setups.

# Entry, Stop and Take Profit

When a new trade signal appears, the script automatically calculates:

**Entry:** Signal candle closing price

**Stop Loss:** Based on the recent swing high or swing low plus an ATR buffer

**Take Profit:** Based on the selected reward/risk multiple

The default target is:

**2R — approximately 2:1 reward/risk**

Example:

Entry: $100
Stop: $95
Risk: $5
2R Take Profit: $110

The reward/risk target can be adjusted in the indicator settings.

## Stop-Loss Logic

For long trades, the stop is placed below a recent swing low.

For bearish trades, the stop is placed above a recent swing high.

An ATR buffer is added to reduce the chance of being stopped out by normal price movement.

## Take-Profit Logic

When price reaches the calculated target, the indicator produces a:

**TAKE PROFIT**

signal.

The script also tracks STOP LOSS events.

Because a daily candle only provides open, high, low, and close information, if both the stop and profit target are touched on the same daily candle, the script uses the conservative assumption that the stop was reached first.

# Avoiding Extended Trades

One of the most important filters in Daily Swing Trader PRO is the **maximum extension from the 21 EMA**.

The default is:

**2 ATR**

If price becomes too extended above or below the 21 EMA, new entries are filtered out.

This is designed to reduce late entries after unusually large price moves.

# Relative Volume

Relative Volume compares current volume with average recent volume.

Default values:

Normal signal: **RVOL ≥ 1.00**

Strong signal: **RVOL ≥ 1.20**

Higher RVOL generally indicates stronger participation behind the move.

# RSI

RSI is used as a momentum filter rather than simply as an overbought/oversold indicator.

For bullish trades, the script generally looks for RSI above 50.

STRONG BUY signals typically require RSI in the stronger momentum zone of approximately:

**55–70**

Bearish signals use the opposite momentum structure.

# ATR

ATR is used for several purposes:

* Measuring volatility
* Preventing trades in stocks with insufficient movement
* Measuring price extension
* Calculating stop buffers
* Helping evaluate swing-trading opportunity

The dashboard displays both ATR and ATR as a percentage of price.

# Dashboard

The **Daily Swing Dashboard** appears in the top-right corner of the chart.

It displays information such as:

* Current trend
* Trade status
* Last signal
* Setup type
* RSI
* RVOL
* ATR
* ATR %
* Entry
* Stop
* Profit target

The **Signal Notification Panel** appears in the bottom-right corner and displays the most recent trading event.

# TradingView Alerts

The indicator includes individual alert conditions for:

* STRONG BUY
* BUY
* STRONG SELL
* SELL
* TAKE PROFIT
* STOP LOSS

Detailed alerts can include:

* Ticker
* Current price
* Entry
* Stop
* Take-profit target
* Reward/risk
* RSI
* RVOL
* ATR
* ATR %

For daily swing trading, alerts are best evaluated after the daily candle has closed so that the setup is confirmed.

# Suggested Workflow

A practical workflow is:

1. Start with stocks already showing a strong trend.
2. Use the daily chart.
3. Wait for BUY or STRONG BUY rather than chasing large candles.
4. Check nearby support and resistance.
5. Confirm that the profit target has enough room before major resistance.
6. Review earnings and major market-event risk.
7. Enter only if the chart still offers acceptable reward/risk.
8. Use the calculated stop rather than widening the stop after entering.
9. Take profit at the target or manage the position with your own trailing-stop rules.

For conservative use, traders may choose to treat:

**STRONG BUY / STRONG SELL = potential trade signals**

and

**BUY / SELL = watchlist or early-warning signals**

# Default Settings

The default settings are intended as a starting point:

10 EMA: 10
21 EMA: 21
50 SMA: 50
200 SMA: 200
SuperTrend ATR: 10
SuperTrend Factor: 3.0
RSI: 14
RVOL Lookback: 20
Normal RVOL: 1.00
Strong RVOL: 1.20
ATR: 14
Maximum Extension: 2 ATR
Swing Stop Lookback: 5 bars
Take Profit: 2R

Different securities and market conditions may require different settings.

# Important Notes

Daily Swing Trader PRO is not designed to predict the market.

No technical indicator can guarantee profitable trades. Signals should be combined with proper position sizing, risk management, market context, support and resistance, earnings awareness, and individual trading judgment.

Historical signals do not guarantee future performance.

This indicator is provided for educational and informational purposes only and should not be considered financial or investment advice.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © jcking48

//@version=6
indicator("Daily Swing Trader PRO v3.2 - Theme Safe", overlay=true, max_labels_count=500)

// ============================================================================
// INPUT GROUPS
// ============================================================================

grpTrend = "1. Trend Settings"
grpSetup = "2. Setup Settings"
grpVolume = "3. Volume / Momentum"
grpRisk = "4. Risk Management"
grpVisual = "5. Display"

// ============================================================================
// INPUTS
// ============================================================================

fastLen = input.int(10, "Fast EMA", minval=1, group=grpTrend)
slowLen = input.int(21, "Pullback EMA", minval=1, group=grpTrend)
sma50Len = input.int(50, "Trend SMA", minval=1, group=grpTrend)
sma200Len = input.int(200, "Major Trend SMA", minval=1, group=grpTrend)

stAtrLen = input.int(10, "SuperTrend ATR Length", minval=1, group=grpTrend)
stFactor = input.float(3.0, "SuperTrend Factor", minval=0.1, step=0.1, group=grpTrend)

breakoutLen = input.int(10, "Breakout Lookback", minval=3, maxval=50, group=grpSetup)
pullbackATRAllowance = input.float(0.75, "Pullback Zone ATR Allowance", minval=0.10, step=0.05, group=grpSetup)
maxExtensionATR = input.float(2.0, "Maximum Extension From 21 EMA", minval=0.50, step=0.25, group=grpSetup)

rsiLen = input.int(14, "RSI Length", minval=2, group=grpVolume)
volumeLen = input.int(20, "RVOL Lookback", minval=5, group=grpVolume)
minRVOL = input.float(1.00, "Minimum RVOL - Normal Signal", minval=0.10, step=0.05, group=grpVolume)
strongRVOL = input.float(1.20, "Minimum RVOL - Strong Signal", minval=0.10, step=0.05, group=grpVolume)

atrLen = input.int(14, "ATR Length", minval=1, group=grpVolume)
minATRPct = input.float(0.75, "Minimum ATR % of Price", minval=0, step=0.05, group=grpVolume)

stopLookback = input.int(5, "Swing Stop Lookback", minval=2, maxval=20, group=grpRisk)
stopBufferATR = input.float(0.10, "Stop Buffer - ATR", minval=0, step=0.05, group=grpRisk)
rewardRisk = input.float(2.0, "Take Profit - R Multiple", minval=1.0, step=0.25, group=grpRisk)

dailyOnly = input.bool(true, "Require Daily Chart", group=grpVisual)
showMAs = input.bool(true, "Show Moving Averages", group=grpVisual)
showSuperTrend = input.bool(true, "Show SuperTrend", group=grpVisual)
showTradeLevels = input.bool(true, "Show Entry / Stop / Take Profit", group=grpVisual)
colorSignalBars = input.bool(true, "Color Signal Bars", group=grpVisual)
showDashboard = input.bool(true, "Show Daily Swing Dashboard", group=grpVisual)
showNotification = input.bool(true, "Show Signal Notification Panel", group=grpVisual)

// ============================================================================
// THEME-SAFE COLORS
// ============================================================================

panelBackground = chart.bg_color
panelText = chart.fg_color
panelBorder = color.new(chart.fg_color, 55)

contrastText(color bg) =>
    float brightness = (color.r(bg) + color.g(bg) + color.b(bg)) / (3.0 * 255.0)
    brightness > 0.5 ? color.black : color.white

formatPrice(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

formatOne(float value) =>
    na(value) ? "-" : str.tostring(value, "#.0")

formatTwo(float value) =>
    na(value) ? "-" : str.tostring(value, "#.00")

// ============================================================================
// INDICATORS
// ============================================================================

ema10 = ta.ema(close, fastLen)
ema21 = ta.ema(close, slowLen)
sma50 = ta.sma(close, sma50Len)
sma200 = ta.sma(close, sma200Len)

rsi = ta.rsi(close, rsiLen)
atr = ta.atr(atrLen)
atrPct = close != 0 ? (atr / close) * 100 : na

volumeAverage = ta.sma(volume, volumeLen)
rvol = volumeAverage > 0 ? volume / volumeAverage : na

[superTrend, stDirection] = ta.supertrend(stFactor, stAtrLen)

stBull = stDirection < 0
stBear = stDirection > 0

validTimeframe = not dailyOnly or timeframe.isdaily
confirmedBar = barstate.isconfirmed

// ============================================================================
// TREND CONDITIONS
// ============================================================================

bullTrend = (
    close > sma50 and
    close > sma200 and
    close > ema21 and
    ema10 > ema21 and
    ema21 > ema21[1]
)

bearTrend = (
    close < sma50 and
    close < sma200 and
    close < ema21 and
    ema10 < ema21 and
    ema21 < ema21[1]
)

// ============================================================================
// EXTENSION AND ATR FILTERS
// ============================================================================

longExtension = atr > 0 ? (close - ema21) / atr : na
shortExtension = atr > 0 ? (ema21 - close) / atr : na

notExtendedLong = not na(longExtension) and longExtension <= maxExtensionATR
notExtendedShort = not na(shortExtension) and shortExtension <= maxExtensionATR

atrOK = not na(atrPct) and atrPct >= minATRPct

// ============================================================================
// SETUPS
// ============================================================================

breakoutLevel = ta.highest(high[1], breakoutLen)
breakdownLevel = ta.lowest(low[1], breakoutLen)

bullBreakout = close > breakoutLevel and close > open

bullPullbackZone = low <= ema10 and low >= ema21 - atr * pullbackATRAllowance

bullPullback = (
    bullPullbackZone and
    close > ema10 and
    close > ema21 and
    close > high[1] and
    close > open
)

bearBreakdown = close < breakdownLevel and close < open

bearRallyZone = high >= ema10 and high <= ema21 + atr * pullbackATRAllowance

bearFailedRally = (
    bearRallyZone and
    close < ema10 and
    close < ema21 and
    close < low[1] and
    close < open
)

// ============================================================================
// CANDLE QUALITY
// ============================================================================

barRange = high - low

strongBullClose = barRange <= 0 or close >= high - barRange * 0.25
strongBearClose = barRange <= 0 or close <= low + barRange * 0.25

// ============================================================================
// BASE CONDITIONS
// ============================================================================

bullBase = (
    validTimeframe and
    confirmedBar and
    bullTrend and
    stBull and
    rsi > 50 and
    rsi < 75 and
    rvol >= minRVOL and
    atrOK and
    notExtendedLong
)

bearBase = (
    validTimeframe and
    confirmedBar and
    bearTrend and
    stBear and
    rsi < 50 and
    rsi > 25 and
    rvol >= minRVOL and
    atrOK and
    notExtendedShort
)

// ============================================================================
// RAW SIGNAL CONDITIONS
// ============================================================================

buyRaw = bullBase and (bullBreakout or bullPullback)

strongBuyRaw = (
    bullBase and
    rsi >= 55 and
    rsi <= 70 and
    rvol >= strongRVOL and
    strongBullClose and
    (bullBreakout or bullPullback)
)

sellRaw = bearBase and (bearBreakdown or bearFailedRally)

strongSellRaw = (
    bearBase and
    rsi >= 30 and
    rsi <= 45 and
    rvol >= strongRVOL and
    strongBearClose and
    (bearBreakdown or bearFailedRally)
)

// ============================================================================
// NEW SIGNALS
// ============================================================================

newStrongBuy = strongBuyRaw and not strongBuyRaw[1]
newBuy = buyRaw and not strongBuyRaw and not buyRaw[1]

newStrongSell = strongSellRaw and not strongSellRaw[1]
newSell = sellRaw and not strongSellRaw and not sellRaw[1]

// ============================================================================
// STOPS
// ============================================================================

longStopCandidate = ta.lowest(low, stopLookback) - atr * stopBufferATR
shortStopCandidate = ta.highest(high, stopLookback) + atr * stopBufferATR

// ============================================================================
// TRADE TRACKING
// ============================================================================

var float lastEntry = na
var float lastStop = na
var float lastTarget = na

var string lastSignal = "NONE"
var string lastSetup = "NONE"
var string lastExit = "NONE"

var int tradeDirection = 0
var int entryBar = na

// ============================================================================
// NOTIFICATION TRACKING
// ============================================================================

var string lastEvent = "NO SIGNAL YET"
var color lastEventColor = color.gray

var float eventPrice = na
var float eventRSI = na
var float eventRVOL = na
var float eventATR = na
var float eventATRPct = na

// ============================================================================
// ACTIVE TRADE CHECK
// ============================================================================

canCheckTrade = tradeDirection != 0 and not na(entryBar) and bar_index > entryBar

longStopTouched = canCheckTrade and tradeDirection == 1 and low <= lastStop
longTargetTouched = canCheckTrade and tradeDirection == 1 and high >= lastTarget

shortStopTouched = canCheckTrade and tradeDirection == -1 and high >= lastStop
shortTargetTouched = canCheckTrade and tradeDirection == -1 and low <= lastTarget

stopLossSignal = confirmedBar and (longStopTouched or shortStopTouched)

takeProfitSignal = (
    confirmedBar and
    not stopLossSignal and
    (longTargetTouched or shortTargetTouched)
)

// ============================================================================
// PROCESS EXITS
// ============================================================================

if stopLossSignal
    lastExit := "STOP LOSS"
    lastEvent := "STOP LOSS"
    lastEventColor := color.red
    eventPrice := lastStop
    eventRSI := rsi
    eventRVOL := rvol
    eventATR := atr
    eventATRPct := atrPct
    tradeDirection := 0

if takeProfitSignal
    lastExit := "TAKE PROFIT"
    lastEvent := "TAKE PROFIT"
    lastEventColor := color.aqua
    eventPrice := lastTarget
    eventRSI := rsi
    eventRVOL := rvol
    eventATR := atr
    eventATRPct := atrPct
    tradeDirection := 0

// ============================================================================
// ENTRY SIGNALS
// ============================================================================

canEnter = tradeDirection == 0 and not stopLossSignal and not takeProfitSignal

strongBuySignal = canEnter and newStrongBuy
buySignal = canEnter and newBuy

strongSellSignal = canEnter and newStrongSell
sellSignal = canEnter and newSell

bullSetupText = bullBreakout ? "BREAKOUT" : "PULLBACK"
bearSetupText = bearBreakdown ? "BREAKDOWN" : "FAILED RALLY"

// ============================================================================
// PROCESS LONG ENTRY
// ============================================================================

if strongBuySignal or buySignal
    lastEntry := close
    lastStop := longStopCandidate

    float longRisk = lastEntry - lastStop
    lastTarget := lastEntry + longRisk * rewardRisk

    lastSignal := strongBuySignal ? "STRONG BUY" : "BUY"
    lastSetup := bullSetupText
    lastExit := "ACTIVE"

    tradeDirection := 1
    entryBar := bar_index

    lastEvent := strongBuySignal ? "STRONG BUY" : "BUY"
    lastEventColor := strongBuySignal ? color.lime : color.green

    eventPrice := lastEntry
    eventRSI := rsi
    eventRVOL := rvol
    eventATR := atr
    eventATRPct := atrPct

// ============================================================================
// PROCESS SHORT ENTRY
// ============================================================================

if strongSellSignal or sellSignal
    lastEntry := close
    lastStop := shortStopCandidate

    float shortRisk = lastStop - lastEntry
    lastTarget := lastEntry - shortRisk * rewardRisk

    lastSignal := strongSellSignal ? "STRONG SELL" : "SELL"
    lastSetup := bearSetupText
    lastExit := "ACTIVE"

    tradeDirection := -1
    entryBar := bar_index

    lastEvent := strongSellSignal ? "STRONG SELL" : "SELL"
    lastEventColor := strongSellSignal ? color.red : color.orange

    eventPrice := lastEntry
    eventRSI := rsi
    eventRVOL := rvol
    eventATR := atr
    eventATRPct := atrPct

// ============================================================================
// MOVING AVERAGES
// ============================================================================

plot(showMAs ? ema10 : na, title="10 EMA", color=color.aqua, linewidth=2)
plot(showMAs ? ema21 : na, title="21 EMA", color=color.orange, linewidth=2)
plot(showMAs ? sma50 : na, title="50 SMA", color=color.blue, linewidth=2)
plot(showMAs ? sma200 : na, title="200 SMA", color=color.purple, linewidth=2)

// ============================================================================
// SUPERTREND
// ============================================================================

plot(showSuperTrend and stBull ? superTrend : na, title="Bullish SuperTrend", color=color.green, linewidth=2, style=plot.style_linebr)
plot(showSuperTrend and stBear ? superTrend : na, title="Bearish SuperTrend", color=color.red, linewidth=2, style=plot.style_linebr)

// ============================================================================
// ENTRY / STOP / TARGET
// ============================================================================

plot(showTradeLevels ? lastEntry : na, title="Entry", color=color.blue, linewidth=2, style=plot.style_linebr)
plot(showTradeLevels ? lastStop : na, title="Stop Loss", color=color.red, linewidth=2, style=plot.style_linebr)
plot(showTradeLevels ? lastTarget : na, title="Take Profit", color=color.green, linewidth=2, style=plot.style_linebr)

// ============================================================================
// HIDDEN ALERT PLOTS
// ============================================================================

plot(lastEntry, title="Alert Entry", display=display.none)
plot(lastStop, title="Alert Stop", display=display.none)
plot(lastTarget, title="Alert Target", display=display.none)
plot(rewardRisk, title="Alert RR", display=display.none)
plot(rsi, title="Alert RSI", display=display.none)
plot(rvol, title="Alert RVOL", display=display.none)
plot(atr, title="Alert ATR", display=display.none)
plot(atrPct, title="Alert ATR Percent", display=display.none)

// ============================================================================
// SIGNAL LABELS
// ============================================================================

plotshape(strongBuySignal, title="Strong Buy", text="STRONG\nBUY", style=shape.labelup, location=location.belowbar, color=color.lime, textcolor=color.black, size=size.small)

plotshape(buySignal, title="Buy", text="BUY", style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white, size=size.small)

plotshape(strongSellSignal, title="Strong Sell", text="STRONG\nSELL", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.small)

plotshape(sellSignal, title="Sell", text="SELL", style=shape.labeldown, location=location.abovebar, color=color.orange, textcolor=color.black, size=size.small)

plotshape(takeProfitSignal, title="Take Profit", text="TAKE\nPROFIT", style=shape.labeldown, location=location.abovebar, color=color.aqua, textcolor=color.black, size=size.small)

plotshape(stopLossSignal, title="Stop Loss", text="STOP\nLOSS", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.small)

// ============================================================================
// BAR COLORS
// ============================================================================

signalBarColor = (
    strongBuySignal ? color.lime :
    buySignal ? color.green :
    strongSellSignal ? color.red :
    sellSignal ? color.orange :
    takeProfitSignal ? color.aqua :
    stopLossSignal ? color.red :
    na
)

barcolor(colorSignalBars ? signalBarColor : na)

// ============================================================================
// WRONG TIMEFRAME WARNING
// ============================================================================

bgcolor(dailyOnly and not timeframe.isdaily ? color.new(color.orange, 88) : na)

// ============================================================================
// SIGNAL NOTIFICATION PANEL
// BOTTOM RIGHT
// ============================================================================

var table signalPanel = table.new(
    position.bottom_right,
    2,
    8,
    bgcolor=panelBackground,
    frame_color=panelBorder,
    frame_width=2,
    border_color=panelBorder,
    border_width=1
)

eventHeaderBackground = lastEvent == "NO SIGNAL YET" ? chart.fg_color : lastEventColor
eventHeaderText = lastEvent == "NO SIGNAL YET" ? chart.bg_color : contrastText(eventHeaderBackground)

if barstate.islast and showNotification
    table.cell(signalPanel, 0, 0, "SIGNAL", bgcolor=eventHeaderBackground, text_color=eventHeaderText, text_size=size.large)
    table.cell(signalPanel, 1, 0, lastEvent, bgcolor=eventHeaderBackground, text_color=eventHeaderText, text_size=size.large)

    table.cell(signalPanel, 0, 1, "Setup", bgcolor=panelBackground, text_color=panelText)
    table.cell(signalPanel, 1, 1, lastSetup, bgcolor=panelBackground, text_color=panelText)

    table.cell(signalPanel, 0, 2, "Signal Price", bgcolor=panelBackground, text_color=panelText)
    table.cell(signalPanel, 1, 2, formatPrice(eventPrice), bgcolor=panelBackground, text_color=panelText)

    table.cell(signalPanel, 0, 3, "Entry", bgcolor=panelBackground, text_color=panelText)
    table.cell(signalPanel, 1, 3, formatPrice(lastEntry), bgcolor=panelBackground, text_color=panelText)

    table.cell(signalPanel, 0, 4, "Stop", bgcolor=panelBackground, text_color=panelText)
    table.cell(signalPanel, 1, 4, formatPrice(lastStop), bgcolor=panelBackground, text_color=panelText)

    table.cell(signalPanel, 0, 5, "Take Profit", bgcolor=panelBackground, text_color=panelText)
    table.cell(signalPanel, 1, 5, formatPrice(lastTarget), bgcolor=panelBackground, text_color=panelText)

    table.cell(signalPanel, 0, 6, "RSI / RVOL", bgcolor=panelBackground, text_color=panelText)
    table.cell(signalPanel, 1, 6, formatOne(eventRSI) + " / " + formatTwo(eventRVOL), bgcolor=panelBackground, text_color=panelText)

    table.cell(signalPanel, 0, 7, "ATR / ATR%", bgcolor=panelBackground, text_color=panelText)
    table.cell(signalPanel, 1, 7, formatPrice(eventATR) + " / " + formatTwo(eventATRPct) + "%", bgcolor=panelBackground, text_color=panelText)

// ============================================================================
// DAILY SWING DASHBOARD
// TOP RIGHT
// ============================================================================

var table dashboard = table.new(
    position.top_right,
    2,
    11,
    bgcolor=panelBackground,
    frame_color=panelBorder,
    frame_width=2,
    border_color=panelBorder,
    border_width=1
)

trendText = bullTrend ? "BULLISH" : bearTrend ? "BEARISH" : "MIXED"
trendColor = bullTrend ? color.green : bearTrend ? color.red : color.orange

tradeStatus = tradeDirection == 1 ? "LONG ACTIVE" : tradeDirection == -1 ? "SHORT ACTIVE" : "NO ACTIVE TRADE"

tradeStatusColor = tradeDirection == 1 ? color.green : tradeDirection == -1 ? color.red : color.gray

if barstate.islast and showDashboard
    table.cell(dashboard, 0, 0, "DAILY SWING", bgcolor=chart.fg_color, text_color=chart.bg_color)
    table.cell(dashboard, 1, 0, validTimeframe ? "1D READY" : "USE 1D", bgcolor=validTimeframe ? color.green : color.red, text_color=color.white)

    table.cell(dashboard, 0, 1, "Trend", bgcolor=panelBackground, text_color=panelText)
    table.cell(dashboard, 1, 1, trendText, bgcolor=trendColor, text_color=contrastText(trendColor))

    table.cell(dashboard, 0, 2, "Trade Status", bgcolor=panelBackground, text_color=panelText)
    table.cell(dashboard, 1, 2, tradeStatus, bgcolor=tradeStatusColor, text_color=contrastText(tradeStatusColor))

    table.cell(dashboard, 0, 3, "Last Signal", bgcolor=panelBackground, text_color=panelText)
    table.cell(dashboard, 1, 3, lastSignal, bgcolor=panelBackground, text_color=panelText)

    table.cell(dashboard, 0, 4, "Setup", bgcolor=panelBackground, text_color=panelText)
    table.cell(dashboard, 1, 4, lastSetup, bgcolor=panelBackground, text_color=panelText)

    table.cell(dashboard, 0, 5, "RSI", bgcolor=panelBackground, text_color=panelText)
    table.cell(dashboard, 1, 5, formatOne(rsi), bgcolor=panelBackground, text_color=panelText)

    table.cell(dashboard, 0, 6, "RVOL", bgcolor=panelBackground, text_color=panelText)
    table.cell(dashboard, 1, 6, formatTwo(rvol), bgcolor=panelBackground, text_color=panelText)

    table.cell(dashboard, 0, 7, "ATR / ATR%", bgcolor=panelBackground, text_color=panelText)
    table.cell(dashboard, 1, 7, formatPrice(atr) + " / " + formatTwo(atrPct) + "%", bgcolor=panelBackground, text_color=panelText)

    table.cell(dashboard, 0, 8, "Entry", bgcolor=panelBackground, text_color=panelText)
    table.cell(dashboard, 1, 8, formatPrice(lastEntry), bgcolor=panelBackground, text_color=panelText)

    table.cell(dashboard, 0, 9, "Stop", bgcolor=panelBackground, text_color=panelText)
    table.cell(dashboard, 1, 9, formatPrice(lastStop), bgcolor=panelBackground, text_color=panelText)

    table.cell(dashboard, 0, 10, str.tostring(rewardRisk, "#.0") + "R Target", bgcolor=panelBackground, text_color=panelText)
    table.cell(dashboard, 1, 10, formatPrice(lastTarget), bgcolor=panelBackground, text_color=panelText)

// ============================================================================
// DETAILED ALERTS
// ============================================================================

alertcondition(
    strongBuySignal,
    title="STRONG BUY - Detailed",
    message='STRONG BUY | {{exchange}}:{{ticker}} | Close: {{close}} | Entry: {{plot("Alert Entry")}} | Stop: {{plot("Alert Stop")}} | Take Profit: {{plot("Alert Target")}} | R/R: {{plot("Alert RR")}}R | RSI: {{plot("Alert RSI")}} | RVOL: {{plot("Alert RVOL")}} | ATR: {{plot("Alert ATR")}} | ATR%: {{plot("Alert ATR Percent")}}'
)

alertcondition(
    buySignal,
    title="BUY - Detailed",
    message='BUY | {{exchange}}:{{ticker}} | Close: {{close}} | Entry: {{plot("Alert Entry")}} | Stop: {{plot("Alert Stop")}} | Take Profit: {{plot("Alert Target")}} | R/R: {{plot("Alert RR")}}R | RSI: {{plot("Alert RSI")}} | RVOL: {{plot("Alert RVOL")}} | ATR: {{plot("Alert ATR")}} | ATR%: {{plot("Alert ATR Percent")}}'
)

alertcondition(
    strongSellSignal,
    title="STRONG SELL - Detailed",
    message='STRONG SELL | {{exchange}}:{{ticker}} | Close: {{close}} | Entry: {{plot("Alert Entry")}} | Stop: {{plot("Alert Stop")}} | Take Profit: {{plot("Alert Target")}} | R/R: {{plot("Alert RR")}}R | RSI: {{plot("Alert RSI")}} | RVOL: {{plot("Alert RVOL")}} | ATR: {{plot("Alert ATR")}} | ATR%: {{plot("Alert ATR Percent")}}'
)

alertcondition(
    sellSignal,
    title="SELL - Detailed",
    message='SELL | {{exchange}}:{{ticker}} | Close: {{close}} | Entry: {{plot("Alert Entry")}} | Stop: {{plot("Alert Stop")}} | Take Profit: {{plot("Alert Target")}} | R/R: {{plot("Alert RR")}}R | RSI: {{plot("Alert RSI")}} | RVOL: {{plot("Alert RVOL")}} | ATR: {{plot("Alert ATR")}} | ATR%: {{plot("Alert ATR Percent")}}'
)

alertcondition(
    takeProfitSignal,
    title="TAKE PROFIT - Detailed",
    message='TAKE PROFIT | {{exchange}}:{{ticker}} | Close: {{close}} | Entry: {{plot("Alert Entry")}} | Target: {{plot("Alert Target")}} | Stop: {{plot("Alert Stop")}}'
)

alertcondition(
    stopLossSignal,
    title="STOP LOSS - Detailed",
    message='STOP LOSS | {{exchange}}:{{ticker}} | Close: {{close}} | Entry: {{plot("Alert Entry")}} | Stop: {{plot("Alert Stop")}} | Planned Target: {{plot("Alert Target")}}'
)
````
