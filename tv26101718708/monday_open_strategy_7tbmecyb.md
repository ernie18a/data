# Monday Open Strategy

- url: https://www.tradingview.com/script/7tbmecYB-Monday-Open-Strategy/
- type: strategy
- pine_id: PUB;bd1d26c36d9c490c8068713951275165
- version: 1.0

## Description

[b]Year Range Inputs:[/b]
[b]start_year[/b] and [b]end_year[/b] allow you to define the range of years in which the strategy will execute.
You can adjust these values in the script’s settings panel in TradingView.

[b]Entry Condition:[/b]
The strategy checks that the current year falls within the specified range before entering a trade on Monday’s open.

[b]Exit Condition:[/b]
Similarly, it only exits on Tuesday’s close if the current year is within the specified range.
This setup ensures that trades only take place between the defined years, effectively filtering out unwanted trades outside this timeframe.

## Source Code

````pine
//@version=5
strategy("Monday Open Strategy", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=10)

// Input for start and end year
start_year = input.int(2023, title="Start Year")
end_year = input.int(2025, title="End Year")

// Trading days
monday = (dayofweek == dayofweek.sunday)
tuesday = (dayofweek == dayofweek.tuesday)

// Current year
current_year = year

// Define entry and exit points
var bool trade_opened = false

// Open trade on Monday's open within the year range
if monday and not trade_opened and (current_year >= start_year and current_year <= end_year)
    strategy.entry("Monday Trade", strategy.long)
    trade_opened := true  // Mark trade as opened

// Close trade on Tuesday's daily close within the year range
if tuesday and trade_opened and (current_year >= start_year and current_year <= end_year)
    strategy.close("Monday Trade")
    trade_opened := false  // Reset for the next week
````
