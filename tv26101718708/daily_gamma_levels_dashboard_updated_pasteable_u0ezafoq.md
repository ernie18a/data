# Daily Gamma Levels Dashboard Updated  (Pasteable)

- url: https://www.tradingview.com/script/U0eZaFOQ-Daily-Gamma-Levels-Dashboard-Updated-Pasteable/
- type: indicator
- pine_id: PUB;0b4dbbe062ff4aea91662e0003983c98
- version: 1.0

## Description

It is a TradingView Pine Script indicator for daily gamma and key market levels. Its purpose is to let you paste a fresh block of daily levels into the settings each day instead of editing the source code manually.
The script reads the row that matches the chart symbol, converts those pasted values into horizontal price lines across the chart, and labels the important levels so you can quickly see where call walls, put walls, zero gamma, volatility trigger, implied move levels, risk pivots, and any other custom fields sit relative to current price.
It also includes a small info table so the levels can be read numerically, and it can merge nearby labels when two levels are close together, which keeps the chart cleaner while still preserving the separate horizontal lines.
In short, it is used to create a daily, manually refreshed gamma-level dashboard on your chart so you can track market structure and important dealer-related price zones visually.

## Source Code

````pine
//@version=6
indicator("Daily Gamma Levels Dashboard (Pasteable)", shorttitle="Gamma Levels Paste", overlay=true, max_lines_count=200, max_labels_count=200, max_boxes_count=10)

// ============================================================
//  HOW TO USE
//  1) Open Settings -> Inputs.
//  2) Paste your full daily CSV block into "Paste Daily Levels".
//  3) Leave Symbol Override blank to auto-match the current chart.
//  4) If you want different names for the 14 numeric columns,
//     update "Column Labels" once and keep reusing the same format.
// ============================================================

int LEVEL_COUNT = 14
int TOKENS_PER_ROW = LEVEL_COUNT + 2

// ==========================================
// --- DAILY LEVEL INPUT ---
// ==========================================
grp_data = "Daily Levels Input"
rawLevelsInput = input.text_area("$SPX, SPX, 7100, 6800, 6870, 7000, 7050, 6000, 7100, 7098, 7048, 7076, 7203, 0.0066, 0.0147, 6895", "Paste Daily Levels", group=grp_data, tooltip="Paste the full comma-separated daily levels block here. One symbol row must contain 2 text fields followed by 14 numeric values.")
symbolOverride = input.string("", "Symbol Override", group=grp_data, tooltip="Leave blank to auto-use the current chart ticker. Use this only if your chart ticker does not match the pasted symbol row.")
columnLabelsCsv = input.string("Call Wall,Put Wall,Zero Gamma,Vol Trigger,Level 5,Level 6,Level 7,Implied Move Low,Implied Move High,Level 10,Level 11,Metric 12,Metric 13,Risk Pivot", "Column Labels", group=grp_data, tooltip="Comma-separated names for the 14 numeric fields in each symbol row. You only need to set this once if your data provider uses a fixed order.")
plotColumnsCsv = input.string("1,2,3,4,5,6,7,8,9,10,11,12,13,14", "Plot Columns As Horizontal Lines", group=grp_data, tooltip="Enter the numeric field positions that should draw horizontal lines. By default, all pasted level columns are plotted. Remove columns here only if a value is a non-price metric that you do not want drawn on the chart.")
plotMinValue = input.float(1.0, "Minimum Absolute Value To Plot As Price Level", group=grp_data, minval=0.0, step=0.01, tooltip="Very small values, such as percentages, stay in the table only. Price-style levels above this threshold can draw as chart lines.")

// ==========================================
// --- DISPLAY SETTINGS ---
// ==========================================
grp_display = "Display Settings"
showLabels = input.bool(true, "Show Line Labels", group=grp_display)
showTable = input.bool(true, "Show Info Table", group=grp_display)
mergeNearbyLabels = input.bool(true, "Merge Nearby Labels", group=grp_display, tooltip="If enabled, nearby levels keep their own horizontal lines but share one combined label for visibility.")
mergeDistance = input.float(3.0, "Merge Labels Within (points)", group=grp_display, minval=0.0, step=0.25, tooltip="If two plotted levels are within this price distance, their names merge into one shared label.")
extendBars = input.int(30, "Push Label Right (bars)", group=grp_display, minval=5, maxval=500)
labelSizeInput = input.string("Small", "Label Size", group=grp_display, options=["Small", "Medium", "Large"])
lineWidthInput = input.string("Small", "Line Width", group=grp_display, options=["Small", "Medium", "Large"])
lineStyleInput = input.string("Solid", "Line Style", group=grp_display, options=["Solid", "Dashed", "Dotted"])

