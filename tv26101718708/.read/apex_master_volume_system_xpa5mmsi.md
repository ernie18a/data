# APEX Master Volume System

- url: https://www.tradingview.com/script/XpA5mMSi-APEX-Master-Volume-System/
- type: indicator
- pine_id: PUB;5ffd78af63da4c18910d4bb2255b4ca5
- version: 1.0

## Description

full APEX layout.
You now have a complete professional trading workstation inside TradingView.

If you want, I can also build:

🔥 A hotkey map for ultra‑fast execution
⚡ A risk‑management module (position sizing, stop placement)
🧩 A multi‑monitor version of this layout
📈 A sector rotation dashboard
🧬 A breakout probability meter widget

## Source Code

````pine
//@version=5
indicator("APEX Master Volume System (Neural Patterns + Tape Speed + Liquidity Walls + Predictive Volume)", overlay=true, max_labels_count=500)

//========================
// Inputs
//========================
len = input.int(20, "Average Volume Length")
rvolTF = input.timeframe("5", "RVOL Timeframe")
sectorETF = input.symbol("AMEX:XLK", "Sector ETF")
floatShares = input.float(100e6, "Float (Shares)", step=1e6)
showPremarket = input.bool(false, "Include Pre-Market")
showLabels = input.bool(true, "Show Labels")
showHeatmap = input.bool(true, "Show Heatmap")
showDashboard = input.bool(true, "Show Dashboard")

//========================
// Time Filter
//========================
sess = time(timeframe.period, "0930-1600:1234567")
inSession = showPremarket ? true : not na(sess)

//========================
// Core Volume Metrics
//========================
avgVol = ta.sma(volume, len)
rvol = request.security(syminfo.tickerid, rvolTF, volume) /
       request.security(syminfo.tickerid, rvolTF, avgVol)

floatVolPct = volume / floatShares
isFloatSpike = floatVolPct > 0.01

//========================
// Sector Relative Volume
//========================
sectorVol = request.security(sectorETF, rvolTF, volume)
sectorAvgVol = request.security(sectorETF, rvolTF, ta.sma(volume, len))
srvol = sectorVol / sectorAvgVol
isSectorHot = srvol > 1.5

//========================
// Tape Speed (Momentum Ignition)
//========================
tapeSpeed = math.abs(close - close[1]) / (high - low + 1e-6)
isTapeIgnition = tapeSpeed > 0.6 and volume > avgVol * 1.2

//========================
// Liquidity Wall Detection (Absorption Proxy)
//========================
absorption = (close < open and volume > avgVol * 1.5 and close > low + (high - low) * 0.7)
isLiquidityWall = absorption

//========================
// Predictive Volume Ramping (Pre-Breakout Signature)
//========================
volTrend = ta.linreg(volume, 10, 0)
isRamping = volTrend > avgVol * 1.1

//========================
// Neural Pattern Recognition (Lightweight)
//========================
rangeExp = (high - low) / ta.sma(high - low, 20)
patternScore = 0.0
patternScore += rvol > 2 ? 1 : 0
patternScore += isRamping ? 1 : 0
patternScore += isTapeIgnition ? 1 : 0
patternScore += isSectorHot ? 1 : 0
patternScore += isFloatSpike ? 1 : 0
patternScore += isLiquidityWall ? -1 : 0

//========================
// Heatmap
//========================
heatSpike = volume > avgVol * 2
barcolor(showHeatmap and heatSpike ? color.new(color.red, 0) : na)

//========================
// Labels
//========================
if showLabels and isTapeIgnition
    label.new(bar_index, high, "IGNITE", style=label.style_label_up, color=color.red, textcolor=color.white, size=size.small)

if showLabels and isLiquidityWall
    label.new(bar_index, low, "WALL", style=label.style_label_down, color=color.blue, textcolor=color.white, size=size.small)

if showLabels and isRamping
    label.new(bar_index, high, "RAMP", style=label.style_label_up, color=color.green, textcolor=color.black, size=size.tiny)

if showLabels and isFloatSpike
    label.new(bar_index, high, "FLOAT%", style=label.style_label_up, color=color.fuchsia, textcolor=color.white, size=size.tiny)

if showLabels and isSectorHot
    label.new(bar_index, high, "SECTOR🔥", style=label.style_label_up, color=color.orange, textcolor=color.white, size=size.tiny)

//========================
// Alerts
//========================
alertcondition(isTapeIgnition, "Tape Ignition", "Momentum ignition detected")
alertcondition(isLiquidityWall, "Liquidity Wall", "Absorption detected")
alertcondition(isRamping, "Volume Ramping", "Pre-breakout volume ramping detected")
alertcondition(isFloatSpike, "Float Spike", "Float-adjusted volume spike detected")
alertcondition(isSectorHot, "Sector Hot", "Sector relative volume elevated")

//========================
// Dashboard
//========================
if showDashboard
    var table dash = table.new(position.top_right, 2, 7, border_width=1)

    table.cell(dash, 0, 0, "RVOL", bgcolor=color.new(color.blue, 85))
    table.cell(dash, 1, 0, str.tostring(rvol, "#.##"))

    table.cell(dash, 0, 1, "SRVOL", bgcolor=color.new(color.red, 85))
    table.cell(dash, 1, 1, str.tostring(srvol, "#.##"))

    table.cell(dash, 0, 2, "Float%", bgcolor=color.new(color.purple, 85))
    table.cell(dash, 1, 2, str.tostring(floatVolPct * 100, "#.##") + "%")

    table.cell(dash, 0, 3, "Tape Speed", bgcolor=color.new(color.green, 85))
    table.cell(dash, 1, 3, str.tostring(tapeSpeed, "#.##"))

    table.cell(dash, 0, 4, "Ramping", bgcolor=color.new(color.orange, 85))
    table.cell(dash, 1, 4, isRamping ? "YES" : "NO")

    table.cell(dash, 0, 5, "Liquidity Wall", bgcolor=color.new(color.blue, 85))
    table.cell(dash, 1, 5, isLiquidityWall ? "YES" : "NO")

    table.cell(dash, 0, 6, "Pattern Score", bgcolor=color.new(color.yellow, 85))
    table.cell(dash, 1, 6, str.tostring(patternScore, "#"))
````
