# Volume Map

- url: https://www.tradingview.com/script/tNoemECq-Volume-Map/
- type: indicator
- pine_id: PUB;7a0d52a53fec4427a2e0655f40b4ff1e
- version: 1.0

## Description

Volume Map is a volume profile that shows the price levels where trading activity was concentrated within the selected market range.
The indicator distributes historical candle volume across horizontal price rows and identifies three key reference levels:
🔴 Resistance — the upper boundary of the calculated balance area.
🟡 Balance — the price row with the highest calculated volume.
🟢 Support — the lower boundary of the calculated balance area.
The profile, levels, and information dashboard are all generated from one unified volume-distribution model. They are not separate indicators mechanically combined to create additional signals.
The horizontal profile displays the full volume distribution, the levels identify its key boundaries, and the dashboard translates the same calculations into a clear and accessible market context.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚙️ ORIGINAL CALCULATION METHOD
The main feature of this implementation is the way each candle’s volume is distributed across price rows.
A single candle may cross several price levels. Instead of adding the entire candle volume to every crossed row, Volume Map measures the actual overlap between the candle’s range and each price row.
The volume allocated to a specific row is proportional to:
the row’s overlap with the candle / the candle’s full range
For example, if a price row covers 20% of the candle’s full high-to-low range, that row receives approximately 20% of the candle’s volume.
This approach:
• preserves the candle’s total volume within the profile;
• avoids repeatedly counting the full candle volume at multiple price levels;
• provides a more precise approximation of how available OHLCV volume is distributed within the candle’s range.
When a candle has no measurable difference between its high and low, its volume is assigned to the row containing the closing price.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🟡 HOW BALANCE IS DETERMINED
Balance represents the price row with the highest calculated concentration of volume.
When several rows have the same maximum volume, the indicator calculates the volume-weighted centroid of the entire profile and selects the maximum-volume row located closest to that centroid.
This rule connects Balance to the broader volume distribution and avoids automatically selecting the first maximum found in the profile.
Balance can be viewed as a statistical reference for the area of value within the selected range.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔵 HOW THE BALANCE AREA IS FORMED
The Balance Zone Size setting determines what percentage of the profile’s total volume must be contained between Support and Resistance.
The default value is 68%.
The script searches for the narrowest continuous group of price rows that:
• contains the Balance row;
• includes at least the selected percentage of total volume;
• remains continuous between its lower and upper boundaries.
When two possible ranges have the same width, the script selects the one whose center is located closest to Balance.
The balance area does not have to be symmetrical. When more volume is concentrated above or below the Balance row, one side of the area may extend noticeably farther than the other.
This reflects the actual calculated volume distribution instead of artificially centering the boundaries around Balance.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎨 PROFILE COLOR LOGIC
The horizontal profile uses three visual states:
🔵 Blue rows — volume included in the calculated balance area.
⚫ Gray rows — volume located outside the balance area.
🟡 Yellow row — the Balance level.
The width of each row represents its calculated volume relative to the highest-volume row in the profile.
The wider the row, the greater the volume concentration at that price level within the analyzed range.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📍 KEY REFERENCE LEVELS
🟡 BALANCE
Balance is the row with the highest calculated volume in the profile.
It can be used as a statistical reference for the area of value and as a central point for evaluating the current price location.
🔴 RESISTANCE
Resistance is the upper boundary of the balance area.
This level does not mean that price must reverse. It identifies the price where the selected concentration of volume ends on the upper side of the profile.
🟢 SUPPORT
Support is the lower boundary of the balance area.
It is a statistical boundary of the calculated area of value, not a guaranteed support level.
The names Support and Resistance are used to make the profile easier to understand. Both levels are calculated from volume distribution rather than from:
• local highs and lows;
• moving averages;
• traditional pivot levels;
• trend lines.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔗 WHY THESE COMPONENTS ARE COMBINED IN ONE INDICATOR
Volume Map contains three connected components:
1. Horizontal profile
Displays the full calculated volume distribution across price levels.
2. Support, Balance, and Resistance levels
Identify the highest concentration of volume and the boundaries of the balance area.
3. Beginner Dashboard
Explains the current price location relative to the same calculated levels.
The dashboard does not calculate a separate trend, momentum, or trading signal.
Every value displayed in the dashboard is derived directly from:
• the current price;
• Balance;
• Support;
• Resistance.
The purpose of combining these components is to make one volume-distribution calculation useful both for experienced volume-profile users and for traders who prefer a simpler and clearer summary.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧭 BEGINNER DASHBOARD
Market
Shows whether the current price is above or below Balance.
🟢 Above — price is above Balance.
🔴 Below — price is below Balance.
This describes the location of price. It is not a prediction of future upward or downward movement.
Price
Shows the current price location relative to the entire balance area.
• Above map — price is above Resistance.
• Upper — price is between Balance and Resistance.
• Balance — price is at the Balance level.
• Lower — price is between Support and Balance.
• Below map — price is below Support.
Zone
Shows the nearest significant profile level while price remains inside the balance area:
🔴 Resistance
🟡 Balance
🟢 Support
When price is above Resistance or below Support, the dashboard displays Outside.
Tip
Provides a brief description of the current price location:
• Above resistance — price is above Resistance;
• Above balance — price is above Balance;
• At balance — price is at Balance;
• Below balance — price is below Balance;
• Below support — price is below Support.
The Tip row is descriptive only and does not represent a buy or sell signal.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🛠️ SETTINGS
Use Visible Range
When enabled, the script builds the profile from the chart range currently visible to the user.
Changing the chart scale or moving the visible range may change the calculated profile and levels.
When disabled, the script uses the fixed number of candles selected in Lookback Bars.
Lookback Bars
Defines the number of recent candles used in the calculation when Use Visible Range is disabled.
• A larger value includes more historical data.
• A smaller value makes the profile more responsive to recent price action.
Profile Detail
Controls the number of horizontal price rows.
• Higher values provide finer price resolution but require more calculations.
• Lower values produce a simpler and smoother profile.
Profile Bar Thickness
Controls the visual thickness of the horizontal rows.
This setting does not affect the calculations.
Profile Width
Controls the maximum horizontal width of the profile relative to the number of analyzed candles.
This setting affects presentation only.
Right Offset
Controls the distance between the latest candle and the profile.
Balance Zone Size
Defines the percentage of total profile volume that must be included between Support and Resistance.
• A higher value usually creates a wider balance area.
• A lower value creates a narrower balance area.
Volume Type
• Both — includes all qualifying candles.
• Bullish — includes candles whose closing price is greater than or equal to their opening price.
• Bearish — includes candles whose closing price is below their opening price.
Bullish and Bearish modes classify the entire volume of a candle according to the candle’s direction.
They do not represent actual buy and sell volume, bid/ask volume, order-flow delta, or the precise distribution of aggressive market orders.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📈 HOW TO USE THE INDICATOR
Start with the default settings and observe how price behaves around Balance, Support, and Resistance.
Price inside the balance area
When price is between Support and Resistance, the profile indicates that a significant share of the analyzed volume was concentrated within this range.
Balance can be used as a reference for analyzing:
• price rotation within the area of value;
• mean-reversion behavior;
• price reactions around the area of maximum volume concentration.
Price above Resistance or below Support
When price moves outside the balance area, traders can observe:
• whether price is being accepted outside the area;
• whether price remains outside the area of value;
• whether price returns toward Balance.
The profile may also help identify:
• high-volume areas that price may revisit repeatedly;
• low-volume transitions where less trading activity was previously concentrated;
• changes in the area of value when the profile is calculated over a different range;
• differences between short-term and long-term volume distributions.
Volume Map does not determine trend direction and does not generate predefined:
• entry points;
• exit points;
• stop-loss levels;
• profit targets.
The indicator can be used together with the trader’s own market-structure, trend-direction, and risk-management process.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 REAL-TIME BEHAVIOR
The profile is calculated in real time using the selected market range.
Its values may change when:
• the current candle’s high, low, or volume changes;
• a new candle enters the fixed calculation range;
• an older candle leaves the calculation range;
• the visible chart range changes;
• the timeframe, symbol, or settings are changed.
This recalculation is normal behavior for a volume profile based on a changing market range.
The script does not request future data and does not use lookahead calculations.
However, levels calculated using the active candle may continue to change until that candle closes.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ LIMITATIONS
Volume Map uses the volume data supplied by TradingView’s chart data source.
Results may be less informative for instruments with:
• unavailable volume data;
• synthetic volume;
• incomplete volume data;
• decentralized volume.
The script estimates the distribution of volume within each candle using the candle’s high-to-low range.
Standard chart data does not contain the exact sequence of every transaction at each price level inside a historical candle.
The profile is therefore an approximation based on the available OHLCV data.
It is not an exchange-level profile calculated from every individual trade or tick.
Support, Balance, and Resistance describe the selected historical range. They do not guarantee a future price reaction and should not be treated as standalone trading instructions.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎓 IMPORTANT
Volume Map is designed for analytical and educational purposes.
The indicator does not constitute financial advice, does not promise a particular outcome, and does not replace independent analysis or risk management.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarketStructureLab
// Volume Map — developed by MarketStructureLab.

