# Order Imbalance / Volume Regime

- url: https://www.tradingview.com/script/wD1sFPeV/
- type: indicator
- pine_id: PUB;1c79b7f4cf734b47b763d6a19a82a494
- version: 1.0

## Description

A buy-versus-sell volume imbalance proxy using the up-bar / down-bar (tick) rule when level-1 order data is unavailable, plus a percentile-rank regime of total traded volume. Highlights directional pressure and activity bursts. It does NOT generate buy or sell signals.

What it shows
- Cumulative buy-minus-sell volume imbalance over a window, normalised to [-1, 1]
- Volume percentile rank
- Volume regime (Quiet / Normal / High / Burst)

Honest by design
- No buy/sell signals. The imbalance is a descriptive pressure proxy, not a directional call.
- Non-repainting: backward-looking sums on confirmed bars.

Open-source and MIT licensed.

Disclaimer: impersonal educational and analytics tool. This is not investment advice, not a personalised recommendation, and carries no performance guarantee. Past results do not predict future results. You are solely responsible for your own trading decisions.

## Source Code

````pine
//@version=6
// Order Imbalance / Volume Regime
// Buy-versus-sell volume imbalance proxy using the up-bar / down-bar
// rule (Tick Rule when no L1 data is available). The cumulative
// imbalance over a window plus a percentile-rank regime of total
// traded volume highlights pressure and activity bursts. Analytics
// only, no signals, non-repainting.
indicator("Order Imbalance / Volume Regime", overlay = false)
// Disclaimer: impersonal educational/analytics tool, not investment advice, no
// performance guarantees, no buy/sell signals, no auto-execution.

winLen   = input.int(20, "Imbalance window", minval = 2, group = "Window")
volLook  = input.int(120, "Volume percentile lookback",
     minval = 10, group = "Regime")

isUp = close > close[1]
isDown = close < close[1]
buyVol = isUp ? volume : 0.0
sellVol = isDown ? volume : 0.0
neutVol = (not isUp and not isDown) ? volume : 0.0

bw = math.sum(buyVol, winLen)
sw = math.sum(sellVol, winLen)
tw = bw + sw + math.sum(neutVol, winLen)
imbalance = tw > 0 ? (bw - sw) / tw : na

volRank = ta.percentrank(volume, volLook)
volRegime = volRank >= 90.0 ? "Burst" : volRank >= 70.0 ? "High" :
     volRank >= 30.0 ? "Normal" : "Quiet"
volColor = volRank >= 90.0 ? color.red : volRank >= 70.0 ? color.orange :
     volRank >= 30.0 ? color.green : color.gray

plot(imbalance, title = "Imbalance",
     color = imbalance >= 0 ? color.new(color.green, 0) :
          color.new(color.red, 0), linewidth = 2)
hline(0, title = "neutral",
     color = color.new(color.gray, 50), linestyle = hline.style_dashed)

var table t = table.new(position.top_right, 2, 4, border_width = 1)
if barstate.islast
    table.cell(t, 0, 0, "Imbalance / Volume",
         text_color = color.white, bgcolor = color.new(color.black, 0))
    table.cell(t, 1, 0, "", bgcolor = color.new(color.black, 0))
    table.cell(t, 0, 1, "Imbalance")
    table.cell(t, 1, 1, na(imbalance) ? "na" :
         str.tostring(imbalance, "#.###"))
    table.cell(t, 0, 2, "Volume percentile")
    table.cell(t, 1, 2, str.tostring(volRank, "#.#") + "%")
    table.cell(t, 0, 3, "Volume regime")
    table.cell(t, 1, 3, volRegime, text_color = color.white,
         bgcolor = color.new(volColor, 30))
````
