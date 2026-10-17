# Safe Size [SkaleHub]

- url: https://www.tradingview.com/script/PzMAnuss-Safe-Size-SkaleHub/
- type: indicator
- pine_id: PUB;0f07aaaabf3a4d2ea6cfe7b2f13a2e35
- version: 1.0

## Description

You can have the best entries in the world, but poor risk management will blow up an account. The Safe Size [SkaleHub] indicator is the final, ultimate safeguard in the SkaleHub progression system. It acts as an on-chart risk manager that calculates mathematically secure stop-loss placements based on real-time market volatility (ATR). Instead of forcing you to manually calculate pip values or guess where your stop should go, this tool tells you exactly where to put your stop-loss and calculates exactly how much capital to risk.


The Pitch: "Never blow up your account. Type in your account balance, and this tool tells you exactly how many shares to buy and where to put your stop-loss so you only risk 1%."

## Source Code

````pine
//@version=5
indicator("Safe Size [SkaleHub]", overlay=true, precision=2)

// =========================================================================
// 1. USER INPUTS (The Anti-Overwhelm Settings)
// =========================================================================
grp1 = "Account Parameters"
acctBalance = input.float(10000, title="Account Balance ($)", group=grp1, tooltip="Enter your total trading capital.")
riskPct = input.float(1.0, title="Risk Percentage (%)", step=0.1, group=grp1, tooltip="The maximum percentage of your account you are willing to lose on one trade.")

grp2 = "Risk Engine (Volatility)"
atrLen = input.int(14, title="ATR Length", group=grp2, tooltip="Lookback period for measuring market volatility.")
atrMult = input.float(1.5, title="ATR Multiplier", step=0.1, group=grp2, tooltip="How wide the stop loss buffer should be based on volatility.")

// =========================================================================
// 2. $100k PREMIUM COLOR PALETTE
// =========================================================================
colorCyan = color.new(#00E5FF, 0)      // Long / Bullish
colorMagenta = color.new(#D500F9, 0)   // Short / Bearish
colorBg = color.new(#131722, 10)       // Clean Dark Mode UI Background
colorText = color.white

// =========================================================================
// 3. THE RISK ENGINE MATH
// =========================================================================
// Calculate current market volatility
atr = ta.atr(atrLen)
stopDist = atr * atrMult

// Calculate exact Stop Loss levels based on current price
longStop = close - stopDist
shortStop = close + stopDist

// Calculate actual dollar amount risked
riskAmount = acctBalance * (riskPct / 100)

// Calculate exact position sizing (Shares/Contracts)
longSize = stopDist > 0 ? riskAmount / stopDist : 0
shortSize = stopDist > 0 ? riskAmount / stopDist : 0

// =========================================================================
// 4. VISUALS: CHART OVERLAYS
// =========================================================================
// Plot dynamic stop loss tracking dots so the user knows exactly where to place their stop
plot(longStop, title="Long Stop Setup", color=color.new(colorCyan, 50), style=plot.style_circles, linewidth=1)
plot(shortStop, title="Short Stop Setup", color=color.new(colorMagenta, 50), style=plot.style_circles, linewidth=1)

// =========================================================================
// 5. THE CLEAN UI DASHBOARD
// =========================================================================
var table riskPanel = table.new(position.bottom_right, 2, 4, bgcolor=colorBg, border_color=color.gray, border_width=1, frame_color=color.gray, frame_width=1)

if barstate.islast
    // Row 0: Total Capital Risked
    table.cell(riskPanel, 0, 0, "Max Risk (" + str.tostring(riskPct) + "%)", text_color=colorText, text_halign=text.align_left)
    table.cell(riskPanel, 1, 0, "$" + str.tostring(riskAmount, "#.##"), text_color=colorText, text_halign=text.align_right)

    // Row 1: Current Stop Distance (Points/Pips)
    table.cell(riskPanel, 0, 1, "Stop Distance", text_color=colorText, text_halign=text.align_left)
    table.cell(riskPanel, 1, 1, str.tostring(stopDist, "#.##"), text_color=colorText, text_halign=text.align_right)

    // Row 2: Long Position Size
    table.cell(riskPanel, 0, 2, "Long Size", text_color=colorCyan, text_halign=text.align_left)
    table.cell(riskPanel, 1, 2, str.tostring(longSize, "#.##") + " Shares", text_color=colorCyan, text_halign=text.align_right)

    // Row 3: Short Position Size
    table.cell(riskPanel, 0, 3, "Short Size", text_color=colorMagenta, text_halign=text.align_left)
    table.cell(riskPanel, 1, 3, str.tostring(shortSize, "#.##") + " Shares", text_color=colorMagenta, text_halign=text.align_right)
````
