# Liquidity Breakout - Strategy [presentTrading]

- url: https://www.tradingview.com/script/UUHabgvo-Liquidity-Breakout-Strategy-presentTrading/
- type: strategy
- pine_id: PUB;9421d63be23e4f8cb869cf67f0ea33ce
- version: 2.0

## Description

- Introduction and How It Is Different

The Liquidity Breakout Strategy is a unique trading strategy that focuses on identifying and leveraging patterns in market price data. This strategy, mainly inspired by the script "Master Pattern" by LuxAlgo, takes a different approach from many traditional strategies that rely on technical indicators or fundamental analysis. Instead, the Liquidity Breakout is based on the concept of contraction detection and liquidity levels. This approach allows traders to identify potential trading opportunities that other strategies might miss.

BTCUSDT 6h 
https://www.tradingview.com/x/LeuJRmtB/

The strategy is different from other trading strategies because it uses a unique combination of pattern detection, liquidity levels, and user-defined trading direction. This combination allows the strategy to adapt to various market conditions and trading styles, making it a versatile tool for traders.

- Strategy: How It Works

1. Contraction Detection: The strategy uses a lookback period defined by the user (default is 10 bars) to identify contractions in the market. A contraction is a period where the market is consolidating, often followed by a significant price movement. The strategy identifies contractions by finding pivot highs and pivot lows within the lookback period. If a pivot high is lower than the previous pivot high and a pivot low is higher than the previous pivot low, a contraction is detected.

2. liquidity Levels: 
What are Liquidity levels? Liquidity levels, also known as liquidity pools or zones, are price levels at which there is a significant amount of trading activity. They are often areas where large institutional traders (like banks or hedge funds) have placed orders. These levels are important because they can act as support or resistance levels, and price often reacts at these levels.

In the context of this strategy, liquidity levels are used to identify potential entry and exit points for trades. When the price reaches a liquidity level, it could indicate a potential trading opportunity. For example, if the price breaks through a liquidity level, it could signal the start of a new trend. On the other hand, if the price approaches a liquidity level and then reverses, it could signal a potential reversal.

The strategy uses these two elements to identify potential trading opportunities. When a contraction is detected, the strategy will look for a breakout in the direction of the trend. If the breakout occurs at a liquidity level, the strategy will execute a trade.

The strategy also allows traders to set their stop loss based on either the Average True Range (ATR) or a fixed percentage. This flexibility allows traders to manage their risk according to their personal risk tolerance and trading style.

- Trade Direction

One of the unique features of the Master Pattern Strategy is the ability to choose the trading direction. Traders can choose to trade in the "Long" direction, the "Short" direction, or "Both". This feature allows traders to adapt the strategy to their personal trading style and market outlook.

For example, if a trader believes that the market is in an uptrend, they can choose to trade only in the "Long" direction. Conversely, if the market is in a downtrend, they can choose to trade only in the "Short" direction. If the trader believes that the market is volatile and there are opportunities in both directions, they can choose to trade in "Both" directions.

- Usage

To use the strategy, traders need to input their preferred settings, including the contraction detection lookback period, liquidity levels, stop loss type, and trading direction. Once these settings are input, the strategy will automatically detect potential trading opportunities and execute trades according to the defined parameters.

- Default Settings

The default settings for the Master Pattern Strategy are as follows:
Contraction Detection Lookback: 10
Liquidity Levels: 20
Stop Loss Type: ATR
ATR Length: 20
ATR Multiplier: 3.0
Fixed Percentage: 0.01
Trading Direction: Both

These settings can be adjusted according to the trader's personal preferences and market conditions. It's recommended that traders experiment with different settings to find the ones that work best for their trading style and goals.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © PresentTrading

//@version=5
strategy('Liquidity Breakout - Strategy [presentTrading]' , overlay=true, precision=3, default_qty_type=strategy.cash, 
 commission_value= 0.1, commission_type=strategy.commission.percent, slippage= 1, 
  currency=currency.USD, default_qty_type = strategy.percent_of_equity, default_qty_value = 10, initial_capital= 10000)
//------------------------------------------------------------------------------
//Settings
//-----------------------------------------------------------------------------{

// Define trading direction options
tradeDirection = input.string(title="Trade Direction", defval="Both", options=["Long", "Short", "Both"])

length = input.int(12, 'Contraction Detection Lookback', minval = 1)
liqLength = input.int(20, 'Liquidity Levels', minval = 1)

// Define stop loss options
stopLossType = input.string(title="Stop Loss Type", defval="SuperTrend", options=["SuperTrend", "Fixed Percentage", "None"])
fixedPercentage = input.float(0.1, title="Fixed Percentage", step=0.01)

// Define Supertrend parameters
supertrendPeriod = input(10, "Supertrend Length")
supertrendMult = input.float(3.0, "Supertrend Mult", step = 0.1)

// Calculate Supertrend
[supertrend, direction] = ta.supertrend(supertrendMult, supertrendPeriod)



showMajor = input(true, 'Show Major Pattern')
showMinor = input(true, 'Show Minor Pattern')

//Style
bullCss = input.color(color.teal, 'Bullish Pattern', inline = 'bull', group = 'Pattern Style')
showBullBox = input(true, 'Area', inline = 'bull', group = 'Pattern Style')
showBullLvl = input(true, 'Line', inline = 'bull', group = 'Pattern Style')

