# Options OI Profile on Futures

- url: https://www.tradingview.com/script/4jU0epAC-Options-OI-Profile-on-Futures/
- type: indicator
- pine_id: PUB;7a5752aaca554ba1a67f25d6ea6c2b17
- version: 2.0

## Description

Title: Options OI Profile on Futures (QQQ → NQ, SPY → ES)

Description:

This indicator displays ETF options open interest as a horizontal profile on index futures charts. It converts QQQ strikes to NQ prices and SPY strikes to ES prices, so options positioning can be viewed directly on the futures chart.

What it does

Large clusters of open interest at specific strikes are often watched as potential areas of interest, because market makers may hedge around them. Those strikes are quoted in ETF prices, though, which don't match futures prices. This script converts each strike to its futures equivalent using a live ratio:

Futures level = ETF strike × (futures price ÷ ETF price)

The ratio is recalculated from live prices rather than hardcoded, so levels stay aligned as the futures basis drifts toward expiration and across contract rolls. Outside regular hours, it uses extended-session ETF prices, and it holds the last valid ratio when the ETF isn't trading.

What you see

Call open interest (upper half of each strike) and put open interest (lower half), drawn as horizontal bars sized relative to the largest strike
The strikes with the most call and put open interest, highlighted as "walls" with a dotted level line and a label showing the ETF strike and converted futures price
An optional info panel showing the ETF symbol, current ratio, data date, and status. It appears automatically if something needs attention, such as missing data or levels outside the visible price range.

How to use it

Pine Script cannot download options data, so you supply it. Paste open interest into the OI data input in this format:

strike:callOI:putOI,strike:callOI:putOI,...

Example: 600:25000:60000,605:18000:22000

Open interest is published once per day, so updating the data each morning before the session is enough. Add the indicator once per chart: set the ETF input to QQQ on an NQ chart, or SPY on an ES chart. Test Mode generates sample data around the current price, so you can check the layout before adding real data.

Settings

Data: ETF symbol, OI data, data date, test mode, and an optional manual ratio
Layout: profile position (right of price or left), bar length and thickness, a filter to hide small strikes, and a redraw sensitivity setting
Walls: number of highlighted walls, line length, and labels on or off
Style: colors and info panel visibility

Performance

Drawings update on each new bar, or when levels drift beyond a set number of points, not on every tick. This keeps the chart responsive.

Limitations

Levels are only as current as the open interest data you paste in. Intraday changes in options positioning are not reflected.
The conversion assumes the ETF and futures track each other closely, which is generally true for QQQ/NQ and SPY/ES but can diverge around dividends and during fast markets.
For an accurate live ratio, both symbols need real-time data. Delayed futures data will skew the conversion.
This script shows positioning only. It does not show order book depth or resting liquidity.

This indicator is a visualization tool for analysis and education. It does not generate trade signals and is not financial advice.

Before you publish:

Clean chart: TradingView requires the publishing chart to show only this indicator, so remove your other studies first. Load real OI data, or turn on test mode, so the screenshot shows the profile.
Open or protected: choose Open source if you're fine with others seeing the code; TradingView favors open-source scripts in public listings. Choose Protected if you want to keep the code private.
Moderator review: the manual data input may get questions. The description explains why it's necessary, which is what moderators look for.

## Source Code

````pine
//@version=6
// Options OI Profile on Futures (v10 - status on top)
// Draws ETF open interest by strike as a profile on NQ / ES, converted live:
// futures level = strike * (futures price / ETF price). Analysis only - not financial advice.
indicator("Options OI Profile on Futures", shorttitle = "OI Profile", overlay = true, max_boxes_count = 500, max_lines_count = 200, max_labels_count = 200)

// ---------------- Data ----------------
etfSym      = input.symbol("BATS:QQQ", "Options ETF (QQQ for NQ, SPY for ES)", group = "Data")
oiData      = input.text_area("", "OI data (strike:callOI:putOI,...)", group = "Data")
dataDate    = input.string("", "Data date", group = "Data")
testMode    = input.bool(false, "Test mode (fake OI)", group = "Data")
useManual   = input.bool(false, "Use manual ratio", group = "Data")
manualRatio = input.float(0.0, "Manual ratio (futures / ETF)", group = "Data")

// ---------------- Layout ----------------
posMode  = input.string("Right of price", "Profile position", options = ["Right of price", "Left"], group = "Layout")
gapBars  = input.int(5, "Gap from price (bars)", minval = 0, maxval = 100, group = "Layout")
leftBack = input.int(150, "Left mode: bars back from price", minval = 20, maxval = 4000, group = "Layout")
maxLen   = input.int(30, "Longest bar (bars)", minval = 5, maxval = 150, group = "Layout")
thick    = input.float(0.7, "Bar thickness", minval = 0.1, maxval = 1.0, group = "Layout")
minPct   = input.float(10.0, "Hide strikes under % of biggest OI", minval = 0, maxval = 90, group = "Layout")
redrawPts = input.float(1.0, "Redraw when levels move more than (points)", minval = 0.25, group = "Layout")

