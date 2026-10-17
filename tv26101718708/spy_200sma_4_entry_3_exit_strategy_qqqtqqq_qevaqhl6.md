# SPY 200SMA +4% Entry -3% Exit Strategy (QQQ/TQQQ)

- url: https://www.tradingview.com/script/QEVAQHl6-SPY-200SMA-4-Entry-3-Exit-Strategy-QQQ-TQQQ/
- type: strategy
- pine_id: PUB;cb09956c4a484c40b8173eec78f3cd61
- version: 2.0

## Description

[b]USE THIS CHART ONLY ON THE SPY DAILY VIEW[/b]

TLDR Summary of the Improved Strategy: When the price of SPY is +4% above the 200SMA BUY TQQQ and when the price of SPY drops to -3% under the SPY 200SMA SELL and slowly DCA into QQQ over the next 6-12 months or until price returns to +4% above the SPY 200SMA at which point you will go back into 100% TQQQ. Note: (if the price of QQQ goes 30% above the 200SMA of QQQ deleverage to QQQ or Sell to protect yourself from dot com level event)

This latest update will cover some important refining points to the latest version of the strategy I posted previously covering two major enhancements after doing more research and talking to other members of the LETF community (special thanks to u/lobsterfanatic)

There are three major changes I want to make in order to make this strategy the most optimal blend of Profit and Safety.

Change 1: Using SPY instead of QQQ as the tracked underlying 200SMA the strategy is based around

Backtest Start date of 1/1/2003 using QQQ & TQQQ (simulated) (Testfol.io)

r/TQQQ - Backtest Start Date 1/1/2003 using QQQ & TQQQ (Simulated) Testfol.io
Backtest Start Date 1/1/2003 using QQQ & TQQQ (Simulated) Testfol.io
Change 2: Under the SPY 200SMA Trigger DCA into the underlying QQQ instead of Bonds/Cash

r/TQQQ - Change 2: Under the SPY 200SMA Trigger DCA into the underlying QQQ instead of Bonds/Cash
Change 2: Under the SPY 200SMA Trigger DCA into the underlying QQQ instead of Bonds/Cash
So this one is an interesting one, above you can see the comparison of going into QQQ vs Bonds when you get a SELL signal from the strategy and exit the TQQQ position.

You really only have two times when you lose money going into the underlying (-8% in the 2022 rate hike crash and -24% in the 08 Crash) overall the average is +6.91% which leads to much greater returns.

If you want the strategy to be as easy and simple as possible just make a decision based on your risk tolerance of going into CASH/SGOV or QQQ based on the above data and your investing time horizon (if you may need to withdraw money at any point use CASH or BONDS, if you have years of time go QQQ).

However this strategy has the goal of being completely bullet proof in any market scenario so in that spirit I would say the most optimal way to handle this if you want to make the strategy better is to sell to CASH/SGOV immediately when the SELL signal for the strategy comes through and then slowly DCA with the funds into the underlying over the next 12 months every month. Block back into the underlying. Buy all the way down and all the way up and when the next BUY signal triggers sell everything and return to 100% TQQQ Exposure.

Change 3: Deleverage when too far above the QQQ 200SMA (Extremely rare but important)

This is all about setting additional safety measures to deleverage when insanely high above the 200SMA, I'll just call this what it is...dot com bubble insurance. An extremely rare dagger in the dark that could assassinate your portfolio and an Achilles heel of this trading strategy.

The 200SMA that this strategy revolves around is the mechanism that prevents mass drawdown events with a pseudo trailing stop loss, in the extremely rare event that price action skyrockets above the 200SMA too fast you become exposed to far too much risk, which necessitates this additional backstop.

For this we will actually need to use the QQQ SMA instead of SPY as in these extremely rare scenarios we need it to be as accurate and sector specific as possible.

The solution is simple, deleveraging as the price action of QQQ swings wildly upward too fast and too high above the QQQ 200SMA. You can choose whatever limits you would like but I'll be using these ones.

Bodyguard Signal 1: 30% Above the QQQ 200SMA Deleverage to QQQ

Bodyguard Signal 2: 40% Above the QQQ 200SMA SELL (This is the GTFO Level where you don't know where the top is but you don't really want to be there to find out lol)

## Source Code

````pine
//@version=5
strategy("SPY 200SMA +4% Entry -3% Exit Strategy", 
     overlay=true, 
     default_qty_type=strategy.percent_of_equity, 
     default_qty_value=100)

// === Inputs ===
smaLength      = input.int(200, title="SMA Period", minval=1)
entryThreshold = input.float(0.04, title="Entry Threshold (%)", step=0.01)
exitThreshold  = input.float(0.03, title="Exit Threshold (%)", step=0.01)
startYear      = input.int(1995, "Start Year")
startMonth     = input.int(1, "Start Month")
startDay       = input.int(1, "Start Day")

// === Time filter ===
startTime    = timestamp(startYear, startMonth, startDay, 0, 0)
isAfterStart = time >= startTime

// === Calculations ===
sma200         = ta.sma(close, smaLength)
upperThreshold = sma200 * (1 + entryThreshold)
lowerThreshold = sma200 * (1 - exitThreshold)

// === Strategy Logic ===
enterLong = close > upperThreshold
exitLong  = close < lowerThreshold

if isAfterStart
    if enterLong and strategy.position_size == 0
        strategy.entry("Buy", strategy.long)
    if exitLong and strategy.position_size > 0
        strategy.close("Buy")

// === 366-Day Marker Logic (Uninterrupted) ===
var int targetTime = na

// 1. Capture entry time only when a brand new position starts
// (Leaving this tied to position_size ensures the 366-day timer starts exactly upon the order fill)
if strategy.position_size > 0 and strategy.position_size[1] == 0
    targetTime := time + (366 * 24 * 60 * 60 * 1000)

// 2. IMPORTANT: If position is closed or a sell signal hits, reset the timer to "na"
if strategy.position_size == 0
    targetTime := na

// 3. Trigger only if we are still in the trade and hit the timestamp
isAnniversary = not na(targetTime) and time >= targetTime and time[1] < targetTime

// === Visuals ===
p_sma   = plot(sma200, title="200 SMA", color=color.rgb(255, 0, 242))
p_upper = plot(upperThreshold, title="Entry Threshold (+4%)", color=color.rgb(0, 200, 0))
p_lower = plot(lowerThreshold, title="Exit Threshold (-3%)", color=color.rgb(255, 0, 0))

fill(p_sma, p_upper, color=color.new(color.green, 80), title="Entry Zone")

// Draw marker only if 366 days passed without a sell
if isAnniversary
    label.new(bar_index, high, "366 DAYS - PHASE 2", style=label.style_label_down, color=color.yellow, textcolor=color.black, size=size.small)

// === Entry/Exit Labels (FIXED) ===
// Tie the labels to the signal instead of waiting for the delayed position_size update
newOpen  = isAfterStart and enterLong and strategy.position_size == 0
newClose = isAfterStart and exitLong and strategy.position_size > 0

if newOpen
    label.new(x=bar_index, y=low * 0.97, text="BUY - PHASE 1", xloc=xloc.bar_index, yloc=yloc.price, color=color.lime, style=label.style_label_up, textcolor=color.black, size=size.small)

if newClose
    label.new(x=bar_index, y=high * 1.03, text="SELL - PHASE 3", xloc=xloc.bar_index, yloc=yloc.price, color=color.red, style=label.style_label_down, textcolor=color.white, size=size.small)
````
