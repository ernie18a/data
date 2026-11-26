# Advanced Watermark By JZ

- url: https://www.tradingview.com/script/rrOqdVcS-Advanced-Watermark-By-JZ/
- type: indicator
- pine_id: PUB;04b53c6eb9814c929facfc9661465597
- version: 3.0

## Description

This is a highly customizable chart watermark and layout-safe dashboard for TradingView (Pine Script v6). It dynamically arranges text elements without overlapping or throwing runtime table errors.

Key Features
Dynamic Anti-Collision Layout Engine: Automatically stacks elements or pushes them side-by-side depending on your position choices. If you set multiple elements to Above, Below, or Right, the script intelligently queues them so they never overlap.

Multi-Source Price Change: Tracks percentage and point changes relative to the Current Timeframe, Daily, Weekly, or Monthly close.

Integrated Trading Rules / Message Board: Features a separate, multi-line text area to keep your trading rules (NO FOMO, WAIT FOR SETUP) clearly visible on your screen.

Settings Explained
1. Watermark Visibility (inline = "wm1" / "wm2")

Show Timeframe: Toggles the visibility of the current chart resolution (e.g., 1h, 4h, D).
Show Exchange: Toggles the visibility of the exchange prefix (e.g., BINANCE, NASDAQ).
Show Change: Toggles the real-time price change statistics.
Show Signature: Toggles your personalized signature text.

2. Positions relative to Title (group = "Positions relative to Title")
Exchange Position: Places the exchange text either Above the ticker symbol or to its Left.

Change Position: Moves the price change label Above, Below, Left, or Right relative to the main title.

Note: Setting both Exchange and Change to Above creates a perfect vertical stack: Change → Exchange → Title.

Signature Position: Places your custom text either Below or to the Right of the layout.

3. Table Alignment on Screen (group = "Table Alignment on Screen")
Vertical Position: Anchors the watermark to the Top, Middle, or Bottom of your chart screen.

Horizontal Position: Aligns the entire watermark structure tightly against the Left edge, Center, or Right edge of your screen.

4. Change Display Mode
Percent Only: Displays only the directional arrow and percentage (e.g., ▲ 1.45%).

Points Only: Displays only the absolute value price change (e.g., ▲ +150.50).

Both: Combines both metrics cleanly (e.g., ▲ 1.45% (+150.50)).

Change Source: Allows you to measure performance relative to Current TF, Daily, Weekly, or Monthly candles.

5. Sizes & Colors (group = "Sizes" / "Colors")
Provides independent text size scales (tiny to huge) and individual transparency/color controls for the Title, Exchange, Signature, and Positive/Negative market returns.

6. Message Board (group = "Message")
A fully customizable multi-line text widget. Great for keeping trading psychology reminders, strict plan rules, or custom daily notes fixed in a separate corner of your screen. Fully adjustable for size, position, and color.

## Source Code

````pine
//@version=6
// ©ashezpow (Original concept and inspiration)
// Modified and enhanced by JZ

indicator("Advanced Watermark v43", overlay = true)

//────────────────────────────────────
// WATERMARK SETTINGS (INPUTS)
//────────────────────────────────────
showTF        = input.bool(true, "Show Timeframe", inline = "wm1")
showpf        = input.bool(true, "Show Exchange", inline = "wm1")
showchange    = input.bool(true, "Show Change", inline = "wm2")
showSignature = input.bool(true, "Show Signature", inline = "wm2")

groupPos = "Positions relative to Title"
exchangePos  = input.string("Left", "Exchange Position", options = ["Above", "Left"], group = groupPos)
changePosSel = input.string("Below", "Change Position", options = ["Above", "Left", "Right", "Below"], group = groupPos)
signaturePos = input.string("Below", "Signature Position", options = ["Right", "Below"], group = groupPos)

groupAlign = "Table Alignment on Screen"
watermarkVPos = input.string("Bottom", "Vertical Position", options = ["Top", "Middle", "Bottom"], inline = "wmPos", group = groupAlign)
watermarkHPos = input.string("Right", "Horizontal Position", options = ["Left", "Center", "Right"], inline = "wmPos", group = groupAlign)

changeMode    = input.string("Both", "Change Display Mode", options = ["Percent Only", "Points Only", "Both"])

