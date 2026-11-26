# Risk On / Risk Off - Index EMA Slope

- url: https://www.tradingview.com/script/MPypFZJS-Risk-On-Risk-Off-Index-EMA-Slope/
- type: indicator
- pine_id: PUB;a55749f27ebb4323af135a723b5548bd
- version: 2.0

## Description

OVERVIEW
A market-regime filter. It shades the background of any chart green (Risk On) or red (Risk Off) based on the trend of a reference index, not the symbol you are viewing. Put it on an individual stock chart and you see the broad-market regime behind every bar. A status box in the upper-right corner shows the current state.

HOW IT WORKS
All calculations run on the reference index (default: Nasdaq Composite, NASDAQ:IXIC) on the calculation timeframe (default: Daily).

1. It computes the 10 EMA and 21 EMA of the index close.
2. For each EMA, it measures the one-bar change and divides it by the index's 14-period ATR. This makes the slope independent of index price level and volatility, so the same threshold means the same thing on any index.
3. It converts that normalized slope to an angle in degrees:
   angle = arctan(sensitivity x (EMA - EMA one bar ago) / ATR14)
4. The regime is RISK ON when BOTH EMAs are rising AND both angles meet their minimums. Otherwise it is RISK OFF.

With the defaults (sensitivity 5, 25-degree minimums), each EMA must rise by at least about 0.093 ATR per bar. The angle is a mathematical measure, not the angle you see on screen, so it does not change when you zoom or rescale the chart.

HOW TO USE IT
- Use it as a regime filter: press new long exposure while Risk On, and tighten up, reduce size or stand aside while Risk Off.
- Apply it to any stock, ETF or index chart. The shading always reflects the reference index.
- Change the reference index to match what you trade (for example, the S&P 500 for large caps or the Russell 2000 for small caps).

SETTINGS
- Reference index: the index that drives the regime (default NASDAQ:IXIC).
- Calculation timeframe: the timeframe the EMAs are computed on (default D). The chart timeframe must be at or below this timeframe; a higher chart timeframe shows an error instead of quietly sampling the signal.
- Require minimum angles: on (default) requires both EMAs to meet their minimum angles; off requires only that both EMAs are rising.
- 10 EMA minimum angle / 21 EMA minimum angle: the thresholds in degrees (default 25 each).
- Angle sensitivity: scales the ATR-normalized slope before it is converted to degrees (default 5). Higher = easier Risk On. Set it to 1 for the unscaled formula, where 25 degrees requires a rise of about 0.466 ATR per bar.
- Color chart background: turns the background shading on or off.
- RISK ON color / RISK OFF color: shading colors; use the opacity slider in each color picker to set how strong the shading is.

NOTES
- Historical bars use only index data that was available at the time (no lookahead). On the live bar, the state reflects the index bar still in progress and can change until that bar closes.
- The status box is gray until the index has enough history to calculate both EMAs and the ATR.
- The indicator does not use the chart symbol's price in any calculation.

This indicator describes the trend of an index. It is not a trade signal on its own and does not predict future prices. Use it alongside your own analysis and risk management.

## Source Code

````pine
//@version=6
indicator("Risk On / Risk Off - Three Index Stack v6", overlay = true, scale = scale.none)

nasdaqSymbol = input.symbol("NASDAQ:IXIC", "Nasdaq")
sp500Symbol = input.symbol("SP:SPX", "S&P 500")
smallCapsSymbol = input.symbol("AMEX:IWM", "Small caps")
nasdaqTicker = ticker.standard(nasdaqSymbol == "" ? "NASDAQ:IXIC" : nasdaqSymbol)
sp500Ticker = ticker.standard(sp500Symbol == "" ? "SP:SPX" : sp500Symbol)
smallCapsTicker = ticker.standard(smallCapsSymbol == "" ? "AMEX:IWM" : smallCapsSymbol)
signalTf = input.timeframe("D", "Calculation timeframe")
showBg = input.bool(true, "Color chart background", group = "Background")
riskOnColor = input.color(color.new(color.green, 90), "RISK ON color / opacity", group = "Background", tooltip = "Use the opacity slider inside this color picker. 100% = solid; 0% = invisible.")
cautionColor = input.color(color.new(color.yellow, 90), "CAUTION color / opacity", group = "Background", tooltip = "Use the opacity slider inside this color picker. 100% = solid; 0% = invisible.")
riskOffColor = input.color(color.new(color.red, 90), "RISK OFF color / opacity", group = "Background", tooltip = "Use the opacity slider inside this color picker. 100% = solid; 0% = invisible.")

if timeframe.in_seconds() > timeframe.in_seconds(signalTf)
    runtime.error("Use a chart timeframe at or below the calculation timeframe.")

indexState() =>
    ema10 = ta.ema(close, 10)
    ema21 = ta.ema(close, 21)
    ready = not na(ema10) and not na(ema21)
    stacked = close > ema10 and ema10 > ema21
    [stacked, ready]

[nasdaqStacked, nasdaqReady] = request.security(nasdaqTicker, signalTf, indexState(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = false)
[sp500Stacked, sp500Ready] = request.security(sp500Ticker, signalTf, indexState(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = false)
[smallCapsStacked, smallCapsReady] = request.security(smallCapsTicker, signalTf, indexState(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = false)

allReady = nasdaqReady and sp500Ready and smallCapsReady
allStacked = nasdaqStacked and sp500Stacked and smallCapsStacked
caution = nasdaqStacked and sp500Stacked and not smallCapsStacked
combinedLabel = not allReady ? "NOT READY" : allStacked ? "RISK ON" : caution ? "CAUTION" : "RISK OFF"
combinedColor = not allReady ? color.gray : allStacked ? color.green : caution ? color.yellow : color.red
combinedBg = color(na)
if allReady
    combinedBg := allStacked ? riskOnColor : caution ? cautionColor : riskOffColor
bgcolor(showBg ? combinedBg : color(na), title = "Three-index Risk On / Caution / Risk Off background", editable = false)

var table panel = table.new(position.top_right, 1, 1, border_width = 1)
if barstate.islast
    table.cell(panel, 0, 0, combinedLabel, text_color = color.white, bgcolor = combinedColor)
````
