# Multi Pivot Points Standard

- url: https://www.tradingview.com/script/6X6X0DX5-Multi-Pivot-Points-Standard/
- type: indicator
- pine_id: PUB;95a1f2e35ea74a49a8e168d9805c6f3d
- version: 4.0

## Description

You can config up to 4 different standard pivot points.

## Source Code

````pine
//@version=6
indicator("Multi Pivot Points", "Multi Pivot Points", overlay = true, max_lines_count = 500, max_labels_count = 500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// General inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string TT_DB = (
     "When selected, pivots use daily/EOD-based values on intraday charts. "
   + "When not selected, pivots use intraday data. If extended hours are shown, "
   + "those values can affect the pivot calculations."
)

DW = display.data_window

int  maxHistoricalPivotsInput = input.int(1, "Number of pivots back", 1, 200, display = DW)
bool isDailyBasedInput        = input.bool(true, "Use daily-based values", tooltip = TT_DB, display = DW)

string GRP_LABELS             = "Labels"
bool   showLabelsInput        = input.bool(true, "Show labels", group = GRP_LABELS, display = DW)
bool   showPricesInput        = input.bool(false, "Show prices", group = GRP_LABELS, display = DW)
string positionLabelsInput    = input.string("Left", "Labels position", options = ["Left", "Right"], group = GRP_LABELS, display = DW)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Pivot set inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string PIVOT_TYPES = "Traditional"

