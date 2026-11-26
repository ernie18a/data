# Linie Open 5min 

- url: https://www.tradingview.com/script/FQ9OW58v-Linie-Open-5min/
- type: indicator
- pine_id: PUB;185aeaf78696424283e93c97264ed9df
- version: 1.0

## Description

English translation:
5min Open Line - ONLY Current Candle
Display a horizontal line at the open price where the current 5-minute candle starts.
Only for the current 5-minute candle.

## Source Code

````pine
//@version=5
indicator("Linie Open 5min - DOAR Candela Curentă", shorttitle="5M Open Current", overlay=true)

// ================== INPUTURI ==================
lineColor = input.color(color.new(#2962FF, 0), "Culoare linie", group="Setări Linie")
lineWidth = input.int(2, "Grosime linie", minval=1, maxval=5, group="Setări Linie")

// ================== DETECTARE TIMFRAME ==================
bool isLowerTF = timeframe.in_seconds() < 300   // < 5 minute (1S, 15S, 1M, 2M, 3M, 4M etc.)

// ================== OBȚINERE OPEN + STATUS CANDELA CURENTĂ ==================
// Folosim barstate.islast pe timeframe-ul de 5 minute
// → asta face ca valoarea să fie valabilă DOAR pentru candela 5min în desfășurare
getCurrent5m() =>
    [open, barstate.islast]

[open5m, isCurrent5m] = request.security(syminfo.tickerid, "5", getCurrent5m(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// ================== PLOT ==================
// Linia apare DOAR pe TF < 5min ȘI DOAR pentru candela 5min curentă
plot(isLowerTF and isCurrent5m ? open5m : na, 
     title="Open Candelă 5min Curentă", 
     color=lineColor, 
     linewidth=lineWidth, 
     style=plot.style_linebr)
````
