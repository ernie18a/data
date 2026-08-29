<!-- tradingview-pine-id: PUB;ca130e09383342f2a92d85d85aedbb8a -->
<!-- tradingviewscripts-format: 1 -->
# GEX Smart Loader — Build 0.2

Source: https://www.tradingview.com/script/HppLMFr2-Andi-GEX-Smart-Loader-2/

## Description

ORB
PMHigh & Low
Prev. Day High & Low
Important daily levels for SPY, SPX & QQQ

---

## Source Code

````pine
//@version=6
indicator(
     "GEX Smart Loader — Build 0.2",
     shorttitle = "GEX Smart 0.2",
     overlay = true,
     max_lines_count = 100,
     max_labels_count = 100
)

//======================================================================
// 01 — REPORTE DIARIO GEX
//======================================================================

string reportGroup = "01 — Reporte diario GEX"

string reportText = input.text_area(
     "",
     "Pegar reportes de SPY, SPX y QQQ",
     tooltip = "Pega aquí los reportes completos de SPY, SPX y QQQ.",
     group = reportGroup
)

//======================================================================
// 02 — NIVELES VISIBLES
//======================================================================

string visibilityGroup = "02 — Niveles visibles"

bool showGamma = input.bool(
     true,
     "Gamma: ABS, AG2–AG6, G-Flip y Max Pain",
     group = visibilityGroup
)

bool showPremarket = input.bool(
     true,
     "Premarket High / Low",
     group = visibilityGroup
)

bool showORB = input.bool(
     true,
     "ORB High / Low",
     group = visibilityGroup
)

bool showPreviousDay = input.bool(
     true,
     "Previous Day High / Low",
     group = visibilityGroup
)

bool showWeek = input.bool(
     true,
     "Week High / Low / Mid",
     group = visibilityGroup
)

bool showPanel = input.bool(
     true,
     "Panel de estado",
     group = visibilityGroup
)

bool showPrices = input.bool(
     true,
     "Mostrar precios en etiquetas",
     group = visibilityGroup
)

//======================================================================
// 03 — CONFIGURACIÓN DE SESIONES
//======================================================================

string sessionGroup = "03 — Sesiones"

string sessionTimezone = input.string(
     "America/New_York",
     "Zona horaria",
     options = [
         "America/New_York",
         "America/Chicago",
         "America/Denver",
         "America/Los_Angeles",
         "Etc/UTC"
     ],
     group = sessionGroup
)

string premarketSession = input.session(
     "0400-0930",
     "Sesión de Premarket",
     group = sessionGroup
)

string orbSession = input.session(
     "0930-0945",
     "Sesión del ORB",
     group = sessionGroup
)

//======================================================================
// 04 — APARIENCIA GAMMA
//======================================================================

string gammaAppearanceGroup = "04 — Apariencia Gamma"

color absColor = input.color(
     color.rgb(255, 193, 7),
     "ABS GEX",
     group = gammaAppearanceGroup
)

color agColor = input.color(
     color.rgb(33, 150, 243),
     "AG2–AG6",
     group = gammaAppearanceGroup
)

color flipColor = input.color(
     color.rgb(244, 67, 54),
     "G-Flip",
     group = gammaAppearanceGroup
)

color maxPainColor = input.color(
     color.rgb(156, 39, 176),
     "Max Pain",
     group = gammaAppearanceGroup
)

//======================================================================
// 05 — APARIENCIA DE SESIONES
//======================================================================

string sessionAppearanceGroup = "05 — Apariencia de sesiones"

color premarketColor = input.color(
     color.rgb(0, 188, 212),
     "Premarket High / Low",
     group = sessionAppearanceGroup
)

color orbColor = input.color(
     color.rgb(255, 152, 0),
     "ORB High / Low",
     group = sessionAppearanceGroup
)

//======================================================================
// 06 — APARIENCIA DE ESTRUCTURA
//======================================================================

string structureAppearanceGroup = "06 — Apariencia de estructura"

color previousDayColor = input.color(
     color.rgb(76, 175, 80),
     "Previous Day High / Low",
     group = structureAppearanceGroup
)

color weekColor = input.color(
     color.rgb(121, 85, 72),
     "Week High / Low",
     group = structureAppearanceGroup
)

