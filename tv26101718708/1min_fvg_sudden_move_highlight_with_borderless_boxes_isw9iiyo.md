# 1min fvg & sudden move highlight with borderless boxes

- url: https://www.tradingview.com/script/iSw9iIyo/
- type: indicator
- pine_id: PUB;e7321b34bb7342edbb038dfb2ddda38e
- version: 1.0

## Description

1. Bullish FVG Strategy (Long Position)
A Bullish FVG (Green Box) indicates a sudden surge in buying pressure, leaving a price imbalance. The market tends to return to this zone to fill orders before continuing upward.

       [Candle 3]  ▲ (Current) 
        ┃  ┃
       [   ]
  ------ ┃ -------- [Box Top: Current Candle Low]


 |      FVG        | -> BUY ZONE (Scale in as price dips here)
  ------ ┃ -------- [Box Bottom: 2 Bars Ago High]
        ┃  ┃
       [Candle 1]  ▲ (2 Bars Ago)

Entry: Wait for the price to pull back into the Green Box. Scale in your buy orders within the box (the middle or bottom of the box offers the best risk-to-reward).
Stop Loss (SL): Place your stop loss just below the Box Bottom (High of 2 bars ago) or the low of the large expansion candle.
Take Profit (TP): Target the recent Swing High or the nearest Bearish FVG box above.
2. Bearish FVG Strategy (Short Position)
A Bearish FVG (Red Box) shows aggressive selling pressure. You look for a temporary technical bounce into this imbalance to short the market.
Entry: Wait for the price to relief-rally back up into the Red Box. Scale in your short orders inside this zone.
Stop Loss (SL): Place your stop loss just above the Box Top (Low of 2 bars ago).
Take Profit (TP): Target the recent Swing Low or the nearest Bullish FVG box below.
3. Sudden Move Candles (Yellow/Purple) as Filters
The Yellow (Sudden Up) and Purple (Sudden Down) candles represent high-momentum volume expansions.
Trend Confirmation: If a Bullish FVG is formed by a Yellow Candle breaking out of a tight consolidation, it has a much higher success rate.
Invalidation Filter: When the price returns to your Bullish FVG box, it should do so on low volume and small candles. If the price crashes back into your green box via a Purple (Sudden Down) candle, skip the trade entirely. The momentum has shifted.
⚠️ Golden Rules for 1-Minute Chart Trading
Higher Timeframe Filter: 1-minute charts have a lot of market noise. Only take Longs (Green Boxes) when the 15-minute or 1-hour trend is bullish, and only take Shorts (Red Boxes) when the higher timeframe is bearish.
Mitigation: Once the price prints a candle body that completely cuts through and closes past the FVG box, that imbalance is "mitigated" (filled). Do not trade that box again.

## Source Code

````pine
//@version=5
indicator("1min fvg & sudden move highlight with borderless boxes", overlay=true)

// --- input settings ---
bullishcolor   = input.color(color.new(#26a69a, 0), title="bullish fvg candle color")
bearishcolor   = input.color(color.new(#ef5350, 0), title="bearish fvg candle color")
suddenupcolor  = input.color(color.new(#ffeb3b, 0), title="sudden pump candle color")
suddendowncolor = input.color(color.new(#9c27b0, 0), title="sudden dump candle color")
onlyonemin     = input.bool(true, title="display on 1-minute chart only")
length         = input.int(20, title="average body length period")
mult           = input.float(2.0, title="sudden move multiplier (x times avg)")

// --- fvg box settings ---
showboxes      = input.bool(true, title="show fvg boxes")
boxtransp      = input.int(85, minval=0, maxval=100, title="fvg box transparency")
boxlength      = input.int(5, minval=1, title="fvg box extend length (bars)")

// --- 1-minute chart check ---
isonemin       = timeframe.isminutes and timeframe.multiplier == 1
allowdisplay   = not onlyonemin or isonemin

// --- sudden move condition calculations ---
candlebody     = math.abs(close - open)
avgbody        = ta.sma(candlebody, length)

// conditions for large candles based on average body size
issuddenup     = allowdisplay and (close > open) and (candlebody >= avgbody * mult)
issuddendown   = allowdisplay and (close < open) and (candlebody >= avgbody * mult)

// --- fvg condition calculations (3-candle basis) ---
// bullish fvg: 2봉 전의 고가 < 현재 봉의 저가
bullishfvg     = allowdisplay and (high[2] < low)
// bearish fvg: 2봉 전의 저가 > 현재 봉의 고가
bearishfvg     = allowdisplay and (low[2] > high)

// --- candle coloring (barcolor) ---
// priority: sudden pump > sudden dump > bullish fvg > bearish fvg
finalcolor     = issuddenup ? suddenupcolor : issuddendown ? suddendowncolor : bullishfvg ? bullishcolor : bearishfvg ? bearishcolor : na
barcolor(finalcolor)

// --- drawing fvg boxes ---
if showboxes
    if bullishfvg
        box.new(
             left=bar_index - 2, 
             top=low, 
             right=bar_index + boxlength, 
             bottom=high[2], 
             bgcolor=color.new(bullishcolor, boxtransp), 
             border_color=color.new(bullishcolor, 100)
             )
             
    if bearishfvg
        box.new(
             left=bar_index - 2, 
             top=low[2], 
             right=bar_index + boxlength, 
             bottom=high, 
             bgcolor=color.new(bearishcolor, boxtransp), 
             border_color=color.new(bearishcolor, 100)
             )
````
