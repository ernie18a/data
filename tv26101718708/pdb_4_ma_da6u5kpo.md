# PDB - 4 MA

- url: https://www.tradingview.com/script/Da6u5KpO-PDB-4-MA/
- type: indicator
- pine_id: PUB;1ba5bd26be8b4a00914b6a0f0d145c8f
- version: 1.0

## Description

4 Moving Averages 
RED = 20
YELLOW = 50
PURPLE = 100
WHITE  = 200

Built for dark mode; adjust color for light mode

MA Value can be changed if you don't like my defaults :-(

## Source Code

````pine

//@version=6
indicator("PDB - 4 MA", overlay=true)

maType   = input.string("SMA", "MA Type", options=["SMA", "EMA"])
ma20len  = input.int(20,  "MA 20 Length")
ma50len  = input.int(50,  "MA 50 Length")
ma100len = input.int(100, "MA 100 Length")
ma200len = input.int(200, "MA 200 Length")

ma(source, length) =>
    maType == "SMA" ? ta.sma(source, length) : ta.ema(source, length)

ma20  = ma(close, ma20len)
ma50  = ma(close, ma50len)
ma100 = ma(close, ma100len)
ma200 = ma(close, ma200len)

// PDB MA Legend: Red=20 | Yellow=50 | Purple=100 | White=200
plot(ma20,  color=color.red,    linewidth=2, title="MA 20")
plot(ma50,  color=color.yellow, linewidth=2, title="MA 50")
plot(ma100, color=color.purple, linewidth=2, title="MA 100")
plot(ma200, color=color.white,  linewidth=2, title="MA 200")
````
