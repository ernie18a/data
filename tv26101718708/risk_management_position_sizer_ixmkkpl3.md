# Risk Management Position Sizer

- url: https://www.tradingview.com/script/ixmkkPL3-Risk-Management-Position-Sizer/
- type: indicator
- pine_id: PUB;d5de788055a844008d87fd77d32ddf41
- version: 1.0

## Description

This Pine Script v6 indicator is an automated Risk Management & Position Sizing Calculator for TradingView. It dynamically computes position size, maximum loss, expected profit, and risk-to-reward ratio directly on your chart canvas.

How to install?
[list]
[*]Open TradingView and load any financial chart (crypto, forex, stocks, or futures).
[*]Click Pine Editor on the bottom panel.
[*]Clear existing text in the editor.
[*]Copy and paste the script code into the editor.
[*]Click Save and then click Add to Chart.
[*]
[/list]

Dynamic Position Sizing: Automatically calculates the exact share/contract/token quantity needed based on account capital and risk percentage.

Auto or Manual Price Detection: Automatically populates the entry price using live bar close, or allows custom limit order entry.

Flexible Stop Loss & Take Profit Modes: Set SL/TP via percentage distances or manual price overrides.

Currency Formatting: Built-in auto-detection for exchange currencies with multi-currency formatting support (USD, EUR, GBP, JPY, BTC, ETH, etc.).

Customizable Dashboard Layout:

Select between Detailed and Minimal modes.

Choose Vertical or Horizontal layouts.

Adjust chart placement (Top Right, Bottom Left, etc.).

5 Color Themes included (Dark, Light, Ocean, Forest, Sunset).

Validation & Debugging: Built-in alerts detect invalid stop-loss setups or position sizes exceeding total capital.

How It Works
The indicator determines position size based on the fundamental fixed-fractional risk formula:

Calculate Capital at Risk:$$\text{Risk Amount} = \frac{\text{Total Capital} \times \text{Risk \%}}{100}$$

Calculate Distance to Stop Loss:$$\text{Risk Per Unit} = \vert{}\text{Entry Price} - \text{Stop Loss Price}\vert{}$$

Calculate Position Size:$$\text{Position Size (Qty)} = \frac{\text{Risk Amount}}{\text{Risk Per Unit}}$$

Risk-to-Reward Ratio:$$\text{R:R Ratio} = \frac{\vert{}\text{Take Profit Price} - \text{Entry Price}\vert{}}{\text{Risk Per Unit}}$$

## Source Code

````pine
// Risk Management & Position Sizing Calculator for TradingView
// @version=6
indicator(title="Risk Management Position Sizer", overlay=true)

// ============================================================================
// CONFIGURATION INPUTS
// ============================================================================

// Display Settings
tableMode = input.string(title="Table Mode", defval="Detailed", options=["Minimal", "Detailed"], group="Display Settings")
tableLayout = input.string(title="Table Layout", defval="Vertical", options=["Vertical", "Horizontal"], group="Display Settings")
themeColor = input.string(title="Theme Color", defval="Dark", options=["Dark", "Light", "Ocean", "Forest", "Sunset"], group="Display Settings")

// Currency Settings
useChartCurrency = input.bool(title="Use Chart Currency Auto-Detect", defval=true, group="Currency Settings")
manualCurrency = input.string(title="Manual Currency Selection", defval="USD", options=["USD", "EUR", "GBP", "JPY", "AUD", "CAD", "CHF", "INR", "BTC", "ETH"], group="Currency Settings")
useCurrentPrice = input.bool(title="Auto-populate Entry from Current Price", defval=true, group="Currency Settings")

totalCapital = input.float(title="Total Capital", defval=10000, step=100, group="Account Settings")
riskPercent = input.float(title="Risk per Trade (%)", defval=2, step=0.1, minval=0.1, maxval=10, group="Account Settings")

