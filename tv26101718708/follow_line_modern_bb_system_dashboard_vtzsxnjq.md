# Follow Line Modern BB [System & Dashboard]

- url: https://www.tradingview.com/script/VtzsxNJQ-Follow-Line-Modern-BB-System-Dashboard/
- type: indicator
- pine_id: PUB;5e1f0d49095a409ab5577824633c59ec
- version: 1.0

## Description

About Follow Line Modern BB
Follow Line Modern BB is a comprehensive trend-following trading system designed to capture strong market trends while minimizing noise during consolidation. It combines a highly responsive Follow Line indicator with a customized Bollinger Bands (BB) Cloud and an ATR Volatility Filter to evaluate market conditions in real-time.

🛠️ Key Features
Dynamic Follow Line: Instantly switches between green (Bullish) and red (Bearish) to define the current trend direction accompanied by explicit BUY signals.

Modern BB Cloud: Visualizes market volatility and price location relative to outer bands, making it easy to spot breakouts or squeeze phases.

ATR Filter (Mode: ATR ON): Automatically filters out low-volatility environments, preventing traders from entering choppy markets.

All-in-One Dashboard: An elegant on-screen display summarizing Trend Status, BB Position, Current ATR, and the exact Follow Line Price Level for quick decision-making.

📈 Trading Rules
Go Long (Buy): Enter when the BUY label appears, the Follow Line turns green, and the Dashboard displays BULLISH.

Exit / Stop Loss: Use the dynamic green Follow Line as your trailing stop or invalidation level.[url=https://www.tradingview.com/x/rCVB9JCn/]https://www.tradingview.com/x/rCVB9JCn/[/url] [symbol="OANDA:XAUUSD"]OANDA:XAUUSD[/symbol]

## Source Code

````pine
//@version=5
indicator("Follow Line Modern BB", overlay=true, max_labels_count=100)

// ===== INPUT =====
bbLen = input.int(21, "BB Length", minval=1)
bbMult = input.float(1.5, "BB Multiplier", step=0.1)

atrLen = input.int(5, "ATR Length", minval=1)
useATR = input.bool(true, "Use ATR Filter")

showBB = input.bool(true, "Show Bollinger Bands")
showSignals = input.bool(true, "Show BUY/SELL")
showDashboard = input.bool(true, "Show Dashboard")

// ===== CORE =====
basis = ta.sma(close, bbLen)
dev = ta.stdev(close, bbLen) * bbMult
upperBB = basis + dev
lowerBB = basis - dev
atr = ta.atr(atrLen)

// ===== BB SIGNAL =====
bbSignal = close > upperBB ? 1 : close < lowerBB ? -1 : 0

// ===== FOLLOW LINE =====
var float followLine = na
prevLine = nz(followLine[1], close)

if bbSignal == 1
    newLine = useATR ? low - atr : low
    followLine := math.max(newLine, prevLine)
else if bbSignal == -1
    newLine = useATR ? high + atr : high
    followLine := math.min(newLine, prevLine)
else
    followLine := prevLine

// ===== TREND =====
var int trend = 0
trend := followLine > nz(followLine[1], followLine) ? 1 : followLine < nz(followLine[1], followLine) ? -1 : nz(trend[1], 0)

// ===== SIGNAL =====
buySignal = trend == 1 and nz(trend[1], 0) == -1
sellSignal = trend == -1 and nz(trend[1], 0) == 1

// ===== COLORS =====
bull = color.rgb(0, 220, 150)
bear = color.rgb(255, 70, 90)
neutral = color.gray
dark = color.rgb(18, 22, 30)

lineColor = trend == 1 ? bull : trend == -1 ? bear : neutral

// ===== PLOTS =====
plot(followLine, "Follow Line", color=lineColor, linewidth=4)

pUpper = plot(showBB ? upperBB : na, "Upper BB", color=color.new(color.gray, 75))
pLower = plot(showBB ? lowerBB : na, "Lower BB", color=color.new(color.gray, 75))
plot(showBB ? basis : na, "BB Basis", color=color.new(color.white, 80))

fill(pUpper, pLower, color=showBB ? color.new(lineColor, 92) : na)

barcolor(trend == 1 ? color.new(bull, 70) : trend == -1 ? color.new(bear, 70) : na)
bgcolor(trend == 1 ? color.new(bull, 94) : trend == -1 ? color.new(bear, 94) : na)

// ===== SIGNAL VISUAL =====
plotshape(showSignals and buySignal, title="BUY", location=location.belowbar, style=shape.labelup, color=bull, text="BUY", textcolor=color.white)
plotshape(showSignals and sellSignal, title="SELL", location=location.abovebar, style=shape.labeldown, color=bear, text="SELL", textcolor=color.white)

// ===== DASHBOARD =====
var table dash = table.new(position.top_right, 2, 6, border_width=1)

trendText = trend == 1 ? "BULLISH" : trend == -1 ? "BEARISH" : "NEUTRAL"
signalText = buySignal ? "BUY" : sellSignal ? "SELL" : "WAIT"
bbText = bbSignal == 1 ? "BREAK UP" : bbSignal == -1 ? "BREAK DOWN" : "INSIDE BB"

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "FOLLOW LINE BB", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 0, signalText, text_color=color.white, bgcolor=buySignal ? bull : sellSignal ? bear : neutral)

    table.cell(dash, 0, 1, "Trend", text_color=color.white, bgcolor=dark)
    table.cell(dash, 1, 1, trendText, text_color=color.white, bgcolor=lineColor)

    table.cell(dash, 0, 2, "BB Status", text_color=color.white, bgcolor=dark)
    table.cell(dash, 1, 2, bbText, text_color=color.white, bgcolor=bbSignal == 1 ? bull : bbSignal == -1 ? bear : neutral)

    table.cell(dash, 0, 3, "ATR", text_color=color.white, bgcolor=dark)
    table.cell(dash, 1, 3, str.tostring(atr, "#.00"), text_color=color.white, bgcolor=dark)

    table.cell(dash, 0, 4, "Follow Line", text_color=color.white, bgcolor=dark)
    table.cell(dash, 1, 4, str.tostring(followLine, "#.00"), text_color=color.white, bgcolor=lineColor)

    table.cell(dash, 0, 5, "Mode", text_color=color.white, bgcolor=dark)
    table.cell(dash, 1, 5, useATR ? "ATR ON" : "ATR OFF", text_color=color.white, bgcolor=useATR ? bull : neutral)

// ===== ALERT =====
alertcondition(buySignal, title="BUY Alert", message="Follow Line Modern BB: BUY")
alertcondition(sellSignal, title="SELL Alert", message="Follow Line Modern BB: SELL")
````
