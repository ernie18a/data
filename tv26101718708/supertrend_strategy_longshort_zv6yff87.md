# SuperTrend Strategy [Long/Short]

- url: https://www.tradingview.com/script/ZV6yfF87/
- type: strategy
- pine_id: PUB;a87c55ddec7a4c5ba694754dc039eaad
- version: 1.0

## Description

SuperTrend Strategy [Long/Short]

A clean SuperTrend-based strategy with dynamic stop-loss, built on Pine Script v6.
Automatically flips between Long and Short on trend reversals, with SuperTrend acting as both entry trigger and trailing stop.

━━━━━━━━━━━━━━━━━━━━━━━
🔹 HOW IT WORKS
━━━━━━━━━━━━━━━━━━━━━━━
SuperTrend is calculated using ATR (Average True Range) and a multiplier factor.
When the trend direction flips, the strategy closes the current position and opens the opposite — a full reversal (flip) system.

- Bullish flip  → Closes Short, opens Long
- Bearish flip  → Closes Long, opens Short

━━━━━━━━━━━━━━━━━━━━━━━
🔹 STOP-LOSS LOGIC
━━━━━━━━━━━━━━━━━━━━━━━
The SuperTrend line acts as a dynamic stop-loss level.

- Long position  → SL applied when SuperTrend is below current price
- Short position → SL applied when SuperTrend is above current price

This keeps the stop adaptive to market volatility rather than fixed.

━━━━━━━━━━━━━━━━━━━━━━━
🔹 FEATURES
━━━━━━━━━━━━━━━━━━━━━━━
- Enable / Disable strategy execution independently
  → When disabled, the SuperTrend line and signals still display on the chart.

- Lot Size input
  → Set a fixed quantity per entry.

- Commission & Slippage
  → Defaults: 0.05% commission, 3 ticks slippage.
  → Edit directly in the script, or override via Strategy Properties tab.

- Visual BUY / SELL labels plotted directly on the chart.

━━━━━━━━━━━━━━━━━━━━━━━
🔹 ALERT CONDITIONS (2 total)
━━━━━━━━━━━━━━━━━━━━━━━
- 🟢 Buy Alert  — Bullish flip detected
- 🔴 Sell Alert — Bearish flip detected

Alerts include ticker and timeframe in the message: {{ticker}}, {{interval}}

━━━━━━━━━━━━━━━━━━━━━━━
🔹 SETTINGS
━━━━━━━━━━━━━━━━━━━━━━━
- ATR Length : 10 (default)
- Factor     : 3.0 (default)
- Lot Size   : 1.0 (default)

Increase the Factor to reduce signal frequency and filter noise.
Decrease it for more responsive signals on shorter timeframes.

━━━━━━━━━━━━━━━━━━━━━━━
⚠️ DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━━
This script is for educational and backtesting purposes only.
Past performance does not guarantee future results.
Always apply proper risk management before using any strategy in live markets.

## Source Code

````pine
//@version=6
strategy(title="SuperTrend Strategy [Long/Short]", shorttitle="ST [L/S]", overlay=true,
     scale=scale.right,
     default_qty_type=strategy.fixed,
     default_qty_value=1.0,
     calc_on_every_tick=true,
     commission_type=strategy.commission.percent,
     commission_value=0.05,
     slippage=3)

// ── SuperTrend Settings ───────────────────────────────────────────────────
atrPeriod  = input.int(10,  minval=1,    title="ATR Length", group="📊 SuperTrend")
multiplier = input.float(3.0, minval=0.01, step=0.01, title="Factor",     group="📊 SuperTrend")

// ── Strategy Settings ─────────────────────────────────────────────────────
useStrategy = input.bool(true,  title="Enable Strategy",              group="⚙️ Strategy")
lotSize     = input.float(1.0,  title="Lot Size", minval=0.01, step=0.01, group="⚙️ Strategy")

// ── SuperTrend Calculation ────────────────────────────────────────────────
[stLineRaw, stDir] = ta.supertrend(multiplier, atrPeriod)
stLine = barstate.isfirst ? na : stLineRaw

isBull = stDir < 0
isBear = stDir > 0

buySignal  = ta.change(stDir) != 0 and isBull
sellSignal = ta.change(stDir) != 0 and isBear

// ── Plots ─────────────────────────────────────────────────────────────────
plot(isBull ? stLine : na, title="Up Trend",   color=color.green, linewidth=2, style=plot.style_linebr)
plot(isBear ? stLine : na, title="Down Trend", color=color.red,   linewidth=2, style=plot.style_linebr)

// ── Entry / Exit ──────────────────────────────────────────────────────────
if useStrategy
    if buySignal
        strategy.close("Sell")
        strategy.entry("Buy", strategy.long, qty=lotSize)

    if sellSignal
        strategy.close("Buy")
        strategy.entry("Sell", strategy.short, qty=lotSize)

    // Long: apply SL only when SuperTrend is below current price
    if strategy.position_size > 0 and not na(stLine) and stLine < close
        strategy.exit("Buy SL", from_entry="Buy", stop=stLine, comment_loss="SL: SuperTrend")

    // Short: apply SL only when SuperTrend is above current price
    if strategy.position_size < 0 and not na(stLine) and stLine > close
        strategy.exit("Sell SL", from_entry="Sell", stop=stLine, comment_loss="SL: SuperTrend")

// ── Signal Shapes ─────────────────────────────────────────────────────────
plotshape(buySignal,  title="Buy Signal",  location=location.belowbar,
     style=shape.labelup,   color=color.green, textcolor=color.white, text="BUY",  size=size.normal)

plotshape(sellSignal, title="Sell Signal", location=location.abovebar,
     style=shape.labeldown, color=color.red,   textcolor=color.white, text="SELL", size=size.normal)

// ── Alert Conditions ──────────────────────────────────────────────────────
alertcondition(buySignal,  title="🟢 Buy Alert",  message="SuperTrend: Buy signal triggered ({{ticker}}, {{interval}})")
alertcondition(sellSignal, title="🔴 Sell Alert", message="SuperTrend: Sell signal triggered ({{ticker}}, {{interval}})")
````