tradeType = input.string(title="Trade Type", defval="LONG", options=["LONG", "SHORT"], group="Trade Setup")
entryPrice = input.float(title="Entry Price", defval=100, step=0.01, group="Trade Setup")

autoSLTP = input.bool(title="Auto-Calculate SL & TP from Current Price", defval=true, group="Trade Setup")
slRiskPercent = input.float(title="SL Risk % below Entry (LONG) / above Entry (SHORT)", defval=2.0, step=0.1, minval=0.1, maxval=10, group="Trade Setup")
tpRewardPercent = input.float(title="TP Reward % above Entry (LONG) / below Entry (SHORT)", defval=3.0, step=0.1, minval=0.1, maxval=20, group="Trade Setup")

stopLossPrice = input.float(title="Stop Loss Price (manual override)", defval=0, step=0.01, group="Trade Setup")
takeProfitPrice = input.float(title="Take Profit Price (manual override)", defval=0, step=0.01, group="Trade Setup")

showTable = input.bool(title="Show Table", defval=true, group="Display Settings")
tablePosition = input.string(title="Table Position", defval="Top Right", options=["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group="Display Settings")
useDebugInfo = input.bool(title="Show Debug Info", defval=false, group="Display Settings")

// ============================================================================
// THEME COLORS - PREDEFINED
// ============================================================================

// Dark Theme
thDarkHeader = color.new(#1f77d2, 0)
thDarkHeaderText = color.white
thDarkRow = color.new(#262626, 0)
thDarkRowText = color.white
thDarkSection = color.new(#4a4a4a, 50)
thDarkBorder = color.gray

// Light Theme
thLightHeader = color.new(#6ba3d6, 0)
thLightHeaderText = color.new(#1a1a1a, 0)
thLightRow = color.new(#f5f5f5, 0)
thLightRowText = color.new(#1a1a1a, 0)
thLightSection = color.new(#e0e0e0, 0)
thLightBorder = color.new(#cccccc, 0)

// Ocean Theme
thOceanHeader = color.new(#0066cc, 0)
thOceanHeaderText = color.white
thOceanRow = color.new(#001a4d, 0)
thOceanRowText = color.new(#e6f2ff, 0)
thOceanSection = color.new(#003366, 0)
thOceanBorder = color.new(#0099ff, 0)

// Forest Theme
thForestHeader = color.new(#1b5e20, 0)
thForestHeaderText = color.white
thForestRow = color.new(#1b3a1b, 0)
thForestRowText = color.new(#c8e6c9, 0)
thForestSection = color.new(#2e7d32, 0)
thForestBorder = color.new(#66bb6a, 0)

// Sunset Theme
thSunsetHeader = color.new(#ff6b35, 0)
thSunsetHeaderText = color.white
thSunsetRow = color.new(#3d2817, 0)
thSunsetRowText = color.new(#ffd9b3, 0)
thSunsetSection = color.new(#b8460b, 0)
thSunsetBorder = color.new(#ff8c42, 0)

// ============================================================================
// APPLY THEME BASED ON SELECTION
// ============================================================================

finalHeaderBg = themeColor == "Dark" ? thDarkHeader : themeColor == "Light" ? thLightHeader : themeColor == "Ocean" ? thOceanHeader : themeColor == "Forest" ? thForestHeader : thSunsetHeader

finalHeaderText = themeColor == "Dark" ? thDarkHeaderText : themeColor == "Light" ? thLightHeaderText : themeColor == "Ocean" ? thOceanHeaderText : themeColor == "Forest" ? thForestHeaderText : thSunsetHeaderText

finalRowBg = themeColor == "Dark" ? thDarkRow : themeColor == "Light" ? thLightRow : themeColor == "Ocean" ? thOceanRow : themeColor == "Forest" ? thForestRow : thSunsetRow

finalRowText = themeColor == "Dark" ? thDarkRowText : themeColor == "Light" ? thLightRowText : themeColor == "Ocean" ? thOceanRowText : themeColor == "Forest" ? thForestRowText : thSunsetRowText

finalSectionBg = themeColor == "Dark" ? thDarkSection : themeColor == "Light" ? thLightSection : themeColor == "Ocean" ? thOceanSection : themeColor == "Forest" ? thForestSection : thSunsetSection

finalBorder = themeColor == "Dark" ? thDarkBorder : themeColor == "Light" ? thLightBorder : themeColor == "Ocean" ? thOceanBorder : themeColor == "Forest" ? thForestBorder : thSunsetBorder

// ============================================================================
// CURRENCY LOGIC
// ============================================================================

chartCurrency = syminfo.currency
selectedCurrency = useChartCurrency ? chartCurrency : manualCurrency

getCurrencySymbol(curr) =>
    switch curr
        "USD" => "$"
        "EUR" => "€"
        "GBP" => "£"
        "JPY" => "¥"
        "AUD" => "A$"
        "CAD" => "C$"
        "CHF" => "CHF"
        "INR" => "₹"
        "BTC" => "₿"
        "ETH" => "Ξ"
        => "$"

getDecimalPlaces(curr) =>
    switch curr
        "JPY" => 0
        "BTC" => 8
        "ETH" => 6
        => 2

currencySymbol = getCurrencySymbol(selectedCurrency)
decimalPlaces = getDecimalPlaces(selectedCurrency)

// ============================================================================
// CALCULATIONS
// ============================================================================

currentPrice = close
effectiveEntryPrice = useCurrentPrice ? currentPrice : entryPrice
isLongTrade = tradeType == "LONG"

// Auto-calculate SL & TP based on current price and risk/reward percentages
autoCalcSL = 0.0
autoCalcTP = 0.0

if autoSLTP
    if isLongTrade
        autoCalcSL := effectiveEntryPrice * (1 - slRiskPercent / 100)
        autoCalcTP := effectiveEntryPrice * (1 + tpRewardPercent / 100)
    else
        autoCalcSL := effectiveEntryPrice * (1 + slRiskPercent / 100)
        autoCalcTP := effectiveEntryPrice * (1 - tpRewardPercent / 100)

// Use manual override if provided, otherwise use auto values
finalSL = stopLossPrice > 0 ? stopLossPrice : autoCalcSL
finalTP = takeProfitPrice > 0 ? takeProfitPrice : autoCalcTP

riskAmount = (totalCapital * riskPercent) / 100
priceDifference = math.abs(effectiveEntryPrice - finalSL)
riskPerShare = priceDifference
positionSize = riskAmount > 0 and riskPerShare > 0 ? math.floor(riskAmount / riskPerShare * 100) / 100 : 0
totalPositionValue = positionSize * effectiveEntryPrice
profitAtTP = (finalTP - effectiveEntryPrice) * positionSize
lossAtSL = (effectiveEntryPrice - finalSL) * positionSize
riskReward = riskPerShare > 0 ? math.abs(finalTP - effectiveEntryPrice) / riskPerShare : 0
profitPercent = effectiveEntryPrice > 0 ? ((finalTP - effectiveEntryPrice) / effectiveEntryPrice) * 100 : 0
lossPercent = effectiveEntryPrice > 0 ? ((effectiveEntryPrice - finalSL) / effectiveEntryPrice) * 100 : 0
slDistance = math.abs(effectiveEntryPrice - finalSL)
tpDistance = math.abs(finalTP - effectiveEntryPrice)

// ============================================================================
// FORMATTING FUNCTIONS
// ============================================================================

f_formatCurrencyValue(value, decimals) =>
    formatted = str.tostring(math.round(value, decimals))
    currencySymbol + formatted

f_formatPercent(value) =>
    str.tostring(value, "0.00") + "%"

f_formatQuantity(value) =>
    str.tostring(value, "0.0000")

// ============================================================================
// TABLE POSITION SELECTOR
// ============================================================================

getTablePosition() =>
    switch tablePosition
        "Top Right" => position.top_right
        "Top Left" => position.top_left
        "Middle Right" => position.middle_right
        "Middle Left" => position.middle_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

// ============================================================================
// MINIMAL VERTICAL TABLE
// ============================================================================

buildMinimalVertical(tbl) =>
    row = 0
    table.cell(tbl, 0, row, "RISK CALC", text_color=finalHeaderText, text_size=size.large, bgcolor=finalHeaderBg)
    row += 1
    table.cell(tbl, 0, row, selectedCurrency + " " + currencySymbol, text_color=finalHeaderText, text_size=size.small, bgcolor=finalHeaderBg)
    row += 1
    table.cell(tbl, 0, row, "PRICES", text_color=finalHeaderText, text_size=size.small, bgcolor=finalSectionBg)
    row += 1
    table.cell(tbl, 0, row, "Entry", text_color=finalRowText, bgcolor=finalRowBg)
    table.cell(tbl, 1, row, f_formatCurrencyValue(effectiveEntryPrice, decimalPlaces), text_color=color.new(#3498db, 0), bgcolor=finalRowBg)
    row += 1
    table.cell(tbl, 0, row, "SL", text_color=finalRowText, bgcolor=finalRowBg)
    table.cell(tbl, 1, row, f_formatCurrencyValue(finalSL, decimalPlaces), text_color=color.new(#e74c3c, 0), bgcolor=finalRowBg)
    row += 1
    table.cell(tbl, 0, row, "TP", text_color=finalRowText, bgcolor=finalRowBg)
    table.cell(tbl, 1, row, f_formatCurrencyValue(finalTP, decimalPlaces), text_color=color.new(#26a69a, 0), bgcolor=finalRowBg)
    row += 1
    table.cell(tbl, 0, row, "POSITION", text_color=finalHeaderText, text_size=size.small, bgcolor=finalSectionBg)
    row += 1
    table.cell(tbl, 0, row, "Qty", text_color=finalRowText, bgcolor=finalRowBg)
    table.cell(tbl, 1, row, f_formatQuantity(positionSize), text_color=color.new(#9b59b6, 0), bgcolor=finalRowBg)
    row += 1
    table.cell(tbl, 0, row, "Risk $", text_color=finalRowText, bgcolor=finalRowBg)
    table.cell(tbl, 1, row, f_formatCurrencyValue(riskAmount, decimalPlaces), text_color=color.new(#e74c3c, 0), bgcolor=finalRowBg)
    row += 1
    table.cell(tbl, 0, row, "R:R", text_color=finalHeaderText, text_size=size.small, bgcolor=finalSectionBg)
    row += 1
    table.cell(tbl, 0, row, "Ratio", text_color=finalRowText, bgcolor=finalRowBg)
    ratioColor = riskReward >= 1.5 ? color.new(#26a69a, 0) : color.new(#f7931a, 0)
    table.cell(tbl, 1, row, str.tostring(riskReward, "0.00") + ":1", text_color=ratioColor, bgcolor=finalRowBg)
    row += 1
    table.cell(tbl, 0, row, "P&L", text_color=finalHeaderText, text_size=size.small, bgcolor=finalSectionBg)
    row += 1
    table.cell(tbl, 0, row, "Profit", text_color=finalRowText, bgcolor=finalRowBg)
    profitText = f_formatCurrencyValue(profitAtTP, decimalPlaces) + " (" + f_formatPercent(profitPercent) + ")"
    table.cell(tbl, 1, row, profitText, text_color=color.new(#26a69a, 0), bgcolor=finalRowBg)
    row += 1
    table.cell(tbl, 0, row, "Loss", text_color=finalRowText, bgcolor=finalRowBg)
    lossText = f_formatCurrencyValue(-lossAtSL, decimalPlaces) + " (" + f_formatPercent(-lossPercent) + ")"
    table.cell(tbl, 1, row, lossText, text_color=color.new(#e74c3c, 0), bgcolor=finalRowBg)

// ============================================================================
// MINIMAL HORIZONTAL TABLE
// ============================================================================

buildMinimalHorizontal(tbl) =>
    col = 0
    table.cell(tbl, col, 0, "Entry", text_color=finalHeaderText, bgcolor=finalHeaderBg)
    table.cell(tbl, col, 1, f_formatCurrencyValue(effectiveEntryPrice, decimalPlaces), text_color=color.new(#3498db, 0), bgcolor=finalRowBg)
    col += 1
    table.cell(tbl, col, 0, "SL", text_color=finalHeaderText, bgcolor=finalHeaderBg)
    table.cell(tbl, col, 1, f_formatCurrencyValue(finalSL, decimalPlaces), text_color=color.new(#e74c3c, 0), bgcolor=finalRowBg)
    col += 1
    table.cell(tbl, col, 0, "TP", text_color=finalHeaderText, bgcolor=finalHeaderBg)
    table.cell(tbl, col, 1, f_formatCurrencyValue(finalTP, decimalPlaces), text_color=color.new(#26a69a, 0), bgcolor=finalRowBg)
    col += 1
    table.cell(tbl, col, 0, "Qty", text_color=finalHeaderText, bgcolor=finalHeaderBg)
    table.cell(tbl, col, 1, f_formatQuantity(positionSize), text_color=color.new(#9b59b6, 0), bgcolor=finalRowBg)
    col += 1
    table.cell(tbl, col, 0, "Risk $", text_color=finalHeaderText, bgcolor=finalHeaderBg)
    table.cell(tbl, col, 1, f_formatCurrencyValue(riskAmount, decimalPlaces), text_color=color.new(#e74c3c, 0), bgcolor=finalRowBg)
    col += 1
    table.cell(tbl, col, 0, "R:R", text_color=finalHeaderText, bgcolor=finalHeaderBg)
    ratioColor = riskReward >= 1.5 ? color.new(#26a69a, 0) : color.new(#f7931a, 0)
    table.cell(tbl, col, 1, str.tostring(riskReward, "0.00") + ":1", text_color=ratioColor, bgcolor=finalRowBg)
    col += 1
    table.cell(tbl, col, 0, "Profit", text_color=finalHeaderText, bgcolor=finalHeaderBg)
    profitText = f_formatCurrencyValue(profitAtTP, decimalPlaces)
    table.cell(tbl, col, 1, profitText, text_color=color.new(#26a69a, 0), bgcolor=finalRowBg)
    col += 1
    table.cell(tbl, col, 0, "Loss", text_color=finalHeaderText, bgcolor=finalHeaderBg)
    lossText = f_formatCurrencyValue(-lossAtSL, decimalPlaces)
    table.cell(tbl, col, 1, lossText, text_color=color.new(#e74c3c, 0), bgcolor=finalRowBg)

// ============================================================================
// DETAILED VERTICAL TABLE
// ============================================================================

buildDetailedVertical(tbl) =>
    row = 0
    table.cell(tbl, 0, row, "RISK MANAGEMENT", text_color=finalHeaderText, text_size=size.large, bgcolor=finalHeaderBg)
    row += 1
    table.cell(tbl, 0, row, selectedCurrency + " | " + currencySymbol, text_color=finalHeaderText, text_size=size.small, bgcolor=finalHeaderBg)
    row += 1
    table.cell(tbl, 0, row, "ACCOUNT", text_color=finalHeaderText, text_size=size.small, bgcolor=finalSectionBg)
    row += 1
    table.cell(tbl, 0, row, "Capital", text_color=finalRowText, bgcolor=finalRowBg)
    table.cell(tbl, 1, row, f_formatCurrencyValue(totalCapital, decimalPlaces), text_color=color.new(#26a69a, 0), bgcolor=finalRowBg)
    row += 1
    table.cell(tbl, 0, row, "Risk %", text_color=finalRowText, bgcolor=finalRowBg)
    table.cell(tbl, 1, row, f_formatPercent(riskPercent), text_color=color.new(#f7931a, 0), bgcolor=finalRowBg)
    row += 1
    table.cell(tbl, 0, row, "Risk $", text_color=finalRowText, bgcolor=finalRowBg)
    table.cell(tbl, 1, row, f_formatCurrencyValue(riskAmount, decimalPlaces), text_color=color.new(#e74c3c, 0), bgcolor=finalRowBg)
    row += 1
    table.cell(tbl, 0, row, "PRICES", text_color=finalHeaderText, text_size=size.small, bgcolor=finalSectionBg)
    row += 1
    table.cell(tbl, 0, row, "Type", text_color=finalRowText, bgcolor=finalRowBg)
    typeColor = isLongTrade ? color.new(#26a69a, 0) : color.new(#e74c3c, 0)
    table.cell(tbl, 1, row, tradeType, text_color=typeColor, bgcolor=finalRowBg)
    row += 1
    table.cell(tbl, 0, row, "Current", text_color=finalRowText, bgcolor=finalRowBg)
    table.cell(tbl, 1, row, f_formatCurrencyValue(currentPrice, decimalPlaces), text_color=color.new(#3498db, 0), bgcolor=finalRowBg)
    row += 1
    table.cell(tbl, 0, row, "Entry", text_color=finalRowText, bgcolor=finalRowBg)
    entryColor = useCurrentPrice ? color.new(#3498db, 0) : finalRowText
    table.cell(tbl, 1, row, f_formatCurrencyValue(effectiveEntryPrice, decimalPlaces), text_color=entryColor, bgcolor=finalRowBg)
    row += 1
    table.cell(tbl, 0, row, "SL", text_color=finalRowText, bgcolor=finalRowBg)
    table.cell(tbl, 1, row, f_formatCurrencyValue(finalSL, decimalPlaces), text_color=color.new(#e74c3c, 0), bgcolor=finalRowBg)
    row += 1
    table.cell(tbl, 0, row, "TP", text_color=finalRowText, bgcolor=finalRowBg)
    table.cell(tbl, 1, row, f_formatCurrencyValue(finalTP, decimalPlaces), text_color=color.new(#26a69a, 0), bgcolor=finalRowBg)
    row += 1
    table.cell(tbl, 0, row, "POSITION", text_color=finalHeaderText, text_size=size.small, bgcolor=finalSectionBg)
    row += 1
    table.cell(tbl, 0, row, "Quantity", text_color=finalRowText, bgcolor=finalRowBg)
    table.cell(tbl, 1, row, f_formatQuantity(positionSize), text_color=color.new(#9b59b6, 0), bgcolor=finalRowBg)
    row += 1
    table.cell(tbl, 0, row, "Position $", text_color=finalRowText, bgcolor=finalRowBg)
    table.cell(tbl, 1, row, f_formatCurrencyValue(totalPositionValue, decimalPlaces), text_color=finalRowText, bgcolor=finalRowBg)
    row += 1
    table.cell(tbl, 0, row, "Risk/Unit", text_color=finalRowText, bgcolor=finalRowBg)
    table.cell(tbl, 1, row, f_formatCurrencyValue(riskPerShare, decimalPlaces), text_color=color.new(#e74c3c, 0), bgcolor=finalRowBg)
    row += 1
    table.cell(tbl, 0, row, "RISK-REWARD", text_color=finalHeaderText, text_size=size.small, bgcolor=finalSectionBg)
    row += 1
    table.cell(tbl, 0, row, "Risk Dist", text_color=finalRowText, bgcolor=finalRowBg)
    table.cell(tbl, 1, row, f_formatCurrencyValue(slDistance, decimalPlaces), text_color=color.new(#e74c3c, 0), bgcolor=finalRowBg)
    row += 1
    table.cell(tbl, 0, row, "Reward Dist", text_color=finalRowText, bgcolor=finalRowBg)
    table.cell(tbl, 1, row, f_formatCurrencyValue(tpDistance, decimalPlaces), text_color=color.new(#26a69a, 0), bgcolor=finalRowBg)
    row += 1
    table.cell(tbl, 0, row, "R:R Ratio", text_color=finalRowText, bgcolor=finalRowBg)
    ratioColor = riskReward >= 1.5 ? color.new(#26a69a, 0) : color.new(#f7931a, 0)
    table.cell(tbl, 1, row, str.tostring(riskReward, "0.00") + ":1", text_color=ratioColor, bgcolor=finalRowBg)
    row += 1
    table.cell(tbl, 0, row, "P&L", text_color=finalHeaderText, text_size=size.small, bgcolor=finalSectionBg)
    row += 1
    table.cell(tbl, 0, row, "Max Profit", text_color=finalRowText, bgcolor=finalRowBg)
    profitText = f_formatCurrencyValue(profitAtTP, decimalPlaces) + " (" + f_formatPercent(profitPercent) + ")"
    table.cell(tbl, 1, row, profitText, text_color=color.new(#26a69a, 0), bgcolor=finalRowBg)
    row += 1
    table.cell(tbl, 0, row, "Max Loss", text_color=finalRowText, bgcolor=finalRowBg)
    lossText = f_formatCurrencyValue(-lossAtSL, decimalPlaces) + " (" + f_formatPercent(-lossPercent) + ")"
    table.cell(tbl, 1, row, lossText, text_color=color.new(#e74c3c, 0), bgcolor=finalRowBg)
    row += 1
    table.cell(tbl, 0, row, "Profit % Cap", text_color=finalRowText, bgcolor=finalRowBg)
    profitCapitalPercent = (profitAtTP / totalCapital) * 100
    table.cell(tbl, 1, row, f_formatPercent(profitCapitalPercent), text_color=color.new(#26a69a, 0), bgcolor=finalRowBg)

// ============================================================================
// DETAILED HORIZONTAL TABLE
// ============================================================================

buildDetailedHorizontal(tbl) =>
    col = 0
    table.cell(tbl, col, 0, "Capital", text_color=finalHeaderText, bgcolor=finalHeaderBg)
    table.cell(tbl, col, 1, f_formatCurrencyValue(totalCapital, decimalPlaces), text_color=color.new(#26a69a, 0), bgcolor=finalRowBg)
    col += 1
    table.cell(tbl, col, 0, "Risk %", text_color=finalHeaderText, bgcolor=finalHeaderBg)
    table.cell(tbl, col, 1, f_formatPercent(riskPercent), text_color=color.new(#f7931a, 0), bgcolor=finalRowBg)
    col += 1
    table.cell(tbl, col, 0, "Risk $", text_color=finalHeaderText, bgcolor=finalHeaderBg)
    table.cell(tbl, col, 1, f_formatCurrencyValue(riskAmount, decimalPlaces), text_color=color.new(#e74c3c, 0), bgcolor=finalRowBg)
    col += 1
    table.cell(tbl, col, 0, "Type", text_color=finalHeaderText, bgcolor=finalHeaderBg)
    typeColor = isLongTrade ? color.new(#26a69a, 0) : color.new(#e74c3c, 0)
    table.cell(tbl, col, 1, tradeType, text_color=typeColor, bgcolor=finalRowBg)
    col += 1
    table.cell(tbl, col, 0, "Entry", text_color=finalHeaderText, bgcolor=finalHeaderBg)
    table.cell(tbl, col, 1, f_formatCurrencyValue(effectiveEntryPrice, decimalPlaces), text_color=color.new(#3498db, 0), bgcolor=finalRowBg)
    col += 1
    table.cell(tbl, col, 0, "SL", text_color=finalHeaderText, bgcolor=finalHeaderBg)
    table.cell(tbl, col, 1, f_formatCurrencyValue(finalSL, decimalPlaces), text_color=color.new(#e74c3c, 0), bgcolor=finalRowBg)
    col += 1
    table.cell(tbl, col, 0, "TP", text_color=finalHeaderText, bgcolor=finalHeaderBg)
    table.cell(tbl, col, 1, f_formatCurrencyValue(finalTP, decimalPlaces), text_color=color.new(#26a69a, 0), bgcolor=finalRowBg)
    col += 1
    table.cell(tbl, col, 0, "Qty", text_color=finalHeaderText, bgcolor=finalHeaderBg)
    table.cell(tbl, col, 1, f_formatQuantity(positionSize), text_color=color.new(#9b59b6, 0), bgcolor=finalRowBg)
    col += 1
    table.cell(tbl, col, 0, "Position $", text_color=finalHeaderText, bgcolor=finalHeaderBg)
    table.cell(tbl, col, 1, f_formatCurrencyValue(totalPositionValue, decimalPlaces), text_color=finalRowText, bgcolor=finalRowBg)
    col += 1
    table.cell(tbl, col, 0, "R:R", text_color=finalHeaderText, bgcolor=finalHeaderBg)
    ratioColor = riskReward >= 1.5 ? color.new(#26a69a, 0) : color.new(#f7931a, 0)
    table.cell(tbl, col, 1, str.tostring(riskReward, "0.00") + ":1", text_color=ratioColor, bgcolor=finalRowBg)
    col += 1
    table.cell(tbl, col, 0, "Profit", text_color=finalHeaderText, bgcolor=finalHeaderBg)
    profitText = f_formatCurrencyValue(profitAtTP, decimalPlaces) + " (" + f_formatPercent(profitPercent) + ")"
    table.cell(tbl, col, 1, profitText, text_color=color.new(#26a69a, 0), bgcolor=finalRowBg)
    col += 1
    table.cell(tbl, col, 0, "Loss", text_color=finalHeaderText, bgcolor=finalHeaderBg)
    lossText = f_formatCurrencyValue(-lossAtSL, decimalPlaces) + " (" + f_formatPercent(-lossPercent) + ")"
    table.cell(tbl, col, 1, lossText, text_color=color.new(#e74c3c, 0), bgcolor=finalRowBg)

// ============================================================================
// TABLE RENDERING ENGINE
// ============================================================================

var table tbl = na

if showTable
    isMinimal = tableMode == "Minimal"
    isVertical = tableLayout == "Vertical"
    
    tableRows = 0
    tableCols = 0
    
    if isMinimal and isVertical
        tableRows := 16
        tableCols := 2
    else if isMinimal and not isVertical
        tableRows := 2
        tableCols := 8
    else if not isMinimal and isVertical
        tableRows := 24
        tableCols := 2
    else
        tableRows := 2
        tableCols := 12
    
    if na(tbl)
        tbl := table.new(position=getTablePosition(), columns=tableCols, rows=tableRows, frame_color=finalBorder, frame_width=2, border_color=finalBorder, border_width=1)
    
    if barstate.islast
        if isMinimal and isVertical
            buildMinimalVertical(tbl)
        else if isMinimal and not isVertical
            buildMinimalHorizontal(tbl)
        else if not isMinimal and isVertical
            buildDetailedVertical(tbl)
        else
            buildDetailedHorizontal(tbl)

// ============================================================================
// ALERTS
// ============================================================================

insufficientFunds = totalPositionValue > totalCapital
invalidSetup = (isLongTrade and finalSL >= effectiveEntryPrice) or (not isLongTrade and finalSL <= effectiveEntryPrice)

if barstate.islast and useDebugInfo
    if insufficientFunds
        runtime.error("⚠️ Insufficient funds for position size")
    if invalidSetup
        runtime.error("⚠️ Invalid stop loss setup for trade type")
````