//@version=6
indicator(
     title = "MarketStructureLab - Volume Map",
     shorttitle = "MSL VolMap",
     overlay = true,
     max_bars_back = 5000,
     max_lines_count = 500,
     max_labels_count = 50
)

//==================================================================================================
// INPUTS
//==================================================================================================

groupRange   = "1. Market Range"
groupProfile = "2. Volume Map"
groupLevels  = "3. Friendly Levels"
groupTable   = "4. Beginner Dashboard"

useVisibleRange = input.bool(
     defval = false,
     title = "Use Visible Range",
     group = groupRange,
     tooltip = "On: the Volume Map follows the visible chart range. Off: the selected number of Lookback Bars is used."
)

lookbackInput = input.int(
     defval = 200,
     minval = 10,
     maxval = 3000,
     title = "Lookback Bars",
     group = groupRange,
     tooltip = "Number of historical bars used to calculate the Volume Map."
)

rowCount = input.int(
     defval = 160,
     minval = 20,
     maxval = 490,
     title = "Profile Detail",
     group = groupProfile,
     tooltip = "Number of price rows used to build the profile. Higher values provide more detail."
)

rowThickness = input.int(
     defval = 1,
     minval = 1,
     maxval = 10,
     title = "Profile Bar Thickness",
     group = groupProfile,
     tooltip = "Pixel thickness of each horizontal volume row."
)

