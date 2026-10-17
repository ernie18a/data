# Backtest History Setup 1.0

- url: https://www.tradingview.com/script/08ofAzKR-Backtest-History-Setup-1-0/
- type: strategy
- pine_id: PUB;t5QHQelZbfu80NYcezSxAHWF9yHyb0En
- version: 1.0

## Description

Script of strategy component to setup the backtext lookback. You setup the maximum days back in the history, which will be used for backtest.

## Source Code

````pine
//@version=3
strategy("Backtest History Setup 1.0")

backtesthistory = input(defval = 365, title="Number of Bars for Back Testing", minval=0)
minutes       = (timenow-time)/60000.0  // number of minutes since last bar
timeinterval = minutes/1440.0/interval // daily Bars

if (ismonthly)
    timeinterval := timeinterval/1440.0/5.0/4.3/interval
    backtesthistory := 12
if (isweekly) 
    timeinterval := timeinterval/1440.0/5.0/interval 
    backtesthistory := 52

timecheck = timeinterval <= backtesthistory 

plotchar(timecheck,"OK",char="1")
````
