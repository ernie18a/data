# Volume Structure

- url: https://www.tradingview.com/script/IcaF8SRK-Volume-Structure/
- type: indicator
- pine_id: PUB;3064afe39db9404abd0bfae93deef4c4
- version: 1.0

## Description

📊 Volume Structure is a market volume structure indicator that combines a horizontal volume profile, the level of maximum volume concentration, and automatically calculated volume-based support and resistance levels.
All components of the indicator are derived from the same volume distribution. This is not a simple combination of several independent tools: the volume profile serves as the underlying calculation model, while the Max Volume Level, support levels, and resistance levels are extracted directly from that model.
The indicator helps traders identify the price areas where the highest trading activity was concentrated during the selected period and locate additional significant volume zones relative to the current price.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 Purpose of the Indicator
A standard horizontal volume profile shows how trading volume is distributed across different price areas. However, when many price rows are displayed, interpreting the profile and identifying its most important concentrations may become difficult.
Volume Structure expands the traditional profile by automatically identifying:
• the price area containing the highest total calculated volume;
• up to two significant volume areas above the current price;
• up to two significant volume areas below the current price.
Together, these areas form a structural market map and help traders evaluate the position of the current price relative to important volume concentrations.
The indicator does not generate independent Buy or Sell signals and does not predict whether a specific level will hold or be broken.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚙️ How the Volume Profile Is Calculated
The indicator first determines the highest and lowest prices reached during the selected calculation period.
The resulting price range is then divided into a user-defined number of horizontal price rows called Rows.
The volume of each candle is distributed among the price rows intersected by its body and wicks.
The calculation follows these steps:
The body volume of a bullish candle is assigned to the estimated up-volume component.
The body volume of a bearish candle is assigned to the estimated down-volume component.
The upper and lower candle wicks are calculated separately from the candle body.
The estimated wick volume is divided equally between the up-volume and down-volume components.
The volume of each candle component is distributed proportionally according to how much of the body or wick overlaps each horizontal price row.
The estimated up-volume and down-volume components are then added together to calculate the total volume of each price area.
🟢 The green section of the profile represents estimated up volume.
🔴 The red section of the profile represents estimated down volume.
It is important to understand that this is an OHLCV-based volume distribution model. It is not a true Bid/Ask profile, order-flow delta, or an exact separation of market buying and selling volume.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔴 Max Volume Level
The Max Volume Level represents the midpoint of the price row containing the highest total calculated volume during the selected period.
It is displayed as a solid red horizontal line.
This level identifies the price area with the greatest concentration of calculated volume within the current profile and can be used as a reference for the strongest area of price acceptance during the selected calculation window.
Because the line is plotted at the midpoint of a horizontal price row, it represents the central price of a volume area rather than the exact price of an individual transaction.
The Max Volume Level does not determine the direction of the next market movement by itself.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧱 Volume Support and Volume Resistance
Using the same volume distribution, the indicator analyzes price rows located above and below the current closing price.
A potential volume node is initially considered significant when:
• its total volume is equal to or greater than the volume of the adjacent rows;
• its volume reaches the user-defined minimum proportion of the Max Volume Level volume;
• it is sufficiently separated from the Max Volume Level;
• it is sufficiently separated from another already selected structure level;
• its distance from the current price does not exceed the user-defined maximum.
A significant volume area above the current price is classified as Volume Resistance.
A significant volume area below the current price is classified as Volume Support.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔎 Level Selection Logic
The indicator first searches for the nearest qualifying local volume peak above and below the current price.
After the first level has been selected, the algorithm searches for a second level that:
• is located on the same side of the current price;
• is sufficiently separated from the first selected level;
• is sufficiently separated from the Max Volume Level;
• satisfies the configured distance and strength requirements.
When no qualifying local volume peak is available, the indicator applies a fallback procedure.
In this case, it selects the strongest eligible volume row on the corresponding side of the current price while preserving the distance and separation requirements.
Because of this fallback logic, a displayed support or resistance level is not always a strict local maximum of the volume distribution.
The indicator can display a maximum of:
• two Volume Resistance levels;
• two Volume Support levels.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💎 What Makes the Indicator Different
The volume profile, Max Volume Level, and structural levels are consecutive stages of one calculation process:
Candle volume is distributed across horizontal price rows.
The estimated up-volume and down-volume components form the horizontal profile.
The total volume of every price row is calculated.
The row with the highest total volume becomes the Max Volume Level.
Additional significant volume rows are evaluated as potential support and resistance levels.
The indicator therefore does more than display several volume-related components together.
It transforms the underlying volume distribution into a more readable structural market map while preserving the complete profile on the chart. Traders can see both the extracted levels and the volume model from which those levels were derived.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧭 How to Interpret the Indicator
Horizontal Volume Profile
The longer a horizontal profile row is, the greater the amount of calculated volume assigned to that price area during the selected period.
The green and red sections should not be interpreted as an exact measurement of aggressive buyers and sellers.
Max Volume Level
The solid red line marks the midpoint of the price row containing the highest total calculated volume.
It serves as a reference for the strongest volume concentration within the current calculation window.
Volume Resistance
The red dashed lines represent selected volume concentrations above the current price.
When price approaches these areas, increased market activity may occur. However, the indicator does not guarantee that price will stop, reverse, or be rejected.
Volume Support
The green dashed lines represent selected volume concentrations below the current price.
They identify potentially significant price areas but do not guarantee a reversal or a successful support reaction.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📌 Practical Applications
The indicator can be used to:
• evaluate the position of the current price relative to significant volume concentrations;
• observe price behavior around the Max Volume Level;
• identify price areas that may require additional analysis;
• study price acceptance and rejection;
• analyze consolidation around high-volume areas;
• observe breakouts from significant volume zones;
• define areas of interest within an existing trading strategy;
• provide additional context for an already established trading scenario.
Volume-based levels should be used together with trend analysis, price structure, volatility assessment, trade confirmation rules, and risk management.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎛️ Indicator Settings
Bars for Calculation
Defines the number of recent candles included in the volume profile calculation.
A lower value makes the structure more responsive to recent market activity.
A higher value includes a longer historical period and generally produces a broader, slower-changing structure.
Default value: 120 bars.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Rows (Horizontal Bands)
Defines the number of horizontal price rows used to divide the calculation range.
A higher number of rows increases price resolution but may make the calculated levels more sensitive to small market changes.
A lower number of rows produces a smoother and more aggregated volume structure.
Default value: 24 rows.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Up Volume Color / Down Volume Color
Controls the colors of the estimated up-volume and down-volume sections of the profile.
These settings affect only the visual appearance and do not change the calculation.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Show Max Volume Level Label
Enables or disables the price label for the Max Volume Level.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Max Volume Level Color / Line Width
Controls the color and thickness of the Max Volume Level line.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Show Volume Support and Resistance
Enables or disables the automatically calculated volume support and resistance levels.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Volume Resistance Color / Volume Support Color
Controls the colors of the corresponding structure lines and labels.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Structure Line Width
Defines the thickness of the Volume Support and Volume Resistance lines.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Labels Offset to the Right
Controls the horizontal position of the level labels to the right of the current candle.
This setting changes only the visual placement of the labels and does not affect the calculation.
Default value: 25 bars.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Maximum Level Distance, %
Defines the maximum permitted percentage distance between the current closing price and a structural level.
If a volume area is located farther away than the selected percentage, it is not displayed as support or resistance.
Default value: 20%.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Minimum Volume Node Strength
Defines the minimum strength of a local volume node relative to the volume of the Max Volume Level.
For example, a value of 0.20 means that during the initial selection process, a qualifying local node must contain at least 20% of the volume of the Max Volume Level.
Default value: 0.20.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 Dynamic Recalculation
Volume Structure uses a rolling calculation window.
When a new candle appears, the oldest candle may leave the selected calculation period. At the same time, the highest and lowest prices, horizontal row boundaries, and volume distribution may change.
As a result, the following elements may change over time:
• the shape of the volume profile;
• the Max Volume Level;
• Volume Support levels;
• Volume Resistance levels.
The current unfinished candle is also included in the calculation. While that candle is forming, its volume and price range may change, causing the calculated levels to move, appear, or disappear.
The indicator displays the current structure derived from the latest calculation window. It does not preserve historical versions of previously calculated levels.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ Limitations
• The up-volume and down-volume distribution is an OHLCV-based estimate, not actual Bid/Ask volume.
• The indicator does not have access to the exact amount of volume executed at every individual price inside a candle.
• Volume is distributed proportionally across the candle body and wicks.
• Every displayed level represents the midpoint of a horizontal price row rather than the exact price of an individual transaction.
• Results depend on the quality and completeness of the volume data available for the selected instrument.
• Increasing the number of horizontal rows improves visual resolution but also makes the profile more sensitive to changes in the calculation range.
• The levels are dynamic and may change while the current candle is forming.
• A fallback structure level may represent the strongest eligible volume area without being a strict local volume peak.
• A high-volume area may act as support, resistance, consolidation, price acceptance, or a breakout zone.
• The indicator cannot determine in advance which market scenario will occur.
• The script does not calculate entry points, stop-loss levels, profit targets, or trading performance statistics.
• The indicator does not guarantee profitable results.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🛡️ Important Information
Volume Structure is designed to provide analytical market context and is not a standalone trading system.
All trading decisions should be based on the user’s own analysis, trading plan, and risk management rules.
The indicator does not constitute financial or investment advice.

