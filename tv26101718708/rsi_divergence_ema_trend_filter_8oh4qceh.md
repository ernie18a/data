# RSI Divergence + EMA Trend Filter

- url: https://www.tradingview.com/script/8oH4qCeH-RSI-Divergence-EMA-Trend-Filter/
- type: strategy
- pine_id: PUB;4013650ae4b4404aaf4b13d7f8c884fd
- version: 1.0

## Description

[b]Description:[/b]
Divergence is one of the most discussed concepts in technical analysis and one of the most misapplied. The core idea is simple: when price makes a new high but the RSI makes a lower high, momentum is weakening even as price advances. That disconnect between price action and momentum is what divergence measures — and it often precedes reversals before price itself confirms the change in direction.
This strategy formalizes that concept into a rule-based, backtestable system with two components: RSI divergence detection and an EMA trend filter that determines which divergences to act on.

[b]What divergence actually measures[/b]
RSI measures the speed and magnitude of price changes. When price reaches a new swing high but RSI fails to reach a correspondingly higher reading, it means the buying pressure behind the new high was weaker than the buying pressure behind the previous high. The market got to a higher price but required less momentum to do it — which suggests the move is losing conviction. Bearish divergence (price higher, RSI lower) signals potential exhaustion in an uptrend. Bullish divergence (price lower, RSI higher) signals potential exhaustion in a downtrend.

Important: divergence is a momentum signal, not a reversal guarantee. Price can continue making new highs with weakening RSI for a significant period before actually reversing. This is why divergence signals work best when combined with a trend filter that identifies the broader market context.

[b]The EMA filter[/b]
The 200 EMA defines the dominant trend regime. Bearish divergence signals — where momentum is weakening on the upside — are only acted on when price is below the 200 EMA, meaning the broader trend is already bearish and divergence represents a potential resumption of that trend after a counter-trend bounce. Bullish divergence signals are only acted on when price is above the 200 EMA, where they represent potential continuations of the dominant uptrend after a pullback with improving momentum.

This filter deliberately reduces the total number of signals. Many valid divergences occur against the dominant trend and produce short-lived reversals that reverse again quickly. By requiring trend alignment, the strategy trades fewer setups but acts on the ones with a higher probability of following through.

[b]How divergence is detected[/b]
The strategy identifies swing highs and swing lows using a lookback period — the number of bars on each side of a pivot that must be lower (for a high) or higher (for a low) to qualify as a genuine swing point. When two consecutive swing highs show price making a higher high but RSI making a lower high, bearish divergence is flagged. When two consecutive swing lows show price making a lower low but RSI making a higher low, bullish divergence is flagged.
The lookback length is the most important input to tune. A shorter lookback detects more swing points and generates more signals, but many will be minor pivots in the context of noise. A longer lookback requires more significant swing points and generates fewer, higher-quality signals. On daily charts, a lookback of 5 works well. On lower timeframes, 3 to 4 is more appropriate.

[b]Exits[/b]
Positions exit at an ATR-based stop-loss and a fixed ATR-based take-profit. The stop is placed beyond the swing point that generated the divergence signal — for a bearish divergence, the stop sits above the swing high; for a bullish divergence, below the swing low. This is intentional: if price breaks through the very level that defined the divergence, the signal is invalidated regardless of what RSI was doing. The take-profit is set at 2x ATR to maintain a positive reward-to-risk ratio across the system.

[b]What to evaluate in backtesting[/b]
Look at the signal distribution across different market environments. Divergence strategies tend to perform differently in trending versus ranging markets — in strong trending environments, bearish divergences against the dominant trend will produce many false signals even with the EMA filter. Look at whether the EMA filter is doing real work by temporarily disabling it and comparing signal quality. Check average trade duration — divergence signals that take too long to play out often give back open profit before the take-profit level is reached.

This is not a high-frequency strategy. On daily charts with a 5-bar lookback, signals may appear only a few times per month on a given instrument. That frequency is appropriate — divergence setups require specific conditions to form and should not be forced.
Shared for educational purposes and discussion. This is not investment advice. Backtest on your own instruments and timeframes before drawing conclusions about expected performance.

