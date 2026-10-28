# Volume Delta 2Minute (TopinTrade)

- url: https://www.tradingview.com/script/Zne3jjMS-Volume-Delta-2Minute-TopinTrade/
- type: indicator
- pine_id: PUB;50d520dd08b24fbe8e518bf9af730531
- version: 1.0

## Description

📊 Volume Delta Indicator

This tool visualizes the difference between buying and selling volume 
(Delta) to help traders understand the real pressure behind each candle.

⚠️ Important Notice:
This indicator does NOT generate buy or sell signals.
It is designed purely as a confirmation tool to support your existing 
trading strategy — not to replace it.

📌 How to use:
- Positive Delta → Buying pressure is dominant
- Negative Delta → Selling pressure is dominant

Use this data to confirm your strategy entries and exits, 
not as a standalone reason to trade.

🔒 Risk Management:
No indicator can replace proper risk management.
Always define your risk before entering any trade.
Never risk more than you can afford to lose.

⚠️ Disclaimer:
This is not financial advice. Past performance does not guarantee 
future results. You are solely responsible for your trading decisions.

## Source Code

````pine
//@version=6
indicator("Volume Delta(TopinTrade)", format=format.volume)

import TradingView/ta/8


lowerTimeframeTooltip = "The indicator scans lower timeframe data to approximate up and down volume used in the delta calculation. By default, the timeframe is chosen automatically. These inputs override this with a custom timeframe."
 + " \n\nHigher timeframes provide more historical data, but the data will be less precise."
useCustomTimeframeInput = input.bool(true, "Use custom timeframe", tooltip = lowerTimeframeTooltip)
// lowerTimeframeInput = input.timeframe("1", "Timeframe", active = useCustomTimeframeInput)

var string lowerTimeframeInput = input.string("2", "TimeFrame")


var lowerTimeframe = switch
    useCustomTimeframeInput => lowerTimeframeInput
    timeframe.isseconds     => "1S"
    timeframe.isintraday    => "1"
    timeframe.isdaily       => "5"
    => "60"

[openVolume, maxVolume, minVolume, lastVolume] = ta.requestVolumeDelta(lowerTimeframe)


col = lastVolume > 0 ? color.teal : color.red
hline(0)
plotcandle(openVolume, maxVolume, minVolume, lastVolume, "Volume Delta", color = col, bordercolor = col, wickcolor = col)

var cumVol = 0.
cumVol += nz(volume)
if barstate.islast and cumVol == 0
    runtime.error("The data vendor doesn't provide volume data for this symbol.")
````
