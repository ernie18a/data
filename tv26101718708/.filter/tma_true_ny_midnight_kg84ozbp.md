# TMA - True NY Midnight

- url: https://www.tradingview.com/script/kG84Ozbp-TMA-True-NY-Midnight/
- type: indicator
- pine_id: PUB;c3cb710c6ffb478f9987189ce019b8cb
- version: 2.0

## Description

Welcome to the Trend Master Akademi (TMA) institutional toolset.

The TMA - True NY Midnight indicator is designed for precision price action and SMC/ICT traders who need absolute accuracy in defining the daily algorithmic bias.

The Problem with Standard Indicators:
Most Midnight Open indicators on TradingView fail when applied to Regular Trading Hours (RTH) charts (like CME futures or traditional equities). Because the actual 00:00 candle is hidden during RTH, standard scripts mistakenly plot the midnight open at the 09:30 AM RTH opening price, destroying your bias.

The TMA Edge (ETH Bypass Engine):
We solved this by engineering an "Extended Trading Hours (ETH) Bypass". Regardless of your chart's session settings (RTH or 24/7), this indicator runs a ghost data feed in the background. It connects to the 1-minute ETH chart, extracts the exact 00:00 New York print, and projects it directly onto your current chart.

How to Use It (The Institutional Narrative):
In algorithmic trading, the true New York Midnight Open acts as the ultimate daily equilibrium.

Premium Zone: When price is above this line, the asset is considered expensive. Look for Institutional Distribution and Short (Sell) setups.

Discount Zone: When price is below this line, the asset is considered cheap. Look for Institutional Accumulation and Long (Buy) setups.

Judas Swing: Watch for the price to aggressively sweep above or below this line in the early sessions to trap retail traders before reversing to the true daily direction.

Key Features:

Absolute Precision: Extracts the true 00:00 NY price flawlessly, immune to chart session errors.

Zero Chart Clutter: Professionally coded to auto-delete yesterday's line. It only projects the current day's active level, keeping your workspace clean and focused.

Fully Customizable: Adjust line color, thickness, and style to match your charting theme.

Stay disciplined, trade the narrative, and let the algorithms show their hand.

Tags:
#ICT #SmartMoneyConcepts #SMC #NYMidnight #PriceAction #TMA #AlgorithmicTrading #DayTrading

## Source Code

````pine
//@version=5
indicator("TMA - True NY Midnight (00:00) Fixed", overlay=true)

grp = "Çizgi Görünüm Ayarları"
line_color = input.color(color.white, title="Çizgi Rengi", group=grp)
line_width = input.int(2, title="Çizgi Kalınlığı", minval=1, maxval=5, group=grp)
line_style_s = input.string("Solid (Düz)", title="Çizgi Stili", options=["Solid (Düz)", "Dashed (Kesik)", "Dotted (Noktalı)"], group=grp)

get_style(s) =>
    s == "Solid (Düz)" ? line.style_solid : s == "Dashed (Kesik)" ? line.style_dashed : line.style_dotted

eth_ticker = ticker.new(syminfo.prefix, syminfo.ticker, session.extended)

f_midnight() =>
    var float mid = na
    if ta.change(dayofmonth(time, "America/New_York")) != 0
        mid := open
    mid

midnight_price = request.security(eth_ticker, "1", f_midnight(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

is_new_ny_day = ta.change(dayofmonth(time, "America/New_York")) != 0

var line ml = na

if is_new_ny_day and not na(midnight_price)
    line.delete(ml)
    ml := line.new(bar_index, midnight_price, bar_index + 1, midnight_price, color=line_color, width=line_width, style=get_style(line_style_s))
    line.set_extend(ml, extend.right)
````
