# VWRA Optimal Volatility Harvesting (Corrected WD)

- url: https://www.tradingview.com/script/uyr1MWM0-VWRA-Optimal-Volatility-Harvesting-Corrected-WD/
- type: indicator
- pine_id: PUB;2ebb8458f77a4e2ba63575a164d57ef2
- version: 2.0

## Description

The ETF compounding indicator for your self invested pension. 
Make your all-world ETF work four times harder! (VWRA etc) 
Backtest shows 7 year growth at 415%. YTD 04/2026 
Not automated. Harvests a certain % of increased capital for redistribution in drawdowns. Easy to use and alarm. Only a few trades per year. 
I have produced and tested many Monte Carlo/ Bayesian strategies over the past five years and this is the most consistent as it uses the logical sense of partial capital preservation in trending years to be redistributed at times of drawdown. 
Load it up and DM me for details of how exactly the strategy works because if you use random $\£\€\¥ amounts it will likely be suboptimal. No fee needed.

SPY/VUSA strategy also available but you will need to DM me for details because it’s far more powerful, has taken literally years to develop and will require a small payment.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// ©  marcr826

//@version=5
indicator("VWRA Optimal Volatility Harvesting (Corrected WD)", overlay=true)

// Parameters
withdrawPct = 0.04
pb1 = 0.03
pb2 = 0.07

// State
var float runningPeak = na
var float wdAnchor = na
var bool cashAvailable = false
var bool redeployed60 = false

// Initialise
if na(runningPeak)
    runningPeak := close
if na(wdAnchor)
    wdAnchor := close

// Update peak
runningPeak := math.max(runningPeak, close)

// Withdrawal logic (FIXED)
withdrawSignal = close >= wdAnchor * (1 + withdrawPct)

if withdrawSignal
    wdAnchor := close
    runningPeak := close
    cashAvailable := true
    redeployed60 := false

// Redeploy logic
redeploy60 = cashAvailable and not redeployed60 and close <= runningPeak * (1 - pb1)
redeploy40 = cashAvailable and redeployed60 and close <= runningPeak * (1 - pb2)

if redeploy60
    redeployed60 := true

if redeploy40
    cashAvailable := false
    redeployed60 := false
    runningPeak := close

// Visuals (single-line = safe)
plotshape(withdrawSignal, title="WITHDRAW", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="WD")
plotshape(redeploy60, title="BUY 60%", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, text="60%")
plotshape(redeploy40, title="BUY 40%", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small, text="40%")

plot(runningPeak, title="Running Peak", color=color.orange)
plot(wdAnchor, title="Withdrawal Anchor", color=color.blue)
````