profileWidthPercent = input.int(
     defval = 22,
     minval = 1,
     maxval = 50,
     title = "Profile Width",
     group = groupProfile,
     tooltip = "Maximum profile width as a percentage of the analysed bars."
)

rightOffset = input.int(
     defval = 70,
     minval = 0,
     maxval = 400,
     title = "Right Offset",
     group = groupProfile,
     tooltip = "Distance between the latest candle and the Volume Map."
)

volumeFilter = input.string(
     defval = "Both",
     title = "Volume Type",
     options = ["Both", "Bullish", "Bearish"],
     group = groupProfile,
     tooltip = "Both uses all candles. Bullish uses bullish candles only. Bearish uses bearish candles only."
)

balancePercent = input.int(
     defval = 68,
     minval = 5,
     maxval = 95,
     title = "Balance Zone Size (%)",
     group = groupProfile,
     tooltip = "Percentage of total profile volume included in the balance zone."
)

showProfile = input.bool(
     defval = true,
     title = "Show Volume Map",
     group = groupProfile
)

showLevels = input.bool(
     defval = true,
     title = "Show Support / Balance / Resistance",
     group = groupLevels
)

showLevelLabels = input.bool(
     defval = true,
     title = "Show Friendly Labels",
     group = groupLevels
)

showDashboard = input.bool(
     defval = true,
     title = "Show Beginner Dashboard",
     group = groupTable
)

showTip = input.bool(
     defval = true,
     title = "Show Simple Tip",
     group = groupTable
)

