# Tight After Big Move

- url: https://www.tradingview.com/script/f2UP0NmD-Tight-After-Big-Move/
- type: indicator
- pine_id: PUB;442180ea28fd4fdf916f29b14d1b4bbf
- version: 1.0

## Description

Find those tight actionable days after a big move up where you can join for continuation.

## Source Code

````pine
//@version=5
indicator("Tight After Big Move", overlay=true)

shortMovePct     = input.float(15.0, "Min % move over short window")
shortLookback    = input.int(20, "Short lookback (sessions)")
longMovePct      = input.float(30.0, "Min % move over long window")
longLookback     = input.int(60, "Long lookback (sessions)")
tightRangeMult   = input.float(0.7, "Today range vs ADR20 max")
adrLookback      = input.int(20, "ADR lookback")

shortLow    = ta.lowest(low, shortLookback)
shortMove   = (close / shortLow - 1) * 100
shortMoveOK = shortMove >= shortMovePct

longLow     = ta.lowest(low, longLookback)
longMove    = (close / longLow - 1) * 100
longMoveOK  = longMove >= longMovePct

hadBigMove  = shortMoveOK or longMoveOK

todayRangePct = (high - low) / close * 100
adrStable     = ta.sma((high - low) / close * 100, adrLookback)
tightToday    = todayRangePct <= adrStable * tightRangeMult

setup = hadBigMove and tightToday

plotshape(setup, title="Tight", location=location.belowbar, color=color.yellow, style=shape.diamond, size=size.tiny)

plot(setup ? 1 : 0, title="Setup Match", color=color.new(color.white, 100))
````
