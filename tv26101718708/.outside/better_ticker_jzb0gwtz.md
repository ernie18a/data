# Better Ticker

- url: https://www.tradingview.com/script/Jzb0gwtZ-Better-Ticker/
- type: indicator
- pine_id: PUB;b6f5305cde2d40e4893db173745d3e8d
- version: 1.0

## Description

It's a Ticker! 

Live updates, Market Status dots, styling options.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradingView
// Modified styling/customization by FS-Dev

//@version=6
indicator("Better Ticker", overlay = true, dynamic_requests = true)

string TT_SYM = "A list of symbols or ticker IDs, separated by commas, MUST have a space after the comma if you want it to rotate"
string TT_STATUS = "If viewing a symbol feed that has delayed data, every status dot in your ticker will appear green, this is a Pinescript limitation in the way it fetches the status"

string groupMain = "Ticker Settings"
string groupStyle = "Style"
string groupColors = "Text Colors"
string groupBackgrounds = "Background"
string groupFrame = "Frame / Border"
string groupSmooth = "Smooth Scroll Layout"
string groupFormat = "Display Formatting"
string groupStatus = "Feed Status"

bool letTapeRunInput = input.bool(true, "Running", group = groupMain)
int offsetInput = input.int(0, "Offset", minval = 0, group = groupMain)
int scrollStepInput = input.int(1, "Scroll Step Per Update", minval = 1, maxval = 10, group = groupMain)

string symbolListInput = input.text_area("OANDA:GBPUSD, OANDA:USDJPY, ICMARKETS:USDCAD, CAPITALCOM:US30, CAPITALCOM:US100, VANTAGE:SP500, FOREXCOM:XAUUSD, FOREXCOM:XAGUSD, COINBASE:BTCUSD, COINBASE:ETHUSD, COMEX:GC1!, CME_MINI:ES1!, CBOT_MINI:YM1!, CME_MINI:NQ1!, CME:NIY1!", "Symbol list", tooltip = TT_SYM, group = groupMain)

string requestTfInput = input.timeframe("1D", "Data Timeframe", group = groupMain)

string displayNameModeInput = input.string("Short Ticker", "Display Name Mode", options = ["Description", "Short Ticker"], group = groupFormat)
string priceDisplayModeInput = input.string("Mintick", "Price Display Mode", options = ["Mintick", "2 Decimals", "3 Decimals", "5 Decimals", "Compact"], group = groupFormat)
string changeDisplayModeInput = input.string("Price + Percent", "Change Display", options = ["Price + Percent", "Percent Only", "Price Only"], group = groupFormat)

bool showStatusInput = input.bool(true, "Show Status Dot", tooltip = TT_STATUS, group = groupStatus)
string statusDotInput = input.string("●", "Status Dot", group = groupStatus)
string statusTfInput = input.timeframe("1", "Status Timeframe", group = groupStatus)
int freshMinutesInput = input.int(3, "Fresh If Status Bar Updated Within Minutes", minval = 1, maxval = 1440, group = groupStatus)
color statusFreshColorInput = input.color(color.lime, "Fresh / Active Color", group = groupStatus)
color statusStaleColorInput = input.color(color.gray, "Stale / Closed Color", group = groupStatus)
color statusUnknownColorInput = input.color(color.orange, "Unknown / No Data Color", group = groupStatus)

string tickerOrientationInput = input.string("Horizontal", "Ticker Orientation", options = ["Horizontal", "Vertical"], group = groupStyle)
string verticalDirectionInput = input.string("Down", "Vertical Scroll Direction", options = ["Down", "Up"], group = groupStyle)