//==================================================================================================
// COLORS
//==================================================================================================

color profileColor     = color.new(color.rgb(90, 96, 110), 62)
color balanceAreaColor = color.new(color.rgb(32, 113, 255), 20)

color resistanceColor = color.rgb(235, 55, 65)
color balanceColor    = color.rgb(255, 185, 35)
color supportColor    = color.rgb(0, 205, 160)

color dashboardHeader = color.new(color.rgb(20, 24, 31), 8)
color dashboardCell   = color.new(color.rgb(30, 34, 43), 0)
color outsideColor    = color.new(color.rgb(90, 96, 110), 15)

color mainTextColor  = color.white
color mutedTextColor = color.rgb(190, 195, 205)
color hiddenColor    = color.new(color.black, 100)

//==================================================================================================
// MARKET RANGE
//==================================================================================================

float timeframeSeconds = nz(timeframe.in_seconds(), 1.0)

int timeframeMilliseconds = int(
     math.max(
         timeframeSeconds * 1000.0,
         1.0
     )
)

int rawVisibleBars = int(
     math.round(
         (last_bar_time - chart.left_visible_bar_time) /
         timeframeMilliseconds
     )
)

int visibleBarsEstimate = math.max(
     10,
     nz(rawVisibleBars, lookbackInput)
)

int requestedBars = useVisibleRange ? visibleBarsEstimate : lookbackInput

int activeBars = math.max(
     1,
     math.min(
         math.min(requestedBars, 3000),
         bar_index + 1
     )
)

float rangeHigh = ta.highest(high, activeBars)
float rangeLow  = ta.lowest(low, activeBars)
float rangeSize = rangeHigh - rangeLow
float rowHeight = rangeSize / math.max(rowCount, 1)

//==================================================================================================
// OBJECTS AND DATA
//==================================================================================================

var line balanceLine    = na
var line resistanceLine = na
var line supportLine    = na

var label resistanceLabel = na
var label balanceLabel    = na
var label supportLabel    = na

var table dashboard = table.new(
     position.top_right,
     2,
     6,
     border_width = 1
)

var array<line> profileRows = array.new_line()

var array<float> rowVolumes = array.new_float(
     rowCount,
     0.0
)

//==================================================================================================
// PROFILE ENGINE
//==================================================================================================

clampRow(int row) =>
    math.max(
         0,
         math.min(rowCount - 1, row)
    )

rowPrice(int row) =>
    rangeLow + rowHeight * (row + 0.5)

acceptCandle(int offset) =>
    bool bullish = close[offset] >= open[offset]

    volumeFilter == "Both" or
     (volumeFilter == "Bullish" and bullish) or
     (volumeFilter == "Bearish" and not bullish)

// Each candle's volume is distributed proportionally across
// only the price rows actually crossed by that candle.

buildVolumeMap() =>
    array.fill(rowVolumes, 0.0)

    if rowHeight > 0.0
        for offset = 0 to activeBars - 1
            float candleVolume = nz(volume[offset], 0.0)

            if candleVolume > 0.0 and acceptCandle(offset)
                float candleLow   = low[offset]
                float candleHigh  = high[offset]
                float candleRange = candleHigh - candleLow

                if candleRange <= 0.0
                    int singleRow = clampRow(
                         int(
                             math.floor(
                                 (close[offset] - rangeLow) /
                                 rowHeight
                             )
                         )
                    )

                    float storedVolume = array.get(
                         rowVolumes,
                         singleRow
                    )

                    array.set(
                         rowVolumes,
                         singleRow,
                         storedVolume + candleVolume
                    )

                else
                    int firstRow = clampRow(
                         int(
                             math.floor(
                                 (candleLow - rangeLow) /
                                 rowHeight
                             )
                         )
                    )

                    int lastRow = clampRow(
                         int(
                             math.floor(
                                 (candleHigh - rangeLow) /
                                 rowHeight
                             )
                         )
                    )

                    for row = firstRow to lastRow
                        float binLow = rangeLow + rowHeight * row

                        float binHigh = row == rowCount - 1 ?
                             rangeHigh :
                             binLow + rowHeight

                        float overlap = math.max(
                             0.0,
                             math.min(candleHigh, binHigh) -
                             math.max(candleLow, binLow)
                        )

                        if overlap > 0.0
                            float allocatedVolume =
                                 candleVolume *
                                 overlap /
                                 candleRange

                            float storedVolume = array.get(
                                 rowVolumes,
                                 row
                            )

                            array.set(
                                 rowVolumes,
                                 row,
                                 storedVolume + allocatedVolume
                            )

