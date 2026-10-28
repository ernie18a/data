# ATR, DTR and Stop Loss

- url: https://www.tradingview.com/script/7qWCQ7OQ-ATR-DTR-and-Stop-Loss/
- type: indicator
- pine_id: PUB;862a5ee67a8c4b9293569ecb5ba72ce4
- version: 4.0

## Description

[b]ATR, DTR and Stop Loss[/b]
Compact TradingView overlay table for daily ATR, daily trading range, and ATR-based stop-loss reference levels.

[b]Features[/b]
[list]
[*]Shows ATR / DTR with DTR as a percent of ATR.
[*]Shows ATR-based stop-loss guidance using 0.25 ATR and 0.5 ATR.
[*]Optional display modes:
[list]
[*]ATR distance values only
[*]Stop prices using close - 0.25 ATR and close - 0.5 ATR
[*]Stop prices with ATR distance values in parentheses
[/list]
[*]Default table position is bottom-left.
[*]Includes an extra blank spacer row so the table is less likely to be hidden by TradingView UI icons.
[*]Uses muted, non-invasive table colors.
[/list]

[b]Settings[/b]
[list]
[*]Table Position: Choose where the table appears.
[*]Text Size: Tiny, Small, Normal, or Large. Default is Normal.
[*]ATR Length: Daily ATR period. Default is 14.
[*]Stop Loss Format: Choose ATR values, stop prices, or stop prices plus ATR values. Default is Stop Prices.
[*]Show $ Prefix: Toggle dollar-style formatting on/off.
[/list]

## Source Code

````pine
//@version=5
indicator("ATR, DTR and Stop Loss", overlay=true)

