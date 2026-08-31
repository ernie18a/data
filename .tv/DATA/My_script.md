<!-- tradingview-pine-id: PUB;ea722a64478b4e8a93294cd678d2c52f -->
<!-- tradingviewscripts-format: 1 -->
# My script

Source: https://www.tradingview.com/script/KeJWF08v-Trend-Tide-Trigger/

## Description

Trend Tide & Trigger
Overview
The Trend Tide & Trigger is a comprehensive, all-in-one trading system designed for trend-following and price-action traders. By combining Multi-Timeframe (MTF) EMA alignments, Higher Timeframe Fair Value Gaps (FVG), and advanced dynamic candlestick patterns, this indicator acts as a highly precise sniper, filtering out market noise and pinpointing high-probability entry zones.

Whether you are a scalper, day trader, or swing trader, this script keeps you on the right side of the "Tide" (macro trend) while sniper-targeting the "Trend" (micro price action) for optimal execution.

🌟 Key Features

Multi-Timeframe Trend Alignment: Utilizes Fast, Medium, and Slow EMAs across both your current chart and a higher timeframe. It ensures you are only taking setups that align with the broader market direction.

Smart FVG Detection & Retest Zones: Automatically identifies and plots Bullish and Bearish Fair Value Gaps from a customizable higher timeframe.

Auto-Expiration & Limiters: To keep your chart clean, FVGs will only extend for a user-defined number of bars (Max Extend Bars) and are capped at a maximum count (Max Keep) to prevent clutter.

Touch Detection: Boxes dynamically change color the moment price taps into them, visually confirming the retest.

Advanced Dynamic Patterns & Engulfing: Goes beyond simple engulfing candles. The script scans for complex pullback structures, featuring:

EMA Filter: Ensures FVG setups only trigger if they respect the Fast EMA boundary.

Early Warning & Pre-Setup Alerts: Never miss a trade again. The script can alert you mid-bar as a dynamic pattern is forming, giving you crucial time to open your chart and prepare before the candle closes.

Trading Sessions & Time Filters: Visually highlights up to 3 major trading sessions (e.g., Asian, London, New York) with customizable GMT offsets. You can also restrict script alerts to only trigger during your specific trading hours.

Live Trend Dashboard: A sleek, non-intrusive on-chart table that provides a bird’s-eye view of the EMA trends across 4 different timeframes simultaneously.

Highly Optimized & No-Repaint Options: Features a Use Real-Time Price? toggle. Turn it off for strictly confirmed, no-repaint signals ideal for backtesting, or turn it on for aggressive, real-time scalping. The script is also heavily optimized under the hood to ensure lightning-fast loading times without exhausting system limits.

💡 How to Use (The Trigger Setup)

The Tide: Look at the Trend Dashboard to ensure Higher Timeframes are aligned (e.g., All UP). Pro Tip: A high-quality entry occurs when the EMA lines display a clear, steep slope, indicating strong and undeniable market momentum.

The Zone: Wait for the price to retrace and tap into a Higher Timeframe FVG box (the box will change color).

The Trigger: Wait for a "BUY" or "SELL" Dynamic Engulfing label to print, confirming the rejection.

Execute: Enter the trade strictly at the close of the engulfing candle. Place your Stop Loss (SL) at the extreme wick of the reversal pattern, and set a minimum Take Profit (TP) target of 1:2 Risk-to-Reward (2RR).

Please ensure you thoroughly backtest this system on your preferred assets and timeframes before trading live. The indicator is a powerful tool, but you should always manually verify the overall market context and your trade setup before executing any position.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AbhisitV

//@version=6
indicator("My script")
plot(close)
````
