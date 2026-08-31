<!-- tradingview-pine-id: PUB;cd74dcfa31db434f9af4cb39ed3f0ca2 -->
<!-- tradingviewscripts-format: 1 -->
# Caheeen Pulse v3.0

Source: https://www.tradingview.com/script/PA80QWVa/

## Description

Caheeen Pulse is a market-regime visualization tool designed to summarize trend structure, directional alignment and volatility-normalized price positioning in one compact view.

HOW IT WORKS

The indicator combines four independent observations into a composite regime score ranging from -4 to +4:

Price position relative to the long-term Trend EMA.
Alignment between the Fast EMA and Slow EMA.
Direction of the Trend EMA slope.
Price distance from the Trend EMA, normalized by ATR.

The combined score classifies the current market environment into five states:

• Strong Bull
• Bull
• Neutral
• Bear
• Strong Bear

This approach differs from a basic moving-average crossover. It evaluates several dimensions of market structure simultaneously and normalizes price displacement using volatility, allowing the same framework to adapt across instruments and timeframes.

VISUAL COMPONENTS

• Long-term Trend EMA
• Fast and Slow EMAs
• Regime-based chart background
• Confirmed regime-transition markers
• Dashboard displaying the composite score, ATR-normalized price distance, trend slope, EMA spread and ATR volatility

ALERTS

Caheeen Pulse includes alert conditions for confirmed transitions into Strong Bull, Strong Bear and Neutral regimes. Transition alerts and markers are confirmed only after the candle closes. When creating an alert, select “Once Per Bar Close.”

USAGE

Caheeen Pulse is intended to help users:

• Identify the prevailing market regime
• Distinguish directional conditions from transitional periods
• Compare trend structure with current volatility
• Apply an additional market-context filter to their own analysis

The indicator does not place orders, manage positions or provide personalized investment advice. It should not be used as a standalone instruction to buy or sell.

The live regime display can change while the current candle is forming. Confirmed transition markers and alerts are generated at candle close.

Historical or hypothetical observations do not guarantee future results. Trading involves risk, and users remain responsible for their own decisions and risk management.

---

## Source Code

````pine
//@version=6
// Caheeen Pulse v3.0
// A market-regime visualization tool. It does not place or manage trades.

indicator("Caheeen Pulse v3.0", shorttitle="Caheeen Pulse", overlay=true)

// ─────────────────────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────────────────────
trendLen       = input.int(200, "Trend EMA Length", minval=2, group="Regime Engine")
fastLen        = input.int(9, "Fast EMA Length", minval=1, group="Regime Engine")
slowLen        = input.int(21, "Slow EMA Length", minval=2, group="Regime Engine")
slopeLookback  = input.int(5, "Trend Slope Lookback", minval=1, group="Regime Engine")
atrLen         = input.int(14, "ATR Length", minval=1, group="Regime Engine")
neutralAtrBand = input.float(0.25, "Neutral Band (ATR)", minval=0.0, step=0.05, group="Regime Engine", tooltip="Price must move beyond this ATR-normalized distance from the Trend EMA to add a distance vote to the regime score.")

showTrendEMA   = input.bool(true, "Show Trend EMA", group="Display")
showFastSlow   = input.bool(true, "Show Fast/Slow EMAs", group="Display")
showBackground = input.bool(true, "Color Regime Background", group="Display")
showDashboard  = input.bool(true, "Show Regime Dashboard", group="Display")
showTransitions = input.bool(true, "Show Confirmed Regime Transitions", group="Display")

// ─────────────────────────────────────────────────────────────────────────────
// Regime engine
// Four independent votes are combined into a score from -4 to +4:
// price location, EMA alignment, Trend EMA slope and ATR-normalized distance.
// ─────────────────────────────────────────────────────────────────────────────
trendEMA = ta.ema(close, trendLen)
fastEMA  = ta.ema(close, fastLen)
slowEMA  = ta.ema(close, slowLen)
atrValue = ta.atr(atrLen)

trendSlope     = trendEMA - trendEMA[slopeLookback]
distanceInAtr  = atrValue > 0 ? (close - trendEMA) / atrValue : 0.0
slopeInAtr     = atrValue > 0 ? trendSlope / atrValue : 0.0
emaSpreadPct   = close != 0 ? (fastEMA - slowEMA) / close * 100.0 : 0.0
atrPct         = close != 0 ? atrValue / close * 100.0 : 0.0

int regimeScore = 0
regimeScore += close > trendEMA ? 1 : close < trendEMA ? -1 : 0
regimeScore += fastEMA > slowEMA ? 1 : fastEMA < slowEMA ? -1 : 0
regimeScore += trendSlope > 0 ? 1 : trendSlope < 0 ? -1 : 0
regimeScore += distanceInAtr > neutralAtrBand ? 1 : distanceInAtr < -neutralAtrBand ? -1 : 0