// ==================== INPUTS ====================
tablePosition = input.string("Bottom Left", "Table Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group="Display Options")
textSizeOption = input.string("Normal", "Text Size", options=["Tiny", "Small", "Normal", "Large"], group="Display Options")
atrLength = input.int(14, "ATR Length", minval=1, group="ATR Settings")
stopLossFormat = input.string("ATR Values", "Stop Loss Format", options=["ATR Values", "Stop Prices", "Stop Prices + ATR Values"], group="ATR Settings")
showDollarPrefix = input.bool(false, "Show $ Prefix", group="Display Options")
yellowThreshold = input.int(80, "Yellow Alert Threshold (%)", minval=1, maxval=100, group="ATR Settings", tooltip="At what % of ATR does the DTR turn yellow (warning)?")
useLightTheme = input.bool(false, "Use Light Theme Colors", group="Display Options", tooltip="Adjusts table backgrounds and text colors to blend with a light chart background")
showBorders = input.bool(true, "Show Table Borders", group="Display Options", tooltip="Toggle table frame and borders on/off")

// ==================== COLOR INPUTS ====================
group_colors = "Color Settings"
labelBgColor = input.color(color.new(#434651, 30), "Label Background Color", group=group_colors)
tableBgColor = input.color(color.new(#1e222a, 60), "Table Background Color", group=group_colors)
tableFrameColor = input.color(color.new(color.white, 85), "Table Border Color", group=group_colors)

greenColor = input.color(color.new(#26a69a, 25), "DTR < 80% ATR Color (Green)", group=group_colors)
yellowColor = input.color(color.new(#ffca28, 25), "DTR ~ 80% ATR Color (Yellow)", group=group_colors)
redColor = input.color(color.new(#ef5350, 25), "DTR > ATR Color (Red)", group=group_colors)

stopLossBgColor = input.color(color.new(#78909c, 30), "Stop Loss Background Color", group=group_colors)
emptyBgColor = input.color(color.new(#37474f, 45), "N/A Cell Background Color", group=group_colors)

// ==================== RESOLVED COLORS ====================
resolvedTextClr = useLightTheme ? #1e222a : color.white
resolvedTableBg = useLightTheme ? color.new(#ffffff, 10) : tableBgColor
resolvedFrameClr = showBorders ? (useLightTheme ? color.new(#bcbec6, 20) : tableFrameColor) : color.new(color.white, 100)
resolvedLabelBg = useLightTheme ? color.new(#e0e3eb, 0) : labelBgColor

resolvedGreenColor = useLightTheme ? color.new(#26a69a, 40) : greenColor
resolvedYellowColor = useLightTheme ? color.new(#ffca28, 40) : yellowColor
resolvedRedColor = useLightTheme ? color.new(#ef5350, 40) : redColor

resolvedSLBgColor = useLightTheme ? color.new(#90a4ae, 30) : stopLossBgColor
resolvedEmptyBgColor = useLightTheme ? color.new(#cfd8dc, 30) : emptyBgColor

// ==================== HELPERS ====================
getTablePosition(pos) =>
    pos == "Top Left" ? position.top_left :
     pos == "Top Center" ? position.top_center :
     pos == "Top Right" ? position.top_right :
     pos == "Middle Left" ? position.middle_left :
     pos == "Middle Center" ? position.middle_center :
     pos == "Middle Right" ? position.middle_right :
     pos == "Bottom Left" ? position.bottom_left :
     pos == "Bottom Center" ? position.bottom_center :
     position.bottom_right

getTextSize(sizeInput) =>
    sizeInput == "Tiny" ? size.tiny :
     sizeInput == "Small" ? size.small :
     sizeInput == "Large" ? size.large :
     size.normal

formatPrice(value) =>
    na(value) ? "N/A" : (showDollarPrefix ? "$" : "") + str.tostring(value, format.mintick)

// ==================== CALCULATIONS ====================
// Keep this aligned with the ORB Trading Dashboard ATR / DTR row.
[dailyLow, dailyHigh, dailyATR] = request.security(syminfo.tickerid, "D", [low, high, ta.atr(atrLength)], lookahead=barmerge.lookahead_off)
dailyTR = dailyHigh - dailyLow
quarterATR = dailyATR * 0.25
halfATR = dailyATR * 0.5
quarterAtrStop = close - quarterATR
halfAtrStop = close - halfATR

// ==================== TABLE ====================
var table atrTable = table.new(getTablePosition(tablePosition), 2, 2, bgcolor=resolvedTableBg, border_width=showBorders ? 1 : 0, frame_width=showBorders ? 1 : 0, frame_color=resolvedFrameClr)

if barstate.islast
    txtSize = getTextSize(textSizeOption)

    table.cell(atrTable, 0, 0, "ATR/DTR", bgcolor=resolvedLabelBg, text_color=resolvedTextClr, text_size=txtSize)
    if not na(dailyATR) and not na(dailyTR) and dailyATR > 0
        dtrPct = dailyTR / dailyATR * 100
        atrDtrStr = formatPrice(dailyATR) + "/" + formatPrice(dailyTR) + " (" + str.tostring(dtrPct, "#") + "%)"
        atrDtrColor = dtrPct > 100 ? resolvedRedColor : dtrPct >= yellowThreshold ? resolvedYellowColor : resolvedGreenColor
        table.cell(atrTable, 1, 0, atrDtrStr, bgcolor=atrDtrColor, text_color=resolvedTextClr, text_size=txtSize)
    else
        table.cell(atrTable, 1, 0, na(dailyATR) ? "N/A" : formatPrice(dailyATR), bgcolor=resolvedEmptyBgColor, text_color=resolvedTextClr, text_size=txtSize)

    table.cell(atrTable, 0, 1, "SL 0.25/0.5", bgcolor=resolvedLabelBg, text_color=resolvedTextClr, text_size=txtSize)
    if not na(dailyATR) and dailyATR > 0
        atrValuesStr = formatPrice(quarterATR) + "/" + formatPrice(halfATR)
        stopPricesStr = formatPrice(quarterAtrStop) + "/" + formatPrice(halfAtrStop)
        stopPricesWithAtrStr = formatPrice(quarterAtrStop) + " (" + formatPrice(quarterATR) + ")/" + formatPrice(halfAtrStop) + " (" + formatPrice(halfATR) + ")"
        stopLossStr = stopLossFormat == "Stop Prices" ? stopPricesStr : stopLossFormat == "Stop Prices + ATR Values" ? stopPricesWithAtrStr : atrValuesStr
        table.cell(atrTable, 1, 1, stopLossStr, bgcolor=resolvedSLBgColor, text_color=resolvedTextClr, text_size=txtSize)
    else
        table.cell(atrTable, 1, 1, "N/A", bgcolor=resolvedEmptyBgColor, text_color=resolvedTextClr, text_size=txtSize)
````