string tablePositionInput = input.string("Bottom Center", "Ticker Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupStyle)
string textSizeInput = input.string("Normal", "Text Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupStyle)

string separatorTextInput = input.string("|", "Separator Text", group = groupStyle)
color separatorColorInput = input.color(color.gray, "Separator Color", group = groupStyle)
int separatorTransparencyInput = input.int(0, "Separator Transparency", minval = 0, maxval = 100, group = groupStyle)

bool useSmoothSpacingInput = input.bool(true, "Use Smooth Spacer Cells", group = groupSmooth)
string spacerTextInput = input.string(" ", "Spacer Text", group = groupSmooth)
color spacerTextColorInput = input.color(color.gray, "Spacer Text Color", group = groupSmooth)
int spacerTransparencyInput = input.int(100, "Spacer Text Transparency", minval = 0, maxval = 100, group = groupSmooth)

color nameTextColorInput = input.color(color.white, "Symbol / Name Text Color", group = groupColors)

color priceUpColorInput = input.color(color.lime, "Price Up Color", group = groupColors)
color priceDownColorInput = input.color(color.red, "Price Down Color", group = groupColors)
color priceNeutralColorInput = input.color(color.gray, "Price Neutral Color", group = groupColors)

color changeUpColorInput = input.color(color.lime, "Change Up Color", group = groupColors)
color changeDownColorInput = input.color(color.red, "Change Down Color", group = groupColors)
color changeNeutralColorInput = input.color(color.gray, "Change Neutral Color", group = groupColors)

color tableBgColorInput = input.color(color.rgb(0, 13, 111, 97), "Table Background Color", group = groupBackgrounds)
int tableBgTransparencyInput = input.int(90, "Table Background Transparency", minval = 0, maxval = 100, group = groupBackgrounds)

color frameColorInput = input.color(color.rgb(48, 48, 48), "Frame Color", group = groupFrame)
int frameTransparencyInput = input.int(0, "Frame Transparency", minval = 0, maxval = 100, group = groupFrame)
int frameWidthInput = input.int(1, "Frame Width", minval = 0, maxval = 5, group = groupFrame)

getTablePosition(string pos) =>
    pos == "Top Left" ? position.top_left : pos == "Top Center" ? position.top_center : pos == "Top Right" ? position.top_right : pos == "Middle Left" ? position.middle_left : pos == "Middle Center" ? position.middle_center : pos == "Middle Right" ? position.middle_right : pos == "Bottom Left" ? position.bottom_left : pos == "Bottom Center" ? position.bottom_center : position.bottom_right

getTextSize(string sz) =>
    sz == "Tiny" ? size.tiny : sz == "Small" ? size.small : sz == "Normal" ? size.normal : sz == "Large" ? size.large : size.huge

getShortTicker(string ticker) =>
    array<string> parts = str.split(ticker, ":")
    array.size(parts) > 1 ? array.get(parts, array.size(parts) - 1) : ticker

formatCompact(float val) =>
    float absVal = math.abs(val)
    string sign = val < 0 ? "-" : ""
    string suffix = ""
    float scaled = absVal
    if absVal >= 1000000000
        scaled := absVal / 1000000000
        suffix := "B"
    else if absVal >= 1000000
        scaled := absVal / 1000000
        suffix := "M"
    else if absVal >= 1000
        scaled := absVal / 1000
        suffix := "K"
    sign + str.tostring(math.round(scaled * 100.0) / 100.0) + suffix

formatPrice(float val, string mode) =>
    na(val) ? "n/a" : mode == "2 Decimals" ? str.tostring(val, "#.##") : mode == "3 Decimals" ? str.tostring(val, "#.###") : mode == "5 Decimals" ? str.tostring(val, "#.#####") : mode == "Compact" ? formatCompact(val) : str.tostring(val, format.mintick)

formatChange(float chg, float chgP, string mode, string priceMode) =>
    string pricePart = formatPrice(chg, priceMode)
    string percentPart = na(chgP) ? "n/a" : str.tostring(chgP, format.percent)
    mode == "Percent Only" ? percentPart : mode == "Price Only" ? pricePart : pricePart + " (" + percentPart + ")"

getDisplayName(string mode, string ticker, string desc) =>
    mode == "Description" ? (na(desc) or desc == "" ? ticker : desc) : getShortTicker(ticker)

getStatusColor(bool hasData, int statusTime, int freshMinutes, color freshColor, color staleColor, color unknownColor) =>
    not hasData ? unknownColor : na(statusTime) ? freshColor : timenow - statusTime <= freshMinutes * 60000 ? freshColor : staleColor

type Tape
    string ticker
    string name
    varip float last
    varip string lastStr
    varip float change
    varip string changeStr
    varip float changeP
    varip int upDown
    varip int statusTime
    varip color statusColor

type TickerSlot
    string txt
    color txtColor

fsec(series string ticker, string tf, string statusTf) =>
    [tfClose, tfChange, tfChangeP, tfName] = request.security(ticker, tf, [close, close - close[1], close[1] != 0 ? (close - close[1]) / close[1] * 100 : na, syminfo.description], lookahead = barmerge.lookahead_on, calc_bars_count = 50, ignore_invalid_symbol = true)
    [dClose, dChange, dChangeP, dName] = request.security(ticker, "1D", [close, close - close[1], close[1] != 0 ? (close - close[1]) / close[1] * 100 : na, syminfo.description], lookahead = barmerge.lookahead_on, calc_bars_count = 50, ignore_invalid_symbol = true)
    statusTime = request.security(ticker, statusTf, time, lookahead = barmerge.lookahead_on, calc_bars_count = 5, ignore_invalid_symbol = true)
    useFallback = na(tfClose)
    outClose = useFallback ? dClose : tfClose
    outChange = useFallback ? dChange : tfChange
    outChangeP = useFallback ? dChangeP : tfChangeP
    outName = useFallback ? dName : tfName
    [outClose, outChange, outChangeP, outName, statusTime]

makeTapes(array<string> symbolArray) =>
    array<Tape> tapes = array.new<Tape>()
    for ticker in symbolArray
        string cleanedTicker = str.trim(ticker)
        if cleanedTicker != ""
            tapes.push(Tape.new(cleanedTicker))
    tapes

method update(Tape this, string tf, string statusTf, string displayNameMode, string priceDisplayMode, string changeDisplayMode, int freshMinutes, color freshColor, color staleColor, color unknownColor) =>
    [last, change, changeP, desc, statusTime] = fsec(this.ticker, tf, statusTf)
    bool hasData = not na(last)
    this.upDown := na(last) ? 0 : na(this.last) ? 0 : this.last < last ? 1 : this.last > last ? -1 : 0
    this.name := getDisplayName(displayNameMode, this.ticker, desc)
    this.last := last
    this.lastStr := formatPrice(last, priceDisplayMode)
    this.change := change
    this.changeStr := formatChange(change, changeP, changeDisplayMode, priceDisplayMode)
    this.changeP := changeP
    this.statusTime := statusTime
    this.statusColor := getStatusColor(hasData, statusTime, freshMinutes, freshColor, staleColor, unknownColor)
    this

appendSlot(array<TickerSlot> slots, string txt, color txtColor) =>
    array.push(slots, TickerSlot.new(txt, txtColor))

appendTextAsCharacters(array<TickerSlot> slots, string txt, color txtColor) =>
    int len = str.length(txt)
    if len > 0
        for i = 0 to len - 1
            string ch = str.substring(txt, i, i + 1)
            array.push(slots, TickerSlot.new(ch, txtColor))

appendField(array<TickerSlot> slots, string txt, color txtColor, bool isVertical) =>
    if isVertical
        appendTextAsCharacters(slots, txt, txtColor)
    else
        appendSlot(slots, txt, txtColor)

appendTape(array<TickerSlot> slots, Tape this, bool isVertical, bool useSmoothSpacing, bool showStatus, string statusDot, color nameTextColor, color priceUpColor, color priceDownColor, color priceNeutralColor, color changeUpColor, color changeDownColor, color changeNeutralColor, string separatorText, color separatorColor, string spacerText, color spacerTextColor) =>
    color priceColor = this.upDown < 0 ? priceDownColor : this.upDown > 0 ? priceUpColor : priceNeutralColor
    color changeColor = na(this.change) ? changeNeutralColor : this.change < 0 ? changeDownColor : this.change > 0 ? changeUpColor : changeNeutralColor
    if useSmoothSpacing
        appendField(slots, separatorText, separatorColor, isVertical)
        appendField(slots, spacerText, spacerTextColor, isVertical)
        if showStatus
            appendField(slots, statusDot, this.statusColor, isVertical)
            appendField(slots, spacerText, spacerTextColor, isVertical)
        appendField(slots, this.name, nameTextColor, isVertical)
        appendField(slots, spacerText, spacerTextColor, isVertical)
        appendField(slots, this.lastStr, priceColor, isVertical)
        appendField(slots, spacerText, spacerTextColor, isVertical)
        appendField(slots, this.changeStr, changeColor, isVertical)
        appendField(slots, spacerText, spacerTextColor, isVertical)
    else
        appendField(slots, separatorText, separatorColor, isVertical)
        if showStatus
            appendField(slots, statusDot, this.statusColor, isVertical)
        appendField(slots, this.name, nameTextColor, isVertical)
        appendField(slots, this.lastStr, priceColor, isVertical)
        appendField(slots, this.changeStr, changeColor, isVertical)

fillTickerSlot(series table display, series int slot, bool isVertical, string txt, color txtColor, string textSize, color cellBgColor) =>
    if isVertical
        table.cell(display, column = 0, row = slot, text = txt, text_color = txtColor, text_size = textSize, bgcolor = cellBgColor)
    else
        table.cell(display, column = slot, row = 0, text = txt, text_color = txtColor, text_size = textSize, bgcolor = cellBgColor)

varip array<Tape> tapes = makeTapes(str.split(symbolListInput, ","))

bool isVertical = tickerOrientationInput == "Vertical"
bool verticalScrollDown = verticalDirectionInput == "Down"

array<TickerSlot> slots = array.new<TickerSlot>()

for t in tapes
    t.update(requestTfInput, statusTfInput, displayNameModeInput, priceDisplayModeInput, changeDisplayModeInput, freshMinutesInput, statusFreshColorInput, statusStaleColorInput, statusUnknownColorInput)
    appendTape(slots, t, isVertical, useSmoothSpacingInput, showStatusInput, statusDotInput, nameTextColorInput, priceUpColorInput, priceDownColorInput, priceNeutralColorInput, changeUpColorInput, changeDownColorInput, changeNeutralColorInput, separatorTextInput, color.new(separatorColorInput, separatorTransparencyInput), spacerTextInput, color.new(spacerTextColorInput, spacerTransparencyInput))

int cells = math.max(1, array.size(slots))

int tableColumns = isVertical ? 1 : cells
int tableRows = isVertical ? cells : 1

tablePosition = getTablePosition(tablePositionInput)
textSize = getTextSize(textSizeInput)

tableBgColor = color.new(tableBgColorInput, tableBgTransparencyInput)
frameColor = color.new(frameColorInput, frameTransparencyInput)

cellBgColor = color.new(color.blue, 97)

var table tbl = na
var string lastTablePositionInput = na
var int lastCells = na
var int lastFrameWidth = na
var string lastOrientationInput = na

bool needsNewTable = na(tbl) or tablePositionInput != lastTablePositionInput or cells != lastCells or frameWidthInput != lastFrameWidth or tickerOrientationInput != lastOrientationInput

if needsNewTable
    if not na(tbl)
        table.delete(tbl)
    tbl := table.new(position = tablePosition, columns = tableColumns, rows = tableRows, bgcolor = tableBgColor, frame_width = frameWidthInput, frame_color = frameColor)
    lastTablePositionInput := tablePositionInput
    lastCells := cells
    lastFrameWidth := frameWidthInput
    lastOrientationInput := tickerOrientationInput

varip int shift = 0

if barstate.isfirst
    shift := cells - 1 + offsetInput

if barstate.islast
    if letTapeRunInput
        shift += verticalScrollDown ? scrollStepInput : -scrollStepInput

    for slot = 0 to cells - 1
        int rawIdx = isVertical ? (slot + shift) % cells : (slot + shift) % cells
        int idx = rawIdx < 0 ? rawIdx + cells : rawIdx
        TickerSlot tickerSlot = array.get(slots, idx)
        fillTickerSlot(tbl, slot, isVertical, tickerSlot.txt, tickerSlot.txtColor, textSize, cellBgColor)
````
