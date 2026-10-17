# Trend Flip Risk Map

- url: https://www.tradingview.com/script/S1rwQT8N-Trend-Flip-Risk-Map/
- type: indicator
- pine_id: PUB;a42bc82033ea4c4c95ecc7eccece7ddd
- version: 1.0

## Description

[b]Trend Flip Risk Map [/b]

[b]Short description:[/b]
Trend Flip Risk Map is a structured trend-transition and risk-planning overlay that marks EMA regime flips with BUY/SELL planning labels, then projects an ATR-based Entry, Stop Loss, and TP1/TP2/TP3 ladder directly on the chart.

[b]Full description:[/b][/b]
Trend Flip Risk Map is a Trade Manager-style research indicator designed to make trend-transition areas easier to study, validate, and publish cleanly on TradingView. The script focuses on the moment when a faster EMA crosses above or below a slower EMA, then converts that trend flip into a clear visual risk map instead of leaving the trader to mentally estimate entry, invalidation, and profit-taking zones.

When the fast EMA flips above the slow EMA, the indicator can print a BUY planning marker. When the fast EMA flips below the slow EMA, it can print a SELL planning marker. Each marker is paired with a fresh trade-planning ladder that includes an Entry reference, an ATR-based Stop Loss, and three configurable R-multiple targets: TP1, TP2, and TP3.

The goal is not to predict every market turn. The goal is to create a cleaner decision map around confirmed trend changes so a trader can quickly see:
- Where the trend-transition signal occurred
- Which side of the market the EMA regime currently favours
- Where the entry reference sits relative to price
- Where the idea is visually invalidated by the Stop Loss level
- Where staged target zones would appear if the move continues
- Whether the available reward profile is worth further review before any trade decision

[b]Core visual elements:[/b]
- Fast EMA and slow EMA regime map
- BUY labels on bullish EMA trend flips
- SELL labels on bearish EMA trend flips
- ATR-based Stop Loss projection
- Entry reference line
- TP1, TP2, and TP3 R-multiple target ladder
- Trend-coloured candles to show the active EMA bias
- Right-side price labels for Entry, SL, TP1, TP2, and TP3
- Alert conditions for bullish and bearish planning markers

[b]How it works:[/b]
The indicator uses a fast EMA and a slow EMA to define the active trend regime. A bullish flip occurs when the fast EMA crosses above the slow EMA. A bearish flip occurs when the fast EMA crosses below the slow EMA. On each new flip, the prior ladder is cleared and a new risk map is drawn from the latest signal area.

The Stop Loss is calculated using ATR, which allows the risk zone to expand or contract with current market volatility. The take-profit levels are then projected from the distance between Entry and Stop Loss, using configurable R-multiple inputs. This keeps the visual structure consistent across different symbols, price ranges, and volatility conditions.

[b]Suggested use cases:[/b]
- Studying clean trend-transition zones after EMA regime changes
- Building publication screenshots with a complete BUY/SELL + TP/SL path
- Reviewing whether a trend flip has enough room before nearby structure
- Comparing signals across intraday futures, indexes, stocks, crypto, or forex charts
- Forward-validating a simple trend-following planning model before developing stricter rules
- Creating a consistent visual framework for entry, invalidation, and staged target discussion

[b]Suggested chart setup:[/b]
For publishing, 15-minute or 30-minute charts usually give the cleanest balance between readable trend structure and enough signal detail. For broader swing review, 1-hour charts may be cleaner. Very low timeframes can create more frequent flips and may make screenshots look crowded, so use them only when the purpose is short-term scalping review.

[b]Recommended markets and timeframes:[/b]
- NQ / ES: 15m or 30m for intraday trend-transition examples
- Major index ETFs: 30m or 1h for cleaner directional examples
- Liquid large-cap stocks: 30m or 1h
- Crypto majors: 30m, 1h, or 4h depending on volatility

[b]Input controls:[/b]
- Fast EMA length
- Slow EMA length
- ATR length
- Stop Loss ATR multiplier
- TP1 R-multiple
- TP2 R-multiple
- TP3 R-multiple
- Confirm on close toggle
- BUY, SELL, TP, SL, and Entry colours

[b]Reading the indicator:[/b]
A BUY marker means the fast EMA has flipped above the slow EMA under the selected settings. A SELL marker means the fast EMA has flipped below the slow EMA under the selected settings. The Entry line shows the reference price used when the marker was created. The SL line shows the ATR-based invalidation area. TP1, TP2, and TP3 show staged target references based on the configured R-multiple values.

Because the ladder is redrawn at each new flip, the chart stays focused on the most recent active trend-transition map rather than accumulating old levels across the full chart.

[b]What makes this useful:[/b]
Many trend-following tools stop at a signal label or a moving-average crossover. Trend Flip Risk Map adds the missing planning layer: where the idea starts, where it fails, and where staged targets would be located if the move extends. That makes the signal easier to review visually, easier to screenshot for educational publishing, and easier to forward-test with consistent rules.

[b]Best practices:[/b]
- Use the indicator as a planning and research overlay, not as a standalone trading system
- Review signal quality in context with market structure, session timing, liquidity, and higher-timeframe trend
- Adjust ATR and R-multiple settings to match the symbol and timeframe being studied
- Avoid using very small stop settings on volatile markets without additional validation
- Forward-test settings before relying on them for any decision-making process
- Use clean screenshots with only a few strong examples visible when publishing





