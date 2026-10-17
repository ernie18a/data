# MSNR Order Block QML Indicator

- url: https://www.tradingview.com/script/Ic7eGG81-MSNR-Order-Block-QML-Indicator/
- type: indicator
- pine_id: PUB;8c24c84cff3641288f5b80586703e8e7
- version: 4.0

## Description

MSNR Order Block QML Indicator

A display-only, multi-timeframe indicator for gold and other markets. It draws structure on the chart and gives no buy or sell signals and no entries, stops or targets. What you trade is your decision.

WHAT IT DRAWS

MSNR levels (Malaysian Support & Resistance)
V, A and OCL levels built from H4, Daily, Weekly and Monthly candles. Each level is marked fresh until price first touches it, and touched levels can stay on the chart faded. H4 levels convert to RBS/SBR when an H1 candle closes through them. Support is a solid line (▲) and resistance is a dashed line (▼). Weekly and Monthly levels are backfilled from higher-timeframe history.

QML (Quasimodo) lines
Close-based Quasimodo structures on M5, M15, M30, H1 and optionally H4. A QML is drawn as a line at its level. A grey dashed "flip" line sits at the head's close. If a candle on the QML's own timeframe closes beyond that line, the QML is invalidated and removed.

Order blocks with a 0.5 line
The last opposite candle before a displacement that breaks the recent range, with its midpoint line. A block is removed when a candle on its own timeframe closes through it. Order block timeframes are chosen separately from QML timeframes.

External liquidity ($)
The last confirmed swing highs and lows of H1, H4 and Daily that have not been taken yet, labelled "$ H1", "$ H4" and "$ D".

CISD (M5 chart only)
After a wick takes an H1, H4 or Daily swing level, the first M5 close beyond the open of the last same-direction candle run is marked CISD ▲ or CISD ▼.

CLEAN-CHART TOOLS

- Colour by timeframe: each timeframe has one colour across MSNR, QML, order blocks and liquidity.
- Only items within a set multiple of the Daily ATR of price are drawn.
- Only the nearest N items per type, per side, are shown.
- Items of the same type and direction within a set dollar range (default $10) are merged. The most recently formed one is drawn and its label shows the count (x2, x3).
- All labels sit in one right-aligned column, spaced so they do not overlap.

NOTES

- Works on any chart timeframe. A source timeframe lower than the chart is switched off. H4 RBS/SBR conversion needs a chart of H1 or lower, and CISD needs an M5 chart.
- Higher-timeframe data uses closed candles only.
- Daily, weekly and monthly backfilled levels only become active on the last bar, so past bars show levels built from the candles on your chart.
- Everything is redrawn at candle close.

DISCLAIMER

For educational and informational use only. This is not financial advice, and no result is implied or guaranteed. Test it on your own charts and use your own risk management.

## Source Code

````pine
//@version=6
indicator("testing", overlay=true)

// This public version is retired and no longer maintained.
// The author now keeps the indicator private.

var label note = na
if barstate.islast
    label.delete(note)
    note := label.new(bar_index, high, "This public version is retired", style=label.style_label_down)
````
