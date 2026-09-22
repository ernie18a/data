<!-- tradingview-pine-id: PUB;cc2312ac4df240eaac62d9f059f98433 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Supertrend Volatility Line

Source: https://www.tradingview.com/script/EZrjRvpn-Supertrend-Volatility-Line/

## Description

Supertrend Volatility Line displays an ATR-based trend reference and a yellow pullback observation zone on the price chart. It is a visual indicator, not an automated strategy. Green identifies the bullish state, red identifies the bearish state, and the yellow band shows a volatility-scaled area next to the active line where users can observe a price retracement.

How it works
The calculation uses the chart's own timeframe and a fixed 14-bar Wilder ATR. ATR measures the size of price fluctuations, including gaps; it does not determine direction on its own. Initial upper and lower bands are placed three ATR units above and below each candle's high-low midpoint. The upper band carries forward until a lower candidate appears or the previous close has exceeded that band. The lower band carries forward until a higher candidate appears or the previous close has fallen below that band. In a bearish state, a close above the updated upper band changes the state to bullish. In a bullish state, a close below the updated lower band changes it to bearish. The initial state is bearish once ATR is available.

The yellow zone extends half an ATR toward price from the active line: above the green lower line in a bullish state, and below the red upper line in a bearish state. Both its position and width follow the displayed line and ATR. The 14-bar length, multiplier of 3, and zone width of 0.5 ATR are fixed in this version.

How to use it
Read the line color as trend context, then watch whether price returns to the yellow zone. In a bullish state, observe downward retracements toward the green line; in a bearish state, observe upward retracements toward the red line. A touch is an observation event, not a buy or sell instruction. The script does not evaluate volume confirmation, produce numbered entry or exit labels, place orders, or calculate trade results. The example uses standard five-minute Gold Futures candles; changing the symbol or timeframe changes the calculation.

Display timing
The displayed direction, line and zone update only when a candle closes. While a candle is open, they retain the last completed candle's values. No plots are shifted into earlier bars, and the script does not request future or higher-timeframe data. This close-confirmed display deliberately responds later than an intrabar-updating display.

Design contribution and limitations
The underlying Supertrend and ATR methods are established techniques, not new inventions. This implementation combines the trend reference with a one-sided, ATR-scaled pullback zone and holds both steady during an open candle, providing a consistent area for observing retracements. It does not claim a new Supertrend formula or a proven trading advantage. The line can lag reversals and repeatedly change direction in sideways markets. Price can cross the entire yellow zone without reversing. Fixed parameters may be unsuitable for some markets or timeframes, and results depend on the available price history and data feed. No win rate, profitability or predictive accuracy is claimed.

Author: Feng Qing Yang (suifeng789486).

---

## Source Code

````pine
//@version=6
indicator("Supertrend Volatility Line", shorttitle="ST Volatility", overlay=true)

// Author: Feng Qing Yang (TradingView: suifeng789486)
// ATR-based Supertrend with the original yellow touch zone.
// The active chart timeframe is used; use standard 5-minute candles
// to match the original indicator. No trade signals or execution.
int ATR_LEN = 14
float FACTOR = 3.0
color GREEN = color.rgb(13, 150, 111)
color RED = color.rgb(220, 72, 85)

// Wilder ATR and the same Supertrend recurrence as the research implementation.
float atr = ta.atr(ATR_LEN)
float basicUp = hl2 + FACTOR * atr
float basicDown = hl2 - FACTOR * atr
var float upper = na
var float lower = na
var int direction = 0
if not na(atr)
    if na(upper[1])
        upper := basicUp
        lower := basicDown
        direction := -1
    else
        upper := basicUp < upper[1] or close[1] > upper[1] ? basicUp : upper[1]
        lower := basicDown > lower[1] or close[1] < lower[1] ? basicDown : lower[1]
        direction := direction[1] < 0 ? (close > upper ? 1 : -1) : (close < lower ? -1 : 1)
float trend = direction == 1 ? lower : upper

// During a live candle, display the last completed candle's line.
// Update the displayed direction and level only when the candle closes.
int viewSide = barstate.isconfirmed ? direction : direction[1]
float viewTrend = barstate.isconfirmed ? trend : trend[1]
plot(viewSide == 1 ? viewTrend : na, "Bullish volatility line", color=GREEN, linewidth=2, style=plot.style_linebr, display=display.pane)
plot(viewSide == -1 ? viewTrend : na, "Bearish volatility line", color=RED, linewidth=2, style=plot.style_linebr, display=display.pane)

// Original touch zone: half an ATR on the price-facing side of the line.
float viewAtr = barstate.isconfirmed ? atr : atr[1]
color GOLD = color.rgb(221, 160, 37)
float zoneTop = viewSide == 1 ? viewTrend + 0.5 * viewAtr : viewTrend
float zoneBottom = viewSide == 1 ? viewTrend : viewTrend - 0.5 * viewAtr
pTop = plot(zoneTop, "Touch zone upper edge", color=color.new(GOLD, 75), style=plot.style_linebr, display=display.pane)
pBottom = plot(zoneBottom, "Touch zone lower edge", color=color.new(GOLD, 75), style=plot.style_linebr, display=display.pane)
fill(pTop, pBottom, color=color.new(GOLD, 87), title="Yellow touch zone")
````
