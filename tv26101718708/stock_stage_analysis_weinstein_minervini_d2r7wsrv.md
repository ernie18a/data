# Stock Stage Analysis (Weinstein + Minervini)

- url: https://www.tradingview.com/script/D2R7WSRv-Stock-Stage-Analysis-Weinstein-Minervini/
- type: indicator
- pine_id: PUB;5d4c947fbd514b30925ec7f4c63d4c00
- version: 1.0

## Description

[b]Overview[/b]
This indicator combines Stan Weinstein's Stage Analysis with Mark Minervini's Trend Template to identify the best buying opportunities in stocks. It displays a color-coded bar at the bottom of your chart showing which stage the stock is currently in.
[b]Color Coding[/b]
The indicator displays a horizontal colored bar with gradient intensity based on trend strength:
Stage 1 - GRAY (Basing/Accumulation)
[list]
[*]Stock is consolidating after a decline
[*]150-day MA is flattening out
[*]Price oscillating around the 150-day MA
[*]Action: WATCH - Building a base, not yet ready to buy
[/list]
Stage 2 - GREEN (Advancing/Markup) ⭐
[list]
[*]Stock is in a confirmed uptrend
[*]Price above 150-day MA
[*]150-day MA sloping upward
[*]50-day MA above 150-day MA
[*][b]Action[/b]: BUY ZONE - This is where you want to buy
[*][b]Gradient[/b]: Light green = weak trend, Dark green = strong trend
[*]
[/list]
Stage 3 - YELLOW/ORANGE (Topping/Distribution)
[list]
[*]Stock momentum is weakening
[*]150-day MA flattening after an uptrend
[*]Price oscillating around 150-day MA
[*]Action: SELL - Institutional distribution happening
[/list]
Stage 4 - RED (Declining/Markdown)
[list]
[*]Stock is in a confirmed downtrend
[*]Price below 150-day MA
[*]150-day MA sloping downward
[*]Action: AVOID - Do not buy or hold
[*]Gradient: Light red = weak downtrend, Dark red = strong downtrend
[/list]
⬜ White Square Marker (Minervini Qualified)
When you see a small white square at the top of the Stage 2 bar, this indicates a high-quality buying opportunity that meets ALL of Mark Minervini's strict criteria:
✅ Stock is in Stage 2 (uptrend)
✅ Price > 50-day MA > 150-day MA > 200-day MA (perfect alignment)
✅ 200-day MA is trending upward
✅ Price within 25% of 52-week high
This is the ideal entry point - Stage 2 stocks that also pass Minervini's quality filter.

