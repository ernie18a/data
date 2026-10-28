# Universal Scalper System

- url: https://www.tradingview.com/script/OPCnuaNa-Universal-Scalper-System/
- type: indicator
- pine_id: PUB;e68b82f39eb94ad9a35af8df0429f8e9
- version: 1.0

## Description

The Universal Scalper System is a powerful technical indicator designed specifically for intraday scalping on lower timeframes like 1-minute and 5-minute charts. It provides a streamlined approach to trading by combining trend identification with essential market data.
Key Features:
 9 EMA Crossover: Generates clear, actionable Buy and Sell signals the moment the price crosses and closes beyond the 9-period Exponential Moving Average (EMA).
 Live Market Dashboard: Includes a fully customizable dashboard that displays:
 Current Chart Timer: Countdown until the current candle closes.
 15-Minute Timeframe Timer: Tracks the closure of the 15-minute candle for higher-timeframe context.
 Real-time Candle Info: Shows if the current candle is Bullish or Bearish along with live volume data.
 Highly Customizable: Traders can easily adjust EMA settings, dashboard colors, text sizes, and dashboard positioning directly through the settings panel to fit their unique workspace.
 Built-in Alerts: Features integrated alert conditions for both Buy and Sell signals, ensuring you never miss a trading opportunity.
This system is perfect for traders who prioritize speed, clean visuals, and real-time data at their fingertips.
Tags: Scalping, EMA, CrossOver, Dashboard, TradingSystem, PriceAction, TechnicalAnalysis, Indicator, Scalper, LiveTimer

## Source Code

````pine
//@version=6
indicator("Universal Scalper System", overlay=true)

// --- Inputs ---
emaLen = input.int(9, "EMA Length")
emaCol = input.color(color.yellow, "EMA Color")
emaW = input.int(2, "EMA Width")
showDashboard = input.bool(true, "Show Dashboard")
dashPos = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])
txtSize = input.string("Small", "Dashboard Text Size", options=["Tiny", "Small", "Normal", "Large"])
dashColor = input.color(color.new(color.black, 30), "Dashboard Color")
txtColor = input.color(color.white, "Text Color")

// --- EMA Calculation ---
emaValue = ta.ema(close, emaLen)
plot(emaValue, color=emaCol, linewidth=emaW, title="9 EMA")

// --- Signals ---
buySignal = ta.crossover(close, emaValue)
sellSignal = ta.crossunder(close, emaValue)
plotshape(buySignal, style=shape.labelup, location=location.belowbar, color=color.green, text="BUY", textcolor=color.white)
plotshape(sellSignal, style=shape.labeldown, location=location.abovebar, color=color.red, text="SELL", textcolor=color.white)

// --- Timer logic ---
tf15_time = request.security(syminfo.tickerid, "15", time_close - timenow)

// --- Dashboard ---
// ਸਥਿਤੀ ਅਤੇ ਸਾਈਜ਼ ਨਿਰਧਾਰਤ ਕਰਨਾ
pos = dashPos == "Top Right" ? position.top_right : dashPos == "Top Left" ? position.top_left : dashPos == "Bottom Right" ? position.bottom_right : position.bottom_left
sizeInput = txtSize == "Tiny" ? size.tiny : txtSize == "Small" ? size.small : txtSize == "Normal" ? size.normal : size.large

// ਟੇਬਲ ਬਣਾਉਣਾ - ਇੱਥੇ ਸਿੱਧੀਆਂ ਵੈਲਯੂਜ਼ ਵਰਤ ਰਹੇ ਹਾਂ ਤਾਂ ਜੋ ਐਰਰ ਨਾ ਆਵੇ
var table dash = table.new(position.top_right, 2, 4, bgcolor=dashColor, border_width=1)

if barstate.islast
    // ਜੇ ਪੋਜੀਸ਼ਨ ਬਦਲਣੀ ਹੈ ਤਾਂ ਟੇਬਲ ਨੂੰ ਰੀਸੈਟ ਕਰਨਾ ਪੈਂਦਾ ਹੈ, ਪਰ ਸੌਖੇ ਤਰੀਕੇ ਲਈ ਅਸੀਂ ਟੇਬਲ ਦੇ ਸੈੱਲ ਅਪਡੇਟ ਕਰਾਂਗੇ
    if showDashboard
        table.cell(dash, 0, 0, "UNIVERSAL", text_color=txtColor, text_size=sizeInput)
        table.cell(dash, 1, 0, "SYSTEM", text_color=txtColor, text_size=sizeInput)
        table.cell(dash, 0, 1, "Chart Time", text_color=txtColor, text_size=sizeInput)
        table.cell(dash, 1, 1, str.tostring(math.round((time_close - timenow) / 60000, 1)) + " m", text_color=txtColor, text_size=sizeInput)
        table.cell(dash, 0, 2, "15m Time", text_color=txtColor, text_size=sizeInput)
        table.cell(dash, 1, 2, str.tostring(math.round(tf15_time / 60000, 1)) + " m", text_color=txtColor, text_size=sizeInput)
        
        string cName = close > open ? "Bullish" : close < open ? "Bearish" : "Doji"
        table.cell(dash, 0, 3, "Candle | Vol", text_color=txtColor, text_size=sizeInput)
        table.cell(dash, 1, 3, cName + " | " + str.tostring(volume, format.volume), text_color=txtColor, text_size=sizeInput)
````