## Source Code

````pine
//@version=6
indicator(
     'MarketStructureLab - Volume Structure',
     shorttitle='Volume Structure',
     overlay=true,
     max_boxes_count=200,
     max_lines_count=20,
     max_labels_count=20,
     max_bars_back=500
)

// ==========================================
// Volume Profile
// ==========================================
calcBars = input.int(
     title='Bars for Calculation',
     defval=120,
     minval=20,
     maxval=500,
     group='Volume Profile'
)

rowCount = input.int(
     title='Rows (Horizontal Bands)',
     defval=24,
     minval=5,
     maxval=100,
     group='Volume Profile'
)

upColor = input.color(
     defval=color.new(color.rgb(64, 217, 143), 50),
     title='Up Volume Color',
     group='Volume Profile'
)

downColor = input.color(
     defval=color.new(color.rgb(246, 113, 113), 50),
     title='Down Volume Color',
     group='Volume Profile'
)

// ==========================================
// Max Volume Level
// ==========================================
showPocLabel = input.bool(
     defval=true,
     title='Show Max Volume Level Label',
     group='Max Volume Level'
)

pocLineColor = input.color(
     defval=#ff0000,
     title='Color',
     inline='poc',
     group='Max Volume Level'
)

pocLineWidth = input.int(
     defval=2,
     title='Line Width',
     minval=1,
     maxval=5,
     inline='poc',
     group='Max Volume Level'
)