Important disclaimer:
This script is provided for educational, research, and chart-planning purposes only. BUY/SELL markers, Entry levels, Stop Loss levels, and TP levels are visual planning references, not financial advice, trade recommendations, or promises of future performance. The script does not predict market direction, guarantee profitability, or replace independent risk management. Markets involve risk, and all settings should be tested on your own symbol, timeframe, and risk model before relying on any output.

## Source Code

````pine
//@version=6
indicator("Trend Flip Risk Map", shorttitle="Trend Flip Risk", overlay=true, max_lines_count=80, max_labels_count=80)

// Trade Manager original research tool. BUY/SELL and TP/SL visuals are planning references only. Not financial advice.

emaFastLen = input.int(21, "Fast EMA", minval=2, group="Trend")
emaSlowLen = input.int(55, "Slow EMA", minval=3, group="Trend")
atrLen = input.int(14, "ATR Length", minval=2, group="Risk")
slAtr = input.float(1.5, "SL ATR Multiplier", minval=0.25, step=0.25, group="Risk")
rr1 = input.float(1.0, "TP1 R", minval=0.25, step=0.25, group="Risk")
rr2 = input.float(2.0, "TP2 R", minval=0.5, step=0.25, group="Risk")
rr3 = input.float(3.0, "TP3 R", minval=0.75, step=0.25, group="Risk")
useCloseConfirm = input.bool(true, "Confirm On Close", group="Signals")
bullColor = input.color(color.rgb(38,166,154), "BUY Color", group="Display")
bearColor = input.color(color.rgb(239,83,80), "SELL Color", group="Display")
tpColor = input.color(color.rgb(102,187,106), "TP Color", group="Display")
slColor = input.color(color.rgb(239,83,80), "SL Color", group="Display")
entryColor = input.color(color.rgb(255,167,38), "Entry Color", group="Display")

fast = ta.ema(close, emaFastLen)
slow = ta.ema(close, emaSlowLen)
atr = ta.atr(atrLen)
bull = fast > slow
bear = fast < slow
buySignal = ta.crossover(fast, slow) and (not useCloseConfirm or barstate.isconfirmed)
sellSignal = ta.crossunder(fast, slow) and (not useCloseConfirm or barstate.isconfirmed)

plot(fast, "Fast EMA", color=bull ? bullColor : bearColor, linewidth=2)
plot(slow, "Slow EMA", color=color.new(color.white, 35), linewidth=2)
barcolor(bull ? color.new(bullColor, 82) : bear ? color.new(bearColor, 82) : na)

var line entryLine = na
var line slLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na
var label entryLab = na
var label slLab = na
var label tp1Lab = na
var label tp2Lab = na
var label tp3Lab = na
if buySignal or sellSignal
    if not na(entryLine)
        line.delete(entryLine)
        line.delete(slLine)
        line.delete(tp1Line)
        line.delete(tp2Line)
        line.delete(tp3Line)
        label.delete(entryLab)
        label.delete(slLab)
        label.delete(tp1Lab)
        label.delete(tp2Lab)
        label.delete(tp3Lab)
    dir = buySignal ? 1.0 : -1.0
    entry = close
    sl = entry - dir * atr * slAtr
    risk = math.max(math.abs(entry - sl), syminfo.mintick)
    tp1 = entry + dir * risk * rr1
    tp2 = entry + dir * risk * rr2
    tp3 = entry + dir * risk * rr3
    sigColor = buySignal ? bullColor : bearColor
    label.new(bar_index, buySignal ? low : high, buySignal ? "BUY" : "SELL", style=buySignal ? label.style_label_up : label.style_label_down, color=sigColor, textcolor=color.white)
    entryLine := line.new(bar_index, entry, bar_index + 80, entry, extend=extend.right, color=entryColor, width=2)
    slLine := line.new(bar_index, sl, bar_index + 80, sl, extend=extend.right, color=slColor, width=2)
    tp1Line := line.new(bar_index, tp1, bar_index + 80, tp1, extend=extend.right, color=tpColor, width=1)
    tp2Line := line.new(bar_index, tp2, bar_index + 80, tp2, extend=extend.right, color=tpColor, width=1)
    tp3Line := line.new(bar_index, tp3, bar_index + 80, tp3, extend=extend.right, color=tpColor, width=2)
    entryLab := label.new(bar_index + 2, entry, "ENTRY " + str.tostring(entry, format.mintick), style=label.style_label_left, color=entryColor, textcolor=color.white)
    slLab := label.new(bar_index + 2, sl, "SL " + str.tostring(sl, format.mintick), style=label.style_label_left, color=slColor, textcolor=color.white)
    tp1Lab := label.new(bar_index + 2, tp1, "TP1 " + str.tostring(tp1, format.mintick), style=label.style_label_left, color=tpColor, textcolor=color.white)
    tp2Lab := label.new(bar_index + 2, tp2, "TP2 " + str.tostring(tp2, format.mintick), style=label.style_label_left, color=tpColor, textcolor=color.white)
    tp3Lab := label.new(bar_index + 2, tp3, "TP3 " + str.tostring(tp3, format.mintick), style=label.style_label_left, color=tpColor, textcolor=color.white)

alertcondition(buySignal, "Trend Flip Risk Map BUY", "Trend Flip Risk Map: BUY planning marker created with TP/SL ladder.")
alertcondition(sellSignal, "Trend Flip Risk Map SELL", "Trend Flip Risk Map: SELL planning marker created with TP/SL ladder.")
````