color weekMidColor = input.color(
     color.rgb(158, 158, 158),
     "Week Mid",
     group = structureAppearanceGroup
)

//======================================================================
// 07 — APARIENCIA GENERAL
//======================================================================

string generalAppearanceGroup = "07 — Apariencia general"

int lineWidth = input.int(
     2,
     "Grosor de líneas",
     minval = 1,
     maxval = 5,
     group = generalAppearanceGroup
)

string gammaLineStyleInput = input.string(
     "Dashed",
     "Estilo Gamma",
     options = ["Solid", "Dashed", "Dotted"],
     group = generalAppearanceGroup
)

string technicalLineStyleInput = input.string(
     "Solid",
     "Estilo niveles técnicos",
     options = ["Solid", "Dashed", "Dotted"],
     group = generalAppearanceGroup
)

int lineTransparency = input.int(
     0,
     "Transparencia de líneas",
     minval = 0,
     maxval = 100,
     group = generalAppearanceGroup
)

int labelTransparency = input.int(
     10,
     "Transparencia de etiquetas",
     minval = 0,
     maxval = 100,
     group = generalAppearanceGroup
)

int labelDistance = input.int(
     15,
     "Distancia de etiquetas",
     minval = 1,
     maxval = 500,
     group = generalAppearanceGroup
)

int lineHistory = input.int(
     150,
     "Extensión hacia la izquierda",
     minval = 1,
     maxval = 5000,
     group = generalAppearanceGroup
)

//======================================================================
// FUNCIONES DE TEXTO
//======================================================================

normalizeText(string source) =>
    string result = str.upper(source)
    result := str.replace_all(result, "\r", "")
    result := str.replace_all(result, "\t", " ")
    result := str.trim(result)
    result

isUnavailable(string source) =>
    string value = normalizeText(source)
    bool unavailable = str.contains(value, "N/A")
    unavailable := unavailable or str.contains(value, ":NA")
    unavailable := unavailable or str.contains(value, "NONE")
    unavailable := unavailable or str.contains(value, "NULL")
    unavailable

extractNumber(string source) =>
    float result = na
    string cleaned = normalizeText(source)
    cleaned := str.replace_all(cleaned, ",", "")
    cleaned := str.replace_all(cleaned, "$", "")

    if not isUnavailable(cleaned)
        array<string> pieces = str.split(cleaned, ":")

        if array.size(pieces) >= 2
            string numberText = array.get(pieces, array.size(pieces) - 1)
            numberText := str.trim(numberText)
            result := str.tonumber(numberText)

    result

isABSLine(string source) =>
    bool exactName = str.contains(source, "ABS GEX")
    bool shortName = str.contains(source, "ABS:")
    exactName or shortName

isGFlipLine(string source) =>
    bool nameOne = str.contains(source, "G-FLIP")
    bool nameTwo = str.contains(source, "GFLIP")
    bool nameThree = str.contains(source, "GAMMA FLIP")
    nameOne or nameTwo or nameThree

isMaxPainLine(string source) =>
    bool nameOne = str.contains(source, "MAX PAIN")
    bool nameTwo = str.contains(source, "MAXPAIN")
    nameOne or nameTwo

isLevelLine(string source) =>
    bool result = isABSLine(source)
    result := result or str.contains(source, "AG2")
    result := result or str.contains(source, "AG3")
    result := result or str.contains(source, "AG4")
    result := result or str.contains(source, "AG5")
    result := result or str.contains(source, "AG6")
    result := result or isGFlipLine(source)
    result := result or isMaxPainLine(source)
    result

//======================================================================
// CONVERSIÓN DE ESTILO
//======================================================================

getLineStyle(string styleInput) =>
    string result = line.style_solid

    if styleInput == "Dashed"
        result := line.style_dashed
    else if styleInput == "Dotted"
        result := line.style_dotted

    result

string gammaLineStyle = getLineStyle(gammaLineStyleInput)
string technicalLineStyle = getLineStyle(technicalLineStyleInput)

//======================================================================
// VARIABLES DEL REPORTE SPY
//======================================================================

float spyABS = na
float spyAG2 = na
float spyAG3 = na
float spyAG4 = na
float spyAG5 = na
float spyAG6 = na
float spyGFlip = na
float spyMaxPain = na

//======================================================================
// VARIABLES DEL REPORTE SPX
//======================================================================