// ==========================================
// Volume Support and Resistance
// ==========================================
showStructureLevels = input.bool(
     defval=true,
     title='Show Volume Support and Resistance',
     group='Volume Support and Resistance'
)

resistanceColor = input.color(
     defval=color.rgb(218, 83, 98),
     title='Volume Resistance Color',
     group='Volume Support and Resistance'
)

supportColor = input.color(
     defval=color.rgb(43, 190, 145),
     title='Volume Support Color',
     group='Volume Support and Resistance'
)

structureLineWidth = input.int(
     defval=1,
     title='Line Width',
     minval=1,
     maxval=3,
     group='Volume Support and Resistance'
)

labelOffsetBars = input.int(
     defval=25,
     title='Labels Offset to the Right',
     minval=10,
     maxval=100,
     group='Volume Support and Resistance'
)

maxLevelDistancePercent = input.float(
     defval=20.0,
     title='Maximum Level Distance, %',
     minval=1.0,
     maxval=100.0,
     step=1.0,
     tooltip='Levels farther than this percentage from the current price will not be displayed.',
     group='Volume Support and Resistance'
)

minimumNodeStrength = input.float(
     defval=0.20,
     title='Minimum Volume Node Strength',
     minval=0.05,
     maxval=1.00,
     step=0.05,
     tooltip='Minimum volume of a level relative to the Max Volume Level.',
     group='Volume Support and Resistance'
)

