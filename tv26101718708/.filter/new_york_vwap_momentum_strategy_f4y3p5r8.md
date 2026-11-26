# New York VWAP Momentum Strategy

- url: https://www.tradingview.com/script/f4y3p5r8-New-York-VWAP-Momentum-Strategy/
- type: strategy
- pine_id: PUB;4addc9edfc634c48b7429e94ac8991a0
- version: 1.0

## Description

[b]New York VWAP Momentum Strategy[/b]

[b]This strategy is designed to identify momentum entries during the New York trading session using VWAP as the primary dynamic support/resistance level. It combines trend-following logic with strict risk management controls to help traders manage their daily trade frequency and exposure.[/b]
[b]Key Features[/b]
Dynamic VWAP Filtering: Trades are only taken in the direction of the momentum when price is respecting the Session VWAP.

Customizable Time & Day Filters: Fully configurable session timing and individual day-of-week toggles to ensure you only trade when the market conditions suit your strategy.

Intelligent Trade Management: * Max Daily Trades: Limit of two trades per day.

Loss-Sequence Logic: The strategy restricts entering a second trade unless the first trade of the day resulted in a loss.

Volume Confirmation: Optional volume filter to ensure momentum is supported by market participation.

Risk Management: Automatically calculates Take Profit levels based on a customizable Risk-Reward Ratio, with the Stop Loss fixed at the VWAP level.

[b]Strategy Logic[/b]
Long Entries: Triggered when two consecutive green candles close above the VWAP, with volume increasing, and the session time filter is active.

Short Entries: Triggered when two consecutive red candles close below the VWAP, with volume increasing, and the session time filter is active.

Stop Loss: Placed at the current VWAP value at the time of entry.

Take Profit: Determined by the Risk-Reward Ratio setting.
[b]How to use[/b]
Add the script to your chart.

Adjust the "Monitoring Session" time to match your specific asset's liquidity or your local time zone settings.

Configure your desired Risk-Reward Ratio in the Settings menu.

Toggle specific days of the week on/off according to your preference.
[b]Disclaimer:[/b]
Trading in financial markets involves a high level of risk and may not be suitable for all investors. Past performance is not indicative of future results. This script is for educational and informational purposes only and does not constitute financial, investment, or trading advice. Use this tool at your own risk.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo AI Assistant

//@version=6
strategy("New York VWAP Momentum Strategy", overlay=true, initial_capital=10000, default_qty_type=strategy.percent_of_equity, default_qty_value=10)

// =========================================================================
// INPUTS
// =========================================================================
// Strategy Settings
riskRewardRatio = input.float(1.5, title="Risk Reward Ratio", group="Strategy Settings")
useVolumeFilter = input.bool(true, title="Enable Volume Filter", group="Strategy Settings")

// Time Settings
// Updated to start at 19:00 PKT
sessionTime     = input.session("1900-2359", title="Monitoring Session (PKT)", group="Time Settings")
timeZone        = "UTC+5"

// Days to Trade
tradeMonday     = input.bool(true,  title="Trade Monday",    group="Days to Trade")
tradeTuesday    = input.bool(true,  title="Trade Tuesday",   group="Days to Trade")
tradeWednesday  = input.bool(true,  title="Trade Wednesday", group="Days to Trade")
tradeThursday   = input.bool(true,  title="Trade Thursday",  group="Days to Trade")
tradeFriday     = input.bool(true,  title="Trade Friday",    group="Days to Trade")
tradeSaturday   = input.bool(false, title="Trade Saturday",  group="Days to Trade")
tradeSunday     = input.bool(false, title="Trade Sunday",    group="Days to Trade")

// Visual Settings
vwapColor       = input.color(color.blue, title="VWAP Color", group="Visual Settings")
buyColor        = input.color(color.green, title="Buy Arrow Color", group="Visual Settings")
sellColor       = input.color(color.red, title="Sell Arrow Color", group="Visual Settings")

// =========================================================================
// TIME & SESSION LOGIC
// =========================================================================
inSession = not na(time(timeframe.period, sessionTime, timeZone))

nySessionStart = "1830-2359"
inNySession = not na(time(timeframe.period, nySessionStart, timeZone))
isNewSession = inNySession and not inNySession[1]

// =========================================================================
// VWAP CALCULATION
// =========================================================================
var float sumSrcVol = 0.0
var float sumVol    = 0.0

if isNewSession
    sumSrcVol := hlc3 * volume
    sumVol    := volume
else if inNySession
    sumSrcVol += hlc3 * volume
    sumVol    += volume