float spxABS = na
float spxAG2 = na
float spxAG3 = na
float spxAG4 = na
float spxAG5 = na
float spxAG6 = na
float spxGFlip = na
float spxMaxPain = na

//======================================================================
// VARIABLES DEL REPORTE QQQ
//======================================================================

float qqqABS = na
float qqqAG2 = na
float qqqAG3 = na
float qqqAG4 = na
float qqqAG5 = na
float qqqAG6 = na
float qqqGFlip = na
float qqqMaxPain = na

bool spyFound = false
bool spxFound = false
bool qqqFound = false

// 0 = Ninguno
// 1 = SPY
// 2 = SPX
// 3 = QQQ

int activeReport = 0

//======================================================================
// PARSER DEL REPORTE
//======================================================================

array<string> reportLines = str.split(reportText, "\n")

if array.size(reportLines) > 0
    for lineIndex = 0 to array.size(reportLines) - 1
        string currentLine = normalizeText(array.get(reportLines, lineIndex))
        bool levelLine = isLevelLine(currentLine)

        if not levelLine
            if str.contains(currentLine, "SPX")
                activeReport := 2
                spxFound := true
            else if str.contains(currentLine, "SPY")
                activeReport := 1
                spyFound := true
            else if str.contains(currentLine, "QQQ")
                activeReport := 3
                qqqFound := true

        if levelLine
            float parsedValue = extractNumber(currentLine)

            if activeReport == 1
                if isABSLine(currentLine)
                    spyABS := parsedValue
                else if str.contains(currentLine, "AG2")
                    spyAG2 := parsedValue
                else if str.contains(currentLine, "AG3")
                    spyAG3 := parsedValue
                else if str.contains(currentLine, "AG4")
                    spyAG4 := parsedValue
                else if str.contains(currentLine, "AG5")
                    spyAG5 := parsedValue
                else if str.contains(currentLine, "AG6")
                    spyAG6 := parsedValue
                else if isGFlipLine(currentLine)
                    spyGFlip := parsedValue
                else if isMaxPainLine(currentLine)
                    spyMaxPain := parsedValue

            else if activeReport == 2
                if isABSLine(currentLine)
                    spxABS := parsedValue
                else if str.contains(currentLine, "AG2")
                    spxAG2 := parsedValue
                else if str.contains(currentLine, "AG3")
                    spxAG3 := parsedValue
                else if str.contains(currentLine, "AG4")
                    spxAG4 := parsedValue
                else if str.contains(currentLine, "AG5")
                    spxAG5 := parsedValue
                else if str.contains(currentLine, "AG6")
                    spxAG6 := parsedValue
                else if isGFlipLine(currentLine)
                    spxGFlip := parsedValue
                else if isMaxPainLine(currentLine)
                    spxMaxPain := parsedValue

            else if activeReport == 3
                if isABSLine(currentLine)
                    qqqABS := parsedValue
                else if str.contains(currentLine, "AG2")
                    qqqAG2 := parsedValue
                else if str.contains(currentLine, "AG3")
                    qqqAG3 := parsedValue
                else if str.contains(currentLine, "AG4")
                    qqqAG4 := parsedValue
                else if str.contains(currentLine, "AG5")
                    qqqAG5 := parsedValue
                else if str.contains(currentLine, "AG6")
                    qqqAG6 := parsedValue
                else if isGFlipLine(currentLine)
                    qqqGFlip := parsedValue
                else if isMaxPainLine(currentLine)
                    qqqMaxPain := parsedValue

//======================================================================
// DETECCIÓN DEL SÍMBOLO
//======================================================================

string chartTicker = str.upper(syminfo.ticker)
string chartRoot = str.upper(syminfo.root)

bool chartIsSPY = chartTicker == "SPY"
bool chartIsSPX = chartTicker == "SPX" or chartRoot == "SPX"
bool chartIsQQQ = chartTicker == "QQQ"

string gammaSource = "N/A"

if chartIsSPY
    gammaSource := "SPY"
else if chartIsSPX
    gammaSource := "SPX"
else if chartIsQQQ
    gammaSource := "QQQ"

//======================================================================
// SELECCIÓN DE NIVELES GAMMA
//======================================================================