// Finds the highest-volume row.
// If several rows share the maximum, the one closest
// to the profile volume centroid becomes Balance.

findBalanceRow() =>
    float totalVolume  = 0.0
    float weightedRows = 0.0
    float peakVolume   = 0.0

    for row = 0 to rowCount - 1
        float currentVolume = array.get(
             rowVolumes,
             row
        )

        totalVolume  += currentVolume
        weightedRows += currentVolume * row

        peakVolume := math.max(
             peakVolume,
             currentVolume
        )

    float volumeCentroid = totalVolume > 0.0 ?
         weightedRows / totalVolume :
         (rowCount - 1) * 0.5

    int balanceRow = clampRow(
         int(
             math.round(volumeCentroid)
         )
    )

    float closestDistance = 1000000.0

    if peakVolume > 0.0
        for row = 0 to rowCount - 1
            float currentVolume = array.get(
                 rowVolumes,
                 row
            )

            if currentVolume == peakVolume
                float distance = math.abs(
                     row - volumeCentroid
                )

                if distance < closestDistance
                    closestDistance := distance
                    balanceRow := row

    [balanceRow, peakVolume, totalVolume]

// Finds the narrowest continuous range that contains
// Balance and the selected percentage of total volume.

findBalanceBand(int balanceRow, float totalVolume) =>
    int bestLow  = balanceRow
    int bestHigh = balanceRow
    int bestSpan = rowCount + 1

    float targetVolume =
         totalVolume *
         balancePercent /
         100.0

    if targetVolume > 0.0
        int left = 0
        float windowVolume = 0.0

        for right = 0 to rowCount - 1
            windowVolume += array.get(
                 rowVolumes,
                 right
            )

            if right >= balanceRow
                while left < balanceRow and windowVolume - array.get(rowVolumes, left) >= targetVolume
                    windowVolume -= array.get(
                         rowVolumes,
                         left
                    )

                    left += 1

                if windowVolume >= targetVolume
                    int span = right - left

                    float candidateCenterDistance = math.abs(
                         (left + right) * 0.5 -
                         balanceRow
                    )

                    float bestCenterDistance = math.abs(
                         (bestLow + bestHigh) * 0.5 -
                         balanceRow
                    )

                    if span < bestSpan or
                         (span == bestSpan and candidateCenterDistance < bestCenterDistance)

                        bestSpan := span
                        bestLow  := left
                        bestHigh := right

    [bestLow, bestHigh]

profileLength(float rowVolume, float peakVolume) =>
    int maximumWidth = math.max(
         1,
         int(
             math.round(
                 activeBars *
                 profileWidthPercent /
                 100.0
             )
         )
    )

    peakVolume > 0.0 ?
         math.max(
             0,
             int(
                 math.round(
                     maximumWidth *
                     rowVolume /
                     peakVolume
                 )
             )
         ) :
         0

//==================================================================================================
// DASHBOARD LOGIC
//==================================================================================================

pricePosition(
     float price,
     float support,
     float balance,
     float resistance
) =>
    string result = "Balance"

    if price > resistance
        result := "Above map"

    else if price < support
        result := "Below map"

    else if price > balance
        result := "Upper"

    else if price < balance
        result := "Lower"

    result

