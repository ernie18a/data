# AutoView - Hodl to Sodl

- url: https://www.tradingview.com/script/aRbt7nSQ-AutoView-Hodl-to-Sodl/
- type: indicator
- pine_id: PUB;NY3OERuApHRO1bTImo2fgFjsziGKwlNJ
- version: 2.0

## Description

Write your own strategy and use Hodl to Sodl to send Alerts for when to buy & sell, and automatically plot your anticipated buys/sells to the chart.  A must have for AutoView users.  Requires Pine Script coding.  Not compatible with "Strategy Tester" tab and "Paper Trading" tab in TradingView.

Hodl-Sodl itself is not a strategy.  It is a framework for building AutoView strategies.  For demonstration purposes, the image featured with this script shows an example of a very simple CCI strategy (and not a very good one), but you would presumably replace that with your own ideas.  If you'd like a little help plugging in your own strategy, contact jdhadwin for custom coding.

## Source Code

````pine
//@version=3
study("AutoView - Hodl to Sodl", shorttitle="hodl-sodl", overlay=true)

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// Hodl to Sodl
//
// Description:     Write your strategy and use Hodl to Sodl to send alerts
//                  for when to buy & sell, and plot your anticipated buys/sells
//                  to the chart.  A must have for AutoView users.  Requires
//                  pineScript coding.
//

// Inputs
entrySize = input(defval=4, title="Entry Marks (Size)", minval=1)
exitProfitSize = input(defval=9, title="Exit Profit Marks (Size)", minval=1)
exitLossSize = input(defval=4, title="Exit Loss Marks (Size)", minval=1)
darkTheme = input(defval=true, title="Use with Dark Theme")

// Variables
preEntrySignal = na //This will be the unfinished entrySignal
entrySignal = na
preExitSignal = na //This will be the unfinished exitSignal
exitSignal = na
hodling = 0.0
hodling := na(hodling[1]) ? hodling : hodling[1]
sodling = 0.0
sodling := na(sodling[1]) ? sodling : sodling[1]

// Entries
preEntrySignal := false

// Module 1 - Just a simple cci buy strategy for demonstration purposes - replace this with your own ideas
cci = cci(close, 150)
exampleBuyingModuleSignal = cci > -100.0 and cci[1] < -100.0 and cci < 0.0
preEntrySignal := exampleBuyingModuleSignal or preEntrySignal //add to the preEntrySignal

// Module 2
mySecondBuyingModuleSignal = false //build something else that identifies good buys and put it here
preEntrySignal := mySecondBuyingModuleSignal or preEntrySignal //add other ideas you have to the preEntrySignal

// Add more buying modules here

// Last word - maybe you'll want to run your buy signal past the RSI or seek the approval of the Simple Moving Average first, or even save the buy signal till these give the nod of approval
buyApproval = true //here, create modules that approve or deny other buy signals
delayedBuySignal = false //here, create modules that hold on to denied buy signals until buying is approved again

// Final entrySignal - buyApproval and delayedBuySignals are married together with the preEntrySignal for a final entrySignal
entrySignal := not entrySignal and not (hodling > 0) and buyApproval and (preEntrySignal or delayedBuySignal)

// Log the trade and entry price
hodling := entrySignal ? (true ? close : (false ? open : (false ? high : low))) : hodling // you may want to have different buySignals record the price they bought at differently (i.e. open, close, high, low, etc)


// Exits
preExitSignal := false

// Module 1
exampleSellingModule = cci < 100.0 and cci[1] > 100.0 and not entrySignal
preExitSignal := exampleSellingModule or preExitSignal //add to the preExitSignal

// Module 2
mySecondSellingModule = cci < -100.0 and ((cci[1] > -100.0 and not entrySignal) or (cci[1] < -100.0 and entrySignal[1]))
preExitSignal := mySecondSellingModule or preExitSignal //add to the preExitSignal

// Add more selling modules here

// Last word
sellApproval = true //here, create modules that approve or deny other sell signals
delayedSellSignal = false //create modules that hold on to denied sell signals until selling is approved again

// Final exitSignal - sellApproval and delayedSellSignals are married together with the preExitSignal for a final exitSignal
exitSignal := not exitSignal and hodling > 0 and sellApproval and (preExitSignal or delayedSellSignal)

// Update your position
sodling := exitSignal ? (true ? close : (false ? open : (false ? high : low))) : entrySignal ? 0.0 : sodling


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// PLOTTING TO THE CHART
entryC = darkTheme ? white : blue
plot(entrySignal ? hodling : na, color=entryC, linewidth=entrySize, style=cross, title="Entry")
exitC = hodling[1] > sodling ? red : lime
plot(exitSignal ? sodling : na, color=#00000000, linewidth=1, style=cross, title="Exit")
plot(exitSignal and hodling[1] <= sodling ? sodling : na, color=exitC, linewidth=exitProfitSize, style=cross, title="Wins")
plot(exitSignal and hodling[1] > sodling ? sodling : na, color=exitC, linewidth=exitLossSize, style=cross, title="Losses")
hodlC = exitSignal and not entrySignal ? (darkTheme ? #ffffffff : #000000ff) : #00000000
plot((entrySignal or exitSignal) ? (entrySignal ? hodling : sodling) : na, color=hodlC, linewidth=1, title="Position")

// Update your position
hodling := exitSignal ? 0.0 : hodling

// Alerts
alertcondition(entrySignal, title="Buy", message="Buy Signal")
alertcondition(exitSignal, title="Sell", message="Sell Signal")
````
