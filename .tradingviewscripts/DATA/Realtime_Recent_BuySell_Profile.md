<!-- tradingview-pine-id: PUB;0b142821b3184cdfb271106a2e05c9b1 -->
<!-- tradingviewscripts-format: 1 -->
# Realtime Recent Buy/Sell Profile

Source: https://www.tradingview.com/script/Eb57Hpn9-Realtime-Recent-Buy-Sell-Profile/

## Description

Shows to the right of the current candle the real time buys and sells. The volume bars are proportional to the amount bought and sold. the width is adjustable. Based on the tape script.

---

## Source Code

````pine
//@version=6
indicator("Realtime Recent Buy/Sell Profile", shorttitle = "Realtime Tape Profile", overlay = true, max_lines_count = 500)

//──────────────────────────────────────────────────────────────────────────────
// Inputs
//──────────────────────────────────────────────────────────────────────────────

string GP1 = "Profile"

int recentUpdates = input.int(200, "Recent tape updates retained", minval = 10, maxval = 2000, group = GP1)
int ticksPerRow = input.int(1, "Ticks per price row", minval = 1, maxval = 100, group = GP1)
int maximumRows = input.int(120, "Maximum price rows displayed", minval = 10, maxval = 240, group = GP1)

float widthPercent = input.float(30.0, "Maximum width as % of visible chart", minval = 2.5, maxval = 50.0, step = 1.0, group = GP1)
int gapAfterLatestBar = input.int(1, "Gap after latest candle in bars", minval = 0, maxval = 50, group = GP1)

float minimumUpdateVolume = input.float(0.0, "Ignore updates below volume", minval = 0.0, group = GP1)

// Default height is now 1 pixel.
int profileThickness = input.int(1, "Histogram bar height", minval = 1, maxval = 10, group = GP1, tooltip = "Controls the vertical thickness of each horizontal buy/sell volume bar in pixels.")

color buyColour = input.color(color.new(color.green, 10), "Buy volume", inline = "C1", group = GP1)
color sellColour = input.color(color.new(color.red, 10), "Sell volume", inline = "C1", group = GP1)

//──────────────────────────────────────────────────────────────────────────────
// Realtime tape-event storage
//──────────────────────────────────────────────────────────────────────────────

varip array<int> eventPriceTicks = array.new_int()
varip array<float> eventVolumes = array.new_float()
varip array<bool> eventDirections = array.new_bool()

varip array<int> rowPriceTicks = array.new_int()
varip array<float> rowBuyVolumes = array.new_float()
varip array<float> rowSellVolumes = array.new_float()

varip bool realtimeInitialised = false
varip float previousBarVolume = 0.0
varip int previousPriceTick = na
varip bool previousDirectionUp = false

var array<line> buyLines = array.new_line()
var array<line> sellLines = array.new_line()

//──────────────────────────────────────────────────────────────────────────────
// Functions
//──────────────────────────────────────────────────────────────────────────────

f_trimEvents() =>
    while array.size(eventPriceTicks) > recentUpdates
        array.shift(eventPriceTicks)
        array.shift(eventVolumes)
        array.shift(eventDirections)

f_rebuildRows() =>
    array.clear(rowPriceTicks)
    array.clear(rowBuyVolumes)
    array.clear(rowSellVolumes)

    int eventCount = array.size(eventPriceTicks)

    if eventCount > 0
        for offset = 0 to eventCount - 1
            int eventIndex = eventCount - 1 - offset
            int rawPriceTick = array.get(eventPriceTicks, eventIndex)
            int groupedPriceTick = int(math.round(float(rawPriceTick) / float(ticksPerRow))) * ticksPerRow
            float updateVolume = array.get(eventVolumes, eventIndex)
            bool updateIsBuy = array.get(eventDirections, eventIndex)

            int rowIndex = array.indexof(rowPriceTicks, groupedPriceTick)

            if rowIndex == -1
                if array.size(rowPriceTicks) < maximumRows
                    array.push(rowPriceTicks, groupedPriceTick)
                    array.push(rowBuyVolumes, updateIsBuy ? updateVolume : 0.0)
                    array.push(rowSellVolumes, updateIsBuy ? 0.0 : updateVolume)
            else
                if updateIsBuy
                    array.set(rowBuyVolumes, rowIndex, array.get(rowBuyVolumes, rowIndex) + updateVolume)
                else
                    array.set(rowSellVolumes, rowIndex, array.get(rowSellVolumes, rowIndex) + updateVolume)

f_hideLine(line profileLine, int anchorTime) =>
    line.set_xy1(profileLine, anchorTime, close)
    line.set_xy2(profileLine, anchorTime, close)
    line.set_color(profileLine, color.new(color.gray, 100))
    line.set_width(profileLine, 1)

//──────────────────────────────────────────────────────────────────────────────
// Create persistent lines
//──────────────────────────────────────────────────────────────────────────────

