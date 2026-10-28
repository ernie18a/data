# Bitcoin/USDT Dominance Ratio | Astral Vision 

- url: https://www.tradingview.com/script/UjV6kYHL/
- type: indicator
- pine_id: PUB;9cad5af4b0ab41149eecc9fbfc9135bf
- version: 1.0

## Description

[b]Bitcoin/USDT Dominance Ratio | Astral Vision 🌠💠[/b]

USDT dominance measures the share of total crypto market capitalization held in Tether. 
When USDT dominance is high, capital is parked in stablecoins: risk appetite is low and dry powder is accumulating. 
When USDT dominance is low, capital has rotated into risk assets: stablecoin supply relative to the market has been deployed.

Dividing Bitcoin's price by USDT dominance produces a ratio that amplifies both conditions: it rises when BTC appreciates while stablecoin dominance contracts (maximum risk-on), and falls when BTC depreciates while stablecoin dominance expands (maximum risk-off). 
The ratio acts as a liquidity-adjusted price: a measure of how much Bitcoin is worth relative to the available pool of sidelined capital.

[b]Calculation ⚙️[/b]

`Ratio = BTC Price / USDT Dominance (%)`

Both the ratio candles and the price chart candles are colored identically by the same threshold logic, so the regime read is simultaneously visible in the indicator panel and on the price chart without switching focus.

[b]Plots 📊[/b]
[list]
[*]Ratio candles in the indicator panel, colored by active regime
[*]Oversold threshold line (positive color) and overbought threshold line (negative color)
[*]Price chart candle coloring by the same regime logic
[*]Background highlight on the price chart when either threshold is breached
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]`Oversold Threshold`: ratio level below which the signal enters accumulation territory (default 2100)
[*]`Overbought Threshold`: ratio level above which the signal enters distribution territory (default 27000)
[/list]

[b]Colors 🎨[/b]

5 Astral Vision presets + custom override. Default: Infinito. Positive color activates below the oversold threshold; negative color activates above the overbought threshold.

[b]Purpose 🎯[/b]

Tracking BTC price and USDT dominance as separate charts requires constant context-switching and leaves the relationship between the two implicit. Most dominance indicators plot stablecoin share in isolation with no connection to price magnitude, while raw BTC price charts carry no information about the liquidity environment surrounding each move.

This indicator fuses the two into a single ratio that makes the liquidity context inseparable from price. A BTC rally with contracting USDT dominance reads as a structurally stronger move than the same price gain with stable or rising stablecoin dominance and this indicator makes that difference directly visible through threshold crossings, candle color, and background regime highlighting on the price chart.

[b]Disclaimer ⭕️[/b]

It is not financial advice, not an investment recommendation, and not affiliated with any financial institution, research firm, or organization of any kind. All content is provided for educational and informational purposes only. Always conduct your own research before making any financial decision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Astral Vision 

//@version=6
indicator("Bitcoin/USDT Dominance Ratio | Astral Vision 🌠💠")

group1 = "Settings"
group2 = "Astral Colors"

float thresh_lo = input.float(2100,  "Oversold Threshold",   step=100, group=group1)
float thresh_hi = input.float(27000, "Overbought Threshold", step=100, group=group1)

string theme      = input.string("Infinito", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group2)
bool   usecustom  = input.bool(false, "Custom Colors", group=group2)
color  custom_pos = input.color(color.rgb(255,0,0),  "Custom Positive", group=group2)
color  custom_neg = input.color(color.rgb(120,0,0),  "Custom Negative", group=group2)

color pos_col = usecustom ? custom_pos :
     theme == "Inferno"  ? color.rgb(255,0,0)    :
     theme == "Paradiso" ? color.rgb(0,210,255)  :
     theme == "Futura"   ? color.rgb(0,255,180)  :
     theme == "Infinito" ? color.rgb(180,120,255) :
     color.rgb(255,160,0)

color neg_col = usecustom ? custom_neg :
     theme == "Inferno"  ? color.rgb(120,0,0)    :
     theme == "Paradiso" ? color.rgb(0,80,160)   :
     theme == "Futura"   ? color.rgb(180,0,255)  :
     theme == "Infinito" ? color.rgb(255,220,80)  :
     color.rgb(0,180,120)

float ratioclose = request.security("INDEX:BTCUSD/CRYPTOCAP:USDT.D", timeframe.period, close)
float ratiohigh  = request.security("INDEX:BTCUSD/CRYPTOCAP:USDT.D", timeframe.period, high)
float ratiolow   = request.security("INDEX:BTCUSD/CRYPTOCAP:USDT.D", timeframe.period, low)
float ratioopen  = request.security("INDEX:BTCUSD/CRYPTOCAP:USDT.D", timeframe.period, open)

color plotcolor = ratioclose > thresh_hi ? neg_col : ratioclose < thresh_lo ? pos_col : color.black

color bgcol = ratioclose < thresh_lo ? color.new(pos_col, 50) :
              ratioclose > thresh_hi ? color.new(neg_col, 50) : na

bgcolor(bgcol, force_overlay=true)

plotcandle(open, high, low, close, "Price Candle",
     plotcolor, plotcolor, bordercolor=plotcolor, force_overlay=true)

plotcandle(ratioopen, ratiohigh, ratiolow, ratiohigh, "Ratio Candle",
     plotcolor, plotcolor, bordercolor=plotcolor)

plot(thresh_lo, "Oversold Line",   color=pos_col, linewidth=1)
plot(thresh_hi, "Overbought Line", color=neg_col, linewidth=1)
````
