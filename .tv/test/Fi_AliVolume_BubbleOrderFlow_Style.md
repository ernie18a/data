<!-- tradingview-pine-id: PUB;cda9c3197f724ae98c5d6c16fe869207 -->
<!-- tradingviewscripts-format: 1 -->
# Fi Ali_Volume Bubble_OrderFlow Style

Source: https://www.tradingview.com/script/LCTfuKKW-Fi-Ali-Volume-Bubble/

## Description

Fi Ali Volume Bubble is a volume analysis indicator inspired by professional Order Flow and Wyckoff methodologies. It helps traders identify significant buying and selling activity using intuitive volume bubbles, making high-volume events easier to spot without relying on complex footprint charts.

Features
🟢 Buy Volume Bubble
🔴 Sell Volume Bubble
🟢 Large Bubble for Extreme Volume
🟡 Buy Absorption Detection
🟠 Sell Absorption Detection
📊 Automatic Volume Spike Detection based on moving average volume
👀 Clean, minimalist, and eye-friendly visualization
How It Works

The indicator compares current volume against the average market volume to detect unusual trading activity. It then estimates buying and selling pressure using candle structure and plots color-coded bubbles directly on the chart.

Large bubbles represent exceptionally high volume, while absorption bubbles highlight potential exhaustion or trapped traders—valuable clues often used in Wyckoff analysis.

Best Used For
FCPO Futures
Crude Palm Oil
Commodity Futures
Index Futures
Stocks
Forex
Cryptocurrency
Recommended Timeframes
1 Minute
3 Minutes
5 Minutes
15 Minutes
Suitable Trading Styles
Scalping
Intraday Trading
Swing Trading
Wyckoff Analysis
Smart Money Concept (SMC)
Disclaimer

This indicator provides a visual representation of abnormal volume activity and estimated order flow. It does not use true bid/ask footprint data and should be used together with price action, market structure, and proper risk management.

Developed by Fi Ali

---

## Source Code

````pine
//@version=6
indicator("Fi Ali_Volume Bubble_OrderFlow Style", overlay=true)

// ===== INPUT =====
vol_len      = input.int(20, "Volume Average Length")
spike_mult   = input.float(1.3, "Volume Spike Multiplier")
extreme_mult = input.float(2.5, "Extreme Volume Multiplier")

// ===== VOLUME CORE =====
avg_vol = ta.sma(volume, vol_len)
vol_spike = volume > avg_vol * spike_mult
extreme_vol = volume > avg_vol * extreme_mult

// ===== CANDLE DATA =====
bull = close > open
bear = close < open
candle_range = high - low
body = math.abs(close - open)
upper_wick = high - math.max(close, open)
lower_wick = math.min(close, open) - low

// ===== PSEUDO ORDERFLOW DELTA =====
buy_pressure  = bull ? volume : volume * 0.3
sell_pressure = bear ? volume : volume * 0.3
delta = buy_pressure - sell_pressure

is_buy  = vol_spike and delta > 0
is_sell = vol_spike and delta < 0

// ===== SUBTLE COLORS (EYE FRIENDLY) =====
subtle_green  = color.new(color.lime, 65)
subtle_red    = color.new(color.red, 65)
subtle_yellow = color.new(color.yellow, 70) // buy absorption (trap buyer)
subtle_orange = color.new(color.orange, 70) // sell absorption (trap seller)

// ===== AGGRESSIVE BUBBLES =====
// Buy bubbles BELOW candle
plotshape(
     is_buy and not extreme_vol,
     title="Buy Bubble",
     style=shape.circle,
     location=location.belowbar,
     color=subtle_green,
     size=size.small)

plotshape(
     extreme_vol and delta > 0,
     title="Strong Buy Bubble",
     style=shape.circle,
     location=location.belowbar,
     color=subtle_green,
     size=size.large)

// Sell bubbles ABOVE candle
plotshape(
     is_sell and not extreme_vol,
     title="Sell Bubble",
     style=shape.circle,
     location=location.abovebar,
     color=subtle_red,
     size=size.small)

plotshape(
     extreme_vol and delta < 0,
     title="Strong Sell Bubble",
     style=shape.circle,
     location=location.abovebar,
     color=subtle_red,
     size=size.large)

// ===== TRUE ABSORPTION LOGIC (FIXED PROFESSIONAL VERSION) =====
// Buy Absorption = Big volume + long upper wick (buyer trapped)
buy_absorption =
     vol_spike and
     upper_wick > body * 1.2 and
     delta > 0

// Sell Absorption = Big volume + long lower wick (seller trapped)
sell_absorption =
     vol_spike and
     lower_wick > body * 1.2 and
     delta < 0

// Plot absorption at correct locations
plotshape(
     buy_absorption,
     title="Buy Absorption (Bull Trap)",
     style=shape.circle,
     location=location.abovebar,
     color=subtle_yellow,
     size=size.small)

plotshape(
     sell_absorption,
     title="Sell Absorption (Bear Trap)",
     style=shape.circle,
     location=location.belowbar,
     color=subtle_orange,
     size=size.small)
````