// SIZES
groupSizes = "Sizes"
sizeTitle = input.string("huge", "Title Size", options = ["tiny", "small", "normal", "large", "huge", "auto"], group = groupSizes)
sizeExch  = input.string("small", "Exchange Size", options = ["tiny", "small", "normal", "large", "huge", "auto"], group = groupSizes)
sizeChg   = input.string("large", "Change Size", options = ["tiny", "small", "normal", "large", "huge", "auto"], group = groupSizes)
sizeSign  = input.string("small", "Signature Size", options = ["tiny", "small", "normal", "large", "huge", "auto"], group = groupSizes)

// COLORS
groupColors = "Colors"
colorTitle = input.color(#ffffff77, "Title Color", group = groupColors)
colorExch  = input.color(#ffffff55, "Exchange Color", group = groupColors)
colorSign  = input.color(#ffffff55, "Signature Color", group = groupColors)
positiveColor = input.color(color.lime, "Positive Change Color", group = groupColors)
negativeColor = input.color(color.red, "Negative Change Color", group = groupColors)

signature     = input.string("by you", "Signature text")
separator     = input.string(" ", "Separator (e.g. space, / or -)")
changeSource = input.string("Daily", "Change Source", options = ["Current TF", "Daily", "Weekly", "Monthly"])

// Watermark Background & Border Styling
showWmBg       = input.bool(false, "Enable Background Behind Watermark", group = "Watermark Styling")
wmBgColor      = input.color(color.new(color.black, 85), "Background Color", group = "Watermark Styling")
wmFrameStyle   = input.string("Grid Lines Only", "Border Mode", options = ["None", "Frame Only", "Grid Lines Only", "Frame & Grid Lines"], group = "Watermark Styling")
wmFrameColor   = input.color(color.white, "Border Color", group = "Watermark Styling")
wmBorderWidth  = input.int(2, "Border Width (px)", minval = 1, maxval = 5, group = "Watermark Styling")

//────────────────────────────────────
// MESSAGE SETTINGS
//────────────────────────────────────
showMessage    = input.bool(true, "Show Message", group = "Message Layout")
messageText    = input.text_area("FOLLOW THE PLAN\nWAIT FOR SETUP\nNO FOMO", "Text", group = "Message Layout")
messageVPos    = input.string("Top", "Vertical Alignment", options = ["Top", "Middle", "Bottom"], inline = "msgPos", group = "Message Layout")
messageHPos    = input.string("Center", "Horizontal Alignment", options = ["Left", "Center", "Right"], inline = "msgPos", group = "Message Layout")
messageSize    = input.string("large", "Text Size", options = ["tiny", "small", "normal", "large", "huge", "auto"], group = "Message Layout")
messageColor   = input.color(color.white, "Text Color", group = "Message Layout")

// Message Background & Border Styling
showMsgBg      = input.bool(true, "Enable Background Behind Message", group = "Message Styling")
msgBgColor     = input.color(color.new(color.blue, 85), "Background Color", group = "Message Styling")
msgFrameStyle  = input.string("Frame Only", "Border Mode", options = ["None", "Frame Only", "Grid Lines Only", "Frame & Grid Lines"], group = "Message Styling")
msgFrameColor  = input.color(color.white, "Border Color", group = "Message Styling")
msgBorderWidth = input.int(2, "Border Width (px)", minval = 1, maxval = 5, group = "Message Styling")

//────────────────────────────────────
// POSITION SETUP
//────────────────────────────────────
getPos(vpos, hpos) =>
    vpos == "Top" ? (hpos == "Left" ? position.top_left : hpos == "Center" ? position.top_center : position.top_right) :
     vpos == "Middle" ? (hpos == "Left" ? position.middle_left : hpos == "Center" ? position.middle_center : position.middle_right) :
     (hpos == "Left" ? position.bottom_left : hpos == "Center" ? position.bottom_center : position.bottom_right)

watermarkPos = getPos(watermarkVPos, watermarkHPos)
messagePos   = getPos(messageVPos, messageHPos)

var table watermarkTable = table.new(watermarkPos, 6, 5)

//────────────────────────────────────
// TIME FRAME FUNCTION
//────────────────────────────────────
getTimeFrame() =>
    tf = timeframe.multiplier
    tfstr = ""
    if timeframe.isseconds
        tfstr := "s"
    if timeframe.isminutes
        if tf >= 60
            tf := tf / 60
            tfstr := "h"
        else
            tfstr := "m"
    if timeframe.isdaily
        tfstr := "D"
    if timeframe.isweekly
        tfstr := "W"
    if timeframe.ismonthly
        tfstr := "M"
    [tfstr, str.tostring(tf)]

//────────────────────────────────────
// WATERMARK GENERATION
//────────────────────────────────────
if barstate.islast
    // Price change calculations
    prevDailyClose   = request.security(syminfo.tickerid, "D", close[1], lookahead = barmerge.lookahead_on)
    prevWeeklyClose  = request.security(syminfo.tickerid, "W", close[1], lookahead = barmerge.lookahead_on)
    prevMonthlyClose = request.security(syminfo.tickerid, "M", close[1], lookahead = barmerge.lookahead_on)
    
    float compareClose = na
    if changeSource == "Current TF"
        compareClose := close[1]
    else if changeSource == "Daily"
        compareClose := prevDailyClose
    else if changeSource == "Weekly"
        compareClose := prevWeeklyClose
    else
        compareClose := prevMonthlyClose

    float changePct = ((close / compareClose) - 1) * 100
    float changePts = close - compareClose

    string changeStr = ""
    string ptsSign = changePts > 0 ? "+" : ""
    
    if changeMode == "Percent Only"
        changeStr := (changePct > 0 ? "▲ " : changePct < 0 ? "▼ " : "") + str.tostring(math.abs(changePct), "#.##") + "%"
    else if changeMode == "Points Only"
        changeStr := (changePts > 0 ? "▲ " : changePts < 0 ? "▼ " : "") + ptsSign + str.tostring(changePts, "#.##")
    else
        changeStr := (changePct > 0 ? "▲ " : changePct < 0 ? "▼ " : "") + str.tostring(math.abs(changePct), "#.##") + "% (" + ptsSign + str.tostring(changePts, "#.##") + ")"

    changeCol = changePct >= 0 ? positiveColor : negativeColor

    [tf, period] = getTimeFrame()
    string baseTicker = syminfo.ticker
    if syminfo.basecurrency != "" and syminfo.currency != ""
        baseTicker := syminfo.basecurrency + separator + syminfo.currency
    string symbolText = baseTicker + (showTF ? (separator + period + tf) : "")

    // Position coordinates mapping logic
    bool doubleAbove = (showpf and exchangePos == "Above") and (showchange and changePosSel == "Above")
    
    int leftOffset = 0
    if showpf and exchangePos == "Left"
        leftOffset += 1
    if showchange and changePosSel == "Left"
        leftOffset += 1

    int titleX = leftOffset
    int titleY = doubleAbove ? 2 : 1

    int exchX = titleX
    int exchY = exchangePos == "Above" ? 0 : 1

    int chgX  = titleX
    int chgY  = changePosSel == "Above" ? 0 : (changePosSel == "Below" ? (doubleAbove ? 3 : 2) : 1)

    int signX = titleX
    int signY = signaturePos == "Below" ? (doubleAbove ? 3 : 2) : 1

    if showchange and changePosSel == "Below" and signaturePos == "Below" and not doubleAbove
        signX := titleX + 1

    if showchange and changePosSel == "Left"
        chgX := titleX - 1
        chgY := titleY
    if showpf and exchangePos == "Left"
        exchX := (showchange and changePosSel == "Left") ? titleX - 2 : titleX - 1
        exchY := titleY

    if showchange and changePosSel == "Right" and showSignature and signaturePos == "Right"
        chgX  := titleX + 1
        chgY  := titleY
        signX := titleX + 2
        signY := titleY
    else
        if showchange and changePosSel == "Right"
            chgX := titleX + 1
            chgY := titleY
        if showSignature and signaturePos == "Right"
            signX := titleX + 1
            signY := titleY

    // Calculate bounding limits
    int minX = titleX
    int maxX = titleX
    int minY = titleY
    int maxY = titleY

    if showpf
        minX := math.min(minX, exchX), maxX := math.max(maxX, exchX)
        minY := math.min(minY, exchY), maxY := math.max(maxY, exchY)
    if showchange
        minX := math.min(minX, chgX),  maxX := math.max(maxX, chgX)
        minY := math.min(minY, chgY),  maxY := math.max(maxY, chgY)
    if showSignature
        minX := math.min(minX, signX), maxX := math.max(maxX, signX)
        minY := math.min(minY, signY), maxY := math.max(maxY, signY)

    int totalCols = (maxX - minX) + 1
    int totalRows = (maxY - minY) + 1

    table.clear(watermarkTable, 0, 0, 5, 4)

    // Setup borders/frames correctly using compatible v6 table properties
    if wmFrameStyle == "Frame Only"
        table.set_frame_width(watermarkTable, wmBorderWidth)
        table.set_frame_color(watermarkTable, wmFrameColor)
        table.set_border_width(watermarkTable, 0)
    else if wmFrameStyle == "Grid Lines Only"
        table.set_frame_width(watermarkTable, 0)
        table.set_border_width(watermarkTable, wmBorderWidth)
        table.set_border_color(watermarkTable, wmFrameColor)
    else if wmFrameStyle == "Frame & Grid Lines"
        table.set_frame_width(watermarkTable, wmBorderWidth)
        table.set_frame_color(watermarkTable, wmFrameColor)
        table.set_border_width(watermarkTable, wmBorderWidth)
        table.set_border_color(watermarkTable, wmFrameColor)
    else
        table.set_frame_width(watermarkTable, 0)
        table.set_border_width(watermarkTable, 0)

    activeWmBg = showWmBg ? wmBgColor : color.new(color.black, 100)
    halign = watermarkHPos == "Left" ? text.align_left : watermarkHPos == "Center" ? text.align_center : text.align_right

    // Build uniform layout grid
    for r = 0 to totalRows - 1
        for c = 0 to totalCols - 1
            table.cell(watermarkTable, c, r, "", bgcolor = activeWmBg)

    table.cell(watermarkTable, titleX - minX, titleY - minY, symbolText, text_color = colorTitle, text_size = sizeTitle, text_halign = halign, bgcolor = activeWmBg)

    if showpf
        table.cell(watermarkTable, exchX - minX, exchY - minY, syminfo.prefix, text_color = colorExch, text_size = sizeExch, text_halign = halign, bgcolor = activeWmBg)

    if showchange
        table.cell(watermarkTable, chgX - minX, chgY - minY, changeStr, text_color = changeCol, text_size = sizeChg, text_halign = halign, bgcolor = activeWmBg)

    if showSignature
        table.cell(watermarkTable, signX - minX, signY - minY, signature, text_color = colorSign, text_size = sizeSign, text_halign = halign, bgcolor = activeWmBg)

//────────────────────────────────────
// MESSAGE GENERATION
//────────────────────────────────────
var table messageTable = table.new(messagePos, 1, 10)

if barstate.islast
    table.clear(messageTable, 0, 0, 0, 9)
    
    if showMessage
        color msgCellBg = showMsgBg ? msgBgColor : color.new(color.black, 100)
        
        string[] lines = str.split(messageText, "\n")
        int totalMsgRows = array.size(lines)
        
        if msgFrameStyle == "Frame Only"
            table.set_frame_width(messageTable, msgBorderWidth)
            table.set_frame_color(messageTable, msgFrameColor)
            table.set_border_width(messageTable, 0)
        else if msgFrameStyle == "Grid Lines Only"
            table.set_frame_width(messageTable, 0)
            table.set_border_width(messageTable, msgBorderWidth)
            table.set_border_color(messageTable, msgFrameColor)
        else if msgFrameStyle == "Frame & Grid Lines"
            table.set_frame_width(messageTable, msgBorderWidth)
            table.set_frame_color(messageTable, msgFrameColor)
            table.set_border_width(messageTable, msgBorderWidth)
            table.set_border_color(messageTable, msgFrameColor)
        else
            table.set_frame_width(messageTable, 0)
            table.set_border_width(messageTable, 0)

        for i = 0 to totalMsgRows - 1
            string currentLineText = array.get(lines, i)
            table.cell(messageTable, 0, i, currentLineText, 
                       text_color = messageColor, 
                       text_size = messageSize,
                       bgcolor = msgCellBg,
                       text_halign = text.align_center)
````
