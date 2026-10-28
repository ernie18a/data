# VXTLT / MOVE Volatility Ratio

- url: https://www.tradingview.com/script/lazIRZth-VXTLT-MOVE-Volatility-Ratio/
- type: indicator
- pine_id: PUB;663e985528ba4ed3afdb3a04b6c89819
- version: 1.0

## Description

• The Baseline: Because VXTLT usually trades as a standard percentage (e.g., 16.5) and the MOVE index trades in normalized basis points (e.g., 106.0), the ratio values sit as decimal fractions.
• The Trend:
	• When the blue line crosses above the orange moving average, long-end yield panic is growing faster than short-end Fed policy fears.
	• When the blue line drops below the orange moving average, short-duration rate confusion is the dominant force in the macro environment.


VXTLT (Long-End Volatility) has expanded significantly, currently sitting elevated around 17.91.The MOVE Index (Broad Yield Volatility) is also elevated, closing yesterday at 110.45. StreetStats +1How to Understand the VXTLT / MOVE Ratio GraphIf you plug the script into TradingView right now, you are plotting a decimal fraction (approx. \(17.91 \div 110.45 \approx \mathbf{0.162}\)), which tracks whether the long end or short end is driving the panic. Here is how to interpret the line's position against your 20 SMA (Moving Average) and the 0.15 Baseline: 1. If the Ratio Line is Spiking Up (Above the 20 SMA) What it means: Long-end bond risk is outpacing short-end interest rate risk.Current Context: This accurately describes the current landscape. Investors are not just worried about the next Federal Reserve meeting; they are demanding a massive premium to hold long-term U.S. debt due to secular inflation fears and exploding fiscal deficits. Reuters +12. If the Ratio Line is Crashing Down (Below the 20 SMA) What it means: Near-term interest rate confusion is the dominant force.What triggers it: This happens when the market goes into a frenzy over short-term Fed policy changes or immediate economic data dumps, while long-term assumptions remain anchored. 3. Gauging the Baseline (0.15) Above 0.15: Long bonds (TLT) are experiencing highly concentrated, equity-style positioning and liquidity shocks relative to standard institutional OTC bond markets.Below 0.15: Institutional yield hedging across the broad curve is much higher than individual retail/ETF option panic.

## Source Code

````pine
//@version=6
indicator("VXTLT / MOVE Volatility Ratio", overlay=false, precision=4)

// 1. Fetch data from both volatility indices
vxtlt = request.security("CBOE:VXTLT", "D", close)
move  = request.security("TVC:MOVE", "D", close)

// 2. Calculate the ratio (safeguard against division by zero)
vol_ratio = (move > 0) ? (vxtlt / move) : na

// 3. Optional: Add a Moving Average to smooth out noise
ma_length = input.int(20, title="MA Length")
ratio_ma  = ta.sma(vol_ratio, ma_length)

// 4. Plot the ratio and its moving average
plot(vol_ratio, title="VXTLT/MOVE Ratio", color=color.blue, linewidth=2)
plot(ratio_ma, title="Ratio 20 SMA", color=color.orange, linewidth=1, style=plot.style_line)

// 5. Add a neutral horizontal reference line based on historical baseline
hline(0.15, "Historical Baseline", color=color.gray, linestyle=hline.style_dashed)
````
