<!-- tradingview-pine-id: PUB;8fdc19e0f74746108a444735241a9341 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# MTF ATR Stop Loss Lines

Source: https://www.tradingview.com/script/FKRcDZrn/

## Description

MTF ATR Stop Loss Lines (v6) is a lightweight, high-utility technical analysis tool designed to streamline risk management and stop-loss placement. Instead of manually calculating Average True Range (ATR) distances across different intervals, this script automatically fetches volatility data from any higher timeframe and dynamically projects precise stop-loss levels directly onto your current chart.

By overlaying the calculated risk channels on both sides of the asset's current price, traders can instantly visualize their maximum risk exposure for both long and short market setups.

➡️ Key Features

Multi-Timeframe Engine: Pull volatility data from higher charts (e.g., Daily, 4-Hour) to protect your lower-timeframe execution from broader market noise.
Custom Risk Multiplier: Tailor your stop-loss buffer to match your specific risk tolerance or market asset volatility rules.
Visual Symmetry: Displays dual step-lines above and below the price action for instantaneous Long or Short trade planning.
Pine Script v6 Optimized: Engineered using the newest compiler version for maximum speed, strict type stability, and zero chart lag.

💡 How to Use

Long Positions: Utilize the Green (Lower) Line as your baseline invalidation level.
Short Positions: Utilize the Red (Upper) Line as your baseline invalidation level.
Pro-Tip: If you trade a volatile asset like Crypto or FX, increase the multiplier to 2.0 or 2.5 to avoid getting prematurely stopped out by sudden liquidity wicks.

---

## Source Code

````pine
//@version=6
indicator("MTF ATR Stop Loss Lines", overlay=true)

// Inputs
timeframeInput = input.timeframe("D", title="ATR Timeframe")
atrLength     = input.int(14, title="ATR Lookback Period")
atrMultiplier = input.float(1.5, title="ATR Multiplier")

// Fetch ATR from the selected timeframe
htfAtr = request.security(syminfo.tickerid, timeframeInput, ta.atr(atrLength))

// Calculate the final stop loss distance
atrDistance = htfAtr * atrMultiplier

// Project lines symmetrically on both sides of the current price
atrUpperSL = close + atrDistance
atrLowerSL = close - atrDistance

// Plot lines directly on the price chart
plot(atrUpperSL, title="Short Stop Loss (Upper)", color=color.new(color.red, 30), linewidth=2, style=plot.style_stepline)
plot(atrLowerSL, title="Long Stop Loss (Lower)", color=color.new(color.green, 30), linewidth=2, style=plot.style_stepline)
````