// ==========================================
// --- COLORS ---
// ==========================================
grp_colors = "Colors"
col_resistance = input.color(color.red, "Resistance / Upside", group=grp_colors)
col_support = input.color(color.lime, "Support / Downside", group=grp_colors)
col_gamma = input.color(color.fuchsia, "Gamma", group=grp_colors)
col_move = input.color(color.aqua, "Implied Move / Metric", group=grp_colors)
col_pivot = input.color(color.yellow, "Pivot / Risk", group=grp_colors)
col_custom = input.color(color.white, "Other Levels", group=grp_colors)
col_header = input.color(color.new(color.blue, 40), "Table Header", group=grp_colors)

// ==========================================
// --- RESOLVE DISPLAY SETTINGS ---
// ==========================================
int lineW = lineWidthInput == "Large" ? 3 : lineWidthInput == "Medium" ? 2 : 1
string labelSz = labelSizeInput == "Large" ? size.large : labelSizeInput == "Medium" ? size.normal : size.small
string lineStyl = lineStyleInput == "Dotted" ? line.style_dotted : lineStyleInput == "Dashed" ? line.style_dashed : line.style_solid

// ==========================================
// --- HELPERS ---
// ==========================================
normalizeSymbol(string s) =>
    string cleaned = str.upper(str.trim(s))
    cleaned := str.replace_all(cleaned, "$", "")
    cleaned := str.replace_all(cleaned, " ", "")
    cleaned

formatValue(float v) =>
    bool isPct = math.abs(v) < 1 and v != 0
    isPct ? str.tostring(v * 100, "#.##") + "%" : str.tostring(v, "#.##")

isMetricValue(float v, string lbl) =>
    string u = str.upper(lbl)
    bool labelSuggestsMetric = str.contains(u, "%") or str.contains(u, "PCT") or str.contains(u, "PERCENT") or str.contains(u, "IV") or str.contains(u, "RATIO")
    labelSuggestsMetric or math.abs(v) < plotMinValue

pickColor(string lbl, float price) =>
    string u = str.upper(lbl)
    str.contains(u, "CALL") ? col_resistance :
     str.contains(u, "PUT") ? col_support :
     (str.contains(u, "GAMMA") or str.contains(u, "ZERO")) ? col_gamma :
     (str.contains(u, "IMPLIED") or str.contains(u, "MOVE") or str.contains(u, "VOL")) ? col_move :
     (str.contains(u, "PIVOT") or str.contains(u, "RISK")) ? col_pivot :
     price >= close ? col_resistance : col_support

isPlotColumn(int columnNumber, array<string> tokens) =>
    bool found = false
    for j = 0 to array.size(tokens) - 1
        string plotToken = str.trim(array.get(tokens, j))
        if plotToken != "" and str.tonumber(plotToken) == columnNumber
            found := true
    found

updateLine(line ln, label lb, float price, string txt, color col, bool showLine, bool showText) =>
    int leftBar = math.max(bar_index - 1, 0)
    int rightBar = bar_index + 1
    if showLine and not na(price)
        line.set_x1(ln, leftBar)
        line.set_x2(ln, rightBar)
        line.set_y1(ln, price)
        line.set_y2(ln, price)
        line.set_extend(ln, extend.both)
        line.set_color(ln, col)
        line.set_width(ln, lineW)
        line.set_style(ln, lineStyl)
        label.set_x(lb, bar_index + extendBars)
        label.set_y(lb, price)
        label.set_text(lb, showLabels and showText ? txt : "")
        label.set_textcolor(lb, col)
        label.set_size(lb, labelSz)
    else
        line.set_x1(ln, leftBar)
        line.set_x2(ln, rightBar)
        line.set_y1(ln, 0.0)
        line.set_y2(ln, 0.0)
        line.set_extend(ln, extend.none)
        label.set_text(lb, "")
    true