sessionVWAP = sumVol > 0 ? sumSrcVol / sumVol : na

plot(sessionVWAP, color=vwapColor, title="Session VWAP", linewidth=2)

// =========================================================================
// ENTRY CONDITIONS
// =========================================================================

// --- DAY FILTERS & 2ND TRADE ALLOWED ONLY IF 1ST IS A LOSS ---
currentDay = dayofweek(time, timeZone)
isAllowedDay = (currentDay == dayofweek.monday and tradeMonday) or
               (currentDay == dayofweek.tuesday and tradeTuesday) or
               (currentDay == dayofweek.wednesday and tradeWednesday) or
               (currentDay == dayofweek.thursday and tradeThursday) or
               (currentDay == dayofweek.friday and tradeFriday) or
               (currentDay == dayofweek.saturday and tradeSaturday) or
               (currentDay == dayofweek.sunday and tradeSunday)

var int startTrades = 0
if ta.change(time("D", timeZone)) != 0
    startTrades := strategy.closedtrades

tradesClosedToday = strategy.closedtrades - startTrades

bool isFirstTradeLoss = false
if tradesClosedToday == 1
    if strategy.closedtrades > 0
        if strategy.closedtrades.profit(strategy.closedtrades - 1) < 0
            isFirstTradeLoss := true

canTradeToday = tradesClosedToday == 0 or (tradesClosedToday == 1 and isFirstTradeLoss)

// --- UPDATED ENTRY LOGIC: 2 CONSECUTIVE CANDLES, VOLUME, VWAP & NO DOJI ---
// Doji logic: Body size <= 10% of total candle range
bodySize = math.abs(close - open)
candleRange = high - low
isDoji = bodySize <= (candleRange * 0.1)

// Long: 2 Green, Volume >= 1.5x previous, Low > VWAP, No Doji
bullCandle1 = close[1] > open[1]
bullCandle2 = close > open
volRequirementLong = volume >= (volume[1] * 1.5)
lowNotTouchingVWAP = low > sessionVWAP 

longCondition = inSession and bullCandle1 and bullCandle2 and volRequirementLong and lowNotTouchingVWAP and not isDoji and strategy.position_size == 0 and isAllowedDay and canTradeToday

// Short: 2 Red, Volume >= 1.5x previous, High < VWAP, No Doji
bearCandle1 = close[1] < open[1]
bearCandle2 = close < open
volRequirementShort = volume >= (volume[1] * 1.5)
highNotTouchingVWAP = high < sessionVWAP

shortCondition = inSession and bearCandle1 and bearCandle2 and volRequirementShort and highNotTouchingVWAP and not isDoji and strategy.position_size == 0 and isAllowedDay and canTradeToday

// =========================================================================
// EXECUTION & TRADE MANAGEMENT
// =========================================================================
var float sl = na
var float tp = na

if longCondition
    sl := sessionVWAP
    risk = close - sl
    tp := close + (risk * riskRewardRatio)
    
    strategy.entry("Long", strategy.long)
    strategy.exit("Exit Long", "Long", stop=sl, limit=tp)
    
    alert("Long Entry", alert.freq_once_per_bar_close)

if shortCondition
    sl := sessionVWAP
    risk = sl - close
    tp := close - (risk * riskRewardRatio)
    
    strategy.entry("Short", strategy.short)
    strategy.exit("Exit Short", "Short", stop=sl, limit=tp)
    
    alert("Short Entry", alert.freq_once_per_bar_close)

// Alert for TP/SL hits
if strategy.position_size > 0
    if low <= sl
        alert("Stop Loss Hit - Long", alert.freq_once_per_bar_close)
    if high >= tp
        alert("Take Profit Hit - Long", alert.freq_once_per_bar_close)

if strategy.position_size < 0
    if high >= sl
        alert("Stop Loss Hit - Short", alert.freq_once_per_bar_close)
    if low <= tp
        alert("Take Profit Hit - Short", alert.freq_once_per_bar_close)

// Reset SL and TP lines when flat
if strategy.position_size == 0
    sl := na
    tp := na

// =========================================================================
// VISUALS
// =========================================================================
plotshape(longCondition, title="Buy Signal", style=shape.triangleup, location=location.belowbar, color=buyColor, size=size.small)
plotshape(shortCondition, title="Sell Signal", style=shape.triangledown, location=location.abovebar, color=sellColor, size=size.small)

plot(strategy.position_size != 0 ? sl : na, color=color.red, style=plot.style_linebr, title="Stop Loss")
plot(strategy.position_size != 0 ? tp : na, color=color.green, style=plot.style_linebr, title="Take Profit")
````