if barstate.isfirst
    for rowIndex = 0 to maximumRows - 1
        line buyLine = line.new(time, close, time, close, xloc = xloc.bar_time, extend = extend.none, color = color.new(buyColour, 100), width = profileThickness)
        line sellLine = line.new(time, close, time, close, xloc = xloc.bar_time, extend = extend.none, color = color.new(sellColour, 100), width = profileThickness)

        array.push(buyLines, buyLine)
        array.push(sellLines, sellLine)

//──────────────────────────────────────────────────────────────────────────────
// Capture every new realtime price/volume update
//──────────────────────────────────────────────────────────────────────────────

if barstate.isrealtime
    int currentPriceTick = int(math.round(close / syminfo.mintick))

    if not realtimeInitialised
        previousBarVolume := nz(volume)
        previousPriceTick := currentPriceTick
        previousDirectionUp := close >= open
        realtimeInitialised := true
    else
        if barstate.isnew
            previousBarVolume := 0.0

        float newVolume = math.max(nz(volume) - previousBarVolume, 0.0)
        bool directionUp = previousDirectionUp

        if currentPriceTick > previousPriceTick
            directionUp := true
        else if currentPriceTick < previousPriceTick
            directionUp := false

        // Unchanged prices retain the preceding tape direction.
        if newVolume > 0 and newVolume >= minimumUpdateVolume
            array.push(eventPriceTicks, currentPriceTick)
            array.push(eventVolumes, newVolume)
            array.push(eventDirections, directionUp)
            f_trimEvents()

        previousBarVolume := nz(volume)
        previousPriceTick := currentPriceTick
        previousDirectionUp := directionUp

    f_rebuildRows()

//──────────────────────────────────────────────────────────────────────────────
// Visible chart and positioning
//──────────────────────────────────────────────────────────────────────────────

int visibleLeftTime = chart.left_visible_bar_time
int visibleRightTime = chart.right_visible_bar_time

float chartSeconds = timeframe.in_seconds()
int barDurationMs = not na(chartSeconds) ? math.max(1000, int(math.round(chartSeconds * 1000.0))) : math.max(1000, time_close - time)

int fallbackSpan = barDurationMs * 100
int visibleSpan = math.max(fallbackSpan, visibleRightTime - visibleLeftTime)

int maximumProfileWidth = math.max(1, int(math.round(float(visibleSpan) * widthPercent / 100.0)))

int latestCandleRightTime = not na(time_close) ? time_close : time + barDurationMs

// The common left edge begins beyond the latest candle.
int profileLeftTime = latestCandleRightTime + barDurationMs * gapAfterLatestBar

//──────────────────────────────────────────────────────────────────────────────
// Redraw on every realtime execution
//──────────────────────────────────────────────────────────────────────────────

if barstate.islast
    int rowCount = array.size(rowPriceTicks)
    float maximumTotalVolume = 0.0

    if rowCount > 0
        for rowIndex = 0 to rowCount - 1
            float totalVolume = array.get(rowBuyVolumes, rowIndex) + array.get(rowSellVolumes, rowIndex)
            maximumTotalVolume := math.max(maximumTotalVolume, totalVolume)

    for lineIndex = 0 to maximumRows - 1
        line buyLine = array.get(buyLines, lineIndex)
        line sellLine = array.get(sellLines, lineIndex)

        if lineIndex < rowCount and maximumTotalVolume > 0
            int priceTick = array.get(rowPriceTicks, lineIndex)

            // The horizontal bar is drawn at the recorded price point.
            float rowPrice = float(priceTick) * syminfo.mintick

            float buyVolume = array.get(rowBuyVolumes, lineIndex)
            float sellVolume = array.get(rowSellVolumes, lineIndex)
            float totalVolume = buyVolume + sellVolume

            int totalWidth = math.max(1, int(math.round(totalVolume / maximumTotalVolume * maximumProfileWidth)))
            int buyWidth = totalVolume > 0 ? int(math.round(float(totalWidth) * buyVolume / totalVolume)) : 0
            int sellWidth = totalWidth - buyWidth

            // Bars grow from left to right.
            int buyLeftTime = profileLeftTime
            int buyRightTime = buyLeftTime + buyWidth

            int sellLeftTime = buyRightTime
            int sellRightTime = sellLeftTime + sellWidth

            if buyWidth > 0
                line.set_xy1(buyLine, buyLeftTime, rowPrice)
                line.set_xy2(buyLine, buyRightTime, rowPrice)
                line.set_color(buyLine, buyColour)
                line.set_width(buyLine, profileThickness)
            else
                f_hideLine(buyLine, profileLeftTime)

            if sellWidth > 0
                line.set_xy1(sellLine, sellLeftTime, rowPrice)
                line.set_xy2(sellLine, sellRightTime, rowPrice)
                line.set_color(sellLine, sellColour)
                line.set_width(sellLine, profileThickness)
            else
                f_hideLine(sellLine, profileLeftTime)
        else
            f_hideLine(buyLine, profileLeftTime)
            f_hideLine(sellLine, profileLeftTime)
````