float selectedABS = na
float selectedAG2 = na
float selectedAG3 = na
float selectedAG4 = na
float selectedAG5 = na
float selectedAG6 = na
float selectedGFlip = na
float selectedMaxPain = na

if gammaSource == "SPY"
    selectedABS := spyABS
    selectedAG2 := spyAG2
    selectedAG3 := spyAG3
    selectedAG4 := spyAG4
    selectedAG5 := spyAG5
    selectedAG6 := spyAG6
    selectedGFlip := spyGFlip
    selectedMaxPain := spyMaxPain

else if gammaSource == "SPX"
    selectedABS := spxABS
    selectedAG2 := spxAG2
    selectedAG3 := spxAG3
    selectedAG4 := spxAG4
    selectedAG5 := spxAG5
    selectedAG6 := spxAG6
    selectedGFlip := spxGFlip
    selectedMaxPain := spxMaxPain

else if gammaSource == "QQQ"
    selectedABS := qqqABS
    selectedAG2 := qqqAG2
    selectedAG3 := qqqAG3
    selectedAG4 := qqqAG4
    selectedAG5 := qqqAG5
    selectedAG6 := qqqAG6
    selectedGFlip := qqqGFlip
    selectedMaxPain := qqqMaxPain

//======================================================================
// MOTOR DE PREMARKET Y ORB EN 1 MINUTO
//======================================================================

calculateSessionLevels() =>
    var float calculatedPMH = na
    var float calculatedPML = na
    var float calculatedORBH = na
    var float calculatedORBL = na

    bool newTradingDay = ta.change(time("D")) != 0

    bool insidePremarket = not na(
         time(
             "",
             premarketSession,
             sessionTimezone
         )
    )

    bool insideORB = not na(
         time(
             "",
             orbSession,
             sessionTimezone
         )
    )

    bool premarketStarted = insidePremarket and not insidePremarket[1]
    bool orbStarted = insideORB and not insideORB[1]

    if newTradingDay
        calculatedPMH := na
        calculatedPML := na
        calculatedORBH := na
        calculatedORBL := na

    if premarketStarted
        calculatedPMH := high
        calculatedPML := low
    else if insidePremarket
        calculatedPMH := na(calculatedPMH) ? high : math.max(calculatedPMH, high)
        calculatedPML := na(calculatedPML) ? low : math.min(calculatedPML, low)

    if orbStarted
        calculatedORBH := high
        calculatedORBL := low
    else if insideORB
        calculatedORBH := na(calculatedORBH) ? high : math.max(calculatedORBH, high)
        calculatedORBL := na(calculatedORBL) ? low : math.min(calculatedORBL, low)

    [calculatedPMH, calculatedPML, calculatedORBH, calculatedORBL]

