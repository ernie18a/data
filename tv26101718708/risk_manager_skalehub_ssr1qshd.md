# Risk Manager [SkaleHub]

- url: https://www.tradingview.com/script/sSr1QShD-Risk-Manager-SkaleHub/
- type: indicator
- pine_id: PUB;2a6eb15e365343c7ab294821b41f46f8
- version: 1.0

## Description

Overview
The ultimate capital preservation tool. This indicator calculates mathematically secure stop-loss placements based on real-time market volatility (ATR) and features a dynamic dashboard that tells you the exact position size to take to protect your account.

The Edge
Amateurs blow accounts by guessing their lot sizes and placing arbitrary stop-losses. This tool professionalizes your risk. By adjusting your position size relative to the asset's current volatility, it ensures that whether you are trading a quiet forex pair or a volatile crypto asset, your monetary risk remains an exact, controlled percentage of your capital.

Key Features:

Volatility-Based Stops: Automatically calculates stop-loss levels using the Average True Range (ATR), ensuring your stop is safely tucked behind the market's natural "noise" to prevent early liquidations.

Auto-Position Sizing: Input your account balance and risk tolerance (e.g., 1%), and the built-in dashboard instantly outputs the exact number of shares or units you should buy.

On-Chart Visual Guardrails: Optionally plots dynamic crosshair lines on the chart so you can visually see exactly where your mathematically optimized stop-loss should be placed before entering a trade.

How to Use

Apply the indicator and open the settings menu. Enter your total account balance and your strict risk percentage (1-2% is highly recommended).

When your Level 3 Momentum Trigger fires an entry signal, look at the Risk Manager dashboard in the corner of your screen.

Execute the trade using the exact "Position Size (Units)" displayed on the dashboard, and immediately set your hard stop-loss at the "Stop Distance" mapped out on the chart.

Author's Note
This is a premium, Invite-Only script. It is Level 4 of the SkaleHub Training System. To gain access, your TradingView username must be explicitly authorized through the SkaleHub Academy.

## Source Code

````pine
//@version=5
indicator("Risk Manager [SkaleHub]", overlay=true)

// =========================================================================
// 1. INPUT PARAMETERS
// =========================================================================
grp1 = "Account Details"
accBalance = input.float(10000, title="Account Balance ($)", group=grp1)
riskPct    = input.float(1.0, title="Risk Per Trade (%)", step=0.1, group=grp1)

grp2 = "Stop Loss (ATR) Logic"
atrLen  = input.int(14, title="ATR Length", group=grp2)
atrMult = input.float(1.5, title="ATR Multiplier", step=0.1, group=grp2)
showStops = input.bool(true, title="Show Dynamic Stop Lines on Chart", group=grp2)

grp3 = "Visuals"
posStr = input.string("Bottom Right", title="Dashboard Position", options=["Top Right", "Top Center", "Top Left", "Bottom Right", "Bottom Left"], group=grp3)
c_bg   = input.color(color.new(#131722, 10), title="Dashboard Background", group=grp3)
c_text = input.color(color.white, title="Text Color", group=grp3)
c_val  = input.color(#00bcd4, title="Value Color", group=grp3)
c_stop = input.color(color.new(#ff0000, 40), title="Stop Line Color", group=grp3)

// Convert position string to TradingView position variable
get_pos(p) =>
    p == "Top Right" ? position.top_right :
     p == "Top Center" ? position.top_center :
     p == "Top Left" ? position.top_left :
     p == "Bottom Right" ? position.bottom_right : position.bottom_left

// =========================================================================
// 2. MATH & LOGIC
// =========================================================================
// Calculate Volatility-Based Stop Loss Distance
atr = ta.atr(atrLen)
slDist = atr * atrMult

// Calculate Stop Levels based on the current close
longSL  = close - slDist
shortSL = close + slDist

// Calculate the exact dollar amount being risked
riskAmount = accBalance * (riskPct / 100)

// Calculate Position Size (Units/Shares)
// Prevent division by zero if ATR drops to absolute zero
posSize = slDist > 0 ? (riskAmount / slDist) : 0

// =========================================================================
// 3. VISUAL PLOTTING (Stop Lines)
// =========================================================================
plot(showStops ? longSL : na, title="Long Stop Level", color=c_stop, style=plot.style_cross, linewidth=1)
plot(showStops ? shortSL : na, title="Short Stop Level", color=c_stop, style=plot.style_cross, linewidth=1)

// =========================================================================
// 4. DASHBOARD RENDERING
// =========================================================================
var table tb = table.new(get_pos(posStr), 2, 3, bgcolor=c_bg, border_width=1, border_color=color.new(color.gray, 80))

if barstate.islast
    // Formatting numbers for clean display
    strRiskAmt = "$" + str.tostring(riskAmount, "#.##")
    strSlDist  = str.tostring(slDist, syminfo.mintick < 0.001 ? "#.####" : "#.##")
    strPosSize = str.tostring(posSize, "#.##")
    
    // Row 0: Total Capital at Risk
    table.cell(tb, 0, 0, "Risk Amount:", text_color=c_text, text_halign=text.align_left, text_size=size.small)
    table.cell(tb, 1, 0, strRiskAmt, text_color=color.red, text_halign=text.align_right, text_size=size.small)
    
    // Row 1: Stop Loss Distance
    table.cell(tb, 0, 1, "Stop Distance:", text_color=c_text, text_halign=text.align_left, text_size=size.small)
    table.cell(tb, 1, 1, strSlDist, text_color=c_val, text_halign=text.align_right, text_size=size.small)
    
    // Row 2: Suggested Position Size
    table.cell(tb, 0, 2, "Position Size (Units):", text_color=c_text, text_halign=text.align_left, text_size=size.normal)
    table.cell(tb, 1, 2, strPosSize, text_color=#00ff00, text_halign=text.align_right, text_size=size.normal)
````
