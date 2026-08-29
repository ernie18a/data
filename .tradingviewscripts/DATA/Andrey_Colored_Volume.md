<!-- tradingview-pine-id: PUB;d6efb7a594c543aa9f67affb9e7d8dca -->
<!-- tradingviewscripts-format: 1 -->
# Andrey Colored Volume

Source: https://www.tradingview.com/script/muhLYKgi-Group-Colored-Volume/

## Description

well oh well.
This is for the group. they know. what is it about. rough but i am happy

---

## Source Code

````pine
//@version=6
indicator("Andrey Colored Volume", overlay=true)

//---------------------------------------------------------
// Volume values (same as TradingView)
//---------------------------------------------------------
vol      = volume
vol_prev = volume[1]

//---------------------------------------------------------
// 3‑color logic
//---------------------------------------------------------
volColor =
     vol > vol_prev ? color.green :
     vol < vol_prev ? color.red   :
                      color.yellow

//---------------------------------------------------------
// Plot volume exactly like TradingView
//---------------------------------------------------------
plot(vol,
     title = "Volume",
     style = plot.style_columns,
     color = volColor)
````
