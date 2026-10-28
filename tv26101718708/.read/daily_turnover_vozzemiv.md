# Daily Turnover %

- url: https://www.tradingview.com/script/vozZEmIV-Daily-Turnover/
- type: indicator
- pine_id: PUB;35025d06f3ac4f03a852540a74380442
- version: 1.0

## Description

Grok derived % turnover script using % of shaes turned over in the time period.

## Source Code

````pine
//@version=5
indicator("Daily Turnover %", shorttitle="Turnover %", overlay=false, max_bars_back=500)

// ←←← CHANGE THIS NUMBER FOR EACH TICKER
shares_out = input.int(65000000, "Shares Outstanding (edit per ticker)", minval=1000000, step=1000000)

turnover_pct = (volume / shares_out) * 100

plot(turnover_pct, title="Turnover %", color=color.new(color.blue, 0), style=plot.style_columns, linewidth=3)
hline(5,  "5%  = Strong participation", color=color.orange, linestyle=hline.style_dashed)
hline(10, "10% = Explosive runner",     color=color.red,    linestyle=hline.style_dashed)

// Optional: 20-period MA on turnover for trend
ma_turnover = ta.sma(turnover_pct, 20)
plot(ma_turnover, title="20-bar Avg Turnover", color=color.orange, linewidth=2)
````