// ==========================================
// Persistent drawing objects
// ==========================================
var volBars = array.new_box(rowCount * 2, na)

var line pocLine = na
var label pocLabel = na

var line resistanceLine1 = na
var line resistanceLine2 = na
var line supportLine1 = na
var line supportLine2 = na

var label resistanceLabel1 = na
var label resistanceLabel2 = na
var label supportLabel1 = na
var label supportLabel2 = na

// ==========================================
// Helper functions
// ==========================================
getVol(y11, y12, y21, y22, height, vol) =>
    height > 0
         ? nz(
             math.max(
                 math.min(math.max(y11, y12), math.max(y21, y22)) -
                 math.max(math.min(y11, y12), math.min(y21, y22)),
                 0
             ) * vol / height
         )
         : 0.0

getLevelPrice(levelsArray, index) =>
    (
         array.get(levelsArray, index) +
         array.get(levelsArray, index + 1)
    ) / 2

getDistancePercent(levelPrice, referencePrice) =>
    referencePrice != 0
         ? (levelPrice - referencePrice) / referencePrice * 100
         : 0.0

isInsideMaximumDistance(levelPrice, referencePrice, maximumPercent) =>
    math.abs(
         getDistancePercent(levelPrice, referencePrice)
    ) <= maximumPercent

getResistanceText(levelPrice) =>
    'Volume Resistance: ' +
     str.tostring(levelPrice, format.mintick)

getSupportText(levelPrice) =>
    'Volume Support: ' +
     str.tostring(levelPrice, format.mintick)

// ==========================================
// Main values
// ==========================================
barsToUse = math.min(calcBars, bar_index + 1)

highestPrice = nz(
     ta.highest(high, calcBars),
     high
)

lowestPrice = nz(
     ta.lowest(low, calcBars),
     low
)

priceRange = math.max(
     highestPrice - lowestPrice,
     syminfo.mintick
)

rowStep = priceRange / rowCount
rowPadding = priceRange / 500

// ==========================================
// Price rows
// ==========================================
levels = array.new_float(rowCount + 1, 0.0)

for x = 0 to rowCount
    array.set(
         levels,
         x,
         lowestPrice + rowStep * x
    )

