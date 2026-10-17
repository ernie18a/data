# WaveScope 

- url: https://www.tradingview.com/script/LtuRPrQo-WaveScope/
- type: indicator
- pine_id: PUB;a08d092b8bf24abba1b5dea3892614a8
- version: 1.0

## Description

WaveScope is a market structure indicator designed to identify confirmed swing highs and lows, classify them as Higher High (HH), Higher Low (HL), Lower High (LH), or Lower Low (LL), and automatically detect the structural events Break of Structure (BOS) and Change of Character (CHoCH).
Rather than focusing on individual price swings, the algorithm builds a continuous sequence of confirmed structural points using Pivot High and Pivot Low detection. This sequence serves as the foundation for all structural calculations performed by the indicator.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📖 Overview
Most market structure indicators simply connect confirmed pivots.
During strong directional moves this often creates either excessive structural noise or delays the representation of the current market movement until the next pivot has been confirmed.
WaveScope was designed around a different idea.
Instead of treating each pivot as an isolated event, the indicator continuously maintains the latest structural swing.
Until an opposite pivot is confirmed, the most recent structural point can be replaced whenever price creates a stronger extreme of the same type.
At the same time, the developing swing is displayed independently from the confirmed structure and is updated in real time.
This allows traders to observe:
• confirmed market structure;
• the current developing swing;
• BOS and CHoCH events;
• the current structural state through the information panel.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚙️ How It Works
WaveScope uses symmetrical Pivot High and Pivot Low detection with configurable sensitivity.
Every confirmed pivot is compared with the previous confirmed pivot of the same type.
The result determines whether the new structural point is classified as:
• Higher High (HH)
• Higher Low (HL)
• Lower High (LH)
• Lower Low (LL)
Rather than measuring absolute price movement, the indicator evaluates the relative position of consecutive highs and lows, allowing the market structure to evolve naturally as new pivots are confirmed.
If price forms a stronger extreme before an opposite pivot appears, the existing structural point is updated instead of creating an additional swing.
This approach keeps the structure consistent during fast impulsive movements while reducing unnecessary structural clutter.
WaveScope also includes dedicated Double Pivot Resolution logic to correctly process situations where both Pivot High and Pivot Low are confirmed simultaneously.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 BOS & CHoCH Detection
Once market structure has been established, the latest confirmed highs and lows become active structural reference levels.
A breakout that occurs in the direction of the existing structure is classified as Break of Structure (BOS).
A breakout against the current structural direction is classified as Change of Character (CHoCH).
Breakouts can be confirmed using either:
• candle close;
• candle wick.
This provides additional flexibility for different analytical approaches and varying market conditions.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📈 Developing Structure
Alongside confirmed swings, WaveScope visualizes the developing market structure.
A dynamic dashed line extends from the latest confirmed structural point to the current developing high or low.
This line is updated continuously with each new candle and becomes part of the confirmed structure only after the next pivot has been validated.
By separating confirmed and developing structure, the indicator allows traders to monitor ongoing price development without modifying historical structural information.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🖥️ Information Panel
An optional information panel provides a concise summary of the current structural state, including:
• current market structure direction;
• latest confirmed structural point;
• latest BOS or CHoCH event.
The panel is designed to provide structural context without requiring the entire swing sequence to be reviewed.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎛️ Settings
Structure
• Pivot sensitivity
• Maximum displayed swings
• HH / HL / LH / LL labels
• BOS & CHoCH visualization
• Breakout confirmation method
• Maximum displayed structural events
Visuals
• Structure lines
• Glow effect
• Line width
• Label size
• Label offset
• Color customization
Information Panel
• Enable / disable
• Panel position
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✨ Core Features
WaveScope is built around a single market structure engine.
The HH / HL / LH / LL sequence serves as the foundation for all subsequent calculations.
The same structural model is used for BOS detection, CHoCH detection, developing structure visualization, and the information panel.
Key implementation features include:
• automatic replacement of stronger same-type swings;
• Double Pivot Resolution;
• independent visualization of confirmed and developing structure;
• automatic BOS and CHoCH classification;
• controlled chart object management for improved performance.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📌 Notes
WaveScope relies on confirmed Pivot High and Pivot Low formations.
As a result, new structural points appear only after the corresponding pivot has been confirmed.
The confirmation delay depends on the selected pivot sensitivity and is an inherent characteristic of confirmation-based market structure analysis.
This approach prioritizes structural consistency by relying on confirmed market data instead of preliminary estimates.
The developing structure visualization partially compensates for this characteristic by displaying the ongoing structural progression before confirmation.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📚 Usage Notes
Lower pivot sensitivity produces a more detailed market structure with a larger number of local swings.
Higher sensitivity filters smaller market fluctuations and emphasizes broader structural trends.
The HH / HL sequence represents bullish market structure, while LH / LL represents bearish market structure.
BOS identifies structural continuation, whereas CHoCH identifies structural transitions against the prevailing market direction.
WaveScope can be applied across different markets and timeframes by adjusting pivot sensitivity to match the desired structural scale.