📈 How to Use in Your Trading
Step 1: Find Stage 2 Stocks
[list]
[*]Look for GREEN bars on the indicator
[*]These are stocks in confirmed uptrends
[/list]
Step 2: Look for White Squares
[list]
[*]The white square marker identifies the highest quality Stage 2 setups
[*]These stocks meet both Weinstein and Minervini criteria
[/list]
Step 3: Check the Gradient Intensity
Dark green = Strong momentum (safer entry)
Light green = Weaker momentum (wait for confirmation)
Step 4: Exit Signals
[list]
[*]When the bar turns YELLOW = Start reducing position
[*]When the bar turns RED = Exit completely
[/list]
⚙️ Installation
[list]
[*]Open TradingView
[*]Click Pine Editor at the bottom
[*]Click "+" to create new indicator
[*]Paste the script code
[*]Click "Save" and "Add to Chart"
[/list]
🧠 Methodology
[b]Weinstein Stage Theory[/b]
[list]
[*]Uses the 30-week (150-day) moving average to identify the four stages of stock price cycles. Stage 2 is the only stage where you should be buying.
[/list]
[b]Minervini Trend Template[/b]
[list]
[*]Applies stricter criteria within Stage 2 to filter for the highest-quality setups with proper moving average alignment and relative strength.
[*]Gradient Intensity
[*]Color intensity is calculated based on:
[/list]
[list=1]
[*]MA slope steepness (steeper = darker)
[*]Price distance from MA (further = darker)
[/list]
This helps you visually assess trend strength at a glance.
🎯 Trading Rules
BUY: Stage 2 (green) with white square marker
HOLD: Stage 2 (green) without marker (monitor closely)
SELL: Stage 3 (yellow/orange)
AVOID: Stage 1 (gray) and Stage 4 (red)
📝 Technical Parameters
50-day MA: Short-term trend
150-day MA: Primary stage identifier (Weinstein's 30-week)
200-day MA: Long-term trend filter
52-week high: Relative strength filter
MA slope threshold: ±0.5% over 20 bars
👨‍💻 Author
CANSLIM Research by hkpress
Based on:
Stan Weinstein's "Secrets for Profiting in Bull and Bear Markets"
Mark Minervini's "Trade Like a Stock Market Wizard"
⚠️ Disclaimer
This indicator is for educational purposes only. It does not constitute financial advice. Always do your own research and use proper risk management. Past performance does not guarantee future results.
📌 Quick Reference Card
Remember: Only buy Stage 2 stocks. The white square identifies the cream of the crop.

## Source Code

````pine
//@version=5
// CANSLIM Research by hkpress
// Stock Stage Analysis based on Stan Weinstein's Stage Theory + Mark Minervini's Trend Template
indicator("Stage Analysis", overlay=false)

// Moving Averages
ma50 = ta.sma(close, 50)
ma150 = ta.sma(close, 150)
ma200 = ta.sma(close, 200)

// MA Slope Calculations
ma150_slope = ta.change(ma150, 20) / ma150 * 100
ma200_slope = ta.change(ma200, 20) / ma200 * 100

// 52-Week High
high52week = ta.highest(high, 252)
pctFrom52WeekHigh = (high52week - close) / high52week * 100

// STAGE DETECTION
stage2 = close > ma150 and ma150_slope > 0.5 and ma50 > ma150
stage4 = close < ma150 and ma150_slope < -0.5

ma150Flat = math.abs(ma150_slope) <= 0.5
stage1 = ma150Flat and ma150 < ma150[20] and not stage2 and not stage4
stage3 = ma150Flat and ma150 > ma150[20] and not stage2 and not stage4

if not stage1 and not stage2 and not stage3 and not stage4
    if close > ma150
        stage2 := true
    else
        stage4 := true

// INTENSITY CALCULATION (0-100)
slopeIntensity = math.min(math.abs(ma150_slope) * 10, 100)
priceDistance = math.abs((close - ma150) / ma150 * 100)
distanceIntensity = math.min(priceDistance * 20, 100)
intensity = math.min((slopeIntensity + distanceIntensity) / 2, 100)

// GRADIENT COLORS
color1 = color.gray

// Stage 2: Light green -> Dark green
color2Light = color.rgb(144, 238, 144)
color2Dark = color.rgb(0, 100, 0)
color2 = color.from_gradient(intensity, 0, 100, color2Light, color2Dark)

// Stage 3: Light yellow -> Dark orange
color3Light = color.rgb(255, 255, 153)
color3Dark = color.rgb(255, 165, 0)
color3 = color.from_gradient(intensity, 0, 100, color3Light, color3Dark)

// Stage 4: Light red -> Dark red
color4Light = color.rgb(255, 182, 193)
color4Dark = color.rgb(139, 0, 0)
color4 = color.from_gradient(intensity, 0, 100, color4Light, color4Dark)

stageColor = stage1 ? color1 : stage2 ? color2 : stage3 ? color3 : color4

// MINERVINI CRITERIA
minerviniAlignment = close > ma50 and ma50 > ma150 and ma150 > ma200
ma200TrendingUp = ma200_slope > 0.1
priceStrength = pctFrom52WeekHigh < 25
minerviniQualified = stage2 and minerviniAlignment and ma200TrendingUp and priceStrength

// PLOT - Area style as default
plot(1, color=stageColor, style=plot.style_area, title="Stage Bar")

// Minervini marker - white square
plotshape(minerviniQualified, style=shape.square, location=location.top, color=color.white, size=size.tiny, title="Minervini")
````
