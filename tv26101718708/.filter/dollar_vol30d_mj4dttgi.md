# Dollar Vol(30D) 

- url: https://www.tradingview.com/script/MJ4dTtgi-Dollar-Vol-30D/
- type: indicator
- pine_id: PUB;7328dd1b4630495a9a1fbcc6e40d8538
- version: 1.0

## Description

Average dollar volume in the past 30 days. Can be used to find liquid stocks

## Source Code

````pine
//@version=5
indicator("Dollar Vol(30D) ", overlay=true)

// Calculate Price * 30-day Average Volume
avg_vol = ta.sma(volume, 30)
dollar_vol = close * avg_vol

// Convert to Millions (M)
dv_millions = dollar_vol / 1000000

// display=display.status_line makes it show up in the top text legend
// color=color.new(color.white, 100) makes the actual line 100% transparent/invisible
plot(dv_millions, title="Price x Vol (M)", color=color.new(color.white, 100), display=display.status_line)
````