string GRP_SET1 = "Pivot Set 1"
bool   set1EnabledInput = input.bool(true, "Enable", group = GRP_SET1, display = DW)
string set1PrefixInput  = input.string("D", "Label prefix", group = GRP_SET1, display = DW)
string set1TypeInput    = input.string("Traditional", "Type", options = ["Traditional", "Fibonacci", "Woodie", "Classic", "DM", "Camarilla"], group = GRP_SET1, display = DW)
string set1AnchorInput  = input.string("Daily", "Timeframe", options = ["Auto", "Daily", "Weekly", "Monthly", "Quarterly", "Yearly", "Biyearly", "Triyearly", "Quinquennially", "Decennially"], group = GRP_SET1, display = DW)
color  set1PColorInput  = input.color(#fb8c00, "P color", group = GRP_SET1, display = DW)
color  set1RColorInput  = input.color(#ffffff, "R color", group = GRP_SET1, display = DW)
color  set1SColorInput  = input.color(#ffffff, "S color", group = GRP_SET1, display = DW)
int    set1LineWidthInput = input.int(1, "Line width", 1, 100, group = GRP_SET1, display = DW)
bool   set1PShowInput  = input.bool(true, "P",  inline = "set1P", group = GRP_SET1, display = DW)
bool   set1R1ShowInput = input.bool(true, "R1", inline = "set11", group = GRP_SET1, display = DW)
bool   set1S1ShowInput = input.bool(true, "S1", inline = "set11", group = GRP_SET1, display = DW)
bool   set1R2ShowInput = input.bool(true, "R2", inline = "set12", group = GRP_SET1, display = DW)
bool   set1S2ShowInput = input.bool(true, "S2", inline = "set12", group = GRP_SET1, display = DW)
bool   set1R3ShowInput = input.bool(true, "R3", inline = "set13", group = GRP_SET1, display = DW)
bool   set1S3ShowInput = input.bool(true, "S3", inline = "set13", group = GRP_SET1, display = DW)
bool   set1R4ShowInput = input.bool(true, "R4", inline = "set14", group = GRP_SET1, display = DW)
bool   set1S4ShowInput = input.bool(true, "S4", inline = "set14", group = GRP_SET1, display = DW)
bool   set1R5ShowInput = input.bool(true, "R5", inline = "set15", group = GRP_SET1, display = DW)
bool   set1S5ShowInput = input.bool(true, "S5", inline = "set15", group = GRP_SET1, display = DW)

string GRP_SET2 = "Pivot Set 2"
bool   set2EnabledInput = input.bool(true, "Enable", group = GRP_SET2, display = DW)
string set2PrefixInput  = input.string("W", "Label prefix", group = GRP_SET2, display = DW)
string set2TypeInput    = input.string("Traditional", "Type", options = ["Traditional", "Fibonacci", "Woodie", "Classic", "DM", "Camarilla"], group = GRP_SET2, display = DW)
string set2AnchorInput  = input.string("Weekly", "Timeframe", options = ["Auto", "Daily", "Weekly", "Monthly", "Quarterly", "Yearly", "Biyearly", "Triyearly", "Quinquennially", "Decennially"], group = GRP_SET2, display = DW)
color  set2PColorInput  = input.color(#fb8c00, "P color", group = GRP_SET2, display = DW)
color  set2RColorInput  = input.color(#ffffff, "R color", group = GRP_SET2, display = DW)
color  set2SColorInput  = input.color(#ffffff, "S color", group = GRP_SET2, display = DW)
int    set2LineWidthInput = input.int(1, "Line width", 1, 100, group = GRP_SET2, display = DW)
bool   set2PShowInput  = input.bool(true, "P",  inline = "set2P", group = GRP_SET2, display = DW)
bool   set2R1ShowInput = input.bool(true, "R1", inline = "set21", group = GRP_SET2, display = DW)
bool   set2S1ShowInput = input.bool(true, "S1", inline = "set21", group = GRP_SET2, display = DW)
bool   set2R2ShowInput = input.bool(true, "R2", inline = "set22", group = GRP_SET2, display = DW)
bool   set2S2ShowInput = input.bool(true, "S2", inline = "set22", group = GRP_SET2, display = DW)
bool   set2R3ShowInput = input.bool(true, "R3", inline = "set23", group = GRP_SET2, display = DW)
bool   set2S3ShowInput = input.bool(true, "S3", inline = "set23", group = GRP_SET2, display = DW)
bool   set2R4ShowInput = input.bool(true, "R4", inline = "set24", group = GRP_SET2, display = DW)
bool   set2S4ShowInput = input.bool(true, "S4", inline = "set24", group = GRP_SET2, display = DW)
bool   set2R5ShowInput = input.bool(true, "R5", inline = "set25", group = GRP_SET2, display = DW)
bool   set2S5ShowInput = input.bool(true, "S5", inline = "set25", group = GRP_SET2, display = DW)

string GRP_SET3 = "Pivot Set 3"
bool   set3EnabledInput = input.bool(true, "Enable", group = GRP_SET3, display = DW)
string set3PrefixInput  = input.string("M", "Label prefix", group = GRP_SET3, display = DW)
string set3TypeInput    = input.string("Traditional", "Type", options = ["Traditional", "Fibonacci", "Woodie", "Classic", "DM", "Camarilla"], group = GRP_SET3, display = DW)
string set3AnchorInput  = input.string("Monthly", "Timeframe", options = ["Auto", "Daily", "Weekly", "Monthly", "Quarterly", "Yearly", "Biyearly", "Triyearly", "Quinquennially", "Decennially"], group = GRP_SET3, display = DW)
color  set3PColorInput  = input.color(#fb8c00, "P color", group = GRP_SET3, display = DW)
color  set3RColorInput  = input.color(#ffffff, "R color", group = GRP_SET3, display = DW)
color  set3SColorInput  = input.color(#ffffff, "S color", group = GRP_SET3, display = DW)
int    set3LineWidthInput = input.int(1, "Line width", 1, 100, group = GRP_SET3, display = DW)
bool   set3PShowInput  = input.bool(true, "P",  inline = "set3P", group = GRP_SET3, display = DW)
bool   set3R1ShowInput = input.bool(true, "R1", inline = "set31", group = GRP_SET3, display = DW)
bool   set3S1ShowInput = input.bool(true, "S1", inline = "set31", group = GRP_SET3, display = DW)
bool   set3R2ShowInput = input.bool(true, "R2", inline = "set32", group = GRP_SET3, display = DW)
bool   set3S2ShowInput = input.bool(true, "S2", inline = "set32", group = GRP_SET3, display = DW)
bool   set3R3ShowInput = input.bool(true, "R3", inline = "set33", group = GRP_SET3, display = DW)
bool   set3S3ShowInput = input.bool(true, "S3", inline = "set33", group = GRP_SET3, display = DW)
bool   set3R4ShowInput = input.bool(true, "R4", inline = "set34", group = GRP_SET3, display = DW)
bool   set3S4ShowInput = input.bool(true, "S4", inline = "set34", group = GRP_SET3, display = DW)
bool   set3R5ShowInput = input.bool(true, "R5", inline = "set35", group = GRP_SET3, display = DW)
bool   set3S5ShowInput = input.bool(true, "S5", inline = "set35", group = GRP_SET3, display = DW)

string GRP_SET4 = "Pivot Set 4"
bool   set4EnabledInput = input.bool(false, "Enable", group = GRP_SET4, display = DW)
string set4PrefixInput  = input.string("Q", "Label prefix", group = GRP_SET4, display = DW)
string set4TypeInput    = input.string("Traditional", "Type", options = ["Traditional", "Fibonacci", "Woodie", "Classic", "DM", "Camarilla"], group = GRP_SET4, display = DW)
string set4AnchorInput  = input.string("Quarterly", "Timeframe", options = ["Auto", "Daily", "Weekly", "Monthly", "Quarterly", "Yearly", "Biyearly", "Triyearly", "Quinquennially", "Decennially"], group = GRP_SET4, display = DW)
color  set4PColorInput  = input.color(#fb8c00, "P color", group = GRP_SET4, display = DW)
color  set4RColorInput  = input.color(#ffffff, "R color", group = GRP_SET4, display = DW)
color  set4SColorInput  = input.color(#ffffff, "S color", group = GRP_SET4, display = DW)
int    set4LineWidthInput = input.int(1, "Line width", 1, 100, group = GRP_SET4, display = DW)
bool   set4PShowInput  = input.bool(true, "P",  inline = "set4P", group = GRP_SET4, display = DW)
bool   set4R1ShowInput = input.bool(true, "R1", inline = "set41", group = GRP_SET4, display = DW)
bool   set4S1ShowInput = input.bool(true, "S1", inline = "set41", group = GRP_SET4, display = DW)
bool   set4R2ShowInput = input.bool(true, "R2", inline = "set42", group = GRP_SET4, display = DW)
bool   set4S2ShowInput = input.bool(true, "S2", inline = "set42", group = GRP_SET4, display = DW)
bool   set4R3ShowInput = input.bool(true, "R3", inline = "set43", group = GRP_SET4, display = DW)
bool   set4S3ShowInput = input.bool(true, "S3", inline = "set43", group = GRP_SET4, display = DW)
bool   set4R4ShowInput = input.bool(true, "R4", inline = "set44", group = GRP_SET4, display = DW)
bool   set4S4ShowInput = input.bool(true, "S4", inline = "set44", group = GRP_SET4, display = DW)
bool   set4R5ShowInput = input.bool(true, "R5", inline = "set45", group = GRP_SET4, display = DW)
bool   set4S5ShowInput = input.bool(true, "S5", inline = "set45", group = GRP_SET4, display = DW)

string GRP_SET5 = "Pivot Set 5"
bool   set5EnabledInput = input.bool(false, "Enable", group = GRP_SET5, display = DW)
string set5PrefixInput  = input.string("Y", "Label prefix", group = GRP_SET5, display = DW)
string set5TypeInput    = input.string("Traditional", "Type", options = ["Traditional", "Fibonacci", "Woodie", "Classic", "DM", "Camarilla"], group = GRP_SET5, display = DW)
string set5AnchorInput  = input.string("Yearly", "Timeframe", options = ["Auto", "Daily", "Weekly", "Monthly", "Quarterly", "Yearly", "Biyearly", "Triyearly", "Quinquennially", "Decennially"], group = GRP_SET5, display = DW)
color  set5PColorInput  = input.color(#fb8c00, "P color", group = GRP_SET5, display = DW)
color  set5RColorInput  = input.color(#ffffff, "R color", group = GRP_SET5, display = DW)
color  set5SColorInput  = input.color(#ffffff, "S color", group = GRP_SET5, display = DW)
int    set5LineWidthInput = input.int(1, "Line width", 1, 100, group = GRP_SET5, display = DW)
bool   set5PShowInput  = input.bool(true, "P",  inline = "set5P", group = GRP_SET5, display = DW)
bool   set5R1ShowInput = input.bool(true, "R1", inline = "set51", group = GRP_SET5, display = DW)
bool   set5S1ShowInput = input.bool(true, "S1", inline = "set51", group = GRP_SET5, display = DW)
bool   set5R2ShowInput = input.bool(true, "R2", inline = "set52", group = GRP_SET5, display = DW)
bool   set5S2ShowInput = input.bool(true, "S2", inline = "set52", group = GRP_SET5, display = DW)
bool   set5R3ShowInput = input.bool(true, "R3", inline = "set53", group = GRP_SET5, display = DW)
bool   set5S3ShowInput = input.bool(true, "S3", inline = "set53", group = GRP_SET5, display = DW)
bool   set5R4ShowInput = input.bool(true, "R4", inline = "set54", group = GRP_SET5, display = DW)
bool   set5S4ShowInput = input.bool(true, "S4", inline = "set54", group = GRP_SET5, display = DW)
bool   set5R5ShowInput = input.bool(true, "R5", inline = "set55", group = GRP_SET5, display = DW)
bool   set5S5ShowInput = input.bool(true, "S5", inline = "set55", group = GRP_SET5, display = DW)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Custom types
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

type pivotGraphic
    line  pivotLine
    label pivotLabel

type pivotVisibility
    bool p
    bool r1
    bool s1
    bool r2
    bool s2
    bool r3
    bool s3
    bool r4
    bool s4
    bool r5
    bool s5

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Per-set level visibility
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pivotVisibility set1Visibility = pivotVisibility.new(set1PShowInput, set1R1ShowInput, set1S1ShowInput, set1R2ShowInput, set1S2ShowInput, set1R3ShowInput, set1S3ShowInput, set1R4ShowInput, set1S4ShowInput, set1R5ShowInput, set1S5ShowInput)
pivotVisibility set2Visibility = pivotVisibility.new(set2PShowInput, set2R1ShowInput, set2S1ShowInput, set2R2ShowInput, set2S2ShowInput, set2R3ShowInput, set2S3ShowInput, set2R4ShowInput, set2S4ShowInput, set2R5ShowInput, set2S5ShowInput)
pivotVisibility set3Visibility = pivotVisibility.new(set3PShowInput, set3R1ShowInput, set3S1ShowInput, set3R2ShowInput, set3S2ShowInput, set3R3ShowInput, set3S3ShowInput, set3R4ShowInput, set3S4ShowInput, set3R5ShowInput, set3S5ShowInput)
pivotVisibility set4Visibility = pivotVisibility.new(set4PShowInput, set4R1ShowInput, set4S1ShowInput, set4R2ShowInput, set4S2ShowInput, set4R3ShowInput, set4S3ShowInput, set4R4ShowInput, set4S4ShowInput, set4R5ShowInput, set4S5ShowInput)
pivotVisibility set5Visibility = pivotVisibility.new(set5PShowInput, set5R1ShowInput, set5S1ShowInput, set5R2ShowInput, set5S2ShowInput, set5R3ShowInput, set5S3ShowInput, set5R4ShowInput, set5S4ShowInput, set5R5ShowInput, set5S5ShowInput)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Helper functions
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

autoAnchor(simple bool isDailyBased) =>
    timeframe.isintraday ? timeframe.multiplier <= 15 ? isDailyBased ? "1D" : "1440" : "1W" :
     timeframe.isdaily ? "1M" :
     "12M"

anchorToTimeframe(simple string anchor, simple bool isDailyBased) =>
    switch anchor
        "Auto"      => autoAnchor(isDailyBased)
        "Daily"     => isDailyBased ? "1D" : "1440"
        "Weekly"    => "1W"
        "Monthly"   => "1M"
        "Quarterly" => "3M"
        => "12M"

anchorToYearMultiplier(simple string anchor) =>
    switch anchor
        "Biyearly"       => 2
        "Triyearly"      => 3
        "Quinquennially" => 5
        "Decennially"    => 10
        => 1

levelName(int index) =>
    switch index
        0  => "P"
        1  => "R1"
        2  => "S1"
        3  => "R2"
        4  => "S2"
        5  => "R3"
        6  => "S3"
        7  => "R4"
        8  => "S4"
        9  => "R5"
        10 => "S5"
        => ""

isResistanceLevel(int index) =>
    index == 1 or index == 3 or index == 5 or index == 7 or index == 9

isSupportLevel(int index) =>
    index == 2 or index == 4 or index == 6 or index == 8 or index == 10

levelColor(int index, color pColor, color rColor, color sColor) =>
    index == 0 ? pColor : isResistanceLevel(index) ? rColor : sColor

userWantsLevel(int index, pivotVisibility visibility) =>
    switch index
        0  => visibility.p
        1  => visibility.r1
        2  => visibility.s1
        3  => visibility.r2
        4  => visibility.s2
        5  => visibility.r3
        6  => visibility.s3
        7  => visibility.r4
        8  => visibility.s4
        9  => visibility.r5
        10 => visibility.s5
        => false

pivotTypeAllowsLevel(simple string pivotType, int index) =>
    bool showLevel2and3 = pivotType != "DM"
    bool showLevel4     = pivotType != "DM" and pivotType != "Fibonacci"
    bool showLevel5     = pivotType == "Traditional" or pivotType == "Camarilla"

    switch index
        0  => true
        1  => true
        2  => true
        3  => showLevel2and3
        4  => showLevel2and3
        5  => showLevel2and3
        6  => showLevel2and3
        7  => showLevel4
        8  => showLevel4
        9  => showLevel5
        10 => showLevel5
        => false

pivotTimeframeChangeCounter(bool condition) =>
    var int count = 0
    if condition and bar_index > 0
        count += 1
    count

method delete(pivotGraphic graphic) =>
    graphic.pivotLine.delete()
    graphic.pivotLabel.delete()

calculatePivots(simple string pivotType, simple string pivotTimeframe, simple int pivotYearMultiplier, simple bool isDailyBased) =>
    if isDailyBased
        bool pivotTimeframeChange = (
            timeframe.change(timeframe.period) and year(time_tradingday, syminfo.timezone) % pivotYearMultiplier == 0
        )

        [pivotPointsArrayStatic, pivotPointsArrayDeveloping, pivotCounter] = request.security(
             ticker.modify(syminfo.tickerid, settlement_as_close = settlement_as_close.on),
             pivotTimeframe,
             [
                 ta.pivot_point_levels(pivotType, pivotTimeframeChange),
                 ta.pivot_point_levels(pivotType, pivotTimeframeChange, developing = pivotType != "Woodie"),
                 pivotTimeframeChangeCounter(pivotTimeframeChange)
             ],
             lookahead = barmerge.lookahead_on
        )

        [pivotPointsArrayStatic, pivotPointsArrayDeveloping, pivotCounter]
    else
        bool pivotTimeframeChange = (
            timeframe.change(pivotTimeframe) and year(time_tradingday, syminfo.timezone) % pivotYearMultiplier == 0
        )

        array<float> pivotPointsArrayStatic = ta.pivot_point_levels(pivotType, pivotTimeframeChange)
        array<float> pivotPointsArrayDeveloping = ta.pivot_point_levels(
             pivotType,
             pivotTimeframeChange,
             developing = pivotType != "Woodie"
        )

        int pivotCounter = pivotTimeframeChangeCounter(pivotTimeframeChange)

        [pivotPointsArrayStatic, pivotPointsArrayDeveloping, pivotCounter]

affixOldPivots(matrix<pivotGraphic> drawnGraphics, int endTime) =>
    int rows = drawnGraphics.rows()

    if rows > 0
        array<pivotGraphic> lastGraphics = drawnGraphics.row(rows - 1)

        for graphic in lastGraphics
            graphic.pivotLine.set_x2(endTime)

            if positionLabelsInput == "Right"
                graphic.pivotLabel.set_x(endTime)

drawNewPivots(
     matrix<pivotGraphic> drawnGraphics,
     int startTime,
     array<float> pivotPointsArray,
     simple string pivotType,
     string prefix,
     color pColor,
     color rColor,
     color sColor,
     simple int lineWidth,
     pivotVisibility visibility,
     simple string pivotTimeframe,
     simple int pivotYearMultiplier
 ) =>
    // Important: a pivot set can have no usable data while other sets do.
    // In that case, skip drawing this set instead of causing a script-wide stop.
    if not na(pivotPointsArray) and pivotPointsArray.size() > 0
        array<pivotGraphic> newGraphics = array.new<pivotGraphic>()

        int endTime = startTime + timeframe.in_seconds(pivotTimeframe) * 1000 * pivotYearMultiplier

        [labelPosition, labelStyle] = switch positionLabelsInput
            "Left"  => [startTime, label.style_label_right]
            "Right" => [endTime, label.style_label_left]

        for [index, level] in pivotPointsArray
            bool shouldDrawLevel = not na(level) and userWantsLevel(index, visibility) and pivotTypeAllowsLevel(pivotType, index)

            if shouldDrawLevel
                string name = levelName(index)
                color currentLevelColor = levelColor(index, pColor, rColor, sColor)

                string labelText = (
                     (showLabelsInput ? prefix + " " + name + " " : "")
                   + (showPricesInput ? "(" + str.tostring(level, format.mintick) + ")" : "")
                )

                line pivotLine = line.new(
                     startTime,
                     level,
                     endTime,
                     level,
                     xloc = xloc.bar_time,
                     color = currentLevelColor,
                     width = lineWidth
                )

                label pivotLabel = label.new(
                     labelPosition,
                     level,
                     labelText,
                     style = labelStyle,
                     textcolor = currentLevelColor,
                     color = #00000000,
                     xloc = xloc.bar_time
                )

                newGraphics.push(pivotGraphic.new(pivotLine, pivotLabel))

        if newGraphics.size() > 0
            drawnGraphics.add_row(array_id = newGraphics)

            if drawnGraphics.rows() > maxHistoricalPivotsInput
                array<pivotGraphic> oldGraphics = drawnGraphics.remove_row(0)

                for graphic in oldGraphics
                    graphic.delete()

processPivotSet(
     bool enabled,
     matrix<pivotGraphic> drawnGraphics,
     simple string pivotType,
     simple string pivotTimeframe,
     simple int pivotYearMultiplier,
     array<float> pivotPointsArrayStatic,
     array<float> pivotPointsArrayDeveloping,
     int pivotCount,
     bool skipNextPivots,
     int firstBarTime,
     string prefix,
     color pColor,
     color rColor,
     color sColor,
     simple int lineWidth,
     pivotVisibility visibility
 ) =>
    bool newSkipNextPivots = skipNextPivots

    if enabled
        if barstate.islast and barstate.isconfirmed and pivotType != "Woodie"
            int nextBarOpenTime = time("", bars_back = -1)
            int nextPivotStartTime = time(pivotTimeframe, timeframe_bars_back = -1)

            if nextBarOpenTime >= nextPivotStartTime
                affixOldPivots(drawnGraphics, nextPivotStartTime)
                drawNewPivots(
                     drawnGraphics,
                     nextPivotStartTime,
                     pivotPointsArrayDeveloping,
                     pivotType,
                     prefix,
                     pColor,
                     rColor,
                     sColor,
                     lineWidth,
                     visibility,
                     pivotTimeframe,
                     pivotYearMultiplier
                )
                newSkipNextPivots := true

        if pivotCount != pivotCount[1]
            if newSkipNextPivots
                newSkipNextPivots := false
            else
                affixOldPivots(drawnGraphics, time)
                drawNewPivots(
                     drawnGraphics,
                     time,
                     pivotPointsArrayStatic,
                     pivotType,
                     prefix,
                     pColor,
                     rColor,
                     sColor,
                     lineWidth,
                     visibility,
                     pivotTimeframe,
                     pivotYearMultiplier
                )

        else if drawnGraphics.rows() > 0 and drawnGraphics.row(drawnGraphics.rows() - 1).last().pivotLine.get_x2() <= time[1]
            affixOldPivots(drawnGraphics, time)

        // Do not use runtime.error here. A runtime error stops the whole indicator,
        // so one unavailable pivot set would prevent all other independent sets from showing.
        if barstate.islastconfirmedhistory and drawnGraphics.rows() == 0
            if pivotCount > 0 and not na(pivotPointsArrayStatic)
                drawNewPivots(
                     drawnGraphics,
                     firstBarTime,
                     pivotPointsArrayStatic,
                     pivotType,
                     prefix,
                     pColor,
                     rColor,
                     sColor,
                     lineWidth,
                     visibility,
                     pivotTimeframe,
                     pivotYearMultiplier
                )

    newSkipNextPivots

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Per-set calculation
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

simple string set1Timeframe = anchorToTimeframe(set1AnchorInput, isDailyBasedInput)
simple string set2Timeframe = anchorToTimeframe(set2AnchorInput, isDailyBasedInput)
simple string set3Timeframe = anchorToTimeframe(set3AnchorInput, isDailyBasedInput)
simple string set4Timeframe = anchorToTimeframe(set4AnchorInput, isDailyBasedInput)
simple string set5Timeframe = anchorToTimeframe(set5AnchorInput, isDailyBasedInput)

simple int set1YearMultiplier = anchorToYearMultiplier(set1AnchorInput)
simple int set2YearMultiplier = anchorToYearMultiplier(set2AnchorInput)
simple int set3YearMultiplier = anchorToYearMultiplier(set3AnchorInput)
simple int set4YearMultiplier = anchorToYearMultiplier(set4AnchorInput)
simple int set5YearMultiplier = anchorToYearMultiplier(set5AnchorInput)

[pivotPointsArrayStatic1, pivotPointsArrayDeveloping1, pivotCount1] = calculatePivots(set1TypeInput, set1Timeframe, set1YearMultiplier, isDailyBasedInput)
[pivotPointsArrayStatic2, pivotPointsArrayDeveloping2, pivotCount2] = calculatePivots(set2TypeInput, set2Timeframe, set2YearMultiplier, isDailyBasedInput)
[pivotPointsArrayStatic3, pivotPointsArrayDeveloping3, pivotCount3] = calculatePivots(set3TypeInput, set3Timeframe, set3YearMultiplier, isDailyBasedInput)
[pivotPointsArrayStatic4, pivotPointsArrayDeveloping4, pivotCount4] = calculatePivots(set4TypeInput, set4Timeframe, set4YearMultiplier, isDailyBasedInput)
[pivotPointsArrayStatic5, pivotPointsArrayDeveloping5, pivotCount5] = calculatePivots(set5TypeInput, set5Timeframe, set5YearMultiplier, isDailyBasedInput)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Per-set drawing storage
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var matrix<pivotGraphic> drawnGraphics1 = matrix.new<pivotGraphic>()
var matrix<pivotGraphic> drawnGraphics2 = matrix.new<pivotGraphic>()
var matrix<pivotGraphic> drawnGraphics3 = matrix.new<pivotGraphic>()
var matrix<pivotGraphic> drawnGraphics4 = matrix.new<pivotGraphic>()
var matrix<pivotGraphic> drawnGraphics5 = matrix.new<pivotGraphic>()

var bool skipNextPivots1 = false
var bool skipNextPivots2 = false
var bool skipNextPivots3 = false
var bool skipNextPivots4 = false
var bool skipNextPivots5 = false

var int firstBarTime = time

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Draw each enabled pivot set
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

skipNextPivots1 := processPivotSet(
     set1EnabledInput,
     drawnGraphics1,
     set1TypeInput,
     set1Timeframe,
     set1YearMultiplier,
     pivotPointsArrayStatic1,
     pivotPointsArrayDeveloping1,
     pivotCount1,
     skipNextPivots1,
     firstBarTime,
     set1PrefixInput,
     set1PColorInput,
     set1RColorInput,
     set1SColorInput,
     set1LineWidthInput,
     set1Visibility
)

skipNextPivots2 := processPivotSet(
     set2EnabledInput,
     drawnGraphics2,
     set2TypeInput,
     set2Timeframe,
     set2YearMultiplier,
     pivotPointsArrayStatic2,
     pivotPointsArrayDeveloping2,
     pivotCount2,
     skipNextPivots2,
     firstBarTime,
     set2PrefixInput,
     set2PColorInput,
     set2RColorInput,
     set2SColorInput,
     set2LineWidthInput,
     set2Visibility
)

skipNextPivots3 := processPivotSet(
     set3EnabledInput,
     drawnGraphics3,
     set3TypeInput,
     set3Timeframe,
     set3YearMultiplier,
     pivotPointsArrayStatic3,
     pivotPointsArrayDeveloping3,
     pivotCount3,
     skipNextPivots3,
     firstBarTime,
     set3PrefixInput,
     set3PColorInput,
     set3RColorInput,
     set3SColorInput,
     set3LineWidthInput,
     set3Visibility
)

skipNextPivots4 := processPivotSet(
     set4EnabledInput,
     drawnGraphics4,
     set4TypeInput,
     set4Timeframe,
     set4YearMultiplier,
     pivotPointsArrayStatic4,
     pivotPointsArrayDeveloping4,
     pivotCount4,
     skipNextPivots4,
     firstBarTime,
     set4PrefixInput,
     set4PColorInput,
     set4RColorInput,
     set4SColorInput,
     set4LineWidthInput,
     set4Visibility
)

skipNextPivots5 := processPivotSet(
     set5EnabledInput,
     drawnGraphics5,
     set5TypeInput,
     set5Timeframe,
     set5YearMultiplier,
     pivotPointsArrayStatic5,
     pivotPointsArrayDeveloping5,
     pivotCount5,
     skipNextPivots5,
     firstBarTime,
     set5PrefixInput,
     set5PColorInput,
     set5RColorInput,
     set5SColorInput,
     set5LineWidthInput,
     set5Visibility
)
````