## Source Code

````pine
//@version=6
strategy("RSI Divergence + EMA Trend Filter", overlay=true,
     default_qty_type=strategy.percent_of_equity, default_qty_value=10)

// ── INPUTS ─────────────────────────────────────────────
rsiLen  = input.int(14,   "RSI Length",         group="RSI")
rsiSrc  = input.source(close, "RSI Source",      group="RSI")
lbLen   = input.int(5,    "Pivot Lookback",      group="Divergence", minval=2)
emaLen  = input.int(200,  "EMA Length",          group="Trend Filter")
atrLen  = input.int(14,   "ATR Length",          group="Risk")
slMult  = input.float(1.5,"SL ATR Multiplier",   group="Risk", step=0.1)
tpMult  = input.float(3.0,"TP ATR Multiplier",   group="Risk", step=0.1)

// ── INDICATORS ──────────────────────────────────────────
rsiVal = ta.rsi(rsiSrc, rsiLen)
emaVal = ta.ema(close, emaLen)
atrVal = ta.atr(atrLen)

// ── PIVOT DETECTION ─────────────────────────────────────
pivotHigh = ta.pivothigh(high, lbLen, lbLen)
pivotLow  = ta.pivotlow(low,   lbLen, lbLen)

// ── RSI AT PIVOTS ───────────────────────────────────────
rsiAtHigh = ta.valuewhen(not na(pivotHigh), rsiVal, 0)
rsiAtLow  = ta.valuewhen(not na(pivotLow),  rsiVal, 0)

prevRsiHigh = ta.valuewhen(not na(pivotHigh), rsiVal, 1)
prevRsiLow  = ta.valuewhen(not na(pivotLow),  rsiVal, 1)

prevPivotHigh = ta.valuewhen(not na(pivotHigh), high, 1)
prevPivotLow  = ta.valuewhen(not na(pivotLow),  low,  1)

// ── DIVERGENCE DETECTION ────────────────────────────────
bearDiv = not na(pivotHigh) and high > prevPivotHigh and rsiAtHigh < prevRsiHigh
bullDiv = not na(pivotLow)  and low  < prevPivotLow  and rsiAtLow  > prevRsiLow

// ── TREND FILTER ────────────────────────────────────────
aboveEma = close > emaVal
belowEma = close < emaVal

// ── ENTRY CONDITIONS ────────────────────────────────────
longCond  = bullDiv and aboveEma and barstate.isconfirmed and strategy.position_size == 0
shortCond = bearDiv and belowEma and barstate.isconfirmed and strategy.position_size == 0

// ── EXECUTION ───────────────────────────────────────────
if longCond
    strategy.entry("Long",  strategy.long,
         alert_message="Bullish divergence — long entry on {{ticker}} @ {{close}}")
    strategy.exit("Long Exit",  "Long",
         stop=low[lbLen]  - atrVal * slMult,
         limit=close      + atrVal * tpMult)

if shortCond
    strategy.entry("Short", strategy.short,
         alert_message="Bearish divergence — short entry on {{ticker}} @ {{close}}")
    strategy.exit("Short Exit", "Short",
         stop=high[lbLen] + atrVal * slMult,
         limit=close      - atrVal * tpMult)

// ── VISUALS ─────────────────────────────────────────────
plot(emaVal, "EMA Trend Filter", color=color.new(color.blue, 50), linewidth=1)

plotshape(longCond,  location=location.belowbar, color=color.green,
     style=shape.triangleup,   size=size.small, text="Bull Div")
plotshape(shortCond, location=location.abovebar, color=color.red,
     style=shape.triangledown, size=size.small, text="Bear Div")

// RSI panel
rsiPlot = plot(rsiVal, "RSI", color=color.purple, display=display.pane)
hline(70, "Overbought", color=color.new(color.red,   50), linestyle=hline.style_dashed)
hline(30, "Oversold",   color=color.new(color.green, 50), linestyle=hline.style_dashed)
hline(50, "Midline",    color=color.new(color.gray,  70), linestyle=hline.style_dotted)
````