// ---------------- Walls ----------------
topN     = input.int(2, "Highlight top N call and put walls", minval = 0, maxval = 5, group = "Walls")
lineBack = input.int(60, "Wall line length into chart (bars, 0 = off)", minval = 0, maxval = 2000, group = "Walls")
showLbl  = input.bool(true, "Show wall labels", group = "Walls")

// ---------------- Strike levels ----------------
levelStep  = input.int(1, "Strike labels every $ (0 = off)", minval = 0, maxval = 50, group = "Strike levels")
levelLines = input.bool(false, "Faint line at each labeled strike", group = "Strike levels")
levelCol   = input.color(color.new(color.gray, 20), "Strike label color", group = "Strike levels")

// ---------------- Style ----------------
callCol     = input.color(color.new(color.teal, 75), "Call OI", group = "Style")
putCol      = input.color(color.new(color.red, 75), "Put OI", group = "Style")
callWallCol = input.color(color.new(color.teal, 15), "Call wall", group = "Style")
putWallCol  = input.color(color.new(color.red, 15), "Put wall", group = "Style")
showPanel   = input.bool(false, "Always show info panel", group = "Style")
panelPos    = input.string("Bottom right", "Panel position", options = ["Top left", "Top center", "Top right", "Middle left", "Middle center", "Middle right", "Bottom left", "Bottom center", "Bottom right"], group = "Style")
panelSize   = input.string("Small", "Panel text size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = "Style")
labelSize   = input.string("Small", "Label text size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = "Style")

tblPos = switch panelPos
    "Top left" => position.top_left
    "Top center" => position.top_center
    "Top right" => position.top_right
    "Middle left" => position.middle_left
    "Middle center" => position.middle_center
    "Middle right" => position.middle_right
    "Bottom left" => position.bottom_left
    "Bottom center" => position.bottom_center
    => position.bottom_right

tblSize = switch panelSize
    "Tiny" => size.tiny
    "Normal" => size.normal
    "Large" => size.large
    "Huge" => size.huge
    => size.small

lblSize = switch labelSize
    "Tiny" => size.tiny
    "Normal" => size.normal
    "Large" => size.large
    "Huge" => size.huge
    => size.small

// ---------------- Live ratio ----------------
etfTicker = ticker.new(syminfo.prefix(etfSym), syminfo.ticker(etfSym), session.extended)
etfGap = request.security(etfTicker, timeframe.period, close, gaps = barmerge.gaps_on)
etfAny = request.security(etfTicker, timeframe.period, close)
var float liveRatio = na
if not na(etfGap) and etfGap > 0
    liveRatio := close / etfGap
float fallbackRatio = not na(etfAny) and etfAny > 0 ? close / etfAny : na
float autoRatio = not na(liveRatio) ? liveRatio : fallbackRatio
float r = useManual and manualRatio > 0 ? manualRatio : autoRatio

hiRange = ta.highest(high, 300)
loRange = ta.lowest(low, 300)

// ---------------- Drawing (only once per bar = no lag) ----------------
var array<box>   boxes  = array.new<box>()
var array<line>  lines  = array.new<line>()
var array<label> labels = array.new<label>()
var table info = table.new(tblPos, 2, 5, bgcolor = color.new(color.black, 60))

var float drawnR = na
var string status = "OK"
ratioMoved = not na(r) and not na(drawnR) and not na(etfAny) and math.abs(r - drawnR) * etfAny > redrawPts
doDraw = barstate.islastconfirmedhistory or (barstate.isrealtime and (barstate.isnew or ratioMoved))

if doDraw
    drawnR := r
    for b in boxes
        box.delete(b)
    boxes.clear()
    for l in lines
        line.delete(l)
    lines.clear()
    for lb in labels
        label.delete(lb)
    labels.clear()

    strikes = array.new<float>()
    calls   = array.new<float>()
    puts    = array.new<float>()

    if testMode
        if not na(etfAny)
            base = math.round(etfAny)
            for j = -12 to 12
                bigC = j >= 0 and j % 4 == 0
                bigP = j <= 0 and j % 4 == 0
                strikes.push(float(base + j))
                calls.push(bigC ? 50000.0 : j >= 0 ? 9000.0 : 3000.0)
                puts.push(bigP ? 50000.0 : j <= 0 ? 9000.0 : 3000.0)
    else
        for item in str.split(oiData, ",")
            parts = str.split(str.trim(item), ":")
            if parts.size() >= 3
                s = str.tonumber(str.trim(parts.get(0)))
                if not na(s)
                    strikes.push(s)
                    calls.push(nz(str.tonumber(str.trim(parts.get(1)))))
                    puts.push(nz(str.tonumber(str.trim(parts.get(2)))))

    n = strikes.size()
    int inRange = 0
    status := "OK"

    if na(r)
        status := "No ratio - check ETF symbol"
    else if n == 0
        status := "Paste OI data in settings"
    else
        maxOI = math.max(calls.max(), puts.max())
        minOI = maxOI * minPct / 100

        float step = 1.0
        if n > 1
            sorted = strikes.copy()
            sorted.sort()
            step := na
            for i = 1 to n - 1
                d = sorted.get(i) - sorted.get(i - 1)
                if d > 0 and (na(step) or d < step)
                    step := d
            step := nz(step, 1.0)
        halfH = step * r * thick / 2

        // Mark the top N walls on each side
        isCWall = array.new<bool>(n, false)
        isPWall = array.new<bool>(n, false)
        if topN > 0
            cIdx = calls.sort_indices(order.descending)
            pIdx = puts.sort_indices(order.descending)
            for k = 0 to math.min(topN, n) - 1
                isCWall.set(cIdx.get(k), true)
                isPWall.set(pIdx.get(k), true)

        isRight = posMode == "Right of price"
        x0 = isRight ? bar_index + gapBars : math.max(0, bar_index - leftBack)
        lblX = x0 + maxLen + 2
        lineStart = isRight ? math.max(0, bar_index - lineBack) : x0
        lineEnd = isRight ? x0 : bar_index

        for i = 0 to n - 1
            y  = strikes.get(i) * r
            c  = calls.get(i)
            p  = puts.get(i)
            cw = isCWall.get(i)
            pw = isPWall.get(i)
            if y >= loRange and y <= hiRange
                inRange += 1
            cLen = maxOI > 0 ? math.max(1, int(math.round(c / maxOI * maxLen))) : 1
            pLen = maxOI > 0 ? math.max(1, int(math.round(p / maxOI * maxLen))) : 1
            if c >= minOI or cw
                boxes.push(box.new(x0, y + halfH, x0 + cLen, y, xloc = xloc.bar_index, bgcolor = cw ? callWallCol : callCol, border_width = 0))
            if p >= minOI or pw
                boxes.push(box.new(x0, y, x0 + pLen, y - halfH, xloc = xloc.bar_index, bgcolor = pw ? putWallCol : putCol, border_width = 0))
            if cw or pw
                wallCol = cw ? callWallCol : putWallCol
                if lineBack > 0
                    lines.push(line.new(lineStart, y, lineEnd, y, xloc = xloc.bar_index, color = wallCol, style = line.style_dotted, width = 1))
                if showLbl
                    tag = cw and pw ? "C+P " : cw ? "C " : "P "
                    labels.push(label.new(lblX, y, tag + str.tostring(strikes.get(i)) + "  " + str.tostring(y, "#.##"), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.new(wallCol, 0), size = lblSize))
            else if levelStep > 0
                k2 = strikes.get(i) / levelStep
                if math.abs(k2 - math.round(k2)) < 0.001
                    labels.push(label.new(lblX, y, str.tostring(strikes.get(i)) + "  " + str.tostring(y, "#.##"), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.black, 100), textcolor = levelCol, size = lblSize))
                    if levelLines
                        lines.push(line.new(lineStart, y, lineEnd, y, xloc = xloc.bar_index, color = color.new(levelCol, 70), style = line.style_dotted, width = 1))

        if inRange == 0
            status := "Off-screen: levels " + str.tostring(strikes.min() * r, "#") + " - " + str.tostring(strikes.max() * r, "#")

// ---------------- Info panel (live, every tick) ----------------
if barstate.islast
    if showPanel or status != "OK"
        dateText = testMode ? "TEST DATA" : dataDate == "" ? "-" : dataDate
        table.cell(info, 0, 0, "Status", text_color = color.white, text_size = tblSize)
        table.cell(info, 1, 0, status, text_color = status == "OK" ? color.lime : color.orange, text_size = tblSize)
        table.cell(info, 0, 1, syminfo.ticker(etfSym) + " price", text_color = color.white, text_size = tblSize)
        table.cell(info, 1, 1, na(etfAny) ? "none" : str.tostring(etfAny, "#.##"), text_color = color.white, text_size = tblSize)
        table.cell(info, 0, 2, syminfo.ticker + " price", text_color = color.white, text_size = tblSize)
        table.cell(info, 1, 2, str.tostring(close, format.mintick), text_color = color.white, text_size = tblSize)
        table.cell(info, 0, 3, "Ratio", text_color = color.white, text_size = tblSize)
        table.cell(info, 1, 3, na(r) ? "none" : str.tostring(r, "#.####"), text_color = color.white, text_size = tblSize)
        table.cell(info, 0, 4, "OI date", text_color = color.white, text_size = tblSize)
        table.cell(info, 1, 4, dateText, text_color = color.white, text_size = tblSize)
    else
        table.clear(info, 0, 0, 1, 4)
````
