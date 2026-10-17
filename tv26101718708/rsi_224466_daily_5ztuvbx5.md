# RSI 22/44/66 Daily

- url: https://www.tradingview.com/script/5ztuVbx5-RSI-22-44-66-Daily/
- type: indicator
- pine_id: PUB;adefddf561e5467ca50c5092a123f327
- version: 1.0

## Description

its show rsi data for 1 month 2 month & 3 month so that we can get which stocks are in momentum since last 3 month

## Source Code

````pine
 //@version=5
indicator("RSI 22/44/66 Daily", shorttitle="RSI 22‑44‑66", overlay=false)

// Inputs
length22 = 22
length44 = 44
length66 = 66
src      = close

// RSI calculations
rsi22 = ta.rsi(src, length22)
rsi44 = ta.rsi(src, length44)
rsi66 = ta.rsi(src, length66)

// Print current RSI values as a label (you can copy‑paste this text)
txt = "Symbol: " + syminfo.ticker + "\n" +
      "RSI(22): " + str.tostring(rsi22, "#.##") + "\n" +
      "RSI(44): " + str.tostring(rsi44, "#.##") + "\n" +
      "RSI(66): " + str.tostring(rsi66, "#.##")

label.new(bar_index, 90, txt, color=color.new(color.black, 100), textcolor=color.white, style=label.style_label_left)

// Optional: plot lines for reference (optional, you can keep this for charts)
plot(rsi22, title="RSI(22)", color=color.blue, linewidth=2)
plot(rsi44, title="RSI(44)", color=color.orange, linewidth=2)
plot(rsi66, title="RSI(66)", color=color.red, linewidth=2)

// Neutral‑zone lines
h30 = hline(30, "Zone Low", color=color.new(color.gray, 70), linestyle=hline.style_dotted)
h70 = hline(70, "Zone High", color=color.new(color.gray, 70), linestyle=hline.style_dotted)
````