nearestZone(
     float price,
     float support,
     float balance,
     float resistance
) =>
    string result = "Balance"

    if price > resistance or price < support
        result := "Outside"

    else
        float supportDistance = math.abs(
             price - support
        )

        float balanceDistance = math.abs(
             price - balance
        )

        float resistanceDistance = math.abs(
             price - resistance
        )

        if supportDistance <= balanceDistance and
             supportDistance <= resistanceDistance

            result := "Support"

        else if resistanceDistance <= balanceDistance and
             resistanceDistance <= supportDistance

            result := "Resistance"

        else
            result := "Balance"

    result

zoneBackground(string zoneText) =>
    color result = balanceColor

    if zoneText == "Resistance"
        result := resistanceColor

    else if zoneText == "Support"
        result := supportColor

    else if zoneText == "Outside"
        result := outsideColor

    result

marketSide(float price, float balance) =>
    price >= balance ? "Above" : "Below"

simpleTip(
     float price,
     float support,
     float balance,
     float resistance
) =>
    string tip = "At balance"

    if price > resistance
        tip := "Above resistance"

    else if price < support
        tip := "Below support"

    else if price > balance
        tip := "Above balance"

    else if price < balance
        tip := "Below balance"

    tip

//==================================================================================================
// DRAWING HELPERS
//==================================================================================================

setLevelLine(
     line levelLine,
     int x1,
     float y,
     int x2,
     color lineColor,
     int lineWidth
) =>
    line.set_xy1(levelLine, x1, y)
    line.set_xy2(levelLine, x2, y)
    line.set_color(levelLine, lineColor)
    line.set_width(levelLine, lineWidth)

setLevelLabel(
     label levelLabel,
     int x,
     float y,
     string labelText,
     color backgroundColor
) =>
    label.set_xy(levelLabel, x, y)
    label.set_text(levelLabel, labelText)
    label.set_color(levelLabel, backgroundColor)
    label.set_textcolor(levelLabel, color.white)
    label.set_style(levelLabel, label.style_label_left)
    label.set_size(levelLabel, size.small)

hideLevelLabel(label levelLabel) =>
    label.set_text(levelLabel, "")
    label.set_color(levelLabel, hiddenColor)
    label.set_textcolor(
         levelLabel,
         color.new(color.white, 100)
    )

//==================================================================================================
// DASHBOARD
//==================================================================================================

renderDashboard(
     string market,
     string positionText,
     string zoneText,
     float balancePrice,
     string tipText
) =>
    table.cell(
         dashboard,
         0,
         0,
         "VOL MAP",
         text_color = mainTextColor,
         bgcolor = dashboardHeader,
         text_size = size.small
    )

    table.cell(
         dashboard,
         1,
         0,
         "Beginner",
         text_color = mainTextColor,
         bgcolor = dashboardHeader,
         text_size = size.small
    )

    table.cell(
         dashboard,
         0,
         1,
         "Market",
         text_color = mainTextColor,
         bgcolor = dashboardCell,
         text_size = size.small
    )

    table.cell(
         dashboard,
         1,
         1,
         market,
         text_color = mainTextColor,
         bgcolor = market == "Above" ?
             color.new(supportColor, 10) :
             color.new(resistanceColor, 10),
         text_size = size.small
    )

    table.cell(
         dashboard,
         0,
         2,
         "Price",
         text_color = mainTextColor,
         bgcolor = dashboardCell,
         text_size = size.small
    )

    table.cell(
         dashboard,
         1,
         2,
         positionText,
         text_color = mainTextColor,
         bgcolor = dashboardCell,
         text_size = size.small
    )

    table.cell(
         dashboard,
         0,
         3,
         "Zone",
         text_color = mainTextColor,
         bgcolor = dashboardCell,
         text_size = size.small
    )

    table.cell(
         dashboard,
         1,
         3,
         zoneText,
         text_color = mainTextColor,
         bgcolor = zoneBackground(zoneText),
         text_size = size.small
    )

    table.cell(
         dashboard,
         0,
         4,
         "Balance",
         text_color = mainTextColor,
         bgcolor = dashboardCell,
         text_size = size.small
    )

    table.cell(
         dashboard,
         1,
         4,
         str.tostring(
             balancePrice,
             format.mintick
         ),
         text_color = balanceColor,
         bgcolor = dashboardCell,
         text_size = size.small
    )

    table.cell(
         dashboard,
         0,
         5,
         "Tip",
         text_color = mainTextColor,
         bgcolor = dashboardCell,
         text_size = size.small
    )

    table.cell(
         dashboard,
         1,
         5,
         showTip ? tipText : "",
         text_color = mutedTextColor,
         bgcolor = dashboardCell,
         text_size = size.small
    )

