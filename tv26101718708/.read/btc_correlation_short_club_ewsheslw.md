# BTC Correlation - short club

- url: https://www.tradingview.com/script/EWsHeSlw-btc-correlation-short-club/
- type: indicator
- pine_id: PUB;c53121cead93485eb50841434a51cda9
- version: 1.0

## Description

BTC Correlation % — Indicator Description
Author: Short Club / @DemianNagoga
Version: Pine Script v6
Type: Indicator (non-overlay, separate pane)

Overview
The BTC Correlation % indicator measures how closely an altcoin's price movements follow Bitcoin in real time. It uses Pearson correlation on 1-bar rate-of-change (RoC) values over a configurable lookback window, giving you a clear signal of whether the altcoin is riding BTC's coattails or moving independently.

How It Works
RoC Calculation — Computes the 1-bar % change for both the current chart symbol and BTC.
Pearson Correlation — Runs ta.correlation() over the user-defined lookback (default 50 bars).
Percentage Scale — Multiplies the correlation coefficient by 100, yielding a range from −100% to +100%.

Color-Coded Columns — The histogram is split into four segments, each plotted as a separate column-style plot for clean color separation.

Color Zones & Interpretation
Zone	Range	        Meaning
🟢 Green	> 70%	High correlation — altcoin closely follows BTC
🟡 Yellow	30–70%	Moderate correlation — partial BTC influence
⚪ Gray	0–30%	Weak correlation / decoupling — altcoin lives its own life
🔴 Red	< 0%	Inverse correlation — altcoin moves opposite to BTC
A dashed zero line sits at 0% for visual reference.

On-Chart Table
A small overlay table (position configurable: top-right, top-left, bottom-right, bottom-left) displays:

Ticker — current chart symbol
BTC Corr. — current correlation value in % (color-coded by zone)
Rating — qualitative label: Strong (>70%), Moderate (30–70%), Weak (0–30%), Inverse (<0%)
Input Parameters

Parameter	Default	Description

BTC Symbol	BINANCE:BTCUSDT.P	BTC pair used as benchmark
Correlation Lookback	50	Number of bars for Pearson correlation
Show Table	true	Toggle the on-chart info table
Show Correlation Line	true	Toggle the histogram columns
Table Position	top_right	Placement of the info table
Use Cases
Altcoin scalping — Know instantly whether your alt is following BTC or running on its own catalyst.
Decoupling detection — Gray zone = potential breakout candidate independent of BTC direction.
Hedging signals — Red zone (inverse) = altcoin moving opposite to BTC; useful for pairs or hedging.
Swing context — Avoid fading BTC trend on a highly-correlated alt; size down when correlation drops.
Credits
Built for the Short Club community. If you reuse or build upon this script, please credit @DemianNagoga.

## Source Code

````pine
//@version=6
indicator("BTC Correlation - short club", overlay=false)
// Copyright — Short Club / @DemianNagoga. При использовании просьба ссылаться на автора.
// 2026-07-10 · TradingView: https://www.tradingview.com/u/DemianNagoga/

//#region Inputs
btcSymbol = input.symbol("BINANCE:BTCUSDT.P", "BTC Symbol")
lookback = input.int(50, "Correlation Lookback", minval=1)
showTable = input.bool(true, "Show Table")
showCorrelationLine = input.bool(true, "Show Correlation Line")
tablePositionInput = input.string("top_right", "Table Position", options=["top_right", "top_left", "bottom_right", "bottom_left"])
//#endregion

//#region Data
btcClose = request.security(btcSymbol, timeframe.period, close)
assetRoc = ta.roc(close, 1)
btcRoc = ta.roc(btcClose, 1)
correlation = ta.correlation(assetRoc, btcRoc, lookback)
correlationPct = correlation * 100
//#endregion

//#region Visuals
greenCorr = showCorrelationLine and correlationPct > 70 ? correlationPct : na
yellowCorr = showCorrelationLine and correlationPct >= 30 and correlationPct <= 70 ? correlationPct : na
grayCorr = showCorrelationLine and correlationPct >= 0 and correlationPct < 30 ? correlationPct : na
redCorr = showCorrelationLine and correlationPct < 0 ? correlationPct : na

plot(greenCorr, title="🟢 > 70% — высокая", style=plot.style_columns, color=color.green, linewidth=2)
plot(yellowCorr, title="🟡 30-70% — умеренная", style=plot.style_columns, color=color.yellow, linewidth=2)
plot(grayCorr, title="⚪ 0-30% — декаплинг", style=plot.style_columns, color=color.gray, linewidth=2)
plot(redCorr, title="🔴 < 0% — инверсная", style=plot.style_columns, color=color.red, linewidth=2)
hline(0, "Zero", color=color.new(color.gray, 70))
//#endregion

//#region Table
var tablePosition = switch tablePositionInput
    "top_left" => position.top_left
    "bottom_right" => position.bottom_right
    "bottom_left" => position.bottom_left
    => position.top_right

var table infoTable = table.new(tablePosition, 2, 3, border_width=1)

visualRating = correlationPct < 0 ? "Inverse" : correlationPct > 70 ? "Strong" : correlationPct >= 30 ? "Moderate" : "Weak"

if barstate.islast and showTable
    infoTable.cell(0, 0, "Ticker", text_color=color.white, bgcolor=color.new(color.blue, 0))
    infoTable.cell(1, 0, syminfo.tickerid, text_color=color.white)

    infoTable.cell(0, 1, "BTC Corr.", text_color=color.white, bgcolor=color.new(color.blue, 0))
    infoTable.cell(1, 1, str.tostring(correlationPct, format.mintick) + "%", text_color=correlationPct < 0 ? color.red : correlationPct > 70 ? color.green : correlationPct >= 30 ? color.yellow : color.gray)

    infoTable.cell(0, 2, "Rating", text_color=color.white, bgcolor=color.new(color.blue, 0))
    infoTable.cell(1, 2, visualRating, text_color=correlationPct < 0 ? color.red : correlationPct > 70 ? color.green : correlationPct >= 30 ? color.yellow : color.gray)
//#endregion
````