// ==========================================
// Calculate and draw on the latest bar
// ==========================================
if barstate.islast

    // ==========================================
    // Accumulate volume by price row
    // ==========================================
    volumes = array.new_float(rowCount * 2, 0.0)

    for bars = 0 to barsToUse - 1

        bodyTop = math.max(close[bars], open[bars])
        bodyBottom = math.min(close[bars], open[bars])
        isUpBar = close[bars] >= open[bars]

        topWick = high[bars] - bodyTop
        bottomWick = bodyBottom - low[bars]
        bodyHeight = bodyTop - bodyBottom

        candleWeight =
             2 * topWick +
             2 * bottomWick +
             bodyHeight

        candleVolume = nz(volume[bars])

        bodyVolume = candleWeight > 0
             ? bodyHeight * candleVolume / candleWeight
             : 0.0

        topWickVolume = candleWeight > 0
             ? 2 * topWick * candleVolume / candleWeight
             : 0.0

        bottomWickVolume = candleWeight > 0
             ? 2 * bottomWick * candleVolume / candleWeight
             : 0.0

        for x = 0 to rowCount - 1

            rowBottom = array.get(levels, x)
            rowTop = array.get(levels, x + 1)

            bullishVolume =
                 (
                     isUpBar
                         ? getVol(
                             rowBottom,
                             rowTop,
                             bodyBottom,
                             bodyTop,
                             bodyHeight,
                             bodyVolume
                         )
                         : 0.0
                 ) +
                 getVol(
                     rowBottom,
                     rowTop,
                     bodyTop,
                     high[bars],
                     topWick,
                     topWickVolume
                 ) / 2 +
                 getVol(
                     rowBottom,
                     rowTop,
                     bodyBottom,
                     low[bars],
                     bottomWick,
                     bottomWickVolume
                 ) / 2

            bearishVolume =
                 (
                     isUpBar
                         ? 0.0
                         : getVol(
                             rowBottom,
                             rowTop,
                             bodyBottom,
                             bodyTop,
                             bodyHeight,
                             bodyVolume
                         )
                 ) +
                 getVol(
                     rowBottom,
                     rowTop,
                     bodyTop,
                     high[bars],
                     topWick,
                     topWickVolume
                 ) / 2 +
                 getVol(
                     rowBottom,
                     rowTop,
                     bodyBottom,
                     low[bars],
                     bottomWick,
                     bottomWickVolume
                 ) / 2

            array.set(
                 volumes,
                 x,
                 array.get(volumes, x) + bullishVolume
            )

            array.set(
                 volumes,
                 x + rowCount,
                 array.get(volumes, x + rowCount) + bearishVolume
            )

    // ==========================================
    // Total volume for each price row
    // ==========================================
    totalVolumes = array.new_float(rowCount, 0.0)

    for x = 0 to rowCount - 1

        totalRowVolume =
             array.get(volumes, x) +
             array.get(volumes, x + rowCount)

        array.set(
             totalVolumes,
             x,
             totalRowVolume
        )

    maxVolume = array.max(totalVolumes)

    pocIndex = array.indexof(
         totalVolumes,
         maxVolume
    )

    volumeScaleBase = maxVolume > 0
         ? maxVolume
         : 1.0

    for x = 0 to rowCount * 2 - 1

        scaledVolume =
             array.get(volumes, x) *
             barsToUse /
             (3 * volumeScaleBase)

        array.set(
             volumes,
             x,
             scaledVolume
        )

    // ==========================================
    // Draw Volume Profile
    // ==========================================
    profileStartBar =
         bar_index -
         barsToUse +
         1

    for x = 0 to rowCount - 1

        box.delete(
             array.get(volBars, x)
        )

        box.delete(
             array.get(
                 volBars,
                 x + rowCount
             )
        )

        bullishWidth = int(
             math.round(
                 array.get(volumes, x)
             )
        )

        bearishWidth = int(
             math.round(
                 array.get(
                     volumes,
                     x + rowCount
                 )
             )
        )

        rowBottom = array.get(levels, x)
        rowTop = array.get(levels, x + 1)

        bullishBox = box.new(
             left=profileStartBar,
             top=rowTop - rowPadding,
             right=profileStartBar + bullishWidth,
             bottom=rowBottom + rowPadding,
             border_width=0,
             bgcolor=upColor
        )

        bearishBox = box.new(
             left=profileStartBar + bullishWidth,
             top=rowTop - rowPadding,
             right=profileStartBar +
                   bullishWidth +
                   bearishWidth,
             bottom=rowBottom + rowPadding,
             border_width=0,
             bgcolor=downColor
        )

        array.set(
             volBars,
             x,
             bullishBox
        )

        array.set(
             volBars,
             x + rowCount,
             bearishBox
        )

    // ==========================================
    // Shared label position
    // ==========================================
    levelLabelX =
         bar_index +
         labelOffsetBars

    // ==========================================
    // Draw Max Volume Level
    // ==========================================
    pointOfControl = getLevelPrice(
         levels,
         pocIndex
    )

    line.delete(pocLine)

    pocLine := line.new(
         x1=profileStartBar,
         y1=pointOfControl,
         x2=levelLabelX,
         y2=pointOfControl,
         extend=extend.none,
         color=pocLineColor,
         width=pocLineWidth
    )

    label.delete(pocLabel)
    pocLabel := na

    if showPocLabel

        pocLabel := label.new(
             x=levelLabelX,
             y=pointOfControl,
             text='Max Volume Level: ' +
                  str.tostring(
                       pointOfControl,
                       format.mintick
                  ),
             style=label.style_label_center,
             color=pocLineColor,
             textcolor=color.white,
             size=size.small
        )

    // ==========================================
    // Volume node selection
    // ==========================================
    minimumRowGap = rowCount >= 12
         ? 2
         : 1

    int resistanceIndex1 = na
    int resistanceIndex2 = na
    int supportIndex1 = na
    int supportIndex2 = na

    float nearestResistanceDistance = 1e10
    float secondResistanceDistance = 1e10
    float nearestSupportDistance = 1e10
    float secondSupportDistance = 1e10

    // ==========================================
    // First Volume Resistance
    // ==========================================
    for x = 0 to rowCount - 1

        nodeVolume = array.get(totalVolumes, x)

        previousVolume = x > 0
             ? array.get(totalVolumes, x - 1)
             : -1.0

        nextVolume = x < rowCount - 1
             ? array.get(totalVolumes, x + 1)
             : -1.0

        nodePrice = getLevelPrice(levels, x)

        isVolumePeak =
             nodeVolume >= previousVolume and
             nodeVolume >= nextVolume

        nodeStrength = maxVolume > 0
             ? nodeVolume / maxVolume
             : 0.0

        farEnoughFromPoc =
             math.abs(x - pocIndex) >= minimumRowGap

        insideDistance =
             isInsideMaximumDistance(
                 nodePrice,
                 close,
                 maxLevelDistancePercent
             )

        resistanceDistance =
             nodePrice - close

        validResistance =
             nodePrice > close and
             isVolumePeak and
             nodeStrength >= minimumNodeStrength and
             farEnoughFromPoc and
             insideDistance

        if validResistance and resistanceDistance < nearestResistanceDistance

            resistanceIndex1 := x
            nearestResistanceDistance := resistanceDistance

    // ==========================================
    // First resistance fallback
    // ==========================================
    if na(resistanceIndex1)

        float strongestResistanceVolume = -1.0

        for x = 0 to rowCount - 1

            nodePrice = getLevelPrice(levels, x)
            nodeVolume = array.get(totalVolumes, x)

            farEnoughFromPoc =
                 math.abs(x - pocIndex) >= minimumRowGap

            insideDistance =
                 isInsideMaximumDistance(
                     nodePrice,
                     close,
                     maxLevelDistancePercent
                 )

            validFallbackResistance =
                 nodePrice > close and
                 farEnoughFromPoc and
                 insideDistance

            if validFallbackResistance and nodeVolume > strongestResistanceVolume

                resistanceIndex1 := x
                strongestResistanceVolume := nodeVolume

    // ==========================================
    // Second Volume Resistance
    // ==========================================
    if not na(resistanceIndex1)

        for x = 0 to rowCount - 1

            nodeVolume = array.get(totalVolumes, x)

            previousVolume = x > 0
                 ? array.get(totalVolumes, x - 1)
                 : -1.0

            nextVolume = x < rowCount - 1
                 ? array.get(totalVolumes, x + 1)
                 : -1.0

            nodePrice = getLevelPrice(levels, x)

            isVolumePeak =
                 nodeVolume >= previousVolume and
                 nodeVolume >= nextVolume

            nodeStrength = maxVolume > 0
                 ? nodeVolume / maxVolume
                 : 0.0

            farEnough =
                 math.abs(x - resistanceIndex1) >= minimumRowGap and
                 math.abs(x - pocIndex) >= minimumRowGap

            insideDistance =
                 isInsideMaximumDistance(
                     nodePrice,
                     close,
                     maxLevelDistancePercent
                 )

            resistanceDistance =
                 nodePrice - close

            validSecondResistance =
                 nodePrice > close and
                 isVolumePeak and
                 nodeStrength >= minimumNodeStrength and
                 farEnough and
                 insideDistance

            if validSecondResistance and resistanceDistance < secondResistanceDistance

                resistanceIndex2 := x
                secondResistanceDistance := resistanceDistance

    // ==========================================
    // Second resistance fallback
    // ==========================================
    if not na(resistanceIndex1) and na(resistanceIndex2)

        float strongestSecondResistanceVolume = -1.0

        for x = 0 to rowCount - 1

            nodePrice = getLevelPrice(levels, x)
            nodeVolume = array.get(totalVolumes, x)

            farEnough =
                 math.abs(x - resistanceIndex1) >= minimumRowGap and
                 math.abs(x - pocIndex) >= minimumRowGap

            insideDistance =
                 isInsideMaximumDistance(
                     nodePrice,
                     close,
                     maxLevelDistancePercent
                 )

            validFallbackResistance =
                 nodePrice > close and
                 farEnough and
                 insideDistance

            if validFallbackResistance and nodeVolume > strongestSecondResistanceVolume

                resistanceIndex2 := x
                strongestSecondResistanceVolume := nodeVolume

    // ==========================================
    // First Volume Support
    // ==========================================
    for x = 0 to rowCount - 1

        nodeVolume = array.get(totalVolumes, x)

        previousVolume = x > 0
             ? array.get(totalVolumes, x - 1)
             : -1.0

        nextVolume = x < rowCount - 1
             ? array.get(totalVolumes, x + 1)
             : -1.0

        nodePrice = getLevelPrice(levels, x)

        isVolumePeak =
             nodeVolume >= previousVolume and
             nodeVolume >= nextVolume

        nodeStrength = maxVolume > 0
             ? nodeVolume / maxVolume
             : 0.0

        farEnoughFromPoc =
             math.abs(x - pocIndex) >= minimumRowGap

        insideDistance =
             isInsideMaximumDistance(
                 nodePrice,
                 close,
                 maxLevelDistancePercent
             )

        supportDistance =
             close - nodePrice

        validSupport =
             nodePrice < close and
             isVolumePeak and
             nodeStrength >= minimumNodeStrength and
             farEnoughFromPoc and
             insideDistance

        if validSupport and supportDistance < nearestSupportDistance

            supportIndex1 := x
            nearestSupportDistance := supportDistance

    // ==========================================
    // First support fallback
    // ==========================================
    if na(supportIndex1)

        float strongestSupportVolume = -1.0

        for x = 0 to rowCount - 1

            nodePrice = getLevelPrice(levels, x)
            nodeVolume = array.get(totalVolumes, x)

            farEnoughFromPoc =
                 math.abs(x - pocIndex) >= minimumRowGap

            insideDistance =
                 isInsideMaximumDistance(
                     nodePrice,
                     close,
                     maxLevelDistancePercent
                 )

            validFallbackSupport =
                 nodePrice < close and
                 farEnoughFromPoc and
                 insideDistance

            if validFallbackSupport and nodeVolume > strongestSupportVolume

                supportIndex1 := x
                strongestSupportVolume := nodeVolume

    // ==========================================
    // Second Volume Support
    // ==========================================
    if not na(supportIndex1)

        for x = 0 to rowCount - 1

            nodeVolume = array.get(totalVolumes, x)

            previousVolume = x > 0
                 ? array.get(totalVolumes, x - 1)
                 : -1.0

            nextVolume = x < rowCount - 1
                 ? array.get(totalVolumes, x + 1)
                 : -1.0

            nodePrice = getLevelPrice(levels, x)

            isVolumePeak =
                 nodeVolume >= previousVolume and
                 nodeVolume >= nextVolume

            nodeStrength = maxVolume > 0
                 ? nodeVolume / maxVolume
                 : 0.0

            farEnough =
                 math.abs(x - supportIndex1) >= minimumRowGap and
                 math.abs(x - pocIndex) >= minimumRowGap

            insideDistance =
                 isInsideMaximumDistance(
                     nodePrice,
                     close,
                     maxLevelDistancePercent
                 )

            supportDistance =
                 close - nodePrice

            validSecondSupport =
                 nodePrice < close and
                 isVolumePeak and
                 nodeStrength >= minimumNodeStrength and
                 farEnough and
                 insideDistance

            if validSecondSupport and supportDistance < secondSupportDistance

                supportIndex2 := x
                secondSupportDistance := supportDistance

    // ==========================================
    // Second support fallback
    // ==========================================
    if not na(supportIndex1) and na(supportIndex2)

        float strongestSecondSupportVolume = -1.0

        for x = 0 to rowCount - 1

            nodePrice = getLevelPrice(levels, x)
            nodeVolume = array.get(totalVolumes, x)

            farEnough =
                 math.abs(x - supportIndex1) >= minimumRowGap and
                 math.abs(x - pocIndex) >= minimumRowGap

            insideDistance =
                 isInsideMaximumDistance(
                     nodePrice,
                     close,
                     maxLevelDistancePercent
                 )

            validFallbackSupport =
                 nodePrice < close and
                 farEnough and
                 insideDistance

            if validFallbackSupport and nodeVolume > strongestSecondSupportVolume

                supportIndex2 := x
                strongestSecondSupportVolume := nodeVolume

    // ==========================================
    // Convert row indexes to prices
    // ==========================================
    float resistance1 = na
    float resistance2 = na
    float support1 = na
    float support2 = na

    if not na(resistanceIndex1)
        resistance1 := getLevelPrice(
             levels,
             resistanceIndex1
        )

    if not na(resistanceIndex2)
        resistance2 := getLevelPrice(
             levels,
             resistanceIndex2
        )

    if not na(supportIndex1)
        support1 := getLevelPrice(
             levels,
             supportIndex1
        )

    if not na(supportIndex2)
        support2 := getLevelPrice(
             levels,
             supportIndex2
        )

    // Nearest resistance first
    if not na(resistance1) and
       not na(resistance2) and
       resistance1 > resistance2

        temporaryResistance = resistance1
        resistance1 := resistance2
        resistance2 := temporaryResistance

    // Nearest support first
    if not na(support1) and
       not na(support2) and
       support1 < support2

        temporarySupport = support1
        support1 := support2
        support2 := temporarySupport

    // ==========================================
    // Delete previous structure objects
    // ==========================================
    line.delete(resistanceLine1)
    line.delete(resistanceLine2)
    line.delete(supportLine1)
    line.delete(supportLine2)

    label.delete(resistanceLabel1)
    label.delete(resistanceLabel2)
    label.delete(supportLabel1)
    label.delete(supportLabel2)

    resistanceLine1 := na
    resistanceLine2 := na
    supportLine1 := na
    supportLine2 := na

    resistanceLabel1 := na
    resistanceLabel2 := na
    supportLabel1 := na
    supportLabel2 := na

    // ==========================================
    // Draw Volume Support and Resistance
    // ==========================================
    if showStructureLevels

        structureStartX = profileStartBar
        structureEndX = levelLabelX

        if not na(resistance1)

            resistanceLine1 := line.new(
                 x1=structureStartX,
                 y1=resistance1,
                 x2=structureEndX,
                 y2=resistance1,
                 extend=extend.none,
                 color=resistanceColor,
                 style=line.style_dashed,
                 width=structureLineWidth
            )

            resistanceLabel1 := label.new(
                 x=levelLabelX,
                 y=resistance1,
                 text=getResistanceText(resistance1),
                 style=label.style_label_down,
                 color=resistanceColor,
                 textcolor=color.white,
                 size=size.small
            )

        if not na(resistance2)

            resistanceLine2 := line.new(
                 x1=structureStartX,
                 y1=resistance2,
                 x2=structureEndX,
                 y2=resistance2,
                 extend=extend.none,
                 color=resistanceColor,
                 style=line.style_dashed,
                 width=structureLineWidth
            )

            resistanceLabel2 := label.new(
                 x=levelLabelX,
                 y=resistance2,
                 text=getResistanceText(resistance2),
                 style=label.style_label_down,
                 color=resistanceColor,
                 textcolor=color.white,
                 size=size.small
            )

        if not na(support1)

            supportLine1 := line.new(
                 x1=structureStartX,
                 y1=support1,
                 x2=structureEndX,
                 y2=support1,
                 extend=extend.none,
                 color=supportColor,
                 style=line.style_dashed,
                 width=structureLineWidth
            )

            supportLabel1 := label.new(
                 x=levelLabelX,
                 y=support1,
                 text=getSupportText(support1),
                 style=label.style_label_up,
                 color=supportColor,
                 textcolor=color.rgb(7, 69, 58),
                 size=size.small
            )

        if not na(support2)

            supportLine2 := line.new(
                 x1=structureStartX,
                 y1=support2,
                 x2=structureEndX,
                 y2=support2,
                 extend=extend.none,
                 color=supportColor,
                 style=line.style_dashed,
                 width=structureLineWidth
            )

            supportLabel2 := label.new(
                 x=levelLabelX,
                 y=support2,
                 text=getSupportText(support2),
                 style=label.style_label_up,
                 color=supportColor,
                 textcolor=color.rgb(7, 69, 58),
                 size=size.small
            )
````