clearDashboard() =>
    for row = 0 to 5
        table.cell(
             dashboard,
             0,
             row,
             "",
             bgcolor = hiddenColor
        )

        table.cell(
             dashboard,
             1,
             row,
             "",
             bgcolor = hiddenColor
        )

//==================================================================================================
// PROFILE RENDERING
//==================================================================================================

renderVolumeMap() =>
    [balanceRow, peakVolume, totalVolume] = findBalanceRow()

    [supportRow, resistanceRow] = findBalanceBand(
         balanceRow,
         totalVolume
    )

    float balancePrice    = rowPrice(balanceRow)
    float resistancePrice = rowPrice(resistanceRow)
    float supportPrice    = rowPrice(supportRow)

    int profileRight = bar_index + rightOffset

    int levelStart = math.max(
         0,
         bar_index - activeBars + 1
    )

    int labelX = profileRight + 8

    for row = 0 to rowCount - 1
        float currentRowVolume = array.get(
             rowVolumes,
             row
        )

        int rowLength = profileLength(
             currentRowVolume,
             peakVolume
        )

        int rowStart = profileRight - rowLength
        float y      = rowPrice(row)

        bool insideBalanceArea =
             row >= supportRow and
             row <= resistanceRow

        bool isBalanceRow = row == balanceRow

        color baseColor = insideBalanceArea ?
             balanceAreaColor :
             profileColor

        color displayedColor =
             not showProfile ?
             hiddenColor :
             isBalanceRow ?
             balanceColor :
             baseColor

        line currentProfileLine = array.get(
             profileRows,
             row
        )

        line.set_xy1(
             currentProfileLine,
             rowStart,
             y
        )

        line.set_xy2(
             currentProfileLine,
             profileRight,
             y
        )

        line.set_color(
             currentProfileLine,
             displayedColor
        )

        line.set_width(
             currentProfileLine,
             rowThickness
        )

    if showLevels
        int resistanceLength = profileLength(
             array.get(rowVolumes, resistanceRow),
             peakVolume
        )

        int balanceLength = profileLength(
             peakVolume,
             peakVolume
        )

        int supportLength = profileLength(
             array.get(rowVolumes, supportRow),
             peakVolume
        )

        setLevelLine(
             resistanceLine,
             levelStart,
             resistancePrice,
             profileRight - resistanceLength - 10,
             resistanceColor,
             1
        )

        setLevelLine(
             balanceLine,
             levelStart,
             balancePrice,
             profileRight - balanceLength - 10,
             balanceColor,
             2
        )

        setLevelLine(
             supportLine,
             levelStart,
             supportPrice,
             profileRight - supportLength - 10,
             supportColor,
             1
        )

        if showLevelLabels
            setLevelLabel(
                 resistanceLabel,
                 labelX,
                 resistancePrice,
                 "Resistance\n" +
                 str.tostring(
                     resistancePrice,
                     format.mintick
                 ),
                 resistanceColor
            )

            setLevelLabel(
                 balanceLabel,
                 labelX,
                 balancePrice,
                 "Balance\n" +
                 str.tostring(
                     balancePrice,
                     format.mintick
                 ),
                 balanceColor
            )

            setLevelLabel(
                 supportLabel,
                 labelX,
                 supportPrice,
                 "Support\n" +
                 str.tostring(
                     supportPrice,
                     format.mintick
                 ),
                 supportColor
            )

        else
            hideLevelLabel(resistanceLabel)
            hideLevelLabel(balanceLabel)
            hideLevelLabel(supportLabel)

    else
        line.set_color(resistanceLine, hiddenColor)
        line.set_color(balanceLine, hiddenColor)
        line.set_color(supportLine, hiddenColor)

        hideLevelLabel(resistanceLabel)
        hideLevelLabel(balanceLabel)
        hideLevelLabel(supportLabel)

    string market = marketSide(
         close,
         balancePrice
    )

    string positionText = pricePosition(
         close,
         supportPrice,
         balancePrice,
         resistancePrice
    )

    string zoneText = nearestZone(
         close,
         supportPrice,
         balancePrice,
         resistancePrice
    )

    string tipText = simpleTip(
         close,
         supportPrice,
         balancePrice,
         resistancePrice
    )

    if showDashboard
        renderDashboard(
             market,
             positionText,
             zoneText,
             balancePrice,
             tipText
        )

    else
        clearDashboard()

