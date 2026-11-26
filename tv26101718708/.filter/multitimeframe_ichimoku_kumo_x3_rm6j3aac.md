# Multi-Timeframe Ichimoku Kumo x3

- url: https://www.tradingview.com/script/Rm6J3aAC/
- type: indicator
- pine_id: PUB;a133c565ef384b2bbca43251647772ae
- version: 1.0

## Description

MTF KUMO , superposition des 3 UT au niveau du kumo + tableur correlation

## Source Code

````pine
//@version=6
indicator("Multi-Timeframe Ichimoku Kumo x3", overlay=true)

// === Paramètres Ichimoku ===
tenkanLen = input.int(9, "Tenkan", minval=1)
kijunLen  = input.int(26, "Kijun", minval=1)
senkouLen = input.int(52, "Senkou B", minval=1)
displacement = input.int(26, "Décalage Kumo", minval=1)

// === Timeframes ===
tf1 = input.timeframe("60", "UT 1")
tf2 = input.timeframe("15", "UT 2")
tf3 = input.timeframe("5", "UT 3")

// === Fonction Ichimoku ===
ichimokuCloud() =>
    tenkan = (ta.highest(high, tenkanLen) + ta.lowest(low, tenkanLen)) / 2
    kijun  = (ta.highest(high, kijunLen) + ta.lowest(low, kijunLen)) / 2
    spanA  = (tenkan + kijun) / 2
    spanB  = (ta.highest(high, senkouLen) + ta.lowest(low, senkouLen)) / 2
    [spanA, spanB]

// === Récupération MTF ===
[spanA1, spanB1] = request.security(syminfo.tickerid, tf1, ichimokuCloud())
[spanA2, spanB2] = request.security(syminfo.tickerid, tf2, ichimokuCloud())
[spanA3, spanB3] = request.security(syminfo.tickerid, tf3, ichimokuCloud())

// === Plots invisibles pour remplissage ===
pA1 = plot(spanA1, "Senkou A UT1", color=color.new(color.green, 70), offset=displacement)
pB1 = plot(spanB1, "Senkou B UT1", color=color.new(color.red, 70), offset=displacement)
fill(pA1, pB1, color=spanA1 >= spanB1 ? color.new(color.green, 85) : color.new(color.red, 85), title="Kumo UT1")

pA2 = plot(spanA2, "Senkou A UT2", color=color.new(color.blue, 70), offset=displacement)
pB2 = plot(spanB2, "Senkou B UT2", color=color.new(color.orange, 70), offset=displacement)
fill(pA2, pB2, color=spanA2 >= spanB2 ? color.new(color.blue, 88) : color.new(color.orange, 88), title="Kumo UT2")

pA3 = plot(spanA3, "Senkou A UT3", color=color.new(color.teal, 70), offset=displacement)
pB3 = plot(spanB3, "Senkou B UT3", color=color.new(color.purple, 70), offset=displacement)
fill(pA3, pB3, color=spanA3 >= spanB3 ? color.new(color.teal, 90) : color.new(color.purple, 90), title="Kumo UT3")
// === Tableau de confluence ===
showTable = input.bool(true, "Afficher tableau de confluence")

var table confluenceTable = table.new(position.top_right, 2, 4, border_width=1)

trendText(spanA, spanB) =>
    spanA > spanB ? "Bull" : spanA < spanB ? "Bear" : "Neutre"

trendColor(spanA, spanB) =>
    spanA > spanB ? color.new(color.green, 0) : spanA < spanB ? color.new(color.red, 0) : color.new(color.gray, 0)

if barstate.islast and showTable
    table.cell(confluenceTable, 0, 0, "UT", text_color=color.white, bgcolor=color.black)
    table.cell(confluenceTable, 1, 0, "Kumo", text_color=color.white, bgcolor=color.black)

    table.cell(confluenceTable, 0, 1, tf1, text_color=color.white)
    table.cell(confluenceTable, 1, 1, trendText(spanA1, spanB1), text_color=color.white, bgcolor=trendColor(spanA1, spanB1))

    table.cell(confluenceTable, 0, 2, tf2, text_color=color.white)
    table.cell(confluenceTable, 1, 2, trendText(spanA2, spanB2), text_color=color.white, bgcolor=trendColor(spanA2, spanB2))

    table.cell(confluenceTable, 0, 3, tf3, text_color=color.white)
    table.cell(confluenceTable, 1, 3, trendText(spanA3, spanB3), text_color=color.white, bgcolor=trendColor(spanA3, spanB3))
````
