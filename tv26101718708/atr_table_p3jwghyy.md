# ATR% Table

- url: https://www.tradingview.com/script/p3jwghYy-ATR-Table/
- type: indicator
- pine_id: PUB;17cde3d18bfe4a1091948f3337880de9
- version: 1.0

## Description

ATR% Table

ATR% Table is a clean and minimal volatility indicator designed for Indian equity traders. It displays the Average True Range percentage (ATR%) of any stock directly on the chart as a color-coded label, helping traders instantly assess how volatile a stock is before entering a trade.

What it shows:
ATR% tells you how much a stock moves on average relative to its price. For example, ATR% of 3% on a ₹500 stock means it moves approximately ₹15 per day on average.

Color Coding:
- 🔴 Red — Below 4% (low to moderate volatility)
- 🔵 Blue — Above 4% (high volatility, larger moves expected)

How to use:
- Use ATR% to set better stop losses — avoid keeping stop loss tighter than ATR range
- High ATR% stocks are better for short term momentum trades
- Low ATR% stocks suit positional traders who prefer slow and steady movers
- Combine with Liquidity Indicator LR for best results — high liquidity + good ATR% = ideal swing trade candidate

Settings:
- ATR Period — default 14 (customizable)
- Table Position — top right / top left / middle right / middle left / bottom right / bottom left
- Label Size — tiny / small / normal / large / huge

## Source Code

````pine
//@version=6
indicator("ATR% Table", overlay=true, shorttitle="ATR%")

// ── Inputs ──────────────────────────────────────────────────
atrPeriod = input.int(14, "ATR Period", minval=1)
tablePos  = input.string("top_right", "Table Position",
             options=["top_right","top_left","middle_right","middle_left","bottom_right","bottom_left"])
textSize  = input.string("normal", "Label Size",
             options=["tiny","small","normal","large","huge"])

// ── Calculations ─────────────────────────────────────────────
atrVal  = ta.atr(atrPeriod)
atrPct  = (atrVal / close) * 100

// ── Color Logic ───────────────────────────────────────────────
atrColor = atrPct < 4 ? color.red : color.blue

// ── Size Map ─────────────────────────────────────────────────
sizeMap = textSize == "tiny"  ? size.tiny  :
          textSize == "small" ? size.small :
          textSize == "large" ? size.large :
          textSize == "huge"  ? size.huge  : size.normal

// ── Position Map ─────────────────────────────────────────────
posMap = tablePos == "top_right"    ? position.top_right    :
         tablePos == "top_left"     ? position.top_left     :
         tablePos == "middle_right" ? position.middle_right :
         tablePos == "middle_left"  ? position.middle_left  :
         tablePos == "bottom_right" ? position.bottom_right :
         position.bottom_left

// ── Table ─────────────────────────────────────────────────────
var table t = table.new(posMap, 1, 1, border_width=0, frame_width=0)

if barstate.islast
    table.cell(t, 0, 0, "ATR " + str.tostring(math.round(atrPct, 2)) + "%",
         text_color=color.white, bgcolor=atrColor, text_size=sizeMap)
````