//==================================================================================================
// INITIALIZATION
//==================================================================================================

if barstate.isfirst
    for row = 0 to rowCount - 1
        array.push(
             profileRows,
             line.new(
                 x1 = bar_index,
                 y1 = close,
                 x2 = bar_index,
                 y2 = close,
                 width = rowThickness,
                 color = profileColor
             )
        )

    balanceLine := line.new(
         x1 = bar_index,
         y1 = close,
         x2 = bar_index,
         y2 = close,
         color = balanceColor,
         width = 2
    )

    resistanceLine := line.new(
         x1 = bar_index,
         y1 = close,
         x2 = bar_index,
         y2 = close,
         color = resistanceColor,
         width = 1
    )

    supportLine := line.new(
         x1 = bar_index,
         y1 = close,
         x2 = bar_index,
         y2 = close,
         color = supportColor,
         width = 1
    )

    resistanceLabel := label.new(
         x = bar_index,
         y = close,
         text = "",
         style = label.style_label_left,
         color = resistanceColor,
         textcolor = color.white,
         size = size.small
    )

    balanceLabel := label.new(
         x = bar_index,
         y = close,
         text = "",
         style = label.style_label_left,
         color = balanceColor,
         textcolor = color.white,
         size = size.small
    )

    supportLabel := label.new(
         x = bar_index,
         y = close,
         text = "",
         style = label.style_label_left,
         color = supportColor,
         textcolor = color.white,
         size = size.small
    )

//==================================================================================================
// CALCULATION
//==================================================================================================

if barstate.islast
    buildVolumeMap()
    renderVolumeMap()

//==================================================================================================
// USAGE GUIDE
//==================================================================================================

// WHAT IT DOES
//
// Volume Map builds a horizontal volume profile from recent price action
// and identifies three practical reference levels:
//
// Balance: the highest-volume price row.
// Resistance: the upper boundary of the balance zone.
// Support: the lower boundary of the balance zone.
//
// HOW THE MAP IS CALCULATED
//
// Each candle's volume is distributed proportionally across only the
// price rows actually crossed by that candle.
//
// A row receives volume according to the size of its price overlap with
// the candle's full range.
//
// The candle's total volume is preserved instead of being repeated on
// every crossed price row.
//
// If multiple rows share the highest volume, the row closest to the
// profile volume centroid becomes Balance.
//
// The balance zone is the narrowest contiguous range containing Balance
// and the selected percentage of total profile volume.
//
// DASHBOARD
//
// Market:
// Shows whether the current price is above or below Balance.
//
// Price:
// Above map — price is above Resistance.
// Upper — price is between Balance and Resistance.
// Balance — price is at Balance.
// Lower — price is between Support and Balance.
// Below map — price is below Support.
//
// Zone:
// Shows the nearest important level while price is inside the map:
// Resistance, Balance or Support.
//
// If price is above Resistance or below Support, Zone shows Outside.
//
// Tip:
// Describes the current relationship between price and the three levels.
//
// HOW TO READ IT
//
// Price inside the balance zone suggests acceptance and possible rotation.
//
// Price above Resistance or below Support suggests that price is testing
// acceptance outside the balance area.
//
// Wider profile rows represent greater concentration of volume.
//
// Educational tool only. Not financial advice.
// Levels are statistical reference points, not guarantees.
````
