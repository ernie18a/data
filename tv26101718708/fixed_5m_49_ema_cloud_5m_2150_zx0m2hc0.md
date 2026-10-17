# Fixed 5m 4/9 EMA Cloud + 5m 21/50

- url: https://www.tradingview.com/script/zX0M2Hc0-Fixed-5m-4-9-EMA-Cloud-5m-21-50/
- type: indicator
- pine_id: PUB;33b3e7bab99e4c298c635558df1e411a
- version: 1.0

## Description

This updated indicator is a **Fixed Multi-Timeframe Momentum and Trend System**. It is designed specifically for day traders who execute on lower timeframes (like the 1-minute or tick charts) but want to stay strictly aligned with the 5-minute trend without having to constantly switch charts.

Because every moving average in this script is hard-locked to the 5-minute data, you get a pure, top-down view of price action regardless of what chart you are looking at.

Here is the breakdown of its two main components:
1. The 5-Minute Momentum Cloud (4 & 9 EMA)

This is your fast-moving trigger engine. It visually paints the short-term momentum of the 5-minute chart over your price action.

* **Green Cloud:** The 5m 4 EMA is above the 5m 9 EMA. This signals strong, active bullish momentum.
* **Red Cloud:** The 5m 4 EMA is below the 5m 9 EMA. This signals strong, active bearish momentum.
* **Yellow Cloud (The Warning):** The current candle has closed inside the space between the 4 and 9 EMAs. This signifies consolidation, slowing momentum, or an impending reversal. It is an excellent visual cue to tighten stop-losses or avoid entering new breakout trades until the cloud turns solid red or green again.

2. The 5-Minute Trend Filter (21 & 50 EMA)

These represent your structural intraday support and resistance. Because they are now also locked to the 5-minute timeframe, they act as the "anchor" for your trades.

* **The 21 EMA:** Acts as a standard pullback target in a healthy, fast-moving trend.
* **The 50 EMA:** Acts as your intraday baseline or "line in the sand."
* **Customization:** You can toggle these lines on and off, change their thickness, and alter their colors directly in the indicator settings to keep your screen as clean as you need it to be.

### How to Trade with This Setup

This indicator is built for **trend continuation** and **pullback trading** on fast instruments like Nasdaq futures.

1. **Determine the Bias:** Look at the 5m 50 EMA. If price is above it, you are only looking for longs. If price is below it, you are only looking for shorts.
2. **Wait for the Setup:** Wait for price to pull back toward the 5m 21 EMA or 50 EMA. During this pullback, your momentum cloud will often flash yellow or temporarily flip against the trend.
3. **Execute on the Lower Timeframe:** Drop to a 1-minute chart. Because the indicator is locked to the 5-minute data, wait for your 1-minute candles to break structure in the direction of the 5m 50 EMA, and enter when the 4/9 Cloud flips back to Green (for longs) or Red (for shorts).

## Source Code

````pine
//@version=6
indicator("Fixed 5m 4/9 EMA Cloud + 5m 21/50", overlay=true)

// --- Inputs for 21 and 50 EMA ---
grp_emas = "21 & 50 EMA Settings (5m Fixed)"
show_21 = input.bool(true, title="Show 21 EMA", group=grp_emas)
color_21 = input.color(color.orange, title="21 EMA Color", group=grp_emas)
width_21 = input.int(2, title="21 EMA Line Width", minval=1, maxval=4, group=grp_emas)

show_50 = input.bool(true, title="Show 50 EMA", group=grp_emas)
color_50 = input.color(color.white, title="50 EMA Color", group=grp_emas)
width_50 = input.int(2, title="50 EMA Line Width", minval=1, maxval=4, group=grp_emas)

// --- 4 & 9 EMA (Fixed 5-minute timeframe) ---
ema4_5m = request.security(syminfo.tickerid, "5", ta.ema(close, 4))
ema9_5m = request.security(syminfo.tickerid, "5", ta.ema(close, 9))

p1 = plot(ema4_5m, title="4 EMA (5m)", color=color.new(color.blue, 0), linewidth=1)
p2 = plot(ema9_5m, title="9 EMA (5m)", color=color.new(color.purple, 0), linewidth=1)

// Determine if the current candle closes between the two 5m EMAs
high_ema = math.max(ema4_5m, ema9_5m)
low_ema = math.min(ema4_5m, ema9_5m)
closed_between = close <= high_ema and close >= low_ema

// Determine the fill color based on the rules
cloud_color = closed_between ? color.new(color.yellow, 50) : 
              (ema4_5m > ema9_5m ? color.new(color.green, 80) : color.new(color.red, 80))

// Fill the space between the EMAs
fill(p1, p2, color=cloud_color, title="EMA Cloud")

// --- 21 & 50 EMA (Fixed 5-minute timeframe) ---
ema21_5m = request.security(syminfo.tickerid, "5", ta.ema(close, 21))
ema50_5m = request.security(syminfo.tickerid, "5", ta.ema(close, 50))

plot(show_21 ? ema21_5m : na, title="21 EMA (5m)", color=color_21, linewidth=width_21)
plot(show_50 ? ema50_5m : na, title="50 EMA (5m)", color=color_50, linewidth=width_50)
````