## Source Code

````pine
//@version=6
indicator(
     "WaveScope — Market Structure",
     shorttitle = "WaveScope",
     overlay = true,
     max_lines_count = 300,
     max_labels_count = 250
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// WAVESCOPE
// Market Structure: HH / HL / LH / LL
// Structural events: BOS / CHoCH
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 1. SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string GROUP_STRUCTURE = "Structure"
string GROUP_VISUAL    = "Visual"
string GROUP_PANEL     = "Dashboard"

// Structure

int sensitivity = input.int(
     8,
     "Sensitivity",
     minval = 2,
     maxval = 30,
     group = GROUP_STRUCTURE,
     tooltip = "Lower values show smaller swings. Higher values show larger market structure."
)

int visibleSwings = input.int(
     40,
     "Visible swings",
     minval = 10,
     maxval = 80,
     group = GROUP_STRUCTURE
)

bool showSwingLetters = input.bool(
     true,
     "Show HH / HL / LH / LL",
     group = GROUP_STRUCTURE
)

bool showBreaks = input.bool(
     true,
     "Show BOS / CHoCH",
     group = GROUP_STRUCTURE
)

bool confirmByClose = input.bool(
     true,
     "Confirm break by candle close",
     group = GROUP_STRUCTURE,
     tooltip = "When disabled, a wick through the structural level confirms the break."
)

int visibleBreaks = input.int(
     6,
     "Visible BOS / CHoCH",
     minval = 1,
     maxval = 20,
     group = GROUP_STRUCTURE
)

// Visual

bool showZigzag = input.bool(
     true,
     "Show structure lines",
     group = GROUP_VISUAL
)

bool showGlow = input.bool(
     true,
     "Soft glow",
     group = GROUP_VISUAL
)

int lineWidth = input.int(
     1,
     "Structure line width",
     minval = 1,
     maxval = 4,
     group = GROUP_VISUAL
)

string letterSizeInput = input.string(
     "Small",
     "Structure letter size",
     options = ["Tiny", "Small", "Normal"],
     group = GROUP_VISUAL
)

float labelOffsetAtr = input.float(
     0.25,
     "Structure letter offset",
     minval = 0.05,
     maxval = 1.00,
     step = 0.05,
     group = GROUP_VISUAL,
     tooltip = "Vertical distance between the swing point and its HH / HL / LH / LL label."
)

float eventOffsetAtr = input.float(
     0.12,
     "BOS / CHoCH offset",
     minval = 0.00,
     maxval = 0.50,
     step = 0.02,
     group = GROUP_VISUAL
)

color bullColor = input.color(
     color.rgb(0, 240, 185),
     "Bullish",
     group = GROUP_VISUAL
)

color bearColor = input.color(
     color.rgb(255, 55, 95),
     "Bearish",
     group = GROUP_VISUAL
)

color chochColor = input.color(
     color.rgb(255, 170, 35),
     "CHoCH",
     group = GROUP_VISUAL
)

color levelColor = input.color(
     color.rgb(190, 70, 255),
     "Break level",
     group = GROUP_VISUAL
)

// Dashboard

bool showPanel = input.bool(
     true,
     "Show dashboard",
     group = GROUP_PANEL
)

string panelPositionInput = input.string(
     "Top Right",
     "Position",
     options = [
          "Top Right",
          "Top Left",
          "Bottom Right",
          "Bottom Left"
     ],
     group = GROUP_PANEL
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 2. HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_text_size(string selectedSize) =>
    selectedSize == "Tiny"
         ? size.tiny
         : selectedSize == "Normal"
         ? size.normal
         : size.small

f_structure_color(string structureName) =>
    structureName == "HH" or structureName == "HL"
         ? bullColor
         : bearColor

f_panel_position(string selectedPosition) =>
    selectedPosition == "Top Left"
         ? position.top_left
         : selectedPosition == "Bottom Right"
         ? position.bottom_right
         : selectedPosition == "Bottom Left"
         ? position.bottom_left
         : position.top_right

f_create_swing_letter(
     int labelBar,
     float labelPrice,
     float labelOffset,
     string labelValue,
     int pivotType
 ) =>
    float finalPrice =
         pivotType == 1
         ? labelPrice + labelOffset
         : labelPrice - labelOffset

    label.new(
         x = labelBar,
         y = finalPrice,
         text = labelValue,
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_none,
         textcolor = f_structure_color(labelValue),
         size = f_text_size(letterSizeInput)
    )

f_create_break(
     int levelBar,
     float levelPrice,
     int breakBar,
     string eventName,
     int direction,
     float eventOffset
 ) =>
    color eventColor =
         eventName == "CHoCH"
         ? chochColor
         : direction == 1
         ? bullColor
         : bearColor

    int middleBar = int(
         math.round(
              (levelBar + breakBar) / 2.0
         )
    )

    float eventLabelPrice =
         direction == 1
         ? levelPrice + eventOffset
         : levelPrice - eventOffset

    line eventLine = line.new(
         x1 = levelBar,
         y1 = levelPrice,
         x2 = breakBar,
         y2 = levelPrice,
         xloc = xloc.bar_index,
         extend = extend.none,
         color = color.new(levelColor, 10),
         style = line.style_dashed,
         width = 1
    )

    label eventLabel = label.new(
         x = middleBar,
         y = eventLabelPrice,
         text = eventName,
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_none,
         textcolor = eventColor,
         size = size.small
    )

    [eventLine, eventLabel]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 3. ATR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

float atrValue = ta.atr(14)

float detectedOffset =
     nz(
          atrValue[sensitivity],
          atrValue
     ) * labelOffsetAtr

float currentEventOffset =
     nz(
          atrValue,
          syminfo.mintick
     ) * eventOffsetAtr

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 4. PIVOT DETECTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

float pivotHigh = ta.pivothigh(
     high,
     sensitivity,
     sensitivity
)

float pivotLow = ta.pivotlow(
     low,
     sensitivity,
     sensitivity
)

float detectedPrice = na
int detectedBar = na
int detectedType = 0

//  1 = High
// -1 = Low

if not na(pivotHigh) and na(pivotLow)
    detectedPrice := pivotHigh
    detectedBar := bar_index - sensitivity
    detectedType := 1

else if not na(pivotLow) and na(pivotHigh)
    detectedPrice := pivotLow
    detectedBar := bar_index - sensitivity
    detectedType := -1

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 5. STORAGE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var array<float> pivotPrices = array.new<float>()
var array<int> pivotBars = array.new<int>()
var array<int> pivotTypes = array.new<int>()
var array<float> pivotOffsets = array.new<float>()
var array<string> structureNames = array.new<string>()
var array<label> pivotLabelRefs = array.new<label>()

var array<line> structureLines = array.new<line>()
var array<line> glowLines = array.new<line>()

var array<line> breakLines = array.new<line>()
var array<label> breakLabels = array.new<label>()

// Developing unconfirmed structure

var line developingLine = na
var line developingGlowLine = na

var int developingAnchorBar = na
var float developingAnchorPrice = na
var int developingAnchorType = 0

var int developingExtremeBar = na
var float developingExtremePrice = na

// Active structural levels

var float activeHighPrice = na
var int activeHighBar = na

var float activeLowPrice = na
var int activeLowBar = na

var bool activeHighBroken = false
var bool activeLowBroken = false

//  1 = bullish
// -1 = bearish
//  0 = waiting

var int marketTrend = 0

var string latestEvent = "WAITING"
var int latestEventDirection = 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 6. DOUBLE-PIVOT RESOLUTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if not na(pivotHigh) and not na(pivotLow)
    detectedBar := bar_index - sensitivity

    int storedCount = array.size(pivotTypes)

    if storedCount == 0
        detectedPrice := pivotHigh
        detectedType := 1
    else
        int previousType = array.get(
             pivotTypes,
             storedCount - 1
        )

        if previousType == 1
            detectedPrice := pivotLow
            detectedType := -1
        else
            detectedPrice := pivotHigh
            detectedType := 1

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 7. ADD OR UPDATE PIVOT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if detectedType != 0
    int pivotCount = array.size(pivotPrices)

    // First pivot

    if pivotCount == 0
        array.push(
             pivotPrices,
             detectedPrice
        )

        array.push(
             pivotBars,
             detectedBar
        )

        array.push(
             pivotTypes,
             detectedType
        )

        array.push(
             pivotOffsets,
             detectedOffset
        )

        array.push(
             structureNames,
             detectedType == 1 ? "H" : "L"
        )

        array.push(
             pivotLabelRefs,
             na
        )

        if detectedType == 1
            activeHighPrice := detectedPrice
            activeHighBar := detectedBar
            activeHighBroken := false
        else
            activeLowPrice := detectedPrice
            activeLowBar := detectedBar
            activeLowBroken := false

    else
        int lastIndex = pivotCount - 1

        float lastPrice = array.get(
             pivotPrices,
             lastIndex
        )

        int lastBar = array.get(
             pivotBars,
             lastIndex
        )

        int lastType = array.get(
             pivotTypes,
             lastIndex
        )

        // Same pivot type:
        // retain only the stronger extreme.

        if detectedType == lastType
            bool strongerExtreme =
                 detectedType == 1
                 ? detectedPrice > lastPrice
                 : detectedPrice < lastPrice

            if strongerExtreme
                array.set(
                     pivotPrices,
                     lastIndex,
                     detectedPrice
                )

                array.set(
                     pivotBars,
                     lastIndex,
                     detectedBar
                )

                array.set(
                     pivotOffsets,
                     lastIndex,
                     detectedOffset
                )

                string updatedName =
                     detectedType == 1 ? "H" : "L"

                if lastIndex >= 2
                    float previousSameTypePrice = array.get(
                         pivotPrices,
                         lastIndex - 2
                    )

                    if detectedType == 1
                        updatedName :=
                             detectedPrice > previousSameTypePrice
                             ? "HH"
                             : "LH"
                    else
                        updatedName :=
                             detectedPrice > previousSameTypePrice
                             ? "HL"
                             : "LL"

                array.set(
                     structureNames,
                     lastIndex,
                     updatedName
                )

                if array.size(structureLines) > 0
                    line latestStructureLine = array.get(
                         structureLines,
                         array.size(structureLines) - 1
                    )

                    line.set_xy2(
                         latestStructureLine,
                         detectedBar,
                         detectedPrice
                    )

                if array.size(glowLines) > 0
                    line latestGlowLine = array.get(
                         glowLines,
                         array.size(glowLines) - 1
                    )

                    line.set_xy2(
                         latestGlowLine,
                         detectedBar,
                         detectedPrice
                    )

                label existingLabel = array.get(
                     pivotLabelRefs,
                     lastIndex
                )

                bool validStructureName =
                     updatedName != "H" and
                     updatedName != "L"

                if showSwingLetters and validStructureName
                    float finalLabelPrice =
                         detectedType == 1
                         ? detectedPrice + detectedOffset
                         : detectedPrice - detectedOffset

                    if na(existingLabel)
                        label newUpdatedLabel = f_create_swing_letter(
                             detectedBar,
                             detectedPrice,
                             detectedOffset,
                             updatedName,
                             detectedType
                        )

                        array.set(
                             pivotLabelRefs,
                             lastIndex,
                             newUpdatedLabel
                        )
                    else
                        label.set_x(
                             existingLabel,
                             detectedBar
                        )

                        label.set_y(
                             existingLabel,
                             finalLabelPrice
                        )

                        label.set_text(
                             existingLabel,
                             updatedName
                        )

                        label.set_textcolor(
                             existingLabel,
                             f_structure_color(updatedName)
                        )

                else if not na(existingLabel)
                    label.delete(existingLabel)

                    array.set(
                         pivotLabelRefs,
                         lastIndex,
                         na
                    )

                if detectedType == 1
                    activeHighPrice := detectedPrice
                    activeHighBar := detectedBar
                    activeHighBroken := false
                else
                    activeLowPrice := detectedPrice
                    activeLowBar := detectedBar
                    activeLowBroken := false

        // Opposite pivot:
        // confirm a new swing.

        else
            string newStructureName =
                 detectedType == 1 ? "H" : "L"

            if pivotCount >= 2
                float previousSameTypePrice = array.get(
                     pivotPrices,
                     pivotCount - 2
                )

                if detectedType == 1
                    newStructureName :=
                         detectedPrice > previousSameTypePrice
                         ? "HH"
                         : "LH"
                else
                    newStructureName :=
                         detectedPrice > previousSameTypePrice
                         ? "HL"
                         : "LL"

            color swingColor =
                 detectedPrice > lastPrice
                 ? bullColor
                 : bearColor

            if showZigzag and showGlow
                line newGlowLine = line.new(
                     x1 = lastBar,
                     y1 = lastPrice,
                     x2 = detectedBar,
                     y2 = detectedPrice,
                     xloc = xloc.bar_index,
                     extend = extend.none,
                     color = color.new(
                          swingColor,
                          84
                     ),
                     width = math.min(
                          lineWidth + 3,
                          6
                     )
                )

                array.push(
                     glowLines,
                     newGlowLine
                )

            if showZigzag
                line newStructureLine = line.new(
                     x1 = lastBar,
                     y1 = lastPrice,
                     x2 = detectedBar,
                     y2 = detectedPrice,
                     xloc = xloc.bar_index,
                     extend = extend.none,
                     color = swingColor,
                     width = lineWidth
                )

                array.push(
                     structureLines,
                     newStructureLine
                )

            array.push(
                 pivotPrices,
                 detectedPrice
            )

            array.push(
                 pivotBars,
                 detectedBar
            )

            array.push(
                 pivotTypes,
                 detectedType
            )

            array.push(
                 pivotOffsets,
                 detectedOffset
            )

            array.push(
                 structureNames,
                 newStructureName
            )

            label newSwingLabel = na

            bool validStructureName =
                 newStructureName != "H" and
                 newStructureName != "L"

            if showSwingLetters and validStructureName
                newSwingLabel := f_create_swing_letter(
                     detectedBar,
                     detectedPrice,
                     detectedOffset,
                     newStructureName,
                     detectedType
                )

            array.push(
                 pivotLabelRefs,
                 newSwingLabel
            )

            if detectedType == 1
                activeHighPrice := detectedPrice
                activeHighBar := detectedBar
                activeHighBroken := false
            else
                activeLowPrice := detectedPrice
                activeLowBar := detectedBar
                activeLowBroken := false

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 8. DEVELOPING UNCONFIRMED STRUCTURE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

int livePivotCount = array.size(pivotPrices)

if livePivotCount > 0
    int livePivotIndex = livePivotCount - 1

    int latestPivotBar = array.get(
         pivotBars,
         livePivotIndex
    )

    float latestPivotPrice = array.get(
         pivotPrices,
         livePivotIndex
    )

    int latestPivotType = array.get(
         pivotTypes,
         livePivotIndex
    )

    bool anchorChanged =
         na(developingAnchorBar) or
         developingAnchorBar != latestPivotBar or
         developingAnchorPrice != latestPivotPrice or
         developingAnchorType != latestPivotType

    // A newly confirmed or updated pivot becomes
    // the anchor of the developing structure.

    if anchorChanged
        developingAnchorBar := latestPivotBar
        developingAnchorPrice := latestPivotPrice
        developingAnchorType := latestPivotType

        developingExtremePrice :=
             latestPivotType == -1
             ? high
             : low

        developingExtremeBar := bar_index

        // Include bars formed after the historical pivot,
        // while it was waiting for confirmation.

        for offset = 0 to sensitivity - 1
            if bar_index - offset > latestPivotBar
                if latestPivotType == -1
                    if high[offset] > developingExtremePrice
                        developingExtremePrice := high[offset]
                        developingExtremeBar := bar_index - offset
                else
                    if low[offset] < developingExtremePrice
                        developingExtremePrice := low[offset]
                        developingExtremeBar := bar_index - offset

    // Continue updating the active extreme.

    else
        if latestPivotType == -1
            if na(developingExtremePrice) or high > developingExtremePrice
                developingExtremePrice := high
                developingExtremeBar := bar_index
        else
            if na(developingExtremePrice) or low < developingExtremePrice
                developingExtremePrice := low
                developingExtremeBar := bar_index

// Draw only one developing segment.

if barstate.islast
    bool canShowDeveloping =
         showZigzag and
         not na(developingAnchorBar) and
         not na(developingExtremeBar) and
         developingExtremeBar > developingAnchorBar

    if canShowDeveloping
        color developingColor =
             developingAnchorType == -1
             ? bullColor
             : bearColor

        if showGlow
            if na(developingGlowLine)
                developingGlowLine := line.new(
                     x1 = developingAnchorBar,
                     y1 = developingAnchorPrice,
                     x2 = developingExtremeBar,
                     y2 = developingExtremePrice,
                     xloc = xloc.bar_index,
                     extend = extend.none,
                     color = color.new(
                          developingColor,
                          88
                     ),
                     style = line.style_dashed,
                     width = math.min(
                          lineWidth + 3,
                          6
                     )
                )
            else
                line.set_xy1(
                     developingGlowLine,
                     developingAnchorBar,
                     developingAnchorPrice
                )

                line.set_xy2(
                     developingGlowLine,
                     developingExtremeBar,
                     developingExtremePrice
                )

                line.set_color(
                     developingGlowLine,
                     color.new(
                          developingColor,
                          88
                     )
                )

                line.set_style(
                     developingGlowLine,
                     line.style_dashed
                )

                line.set_width(
                     developingGlowLine,
                     math.min(
                          lineWidth + 3,
                          6
                     )
                )

        else if not na(developingGlowLine)
            line.delete(developingGlowLine)
            developingGlowLine := na

        if na(developingLine)
            developingLine := line.new(
                 x1 = developingAnchorBar,
                 y1 = developingAnchorPrice,
                 x2 = developingExtremeBar,
                 y2 = developingExtremePrice,
                 xloc = xloc.bar_index,
                 extend = extend.none,
                 color = developingColor,
                 style = line.style_dashed,
                 width = lineWidth
            )
        else
            line.set_xy1(
                 developingLine,
                 developingAnchorBar,
                 developingAnchorPrice
            )

            line.set_xy2(
                 developingLine,
                 developingExtremeBar,
                 developingExtremePrice
            )

            line.set_color(
                 developingLine,
                 developingColor
            )

            line.set_style(
                 developingLine,
                 line.style_dashed
            )

            line.set_width(
                 developingLine,
                 lineWidth
            )

    else
        if not na(developingLine)
            line.delete(developingLine)
            developingLine := na

        if not na(developingGlowLine)
            line.delete(developingGlowLine)
            developingGlowLine := na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 9. BOS / CHoCH ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

float bullishBreakValue =
     confirmByClose ? close : high

float bearishBreakValue =
     confirmByClose ? close : low

bool bullishBreak =
     not na(activeHighPrice) and
     not activeHighBroken and
     bar_index > activeHighBar and
     bullishBreakValue > activeHighPrice

bool bearishBreak =
     not na(activeLowPrice) and
     not activeLowBroken and
     bar_index > activeLowBar and
     bearishBreakValue < activeLowPrice

// Only one event can be processed on a bar.

if bullishBreak and not bearishBreak
    string eventName =
         marketTrend == -1
         ? "CHoCH"
         : "BOS"

    if showBreaks
        [newBreakLine, newBreakLabel] = f_create_break(
             activeHighBar,
             activeHighPrice,
             bar_index,
             eventName,
             1,
             currentEventOffset
        )

        array.push(
             breakLines,
             newBreakLine
        )

        array.push(
             breakLabels,
             newBreakLabel
        )

    marketTrend := 1
    latestEvent := eventName
    latestEventDirection := 1
    activeHighBroken := true

else if bearishBreak
    string eventName =
         marketTrend == 1
         ? "CHoCH"
         : "BOS"

    if showBreaks
        [newBreakLine, newBreakLabel] = f_create_break(
             activeLowBar,
             activeLowPrice,
             bar_index,
             eventName,
             -1,
             currentEventOffset
        )

        array.push(
             breakLines,
             newBreakLine
        )

        array.push(
             breakLabels,
             newBreakLabel
        )

    marketTrend := -1
    latestEvent := eventName
    latestEventDirection := -1
    activeLowBroken := true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 10. HISTORY LIMIT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

while array.size(pivotPrices) > visibleSwings + 1
    label oldestPivotLabel = array.shift(
         pivotLabelRefs
    )

    if not na(oldestPivotLabel)
        label.delete(oldestPivotLabel)

    array.shift(pivotPrices)
    array.shift(pivotBars)
    array.shift(pivotTypes)
    array.shift(pivotOffsets)
    array.shift(structureNames)

while array.size(structureLines) > visibleSwings
    line oldestStructureLine = array.shift(
         structureLines
    )

    line.delete(oldestStructureLine)

while array.size(glowLines) > visibleSwings
    line oldestGlowLine = array.shift(
         glowLines
    )

    line.delete(oldestGlowLine)

while array.size(breakLines) > visibleBreaks
    line oldestBreakLine = array.shift(
         breakLines
    )

    line.delete(oldestBreakLine)

while array.size(breakLabels) > visibleBreaks
    label oldestBreakLabel = array.shift(
         breakLabels
    )

    label.delete(oldestBreakLabel)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 11. DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var table statusPanel = table.new(
     f_panel_position(panelPositionInput),
     2,
     4,
     border_width = 0,
     frame_width = 0
)

if barstate.islast
    if showPanel
        string trendText =
             marketTrend == 1
             ? "BULLISH"
             : marketTrend == -1
             ? "BEARISH"
             : "WAITING"

        color trendColor =
             marketTrend == 1
             ? bullColor
             : marketTrend == -1
             ? bearColor
             : chochColor

        int structureCount = array.size(
             structureNames
        )

        string latestStructure =
             structureCount > 0
             ? array.get(
                  structureNames,
                  structureCount - 1
             )
             : "—"

        color latestStructureColor =
             latestStructure == "HH" or
             latestStructure == "HL"
             ? bullColor
             : latestStructure == "LH" or
             latestStructure == "LL"
             ? bearColor
             : color.white

        string eventText =
             latestEvent == "WAITING"
             ? "WAITING"
             : latestEvent +
               (
                    latestEventDirection == 1
                    ? " ↑"
                    : " ↓"
               )

        color eventColor =
             latestEvent == "CHoCH"
             ? chochColor
             : latestEventDirection == 1
             ? bullColor
             : latestEventDirection == -1
             ? bearColor
             : color.white

        color panelBackground =
             color.new(
                  color.rgb(27, 31, 41),
                  8
             )

        color mutedText =
             color.new(
                  color.white,
                  38
             )

        table.cell(
             statusPanel,
             0,
             0,
             "WAVESCOPE",
             text_color = color.white,
             bgcolor = panelBackground,
             text_size = size.small,
             text_halign = text.align_left
        )

        table.cell(
             statusPanel,
             1,
             0,
             "",
             bgcolor = panelBackground
        )

        table.cell(
             statusPanel,
             0,
             1,
             "Structure",
             text_color = mutedText,
             bgcolor = panelBackground,
             text_size = size.tiny,
             text_halign = text.align_left
        )

        table.cell(
             statusPanel,
             1,
             1,
             trendText,
             text_color = trendColor,
             bgcolor = panelBackground,
             text_size = size.small,
             text_halign = text.align_right
        )

        table.cell(
             statusPanel,
             0,
             2,
             "Last swing",
             text_color = mutedText,
             bgcolor = panelBackground,
             text_size = size.tiny,
             text_halign = text.align_left
        )

        table.cell(
             statusPanel,
             1,
             2,
             latestStructure,
             text_color = latestStructureColor,
             bgcolor = panelBackground,
             text_size = size.small,
             text_halign = text.align_right
        )

        table.cell(
             statusPanel,
             0,
             3,
             "Last event",
             text_color = mutedText,
             bgcolor = panelBackground,
             text_size = size.tiny,
             text_halign = text.align_left
        )

        table.cell(
             statusPanel,
             1,
             3,
             eventText,
             text_color = eventColor,
             bgcolor = panelBackground,
             text_size = size.small,
             text_halign = text.align_right
        )

    else
        table.clear(
             statusPanel,
             0,
             0,
             1,
             3
        )
````
