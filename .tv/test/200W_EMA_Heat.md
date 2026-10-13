<!-- tradingview-pine-id: PUB;8bf7efdd72d24fed9c14b2ab2d82b8e0 -->
<!-- tradingviewscripts-format: 1 -->
# 200W EMA Heat

Source: https://www.tradingview.com/script/R5tatqRR-200W-EMA-Hot-Cold/

## Description

Shows how far price has stretched from its 200-week EMA, expressed as a percentage — a quick read on whether a stock is "hot" or "cold" relative to its own long-term trend.
Unlike a fixed-band overbought/oversold indicator, the color is driven by a percentile rank of that % distance against the stock's own history (default 5-year lookback), so the read is calibrated per-ticker instead of using the same thresholds for a sleepy utility stock and a high-beta growth name.
How to read it:
• Columns show the raw % distance from the 200W EMA (0 = price at the EMA)
• Color shifts blue → gray → red as the current reading moves from the coldest to the hottest it's been for that stock
• Top-right table shows the live % and a plain-language zone: COLD / COOL / NEUTRAL / WARM / HOT
• Built-in alerts fire when a stock enters the top or bottom 10% of its own historical range
All calculations run on weekly bars internally via request.security(), so the reading is identical whether you're viewing a daily, weekly, or monthly chart. An "Avoid Repaint" toggle (on by default) locks values to the last closed weekly bar so historical readings never repaint.
Not financial advice — a context tool for gauging trend extension, not a standalone buy/sell signal.

---

## Source Code

````pine
// This Pine Script code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © utkarsh.bansal
//@version=6
indicator('200W EMA Heat', shorttitle = '200W Heat', overlay = false)

// ───────────────────────────── Inputs ─────────────────────────────
emaLength = input.int(200, 'EMA Length (weekly bars)', minval = 10)
pctLookback = input.int(260, 'Percentile Lookback (weekly bars)', minval = 20, tooltip = '260 weekly bars ≈ 5 years. This is how far back the indicator looks to judge whether the current % distance is \'hot\' or \'cold\' for THIS stock specifically.')
avoidRepaint = input.bool(true, 'Avoid Repaint (lag 1 confirmed weekly bar)', tooltip = 'When on, values are pulled from the last CLOSED weekly bar so nothing repaints, at the cost of being one week behind on the most recent reading. Turn off to see the live, unconfirmed current-week value (it will repaint intra-week).')

coldColor = input.color(color.new(#2962FF, 0), 'Cold color', group = 'Colors')
neutralColor = input.color(color.new(#787B86, 0), 'Neutral color', group = 'Colors')
hotColor = input.color(color.new(#FF1744, 0), 'Hot color', group = 'Colors')

// ───────────────────────────── Weekly calc (context-independent of chart TF) ─────────────────────────────
f_weekly() =>
    ema200w = ta.ema(close, emaLength)
    pct = (close - ema200w) / ema200w * 100
    rank = ta.percentrank(pct, pctLookback)
    offsetIdx = avoidRepaint ? 1 : 0
    [pct[offsetIdx], rank[offsetIdx]]

[pctDistance, pctRank] = request.security(syminfo.tickerid, 'W', f_weekly(), barmerge.gaps_off, barmerge.lookahead_off)

// ───────────────────────────── Color: diverging gradient by percentile rank ─────────────────────────────
barColor = pctRank < 50 ? color.from_gradient(pctRank, 0, 50, coldColor, neutralColor) : color.from_gradient(pctRank, 50, 100, neutralColor, hotColor)

// ───────────────────────────── Plots ─────────────────────────────
plot(pctDistance, title = '% Distance from 200W EMA', style = plot.style_columns, color = barColor)
hline(0, 'Zero (price = 200W EMA)', color = color.new(color.gray, 50), linestyle = hline.style_dashed)

// ───────────────────────────── Zone label ─────────────────────────────
zone(rank) =>
    rank < 10 ? 'COLD' : rank < 30 ? 'COOL' : rank < 70 ? 'NEUTRAL' : rank < 90 ? 'WARM' : 'HOT'

var table infoTable = table.new(position.top_right, 1, 3, bgcolor = color.new(color.black, 80), border_width = 1)
if barstate.islast
    table.cell(infoTable, 0, 0, syminfo.ticker, text_color = color.white, text_size = size.small)
    table.cell(infoTable, 0, 1, str.tostring(pctDistance, '#.##') + '% from 200W EMA', text_color = color.white, text_size = size.small)
    table.cell(infoTable, 0, 2, zone(pctRank) + '  (percentile ' + str.tostring(pctRank, '#') + ')', text_color = barColor, text_size = size.normal)

// ───────────────────────────── Alerts ─────────────────────────────
alertcondition(pctRank >= 90, title = 'Overheated (top 10% percentile)', message = '{{ticker}} is HOT: {{plot_0}}% above its 200W EMA, top 10% of its own history.')
alertcondition(pctRank <= 10, title = 'Deeply Cold (bottom 10% percentile)', message = '{{ticker}} is COLD: {{plot_0}}% from its 200W EMA, bottom 10% of its own history.')
````