[premarketHigh, premarketLow, orbHigh, orbLow] = request.security(
     syminfo.tickerid,
     "1",
     calculateSessionLevels(),
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

//======================================================================
// PREVIOUS DAY HIGH / LOW
//======================================================================

float previousDayHigh = request.security(
     syminfo.tickerid,
     "D",
     high[1],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on
)

float previousDayLow = request.security(
     syminfo.tickerid,
     "D",
     low[1],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on
)

//======================================================================
// CURRENT WEEK HIGH / LOW / MID
//======================================================================

float currentWeekHigh = request.security(
     syminfo.tickerid,
     "W",
     high,
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

float currentWeekLow = request.security(
     syminfo.tickerid,
     "W",
     low,
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

float currentWeekMid = na

if not na(currentWeekHigh) and not na(currentWeekLow)
    currentWeekMid := (currentWeekHigh + currentWeekLow) / 2.0

//======================================================================
// ARRAYS DE OBJETOS
//======================================================================

var array<line> levelLines = array.new_line()
var array<label> levelLabels = array.new_label()

clearObjects() =>
    if array.size(levelLines) > 0
        for objectIndex = 0 to array.size(levelLines) - 1
            line.delete(array.get(levelLines, objectIndex))

    if array.size(levelLabels) > 0
        for objectIndex = 0 to array.size(levelLabels) - 1
            label.delete(array.get(levelLabels, objectIndex))

    array.clear(levelLines)
    array.clear(levelLabels)

//======================================================================
// FUNCIÓN DE DIBUJO
//======================================================================

drawLevel(
     string levelName,
     float levelPrice,
     color levelColor,
     string selectedStyle,
     int staggerNumber
) =>
    if not na(levelPrice)
        int startingBar = math.max(bar_index - lineHistory, 0)
        int labelXPosition = bar_index + labelDistance + staggerNumber

        color visibleLineColor = color.new(
             levelColor,
             lineTransparency
        )

        line newLevelLine = line.new(
             x1 = startingBar,
             y1 = levelPrice,
             x2 = labelXPosition,
             y2 = levelPrice,
             xloc = xloc.bar_index,
             extend = extend.right,
             color = visibleLineColor,
             style = selectedStyle,
             width = lineWidth
        )

        string labelText = levelName

        if showPrices
            labelText := levelName + "  " + str.tostring(
                 levelPrice,
                 format.mintick
            )

        label newLevelLabel = label.new(
             x = labelXPosition,
             y = levelPrice,
             text = labelText,
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_left,
             color = color.new(
                 levelColor,
                 labelTransparency
             ),
             textcolor = color.white,
             size = size.small
        )

        array.push(levelLines, newLevelLine)
        array.push(levelLabels, newLevelLabel)

//======================================================================
// DIBUJAR TODOS LOS NIVELES
//======================================================================

if barstate.islast
    clearObjects()

    int stagger = 0

    if showGamma and gammaSource != "N/A"
        drawLevel(
             "ABS GEX",
             selectedABS,
             absColor,
             gammaLineStyle,
             stagger
        )
        stagger += 1

        drawLevel(
             "AG2",
             selectedAG2,
             agColor,
             gammaLineStyle,
             stagger
        )
        stagger += 1

        drawLevel(
             "AG3",
             selectedAG3,
             agColor,
             gammaLineStyle,
             stagger
        )
        stagger += 1

        drawLevel(
             "AG4",
             selectedAG4,
             agColor,
             gammaLineStyle,
             stagger
        )
        stagger += 1

        drawLevel(
             "AG5",
             selectedAG5,
             agColor,
             gammaLineStyle,
             stagger
        )
        stagger += 1

        drawLevel(
             "AG6",
             selectedAG6,
             agColor,
             gammaLineStyle,
             stagger
        )
        stagger += 1

        drawLevel(
             "G-FLIP",
             selectedGFlip,
             flipColor,
             gammaLineStyle,
             stagger
        )
        stagger += 1

        drawLevel(
             "MAX PAIN",
             selectedMaxPain,
             maxPainColor,
             gammaLineStyle,
             stagger
        )
        stagger += 1

    if showPremarket
        drawLevel(
             "PMH",
             premarketHigh,
             premarketColor,
             technicalLineStyle,
             stagger
        )
        stagger += 1

        drawLevel(
             "PML",
             premarketLow,
             premarketColor,
             technicalLineStyle,
             stagger
        )
        stagger += 1

    if showORB
        drawLevel(
             "ORB HIGH",
             orbHigh,
             orbColor,
             technicalLineStyle,
             stagger
        )
        stagger += 1

        drawLevel(
             "ORB LOW",
             orbLow,
             orbColor,
             technicalLineStyle,
             stagger
        )
        stagger += 1

    if showPreviousDay
        drawLevel(
             "PDH",
             previousDayHigh,
             previousDayColor,
             technicalLineStyle,
             stagger
        )
        stagger += 1

        drawLevel(
             "PDL",
             previousDayLow,
             previousDayColor,
             technicalLineStyle,
             stagger
        )
        stagger += 1

    if showWeek
        drawLevel(
             "WEEK HIGH",
             currentWeekHigh,
             weekColor,
             technicalLineStyle,
             stagger
        )
        stagger += 1

        drawLevel(
             "WEEK MID",
             currentWeekMid,
             weekMidColor,
             technicalLineStyle,
             stagger
        )
        stagger += 1

        drawLevel(
             "WEEK LOW",
             currentWeekLow,
             weekColor,
             technicalLineStyle,
             stagger
        )

//======================================================================
// CONTADORES
//======================================================================

int gammaLevelsLoaded = 0

if not na(selectedABS)
    gammaLevelsLoaded += 1

if not na(selectedAG2)
    gammaLevelsLoaded += 1

if not na(selectedAG3)
    gammaLevelsLoaded += 1

if not na(selectedAG4)
    gammaLevelsLoaded += 1

if not na(selectedAG5)
    gammaLevelsLoaded += 1

if not na(selectedAG6)
    gammaLevelsLoaded += 1

if not na(selectedGFlip)
    gammaLevelsLoaded += 1

if not na(selectedMaxPain)
    gammaLevelsLoaded += 1

int technicalLevelsLoaded = 0

if not na(premarketHigh)
    technicalLevelsLoaded += 1

if not na(premarketLow)
    technicalLevelsLoaded += 1

if not na(orbHigh)
    technicalLevelsLoaded += 1

if not na(orbLow)
    technicalLevelsLoaded += 1

if not na(previousDayHigh)
    technicalLevelsLoaded += 1

if not na(previousDayLow)
    technicalLevelsLoaded += 1

if not na(currentWeekHigh)
    technicalLevelsLoaded += 1

if not na(currentWeekMid)
    technicalLevelsLoaded += 1

if not na(currentWeekLow)
    technicalLevelsLoaded += 1

//======================================================================
// PANEL DE ESTADO
//======================================================================

var table statusPanel = table.new(
     position.top_right,
     2,
     8,
     border_width = 1
)

if barstate.islast
    if showPanel
        color panelBackground = color.new(color.black, 15)
        color goodColor = color.rgb(76, 175, 80)
        color warningColor = color.rgb(255, 193, 7)
        color badColor = color.rgb(244, 67, 54)
        color neutralColor = color.rgb(158, 158, 158)

        table.cell(
             statusPanel,
             0,
             0,
             "GEX SMART",
             text_color = color.white,
             bgcolor = panelBackground
        )

        table.cell(
             statusPanel,
             1,
             0,
             chartTicker,
             text_color = color.white,
             bgcolor = panelBackground
        )

        table.cell(
             statusPanel,
             0,
             1,
             "SPY report",
             text_color = color.white,
             bgcolor = panelBackground
        )

        table.cell(
             statusPanel,
             1,
             1,
             spyFound ? "OK" : "—",
             text_color = spyFound ? goodColor : badColor,
             bgcolor = panelBackground
        )

        table.cell(
             statusPanel,
             0,
             2,
             "SPX report",
             text_color = color.white,
             bgcolor = panelBackground
        )

        table.cell(
             statusPanel,
             1,
             2,
             spxFound ? "OK" : "—",
             text_color = spxFound ? goodColor : badColor,
             bgcolor = panelBackground
        )

        table.cell(
             statusPanel,
             0,
             3,
             "QQQ report",
             text_color = color.white,
             bgcolor = panelBackground
        )

        table.cell(
             statusPanel,
             1,
             3,
             qqqFound ? "OK" : "—",
             text_color = qqqFound ? goodColor : badColor,
             bgcolor = panelBackground
        )

        table.cell(
             statusPanel,
             0,
             4,
             "Gamma source",
             text_color = color.white,
             bgcolor = panelBackground
        )

        table.cell(
             statusPanel,
             1,
             4,
             gammaSource,
             text_color = gammaSource == "N/A" ? neutralColor : goodColor,
             bgcolor = panelBackground
        )

        table.cell(
             statusPanel,
             0,
             5,
             "Gamma levels",
             text_color = color.white,
             bgcolor = panelBackground
        )

        table.cell(
             statusPanel,
             1,
             5,
             gammaSource == "N/A" ? "N/A" : str.tostring(gammaLevelsLoaded) + "/8",
             text_color = gammaLevelsLoaded > 0 ? goodColor : neutralColor,
             bgcolor = panelBackground
        )

        table.cell(
             statusPanel,
             0,
             6,
             "Technical",
             text_color = color.white,
             bgcolor = panelBackground
        )

        table.cell(
             statusPanel,
             1,
             6,
             str.tostring(technicalLevelsLoaded) + "/9",
             text_color = technicalLevelsLoaded >= 6 ? goodColor : warningColor,
             bgcolor = panelBackground
        )

        table.cell(
             statusPanel,
             0,
             7,
             "1m engine",
             text_color = color.white,
             bgcolor = panelBackground
        )

        table.cell(
             statusPanel,
             1,
             7,
             "ACTIVE",
             text_color = goodColor,
             bgcolor = panelBackground
        )

    else
        table.clear(
             statusPanel,
             0,
             0,
             1,
             7
        )
````
