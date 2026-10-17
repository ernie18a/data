# Candle Close Percentage

- url: https://www.tradingview.com/script/5ysDvumg-Candle-Close-Percentage/
- type: indicator
- pine_id: PUB;166b4e2723334185ad80394fb16736b8
- version: 1.0

## Description

Description:

Volume tells you there is fuel, but the wick tells you who is actually driving.

Most breakout traders get destroyed by false momentum. A stock breaks a major resistance level on massive morning volume, retail rushes in to buy the breakout, and by the closing bell, the stock has faded into a massive shooting star. The institutions used the morning liquidity to dump their bags.

The Candle Close Percentage is a strict mathematical guardrail designed to prove absolute institutional control. It calculates the exact percentile of the daily close relative to the total high-low range of the candle (0 to 100).

⚙️ The Stealth HUD (How it Works)
Traders do not need more messy oscillators cluttering up their screen real estate. This indicator is built for strict "Stealth Mode." It runs directly on the main chart overlay but draws absolutely no lines. The exact mathematical percentage is pushed purely to your Status Line (top left of the chart) and the Data Window. Simply hover your mouse over any breakout candle to instantly read the wick physics to two decimal places.

🩸 The Operator's Playbook (The Thresholds)
This is not a standalone strategy; it is a structural validation tool for momentum breakouts and trend ignitions.

> 65% (The Ignition Sweet Spot): The stock closed in the top 35% of its daily range. Institutional buyers successfully held the floor against market-maker shakeouts and routine end-of-day profit-taking. The breakout is valid.

> 85% (Pristine Momentum): Absolute institutional domination. The candle closed near its absolute dead-high, proving zero overhead supply.

40% to 60% (The Chop Zone): The market is undecided. A spinning top candle. Proceed with caution.

< 40% (The Kill Zone): Institutional distribution. The stock printed a massive upper wick. No matter how high the volume was today, the sellers won the bell. Throw the ticket in the trash and walk away.

📐 The Math
((Close - Low) / (High - Low)) * 100
(Includes a built-in division-zero guard to prevent script crashes on flat-range or halted candles).

Stop guessing if a candle "looks" strong enough. Hover, check the math, and trade the structure.

## Source Code

````pine
//@version=6
indicator("Candle Close Percentage", shorttitle="Candle Close %", overlay=true)

// 1. Calculate the total vertical range of the candle
candleRange = high - low

// 2. Calculate the close percentage (with built-in protection against division by zero)
pctClose = candleRange != 0 ? ((close - low) / candleRange) * 100 : 0

// 3. Plot strictly to the status line (Stealth Mode)
// precision=2 outputs the exact decimal to two places (e.g., 65.42)
plot(pctClose, title="Close %", display=display.status_line + display.data_window, precision=2)
````