fillInfoRow(table t, int row, string lbl, float price, bool treatAsLevel) =>
    color rowCol = pickColor(lbl, nz(price, close))
    string distStr = ""
    color distCol = color.silver
    if treatAsLevel
        float dist = close - price
        distStr := (dist >= 0 ? "+" : "") + str.tostring(dist, "#.##")
        distCol := dist >= 0 ? color.lime : color.red
    table.cell(t, 0, row, lbl, text_color=rowCol, text_size=size.tiny)
    table.cell(t, 1, row, formatValue(price), text_color=rowCol, text_size=size.tiny)
    table.cell(t, 2, row, distStr, text_color=distCol, text_size=size.tiny)
    true

// ==========================================
// --- STORAGE ARRAYS ---
// ==========================================
var array<float> activeValues = array.new<float>(LEVEL_COUNT, na)
var array<string> activeLabels = array.new<string>(LEVEL_COUNT, "")
var array<line> levelLines = array.new<line>()
var array<label> levelLabels = array.new<label>()
var array<bool> plotFlags = array.new<bool>(LEVEL_COUNT, false)
var array<bool> showMergedLabelFlags = array.new<bool>(LEVEL_COUNT, false)
var array<string> mergedLabelTexts = array.new<string>(LEVEL_COUNT, "")
var table infoTable = table.new(position.top_right, 3, LEVEL_COUNT + 2, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.new(color.gray, 65))

if barstate.isfirst
    for i = 0 to LEVEL_COUNT - 1
        array.push(levelLines, line.new(x1=bar_index, y1=0.0, x2=bar_index + 1, y2=0.0, xloc=xloc.bar_index, extend=extend.none, color=col_custom, width=lineW, style=lineStyl))
        array.push(levelLabels, label.new(x=bar_index + 1, y=0.0, text="", style=label.style_none, textcolor=col_custom, size=labelSz, xloc=xloc.bar_index))

// ==========================================
// --- LOAD LABEL NAMES / RESET STATE ---
// ==========================================
for i = 0 to LEVEL_COUNT - 1
    array.set(activeValues, i, na)
    array.set(activeLabels, i, "Level " + str.tostring(i + 1))
    array.set(plotFlags, i, false)
    array.set(showMergedLabelFlags, i, false)
    array.set(mergedLabelTexts, i, "")

array<string> labelTokens = str.split(columnLabelsCsv, ",")
array<string> plotTokens = str.split(plotColumnsCsv, ",")
for i = 0 to LEVEL_COUNT - 1
    string fallback = "Level " + str.tostring(i + 1)
    string lbl = array.size(labelTokens) > i ? str.trim(array.get(labelTokens, i)) : fallback
    array.set(activeLabels, i, lbl == "" ? fallback : lbl)

// ==========================================
// --- PARSE PASTED DAILY LEVELS ---
// ==========================================
string targetSymbol = normalizeSymbol(symbolOverride == "" ? syminfo.ticker : symbolOverride)
string cleanedLevels = str.replace_all(str.replace_all(rawLevelsInput, "\n", ","), "\r", ",")
array<string> rawTokens = str.split(cleanedLevels, ",")
int rowCount = int(math.floor(array.size(rawTokens) / TOKENS_PER_ROW))

bool rowFound = false
string matchedSymbol = ""

if rowCount > 0
    for row = 0 to rowCount - 1
        int rowStart = row * TOKENS_PER_ROW
        string aliasOne = normalizeSymbol(array.get(rawTokens, rowStart))
        string aliasTwo = normalizeSymbol(array.get(rawTokens, rowStart + 1))
        if aliasOne == targetSymbol or aliasTwo == targetSymbol
            rowFound := true
            matchedSymbol := str.trim(array.get(rawTokens, rowStart + 1))
            for i = 0 to LEVEL_COUNT - 1
                string rawVal = str.trim(array.get(rawTokens, rowStart + 2 + i))
                array.set(activeValues, i, str.tonumber(rawVal))
            break

