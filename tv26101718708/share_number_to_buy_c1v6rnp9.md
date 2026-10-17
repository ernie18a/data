# Share Number to Buy

- url: https://www.tradingview.com/script/C1v6rNP9-Share-Number-to-Buy/
- type: indicator
- pine_id: PUB;a92c4b7921b549d19ae036f3872db1e8
- version: 1.0

## Description

Simple Share number calculator to show how many shares of a stock should be purchased based on;
    1. Total Capital Allocation, and 
    2. Percentage of that Allocation available for buying a specific number of shares of a stock.
JJ

## Source Code

````pine
//Simple Share number calculator to show how many shares of a stock should be purchased based on;
// 1. Total Capital Allocation, and 
// 2. Percentage of that Allocation available for buying a specific number of shares of a stock.
// JJ

//@version=6
indicator(title="Share Number", shorttitle="Share #",  overlay=false)

capital = input.int(5000, "Capital", minval=1)
percentage_of_capital_to_invest =  input.int(20, "Percentage of Capital to Invest", minval=1)

shares_num = (capital*(percentage_of_capital_to_invest/100)) /close

plotchar(shares_num, title="SHARE #", char="", location=location.top, color=color.yellow, precision = 0)
````