bearCss = input.color(color.red, 'Bearish Pattern', inline = 'bear', group = 'Pattern Style')
showBearBox = input(true, 'Area', inline = 'bear', group = 'Pattern Style')
showBearLvl = input(true, 'Line', inline = 'bear', group = 'Pattern Style')

//Liquidity Style
showLiq = input(true, 'Show Liquidity Levels', group = 'Liquidity')
bullLiqCss = input.color(color.teal, 'Upper Liquidity', group = 'Liquidity')
bearLiqCss = input.color(color.red, 'Lower Liquidity', group = 'Liquidity')

//-----------------------------------------------------------------------------}
//UDT
//-----------------------------------------------------------------------------{
type mp
    box area
    line avg
    bool breakup
    bool breakdn

//-----------------------------------------------------------------------------}
//Detect contraction
//-----------------------------------------------------------------------------{
var phy = 0., var phx = 0, var pht = 0.
var ply = 0., var plx = 0, var plt = 0.

var float top = na
var float btm = na

n = bar_index
ph = ta.pivothigh(length, length)
pl = ta.pivotlow(length, length)

if ph
    pht := math.sign(ph - phy)
    phy := ph

    if pht == -1 and plt == 1
        top := ph
        btm := ply
        phx := n-length

if pl
    plt := math.sign(pl - ply)
    ply := pl

    if pht  == -1 and plt == 1
        top := phy
        btm := pl
        plx := n-length

//-----------------------------------------------------------------------------}
//Set pattern
//-----------------------------------------------------------------------------{
var mp master = mp.new()

//Detect master pattern
isbull = high[length] > top and top > btm
isbear = low[length] < btm and top > btm

if isbull or isbear
    css = isbull ? bullCss : bearCss

    master.avg.set_x2(n-length)

    val = math.avg(top, btm)

    //Create new master pattern object
    master := mp.new(
      (isbull and showBullBox) or (isbear and showBearBox) ? box.new(math.max(phx, plx), top, n-length, btm, na, bgcolor = showMinor ? color.new(css, 50) : na) : na
      , (isbull and showBullLvl) or (isbear and showBearLvl) ? line.new(n-length, val, n, val, color = showMinor ? css : na) : na
      , isbull
      , isbear)

    top := na
    btm := na

//Determine if pattern switch to major
if master.breakup
    if low < master.area.get_bottom()
        if not showMajor
            master.area.delete()
            master.avg.delete()
        else
            master.area.set_border_color(bullCss)
            if not showMinor
                master.area.set_bgcolor(color.new(bullCss, 50))
                master.avg.set_color(bullCss)
else if master.breakdn
    if high > master.area.get_top()
        if not showMajor
            master.area.delete()
            master.avg.delete()
        else
            master.area.set_border_color(bearCss)
            if not showMinor
                master.area.set_bgcolor(color.new(bearCss, 50))
                master.avg.set_color(bearCss)

//Set friction level x2 coordinate to current bar
if not na(master.avg)
    master.avg.set_x2(n)

//-----------------------------------------------------------------------------}
//Liquidity levels
//-----------------------------------------------------------------------------{
var line liqup = na, var liqup_reach = false
var line liqdn = na, var liqdn_reach = false

liqph = ta.pivothigh(liqLength, liqLength)
liqpl = ta.pivotlow(liqLength, liqLength)

//Set upper liquidity
if liqph and showLiq
    if not liqup_reach
        liqup.set_x2(n-liqLength)

    liqup := line.new(n-liqLength, liqph, n, liqph, color = bullLiqCss, style = line.style_dotted)
    liqup_reach := false
else if not liqup_reach and showLiq
    liqup.set_x2(n)

    if high > liqup.get_y1()
        liqup_reach := true

//Set lower liquidity
if liqpl and showLiq
    if not liqdn_reach
        liqdn.set_x2(n-liqLength)

    liqdn := line.new(n-liqLength, liqpl, n, liqpl, color = bearLiqCss, style = line.style_dotted)
    liqdn_reach := false
else if not liqdn_reach and showLiq
    liqdn.set_x2(n)

    if low < liqdn.get_y1()
        liqdn_reach := true

//-----------------------------------------------------------------------------}


// Define entry conditions
bullishEntry = isbull //and direction < 0
bearishEntry = isbear //and direction > 0


// Execute trades
if (bullishEntry and (tradeDirection == "Long" or tradeDirection == "Both"))
    strategy.entry("Buy", strategy.long)
    if (stopLossType == "SuperTrend")
        strategy.exit("Sell", "Buy", stop=supertrend)
    else if (stopLossType == "Fixed Percentage")
        strategy.exit("Sell", "Buy", stop=close * (1 - fixedPercentage))
if (bearishEntry and (tradeDirection == "Short" or tradeDirection == "Both"))
    strategy.entry("Sell", strategy.short)
    if (stopLossType == "SuperTrend")
        strategy.exit("Buy", "Sell", stop=supertrend)
    else if (stopLossType == "Fixed Percentage")
        strategy.exit("Buy", "Sell", stop=close * (1 + fixedPercentage))

// Exit conditions
if (strategy.position_size > 0 and bearishEntry) // If in a long position and bearish entry condition is met
    strategy.close("Buy")
if (strategy.position_size < 0 and bullishEntry) // If in a short position and bullish entry condition is met
    strategy.close("Sell")
````