strongBull = regimeScore >= 3
bull       = regimeScore >= 1 and regimeScore < 3
neutral    = regimeScore == 0
bear       = regimeScore <= -1 and regimeScore > -3
strongBear = regimeScore <= -3

regimeText = strongBull ? "STRONG BULL" : bull ? "BULL" : strongBear ? "STRONG BEAR" : bear ? "BEAR" : "NEUTRAL"
regimeColor = strongBull ? color.rgb(0, 170, 105) : bull ? color.rgb(75, 175, 120) : strongBear ? color.rgb(215, 55, 75) : bear ? color.rgb(205, 120, 95) : color.rgb(130, 130, 145)

// Transitions are confirmed only after the candle closes.
previousScore = nz(regimeScore[1], 0)
strongBullTransition = barstate.isconfirmed and strongBull and previousScore < 3
strongBearTransition = barstate.isconfirmed and strongBear and previousScore > -3
neutralTransition    = barstate.isconfirmed and neutral and previousScore != 0

// ─────────────────────────────────────────────────────────────────────────────
// Visuals
// ─────────────────────────────────────────────────────────────────────────────
plot(showTrendEMA ? trendEMA : na, "Trend EMA", color=color.orange, linewidth=2)
plot(showFastSlow ? fastEMA : na, "Fast EMA", color=color.aqua)
plot(showFastSlow ? slowEMA : na, "Slow EMA", color=color.purple)

backgroundColor = strongBull ? color.new(color.green, 88) : bull ? color.new(color.green, 94) : strongBear ? color.new(color.red, 88) : bear ? color.new(color.red, 94) : color.new(color.gray, 96)
bgcolor(showBackground ? backgroundColor : na, title="Regime Background")

plotshape(showTransitions and strongBullTransition, title="Strong Bull Transition", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.tiny, text="BULL")
plotshape(showTransitions and strongBearTransition, title="Strong Bear Transition", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.tiny, text="BEAR")
plotshape(showTransitions and neutralTransition, title="Neutral Transition", style=shape.circle, location=location.abovebar, color=color.gray, size=size.tiny)

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard
// ─────────────────────────────────────────────────────────────────────────────
var table dashboard = table.new(position.top_right, 2, 6, border_width=1)

if barstate.islast
    if showDashboard
        table.cell(dashboard, 0, 0, "CAHEEEN PULSE", text_color=color.white, bgcolor=color.rgb(35, 38, 48))
        table.cell(dashboard, 1, 0, regimeText, text_color=color.white, bgcolor=regimeColor)
        table.cell(dashboard, 0, 1, "Composite Score", text_color=color.white, bgcolor=color.rgb(55, 58, 68))
        table.cell(dashboard, 1, 1, str.tostring(regimeScore) + " / 4", text_color=color.white, bgcolor=color.rgb(70, 73, 83))
        table.cell(dashboard, 0, 2, "Price / Trend EMA", text_color=color.white, bgcolor=color.rgb(55, 58, 68))
        table.cell(dashboard, 1, 2, str.tostring(distanceInAtr, "#.##") + " ATR", text_color=color.white, bgcolor=color.rgb(70, 73, 83))
        table.cell(dashboard, 0, 3, "Trend Slope", text_color=color.white, bgcolor=color.rgb(55, 58, 68))
        table.cell(dashboard, 1, 3, str.tostring(slopeInAtr, "#.###") + " ATR", text_color=color.white, bgcolor=color.rgb(70, 73, 83))
        table.cell(dashboard, 0, 4, "Fast/Slow Spread", text_color=color.white, bgcolor=color.rgb(55, 58, 68))
        table.cell(dashboard, 1, 4, str.tostring(emaSpreadPct, "#.##") + "%", text_color=color.white, bgcolor=color.rgb(70, 73, 83))
        table.cell(dashboard, 0, 5, "ATR Volatility", text_color=color.white, bgcolor=color.rgb(55, 58, 68))
        table.cell(dashboard, 1, 5, str.tostring(atrPct, "#.##") + "%", text_color=color.white, bgcolor=color.rgb(70, 73, 83))
    else
        table.clear(dashboard, 0, 0, 1, 5)

// ─────────────────────────────────────────────────────────────────────────────
// Alerts
// Configure TradingView alerts as "Once Per Bar Close".
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(strongBullTransition, "Caheeen Pulse: Strong Bull Regime", "Caheeen Pulse: Strong Bull regime confirmed on {{ticker}} ({{interval}}).")
alertcondition(strongBearTransition, "Caheeen Pulse: Strong Bear Regime", "Caheeen Pulse: Strong Bear regime confirmed on {{ticker}} ({{interval}}).")
alertcondition(neutralTransition, "Caheeen Pulse: Neutral Regime", "Caheeen Pulse: Neutral regime confirmed on {{ticker}} ({{interval}}).")
````