// ==========================================
// --- BUILD PLOT AND MERGED LABEL STATE ---
// ==========================================
if barstate.islast
    for i = 0 to LEVEL_COUNT - 1
        float price = array.get(activeValues, i)
        string lbl = array.get(activeLabels, i)
        bool shouldPlotColumn = isPlotColumn(i + 1, plotTokens)
        bool drawLine = rowFound and not na(price) and shouldPlotColumn and math.abs(price) >= plotMinValue
        array.set(plotFlags, i, drawLine)
        array.set(showMergedLabelFlags, i, drawLine)
        array.set(mergedLabelTexts, i, lbl + "  " + formatValue(price))

    if mergeNearbyLabels and rowFound
        for i = 0 to LEVEL_COUNT - 1
            if array.get(plotFlags, i)
                float basePrice = array.get(activeValues, i)
                bool hasEarlierNearby = false
                if i > 0
                    for j = 0 to i - 1
                        if array.get(plotFlags, j)
                            float otherPrice = array.get(activeValues, j)
                            if math.abs(basePrice - otherPrice) <= mergeDistance
                                hasEarlierNearby := true
                if hasEarlierNearby
                    array.set(showMergedLabelFlags, i, false)
                else
                    string mergedNames = array.get(activeLabels, i)
                    if i < LEVEL_COUNT - 1
                        for j = i + 1 to LEVEL_COUNT - 1
                            if array.get(plotFlags, j)
                                float otherPrice = array.get(activeValues, j)
                                if math.abs(basePrice - otherPrice) <= mergeDistance
                                    mergedNames += " / " + array.get(activeLabels, j)
                                    array.set(showMergedLabelFlags, j, false)
                    array.set(mergedLabelTexts, i, mergedNames + "  " + formatValue(basePrice))

// ==========================================
// --- UPDATE LINES ---
// ==========================================
if barstate.islast
    for i = 0 to LEVEL_COUNT - 1
        line ln = array.get(levelLines, i)
        label lb = array.get(levelLabels, i)
        float price = array.get(activeValues, i)
        string lbl = array.get(activeLabels, i)
        color col = pickColor(lbl, nz(price, close))
        bool drawLine = array.get(plotFlags, i)
        bool showMergedLabel = array.get(showMergedLabelFlags, i)
        string txt = array.get(mergedLabelTexts, i)
        updateLine(ln, lb, price, txt, col, drawLine, showMergedLabel)

// ==========================================
// --- INFO TABLE ---
// ==========================================
if barstate.islast
    if showTable
        table.cell(infoTable, 0, 0, rowFound ? matchedSymbol + " LEVELS" : "NO MATCH", text_color=color.white, text_size=size.small, bgcolor=col_header)
        table.cell(infoTable, 1, 0, "Value", text_color=color.white, text_size=size.tiny, bgcolor=col_header)
        table.cell(infoTable, 2, 0, "Dist", text_color=color.white, text_size=size.tiny, bgcolor=col_header)

        for i = 0 to LEVEL_COUNT - 1
            float price = array.get(activeValues, i)
            string lbl = array.get(activeLabels, i)
            int row = i + 1
            bool treatAsLevel = array.get(plotFlags, i) or not isMetricValue(price, lbl)
            if rowFound and not na(price)
                fillInfoRow(infoTable, row, lbl, price, treatAsLevel)
            else
                table.cell(infoTable, 0, row, "", text_color=color.white, text_size=size.tiny)
                table.cell(infoTable, 1, row, "", text_color=color.white, text_size=size.tiny)
                table.cell(infoTable, 2, row, "", text_color=color.white, text_size=size.tiny)

        string statusText = rowFound ? "Close: " + str.tostring(close, "#.##") : "Paste data or use Symbol Override"
        string gammaState = ""
        float zeroGamma = array.get(activeValues, 2)
        if rowFound and not na(zeroGamma) and math.abs(zeroGamma) >= plotMinValue
            gammaState := close > zeroGamma ? " | Above Zero Gamma" : " | Below Zero Gamma"
        table.cell(infoTable, 0, LEVEL_COUNT + 1, statusText + gammaState, text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.blue, 20))
        table.cell(infoTable, 1, LEVEL_COUNT + 1, targetSymbol, text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.blue, 20))
        table.cell(infoTable, 2, LEVEL_COUNT + 1, rowFound ? "OK" : "WAIT", text_color=rowFound ? color.lime : color.orange, text_size=size.tiny, bgcolor=color.new(color.blue, 20))
    else
        for row = 0 to LEVEL_COUNT + 1
            table.cell(infoTable, 0, row, "")
            table.cell(infoTable, 1, row, "")
            table.cell(infoTable, 2, row, "")
````
